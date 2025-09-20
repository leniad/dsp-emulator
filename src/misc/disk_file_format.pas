unit disk_file_format;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}main_engine,misc_functions,dialogs;

function dsk_format(DrvNum:byte;longi_ini:dword;datos:pbyte):boolean;
procedure clear_disk(drvnum:byte);
procedure check_protections(drvnum:byte;hay_multi:boolean);
function oric_dsk_format(DrvNum:byte;longi_ini:dword;datos:pbyte):boolean;

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
  data_length:word;
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
var
  f,h,g:byte;
begin
  if not(dsk[drvnum].abierto) then exit;
  dsk[drvnum].cont_multi:=0;
  dsk[drvnum].max_multi:=0;
  for g:=0 to 1 do begin
   for f:=0 to dsk[drvnum].DiskHeader.nbof_tracks do begin
    dsk[drvnum].Tracks[g,f].track_number:=0;
    dsk[drvnum].Tracks[g,f].side_number:=0;
    dsk[drvnum].Tracks[g,f].data_rate:=0;
    dsk[drvnum].Tracks[g,f].sector_size:=0;
    dsk[drvnum].Tracks[g,f].GAP3:=0;
    dsk[drvnum].Tracks[g,f].track_lenght:=0;
    if dsk[drvnum].Tracks[g,f].data<>nil then begin
      freemem(dsk[drvnum].Tracks[g,f].data);
      dsk[drvnum].Tracks[g,f].data:=nil;
    end;
    for h:=0 to dsk[drvnum].Tracks[g,f].number_sector do begin
      dsk[drvnum].Tracks[g,f].sector[h].track:=0;
      dsk[drvnum].Tracks[g,f].sector[h].head:=0;
      dsk[drvnum].Tracks[g,f].sector[h].sector_size:=0;
      dsk[drvnum].Tracks[g,f].sector[h].status1:=0;
      dsk[drvnum].Tracks[g,f].sector[h].status2:=0;
      dsk[drvnum].Tracks[g,f].sector[h].data_length:=0;
      dsk[drvnum].Tracks[g,f].sector[h].posicion_data:=0;
      dsk[drvnum].Tracks[g,f].sector[h].sector:=0;
      dsk[drvnum].Tracks[g,f].sector[h].multi:=false;
      dsk[drvnum].Tracks[g,f].sector[h].posicion_data:=0;
    end;
    dsk[drvnum].Tracks[g,f].number_sector:=0;
   end;
  end;
    dsk[drvnum].abierto:=false;
    dsk[drvnum].DiskHeader.nbof_tracks:=0;
    dsk[drvnum].DiskHeader.nbof_heads:=0;
    dsk[drvnum].track_actual:=0;
    dsk[drvnum].cara_actual:=0;
    dsk[drvnum].sector_actual:=0;
    fillchar(dsk[drvnum].DiskHeader.track_size_table,408,0);
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

type
tmfm_header=record
  firma:array[0..7] of ansichar;
  side:dword;
  track:dword;
  sec_geo:dword;
  trash:array[0..235] of byte;
end;

tmfm_sector=record
  sync:array[0..14] of byte;
  info:byte;
  ntrack:byte;
  nside:byte;
  nsector:byte;
  nsector_size:byte;
  crc:word;
  sync2:array[0..21] of byte;
end;

function oric_dsk_format(DrvNum:byte;longi_ini:dword;datos:pbyte):boolean;
var
  mfm_header:^tmfm_header;
  mfm_sector:^tmfm_sector;
  puntero:pbyte;
  longi,track_long:integer;
  f,h,g:byte;
  wtemp:word;
  datos_track:array[0..6399] of byte;
  ptemp,ptemp2:pbyte;
