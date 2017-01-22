unit coleco;
{
23/12/12 Snapshot v2 - New Z80 CPU Engine
04/03/13 Snapshot v2.1 - Añadido al snapshot el SN76496
18/08/15 Snapshot v2.2 - Modificado el TMS
21/08/15 Cambiados los controles y la NMI
         La memoria no hay que iniciarla a 0... sino hay juegos que fallan!
}
interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,lenguaje,main_engine,controls_engine,tms99xx,sn_76496,sysutils,dialogs,
     rom_engine,misc_functions,sound_engine,file_engine;

procedure cargar_coleco;
procedure reset_coleco;
procedure coleco_interrupt(int:boolean);

implementation
uses snapshot,principal;

const
  coleco_bios:tipo_roms=(n:'coleco.rom';l:$2000;p:0;crc:$3aa93ef3);

var
  joymode,last_nmi:boolean;
  joystick:array[0..1] of byte;
  keypad:array[0..1] of word;

procedure eventos_coleco;
begin
if event.arcade then begin
   //P1
   if arcade_input.up[0] then joystick[0]:=(joystick[0] and $fe) else joystick[0]:=(joystick[0] or 1);
   if arcade_input.right[0] then joystick[0]:=(joystick[0] and $fd) else joystick[0]:=(joystick[0] or 2);
   if arcade_input.down[0] then joystick[0]:=(joystick[0] and $fb) else joystick[0]:=(joystick[0] or 4);
   if arcade_input.left[0] then joystick[0]:=(joystick[0] and $f7) else joystick[0]:=(joystick[0] or 8);
   if arcade_input.but0[0] then joystick[0]:=(joystick[0] and $bf) else joystick[0]:=(joystick[0] or $40);
   if arcade_input.but1[0] then keypad[0]:=(keypad[0] and $bfff) else keypad[0]:=(keypad[0] or $4000);
   //P2
   if arcade_input.up[1] then joystick[1]:=(joystick[1] and $fe) else joystick[1]:=(joystick[1] or 1);
   if arcade_input.right[1] then joystick[1]:=(joystick[1] and $fd) else joystick[1]:=(joystick[1] or 2);
   if arcade_input.down[1] then joystick[1]:=(joystick[1] and $fb) else joystick[1]:=(joystick[1] or 4);
   if arcade_input.left[1] then joystick[1]:=(joystick[1] and $f7) else joystick[1]:=(joystick[1] or 8);
   if arcade_input.but0[1] then joystick[1]:=(joystick[1] and $bf) else joystick[1]:=(joystick[1] or $40);
   if arcade_input.but1[1] then keypad[1]:=(keypad[1] and $bfff) else keypad[1]:=(keypad[1] or $4000);
end;
if event.keyboard then begin
   //P1
   if keyboard[KEYBOARD_0] then keypad[0]:=(keypad[0] and $fffe) else keypad[0]:=(keypad[0] or $0001);
   if keyboard[KEYBOARD_1] then keypad[0]:=(keypad[0] and $fffd) else keypad[0]:=(keypad[0] or $0002);
   if keyboard[KEYBOARD_2] then keypad[0]:=(keypad[0] and $fffb) else keypad[0]:=(keypad[0] or $0004);
   if keyboard[KEYBOARD_3] then keypad[0]:=(keypad[0] and $fff7) else keypad[0]:=(keypad[0] or $0008);
   if keyboard[KEYBOARD_4] then keypad[0]:=(keypad[0] and $ffef) else keypad[0]:=(keypad[0] or $0010);
   if keyboard[KEYBOARD_5] then keypad[0]:=(keypad[0] and $ffdf) else keypad[0]:=(keypad[0] or $0020);
   if keyboard[KEYBOARD_6] then keypad[0]:=(keypad[0] and $ffbf) else keypad[0]:=(keypad[0] or $0040);
   if keyboard[KEYBOARD_7] then keypad[0]:=(keypad[0] and $ff7f) else keypad[0]:=(keypad[0] or $0080);
   if keyboard[KEYBOARD_8] then keypad[0]:=(keypad[0] and $feff) else keypad[0]:=(keypad[0] or $0100);
   if keyboard[KEYBOARD_9] then keypad[0]:=(keypad[0] and $fdff) else keypad[0]:=(keypad[0] or $0200);
   if keyboard[KEYBOARD_A] then keypad[0]:=(keypad[0] and $fbff) else keypad[0]:=(keypad[0] or $0400);
   if keyboard[KEYBOARD_S] then keypad[0]:=(keypad[0] and $f7ff) else keypad[0]:=(keypad[0] or $0800);
   //P2
   if keyboard[KEYBOARD_P] then keypad[1]:=(keypad[1] and $fffe) else keypad[1]:=(keypad[1] or $0001);
   if keyboard[KEYBOARD_Q] then keypad[1]:=(keypad[1] and $fffd) else keypad[1]:=(keypad[1] or $0002);
   if keyboard[KEYBOARD_W] then keypad[1]:=(keypad[1] and $fffb) else keypad[1]:=(keypad[1] or $0004);
   if keyboard[KEYBOARD_E] then keypad[1]:=(keypad[1] and $fff7) else keypad[1]:=(keypad[1] or $0008);
   if keyboard[KEYBOARD_R] then keypad[1]:=(keypad[1] and $ffef) else keypad[1]:=(keypad[1] or $0010);
   if keyboard[KEYBOARD_T] then keypad[1]:=(keypad[1] and $ffdf) else keypad[1]:=(keypad[1] or $0020);
   if keyboard[KEYBOARD_Y] then keypad[1]:=(keypad[1] and $ffbf) else keypad[1]:=(keypad[1] or $0040);
   if keyboard[KEYBOARD_U] then keypad[1]:=(keypad[1] and $ff7f) else keypad[1]:=(keypad[1] or $0080);
   if keyboard[KEYBOARD_I] then keypad[1]:=(keypad[1] and $feff) else keypad[1]:=(keypad[1] or $0100);
   if keyboard[KEYBOARD_O] then keypad[1]:=(keypad[1] and $fdff) else keypad[1]:=(keypad[1] or $0200);
   if keyboard[KEYBOARD_Z] then keypad[1]:=(keypad[1] and $fbff) else keypad[1]:=(keypad[1] or $0400);
   if keyboard[KEYBOARD_X] then keypad[1]:=(keypad[1] and $f7ff) else keypad[1]:=(keypad[1] or $0800);
