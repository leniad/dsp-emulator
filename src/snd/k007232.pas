unit k007232;
interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
      sound_engine,timer_engine;

const
   KDAC_A_PCM_MAX=2;

type
  tk007232_call_back=procedure (valor:byte);
  k007232_chip=class(snd_chip_class)
        constructor create(clock:dword;rom_adpcm:pbyte;size:dword;amplifi:single;call_back:tk007232_call_back);
        destructor free;
    public
        procedure update;
        procedure set_volume(channel,volumeA,volumeB:byte);
        procedure write(direccion,valor:byte);
        function read(direccion:byte):byte;
        procedure set_bank(banka,bankb:byte);
    private
        vol:array[0..KDAC_A_PCM_MAX-1,0..1] of byte; // volume for the left and right channel
	      address,start,step,bank:array[0..KDAC_A_PCM_MAX-1] of dword;
	      play:array[0..KDAC_A_PCM_MAX-1] of boolean;
	      wreg:array[0..$f] of byte; //write data
	      pcmlimit:dword;
	      ntimer:byte;
	      fncode:array[0..$1ff] of dword;
        call_back:tk007232_call_back;
        rom:pbyte;
        out1,out2:integer;
        tsample_num2:byte;
        procedure internal_update;
    end;

procedure internal_update_k007232_0;

var
  k007232_0,k007232_1:k007232_chip;

implementation
const
   BASE_SHIFT=12;

constructor k007232_chip.create(clock:dword;rom_adpcm:pbyte;size:dword;amplifi:single;call_back:tk007232_call_back);
var
  f:word;
begin
	// Set up the chips */
	self.pcmlimit:=size;
  self.call_back:=call_back;
  self.clock:=clock;
	for f:=0 to (KDAC_A_PCM_MAX-1) do begin
		self.address[f]:=0;
		self.start[f]:=0;
		self.step[f]:=0;
		self.play[f]:=false;
		self.bank[f]:=0;
	end;
	self.vol[0,0]:=255;  // channel A output to output A */
	self.vol[0,1]:=0;
	self.vol[1,0]:=0;
	self.vol[1,1]:=255;  // channel B output to output B */
  self.amp:=amplifi;
	for f:=0 to $f do self.wreg[f]:=0;
  self.ntimer:=init_timer(sound_status.cpu_num,sound_status.cpu_clock/(clock/128),internal_update_k007232_0,true);
  self.tsample_num:=init_channel;
  self.tsample_num2:=init_channel;
  self.rom:=rom_adpcm;
	//KDAC_A_make_fncode;
  for f:=0 to $1ff do self.fncode[f]:=round((32 shl BASE_SHIFT)/($200-f));
end;

destructor k007232_chip.free;
begin
end;

procedure k007232_chip.write(direccion,valor:byte);
var
  r,idx:word;
  v,reg_port:byte;
begin
	r:=direccion;
	v:=valor;
	self.wreg[r]:=v; //store write data
  case r  of
	  $c:if (@self.call_back<>nil) then self.call_back(v); // external port, usually volume control
	  $d:; // loopflag.
    else begin
          if (r>=$06) then begin
            reg_port:=1;
            r:=r-$06;
          end else reg_port:=0;
          case r of
            0,1:begin //*** address step ****
                    idx:=((self.wreg[reg_port*6+1] shl 8) and $100) or self.wreg[reg_port*6];
                    self.step[reg_port]:=self.fncode[idx];
                end;
            2,3,4:;
            5:begin  //*** start address ****
                    self.start[reg_port]:=((self.wreg[reg_port*6+4] and 1) shl 16) or
                                          (self.wreg[reg_port*6+3] shl 8) or
                                          self.wreg[reg_port*6+2] or
                                          self.bank[reg_port];
                    if (self.start[reg_port]<self.pcmlimit) then begin
                        self.play[reg_port]:=true;
                        self.address[reg_port]:=0;
                    end;
            end;
          end;
    end;
  end;
end;

function k007232_chip.read(direccion:byte):byte;
var
  r:byte;
  ch:byte;
begin
r:=direccion;
ch:=0;
if ((r=$5) or (r=$b)) then begin
	  ch:=r div 6;
	  r:=ch*6;
	  self.start[ch]:=((self.wreg[r+4] and 1) shl 16) or
		                (self.wreg[r+3] shl 8)  or
		                (self.wreg[r+2]) or
                    self.bank[ch];
	  if (self.start[ch]<self.pcmlimit) then begin
		  self.play[ch]:=true;
		  self.address[ch]:=0;
	  end;
end;
read:=0;
end;

procedure k007232_chip.set_volume(channel,volumeA,volumeB:byte);
begin
	self.vol[channel,0]:=volumeA;
	self.vol[channel,1]:=volumeB;
end;

procedure k007232_chip.set_bank(banka,bankb:byte);
begin
	self.bank[0]:=banka shl 17;
	self.bank[1]:=bankb shl 17;
end;

procedure k007232_chip.internal_update;
var
  f:byte;
  addr,old_addr:dword;
  volA,volB:word;
begin
self.out1:=0;
self.out2:=0;
for f:=0 to (KDAC_A_PCM_MAX-1) do begin
    if self.play[f] then begin
       //*** PCM setup ****/
       addr:=self.start[f]+((self.address[f] shr BASE_SHIFT) and $fffff);
       volA:=self.vol[f,0]*2;
       volB:=self.vol[f,1]*2;
       old_addr:=addr;
       addr:=self.start[f]+((self.address[f] shr BASE_SHIFT) and $fffff);
       while (old_addr<=addr) do begin
             if (((self.rom[old_addr] and $80)<>0) or (old_addr>=self.pcmlimit)) then begin // end of sample
		if (self.wreg[$d] and (1 shl f))<>0 then begin // loop to the beginning
	  	   self.start[f]:=((self.wreg[f*6+4] and 1) shl 16) or
                                  (self.wreg[f*6+3] shl 8) or
	 			  (self.wreg[f*6+2]) or
                                  self.bank[f];
	  	   addr:=self.start[f];
		   self.address[f]:=0;
		   old_addr:=addr; // skip loop
		end else self.play[f]:=false; // stop sample
                break;
             end;
             old_addr:=old_addr+1;
       end;
       if not(self.play[f]) then break;
       self.address[f]:=self.address[f]+self.step[f];
       self.out1:=self.out1+(((self.rom[addr] and $7f)-$40)*volA);
       self.out2:=self.out2+(((self.rom[addr] and $7f)-$40)*volB);
    end;
end;
end;

procedure internal_update_k007232_0;
begin
  k007232_0.internal_update;
end;

procedure k007232_chip.update;
begin
  //Channel 1
  tsample[self.tsample_num,sound_status.posicion_sonido]:=round(self.out1*self.amp);
  if sound_status.stereo then tsample[self.tsample_num,sound_status.posicion_sonido+1]:=round(self.out1*self.amp);
  //Channel 2
  tsample[self.tsample_num2,sound_status.posicion_sonido]:=round(self.out2*self.amp);
  if sound_status.stereo then tsample[self.tsample_num2,sound_status.posicion_sonido+1]:=round(self.out2*self.amp);
end;

end.
