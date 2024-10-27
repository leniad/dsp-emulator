unit nemesis_hw;
interface

uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,m68000,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     sound_engine,ay_8910,vlm_5030,k005289,ym_2151,k007232;

function iniciar_nemesis:boolean;

implementation

type
  tipo_sprite=record
                width,height,char_type:byte;
                mask:word;
              end;
const
        nemesis_rom:array[0..7] of tipo_roms=(
        (n:'456-d01.12a';l:$8000;p:0;crc:$35ff1aaa),(n:'456-d05.12c';l:$8000;p:$1;crc:$23155faa),
        (n:'456-d02.13a';l:$8000;p:$10000;crc:$ac0cf163),(n:'456-d06.13c';l:$8000;p:$10001;crc:$023f22a9),
        (n:'456-d03.14a';l:$8000;p:$20000;crc:$8cefb25f),(n:'456-d07.14c';l:$8000;p:$20001;crc:$d50b82cb),
        (n:'456-d04.15a';l:$8000;p:$30000;crc:$9ca75592),(n:'456-d08.15c';l:$8000;p:$30001;crc:$03c0b7f5));
        nemesis_sound:tipo_roms=(n:'456-d09.9c';l:$4000;p:0;crc:$26bf9636);
        rom_k005289:array[0..1] of tipo_roms=(
        (n:'400-a01.fse';l:$100;p:$0;crc:$5827b1e8),(n:'400-a02.fse';l:$100;p:$100;crc:$2f44f970));
        gx400_bios:array[0..1] of tipo_roms=(
        (n:'400-a06.15l';l:$8000;p:0;crc:$b99d8cff),(n:'400-a04.10l';l:$8000;p:$1;crc:$d02c9552));
        gx400_sound:tipo_roms=(n:'400-e03.5l';l:$2000;p:0;crc:$a5a8e57d);
        twinbee_rom:array[0..1] of tipo_roms=(
        (n:'412-a07.17l';l:$20000;p:$0;crc:$d93c5499),(n:'412-a05.12l';l:$20000;p:$1;crc:$2b357069));
        gwarrior_rom:array[0..1] of tipo_roms=(
        (n:'578-a07.17l';l:$20000;p:$0;crc:$0aedacb5),(n:'578-a05.12l';l:$20000;p:$1;crc:$76240e2e));
        salamander_rom:array[0..3] of tipo_roms=(
        (n:'587-d02.18b';l:$10000;p:0;crc:$a42297f9),(n:'587-d05.18c';l:$10000;p:$1;crc:$f9130b0a),
        (n:'587-c03.17b';l:$20000;p:$40000;crc:$e5caf6e6),(n:'587-c06.17c';l:$20000;p:$40001;crc:$c2f567ea));
        salamander_sound:tipo_roms=(n:'587-d09.11j';l:$8000;p:0;crc:$5020972c);
        salamander_vlm:tipo_roms=(n:'587-d08.8g';l:$4000;p:0;crc:$f9ac6b82);
        salamander_k007232:tipo_roms=(n:'587-c01.10a';l:$20000;p:0;crc:$09fe0632);
        //Graficos
        char_x:array[0..63] of dword=(0*4,1*4,2*4,3*4,4*4,5*4,6*4,7*4,
                                          8*4,9*4,10*4,11*4,12*4,13*4,14*4,15*4,
                                          16*4,17*4,18*4,19*4,20*4,21*4,22*4,23*4,
                                          24*4,25*4,26*4,27*4,28*4,29*4,30*4,31*4,
                                          32*4,33*4,34*4,35*4,36*4,37*4,38*4,39*4,
                                          40*4,41*4,42*4,43*4,44*4,45*4,46*4,47*4,
                                          48*4,49*4,50*4,51*4,52*4,53*4,54*4,55*4,
                                          56*4,57*4,58*4,59*4,60*4,61*4,62*4,63*4);
        char_8_y:array[0..15] of dword=(0*4*8,1*4*8,2*4*8,3*4*8,4*4*8,5*4*8,6*4*8,7*4*8,
                                          8*4*8,9*4*8,10*4*8,11*4*8,12*4*8,13*4*8,14*4*8,15*4*8);
        char_16_y:array[0..31] of dword=(0*4*16,1*4*16,2*4*16,3*4*16,4*4*16,5*4*16,6*4*16,7*4*16,
                                          8*4*16,9*4*16,10*4*16,11*4*16,12*4*16,13*4*16,14*4*16,15*4*16,
                                          16*4*16,17*4*16,18*4*16,19*4*16,20*4*16,21*4*16,22*4*16,23*4*16,
                                          24*4*16,25*4*16,26*4*16,27*4*16,28*4*16,29*4*16,30*4*16,31*4*16);
        char_32_y:array[0..31] of dword=(0*4*32,1*4*32,2*4*32,3*4*32,4*4*32,5*4*32,6*4*32,7*4*32,
                                          8*4*32,9*4*32,10*4*32,11*4*32,12*4*32,13*4*32,14*4*32,15*4*32,
                                          16*4*32,17*4*32,18*4*32,19*4*32,20*4*32,21*4*32,22*4*32,23*4*32,
                                          24*4*32,25*4*32,26*4*32,27*4*32,28*4*32,29*4*32,30*4*32,31*4*32);
        char_64_y:array[0..63] of dword=(0*4*64,1*4*64,2*4*64,3*4*64,4*4*64,5*4*64,6*4*64,7*4*64,
                                          8*4*64,9*4*64,10*4*64,11*4*64,12*4*64,13*4*64,14*4*64,15*4*64,
                                          16*4*64,17*4*64,18*4*64,19*4*64,20*4*64,21*4*64,22*4*64,23*4*64,
                                          24*4*64,25*4*64,26*4*64,27*4*64,28*4*64,29*4*64,30*4*64,31*4*64,
                                          32*4*64,33*4*64,34*4*64,35*4*64,36*4*64,37*4*64,38*4*64,39*4*64,
                                          40*4*64,41*4*64,42*4*64,43*4*64,44*4*64,45*4*64,46*4*64,47*4*64,
                                          48*4*64,49*4*64,50*4*64,51*4*64,52*4*64,53*4*64,54*4*64,55*4*64,
                                          56*4*64,57*4*64,58*4*64,59*4*64,60*4*64,61*4*64,62*4*64,63*4*64);
        //Sprites
        sprite_data:array[0..7] of tipo_sprite=((width:32;height:32;char_type:4;mask:$7f),(width:16;height:32;char_type:5;mask:$ff),(width:32;height:16;char_type:2;mask:$ff),(width:64;height:64;char_type:7;mask:$1f),
                                                (width:8;height:8;char_type:0;mask:$7ff),(width:16;height:8;char_type:6;mask:$3ff),(width:8;height:16;char_type:3;mask:$3ff),(width:16;height:16;char_type:1;mask:$1ff));
        pal_look:array[0..$1f] of byte=(0,1,2,4,5,6,8,9,11,13,15,18,20,22,25,28,33,36,41,46,51,57,64,73,
                                        80,91,104,120,142,168,204,255);
