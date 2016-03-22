unit upd765;

interface
uses sysutils,{$IFDEF WINDOWS}windows,{$ENDIF}dialogs;

var
  FloppyMotor:byte;
  FDCCurrDrv:byte;
  ExecCmdPhase:boolean;
  ResultPhase:boolean;
  StatusRegister:byte;
  st0,st1,st2,st3:byte;
  contador_status,contador_read_status:byte;

  FDCCommand:array[0..8] of byte;
  FDCResult:array[0..6] of byte;
  FDCPointer:word;
  FDCCmdPointer:word;
  FDCResPointer:word;
  FDCResCounter:word;
  FDCDataPointer:word;
  FDCDataLength:word;
  FDCCounter:word;
  SeekTrack:boolean;
  Mostrar_disco:boolean;
  bytes_in_cmd: array[0..31] of byte = (
  1,1,9,3,2,9,9,2,1,9,2,1,9,6,1,3,1,9,1,1,1,1,1,1,1,9,1,1,1,1,9,1);

procedure WriteFDCData(value:byte);
function ReadFDCStatus:byte;
function ReadFDCData:byte;
procedure ResetFDC;

implementation
uses principal,disk_file_format;

procedure GetRes7;
begin
    FDCResult[0]:=st0;
    FDCResult[1]:=st1;
    FDCResult[2]:=st2;
    FDCResult[3]:=dsk[FDCCurrDrv].Tracks[dsk[FDCCurrDrv].cara_actual,dsk[FDCCurrDrv].track_actual].sector[dsk[FDCCurrDrv].sector_actual].track;
    FDCResult[4]:=dsk[FDCCurrDrv].Tracks[dsk[FDCCurrDrv].cara_actual,dsk[FDCCurrDrv].track_actual].sector[dsk[FDCCurrDrv].sector_actual].head;
    FDCResult[5]:=dsk[FDCCurrDrv].Tracks[dsk[FDCCurrDrv].cara_actual,dsk[FDCCurrDrv].track_actual].sector[dsk[FDCCurrDrv].sector_actual].sector;
    FDCResult[6]:=dsk[FDCCurrDrv].Tracks[dsk[FDCCurrDrv].cara_actual,dsk[FDCCurrDrv].track_actual].sector[dsk[FDCCurrDrv].sector_actual].sector_size;
    StatusRegister:=$D0;
    FDCResPointer:=0;
    FDCResCounter:=7;
    st0:=0;
    st1:=0;
    st2:=0;
    ExecCmdPhase:=FALSE;
    ResultPhase:=TRUE;
 end;

function buscar_sector:boolean;
var
  index_count:byte;
begin
buscar_sector:=false;
if dsk[FDCCurrDrv].Tracks[dsk[FDCCurrDrv].cara_actual,dsk[FDCCurrDrv].track_actual].number_sector=0 then begin
  buscar_sector:=TRUE;
  exit;
