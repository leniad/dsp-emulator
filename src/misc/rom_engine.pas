unit Rom_engine;

interface
uses {$IFDEF windows}windows,{$ENDIF}
     sysutils,dialogs,file_engine,main_engine;

type
  tipo_roms=record
                n:string;
                l:dword;
                p:dword;
                crc:dword;
            end;
  ptipo_roms=^tipo_roms;

function carga_rom_zip(nombre_zip,nombre_rom:string;donde:pbyte;longitud,crc:integer;warning:boolean):boolean;
function carga_rom_zip_crc(nombre_zip,nombre_rom:string;donde:pointer;longitud,crc:integer):boolean;
function cargar_roms(sitio:pbyte;ctipo_roms:ptipo_roms;nombre_zip:string;cantidad_roms:byte=1):boolean;
function cargar_roms16b(sitio:pbyte;ctipo_roms:ptipo_roms;nombre_zip:string;cantidad_roms:byte):boolean;
function cargar_roms16w(sitio:pword;ctipo_roms:ptipo_roms;nombre_zip:string;cantidad_roms:byte):boolean;
function cargar_roms32b(sitio:pbyte;ctipo_roms:ptipo_roms;nombre_zip:string;cantidad_roms:byte):boolean;
function cargar_roms32b_b(sitio:pbyte;ctipo_roms:ptipo_roms;nombre_zip:string;cantidad_roms:byte):boolean;
function cargar_roms_skip(sitio:pbyte;ctipo_roms:ptipo_roms;nombre_zip:string;cantidad_roms,skip:byte):boolean;
function cargar_roms_swap_word(sitio:pbyte;ctipo_roms:ptipo_roms;nombre_zip:string;cantidad_roms:byte):boolean;
function cargar_roms_skip_word(sitio:pbyte;ctipo_roms:ptipo_roms;nombre_zip:string;cantidad_roms,skip:byte):boolean;

implementation

function carga_rom_zip(nombre_zip,nombre_rom:string;donde:pbyte;longitud,crc:integer;warning:boolean):boolean;
var
  long_rom,crc_rom:integer;
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

function carga_rom_zip_crc(nombre_zip,nombre_rom:string;donde:pointer;longitud,crc:integer):boolean;
var
  long_rom:integer;
begin
carga_rom_zip_crc:=false;
if not(load_file_from_zip_crc(nombre_zip,donde,long_rom,crc)) then exit;
//Es la longitud correcta?
if (longitud<>long_rom) then begin
  MessageDlg('ROM file size error: '+'"'+nombre_rom+'"', mtError,[mbOk], 0);
  exit;
end;
carga_rom_zip_crc:=true;
end;

function cargar_roms(sitio:pbyte;ctipo_roms:ptipo_roms;nombre_zip:string;cantidad_roms:byte=1):boolean;
var
  f:byte;
  ptemp:pbyte;
  troms:ptipo_roms;
begin
cargar_roms:=false;
troms:=ctipo_roms;
f:=0;
repeat
    ptemp:=sitio;
    inc(ptemp,troms.p);
    if troms.crc<>0 then if not(carga_rom_zip_crc(Directory.Arcade_roms+nombre_zip,troms.n,ptemp,troms.l,integer(troms.crc))) then
        if not(carga_rom_zip(Directory.Arcade_roms+nombre_zip,troms.n,ptemp,troms.l,troms.crc,true)) then exit;
    inc(troms);
    inc(f);
until ((troms.n='') or (f=cantidad_roms));
cargar_roms:=true;
end;

function cargar_roms_swap_word(sitio:pbyte;ctipo_roms:ptipo_roms;nombre_zip:string;cantidad_roms:byte):boolean;
var
  f,v1,v2:byte;
  ptemp,ptemp2:pbyte;
  troms:ptipo_roms;
  h:dword;
