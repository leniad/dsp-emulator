unit tms99xx;

interface

uses gfx_engine,{$IFDEF WINDOWS}windows,{$endif}
     main_engine,pal_engine;


  type
    irq_type=procedure(int:boolean);
    read_mem_type=function(direccion:word):byte;
    write_mem_type=procedure(direccion:word;valor:byte);
    tms99xx_chip=class
        constructor create(pant:byte;irq_call:irq_type;read_mem:read_mem_type=nil;write_mem:write_mem_type=nil);
        destructor free;
      public
        regs:array[0..$f] of byte;
        fgcolor,bgcolor,modo_video,status_reg,buffer:byte;
        addr,TMS9918A_VRAM_SIZE,color,pattern,nametbl,spriteattribute,spritepattern,colormask,patternmask:word;
        vdp_mode,int,segundo_byte:boolean;
        mem:array[0..$3fff] of byte;
        pant:byte;
        read_m:read_mem_type;
        write_m:write_mem_type;
        procedure reset;
        procedure refresh(linea:word);
        function vram_r:byte;
        function register_r:byte;
        procedure register_w(valor:byte);
        procedure vram_w(valor:byte);
        function save_snapshot(data:pbyte):word;
        procedure load_snapshot(data:pbyte);
        procedure change_irq(irq_call:irq_type);
      private
        FifthSprite:byte;
        espera_read:boolean;
        IRQ_Handler:procedure(int:boolean);
        procedure exec_interrupt;
        procedure draw_sprites(linea:byte);
        procedure draw_mode0(linea:byte);
        procedure draw_mode1(linea:byte);
        procedure draw_mode12(linea:byte);
        procedure draw_mode2(linea:byte);
        procedure draw_mode3(linea:byte);
        procedure draw_modebogus;
        procedure draw_mode23(linea:byte);
    end;

var
  tms_0:tms99xx_chip;

implementation
const
    PIXELS_VISIBLES_TOTAL=284;
    PIXELS_RIGHT_BORDER_VISIBLES=15;
    PIXELS_RIGHT_BORDER_VISIBLES_TEXT=25;
    PIXELS_LEFT_BORDER_VISIBLES=13;
    PIXELS_LEFT_BORDER_VISIBLES_TEXT=19;
    LINEAS_TOP_BORDE=27;

var
    chips_total:integer=-1;

procedure tms99xx_chip.change_irq(irq_call:irq_type);
begin
  self.IRQ_Handler:=irq_call;
end;

function tms99xx_chip.save_snapshot(data:pbyte):word;
var
  temp:pbyte;
  buffer:array[0..28] of byte;
begin
  temp:=data;
  copymemory(temp,@self.regs[0],$10);inc(temp,$10);
  copymemory(temp,@self.mem[0],$4000);inc(temp,$4000);
  buffer[0]:=self.modo_video;
  buffer[1]:=self.status_reg;
  buffer[2]:=self.buffer;
  copymemory(@buffer[3],@self.addr,2);
  buffer[5]:=byte(self.vdp_mode);
  buffer[6]:=byte(self.int);
  buffer[7]:=byte(self.segundo_byte);
  buffer[8]:=self.pant;
  copymemory(@buffer[9],@self.color,2);
  copymemory(@buffer[11],@self.pattern,2);
  copymemory(@buffer[13],@self.nametbl,2);
  copymemory(@buffer[15],@self.spriteattribute,2);
  copymemory(@buffer[17],@self.spritepattern,2);
  copymemory(@buffer[19],@self.colormask,2);
  copymemory(@buffer[21],@self.patternmask,2);
  buffer[23]:=self.fgcolor;
  buffer[24]:=self.bgcolor;
  buffer[25]:=self.FifthSprite;
  buffer[26]:=byte(self.espera_read);
  copymemory(@buffer[27],@self.TMS9918A_VRAM_SIZE,2);
  copymemory(temp,@buffer[0],29);
  save_snapshot:=$10+$4000+29;
end;

procedure tms99xx_chip.load_snapshot(data:pbyte);
var
  temp:pbyte;
