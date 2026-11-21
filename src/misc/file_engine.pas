unit file_engine;

interface
uses {$ifdef fpc}
     zipper,zdeflate,zinflate,zbase,ziputils,unzip,
     {$else}
     Zlib,zip,
     {$endif}
     sysutils,dialogs,lenguaje,sound_engine,inifiles,main_engine,
     controls_engine,misc_functions,timer_engine,configgeneral_misc;

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
function file_ini_load_dip(var number:word):boolean;
procedure file_ini_save_dip;
//Ficheros normales
function read_file_size(nombre_file:string;var longitud:integer):boolean;
function read_file(nombre_file:string;donde:pbyte;var longitud:integer):boolean;
function write_file(nombre_file:string;donde:pbyte;longitud:integer):boolean;
function file_name_only(cadena:string):string;
//Parte ZIP
function search_file_from_zip(nombre_zip,file_mask:string;var nombre_file:string;var longitud:integer;crc:dword;warning:boolean):boolean;
function find_next_file_zip(var nombre_file:string;var longitud:integer;crc:dword):boolean;
function load_file_from_zip(nombre_zip,nombre_file:string;donde:pbyte;var longitud:integer;var crc:dword;warning:boolean=true):boolean;
function load_file_from_zip_crc(nombre_zip:string;donde:pbyte;var longitud:integer;crc:dword;warning:boolean=true):boolean;
//Parte ZLIB
procedure compress_zlib(in_buffer:pointer;in_size:integer;out_buffer:pointer;var out_size:integer);
procedure decompress_zlib(in_buffer:pointer;in_size:integer;var out_buffer:pointer;var out_size:integer);

var
  zip_find_files_data:tzip_find_files;

implementation
uses spectrum_misc,principal,amstrad_cpc,sms,gb,init_games;

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
function file_ini_load_dip(var number:word):boolean;
var
  fich_ini:Tinifile;
  f:word;
  res,nombre:string;
  ires:integer;
begin
res:='-1';
if fileexists(directory.Base+'dsp_dipsw.ini') then begin
  fich_ini:=Tinifile.Create(directory.Base+'dsp_dipsw.ini');
  for f:=1 to GAMES_CONT do begin
    if GAMES_DESC[f].grid=main_vars.tipo_maquina then begin
      nombre:=GAMES_DESC[f].zip;
      break;
    end;
  end;
  case number of
    1:res:=fich_ini.readString(nombre,'dip1','-1');
    2:res:=fich_ini.readString(nombre,'dip2','-1');
    3:res:=fich_ini.readString(nombre,'dip3','-1');
  end;
  fich_ini.free;
end;
ires:=strtoint(res);
if (ires<>-1) then begin
  file_ini_load_dip:=true;
  number:=ires;
end else file_ini_load_dip:=false;
end;

procedure file_ini_save_dip;
var
  fich_ini:Tinifile;
  f:word;
  nombre:string;
begin
fich_ini:=Tinifile.Create(directory.base+'dsp_dipsw.ini');
if @fich_ini=nil then begin
  MessageDlg('Error writing INI file!', mtError,[mbOk], 0);
  exit;
end;
for f:=1 to GAMES_CONT do begin
  if GAMES_DESC[f].grid=main_vars.tipo_maquina then begin
    nombre:=GAMES_DESC[f].zip;
    break;
  end;
