unit nes_ppu;

interface

uses {$IFDEF WINDOWS}windows,{$ENDIF}
     gfx_engine,main_engine,pal_engine,math,n2a03;

type
  tnes_ppu=packed record
      control1,control2,status,sprite_ram_pos:byte;
      sprite_ram:array[0..$ff] of byte;
      sprite_size,pos_bg,pos_spt:byte;
      sprite0_hit_pos:single;
      dir_first,sprite0_hit,sprite_over_flow,disable_chr,write_chr:boolean;
      name_table:array [0..3,0..$3ff] of byte;
      chr:array[0..3,0..$fff] of byte;
      pal_ram:array[0..$1f] of byte;
      linea,address_temp,address:word;
      open_bus,mirror,buffer_read,tile_x_offset:byte;
      dot_line_trans:array[0..((33*8)-1)] of byte;  //012345-- --> sprites
                                                    //-------7 --> Background
  end;

procedure ppu_dma_spr(direccion:byte);
procedure reset_ppu;
procedure ppu_linea(nes_linea:word);
function ppu_read:byte;
procedure ppu_write(valor:byte);
procedure nes_init_palette;
procedure ppu_end_y_coarse;

const
  MIRROR_HORIZONTAL=1;
  MIRROR_VERTICAL=2;
  MIRROR_LOW=3;
  MIRROR_HIGH=4;
  MIRROR_FOUR_SCREEN=5;
  MIRROR_MAP95=6;
  MIRROR_MAP243=7;
  MIRROR_MAP139=8;
  //Los sprites se evaluan desde 64 al 255 (PPU T), convertidos en CPU T --> 21.333 al 85 o lo que es lo mismo aprox 8T por sprite
  //Como el sprite 0 siempre se evalua el primero, si hay un hit sera desde el 21.333 al 29
  PPU_PIXEL_TIMING=((128*2)/3)/256;
  MIRROR_TYPES:array [1..8,0..3] of byte=((0,0,1,1),(0,1,0,1),(0,0,0,0),(1,1,1,1),(0,1,2,3),(1,1,0,0),(0,0,0,1),(0,1,1,1));

var
  ppu_nes:^tnes_ppu;

implementation

uses nes,nes_mappers;

function ppu_read_mem(address:word):byte;
begin
case (address and $3fff) of
  $0..$1fff:if not(ppu_nes.disable_chr) then ppu_read_mem:=ppu_nes.chr[mapper_nes.chr_map[(address shr 12) and 1],address and $fff]
            else ppu_read_mem:=address and $ff;
  $2000..$3eff:ppu_read_mem:=ppu_nes.name_table[MIRROR_TYPES[ppu_nes.mirror,(address shr 10) and 3],address and $3ff];
  $3f00..$3fff:ppu_read_mem:=ppu_nes.pal_ram[address and $1f]; //Palete
end;
end;

procedure putsprites(nes_linea:word;pri:byte);
var
  f,x,pos_x,pos_y,punto,tempb1,tempb2,nsprites:byte;
  num_char,atrib,temp,def_y:byte;
  flipx,flipy:boolean;
  pos_linea:word;
  ptemp:pword;
begin
nsprites:=0;
for f:=0 to 63 do begin
 pos_y:=ppu_nes.sprite_ram[f*4];
 if (((ppu_nes.sprite_ram[(f*4)+2] and $20)<>pri) or (pos_y>239)) then continue;
 pos_x:=ppu_nes.sprite_ram[(f*4)+3];
 pos_linea:=nes_linea-(pos_y+1);