begin
  temp:=data;
  copymemory(@self.regs[0],temp,$10);inc(temp,$10);
  copymemory(@self.mem[0],temp,$4000);inc(temp,$4000);
  self.modo_video:=temp^;inc(temp);
  self.status_reg:=temp^;inc(temp);
  self.buffer:=temp^;inc(temp);
  copymemory(@self.addr,temp,2);inc(temp,2);
  self.vdp_mode:=temp^<>0;inc(temp);
  self.int:=temp^<>0;inc(temp);
  self.segundo_byte:=temp^<>0;inc(temp);
  self.pant:=temp^;inc(temp);
  copymemory(@self.color,temp,2);inc(temp,2);
  copymemory(@self.pattern,temp,2);inc(temp,2);
  copymemory(@self.nametbl,temp,2);inc(temp,2);
  copymemory(@self.spriteattribute,temp,2);inc(temp,2);
  copymemory(@self.spritepattern,temp,2);inc(temp,2);
  copymemory(@self.colormask,temp,2);inc(temp,2);
  copymemory(@self.patternmask,temp,2);inc(temp,2);
  self.fgcolor:=temp^;inc(temp);
  self.bgcolor:=temp^;inc(temp);
  self.FifthSprite:=temp^;inc(temp);
  self.espera_read:=temp^<>0;inc(temp);
  copymemory(@self.TMS9918A_VRAM_SIZE,temp,2);
end;

procedure tms99xx_chip.reset;
begin
  fillchar(self.regs[0],$10,0);
  self.segundo_byte:=false;
  self.espera_read:=false;
  self.FifthSprite:=$1f;
  self.addr:=0;
  self.buffer:=0;
  self.status_reg:=0;
  self.fgcolor:=0;
  self.bgcolor:=0;
  self.color:=0;
  self.pattern:=0;
  self.nametbl:=0;
  self.spriteattribute:=0;
  self.spritepattern:=0;
  self.colormask:=$3fff;
  self.patternmask:=$3fff;
  self.int:=false;
  self.TMS9918A_VRAM_SIZE:=$3fff;
  fillchar(self.mem[0],$4000,0);
  self.vdp_mode:=false;
  paleta[0]:=0;
end;

destructor tms99xx_chip.free;
begin
chips_total:=chips_total-1;
end;

function read_mem_0(direccion:word):byte;
begin
  read_mem_0:=tms_0.mem[direccion and tms_0.TMS9918A_VRAM_SIZE];
end;

procedure write_mem_0(direccion:word;valor:byte);
begin
  tms_0.mem[direccion and tms_0.TMS9918A_VRAM_SIZE]:=valor;
end;

constructor tms99xx_chip.create(pant:byte;irq_call:irq_type;read_mem:read_mem_type=nil;write_mem:write_mem_type=nil);
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
chips_total:=chips_total+1;
//poner la paleta
for f:=0 to 15 do begin
  colores[f].r:=tms992X_palete[f,0];
  colores[f].g:=tms992X_palete[f,1];
  colores[f].b:=tms992X_palete[f,2];
end;
set_pal(colores,16);
if @read_mem<>nil then begin
    self.read_m:=read_mem;
    self.write_m:=write_mem;
end else begin
  case chips_total of
    0:begin
        self.read_m:=read_mem_0;
        self.write_m:=write_mem_0;
    end;
  end;
end;
self.pant:=pant;
self.IRQ_Handler:=irq_call;
self.reset;
end;

procedure tms99xx_chip.exec_interrupt;
var
  b:boolean;
begin
b:=((self.regs[1] and $20)<>0) and ((self.status_reg and $80)<>0);
if b<>self.int then begin
    self.int:=b;
    if @self.IRQ_Handler<>nil then self.IRQ_Handler(b);
end;
end;

procedure tms99xx_chip.draw_sprites(linea:byte);
var
  sprite_size,sprite_mag,sprite_height,num_sprites,sprattr:byte;
  sprcode,sprcol,pattern,s,i,z:byte;
  spr_x,spr_y,pataddr:word;
  spr_drawn:array[0..(32+256+32)-1] of byte;
  fifth_encountered:boolean;
  colission_index:integer;