begin
cargar_roms_swap_word:=false;
troms:=ctipo_roms;
f:=0;
repeat
    ptemp:=sitio;
    inc(ptemp,troms.p);
    if troms.crc<>0 then if not(carga_rom_zip_crc(Directory.Arcade_roms+nombre_zip,troms.n,ptemp,troms.l,troms.crc)) then
      if not(carga_rom_zip(Directory.Arcade_roms+nombre_zip,troms.n,ptemp,troms.l,troms.crc,true)) then exit;
    ptemp2:=ptemp;
    for h:=0 to (troms.l div 2)-1 do begin
      v1:=ptemp2^;inc(ptemp2);
      v2:=ptemp2^;dec(ptemp2);
      ptemp2^:=v2;inc(ptemp2);
      ptemp2^:=v1;inc(ptemp2);
    end;
    inc(troms);
    inc(f);
until ((troms.n='') or (f=cantidad_roms));
cargar_roms_swap_word:=true;
end;

function cargar_roms16b(sitio:pbyte;ctipo_roms:ptipo_roms;nombre_zip:string;cantidad_roms:byte):boolean;
var
  f:byte;
  ptemp,ptemp2,mem_temp:pbyte;
  troms:ptipo_roms;
  h:dword;
begin
cargar_roms16b:=false;
troms:=ctipo_roms;
f:=0;
repeat
    getmem(mem_temp,troms.l);
    ptemp2:=mem_temp;
    ptemp:=sitio;
    inc(ptemp,troms.p);
    if troms.crc<>0 then if not(carga_rom_zip_crc(Directory.Arcade_roms+nombre_zip,troms.n,mem_temp,troms.l,troms.crc)) then
      if not(carga_rom_zip(Directory.Arcade_roms+nombre_zip,troms.n,mem_temp,troms.l,troms.crc,true)) then exit;
    for h:=0 to (troms.l-1) do begin
      ptemp^:=ptemp2^;
      inc(ptemp2);
      inc(ptemp,2);
    end;
    inc(troms);
    inc(f);
    freemem(mem_temp);
until ((troms.n='') or (f=cantidad_roms));
cargar_roms16b:=true;
end;

function cargar_roms16w(sitio:pword;ctipo_roms:ptipo_roms;nombre_zip:string;cantidad_roms:byte):boolean;
var
  f:byte;
  ptemp:pword;
  ptemp2,mem_temp:pbyte;
  troms:ptipo_roms;
  h:dword;
  alto:boolean;
  valor:word;
begin
cargar_roms16w:=false;
troms:=ctipo_roms;
f:=0;
repeat
    getmem(mem_temp,troms.l);
    ptemp2:=mem_temp;
    ptemp:=sitio;
    alto:=(troms.p and $1)<>0;
    inc(ptemp,troms.p shr 1);
    if troms.crc<>0 then if not(carga_rom_zip_crc(Directory.Arcade_roms+nombre_zip,troms.n,mem_temp,troms.l,troms.crc)) then
      if not(carga_rom_zip(Directory.Arcade_roms+nombre_zip,troms.n,mem_temp,troms.l,troms.crc,true)) then exit;
    for h:=0 to (troms.l-1) do begin
      if not(alto) then valor:=(ptemp2^ shl 8) or (ptemp^ and $ff)
        else valor:=ptemp2^ or (ptemp^ and $ff00);
      ptemp^:=valor;
      inc(ptemp2);
      inc(ptemp);
    end;
    inc(troms);
    inc(f);
    freemem(mem_temp);
until ((troms.n='') or (f=cantidad_roms));
cargar_roms16w:=true;
end;

function cargar_roms32b(sitio:pbyte;ctipo_roms:ptipo_roms;nombre_zip:string;cantidad_roms:byte):boolean;
var
  f:byte;
  ptemp,ptemp2,mem_temp:pbyte;
  troms:ptipo_roms;
  h:dword;
begin
cargar_roms32b:=false;
troms:=ctipo_roms;
f:=0;
repeat
    getmem(mem_temp,troms.l);
    ptemp2:=mem_temp;
    ptemp:=sitio;
    inc(ptemp,troms.p);
    if troms.crc<>0 then if not(carga_rom_zip_crc(Directory.Arcade_roms+nombre_zip,troms.n,mem_temp,troms.l,troms.crc)) then
      if not(carga_rom_zip(Directory.Arcade_roms+nombre_zip,troms.n,mem_temp,troms.l,troms.crc,true)) then exit;
    for h:=0 to ((troms.l shr 1)-1) do begin
      ptemp^:=ptemp2^;
      inc(ptemp);
      inc(ptemp2);
      ptemp^:=ptemp2^;
      inc(ptemp2);
      inc(ptemp,3);
    end;
    inc(troms);
    inc(f);
    freemem(mem_temp);
