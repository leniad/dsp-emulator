unit nemesis_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,m68000,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     sound_engine,ay_8910;

procedure Cargar_nemesis;
function iniciar_nemesis:boolean;
procedure reset_nemesis;
procedure cerrar_nemesis;
procedure sound_instruccion;
function ay0_porta_read:byte;
//Nemesis
procedure nemesis_principal;
function nemesis_getword(direccion:dword):word;
procedure nemesis_putword(direccion:dword;valor:word);
function nemesis_snd_getbyte(direccion:word):byte;
procedure nemesis_snd_putbyte(direccion:word;valor:byte);
//GX400
procedure gx400_principal;
function gx400_getword(direccion:dword):word;
procedure gx400_putword(direccion:dword;valor:word);
function gx400_snd_getbyte(direccion:word):byte;
procedure gx400_snd_putbyte(direccion:word;valor:byte);

implementation
type
  tipo_sprite=record
                width,height,char_type:byte;
                mask:word;
              end;

const
        nemesis_rom:array[0..8] of tipo_roms=(
        (n:'456-d01.12a';l:$8000;p:0;crc:$35ff1aaa),(n:'456-d05.12c';l:$8000;p:$1;crc:$23155faa),
        (n:'456-d02.13a';l:$8000;p:$10000;crc:$ac0cf163),(n:'456-d06.13c';l:$8000;p:$10001;crc:$023f22a9),
        (n:'456-d03.14a';l:$8000;p:$20000;crc:$8cefb25f),(n:'456-d07.14c';l:$8000;p:$20001;crc:$d50b82cb),
        (n:'456-d04.15a';l:$8000;p:$30000;crc:$9ca75592),(n:'456-d08.15c';l:$8000;p:$30001;crc:$03c0b7f5),());
        nemesis_sound:tipo_roms=(n:'456-d09.9c';l:$4000;p:0;crc:$26bf9636);
        nemesis_k005289:array[0..2] of tipo_roms=(
        (n:'400-a01.fse';l:$100;p:$0;crc:$002ccf39),(n:'400-a02.fse';l:$100;p:$100;crc:$feafca05),());
        gx400_bios:array[0..2] of tipo_roms=(
        (n:'400-a06.15l';l:$8000;p:0;crc:$b99d8cff),(n:'400-a04.10l';l:$8000;p:$1;crc:$d02c9552),());
        twinbee_rom:array[0..2] of tipo_roms=(
        (n:'412-a07.17l';l:$20000;p:$0;crc:$d93c5499),(n:'412-a05.12l';l:$20000;p:$1;crc:$2b357069),());
        twinbee_sound:tipo_roms=(n:'400-e03.5l';l:$2000;p:0;crc:$a5a8e57d);
        twinbee_k005289:array[0..2] of tipo_roms=(
        (n:'400-a01.fse';l:$100;p:$0;crc:$5827b1e8),(n:'400-a02.fse';l:$100;p:$100;crc:$2f44f970),());
        //Graficos
        pc_x:array[0..7] of dword=(0*4,1*4,2*4,3*4,4*4,5*4,6*4,7*4);
        pc_y:array[0..7] of dword=(0*4*8,1*4*8,2*4*8,3*4*8,4*4*8,5*4*8,6*4*8,7*4*8);
        //0
        sprite0_x:array[0..15] of dword=(0*4,1*4,2*4,3*4,4*4,5*4,6*4,7*4,
                                          8*4,9*4,10*4,11*4,12*4,13*4,14*4,15*4);
        sprite0_y:array[0..15] of dword=(0*4*16,1*4*16,2*4*16,3*4*16,4*4*16,5*4*16,6*4*16,7*4*16,
                                          8*4*16,9*4*16,10*4*16,11*4*16,12*4*16,13*4*16,14*4*16,15*4*16);
        //1
        sprite1_x:array[0..31] of dword=(0*4,1*4,2*4,3*4,4*4,5*4,6*4,7*4,
                                          8*4,9*4,10*4,11*4,12*4,13*4,14*4,15*4,
                                          16*4,17*4,18*4,19*4,20*4,21*4,22*4,23*4,
                                          24*4,25*4,26*4,27*4,28*4,29*4,30*4,31*4);
        sprite1_y:array[0..15] of dword=(0*4*32,1*4*32,2*4*32,3*4*32,4*4*32,5*4*32,6*4*32,7*4*32,
                                          8*4*32,9*4*32,10*4*32,11*4*32,12*4*32,13*4*32,14*4*32,15*4*32);
        //2
        sprite2_y:array[0..31] of dword=(0*4*16,1*4*16,2*4*16,3*4*16,4*4*16,5*4*16,6*4*16,7*4*16,
                                          8*4*16,9*4*16,10*4*16,11*4*16,12*4*16,13*4*16,14*4*16,15*4*16,
                                          16*4*16,17*4*16,18*4*16,19*4*16,20*4*16,21*4*16,22*4*16,23*4*16,
                                          24*4*16,25*4*16,26*4*16,27*4*16,28*4*16,29*4*16,30*4*16,31*4*16);
        //3
        sprite3_y:array[0..31] of dword=(0*4*32,1*4*32,2*4*32,3*4*32,4*4*32,5*4*32,6*4*32,7*4*32,
                                          8*4*32,9*4*32,10*4*32,11*4*32,12*4*32,13*4*32,14*4*32,15*4*32,
                                          16*4*32,17*4*32,18*4*32,19*4*32,20*4*32,21*4*32,22*4*32,23*4*32,
                                          24*4*32,25*4*32,26*4*32,27*4*32,28*4*32,29*4*32,30*4*32,31*4*32);
        //4
        sprite4_y:array[0..15] of dword=(0*4*8,1*4*8,2*4*8,3*4*8,4*4*8,5*4*8,6*4*8,7*4*8,
                                          8*4*8,9*4*8,10*4*8,11*4*8,12*4*8,13*4*8,14*4*8,15*4*8);
        //5
        sprite5_y:array[0..7] of dword=(0*4*16,1*4*16,2*4*16,3*4*16,4*4*16,5*4*16,6*4*16,7*4*16);
        //6
        sprite6_x:array[0..63] of dword=(0*4,1*4,2*4,3*4,4*4,5*4,6*4,7*4,
                                          8*4,9*4,10*4,11*4,12*4,13*4,14*4,15*4,
                                          16*4,17*4,18*4,19*4,20*4,21*4,22*4,23*4,
                                          24*4,25*4,26*4,27*4,28*4,29*4,30*4,31*4,
                                          32*4,33*4,34*4,35*4,36*4,37*4,38*4,39*4,
                                          40*4,41*4,42*4,43*4,44*4,45*4,46*4,47*4,
                                          48*4,49*4,50*4,51*4,52*4,53*4,54*4,55*4,
                                          56*4,57*4,58*4,59*4,60*4,61*4,62*4,63*4);
        sprite6_y:array[0..63] of dword=(0*4*64,1*4*64,2*4*64,3*4*64,4*4*64,5*4*64,6*4*64,7*4*64,
                                          8*4*64,9*4*64,10*4*64,11*4*64,12*4*64,13*4*64,14*4*64,15*4*64,
                                          16*4*64,17*4*64,18*4*64,19*4*64,20*4*64,21*4*64,22*4*64,23*4*64,
                                          24*4*64,25*4*64,26*4*64,27*4*64,28*4*64,29*4*64,30*4*64,31*4*64,
                                          32*4*64,33*4*64,34*4*64,35*4*64,36*4*64,37*4*64,38*4*64,39*4*64,
                                          40*4*64,41*4*64,42*4*64,43*4*64,44*4*64,45*4*64,46*4*64,47*4*64,
                                          48*4*64,49*4*64,50*4*64,51*4*64,52*4*64,53*4*64,54*4*64,55*4*64,
                                          56*4*64,57*4*64,58*4*64,59*4*64,60*4*64,61*4*64,62*4*64,63*4*64);
        //Sprites
        sprite_data:array[0..7] of tipo_sprite=((width:32;height:32;char_type:4;mask:$7f),(width:16;height:32;char_type:5;mask:$ff),(width:32;height:16;char_type:2;mask:$ff),(width:64;height:64;char_type:7;mask:$1f),
                                                (width:8;height:8;char_type:0;mask:$7ff),(width:16;height:8;char_type:6;mask:$3ff),(width:8;height:16;char_type:3;mask:$3ff),(width:16;height:16;char_type:1;mask:$ff));