begin
  if (self.regs[1] and 2)<>0 then sprite_size:=16
    else sprite_size:=8;
  sprite_mag:=self.regs[1] and 1;
  sprite_height:=sprite_size*(sprite_mag+1);
  fillchar(spr_drawn[0],32+256+32,0);
  num_sprites:=0;
  fifth_encountered:=false;
  for sprattr:=0 to 31 do begin
      spr_y:=self.read_m(self.spriteattribute+(sprattr*4));
      self.FifthSprite:=sprattr;
      // Stop processing sprites
      if (spr_y=208) then break;
      if (spr_y>$e0) then spr_y:=spr_y-256;
      // vert pos 255 is displayed on the first line of the screen
      spr_y:=spr_y+1;
      // is sprite enabled on this line?
      if ((spr_y<=linea) and (linea<(spr_y+sprite_height))) then begin
         spr_x:=self.read_m(self.spriteattribute+(sprattr*4)+1);
         sprcode:=self.read_m(self.spriteattribute+(sprattr*4)+2);
         sprcol:=self.read_m(self.spriteattribute+(sprattr*4)+3);
         if (sprite_size=16) then pataddr:=self.spritepattern+(sprcode and $fc)*8
            else pataddr:=self.spritepattern+sprcode*8;
         num_sprites:=num_sprites+1;
         // Fifth sprite encountered?
         if (num_sprites=5) then begin
	          fifth_encountered:=true;
	          break;
         end;
	  if (sprite_mag<>0) then pataddr:=pataddr+(((linea-spr_y) and $1f) shr 1)
	     else pataddr:=pataddr+((linea-spr_y) and $f);
	  pattern:=self.read_m(pataddr);
	  if (sprcol and $80)<>0 then spr_x:=spr_x-32;
	  sprcol:=sprcol and $0f;
	  for s:=0 to ((sprite_size-1) div 8) do begin
	      for i:=0 to 7 do begin
          if sprite_mag<>0 then colission_index:=spr_x+(i*2)+32
            else colission_index:=spr_x+i+32;
          for z:=0 to sprite_mag do begin
            // Check if pixel should be drawn
		        if (pattern and $80)<>0 then begin
		          if ((colission_index>=32) and (colission_index<32+256)) then begin
		            // Check for colission
 		            if (spr_drawn[colission_index]<>0) then self.status_reg:=self.status_reg or $20;
		            spr_drawn[colission_index]:=spr_drawn[colission_index] or $01;
 		            if (sprcol<>0) then begin
                  // Has another sprite already drawn here?
			            if ((spr_drawn[colission_index] and $02)=0) then begin
			              spr_drawn[colission_index]:=spr_drawn[colission_index] or $02;
                    punbuf^:=paleta[sprcol];
                    putpixel(colission_index-32+PIXELS_LEFT_BORDER_VISIBLES,linea+LINEAS_TOP_BORDE,1,punbuf,self.pant);
                  end;
                end; //del if sprcol
              end; //del colision
            end; //del if pattern $80
            colission_index:=colission_index+1;
          end; //del for z
          pattern:=pattern shl 1;
        end; //del for de la i
	      pattern:=self.read_m(pataddr+16);
        if sprite_mag<>0 then spr_x:=spr_x+16
          else spr_x:=spr_x+8;
    end; //del for de la s
   end; //del if dentro
  end; //del for
	// Update sprite overflow bits */
  if (self.status_reg and $40)=0 then begin
    self.status_reg:=(self.status_reg and $e0) or self.FifthSprite;
    if (fifth_encountered and ((self.status_reg  and $80)=0)) then self.status_reg:=self.status_reg or $40;
  end;
end;

procedure tms99xx_chip.draw_mode0(linea:byte);
var
  x,fc,bc,k:byte;
  ptemp:pword;
  patternptr,charcode,name_base:dword;
begin //256x192 --> Caracteres de 8x8
 ptemp:=punbuf;
 fillword(ptemp,PIXELS_LEFT_BORDER_VISIBLES,paleta[self.bgcolor]);
 inc(ptemp,PIXELS_LEFT_BORDER_VISIBLES);
 name_base:=self.NameTbl+((linea div 8)*32);
 for x:=0 to 31 do begin
     charcode:=self.read_m(name_base);
     name_base:=name_base+1;
     patternptr:=self.pattern+(charcode shl 3)+(linea and 7);
     bc:=self.read_m(self.color+(charcode shr 3));
     fc:=bc shr 4;
     bc:=bc and $f;
     K:=self.read_m(patternptr);
     if (k and $80)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
     if (k and $40)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
     if (k and $20)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
     if (k and $10)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
     if (k and $08)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
     if (k and $04)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
     if (k and $02)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
     if (k and $01)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
 end;
 fillword(ptemp,PIXELS_RIGHT_BORDER_VISIBLES,paleta[self.bgcolor]);
