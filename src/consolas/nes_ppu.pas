unit nes_ppu;
interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     gfx_engine,main_engine,pal_engine,math,n2a03;

type
  nesppu_chip=class
      constructor create;
      destructor free;
    public
      linea,address,address_temp:word;
      disable_chr,sprite_over_flow,sprite0_hit,dir_first,write_chr:boolean;
      mirror,tile_x_offset,pos_bg,pos_spt,sprite_size,control1,control2,status,open_bus,sprite_ram_pos:byte;
      pal_mask:byte;
      sprite0_hit_pos:single;
      sprite_ram:array[0..$ff] of byte;
      chr:array[0..3,0..$fff] of byte;
      name_table:array [0..3,0..$3ff] of byte;
      procedure dma_spr(direccion:byte);
      procedure reset;
      procedure draw_linea(nes_linea:word);
      function read:byte;
      procedure write(valor:byte);
      procedure end_y_coarse;
      function save_snapshot(data:pbyte):word;
      procedure load_snapshot(data:pbyte);
    private
      pal_ram:array[0..$1f] of byte;
      buffer_read:byte;
      //Son 33 de la pantalla, uno del scroll y uno mas por si acaso!
      dot_line_trans:array[0..((34*8)-1)] of byte;  //012345-- --> sprites
                                                    //-------7 --> Background
      function read_mem(address:word):byte;
      function set_emphasis(pal_tmp:word):word;
    end;
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
  PPU_PIXEL_TIMING=1789733/60.0988/262/256;//((128*2)/3)/256;
  MIRROR_TYPES:array [1..8,0..3] of byte=((0,0,1,1),(0,1,0,1),(0,0,0,0),(1,1,1,1),(0,1,2,3),(1,1,0,0),(0,0,0,1),(0,1,1,1));

var
  ppu_nes_0:nesppu_chip;

implementation
uses nes,nes_mappers;

function nesppu_chip.save_snapshot(data:pbyte):word;
var
  temp:pbyte;
  buffer:array[0..26] of byte;
  size:word;
begin
  temp:=data;
  copymemory(temp,@self.sprite_ram,sizeof(self.sprite_ram));
  size:=sizeof(self.sprite_ram);
  inc(temp,sizeof(self.sprite_ram));
  copymemory(temp,@self.chr,sizeof(self.chr));
  size:=size+sizeof(self.chr);
  inc(temp,sizeof(self.chr));
  copymemory(temp,@self.name_table,sizeof(self.name_table));
  size:=size+sizeof(self.name_table);
  inc(temp,sizeof(self.name_table));
  copymemory(temp,@self.pal_ram,sizeof(self.pal_ram));
  size:=size+sizeof(self.pal_ram);
  inc(temp,sizeof(self.pal_ram));
  copymemory(temp,@self.dot_line_trans,sizeof(self.dot_line_trans));
  size:=size+sizeof(self.dot_line_trans);
  inc(temp,sizeof(self.dot_line_trans));
  copymemory(@buffer[0],@self.linea,2);
  copymemory(@buffer[2],@self.address,2);
  copymemory(@buffer[4],@self.address_temp,2);
  buffer[6]:=byte(self.disable_chr);
  buffer[7]:=byte(self.sprite_over_flow);
  buffer[8]:=byte(self.sprite0_hit);
  buffer[9]:=byte(self.dir_first);
  buffer[10]:=byte(self.write_chr);
  buffer[11]:=self.mirror;
  buffer[12]:=self.tile_x_offset;
  buffer[13]:=self.pos_bg;
  buffer[14]:=self.pos_spt;
  buffer[15]:=self.sprite_size;
  buffer[16]:=self.control1;
  buffer[17]:=self.control2;
  buffer[18]:=self.status;
  buffer[19]:=self.open_bus;
  buffer[20]:=self.sprite_ram_pos;
  copymemory(@buffer[21],@self.sprite0_hit_pos,4);
  buffer[25]:=self.buffer_read;
  buffer[26]:=self.pal_mask;
  copymemory(temp,@buffer[0],27);
  save_snapshot:=size+27;
end;

procedure nesppu_chip.load_snapshot(data:pbyte);
var
  temp:pbyte;
  buffer:array[0..26] of byte;
