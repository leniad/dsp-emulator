unit ym_2610;

interface
uses main_engine,fmopn,ay_8910,timer_engine,sound_engine,cpu_misc;

type
  tym2610_adpcma=record
    playing:boolean;
    address:dword; // nibble address
    accumulator,step_index:integer;
  end;
  ym2610_chip=class(snd_chip_class)
    constructor create(clock:dword;amp:single=1;ay_amp:single=1);
    destructor free;
    public
      rom_a,rom_b:array of byte;
      procedure reset;
      procedure update;
      function read_port(port:byte):byte;
      procedure write_port(port,data:byte);
      function status:byte;
      function read:byte;
      procedure control(data:byte);
      procedure write(data:byte);
      procedure change_irq_calls(irq_handler:type_irq_handler);
    private
      OPN:pfm_opn;
      regs:array[0..$1ff]of byte;
      address_latch:word;
      ay8910_int:ay8910_chip;
      timer1,timer2,busy_timer:byte;
      timer_adjust:single;
      busy:boolean;
      a:array[0..5] of tym2610_adpcma;
      a_phase,b_phase:double;
      eos,flag_mask:byte;
      b_playing,b_latch:boolean;
      b_address,b_buffer:dword;
      b_nibbles,b_position,b_accumulator,b_step,b_output,b_previous:integer;
      procedure clock_a;
      procedure clock_b;
      function fetch_b:boolean;
      function consume_b(count:integer):integer;
      procedure start_b;
      procedure set_timer(number:byte;count:single);
      procedure set_busy;
  end;
var ym2610_0:ym2610_chip;

implementation
uses sysutils;
const
  a_steps:array[0..48]of integer=(16,17,19,21,23,25,28,31,34,37,41,45,50,55,
    60,66,73,80,88,97,107,118,130,143,157,173,190,209,230,253,279,307,337,
    371,408,449,494,544,598,658,724,796,876,963,1060,1166,1282,1411,1552);
  a_step_inc:array[0..7]of integer=(-1,-1,-1,-1,2,5,7,9);
  b_scale:array[0..7]of integer=(57,57,57,57,77,102,128,153);
  fm_channels:array[0..3]of byte=(1,2,4,5); // YM2610, not YM2610B

function clamp(v,lo,hi:integer):integer;
begin
  if v<lo then result:=lo
    else if v>hi then result:=hi
      else Result:=v;
end;

function sar(v:integer;shift:integer):integer;
begin
  if v>=0 then Result:=v shr shift
    else Result:=-integer((int64(-int64(v))+(int64(1)shl shift)-1)shr shift);
end;

procedure timer_a_set(count:single);
begin
  ym2610_0.set_timer(ym2610_0.timer1,count);
end;

procedure timer_b_set(count:single);
begin
  ym2610_0.set_timer(ym2610_0.timer2,count);
end;

procedure timer_a_over(index:byte);
begin
  TimerAOver(ym2610_0.OPN.ST);
  if (ym2610_0.OPN.ST.mode and $80)<>0 then CSMKeyControll(ym2610_0.OPN.P_CH[2]);
end;

procedure timer_b_over(index:byte);
begin
  TimerBOver(ym2610_0.OPN.ST);
end;

procedure busy_over(index:byte);
begin
  ym2610_0.busy:=false;timers.enabled(ym2610_0.busy_timer,false);
end;

constructor ym2610_chip.create(clock:dword;amp:single;ay_amp:single);
begin
  inherited Create;
  ym2610_0:=self;
  self.clock:=clock;
  self.amp:=amp;
  OPN:=opn_init(6);
  OPN.type_:=TYPE_YM2610;
  OPN.ST.clock:=clock;
  OPN.ST.rate:=FREQ_BASE_AUDIO;
  OPN.ST.TIMER_set_a:=timer_a_set;
  OPN.ST.TIMER_set_b:=timer_b_set;
  timer_adjust:=sound_status.cpu_clock/clock;
  timer1:=timers.init(sound_status.cpu_num,1,nil,timer_a_over,false);
  timer2:=timers.init(sound_status.cpu_num,1,nil,timer_b_over,false);
  busy_timer:=timers.init(sound_status.cpu_num,1,nil,busy_over,false);
  ay8910_int:=ay8910_chip.create(clock div 4,AY8910,ay_amp,true);
  tsample_num:=init_channel;
  SetLength(rom_a,$80000);
  SetLength(rom_b,$80000);
  reset;