var
 rom:array[0..$3ffff] of word;
 ram3,bios_rom,char_ram:array[0..$7fff] of word;
 ram1:array[0..$fff] of word;
 ram2:array[0..$3fff] of word;
 ram4:array[0..$ffff] of word;
 shared_ram:array[0..$3fff] of byte;
 xscroll_1,xscroll_2:array[0..$1ff] of word;
 yscroll_1,yscroll_2:array[0..$3f] of word;
 video1_ram,video2_ram,color1_ram,color2_ram,sprite_ram:array[0..$7ff] of word;
 screen_par,irq_on,irq2_on,irq4_on,flipx_scr,flipy_scr,changed_chr:boolean;
 sound_latch:byte;
 k007232_1_rom:pbyte;
 //char buffer
 char_8_8:array[0..$7ff] of boolean;
 char_16_16:array[0..$1ff] of boolean;
 char_32_16:array[0..$ff] of boolean;
 char_8_16:array[0..$3ff] of boolean;
 char_32_32:array[0..$7f] of boolean;
 char_64_64:array[0..$1f] of boolean;

procedure update_video_nemesis;
procedure char_calc;
var
  f:word;
begin
  //8x8 char
  gfx_set_desc_data(4,0,4*8*8,0,1,2,3);
  for f:=0 to $7ff do if char_8_8[f] then begin
    convert_gfx_single(0,0,@char_ram,@char_x,@char_8_y,false,false,f);
    char_8_8[f]:=false;
  end;
  //16x16
  gfx_set_desc_data(4,1,4*16*16,0,1,2,3);
  for f:=0 to $1ff do if char_16_16[f] then begin
    convert_gfx_single(1,0,@char_ram,@char_x,@char_16_y,false,false,f);
    char_16_16[f]:=false;
  end;
  //32x16 y 16x32
  gfx_set_desc_data(4,2,4*32*16,0,1,2,3);
  for f:=0 to $ff do if char_32_16[f] then convert_gfx_single(2,0,@char_ram,@char_x,@char_32_y,false,false,f);
  gfx_set_desc_data(4,5,4*16*32,0,1,2,3);
  for f:=0 to $ff do if char_32_16[f] then begin
      convert_gfx_single(5,0,@char_ram,@char_x,@char_16_y,false,false,f);
      char_32_16[f]:=false;
  end;
  //8x16 y 16x8
  gfx_set_desc_data(4,3,4*8*16,0,1,2,3);
  for f:=0 to $3ff do if char_8_16[f] then convert_gfx_single(3,0,@char_ram,@char_x,@char_8_y,false,false,f);
  gfx_set_desc_data(4,6,4*16*8,0,1,2,3);
  for f:=0 to $3ff do if char_8_16[f] then begin
      convert_gfx_single(6,0,@char_ram,@char_x,@char_16_y,false,false,f);
      char_8_16[f]:=false;
  end;
  //32x32
  gfx_set_desc_data(4,4,4*32*32,0,1,2,3);
  for f:=0 to $7f do if char_32_32[f] then begin
    convert_gfx_single(4,0,@char_ram,@char_x,@char_32_y,false,false,f);
    char_32_32[f]:=false;
  end;
  //64x64
  gfx_set_desc_data(4,7,4*64*64,0,1,2,3);
  for f:=0 to $1f do if char_64_64[f] then begin
    convert_gfx_single(7,0,@char_ram,@char_x,@char_64_y,false,false,f);
    char_64_64[f]:=false;
  end;
  changed_chr:=false;
end;

procedure draw_sprites;
var
  f,pri,idx,num_gfx:byte;
  zoom,nchar,size,sx,sy,color,atrib,atrib2:word;
  flipx,flipy:boolean;
  zx:single;
begin
for pri:=0 to $ff do begin  //prioridad
  for f:=0 to $ff do begin      //cantidad de sprites
    if((sprite_ram[f*8] and $ff)<>pri) then continue;  //si no tiene la prioridad requerida sigo
    zoom:=sprite_ram[(f*8)+2] and $ff;
    atrib:=sprite_ram[(f*8)+4];
    atrib2:=sprite_ram[(f*8)+3];
    if (((sprite_ram[(f*8)+2] and $ff00)=0) and ((atrib2 and $ff00)<>$ff00)) then nchar:=atrib2+((atrib and $c0) shl 2)
      else nchar:=(atrib2 and $ff)+((atrib and $c0) shl 2);
    if (zoom<>$ff) then begin
      size:=sprite_ram[(f*8)+1];
      zoom:=zoom+((size and $c0) shl 2);
      sx:=(sprite_ram[(f*8)+5] and $ff)+((atrib and $1) shl 8);
      sy:=sprite_ram[(f*8)+6] and $ff;
      color:=(atrib and $1e) shl 3;
      flipx:=(size and $01)<>0;
      flipy:=(atrib and $20)<>0;
      idx:=(size shr 3) and 7;
      nchar:=nchar*8*16 div (sprite_data[idx].width*sprite_data[idx].height);
      num_gfx:=sprite_data[idx].char_type;
      if (zoom<>0) then begin
        zx:=$80/zoom;
        put_gfx_sprite_zoom(nchar and sprite_data[idx].mask,color,flipx,flipy,num_gfx,zx,zx);
        actualiza_gfx_sprite_zoom(sx,sy,9,num_gfx,zx,zx);
      end;
    end;
  end;
