unit namcoio_56xx_58xx;
interface
uses timer_engine;
type
  tin_f=function:byte;
  tout_f=procedure (data:byte);
  namco_5x_chip=class
            constructor create(num_cpu,tipo:byte);
            destructor free;
            public
               reset_status:boolean;
               procedure run;
               function read(direccion:byte):byte;
               procedure write(direccion,valor:byte);
               procedure reset_internal(reset_status:boolean);
               procedure reset;
               procedure change_io(in0,in1,in2,in3:tin_f;out0,out1:tout_f);
            private
               tipo:byte;
               ram:array[0..$f] of byte;
               coins,coins_per_cred,creds_per_coin:array[0..1] of byte;
            	 in_count,credits,lastcoins,lastbuttons:byte;
               in_f:array[0..3] of tin_f;
               out_f:array[0..1] of tout_f;
               timer_io:byte;
               procedure handle_coins(swap:byte);
               procedure run_internal;
            end;
var
   namco_5x_0,namco_5x_1:namco_5x_chip;
const
  NAMCO_56XX=0;
  NAMCO_58XX=1;
  NAMCO_59XX=2;

implementation
var
  chips_total:integer=-1;

procedure run_io_0;
begin
  namco_5x_0.run_internal;
  timers.enabled(namco_5x_0.timer_io,false);
end;

procedure run_io_1;
begin
  namco_5x_1.run_internal;
  timers.enabled(namco_5x_1.timer_io,false);
end;

constructor namco_5x_chip.create(num_cpu,tipo:byte);
begin
  self.in_f[0]:=nil;
  self.in_f[1]:=nil;
  self.in_f[2]:=nil;
  self.in_f[3]:=nil;
  self.out_f[0]:=nil;
  self.out_f[1]:=nil;
  self.tipo:=tipo;
  chips_total:=chips_total+1;
  //1536000*0.000001*50=76,8
  case chips_total of
    0:self.timer_io:=timers.init(num_cpu,76.8,run_io_0,nil,false);
    1:self.timer_io:=timers.init(num_cpu,76.8,run_io_1,nil,false);
  end;
end;

destructor namco_5x_chip.free;
begin
  chips_total:=chips_total-1;
end;

procedure namco_5x_chip.reset;
begin
	self.reset_status:=false;
  fillchar(self.ram,$10,0);
end;

procedure namco_5x_chip.change_io(in0,in1,in2,in3:tin_f;out0,out1:tout_f);
begin
  self.in_f[0]:=in0;
  self.in_f[1]:=in1;
  self.in_f[2]:=in2;
  self.in_f[3]:=in3;
  self.out_f[0]:=out0;
  self.out_f[1]:=out0;
end;

procedure namco_5x_chip.run;
begin
  timers.enabled(self.timer_io,true);
end;

function namco_5x_chip.read(direccion:byte):byte;
begin
 	// RAM is 4-bit wide; Pac & Pal requires the | 0xf0 otherwise Easter egg doesn't work
	read:=$f0 or self.ram[direccion and $f];
end;

procedure namco_5x_chip.write(direccion,valor:byte);
begin
	self.ram[direccion and $f]:=valor and $f;
end;

procedure namco_5x_chip.handle_coins(swap:byte);
var
	val,toggled,credit_add,credit_sub,button:byte;
begin
  credit_add:=0;
	credit_sub:=0;
	val:=not(self.in_f[0]);	// pins 38-41
	toggled:=val xor self.lastcoins;
	self.lastcoins:=val;
	// check coin insertion
	if (val and toggled and $1)<>0 then begin
		self.coins[0]:=self.coins[0]+1;
		if (self.coins[0]>=(self.coins_per_cred[0] and 7)) then begin
			credit_add:=self.creds_per_coin[0]-(self.coins_per_cred[0] shr 3);
      self.coins[0]:=self.coins[0]-(self.coins_per_cred[0] and 7);
    end	else begin
      if (self.coins_per_cred[0] and 8)<>0 then credit_add:=1;
    end;
	end;
	if (val and toggled and $02)<>0 then begin
		self.coins[1]:=self.coins[1]+1;
		if (self.coins[1]>=(self.coins_per_cred[1] and 7)) then begin
			credit_add:=self.creds_per_coin[1]-(self.coins_per_cred[1] shr 3);
			self.coins[1]:=self.coins[1]-(self.coins_per_cred[1] and 7);
		end	else begin
      if (self.coins_per_cred[1] and 8)<>0 then credit_add:=1;
    end;
	end;
	if (val and toggled and $08)<>0 then	credit_add:= 1;
	val:=not(self.in_f[3]);	// pins 30-33
	toggled:=val xor self.lastbuttons;
	self.lastbuttons:=val;
	// check start buttons, only if the game allows
	if ((self.ram[9] and $f)=0) then begin
	// the other argument is IORAM_READ(10) = 1, meaning unknown
		if (val and toggled and $04)<>0 then begin
			if (self.credits>=1) then credit_sub:=1;
		end else begin
      if (val and toggled and $08)<>0 then begin
	  		if (self.credits>=2) then credit_sub:=2;
  		end;
    end;
	end;
	self.credits:=self.credits+credit_add-credit_sub;
  self.ram[0 xor swap]:=(self.credits div 10) and $f;  // BCD credits
  self.ram[1 xor swap]:=(self.credits mod 10) and $f;  // BCD credits
  self.ram[2 xor swap]:=credit_add and $f;  // credit increment (coin inputs)
  self.ram[3 xor swap]:=credit_sub and $f;  // credit decrement (start buttons)
  self.ram[4]:=not(self.in_f[1]) and $f; // pins 22-25
	button:=((val and $05) shl 1) or (val and toggled and $05);
  self.ram[5]:=button and $f;  // pins 30 & 32 normal and impulse
  self.ram[6]:=not(self.in_f[2]) and $f;  // pins 26-29
	button:=(val and $a) or ((val and toggled and $a) shr 1);
  self.ram[7]:=button and $f;  // pins 31 & 33 normal and impulse
