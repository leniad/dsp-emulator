unit misc_functions;

interface
uses {$IFDEF windows}windows,{$ENDIF}{$ifdef fpc}crc,{$else}
     {$IFDEF windows}vcl.imaging.pngimage,{$ENDIF}{$endif}sysutils,forms,
     dialogs,controls;

const
  SARCADE=0;
  SNES=1;
  SCOLECO=2;
  SGB=3;
  SCHIP8=4;
  SAMSTRADCPC=5;
  SSMS=6;
  SSPECTRUM=7;
  SSG1000=8;
  SC64=9;
  SGG=10;
  SSUPERCASSETTE=11;
  SORIC=12;
  SPV1000=14;
  SPV2000=15;
  SAMSTRADROM=16;
  SROM=17;
  SEXPORT=18;
  SEXPORT_SAMPLES=22;
  SBITMAP=19;
  SGENESIS=20;
  SGANDW=21;

function extension_fichero(nombre:string):string;
procedure fix_screen_pos(width,height:word);
function calc_crc(p: pointer;byteCount:dword):dword;
function mul_video:byte;
//bit func
function bit(data:dword;bitpos:byte):boolean;
function bit_n(data:dword;bitpos:byte):byte;
function BITSWAP8(val,B7,B6,B5,B4,B3,B2,B1,B0:byte):byte;
function BITSWAP16(val:word;B15,B14,B13,B12,B11,B10,B9,B8,B7,B6,B5,B4,B3,B2,B1,B0:byte):word;
function BITSWAP24(val:dword;B23,B22,B21,B20,B19,B18,B17,B16,B15,B14,B13,B12,B11,B10,B9,B8,B7,B6,B5,B4,B3,B2,B1,B0:byte):dword;
function BITSWAP32(val:dword;B31,B30,B29,B28,B27,B26,B25,B24,B23,B22,B21,B20,B19,B18,B17,B16,B15,B14,B13,B12,B11,B10,B9,B8,B7,B6,B5,B4,B3,B2,B1,B0:byte):dword;
//Load/Save Systems ROM
function openrom(var name:string;system_type:byte):boolean;
function saverom(var name:string;var index:byte;system_type:byte):boolean;
//Load data
function extract_data(romfile:string;data_des:pbyte;var longitud:integer;var file_name:string;system_type:byte):boolean;

implementation
uses principal,main_engine,file_engine;

procedure fix_screen_pos(width,height:word);
var
   old_x,old_y:integer;
begin
old_x:=principal1.Left;
old_y:=principal1.Top;
{$ifdef fpc}
principal1.BorderStyle:=bsSizeable;
{$endif}
if width<>0 then principal1.ClientWidth:=width;
if height<>0 then principal1.ClientHeight:=height;
{$ifdef fpc}
principal1.BorderStyle:=bsSingle;
{$endif}
//arreglar la barra del fondo
principal1.statusbar1.Width:=width-25;
principal1.Image1.Left:=principal1.statusbar1.Width;
principal1.Image1.top:=principal1.statusbar1.top;
principal1.statusbar1.Panels[0].Width:=60;
principal1.statusbar1.Panels[1].Width:=125;
//botones
principal1.BitBtn2.left:=(principal1.statusbar1.width div 2)-107-38{$ifdef fpc}-9{$endif}; //107
principal1.BitBtn3.left:=(principal1.statusbar1.width div 2)-79-28{$ifdef fpc}-7{$endif}; //79
principal1.BitBtn5.left:=(principal1.statusbar1.width div 2)-47-22{$ifdef fpc}-8{$endif}; //47
principal1.BitBtn6.left:=(principal1.statusbar1.width div 2)-19-12{$ifdef fpc}-6{$endif}; //19
principal1.BitBtn8.left:=(principal1.statusbar1.width div 2)+14-1{$ifdef fpc}+6{$endif}; //14
principal1.BitBtn19.left:=(principal1.statusbar1.width div 2)+42+9{$ifdef fpc}+8{$endif}; //42
principal1.btncfg.left:=(principal1.statusbar1.width div 2)+72+22{$ifdef fpc}+9{$endif};  //72
principal1.BitBtn13.left:=(principal1.statusbar1.width div 2)+103+29{$ifdef fpc}+11{$endif}; //103
principal1.Left:=old_x;
principal1.Top:=old_y;
end;

