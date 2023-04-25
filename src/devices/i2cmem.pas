unit i2cmem;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     file_engine;

type
  i2cmem_chip=class
      constructor create(tipo:byte);
      destructor free;
    public
      function read_sda:byte;
      procedure write_scl(valor:byte);
      procedure write_sda(valor:byte);
      procedure reset;
      procedure load_data(ptemp:pbyte);
      procedure write_data(file_name:string);
    private
      page:array[0..7] of byte;
      data:array[0..$1fff] of byte;
      wc,devsel_address_low:boolean;
      byteaddr,data_size,address_mask:word;
      page_written_size,page_offset,addresshigh,write_page_size,slave_address,
      devsel,scl,sdaw,shift,bits,state,sdar,e0,e1,e2,read_page_size:byte;
      function select_device:boolean;
  end;

const
  STATE_IDLE=0;
  STATE_DEVSEL=1;
  STATE_ADDRESSHIGH=2;
  STATE_ADDRESSLOW=3;
  STATE_DATAIN=4;
  STATE_READSELACK=5;
  STATE_DATAOUT=6;
  STATE_RESET=7;

  I2CMEM_SLAVE_ADDRESS=$a0;
  I2CMEM_SLAVE_ADDRESS_ALT=$b0;

  DEVSEL_RW=1;
  DEVSEL_ADDRESS=$fe;
  I2C_24C02=6;

var
  i2cmem_0:i2cmem_chip;

implementation

constructor i2cmem_chip.create(tipo:byte);
begin
case tipo of
  I2C_24C02:begin
      self.read_page_size:=0;
	    self.write_page_size:=8;
      self.data_size:=$100;
  end;
end;
self.address_mask:=self.data_size-1;
fillchar(self.data[0],$2000,$ff);
end;

destructor i2cmem_chip.free;
begin
end;

procedure i2cmem_chip.reset;
begin
	self.scl:=0;
	self.sdaw:=0;
	self.e0:=0;
	self.e1:=0;
	self.e2:=0;
	self.wc:=false;
	self.sdar:=1;
	self.state:=STATE_IDLE;
	self.bits:=0;
	self.shift:=0;
	self.devsel:=0;
	self.addresshigh:=0;
	self.byteaddr:=0;
	self.page_offset:=0;
	self.page_written_size:=0;
	self.devsel_address_low:=false;
  slave_address:=I2CMEM_SLAVE_ADDRESS;
end;

procedure i2cmem_chip.load_data(ptemp:pbyte);
begin
  copymemory(@self.data,ptemp,self.data_size);
end;

procedure i2cmem_chip.write_data(file_name:string);
begin
  write_file(file_name,@self.data,self.data_size);
end;

function i2cmem_chip.select_device:boolean;
var
  device:byte;
  mask:word;
begin
	if self.devsel_address_low then begin
		// Due to a full address and read/write flag fitting in one 8-bit packet, the Xicor X24C01 replies on all addresses.
    select_device:=true;
    exit;
  end;
	device:=(self.slave_address and $f0) or (self.e2 shl 3) or (self.e1 shl 2) or (self.e0 shl 1);
  if (self.data_size<=$800) then mask:=DEVSEL_ADDRESS and not(self.address_mask shr 7)
    else mask:=DEVSEL_ADDRESS and $ffff;
	if ((self.devsel and mask)=(device and mask)) then begin
    select_device:=true;
		exit;
	end;
  select_device:=false;
end;

function i2cmem_chip.read_sda:byte;
begin
	read_sda:=self.sdar and 1;
end;

procedure i2cmem_chip.write_scl(valor:byte);
var
  offset:integer;