begin
  oric_dsk_format:=false;
  if datos=nil then exit;
  getmem(mfm_header,sizeof(tmfm_header));
  getmem(mfm_sector,sizeof(tmfm_sector));
  clear_disk(drvnum);
  puntero:=datos;
  longi:=0;
  copymemory(mfm_header,datos,$100);
  inc(puntero,$100);inc(longi,$100);
  dsk[DrvNum].protegido:=false;
  if mfm_header.firma='MFM_DISK' then begin
    if mfm_header.sec_geo<>1 then begin
      MessageDlg('Geometria del disco<>1', mtInformation,[mbOk], 0);
      exit;
    end else begin
      dsk[drvnum].DiskHeader.nbof_tracks:=mfm_header.track;
      dsk[drvnum].DiskHeader.nbof_heads:=mfm_header.side;
      getmem(ptemp,6400);
      f:=0;
      g:=0;
      while (longi<longi_ini) do begin
        //pillo los datos del track, con sus sectores...
        wtemp:=0;
        copymemory(@datos_track,puntero,6400);
        inc(puntero,6400);
        inc(longi,6400);
        ptemp2:=ptemp;
        track_long:=0;
        h:=0;
        //La informacion del track
        if datos_track[40+wtemp]=0 then inc(wtemp,96) //formato Sedoric
            else inc(wtemp,146); //formato IBM
        //Leo los sectores
        while (wtemp<6400) do begin
          copymemory(mfm_sector,@datos_track[wtemp],44);
          wtemp:=wtemp+44;
          //Algunos checks...
          if mfm_sector.nside>mfm_header.side then exit;
          if mfm_sector.ntrack>mfm_header.track then exit;
          //Status del sector (borrado, normal, etc)
          dsk[drvnum].Tracks[f,g].sector[h].status1:=mfm_sector.info;
          dsk[drvnum].Tracks[f,g].sector[h].track:=mfm_sector.ntrack;
          dsk[drvnum].Tracks[f,g].sector[h].head:=mfm_sector.nside;
          dsk[drvnum].Tracks[f,g].sector[h].sector:=mfm_sector.nsector;
          dsk[drvnum].Tracks[f,g].sector[h].sector_size:=mfm_sector.nsector_size;
          dsk[drvnum].Tracks[f,g].sector[h].data_length:=mfm_sector.crc;
          //Le añado 16 bytes y ya estoy en los datos...
          wtemp:=wtemp+16;
          //Posicion de los datos...
          dsk[drvnum].Tracks[f,g].sector[h].posicion_data:=track_long;
          case mfm_sector.nsector_size of
            1:begin //256b
                copymemory(ptemp2,@datos_track[wtemp],256);
                wtemp:=wtemp+256;
                track_long:=track_long+256;
              end;
            2:begin //512b
                copymemory(ptemp2,@datos_track[wtemp],512);
                wtemp:=wtemp+512;
                track_long:=track_long+512;
              end;
          end;
          wtemp:=wtemp+2;
          while datos_track[wtemp]=$4e do wtemp:=wtemp+1;
          h:=h+1;
        end;
        dsk[drvnum].Tracks[f,g].number_sector:=h;
        dsk[drvnum].Tracks[f,g].track_lenght:=track_long;
        getmem(dsk[drvnum].Tracks[f,g].data,track_long);
        copymemory(dsk[drvnum].Tracks[f,g].data,ptemp,track_long);
        g:=g+1;
        if g=mfm_header.track then begin
          g:=0;
          f:=f+1;
        end;
      end;
      freemem(ptemp);
    end;
  end else if mfm_header.firma='ORICDISK' then begin
      //Este es fijo... Todo va segido y se asume que cada sector es de 256bytes
      dsk[drvnum].DiskHeader.nbof_tracks:=mfm_header.track;
      dsk[drvnum].DiskHeader.nbof_heads:=mfm_header.side;
      //caras
      for f:=0 to mfm_header.side-1 do begin
        //pistas
        for g:=0 to mfm_header.track-1 do begin
          track_long:=256*mfm_header.sec_geo;
          dsk[drvnum].Tracks[f,g].track_lenght:=track_long;
          getmem(dsk[drvnum].Tracks[f,g].data,track_long);
          copymemory(dsk[drvnum].Tracks[f,g].data,puntero,track_long);
          inc(puntero,track_long);
          inc(longi,track_long);
          dsk[drvnum].Tracks[f,g].number_sector:=mfm_header.sec_geo;
          //sectores
          for h:=0 to (mfm_header.sec_geo-1) do begin
            dsk[drvnum].Tracks[f,g].sector[h].track:=g;
            dsk[drvnum].Tracks[f,g].sector[h].head:=f;
            dsk[drvnum].Tracks[f,g].sector[h].sector:=h;
            dsk[drvnum].Tracks[f,g].sector[h].sector_size:=1;
            dsk[drvnum].Tracks[f,g].sector[h].posicion_data:=256*h;
          end;
        end;
      end;
  end else exit;
  freemem(mfm_header);
  freemem(mfm_sector);
  dsk[drvnum].abierto:=true;
  oric_dsk_format:=true;
end;

end.
