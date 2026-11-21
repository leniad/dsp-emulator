unit atari7800;

interface

function iniciar_atari7800:boolean;

implementation
uses atari7800_video,sysutils,Dialogs,m6502,cpu_misc,main_engine,
     controls_engine,sound_engine,timer_engine,pal_engine,gfx_engine,pokey,
     misc_functions,file_engine,atari2600_audio,atari_riot,principal;

const MAX_ROM=$100000;

var
  a7800_last_error:string='';
  a7800_gun_offset_x:integer=11;
  a7800_gun_offset_y:integer=-11;
  ram:array[0..$fff]of byte;
  cart_ram:array[0..$3fff] of byte;
  rom:array[0..MAX_ROM-1] of byte;
  cart_size,cart_bank,cart_banks,mapper,fixed4000:integer;
  cart_has_ram,pal_mode,in_bus,in_dma:boolean;
  master_clock:cardinal;
  master_phase,riot_phase,extra_phase:integer;
  pokey_address:integer;
  control:byte;
  last_switch:array[0..1] of boolean;
  switches:byte=$ff;
  cart_controller:array[0..1] of byte;
  gun_armed:array[0..1] of boolean;

procedure update_inputs;
var
  p,shift:integer;
  input:byte;
begin
 input:=$ff;
 for p:=0 to 1 do begin
    shift:=(1-p)*4;
    if cart_controller[p]=3 then begin
        // The XG-1 trigger uses pin 1 (UP), high when pressed.
        // Wait for release after loading/reset, so a menu click cannot select joystick mode.
        if p=0 then begin
          if not raton.button1 then gun_armed[p]:=true;
          if not(gun_armed[p] and raton.button1) then input:=input and not(1 shl shift);
        end else begin
          if not raton.button2 then gun_armed[p]:=true;
          if not(gun_armed[p] and raton.button2) then input:=input and not(1 shl shift);
        end;
        continue;
    end;
    if arcade_input.up[p] then input:=input and not(1 shl shift);
    if arcade_input.down[p] then input:=input and not(2 shl shift);
    if arcade_input.left[p] then input:=input and not(4 shl shift);
    if arcade_input.right[p] then input:=input and not(8 shl shift);
 end;
 if keyboard[KEYBOARD_4] and not last_switch[0] then switches:=switches xor $40;
 if keyboard[KEYBOARD_5] and not last_switch[1] then switches:=switches xor $80;
 last_switch[0]:=keyboard[KEYBOARD_4];
 last_switch[1]:=keyboard[KEYBOARD_5];
 riot_0.input_b:=switches or $b;
 if keyboard[KEYBOARD_1] or keyboard[KEYBOARD_RETURN] then riot_0.input_b:=riot_0.input_b and $fe;
 if keyboard[KEYBOARD_2] then riot_0.input_b:=riot_0.input_b and $fd;
 if keyboard[KEYBOARD_3] then riot_0.input_b:=riot_0.input_b and $f7;
 riot_0.input_a:=input;
end;

procedure clock_master;
begin
 if a7800_video.clock=0 then update_inputs;
 a7800_video_tick;
 master_phase:=(master_phase+1)mod 4;
 if(master_phase=0)and(pokey_address<>0)then pokey_0.clock;
 if(master_phase and 1)=0 then tia_audio_tick;
 inc(riot_phase);
 if riot_phase=6 then begin
  riot_phase:=0;
  riot_0.tick;
 end;
end;

procedure wait_master(count:integer;account:boolean);
var
  i:integer;
begin
 for i:=1 to count do begin
  clock_master;
  if account then begin
    inc(extra_phase);
    if extra_phase=4 then begin
      extra_phase:=0;
      inc(m6502_0.contador);
    end;
  end;
 end;
end;

procedure slow_access(address:word);
begin
 if in_bus and not in_dma and(address<$400) and (((address and $e0)=0) or ((address and $280)=$280)) then wait_master(2,true);
end;

function cart_read(address:word):byte;
var
  n,bank:integer;
begin
 result:=$ff;
 if cart_size=0 then exit;
 if mapper=3 then begin
  if address<$8000 then n:=cart_bank*$4000+(address and $3fff)
   else n:=integer(address);
  result:=rom[n];exit;
 end;
 if mapper=2 then begin
  // Activision: four fixed 8 KB slices surround the banked $a000-$dfff window.
  if address<$6000 then n:=$1a000+(address and $1fff)
   else if address<$8000 then n:=$18000+(address and $1fff)
   else if address<$a000 then n:=$1e000+(address and $1fff)
   else if address<$e000 then n:=cart_bank*$4000+integer(address)-$a000
   else n:=$1c000+(address and $1fff);
  result:=rom[n];exit;
 end;
 if mapper=0 then begin
  n:=integer(address)-(65536-cart_size);
  if(n>=0) and (n<cart_size) then result:=rom[n];
 end else begin
  if address<$4000 then exit;
  if address<$8000 then begin
   if cart_has_ram then begin
    result:=cart_ram[address and $3fff];
    exit;
   end;
   if fixed4000<0 then exit;
   bank:=fixed4000;
  end else if address<$c000 then bank:=cart_bank
              else bank:=cart_banks-1;
  n:=bank*$4000+(address and $3fff);
  if(n>=0) and (n<cart_size) then result:=rom[n];
 end;
