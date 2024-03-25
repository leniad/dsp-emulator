unit commodore64;
{$DEFINE CIA_OLD}
interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     main_engine,controls_engine,sysutils,dialogs,misc_functions,
     rom_engine,sound_engine,file_engine,m6502,mos6566,gfx_engine,
     tape_window,sid_sound,cargar_dsk,forms,
     {$IFDEF CIA_OLD}mos6526_old{$ELSE}mos6526{$ENDIF};

function iniciar_c64:boolean;
//CPU
procedure c64_putbyte(direccion:word;valor:byte);

var
    char_rom:array[0..$fff] of byte;
    color_ram:array[0..$3ff] of byte;
    cia_nmi,cia_irq,vic_irq,tape_motor:boolean;
    c64_keyboard,c64_keyboard_i:array[0..7] of byte;

implementation
uses tap_tzx,snapshot;

const
  c64_kernel:tipo_roms=(n:'901227-03.u4';l:$2000;p:$0;crc:$dbe3e7c7);
  c64_basic:tipo_roms=(n:'901226-01.u3';l:$2000;p:$0;crc:$f833d117);
  c64_char:tipo_roms=(n:'901225-01.u5';l:$1000;p:0;crc:$ec4272ee);
var
  kernel_rom,basic_rom:array[0..$1fff] of byte;
  tape_control,port_bits,port_val:byte;
  write_ram:boolean;
  read_ram_a,read_ram_e:boolean;
  read_ram_d:byte;

procedure eventos_c64;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then mos6526_0.joystick1:=(mos6526_0.joystick1 and $fe) else mos6526_0.joystick1:=(mos6526_0.joystick1 or 1);
  if arcade_input.down[0] then mos6526_0.joystick1:=(mos6526_0.joystick1 and $fd) else mos6526_0.joystick1:=(mos6526_0.joystick1 or 2);
  if arcade_input.left[0] then mos6526_0.joystick1:=(mos6526_0.joystick1 and $fb) else mos6526_0.joystick1:=(mos6526_0.joystick1 or 4);
  if arcade_input.right[0] then mos6526_0.joystick1:=(mos6526_0.joystick1 and $f7) else mos6526_0.joystick1:=(mos6526_0.joystick1 or $8);
  if arcade_input.but0[0] then mos6526_0.joystick1:=(mos6526_0.joystick1 and $ef) else mos6526_0.joystick1:=(mos6526_0.joystick1 or $10);
  //P2
  if arcade_input.up[1] then mos6526_0.joystick2:=(mos6526_0.joystick2 and $fe) else mos6526_0.joystick2:=(mos6526_0.joystick2 or 1);
  if arcade_input.down[1] then mos6526_0.joystick2:=(mos6526_0.joystick2 and $fd) else mos6526_0.joystick2:=(mos6526_0.joystick2 or 2);
  if arcade_input.left[1] then mos6526_0.joystick2:=(mos6526_0.joystick2 and $fb) else mos6526_0.joystick2:=(mos6526_0.joystick2 or 4);
  if arcade_input.right[1] then mos6526_0.joystick2:=(mos6526_0.joystick2 and $f7) else mos6526_0.joystick2:=(mos6526_0.joystick2 or 8);
  if arcade_input.but0[1] then mos6526_0.joystick2:=(mos6526_0.joystick2 and $ef) else mos6526_0.joystick2:=(mos6526_0.joystick2 or $10);
