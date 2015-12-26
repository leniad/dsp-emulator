unit legendarywings_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,ym_2203,gfx_engine,msm5205,
     rom_engine,pal_engine,sound_engine,timer_engine;

procedure Cargar_hlwings;
procedure lwings_principal;
function iniciar_lwings:boolean;
procedure reset_lwings;
procedure cerrar_lwings;
//Legendary Wings
function lwings_getbyte(direccion:word):byte;
procedure lwings_putbyte(direccion:word;valor:byte);
function lwings_snd_getbyte(direccion:word):byte;
procedure lwings_snd_putbyte(direccion:word;valor:byte);
procedure lwings_sound_update;
procedure lwings_snd_irq;
//Trojan
procedure trojan_principal;
function trojan_misc_getbyte(direccion:word):byte;
procedure trojan_misc_putbyte(direccion:word;valor:byte);
procedure trojan_putbyte(direccion:word;valor:byte);
function trojan_inbyte(puerto:word):byte;
procedure trojan_outbyte(valor:byte;puerto:word);
procedure trojan_adpcm_instruccion;

implementation
const
        //legendary wings
        lwings_rom:array[0..3] of tipo_roms=(
        (n:'6c_lw01.bin';l:$8000;p:0;crc:$b55a7f60),(n:'7c_lw02.bin';l:$8000;p:$8000;crc:$a5efbb1b),
        (n:'9c_lw03.bin';l:$8000;p:$10000;crc:$ec5cc201),());
        lwings_snd_rom:tipo_roms=(n:'11e_lw04.bin';l:$8000;p:0;crc:$a20337a2);
        lwings_char:tipo_roms=(n:'9h_lw05.bin';l:$4000;p:0;crc:$091d923c);
        lwings_sprites:array[0..4] of tipo_roms=(
        (n:'3j_lw17.bin';l:$8000;p:0;crc:$5ed1bc9b),(n:'1j_lw11.bin';l:$8000;p:$8000;crc:$2a0790d6),
        (n:'3h_lw16.bin';l:$8000;p:$10000;crc:$e8834006),(n:'1h_lw10.bin';l:$8000;p:$18000;crc:$b693f5a5),());
        lwings_tiles:array[0..8] of tipo_roms=(
        (n:'3e_lw14.bin';l:$8000;p:0;crc:$5436392c),(n:'1e_lw08.bin';l:$8000;p:$8000;crc:$b491bbbb),
        (n:'3d_lw13.bin';l:$8000;p:$10000;crc:$fdd1908a),(n:'1d_lw07.bin';l:$8000;p:$18000;crc:$5c73d406),
        (n:'3b_lw12.bin';l:$8000;p:$20000;crc:$32e17b3c),(n:'1b_lw06.bin';l:$8000;p:$28000;crc:$52e533c1),
        (n:'3f_lw15.bin';l:$8000;p:$30000;crc:$99e134ba),(n:'1f_lw09.bin';l:$8000;p:$38000;crc:$c8f28777),());
        //section Z
        sectionz_rom:array[0..3] of tipo_roms=(
        (n:'6c_sz01.bin';l:$8000;p:0;crc:$69585125),(n:'7c_sz02.bin';l:$8000;p:$8000;crc:$22f161b8),
        (n:'9c_sz03.bin';l:$8000;p:$10000;crc:$4c7111ed),());
        sectionz_snd_rom:tipo_roms=(n:'11e_sz04.bin';l:$8000;p:0;crc:$a6073566);
        sectionz_char:tipo_roms=(n:'9h_sz05.bin';l:$4000;p:0;crc:$3173ba2e);
        sectionz_sprites:array[0..4] of tipo_roms=(
        (n:'3j_sz17.bin';l:$8000;p:0;crc:$8df7b24a),(n:'1j_sz11.bin';l:$8000;p:$8000;crc:$685d4c54),
        (n:'3h_sz16.bin';l:$8000;p:$10000;crc:$500ff2bb),(n:'1h_sz10.bin';l:$8000;p:$18000;crc:$00b3d244),());
        sectionz_tiles:array[0..8] of tipo_roms=(
        (n:'3e_sz14.bin';l:$8000;p:0;crc:$63782e30),(n:'1e_sz08.bin';l:$8000;p:$8000;crc:$d57d9f13),
        (n:'3d_sz13.bin';l:$8000;p:$10000;crc:$1b3d4d7f),(n:'1d_sz07.bin';l:$8000;p:$18000;crc:$f5b3a29f),
        (n:'3b_sz12.bin';l:$8000;p:$20000;crc:$11d47dfd),(n:'1b_sz06.bin';l:$8000;p:$28000;crc:$df703b68),
        (n:'3f_sz15.bin';l:$8000;p:$30000;crc:$36bb9bf7),(n:'1f_sz09.bin';l:$8000;p:$38000;crc:$da8f06c9),());
        //y mi favorito... TROJAN!!!, pues no me he dajao pasta ni na...
        trojan_rom:array[0..3] of tipo_roms=(
        (n:'t4';l:$8000;p:0;crc:$c1bbeb4e),(n:'t6';l:$8000;p:$8000;crc:$d49592ef),
        (n:'tb05.bin';l:$8000;p:$10000;crc:$9273b264),());
        trojan_snd_rom:tipo_roms=(n:'tb02.bin';l:$8000;p:0;crc:$21154797);
        trojan_adpcm:tipo_roms=(n:'tb01.bin';l:$4000;p:0;crc:$1c0f91b2);
        trojan_char:tipo_roms=(n:'tb03.bin';l:$4000;p:0;crc:$581a2b4c);
        trojan_sprites:array[0..8] of tipo_roms=(
        (n:'tb18.bin';l:$8000;p:0;crc:$862c4713),(n:'tb16.bin';l:$8000;p:$8000;crc:$d86f8cbd),
        (n:'tb17.bin';l:$8000;p:$10000;crc:$12a73b3f),(n:'tb15.bin';l:$8000;p:$18000;crc:$bb1a2769),
        (n:'tb22.bin';l:$8000;p:$20000;crc:$39daafd4),(n:'tb20.bin';l:$8000;p:$28000;crc:$94615d2a),
        (n:'tb21.bin';l:$8000;p:$30000;crc:$66c642bd),(n:'tb19.bin';l:$8000;p:$38000;crc:$81d5ab36),());
        trojan_tiles:array[0..8] of tipo_roms=(
        (n:'tb13.bin';l:$8000;p:0;crc:$285a052b),(n:'tb09.bin';l:$8000;p:$8000;crc:$aeb693f7),
        (n:'tb12.bin';l:$8000;p:$10000;crc:$dfb0fe5c),(n:'tb08.bin';l:$8000;p:$18000;crc:$d3a4c9d1),
        (n:'tb11.bin';l:$8000;p:$20000;crc:$00f0f4fd),(n:'tb07.bin';l:$8000;p:$28000;crc:$dff2ee02),
        (n:'tb14.bin';l:$8000;p:$30000;crc:$14bfac18),(n:'tb10.bin';l:$8000;p:$38000;crc:$71ba8a6d),());
        trojan_tiles2:array[0..2] of tipo_roms=(
        (n:'tb25.bin';l:$8000;p:0;crc:$6e38c6fa),(n:'tb24.bin';l:$8000;p:$8000;crc:$14fc6cf2),());
        trojan_tile_map:tipo_roms=(n:'tb23.bin';l:$8000;p:0;crc:$eda13c0e);

