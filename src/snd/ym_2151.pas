unit ym_2151;

interface
uses {$ifdef windows}windows,{$else}main_engine,{$endif}fm_2151,sound_engine,cpu_misc;

type
  ym2151_chip=class(snd_chip_class)
       constructor create(clock:dword;amp:single=1);
       destructor free;
    public
       procedure reset;
       procedure update;
       function status:byte;
       procedure reg(data:byte);
       procedure write(data:byte);
       procedure change_port_func(port_func:cpu_outport_call);
       procedure change_irq_func(irq_func:cpu_outport_call);
       procedure load_snapshot(data:pbyte);
       function save_snapshot(data:pbyte):word;
    private
       chip_number,lastreg:byte;
  end;

var
   ym2151_0,ym2151_1:ym2151_chip;

implementation
var
  chips_total:integer=-1;

constructor ym2151_chip.create(clock:dword;amp:single=1);
begin
  chips_total:=chips_total+1;
  self.chip_number:=chips_total;
  YM_2151Init(self.chip_number,clock);
  self.tsample_num:=init_channel;
  self.amp:=amp;
end;

procedure ym2151_chip.change_port_func(port_func:cpu_outport_call);
begin
FM2151[self.chip_number].porthandler:=port_func;
end;

procedure ym2151_chip.change_irq_func(irq_func:cpu_outport_call);
begin
FM2151[self.chip_number].IRQ_Handler:=irq_func;
end;

destructor ym2151_chip.free;
begin
  YM_2151Close(self.chip_number);
  chips_total:=chips_total-1;
end;

procedure ym2151_chip.reset;
begin
  YM_2151ResetChip(self.chip_number);
end;

function ym2151_chip.save_snapshot(data:pbyte):word;
var
  temp:pbyte;
  size:word;
begin
  temp:=data;
  copymemory(temp,@self.chip_number,1);inc(temp);size:=1;
  copymemory(temp,@self.lastreg,1);inc(temp);size:=size+1;
  save_snapshot:=size;
end;

procedure ym2151_chip.load_snapshot(data:pbyte);
var
  temp:pbyte;
begin
  temp:=data;
  copymemory(@self.chip_number,temp,1);inc(temp);
  copymemory(@self.lastreg,temp,1);inc(temp);
end;

function ym2151_chip.status:byte;
begin
     status:=YM_2151ReadStatus(self.chip_number);
end;

procedure ym2151_chip.reg(data:byte);
begin
  self.lastreg:=data;
end;

procedure ym2151_chip.write(data:byte);
begin
  YM_2151WriteReg(self.chip_number,self.lastreg,data);
end;

procedure ym2151_chip.update;
var
  audio:pinteger;
begin
  audio:=YM_2151UpdateOne(self.chip_number);
  if sound_status.stereo then begin
    inc(audio);
    tsample[self.tsample_num,sound_status.posicion_sonido]:=trunc(audio^*self.amp);
    inc(audio);
    tsample[self.tsample_num,sound_status.posicion_sonido+1]:=trunc(audio^*self.amp);
  end else tsample[self.tsample_num,sound_status.posicion_sonido]:=trunc(audio^*self.amp);
end;

end.
