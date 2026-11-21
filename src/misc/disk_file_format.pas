unit disk_file_format;

interface
uses main_engine,misc_functions,dialogs;

function dsk_format(DrvNum:byte;longi_ini:dword;datos:pbyte):boolean;
procedure clear_disk(drvnum:byte);
procedure check_protections(drvnum:byte;hay_multi:boolean);
function oric_dsk_format(DrvNum:byte;longi_ini:dword;datos:pbyte):boolean;
function oric_crc_byte(crc:word;value:byte):word;
function oric_decode_track(DrvNum,side,track:byte;raw:pbyte;raw_length:word):boolean;

type
disc_header_type=record
  nbof_tracks:byte;
  nbof_heads:byte;
  track_size_table:array[0..1,0..$cb] of byte;
end;

sector_info_type=record
  track:byte;
  head:byte;
  sector:byte;
  sector_size:byte;
  status1:byte;
  status2:byte;
  data_length:word; // Payload length, never a CRC
  id_crc,data_crc:word; // Oric: CRCs in on-disk byte order
  raw_data_offset:word; // Oric: payload offset in the raw MFM track
  posicion_data:word;
  multi:boolean;
end;

track_type=record
  track_number:byte;
  side_number:byte;
  data_rate:byte;
  recording_mode:byte;
  sector_size:byte;
  number_sector:byte;
  GAP3:byte;
  filler:byte;
  track_lenght:word;
  data:pbyte;
  raw_data:pbyte; // Oric MFM track; nil for CPC/other formats
  raw_length:word;
  sector:array[0..63] of sector_info_type;
end;

DskImg=record
  ImageName:string;
  abierto:boolean;
  track_actual:byte;
  cara_actual:byte;
  sector_actual:byte;
  sector_read_track:byte;
  protegido:boolean;
  DiskHeader:disc_header_type;
  extended:boolean;
  Tracks:array[0..1,0..82] of track_type;
  cont_multi,max_multi:byte;
end;

var
  dsk:array[0..1] of DskImg;

implementation
uses principal,sysutils,lenslock;

type
  tdsk_header=packed record
    magic:array[0..7] of ansichar;  //Realmente son mas, pero solo hay que mirar el 'EXTENDED' (no siempre se sigue el estandar)
    unused:array[0..25] of byte;
    creator:array[0..13] of ansichar;
    tracks:byte;
    sides:byte;
    track_size:word;
    track_size_map:array[0..203] of byte;
  end;
  tdsk_track=packed record
    magic:array[0..9] of ansichar; //El estandar termina con chr(13)+chr(10), pero no lo siguen algunos...
    unused1:array[0..5] of byte;
    track:byte; //No siempre ponen el numero de track correcto... WTF???
    side:byte;
    data_rate:byte;
    record_mode:byte;
    sector_size:byte;
    number_of_sectors:byte;
    gap:byte;
    filler:byte;
  end;
  tdsk_sector=packed record
    track:byte;
    side:byte;
    id:byte;
    size:byte;
    status1:byte;
    status2:byte;
    length:word;
  end;

function dsk_format(DrvNum:byte;longi_ini:dword;datos:pbyte):boolean;
var
  puntero,ptemp:pbyte;
  posicion,tempw:word;
  estandar,primer_sector,salir,hay_multi:boolean;
  dsk_header:^tdsk_header;
  dsk_track:^tdsk_track;
  dsk_sector:^tdsk_sector;
  f,side_num,track_num:byte;
  longi,track_long,long_temp:dword;
  sector_count:integer;