var
 scroll_x,scroll_y:word;
 bank,sound_command,sound_command2:byte;
 mem_rom:array[0..3,0..$3fff] of byte;
 irq_ena:boolean;
 //trojan
 trojan_map:array[0..$7fff] of byte;
 scroll_x2,image:byte;
 pintar_image:boolean;
 mem_adpcm:array[0..$3fff] of byte;

procedure Cargar_hlwings;
begin
case main_vars.tipo_maquina of
  59,60:llamadas_maquina.bucle_general:=lwings_principal;
  61:llamadas_maquina.bucle_general:=trojan_principal;
end;
llamadas_maquina.iniciar:=iniciar_lwings;
llamadas_maquina.cerrar:=cerrar_lwings;
llamadas_maquina.reset:=reset_lwings;
end;

function iniciar_lwings:boolean;
var
      f,x,y:word;
      memoria_temp:array[0..$3ffff] of byte;
const
    pc_x:array[0..7] of dword=(0, 1, 2, 3, 8+0, 8+1, 8+2, 8+3);
    pc_y:array[0..7] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16);
    ps_x:array[0..15] of dword=(0, 1, 2, 3, 8+0, 8+1, 8+2, 8+3,
			32*8+0, 32*8+1, 32*8+2, 32*8+3, 33*8+0, 33*8+1, 33*8+2, 33*8+3);
    ps_y:array[0..15] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16,
			8*16, 9*16, 10*16, 11*16, 12*16, 13*16, 14*16, 15*16);
    pt_x:array[0..15] of dword=(0, 1, 2, 3, 4, 5, 6, 7,
			16*8+0, 16*8+1, 16*8+2, 16*8+3, 16*8+4, 16*8+5, 16*8+6, 16*8+7);
    pt_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8);
