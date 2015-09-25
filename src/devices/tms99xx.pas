unit tms99xx;

interface

uses gfx_engine,{$IFDEF WINDOWS}windows,{$endif}
     main_engine,pal_engine;

  type
    ttms99xx=packed record
      regs:array[0..7] of byte;
      color,pattern,nametbl,spriteattribute,spritepattern,colormask,patternmask,addr:word;
      modo_video,status_reg,buffer,fgcolor,bgcolor,FifthSprite:byte;
      int,segundo_byte,espera_read:boolean;
      TMS9918A_VRAM_SIZE:word;
      memory:array[0..$3FFF] of byte;
      IRQ_Handler:procedure(int:boolean);
      pant:byte;
    end;

procedure TMS99XX_Init(pant:byte);
procedure TMS99XX_refresh(linea:word);
procedure TMS99XX_reset;
function TMS99XX_vram_r:byte;
function TMS99XX_register_r:integer;
procedure TMS99XX_register_w(valor:byte);
procedure TMS99XX_vram_w(valor:byte);
procedure TMS99XX_close;

var
  tms:^ttms99xx;

implementation
const
    PIXELS_VISIBLES_TOTAL=284;
    PIXELS_RIGHT_BORDER_VISIBLES=15;
    PIXELS_RIGHT_BORDER_VISIBLES_TEXT=25;
    PIXELS_LEFT_BORDER_VISIBLES=13;
    PIXELS_LEFT_BORDER_VISIBLES_TEXT=19;
    LINEAS_TOP_BORDE=27;

procedure tms99xx_reset;
begin
  fillchar(tms.regs[0],7,0);
  tms.segundo_byte:=false;
  tms.espera_read:=false;
  tms.FifthSprite:=$1f;
  tms.addr:=0;
  tms.buffer:=0;
  tms.status_reg:=0;
  tms.fgcolor:=0;
  tms.bgcolor:=0;
  tms.color:=0;
  tms.pattern:=0;
  tms.nametbl:=0;
  tms.spriteattribute:=0;
  tms.spritepattern:=0;
  tms.colormask:=$3fff;
  tms.patternmask:=$3fff;
  tms.int:=false;
  tms.TMS9918A_VRAM_SIZE:=$3FFF;
  fillchar(tms.memory[0],$4000,0);
  paleta[0]:=0;
end;

procedure TMS99XX_Init(pant:byte);
const
    tms992X_palete:array[0..15, 0..2] of byte =(
     (0,0,0),(0,0,0),(33, 200, 66),(94, 220, 120),
	  (84, 85, 237),(125, 118, 252),(212, 82, 77),(66, 235, 245),
    (252, 85, 84),(255, 121, 120),(212, 193, 84),(230, 206, 128),
	  (33, 176, 59),(201, 91, 186),(204, 204, 204),(255,255,255));
var
  f:byte;
  colores:tpaleta;
begin
//poner la paleta
for f:=0 to 15 do begin
  colores[f].r:=tms992X_palete[f,0];
  colores[f].g:=tms992X_palete[f,1];
  colores[f].b:=tms992X_palete[f,2];
end;
set_pal(colores,16);
getmem(tms,sizeof(TTMS99XX));
tms.pant:=pant;
TMS99XX_reset;
end;

procedure TMS99XX_Interrupt;
var
  b:boolean;
begin
b:=((tms.regs[1] and $20)<>0) and ((tms.status_reg and $80)<>0);
if b<>tms.int then begin
    tms.int:=b;
    if @tms.IRQ_Handler<>nil then tms.IRQ_Handler(tms.INT);
end;
end;

procedure draw_sprites(linea:byte);
var
  sprite_size,sprite_mag,sprite_height,num_sprites,sprattr:byte;
  sprcode,sprcol,pattern,s,i,z:byte;
  spr_x,spr_y,pataddr:word;
  spr_drawn:array[0..(32+256+32)-1] of byte;
  fifth_encountered:boolean;
  colission_index:integer;
