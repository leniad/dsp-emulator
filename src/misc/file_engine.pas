unit file_engine;

interface
uses unzip2,
     {$ifdef fpc}
     ziputils2,ZLibEx,
     {$IFDEF windows}windows,{$endif}
     {$else}
     {$IFDEF windows}windows,Zlib,{$ENDIF}
     {$endif}
     sysutils,dialogs,lenguaje,misc_functions,sound_engine,inifiles,main_engine,
     controls_engine;

type
    tzip_find_files=record
      posicion_dentro_zip:integer;
      nombre_zip,file_mask:string;
    end;
type tfile_data=record
      sms_bios_enabled,sms_is_pal:boolean;
    end;

//Hi Score
procedure save_hi(nombre:string;posicion:pbyte;longitud:dword);
function load_hi(nombre:string;posicion:pbyte;longitud:word):boolean;
//Iniciar fichero INI
procedure file_ini_load;
procedure file_ini_save;
//Ficheros normales
function read_file_size(nombre_file:string;var longitud:integer):boolean;
function read_file(nombre_file:string;donde:pbyte;var longitud:integer):boolean;
function write_file(nombre_file:string;donde:pbyte;longitud:integer):boolean;
function file_name_only(cadena:string):string;
//Parte ZIP
function search_file_from_zip(nombre_zip,file_mask:string;var nombre_file:string;var longitud,crc:integer;warning:boolean):boolean;
function find_first_file_zip(nombre_zip,file_mask:string;var nombre_file:string;var longitud,crc:integer;warning:boolean):boolean;
function find_next_file_zip(var nombre_file:string;var longitud,crc:integer):boolean;
function load_file_from_zip(nombre_zip,nombre_file:string;donde:pbyte;var longitud,crc:integer;warning:boolean):boolean;
function load_file_from_zip_crc(nombre_zip:string;donde:pbyte;var longitud:integer;crc:integer):boolean;
//Parte ZLIB
procedure compress_zlib(in_buffer:pointer;in_size:integer;out_buffer:pointer;var out_size:integer);
procedure decompress_zlib(in_buffer:pointer;in_size:integer;var out_buffer:pointer;var out_size:integer);

var
  zip_find_files_data:tzip_find_files;
  file_data:tfile_data;

implementation
uses spectrum_misc,principal,amstrad_cpc;

//Hi-score
procedure save_hi(nombre:string;posicion:pbyte;longitud:dword);
var
  fichero:file of byte;
begin
{$I-}
assignfile(fichero,Directory.Arcade_hi+nombre);
rewrite(fichero);
blockwrite(fichero,posicion^,longitud);
closefile(fichero);
{$I+}
end;

function load_hi(nombre:string;posicion:pbyte;longitud:word):boolean;
var
  fichero:file of byte;
  l:integer;
begin
load_hi:=false;
if not(fileexists(Directory.Arcade_hi+nombre)) then exit;
{$I-}
assignfile(fichero,Directory.Arcade_hi+nombre);
reset(fichero);
blockread(fichero,posicion^,longitud,l);
closefile(fichero);
{$I+}
if l<>longitud then exit;
load_hi:=true;
end;

//INI Files
procedure file_ini_load;
var
  fich_ini:Tinifile;
  f:byte;
