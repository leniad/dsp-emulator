unit atari2600;

interface
uses atari2600_video,atari2600_audio;

function iniciar_atari2600:boolean;
procedure abrir_atari2600;

implementation
uses m6502,main_engine,controls_engine,sound_engine,misc_functions,sysutils,
     principal,atari_riot;

type
  ta26_mapper=(am_2k,am_4k,am_f8,am_f6,am_f4,am_f8sc,am_f6sc,am_f4sc,am_e0,am_dpc,am_fa,am_ar,am_3f);
  ta26_dpc_fetcher=record
    top,bottom:byte;
    counter:word; // 11-bit display-data address
    flag,music_mode,osc_clock:boolean;
  end;
  ta26_dpc=record
    fetcher:array[0..7] of ta26_dpc_fetcher;
    random,movement,latch62,latch64:byte;
    draw_carry:boolean;
    osc_phase:cardinal;
  end;

const
  MAX_CARTRIDGE=32768;
  MAX_AR_IMAGE=8448*256; // Concatenated Supercharger tape loads.
  DPC_OSC_HZ=18400; // Independent cartridge oscillator; approximate hardware pitch.

var
  cartridge:array[0..32767] of byte;
  cartridge_size,bank,bank_count:integer;
  cart_mapper:ta26_mapper;
  cart_ram:array[0..255] of byte;
  e0_bank:array[0..2] of byte;
  ar_images:array of byte;
  ar_ram:array[0..6143] of byte;
  ar_rom:array[0..2047] of byte;
  ar_low,ar_high:integer;
  ar_config,ar_latch:byte;
  ar_pending,ar_write_enabled,ar_have_address:boolean;
  ar_last_address:word;
  ar_accesses,ar_latched_at:uint64;
  data_bus:byte;
  last_keys:array[0..2] of boolean;
  cpu_cycles:uint64;
  a26_dpc:ta26_dpc;
  a26_color_clock:cardinal=3546894;
  a26_pal:boolean=true;
  timing_frames,timing_lines:integer;
  has_superchip:boolean;
  a26_console_switches:byte=$3f; // color, difficulty B/B, RESET/SELECT released

procedure ar_configuration(value:byte);
const
  low_bank:array[0..7]of byte=(2,0,2,0,2,1,2,1);
  high_bank:array[0..7]of byte=(3,3,0,2,3,3,1,2);
var
  n:integer;
begin
  ar_config:=value;
  n:=(value shr 2) and 7;
  ar_low:=low_bank[n]*2048;
  ar_high:=high_bank[n]*2048;
  ar_write_enabled:=(value and 2)<>0;
end;

function ar_load(load:byte):boolean;
const
  bootstrap:array[0..34]of byte=($78,$d8,$a2,$ff,$9a,$a0,$00,$84,$01,$a2,$05,
    $bd,$40,$f8,$95,$fa,$ca,$10,$f8,$a2,$00,$bd,$00,$f0,
    $a2,$ff,$9a,$a9,$00,$a0,$00,$4c,$fa,$00,$ea);
var
  base,h,j,map,dest:integer;
