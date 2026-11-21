unit msx1;

interface
uses sysutils,dialogs,rom_engine;

function iniciar_msx1:boolean;

var
  key_type:byte;

const
  mpc100_bios:array [0..1] of tipo_roms=((n:'mpc100bios.rom';l:$8000;p:0;crc:$e9ccd789),());
  nms801_bios:tipo_roms=(n:'801bios.rom';l:$8000;p:0;crc:$fa089461);

implementation
uses snapshot,principal,tap_tzx,nz80,main_engine,controls_engine,tms99xx,
     misc_functions,sound_engine,file_engine,ay_8910,ppi8255,tape_window,
     timer_engine;

const
  MAX_CARTRIDGE=$80000;

type
  tslot=record
    mem:array[0..$3fff] of byte;
    rom:boolean;
    ena:boolean;
  end;

var
  slot:array[0..3,0..3] of tslot;
  pag_ena,pag_rom:array [0..3] of boolean;
  slot0,slot1,slot2,slot3:pbyte;
  teclado:byte;
  last_irq:boolean;
  keypad:array[0..9] of byte;
  port_a,port_c,port_b_ay:byte;
  tape_motor:boolean;
  tape_sound_channel:byte;
  joystick:array[0..1] of byte;
  joy_select:byte;
  key_timer,key_pos:byte;