end;

function lightgun_sensor:byte;
var x,y,target_line,target_clock:integer;
begin
 result:=$80;
 if not event.emouse then exit;
 x:=raton.x;y:=raton.y;
 // controls_engine already converts window coordinates into the 320x288 virtual image.
 if(x<0)or(x>=A78_WIDTH)or(y<0)or(y>=A78_HEIGHT)then exit;
 target_line:=y+17;
 if not pal_mode then dec(target_line,24);
 if(target_line<26)or((not pal_mode)and(target_line>248))or
   (pal_mode and(target_line>297))then exit;
 // Apply one virtual-screen calibration to both ports and all cartridges.
 inc(x,a7800_gun_offset_x);
 if x<0 then x:=0 else if x>=A78_WIDTH then x:=A78_WIDTH-1;
 inc(target_line,a7800_gun_offset_y);
 if target_line<26 then target_line:=26;
 if pal_mode then begin
  if target_line>297 then target_line:=297;
 end else if target_line>248 then target_line:=248;
 // Include the XG-1 response delay used by the lightgun software.
 target_clock:=A78_HBLANK_CLOCKS+52+x;
 if target_clock>=A78_LINE_CLOCKS then begin
  dec(target_clock,A78_LINE_CLOCKS);inc(target_line);
 end;
 // Keep the response available during the nine fine-position samples of XG-1 software.
 // This remains an approximate photodiode model, independent of the trigger.
 if(a7800_video.line>=target_line)and(a7800_video.line<=target_line+10)and
   (a7800_video.clock>=target_clock)then result:=0;
end;

function tia_input(reg:byte):byte;
var
  player:integer;
  one_button,pressed:boolean;b:byte;
begin
 result:=$ff;
 if (reg<8) or (reg>13) then exit;
 b:=((riot_0.portb and riot_0.ddrb)or not riot_0.ddrb) and riot_0.input_b;
 if reg>=12 then begin
  player:=reg-12;
  if cart_controller[player]=3 then begin
    result:=lightgun_sensor;
    exit;
  end;
  one_button:=(b and (4 shl (player*2)))<>0;
  pressed:=one_button and (arcade_input.but0[player] or arcade_input.but1[player]);
  if pressed then result:=0
    else result:=$80;
 end else begin
  player:=(reg-8)shr 1;
  if cart_controller[player]=3 then begin
    result:=0;
    exit;
  end;
  one_button:=(b and (4 shl (player*2)))<>0;
  if one_button then result:=0
    else begin
          if Odd(reg) then pressed:=arcade_input.but0[player]
            else pressed:=arcade_input.but1[player];
          if pressed then result:=$80
            else result:=0;
         end;
 end;
end;

function a7800_read(address:word):byte;
begin
 slow_access(address);
 if (pokey_address<>0) and (address>=pokey_address) and (address<pokey_address+16) then begin
  result:=pokey_0.read(address-pokey_address);
  exit;
 end;
 if address>=$4000 then begin
  result:=cart_read(address);
  exit;
 end;
 if(address and $ffe0)=$0280 then begin
  result:=riot_0.read(address and 31);
  exit;
 end;
 if(address<$0400)and((address and $e0)=$20)then begin
  result:=a7800_maria_read(address and 31);
  exit;
 end;
 if(address<$0400)and((address and $e0)=0)then begin
  result:=tia_input(address and 15);
  exit;
 end;
 if(address<$0400)then begin
  result:=ram[address and $3ff];
  exit;
 end;
 // $2800/$3000/$3800 repeat the $2000-$27ff RAM chip, not $1800.
 if address>=$2000 then begin
  result:=ram[address and $7ff];
  exit;
 end;
 if address>=$1800 then begin
  result:=ram[address and $fff];
  exit;
 end;
 result:=$ff;
end;

procedure a7800_write(address:word;value:byte);
begin
 slow_access(address);
 if(pokey_address<>0)and(address>=pokey_address)and(address<pokey_address+16)then begin pokey_0.write(address-pokey_address,value);exit;end;
 if address>=$4000 then begin
  if mapper=3 then begin
   if(address=$8000)and((value=1)or(value=2))then cart_bank:=value-1;
  end else if mapper=2 then begin
   if address>=$ff80 then cart_bank:=address and 7;
  end else if mapper=1 then begin
   if(address<$8000)and cart_has_ram then cart_ram[address and $3fff]:=value
   else if(address>=$8000)and(address<$c000)then begin
    if cart_banks=9 then cart_bank:=1+(value and 7)else cart_bank:=value mod cart_banks;
   end;
  end;exit;
 end;
 if(address and $ffe0)=$0280 then begin riot_0.write(address and 31,value);exit;end;
 if(address<$0400)and((address and $e0)=$20)then begin a7800_maria_write(address and 31,value);exit;end;
 if(address<$0400)and((address and $e0)=0)then begin
  // Direct cartridge boot starts with the 7800 latch locked; TIA video is separate.
  if(address and 31)=$01 then begin if(control and 1)=0 then control:=value;end
  else if(address and 31)in[$15..$1a]then tia_audio_write(address and 31,value);
  exit;
 end;
 if address<$0400 then begin ram[address and $3ff]:=value;exit;end;
 if address>=$2000 then ram[address and $7ff]:=value
  else if address>=$1800 then ram[address and $fff]:=value;