function bit(data:dword;bitpos:byte):boolean;
begin
   bit:=((data shr bitpos) and 1)<>0;
end;

function bit_n(data:dword;bitpos:byte):byte;
begin
   bit_n:=(data shr bitpos) and 1;
end;

function BITSWAP8(val,B7,B6,B5,B4,B3,B2,B1,B0:byte):byte;
var
  src:byte;
begin
  src:=0;
  if BIT(val,B7) then src:=src or (1 shl 7);
  if BIT(val,B6) then src:=src or (1 shl 6);
  if BIT(val,B5) then src:=src or (1 shl 5);
  if BIT(val,B4) then src:=src or (1 shl 4);
  if BIT(val,B3) then src:=src or (1 shl 3);
  if BIT(val,B2) then src:=src or (1 shl 2);
  if BIT(val,B1) then src:=src or (1 shl 1);
  if BIT(val,B0) then src:=src or (1 shl 0);
  bitswap8:=src;
end;

function BITSWAP16(val:word;B15,B14,B13,B12,B11,B10,B9,B8,B7,B6,B5,B4,B3,B2,B1,B0:byte):word;
var
  src:word;
begin
  src:=0;
  if BIT(val,B15) then src:=src or (1 shl 15);
	if BIT(val,B14) then src:=src or (1 shl 14);
  if BIT(val,B13) then src:=src or (1 shl 13);
  if BIT(val,B12) then src:=src or (1 shl 12);
  if BIT(val,B11) then src:=src or (1 shl 11);
  if BIT(val,B10) then src:=src or (1 shl 10);
  if BIT(val,B9) then src:=src or (1 shl 9);
  if BIT(val,B8) then src:=src or (1 shl 8);
  if BIT(val,B7) then src:=src or (1 shl 7);
  if BIT(val,B6) then src:=src or (1 shl 6);
  if BIT(val,B5) then src:=src or (1 shl 5);
  if BIT(val,B4) then src:=src or (1 shl 4);
  if BIT(val,B3) then src:=src or (1 shl 3);
  if BIT(val,B2) then src:=src or (1 shl 2);
  if BIT(val,B1) then src:=src or (1 shl 1);
  if BIT(val,B0) then src:=src or (1 shl 0);
  bitswap16:=src;
end;

function BITSWAP24(val:dword;B23,B22,B21,B20,B19,B18,B17,B16,B15,B14,B13,B12,B11,B10,B9,B8,B7,B6,B5,B4,B3,B2,B1,B0:byte):dword;
var
  src:dword;
begin
     src:=0;
     if BIT(val,B23) then src:=src or (1 shl 23);
		 if BIT(val,B22) then src:=src or (1 shl 22);
		 if BIT(val,B21) then src:=src or (1 shl 21);
		 if BIT(val,B20) then src:=src or (1 shl 20);
		 if BIT(val,B19) then src:=src or (1 shl 19);
		 if BIT(val,B18) then src:=src or (1 shl 18);
		 if BIT(val,B17) then src:=src or (1 shl 17);
		 if BIT(val,B16) then src:=src or (1 shl 16);
     if BIT(val,B15) then src:=src or (1 shl 15);
		 if BIT(val,B14) then src:=src or (1 shl 14);
		 if BIT(val,B13) then src:=src or (1 shl 13);
		 if BIT(val,B12) then src:=src or (1 shl 12);
		 if BIT(val,B11) then src:=src or (1 shl 11);
		 if BIT(val,B10) then src:=src or (1 shl 10);
		 if BIT(val,B9) then src:=src or (1 shl 9);
		 if BIT(val,B8) then src:=src or (1 shl 8);
		 if BIT(val,B7) then src:=src or (1 shl 7);
		 if BIT(val,B6) then src:=src or (1 shl 6);
		 if BIT(val,B5) then src:=src or (1 shl 5);
		 if BIT(val,B4) then src:=src or (1 shl 4);
		 if BIT(val,B3) then src:=src or (1 shl 3);
		 if BIT(val,B2) then src:=src or (1 shl 2);
		 if BIT(val,B1) then src:=src or (1 shl 1);
		 if BIT(val,B0) then src:=src or (1 shl 0);
     bitswap24:=src;