procedure eventos_msx1;
begin
if event.arcade then begin
   fillchar(keypad[0],10,$ff);
   //P0
   if keyboard[KEYBOARD_0] then keypad[0]:=keypad[0] and $fe;
   if (keyboard[KEYBOARD_1] and not(keyboard[KEYBOARD_RSHIFT])) then keypad[0]:=keypad[0] and $fd;
   if (keyboard[KEYBOARD_2] and not(keyboard[KEYBOARD_RSHIFT])) then keypad[0]:=keypad[0] and $fb;
   if (keyboard[KEYBOARD_3] and not(keyboard[KEYBOARD_RSHIFT])) then keypad[0]:=keypad[0] and $f7;
   if (keyboard[KEYBOARD_4] and not(keyboard[KEYBOARD_RSHIFT])) then keypad[0]:=keypad[0] and $ef;
   if (keyboard[KEYBOARD_5] and not(keyboard[KEYBOARD_RSHIFT])) then keypad[0]:=keypad[0] and $df;
   if keyboard[KEYBOARD_6] then keypad[0]:=keypad[0] and $bf;
   if keyboard[KEYBOARD_7] then keypad[0]:=keypad[0] and $7f;
   //P1
   if keyboard[KEYBOARD_8] then keypad[1]:=keypad[1] and $fe;
   if keyboard[KEYBOARD_9] then keypad[1]:=keypad[1] and $fd;
   if keyboard[KEYBOARD_FILA3_T3] then keypad[1]:=keypad[1] and $fb;
   //if keyboard[KEYBOARD_=] then keypad[1]:=keypad[1] and $f7;
   if keyboard[KEYBOARD_FILA0_T0] then keypad[1]:=keypad[1] and $ef;
   if keyboard[KEYBOARD_FILA1_T1] then keypad[1]:=keypad[1] and $df;
   if keyboard[KEYBOARD_FILA1_T2] then keypad[1]:=keypad[1] and $bf;
   if keyboard[KEYBOARD_FILA3_T1] then keypad[1]:=keypad[1] and $7f;
   //P2
   if keyboard[KEYBOARD_FILA0_T1] then keypad[2]:=keypad[2] and $fe;
   //if keyboard[KEYBOARD_)] then keypad[2]:=keypad[2] and $fd;
   if keyboard[KEYBOARD_FILA2_T2] then keypad[2]:=keypad[2] and $fb;
   if keyboard[KEYBOARD_FILA3_T2] then keypad[2]:=keypad[2] and $f7;
   //if keyboard[KEYBOARD_/] then keypad[2]:=keypad[2] and $ef;
   //if keyboard[KEYBOARD_*-] then keypad[2]:=keypad[2] and $df;
   if keyboard[KEYBOARD_a] then keypad[2]:=keypad[2] and $bf;
   if keyboard[KEYBOARD_b] then keypad[2]:=keypad[2] and $7f;
   //P3
   if keyboard[KEYBOARD_c] then keypad[3]:=keypad[3] and $fe;
   if keyboard[KEYBOARD_d] then keypad[3]:=keypad[3] and $fd;
   if keyboard[KEYBOARD_e] then keypad[3]:=keypad[3] and $fb;
   if keyboard[KEYBOARD_f] then keypad[3]:=keypad[3] and $f7;
   if keyboard[KEYBOARD_g] then keypad[3]:=keypad[3] and $ef;
   if keyboard[KEYBOARD_h] then keypad[3]:=keypad[3] and $df;
   if keyboard[KEYBOARD_i] then keypad[3]:=keypad[3] and $bf;
   if keyboard[KEYBOARD_j] then keypad[3]:=keypad[3] and $7f;
   //P4
   if keyboard[KEYBOARD_k] then keypad[4]:=keypad[4] and $fe;
   if keyboard[KEYBOARD_l] then keypad[4]:=keypad[4] and $fd;
   if keyboard[KEYBOARD_m] then keypad[4]:=keypad[4] and $fb;
   if keyboard[KEYBOARD_n] then keypad[4]:=keypad[4] and $f7;
   if keyboard[KEYBOARD_o] then keypad[4]:=keypad[4] and $ef;
   if keyboard[KEYBOARD_p] then keypad[4]:=keypad[4] and $df;
   if keyboard[KEYBOARD_q] then keypad[4]:=keypad[4] and $bf;
   if keyboard[KEYBOARD_r] then keypad[4]:=keypad[4] and $7f;
   //P5
   if keyboard[KEYBOARD_s] then keypad[5]:=keypad[5] and $fe;
   if keyboard[KEYBOARD_t] then keypad[5]:=keypad[5] and $fd;
   if keyboard[KEYBOARD_u] then keypad[5]:=keypad[5] and $fb;
   if keyboard[KEYBOARD_v] then keypad[5]:=keypad[5] and $f7;
   if keyboard[KEYBOARD_w] then keypad[5]:=keypad[5] and $ef;
   if keyboard[KEYBOARD_x] then keypad[5]:=keypad[5] and $df;
   if keyboard[KEYBOARD_y] then keypad[5]:=keypad[5] and $bf;
   if keyboard[KEYBOARD_z] then keypad[5]:=keypad[5] and $7f;
   //P6
   if keyboard[KEYBOARD_LSHIFT] then keypad[6]:=keypad[6] and $fe;
   if keyboard[KEYBOARD_LCTRL] then keypad[6]:=keypad[6] and $fd;
   //if keyboard[KEYBOARD_graph] then keypad[6]:=keypad[6] and $fb;
   if keyboard[KEYBOARD_CAPSLOCK] then keypad[6]:=keypad[6] and $f7;
   //if keyboard[KEYBOARD_code] then keypad[6]:=keypad[6] and $ef;
   if (keyboard[KEYBOARD_1] and keyboard[KEYBOARD_RSHIFT]) then keypad[6]:=keypad[6] and $df;
   if (keyboard[KEYBOARD_2] and keyboard[KEYBOARD_RSHIFT]) then keypad[6]:=keypad[6] and $bf;
   if (keyboard[KEYBOARD_3] and keyboard[KEYBOARD_RSHIFT]) then keypad[6]:=keypad[6] and $7f;
   //P7
   if (keyboard[KEYBOARD_4] and keyboard[KEYBOARD_RSHIFT]) then keypad[7]:=keypad[7] and $fe;
   if (keyboard[KEYBOARD_5] and keyboard[KEYBOARD_RSHIFT]) then keypad[7]:=keypad[7] and $fd;
   if keyboard[KEYBOARD_ESCAPE] then keypad[7]:=keypad[7] and $fb;
   if keyboard[KEYBOARD_TAB] then keypad[7]:=keypad[7] and $f7;
   //if keyboard[KEYBOARD_stop] then keypad[7]:=keypad[7] and $ef;
   if keyboard[KEYBOARD_BACKSPACE] then keypad[7]:=keypad[7] and $df;
   //if keyboard[KEYBOARD_select] then keypad[7]:=keypad[7] and $bf;
   if keyboard[KEYBOARD_RETURN] then keypad[7]:=keypad[7] and $7f;
   //P8
   if keyboard[KEYBOARD_SPACE] then keypad[8]:=keypad[8] and $fe;
   if keyboard[KEYBOARD_HOME] then keypad[8]:=keypad[8] and $fd;
   //if keyboard[KEYBOARD_INSERT] then keypad[8]:=keypad[8] and $fb;
   //if keyboard[KEYBOARD_DEL] then keypad[8]:=keypad[8] and $f7;
   if keyboard[KEYBOARD_LEFT] then keypad[8]:=keypad[8] and $ef;
   if keyboard[KEYBOARD_UP] then keypad[8]:=keypad[8] and $df;
   if keyboard[KEYBOARD_DOWN] then keypad[8]:=keypad[8] and $bf;
   if keyboard[KEYBOARD_RIGHT] then keypad[8]:=keypad[8] and $7f;
   joystick[0]:=$3f;
   joystick[1]:=$3f;
   //P1
   if arcade_input.up[0] then joystick[0]:=joystick[0] and $fe;
   if arcade_input.down[0] then joystick[0]:=joystick[0] and $fd;
   if arcade_input.left[0] then joystick[0]:=joystick[0] and $fb;
   if arcade_input.right[0] then joystick[0]:=joystick[0] and $f7;
   if arcade_input.but0[0] then joystick[0]:=joystick[0] and $ef;
   if arcade_input.but1[0] then joystick[0]:=joystick[0] and $df;
   //P2
   if arcade_input.up[1] then joystick[1]:=joystick[1] and $fe;
   if arcade_input.down[1] then joystick[1]:=joystick[1] and $fd;
   if arcade_input.left[1] then joystick[1]:=joystick[1] and $fb;
   if arcade_input.right[1] then joystick[1]:=joystick[1] and $f7;
   if arcade_input.but0[1] then joystick[1]:=joystick[1] and $ef;
   if arcade_input.but1[1] then joystick[1]:=joystick[1] and $df;