begin
if fileexists(directory.Base+'dsp.ini') then begin
  fich_ini:=Tinifile.Create(directory.Base+'dsp.ini');
  //Diretorios de roms
  Directory.Arcade_roms:=fich_ini.readString('Dir','arcade',directory.Base+'roms'+main_vars.cadena_dir);
  Directory.lenguaje:=fich_ini.readString('Dir','lng',directory.Base+'lng'+main_vars.cadena_dir);
  Directory.Arcade_hi:=fich_ini.readString('dir','dir_hi',directory.Base+'hi'+main_vars.cadena_dir);
  Directory.Arcade_nvram:=fich_ini.readString('dir','dir_nvram',directory.Base+'nvram'+main_vars.cadena_dir);
  Directory.qsnapshot:=fich_ini.readString('dir','qsnapshot',directory.Base+'qsnap'+main_vars.cadena_dir);
  Directory.Arcade_samples:=fich_ini.readString('dir','dir_samples',directory.Base+'samples'+main_vars.cadena_dir);
  Directory.Nes:=fich_ini.readString('Dir','nes',directory.Base+'nes'+main_vars.cadena_dir);
  Directory.GameBoy:=fich_ini.readString('Dir','GameBoy',directory.Base+'gameboy'+main_vars.cadena_dir);
  Directory.Chip8:=fich_ini.readString('Dir','Chip8',directory.Base+'chip8'+main_vars.cadena_dir);
  Directory.sms:=fich_ini.readString('Dir','SMS',directory.Base+'sms'+main_vars.cadena_dir);
  Directory.ColecoVision:=fich_ini.readString('Dir','Colecovision',directory.Base+'coleco'+main_vars.cadena_dir);
  Directory.Coleco_snap:=fich_ini.readString('Dir','ColecoSnap',directory.Base+'coleco'+main_vars.cadena_dir+'snap'+main_vars.cadena_dir);
  Directory.spectrum_48:=fich_ini.ReadString('Dir','spectrum_rom_48',directory.Base+'roms'+main_vars.cadena_dir+'spectrum.zip');
  Directory.spectrum_128:=fich_ini.ReadString('Dir','spectrum_rom_128',directory.Base+'roms'+main_vars.cadena_dir+'spec128.zip');
  Directory.spectrum_3:=fich_ini.ReadString('Dir','spectrum_rom_plus3',directory.Base+'roms'+main_vars.cadena_dir+'plus3.zip');
  Directory.spectrum_tap:=fich_ini.readString('dir','dir_tap',directory.Base+'tap'+main_vars.cadena_dir);
  Directory.spectrum_snap:=fich_ini.readString('dir','dir_save',directory.Base+'save'+main_vars.cadena_dir);
  Directory.spectrum_image:=fich_ini.readString('dir','dir_gif',directory.Base+'gif'+main_vars.cadena_dir);
  Directory.spectrum_disk:=fich_ini.readString('dir','dir_dsk',directory.Base+'dsk'+main_vars.cadena_dir);
  Directory.amstrad_tap:=fich_ini.readString('dir','ams_tap',directory.Base+'tap'+main_vars.cadena_dir);
  Directory.amstrad_disk:=fich_ini.readString('dir','ams_dsk',directory.Base+'dsk'+main_vars.cadena_dir);
  Directory.amstrad_snap:=fich_ini.readString('dir','ams_snap',directory.Base+'snap'+main_vars.cadena_dir);
  Directory.amstrad_rom:=fich_ini.readString('dir','Amstrad_ROM_dir',directory.Base+'ROM'+main_vars.cadena_dir);
  Directory.Preview:=fich_ini.readString('dir','dir_preview',directory.Base+'preview'+main_vars.cadena_dir);
  main_vars.idioma:=fich_ini.ReadInteger('dsp','idioma',1);
  if main_vars.idioma>max_idiomas then main_vars.idioma:=1;
  sound_status.calidad_audio:=fich_ini.ReadInteger('dsp','sonido',1);
  if sound_status.calidad_audio>3 then sound_status.calidad_audio:=3;
  case sound_status.calidad_audio of
    0:principal1.N110251.Checked:=true;
    1:principal1.N220501.Checked:=true;
    2:principal1.N441001.Checked:=true;
    3:begin
      principal1.SinSonido1.Checked:=true;
      sound_status.hay_sonido:=false;
      end;
  end;
  main_screen.video_mode:=fich_ini.ReadInteger('dsp','video',1);
  if ((main_screen.video_mode<1) or (main_screen.video_mode>5)) then main_screen.video_mode:=1;
  main_screen.pantalla_completa:=false;
  main_vars.tipo_maquina:=fich_ini.ReadInteger('dsp','maquina',0);
  main_vars.auto_exec:=(fich_ini.ReadInteger('dsp','auto_exec',0)=1);
  main_vars.show_crc_error:=(fich_ini.ReadInteger('dsp','show_crc_error',1)=1);
  main_vars.center_screen:=(fich_ini.ReadInteger('dsp','center_screen',1)=1);
  main_vars.x11:=(fich_ini.ReadInteger('dsp','x11',0)=1);
  //configuracion spectrum
  issue2:=(fich_ini.ReadInteger('spectrum','issue',0)=0);
  f:=fich_ini.ReadInteger('spectrum','joystick',0);
  jkempston:=false;
  jcursor:=false;
  jsinclair1:=false;
  jsinclair2:=false;
  case f of
    0:jkempston:=true;
    1:jcursor:=true;
    2:jsinclair1:=true;
    3:jsinclair2:=true;
  end;
  borde.tipo:=fich_ini.ReadInteger('spectrum','border',0);
  mouse.tipo:=fich_ini.ReadInteger('spectrum','tipo_mouse',0);
  beeper_filter:=(fich_ini.ReadInteger('spectrum','beepfilter',0)=1);
  audio_load:=(fich_ini.ReadInteger('spectrum','audioload',0)=1);
  audio_128k:=fich_ini.ReadInteger('spectrum','audio_128k',0);
  beeper_oversample:=fich_ini.ReadInteger('spectrum','beeper_oversample',1);
  ulaplus.enabled:=(fich_ini.ReadInteger('spectrum','ulaplus',0)=1);
  //Configuracion CPC
  for f:=0 to 6 do cpc_rom_slot[f]:=fich_ini.readString('cpc','rom_dir_'+inttostr(f),'');
  cpc_ga.cpc_model:=fich_ini.ReadInteger('cpc','cpcmodel',0);
  cpc_ga.ram_exp:=fich_ini.ReadInteger('cpc','cpcramexp',0);
  //Configuracion SMS
  file_data.sms_is_pal:=(fich_ini.ReadInteger('sms','is_pal',1)=1);
  file_data.sms_bios_enabled:=(fich_ini.ReadInteger('sms','bios_enabled',0)=1);
  //Teclas
  arcade_input.nup[0]:=fich_ini.ReadInteger('keyboard','up_0',KEYBOARD_UP) and $ff;
  arcade_input.ndown[0]:=fich_ini.ReadInteger('keyboard','down_0',KEYBOARD_DOWN) and $ff;
  arcade_input.nleft[0]:=fich_ini.ReadInteger('keyboard','left_0',KEYBOARD_LEFT) and $ff;
  arcade_input.nright[0]:=fich_ini.ReadInteger('keyboard','right_0',KEYBOARD_RIGHT) and $ff;
  arcade_input.nbut0[0]:=fich_ini.ReadInteger('keyboard','but0_0',KEYBOARD_LALT) and $ff;
  arcade_input.nbut1[0]:=fich_ini.ReadInteger('keyboard','but1_0',KEYBOARD_LCTRL) and $ff;
  arcade_input.nbut2[0]:=fich_ini.ReadInteger('keyboard','but2_0',KEYBOARD_LSHIFT) and $ff;
  arcade_input.nbut3[0]:=fich_ini.ReadInteger('keyboard','but3_0',KEYBOARD_A) and $ff;
  arcade_input.nbut4[0]:=fich_ini.ReadInteger('keyboard','but4_0',KEYBOARD_S) and $ff;
  arcade_input.nbut5[0]:=fich_ini.ReadInteger('keyboard','but5_0',KEYBOARD_D) and $ff;
  arcade_input.jbut0[0]:=fich_ini.ReadInteger('keyboard','jbut0_0',0) and $ff;
  arcade_input.jbut1[0]:=fich_ini.ReadInteger('keyboard','jbut1_0',1) and $ff;
  arcade_input.jbut2[0]:=fich_ini.ReadInteger('keyboard','jbut2_0',2) and $ff;
  arcade_input.jbut3[0]:=fich_ini.ReadInteger('keyboard','jbut3_0',3) and $ff;
  arcade_input.jbut4[0]:=fich_ini.ReadInteger('keyboard','jbut4_0',4) and $ff;
  arcade_input.jbut5[0]:=fich_ini.ReadInteger('keyboard','jbut5_0',5) and $ff;
  arcade_input.ncoin[0]:=fich_ini.ReadInteger('keyboard','coin_0',KEYBOARD_5) and $ff;
  arcade_input.ncoin[1]:=fich_ini.ReadInteger('keyboard','coin_1',KEYBOARD_6) and $ff;
  arcade_input.nstart[0]:=fich_ini.ReadInteger('keyboard','start_0',KEYBOARD_1) and $ff;
  arcade_input.nstart[1]:=fich_ini.ReadInteger('keyboard','start_1',KEYBOARD_2) and $ff;
  arcade_input.nup[1]:=fich_ini.ReadInteger('keyboard','up_1',KEYBOARD_NONE) and $ff;
  arcade_input.ndown[1]:=fich_ini.ReadInteger('keyboard','down_1',KEYBOARD_NONE) and $ff;
  arcade_input.nleft[1]:=fich_ini.ReadInteger('keyboard','left_1',KEYBOARD_NONE) and $ff;
  arcade_input.nright[1]:=fich_ini.ReadInteger('keyboard','right_1',KEYBOARD_NONE) and $ff;
  arcade_input.nbut0[1]:=fich_ini.ReadInteger('keyboard','but0_1',KEYBOARD_NONE) and $ff;
  arcade_input.nbut1[1]:=fich_ini.ReadInteger('keyboard','but1_1',KEYBOARD_NONE) and $ff;
  arcade_input.nbut2[1]:=fich_ini.ReadInteger('keyboard','but2_1',KEYBOARD_NONE) and $ff;
  arcade_input.nbut3[1]:=fich_ini.ReadInteger('keyboard','but3_1',KEYBOARD_NONE) and $ff;
  arcade_input.nbut4[1]:=fich_ini.ReadInteger('keyboard','but4_1',KEYBOARD_NONE) and $ff;
  arcade_input.nbut5[1]:=fich_ini.ReadInteger('keyboard','but5_1',KEYBOARD_NONE) and $ff;
  arcade_input.jbut0[1]:=fich_ini.ReadInteger('keyboard','jbut0_1',0) and $ff;
  arcade_input.jbut1[1]:=fich_ini.ReadInteger('keyboard','jbut1_1',1) and $ff;
  arcade_input.jbut2[1]:=fich_ini.ReadInteger('keyboard','jbut2_1',2) and $ff;
  arcade_input.jbut3[1]:=fich_ini.ReadInteger('keyboard','jbut3_1',3) and $ff;
  arcade_input.jbut4[1]:=fich_ini.ReadInteger('keyboard','jbut4_1',4) and $ff;
  arcade_input.jbut5[1]:=fich_ini.ReadInteger('keyboard','jbut5_1',5) and $ff;
  //tipo y numero joystick
  arcade_input.use_key[0]:=(fich_ini.ReadInteger('keyboard','use_keyb_0',0)=0);
  arcade_input.use_key[1]:=(fich_ini.ReadInteger('keyboard','use_keyb_1',0)=0);
  arcade_input.num_joystick[0]:=fich_ini.ReadInteger('keyboard','num_joy_0',0);
  arcade_input.num_joystick[1]:=fich_ini.ReadInteger('keyboard','num_joy_1',0);
  //Joystick calibration
  for f:=0 to NUM_PLAYERS do begin
    arcade_input.joy_left[f]:=fich_ini.ReadInteger('keyboard','joy_left_'+inttostr(f),0);
    arcade_input.joy_right[f]:=fich_ini.ReadInteger('keyboard','joy_right_'+inttostr(f),0);
    arcade_input.joy_up[f]:=fich_ini.ReadInteger('keyboard','joy_up_'+inttostr(f),0);
    arcade_input.joy_down[f]:=fich_ini.ReadInteger('keyboard','joy_down_'+inttostr(f),0);
  end;
  //Cerrar fichero
  fich_ini.free;