end;

procedure tms99xx_chip.draw_mode1(linea:byte);
var
  name_base,s:word;
  ptemp:pword;
  x,fc,bc,k:byte;
begin //240x192 --> Caracteres de 6x8
 ptemp:=punbuf;
 fillword(ptemp,PIXELS_LEFT_BORDER_VISIBLES_TEXT,paleta[self.bgcolor]);
 inc(ptemp,PIXELS_LEFT_BORDER_VISIBLES_TEXT);
 fc:=self.fgcolor;
 bc:=self.bgcolor;
 name_base:=self.Nametbl+((linea div 8)*40);
 for x:=0 to 39 do begin
     s:=self.pattern+(self.read_m(name_base) shl 3)+(linea and 7);
     name_base:=name_base+1;
     k:=self.read_m(s);
     if (k and $80)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
     if (k and $40)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
     if (k and $20)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
     if (k and $10)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
     if (k and 8)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
     if (k and 4)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
 end;
 fillword(ptemp,PIXELS_RIGHT_BORDER_VISIBLES_TEXT,paleta[self.bgcolor]);
end;

procedure tms99xx_chip.draw_mode12(linea:byte);
var
  charcode,patternptr,name_base:word;
  ptemp:pword;
  x,fc,bc,pattern:byte;
begin //240x192 --> Caracteres de 6x8
 ptemp:=punbuf;
 fillword(ptemp,PIXELS_LEFT_BORDER_VISIBLES_TEXT,paleta[self.bgcolor]);
 inc(ptemp,PIXELS_LEFT_BORDER_VISIBLES_TEXT);
 fc:=self.fgcolor;
 bc:=self.bgcolor;
 name_base:=self.Nametbl+((linea div 8)*40);
 for x:=0 to 39 do begin
     charcode:=(self.read_m(name_base)+(linea shr 6)*256) and self.patternmask;
     name_base:=name_base+1;
     patternptr:=self.pattern+(charcode shl 3)+(linea and 7);
     pattern:=self.read_m(patternptr);
     if (pattern and $80)<>0 then ptemp^:=paleta[FC] else ptemp^:=paleta[BC];inc(ptemp);
     if (pattern and $40)<>0 then ptemp^:=paleta[FC] else ptemp^:=paleta[BC];inc(ptemp);
     if (pattern and $20)<>0 then ptemp^:=paleta[FC] else ptemp^:=paleta[BC];inc(ptemp);
     if (pattern and $10)<>0 then ptemp^:=paleta[FC] else ptemp^:=paleta[BC];inc(ptemp);
     if (pattern and 8)<>0 then ptemp^:=paleta[FC] else ptemp^:=paleta[BC];inc(ptemp);
     if (pattern and 4)<>0 then ptemp^:=paleta[FC] else ptemp^:=paleta[BC];inc(ptemp);
 end;
 fillword(ptemp,PIXELS_RIGHT_BORDER_VISIBLES_TEXT,paleta[self.bgcolor]);
end;

procedure tms99xx_chip.draw_mode2(linea:byte);
var
  x,fc,bc:byte;
  name_base,pattern,patternptr,colorptr,charcode:word;
  ptemp:pword;
begin //256x192 --> Caracteres de 8x8
 ptemp:=punbuf;
 fillword(ptemp,PIXELS_LEFT_BORDER_VISIBLES,paleta[self.bgcolor]);
 inc(ptemp,PIXELS_LEFT_BORDER_VISIBLES);
 name_base:=self.NameTbl+((linea div 8)*32);
 for x:=0 to 31 do begin
     charcode:=self.read_m(name_base)+(linea shr 6)*256;
     name_base:=name_base+1;
     patternptr:=self.pattern+((charcode and self.patternmask)*8)+(linea and 7);
     colorptr:=self.color+((charcode and self.colormask)*8)+(linea and 7);
     pattern:=self.read_m(patternptr);
     bc:=self.read_m(colorptr);
     fc:=bc shr 4;
     bc:=bc and $f;
     if (pattern and $80)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
     if (pattern and $40)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
     if (pattern and $20)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
     if (pattern and $10)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
     if (pattern and 8)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
     if (pattern and 4)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
     if (pattern and 2)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
     if (pattern and 1)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
 end;
 fillword(ptemp,PIXELS_RIGHT_BORDER_VISIBLES,paleta[self.bgcolor]);