end;
end;

var
  f,x,y,nchar,color:word;
  flipx,flipy:boolean;
  mask,layer,pant,h:byte;
  scroll_x1,scroll_x2:array[0..$ff] of word;
begin
fill_full_screen(9,0);
if changed_chr then char_calc;
for f:=0 to $7ff do begin
    //background
    color:=color2_ram[f];
    if (gfx[1].buffer[f] or buffer_color[color and $7f]) then begin
      nchar:=video2_ram[f];
      if flipx_scr then x:=63-(f and $3f)
        else x:=f and $3f;
      if flipy_scr then y:=31-(f shr 6)
        else y:=f shr 6;
      flipx:=((color and $80)<>0) xor flipx_scr;
      flipy:=((nchar and $800)<>0) xor flipy_scr;
      for h:=1 to 4 do put_gfx_block_trans(x*8,y*8,h,8,8);
      if (((not(nchar) and $2000)<>0) or ((nchar and $c000)=$4000)) then begin
        if (nchar and $f800)<>0 then put_gfx_flip(x*8,y*8,nchar and $7ff,(color and $7f) shl 4,4,0,flipx,flipy);
      end else begin
        mask:=(nchar and $1000) shr 12;
	      layer:=(nchar and $4000) shr 14;
	      if ((mask<>0) and (layer=0)) then layer:=1;
        pant:=(mask or (layer shl 1))+1;
        if (nchar and $f800)<>0 then put_gfx_trans_flip(x*8,y*8,nchar and $7ff,(color and $7f) shl 4,pant,0,flipx,flipy);
      end;
      gfx[1].buffer[f]:=false;
    end;
    //foreground
    color:=color1_ram[f];
    if (gfx[0].buffer[f] or buffer_color[color and $7f]) then begin
      nchar:=video1_ram[f];
      if flipx_scr then x:=63-(f and $3f)
        else x:=f and $3f;
      if flipy_scr then y:=31-(f shr 6)
        else y:=f shr 6;
      flipx:=((color and $80)<>0) xor flipx_scr;
      flipy:=((nchar and $800)<>0) xor flipy_scr;
      for h:=5 to 8 do put_gfx_block_trans(x*8,y*8,h,8,8);
      if (((not(nchar) and $2000)<>0) or ((nchar and $c000)=$4000)) then begin
        if (nchar and $f800)<>0 then put_gfx_flip(x*8,y*8,nchar and $7ff,(color and $7f) shl 4,8,0,flipx,flipy);
      end else begin
        mask:=(nchar and $1000) shr 12;
	      layer:=(nchar and $4000) shr 14;
        if ((mask<>0) and (layer=0)) then layer:=1;
        pant:=(mask or (layer shl 1))+5;
        if (nchar and $f800)<>0 then put_gfx_trans_flip(x*8,y*8,nchar and $7ff,(color and $7f) shl 4,pant,0,flipx,flipy);
      end;
      gfx[0].buffer[f]:=false;
    end;
end;
for f:=0 to $ff do begin
  scroll_x1[f]:=(xscroll_1[f] and $ff)+((xscroll_1[f+$100] and $1) shl 8);
  scroll_x2[f]:=(xscroll_2[f] and $ff)+((xscroll_2[f+$100] and $1) shl 8);
end;
//1
scroll__x_part2(1,9,1,@scroll_x2);
scroll__x_part2(5,9,1,@scroll_x1);
//2
scroll__x_part2(2,9,1,@scroll_x2);
scroll__x_part2(6,9,1,@scroll_x1);
//Sprites
draw_sprites;
//3
scroll__x_part2(3,9,1,@scroll_x2);
scroll__x_part2(7,9,1,@scroll_x1);
//4
scroll__x_part2(4,9,1,@scroll_x2);
scroll__x_part2(8,9,1,@scroll_x1);
actualiza_trozo_final(0,16,256,224,9);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
end;

procedure eventos_nemesis;
begin
if event.arcade then begin
  //IN0
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 or $1) else marcade.in0:=(marcade.in0 and $fffe);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 or $2) else marcade.in0:=(marcade.in0 and $fffd);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 or $8) else marcade.in0:=(marcade.in0 and $fff7);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 or $10) else marcade.in0:=(marcade.in0 and $ffef);
  //P1
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 or $1) else marcade.in1:=(marcade.in1 and $fffe);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 or $2) else marcade.in1:=(marcade.in1 and $fffd);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 or $4) else marcade.in1:=(marcade.in1 and $fffb);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 or $8) else marcade.in1:=(marcade.in1 and $fff7);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 or $10) else marcade.in1:=(marcade.in1 and $ffef);
  if arcade_input.but2[0] then marcade.in1:=(marcade.in1 or $20) else marcade.in1:=(marcade.in1 and $ffdf);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 or $40) else marcade.in1:=(marcade.in1 and $ffbf);
  //P2
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 or $1) else marcade.in2:=(marcade.in2 and $fffe);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 or $2) else marcade.in2:=(marcade.in2 and $fffd);
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 or $4) else marcade.in2:=(marcade.in2 and $fffb);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 or $8) else marcade.in2:=(marcade.in2 and $fff7);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 or $10) else marcade.in2:=(marcade.in2 and $ffef);
  if arcade_input.but2[1] then marcade.in2:=(marcade.in2 or $20) else marcade.in2:=(marcade.in2 and $ffdf);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 or $40) else marcade.in2:=(marcade.in2 and $ffbf);
end;
end;

procedure cambiar_color(tmp_color,numero:word);
var
  bit1,bit2,bit3:byte;
  color:tcolor;