end;

function dma_read(address:word):byte;
begin
  in_dma:=true;
  result:=a7800_read(address);
  in_dma:=false;
end;

procedure maria_nmi;
begin
  m6502_0.change_nmi(PULSE_LINE);
end;

procedure a7800_audio_sample;
begin
 if pokey_address<>0 then pokey_0.update;
end;

procedure sound_marker;
begin
end;

procedure reset_atari7800;
var i:integer;
begin
 FillChar(ram,SizeOf(ram),0);
 FillChar(cart_ram,SizeOf(cart_ram),0);
 FillChar(gun_armed,SizeOf(gun_armed),0);
 riot_0.reset;
 cart_bank:=0;
 if cart_banks=9 then cart_bank:=1;
 control:=7;
 master_phase:=0;
 riot_phase:=0;
 extra_phase:=0;
 in_bus:=false;
 in_dma:=false;
 a7800_video_reset(pal_mode);
 //tia_audio.color_clock:=master_clock div 2;
 tia_audio_reset;
 reset_audio;
 pokey_0.reset;
 m6502_0.reset;
 for i:=1 to 28 do clock_master;
end;

procedure cpu_cycle(is_read:boolean);
begin
 in_bus:=true;
 while a7800_video_blocked(is_read) do wait_master(1,true);
 wait_master(4,false);
end;

