unit eepromser;

interface
uses main_engine,file_engine;

type
  eepromser_chip=class
                constructor create(tipo,epr_bits:byte);
                destructor free;
             public
                procedure reset;
                function do_read:byte;
                function ready_read:byte;
                procedure cs_write(epr_state:byte);
                procedure clk_write(epr_state:byte);
                procedure di_write(epr_state:byte);
                function load_data(name:string):boolean;
                procedure write_data(name:string);
                function get_data:pbyte;
             private
                state,cs_state,clk_state,di_state,bits_accum,command_address_bits:byte;
                shift_register,command_address_accum:dword;
                locked,streaming_enabled:boolean;
                tipo,command,data_bits,address_bits:byte;
                address:word;
                addrspace:array[0..$7ff] of byte;
                size_:word;
                procedure handle_event(event:byte);
                function is_ready:boolean;
                procedure execute_command;
                procedure execute_write_command;
                procedure write_(direccion,valor:word);
                procedure write_all(valor:word);
                procedure erase_(direccion:word);
                procedure erase_all;
                procedure internal_write(direccion,valor:word);
                function internal_read(direccion:word):word;
                function read_(direccion:word):word;
                procedure er5911_parse_command_and_address;
                procedure e93cxx_parse_command_and_address;
             end;

  // Xicor X24C01: 128 x 8, seven address bits plus R/W (not 24C02).
  tx24c01_phase=(xpIdle,xpAddress,xpWrite,xpDeviceAck,xpRead,xpHostAck);
  x24c01_chip=class
  public
    dirty:boolean;
    constructor create;
    procedure reset;
    procedure lines_write(new_sda,new_scl:byte);
    function do_read:byte;
    function get_data:pbyte;
    function load_data(name:string):boolean;
    procedure write_data(name:string);
 private
    memory:array[0..$7f]of byte;
    phase,after_ack:tx24c01_phase;
    scl,sda,output,address:byte;
    bits,shift,ack_phase:integer;
    continue_read:boolean;
  end;

const
    E93C06=0;
    E93C46=1;
    E93C56=2;
    E93C57=3;
    E93C66=4;
    E93C76=5;
    E93C86=6;
    ER5911=7;
    X24C44=8;

var
  eepromser_0:eepromser_chip;
  x24c01_0:x24c01_chip;

implementation
uses SysUtils;
const
    COMMAND_INVALID=0;
		COMMAND_READ=1;
		COMMAND_WRITE=2;
		COMMAND_ERASE=3;
		COMMAND_LOCK=4;
		COMMAND_UNLOCK=5;
		COMMAND_WRITEALL=6;
		COMMAND_ERASEALL=7;
		COMMAND_COPY_EEPROM_TO_RAM=8;
		COMMAND_COPY_RAM_TO_EEPROM=9;
	  // states
		STATE_IN_RESET=0;
		STATE_WAIT_FOR_START_BIT=1;
		STATE_WAIT_FOR_COMMAND=2;
		STATE_READING_DATA=3;
		STATE_WAIT_FOR_DATA=4;
		STATE_WAIT_FOR_COMPLETION=5;
	  // events
		EVENT_CS_RISING_EDGE=1 shl 0;
		EVENT_CS_FALLING_EDGE=1 shl 1;
		EVENT_CLK_RISING_EDGE=1 shl 2;
		EVENT_CLK_FALLING_EDGE=1 shl 3;

constructor eepromser_chip.create(tipo,epr_bits:byte);
function calc_address_bits(cells:byte):byte;
var
  res:byte;
begin
cells:=cells-1;
res:=0;
while (cells<>0) do begin
		cells:=cells shr 1;
		res:=res+1;
end;
calc_address_bits:=res;
end;
begin
  self.tipo:=tipo;
  case tipo of
    E93C46:begin
              if epr_bits=8 then begin
                self.command_address_bits:=7;
                self.address_bits:=calc_address_bits(128);
              end else begin
                self.command_address_bits:=6;
                self.address_bits:=calc_address_bits(64);
              end;
              self.size_:=$80;
           end;
    ER5911:begin
              if epr_bits=8 then begin
                self.command_address_bits:=9;
                self.address_bits:=calc_address_bits(128);
              end else begin
                self.command_address_bits:=8;
                self.address_bits:=calc_address_bits(64);
              end;
              self.size_:=$80;
           end;
  end;