var
 rom:array[0..$1ffff] of word;
 ram3,bios_rom,char_ram:array[0..$7fff] of word;
 ram1:array[0..$fff] of word;
 ram2:array[0..$3fff] of word;
 ram4:array[0..$ffff] of word;
 shared_ram:array[0..$3fff] of byte;
 xscroll_1,xscroll_2:array[0..$1ff] of word;
 yscroll_1,yscroll_2:array[0..$3f] of word;
 video1_ram,video2_ram,color1_ram,color2_ram,sprite_ram:array[0..$7ff] of word;
 screen_par,irq_on,irq2_on,irq4_on,flipy_char:boolean;
 sound_latch,linea:byte;
 recalc_char:array[0..7] of boolean;

procedure Cargar_nemesis;
begin
llamadas_maquina.iniciar:=iniciar_nemesis;
case main_vars.tipo_maquina of
  204:llamadas_maquina.bucle_general:=nemesis_principal;
  205:llamadas_maquina.bucle_general:=gx400_principal;
end;
llamadas_maquina.cerrar:=cerrar_nemesis;
llamadas_maquina.reset:=reset_nemesis;
llamadas_maquina.fps_max:=60.60606060606060;
end;

function iniciar_nemesis:boolean;
var
  f:byte;
begin
iniciar_nemesis:=false;
iniciar_audio(false);
//Pantallas:  principal+char y sprites
for f:=1 to 8 do begin
  screen_init(f,512,256,true);
  screen_mod_scroll(f,512,512,511,256,256,255);
  //screen_init(f,512,512,true);
  //screen_mod_scroll(f,512,512,511,512,512,511);