procedure palette_init;
const
  ntsc:array[0..767]of byte=(
    $00,$00,$00,$14,$14,$14,$29,$29,$29,$3D,$3D,$3D,
    $52,$52,$52,$66,$66,$66,$7A,$7A,$7A,$8F,$8F,$8F,
    $A3,$A3,$A3,$B8,$B8,$B8,$CC,$CC,$CC,$E0,$E0,$E0,
    $F5,$F5,$F5,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,
    $18,$11,$00,$2C,$25,$00,$41,$3A,$00,$55,$4E,$00,
    $6A,$62,$00,$7E,$77,$00,$92,$8B,$00,$A7,$A0,$00,
    $BB,$B4,$0E,$D0,$C8,$22,$E4,$DD,$37,$F8,$F1,$4B,
    $FF,$FF,$5F,$FF,$FF,$74,$FF,$FF,$88,$FF,$FF,$9D,
    $3B,$00,$00,$50,$0C,$00,$64,$21,$00,$79,$35,$00,
    $8D,$49,$00,$A1,$5E,$00,$B6,$72,$09,$CA,$87,$1D,
    $DF,$9B,$31,$F3,$AF,$46,$FF,$C4,$5A,$FF,$D8,$6F,
    $FF,$ED,$83,$FF,$FF,$97,$FF,$FF,$AC,$FF,$FF,$C0,
    $52,$00,$00,$66,$00,$00,$7B,$09,$00,$8F,$1E,$08,
    $A4,$32,$1C,$B8,$47,$31,$CC,$5B,$45,$E1,$6F,$5A,
    $F5,$84,$6E,$FF,$98,$82,$FF,$AD,$97,$FF,$C1,$AB,
    $FF,$D5,$C0,$FF,$EA,$D4,$FF,$FE,$E8,$FF,$FF,$FD,
    $57,$00,$13,$6B,$00,$27,$7F,$00,$3C,$94,$0D,$50,
    $A8,$22,$65,$BD,$36,$79,$D1,$4B,$8D,$E5,$5F,$A2,
    $FA,$73,$B6,$FF,$88,$CB,$FF,$9C,$DF,$FF,$B1,$F3,
    $FF,$C5,$FF,$FF,$D9,$FF,$FF,$EE,$FF,$FF,$FF,$FF,
    $48,$00,$57,$5D,$00,$6B,$71,$00,$80,$86,$08,$94,
    $9A,$1C,$A9,$AE,$30,$BD,$C3,$45,$D1,$D7,$59,$E6,
    $EC,$6E,$FA,$FF,$82,$FF,$FF,$96,$FF,$FF,$AB,$FF,
    $FF,$BF,$FF,$FF,$D4,$FF,$FF,$E8,$FF,$FF,$FC,$FF,
    $2A,$00,$88,$3F,$00,$9C,$53,$00,$B1,$67,$0D,$C5,
    $7C,$22,$DA,$90,$36,$EE,$A5,$4A,$FF,$B9,$5F,$FF,
    $CD,$73,$FF,$E2,$88,$FF,$F6,$9C,$FF,$FF,$B0,$FF,
    $FF,$C5,$FF,$FF,$D9,$FF,$FF,$EE,$FF,$FF,$FF,$FF,
    $03,$00,$9B,$17,$00,$B0,$2C,$09,$C4,$40,$1D,$D9,
    $55,$32,$ED,$69,$46,$FF,$7D,$5B,$FF,$92,$6F,$FF,
    $A6,$83,$FF,$BB,$98,$FF,$CF,$AC,$FF,$E3,$C1,$FF,
    $F8,$D5,$FF,$FF,$E9,$FF,$FF,$FE,$FF,$FF,$FF,$FF,
    $00,$00,$8D,$00,$0C,$A1,$04,$20,$B6,$18,$35,$CA,
    $2D,$49,$DE,$41,$5D,$F3,$56,$72,$FF,$6A,$86,$FF,
    $7E,$9B,$FF,$93,$AF,$FF,$A7,$C3,$FF,$BC,$D8,$FF,
    $D0,$EC,$FF,$E4,$FF,$FF,$F9,$FF,$FF,$FF,$FF,$FF,
    $00,$10,$60,$00,$25,$74,$00,$39,$89,$00,$4E,$9D,
    $0D,$62,$B1,$21,$76,$C6,$36,$8B,$DA,$4A,$9F,$EF,
    $5E,$B4,$FF,$73,$C8,$FF,$87,$DC,$FF,$9C,$F1,$FF,
    $B0,$FF,$FF,$C4,$FF,$FF,$D9,$FF,$FF,$ED,$FF,$FF,
    $00,$26,$1E,$00,$3A,$32,$00,$4F,$46,$00,$63,$5B,
    $00,$77,$6F,$10,$8C,$84,$25,$A0,$98,$39,$B5,$AC,
    $4E,$C9,$C1,$62,$DD,$D5,$76,$F2,$EA,$8B,$FF,$FE,
    $9F,$FF,$FF,$B4,$FF,$FF,$C8,$FF,$FF,$DC,$FF,$FF,
    $00,$33,$00,$00,$47,$00,$00,$5C,$00,$00,$70,$12,
    $00,$85,$27,$12,$99,$3B,$27,$AD,$50,$3B,$C2,$64,
    $4F,$D6,$78,$64,$EB,$8D,$78,$FF,$A1,$8D,$FF,$B6,
    $A1,$FF,$CA,$B5,$FF,$DE,$CA,$FF,$F3,$DE,$FF,$FF,
    $00,$35,$00,$00,$49,$00,$00,$5E,$00,$00,$72,$00,
    $12,$87,$00,$26,$9B,$00,$3B,$AF,$10,$4F,$C4,$25,
    $63,$D8,$39,$78,$ED,$4E,$8C,$FF,$62,$A1,$FF,$76,
    $B5,$FF,$8B,$C9,$FF,$9F,$DE,$FF,$B4,$F2,$FF,$C8,
    $00,$2C,$00,$00,$40,$00,$0B,$54,$00,$1F,$69,$00,
    $34,$7D,$00,$48,$92,$00,$5D,$A6,$00,$71,$BA,$00,
    $85,$CF,$11,$9A,$E3,$26,$AE,$F8,$3A,$C3,$FF,$4E,
    $D7,$FF,$63,$EB,$FF,$77,$FF,$FF,$8C,$FF,$FF,$A0,
    $0B,$19,$00,$1F,$2D,$00,$33,$41,$00,$48,$56,$00,
    $5C,$6A,$00,$71,$7F,$00,$85,$93,$00,$99,$A7,$00,
    $AE,$BC,$09,$C2,$D0,$1D,$D7,$E5,$32,$EB,$F9,$46,
    $FF,$FF,$5B,$FF,$FF,$6F,$FF,$FF,$83,$FF,$FF,$98,
    $31,$00,$00,$45,$15,$00,$5A,$29,$00,$6E,$3D,$00,
    $82,$52,$00,$97,$66,$00,$AB,$7B,$00,$C0,$8F,$0E,
    $D4,$A3,$22,$E8,$B8,$37,$FD,$CC,$4B,$FF,$E1,$60,
    $FF,$F5,$74,$FF,$FF,$88,$FF,$FF,$9D,$FF,$FF,$B1);
  pal:array[0..767]of byte=(
    $00,$00,$00,$1C,$1C,$1C,$39,$39,$39,$59,$59,$59,
    $79,$79,$79,$92,$92,$92,$AB,$AB,$AB,$BC,$BC,$BC,
    $CD,$CD,$CD,$D9,$D9,$D9,$E6,$E6,$E6,$EC,$EC,$EC,
    $F2,$F2,$F2,$F8,$F8,$F8,$FF,$FF,$FF,$FF,$FF,$FF,
    $26,$30,$01,$24,$38,$03,$23,$40,$05,$51,$54,$1B,
    $80,$69,$31,$97,$81,$35,$AF,$99,$3A,$C2,$A7,$3E,
    $D5,$B5,$43,$DB,$C0,$3D,$E1,$CB,$38,$E2,$D8,$36,
    $E3,$E5,$34,$EF,$F2,$58,$FB,$FF,$7D,$FB,$FF,$7D,
    $39,$17,$01,$5E,$23,$04,$83,$30,$08,$A5,$47,$16,
    $C8,$5F,$24,$E3,$78,$20,$FF,$91,$1D,$FF,$AB,$1D,
    $FF,$C5,$1D,$FF,$CE,$34,$FF,$D8,$4C,$FF,$E6,$51,
    $FF,$F4,$56,$FF,$F9,$77,$FF,$FF,$98,$FF,$FF,$98,
    $45,$19,$04,$72,$1E,$11,$9F,$24,$1E,$B3,$3A,$20,
    $C8,$51,$22,$E3,$69,$20,$FF,$81,$1E,$FF,$8C,$25,
    $FF,$98,$2C,$FF,$AE,$38,$FF,$C5,$45,$FF,$C5,$59,
    $FF,$C6,$6D,$FF,$D5,$87,$FF,$E4,$A1,$FF,$E4,$A1,
    $4A,$17,$04,$7E,$1A,$0D,$B2,$1D,$17,$C8,$21,$19,
    $DF,$25,$1C,$EC,$3B,$38,$FA,$52,$55,$FC,$61,$61,
    $FF,$70,$6E,$FF,$7F,$7E,$FF,$8F,$8F,$FF,$9D,$9E,
    $FF,$AB,$AD,$FF,$B9,$BD,$FF,$C7,$CE,$FF,$C7,$CE,
    $05,$05,$68,$3B,$13,$6D,$71,$22,$72,$8B,$2A,$8C,
    $A5,$32,$A6,$B9,$38,$BA,$CD,$3E,$CF,$DB,$47,$DD,
    $EA,$51,$EB,$F4,$5F,$F5,$FE,$6D,$FF,$FE,$7A,$FD,
    $FF,$87,$FB,$FF,$95,$FD,$FF,$A4,$FF,$FF,$A4,$FF,
    $28,$04,$79,$40,$09,$84,$59,$0F,$90,$70,$24,$9D,
    $88,$39,$AA,$A4,$41,$C3,$C0,$4A,$DC,$D0,$54,$ED,
    $E0,$5E,$FF,$E9,$6D,$FF,$F2,$7C,$FF,$F8,$8A,$FF,
    $FF,$98,$FF,$FE,$A1,$FF,$FE,$AB,$FF,$FE,$AB,$FF,
    $35,$08,$8A,$42,$0A,$AD,$50,$0C,$D0,$64,$28,$D0,
    $79,$45,$D0,$8D,$4B,$D4,$A2,$51,$D9,$B0,$58,$EC,
    $BE,$60,$FF,$C5,$6B,$FF,$CC,$77,$FF,$D1,$83,$FF,
    $D7,$90,$FF,$DB,$9D,$FF,$DF,$AA,$FF,$DF,$AA,$FF,
    $05,$1E,$81,$06,$26,$A5,$08,$2F,$CA,$26,$3D,$D4,
    $44,$4C,$DE,$4F,$5A,$EE,$5A,$68,$FF,$65,$75,$FF,
    $71,$83,$FF,$80,$91,$FF,$90,$A0,$FF,$97,$A9,$FF,
    $9F,$B2,$FF,$AF,$BE,$FF,$C0,$CB,$FF,$C0,$CB,$FF,
    $05,$1E,$81,$06,$26,$A5,$08,$2F,$CA,$26,$3D,$D4,
    $44,$4C,$DE,$4F,$5A,$EE,$5A,$68,$FF,$65,$75,$FF,
    $71,$83,$FF,$80,$91,$FF,$90,$A0,$FF,$97,$A9,$FF,
    $9F,$B2,$FF,$AF,$BE,$FF,$C0,$CB,$FF,$C0,$CB,$FF,
    $0C,$04,$8B,$22,$18,$A0,$38,$2D,$B5,$48,$3E,$C7,
    $58,$4F,$DA,$61,$59,$EC,$6B,$64,$FF,$7A,$74,$FF,
    $8A,$84,$FF,$91,$8E,$FF,$99,$98,$FF,$A5,$A3,$FF,
    $B1,$AE,$FF,$B8,$B8,$FF,$C0,$C2,$FF,$C0,$C2,$FF,
    $1D,$29,$5A,$1D,$38,$76,$1D,$48,$92,$1C,$5C,$AC,
    $1C,$71,$C6,$32,$86,$CF,$48,$9B,$D9,$4E,$A8,$EC,
    $55,$B6,$FF,$70,$C7,$FF,$8C,$D8,$FF,$93,$DB,$FF,
    $9B,$DF,$FF,$AF,$E4,$FF,$C3,$E9,$FF,$C3,$E9,$FF,
    $2F,$43,$02,$39,$52,$02,$44,$61,$03,$41,$7A,$12,
    $3E,$94,$21,$4A,$9F,$2E,$57,$AB,$3B,$5C,$BD,$55,
    $61,$D0,$70,$69,$E2,$7A,$72,$F5,$84,$7C,$FA,$8D,
    $87,$FF,$97,$9A,$FF,$A6,$AD,$FF,$B6,$AD,$FF,$B6,
    $0A,$41,$08,$0D,$54,$0A,$10,$68,$0D,$13,$7D,$0F,
    $16,$92,$12,$19,$A5,$14,$1C,$B9,$17,$1E,$C9,$19,
    $21,$D9,$1B,$47,$E4,$2D,$6E,$F0,$40,$78,$F7,$4D,
    $83,$FF,$5B,$9A,$FF,$7A,$B2,$FF,$9A,$B2,$FF,$9A,
    $04,$41,$0B,$05,$53,$0E,$06,$66,$11,$07,$77,$14,
    $08,$88,$17,$09,$9B,$1A,$0B,$AF,$1D,$48,$C4,$1F,
    $86,$D9,$22,$8F,$E9,$24,$99,$F9,$27,$A8,$FC,$41,
    $B7,$FF,$5B,$C9,$FF,$6E,$DC,$FF,$81,$DC,$FF,$81,
    $02,$35,$0F,$07,$3F,$15,$0C,$4A,$1C,$2D,$5F,$1E,
    $4F,$74,$20,$59,$83,$24,$64,$92,$28,$82,$A1,$2E,
    $A1,$B0,$34,$A9,$C1,$3A,$B2,$D2,$41,$C4,$D9,$45,
    $D6,$E1,$49,$E4,$F0,$4E,$F2,$FF,$53,$F2,$FF,$53);
