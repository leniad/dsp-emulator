unit namcoio_56xx_58xx;

interface

type
  tin_f=function:byte;  
  tout_f=procedure (data:byte); 
  tnamco_io=record
               tipo:byte;
               namco_io_ram:array[0..$f] of byte;
               coins,coins_per_cred,creds_per_coin:array[0..1] of byte;
            	 in_count,credits,lastcoins,lastbuttons:byte;
               in_f:array[0..3] of tin_f;
               out_f:array[0..1] of tout_f;
               reset:boolean;
            end;
var
   namco_chip:array[0..1] of tnamco_io;
const
  namco_56xx=0;
  namco_58xx=1;


procedure namco_io_run(num:byte);
function namcoio_r(num,direccion:byte):byte;
procedure namcoio_w(num,direccion,data:byte);
procedure namco_io_init(num:byte);
procedure namco_io_reset(num:byte;reset:boolean);

implementation

function namcoio_r(num,direccion:byte):byte;
begin
 	// RAM is 4-bit wide; Pac & Pal requires the | 0xf0 otherwise Easter egg doesn't work
	direccion:=direccion and $3f;
	namcoio_r:=$f0 or namco_chip[num].namco_io_ram[direccion];
end;

procedure namcoio_w(num,direccion,data:byte);
begin
	direccion:=direccion and $3f;
	namco_chip[num].namco_io_ram[direccion]:=data and $f;
end;

function ram_read(num,pos:byte):byte;
begin
  ram_read:=namco_chip[num].namco_io_ram[pos] and $f;
end;

procedure ram_write(num,pos,data:byte);
begin
  namco_chip[num].namco_io_ram[pos]:=data and $f;
end;

procedure handle_coins(num,swap:byte);
var
	val,toggled:byte;
	credit_add:byte;
	credit_sub:byte;
	button:byte;
begin
  credit_add:=0;
	credit_sub:=0;
	val:=not(namco_chip[num].in_f[0]);	// pins 38-41
	toggled:=val xor namco_chip[num].lastcoins;
	namco_chip[num].lastcoins:=val;
	// check coin insertion */
	if (val and toggled and $01)<>0 then begin
		namco_chip[num].coins[0]:=namco_chip[num].coins[0]+1;
		if (namco_chip[num].coins[0]>=(namco_chip[num].coins_per_cred[0] and 7)) then begin
			credit_add:=namco_chip[num].creds_per_coin[0]-(namco_chip[num].coins_per_cred[0] shr 3);
			namco_chip[num].coins[0]:=namco_chip[num].coins[0]-(namco_chip[num].coins_per_cred[0] and 7);
    end	else begin
      if (namco_chip[num].coins_per_cred[0] and 8)<>0 then credit_add:=1;
    end;
	end;
	if (val and toggled and $02)<>0 then begin
		namco_chip[num].coins[1]:=namco_chip[num].coins[1]+1;
		if (namco_chip[num].coins[1] >= (namco_chip[num].coins_per_cred[1] and 7)) then begin
			credit_add:=namco_chip[num].creds_per_coin[1]-(namco_chip[num].coins_per_cred[1] shr 3);
			namco_chip[num].coins[1]:=namco_chip[num].coins[1]-(namco_chip[num].coins_per_cred[1] and 7);
		end	else begin
      if (namco_chip[num].coins_per_cred[1] and 8)<>0 then credit_add:=1;
    end;
	end;
	if (val and toggled and $08)<>0 then	credit_add:= 1;
	val:=not(namco_chip[num].in_f[3]);	// pins 30-33
	toggled:= val xor namco_chip[num].lastbuttons;
	namco_chip[num].lastbuttons:=val;
	// check start buttons, only if the game allows */
	if (ram_read(num,9)=0) then begin
	// the other argument is IORAM_READ(10) = 1, meaning unknown
		if (val and toggled and $04)<>0 then begin
			if (namco_chip[num].credits>=1) then credit_sub:=1;
		end else begin
      if (val and toggled and $08)<>0 then begin
	  		if (namco_chip[num].credits >= 2) then credit_sub:=2;
  		end;
    end;
	end;
	namco_chip[num].credits:=namco_chip[num].credits+credit_add-credit_sub;
  ram_write(num,0 xor swap,namco_chip[num].credits div 10);  // BCD credits
  ram_write(num,1 xor swap,namco_chip[num].credits mod 10);  // BCD credits
  ram_write(num,2 xor swap,credit_add);  // credit increment (coin inputs)
  ram_write(num,3 xor swap,credit_sub);  // credit decrement (start buttons)
  ram_write(num,4,not(namco_chip[num].in_f[1])); // pins 22-25
	button:=((val and $05) shl 1) or (val and toggled and $05);
  ram_write(num,5,button);  // pins 30 & 32 normal and impulse
  ram_write(num,6,not(namco_chip[num].in_f[2]));  // pins 26-29
	button:=(val and $0a) or ((val and toggled and $0a) shr 1);
  ram_write(num,7,button);  // pins 31 & 33 normal and impulse
