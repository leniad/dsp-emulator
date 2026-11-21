unit atari2600_video;
interface

const
  A26_WIDTH=352;
  A26_CAPTURE_LINES=400;
  A26_HEIGHT=288;

type
  ta26_frame=array[0..A26_HEIGHT-1,0..159] of byte;
  ta26_capture=array[0..A26_CAPTURE_LINES-1,0..159] of byte;
  ttia_video=record
    regs:array[0..$2c] of byte;
    collisions:array[0..7] of byte;
    xpos:array[0..4] of integer;
    grp_delay:array[0..1] of byte;
    ball_delay:byte;
    hclock,scanline:integer;
    frame_number:cardinal;
    wsync,pal_mode,hmove_blank:boolean;
    fire:array[0..1] of boolean;
    fire_latch:array[0..1] of boolean;
    frame:ta26_capture;
    completed:ta26_frame;
    active_top,active_bottom:integer;
  end;

var
  tia_video:ttia_video;

procedure tia_video_init(pal_mode:boolean);
procedure tia_video_set_palette(pal_mode:boolean);
procedure tia_video_reset;
procedure tia_video_tick;
procedure tia_video_write(reg,value:byte);
function tia_video_read(reg,open_bus:byte):byte;
procedure tia_video_inputs(fire0,fire1:boolean);
procedure tia_video_present;

implementation
uses main_engine,gfx_engine,pal_engine;

const
  A26_WINDOW_HISTORY=8;
var
  window_top,window_bottom:array[0..A26_WINDOW_HISTORY-1] of integer;
  window_count,window_next:integer;
  window_locked:boolean;
  window_offset:integer;
  pf_pending,pf_delay:array[0..2] of byte;
  gfx_pending,gfx_delay:array[0..4] of byte;
  size_pending,size_delay:array[0..1] of byte;
  suppress_player:array[0..1] of boolean;
  resp_delay:array[0..1 ]of byte;
  resp_position:array[0..1] of integer;
  hmove_blank_next:boolean;
  hmove_start:integer;
  hmove_clocks:array[0..4] of integer;

const
  A26_PALETTE_NTSC:array[0..127]of cardinal=(
    $000000,$4A4A4A,$6F6F6F,$8E8E8E,$AAAAAA,$C0C0C0,$D6D6D6,$ECECEC,
    $484800,$69690F,$86861D,$A2A22A,$BBBB35,$D2D240,$E8E84A,$FCFC54,
    $7C2C00,$904811,$A26221,$B47A30,$C3903D,$D2A44A,$DFB755,$ECC860,
    $901C00,$A33915,$B55328,$C66C3A,$D5824A,$E39759,$F0AA67,$FCBC74,
    $940000,$A71A1A,$B83232,$C84848,$D65C5C,$E46F6F,$F08080,$FC9090,
    $840064,$97197A,$A8308F,$B846A2,$C659B3,$D46CC3,$E07CD2,$EC8CE0,
    $500084,$68199A,$7D30AD,$9246C0,$A459D0,$B56CE0,$C57CEE,$D48CFC,
    $140090,$331AA3,$4E32B5,$6848C6,$7F5CD5,$956FE3,$A980F0,$BC90FC,
    $000094,$181AA7,$2D32B8,$4248C8,$545CD6,$656FE4,$7580F0,$8490FC,
    $001C88,$183B9D,$2D57B0,$4272C2,$548AD2,$65A0E1,$75B5EF,$84C8FC,
    $003064,$185080,$2D6D98,$4288B0,$54A0C5,$65B7D9,$75CCEB,$84E0FC,
    $004030,$18624E,$2D8169,$429E82,$54B899,$65D1AE,$75E7C2,$84FCD4,
    $004400,$1A661A,$328432,$48A048,$5CBA5C,$6FD26F,$80E880,$90FC90,
    $143C00,$355F18,$527E2D,$6E9C42,$87B754,$9ED065,$B4E775,$C8FC84,
    $303800,$505916,$6D762B,$88923E,$A0AB4F,$B7C25F,$CCD86E,$E0EC7C,
    $482C00,$694D14,$866A26,$A28638,$BB9F47,$D2B656,$E8CC63,$FCE070);
  A26_PALETTE_PAL:array[0..127]of cardinal=(
    $000000,$2B2B2B,$525252,$767676,$979797,$B6B6B6,$D2D2D2,$ECECEC,
    $000000,$2B2B2B,$525252,$767676,$979797,$B6B6B6,$D2D2D2,$ECECEC,
    $805800,$96711A,$AB8732,$BE9C48,$CFAF5C,$DFC06F,$EED180,$FCE090,
    $445C00,$5E791A,$769332,$8CAC48,$A0C25C,$B3D76F,$C4EA80,$D4FC90,
    $703400,$89511A,$A06B32,$B68448,$C99A5C,$DCAF6F,$ECC280,$FCD490,
    $006414,$1A8035,$329852,$48B06E,$5CC587,$6FD99E,$80EBB4,$90FCC8,
    $700014,$891A35,$A03252,$B6486E,$C95C87,$DC6F9E,$EC80B4,$FC90C8,
    $005C5C,$1A7676,$328E8E,$48A4A4,$5CB8B8,$6FCBCB,$80DCDC,$90ECEC,
    $70005C,$841A74,$963289,$A8489E,$B75CB0,$C66FC1,$D380D1,$E090E0,
    $003C70,$195A89,$2F75A0,$448EB6,$57A5C9,$68BADC,$79CEEC,$88E0FC,
    $580070,$6E1A89,$8332A0,$9648B6,$A75CC9,$B76FDC,$C680EC,$D490FC,
    $002070,$193F89,$2F5AA0,$4474B6,$578BC9,$68A1DC,$79B5EC,$88C8FC,
    $340080,$4A1A96,$5F32AB,$7248BE,$835CCF,$936FDF,$A280EE,$B090FC,
    $000088,$1A1A9D,$3232B0,$4848C2,$5C5CD2,$6F6FE1,$8080EF,$9090FC,
    $000000,$2B2B2B,$525252,$767676,$979797,$B6B6B6,$D2D2D2,$ECECEC,
    $000000,$2B2B2B,$525252,$767676,$979797,$B6B6B6,$D2D2D2,$ECECEC);

