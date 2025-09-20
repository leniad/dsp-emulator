unit taito_68705;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}main_engine,m6805;

const
  TIGER_HELI=1;
  ARKANOID=2;

type
      taito_68705p=class
          constructor create(clock:dword;frames_div:word;mcu_type:byte=0);
          destructor free;
        public
          main_sent,mcu_sent:boolean;
          misc_call:procedure(pos,valor:byte);
          arkanoid_call:function:byte;
          procedure reset;
          function read:byte;
          procedure write(valor:byte);
          function get_rom_addr:pbyte;
          procedure run;
          procedure change_reset(status:byte);
        private
          m68705:cpu_m6805;
          mcu_mem:array[0..$7ff] of byte;
          port_c_in,port_c_out,port_b_out,port_b_in,port_a_in,port_a_out:byte;
          ddr_a,ddr_b,ddr_c,from_main,from_mcu:byte;
          frame_mcu:single;
          read_addr_2:function:byte;
          write_addr_0:procedure(valor:byte);
        end;

var
  taito_68705_0:taito_68705p;

implementation

//Arkanoid
function arkanoid_getbyte(direccion:word):byte;
begin
direccion:=direccion and $7ff;
case direccion of
  0:arkanoid_getbyte:=(taito_68705_0.port_a_out and taito_68705_0.ddr_a) or (taito_68705_0.port_a_in and not(taito_68705_0.ddr_a));
  1:arkanoid_getbyte:=taito_68705_0.arkanoid_call;
  2:begin
      taito_68705_0.port_c_in:=byte(taito_68705_0.main_sent) or (byte(not(taito_68705_0.mcu_sent)) shl 1);
      arkanoid_getbyte:=(taito_68705_0.port_c_out and taito_68705_0.ddr_c) or (taito_68705_0.port_c_in and not(taito_68705_0.ddr_c));
    end;
  $10..$7ff:arkanoid_getbyte:=taito_68705_0.mcu_mem[direccion];
end;
end;


procedure arkanoid_putbyte(direccion:word;valor:byte);
begin
direccion:=direccion and $7ff;
case direccion of
  0:taito_68705_0.port_a_out:=valor;
  2:begin
      if (((taito_68705_0.ddr_c and 4)<>0) and ((not(valor) and 4)<>0) and ((taito_68705_0.port_c_out and 4)<>0)) then begin
        taito_68705_0.port_a_in:=taito_68705_0.from_main;
        taito_68705_0.main_sent:=false;
        taito_68705_0.m68705.irq_request(0,CLEAR_LINE);
      end;
      if (((taito_68705_0.ddr_c and 8)<>0) and ((not(valor) and 8)<>0) and ((taito_68705_0.port_c_out and 8)<>0)) then begin
        taito_68705_0.from_mcu:=taito_68705_0.port_a_out;
    	  taito_68705_0.mcu_sent:=true;
      end;
      taito_68705_0.port_c_out:=valor;
    end;
  4:taito_68705_0.ddr_a:=valor;
  6:taito_68705_0.ddr_c:=valor;
  $10..$7f:taito_68705_0.mcu_mem[direccion]:=valor;
  $80..$7ff:; //ROM
end;
end;

//Resto
function read_addr_2_st:byte;
begin

  read_addr_2_st:=byte(taito_68705_0.main_sent) or (byte(not(taito_68705_0.mcu_sent)) shl 1);
end;


function read_addr_2_tigerh:byte;

begin

  read_addr_2_tigerh:=byte(not(taito_68705_0.main_sent)) or (byte(taito_68705_0.mcu_sent) shl 1);
end;


function getbyte(direccion:word):byte;
begin
direccion:=direccion and $7ff;
case direccion of
  0:getbyte:=(taito_68705_0.port_a_out and taito_68705_0.ddr_a) or (taito_68705_0.port_a_in and not(taito_68705_0.ddr_a));
  1:getbyte:=(taito_68705_0.port_b_out and taito_68705_0.ddr_b) or (taito_68705_0.port_b_in and not(taito_68705_0.ddr_b));
  2:begin
      taito_68705_0.port_c_in:=taito_68705_0.read_addr_2;
      getbyte:=(taito_68705_0.port_c_out and taito_68705_0.ddr_c) or (taito_68705_0.port_c_in and not(taito_68705_0.ddr_c));
    end;
  $10..$7ff:getbyte:=taito_68705_0.mcu_mem[direccion];
