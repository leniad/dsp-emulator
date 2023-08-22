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
function carga_rom_zip_crc(nombre_zip,nombre_rom:string;donde:pointer;longitud:integer;crc:dword;warning:boolean=true):boolean;
function roms_load(sitio:pbyte;const ctipo_roms:array of tipo_roms;warning:boolean=true;parent:boolean=false;nombre:string=''):boolean;
function roms_load16b(sitio:pbyte;const ctipo_roms:array of tipo_roms):boolean;
function roms_load16w(sitio:pword;const ctipo_roms:array of tipo_roms):boolean;
function roms_load32b(sitio:pbyte;const ctipo_roms:array of tipo_roms):boolean;
function roms_load32b_b(sitio:pbyte;const ctipo_roms:array of tipo_roms):boolean;
function roms_load32dw(sitio:pdword;const ctipo_roms:array of tipo_roms):boolean;
function roms_load64b(sitio:pbyte;const ctipo_roms:array of tipo_roms):boolean;
function roms_load_swap_word(sitio:pbyte;const ctipo_roms:array of tipo_roms):boolean;
function roms_load64b_b(sitio:pbyte;const ctipo_roms:array of tipo_roms):boolean;

implementation
uses init_games;

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

function roms_load(sitio:pbyte;const ctipo_roms:array of tipo_roms;warning:boolean=true;parent:boolean=false;nombre:string=''):boolean;
var
  ptemp:pbyte;
  f,roms_size:word;
  nombre_zip,dir:string;
begin
if parent then nombre_zip:=nombre
  else for f:=1 to GAMES_CONT do begin
          if GAMES_DESC[f].grid=main_vars.tipo_maquina then begin
            nombre_zip:=GAMES_DESC[f].zip+'.zip';
            break;
          end;
        end;
roms_load:=false;
roms_size:=length(ctipo_roms);
for f:=0 to (roms_size-1) do begin
    ptemp:=sitio;
    inc(ptemp,ctipo_roms[f].p);
    dir:=directory.arcade_list_roms[find_rom_multiple_dirs(nombre_zip)];
    if ctipo_roms[f].crc<>0 then if not(carga_rom_zip_crc(dir+nombre_zip,ctipo_roms[f].n,ptemp,ctipo_roms[f].l,integer(ctipo_roms[f].crc),warning)) then
        if not(carga_rom_zip(dir+nombre_zip,ctipo_roms[f].n,ptemp,ctipo_roms[f].l,ctipo_roms[f].crc,warning)) then exit;
end;
roms_load:=true;
end;

function roms_load16b(sitio:pbyte;const ctipo_roms:array of tipo_roms):boolean;
var
  ptemp,ptemp2,mem_temp:pbyte;
  h:dword;
  nombre_zip,dir:string;
  f,roms_size:word;
begin
for f:=1 to GAMES_CONT do begin
  if GAMES_DESC[f].grid=main_vars.tipo_maquina then begin
    nombre_zip:=GAMES_DESC[f].zip+'.zip';
    break;
  end;
end;
roms_load16b:=false;
roms_size:=length(ctipo_roms);
for f:=0 to (roms_size-1) do begin
    //Creo un puntero byte
    getmem(mem_temp,ctipo_roms[f].l);
    //Cargo los datos como byte
    dir:=directory.arcade_list_roms[find_rom_multiple_dirs(nombre_zip)];
    if ctipo_roms[f].crc<>0 then if not(carga_rom_zip_crc(dir+nombre_zip,ctipo_roms[f].n,mem_temp,ctipo_roms[f].l,ctipo_roms[f].crc)) then
      if not(carga_rom_zip(dir+nombre_zip,ctipo_roms[f].n,mem_temp,ctipo_roms[f].l,ctipo_roms[f].crc,true)) then exit;
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

function roms_load16w(sitio:pword;const ctipo_roms:array of tipo_roms):boolean;
var
  ptemp:pword;
  ptemp2,mem_temp:pbyte;
  h:dword;
  alto:boolean;
  f,roms_size,valor:word;
  nombre_zip,dir:string;
begin
for f:=1 to GAMES_CONT do begin
  if GAMES_DESC[f].grid=main_vars.tipo_maquina then begin
    nombre_zip:=GAMES_DESC[f].zip+'.zip';
    break;
  end;
end;
roms_load16w:=false;
roms_size:=length(ctipo_roms);
for f:=0 to (roms_size-1) do begin
    //Cargo los datos en tipo byte
    getmem(mem_temp,ctipo_roms[f].l);
    dir:=directory.arcade_list_roms[find_rom_multiple_dirs(nombre_zip)];
    if ctipo_roms[f].crc<>0 then if not(carga_rom_zip_crc(dir+nombre_zip,ctipo_roms[f].n,mem_temp,ctipo_roms[f].l,ctipo_roms[f].crc)) then
      if not(carga_rom_zip(dir+nombre_zip,ctipo_roms[f].n,mem_temp,ctipo_roms[f].l,ctipo_roms[f].crc,true)) then exit;
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
for f:=1 to GAMES_CONT do begin
  if GAMES_DESC[f].grid=main_vars.tipo_maquina then begin
    nombre_zip:=GAMES_DESC[f].zip+'.zip';
    break;
  end;
end;
roms_load32b:=false;
roms_size:=length(ctipo_roms);
for f:=0 to (roms_size-1) do begin
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
for f:=1 to GAMES_CONT do begin
  if GAMES_DESC[f].grid=main_vars.tipo_maquina then begin
    nombre_zip:=GAMES_DESC[f].zip+'.zip';
    break;
  end;
end;
roms_load32b_b:=false;
roms_size:=length(ctipo_roms);
for f:=0 to (roms_size-1) do begin
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
for f:=1 to GAMES_CONT do begin
  if GAMES_DESC[f].grid=main_vars.tipo_maquina then begin
    nombre_zip:=GAMES_DESC[f].zip+'.zip';
    break;
  end;
end;
roms_load32dw:=false;
roms_size:=length(ctipo_roms);
for f:=0 to (roms_size-1) do begin
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
for f:=1 to GAMES_CONT do begin
  if GAMES_DESC[f].grid=main_vars.tipo_maquina then begin
    nombre_zip:=GAMES_DESC[f].zip+'.zip';
    break;
  end;
end;
roms_load64b:=false;
roms_size:=length(ctipo_roms);
for f:=0 to (roms_size-1) do begin
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

function roms_load_swap_word(sitio:pbyte;const ctipo_roms:array of tipo_roms):boolean;
var
  v1,v2:byte;
  ptemp,ptemp2:pbyte;
  roms_size,f,h:dword;
  nombre_zip,dir:string;
begin
for f:=1 to GAMES_CONT do begin
  if GAMES_DESC[f].grid=main_vars.tipo_maquina then begin
    nombre_zip:=GAMES_DESC[f].zip+'.zip';
    break;
  end;
end;
roms_load_swap_word:=false;
roms_size:=length(ctipo_roms);
for f:=0 to (roms_size-1) do begin
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
for f:=1 to GAMES_CONT do begin
  if GAMES_DESC[f].grid=main_vars.tipo_maquina then begin
    nombre_zip:=GAMES_DESC[f].zip+'.zip';
    break;
  end;
end;
roms_load64b_b:=false;
roms_size:=length(ctipo_roms);
for f:=0 to (roms_size-1) do begin
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

end.
