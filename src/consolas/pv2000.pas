unit pv2000;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,sysutils,sound_engine,misc_functions,
     tms99xx,sn_76496,rom_engine;

function iniciar_pv2000:boolean;

type
  tpv2000=record
    last_nmi:boolean;
    last_key,keyb_column:byte;
    keys:array[0..10] of byte;
  end;

var
  pv2000_0:tpv2000;

implementation
uses principal,snapshot;

const
  pv2000_bios:tipo_roms=(n:'hn613128pc64.bin';l:$4000;p:0;crc:$8f31f297);

procedure eventos_pv2000;
begin
if event.keyboard then begin
  //in0
  if keyboard[KEYBOARD_4] then pv2000_0.keys[0]:=(pv2000_0.keys[0] or 1) else pv2000_0.keys[0]:=(pv2000_0.keys[0] and $fe);
  if keyboard[KEYBOARD_3] then pv2000_0.keys[0]:=(pv2000_0.keys[0] or 2) else pv2000_0.keys[0]:=(pv2000_0.keys[0] and $fd);
  if keyboard[KEYBOARD_2] then pv2000_0.keys[0]:=(pv2000_0.keys[0] or 4) else pv2000_0.keys[0]:=(pv2000_0.keys[0] and $fb);
  if keyboard[KEYBOARD_1] then pv2000_0.keys[0]:=(pv2000_0.keys[0] or 8) else pv2000_0.keys[0]:=(pv2000_0.keys[0] and $f7);
  if keyboard[KEYBOARD_8] then pv2000_0.keys[0]:=(pv2000_0.keys[0] or $10) else pv2000_0.keys[0]:=(pv2000_0.keys[0] and $ef);
  if keyboard[KEYBOARD_7] then pv2000_0.keys[0]:=(pv2000_0.keys[0] or $20) else pv2000_0.keys[0]:=(pv2000_0.keys[0] and $df);
  if keyboard[KEYBOARD_6] then pv2000_0.keys[0]:=(pv2000_0.keys[0] or $40) else pv2000_0.keys[0]:=(pv2000_0.keys[0] and $bf);
  if keyboard[KEYBOARD_5] then pv2000_0.keys[0]:=(pv2000_0.keys[0] or $80) else pv2000_0.keys[0]:=(pv2000_0.keys[0] and $7f);
  //in1
  if keyboard[KEYBOARD_R] then pv2000_0.keys[1]:=(pv2000_0.keys[1] or 1) else pv2000_0.keys[1]:=(pv2000_0.keys[1] and $fe);
  if keyboard[KEYBOARD_E] then pv2000_0.keys[1]:=(pv2000_0.keys[1] or 2) else pv2000_0.keys[1]:=(pv2000_0.keys[1] and $fd);
  if keyboard[KEYBOARD_W] then pv2000_0.keys[1]:=(pv2000_0.keys[1] or 4) else pv2000_0.keys[1]:=(pv2000_0.keys[1] and $fb);
  if keyboard[KEYBOARD_Q] then pv2000_0.keys[1]:=(pv2000_0.keys[1] or 8) else pv2000_0.keys[1]:=(pv2000_0.keys[1] and $f7);
  if keyboard[KEYBOARD_I] then pv2000_0.keys[1]:=(pv2000_0.keys[1] or $10) else pv2000_0.keys[1]:=(pv2000_0.keys[1] and $ef);
  if keyboard[KEYBOARD_U] then pv2000_0.keys[1]:=(pv2000_0.keys[1] or $20) else pv2000_0.keys[1]:=(pv2000_0.keys[1] and $df);
  if keyboard[KEYBOARD_Y] then pv2000_0.keys[1]:=(pv2000_0.keys[1] or $40) else pv2000_0.keys[1]:=(pv2000_0.keys[1] and $bf);
  if keyboard[KEYBOARD_T] then pv2000_0.keys[1]:=(pv2000_0.keys[1] or $80) else pv2000_0.keys[1]:=(pv2000_0.keys[1] and $7f);
  //in2
  if keyboard[KEYBOARD_F] then pv2000_0.keys[2]:=(pv2000_0.keys[2] or 1) else pv2000_0.keys[2]:=(pv2000_0.keys[2] and $fe);
  if keyboard[KEYBOARD_D] then pv2000_0.keys[2]:=(pv2000_0.keys[2] or 2) else pv2000_0.keys[2]:=(pv2000_0.keys[2] and $fd);
  if keyboard[KEYBOARD_S] then pv2000_0.keys[2]:=(pv2000_0.keys[2] or 4) else pv2000_0.keys[2]:=(pv2000_0.keys[2] and $fb);
  if keyboard[KEYBOARD_A] then pv2000_0.keys[2]:=(pv2000_0.keys[2] or 8) else pv2000_0.keys[2]:=(pv2000_0.keys[2] and $f7);
  if keyboard[KEYBOARD_K] then pv2000_0.keys[2]:=(pv2000_0.keys[2] or $10) else pv2000_0.keys[2]:=(pv2000_0.keys[2] and $ef);
  if keyboard[KEYBOARD_J] then pv2000_0.keys[2]:=(pv2000_0.keys[2] or $20) else pv2000_0.keys[2]:=(pv2000_0.keys[2] and $df);
  if keyboard[KEYBOARD_H] then pv2000_0.keys[2]:=(pv2000_0.keys[2] or $40) else pv2000_0.keys[2]:=(pv2000_0.keys[2] and $bf);
  if keyboard[KEYBOARD_G] then pv2000_0.keys[2]:=(pv2000_0.keys[2] or $80) else pv2000_0.keys[2]:=(pv2000_0.keys[2] and $7f);
  //in3
  if keyboard[KEYBOARD_C] then pv2000_0.keys[3]:=(pv2000_0.keys[3] or 1) else pv2000_0.keys[3]:=(pv2000_0.keys[3] and $fe);
  if keyboard[KEYBOARD_X] then pv2000_0.keys[3]:=(pv2000_0.keys[3] or 2) else pv2000_0.keys[3]:=(pv2000_0.keys[3] and $fd);
  if keyboard[KEYBOARD_Z] then pv2000_0.keys[3]:=(pv2000_0.keys[3] or 4) else pv2000_0.keys[3]:=(pv2000_0.keys[3] and $fb);
  //if keyboard[KEYBOARD_] then pv2000_0.keys[3]:=(pv2000_0.keys[3] or 8) else pv2000_0.keys[3]:=(pv2000_0.keys[3] and $f7);
  if keyboard[KEYBOARD_SPACE] then pv2000_0.keys[3]:=(pv2000_0.keys[3] or $10) else pv2000_0.keys[3]:=(pv2000_0.keys[3] and $ef);
  if keyboard[KEYBOARD_N] then pv2000_0.keys[3]:=(pv2000_0.keys[3] or $20) else pv2000_0.keys[3]:=(pv2000_0.keys[3] and $df);
  if keyboard[KEYBOARD_B] then pv2000_0.keys[3]:=(pv2000_0.keys[3] or $40) else pv2000_0.keys[3]:=(pv2000_0.keys[3] and $bf);
  if keyboard[KEYBOARD_V] then pv2000_0.keys[3]:=(pv2000_0.keys[3] or $80) else pv2000_0.keys[3]:=(pv2000_0.keys[3] and $7f);
  //in4
  //if keyboard[KEYBOARD_] then pv2000_0.keys[4]:=(pv2000_0.keys[4] or 1) else pv2000_0.keys[4]:=(pv2000_0.keys[4] and $fe);
  //if keyboard[KEYBOARD_] then pv2000_0.keys[4]:=(pv2000_0.keys[4] or 2) else pv2000_0.keys[4]:=(pv2000_0.keys[4] and $fd);
  //if keyboard[KEYBOARD_] then pv2000_0.keys[4]:=(pv2000_0.keys[4] or 4) else pv2000_0.keys[4]:=(pv2000_0.keys[4] and $fb);
  if keyboard[KEYBOARD_HOME] then pv2000_0.keys[4]:=(pv2000_0.keys[4] or 8) else pv2000_0.keys[4]:=(pv2000_0.keys[4] and $f7);
  if keyboard[KEYBOARD_9] then pv2000_0.keys[4]:=(pv2000_0.keys[4] or $10) else pv2000_0.keys[4]:=(pv2000_0.keys[4] and $ef);
  if keyboard[KEYBOARD_FILA3_T3] then pv2000_0.keys[4]:=(pv2000_0.keys[4] or $20) else pv2000_0.keys[4]:=(pv2000_0.keys[4] and $df);
  if keyboard[KEYBOARD_FILA3_T0] then pv2000_0.keys[4]:=(pv2000_0.keys[4] or $40) else pv2000_0.keys[4]:=(pv2000_0.keys[4] and $bf);
  if keyboard[KEYBOARD_0] then pv2000_0.keys[4]:=(pv2000_0.keys[4] or $80) else pv2000_0.keys[4]:=(pv2000_0.keys[4] and $7f);
  //in5
  if keyboard[KEYBOARD_N7] then pv2000_0.keys[5]:=(pv2000_0.keys[5] or 1) else pv2000_0.keys[5]:=(pv2000_0.keys[5] and $fe);
  if keyboard[KEYBOARD_N1] then pv2000_0.keys[5]:=(pv2000_0.keys[5] or 2) else pv2000_0.keys[5]:=(pv2000_0.keys[5] and $fd);
  if keyboard[KEYBOARD_N3] then pv2000_0.keys[5]:=(pv2000_0.keys[5] or 4) else pv2000_0.keys[5]:=(pv2000_0.keys[5] and $fb);
  if keyboard[KEYBOARD_N9] then pv2000_0.keys[5]:=(pv2000_0.keys[5] or 8) else pv2000_0.keys[5]:=(pv2000_0.keys[5] and $f7);
  if keyboard[KEYBOARD_O] then pv2000_0.keys[5]:=(pv2000_0.keys[5] or $10) else pv2000_0.keys[5]:=(pv2000_0.keys[5] and $ef);
  if keyboard[KEYBOARD_FILA2_T1] then pv2000_0.keys[5]:=(pv2000_0.keys[5] or $20) else pv2000_0.keys[5]:=(pv2000_0.keys[5] and $df);
  if keyboard[KEYBOARD_FILA1_T1] then pv2000_0.keys[5]:=(pv2000_0.keys[5] or $40) else pv2000_0.keys[5]:=(pv2000_0.keys[5] and $bf);
  if keyboard[KEYBOARD_P] then pv2000_0.keys[5]:=(pv2000_0.keys[5] or $80) else pv2000_0.keys[5]:=(pv2000_0.keys[5] and $7f);
  //in6
  //down
  //right
  //if keyboard[KEYBOARD_] then pv2000_0.keys[6]:=(pv2000_0.keys[6] or 4) else pv2000_0.keys[6]:=(pv2000_0.keys[6] and $fb);
  //if keyboard[KEYBOARD_] then pv2000_0.keys[6]:=(pv2000_0.keys[6] or 8) else pv2000_0.keys[6]:=(pv2000_0.keys[6] and $f7);
  if keyboard[KEYBOARD_L] then pv2000_0.keys[6]:=(pv2000_0.keys[6] or $10) else pv2000_0.keys[6]:=(pv2000_0.keys[6] and $ef);
  //if keyboard[KEYBOARD_] then pv2000_0.keys[6]:=(pv2000_0.keys[6] or $20) else pv2000_0.keys[6]:=(pv2000_0.keys[6] and $df);
  if keyboard[KEYBOARD_FILA1_T2] then pv2000_0.keys[6]:=(pv2000_0.keys[6] or $40) else pv2000_0.keys[6]:=(pv2000_0.keys[6] and $bf);
  //if keyboard[KEYBOARD_] then pv2000_0.keys[6]:=(pv2000_0.keys[6] or $80) else pv2000_0.keys[6]:=(pv2000_0.keys[6] and $7f);
  //in7
  //left
  //up
  //if keyboard[KEYBOARD_] then pv2000_0.keys[7]:=(pv2000_0.keys[7] or 4) else pv2000_0.keys[7]:=(pv2000_0.keys[7] and $fb);
  //if keyboard[KEYBOARD_] then pv2000_0.keys[7]:=(pv2000_0.keys[7] or 8) else pv2000_0.keys[7]:=(pv2000_0.keys[7] and $f7);
  if keyboard[KEYBOARD_M] then pv2000_0.keys[7]:=(pv2000_0.keys[7] or $10) else pv2000_0.keys[7]:=(pv2000_0.keys[7] and $ef);
  if keyboard[KEYBOARD_FILA3_T2] then pv2000_0.keys[7]:=(pv2000_0.keys[7] or $20) else pv2000_0.keys[7]:=(pv2000_0.keys[7] and $df);
  //if keyboard[KEYBOARD_] then pv2000_0.keys[7]:=(pv2000_0.keys[7] or $40) else pv2000_0.keys[7]:=(pv2000_0.keys[7] and $bf);
  if keyboard[KEYBOARD_FILA3_T1] then pv2000_0.keys[7]:=(pv2000_0.keys[7] or $80) else pv2000_0.keys[7]:=(pv2000_0.keys[7] and $7f);
  //in8
  //boton 0
  //boton 1
  //if keyboard[KEYBOARD_] then pv2000_0.keys[8]:=(pv2000_0.keys[8] or 4) else pv2000_0.keys[8]:=(pv2000_0.keys[8] and $fb);
  //if keyboard[KEYBOARD_] then pv2000_0.keys[8]:=(pv2000_0.keys[8] or 8) else pv2000_0.keys[8]:=(pv2000_0.keys[8] and $f7);
  if keyboard[KEYBOARD_RETURN] then pv2000_0.keys[8]:=(pv2000_0.keys[8] or $10) else pv2000_0.keys[8]:=(pv2000_0.keys[8] and $ef);
  //if keyboard[KEYBOARD_] then pv2000_0.keys[8]:=(pv2000_0.keys[8] or $20) else pv2000_0.keys[8]:=(pv2000_0.keys[8] and $df);
  if keyboard[KEYBOARD_BACKSPACE] then pv2000_0.keys[8]:=(pv2000_0.keys[8] or $40) else pv2000_0.keys[8]:=(pv2000_0.keys[8] and $bf);
  //if keyboard[KEYBOARD_] then pv2000_0.keys[8]:=(pv2000_0.keys[8] or $80) else pv2000_0.keys[8]:=(pv2000_0.keys[8] and $7f);
  //in9
  //in10
  //if keyboard[KEYBOARD_] then pv2000_0.keys[1]:=(pv2000_0.keys[1] or 1) else pv2000_0.keys[1]:=(pv2000_0.keys[1] and $fe);
  //if keyboard[KEYBOARD_] then pv2000_0.keys[1]:=(pv2000_0.keys[1] or 2) else pv2000_0.keys[1]:=(pv2000_0.keys[1] and $fd);
  if keyboard[KEYBOARD_LSHIFT] then pv2000_0.keys[10]:=(pv2000_0.keys[10] or 4) else pv2000_0.keys[10]:=(pv2000_0.keys[10] and $fb);
