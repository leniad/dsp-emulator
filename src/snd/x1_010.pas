unit x1_010;

interface
uses main_engine,sound_engine,timer_engine,dialogs;

const
  VOL_BASE=(2*32*256 div 30);
  NUM_CHANNELS=16;

type
  x1_010_channel=packed record
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
       lsignal,rsignal:integer;
       instance_id,timer_id:byte;
       timer_ready:boolean;
       tsample_:byte;
       procedure internal_update;
  end;

var
  x1_010_0:tx1_010;

implementation
var
  instances:array[0..3] of tx1_010;

procedure x10_final_update(index:byte);
begin
  if index>3 then Exit;
  if instances[index]<>nil then instances[index].internal_update;
end;

procedure tx1_010.internal_update;
function arithmetic_shift8(value:integer):integer;
begin
  if value<0 then arithmetic_shift8:=-Integer(((-Int64(value))+255) div 256)
    else arithmetic_shift8:=value div 256;
end;
function signed_byte(value:byte):integer;
begin
  if value>=128 then signed_byte:=Integer(value)-256 else signed_byte:=value;
end;
var
  ch,div_,vol:byte;
  reg:px1_010_channel;
  start,end_,smp_offs,delta,env_offs:dword;
  volL,volR:integer;
  data:integer;
  env,freq:word;
begin
  self.lsignal:=0;
  self.rsignal:=0;
  for ch:=0 to (NUM_CHANNELS-1) do begin
    reg:=@self.reg[ch*sizeof(x1_010_channel)];
    if (reg.status and 1)<>0 then begin //Key On
      div_:=(reg.status and $80) shr 7;
      if (reg.status and $2)=0 then begin //PCM Sampling
        start:=reg.start shl 12;
				end_:=($100-reg.end_) shl 12;
				volL:=trunc(((reg.volume shr 4) and $f)*VOL_BASE);
				volR:=trunc(((reg.volume shr 0) and $f)*VOL_BASE);
				smp_offs:=self.smp_offset[ch];
				freq:=reg.frequency shr div_;
				// Meta Fox does write the frequency register, but this is a hack to make it "work" with the current setup
				// This is broken for Arbalester (it writes 8), but that'll be fixed later.
				if (freq=0) then freq:=4;
        delta:=smp_offs shr 4;
        // sample ended?
        if ((start+delta)>=end_) then begin
						reg.status:=reg.status and $fe;                    // Key off
						continue;
        end;
        data:=signed_byte(self.rom[start+delta]);
        self.lsignal:=self.lsignal+arithmetic_shift8(data*volL);
			  self.rsignal:=self.rsignal+arithmetic_shift8(data*volR);
				self.smp_offset[ch]:=dword((Int64(smp_offs)+freq) and $ffffffff);
      end else begin //Wave form
        // Reject selectors outside allocated RAM; do not invent wrapping bits.
        if (reg.volume>=32) or (reg.end_>=64) then begin
          reg.status:=reg.status and $fe;
          continue;
        end;
        start:=(reg.volume shl 7)+$1000;
				smp_offs:=self.smp_offset[ch];
				freq:=((reg.pitch_hi shl 8)+reg.frequency) shr div_;
				env:=reg.end_ shl 7;
				env_offs:=self.env_offset[ch];
        delta:=env_offs shr 10;
        // Envelope one shot mode
        if (((reg.status and 4)<>0) and (delta>=$80)) then begin
						reg.status:=reg.status and $fe;                    // Key off
						continue;
        end;
        vol:=self.reg[env+(delta and $7f)];
				volL:=trunc(((vol shr 4) and $f)*VOL_BASE);
				volR:=trunc(((vol shr 0) and $f)*VOL_BASE);
				data:=signed_byte(self.reg[start+((smp_offs shr 10) and $7f)]);
				self.lsignal:=self.lsignal+arithmetic_shift8(data*volL);
			  self.rsignal:=self.rsignal+arithmetic_shift8(data*volR);
				self.smp_offset[ch]:=dword((Int64(smp_offs)+freq) and $ffffffff);
				self.env_offset[ch]:=dword((Int64(env_offs)+reg.start) and $ffffffff);
      end;
    end;
  end;
end;

constructor tx1_010.create(clock:dword);
var i:integer;
begin
  if addr(update_sound_proc)=nil then MessageDlg('ERROR: Chip de sonido inicializado sin CPU de sonido!',mtInformation,[mbOk],0);
  self.instance_id:=$ff;
  for i:=0 to 3 do
    if instances[i]=nil then begin
      self.instance_id:=i;
      break;
    end;
  self.clock:=clock;
  self.rate:=clock/512;
  self.reset;
  self.tsample_:=init_channel;
  self.timer_id:=timers.init(sound_status.cpu_num,sound_status.cpu_clock*512.0/clock,nil,x10_final_update,false,self.instance_id);
  self.timer_ready:=true;
  instances[self.instance_id]:=self;
  timers.enabled(self.timer_id,true);
end;

destructor tx1_010.free;
begin
  if self.timer_ready then timers.enabled(self.timer_id,false);
  if self.instance_id<=3 then
    if instances[self.instance_id]=self then instances[self.instance_id]:=nil;
  if x1_010_0=self then x1_010_0:=nil;
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
function clip_sample(value:integer):smallint;
begin
  if value>32767 then clip_sample:=32767
    else if value< -32768 then clip_sample:=-32768
            else clip_sample:=value;
end;
begin
if sound_status.stereo then begin
  tsample[self.tsample_,sound_status.posicion_sonido]:=clip_sample(self.lsignal);
  tsample[self.tsample_,sound_status.posicion_sonido+1]:=clip_sample(self.rsignal);
end else tsample[self.tsample_,sound_status.posicion_sonido]:=clip_sample(self.lsignal+self.rsignal);
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
  channel,reg:integer;
begin
  channel:=direccion div sizeof(x1_010_channel);
	reg:=direccion mod sizeof(x1_010_channel);
	if ((direccion<$80) and (channel<NUM_CHANNELS) and (reg=0) and ((self.reg[direccion] and 1)=0) and ((valor and 1)<>0)) then begin
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
