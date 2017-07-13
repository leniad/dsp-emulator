unit ym_2203;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     {$ifndef windows}main_engine,{$endif}
     fmopn,ay_8910,timer_engine,sound_engine,cpu_misc;

type
  ym2203_chip=class(snd_chip_class)
       constructor create(clock:dword;amp:single=1;ay_amp:single=1);
       destructor free;
    public
       procedure reset;
       procedure update;
       function status:byte;
       function read:byte;
       procedure control(data:byte);
       procedure write(data:byte);
       procedure change_irq_calls(irq_handler:type_irq_handler);
       procedure change_io_calls(porta_read,portb_read:cpu_inport_call;porta_write,portb_write:cpu_outport_call);
       function save_snapshot(data:pbyte):word;
       procedure load_snapshot(data:pbyte);
     private
       OPN:pfm_opn;
       REGS:array[0..255] of byte;
       timer_adjust:single;
       timer1,timer2,chip_number:byte;
       ay8910_int:ay8910_chip;
       procedure reset_channels(chan:byte);
       procedure write_int(port,data:byte);
  end;

var
  ym2203_0,ym2203_1:ym2203_chip;

procedure ym2203_0_timer1;
procedure ym2203_0_timer2;
procedure ym2203_1_timer1;
procedure ym2203_1_timer2;
procedure ym2203_0_init_timer_a(count:single);
procedure ym2203_0_init_timer_b(count:single);
procedure ym2203_1_init_timer_a(count:single);
procedure ym2203_1_init_timer_b(count:single);

implementation
var
  chips_total:integer=-1;

procedure change_ay_clock_0(clock:dword);
begin
  if ym2203_0<>nil then ym2203_0.ay8910_int.change_clock(clock);
end;

procedure change_ay_clock_1(clock:dword);
begin
  if ym2203_1<>nil then ym2203_1.ay8910_int.change_clock(clock);
end;

constructor ym2203_chip.create(clock:dword;amp:single;ay_amp:single);
begin
  chips_total:=chips_total+1;
  self.amp:=amp;
  self.ay8910_int:=ay8910_chip.create(clock,AY8910,ay_amp,true); //El PSG
  self.OPN:=opn_init(4); //Inicializo el OPN
  //Inicializo el state
  self.OPN.type_:=TYPE_YM2203;
  self.OPN.ST.clock:=clock;
  self.OPN.ST.rate:=FREQ_BASE_AUDIO;
  self.tsample_num:=init_channel;
  self.opn.ST.IRQ_Handler:=nil;
  self.timer_adjust:=sound_status.cpu_clock/self.OPN.ST.clock;
  self.chip_number:=chips_total;
  case chips_total of
    0:begin
        self.timer1:=init_timer(sound_status.cpu_num,1,ym2203_0_timer1,false);
        self.timer2:=init_timer(sound_status.cpu_num,1,ym2203_0_timer2,false);
        self.OPN.ST.TIMER_set_a:=ym2203_0_init_timer_a;
        self.OPN.ST.TIMER_set_b:=ym2203_0_init_timer_b;
        self.OPN.ST.SSG_Clock_change:=change_ay_clock_0;
    end;
    1:begin
        self.timer1:=init_timer(sound_status.cpu_num,1,ym2203_1_timer1,false);
        self.timer2:=init_timer(sound_status.cpu_num,1,ym2203_1_timer2,false);
        self.OPN.ST.TIMER_set_a:=ym2203_1_init_timer_a;
        self.OPN.ST.TIMER_set_b:=ym2203_1_init_timer_b;
        self.OPN.ST.SSG_Clock_change:=change_ay_clock_1;
    end;
  end;
  self.Reset;
end;

procedure ym2203_chip.change_io_calls(porta_read,portb_read:cpu_inport_call;porta_write,portb_write:cpu_outport_call);
begin
  self.ay8910_int.change_io_calls(porta_read,portb_read,porta_write,portb_write);
end;

procedure ym2203_chip.change_irq_calls(irq_handler:type_irq_handler);
begin
  self.opn.ST.IRQ_Handler:=irq_handler;
end;

destructor ym2203_chip.free;
begin
//Cierro el OPN
opn_close(self.OPN);
self.OPN:=nil;
self.ay8910_int.Free;
chips_total:=chips_total-1;
end;

procedure ym2203_chip.Reset;
var
  i:byte;
  OPN:pfm_opn;