if (pos_linea<ppu_nes.sprite_size) then begin
   nsprites:=nsprites+1;
   if nsprites=9 then exit;
   atrib:=(ppu_nes.sprite_ram[(f*4)+2] and $3) shl 2;
   flipx:=(ppu_nes.sprite_ram[(f*4)+2] and $40)=$40;
   flipy:=(ppu_nes.sprite_ram[(f*4)+2] and $80)=$80;
   num_char:=ppu_nes.sprite_ram[(f*4)+1];
   if ppu_nes.sprite_size=8 then begin //8x8
      temp:=ppu_nes.pos_spt;
      if flipy then def_y:=7-(pos_linea and 7)
        else def_y:=pos_linea and 7;
   end else begin //8x16
      temp:=num_char and 1;
      if flipy then begin
        def_y:=7-(pos_linea and 7);
        num_char:=(num_char and $fe)+(not(pos_linea shr 3) and 1);
      end else begin
        def_y:=pos_linea and 7;
        num_char:=(num_char and $fe)+(pos_linea shr 3);
      end;
   end;
   ptemp:=punbuf;
   tempb1:=ppu_read_mem((temp*$1000)+(num_char*16)+def_y);
   if @mapper_nes.ppu_read<>nil then mapper_nes.ppu_read((temp*$1000)+(num_char*16)+def_y);
   tempb2:=ppu_read_mem((temp*$1000)+(num_char*16)+8+def_y);
   if @mapper_nes.ppu_read<>nil then mapper_nes.ppu_read((temp*$1000)+(num_char*16)+8+def_y);
   if flipx then begin
        for x:=0 to 7 do begin
          punto:=(((tempb1 and (1 shl x)) shr x) and 1)+((((tempb2 and (1 shl x)) shr x) and 1) shl 1);
          if punto=0 then ptemp^:=paleta[max_colores]
            else begin
              //Sprite 0 Hit
              if (((pos_x+x)<>255) and (f=0) and ((ppu_nes.dot_line_trans[pos_x+x] and $3f)<>0) and ((ppu_nes.status and $40)=0)) then begin
                ppu_nes.sprite0_hit:=true;
                ppu_nes.sprite0_hit_pos:=nsprites*8*PPU_PIXEL_TIMING;
              end;
              if (((ppu_nes.control2 and $4)=0) and ((pos_x+x)<8)) then begin
                ptemp^:=paleta[max_colores];
              end else begin
                 if ((ppu_nes.dot_line_trans[pos_x+x] and $3f)>=f) then begin
                    ptemp^:=paleta[ppu_read_mem($3f10+punto+atrib) and $3f];
                    ppu_nes.dot_line_trans[pos_x+x]:=(ppu_nes.dot_line_trans[pos_x+x] and $80) or f;
                 end else
                    ptemp^:=paleta[max_colores];
                 end;
            end;
          inc(ptemp);
        end;
        putpixel(0,0,8,punbuf,PANT_SPRITES);
   end else begin
        for x:=7 downto 0 do begin
          punto:=(((tempb1 and (1 shl x)) shr x) and 1)+((((tempb2 and (1 shl x)) shr x) and 1) shl 1);
          if punto=0 then ptemp^:=paleta[max_colores]
            else begin
              //Sprite 0 Hit
              if (((pos_x+(7-x))<>255) and (f=0) and ((ppu_nes.dot_line_trans[pos_x+(7-x)] and $3f)<>0) and ((ppu_nes.status and $40)=0)) then begin
                 ppu_nes.sprite0_hit:=true;
                 ppu_nes.sprite0_hit_pos:=nsprites*8*PPU_PIXEL_TIMING;;
              end;
              if (((ppu_nes.control2 and $4)=0) and ((pos_x+(7-x))<8)) then begin
                ptemp^:=paleta[max_colores];
              end else begin
                if ((ppu_nes.dot_line_trans[pos_x+(7-x)] and $3f)>=f) then begin //Prioridad sprite/sprite
                  ptemp^:=paleta[ppu_read_mem($3f10+punto+atrib) and $3f];
                  ppu_nes.dot_line_trans[pos_x+(7-x)]:=(ppu_nes.dot_line_trans[pos_x+(7-x)] and $80) or f;
                end else ptemp^:=paleta[max_colores];
              end;
            end;
          inc(ptemp);
        end;
        putpixel(0,0,8,punbuf,PANT_SPRITES);
   end;
   actualiza_trozo(0,0,8,1,PANT_SPRITES,pos_x,nes_linea,8,1,2);
 end;
end;
end;

function set_emphasis(pal_tmp:word):word;
begin
if ((ppu_nes.control2 and $80)<>0) then begin //Azul
   pal_tmp:=(pal_tmp and $ce7f);
end;
if ((ppu_nes.control2 and $40)<>0) then begin //Verde
   pal_tmp:=(pal_tmp and $cff9);
end;
if ((ppu_nes.control2 and $20)<>0) then begin //rojo
   pal_tmp:=(pal_tmp and $fe79);
end;
set_emphasis:=pal_tmp;
end;

procedure putbackground;
var
    AttribTable,PatternAdr,AttribVal,tiles,Col,x,TileYOffset:integer;
    ptemp:pword;
    pos_x:word;
