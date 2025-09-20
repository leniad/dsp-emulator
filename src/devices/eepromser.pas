unit eepromser;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     main_engine;

const
    //tipos
    E93CXX=0;
    ER5911=1;
    X24c44=2;

procedure eepromser_init(tipo,epr_bits:byte);
procedure eepromser_reset;
procedure eepromser_load_data(datos:pbyte;size:word);
function er5911_do_read:byte;
function er5911_ready_read:byte;
procedure er5911_cs_write(epr_state:byte);
procedure er5911_clk_write(epr_state:byte);
procedure er5911_di_write(epr_state:byte);
procedure er5911_parse_command_and_address;

implementation
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
		EVENT_CS_FALLING_EDGE = 1 shl 1;
		EVENT_CLK_RISING_EDGE = 1 shl 2;
		EVENT_CLK_FALLING_EDGE = 1 shl 3;

type
  t_parse_command_and_address=procedure;
var
  state,cs_state,clk_state,di_state,bits_accum,command_address_bits:byte;
  shift_register,command_address_accum:dword;
  locked,streaming_enabled:boolean;
  command,data_bits,address_bits:byte;
  address:word;
  parse_command_and_address:t_parse_command_and_address;
  addrspace:array[0..$7ff] of byte;

procedure eepromser_load_data(datos:pbyte;size:word);
begin
  copymemory(@addrspace[0],datos,size);
end;

function eeprom_ready:boolean;
begin
  eeprom_ready:=true; //implementar...
end;

//-------------------------------------------------
//  internal_read - read data at the given address
//-------------------------------------------------
function internal_read(direccion:word):word;
begin
	if (data_bits=16) then internal_read:=(addrspace[direccion*2] shl 8)+addrspace[(direccion*2)+1]
    else internal_read:=addrspace[direccion];
end;

//-------------------------------------------------
//  internal_write - write data at the given
//  address
//-------------------------------------------------

procedure internal_write(direccion,valor:word);
begin
	if (data_bits=16) then begin
    addrspace[direccion*2]:=valor shr 8;
    addrspace[(direccion*2)]:=valor and $ff;
  end else addrspace[direccion]:=valor;
end;

//-------------------------------------------------
//  read - read data at the given address
//-------------------------------------------------
function read_(direccion:word):word;
begin
	//if not(eeprom_ready) then logerror("EEPROM: Read performed before previous operation completed!");
	read_:=internal_read(direccion);
end;

//-------------------------------------------------
//  write - write data at the given address
//-------------------------------------------------
procedure write_(direccion,valor:word);
begin
	//if not(eeprom_ready) then logerror("EEPROM: Write performed before previous operation completed!");
	internal_write(direccion,valor);
	//m_completion_time = machine().time() + m_operation_time[WRITE_TIME];
end;

//-------------------------------------------------
//  write_all - write data at all addresses
//  (assumes an erase has previously been
//  performed)
//-------------------------------------------------
procedure write_all(valor:word);
var
  f:word;
begin
	//if not (eeprm_ready) then logerror("EEPROM: Write all performed before previous operation completed!");
	for f:=0 to ((1 shl address_bits)-1) do internal_write(f,internal_read(f) and valor);
	//m_completion_time = machine().time() + m_operation_time[WRITE_ALL_TIME];
end;

//-------------------------------------------------
//  erase - erase data at the given address
//-------------------------------------------------
procedure erase_(direccion:word);
begin
	//if not(eeprom_ready) then logerror("EEPROM: Erase performed before previous operation completed!");
	internal_write(direccion,$ffff);
	//m_completion_time = machine().time() + m_operation_time[ERASE_TIME];
end;

//-------------------------------------------------
//  erase_all - erase data at all addresses
//-------------------------------------------------
procedure erase_all;
var
  f:word;