end else begin
  Directory.Nes:=directory.base+'nes'+main_vars.cadena_dir;
  Directory.GameBoy:=directory.base+'gameboy'+main_vars.cadena_dir;
  Directory.Chip8:=directory.base+'chip8'+main_vars.cadena_dir;
  Directory.ColecoVision:=directory.base+'coleco'+main_vars.cadena_dir;
  Directory.Coleco_snap:=directory.Base+'coleco'+main_vars.cadena_dir+'snap'+main_vars.cadena_dir;
  Directory.sms:=directory.base+'sms'+main_vars.cadena_dir;
  Directory.qsnapshot:=directory.base+'qsnap'+main_vars.cadena_dir;
  Directory.spectrum_image:=directory.base+'gif'+main_vars.cadena_dir;
  Directory.Arcade_roms:=directory.base+'roms'+main_vars.cadena_dir;
  Directory.lenguaje:=directory.base+'lng'+main_vars.cadena_dir;
  Directory.Arcade_hi:=directory.base+'hi'+main_vars.cadena_dir;
  Directory.Arcade_nvram:=directory.base+'nvram'+main_vars.cadena_dir;
  Directory.Arcade_samples:=directory.base+'samples'+main_vars.cadena_dir;
  Directory.spectrum_tap:=directory.base+'tap'+main_vars.cadena_dir;
  Directory.Preview:=directory.base+'preview'+main_vars.cadena_dir;
  Directory.spectrum_snap:=directory.base+'save'+main_vars.cadena_dir;
  Directory.spectrum_disk:=directory.base+'dsk'+main_vars.cadena_dir;
  Directory.spectrum_48:=directory.base+'roms'+main_vars.cadena_dir+'spectrum.zip';
  Directory.spectrum_128:=directory.base+'roms'+main_vars.cadena_dir+'spec128.zip';
  Directory.spectrum_3:=directory.base+'roms'+main_vars.cadena_dir+'plus3.zip';
  Directory.amstrad_tap:=directory.base+'tap'+main_vars.cadena_dir;
  Directory.amstrad_disk:=directory.base+'dsk'+main_vars.cadena_dir;
  Directory.amstrad_snap:=directory.base+'snap'+main_vars.cadena_dir;
  Directory.amstrad_rom:=directory.base+'roms'+main_vars.cadena_dir;
  main_vars.idioma:=1;
  main_screen.video_mode:=1;
  sound_status.calidad_audio:=1;
  main_screen.pantalla_completa:=false;
  main_vars.show_crc_error:=true;
  main_vars.center_screen:=true;
  main_vars.x11:=false;
  //configuracion basica spectrum
  audio_128k:=0;
  beeper_filter:=false;
  audio_load:=true;
  issue2:=true;
  jkempston:=true;
  jcursor:=false;
  jsinclair1:=false;
  jsinclair2:=false;
  borde.tipo:=1;
  mouse.tipo:=0;
  beeper_oversample:=1;
  ulaplus.enabled:=true;
  //Configuracion CPC
  for f:=0 to 6 do cpc_rom_slot[f]:='';
  cpc_ga.cpc_model:=0;
  cpc_ga.ram_exp:=0;
  //Configuracion basica SMS
  file_data.sms_is_pal:=false;
  file_data.sms_bios_enabled:=true;
  //Teclas
  arcade_input.nup[0]:=KEYBOARD_UP;
  arcade_input.ndown[0]:=KEYBOARD_DOWN;
  arcade_input.nleft[0]:=KEYBOARD_LEFT;
  arcade_input.nright[0]:=KEYBOARD_RIGHT;
  arcade_input.nbut0[0]:=KEYBOARD_LALT;
  arcade_input.nbut1[0]:=KEYBOARD_LCTRL;
  arcade_input.nbut2[0]:=KEYBOARD_LSHIFT;
  arcade_input.nbut3[0]:=KEYBOARD_A;
  arcade_input.nbut4[0]:=KEYBOARD_S;
  arcade_input.nbut5[0]:=KEYBOARD_D;
  arcade_input.jbut0[0]:=0;
  arcade_input.jbut1[0]:=1;
  arcade_input.jbut2[0]:=2;
  arcade_input.jbut3[0]:=3;
  arcade_input.jbut4[0]:=4;
  arcade_input.jbut5[0]:=5;
  arcade_input.ncoin[0]:=KEYBOARD_5;
  arcade_input.ncoin[1]:=KEYBOARD_6;
  arcade_input.nstart[0]:=KEYBOARD_1;
  arcade_input.nstart[1]:=KEYBOARD_2;
  arcade_input.nup[1]:=KEYBOARD_NONE;
  arcade_input.ndown[1]:=KEYBOARD_NONE;
  arcade_input.nleft[1]:=KEYBOARD_NONE;
  arcade_input.nright[1]:=KEYBOARD_NONE;
  arcade_input.nbut0[1]:=KEYBOARD_NONE;
  arcade_input.nbut1[1]:=KEYBOARD_NONE;
  arcade_input.nbut2[1]:=KEYBOARD_NONE;
  arcade_input.nbut3[1]:=KEYBOARD_NONE;
  arcade_input.nbut4[1]:=KEYBOARD_NONE;
  arcade_input.nbut5[1]:=KEYBOARD_NONE;
  arcade_input.jbut0[1]:=0;
  arcade_input.jbut1[1]:=1;
  arcade_input.jbut2[1]:=2;
  arcade_input.jbut3[1]:=3;
  arcade_input.jbut4[1]:=4;
  arcade_input.jbut5[1]:=5;
  arcade_input.use_key[0]:=true;
  arcade_input.use_key[1]:=true;
  arcade_input.num_joystick[0]:=0;
  arcade_input.num_joystick[1]:=0;
  //Joystick calibration
  for f:=0 to NUM_PLAYERS do begin
    arcade_input.joy_left[f]:=0;
    arcade_input.joy_right[f]:=0;
    arcade_input.joy_up[f]:=0;
    arcade_input.joy_down[f]:=0;
  end;
