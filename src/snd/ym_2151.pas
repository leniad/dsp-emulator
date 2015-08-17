unit ym_2151;

interface
uses fm_2151,sound_engine{$ifdef windows},windows{$endif};
type
  IRQ_Handler=procedure (irqstate:byte);
  porthandler=procedure (valor:byte);

function YM2151_status_port_read(num:byte):byte;
procedure YM2151_Init(num:byte;clock:dword;port_func:porthandler;irq_func:IRQ_Handler;amp:single=1);
procedure YM2151_register_port_write(num,data:byte);
procedure YM2151_data_port_write(num,data:byte);
procedure YM2151_Reset(num:byte);
procedure YM2151_Update(num:byte);
procedure YM2151_Close(num:byte);

implementation

function YM2151_status_port_read(num:byte):byte;
begin
	YM2151_status_port_read:=YM_2151ReadStatus(num);
end;

procedure YM2151_register_port_write(num,data:byte);
begin
  FM2151[num].lastreg:=data;
end;

procedure YM2151_data_port_write(num,data:byte);
begin
	YM_2151WriteReg(num,FM2151[num].lastreg,data);
end;

procedure YM2151_Init(num:byte;clock:dword;port_func:porthandler;irq_func:IRQ_Handler;amp:single=1);
begin
  YM_2151Init(num,clock);
  FM2151[num].porthandler:=port_func;
  FM2151[num].tsample:=init_channel;
  FM2151[num].IRQ_Handler:=irq_func;
  FM2151[num].amp:=amp;
end;

procedure YM2151_Reset(num:byte);
begin
  YM_2151ResetChip(num);
end;

procedure YM2151_Update(num:byte);
var
  audio:pinteger;
begin
  audio:=YM_2151UpdateOne(num);
  if sound_status.stereo then begin
    inc(audio);
    tsample[FM2151[num].tsample,sound_status.posicion_sonido]:=trunc(audio^*FM2151[num].amp);
    inc(audio);
    tsample[FM2151[num].tsample,sound_status.posicion_sonido+1]:=trunc(audio^*FM2151[num].amp);
  end else tsample[FM2151[num].tsample,sound_status.posicion_sonido]:=trunc(audio^*FM2151[num].amp);
end;

procedure YM2151_Close(num:byte);
begin
  YM_2151Close(num);
end;

end.