end;
end;

procedure msx1_principal;
var
  f:word;
begin
while EmuStatus=EsRunning do begin
  for f:=0 to 312 do begin
      eventos_msx1;
      z80_0.run(frame_main);
      frame_main:=frame_main+z80_0.tframes-z80_0.contador;
      tms_0.refresh_pal(f);
  end;
  actualiza_trozo(0,0,284,243,1,0,0,284,243,PANT_TEMP);
  video_sync;
end;
end;

function msx1_getbyte(direccion:word):byte;
var
  res:byte;
begin
//Es muy importante que devuelva $ff si no hay una pagina de memoria activa!
res:=$ff;
case direccion of
  0..$3fff:if pag_ena[0] then res:=slot0[direccion];
  $4000..$7fff:if pag_ena[1] then res:=slot1[direccion and $3fff];
  $8000..$bfff:if pag_ena[2] then res:=slot2[direccion and $3fff];
  $c000..$ffff:if pag_ena[3] then res:=slot3[direccion and $3fff];
end;
msx1_getbyte:=res;
end;

procedure msx1_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$3fff:if (not(pag_rom[0]) and pag_ena[0]) then slot0[direccion]:=valor;
  $4000..$7fff:if (not(pag_rom[1]) and pag_ena[1]) then slot1[direccion and $3fff]:=valor;
  $8000..$bfff:if (not(pag_rom[2]) and pag_ena[2]) then slot2[direccion and $3fff]:=valor;
  $c000..$ffff:if (not(pag_rom[3]) and pag_ena[3]) then slot3[direccion and $3fff]:=valor;
