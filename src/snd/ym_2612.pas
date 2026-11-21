unit ym_2612;

interface
uses main_engine,fmopn,sound_engine;

type
  ym2612_chip=class(snd_chip_class)
    constructor create(clock:dword;amp:single=1);
    destructor free;
  public
    procedure reset;
    procedure update;
    function read_port(port:byte):byte;
    procedure write_port(port,data:byte);
    function status:byte;
    function read:byte;
    procedure control(data:byte);
    procedure write(data:byte);
    procedure change_irq_calls(irq_handler:type_irq_handler);
    procedure change_clock(new_clock:dword);
  private
    OPN:pfm_opn;
    address_latch:word;
    timer1,timer2,busy_timer:byte;
    timer_cpu_clock:dword;
    busy,dac_enabled:boolean;
    dac:integer;
    procedure set_timer(number:byte;count:single);
    procedure set_busy;
  end;
var ym2612_0:ym2612_chip;

implementation
uses dialogs,SysUtils,timer_engine;

procedure timer_a_set(count:single);
begin
  if ym2612_0<>nil then ym2612_0.set_timer(ym2612_0.timer1,count);
end;

procedure timer_b_set(count:single);
begin
  if ym2612_0<>nil then ym2612_0.set_timer(ym2612_0.timer2,count);
end;

procedure timer_a_over(index:byte);
begin
 TimerAOver(ym2612_0.OPN.ST);
 if (ym2612_0.OPN.ST.mode and $80)<>0 then CSMKeyControll(ym2612_0.OPN.P_CH[2]);
end;

procedure timer_b_over(index:byte);
begin
  if ym2612_0<>nil then TimerBOver(ym2612_0.OPN.ST);
end;

procedure busy_over(index:byte);
begin
 ym2612_0.busy:=false;
 timers.enabled(ym2612_0.busy_timer,false);
end;

constructor ym2612_chip.create(clock:dword;amp:single);
begin
 inherited Create;
 if (sound_status.cpu_clock=0) then MessageDlg('YM2612: inicializa primero el reloj de audio de la CPU.',mtError,[mbOk],0);
 self.clock:=clock;
 self.amp:=amp;
 OPN:=opn_init(6);
 OPN.type_:=TYPE_6CH or TYPE_LFOPAN or TYPE_DAC;
 OPN.ST.clock:=clock;
 OPN.ST.rate:=FREQ_BASE_AUDIO;
 OPN.ST.TIMER_set_a:=timer_a_set;
 OPN.ST.TIMER_set_b:=timer_b_set;
 timer_cpu_clock:=sound_status.cpu_clock;
 timer1:=timers.init(sound_status.cpu_num,1,nil,timer_a_over,false);
 timer2:=timers.init(sound_status.cpu_num,1,nil,timer_b_over,false);
 busy_timer:=timers.init(sound_status.cpu_num,1,nil,busy_over,false);
 tsample_num:=init_channel;
 reset;
end;

destructor ym2612_chip.free;
begin
 timers.enabled(timer1,false);
 timers.enabled(timer2,false);
 timers.enabled(busy_timer,false);
 opn_close(OPN);
 OPN:=nil;
 if ym2612_0=self then ym2612_0:=nil;
end;

procedure ym2612_chip.set_timer(number:byte;count:single);
var
  ratio:double;
begin
 ratio:=timer_cpu_clock;
 ratio:=ratio/clock;
 if count=0 then begin
  timers.enabled(number,false);
  timers.timer[number].actual_time:=0;
 end else begin
  if not timers.timer[number].enabled then timers.timer[number].actual_time:=0;
  timers.timer[number].time_final:=count*ratio;
  timers.enabled(number,true);
 end;
end;

procedure ym2612_chip.set_busy;
var
  ratio:double;
begin
 ratio:=timer_cpu_clock;
 ratio:=ratio/clock;
 busy:=true;
 timers.timer[busy_timer].actual_time:=0;
 // 32 internal cycles, prescaled by 6, expressed on the host CPU clock.
 timers.timer[busy_timer].time_final:=192.0*ratio;
 timers.enabled(busy_timer,true);
end;

procedure ym2612_chip.change_irq_calls(irq_handler:type_irq_handler);
begin
  OPN.ST.IRQ_Handler:=irq_handler;
end;

procedure ym2612_chip.change_clock(new_clock:dword);
begin
 clock:=new_clock;
 timer_cpu_clock:=sound_status.cpu_clock;
 reset;
end;

procedure ym2612_chip.reset;
var
  c,s,r:integer;