begin
  bit1:=(tmp_color shr 0) and $1f;
  bit2:=(tmp_color shr 5) and $1f;
  bit3:=(tmp_color shr 10) and $1f;
  color.r:=pal_look[bit1];
  color.g:=pal_look[bit2];
  color.b:=pal_look[bit3];
  set_pal_color(color,numero);
  buffer_color[numero shr 4]:=true;
end;

function ay0_porta_read:byte;
var
  res:byte;
begin
  res:=round(z80_0.totalt/1024) and $2f;
  ay0_porta_read:=res or $d0 or $20;
end;

procedure ay8910_k005289_1(valor:byte);
begin
  k005289_0.control_A_w(valor);
end;

procedure ay8910_k005289_2(valor:byte);
begin
  k005289_0.control_B_w(valor);
end;

procedure sound_update;
begin
  ay8910_0.update;
  ay8910_1.update;
  k005289_0.update;
end;

//Nemesis
procedure nemesis_principal;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
frame_s:=z80_0.tframes;
while EmuStatus=EsRunning do begin
 for f:=0 to $ff do begin
    //Main CPU
    m68000_0.run(frame_m);
    frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
    //Sound CPU
    z80_0.run(frame_s);
    frame_s:=frame_s+z80_0.tframes-z80_0.contador;
    if f=239 then begin
      update_video_nemesis;
      if irq_on then m68000_0.irq[1]:=HOLD_LINE;
    end;
 end;
 eventos_nemesis;
 video_sync;
end;
end;

function nemesis_getword(direccion:dword):word;
begin
case direccion of
  0..$3ffff:nemesis_getword:=rom[direccion shr 1];
  $40000..$4ffff:nemesis_getword:=(char_ram[(direccion and $ffff) shr 1] shr 8)+((char_ram[(direccion and $ffff) shr 1] and $ff) shl 8);//char_ram[(direccion+1) and $ffff] or (char_ram[direccion and $ffff] shl 8);
  $50000..$51fff:nemesis_getword:=ram1[(direccion and $1fff) shr 1];
  $52000..$52fff:nemesis_getword:=video1_ram[(direccion and $fff) shr 1];
  $53000..$53fff:nemesis_getword:=video2_ram[(direccion and $fff) shr 1];
  $54000..$54fff:nemesis_getword:=color1_ram[(direccion and $fff) shr 1];
  $55000..$55fff:nemesis_getword:=color2_ram[(direccion and $fff) shr 1];
  $56000..$56fff:nemesis_getword:=sprite_ram[(direccion and $fff) shr 1];
  $5a000..$5afff:nemesis_getword:=buffer_paleta[(direccion and $fff) shr 1];
  $5c400:nemesis_getword:=$ff;
  $5c402:nemesis_getword:=$5b;
  $5cc00:nemesis_getword:=marcade.in0;
  $5cc02:nemesis_getword:=marcade.in1;
  $5cc04:nemesis_getword:=marcade.in2;
  $5cc06:nemesis_getword:=$ff;
  $60000..$67fff:nemesis_getword:=ram2[(direccion and $7fff) shr 1];
end;
end;

procedure nemesis_putword(direccion:dword;valor:word);
var
  dir:word;
begin
case direccion of
  0..$3ffff:;
  $40000..$4ffff:if char_ram[(direccion and $ffff) shr 1]<>(((valor and $ff) shl 8)+(valor shr 8)) then begin
                    char_ram[(direccion and $ffff) shr 1]:=((valor and $ff) shl 8)+(valor shr 8);
                    char_8_8[(direccion and $ffff) div $20]:=true;
                    char_16_16[(direccion and $ffff) div $80]:=true;
                    char_32_16[(direccion and $ffff) div $100]:=true;
                    char_8_16[(direccion and $ffff) div $40]:=true;
                    char_32_32[(direccion and $ffff) div $200]:=true;
                    char_64_64[(direccion and $ffff) div $800]:=true;
                    fillchar(gfx[0].buffer,$800,1);
                    fillchar(gfx[1].buffer,$800,1);
                    changed_chr:=true;
                 end;
  $50000..$51fff:begin
                    dir:=(direccion and $1fff) shr 1;
                    ram1[dir]:=valor;
                    case (direccion and $1fff) of
                      0..$3ff:xscroll_1[dir and $1ff]:=valor;
                      $400..$7ff:xscroll_2[dir and $1ff]:=valor;
                      $f00..$f7f:yscroll_2[dir and $3f]:=valor;
                      $f80..$fff:yscroll_1[dir and $3f]:=valor;
                    end;
                 end;
  $52000..$52fff:if video1_ram[(direccion and $fff) shr 1]<>valor then begin
                    video1_ram[(direccion and $fff) shr 1]:=valor;
                    gfx[0].buffer[(direccion and $fff) shr 1]:=true;
                 end;
  $53000..$53fff:if video2_ram[(direccion and $fff) shr 1]<>valor then begin
                    video2_ram[(direccion and $fff) shr 1]:=valor;
                    gfx[1].buffer[(direccion and $fff) shr 1]:=true;
                 end;
  $54000..$54fff:if color1_ram[(direccion and $fff) shr 1]<>valor then begin
                    color1_ram[(direccion and $fff) shr 1]:=valor;
                    gfx[0].buffer[(direccion and $fff) shr 1]:=true;
                 end;
  $55000..$55fff:if color2_ram[(direccion and $fff) shr 1]<>valor then begin
                    color2_ram[(direccion and $fff) shr 1]:=valor;
                    gfx[1].buffer[(direccion and $fff) shr 1]:=true;
                 end;
  $56000..$56fff:sprite_ram[(direccion and $fff) shr 1]:=valor;
  $5a000..$5afff:if buffer_paleta[(direccion and $fff) shr 1]<>valor then begin
                    buffer_paleta[(direccion and $fff) shr 1]:=valor;
                    cambiar_color(valor,(direccion and $fff) shr 1);
                 end;
  $5c000:sound_latch:=valor and $ff;
  $5e000:irq_on:=(valor and $ff)<>0;
  $5e004:begin
            flipx_scr:=(valor and $1)<>0;
            if (valor and $100)<>0 then z80_0.change_irq(HOLD_LINE);
         end;
  $5e006:flipy_scr:=(valor and $1)<>0;
  $60000..$67fff:ram2[(direccion and $7fff) shr 1]:=valor;
