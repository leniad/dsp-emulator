unit nes_ppu;

interface

uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6502,gfx_engine,main_engine,pal_engine,math;

procedure ppu_dma_spr(direccion:byte);
procedure reset_ppu;
procedure ppu_linea(nes_linea:word);
function ppu_read:byte;
procedure ppu_write(valor:byte);
procedure nes_init_palette;
procedure ppu_end_linea;

const
  MIRROR_HORIZONTAL=1;
  MIRROR_VERTICAL=2;
  MIRROR_SINGLE=3;
  MIRROR_SINGLE_1=4;
  MIRROR_FOUR_SCREEN=5;
  PPU_PIXEL_TIMING=((128*2)/3)/256;

var
  ppu_control1,ppu_control2,ppu_status,sprite_ram_pos:byte;
  sprite_ram:array[0..$ff] of byte;
  pos_bg,pos_spt,sprite0_hit_pos:byte;
  ppu_dir_first,ppu_chr_rom,sprite0_hit:boolean;
  ppu_mem:array [0..$3FFF] of byte;
  ppu_mem_single:array [0..1,0..$fff] of byte;
  ppu_address_temp,ppu_address:word;
  ppu_mirror,ppu_buffer_read,ppu_tile_x_offset:byte;
  ppu_dot_line_trans:array[0..((33*8)-1)] of byte;  //0-63 sprites + $40 trans bg + $80 dot bg

implementation

uses nes;

procedure putsprites(nes_linea:word;pri:byte);
var
  f,x,size,pos_x,pos_y,punto,tempb1,tempb2:byte;
  num_char,atrib,temp,def_y,num_sprites:byte;
  flipx,flipy:boolean;
  pos_linea:word;
  ptemp:pword;
begin
num_sprites:=0;
for f:=63 downto 0 do begin
 pos_y:=sprite_ram[f*4];
 if (((sprite_ram[(f*4)+2] and $20)<>pri) or (pos_y>239)) then continue;
 size:=8 shl ((ppu_control1 and $20) shr 5);
 pos_linea:=nes_linea-(pos_y+1);
 if (pos_linea<size) then begin
   num_sprites:=num_sprites+1;
   if num_sprites=9 then begin
      ppu_status:=ppu_status or $20;
      exit;
   end;
   pos_x:=sprite_ram[(f*4)+3];
   atrib:=(sprite_ram[(f*4)+2] and $3) shl 2;
   flipx:=(sprite_ram[(f*4)+2] and $40)=$40;
   flipy:=(sprite_ram[(f*4)+2] and $80)=$80;
   num_char:=sprite_ram[(f*4)+1];
   if size=8 then begin //8x8
      temp:=pos_spt;
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
   tempb1:=ppu_mem[(temp*$1000)+(num_char*16)+def_y];
   tempb2:=ppu_mem[(temp*$1000)+(num_char*16)+8+def_y];
   if flipx then begin
        for x:=0 to 7 do begin
          punto:=(((tempb1 and (1 shl x)) shr x) and 1)+((((tempb2 and (1 shl x)) shr x) and 1) shl 1);
          if punto=0 then ptemp^:=paleta[max_colores]
            else begin
              if (((ppu_control2 and $4)=0) and ((pos_x+x)<8)) then begin
                ptemp^:=paleta[max_colores];
              end else begin
                 if ((ppu_dot_line_trans[pos_x+x] and $3f)>=f) then begin
                    ptemp^:=paleta[ppu_mem[$3f10+punto+atrib] and $3f];
                    ppu_dot_line_trans[pos_x+x]:=(ppu_dot_line_trans[pos_x+x] and $c0) or f;
                 end else
                    ptemp^:=paleta[max_colores];
                 end;
                 //Sprite 0 Hit
                 if ((f=0) and ((ppu_dot_line_trans[pos_x+x] and $80)<>0) and not(sprite0_hit)) then begin
                   sprite0_hit:=true;
                   sprite0_hit_pos:=round((pos_x+x)*PPU_PIXEL_TIMING);
                 end;
            end;
          inc(ptemp);
        end;
        putpixel(0,0,8,punbuf,pant_sprites);
   end else begin
        for x:=7 downto 0 do begin
          punto:=(((tempb1 and (1 shl x)) shr x) and 1)+((((tempb2 and (1 shl x)) shr x) and 1) shl 1);
          if punto=0 then ptemp^:=paleta[max_colores]
            else begin
              if (((ppu_control2 and $4)=0) and ((pos_x+(7-x))<8)) then begin
                ptemp^:=paleta[max_colores];
              end else begin
                if ((ppu_dot_line_trans[pos_x+(7-x)] and $3f)>=f) then begin //Prioridad sprite/sprite
                  ptemp^:=paleta[ppu_mem[$3f10+punto+atrib] and $3f];
                  ppu_dot_line_trans[pos_x+(7-x)]:=(ppu_dot_line_trans[pos_x+(7-x)] and $c0) or f;
                end else ptemp^:=paleta[max_colores];
              end;
              //Sprite 0 Hit
              if ((f=0) and ((ppu_dot_line_trans[pos_x+(7-x)] and $80)<>0) and not(sprite0_hit)) then begin
                 sprite0_hit:=true;
                 sprite0_hit_pos:=round((pos_x+(7-x))*PPU_PIXEL_TIMING);
              end;
            end;
          inc(ptemp);
        end;
        putpixel(0,0,8,punbuf,pant_sprites);
   end;
   if (pos_x+8)>255 then begin
    actualiza_trozo(0,0,255-pos_x,1,pant_sprites,pos_x,nes_linea,255-pos_x,1,2);
    if (ppu_control2 and $4)<>0 then actualiza_trozo(255-pos_x,0,8-(255-pos_x),1,pant_sprites,0,nes_linea,8-(255-pos_x),1,2);
   end else begin
    if (ppu_control2 and $4)<>0 then actualiza_trozo(0,0,8,1,pant_sprites,pos_x,nes_linea,8,1,2)
      else if ((pos_x+8)<8) then actualiza_trozo(0,0,8-pos_x,1,pant_sprites,pos_x,nes_linea,8-pos_x,1,2)
              else actualiza_trozo(0,0,8,1,pant_sprites,pos_x,nes_linea,8,1,2);
   end;
 end;