begin
  temp:=data;
  copymemory(@self.sprite_ram,temp,sizeof(self.sprite_ram));
  inc(temp,sizeof(self.sprite_ram));
  copymemory(@self.chr,temp,sizeof(self.chr));
  inc(temp,sizeof(self.chr));
  copymemory(@self.name_table,temp,sizeof(self.name_table));
  inc(temp,sizeof(self.name_table));
  copymemory(@self.pal_ram,temp,sizeof(self.pal_ram));
  inc(temp,sizeof(self.pal_ram));
  copymemory(@self.dot_line_trans,temp,sizeof(self.dot_line_trans));
  inc(temp,sizeof(self.dot_line_trans));
  copymemory(@buffer[0],temp,27);
  copymemory(@self.linea,@buffer[0],2);
  copymemory(@self.address,@buffer[2],2);
  copymemory(@self.address_temp,@buffer[4],2);
  self.disable_chr:=buffer[6]<>0;
  self.sprite_over_flow:=buffer[7]<>0;
  self.sprite0_hit:=buffer[8]<>0;
  self.dir_first:=buffer[9]<>0;
  self.write_chr:=buffer[10]<>0;
  self.mirror:=buffer[11];
  self.tile_x_offset:=buffer[12];
  self.pos_bg:=buffer[13];
  self.pos_spt:=buffer[14];
  self.sprite_size:=buffer[15];
  self.control1:=buffer[16];
  self.control2:=buffer[17];
  self.status:=buffer[18];
  self.open_bus:=buffer[19];
  self.sprite_ram_pos:=buffer[20];
  copymemory(@self.sprite0_hit_pos,@buffer[21],4);
  self.buffer_read:=buffer[25];
  self.pal_mask:=buffer[26];
end;

constructor nesppu_chip.create;
const
  BRIGHTNESS:array[0..2,0..3] of single=(
		(0.50,0.75,1.00,1.00),
    (0.29,0.45,0.73,0.90),
		(0.00,0.24,0.47,0.77));
var
	color_intensity,color_num,color_emphasis:integer;
	r,g,b:single;
	tint:single; // adjust to taste
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
	tint:=0.22;	// adjust to taste
	hue:=287.0;
	Kr:=0.2989;
	Kb:=0.1145;
	Ku:=2.029;
	Kv:=1.140;
	// Loop through the emphasis modes (8 total)
	for color_emphasis:=0 to 7 do begin
		// loop through the 4 intensities
		for color_intensity:=0 to 3 do begin
			// loop through the 16 colors
			for color_num:=0 to 15 do begin
				case color_num of
					0:begin
  						sat:=0;
              rad:=0;
  						y:=BRIGHTNESS[0][color_intensity];
						end;
					13:begin
  						sat:=0;
              rad:=0;
	  					y:=BRIGHTNESS[2][color_intensity];
						 end;
					14,15:begin
              sat:=0;
              rad:=0;
              y:=0;
						 end;
          else begin
						sat:=tint;
						rad:=M_PI*((color_num*30+hue)/180.0);
						y:=BRIGHTNESS[1][color_intensity];
          end;
				end;
				u:=sat*cos(rad);
				v:=sat*sin(rad);
				// Transform to RGB
				R:=(y+Kv*v)*255;
				G:=(y-(Kb*Ku*u+Kr*Kv*v)/(1-Kb-Kr))*255;
				B:=(y+Ku*u)*255;
				// Clipping, in case of saturation
				if (R<0) then R:=0
				  else if (R>255) then R:=255;
				if (G<0) then G:=0
				  else if (G>255) then G:=255;
				if (B<0) then B:=0
				  else if (B>255) then B:=255;
				// Round, and set the value
        colores[pos_col].r:=floor(R+0.5);
        colores[pos_col].g:=floor(G+0.5);
        colores[pos_col].b:=floor(B+0.5);
        pos_col:=pos_col+1;
			end; //color_num
		end; //color_intensity
	end; //Color_emphasis
  set_pal(colores,64);
end;

destructor nesppu_chip.free;
begin
end;

procedure nesppu_chip.reset;
begin
self.control1:=0;
self.control2:=0;
self.pal_mask:=$3f;
self.status:=0;
self.sprite_ram_pos:=0;
self.address:=0;
self.address_temp:=0;
self.dir_first:=false;
self.sprite0_hit:=false;
self.sprite_over_flow:=false;
self.sprite_size:=8;
self.pos_bg:=0;
self.pos_spt:=1;
self.sprite0_hit_pos:=0;
self.disable_chr:=false;
self.buffer_read:=random(256);
self.tile_x_offset:=0;
fillchar(self.dot_line_trans[0],sizeof(self.dot_line_trans),0);
end;

function nesppu_chip.read:byte;
var
  ret:byte;
begin
//Proteccion del mapper 185!!!
if self.disable_chr then ret:=self.address and $ff
  else ret:=self.buffer_read;
