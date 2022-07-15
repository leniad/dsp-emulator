unit file_engine;

interface
uses {$IFDEF windows}windows,{$endif}
     {$ifdef fpc}
     zipper,zdeflate,zinflate,zbase,ziputils,unzip2,
     {$else}
     Zlib,zip,
     {$endif}
     sysutils,dialogs,lenguaje,sound_engine,inifiles,main_engine,
     controls_engine,misc_functions,timer_engine;

type
    tzip_find_files=record
      posicion_dentro_zip:integer;
      nombre_zip,file_mask:string;
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
function find_next_file_zip(var nombre_file:string;var longitud,crc:integer):boolean;
function load_file_from_zip(nombre_zip,nombre_file:string;donde:pbyte;var longitud,crc:integer;warning:boolean):boolean;
function load_file_from_zip_crc(nombre_zip:string;donde:pbyte;var longitud:integer;crc:integer):boolean;
//Parte ZLIB
procedure compress_zlib(in_buffer:pointer;in_size:integer;out_buffer:pointer;var out_size:integer);
procedure decompress_zlib(in_buffer:pointer;in_size:integer;var out_buffer:pointer;var out_size:integer);

var
  zip_find_files_data:tzip_find_files;

implementation
uses spectrum_misc,principal,amstrad_cpc,sms,gb;

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
  split_dirs(fich_ini.readString('Dir','arcade',directory.Base+'roms'));
  Directory.Arcade_hi:=fich_ini.readString('dir','dir_hi',directory.Base+'hi'+main_vars.cadena_dir)+main_vars.cadena_dir;
  Directory.Arcade_nvram:=fich_ini.readString('dir','dir_nvram',directory.Base+'nvram'+main_vars.cadena_dir)+main_vars.cadena_dir;
  Directory.qsnapshot:=fich_ini.readString('dir','qsnapshot',directory.Base+'qsnap'+main_vars.cadena_dir)+main_vars.cadena_dir;
  Directory.Arcade_samples:=fich_ini.readString('dir','dir_samples',directory.Base+'samples'+main_vars.cadena_dir)+main_vars.cadena_dir;
  Directory.Nes:=fich_ini.readString('Dir','nes',directory.Base+'nes'+main_vars.cadena_dir)+main_vars.cadena_dir;
  Directory.GameBoy:=fich_ini.readString('Dir','GameBoy',directory.Base+'gameboy'+main_vars.cadena_dir)+main_vars.cadena_dir;
  Directory.Chip8:=fich_ini.readString('Dir','Chip8',directory.Base+'chip8'+main_vars.cadena_dir)+main_vars.cadena_dir;
  Directory.sms:=fich_ini.readString('Dir','SMS',directory.Base+'sms'+main_vars.cadena_dir)+main_vars.cadena_dir;
  Directory.SG1000:=fich_ini.readString('Dir','SG1000',directory.Base+'sg1000'+main_vars.cadena_dir)+main_vars.cadena_dir;
  Directory.gg:=fich_ini.readString('Dir','gg',directory.Base+'gg'+main_vars.cadena_dir)+main_vars.cadena_dir;
  Directory.scv:=fich_ini.readString('Dir','scv',directory.Base+'scv'+main_vars.cadena_dir)+main_vars.cadena_dir;
  Directory.Coleco_snap:=fich_ini.readString('Dir','ColecoSnap',directory.Base+'coleco'+main_vars.cadena_dir)+main_vars.cadena_dir;
  Directory.spectrum_48:=fich_ini.ReadString('Dir','spectrum_rom_48',directory.Base+'roms'+main_vars.cadena_dir+'spectrum.zip');
  Directory.spectrum_128:=fich_ini.ReadString('Dir','spectrum_rom_128',directory.Base+'roms'+main_vars.cadena_dir+'spec128.zip');
  Directory.spectrum_3:=fich_ini.ReadString('Dir','spectrum_rom_plus3',directory.Base+'roms'+main_vars.cadena_dir+'plus3.zip');
  Directory.spectrum_tap_snap:=fich_ini.readString('dir','dir_save',directory.Base+'snap'+main_vars.cadena_dir)+main_vars.cadena_dir;
  Directory.spectrum_image:=fich_ini.readString('dir','dir_gif',directory.Base+'gif'+main_vars.cadena_dir)+main_vars.cadena_dir;
  Directory.spectrum_disk:=fich_ini.readString('dir','dir_dsk',directory.Base+'dsk'+main_vars.cadena_dir)+main_vars.cadena_dir;
  Directory.amstrad_tap:=fich_ini.readString('dir','ams_tap',directory.Base+'cdt'+main_vars.cadena_dir)+main_vars.cadena_dir;
  Directory.amstrad_disk:=fich_ini.readString('dir','ams_dsk',directory.Base+'dsk'+main_vars.cadena_dir)+main_vars.cadena_dir;
  Directory.amstrad_snap:=fich_ini.readString('dir','ams_snap',directory.Base+'snap'+main_vars.cadena_dir)+main_vars.cadena_dir;
  Directory.amstrad_rom:=fich_ini.readString('dir','Amstrad_ROM_dir',directory.Base+'snap'+main_vars.cadena_dir)+main_vars.cadena_dir;
  Directory.c64_tap:=fich_ini.readString('dir','c64_tap',directory.Base+'c64'+main_vars.cadena_dir)+main_vars.cadena_dir;
  Directory.c64_disk:=fich_ini.readString('dir','c64_disk',directory.Base+'c64'+main_vars.cadena_dir)+main_vars.cadena_dir;
  Directory.Preview:=fich_ini.readString('dir','dir_preview',directory.Base+'preview'+main_vars.cadena_dir)+main_vars.cadena_dir;
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
  var_spectrum.issue2:=(fich_ini.ReadInteger('spectrum','issue',0)=0);
  var_spectrum.tipo_joy:=fich_ini.ReadInteger('spectrum','joystick',0);
  borde.tipo:=fich_ini.ReadInteger('spectrum','border',0);
  mouse.tipo:=fich_ini.ReadInteger('spectrum','tipo_mouse',0);
  var_spectrum.audio_load:=(fich_ini.ReadInteger('spectrum','audioload',0)=1);
  var_spectrum.audio_128k:=fich_ini.ReadInteger('spectrum','audio_128k',0);
  var_spectrum.speaker_oversample:=(fich_ini.ReadInteger('spectrum','beeperoversample',0)=1);
  var_spectrum.turbo_sound:=(fich_ini.ReadInteger('spectrum','turbo_sound',0)=1);
  ulaplus.enabled:=(fich_ini.ReadInteger('spectrum','ulaplus',0)=1);
  //Configuracion CPC
  for f:=0 to 6 do cpc_rom[f].name:=fich_ini.readString('cpc','rom_dir_'+inttostr(f),'');
  cpc_ga.cpc_model:=fich_ini.ReadInteger('cpc','cpcmodel',0);
  cpc_ga.ram_exp:=fich_ini.ReadInteger('cpc','cpcramexp',0);
  cpc_crt.color_monitor:=fich_ini.ReadInteger('cpc','cpccolor',1)=1;
  cpc_crt.bright:=fich_ini.ReadInteger('cpc','cpcbright',1);
  //Configuracion SMS
  sms_model:=fich_ini.ReadInteger('sms','model',1);
  //Configuracion GB
  gb_palette:=fich_ini.ReadInteger('gb','palette',0);
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
  //Autofire
  timers.autofire_enabled[0]:=fich_ini.ReadInteger('keyboard','autofire_p1_but0',0)<>0;
  timers.autofire_enabled[1]:=fich_ini.ReadInteger('keyboard','autofire_p1_but1',0)<>0;
  timers.autofire_enabled[2]:=fich_ini.ReadInteger('keyboard','autofire_p1_but2',0)<>0;
  timers.autofire_enabled[3]:=fich_ini.ReadInteger('keyboard','autofire_p1_but3',0)<>0;
  timers.autofire_enabled[4]:=fich_ini.ReadInteger('keyboard','autofire_p1_but4',0)<>0;
  timers.autofire_enabled[5]:=fich_ini.ReadInteger('keyboard','autofire_p1_but5',0)<>0;
  timers.autofire_enabled[6]:=fich_ini.ReadInteger('keyboard','autofire_p2_but0',0)<>0;
  timers.autofire_enabled[7]:=fich_ini.ReadInteger('keyboard','autofire_p2_but1',0)<>0;
  timers.autofire_enabled[8]:=fich_ini.ReadInteger('keyboard','autofire_p2_but2',0)<>0;
  timers.autofire_enabled[9]:=fich_ini.ReadInteger('keyboard','autofire_p2_but3',0)<>0;
  timers.autofire_enabled[10]:=fich_ini.ReadInteger('keyboard','autofire_p2_but4',0)<>0;
  timers.autofire_enabled[11]:=fich_ini.ReadInteger('keyboard','autofire_p2_but5',0)<>0;
  timers.autofire_on:=fich_ini.ReadInteger('keyboard','autofire_general',0)<>0;
  //tipo y numero joystick
  arcade_input.use_key[0]:=fich_ini.ReadInteger('keyboard','use_keyb_0',0)=0;
  arcade_input.use_key[1]:=fich_ini.ReadInteger('keyboard','use_keyb_1',0)=0;
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
  Directory.Coleco_snap:=directory.Base+'coleco'+main_vars.cadena_dir;
  Directory.sms:=directory.base+'sms'+main_vars.cadena_dir;
  Directory.sg1000:=directory.base+'sg1000'+main_vars.cadena_dir;
  Directory.gg:=directory.base+'gg'+main_vars.cadena_dir;
  Directory.scv:=directory.base+'scv'+main_vars.cadena_dir;
  Directory.qsnapshot:=directory.base+'qsnap'+main_vars.cadena_dir;
  Directory.spectrum_image:=directory.base+'gif'+main_vars.cadena_dir;
  Directory.arcade_list_roms[0]:=directory.base+'roms'+main_vars.cadena_dir;
  Directory.Arcade_hi:=directory.base+'hi'+main_vars.cadena_dir;
  Directory.Arcade_nvram:=directory.base+'nvram'+main_vars.cadena_dir;
  Directory.Arcade_samples:=directory.base+'samples'+main_vars.cadena_dir;
  Directory.Preview:=directory.base+'preview'+main_vars.cadena_dir;
  Directory.spectrum_tap_snap:=directory.base+'save'+main_vars.cadena_dir;
  Directory.spectrum_disk:=directory.base+'dsk'+main_vars.cadena_dir;
  Directory.spectrum_48:=directory.base+'roms'+main_vars.cadena_dir+'spectrum.zip';
  Directory.spectrum_128:=directory.base+'roms'+main_vars.cadena_dir+'spec128.zip';
  Directory.spectrum_3:=directory.base+'roms'+main_vars.cadena_dir+'plus3.zip';
  Directory.amstrad_tap:=directory.base+'cdt'+main_vars.cadena_dir;
  Directory.amstrad_disk:=directory.base+'dsk'+main_vars.cadena_dir;
  Directory.amstrad_snap:=directory.base+'snap'+main_vars.cadena_dir;
  Directory.amstrad_rom:=directory.base+'snap'+main_vars.cadena_dir;
  Directory.c64_tap:=directory.base+'c64'+main_vars.cadena_dir;
  Directory.c64_disk:=directory.base+'c64'+main_vars.cadena_dir;
  main_vars.idioma:=1;
  main_screen.video_mode:=1;
  sound_status.calidad_audio:=1;
  main_screen.pantalla_completa:=false;
  main_vars.show_crc_error:=true;
  main_vars.center_screen:=true;
  main_vars.x11:=false;
  //configuracion basica spectrum
  var_spectrum.audio_128k:=0;
  var_spectrum.audio_load:=true;
  var_spectrum.issue2:=true;
  var_spectrum.tipo_joy:=JKEMPSTON;
  borde.tipo:=1;
  mouse.tipo:=0;
  ulaplus.enabled:=true;
  var_spectrum.speaker_oversample:=false;
  var_spectrum.turbo_sound:=false;
  //Configuracion CPC
  for f:=0 to 6 do cpc_rom[f].name:='';
  cpc_ga.cpc_model:=0;
  cpc_ga.ram_exp:=0;
  cpc_crt.color_monitor:=true;
  cpc_crt.bright:=1;
  //Configuracion basica SMS
  sms_model:=0;
  //Config GB
  gb_palette:=0;
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
  timers.autofire_enabled[0]:=false;
  timers.autofire_enabled[1]:=false;
  timers.autofire_enabled[2]:=false;
  timers.autofire_enabled[3]:=false;
  timers.autofire_enabled[4]:=false;
  timers.autofire_enabled[5]:=false;
  timers.autofire_enabled[6]:=false;
  timers.autofire_enabled[7]:=false;
  timers.autofire_enabled[8]:=false;
  timers.autofire_enabled[9]:=false;
  timers.autofire_enabled[10]:=false;
  timers.autofire_enabled[11]:=false;
  timers.autofire_on:=false;
  //Joystick calibration
  for f:=0 to NUM_PLAYERS do begin
    arcade_input.joy_left[f]:=0;
    arcade_input.joy_right[f]:=0;
    arcade_input.joy_up[f]:=0;
    arcade_input.joy_down[f]:=0;
  end;
