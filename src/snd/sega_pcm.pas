unit sega_pcm;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}sound_engine,timer_engine;

type
  tread_rom_call=function(dir:dword):byte;
  tsega_pcm=class(snd_chip_class)
          constructor create(clock:dword;read_rom_call:tread_rom_call;amp:single);
          destructor free;
        public
          read_rom:tread_rom_call;
          procedure reset;
          function read(dir:word):byte;
          procedure write(dir:word;valor:byte);
          procedure set_bank(bank:byte);
          procedure update;
        protected
          ram:array[0..$7ff] of byte;
          outl,outr:integer;
          ntimer,bankshift,bankmask:byte;
          clock:dword;
          low:array[0..15] of byte;
  end;
const
  BANK_256    = 11;
	BANK_512    = 12;
	BANK_12M    = 13;
	BANK_MASK7  = $70 shl 16;
	BANK_MASKF  = $f0 shl 16;
	BANK_MASKF8 = $f8 shl 16;

procedure internal_update_segapcm;

var
  sega_pcm_0:tsega_pcm;

implementation

constructor tsega_pcm.create(clock:dword;read_rom_call:tread_rom_call;amp:single);
begin
  self.tsample_num:=init_channel;
  self.amp:=amp;
  self.clock:=clock;
  self.read_rom:=read_rom_call;
  self.ntimer:=timers.init(sound_status.cpu_num,sound_status.cpu_clock/(clock/128),internal_update_segapcm,nil,true);
end;

destructor tsega_pcm.free;
begin
end;

procedure tsega_pcm.reset;
begin
  fillchar(self.ram[0],$800,$ff);
  self.outl:=0;
  self.outr:=0;
end;

function tsega_pcm.read(dir:word):byte;
begin
  read:=self.ram[dir and $7ff];
end;
procedure tsega_pcm.write(dir:word;valor:byte);
begin
  self.ram[dir and $7ff]:=valor;
end;

procedure tsega_pcm.set_bank(bank:byte);
begin
  self.bankshift:=(bank and $f);
  self.bankmask:=($70 or ((bank shr 16) and $fc));
end;

procedure tsega_pcm.update;
begin
  tsample[self.tsample_num,sound_status.posicion_sonido]:=self.outl;
  if sound_status.stereo then tsample[self.tsample_num,sound_status.posicion_sonido+1]:=self.outr;
end;

procedure internal_update_segapcm;
var
  f,end_,control:byte;
  offset,addr,loop:dword;
  v:shortint;
begin
  sega_pcm_0.outl:=0;
  sega_pcm_0.outr:=0;
  for f:=0 to 15 do begin
    control:=sega_pcm_0.ram[$86+(f*8)];
		// only process active channels
		if (control and 1)=0 then begin
			offset:=(control and sega_pcm_0.bankmask) shl sega_pcm_0.bankshift;
      addr:=(sega_pcm_0.ram[$85+(f*8)] shl 16) or (sega_pcm_0.ram[$84+(f*8)] shl 8) or sega_pcm_0.low[f];
			loop:=(sega_pcm_0.ram[$05+(f*8)] shl 16) or (sega_pcm_0.ram[$04+(f*8)] shl 8);
			end_:=sega_pcm_0.ram[6+(f*8)]+1;
      // handle looping if we've hit the end
      if ((addr shr 16)=end_) then begin
					if (control and 2)<>0 then begin
						sega_pcm_0.ram[$86+(f*8)]:=control or 1;
            sega_pcm_0.ram[$84+(f*8)]:=addr shr 8;
			      sega_pcm_0.ram[$85+(f*8)]:=addr shr 16;
            sega_pcm_0.low[f]:=0;
						continue;
					end else addr:=loop;
      end;
			// fetch the sample
      v:=sega_pcm_0.read_rom(offset+(addr shr 8))-$80;
      // apply panning and advance
      sega_pcm_0.outl:=sega_pcm_0.outl+(v*(sega_pcm_0.ram[2+(f*8)] and $7f));
      sega_pcm_0.outr:=sega_pcm_0.outr+(v*(sega_pcm_0.ram[3+(f*8)] and $7f));
      addr:=(addr+sega_pcm_0.ram[7+(f*8)]) and $ffffff;
			// store back the updated address
			sega_pcm_0.ram[$84+(f*8)]:=addr shr 8;
			sega_pcm_0.ram[$85+(f*8)]:=addr shr 16;
      if (control and 1)<>0 then sega_pcm_0.low[f]:=0
        else sega_pcm_0.low[f]:=addr and $ff;
		end;
  end; //del chnnel
  if sega_pcm_0.outl<-32767 then sega_pcm_0.outl:=-32767
    else if sega_pcm_0.outl>32767 then sega_pcm_0.outl:=32767;
  if sega_pcm_0.outr<-32767 then sega_pcm_0.outr:=-32767
    else if sega_pcm_0.outr>32767 then sega_pcm_0.outr:=32767;
end;

end.