end;
screen_init(9,512,256,false,true);
screen_mod_sprites(9,1024,256,1023,255);
//screen_init(9,512,512,false,true);
iniciar_video(256,224);
//Main CPU
main_m68000:=cpu_m68000.create(18432000 div 2,256);
//Sound CPU
snd_z80:=cpu_z80.create(14318180 div 4,256);
snd_z80.init_sound(sound_instruccion);
//Sound Chips
ay8910_0:=ay8910_chip.create(18432000 div 8,1);
ay8910_0.change_io_calls(ay0_porta_read,nil,nil,nil);
ay8910_1:=ay8910_chip.create(18432000 div 8,1);
case main_vars.tipo_maquina of
  204:begin //nemesis
        //cargar roms
        if not(cargar_roms16w(@rom[0],@nemesis_rom[0],'nemesis.zip',0)) then exit;
        if not(cargar_roms(@mem_snd[0],@nemesis_sound,'nemesis.zip')) then exit;
        main_m68000.change_ram16_calls(nemesis_getword,nemesis_putword);
        snd_z80.change_ram_calls(nemesis_snd_getbyte,nemesis_snd_putbyte);
  end;
  205:begin //twinbee
        //cargar roms
        if not(cargar_roms16w(@bios_rom[0],@gx400_bios[0],'twinbee.zip',0)) then exit;
        if not(cargar_roms16w(@rom[0],@twinbee_rom[0],'twinbee.zip',0)) then exit;
        if not(cargar_roms(@mem_snd[0],@twinbee_sound,'twinbee.zip')) then exit;
        main_m68000.change_ram16_calls(gx400_getword,gx400_putword);
        snd_z80.change_ram_calls(gx400_snd_getbyte,gx400_snd_putbyte);
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

procedure cerrar_nemesis;
begin
main_m68000.free;
snd_z80.free;
ay8910_0.Free;
ay8910_1.Free;
close_audio;
close_video;
end;

procedure reset_nemesis;
begin
 main_m68000.reset;
 snd_z80.reset;
 ay8910_0.reset;
 ay8910_1.reset;
 reset_audio;
 marcade.in0:=0;
 marcade.in1:=0;
 marcade.in2:=0;
 irq_on:=false;
 irq2_on:=false;
 irq4_on:=false;
 screen_par:=false;
 fillchar(recalc_char[0],8,1);
 flipy_char:=false;
end;

