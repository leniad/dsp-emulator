unit ym_3812;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}fmopl,timer_engine,sound_engine;

const
  MAX_YM3812=2-1;

type
  YM3812_f=record
     OPL:pfm_opl;
     tsample:byte;
     timer1,timer2:byte;
     amp:byte;
  end;
  pYM3812_f=^YM3812_f;
  IRQ_Handler=procedure (irqstate:byte);
var
  FM3812:array[0..MAX_YM3812] of pYM3812_f;

procedure YM3812_Update(num:byte);
procedure YM3812_Init(num:byte;clock:dword;irq_func:IRQ_Handler;amp:byte=1);
procedure YM3812_Reset(num:byte);
procedure YM3812_Close(num:byte);
procedure YM3812_control_port(num,data:byte);
procedure YM3812_write_port(num,data:byte);
function YM3812_status_port(num:byte):integer;
function YM3812_read_port(num:byte):integer;
procedure ym3812_timer_handler(num,timer_num:byte;period:single);
procedure ym3812_timer1_0;
procedure ym3812_timer2_0;
procedure ym3812_timer1_1;
procedure ym3812_timer2_1;


implementation

procedure ym3812_init_timers(num:byte);
begin
  //Timers
  case num of
    0:begin
        FM3812[num].timer1:=init_timer(sound_status.cpu_num,1,ym3812_timer1_0,false);
        FM3812[num].timer2:=init_timer(sound_status.cpu_num,1,ym3812_timer2_0,false);
      end;
    1:begin
        FM3812[num].timer1:=init_timer(sound_status.cpu_num,1,ym3812_timer1_1,false);
        FM3812[num].timer2:=init_timer(sound_status.cpu_num,1,ym3812_timer2_1,false);
      end;
  end;
end;

procedure YM3812_Init(num:byte;clock:dword;irq_func:IRQ_Handler;amp:byte=1);
var
  rate:integer;
begin
  rate:=round(clock/72);
	// emulator create */
  if FM3812[num]=nil then begin
    getmem(FM3812[num],sizeof(ym3812_f));
    fillchar(FM3812[num]^,SizeOf(ym3812_f),0);
  end;
  FM3812[num].OPL:=OPLCreate(sound_status.cpu_clock,clock,rate);
  YM3812_Reset(num);
  fm3812[num].OPL.type_:=OPL_TYPE_WAVESEL;
  FM3812[num].tsample:=init_channel;
  FM3812[num].OPL.IRQ_Handler:=irq_func;
  FM3812[num].amp:=amp;
  ym3812_init_timers(num);
end;

procedure YM3812_close(num:byte);
var
  OPL:pfm_opl;
begin
	OPL:=FM3812[num].OPL;
	OPLClose(OPL);
  freemem(FM3812[num]);
  FM3812[num]:=nil;
end;

procedure YM3812_Reset(num:byte);
var
  OPL:pfm_opl;
begin
	OPL:=FM3812[num].OPL;
	OPLResetChip(num,OPL);
end;

procedure YM3812_Update(num:byte);
var
	OPL:pFM_OPL;
  lt:integer;
begin
  OPL:=FM3812[num].OPL;
  // rhythm slots */
  SLOT7_1:=OPL.P_CH[7].SLOT[SLOT1];
  SLOT7_2:=OPL.P_CH[7].SLOT[SLOT2];
  SLOT8_1:=OPL.P_CH[8].SLOT[SLOT1];
  SLOT8_2:=OPL.P_CH[8].SLOT[SLOT2];

  OPL.output:=0;
	advance_lfo(OPL);
  // FM part */
  OPL_CALC_CH(OPL,OPL.P_CH[0]);
  OPL_CALC_CH(OPL,OPL.P_CH[1]);
  OPL_CALC_CH(OPL,OPL.P_CH[2]);
  OPL_CALC_CH(OPL,OPL.P_CH[3]);
  OPL_CALC_CH(OPL,OPL.P_CH[4]);
  OPL_CALC_CH(OPL,OPL.P_CH[5]);
  if (OPL.rhythm and $20)=0 then begin
			OPL_CALC_CH(OPL,OPL.P_CH[6]);
			OPL_CALC_CH(OPL,OPL.P_CH[7]);
			OPL_CALC_CH(OPL,OPL.P_CH[8]);
  end else begin		// Rhythm part */
			OPL_CALC_RH(OPL,OPL.noise_rng and 1);
  end;
  lt:=(OPL.output div 2)*FM3812[num].amp;
  //lt:=lt shr FINAL_SH;
  // limit check */
  if lt>$7fff then lt:=$7fff;
  if lt<-$7fff then lt:=-$7fff;
  tsample[FM3812[num].tsample,sound_status.posicion_sonido]:=lt;
  if sound_status.stereo then tsample[FM3812[num].tsample,sound_status.posicion_sonido+1]:=lt;
  // store to sound buffer */
  advance(OPL);
end;

procedure YM3812_control_port(num,data:byte);
begin
  FM3812[num].OPL.address:=data;
end;

procedure YM3812_write_port(num,data:byte);
begin
		OPLWriteReg(num,FM3812[num].OPL,FM3812[num].OPL.address,data);
end;

function YM3812_status_port(num:byte):integer;
begin
	YM3812_status_port:=(FM3812[num].OPL.status and (FM3812[num].OPL.statusmask or $80)) or $06 ;
end;

function YM3812_read_port(num:byte):integer;
begin
	YM3812_read_port:=$ff;
end;

procedure ym3812_timer_handler(num,timer_num:byte;period:single);
begin
  case timer_num of
    0:if period=0 then timer[FM3812[num].timer1].enabled:=false
        else begin
          timer[FM3812[num].timer1].time_final:=period;
          timer[FM3812[num].timer1].enabled:=true;
        end;
    1:if period=0 then timer[FM3812[num].timer2].enabled:=false
        else begin
          timer[FM3812[num].timer2].time_final:=period;
          timer[FM3812[num].timer2].enabled:=true;
        end;
  end;
end;

procedure ym3812_timer1_0;
begin
  OPLTimerOver(0,FM3812[0].OPL,0);
end;

procedure ym3812_timer2_0;
begin
  OPLTimerOver(0,FM3812[0].OPL,1);
end;

procedure ym3812_timer1_1;
begin
  OPLTimerOver(1,FM3812[1].OPL,0);
end;

procedure ym3812_timer2_1;
begin
  OPLTimerOver(1,FM3812[1].OPL,1);
end;


end.
