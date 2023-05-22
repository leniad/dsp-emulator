unit coleco;
{
23/12/12 Snapshot v2 - New Z80 CPU Engine
04/03/13 Snapshot v2.1 - Añadido al snapshot el SN76496
18/08/15 Snapshot v2.2 - Modificado el TMS
21/08/15 Cambiados los controles y la NMI
         La memoria no hay que iniciarla a 0... sino hay juegos que fallan!
12/11/20 Añado Super Game Card y Mega Cart
14/07/22 Modificado el snapshot a la version 3.01, por las modificaciones del SN76496
}

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,lenguaje,main_engine,controls_engine,tms99xx,sn_76496,sysutils,dialogs,
     rom_engine,misc_functions,sound_engine,file_engine,ay_8910,i2cmem;

type
  tcoleco_machine=record
    joymode,rom_enabled,sgm_ram,last_nmi,mega_cart:boolean;
    joystick:array[0..1] of byte;
    keypad:array[0..1] of word;
    mega_cart_rom:array[0..$1f,0..$3fff] of byte;
    mega_cart_size:byte;
    boxxle:boolean;
    eprom_type:byte;
  end;

procedure cargar_coleco;
procedure reset_coleco;
procedure coleco_interrupt(int:boolean);

var
  tcoleco:tcoleco_machine;

implementation
uses snapshot,principal;

const
  coleco_bios:tipo_roms=(n:'coleco.rom';l:$2000;p:0;crc:$3aa93ef3);

var
  rom:array[0..$1fff] of byte;

procedure eventos_coleco;
begin
if event.keyboard then begin
   //P1
   if keyboard[KEYBOARD_0] then tcoleco.keypad[0]:=(tcoleco.keypad[0] and $fffe) else tcoleco.keypad[0]:=(tcoleco.keypad[0] or $0001);
   if keyboard[KEYBOARD_1] then tcoleco.keypad[0]:=(tcoleco.keypad[0] and $fffd) else tcoleco.keypad[0]:=(tcoleco.keypad[0] or $0002);
   if keyboard[KEYBOARD_2] then tcoleco.keypad[0]:=(tcoleco.keypad[0] and $fffb) else tcoleco.keypad[0]:=(tcoleco.keypad[0] or $0004);
   if keyboard[KEYBOARD_3] then tcoleco.keypad[0]:=(tcoleco.keypad[0] and $fff7) else tcoleco.keypad[0]:=(tcoleco.keypad[0] or $0008);
   if keyboard[KEYBOARD_4] then tcoleco.keypad[0]:=(tcoleco.keypad[0] and $ffef) else tcoleco.keypad[0]:=(tcoleco.keypad[0] or $0010);
   if keyboard[KEYBOARD_5] then tcoleco.keypad[0]:=(tcoleco.keypad[0] and $ffdf) else tcoleco.keypad[0]:=(tcoleco.keypad[0] or $0020);
   if keyboard[KEYBOARD_6] then tcoleco.keypad[0]:=(tcoleco.keypad[0] and $ffbf) else tcoleco.keypad[0]:=(tcoleco.keypad[0] or $0040);
   if keyboard[KEYBOARD_7] then tcoleco.keypad[0]:=(tcoleco.keypad[0] and $ff7f) else tcoleco.keypad[0]:=(tcoleco.keypad[0] or $0080);
   if keyboard[KEYBOARD_8] then tcoleco.keypad[0]:=(tcoleco.keypad[0] and $feff) else tcoleco.keypad[0]:=(tcoleco.keypad[0] or $0100);
   if keyboard[KEYBOARD_9] then tcoleco.keypad[0]:=(tcoleco.keypad[0] and $fdff) else tcoleco.keypad[0]:=(tcoleco.keypad[0] or $0200);
   if keyboard[KEYBOARD_A] then tcoleco.keypad[0]:=(tcoleco.keypad[0] and $fbff) else tcoleco.keypad[0]:=(tcoleco.keypad[0] or $0400);
   if keyboard[KEYBOARD_S] then tcoleco.keypad[0]:=(tcoleco.keypad[0] and $f7ff) else tcoleco.keypad[0]:=(tcoleco.keypad[0] or $0800);
   //P2
   if keyboard[KEYBOARD_P] then tcoleco.keypad[1]:=(tcoleco.keypad[1] and $fffe) else tcoleco.keypad[1]:=(tcoleco.keypad[1] or $0001);
   if keyboard[KEYBOARD_Q] then tcoleco.keypad[1]:=(tcoleco.keypad[1] and $fffd) else tcoleco.keypad[1]:=(tcoleco.keypad[1] or $0002);
   if keyboard[KEYBOARD_W] then tcoleco.keypad[1]:=(tcoleco.keypad[1] and $fffb) else tcoleco.keypad[1]:=(tcoleco.keypad[1] or $0004);
   if keyboard[KEYBOARD_E] then tcoleco.keypad[1]:=(tcoleco.keypad[1] and $fff7) else tcoleco.keypad[1]:=(tcoleco.keypad[1] or $0008);
   if keyboard[KEYBOARD_R] then tcoleco.keypad[1]:=(tcoleco.keypad[1] and $ffef) else tcoleco.keypad[1]:=(tcoleco.keypad[1] or $0010);
   if keyboard[KEYBOARD_T] then tcoleco.keypad[1]:=(tcoleco.keypad[1] and $ffdf) else tcoleco.keypad[1]:=(tcoleco.keypad[1] or $0020);
   if keyboard[KEYBOARD_Y] then tcoleco.keypad[1]:=(tcoleco.keypad[1] and $ffbf) else tcoleco.keypad[1]:=(tcoleco.keypad[1] or $0040);
   if keyboard[KEYBOARD_U] then tcoleco.keypad[1]:=(tcoleco.keypad[1] and $ff7f) else tcoleco.keypad[1]:=(tcoleco.keypad[1] or $0080);
   if keyboard[KEYBOARD_I] then tcoleco.keypad[1]:=(tcoleco.keypad[1] and $feff) else tcoleco.keypad[1]:=(tcoleco.keypad[1] or $0100);
   if keyboard[KEYBOARD_O] then tcoleco.keypad[1]:=(tcoleco.keypad[1] and $fdff) else tcoleco.keypad[1]:=(tcoleco.keypad[1] or $0200);
   if keyboard[KEYBOARD_Z] then tcoleco.keypad[1]:=(tcoleco.keypad[1] and $fbff) else tcoleco.keypad[1]:=(tcoleco.keypad[1] or $0400);
   if keyboard[KEYBOARD_X] then tcoleco.keypad[1]:=(tcoleco.keypad[1] and $f7ff) else tcoleco.keypad[1]:=(tcoleco.keypad[1] or $0800);