self.buffer_read:=self.read_mem(self.address);
if ((self.linea>=240) or ((self.control2 and $18)=0)) then begin
  if (self.control1 and $4)<>0 then self.address:=(self.address+32) and $7fff
    else self.address:=(self.address+1) and $7fff;
end else begin
  //X fina
  if (self.address and $1f)=$1f then self.address:=self.address xor $41f
    else self.address:=self.address+1;
  //Y fina
  self.end_y_coarse;
end;
read:=ret;
end;

procedure nesppu_chip.write(valor:byte);
begin
case (self.address and $3fff) of
  $0..$1fff:if (not(self.disable_chr) and self.write_chr) then self.chr[nes_mapper_0.chr_map[(self.address shr 12) and 1],self.address and $fff]:=valor;
  $2000..$3eff:self.name_table[MIRROR_TYPES[self.mirror,(self.address shr 10) and 3],self.address and $3ff]:=valor;
  $3f00..$3fff:case (self.address and $1f) of //Palete
                    0,$10:begin
                        self.pal_ram[0]:=valor;self.pal_ram[$04]:=valor;
                        self.pal_ram[$8]:=valor;self.pal_ram[$0c]:=valor;
                        self.pal_ram[$10]:=valor;self.pal_ram[$14]:=valor;
                        self.pal_ram[$18]:=valor;self.pal_ram[$1c]:=valor;
                    end;
                    else self.pal_ram[self.address and $1f]:=valor;
                  end;
end;
if ((self.linea>=240) or ((self.control2 and $18)=0)) then begin
  if (self.control1 and $4)<>0 then self.address:=(self.address+32) and $7fff
    else self.address:=(self.address+1) and $7fff;
end else begin
  //X fina
  if (self.address and $1f)=$1f then self.address:=self.address xor $41f
    else self.address:=self.address+1;
  //Y fina
  self.end_y_coarse;
end;
end;

function nesppu_chip.read_mem(address:word):byte;
begin
case (address and $3fff) of
  $0..$1fff:if not(self.disable_chr) then read_mem:=self.chr[nes_mapper_0.chr_map[(address shr 12) and 1],address and $fff]
            else read_mem:=address and $ff;
  $2000..$3eff:read_mem:=self.name_table[MIRROR_TYPES[self.mirror,(address shr 10) and 3],address and $3ff];
  $3f00..$3fff:read_mem:=self.pal_ram[address and $1f]; //Palete
end;
end;

function nesppu_chip.set_emphasis(pal_tmp:word):word;
begin
if ((self.control2 and $80)<>0) then begin //azul
   pal_tmp:=(pal_tmp and $ce7f);
end;
if ((self.control2 and $40)<>0) then begin //verde
   pal_tmp:=(pal_tmp and $cff9);
end;
if ((self.control2 and $20)<>0) then begin //rojo
   pal_tmp:=(pal_tmp and $fe79);
end;
set_emphasis:=pal_tmp;
end;

procedure nesppu_chip.end_y_coarse;
var
  tmp:word;
begin
if (self.control2 and $18)<>0 then begin
  self.address:=self.address+$1000;
  if (@nes_mapper_0.calls.line_ack<>nil) then nes_mapper_0.calls.line_ack(false);
  if (self.address and $8000)<>0 then begin
    tmp:=(self.address and $03e0)+$20;
    self.address:=self.address and $7c1f;
    // handle bizarro scrolling rollover at the 30th (not 32nd) vertical tile
    if (tmp=$03c0) then self.address:=self.address xor $0800
      else self.address:=self.address or (tmp and $03e0);
  end;
  self.address:=(self.address and $7be0) or (self.address_temp and $41f);
end;
end;

procedure nesppu_chip.draw_linea(nes_linea:word);
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
 pos_y:=self.sprite_ram[f*4];
 if (((self.sprite_ram[(f*4)+2] and $20)<>pri) or (pos_y>239)) then continue;
 pos_x:=self.sprite_ram[(f*4)+3];
 pos_linea:=nes_linea-pos_y;