end;
if ((directory.Nes='') or (directory.nes[length(directory.nes)]<>main_vars.cadena_dir)) then Directory.Nes:=directory.base+'nes'+main_vars.cadena_dir;
if ((Directory.GameBoy='') or (directory.gameboy[length(directory.gameboy)]<>main_vars.cadena_dir)) then Directory.GameBoy:=directory.base+'gameboy'+main_vars.cadena_dir;
if ((Directory.Chip8='') or (directory.chip8[length(directory.chip8)]<>main_vars.cadena_dir)) then Directory.Chip8:=directory.base+'chip8'+main_vars.cadena_dir;
if ((Directory.sms='') or (directory.chip8[length(directory.sms)]<>main_vars.cadena_dir)) then Directory.Chip8:=directory.base+'sms'+main_vars.cadena_dir;
if ((Directory.ColecoVision='') or (directory.ColecoVision[length(directory.ColecoVision)]<>main_vars.cadena_dir)) then Directory.ColecoVision:=directory.base+'coleco'+main_vars.cadena_dir;
if ((Directory.Coleco_snap='') or (directory.ColecoVision[length(directory.Coleco_snap)]<>main_vars.cadena_dir)) then Directory.ColecoVision:=directory.base+'coleco'+main_vars.cadena_dir+'snap'+main_vars.cadena_dir;
if ((Directory.spectrum_image='') or (directory.spectrum_image[length(directory.spectrum_image)]<>main_vars.cadena_dir)) then Directory.spectrum_image:=directory.base+'gif'+main_vars.cadena_dir;
if Directory.qsnapshot='' then Directory.qsnapshot:=directory.base+'qsnap'+main_vars.cadena_dir;
if Directory.spectrum_48='' then Directory.spectrum_48:=directory.base+'roms'+main_vars.cadena_dir+'spectrum.zip';
if Directory.spectrum_128='' then Directory.spectrum_128:=directory.base+'roms'+main_vars.cadena_dir+'spec128.zip';
if Directory.spectrum_3='' then Directory.spectrum_3:=directory.base+'roms'+main_vars.cadena_dir+'plus3.zip';
if ((Directory.Arcade_roms='') or (directory.Arcade_roms[length(directory.Arcade_roms)]<>main_vars.cadena_dir)) then Directory.Arcade_roms:=directory.base+'roms'+main_vars.cadena_dir;
if ((Directory.lenguaje='') or (directory.lenguaje[length(directory.lenguaje)]<>main_vars.cadena_dir)) then Directory.lenguaje:=directory.base+'lng'+main_vars.cadena_dir;
if ((directory.Arcade_hi='') or (directory.Arcade_hi[length(directory.Arcade_hi)]<>main_vars.cadena_dir)) then directory.Arcade_hi:=directory.base+'hi'+main_vars.cadena_dir;
if ((directory.Arcade_nvram='') or (directory.Arcade_nvram[length(directory.Arcade_nvram)]<>main_vars.cadena_dir)) then directory.Arcade_nvram:=directory.base+'nvram'+main_vars.cadena_dir;
if ((directory.Arcade_samples='') or (directory.Arcade_samples[length(directory.Arcade_samples)]<>main_vars.cadena_dir)) then directory.Arcade_samples:=directory.base+'samples'+main_vars.cadena_dir;
if ((Directory.spectrum_tap='') or (directory.spectrum_tap[length(directory.spectrum_tap)]<>main_vars.cadena_dir)) then Directory.spectrum_tap:=directory.base+'tap'+main_vars.cadena_dir;
if ((Directory.Preview='') or (directory.Preview[length(directory.Preview)]<>main_vars.cadena_dir)) then Directory.Preview:=directory.base+'preview'+main_vars.cadena_dir;
if ((Directory.spectrum_snap='') or (directory.spectrum_snap[length(directory.spectrum_snap)]<>main_vars.cadena_dir)) then directory.spectrum_snap:=directory.base+'snap'+main_vars.cadena_dir;
if ((Directory.spectrum_disk='') or (directory.spectrum_disk[length(directory.spectrum_disk)]<>main_vars.cadena_dir)) then Directory.spectrum_disk:=directory.base+'dsk'+main_vars.cadena_dir;
if ((Directory.amstrad_tap='') or (directory.amstrad_tap[length(directory.amstrad_tap)]<>main_vars.cadena_dir)) then Directory.amstrad_tap:=directory.base+'tap'+main_vars.cadena_dir;
if ((Directory.amstrad_disk='') or (directory.amstrad_disk[length(directory.amstrad_disk)]<>main_vars.cadena_dir)) then Directory.amstrad_disk:=directory.base+'dsk'+main_vars.cadena_dir;
if ((Directory.amstrad_snap='') or (directory.amstrad_snap[length(directory.amstrad_snap)]<>main_vars.cadena_dir)) then Directory.amstrad_snap:=directory.base+'snap'+main_vars.cadena_dir;
if ((Directory.amstrad_rom='') or (directory.amstrad_rom[length(directory.amstrad_rom)]<>main_vars.cadena_dir)) then Directory.amstrad_rom:=directory.base+'snap'+main_vars.cadena_dir;
end;