end;
index_count:=0;
while (index_count<>2) do begin
    if (dsk[FDCCurrDrv].sector_actual+1)>dsk[FDCCurrDrv].Tracks[dsk[FDCCurrDrv].cara_actual,dsk[FDCCurrDrv].track_actual].number_sector then begin
      dsk[FDCCurrDrv].sector_actual:=0;
      index_count:=index_count+1;
    end;
		if (dsk[FDCCurrDrv].Tracks[dsk[FDCCurrDrv].cara_actual,dsk[FDCCurrDrv].track_actual].sector[dsk[FDCCurrDrv].sector_actual].sector=FDCCommand[4]) then begin
			if (dsk[FDCCurrDrv].Tracks[dsk[FDCCurrDrv].cara_actual,dsk[FDCCurrDrv].track_actual].sector[dsk[FDCCurrDrv].sector_actual].track=FDCCommand[2]) then begin
				if (dsk[FDCCurrDrv].Tracks[dsk[FDCCurrDrv].cara_actual,dsk[FDCCurrDrv].track_actual].sector[dsk[FDCCurrDrv].sector_actual].head=FDCCommand[3]) then begin
					//if (dsk[FDCCurrDrv].Tracks[dsk[FDCCurrDrv].cara_actual,dsk[FDCCurrDrv].track_actual].sector[dsk[FDCCurrDrv].sector_actual].sector_size=FDCCommand[5]) then begin
						if (FDCCommand[4]=FDCCommand[6]) then st1:=st1 or $80;// set end of cylinder */
            st1:=st1 or (dsk[FDCCurrDrv].Tracks[dsk[FDCCurrDrv].cara_actual,dsk[FDCCurrDrv].track_actual].sector[dsk[FDCCurrDrv].sector_actual].status1 and $20);
            st2:=st2 or (dsk[FDCCurrDrv].Tracks[dsk[FDCCurrDrv].cara_actual,dsk[FDCCurrDrv].track_actual].sector[dsk[FDCCurrDrv].sector_actual].status1 and $60);
						buscar_sector:=TRUE;
            exit;
          end else begin
            buscar_sector:=TRUE;
            st1:=st1 or $80;
            exit;
          end;
				//end;
			end else begin
				st1:=st1 or $4; //NEC765_ST1_NO_DATA
				st2:=st2 or $10; //NEC765_ST2_WRONG_CYLINDER
				if (dsk[FDCCurrDrv].Tracks[dsk[FDCCurrDrv].cara_actual,dsk[FDCCurrDrv].track_actual].sector[dsk[FDCCurrDrv].sector_actual].track=$ff) then st2:=st2 or $2; //NEC765_ST2_BAD_CYLINDER
        buscar_sector:=true;
        exit;
			end;
		end;
    dsk[FDCCurrDrv].sector_actual:=dsk[FDCCurrDrv].sector_actual+1;
	end;
end;

function saltar_sector:boolean;
begin
if ((FDCCommand[0] and $20)<>0) then begin
  if ((FDCCommand[0] and $1f)=$6) then begin
    if ((dsk[FDCCurrDrv].Tracks[dsk[FDCCurrDrv].cara_actual,dsk[FDCCurrDrv].track_actual].sector[dsk[FDCCurrDrv].sector_actual].status2 and $40)<>0) then begin
      saltar_sector:=TRUE;
      exit;
    end;
  end else begin
    if ((FDCCommand[0] and $1f)=$c) then begin
      if ((dsk[FDCCurrDrv].Tracks[dsk[FDCCurrDrv].cara_actual,dsk[FDCCurrDrv].track_actual].sector[dsk[FDCCurrDrv].sector_actual].status2 and $40)=0) then begin
        saltar_sector:=true;
        exit;
			end;
		end;
  end;
end;
saltar_sector:=FALSE;
end;

procedure read_sector;
var
  salir:boolean;
begin
salir:=false;
while not(salir) do begin
  if buscar_sector then begin
    if saltar_sector then begin
      if (FDCCommand[4]=FDCCommand[6]) then begin
        st1:=st1 and $7f;
        GetRes7;
        exit;
      end;
      FDCCommand[4]:=FDCCommand[4]+1;
    end else salir:=true;
  end else begin
    st0:=st0 or $40;
    st1:=st1 or $4;
    GetRes7;
    exit;
  end;
end;
ExecCmdPhase:=TRUE;
if dsk[FDCCurrDrv].Tracks[dsk[FDCCurrDrv].cara_actual,dsk[FDCCurrDrv].track_actual].sector[dsk[FDCCurrDrv].sector_actual].multi then begin
  if (dsk[FDCCurrDrv].cont_multi>=(dsk[FDCCurrDrv].max_multi-1)) then dsk[FDCCurrDrv].cont_multi:=0
     else inc(dsk[FDCCurrDrv].cont_multi);
  FDCDataPointer:=dsk[FDCCurrDrv].Tracks[dsk[FDCCurrDrv].cara_actual,dsk[FDCCurrDrv].track_actual].sector[dsk[FDCCurrDrv].sector_actual].posicion_data+(dsk[FDCCurrDrv].cont_multi*(1 shl (dsk[FDCCurrDrv].Tracks[dsk[FDCCurrDrv].cara_actual,dsk[FDCCurrDrv].track_actual].sector[dsk[FDCCurrDrv].sector_actual].sector_size+7)));
  FDCDataLength:=1 shl (FDCCommand[5]+7);