end;
if event.arcade then begin
   //P1
   if arcade_input.up[0] then tcoleco.joystick[0]:=(tcoleco.joystick[0] and $fe) else tcoleco.joystick[0]:=(tcoleco.joystick[0] or 1);
   if arcade_input.right[0] then tcoleco.joystick[0]:=(tcoleco.joystick[0] and $fd) else tcoleco.joystick[0]:=(tcoleco.joystick[0] or 2);
   if arcade_input.down[0] then tcoleco.joystick[0]:=(tcoleco.joystick[0] and $fb) else tcoleco.joystick[0]:=(tcoleco.joystick[0] or 4);
   if arcade_input.left[0] then tcoleco.joystick[0]:=(tcoleco.joystick[0] and $f7) else tcoleco.joystick[0]:=(tcoleco.joystick[0] or 8);
   if arcade_input.but1[0] then tcoleco.joystick[0]:=(tcoleco.joystick[0] and $bf) else tcoleco.joystick[0]:=(tcoleco.joystick[0] or $40);
   if arcade_input.but0[0] then tcoleco.keypad[0]:=(tcoleco.keypad[0] and $bfff) else tcoleco.keypad[0]:=(tcoleco.keypad[0] or $4000);
   //P2
   if arcade_input.up[1] then tcoleco.joystick[1]:=(tcoleco.joystick[1] and $fe) else tcoleco.joystick[1]:=(tcoleco.joystick[1] or 1);
   if arcade_input.right[1] then tcoleco.joystick[1]:=(tcoleco.joystick[1] and $fd) else tcoleco.joystick[1]:=(tcoleco.joystick[1] or 2);
   if arcade_input.down[1] then tcoleco.joystick[1]:=(tcoleco.joystick[1] and $fb) else tcoleco.joystick[1]:=(tcoleco.joystick[1] or 4);
   if arcade_input.left[1] then tcoleco.joystick[1]:=(tcoleco.joystick[1] and $f7) else tcoleco.joystick[1]:=(tcoleco.joystick[1] or 8);
   if arcade_input.but1[1] then tcoleco.joystick[1]:=(tcoleco.joystick[1] and $bf) else tcoleco.joystick[1]:=(tcoleco.joystick[1] or $40);
   if arcade_input.but0[1] then tcoleco.keypad[1]:=(tcoleco.keypad[1] and $bfff) else tcoleco.keypad[1]:=(tcoleco.keypad[1] or $4000);
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
var
   tbyte:byte;
