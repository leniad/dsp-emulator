unit upd1771;

interface
uses {$IFDEF WINDOWS}windows,{$else}main_engine,{$ENDIF}timer_engine,
     sound_engine,vars_hide;

const
  MAX_PACKET_SIZE=$8000;

type
  tack_handler=procedure(state:boolean);
  upd1771_chip=class(snd_chip_class)
        constructor create(clock:integer;amp:single);
        destructor free;
      public
        procedure reset;
        function read:byte;
        procedure write(valor:byte);
        procedure change_calls(ack_handler:tack_handler);
        procedure pcm_write(state:byte);
        procedure update;
        function save_snapshot(data:pbyte):word;
        procedure load_snapshot(data:pbyte);
      private
        clock,index:dword;
        nw_tpos:byte;
        timer,expected_bytes,pc3,t_tpos,state:byte;
        t_ppos:word;
        n_value:array[0..2] of byte;
        n_ppos,n_period:array[0..2] of dword;
        packet:array[0..(MAX_PACKET_SIZE-1)] of byte;
        t_volume,t_timbre,t_offset,nw_timbre,nw_volume:byte;
        nw_ppos,nw_period:dword;
        n_volume:array[0..2] of word;
        t_period:word;
        ack_handler:tack_handler;
        salida:smallint;
  end;

var
  upd1771_0:upd1771_chip;

implementation

const
  WAVEFORMS:array[0..7,0..31] of shortint=(
(   0,   0,-123,-123, -61, -23, 125, 107,  94,  83,-128,-128,-128,   0,   0,   0,   1,   1,   1,   1,   0,   0,   0,-128,-128,-128,   0,   0,   0,   0,   0,   0),
(  37,  16,  32, -21,  32,  52,   4,   4,  33,  18,  60,  56,   0,   8,   5,  16,  65,  19,  69,  16,  -2,  19,  37,  16,  97,  19,   0,  87, 127,  -3,   1,   2),
(   0,   8,   1,  52,   4,   0,   0,  77,  81,-109,  47,  97, -83,-109,  38,  97,   0,  52,   4,   0,   1,   4,   1,  22,   2, -46,  33,  97,   0,   8, -85, -99),
(  47,  97,  40,  97,  -3,  25,  64,  17,   0,  52,  12,   5,  12,   5,  12,   5,  12,   5,  12,   5,   8,   4,-114,  19,   0,  52,-122,  21,   2,   5,   0,   8),
( -52, -96,-118,-128,-111, -74, -37,  -5,  31,  62,  89, 112, 127, 125, 115,  93,  57,  23,   0, -16,  -8,  15,  37,  54,  65,  70,  62,  54,  43,  31,  19,   0),
( -81,-128, -61,  13,  65,  93, 127,  47,  41,  44,  52,  55,  56,  58,  58,  34,   0,  68,  76,  72,  61, 108,  55,  29,  32,  39,  43,  49,  50,  51,  51,   0),
( -21, -45, -67, -88,-105,-114,-122,-128,-123,-116,-103, -87, -70, -53, -28,  -9,  22,  46,  67,  86, 102, 114, 123, 125, 127, 117, 104,  91,  72,  51,  28,   0),
( -78,-118,-128,-102, -54,  -3,  40,  65,  84,  88,  84,  80,  82,  88,  94, 103, 110, 119, 122, 125, 122, 122, 121, 123, 125, 126, 127, 127, 125, 118,  82,   0));
  NOISE_SIZE=255;

  noise_tbl:array[0..$ff] of byte=(
	$1c,$86,$8a,$8f,$98,$a1,$ad,$be,$d9,$8a,$66,$4d,$40,$33,$2b,$23,
	$1e,$8a,$90,$97,$a4,$ae,$b8,$d6,$ec,$e9,$69,$4a,$3e,$34,$2d,$27,
	$24,$24,$89,$8e,$93,$9c,$a5,$b0,$c1,$dd,$40,$36,$30,$29,$27,$24,
	$8b,$90,$96,$9e,$a7,$b3,$c4,$e1,$25,$21,$8a,$8f,$93,$9d,$a5,$b2,
	$c2,$dd,$dd,$98,$a2,$af,$bf,$d8,$fd,$65,$4a,$3c,$31,$2b,$24,$22,
	$1e,$87,$8c,$91,$9a,$a3,$af,$c0,$db,$be,$d9,$8c,$66,$4d,$40,$34,
	$2c,$24,$1f,$88,$90,$9a,$a4,$b2,$c2,$da,$ff,$67,$4d,$3d,$34,$2d,
	$26,$24,$20,$89,$8e,$93,$9c,$a5,$b1,$c2,$de,$c1,$da,$ff,$67,$4d,
	$3d,$33,$2d,$26,$24,$20,$89,$8e,$93,$9c,$a5,$b1,$c2,$dd,$a3,$b0,
	$c0,$d9,$fe,$66,$4b,$3c,$32,$2b,$24,$23,$1e,$88,$8d,$92,$9b,$a4,
	$b0,$c1,$dc,$ad,$be,$da,$22,$20,$1c,$85,$8a,$8f,$98,$a1,$ad,$be,
	$da,$20,$1b,$85,$8d,$97,$a1,$af,$bf,$d8,$fd,$64,$49,$3a,$30,$2a,
	$23,$21,$1d,$86,$8b,$91,$9a,$a2,$ae,$c0,$db,$33,$2b,$24,$1f,$88,
	$90,$9a,$a4,$b2,$c2,$da,$ff,$67,$4c,$3e,$33,$2d,$25,$24,$1f,$89,
	$8e,$93,$9c,$a5,$b1,$c2,$de,$85,$8e,$98,$a2,$b0,$c0,$d9,$fe,$64,
	$4b,$3b,$31,$2a,$23,$22,$1e,$88,$8c,$91,$9b,$a3,$af,$c1,$dc,$dc);

  STATE_SILENCE=0;
  STATE_NOISE=1;
  STATE_TONE=2;
  STATE_ADPCM=3;

