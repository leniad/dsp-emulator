unit rom_engine;

interface
uses main_engine,sysutils,dialogs;

type
  tipo_roms=record
                n:string;
                l:dword;
                p:dword;
                crc:dword;
            end;
  ptipo_roms=^tipo_roms;

function carga_rom_zip(nombre_zip,nombre_rom:string;donde:pbyte;longitud,crc:integer;warning:boolean):boolean;
function carga_rom_zip_crc(nombre_zip,nombre_rom:string;donde:pointer;longitud:integer;crc:dword;warning:boolean=true):boolean;
function roms_load(sitio:pbyte;const ctipo_roms:array of tipo_roms;warning:boolean=true;parent:boolean=false;nombre:string=''):boolean;
function roms_load16b(sitio:pbyte;const ctipo_roms:array of tipo_roms;warning:boolean=true;parent:boolean=false;nombre:string=''):boolean;
function roms_load16w(sitio:pword;const ctipo_roms:array of tipo_roms;warning:boolean=true;parent:boolean=false;nombre:string=''):boolean;
function roms_load32b(sitio:pbyte;const ctipo_roms:array of tipo_roms):boolean;
function roms_load32b_b(sitio:pbyte;const ctipo_roms:array of tipo_roms):boolean;
function roms_load32dw(sitio:pdword;const ctipo_roms:array of tipo_roms):boolean;
function roms_load64b(sitio:pbyte;const ctipo_roms:array of tipo_roms):boolean;
function roms_load_swap_word(sitio:pbyte;const ctipo_roms:array of tipo_roms;warning:boolean=true;parent:boolean=false;nombre:string=''):boolean;
function roms_load64b_b(sitio:pbyte;const ctipo_roms:array of tipo_roms):boolean;
//Rom Export
procedure export_roms;
procedure export_samples;

implementation
uses init_games,file_engine,lenguaje,misc_functions,samples;

var
  fichero:textfile;

function carga_rom_zip(nombre_zip,nombre_rom:string;donde:pbyte;longitud,crc:integer;warning:boolean):boolean;
var
  long_rom:integer;
  crc_rom:dword;
begin
carga_rom_zip:=false;
//Cargar el archivo
if not(load_file_from_zip(nombre_zip,nombre_rom,donde,long_rom,crc_rom,warning)) then exit;
//Es la longitud correcta?
if ((longitud<>long_rom) and warning) then begin
  MessageDlg('ROM file size error: '+'"'+nombre_rom+'"', mtError,[mbOk], 0);
  exit;
end;
//Tiene el CRC correcto?
if ((crc_rom<>crc) and (crc<>0) and warning and main_vars.show_crc_error) then MessageDlg('CRC Error file: '+'"'+nombre_rom+'".'+chr(10)+chr(13)+'Have: 0x'+inttohex(crc_rom,8)+' must be: 0x'+inttohex(crc,8), mtError,[mbOk], 0);
carga_rom_zip:=true;
end;

function carga_rom_zip_crc(nombre_zip,nombre_rom:string;donde:pointer;longitud:integer;crc:dword;warning:boolean=true):boolean;
var
  long_rom:integer;
begin
carga_rom_zip_crc:=false;
if not(load_file_from_zip_crc(nombre_zip,donde,long_rom,crc,warning)) then exit;
//Es la longitud correcta?
if ((longitud<>long_rom) and warning) then begin
  MessageDlg('ROM file size error: '+'"'+nombre_rom+'"', mtError,[mbOk], 0);
  exit;
end;
carga_rom_zip_crc:=true;
end;

function rom_zip_name:string;
var
  f:integer;
begin
for f:=1 to GAMES_CONT do begin
  if GAMES_DESC[f].grid=main_vars.tipo_maquina then begin
    rom_zip_name:=GAMES_DESC[f].zip+'.zip';
    break;
  end;
end;
end;

function roms_load(sitio:pbyte;const ctipo_roms:array of tipo_roms;warning:boolean=true;parent:boolean=false;nombre:string=''):boolean;
var
  ptemp:pbyte;
  f,roms_size:word;
  nombre_zip,dir:string;
