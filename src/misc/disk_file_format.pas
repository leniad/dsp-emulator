unit disk_file_format;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}main_engine,ipf_disk;

function dsk_format(DrvNum:byte;longi_ini:dword;datos:pbyte):boolean;
function ipf_format(DrvNum:byte;longi_ini:dword;datos:pbyte):boolean;
procedure clear_disk(drvnum:byte);

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
  multi:boolean;
  data_multi:array[0..4] of pbyte;
  cont_multi,pos_multi:byte;
  status1:byte;
  status2:byte;
  data_length:word;
  posicion_data:word;
end;
track_type=record
  track_number:byte;
  side_number:byte;
  data_rate:byte;
  recording_mode:byte;
  sector_size:byte;
  number_sector:byte;
  GAP3:byte;
  track_lenght:word;
  data:pbyte;
  sector:array[0..28] of sector_info_type;
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
  Tracks:array[0..1,0..79] of track_type;
end;

var
  dsk:array[0..1] of DskImg;

implementation
uses principal,sysutils;

function dsk_format(DrvNum:byte;longi_ini:dword;datos:pbyte):boolean;
var
  puntero,sp3,ptemp,ptemp2:pbyte;
  h:word;
  cadena,cadena2:string;
  longi:dword;
  estandar,hay_multi,rehacer_multi,sp3_presente:boolean;
  posicion,tempw:word;
  cara,track,f:byte;