begin
case direccion of
  0..$1fff:if tcoleco.rom_enabled then coleco_getbyte:=rom[direccion]
              else coleco_getbyte:=memoria[direccion];
  $2000..$5fff:if tcoleco.sgm_ram then coleco_getbyte:=memoria[direccion];
  $6000..$7fff:if tcoleco.sgm_ram then coleco_getbyte:=memoria[direccion]
                  else coleco_getbyte:=memoria[$6000+(direccion and $3ff)];
  $8000..$ff7f,$ff81..$ffbf:coleco_getbyte:=memoria[direccion];
  $ff80:if tcoleco.boxxle then coleco_getbyte:=i2cmem_0.read_sda
          else coleco_getbyte:=memoria[direccion];
  $ffc0..$ffff:if tcoleco.mega_cart then begin
                     tbyte:=tcoleco.mega_cart_size-(($ffff-direccion) and tcoleco.mega_cart_size);
                     copymemory(@memoria[$c000],@tcoleco.mega_cart_rom[tbyte,0],$4000);
                  end else coleco_getbyte:=memoria[direccion];
end;
end;

procedure coleco_putbyte(direccion:word;valor:byte);
var
   tbyte:byte;
begin
//La CV original solo tiene $400 bytes de memoria RAM, hace mirror desde $6000 hasta la $7fff
//Con el cartucho Super Game Master, añade mas RAM
case direccion of
  0..$1fff:if not(tcoleco.rom_enabled) then memoria[direccion]:=valor;
  $2000..$5fff:if tcoleco.sgm_ram then memoria[direccion]:=valor;
  $6000..$7fff:if tcoleco.sgm_ram then memoria[direccion]:=valor
                  else memoria[$6000+(direccion and $3ff)]:=valor;
  $ff90,$ffa0,$ffb0:if tcoleco.boxxle then begin
                         tbyte:=((direccion shr 4) and 3) and tcoleco.mega_cart_size;
                         copymemory(@memoria[$c000],@tcoleco.mega_cart_rom[tbyte,0],$4000);
                    end;
  $ffc0:if tcoleco.boxxle then i2cmem_0.write_scl(0);
  $ffd0:if tcoleco.boxxle then i2cmem_0.write_scl(1);
  $ffe0:if tcoleco.boxxle then i2cmem_0.write_sda(0);
  $fff0:if tcoleco.boxxle then i2cmem_0.write_sda(1);
end;
end;

function coleco_inbyte(puerto:word):byte;
var
  player,data:byte;
  input:word;
begin
  puerto:=puerto and $ff;
  case (puerto and $e0) of
    $40:if puerto=$52 then coleco_inbyte:=ay8910_0.Read;
    $a0:if (puerto and $01)<>0 then coleco_inbyte:=tms_0.register_r
             else coleco_inbyte:=tms_0.vram_r;
    $e0:begin
             player:=(puerto shr 1) and $01;
             if tcoleco.joymode then begin //leer joystick
                coleco_inbyte:=tcoleco.joystick[player] and $7f;
             end else begin //leer keypad
                data:=$f;
                input:=tcoleco.keypad[player];
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
  puerto:=puerto and $ff;
  case (puerto and $e0) of
    $40:case puerto of //Super Game Module
           $50:ay8910_0.Control(valor);
           $51:ay8910_0.Write(valor);
           $53:tcoleco.sgm_ram:=(valor and 1)<>0;
        end;
    $60:tcoleco.rom_enabled:=(valor and 2)<>0; //Super Game Module
    $80,$c0:tcoleco.joymode:=(puerto and $40)<>0;
    $a0:if (puerto and $01)<>0 then tms_0.register_w(valor)
                else tms_0.vram_w(valor);
    $e0:sn_76496_0.Write(valor);
  end;
end;