begin
if parent then nombre_zip:=nombre
  else nombre_zip:=rom_zip_name;
roms_load:=false;
roms_size:=length(ctipo_roms);
for f:=0 to (roms_size-1) do begin
    if ctipo_roms[f].n='' then continue;
    ptemp:=sitio;
    inc(ptemp,ctipo_roms[f].p);
    dir:=directory.arcade_list_roms[find_rom_multiple_dirs(nombre_zip)];
    if ctipo_roms[f].crc<>0 then if not(carga_rom_zip_crc(dir+nombre_zip,ctipo_roms[f].n,ptemp,ctipo_roms[f].l,ctipo_roms[f].crc,warning)) then
        if not(carga_rom_zip(dir+nombre_zip,ctipo_roms[f].n,ptemp,ctipo_roms[f].l,ctipo_roms[f].crc,warning)) then exit;
end;
roms_load:=true;
end;

function roms_load16b(sitio:pbyte;const ctipo_roms:array of tipo_roms;warning:boolean=true;parent:boolean=false;nombre:string=''):boolean;
var
  ptemp,ptemp2,mem_temp:pbyte;
  h:dword;
  nombre_zip,dir:string;
  f,roms_size:word;
begin
if parent then nombre_zip:=nombre
  else nombre_zip:=rom_zip_name;
roms_load16b:=false;
roms_size:=length(ctipo_roms);
for f:=0 to (roms_size-1) do begin
    if ctipo_roms[f].n='' then continue;
    //Creo un puntero byte
    getmem(mem_temp,ctipo_roms[f].l);
    //Cargo los datos como byte
    dir:=directory.arcade_list_roms[find_rom_multiple_dirs(nombre_zip)];
    if ctipo_roms[f].crc<>0 then if not(carga_rom_zip_crc(dir+nombre_zip,ctipo_roms[f].n,mem_temp,ctipo_roms[f].l,ctipo_roms[f].crc,warning)) then
      if not(carga_rom_zip(dir+nombre_zip,ctipo_roms[f].n,mem_temp,ctipo_roms[f].l,ctipo_roms[f].crc,warning)) then exit;
    //Los convierto a word
    ptemp2:=mem_temp;
    ptemp:=sitio;
    inc(ptemp,ctipo_roms[f].p);
    for h:=0 to (ctipo_roms[f].l-1) do begin
      ptemp^:=ptemp2^;
      inc(ptemp2);
      inc(ptemp,2);
    end;
    freemem(mem_temp);
end;
roms_load16b:=true;
end;

function roms_load16w(sitio:pword;const ctipo_roms:array of tipo_roms;warning:boolean=true;parent:boolean=false;nombre:string=''):boolean;
var
  ptemp:pword;
  ptemp2,mem_temp:pbyte;
  h:dword;
  alto:boolean;
  f,roms_size,valor:word;
  nombre_zip,dir:string;
begin
if parent then nombre_zip:=nombre
  else nombre_zip:=rom_zip_name;
roms_load16w:=false;
roms_size:=length(ctipo_roms);
for f:=0 to (roms_size-1) do begin
    if ctipo_roms[f].n='' then continue;
    //Cargo los datos en tipo byte
    getmem(mem_temp,ctipo_roms[f].l);
    dir:=directory.arcade_list_roms[find_rom_multiple_dirs(nombre_zip)];
    if ctipo_roms[f].crc<>0 then if not(carga_rom_zip_crc(dir+nombre_zip,ctipo_roms[f].n,mem_temp,ctipo_roms[f].l,ctipo_roms[f].crc,warning)) then
      if not(carga_rom_zip(dir+nombre_zip,ctipo_roms[f].n,mem_temp,ctipo_roms[f].l,ctipo_roms[f].crc,warning)) then exit;
    //Y ahora los pongo como word
    ptemp2:=mem_temp;
    ptemp:=sitio;
    alto:=(ctipo_roms[f].p and $1)<>0;
    inc(ptemp,ctipo_roms[f].p shr 1);
    for h:=0 to (ctipo_roms[f].l-1) do begin
      if not(alto) then valor:=(ptemp2^ shl 8) or (ptemp^ and $ff)
        else valor:=ptemp2^ or (ptemp^ and $ff00);
      ptemp^:=valor;
      inc(ptemp2);
      inc(ptemp);
    end;
    freemem(mem_temp);