end;
end;

procedure coleco_principal;
var
  frame:single;
  f:word;
begin
init_controls(false,true,true,false);
frame:=z80_0.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to 261 do begin
      z80_0.run(frame);
      frame:=frame+z80_0.tframes-z80_0.contador;
      tms_0.refresh(f);
  end;
  actualiza_trozo_simple(0,0,284,243,1);
  eventos_coleco;
  video_sync;
end;
end;

function coleco_getbyte(direccion:word):byte;
begin
case direccion of
  0..$1fff,$8000..$ffff:coleco_getbyte:=memoria[direccion];
  $6000..$7fff:coleco_getbyte:=memoria[$6000+(direccion and $3ff)];
end;
end;

procedure coleco_putbyte(direccion:word;valor:byte);
begin
//Solo tiene $400 bytes de memoria RAM, hace mirror desde $6000 hasta la $7fff
case direccion of
  // $2000..$3fff:memoria[direccion]:=valor;
  $6000..$7fff:memoria[$6000+(direccion and $3ff)]:=valor;
end;
end;

function coleco_inbyte(puerto:word):byte;
var
  player,data:byte;
  input:word;
begin
  case (puerto and $e0) of
    $a0:if (puerto and $01)<>0 then coleco_inbyte:=tms_0.register_r
             else coleco_inbyte:=tms_0.vram_r;
    $e0:begin
             player:=(puerto shr 1) and $01;
             if joymode then begin //leer joystick
                coleco_inbyte:=joystick[player] and $7f;
             end else begin //leer keypad
                data:=$f;
                input:=keypad[player];
                if (input and 1)=0 then data:=data and $a; //0
                if (input and 2)=0 then data:=data and $d; //1
                if (input and 4)=0 then data:=data and $7; //2
                if (input and 8)=0 then data:=data and $c; //2
                if (input and $10)=0 then data:=data and $2; //4
                if (input and $20)=0 then data:=data and $3; //5
                if (input and $40)=0 then data:=data and $e; //6
                if (input and $80)=0 then data:=data and $5; //7
                if (input and $100)=0 then data:=data and $1; //8
                if (input and $200)=0 then data:=data and $b; //9
                if (input and $400)=0 then data:=data and $6; //#
                if (input and $800)=0 then data:=data and $9; //*
                //Segundo boton
                coleco_inbyte:=((input and $4000) shr 8) or $30 or data;
             end;
        end;
  end;
end;

procedure coleco_outbyte(puerto:word;valor:byte);
begin
  case (puerto and $e0) of
    $80,$c0:joymode:=(puerto and $40)<>0;
    $a0:if (puerto and $01)<>0 then tms_0.register_w(valor)
                else tms_0.vram_w(valor);
    $e0:sn_76496_0.Write(valor);
  end;
end;

procedure coleco_interrupt(int:boolean);
begin
  if (int and not(last_nmi)) then z80_0.change_nmi(PULSE_LINE);
  last_nmi:=int;
end;

procedure coleco_sound_update;
begin
  sn_76496_0.update;
end;

//Main
procedure reset_coleco;
var
  f:word;
begin
 z80_0.reset;
 sn_76496_0.reset;
 tms_0.reset;
 reset_audio;
 //Importante o el juego 'The Yolk's on You' se para
 for f:=0 to $3ff do memoria[$6000+f]:=random(256);
 joymode:=false;
 last_nmi:=false;
 joystick[0]:=$ff;
 joystick[1]:=$ff;
 keypad[0]:=$ffff;
 keypad[1]:=$ffff;
end;

function abrir_cartucho(datos:pbyte;longitud:integer):boolean;
var
  ptemp:pbyte;