procedure ack_callback;
begin
	upd1771_0.ack_handler(true);
  timers.enabled(upd1771_0.timer,false);
end;

procedure internal_update;
var
  wlfsr_val:integer;
  res:array[0..2] of byte;
  f:byte;
  temp:integer;
begin
  upd1771_0.salida:=0;
	case upd1771_0.state of
		STATE_TONE:begin
				        temp:=WAVEFORMS[upd1771_0.t_timbre][upd1771_0.t_tpos]*upd1771_0.t_volume;
                if temp>16384 then upd1771_0.salida:=16384
                  else upd1771_0.salida:=temp;
				        upd1771_0.t_ppos:=upd1771_0.t_ppos+1;
				        if (upd1771_0.t_ppos>=upd1771_0.t_period) then begin
					        upd1771_0.t_tpos:=upd1771_0.t_tpos+1;
					        if (upd1771_0.t_tpos=32) then upd1771_0.t_tpos:=upd1771_0.t_offset;
					        upd1771_0.t_ppos:=0;
                end;
              end;
		STATE_NOISE:begin
				          //"wavetable-LFSR" component
				          wlfsr_val:=noise_tbl[upd1771_0.nw_tpos]-127;//data too wide
				          upd1771_0.nw_ppos:=upd1771_0.nw_ppos+1;
				          if (upd1771_0.nw_ppos>=upd1771_0.nw_period) then begin
					          upd1771_0.nw_tpos:=upd1771_0.nw_tpos+1;
					          upd1771_0.nw_ppos:=0;
                  end;
				          //mix in each of the noise's 3 pulse components
				          for f:=0 to 2 do begin
					          res[f]:=upd1771_0.n_value[f]*127;
					          upd1771_0.n_ppos[f]:=upd1771_0.n_ppos[f]+1;
					          if (upd1771_0.n_ppos[f]>=upd1771_0.n_period[f]) then begin
						          upd1771_0.n_ppos[f]:=0;
						          upd1771_0.n_value[f]:=not(upd1771_0.n_value[f]);
                    end;
                  end;
				          //not quite, but close.
                  temp:=(wlfsr_val*upd1771_0.nw_volume) or (res[0]*upd1771_0.n_volume[0]) or (res[1]*upd1771_0.n_volume[1]) or (res[2]*upd1771_0.n_volume[2]);
                  if temp>32767 then upd1771_0.salida:=32767
                    else upd1771_0.salida:=temp;
                end;
  end;
end;

constructor upd1771_chip.create(clock:integer;amp:single);
begin
  self.clock:=clock;
  self.amp:=amp;
  self.tsample_num:=init_channel;
  self.timer:=timers.init(sound_status.cpu_num,512,ack_callback,nil,false,0);
  timers.init(sound_status.cpu_num,sound_status.cpu_clock/(self.clock/4),internal_update,nil,true,0);
  self.reset;
end;

destructor upd1771_chip.free;
begin
end;

procedure upd1771_chip.change_calls(ack_handler:tack_handler);
begin
  self.ack_handler:=ack_handler;
end;

procedure upd1771_chip.reset;
var
  f:byte;
begin
  self.index:=0;
	self.expected_bytes:=0;
	self.pc3:=0;
	self.t_tpos:=0;
	self.t_ppos:=0;
	self.state:=0;
	self.nw_tpos:=0;
	fillchar(n_value,3,0);
  for f:=0 to 2 do n_ppos[f]:=0;
  timers.enabled(self.timer,false);
  self.salida:=0;
end;

function upd1771_chip.read:byte;
begin
  read:=$80;
end;