end;

function BITSWAP32(val:dword;B31,B30,B29,B28,B27,B26,B25,B24,B23,B22,B21,B20,B19,B18,B17,B16,B15,B14,B13,B12,B11,B10,B9,B8,B7,B6,B5,B4,B3,B2,B1,B0:byte):dword;
var
  src:dword;
begin
     src:=0;
     if BIT(val,B31) then src:=src or (1 shl 31);
     if BIT(val,B30) then src:=src or (1 shl 30);
     if BIT(val,B29) then src:=src or (1 shl 29);
     if BIT(val,B28) then src:=src or (1 shl 28);
     if BIT(val,B27) then src:=src or (1 shl 27);
     if BIT(val,B26) then src:=src or (1 shl 26);
     if BIT(val,B25) then src:=src or (1 shl 25);
     if BIT(val,B24) then src:=src or (1 shl 24);
     if BIT(val,B23) then src:=src or (1 shl 23);
		 if BIT(val,B22) then src:=src or (1 shl 22);
		 if BIT(val,B21) then src:=src or (1 shl 21);
		 if BIT(val,B20) then src:=src or (1 shl 20);
		 if BIT(val,B19) then src:=src or (1 shl 19);
		 if BIT(val,B18) then src:=src or (1 shl 18);
		 if BIT(val,B17) then src:=src or (1 shl 17);
		 if BIT(val,B16) then src:=src or (1 shl 16);
     if BIT(val,B15) then src:=src or (1 shl 15);
		 if BIT(val,B14) then src:=src or (1 shl 14);
		 if BIT(val,B13) then src:=src or (1 shl 13);
		 if BIT(val,B12) then src:=src or (1 shl 12);
		 if BIT(val,B11) then src:=src or (1 shl 11);
		 if BIT(val,B10) then src:=src or (1 shl 10);
		 if BIT(val,B9) then src:=src or (1 shl 9);
		 if BIT(val,B8) then src:=src or (1 shl 8);
		 if BIT(val,B7) then src:=src or (1 shl 7);
		 if BIT(val,B6) then src:=src or (1 shl 6);
		 if BIT(val,B5) then src:=src or (1 shl 5);
		 if BIT(val,B4) then src:=src or (1 shl 4);
		 if BIT(val,B3) then src:=src or (1 shl 3);
		 if BIT(val,B2) then src:=src or (1 shl 2);
		 if BIT(val,B1) then src:=src or (1 shl 1);
		 if BIT(val,B0) then src:=src or (1 shl 0);
     bitswap32:=src;
end;

function extension_fichero(nombre:string):string;
var
  f:word;
  final_,final2:string;
begin
final_:=extractfileext(nombre);
final2:='';
if final_<>'' then for f:=1 to length(final_) do begin
  final_[f]:=upcase(final_[f]);
  if final_[f]<>'.' then final2:=final2+final_[f];
end;
extension_fichero:=final2;
end;

function mul_video:byte;
begin
case main_screen.video_mode of
   2,4,6:mul_video:=2;
   5:mul_video:=3;
   else mul_video:=1;
end;
end;

{$ifndef fpc}
function calc_crc(p:pointer;byteCount:dword):dword;
begin
calc_crc:=not(update_crc($FFFFFFFF,p,bytecount));
end;
{$else}
function calc_crc(p:pointer;byteCount:dword):dword;
var
   crc:cardinal;