end;
if event.keyboard then begin
  if keyboard[KEYBOARD_F1] then begin
      if cinta_tzx.cargada then begin
        if cinta_tzx.play_tape then tape_window1.fStopCinta(nil)
          else tape_window1.fPlayCinta(nil);
      end;
      keyboard[KEYBOARD_F1]:=false;
  end;
  //Line 0
  if keyboard[KEYBOARD_BACKSPACE] then c64_keyboard[0]:=(c64_keyboard[0] and $fe) else c64_keyboard[0]:=(c64_keyboard[0] or $1);
  if keyboard[KEYBOARD_RETURN] then c64_keyboard[0]:=(c64_keyboard[0] and $fd) else c64_keyboard[0]:=(c64_keyboard[0] or $2);
  //if keyboard[KEYBOARD_J] then c64_keyboard[0]:=(c64_keyboard[0] and $fb) else c64_keyboard[0]:=(c64_keyboard[0] or $4);
  if keyboard[KEYBOARD_N7] then c64_keyboard[0]:=(c64_keyboard[0] and $f7) else c64_keyboard[0]:=(c64_keyboard[0] or $8);
  if keyboard[KEYBOARD_N1] then c64_keyboard[0]:=(c64_keyboard[0] and $ef) else c64_keyboard[0]:=(c64_keyboard[0] or $10);
  if keyboard[KEYBOARD_N3] then c64_keyboard[0]:=(c64_keyboard[0] and $df) else c64_keyboard[0]:=(c64_keyboard[0] or $20);
  if keyboard[KEYBOARD_N1] then c64_keyboard[0]:=(c64_keyboard[0] and $bf) else c64_keyboard[0]:=(c64_keyboard[0] or $40);
  //if keyboard[KEYBOARD_N] then c64_keyboard[0]:=(c64_keyboard[0] and $7f) else c64_keyboard[0]:=(c64_keyboard[0] or $80);
  //Line 1
  if keyboard[KEYBOARD_3] then c64_keyboard[1]:=(c64_keyboard[1] and $fe) else c64_keyboard[1]:=(c64_keyboard[1] or $1);
  if keyboard[KEYBOARD_W] then c64_keyboard[1]:=(c64_keyboard[1] and $fd) else c64_keyboard[1]:=(c64_keyboard[1] or $2);
  if keyboard[KEYBOARD_A] then c64_keyboard[1]:=(c64_keyboard[1] and $fb) else c64_keyboard[1]:=(c64_keyboard[1] or $4);
  if keyboard[KEYBOARD_4] then c64_keyboard[1]:=(c64_keyboard[1] and $f7) else c64_keyboard[1]:=(c64_keyboard[1] or $8);
  if keyboard[KEYBOARD_Z] then c64_keyboard[1]:=(c64_keyboard[1] and $ef) else c64_keyboard[1]:=(c64_keyboard[1] or $10);
  if keyboard[KEYBOARD_S] then c64_keyboard[1]:=(c64_keyboard[1] and $df) else c64_keyboard[1]:=(c64_keyboard[1] or $20);
  if keyboard[KEYBOARD_E] then c64_keyboard[1]:=(c64_keyboard[1] and $bf) else c64_keyboard[1]:=(c64_keyboard[1] or $40);
  if keyboard[KEYBOARD_LSHIFT] then c64_keyboard[1]:=(c64_keyboard[1] and $7f) else c64_keyboard[1]:=(c64_keyboard[1] or $80);
  //Line 2
  if keyboard[KEYBOARD_5] then c64_keyboard[2]:=(c64_keyboard[2] and $fe) else c64_keyboard[2]:=(c64_keyboard[2] or $1);
  if keyboard[KEYBOARD_R] then c64_keyboard[2]:=(c64_keyboard[2] and $fd) else c64_keyboard[2]:=(c64_keyboard[2] or $2);
  if keyboard[KEYBOARD_D] then c64_keyboard[2]:=(c64_keyboard[2] and $fb) else c64_keyboard[2]:=(c64_keyboard[2] or $4);
  if keyboard[KEYBOARD_6] then c64_keyboard[2]:=(c64_keyboard[2] and $f7) else c64_keyboard[2]:=(c64_keyboard[2] or $8);
  if keyboard[KEYBOARD_C] then c64_keyboard[2]:=(c64_keyboard[2] and $ef) else c64_keyboard[2]:=(c64_keyboard[2] or $10);
  if keyboard[KEYBOARD_F] then c64_keyboard[2]:=(c64_keyboard[2] and $df) else c64_keyboard[2]:=(c64_keyboard[2] or $20);
  if keyboard[KEYBOARD_T] then c64_keyboard[2]:=(c64_keyboard[2] and $bf) else c64_keyboard[2]:=(c64_keyboard[2] or $40);
  if keyboard[KEYBOARD_X] then c64_keyboard[2]:=(c64_keyboard[2] and $7f) else c64_keyboard[2]:=(c64_keyboard[2] or $80);
  //Line 3
  if keyboard[KEYBOARD_7] then c64_keyboard[3]:=(c64_keyboard[3] and $fe) else c64_keyboard[3]:=(c64_keyboard[3] or $1);
  if keyboard[KEYBOARD_Y] then c64_keyboard[3]:=(c64_keyboard[3] and $fd) else c64_keyboard[3]:=(c64_keyboard[3] or $2);
  if keyboard[KEYBOARD_G] then c64_keyboard[3]:=(c64_keyboard[3] and $fb) else c64_keyboard[3]:=(c64_keyboard[3] or $4);
  if keyboard[KEYBOARD_8] then c64_keyboard[3]:=(c64_keyboard[3] and $f7) else c64_keyboard[3]:=(c64_keyboard[3] or $8);
  if keyboard[KEYBOARD_B] then c64_keyboard[3]:=(c64_keyboard[3] and $ef) else c64_keyboard[3]:=(c64_keyboard[3] or $10);
  if keyboard[KEYBOARD_H] then c64_keyboard[3]:=(c64_keyboard[3] and $df) else c64_keyboard[3]:=(c64_keyboard[3] or $20);
  if keyboard[KEYBOARD_U] then c64_keyboard[3]:=(c64_keyboard[3] and $bf) else c64_keyboard[3]:=(c64_keyboard[3] or $40);
  if keyboard[KEYBOARD_V] then c64_keyboard[3]:=(c64_keyboard[3] and $7f) else c64_keyboard[3]:=(c64_keyboard[3] or $80);
  //Line 4
  if keyboard[KEYBOARD_9] then c64_keyboard[4]:=(c64_keyboard[4] and $fe) else c64_keyboard[4]:=(c64_keyboard[4] or $1);
  if keyboard[KEYBOARD_I] then c64_keyboard[4]:=(c64_keyboard[4] and $fd) else c64_keyboard[4]:=(c64_keyboard[4] or $2);
  if keyboard[KEYBOARD_J] then c64_keyboard[4]:=(c64_keyboard[4] and $fb) else c64_keyboard[4]:=(c64_keyboard[4] or $4);
  if keyboard[KEYBOARD_0] then c64_keyboard[4]:=(c64_keyboard[4] and $f7) else c64_keyboard[4]:=(c64_keyboard[4] or $8);
  if keyboard[KEYBOARD_M] then c64_keyboard[4]:=(c64_keyboard[4] and $ef) else c64_keyboard[4]:=(c64_keyboard[4] or $10);
  if keyboard[KEYBOARD_K] then c64_keyboard[4]:=(c64_keyboard[4] and $df) else c64_keyboard[4]:=(c64_keyboard[4] or $20);
  if keyboard[KEYBOARD_O] then c64_keyboard[4]:=(c64_keyboard[4] and $bf) else c64_keyboard[4]:=(c64_keyboard[4] or $40);
  if keyboard[KEYBOARD_N] then c64_keyboard[4]:=(c64_keyboard[4] and $7f) else c64_keyboard[4]:=(c64_keyboard[4] or $80);
  //Line 5
  if keyboard[KEYBOARD_FILA1_T2] then c64_keyboard[5]:=(c64_keyboard[5] and $fe) else c64_keyboard[5]:=(c64_keyboard[5] or $1);
  if keyboard[KEYBOARD_P] then c64_keyboard[5]:=(c64_keyboard[5] and $fd) else c64_keyboard[5]:=(c64_keyboard[5] or $2);
  if keyboard[KEYBOARD_L] then c64_keyboard[5]:=(c64_keyboard[5] and $fb) else c64_keyboard[5]:=(c64_keyboard[5] or $4);
  if keyboard[KEYBOARD_FILA3_T3] then c64_keyboard[5]:=(c64_keyboard[5] and $f7) else c64_keyboard[5]:=(c64_keyboard[5] or $8);
  if keyboard[KEYBOARD_FILA3_T2] then c64_keyboard[5]:=(c64_keyboard[5] and $ef) else c64_keyboard[5]:=(c64_keyboard[5] or $10);
  //if keyboard[KEYBOARD_K] then c64_keyboard[5]:=(c64_keyboard[5] and $df) else c64_keyboard[5]:=(c64_keyboard[5] or $20);
  //if keyboard[KEYBOARD_O] then c64_keyboard[5]:=(c64_keyboard[5] and $bf) else c64_keyboard[5]:=(c64_keyboard[5] or $40);
  if keyboard[KEYBOARD_FILA3_T1] then c64_keyboard[5]:=(c64_keyboard[5] and $7f) else c64_keyboard[5]:=(c64_keyboard[5] or $80);
  //Line 6
  //if keyboard[KEYBOARD_9] then c64_keyboard[6]:=(c64_keyboard[6] and $fe) else c64_keyboard[6]:=(c64_keyboard[6] or $1);
  //if keyboard[KEYBOARD_I] then c64_keyboard[6]:=(c64_keyboard[6] and $fd) else c64_keyboard[6]:=(c64_keyboard[6] or $2);
  //if keyboard[KEYBOARD_J] then c64_keyboard[6]:=(c64_keyboard[6] and $fb) else c64_keyboard[6]:=(c64_keyboard[6] or $4);
  //if keyboard[KEYBOARD_0] then c64_keyboard[6]:=(c64_keyboard[6] and $f7) else c64_keyboard[6]:=(c64_keyboard[6] or $8);
  if keyboard[KEYBOARD_RSHIFT] then c64_keyboard[6]:=(c64_keyboard[6] and $ef) else c64_keyboard[6]:=(c64_keyboard[6] or $10);
  //if keyboard[KEYBOARD_K] then c64_keyboard[6]:=(c64_keyboard[6] and $df) else c64_keyboard[6]:=(c64_keyboard[6] or $20);
  //if keyboard[KEYBOARD_O] then c64_keyboard[6]:=(c64_keyboard[6] and $bf) else c64_keyboard[6]:=(c64_keyboard[6] or $40);
  //if keyboard[KEYBOARD_N] then c64_keyboard[6]:=(c64_keyboard[6] and $7f) else c64_keyboard[6]:=(c64_keyboard[6] or $80);
  //Line 7
  if keyboard[KEYBOARD_1] then begin
    c64_keyboard[7]:=(c64_keyboard[7] and $fe);
    c64_keyboard_i[0]:=(c64_keyboard_i[0] and $fe);
   end else begin
    c64_keyboard[7]:=(c64_keyboard[7] or $1);
    c64_keyboard_i[0]:=(c64_keyboard_i[0] or $1);
   end;
  //if keyboard[KEYBOARD_I] then c64_keyboard[7]:=(c64_keyboard[7] and $fd) else c64_keyboard[7]:=(c64_keyboard[7] or $2);
  if keyboard[KEYBOARD_RCTRL] then c64_keyboard[7]:=(c64_keyboard[7] and $fb) else c64_keyboard[7]:=(c64_keyboard[7] or $4);
  if keyboard[KEYBOARD_2] then begin
    c64_keyboard[7]:=(c64_keyboard[7] and $f7);
    c64_keyboard_i[3]:=(c64_keyboard_i[3] and $f7);
  end else begin
    c64_keyboard[7]:=(c64_keyboard[7] or $8);
    c64_keyboard_i[3]:=(c64_keyboard_i[3] or $8);
  end;
  if keyboard[KEYBOARD_SPACE] then c64_keyboard[7]:=(c64_keyboard[7] and $ef) else c64_keyboard[7]:=(c64_keyboard[7] or $10);
  //if keyboard[KEYBOARD_K] then c64_keyboard[7]:=(c64_keyboard[7] and $df) else c64_keyboard[7]:=(c64_keyboard[7] or $20);
  if keyboard[KEYBOARD_Q] then c64_keyboard[7]:=(c64_keyboard[7] and $bf) else c64_keyboard[7]:=(c64_keyboard[7] or $40);
  if keyboard[KEYBOARD_ESCAPE] then c64_keyboard[7]:=(c64_keyboard[7] and $7f) else c64_keyboard[7]:=(c64_keyboard[7] or $80);
