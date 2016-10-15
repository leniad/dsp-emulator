unit qsnapshot;

interface
uses {$IFDEF windows}windows,{$ENDIF}
     main_engine,file_engine,sysutils;

procedure open_qsnapshot_save(name:string);
procedure close_qsnapshot;
procedure savedata_qsnapshot(data:pbyte;size:dword);
procedure savedata_com_qsnapshot(data:pbyte;size:dword);
function open_qsnapshot_load(name:string):boolean;
procedure loaddata_qsnapshot(data:pbyte);

var
  qsnap_fichero:file of byte;

implementation

procedure open_qsnapshot_save(name:string);
var
  cadena:array[0..8] of char;
  buffer:array[0..1] of byte;
begin
{$I-}
cadena:='DSP-QSNAP';
buffer[0]:=1; //Version 1.00
buffer[1]:=00;
assignfile(qsnap_fichero,Directory.qsnapshot+name);
rewrite(qsnap_fichero);
blockwrite(qsnap_fichero,cadena[0],18);
blockwrite(qsnap_fichero,buffer[0],2);
{$I+}
end;

procedure close_qsnapshot;
begin
{$I-}
closefile(qsnap_fichero);
{$I+}
end;

procedure savedata_qsnapshot(data:pbyte;size:dword);
var
  buffer:array[0..4] of byte;
begin
buffer[0]:=size and $ff;
buffer[1]:=(size shr 8) and $ff;
buffer[2]:=(size shr 16) and $ff;
buffer[3]:=(size shr 24) and $ff;
buffer[4]:=0; //Not copressed
{$I-}
blockwrite(qsnap_fichero,buffer[0],5);
blockwrite(qsnap_fichero,data^,size);
{$I+}
end;

procedure savedata_com_qsnapshot(data:pbyte;size:dword);
var
  puntero:pbyte;
  comprimido:dword;
  buffer:array[0..4] of byte;
begin
getmem(puntero,size);
compress_zlib(pointer(data),integer(size),pointer(puntero),integer(comprimido));
buffer[0]:=comprimido and $ff;
buffer[1]:=(comprimido shr 8) and $ff;
buffer[2]:=(comprimido shr 16) and $ff;
buffer[3]:=(comprimido shr 24) and $ff;
buffer[4]:=1; //Copressed
{$I-}
blockwrite(qsnap_fichero,buffer[0],5);
blockwrite(qsnap_fichero,puntero^,comprimido);
{$I+}
freemem(puntero);
end;

function open_qsnapshot_load(name:string):boolean;
var
  cadena:array[0..8] of char;
  buffer:array[0..1] of byte;
begin
open_qsnapshot_load:=false;
if not FileExists(directory.qsnapshot+name) then exit;
{$I-}
assignfile(qsnap_fichero,directory.qsnapshot+name);
reset(qsnap_fichero);
blockread(qsnap_fichero,cadena[0],18);
if cadena<>'DSP-QSNAP' then exit;
blockread(qsnap_fichero,buffer[0],2);  //Version
open_qsnapshot_load:=true;
{$I+}
end;

procedure loaddata_qsnapshot(data:pbyte);
var
  puntero,ptemp:pbyte;
  comprimido,descomprimido:integer;
  buffer:array[0..4] of byte;
begin
{$I-}
blockread(qsnap_fichero,buffer[0],5);
comprimido:=buffer[0]+(buffer[1] shl 8)+(buffer[2] shl 16)+(buffer[3] shl 24);
if buffer[4]=0 then begin //No compressed
  blockread(qsnap_fichero,data^,comprimido);
end else begin //Compressed
  getmem(puntero,comprimido);
  getmem(ptemp,$30000);
  blockread(qsnap_fichero,puntero^,comprimido);
  decompress_zlib(pointer(puntero),comprimido,pointer(ptemp),descomprimido);
  copymemory(data,ptemp,descomprimido);
  freemem(ptemp);
  freemem(puntero);
end;
{$I+}
end;

end.