begin
   dsk_format:=false;
   if datos=nil then exit;
   clear_disk(drvnum);
   puntero:=datos;
   longi:=0;
   hay_multi:=false;
   rehacer_multi:=false;
   dsk[DrvNum].protegido:=false;
   //Disk Header
   for h:=0 to 7 do begin
       cadena:=cadena+char(puntero^);
       inc(puntero);inc(longi);
   end;
   estandar:=(cadena='MV - CPC');
   dsk[DrvNum].extended:=not(estandar);
   if ((cadena='EXTENDED') or estandar) then begin
    inc(puntero,40);inc(longi,40);
    dsk[drvnum].DiskHeader.nbof_tracks:=puntero^;
    inc(puntero);inc(longi);
    dsk[drvnum].DiskHeader.nbof_heads:=puntero^;
    inc(puntero,3);inc(longi,3);
    copymemory(@dsk[DrvNum].DiskHeader.track_size_table[0],puntero,204);
    inc(puntero,204);inc(longi,204);
    //Disk Tracks
    cadena:=char(puntero^);
    inc(puntero);inc(longi);
    cadena2:=char(puntero^);
    if ((cadena<>'T') or (cadena2<>'r')) then exit;
    while longi<longi_ini do begin
      if longi>longi_ini then break;
      cadena:=char(puntero^);
      inc(puntero);inc(longi);
      for h:=0 to 7 do begin
        cadena:=cadena+char(puntero^);
        inc(puntero);inc(longi);
      end;
      if cadena<>'rack-Info' then begin
        clear_disk(drvnum);
        exit;
      end;
      inc(puntero,6);inc(longi,6);
      track:=puntero^;
      inc(puntero);inc(longi);
      cara:=puntero^;
      inc(puntero);inc(longi);
      dsk[DrvNum].Tracks[cara,track].track_number:=track;
      dsk[DrvNum].Tracks[cara,track].side_number:=cara;
      dsk[DrvNum].Tracks[cara,track].data_rate:=puntero^;
      inc(puntero);inc(longi);
      dsk[DrvNum].Tracks[cara,track].recording_mode:=puntero^;
      inc(puntero);inc(longi);
      dsk[DrvNum].Tracks[cara,track].sector_size:=puntero^;
      inc(puntero);inc(longi);
      dsk[DrvNum].Tracks[cara,track].number_sector:=puntero^;
      inc(puntero);inc(longi);
      dsk[DrvNum].Tracks[cara,track].GAP3:=puntero^;
      inc(puntero,2);inc(longi,2);
      posicion:=0;
      if dsk[drvnum].Tracks[cara,track].number_sector<>0 then begin
        for h:=0 to dsk[drvnum].Tracks[cara,track].number_sector-1 do begin
          dsk[drvnum].Tracks[cara,track].sector[h].track:=puntero^;
          inc(puntero);inc(longi);
          dsk[drvnum].Tracks[cara,track].sector[h].head:=puntero^;
          inc(puntero);inc(longi);
          dsk[drvnum].Tracks[cara,track].sector[h].sector:=puntero^;
          inc(puntero);inc(longi);
          dsk[drvnum].Tracks[cara,track].sector[h].sector_size:=puntero^;
          inc(puntero);inc(longi);
          dsk[drvnum].Tracks[cara,track].sector[h].status1:=puntero^;
          inc(puntero);inc(longi);
          dsk[drvnum].Tracks[cara,track].sector[h].status2:=puntero^;
          inc(puntero);inc(longi);
          if not(estandar) then begin
            dsk[drvnum].Tracks[cara,track].sector[h].data_length:=puntero^;
            inc(puntero);inc(longi);
            dsk[drvnum].Tracks[cara,track].sector[h].data_length:=dsk[drvnum].Tracks[cara,track].sector[h].data_length+(puntero^*256);
            inc(puntero);inc(longi);
          end else begin
            dsk[drvnum].Tracks[cara,track].sector[h].data_length:=1 shl (dsk[drvnum].Tracks[cara,track].sector[h].sector_size+7);
            inc(puntero,2);inc(longi,2);
          end;
          dsk[drvnum].Tracks[cara,track].sector[h].posicion_data:=posicion;
          inc(posicion,dsk[drvnum].Tracks[cara,track].sector[h].data_length);
          //Weak sectors
          dsk[drvnum].Tracks[cara,track].sector[h].cont_multi:=0;
          tempw:=dsk[drvnum].Tracks[cara,track].sector[h].data_length div (1 shl (dsk[drvnum].Tracks[cara,track].sector[h].sector_size+7));
          if (tempw>1) then begin
            if tempw>5 then exit;
            dsk[drvnum].Tracks[cara,track].sector[h].multi:=true;
            dsk[drvnum].Tracks[cara,track].sector[h].cont_multi:=tempw;
            hay_multi:=true;
            rehacer_multi:=true;
          end;
        end;
      end;
        inc(puntero,8*(29-dsk[drvnum].Tracks[cara,track].number_sector));
        inc(longi,8*(29-dsk[drvnum].Tracks[cara,track].number_sector));
        if dsk[DrvNum].DiskHeader.track_size_table[cara,track]<>0 then begin
          dsk[drvnum].Tracks[cara,track].track_lenght:=256*(dsk[DrvNum].DiskHeader.track_size_table[cara,track]-1);
        end else begin
          dsk[drvnum].Tracks[cara,track].track_lenght:=0;
          if dsk[drvnum].Tracks[cara,track].number_sector<>0 then begin
            for h:=0 to dsk[drvnum].Tracks[cara,track].number_sector-1 do begin
              dsk[drvnum].Tracks[cara,track].sector[h].posicion_data:=dsk[drvnum].Tracks[cara,track].track_lenght;
              inc(dsk[drvnum].Tracks[cara,track].track_lenght,dsk[drvnum].Tracks[cara,track].sector[h].data_length)
            end;
          end;
        end;
        getmem(dsk[drvnum].Tracks[cara,track].data,dsk[drvnum].Tracks[cara,track].track_lenght);
        copymemory(dsk[drvnum].Tracks[cara,track].data,puntero,dsk[drvnum].Tracks[cara,track].track_lenght);
        inc(puntero,dsk[drvnum].Tracks[cara,track].track_lenght);
        inc(longi,dsk[drvnum].Tracks[cara,track].track_lenght);
        if rehacer_multi then begin
          for h:=0 to dsk[drvnum].Tracks[cara,track].number_sector-1 do begin
            if dsk[drvnum].Tracks[cara,track].sector[h].multi then break;
          end;
          for f:=0 to 3 do getmem(dsk[drvnum].Tracks[cara,track].sector[h].data_multi[f],(1 shl (dsk[drvnum].Tracks[cara,0].sector[1].sector_size+7))*3);
          ptemp:=dsk[drvnum].Tracks[cara,track].data;
          for f:=0 to (h-1) do inc(ptemp,(1 shl (dsk[drvnum].Tracks[cara,track].sector[h].sector_size+7)));
          for f:=0 to (dsk[drvnum].Tracks[cara,track].sector[h].cont_multi-1) do begin
            copymemory(dsk[drvnum].Tracks[cara,track].sector[h].data_multi[f],ptemp,(1 shl (dsk[drvnum].Tracks[cara,track].sector[h].sector_size+7)));
            inc(ptemp,(1 shl (dsk[drvnum].Tracks[cara,track].sector[h].sector_size+7)));
          end;
          dsk[drvnum].Tracks[cara,track].sector[h].pos_multi:=dsk[drvnum].Tracks[cara,track].sector[h].cont_multi;
          rehacer_multi:=false;
        end;
        while ((cadena<>'T') or (cadena2<>'r')) do begin
          cadena:=char(puntero^);
          inc(puntero);
          inc(longi);
          cadena2:=char(puntero^);
          if ((cadena='O') and (cadena2='f')) then begin
            longi:=longi_ini;
            break;
          end;
          if longi>longi_ini then begin
            dec(puntero);
            dec(longi);
            break;
          end;
        end;
    end;
   end else begin
       exit;
   end;
   //Comprobar SpeedLock +3
   if (main_vars.tipo_maquina=2) then begin
    sp3:=dsk[drvnum].Tracks[cara,0].data;
    cadena2:='SPEEDLOCK';
    cadena:='';
    for h:=0 to 511 do begin
      cadena:=cadena+char(sp3^);
      inc(sp3);
    end;
    sp3_presente:=pos(cadena2,cadena)<>0;
    if ((sp3_presente) and not(hay_multi)) then begin
      main_vars.mensaje_general:='SpeedLock +3 Simulated';
      dsk[drvnum].Tracks[cara,0].sector[1].multi:=true;
      //Empiezo con 3, y al sumar 1 termina empezando en 0
      dsk[drvnum].Tracks[cara,0].sector[1].cont_multi:=3;
      for f:=0 to 3 do getmem(dsk[drvnum].Tracks[cara,0].sector[1].data_multi[f],(1 shl (dsk[drvnum].Tracks[cara,0].sector[1].sector_size+7))*3);
      //Primera copia
      ptemp2:=dsk[drvnum].Tracks[cara,0].data;
      inc(ptemp2,(1 shl (dsk[drvnum].Tracks[cara,0].sector[0].sector_size+7)));
      copymemory(dsk[drvnum].Tracks[cara,0].sector[1].data_multi[0],ptemp2,(1 shl (dsk[drvnum].Tracks[cara,0].sector[1].sector_size+7)));
      //Resto de sectores con parte aleatoria
      for f:=0 to 1 do begin
        ptemp:=dsk[drvnum].Tracks[cara,0].sector[1].data_multi[f];
        copymemory(ptemp,ptemp2,256);
        inc(ptemp,256);
        for h:=0 to 255 do begin
          ptemp^:=random(256);
          inc(ptemp);
        end;
      end;
    end else main_vars.mensaje_general:='';
   end;
   dsk[drvnum].abierto:=true;
   dsk_format:=true;
