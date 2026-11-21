unit atari_riot;

interface

type
  tatari_riot=class
    constructor create;
    destructor free;
    public
      ram:array[0..255] of byte;
      porta,portb,ddra,ddrb,input_a,input_b:byte;
      procedure reset;
      procedure edge;
      procedure tick;
      function read(address:word):byte;
      procedure write(address:word;value:byte);
    private
      timer:byte;
      prescaler,phase,underflow_age:integer;
      running,underflow,timer_flag,edge_flag,edge_positive,edge_enable,last_pa7:boolean;
      function port_a_pins:byte;
  end;

var
  riot_0:tatari_riot;

implementation

constructor tatari_riot.create;
begin
  inherited Create;
  self.reset;
end;

destructor tatari_riot.free;
begin
end;

function tatari_riot.port_a_pins:byte;
begin
  // Port A reads the actual pins: a joystick can ground an output-high pin.
  Result:=(self.porta or byte(not self.ddra)) and self.input_a;
end;

procedure tatari_riot.edge;
var
  level:boolean;
begin
  level:=(self.port_a_pins and $80)<>0;
  if (level<>self.last_pa7) and (level=self.edge_positive) then self.edge_flag:=true;
  self.last_pa7:=level;
end;

procedure tatari_riot.tick;
var
  pa7:boolean;
begin
 pa7:=(self.port_a_pins and $80)<>0;
 if (pa7<>self.last_pa7) and (pa7=self.edge_positive) then self.edge_flag:=true;
 self.last_pa7:=pa7;
 if self.underflow and (self.underflow_age<1000000)then inc(self.underflow_age);
 if not self.running then exit;
 dec(self.phase);
 if self.phase>0 then exit;
 if self.timer=0 then begin
  self.timer:=$ff;
  if not self.underflow then begin
    self.timer_flag:=true;
    self.underflow_age:=0;
  end;
  self.underflow:=true;
 end else dec(self.timer);
 if self.underflow then self.phase:=1
  else self.phase:=self.prescaler;
end;

function tatari_riot.read(address:word):byte;
var
  reg:byte;
begin
  reg:=address and $1f;
  if(reg and 4)=0 then begin
    case (reg and 3) of
      0:result:=self.port_a_pins;
      1:result:=self.ddra;
      2:result:=(self.portb and self.ddrb) or (self.input_b and not(self.ddrb));
      3:result:=self.ddrb;
    end;
  end else if(reg and 1)=0 then begin
    result:=self.timer;
    if ((not self.underflow) or (self.underflow_age>1)) then begin
      self.timer_flag:=false;
      if self.underflow then begin
        self.underflow:=false;
        self.phase:=1;
      end;
    end;
  end else begin
    result:=byte(self.timer_flag)*$80 or byte(self.edge_flag)*$40;
    self.edge_flag:=false;
  end;
end;

procedure tatari_riot.write(address:word;value:byte);
const
  divisors:array[0..3]of integer=(1,8,64,1024);
var
  reg:byte;
begin
  reg:=address and $1f;
  if (reg and 4)=0 then begin
    case reg and 3 of
      0:self.porta:=value;
      1:self.ddra:=value;
      2:self.portb:=value;
      3:self.ddrb:=value;
    end;
    self.edge;
  end else if(reg and $10)<>0 then begin
    self.timer:=value;
    self.prescaler:=divisors[reg and 3];
    self.phase:=1;
    self.running:=true;
    self.underflow:=false;
    self.timer_flag:=false;
    self.underflow_age:=0;
  end else begin
    self.edge_positive:=(reg and 1)<>0;
    self.edge_enable:=(reg and 2)<>0;
    self.edge_flag:=false;
  end;
  // RIOT IRQ is not connected to the 6507 (which has no external IRQ pin).
end;

procedure tatari_riot.reset;
begin
  self.porta:=0;
  self.portb:=0;
  self.ddra:=0;
  self.ddrb:=0;
  self.edge_flag:=false;
  self.edge_positive:=false;
  self.edge_enable:=false;
  self.input_a:=$ff;
  self.input_b:=$ff;
  self.last_pa7:=true;
  self.timer:=$ff;
  self.prescaler:=1024;
  self.phase:=1;
  self.running:=true;
  self.underflow:=false;
  self.timer_flag:=false;
  self.underflow_age:=0;
end;

end.

