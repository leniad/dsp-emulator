unit oki6295;

interface
uses {$IFDEF WINDOWS}windows,{$else}main_engine,{$ENDIF}
     math,dialogs,timer_engine,sysutils,sound_engine;

const
  OKIM6295_VOICES=4;
  OKIM6295_PIN7_LOW=0;
  OKIM6295_PIN7_HIGH=1;

type
      adpcm_state=record
        signal:integer;
        step:integer;
      end;
      // struct describing a single playing ADPCM voice */
      ADPCMVoice=record
	        playing:boolean;			//if we are actively playing */
	        base_offset:dword;		// pointer to the base memory location */
	        sample:dword;			// current sample number */
	        count:dword;			// total samples to play */
          adpcm:adpcm_state; // current ADPCM state */
	        volume:dword;			// output volume
      end;
      snd_okim6295=class(snd_chip_class)
            constructor Create(clock:dword;pin7:byte;amp:single=1);
            destructor free;
          public
            procedure reset;
            function read:byte;
            procedure write(valor:byte);
            procedure change_pin7(pin7:byte);
            function get_rom_addr:pbyte;
            procedure update;
            function load_snapshot(data:pbyte):word;
            function save_snapshot(data:pbyte):word;
          private
  	        voice:array[0..OKIM6295_VOICES-1] of ADPCMVoice;
            command,bank_offs,out_:integer;
	          bank_installed:boolean;
            rom:pbyte;
            ntimer:byte;
            amp:single;
            procedure reset_adpcm(num_voice:byte);
            function clock_adpcm(num_voice,nibble:byte):integer;
            function generate_adpcm(num_voice:byte):integer;
            procedure stream_update;
      end;

procedure internal_update_oki6295_0;
procedure internal_update_oki6295_1;

var
    oki_6295_0,oki_6295_1:snd_okim6295;

implementation
const
  // step size index shift table */
  index_shift:array[0..7] of integer =(-1, -1, -1, -1, 2, 4, 6, 8 );
  // volume lookup table. The manual lists only 9 steps, ~3dB per step. Given the dB values,
  // that seems to map to a 5-bit volume control. Any volume parameter beyond the 9th index
  // results in silent playback.
  volume_table:array[0..15] of integer =(
	$20,	//   0 dB
	$16,	//  -3.2 dB
	$10,	//  -6.0 dB
	$0b,	//  -9.2 dB
	$08,	// -12.0 dB
	$06,	// -14.5 dB
	$04,	// -18.0 dB
	$03,	// -20.5 dB
	$02,	// -24.0 dB
	$00,
	$00,
	$00,
	$00,
	$00,
	$00,
	$00);

var
    //lookup table for the precomputed difference */
    diff_lookup:array[0..(49*16)-1] of single;
    chips_total:integer=-1;

procedure compute_tables;inline;
const
	// nibble to bit map */
	nbl2bit:array[0..15,0..3] of integer=(
		( 1, 0, 0, 0), ( 1, 0, 0, 1), ( 1, 0, 1, 0), ( 1, 0, 1, 1),
		( 1, 1, 0, 0), ( 1, 1, 0, 1), ( 1, 1, 1, 0), ( 1, 1, 1, 1),
		(-1, 0, 0, 0), (-1, 0, 0, 1), (-1, 0, 1, 0), (-1, 0, 1, 1),
		(-1, 1, 0, 0), (-1, 1, 0, 1), (-1, 1, 1, 0), (-1, 1, 1, 1));
var
	step,nib,stepval:integer;
begin
	// loop over all possible steps */
	for step:=0 to 48 do begin
		// compute the step value */
		stepval:= floor(16.0*power(11.0/10.0,step));
		// loop over all nibbles and compute the difference */
		for nib:=0 to 15 do begin
			diff_lookup[step*16 + nib]:=nbl2bit[nib][0]*(stepval*nbl2bit[nib][1]+
				 stepval/2*nbl2bit[nib][2]+
				 stepval/4*nbl2bit[nib][3]+
				 stepval/8);
		end;
  end;
end;

constructor snd_okim6295.Create(clock:dword;pin7:byte;amp:single=1);
begin
  chips_total:=chips_total+1;
  getmem(self.rom,$40000);
	compute_tables;
	self.bank_installed:=false;
  self.tsample_num:=init_channel;
  self.amp:=amp;
  self.clock:=clock;
  case chips_total of
      0:self.ntimer:=init_timer(sound_status.cpu_num,1,internal_update_oki6295_0,true);
      1:self.ntimer:=init_timer(sound_status.cpu_num,1,internal_update_oki6295_1,true);
  end;
  self.change_pin7(pin7);
	// initialize the voices */
  self.reset;
