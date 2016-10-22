unit ipf_disk;

interface
uses {$ifdef windows}windows,{$else}main_engine,{$endif}dialogs;

function ipf_format(DrvNum:byte;longi_ini:dword;datos:pbyte):boolean;

implementation
uses disk_file_format;

type

tipf_header=packed record
    name:array[0..3] of ansichar;
    size:dword;
    crc32:dword;
  end;

tipf_info=packed record
    mediaType:dword;
    encoderType:dword;
    encoderRev:dword;
    fileKey:dword;
    fileRev:dword;
    origin:dword;
    minTrack:dword;
    maxTrack:dword;
    minSide:dword;
    maxSide:dword;
    creationDate:dword;
    creationTime:dword;
    platforms:dword;
    diskNumber:dword;
    creatorId:dword;
    reserved:array[0..5] of dword;
  end;

tipf_imge=packed record
    track:dword;
    side:dword;
    density:dword;
    signatType:dword;
    trackBytes:dword;
    startBytePos:dword;
    startBitPos:dword;
    dataBits:dword;
    gapBits:dword;
    trackBits:dword;
    blockCount:dword;
    encoderProcess:dword;
    trackFlags:dword;
    dataKey:dword;
    reserved:array[0..2] of dword;
  end;

tipf_data=packed record
    lenghtExtra:dword;
    bitSize:dword;
    crc:dword;
    dataKey:dword;
  end;

tipf_block=packed record
    dataBits:dword;
    gapBits:dword;
    gapOffset:dword;
    cellType:dword;
    encoderType:dword;
    blockFlags:dword;
    gapDefault:dword;
    dataOffset:dword;
  end;

function big_to_little(val:dword):dword;
var
  res:dword;
begin
  res:=(val shr 24) or ((val shr 8) and $ff00) or ((val shl 8) and $ff0000) or ((val and $ff) shl 24);
  big_to_little:=res;
end;

function ipf_format(DrvNum:byte;longi_ini:dword;datos:pbyte):boolean;
var
  ipf_header:^tipf_header;
  ipf_info:^tipf_info;
  ipf_imge:^tipf_imge;
  ipf_data:^tipf_data;
  ipf_block:^tipf_block;
  buffer_data,buffer_temp,buffer_temp2,track_data_temp,track_data_temp2:pbyte;
  imge_data:array[0..1,0..82] of ^tipf_imge;
  f,side_number,track_number,dataHead,dataSizeWidth,dataType:byte;
  posicion,posicion_data_sector,dataLenght,total_sectores:dword;
  g,sector_count:integer;
  track_found,salir:boolean;