begin
  if (tms.regs[1] and 2)<>0 then sprite_size:=16
    else sprite_size:=8;
  sprite_mag:=tms.regs[1] and 1;
  sprite_height:=sprite_size*(sprite_mag+1);
  fillchar(spr_drawn[0],32+256+32,0);
  num_sprites:=0;
  fifth_encountered:=false;
  for sprattr:=0 to 31 do begin
      spr_y:=tms.memory[tms.spriteattribute+(sprattr*4)];
      tms.FifthSprite:=sprattr;
      // Stop processing sprites */
      if (spr_y=208) then break;
      if (spr_y>$e0) then spr_y:=spr_y-256;
      // vert pos 255 is displayed on the first line of the screen */
      spr_y:=spr_y+1;
      // is sprite enabled on this line? */
      if ((spr_y<=linea) and (linea<(spr_y+sprite_height))) then begin
         spr_x:= tms.memory[tms.spriteattribute+(sprattr*4)+1];
	 sprcode:=tms.memory[tms.spriteattribute+(sprattr*4)+2];
	 sprcol:=tms.memory[tms.spriteattribute+(sprattr*4)+3];
          if (sprite_size=16) then pataddr:=tms.spritepattern+(sprcode and $fc)*8
            else pataddr:=tms.spritepattern+sprcode*8;
	  num_sprites:=num_sprites+1;
	  // Fifth sprite encountered? */
	  if (num_sprites=5) then begin
	     fifth_encountered:=true;
	     break;
          end;
	  if (sprite_mag<>0) then pataddr:=pataddr+(((linea-spr_y) and $1F) shr 1)
	     else pataddr:=pataddr+((linea-spr_y) and $0F );
	  pattern:=tms.memory[pataddr];
	  if (sprcol and $80)<>0 then spr_x:=spr_x-32;
	  sprcol:=sprcol and $0f;
	  for s:=0 to ((sprite_size-1) div 8) do begin
	      for i:=0 to 7 do begin
          if sprite_mag<>0 then colission_index:=spr_x+(i*2)+32
            else colission_index:=spr_x+i+32;
          for z:=0 to sprite_mag do begin
            // Check if pixel should be drawn */
		        if (pattern and $80)<>0 then begin
		          if ((colission_index>=32) and (colission_index<32+256)) then begin
		            // Check for colission */
 		            if (spr_drawn[colission_index]<>0) then tms.status_reg:=tms.status_reg or $20;
		            spr_drawn[colission_index]:=spr_drawn[colission_index] or $01;
 		            if (sprcol<>0) then begin
                  // Has another sprite already drawn here? */
			            if ((spr_drawn[colission_index] and $02)=0) then begin
			              spr_drawn[colission_index]:=spr_drawn[colission_index] or $02;
                    punbuf^:=paleta[sprcol];
                    putpixel(colission_index-32+PIXELS_LEFT_BORDER_VISIBLES,linea+LINEAS_TOP_BORDE,1,punbuf,tms.pant);
                  end;
                end; //del if sprcol
              end; //del colision
            end; //del if pattern $80
            colission_index:=colission_index+1;
          end; //del for z
          pattern:=pattern shl 1;
        end; //del for de la i
	      pattern:=tms.memory[pataddr+16];
        if sprite_mag<>0 then spr_x:=spr_x+16
          else spr_x:=spr_x+8;
    end; //del for de la s
   end; //del if dentro
  end; //del for
	// Update sprite overflow bits */
  if (tms.status_reg and $40)=0 then begin
    tms.status_reg:=(tms.status_reg and $e0) or tms.FifthSprite;
				if (fifth_encountered and ((tms.status_reg  and $80)=0)) then tms.status_reg:=tms.status_reg or $40;
  end;

end;

procedure draw_mode0(linea:byte);
var
  x,fc,bc,k:byte;
  ptemp:pword;
  patternptr,charcode,name_base:dword;
begin //256x192 --> Caracteres de 8x8
 ptemp:=punbuf;
 fillword(ptemp,PIXELS_LEFT_BORDER_VISIBLES,paleta[tms.bgcolor]);
 inc(ptemp,PIXELS_LEFT_BORDER_VISIBLES);
 name_base:=tms.NameTbl+((linea div 8)*32);
 for x:=0 to 31 do begin
     charcode:=tms.memory[name_base];
     name_base:=name_base+1;
     patternptr:=tms.pattern+(charcode shl 3)+(linea and 7);
     bc:=tms.memory[tms.color+(charcode shr 3)];
     fc:=bc shr 4;
     bc:=bc and $f;
     K:=tms.memory[patternptr];
     if (k and $80)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
     if (k and $40)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
     if (k and $20)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
     if (k and $10)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
     if (k and $08)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
     if (k and $04)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
     if (k and $02)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
     if (k and $01)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
 end;
 fillword(ptemp,PIXELS_RIGHT_BORDER_VISIBLES,paleta[tms.bgcolor]);