begin
   dsk_format:=false;
   if datos=nil then exit;
   getmem(dsk_header,sizeof(tdsk_header));
   getmem(dsk_track,sizeof(tdsk_track));
   getmem(dsk_sector,sizeof(tdsk_sector));
   clear_disk(drvnum);
   puntero:=datos;
   longi:=0;
   hay_multi:=false;
   copymemory(dsk_header,datos,$100);
   inc(puntero,$100);inc(longi,$100);
   dsk[DrvNum].protegido:=false;
   //Disk Header
   if dsk_header.magic='MV - CPC' then estandar:=true
      else if dsk_header.magic='EXTENDED' then estandar:=false
        else begin
           freemem(dsk_track);
           freemem(dsk_header);
           freemem(dsk_sector);
           exit;
        end;
   dsk[drvnum].DiskHeader.nbof_tracks:=dsk_header.tracks;
   dsk[drvnum].DiskHeader.nbof_heads:=dsk_header.sides;
   f:=0;
   for track_num:=0 to (dsk_header.tracks-1) do begin
     for side_num:=0 to (dsk_header.sides-1) do begin
         dsk[DrvNum].DiskHeader.track_size_table[side_num,track_num]:=dsk_header.track_size_map[f];
         f:=f+1;
     end;
   end;
   //Disk Tracks
   while longi<longi_ini do begin
           //Me posiciono en los datos, la cabecera del track siempre ocupa 256bytes
           ptemp:=puntero;
           copymemory(dsk_track,ptemp,24);
           inc(ptemp,24);
           if dsk_track.magic<>'Track-Info' then begin
              clear_disk(drvnum);
              freemem(dsk_track);
              freemem(dsk_header);
              freemem(dsk_sector);
              exit;
           end;
           primer_sector:=true;
           posicion:=0;
           //Sectores
           for sector_count:=0 to (dsk_track.number_of_sectors-1) do begin
              copymemory(dsk_sector,ptemp,8);
              inc(ptemp,8);
              //Comprobar el track que es...
              if primer_sector then begin
                dsk[DrvNum].Tracks[dsk_track.side,dsk_track.track].track_number:=dsk_track.track;
                dsk[DrvNum].Tracks[dsk_track.side,dsk_track.track].side_number:=dsk_track.side;
                dsk[DrvNum].Tracks[dsk_track.side,dsk_track.track].data_rate:=dsk_track.data_rate;
                dsk[DrvNum].Tracks[dsk_track.side,dsk_track.track].recording_mode:=dsk_track.record_mode;
                dsk[DrvNum].Tracks[dsk_track.side,dsk_track.track].sector_size:=dsk_track.sector_size;
                dsk[DrvNum].Tracks[dsk_track.side,dsk_track.track].number_sector:=dsk_track.number_of_sectors;
                dsk[DrvNum].Tracks[dsk_track.side,dsk_track.track].GAP3:=dsk_track.gap;
                dsk[DrvNum].Tracks[dsk_track.side,dsk_track.track].filler:=dsk_track.filler;
                primer_sector:=false;
              end;
              dsk[drvnum].Tracks[dsk_track.side,dsk_track.track].sector[sector_count].track:=dsk_sector.track;
              dsk[drvnum].Tracks[dsk_track.side,dsk_track.track].sector[sector_count].head:=dsk_sector.side;
              dsk[drvnum].Tracks[dsk_track.side,dsk_track.track].sector[sector_count].sector:=dsk_sector.id;
              dsk[drvnum].Tracks[dsk_track.side,dsk_track.track].sector[sector_count].sector_size:=dsk_sector.size;
              dsk[drvnum].Tracks[dsk_track.side,dsk_track.track].sector[sector_count].status1:=dsk_sector.status1;
              dsk[drvnum].Tracks[dsk_track.side,dsk_track.track].sector[sector_count].status2:=dsk_sector.status2;
              //Calcular la longitud del sector
              if not(estandar) then dsk[drvnum].Tracks[dsk_track.side,dsk_track.track].sector[sector_count].data_length:=dsk_sector.length
                 else dsk[drvnum].Tracks[dsk_track.side,dsk_track.track].sector[sector_count].data_length:=1 shl (dsk_sector.size+7);
              dsk[drvnum].Tracks[dsk_track.side,dsk_track.track].sector[sector_count].posicion_data:=posicion;
              inc(posicion,dsk[drvnum].Tracks[dsk_track.side,dsk_track.track].sector[sector_count].data_length);
              //Weak sectors
              tempw:=dsk[drvnum].Tracks[dsk_track.side,dsk_track.track].sector[sector_count].data_length div (1 shl (dsk_sector.size+7));
              if (tempw>1) then begin
                 if tempw>4 then tempw:=4;
                 dsk[drvnum].Tracks[dsk_track.side,dsk_track.track].sector[sector_count].multi:=true;
                 dsk[drvnum].cont_multi:=tempw;
                 dsk[drvnum].max_multi:=tempw;
                 hay_multi:=true;
              end;
           end; //sectors
           //Primero muevo el puntero hasta el final de la cabecera, que siempre ocupa 256bytes
           inc(puntero,$100);inc(longi,$100);
           //Me guardo la cara y el track del disco, que ahora los voy a borrar...
           side_num:=dsk_track.side;
           track_num:=dsk_track.track;
           //Ahora la longitud del track... No encuentro una forma decente de cuadrar la longitud del fichero con lo que dicen los datos... busco directemente
           ptemp:=puntero;
           salir:=false;
           track_long:=0;
           long_temp:=longi;
           while not(salir) do begin
              copymemory(dsk_track,ptemp,24);
              if dsk_track.magic='Track-Info' then begin
                 salir:=true;
              end else begin
                 if long_temp=longi_ini then begin
                  salir:=true
                 end else begin
                  track_long:=track_long+1;
                  long_temp:=long_temp+1;
                  inc(ptemp);
                end;
              end;
           end;
           if dsk[DrvNum].DiskHeader.track_size_table[side_num,track_num]<>0 then begin
              dsk[drvnum].Tracks[side_num,track_num].track_lenght:=256*(dsk[DrvNum].DiskHeader.track_size_table[side_num,track_num]-1);
           end else begin
              if not(estandar) then dsk[drvnum].Tracks[side_num,track_num].track_lenght:=track_long
                else dsk[drvnum].Tracks[side_num,track_num].track_lenght:=dsk_header.track_size;
           end;
           getmem(dsk[drvnum].Tracks[side_num,track_num].data,track_long);
           copymemory(dsk[drvnum].Tracks[side_num,track_num].data,puntero,track_long);
           inc(puntero,track_long);
           inc(longi,track_long);
   end; //del while
   check_protections(drvnum,hay_multi);
   dsk[drvnum].abierto:=true;
   dsk_format:=true;
   freemem(dsk_sector);
   freemem(dsk_track);
   freemem(dsk_header);
