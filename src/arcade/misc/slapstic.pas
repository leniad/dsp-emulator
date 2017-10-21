unit slapstic;

interface

type
  mask_value=record
	  mask,value:integer;
  end;
  slapstic_data=record
      bankstart:integer;
	    bank:array[0..3] of integer;
	    alt1,alt2,alt3,alt4:mask_value;
	    altshift:integer;
	    bit1,bit2c0,bit2s0,bit2c1,bit2s1,bit3:mask_value;
	    add1,add2,addplus1,addplus2,add3:mask_value;
  end;
  slapstic_type=class
      constructor create(num:byte;is_68k:boolean);
      destructor free;
    public
      current_bank:byte;
      procedure reset;
      function slapstic_tweak(offset:word):byte;
    private
      m_chipnum:integer;
	    state:byte;
	    access_68k:boolean;
	    alt_bank,bit_bank,add_bank,bit_xor:byte;
      slapstic:slapstic_data;
  end;

var
  slapstic_0:slapstic_type;

implementation

const
  DISABLED=0;
	ENABLED=1;
	ALTERNATE1=2;
	ALTERNATE2=3;
	ALTERNATE3=4;
	BITWISE1=5;
	BITWISE2=6;
	BITWISE3=7;
	ADDITIVE1=8;
	ADDITIVE2=9;
	ADDITIVE3=10;

  UNKNOWN=$ffff;

  slapstic101:slapstic_data=(
	    // basic banking */
	    bankstart:3;                             // starting bank */
	    bank:($0080,$0090,$00a0,$00b0);          // bank select values */
	    // alternate banking */
	    alt1:(mask:$007f;value:UNKNOWN);         // 1st mask/value in sequence */
	    alt2:(mask:$1fff;value:$1dff);           // 2nd mask/value in sequence */
	    alt3:(mask:$1ffc;value:$1b5c);           // 3rd mask/value in sequence */
	    alt4:(mask:$1fcf;value:$0080);           // 4th mask/value in sequence */
	    altshift:0;                              // shift to get bank from 3rd */
	    // bitwise banking */
	    bit1:(mask:$1ff0;value:$1540);           // 1st mask/value in sequence */
	    bit2c0:(mask:$1ff3;value:$1540);         // clear bit 0 value */
	    bit2s0:(mask:$1ff3;value:$1541);         //   set bit 0 value */
	    bit2c1:(mask:$1ff3;value:$1542);         // clear bit 1 value */
	    bit2s1:(mask:$1ff3;value:$1543);         //   set bit 1 value */
	    bit3:(mask:$1ff8;value:$1550);           // final mask/value in sequence */
	    // additive banking */
	    add1:(mask:UNKNOWN;value:UNKNOWN);
	    add2:(mask:UNKNOWN;value:UNKNOWN);
	    addplus1:(mask:UNKNOWN;value:UNKNOWN);
	    addplus2:(mask:UNKNOWN;value:UNKNOWN);
	    add3:(mask:UNKNOWN;value:UNKNOWN));

constructor slapstic_type.create(num:byte;is_68k:boolean);
begin
  case num of
    101:self.slapstic:=slapstic101;
  end;
  self.access_68k:=is_68k;
  self.reset;
end;

destructor slapstic_type.free;
begin

end;

function MATCHES_MASK_VALUE(val:word;maskval:mask_value):boolean;
begin
  MATCHES_MASK_VALUE:=((val and maskval.mask)=maskval.value);
end;

procedure slapstic_type.reset;
begin
  // reset the chip */
	self.state:=DISABLED;
	// the 111 and later chips seem to reset to bank 0 */
	self.current_bank:=self.slapstic.bankstart;
end;

function alt2_kludge(offset:word):byte;
begin
  halt(0);
end;