begin
		OPN:=self.OPN;
		// Reset Prescaler
	  OPNPrescaler_w(OPN,0,1);
	  // reset SSG section */
    self.ay8910_int.reset;
	  // status clear */
	  FM_IRQMASK_SET(OPN.ST,$03);
	  OPNWriteMode(OPN,$27,$30); //mode 0 , timer reset
	  OPN.eg_timer:=0;
	  OPN.eg_cnt:=0;
	  FM_STATUS_RESET(OPN.ST,$ff);
    opn.st.mode:=0;	//normal mode
  	opn.st.TA:=0;
  	opn.ST.TAC:=0;
  	opn.ST.TB:=0;
  	opn.ST.TBC:=0;
	  self.reset_channels(4);
		// reset OPerator paramater */
		for i:=$b2 downto $30 do OPNWriteReg(OPN,i,0);
		for i:=$26 downto $20 do OPNWriteReg(OPN,i,0);
end;

function ym2203_chip.save_snapshot(data:pbyte):word;
var
  temp:pbyte;
  size:word;
  f:byte;
begin
  temp:=data;
  size:=self.ay8910_int.save_snapshot(temp);inc(temp,size);
  copymemory(temp,@self.regs[0],$100);inc(temp,$100);size:=size+$100;
  copymemory(temp,@self.timer_adjust,sizeof(single));inc(temp,sizeof(single));size:=size+sizeof(single);
  temp^:=self.chip_number;inc(temp);size:=size+1;
  //ST:pFM_state;
  copymemory(temp,@self.opn.st.clock,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.opn.st.rate,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.opn.st.freqbase,sizeof(single));inc(temp,sizeof(single));size:=size+sizeof(single);
  copymemory(temp,@self.opn.st.timer_prescaler,4);inc(temp,4);size:=size+4;
  temp^:=self.opn.st.address;inc(temp);size:=size+1;
  temp^:=self.opn.st.irq;inc(temp);size:=size+1;
  temp^:=self.opn.st.irqmask;inc(temp);size:=size+1;
  temp^:=self.opn.st.status;inc(temp);size:=size+1;
  copymemory(temp,@self.opn.st.mode,4);inc(temp,4);size:=size+4;
  temp^:=self.opn.st.prescaler_sel;inc(temp);size:=size+1;
  temp^:=self.opn.st.fn_h;inc(temp);size:=size+1;
  copymemory(temp,@self.opn.st.TA,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.opn.st.TAC,sizeof(single));inc(temp,sizeof(single));size:=size+sizeof(single);
  copymemory(temp,@self.opn.st.TB,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.opn.st.TBC,sizeof(single));inc(temp,sizeof(single));size:=size+sizeof(single);
  copymemory(temp,@self.opn.ST.dt_tab[0,0],8*32*4);inc(temp,8*32*4);size:=size+(8*32*4);
  //resto
  copymemory(temp,self.opn.SL3,sizeof(FM_3Slot));inc(temp,sizeof(FM_3Slot));size:=size+sizeof(FM_3Slot);
  //channels 0..3
  for f:=0 to 3 do begin
    temp^:=self.opn.P_CH[f].ALGO;inc(temp);size:=size+1;
    temp^:=self.opn.P_CH[f].FB;inc(temp);size:=size+1;
    copymemory(temp,@self.opn.P_CH[f].op1_out[0],2*4);inc(temp,2*4);size:=size+(2*4);
    copymemory(temp,@self.opn.P_CH[f].mem_value,4);inc(temp,4);size:=size+4;
    copymemory(temp,@self.opn.P_CH[f].pms,4);inc(temp,4);size:=size+4;
    temp^:=self.opn.P_CH[f].ams;inc(temp);size:=size+1;
    copymemory(temp,@self.opn.P_CH[f].fc,4);inc(temp,4);size:=size+4;
    temp^:=self.opn.P_CH[f].kcode;inc(temp);size:=size+1;
    copymemory(temp,@self.opn.P_CH[f].block_fnum,4);inc(temp,4);size:=size+4;
    copymemory(temp,self.opn.P_CH[f].SLOT[0],sizeof(fm_slot));inc(temp,sizeof(fm_slot));size:=size+sizeof(fm_slot);
    copymemory(temp,self.opn.P_CH[f].SLOT[1],sizeof(fm_slot));inc(temp,sizeof(fm_slot));size:=size+sizeof(fm_slot);
    copymemory(temp,self.opn.P_CH[f].SLOT[2],sizeof(fm_slot));inc(temp,sizeof(fm_slot));size:=size+sizeof(fm_slot);
    copymemory(temp,self.opn.P_CH[f].SLOT[3],sizeof(fm_slot));inc(temp,sizeof(fm_slot));size:=size+sizeof(fm_slot);
  end;
  copymemory(temp,@self.opn.pan[0],12*4);inc(temp,12*4);size:=size+(12*4);
  copymemory(temp,@self.opn.fn_table[0],4096*4);inc(temp,4096*4);size:=size+(4096*4);
  copymemory(temp,@self.opn.lfo_freq[0],8*4);inc(temp,8*4);size:=size+(8*4);
  temp^:=self.opn.type_;inc(temp);size:=size+1;
  copymemory(temp,@self.opn.eg_cnt,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.opn.eg_timer,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.opn.eg_timer_add,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.opn.eg_timer_overflow,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.opn.fn_max,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.opn.lfo_cnt,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.opn.lfo_inc,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.opn.m2,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.opn.c1,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.opn.c2,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.opn.mem,4);size:=size+4;
  save_snapshot:=size;