end;

procedure clear_disk(drvnum:byte);
var s,t:integer;
begin
  if drvnum>High(dsk) then exit;
  // Fixed array bounds: safe for partial images, zero counts and 83 tracks.
  for s:=0 to High(dsk[drvnum].Tracks) do
    for t:=0 to High(dsk[drvnum].Tracks[s]) do begin
      if dsk[drvnum].Tracks[s,t].data<>nil then
        FreeMem(dsk[drvnum].Tracks[s,t].data);
      FillChar(dsk[drvnum].Tracks[s,t],SizeOf(track_type),0);
    end;
  dsk[drvnum].abierto:=false;
  dsk[drvnum].cont_multi:=0;
  dsk[drvnum].max_multi:=0;
  dsk[drvnum].track_actual:=0;
  dsk[drvnum].cara_actual:=0;
  dsk[drvnum].sector_actual:=0;
  dsk[drvnum].sector_read_track:=0;
  dsk[drvnum].protegido:=false;
  dsk[drvnum].extended:=false;
  FillChar(dsk[drvnum].DiskHeader,SizeOf(disc_header_type),0);
end;

procedure check_protections(drvnum:byte;hay_multi:boolean);
var
  tempdw:dword;
  puntero,ptemp,ptemp2,ptemp3:pbyte;
  h,cont:word;
  cadena,cadena2:string;
  sp3_presente:boolean;
  f:byte;