end;
if event.arcade then begin
   //P1
   if arcade_input.but0[0] then pv2000_0.keys[8]:=(pv2000_0.keys[8] or 1) else pv2000_0.keys[8]:=(pv2000_0.keys[8] and $fe);
   if arcade_input.but1[0] then pv2000_0.keys[8]:=(pv2000_0.keys[8] or 2) else pv2000_0.keys[8]:=(pv2000_0.keys[8] and $fd);
   if arcade_input.left[0] then pv2000_0.keys[7]:=(pv2000_0.keys[7] or 1) else pv2000_0.keys[7]:=(pv2000_0.keys[7] and $fe);
   if arcade_input.up[0] then pv2000_0.keys[7]:=(pv2000_0.keys[7] or 2) else pv2000_0.keys[7]:=(pv2000_0.keys[7] and $fd);
   if arcade_input.down[0] then pv2000_0.keys[6]:=(pv2000_0.keys[6] or 1) else pv2000_0.keys[6]:=(pv2000_0.keys[6] and $fe);
   if arcade_input.right[0] then pv2000_0.keys[6]:=(pv2000_0.keys[6] or 2) else pv2000_0.keys[6]:=(pv2000_0.keys[6] and $fd);
end;
end;

procedure pv2000_principal;
var
  frame:single;
  f:word;