function slapstic_type.slapstic_tweak(offset:word):byte;
begin
	// reset is universal */
	if (offset=$0000) then begin
    self.state:=ENABLED;
	end else begin// otherwise, use the state machine
		case self.state of
			// DISABLED state: everything is ignored except a reset */
			DISABLED:;
			// ENABLED state: the chip has been activated and is ready for a bankswitch */
			ENABLED:begin
				if MATCHES_MASK_VALUE(offset,self.slapstic.bit1) then begin
          // check for request to enter bitwise state */
          self.state:=BITWISE1;
        end else if MATCHES_MASK_VALUE(offset,self.slapstic.add1) then begin
                    // check for request to enter additive state */
                    self.state:=ADDITIVE1;
                 end else if MATCHES_MASK_VALUE(offset,self.slapstic.alt1) then begin
                            // check for request to enter alternate state */
                            self.state:=ALTERNATE1
                          end else if MATCHES_MASK_VALUE(offset,self.slapstic.alt2) then begin
                                     // special kludge for catching the second alternate address if */
				                             // the first one was missed (since it's usually an opcode fetch) */
                                     self.state:=alt2_kludge(offset);
                                   end
				                              // check for standard bankswitches */
				                              else if (offset=self.slapstic.bank[0]) then begin
					                                    self.state:=DISABLED;
					                                    self.current_bank:=0;
				                                   end else if (offset=self.slapstic.bank[1]) then begin
					                                            self.state:=DISABLED;
					                                            self.current_bank:=1;
                                                    end else if (offset=self.slapstic.bank[2]) then begin
					                                                      self.state:=DISABLED;
					                                                      self.current_bank:=2;
                                                             end else if (offset=self.slapstic.bank[3]) then begin
					                                                              self.state:=DISABLED;
					                                                              self.current_bank:=3;
                                                                      end;
      end;
			// ALTERNATE1 state: look for alternate2 offset, or else fall back to ENABLED */
			ALTERNATE1:begin
				if MATCHES_MASK_VALUE(offset,self.slapstic.alt2) then self.state:=ALTERNATE2
          else self.state:=ENABLED;
      end;
			// ALTERNATE2 state: look for altbank offset, or else fall back to ENABLED */
			ALTERNATE2:begin
				if MATCHES_MASK_VALUE(offset, slapstic.alt3) then begin
          self.state:=ALTERNATE3;
					self.alt_bank:=(offset shr self.slapstic.altshift) and 3;
				end else begin
					self.state:=ENABLED;
				end;
      end;
			// ALTERNATE3 state: wait for the final value to finish the transaction */
			ALTERNATE3:if MATCHES_MASK_VALUE(offset, slapstic.alt4) then begin
					self.state:=DISABLED;
					current_bank:=self.alt_bank;
      end;
			// BITWISE1 state: waiting for a bank to enter the BITWISE state */
			BITWISE1:if ((offset=self.slapstic.bank[0]) or (offset=self.slapstic.bank[1]) or (offset=self.slapstic.bank[2]) or (offset=self.slapstic.bank[3])) then begin
					self.state:=BITWISE2;
					self.bit_bank:=self.current_bank;
					self.bit_xor:=0;
      end;
			// BITWISE2 state: watch for twiddling and the escape mechanism */
			BITWISE2:begin
        // check for clear bit 0 case */
				if MATCHES_MASK_VALUE(offset xor self.bit_xor,self.slapstic.bit2c0) then begin
					self.bit_bank:=self.bit_bank and $fe;
					self.bit_xor:=self.bit_xor xor 3;
				end // check for set bit 0 case */
				    else if MATCHES_MASK_VALUE(offset xor self.bit_xor,self.slapstic.bit2s0) then begin
					          self.bit_bank:=self.bit_bank or 1;
					          self.bit_xor:=self.bit_xor xor 3;
				          end	// check for clear bit 1 case */
				              else if MATCHES_MASK_VALUE(offset xor self.bit_xor,self.slapstic.bit2c1) then begin
					                    self.bit_bank:=self.bit_bank and $fd;
					                    self.bit_xor:=self.bit_xor xor 3;
                      end // check for set bit 1 case */
				                  else if MATCHES_MASK_VALUE(offset xor self.bit_xor,self.slapstic.bit2s1) then begin
					                        self.bit_bank:=self.bit_bank or 2;
					                        self.bit_xor:=self.bit_xor xor 3;
                          end // check for escape case */
				                      else if MATCHES_MASK_VALUE(offset,self.slapstic.bit3) then begin
					                            self.state:=BITWISE3;
                                   end;
      end;
			// BITWISE3 state: waiting for a bank to seal the deal */
			BITWISE3:if ((offset=self.slapstic.bank[0]) or (offset=self.slapstic.bank[1]) or (offset=self.slapstic.bank[2]) or (offset=self.slapstic.bank[3])) then begin
					self.state:=DISABLED;
					self.current_bank:=self.bit_bank;
      end;
			// ADDITIVE1 state: look for add2 offset, or else fall back to ENABLED */
			ADDITIVE1:if MATCHES_MASK_VALUE(offset,self.slapstic.add2) then begin
					self.state:=ADDITIVE2;
					self.add_bank:=self.current_bank;
				end else begin
					self.state:=ENABLED;
				end;
			// ADDITIVE2 state: watch for twiddling and the escape mechanism */
			ADDITIVE2:begin
				// check for add 1 case -- can intermix */
				if MATCHES_MASK_VALUE(offset,self.slapstic.addplus1) then self.add_bank:=(self.add_bank+1) and 3;
				// check for add 2 case -- can intermix */
				if MATCHES_MASK_VALUE(offset,self.slapstic.addplus2) then self.add_bank:=(self.add_bank+2) and 3;
				// check for escape case -- can intermix with the above */
				if MATCHES_MASK_VALUE(offset,self.slapstic.add3) then self.state:=ADDITIVE3;
      end;
			/// ADDITIVE3 state: waiting for a bank to seal the deal */
			ADDITIVE3:if ((offset=self.slapstic.bank[0]) or (offset=self.slapstic.bank[1]) or (offset=self.slapstic.bank[2]) or (offset=self.slapstic.bank[3])) then begin
        self.state:=DISABLED;
        self.current_bank:=self.add_bank;
      end;
	end;
end;
  // return the active bank
	slapstic_tweak:=self.current_bank;
end;

end.