procedure file_ini_save;
var
  fich_ini:Tinifile;
  f:byte;
begin
fich_ini:=Tinifile.Create(directory.base+'dsp.ini');
if @fich_ini=nil then begin
  MessageDlg('Error writing INI file!', mtError,[mbOk], 0);
  exit;
end;
fich_ini.WriteInteger('dsp','idioma',main_vars.idioma);
//Inicializacion de Diretorios
fich_ini.Writestring('dir','arcade',Directory.Arcade_roms);
fich_ini.Writestring('dir','lng',Directory.lenguaje);
fich_ini.Writestring('dir','dir_hi',Directory.Arcade_hi);
fich_ini.Writestring('dir','dir_nvram',Directory.Arcade_nvram);
fich_ini.Writestring('dir','dir_samples',Directory.Arcade_samples);
fich_ini.Writestring('dir','nes',Directory.Nes);
fich_ini.Writestring('dir','chip8',Directory.Chip8);
fich_ini.Writestring('dir','sms',Directory.sms);
fich_ini.Writestring('dir','qsnapshot',Directory.qsnapshot);
fich_ini.Writestring('dir','GameBoy',Directory.GameBoy);
fich_ini.Writestring('dir','Colecovision',Directory.ColecoVision);
fich_ini.Writestring('dir','ColecoSnap',Directory.Coleco_snap);
fich_ini.Writestring('dir','spectrum_rom_48',Directory.spectrum_48);
fich_ini.Writestring('dir','spectrum_rom_128',Directory.spectrum_128);
fich_ini.Writestring('dir','spectrum_rom_plus3',Directory.spectrum_3);
fich_ini.Writestring('dir','dir_gif',Directory.spectrum_image);
fich_ini.Writestring('dir','dir_tap',Directory.spectrum_tap);
fich_ini.Writestring('dir','dir_preview',Directory.Preview);
fich_ini.Writestring('dir','dir_save',Directory.spectrum_snap);
fich_ini.Writestring('dir','dir_dsk',Directory.spectrum_disk);
fich_ini.Writestring('dir','ams_tap',Directory.amstrad_tap);
fich_ini.Writestring('dir','ams_dsk',Directory.amstrad_disk);
fich_ini.Writestring('dir','ams_snap',Directory.amstrad_snap);
fich_ini.Writestring('dir','ams_rom',Directory.amstrad_rom);
//Config general
fich_ini.WriteInteger('dsp','sonido',sound_status.calidad_audio);
fich_ini.WriteInteger('dsp','video',main_screen.video_mode);
fich_ini.WriteInteger('dsp','maquina',main_vars.tipo_maquina);
fich_ini.WriteInteger('dsp','auto_exec',byte(main_vars.auto_exec));
fich_ini.WriteInteger('dsp','show_crc_error',byte(main_vars.show_crc_error));
fich_ini.WriteInteger('dsp','center_screen',byte(main_vars.center_screen));
fich_ini.WriteInteger('dsp','x11',byte(main_vars.x11));
//Config Spectrum
fich_ini.WriteInteger('spectrum','issue',byte(issue2));
if jkempston then f:=0;
if jcursor then f:=1;
if jsinclair1 then f:=2;
if jsinclair2 then f:=3;
fich_ini.WriteInteger('spectrum','joystick',f);
fich_ini.WriteInteger('spectrum','border',borde.tipo);
fich_ini.WriteInteger('spectrum','tipo_mouse',mouse.tipo);
fich_ini.WriteInteger('spectrum','beepfilter',byte(beeper_filter));
f:=byte(audio_load);
if main_vars.tipo_maquina=255 then f:=0;
fich_ini.WriteInteger('spectrum','audioload',f);
fich_ini.WriteInteger('spectrum','audio_128k',audio_128k);
fich_ini.WriteInteger('spectrum','beeper_oversample',beeper_oversample);
fich_ini.WriteInteger('spectrum','ulaplus',byte(ulaplus.enabled));
//Configuracion CPC
for f:=0 to 6 do fich_ini.WriteString('cpc','rom_dir_'+inttostr(f),cpc_rom_slot[f]);
fich_ini.WriteInteger('cpc','cpcmodel',cpc_ga.cpc_model);
fich_ini.WriteInteger('cpc','cpcramexp',cpc_ga.ram_exp);
//Config SMS
fich_ini.WriteInteger('sms','is_pal',byte(file_data.sms_is_pal));
fich_ini.WriteInteger('sms','bios_enabled',byte(file_data.sms_bios_enabled));
//Teclas P1
fich_ini.WriteInteger('keyboard','up_0',arcade_input.nup[0]);
fich_ini.WriteInteger('keyboard','down_0',arcade_input.ndown[0]);
fich_ini.WriteInteger('keyboard','left_0',arcade_input.nleft[0]);
fich_ini.WriteInteger('keyboard','right_0',arcade_input.nright[0]);
fich_ini.WriteInteger('keyboard','but0_0',arcade_input.nbut0[0]);
fich_ini.WriteInteger('keyboard','but1_0',arcade_input.nbut1[0]);
fich_ini.WriteInteger('keyboard','but2_0',arcade_input.nbut2[0]);
fich_ini.WriteInteger('keyboard','but3_0',arcade_input.nbut3[0]);
fich_ini.WriteInteger('keyboard','but4_0',arcade_input.nbut4[0]);
fich_ini.WriteInteger('keyboard','but5_0',arcade_input.nbut5[0]);
fich_ini.WriteInteger('keyboard','jbut0_0',arcade_input.jbut0[0]);
fich_ini.WriteInteger('keyboard','jbut1_0',arcade_input.jbut1[0]);
fich_ini.WriteInteger('keyboard','jbut2_0',arcade_input.jbut2[0]);
fich_ini.WriteInteger('keyboard','jbut3_0',arcade_input.jbut3[0]);
fich_ini.WriteInteger('keyboard','jbut4_0',arcade_input.jbut4[0]);
fich_ini.WriteInteger('keyboard','jbut5_0',arcade_input.jbut5[0]);
//Teclas Misc
fich_ini.WriteInteger('keyboard','coin_0',arcade_input.ncoin[0]);
fich_ini.WriteInteger('keyboard','coin_1',arcade_input.ncoin[1]);
fich_ini.WriteInteger('keyboard','start_0',arcade_input.nstart[0]);
fich_ini.WriteInteger('keyboard','start_1',arcade_input.nstart[1]);
//Teclas P2
fich_ini.WriteInteger('keyboard','up_1',arcade_input.nup[1]);
fich_ini.WriteInteger('keyboard','down_1',arcade_input.ndown[1]);
fich_ini.WriteInteger('keyboard','left_1',arcade_input.nleft[1]);
fich_ini.WriteInteger('keyboard','right_1',arcade_input.nright[1]);
fich_ini.WriteInteger('keyboard','but0_1',arcade_input.nbut0[1]);
fich_ini.WriteInteger('keyboard','but1_1',arcade_input.nbut1[1]);
fich_ini.WriteInteger('keyboard','but2_1',arcade_input.nbut2[1]);
fich_ini.WriteInteger('keyboard','but3_1',arcade_input.nbut3[1]);
fich_ini.WriteInteger('keyboard','but4_1',arcade_input.nbut4[1]);
fich_ini.WriteInteger('keyboard','but5_1',arcade_input.nbut5[1]);
fich_ini.WriteInteger('keyboard','jbut0_1',arcade_input.jbut0[1]);
fich_ini.WriteInteger('keyboard','jbut1_1',arcade_input.jbut1[1]);
fich_ini.WriteInteger('keyboard','jbut2_1',arcade_input.jbut2[1]);
fich_ini.WriteInteger('keyboard','jbut3_1',arcade_input.jbut3[1]);
fich_ini.WriteInteger('keyboard','jbut4_1',arcade_input.jbut4[1]);
fich_ini.WriteInteger('keyboard','jbut5_1',arcade_input.jbut5[1]);
//tipo y numero joystick
fich_ini.WriteInteger('keyboard','use_keyb_0',byte(not(arcade_input.use_key[0])));
fich_ini.WriteInteger('keyboard','use_keyb_1',byte(not(arcade_input.use_key[1])));
fich_ini.WriteInteger('keyboard','num_joy_0',arcade_input.num_joystick[0]);
fich_ini.WriteInteger('keyboard','num_joy_1',arcade_input.num_joystick[1]);
//Joystick calibration
for f:=0 to NUM_PLAYERS do begin
  fich_ini.WriteInteger('keyboard','joy_up_'+inttostr(f),arcade_input.joy_up[f]);
  fich_ini.WriteInteger('keyboard','joy_down_'+inttostr(f),arcade_input.joy_down[f]);
  fich_ini.WriteInteger('keyboard','joy_left_'+inttostr(f),arcade_input.joy_left[f]);
  fich_ini.WriteInteger('keyboard','joy_right_'+inttostr(f),arcade_input.joy_right[f]);