begin
if (self.scl<>valor) then begin
		self.scl:=valor;
		case self.state of
		  STATE_DEVSEL,
		  STATE_ADDRESSHIGH,
		  STATE_ADDRESSLOW,
		  STATE_DATAIN:begin
      if (self.bits<8) then begin
				if (self.scl<>0) then begin
					self.shift:=((self.shift shl 1) or self.sdaw) and $ff;
					self.bits:=self.bits+1;
        end;
			end else begin
				if (self.scl<>0) then begin
					self.bits:=self.bits+1;
        end else begin
					if (self.bits=8) then begin
						case self.state of
						  STATE_DEVSEL:begin
							  self.devsel:=self.shift;
							  if ((self.devsel=0) and not(self.devsel_address_low)) then begin
								  // TODO: Atmel datasheets document 2-wire software reset, but doesn't mention it will lower sda only that it will release it.
								  // ltv_naru however requires it to be lowered, but we don't currently know the manufacturer of the chip used.
								  self.state:=STATE_RESET;
                end else if not(self.select_device) then begin
                            self.state:=STATE_IDLE;
							           end else if ((self.devsel and DEVSEL_RW)=0) then begin
								                      if (self.devsel_address_low) then begin
									                      self.byteaddr:=(self.devsel and DEVSEL_ADDRESS) shr 1;
									                      self.page_offset:=0;
									                      self.page_written_size:=0;
									                      self.state:=STATE_DATAIN;
								                      end else begin
                                        if (self.data_size<=$800) then self.state:=STATE_ADDRESSLOW
                                          else self.state:=STATE_ADDRESSHIGH;
                                      end;
                                  end else begin
								                            if (self.devsel_address_low) then self.byteaddr:=(self.devsel and DEVSEL_ADDRESS) shr 1;
								                            self.state:=STATE_READSELACK;
                                  end;
							end;
						  STATE_ADDRESSHIGH:begin
							  self.addresshigh:=self.shift;
							  self.state:=STATE_ADDRESSLOW;
              end;
						  STATE_ADDRESSLOW:begin
                if (self.data_size<=$800) then self.byteaddr:=self.shift or ((self.devsel and DEVSEL_ADDRESS) shl 7) and self.address_mask
                  else self.byteaddr:=self.shift or (self.addresshigh shl 8);
							  self.page_offset:=0;
							  self.page_written_size:=0;
							  self.state:=STATE_DATAIN;
							end;
						  STATE_DATAIN:begin
							  if not(self.wc) then begin
								  self.state:=STATE_IDLE;
							  end else if (self.write_page_size>0) then begin
								            self.page[self.page_offset]:=self.shift;
								            self.page_offset:=self.page_offset+1;
								            if (self.page_offset=self.write_page_size) then self.page_offset:=0;
								            self.page_written_size:=self.page_written_size+1;
								            if (self.page_written_size>self.write_page_size) then self.page_written_size:=self.write_page_size;
                         end else begin
								            offset:=self.byteaddr and self.address_mask;
								            self.data[offset]:=self.shift;
								            self.byteaddr:=self.byteaddr+1;
                         end
              end;
						end; //del segundo case
						if (self.state<>STATE_IDLE) then self.sdar:=0;
					end else begin //del if bits=8
						self.bits:=0;
						self.sdar:=1;
					end;
				end;
			end; //del else del prime if
    end;
		STATE_READSELACK:begin
			self.bits:=0;
			self.state:=STATE_DATAOUT;
    end;
		STATE_DATAOUT:begin
			if (self.bits<8) then begin
				if (self.scl<>0) then begin
					self.bits:=self.bits+1;
				end else begin
					if (self.bits=0) then begin
						offset:=self.byteaddr and self.address_mask;
						self.shift:=self.data[offset];
						self.byteaddr:=(self.byteaddr and not(self.read_page_size-1)) or ((self.byteaddr+1) and (self.read_page_size-1));
					end;
					self.sdar:=(self.shift shr 7) and 1;
					self.shift:=(self.shift shl 1) and $ff;
				end;
			end else begin
				if (self.scl<>0) then begin
					if (self.sdaw<>0) then self.state:=STATE_IDLE;
					self.bits:=0;
				end else self.sdar:=1;
			end;
    end;
		STATE_RESET:begin
			if (self.scl<>0) then begin
				if (self.bits>8) then begin
					self.state:=STATE_IDLE;
					self.sdar:=1;
				end;
				self.bits:=self.bits+1;
			end;
    end;
  end; //del case
end; //del if
end;

procedure i2cmem_chip.write_sda(valor:byte);
var
  base,root,f:integer;
begin
	valor:=valor and 1;
	if (self.sdaw<>valor) then begin
		self.sdaw:=valor;
		if (self.scl<>0) then begin
			if (self.sdaw<>0) then begin
				if (self.page_written_size>0) then begin
					base:=self.byteaddr and self.address_mask;
					root:=base and not(self.write_page_size-1);
					for f:=0 to (self.page_written_size-1) do
						self.data[root or ((base+f) and (self.write_page_size-1))]:=self.page[f];
					self.page_written_size:=0;
				end;
				self.state:=STATE_IDLE;
			end else begin
				self.state:=STATE_DEVSEL;
				self.bits:=0;
			end;
			self.sdar:=1;
		end;
	end;
end;

end.