begin
init_controls(false,true,false,true);
frame:=z80_0.tframes;
while EmuStatus=EsRunning do begin
  for f:=0 to 261 do begin
      z80_0.run(frame);
      frame:=frame+z80_0.tframes-z80_0.contador;
      tms_0.refresh(f);
  end;
  actualiza_trozo(0,0,284,243,1,0,0,284,243,PANT_TEMP);
  eventos_pv2000;
  video_sync;
end;
end;

function pv2000_getbyte(direccion:word):byte;
begin
  case direccion of
    0..$3fff,$7000..$7fff,$c000..$ffff:pv2000_getbyte:=memoria[direccion];
    $4000:pv2000_getbyte:=tms_0.vram_r;
    $4001:pv2000_getbyte:=tms_0.register_r;
  end;
end;

procedure pv2000_putbyte(direccion:word;valor:byte);
begin
  case direccion of
    0..$3fff,$c000..$ffff:;
    $4000:tms_0.vram_w(valor);
    $4001:tms_0.register_w(valor);
    $7000..$7fff:memoria[direccion]:=valor;
  end;
end;

function pv2000_in(puerto:word):byte;
begin
case (puerto and $ff) of
  $10:if pv2000_0.keyb_column<10 then pv2000_in:=pv2000_0.keys[pv2000_0.keyb_column] shr 4
        else pv2000_in:=0;
  $20:if pv2000_0.keyb_column<10 then pv2000_in:=$f0 or (pv2000_0.keys[pv2000_0.keyb_column] and $f)
        else pv2000_in:=$f0;
  $40:pv2000_in:=$f0 or (pv2000_0.keys[10] and $f);
  $60:pv2000_in:=0; //cassete