begin
	//if not(eeprom_ready) then logerror("EEPROM: Erase all performed before previous operation completed!");
	for f:=0 to ((1 shl address_bits)-1) do internal_write(f,$ffff);
	//m_completion_time = machine().time() + m_operation_time[ERASE_ALL_TIME];
end;

//-------------------------------------------------
//  set_state - update the state to a new one
//-------------------------------------------------
procedure set_state(newstate:byte);
begin
	// switch to the new state
	state:=newstate;
end;

//-------------------------------------------------
//  execute_write_command - execute a write
//  command after receiving the data bits
//-------------------------------------------------
procedure execute_write_command;
begin
	// each command advances differently
	case command of
		// reset the shift register and wait for enough data to be clocked through
		COMMAND_WRITE:begin
			if locked then begin
				set_state(STATE_IN_RESET);
				exit;
			end;
			write_(address,shift_register);
			set_state(STATE_WAIT_FOR_COMPLETION);
    end;
		// write the entire EEPROM with the same data; ERASEALL is required before so we
		// AND against the already-present data
		COMMAND_WRITEALL:begin
			if locked then begin
				set_state(STATE_IN_RESET);
				exit;
			end;
			write_all(shift_register);
			set_state(STATE_WAIT_FOR_COMPLETION);
    end;
  end;
end;

//-------------------------------------------------
//  execute_command - execute a command once we
//  have enough bits for one
//-------------------------------------------------
procedure execute_command;
begin
	// parse into a generic command and reset the accumulator count
	parse_command_and_address;
	bits_accum:=0;
	// each command advances differently
	case (command) of
		// advance to the READING_DATA state; data is fetched after first CLK
		// reset the shift register to 0 to simulate the dummy 0 bit that happens prior
		// to the first clock
		COMMAND_READ:begin
			shift_register:=0;
			set_state(STATE_READING_DATA);
    end;
		// reset the shift register and wait for enough data to be clocked through
		COMMAND_WRITE,COMMAND_WRITEALL:begin
			shift_register:=0;
			set_state(STATE_WAIT_FOR_DATA);
    end;
		// erase the parsed address (unless locked) and wait for it to complete
		COMMAND_ERASE:begin
			if (locked) then begin
				set_state(STATE_IN_RESET);
				exit;
			end;
			erase_(address);
			set_state(STATE_WAIT_FOR_COMPLETION);
    end;
		// lock the chip; return to IN_RESET state
		COMMAND_LOCK:begin
			locked:=true;
			set_state(STATE_IN_RESET);
    end;
		// unlock the chip; return to IN_RESET state
		COMMAND_UNLOCK:begin
			locked:=false;
			set_state(STATE_IN_RESET);
    end;
		// erase the entire chip (unless locked) and wait for it to complete
		COMMAND_ERASEALL:begin
			if (locked) then begin
				set_state(STATE_IN_RESET);
				exit;
			end;
			erase_all();
			set_state(STATE_WAIT_FOR_COMPLETION);
    end;
  end;
end;

//-------------------------------------------------
//  handle_event - handle an event via the state
//  machine
//-------------------------------------------------
procedure handle_event(event:byte);
var
  bit_index:byte;