end;
end;

function msx1_inbyte(puerto:word):byte;
begin
  puerto:=puerto and $ff;
  case puerto of
    $98:msx1_inbyte:=tms_0.vram_r;
    $99:msx1_inbyte:=tms_0.register_r;
    $a2:msx1_inbyte:=ay8910_0.read;
    $a8..$ab:msx1_inbyte:=pia8255_0.read(puerto and 3);
  end;
end;

procedure msx1_outbyte(puerto:word;valor:byte);
begin
  puerto:=puerto and $ff;
  case puerto of
    $98:tms_0.vram_w(valor);
    $99:tms_0.register_w(valor);
    $a0:ay8910_0.control(valor);
    $a1:ay8910_0.write(valor);
    $a8..$ab:pia8255_0.write(puerto and 3,valor);
  end;
end;

procedure msx1_interrupt(int:boolean);
begin
  if (int and not(last_irq)) then z80_0.change_irq(HOLD_LINE);
  last_irq:=int;
end;

function ay_porta_read:byte;
begin
  ay_porta_read:=joystick[joy_select] or (cinta_tzx.value shl 1);
end;

function ay_portb_read:byte;
begin
  ay_portb_read:=port_b_ay;
end;

procedure ay_b_write(valor:byte);
begin
  joy_select:=(valor and $40) shr 6;
  port_b_ay:=valor;
end;

function port_a_read:byte;
begin
  port_a_read:=port_a;
end;

function port_b_read:byte;
var
  res:byte;
begin
  res:=$ff;
  if teclado<10 then res:=keypad[teclado];
  port_b_read:=res;
end;

procedure port_a_write(valor:byte);
var
  f,tempb:byte;
begin
  for f:=0 to 3 do begin
    tempb:=(valor shr (f*2)) and 3;
    case f of
      0:slot0:=@slot[tempb,f].mem[0];
      1:slot1:=@slot[tempb,f].mem[0];
      2:slot2:=@slot[tempb,f].mem[0];
      3:slot3:=@slot[tempb,f].mem[0];
    end;
    pag_rom[f]:=slot[tempb,f].rom;
    pag_ena[f]:=slot[tempb,f].ena;
  end;
  port_a:=valor;
end;

procedure port_c_write(valor:byte);
begin
  //Teclado bits 0-3 max 10
  teclado:=valor and $f;
  //Motor cinta
  if ((((port_c xor valor) and $10)<>0) and cinta_tzx.cargada) then begin
    if (not(cinta_tzx.play_tape) and ((valor and $10)=0)) then begin
      main_screen.rapido:=true;
      tape_window1.fPlayCinta(nil);
      if not(cinta_tzx.play_once) then cinta_tzx.play_once:=true;
    end;
    if (cinta_tzx.play_tape and ((valor and $10)<>0)) then begin
      main_screen.rapido:=false;
      if cinta_tzx.play_tape then tape_window1.fStopCinta(nil);
    end;
  end;
  port_c:=valor;
end;

procedure msx_despues_instruccion(estados_t:word);
begin
if (cinta_tzx.cargada and cinta_tzx.play_tape) then play_cinta_tzx(trunc(estados_t*0.9777));
end;

procedure msx1_sound_update;
begin
  tsample[tape_sound_channel,sound_status.posicion_sonido]:=((port_c and $80)*10)+(cinta_tzx.value*$20)*byte(cinta_tzx.play_tape);
  ay8910_0.update;
end;

