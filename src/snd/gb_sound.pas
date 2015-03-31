unit gb_sound;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}sound_engine;

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

  LEFT=1;
  RIGHT=2;
  MAX_FREQUENCIES=2048;
  FIXED_POINT=16;

  // Represents wave duties of 12.5%, 25%, 50% and 75% */
  wave_duty_table:array[0..3] of single=(8.0,4.0,2.0,1.33);

type

  tipo_SOUND=record
  	// Common */
  	on_:byte;
  	channel:byte;
  	length:integer;
  	pos:integer;
  	period:dword;
  	count:integer;
  	mode:shortint;
  	// Mode 1, 2, 3 */
  	duty:shortint;
  	// Mode 1, 2, 4 */
  	env_value:integer;
    env_direction:shortint;
  	env_length:integer;
  	env_count:integer;
  	signal:shortint;
  	// Mode 1 */
  	frequency:dword;
  	swp_shift:integer;
  	swp_direction:integer;
  	swp_time:integer;
  	swp_count:integer;
  	// Mode 3 */
  	level:shortint;
  	offset:byte;
  	dutycount:dword;
  	// Mode 4 */
  	ply_step:integer;
  	ply_value:smallint;
  end;
  tipo_SOUNDC=record
	  on_:byte;
  	vol_left:byte;
  	vol_right:byte;
  	mode1_left:byte;
  	mode1_right:byte;
  	mode2_left:byte;
  	mode2_right:byte;
  	mode3_left:byte;
  	mode3_right:byte;
  	mode4_left:byte;
  	mode4_right:byte;
  end;
  gb_sound_tipo=record
	  rate:integer;
  	env_length_table:array[0..7] of integer;
  	swp_time_table:array[0..7] of integer;
  	period_table:array[0..MAX_FREQUENCIES-1] of dword;
  	period_mode3_table:array[0..MAX_FREQUENCIES-1] of dword;
  	period_mode4_table:array[0..7,0..15] of dword;
  	length_table:array[0..63] of dword;
  	length_mode3_table:array[0..$ff] of dword;
	  snd_1:tipo_sound;
  	snd_2:tipo_sound;
  	snd_3:tipo_sound;
  	snd_4:tipo_sound;
  	snd_control:tipo_soundc;
	  snd_regs:array[0..$30-1] of byte;
    tsample:byte;
  end;
  pgb_sound_tipo=^gb_sound_tipo;

var
  gb_snd:pgb_sound_tipo;

function gb_sound_r(offset:byte):byte;
procedure gb_sound_w(offset,valor:byte);
function gb_wave_r(offset:byte):byte;
procedure gb_wave_w(offset,valor:byte);
procedure gameboy_sound_ini(sample_rate:integer);
procedure gameboy_sound_close;
procedure gameboy_sound_reset;
procedure gameboy_sound_update;

implementation

function gb_wave_r(offset:byte):byte;
begin
	// TODO: properly emulate scrambling of wave ram area when playback is active */
	gb_wave_r:=gb_snd.snd_regs[AUD3W0+offset] or gb_snd.snd_3.on_;
end;

procedure gb_wave_w(offset,valor:byte);
begin
	gb_snd.snd_regs[AUD3W0+offset]:=valor;
end;

function gb_sound_r(offset:byte):byte;
begin
	case offset of
  NR10:gb_sound_r:=$80 or gb_snd.snd_regs[offset];
  NR11:gb_sound_r:=$3F or gb_snd.snd_regs[offset];
  NR12:gb_sound_r:=gb_snd.snd_regs[offset];
  NR13:gb_sound_r:=$FF;
  NR14:gb_sound_r:=$BF or gb_snd.snd_regs[offset];
  NR21:gb_sound_r:=$3f or gb_snd.snd_regs[offset];
  NR22:gb_sound_r:=gb_snd.snd_regs[offset];
  NR23:gb_sound_r:=$ff;
  NR24:gb_sound_r:=$bf or gb_snd.snd_regs[offset];
  NR41:gb_sound_r:=$FF;
  NR42:gb_sound_r:=gb_snd.snd_regs[offset];
  NR43:gb_sound_r:=gb_snd.snd_regs[offset];
  NR44:gb_sound_r:=$BF or gb_snd.snd_regs[offset];
  NR50:gb_sound_r:=gb_snd.snd_regs[offset];
  NR51:gb_sound_r:=gb_snd.snd_regs[offset];
	$05,$0a:gb_sound_r:=$FF;
	NR52:gb_sound_r:=$70 or gb_snd.snd_regs[offset];
	 else gb_sound_r:=gb_snd.snd_regs[offset];
	end;