begin
	// switch off the current state
	case state of
		// CS is not asserted; wait for a rising CS to move us forward, ignoring all clocks
		STATE_IN_RESET:begin
      if (event=EVENT_CS_RISING_EDGE) then set_state(STATE_WAIT_FOR_START_BIT);
    end;
		// CS is asserted; wait for rising clock with a 1 start bit; falling CS will reset us
		// note that because each bit is written independently, it is possible for us to receive
		// a false rising CLK edge at the exact same time as a rising CS edge; it appears we
		// should ignore these edges (makes sense really)
		STATE_WAIT_FOR_START_BIT:begin
			if ((event=EVENT_CLK_RISING_EDGE) and (di_state=ASSERT_LINE) and eeprom_ready) then begin //--> and machine().time() > m_last_cs_rising_edge_time)
				command_address_accum:=0;
        bits_accum:=0;
				set_state(STATE_WAIT_FOR_COMMAND);
			end	else begin
        if (event=EVENT_CS_FALLING_EDGE) then set_state(STATE_IN_RESET);
			end;
    end;
		// CS is asserted; wait for a command to come through; falling CS will reset us
		STATE_WAIT_FOR_COMMAND:begin
			if (event=EVENT_CLK_RISING_EDGE) then begin
				// if we have enough bits for a command + address, check it out
				command_address_accum:=(command_address_accum shl 1) or di_state;
        bits_accum:=bits_accum+1;
				if (bits_accum=(2+command_address_bits)) then execute_command();
			end else begin
        if (event=EVENT_CS_FALLING_EDGE) then set_state(STATE_IN_RESET);
			end;
    end;
		// CS is asserted; reading data, clock the shift register; falling CS will reset us
		STATE_READING_DATA:begin
			if (event=EVENT_CLK_RISING_EDGE) then begin
				bit_index:=bits_accum;
        bits_accum:=bits_accum+1;
				// wrapping the address on multi-read is required by pacslot(cave.c)
				if ((((bit_index mod data_bits))=0) and (bit_index=0) or streaming_enabled) then
					shift_register:=read_((address+bits_accum div data_bits) and ((1 shl address_bits)-1)) shl (32-data_bits)
				else shift_register:=(shift_register shl 1) or 1;
			end else begin
        if (event=EVENT_CS_FALLING_EDGE) then begin
				  set_state(STATE_IN_RESET);
          {if (m_streaming_enabled)
					  LOG1(("  (%d cells read)\n", m_bits_accum / m_data_bits));
				  if (!m_streaming_enabled && m_bits_accum > m_data_bits + 1)
					  LOG0(("EEPROM: Overclocked read by %d bits\n", m_bits_accum - m_data_bits));
				  else if (m_streaming_enabled && m_bits_accum > m_data_bits + 1 && m_bits_accum % m_data_bits > 2)
					  LOG0(("EEPROM: Overclocked read by %d bits\n", m_bits_accum % m_data_bits));
				  else if (m_bits_accum < m_data_bits)
					  LOG0(("EEPROM: CS deasserted in READING_DATA after %d bits\n", m_bits_accum));}
			  end;
      end;
    end;
		// CS is asserted; waiting for data; clock data through until we accumulate enough; falling CS will reset us
		STATE_WAIT_FOR_DATA:begin
			if (event=EVENT_CLK_RISING_EDGE) then begin
				shift_register:=(shift_register shl 1) or di_state;
        bits_accum:=bits_accum+1;
				if (bits_accum=data_bits) then execute_write_command();
			end else begin
        if (event=EVENT_CS_FALLING_EDGE) then begin
				    set_state(STATE_IN_RESET);
        end;
      end;
    end;
		// CS is asserted; waiting for completion; watch for CS falling
		STATE_WAIT_FOR_COMPLETION:begin
			if (event=EVENT_CS_FALLING_EDGE) then set_state(STATE_IN_RESET);
    end;
  end;
end;

//-------------------------------------------------
//  base_do_read - read the state of the data
//  output (DO) line
//-------------------------------------------------
function base_do_read:byte;
var
  res:byte;
begin
	// in most states, the output is tristated, and generally connected to a pull up
	// to send back a 1 value; the only exception is if reading data and the current output
	// bit is a 0
  if ((state=STATE_READING_DATA) and ((shift_register and $80000000)=0)) then res:=CLEAR_LINE
    else res:=ASSERT_LINE;
	base_do_read:=res;
end;

//-------------------------------------------------
//  base_ready_read - read the state of the
//  READY/BUSY line
//-------------------------------------------------
function base_ready_read:byte;
var
  res:byte;
begin
	// ready by default, except during long operations
  if eeprom_ready then res:=ASSERT_LINE
    else res:=CLEAR_LINE;
	base_ready_read:=res;