begin
crc:=crc32(0,nil,0);
crc:=CRC32(crc,p,bytecount);
calc_crc:=crc;
end;
{$endif}

function extract_data(romfile:string;data_des:pbyte;var longitud:integer;var file_name:string;system_type:byte):boolean;
var
  nombre_file,extension:string;
  datos:pbyte;
  salir,resultado:boolean;
  crc:dword;
  ext:array[1..10] of string;
  f,total_ext:byte;
begin
case system_type of
  SNES:begin
            ext[1]:='NES';
            ext[2]:='DSP';
            total_ext:=2;
          end;
  SCOLECO:begin
            ext[1]:='COL';
            ext[2]:='ROM';
            ext[3]:='CSN';
            ext[4]:='DSP';
            total_ext:=4;
          end;
  SGB:begin
            ext[1]:='GB';
            ext[2]:='GBC';
            ext[3]:='DSP';
            total_ext:=3;
          end;
  SSG1000:begin
            ext[1]:='SG';
            ext[2]:='MV';
            ext[3]:='DSP';
            total_ext:=3;
          end;
  SGG:begin
            ext[1]:='GG';
            ext[2]:='DSP';
            total_ext:=2;
          end;
  SSMS:begin
            ext[1]:='SMS';
            ext[2]:='ROM';
            ext[3]:='DSP';
            total_ext:=3;
          end;
  SSUPERCASSETTE:begin
            ext[1]:='0';
            ext[2]:='BIN';
            ext[3]:='DSP';
            total_ext:=3;
          end;
  SCHIP8:begin
            ext[1]:='BIN';
            ext[2]:='CH8';
            ext[3]:='DSP';
            total_ext:=3;
          end;
  SORIC:begin
            ext[1]:='TAP';
            ext[2]:='WAV';
            total_ext:=2;
          end;
  SAMSTRADCPC:begin
            ext[1]:='CDT';
            ext[2]:='TZX';
            ext[3]:='CSW';
            ext[4]:='ROM';
            ext[5]:='WAV';
            ext[6]:='SNA';
            total_ext:=6;
          end;
  SC64:begin
            ext[1]:='TAP';
            ext[2]:='PRG';
            ext[3]:='T64';
            ext[4]:='WAV';
            ext[5]:='VSF';
            total_ext:=5;
          end;
  SPV1000,SPV2000:begin
            ext[1]:='BIN';
            ext[2]:='DSP';
            ext[3]:='ROM';
            total_ext:=3;
          end;
  else begin
          MessageDlg('Sistema sin definir!!!', mtInformation,[mbOk], 0);
          extract_data:=false;
          exit;
       end;
end;
extension:=extension_fichero(romfile);
datos:=nil;
if extension='ZIP' then begin
  resultado:=false;
  f:=1;
  salir:=false;
  while not(salir) do begin
    if search_file_from_zip(romfile,'*.'+ext[f],nombre_file,longitud,crc,false) then begin
      resultado:=true;
      salir:=true;
    end;
    f:=f+1;
    if f>total_ext then salir:=true;
  end;
  if resultado then begin
    getmem(datos,longitud);
    if not(load_file_from_zip(romfile,nombre_file,datos,longitud,crc,true)) then resultado:=false;
  end;
end else begin
  resultado:=false;
  for f:=1 to total_ext do if extension=ext[f] then resultado:=true;
  if resultado then begin
    if read_file_size(romfile,longitud) then begin
      getmem(datos,longitud);
      if read_file(romfile,datos,longitud) then begin
        resultado:=true;
        nombre_file:=extractfilename(romfile)
      end;
    end else resultado:=false;
  end;
end;
if not(resultado) then begin
  MessageDlg('Error cargando.'+chr(10)+chr(13)+'Error loading.', mtInformation,[mbOk], 0);
  if datos<>nil then freemem(datos);
  extract_data:=false;
  nombre_file:='';
  exit;
end;
copymemory(data_des,datos,longitud);
file_name:=nombre_file;
if datos<>nil then freemem(datos);
extract_data:=true;
end;