end else begin
  FDCDataPointer:=dsk[FDCCurrDrv].Tracks[dsk[FDCCurrDrv].cara_actual,dsk[FDCCurrDrv].track_actual].sector[dsk[FDCCurrDrv].sector_actual].posicion_data;
  FDCDataLength:=1 shl (FDCCommand[5]+7);//1 shl (dsk[FDCCurrDrv].Tracks[dsk[FDCCurrDrv].cara_actual,dsk[FDCCurrDrv].track_actual].sector[dsk[FDCCurrDrv].sector_actual].sector_size+7);  //1 shl (FDCCommand[5]+7);
end;
if FDCCommand[5]=0 then begin
  FDCDataLength:=FDCCommand[8];
  if FDCDataLength>$80 then FDCDataLength:=$80;
end;
FDCCounter:=0;
StatusRegister:=$f0;
principal1.Image1.visible:=true;
principal1.Image1.Refresh;
end;

procedure read_track;
begin
FDCDataLength:=dsk[FDCCurrDrv].Tracks[dsk[FDCCurrDrv].cara_actual,dsk[FDCCurrDrv].track_actual].sector[dsk[FDCCurrDrv].sector_read_track].data_length;
FDCDataPointer:=dsk[FDCCurrDrv].Tracks[dsk[FDCCurrDrv].cara_actual,dsk[FDCCurrDrv].track_actual].sector[dsk[FDCCurrDrv].sector_read_track].posicion_data;
FDCCounter:=0;
ExecCmdPhase:=TRUE;
StatusRegister:=$F0;
end;

procedure fdc_get_drive;
begin
	FDCCurrDrv:=(FDCCommand[1] and 1);
	dsk[FDCCurrDrv].cara_actual:=(FDCCommand[1] and 4) shr 2;
	st0:=st0 and $F8;
	st3:=st3 and $F8;
	st0:=st0 or (FDCCommand[1] and 1) or (FDCCommand[1] and 4);
  st3:=st3 or (FDCCommand[1] and 1) or (FDCCommand[1] and 4);
end;

function seek_track(track:byte):boolean;
var
  test:boolean;
begin
test:=not(track>(dsk[FDCCurrDrv].DiskHeader.nbof_tracks-1));
if test then dsk[FDCCurrDrv].track_actual:=track
  else dsk[FDCCurrDrv].track_actual:=dsk[FDCCurrDrv].DiskHeader.nbof_tracks;
seek_track:=test;
end;

