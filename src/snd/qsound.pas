unit qsound;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     timer_engine,sound_engine;

const
  QSOUND_CLOCKDIV=166;			 // Clock divider
  QSOUND_CHANNELS=16-1;

type

  QSOUND_CHANNEL_def=record
	  bank,	   // bank (x16)
	  address,	// start address
    pitch,	  // pitch
    reg3,	   // unknown (always 0x8000)
    loop,	   // loop address
    end_addr,		// end address
    vol,		// master volume
    pan,		// Pan value
    reg9:integer;	   // unknown
	  // Work variables
    key:integer;		// Key on / key off
    lvol,	   // left volume
    rvol,	   // right volume
    lastdt,	 // last sample value
    offset:integer;	 // current offset counter
  end;
  pQSOUND_CHANNEL_def=^QSOUND_CHANNEL_def;

  qsound_state_def=record
    // Private variables
	  channel:array[0..QSOUND_CHANNELS] of pQSOUND_CHANNEL_def;
    data:word;				  // register latch data
	  sample_rom:pbyte;	// Q sound sample ROM
	  sample_rom_length:dword;
	  pan_table:array[0..33-1] of integer;		 // Pan volume table
	  frq_ratio:single;		   // Frequency ratio
    tsample:byte;
    out_:array[0..1] of integer;
  end;
  pqsound_state_def=^qsound_state_def;

var
  qsound_state:pqsound_state_def;

procedure qsound_init(sample_size:dword);
procedure qsound_close;
procedure qsound_reset;
procedure qsound_w(offset,data:byte);
function qsound_r:byte;
procedure qsound_sound_update;

implementation

procedure qsound_close;
var
  f:byte;
begin
if qsound_state<>nil then begin
  freemem(qsound_state.sample_rom);
  qsound_state.sample_rom:=nil;
  for f:=0 to QSOUND_CHANNELS do begin
    freemem(qsound_state.channel[f]);
    qsound_state.channel[f]:=nil;
  end;
  freemem(qsound_state);
  qsound_state:=nil;
end;
end;

procedure qsound_reset;
var
  f:byte;
begin
for f:=0 to QSOUND_CHANNELS do fillchar(qsound_state.channel[f]^,sizeof(QSOUND_CHANNEL_def),0);
qsound_state.data:=0;
qsound_state.out_[0]:=0;
qsound_state.out_[1]:=0;
end;

procedure qsound_set_command(data:byte;value:word);
var
  ch,reg,pandata:byte;
  chip:pqsound_state_def;
begin
	chip:=qsound_state;
	if (data<$80) then begin
		ch:=data shr 3;
		reg:=data and $07;
	end else begin
		if (data<$90) then begin
			ch:=data-$80;
			reg:=8;
		end else begin
			if ((data>=$ba) and (data<$ca)) then begin
				ch:=data-$ba;
				reg:=9;
			end else begin
				// Unknown registers
				ch:=99;
				reg:=99;
			end;
		end;
	end;
	case reg of
		0:begin // Bank
			  ch:=(ch+1) and $0f;	// strange...
			  chip.channel[ch].bank:=(value and $7f) shl 16;
      end;
		1:chip.channel[ch].address:=value; // start
		2:begin // pitch
			  chip.channel[ch].pitch:=value*16;
			  if (value=0) then chip.channel[ch].key:=0; // Key off
			end;
		3:chip.channel[ch].reg3:=value; // unknown
		4:chip.channel[ch].loop:=value; // loop offset
		5:chip.channel[ch].end_addr:=value; // end
		6:begin // master volume
			  if (value=0) then begin
  				// Key off
				  chip.channel[ch].key:=0;
        end	else if (chip.channel[ch].key=0) then begin
          				// Key on
          				chip.channel[ch].key:=1;
          				chip.channel[ch].offset:=0;
          				chip.channel[ch].lastdt:=0;
          			end;
			  chip.channel[ch].vol:=value;
			end;
		7:;  // unused
		8:begin
			   pandata:=(value-$10) and $3f;
			   if (pandata>32) then pandata:=32;
			   chip.channel[ch].rvol:=chip.pan_table[pandata];
			   chip.channel[ch].lvol:=chip.pan_table[32-pandata];
			   chip.channel[ch].pan:=value;
      end;
		 9:chip.channel[ch].reg9:=value;
	end;
end;

procedure qsound_w(offset,data:byte);
var
  chip:pqsound_state_def;
begin
	chip:=qsound_state;
	case offset of
		0:chip.data:=(chip.data and $ff) or (data shl 8);
		1:chip.data:=(chip.data and $ff00) or data;
    2:qsound_set_command(data, chip.data);
	end;
end;

function qsound_r:byte;
begin
	// Port ready bit (0x80 if ready)
	qsound_r:=$80;
end;

procedure qsound_update_internal;
var
  chip:pqsound_state_def;
  i:byte;
  rvol,lvol,count:integer;
  ptemp:pbyte;
  pC:pQSOUND_CHANNEL_def;
begin
	chip:=qsound_state;
  chip.out_[0]:=0;
  chip.out_[1]:=0;
	for i:=0 to QSOUND_CHANNELS do begin
    pC:=chip.channel[i];
		if (pC.key<>0) then begin
			rvol:=(pC.rvol*pC.vol) div 256;
			lvol:=(pC.lvol*pC.vol) div 256;
			count:=(pC.offset) shr 16;
			pC.offset:=pC.offset and $ffff;
			if (count<>0) then begin
					pC.address:=pC.address+count;
					if (pC.address>= pC.end_addr) then begin
						if (pC.loop<>0) then begin
							pC.key:=0;
							continue;
						end;
						pC.address:=(pC.end_addr-pC.loop) and $ffff;
					end;
          ptemp:=chip.sample_rom;
          inc(ptemp,(pC.bank+pC.address) and chip.sample_rom_length);
          pC.lastdt:=shortint(ptemp^);
      end;  //del if count
      chip.out_[0]:=chip.out_[0]+((pC.lastdt*lvol) div 32);
      if chip.out_[0]<-32767 then chip.out_[0]:=-32767
        else if chip.out_[0]>32767 then chip.out_[0]:=32767;
			chip.out_[1]:=chip.out_[1]+((pC.lastdt*rvol) div 32);
      if chip.out_[1]<-32767 then chip.out_[1]:=-32767
        else if chip.out_[1]>32767 then chip.out_[1]:=32767;
			pC.offset:=pC.offset+pC.pitch;
    end; //del if key
	end; //del for
end;

procedure qsound_sound_update;
begin
  tsample[qsound_state.tsample,sound_status.posicion_sonido]:=qsound_state.out_[0];
  tsample[qsound_state.tsample,sound_status.posicion_sonido+1]:=qsound_state.out_[1];
end;

procedure qsound_init(sample_size:dword);
var
  f:byte;
begin
  getmem(qsound_state,sizeof(qsound_state_def));
  for f:=0 to QSOUND_CHANNELS do getmem(qsound_state.channel[f],sizeof(QSOUND_CHANNEL_def));
  getmem(qsound_state.sample_rom,sample_size);
  qsound_state.frq_ratio:=16;
	// Create pan table
	for f:=0 to 32 do qsound_state.pan_table[f]:=round((256/sqrt(32))*sqrt(f));
  qsound_state.sample_rom_length:=sample_size-1;
  init_timer(1,sound_status.cpu_clock/(4000000/QSOUND_CLOCKDIV),qsound_update_internal,true);  //Aprox 24.096Hz
  qsound_state.tsample:=init_channel;
end;

end.