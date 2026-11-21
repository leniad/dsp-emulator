unit oric_disc;

interface
uses main_engine;

type
  tirq_handler=procedure(valor:byte);
  twd17xx=class
    constructor create(clock:dword);
    destructor free;
  public
    c_drive,c_side:byte;
    clock:dword;
    procedure run(cycles:word);
    procedure write(direccion,valor:byte);
    function read(direccion:byte):byte;
    procedure reset;
  private
    r_status,r_track,r_sector,r_data:byte;
    physical_track:array[0..3] of byte;
    c_sector,currentop,sectype:byte;
    last_step_in,update_track,verify_seek:boolean;
    pending_track:byte;
    delayedint,delayeddrq,distatus,drq_deadline:integer;
    curroffs,currseclen:word;
    crc:word;
    address_data:array[0..5] of byte;
    track_buffer:array[0..6399] of byte;
    format_crc:word;
    format_sync:byte;
    format_crc_active:boolean;
    force_mask:byte;
    index_cycles:integer;
    clrintrq,setintrq,clrdrq,setdrq:procedure(num:byte);
    function media_ready:boolean;
    function find_sector(secid:byte):boolean;
    procedure complete(status:byte;delay:integer);
    procedure begin_sector(writing,multiple:boolean);
    procedure end_sector(writing:boolean);
    procedure seek_track(track:byte;command:byte;update:boolean);
    procedure update_raw_sector;
    procedure format_byte(value:byte);
  end;
  tmicrodisc=class
    constructor create(clock:dword;set_irq:tirq_handler);
    destructor free;
  public
    rom:array[0..$1fff] of byte;
    port_314:byte;
    irq_handle:tirq_handler;
    wd:twd17xx;
    procedure reset;
    procedure write(direccion,valor:byte);
    function read(direccion:byte):byte;
  private
    intrq,drq:byte; // $80=inactive, 0=active (ports are inverted)
  end;

const
  P_ROMDIS=$02; P_EPROM=$80; MDSF_INTENA=1;
  MDSF_INTRQ=$80; MF_DRQ=$80;
  WSF_BUSY=1; WSF_DRQ=2; WSF_LOST=4; WSF_CRC=8;
  WSF_RNF=$10; WSFI_SEEKERR=$10; WSFI_HEADL=$20;
  WSFI_PULSE=2; WSFI_TRK0=4; WSFR_RECTYP=$20;
  WSF_WPROT=$40; WSF_NOTREADY=$80;
  COP_NUFFINK=0; COP_READ_TRACK=1; COP_READ_SECTOR=2;
  COP_READ_SECTORS=3; COP_WRITE_TRACK=4; COP_WRITE_SECTOR=5;
  COP_WRITE_SECTORS=6; COP_READ_ADDRESS=7;

var
  microdisc_0:tmicrodisc;
  disc_count:integer=-1; // retained for interface compatibility

implementation
uses disk_file_format;

procedure clear_drq_int(num:byte);
begin
  if microdisc_0<>nil then microdisc_0.drq:=MF_DRQ;
end;
procedure set_drq_int(num:byte);
begin
  if microdisc_0<>nil then microdisc_0.drq:=0;
end;
procedure clear_int_irq(num:byte);
begin
  if microdisc_0=nil then exit;
  microdisc_0.intrq:=MDSF_INTRQ;
  if Assigned(microdisc_0.irq_handle) then microdisc_0.irq_handle(CLEAR_LINE);
end;
procedure set_int_irq(num:byte);
begin
  if microdisc_0=nil then exit;
  microdisc_0.intrq:=0;
  if Assigned(microdisc_0.irq_handle) then begin
    if (microdisc_0.port_314 and MDSF_INTENA)<>0 then
      microdisc_0.irq_handle(ASSERT_LINE)
    else microdisc_0.irq_handle(CLEAR_LINE);
  end;
end;

constructor twd17xx.create(clock:dword);
begin
  self.clock:=clock;
  clrintrq:=clear_int_irq; setintrq:=set_int_irq;
  clrdrq:=clear_drq_int; setdrq:=set_drq_int;
  reset;
end;
destructor twd17xx.free;
begin
end;