procedure char_calc(num:byte);
begin
case num of
  0:begin//8x8 char
      gfx_set_desc_data(4,0,4*8*8,0,1,2,3);
      convert_gfx(0,0,@char_ram[0],@pc_x[0],@pc_y[0],false,flipy_char);
  end;
  1:begin//16x16
      gfx_set_desc_data(4,1,4*16*16,0,1,2,3);
      convert_gfx(1,0,@char_ram[0],@sprite0_x[0],@sprite0_y[0],false,flipy_char);
  end;
  2:begin//32x16
      gfx_set_desc_data(4,2,4*32*16,0,1,2,3);
      convert_gfx(2,0,@char_ram[0],@sprite1_x[0],@sprite1_y[0],false,flipy_char);
  end;
  3:begin//16x32
      gfx_set_desc_data(4,3,4*8*16,0,1,2,3);
      convert_gfx(3,0,@char_ram[0],@pc_x[0],@sprite4_y[0],false,flipy_char);
  end;
  4:begin//32x32
      gfx_set_desc_data(4,4,4*32*32,0,1,2,3);
      convert_gfx(4,0,@char_ram[0],@sprite1_x[0],@sprite3_y[0],false,flipy_char);
  end;
  5:begin//8x16
      gfx_set_desc_data(4,5,4*16*32,0,1,2,3);
      convert_gfx(5,0,@char_ram[0],@sprite0_x[0],@sprite3_y[0],false,flipy_char);
  end;
  6:begin//16x8
      gfx_set_desc_data(4,6,4*16*8,0,1,2,3);
      convert_gfx(6,0,@char_ram[0],@sprite0_x[0],@sprite5_y[0],false,flipy_char);
  end;
  7:begin//64x64
      gfx_set_desc_data(4,7,4*64*64,0,1,2,3);
      convert_gfx(7,0,@char_ram[0],@sprite6_x[0],@sprite6_y[0],false,flipy_char);
  end;
end;
recalc_char[num]:=false;
end;

procedure draw_sprites;
var
  f,pri,idx,num_gfx:byte;
  zoom,nchar,size,sx,sy,color,atrib,atrib2:word;
  flipx,flipy:boolean;
begin
{  16 bytes per sprite, in memory from 56000-56fff
	 *
	 *  byte    0 : relative priority.
	 *  byte    2 : size (?) value #E0 means not used., bit 0x01 is flipx
	                0xc0 is upper 2 bits of zoom.
	                0x38 is size.
	 *  byte    4 : zoom = 0xff
	 *  byte    6 : low bits sprite code.
	 *  byte    8 : color + hi bits sprite code., bit 0x20 is flipy bit. bit 0x01 is high bit of X pos.
	 *  byte    A : X position.
	 *  byte    C : Y position.
	 *  byte    E : not used. }
for pri:=$ff downto 0 do begin  //prioridad
  for f:=0 to $ff do begin      //cantidad de sprites
    if((sprite_ram[f*8] and $ff)<>pri) then continue;  //si no tiene la prioridad requerida sigo
    zoom:=sprite_ram[(f*8)+2] and $ff;
    atrib:=sprite_ram[(f*8)+4];
    atrib2:=sprite_ram[(f*8)+3];
    if (((sprite_ram[(f*8)+2] and $ff00)=0) and ((atrib2 and $ff00)<>$ff00)) then nchar:=atrib2+((atrib and $c0) shl 2)
    else nchar:=(atrib2 and $ff)+((atrib and $c0) shl 2);
    if ((zoom<>$ff) or (nchar<>0)) then begin
      size:=sprite_ram[(f*8)+1];
      zoom:=zoom+((size and $c0) shl 2);
      sx:=(sprite_ram[(f*8)+5] and $ff)+((atrib and $1) shl 8);
      sy:=sprite_ram[(f*8)+6] and $ff;
      color:=(atrib and $1e) shl 3;
      flipx:=(size{sprite_ram[(f*8)+1]} and $01)<>0;
      flipy:=(atrib and $20)<>0;
      idx:=(size shr 3) and 7;
      nchar:=nchar*8*16 div (sprite_data[idx].width*sprite_data[idx].height);
      num_gfx:=sprite_data[idx].char_type;
      if recalc_char[num_gfx] then char_calc(num_gfx);
      if (zoom<>0) then begin
        zoom:=((1 shl 16)*$80 div zoom)+$02ab;
        put_gfx_sprite(nchar and sprite_data[idx].mask,color,flipx,flipy,num_gfx);
        actualiza_gfx_sprite(sx,sy,9,num_gfx);
      end;
    end;
  end;
end;
end;

procedure update_video_nemesis;
var
  f,x,y,nchar,color:word;
  flipx,flipy:boolean;
  mask,layer,pant,h:byte;