if (pos_linea<self.sprite_size) then begin
   nsprites:=nsprites+1;
   if nsprites=9 then exit;
   atrib:=(self.sprite_ram[(f*4)+2] and $3) shl 2;
   flipx:=(self.sprite_ram[(f*4)+2] and $40)=$40;
   flipy:=(self.sprite_ram[(f*4)+2] and $80)=$80;
   num_char:=self.sprite_ram[(f*4)+1];
   if self.sprite_size=8 then begin //8x8
      temp:=self.pos_spt;
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
   tempb1:=self.read_mem((temp*$1000)+(num_char*16)+def_y);
   if @nes_mapper_0.calls.ppu_read<>nil then nes_mapper_0.calls.ppu_read((temp*$1000)+(num_char*16)+def_y);
   tempb2:=self.read_mem((temp*$1000)+(num_char*16)+8+def_y);
   if @nes_mapper_0.calls.ppu_read<>nil then nes_mapper_0.calls.ppu_read((temp*$1000)+(num_char*16)+8+def_y);
   if flipx then begin
        for x:=0 to 7 do begin
          punto:=(((tempb1 and (1 shl x)) shr x) and 1)+((((tempb2 and (1 shl x)) shr x) and 1) shl 1);
          if punto=0 then ptemp^:=paleta[MAX_COLORES]
            else begin
              //Sprite 0 Hit
              if (((pos_x+x)<>255) and (f=0) and ((self.dot_line_trans[pos_x+x] and $3f)<>0)) then begin
                ppu_nes_0.status:=ppu_nes_0.status or $40;
              end;
              if (((self.control2 and $4)=0) and ((pos_x+x)<8)) then begin
                ptemp^:=paleta[MAX_COLORES];
              end else begin
                 if ((self.dot_line_trans[pos_x+x] and $3f)>=f) then begin
                    ptemp^:=paleta[self.read_mem($3f10+punto+atrib) and ppu_nes_0.pal_mask];
                    self.dot_line_trans[pos_x+x]:=(self.dot_line_trans[pos_x+x] and $80) or f;
                 end else
                    ptemp^:=paleta[MAX_COLORES];
                 end;
            end;
          inc(ptemp);
        end;
        putpixel(0,0,8,punbuf,PANT_SPRITES);
   end else begin
        for x:=7 downto 0 do begin
          punto:=(((tempb1 and (1 shl x)) shr x) and 1)+((((tempb2 and (1 shl x)) shr x) and 1) shl 1);
          if punto=0 then ptemp^:=paleta[MAX_COLORES]
            else begin
              //Sprite 0 Hit
              if (((pos_x+(7-x))<>255) and (f=0) and ((self.dot_line_trans[pos_x+(7-x)] and $3f)<>0)) then begin
                 ppu_nes_0.status:=ppu_nes_0.status or $40;
                 //self.sprite0_hit:=true;
                 //self.sprite0_hit_pos:=nsprites*8*PPU_PIXEL_TIMING;;
              end;
              if (((self.control2 and $4)=0) and ((pos_x+(7-x))<8)) then begin
                ptemp^:=paleta[MAX_COLORES];
              end else begin
                if ((self.dot_line_trans[pos_x+(7-x)] and $3f)>=f) then begin //Prioridad sprite/sprite
                  ptemp^:=paleta[self.read_mem($3f10+punto+atrib) and ppu_nes_0.pal_mask];
                  self.dot_line_trans[pos_x+(7-x)]:=(self.dot_line_trans[pos_x+(7-x)] and $80) or f;
                end else ptemp^:=paleta[MAX_COLORES];
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
procedure putbackground;
var
    AttribTable,PatternAdr,AttribVal,tiles,Col,x,TileYOffset:integer;
    ptemp:pword;
    pos_x:word;
