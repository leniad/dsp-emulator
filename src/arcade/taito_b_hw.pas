unit taito_b_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m68000,main_engine,controls_engine,gfx_engine,taito_sound,rom_engine,
     pal_engine,sound_engine,taito_tc0180vcu;

function iniciar_taito_b:boolean;

implementation
const
        nastar_rom:array[0..3] of tipo_roms=(
        (n:'b81-08.50';l:$20000;p:0;crc:$d6da9169),(n:'b81-13.31';l:$20000;p:1;crc:$60d176fb),
        (n:'b81-10.49';l:$20000;p:$40000;crc:$53f34344),(n:'b81-09.30';l:$20000;p:$40001;crc:$630d34af));
        nastar_sound:tipo_roms=(n:'b81-11.37';l:$10000;p:0;crc:$3704bf09);
        nastar_gfx:array[0..1] of tipo_roms=(
        (n:'b81-03.14';l:$80000;p:0;crc:$551b75e6),(n:'b81-04.15';l:$80000;p:$80000;crc:$cf734e12));
        nastar_adpcm_a:tipo_roms=(n:'b81-02.2';l:$80000;p:0;crc:$20ec3b86);
        nastar_adpcm_b:tipo_roms=(n:'b81-01.1';l:$80000;p:0;crc:$b33f796b);
        masterw_rom:array[0..3] of tipo_roms=(
        (n:'b72_06.33';l:$20000;p:0;crc:$ae848eff),(n:'b72_12.24';l:$20000;p:1;crc:$7176ce70),
        (n:'b72_04.34';l:$20000;p:$40000;crc:$141e964c),(n:'b72_03.25';l:$20000;p:$40001;crc:$f4523496));
        masterw_sound:tipo_roms=(n:'b72_07.30';l:$10000;p:0;crc:$2b1a946f);
        masterw_gfx:array[0..1] of tipo_roms=(
        (n:'b72-02.6';l:$80000;p:0;crc:$843444eb),(n:'b72-01.5';l:$80000;p:$80000;crc:$a24ac26e));

var
 rom:array[0..$3ffff] of word;
 ram:array[0..$3fff] of word;

procedure update_video_rastan;
begin
tc0180vcu_0.draw;
actualiza_trozo(0,0,1024,1024,1,0,0,1024,1024,4);
actualiza_trozo(0,0,1024,1024,2,0,0,1024,1024,4);
tc0180vcu_0.draw_sprites;
actualiza_trozo(0,0,512,256,3,0,0,512,256,4);
actualiza_trozo_final(0,0,512,512,4);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
end;

procedure eventos_rastan;
begin
if event.arcade then begin
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or 8);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 or $20) else marcade.in0:=(marcade.in0 and $df);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 or $40) else marcade.in0:=(marcade.in0 and $bf);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
end;
end;

procedure rastan_principal;
var
  frame_m:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
while EmuStatus=EsRunning do begin
 for f:=0 to $ff do begin
  if f=240 then begin
    update_video_rastan;
    m68000_0.irq[5]:=HOLD_LINE;
  end;
  if f=248 then m68000_0.irq[4]:=HOLD_LINE;
  //Main CPU
  m68000_0.run(frame_m);
  frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
  //Sound CPU
  tc0140syt_0.run;
 end;
 eventos_rastan;
 video_sync;
end;
end;

procedure cambiar_color(tmp_color,numero:word);
var
  color:tcolor;
begin
  color.r:=pal4bit(tmp_color shr 12);
  color.g:=pal4bit(tmp_color shr 8);
  color.b:=pal4bit(tmp_color shr 4);
  set_pal_color(color,numero);
  buffer_color[(numero shr 4) and $7f]:=true;
end;

//Nastar
function nastar_getword(direccion:dword):word;
begin
case direccion of
  0..$7ffff:nastar_getword:=rom[direccion shr 1];
  $200000..$201fff:nastar_getword:=buffer_paleta[(direccion and $1fff) shr 1];
  $400000..$47ffff:nastar_getword:=tc0180vcu_0.read(direccion and $7ffff);
  $600000..$607fff:nastar_getword:=ram[(direccion and $7fff) shr 1];
  $800002:{if m68000_0.read_8bits_hi_dir then }nastar_getword:=tc0140syt_0.comm_r;
  $a00000,$a00002,$a00004,$a00006,$a0000a,$a0000c,$a0000e:nastar_getword:=$ffff;
  $a00008:nastar_getword:=$ffff;
end;
end;

procedure nastar_putword(direccion:dword;valor:word);
begin
case direccion of
      0..$7ffff:; //ROM
      $200000..$201fff:if buffer_paleta[(direccion and $1fff) shr 1]<>valor then begin
                            buffer_paleta[(direccion and $1fff) shr 1]:=valor;
                            cambiar_color(valor,(direccion and $1fff) shr 1);
                       end;
      $400000..$47ffff:tc0180vcu_0.write(direccion and $7ffff,valor);
      $600000..$607fff:ram[(direccion and $7fff) shr 1]:=valor;
      $800000:tc0140syt_0.port_w(valor and $ff);
      $800002:tc0140syt_0.comm_w(valor and $ff);
end;
end;

//Master of weapon
function masterw_getword(direccion:dword):word;
begin
case direccion of
  0..$7ffff:masterw_getword:=rom[direccion shr 1];
  $200000..$203fff:masterw_getword:=ram[(direccion and $3fff) shr 1];
  $400000..$47ffff:masterw_getword:=tc0180vcu_0.read(direccion and $7ffff);
  $600000..$601fff:masterw_getword:=buffer_paleta[(direccion and $1fff) shr 1];
  $800000..$800001:masterw_getword:=$0f00;
  $800002..$800003:masterw_getword:=$0;
  $a00002:if m68000_0.read_8bits_hi_dir then masterw_getword:=tc0140syt_0.comm_r;
