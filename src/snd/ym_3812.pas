unit ym_3812;

interface
uses main_engine,fmopl,timer_engine,sound_engine,cpu_misc,dialogs;

type
  ym3812_chip=class(snd_chip_class)
     constructor create(type_:byte;clock:dword;amp:single=1);
     destructor free;
  public
     procedure reset;
     procedure update;
     procedure control(data:byte);
     procedure write(data:byte);
     function status:byte;
     function read:byte;
     procedure timer_handler(timer_num:byte;period:single);
     procedure change_irq_calls(irq_func:cpu_outport_call);
     function save_snapshot(data:pbyte):word;
     procedure load_snapshot(data:pbyte);
  private
     OPL:pfm_opl;
     num,timer1,timer2:byte;
  end;
const
  YM3812_FM=0;
  YM3526_FM=1;
var
  ym3812_0,ym3812_1:ym3812_chip;

procedure ym3812_set_timer(index,timer_num:byte;period:single);
procedure ym3812_timer1(index:byte);
procedure ym3812_timer2(index:byte);
procedure ym3812_timer1_0;
procedure ym3812_timer2_0;
procedure ym3812_timer1_1;
procedure ym3812_timer2_1;

implementation
var
  chip_instances:array[0..1] of ym3812_chip;

function ym3812_chip.save_snapshot(data:pbyte):word;
begin
  save_snapshot:=1;
end;

procedure ym3812_chip.load_snapshot(data:pbyte);
begin

end;

constructor ym3812_chip.create(type_:byte;clock:dword;amp:single=1);
var
  rate:integer;
begin
  if addr(update_sound_proc)=nil then MessageDlg('ERROR: Chip de sonido inicializado sin CPU de sonido!', mtInformation,[mbOk], 0);
  if chip_instances[0]=nil then self.num:=0
    else if chip_instances[1]=nil then self.num:=1;
  rate:=round(clock/72);
  // emulator create
  self.OPL:=OPLCreate(sound_status.cpu_clock,clock,rate);
  case type_ of
    YM3812_FM:self.OPL.type_:=OPL_TYPE_WAVESEL;
    YM3526_FM:self.OPL.type_:=0;
  end;
  self.tsample_num:=init_channel;
  self.amp:=amp;
  self.timer1:=timers.init(sound_status.cpu_num,1,nil,ym3812_timer1,false,self.num);
  self.timer2:=timers.init(sound_status.cpu_num,1,nil,ym3812_timer2,false,self.num);
  chip_instances[self.num]:=self;
  self.reset;
end;

destructor ym3812_chip.free;
begin
  if self.num<=1 then begin
    if chip_instances[self.num]=self then begin
      timers.enabled(self.timer1,false);
      timers.enabled(self.timer2,false);
      chip_instances[self.num]:=nil;
    end;
  end;
  if self.OPL<>nil then OPLClose(self.OPL);
  self.OPL:=nil;
end;

procedure ym3812_chip.change_irq_calls(irq_func:cpu_outport_call);
begin
  self.OPL.IRQ_Handler:=irq_func;
end;

procedure ym3812_chip.reset;
begin
  timers.enabled(self.timer1,false);
  timers.enabled(self.timer2,false);
  OPLResetChip(self.num,self.OPL);
end;

procedure ym3812_chip.update;
var
  lt:smallint;
  mixed:double;
begin
  self.OPL.output:=0;
  advance_lfo(self.OPL);
  // FM part
  OPL_CALC_CH(self.OPL,self.OPL.P_CH[0]);
  OPL_CALC_CH(self.OPL,self.OPL.P_CH[1]);
  OPL_CALC_CH(self.OPL,self.OPL.P_CH[2]);
  OPL_CALC_CH(self.OPL,self.OPL.P_CH[3]);
  OPL_CALC_CH(self.OPL,self.OPL.P_CH[4]);
  OPL_CALC_CH(self.OPL,self.OPL.P_CH[5]);
  if (self.OPL.rhythm and $20)=0 then begin
     OPL_CALC_CH(self.OPL,self.OPL.P_CH[6]);
     OPL_CALC_CH(self.OPL,self.OPL.P_CH[7]);
     OPL_CALC_CH(self.OPL,self.OPL.P_CH[8]);
  end else begin		// Rhythm part
      OPL_CALC_RH(self.OPL,self.OPL.noise_rng and 1);
  end;
  // Preserve the existing x2 mix level; clip after applying gain.
  mixed:=self.OPL.output*2.0*self.amp;
  if mixed>32767 then lt:=32767
    else if mixed< -32768 then lt:=-32768
      else lt:=Trunc(mixed);
  tsample[self.tsample_num,sound_status.posicion_sonido]:=lt;
  if sound_status.stereo then tsample[self.tsample_num,sound_status.posicion_sonido+1]:=lt;
  // store to sound buffer
  advance(self.OPL);
end;

procedure ym3812_chip.control(data:byte);
begin
  self.OPL.address:=data;
end;

procedure ym3812_chip.write(data:byte);
begin
  OPLWriteReg(self.num,self.OPL,self.OPL.address,data);
end;

function ym3812_chip.status:byte;
begin
  status:=(self.OPL.status and (self.OPL.statusmask or $80)) or $06 ;
end;

function ym3812_chip.read:byte;
begin
  read:=$ff;
end;

procedure ym3812_chip.timer_handler(timer_num:byte;period:single);
begin
  case timer_num of
    0:if period=0 then timers.enabled(self.timer1,false)
        else begin
          timers.timer[self.timer1].time_final:=period;
          timers.enabled(self.timer1,true);
        end;
    1:if period=0 then timers.enabled(self.timer2,false)
        else begin
          timers.timer[self.timer2].time_final:=period;
          timers.enabled(self.timer2,true);
        end;
  end;
end;

procedure ym3812_set_timer(index,timer_num:byte;period:single);
begin
  chip_instances[index].timer_handler(timer_num,period);
end;

procedure ym3812_timer1(index:byte);
var
  chip:ym3812_chip;
begin
  chip:=chip_instances[index];
  if chip.OPL.st[0]=0 then Exit;
  OPLTimerOver(index,chip.OPL,0);
end;

procedure ym3812_timer2(index:byte);
var
  chip:ym3812_chip;
begin
  chip:=chip_instances[index];
  if chip.OPL.st[1]=0 then Exit;
  OPLTimerOver(index,chip.OPL,1);
end;

procedure ym3812_timer1_0;
begin
  ym3812_timer1(0);
end;

procedure ym3812_timer2_0;
begin
  ym3812_timer2(0);
end;

procedure ym3812_timer1_1;
begin
  ym3812_timer1(1);
end;

procedure ym3812_timer2_1;
begin
  ym3812_timer2(1);
end;

end.