end;
end;

procedure write_addr_0_tigerh(valor:byte);
begin
  taito_68705_0.from_mcu:=valor;
	taito_68705_0.mcu_sent:=true;
end;

procedure putbyte(direccion:word;valor:byte);
begin
direccion:=direccion and $7ff;
case direccion of
  0:begin
      taito_68705_0.port_a_out:=valor;
      if @taito_68705_0.write_addr_0<>nil then taito_68705_0.write_addr_0(valor);
    end;
  1:begin
      if (((taito_68705_0.ddr_b and 2)<>0) and ((not(valor) and 2)<>0) and ((taito_68705_0.port_b_out and 2)<>0)) then begin
        taito_68705_0.port_a_in:=taito_68705_0.from_main;
        if taito_68705_0.main_sent then begin
          taito_68705_0.m68705.irq_request(0,CLEAR_LINE);
          taito_68705_0.main_sent:=false;
        end;
      end;
      if (((taito_68705_0.ddr_b and 4)<>0) and ((valor and 4)<>0) and ((not(taito_68705_0.port_b_out) and 4)<>0)) then begin
        taito_68705_0.from_mcu:=taito_68705_0.port_a_out;
    	  taito_68705_0.mcu_sent:=true;
      end;
      if (((taito_68705_0.ddr_b and 8)<>0) and ((not(valor) and 8)<>0) and ((taito_68705_0.port_b_out and 8)<>0)) then begin
        if @taito_68705_0.misc_call<>nil then taito_68705_0.misc_call(0,taito_68705_0.port_a_out);
      end;
	    if (((taito_68705_0.ddr_b and $10)<>0) and ((not(valor) and $10)<>0) and ((taito_68705_0.port_b_out and $10)<>0)) then begin
        if @taito_68705_0.misc_call<>nil then taito_68705_0.misc_call(1,taito_68705_0.port_a_out);
      end;
      taito_68705_0.port_b_out:=valor;
    end;
  2:taito_68705_0.port_c_out:=valor;
  4:taito_68705_0.ddr_a:=valor;
  5:taito_68705_0.ddr_b:=valor;
  6:taito_68705_0.ddr_c:=valor;
  $10..$7f:taito_68705_0.mcu_mem[direccion]:=valor;
  $80..$7ff:; //ROM
end;
end;

constructor taito_68705p.create(clock:dword;frames_div:word;mcu_type:byte=0);
begin
self.m68705:=cpu_m6805.create(clock,frames_div,tipo_m68705);
self.m68705.change_ram_calls(getbyte,putbyte);
self.write_addr_0:=nil;
case mcu_type of
  0:self.read_addr_2:=read_addr_2_st;
  1:begin
      self.read_addr_2:=read_addr_2_tigerh;
      self.write_addr_0:=write_addr_0_tigerh;
    end;
  2:self.m68705.change_ram_calls(arkanoid_getbyte,arkanoid_putbyte);
end;
end;

destructor taito_68705p.free;
begin
end;

procedure taito_68705p.reset;
begin
  self.m68705.reset;
  self.port_a_in:=0;
  self.port_a_out:=0;
  self.port_b_out:=0;
  self.port_b_in:=0;
  self.port_c_in:=0;
  self.port_c_out:=0;
  self.ddr_a:=0;
  self.ddr_b:=0;
  self.ddr_c:=0;
  self.from_main:=0;
  self.from_mcu:=0;
  self.main_sent:=false;
  self.mcu_sent:=false;
  self.frame_mcu:=self.m68705.tframes;
end;

function taito_68705p.get_rom_addr:pbyte;
begin
  get_rom_addr:=@self.mcu_mem[0];
end;

procedure taito_68705p.run;
begin
  self.m68705.run(self.frame_mcu);
  self.frame_mcu:=self.frame_mcu+self.m68705.tframes-self.m68705.contador;
end;

function taito_68705p.read:byte;
begin
  read:=self.from_mcu;
  self.mcu_sent:=false;
end;

procedure taito_68705p.write(valor:byte);
begin
  self.from_main:=valor;
  self.main_sent:=true;
  self.mcu_sent:=false;
  self.m68705.irq_request(0,ASSERT_LINE);
end;

procedure taito_68705p.change_reset(status:byte);
begin
  self.m68705.change_reset(status);
end;

end.