procedure twd17xx.reset;
begin
  r_status:=WSFI_TRK0; r_track:=0; r_sector:=1; r_data:=0;
  c_drive:=0; c_side:=0; c_sector:=0;
  fillchar(physical_track,SizeOf(physical_track),0);
  currentop:=COP_NUFFINK; last_step_in:=true;
  update_track:=false; verify_seek:=false; pending_track:=0;
  delayedint:=0; delayeddrq:=0; distatus:=-1; drq_deadline:=0;
  curroffs:=0; currseclen:=0; sectype:=0; crc:=0;
  force_mask:=0; index_cycles:=0;
  format_sync:=0; format_crc:=$ffff; format_crc_active:=false;
end;

function twd17xx.media_ready:boolean;
begin
  media_ready:=false;
  if c_drive>High(dsk) then exit;
  if not dsk[c_drive].abierto then exit;
  if c_side>=dsk[c_drive].DiskHeader.nbof_heads then exit;
  if c_drive>3 then exit;
  if physical_track[c_drive]>High(dsk[c_drive].Tracks[c_side]) then exit;
  if physical_track[c_drive]>=dsk[c_drive].DiskHeader.nbof_tracks then exit;
  media_ready:=true;
end;

function twd17xx.find_sector(secid:byte):boolean;
var i,n:integer;
begin
  find_sector:=false;
  if not media_ready then exit;
  n:=dsk[c_drive].Tracks[c_side,physical_track[c_drive]].number_sector;
  if n=0 then exit;
  for i:=1 to n do begin
    c_sector:=(c_sector+1) mod n;
    with dsk[c_drive].Tracks[c_side,physical_track[c_drive]].sector[c_sector] do
      if (sector=secid) and (track=r_track) then begin
        find_sector:=true; exit;
      end;
  end;
end;

procedure twd17xx.complete(status:byte;delay:integer);
begin
  currentop:=COP_NUFFINK; delayeddrq:=0; drq_deadline:=0;
  r_status:=r_status and not WSF_DRQ;
  clrdrq(0);
  distatus:=status; delayedint:=delay;
  if delay<=0 then begin
    r_status:=status; distatus:=-1; delayedint:=0; setintrq(0);
  end;
end;

procedure twd17xx.seek_track(track:byte;command:byte;update:boolean);
var distance,rate,i:integer; valid_id:boolean;
begin
  // Physical position and the track register are separate. 83 tracks supported.
  if track>82 then track:=82;
  distance:=abs(integer(track)-integer(physical_track[c_drive]));
  physical_track[c_drive]:=track;
  if update then begin
    if (command and $e0)=0 then begin
      if (command and $10)<>0 then r_track:=r_data else r_track:=0;
    end
    else if last_step_in then r_track:=r_track+1
    else if r_track>0 then dec(r_track);
  end;
  pending_track:=track; update_track:=update;
  verify_seek:=(command and 4)<>0;
  r_status:=WSF_BUSY;
  if (command and 8)<>0 then r_status:=r_status or WSFI_HEADL;
  case command and 3 of
    0:rate:=6000; 1:rate:=12000; 2:rate:=20000; else rate:=30000;
  end;
  if distance=0 then distance:=1;
  distatus:=r_status and not WSF_BUSY;
  if track=0 then distatus:=distatus or WSFI_TRK0;
  if verify_seek then begin
    if not media_ready then distatus:=distatus or WSFI_SEEKERR
    else begin
      // Verification must find a matching cylinder ID on this physical track.
      valid_id:=false;
      for i:=0 to integer(dsk[c_drive].Tracks[c_side,track].number_sector)-1 do
        if (dsk[c_drive].Tracks[c_side,track].sector[i].track=r_track) and
           ((dsk[c_drive].Tracks[c_side,track].sector[i].status2 and 1)=0) then valid_id:=true;
      if not valid_id then distatus:=distatus or WSFI_SEEKERR;
    end;
  end;
  // Timing is in FDC clocks; Oric CPU and FDC both use 1 MHz.
  delayedint:=distance*rate;
  currentop:=COP_NUFFINK;
end;