function wrap160(x:integer):integer;
begin
  result:=x mod 160;
  if result<0 then inc(result,160);
end;

procedure tia_video_set_palette(pal_mode:boolean);
var
  i:integer;
  rgb:cardinal;
  c:tcolor;
begin
  tia_video.pal_mode:=pal_mode;
  // Rendered TIA codes use (value and $FE) shr 1: 128 RGB entries.
  for i:=0 to 127 do begin
    if pal_mode then rgb:=A26_PALETTE_PAL[i]
      else rgb:=A26_PALETTE_NTSC[i];
    c.r:=(rgb shr 16) and $ff;
    c.g:=(rgb shr 8) and $ff;
    c.b:=rgb and $ff;
    c.a:=255;
    set_pal_color(c,i);
  end;
end;

procedure tia_video_init(pal_mode:boolean);
begin
  tia_video_set_palette(pal_mode);
  tia_video_reset;
end;

procedure tia_video_reset;
var
  p:boolean;
begin
  p:=tia_video.pal_mode;
  fillchar(tia_video,SizeOf(tia_video),0);
  tia_video.pal_mode:=p;
  tia_video.regs[1]:=2;
  tia_video.active_top:=A26_CAPTURE_LINES;
  tia_video.active_bottom:=-1;
  fillchar(pf_delay,SizeOf(pf_delay),0);
  fillchar(gfx_delay,SizeOf(gfx_delay),0);
  fillchar(size_delay,SizeOf(size_delay),0);
  fillchar(suppress_player,SizeOf(suppress_player),0);
  fillchar(resp_delay,SizeOf(resp_delay),0);
  hmove_blank_next:=false;
  hmove_start:=-1;
  window_locked:=false;
  window_offset:=0;
  window_count:=0;
  window_next:=0;
end;

procedure tia_video_inputs(fire0,fire1:boolean);
begin
  tia_video.fire[0]:=fire0;
  tia_video.fire[1]:=fire1;
  if (tia_video.regs[1] and $40)<>0 then begin
    tia_video.fire_latch[0]:=tia_video.fire_latch[0] or fire0;
    tia_video.fire_latch[1]:=tia_video.fire_latch[1] or fire1;
  end;
end;

procedure finish_frame;
var
  source_top,source_bottom,lines,dest_top,y,dest_y,i:integer;