begin
  result:=false;
  base:=0;
  while base<Length(ar_images) do begin
    h:=base+8192;
    if ar_images[h+5]=load then begin
      for j:=0 to ar_images[h+3]-1 do begin
        map:=ar_images[h+16+j];
        dest:=(map and 3)*2048+((map shr 2) and 7)*256;
        if (map and 3)<3 then Move(ar_images[base+j*256],ar_ram[dest],256);
      end;
      FillChar(ar_rom,SizeOf(ar_rom),$ea);
      // $F800 is the conventional multi-load entry; reset starts at $F80A.
      ar_rom[0]:=$a5;
      ar_rom[1]:=$fa;
      ar_rom[2]:=$85;
      ar_rom[3]:=$80;
      ar_rom[4]:=$4c;
      ar_rom[5]:=$50;
      ar_rom[6]:=$f8;
      Move(bootstrap,ar_rom[$0a],SizeOf(bootstrap));
      ar_rom[$0a+20]:=ar_images[h+2];
      // Only $FA..$FF are used for the final bank-switch trampoline.
      // Leave the game's workspace at $81..$9D clear on cold start.
      ar_rom[$40]:=$cd;
      ar_rom[$41]:=$f8;
      ar_rom[$42]:=$ff;
      ar_rom[$43]:=$4c;
      ar_rom[$44]:=ar_images[h];
      ar_rom[$45]:=ar_images[h+1];
      ar_rom[$50]:=$4c;
      ar_rom[$51]:=$0a;
      ar_rom[$52]:=$f8;
      ar_rom[$7fc]:=$0a;
      ar_rom[$7fd]:=$f8;
      ar_rom[$7fe]:=$0a;
      ar_rom[$7ff]:=$f8;
      riot_0.ram[0]:=ar_images[h+2];
      ar_pending:=false;
      result:=true;
      exit;
    end;
    inc(base,8448);
  end;
end;

procedure ar_observe(address:word);
begin
  // Count distinct physical addresses, including TIA/RIOT and dummy reads.
  // Repeated accesses held by RDY do not advance the write sequence.
  if (not ar_have_address) or (address<>ar_last_address) then begin
    Inc(ar_accesses);
    ar_last_address:=address;
    ar_have_address:=true;
  end;
end;

procedure ar_access(address:word);
var offset:integer;
begin
  if ar_pending and (ar_accesses-ar_latched_at>5) then ar_pending:=false;
  if ((address and $f00)=0) and ((not ar_write_enabled) or (not ar_pending)) then begin
    ar_latch:=address and $ff;
    ar_latched_at:=ar_accesses;
    ar_pending:=true;
  end else if address=$1ff8 then begin
    ar_pending:=false;
    ar_configuration(ar_latch);
  end else if ar_write_enabled and ar_pending and (ar_accesses-ar_latched_at=5) then begin
              if (address and $800)=0 then offset:=ar_low+(address and $7ff)
                else offset:=ar_high+(address and $7ff);
              if offset<6144 then ar_ram[offset]:=ar_latch;
              ar_pending:=false;
           end;
end;

function ar_read(address:word):byte;
var offset:integer;
begin
  // Fast loading when software enters the cartridge loading routine.
  if (address=$1850) and (ar_high=6144) then ar_load(riot_0.ram[0]);
  ar_access(address);
  if (address and $800)=0 then offset:=ar_low+(address and $7ff)
    else offset:=ar_high+(address and $7ff);
  if offset<6144 then result:=ar_ram[offset]
    else result:=ar_rom[offset-6144];
end;

procedure dpc_check_flag(n:integer);
var
  low:byte;
begin
  low:=a26_dpc.fetcher[n].counter and $ff;
  if low=a26_dpc.fetcher[n].top then a26_dpc.fetcher[n].flag:=true;
  if low=a26_dpc.fetcher[n].bottom then a26_dpc.fetcher[n].flag:=false;
end;

procedure dpc_decrement(n:integer);
begin
  a26_dpc.fetcher[n].counter:=(a26_dpc.fetcher[n].counter+$7ff) and $7ff;
  if (n>=5) and a26_dpc.fetcher[n].music_mode and ((a26_dpc.fetcher[n].counter and $ff)=$ff) then a26_dpc.fetcher[n].counter:=(a26_dpc.fetcher[n].counter and $700) or a26_dpc.fetcher[n].top;
  dpc_check_flag(n);
end;

procedure dpc_clock_cpu;
var
  n:integer;
begin
  if cart_mapper<>am_dpc then exit;
  // One 6507 cycle is exactly three TIA colour clocks. This accumulator
  // keeps the DPC oscillator independent of PAL/NTSC and of frame lengths.
  inc(a26_dpc.osc_phase,3*DPC_OSC_HZ);
  while a26_dpc.osc_phase>=a26_color_clock do begin
    dec(a26_dpc.osc_phase,a26_color_clock);
    for n:=5 to 7 do if a26_dpc.fetcher[n].osc_clock then dpc_decrement(n);
  end;