end;
if ((directory.Nes='') or (directory.Nes=main_vars.cadena_dir)) then Directory.Nes:=directory.base+'nes'+main_vars.cadena_dir;
if ((Directory.GameBoy='') or (directory.GameBoy=main_vars.cadena_dir)) then Directory.GameBoy:=directory.base+'gameboy'+main_vars.cadena_dir;
if ((Directory.Chip8='') or (directory.Chip8=main_vars.cadena_dir)) then Directory.Chip8:=directory.base+'chip8'+main_vars.cadena_dir;
if ((Directory.sms='') or (directory.sms=main_vars.cadena_dir)) then Directory.sms:=directory.base+'sms'+main_vars.cadena_dir;
if ((Directory.sg1000='') or (directory.sg1000=main_vars.cadena_dir)) then Directory.sg1000:=directory.base+'sg1000'+main_vars.cadena_dir;
if ((Directory.gg='') or (directory.gg=main_vars.cadena_dir)) then Directory.gg:=directory.base+'gg'+main_vars.cadena_dir;
if ((Directory.scv='') or (directory.scv=main_vars.cadena_dir)) then Directory.scv:=directory.base+'scv'+main_vars.cadena_dir;
if ((Directory.coleco_snap='') or (directory.coleco_snap=main_vars.cadena_dir)) then Directory.coleco_snap:=directory.base+'coleco'+main_vars.cadena_dir;
if ((Directory.spectrum_image='') or (directory.spectrum_image=main_vars.cadena_dir)) then Directory.spectrum_image:=directory.base+'gif'+main_vars.cadena_dir;
if ((Directory.qsnapshot='') or (directory.qsnapshot=main_vars.cadena_dir)) then Directory.qsnapshot:=directory.base+'qsnap'+main_vars.cadena_dir;
if ((Directory.spectrum_48='') or (directory.spectrum_48=main_vars.cadena_dir)) then Directory.spectrum_48:=directory.base+'roms'+main_vars.cadena_dir+'spectrum.zip';
if ((Directory.spectrum_128='') or (directory.spectrum_128=main_vars.cadena_dir)) then Directory.spectrum_128:=directory.base+'roms'+main_vars.cadena_dir+'spec128.zip';
if ((Directory.spectrum_3='') or (directory.spectrum_3=main_vars.cadena_dir)) then Directory.spectrum_3:=directory.base+'roms'+main_vars.cadena_dir+'plus3.zip';
if ((Directory.arcade_list_roms[0]='') or (Directory.arcade_list_roms[0]=main_vars.cadena_dir)) then Directory.arcade_list_roms[0]:=directory.base+'roms'+main_vars.cadena_dir;
if ((directory.Arcade_hi='') or (directory.Arcade_hi=main_vars.cadena_dir)) then directory.Arcade_hi:=directory.base+'hi'+main_vars.cadena_dir;
if ((directory.Arcade_nvram='') or (directory.Arcade_nvram=main_vars.cadena_dir)) then directory.Arcade_nvram:=directory.base+'nvram'+main_vars.cadena_dir;
if ((directory.Arcade_samples='') or (directory.Arcade_samples=main_vars.cadena_dir)) then directory.Arcade_samples:=directory.base+'samples'+main_vars.cadena_dir;
if ((Directory.Preview='') or (directory.Preview=main_vars.cadena_dir)) then Directory.Preview:=directory.base+'preview'+main_vars.cadena_dir;
if ((Directory.spectrum_tap_snap='') or (directory.spectrum_tap_snap=main_vars.cadena_dir)) then directory.spectrum_tap_snap:=directory.base+'snap'+main_vars.cadena_dir;
if ((Directory.spectrum_disk='') or (directory.spectrum_disk=main_vars.cadena_dir)) then Directory.spectrum_disk:=directory.base+'dsk'+main_vars.cadena_dir;
if ((Directory.amstrad_tap='') or (directory.amstrad_tap=main_vars.cadena_dir)) then Directory.amstrad_tap:=directory.base+'cdt'+main_vars.cadena_dir;
if ((Directory.amstrad_disk='') or (directory.amstrad_disk=main_vars.cadena_dir)) then Directory.amstrad_disk:=directory.base+'dsk'+main_vars.cadena_dir;
if ((Directory.amstrad_snap='') or (directory.amstrad_snap=main_vars.cadena_dir)) then Directory.amstrad_snap:=directory.base+'snap'+main_vars.cadena_dir;
if ((Directory.amstrad_rom='') or( directory.amstrad_rom=main_vars.cadena_dir)) then Directory.amstrad_rom:=directory.base+'snap'+main_vars.cadena_dir;
if ((Directory.c64_tap='') or( directory.c64_tap=main_vars.cadena_dir)) then Directory.c64_tap:=directory.base+'c64'+main_vars.cadena_dir;
if ((Directory.c64_disk='') or( directory.c64_disk=main_vars.cadena_dir)) then Directory.c64_disk:=directory.base+'c64'+main_vars.cadena_dir;
end;