end;
end;

procedure putbackground(nes_line:byte);
var
    AttribTable,PatternAdr,AttribVal,Tiles,Col,x,TileYOffset:integer;
    ptemp:pword;
    pos_x:word;
begin
    AttribTable:=$2000+(ppu_address and $C00)+$3C0+((((ppu_address and $3E0) div $20) and $FFFC)*$2)+((ppu_address and $1F) div $4);
    ptemp:=punbuf;
    pos_x:=0;
    TileYOffset:=(ppu_address and $7000) shr 12;
    // Draw 32 tiles (31 + 1 de scroll)
    if ((ppu_address and $40)=0) then begin
      if ((ppu_address and $2)=0) then AttribVal:=(ppu_mem[AttribTable] and $3) shl 2
        else AttribVal:=ppu_mem[AttribTable] and $C;
    end else begin
      if ((ppu_address and $2)=0) then AttribVal:=(ppu_mem[AttribTable] and $30) shr 2
        else AttribVal:=(ppu_mem[AttribTable] and $C0) shr 4;
    end;
    for Tiles:=32 downto 0 do begin
        PatternAdr:=(pos_bg*$1000)+(ppu_mem[$2000+(ppu_address and $FFF)]*$10)+TileYOffset;
        // Draw tile line
        for x:=7 downto 0 do begin
            Col:=((ppu_mem[PatternAdr] and (1 shl x)) shr x)+((ppu_mem[PatternAdr+8] and (1 shl x)) shr x)*2;
            if Col=0 then begin
              ptemp^:=paleta[max_colores];
              ppu_dot_line_trans[pos_x]:=ppu_dot_line_trans[pos_x] and $7f;
            end else begin
              ptemp^:=paleta[ppu_mem[$3f00+Col+AttribVal] and $3f];
              ppu_dot_line_trans[pos_x]:=ppu_dot_line_trans[pos_x] or $80;
            end;
            inc(ptemp);
            pos_x:=pos_x+1;
        end;
        //los bits 0,1,2,3,4 son la X
        if (ppu_address and $1F)=$1F then begin
            //Cuando llega a 31 --> bit 10 cambia
            AttribTable:=(AttribTable xor $400)-$8;
            ppu_address:=ppu_address xor $41F;
        end else begin
          ppu_address:=ppu_address+1;
        end;
        if (ppu_address and $3)=0 then AttribTable:=AttribTable+1;
        if (ppu_address and $1)=0 Then begin
            if ((ppu_address and $40)=0) then begin
                if ((ppu_address and $2)=0) then AttribVal:=(ppu_mem[AttribTable] and $3) shl 2
                  else AttribVal:=ppu_mem[AttribTable] and $C;
            end else begin
                if ((ppu_address and $2)=0) then AttribVal:=(ppu_mem[AttribTable] and $30) shr 2
                   else AttribVal:=(ppu_mem[AttribTable] and $C0) shr 4;
            end;
        end;
    end;
    // Clip left tiles, bit 1 of PPU2 = 0
    if (ppu_control2 and $2)=0 then begin
        ptemp:=punbuf;
        inc(ptemp,ppu_tile_x_offset);
        for x:=0 to 7 do begin
          ptemp^:=paleta[ppu_mem[$3f00]];
          inc(ptemp);
        end;
    end;
    putpixel(0,0,256+ppu_tile_x_offset,punbuf,1);
