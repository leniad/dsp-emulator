unit msx1;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,tms99xx,sysutils,dialogs,
     rom_engine,misc_functions,sound_engine,file_engine,ay_8910,ppi8255,
     tape_window;

function iniciar_msx1:boolean;

implementation
uses snapshot,principal,tap_tzx;

const
  mpc100_bios:tipo_roms=(n:'mpc100bios.rom';l:$8000;p:0;crc:$e9ccd789);
  nms801_bios:tipo_roms=(n:'801bios.rom';l:$8000;p:0;crc:$fa089461);
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

procedure eventos_msx1;
begin
if event.keyboard then begin
   //P0
   if keyboard[KEYBOARD_0] then keypad[0]:=(keypad[0] and $fe) else keypad[0]:=(keypad[0] or 1);
   if (keyboard[KEYBOARD_1] and not(keyboard[KEYBOARD_RSHIFT])) then keypad[0]:=(keypad[0] and $fd) else keypad[0]:=(keypad[0] or 2);
   if (keyboard[KEYBOARD_2] and not(keyboard[KEYBOARD_RSHIFT])) then keypad[0]:=(keypad[0] and $fb) else keypad[0]:=(keypad[0] or 4);
   if (keyboard[KEYBOARD_3] and not(keyboard[KEYBOARD_RSHIFT])) then keypad[0]:=(keypad[0] and $f7) else keypad[0]:=(keypad[0] or 8);
   if (keyboard[KEYBOARD_4] and not(keyboard[KEYBOARD_RSHIFT])) then keypad[0]:=(keypad[0] and $ef) else keypad[0]:=(keypad[0] or $10);
   if (keyboard[KEYBOARD_5] and not(keyboard[KEYBOARD_RSHIFT])) then keypad[0]:=(keypad[0] and $df) else keypad[0]:=(keypad[0] or $20);
   if keyboard[KEYBOARD_6] then keypad[0]:=(keypad[0] and $bf) else keypad[0]:=(keypad[0] or $40);
   if keyboard[KEYBOARD_7] then keypad[0]:=(keypad[0] and $7f) else keypad[0]:=(keypad[0] or $80);
   //P1
   if keyboard[KEYBOARD_8] then keypad[1]:=(keypad[1] and $fe) else keypad[1]:=(keypad[1] or 1);
   if keyboard[KEYBOARD_9] then keypad[1]:=(keypad[1] and $fd) else keypad[1]:=(keypad[1] or 2);
   if keyboard[KEYBOARD_FILA3_T3] then keypad[1]:=(keypad[1] and $fb) else keypad[1]:=(keypad[1] or 4);
   //if keyboard[KEYBOARD_=] then keypad[1]:=(keypad[1] and $f7) else keypad[1]:=(keypad[1] or 8);
   if keyboard[KEYBOARD_FILA0_T0] then keypad[1]:=(keypad[1] and $ef) else keypad[1]:=(keypad[1] or $10);
   if keyboard[KEYBOARD_FILA1_T1] then keypad[1]:=(keypad[1] and $df) else keypad[1]:=(keypad[1] or $20);
   if keyboard[KEYBOARD_FILA1_T2] then keypad[1]:=(keypad[1] and $bf) else keypad[1]:=(keypad[1] or $40);
   if keyboard[KEYBOARD_FILA3_T1] then keypad[1]:=(keypad[1] and $7f) else keypad[1]:=(keypad[1] or $80);
   //P2
   if keyboard[KEYBOARD_FILA0_T1] then keypad[2]:=(keypad[2] and $fe) else keypad[2]:=(keypad[2] or 1);
   //if keyboard[KEYBOARD_)] then keypad[2]:=(keypad[2] and $fd) else keypad[2]:=(keypad[2] or 2);
   if keyboard[KEYBOARD_FILA2_T2] then keypad[2]:=(keypad[2] and $fb) else keypad[2]:=(keypad[2] or 4);
   if keyboard[KEYBOARD_FILA3_T2] then keypad[2]:=(keypad[2] and $f7) else keypad[2]:=(keypad[2] or 8);
   //if keyboard[KEYBOARD_/] then keypad[2]:=(keypad[2] and $ef) else keypad[2]:=(keypad[2] or $10);
   //if keyboard[KEYBOARD_*-] then keypad[2]:=(keypad[2] and $df) else keypad[2]:=(keypad[2] or $20);
   if keyboard[KEYBOARD_a] then keypad[2]:=(keypad[2] and $bf) else keypad[2]:=(keypad[2] or $40);
   if keyboard[KEYBOARD_b] then keypad[2]:=(keypad[2] and $7f) else keypad[2]:=(keypad[2] or $80);
   //P3
   if keyboard[KEYBOARD_c] then keypad[3]:=(keypad[3] and $fe) else keypad[3]:=(keypad[3] or 1);
   if keyboard[KEYBOARD_d] then keypad[3]:=(keypad[3] and $fd) else keypad[3]:=(keypad[3] or 2);
   if keyboard[KEYBOARD_e] then keypad[3]:=(keypad[3] and $fb) else keypad[3]:=(keypad[3] or 4);
   if keyboard[KEYBOARD_f] then keypad[3]:=(keypad[3] and $f7) else keypad[3]:=(keypad[3] or 8);
   if keyboard[KEYBOARD_g] then keypad[3]:=(keypad[3] and $ef) else keypad[3]:=(keypad[3] or $10);
   if keyboard[KEYBOARD_h] then keypad[3]:=(keypad[3] and $df) else keypad[3]:=(keypad[3] or $20);
   if keyboard[KEYBOARD_i] then keypad[3]:=(keypad[3] and $bf) else keypad[3]:=(keypad[3] or $40);
   if keyboard[KEYBOARD_j] then keypad[3]:=(keypad[3] and $7f) else keypad[3]:=(keypad[3] or $80);
   //P4
   if keyboard[KEYBOARD_k] then keypad[4]:=(keypad[4] and $fe) else keypad[4]:=(keypad[4] or 1);
   if keyboard[KEYBOARD_l] then keypad[4]:=(keypad[4] and $fd) else keypad[4]:=(keypad[4] or 2);
   if keyboard[KEYBOARD_m] then keypad[4]:=(keypad[4] and $fb) else keypad[4]:=(keypad[4] or 4);
   if keyboard[KEYBOARD_n] then keypad[4]:=(keypad[4] and $f7) else keypad[4]:=(keypad[4] or 8);
   if keyboard[KEYBOARD_o] then keypad[4]:=(keypad[4] and $ef) else keypad[4]:=(keypad[4] or $10);
   if keyboard[KEYBOARD_p] then keypad[4]:=(keypad[4] and $df) else keypad[4]:=(keypad[4] or $20);
   if keyboard[KEYBOARD_q] then keypad[4]:=(keypad[4] and $bf) else keypad[4]:=(keypad[4] or $40);
   if keyboard[KEYBOARD_r] then keypad[4]:=(keypad[4] and $7f) else keypad[4]:=(keypad[4] or $80);
   //P5
   if keyboard[KEYBOARD_s] then keypad[5]:=(keypad[5] and $fe) else keypad[5]:=(keypad[5] or 1);
   if keyboard[KEYBOARD_t] then keypad[5]:=(keypad[5] and $fd) else keypad[5]:=(keypad[5] or 2);
   if keyboard[KEYBOARD_u] then keypad[5]:=(keypad[5] and $fb) else keypad[5]:=(keypad[5] or 4);
   if keyboard[KEYBOARD_v] then keypad[5]:=(keypad[5] and $f7) else keypad[5]:=(keypad[5] or 8);
   if keyboard[KEYBOARD_w] then keypad[5]:=(keypad[5] and $ef) else keypad[5]:=(keypad[5] or $10);
   if keyboard[KEYBOARD_x] then keypad[5]:=(keypad[5] and $df) else keypad[5]:=(keypad[5] or $20);
   if keyboard[KEYBOARD_y] then keypad[5]:=(keypad[5] and $bf) else keypad[5]:=(keypad[5] or $40);
   if keyboard[KEYBOARD_z] then keypad[5]:=(keypad[5] and $7f) else keypad[5]:=(keypad[5] or $80);
   //P6
   if keyboard[KEYBOARD_LSHIFT] then keypad[6]:=(keypad[6] and $fe) else keypad[6]:=(keypad[6] or 1);
   if keyboard[KEYBOARD_LCTRL] then keypad[6]:=(keypad[6] and $fd) else keypad[6]:=(keypad[6] or 2);
   //if keyboard[KEYBOARD_graph] then keypad[6]:=(keypad[6] and $fb) else keypad[6]:=(keypad[6] or 4);
   if keyboard[KEYBOARD_CAPSLOCK] then keypad[6]:=(keypad[6] and $f7) else keypad[6]:=(keypad[6] or 8);
   //if keyboard[KEYBOARD_code] then keypad[6]:=(keypad[6] and $ef) else keypad[6]:=(keypad[6] or $10);
   if (keyboard[KEYBOARD_1] and keyboard[KEYBOARD_RSHIFT]) then keypad[6]:=(keypad[6] and $df) else keypad[6]:=(keypad[6] or $20);
   if (keyboard[KEYBOARD_2] and keyboard[KEYBOARD_RSHIFT]) then keypad[6]:=(keypad[6] and $bf) else keypad[6]:=(keypad[6] or $40);
   if (keyboard[KEYBOARD_3] and keyboard[KEYBOARD_RSHIFT]) then keypad[6]:=(keypad[6] and $7f) else keypad[6]:=(keypad[6] or $80);
   //P7
   if (keyboard[KEYBOARD_4] and keyboard[KEYBOARD_RSHIFT]) then keypad[7]:=(keypad[7] and $fe) else keypad[7]:=(keypad[7] or 1);
   if (keyboard[KEYBOARD_5] and keyboard[KEYBOARD_RSHIFT]) then keypad[7]:=(keypad[7] and $fd) else keypad[7]:=(keypad[7] or 2);
   if keyboard[KEYBOARD_ESCAPE] then keypad[7]:=(keypad[7] and $fb) else keypad[7]:=(keypad[7] or 4);
   if keyboard[KEYBOARD_TAB] then keypad[7]:=(keypad[7] and $f7) else keypad[7]:=(keypad[7] or 8);
   //if keyboard[KEYBOARD_stop] then keypad[7]:=(keypad[7] and $ef) else keypad[7]:=(keypad[7] or $10);
   if keyboard[KEYBOARD_BACKSPACE] then keypad[7]:=(keypad[7] and $df) else keypad[7]:=(keypad[7] or $20);
   //if keyboard[KEYBOARD_select] then keypad[7]:=(keypad[7] and $bf) else keypad[7]:=(keypad[7] or $40);
   if keyboard[KEYBOARD_RETURN] then keypad[7]:=(keypad[7] and $7f) else keypad[7]:=(keypad[7] or $80);
   //P8
   if keyboard[KEYBOARD_SPACE] then keypad[8]:=(keypad[8] and $fe) else keypad[8]:=(keypad[8] or 1);
   if keyboard[KEYBOARD_HOME] then keypad[8]:=(keypad[8] and $fd) else keypad[8]:=(keypad[8] or 2);
   //if keyboard[KEYBOARD_INSERT] then keypad[8]:=(keypad[8] and $fb) else keypad[8]:=(keypad[8] or 4);
   //if keyboard[KEYBOARD_DEL] then keypad[8]:=(keypad[8] and $f7) else keypad[8]:=(keypad[8] or 8);
   if keyboard[KEYBOARD_LEFT] then keypad[8]:=(keypad[8] and $ef) else keypad[8]:=(keypad[8] or $10);
   if keyboard[KEYBOARD_UP] then keypad[8]:=(keypad[8] and $df) else keypad[8]:=(keypad[8] or $20);
   if keyboard[KEYBOARD_DOWN] then keypad[8]:=(keypad[8] and $bf) else keypad[8]:=(keypad[8] or $40);
   if keyboard[KEYBOARD_RIGHT] then keypad[8]:=(keypad[8] and $7f) else keypad[8]:=(keypad[8] or $80);