end;
end;

procedure c64_principal;
var
  f:word;
  frame:single;
begin
init_controls(false,false,false,true);
frame:=0;
while EmuStatus=EsRunning do begin
 for f:=0 to 311 do begin
    frame:=frame+mos6566_0.update(f);
    m6502_0.run(frame);
    frame:=frame-m6502_0.contador;
    if ((f>15) and (f<286)) then putpixel(0,f-16,384,punbuf,1);
 end;
 actualiza_trozo_simple(0,0,384,284,1);
 eventos_c64;
 video_sync;
end;
end;

function c64_getbyte(direccion:word):byte;
begin
case direccion of
  0:c64_getbyte:=port_bits;
  1:c64_getbyte:=tape_control or (byte(not(tape_motor))*$20) or (port_val and $7);
  2..$9fff,$c000..$cfff:c64_getbyte:=memoria[direccion];
  $a000..$bfff:if read_ram_a then c64_getbyte:=memoria[direccion]
                  else c64_getbyte:=basic_rom[direccion and $1fff];
  $d000..$dfff:case read_ram_d of
                  0:c64_getbyte:=memoria[direccion];
                  1:c64_getbyte:=char_rom[direccion and $fff];
                  2:case ((direccion shr 8) and $f) of
                      0..3:c64_getbyte:=mos6566_0.read(direccion and $3f);   //VICII
                      4..7:c64_getbyte:=sid_0.read(direccion and $1f); //SID
                      8..$b:c64_getbyte:=color_ram[direccion and $3ff];
                      {$IFDEF CIA_OLD}
                      $c:c64_getbyte:=mos6526_0.read(direccion and $f); //CIA1
                      $d:c64_getbyte:=mos6526_1.read(direccion and $f); //CIA2
                      {$ELSE}
                      $c:c64_getbyte:=mos6526_0.read1(direccion and $f); //CIA1
                      $d:c64_getbyte:=mos6526_0.read2(direccion and $f); //CIA2
                      {$ENDIF}
                      $e..$f:c64_getbyte:=$ff;//MessageDlg('Leyendo de la expansion...', mtInformation,[mbOk], 0);
                    end;
               end;
  $e000..$ffff:if read_ram_e then c64_getbyte:=memoria[direccion]
                  else c64_getbyte:=kernel_rom[direccion and $1fff];