procedure upd1771_chip.write(valor:byte);
begin
	self.ack_handler(false);
	if (index<MAX_PACKET_SIZE) then begin
    packet[index]:=valor;
    index:=index+1
  end else exit;
	case packet[0] of
		0:begin
			  state:=STATE_SILENCE;
			  index:=0;
      end;
		1:if (index=10) then begin
				  state:=STATE_NOISE;
  				index:=0;
  				nw_timbre:=(packet[1] and $e0) shr 5;
  				nw_period:=(packet[2]+1) shl 7;
  				nw_volume:=packet[3] and $1f;
  				//very long clocked periods.. used for engine drones
  				n_period[0]:=(packet[4]+1) shl 7;
  				n_period[1]:=(packet[5]+1) shl 7;
  				n_period[2]:=(packet[6]+1) shl 7;
  				n_volume[0]:=packet[7] and $1f;
  				n_volume[1]:=packet[8] and $1f;
	  			n_volume[2]:=packet[9] and $1f;
    		end else timers.enabled(self.timer,true);
		2:if (index=4) then begin
				  t_timbre:=(packet[1] and $e0) shr 5;
  				t_offset:=packet[1] and $1f;
  				t_period:=packet[2];
  				//smaller periods don't all equal to 0x20
  				if (t_period<$20) then t_period:=$20;
  				t_volume:=packet[3] and $1f;
	  			state:=STATE_TONE;
  				index:=0;
        end else timers.enabled(self.timer,true);
		$1f:begin
			    //6Khz(ish) DIGI playback
			    //end capture
			    if ((index>=2) and (packet[index-2]=$fe) and (packet[index-1]=0)) then begin
				    //TODO play capture!
				    index:=0;
				    packet[0]:=0;
            state:=STATE_ADPCM;
			    end else timers.enabled(self.timer,true);
			  end;
		  //garbage: wipe stack
		  else begin
			  state:=STATE_SILENCE;
			  index:=0;
      end;
  end;
end;

procedure upd1771_chip.pcm_write(state:byte);
begin
	//RESET upon HIGH
	if (state<>pc3) then begin
		index:=0;
		packet[0]:=0;
	end;
	pc3:=state;
end;

procedure upd1771_chip.update;
begin
  tsample[self.tsample_num,sound_status.posicion_sonido]:=trunc(salida*amp);
  if sound_status.stereo then tsample[self.tsample_num,sound_status.posicion_sonido+1]:=trunc(salida*amp);
end;

function upd1771_chip.save_snapshot(data:pbyte):word;
var
  temp:pbyte;
  buffer:array[0..64] of byte;
  size:word;
begin
temp:=data;
copymemory(temp,@self.packet,MAX_PACKET_SIZE);
inc(temp,MAX_PACKET_SIZE);
copymemory(@buffer[0],@self.clock,4);
copymemory(@buffer[4],@self.index,4);
buffer[8]:=self.nw_tpos;
buffer[9]:=self.expected_bytes;
buffer[10]:=self.pc3;
buffer[11]:=self.t_tpos;
buffer[12]:=self.state;
copymemory(@buffer[13],@self.t_ppos,2);
copymemory(@buffer[15],@self.n_value,3);
copymemory(@buffer[18],@self.n_ppos,4*3);
copymemory(@buffer[30],@self.n_period,4*3);
buffer[42]:=self.t_volume;
buffer[43]:=self.t_timbre;
buffer[44]:=self.t_offset;
buffer[45]:=self.nw_timbre;
buffer[46]:=self.nw_volume;
copymemory(@buffer[47],@self.nw_ppos,4);
copymemory(@buffer[51],@self.nw_period,4);
copymemory(@buffer[55],@self.n_volume,2*3);
copymemory(@buffer[61],@self.t_period,2);
copymemory(@buffer[63],@self.salida,2);
copymemory(temp,@buffer[0],65);
save_snapshot:=size+65;
end;

procedure upd1771_chip.load_snapshot(data:pbyte);
var
  temp:pbyte;
  buffer:array[0..64] of byte;
begin
temp:=data;
copymemory(@self.packet,temp,MAX_PACKET_SIZE);
inc(temp,MAX_PACKET_SIZE);
copymemory(@buffer[0],temp,65);
copymemory(@self.clock,@buffer[0],4);
copymemory(@self.index,@buffer[4],4);
self.nw_tpos:=buffer[8];
self.expected_bytes:=buffer[9];
self.pc3:=buffer[10];
self.t_tpos:=buffer[11];
self.state:=buffer[12];
copymemory(@self.t_ppos,@buffer[13],2);
copymemory(@self.n_value,@buffer[15],3);
copymemory(@self.n_ppos,@buffer[18],4*3);
copymemory(@self.n_period,@buffer[30],4*3);
self.t_volume:=buffer[42];
self.t_timbre:=buffer[43];
self.t_offset:=buffer[44];
self.nw_timbre:=buffer[45];
self.nw_volume:=buffer[46];
copymemory(@self.nw_ppos,@buffer[47],4);
copymemory(@self.nw_period,@buffer[51],4);
copymemory(@self.n_volume,@buffer[55],2*3);
copymemory(@self.t_period,@buffer[61],2);
copymemory(@self.salida,@buffer[63],2);
end;

end.