end;

procedure draw_mode1(linea:byte);
var
  name_base,s:word;
  ptemp:pword;
  x,fc,bc,k:byte;
begin //240x192 --> Caracteres de 6x8
 ptemp:=punbuf;
 fillword(ptemp,PIXELS_LEFT_BORDER_VISIBLES_TEXT,paleta[tms.bgcolor]);
 inc(ptemp,PIXELS_LEFT_BORDER_VISIBLES_TEXT);
 fc:=tms.fgcolor;
 bc:=tms.bgcolor;
 name_base:=tms.Nametbl+((linea div 8)*40);
 for x:=0 to 39 do begin
     s:=tms.pattern+(tms.memory[name_base] shl 3)+(linea and 7);
     name_base:=name_base+1;
     k:=tms.memory[s];
     if (k and $80)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
     if (k and $40)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
     if (k and $20)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
     if (k and $10)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
     if (k and 8)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
     if (k and 4)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
 end;
 fillword(ptemp,PIXELS_RIGHT_BORDER_VISIBLES_TEXT,paleta[tms.bgcolor]);
end;

procedure draw_mode12(linea:byte);
var
  charcode,patternptr,name_base:word;
  ptemp:pword;
  x,fc,bc,pattern:byte;
begin //240x192 --> Caracteres de 6x8
 ptemp:=punbuf;
 fillword(ptemp,PIXELS_LEFT_BORDER_VISIBLES_TEXT,paleta[tms.bgcolor]);
 inc(ptemp,PIXELS_LEFT_BORDER_VISIBLES_TEXT);
 fc:=tms.fgcolor;
 bc:=tms.bgcolor;
 name_base:=tms.Nametbl+((linea div 8)*40);
 for x:=0 to 39 do begin
     charcode:=(tms.memory[name_base]+(linea shr 6)*256) and tms.patternmask;
     name_base:=name_base+1;
     patternptr:=tms.pattern+(charcode shl 3)+(linea and 7);
     pattern:=tms.memory[patternptr];
     if (pattern and $80)<>0 then ptemp^:=paleta[FC] else ptemp^:=paleta[BC];inc(ptemp);
     if (pattern and $40)<>0 then ptemp^:=paleta[FC] else ptemp^:=paleta[BC];inc(ptemp);
     if (pattern and $20)<>0 then ptemp^:=paleta[FC] else ptemp^:=paleta[BC];inc(ptemp);
     if (pattern and $10)<>0 then ptemp^:=paleta[FC] else ptemp^:=paleta[BC];inc(ptemp);
     if (pattern and 8)<>0 then ptemp^:=paleta[FC] else ptemp^:=paleta[BC];inc(ptemp);
     if (pattern and 4)<>0 then ptemp^:=paleta[FC] else ptemp^:=paleta[BC];inc(ptemp);
 end;
 fillword(ptemp,PIXELS_RIGHT_BORDER_VISIBLES_TEXT,paleta[tms.bgcolor]);
end;

procedure draw_mode2(linea:byte);
var
  x,fc,bc:byte;
  name_base,colour,pattern,patternptr,colourptr,charcode:word;
  ptemp:pword;
begin //256x192 --> Caracteres de 8x8
 ptemp:=punbuf;
 fillword(ptemp,PIXELS_LEFT_BORDER_VISIBLES,paleta[tms.bgcolor]);
 inc(ptemp,PIXELS_LEFT_BORDER_VISIBLES);
 name_base:=tms.NameTbl+((linea div 8)*32);
 for x:=0 to 31 do begin
     charcode:=tms.memory[name_base]+(linea shr 6)*256;
     name_base:=name_base+1;
     colour:=charcode and tms.colormask;
     pattern:=charcode and tms.patternmask;
     patternptr:=tms.pattern+(colour*8)+(linea and 7);
     colourptr:=tms.color+(pattern*8)+(linea and 7);
     pattern:=tms.memory[patternptr];
     bc:=tms.memory[colourptr];
     fc:=bc shr 4;
     bc:=bc and $F;
     if (pattern and $80)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
     if (pattern and $40)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
     if (pattern and $20)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
     if (pattern and $10)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
     if (pattern and 8)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
     if (pattern and 4)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
     if (pattern and 2)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
     if (pattern and 1)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
 end;
 fillword(ptemp,PIXELS_RIGHT_BORDER_VISIBLES,paleta[tms.bgcolor]);