end;

function dpc_read(reg:byte):byte;
const
  amplitude:array[0..7] of byte=($00,$04,$05,$09,$06,$0a,$0b,$0f);
var
  n,i,mix,total:integer;
  value,feedback,reversed:byte;
begin
  reg:=reg and $3f;
  n:=reg and 7;
  if reg<8 then begin
    if (reg and 6)<4 then begin
      feedback:=not((a26_dpc.random shr 7) xor (a26_dpc.random shr 5) xor (a26_dpc.random shr 4) xor (a26_dpc.random shr 3)) and 1;
      a26_dpc.random:=((word(a26_dpc.random) shl 1) or feedback) and $ff;
      result:=a26_dpc.random;
    end else begin
      if (reg and 6)=4 then a26_dpc.latch62:=a26_dpc.latch64;
      total:=integer(a26_dpc.latch62)+a26_dpc.fetcher[4].top;
      a26_dpc.latch64:=total and $ff;
      a26_dpc.draw_carry:=total>$ff;
      mix:=0;
      for i:=5 to 7 do
        if a26_dpc.fetcher[i].music_mode and a26_dpc.fetcher[i].flag then mix:=mix or (1 shl (i-5));
      result:=amplitude[mix];
      if a26_dpc.draw_carry then result:=result or (a26_dpc.movement and $f0);
    end;
    exit;
  end;
  value:=cartridge[$2000+($7ff-a26_dpc.fetcher[n].counter)];
  case (reg and $38) of
    $08:result:=value;
    $10,$18,$20,$28,$30:begin
      if not a26_dpc.fetcher[n].flag then value:=0;
      case (reg and $38) of
        $10:result:=value;
        $18:result:=((word(value) shl 4) or (value shr 4)) and $ff;
        $20:begin
          reversed:=0;
          for i:=0 to 7 do reversed:=(word(reversed) shl 1) or ((value shr i) and 1);
          result:=reversed;
        end;
        $28:result:=value shr 1;
        else result:=(word(value) shl 1) and $ff;
      end;
    end;
    else if a26_dpc.fetcher[n].flag then result:=$ff else result:=0;
  end;
  if (n<5) or not a26_dpc.fetcher[n].osc_clock then dpc_decrement(n);
end;

procedure dpc_write(reg,value:byte);
var
  n:integer;
begin
  reg:=reg and $3f;
  n:=reg and 7;
  case (reg and $38) of
    $00:begin
      a26_dpc.fetcher[n].top:=value;
      a26_dpc.fetcher[n].flag:=false;
      dpc_check_flag(n);
    end;
    $08:begin
          a26_dpc.fetcher[n].bottom:=value;
          dpc_check_flag(n);
        end;
    $10:begin
      a26_dpc.fetcher[n].counter:=(a26_dpc.fetcher[n].counter and $700) or value;
      if n=4 then a26_dpc.latch64:=value;
      if (n>=5) and a26_dpc.fetcher[n].music_mode then a26_dpc.fetcher[n].counter:=(a26_dpc.fetcher[n].counter and $700) or a26_dpc.fetcher[n].top;
      dpc_check_flag(n);
    end;
    $18:begin
      a26_dpc.fetcher[n].counter:=(word(value and 7) shl 8) or (a26_dpc.fetcher[n].counter and $ff);
      a26_dpc.fetcher[n].music_mode:=(value and $10)<>0;
      a26_dpc.fetcher[n].osc_clock:=(value and $20)<>0;
      if (n>=5) and a26_dpc.fetcher[n].music_mode and ((a26_dpc.fetcher[n].counter and $ff)=$ff) then begin
        a26_dpc.fetcher[n].counter:=(a26_dpc.fetcher[n].counter and $700) or a26_dpc.fetcher[n].top;
        dpc_check_flag(n);
      end;
    end;
    $20:a26_dpc.movement:=value;
    $30:a26_dpc.random:=0;
  end;