end;
if event.arcade then begin
   //P1
   if arcade_input.up[0] then joystick[0]:=(joystick[0] and $fe) else joystick[0]:=(joystick[0] or 1);
   if arcade_input.down[0] then joystick[0]:=(joystick[0] and $fd) else joystick[0]:=(joystick[0] or 2);
   if arcade_input.left[0] then joystick[0]:=(joystick[0] and $fb) else joystick[0]:=(joystick[0] or 4);
   if arcade_input.right[0] then joystick[0]:=(joystick[0] and $f7) else joystick[0]:=(joystick[0] or 8);
   if arcade_input.but0[0] then joystick[0]:=(joystick[0] and $ef) else joystick[0]:=(joystick[0] or $10);
   if arcade_input.but1[0] then joystick[0]:=(joystick[0] and $df) else joystick[0]:=(joystick[0] or $20);
   //P2
   if arcade_input.up[1] then joystick[1]:=(joystick[1] and $fe) else joystick[1]:=(joystick[1] or 1);
   if arcade_input.down[1] then joystick[1]:=(joystick[1] and $fd) else joystick[1]:=(joystick[1] or 2);
   if arcade_input.left[1] then joystick[1]:=(joystick[1] and $fb) else joystick[1]:=(joystick[1] or 4);
   if arcade_input.right[1] then joystick[1]:=(joystick[1] and $f7) else joystick[1]:=(joystick[1] or 8);
   if arcade_input.but0[1] then joystick[1]:=(joystick[1] and $ef) else joystick[1]:=(joystick[1] or $10);
   if arcade_input.but1[1] then joystick[1]:=(joystick[1] and $df) else joystick[1]:=(joystick[1] or $20);