begin
  ipf_format:=false;
  if datos=nil then exit;
  clear_disk(drvnum);
  for track_number:=0 to 82 do begin
    imge_data[0,track_number]:=nil;
    imge_data[1,track_number]:=nil;
  end;
  getmem(ipf_header,sizeof(tipf_header));
  copymemory(ipf_header,datos,12);posicion:=12;
  inc(datos,12);
  getmem(track_data_temp,$10000);
  while posicion<longi_ini do begin
    copymemory(ipf_header,datos,12);
    ipf_header.size:=big_to_little(ipf_header.size)-12;
    inc(datos,12);
    inc(posicion,12);
    if ipf_header.name='INFO' then begin
      getmem(ipf_info,sizeof(tipf_info));
      copymemory(ipf_info,datos,sizeof(tipf_info));
      ipf_info.maxTrack:=big_to_little(ipf_info.maxTrack);
      ipf_info.maxSide:=big_to_little(ipf_info.maxSide);
      dsk[drvnum].DiskHeader.nbof_tracks:=ipf_info.maxTrack;
      dsk[drvnum].DiskHeader.nbof_heads:=ipf_info.maxSide;
      freemem(ipf_info);
      inc(datos,ipf_header.size);
      inc(posicion,ipf_header.size);
    end;
    if ipf_header.name='IMGE' then begin
      getmem(ipf_imge,sizeof(tipf_imge));
      copymemory(ipf_imge,datos,sizeof(tipf_imge));
      ipf_imge.track:=big_to_little(ipf_imge.track);
      ipf_imge.side:=big_to_little(ipf_imge.side);
      ipf_imge.blockCount:=big_to_little(ipf_imge.blockCount);
      ipf_imge.dataKey:=big_to_little(ipf_imge.dataKey);
      getmem(imge_data[ipf_imge.side,ipf_imge.track],sizeof(tipf_imge));
      copymemory(imge_data[ipf_imge.side,ipf_imge.track],ipf_imge,sizeof(tipf_imge));
      freemem(ipf_imge);
      inc(datos,ipf_header.size);
      inc(posicion,ipf_header.size);
    end;
    if ipf_header.name='DATA' then begin
      getmem(ipf_data,sizeof(tipf_data));
      copymemory(ipf_data,datos,sizeof(tipf_data));
      ipf_data.lenghtExtra:=big_to_little(ipf_data.lenghtExtra);
      ipf_data.dataKey:=big_to_little(ipf_data.dataKey);
      inc(datos,ipf_header.size);
      inc(posicion,ipf_header.size);
      //Continuo si tengo datos extra...
      getmem(buffer_data,ipf_data.lenghtExtra);
      copymemory(buffer_data,datos,ipf_data.lenghtExtra);
      inc(datos,ipf_data.lenghtExtra);
      inc(posicion,ipf_data.lenghtExtra);
      //Ya he llegado, ahora hago cosas con los datos!
      //Primero busco la informacion del track, relacionando el dataKey de los dos
      track_found:=false;
      for side_number:=0 to dsk[drvnum].DiskHeader.nbof_heads do begin
           for track_number:=0 to dsk[drvnum].DiskHeader.nbof_tracks do begin
               if imge_data[side_number,track_number]<>nil then begin
                  if imge_data[side_number,track_number].dataKey=ipf_data.dataKey then track_found:=true;
               end;
               if track_found then break;
           end;
           if track_found then break;
      end;
      //Vale, ya tengo los datos del track
      if track_found then begin
          dsk[DrvNum].Tracks[side_number,track_number].track_number:=imge_data[side_number,track_number].track;
          dsk[DrvNum].Tracks[side_number,track_number].side_number:=imge_data[side_number,track_number].side;
          buffer_temp:=buffer_data;
          //Primero copio el bloque que hay dentro de los datos
          getmem(ipf_block,sizeof(tipf_block));
          posicion_data_sector:=0;
          total_sectores:=0;
          for sector_count:=0 to (imge_data[side_number,track_number].blockCount-1) do begin
            copymemory(ipf_block,buffer_temp,sizeof(tipf_block));
            //Donde empiezan los datos??
            ipf_block.dataOffset:=big_to_little(ipf_block.dataOffset);
            //OK, me voy a por los datos
            buffer_temp2:=buffer_data;
            inc(buffer_temp2,ipf_block.dataOffset);
            //Ya estoy apuntando a los datos, analizo lo que hay...
            salir:=false;
            while not(salir) do begin
              dataHead:=buffer_temp2^;inc(buffer_temp2);
              if dataHead=0 then salir:=true
                else begin
                  dataSizeWidth:=dataHead shr 5;
                  dataType:=dataHead and $1f;
                  dataLenght:=0;
                  for f:=0 to (dataSizeWidth-1) do begin
                    dataLenght:=dataLenght+(buffer_temp2^ shl (8*(dataSizeWidth-1-f)));
                    inc(buffer_temp2);
                  end;
                  case dataType of
                    1:begin //Sync...
                        track_data_temp2:=track_data_temp;
                        inc(track_data_temp2,posicion_data_sector);
                        copymemory(track_data_temp2,buffer_temp2,dataLenght);
                        posicion_data_sector:=posicion_data_sector+dataLenght;
                        inc(buffer_temp2,dataLenght);
                      end;
                    2:begin  //Datos... ESTOS SI!
                        case buffer_temp2^ of
                          $fc:begin //la informacion del track
                                track_data_temp2:=track_data_temp;
                                inc(track_data_temp2,posicion_data_sector);
                                copymemory(track_data_temp2,buffer_temp2,dataLenght);
                                posicion_data_sector:=posicion_data_sector+dataLenght;
                                inc(buffer_temp2,dataLenght);
                              end;
                          $fe,$ff:begin  //informacion del sector (numero, trac, size)
                                track_data_temp2:=track_data_temp;
                                inc(track_data_temp2,posicion_data_sector);
                                copymemory(track_data_temp2,buffer_temp2,dataLenght);
                                posicion_data_sector:=posicion_data_sector+dataLenght;
                                //IDAM data, deberia ser algo entre $FF y $FC, estandar $FE
                                inc(buffer_temp2);
                                dsk[drvnum].Tracks[side_number,track_number].sector[total_sectores].track:=buffer_temp2^;
                                inc(buffer_temp2);
                                dsk[drvnum].Tracks[side_number,track_number].sector[total_sectores].head:=buffer_temp2^;
                                inc(buffer_temp2);
                                dsk[drvnum].Tracks[side_number,track_number].sector[total_sectores].sector:=buffer_temp2^;
                                inc(buffer_temp2);
                                dsk[drvnum].Tracks[side_number,track_number].sector[total_sectores].sector_size:=buffer_temp2^;
                                inc(buffer_temp2);
                                inc(buffer_temp2,dataLenght-5); //CRC data
                            end;
                          $f8..$fb:begin //contenido del sector
                                dsk[drvnum].Tracks[side_number,track_number].sector[total_sectores].posicion_data:=posicion_data_sector+1;
                                //Copio los datos en un buffer temporal...
                                track_data_temp2:=track_data_temp;
                                inc(track_data_temp2,posicion_data_sector);
                                //DAM o DDAM Data
                                //Si es $FA o $FB track normal, si es $F8 o $F9 track borrado
                                dsk[drvnum].Tracks[side_number,track_number].sector[total_sectores].status2:=(not(buffer_temp2^) and $2) shl 5;
                                copymemory(track_data_temp2,buffer_temp2,dataLenght);
                                inc(posicion_data_sector,dataLenght);
                                dsk[drvnum].Tracks[side_number,track_number].sector[total_sectores].data_length:=dataLenght-3;
                                inc(buffer_temp2,dataLenght);
                                total_sectores:=total_sectores+1;
                                track_data_temp2:=track_data_temp;
                                inc(track_data_temp2,posicion_data_sector);
                                for f:=0 to 79 do begin
                                    track_data_temp2^:=$f7;
                                    inc(track_data_temp2);
                                    inc(posicion_data_sector);
                                end;
                            end;
                            else begin
                                    track_data_temp2:=track_data_temp;
                                    inc(track_data_temp2,posicion_data_sector);
                                    copymemory(track_data_temp2,buffer_temp2,dataLenght);
                                    posicion_data_sector:=posicion_data_sector+dataLenght;
                                    inc(buffer_temp2,dataLenght);
                            end;
                        end;
                    end;
                    3:begin //InterGAP...
                        track_data_temp2:=track_data_temp;
                        inc(track_data_temp2,posicion_data_sector);
                        copymemory(track_data_temp2,buffer_temp2,dataLenght);
                        posicion_data_sector:=posicion_data_sector+dataLenght;
                        inc(buffer_temp2,dataLenght);
                    end;
                    4:MessageDlg('GAP data found in data section!', mtInformation,[mbOk], 0);
                    5:begin //Sectores debiles... Tengo toda la informacion del sector, excepto los datos, que me los invento
                        //Me posiciono en los datos del sector
                        track_data_temp2:=track_data_temp;
                        inc(track_data_temp2,posicion_data_sector);
                        dsk[drvnum].Tracks[side_number,track_number].sector[total_sectores-1].status1:=$20;
                        dsk[drvnum].Tracks[side_number,track_number].sector[total_sectores-1].status2:=$20;
                        dsk[drvnum].Tracks[side_number,track_number].sector[total_sectores-1].data_length:=dataLenght*3;
                        dsk[drvnum].Tracks[side_number,track_number].sector[total_sectores-1].multi:=true;
                        dsk[drvnum].cont_multi:=3;
                        dsk[drvnum].max_multi:=3;
                        inc(posicion_data_sector,dataLenght*3);
                        for f:=0 to 2 do begin
                          for g:=0 to ((dataLenght shr 1)-1) do begin
                            track_data_temp2^:=$e5;
                            inc(track_data_temp2);
                          end;
                          for g:=0 to ((dataLenght shr 1)-1) do begin
                            track_data_temp2^:=random(256);
                            inc(track_data_temp2);
                          end;
                        end;
                      end;
                  end;
                end;
            end;
            inc(buffer_temp,sizeof(tipf_block));
          end;
          freemem(ipf_block);
      end else MessageDlg('There is IMGE but no track DATA found!', mtInformation,[mbOk], 0);
      //Vale, ya tengo todos los datos del track...
      dsk[DrvNum].Tracks[side_number,track_number].number_sector:=total_sectores;
      getmem(dsk[drvnum].Tracks[side_number,track_number].data,posicion_data_sector);
      copymemory(dsk[drvnum].Tracks[side_number,track_number].data,track_data_temp,posicion_data_sector);
      dsk[drvnum].Tracks[side_number,track_number].track_lenght:=posicion_data_sector;
      freemem(buffer_data);
      freemem(ipf_data);
    end;
  end;
  //check_protections(drvnum,false);
  dsk[drvnum].abierto:=true;
  freemem(ipf_header);
  freemem(track_data_temp);
  ipf_format:=true;
end;


end.