end;
end;

procedure actualiza_mem;
var
  res:byte;
begin
res:=port_val or not(port_bits);
tape_motor:=(port_val and $20)=0;
case (res and 7) of
  0:begin
      write_ram:=true;
      read_ram_d:=0;
      read_ram_a:=true;
      read_ram_e:=true;
    end;
  1:begin
      write_ram:=true;
      read_ram_d:=1;
      read_ram_a:=true;
      read_ram_e:=true;
    end;
  2:begin
      write_ram:=true;
      read_ram_d:=1;
      read_ram_a:=true;
      read_ram_e:=false;
    end;
  3:begin
      write_ram:=true;
      read_ram_d:=1;
      read_ram_a:=false;
      read_ram_e:=false;
    end;
  4:begin
      write_ram:=true;
      read_ram_d:=0;
      read_ram_a:=true;
      read_ram_e:=true;
    end;
  5:begin
      write_ram:=false;
      read_ram_d:=2;
      read_ram_a:=true;
      read_ram_e:=true;
    end;
  6:begin
      write_ram:=false;
      read_ram_d:=2;
      read_ram_a:=true;
      read_ram_e:=false;
    end;
  7:begin
      write_ram:=false;
      read_ram_d:=2;
      read_ram_a:=false;
      read_ram_e:=false;
    end;