end;

procedure ym2203_chip.load_snapshot(data:pbyte);
var
  temp:pbyte;
  f:byte;
begin
  temp:=data;
  self.ay8910_int.load_snapshot(temp);inc(temp,128);
  copymemory(@self.regs[0],temp,$100);inc(temp,$100);
  copymemory(@self.timer_adjust,temp,sizeof(single));inc(temp,sizeof(single));
  self.chip_number:=temp^;inc(temp);
  //ST:pFM_state;
  copymemory(@self.opn.st.clock,temp,4);inc(temp,4);
  copymemory(@self.opn.st.rate,temp,4);inc(temp,4);
  copymemory(@self.opn.st.freqbase,temp,sizeof(single));inc(temp,sizeof(single));
  copymemory(@self.opn.st.timer_prescaler,temp,4);inc(temp,4);
  self.opn.st.address:=temp^;inc(temp);
  self.opn.st.irq:=temp^;inc(temp);
  self.opn.st.irqmask:=temp^;inc(temp);
  self.opn.st.status:=temp^;inc(temp);
  copymemory(@self.opn.st.mode,temp,4);inc(temp,4);
  self.opn.st.prescaler_sel:=temp^;inc(temp);
  self.opn.st.fn_h:=temp^;inc(temp);
  copymemory(@self.opn.st.TA,temp,4);inc(temp,4);
  copymemory(@self.opn.st.TAC,temp,sizeof(single));inc(temp,sizeof(single));
  copymemory(@self.opn.st.TB,temp,4);inc(temp,4);
  copymemory(@self.opn.st.TBC,temp,sizeof(single));inc(temp,sizeof(single));
  copymemory(@self.opn.ST.dt_tab[0,0],temp,8*32*4);inc(temp,8*32*4);
  //resto
  copymemory(self.opn.SL3,temp,sizeof(FM_3Slot));inc(temp,sizeof(FM_3Slot));
  //Channels 0..3
  for f:=0 to 3 do begin
    self.opn.P_CH[f].ALGO:=temp^;inc(temp);
    self.opn.P_CH[f].FB:=temp^;inc(temp);
    copymemory(@self.opn.P_CH[f].op1_out[0],temp,2*4);inc(temp,2*4);
    copymemory(@self.opn.P_CH[f].mem_value,temp,4);inc(temp,4);
    copymemory(@self.opn.P_CH[f].pms,temp,4);inc(temp,4);
    self.opn.P_CH[f].ams:=temp^;inc(temp);
    copymemory(@self.opn.P_CH[f].fc,temp,4);inc(temp,4);
    self.opn.P_CH[f].kcode:=temp^;inc(temp);
    copymemory(@self.opn.P_CH[f].block_fnum,temp,4);inc(temp,4);
    copymemory(self.opn.P_CH[f].SLOT[0],temp,sizeof(fm_slot));inc(temp,sizeof(fm_slot));
    copymemory(self.opn.P_CH[f].SLOT[1],temp,sizeof(fm_slot));inc(temp,sizeof(fm_slot));
    copymemory(self.opn.P_CH[f].SLOT[2],temp,sizeof(fm_slot));inc(temp,sizeof(fm_slot));
    copymemory(self.opn.P_CH[f].SLOT[3],temp,sizeof(fm_slot));inc(temp,sizeof(fm_slot));
    setup_connection(self.OPN,self.OPN.P_CH[f],self.chip_number);
    self.opn.P_CH[f].SLOT[0].DT:=@self.OPN.ST.dt_tab[self.opn.P_CH[f].SLOT[0].det_mul_val];
    self.opn.P_CH[f].SLOT[1].DT:=@self.OPN.ST.dt_tab[self.opn.P_CH[f].SLOT[1].det_mul_val];
    self.opn.P_CH[f].SLOT[2].DT:=@self.OPN.ST.dt_tab[self.opn.P_CH[f].SLOT[2].det_mul_val];
    self.opn.P_CH[f].SLOT[3].DT:=@self.OPN.ST.dt_tab[self.opn.P_CH[f].SLOT[3].det_mul_val];
  end;
  copymemory(@self.opn.pan[0],temp,12*4);inc(temp,12*4);
  copymemory(@self.opn.fn_table[0],temp,4096*4);inc(temp,4096*4);
  copymemory(@self.opn.lfo_freq[0],temp,8*4);inc(temp,8*4);
  self.opn.type_:=temp^;inc(temp);
  copymemory(@self.opn.eg_cnt,temp,4);inc(temp,4);
  copymemory(@self.opn.eg_timer,temp,4);inc(temp,4);
  copymemory(@self.opn.eg_timer_add,temp,4);inc(temp,4);
  copymemory(@self.opn.eg_timer_overflow,temp,4);inc(temp,4);
  copymemory(@self.opn.fn_max,temp,4);inc(temp,4);
  copymemory(@self.opn.lfo_cnt,temp,4);inc(temp,4);
  copymemory(@self.opn.lfo_inc,temp,4);inc(temp,4);
  copymemory(@self.opn.m2,temp,4);inc(temp,4);
  copymemory(@self.opn.c1,temp,4);inc(temp,4);
  copymemory(@self.opn.c2,temp,4);inc(temp,4);
  copymemory(@self.opn.mem,temp,4);
