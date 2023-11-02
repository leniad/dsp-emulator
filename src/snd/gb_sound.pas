unit gb_sound;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}sound_engine;

const
  MAX_FREQUENCIES=2048;

type
  tipo_sound=record
  	// Common
  	on_:boolean;
  	channel:byte;
  	length:word;
  	pos:dword;
  	period:dword;
  	count:integer;
  	mode:boolean;
  	// Mode 1, 2, 3
  	duty:shortint;
  	// Mode 1, 2, 4
  	env_value:integer;
    env_direction:shortint;
  	env_length:word;
  	env_count:integer;
  	signal:shortint;
  	// Mode 1
  	frequency:dword;
  	swp_shift:integer;
  	swp_direction:integer;
  	swp_time:word;
  	swp_count:integer;
  	// Mode 3
  	level:byte;
  	offset:byte;
  	dutycount:dword;
  	// Mode 4
  	ply_step:boolean;
  	ply_value:dword;
  end;
  tipo_soundc=record
	  on_:boolean;
  	vol_left:byte;
  	vol_right:byte;
  	mode_left:array[1..4] of boolean;
  	mode_right:array[1..4] of boolean;
  end;

  gb_sound_chip=class(snd_chip_class)
      constructor create;
      destructor free;
  public
    procedure reset;
    procedure update;
    function sound_r(offset:byte):byte;
    procedure sound_w(offset,valor:byte);
    function wave_r(offset:byte):byte;
    procedure wave_w(offset,valor:byte);
    function save_snapshot(datos:pbyte):word;
    procedure load_snapshot(datos:pbyte);
  private
    channel:array[1..4] of tipo_sound;
  	control:tipo_soundc;
    regs:array[0..$2f] of byte;
    procedure w_internal(offset,valor:byte);
  end;

var
  gb_snd_0:gb_sound_chip;

implementation
const
  NR10=$00;
  NR11=$01;
  NR12=$02;
  NR13=$03;
  NR14=$04;
  NR21=$06;
  NR22=$07;
  NR23=$08;
  NR24=$09;
  NR30=$0A;
  NR31=$0B;
  NR32=$0C;
  NR33=$0D;
  NR34=$0E;
  NR41=$10;
  NR42=$11;
  NR43=$12;
  NR44=$13;
  NR50=$14;
  NR51=$15;
  NR52=$16;
  AUD3W0=$20;
  AUD3W1=$21;
  AUD3W2=$22;
  AUD3W3=$23;
  AUD3W4=$24;
  AUD3W5=$25;
  AUD3W6=$26;
  AUD3W7=$27;
  AUD3W8=$28;
  AUD3W9=$29;
  AUD3WA=$2A;
  AUD3WB=$2B;
  AUD3WC=$2C;
  AUD3WD=$2D;
  AUD3WE=$2E;
  AUD3WF=$2F;
  // Represents wave duties of 12.5%, 25%, 50% and 75%
  wave_duty_table:array[0..3] of single=(8,4,2,1.33);

var
  env_length_table:array[0..7] of word;
  swp_time_table:array[0..7] of word;
  period_table:array[0..MAX_FREQUENCIES-1] of dword;
  period_mode3_table:array[0..MAX_FREQUENCIES-1] of dword;
  period_mode4_table:array[0..7,0..15] of dword;
  length_table:array[0..63] of word;
  length_mode3_table:array[0..$ff] of dword;

destructor gb_sound_chip.free;
begin
end;

constructor gb_sound_chip.create;
const
  FIXED_POINT=16;
var
  i,j:integer;