end;

procedure clock_cpu;
var
  i:integer;
begin
  for i:=1 to 3 do begin
    tia_video_tick;
    tia_audio_tick;
  end;
  riot_0.tick;
  dpc_clock_cpu;
  inc(cpu_cycles);
end;

procedure a26_cpu_cycle(is_read:boolean);
begin
  if is_read then
    while tia_video.wsync do begin
      clock_cpu;
      inc(m6502_0.contador);
    end;
  clock_cpu;
end;

procedure select_bank(address:word);
var
  start:word;
begin
  address:=address and $1fff;
  if cart_mapper=am_e0 then begin
    case address of
      $1fe0..$1fe7:e0_bank[0]:=address and 7;
      $1fe8..$1fef:e0_bank[1]:=address and 7;
      $1ff0..$1ff7:e0_bank[2]:=address and 7;
    end;
    exit;
  end;
  start:=0;
  case cart_mapper of
    am_f8,am_f8sc,am_dpc,am_fa:start:=$1ff8;
    am_f6,am_f6sc:start:=$1ff6;
    am_f4,am_f4sc:start:=$1ff4;
  end;
  if (start<>0) and (address>=start) and (address<start+bank_count) then bank:=address-start;
end;

function a26_getbyte(address:word):byte;
var
  segment,selected_bank:integer;
begin
  address:=address and $1fff;
  if cart_mapper=am_ar then ar_observe(address);
  case address of
    0..$fff:begin
      if (address and $80)=0 then result:=tia_video_read(address and $f,data_bus)
        else if (address and $200)=0 then result:=riot_0.ram[address and $7f]
                else result:=riot_0.read(address);
    end;
    $1000..$1fff:begin
      select_bank(address);
      if cart_mapper=am_ar then result:=ar_read(address)
        else if (cart_mapper=am_dpc) and (address<$1040) then result:=dpc_read(address and $3f)
              else if (cart_mapper=am_fa) and (address<$1200) then begin
                      if address<$1100 then begin
                          // Reading a write-only RAM port writes the current bus value.
                          result:=data_bus;
                          cart_ram[address and $ff]:=result;
                      end else result:=cart_ram[address and $ff];
                   end else if cart_mapper=am_e0 then begin
                                segment:=(address and $fff) shr 10;
                                if segment=3 then selected_bank:=7
                                  else selected_bank:=e0_bank[segment];
                                result:=cartridge[selected_bank*1024+(address and $03ff)];
                            end else if (has_superchip and (address<$1100)) then begin
                                        if address<$1080 then begin
                                            // Reading the write-only port also writes the current bus value.
                                            result:=data_bus;
                                            cart_ram[address and $7f]:=result;
                                        end else result:=cart_ram[address and $7f];
                                     end else if cart_mapper=am_3f then begin
                                                  if address<$1800 then result:=cartridge[bank*2048+(address and $7ff)]
                                                      else result:=cartridge[cartridge_size-2048+(address and $7ff)];
                                              end else if cart_mapper=am_2k then result:=cartridge[address and $7ff]
                                                          else result:=cartridge[bank*4096+(address and $fff)];
      end;
  end;
  data_bus:=result;
end;

procedure a26_putbyte(address:word;value:byte);
begin
  address:=address and $1fff;
  if cart_mapper=am_ar then ar_observe(address);
  data_bus:=value;
  // Tigervision 3F observes writes in $00..$3F; the TIA sees them too.
  if(cart_mapper=am_3f)and(address<=$3f)then bank:=value mod bank_count;
  if(address and $1000)<>0 then begin
    select_bank(address);
    if cart_mapper=am_ar then ar_access(address)
      else if (cart_mapper=am_dpc) and (address>=$1040) and (address<$1080) then dpc_write(address and $3f,value)
            else if (cart_mapper=am_fa) and (address<$1100) then cart_ram[address and $ff]:=value
                    else if (has_superchip and (address<$1080)) then cart_ram[address and $7f]:=value;
    // Writes to Superchip $1080..$10FF and FA $1100..$11FF are ignored (read ports).
  end else if(address and $80)=0 then begin
              tia_video_write(address and $3f,value);
              if (address and $3f) in[$15..$1a] then tia_audio_write(address and $3f,value);
           end else if(address and $200)=0 then riot_0.ram[address and $7f]:=value
                      else riot_0.write(address,value);