end;

procedure tms99xx_chip.draw_mode3(linea:byte);
var
    fc,bg,x,charcode:byte;
    colorptr,name_base:word;
    ptemp:pword;
begin //256x192 --> Caracteres de 4x4 en dos bloques
 ptemp:=punbuf;
 fillword(ptemp,PIXELS_LEFT_BORDER_VISIBLES,paleta[self.bgcolor]);
 inc(ptemp,PIXELS_LEFT_BORDER_VISIBLES);
 name_base:=self.nametbl+((linea div 8)*32);
 for x:=0 to 31 do begin
     charcode:=self.read_m(name_base);
     name_base:=name_base+1;
     colorptr:=self.pattern+(charcode*8)+((linea shr 2) and 7);
     fc:=self.read_m(colorptr) shr 4;
     bg:=self.read_m(colorptr) and $f;
     ptemp^:=paleta[fc];inc(ptemp); //(x+0)
     ptemp^:=paleta[fc];inc(ptemp); //(x+1)
     ptemp^:=paleta[fc];inc(ptemp); //(x+2)
     ptemp^:=paleta[fc];inc(ptemp); //(x+3)
     ptemp^:=paleta[bg];inc(ptemp); //(x+4)
     ptemp^:=paleta[bg];inc(ptemp); //(x+5)
     ptemp^:=paleta[bg];inc(ptemp); //(x+6)
     ptemp^:=paleta[bg];inc(ptemp); //(x+7)
 end;
 fillword(ptemp,PIXELS_RIGHT_BORDER_VISIBLES,paleta[self.bgcolor]);
end;

procedure tms99xx_chip.draw_modebogus;
var
    fc,bc,x:byte;
    ptemp:pword;
begin //240x192 --> Caracteres de 6x8
 ptemp:=punbuf;
 fillword(ptemp,PIXELS_LEFT_BORDER_VISIBLES_TEXT,paleta[self.bgcolor]);
 inc(ptemp,PIXELS_LEFT_BORDER_VISIBLES_TEXT);
 for x:=0 to 39 do begin
     fc:=self.fgcolor;
     bc:=self.bgcolor;
     ptemp^:=paleta[fc];inc(ptemp); //(x+0)
     ptemp^:=paleta[fc];inc(ptemp); //(x+1)
     ptemp^:=paleta[fc];inc(ptemp); //(x+2)
     ptemp^:=paleta[fc];inc(ptemp); //(x+3)
     ptemp^:=paleta[bc];inc(ptemp); //(x+4)
     ptemp^:=paleta[bc];inc(ptemp); //(x+5)
 end;
 fillword(ptemp,PIXELS_RIGHT_BORDER_VISIBLES_TEXT,paleta[self.bgcolor]);
end;

procedure tms99xx_chip.draw_mode23(linea:byte);
var
    fc,bg,x:byte;
    colorptr,charcode,name_base:word;
    ptemp:pword;