procedure coleco_interrupt(int:boolean);
begin
  if (int and not(tcoleco.last_nmi)) then z80_0.change_nmi(PULSE_LINE);
  tcoleco.last_nmi:=int;
end;

procedure coleco_sound_update;
begin
  sn_76496_0.update;
  ay8910_0.update;
end;

//Main
procedure reset_coleco;
var
  f:word;
begin
 z80_0.reset;
 sn_76496_0.reset;
 ay8910_0.reset;
 tms_0.reset;
 if tcoleco.boxxle then i2cmem_0.reset;
 reset_audio;
 //Importante o el juego 'The Yolk's on You' se para
 for f:=0 to $3ff do memoria[$6000+f]:=random(256);
 tcoleco.joymode:=false;
 tcoleco.rom_enabled:=true;
 tcoleco.sgm_ram:=false;
 tcoleco.last_nmi:=false;
 tcoleco.joystick[0]:=$ff;
 tcoleco.joystick[1]:=$ff;
 tcoleco.keypad[0]:=$ffff;
 tcoleco.keypad[1]:=$ffff;
end;

function abrir_cartucho(datos:pbyte;longitud:integer):boolean;
var
   f:byte;
   ptemp:pbyte;
   rom_crc32:dword;
   memoria_temp:array[0..$7fff] of byte;
   long:integer;
begin
abrir_cartucho:=false;
tcoleco.boxxle:=false;
tcoleco.mega_cart:=false;
if longitud>32768 then begin
   ptemp:=datos;
   rom_crc32:=calc_crc(datos,longitud);
   tcoleco.mega_cart_size:=(longitud shr 14)-1;
   if ((rom_crc32=$62dacf07) or (rom_crc32=$dddd1396)) then begin //Boxxle o Black Onix
      tcoleco.boxxle:=true;
      if rom_crc32<>$62dacf07 then begin
        tcoleco.eprom_type:=1;
        i2cmem_0:=i2cmem_chip.create(I2C_24C08);
        if read_file_size(Directory.Arcade_nvram+'black_onix.nv',long) then begin
          read_file(Directory.Arcade_nvram+'black_onix.nv',@memoria_temp,long);
          i2cmem_0.load_data(@memoria_temp);
        end;
      end else begin
        tcoleco.eprom_type:=2;
        i2cmem_0:=i2cmem_chip.create(I2C_24C256);
        if read_file_size(Directory.Arcade_nvram+'boxxle.nv',long) then begin
          read_file(Directory.Arcade_nvram+'boxxle.nv',@memoria_temp,long);
          i2cmem_0.load_data(@memoria_temp);
        end;
      end;
      for f:=0 to tcoleco.mega_cart_size do begin
          copymemory(@tcoleco.mega_cart_rom[f,0],ptemp,$4000);
          inc(ptemp,$4000);
      end;
      copymemory(@memoria[$8000],@tcoleco.mega_cart_rom[0,0],$4000);
      abrir_cartucho:=true;
   end else begin //Mega Cart
      tcoleco.mega_cart:=true;
      for f:=0 to tcoleco.mega_cart_size do begin
          copymemory(@tcoleco.mega_cart_rom[f,0],ptemp,$4000);
          inc(ptemp,$4000);
      end;
      if not(((tcoleco.mega_cart_rom[tcoleco.mega_cart_size,0]=$55) and (tcoleco.mega_cart_rom[tcoleco.mega_cart_size,1]=$aa)) or ((tcoleco.mega_cart_rom[tcoleco.mega_cart_size,0]=$aa) and (tcoleco.mega_cart_rom[tcoleco.mega_cart_size,1]=$55)) or ((tcoleco.mega_cart_rom[tcoleco.mega_cart_size,0]=$66) and (tcoleco.mega_cart_rom[tcoleco.mega_cart_size,1]=$99))) then exit;
      copymemory(@memoria[$8000],@tcoleco.mega_cart_rom[tcoleco.mega_cart_size,0],$4000);
      abrir_cartucho:=true;
   end;
end else begin
    if not(((datos[0]=$55) and (datos[1]=$aa)) or ((datos[0]=$aa) and (datos[1]=$55)) or ((datos[0]=$66) and (datos[1]=$99))) then exit;
    copymemory(@memoria[$8000],datos,longitud);
    abrir_cartucho:=true;
end;
end;

procedure abrir_coleco;
var
  extension,nombre_file,RomFile:string;
  datos:pbyte;
  longitud:integer;
  resultado:boolean;
  crc:dword;