procedure convert_chars_lw;
begin
  init_gfx(0,8,8,1024);
  gfx[0].trans[3]:=true;
  gfx_set_desc_data(2,0,16*8,0,4);
  convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,false);
end;
procedure convert_sprites_lw;
begin
  init_gfx(1,16,16,1024);
  gfx[1].trans[15]:=true;
  gfx_set_desc_data(4,0,64*8,$10000*8+4,$10000*8+0,4,0);
  convert_gfx(1,0,@memoria_temp[0],@ps_x[0],@ps_y[0],false,false);
end;
procedure convert_tiles_lw;
begin
  init_gfx(2,16,16,$800);
  gfx_set_desc_data(4,0,32*8,$30000*8,$20000*8,$10000*8,$0*8);
  convert_gfx(2,0,@memoria_temp[0],@pt_x[0],@pt_y[0],false,false);
end;

begin
iniciar_lwings:=false;
iniciar_audio(false);
//Pantallas:  principal+char y sprites
//final 1  512x512 (por sprites)
//tiles 2  512x512 pri 0
//chars 3
//tiles 4  pri 1
screen_init(1,512,512,false,true);
screen_init(3,256,256,true);
case main_vars.tipo_maquina of
  59:begin
      x:=240;
      y:=256;
      screen_0_mod_real(256,256);
      screen_init(2,512,512);
      screen_mod_scroll(2,512,256,511,512,256,511);
      main_screen.rol90_screen:=true;
     end;
  60:begin
      x:=256;
      y:=240;
      screen_init(2,512,512);
      screen_mod_scroll(2,512,256,511,512,256,511);
     end;
  61:begin
      x:=256;
      y:=240;
      //La pantallas 2 y 4 son transparentes
      screen_init(2,512,512,true);
      screen_mod_scroll(2,512,256,511,512,256,511);
      screen_init(4,512,512,true);
      screen_mod_scroll(4,512,256,511,512,256,511);
      //La pantalla 5 es el fondo
      screen_init(5,512,256);
      screen_mod_scroll(5,512,256,511,256,256,255);
     end;
end;
iniciar_video(x,y);
case main_vars.tipo_maquina of
  59,60:begin
        //Main CPU
        main_z80:=cpu_z80.create(6000000,256);
        main_z80.change_ram_calls(lwings_getbyte,lwings_putbyte);
        //Sound CPU
        snd_z80:=cpu_z80.create(4000000,256);
        snd_z80.init_sound(lwings_sound_update);
        init_timer(snd_z80.numero_cpu,4000000/222,lwings_snd_irq,true);
  end;
  61:begin
        //Main CPU
        main_z80:=cpu_z80.create(3000000,256);
        main_z80.change_ram_calls(lwings_getbyte,trojan_putbyte);
        //Sound CPU
        snd_z80:=cpu_z80.create(3000000,256);
        snd_z80.init_sound(lwings_sound_update);
        init_timer(snd_z80.numero_cpu,3000000/222,lwings_snd_irq,true);
     end;