end;

destructor ym2610_chip.free;
begin
  opn_close(OPN);
  OPN:=nil;
  ay8910_int.free;
  SetLength(rom_a,0);SetLength(rom_b,0);
  inherited Destroy;
end;

procedure ym2610_chip.set_timer(number:byte;count:single);
var
  was_enabled:boolean;
begin
  was_enabled:=timers.timer[number].enabled;
  if count=0 then begin
    timers.enabled(number,false);
    timers.timer[number].actual_time:=0;
  end else begin
    if not(was_enabled) then timers.timer[number].actual_time:=0;
    timers.timer[number].time_final:=count*timer_adjust;
    timers.enabled(number,true);
  end;
end;

procedure ym2610_chip.set_busy;
begin
  busy:=true;
  timers.timer[busy_timer].actual_time:=0;
  timers.timer[busy_timer].time_final:=192*timer_adjust;
  timers.enabled(busy_timer,true);
end;

procedure ym2610_chip.change_irq_calls(irq_handler:type_irq_handler);
begin
  OPN.ST.IRQ_Handler:=irq_handler;
end;

procedure ym2610_chip.reset;
var
  c,s,r:integer;
begin
  timers.enabled(timer1,false);
  timers.enabled(timer2,false);
  timers.enabled(busy_timer,false);
  busy:=false;
  address_latch:=0;
  fillchar(regs,SizeOf(regs),0);
  fillchar(a,SizeOf(a),0);
  a_phase:=0;
  b_phase:=0;
  eos:=0;
  flag_mask:=$bf;
  b_playing:=false;
  b_latch:=true;
  b_address:=0;
  b_buffer:=0;
  b_nibbles:=0;
  b_position:=0;
  b_accumulator:=0;
  b_step:=127;
  b_output:=0;
  b_previous:=0;
  ay8910_int.reset;
  OPNSetPres(OPN,144,144,0);
  OPN.ST.mode:=0;
  OPN.ST.TAC:=0;
  OPN.ST.TBC:=0;
  OPN.ST.TA:=0;
  OPN.ST.TB:=0;
  OPN.ST.fn_h:=0;
  fillchar(OPN.SL3^,SizeOf(fm_3slot),0);
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
      fillchar(OPN.P_CH[c].SLOT[s]^,SizeOf(fm_slot),0);
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
    regs[r]:=$c0;
    regs[r or $100]:=$c0;
  end;
  for c:=0 to 5 do regs[$108+c]:=$df;
end;

procedure ym2610_chip.start_b;
begin
  b_playing:=true;
  b_latch:=true;
  b_buffer:=0;
  b_nibbles:=0;
  b_position:=0;
  b_accumulator:=0;
  b_step:=127;
  b_output:=0;
  b_previous:=0;
  eos:=eos and $7f;
end;

procedure ym2610_chip.write_port(port,data:byte);
var
  r,c:integer;
begin
  port:=port and 3;
  if(port and 1)=0 then begin
    address_latch:=data+word(port shr 1)*$100;
    if ((port=0) and (data<16)) then ay8910_int.control(data);
    exit;
  end;
  // A1 must agree with the most recent address write (one shared latch).
  if (port shr 1)<>(address_latch shr 8)then exit;
  r:=address_latch;
  if r=$10 then data:=(data or $20)and $bf; // ROM mode, recording disabled
  regs[r]:=data;
  set_busy;
  if r<$0e then begin
    ay8910_int.write(data);
    exit;
  end;
  if r<$10 then exit; // No SSG I/O pins on YM2610
  if(r>=$10)and(r<$20)then begin
    case r of
      $10:begin
        if(data and 1)<>0 then begin
          if b_playing then eos:=eos or $80;
          b_playing:=false;
          b_position:=0;
          b_previous:=b_output;
        end else if(data and $80)<>0 then start_b
          else b_playing:=false;
      end;
      $1c:begin
            flag_mask:=byte(not data) and $bf;
            eos:=eos and flag_mask;
          end;
    end;
    exit;
  end;
  if (r>=$100) and (r<$130) then begin
    if r=$100 then for c:=0 to 5 do
      if(data and(1 shl c))<>0 then begin
        a[c].playing:=(data and $80)=0;
        if not a[c].playing then a[c].accumulator:=0;
        if a[c].playing then begin
          a[c].address:=dword(regs[$110+c]+word(regs[$118+c])*256)*512;
          a[c].accumulator:=0;a[c].step_index:=0;
        end;
      end;
    exit;
  end;
  if (r>=$20) and (r<$30) then OPNWriteMode(OPN,r,data)
    else OPNWriteReg(OPN,r,data);