end;
fich_ini.WriteInteger(nombre,'dip1',marcade.dswa);
fich_ini.WriteInteger(nombre,'dip2',marcade.dswb);
fich_ini.WriteInteger(nombre,'dip3',marcade.dswc);
fich_ini.free;
end;

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
  Directory.coleco:=fich_ini.readString('Dir','ColecoSnap',directory.Base+'coleco'+main_vars.cadena_dir)+main_vars.cadena_dir;
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
  Directory.oric_tap:=fich_ini.readString('dir','oric_tap',directory.Base+'oric'+main_vars.cadena_dir)+main_vars.cadena_dir;
  Directory.msx_tap:=fich_ini.readString('dir','msx_tap',directory.Base+'msx'+main_vars.cadena_dir)+main_vars.cadena_dir;
  Directory.pv1000:=fich_ini.readString('dir','pv1000',directory.Base+'pv1000'+main_vars.cadena_dir)+main_vars.cadena_dir;
  Directory.pv2000:=fich_ini.readString('dir','pv2000',directory.Base+'pv2000'+main_vars.cadena_dir)+main_vars.cadena_dir;
  Directory.atari2600:=fich_ini.readString('dir','atari2600',directory.Base+'atari2600'+main_vars.cadena_dir)+main_vars.cadena_dir;
  Directory.atari5200:=fich_ini.readString('dir','atari5200',directory.Base+'atari5200'+main_vars.cadena_dir)+main_vars.cadena_dir;
  Directory.atari7800:=fich_ini.readString('dir','atari7800',directory.Base+'atari7800'+main_vars.cadena_dir)+main_vars.cadena_dir;
  Directory.genesis:=fich_ini.readString('dir','genesis',directory.Base+'genesis'+main_vars.cadena_dir)+main_vars.cadena_dir;
  Directory.pcengine:=fich_ini.readString('dir','pcengine',directory.Base+'pcengine'+main_vars.cadena_dir)+main_vars.cadena_dir;
  Directory.Preview:=fich_ini.readString('dir','dir_preview',directory.Base+'preview'+main_vars.cadena_dir)+main_vars.cadena_dir;
  main_vars.idioma:=fich_ini.ReadInteger('dsp','idioma',1);
  if ((main_vars.idioma>max_idiomas) and (main_vars.idioma<>200)) then main_vars.idioma:=1;
  sound_status.sonido_activo:=fich_ini.ReadInteger('dsp','sonido_ena',1)=1;
  if sound_status.sonido_activo then principal1.consonido1.checked:=true
    else principal1.SinSonido1.Checked:=true;
  main_screen.video_mode:=fich_ini.ReadInteger('dsp','video',1);
  if ((main_screen.video_mode<1) or (main_screen.video_mode>6)) then main_screen.video_mode:=1;
  main_screen.pantalla_completa:=false;
  main_vars.tipo_maquina:=fich_ini.ReadInteger('dsp','maquina',0);
  main_vars.auto_exec:=(fich_ini.ReadInteger('dsp','auto_exec',0)=1);
  main_vars.show_crc_error:=(fich_ini.ReadInteger('dsp','show_crc_error',1)=1);
  main_vars.center_screen:=(fich_ini.ReadInteger('dsp','center_screen',1)=1);
  main_vars.console_init:=(fich_ini.ReadInteger('dsp','console_init',0)=1);
  main_vars.sort:=fich_ini.ReadInteger('dsp','sort',0);
  main_vars.auto_type:=(fich_ini.ReadInteger('dsp','auto_type',1)=1);
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
  for f:=0 to 15 do cpc_rom[f].name:=fich_ini.readString('cpc','rom_dir_'+inttostr(f),'');
  cpc_ga.cpc_model:=fich_ini.ReadInteger('cpc','cpcmodel',0);
  cpc_ga.ram_exp:=fich_ini.ReadInteger('cpc','cpcramexp',0);
  cpc_crt.color_monitor:=fich_ini.ReadInteger('cpc','cpccolor',1)=1;
  cpc_crt.bright:=fich_ini.ReadInteger('cpc','cpcbright',1);
  //Configuracion SMS
  sms_0.model:=fich_ini.ReadInteger('sms','model',1);
  //Configuracion GB
  gb_0.palette:=fich_ini.ReadInteger('gb','palette',0);
  //Teclas
  arcade_input.ndef[0]:=fich_ini.ReadInteger('keyboard','ndef_0',0);
  arcade_input.ndef[1]:=fich_ini.ReadInteger('keyboard','ndef_1',1);
  arcade_input.ndef[2]:=fich_ini.ReadInteger('keyboard','ndef_2',2);
  //arcade_input.ndef[3]:=fich_ini.ReadInteger('keyboard','ndef_3',3);
  defkeys[0].up:=fich_ini.ReadInteger('keyboard_def','up_0',KEYBOARD_UP);
  defkeys[0].down:=fich_ini.ReadInteger('keyboard_def','down_0',KEYBOARD_DOWN);
  defkeys[0].left:=fich_ini.ReadInteger('keyboard_def','left_0',KEYBOARD_LEFT);
  defkeys[0].right:=fich_ini.ReadInteger('keyboard_def','right_0',KEYBOARD_RIGHT);
  defkeys[0].but0:=fich_ini.ReadInteger('keyboard_def','but0_0',KEYBOARD_LALT);
  defkeys[0].but1:=fich_ini.ReadInteger('keyboard_def','but1_0',KEYBOARD_LCTRL);
  defkeys[0].but2:=fich_ini.ReadInteger('keyboard_def','but2_0',KEYBOARD_LSHIFT);
  defkeys[0].but3:=fich_ini.ReadInteger('keyboard_def','but3_0',KEYBOARD_A);
  defkeys[0].but4:=fich_ini.ReadInteger('keyboard_def','but4_0',KEYBOARD_S);
  defkeys[0].but5:=fich_ini.ReadInteger('keyboard_def','but5_0',KEYBOARD_D);
  defkeys[0].coin:=fich_ini.ReadInteger('keyboard_def','coin_0',KEYBOARD_5);
  defkeys[0].start:=fich_ini.ReadInteger('keyboard_def','start_0',KEYBOARD_1);
  defkeys[1].coin:=fich_ini.ReadInteger('keyboard_def','coin_1',KEYBOARD_6);
  defkeys[1].start:=fich_ini.ReadInteger('keyboard_def','start_1',KEYBOARD_2);
  defkeys[1].up:=fich_ini.ReadInteger('keyboard_def','up_1',KEYBOARD_Q);
  defkeys[1].down:=fich_ini.ReadInteger('keyboard_def','down_1',KEYBOARD_A);
  defkeys[1].left:=fich_ini.ReadInteger('keyboard_def','left_1',KEYBOARD_O);
  defkeys[1].right:=fich_ini.ReadInteger('keyboard_def','right_1',KEYBOARD_P);
  defkeys[1].but0:=fich_ini.ReadInteger('keyboard_def','but0_1',KEYBOARD_N);
  defkeys[1].but1:=fich_ini.ReadInteger('keyboard_def','but1_1',KEYBOARD_M);
  defkeys[1].but2:=fich_ini.ReadInteger('keyboard_def','but2_1',KEYBOARD_B);
  defkeys[1].but3:=fich_ini.ReadInteger('keyboard_def','but3_1',KEYBOARD_V);
  defkeys[1].but4:=fich_ini.ReadInteger('keyboard_def','but4_1',KEYBOARD_C);
  defkeys[1].but5:=fich_ini.ReadInteger('keyboard_def','but5_1',KEYBOARD_X);
  for f:=2 to NUM_CONTROLS do begin
    defkeys[f].up:=fich_ini.ReadInteger('keyboard_def','up_'+inttostr(f),KEYBOARD_NONE);
    defkeys[f].down:=fich_ini.ReadInteger('keyboard_def','down_'+inttostr(f),KEYBOARD_NONE);
    defkeys[f].left:=fich_ini.ReadInteger('keyboard_def','left_'+inttostr(f),KEYBOARD_NONE);
    defkeys[f].right:=fich_ini.ReadInteger('keyboard_def','right_'+inttostr(f),KEYBOARD_NONE);
    defkeys[f].but0:=fich_ini.ReadInteger('keyboard_def','but0_'+inttostr(f),KEYBOARD_NONE);
    defkeys[f].but1:=fich_ini.ReadInteger('keyboard_def','but1_'+inttostr(f),KEYBOARD_NONE);
    defkeys[f].but2:=fich_ini.ReadInteger('keyboard_def','but2_'+inttostr(f),KEYBOARD_NONE);
    defkeys[f].but3:=fich_ini.ReadInteger('keyboard_def','but3_'+inttostr(f),KEYBOARD_NONE);
    defkeys[f].but4:=fich_ini.ReadInteger('keyboard_def','but4_'+inttostr(f),KEYBOARD_NONE);
    defkeys[f].but5:=fich_ini.ReadInteger('keyboard_def','but5_'+inttostr(f),KEYBOARD_NONE);
    defkeys[f].coin:=fich_ini.ReadInteger('keyboard_def','coin_'+inttostr(f),KEYBOARD_NONE);
    defkeys[f].start:=fich_ini.ReadInteger('keyboard_def','start_'+inttostr(f),KEYBOARD_NONE);
  end;
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
  arcade_input.use_key[0]:=fich_ini.ReadInteger('keyboard','use_keyb_0',0)<>0;
  arcade_input.use_key[1]:=fich_ini.ReadInteger('keyboard','use_keyb_1',0)<>0;
  arcade_input.use_key[2]:=fich_ini.ReadInteger('keyboard','use_keyb_2',0)<>0;
  //arcade_input.use_key[3]:=fich_ini.ReadInteger('keyboard','use_keyb_3',0)<>0;
  arcade_input.num_joystick[0]:=fich_ini.ReadInteger('keyboard','num_joy_0',0);
  arcade_input.num_joystick[1]:=fich_ini.ReadInteger('keyboard','num_joy_1',0);
  arcade_input.num_joystick[2]:=fich_ini.ReadInteger('keyboard','num_joy_2',0);
  //arcade_input.num_joystick[3]:=fich_ini.ReadInteger('keyboard','num_joy_3',0);
  //Joystick calibration
  for f:=0 to NUM_PLAYERS do begin
    arcade_input.joy_x[f]:=fich_ini.ReadInteger('keyboard','joy_left_'+inttostr(f),0);
    arcade_input.joy_y[f]:=fich_ini.ReadInteger('keyboard','joy_up_'+inttostr(f),0);
  end;
  //Cerrar fichero
  fich_ini.free;