function openrom(var name:string;system_type:byte):boolean;
var
  opendialog:topendialog;
begin
opendialog:=TOpenDialog.Create(principal1);
case system_type of
  SCOLECO:begin
         opendialog.InitialDir:=directory.coleco;
         Opendialog.Filter:='ColecoVision Game/Snapshots (*.col;*.rom;*.csn;*.dsp;*.bin;*.zip)|*.col;*.rom;*.csn;*.dsp;*.bin;*.zip';
       end;
  SNES:begin
         opendialog.InitialDir:=directory.nes;
         Opendialog.Filter:='NES Game (*.nes;*.dsp;*zip)|*.nes;*.dsp;*.zip';
       end;
  SSMS:begin
         opendialog.InitialDir:=directory.sms;
         Opendialog.Filter:='SMS Game/Snapshot (*.sms;*.rom;*.dsp;*.zip)|*.sms;*.rom;*.dsp;*.zip';
       end;
  SGB:begin
         opendialog.InitialDir:=directory.gameboy;
         Opendialog.Filter:='GB Game (*.gb;*.gbc;*.dsp;*zip)|*.gb;*.gbc;*.dsp;*.zip';
       end;
  SCHIP8:begin
         opendialog.InitialDir:=directory.chip8;
         Opendialog.Filter:='Chip-8 Files (*.ch8;*.bin;*.dsp;*zip)|*.ch8;*.bin;*.dsp;*.zip';
       end;
  SAMSTRADCPC:begin
         opendialog.InitialDir:=directory.amstrad_tap;
         Opendialog.Filter:='CPC Tape/Snapshot/ROM (*.rom;*.cdt;*.tzx;*.csw;*.wav;*.sna;*zip;)|*.rom;*.cdt;*.tzx;*.csw;*.wav;*.sna;*.zip';
       end;
  SROM:begin
         opendialog.InitialDir:=directory.arcade_list_roms[0];
         Opendialog.Filter:='ROM Files (*.rom;*.zip)|*.rom;*.zip';
       end;
  SAMSTRADROM:begin
         opendialog.InitialDir:=directory.Amstrad_rom;
         Opendialog.Filter:='CPC ROM Files (*.rom;*.zip)|*.rom;*.zip';
       end;
  SSG1000:begin
         opendialog.InitialDir:=directory.sg1000;
         Opendialog.Filter:='SG-1000 Game/Snapshot (*.sg;*.mv;*.dsp;*.zip)|*.sg;*.mv;*.dsp;*.zip';
       end;
  SC64:begin
         opendialog.InitialDir:=directory.c64_tap;
         Opendialog.Filter:='C64 Tape/Snapshot (*.prg;*.t64;*.tap;*.wav;*.vsf;*.zip)|*.prg;*.t64;*.tap;*.wav;*.vsf;*.zip';
       end;
  SGG:begin
         opendialog.InitialDir:=directory.gg;
         Opendialog.Filter:='GG Game/Snapshot (*.gg;*.dsp;*.zip)|*.gg;*.dsp;*.zip';
       end;
  SSUPERCASSETTE:begin
         opendialog.InitialDir:=directory.scv;
         Opendialog.Filter:='SCV Game/Snapshot (*.bin;*.dsp;*.zip)|*.bin;*.dsp;*.zip';
       end;
  SORIC:begin
         opendialog.InitialDir:=directory.oric_tap;
         Opendialog.Filter:='Oric Tape (*.tap;*.wav;*.zip)|*.tap;*.wav;*.zip';
       end;
  SPV1000:begin
         opendialog.InitialDir:=directory.pv1000;
         Opendialog.Filter:='PV1000 Game/Snapshot (*.rom;*.bin;*.dsp;*.zip)|*.rom;*.bin;*.dsp;*.zip';
       end;
  SPV2000:begin
         opendialog.InitialDir:=directory.pv2000;
         Opendialog.Filter:='PV2000 Game/Snapshot (*.rom;*.bin;*.dsp;*.zip)|*.rom;*.bin;*.dsp;*.zip';
       end;