end;
end;

procedure pv2000_out(puerto:word;valor:byte);
begin
case (puerto and $ff) of
  0,$60:; //cassette
  $20:begin
          pv2000_0.keyb_column:=valor;
          z80_0.change_irq(CLEAR_LINE);
      end;
  $40:sn_76496_0.Write(valor);
end;
end;

procedure pv2000_sound_update;
begin
  sn_76496_0.update;
end;

procedure pv2000_interrupt(int:boolean);
var
  key_pressed:byte;
begin
  if (int and not(pv2000_0.last_nmi)) then z80_0.change_nmi(PULSE_LINE);
  pv2000_0.last_nmi:=int;
  if pv2000_0.keyb_column=$f then begin
    key_pressed:=pv2000_0.keys[0] or pv2000_0.keys[1] or pv2000_0.keys[2] or pv2000_0.keys[3] or pv2000_0.keys[4] or pv2000_0.keys[5] or pv2000_0.keys[6] or pv2000_0.keys[7] or pv2000_0.keys[8];
    if ((key_pressed<>0) and (key_pressed<>pv2000_0.last_key)) then z80_0.change_irq(ASSERT_LINE);
    pv2000_0.last_key:=key_pressed;
  end;
end;

//Main
procedure reset_pv2000;
begin
 z80_0.reset;
 sn_76496_0.reset;
 reset_audio;
 pv2000_0.last_nmi:=false;
 pv2000_0.keyb_column:=0;
 pv2000_0.last_key:=0;
 fillchar(pv2000_0.keys,11,0);