end;
end;

procedure masterw_putword(direccion:dword;valor:word);
begin
case direccion of
      0..$7ffff:; //ROM
      $200000..$203fff:ram[(direccion and $3fff) shr 1]:=valor;
      $400000..$47ffff:tc0180vcu_0.write(direccion and $7ffff,valor);
      $600000..$601fff:if buffer_paleta[(direccion and $1fff) shr 1]<>valor then begin
                            buffer_paleta[(direccion and $1fff) shr 1]:=valor;
                            cambiar_color(valor,(direccion and $1fff) shr 1);
                       end;
      $800000..$800003:;
      $a00000:tc0140syt_0.port_w(valor and $ff);
      $a00002:tc0140syt_0.comm_w(valor and $ff);
end;
end;


//Main
procedure reset_taito_b;
begin
 m68000_0.reset;
 tc0140syt_0.reset;
 //tc0180vcu_0.reset;
 marcade.in0:=$1f;
 marcade.in1:=$ff;
end;

function iniciar_taito_b:boolean;
const
  ps_x:array[0..15] of dword=(0, 1, 2 ,3,	4, 5, 6, 7,
              	8*8*2+0, 8*8*2+1, 8*8*2+2,8*8*2+3, 8*8*2+4,8*8*2+5, 8*8*2+6, 8*8*2+7);
  ps_y:array[0..15] of dword=(8*2*0, 8*2*1, 8*2*2,8*2*3, 8*2*4,8*2*5, 8*2*6, 8*2*7,
			8*8*2*2+8*2*0, 8*8*2*2+8*2*1, 8*8*2*2+8*2*2, 8*8*2*2+8*2*3, 8*8*2*2+8*2*4, 8*8*2*2+8*2*5, 8*8*2*2+8*2*6, 8*8*2*2+8*2*7 );
var
  ptemp:pbyte;
procedure convert_chars;
begin
  init_gfx(0,8,8,$8000);
  gfx[0].trans[0]:=true;
  gfx_set_desc_data(4,0,16*8,0,8,$8000*16*8,$8000*16*8+8);
  convert_gfx(0,0,ptemp,@ps_x,@ps_y,false,false);
end;
procedure convert_sprites;
begin
  init_gfx(1,16,16,$2000);
  gfx[1].trans[0]:=true;
  gfx_set_desc_data(4,0,64*8,0,8,$2000*64*8,$2000*64*8+8);
  convert_gfx(1,0,ptemp,@ps_x,@ps_y,false,false);
end;
begin
llamadas_maquina.bucle_general:=rastan_principal;
llamadas_maquina.reset:=reset_taito_b;
llamadas_maquina.scanlines:=256;
iniciar_taito_b:=false;
iniciar_audio(false);
if main_vars.tipo_maquina=418 then main_screen.rot270_screen:=true;
screen_init(1,1024,1024);
screen_init(2,1024,1024,true);
screen_init(3,512,256,true);
screen_init(4,1024,1024,false,true);
//iniciar_video(320,224);
iniciar_video(512,512);
//Main CPU
getmem(ptemp,$100000);
m68000_0:=cpu_m68000.create(12000000);
case main_vars.tipo_maquina of
  417:begin //Nastar
        m68000_0.change_ram16_calls(nastar_getword,nastar_putword);
        if not(roms_load16w(@rom,nastar_rom)) then exit;
        //Sound
        tc0140syt_0:=tc0140syt_chip.create(4000000,SOUND_TAITOB);
        //cargar sonido+ponerlas en su banco
        if not(roms_load(ptemp,nastar_sound)) then exit;
        copymemory(@tc0140syt_0.snd_rom[0],@ptemp[0],$4000);
        copymemory(@tc0140syt_0.snd_bank_rom[0,0],@ptemp[$0],$4000);
        copymemory(@tc0140syt_0.snd_bank_rom[1,0],@ptemp[$4000],$4000);
        copymemory(@tc0140syt_0.snd_bank_rom[2,0],@ptemp[$8000],$4000);
        copymemory(@tc0140syt_0.snd_bank_rom[3,0],@ptemp[$c000],$4000);
        //Video
        tc0180vcu_0:=tc0180vcu_chip.create(0,$c0,$80,$40);
        //convertir chars
        if not(roms_load(ptemp,nastar_gfx)) then exit;
        convert_chars;
        //convertir sprites
        convert_sprites;
  end;
  418:begin //Master of Weapon
        m68000_0.change_ram16_calls(masterw_getword,masterw_putword);
        if not(roms_load16w(@rom,masterw_rom)) then exit;
        //Sound
        tc0140syt_0:=tc0140syt_chip.create(6000000,SOUND_MASTERW);
        //cargar sonido+ponerlas en su banco
        if not(roms_load(ptemp,masterw_sound)) then exit;
        copymemory(@tc0140syt_0.snd_rom[0],@ptemp[0],$4000);
        copymemory(@tc0140syt_0.snd_bank_rom[0,0],@ptemp[$0],$4000);
        copymemory(@tc0140syt_0.snd_bank_rom[1,0],@ptemp[$4000],$4000);
        copymemory(@tc0140syt_0.snd_bank_rom[2,0],@ptemp[$8000],$4000);
        copymemory(@tc0140syt_0.snd_bank_rom[3,0],@ptemp[$c000],$4000);
        //Video
        tc0180vcu_0:=tc0180vcu_chip.create(0,$30,$20,$10);
        //convertir chars
        if not(roms_load(ptemp,masterw_gfx)) then exit;
        convert_chars;
        //convertir sprites
        convert_sprites;
  end;
end;
freemem(ptemp);
//final
iniciar_taito_b:=true;
end;

end.