begin
	// Calculate the envelope and sweep tables
	for i:=0 to 7 do begin
		env_length_table[i]:=trunc((i*((1 shl FIXED_POINT)/64)*FREQ_BASE_AUDIO)) shr FIXED_POINT;
		swp_time_table[i]:=trunc((((i shl FIXED_POINT)/128)*FREQ_BASE_AUDIO)) shr (FIXED_POINT-1);
	end;
	// Calculate the period tables
	for i:=0 to (MAX_FREQUENCIES-1) do begin
		period_table[i]:=trunc(((1 shl FIXED_POINT)/(131072/(2048-i)))*FREQ_BASE_AUDIO);
		period_mode3_table[i]:=trunc(((1 shl FIXED_POINT)/(65536/(2048-i)))*FREQ_BASE_AUDIO);
	end;
	// Calculate the period table for mode 4
	for i:=0 to 7 do begin
		for j:=0 to 15 do begin
			// I is the dividing ratio of frequencies
      // J is the shift clock frequency
      if i=0 then period_mode4_table[i,j]:=trunc(((1 shl FIXED_POINT)/(524288/0.5/(1 shl (j+1))))*FREQ_BASE_AUDIO)
          else period_mode4_table[i,j]:=trunc(((1 shl FIXED_POINT)/(524288/i/(1 shl (j+1))))*FREQ_BASE_AUDIO);
		end;
	end;
	// Calculate the length table
	for i:=0 to 63 do begin
		length_table[i]:=trunc((64-i)*((1 shl FIXED_POINT)/256)*FREQ_BASE_AUDIO) shr FIXED_POINT;
	end;
	// Calculate the length table for mode 3
	for i:=0 to 255 do begin
		length_mode3_table[i]:=trunc((256-i)*((1 shl FIXED_POINT)/256)*FREQ_BASE_AUDIO) shr FIXED_POINT;
	end;
  self.tsample_num:=init_channel;
  self.reset;
end;

procedure gb_sound_chip.reset;
var
  f:byte;
begin
  for f:=0 to $2f do self.regs[f]:=0;
  self.w_internal(NR52,$00);
end;

function gb_sound_chip.save_snapshot(datos:pbyte):word;
var
  temp:pbyte;
  f:byte;
  size:dword;
begin
  temp:=datos;
  size:=0;
  for f:=1 to 4 do begin
    copymemory(temp,@self.channel[f],sizeof(tipo_sound));
    size:=size+sizeof(tipo_sound);
    inc(temp,sizeof(tipo_sound));
  end;
  copymemory(temp,@self.control,sizeof(tipo_soundc));
  size:=size+sizeof(tipo_soundc);
  inc(temp,sizeof(tipo_soundc));
  copymemory(temp,@self.regs,sizeof(self.regs));
  size:=size+sizeof(self.regs);
  save_snapshot:=size;
end;

procedure gb_sound_chip.load_snapshot(datos:pbyte);
var
  temp:pbyte;
  f:byte;
begin
  temp:=datos;
  for f:=1 to 4 do begin
    copymemory(@self.channel[f],temp,sizeof(tipo_sound));
    inc(temp,sizeof(tipo_sound));
  end;
  copymemory(@self.control,temp,sizeof(tipo_soundc));
  inc(temp,sizeof(tipo_soundc));
  copymemory(@self.regs,temp,sizeof(self.regs));
  inc(temp,sizeof(self.regs));
end;

function gb_sound_chip.wave_r(offset:byte):byte;
begin
	// TODO: properly emulate scrambling of wave ram area when playback is active
	wave_r:=self.regs[AUD3W0+offset] or byte(self.channel[3].on_);
end;

procedure gb_sound_chip.wave_w(offset,valor:byte);
begin
	self.regs[AUD3W0+offset]:=valor;
end;