end;

procedure namco_5x_chip.run_internal;
var
  i,n,rng,seed:byte;
function NEXT(n:byte):byte;
begin
   if (n and 1)<>0 then next:=(n xor $90) shr 1
    else next:=n shr 1;
end;
begin
case self.tipo of
 NAMCO_56XX:case (self.ram[8] and $f) of  //Namco 56XX
		0:;	// nop?
		1:begin	// read switch inputs
        self.ram[0]:=not(self.in_f[0]) and $f;  // pins 38-41
        self.ram[1]:=not(self.in_f[1]) and $f;  // pins 22-25
        self.ram[2]:=not(self.in_f[2]) and $f;  // pins 26-29
        self.ram[3]:=not(self.in_f[3]) and $f;  // pins 30-33
        if @self.out_f[0]<>nil then self.out_f[0](self.ram[9] and $f);	// output to pins 13-16 (motos, pacnpal, gaplus)
        if @self.out_f[1]<>nil then self.out_f[1](self.ram[$a] and $f);	// output to pins 17-20 (gaplus)
			end;
		2:begin	// initialize coinage settings
  			self.coins_per_cred[0]:=self.ram[9] and $f;
  			self.creds_per_coin[0]:=self.ram[$a] and $f;
  			self.coins_per_cred[1]:=self.ram[$b] and $f;
  			self.creds_per_coin[1]:=self.ram[$c] and $f;
  			// IORAM_READ(13) = 1; meaning unknown - possibly a 3rd coin input? (there's a IPT_UNUSED bit in port A)
  			// IORAM_READ(14) = 1; meaning unknown - possibly a 3rd coin input? (there's a IPT_UNUSED bit in port A)
  			// IORAM_READ(15) = 0; meaning unknown
			end;
		4:begin	// druaga, digdug chip #1: read dip switches and inputs
  				// superpac chip #0: process coin and start inputs, read switch inputs
	  		self.handle_coins(0);
  		end;
		7:begin	// bootup check (liblrabl only)
				// liblrabl chip #1: 9-15 = f 1 2 3 4 0 0, expects 2 = e
				// liblrabl chip #2: 9-15 = 0 1 4 5 5 0 0, expects 7 = 6
        self.ram[2]:=$e;
        self.ram[7]:=$6;
			end;
		8:begin	// bootup check
				// superpac: 9-15 = f f f f f f f, expects 0-1 = 6 9. 0x69 = f+f+f+f+f+f+f.
				// motos:    9-15 = f f f f f f f, expects 0-1 = 6 9. 0x69 = f+f+f+f+f+f+f.
				// phozon:   9-15 = 1 2 3 4 5 6 7, expects 0-1 = 1 c. 0x1c = 1+2+3+4+5+6+7
				n:=0;
				for i:=9 to 15 do n:=n+(self.ram[i] and $f);
        self.ram[0]:=n shr 4;
        self.ram[1]:=n and $f;
			end;
		9:begin	// read dip switches and inputs
  			if @self.out_f[0]<>nil then self.out_f[0](0);	// set pin 13 = 0
        self.ram[0]:=not(self.in_f[0]) and $f;
        self.ram[2]:=not(self.in_f[1]) and $f;
        self.ram[4]:=not(self.in_f[2]) and $f;
        self.ram[5]:=not(self.in_f[3]) and $f;
  			if @self.out_f[0]<>nil then self.out_f[0](1);	// set pin 13 = 0
        self.ram[1]:=not(self.in_f[0]) and $f;
        self.ram[3]:=not(self.in_f[1]) and $f;
        self.ram[5]:=not(self.in_f[2]) and $f;
        self.ram[7]:=not(self.in_f[3]) and $f;
			end;
   end;
 NAMCO_58XX:case (self.ram[8] and $f) of  //Namco 58XX
    0:; //nop
		1:begin	// read switch inputs
        self.ram[4]:=not(self.in_f[0]) and $f;
        self.ram[5]:=not(self.in_f[1]) and $f;
        self.ram[6]:=not(self.in_f[2]) and $f;
        self.ram[7]:=not(self.in_f[3]) and $f;
			  //WRITE_PORT(space,0,IORAM_READ(9));	// output to pins 13-16 (toypop)
			  //WRITE_PORT(space,1,IORAM_READ(10));	// output to pins 17-20 (toypop)
			end;
    2:begin	// initialize coinage settings
  			self.coins_per_cred[0]:=self.ram[9] and $f;
    		self.creds_per_coin[0]:=self.ram[$a] and $f;
  			self.coins_per_cred[1]:=self.ram[$b] and $f;
  			self.creds_per_coin[1]:=self.ram[$c] and $f;
	  		// IORAM_READ(13) = 1; meaning unknown - possibly a 3rd coin input? (there's a IPT_UNUSED bit in port A)
  			// IORAM_READ(14) = 0; meaning unknown - possibly a 3rd coin input? (there's a IPT_UNUSED bit in port A)
		  	// IORAM_READ(15) = 0; meaning unknown
			end;
    3:self.handle_coins(2); //coin handle
    4:begin	// read dip switches and inputs
  			if @self.out_f[0]<>nil then self.out_f[0](0);	// set pin 13 = 0
        self.ram[0]:=not(self.in_f[0]) and $f;
        self.ram[2]:=not(self.in_f[1]) and $f;
        self.ram[4]:=not(self.in_f[2]) and $f;
        self.ram[6]:=not(self.in_f[3]) and $f;
        if @self.out_f[0]<>nil then self.out_f[0](1);	// set pin 13 = 0
        self.ram[1]:=not(self.in_f[0]) and $f;
        self.ram[3]:=not(self.in_f[1]) and $f;
        self.ram[5]:=not(self.in_f[2]) and $f;
        self.ram[7]:=not(self.in_f[3]) and $f;
			end;
		5:begin	// bootup check
			{ mode 5 values are checked against these numbers during power up
               mappy:  9-15 = 3 6 5 f a c e, expects 1-7 =   8 4 6 e d 9 d
               grobda: 9-15 = 2 3 4 5 6 7 8, expects 2 = f and 6 = c
               phozon: 9-15 = 0 1 2 3 4 5 6, expects 0-7 = 0 2 3 4 5 6 c a
               gaplus: 9-15 = f f f f f f f, expects 0-1 = f f
        This has been determined to be the result of repeated XORs,
        controlled by a 7-bit LFSR. The following algorithm should be
        equivalent to the original one (though probably less efficient).
        The first nibble of the result however is uncertain. It is usually
        0, but in some cases it toggles between 0 and F. We use a kludge
        to give Gaplus the F it expects.}
				//initialize the LFSR depending on the first two arguments
				n:=((self.ram[9] and $f)*16+(self.ram[$a] and $f)) and $7f;
				seed:=$22;
				for i:=0 to n-1 do seed:=NEXT(seed);
        // calculate the answer
				for i:=1 to 7 do begin
					n:=0;
					rng:=seed;
					if (rng and 1)<>0 then n:=n xor (not(self.ram[$b]) and $f);
					rng:=NEXT(rng);
					seed:=rng;	// save state for next loop
					if (rng and 1)<>0 then n:=n xor (not(self.ram[$a]) and $f);
					rng:=NEXT(rng);
					if (rng and 1)<>0 then n:=n xor (not(self.ram[9]) and $f);
					rng:=NEXT(rng);
					if (rng and 1)<>0 then n:=n xor (not(self.ram[$f]) and $f);
					rng:=NEXT(rng);
					if (rng and 1)<>0 then n:=n xor (not(self.ram[$e]) and $f);
					rng:=NEXT(rng);
					if (rng and 1)<>0 then n:=n xor (not(self.ram[$d]) and $f);
					rng:=NEXT(rng);
					if (rng and 1)<>0 then n:=n xor (not(self.ram[$c]) and $f);
          self.ram[i]:=not(n) and $f;
				end;
				self.ram[0]:=0;
				// kludge for gaplus
				if (self.ram[9] and $f)=$f then self.ram[0]:=$f;
			end;
 end;
 NAMCO_59XX:case (self.ram[8] and $f) of  //Namco 59XX
		  0:; // nop?
		  3:begin // pacnpal chip #1: read dip switches and inputs
          self.ram[4]:=not(self.in_f[0]) and $f;  // pins 38-41, pin 13 = 0 ?
          self.ram[5]:=not(self.in_f[2]) and $f;  // pins 26-29 ?
          self.ram[6]:=not(self.in_f[1]) and $f;  // pins 22-25 ?
          self.ram[7]:=not(self.in_f[3]) and $f;  // pins 30-33
        end;
 end;
end;
end;

procedure namco_5x_chip.reset_internal(reset_status:boolean);
begin
	self.reset_status:=reset_status;
  if reset_status then begin
    // reset internal registers
    self.lastcoins:=0;
    self.lastbuttons:=0;
    self.credits:= 0;
    self.coins[0]:=0;
    self.coins_per_cred[0]:=1;
    self.creds_per_coin[0]:=1;
    self.coins[1]:=0;
    self.coins_per_cred[1]:=1;
    self.creds_per_coin[1]:=1;
    self.in_count:=0;
  end;
end;

end.