self.data_bits:=epr_bits;
self.streaming_enabled:=false;
end;

destructor eepromser_chip.free;
begin
end;

procedure eepromser_chip.reset;
begin
	self.state:=STATE_IN_RESET;
	self.locked:=true;
	self.bits_accum:=0;
	self.command_address_accum:=0;
	self.command:=COMMAND_INVALID;
	self.address:=0;
	self.shift_register:=0;
end;

function eepromser_chip.is_ready:boolean;
begin
  is_ready:=true; //implementar...
end;

procedure eepromser_chip.internal_write(direccion,valor:word);
begin
	if (self.data_bits=16) then begin
    self.addrspace[direccion*2]:=valor shr 8;
    self.addrspace[(direccion*2)+1]:=valor and $ff;
  end else self.addrspace[direccion]:=valor;
end;

procedure eepromser_chip.write_(direccion,valor:word);
begin
	internal_write(direccion,valor);
end;

procedure eepromser_chip.write_all(valor:word);
var
  f:word;
begin
	for f:=0 to ((1 shl self.address_bits)-1) do self.internal_write(f,self.internal_read(f) and valor);
end;

procedure eepromser_chip.erase_(direccion:word);
begin
	self.internal_write(direccion,$ffff);
end;

procedure eepromser_chip.erase_all;
var
  f:word;
begin
	for f:=0 to ((1 shl self.address_bits)-1) do self.internal_write(f,$ffff);
end;

function eepromser_chip.internal_read(direccion:word):word;
begin
	if (self.data_bits=16) then internal_read:=(self.addrspace[direccion*2] shl 8)+self.addrspace[(direccion*2)+1]
    else internal_read:=self.addrspace[direccion];
end;

function eepromser_chip.read_(direccion:word):word;
begin
	read_:=self.internal_read(direccion);
end;

procedure eepromser_chip.execute_write_command;
begin
	// each command advances differently
	case self.command of
		// reset the shift register and wait for enough data to be clocked through
		COMMAND_WRITE:begin
			if self.locked then begin
				self.state:=STATE_IN_RESET;
				exit;
			end;
			self.write_(self.address,self.shift_register);
			self.state:=STATE_WAIT_FOR_COMPLETION;
    end;
		// write the entire EEPROM with the same data; ERASEALL is required before so we
		// AND against the already-present data
		COMMAND_WRITEALL:begin
			if self.locked then begin
				self.state:=STATE_IN_RESET;
				exit;
			end;
			self.write_all(self.shift_register);
			self.state:=STATE_WAIT_FOR_COMPLETION;
    end;
  end;
end;

procedure eepromser_chip.execute_command;
begin
	// parse into a generic command and reset the accumulator count
	case self.tipo of
    E93C06,E93C46,E93C56,E93C57,E93C66,E93C76,E93C86:self.e93cxx_parse_command_and_address;
    ER5911:self.er5911_parse_command_and_address;
  end;
	self.bits_accum:=0;
	// each command advances differently
	case self.command of
		// advance to the READING_DATA state; data is fetched after first CLK
		// reset the shift register to 0 to simulate the dummy 0 bit that happens prior
		// to the first clock
		COMMAND_READ:begin
			self.shift_register:=0;
			self.state:=STATE_READING_DATA;
    end;
		// reset the shift register and wait for enough data to be clocked through
		COMMAND_WRITE,COMMAND_WRITEALL:begin
			self.shift_register:=0;
			self.state:=STATE_WAIT_FOR_DATA;
    end;
		// erase the parsed address (unless locked) and wait for it to complete
		COMMAND_ERASE:begin
			if self.locked then begin
				self.state:=STATE_IN_RESET;
				exit;
			end;
			self.erase_(address);
			self.state:=STATE_WAIT_FOR_COMPLETION;
    end;
		// lock the chip; return to IN_RESET state
		COMMAND_LOCK:begin
			self.locked:=true;
			self.state:=STATE_IN_RESET;
    end;
		// unlock the chip; return to IN_RESET state
		COMMAND_UNLOCK:begin
			self.locked:=false;
			self.state:=STATE_IN_RESET;
    end;
		// erase the entire chip (unless locked) and wait for it to complete
		COMMAND_ERASEALL:begin
			if self.locked then begin
				self.state:=STATE_IN_RESET;
				exit;
			end;
			self.erase_all;
			self.state:=STATE_WAIT_FOR_COMPLETION;
    end;
  end;