function test_dir(cadena:string):string;
var
   f:word;
begin
    for f:=length(cadena) downto 1 do
       if cadena[f]<>main_vars.cadena_dir then break;
    test_dir:=system.copy(cadena,1,f);
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
fich_ini.Writestring('dir','arcade',get_all_dirs);
fich_ini.Writestring('dir','dir_hi',test_dir(Directory.Arcade_hi));
fich_ini.Writestring('dir','dir_nvram',test_dir(Directory.Arcade_nvram));
fich_ini.Writestring('dir','dir_samples',test_dir(Directory.Arcade_samples));
fich_ini.Writestring('dir','nes',test_dir(Directory.Nes));
fich_ini.Writestring('dir','chip8',test_dir(Directory.Chip8));
fich_ini.Writestring('dir','sms',test_dir(Directory.sms));
fich_ini.Writestring('dir','sg1000',test_dir(Directory.sg1000));
fich_ini.Writestring('dir','gg',test_dir(Directory.gg));
fich_ini.Writestring('dir','scv',test_dir(Directory.scv));
fich_ini.Writestring('dir','qsnapshot',test_dir(Directory.qsnapshot));
fich_ini.Writestring('dir','GameBoy',test_dir(Directory.GameBoy));
fich_ini.Writestring('dir','ColecoSnap',test_dir(Directory.coleco_snap));
fich_ini.Writestring('dir','spectrum_rom_48',test_dir(Directory.spectrum_48));
fich_ini.Writestring('dir','spectrum_rom_128',test_dir(Directory.spectrum_128));
fich_ini.Writestring('dir','spectrum_rom_plus3',test_dir(Directory.spectrum_3));
fich_ini.Writestring('dir','dir_gif',test_dir(Directory.spectrum_image));
fich_ini.Writestring('dir','dir_preview',test_dir(Directory.Preview));
fich_ini.Writestring('dir','dir_save',test_dir(Directory.spectrum_tap_snap));
fich_ini.Writestring('dir','dir_dsk',test_dir(Directory.spectrum_disk));
fich_ini.Writestring('dir','ams_tap',test_dir(Directory.amstrad_tap));
fich_ini.Writestring('dir','ams_dsk',test_dir(Directory.amstrad_disk));
fich_ini.Writestring('dir','ams_snap',test_dir(Directory.amstrad_snap));
fich_ini.Writestring('dir','ams_rom',test_dir(Directory.amstrad_rom));
fich_ini.Writestring('dir','c64_tap',test_dir(Directory.c64_tap));
fich_ini.Writestring('dir','c64_disk',test_dir(Directory.c64_disk));
//Config general
fich_ini.WriteInteger('dsp','sonido',sound_status.calidad_audio);
fich_ini.WriteInteger('dsp','video',main_screen.video_mode);
fich_ini.WriteInteger('dsp','maquina',main_vars.tipo_maquina);
fich_ini.WriteInteger('dsp','auto_exec',byte(main_vars.auto_exec));
fich_ini.WriteInteger('dsp','show_crc_error',byte(main_vars.show_crc_error));
fich_ini.WriteInteger('dsp','center_screen',byte(main_vars.center_screen));
fich_ini.WriteInteger('dsp','x11',byte(main_vars.x11));
//Config Spectrum
fich_ini.WriteInteger('spectrum','issue',byte(var_spectrum.issue2));
fich_ini.WriteInteger('spectrum','joystick',var_spectrum.tipo_joy);
fich_ini.WriteInteger('spectrum','border',borde.tipo);
fich_ini.WriteInteger('spectrum','tipo_mouse',mouse.tipo);
fich_ini.WriteInteger('spectrum','audioload',byte(var_spectrum.audio_load));
fich_ini.WriteInteger('spectrum','beeperoversample',byte(var_spectrum.speaker_oversample));
fich_ini.WriteInteger('spectrum','turbo_sound',byte(var_spectrum.turbo_sound));
fich_ini.WriteInteger('spectrum','audio_128k',var_spectrum.audio_128k);
fich_ini.WriteInteger('spectrum','ulaplus',byte(ulaplus.enabled));
//Configuracion CPC
for f:=0 to 6 do fich_ini.WriteString('cpc','rom_dir_'+inttostr(f),cpc_rom[f].name);
fich_ini.WriteInteger('cpc','cpcmodel',cpc_ga.cpc_model);
fich_ini.WriteInteger('cpc','cpcramexp',cpc_ga.ram_exp);
fich_ini.WriteInteger('cpc','cpccolor',byte(cpc_crt.color_monitor));
fich_ini.WriteInteger('cpc','cpcbright',cpc_crt.bright);
//Config SMS
fich_ini.WriteInteger('sms','model',sms_model);
//Config GB
fich_ini.WriteInteger('gb','palette',gb_palette);
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
//Autofire
fich_ini.WriteInteger('keyboard','autofire_p1_but0',byte(timers.autofire_enabled[0]));
fich_ini.WriteInteger('keyboard','autofire_p1_but1',byte(timers.autofire_enabled[1]));
fich_ini.WriteInteger('keyboard','autofire_p1_but2',byte(timers.autofire_enabled[2]));
fich_ini.WriteInteger('keyboard','autofire_p1_but3',byte(timers.autofire_enabled[3]));
fich_ini.WriteInteger('keyboard','autofire_p1_but4',byte(timers.autofire_enabled[4]));
fich_ini.WriteInteger('keyboard','autofire_p1_but5',byte(timers.autofire_enabled[5]));
fich_ini.WriteInteger('keyboard','autofire_p2_but0',byte(timers.autofire_enabled[6]));
fich_ini.WriteInteger('keyboard','autofire_p2_but1',byte(timers.autofire_enabled[7]));
fich_ini.WriteInteger('keyboard','autofire_p2_but2',byte(timers.autofire_enabled[8]));
fich_ini.WriteInteger('keyboard','autofire_p2_but3',byte(timers.autofire_enabled[9]));
fich_ini.WriteInteger('keyboard','autofire_p2_but4',byte(timers.autofire_enabled[10]));
fich_ini.WriteInteger('keyboard','autofire_p2_but5',byte(timers.autofire_enabled[11]));
fich_ini.WriteInteger('keyboard','autofire_general',byte(timers.autofire_on));
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
    cadena2:=system.copy(cadena,f+1,length(cadena)-f);
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
  f:integer;
  extension,extension2:string;
  res:boolean;
{$ifndef fpc}
  ZipFile:TZipFile;
{$else}
  ZipFile:TUnZipper;
{$endif}
begin
res:=false;
//Si no existe el ZIP -> Error
if not(FileExists(nombre_zip)) then exit;
{$ifndef fpc}
  ZipFile:=TZipFile.Create;
  ZipFile.Open(nombre_zip,zmRead);
  for f:=0 to (ZipFile.FileCount-1) do begin
    nombre_file:=ZipFile.FileNames[f];
    longitud:=ZipFile.FileInfos[f].UncompressedSize;
    crc:=ZipFile.FileInfos[f].CRC32;
    zip_find_files_data.posicion_dentro_zip:=f;
    zip_find_files_data.nombre_zip:=nombre_zip;
    zip_find_files_data.file_mask:=file_mask;
    if file_mask[1]='*' then begin
       if file_mask='*.*' then begin
          res:=true;
          break;
       end;
       extension:=extension_fichero(nombre_file);
       extension2:=extension_fichero(file_mask);
       if extension=extension2 then begin
          res:=true;
          break;
       end;
    end else begin
      if lowercase(nombre_file)=lowercase(file_mask) then begin
          res:=true;
          break;
       end;
    end;
  end;
  ZipFile.Close;
  ZipFile.Free;
{$else}
  ZipFile:=TUnZipper.create;
  ZipFile.FileName:=nombre_zip;
  ZipFile.Examine;
  for f:=0 to (ZipFile.Entries.Count-1) do begin
    nombre_file:=ZipFile.Entries[f].ArchiveFileName;
    longitud:=ZipFile.Entries[f].Size;
    crc:=ZipFile.Entries[f].CRC32;
    zip_find_files_data.posicion_dentro_zip:=f;
    zip_find_files_data.nombre_zip:=nombre_zip;
    zip_find_files_data.file_mask:=file_mask;
    if file_mask[1]='*' then begin
       if file_mask='*.*' then begin
          res:=true;
          break;
       end;
       extension:=extension_fichero(nombre_file);
       extension2:=extension_fichero(file_mask);
       if extension=extension2 then begin
          res:=true;
          break;
       end;
    end else begin
      if lowercase(nombre_file)=lowercase(file_mask) then begin
          res:=true;
          break;
       end;
    end;
  end;
  ZipFile.Free;
{$endif}
search_file_from_zip:=res;
if (warning and not(res)) then MessageDlg(leng[main_vars.idioma].errores[0]+' "'+nombre_file+'" '+leng[main_vars.idioma].errores[1]+' '+nombre_zip, mtError,[mbOk], 0);
end;

