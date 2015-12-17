unit eeprom;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     main_engine,dialogs,file_engine;

const
    SERIAL_BUFFER_LENGTH=40;
type
     eeprom_class=class
        constructor create(address_bits,data_bits:byte;cmd_read,cmd_write,cmd_erase:string;cmd_lock:string='';cmd_unlock:string='';enable_multi_read:boolean=false;reset_delay:byte=0);
        destructor free;
     public
        procedure set_cs_line(state:byte);
        procedure set_clock_line(state:byte);
        procedure write_bit(valor:byte);
        function readbit:byte;
        procedure reset;
        function get_rom_addr:pbyte;
     private
        nombre:string;
        default_data_size:integer;
	      default_value:dword;
        addrspace:array[0..$ff] of word;
      	// runtime state
      	serial_count:integer;
      	serial_buffer:array[0..SERIAL_BUFFER_LENGTH] of char;
      	read_address,clock_count,reset_counter:integer;
        data_buffer:dword;
        reset_line,clock_line,latch:byte;
        locked,sending:boolean;
        //interface
        address_bits:byte;			// EEPROM has 2^address_bits cells
	      data_bits:byte;			// every cell has this many bits (8 or 16)
	      cmd_read:string;				//   read command string, e.g. "0110"
	      cmd_write:string;			//  write command string, e.g. "0111"
	      cmd_erase:string;			//  erase command string, or 0 if n/a
	      cmd_lock:string;				//   lock command string, or 0 if n/a
        cmd_unlock:string;			// unlock command string, or 0 if n/a
	      enable_multi_read:boolean;	// set to 1 to enable multiple values to be read from one read command
	      reset_delay:byte;			// number of times eeprom_read_bit() should return 0 after a reset,
										// before starting to return 1.
        procedure write(latch:byte);
     end;

var
  eeprom_0:eeprom_class;

implementation
uses init_games;

constructor eeprom_class.create(address_bits,data_bits:byte;cmd_read,cmd_write,cmd_erase:string;cmd_lock:string='';cmd_unlock:string='';enable_multi_read:boolean=false;reset_delay:byte=0);
var
  f:integer;
begin
self.address_bits:=address_bits;
self.data_bits:=data_bits;
self.cmd_read:=cmd_read;
self.cmd_write:=cmd_write;
self.cmd_erase:=cmd_erase;
self.cmd_lock:=cmd_lock;
self.cmd_unlock:=cmd_unlock;
self.enable_multi_read:=enable_multi_read;
self.reset_delay:=reset_delay;
//Sacar el nombre de la maquina...
for f:=0 to games_cont do begin
  if games_desc[f].grid=main_vars.tipo_maquina then begin
    self.nombre:=directory.Arcade_nvram+games_desc[f].name+'.nv';
    break
  end;
end;
fillchar(self.addrspace[0],$100*2,0);
if read_file_size(self.nombre,f) then read_file(self.nombre,@self.addrspace,f);
end;

destructor eeprom_class.free;
var
  size:dword;
begin
size:=((1 shl self.address_bits)*self.data_bits) div 8;
if self.data_bits=8 then size:=size*2;
write_file(self.nombre,@self.addrspace,size);
end;

function eeprom_class.get_rom_addr:pbyte;
begin
  get_rom_addr:=@self.addrspace[0];
end;

procedure eeprom_class.reset;
begin
default_data_size:=0;
default_value:=0;
serial_count:=0;
data_buffer:=0;
read_address:=0;
clock_count:=0;
latch:=0;
reset_line:=CLEAR_LINE;
clock_line:=CLEAR_LINE;
sending:=false;
locked:=false;
reset_counter:=0;
end;

function command_match(buf:pchar;cmd:pchar;len:integer):boolean;inline;
var
  b,c:char;