end;
end;

function nemesis_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$47ff:nemesis_snd_getbyte:=mem_snd[direccion];
  $e001:nemesis_snd_getbyte:=sound_latch;
  $e086:nemesis_snd_getbyte:=ay8910_0.Read;
  $e205:nemesis_snd_getbyte:=ay8910_1.Read;
end;
end;

procedure nemesis_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$3fff:;
  $4000..$47ff:mem_snd[direccion]:=valor;
  $a000..$afff:k005289_0.ld1_w(direccion and $fff,valor);
  $c000..$cfff:k005289_0.ld2_w(direccion and $fff,valor);
  $e003:k005289_0.tg1_w(valor);
  $e004:k005289_0.tg2_w(valor);
  $e005:ay8910_1.Control(valor);
  $e006:ay8910_0.Control(valor);
  $e106:ay8910_0.Write(valor);
  $e405:ay8910_1.Write(valor);
end;
end;

//GX400
procedure eventos_gx400;
begin
if event.arcade then begin
  marcade.in0:=$ff;
  marcade.in1:=$ff;
  marcade.in2:=$ff;
  //IN0
  if arcade_input.coin[0] then marcade.in0:=marcade.in0 and $fe;
  if arcade_input.coin[1] then marcade.in0:=marcade.in0 and $fd;
  if arcade_input.start[0] then marcade.in0:=marcade.in0 and $f7;
  if arcade_input.start[1] then marcade.in0:=marcade.in0 and $ef;
  //P1
  if arcade_input.left[0] then marcade.in1:=marcade.in1 and $fe;
  if arcade_input.right[0] then marcade.in1:=marcade.in1 and $fd;
  if arcade_input.up[0] then marcade.in1:=marcade.in1 and $fb;
  if arcade_input.down[0] then marcade.in1:=marcade.in1 and $f7;
  if arcade_input.but0[0] then marcade.in1:=marcade.in1 and $ef;
  if arcade_input.but2[0] then marcade.in1:=marcade.in1 and $df;
  if arcade_input.but1[0] then marcade.in1:=marcade.in1 and $bf;
  //P2
  if arcade_input.left[1] then marcade.in2:=marcade.in2 and $fe;
  if arcade_input.right[1] then marcade.in2:=marcade.in2 and $fd;
  if arcade_input.up[1] then marcade.in2:=marcade.in2 and $fb;
  if arcade_input.down[1] then marcade.in2:=marcade.in2 and $f7;
  if arcade_input.but0[1] then marcade.in2:=marcade.in2 and $ef;
  if arcade_input.but2[1] then marcade.in2:=marcade.in2 and $df;
  if arcade_input.but1[1] then marcade.in2:=marcade.in2 and $bf;
end;
end;

procedure gx400_principal;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
frame_s:=z80_0.tframes;
while EmuStatus=EsRunning do begin
 for f:=0 to $ff do begin
    //Main CPU
    m68000_0.run(frame_m);
    frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
    //Sound CPU
    z80_0.run(frame_s);
    frame_s:=frame_s+z80_0.tframes-z80_0.contador;
    case f of
      119:if irq4_on then m68000_0.irq[4]:=HOLD_LINE;
      239:begin
            update_video_nemesis;
            if (irq_on and screen_par) then m68000_0.irq[1]:=HOLD_LINE;
            z80_0.change_nmi(PULSE_LINE);
          end;
      255:if irq2_on then m68000_0.irq[2]:=HOLD_LINE;
    end;
 end;
 screen_par:=not(screen_par);
 eventos_gx400;
 video_sync;
end;
end;

function gx400_getword(direccion:dword):word;
begin
case direccion of
  0..$ffff:gx400_getword:=bios_rom[direccion shr 1];
  $10000..$1ffff:gx400_getword:=ram3[(direccion and $ffff) shr 1];
  $20000..$27fff:gx400_getword:=shared_ram[(direccion and $7fff) shr 1];
  $30000..$3ffff:gx400_getword:=(char_ram[(direccion and $ffff) shr 1] shr 8)+((char_ram[(direccion and $ffff) shr 1] and $ff) shl 8);
  $50000..$51fff:gx400_getword:=ram1[(direccion and $1fff) shr 1];
  $52000..$52fff:gx400_getword:=video1_ram[(direccion and $fff) shr 1];
  $53000..$53fff:gx400_getword:=video2_ram[(direccion and $fff) shr 1];
  $54000..$54fff:gx400_getword:=color1_ram[(direccion and $fff) shr 1];
  $55000..$55fff:gx400_getword:=color2_ram[(direccion and $fff) shr 1];
  $56000..$56fff:gx400_getword:=sprite_ram[(direccion and $fff) shr 1];
  $57000..$57fff:gx400_getword:=ram2[(direccion and $fff) shr 1];
  $5a000..$5afff:gx400_getword:=buffer_paleta[(direccion and $fff) shr 1];
  $5c402:gx400_getword:=$ff;
  $5c404:gx400_getword:=$56;
  $5c406:gx400_getword:=$fd;
  $5cc00:gx400_getword:=marcade.in0;
  $5cc02:gx400_getword:=marcade.in1;
  $5cc04:gx400_getword:=marcade.in2;
  $60000..$7ffff:gx400_getword:=ram4[(direccion and $1ffff) shr 1];
  $80000..$bffff:gx400_getword:=rom[(direccion and $3ffff) shr 1];
end;
end;

procedure gx400_putword(direccion:dword;valor:word);
var
  dir:word;