end;

procedure gb_sound_w_internal(offset,valor:byte);
begin
	// Store the value */
	gb_snd.snd_regs[offset]:=valor;
	case offset of
	// MODE 1 */
	NR10:begin // Sweep (R/W)
		      gb_snd.snd_1.swp_shift:= valor and $7;
		      gb_snd.snd_1.swp_direction:=(valor and $8) shr 3;
		      gb_snd.snd_1.swp_direction:=gb_snd.snd_1.swp_direction or (gb_snd.snd_1.swp_direction-1);
		      gb_snd.snd_1.swp_time:= gb_snd.swp_time_table[(valor and $70) shr 4];
       end;
	NR11:begin // Sound length/Wave pattern duty (R/W) */
      		gb_snd.snd_1.duty:=(valor and $C0) shr 6;
      		gb_snd.snd_1.length:=gb_snd.length_table[valor and $3F];
		   end;
	NR12:begin // Envelope (R/W) */
      		gb_snd.snd_1.env_value:=valor shr 4;
      		gb_snd.snd_1.env_direction:=(valor and $8) shr 3;
      		gb_snd.snd_1.env_direction:=gb_snd.snd_1.env_direction or (gb_snd.snd_1.env_direction-1);
      		gb_snd.snd_1.env_length:=gb_snd.env_length_table[valor and $7];
		   end;
	NR13:begin // Frequency lo (R/W) */
      		gb_snd.snd_1.frequency:=((gb_snd.snd_regs[NR14] and $7) shl 8) or gb_snd.snd_regs[NR13];
      		gb_snd.snd_1.period:=gb_snd.period_table[gb_snd.snd_1.frequency];
		   end;
	NR14:begin // Frequency hi / Initialize (R/W) */
      		gb_snd.snd_1.mode:= (valor and $40) shr 6;
      		gb_snd.snd_1.frequency:= ((gb_snd.snd_regs[NR14] and $7) shl 8) or gb_snd.snd_regs[NR13];
      		gb_snd.snd_1.period:= gb_snd.period_table[gb_snd.snd_1.frequency];
      		if (valor and $80)<>0 then begin
      			if (gb_snd.snd_1.on_=0) then	gb_snd.snd_1.pos:=0;
			      gb_snd.snd_1.on_:=1;
      			gb_snd.snd_1.count:=0;
      			gb_snd.snd_1.env_value:=gb_snd.snd_regs[NR12] shr 4;
      			gb_snd.snd_1.env_count:=0;
      			gb_snd.snd_1.swp_count:=0;
      			gb_snd.snd_1.signal:=$1;
      			gb_snd.snd_regs[NR52]:=gb_snd.snd_regs[NR52] or $1;
      		end;
		    end;
	// MODE 2 */
	NR21:begin // Sound length/Wave pattern duty (R/W) */
		      gb_snd.snd_2.duty:=(valor and $C0) shr 6;
		      gb_snd.snd_2.length:= gb_snd.length_table[valor and $3F];
		   end;
	NR22:begin // Envelope (R/W)
      		gb_snd.snd_2.env_value:= valor shr 4;
      		gb_snd.snd_2.env_direction:= (valor and $8 ) shr 3;
      		gb_snd.snd_2.env_direction:=gb_snd.snd_2.env_direction or (gb_snd.snd_2.env_direction-1);
      		gb_snd.snd_2.env_length:=gb_snd.env_length_table[valor and $7];
		    end;
	NR23:begin // Frequency lo (R/W) */
      		gb_snd.snd_2.period:=gb_snd.period_table[((gb_snd.snd_regs[NR24] and $7) shl 8) or gb_snd.snd_regs[NR23]];
       end;
	NR24:begin // Frequency hi / Initialize (R/W) */
      		gb_snd.snd_2.mode:=(valor and $40) shr 6;
      		gb_snd.snd_2.period:=gb_snd.period_table[((gb_snd.snd_regs[NR24] and $7) shl 8) or gb_snd.snd_regs[NR23]];
      		if (valor and $80)<>0 then begin
      			if (gb_snd.snd_2.on_=0) then gb_snd.snd_2.pos:=0;
      			gb_snd.snd_2.on_:=1;
      			gb_snd.snd_2.count:=0;
      			gb_snd.snd_2.env_value:=gb_snd.snd_regs[NR22] shr 4;
      			gb_snd.snd_2.env_count:=0;
      			gb_snd.snd_2.signal:=$1;
      			gb_snd.snd_regs[NR52]:=gb_snd.snd_regs[NR52] or $2;
		      end;
		   end;
	// MODE 3 */
	NR30:begin // Sound On/Off (R/W) */
		      gb_snd.snd_3.on_:= (valor and $80) shr 7;
		   end;
	NR31:begin // Sound Length (R/W) */
		      gb_snd.snd_3.length:= gb_snd.length_mode3_table[valor];
		   end;
	NR32:begin // Select Output Level */
		      gb_snd.snd_3.level:= (valor and $60) shr 5;
		   end;
	NR33:begin // Frequency lo (W) */
		      gb_snd.snd_3.period:= gb_snd.period_mode3_table[((gb_snd.snd_regs[NR34] and $7) shl 8) or gb_snd.snd_regs[NR33]];
		   end;
	NR34:begin // Frequency hi / Initialize (W) */
		      gb_snd.snd_3.mode:= (valor and $40) shr 6;
		      gb_snd.snd_3.period:= gb_snd.period_mode3_table[((gb_snd.snd_regs[NR34] and $7) shl 8) or gb_snd.snd_regs[NR33]];
		      if (valor and $80)<>0 then begin
      			if (gb_snd.snd_3.on_=0) then begin
      				gb_snd.snd_3.pos:=0;
      				gb_snd.snd_3.offset:=0;
      				gb_snd.snd_3.duty:=0;
            end;
    			  gb_snd.snd_3.on_:=1;
      			gb_snd.snd_3.count:=0;
      			gb_snd.snd_3.duty:=1;
      			gb_snd.snd_3.dutycount:=0;
      			gb_snd.snd_regs[NR52]:=gb_snd.snd_regs[NR52] or $4;
          end;
		   end;
	// MODE 4 */
	NR41:begin // Sound Length (R/W) */
		      gb_snd.snd_4.length:=gb_snd.length_table[valor and $3F];
		   end;
	NR42:begin // Envelope (R/W) */
		      gb_snd.snd_4.env_value:=valor shr 4;
      		gb_snd.snd_4.env_direction:=(valor and $8 ) shr 3;
      		gb_snd.snd_4.env_direction:=gb_snd.snd_4.env_direction or (gb_snd.snd_4.env_direction-1);
      		gb_snd.snd_4.env_length:=gb_snd.env_length_table[valor and $7];
       end;
	NR43:begin // Polynomial Counter/Frequency */
      		gb_snd.snd_4.period:=gb_snd.period_mode4_table[valor and $7][(valor and $F0) shr 4];
      		gb_snd.snd_4.ply_step:= (valor and $8) shr 3;
		   end;
	NR44:begin // Counter/Consecutive / Initialize (R/W)  */
		      gb_snd.snd_4.mode:= (valor and $40) shr 6;
		      if (valor and $80)<>0 then begin
      			if (gb_snd.snd_4.on_=0) then gb_snd.snd_4.pos:=0;
      			gb_snd.snd_4.on_:=1;
      			gb_snd.snd_4.count:=0;
      			gb_snd.snd_4.env_value:=gb_snd.snd_regs[NR42] shr 4;
      			gb_snd.snd_4.env_count:=0;
      			gb_snd.snd_4.signal:=shortint(random(256));
      			gb_snd.snd_4.ply_value:=$7fff;
      			gb_snd.snd_regs[NR52]:=gb_snd.snd_regs[NR52] or $8;
		      end;
		   end;
	// CONTROL */
	NR50:begin // Channel Control / On/Off / Volume (R/W)  */
      		gb_snd.snd_control.vol_left:= valor and $7;
      		gb_snd.snd_control.vol_right:= (valor and $70) shr 4;
		   end;
	NR51:begin // Selection of Sound Output Terminal */
      		gb_snd.snd_control.mode1_right:= valor and $1;
      		gb_snd.snd_control.mode1_left:= (valor and $10) shr 4;
      		gb_snd.snd_control.mode2_right:= (valor and $2) shr 1;
      		gb_snd.snd_control.mode2_left:= (valor and $20) shr 5;
      		gb_snd.snd_control.mode3_right:= (valor and $4) shr 2;
      		gb_snd.snd_control.mode3_left:= (valor and $40) shr 6;
      		gb_snd.snd_control.mode4_right:= (valor and $8) shr 3;
      		gb_snd.snd_control.mode4_left:= (valor and $80) shr 7;
       end;
	NR52:begin // Sound On/Off (R/W) */
		      // Only bit 7 is writable, writing to bits 0-3 does NOT enable or
          // disable sound.  They are read-only
      		gb_snd.snd_control.on_:= (valor and $80) shr 7;
      		if (gb_snd.snd_control.on_=0) then begin
      			gb_sound_w_internal(NR10,$80);
      			gb_sound_w_internal(NR11,$3F);
      			gb_sound_w_internal(NR12,$00);
      			gb_sound_w_internal(NR13,$FE);
      			gb_sound_w_internal(NR14,$BF);
      			gb_sound_w_internal(NR21,$3F);
      			gb_sound_w_internal(NR22,$00);
      			gb_sound_w_internal(NR23,$FF);
      			gb_sound_w_internal(NR24,$BF);
      			gb_sound_w_internal(NR30,$7F);
      			gb_sound_w_internal(NR31,$FF);
      			gb_sound_w_internal(NR32,$9F);
      			gb_sound_w_internal(NR33,$FF);
      			gb_sound_w_internal(NR34,$BF);
      			gb_sound_w_internal(NR41,$FF);
      			gb_sound_w_internal(NR42,$00);
      			gb_sound_w_internal(NR43,$00);
      			gb_sound_w_internal(NR44,$BF);
      			gb_sound_w_internal(NR50,$00);
      			gb_sound_w_internal(NR51,$00);
      			gb_snd.snd_1.on_:=0;
      			gb_snd.snd_2.on_:=0;
      			gb_snd.snd_3.on_:=0;
      			gb_snd.snd_4.on_:=0;
      			gb_snd.snd_regs[offset]:=0;
          end;
		   end;
  end;