end;

function ym2610_chip.read_port(port:byte):byte;
begin
  Result:=0;
  case port and 3 of
    0:begin
        Result:=OPN.ST.status and 3;
        if busy then Result:=Result or $80;
      end;
    1:if address_latch<$0e then Result:=ay8910_int.read
        else if address_latch<$10 then Result:=$ff
                else if address_latch=$ff then Result:=1;
    2:Result:=eos and flag_mask;
  end;
end;

function ym2610_chip.status:byte;
begin
  Result:=read_port(0);
end;

function ym2610_chip.read:byte;
begin
  Result:=read_port(1);
end;

procedure ym2610_chip.control(data:byte);
begin
  write_port(0,data);
end;

procedure ym2610_chip.write(data:byte);
begin
  write_port(1,data);
end;

procedure ym2610_chip.clock_a;
var
  c,n,delta,ending,addr:integer;
  data:byte;
begin
  for c:=0 to 5 do if a[c].playing then begin
    ending:=(regs[$120+c]+integer(regs[$128+c])*256+1)*256;
    if(a[c].address and 1)=0 then
      if(((a[c].address shr 1)xor dword(ending))and $fffff)=0 then begin
        a[c].playing:=false;
        a[c].accumulator:=0;
        eos:=eos or(1 shl c);
        continue;
      end;
    addr:=a[c].address shr 1;
    data:=$ff;
    if addr<Length(rom_a) then data:=rom_a[addr];
    if (a[c].address and 1)=0 then n:=data shr 4
      else n:=data and 15;
    inc(a[c].address);
    a[c].address:=a[c].address and $1ffffff;
    delta:=((n and 7)*2+1)*a_steps[a[c].step_index]div 8;
    if(n and 8)<>0 then delta:=-delta;
    a[c].accumulator:=(a[c].accumulator+delta) and $fff;
    a[c].step_index:=clamp(a[c].step_index+a_step_inc[n and 7],0,48);
  end;
end;

function ym2610_chip.consume_b(count:integer):integer;
begin
  dec(b_nibbles,count);
  Result:=(b_buffer shr (b_nibbles*4)) and ((1 shl (count*4))-1);
end;

function ym2610_chip.fetch_b:boolean;
var
  data:byte;ending:integer;
begin
  if b_latch then begin
    b_address:=dword(regs[$12]+word(regs[$13])*256)*256;
    b_latch:=false;
  end;
  data:=$ff;
  if b_address<dword(Length(rom_b)) then data:=rom_b[b_address];
  b_buffer:=(b_buffer shl 8)or data;
  inc(b_nibbles,2);
  ending:=regs[$14]+integer(regs[$15])*256;
  Result:=((b_address and $ff)=$ff) and (integer(b_address shr 8)=ending);
  if not Result then b_address:=(b_address+1)and $ffffff;
end;

procedure ym2610_chip.clock_b;
var
  position,n,delta,dummy:integer;
begin
  if not b_playing or((regs[$10]and $40)<>0)then begin
    b_previous:=b_output;
    b_position:=0;
    exit;
  end;
  position:=b_position+regs[$19]+integer(regs[$1a])*256;
  b_position:=position and $ffff;
  if position<$10000 then exit;
  if b_nibbles<>0 then begin
    n:=consume_b(1);
    delta:=((n and 7)*2+1)*b_step div 8;
    if(n and 8)<>0 then delta:=-delta;
    b_accumulator:=clamp(b_accumulator+delta,-32768,32767);
    b_step:=clamp(b_step*b_scale[n and 7]div 64,127,24576);
    b_previous:=b_output;
    b_output:=b_accumulator;
    if b_nibbles=0 then begin
      b_accumulator:=0;
      b_step:=127;
      eos:=eos or $80;
      if(regs[$10]and $10)=0 then b_playing:=false;
    end;
  end;
  if b_playing and (b_nibbles<3)then if fetch_b then begin
    // Hardware lookahead: the last three buffered nibbles are discarded.
    dummy:=consume_b(3);
    if(regs[$10]and $10)<>0 then b_latch:=true;
  end;