begin
  case main_vars.tipo_maquina of
      8,9:begin  //Comprobar algunas protecciones para poder parchearlas...
            if dsk[drvnum].Tracks[0,0].data<>nil then tempdw:=calc_crc(dsk[drvnum].Tracks[0,0].data,dsk[drvnum].Tracks[0,0].sector[0].data_length)
              else exit;
            case tempdw of
              $8c817e25,$4b616c83:dsk[drvnum].Tracks[0,40].sector[6].sector_size:=2; //Titus the fox
              $57a3276f:dsk[drvnum].Tracks[0,39].sector[10].sector_size:=0; //Prehistorik
              $f05fe06e:dsk[drvnum].Tracks[0,39].sector[0].sector_size:=2; //Prehistorik alt
              $31388451:begin // Tomahawk
                          lenslok.indice:=5;
                          lenslock1.Show;
                        end;
              $23a68c26:begin //Graphic Adventure Creator
                          lenslok.indice:=7;
                          lenslock1.Show;
                        end;
              $4c23dda4:begin // Art Studio
                          lenslok.indice:=1;
                          lenslock1.Show;
                        end;
            end;
            if lenslock1.Showing then lenslock1.combobox1.ItemIndex:=lenslok.indice;
          end;
     2:begin  //Comprobar SpeedLock +3
        puntero:=dsk[drvnum].Tracks[0,0].data;
        cadena2:='SPEEDLOCK';
        cadena:='';
        for h:=0 to (dsk[drvnum].Tracks[0,0].sector[0].data_length-1) do begin
          cadena:=cadena+char(puntero^);
          inc(puntero);
        end;
        sp3_presente:=pos(cadena2,cadena)<>0;
        if ((sp3_presente) and not(hay_multi)) then begin
          //main_vars.mensaje_general:='SpeedLock +3 Simulated';
          dsk[drvnum].Tracks[0,0].sector[1].multi:=true;
          dsk[drvnum].cont_multi:=3;
          dsk[drvnum].max_multi:=3;
          //Ahora reago todos los datos
          getmem(ptemp3,dsk[drvnum].Tracks[0,0].track_lenght);
          ptemp:=ptemp3;
          //Guardo los viejos
          copymemory(ptemp,dsk[drvnum].Tracks[0,0].data,dsk[drvnum].Tracks[0,0].track_lenght);
          //Libero los datos antiguos
          freemem(dsk[drvnum].Tracks[0,0].data);
          dsk[drvnum].Tracks[0,0].data:=nil;
          //Creo los nuevos
          getmem(dsk[drvnum].Tracks[0,0].data,dsk[drvnum].Tracks[0,0].track_lenght+(dsk[drvnum].Tracks[0,0].sector[1].data_length*2));
          //Muevo el primer sector
          cont:=0;
          ptemp2:=dsk[drvnum].Tracks[0,0].data;
          copymemory(ptemp2,ptemp,dsk[drvnum].Tracks[0,0].sector[0].data_length);
          inc(ptemp,dsk[drvnum].Tracks[0,0].sector[0].data_length);
          inc(ptemp2,dsk[drvnum].Tracks[0,0].sector[0].data_length);
          inc(cont,dsk[drvnum].Tracks[0,0].sector[0].data_length);
          //Arreglo el segundo
          //Lo copio, pero dejo el puntero a los datos para copiar los 256 primeros bytes
          copymemory(ptemp2,ptemp,dsk[drvnum].Tracks[0,0].sector[1].data_length);
          inc(ptemp2,dsk[drvnum].Tracks[0,0].sector[1].data_length);
          inc(cont,dsk[drvnum].Tracks[0,0].sector[1].data_length);
          for f:=0 to 1 do begin
            //Copio los 256 primeros datos
            copymemory(ptemp2,ptemp,256);
            inc(ptemp2,256);
            //Me invento el resto
            for h:=0 to 255 do begin
              ptemp2^:=random(256);
              inc(ptemp2);
            end;
            inc(cont,dsk[drvnum].Tracks[0,0].sector[1].data_length);
          end;
          //Paso al sector 2
          inc(ptemp,dsk[drvnum].Tracks[0,0].sector[1].data_length);
          //Y los ultimos sectores arreglando la pos relativa dentro del track
          for f:=2 to (dsk[drvnum].Tracks[0,0].number_sector-1) do begin
            dsk[drvnum].Tracks[0,0].sector[f].posicion_data:=cont;
            copymemory(ptemp2,ptemp,dsk[drvnum].Tracks[0,0].sector[f].data_length);
            inc(ptemp,dsk[drvnum].Tracks[0,0].sector[f].data_length);
            inc(ptemp2,dsk[drvnum].Tracks[0,0].sector[f].data_length);
            inc(cont,dsk[drvnum].Tracks[0,0].sector[f].data_length);
          end;
          freemem(ptemp3);
        end;
      end;
   end;