begin //256x192 --> Caracteres de 4x4 en dos bloques
 ptemp:=punbuf;
 fillword(ptemp,PIXELS_LEFT_BORDER_VISIBLES,paleta[self.bgcolor]);
 inc(ptemp,PIXELS_LEFT_BORDER_VISIBLES);
 name_base:=self.nametbl+((linea div 8)*32);
 for x:=0 to 31 do begin
     charcode:=self.read_m(name_base);
     name_base:=name_base+1;
     colorptr:=self.pattern+(((charcode+((linea shr 2) and 7)+((linea shr 6) shl 8)) and self.patternmask) shl 3);
     fc:=self.read_m(colorptr) shr 4;
     bg:=self.read_m(colorptr) and $f;
     ptemp^:=paleta[fc];inc(ptemp); //(x+0)
     ptemp^:=paleta[fc];inc(ptemp); //(x+1)
     ptemp^:=paleta[fc];inc(ptemp); //(x+2)
     ptemp^:=paleta[fc];inc(ptemp); //(x+3)
     ptemp^:=paleta[bg];inc(ptemp); //(x+4)
     ptemp^:=paleta[bg];inc(ptemp); //(x+5)
     ptemp^:=paleta[bg];inc(ptemp); //(x+6)
     ptemp^:=paleta[bg];inc(ptemp); //(x+7)
 end;
 fillword(ptemp,PIXELS_RIGHT_BORDER_VISIBLES,paleta[self.bgcolor]);
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
procedure tms99xx_chip.refresh(linea:word);
begin
  //ESPERO UNA LINEA FISICA
  //Pantalla apagada, solo pinto el color de fondo
  if (self.regs[1] and $40)=0 then begin
    single_line(0,linea,paleta[self.bgcolor],PIXELS_VISIBLES_TOTAL,self.pant);
    if linea=192 then begin
                self.status_reg:=self.status_reg or $80;
                self.exec_interrupt;
    end;
    exit;
  end;
  case linea of
     0..191:begin //Pantalla visible (192)
               case self.modo_video of
                    0:self.draw_mode0(linea);
                    1:self.draw_mode1(linea);
                    2:self.draw_mode2(linea);
                    3:self.draw_mode12(linea);
                    4:self.draw_mode3(linea);
                    6:self.draw_mode23(linea);
                    5,7:self.draw_modebogus;
               end;
               putpixel(0,linea+LINEAS_TOP_BORDE,PIXELS_VISIBLES_TOTAL,punbuf,self.pant);
               if ((self.regs[1] and $50)=$40) then draw_sprites(linea)
                else self.FifthSprite:=$1f;
               //if linea=191 then self.status_reg:=self.status_reg or $80;
            end;
     192:begin
            single_line(0,linea+LINEAS_TOP_BORDE,paleta[self.bgcolor],PIXELS_VISIBLES_TOTAL,self.pant);
            self.status_reg:=self.status_reg or $80;
            self.exec_interrupt;
         end;
     193..215:single_line(0,linea+LINEAS_TOP_BORDE,paleta[self.bgcolor],PIXELS_VISIBLES_TOTAL,self.pant);
     //Lineas no dibujadas sincronismos (3+3+13)
     216..234:;
     //Borde superior (27)
     235..261:single_line(0,linea-235,paleta[self.bgcolor],PIXELS_VISIBLES_TOTAL,self.pant);
  end;
end;

procedure update_table_masks(tms:tms99xx_chip);
begin
	tms.colormask:=((tms.regs[3] and $7f) shl 3) or 7;
	//on 91xx family, the colour table mask doesn't affect the pattern table mask
	tms.patternmask:=((tms.regs[4] and 3) shl 8) or $ff;
end;

//change register
procedure change_reg(tms:tms99xx_chip;addr,Val:byte);
const
  Mask:array[0..7] of byte=($07,$fb,$0f,$ff,$07,$7f,$07,$ff);
