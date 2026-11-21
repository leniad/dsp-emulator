unit atari5200;

interface
uses rom_engine;

const
  a5200_rom:array[0..1] of tipo_roms=((n:'5200.rom';l:$800;p:0;crc:$4248D3E3),());

function iniciar_atari5200:boolean;

implementation
uses
  sysutils,dialogs,m6502,pokey,controls_engine,sound_engine,timer_engine,
  main_engine,atari5200_video,misc_functions,file_engine,principal;

const
  MAX_CARTRIDGE=$80000; // Super Cart: up to 512 KiB.
  MAX_CARTRIDGE_FILE=MAX_CARTRIDGE+16; // Optional CART header.

var
  ram:array[0..$3fff] of byte;
  bios:array[0..$7ff] of byte;
  cartridge:array[0..MAX_CARTRIDGE-1] of byte;
  cartridge_size,cartridge_type:integer;
  bounty_bank:array[0..1] of byte;
  super_bank:byte;
  irq_enable,skctl,kbcode,last_key,key_pending,key_scan:byte;
  pots:array[0..7] of byte;
  a5200_axis_override:array[0..7] of integer;
  a5200_connected_controllers:byte=$01;
  a5200_keypad:array[0..3] of byte;
  a5200_buttons_override:array[0..3] of integer;

procedure sync_irq;
var
  state:byte;
begin
  state:=not pokey_0.read(IRQST_C);
  if (((state or key_pending) and irq_enable)<>0) then m6502_0.change_irq(ASSERT_LINE)
    else m6502_0.change_irq(CLEAR_LINE);
end;

function pot_read(offset:byte):byte;
begin
  if (a5200_video.gtia[31] and 4)=0 then Result:=228
    else Result:=pots[offset and 7];
end;

procedure video_nmi;
begin
  m6502_0.change_nmi(PULSE_LINE);
end;

procedure sound_update;
begin
  pokey_0.update;
end;

procedure reset_cart_banks;
begin
  bounty_bank[0]:=0;
  bounty_bank[1]:=0;
  if cartridge_type in [71..74] then super_bank:=(cartridge_size div $8000)-1
    else super_bank:=0;
end;

procedure super_cart_access(address:word);
var
  bank:integer;
begin
  if address<$bfc0 then exit;
  bank:=super_bank;
  case address and $30 of
    $00:bank:=(bank and 3) or (address and $0c);
    $10:bank:=(bank and $0c) or ((address and $0c) shr 2);
    else bank:=$0f;
  end;
  super_bank:=bank and ((cartridge_size div $8000)-1);
end;

function cart_read(address:word):byte;
var
  o:integer;
begin
  if cartridge_size=0 then begin
    result:=$ff;
    exit;
  end;
  o:=address-$4000;
  case cartridge_type of
    6:if address<$8000 then o:=address and $1fff
        else o:=$2000+(address and $1fff);
    7:begin
      if (address>=$4ff6) and (address<=$4ff9) then bounty_bank[0]:=address-$4ff6;
      if (address>=$5ff6) and (address<=$5ff9) then bounty_bank[1]:=address-$5ff6;
      if address<$5000 then o:=bounty_bank[0]*4096+(address and $fff)
        else if address<$6000 then o:=$4000+bounty_bank[1]*4096+(address and $fff)
              else if address>=$8000 then o:=$8000+(address and $1fff)
                    else begin
                            result:=$ff;
                            exit;
                         end;
    end;
    71..74:begin
      // A hotspot access switches the bank before returning the ROM byte.
      super_cart_access(address);
      o:=integer(super_bank)*$8000+(address-$4000);
    end;
    else o:=o mod cartridge_size;
  end;
  result:=cartridge[o];
end;

function a5200_read(address:word):byte;
var
  r:byte;selected:integer;
