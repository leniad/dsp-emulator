unit tecmo_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,gfx_engine,msm5205,ym_3812,rom_engine,
     pal_engine,sound_engine;

procedure Cargar_tecmo;
procedure tecmo_principal;
function iniciar_tecmo:boolean;
procedure reset_tecmo;
procedure cerrar_tecmo;
//Sound
procedure snd_sound_play;
procedure snd_adpcm;
procedure snd_irq(irqstate:byte);
//Rygar
function rygar_getbyte(direccion:word):byte;
procedure rygar_putbyte(direccion:word;valor:byte);
function rygar_snd_getbyte(direccion:word):byte;
procedure rygar_snd_putbyte(direccion:word;valor:byte);
//Silk Worm
function sw_getbyte(direccion:word):byte;
procedure sw_putbyte(direccion:word;valor:byte);
function sw_snd_getbyte(direccion:word):byte;
procedure sw_snd_putbyte(direccion:word;valor:byte);

implementation
const
        //Rygar
        rygar_rom:array[0..3] of tipo_roms=(
        (n:'5.5p';l:$8000;p:0;crc:$062cd55d),(n:'cpu_5m.bin';l:$4000;p:$8000;crc:$7ac5191b),
        (n:'cpu_5j.bin';l:$8000;p:$10000;crc:$ed76d606),());
        rygar_char:tipo_roms=(n:'cpu_8k.bin';l:$8000;p:0;crc:$4d482fb6);
        rygar_tiles1:array[0..4] of tipo_roms=(
        (n:'vid_6p.bin';l:$8000;p:0;crc:$9eae5f8e),(n:'vid_6o.bin';l:$8000;p:$8000;crc:$5a10a396),
        (n:'vid_6n.bin';l:$8000;p:$10000;crc:$7b12cf3f),(n:'vid_6l.bin';l:$8000;p:$18000;crc:$3cea7eaa),());
        rygar_tiles2:array[0..4] of tipo_roms=(
        (n:'vid_6f.bin';l:$8000;p:0;crc:$9840edd8),(n:'vid_6e.bin';l:$8000;p:$8000;crc:$ff65e074),
        (n:'vid_6c.bin';l:$8000;p:$10000;crc:$89868c85),(n:'vid_6b.bin';l:$8000;p:$18000;crc:$35389a7b),());
        rygar_adpcm:tipo_roms=(n:'cpu_1f.bin';l:$4000;p:0;crc:$3cc98c5a);
        rygar_sound:tipo_roms=(n:'cpu_4h.bin';l:$2000;p:0;crc:$e4a2fa87);
        rygar_sprites:array[0..4] of tipo_roms=(
        (n:'vid_6k.bin';l:$8000;p:0;crc:$aba6db9e),(n:'vid_6j.bin';l:$8000;p:$8000;crc:$ae1f2ed6),
        (n:'vid_6h.bin';l:$8000;p:$10000;crc:$46d9e7df),(n:'vid_6g.bin';l:$8000;p:$18000;crc:$45839c9a),());
        //Silkworm
        sw_rom:array[0..2] of tipo_roms=(
        (n:'silkworm.4';l:$10000;p:0;crc:$a5277cce),(n:'silkworm.5';l:$10000;p:$10000;crc:$a6c7bb51),());
        sw_char:tipo_roms=(n:'silkworm.2';l:$8000;p:0;crc:$e80a1cd9);
        sw_tiles1:array[0..4] of tipo_roms=(
        (n:'silkworm.10';l:$10000;p:0;crc:$8c7138bb),(n:'silkworm.11';l:$10000;p:$10000;crc:$6c03c476),
        (n:'silkworm.12';l:$10000;p:$20000;crc:$bb0f568f),(n:'silkworm.13';l:$10000;p:$30000;crc:$773ad0a4),());
        sw_tiles2:array[0..4] of tipo_roms=(
        (n:'silkworm.14';l:$10000;p:0;crc:$409df64b),(n:'silkworm.15';l:$10000;p:$10000;crc:$6e4052c9),
        (n:'silkworm.16';l:$10000;p:$20000;crc:$9292ed63),(n:'silkworm.17';l:$10000;p:$30000;crc:$3fa4563d),());
        sw_adpcm:tipo_roms=(n:'silkworm.1';l:$8000;p:0;crc:$5b553644);
        sw_sound:tipo_roms=(n:'silkworm.3';l:$8000;p:0;crc:$b589f587);
        sw_sprites:array[0..4] of tipo_roms=(
        (n:'silkworm.6';l:$10000;p:0;crc:$1138d159),(n:'silkworm.7';l:$10000;p:$10000;crc:$d96214f7),
        (n:'silkworm.8';l:$10000;p:$20000;crc:$0494b38e),(n:'silkworm.9';l:$10000;p:$30000;crc:$8ce3cdf5),());
        //Dip
        rygar_dip_a:array [0..4] of def_dip=(
        (mask:$3;name:'Coin A';number:4;dip:((dip_val:$1;dip_name:'2C 1C'),(dip_val:$0;dip_name:'1C 1C'),(dip_val:$2;dip_name:'1C 2C'),(dip_val:$3;dip_name:'1C 3C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Coin B';number:4;dip:((dip_val:$4;dip_name:'2C 1C'),(dip_val:$0;dip_name:'1C 1C'),(dip_val:$8;dip_name:'1C 2C'),(dip_val:$c;dip_name:'1C 3C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Lives';number:4;dip:((dip_val:$30;dip_name:'2'),(dip_val:$0;dip_name:'3'),(dip_val:$10;dip_name:'4'),(dip_val:$20;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Cabinet';number:2;dip:((dip_val:$40;dip_name:'Upright'),(dip_val:$0;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        rygar_dip_b:array [0..4] of def_dip=(
        (mask:$3;name:'Bonus Life';number:4;dip:((dip_val:$0;dip_name:'50k 200k 500k'),(dip_val:$1;dip_name:'100k 300k 600k'),(dip_val:$2;dip_name:'200k 500k'),(dip_val:$3;dip_name:'100k'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Difficulty';number:4;dip:((dip_val:$0;dip_name:'Easy'),(dip_val:$10;dip_name:'Normal'),(dip_val:$30;dip_name:'Hard'),(dip_val:$30;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'2P Can Start Anytime';number:2;dip:((dip_val:$40;dip_name:'Yes'),(dip_val:$0;dip_name:'No'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Allow Continue';number:2;dip:((dip_val:$80;dip_name:'Yes'),(dip_val:$0;dip_name:'No'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        sw_dip_a:array [0..4] of def_dip=(
        (mask:$3;name:'Coin A';number:4;dip:((dip_val:$1;dip_name:'2C 1C'),(dip_val:$0;dip_name:'1C 1C'),(dip_val:$2;dip_name:'1C 2C'),(dip_val:$3;dip_name:'1C 3C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Coin B';number:4;dip:((dip_val:$4;dip_name:'2C 1C'),(dip_val:$0;dip_name:'1C 1C'),(dip_val:$8;dip_name:'1C 2C'),(dip_val:$c;dip_name:'1C 3C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Lives';number:4;dip:((dip_val:$30;dip_name:'2'),(dip_val:$0;dip_name:'3'),(dip_val:$10;dip_name:'4'),(dip_val:$20;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Demo Sounds';number:2;dip:((dip_val:$80;dip_name:'On'),(dip_val:$0;dip_name:'Off'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        sw_dip_b:array [0..3] of def_dip=(
        (mask:$7;name:'Bonus Life';number:8;dip:((dip_val:$0;dip_name:'50k 200k 500k'),(dip_val:$1;dip_name:'100k 300k 800k'),(dip_val:$2;dip_name:'50k 200k'),(dip_val:$3;dip_name:'100k 300k'),(dip_val:$4;dip_name:'50k'),(dip_val:$5;dip_name:'100k'),(dip_val:$6;dip_name:'200k'),(dip_val:$7;dip_name:'None'),(),(),(),(),(),(),(),())),
        (mask:$70;name:'Difficulty';number:5;dip:((dip_val:$10;dip_name:'1'),(dip_val:$20;dip_name:'2'),(dip_val:$30;dip_name:'3'),(dip_val:$40;dip_name:'4'),(dip_val:$50;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Allow Continue';number:2;dip:((dip_val:$80;dip_name:'No'),(dip_val:$0;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 mem_adpcm:array[0..$7fff] of byte;
 bank_rom:array[0..$1f,0..$7ff] of byte;
 adpcm_end,adpcm_pos,adpcm_data,scroll_x1,scroll_x2:word;
 nbank_rom,scroll_y1,scroll_y2,soundlatch,tipo_video:byte;
 bg_ram,fg_ram:array[0..$3ff] of byte;
 txt_ram:array[0..$7ff] of byte;

procedure Cargar_tecmo;
begin
llamadas_maquina.iniciar:=iniciar_tecmo;
llamadas_maquina.bucle_general:=tecmo_principal;
llamadas_maquina.cerrar:=cerrar_tecmo;
llamadas_maquina.reset:=reset_tecmo;
end;

function iniciar_tecmo:boolean;
const
  ps_x:array[0..15] of dword=(0*4, 1*4, 2*4, 3*4, 4*4, 5*4, 6*4, 7*4,
			32*8+0*4, 32*8+1*4, 32*8+2*4, 32*8+3*4, 32*8+4*4, 32*8+5*4, 32*8+6*4, 32*8+7*4);
  ps_y:array[0..15] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32,
			16*32, 17*32, 18*32, 19*32, 20*32, 21*32, 22*32, 23*32);
  pc_x:array[0..7] of dword=(0*4, 1*4, 2*4, 3*4, 4*4, 5*4, 6*4, 7*4);
  pc_y:array[0..7] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32);
var
  memoria_temp:array[0..$7ffff] of byte;
  f:byte;

procedure char_convert(num:word);
begin
  init_gfx(0,8,8,num);
  gfx[0].trans[0]:=true;
  gfx_set_desc_data(4,0,32*8,0,1,2,3);
  convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,false);
end;

procedure sprite_convert(num:word);
begin
  init_gfx(2,8,8,num);
  gfx[2].trans[0]:=true;
  gfx_set_desc_data(4,0,32*8,0,1,2,3);
  convert_gfx(2,0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,false);
end;

procedure tile_convert(ngfx:byte;num:word);
begin
  init_gfx(ngfx,16,16,num);
  gfx[ngfx].trans[0]:=true;
  gfx_set_desc_data(4,0,128*8,0,1,2,3);
  convert_gfx(ngfx,0,@memoria_temp[0],@ps_x[0],@ps_y[0],false,false);
end;

begin
iniciar_tecmo:=false;
iniciar_audio(false);
//Pantallas:  principal+char y sprites
screen_init(1,512,256,false,true);
screen_init(2,512,256,true);
screen_mod_scroll(2,512,256+48,511,256,256,255);
screen_init(6,256,256,true); //chars
//foreground
screen_init(7,512,256,true);
screen_mod_scroll(7,512,256+48,511,256,256,255);
iniciar_video(256,224);
//Main CPU
main_z80:=cpu_z80.create(6000000,$100);
//Sound CPU
snd_z80:=cpu_z80.create(4000000,$100);
snd_z80.init_sound(snd_sound_play);
//Sound Chip
msm_5205_0:=MSM5205_chip.create(0,400000,MSM5205_S48_4B,0.5,snd_adpcm);
ym3812_init(0,4000000,snd_irq,6);
//cargar roms
case main_vars.tipo_maquina of
  26:begin
      //Main
      main_z80.change_ram_calls(rygar_getbyte,rygar_putbyte);
      //Sound
      snd_z80.change_ram_calls(rygar_snd_getbyte,rygar_snd_putbyte);
      //Video
      tipo_video:=0;
      if not(cargar_roms(@memoria_temp[0],@rygar_rom[0],'rygar.zip',0)) then exit;
      copymemory(@memoria[0],@memoria_temp[0],$c000);
      for f:=0 to $1f do copymemory(@bank_rom[f,0],@memoria_temp[$10000+(f*$800)],$800);
      //cargar sonido
      if not(cargar_roms(@mem_snd[0],@rygar_sound,'rygar.zip')) then exit;
      if not(cargar_roms(@mem_adpcm[0],@rygar_adpcm,'rygar.zip')) then exit;
      //convertir chars
      if not(cargar_roms(@memoria_temp[0],@rygar_char,'rygar.zip')) then exit;
      char_convert(1024);
      //Sprites
      if not(cargar_roms(@memoria_temp[0],@rygar_sprites[0],'rygar.zip',0)) then exit;
      sprite_convert(4096);
      //foreground
      if not(cargar_roms(@memoria_temp[0],@rygar_tiles1[0],'rygar.zip',0)) then exit;
      tile_convert(1,$400);
      //background
      if not(cargar_roms(@memoria_temp[0],@rygar_tiles2[0],'rygar.zip',0)) then exit;
      tile_convert(3,$400);
      //DIP
      marcade.dswa:=$40;
      marcade.dswb:=$80;
      marcade.dswa_val:=@rygar_dip_a;
      marcade.dswb_val:=@rygar_dip_b;
  end;
  97:begin  //Silk Worm
      //Main
      main_z80.change_ram_calls(sw_getbyte,sw_putbyte);
      //Sound
      snd_z80.change_ram_calls(sw_snd_getbyte,sw_snd_putbyte);
      //Video
      tipo_video:=1;
      if not(cargar_roms(@memoria_temp[0],@sw_rom[0],'silkworm.zip',0)) then exit;
      copymemory(@memoria[0],@memoria_temp[0],$10000);
      for f:=0 to $1f do copymemory(@bank_rom[f,0],@memoria_temp[$10000+(f*$800)],$800);
      //cargar sonido
      if not(cargar_roms(@mem_snd[0],@sw_sound,'silkworm.zip')) then exit;
      if not(cargar_roms(@mem_adpcm[0],@sw_adpcm,'silkworm.zip')) then exit;
      //convertir chars
      if not(cargar_roms(@memoria_temp[0],@sw_char,'silkworm.zip')) then exit;
      char_convert($400);
      //Sprites
      if not(cargar_roms(@memoria_temp[0],@sw_sprites[0],'silkworm.zip',0)) then exit;
      sprite_convert($2000);
      //background
      if not(cargar_roms(@memoria_temp[0],@sw_tiles1[0],'silkworm.zip',0)) then exit;
      tile_convert(1,$800);
      //foreground
      if not(cargar_roms(@memoria_temp[0],@sw_tiles2[0],'silkworm.zip',0)) then exit;
      tile_convert(3,$800);
      //DIP
      marcade.dswa:=$80;
      marcade.dswb:=$30;
      marcade.dswa_val:=@sw_dip_a;
      marcade.dswb_val:=@sw_dip_b;
     end;
end;
reset_tecmo;
iniciar_tecmo:=true;
end;

procedure cerrar_tecmo;
begin
main_z80.free;
snd_z80.free;
msm_5205_0.Free;
ym3812_close(0);
close_audio;
close_video;
end;

procedure reset_tecmo;
begin
 main_z80.reset;
 snd_z80.reset;
 ym3812_reset(0);
 msm_5205_0.reset;
 reset_audio;
 adpcm_end:=0;
 adpcm_pos:=0;
 adpcm_data:=$100;
 marcade.in0:=0;
 marcade.in1:=0;
 marcade.in2:=0;
 marcade.in3:=0;
 marcade.in4:=0;
 nbank_rom:=0;
 scroll_x1:=0;
 scroll_x2:=0;
 scroll_y1:=0;
 scroll_y2:=0;
 soundlatch:=0;
end;

procedure draw_sprites(prioridad:byte);
const
  layout:array[0..7,0..7] of byte = (
		(0,1,4,5,16,17,20,21),
		(2,3,6,7,18,19,22,23),
		(8,9,12,13,24,25,28,29),
		(10,11,14,15,26,27,30,31),
		(32,33,36,37,48,49,52,53),
		(34,35,38,39,50,51,54,55),
		(40,41,44,45,56,57,60,61),
		(42,43,46,47,58,59,62,63));
var
  nchar,dx,dy,sx,sy,x,y,f,color,size:word;
  flags,bank:byte;
  flipx,flipy:boolean;
begin
for f:=0 to $ff do begin
 flags:=memoria[$e003+(f*8)];
 if prioridad=(flags shr 6) then begin
  bank:=memoria[$e000+(f*8)];
  if (bank and 4)<>0 then begin //sprite visible
    if tipo_video=1 then nchar:=memoria[$e001+(f*8)]+((bank and $f8) shl 5)
      else nchar:=memoria[$e001+(f*8)]+((bank and $f0) shl 4);
    size:=memoria[$e002+(f*8)] and 3;
    nchar:=nchar and (not((1 shl (size*2))-1));
    size:=1 shl size;
    dx:=memoria[$e005+(f*8)]-((flags and $10) shl 4);
    dy:=memoria[$e004+(f*8)]-((flags and $20) shl 3);
    color:=(flags and $f) shl 4;
    flipx:=(bank and $1)<>0;
    flipy:=(bank and $2)<>0;
    for y:=0 to (size-1) do begin
				for x:=0 to (size-1) do begin
          if flipx then sx:=dx+8*(size-1-x)
              else sx:=dx+8*x;
          if flipy then sy:=dy+8*(size-1-y)
              else sy:=dy+8*y;
          put_gfx_sprite(nchar+layout[y,x],color,flipx,flipy,2);
          actualiza_gfx_sprite(sx+48,sy,1,2);
        end;
    end;
  end;
 end;
end;
end;

procedure update_video_tecmo;
var
        f,color,nchar:word;
        x,y:word;
        atrib:byte;
begin
//chars
for f:=0 to $3ff do begin
  atrib:=txt_ram[$400+f];
  color:=atrib shr 4;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
      x:=f mod 32;
      y:=f div 32;
      nchar:=txt_ram[f]+((atrib and $3) shl 8);
      put_gfx_trans(x*8,y*8,nchar,(color shl 4)+$100,6,0);
      gfx[0].buffer[f]:=false;
  end;
end;
for f:=0 to $1ff do begin
    //Background
    atrib:=bg_ram[$200+f];
    color:=atrib shr 4;
    if (gfx[3].buffer[f] or buffer_color[color+$20]) then begin
        x:=f mod 32;
        y:=f div 32;
        nchar:=bg_ram[f]+((atrib and $7) shl 8);
        put_gfx_trans(x*16,y*16,nchar,(color shl 4)+$300,2,3);
        gfx[3].buffer[f]:=false;
    end;
    //Delante
    atrib:=fg_ram[$200+f];
    color:=atrib shr 4;
    if (gfx[1].buffer[f] or buffer_color[color+$10]) then begin
        x:=f mod 32;
        y:=f div 32;
        nchar:=fg_ram[f]+((atrib and $7) shl 8);
        put_gfx_trans(x*16,y*16,nchar,(color shl 4)+$200,7,1);
        gfx[1].buffer[f]:=false;
    end;
end;
fill_full_screen(1,$100);
draw_sprites(3);
scroll_x_y(2,1,scroll_x2,scroll_y2);
draw_sprites(2);
scroll_x_y(7,1,scroll_x1,scroll_y1);
draw_sprites(1);
actualiza_trozo(0,0,256,256,6,48,0,256,256,1);
draw_sprites(0);
actualiza_trozo_final(48,16,256,224,1);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure eventos_tecmo;
begin
if event.arcade then begin
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 or 4) else marcade.in0:=(marcade.in0 and $fb);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 or 8) else marcade.in0:=(marcade.in0 and $f7);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 or 1) else marcade.in0:=(marcade.in0 and $fe);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 or 2) else marcade.in0:=(marcade.in0 and $fd);
  if arcade_input.down[1] then marcade.in3:=(marcade.in3 or 4) else marcade.in3:=(marcade.in3 and $fb);
  if arcade_input.up[1] then marcade.in3:=(marcade.in3 or 8) else marcade.in3:=(marcade.in3 and $f7);
  if arcade_input.left[1] then marcade.in3:=(marcade.in3 or 1) else marcade.in3:=(marcade.in3 and $fe);
  if arcade_input.right[1] then marcade.in3:=(marcade.in3 or 2) else marcade.in3:=(marcade.in3 and $fd);
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 or 2) else marcade.in2:=(marcade.in2 and $fd);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 or 1) else marcade.in2:=(marcade.in2 and $fe);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 or 4) else marcade.in2:=(marcade.in2 and $fb);
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 or 8) else marcade.in2:=(marcade.in2 and $f7);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 or $1) else marcade.in1:=(marcade.in1 and $fe);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 or $2) else marcade.in1:=(marcade.in1 and $fd);
  if arcade_input.but1[1] then marcade.in4:=(marcade.in4 or $1) else marcade.in4:=(marcade.in4 and $fe);
  if arcade_input.but0[1] then marcade.in4:=(marcade.in4 or $2) else marcade.in4:=(marcade.in4 and $fd);
end;
end;

procedure tecmo_principal;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=main_z80.tframes;
frame_s:=snd_z80.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
    //Main CPU
    main_z80.run(frame_m);
    frame_m:=frame_m+main_z80.tframes-main_z80.contador;
    //Sound CPU
    snd_z80.run(frame_s);
    frame_s:=frame_s+snd_z80.tframes-snd_z80.contador;
    if f=239 then begin
      main_z80.pedir_irq:=HOLD_LINE;
      update_video_tecmo;
    end;
  end;
  eventos_tecmo;
  video_sync;
end;
end;

procedure cambiar_color(numero:word);inline;
var
  color:tcolor;
  valor:byte;
begin
  valor:=buffer_paleta[numero];
  color.b:=pal4bit(valor);
  valor:=buffer_paleta[1+numero];
  color.g:=pal4bit(valor);
  color.r:=pal4bit(valor shr 4);
  numero:=numero shr 1;
  set_pal_color(color,@paleta[numero]);
  case numero of
    256..511:buffer_color[(numero shr 4) and $f]:=true;
    512..767:buffer_color[((numero shr 4) and $f)+$10]:=true;
    768..1023:buffer_color[((numero shr 4) and $f)+$20]:=true;
  end;
end;

function rygar_getbyte(direccion:word):byte;
begin
case direccion of
  0..$cfff,$e000..$e7ff:rygar_getbyte:=memoria[direccion];
  $d000..$d7ff:rygar_getbyte:=txt_ram[direccion and $7ff];
  $d800..$dbff:rygar_getbyte:=fg_ram[direccion and $3ff];
  $dc00..$dfff:rygar_getbyte:=bg_ram[direccion and $3ff];
  $e800..$efff:rygar_getbyte:=buffer_paleta[direccion and $7ff];
  $f000..$f7ff:rygar_getbyte:=bank_rom[nbank_rom,direccion and $7ff];
  $f800:rygar_getbyte:=marcade.in0;
  $f801:rygar_getbyte:=marcade.in1;
  $f802:rygar_getbyte:=marcade.in3;
  $f803:rygar_getbyte:=marcade.in4;
  $f804:rygar_getbyte:=marcade.in2;
  $f805,$f80f:rygar_getbyte:=0;
  $f806:rygar_getbyte:=marcade.dswa and $f;
  $f807:rygar_getbyte:=(marcade.dswa shr 4) and $f;
  $f808:rygar_getbyte:=marcade.dswb and $f;
  $f809:rygar_getbyte:=(marcade.dswb shr 4) and $f;
end;
end;

procedure rygar_putbyte(direccion:word;valor:byte);
begin
if ((direccion<$c000) or ((direccion>$efff) and (direccion<$f800))) then exit;
case direccion of
    $c000..$cfff,$e000..$e7ff:memoria[direccion]:=valor;
    $d000..$d7ff:if txt_ram[direccion and $7ff]<>valor then begin
                    gfx[0].buffer[direccion and $3ff]:=true;
                    txt_ram[direccion and $7ff]:=valor;
                 end;
    $d800..$dbff:if fg_ram[direccion and $3ff]<>valor then begin
                    gfx[1].buffer[direccion and $1ff]:=true;
                    fg_ram[direccion and $3ff]:=valor;
                 end;
    $dc00..$dfff:if bg_ram[direccion and $3ff]<>valor then begin
                    gfx[3].buffer[direccion and $1ff]:=true;
                    bg_ram[direccion and $3ff]:=valor;
                 end;
    $e800..$efff:if buffer_paleta[direccion and $7ff]<>valor then begin
                    buffer_paleta[direccion and $7ff]:=valor;
                    cambiar_color(direccion and $7fe);
                 end;
    $f800:scroll_x1:=(scroll_x1 and $100) or valor;
    $f801:scroll_x1:=(scroll_x1 and $ff) or ((valor and 1) shl 8);
    $f802:scroll_y1:=valor;
    $f803:scroll_x2:=(scroll_x2 and $100) or valor;
    $f804:scroll_x2:=(scroll_x2 and $ff) or ((valor and 1) shl 8);
    $f805:scroll_y2:=valor;
    $f806:begin
            soundlatch:=valor;
            snd_z80.pedir_nmi:=ASSERT_LINE;
          end;
    $f807:main_screen.flip_main_screen:=(valor and $1)<>0;
    $f808:nbank_rom:=(valor and $f8) shr 3;
end;
end;

function rygar_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$47ff:rygar_snd_getbyte:=mem_snd[direccion];
  $c000:rygar_snd_getbyte:=soundlatch
end;
end;

procedure rygar_snd_putbyte(direccion:word;valor:byte);
begin
if direccion<$4000 then exit;
  case direccion of
     $4000..$47ff:mem_snd[direccion]:=valor;
     $8000:ym3812_control_port(0,valor);
     $8001:ym3812_write_port(0,valor);
     $c000:begin
              adpcm_pos:=(valor shl 8);
              msm_5205_0.reset_w(0);
           end;
     $d000:adpcm_end:=((valor+1) shl 8);
     //$e000:volumen
     $f000:snd_z80.clear_nmi;
  end;
end;

//Silkworm
function sw_getbyte(direccion:word):byte;
begin
case direccion of
  0..$bfff,$d000..$e7ff:sw_getbyte:=memoria[direccion];
  $c000..$c3ff:sw_getbyte:=bg_ram[direccion and $3ff];
  $c400..$c7ff:sw_getbyte:=fg_ram[direccion and $3ff];
  $c800..$cfff:sw_getbyte:=txt_ram[direccion and $7ff];
  $e800..$efff:sw_getbyte:=buffer_paleta[direccion and $7ff];
  $f000..$f7ff:sw_getbyte:=bank_rom[nbank_rom,direccion and $7ff];
  $f800:sw_getbyte:=marcade.in0;
  $f801:sw_getbyte:=marcade.in1;
  $f802:sw_getbyte:=marcade.in3;
  $f803:sw_getbyte:=marcade.in4;
  $f804:sw_getbyte:=0;
  $f806:sw_getbyte:=marcade.dswa and $f;
  $f807:sw_getbyte:=(marcade.dswa shr 4) and $f;
  $f808:sw_getbyte:=marcade.dswb and $f;
  $f809:sw_getbyte:=(marcade.dswb shr 4) and $f;
  $f80f:sw_getbyte:=marcade.in2;
end;
end;

procedure sw_putbyte(direccion:word;valor:byte);
begin
if ((direccion<$c000) or ((direccion>$efff) and (direccion<$f800))) then exit;
case direccion of
    $c000..$c3ff:if bg_ram[direccion and $3ff]<>valor then begin
                    gfx[3].buffer[direccion and $1ff]:=true;
                    bg_ram[direccion and $3ff]:=valor;
                 end;
    $c400..$c7ff:if fg_ram[direccion and $3ff]<>valor then begin
                    gfx[1].buffer[direccion and $1ff]:=true;
                    fg_ram[direccion and $3ff]:=valor;
                 end;
    $c800..$cfff:if txt_ram[direccion and $7ff]<>valor then begin
                    gfx[0].buffer[direccion and $3ff]:=true;
                    txt_ram[direccion and $7ff]:=valor;
                 end;
    $d000..$e7ff:memoria[direccion]:=valor;
    $e800..$efff:if buffer_paleta[direccion and $7ff]<>valor then begin
                    buffer_paleta[direccion and $7ff]:=valor;
                    cambiar_color(direccion and $7fe);
                 end;
    $f800:scroll_x1:=(scroll_x1 and $100) or valor;
    $f801:scroll_x1:=(scroll_x1 and $ff) or ((valor and 1) shl 8);
    $f802:scroll_y1:=valor;
    $f803:scroll_x2:=(scroll_x2 and $100) or valor;
    $f804:scroll_x2:=(scroll_x2 and $ff) or ((valor and 1) shl 8);
    $f805:scroll_y2:=valor;
    $f806:begin
            soundlatch:=valor;
            snd_z80.pedir_nmi:=ASSERT_LINE;
          end;
    $f807:main_screen.flip_main_screen:=(valor and $1)<>0;
    $f808:nbank_rom:=(valor and $f8) shr 3;
end;
end;

function sw_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$87ff:sw_snd_getbyte:=mem_snd[direccion];
  $c000:sw_snd_getbyte:=soundlatch
end;
end;

procedure sw_snd_putbyte(direccion:word;valor:byte);
begin
if direccion<$8000 then exit;
  case direccion of
     $8000..$87ff:mem_snd[direccion]:=valor;
     $a000:ym3812_control_port(0,valor);
     $a001:ym3812_write_port(0,valor);
     $c000:begin
              adpcm_pos:=(valor shl 8);
              msm_5205_0.reset_w(0);
           end;
     $c400:adpcm_end:=((valor+1) shl 8);
     //$c800:volumen
     $cc00:snd_z80.clear_nmi;
  end;
end;

procedure snd_irq(irqstate:byte);
begin
  if (irqstate<>0) then snd_z80.pedir_irq:=ASSERT_LINE
    else snd_z80.pedir_irq:=CLEAR_LINE;
end;

procedure snd_sound_play;
begin
  YM3812_Update(0);
end;

procedure snd_adpcm;
begin
if ((adpcm_pos>=adpcm_end) or	(adpcm_pos>$7fff)) then begin
  msm_5205_0.reset_w(1);
  exit;
end;
if (adpcm_data and $100)=0 then begin
		msm_5205_0.data_w(adpcm_data and $0f);
    adpcm_pos:=adpcm_pos+1;
		adpcm_data:=$100;
end	else begin
		adpcm_data:=mem_adpcm[adpcm_pos];
    msm_5205_0.data_w((adpcm_data and $f0) shr 4);
end;
end;

end.