end;

// CRC-CCITT used by the WD1793, including the three A1 sync bytes.
function oric_crc_byte(crc:word;value:byte):word;
var i:integer; c:cardinal;
begin
  c:=crc xor (word(value) shl 8);
  for i:=0 to 7 do begin
    if (c and $8000)<>0 then c:=(c shl 1) xor $1021
      else c:=c shl 1;
    c:=c and $ffff;
  end;
  oric_crc_byte:=word(c);
end;

function oric_decode_track(DrvNum,side,track:byte;raw:pbyte;raw_length:word):boolean;
var
  pos,j,k,n,count,total,data_pos,scan:integer;
  id:array[0..3] of byte;
  info:array[0..63] of sector_info_type;
  payload:array[0..6399] of byte;
  c:word;
  new_data,new_raw:pbyte;
  function rb(offset:integer):byte;
  begin
    rb:=raw[offset mod raw_length];
  end;
  function sync(offset:integer;mark:byte):boolean;
  begin
    sync:=(rb(offset)=$a1) and (rb(offset+1)=$a1) and
          (rb(offset+2)=$a1) and (rb(offset+3)=mark);
  end;
begin
  oric_decode_track:=false;
  if (DrvNum>High(dsk)) or (side>1) or (track>82) or (raw=nil) or (raw_length<16) or (raw_length>6400) then exit;
  fillchar(info,SizeOf(info),0);
  count:=0;
  total:=0;
  pos:=0;
  while pos<raw_length do begin
    if not sync(pos,$fe) then begin
      inc(pos);
      continue;
    end;
    if count>=64 then exit;
    for j:=0 to 3 do id[j]:=rb(pos+4+j);
    if id[3]>5 then exit;
    n:=128 shl id[3];
    // Look for the following DAM. Stop at a new IDAM.
    data_pos:=-1;
    scan:=pos+10;
    while scan<pos+raw_length do begin
      if sync(scan,$fe) then break;
      if sync(scan,$fb) or sync(scan,$f8) then begin
        data_pos:=scan+4;
        break;
      end;
      inc(scan);
    end;
    if data_pos<0 then begin
      inc(pos,10);
      continue;
    end;
    if (total+n>SizeOf(payload)) or (data_pos+n+2>pos+raw_length) then exit;
    with info[count] do begin
      track:=id[0];
      head:=id[1];
      sector:=id[2];
      sector_size:=id[3];
      status1:=rb(data_pos-1);
      data_length:=n;
      posicion_data:=total;
      raw_data_offset:=data_pos mod raw_length;
      id_crc:=(word(rb(pos+8)) shl 8) or rb(pos+9);
      data_crc:=(word(rb(data_pos+n)) shl 8) or rb(data_pos+n+1);
    end;
    c:=$ffff;
    for j:=0 to 7 do c:=oric_crc_byte(c,rb(pos+j));
    if c<>info[count].id_crc then info[count].status2:=1;
    c:=$ffff;
    for j:=data_pos-4 to data_pos+n-1 do c:=oric_crc_byte(c,rb(j));
    if c<>info[count].data_crc then info[count].status2:=info[count].status2 or 2;
    for k:=0 to n-1 do payload[total+k]:=rb(data_pos+k);
    inc(total,n);
    inc(count);
    pos:=data_pos+n+2;
  end;
  // Empty/unformatted tracks are valid and report RNF to sector commands.
  new_data:=nil; new_raw:=nil;
  if total>0 then begin
    getmem(new_data,total); copymemory(new_data,@payload[0],total);
  end;
  getmem(new_raw,raw_length); copymemory(new_raw,raw,raw_length);
  with dsk[DrvNum].Tracks[side,track] do begin
    if data<>nil then freemem(data);
    if raw_data<>nil then freemem(raw_data);
    fillchar(sector,SizeOf(sector),0);
    copymemory(@sector[0],@info[0],SizeOf(info));
    data:=new_data; raw_data:=new_raw;
    number_sector:=count; track_lenght:=total;
    side_number:=side;
    recording_mode:=2;
  end;
  dsk[DrvNum].Tracks[side,track].track_number:=track;
  dsk[DrvNum].Tracks[side,track].raw_length:=raw_length;
  oric_decode_track:=true;