end;
roms_load16w:=true;
end;

function roms_load32b(sitio:pbyte;const ctipo_roms:array of tipo_roms):boolean;
var
  ptemp,ptemp2,mem_temp:pbyte;
  f,h:dword;
  nombre_zip,dir:string;
  roms_size:word;
begin
nombre_zip:=rom_zip_name;
roms_load32b:=false;
roms_size:=length(ctipo_roms);
for f:=0 to (roms_size-1) do begin
    if ctipo_roms[f].n='' then continue;
    getmem(mem_temp,ctipo_roms[f].l);
    dir:=directory.arcade_list_roms[find_rom_multiple_dirs(nombre_zip)];
    if ctipo_roms[f].crc<>0 then if not(carga_rom_zip_crc(dir+nombre_zip,ctipo_roms[f].n,mem_temp,ctipo_roms[f].l,ctipo_roms[f].crc)) then
      if not(carga_rom_zip(dir+nombre_zip,ctipo_roms[f].n,mem_temp,ctipo_roms[f].l,ctipo_roms[f].crc,true)) then exit;
    ptemp2:=mem_temp;
    ptemp:=sitio;
    inc(ptemp,ctipo_roms[f].p);
    for h:=0 to ((ctipo_roms[f].l shr 1)-1) do begin
      ptemp^:=ptemp2^;
      inc(ptemp);
      inc(ptemp2);
      ptemp^:=ptemp2^;
      inc(ptemp2);
      inc(ptemp,3);
    end;
    freemem(mem_temp);
end;
roms_load32b:=true;
end;

function roms_load32b_b(sitio:pbyte;const ctipo_roms:array of tipo_roms):boolean;
var
  roms_size,f:word;
  ptemp,ptemp2,mem_temp:pbyte;
  h:dword;
  nombre_zip,dir:string;
begin
nombre_zip:=rom_zip_name;
roms_load32b_b:=false;
roms_size:=length(ctipo_roms);
for f:=0 to (roms_size-1) do begin
    if ctipo_roms[f].n='' then continue;
    getmem(mem_temp,ctipo_roms[f].l);
    dir:=directory.arcade_list_roms[find_rom_multiple_dirs(nombre_zip)];
    if ctipo_roms[f].crc<>0 then if not(carga_rom_zip_crc(dir+nombre_zip,ctipo_roms[f].n,mem_temp,ctipo_roms[f].l,ctipo_roms[f].crc)) then
      if not(carga_rom_zip(dir+nombre_zip,ctipo_roms[f].n,mem_temp,ctipo_roms[f].l,ctipo_roms[f].crc,true)) then exit;
    ptemp2:=mem_temp;
    ptemp:=sitio;
    inc(ptemp,ctipo_roms[f].p);
    for h:=0 to (ctipo_roms[f].l-1) do begin
      ptemp^:=ptemp2^;
      inc(ptemp,4);
      inc(ptemp2);
    end;
    freemem(mem_temp);
end;
roms_load32b_b:=true;
end;

function roms_load32dw(sitio:pdword;const ctipo_roms:array of tipo_roms):boolean;
var
  ptemp:pdword;
  ptemp2,mem_temp:pbyte;
  h,valor:dword;
  f,roms_size:word;
  nombre_zip,dir:string;