begin
  case address of
    $0000..$3fff:result:=ram[address];
    $4000..$bfff:result:=cart_read(address);
    $c000..$cfff:result:=a5200_gtia_read(address and 31);
    $d400..$d4ff:result:=a5200_antic_read(address and 15);
    $e800..$efff:begin
      r:=address and 15;
      case r of
        KBCODE_C:result:=kbcode;
        IRQST_C:result:=pokey_0.read(r) and not(key_pending and irq_enable);
        SKSTAT_C:begin
          Result:=pokey_0.read(r) or SK_KEYBD or SK_SHIFT;
          if (last_key<>$ff) and ((skctl and SK_KEYSCAN)<>0) then Result:=Result and not SK_KEYBD;
          selected:=a5200_video.gtia[31] and 3;
          if (a5200_connected_controllers and (1 shl selected))=0 then begin
            // An unplugged upper trigger is released.
          end else if a5200_buttons_override[selected]>=0 then begin
            if (a5200_buttons_override[selected] and 2)<>0 then Result:=Result and not SK_SHIFT;
          end else if selected<=NUM_PLAYERS then
            if arcade_input.but1[selected] then Result:=Result and not SK_SHIFT;
        end;
        else Result:=pokey_0.read(r);
      end;
    end;
    $f800..$ffff:Result:=bios[address and $7ff];
    else Result:=$ff;
  end;
end;

procedure a5200_write(address:word;value:byte);
var
  r,v:byte;
begin
  case address of
    $0000..$3fff:ram[address]:=value;
    $4000..$bfff:if (cartridge_type=7) or (cartridge_type in [71..74]) then v:=cart_read(address);
    $c000..$cfff:a5200_gtia_write(address and 31,value);
    $d400..$d4ff:a5200_antic_write(address and 15,value);
    $e800..$efff:begin
      r:=address and 15;
      if r=IRQEN_C then begin
        irq_enable:=value;
        key_pending:=key_pending and value;
      end;
      if r=SKCTL_C then begin
        skctl:=value;
        if (value and 3)=0 then begin
          irq_enable:=0;
          key_pending:=0;
          last_key:=$ff;
          key_scan:=0;
        end;
      end;
      pokey_0.write(r,value);
      sync_irq;
    end;
  end;
end;

procedure a5200_update_controls;
const
  keys:array[0..9]of byte=(KEYBOARD_0,KEYBOARD_1,KEYBOARD_2,KEYBOARD_3,KEYBOARD_4,KEYBOARD_5,KEYBOARD_6,KEYBOARD_7,KEYBOARD_8,KEYBOARD_9);
  codes:array[0..9]of byte=($05,$1f,$1d,$1b,$17,$15,$13,$0f,$0d,$0b);
var
  p,i,x,y,selected:integer;
  k,scan_code:byte;
begin
  for p:=0 to 3 do begin
    a5200_video.trigger[p]:=1;
    if (a5200_connected_controllers and (1 shl p))=0 then begin
      pots[p*2]:=228;
      pots[p*2+1]:=228;
      continue;
    end;
    x:=114;
    y:=114;
    if p<=NUM_PLAYERS then begin
      x:=analog.c[0].x[p];
      y:=analog.c[0].y[p];
    end;
    if a5200_axis_override[p*2]>=0 then x:=a5200_axis_override[p*2];
    if a5200_axis_override[p*2+1]>=0 then y:=a5200_axis_override[p*2+1];
    if x<0 then x:=0 else if x>228 then x:=228;
    if y<0 then y:=0 else if y>228 then y:=228;
    pots[p*2]:=x;
    pots[p*2+1]:=y;
    a5200_video.trigger[p]:=1;
    if a5200_buttons_override[p]>=0 then a5200_video.trigger[p]:=1-Ord((a5200_buttons_override[p] and 1)<>0)
      else if p<=NUM_PLAYERS then a5200_video.trigger[p]:=1-Ord(arcade_input.but0[p]);
  end;
  selected:=a5200_video.gtia[31] and 3;
  k:=a5200_keypad[selected];
  if selected=0 then begin
    for i:=0 to 9 do if keyboard[keys[i]] then k:=codes[i];
    if keyboard[KEYBOARD_A] then k:=$07;
    if keyboard[KEYBOARD_S] then k:=$03;
    if keyboard[KEYBOARD_RETURN] or arcade_input.start[0] then k:=$19;
    if keyboard[KEYBOARD_P] then k:=$11;
    if keyboard[KEYBOARD_R] then k:=$09;
  end;
  if (a5200_connected_controllers and (1 shl selected))=0 then k:=$ff;
  if (skctl and 3)<>2 then k:=$ff;
  if (k<>$ff) and ((key_scan and $1f)=(k and $1f)) then begin
    scan_code:=(k and $c0) or key_scan;
    kbcode:=scan_code;
    if (irq_enable and IRQ_KEYBD)<>0 then key_pending:=key_pending or IRQ_KEYBD;
  end;
  last_key:=k;
  if (skctl and SK_KEYSCAN)<>0 then key_scan:=(key_scan+1) and $3f
    else key_scan:=0;