end;

procedure a26_update_controls;
var
  p,shift:integer;
  inp:byte;
  pressed:boolean;
begin
  inp:=$ff;
  for p:=0 to 1 do begin
    shift:=(1-p)*4;
    if arcade_input.up[p]then inp:=inp and not(1 shl shift);
    if arcade_input.down[p]then inp:=inp and not(2 shl shift);
    if arcade_input.left[p]then inp:=inp and not(4 shl shift);
    if arcade_input.right[p]then inp:=inp and not(8 shl shift);
  end;
  riot_0.input_a:=inp;
  riot_0.edge;
  tia_video_inputs(arcade_input.but0[0],arcade_input.but0[1]);
  for p:=0 to 2 do begin
    case p of
      0:pressed:=keyboard[KEYBOARD_3];
      1:pressed:=keyboard[KEYBOARD_4];
      else pressed:=keyboard[KEYBOARD_5];
    end;
    if pressed and not(last_keys[p]) then
    case p of
      0:a26_console_switches:=a26_console_switches xor 8;
      1:a26_console_switches:=a26_console_switches xor $40;
      2:a26_console_switches:=a26_console_switches xor $80;
    end;
    last_keys[p]:=pressed;
  end;
  inp:=a26_console_switches or 3;
  if keyboard[KEYBOARD_1]then inp:=inp and $fe;
  if keyboard[KEYBOARD_2]then inp:=inp and $fd;
  riot_0.input_b:=inp;
end;

procedure a26_update_timing(frame_cycles:uint64);
var lines:integer;pal:boolean;clock:cardinal;
begin
  // Count the complete VSYNC frame, never just the visible image.
  lines:=Round(frame_cycles*3/228);
  if(lines<240)or(lines>330)then begin timing_frames:=0;exit;end;
  if lines<>timing_lines then begin timing_lines:=lines;timing_frames:=1;end
    else if timing_frames<8 then Inc(timing_frames);
  if timing_frames<>8 then exit;
  pal:=lines>=290;
  if pal then clock:=3546894 else clock:=3579545;
  if(a26_pal=pal)and(llamadas_maquina.scanlines=lines)then exit;
  a26_pal:=pal;
  a26_color_clock:=clock;
  llamadas_maquina.scanlines:=lines;
  llamadas_maquina.fps_max:=clock/228/lines;
  change_video_clock(llamadas_maquina.fps_max);
  tia_audio_set_clock(clock);
  tia_video_set_palette(pal);
end;

procedure atari2600_main;
var
  serial:cardinal;
  start_cycles:uint64;
begin
  while EmuStatus=EsRunning do begin
    a26_update_controls;
    serial:=tia_video.frame_number;
    start_cycles:=cpu_cycles;
    repeat
      m6502_0.run(1);
    until (tia_video.frame_number<>serial);
    a26_update_timing(cpu_cycles-start_cycles);
    tia_video_present;
    video_sync;
  end;
end;

procedure reset_atari2600;
begin
  timing_frames:=0;timing_lines:=0;
  fillchar(a26_dpc,SizeOf(a26_dpc),0);
  riot_0.reset;
  riot_0.input_b:=$3f;
  e0_bank[0]:=4;
  e0_bank[1]:=5;
  e0_bank[2]:=6;
  bank:=bank_count-1;
  if bank<0 then bank:=0;
  if cart_mapper in [am_f6,am_f6sc,am_3f] then bank:=0;
  data_bus:=0;
  cpu_cycles:=0;
  fillchar(last_keys,3,0);
  tia_video_reset;
  tia_audio_reset;
  reset_audio;
  if cart_mapper=am_ar then begin
    FillChar(ar_ram,SizeOf(ar_ram),0);
    ar_accesses:=0;
    ar_latched_at:=0;
    ar_have_address:=false;
    ar_pending:=false;
    ar_latch:=0;
    ar_configuration(0);
    ar_load(ar_images[8197]);
  end;
  m6502_0.reset;
  // reset() fetches the vector outside run(); clock the seven reset cycles.
  clock_cpu;clock_cpu;clock_cpu;clock_cpu;clock_cpu;clock_cpu;clock_cpu;
