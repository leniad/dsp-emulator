unit ppi8255;

interface
{$IFDEF WINDOWS}uses windows;{$ENDIF}

type
  tread_port_8255=function:byte;
  twrite_port_8255=procedure(valor:byte);
  pia8255_chip=class
      constructor create;
      destructor free;
    public
      procedure reset;
      procedure change_ports(pread_port_a,pread_port_b,pread_port_c:tread_port_8255;pwrite_port_a,pwrite_port_b,pwrite_port_c:twrite_port_8255);
      function read(port:byte):byte;
      procedure write(port,data:byte);
      function get_port(port:byte):byte;
      procedure set_port(port,data:byte);
      function save_snapshot(data:pbyte):word;
      procedure load_snapshot(data:pbyte);
    private
		  group_a_mode,group_b_mode:byte;
	    port_a_dir,port_b_dir,port_ch_dir,port_cl_dir:boolean;
	    obf_a,obf_b:boolean;
      ibf_a,ibf_b:boolean;
	    inte_a,inte_b:boolean;
      inte_1,inte_2:boolean;
      control:byte;
	    in_mask,out_mask,read_val,latch,output_val:array[0..2] of byte;
      read_call:array[0..2] of tread_port_8255;
      write_call:array[0..2] of twrite_port_8255;
      procedure get_handshake_signals(val:pbyte);
      procedure set_mode(data:byte;call_handlers:boolean);
      procedure write_port(port:byte);
      function read_port(port:byte):byte;
      procedure input(port,data:byte);
  end;

var
  pia8255_0,pia8255_1:pia8255_chip;

implementation

constructor pia8255_chip.create;
begin
end;

destructor pia8255_chip.free;
begin
end;

function pia8255_chip.save_snapshot(data:pbyte):word;
var
  buffer:array[0..26] of byte;
begin
  buffer[0]:=group_a_mode;
  buffer[1]:=group_b_mode;
  buffer[2]:=byte(port_a_dir);
  buffer[3]:=byte(port_b_dir);
  buffer[4]:=byte(port_ch_dir);
  buffer[5]:=byte(port_cl_dir);
  buffer[6]:=byte(obf_a);
  buffer[7]:=byte(obf_b);
  buffer[8]:=byte(ibf_a);
  buffer[9]:=byte(ibf_b);
  buffer[10]:=byte(inte_a);
  buffer[11]:=byte(inte_b);
  buffer[12]:=byte(inte_1);
  buffer[13]:=byte(inte_2);
  buffer[14]:=control;
  copymemory(@buffer[15],@in_mask[0],3);
  copymemory(@buffer[18],@read_val[0],3);
  copymemory(@buffer[21],@latch[0],3);
  copymemory(@buffer[24],@output_val[0],3);
  copymemory(data,@buffer[0],27);
  save_snapshot:=27;
end;

procedure pia8255_chip.load_snapshot(data:pbyte);
var
  buffer:array[0..26] of byte;
begin
  copymemory(@buffer[0],data,27);
  group_a_mode:=buffer[0];
  group_b_mode:=buffer[1];
  port_a_dir:=buffer[2]<>0;
  port_b_dir:=buffer[3]<>0;
  port_ch_dir:=buffer[4]<>0;
  port_cl_dir:=buffer[5]<>0;
  obf_a:=buffer[6]<>0;
  obf_b:=buffer[7]<>0;
  ibf_a:=buffer[8]<>0;
  ibf_b:=buffer[9]<>0;
  inte_a:=buffer[10]<>0;
  inte_b:=buffer[11]<>0;
  inte_1:=buffer[12]<>0;
  inte_2:=buffer[13]<>0;
  control:=buffer[14];
  copymemory(@in_mask[0],@buffer[15],3);
  copymemory(@read_val[0],@buffer[18],3);
  copymemory(@latch[0],@buffer[21],3);
  copymemory(@output_val[0],@buffer[24],3);
end;

procedure pia8255_chip.change_ports(pread_port_a,pread_port_b,pread_port_c:tread_port_8255;pwrite_port_a,pwrite_port_b,pwrite_port_c:twrite_port_8255);
begin
  self.read_call[0]:=pread_port_a;
  self.read_call[1]:=pread_port_b;
  self.read_call[2]:=pread_port_c;
  self.write_call[0]:=pwrite_port_a;
  self.write_call[1]:=pwrite_port_b;
  self.write_call[2]:=pwrite_port_c;
end;

procedure pia8255_chip.reset;
var
  f:byte;