end;

procedure clear_disk(drvnum:byte);
var
  f,h,g,i:byte;
begin
  main_vars.mensaje_general:='';
  if not(dsk[drvnum].abierto) then exit;
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
      for i:=0 to 4 do if dsk[drvnum].Tracks[g,f].sector[h].data_multi[i]<>nil then begin
        freemem(dsk[drvnum].Tracks[g,f].sector[h].data_multi[i]);
        dsk[drvnum].Tracks[g,f].sector[h].data_multi[i]:=nil;
      end;
      dsk[drvnum].Tracks[g,f].sector[h].multi:=false;
      dsk[drvnum].Tracks[g,f].sector[h].pos_multi:=0;
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

function ipf_format(DrvNum:byte;longi_ini:dword;datos:pbyte):boolean;
var
  id,error:SDWORD;
  info:PCAPSIMAGEINFO;
  track:PCAPSTRACKINFO;
begin
  ipf_format:=false;
  if not(init_ipf_dll) then exit;
  //Cargar IPF
  CAPSInit;
  id:=CAPSAddImage;
  error:=CAPSLockImageMemory(id,datos,longi_ini,DI_LOCK_MEMREF);
  if error<>0 then exit;
  getmem(info,sizeof(CapsImageInfo));
  CAPSGetImageInfo(info,id);
  //form1.statusbar1.panels[2].text:=inttostr(info.type_);
  //error:=CAPSLoadImage(id,DI_LOCK_DENVAR);
  //if error<>0 then exit;
  getmem(track,sizeof(CapsTrackInfo));
  CAPSLockTrack(track,id,0,0,DI_LOCK_DENVAR);
  principal1.statusbar1.panels[2].text:=inttostr(track.type_);
  //cerrar
  freemem(track);
  freemem(info);
  CAPSUnlockAllTracks(id);
  CAPSUnlockImage(id);
  CAPSRemImage(id);
  CAPSExit;
  close_ipf_dll;
end;

end.