end;

procedure draw_mode3(linea:byte);
var
    fc,bg,x,charcode:byte;
    colorptr,name_base:word;
    ptemp:pword;
begin //256x192 --> Caracteres de 4x4 en dos bloques
 ptemp:=punbuf;
 fillword(ptemp,PIXELS_LEFT_BORDER_VISIBLES,paleta[tms.bgcolor]);
 inc(ptemp,PIXELS_LEFT_BORDER_VISIBLES);
 name_base:=tms.nametbl+((linea div 8)*32);
 for x:=0 to 31 do begin
     charcode:=tms.memory[name_base];
     name_base:=name_base+1;
     colorptr:=tms.pattern+(charcode*8)+((linea shr 2) and 7);
     FC:=tms.memory[colorptr] shr 4;
     BG:=tms.memory[colorptr] and $f;
     ptemp^:=paleta[fc];inc(ptemp); //(x+0)
     ptemp^:=paleta[fc];inc(ptemp); //(x+1)
     ptemp^:=paleta[fc];inc(ptemp); //(x+2)
     ptemp^:=paleta[fc];inc(ptemp); //(x+3)
     ptemp^:=paleta[bg];inc(ptemp); //(x+4)
     ptemp^:=paleta[bg];inc(ptemp); //(x+5)
     ptemp^:=paleta[bg];inc(ptemp); //(x+6)
     ptemp^:=paleta[bg];inc(ptemp); //(x+7)
 end;
 fillword(ptemp,PIXELS_RIGHT_BORDER_VISIBLES,paleta[tms.bgcolor]);
end;

procedure draw_modebogus(linea:byte);
var
    fc,bc,x:byte;
    ptemp:pword;
begin //240x192 --> Caracteres de 6x8
 ptemp:=punbuf;
 fillword(ptemp,PIXELS_LEFT_BORDER_VISIBLES_TEXT,paleta[tms.bgcolor]);
 inc(ptemp,PIXELS_LEFT_BORDER_VISIBLES_TEXT);
 for x:=0 to 39 do begin
     FC:=tms.fgcolor;
     BC:=tms.bgcolor;
     ptemp^:=paleta[fc];inc(ptemp); //(x+0)
     ptemp^:=paleta[fc];inc(ptemp); //(x+1)
     ptemp^:=paleta[fc];inc(ptemp); //(x+2)
     ptemp^:=paleta[fc];inc(ptemp); //(x+3)
     ptemp^:=paleta[bc];inc(ptemp); //(x+4)
     ptemp^:=paleta[bc];inc(ptemp); //(x+5)
 end;
 fillword(ptemp,PIXELS_RIGHT_BORDER_VISIBLES_TEXT,paleta[tms.bgcolor]);
end;

procedure draw_mode23(linea:byte);
var
    fc,bg,x:byte;
    colorptr,charcode,name_base:word;
    ptemp:pword;
begin //256x192 --> Caracteres de 4x4 en dos bloques
 ptemp:=punbuf;
 fillword(ptemp,PIXELS_LEFT_BORDER_VISIBLES,paleta[tms.bgcolor]);
 inc(ptemp,PIXELS_LEFT_BORDER_VISIBLES);
 name_base:=tms.nametbl+((linea div 8)*32);
 for x:=0 to 31 do begin
     charcode:=tms.memory[name_base];
     name_base:=name_base+1;
     colorptr:=tms.pattern+(((charcode+((linea shr 2) and 7)+((linea shr 6) shl 8)) and tms.patternmask) shl 3);
     FC:=tms.memory[colorptr] shr 4;
     BG:=tms.memory[colorptr] and $f;
     ptemp^:=paleta[fc];inc(ptemp); //(x+0)
     ptemp^:=paleta[fc];inc(ptemp); //(x+1)
     ptemp^:=paleta[fc];inc(ptemp); //(x+2)
     ptemp^:=paleta[fc];inc(ptemp); //(x+3)
     ptemp^:=paleta[bg];inc(ptemp); //(x+4)
     ptemp^:=paleta[bg];inc(ptemp); //(x+5)
     ptemp^:=paleta[bg];inc(ptemp); //(x+6)
     ptemp^:=paleta[bg];inc(ptemp); //(x+7)
 end;
 fillword(ptemp,PIXELS_RIGHT_BORDER_VISIBLES,paleta[tms.bgcolor]);