end else begin
  Directory.Nes:=directory.base+'nes'+main_vars.cadena_dir;
  Directory.GameBoy:=directory.base+'gameboy'+main_vars.cadena_dir;
  Directory.Chip8:=directory.base+'chip8'+main_vars.cadena_dir;
  Directory.coleco:=directory.Base+'coleco'+main_vars.cadena_dir;
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
  Directory.oric_tap:=directory.base+'oric'+main_vars.cadena_dir;
  Directory.msx_tap:=directory.base+'msx'+main_vars.cadena_dir;
  Directory.pv1000:=directory.base+'pv1000'+main_vars.cadena_dir;
  Directory.pv2000:=directory.base+'pv2000'+main_vars.cadena_dir;
  Directory.atari2600:=directory.base+'atari2600'+main_vars.cadena_dir;
  Directory.atari5200:=directory.base+'atari5200'+main_vars.cadena_dir;
  Directory.atari7800:=directory.base+'atari7800'+main_vars.cadena_dir;
  Directory.genesis:=directory.base+'genesis'+main_vars.cadena_dir;
  Directory.pcengine:=directory.base+'pcengine'+main_vars.cadena_dir;
  main_vars.idioma:=1;
  main_screen.video_mode:=1;
  sound_status.sonido_activo:=true;
  main_screen.pantalla_completa:=false;
  main_vars.show_crc_error:=true;
  main_vars.center_screen:=true;
  main_vars.console_init:=true;
  main_vars.sort:=0;
  main_vars.auto_type:=true;
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
  for f:=0 to 15 do cpc_rom[f].name:='';
  cpc_ga.cpc_model:=0;
  cpc_ga.ram_exp:=0;
  cpc_crt.color_monitor:=true;
  cpc_crt.bright:=1;
  //Configuracion basica SMS
  sms_0.model:=0;
  //Config GB
  gb_0.palette:=0;
  //Teclas
  arcade_input.ndef[0]:=0;
  arcade_input.ndef[1]:=1;
  arcade_input.ndef[2]:=2;
  //arcade_input.ndef[3]:=3;
  defkeys[0].up:=KEYBOARD_UP;
  defkeys[0].down:=KEYBOARD_DOWN;
  defkeys[0].left:=KEYBOARD_LEFT;
  defkeys[0].right:=KEYBOARD_RIGHT;
  defkeys[0].but0:=KEYBOARD_LALT;
  defkeys[0].but1:=KEYBOARD_LCTRL;
  defkeys[0].but2:=KEYBOARD_LSHIFT;
  defkeys[0].but3:=KEYBOARD_A;
  defkeys[0].but4:=KEYBOARD_S;
  defkeys[0].but5:=KEYBOARD_D;
  defkeys[0].coin:=KEYBOARD_5;
  defkeys[0].start:=KEYBOARD_1;
  defkeys[1].coin:=KEYBOARD_6;
  defkeys[1].start:=KEYBOARD_2;
  defkeys[1].up:=KEYBOARD_Q;
  defkeys[1].down:=KEYBOARD_A;
  defkeys[1].left:=KEYBOARD_O;
  defkeys[1].right:=KEYBOARD_P;
  defkeys[1].but0:=KEYBOARD_N;
  defkeys[1].but1:=KEYBOARD_M;
  defkeys[1].but2:=KEYBOARD_B;
  defkeys[1].but3:=KEYBOARD_V;
  defkeys[1].but4:=KEYBOARD_C;
  defkeys[1].but5:=KEYBOARD_X;
  for f:=2 to NUM_CONTROLS do begin
    defkeys[f].start:=KEYBOARD_NONE;
    defkeys[f].up:=KEYBOARD_NONE;
    defkeys[f].down:=KEYBOARD_NONE;
    defkeys[f].left:=KEYBOARD_NONE;
    defkeys[f].right:=KEYBOARD_NONE;
    defkeys[f].but0:=KEYBOARD_NONE;
    defkeys[f].but1:=KEYBOARD_NONE;
    defkeys[f].but2:=KEYBOARD_NONE;
    defkeys[f].but3:=KEYBOARD_NONE;
    defkeys[f].but4:=KEYBOARD_NONE;
    defkeys[f].but5:=KEYBOARD_NONE;
  end;
  arcade_input.use_key[0]:=true;
  arcade_input.use_key[1]:=true;
  arcade_input.use_key[2]:=true;
  //arcade_input.use_key[3]:=true;
  arcade_input.num_joystick[0]:=255;
  arcade_input.num_joystick[1]:=255;
  arcade_input.num_joystick[2]:=255;
  //arcade_input.num_joystick[3]:=255;
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
    arcade_input.joy_x[f]:=0;
    arcade_input.joy_y[f]:=0;
  end;