begin
fill_full_screen(9,0);
if recalc_char[0] then char_calc(0);
for f:=0 to $7ff do begin
    //background
    color:=color2_ram[f] and $7f;
    if (gfx[1].buffer[f] or buffer_color[color]) then begin
      x:=f mod 64;
      y:=f div 64;
      nchar:=video2_ram[f];
      flipx:=(color and $80)<>0;
      flipy:=(nchar and $800)<>0;
      mask:=(nchar and $1000) shr 12;
	    layer:=(nchar and $4000) shr 14;
	    if ((mask<>0) and (layer=0)) then layer:=1;
      pant:=(mask or (layer shl 1))+1;
      if (((not(nchar) and $2000)<>0) or ((nchar and $c000)=$4000)) then begin
        // siempre abajo
        if (nchar and $f800)<>0 then begin
          put_gfx_flip(x*8,y*8,nchar and $7ff,color shl 4,1,0,flipx,flipy);
          for h:=2 to 4 do put_gfx_block_trans(x*8,y*8,h,8,8);
        end else begin
          for h:=1 to 4 do put_gfx_block_trans(x*8,y*8,h,8,8);
        end;
      end else begin
        if (nchar and $f800)<>0 then begin
          put_gfx_trans_flip(x*8,y*8,nchar and $7ff,color shl 4,pant,0,flipx,flipy);
          for h:=1 to 4 do if (h<>pant) then put_gfx_block_trans(x*8,y*8,h,8,8);
        end else begin
          for h:=1 to 4 do put_gfx_block_trans(x*8,y*8,h,8,8);
        end;
      end;
      gfx[1].buffer[f]:=false;
    end;
    //foreground
    color:=color1_ram[f] and $7f;
    if (gfx[0].buffer[f] or buffer_color[color]) then begin
      x:=f mod 64;
      y:=f div 64;
      nchar:=video1_ram[f];
      flipx:=(color and $80)<>0;
      flipy:=(nchar and $800)<>0;
      mask:=(nchar and $1000) shr 12;
	    layer:=(nchar and $4000) shr 14;
	    if ((mask<>0) and (layer=0)) then layer:=1;
      pant:=(mask or (layer shl 1))+5;
      if (((not(nchar) and $2000)<>0) or ((nchar and $c000)=$4000)) then begin
        //siempre abajo
        if (nchar and $f800)<>0 then begin
          put_gfx_trans_flip(x*8,y*8,nchar and $7ff,color shl 4,5,0,flipx,flipy);
          for h:=6 to 8 do put_gfx_block_trans(x*8,y*8,h,8,8);
        end else begin
          for h:=5 to 8 do put_gfx_block_trans(x*8,y*8,h,8,8);
        end;
      end else begin
        if (nchar and $f800)<>0 then begin
          put_gfx_trans_flip(x*8,y*8,nchar and $7ff,color shl 4,pant,0,flipx,flipy);
          for h:=5 to 8 do if (h<>pant) then put_gfx_block_trans(x*8,y*8,h,8,8);
        end else begin
          for h:=5 to 8 do put_gfx_block_trans(x*8,y*8,h,8,8);
        end;
      end;
      gfx[0].buffer[f]:=false;
    end;
end;
for f:=0 to $ff do begin
  //1
  scroll__x_part(1,9,(xscroll_2[f] and $ff)+((xscroll_2[f+$100] and $1) shl 8),0,f,1);
  scroll__x_part(5,9,(xscroll_1[f] and $ff)+((xscroll_1[f+$100] and $1) shl 8),0,f,1);
  //2
  scroll__x_part(2,9,(xscroll_2[f] and $ff)+((xscroll_2[f+$100] and $1) shl 8),0,f,1);
  scroll__x_part(6,9,(xscroll_1[f] and $ff)+((xscroll_1[f+$100] and $1) shl 8),0,f,1);
end;
//Sprites
draw_sprites;
for f:=0 to $ff do begin
  //3
  scroll__x_part(3,9,(xscroll_2[f] and $ff)+((xscroll_2[f+$100] and $1) shl 8),0,f,1);
  scroll__x_part(7,9,(xscroll_1[f] and $ff)+((xscroll_1[f+$100] and $1) shl 8),0,f,1);
  //4
  scroll__x_part(4,9,(xscroll_2[f] and $ff)+((xscroll_2[f+$100] and $1) shl 8),0,f,1);
  scroll__x_part(8,9,(xscroll_1[f] and $ff)+((xscroll_1[f+$100] and $1) shl 8),0,f,1);