end;

{Lineas de video fisicas NTSC
                            visible
Active display       192      *
Bottom border         24      *
Bottom blanking        3      -
Vertical sync          3      -
Top blanking          13      -
Top border            27      *
Total                262     243

Pixes fisicos dentro de la linea
                        Visible
Active display 240 256    *
Right border    25 15     *
Right blanking   8 8      -
Horiz sync      26 26     -
Left blanking    2 2      -
Color burst     14 14     -
Left blanking    8 8      -
Left border     19 13     *
Total          342 342   284}
procedure TMS99XX_refresh(linea:word);
begin
  //ESPERO UNA LINEA FISICA
  //Pantalla apagada, solo pinto el color de fondo
  if (tms.regs[1] and $40)=0 then begin
    single_line(0,linea,tms.bgcolor,PIXELS_VISIBLES_TOTAL,tms.pant);
    if linea=192 then begin
                tms.status_reg:=tms.status_reg or $80;
                TMS99XX_Interrupt;
    end;
    exit;
  end;
  case linea of
     0..191:begin //Pantalla visible (192)
               case tms.modo_video of
                    0:draw_mode0(linea);
                    1:draw_mode1(linea);
                    2:draw_mode2(linea);
                    3:draw_mode12(linea);
                    4:draw_mode3(linea);
                    6:draw_mode23(linea);
                    5,7:draw_modebogus(linea);
               end;
               putpixel(0,linea+LINEAS_TOP_BORDE,PIXELS_VISIBLES_TOTAL,punbuf,tms.pant);
               if ((tms.regs[1] and $50)=$40) then draw_sprites(linea)
                else tms.FifthSprite:=$1f;
            end;
     193:begin //Borde inferior (1) y activar las IRQs
              single_line(0,linea+LINEAS_TOP_BORDE,tms.bgcolor,PIXELS_VISIBLES_TOTAL,tms.pant);
              tms.status_reg:=tms.status_reg or $80;
              TMS99XX_Interrupt;
         end;
     //Borde inferior (23)
     192,194..215:single_line(0,linea+LINEAS_TOP_BORDE,tms.bgcolor,PIXELS_VISIBLES_TOTAL,tms.pant);
     //Lineas no dibujadas sincronismos (3+3+13)
     216..234:;
     //Borde superior (27)
     235..261:single_line(0,linea-235,tms.bgcolor,PIXELS_VISIBLES_TOTAL,tms.pant);
  end;
end;

procedure update_table_masks;
begin
	tms.colormask:=((tms.regs[3] and $7f) shl 3) or 7;
	//on 91xx family, the colour table mask doesn't affect the pattern table mask
	tms.patternmask:=((tms.regs[4] and 3) shl 8) or $ff;
end;

//change register
procedure change_reg(addr,Val:byte);
const
  Mask:array[0..7] of byte=($03,$fb,$0f,$ff,$07,$7f,$07,$ff);