end;

function oric_dsk_format(DrvNum:byte;longi_ini:dword;datos:pbyte):boolean;
var
  sides,tracks,geometry:cardinal;
  side,track,sec,n:integer;
  offset,required:int64;
  is_mfm,is_raw:boolean;
  c:word;
  id:array[0..7] of byte;
  function le32(offset:integer):cardinal;
  begin
    le32:=cardinal(datos[offset]) or (cardinal(datos[offset+1]) shl 8) or
          (cardinal(datos[offset+2]) shl 16) or (cardinal(datos[offset+3]) shl 24);
  end;
begin
  oric_dsk_format:=false;
  if (DrvNum>High(dsk)) or (datos=nil) or (longi_ini<256) then exit;
  is_mfm:=CompareMem(datos,PAnsiChar(AnsiString('MFM_DISK')),8);
  is_raw:=CompareMem(datos,PAnsiChar(AnsiString('ORICDISK')),8);
  if not (is_mfm or is_raw) then exit;
  sides:=le32(8); tracks:=le32(12); geometry:=le32(16);
  if (sides<1) or (sides>2) or (tracks<1) or (tracks>83) then exit;
  if is_mfm then begin
    if geometry<>1 then exit;
    required:=256+int64(6400)*sides*tracks;
  end else begin
    if (geometry<1) or (geometry>64) then exit;
    required:=256+int64(256)*geometry*sides*tracks;
    if geometry*256>65535 then exit;
  end;
  if required<>longi_ini then exit;
  clear_disk(DrvNum);
  dsk[DrvNum].DiskHeader.nbof_tracks:=tracks;
  dsk[DrvNum].DiskHeader.nbof_heads:=sides;
  offset:=256;
  for side:=0 to integer(sides)-1 do
    for track:=0 to integer(tracks)-1 do begin
      if is_mfm then begin
        if not oric_decode_track(DrvNum,side,track,@datos[offset],6400) then begin
          clear_disk(DrvNum); exit;
        end;
        inc(offset,6400);
      end else begin
        n:=geometry*256;
        with dsk[DrvNum].Tracks[side,track] do begin
          track_number:=track;
          side_number:=side;
          number_sector:=geometry;
          track_lenght:=n;
          recording_mode:=2;
          getmem(data,n);
          copymemory(data,@datos[offset],n);
        end;
        for sec:=0 to integer(geometry)-1 do begin
          with dsk[DrvNum].Tracks[side,track].sector[sec] do begin
            // Legacy ORICDISK has no IDs: synthesize conventional 1-based IDs.
            head:=side; sector:=sec+1; sector_size:=1;
            status1:=$fb; data_length:=256; posicion_data:=sec*256;
            id[0]:=$a1; id[1]:=$a1; id[2]:=$a1; id[3]:=$fe;
            id[4]:=dsk[DrvNum].Tracks[side,track].track_number;
            id[5]:=side;
            id[6]:=sec+1;
            id[7]:=1;
            c:=$ffff;
            for n:=0 to 7 do c:=oric_crc_byte(c,id[n]);
            id_crc:=c;
          end;
        end;
        for sec:=0 to integer(geometry)-1 do dsk[DrvNum].Tracks[side,track].sector[sec].track:=track;
        inc(offset,int64(geometry)*256);
      end;
    end;
  dsk[DrvNum].abierto:=true;
  dsk[DrvNum].protegido:=false;
  oric_dsk_format:=true;
end;

end.