begin
abrir_cartucho:=false;
ptemp:=datos;
inc(ptemp,1);
if not(((datos^=$55) and (ptemp^=$aa)) or ((datos^=$aa) and (ptemp^=$55)) or ((datos^=$66) and (ptemp^=$99))) then exit;
reset_coleco;
copymemory(@memoria[$8000],datos,longitud);
abrir_cartucho:=true;
end;

function abrir_coleco:boolean;
var
  extension,nombre_file,RomFile:string;
  datos:pbyte;
  longitud,crc:integer;
  resultado:boolean;
begin
  if not(OpenRom(StColecovision,Romfile)) then begin
    abrir_coleco:=true;
    exit;
  end;
  abrir_coleco:=false;
  extension:=extension_fichero(RomFile);
  if extension='ZIP' then begin
    if not(search_file_from_zip(RomFile,'*.col',nombre_file,longitud,crc,false)) then
      if not(search_file_from_zip(RomFile,'*.rom',nombre_file,longitud,crc,false)) then
        if not(search_file_from_zip(RomFile,'*.bin',nombre_file,longitud,crc,false)) then
          if not(search_file_from_zip(RomFile,'*.csn',nombre_file,longitud,crc,true)) then
            if not(search_file_from_zip(RomFile,'*.dsp',nombre_file,longitud,crc,true)) then exit;
    getmem(datos,longitud);
    if not(load_file_from_zip(RomFile,nombre_file,datos,longitud,crc,true)) then begin
      freemem(datos);
      exit;
    end;
  end else begin
    if ((extension<>'COL') and (extension<>'ROM') and (extension<>'BIN') and (extension<>'CSN') and (extension<>'DSP')) then exit;
    if not(read_file_size(RomFile,longitud)) then exit;
    getmem(datos,longitud);
    if not(read_file(RomFile,datos,longitud)) then begin
      freemem(datos);
      exit;
    end;
    nombre_file:=extractfilename(RomFile);
  end;
abrir_coleco:=true;
extension:=extension_fichero(nombre_file);
if ((extension='CSN') or (extension='DSP')) then resultado:=abrir_coleco_snapshot(datos,longitud)
   else resultado:=abrir_cartucho(datos,longitud);
freemem(datos);
if resultado then begin
  llamadas_maquina.open_file:=nombre_file;
end else begin
  MessageDlg('Error cargando snapshot/ROM.'+chr(10)+chr(13)+'Error loading the snapshot/ROM.', mtInformation,[mbOk], 0);
  llamadas_maquina.open_file:='';
end;
change_caption;
directory.coleco_snap:=ExtractFilePath(romfile);
end;

procedure coleco_grabar_snapshot;
var
  nombre:string;
  correcto:boolean;
begin
principal1.savedialog1.InitialDir:=Directory.coleco_snap;
principal1.saveDialog1.Filter := 'DSP Format (*.dsp)|*.dsp|CSN Format (*.csn)|*.csn';
if principal1.savedialog1.execute then begin
        nombre:=principal1.savedialog1.FileName;
        case principal1.SaveDialog1.FilterIndex of
          1:nombre:=changefileext(nombre,'.dsp');
          2:nombre:=changefileext(nombre,'.csn');
        end;
        if FileExists(nombre) then begin                                         //Respuesta 'NO' es 7
            if MessageDlg(leng[main_vars.idioma].mensajes[3], mtWarning, [mbYes]+[mbNo],0)=7 then exit;
        end;
        case principal1.SaveDialog1.FilterIndex of
          1,2:correcto:=grabar_coleco_snapshot(nombre);
        end;
        if not(correcto) then MessageDlg('No se ha podido guardar el snapshot!',mtError,[mbOk],0);
end else exit;
Directory.coleco_snap:=extractfiledir(principal1.savedialog1.FileName);
end;

function iniciar_coleco:boolean;
begin
iniciar_coleco:=false;
iniciar_audio(false);
screen_init(1,284,243);
iniciar_video(284,243);
//Main CPU
z80_0:=cpu_z80.create(3579545,262);
z80_0.change_ram_calls(coleco_getbyte,coleco_putbyte);
z80_0.change_io_calls(coleco_inbyte,coleco_outbyte);
z80_0.init_sound(coleco_sound_update);
//TMS
tms_0:=tms99xx_chip.create(1,coleco_interrupt);
//Chip Sonido
sn_76496_0:=sn76496_chip.Create(3579545);
//cargar roms
if not(cargar_roms(@memoria[0],@coleco_bios,'coleco.zip',1)) then exit;
//final
reset_coleco;
iniciar_coleco:=true;
end;

procedure Cargar_coleco;
begin
principal1.BitBtn10.Glyph:=nil;
principal1.imagelist2.GetBitmap(4,principal1.BitBtn10.Glyph);
principal1.BitBtn10.OnClick:=principal1.fLoadCartucho;
llamadas_maquina.iniciar:=iniciar_coleco;
llamadas_maquina.bucle_general:=coleco_principal;
llamadas_maquina.reset:=reset_coleco;
llamadas_maquina.cartuchos:=abrir_coleco;
llamadas_maquina.grabar_snapshot:=coleco_grabar_snapshot;
llamadas_maquina.fps_max:=10738635/2/342/262;
end;

end.