begin
	if (cmd^=chr(0))	then begin
    command_match:=false;
    exit;
  end;
	if (len=0) then begin
    command_match:=false;
    exit;
  end;
	while (len>0) do begin
		b:=buf^;
		c:=cmd^;
		if ((b=chr(0)) or (c=chr(0))) then begin
			command_match:=(b=c);
      exit;
    end;
		case c of
			'0','1':begin
                if (b<>c)	then begin
                  command_match:=false;
                  exit;
                end;
                inc(buf);
				        len:=len-1;
				        inc(cmd);
              end;
			'X','x':begin
        				inc(buf);
				        len:=len-1;
				        inc(cmd);
				      end;
			'*':begin
{				c = cmd[1];
				switch( c ) {
					case '0':
					case '1':
						if (b == c)	{	cmd++;			}
 //						else		{	buf++;	len--;	}
	 //					break;
		 //			default:	return false;
			 //	}
		      end;
	    end;
  end;
	command_match:=(cmd^=chr(0));
end;

procedure eeprom_class.write(latch:byte);
var
  i,address,data:word;
  command:array[0..SERIAL_BUFFER_LENGTH] of char;
begin
if (serial_count>=(SERIAL_BUFFER_LENGTH-1)) then begin
  MessageDlg('Buffer eeprom superado', mtInformation,[mbOk], 0);
  exit;
end;
	if latch<>0 then serial_buffer[serial_count]:='1'
    else serial_buffer[serial_count]:='0';
  serial_count:=serial_count+1;
	serial_buffer[serial_count]:=chr(0);	// nul terminate so we can treat it as a string
	if (serial_count>address_bits) then begin
    for i:=0 to length(self.cmd_read) do command[i]:=self.cmd_read[i+1];
    //READ Command
    if command_match(@serial_buffer,@command,serial_count-address_bits) then begin
  		address:=0;
  		for i:=serial_count-address_bits to (serial_count-1) do begin
  			address:=address shl 1;
  			if (serial_buffer[i]='1') then address:=address or 1;
  		end;
  		if (data_bits=16) then data_buffer:=(addrspace[address] shr 8) or ((addrspace[address] and $ff) shl 8)
    		else data_buffer:=addrspace[address] and $ff;
  		read_address:=address;
  		clock_count:=0;
  		sending:=true;
  		serial_count:=0;
    end;
    //ERASE Command
    for i:=0 to length(self.cmd_erase) do command[i]:=self.cmd_erase[i+1];
	  if command_match(@serial_buffer,@command,serial_count-address_bits) then begin
  		address:=0;
  		for i:=serial_count-address_bits to (serial_count-1) do begin
  			address:=address shl 1;
  			if (serial_buffer[i]='1') then address:=address or 1;
  		end;
  		if not(locked) then begin
  			if (data_bits=16) then addrspace[address]:=$FFFF
  			  else addrspace[address]:=$FF;
  		end else begin
  			MessageDlg('Comando ERASE eeprom bloqueada', mtInformation,[mbOk], 0);
      end;
		  serial_count:=0;
    end;
    //WRITE Command
    for i:=0 to length(self.cmd_write) do command[i]:=self.cmd_write[i+1];
	  if command_match(@serial_buffer,@command,serial_count-(address_bits+data_bits)) then begin
  		address:=0;
  		for i:=serial_count-data_bits-address_bits to (serial_count-data_bits-1) do begin
  			address:=address shl 1;
  			if (serial_buffer[i]='1') then address:=address or 1;
  		end;
  		data:=0;
  		for i:=serial_count-data_bits to (serial_count-1) do begin
  			data:=data shl 1;
  			if (serial_buffer[i]='1') then data:=data or 1;
	  	end;
		  if not(locked) then begin
			  if (data_bits=16) then addrspace[address]:=(data shr 8) or ((data and $ff) shl 8)
  			  else addrspace[address]:=data;
	  	end else begin
		  	MessageDlg('Comando WRITE eeprom bloqueada', mtInformation,[mbOk], 0);
      end;
	  	serial_count:=0;
    end;
  //LOCK Command
	end else begin
    if self.cmd_lock<>'' then begin
      for i:=0 to length(self.cmd_lock) do command[i]:=self.cmd_lock[i+1];
      if (command_match(@serial_buffer,@command,serial_count)) then begin
		    locked:=true;
  		  serial_count:=0;
      end;
    end else begin
    //UNLOCK Command
    if self.cmd_unlock<>'' then begin
      for i:=0 to length(self.cmd_unlock) do command[i]:=self.cmd_unlock[i+1];
        if (command_match(@serial_buffer,@command,serial_count)) then begin
	  	    locked:=false;
	  	    serial_count:=0;
        end;
      end;
    end;
  end;
end;

procedure eeprom_class.set_cs_line(state:byte);
begin
reset_line:=state;
if (reset_line<>CLEAR_LINE) then begin
		//if (serial_count<>0) then MessageDlg('Comando CS serial count<>0', mtInformation,[mbOk], 0);
		serial_count:=0;
		sending:=false;
		reset_counter:=reset_delay;	// delay a little before returning setting data to 1 (needed by wbeachvl)
end;
end;

procedure eeprom_class.set_clock_line(state:byte);
begin
if ((state=PULSE_LINE) or ((clock_line=CLEAR_LINE) and (state<>CLEAR_LINE))) then begin
		if (reset_line=CLEAR_LINE) then begin
			if sending then begin
				if ((clock_count=data_bits) and enable_multi_read) then begin
					//read_address:=(read_address+1) and ((1 shl address_bits)-1);
					//if (data_bits=16) then data_buffer:=addrspace[0]->read_word(m_read_address * 2);
					//  else	data_buffer:=addrspace[0]->read_byte(m_read_address);
					//m_clock_count = 0;
          MessageDlg('Eeprom comando multi-read', mtInformation,[mbOk], 0);
				end;
				data_buffer:=(data_buffer shl 1) or 1;
				clock_count:=clock_count+1;
			end else begin
        write(self.latch);
      end;
		end;
end;
clock_line:=state;
end;

procedure eeprom_class.write_bit(valor:byte);
begin
  self.latch:=valor;
end;

function eeprom_class.readbit:byte;
var
  res:byte;
begin
if sending then begin
  res:=(data_buffer shr data_bits) and 1;
end else begin
  if (reset_counter>0) then begin
			// this is needed by wbeachvl
			reset_counter:=reset_counter-1;
			res:=0;
  end else begin
			res:=1;
  end;
end;
readbit:=res;
end;

end.