end;
end;

procedure c64_putbyte(direccion:word;valor:byte);
begin
case direccion of
    0:begin
        port_bits:=valor;
        actualiza_mem;
      end;
    1:begin
        port_val:=valor;
        actualiza_mem;
      end;
    $d000..$dfff:if write_ram then memoria[direccion]:=valor
                  else case ((direccion shr 8) and $f) of
                        0..3:mos6566_0.write(direccion and $3f,valor); //VICII
                        4..7:sid_0.write(direccion and $1f,valor); //SID
                        8..$b:color_ram[direccion and $3ff]:=valor and $f;
                        {$IFDEF CIA_OLD}
                        $c:mos6526_0.write(direccion and $f,valor); //CIA1
                        $d:mos6526_1.write(direccion and $f,valor); //CIA2
                        {$ELSE}
                        $c:mos6526_0.write1(direccion and $f,valor); //CIA1
                        $d:mos6526_0.write2(direccion and $f,valor); //CIA2
                        {$ENDIF}
                        $e..$f:;//MessageDlg('Escribiendo en la expansion...', mtInformation,[mbOk], 0);
                       end;
    2..$cfff,$e000..$ffff:memoria[direccion]:=valor;
end;
end;

{$IFDEF CIA_OLD}
function cia1_portb_r:byte;
var
  ret:byte;