begin
  fillchar(tia_video.completed,SizeOf(tia_video.completed),0);
  if tia_video.active_bottom>=tia_video.active_top then begin
    source_top:=tia_video.active_top;
    source_bottom:=tia_video.active_bottom;
    // VBLANK is software-controlled and can include intermittent overscan.
    // Use the common active window of recent frames ONLY to place the image.
    // Keep all captured pixels: do not discard a score/sprite outside it.
    // Power-on can run into the 400-line presentation watchdog repeatedly.
    // Such partial/unsynchronised frames must never lock the TV origin.
    if not window_locked and (tia_video.scanline>=240) and (tia_video.scanline<=330) and (source_bottom-source_top+1>=100)then begin
      window_top[window_next]:=source_top;
      window_bottom[window_next]:=source_bottom;
      window_next:=(window_next+1) mod A26_WINDOW_HISTORY;
      if window_count<A26_WINDOW_HISTORY then inc(window_count);
      for i:=0 to window_count-1 do begin
        if window_top[i]>source_top then source_top:=window_top[i];
        if window_bottom[i]<source_bottom then source_bottom:=window_bottom[i];
      end;
      if source_bottom-source_top+1<100 then begin
        // The game changed its display layout; start acquisition again.
        source_top:=tia_video.active_top;
        source_bottom:=tia_video.active_bottom;
        window_top[0]:=source_top;
        window_bottom[0]:=source_bottom;
        window_count:=1;
        window_next:=1;
      end;
    end;
    lines:=source_bottom-source_top+1;
    if lines>A26_HEIGHT then begin
      inc(source_top,(lines-A26_HEIGHT)div 2);
      lines:=A26_HEIGHT;
    end;
    if not window_locked then begin
      dest_top:=(A26_HEIGHT-lines)div 2;
      window_offset:=dest_top-source_top;
      // VBLANK changes the visible content, not the TV's vertical origin.
      // Acquire once after reset, then keep the whole frame at that origin.
      if window_count=A26_WINDOW_HISTORY then window_locked:=true;
    end;
    for y:=tia_video.active_top to tia_video.active_bottom do begin
      dest_y:=y+window_offset;
      if (dest_y>=0) and (dest_y<A26_HEIGHT) then copymemory(@tia_video.completed[dest_y,0],@tia_video.frame[y,0],160);
    end;
  end;
  fillchar(tia_video.frame,SizeOf(tia_video.frame),0);
  tia_video.active_top:=A26_CAPTURE_LINES;
  tia_video.active_bottom:=-1;
  tia_video.scanline:=0;
  inc(tia_video.frame_number);
end;

procedure apply_video_write(reg,value:byte);
const
  pf_write_delay:array[0..3]of byte=(4,5,2,3);
var
  i,n,x,passed,remaining,stop_clock,k,mode,width,dx:integer;
  old:byte;