begin
  self.group_a_mode:=0;
	self.group_b_mode:=0;
	self.port_a_dir:=false;
	self.port_b_dir:=false;
	self.port_ch_dir:=false;
	self.port_cl_dir:=false;
	self.obf_a:=false;
  self.ibf_a:=false;
	self.obf_b:=false;
  self.ibf_b:=false;
	self.inte_a:=false;
  self.inte_b:=false;
  self.inte_1:=false;
  self.inte_2:=false;
	for f:=0 to 2 do begin
		self.in_mask[f]:=0;
    self.out_mask[f]:=0;
    self.read_val[f]:=0;
    self.latch[f]:=0;
    self.output_val[f]:=0;
	end;
	self.set_mode($9b,false);
end;

procedure pia8255_chip.set_mode(data:byte;call_handlers:boolean);
var
  f:byte;
begin
	// parse out mode
	self.group_a_mode:=(data shr 5) and 3;
	self.group_b_mode:=(data shr 2) and 1;
	self.port_a_dir:=(data and $10)<>0;
	self.port_b_dir:=(data and 2)<>0;
	self.port_ch_dir:=(data and 8)<>0;
	self.port_cl_dir:=(data and 1)<>0;
	// normalize group_a_mode
	if (self.group_a_mode=3) then self.group_a_mode:=2;
	// Port A direction
	if (self.group_a_mode=2) then begin
		self.in_mask[0]:=$FF;
		self.out_mask[0]:=$FF;	//bidirectional
	end else begin
		if self.port_a_dir then begin
			self.in_mask[0]:=$FF;
			self.out_mask[0]:=0;	// input
		end else begin
			self.in_mask[0]:=0;
			self.out_mask[0]:=$FF;	// output
		end;
	end;
	// Port B direction
	if self.port_b_dir then begin
		self.in_mask[1]:=$FF;
		self.out_mask[1]:=0;	// input
	end else begin
		self.in_mask[1]:=0;
		self.out_mask[1]:=$FF;	// output
	end;
	// Port C upper direction */
	if self.port_ch_dir then begin
		self.in_mask[2]:=$F0;
		self.out_mask[2]:=0;	// input
	end else begin
		self.in_mask[2]:=0;
		self.out_mask[2]:=$F0;	// output
	end;
	// Port C lower direction
	if self.port_cl_dir then self.in_mask[2]:=self.in_mask[2] or $0F	// input
	  else self.out_mask[2]:=self.out_mask[2] or $0F;	// output
	// now depending on the group modes, certain Port C lines may be replaced
  //   * with varying control signals
	case self.group_a_mode of
		0:;	// Group A mode 0 no changes
		1:begin	// Group A mode 1 bits 5-3 are reserved by Group A mode 1
			  self.in_mask[2]:=self.in_mask[2] and $c7;
			  self.out_mask[2]:=self.out_mask[2] and $c7;
			end;
		2:begin // Group A mode 2 bits 7-3 are reserved by Group A mode 2
			  self.in_mask[2]:=self.in_mask[2] and $07;
			  self.out_mask[2]:=self.out_mask[2] and $07;
			end;
	end;
	case self.group_b_mode of
		0:;	// Group B mode 0 no changes
    1:begin	// Group B mode 1 bits 2-0 are reserved by Group B mode 1
			  self.in_mask[2]:=self.in_mask[2] and $F8;
			  self.out_mask[2]:=self.out_mask[2] and $F8;
			end;
	end;
	// KT: 25-Dec-99 - 8255 resets latches when mode set
	self.latch[0]:=0;
  self.latch[1]:=0;
  self.latch[2]:=0;
	if call_handlers then for f:=0 to 2 do self.write_port(f);
	// reset flip-flops
	self.obf_a:=false;
  self.ibf_a:=false;
	self.obf_b:=false;
  self.ibf_b:=false;
	self.inte_a:=false;
  self.inte_b:=false;
  self.inte_1:=false;
  self.inte_2:=false;
	// store control word
	self.control:=data;
end;

procedure pia8255_chip.get_handshake_signals(val:pbyte);
var
  handshake,mask:byte;
begin
	handshake:=0;
	mask:=0;
	// group A
	if (self.group_a_mode=1) then begin
		if self.port_a_dir then begin
			if self.ibf_a then handshake:=handshake or $20;
      if (self.ibf_a and self.inte_a) then handshake:=handshake or $8;
			mask:=mask or $28;
		end	else begin
      if not(self.obf_a) then handshake:=handshake or $80;
      if (self.obf_a and self.inte_a) then handshake:=handshake or $8;
			mask:=mask or $88;
		end;
	end else if (self.group_a_mode=2) then begin
    if not(self.obf_a) then handshake:=handshake or $80;
    if self.ibf_a then handshake:=handshake or $20;
    if ((self.obf_a and self.inte_1) or (self.ibf_a and self.inte_2)) then handshake:=handshake or $8;
		mask:=mask or $a8;
	end;
	// group B
	if (self.group_b_mode=1) then begin
		if self.port_b_dir then begin
      if self.ibf_b then handshake:=handshake or $02;
      if (self.ibf_b and self.inte_b) then handshake:=handshake or $01;
			mask:=mask or $03;
		end else begin
      if not(self.obf_b) then handshake:=handshake or $02;
      if (self.obf_b and self.inte_b) then handshake:=handshake or $01;
			mask:=mask or $03;
		end;
	end;
	val^:=val^ and not(mask);
	val^:=val^ or (handshake and mask);