function gb_sound_chip.sound_r(offset:byte):byte;
begin
	case offset of
  NR10:sound_r:=$80 or self.regs[offset];
  NR11:sound_r:=$3f or self.regs[offset];
  NR12:sound_r:=self.regs[offset];
  NR13:sound_r:=$ff;
  NR14:sound_r:=$bf or self.regs[offset];
  NR21:sound_r:=$3f or self.regs[offset];
  NR22:sound_r:=self.regs[offset];
  NR23:sound_r:=$ff;
  NR24:sound_r:=$bf or self.regs[offset];
  NR41:sound_r:=$ff;
  NR42:sound_r:=self.regs[offset];
  NR43:sound_r:=self.regs[offset];
  NR44:sound_r:=$bf or self.regs[offset];
  NR50:sound_r:=self.regs[offset];
  NR51:sound_r:=self.regs[offset];
	$05,$0a:sound_r:=$ff;
	NR52:sound_r:=$70 or self.regs[offset];
	 else sound_r:=self.regs[offset];
	end;
end;

procedure gb_sound_chip.sound_w(offset,valor:byte);
begin
	// Only register NR52 is accessible if the sound controller is disabled
	if (not(self.control.on_) and (offset<>NR52)) then exit;
	self.w_internal(offset,valor);
end;