end;
//Cerrar
fich_ini.Free;
end;

function file_name_only(cadena:string):string;
var
  f:word;
  cadena2:string;
begin
for f:=length(cadena) downto 1 do begin
  if cadena[f]=main_vars.cadena_dir then begin
    cadena2:=copy(cadena,f+1,length(cadena)-f);
    break;
  end;
end;
if cadena2='' then cadena2:=cadena;
file_name_only:=cadena2;
end;


function read_file_size(nombre_file:string;var longitud:integer):boolean;
var
  fichero:file of byte;
begin
read_file_size:=false;
{$I-}
  filemode:=fmOpenRead;
  assignfile(fichero,nombre_file);
  reset(fichero);
  if ioresult<>0 then exit;
  longitud:=filesize(fichero);
  closefile(fichero);
  filemode:=fmOpenReadWrite;
{$I+}
if longitud>0 then read_file_size:=true;
end;

function read_file(nombre_file:string;donde:pbyte;var longitud:integer):boolean;
var
  fichero:file of byte;
begin
read_file:=false;
{$I-}
  filemode:=fmOpenRead;
  assignfile(fichero,nombre_file);
  reset(fichero);
  if ioresult<>0 then begin
      MessageDlg('Cannot open file: '+'"'+nombre_file+'"',mtError,[mbOk], 0);
      exit;
  end;
  longitud:=filesize(fichero);
  blockread(fichero,donde^,longitud);
  closefile(fichero);
  filemode:=fmOpenReadWrite;
{$I+}
if longitud>0 then read_file:=true;
end;