end;
openrom:=opendialog.execute;
name:=opendialog.FileName;
opendialog.free;
end;

function saverom(var name:string;var index:byte;system_type:byte):boolean;
var
  SaveDialog:tsavedialog;
begin
SaveDialog:=TSaveDialog.Create(principal1);
case system_type of
  SCOLECO:begin
         SaveDialog.InitialDir:=directory.coleco;
         SaveDialog.Filter:='DSP Format (*.dsp)|*.dsp|CSN Format (*.csn)|*.csn';
       end;
  SAMSTRADCPC:begin
         savedialog.InitialDir:=directory.amstrad_snap;
         saveDialog.Filter:='SNA Format (*.sna)|*.sna';
       end;
  SEXPORT:begin
         SaveDialog.Filter:='DAT File (*.dat)|*.dat';
         SaveDialog.FileName:='dsp_roms_dat.dat';
       end;
  SEXPORT_SAMPLES:begin
         SaveDialog.Filter:='DAT File (*.dat)|*.dat';
         SaveDialog.FileName:='dsp_samples_dat.dat';
       end;
  SSPECTRUM:begin
         SaveDialog.InitialDir:=directory.spectrum_tap_snap;
         if ((main_vars.tipo_maquina=2) or (main_vars.tipo_maquina=3)) then SaveDialog.Filter:= 'SZX Format (*.SZX)|*.SZX|Z80 Format (*.Z80)|*.Z80|DSP Format (*.DSP)|*.DSP'
            else SaveDialog.Filter:= 'SZX Format (*.SZX)|*.SZX|Z80 Format (*.Z80)|*.Z80|DSP Format (*.DSP)|*.DSP|SNA Format (*.SNA)|*.SNA';
       end;
  SBITMAP:begin
         savedialog.InitialDir:=directory.spectrum_image;
         saveDialog.Filter:='Imagen PNG(*.PNG)|*.png|Imagen JPG(*.JPG)|*.jpg|Imagen GIF(*.GIF)|*.gif';
         SaveDialog.FileName:=StringReplace(StringReplace(llamadas_maquina.caption,'/','-',[rfReplaceAll, rfIgnoreCase]),':',' ',[rfReplaceAll, rfIgnoreCase]);
       end;
  SNES:begin
         savedialog.InitialDir:=directory.nes;
         saveDialog.Filter:='DSP Format (*.DSP)|*.DSP';
       end;
  SGB:begin
         savedialog.InitialDir:=directory.gameboy;
         saveDialog.Filter:='DSP Format (*.DSP)|*.DSP';
       end;
  SSG1000:begin
         SaveDialog.InitialDir:=directory.sg1000;
         SaveDialog.Filter:='DSP Format (*.dsp)|*.dsp';
       end;
  SSMS:begin
         SaveDialog.InitialDir:=directory.sms;
         SaveDialog.Filter:='DSP Format (*.dsp)|*.dsp';
       end;
  SGG:begin
         SaveDialog.InitialDir:=directory.gg;
         SaveDialog.Filter:='DSP Format (*.dsp)|*.dsp';
       end;
  SCHIP8:begin
         SaveDialog.InitialDir:=directory.Chip8;
         SaveDialog.Filter:='DSP Format (*.dsp)|*.dsp';
       end;
  SSUPERCASSETTE:begin
         SaveDialog.InitialDir:=directory.scv;
         SaveDialog.Filter:='DSP Format (*.dsp)|*.dsp';
       end;
  SPV1000:begin
         SaveDialog.InitialDir:=directory.pv1000;
         SaveDialog.Filter:='DSP Format (*.dsp)|*.dsp';
       end;
  SPV2000:begin
         SaveDialog.InitialDir:=directory.pv2000;
         SaveDialog.Filter:='DSP Format (*.dsp)|*.dsp';
       end;
end;
saverom:=savedialog.execute;
name:=savedialog.FileName;
index:=savedialog.FilterIndex;
savedialog.free;
end;

end.