procedure gb_sound_chip.w_internal(offset,valor:byte);
begin
	// Store the value
	self.regs[offset]:=valor;
	case offset of
	// MODE 1
	NR10:begin // Sweep (R/W)
		      self.channel[1].swp_shift:= valor and $7;
		      self.channel[1].swp_direction:=(valor and $8) shr 3;
		      self.channel[1].swp_direction:=self.channel[1].swp_direction or (self.channel[1].swp_direction-1);
		      self.channel[1].swp_time:=swp_time_table[(valor and $70) shr 4];
       end;
	NR11:begin // Sound length/Wave pattern duty (R/W)
      		self.channel[1].duty:=(valor and $C0) shr 6;
      		self.channel[1].length:=length_table[valor and $3f];
		   end;
	NR12:begin // Envelope (R/W)
      		self.channel[1].env_value:=valor shr 4;
      		self.channel[1].env_direction:=(valor and $8) shr 3;
      		self.channel[1].env_direction:=self.channel[1].env_direction or (self.channel[1].env_direction-1);
      		self.channel[1].env_length:=env_length_table[valor and $7];
		   end;
	NR13:begin // Frequency lo (R/W)
      		self.channel[1].frequency:=((self.regs[NR14] and $7) shl 8) or self.regs[NR13];
      		self.channel[1].period:=period_table[self.channel[1].frequency];
		   end;
	NR14:begin // Frequency hi / Initialize (R/W)
      		self.channel[1].mode:=(valor and $40)<>0;
      		self.channel[1].frequency:=((self.regs[NR14] and $7) shl 8) or self.regs[NR13];
      		self.channel[1].period:=period_table[self.channel[1].frequency];
      		if (valor and $80)<>0 then begin
      			if not(self.channel[1].on_) then	self.channel[1].pos:=0;
			      self.channel[1].on_:=true;
      			self.channel[1].count:=0;
      			self.channel[1].env_value:=self.regs[NR12] shr 4;
      			self.channel[1].env_count:=0;
      			self.channel[1].swp_count:=0;
      			self.channel[1].signal:=$1;
      			self.regs[NR52]:=self.regs[NR52] or $1;
      		end;
		    end;
	// MODE 2 */
	NR21:begin // Sound length/Wave pattern duty (R/W) */
		      self.channel[2].duty:=(valor and $C0) shr 6;
		      self.channel[2].length:=length_table[valor and $3f];
		   end;
	NR22:begin // Envelope (R/W)
      		self.channel[2].env_value:= valor shr 4;
      		self.channel[2].env_direction:= (valor and $8 ) shr 3;
      		self.channel[2].env_direction:=self.channel[2].env_direction or (self.channel[2].env_direction-1);
      		self.channel[2].env_length:=env_length_table[valor and $7];
		    end;
	NR23:begin // Frequency lo (R/W)
      		self.channel[2].period:=period_table[((self.regs[NR24] and $7) shl 8) or self.regs[NR23]];
       end;
	NR24:begin // Frequency hi / Initialize (R/W)
      		self.channel[2].mode:=(valor and $40)<>0;
      		self.channel[2].period:=period_table[((self.regs[NR24] and $7) shl 8) or self.regs[NR23]];
      		if (valor and $80)<>0 then begin
      			if not(self.channel[2].on_) then self.channel[2].pos:=0;
      			self.channel[2].on_:=true;
      			self.channel[2].count:=0;
      			self.channel[2].env_value:=self.regs[NR22] shr 4;
      			self.channel[2].env_count:=0;
      			self.channel[2].signal:=$1;
      			self.regs[NR52]:=self.regs[NR52] or $2;
		      end;
		   end;
	// MODE 3
	NR30:begin // Sound On/Off (R/W)
		      self.channel[3].on_:=(valor and $80)<>0;
		   end;
	NR31:begin // Sound Length (R/W)
		      self.channel[3].length:=length_mode3_table[valor];
		   end;
	NR32:begin // Select Output Level
		      self.channel[3].level:=(valor and $60) shr 5;
		   end;
	NR33:begin // Frequency lo (W)
		      self.channel[3].period:=period_mode3_table[((self.regs[NR34] and $7) shl 8) or self.regs[NR33]];
		   end;
	NR34:begin // Frequency hi / Initialize (W)
		      self.channel[3].mode:=(valor and $40)<>0;
		      self.channel[3].period:=period_mode3_table[((self.regs[NR34] and $7) shl 8) or self.regs[NR33]];
		      if (valor and $80)<>0 then begin
      			if not(self.channel[3].on_) then begin
      				self.channel[3].pos:=0;
      				self.channel[3].offset:=0;
      				self.channel[3].duty:=0;
            end;
    			  self.channel[3].on_:=true;
      			self.channel[3].count:=0;
      			self.channel[3].duty:=1;
      			self.channel[3].dutycount:=0;
      			self.regs[NR52]:=self.regs[NR52] or $4;
          end;
		   end;
	// MODE 4
	NR41:begin // Sound Length (R/W)
		      self.channel[4].length:=length_table[valor and $3f];
		   end;
	NR42:begin // Envelope (R/W)
		      self.channel[4].env_value:=valor shr 4;
      		self.channel[4].env_direction:=(valor and $8 ) shr 3;
      		self.channel[4].env_direction:=self.channel[4].env_direction or (self.channel[4].env_direction-1);
      		self.channel[4].env_length:=env_length_table[valor and $7];
       end;
	NR43:begin // Polynomial Counter/Frequency
      		self.channel[4].period:=period_mode4_table[valor and $7][(valor and $F0) shr 4];
      		self.channel[4].ply_step:=(valor and $8)<>0;
		   end;
	NR44:begin // Counter/Consecutive / Initialize (R/W)
		      self.channel[4].mode:=(valor and $40)<>0;
		      if (valor and $80)<>0 then begin
      			if not(self.channel[4].on_) then self.channel[4].pos:=0;
      			self.channel[4].on_:=true;
      			self.channel[4].count:=0;
      			self.channel[4].env_value:=self.regs[NR42] shr 4;
      			self.channel[4].env_count:=0;
      			self.channel[4].signal:=shortint(random(256));
      			self.channel[4].ply_value:=$7fff;
      			self.regs[NR52]:=self.regs[NR52] or $8;
		      end;
		   end;
	// CONTROL
	NR50:begin // Channel Control / On/Off / Volume (R/W)
      		self.control.vol_left:= valor and $7;
      		self.control.vol_right:= (valor and $70) shr 4;
		   end;
	NR51:begin // Selection of Sound Output Terminal
      		self.control.mode_right[1]:=(valor and $1)<>0;
      		self.control.mode_left[1]:=(valor and $10)<>0;
      		self.control.mode_right[2]:=(valor and $2)<>0;
      		self.control.mode_left[2]:=(valor and $20)<>0;
      		self.control.mode_right[3]:=(valor and $4)<>0;
      		self.control.mode_left[3]:=(valor and $40)<>0;
      		self.control.mode_right[4]:=(valor and $8)<>0;
      		self.control.mode_left[4]:=(valor and $80)<>0;
       end;
	NR52:begin // Sound On/Off (R/W)
		      // Only bit 7 is writable, writing to bits 0-3 does NOT enable or
          // disable sound.  They are read-only
      		self.control.on_:=(valor and $80)<>0;
      		if not(self.control.on_) then begin
      			self.w_internal(NR10,$80);
      			self.w_internal(NR11,$3f);
      			self.w_internal(NR12,$00);
      			self.w_internal(NR13,$fe);
      			self.w_internal(NR14,$bf);
      			self.w_internal(NR21,$3f);
      			self.w_internal(NR22,$00);
      			self.w_internal(NR23,$ff);
      			self.w_internal(NR24,$bf);
      			self.w_internal(NR30,$7f);
      			self.w_internal(NR31,$ff);
      			self.w_internal(NR32,$9f);
      			self.w_internal(NR33,$ff);
      			self.w_internal(NR34,$bf);
      			self.w_internal(NR41,$ff);
      			self.w_internal(NR42,$00);
      			self.w_internal(NR43,$00);
      			self.w_internal(NR44,$bf);
      			self.w_internal(NR50,$00);
      			self.w_internal(NR51,$00);
      			self.channel[1].on_:=false;
      			self.channel[2].on_:=false;
      			self.channel[3].on_:=false;
      			self.channel[4].on_:=false;
      			self.regs[offset]:=0;
          end;
		   end;
  end;