end;

procedure namco_io_run(num:byte);
var
  i,n,rng,seed:byte;
function NEXT(n:byte):byte;
begin
   if (n and 1)<>0 then next:=(n xor $90) shr 1
    else next:=n shr 1;
end;
begin
case namco_chip[num].tipo of
 namco_56xx:case ram_read(num,8) of  //Namco 56XX
		0:;	// nop?
		1:begin	// read switch inputs
        ram_write(num,0,not(namco_chip[num].in_f[0]));  // pins 38-41
        ram_write(num,1,not(namco_chip[num].in_f[1]));  // pins 22-25
        ram_write(num,2,not(namco_chip[num].in_f[2]));  // pins 26-29
        ram_write(num,3,not(namco_chip[num].in_f[3]));  // pins 30-33
        if @namco_chip[num].out_f[0]<>nil then namco_chip[num].out_f[0](ram_read(num,9));	// output to pins 13-16 (motos, pacnpal, gaplus)
        if @namco_chip[num].out_f[1]<>nil then namco_chip[num].out_f[1](ram_read(num,10));	// output to pins 17-20 (gaplus)
			end;
		2:begin	// initialize coinage settings
  			namco_chip[num].coins_per_cred[0]:=ram_read(num,9);
  			namco_chip[num].creds_per_coin[0]:=ram_read(num,10);
  			namco_chip[num].coins_per_cred[1]:=ram_read(num,11);
  			namco_chip[num].creds_per_coin[1]:=ram_read(num,12);
  			// IORAM_READ(13) = 1; meaning unknown - possibly a 3rd coin input? (there's a IPT_UNUSED bit in port A)
  			// IORAM_READ(14) = 1; meaning unknown - possibly a 3rd coin input? (there's a IPT_UNUSED bit in port A)
  			// IORAM_READ(15) = 0; meaning unknown
			end;
		4:begin	// druaga, digdug chip #1: read dip switches and inputs
  				// superpac chip #0: process coin and start inputs, read switch inputs
	  		handle_coins(num,0);
  		end;
		7:begin	// bootup check (liblrabl only)
				// liblrabl chip #1: 9-15 = f 1 2 3 4 0 0, expects 2 = e
				// liblrabl chip #2: 9-15 = 0 1 4 5 5 0 0, expects 7 = 6
        ram_write(num,2,$e);
        ram_write(num,7,$6);
			end;
		8:begin	// bootup check
				// superpac: 9-15 = f f f f f f f, expects 0-1 = 6 9. 0x69 = f+f+f+f+f+f+f.
				// motos:    9-15 = f f f f f f f, expects 0-1 = 6 9. 0x69 = f+f+f+f+f+f+f.
				// phozon:   9-15 = 1 2 3 4 5 6 7, expects 0-1 = 1 c. 0x1c = 1+2+3+4+5+6+7
				n:=0;
				for i:=9 to 15 do n:=n+ram_read(num,i);
        ram_write(num,0,n shr 4);
        ram_write(num,1,n and $f);
			end;
		9:begin	// read dip switches and inputs
  			if @namco_chip[num].out_f[0]<>nil then namco_chip[num].out_f[0](0);	// set pin 13 = 0
        ram_write(num,0,not(namco_chip[num].in_f[0]));
        ram_write(num,2,not(namco_chip[num].in_f[1]));
        ram_write(num,4,not(namco_chip[num].in_f[2]));
        ram_write(num,6,not(namco_chip[num].in_f[3]));
  			if @namco_chip[num].out_f[0]<>nil then namco_chip[num].out_f[0](1);	// set pin 13 = 0
  			ram_write(num,1,not(namco_chip[num].in_f[0]));
        ram_write(num,3,not(namco_chip[num].in_f[1]));
        ram_write(num,5,not(namco_chip[num].in_f[2]));
        ram_write(num,7,not(namco_chip[num].in_f[3]));
			end;
   end;
 namco_58xx:case ram_read(num,8) of  //Namco 58XX
    0:; //nop
		1:begin	// read switch inputs
        ram_write(num,4,not(namco_chip[num].in_f[0]));
        ram_write(num,5,not(namco_chip[num].in_f[1]));
        ram_write(num,6,not(namco_chip[num].in_f[2]));
        ram_write(num,7,not(namco_chip[num].in_f[3]));
			  //WRITE_PORT(space,0,IORAM_READ(9));	// output to pins 13-16 (toypop)
			  //WRITE_PORT(space,1,IORAM_READ(10));	// output to pins 17-20 (toypop)
			end;
    2:begin	// initialize coinage settings
  			namco_chip[num].coins_per_cred[0]:=ram_read(num,9);
    		namco_chip[num].creds_per_coin[0]:=ram_read(num,10);
  			namco_chip[num].coins_per_cred[1]:=ram_read(num,11);
  			namco_chip[num].creds_per_coin[1]:=ram_read(num,12);
	  		// IORAM_READ(13) = 1; meaning unknown - possibly a 3rd coin input? (there's a IPT_UNUSED bit in port A)
  			// IORAM_READ(14) = 0; meaning unknown - possibly a 3rd coin input? (there's a IPT_UNUSED bit in port A)
		  	// IORAM_READ(15) = 0; meaning unknown
			end;
    3:handle_coins(num,2); //coin handle
    4:begin	// read dip switches and inputs
  			if @namco_chip[num].out_f[0]<>nil then namco_chip[num].out_f[0](0);	// set pin 13 = 0
        ram_write(num,0,not(namco_chip[num].in_f[0]));
        ram_write(num,2,not(namco_chip[num].in_f[1]));
        ram_write(num,4,not(namco_chip[num].in_f[2]));
        ram_write(num,6,not(namco_chip[num].in_f[3]));
        if @namco_chip[num].out_f[0]<>nil then namco_chip[num].out_f[0](1);	// set pin 13 = 0
        ram_write(num,1,not(namco_chip[num].in_f[0]));
        ram_write(num,3,not(namco_chip[num].in_f[1]));
        ram_write(num,5,not(namco_chip[num].in_f[2]));
        ram_write(num,7,not(namco_chip[num].in_f[3]));
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
               to give Gaplus the F it expects.
				/* initialize the LFSR depending on the first two arguments }
				n:= (ram_read(num,9)*16+ram_read(num,10)) and $7f;
				seed:=$22;
				for i:=0 to n-1 do seed:=NEXT(seed);
				  // calculate the answer */
				for i:=1 to 7 do begin
					n:=0;
					rng:=seed;
					if (rng and 1)<>0 then n:=n xor not(ram_read(num,11));
					rng:=NEXT(rng);
					seed:=rng;	// save state for next loop
					if (rng and 1)<>0 then n:=n xor not(ram_read(num,10));
					rng:=NEXT(rng);
					if (rng and 1)<>0 then n:=n xor not(ram_read(num,9));
					rng:=NEXT(rng);
					if (rng and 1)<>0 then n:=n xor not(ram_read(num,15));
					rng:=NEXT(rng);
					if (rng and 1)<>0 then n:=n xor not(ram_read(num,14));
					rng:=NEXT(rng);
					if (rng and 1)<>0 then n:=n xor not(ram_read(num,13));
					rng:=NEXT(rng);
					if (rng and 1)<>0 then n:=n xor not(ram_read(num,12));
          ram_write(num,i,not(n));
				end;
				ram_write(num,0,0);
				// kludge for gaplus */
				if (ram_read(num,9)=$f) then ram_write(num,0,$f);
			end;
    end;
 2:;
end;
end;

procedure namco_io_init(num:byte);
var
  f:byte;
begin
	namco_chip[num].reset:=false;
  for f:=0 to $f do namco_chip[num].namco_io_ram[f]:=0;
end;

procedure namco_io_reset(num:byte;reset:boolean);
begin
	namco_chip[num].reset:=reset;
  if reset then begin
    // reset internal registers */
    namco_chip[num].lastcoins:=0;
    namco_chip[num].lastbuttons:=0;
    namco_chip[num].credits:= 0;
    namco_chip[num].coins[0]:=0;
    namco_chip[num].coins_per_cred[0]:= 1;
    namco_chip[num].creds_per_coin[0]:= 1;
    namco_chip[num].coins[1]:=0;
    namco_chip[num].coins_per_cred[1]:= 1;
    namco_chip[num].creds_per_coin[1]:= 1;
    namco_chip[num].in_count:=0;
  end;
end;

end.