end;

procedure gb_sound_w(offset,valor:byte);
begin
	// Only register NR52 is accessible if the sound controller is disabled
	if ((gb_snd.snd_control.on_=0) and (offset<>NR52)) then exit;
	gb_sound_w_internal(offset,valor);
end;

procedure gameboy_sound_close;
begin
if gb_snd<>nil then begin
  freemem(gb_snd);
  gb_snd:=nil;
end;
end;

procedure gameboy_sound_ini(sample_rate:integer);
var
  I, J:integer;
begin
  getmem(gb_snd,sizeof(gb_sound_tipo));
	gb_snd.rate:=sample_rate;
	// Calculate the envelope and sweep tables */
	for i:=0 to 7 do begin
		gb_snd.env_length_table[i]:=trunc((i* ((1*$10000)/64) * gb_snd.rate)) div $10000;
		gb_snd.swp_time_table[i]:=trunc((((i*$10000) / 128) * gb_snd.rate)) div $8000;
	end;
	// Calculate the period tables */
	for i:=0 to (MAX_FREQUENCIES-1) do begin
		gb_snd.period_table[i]:=trunc(((1*$10000) / (131072 / (2048 - i))) * gb_snd.rate);
		gb_snd.period_mode3_table[i]:=trunc(((1*$10000) / (65536 / (2048 - i))) * gb_snd.rate);
	end;
	// Calculate the period table for mode 4 */
	for i:=0 to 7 do begin
		for j:=0 to 15 do begin
			// I is the dividing ratio of frequencies
      // J is the shift clock frequency
      if i=0 then gb_snd.period_mode4_table[i,j]:=trunc(((1*$10000) / (524288 / 0.5 / (1 shl (j + 1)))) * gb_snd.rate)
          else gb_snd.period_mode4_table[i,j]:=trunc(((1*$10000) / (524288 / i / (1 shl (j + 1)))) * gb_snd.rate);
		end;
	end;
	// Calculate the length table */
	for i:=0 to 63 do begin
		gb_snd.length_table[i]:=trunc((64 - i)*((1 shl FIXED_POINT)/256) * gb_snd.rate) div $10000;
	end;
	// Calculate the length table for mode 3 */
	for i:=0 to 255 do begin
		gb_snd.length_mode3_table[i]:=trunc((256 - i) * ((1 shl FIXED_POINT)/256) * gb_snd.rate) div $10000;
	end;
	gameboy_sound_reset;
  gb_snd.tsample:=init_channel;