begin
  val:=val and mask[addr];
  tms.regs[addr]:=Val;
  case addr of
     0:begin
          tms.vdp_mode:=(val and 4)<>0;
	        if (val and 2)<>0 then begin
			      tms.color:=((tms.Regs[3] and $80)*64) and tms.TMS9918A_VRAM_SIZE;
			      tms.pattern:=((tms.Regs[4] and 4)*2048) and tms.TMS9918A_VRAM_SIZE;
            update_table_masks(tms);
		      end else begin
			      tms.color:=(tms.Regs[3]*64) and tms.TMS9918A_VRAM_SIZE;
			      tms.pattern:=(tms.Regs[4]*2048) and tms.TMS9918A_VRAM_SIZE;
          end;
          tms.modo_video:=(tms.Regs[0] and 2) or ((tms.Regs[1] and $10) shr 4) or ((tms.Regs[1] and 8) shr 1);
       end;
     1:begin
        tms.exec_interrupt;
        tms.modo_video:=(tms.Regs[0] and 2) or ((tms.Regs[1] and $10) shr 4) or ((tms.Regs[1] and 8) shr 1);
        if (val and $80)<>0 then tms.TMS9918A_VRAM_SIZE:=$3fff
           else tms.TMS9918A_VRAM_SIZE:=$fff;
       end;
     2:tms.NameTbl:=(val*1024) and tms.TMS9918A_VRAM_SIZE;
     3:begin
        if (tms.Regs[0] and 2)<>0 then begin
            tms.color:=((val and $80)*64) and tms.TMS9918A_VRAM_SIZE;
            update_table_masks(tms);
        end else begin
            tms.color:=(val*64) and tms.TMS9918A_VRAM_SIZE;
        end;
		    tms.patternmask:=(tms.Regs[4] and 3)*256 or (tms.colormask and 255);
       end;
     4:if (tms.Regs[0] and 2)<>0 then begin
            tms.pattern:=((val and 4)*2048) and tms.TMS9918A_VRAM_SIZE;
            update_table_masks(tms);
        end else begin
            tms.pattern:=(val*2048) and tms.TMS9918A_VRAM_SIZE;
        end;
     5:tms.spriteattribute:=(val*128) and tms.TMS9918A_VRAM_SIZE;
     6:tms.spritepattern:=(val*2048) and tms.TMS9918A_VRAM_SIZE;
     7: begin
       tms.fgcolor:=val shr 4;
       if tms.bgcolor<>(val and $f) then begin
          tms.bgcolor:=(val and $f);
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

function tms99xx_chip.register_r:byte;
begin
  register_r:=self.status_reg;
  self.status_reg:=self.FifthSprite;
  self.segundo_byte:=false;
  self.exec_interrupt; //Limpio la IRQ...
end;

//http://bifi.msxnet.org/msxnet/tech/tms9918a.txt
//http://bifi.msxnet.org/msxnet/tech/tmsposting.txt

procedure tms99xx_chip.register_w(valor:byte);
begin
{Definicion de los dos bytes escritos
Byte #0		V7	V6	V5	V4	V3	V2	V1	V0
Byte #1		1(CR)	?	?	?	?	R2	R1	R0
CR --> Si es 1 cambiar registro
	VX --> Valor (1 byte)
	RX --> Registro
  CR --> 0 cambiar direccion L/E (ver mas abajo la descripcion)
}
if not(self.segundo_byte) then begin
  self.addr:=((self.addr and $ff00) or valor) and self.tms9918A_VRAM_SIZE;
  self.segundo_byte:=true;
end else begin
  self.segundo_byte:=false;
  self.addr:=((self.addr and $ff) or (valor shl 8)) and self.tms9918A_VRAM_SIZE;
  case (valor and $c0) of
    $80:change_reg(self,valor and $f,self.addr and $ff);
    $00:begin
          self.buffer:=self.read_m(self.addr);
          self.addr:=(self.addr+1) and self.tms9918A_VRAM_SIZE;
          self.segundo_byte:=false;
          self.espera_read:=true;
        end;
    $40:self.espera_read:=false;
  end;
end;
end;

{Definicion del word de la direccion
Byte #0		A7	A6	A5	A4	A3	A2	A1	A0
Byte #1		0	R/W	A13	A12	A11	A10	A9	A8
AX --> Direccion
R/W --> 0 para leer y 1 para escribir}

function tms99xx_chip.vram_r:byte;  //ReadDataPort
begin
  //Si el bit R/W esta a 1 (escritura) que hago???
  vram_r:=self.buffer;
  self.buffer:=self.read_m(self.addr);
  self.addr:=(self.addr+1) and self.tms9918A_VRAM_SIZE;
  self.segundo_byte:=false;
end;

procedure tms99xx_chip.vram_w(valor:byte);
begin
if not(self.espera_read) then begin
   self.write_m(self.addr,valor);
   self.buffer:=valor;
   self.addr:=(self.addr+1) and self.tms9918A_VRAM_SIZE;
   self.segundo_byte:=false;
end else begin
   self.buffer:=self.read_m(self.addr);
   self.addr:=(self.addr+1) and self.tms9918A_VRAM_SIZE;
   self.write_m(self.addr,valor);
end;
end;

end.