end;

procedure gb_sound_chip.update;
var
  left,right,sample,mode4_mask:integer;
begin
		left:=0;
    right:=0;
		// Mode 1 - Wave with Envelope and Sweep
		if self.channel[1].on_ then begin
			sample:=self.channel[1].signal*self.channel[1].env_value;
			self.channel[1].pos:=self.channel[1].pos+1;
			if (self.channel[1].pos=(trunc(self.channel[1].period/wave_duty_table[self.channel[1].duty]) shr 16)) then begin
				self.channel[1].signal:=-self.channel[1].signal;
			end else if (self.channel[1].pos>(self.channel[1].period shr 16)) then begin
				self.channel[1].pos:=0;
				self.channel[1].signal:=-self.channel[1].signal;
			end;
			if ((self.channel[1].length<>0) and self.channel[1].mode) then begin
				self.channel[1].count:=self.channel[1].count+1;
				if (self.channel[1].count>=self.channel[1].length) then begin
					self.channel[1].on_:=false;
					self.regs[NR52]:=self.regs[NR52] and $FE;
				end;
			end;
			if (self.channel[1].env_length<>0) then begin
				self.channel[1].env_count:=self.channel[1].env_count+1;
				if (self.channel[1].env_count>=self.channel[1].env_length) then begin
					self.channel[1].env_count:= 0;
					self.channel[1].env_value:=self.channel[1].env_value+self.channel[1].env_direction;
					if (self.channel[1].env_value<0) then self.channel[1].env_value:=0;
					if (self.channel[1].env_value>15) then self.channel[1].env_value:=15;
				end;
			end;
			if (self.channel[1].swp_time<>0) then begin
				self.channel[1].swp_count:=self.channel[1].swp_count+1;
				if (self.channel[1].swp_count>=self.channel[1].swp_time) then begin
					self.channel[1].swp_count:=0;
					if (self.channel[1].swp_direction>0) then begin
						self.channel[1].frequency:=self.channel[1].frequency-(self.channel[1].frequency div (1 shl self.channel[1].swp_shift));
						if (self.channel[1].frequency<=0) then begin
							self.channel[1].on_:=false;
							self.regs[NR52]:=self.regs[NR52] and $FE;
						end;
					end else begin
						self.channel[1].frequency:=self.channel[1].frequency+(self.channel[1].frequency div (1 shl self.channel[1].swp_shift));
						if (self.channel[1].frequency>=MAX_FREQUENCIES) then begin
							self.channel[1].frequency:= MAX_FREQUENCIES-1;
						end;
					end;
					self.channel[1].period:=period_table[self.channel[1].frequency];
				end;
			end;

			if self.control.mode_left[1] then left:=left+sample;
			if self.control.mode_right[1] then right:=right+sample;
		end; // del on1

		// Mode 2 - Wave with Envelope */
		if self.channel[2].on_ then begin
			sample:=self.channel[2].signal*self.channel[2].env_value;
			self.channel[2].pos:=self.channel[2].pos+1;
			if (self.channel[2].pos=(trunc(self.channel[2].period/wave_duty_table[self.channel[2].duty]) shr 16)) then begin
				self.channel[2].signal:=-self.channel[2].signal;
			end	else if( self.channel[2].pos>(self.channel[2].period shr 16)) then begin
				self.channel[2].pos:=0;
				self.channel[2].signal:=-self.channel[2].signal;
			end;

			if ((self.channel[2].length<>0) and self.channel[2].mode) then begin
				self.channel[2].count:=self.channel[2].count+1;
				if (self.channel[2].count>=self.channel[2].length) then begin
					self.channel[2].on_:=false;
					self.regs[NR52]:=self.regs[NR52] and $FD;
				end;
			end;

			if (self.channel[2].env_length<>0) then begin
				self.channel[2].env_count:=self.channel[2].env_count+1;
				if (self.channel[2].env_count>=self.channel[2].env_length) then begin
					self.channel[2].env_count:=0;
					self.channel[2].env_value:=self.channel[2].env_value+self.channel[2].env_direction;
					if (self.channel[2].env_value<0) then self.channel[2].env_value:=0;
					if (self.channel[2].env_value>15) then self.channel[2].env_value:=15;
				end;
			end;
			if self.control.mode_left[2] then left:=left+sample;
			if self.control.mode_right[2] then right:=right+sample;
		end;

		// Mode 3 - Wave patterns from WaveRAM */
		if self.channel[3].on_ then begin
			// NOTE: This is extremely close, but not quite right.
      //       The problem is for GB frequencies above 2000 the frequency gets
      //       clipped. This is caused because self.channel[3].pos is never 0 at the test.
			sample:=self.regs[AUD3W0+(self.channel[3].offset div 2)];
			if ((self.channel[3].offset mod 2)=0) then sample:=sample shr 4;
			sample:=(sample and $f)-8;
			if (self.channel[3].level<>0) then sample:=sample shr (self.channel[3].level-1)
  			else sample:=0;
			self.channel[3].pos:=self.channel[3].pos+1;
			if (self.channel[3].pos>=(dword(self.channel[3].period shr 21)+self.channel[3].duty)) then begin
				self.channel[3].pos:=0;
				if (self.channel[3].dutycount=(dword(self.channel[3].period shr 16) mod 32)) then begin
					self.channel[3].duty:=self.channel[3].duty-1;
				end;
				self.channel[3].dutycount:=self.channel[3].dutycount+1;
				self.channel[3].offset:=self.channel[3].offset+1;
				if (self.channel[3].offset>31) then begin
					self.channel[3].offset:=0;
					self.channel[3].duty:=1;
					self.channel[3].dutycount:=0;
				end;
			end;
			if ((self.channel[3].length<>0) and self.channel[3].mode) then begin
				self.channel[3].count:=self.channel[3].count+1;
				if (self.channel[3].count>=self.channel[3].length ) then begin
					self.channel[3].on_:=false;
					self.regs[NR52]:=self.regs[NR52] and $fb;
				end;
			end;
			if self.control.mode_left[3] then left:=left+sample;
			if self.control.mode_right[3] then right:=right+sample;
		end;

		// Mode 4 - Noise with Envelope */
		if self.channel[4].on_ then begin
			// Similar problem to Mode 3, we seem to miss some notes */
			sample:=self.channel[4].signal and self.channel[4].env_value;
			self.channel[4].pos:=self.channel[4].pos+1;
			if (self.channel[4].pos=(self.channel[4].period shr 17)) then begin
				// Using a Polynomial Counter (aka Linear Feedback Shift Register)
        //         Mode 4 has a 7 bit and 15 bit counter so we need to shift the
        //         bits around accordingly
        if self.channel[4].ply_step then mode4_mask:=(((self.channel[4].ply_value and $2) div 2) xor (self.channel[4].ply_value and $1)) shl 6
          else mode4_mask:=(((self.channel[4].ply_value and $2) div 2) xor (self.channel[4].ply_value and $1)) shl 14;

				self.channel[4].ply_value:=self.channel[4].ply_value div 2;
				self.channel[4].ply_value:=self.channel[4].ply_value or mode4_mask;
        if self.channel[4].ply_step then self.channel[4].ply_value:=self.channel[4].ply_value and $7f
         else self.channel[4].ply_value:=self.channel[4].ply_value and $7fff;
				self.channel[4].signal:=shortint(self.channel[4].ply_value);
			end else if (self.channel[4].pos>(self.channel[4].period shr 16)) then begin
				self.channel[4].pos:=0;
        if self.channel[4].ply_step then mode4_mask:=(((self.channel[4].ply_value and $2) div 2) xor (self.channel[4].ply_value and $1)) shl 6
          else mode4_mask:=(((self.channel[4].ply_value and $2) div 2) xor (self.channel[4].ply_value and $1)) shl 14;
				self.channel[4].ply_value:=self.channel[4].ply_value div 2;
				self.channel[4].ply_value:=self.channel[4].ply_value or mode4_mask;
        if self.channel[4].ply_step then self.channel[4].ply_value:=self.channel[4].ply_value and $7f
          else self.channel[4].ply_value:=self.channel[4].ply_value and $7fff;
				self.channel[4].signal:=shortint(self.channel[4].ply_value);
			end;
			if ((self.channel[4].length<>0) and self.channel[4].mode) then begin
				self.channel[4].count:=self.channel[4].count+1;
				if (self.channel[4].count>=self.channel[4].length) then begin
					self.channel[4].on_:=false;
					self.regs[NR52]:=self.regs[NR52] and $f7;
				end;
			end;
			if (self.channel[4].env_length<>0) then begin
				self.channel[4].env_count:=self.channel[4].env_count+1;
				if (self.channel[4].env_count>=self.channel[4].env_length) then begin
					self.channel[4].env_count:=0;
					self.channel[4].env_value:=self.channel[4].env_value+self.channel[4].env_direction;
					if (self.channel[4].env_value<0) then self.channel[4].env_value:=0;
					if (self.channel[4].env_value>15) then self.channel[4].env_value:=15;
				end;
			end;
			if self.control.mode_left[4] then left:=left+sample;
			if self.control.mode_right[4] then right:=right+sample;
		end;
		// Adjust for master volume
		left:=left*self.control.vol_left;
		right:=right*self.control.vol_right;
		// pump up the volume
		left:=left shl 6;
		right:=right shl 6;
		// Update the buffers
    tsample[self.tsample_num,sound_status.posicion_sonido]:=left;
    tsample[self.tsample_num,sound_status.posicion_sonido+1]:=right;
	  self.regs[NR52]:=(self.regs[NR52] and $f0) or byte(self.channel[1].on_) or (byte(self.channel[2].on_) shl 1) or (byte(self.channel[3].on_) shl 2) or (byte(self.channel[4].on_) shl 3);
end;

end.