function write_file(nombre_file:string;donde:pbyte;longitud:integer):boolean;
var
  fichero:file of byte;
  escrito:integer;
begin
write_file:=false;
{$I-}
assignfile(fichero,nombre_file);
rewrite(fichero);
if ioresult<>0 then begin
  MessageDlg('Cannot write file: '+'"'+nombre_file+'"',mtError,[mbOk], 0);
  exit;
end;
blockwrite(fichero,donde^,longitud,escrito);
if longitud<>escrito then begin
  MessageDlg('Error writing data: '+'"'+nombre_file+'"',mtError,[mbOk], 0);
  close(fichero);
  exit;
end;
close(fichero);
{$I+}
write_file:=true;
end;

//Parte ZIP
function search_file_from_zip(nombre_zip,file_mask:string;var nombre_file:string;var longitud,crc:integer;warning:boolean):boolean;
var
  zfile:unzFile;
  zfile_info:unz_file_info_ptr;
  zglobal_info:unz_global_info;
  f,h:integer;
  pfile_name,temp:pchar;
  extension,extension2:string;
begin
search_file_from_zip:=false;
//Si no existe el ZIP -> Error
if not(FileExists(nombre_zip)) then begin
  if warning then MessageDlg('ZIP File not found: '+'"'+nombre_zip+'"', mtError,[mbOk], 0);
  exit;
end;
zfile:=unzOpen(pchar(nombre_zip));  //Abro el ZIP
getmem(zfile_info,sizeof(unz_file_info));  //Creo la info del fichero
unzGetGlobalInfo(zfile,zglobal_info); //Asignarle info global
if unzGoToFirstFile(zfile)<>0 then exit;  //Buscar primer fichero
for h:=1 to 25 {zglobal_info.number_entry} do begin //En lugar de buscar en todos los ficheros, solo busco en los 25 primeros... o se cuelga!!
    unzOpenCurrentFile(zfile);  //Cojo el primer fichero
    getmem(pfile_name,200);
    unzGetCurrentFileInfo(zfile,zfile_info,pfile_name,200,nil,0,nil,0);  //Cojo la informacion del fichero
    unzCloseCurrentFile(zfile);
    temp:=pfile_name;
    nombre_file:='';
    for f:=1 to zfile_info.size_filename do begin
        nombre_file:=nombre_file+temp^;
        inc(temp);
    end;
    freemem(pfile_name);
    longitud:=zfile_info.uncompressed_size;
    crc:=zfile_info.crc;
    //Hay algun wildcard?
    if file_mask[1]='*' then begin
       if file_mask='*.*' then begin
          freemem(zfile_info);
          search_file_from_zip:=true;
          exit;
       end;
       extension:=extension_fichero(nombre_file);
       extension2:=extension_fichero(file_mask);
       if extension=extension2 then begin
          freemem(zfile_info);
          search_file_from_zip:=true;
          exit;
       end;
    end else begin //Busca un fichero
        if nombre_file=file_mask then begin
          freemem(zfile_info);
          search_file_from_zip:=true;
          exit;
       end;
    end;
    if unzGoToNextFile(zfile)<>0 then exit;
end;
if warning then MessageDlg(leng[main_vars.idioma].errores[0]+' "'+nombre_file+'" '+leng[main_vars.idioma].errores[1]+' '+nombre_zip, mtError,[mbOk], 0);
freemem(zfile_info);
end;

function find_first_file_zip(nombre_zip,file_mask:string;var nombre_file:string;var longitud,crc:integer;warning:boolean):boolean;
var
  zfile:unzFile;
  zfile_info:unz_file_info_ptr;
  zglobal_info:unz_global_info;
  f,h:integer;
  pfile_name,temp:pchar;
  extension,extension2:string;
begin
find_first_file_zip:=false;
//Si no existe el ZIP -> Error
if not(FileExists(nombre_zip)) then begin
  if warning then MessageDlg('ZIP File not found: '+'"'+nombre_zip+'"', mtError,[mbOk], 0);
  exit;
end;
zfile:=unzOpen(pchar(nombre_zip));  //Abro el ZIP
getmem(zfile_info,sizeof(unz_file_info));  //Creo la info del fichero
unzGetGlobalInfo(zfile,zglobal_info); //Asignarle info global
if unzGoToFirstFile(zfile)<>0 then exit;  //Buscar primer fichero
for h:=1 to zglobal_info.number_entry do begin
    unzOpenCurrentFile(zfile);  //Cojo el primer fichero
    getmem(pfile_name,200);
    unzGetCurrentFileInfo(zfile,zfile_info,pfile_name,200,nil,0,nil,0);  //Cojo la informacion del fichero
    unzCloseCurrentFile(zfile);
    temp:=pfile_name;
    nombre_file:='';
    for f:=1 to zfile_info.size_filename do begin
        nombre_file:=nombre_file+temp^;
        inc(temp);
    end;
    freemem(pfile_name);
    longitud:=zfile_info.uncompressed_size;
    crc:=zfile_info.crc;
    zip_find_files_data.posicion_dentro_zip:=h-1;
    zip_find_files_data.nombre_zip:=nombre_zip;
    zip_find_files_data.file_mask:=file_mask;
    //Hay algun wildcard?
    if file_mask[1]='*' then begin
       if file_mask='*.*' then begin
          freemem(zfile_info);
          find_first_file_zip:=true;
          exit;
       end;
       extension:=extension_fichero(nombre_file);
       extension2:=extension_fichero(file_mask);
       if extension=extension2 then begin
          freemem(zfile_info);
          find_first_file_zip:=true;
          exit;
       end;
    end else begin //Busca un fichero
        if nombre_file=file_mask then begin
          freemem(zfile_info);
          find_first_file_zip:=true;
          exit;
       end;
    end;
    if unzGoToNextFile(zfile)<>0 then exit;
end;
if warning then MessageDlg(leng[main_vars.idioma].errores[0]+' "'+nombre_file+'" '+leng[main_vars.idioma].errores[1]+' '+nombre_zip, mtError,[mbOk], 0);
freemem(zfile_info);
end;