procedure key_press;
const
  run_key_0:array[0..34] of word=($027f,$02ff,$04fd,$04ff,$04ef,$04ff,$02bf,$02ff,$03fd,$03ff,$06fe,$02fe,$06ff,$02ff,$03fe,$03ff,$02bf,$02ff,$05fe,$05ff,$06fe,$017f,$06ff,$01ff,$06fe,$02fe,$06ff,$02ff,$02fb,$02ff,$047f,$04ff,$077f,$07ff,$ffff);
  run_key_1:array[0..12] of word=($03fe,$03ff,$04fd,$04ff,$04ef,$04ff,$02bf,$02ff,$03fd,$03ff,$077f,$07ff,$ffff);
  run_key_2:array[0..22] of word=($047f,$04ff,$05fb,$05ff,$04f7,$04ff,$06fe,$02fe,$06ff,$02ff,$03fe,$03ff,$02bf,$02ff,$05fe,$05ff,$06fe,$017f,$06ff,$01ff,$077f,$07ff,$ffff);
begin
case key_type of
  0:begin
      keypad[run_key_0[key_pos] shr 8]:=run_key_0[key_pos] and $ff;
      if run_key_0[key_pos]=$ffff then begin
        timers.enabled(key_timer,false);
        key_pos:=0;
      end else key_pos:=key_pos+1;
    end;
  1:begin
      keypad[run_key_1[key_pos] shr 8]:=run_key_1[key_pos] and $ff;
      if run_key_1[key_pos]=$ffff then begin
        timers.enabled(key_timer,false);
        key_pos:=0;
      end else key_pos:=key_pos+1;
    end;
  2:begin
      keypad[run_key_2[key_pos] shr 8]:=run_key_2[key_pos] and $ff;
      if run_key_2[key_pos]=$ffff then begin
        timers.enabled(key_timer,false);
        key_pos:=0;
      end else key_pos:=key_pos+1;
  end;
end;
end;

//Main
procedure reset_msx1;
var
  f:byte;
begin
 z80_0.reset;
 frame_main:=z80_0.tframes;
 pia8255_0.reset;
 ay8910_0.reset;
 tms_0.reset;
 key_pos:=0;
 fillchar(keypad[0],10,$ff);
 joystick[0]:=$3f;
 joystick[1]:=$3f;
 joy_select:=0;
 port_a:=0;
 port_c:=$7f;
 slot0:=@slot[0,0].mem[0];
 slot1:=@slot[0,1].mem[0];
 pag_rom[0]:=true;
 pag_rom[1]:=true;
 pag_ena[0]:=true;
 pag_ena[1]:=true;
 for f:=0 to 3 do fillchar(slot[1,f].mem[0],$4000,0);
 for f:=0 to 3 do fillchar(slot[2,f].mem[0],$4000,0);
 for f:=0 to 3 do fillchar(slot[3,f].mem[0],$4000,0);
 if cinta_tzx.cargada then cinta_tzx.play_once:=false;
 cinta_tzx.value:=0;
end;

procedure abrir_msx1;
var
  nombre_file,RomFile:string;
  datos:pbyte;
  longitud:integer;
begin
  if not(openrom(romfile,SMSX_ROM)) then exit;
  getmem(datos,MAX_CARTRIDGE);
  if not(extract_data(romfile,datos,longitud,nombre_file,SMSX_ROM)) then begin
    freemem(datos);
    exit;
  end;
  reset_msx1;
  copymemory(@slot[1,1].mem[0],@datos[0],$4000);
  copymemory(@slot[1,2].mem[0],@datos[$4000],$4000);
  slot[1,1].rom:=true;
  slot[1,2].rom:=true;
  slot[1,1].ena:=true;
  slot[1,2].ena:=true;
  freemem(datos);
  main_vars.nombre_caption:=nombre_file;
  change_caption;
  directory.msx_tap:=ExtractFilePath(romfile);
end;

procedure msx_tapes;
var
  datos:pbyte;
  longitud:integer;
  romfile,nombre_file,extension,cadena:string;
  resultado:boolean;