begin
  reg:=reg and $3f;
  if reg>$2c then exit;
  if reg in[$0d..$0f]then begin
    // Playfield writes reach the display on the TIA four-clock phase.
    // Keep the old pattern visible until that point, including collisions.
    pf_pending[reg-$0d]:=value;
    pf_delay[reg-$0d]:=pf_write_delay[(tia_video.hclock div 3)and 3]+1;
    exit;
  end;
  old:=tia_video.regs[reg];
  tia_video.regs[reg]:=value;
  case reg of
    $04,$05:suppress_player[reg-4]:=false;
    $00:if ((old and 2)<>0) and ((value and 2)=0) and (tia_video.scanline>=100) then finish_frame;
    $01:if(value and $40)=0 then begin
          tia_video.fire_latch[0]:=false;
          tia_video.fire_latch[1]:=false;
        end else tia_video_inputs(tia_video.fire[0],tia_video.fire[1]);
    $02:tia_video.wsync:=(tia_video.hclock<>0);
    $03:begin
          tia_video.hclock:=0;
          tia_video.wsync:=false;
        end;
    $10..$14:begin
      i:=reg-$10;
      stop_clock:=75;
      if (hmove_start>=0) and (hmove_start+70<stop_clock) then stop_clock:=hmove_start+70;
      if (hmove_start>=0) and (tia_video.hclock>=hmove_start) and (tia_video.hclock<stop_clock) then begin
        // RESP/RESM/RESBL during an early HMOVE must retain the motion
        // clocks which have not arrived yet; setting a final X loses them.
        if i<2 then x:=3 else x:=2;
        n:=tia_video.hclock-(hmove_start+4);
        if n>=0 then passed:=n div 4
          else passed:=-((-n+3)div 4);
        remaining:=hmove_clocks[i]-passed;
        x:=x+8;
        if remaining>0 then dec(x,remaining);
      end else if tia_video.hclock<68 then begin
                  if i<2 then x:=3 else x:=2;
               end else begin
                  x:=tia_video.hclock-68+4;
                  if i<2 then inc(x);
               end;
      x:=wrap160(x);
      // RESP starts a new decode sequence: its first copy may be suppressed.
      // A copy already shifting out must finish before the reset takes effect.
      if (i<2) and (x<>tia_video.xpos[i]) then begin
        resp_delay[i]:=0;
        mode:=tia_video.regs[4+i]and 7;
        width:=8;
        if mode=5 then width:=16
          else if mode=7 then width:=32;
        passed:=0;
        for k:=0 to 2 do begin
          n:=-1;
          if k=0 then n:=0
          else case mode of
            1:if k=1 then n:=16;
            2:if k=1 then n:=32;
            3:n:=k*16;
            4:if k=1 then n:=64;
            6:n:=k*32;
          end;
          if n>=0 then begin
            dx:=wrap160(x-tia_video.xpos[i]-n);
            if dx<4 then passed:=-1
              else if(dx<4+width) and (passed<>-1) then passed:=1;
          end;
        end;
        if passed=1 then begin
          resp_position[i]:=x;
          resp_delay[i]:=12;
        end else begin
          suppress_player[i]:=passed<>-1;
          tia_video.xpos[i]:=x;
        end;
      end else tia_video.xpos[i]:=x;
    end;
    $1b:tia_video.grp_delay[1]:=tia_video.regs[$1c];
    $1c:begin
          tia_video.grp_delay[0]:=tia_video.regs[$1b];
          tia_video.ball_delay:=tia_video.regs[$1f];
        end;
    $2a:begin
      fillchar(suppress_player,SizeOf(suppress_player),0);
      hmove_start:=-1;
      // Only early-HMOVE reset timing is modelled here. Preserve the
      // existing late-HMOVE positioning path, including its cycle-74 case.
      if tia_video.hclock<63 then hmove_start:=tia_video.hclock;
      for i:=0 to 4 do begin
        hmove_clocks[i]:=(tia_video.regs[$20+i]xor $80)shr 4;
        if (hmove_start>=12) then begin
          n:=(70-hmove_start) div 4;
          if hmove_clocks[i]>n then hmove_clocks[i]:=n;
        end;
        n:=tia_video.regs[$20+i] shr 4;
        if n>=8 then dec(n,16);
        if tia_video.hclock=222 then tia_video.xpos[i]:=wrap160(tia_video.xpos[i]-n-8)
          else tia_video.xpos[i]:=wrap160(tia_video.xpos[i]-n);
      end;
      if tia_video.hclock<68 then tia_video.hmove_blank:=true;
      // A cycle-75 HMOVE extends HBLANK into the following scanline.
      // It must survive the line boundary instead of leaving a comb edge.
      if tia_video.hclock>=225 then hmove_blank_next:=true;
    end;
    $20..$24:begin
      // HMxx may change before the current motion comparator has stopped.
      // Correct the movement already applied by the positional renderer.
      i:=reg-$20;
      stop_clock:=75;
      n:=hmove_start+6+hmove_clocks[i]*4;
      if n<stop_clock then stop_clock:=n;
      if (hmove_start>=0) and ((old and $f0)<>(value and $f0)) and (tia_video.hclock<stop_clock)then begin
        n:=(value xor $80)shr 4;
        stop_clock:=75;
        x:=hmove_start+6+n*4;
        if x<stop_clock then stop_clock:=x;
        if (n>hmove_clocks[i]) or (tia_video.hclock<=stop_clock) then begin
          tia_video.xpos[i]:=wrap160(tia_video.xpos[i]-(n-hmove_clocks[i]));
          hmove_clocks[i]:=n;
        end else begin
          tia_video.xpos[i]:=wrap160(tia_video.xpos[i]-(15-hmove_clocks[i]));
          hmove_clocks[i]:=15;
        end;
      end;
    end;
    $2b:for i:=$20 to $24 do apply_video_write(i,0);
    $2c:fillchar(tia_video.collisions,SizeOf(tia_video.collisions),0);
  end;
end;

procedure tia_video_write(reg,value:byte);
begin
  reg:=reg and $3f;
  // Preserve the TIA write latency for copies and graphic/latch updates.
  if reg in[4,5]then begin
    size_pending[reg-4]:=value;
    size_delay[reg-4]:=9;
  end else if reg in[$1b..$1f]then begin
              gfx_pending[reg-$1b]:=value;
              gfx_delay[reg-$1b]:=2;
           end else apply_video_write(reg,value);