begin
  ret:=$ff;
  //Filas
  if ((mos6526_0.pa and $01)=0) then ret:=ret and c64_keyboard[0];
  if ((mos6526_0.pa and $02)=0) then ret:=ret and c64_keyboard[1];
  if ((mos6526_0.pa and $04)=0) then ret:=ret and c64_keyboard[2];
  if ((mos6526_0.pa and $08)=0) then ret:=ret and c64_keyboard[3];
  if ((mos6526_0.pa and $10)=0) then ret:=ret and c64_keyboard[4];
  if ((mos6526_0.pa and $20)=0) then ret:=ret and c64_keyboard[5];
  if ((mos6526_0.pa and $40)=0) then ret:=ret and c64_keyboard[6];
  if ((mos6526_0.pa and $80)=0) then ret:=ret and c64_keyboard[7];
  cia1_portb_r:=ret;
end;

procedure cia2_porta_w(valor:byte);
begin
  mos6566_0.ChangedVA(not(valor) and 3);
end;

procedure cia2_portb_w(valor:byte);
begin
end;
{$ENDIF}

procedure c64_cia_irq(state:byte);
begin
  cia_irq:=(state=ASSERT_LINE);
  if not(cia_irq) then m6502_0.change_irq(CLEAR_LINE);
end;

procedure c64_vic_irq(state:byte);
begin
  vic_irq:=(state=ASSERT_LINE);
  if not(vic_irq) then m6502_0.change_irq(CLEAR_LINE);
end;

procedure c64_nmi(state:byte);
begin
  cia_nmi:=(state=ASSERT_LINE);
  if not(cia_nmi) then m6502_0.change_nmi(CLEAR_LINE);
end;

procedure c64_despues_instruccion(tstates:word);
begin
  if (cia_irq or vic_irq) then m6502_0.change_irq(ASSERT_LINE);
  if cia_nmi then m6502_0.change_nmi(ASSERT_LINE);
  if cinta_tzx.cargada then begin
    if cinta_tzx.play_tape then begin
      if tape_motor then begin
        mos6526_0.flag_w(cinta_tzx.value shr 6);
        //3500/985 =3.5524
        play_cinta_tzx(tstates);
      end;
    end;
  end;
  {$IFDEF CIA_OLD}
  mos6526_0.sync(tstates);
  mos6526_1.sync(tstates);
  {$ELSE}
  mos6526_0.EmulateLine1(tstates);
  mos6526_0.EmulateLine2(tstates);
  {$ENDIF}
end;

procedure c64_reset;
var
  f:byte;
begin
fillchar(memoria[0],$10000,0);
//SIEMPRE ESTO PRIMERO PARA PONER LOS VALORES DE RESET DE LA CPU!!!
port_bits:=$ef;
port_val:=$ef;
actualiza_mem;
m6502_0.reset;
mos6526_0.reset;
{$IFDEF CIA_OLD}
mos6526_1.reset;
{$ENDIF}
mos6566_0.reset;
sid_0.reset;
reset_audio;
for f:=0 to 7 do begin
  c64_keyboard[f]:=$ff;
  c64_keyboard_i[f]:=$ff;
end;
tape_control:=$10;
vic_irq:=false;
cia_irq:=false;
cia_nmi:=false;
tape_motor:=false;
write_ram:=false;
read_ram_a:=false;
read_ram_e:=false;
read_ram_d:=2;
end;

procedure c64_tape_start;
begin
  main_screen.rapido:=true;
  tape_control:=$0;
end;

procedure c64_tape_stop;
begin
  main_screen.rapido:=false;
  tape_control:=$10;
end;

procedure c64_sound_update;
begin
  sid_0.update;
end;

procedure c64_cerrar;
begin
end;

procedure c64_loaddisk;
begin
load_dsk.show;
while load_dsk.Showing do application.ProcessMessages;
end;

procedure c64_tapes;
var
  datos:pbyte;
  longitud:integer;
  romfile,nombre_file,extension,cadena:string;
  resultado,es_cinta:boolean;
