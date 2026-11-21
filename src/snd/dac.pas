unit dac;

interface
uses main_engine,sound_engine,dialogs;

type
  dac_chip=class(snd_chip_class)
      constructor Create(amp:single=1;internal:boolean=false);
      destructor free;
    public
      procedure update;
      procedure reset;
      procedure data8_w(data:byte);
      procedure signed_data8_w(data:byte);
      procedure data16_w(data:word);
      procedure signed_data16_w(data:word);
      function save_snapshot(data:pbyte):word;
      procedure load_snapshot(data:pbyte);
      function internal_update:integer;
    private
      output:integer;
      amp:single;
      internal_mode:boolean;
  end;
var
  dac_0,dac_1,dac_2,dac_3:dac_chip;

implementation

constructor dac_chip.Create(amp:single=1;internal:boolean=false);
function valid_gain(value:single):boolean;
var
  bits:dword;
begin
  move(value,bits,sizeof(bits));
  valid_gain:=(bits and $7f800000)<>$7f800000; // reject NaN and infinity
end;
begin
  valid_gain(amp);
  self.internal_mode:=internal;
  if (not internal) and (addr(update_sound_proc)=nil) then MessageDlg('ERROR: Chip de sonido inicializado sin CPU de sonido!', mtInformation,[mbOk], 0);
  self.amp:=amp;
  if not(internal) then self.tsample_num:=init_channel;
  self.reset;
end;

destructor dac_chip.free;
begin
end;

function dac_chip.save_snapshot(data:pbyte):word;
var
  ptemp:pbyte;
begin
  ptemp:=data;
  copymemory(ptemp,@self.output,sizeof(integer));inc(ptemp,sizeof(integer));
  copymemory(ptemp,@self.amp,sizeof(single));
  save_snapshot:=SizeOf(self.output)+SizeOf(self.amp);
end;

procedure dac_chip.load_snapshot(data:pbyte);
var
  ptemp:pbyte;
  next_output:integer;
  next_amp:single;
begin
  ptemp:=data;
  CopyMemory(@next_output,ptemp,SizeOf(next_output));
  Inc(ptemp,SizeOf(next_output));
  CopyMemory(@next_amp,ptemp,SizeOf(next_amp));
  self.output:=next_output;
  self.amp:=next_amp;
end;

function dac_chip.internal_update:integer;
var
  value:double;
begin
  value:=self.output*self.amp;
  if value>High(integer) then internal_update:=High(integer)
    else if value<Low(integer) then internal_update:=Low(integer)
            else internal_update:=Trunc(value);
end;

procedure dac_chip.update;
var
  res:smallint;
  value:double;
begin
  if self.internal_mode then Exit;
  value:=self.output*self.amp;
  if value>32767 then res:=32767
    else if value<-32767 then res:=-32767
    else res:=Trunc(value);
  tsample[self.tsample_num,sound_status.posicion_sonido]:=res;
  if sound_status.stereo then tsample[self.tsample_num,sound_status.posicion_sonido+1]:=res;
end;

procedure dac_chip.data8_w(data:byte);
begin
	self.output:=Integer(data)*32767 div 255;
end;

procedure dac_chip.signed_data8_w(data:byte);
begin
	self.output:=(Integer(data)-$80)*32767 div 128;
end;

procedure dac_chip.data16_w(data:word);
begin
	self.output:=data shr 1;
end;

procedure dac_chip.signed_data16_w(data:word);
begin
	self.output:=Integer(data)-$8000;
end;

procedure dac_chip.reset;
begin
  self.output:=0;
end;

end.