until ((troms.n='') or (f=cantidad_roms));
cargar_roms32b:=true;
end;

function cargar_roms32b_b(sitio:pbyte;ctipo_roms:ptipo_roms;nombre_zip:string;cantidad_roms:byte):boolean;
var
  f:byte;
  ptemp,ptemp2,mem_temp:pbyte;
  troms:ptipo_roms;
  h:dword;
begin
cargar_roms32b_b:=false;
troms:=ctipo_roms;
f:=0;
repeat
    getmem(mem_temp,troms.l);
    ptemp2:=mem_temp;
    ptemp:=sitio;
    inc(ptemp,troms.p);
    if troms.crc<>0 then if not(carga_rom_zip_crc(Directory.Arcade_roms+nombre_zip,troms.n,mem_temp,troms.l,troms.crc)) then
      if not(carga_rom_zip(Directory.Arcade_roms+nombre_zip,troms.n,mem_temp,troms.l,troms.crc,true)) then exit;
    for h:=0 to (troms.l-1) do begin
      ptemp^:=ptemp2^;
      inc(ptemp,4);
      inc(ptemp2);
    end;
    inc(troms);
    inc(f);
    freemem(mem_temp);
until ((troms.n='') or (f=cantidad_roms));
cargar_roms32b_b:=true;
end;


function cargar_roms_skip(sitio:pbyte;ctipo_roms:ptipo_roms;nombre_zip:string;cantidad_roms,skip:byte):boolean;
var
  f:byte;
  ptemp,ptemp2,mem_temp:pbyte;
  troms:ptipo_roms;
  h:dword;
begin
cargar_roms_skip:=false;
troms:=ctipo_roms;
f:=0;
repeat
    getmem(mem_temp,troms.l);
    ptemp2:=mem_temp;
    ptemp:=sitio;
    inc(ptemp,troms.p);
    if troms.crc<>0 then if not(carga_rom_zip_crc(Directory.Arcade_roms+nombre_zip,troms.n,mem_temp,troms.l,troms.crc)) then
      if not(carga_rom_zip(Directory.Arcade_roms+nombre_zip,troms.n,mem_temp,troms.l,troms.crc,true)) then exit;
    for h:=0 to (troms.l-1) do begin
      ptemp^:=ptemp2^;
      inc(ptemp2);
      inc(ptemp,skip);
    end;
    inc(troms);
    inc(f);
    freemem(mem_temp);
until ((troms.n='') or (f=cantidad_roms));
cargar_roms_skip:=true;
end;

function cargar_roms_skip_word(sitio:pbyte;ctipo_roms:ptipo_roms;nombre_zip:string;cantidad_roms,skip:byte):boolean;
var
  f:byte;
  ptemp,ptemp2,mem_temp:pbyte;
  troms:ptipo_roms;
  h:dword;
begin
cargar_roms_skip_word:=false;
troms:=ctipo_roms;
f:=0;
repeat
    getmem(mem_temp,troms.l);
    ptemp2:=mem_temp;
    ptemp:=sitio;
    inc(ptemp,troms.p);
    if troms.crc<>0 then if not(carga_rom_zip_crc(Directory.Arcade_roms+nombre_zip,troms.n,mem_temp,troms.l,troms.crc)) then
      if not(carga_rom_zip(Directory.Arcade_roms+nombre_zip,troms.n,mem_temp,troms.l,troms.crc,true)) then exit;
    for h:=0 to ((troms.l div 2)-1) do begin
      ptemp^:=ptemp2^;
      //word
      inc(ptemp);
      inc(ptemp2);
      ptemp^:=ptemp2^;
      inc(ptemp2);
      inc(ptemp,skip-1);
    end;
    inc(troms);
    inc(f);
    freemem(mem_temp);
until ((troms.n='') or (f=cantidad_roms));
cargar_roms_skip_word:=true;
end;

end.