begin
nombre_zip:=rom_zip_name;
roms_load32dw:=false;
roms_size:=length(ctipo_roms);
for f:=0 to (roms_size-1) do begin
    if ctipo_roms[f].n='' then continue;
    //Cargo los datos en tipo byte
    getmem(mem_temp,ctipo_roms[f].l);
    dir:=directory.arcade_list_roms[find_rom_multiple_dirs(nombre_zip)];
    if ctipo_roms[f].crc<>0 then if not(carga_rom_zip_crc(dir+nombre_zip,ctipo_roms[f].n,mem_temp,ctipo_roms[f].l,ctipo_roms[f].crc)) then
      if not(carga_rom_zip(dir+nombre_zip,ctipo_roms[f].n,mem_temp,ctipo_roms[f].l,ctipo_roms[f].crc,true)) then exit;
    //Y ahora los pongo como word
    ptemp2:=mem_temp;
    ptemp:=sitio;
    inc(ptemp,ctipo_roms[f].p shr 2);
    for h:=0 to (ctipo_roms[f].l-1) do begin
      valor:=ptemp^;
      case (ctipo_roms[f].p and $3) of
        0:ptemp^:=ptemp2^ or (valor and $ffffff00);
        1:ptemp^:=(ptemp2^ shl 8) or (valor and $ffff00ff);
        2:ptemp^:=(ptemp2^ shl 16) or (valor and $ff00ffff);
        3:ptemp^:=(ptemp2^ shl 24) or (valor and $00ffffff);
      end;
      inc(ptemp2);
      inc(ptemp);
    end;
    freemem(mem_temp);
end;
roms_load32dw:=true;
end;

function roms_load64b(sitio:pbyte;const ctipo_roms:array of tipo_roms):boolean;
var
  roms_size,f:word;
  ptemp,ptemp2,mem_temp:pbyte;
  h:dword;
  nombre_zip,dir:string;
begin
nombre_zip:=rom_zip_name;
roms_load64b:=false;
roms_size:=length(ctipo_roms);
for f:=0 to (roms_size-1) do begin
    if ctipo_roms[f].n='' then continue;
    getmem(mem_temp,ctipo_roms[f].l);
    dir:=directory.arcade_list_roms[find_rom_multiple_dirs(nombre_zip)];
    if ctipo_roms[f].crc<>0 then if not(carga_rom_zip_crc(dir+nombre_zip,ctipo_roms[f].n,mem_temp,ctipo_roms[f].l,ctipo_roms[f].crc)) then
      if not(carga_rom_zip(dir+nombre_zip,ctipo_roms[f].n,mem_temp,ctipo_roms[f].l,ctipo_roms[f].crc,true)) then exit;
    ptemp2:=mem_temp;
    ptemp:=sitio;
    inc(ptemp,ctipo_roms[f].p);
    for h:=0 to ((ctipo_roms[f].l shr 1)-1) do begin
      ptemp^:=ptemp2^;
      inc(ptemp);
      inc(ptemp2);
      ptemp^:=ptemp2^;
      inc(ptemp2);
      inc(ptemp,7);
    end;
    freemem(mem_temp);
end;
roms_load64b:=true;
end;

function roms_load_swap_word(sitio:pbyte;const ctipo_roms:array of tipo_roms;warning:boolean=true;parent:boolean=false;nombre:string=''):boolean;
var
  v1,v2:byte;
  ptemp,ptemp2:pbyte;
  roms_size,f,h:dword;
  nombre_zip,dir:string;
begin
if parent then nombre_zip:=nombre
  else nombre_zip:=rom_zip_name;
roms_load_swap_word:=false;
roms_size:=length(ctipo_roms);
for f:=0 to (roms_size-1) do begin
    if ctipo_roms[f].n='' then continue;
    ptemp:=sitio;
    inc(ptemp,ctipo_roms[f].p);
    dir:=directory.arcade_list_roms[find_rom_multiple_dirs(nombre_zip)];
    if ctipo_roms[f].crc<>0 then if not(carga_rom_zip_crc(dir+nombre_zip,ctipo_roms[f].n,ptemp,ctipo_roms[f].l,ctipo_roms[f].crc)) then
        if not(carga_rom_zip(dir+nombre_zip,ctipo_roms[f].n,ptemp,ctipo_roms[f].l,ctipo_roms[f].crc,true)) then exit;
    ptemp2:=ptemp;
    for h:=0 to (ctipo_roms[f].l div 2)-1 do begin
      v1:=ptemp2^;inc(ptemp2);
      v2:=ptemp2^;dec(ptemp2);
      ptemp2^:=v2;inc(ptemp2);
      ptemp2^:=v1;inc(ptemp2);
    end;