procedure FDCExecWriteCommand;
begin
case (FDCCommand[0] and $1f) of
     2:begin // Read track
      st0:=0;
      st1:=$4;
      st2:=0;
      fdc_get_drive;
      if not(dsk[FDCCurrDrv].abierto) then begin
        st0:=st0 or $48;
        GetRes7;
      end else begin
        principal1.Image1.visible:=true;
        principal1.Image1.Refresh;
        dsk[FDCCurrDrv].sector_read_track:=0;
        read_track;
      end;
     end;
     3:begin // Specify
        ExecCmdPhase:=FALSE;
        ResultPhase:=FALSE;
        StatusRegister:=StatusRegister and ($40+$20+$10);
        StatusRegister:=StatusRegister or $80;
      end;
     4:begin // Sense drive status
      FDCCurrDrv:=(FDCCommand[1] and 1);
      st3:=st3 or (FDCCommand[1] and 1) or (FDCCommand[1] and 4);
      if dsk[FDCCurrDrv].protegido then st3:=st3 or $40;
      if dsk[FDCCurrDrv].abierto then st3:=st3 or $20;
      if (dsk[FDCCurrDrv].track_actual=0) then st3:=st3 or  $10;
      st3:=st3 or dsk[FDCCurrDrv].DiskHeader.nbof_heads shl 4;
      FDCResCounter:=1;
      FDCResPointer:=0;
      FDCResult[0]:=st3;
      ExecCmdPhase:=FALSE;
      ResultPhase:=TRUE;
      StatusRegister:=StatusRegister or $40;// $D0;
      StatusRegister:=StatusRegister and $20;
      end;
     5,9:begin  //Write data o deleted data (parcial)
         st0:=0;
         st1:=0;
         st2:=0;
         fdc_get_drive;
         if not(dsk[FDCCurrDrv].abierto) then begin
           st0:=st0 or $48;
           getres7;
           exit;
         end;
         if dsk[FDCCurrDrv].protegido then begin
           st0:=st0 or $40;
           st1:=st1 or 2;
           getres7;
           exit;
         end else begin
           st0:=0;
           st1:=0;
           st2:=0;
           fdc_get_drive;
         end;
     end;
     6,12:begin // Read data o deleted data
          st0:=0;
          st1:=0;
          st2:=0;
          fdc_get_drive;
          if not(dsk[FDCCurrDrv].abierto) then begin
            st0:=st0 or $48;
            getres7;
          end else read_sector;
        end;
     7:begin // Recalibrate
      st0:=$20;
      st1:=0;
      st2:=0;
      fdc_get_drive;
      StatusRegister:=$80;
      SeekTrack:=true;
      if not(dsk[FDCCurrDrv].abierto) then st0:=st0 or $48
        else seek_track(0);
      ExecCmdPhase:=FALSE;
      end;
     8:begin // Sense Interrupt
      FDCResPointer:=0;
      st0:=st0 and $f8;
      if SeekTrack then begin
        st0:=st0 or $20;
        FDCResCounter:=2;
        SeekTrack:=FALSE;
        FDCResult[1]:=dsk[FDCCurrDrv].track_actual;
        FDCResult[0]:=st0;
      end else begin
        st0:=$80;
        FDCResCounter:=1;
        FDCResult[0]:=st0;
      end;
      StatusRegister:=$d0;
      ExecCmdPhase:=FALSE;
      ResultPhase:=TRUE;
      end;
     10:begin // read ID of next sector
      st0:=0;
      st1:=0;
      st2:=0;
      fdc_get_drive;
      if not(dsk[FDCCurrDrv].abierto) then begin
        st0:=$48;
        getres7;
        FDCResult[3]:=dsk[FDCCurrDrv].track_actual;
        FDCResult[4]:=0;
        FDCResult[5]:=0;
        FDCResult[6]:=0;
      end else begin
          //Esto es fundamental, por ejemplo para 'Tintin on the Moon'
          if (dsk[FDCCurrDrv].sector_actual+1)>dsk[FDCCurrDrv].Tracks[dsk[FDCCurrDrv].cara_actual,dsk[FDCCurrDrv].track_actual].number_sector then begin
            dsk[FDCCurrDrv].sector_actual:=0;
            getres7;
          end else begin
            getres7;
            inc(dsk[FDCCurrDrv].sector_actual);
          end;
        end;
        end;
     15:begin // SEEK
      fdc_get_drive;
      StatusRegister:=$80;
      SeekTrack:=TRUE;
      //st2:=st2 and $fd;
      st0:=$20;
      st1:=0;
      st2:=0;
      if not(dsk[FDCCurrDrv].abierto) then st0:=st0 or $48
        else seek_track(FDCCommand[2]);
      ExecCmdPhase:=FALSE;
      end;
      else begin
        FDCResCounter:=1;
        FDCResPointer:=0;
        st0:=$80 or st0;
        if ExecCmdPhase then begin  //Hacer timeout para la proteccion Hexagon
          st1:=st1 or $10;
          st0:=(st0 and $3f) or $40;
          StatusRegister:=$80;
        end;
        FDCResult[0]:=st0;
        ExecCmdPhase:=FALSE;
        ResultPhase:=TRUE;
        seektrack:=true;
      end;
   end;