begin
case direccion of
  0..$ffff,$80000..$bffff:;
  $10000..$1ffff:ram3[(direccion and $ffff) shr 1]:=valor;
  $20000..$27fff:shared_ram[(direccion and $7fff) shr 1]:=valor and $ff;
  $30000..$3ffff:if char_ram[(direccion and $ffff) shr 1]<>(((valor and $ff) shl 8)+(valor shr 8)) then begin
                    char_ram[(direccion and $ffff) shr 1]:=((valor and $ff) shl 8)+(valor shr 8);
                    char_8_8[(direccion and $ffff) div $20]:=true;
                    char_16_16[(direccion and $ffff) div $80]:=true;
                    char_32_16[(direccion and $ffff) div $100]:=true;
                    char_8_16[(direccion and $ffff) div $40]:=true;
                    char_32_32[(direccion and $ffff) div $200]:=true;
                    char_64_64[(direccion and $ffff) div $800]:=true;
                    fillchar(gfx[0].buffer,$800,1);
                    fillchar(gfx[1].buffer,$800,1);
                    changed_chr:=true;
                 end;
  $50000..$51fff:begin
                    dir:=(direccion and $1fff) shr 1;
                    ram1[dir]:=valor;
                    case (direccion and $1fff) of
                      0..$3ff:xscroll_1[dir and $1ff]:=valor;
                      $400..$7ff:xscroll_2[dir and $1ff]:=valor;
                      $f00..$f7f:yscroll_2[dir and $3f]:=valor;
                      $f80..$fff:yscroll_1[dir and $3f]:=valor;
                    end;
                 end;
  $52000..$52fff:if video1_ram[(direccion and $fff) shr 1]<>valor then begin
                    video1_ram[(direccion and $fff) shr 1]:=valor;
                    gfx[0].buffer[(direccion and $fff) shr 1]:=true;
                 end;
  $53000..$53fff:if video2_ram[(direccion and $fff) shr 1]<>valor then begin
                    video2_ram[(direccion and $fff) shr 1]:=valor;
                    gfx[1].buffer[(direccion and $fff) shr 1]:=true;
                 end;
  $54000..$54fff:if color1_ram[(direccion and $fff) shr 1]<>valor then begin
                    color1_ram[(direccion and $fff) shr 1]:=valor;
                    gfx[0].buffer[(direccion and $fff) shr 1]:=true;
                 end;
  $55000..$55fff:if color2_ram[(direccion and $fff) shr 1]<>valor then begin
                    color2_ram[(direccion and $fff) shr 1]:=valor;
                    gfx[1].buffer[(direccion and $fff) shr 1]:=true;
                 end;
  $56000..$56fff:sprite_ram[(direccion and $fff) shr 1]:=valor;
  $57000..$57fff:ram2[(direccion and $fff) shr 1]:=valor;
  $5a000..$5afff:if buffer_paleta[(direccion and $fff) shr 1]<>valor then begin
                    buffer_paleta[(direccion and $fff) shr 1]:=valor;
                    cambiar_color(valor,(direccion and $fff) shr 1);
                 end;
  $5c000:sound_latch:=valor and $ff;
  $5e000:irq2_on:=(valor and $1)<>0;
  $5e002:irq_on:=(valor and $1)<>0;
  $5e004:begin
            flipx_scr:=(valor and $1)<>0;
            if (valor and $100)<>0 then z80_0.change_irq(HOLD_LINE);
         end;
  $5e006:flipy_scr:=(valor and $1)<>0;
  $5e00e:irq4_on:=(valor and $100)<>0;
  $60000..$7ffff:ram4[(direccion and $1ffff) shr 1]:=valor;
end;
end;

function gx400_snd_getbyte(direccion:word):byte;
var
  ptemp:pbyte;
begin
case direccion of
  0..$1fff:gx400_snd_getbyte:=mem_snd[direccion];
  $4000..$7fff:gx400_snd_getbyte:=shared_ram[direccion and $3fff];
  $8000..$87ff:begin
                  ptemp:=vlm5030_0.get_rom_addr;
                  inc(ptemp,direccion and $7ff);
                  gx400_snd_getbyte:=ptemp^;
               end;
  $e001:gx400_snd_getbyte:=sound_latch;
  $e086:gx400_snd_getbyte:=ay8910_0.Read;
  $e205:gx400_snd_getbyte:=ay8910_1.Read;
end;
end;

procedure gx400_snd_putbyte(direccion:word;valor:byte);
var
  ptemp:pbyte;
begin
case direccion of
  0..$1fff:;
  $4000..$7fff:shared_ram[direccion and $3fff]:=valor;
  $8000..$87ff:begin
                  ptemp:=vlm5030_0.get_rom_addr;
                  inc(ptemp,direccion and $7ff);
                  ptemp^:=valor;
               end;
  $a000..$afff:k005289_0.ld1_w(direccion and $fff,valor);
  $c000..$cfff:k005289_0.ld2_w(direccion and $fff,valor);
  $e000:vlm5030_0.data_w(valor);
  $e003:k005289_0.tg1_w(valor);
  $e004:k005289_0.tg2_w(valor);
  $e005:ay8910_1.Control(valor);
  $e006:ay8910_0.Control(valor);
  $e030:begin
           vlm5030_0.set_st(1);
           vlm5030_0.set_st(0);
        end;
  $e106:ay8910_0.Write(valor);
  $e405:ay8910_1.Write(valor);
end;
end;

function ay0_porta_read_gx400:byte;
var
  res:byte;
begin
  res:=round(z80_0.totalt/1024) and $2f;
  ay0_porta_read_gx400:=res or $d0 or ($20*vlm5030_0.get_bsy);
end;

procedure sound_update_gx400;
begin
  ay8910_0.update;
  ay8910_1.update;
  vlm5030_0.update;
  k005289_0.update;
end;