end;
if ((directory.Nes='') or (directory.Nes=main_vars.cadena_dir)) then Directory.Nes:=directory.base+'nes'+main_vars.cadena_dir;
if ((Directory.GameBoy='') or (directory.GameBoy=main_vars.cadena_dir)) then Directory.GameBoy:=directory.base+'gameboy'+main_vars.cadena_dir;
if ((Directory.Chip8='') or (directory.Chip8=main_vars.cadena_dir)) then Directory.Chip8:=directory.base+'chip8'+main_vars.cadena_dir;
if ((Directory.sms='') or (directory.sms=main_vars.cadena_dir)) then Directory.sms:=directory.base+'sms'+main_vars.cadena_dir;
if ((Directory.sg1000='') or (directory.sg1000=main_vars.cadena_dir)) then Directory.sg1000:=directory.base+'sg1000'+main_vars.cadena_dir;
if ((Directory.gg='') or (directory.gg=main_vars.cadena_dir)) then Directory.gg:=directory.base+'gg'+main_vars.cadena_dir;
if ((Directory.scv='') or (directory.scv=main_vars.cadena_dir)) then Directory.scv:=directory.base+'scv'+main_vars.cadena_dir;
if ((Directory.coleco='') or (directory.coleco=main_vars.cadena_dir)) then Directory.coleco:=directory.base+'coleco'+main_vars.cadena_dir;
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
if ((Directory.amstrad_rom='') or (directory.amstrad_rom=main_vars.cadena_dir)) then Directory.amstrad_rom:=directory.base+'snap'+main_vars.cadena_dir;
if ((Directory.c64_tap='') or (directory.c64_tap=main_vars.cadena_dir)) then Directory.c64_tap:=directory.base+'c64'+main_vars.cadena_dir;
if ((Directory.c64_disk='') or (directory.c64_disk=main_vars.cadena_dir)) then Directory.c64_disk:=directory.base+'c64'+main_vars.cadena_dir;
if ((Directory.oric_tap='') or (directory.oric_tap=main_vars.cadena_dir)) then Directory.oric_tap:=directory.base+'oric'+main_vars.cadena_dir;
if ((Directory.msx_tap='') or (directory.msx_tap=main_vars.cadena_dir)) then Directory.msx_tap:=directory.base+'msx'+main_vars.cadena_dir;
if ((Directory.pv1000='') or (directory.pv1000=main_vars.cadena_dir)) then Directory.pv1000:=directory.base+'pv1000'+main_vars.cadena_dir;
if ((Directory.pv2000='') or (directory.pv2000=main_vars.cadena_dir)) then Directory.pv2000:=directory.base+'pv2000'+main_vars.cadena_dir;
if ((Directory.atari2600='') or (directory.atari2600=main_vars.cadena_dir)) then Directory.atari2600:=directory.base+'atari2600'+main_vars.cadena_dir;
if ((Directory.atari5200='') or (directory.atari5200=main_vars.cadena_dir)) then Directory.atari5200:=directory.base+'atari5200'+main_vars.cadena_dir;
if ((Directory.atari7800='') or (directory.atari7800=main_vars.cadena_dir)) then Directory.atari7800:=directory.base+'atari7800'+main_vars.cadena_dir;
if ((Directory.genesis='') or (directory.genesis=main_vars.cadena_dir)) then Directory.genesis:=directory.base+'genesis'+main_vars.cadena_dir;
if ((Directory.pcengine='') or (directory.pcengine=main_vars.cadena_dir)) then Directory.pcengine:=directory.base+'pcengine'+main_vars.cadena_dir;
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
fich_ini.Writestring('dir','ColecoSnap',test_dir(Directory.coleco));
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
fich_ini.Writestring('dir','oric_tap',test_dir(Directory.oric_tap));
fich_ini.Writestring('dir','msx_tap',test_dir(Directory.msx_tap));
fich_ini.Writestring('dir','pv1000',test_dir(Directory.pv1000));
fich_ini.Writestring('dir','pv2000',test_dir(Directory.pv2000));
fich_ini.Writestring('dir','atari2600',test_dir(Directory.atari2600));
fich_ini.Writestring('dir','atari5200',test_dir(Directory.atari5200));
fich_ini.Writestring('dir','atari7800',test_dir(Directory.atari7800));
fich_ini.Writestring('dir','genesis',test_dir(Directory.genesis));
fich_ini.Writestring('dir','pcengine',test_dir(Directory.pcengine));
//Config general
fich_ini.WriteInteger('dsp','sonido_ena',byte(sound_status.sonido_activo));
fich_ini.WriteInteger('dsp','video',main_screen.video_mode);
fich_ini.WriteInteger('dsp','maquina',main_vars.tipo_maquina);
fich_ini.WriteInteger('dsp','auto_exec',byte(main_vars.auto_exec));
fich_ini.WriteInteger('dsp','show_crc_error',byte(main_vars.show_crc_error));
fich_ini.WriteInteger('dsp','center_screen',byte(main_vars.center_screen));
fich_ini.WriteInteger('dsp','console_init',byte(main_vars.console_init));
fich_ini.WriteInteger('dsp','sort',main_vars.sort);
fich_ini.WriteInteger('dsp','auto_type',byte(main_vars.auto_type));
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
for f:=0 to 15 do fich_ini.WriteString('cpc','rom_dir_'+inttostr(f),cpc_rom[f].name);
fich_ini.WriteInteger('cpc','cpcmodel',cpc_ga.cpc_model);
fich_ini.WriteInteger('cpc','cpcramexp',cpc_ga.ram_exp);
fich_ini.WriteInteger('cpc','cpccolor',byte(cpc_crt.color_monitor));
fich_ini.WriteInteger('cpc','cpcbright',cpc_crt.bright);
//Config SMS
fich_ini.WriteInteger('sms','model',sms_0.model);
//Config GB
fich_ini.WriteInteger('gb','palette',gb_0.palette);
//Teclas P1
fich_ini.WriteInteger('keyboard','ndef_0',arcade_input.ndef[0]);
fich_ini.WriteInteger('keyboard','ndef_1',arcade_input.ndef[1]);
fich_ini.WriteInteger('keyboard','ndef_2',arcade_input.ndef[2]);
//fich_ini.WriteInteger('keyboard','ndef_3',arcade_input.ndef[3]);
for f:=0 to NUM_CONTROLS do begin
  fich_ini.WriteInteger('keyboard_def','up_'+inttostr(f),defkeys[f].up);
  fich_ini.WriteInteger('keyboard_def','down_'+inttostr(f),defkeys[f].down);
  fich_ini.WriteInteger('keyboard_def','left_'+inttostr(f),defkeys[f].left);
  fich_ini.WriteInteger('keyboard_def','right_'+inttostr(f),defkeys[f].right);
  fich_ini.WriteInteger('keyboard_def','but0_'+inttostr(f),defkeys[f].but0);
  fich_ini.WriteInteger('keyboard_def','but1_'+inttostr(f),defkeys[f].but1);
  fich_ini.WriteInteger('keyboard_def','but2_'+inttostr(f),defkeys[f].but2);
  fich_ini.WriteInteger('keyboard_def','but3_'+inttostr(f),defkeys[f].but3);
  fich_ini.WriteInteger('keyboard_def','but4_'+inttostr(f),defkeys[f].but4);
  fich_ini.WriteInteger('keyboard_def','but5_'+inttostr(f),defkeys[f].but5);
  fich_ini.WriteInteger('keyboard_def','coin_'+inttostr(f),defkeys[f].coin);
  fich_ini.WriteInteger('keyboard_def','start_'+inttostr(f),defkeys[f].start);