begin
 timers.enabled(timer1,false);
 timers.enabled(timer2,false);
 timers.enabled(busy_timer,false);
 timers.timer[timer1].actual_time:=0;
 timers.timer[timer2].actual_time:=0;
 timers.timer[busy_timer].actual_time:=0;
 address_latch:=0;
 busy:=false;
 dac:=0;
 dac_enabled:=false;
 OPN.ST.clock:=clock;OPNSetPres(OPN,144,144,0);
 OPN.ST.mode:=0;
 OPN.ST.TAC:=0;
 OPN.ST.TBC:=0;
 OPN.ST.TA:=0;
 OPN.ST.TB:=0;
 OPN.ST.fn_h:=0;
 FillChar(OPN.SL3^,SizeOf(fm_3slot),0);
 OPN.eg_timer:=0;
 OPN.eg_cnt:=0;
 OPN.lfo_cnt:=0;
 OPN.lfo_inc:=0;
 FM_IRQMASK_SET(OPN.ST,3);
 FM_STATUS_RESET(OPN.ST,$ff);
 for c:=0 to 5 do begin
  OPN.P_CH[c].fc:=0;
  OPN.P_CH[c].block_fnum:=0;
  OPN.P_CH[c].kcode:=0;
  OPN.P_CH[c].am_enable:=0;
  OPN.P_CH[c].pms:=0;
  OPN.P_CH[c].ams:=8;
  OPN.P_CH[c].op1_out[0]:=0;
  OPN.P_CH[c].op1_out[1]:=0;
  OPN.P_CH[c].mem_value:=0;
  for s:=0 to 3 do begin
   FillChar(OPN.P_CH[c].SLOT[s]^,SizeOf(fm_slot),0);
   OPN.P_CH[c].SLOT[s].state:=EG_OFF;
   OPN.P_CH[c].SLOT[s].volume:=MAX_ATT_INDEX;
   OPN.P_CH[c].SLOT[s].vol_out:=MAX_ATT_INDEX;
  end;
 end;
 for r:=$b2 downto $30 do begin
    OPNWriteReg(OPN,r,0);
    OPNWriteReg(OPN,r or $100,0);
 end;
 for r:=$b4 to $b6 do begin
    OPNWriteReg(OPN,r,$c0);
    OPNWriteReg(OPN,r or $100,$c0);
 end;
end;

procedure ym2612_chip.write_port(port,data:byte);
var r:integer;
begin
 port:=port and 3;
 if(port and 1)=0 then begin
  address_latch:=word(data) or (word(port shr 1) shl 8);
  exit;
 end;
 // A single shared address latch: the data port must match its A1 bank.
 if (port shr 1)<>(address_latch shr 8) then exit;
 r:=address_latch;set_busy;
 case r of
  $2a:begin
        dac:=(integer(data)-128)*64;
        exit;
      end;
  $2b:begin
        dac_enabled:=(data and $80)<>0;
        exit;
      end;
 end;
 if (r>=$20) and (r<$30) then OPNWriteMode(OPN,r,data)
  else if(r and $ff)>=$30 then OPNWriteReg(OPN,r,data);
end;

function ym2612_chip.read_port(port:byte):byte;
begin
 // Digital status mirror; discrete-chip bus decay is not modelled.
 Result:=OPN.ST.status and 3;
 if busy then Result:=Result or $80;
end;

function ym2612_chip.status:byte;
begin
  Result:=read_port(0);
end;

function ym2612_chip.read:byte;
begin
  Result:=read_port(1);
end;

procedure ym2612_chip.control(data:byte);
begin
  write_port(0,data);
end;

procedure ym2612_chip.write(data:byte);
begin
  write_port(1,data);
end;

procedure ym2612_chip.update;
var
  c,pos,l,r,v:integer;
  ch:pfm_chan;
function clip(value:integer):integer;
begin
  if value>32767 then Result:=32767
    else if value< -32768 then Result:=-32768
      else Result:=value;
end;
begin
 for c:=0 to 5 do begin
  ch:=opn.P_CH[c];
  if (c=2) and ((opn.ST.mode and $c0)<>0) then begin
   if ch.SLOT[SLOT1].Incr=-1 then begin
    refresh_fc_eg_slot(opn,ch.SLOT[SLOT1],opn.SL3.fc[1],opn.SL3.kcode[1]);
    refresh_fc_eg_slot(opn,ch.SLOT[SLOT2],opn.SL3.fc[2],opn.SL3.kcode[2]);
    refresh_fc_eg_slot(opn,ch.SLOT[SLOT3],opn.SL3.fc[0],opn.SL3.kcode[0]);
    refresh_fc_eg_slot(opn,ch.SLOT[SLOT4],ch.fc,ch.kcode);
   end;
  end else refresh_fc_eg_chan(opn,ch);
 end;
 LFO_AM:=0;LFO_PM:=0;
 if opn.lfo_inc<>0 then begin
  opn.lfo_cnt:=dword((uint64(opn.lfo_cnt)+opn.lfo_inc) and $ffffffff);
  pos:=(opn.lfo_cnt shr LFO_SH) and $7f;
  if pos<64 then LFO_AM:=pos*2
    else LFO_AM:=126-(pos and 63)*2;
  LFO_PM:=pos shr 2;
 end;
 opn.eg_timer:=opn.eg_timer+opn.eg_timer_add;
 while opn.eg_timer>=opn.eg_timer_overflow do begin
  opn.eg_timer:=opn.eg_timer-opn.eg_timer_overflow;inc(opn.eg_cnt);
  for c:=0 to 5 do advance_eg_channel(opn,opn.P_CH[c]);
 end;
 l:=0;
 r:=0;
 for c:=0 to 5 do begin
  out_fm[c]:=0;
  CHAN_Calc(opn,opn.P_CH[c]);
  v:=out_fm[c];
  if(c=5)and dac_enabled then v:=dac;
  if opn.pan[c*2]<>0 then inc(l,v);
  if opn.pan[c*2+1]<>0 then inc(r,v);
 end;
 if sound_status.stereo then begin
  tsample[tsample_num,sound_status.posicion_sonido]:=clip(Trunc(l*amp));
  tsample[tsample_num,sound_status.posicion_sonido+1]:=clip(Trunc(r*amp));
 end else tsample[tsample_num,sound_status.posicion_sonido]:=clip(Trunc((l+r)*amp));
end;

end.