end;

procedure eepromser_chip.handle_event(event:byte);
var
  bit_index:byte;
begin
	// switch off the current state
	case self.state of
		// CS is not asserted; wait for a rising CS to move us forward, ignoring all clocks
		STATE_IN_RESET:begin
      if (event=EVENT_CS_RISING_EDGE) then self.state:=STATE_WAIT_FOR_START_BIT;
    end;
		// CS is asserted; wait for rising clock with a 1 start bit; falling CS will reset us
		// note that because each bit is written independently, it is possible for us to receive
		// a false rising CLK edge at the exact same time as a rising CS edge; it appears we
		// should ignore these edges (makes sense really)
		STATE_WAIT_FOR_START_BIT:begin
			if ((event=EVENT_CLK_RISING_EDGE) and (self.di_state=ASSERT_LINE) and self.is_ready) then begin //--> and machine().time() > m_last_cs_rising_edge_time)
				self.command_address_accum:=0;
        self.bits_accum:=0;
				self.state:=STATE_WAIT_FOR_COMMAND;
			end	else begin
        if (event=EVENT_CS_FALLING_EDGE) then self.state:=STATE_IN_RESET;
			end;
    end;
		// CS is asserted; wait for a command to come through; falling CS will reset us
		STATE_WAIT_FOR_COMMAND:begin
			if (event=EVENT_CLK_RISING_EDGE) then begin
				// if we have enough bits for a command + address, check it out
				self.command_address_accum:=(self.command_address_accum shl 1) or self.di_state;
        self.bits_accum:=self.bits_accum+1;
				if (self.bits_accum=(2+self.command_address_bits)) then self.execute_command;
			end else begin
        if (event=EVENT_CS_FALLING_EDGE) then self.state:=STATE_IN_RESET;
			end;
    end;
		// CS is asserted; reading data, clock the shift register; falling CS will reset us
		STATE_READING_DATA:begin
			if (event=EVENT_CLK_RISING_EDGE) then begin
				bit_index:=self.bits_accum;
        self.bits_accum:=self.bits_accum+1;
				// wrapping the address on multi-read is required by pacslot(cave.c)
				if (((bit_index mod self.data_bits)=0) and (bit_index=0) or self.streaming_enabled) then
					self.shift_register:=self.read_((self.address+bits_accum div self.data_bits) and ((1 shl self.address_bits)-1)) shl (32-self.data_bits)
				else self.shift_register:=(self.shift_register shl 1) or 1;
			end else begin
        if (event=EVENT_CS_FALLING_EDGE) then begin
				  self.state:=STATE_IN_RESET;
			  end;
      end;
    end;
		// CS is asserted; waiting for data; clock data through until we accumulate enough; falling CS will reset us
		STATE_WAIT_FOR_DATA:begin
			if (event=EVENT_CLK_RISING_EDGE) then begin
				self.shift_register:=(self.shift_register shl 1) or self.di_state;
        self.bits_accum:=self.bits_accum+1;
				if (self.bits_accum=self.data_bits) then self.execute_write_command;
			end else begin
        if (event=EVENT_CS_FALLING_EDGE) then begin
				    self.state:=STATE_IN_RESET;
        end;
      end;
    end;
		// CS is asserted; waiting for completion; watch for CS falling
		STATE_WAIT_FOR_COMPLETION:begin
			if (event=EVENT_CS_FALLING_EDGE) then self.state:=STATE_IN_RESET;
    end;
  end;
end;

function eepromser_chip.do_read:byte;
var
  res:byte;