procedure twd17xx.begin_sector(writing,multiple:boolean);
var flags:byte;
begin
  flags:=0;
  if not find_sector(r_sector) then begin complete(WSF_RNF,20); exit; end;
  with dsk[c_drive].Tracks[c_side,physical_track[c_drive]].sector[c_sector] do begin
    if (sector_size>5) or (data_length<>(128 shl sector_size)) then begin
      complete(WSF_RNF,20); exit;
    end;
    if (status2 and 1)<>0 then begin complete(WSF_RNF or WSF_CRC,20); exit; end;
    currseclen:=data_length;
    if status1=$f8 then flags:=WSFR_RECTYP;
    if (status2 and 2)<>0 then flags:=flags or WSF_CRC;
  end;
  if writing and dsk[c_drive].protegido then begin complete(WSF_WPROT,20); exit; end;
  curroffs:=0;
  r_status:=WSF_BUSY;
  if writing then begin
    if multiple then currentop:=COP_WRITE_SECTORS else currentop:=COP_WRITE_SECTOR;
  end else begin
    sectype:=flags;
    if multiple then currentop:=COP_READ_SECTORS else currentop:=COP_READ_SECTOR;
  end;
  delayeddrq:=60;
end;

procedure twd17xx.update_raw_sector;
var t:^track_type; s:^sector_info_type; i,p:integer; c:word;
begin
  t:=@dsk[c_drive].Tracks[c_side,physical_track[c_drive]];
  s:=@t^.sector[c_sector];
  c:=$ffff;
  c:=oric_crc_byte(c,$a1); c:=oric_crc_byte(c,$a1);
  c:=oric_crc_byte(c,$a1); c:=oric_crc_byte(c,s^.status1);
  for i:=0 to s^.data_length-1 do
    c:=oric_crc_byte(c,t^.data[s^.posicion_data+i]);
  s^.data_crc:=c; s^.status2:=s^.status2 and not 2;
  if (t^.raw_data=nil) or (t^.raw_length=0) then exit;
  p:=s^.raw_data_offset;
  t^.raw_data[(p+t^.raw_length-1) mod t^.raw_length]:=s^.status1;
  for i:=0 to s^.data_length-1 do
    t^.raw_data[(p+i) mod t^.raw_length]:=t^.data[s^.posicion_data+i];
  t^.raw_data[(p+s^.data_length) mod t^.raw_length]:=c shr 8;
  t^.raw_data[(p+s^.data_length+1) mod t^.raw_length]:=c and $ff;
end;

procedure twd17xx.end_sector(writing:boolean);
var multi:boolean;
begin
  multi:=(currentop=COP_WRITE_SECTORS) or (currentop=COP_READ_SECTORS);
  if writing then update_raw_sector;
  if (not writing) and ((sectype and WSF_CRC)<>0) then begin
    complete(sectype,32); exit;
  end;
  if multi then begin
    inc(r_sector); begin_sector(writing,true);
    if currentop<>COP_NUFFINK then delayeddrq:=180;
  end else if writing then complete(0,32)
    else complete(sectype,32);
end;

procedure twd17xx.format_byte(value:byte);
var v:byte;
  procedure emit(b:byte);
  begin
    if curroffs<currseclen then begin
      track_buffer[curroffs]:=b; inc(curroffs);
    end;
  end;
begin
  // Byte-level MFM approximation: F5=A1 missing clock, F6=C2, F7=CRC.
  if value=$f7 then begin
    emit(format_crc shr 8); emit(format_crc and $ff);
    format_crc_active:=false; format_sync:=0;
  end else begin
    v:=value;
    if value=$f5 then begin
      v:=$a1;
      if format_sync=0 then begin format_crc:=$ffff; format_crc_active:=true; end;
      if format_sync<3 then inc(format_sync);
    end else begin
      if value=$f6 then v:=$c2;
      format_sync:=0;
    end;
    emit(v);
    if format_crc_active then format_crc:=oric_crc_byte(format_crc,v);
  end;
end;