begin
    AttribTable:=$2000+(ppu_nes.address and $C00)+$3C0+((((ppu_nes.address and $3E0) div $20) and $FFFC)*$2)+((ppu_nes.address and $1F) div $4);
    ptemp:=punbuf;
    pos_x:=0;
    TileYOffset:=(ppu_nes.address and $7000) shr 12;
    if ((ppu_nes.address and $40)=0) then begin
      if ((ppu_nes.address and $2)=0) then AttribVal:=(ppu_read_mem(AttribTable) and $3) shl 2
        else AttribVal:=ppu_read_mem(AttribTable) and $C;
    end else begin
      if ((ppu_nes.address and $2)=0) then AttribVal:=(ppu_read_mem(AttribTable) and $30) shr 2
        else AttribVal:=(ppu_read_mem(AttribTable) and $C0) shr 4;
    end;
    for tiles:=33 downto 0 do begin
        PatternAdr:=(ppu_nes.pos_bg*$1000)+(ppu_read_mem($2000+(ppu_nes.address and $fff))*$10)+TileYOffset;
        if @mapper_nes.ppu_read<>nil then mapper_nes.ppu_read(PatternAdr);
        // Draw tile line
        for x:=7 downto 0 do begin
            Col:=((ppu_read_mem(PatternAdr) and (1 shl x)) shr x)+((ppu_read_mem(PatternAdr+8) and (1 shl x)) shr x)*2;
            if Col=0 then begin
              ptemp^:=paleta[max_colores];
              ppu_nes.dot_line_trans[pos_x]:=ppu_nes.dot_line_trans[pos_x] and $7f;
            end else begin
              ptemp^:=set_emphasis(paleta[ppu_read_mem($3f00+Col+AttribVal) and $3f]);
              ppu_nes.dot_line_trans[pos_x]:=ppu_nes.dot_line_trans[pos_x] or $80;
            end;
            inc(ptemp);
            pos_x:=pos_x+1;
        end;
        //los bits 0,1,2,3,4 son la X
        if (ppu_nes.address and $1f)=$1f then begin
            //Cuando llega a 31 --> bit 10 cambia
            AttribTable:=(AttribTable xor $400)-$8;
            ppu_nes.address:=ppu_nes.address xor $41F;
        end else begin
          ppu_nes.address:=ppu_nes.address+1;
        end;
        if (ppu_nes.address and $3)=0 then AttribTable:=AttribTable+1;
        if (ppu_nes.address and $1)=0 Then begin
            if ((ppu_nes.address and $40)=0) then begin
                if ((ppu_nes.address and $2)=0) then AttribVal:=(ppu_read_mem(AttribTable) and $3) shl 2
                  else AttribVal:=ppu_read_mem(AttribTable) and $C;
            end else begin
                if ((ppu_nes.address and $2)=0) then AttribVal:=(ppu_read_mem(AttribTable) and $30) shr 2
                   else AttribVal:=(ppu_read_mem(AttribTable) and $C0) shr 4;
            end;
        end;
    end;
    // Clip left tiles, bit 1 of PPU2 = 0
    if (ppu_nes.control2 and $1e)<>$1e then begin
        ptemp:=punbuf;
        inc(ptemp,ppu_nes.tile_x_offset);
        for x:=0 to 7 do begin
          ppu_nes.dot_line_trans[x]:=ppu_nes.dot_line_trans[x] and $7f;
          ptemp^:=set_emphasis(paleta[ppu_read_mem($3f00)]);
          inc(ptemp);
        end;
    end;
    putpixel(0,0,256+ppu_nes.tile_x_offset,punbuf,1);
end;

procedure ppu_end_y_coarse;
var
  tmp:word;
begin
if (ppu_nes.control2 and $18)<>0 then begin
  ppu_nes.address:=ppu_nes.address+$1000;
  if (ppu_nes.address and $8000)<>0 then begin
    tmp:=(ppu_nes.address and $03e0)+$20;
    ppu_nes.address:=ppu_nes.address and $7c1f;
    // handle bizarro scrolling rollover at the 30th (not 32nd) vertical tile
    if (tmp=$03c0) then ppu_nes.address:=ppu_nes.address xor $0800 else ppu_nes.address:=ppu_nes.address or (tmp and $03e0);
  end;
  ppu_nes.address:=(ppu_nes.address and $7be0) or (ppu_nes.address_temp and $41f);
end;
end;

procedure sprite_line_overflow(nes_linea:word);
var
   f,pos_y,size,pos_linea:byte;
   nsprites:byte;