//Salamander
function salamander_getword(direccion:dword):word;
begin
case direccion of
  0..$7ffff:salamander_getword:=rom[direccion shr 1];
  $80000..$87fff:salamander_getword:=ram3[(direccion and $7fff) shr 1];
  $90000..$91fff:salamander_getword:=buffer_paleta[(direccion and $1fff) shr 1];
  $c0002:salamander_getword:=$ff; //dsw0
  $c2000:salamander_getword:=marcade.in0; //in0
  $c2002:salamander_getword:=marcade.in1; //in1
  $c2004:salamander_getword:=marcade.in2; //in2
  $c2006:salamander_getword:=$42; //dsw1
  $100000..$100fff:salamander_getword:=video2_ram[(direccion and $fff) shr 1];
  $101000..$101fff:salamander_getword:=video1_ram[(direccion and $fff) shr 1];
  $102000..$102fff:salamander_getword:=color2_ram[(direccion and $fff) shr 1];
  $103000..$103fff:salamander_getword:=color1_ram[(direccion and $fff) shr 1];
  $120000..$12ffff:salamander_getword:=(char_ram[(direccion and $ffff) shr 1] shr 8)+((char_ram[(direccion and $ffff) shr 1] and $ff) shl 8);
  $180000..$180fff:salamander_getword:=sprite_ram[(direccion and $fff) shr 1];
  $190000..$191fff:salamander_getword:=ram1[(direccion and $1fff) shr 1];
end;
end;

procedure salamander_putword(direccion:dword;valor:word);
var
  dir:word;

procedure cambiar_color_salamander(numero:word);
var
  color:tcolor;
  tmp_color:word;
begin
  numero:=numero shr 1;
  tmp_color:=(buffer_paleta[numero*2] shl 8) or buffer_paleta[(numero*2)+1];
  color.r:=pal5bit(tmp_color shr 0);
  color.g:=pal5bit(tmp_color shr 5);
  color.b:=pal5bit(tmp_color shr 10);
  set_pal_color(color,numero);
  buffer_color[numero shr 4]:=true;
end;

begin
case direccion of
  0..$7ffff:;
  $80000..$87fff:ram3[(direccion and $7fff) shr 1]:=valor;
  $90000..$91fff:if buffer_paleta[(direccion and $1fff) shr 1]<>(valor and $ff) then begin
                    buffer_paleta[(direccion and $1fff) shr 1]:=valor and $ff;
                    cambiar_color_salamander((direccion and $1fff) shr 1);
                 end;
  $a0000:begin
           irq_on:=(valor and 1)<>0;
           flipx_scr:=(valor and 4)<>0;
           flipy_scr:=(valor and 8)<>0;
           if (valor and $800)<>0 then z80_0.change_irq(HOLD_LINE);
         end;
  $c0000:sound_latch:=valor and $ff;
  $100000..$100fff:if video2_ram[(direccion and $fff) shr 1]<>valor then begin
                    video2_ram[(direccion and $fff) shr 1]:=valor;
                    gfx[1].buffer[(direccion and $fff) shr 1]:=true;
                 end;
  $101000..$101fff:if video1_ram[(direccion and $fff) shr 1]<>valor then begin
                    video1_ram[(direccion and $fff) shr 1]:=valor;
                    gfx[0].buffer[(direccion and $fff) shr 1]:=true;
                 end;
  $102000..$102fff:if color2_ram[(direccion and $fff) shr 1]<>valor then begin
                    color2_ram[(direccion and $fff) shr 1]:=valor;
                    gfx[1].buffer[(direccion and $fff) shr 1]:=true;
                 end;
  $103000..$103fff:if color1_ram[(direccion and $fff) shr 1]<>valor then begin
                    color1_ram[(direccion and $fff) shr 1]:=valor;
                    gfx[0].buffer[(direccion and $fff) shr 1]:=true;
                 end;
  $120000..$12ffff:if char_ram[(direccion and $ffff) shr 1]<>(((valor and $ff) shl 8)+(valor shr 8)) then begin
                    dir:=direccion and $ffff;
                    char_ram[dir shr 1]:=((valor and $ff) shl 8)+(valor shr 8);
                    char_8_8[dir div $20]:=true;
                    char_16_16[dir div $80]:=true;
                    char_32_16[dir div $100]:=true;
                    char_8_16[dir div $40]:=true;
                    char_32_32[dir div $200]:=true;
                    char_64_64[dir div $800]:=true;
                    fillchar(gfx[0].buffer,$800,1);
                    fillchar(gfx[1].buffer,$800,1);
                    changed_chr:=true;
                 end;
  $180000..$180fff:sprite_ram[(direccion and $fff) shr 1]:=valor;
  $190000..$191fff:begin
                    dir:=(direccion and $1fff) shr 1;
                    ram1[dir]:=valor;
                    case (direccion and $1fff) of
                      0..$3ff:xscroll_2[dir and $1ff]:=valor;
                      $400..$7ff:xscroll_1[dir and $1ff]:=valor;
                      $f00..$f7f:yscroll_1[dir and $3f]:=valor;
                      $f80..$fff:yscroll_2[dir and $3f]:=valor;
                    end;
                 end;
end;
end;

function salamander_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$87ff:salamander_snd_getbyte:=mem_snd[direccion];
  $a000:salamander_snd_getbyte:=sound_latch;
  $b000..$b00d:salamander_snd_getbyte:=k007232_0.read(direccion and $f);
  $c001:salamander_snd_getbyte:=ym2151_0.status;
  $e000:begin
          screen_par:=not(screen_par);
          salamander_snd_getbyte:=byte(screen_par);
        end;
end;
end;

procedure salamander_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:;
  $8000..$87ff:mem_snd[direccion]:=valor;
  $b000..$b00d:k007232_0.write(direccion and $f,valor);
  $c000:ym2151_0.reg(valor);
  $c001:ym2151_0.write(valor);
  $d000:vlm5030_0.data_w(valor);
  $f000:begin
          vlm5030_0.set_rst(valor and 1);
          vlm5030_0.set_st(((valor and 2) shr 1));
        end;
end;
end;

procedure nemesis_k007232_cb_0(valor:byte);
begin
  k007232_0.set_volume(0,(valor shr 4)*$11,0);
  k007232_0.set_volume(1,0,(valor and $f)*$11);
end;

procedure sound_update_salamand;
begin
  ym2151_0.update;
  k007232_0.update;
  vlm5030_0.update;
end;

