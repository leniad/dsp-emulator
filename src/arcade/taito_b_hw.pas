unit taito_b_hw;

interface
uses rom_engine;

const
        nastar_rom:array[0..3] of tipo_roms=(
        (n:'b81-08.50';l:$20000;p:0;crc:$d6da9169),(n:'b81-13.31';l:$20000;p:1;crc:$60d176fb),
        (n:'b81-10.49';l:$20000;p:$40000;crc:$53f34344),(n:'b81-09.30';l:$20000;p:$40001;crc:$630d34af));
        nastar_sound:tipo_roms=(n:'b81-11.37';l:$10000;p:0;crc:$3704bf09);
        nastar_adpcm_a:tipo_roms=(n:'b81-02.2';l:$80000;p:0;crc:$20ec3b86);
        nastar_adpcm_b:tipo_roms=(n:'b81-01.1';l:$80000;p:0;crc:$b33f796b);
        nastar_gfx:array[0..2] of tipo_roms=(
        (n:'b81-03.14';l:$80000;p:0;crc:$551b75e6),(n:'b81-04.15';l:$80000;p:$80000;crc:$cf734e12),());
        masterw_rom:array[0..3] of tipo_roms=(
        (n:'b72_06.33';l:$20000;p:0;crc:$ae848eff),(n:'b72_12.24';l:$20000;p:1;crc:$7176ce70),
        (n:'b72_04.34';l:$20000;p:$40000;crc:$141e964c),(n:'b72_03.25';l:$20000;p:$40001;crc:$f4523496));
        masterw_sound:tipo_roms=(n:'b72_07.30';l:$10000;p:0;crc:$2b1a946f);
        masterw_gfx:array[0..2] of tipo_roms=(
        (n:'b72-02.6';l:$80000;p:0;crc:$843444eb),(n:'b72-01.5';l:$80000;p:$80000;crc:$a24ac26e),());

function iniciar_taito_b:boolean;

implementation
uses m68000,main_engine,controls_engine,gfx_engine,taito_sound,pal_engine,
     sound_engine,taito_tc0180vcu;

var
 rom:array[0..$3ffff] of word;
 ram:array[0..$3fff] of word;
 m68k_irq_a,m68k_irq_b:byte;
 ioc_port:byte;
 ioc_coin_control:word;

procedure eventos_taito_b;
begin
  marcade.in0:=$ffff;
  marcade.in1:=$ffff;
  marcade.in2:=$ffff;
  //P1
  if arcade_input.up[0] then marcade.in1:=marcade.in1 and $feff;
  if arcade_input.down[0] then marcade.in1:=marcade.in1 and $fdff;
  if arcade_input.left[0] then marcade.in1:=marcade.in1 and $fbff;
  if arcade_input.right[0] then marcade.in1:=marcade.in1 and $f7ff;
  if arcade_input.but0[0] then marcade.in1:=marcade.in1 and $efff;
  if arcade_input.but1[0] then marcade.in1:=marcade.in1 and $dfff;
  //P2
  if arcade_input.up[0] then marcade.in2:=marcade.in2 and $feff;
  if arcade_input.down[0] then marcade.in2:=marcade.in2 and $fdff;
  if arcade_input.left[0] then marcade.in2:=marcade.in2 and $fbff;
  if arcade_input.right[0] then marcade.in2:=marcade.in2 and $f7ff;
  if arcade_input.but0[0] then marcade.in2:=marcade.in2 and $efff;
  if arcade_input.but1[0] then marcade.in2:=marcade.in2 and $dfff;
  //System
  if arcade_input.start[0] then marcade.in0:=marcade.in0 and $bfff;
  if arcade_input.start[1] then marcade.in0:=marcade.in0 and $7fff;
  if arcade_input.coin[0] then marcade.in0:=marcade.in0 and $fbff;
  if arcade_input.coin[1] then marcade.in0:=marcade.in0 and $f7ff;
end;

procedure update_video_taito_b;
begin
  tc0180vcu_0.draw;
  actualiza_trozo_final(0,16,320,224,1);