end;
snd_z80.change_ram_calls(lwings_snd_getbyte,lwings_snd_putbyte);
//Sound Chips
ym2203_0:=ym2203_chip.create(0,1500000,2);
ym2203_1:=ym2203_chip.create(1,1500000,2);
case main_vars.tipo_maquina of
  59:begin
        if not(cargar_roms(@memoria_temp[0],@lwings_rom[0],'lwings.zip',0)) then exit;
        copymemory(@memoria[0],@memoria_temp[0],$8000);
        for f:=0 to 3 do copymemory(@mem_rom[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
        //cargar ROMS sonido
        if not(cargar_roms(@mem_snd[0],@lwings_snd_rom,'lwings.zip',1)) then exit;
        //convertir chars
        if not(cargar_roms(@memoria_temp[0],@lwings_char,'lwings.zip',1)) then exit;
        convert_chars_lw;
        //convertir sprites
        if not(cargar_roms(@memoria_temp[0],@lwings_sprites[0],'lwings.zip',0)) then exit;
        convert_sprites_lw;
        //tiles
        if not(cargar_roms(@memoria_temp[0],@lwings_tiles[0],'lwings.zip',0)) then exit;
        convert_tiles_lw;
     end;
  60:begin
        if not(cargar_roms(@memoria_temp[0],@sectionz_rom[0],'sectionz.zip',0)) then exit;
        copymemory(@memoria[0],@memoria_temp[0],$8000);
        for f:=0 to 3 do copymemory(@mem_rom[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
        //cargar ROMS sonido
        if not(cargar_roms(@mem_snd[0],@sectionz_snd_rom,'sectionz.zip',1)) then exit;
        //convertir chars
        if not(cargar_roms(@memoria_temp[0],@sectionz_char,'sectionz.zip',1)) then exit;
        convert_chars_lw;
        //convertir sprites
        if not(cargar_roms(@memoria_temp[0],@sectionz_sprites[0],'sectionz.zip',0)) then exit;
        convert_sprites_lw;
        //tiles
        if not(cargar_roms(@memoria_temp[0],@sectionz_tiles[0],'sectionz.zip',0)) then exit;
        convert_tiles_lw;
      end;
  61:begin
        //ADPCM Z80
        sub_z80:=cpu_z80.create(3000000,256);
        sub_z80.change_ram_calls(trojan_misc_getbyte,trojan_misc_putbyte);
        sub_z80.change_io_calls(trojan_inbyte,trojan_outbyte);
        msm_5205_0:=MSM5205_chip.create(0,445000,MSM5205_SEX_4B,2,nil);
        init_timer(sub_z80.numero_cpu,3000000/4000,trojan_adpcm_instruccion,true);
        //Graficos
        if not(cargar_roms(@memoria_temp[0],@trojan_rom[0],'trojan.zip',0)) then exit;
        copymemory(@memoria[0],@memoria_temp[0],$8000);
        for f:=0 to 3 do copymemory(@mem_rom[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
        //cargar ROMS sonido
        if not(cargar_roms(@mem_snd[0],@trojan_snd_rom,'trojan.zip',1)) then exit;
        if not(cargar_roms(@mem_adpcm[0],@trojan_adpcm,'trojan.zip',1)) then exit;
        //convertir chars
        if not(cargar_roms(@memoria_temp[0],@trojan_char,'trojan.zip',1)) then exit;
        convert_chars_lw;
        //convertir sprites, tiene mas sprites...
        if not(cargar_roms(@memoria_temp[0],@trojan_sprites[0],'trojan.zip',0)) then exit;
        init_gfx(1,16,16,2048);
        gfx[1].trans[15]:=true;
        gfx_set_desc_data(4,0,64*8,$20000*8+4,$20000*8+0,4,0);
        convert_gfx(1,0,@memoria_temp[0],@ps_x[0],@ps_y[0],false,false);
        //tiles
        if not(cargar_roms(@memoria_temp[0],@trojan_tiles[0],'trojan.zip',0)) then exit;
        convert_tiles_lw;
        for f:=0 to 6 do gfx[2].trans_alt[0,f]:=true;
        for f:=12 to 15 do gfx[2].trans_alt[0,f]:=true;
        gfx[2].trans[0]:=true;
        //tiles 2
        if not(cargar_roms(@memoria_temp[0],@trojan_tiles2[0],'trojan.zip',0)) then exit;
        init_gfx(3,16,16,$200);
        gfx_set_desc_data(4,0,64*8,$8000*8+0,$8000*8+4,0,4);
        convert_gfx(3,0,@memoria_temp[0],@ps_x[0],@ps_y[0],false,false);
        //Map
        if not(cargar_roms(@trojan_map[0],@trojan_tile_map,'trojan.zip',1)) then exit;
      end;
end;
//final
reset_lwings;
iniciar_lwings:=true;
end;

procedure cerrar_lwings;
begin
main_z80.free;
snd_z80.free;
YM2203_0.Free;
YM2203_1.Free;
if main_vars.tipo_maquina=61 then begin
  msm_5205_0.Free;
  sub_z80.free;
end;
close_audio;
close_video;
end;

procedure reset_lwings;
begin
 main_z80.reset;
 main_z80.im0:=$d7;  //rst 10
 snd_z80.reset;
 YM2203_0.reset;
 YM2203_1.reset;
 if main_vars.tipo_maquina=61 then begin
  sub_z80.reset;
  msm_5205_0.reset;
 end;
 reset_audio;
 marcade.in0:=$FF;
 marcade.in1:=$FF;
 marcade.in2:=$FF;
 scroll_x:=0;
 scroll_y:=0;
 irq_ena:=true;
 //trjoan
 image:=$FF;
 pintar_image:=true;
 scroll_x2:=0;
end;

procedure eventos_lwings;
begin
if event.arcade then begin
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $F7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $F7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
end;
end;

procedure update_video_lw;inline;
var
  f,color,nchar:word;
  x,y:word;
  attr:byte;
begin
for f:=$3ff downto 0 do begin
  //tiles
  attr:=memoria[$ec00+f];
  color:=attr and $7;
  if (gfx[2].buffer[f] or buffer_color[color+$10]) then begin
      x:=f div 32;
      y:=f mod 32;
      nchar:=memoria[$e800+f]+((attr and $e0) shl 3);
      put_gfx_flip(x*16,y*16,nchar,color shl 4,2,2,(attr and $8)<>0,(attr and $10)<>0);
      gfx[2].buffer[f]:=false;
  end;
  //Chars
  attr:=memoria[f+$e400];
  color:=attr and $f;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
    x:=f mod 32;
    y:=f div 32;
    nchar:=memoria[f+$e000]+((attr and $c0) shl 2);
    put_gfx_trans_flip(x*8,y*8,nchar,(color shl 2)+512,3,0,(attr and $20)<>0,(attr and $10)<>0);
    gfx[0].buffer[f]:=false;
  end;
end;
scroll_x_y(2,1,scroll_y,scroll_x);
for f:=$7f downto 0 do begin
    x:=(buffer_sprites[3+(f*4)]+((buffer_sprites[1+(f*4)] and $1) shl 8));
    y:=buffer_sprites[2+(f*4)];
    if (x or y)<>0 then begin
      attr:=buffer_sprites[1+(f*4)];
      nchar:=buffer_sprites[(f*4)]+((attr and $c0) shl 2);
      color:=(attr and $38) shl 1;
      put_gfx_sprite(nchar,color+384,(attr and $2)<>0,(attr and $4)<>0,1);
      actualiza_gfx_sprite(x,y,1,1);
    end;
end;
actualiza_trozo(0,0,256,256,3,0,0,256,256,1);
actualiza_trozo_final(0,8,256,240,1);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure lwings_principal;
var
  f:byte;
  frame_m,frame_s:single;
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
    if f=247 then begin
      if irq_ena then main_z80.pedir_irq:=HOLD_LINE;
      update_video_lw;
      copymemory(@buffer_sprites[0],@memoria[$de00],$200);
    end;
  end;
  eventos_lwings;
  video_sync;
end;
end;

//Main CPU
function lwings_getbyte(direccion:word):byte;
begin
case direccion of
  $8000..$bfff:lwings_getbyte:=mem_rom[bank,direccion and $3fff];
  $f808:lwings_getbyte:=marcade.in0;
  $f809:lwings_getbyte:=marcade.in1;
  $f80a:lwings_getbyte:=marcade.in2;
  $f80b..$f80c:lwings_getbyte:=$ff;
  else lwings_getbyte:=memoria[direccion];
end;
end;

procedure cambiar_color(dir:word);inline;
var
  tmp_color:byte;
  color:tcolor;
begin
  tmp_color:=buffer_paleta[dir];
  color.r:=pal4bit(tmp_color shr 4);
  color.g:=pal4bit(tmp_color);
  tmp_color:=buffer_paleta[dir+$400];
  color.b:=pal4bit(tmp_color shr 4);
  set_pal_color(color,dir);
  case dir of
    $0..$7f:buffer_color[((dir shr 4) and $7)+$10]:=true;
    $200..$23f:buffer_color[(dir shr 2) and $f]:=true;
  end;
end;

procedure lwings_putbyte(direccion:word;valor:byte);
begin
if direccion<$c000 then exit;
memoria[direccion]:=valor;
case direccion of
    $e000..$e7ff:gfx[0].buffer[direccion and $3ff]:=true;
    $e800..$efff:gfx[2].buffer[direccion and $3ff]:=true;
    $f000..$f7ff:if buffer_paleta[direccion and $7ff]<>valor then begin
                    buffer_paleta[direccion and $7ff]:=valor;
                    cambiar_color(direccion and $3ff);
                 end;
    $f808:scroll_y:=(scroll_y and $100) or valor;
    $f809:scroll_y:=(scroll_y and $ff) or ((valor and 1) shl 8);
    $f80a:scroll_x:=(scroll_x and $100) or valor;
    $f80b:scroll_x:=(scroll_x and $ff) or ((valor and 1) shl 8);
    $f80c:sound_command:=valor;
    $f80e:begin
            bank:=(valor and $6) shr 1;
            irq_ena:=(valor and $8)<>0;
          end;
end;
end;

//Sound CPU
function lwings_snd_getbyte(direccion:word):byte;
begin
if direccion=$c800 then lwings_snd_getbyte:=sound_command
 else lwings_snd_getbyte:=mem_snd[direccion];
end;

procedure lwings_snd_putbyte(direccion:word;valor:byte);
begin
if direccion<$8000 then exit;
mem_snd[direccion]:=valor;
case direccion of
        $e000:ym2203_0.Control(valor);
        $e001:ym2203_0.Write_Reg(valor);
        $e002:ym2203_1.Control(valor);
        $e003:ym2203_1.Write_Reg(valor);
end;
end;

procedure lwings_snd_irq;
begin
  snd_z80.pedir_irq:=HOLD_LINE;
end;

procedure lwings_sound_update;
begin
  ym2203_0.Update;
  ym2203_1.Update;
end;

//trojan
procedure update_video_trojan;inline;
var
        f,color,nchar:word;
        x,y:word;
        attr:byte;
        tile_index,offsy:word;
begin
//final 1  512x512 (por sprites)
//tiles 2  512x512 pri 0
//chars 3
//tiles 4  pri 1
//back 5
if pintar_image then begin
  offsy:=image*$20;
  for y:=0 to $f do begin
    offsy:=offsy and $7fff;
    for x:=0 to $1f do begin
      tile_index:=offsy+(2*x);
      attr:=trojan_map[tile_index+1];
      color:=(attr and $7) shl 4;
      nchar:=trojan_map[tile_index]+((attr and $80) shl 1);
      put_gfx_flip(x*16,y*16,nchar,color,5,3,(attr and $30)<>0,false);
    end;
    offsy:=offsy+$800;
  end;
  pintar_image:=false;
end;
scroll__x(5,1,scroll_x2);
for f:=$3ff downto 0 do begin
  //tiles
  attr:=memoria[$ec00+f];
  color:=attr and $7;
  if (gfx[2].buffer[f] or buffer_color[color+$10]) then begin
      x:=f div 32;
      y:=f mod 32;
      nchar:=memoria[$e800+f]+((attr and $e0) shl 3);
      put_gfx_trans_flip(x*16,y*16,nchar,(color shl 4)+256,2,2,(attr and $10)<>0,false);
      if (attr and $8)<>0 then put_gfx_trans_flip_alt(x*16,y*16,nchar,(color shl 4)+256,4,2,(attr and $10)<>0,false,0)
        else put_gfx_block_trans(x*16,y*16,4,16,16);
      gfx[2].buffer[f]:=false;
  end;
  //Chars
  attr:=memoria[f+$e400];
  color:=attr and $f;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
    x:=f mod 32;
    y:=f div 32;
    nchar:=memoria[f+$e000]+((attr and $c0) shl 2);
    put_gfx_trans_flip(x*8,y*8,nchar,(color shl 2)+768,3,0,(attr and $20)<>0,(attr and $10)<>0);
    gfx[0].buffer[f]:=false;
  end;
end;
//Fondo con prioridad 0
scroll_x_y(2,1,scroll_x,scroll_y);
//sprites
for f:=$5f downto 0 do begin
    x:=(buffer_sprites[3+(f*4)]+((buffer_sprites[1+(f*4)] and $1) shl 8));
    y:=buffer_sprites[2+(f*4)];
    if (x or y)<>0 then begin
      attr:=buffer_sprites[1+(f*4)];
      nchar:=buffer_sprites[(f*4)]+((attr and $20) shl 4)+((attr and $40) shl 2)+((attr and $80) shl 3);
      color:=(attr and $e) shl 3;
      put_gfx_sprite(nchar,color+640,(attr and $10)<>0,true,1);
      actualiza_gfx_sprite(x,y,1,1);
    end;
end;
//Fondo con prioridad 1
scroll_x_y(4,1,scroll_x,scroll_y);
actualiza_trozo(0,0,256,256,3,0,0,256,256,1);
actualiza_trozo_final(0,8,256,240,1);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure trojan_principal;
var
  f:byte;
  frame_m,frame_s,frame_ms:single;
begin
init_controls(false,false,false,true);
frame_m:=main_z80.tframes;
frame_s:=snd_z80.tframes;
frame_ms:=sub_z80.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
    //Main Z80
    main_z80.run(frame_m);
    frame_m:=frame_m+main_z80.tframes-main_z80.contador;
    //Sound Z80
    snd_z80.run(frame_s);
    frame_s:=frame_s+snd_z80.tframes-snd_z80.contador;
    //ADPCM Z80
    sub_z80.run(frame_ms);
    frame_ms:=frame_ms+sub_z80.tframes-sub_z80.contador;
    if f=247 then begin
      if irq_ena then main_z80.pedir_irq:=HOLD_LINE;
      update_video_trojan;
      copymemory(@buffer_sprites[0],@memoria[$de00],$200);
    end;
  end;
  eventos_lwings;
  video_sync;
end;
end;

procedure cambiar_color_trojan(dir:word);inline;
var
  tmp_color:byte;
  color:tcolor;
begin
  tmp_color:=buffer_paleta[dir];
  color.r:=pal4bit(tmp_color shr 4);
  color.g:=pal4bit(tmp_color);
  tmp_color:=buffer_paleta[dir+$400];
  color.b:=pal4bit(tmp_color shr 4);
  set_pal_color(color,dir);
  case dir of
    $0..$7f:pintar_image:=true;
    $100..$17f:buffer_color[((dir shr 4) and $7)+$10]:=true;
    $300..$33f:buffer_color[(dir shr 2) and $f]:=true;
  end;
end;

procedure trojan_putbyte(direccion:word;valor:byte);
begin
if direccion<$c000 then exit;
memoria[direccion]:=valor;
case direccion of
    $e000..$e7ff:gfx[0].buffer[direccion and $3ff]:=true;
    $e800..$efff:gfx[2].buffer[direccion and $3ff]:=true;
    $f000..$f7ff:if buffer_paleta[direccion and $7ff]<>valor then begin
                    buffer_paleta[direccion and $7ff]:=valor;
                    cambiar_color(direccion and $3ff);
                 end;
    $f800:scroll_x:=(scroll_x and $100) or valor;
    $f801:scroll_x:=(scroll_x and $ff) or ((valor and 1) shl 8);
    $f802:scroll_y:=(scroll_y and $100) or valor;
    $f803:scroll_y:=(scroll_y and $ff) or ((valor and 1) shl 8);
    $f804:scroll_x2:=valor;
    $f805:if image<>valor then begin
            image:=valor;
            pintar_image:=true;
          end;
    $f80c:sound_command:=valor;
    $f80d:sound_command2:=valor;
    $f80e:begin
            bank:=(valor and $6) shr 1;
            irq_ena:=(valor and $8)<>0;
          end;
end;
end;

function trojan_inbyte(puerto:word):byte;
begin
case (puerto and $ff) of
  $0:trojan_inbyte:=sound_command2;
end;
end;

procedure trojan_outbyte(valor:byte;puerto:word);
begin
//ADPCM
case (puerto and $ff) of
  $1:begin
        msm_5205_0.reset_w((valor shr 7) and 1);
        msm_5205_0.data_w(valor);
        msm_5205_0.vclk_w(1);
	      msm_5205_0.vclk_w(0);
     end;
end;
end;

function trojan_misc_getbyte(direccion:word):byte;
begin
trojan_misc_getbyte:=mem_adpcm[direccion];
end;

procedure trojan_misc_putbyte(direccion:word;valor:byte);
begin
//Nada que hacer!!!
end;

procedure trojan_adpcm_instruccion;
begin
  sub_z80.pedir_irq:=HOLD_LINE;
end;

end.