end;

function tia_video_read(reg,open_bus:byte):byte;
var
  n:integer;
  down:boolean;
begin
  reg:=reg and $f;
  result:=open_bus;
  case reg of
    0..5,7:result:=(open_bus and $3f) or tia_video.collisions[reg];
    6:result:=(open_bus and $7f) or tia_video.collisions[6];
    8..11:begin
      // Joystick configuration: no connected paddle capacitors.
      if(tia_video.regs[1] and $80)<>0 then result:=open_bus and $7f
        else result:=open_bus or $80;
    end;
    12,13:begin
      n:=reg-12;
      down:=tia_video.fire[n];
      if (tia_video.regs[1] and $40)<>0 then down:=down or tia_video.fire_latch[n];
      result:=open_bus and $7f;
      if not down then result:=result or $80;
    end;
  end;
end;

function pf_pixel(x:integer):boolean;
var
  n:integer;
begin
  n:=x div 4;
  if n>=20 then begin
    if(tia_video.regs[$a] and 1)<>0 then n:=39-n
      else dec(n,20);
  end;
  if n<4 then result:=(tia_video.regs[$d] and (1 shl (n+4)))<>0
    else if n<12 then result:=(tia_video.regs[$e] and (1 shl (11-n)))<>0
          else result:=(tia_video.regs[$f] and (1 shl (n-12)))<>0;
end;

function object_pixel(x,obj:integer;missile:boolean):boolean;
const
  copies:array[0..7]of byte=(1,2,2,3,2,1,3,1);
  spacing:array[0..7]of byte=(0,16,32,16,64,0,32,0);
var
  mode,scale,count,k,dx,off,width,player_delay:integer;
  bits:byte;
begin
  mode:=tia_video.regs[4+obj] and 7;
  scale:=1;
  if mode=5 then scale:=2
    else if mode=7 then scale:=4;
  // Double/quad-width players start one color clock later. Missiles do not.
  player_delay:=0;
  if not missile and (mode in[5,7]) then player_delay:=1;
  count:=copies[mode];
  result:=false;
  bits:=tia_video.regs[$1b+obj];
  if missile then begin
    if (tia_video.regs[$1d+obj] and 2)=0 then exit;
    if (tia_video.regs[$28+obj] and 2)<>0 then exit;
    width:=1 shl ((tia_video.regs[4+obj] shr 4) and 3);
  end else begin
    width:=8*scale;
    if (tia_video.regs[$25+obj] and 1)<>0 then bits:=tia_video.grp_delay[obj];
  end;
  for k:=0 to count-1 do begin
    if not missile and (k=0) and suppress_player[obj] then continue;
    off:=k*spacing[mode];
    if missile then dx:=wrap160(x-tia_video.xpos[obj+2]-off)
      else dx:=wrap160(x-tia_video.xpos[obj]-off-player_delay);
    if dx<width then begin
      if missile then begin
        result:=true;
        exit;
      end;
      dx:=dx div scale;
      if (tia_video.regs[$b+obj] and 8)=0 then dx:=7-dx;
      if (bits and(1 shl dx))<>0 then begin
        result:=true;
        exit;
      end;
    end;
  end;
end;

function render_pixel(x:integer):byte;
procedure collide(index,bitnum:integer;a,b:boolean);
begin
  if (a and b) then tia_video.collisions[index]:=tia_video.collisions[index] or (1 shl bitnum);
end;
var
  p0,p1,m0,m1,pf,bl:boolean;
  en:byte;
  pfcolor:byte;
