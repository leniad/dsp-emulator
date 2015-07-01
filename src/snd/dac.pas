unit dac;

interface
uses {$ifdef windows}windows,{$else}main_engine,{$ENDIF}sound_engine;

type
  dac_chip=class(snd_chip_class)
      constructor Create(amp:single=1);
      procedure Free;
      destructor Destroy;
    public
      procedure update;
      procedure reset;
      procedure data8_w(data:byte);
      procedure signed_data8_w(data:byte);
      procedure data16_w(data:word);
      procedure signed_data16_w(data:word);
      function save_snapshot(data:pbyte):word;
      procedure load_snapshot(data:pbyte);
    private
      output:integer;
      amp:single;
  end;
var
  dac_0,dac_1:dac_chip;

implementation

constructor dac_chip.Create(amp:single=1);
begin
  self.amp:=amp;
  self.tsample_num:=init_channel;
  self.reset;
end;

destructor dac_chip.Destroy;
begin
end;

procedure dac_chip.Free;
begin
self.Destroy;
end;

function dac_chip.save_snapshot(data:pbyte):word;
var
  ptemp:pbyte;
begin
  ptemp:=data;
  copymemory(ptemp,@self.output,sizeof(integer));inc(ptemp,sizeof(integer));
  copymemory(ptemp,@self.amp,sizeof(single));
  save_snapshot:=8;
end;

procedure dac_chip.load_snapshot(data:pbyte);
var
  ptemp:pbyte;
begin
  ptemp:=data;
  copymemory(@self.output,ptemp,sizeof(integer));inc(ptemp,sizeof(integer));
  copymemory(@self.amp,ptemp,sizeof(single));
end;

procedure dac_chip.update;
begin
  tsample[self.tsample_num,sound_status.posicion_sonido]:=trunc(self.output*self.amp);
  if sound_status.stereo then tsample[self.tsample_num,sound_status.posicion_sonido+1]:=trunc(self.output+self.amp);
end;

procedure dac_chip.data8_w(data:byte);
begin
	self.output:=(data*32767) div 255;
end;

procedure dac_chip.signed_data8_w(data:byte);
begin
	self.output:=(data-$80)*32767 div 128;
end;

procedure dac_chip.data16_w(data:word);
begin
	self.output:=data shr 1;
end;

procedure dac_chip.signed_data16_w(data:word);
begin
	self.output:=data-$8000;
end;

procedure dac_chip.reset;
begin
  self.output:=0;
end;

end.