end;
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
fich_ini.WriteInteger('keyboard','use_keyb_0',byte(arcade_input.use_key[0]));
fich_ini.WriteInteger('keyboard','use_keyb_1',byte(arcade_input.use_key[1]));
fich_ini.WriteInteger('keyboard','use_keyb_2',byte(arcade_input.use_key[2]));
//fich_ini.WriteInteger('keyboard','use_keyb_3',byte(not(arcade_input.use_key[3])));
fich_ini.WriteInteger('keyboard','num_joy_0',arcade_input.num_joystick[0]);
fich_ini.WriteInteger('keyboard','num_joy_1',arcade_input.num_joystick[1]);
fich_ini.WriteInteger('keyboard','num_joy_2',arcade_input.num_joystick[2]);
//fich_ini.WriteInteger('keyboard','num_joy_3',arcade_input.num_joystick[3]);
//Joystick calibration
for f:=0 to NUM_PLAYERS do begin
  fich_ini.WriteInteger('keyboard','joy_up_'+inttostr(f),arcade_input.joy_y[f]);
  fich_ini.WriteInteger('keyboard','joy_left_'+inttostr(f),arcade_input.joy_x[f]);
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
function search_file_from_zip(nombre_zip,file_mask:string;var nombre_file:string;var longitud:integer;crc:dword;warning:boolean):boolean;
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
if (warning and not(res)) then begin
  MessageDlg(leng.errores[0]+' "'+nombre_file+'" '+leng.errores[1]+' '+nombre_zip, mtError,[mbOk], 0);
  //principal1.Enabled:=true;