function find_next_file_zip(var nombre_file:string;var longitud,crc:integer):boolean;
var
  f:integer;
  extension,extension2:string;
{$ifndef fpc}
  ZipFile:TZipFile;
{$else}
  ZipFile:TUnZipper;
{$endif}
begin
find_next_file_zip:=false;
{$ifndef fpc}
  ZipFile:=TZipFile.Create;
  ZipFile.Open(zip_find_files_data.nombre_zip,zmRead);
  for f:=(zip_find_files_data.posicion_dentro_zip+1) to (ZipFile.FileCount-1) do begin
    nombre_file:=ZipFile.FileNames[f];
    longitud:=ZipFile.FileInfos[f].UncompressedSize;
    crc:=ZipFile.FileInfos[f].CRC32;
    zip_find_files_data.posicion_dentro_zip:=f;
    if zip_find_files_data.file_mask[1]='*' then begin
       if zip_find_files_data.file_mask='*.*' then begin
          find_next_file_zip:=true;
          break;
       end;
       extension:=extension_fichero(nombre_file);
       extension2:=extension_fichero(zip_find_files_data.file_mask);
       if extension=extension2 then begin
          find_next_file_zip:=true;
          break;
       end;
    end else begin
      if lowercase(nombre_file)=lowercase(zip_find_files_data.file_mask) then begin
          find_next_file_zip:=true;
          break;
       end;
    end;
  end;
  ZipFile.Close;
  ZipFile.Free;
{$else}
  ZipFile:=TUnZipper.create;
  ZipFile.FileName:=zip_find_files_data.nombre_zip;
  ZipFile.Examine;
  for f:=(zip_find_files_data.posicion_dentro_zip+1) to (ZipFile.Entries.Count-1) do begin
    nombre_file:=ZipFile.Entries[f].ArchiveFileName;
    longitud:=ZipFile.Entries[f].Size;
    crc:=ZipFile.Entries[f].CRC32;
    zip_find_files_data.posicion_dentro_zip:=f;
    if zip_find_files_data.file_mask[1]='*' then begin
       if zip_find_files_data.file_mask='*.*' then begin
          find_next_file_zip:=true;
          break;
       end;
       extension:=extension_fichero(nombre_file);
       extension2:=extension_fichero(zip_find_files_data.file_mask);
       if extension=extension2 then begin
          find_next_file_zip:=true;
          break;
       end;
    end else begin
      if lowercase(nombre_file)=lowercase(zip_find_files_data.file_mask) then begin
          find_next_file_zip:=true;
          break;
       end;
    end;
  end;
  ZipFile.Free;
{$endif}
end;