end;
actualiza_trozo_final(0,16,256,224,9);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure eventos_nemesis;
begin
if event.arcade then begin
  //IN0
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 or $1) else marcade.in0:=(marcade.in0 and $fe);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 or $2) else marcade.in0:=(marcade.in0 and $fd);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 or $8) else marcade.in0:=(marcade.in0 and $f7);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 or $10) else marcade.in0:=(marcade.in0 and $ef);
  //P1
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 or $1) else marcade.in1:=(marcade.in1 and $fe);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 or $2) else marcade.in1:=(marcade.in1 and $fd);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 or $4) else marcade.in1:=(marcade.in1 and $fb);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 or $8) else marcade.in1:=(marcade.in1 and $f7);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 or $10) else marcade.in1:=(marcade.in1 and $ef);
  if arcade_input.but2[0] then marcade.in1:=(marcade.in1 or $20) else marcade.in1:=(marcade.in1 and $df);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 or $40) else marcade.in1:=(marcade.in1 and $bf);
  //P2
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 or $1) else marcade.in2:=(marcade.in2 and $fe);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 or $2) else marcade.in2:=(marcade.in2 and $fd);
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 or $4) else marcade.in2:=(marcade.in2 and $fb);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 or $8) else marcade.in2:=(marcade.in2 and $f7);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 or $10) else marcade.in2:=(marcade.in2 and $ef);
  if arcade_input.but2[1] then marcade.in2:=(marcade.in2 or $20) else marcade.in2:=(marcade.in2 and $df);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 or $40) else marcade.in2:=(marcade.in2 and $bf);
end;
end;

procedure cambiar_color(tmp_color,numero:word);inline;
var
  bit1,bit2,bit3,bit4,bit5:byte;
  color:tcolor;
begin
  bit1:=(tmp_color shr 0) and 1;
	bit2:=(tmp_color shr 1) and 1;
	bit3:=(tmp_color shr 2) and 1;
	bit4:=(tmp_color shr 3) and 1;
	bit5:=(tmp_color shr 4) and 1;
  color.r:=8*bit1+17*bit2+33*bit3+67*bit4+130*bit5;
  bit1:=(tmp_color shr 5) and 1;
	bit2:=(tmp_color shr 6) and 1;
	bit3:=(tmp_color shr 7) and 1;
	bit4:=(tmp_color shr 8) and 1;
	bit5:=(tmp_color shr 9) and 1;
  color.g:=8*bit1+17*bit2+33*bit3+67*bit4+130*bit5;
  bit1:=(tmp_color shr 10) and 1;
	bit2:=(tmp_color shr 11) and 1;
	bit3:=(tmp_color shr 12) and 1;
	bit4:=(tmp_color shr 13) and 1;
	bit5:=(tmp_color shr 14) and 1;
  color.b:=8*bit1+17*bit2+33*bit3+67*bit4+130*bit5;
  set_pal_color(color,@paleta[numero]);
  buffer_color[numero shr 4]:=true;
end;

function ay0_porta_read:byte;
var
  res:byte;
begin
  res:=round((snd_z80.contador+(linea*snd_z80.tframes))/1024) and $2f;
  res:=res or $d0 or $20;
  ay0_porta_read:=res;
end;

procedure sound_instruccion;
begin
  ay8910_0.update;
  ay8910_1.update;
end;

//Nemesis
procedure nemesis_principal;
var
  frame_m,frame_s:single;
begin
init_controls(false,false,false,true);
frame_m:=main_m68000.tframes;
frame_s:=snd_z80.tframes;
while EmuStatus=EsRuning do begin
 for linea:=0 to $ff do begin
  //Main CPU
  main_m68000.run(frame_m);
  frame_m:=frame_m+main_m68000.tframes-main_m68000.contador;
  //Sound CPU
  snd_z80.run(frame_s);
  frame_s:=frame_s+snd_z80.tframes-snd_z80.contador;
  if linea=239 then begin
    update_video_nemesis;
    if irq_on then main_m68000.irq[1]:=HOLD_LINE;
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
if direccion<$40000 then exit;
case direccion of
  $40000..$4ffff:if char_ram[(direccion and $ffff) shr 1]<>(((valor and $ff) shl 8)+(valor shr 8)) then begin
                    char_ram[(direccion and $ffff) shr 1]:=((valor and $ff) shl 8)+(valor shr 8);
                    fillchar(recalc_char[0],8,1);
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
            //main_screen.flip_main_screen:=(valor and $1)<>0;
            if (valor and $100)<>0 then snd_z80.pedir_irq:=HOLD_LINE;
         end;
  $5e006:if byte(flipy_char)<>(valor and $1) then begin
            flipy_char:=(valor and $1)<>0;
            fillchar(recalc_char[0],8,1);
         end;
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
if direccion<$4000 then exit;
case direccion of
  $4000..$47ff:mem_snd[direccion]:=valor;
  $e005:ay8910_1.Control(valor);
  $e006:ay8910_0.Control(valor);
  $e106:ay8910_0.Write(valor);
  $e405:ay8910_1.Write(valor);
