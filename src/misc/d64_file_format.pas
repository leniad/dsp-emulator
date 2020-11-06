unit d64_file_format;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}main_engine,misc_functions,disk_file_format;

function d64_format(DrvNum:byte;longi_ini:dword;datos:pbyte):boolean;

implementation
const
  sector_track:array[1..42] of byte=(21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,
  19,19,19,19,19,19,19,
  18,18,18,18,18,18,
  17,17,17,17,17,17,17,17,17,17,17,17);

function d64_format(DrvNum:byte;longi_ini:dword;datos:pbyte):boolean;
var
  longitud:dword;
  puntero,punt_data:pbyte;
  track,sector:byte;
begin
d64_format:=false;
if datos=nil then exit;
longitud:=0;
puntero:=datos;
clear_disk(drvnum);
track:=1;
while (longitud<longi_ini) do begin
  dsk[DrvNum].Tracks[0,track].track_number:=track;
  dsk[DrvNum].Tracks[0,track].side_number:=0;
  dsk[DrvNum].Tracks[0,track].number_sector:=sector_track[track];
  getmem(dsk[drvnum].Tracks[0,track].data,256*sector_track[track]);
  punt_data:=dsk[drvnum].Tracks[0,track].data;
  for sector:=0 to sector_track[track]-1 do begin
    dsk[drvnum].Tracks[0,track].sector[sector].track:=track;
    dsk[drvnum].Tracks[0,track].sector[sector].head:=0;
    dsk[drvnum].Tracks[0,track].sector[sector].sector:=sector;
    copymemory(punt_data,puntero,256);
    longitud:=longitud+256;
    inc(puntero,256);
    inc(punt_data,256);
  end;
  track:=track+1;
end;
dsk[drvnum].abierto:=true;
d64_format:=true;
end;

end.