end;

procedure taito_b_principal;
var
  f:byte;
begin
while EmuStatus=EsRunning do begin
 for f:=0 to $ff do begin
  case f of
    240:begin
          update_video_taito_b;
          tc0180vcu_0.vblank_update;
          m68000_0.irq[m68k_irq_a]:=HOLD_LINE;
        end;
    248:m68000_0.irq[m68k_irq_b]:=HOLD_LINE;
  end;
  //Main CPU
  m68000_0.run(frame_main);
  frame_main:=frame_main+m68000_0.tframes-m68000_0.contador;
  //Sound CPU
  tc0140syt_0.run;
 end;
 eventos_taito_b;
 video_sync;
end;
end;

function input_r(port:byte):word;
begin
  case port of
    0:result:=marcade.dswa;
    1:result:=marcade.dswb;
    2:result:=marcade.in1;
    3:result:=marcade.in2;
    4:result:=ioc_coin_control;
    7:result:=marcade.in0;
    else result:=$ffff;
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

procedure vcu_putword(direccion:dword;valor:word);
var mask:word;
begin
  mask:=$ffff;
  if m68000_0.write_8bits_hi_dir then mask:=$ff
    else if m68000_0.write_8bits_lo_dir then mask:=$ff00;
  tc0180vcu_0.write(direccion,valor,mask);
end;

//Nastar
function nastar_getword(direccion:dword):word;
begin
  nastar_getword:=$ffff;
case direccion of
  0..$7ffff:nastar_getword:=rom[direccion shr 1];
  $200000..$201fff:nastar_getword:=buffer_paleta[(direccion and $1fff) shr 1];
  $400000..$47ffff:nastar_getword:=tc0180vcu_0.read(direccion and $7ffff);
  $600000..$607fff:nastar_getword:=ram[(direccion and $7fff) shr 1];
  $800002..$800003:begin
                      nastar_getword:=$ffff;
                      if not(m68000_0.read_8bits_hi_dir or m68000_0.write_8bits_hi_dir or m68000_0.write_8bits_lo_dir) then
                        nastar_getword:=(tc0140syt_0.comm_r shl 8) or $ff;
                    end;
  $a00000..$a0000f:nastar_getword:=input_r((direccion and $e) shr 1);
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
      $400000..$47ffff:vcu_putword(direccion and $7ffff,valor);
      $600000..$607fff:ram[(direccion and $7fff) shr 1]:=valor;
      $800000..$800001:if not m68000_0.write_8bits_hi_dir then tc0140syt_0.port_w(valor shr 8);
      $800002..$800003:if not m68000_0.write_8bits_hi_dir then tc0140syt_0.comm_w(valor shr 8);
      $a00008..$a00009:if not m68000_0.write_8bits_hi_dir then ioc_coin_control:=valor;
end;
end;

//Master of weapon
function masterw_getword(direccion:dword):word;
begin
  masterw_getword:=$ffff;
case direccion of
  0..$7ffff:masterw_getword:=rom[direccion shr 1];
  $200000..$203fff:masterw_getword:=ram[(direccion and $3fff) shr 1];
  $400000..$47ffff:masterw_getword:=tc0180vcu_0.read(direccion and $7ffff);
  $600000..$601fff:masterw_getword:=buffer_paleta[(direccion and $1fff) shr 1];
  $800000..$800001:masterw_getword:=input_r(ioc_port);
  $800002..$800003:masterw_getword:=$ff; // Watchdog read
  $a00002..$a00003:if not(m68000_0.read_8bits_hi_dir or m68000_0.write_8bits_hi_dir or m68000_0.write_8bits_lo_dir) then
                        masterw_getword:=(tc0140syt_0.comm_r shl 8) or $ff;
end;
end;