begin
  if not(OpenRom(StColecovision,Romfile)) then exit;
  extension:=extension_fichero(RomFile);
  resultado:=false;
  if extension='ZIP' then begin
    if not(search_file_from_zip(RomFile,'*.col',nombre_file,longitud,crc,false)) then
      if not(search_file_from_zip(RomFile,'*.rom',nombre_file,longitud,crc,false)) then
        if not(search_file_from_zip(RomFile,'*.bin',nombre_file,longitud,crc,false)) then
          if not(search_file_from_zip(RomFile,'*.csn',nombre_file,longitud,crc,true)) then
            if not(search_file_from_zip(RomFile,'*.dsp',nombre_file,longitud,crc,true)) then begin
              MessageDlg('Error cargando snapshot/ROM.'+chr(10)+chr(13)+'Error loading the snapshot/ROM.', mtInformation,[mbOk], 0);
              exit;
            end;
    getmem(datos,longitud);
    if not(load_file_from_zip(RomFile,nombre_file,datos,longitud,crc,true)) then freemem(datos)
      else resultado:=true;
  end else begin
    if ((extension<>'COL') and (extension<>'ROM') and (extension<>'BIN') and (extension<>'CSN') and (extension<>'DSP')) then begin
      MessageDlg('Error cargando snapshot/ROM.'+chr(10)+chr(13)+'Error loading the snapshot/ROM.', mtInformation,[mbOk], 0);
      exit;
    end;
    if read_file_size(RomFile,longitud) then begin
      getmem(datos,longitud);
      if not(read_file(RomFile,datos,longitud)) then freemem(datos)
        else resultado:=true;
      nombre_file:=extractfilename(RomFile);
    end;
  end;
  if not(resultado) then begin
    MessageDlg('Error cargando snapshot/ROM.'+chr(10)+chr(13)+'Error loading the snapshot/ROM.', mtInformation,[mbOk], 0);
    exit;
  end;
  extension:=extension_fichero(nombre_file);
  if ((extension='CSN') or (extension='DSP')) then resultado:=abrir_coleco_snapshot(datos,longitud)
    else resultado:=abrir_cartucho(datos,longitud);
  freemem(datos);
  if not(resultado) then begin
    MessageDlg('Error cargando snapshot/ROM.'+chr(10)+chr(13)+'Error loading the snapshot/ROM.', mtInformation,[mbOk], 0);
    nombre_file:='';
  end;
  reset_coleco;
  change_caption(nombre_file);
  directory.coleco_snap:=ExtractFilePath(romfile);
end;

procedure coleco_grabar_snapshot;
var
  nombre:string;
  correcto:boolean;
  indice:byte;
begin
if SaveRom(StColecovision,nombre,indice) then begin
        case indice of
          1:nombre:=changefileext(nombre,'.dsp');
          2:nombre:=changefileext(nombre,'.csn');
        end;
        if FileExists(nombre) then begin                                         //Respuesta 'NO' es 7
            if MessageDlg(leng[main_vars.idioma].mensajes[3], mtWarning, [mbYes]+[mbNo],0)=7 then exit;
        end;
        case indice of
          1,2:correcto:=grabar_coleco_snapshot(nombre);
        end;
        if not(correcto) then MessageDlg('No se ha podido guardar el snapshot!',mtError,[mbOk],0);
end else exit;
Directory.coleco_snap:=ExtractFilePath(nombre);
end;

procedure cerrar_coleco;
begin
case tcoleco.eprom_type of
  1:i2cmem_0.write_data(Directory.Arcade_nvram+'black_onix.nv');
  2:i2cmem_0.write_data(Directory.Arcade_nvram+'boxxle.nv');
end;
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
ay8910_0:=ay8910_chip.create(3579545 div 2,AY8910,1);
//Chip Sonido
sn_76496_0:=sn76496_chip.Create(3579545);
//cargar roms
if not(roms_load(@rom,coleco_bios)) then exit;
//final
reset_coleco;
if main_vars.console_init then abrir_coleco;
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
llamadas_maquina.close:=cerrar_coleco;
llamadas_maquina.cartuchos:=abrir_coleco;
llamadas_maquina.grabar_snapshot:=coleco_grabar_snapshot;
llamadas_maquina.fps_max:=10738635/2/342/262;
end;

end.