end;

procedure abrir_cartucho(datos:pbyte;longitud:integer);
function a26_probably_e0(const data:array of byte;size:integer):boolean;
var
  i,j:integer;
const
  signatures:array[0..7,0..2]of byte=(
    ($8d,$e0,$1f),($8d,$e0,$5f),($8d,$e9,$ff),($0c,$e0,$1f),
    ($ad,$e0,$1f),($ad,$e9,$ff),($ad,$ed,$ff),($ad,$f3,$bf));
begin
  a26_probably_e0:=false;
  for i:=0 to size-3 do
    for j:=0 to 7 do
      if ((data[i]=signatures[j,0]) and (data[i+1]=signatures[j,1]) and (data[i+2]=signatures[j,2])) then begin
          a26_probably_e0:=true;
          exit;
      end;
end;

function a26_probably_3f(const data:array of byte;size:integer):boolean;
var i,hits:integer;
begin
  result:=false;
  if(size<8192)or((size mod 2048)<>0)then exit;
  hits:=0;
  for i:=0 to size-2 do
    if(data[i]=$85)and(data[i+1]=$3f)then begin
      Inc(hits);
      if hits>=2 then begin
        result:=true;
        exit;
      end;
    end;
end;

function a26_probably_superchip(const data:array of byte;size:integer):boolean;
var
  offset,i:integer;
begin
  a26_probably_superchip:=false;
  if ((size<>8192) and (size<>16384) and (size<>32768)) then exit;
  // Each bank has a 128-byte write port followed by its 128-byte read port.
  // Matching image halves are a heuristic; an explicit mapper overrides it.
  offset:=0;
  while offset<size do begin
    for i:=0 to 127 do
      if data[offset+i]<>data[offset+128+i] then exit;
      inc(offset,4096);
  end;
  a26_probably_superchip:=true;
end;
function ar_validate(datos:pbyte;size:integer):boolean;
var
  base,h,j,k,sum,map:integer;
  p:pbyte;
begin
  result:=false;
  if (datos=nil) or (size<8448) or (size>MAX_AR_IMAGE) or ((size mod 8448)<>0) then exit;
  base:=0;
  while base<size do begin
    p:=datos;
    inc(p,base+8192);
    sum:=0;
    for j:=0 to 7 do begin
      inc(sum,p^);
      inc(p);
    end;
    if (sum and 255)<>$55 then exit;
    p:=datos;
    inc(p,base+8195);
    h:=p^;
    if h>24 then exit;
    for j:=0 to h-1 do begin
      p:=datos;
      inc(p,base+8208+j);
      map:=p^;
      if (map and $e0)<>0 then exit;
      p:=datos;
      inc(p,base+8256+j);
      sum:=map+p^;
      p:=datos;
      inc(p,base+j*256);
      for k:=0 to 255 do begin
        inc(sum,p^);
        inc(p);
      end;
      if (sum and 255)<>$55 then exit;
    end;
    inc(base,8448);
  end;
  result:=true;
end;

var
  selected:ta26_mapper;