end;

procedure pia8255_chip.write_port(port:byte);
var
  write_data:byte;
begin
	write_data:=self.latch[port] and self.out_mask[port];
	write_data:=write_data or ($FF and not(self.out_mask[port]));
	// write out special port 2 signals
	if (port=2) then self.get_handshake_signals(@write_data);
	self.output_val[port]:=write_data;
	if @self.write_call[port]<>nil then self.write_call[port](write_data);
end;

function pia8255_chip.read(port:byte):byte;
var
  res:byte;
begin
	res:=0;
  port:=port and $3;
	case port of
		0,1,2:res:=self.read_port(port); // Port A,B,C read
		3:res:=self.control; // Control word
	end;
  read:=res;
end;

function pia8255_chip.read_port(port:byte):byte;
var
  res:byte;
begin
	res:=$00;
	if (self.in_mask[port]<>0) then begin
    if @self.read_call[port]<>nil then self.input(port,self.read_call[port]);
		res:=res or (self.read_val[port] and self.in_mask[port]);
	end;
	res:=res or (self.latch[port] and self.out_mask[port]);
	case port of
	  0:self.ibf_a:=false; // clear input buffer full flag
    1:self.ibf_b:=false; // clear input buffer full flag
	  2:self.get_handshake_signals(@res); // read special port 2 signals
	end;
  read_port:=res;
end;

procedure pia8255_chip.input(port,data:byte);
var
  changed:boolean;
begin
	changed:=false;
	self.read_val[port]:=data;
	// port C is special
	if (port=2) then begin
		if (((self.group_a_mode=1) and not(self.port_a_dir)) or (self.group_a_mode=2)) then begin
			// is !ACKA asserted?
			if (self.obf_a and ((not(data and $40))<>0)) then begin
				self.obf_a:=false;
				changed:=true;
			end;
		end;
		if (((self.group_a_mode=1) and self.port_a_dir) or (self.group_a_mode=2)) then begin
			// is !STBA asserted?
			if (not(self.ibf_a) and ((not(data and $10))<>0)) then begin
				self.ibf_a:=true;
				changed:=true;
			end;
		end;
		if ((self.group_b_mode=1) and not(self.port_b_dir)) then begin
			// is !ACKB asserted?
			if (self.obf_b and ((not(data and $04))<>0)) then begin
				self.obf_b:=false;
				changed:=true;
			end;
		end;
		if ((self.group_b_mode=1) and self.port_b_dir) then begin
			// is !STBB asserted?
			if (not(self.ibf_b) and ((not(data and $04))<>0)) then begin
				self.ibf_b:=true;
				changed:=true;
			end;
		end;
		if changed then self.write_port(2);
	end;  //del if port2
end;

procedure pia8255_chip.write(port,data:byte);
var
  bit:byte;
begin
	port:=port mod 4;
	case port of
		0,1,2:begin // Port A,B,C write
			  self.latch[port]:=data;
			  self.write_port(port);
			  case port of
				0:if (not(self.port_a_dir) and (self.group_a_mode<>0)) then begin
						self.obf_a:=true;
						self.write_port(2);
					end;
				1:if (not(self.port_b_dir) and (self.group_b_mode<>0)) then begin
						self.obf_b:=true;
						self.write_port(2);
					end;
        end;
      end;
		3:begin // Control word
			if (data and $80)<>0 then begin
				self.set_mode(data and $7f,true);
			end else begin
				// bit set/reset
				bit:=(data shr 1) and $07;
				if (data and 1)<>0 then self.latch[2]:=self.latch[2] or (1 shl bit)	// set bit
				  else self.latch[2]:=self.latch[2] and (not(1 shl bit));	// reset bit
				if (self.group_b_mode=1) then
					if (bit=2) then self.inte_b:=(data and 1)<>0;
				if (self.group_a_mode=1) then begin
					if ((bit=4) and self.port_a_dir) then self.inte_a:=(data and 1)<>0;
					if ((bit=6) and not(self.port_a_dir)) then self.inte_a:=(data and 1)<>0;
				end;
				if (self.group_a_mode=2) then begin
					if (bit=4) then self.inte_2:=(data and 1)<>0;
					if (bit=6) then self.inte_1:=(data and 1)<>0;
        end;
				self.write_port(2);
			end;
    end;
	end;  //del case
end;

function pia8255_chip.get_port(port:byte):byte;
begin
  get_port:=self.output_val[port];
end;

procedure pia8255_chip.set_port(port,data:byte);
begin
  self.input(port,data);
end;

end.
