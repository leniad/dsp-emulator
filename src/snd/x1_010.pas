unit x1_010;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     {$ifndef windows}main_engine,{$endif}
     sound_engine,timer_engine,dialogs;

const
  VOL_BASE=(2*32*256/30);
  NUM_CHANNELS=16;

type
  x1_010_channel=record
    	status:byte;
	    volume:byte;                     //        volume / wave form no.
	    frequency:byte;                  //     frequency / pitch lo
	    pitch_hi:byte;                   //      reserved / pitch hi
	    start:byte;                      // start address / envelope time
	    end_:byte;                        //   end address / envelope no.
	    reserve:array[0..1] of byte;
  end;
  px1_010_channel=^x1_010_channel;

  tx1_010=class(snd_chip_class)
       constructor create(clock:dword);
       destructor free;
    public
       rom:array[0..$fffff] of byte;
       procedure reset;
       procedure update;
       function read16(direccion:word):word;
       procedure write16(direccion,valor:word);
       function read(direccion:word):byte;
       procedure write(direccion:word;valor:byte);
       function save_snapshot(data:pbyte):word;
       procedure load_snapshot(data:pbyte);
     private
       clock:dword;
       rate:single;
       reg:array[0..$1fff] of byte;
       hi_word_buf:array[0..$1fff] of byte;
       smp_offset:array[0..(NUM_CHANNELS-1)] of dword;
       env_offset:array[0..(NUM_CHANNELS-1)] of dword;
       lsignal,rsignal:smallint;
       tsample_:byte;
  end;

var
  x1_010_0:tx1_010;

implementation
procedure x10_final_update;
var
  ch,div_,vol:byte;
  reg:px1_010_channel;
  start,end_,smp_offs,delta,env_offs:dword;
  volL,volR:integer;
  data:shortint;
  env,freq:word;
begin
  x1_010_0.lsignal:=0;
  x1_010_0.rsignal:=0;
  for ch:=0 to (NUM_CHANNELS-1) do begin
    reg:=@x1_010_0.reg[ch*sizeof(x1_010_channel)];
    if (reg.status and 1)<>0 then begin //Key On
      div_:=(reg.status and $80) shr 7;
      if (reg.status and $2)=0 then begin //PCM Sampling
        start:=reg.start shl 12;
				end_:=($100-reg.end_) shl 12;
				volL:=trunc(((reg.volume shr 4) and $f)*VOL_BASE);
				volR:=trunc(((reg.volume shr 0) and $f)*VOL_BASE);
				smp_offs:=x1_010_0.smp_offset[ch];
				freq:=reg.frequency shr div_;
				// Meta Fox does write the frequency register, but this is a hack to make it "work" with the current setup
				// This is broken for Arbalester (it writes 8), but that'll be fixed later.
				if (freq=0) then freq:=4;
        delta:=smp_offs shr 4;
        // sample ended?
        if ((start+delta)>=end_) then begin
						reg.status:=reg.status and $fe;                    // Key off
						break;
        end;
        data:=shortint(x1_010_0.rom[start+delta]);
        x1_010_0.lsignal:=x1_010_0.lsignal+((data*volL) shr 8);
			  x1_010_0.rsignal:=x1_010_0.rsignal+((data*volR) shr 8);
				x1_010_0.smp_offset[ch]:=smp_offs+freq;
      end else begin //Wave form
        start:=(reg.volume shl 7)+$1000;
				smp_offs:=x1_010_0.smp_offset[ch];
				freq:=((reg.pitch_hi shl 8)+reg.frequency) shr div_;
				env:=reg.end_ shl 7;
				env_offs:=x1_010_0.env_offset[ch];
        delta:=env_offs shr 10;
        // Envelope one shot mode
        if (((reg.status and 4)<>0) and (delta>=$80)) then begin
						reg.status:=reg.status and $fe;                    // Key off
						break;
        end;
        vol:=x1_010_0.reg[env+(delta and $7f)];
				volL:=trunc(((vol shr 4) and $f)*VOL_BASE);
				volR:=trunc(((vol shr 0) and $f)*VOL_BASE);
				data:=shortint(x1_010_0.reg[start+((smp_offs shr 10) and $7f)]);
				x1_010_0.lsignal:=x1_010_0.lsignal+((data*volL) shr 8);
			  x1_010_0.rsignal:=x1_010_0.rsignal+((data*volR) shr 8);
				x1_010_0.smp_offset[ch]:=smp_offs+freq;
				x1_010_0.env_offset[ch]:=env_offs+reg.start;
      end;
    end;
  end;
end;

constructor tx1_010.create(clock:dword);
begin
  if addr(update_sound_proc)=nil then MessageDlg('ERROR: Chip de sonido inicializado sin CPU de sonido!', mtInformation,[mbOk], 0);
  self.clock:=clock;
  self.rate:=clock/512;
  self.reset;
  timers.init(sound_status.cpu_num,sound_status.cpu_clock/self.rate,x10_final_update,nil,true);
  self.tsample_:=init_channel;
end;

destructor tx1_010.free;
begin
end;

procedure tx1_010.reset;
var
  f:byte;
begin
  for f:=0 to (NUM_CHANNELS-1) do begin
    self.smp_offset[f]:=0;
    self.env_offset[f]:=0;
  end;
  fillchar(self.reg,$2000,0);
  fillchar(self.hi_word_buf,$2000,0);
  self.rsignal:=0;
  self.lsignal:=0;
end;

procedure tx1_010.update;
begin
if sound_status.stereo then begin
  tsample[self.tsample_,sound_status.posicion_sonido]:=self.lsignal;
  tsample[self.tsample_,sound_status.posicion_sonido+1]:=self.rsignal;
end else tsample[self.tsample_,sound_status.posicion_sonido]:=self.lsignal+self.rsignal;
end;
function tx1_010.save_snapshot(data:pbyte):word;
begin
end;
procedure tx1_010.load_snapshot(data:pbyte);
begin
end;

function tx1_010.read(direccion:word):byte;
begin
  read:=self.reg[direccion];
end;

procedure tx1_010.write(direccion:word;valor:byte);
var
  channel,reg:byte;
begin
  channel:=direccion div sizeof(x1_010_channel);
	reg:=direccion mod sizeof(x1_010_channel);
	if ((channel<NUM_CHANNELS) and (reg=0) and ((self.reg[direccion] and 1)=0) and ((valor and 1)<>0)) then begin
		self.smp_offset[channel]:=0;
		self.env_offset[channel]:=0;
	end;
	self.reg[direccion]:=valor;
end;

function tx1_010.read16(direccion:word):word;
var
  ret:word;
begin
	ret:=(self.hi_word_buf[direccion] shl 8) or self.reg[direccion];
	read16:=ret;
end;

procedure tx1_010.write16(direccion,valor:word);
begin
  self.hi_word_buf[direccion]:=valor shr 8;
	self.write(direccion,valor and $ff);
end;

end.