begin
  val:=val and mask[addr];
  tms.regs[addr]:=Val;
  case addr of
     0:begin
	        if (val and 2)<>0 then begin
			      tms.color:=((tms.Regs[3] and $80)*64) and tms.TMS9918A_VRAM_SIZE;
			      tms.pattern:=((tms.Regs[4] and 4)*2048) and tms.TMS9918A_VRAM_SIZE;
            update_table_masks;
		      end else begin
			      tms.color:=(tms.Regs[3]*64) and tms.TMS9918A_VRAM_SIZE;
			      tms.pattern:=(tms.Regs[4]*2048) and tms.TMS9918A_VRAM_SIZE;
          end;
          tms.modo_video:=(tms.Regs[0] and 2) or ((tms.Regs[1] and $10) shr 4) or ((tms.Regs[1] and 8) shr 1);
       end;
     1:begin
        TMS99XX_Interrupt;
        tms.modo_video:=(tms.Regs[0] and 2) or ((tms.Regs[1] and $10) shr 4) or ((tms.Regs[1] and 8) shr 1);
       end;
     2:tms.NameTbl:=(val*1024) and tms.TMS9918A_VRAM_SIZE;
     3:begin
        if (tms.Regs[0] and 2)<>0 then begin
            tms.color:=((val and $80)*64) and tms.TMS9918A_VRAM_SIZE;
            update_table_masks;
        end else begin
            tms.color:=(val*64) and tms.TMS9918A_VRAM_SIZE;
        end;
		    tms.patternmask:=(tms.Regs[4] and 3)*256 or (tms.colormask and 255);
       end;
     4:if (tms.Regs[0] and 2)<>0 then begin
            tms.pattern:=((val and 4)*2048) and tms.TMS9918A_VRAM_SIZE;
            update_table_masks;
        end else begin
            tms.pattern:=(val*2048) and tms.TMS9918A_VRAM_SIZE;
        end;
     5:tms.spriteattribute:=(val*128) and tms.TMS9918A_VRAM_SIZE;
     6:tms.spritepattern:=(val*2048) and tms.TMS9918A_VRAM_SIZE;
     7: begin
       tms.fgcolor:=Val shr 4;
       if tms.bgcolor<>(Val and $0F) then begin
          tms.bgcolor:=(Val and $0F);
          if tms.bgcolor=0 then paleta[0]:=0
            else paleta[0]:=paleta[tms.bgcolor];
          //El color de fondo es transparente. La pantalla se pinta
          //de la siguiente forma: primero todo el fondo (incluido el borde),
          //despues los chars, y por ultimo los sprites.
          //Si hay char con el color 0, es transparente. Yo pongo el color 0
          //igual que el fondo y emulo el color transparente!
       end;
     end;
  end;
end;


function TMS99XX_register_r:integer; //GetStatus
begin
  TMS99XX_register_r:=tms.status_reg;
  tms.status_reg:=tms.FifthSprite;
  tms.segundo_byte:=false;
  TMS99XX_Interrupt;
end;

//http://bifi.msxnet.org/msxnet/tech/tms9918a.txt
//http://bifi.msxnet.org/msxnet/tech/tmsposting.txt

procedure TMS99XX_register_w(valor:byte);
begin
{Definicion de los dos bytes escritos
Byte #0		V7	V6	V5	V4	V3	V2	V1	V0
Byte #1		1(CR)	?	?	?	?	R2	R1	R0
CR --> Si es 1 cambiar registro
	VX --> Valor (1 byte)
	RX --> Registro
CR --> 0 cambiar direccion L/E (ver mas abajo la descripcion)
}
if not(tms.segundo_byte) then begin
  tms.addr:=((tms.addr and $ff00) or valor) and tms.TMS9918A_VRAM_SIZE;
  tms.segundo_byte:=true;
end else begin
  tms.segundo_byte:=false;
  tms.addr:=((tms.addr and $ff) or (valor shl 8)) and tms.TMS9918A_VRAM_SIZE;
  case (valor and $C0) of
    $80:change_reg(valor and $7,tms.addr and $ff);
    $00:begin
          tms.buffer:=tms.memory[tms.addr];
          tms.addr:=(tms.addr+1) and tms.TMS9918A_VRAM_SIZE;
          tms.segundo_byte:=false;
          tms.espera_read:=true;
        end;
    $40:tms.espera_read:=false;
  end;
end;
end;

{Definicion del word de la direccion
Byte #0		A7	A6	A5	A4	A3	A2	A1	A0
Byte #1		0	R/W	A13	A12	A11	A10	A9	A8
AX --> Direccion
R/W --> 0 para leer y 1 para escribir}

function TMS99XX_vram_r:byte;  //ReadDataPort
begin
  //Si el bit R/W esta a 1 (escritura) que hago???
  TMS99XX_vram_r:=tms.buffer;
  tms.buffer:=tms.memory[tms.addr];
  tms.addr:=(tms.addr+1) and tms.TMS9918A_VRAM_SIZE;
  tms.segundo_byte:=false;
end;

procedure TMS99XX_vram_w(valor:byte);
begin
if not(tms.espera_read) then begin
   tms.memory[tms.addr]:=valor;
   tms.buffer:=valor;
   tms.addr:=(tms.addr+1) and tms.TMS9918A_VRAM_SIZE;
   tms.segundo_byte:=false;
end else begin
   tms.buffer:=tms.memory[tms.addr];
   tms.addr:=(tms.addr+1) and tms.TMS9918A_VRAM_SIZE;
   tms.memory[tms.addr]:=valor;
end;
end;

procedure TMS99XX_close;
begin
if tms<>nil then begin
  freemem(tms);
  tms:=nil;
end;
end;

end.