end;

procedure video_clock;
begin
  if a5200_video.cycle=0 then a5200_update_controls;
  // POKEY also runs while ANTIC or WSYNC holds the CPU.
  pokey_0.clock;
  a5200_video_tick;
end;

procedure cpu_cycle(is_read:boolean);
begin
  // ANTIC DMA uses HALT and stops reads and writes. WSYNC uses RDY
  // and can stop reads only; the video module distinguishes both sources.
  while a5200_video_cpu_blocked(is_read) do begin
    video_clock;
    inc(m6502_0.contador);
  end;
  video_clock;
  sync_irq;
end;

procedure atari5200_principal;
begin
  while EmuStatus=EsRunning do begin
    frame_main:=a5200_video.frame_number;
    repeat
      m6502_0.run(1);
    until a5200_video.frame_number<>frame_main;
    a5200_video_present;
    video_sync;
  end;
end;

procedure reset_atari5200;
var
  i:integer;
begin
  fillchar(ram,$4000,0);
  reset_cart_banks;
  irq_enable:=0;
  skctl:=3;
  kbcode:=$ff;
  last_key:=$ff;
  key_pending:=0;
  key_scan:=0;
  for i:=0 to 7 do
    if (a5200_connected_controllers and (1 shl (i div 2)))<>0 then pots[i]:=114
      else pots[i]:=228;
  for i:=0 to NUM_PLAYERS do begin
    analog.c[0].x[i]:=114;
    analog.c[0].y[i]:=114;
  end;
  pokey_0.reset;
  a5200_video_reset;
  reset_audio;
  m6502_0.reset;
  for i:=1 to 7 do video_clock;
  timers.update(7,m6502_0.numero_cpu);
end;

function abrir_cartucho(data:pbyte;size:integer):boolean;
function raw_16k_type(data:pbyte;size:integer):integer;
begin
  case calc_crc(data,size) of
    $4019ecec,$b3b8e314,$04807705,$536a70fe,
    $82b91800, // Congo Bongo (1983, Sega), NTSC: two-chip wiring.
    $f1f42bbd,$fd541c80,$bd52623b,$6a687f9c,
    $04b299a4,$0af19345,$cfd4a7f9,$d9ae4518,
    $7c30592c, // Jr. Pac-Man, alternate dump: two-chip wiring.
    $bfd30c01,$59983c40,$2c676662,$ecfa624f,
    $84df4925,$931a454a,$c597c087,$2a640143,
    $752f5efd,$8873ef51,$abc2d1e4,$a18a9a40,
    $aea6d2c2,$0f996184,$4336c2cc,$ecbd1853,
    $10f33c90,$a97606ab,$b68d61e8,$73b5b6fb,
    $7d819a9f,$69f23548,$75f566df,$1d1cee27,
    $b8faaec3,$e8b130c4,$ce07d9ad,$44ECAEE7,$C5392CBA,$731FD47D,$41FCEE82:result:=6;
    else result:=16;
  end;
end;
function read_be32(offset:integer):cardinal;
begin
  result:=(cardinal(data[offset]) shl 24) or (cardinal(data[offset+1]) shl 16) or (cardinal(data[offset+2]) shl 8) or cardinal(data[offset+3]);
end;
var
  p,expected,i:integer;
  sum,stored:cardinal;
  cart_type:integer;