end;

procedure ym2203_chip.reset_channels(chan:byte);
var
  c,s:byte;
  OPN:pfm_opn;
begin
  opn:=self.opn;
	for c:=0 to chan-1 do begin
		opn.p_CH[c].fc:=0;
		for s:=0 to 3 do begin
			opn.p_CH[c].SLOT[s].ssg:=0;
			opn.p_CH[c].SLOT[s].ssgn:=0;
			opn.p_CH[c].SLOT[s].state:=EG_OFF;
			opn.p_CH[c].SLOT[s].volume:=MAX_ATT_INDEX;
			opn.p_CH[c].SLOT[s].vol_out:=MAX_ATT_INDEX;
		end;
	end;
end;

procedure ym2203_chip.update;
var
  OPN:pfm_opn;
  lt:integer;
  cch:array[0..2] of pfm_chan;
begin
		OPN:=self.OPN;
		cch[0]:=OPN.p_CH[0];
		cch[1]:=OPN.p_CH[1];
		cch[2]:=OPN.p_CH[2];
    // refresh PG and EG */
	  refresh_fc_eg_chan(OPN,cch[0]);
	  refresh_fc_eg_chan(OPN,cch[1]);
		if ((OPN.ST.mode and $c0)<>0) then begin
		  // 3SLOT MODE */
		  if (cch[2].SLOT[SLOT1].Incr=-1) then begin
			  refresh_fc_eg_slot(OPN,cch[2].SLOT[SLOT1],OPN.SL3.fc[1],OPN.SL3.kcode[1] );
			  refresh_fc_eg_slot(OPN,cch[2].SLOT[SLOT2],OPN.SL3.fc[2],OPN.SL3.kcode[2] );
			  refresh_fc_eg_slot(OPN,cch[2].SLOT[SLOT3],OPN.SL3.fc[0],OPN.SL3.kcode[0] );
			  refresh_fc_eg_slot(OPN,cch[2].SLOT[SLOT4],cch[2].fc,cch[2].kcode );
		  end;
    end else begin
      refresh_fc_eg_chan(OPN,cch[2]);
    end;
	  // YM2203 doesn't have LFO so we must keep these globals at 0 level */
	  LFO_AM:= 0;
	  LFO_PM:= 0;
	  // buffering */
    out_fm[0]:= 0;
    out_fm[1]:= 0;
    out_fm[2]:= 0;
		  // advance envelope generator */
    OPN.eg_timer:=OPN.eg_timer+OPN.eg_timer_add;
    while (OPN.eg_timer>=OPN.eg_timer_overflow) do begin
			  OPN.eg_timer:=OPN.eg_timer-OPN.eg_timer_overflow;
			  OPN.eg_cnt:=OPN.eg_cnt+1;
			  advance_eg_channel(OPN,cch[0]);
			  advance_eg_channel(OPN,cch[1]);
			  advance_eg_channel(OPN,cch[2]);
    end;
    // calculate FM
    chan_calc(OPN,cch[0]);
    chan_calc(OPN,cch[1]);
    chan_calc(OPN,cch[2]);
    lt:=self.ay8910_int.update_internal^;
    lt:=lt+trunc((out_fm[0]+out_fm[1]+out_fm[2])*self.amp);
    if lt>$7fff then lt:=$7fff
      else if lt<-$7fff then lt:=-$7fff;
    tsample[self.tsample_num,sound_status.posicion_sonido]:=lt;
    INTERNAL_TIMER_A(self.OPN.ST,self.OPN.p_ch[2]);
    INTERNAL_TIMER_B(self.OPN.ST)