begin
    // A Supercharger load is 8192 bytes plus its 256-byte tape header.
    // Keep the full image; neither truncate it nor classify it as F8.
    if (longitud>=8448) and ((longitud mod 8448)=0) then begin
      if not ar_validate(datos,longitud) then exit;
      SetLength(ar_images,longitud);
      Move(datos^,ar_images[0],longitud);
      cartridge_size:=longitud;
      cart_mapper:=am_ar;
      has_superchip:=false;
      bank_count:=1;
      exit;
    end;
    if (longitud<2048) or (longitud>MAX_CARTRIDGE) then exit;
    SetLength(ar_images,0);
    copymemory(@cartridge[0],datos,longitud);
    // Detect DPC before the generic 8K interval. The display ROM starts
    // at $2000 in both formats; the 10495-byte variant has 255 trailing bytes.
    if (longitud=10240) or (longitud=10495) then selected:=am_dpc
    else if a26_probably_3f(cartridge,longitud)then selected:=am_3f
    else if longitud=12288 then selected:=am_fa // CBS RAM Plus, three 4K banks
    else case longitud of
        2048:selected:=am_2k;
        4096:selected:=am_4k;
        8192:if a26_probably_e0(cartridge,longitud) then selected:=am_e0
              else selected:=am_f8;
        16384:selected:=am_f6;
        32768:selected:=am_f4;
      end;
      if a26_probably_superchip(cartridge,longitud) then
        case selected of
          am_f8:selected:=am_f8sc;
          am_f6:selected:=am_f6sc;
          am_f4:selected:=am_f4sc;
        end;
    cartridge_size:=longitud;
    cart_mapper:=selected;
    has_superchip:=cart_mapper in [am_f8sc,am_f6sc,am_f4sc];
    fillchar(cart_ram,$100,0);
    if cart_mapper=am_3f then bank_count:=longitud div 2048
      else if cart_mapper=am_dpc then bank_count:=2
      else bank_count:=longitud div 4096;
    if bank_count=0 then bank_count:=1;
end;

procedure abrir_atari2600;
var
  extension,nombre_file,RomFile:string;
  datos:pbyte;
  longitud:integer;
begin
  if not(openrom(romfile,SATARI2600)) then exit;
  getmem(datos,MAX_AR_IMAGE);
  if not(extract_data(romfile,datos,longitud,nombre_file,SATARI2600)) then begin
    freemem(datos);
    exit;
  end;
  extension:=extension_fichero(nombre_file);
  if ((extension='A26') or (extension='BIN')) then begin
    abrir_cartucho(datos,longitud);
    reset_atari2600;
  end;
  freemem(datos);
  main_vars.nombre_caption:=nombre_file;
  change_caption;
  directory.atari2600:=ExtractFilePath(romfile);
end;

function iniciar_atari2600:boolean;
var
  color_clock:cardinal;
  nominal_lines:integer;
begin
  iniciar_atari2600:=false;
  principal1.BitBtn10.Glyph:=nil;
  principal1.imagelist2.GetBitmap(4,principal1.BitBtn10.Glyph);
  if a26_pal then begin
    color_clock:=3546894;
    nominal_lines:=312;
  end
  else begin
    color_clock:=3579545;
    nominal_lines:=262;
  end;
  llamadas_maquina.fps_max:=color_clock/228/nominal_lines;
  llamadas_maquina.scanlines:=nominal_lines;
  llamadas_maquina.bucle_general:=atari2600_main;
  llamadas_maquina.reset:=reset_atari2600;
  llamadas_maquina.cartuchos:=abrir_atari2600;
  iniciar_audio(false);
  a26_color_clock:=color_clock;
  screen_init(1,A26_WIDTH,A26_HEIGHT);
  iniciar_video(A26_WIDTH,A26_HEIGHT);
  tia_audio_init(color_clock,true);
  tia_video_init(a26_pal);
  m6502_0:=cpu_m6502.create(color_clock div 3,TCPU_M6502);
  m6502_0.change_ram_calls(a26_getbyte,a26_putbyte);
  m6502_0.change_bus_cycle(a26_cpu_cycle);
  riot_0:=tatari_riot.create;
  fillchar(cartridge[0],sizeof(cartridge),$ff);
  bank_count:=1;
  if main_vars.console_init then abrir_atari2600;
  iniciar_atari2600:=true;
end;

end.