begin
  result:=false;
  if (data=nil) or (size<=0) or (size>MAX_CARTRIDGE_FILE) then begin
    MessageDlg('Tamano de cartucho no soportado', mtError,[mbOk], 0);
    exit;
  end;
  p:=0;
  cart_type:=-1;
  if (size>=16) and (data[0]=Ord('C')) and (data[1]=Ord('A')) and (data[2]=Ord('R')) and (data[3]=Ord('T')) then begin
    // CART stores both 32-bit fields in big-endian order.
    cart_type:=read_be32(4);
    stored:=read_be32(8);
    sum:=0;
    for i:=16 to size-1 do sum:=sum+data[i];
    if sum<>stored then begin
      MessageDlg('Checksum CAR incorrecto', mtError,[mbOk], 0);
      exit;
    end;
    p:=16;
    dec(size,16);
  end;
  if cart_type=-1 then case size of
    4096:cart_type:=20;
    8192:cart_type:=19;
    16384:cart_type:=raw_16k_type(@data[p],size);
    32768:cart_type:=4;
    40960:cart_type:=7;
    65536:cart_type:=71;
    131072:cart_type:=72;
    262144:cart_type:=73;
    524288:cart_type:=74;
    else cart_type:=-1;
  end;
  case cart_type of
    4:expected:=32768;
    6,16:expected:=16384;
    7:expected:=40960;
    19:expected:=8192;
    20:expected:=4096;
    71:expected:=65536;
    72:expected:=131072;
    73:expected:=262144;
    74:expected:=524288;
    else expected:=0;
  end;
  if (expected=0) or (expected<>size) then begin
    MessageDlg('Mapper o longitud CAR no soportado', mtError,[mbOk], 0);
    exit;
  end;
  fillchar(cartridge,SizeOf(cartridge),$ff);
  copymemory(@cartridge[0],@data[p],size);
  cartridge_size:=size;
  cartridge_type:=cart_type;
  reset_cart_banks;
  result:=true;
end;

procedure abrir_atari5200;
var
  extension,nombre_file,RomFile:string;
  datos:pbyte;
  longitud:integer;
begin
  if not(openrom(romfile,SATARI5200)) then exit;
  read_file_size(romfile,longitud);
  if (longitud<=0) or (longitud>MAX_CARTRIDGE_FILE) then exit;
  getmem(datos,MAX_CARTRIDGE_FILE);
  if not(extract_data(romfile,datos,longitud,nombre_file,SATARI5200)) then begin
    freemem(datos);
    exit;
  end;
  extension:=extension_fichero(nombre_file);
  if ((extension='A52') or (extension='BIN') or (extension='CAR')) then begin
          if abrir_cartucho(datos,longitud) then reset_atari5200;
         end;
  freemem(datos);
  main_vars.nombre_caption:=nombre_file;
  change_caption;
  directory.atari5200:=ExtractFilePath(romfile);
end;

function iniciar_atari5200:boolean;
var
  f:byte;
begin
  result:=false;
  principal1.BitBtn10.Glyph:=nil;
  principal1.imagelist2.GetBitmap(4,principal1.BitBtn10.Glyph);
  if not(roms_load(@bios,a5200_rom,true,true,'a5200.zip')) then exit;
  llamadas_maquina.fps_max:=A5200_CLOCK/(A5200_CYCLES_LINE*A5200_LINES);
  llamadas_maquina.scanlines:=A5200_LINES;
  llamadas_maquina.bucle_general:=atari5200_principal;
  llamadas_maquina.reset:=reset_atari5200;
  llamadas_maquina.cartuchos:=abrir_atari5200;
  iniciar_audio(false);
  screen_init(1,A5200_WIDTH,A5200_HEIGHT);
  iniciar_video(A5200_WIDTH,A5200_HEIGHT);
  //CPU
  m6502_0:=cpu_m6502.create(A5200_CLOCK,TCPU_M6502);
  m6502_0.change_ram_calls(a5200_read,a5200_write);
  m6502_0.change_bus_cycle(cpu_cycle);
  m6502_0.init_sound(sound_update);
  //Sound
  pokey_0:=pokey_chip.create(A5200_CLOCK);
  pokey_0.set_external_clock(true);
  pokey_0.set_resampling(true);
  pokey_0.change_pot(pot_read,pot_read,pot_read,pot_read,pot_read,pot_read,pot_read,pot_read);
  fillchar(cartridge[0],sizeof(cartridge),$ff);
  init_analog(m6502_0.numero_cpu,A5200_CLOCK);
  analog_0(100,4,114,228,0,true,false,true,true);
  for f:=0 to 7 do a5200_axis_override[f]:=-1;
  for f:=0 to 3 do begin
    a5200_keypad[f]:=$ff;
    a5200_buttons_override[f]:=-1;
  end;
  a5200_video_init(a5200_read,video_nmi);
  if main_vars.console_init then abrir_atari5200;
  result:=true;
end;

end.