end;

procedure ym2203_chip.write_int(port,data:byte);
var
  OPN:pfm_opn;
  addr:integer;
begin
OPN:=self.OPN;
if ((port and 1)=0) then begin // address port */
   OPN.ST.address:=data;
   // Write register to SSG emulator */
   if (data<$10) then self.ay8910_int.Control(data);
   // prescaler select : 2d,2e,2f  */
   if ((data>=$2d) and (data<=$2f)) then OPNPrescaler_w(OPN,data,1);
end else begin // data port */
   addr:=OPN.ST.address;
   self.REGS[addr]:=data;
   case (addr and $f0) of
       $00:begin	// 0x00-0x0f : SSG section */
              self.ay8910_int.Write(data); // Write data to SSG emulator */
           end;
       $20:begin	// 0x20-0x2f : Mode section */
                //YM2203UpdateReq(n);
		// write register */
		OPNWriteMode(OPN,addr,data);
           end;
       else begin	// 0x30-0xff : OPN section */
                //YM2203UpdateReq(n);
		// write register */
		OPNWriteReg(OPN,addr,data);
            end;
   end;
end;
end;

function ym2203_chip.status:byte;
begin
  status:=self.OPN.ST.status;
end;

function ym2203_chip.read:byte;
var
   ret:byte;
begin
if (self.OPN.ST.address<16) then ret:=self.ay8910_int.Read
   else ret:=0;
read:=ret;
end;

procedure ym2203_chip.control(data:byte);
begin
  self.write_int(0,data);
end;

procedure ym2203_chip.write(data:byte);
begin
  self.write_int(1,data);
end;

procedure ym2203_0_timer1;
begin
  TimerAOver(ym2203_0.OPN.ST);
  if (ym2203_0.OPN.ST.mode and $80)<>0 then begin
			// CSM mode auto key on */
			CSMKeyControll(ym2203_0.OPN.p_ch[2]);
  end;
end;

procedure ym2203_0_timer2;
begin
  TimerBOver(ym2203_0.OPN.ST);
end;

procedure ym2203_1_timer1;
begin
  TimerAOver(ym2203_1.OPN.ST);
  if (ym2203_1.OPN.ST.mode and $80)<>0 then begin
			// CSM mode auto key on */
			CSMKeyControll(ym2203_1.OPN.p_ch[2]);
  end;
end;

procedure ym2203_1_timer2;
begin
  TimerBOver(ym2203_1.OPN.ST);
end;

procedure change_timer_status(timer_num:byte;timer_adjust:single);
begin
  if timer_adjust=0 then timer[timer_num].enabled:=false
    else begin
      timer[timer_num].enabled:=true;
      timer[timer_num].time_final:=timer_adjust;
    end;
end;

procedure ym2203_0_init_timer_a(count:single);
begin
  change_timer_status(ym2203_0.timer1,count*ym2203_0.timer_adjust);
end;

procedure ym2203_0_init_timer_b(count:single);
begin
  change_timer_status(ym2203_0.timer2,count*ym2203_0.timer_adjust);
end;

procedure ym2203_1_init_timer_a(count:single);
begin
  change_timer_status(ym2203_1.timer1,count*ym2203_1.timer_adjust);
end;

procedure ym2203_1_init_timer_b(count:single);
begin
  change_timer_status(ym2203_1.timer2,count*ym2203_1.timer_adjust);
end;

end.