begin
nsprites:=0;
for f:=0 to 63 do begin
    pos_y:=ppu_nes.sprite_ram[f*4];
    if ((pos_y=255) or (pos_y=240)) then continue;
    size:=8 shl ((ppu_nes.control1 and $20) shr 5);
    pos_linea:=nes_linea-(pos_y+1);
    if (pos_linea<size) then begin
       nsprites:=nsprites+1;
       if nsprites=9 then begin
          ppu_nes.sprite_over_flow:=true;
          exit;
       end;
    end;
end;
end;

procedure ppu_linea(nes_linea:word);
var
  fondo_pal:word;
begin
fondo_pal:=set_emphasis(paleta[ppu_read_mem($3f00)]);
single_line(0,nes_linea,fondo_pal,256,2);
fillchar(ppu_nes.dot_line_trans[0],264,$3f);
//Si los sprites O el fondo estan activos, hay sprite overflow
//Evalua los sprites DE LA LINEA SIGUIENTE!! Los sprites de la linea 0 se carga
//en la 261 PERO NO SE EVALUA NADA
if (ppu_nes.control2 and $18)<>0 then sprite_line_overflow(nes_linea+1);
if (ppu_nes.control2 and $8)<>0 then putbackground;
if (ppu_nes.control2 and $10)<>0 then putsprites(nes_linea,$20);
if (ppu_nes.control2 and $8)<>0 then actualiza_trozo(ppu_nes.tile_x_offset,0,256,1,1,0,nes_linea,256,1,2);
if (ppu_nes.control2 and $10)<>0 then putsprites(nes_linea,$0);
//Si los sprites o el fondo estan desactivados, no hay sprite 0 hit
if (ppu_nes.control2 and $18)<>$18 then ppu_nes.sprite0_hit:=false;
end;

function ppu_read:byte;
var
  ret:byte;
begin
//Proteccion del mapper 185!!!
if ppu_nes.disable_chr then ret:=ppu_nes.address and $ff
  else ret:=ppu_nes.buffer_read;
ppu_nes.buffer_read:=ppu_read_mem(ppu_nes.address);
if ((ppu_nes.linea>=240) or ((ppu_nes.control2 and $18)=0)) then begin
  if (ppu_nes.control1 and $4)<>0 then ppu_nes.address:=(ppu_nes.address+32) and $7fff
    else ppu_nes.address:=(ppu_nes.address+1) and $7fff;
end else begin
  //X fina
  if (ppu_nes.address and $1F)=$1F then ppu_nes.address:=ppu_nes.address xor $41f
    else ppu_nes.address:=ppu_nes.address+1;
  //Y fina
  ppu_end_y_coarse;
end;
ppu_read:=ret;
end;

procedure ppu_write(valor:byte);
begin
case (ppu_nes.address and $3fff) of
  $0..$1fff:if (not(ppu_nes.disable_chr) and ppu_nes.write_chr) then ppu_nes.chr[mapper_nes.chr_map[(ppu_nes.address shr 12) and 1],ppu_nes.address and $fff]:=valor;
  $2000..$3eff:ppu_nes.name_table[MIRROR_TYPES[ppu_nes.mirror,(ppu_nes.address shr 10) and 3],ppu_nes.address and $3ff]:=valor;
  $3f00..$3fff:case (ppu_nes.address and $1f) of //Palete
                    0,$10:begin
                        ppu_nes.pal_ram[0]:=valor;ppu_nes.pal_ram[$04]:=valor;
                        ppu_nes.pal_ram[$8]:=valor;ppu_nes.pal_ram[$0c]:=valor;
                        ppu_nes.pal_ram[$10]:=valor;ppu_nes.pal_ram[$14]:=valor;
                        ppu_nes.pal_ram[$18]:=valor;ppu_nes.pal_ram[$1c]:=valor;
                    end;
                    else ppu_nes.pal_ram[ppu_nes.address and $1f]:=valor;
                  end;
end;
if ((ppu_nes.linea>=240) or ((ppu_nes.control2 and $18)=0)) then begin
  if (ppu_nes.control1 and $4)<>0 then ppu_nes.address:=(ppu_nes.address+32) and $7fff
    else ppu_nes.address:=(ppu_nes.address+1) and $7fff;