function load_file_from_zip(nombre_zip,nombre_file:string;donde:pbyte;var longitud,crc:integer;warning:boolean):boolean;
var
  f:word;
  find:boolean;
{$ifndef fpc}
  ZipFile:TZipFile;
  buffer:Tbytes;
{$else}
  ZipFile:TUnZipper;
  zfile:unzFile;
{$endif}
begin
  load_file_from_zip:=false;
  //Si no existe el ZIP -> Error
  if not(FileExists(nombre_zip)) then exit;
  find:=false;
{$ifndef fpc}
  ZipFile:=TZipFile.Create;
  if not(Zipfile.IsValid(nombre_zip)) then exit;
  ZipFile.Open(nombre_zip,zmRead);
  for f:=0 to (ZipFile.FileCount-1) do begin
    if lowercase(ZipFile.FileNames[f])=lowercase(nombre_file) then begin
      find:=true;
      break;
    end;
  end;
  if not(find) then begin
    ZipFile.Close;
    ZipFile.Free;
    if warning then MessageDlg(leng[main_vars.idioma].errores[0]+' "'+nombre_file+'" '+leng[main_vars.idioma].errores[1]+' '+nombre_zip, mtError,[mbOk], 0);
    exit;
  end;
  longitud:=ZipFile.FileInfos[f].UncompressedSize;
  SetLength(buffer,longitud);
  ZipFile.Read(f,buffer);
  copymemory(donde,@buffer[0],longitud);
  SetLength(buffer,0);
  ZipFile.Close;
  ZipFile.Free;
{$else}
  ZipFile:=TUnZipper.create;
  ZipFile.FileName:=nombre_zip;
  ZipFile.Examine;
  for f:=0 to (ZipFile.Entries.Count-1) do begin
    if lowercase(ZipFile.Entries[f].ArchiveFileName)=lowercase(nombre_file) then begin
      find:=true;
      break;
    end;
  end;
  if not(find) then begin
    ZipFile.Free;
    if warning then MessageDlg(leng[main_vars.idioma].errores[0]+' "'+nombre_file+'" '+leng[main_vars.idioma].errores[1]+' '+nombre_zip, mtError,[mbOk], 0);
    exit;
  end;
  zfile:=unzOpen(pchar(nombre_zip));
  longitud:=ZipFile.Entries[f].Size;
  unzLocateFile(zfile,pchar(ZipFile.Entries[f].ArchiveFileName),0);
  unzOpenCurrentFile(zfile);
  unzReadCurrentFile(zfile,pointer(donde),longitud);
  unzClose(zfile);
  ZipFile.Free;
{$endif}
load_file_from_zip:=true;
end;