procedure masterw_putword(direccion:dword;valor:word);
begin
case direccion of
      0..$7ffff:; //ROM
      $200000..$203fff:ram[(direccion and $3fff) shr 1]:=valor;
      $400000..$47ffff:vcu_putword(direccion and $7ffff,valor);
      $600000..$601fff:if buffer_paleta[(direccion and $1fff) shr 1]<>valor then begin
                            buffer_paleta[(direccion and $1fff) shr 1]:=valor;
                            cambiar_color(valor,(direccion and $1fff) shr 1);
                       end;
      $800000..$800001:if not m68000_0.write_8bits_hi_dir then if ioc_port=4 then ioc_coin_control:=valor;
      $800002..$800003:if not m68000_0.write_8bits_hi_dir then ioc_port:=valor shr 8;
      $a00000..$a00001:if not m68000_0.write_8bits_hi_dir then tc0140syt_0.port_w(valor shr 8);
      $a00002..$a00003:if not m68000_0.write_8bits_hi_dir then tc0140syt_0.comm_w(valor shr 8);
end;
end;

//Main
procedure reset_taito_b;
begin
 m68000_0.reset;
 frame_main:=m68000_0.tframes;
 tc0140syt_0.reset;
 tc0180vcu_0.reset;
 marcade.in0:=$ffff;
 marcade.in1:=$ffff;
 marcade.in2:=$ffff;
 ioc_port:=0;
 ioc_coin_control:=0;
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
iniciar_taito_b:=false;
llamadas_maquina.bucle_general:=taito_b_principal;
llamadas_maquina.reset:=reset_taito_b;
llamadas_maquina.scanlines:=256;
iniciar_audio(false);
main_screen.rot270_screen:=(main_vars.tipo_maquina=418);
screen_init(1,512,256,false,true);
iniciar_video(320,224);
//Main CPU
m68000_0:=cpu_m68000.create(12000000);
getmem(ptemp,$100000);
case main_vars.tipo_maquina of
  417:begin //Nastar
        m68000_0.change_ram16_calls(nastar_getword,nastar_putword);
        if not(roms_load16w(@rom,nastar_rom)) then exit;
        m68k_irq_a:=4;
        m68k_irq_b:=2;
        //Sound
        tc0140syt_0:=tc0140syt_chip.create(4000000,SOUND_TAITOB);
        //cargar sonido+ponerlas en su banco
        if not(roms_load(ptemp,nastar_sound)) then exit;
        copymemory(@tc0140syt_0.snd_rom[0],@ptemp[0],$4000);
        copymemory(@tc0140syt_0.snd_bank_rom[0,0],@ptemp[$0],$4000);
        copymemory(@tc0140syt_0.snd_bank_rom[1,0],@ptemp[$4000],$4000);
        copymemory(@tc0140syt_0.snd_bank_rom[2,0],@ptemp[$8000],$4000);
        copymemory(@tc0140syt_0.snd_bank_rom[3,0],@ptemp[$c000],$4000);
        // YM2610 sample ROMs
        if not(roms_load(@tc0140syt_0.ym2610.rom_a[0],nastar_adpcm_a)) then exit;
        if not(roms_load(@tc0140syt_0.ym2610.rom_b[0],nastar_adpcm_b)) then exit;
        //Video
        tc0180vcu_0:=tc0180vcu_chip.create(1,0,$c0,$80,$40);
        //convertir chars
        if not(roms_load(ptemp,nastar_gfx)) then exit;
        convert_chars;
        //convertir sprites
        convert_sprites;
  end;
  418:begin //Master of Weapon
        m68000_0.change_ram16_calls(masterw_getword,masterw_putword);
        if not(roms_load16w(@rom,masterw_rom)) then exit;
        m68k_irq_a:=5;
        m68k_irq_b:=4;
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
        tc0180vcu_0:=tc0180vcu_chip.create(1,0,$30,$20,$10);
        //convertir chars
        if not(roms_load(ptemp,masterw_gfx)) then exit;
        convert_chars;
        //convertir sprites
        convert_sprites;
  end;
end;
//DIP
marcade.dswa:=$ffff;
marcade.dswb:=$ffff;
freemem(ptemp);
//final
iniciar_taito_b:=true;
end;

end.