end;

destructor snd_okim6295.free;
begin
freemem(self.rom);
chips_total:=chips_total-1;
end;

function snd_okim6295.load_snapshot(data:pbyte):word;
var
  temp:pbyte;
  f:byte;
begin
temp:=data;
copymemory(@self.command,temp,4);inc(temp,4);
copymemory(@self.bank_offs,temp,4);inc(temp,4);
copymemory(@self.out_,temp,4);inc(temp,4);
copymemory(@self.bank_installed,temp,sizeof(boolean));inc(temp,sizeof(boolean));
copymemory(@self.ntimer,temp,1);inc(temp,1);
copymemory(@self.amp,temp,sizeof(single));inc(temp,sizeof(single));
for f :=0 to (OKIM6295_VOICES-1) do copymemory(@self.voice[f],temp,sizeof(ADPCMVoice));inc(temp,sizeof(ADPCMVoice));
end;

function snd_okim6295.save_snapshot(data:pbyte):word;
var
  temp:pbyte;
  size:word;
  f:byte;
begin
temp:=data;
copymemory(temp,@self.command,4);inc(temp,4);size:=4;
copymemory(temp,@self.bank_offs,4);inc(temp,4);size:=size+4;
copymemory(temp,@self.out_,4);inc(temp,4);size:=size+4;
copymemory(temp,@self.bank_installed,sizeof(boolean));inc(temp,sizeof(boolean));size:=size+sizeof(boolean);
copymemory(temp,@self.ntimer,1);inc(temp,1);size:=size+1;
copymemory(temp,@self.amp,sizeof(single));inc(temp,sizeof(single));size:=size+sizeof(single);
for f:=0 to (OKIM6295_VOICES-1) do copymemory(temp,@self.voice[f],sizeof(ADPCMVoice));inc(temp,sizeof(ADPCMVoice));size:=size+sizeof(ADPCMVoice);
save_snapshot:=size;
end;

function snd_okim6295.get_rom_addr:pbyte;
begin
  get_rom_addr:=self.rom;
end;

procedure snd_okim6295.reset_adpcm(num_voice:byte);
begin
	// reset the signal/step */
	self.voice[num_voice].adpcm.signal:=-2;
	self.voice[num_voice].adpcm.step:=0;
end;

function snd_okim6295.clock_adpcm(num_voice,nibble:byte):integer;
begin
	self.voice[num_voice].adpcm.signal:=self.voice[num_voice].adpcm.signal+round(diff_lookup[self.voice[num_voice].adpcm.step*16+(nibble and 15)]);
	// clamp to the maximum */
	if (self.voice[num_voice].adpcm.signal>2047) then self.voice[num_voice].adpcm.signal:=2047
	  else if (self.voice[num_voice].adpcm.signal<-2048) then self.voice[num_voice].adpcm.signal:=-2048;
	// adjust the step size and clamp */
	self.voice[num_voice].adpcm.step:=self.voice[num_voice].adpcm.step+index_shift[nibble and 7];
	if (self.voice[num_voice].adpcm.step>48) then self.voice[num_voice].adpcm.step:=48
	  else if (self.voice[num_voice].adpcm.step<0) then self.voice[num_voice].adpcm.step:=0;
	// return the signal */
	clock_adpcm:=self.voice[num_voice].adpcm.signal;
end;

function snd_okim6295.generate_adpcm(num_voice:byte):integer;
var
  nibble:byte;
  base,sample,count:integer;
  ptemp:pbyte;
begin
  base:=self.voice[num_voice].base_offset;
  sample:=self.voice[num_voice].sample;
  count:=self.voice[num_voice].count;
  // compute the new amplitude and update the current step */
  ptemp:=self.rom;
  inc(ptemp,base+(sample shr 1));
  nibble:=ptemp^;
  if (sample and 1)=0 then nibble:=nibble shr 4
    else nibble:=nibble and $f;//(((sample and 1) shl 2) xor 4);
  // next! */
  sample:=sample+1;
  if (sample>=count) then self.voice[num_voice].playing:=false;
  // update the parameters */
  self.voice[num_voice].sample:=sample;
  // output to the buffer, scaling by the volume */
  //signal in range -2048..2047, volume in range 2..32 => signal * volume / 2 in range -32768..32767 */
  generate_adpcm:=trunc(((self.clock_adpcm(num_voice,nibble)*(self.voice[num_voice].volume shr 1)))*self.amp);
end;

procedure snd_okim6295.reset;
var
  f:byte;