function load_file_from_zip_crc(nombre_zip:string;donde:pbyte;var longitud:integer;crc:integer):boolean;
var
  f:word;
  find:boolean;
{$ifndef fpc}
  ZipFile:TZipFile;
  buffer:Tbytes;
{$else}
  ZipFile:TUnZipper;
  zfile:unzFile;
{$endif}
begin
  load_file_from_zip_crc:=false;
  //Si no existe el ZIP -> Error
  if not(FileExists(nombre_zip)) then begin
    MessageDlg(leng[main_vars.idioma].errores[2]+' "'+extractfilename(nombre_zip)+'" ', mtError,[mbOk], 0);
    exit;
  end;
  find:=false;
{$ifndef fpc}
  ZipFile:=TZipFile.Create;
  ZipFile.Open(nombre_zip,zmRead);
  for f:=0 to (ZipFile.FileCount-1) do begin
    if ZipFile.FileInfos[f].CRC32=cardinal(crc) then begin
      find:=true;
      break;
    end;
  end;
  if not(find) then begin
    ZipFile.Close;
    ZipFile.Free;
    exit;
  end;
  longitud:=ZipFile.FileInfos[f].UncompressedSize;
  SetLength(buffer,longitud);
  ZipFile.Read(f,buffer);
  copymemory(donde,@buffer[0],longitud);
  SetLength(buffer,0);
  ZipFile.Close;
  ZipFile.Free;
{$else}
  ZipFile:=TUnZipper.create;
  ZipFile.FileName:=nombre_zip;
  ZipFile.Examine;
  for f:=0 to (ZipFile.Entries.Count-1) do begin
    if ZipFile.Entries[f].CRC32=cardinal(crc) then begin
      find:=true;
      break;
    end;
  end;
  if not(find) then begin
    ZipFile.Free;
    exit;
  end;
  zfile:=unzOpen(pchar(nombre_zip));
  longitud:=ZipFile.Entries[f].Size;
  unzLocateFile(zfile,pchar(ZipFile.Entries[f].ArchiveFileName),0);
  unzOpenCurrentFile(zfile);
  unzReadCurrentFile(zfile,pointer(donde),longitud);
  unzClose(zfile);
  ZipFile.Free;
{$endif}
  load_file_from_zip_crc:=true;