end;

function read_data_stop:boolean;
begin
read_data_stop:=false;
if ((FDCCommand[0] and $20)=0) then begin
		if ((FDCCommand[0] and $1f)=$06) then begin
			if ((dsk[FDCCurrDrv].Tracks[dsk[FDCCurrDrv].cara_actual,dsk[FDCCurrDrv].track_actual].sector[dsk[FDCCurrDrv].sector_actual].status2 and $40)<>0) then begin
				st2:=st2 or $40; //NEC765_ST2_CONTROL_MARK;
        read_data_stop:=true;
			end;
		end else begin
		if ((FDCCommand[0] and $1f)=$0c) then begin
			if ((dsk[FDCCurrDrv].Tracks[dsk[FDCCurrDrv].cara_actual,dsk[FDCCurrDrv].track_actual].sector[dsk[FDCCurrDrv].sector_actual].status2 and $40)=0) then begin
				st2:=st2 or $40; //NEC765_ST2_CONTROL_MARK;
        read_data_stop:=true;
			end;
    end;
	end;
end;
if ((dsk[FDCCurrDrv].Tracks[dsk[FDCCurrDrv].cara_actual,dsk[FDCCurrDrv].track_actual].sector[dsk[FDCCurrDrv].sector_actual].status1 and $20)<>0) then begin
  st1:=st1 or $20;
  read_data_stop:=true;
end;
end;

function FDCExecReadCommand:byte;
var
  ret:pbyte;
begin
  case (FDCCommand[0] and $1f) of
     2:begin
      ret:=dsk[FDCCurrDrv].Tracks[dsk[FDCCurrDrv].cara_actual,dsk[FDCCurrDrv].track_actual].data;
      if ret=nil then begin
        st0:=$40+$80;
        st1:=0+$20;
        st2:=$1;
        GetRes7;
        exit;
      end;
      inc(ret,FDCdataPointer);
      FDCExecReadCommand:=ret^;
      inc(FDCDataPointer);
      inc(FDCCounter);
      if (FDCCounter=FDCDataLength) then begin
        if dsk[FDCCurrDrv].sector_read_track=FDCCommand[6]-1 then begin
            st1:=st1 or $80;
            GetRes7;
            principal1.Image1.visible:=false;
            principal1.Image1.Refresh;
        end else begin
            inc(dsk[FDCCurrDrv].sector_read_track);
            read_track;
        end;
       end;
      end;
     6,12:begin
          ret:=dsk[FDCCurrDrv].Tracks[dsk[FDCCurrDrv].cara_actual,dsk[fdccurrdrv].track_actual].data;
          if ret=nil then begin
            st0:=$40+$80;
            st1:=0+$20;
            st2:=$1;
            GetRes7;
            exit;
          end;
          if FDCCounter>=(1 shl (dsk[FDCCurrDrv].Tracks[dsk[FDCCurrDrv].cara_actual,dsk[FDCCurrDrv].track_actual].sector[dsk[FDCCurrDrv].sector_actual].sector_size+7)) then begin
            //Para la emulacion de speedlock en Amstrad...
            st0:=$40+$80;
            st1:=$4+dsk[FDCCurrDrv].Tracks[dsk[FDCCurrDrv].cara_actual,dsk[FDCCurrDrv].track_actual].sector[dsk[FDCCurrDrv].sector_actual].status1;
            st2:=dsk[FDCCurrDrv].Tracks[dsk[FDCCurrDrv].cara_actual,dsk[FDCCurrDrv].track_actual].sector[dsk[FDCCurrDrv].sector_actual].status2;
            GetRes7;
            exit;
          end else begin
            inc(ret,fdcdatapointer);
            FDCExecReadCommand:=ret^;
          end;
          inc(FDCDataPointer);
          inc(FDCCounter);
          if (FDCCounter=FDCDataLength) then begin
            if ((FDCCommand[4]=FDCCommand[6]) or read_data_stop) then begin
              st0:=st0 or $40;
              GetRes7;
            end else begin
              inc(FDCCommand[4]);
              read_sector;
              exit;
            end;
            principal1.Image1.visible:=false;
            principal1.Image1.Refresh;
          end;
      end;
   end;
 end;