function find_next_file_zip(var nombre_file:string;var longitud,crc:integer):boolean;
var
  zfile:unzFile;
  zfile_info:unz_file_info_ptr;
  zglobal_info:unz_global_info;
  f,h:integer;
  pfile_name,temp:pchar;
  extension,extension2:string;
begin
find_next_file_zip:=false;
zfile:=unzOpen(pchar(zip_find_files_data.nombre_zip));  //Abro el ZIP (ya existe)
getmem(zfile_info,sizeof(unz_file_info));  //Creo la info del fichero
unzGetGlobalInfo(zfile,zglobal_info); //Asignarle info global
if unzGoToFirstFile(zfile)<>0 then exit;  //Buscar primer fichero
zip_find_files_data.posicion_dentro_zip:=zip_find_files_data.posicion_dentro_zip+1;
//He llegado al final?
if zip_find_files_data.posicion_dentro_zip>=zglobal_info.number_entry then begin
  freemem(zfile_info);
  exit;
end;
//Busco el siguiente
for f:=1 to zip_find_files_data.posicion_dentro_zip do begin
    if unzGoToNextFile(zfile)<>0 then begin
       freemem(zfile_info);
       exit;
    end;
end;
for h:=zip_find_files_data.posicion_dentro_zip to zglobal_info.number_entry do begin
    unzOpenCurrentFile(zfile);  //Cojo el primer fichero
    getmem(pfile_name,200);
    unzGetCurrentFileInfo(zfile,zfile_info,pfile_name,200,nil,0,nil,0);  //Cojo la informacion del fichero
    unzCloseCurrentFile(zfile);
    temp:=pfile_name;
    nombre_file:='';
    for f:=1 to zfile_info.size_filename do begin
        nombre_file:=nombre_file+temp^;
        inc(temp);
    end;
    freemem(pfile_name);
    longitud:=zfile_info.uncompressed_size;
    crc:=zfile_info.crc;
    //Hay algun wildcard?
    if zip_find_files_data.file_mask[1]='*' then begin
       if zip_find_files_data.file_mask='*.*' then begin
          freemem(zfile_info);
          find_next_file_zip:=true;
          exit;
       end;
       extension:=extension_fichero(nombre_file);
       extension2:=extension_fichero(zip_find_files_data.file_mask);
       if extension=extension2 then begin
          freemem(zfile_info);
          find_next_file_zip:=true;
          exit;
       end;
    end else begin //Busca un fichero
        if nombre_file=zip_find_files_data.file_mask then begin
          freemem(zfile_info);
          find_next_file_zip:=true;
          exit;
       end;
    end;
    if unzGoToNextFile(zfile)<>0 then exit
       else zip_find_files_data.posicion_dentro_zip:=zip_find_files_data.posicion_dentro_zip+1;
end;
//Existe...
freemem(zfile_info);
end;

function load_file_from_zip(nombre_zip,nombre_file:string;donde:pbyte;var longitud,crc:integer;warning:boolean):boolean;
var
  zfile:unzFile;
  zfile_info:unz_file_info_ptr;
  res:longint;
begin
load_file_from_zip:=false;
//Si no existe el ZIP -> Error
if not(FileExists(nombre_zip)) then begin
  if warning then MessageDlg('ZIP File not found: '+'"'+nombre_zip+'"', mtError,[mbOk], 0);
  exit;
end;
zfile:=unzOpen(pchar(nombre_zip));  //Abro el ZIP
getmem(zfile_info,sizeof(unz_file_info));  //Creo la info del fichero
res:=unzLocateFile(zfile,pchar(nombre_file),0);
//No existe
if res<>0 then begin
   if warning then MessageDlg(leng[main_vars.idioma].errores[0]+' "'+nombre_file+'" '+leng[main_vars.idioma].errores[1]+' '+nombre_zip, mtError,[mbOk], 0);
   freemem(zfile_info);
   exit;
end;
unzOpenCurrentFile(zfile);
unzGetCurrentFileInfo(zfile,zfile_info,nil,0,nil,0,nil,0);
longitud:=zfile_info.uncompressed_size;
crc:=zfile_info.crc;
unzReadCurrentFile(zfile,donde,longitud);
freemem(zfile_info);
load_file_from_zip:=true;
end;

function load_file_from_zip_crc(nombre_zip:string;donde:pbyte;var longitud:integer;crc:integer):boolean;
var
  zfile:unzFile;
  zglobal_info:unz_global_info;
  find:boolean;
  f:word;
  zfile_info:unz_file_info_ptr;
begin
load_file_from_zip_crc:=false;
//Si no existe el ZIP -> Error
if not(FileExists(nombre_zip)) then exit;
zfile:=unzOpen(pchar(nombre_zip));  //Abrir el ZIP
unzGetGlobalInfo(zfile,zglobal_info); //Asignarle info global
unzGoToFirstFile(zfile);  //Buscar primer fichero
getmem(zfile_info,sizeof(unz_file_info)); //Crear info file
find:=false;
for f:=1 to zglobal_info.number_entry do begin
  unzGetCurrentFileInfo(zfile,zfile_info,nil,0,nil,0,nil,0);
  if zfile_info.crc=crc then begin
    longitud:=zfile_info.uncompressed_size;
    find:=true;
    break;
  end;
  unzGoToNextFile(zfile);
end;
if not(find) then begin
   freemem(zfile_info);
   unzClose(zfile);
   exit;
end;
unzOpenCurrentFile(zfile);
unzReadCurrentFile(zfile,donde,longitud);
unzCloseCurrentFile(zfile);
unzClose(zfile);
freemem(zfile_info);
load_file_from_zip_crc:=true;
end;

procedure compress_zlib(in_buffer:pointer;in_size:integer;out_buffer:pointer;var out_size:integer);
var
  buffer:pointer;
begin
  buffer:=nil;
  ZCompress(pointer(in_buffer),in_size,buffer,out_size,zcDefault);
  copymemory(out_buffer,buffer,out_size);
  freemem(buffer);
end;

procedure decompress_zlib(in_buffer:pointer;in_size:integer;var out_buffer:pointer;var out_size:integer);
var
  buffer:pointer;
begin
  buffer:=nil;
  ZDecompress(pointer(in_buffer),in_size,buffer,out_size);
  if out_buffer=nil then getmem(out_buffer,out_size);
  copymemory(out_buffer,buffer,out_size);
  freemem(buffer);
end;

end.