procedure twd17xx.write(direccion,valor:byte);
var cmd,target,i:integer; multiple:boolean;
begin
  case direccion and 3 of
    0:begin
      // Force Interrupt is accepted while busy. Other commands are ignored.
      if ((r_status and WSF_BUSY)<>0) and ((valor and $f0)<>$d0) then exit;
      clrintrq(0); clrdrq(0);
      delayedint:=0; delayeddrq:=0; distatus:=-1; drq_deadline:=0;
      currentop:=COP_NUFFINK; force_mask:=0; r_status:=0;
      cmd:=valor and $f0;
      if cmd=$d0 then begin
        force_mask:=valor and 7;
        if physical_track[c_drive]=0 then r_status:=WSFI_TRK0;
        if (valor and 8)<>0 then setintrq(0);
        exit;
      end;
      if cmd<$80 then begin
        target:=physical_track[c_drive];
        case valor and $e0 of
          $00:if (valor and $10)=0 then begin target:=0; r_track:=0; end
              else target:=target+integer(r_data)-integer(r_track);
          $20:if last_step_in then inc(target) else dec(target);
          $40:begin last_step_in:=true; inc(target); end;
          $60:begin last_step_in:=false; dec(target); end;
        end;
        if target<0 then target:=0;
        if target>82 then target:=82;
        seek_track(target,valor,((valor and $e0)=0) or ((valor and $10)<>0));
        exit;
      end;
      multiple:=(valor and $10)<>0;
      case valor and $e0 of
        $80:begin_sector(false,multiple);
        $a0:begin
          sectype:=0; if (valor and 1)<>0 then sectype:=WSFR_RECTYP;
          begin_sector(true,multiple);
        end;
        $c0:begin
          if not media_ready then begin complete(WSF_RNF,20); exit; end;
          i:=dsk[c_drive].Tracks[c_side,physical_track[c_drive]].number_sector;
          if i=0 then begin complete(WSF_RNF,20); exit; end;
          c_sector:=(c_sector+1) mod i;
          with dsk[c_drive].Tracks[c_side,physical_track[c_drive]].sector[c_sector] do begin
            address_data[0]:=track; address_data[1]:=head;
            address_data[2]:=sector; address_data[3]:=sector_size;
            address_data[4]:=id_crc shr 8; address_data[5]:=id_crc and $ff;
            r_sector:=track;
            sectype:=0; if (status2 and 1)<>0 then sectype:=WSF_CRC;
          end;
          curroffs:=0; currseclen:=6; r_status:=WSF_BUSY;
          currentop:=COP_READ_ADDRESS; delayeddrq:=60;
        end;
        $e0:begin
          if not media_ready then begin complete(WSF_RNF,20); exit; end;
          if (valor and $10)=0 then begin
            sectype:=0;
            currseclen:=dsk[c_drive].Tracks[c_side,physical_track[c_drive]].raw_length;
            if currseclen=0 then begin complete(WSF_RNF,20); exit; end;
            copymemory(@track_buffer[0],dsk[c_drive].Tracks[c_side,physical_track[c_drive]].raw_data,currseclen);
            currentop:=COP_READ_TRACK;
          end else begin
            if dsk[c_drive].protegido then begin complete(WSF_WPROT,20); exit; end;
            currseclen:=6250; currentop:=COP_WRITE_TRACK;
            fillchar(track_buffer,SizeOf(track_buffer),$4e);
            format_sync:=0; format_crc:=$ffff; format_crc_active:=false;
          end;
          curroffs:=0; r_status:=WSF_BUSY; delayeddrq:=60;
        end;
      end;
    end;
    1:r_track:=valor;
    2:r_sector:=valor;
    3:begin
      r_data:=valor;
      if (r_status and WSF_DRQ)=0 then exit;
      if not (currentop in [COP_WRITE_SECTOR,COP_WRITE_SECTORS,COP_WRITE_TRACK]) then exit;
      r_status:=r_status and not WSF_DRQ; clrdrq(0); drq_deadline:=0;
      if not media_ready then begin complete(WSF_RNF,20); exit; end;
      if currentop=COP_WRITE_TRACK then begin
        format_byte(valor);
        if curroffs>=currseclen then begin
          if not oric_decode_track(c_drive,c_side,physical_track[c_drive],@track_buffer[0],currseclen) then
            complete(WSF_RNF,32)
          else complete(0,32);
        end else delayeddrq:=32;
      end else begin
        with dsk[c_drive].Tracks[c_side,physical_track[c_drive]] do begin
          if sectype=WSFR_RECTYP then sector[c_sector].status1:=$f8
            else sector[c_sector].status1:=$fb;
          data[sector[c_sector].posicion_data+curroffs]:=valor;
        end;
        inc(curroffs);
        if curroffs>=currseclen then end_sector(true) else delayeddrq:=32;
      end;
    end;
  end;