end;

procedure ppu_end_linea;
var
  newfinescroll:word;
begin
//increment loopy_v to next row of tiles
newfinescroll:=(ppu_address and $7000)+$1000;
ppu_address:=ppu_address and not($7000);
//reset the fine scroll bits and increment tile address to next row
if (newfinescroll>$7000) then ppu_address:=ppu_address+32
  else ppu_address:=ppu_address+newfinescroll; //increment the fine scroll
if (((ppu_address shr 5) and $1f)=30) then begin
  //if incrementing loopy_v to the next row pushes us into the next
  //nametable, zero the "row" bits and go to next nametable
  ppu_address:=ppu_address and not($3e0);
  ppu_address:=ppu_address xor $800;
end;
end;

procedure ppu_linea(nes_linea:word);
begin
single_line(0,nes_linea,ppu_mem[$3f00],256,2);
fillchar(ppu_dot_line_trans[0],264,$7f);
if (ppu_control2 and $8)<>0 then begin
  putbackground(nes_linea);
  if (@llamadas_nes.line_counter<>nil) then llamadas_nes.line_counter;
end;
if (ppu_control2 and $10)<>0 then putsprites(nes_linea,$20);
if (ppu_control2 and $8)<>0 then actualiza_trozo(ppu_tile_x_offset,0,256,1,1,0,nes_linea,256,1,2);
if (ppu_control2 and $10)<>0 then putsprites(nes_linea,$0);
end;

function ppu_read:byte;
var
  ret:byte;
begin
ret:=ppu_buffer_read;
case ppu_address of
  $0..$1fff:if ppu_chr_rom then ppu_buffer_read:=ppu_mem[ppu_address]
              else ppu_buffer_read:=random(256);
  $2000..$3eff:case ppu_mirror of
                    MIRROR_HORIZONTAL:case (ppu_address and $c00) of
                                        $000,$400:ppu_buffer_read:=ppu_mem[$2000+(ppu_address and $3ff)];
                                        $800,$c00:ppu_buffer_read:=ppu_mem[$2800+(ppu_address and $3ff)];
                                      end;
                    MIRROR_VERTICAL:case (ppu_address and $c00) of
                                        $000,$800:ppu_buffer_read:=ppu_mem[$2000+(ppu_address and $3ff)];
                                        $400,$c00:ppu_buffer_read:=ppu_mem[$2400+(ppu_address and $3ff)];
                                      end;
                    MIRROR_SINGLE:begin
                                      ppu_buffer_read:=ppu_mem[$2000+(ppu_address and $3ff)];
                                      ppu_buffer_read:=ppu_mem[$2400+(ppu_address and $3ff)];
                                      ppu_buffer_read:=ppu_mem[$2800+(ppu_address and $3ff)];
                                      ppu_buffer_read:=ppu_mem[$2c00+(ppu_address and $3ff)];
                                  end;
                    MIRROR_FOUR_SCREEN:ppu_buffer_read:=ppu_mem[$2000+(ppu_address and $fff)];
                  end;
  $3f00..$3fff:begin
                  ppu_buffer_read:=ppu_mem[(ppu_address and $1F)+$3f00]; //Palete
                  ret:=ppu_buffer_read;
                end;