begin
  p0:=object_pixel(x,0,false);
  p1:=object_pixel(x,1,false);
  m0:=object_pixel(x,0,true);
  m1:=object_pixel(x,1,true);
  pf:=pf_pixel(x);
  en:=tia_video.regs[$1f];
  if (tia_video.regs[$27] and 1)<>0 then en:=tia_video.ball_delay;
  bl:=((en and 2)<>0) and (wrap160(x-tia_video.xpos[4])<(1 shl ((tia_video.regs[$a] shr 4)and 3)));
  collide(0,7,m0,p1);
  collide(0,6,m0,p0);
  collide(1,7,m1,p0);
  collide(1,6,m1,p1);
  collide(2,7,p0,pf);
  collide(2,6,p0,bl);
  collide(3,7,p1,pf);
  collide(3,6,p1,bl);
  collide(4,7,m0,pf);
  collide(4,6,m0,bl);
  collide(5,7,m1,pf);
  collide(5,6,m1,bl);
  collide(6,7,bl,pf);
  collide(7,7,p0,p1);
  collide(7,6,m0,m1);
  pfcolor:=tia_video.regs[8];
  // SCORE solo actua cuando la prioridad del playfield esta desactivada.
  if (tia_video.regs[$0a] and $06)=$02 then begin
    if x<80 then pfcolor:=tia_video.regs[6]
      else pfcolor:=tia_video.regs[7];
  end;
  result:=tia_video.regs[9];
  if pf then result:=pfcolor;
  if bl then result:=tia_video.regs[8];
  if p1 or m1 then result:=tia_video.regs[7];
  if p0 or m0 then result:=tia_video.regs[6];
  if(tia_video.regs[$a] and 4)<>0 then begin
    if pf then result:=pfcolor;
    if bl then result:=tia_video.regs[8];
  end;
  result:=(result and $fe) shr 1;
end;

procedure tia_video_tick;
var
  x,y,i,scale:integer;
  color:byte;
begin
  for i:=0 to 2 do
    if pf_delay[i]<>0 then begin
      dec(pf_delay[i]);
      if pf_delay[i]=0 then tia_video.regs[$0d+i]:=pf_pending[i];
    end;
  for i:=0 to 4 do
    if gfx_delay[i]<>0 then begin
      dec(gfx_delay[i]);
      if gfx_delay[i]=0 then apply_video_write($1b+i,gfx_pending[i]);
    end;
  for i:=0 to 1 do
    if size_delay[i]<>0 then begin
      dec(size_delay[i]);
      if size_delay[i]=0 then apply_video_write(4+i,size_pending[i]);
    end;
  for i:=0 to 1 do
    if resp_delay[i]<>0 then begin
      dec(resp_delay[i]);
      if resp_delay[i]=0 then begin
        tia_video.xpos[i]:=resp_position[i];
        suppress_player[i]:=true;
      end;
    end;
  // RESMP tracks the centre of its player while held in reset.
  for i:=0 to 1 do
    if (tia_video.regs[$28+i] and 2)<>0 then begin
      scale:=1;
      if (tia_video.regs[4+i] and 7)=5 then scale:=2;
      if (tia_video.regs[4+i] and 7)=7 then scale:=4;
      tia_video.xpos[i+2]:=wrap160(tia_video.xpos[i]+4*scale);
    end;
  x:=tia_video.hclock-68;
  // Capture the whole frame: centering is performed only at presentation.
  y:=tia_video.scanline;
  if (x>=0) and (x<160) then begin
    color:=0;
    if ((tia_video.regs[0] or tia_video.regs[1]) and 2)=0 then begin
      if (y>=0) and (y<A26_CAPTURE_LINES) then begin
        if y<tia_video.active_top then tia_video.active_top:=y;
        if y>tia_video.active_bottom then tia_video.active_bottom:=y;
      end;
      color:=render_pixel(x);
      if (tia_video.hmove_blank and (x<8)) then color:=0;
    end;
    if ((y>=0) and (y<A26_CAPTURE_LINES)) then tia_video.frame[y,x]:=color;
  end;
  inc(tia_video.hclock);
  if tia_video.hclock=228 then begin
    tia_video.hclock:=0;
    inc(tia_video.scanline);
    fillchar(suppress_player,2,0);
    tia_video.wsync:=false;
    tia_video.hmove_blank:=hmove_blank_next;
    hmove_blank_next:=false;
    hmove_start:=-1;
    // Presentation watchdog only: normal boundaries come from software VSYNC.
    if tia_video.scanline>=400 then finish_frame;
  end;
end;

procedure tia_video_present;
var
  y,x:integer;
  line:array[0..A26_WIDTH-1]of word;
  col:word;
begin
  for y:=0 to A26_HEIGHT-1 do begin
    for x:=0 to A26_WIDTH-1 do line[x]:=paleta[0];
    for x:=0 to 159 do begin
      col:=paleta[tia_video.completed[y,x]];
      line[(A26_WIDTH-320) div 2+x*2]:=col;
      line[(A26_WIDTH-320) div 2+x*2+1]:=col;
    end;
    putpixel(0,y,A26_WIDTH,@line[0],1);
  end;
  actualiza_trozo(0,0,A26_WIDTH,A26_HEIGHT,1,0,0,A26_WIDTH,A26_HEIGHT,PANT_TEMP);
end;

end.