end;
roms_load_swap_word:=true;
end;

function roms_load64b_b(sitio:pbyte;const ctipo_roms:array of tipo_roms):boolean;
var
  roms_size,f:word;
  ptemp,ptemp2,mem_temp:pbyte;
  h:dword;
  nombre_zip,dir:string;
begin
nombre_zip:=rom_zip_name;
roms_load64b_b:=false;
roms_size:=length(ctipo_roms);
for f:=0 to (roms_size-1) do begin
    if ctipo_roms[f].n='' then continue;
    getmem(mem_temp,ctipo_roms[f].l);
    dir:=directory.arcade_list_roms[find_rom_multiple_dirs(nombre_zip)];
    if ctipo_roms[f].crc<>0 then if not(carga_rom_zip_crc(dir+nombre_zip,ctipo_roms[f].n,mem_temp,ctipo_roms[f].l,ctipo_roms[f].crc)) then
      if not(carga_rom_zip(dir+nombre_zip,ctipo_roms[f].n,mem_temp,ctipo_roms[f].l,ctipo_roms[f].crc,true)) then exit;
    ptemp2:=mem_temp;
    ptemp:=sitio;
    inc(ptemp,ctipo_roms[f].p);
    for h:=0 to (ctipo_roms[f].l-1) do begin
      ptemp^:=ptemp2^;
      inc(ptemp2);
      inc(ptemp,8);
    end;
    freemem(mem_temp);
end;
roms_load64b_b:=true;
end;

procedure set_header(nombre_fichero:string);
begin
if FileExists(nombre_fichero) then begin                                         //Respuesta 'NO' es 7
  if MessageDlg(leng.mensajes[3], mtWarning,[mbYes]+[mbNo],0)=7 then exit;
end;
{$I-}
assignfile(fichero,nombre_fichero);
rewrite(fichero);
if ioresult<>0 then begin
  MessageDlg('Cannot write file: "'+nombre_fichero+'"',mtError,[mbOk], 0);
  {$I+}
  exit;
end;
writeln(fichero,'<?xml version="1.0"?>');
writeln(fichero,'<!DOCTYPE datafile PUBLIC "-//DSP Emulator ROM Datafile//" "http://www.github.com/leniad">');
writeln(fichero,'');
writeln(fichero,'<datafile>');
writeln(fichero,'  <header>');
writeln(fichero,'    <name>DSP Emulator</name>');
writeln(fichero,'    <description>DSP Emulator '+DSP_VERSION+'</description>');
writeln(fichero,'    <category>EMULATION</category>');
writeln(fichero,'    <version>'+DSP_VERSION+'</version>');
writeln(fichero,'    <date>'+DateToStr(date)+'</date>');
writeln(fichero,'    <author>Leniad</author>');
writeln(fichero,'    <email>leniad2@hotmail.com</email>');
writeln(fichero,'    <homepage>http://www.github.com/leniad/</homepage>');
writeln(fichero,'    <url>--</url>');
writeln(fichero,'    <comment>--</comment>');
writeln(fichero,'    <clrmamepro/>');
writeln(fichero,'  </header>');
end;

//Rom export
procedure export_roms;
var
  f:word;
  rom_data:tgame_desc;
  rom_file:ptipo_roms;
  nombre_fichero,change_name:string;
  indice:byte;
  //text_file:textfile;