end;

procedure ym2610_chip.update;
var
  j,c,s,pos,vol,mul,shift,sample,l,r,ssg:integer;
  ch:pfm_chan;
  mixb:int64;
begin
  for j:=0 to 3 do begin
    c:=fm_channels[j];
    ch:=OPN.P_CH[c];
    if (c=2) and ((OPN.ST.mode and $c0)<>0) then begin
      if ch.SLOT[SLOT1].Incr=-1 then begin
        refresh_fc_eg_slot(OPN,ch.SLOT[SLOT1],OPN.SL3.fc[1],OPN.SL3.kcode[1]);
        refresh_fc_eg_slot(OPN,ch.SLOT[SLOT2],OPN.SL3.fc[2],OPN.SL3.kcode[2]);
        refresh_fc_eg_slot(OPN,ch.SLOT[SLOT3],OPN.SL3.fc[0],OPN.SL3.kcode[0]);
        refresh_fc_eg_slot(OPN,ch.SLOT[SLOT4],ch.fc,ch.kcode);
      end;
    end else refresh_fc_eg_chan(OPN,ch);
  end;
  LFO_AM:=0;
  LFO_PM:=0;
  if OPN.lfo_inc<>0 then begin
    OPN.lfo_cnt:=dword((uint64(OPN.lfo_cnt)+OPN.lfo_inc)and $ffffffff);
    pos:=(OPN.lfo_cnt shr LFO_SH)and 127;
    if pos<64 then LFO_AM:=pos*2
      else LFO_AM:=126-(pos and 63)*2;
    LFO_PM:=pos shr 2;
  end;
  OPN.eg_timer:=OPN.eg_timer+OPN.eg_timer_add;
  while OPN.eg_timer>=OPN.eg_timer_overflow do begin
    OPN.eg_timer:=OPN.eg_timer-OPN.eg_timer_overflow;Inc(OPN.eg_cnt);
    for j:=0 to 3 do advance_eg_channel(OPN,OPN.P_CH[fm_channels[j]]);
  end;
  l:=0;
  r:=0;
  for j:=0 to 3 do begin
    c:=fm_channels[j];
    out_fm[c]:=0;
    CHAN_Calc(OPN,OPN.P_CH[c]);
    if OPN.pan[c*2]<>0 then inc(l,sar(out_fm[c],1));
    if OPN.pan[c*2+1]<>0 then inc(r,sar(out_fm[c],1));
  end;
  a_phase:=a_phase+clock/(432.0*FREQ_BASE_AUDIO);
  while a_phase>=1 do begin
    a_phase:=a_phase-1;
    clock_a;
  end;
  b_phase:=b_phase+clock/(144.0*FREQ_BASE_AUDIO);
  while b_phase>=1 do begin
    b_phase:=b_phase-1;
    clock_b;
  end;
  for c:=0 to 5 do begin
    vol:=((regs[$108+c]and $1f)xor $1f)+((regs[$101]and $3f)xor $3f);
    if vol>=63 then continue;
    sample:=a[c].accumulator;
    if sample>=$800 then dec(sample,$1000);
    mul:=15-(vol and 7);
    shift:=1+(vol shr 3);
    sample:=sar(sample*mul,shift) and (integer(not 3));
    if (regs[$108+c]and $80)<>0 then inc(l,sample);
    if (regs[$108+c]and $40)<>0 then inc(r,sample);
  end;
  mixb:=(int64(b_previous)*($10000-b_position)+int64(b_output)*b_position)div $10000;
  sample:=sar(integer(mixb)*regs[$1b],9);
  if (regs[$11]and $80)<>0 then inc(l,sample);
  if (regs[$11]and $40)<>0 then inc(r,sample);
  // The AY engine supplies the existing emulator's SSG waveform/mix.
  ssg:=ay8910_int.update_internal^;
  if sound_status.stereo then begin
    tsample[tsample_num,sound_status.posicion_sonido]:=clamp(ssg+Trunc(l*amp),-32768,32767);
    tsample[tsample_num,sound_status.posicion_sonido+1]:=clamp(ssg+Trunc(r*amp),-32768,32767);
  end else tsample[tsample_num,sound_status.posicion_sonido]:=clamp(ssg+Trunc((l+r)*amp),-32768,32767);
  // Timers are advanced exclusively by timer_engine on the Z80 clock.
end;

end.