function FDCGetResult:byte;
var
  ret:byte;
begin
  ret:=FDCResult[FDCResPointer];
  FDCResPointer:= FDCResPointer + 1;
  if (FDCResPointer=FDCResCounter)  then begin
    StatusRegister:=$80;
    ResultPhase:=FALSE;
    fillchar(FDCResult[0],7,0);
    fillchar(FDCCommand[0],9,0);
  end;
  FDCGetResult:=ret;
end;

procedure ResetFDC;
begin
    FloppyMotor:=0;
    FDCPointer:=0;
    ExecCmdPhase:=false;
    ResultPhase:=false;
    StatusRegister:=$80;
    fillchar(FDCCommand[0],9,0);
    fillchar(FDCResult[0],7,0);
    SeekTrack:=FALSE;
    principal1.Image1.visible:=false;
    principal1.Image1.Refresh;
    st0:=0;
    st1:=0;
    st2:=0;
    st3:=0;
    FDCCmdPointer:=0;
    FDCResPointer:=0;
    FDCResCounter:=0;
    FDCDataPointer:=0;
    FDCDataLength:=0;
    FDCCounter:=0;
    Contador_status:=0;
    contador_read_status:=0;
end;

procedure WriteFDCData(value:byte);
begin
contador_status:=0;
if (not(ExecCmdPhase) or not(ResultPhase)) then begin
  if (FDCPointer=0) then begin
    FDCCommand[0]:=Value;
    FDCPointer:=FDCPointer+1;
    StatusRegister:=StatusRegister or $10;
  end else if (FDCPointer<bytes_in_cmd[FDCCommand[0] and $1f]) then begin
    FDCCommand[FDCPointer]:=Value;
    FDCPointer:=FDCPointer+1;
  end;
  if (FDCPointer=bytes_in_cmd[FDCCommand[0] and $1f])  then begin
    FDCPointer:=0;
    StatusRegister:=StatusRegister or $20;
    FDCExecWriteCommand;
  end;
end else FDCExecWriteCommand;
end;

function ReadFDCData:byte;
begin
  contador_status:=0;
  if ExecCmdPhase then begin
    ReadFDCData:= FDCExecReadCommand;
    exit;
  end;
  if ResultPhase then begin
    ReadFDCData:= FDCGetResult;
    exit;
  end;
  ReadFDCData:=0;
end;

function ReadFDCStatus:byte;
begin
//Aqui controlo un time out, si no quiere mas datos pues corto
//Falta por implementar el reloj!!
contador_status:=contador_status+1;
if contador_status>$10 then begin
  if seektrack then begin
    contador_read_status:=contador_read_status+1;
    if contador_read_status>$20 then begin
      StatusRegister:=$80;
      if contador_read_status>$40 then contador_read_status:=0;
    end else StatusRegister:=$50;
    SeekTrack:=FALSE;
  end else begin
    StatusRegister:=$f0;
    st0:=(st0 and $3f) or $40;
    st1:=st1 or $10;
    seektrack:=true;
  end;
  FDCPointer:=0;
  contador_status:=0;
  principal1.Image1.visible:=false;
  principal1.Image1.Refresh;
end;
ReadFDCStatus:=StatusRegister;
end;


end.