begin
  if not(openrom(romfile)) then exit;
  getmem(datos,$400000);
  if not(extract_data(romfile,datos,longitud,nombre_file)) then begin
    freemem(datos);
    exit;
  end;
  extension:=extension_fichero(nombre_file);
  resultado:=false;
  es_cinta:=true;
  if extension='TAP' then resultado:=abrir_c64_tap(datos,longitud);
  if extension='WAV' then resultado:=abrir_wav(datos,longitud,985248);
  if extension='PRG' then begin
      es_cinta:=false;
      resultado:=abrir_prg(datos,longitud);
   end;
  if extension='T64' then begin
     es_cinta:=false;
     resultado:=abrir_t64(datos,longitud);
   end;
  if extension='VSF' then begin
     es_cinta:=false;
     resultado:=abrir_vsf(datos,longitud);
   end;
  if es_cinta then begin
     if resultado then begin
        tape_window1.edit1.Text:=nombre_file;
        tape_window1.show;
        tape_window1.BitBtn1.Enabled:=true;
        tape_window1.BitBtn2.Enabled:=false;
        cinta_tzx.play_tape:=false;
        cadena:=extension+': '+nombre_file;
     end else begin
        MessageDlg('Error cargando cinta/WAV.'+chr(10)+chr(13)+'Error loading tape/WAV.', mtInformation,[mbOk], 0);
        cadena:='';
     end;
  end;
  freemem(datos);
  directory.c64_tap:=ExtractFilePath(romfile);
  change_caption(cadena);
end;

function iniciar_c64:boolean;
begin
  llamadas_maquina.bucle_general:=c64_principal;
  llamadas_maquina.close:=c64_cerrar;
  llamadas_maquina.reset:=c64_reset;
  llamadas_maquina.fps_max:=985248/(312*63);
  llamadas_maquina.cintas:=c64_tapes;
  llamadas_maquina.cartuchos:=c64_loaddisk;
  iniciar_c64:=false;
  iniciar_audio(true);
  //Total --> 504x312
  //Linea --> 76 HBLANK
  //          48 Borde
  //           7 Borde 38 cols o visible si 40 cols
  //         304 Siempre visible
  //           9 Borde 38 cols o visible si 40 cols
  //          37 Borde
  //          23 HBLANK
  //          -----> Total Visible --> 405 pixels
  // Lineas Verticales
  //  15 VBLANK
  //  35 Borde
  //   4 Borde 38 cols o visible si 40 cols
  // 192 visible
  //   4 Borde 30 cols o visible si 40 cols
  //  49 Borde
  //  12 VBLANK
  //  ---------> Total visible  284
  screen_init(1,384,270);
  iniciar_video(384,270);
  m6502_0:=cpu_m6502.create(985248,312,TCPU_M6502);
  m6502_0.change_ram_calls(c64_getbyte,c64_putbyte);
  m6502_0.change_despues_instruccion(c64_despues_instruccion);
  m6502_0.init_sound(c64_sound_update);
  if not(roms_load(@kernel_rom,c64_kernel)) then exit;
  if not(roms_load(@basic_rom,c64_basic)) then exit;
  if not(roms_load(@char_rom,c64_char)) then exit;
  //CIA
  {$IFDEF CIA_OLD}
  mos6526_0:=mos6526_chip.create(985248);
  mos6526_0.change_calls(nil,cia1_portb_r,nil,nil,c64_cia_irq);
  mos6526_1:=mos6526_chip.create(985248);
  mos6526_1.change_calls(nil,nil,cia2_porta_w,cia2_portb_w,c64_nmi);
  {$ELSE}
  mos6526_0:=mos6526_chip.create(985248);
  mos6526_0.change_calls(nil,nil,nil,nil,c64_cia_irq,c64_nmi);
  {$ENDIF}
  //VIDEO
  mos6566_0:=mos6566_chip.create(985248);
  mos6566_0.change_calls(c64_vic_irq);
  sid_0:=sid_chip.create(985248,TYPE_6581);
  c64_reset;
  iniciar_c64:=true;
  cinta_tzx.tape_start:=c64_tape_start;
  cinta_tzx.tape_stop:=c64_tape_stop;
end;

end.