end;

procedure pv2000_grabar_snapshot;
var
  nombre:string;
begin
nombre:=snapshot_main_write;
Directory.pv2000:=ExtractFilePath(nombre);
end;

procedure abrir_pv2000;
var
  extension,nombre_file,romfile:string;
  longitud:integer;
  datos:pbyte;
begin
  if not(openrom(romfile)) then exit;
  getmem(datos,$10000);
  if not(extract_data(romfile,datos,longitud,nombre_file)) then begin
    freemem(datos);
    exit;
  end;
  extension:=extension_fichero(nombre_file);
  if (extension='DSP') then snapshot_r(datos,longitud)
    else begin
            copymemory(@memoria[$c000],datos,longitud);
            reset_pv2000;
         end;
  change_caption(nombre_file);
  freemem(datos);
  directory.pv2000:=ExtractFilePath(romfile);
end;

function iniciar_pv2000:boolean;
begin
principal1.BitBtn10.Glyph:=nil;
principal1.imagelist2.GetBitmap(4,principal1.BitBtn10.Glyph);
principal1.BitBtn10.OnClick:=principal1.fLoadCartucho;
llamadas_maquina.bucle_general:=pv2000_principal;
llamadas_maquina.reset:=reset_pv2000;
llamadas_maquina.cartuchos:=abrir_pv2000;
llamadas_maquina.grabar_snapshot:=pv2000_grabar_snapshot;
llamadas_maquina.fps_max:=59.922738;
iniciar_pv2000:=false;
iniciar_audio(false);
screen_init(1,284,243);
iniciar_video(284,243);
//Main CPU
z80_0:=cpu_z80.create(7159090 div 2,262);
z80_0.change_ram_calls(pv2000_getbyte,pv2000_putbyte);
z80_0.change_io_calls(pv2000_in,pv2000_out);
z80_0.init_sound(pv2000_sound_update);
//TMS
tms_0:=tms99xx_chip.create(1,pv2000_interrupt);
//Chip Sonido
sn_76496_0:=sn76496_chip.Create(7159090 div 2);
//cargar roms
if not(roms_load(@memoria[0],pv2000_bios)) then exit;
//final
reset_pv2000;
if main_vars.console_init then abrir_pv2000;
iniciar_pv2000:=true;
end;

end.