end else begin
  //X fina
  if (ppu_nes.address and $1F)=$1F then ppu_nes.address:=ppu_nes.address xor $41f
    else ppu_nes.address:=ppu_nes.address+1;
  //Y fina
  ppu_end_y_coarse;
end;
end;

procedure ppu_dma_spr(direccion:byte);
begin
if ppu_nes.sprite_ram_pos<>0 then begin
  copymemory(@ppu_nes.sprite_ram[ppu_nes.sprite_ram_pos],@memoria[$100*direccion],$100-ppu_nes.sprite_ram_pos);
  copymemory(@ppu_nes.sprite_ram[0],@memoria[$100*direccion],ppu_nes.sprite_ram_pos);
end else begin
  copymemory(@ppu_nes.sprite_ram[0],@memoria[$100*direccion],$100);
end;
n2a03_0.m6502.contador:=n2a03_0.m6502.contador+513+(n2a03_0.m6502.contador and 1);
end;

procedure reset_ppu;
begin
ppu_nes.control1:=0;
ppu_nes.control2:=0;
ppu_nes.status:=0;
ppu_nes.sprite_ram_pos:=0;
ppu_nes.address:=0;
ppu_nes.address_temp:=0;
ppu_nes.dir_first:=false;
ppu_nes.sprite0_hit:=false;
ppu_nes.sprite_over_flow:=false;
ppu_nes.sprite_size:=8;
ppu_nes.pos_bg:=0;
ppu_nes.pos_spt:=1;
ppu_nes.sprite0_hit_pos:=0;
ppu_nes.disable_chr:=false;
ppu_nes.buffer_read:=random(256);
ppu_nes.tile_x_offset:=0;
fillchar(ppu_nes.dot_line_trans[0],(33*8)-1,0);
end;

procedure nes_init_palette;
const
  brightness:array[0..2,0..3] of single=(
		(0.50,0.75,1.00,1.00),
    (0.29,0.45,0.73,0.90),
		(0.00,0.24,0.47,0.77));
  M_PI=3.1415;
var
	color_intensity,color_num,color_emphasis:integer;
	R,G,B:single;
	tint:single; // adjust to taste */
	hue,Kr,Kb,Ku,Kv:single;
  sat,y,u,v,rad:single;
  colores:tpaleta;
  pos_col:byte;
begin
	// This routine builds a palette using a transformation from
	// the YUV (Y, B-Y, R-Y) to the RGB color space
	// The NES has a 64 color palette
	// 16 colors, with 4 luminance levels for each color
	// The 16 colors circle around the YUV color space,
  pos_col:=0;
	tint:=0.22;	// adjust to taste */
	hue:=287.0;
	Kr:=0.2989;
	Kb:=0.1145;
	Ku:=2.029;
	Kv:=1.140;
	// Loop through the emphasis modes (8 total) */
	for color_emphasis:=0 to 7 do begin
		// loop through the 4 intensities
		for color_intensity:=0 to 3 do begin
			// loop through the 16 colors */
			for color_num:=0 to 15 do begin
				case color_num of
					0:begin
  						sat:=0;
              rad:=0;
  						y:=brightness[0][color_intensity];
						end;
					13:begin
  						sat:=0;
              rad:=0;
	  					y:=brightness[2][color_intensity];
						 end;
					14,15:begin
              sat:=0;
              rad:=0;
              y:=0;
						 end;
          else begin
						sat:=tint;
						rad:=M_PI*((color_num*30+hue)/180.0);
						y:=brightness[1][color_intensity];
          end;
				end;
				u:=sat*cos(rad);
				v:=sat*sin(rad);
				// Transform to RGB */
				R:=(y+Kv*v)*255.0;
				G:=(y-(Kb*Ku*u+Kr*Kv*v)/(1-Kb-Kr))*255.0;
				B:=(y+Ku*u)*255.0;
				// Clipping, in case of saturation */
				if (R<0) then R:=0
				  else if (R>255) then R:=255;
				if (G<0) then G:=0
				  else if (G>255) then G:=255;
				if (B<0) then B:=0
				  else if (B>255) then B:=255;
				// Round, and set the value */
        colores[pos_col].r:=floor(R+0.5);
        colores[pos_col].g:=floor(G+0.5);
        colores[pos_col].b:=floor(B+0.5);
        pos_col:=pos_col+1;
			end; //color_num
		end; //color_intensity
	end; //Color_emphasis
  set_pal(colores,64);
	// color tables are modified at run-time, and are initialized on 'ppu2c0x_reset' */
end;

end.
