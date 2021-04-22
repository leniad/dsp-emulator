unit misc_functions;

interface
uses {$IFDEF windows}windows,{$ENDIF}{$ifdef fpc}crc,{$else}
     {$IFDEF windows}vcl.imaging.pngimage,{$ENDIF}{$endif}sysutils,forms,
     dialogs,controls;

type
  TSistema=(StNES,StColecovision,STGb,StChip8,StAmstrad,StAmstradROM,StROM,
            StSMS,StExport,StSpectrum,StBitmap,StSG1000,StC64,StGG);

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
function OpenRom(Sistema:TSistema;var name:string):boolean;
function SaveRom(sistema:TSistema;var name:string;var index:byte):boolean;

implementation
uses principal,main_engine;

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
principal1.btncfg.left:=(principal1.statusbar1.width div 2)+14+3{$ifdef fpc}+6{$endif}; //14
principal1.BitBtn8.left:=(principal1.statusbar1.width div 2)+42+13{$ifdef fpc}+8{$endif}; //42
principal1.BitBtn13.left:=(principal1.statusbar1.width div 2)+72+22{$ifdef fpc}+9{$endif};  //72
principal1.BitBtn19.left:=(principal1.statusbar1.width div 2)+103+29{$ifdef fpc}+11{$endif}; //103
principal1.Left:=old_x;
principal1.Top:=old_y;
end;

function bit(data:dword;bitpos:byte):boolean;inline;
begin
   bit:=((data shr bitpos) and 1)<>0;
end;

function bit_n(data:dword;bitpos:byte):byte;inline;
begin
   bit_n:=(data shr bitpos) and 1;
end;

function BITSWAP8(val,B7,B6,B5,B4,B3,B2,B1,B0:byte):byte;inline;
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

function BITSWAP16(val:word;B15,B14,B13,B12,B11,B10,B9,B8,B7,B6,B5,B4,B3,B2,B1,B0:byte):word;inline;
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

function BITSWAP24(val:dword;B23,B22,B21,B20,B19,B18,B17,B16,B15,B14,B13,B12,B11,B10,B9,B8,B7,B6,B5,B4,B3,B2,B1,B0:byte):dword;inline;
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

function BITSWAP32(val:dword;B31,B30,B29,B28,B27,B26,B25,B24,B23,B22,B21,B20,B19,B18,B17,B16,B15,B14,B13,B12,B11,B10,B9,B8,B7,B6,B5,B4,B3,B2,B1,B0:byte):dword;inline;
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
   2,4:mul_video:=2;
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

function OpenRom(Sistema:TSistema;var name:string):boolean;
var
  openDialog:topendialog;
begin
openDialog:=TOpenDialog.Create(principal1);
case Sistema of
  StColecovision:begin
         opendialog.InitialDir:=Directory.coleco_snap;
         OpenDialog.Filter:='ColecoVision Files (*.col;*.rom;*.csn;*.dsp;*.bin;*.zip)|*.col;*.rom;*.csn;*.dsp;*.bin;*.zip';
       end;
  StNES:begin
         opendialog.InitialDir:=Directory.Nes;
         OpenDialog.Filter:='NES Files (*.nes;*zip)|*.nes;*.zip';
       end;
  StSMS:begin
         opendialog.InitialDir:=Directory.sms;
         OpenDialog.Filter:='SMS Files (*.sms;*.rom;*.zip)|*.sms;*.rom;*.zip';
       end;
  Stgb:begin
         opendialog.InitialDir:=Directory.GameBoy;
         OpenDialog.Filter:='GB Files (*.gb;*.gbc;*zip)|*.gb;*.gbc;*.zip';
       end;
  StChip8:begin
         opendialog.InitialDir:=Directory.Chip8;
         OpenDialog.Filter:='Chip-8 Files (*.ch8;*.bin;*zip)|*.ch8;*.bin;*.zip';
       end;
  StAmstrad:begin
         opendialog.InitialDir:=directory.amstrad_tap;
         OpenDialog.Filter:='CPC Tape or Snapshot (*.cdt;*.tzx;*.csw;*.wav;*.sna;*zip;)|*.cdt;*.tzx;*.csw;*.wav;*.sna;*.zip';
       end;
  StROM:begin
         opendialog.InitialDir:=Directory.arcade_list_roms[0];
         OpenDialog.Filter:='ROM Files (*.rom;*.zip)|*.rom;*.zip';
       end;
  StAmstradROM:begin
         opendialog.InitialDir:=Directory.Amstrad_rom;
         OpenDialog.Filter:='ROM Files (*.rom;*.zip)|*.rom;*.zip';
       end;
  StSG1000:begin
         opendialog.InitialDir:=Directory.sg1000;
         OpenDialog.Filter:='SG-1000 Files (*.sg;*.zip)|*.sg;*.zip';
       end;
  StC64:begin
         opendialog.InitialDir:=directory.c64_tap;
         OpenDialog.Filter:='C64 Tape or Snapshot (*.prg;*.t64;*.tap;*.wav;*zip)|*.prg;*.t64;*.tap;*.wav;*.zip';
       end;
  StGG:begin
         opendialog.InitialDir:=Directory.gg;
         OpenDialog.Filter:='GG Files (*.gg;*.zip)|*.gg;*.zip';
       end;
end;
OpenRom:=OpenDialog.execute;
name:=OpenDialog.FileName;
opendialog.free;
end;

function SaveRom(sistema:TSistema;var name:string;var index:byte):boolean;
var
  SaveDialog:tsavedialog;
begin
SaveDialog:=TSaveDialog.Create(principal1);
case Sistema of
  StColecovision:begin
         SaveDialog.InitialDir:=Directory.coleco_snap;
         SaveDialog.Filter:='DSP Format (*.dsp)|*.dsp|CSN Format (*.csn)|*.csn';
       end;
  StAmstrad:begin
         savedialog.InitialDir:=Directory.amstrad_snap;
         saveDialog.Filter:='SNA Format (*.SNA)|*.SNA';
       end;
  StExport:begin
         SaveDialog.Filter:='DAT File (*.dat)|*.dat';
         SaveDialog.FileName:='dsp_roms_dat.dat';
       end;
  StSpectrum:begin
         SaveDialog.InitialDir:=Directory.spectrum_tap_snap;
         if ((main_vars.tipo_maquina=2) or (main_vars.tipo_maquina=3)) then SaveDialog.Filter:= 'SZX Format (*.SZX)|*.SZX|Z80 Format (*.Z80)|*.Z80|DSP Format (*.DSP)|*.DSP'
            else SaveDialog.Filter:= 'SZX Format (*.SZX)|*.SZX|Z80 Format (*.Z80)|*.Z80|DSP Format (*.DSP)|*.DSP|SNA Format (*.SNA)|*.SNA';
       end;
  StBitmap:begin
         savedialog.InitialDir:=Directory.spectrum_image;
         saveDialog.Filter:='Imagen PNG(*.PNG)|*.png|Imagen JPG(*.JPG)|*.jpg|Imagen GIF(*.GIF)|*.gif';
         SaveDialog.FileName:=StringReplace(llamadas_maquina.caption,':',' ',[rfReplaceAll, rfIgnoreCase]);
       end;
  StNES:begin
         savedialog.InitialDir:=Directory.amstrad_snap;
         saveDialog.Filter:='DSP Format (*.DSP)|*.DSP';
       end;
end;
SaveRom:=SaveDialog.execute;
name:=SaveDialog.FileName;
index:=SaveDialog.FilterIndex;
SaveDialog.free;
end;

end.