var i:integer;c:tcolor;
begin
 for i:=0 to 255 do begin
  if pal_mode then begin
    c.r:=pal[i*3];
    c.g:=pal[i*3+1];
    c.b:=pal[i*3+2];
  end else begin
    c.r:=ntsc[i*3];
    c.g:=ntsc[i*3+1];
    c.b:=ntsc[i*3+2];
  end;
  set_pal_color(c,i);
 end;
end;

procedure a7800_run_frame;
begin
 frame_main:=a7800_video.frame_number;
 if cart_size=0 then repeat
    clock_master;
    until a7800_video.frame_number<>frame_main
 else repeat
  m6502_0.run(1);
  until a7800_video.frame_number<>frame_main;
end;

procedure atari7800_main;
begin
 while EmuStatus=EsRunning do begin
  a7800_run_frame;
  a7800_video_present;
  video_sync;
 end;
end;

function a7800_load_cartridge(data:pbyte;size:integer):boolean;
var
  p,n,i,flags,v4opt,new_mapper,new_pokey,new_fixed:integer;
  new_pal,new_ram:boolean;
  new_controller:array[0..1]of byte;
  bytes:array of byte;
  crc32:cardinal;
begin
 result:=false;
 a7800_last_error:='';
 p:=0;
 flags:=0;
 new_pal:=false;
 new_mapper:=0;
 new_pokey:=0;
 new_fixed:=-1;
 new_controller[0]:=1;
 new_controller[1]:=1;
 if (data=nil) or (size<=0) or (size>MAX_ROM+128) then begin
  a7800_last_error:='Longitud de cartucho no valida';
  exit;
 end;
 if (size>=128) and (data[1]=Ord('A')) and (data[2]=Ord('T') )and (data[3]=Ord('A')) and (data[4]=Ord('R')) and (data[5]=Ord('I')) and (data[6]=Ord('7')) and (data[7]=Ord('8')) and (data[8]=Ord('0')) and (data[9]=Ord('0')) then begin
  p:=128;
  n:=(integer(data[49]) shl 24) or (integer(data[50]) shl 16) or (integer(data[51]) shl 8) or data[52];
  if n<>size-128 then begin
    a7800_last_error:='La longitud declarada en A78 no coincide';
    exit;
  end;
  if (data[0]<1) or (data[0]>4) then begin
    a7800_last_error:='Version de cabecera A78 no implementada';
    exit;
  end;
  new_controller[0]:=data[55];
  new_controller[1]:=data[56];
  if (data[0]<4) and (n=$20000) then
   case calc_crc(@data[p],n) of
    $2FDDAD78,$4A8F2171:begin
     new_controller[0]:=3;
     new_controller[1]:=3;
    end;
   end;
  if not(new_controller[0]in[0,1,3]) or not(new_controller[1]in[0,1,3]) then begin
    a7800_last_error:='Este cartucho necesita un mando no implementado';
    exit;
  end;
  flags:=(integer(data[53]) shl 8)or data[54];
  new_pal:=(data[57] and 1)<>0;
  if data[0]>=4 then begin
   if data[64]>3 then begin
    a7800_last_error:='Mapper A78 v4 todavia no implementado';
    exit;
   end;
   new_mapper:=data[64];
   v4opt:=data[65];
   if (v4opt and $80)<>0 then begin
    a7800_last_error:='Banksets todavia no implementado';
    exit;
   end;
   flags:=0;
   if new_mapper=1 then flags:=2;
   if (new_mapper=2) or (new_mapper=3) then begin
    if new_mapper=2 then flags:=$100
      else flags:=$200;
    if v4opt<>0 then begin
     a7800_last_error:='Opcion de mapper especial no implementada';exit;
    end;
   end else if new_mapper=0 then begin
    if(v4opt and 3)=1 then flags:=flags or 4
      else if(v4opt and 3)<>0 then begin
        a7800_last_error:='EXRAM no implementada';
        exit;
      end;
   end else case v4opt and 7 of
    0:;
    1:flags:=flags or 4;
    4:flags:=flags or 8;
    5:flags:=flags or 16;
    else begin
            a7800_last_error:='Opcion SuperGame no implementada';
            exit;
         end;
   end;
   i:=(integer(data[66]) shl 8) or data[67];
   if (i and not 7)<>0 then begin
    a7800_last_error:='Audio adicional no implementado';
    exit;
   end;
   case i and 7 of
    0:;
    1:flags:=flags or $400;
    2:flags:=flags or $40;
    4:flags:=flags or $8000;
    5:flags:=flags or 1;
    else begin
      a7800_last_error:='Doble POKEY no implementado';
      exit;
    end;
   end;
   if (data[68] or data[69])<>0 then begin
      a7800_last_error:='IRQ de cartucho no implementada';
      exit;
   end;
  end;
 end;
 n:=size-p;
 // Old A78 headers: fixed-bank SuperGame or Activision hardware omitted.
 // Match the payload, not the title, and keep explicit/v4 mapper options intact.
 crc32:=calc_crc(@data[p],n);
 if (p=128) and (n=$20000) and (crc32=$ED0A587D) then begin
  new_controller[0]:=3;
  flags:=flags and not 1;
 end;
 if (p=128) and (data[0]<4) and (flags=2) and (n=$20000) then
  case crc32 of
   $05A2B94C,$C8B9D7B5,$A44DF354,$720EBC74,$ABA91829,
   $CF21D9AC,$187EC84E,$1E219482,$CB48E8DC,$4E3B9E64,
   $5CC8C34F,$5FD9A141,$AAE12695,$F26621E3,$2FDDAD78,$4A8F2171:flags:=flags or $10; // Fixed bank 6, NTSC.
   $65C6DF3F,$8981B531:flags:=6; // Summer Games / Winter Games: SuperGame with 16 KiB RAM.
   $AA265865,$39A316AA:flags:=$100; // Double Dragon / Rampage NTSC, mislabeled as SuperGame.
   $CD1A98C5:flags:=3;
  end;
 // Impossible Mission NTSC: this old header incorrectly declares Activision/POKEY/PAL.
 if (p=128) and (data[0]<4) and (flags=$502) and (n=$20000) then
  case crc32 of
    $3B1F2F47,$B4347510,$7A545A56:begin
                flags:=6;
                new_pal:=false;
              end;
  end;
 // F-18 Hornet has an old conflicting $0300 header; identify only this payload.
 if (p=128) and (data[0]<4) and (flags=$300) and (n=$10000) then
  if calc_crc(@data[p],n)=$63D1C7C1 then flags:=$200;
 if (flags and not($01 or $02 or $04 or $08 or $10 or $40 or $100 or $200 or $400 or $8000))<>0 then begin
  a7800_last_error:='Hardware de cartucho no implementado';
  exit;
 end;
 if(flags and 2)<>0 then new_mapper:=1;
 if(flags and $100)<>0 then new_mapper:=2;
 if(flags and $200)<>0 then new_mapper:=3;
 new_ram:=(flags and 4)<>0;
 if(flags and 1)<>0 then new_pokey:=$4000;
 if(flags and $40)<>0 then begin
  if new_pokey<>0 then begin
    a7800_last_error:='Doble POKEY no implementado';
    exit;
  end;
 new_pokey:=$450;