begin
  if not(OpenRom(romfile,SMSX_TAP)) then exit;
  getmem(datos,$3000000);
  if not(extract_data(romfile,datos,longitud,nombre_file,SMSX_TAP)) then begin
    freemem(datos);
    exit;
  end;
  cadena:='';
  extension:=extension_fichero(nombre_file);
  resultado:=false;
  if ((extension='TZX') or (extension='TSX')) then resultado:=abrir_tzx(datos,longitud);
  if extension='CAS' then resultado:=abrir_cas(datos,longitud);
  if extension='WAV' then resultado:=abrir_wav(datos,longitud,3579545);
  if resultado then begin
    tape_window1.edit1.Text:=nombre_file;
    tape_window1.show;
    tape_window1.BitBtn1.Enabled:=true;
    tape_window1.BitBtn2.Enabled:=false;
    cinta_tzx.play_tape:=false;
    cadena:=extension+': '+nombre_file;
    tape_motor:=false;
    if ((key_type<>3) and main_vars.auto_type) then timers.enabled(key_timer,true);
  end else MessageDlg('Error cargando cinta/WAV.'+chr(10)+chr(13)+'Error loading tape/WAV.', mtInformation,[mbOk], 0);
  freemem(datos);
  directory.msx_tap:=ExtractFilePath(romfile);
  main_vars.nombre_caption:=cadena;
  change_caption;
end;

function iniciar_msx1:boolean;
var
  temp:array[0..$7fff] of byte;
begin
principal1.BitBtn10.Glyph:=nil;
principal1.imagelist2.GetBitmap(4,principal1.BitBtn10.Glyph);
llamadas_maquina.bucle_general:=msx1_principal;
llamadas_maquina.reset:=reset_msx1;
llamadas_maquina.cartuchos:=abrir_msx1;
llamadas_maquina.cintas:=msx_tapes;
llamadas_maquina.fps_max:=50.158969;
llamadas_maquina.scanlines:=313;
iniciar_msx1:=false;
iniciar_audio(false);
screen_init(1,284,243);
iniciar_video(284,243);
//Main CPU
z80_0:=cpu_z80.create(3579545);
z80_0.change_ram_calls(msx1_getbyte,msx1_putbyte);
z80_0.change_io_calls(msx1_inbyte,msx1_outbyte);
z80_0.change_misc_calls(msx_despues_instruccion,nil,nil);
z80_0.init_sound(msx1_sound_update);
//TMS
tms_0:=tms99xx_chip.create(1,msx1_interrupt);
//Chip Sonido
ay8910_0:=ay8910_chip.create(1789772,AY8910,0.8);
ay8910_0.change_io_calls(ay_porta_read,ay_portb_read,nil,ay_b_write);
tape_sound_channel:=init_channel;
//PPI
pia8255_0:=pia8255_chip.create;
pia8255_0.change_ports(port_a_read,port_b_read,nil,port_a_write,nil,port_c_write);
//cargar roms
if not(roms_load(@temp,mpc100_bios)) then exit;
//if not(roms_load(@temp,nms801_bios)) then exit;
copymemory(@slot[0,0].mem[0],@temp[0],$4000);
copymemory(@slot[0,1].mem[0],@temp[$4000],$4000);
slot[0,0].rom:=true;
slot[0,1].rom:=true;
slot[0,0].ena:=true;
slot[0,1].ena:=true;
slot[3,0].rom:=false;
slot[3,1].rom:=false;
slot[3,2].rom:=false;
slot[3,3].rom:=false;
slot[3,0].ena:=true;
slot[3,1].ena:=true;
slot[3,2].ena:=true;
slot[3,3].ena:=true;
//Timers
key_timer:=timers.init(z80_0.numero_cpu,250000,key_press,nil,false);
iniciar_msx1:=true;
end;

end.