end;

//Funciones de zlib
procedure compress_zlib(in_buffer:pointer;in_size:integer;out_buffer:pointer;var out_size:integer);
var
  buffer:pointer;
  {$ifdef fpc}stream:z_stream;{$endif}
begin
{$ifndef fpc}
  buffer:=nil;
  ZCompress(pointer(in_buffer),in_size,buffer,out_size,zcDefault);
{$else}
  getmem(buffer,$100000);
  stream.next_in:=pbyte(in_buffer);
  stream.avail_in:=cardinal(in_size);
  stream.next_out:=buffer;
  stream.avail_out:=$100000;
  deflateInit(stream,Z_BEST_COMPRESSION);
  deflate(stream,Z_FINISH);
  deflateEnd(stream);
  out_size:=stream.total_out;
{$endif}
  copymemory(out_buffer,buffer,out_size);
  freemem(buffer);
end;

procedure decompress_zlib(in_buffer:pointer;in_size:integer;var out_buffer:pointer;var out_size:integer);
var
  buffer:pointer;
  {$ifdef fpc}stream:z_stream;{$endif}
begin
{$ifndef fpc}
  buffer:=nil;
  ZDecompress(pointer(in_buffer),in_size,buffer,out_size);
{$else}
  getmem(buffer,$100000);
  stream.next_in:=Pbyte(in_buffer);
  stream.avail_in:=cardinal(in_size);
  stream.next_out:=buffer;
  stream.avail_out:=$100000;
  inflateInit(stream);
  inflate(stream,Z_FINISH);
  inflateEnd(stream);
  out_size:=stream.total_out;
{$endif}
  if out_buffer=nil then getmem(out_buffer,out_size);
  copymemory(out_buffer,buffer,out_size);
  freemem(buffer);
end;

end.