end;
if (ppu_control1 and $4)=$4 then ppu_address:=(ppu_address+32) and $3fff
  else ppu_address:=(ppu_address+1) and $3fff;
ppu_read:=ret;
end;

procedure ppu_write(valor:byte);
begin
case ppu_address of
  $0..$1fff:if not(ppu_chr_rom) then ppu_mem[ppu_address]:=valor;
  $2000..$3eff:case ppu_mirror of
                    MIRROR_HORIZONTAL:case (ppu_address and $c00) of
                                        $000,$400:begin
                                                    ppu_mem[$2000+(ppu_address and $3ff)]:=valor;
                                                    ppu_mem[$2400+(ppu_address and $3ff)]:=valor;
                                                  end;
                                        $800,$c00:begin
                                                    ppu_mem[$2800+(ppu_address and $3ff)]:=valor;
                                                    ppu_mem[$2c00+(ppu_address and $3ff)]:=valor;
                                                  end;
                                      end;
                    MIRROR_VERTICAL:case (ppu_address and $c00) of
                                        $000,$800:begin
                                                    ppu_mem[$2000+(ppu_address and $3ff)]:=valor;
                                                    ppu_mem[$2800+(ppu_address and $3ff)]:=valor;
                                                  end;
                                        $400,$c00:begin
                                                    ppu_mem[$2400+(ppu_address and $3ff)]:=valor;
                                                    ppu_mem[$2c00+(ppu_address and $3ff)]:=valor;
                                                  end;
                                      end;
                    MIRROR_SINGLE:begin
                                      ppu_mem[$2000+(ppu_address and $3ff)]:=valor;
                                      ppu_mem[$2400+(ppu_address and $3ff)]:=valor;
                                      ppu_mem[$2800+(ppu_address and $3ff)]:=valor;
                                      ppu_mem[$2c00+(ppu_address and $3ff)]:=valor;
                                  end;
                    MIRROR_FOUR_SCREEN:ppu_mem[$2000+(ppu_address and $fff)]:=valor;
               end;
  $3f00..$3fff:case (ppu_address and $1f) of //Palete
                    0,$10:begin
                        ppu_mem[$3f00]:=valor;ppu_mem[$3f04]:=valor;
                        ppu_mem[$3f08]:=valor;ppu_mem[$3f0c]:=valor;
                        ppu_mem[$3f10]:=valor;ppu_mem[$3f14]:=valor;
                        ppu_mem[$3f18]:=valor;ppu_mem[$3f1c]:=valor;
                    end;
                    else ppu_mem[(ppu_address and $1f)+$3f00]:=valor;
                  end;
end;
if (ppu_control1 and $4)=$4 then ppu_address:=(ppu_address+32) and $3fff
  else ppu_address:=(ppu_address+1) and $3fff;
end;

procedure ppu_dma_spr(direccion:byte);
begin
if sprite_ram_pos<>0 then begin
  copymemory(@sprite_ram[sprite_ram_pos],@memoria[$100*direccion],$100-sprite_ram_pos);
  copymemory(@sprite_ram[0],@memoria[$100*direccion],sprite_ram_pos);
end else begin
  copymemory(@sprite_ram[0],@memoria[$100*direccion],$100);
end;
main_m6502.estados_demas:=main_m6502.estados_demas+513+(main_m6502.contador and 1);
end;

procedure reset_ppu;
begin
ppu_control1:=0;
ppu_control2:=0;
ppu_status:=0;
sprite_ram_pos:=0;
ppu_address:=0;
if not(ppu_chr_rom) then fillchar(ppu_mem[$0],$2000,0);
ppu_dir_first:=false;
sprite0_hit:=false;
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