end;

procedure gameboy_sound_reset;
var
  f:byte;
begin
  for f:=0 to $2f do gb_snd.snd_regs[f]:=0;
  gb_sound_w_internal(NR52,$00);
end;

function sshr(num:integer;fac:byte):integer;
begin
  if num<0 then sshr:=-(abs(num) shr fac)
    else sshr:=num shr fac;
end;

procedure gameboy_sound_update;
var
  left,right,sample,mode4_mask:integer;
  //	stream_sample_t sample, left, right, mode4_mask;
begin
		left:=0;
    right:=0;
		// Mode 1 - Wave with Envelope and Sweep */
		if (gb_snd.snd_1.on_<>0) then begin
			sample:= gb_snd.snd_1.signal*gb_snd.snd_1.env_value;
			gb_snd.snd_1.pos:=gb_snd.snd_1.pos+1;
			if (gb_snd.snd_1.pos=(trunc(gb_snd.snd_1.period/wave_duty_table[gb_snd.snd_1.duty]) shr 16)) then begin
				gb_snd.snd_1.signal:=-gb_snd.snd_1.signal;
			end else if (gb_snd.snd_1.pos>(gb_snd.snd_1.period shr 16)) then begin
				gb_snd.snd_1.pos:=0;
				gb_snd.snd_1.signal:=-gb_snd.snd_1.signal;
			end;
			if ((gb_snd.snd_1.length<>0) and (gb_snd.snd_1.mode<>0)) then begin
				gb_snd.snd_1.count:=gb_snd.snd_1.count+1;
				if (gb_snd.snd_1.count>=gb_snd.snd_1.length) then begin
					gb_snd.snd_1.on_:=0;
					gb_snd.snd_regs[NR52]:=gb_snd.snd_regs[NR52] and $FE;
				end;
			end;
			if (gb_snd.snd_1.env_length<>0) then begin
				gb_snd.snd_1.env_count:=gb_snd.snd_1.env_count+1;
				if (gb_snd.snd_1.env_count>=gb_snd.snd_1.env_length) then begin
					gb_snd.snd_1.env_count:= 0;
					gb_snd.snd_1.env_value:=gb_snd.snd_1.env_value+gb_snd.snd_1.env_direction;
					if (gb_snd.snd_1.env_value<0) then gb_snd.snd_1.env_value:=0;
					if (gb_snd.snd_1.env_value>15) then gb_snd.snd_1.env_value:=15;
				end;
			end;
			if (gb_snd.snd_1.swp_time<>0) then begin
				gb_snd.snd_1.swp_count:=gb_snd.snd_1.swp_count+1;
				if (gb_snd.snd_1.swp_count>=gb_snd.snd_1.swp_time) then begin
					gb_snd.snd_1.swp_count:=0;
					if (gb_snd.snd_1.swp_direction>0) then begin
						gb_snd.snd_1.frequency:=gb_snd.snd_1.frequency-(gb_snd.snd_1.frequency div (1 shl gb_snd.snd_1.swp_shift));
						if (gb_snd.snd_1.frequency<=0) then begin
							gb_snd.snd_1.on_:=0;
							gb_snd.snd_regs[NR52]:=gb_snd.snd_regs[NR52] and $FE;
						end;
					end else begin
						gb_snd.snd_1.frequency:=gb_snd.snd_1.frequency+(gb_snd.snd_1.frequency div (1 shl gb_snd.snd_1.swp_shift));
						if (gb_snd.snd_1.frequency>=MAX_FREQUENCIES) then begin
							gb_snd.snd_1.frequency:= MAX_FREQUENCIES-1;
						end;
					end;
					gb_snd.snd_1.period:= gb_snd.period_table[gb_snd.snd_1.frequency];
				end;
			end;

			if (gb_snd.snd_control.mode1_left<>0) then left:=left+sample;
			if (gb_snd.snd_control.mode1_right<>0) then right:=right+sample;
		end; // del on1

		// Mode 2 - Wave with Envelope */
		if (gb_snd.snd_2.on_<>0) then begin
			sample:=gb_snd.snd_2.signal*gb_snd.snd_2.env_value;
			gb_snd.snd_2.pos:=gb_snd.snd_2.pos+1;
			if (gb_snd.snd_2.pos=(trunc(gb_snd.snd_2.period/wave_duty_table[gb_snd.snd_2.duty]) shr 16)) then begin
				gb_snd.snd_2.signal:=-gb_snd.snd_2.signal;
			end	else if( gb_snd.snd_2.pos>(gb_snd.snd_2.period shr 16)) then begin
				gb_snd.snd_2.pos:=0;
				gb_snd.snd_2.signal:=-gb_snd.snd_2.signal;
			end;

			if ((gb_snd.snd_2.length<>0) and (gb_snd.snd_2.mode<>0)) then begin
				gb_snd.snd_2.count:=gb_snd.snd_2.count+1;
				if (gb_snd.snd_2.count>=gb_snd.snd_2.length) then begin
					gb_snd.snd_2.on_:=0;
					gb_snd.snd_regs[NR52]:=gb_snd.snd_regs[NR52] and $FD;
				end;
			end;

			if (gb_snd.snd_2.env_length<>0) then begin
				gb_snd.snd_2.env_count:=gb_snd.snd_2.env_count+1;
				if (gb_snd.snd_2.env_count>=gb_snd.snd_2.env_length) then begin
					gb_snd.snd_2.env_count:=0;
					gb_snd.snd_2.env_value:=gb_snd.snd_2.env_value+gb_snd.snd_2.env_direction;
					if (gb_snd.snd_2.env_value<0) then gb_snd.snd_2.env_value:=0;
					if (gb_snd.snd_2.env_value>15) then gb_snd.snd_2.env_value:=15;
				end;
			end;
			if (gb_snd.snd_control.mode2_left<>0) then left:=left+sample;
			if (gb_snd.snd_control.mode2_right<>0) then right:=right+sample;
		end;

		// Mode 3 - Wave patterns from WaveRAM */
		if (gb_snd.snd_3.on_<>0) then begin
			// NOTE: This is extremely close, but not quite right.
      //       The problem is for GB frequencies above 2000 the frequency gets
      //       clipped. This is caused because gb_snd.snd_3.pos is never 0 at the test.
			sample:=gb_snd.snd_regs[AUD3W0+(gb_snd.snd_3.offset div 2)];
			if ((gb_snd.snd_3.offset mod 2)=0) then sample:=sample*16;
			sample:=(sample and $F)-8;
			if (gb_snd.snd_3.level<>0) then sample:=sshr(sample,(gb_snd.snd_3.level-1))
  			else sample:=0;
			gb_snd.snd_3.pos:=gb_snd.snd_3.pos+1;
			if (gb_snd.snd_3.pos>=((gb_snd.snd_3.period shr 21)+gb_snd.snd_3.duty)) then begin
				gb_snd.snd_3.pos:=0;
				if (gb_snd.snd_3.dutycount=((gb_snd.snd_3.period shr 16) mod 32)) then begin
					gb_snd.snd_3.duty:=gb_snd.snd_3.duty-1;
				end;
				gb_snd.snd_3.dutycount:=gb_snd.snd_3.dutycount+1;
				gb_snd.snd_3.offset:=gb_snd.snd_3.offset+1;
				if (gb_snd.snd_3.offset>31) then begin
					gb_snd.snd_3.offset:=0;
					gb_snd.snd_3.duty:=1;
					gb_snd.snd_3.dutycount:=0;
				end;
			end;

			if ((gb_snd.snd_3.length<>0) and (gb_snd.snd_3.mode<>0)) then begin
				gb_snd.snd_3.count:=gb_snd.snd_3.count+1;
				if (gb_snd.snd_3.count>=gb_snd.snd_3.length ) then begin
					gb_snd.snd_3.on_:=0;
					gb_snd.snd_regs[NR52]:=gb_snd.snd_regs[NR52] and $FB;
				end;
			end;
			if (gb_snd.snd_control.mode3_left<>0) then left:=left+sample;
			if (gb_snd.snd_control.mode3_right<>0) then right:=right+sample;
		end;

		// Mode 4 - Noise with Envelope */
		if (gb_snd.snd_4.on_<>0) then begin
			// Similar problem to Mode 3, we seem to miss some notes */
			sample:=gb_snd.snd_4.signal and gb_snd.snd_4.env_value;
			gb_snd.snd_4.pos:=gb_snd.snd_4.pos+1;
			if (gb_snd.snd_4.pos=(gb_snd.snd_4.period shr 17)) then begin
				// Using a Polynomial Counter (aka Linear Feedback Shift Register)
        //         Mode 4 has a 7 bit and 15 bit counter so we need to shift the
        //         bits around accordingly
        if gb_snd.snd_4.ply_step<>0 then mode4_mask:=(((gb_snd.snd_4.ply_value and $2) div 2) xor (gb_snd.snd_4.ply_value and $1)) shl 6
          else mode4_mask:=(((gb_snd.snd_4.ply_value and $2) div 2) xor (gb_snd.snd_4.ply_value and $1)) shl 14;

				gb_snd.snd_4.ply_value:=gb_snd.snd_4.ply_value div 2;
				gb_snd.snd_4.ply_value:=gb_snd.snd_4.ply_value or mode4_mask;
        if gb_snd.snd_4.ply_step<>0 then gb_snd.snd_4.ply_value:=gb_snd.snd_4.ply_value and $7f
         else gb_snd.snd_4.ply_value:=gb_snd.snd_4.ply_value and $7fff;
				gb_snd.snd_4.signal:=shortint(gb_snd.snd_4.ply_value);
			end else if (gb_snd.snd_4.pos>(gb_snd.snd_4.period shr 16)) then begin
				gb_snd.snd_4.pos:=0;
        if gb_snd.snd_4.ply_step<>0 then mode4_mask:=(((gb_snd.snd_4.ply_value and $2) div 2) xor (gb_snd.snd_4.ply_value and $1)) shl 6
          else mode4_mask:=(((gb_snd.snd_4.ply_value and $2) div 2) xor (gb_snd.snd_4.ply_value and $1)) shl 14;
				gb_snd.snd_4.ply_value:=gb_snd.snd_4.ply_value div 2;
				gb_snd.snd_4.ply_value:=gb_snd.snd_4.ply_value or mode4_mask;
        if gb_snd.snd_4.ply_step<>0 then gb_snd.snd_4.ply_value:=gb_snd.snd_4.ply_value and $7f
          else gb_snd.snd_4.ply_value:=gb_snd.snd_4.ply_value and $7fff;
				gb_snd.snd_4.signal:=shortint(gb_snd.snd_4.ply_value);
			end;

			if ((gb_snd.snd_4.length<>0) and (gb_snd.snd_4.mode<>0)) then begin
				gb_snd.snd_4.count:=gb_snd.snd_4.count+1;
				if (gb_snd.snd_4.count>=gb_snd.snd_4.length) then begin
					gb_snd.snd_4.on_:=0;
					gb_snd.snd_regs[NR52]:=gb_snd.snd_regs[NR52] and $F7;
				end;
			end;

			if (gb_snd.snd_4.env_length<>0) then begin
				gb_snd.snd_4.env_count:=gb_snd.snd_4.env_count+1;
				if (gb_snd.snd_4.env_count>=gb_snd.snd_4.env_length) then begin
					gb_snd.snd_4.env_count:=0;
					gb_snd.snd_4.env_value:=gb_snd.snd_4.env_value+gb_snd.snd_4.env_direction;
					if (gb_snd.snd_4.env_value<0) then gb_snd.snd_4.env_value:=0;
					if (gb_snd.snd_4.env_value>15) then gb_snd.snd_4.env_value:=15;
				end;
			end;

			if (gb_snd.snd_control.mode4_left<>0) then left:=left+sample;
			if (gb_snd.snd_control.mode4_right<>0) then right:=right+sample;
		end;

		// Adjust for master volume */
		left:=left*gb_snd.snd_control.vol_left;
		right:=right*gb_snd.snd_control.vol_right;

		// pump up the volume */
		left:=left shl 6;
		right:=right shl 6;
		// Update the buffers */
    tsample[gb_snd.tsample,sound_status.posicion_sonido]:=left;
    tsample[gb_snd.tsample,sound_status.posicion_sonido+1]:=right;
	  gb_snd.snd_regs[NR52]:=(gb_snd.snd_regs[NR52] and $f0) or gb_snd.snd_1.on_ or (gb_snd.snd_2.on_ shl 1) or (gb_snd.snd_3.on_ shl 2) or (gb_snd.snd_4.on_ shl 3);
end;

end.