begin
if not(SaveRom(nombre_fichero,indice,SEXPORT)) then exit;
set_header(nombre_fichero);
// {$I-}
//AssignFile(text_file,'d:\abandon\dsp_data');
//ReWrite(text_file);
//for f:=1 to GAMES_CONT do begin
//  WriteLn(text_file,'(nombre:'''+GAMES_DESC[f].name+''';dir:'''+GAMES_DESC[f].zip+''';exec:'''+GAMES_DESC[f].company+''';ciclos:'+inttostr(integer(GAMES_DESC[f].grid))+'''+;extra_param:'''+GAMES_DESC[f].year+'''),');
//end;
//CloseFile(text_file);
{$I+}
for f:=1 to GAMES_CONT do begin
  rom_data:=GAMES_DESC[f];
  if rom_data.zip<>'' then begin
    case rom_data.grid of
      3,5:continue;
      180:writeln(fichero,'  <game name="'+rom_data.zip+'" cloneof="rbisland">'); //Rainbow Island Extra
      350:writeln(fichero,'  <game name="'+rom_data.zip+'" cloneof="xevious">'); //Super Xevious
      426:writeln(fichero,'  <game name="'+rom_data.zip+'" cloneof="bublbobl">'); //Super Bobble Bobble
      else  writeln(fichero,'  <game name="'+rom_data.zip+'">');
    end;
    change_name:=StringReplace(rom_data.name,'&','&amp;',[rfReplaceAll, rfIgnoreCase]);
    case rom_data.grid of
      0:writeln(fichero,'     <description>Spectrum 16K/48K</description>');
      2:writeln(fichero,'     <description>Spectrum +2A/+3</description>');
      else writeln(fichero,'     <description>'+change_name+'</description>');
    end;
    writeln(fichero,'     <year>'+rom_data.year+'</year>');
    writeln(fichero,'     <manufacturer>'+rom_data.company+'</manufacturer>');
    rom_file:=rom_data.rom[0];
    indice:=0;
    repeat
      repeat
        writeln(fichero,'     <rom name="'+rom_file.n+'" size="'+inttostr(rom_file.l)+'" crc="'+inttohex(rom_file.crc,8)+'"/>');
        inc(rom_file);
      until (rom_file.n='');
      indice:=indice+1;
      rom_file:=rom_data.rom[indice];
    until (rom_file=nil);
    writeln(fichero,'  </game>');
  end;
end;
writeln(fichero,'</datafile>');
close(fichero);
{$I+}
end;

procedure export_samples;
var
  f:word;
  rom_data:tgame_desc;
  sample_file:ptipo_nombre_samples;
  nombre_fichero,change_name:string;
  indice:byte;
begin
if not(SaveRom(nombre_fichero,indice,SEXPORT_SAMPLES)) then exit;
set_header(nombre_fichero);
for f:=1 to GAMES_CONT do begin
  rom_data:=GAMES_DESC[f];
  if rom_data.zip<>'' then begin
    if rom_data.samples<>nil then begin
      case rom_data.grid of
        70:writeln(fichero,'  <game name="'+rom_data.zip+'" cloneof="rallyx">'); //New Rally X
        346,347:writeln(fichero,'  <game name="'+rom_data.zip+'" cloneof="zaxxon">'); //Super Zaxxon y Future Spy
        350:writeln(fichero,'  <game name="'+rom_data.zip+'" cloneof="xevious">'); //Super Xevious
        else writeln(fichero,'  <game name="'+rom_data.zip+'">');
      end;
      change_name:=StringReplace(rom_data.name,'&','&amp;',[rfReplaceAll, rfIgnoreCase]);
      writeln(fichero,'     <description>'+change_name+'</description>');
      writeln(fichero,'     <year>'+rom_data.year+'</year>');
      writeln(fichero,'     <manufacturer>'+rom_data.company+'</manufacturer>');
      sample_file:=rom_data.samples[0];
      indice:=0;
      repeat
        repeat
          writeln(fichero,'     <sample name="'+sample_file.nombre+'"/>');
          inc(sample_file);
        until sample_file.nombre='';
        indice:=indice+1;
        sample_file:=rom_data.samples[indice];
      until (sample_file=nil);
      writeln(fichero,'  </game>');
    end;
  end;
end;
writeln(fichero,'</datafile>');
close(fichero);
{$I+}
end;

end.