end;

//-------------------------------------------------
//  base_cs_write - set the state of the chip
//  select (CS) line
//-------------------------------------------------
procedure base_cs_write(epr_state:byte);
begin
	// ignore if the state is not changing
	epr_state:=epr_state and 1;
	if (epr_state=cs_state) then exit;
	// set the new state
	cs_state:=epr_state;
	// remember the rising edge time so we don't process CLK signals at the same time
	// --> if (epr_state=ASSERT_LINE) then m_last_cs_rising_edge_time = machine().time();
  if (cs_state=ASSERT_LINE) then handle_event(EVENT_CS_RISING_EDGE)
    else handle_event(EVENT_CS_FALLING_EDGE);
end;

//-------------------------------------------------
//  base_clk_write - set the state of the clock
//  (CLK) line
//-------------------------------------------------
procedure base_clk_write(epr_state:byte);
begin
	// ignore if the state is not changing
	epr_state:=epr_state and 1;
	if (epr_state=clk_state) then exit;
	// set the new state
	clk_state:=epr_state;
  if (clk_state=ASSERT_LINE) then	handle_event(EVENT_CLK_RISING_EDGE)
     else handle_event(EVENT_CLK_FALLING_EDGE);
end;

//-------------------------------------------------
//  base_di_write - set the state of the data input
//  (DI) line
//-------------------------------------------------
procedure base_di_write(epr_state:byte);
begin
	//if ((epr_state<>0) and (epr_state<>1)) LOG0(("EEPROM: Unexpected data at input 0x%X treated as %d\n", state, state & 1));
	di_state:=epr_state and 1;
end;

procedure eepromser_init(tipo,epr_bits:byte);
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
  case tipo of
    ER5911:begin
              parse_command_and_address:=er5911_parse_command_and_address;
              if epr_bits=8 then begin
                command_address_bits:=9;
                address_bits:=calc_address_bits(128);
              end else begin
                command_address_bits:=8;
                address_bits:=calc_address_bits(64);
              end;
           end;
  end;
  data_bits:=epr_bits;
  streaming_enabled:=false;
end;

procedure eepromser_reset;
begin
  	// reset the state
	set_state(STATE_IN_RESET);
	locked:=true;
	bits_accum:=0;
	command_address_accum:=0;
	command:=COMMAND_INVALID;
	address:=0;
	shift_register:=0;
end;

function er5911_do_read:byte;
begin
 er5911_do_read:=base_do_read;
end;

function er5911_ready_read;
begin
  er5911_ready_read:=base_ready_read;
end;

procedure er5911_cs_write(epr_state:byte);
begin
  base_cs_write(epr_state);
end;

procedure er5911_clk_write(epr_state:byte);
begin
  base_clk_write(epr_state);
end;

procedure er5911_di_write(epr_state:byte);
begin
  base_di_write(epr_state);
end;

//-------------------------------------------------
//  parse_command_and_address - extract the
//  command and address from a bitstream
//-------------------------------------------------
procedure er5911_parse_command_and_address;
begin
	// set the defaults
	command:=COMMAND_INVALID;
	address:=command_address_accum and ((1 shl command_address_bits)-1);
	// extract the command portion and handle it
	case (command_address_accum shr command_address_bits) of
		// opcode 0 needs two more bits to decode the operation
		0:begin
			  case (address shr (command_address_bits-2)) of
				  0:command:=COMMAND_LOCK;
				  1:command:=COMMAND_INVALID;// not on ER5911
				  2:command:=COMMAND_ERASEALL;
				  3:command:=COMMAND_UNLOCK;
			  end;
			  address:=0;
    end;
		1:command:=COMMAND_WRITE;
		2:command:=COMMAND_READ;
		3:command:=COMMAND_WRITE;  // WRITE instead of ERASE on ER5911
	end;
end;

end.