begin
    AttribTable:=$2000+(self.address and $c00)+$3c0+((((self.address and $3e0) div $20) and $fffc)*$2)+((self.address and $1f) div $4);
    ptemp:=punbuf;
    pos_x:=0;
    TileYOffset:=(self.address and $7000) shr 12;
    if ((self.address and $40)=0) then begin
      if ((self.address and $2)=0) then AttribVal:=(self.read_mem(AttribTable) and $3) shl 2
        else AttribVal:=self.read_mem(AttribTable) and $c;
    end else begin
      if ((self.address and $2)=0) then AttribVal:=(self.read_mem(AttribTable) and $30) shr 2
        else AttribVal:=(self.read_mem(AttribTable) and $c0) shr 4;
    end;
    for tiles:=32 downto 0 do begin
        PatternAdr:=(self.pos_bg*$1000)+(self.read_mem($2000+(self.address and $fff))*$10)+TileYOffset;
        if @nes_mapper_0.calls.ppu_read<>nil then nes_mapper_0.calls.ppu_read(PatternAdr);
        // Draw tile line
        for x:=7 downto 0 do begin
            col:=((self.read_mem(PatternAdr) and (1 shl x)) shr x)+((self.read_mem(PatternAdr+8) and (1 shl x)) shr x)*2;
            if col=0 then begin
              ptemp^:=paleta[MAX_COLORES];
              self.dot_line_trans[pos_x]:=self.dot_line_trans[pos_x] and $7f;
            end else begin
              ptemp^:=set_emphasis(paleta[self.read_mem($3f00+col+AttribVal) and ppu_nes_0.pal_mask]);
              self.dot_line_trans[pos_x]:=self.dot_line_trans[pos_x] or $80;
            end;
            inc(ptemp);
            pos_x:=pos_x+1;
        end;
        //los bits 0,1,2,3,4 son la X
        if (self.address and $1f)=$1f then begin
            //Cuando llega a 31 --> bit 10 cambia
            AttribTable:=(AttribTable xor $400)-$8;
            self.address:=self.address xor $41f;
        end else begin
          self.address:=self.address+1;
        end;
        if (self.address and $3)=0 then AttribTable:=AttribTable+1;
        if (self.address and $1)=0 Then begin
            if ((self.address and $40)=0) then begin
                if ((self.address and $2)=0) then AttribVal:=(self.read_mem(AttribTable) and $3) shl 2
                  else AttribVal:=self.read_mem(AttribTable) and $c;
            end else begin
                if ((self.address and $2)=0) then AttribVal:=(self.read_mem(AttribTable) and $30) shr 2
                   else AttribVal:=(self.read_mem(AttribTable) and $c0) shr 4;
            end;
        end;
    end;
    // Clip left tiles, bit 1 of PPU2 = 0
    if (self.control2 and 2)=0 then begin
        ptemp:=punbuf;
        inc(ptemp,self.tile_x_offset);
        for x:=0 to 7 do begin
          //Addams Family confia en esto!!!
          self.dot_line_trans[x]:=self.dot_line_trans[x] and $7f;
          ptemp^:=set_emphasis(paleta[self.read_mem($3f00) and ppu_nes_0.pal_mask]);
          inc(ptemp);
        end;
    end;
    putpixel(0,0,256+self.tile_x_offset,punbuf,1);
end;
procedure sprite_line_overflow(nes_linea:word);
var
   f,pos_y,pos_linea:byte;
   nsprites:byte;
begin
nsprites:=0;
for f:=0 to 63 do begin
    pos_y:=self.sprite_ram[f*4];
    if ((pos_y=255) or (pos_y>239)) then continue;
    pos_linea:=nes_linea-pos_y;
    if (pos_linea<self.sprite_size) then begin
       nsprites:=nsprites+1;
       if nsprites=9 then begin
          //self.sprite_over_flow:=true;
          ppu_nes_0.status:=ppu_nes_0.status or $20;
          exit;
       end;
    end;
end;
end;

var
  fondo_pal:word;
begin
fondo_pal:=set_emphasis(paleta[self.read_mem($3f00) and ppu_nes_0.pal_mask]);
single_line(0,nes_linea,fondo_pal,256,2);
fillchar(self.dot_line_trans[0],sizeof(self.dot_line_trans),$3f);
//Si los sprites o el fondo estan activos, hay sprite overflow
//Evalua los sprites DE LA LINEA SIGUIENTE!! Los sprites de la linea 0 se carga
//en la 261 PERO NO SE EVALUA NADA
if (self.control2 and $18)<>0 then sprite_line_overflow(nes_linea+1);
if (self.control2 and $10)<>0 then putsprites(nes_linea,$20);
if (self.control2 and $8)<>0 then begin
  putbackground;
  actualiza_trozo(self.tile_x_offset,0,256,1,1,0,nes_linea,256,1,2);
end;
if (self.control2 and $10)<>0 then putsprites(nes_linea,$0);
//Si los sprites o el fondo estan desactivados, no hay sprite 0 hit
if (self.control2 and $18)<>$18 then ppu_nes_0.status:=ppu_nes_0.status and $bf;//self.sprite0_hit:=false;
end;

procedure nesppu_chip.dma_spr(direccion:byte);
begin
if self.sprite_ram_pos<>0 then begin
  copymemory(@self.sprite_ram[self.sprite_ram_pos],@memoria[$100*direccion],$100-self.sprite_ram_pos);
  copymemory(@self.sprite_ram[0],@memoria[$100*direccion],self.sprite_ram_pos);
end else begin
  copymemory(@self.sprite_ram[0],@memoria[$100*direccion],$100);
end;
n2a03_0.m6502.contador:=n2a03_0.m6502.contador+513+(n2a03_0.m6502.contador and 1);
end;

end.