end;
end;

//GX400
procedure gx400_principal;
var
  frame_m,frame_s:single;
begin
init_controls(false,false,false,true);
frame_m:=main_m68000.tframes;
frame_s:=snd_z80.tframes;
while EmuStatus=EsRuning do begin
 for linea:=0 to $ff do begin
  //Main CPU
  main_m68000.run(frame_m);
  frame_m:=frame_m+main_m68000.tframes-main_m68000.contador;
  //Sound CPU
  snd_z80.run(frame_s);
  frame_s:=frame_s+snd_z80.tframes-snd_z80.contador;
  case linea of
    119:if irq4_on then main_m68000.irq[4]:=HOLD_LINE;
    239:begin
          update_video_nemesis;
          if (irq_on and screen_par) then main_m68000.irq[1]:=HOLD_LINE;
          snd_z80.pedir_nmi:=PULSE_LINE;
        end;
    255:if irq2_on then main_m68000.irq[2]:=HOLD_LINE;
  end;
 end;
 screen_par:=not(screen_par);
 eventos_nemesis;
 video_sync;
end;
end;

function gx400_getword(direccion:dword):word;
begin
case direccion of
  0..$ffff:gx400_getword:=bios_rom[direccion shr 1];
  $10000..$1ffff:gx400_getword:=ram3[(direccion and $ffff) shr 1];
  $20000..$27fff:gx400_getword:=shared_ram[(direccion and $7fff) shr 1];
  $30000..$3ffff:gx400_getword:=(char_ram[(direccion and $ffff) shr 1] shr 8)+((char_ram[(direccion and $ffff) shr 1] and $ff) shl 8);//char_ram[(direccion+1) and $ffff] or (char_ram[direccion and $ffff] shl 8);
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
if ((direccion<$10000) or (direccion>$7ffff)) then exit;
case direccion of
  $10000..$1ffff:ram3[(direccion and $ffff) shr 1]:=valor;
  $20000..$27fff:shared_ram[(direccion and $7fff) shr 1]:=valor and $ff;
  $30000..$3ffff:if char_ram[(direccion and $ffff) shr 1]<>(((valor and $ff) shl 8)+(valor shr 8)) then begin
                    char_ram[(direccion and $ffff) shr 1]:=((valor and $ff) shl 8)+(valor shr 8);
                    fillchar(recalc_char[0],8,1);
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
            //main_screen.flip_main_screen:=(valor and $1)<>0;
            if (valor and $100)<>0 then snd_z80.pedir_irq:=HOLD_LINE;
         end;
  $5e006:if byte(flipy_char)<>(valor and $1) then begin
            flipy_char:=(valor and $1)<>0;
            fillchar(recalc_char[0],8,1);
         end;
  $5e00e:irq4_on:=(valor and $100)<>0;
  $60000..$7ffff:ram4[(direccion and $1ffff) shr 1]:=valor;
end;
end;

function gx400_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$1fff:gx400_snd_getbyte:=mem_snd[direccion];
  $4000..$7fff:gx400_snd_getbyte:=shared_ram[direccion and $3fff];
  $e001:gx400_snd_getbyte:=sound_latch;
  $e086:gx400_snd_getbyte:=ay8910_0.Read;
  $e205:gx400_snd_getbyte:=ay8910_1.Read;
end;
end;

procedure gx400_snd_putbyte(direccion:word;valor:byte);
begin
if direccion<$2000 then exit;
case direccion of
  $4000..$7fff:shared_ram[direccion and $3fff]:=valor;
  $e005:ay8910_1.Control(valor);
  $e006:ay8910_0.Control(valor);
  $e106:ay8910_0.Write(valor);
  $e405:ay8910_1.Write(valor);
end;
end;

end.
