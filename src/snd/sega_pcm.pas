unit sega_pcm;

interface
uses main_engine,sound_engine,timer_engine,dialogs;

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
    procedure set_bank(bank:dword);
    procedure update;
  protected
    ram:array[0..$7ff] of byte;
    outl,outr:integer;
    ntimer,bankshift,bankmask:byte;
    clock:dword;
    low:array[0..15] of byte;
    instance_slot:byte;
    procedure generate_sample;
  end;

const
  BANK_256=11;
  BANK_512=12;
  BANK_12M=13;
  BANK_MASK7=$70 shl 16;
  BANK_MASKF=$f0 shl 16;
  BANK_MASKF8=$f8 shl 16;

var
  sega_pcm_0:tsega_pcm;

implementation

const
  MAX_SEGA_PCM_INSTANCES=16;
  NO_TIMER=$ff;
var
  sega_pcm_instances:array[0..MAX_SEGA_PCM_INSTANCES-1] of tsega_pcm;

procedure internal_update_segapcm_instance(slot:byte);
begin
  if sega_pcm_instances[slot]<>nil then
    sega_pcm_instances[slot].generate_sample;
end;

constructor tsega_pcm.create(clock:dword;read_rom_call:tread_rom_call;amp:single);
var
  slot:integer;
begin
  if addr(update_sound_proc)=nil then MessageDlg('ERROR: Chip de sonido inicializado sin CPU de sonido!', mtInformation,[mbOk], 0);
  self.ntimer:=NO_TIMER;
  self.instance_slot:=NO_TIMER;
  slot:=0;
  while slot<MAX_SEGA_PCM_INSTANCES do begin
    if sega_pcm_instances[slot]=nil then break;
    inc(slot);
  end;
  self.tsample_num:=init_channel;
  self.amp:=amp;
  self.clock:=clock;
  self.read_rom:=read_rom_call;
  self.set_bank(BANK_512);
  self.reset;
  self.instance_slot:=slot;
  sega_pcm_instances[slot]:=self;
  self.ntimer:=timers.init(sound_status.cpu_num,sound_status.cpu_clock/(clock/128),nil,internal_update_segapcm_instance,true,self.instance_slot);
end;

destructor tsega_pcm.free;
begin
  if (self.ntimer<>NO_TIMER) and (timers<>nil) then timers.enabled(self.ntimer,false);
  if self.instance_slot<MAX_SEGA_PCM_INSTANCES then
    if sega_pcm_instances[self.instance_slot]=self then sega_pcm_instances[self.instance_slot]:=nil;
  if sega_pcm_0=self then sega_pcm_0:=nil;
end;

procedure tsega_pcm.reset;
begin
  FillChar(self.ram,SizeOf(self.ram),$ff);
  FillChar(self.low,SizeOf(self.low),0);
  self.outl:=0;
  self.outr:=0;
  // Bank configuration and the free-running timer phase are preserved.
end;

function tsega_pcm.read(dir:word):byte;
begin
  Result:=self.ram[dir and $7ff];
end;

procedure tsega_pcm.write(dir:word;valor:byte);
begin
  self.ram[dir and $7ff]:=valor;
end;

procedure tsega_pcm.set_bank(bank:dword);
begin
  self.bankshift:=bank and $f;
  self.bankmask:=$70 or ((bank shr 16) and $fc);
end;

procedure tsega_pcm.update;
function sega_pcm_clip(value:double):smallint;
begin
  if value>32767 then Result:=32767
    else if value<-32768 then Result:=-32768
            else Result:=Trunc(value);
end;
var
  left,right,gain:double;
begin
  left:=self.outl;
  right:=self.outr;
  gain:=self.amp;
  if sound_status.stereo then begin
    tsample[self.tsample_num,sound_status.posicion_sonido]:=sega_pcm_clip(left*gain);
    tsample[self.tsample_num,sound_status.posicion_sonido+1]:=sega_pcm_clip(right*gain);
  end else begin
    tsample[self.tsample_num,sound_status.posicion_sonido]:=sega_pcm_clip((left+right)*0.5*gain);
  end;
end;

procedure tsega_pcm.generate_sample;
var
  f,base:integer;
  end_,control:byte;
  offset,addr,loop:dword;
  v:integer;
begin
  self.outl:=0;
  self.outr:=0;
  for f:=0 to 15 do begin
    base:=f*8;
    control:=self.ram[$86+base];
    if (control and 1)<>0 then begin
      self.low[f]:=0;
      continue;
    end;
    offset:=dword(control and self.bankmask) shl self.bankshift;
    addr:=(dword(self.ram[$85+base]) shl 16) or
          (dword(self.ram[$84+base]) shl 8) or self.low[f];
    loop:=(dword(self.ram[5+base]) shl 16) or
          (dword(self.ram[4+base]) shl 8);
    end_:=byte((integer(self.ram[6+base])+1) and $ff);
    // Exact page equality, including $ff -> $00 wrap, matches MAME.
    if (addr shr 16)=end_ then begin
      if (control and 2)<>0 then begin
        self.ram[$86+base]:=control or 1;
        self.low[f]:=0;
        continue;
      end;
      addr:=loop;
    end;
    v:=integer(self.read_rom(offset+(addr shr 8)))-$80;
    Inc(self.outl,v*(self.ram[2+base] and $7f));
    Inc(self.outr,v*(self.ram[3+base] and $7f));
    addr:=(addr+self.ram[7+base]) and $ffffff;
    self.ram[$84+base]:=byte((addr shr 8) and $ff);
    self.ram[$85+base]:=byte((addr shr 16) and $ff);
    self.low[f]:=byte(addr and $ff);
  end;
end;

end.