end;
 if(flags and $400)<>0 then begin
  if new_pokey<>0 then begin
    a7800_last_error:='Doble POKEY no implementado';
    exit;
  end;
  new_pokey:=$440;
 end;
 if(flags and $8000)<>0 then begin
  if new_pokey<>0 then begin
    a7800_last_error:='Doble POKEY no implementado';
    exit;
  end;
  new_pokey:=$800;
 end;
 if new_mapper=3 then begin
  if (n<>$10000) or ((flags and not($200 or 2))<>0) then begin
   a7800_last_error:='Absolute requiere 64 KB sin hardware adicional';
   exit;
  end;
 end else if new_mapper=2 then begin
  if (n<>$20000) or ((flags and not($100 or 2))<>0) then begin
   a7800_last_error:='Activision requiere 128 KB sin hardware adicional';
   exit;
  end;
 end else if new_mapper=0 then begin
  if ((n<>8192) and (n<>16384) and (n<>32768) and (n<>49152)) then begin
    a7800_last_error:='ROM lineal: se admiten 8, 16, 32 o 48 KB';
    exit;
  end;
  if new_ram then begin
    a7800_last_error:='RAM de cartucho lineal aun no implementada';
    exit;
  end;
 end else begin
  if (n mod $4000<>0) or (n<$8000) then begin
    a7800_last_error:='Longitud SuperGame no valida';
    exit;
  end;
  i:=n div $4000;
  if (i<>9) and ((i and(i-1))<>0) then begin
    a7800_last_error:='Numero de bancos no implementado';
    exit;
  end;
  if (flags and $10)<>0 then new_fixed:=6
    else if (flags and 8)<>0 then new_fixed:=0;
  if i=9 then new_fixed:=0;
  if new_fixed>=i then begin
    a7800_last_error:='Banco fijo fuera de la ROM';
    exit;
  end;
  if new_ram and (new_fixed>=0) then begin
    a7800_last_error:='RAM y ROM superpuestas en $4000';
    exit;
  end;
 end;
 SetLength(bytes,n);
 for i:=0 to n-1 do bytes[i]:=data[p+i];
 // This CC2 image stores the fixed first bank at the end of the payload.
 // Restore standard 9-bank SuperGame order before mapping any CPU/DMA reads.
 if (n=$24000) and (crc32=$E56C0CFD) then begin
  copymemory(@rom[0],@bytes[n-$4000],$4000);
  copymemory(@rom[$4000],@bytes[0],n-$4000);
 end else copymemory(@rom,bytes,n);
 cart_size:=n;
 cart_banks:=n div $4000;
 mapper:=new_mapper;
 pal_mode:=new_pal;
 pokey_address:=new_pokey;
 cart_has_ram:=new_ram;
 fixed4000:=new_fixed;
 cart_controller[0]:=new_controller[0];
 cart_controller[1]:=new_controller[1];
 init_mouse((cart_controller[0]=3) or (cart_controller[1]=3));
 if pal_mode then master_clock:=A78_MASTER_PAL
  else master_clock:=A78_MASTER_NTSC;
 llamadas_maquina.fps_max:=master_clock/A78_LINE_CLOCKS/(A78_LINES_NTSC+byte(pal_mode)*50);
 llamadas_maquina.scanlines:=A78_LINES_NTSC+byte(pal_mode)*50;
 // Existing CPU/timer frequency changes are less than 1%; physical devices use master_clock.
 m6502_0.clock:=master_clock div 4;
 sound_status.cpu_clock:=master_clock div 4;
 palette_init;
 result:=true;