begin
  // initialize the voices */
  self.command:=-1;
  self.out_:=0;
  self.bank_offs:=0;
	for f:=0 to (OKIM6295_VOICES-1) do begin
		self.reset_adpcm(f);
    self.voice[f].playing:=false;
    self.voice[f].count:=0;
    self.voice[f].base_offset:=0;
    self.voice[f].sample:=0;
    self.voice[f].volume:=0;
	end;
end;

procedure snd_okim6295.change_pin7(pin7:byte);
var
  divisor:byte;
begin
  if pin7=OKIM6295_PIN7_HIGH then divisor:=132
    else divisor:=165;
  timer[self.ntimer].time_final:=sound_status.cpu_clock/(self.clock/divisor);
end;

function snd_okim6295.read:byte;
var
  f,res:byte;
begin
	res:=$f0;	// naname expects bits 4-7 to be 1 */
	// set the bit to 1 if something is playing on a given channel */
	for f:=0 to (OKIM6295_VOICES-1) do
    if self.voice[f].playing then res:=res or (1 shl f);
	read:=res;
end;

procedure snd_okim6295.write(valor:byte);
var
  base:word;
  start,stop:dword;
  ptemp:pbyte;
  temp,i:byte;
begin
	// if a command is pending, process the second half */
	if (self.command<>-1) then begin
		temp:=valor shr 4;
		// the manual explicitly says that it's not possible to start multiple voices at the same time */
		//if ((temp<>0) and (temp<>1) and (temp<>2) and (temp<>4) and (temp<>8)) then
		//	MessageDlg('OKI 6295 - Oppps! Inicia mas de un canal a la vez!', mtInformation,[mbOk], 0);
		// determine which voice(s) (voice is set by a 1 bit in the upper 4 bits of the second byte) */
		for i:=0 to (OKIM6295_VOICES-1) do begin
			if (temp and 1)<>0 then begin
				// determine the start/stop positions */
				base:=self.command*8;
        ptemp:=self.rom;
        inc(ptemp,base);
				start:=ptemp^ shl 16;
        inc(ptemp);
				start:=start+(ptemp^ shl 8);
        inc(ptemp);
				start:=(start+ptemp^) and $3ffff;
        inc(ptemp);
				stop:=ptemp^ shl 16;
        inc(ptemp);
				stop:=stop+(ptemp^ shl 8);
        inc(ptemp);
				stop:=(stop+ptemp^) and $3ffff;
				// set up the voice to play this sample */
				if (start<stop) then begin
					if not(self.voice[i].playing) then begin // fixes Got-cha and Steel Force */
						self.voice[i].playing:=true;
						self.voice[i].base_offset:=start;
						self.voice[i].sample:=0;
						self.voice[i].count:=2*(stop-start+1);
						// also reset the ADPCM parameters */
						self.reset_adpcm(i);
						self.voice[i].volume:=volume_table[valor and $0f];
					end	else begin
						//logerror("OKIM6295:'%s' requested to play sample %02x on non-stopped voice\n",device->tag(),info->command);
					end;
				end else begin 	// invalid samples go here */
					//logerror("OKIM6295:'%s' requested to play invalid sample %02x\n",device->tag(),info->command);
					self.voice[i].playing:=false;
				end;
			end;
      temp:=temp shr 1;
		end;  //del for
		// reset the command */
		self.command:=-1;
  end	else begin // if this is the start of a command, remember the sample number for next time */
    if (valor and $80)<>0 then begin
		      self.command:=valor and $7f;
    end else begin  // otherwise, see if this is a silence command */
                temp:=valor shr 3;
                //determine which voice(s) (voice is set by a 1 bit in bits 3-6 of the command */
                for i:=0 to (OKIM6295_VOICES-1) do begin
                  if (temp and 1)<>0 then self.voice[i].playing:=false;
                  temp:=temp shr 1;
                end;
          end;
  end;
end;

procedure snd_okim6295.stream_update;
var
  f:byte;
begin
  self.out_:=0;
	for f:=0 to (OKIM6295_VOICES-1) do
    if self.voice[f].playing then self.out_:=self.out_+self.generate_adpcm(f);
  if self.out_<-32767 then self.out_:=-32767
    else if self.out_>32767 then self.out_:=32767;
end;

procedure internal_update_oki6295_0;
begin
  oki_6295_0.stream_update;
end;

procedure internal_update_oki6295_1;
begin
  oki_6295_1.stream_update;
end;

procedure snd_okim6295.update;
begin
  tsample[self.tsample_num,sound_status.posicion_sonido]:=self.out_;
  if sound_status.stereo then tsample[self.tsample_num,sound_status.posicion_sonido+1]:=self.out_;
end;

end.