begin
case self.tipo of
  E93C06,E93C46,E93C56,E93C57,E93C66,E93C76,E93C86,ER5911:begin
      // in most states, the output is tristated, and generally connected to a pull up
	    // to send back a 1 value; the only exception is if reading data and the current output
	    // bit is a 0
      if ((self.state=STATE_READING_DATA) and ((self.shift_register and $80000000)=0)) then res:=CLEAR_LINE
        else res:=ASSERT_LINE;
  end;
end;
do_read:=res;
end;

function eepromser_chip.ready_read:byte;
var
res:byte;
begin
  case self.tipo of
  E93C06,E93C46,E93C56,E93C57,E93C66,E93C76,E93C86,ER5911:begin
	  // ready by default, except during long operations
    if self.is_ready then res:=ASSERT_LINE
      else res:=CLEAR_LINE;
  end;
end;
ready_read:=res;
end;
procedure eepromser_chip.cs_write(epr_state:byte);
begin
case self.tipo of
  E93C06,E93C46,E93C56,E93C57,E93C66,E93C76,E93C86,ER5911:begin
      // ignore if the state is not changing
	    epr_state:=epr_state and 1;
	    if (epr_state=self.cs_state) then exit;
	    // set the new state
	    self.cs_state:=epr_state;
	    // remember the rising edge time so we don't process CLK signals at the same time
	    // --> if (epr_state=ASSERT_LINE) then m_last_cs_rising_edge_time = machine().time();
      if (self.cs_state=ASSERT_LINE) then self.handle_event(EVENT_CS_RISING_EDGE)
        else self.handle_event(EVENT_CS_FALLING_EDGE);
  end;
end;
end;
procedure eepromser_chip.clk_write(epr_state:byte);
begin
case self.tipo of
  E93C06,E93C46,E93C56,E93C57,E93C66,E93C76,E93C86,ER5911:begin
	    // ignore if the state is not changing
	    epr_state:=epr_state and 1;
	    if (epr_state=self.clk_state) then exit;
	    // set the new state
	    self.clk_state:=epr_state;
      if (self.clk_state=ASSERT_LINE) then self.handle_event(EVENT_CLK_RISING_EDGE)
      else self.handle_event(EVENT_CLK_FALLING_EDGE);
  end;
end;
end;

procedure eepromser_chip.di_write(epr_state:byte);
begin
case self.tipo of
  E93C06,E93C46,E93C56,E93C57,E93C66,E93C76,E93C86,ER5911:self.di_state:=epr_state and 1;
end;
end;

function eepromser_chip.load_data(name:string):boolean;
var
  longitud:integer;
  res:boolean;
begin
  res:=false;
  if read_file_size(Directory.Arcade_nvram+name,longitud) then res:=read_file(Directory.Arcade_nvram+name,@self.addrspace[0],longitud);
  load_data:=res;
end;

procedure eepromser_chip.write_data(name:string);
begin
  write_file(Directory.Arcade_nvram+name,@self.addrspace[0],self.size_);
end;

function eepromser_chip.get_data:pbyte;
begin
  get_data:=@self.addrspace[0];
end;

//E93CXX
procedure eepromser_chip.e93cxx_parse_command_and_address;
begin
	// set the defaults
	self.command:=COMMAND_INVALID;
	self.address:=self.command_address_accum and ((1 shl self.command_address_bits)-1);
	// extract the command portion and handle it
	case (self.command_address_accum shr self.command_address_bits) of
		// opcode 0 needs two more bits to decode the operation
		0:begin
			  case (self.address shr (self.command_address_bits-2)) of
				  0:self.command:=COMMAND_LOCK;
				  1:self.command:=COMMAND_WRITEALL;
				  2:self.command:=COMMAND_ERASEALL;
				  3:self.command:=COMMAND_UNLOCK;
			  end;
			  self.address:=0;
    end;
		1:self.command:=COMMAND_WRITE;
		2:self.command:=COMMAND_READ;
		3:self.command:=COMMAND_ERASE;
	end;
end;