end;
end;

procedure msx1_principal;
var
  f:word;
begin
init_controls(false,true,true,false);
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

//Main
procedure reset_msx1;
begin
 z80_0.reset;
 frame_main:=z80_0.tframes;
 pia8255_0.reset;
 ay8910_0.reset;
 tms_0.reset;
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
 fillchar(slot[3,0].mem[0],$4000,0);
 fillchar(slot[3,1].mem[0],$4000,0);
 fillchar(slot[3,2].mem[0],$4000,0);
 fillchar(slot[3,3].mem[0],$4000,0);
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
  //abrir_cartucho(datos,longitud);
  copymemory(@slot[1,1].mem[0],@datos[0],$4000);
  copymemory(@slot[1,2].mem[0],@datos[$4000],$4000);
  slot[1,1].rom:=true;
  slot[1,2].rom:=true;
  slot[1,1].ena:=true;
  slot[1,2].ena:=true;
  reset_msx1;
  freemem(datos);
  change_caption(nombre_file);
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
  end else MessageDlg('Error cargando cinta/WAV.'+chr(10)+chr(13)+'Error loading tape/WAV.', mtInformation,[mbOk], 0);
  freemem(datos);
  directory.msx_tap:=ExtractFilePath(romfile);
  change_caption(cadena);
end;

function iniciar_msx1:boolean;
var
  temp:array[0..$7fff] of byte;
begin
principal1.BitBtn10.Glyph:=nil;
principal1.imagelist2.GetBitmap(4,principal1.BitBtn10.Glyph);
principal1.BitBtn10.OnClick:=principal1.fLoadCartucho;
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
iniciar_msx1:=true;
end;

end.