end;

procedure abrir_atari7800;
var
  extension,nombre_file,RomFile:string;
  datos:pbyte;
  longitud:integer;
begin
  if not(openrom(romfile,SATARI7800)) then exit;
  read_file_size(romfile,longitud);
  if (longitud<=0) or (longitud>MAX_ROM) then exit;
  getmem(datos,MAX_ROM);
  if not(extract_data(romfile,datos,longitud,nombre_file,SATARI7800)) then begin
    freemem(datos);
    exit;
  end;
  extension:=extension_fichero(nombre_file);
  if ((extension='A78') or (extension='BIN') or (extension='CAR')) then begin
          if a7800_load_cartridge(datos,longitud) then reset_atari7800
            else MessageDlg(a7800_last_error,mtError,[mbOk],0);
         end;
  freemem(datos);
  main_vars.nombre_caption:=nombre_file;
  change_caption;
  directory.atari7800:=ExtractFilePath(romfile);
end;

function iniciar_atari7800:boolean;
begin
 result:=false;
 principal1.BitBtn10.Glyph:=nil;
 principal1.imagelist2.GetBitmap(4,principal1.BitBtn10.Glyph);
 master_clock:=A78_MASTER_NTSC;
 pal_mode:=false;
 cart_size:=0;
 cart_controller[0]:=1;
 cart_controller[1]:=1;
 llamadas_maquina.fps_max:=master_clock/A78_LINE_CLOCKS/A78_LINES_NTSC;
 llamadas_maquina.scanlines:=A78_LINES_NTSC;
 iniciar_audio(false);
 m6502_0:=cpu_m6502.Create(master_clock div 4,TCPU_M6502);
 m6502_0.change_ram_calls(a7800_read,a7800_write);
 m6502_0.change_bus_cycle(cpu_cycle);
 m6502_0.init_sound(sound_marker);
 riot_0:=tatari_riot.create;
 timers.enabled(sound_engine_timer,false); // TIA advances the shared PCM write position.
 tia_audio_init(master_clock div 2,true);
 pokey_0:=pokey_chip.Create(master_clock div 4);
 pokey_0.set_external_clock(true);
 pokey_0.set_resampling(false);
 pokey_address:=0;
 tia_audio_set_sample_callback(a7800_audio_sample);
 a7800_video_init(dma_read,maria_nmi,false);
 llamadas_maquina.bucle_general:=atari7800_main;
 llamadas_maquina.reset:=reset_atari7800;
 llamadas_maquina.cartuchos:=abrir_atari7800;
 llamadas_maquina.fps_max:=master_clock/A78_LINE_CLOCKS/A78_LINES_NTSC;
 llamadas_maquina.scanlines:=A78_LINES_NTSC;
 screen_init(1,A78_WIDTH,A78_HEIGHT);
 iniciar_video(A78_WIDTH,A78_HEIGHT);
 palette_init;
 if main_vars.console_init then abrir_atari7800;
 result:=true;
end;

end.