//ER5911
procedure eepromser_chip.er5911_parse_command_and_address;
begin
	// set the defaults
	self.command:=COMMAND_INVALID;
	self.address:=self.command_address_accum and ((1 shl self.command_address_bits)-1);
	// extract the command portion and handle it
	case (self.command_address_accum shr self.command_address_bits) of
		// opcode 0 needs two more bits to decode the operation
		0:begin
			  case (self.address shr (self.command_address_bits-2)) of
				  0:self.command:=COMMAND_LOCK;
				  1:self.command:=COMMAND_INVALID;// not on ER5911
				  2:self.command:=COMMAND_ERASEALL;
				  3:self.command:=COMMAND_UNLOCK;
			  end;
			  self.address:=0;
    end;
		1:self.command:=COMMAND_WRITE;
		2:self.command:=COMMAND_READ;
		3:self.command:=COMMAND_WRITE;  // WRITE instead of ERASE on ER5911
	end;
end;

constructor x24c01_chip.create;
begin
 FillChar(memory,SizeOf(memory),$ff);
 dirty:=false;
 reset;
end;

procedure x24c01_chip.reset;
begin
 phase:=xpIdle;
 scl:=1;
 sda:=1;
 output:=1;
 bits:=0;
 shift:=0;
 address:=0;
 ack_phase:=0;
end;

function x24c01_chip.do_read:byte;
begin
 Result:=sda and output; // Open-drain SDA: either participant can pull it low.
end;

procedure x24c01_chip.lines_write(new_sda,new_scl:byte);
begin
 new_sda:=new_sda and 1;
 new_scl:=new_scl and 1;
 if (scl=1) and (new_scl=1) and (sda<>new_sda) then begin
  output:=1;
  bits:=0;
  shift:=0;
  if new_sda=0 then phase:=xpAddress
    else phase:=xpIdle;
 end else if (scl=0) and (new_scl=1) then begin
  case phase of
   xpAddress,xpWrite:begin
    shift:=((shift shl 1)or new_sda)and $ff;
    inc(bits);
    if bits=8 then begin
     if phase=xpAddress then begin
      address:=(shift shr 1)and $7f;
      if(shift and 1)<>0 then after_ack:=xpRead
        else after_ack:=xpWrite;
     end else begin
      if memory[address]<>shift then begin
       memory[address]:=shift;
       dirty:=true;
      end;
      // X24C01 has four-byte write pages; reads wrap over the whole device.
      address:=(address and $7c) or ((address+1) and 3);
      after_ack:=xpWrite;
     end;
     phase:=xpDeviceAck;
     ack_phase:=0;
    end;
   end;
   xpDeviceAck:if ack_phase=1 then ack_phase:=2;
   xpRead:inc(bits);
   xpHostAck:begin
    continue_read:=new_sda=0;
    ack_phase:=1;
   end;
  end;
 end else if(scl=1)and(new_scl=0)then begin
  case phase of
   xpDeviceAck:begin
    if ack_phase=0 then begin
     output:=0;
     ack_phase:=1;
    end else if ack_phase=2 then begin
     output:=1;
     phase:=after_ack;
     bits:=0;
     shift:=0;
     if phase=xpRead then output:=(memory[address] shr 7)and 1;
    end;
   end;
   xpRead:begin
    if bits=8 then begin
     output:=1;
     phase:=xpHostAck;
     ack_phase:=0;
    end else output:=(memory[address] shr (7-bits)) and 1;
   end;
   xpHostAck:if ack_phase=1 then begin
    if continue_read then begin
     address:=(address+1)and $7f;
     bits:=0;
     phase:=xpRead;
     output:=(memory[address] shr 7) and 1;
    end else begin
     phase:=xpIdle;
     output:=1;
    end;
   end;
  end;
 end;
 sda:=new_sda;
 scl:=new_scl;
end;

function x24c01_chip.get_data:pbyte;
begin
 Result:=@memory[0];
end;

function x24c01_chip.load_data(name:string):boolean;
var n:integer;
begin
 Result:=false;
 if not read_file_size(Directory.Arcade_nvram+name,n) then exit;
 if n<>SizeOf(memory) then exit;
 Result:=read_file(Directory.Arcade_nvram+name,@memory[0],n);
 if Result then dirty:=false;
end;

procedure x24c01_chip.write_data(name:string);
begin
 write_file(Directory.Arcade_nvram+name,@memory[0],SizeOf(memory));
 dirty:=false;
end;

end.