end;

function twd17xx.read(direccion:byte):byte;
begin
  read:=r_data;
  case direccion and 3 of
    0:begin clrintrq(0); read:=r_status; end;
    1:read:=r_track;
    2:read:=r_sector;
    3:begin
      if (r_status and WSF_DRQ)=0 then exit;
      if not (currentop in [COP_READ_SECTOR,COP_READ_SECTORS,COP_READ_ADDRESS,COP_READ_TRACK]) then exit;
      if currentop=COP_READ_ADDRESS then r_data:=address_data[curroffs]
      else if currentop=COP_READ_TRACK then r_data:=track_buffer[curroffs]
      else begin
        if not media_ready then begin complete(WSF_RNF,20); exit; end;
        with dsk[c_drive].Tracks[c_side,physical_track[c_drive]] do
          r_data:=data[sector[c_sector].posicion_data+curroffs];
      end;
      // Set the result BEFORE any completion/multi-sector transition.
      read:=r_data;
      inc(curroffs); r_status:=r_status and not WSF_DRQ; clrdrq(0); drq_deadline:=0;
      if curroffs>=currseclen then begin
        if currentop in [COP_READ_SECTOR,COP_READ_SECTORS] then end_sector(false)
        else complete(sectype,32);
      end else delayeddrq:=32;
    end;
  end;
end;

procedure twd17xx.run(cycles:word);
begin
  // A byte not serviced within its transfer window produces Lost Data.
  if drq_deadline>0 then begin
    dec(drq_deadline,cycles);
    if drq_deadline<=0 then complete(WSF_LOST,0);
  end;
  // Approximate index pulse for Force Interrupt bit 2 (300 rpm).
  inc(index_cycles,cycles);
  if index_cycles>=200000 then begin
    dec(index_cycles,200000);
    if ((force_mask and 4)<>0) and media_ready then setintrq(0);
  end;
  if delayedint>0 then begin
    dec(delayedint,cycles);
    if delayedint<=0 then begin
      delayedint:=0;
      if distatus>=0 then r_status:=distatus;
      distatus:=-1; setintrq(0);
    end;
  end;
  if delayeddrq>0 then begin
    dec(delayeddrq,cycles);
    if delayeddrq<=0 then begin
      delayeddrq:=0; r_status:=r_status or WSF_DRQ; drq_deadline:=32; setdrq(0);
    end;
  end;
end;

constructor tmicrodisc.create(clock:dword;set_irq:tirq_handler);
begin
  irq_handle:=set_irq; wd:=twd17xx.create(clock);
  port_314:=0; intrq:=MDSF_INTRQ; drq:=MF_DRQ;
end;
destructor tmicrodisc.free;
begin
  if Assigned(irq_handle) then irq_handle(CLEAR_LINE);
  wd.free;
end;
procedure tmicrodisc.reset;
begin
  port_314:=0; intrq:=MDSF_INTRQ; drq:=MF_DRQ;
  wd.reset;
  if Assigned(irq_handle) then irq_handle(CLEAR_LINE);
end;
procedure tmicrodisc.write(direccion,valor:byte);
begin
  case direccion and $f of
    0..3:wd.write(direccion and 3,valor);
    4:begin
      port_314:=valor;
      wd.c_drive:=(valor shr 5) and 3; wd.c_side:=(valor shr 4) and 1;
      if Assigned(irq_handle) then begin
        if ((valor and MDSF_INTENA)<>0) and (intrq=0) then irq_handle(ASSERT_LINE)
          else irq_handle(CLEAR_LINE);
      end;
    end;
    // Other addresses have no Microdisc write register.
  end;
end;
function tmicrodisc.read(direccion:byte):byte;
begin
  read:=$ff;
  case direccion and $f of
    0..3:read:=wd.read(direccion and 3);
    4:if ((port_314 and MDSF_INTENA)<>0) and (intrq=0) then read:=$7f;
    8:read:=drq or $7f;
  end;
end;
end.
