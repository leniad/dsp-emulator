unit ym_3812;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     fmopl,timer_engine,sound_engine;

type
  IRQ_Handler=procedure (irqstate:byte);
  ym3812_chip=class(snd_chip_class)
     constructor create(num:byte;clock:dword;amp:single=1);
     destructor free;
  public
     procedure reset;
     procedure update;
     procedure control(data:byte);
     procedure write(data:byte);
     function status:byte;
     function read:byte;
     procedure timer_handler(timer_num:byte;period:single);
     procedure change_irq_calls(irq_func:IRQ_Handler);
  private
     OPL:pfm_opl;
     num,timer1,timer2:byte;
     procedure init_timers;
  end;
var
  ym3812_0,ym3812_1:ym3812_chip;

procedure ym3812_timer1_0;
procedure ym3812_timer2_0;
procedure ym3812_timer1_1;
procedure ym3812_timer2_1;

implementation

procedure ym3812_chip.init_timers;
begin
  //Timers
  case self.num of
    0:begin
        self.timer1:=init_timer(sound_status.cpu_num,1,ym3812_timer1_0,false);
        self.timer2:=init_timer(sound_status.cpu_num,1,ym3812_timer2_0,false);
      end;
    1:begin
        self.timer1:=init_timer(sound_status.cpu_num,1,ym3812_timer1_1,false);
        self.timer2:=init_timer(sound_status.cpu_num,1,ym3812_timer2_1,false);
      end;
  end;
end;

constructor ym3812_chip.create(num:byte;clock:dword;amp:single=1);
var
  rate:integer;
begin
  self.num:=num;
  rate:=round(clock/72);
  // emulator create */
  self.OPL:=OPLCreate(sound_status.cpu_clock,clock,rate);
  self.reset;
  self.OPL.type_:=OPL_TYPE_WAVESEL;
  self.tsample_num:=init_channel;
  self.amp:=amp;
  self.init_timers;
end;

destructor ym3812_chip.free;
begin
  OPLClose(self.OPL);
end;

procedure ym3812_chip.change_irq_calls(irq_func:IRQ_Handler);
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
  // rhythm slots */
  SLOT7_1:=self.OPL.P_CH[7].SLOT[SLOT1];
  SLOT7_2:=self.OPL.P_CH[7].SLOT[SLOT2];
  SLOT8_1:=self.OPL.P_CH[8].SLOT[SLOT1];
  SLOT8_2:=self.OPL.P_CH[8].SLOT[SLOT2];

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
  lt:=trunc(self.OPL.output*self.amp);
  //lt:=lt shr FINAL_SH;
  // limit check */
  if lt>$7fff then lt:=$7fff;
  if lt<-$7fff then lt:=-$7fff;
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
    0:if period=0 then timer[self.timer1].enabled:=false
        else begin
          timer[self.timer1].time_final:=period;
          timer[self.timer1].enabled:=true;
        end;
    1:if period=0 then timer[self.timer2].enabled:=false
        else begin
          timer[self.timer2].time_final:=period;
          timer[self.timer2].enabled:=true;
        end;
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