end;
end;

function find_next_file_zip(var nombre_file:string;var longitud:integer;crc:dword):boolean;
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

function load_file_from_zip(nombre_zip,nombre_file:string;donde:pbyte;var longitud:integer;var crc:dword;warning:boolean=true):boolean;
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
    if warning then MessageDlg(leng.errores[0]+' "'+nombre_file+'" '+leng.errores[1]+' '+nombre_zip, mtError,[mbOk], 0);
    exit;
  end;
  longitud:=ZipFile.FileInfos[f].UncompressedSize;
  crc:=ZipFile.FileInfos[f].CRC32;
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
    if warning then begin
      MessageDlg(leng.errores[0]+' "'+nombre_file+'" '+leng.errores[1]+' '+nombre_zip, mtError,[mbOk], 0);
      //principal1.Enabled:=true;
    end;
    exit;
  end;
  zfile:=unzOpen(pchar(nombre_zip));
  longitud:=ZipFile.Entries[f].Size;
  crc:=ZipFile.Entries[f].CRC32;
  unzLocateFile(zfile,pchar(ZipFile.Entries[f].ArchiveFileName),0);
  unzOpenCurrentFile(zfile);
  unzReadCurrentFile(zfile,pointer(donde),longitud);
  unzClose(zfile);
  ZipFile.Free;
{$endif}
load_file_from_zip:=true;
end;

function load_file_from_zip_crc(nombre_zip:string;donde:pbyte;var longitud:integer;crc:dword;warning:boolean=true):boolean;
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
    if warning then MessageDlg(leng.errores[2]+' "'+extractfilename(nombre_zip)+'" ', mtError,[mbOk], 0);
    exit;
  end;
  find:=false;
{$ifndef fpc}
  ZipFile:=TZipFile.Create;
  ZipFile.Open(nombre_zip,zmRead);
  for f:=0 to (ZipFile.FileCount-1) do begin
    if ZipFile.FileInfos[f].CRC32=crc then begin
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
