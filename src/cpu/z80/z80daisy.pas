unit z80daisy;

interface
type
  tipo_z80_daisy=record
    ack:function:byte;
    reti:procedure;
    state:function:byte;
  end;
const
  Z80_DAISY_INT=$01;		// interrupt request mask
  Z80_DAISY_IEO=$02;		// interrupt disable mask (IEO)

  Z80_PIO0_TYPE=0;
  Z80_PIO1_TYPE=1;
  Z80_CTC0_TYPE=$10;
  Z80_DAISY_NONE=$FF;

  Z80_MAX_DAISY=3-1;
var
  z80daisy_llamadas:array[0..Z80_MAX_DAISY] of tipo_z80_daisy;
  z80daisy_num_dev:integer;

function z80daisy_ack:byte;
procedure z80daisy_reti;
function z80daisy_state:boolean;
procedure z80daisy_init(tipo0:byte=Z80_DAISY_NONE;tipo1:byte=Z80_DAISY_NONE;tipo2:byte=Z80_DAISY_NONE);

implementation
uses z80pio,z80ctc;

procedure poner_llamadas_por_tipo(pos,tipo:byte);
begin
case tipo of
  Z80_PIO0_TYPE:begin
                  z80daisy_llamadas[pos].ack:=pio0_irq_ack;
                  z80daisy_llamadas[pos].reti:=pio0_irq_reti;
                  z80daisy_llamadas[pos].state:=pio0_irq_state;
               end;
  Z80_CTC0_TYPE:begin
                  z80daisy_llamadas[pos].state:=ctc0_irq_state;
                  z80daisy_llamadas[pos].ack:=ctc0_irq_ack;
                  z80daisy_llamadas[pos].reti:=ctc0_irq_reti;
               end;
  Z80_DAISY_NONE:begin
                  z80daisy_llamadas[pos].ack:=nil;
                  z80daisy_llamadas[pos].reti:=nil;
                  z80daisy_llamadas[pos].state:=nil;
               end;
end;
end;

procedure z80daisy_init(tipo0,tipo1,tipo2:byte);
begin
  poner_llamadas_por_tipo(0,tipo0);
  if tipo0<>Z80_DAISY_NONE then z80daisy_num_dev:=0
    else z80daisy_num_dev:=-1;
  poner_llamadas_por_tipo(1,tipo1);
  if tipo1<>Z80_DAISY_NONE then z80daisy_num_dev:=z80daisy_num_dev+1;
  poner_llamadas_por_tipo(2,tipo2);
  if tipo2<>Z80_DAISY_NONE then z80daisy_num_dev:=z80daisy_num_dev+1;
end;

function z80daisy_ack:byte;
var
  f,state:byte;
begin
  for f:=0 to z80daisy_num_dev do begin
    if @z80daisy_llamadas[f].state<>nil then begin
      state:=z80daisy_llamadas[f].state;
      if (state and Z80_DAISY_INT)<>0 then begin
			  z80daisy_ack:=z80daisy_llamadas[f].ack;
        exit;
      end;
    end;
  end;
	z80daisy_ack:=$ff;
end;

procedure z80daisy_reti;
var
  f,state:byte;
begin
// loop over all devices; dev[0] is highest priority
	for f:=0 to z80daisy_num_dev do begin
		if @z80daisy_llamadas[f].state<>nil then begin
      state:=z80daisy_llamadas[f].state;
		  //if this device is asserting the IEO line, that's the one we want
		  if (state and Z80_DAISY_IEO)<>0 then begin
  			z80daisy_llamadas[f].reti;
        exit;
      end;
    end;
  end;
end;

function z80daisy_state:boolean;
var
  f,state:byte;
begin
for f:=0 to z80daisy_num_dev do begin
		if @z80daisy_llamadas[f].state<>nil then begin
      state:=z80daisy_llamadas[f].state;
		  // if this device is asserting the INT line, that's the one we want
		  if (state and Z80_DAISY_INT)<>0 then begin
        z80daisy_state:=true;
        exit;
      end;
		  // if this device is asserting the IEO line, it blocks everyone else
		  if (state and Z80_DAISY_IEO)<>0 then begin
        z80daisy_state:=false;
        exit;
      end;
	end;
end;
z80daisy_state:=false;
end;

end.
