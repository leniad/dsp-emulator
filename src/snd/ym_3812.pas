unit ym_3812;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}fmopl,timer_engine,sound_engine,cpu_misc;

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

procedure ym3812_timer1(index:byte);
procedure ym3812_timer2(index:byte);
procedure ym3812_timer1_0;
procedure ym3812_timer2_0;
procedure ym3812_timer1_1;
procedure ym3812_timer2_1;

implementation
var
  chips_total:integer=-1;

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
  chips_total:=chips_total+1;
  self.num:=chips_total;
  rate:=round(clock/72);
  // emulator create */
  self.OPL:=OPLCreate(sound_status.cpu_clock,clock,rate);
  self.reset;
  case type_ of
    YM3812_FM:self.OPL.type_:=OPL_TYPE_WAVESEL;
    YM3526_FM:self.OPL.type_:=0;
  end;
  self.tsample_num:=init_channel;
  self.amp:=amp;
  self.timer1:=timers.init(sound_status.cpu_num,1,nil,ym3812_timer1,false,chips_total);
  self.timer2:=timers.init(sound_status.cpu_num,1,nil,ym3812_timer2,false,chips_total);
end;

destructor ym3812_chip.free;
begin
  OPLClose(self.OPL);
  chips_total:=chips_total-1;
end;

procedure ym3812_chip.change_irq_calls(irq_func:cpu_outport_call);
begin
  self.OPL.IRQ_Handler:=irq_func;
end;

procedure ym3812_chip.reset;
begin
OPLResetChip(self.num,self.OPL);
end;

procedure ym3812_chip.update;
var
  lt:integer;
begin
  self.OPL.output:=0;
  advance_lfo(self.OPL);
  // FM part */
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
  end else begin		// Rhythm part */
      OPL_CALC_RH(self.OPL,self.OPL.noise_rng and 1);
  end;
  lt:=trunc((self.OPL.output shl 1)*self.amp);
  // limit check */
  if lt>$7fff then lt:=$7fff
   else if lt<-$7fff then lt:=-$7fff;
  tsample[self.tsample_num,sound_status.posicion_sonido]:=lt;
  if sound_status.stereo then tsample[self.tsample_num,sound_status.posicion_sonido+1]:=lt;
  // store to sound buffer */
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

procedure ym3812_timer1(index:byte);
begin
  case index of
    0:OPLTimerOver(0,ym3812_0.OPL,0);
    1:OPLTimerOver(0,ym3812_1.OPL,0);
  end;
end;

procedure ym3812_timer2(index:byte);
begin
  case index of
    0:OPLTimerOver(0,ym3812_0.OPL,1);
    1:OPLTimerOver(0,ym3812_1.OPL,1);
  end;
end;

procedure ym3812_timer1_0;
begin
  OPLTimerOver(0,ym3812_0.OPL,0);
end;

procedure ym3812_timer2_0;
begin
  OPLTimerOver(0,ym3812_0.OPL,1);
end;

procedure ym3812_timer1_1;
begin
  OPLTimerOver(1,ym3812_1.OPL,0);
end;

procedure ym3812_timer2_1;
begin
  OPLTimerOver(1,ym3812_1.OPL,1);
end;

end.