//Main
procedure reset_nemesis;
begin
 m68000_0.reset;
 z80_0.reset;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 case main_vars.tipo_maquina of
  204:begin
        ay8910_0.reset;
        ay8910_1.reset;
        k005289_0.reset;
        marcade.in0:=0;
        marcade.in1:=0;
        marcade.in2:=0;
      end;
  205,260:begin
        ay8910_0.reset;
        ay8910_1.reset;
        k005289_0.reset;
        vlm5030_0.reset;
      end;
  261:begin
        ym2151_0.reset;
        vlm5030_0.reset;
        marcade.in0:=$e0;
        marcade.in1:=0;
        marcade.in2:=0;
      end;
 end;
 reset_video;
 reset_audio;
 irq_on:=false;
 irq2_on:=false;
 irq4_on:=false;
 screen_par:=false;
 flipy_scr:=false;
 flipx_scr:=false;
 fillchar(char_8_8,$800,1);
 fillchar(char_16_16,$200,1);
 fillchar(char_32_16,$100,1);
 fillchar(char_8_16,$400,1);
 fillchar(char_32_32,$80,1);
 fillchar(char_64_64,$20,1);
 changed_chr:=true;
end;

procedure cerrar_nemesis;
begin
if k007232_1_rom<>nil then freemem(k007232_1_rom);
k007232_1_rom:=nil;
end;

function iniciar_nemesis:boolean;
var
  f:byte;
procedure init_ay_sound;
begin
  ay8910_0:=ay8910_chip.create(18432000 div 8,AY8910,1);
  ay8910_1:=ay8910_chip.create(18432000 div 8,AY8910,1);
  ay8910_1.change_io_calls(nil,nil,ay8910_k005289_1,ay8910_k005289_2);
  k005289_0:=k005289_snd_chip.create(3579545,0.5);
  if not(roms_load(@k005289_0.sound_prom,rom_k005289)) then exit;
end;
procedure init_ay_vlm_sound;
begin
  init_ay_sound;
  vlm5030_0:=vlm5030_chip.Create(3579545,$800,2);
end;
begin
llamadas_maquina.close:=cerrar_nemesis;
case main_vars.tipo_maquina of
  204,261:llamadas_maquina.bucle_general:=nemesis_principal;
  205,260:llamadas_maquina.bucle_general:=gx400_principal;
end;
llamadas_maquina.reset:=reset_nemesis;
llamadas_maquina.fps_max:=60.60606060606060;
iniciar_nemesis:=false;
iniciar_audio(false);
for f:=1 to 8 do begin
  screen_init(f,512,256,true);
  screen_mod_scroll(f,512,512,511,256,256,255);
end;
screen_init(9,512,512,false,true);
if main_vars.tipo_maquina=205 then main_screen.rot90_screen:=true;
iniciar_video(256,224);
//Main CPU
m68000_0:=cpu_m68000.create(18432000 div 2,256);
//Sound CPU
z80_0:=cpu_z80.create(14318180 div 4,256);
case main_vars.tipo_maquina of
  204:begin //nemesis
        if not(roms_load16w(@rom,nemesis_rom)) then exit;
        m68000_0.change_ram16_calls(nemesis_getword,nemesis_putword);
        if not(roms_load(@mem_snd,nemesis_sound)) then exit;
        z80_0.change_ram_calls(nemesis_snd_getbyte,nemesis_snd_putbyte);
        z80_0.init_sound(sound_update);
        init_ay_sound;
        ay8910_0.change_io_calls(ay0_porta_read,nil,nil,nil);
  end;
  205:begin //twinbee
        if not(roms_load16w(@bios_rom,gx400_bios)) then exit;
        if not(roms_load16w(@rom,twinbee_rom)) then exit;
        m68000_0.change_ram16_calls(gx400_getword,gx400_putword);
        if not(roms_load(@mem_snd,gx400_sound)) then exit;
        z80_0.change_ram_calls(gx400_snd_getbyte,gx400_snd_putbyte);
        z80_0.init_sound(sound_update_gx400);
        init_ay_vlm_sound;
        ay8910_0.change_io_calls(ay0_porta_read_gx400,nil,nil,nil);
  end;
  260:begin //Galactic Warriors
        if not(roms_load16w(@bios_rom,gx400_bios)) then exit;
        if not(roms_load16w(@rom,gwarrior_rom)) then exit;
        m68000_0.change_ram16_calls(gx400_getword,gx400_putword);
        if not(roms_load(@mem_snd,gx400_sound)) then exit;
        z80_0.change_ram_calls(gx400_snd_getbyte,gx400_snd_putbyte);
        z80_0.init_sound(sound_update_gx400);
        init_ay_vlm_sound;
        ay8910_0.change_io_calls(ay0_porta_read_gx400,nil,nil,nil);
  end;
  261:begin  //Salamander
        if not(roms_load16w(@rom,salamander_rom)) then exit;
        m68000_0.change_ram16_calls(salamander_getword,salamander_putword);
        if not(roms_load(@mem_snd,salamander_sound)) then exit;
        z80_0.change_ram_calls(salamander_snd_getbyte,salamander_snd_putbyte);
        z80_0.init_sound(sound_update_salamand);
        ym2151_0:=ym2151_chip.create(3579545);
        vlm5030_0:=vlm5030_chip.Create(3579545,$4000,1);
        if not(roms_load(vlm5030_0.get_rom_addr,salamander_vlm)) then exit;
        getmem(k007232_1_rom,$20000);
        if not(roms_load(k007232_1_rom,salamander_k007232)) then exit;
        k007232_0:=k007232_chip.create(3579545,k007232_1_rom,$20000,0.20,nemesis_k007232_cb_0);
  end;
end;
//graficos, solo los inicio, los cambia en tiempo real...
init_gfx(0,8,8,$800);
init_gfx(1,16,16,$200);
init_gfx(2,32,16,$100);
init_gfx(3,8,16,$400);
init_gfx(4,32,32,$80);
init_gfx(5,16,32,$100);
init_gfx(6,16,8,$400);
init_gfx(7,64,64,$20);
for f:=0 to 7 do gfx[f].trans[0]:=true;
//final
reset_nemesis;
iniciar_nemesis:=true;
end;

end.
