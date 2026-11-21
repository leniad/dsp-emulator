unit atari5200_video;

interface
uses main_engine;

const
  A5200_WIDTH=384;
  A5200_TV_WIDTH=336;
  A5200_TV_LEFT=(A5200_WIDTH-A5200_TV_WIDTH) div 2;
  A5200_TV_RIGHT=A5200_TV_LEFT+A5200_TV_WIDTH; // exclusive
  A5200_HEIGHT=240;
  A5200_LINES=262;
  A5200_CYCLES_LINE=114;
  A5200_CLOCK=1789773;

type
  ta5200_dma_read=function(address:word):byte;
  ta5200_nmi=procedure;
  ta5200_video=record
    antic:array[0..15] of byte;
    gtia:array[0..31] of byte;
    collision:array[0..15] of byte;
    trigger,trigger_latch:array[0..3] of byte;
    line,cycle,dma_remaining:integer;
    frame_number:cardinal;
    wsync:boolean;
    completed,working:array[0..A5200_HEIGHT-1,0..A5200_WIDTH-1] of byte;
  end;

var
  a5200_video:ta5200_video;
  // Presentation only: false shows the centred TV window with black margins.
  // true exposes the full 384-pixel overscan for debugging or wide displays.
  a5200_show_overscan:boolean=false;

procedure a5200_video_init(read_dma:ta5200_dma_read;nmi_callback:ta5200_nmi);
procedure a5200_video_reset;
procedure a5200_video_tick;
procedure a5200_video_present;
function a5200_video_cpu_blocked(is_read:boolean=true):boolean;
function a5200_antic_read(reg:byte):byte;
procedure a5200_antic_write(reg,value:byte);
function a5200_gtia_read(reg:byte):byte;
procedure a5200_gtia_write(reg,value:byte);

implementation
uses
  SysUtils,Math,pal_engine,gfx_engine;

var
  dma_read:ta5200_dma_read;
  nmi:ta5200_nmi;
  dl,scan:word;
  instruction:byte;
  mode,row,row_end,bytes_line:integer;
  names,glyphs:array[0..47] of byte;
  pixels,pfmask,pf_collision,pmask:array[0..A5200_WIDTH-1] of byte;
  pf_hires:array[0..A5200_WIDTH-1]of boolean;
  waiting,scroll_region,line_active:boolean;
  // Preserve color writes until the line is drawn, instead of coloring the
  // entire line with the final register values (COLPM, COLPF and COLBK).
  line_colors:array[0..8]of byte;
  color_writes:array[0..113]of record
    x:integer;
    reg,value:byte;
  end;
  color_write_count:integer;
  line_prior:byte;
  prior_writes:array[0..113]of record
    x:integer;
    value:byte;
  end;
  prior_write_count:integer;
  line_hpos:array[0..7]of byte;
  hpos_writes:array[0..113]of record
    x:integer;
    reg,value:byte;
  end;
  hpos_write_count:integer;
  line_hscroll:byte;
  hscroll_writes:array[0..113]of record
    x:integer;
    value:byte;
  end;
  hscroll_write_count:integer;
  dma_slots:array[0..113]of boolean;
  line_prepared,pf_names_fetched:boolean;
  dl_reads,wsync_delay:integer;
  chbase_latched,chbase_pending:byte;
  glyph_fetch_index:array[0..113]of integer;

const
  line_height:array[0..15] of byte=(1,1,8,10,8,16,8,16,8,4,4,2,1,2,1,1);
  mode_bytes:array[0..15] of byte=(0,0,40,40,40,40,20,20,10,10,20,20,20,40,40,40);
  sizes:array[0..3] of byte=(1,2,1,4);

function fetch(address:word):byte;
begin
  if Assigned(dma_read) then Result:=dma_read(address)
    else Result:=$ff;
  // Bus contention is scheduled in dma_slots, not accumulated here.
end;

function dlbyte:byte;
begin
  case dl_reads of
    0:dma_slots[1]:=true;
    1:dma_slots[6]:=true;
    2:dma_slots[7]:=true;
  end;
  inc(dl_reads);
  Result:=fetch(dl);dl:=(dl and $fc00) or ((dl+1) and $3ff);
  a5200_video.antic[2]:=dl and $ff;
  a5200_video.antic[3]:=dl shr 8;
end;

function scan_addr(offset:integer):word;
begin
  Result:=(scan and $f000) or ((scan+offset) and $fff);
end;

procedure interrupt_video(flag:byte);
begin
  // NMIST retains the interrupt cause across scanlines. A new cause replaces
  // the previous DLI/VBI status; in particular VBI must clear the DLI bit.
  a5200_video.antic[15]:=$1f or flag;
  if ((a5200_video.antic[14] and flag)<>0) and Assigned(nmi) then nmi;
end;

procedure palette_init;
const
  // NTSC GTIA reference RGB data, phase 26.2 degrees, from MAME atari400.cpp.
  // Copyright Juergen Buchmueller, Angelo Salese. SPDX-License-Identifier: GPL-2.0-or-later
  // See PALETTE_LICENSE.txt. This replaces the previous approximate hue formula.
  ntsc_rgb:array[0..255,0..2]of byte=(
    ($00,$00,$00),($11,$11,$11),($22,$22,$22),($33,$33,$33),
    ($44,$44,$44),($55,$55,$55),($66,$66,$66),($77,$77,$77),
    ($88,$88,$88),($99,$99,$99),($aa,$aa,$aa),($bb,$bb,$bb),
    ($cc,$cc,$cc),($dd,$dd,$dd),($ee,$ee,$ee),($ff,$ff,$ff),
    ($1a,$07,$00),($2b,$18,$00),($3c,$29,$00),($4d,$3a,$00),
    ($5e,$4b,$00),($6f,$5c,$00),($80,$6d,$00),($91,$7e,$09),
    ($a2,$8f,$1a),($b3,$a0,$2b),($c4,$b1,$3c),($d5,$c2,$4d),
    ($e6,$d3,$5e),($f7,$e4,$6f),($ff,$f5,$83),($ff,$f7,$97),
    ($31,$00,$00),($42,$06,$00),($53,$17,$00),($64,$28,$00),
    ($75,$39,$00),($86,$4a,$00),($97,$5b,$0b),($a8,$6c,$1c),
    ($b9,$7d,$2d),($ca,$8e,$3e),($db,$9f,$4f),($ec,$b0,$60),
    ($fd,$c1,$71),($ff,$d2,$86),($ff,$e3,$9d),($ff,$f4,$b3),
    ($3e,$00,$00),($4f,$00,$00),($60,$08,$00),($71,$19,$00),
    ($82,$2a,$0f),($93,$3b,$20),($a4,$4c,$31),($b5,$5d,$42),
    ($c6,$6e,$53),($d7,$7f,$64),($e8,$90,$75),($f9,$a1,$86),
    ($ff,$b2,$9a),($ff,$c3,$b0),($ff,$d4,$c6),($ff,$e5,$dc),
    ($3e,$00,$06),($4f,$00,$12),($60,$00,$1e),($71,$0e,$2e),
    ($82,$1f,$3f),($93,$30,$50),($a4,$41,$61),($b5,$52,$72),
    ($c6,$63,$83),($d7,$74,$94),($e8,$85,$a5),($f9,$96,$b6),
    ($ff,$a7,$cb),($ff,$b8,$e1),($ff,$c9,$ef),($ff,$da,$f4),
    ($32,$00,$38),($43,$00,$44),($54,$00,$50),($65,$0c,$5f),
    ($76,$1d,$70),($87,$2e,$81),($98,$3f,$92),($a9,$50,$a3),
    ($ba,$61,$b4),($cb,$72,$c5),($dc,$83,$d6),($ed,$94,$e4),
    ($fe,$a5,$e4),($ff,$b6,$e9),($ff,$c7,$ee),($ff,$d8,$f3),
    ($1b,$00,$5f),($2c,$00,$6b),($3d,$00,$77),($4e,$11,$88),
    ($5f,$22,$99),($70,$33,$aa),($81,$44,$bb),($92,$55,$cc),
    ($a3,$66,$dd),($b4,$77,$ed),($c5,$88,$ed),($d6,$99,$ed),
    ($e7,$aa,$ed),($f8,$bb,$ed),($ff,$cc,$f0),($ff,$dd,$f5),
    ($00,$00,$72),($10,$00,$7e),($21,$0d,$8e),($32,$1e,$9f),
    ($43,$2f,$b0),($54,$40,$c1),($65,$51,$d2),($76,$62,$e3),
    ($87,$73,$f4),($98,$84,$f9),($a9,$95,$f9),($ba,$a6,$f9),
    ($cb,$b7,$f9),($dc,$c8,$f9),($ed,$d9,$f9),($fe,$ea,$f9),
    ($00,$00,$65),($00,$0c,$7a),($05,$1d,$8e),($16,$2e,$9f),
    ($27,$3f,$b0),($38,$50,$c1),($49,$61,$d2),($5a,$72,$e3),
    ($6b,$83,$f4),($7c,$94,$ff),($8d,$a5,$ff),($9e,$b6,$ff),
    ($af,$c7,$ff),($c0,$d8,$ff),($d1,$e9,$ff),($e2,$fa,$ff),
    ($00,$0d,$48),($00,$1e,$5e),($00,$2f,$74),($00,$40,$8a),
    ($11,$51,$9b),($22,$62,$ac),($33,$73,$bd),($44,$84,$ce),
    ($55,$95,$df),($66,$a6,$f0),($77,$b7,$ff),($88,$c8,$ff),
    ($99,$d9,$ff),($aa,$ea,$ff),($bb,$fb,$ff),($cc,$ff,$ff),
    ($00,$1c,$1c),($00,$2d,$32),($00,$3e,$49),($00,$4f,$5f),
    ($05,$60,$73),($16,$71,$84),($27,$82,$95),($38,$93,$a6),
    ($49,$a4,$b7),($5a,$b5,$c8),($6b,$c6,$d9),($7c,$d7,$ea),
    ($8d,$e8,$fb),($9e,$f9,$ff),($af,$ff,$ff),($c0,$ff,$ff),
    ($00,$25,$0b),($00,$36,$10),($00,$47,$18),($00,$58,$2e),
    ($07,$69,$42),($18,$7a,$53),($29,$8b,$64),($3a,$9c,$75),
    ($4b,$ad,$86),($5c,$be,$97),($6d,$cf,$a8),($7e,$e0,$b9),
    ($8f,$f1,$ca),($a0,$ff,$da),($b1,$ff,$e6),($c2,$ff,$f2),
    ($00,$27,$0c),($00,$38,$11),($00,$49,$16),($04,$5a,$1a),
    ($15,$6b,$1a),($26,$7c,$22),($37,$8d,$33),($48,$9e,$44),
    ($59,$af,$55),($6a,$c0,$66),($7b,$d1,$77),($8c,$e2,$88),
    ($9d,$f3,$99),($ae,$ff,$a8),($bf,$ff,$b4),($d0,$ff,$c0),
    ($00,$21,$0a),($00,$32,$0f),($0a,$43,$11),($1b,$54,$11),
    ($2c,$65,$11),($3d,$76,$11),($4e,$87,$11),($5f,$98,$1e),
    ($70,$a9,$2f),($81,$ba,$40),($92,$cb,$51),($a3,$dc,$62),
    ($b4,$ed,$73),($c5,$fe,$84),($d6,$ff,$90),($e7,$ff,$9c),
    ($05,$13,$04),($16,$24,$04),($27,$35,$04),($38,$46,$04),
    ($49,$57,$04),($5a,$68,$04),($6b,$79,$04),($7c,$8a,$09),
    ($8d,$9b,$1a),($9e,$ac,$2b),($af,$bd,$3c),($c0,$ce,$4d),
    ($d1,$df,$5e),($e2,$f0,$6f),($f3,$ff,$80),($ff,$ff,$8d),
    ($21,$02,$00),($32,$13,$00),($43,$24,$00),($54,$35,$00),
    ($65,$46,$00),($76,$57,$00),($87,$68,$00),($98,$79,$0c),
    ($a9,$8a,$1d),($ba,$9b,$2e),($cb,$ac,$3f),($dc,$bd,$50),
    ($ed,$ce,$61),($fe,$df,$72),($ff,$f0,$87),($ff,$ff,$9d)
  );
var
  p:tpaleta;
  i:integer;
begin
  FillChar(p,SizeOf(p),0);
  for i:=0 to 255 do begin
    p[i].r:=ntsc_rgb[i,0];
    p[i].g:=ntsc_rgb[i,1];
    p[i].b:=ntsc_rgb[i,2];
  end;
  set_pal(p,256);
end;

procedure a5200_video_reset;
var
  i:integer;
begin
  line_prepared:=false;
  wsync_delay:=0;
  chbase_latched:=0;
  chbase_pending:=0;
  FillChar(dma_slots,SizeOf(dma_slots),0);
  FillChar(glyph_fetch_index,SizeOf(glyph_fetch_index),$ff);
  FillChar(a5200_video,SizeOf(a5200_video),0);
  for i:=0 to 3 do begin
    a5200_video.trigger[i]:=1;
    a5200_video.trigger_latch[i]:=1;
  end;
  a5200_video.antic[15]:=$1f;
  dl:=0;
  scan:=0;
  instruction:=0;
  mode:=0;
  row:=0;
  row_end:=0;
  bytes_line:=0;
  waiting:=true;
  scroll_region:=false;
  line_active:=false;
  FillChar(names,SizeOf(names),0);
  FillChar(glyphs,SizeOf(glyphs),0);
end;

procedure a5200_video_init(read_dma:ta5200_dma_read;nmi_callback:ta5200_nmi);
begin
  dma_read:=read_dma;
  nmi:=nmi_callback;
  palette_init;
  a5200_video_reset;
end;

function a5200_antic_read(reg:byte):byte;
begin
  case reg and 15 of
    11:begin
      // VCOUNT exposes the next line during the last three CPU cycles.
      // On the final scanline the extra count is visible for one cycle.
      if a5200_video.cycle<111 then Result:=a5200_video.line shr 1
      else if (a5200_video.line=A5200_LINES-1) and (a5200_video.cycle>=112) then Result:=0
      else Result:=(a5200_video.line+1) shr 1;
    end;
    12,13:Result:=$ff;
    15:Result:=a5200_video.antic[15];
    else Result:=$ff;
  end;
end;

procedure a5200_antic_write(reg,value:byte);
begin
  reg:=reg and 15;
  case reg of
    2:begin a5200_video.antic[2]:=value;dl:=(dl and $ff00) or value;end;
    3:begin a5200_video.antic[3]:=value;dl:=(dl and $00ff) or (word(value) shl 8);end;
    4:begin
      value:=value and 15;
      // Preserve pixels preceding the write. Late HBLANK writes prepare
      // the next line; they must not move the field already displayed.
      if line_prepared and line_active and
         (hscroll_write_count<Length(hscroll_writes)) then begin
        hscroll_writes[hscroll_write_count].x:=a5200_video.cycle*4-68;
        hscroll_writes[hscroll_write_count].value:=value;
        inc(hscroll_write_count);
      end;
      a5200_video.antic[4]:=value;
    end;
    10:begin
      a5200_video.wsync:=true;
      wsync_delay:=1; // RDY allows one more cycle after the write.
    end;
    15:a5200_video.antic[15]:=$1f;
    11..13:;
    else a5200_video.antic[reg]:=value;
  end;
end;

function a5200_gtia_read(reg:byte):byte;
var
  i:integer;
begin
  reg:=reg and 31;
  case reg of
    0..15:Result:=a5200_video.collision[reg];
    16..19:begin
      i:=reg-16;
      if (a5200_video.gtia[29] and 4)<>0 then Result:=a5200_video.trigger_latch[i]
        else Result:=a5200_video.trigger[i];
    end;
    20:Result:=$0f; // NTSC PAL identification
    31:Result:=(not a5200_video.gtia[31]) and $0f; // Pull-ups masked by GTIA output drivers.
    else Result:=$0f; // Unassigned GTIA read registers (including PRIOR).
  end;
end;

procedure a5200_gtia_write(reg,value:byte);
var
  i:integer;
begin
  reg:=reg and 31;
  if reg=30 then FillChar(a5200_video.collision,SizeOf(a5200_video.collision),0)
  else begin
    if (reg=27) and line_prepared and line_active and
       (prior_write_count<Length(prior_writes)) then begin
      prior_writes[prior_write_count].x:=a5200_video.cycle*4-66;
      prior_writes[prior_write_count].value:=value;
      inc(prior_write_count);
    end;
    if (reg<=7) and line_prepared and line_active and
       (hpos_write_count<Length(hpos_writes)) then begin
      hpos_writes[hpos_write_count].x:=a5200_video.cycle*4-68;
      hpos_writes[hpos_write_count].reg:=reg;
      hpos_writes[hpos_write_count].value:=value;
      inc(hpos_write_count);
    end;
    if reg in [18..26] then value:=value and $fe;
    if (reg in [18..26]) and (a5200_video.cycle<>0) and line_active and
       (color_write_count<Length(color_writes)) then begin
      // Two color clocks per CPU cycle, one color-clock color-write delay.
      // GTIA position $20 maps to output x=0; cycle 65 takes effect at $81.
      color_writes[color_write_count].x:=a5200_video.cycle*4-66;
      color_writes[color_write_count].reg:=reg;
      color_writes[color_write_count].value:=value;
      inc(color_write_count);
    end;
    a5200_video.gtia[reg]:=value;
    if (reg=29) and ((value and 4)=0) then
      for i:=0 to 3 do a5200_video.trigger_latch[i]:=1;
  end;
end;

procedure fetch_instruction;
var
  lo,hi,width,dma_width,i:integer;
  new_scroll:boolean;
begin
  instruction:=dlbyte;
  mode:=instruction and 15;
  row:=0;
  if mode=1 then begin
    // JMP consumes a blank mode line; its target is fetched next scanline.
    lo:=dlbyte;
    hi:=dlbyte;
    dl:=lo or (hi shl 8);
    a5200_video.antic[2]:=dl and $ff;
    a5200_video.antic[3]:=dl shr 8;
    row_end:=0;
    if scroll_region then row_end:=a5200_video.antic[5] and 15;
    scroll_region:=false;
    if (instruction and $40)<>0 then waiting:=true;
    exit;
  end;
  if mode=0 then begin
    row_end:=(instruction shr 4) and 7;
    // Blank instructions have VS clear and can terminate a scrolling region.
    // In that case VSCROL, not the encoded blank height, ends the mode line.
    if scroll_region then row_end:=a5200_video.antic[5] and 15;
    scroll_region:=false;
  end
  else begin
    if (instruction and $40)<>0 then begin
      lo:=dlbyte;
      hi:=dlbyte;
      scan:=lo or (hi shl 8);
    end;
    row_end:=line_height[mode]-1;
    new_scroll:=(instruction and $20)<>0;
    if new_scroll and not scroll_region then row:=a5200_video.antic[5] and 15;
    if scroll_region and not new_scroll then row_end:=a5200_video.antic[5] and 15;
    scroll_region:=new_scroll;
    width:=a5200_video.antic[0] and 3;
    dma_width:=width;
    if ((instruction and $10)<>0) and (dma_width<3) then inc(dma_width);
    case dma_width of
      1:bytes_line:=mode_bytes[mode]*4 div 5;
      2:bytes_line:=mode_bytes[mode];
      3:bytes_line:=mode_bytes[mode]*6 div 5;
      else bytes_line:=0;
    end;
    pf_names_fetched:=true;
    for i:=0 to bytes_line-1 do names[i]:=fetch(scan_addr(i));
  end;
end;

procedure schedule_line_dma;
var
  i,c,first,stride,fetch_width:integer;
  refresh_pending:boolean;
procedure occupy(slot:integer);
begin
  if (slot>=0) and (slot<=105) then dma_slots[slot]:=true;
end;
begin
  if line_active then begin
    // DMA consumes slots even when GTIA is not loading the graphic latches.
    if (a5200_video.antic[0] and $0c)<>0 then occupy(0);
    if (a5200_video.antic[0] and 8)<>0 then
      for i:=2 to 5 do occupy(i);
  end;
  if line_active and not waiting and (mode>=2) and
     ((a5200_video.antic[0] and $20)<>0) then begin
    fetch_width:=a5200_video.antic[0] and 3;
    if ((instruction and $10)<>0) and (fetch_width<3) then inc(fetch_width);
    case fetch_width of
      1:first:=26;
      2:first:=18;
      3:first:=10;
      else first:=-1000;
    end;
    if (instruction and $10)<>0 then inc(first,(a5200_video.antic[4] and 15) shr 1);
    if mode in [2..7] then begin
      if mode in [6,7] then stride:=4 else stride:=2;
      for i:=0 to bytes_line-1 do begin
        if pf_names_fetched then occupy(first+i*stride);
        occupy(first+3+i*stride);
        if pf_names_fetched and (first+3+i*stride>=0) and
           (first+3+i*stride<A5200_CYCLES_LINE) then
          glyph_fetch_index[first+3+i*stride]:=i;
      end;
    end else if pf_names_fetched then begin
      case mode of
        8,9:stride:=8;
        10..12:stride:=4;
        else stride:=2;
      end;
      for i:=0 to bytes_line-1 do occupy(first+2+i*stride);
    end;
  end;
  // Only one refresh can be pending. A blocked refresh waits for the next
  // free slot; a later refresh does not create an unbounded DMA debt.
  refresh_pending:=false;
  for c:=0 to 113 do begin
    if (c>=25) and (c<=57) and (((c-25) and 3)=0) then refresh_pending:=true;
    if refresh_pending and not dma_slots[c] then begin
      dma_slots[c]:=true;
      refresh_pending:=false;
    end;
  end;
end;

procedure fetch_character_glyph(i:integer);
var
  base,r,glyph_row:integer;
  character:byte;
begin
  r:=row;
  if mode in [5,7] then r:=r shr 1;
  character:=names[i];
  glyph_row:=r;
  if mode=3 then begin
    if (character and $60)=$60 then dec(glyph_row,2);
    if (glyph_row<0) or (glyph_row>7) then begin
      glyphs[i]:=0;
      exit;
    end;
  end;
  glyph_row:=glyph_row and 7;
  if (a5200_video.antic[1] and 4)<>0 then glyph_row:=7-glyph_row;
  if mode in [6,7] then base:=(chbase_latched and $fe) shl 8
    else base:=(chbase_latched and $fc) shl 8;
  if mode in [6,7] then character:=character and $3f
    else character:=character and $7f;
  glyphs[i]:=fetch((base+integer(character)*8+glyph_row) and $ffff);
end;

procedure prepare_line;
var
  i,base,offset:integer;
  data,mask:byte;
  single:boolean;
begin
  line_prepared:=true;
  FillChar(dma_slots,SizeOf(dma_slots),0);
  FillChar(glyph_fetch_index,SizeOf(glyph_fetch_index),$ff);
  dl_reads:=0;
  pf_names_fetched:=false;
  color_write_count:=0;
  prior_write_count:=0;
  line_prior:=a5200_video.gtia[27];
  hpos_write_count:=0;
  for i:=0 to 7 do line_hpos[i]:=a5200_video.gtia[i];
  hscroll_write_count:=0;
  line_hscroll:=a5200_video.antic[4] and 15;
  for i:=0 to 8 do line_colors[i]:=a5200_video.gtia[18+i];
  a5200_video.dma_remaining:=0; // Legacy field; use a5200_video_cpu_blocked.
  if a5200_video.line=8 then begin
    waiting:=false;
    row:=0;
    row_end:=-1;
    scroll_region:=false;
  end;
  line_active:=(a5200_video.line>=8) and (a5200_video.line<248);
  if not line_active then begin schedule_line_dma;exit;end;
  single:=(a5200_video.antic[0] and $10)<>0;
  if single then begin
    base:=(a5200_video.antic[7] and $f8) shl 8;
    offset:=a5200_video.line;
  end else begin
            base:=(a5200_video.antic[7] and $fc) shl 8;
            offset:=a5200_video.line shr 1;
         end;
  // DMA and CPU writes feed the same GTIA graphics latches. Disabling
  // DMA must retain the last loaded data, not resurrect an old CPU write.
  // VDELAY inhibits DMA loads on even lines; CPU writes are unaffected.
  if ((a5200_video.antic[0] and $0c)<>0) and ((a5200_video.gtia[29] and 1)<>0) then begin
    if single then data:=fetch((base+$300+offset) and $ffff)
      else data:=fetch((base+$180+offset) and $ffff);
    mask:=0;
    for i:=0 to 3 do
      if Odd(a5200_video.line) or ((a5200_video.gtia[28] and (1 shl i))=0) then
        mask:=mask or (3 shl (i*2));
    a5200_video.gtia[17]:=(a5200_video.gtia[17] and not mask) or (data and mask);
  end;
  for i:=0 to 3 do
    if ((a5200_video.antic[0] and 8)<>0) and ((a5200_video.gtia[29] and 2)<>0) then begin
      if single then data:=fetch((base+$400+i*$100+offset) and $ffff)
        else data:=fetch((base+$200+i*$80+offset) and $ffff);
      if Odd(a5200_video.line) or ((a5200_video.gtia[28] and (16 shl i))=0) then
        a5200_video.gtia[13+i]:=data;
    end;
  if ((a5200_video.antic[0] and $20)=0) or waiting then begin schedule_line_dma;exit;end;
  if row>row_end then fetch_instruction;
  if waiting then begin schedule_line_dma;exit;end;
  if mode in [2..7] then begin
    if pf_names_fetched then FillChar(glyphs,SizeOf(glyphs),0)
    else for i:=0 to bytes_line-1 do fetch_character_glyph(i);
  end;
  schedule_line_dma;
end;

procedure paint_playfield_segment(hscroll,first_pixel,last_pixel:integer);
var
    width,left,clipLeft,clipRight,i,bit,bpp,scale,pos,j,value,modeGTIA:integer;
    b,code,c,mask,hit_mask:byte;
procedure emit(color,collision:byte;count:integer;hit_mask:byte);
var
  k:integer;
begin
  for k:=0 to count-1 do begin
    if (pos>=clipLeft) and (pos<clipRight) and (pos>=first_pixel) and (pos<last_pixel) and (pos>=0) and (pos<A5200_WIDTH) then begin
      pixels[pos]:=color;
      pfmask[pos]:=collision;
      pf_collision[pos]:=hit_mask;
      pf_hires[pos]:=(modeGTIA=0) and (mode in [2,3,15]) and (value<>0);
    end;
    inc(pos);
  end;
end;
begin
  if not line_active or waiting or (mode<2) or ((a5200_video.antic[0] and $20)=0) then exit;
  width:=a5200_video.antic[0] and 3;
  case width of
    1:width:=256;
    2:width:=320;
    3:width:=384;
    else exit;
  end;
  clipLeft:=(A5200_WIDTH-width) div 2;
  clipRight:=clipLeft+width;
  left:=clipLeft;
  if (instruction and $10)<>0 then begin
    // ANTIC shifts the expanded DMA playfield RIGHT by HSCROL color clocks.
    // Narrow/normal fetch the next wider field: its origin is 16 color clocks
    // before the clipping window. Wide DMA is already maximal (48 bytes).
    if width<384 then dec(left,32);
    inc(left,hscroll*2);
  end;
  pos:=left;
  modeGTIA:=a5200_video.gtia[27] shr 6;
  for i:=0 to bytes_line-1 do begin
    if mode in [2..7] then b:=glyphs[i]
      else b:=names[i];
    code:=names[i];
    if mode in [2,3] then begin
      if (code and $80)<>0 then begin
        if (a5200_video.antic[1] and 1)<>0 then b:=0
        else if (a5200_video.antic[1] and 2)<>0 then b:=b xor $ff;
      end;
    end;
    if (modeGTIA<>0) and (mode in [2,3,15]) then begin
      for j:=0 to 1 do begin
        if j=0 then value:=b shr 4
          else value:=b and 15;
        mask:=0;
        case modeGTIA of
          1:c:=(a5200_video.gtia[26] and $f0) or value;
          2:begin
            if value<4 then c:=a5200_video.gtia[18+value]
            else if (value<8) or (value>=12) then begin
                  value:=value and 3;
                  c:=a5200_video.gtia[22+value];mask:=1 shl value;
                 end
            else c:=a5200_video.gtia[26];
          end;
          else if value=0 then c:=a5200_video.gtia[26] and $f0
            else c:=(value shl 4) or (a5200_video.gtia[26] and 15);
        end;
        emit(c,mask,4,mask);
      end;
      continue;
    end;
    if mode in [4,5,8,10,13,14] then bpp:=2
      else bpp:=1;
    case mode of
      6,7:scale:=2;
      8:scale:=8;
      9:scale:=4;
      10:scale:=4;
      11,12:scale:=2;
      4,5,13,14:scale:=2;
      else scale:=1;
    end;
    bit:=8-bpp;
    while bit>=0 do begin
      value:=(b shr bit) and ((1 shl bpp)-1);mask:=0;c:=a5200_video.gtia[26];
      if mode in [2,3,15] then begin
        c:=a5200_video.gtia[24];
        mask:=4;
        if value<>0 then c:=(c and $f0) or (a5200_video.gtia[23] and 15);
      end else if mode in [6,7] then begin
        if value<>0 then begin
          value:=code shr 6;
          c:=a5200_video.gtia[22+value];
          mask:=1 shl value;
        end;
      end else if value<>0 then begin
        if (mode in [4,5]) and (value=3) and ((code and $80)<>0) then value:=4;
        c:=a5200_video.gtia[21+value];
        mask:=1 shl (value-1);
      end;
      hit_mask:=mask;
      if mode in [2,3,15] then begin
        // PF2 remains active for priority even on zero luminance pixels.
        // Collision hardware ORs each pair of high-resolution pixels instead.
        if ((b shr (bit and $fe)) and 3)<>0 then hit_mask:=4
          else hit_mask:=0;
      end;
      emit(c,mask,scale,hit_mask);
      dec(bit,bpp);
    end;
  end;
end;

procedure paint_playfield;
var
  i,x,next_x,hscroll,hi,pi:integer;
  final_prior:byte;
begin
  FillChar(pfmask,SizeOf(pfmask),0);
  FillChar(pf_collision,SizeOf(pf_collision),0);
  FillChar(pf_hires,SizeOf(pf_hires),0);
  for i:=0 to A5200_WIDTH-1 do pixels[i]:=a5200_video.gtia[26];
  final_prior:=a5200_video.gtia[27];
  a5200_video.gtia[27]:=line_prior;
  hscroll:=0;
  if (instruction and $10)<>0 then hscroll:=line_hscroll;
  hi:=0;pi:=0;x:=0;
  while x<A5200_WIDTH do begin
    next_x:=A5200_WIDTH;
    if ((instruction and $10)<>0) and (hi<hscroll_write_count) then
      if hscroll_writes[hi].x<next_x then next_x:=hscroll_writes[hi].x;
    if pi<prior_write_count then
      if prior_writes[pi].x<next_x then next_x:=prior_writes[pi].x;
    if next_x<x then next_x:=x;
    if next_x>x then paint_playfield_segment(hscroll,x,next_x);
    x:=next_x;
    if (instruction and $10)<>0 then
      while (hi<hscroll_write_count) do begin
        if hscroll_writes[hi].x>x then break;
        hscroll:=hscroll_writes[hi].value;inc(hi);
      end;
    while pi<prior_write_count do begin
      if prior_writes[pi].x>x then break;
      a5200_video.gtia[27]:=prior_writes[pi].value;inc(pi);
    end;
  end;
  a5200_video.gtia[27]:=final_prior;
end;

function priority_color(pm,pf,color:byte):byte;
var
  p:array[0..3] of boolean;
  f:array[0..3] of boolean;
  sp,sf:array[0..3] of boolean;
  i:integer;
  pr:byte;
  p01,p23,pf01,pf23,multi:boolean;
begin
  if pm=0 then begin
    Result:=color;
    exit;
  end;
  pr:=a5200_video.gtia[27];
  for i:=0 to 3 do begin
    p[i]:=(pm and (1 shl i))<>0;
    if (pr and $10)=0 then p[i]:=p[i] or ((pm and (16 shl i))<>0);
    f[i]:=(pf and (1 shl i))<>0;
  end;
  if ((pr and $10)<>0) and ((pm and $f0)<>0) then f[3]:=true;
  p01:=p[0] or p[1];
  p23:=p[2] or p[3];
  pf01:=f[0] or f[1];
  pf23:=f[2] or f[3];
  multi:=(pr and $20)<>0;
  // Boolean priority network, including OR colors and conflicting PRIOR bits.
  sp[0]:=p[0] and not(pf01 and ((pr and 12)<>0)) and not(pf23 and ((pr and 4)<>0));
  sp[1]:=p[1] and not(pf01 and ((pr and 12)<>0)) and not(pf23 and ((pr and 4)<>0)) and ((not p[0]) or multi);
  sp[2]:=p[2] and not p01 and not(pf23 and ((pr and 6)<>0)) and not(pf01 and ((pr and 1)=0));
  sp[3]:=p[3] and not p01 and not(pf23 and ((pr and 6)<>0)) and not(pf01 and ((pr and 1)=0)) and ((not p[2]) or multi);
  sf[3]:=f[3] and not(p23 and ((pr and 9)<>0)) and not(p01 and ((pr and 4)=0));
  sf[2]:=f[2] and not(p23 and ((pr and 9)<>0)) and not(p01 and ((pr and 4)=0)) and not sf[3];
  sf[0]:=f[0] and not(p23 and ((pr and 1)<>0)) and not(p01 and ((pr and 3)<>0)) and not sf[3];
  sf[1]:=f[1] and not(p23 and ((pr and 1)<>0)) and not(p01 and ((pr and 3)<>0)) and not sf[3];
  if not(p01 or p23 or pf01 or pf23) then begin
    Result:=color;
    exit;
  end;
  Result:=0;
  for i:=0 to 3 do begin
    if sp[i] then Result:=Result or a5200_video.gtia[18+i];
    if sf[i] then begin
      if (pf and (1 shl i))<>0 then Result:=Result or color
      else Result:=Result or a5200_video.gtia[22+i];
    end;
  end;
end;

procedure render_line;
var
  i,j,k,x,start,width,scale,y,event_index:integer;
  b,pm,pf,pl,mi,c:byte;
  final_colors:array[0..8]of byte;
  final_prior:byte;
  prior_event:integer;
  positions:array[0..7]of byte;
  hpos_event,segment_first,segment_last:integer;
procedure object_bits(position,count,multiplier:integer;bits,mask:byte);
var
  a,z,q:integer;
begin
  for a:=0 to count-1 do if (bits and ($80 shr a))<>0 then
    for z:=0 to multiplier-1 do begin
      q:=position+a*multiplier+z;
      if (q>=segment_first) and (q<segment_last) then pmask[q]:=pmask[q] or mask;
    end;
end;
begin
  if not line_active then exit;
  paint_playfield;
  FillChar(pmask,SizeOf(pmask),0);
  for i:=0 to 7 do positions[i]:=line_hpos[i];
  hpos_event:=0;
  segment_first:=0;
  repeat
    segment_last:=A5200_WIDTH;
    if hpos_event<hpos_write_count then begin
      segment_last:=hpos_writes[hpos_event].x;
      if segment_last<segment_first then segment_last:=segment_first;
      if segment_last>A5200_WIDTH then segment_last:=A5200_WIDTH;
    end;
      for i:=0 to 3 do begin
        b:=a5200_video.gtia[13+i];
        start:=(integer(positions[i])-32)*2;
        scale:=sizes[a5200_video.gtia[8+i] and 3]*2;
        object_bits(start,8,scale,b,1 shl i);
        b:=a5200_video.gtia[17];
        b:=(b shl (6-i*2)) and $c0;
        start:=(integer(positions[4+i])-32)*2;
        scale:=sizes[(a5200_video.gtia[12] shr (i*2)) and 3]*2;
        object_bits(start,2,scale,b,16 shl i);
      end;
    segment_first:=segment_last;
    if hpos_event>=hpos_write_count then break;
    positions[hpos_writes[hpos_event].reg]:=hpos_writes[hpos_event].value;
    inc(hpos_event);
  until segment_first>=A5200_WIDTH;
  y:=a5200_video.line-8;
  for i:=0 to 8 do begin
    final_colors[i]:=a5200_video.gtia[18+i];
    a5200_video.gtia[18+i]:=line_colors[i];
  end;
  final_prior:=a5200_video.gtia[27];
  a5200_video.gtia[27]:=line_prior;
  prior_event:=0;
  event_index:=0;
  for x:=0 to A5200_WIDTH-1 do begin
    while event_index<color_write_count do begin
      if color_writes[event_index].x>x then break;
      a5200_video.gtia[color_writes[event_index].reg]:=color_writes[event_index].value;
      inc(event_index);
    end;
    while prior_event<prior_write_count do begin
      if prior_writes[prior_event].x>x then break;
      a5200_video.gtia[27]:=prior_writes[prior_event].value;
      inc(prior_event);
    end;
    pm:=pmask[x];
    pf:=pf_collision[x];
    pl:=pm and 15;
    mi:=pm shr 4;
    if (pm<>0) and (x>=4) and (x<380) then for i:=0 to 3 do begin
      if (pl and (1 shl i))<>0 then begin
        a5200_video.collision[4+i]:=a5200_video.collision[4+i] or pf;
        a5200_video.collision[12+i]:=a5200_video.collision[12+i] or (pl and not(1 shl i));
      end;
      if (mi and (1 shl i))<>0 then begin
        a5200_video.collision[i]:=a5200_video.collision[i] or pf;
        a5200_video.collision[8+i]:=a5200_video.collision[8+i] or pl;
      end;
    end;
    c:=pixels[x];
    if (a5200_video.gtia[27] and $c0)=0 then begin
      case pfmask[x] of
        0:c:=a5200_video.gtia[26];
        1:c:=a5200_video.gtia[22];
        2:c:=a5200_video.gtia[23];
        4:begin
          c:=a5200_video.gtia[24];
          if pf_hires[x] then c:=(c and $f0) or (a5200_video.gtia[23] and 15);
        end;
        8:c:=a5200_video.gtia[25];
      end;
    end;
    c:=priority_color(pm,pfmask[x],c);
    // Hires set bits use PF1 luminance even when a player/missile wins hue.
    if pf_hires[x] and ((a5200_video.gtia[27] and $c0)=0) then
      c:=(c and $f0) or (a5200_video.gtia[23] and $0f);
    a5200_video.working[y,x]:=c;
  end;
  a5200_video.gtia[27]:=final_prior;
  // Registers retain the final CPU-written values after replaying the line.
  for i:=0 to 8 do a5200_video.gtia[18+i]:=final_colors[i];
  if waiting then begin
    // JVB replays a one-line blank after its initial scroll-ending height.
    if row<row_end then inc(row)
      else begin row:=0;row_end:=0;end;
  end;
  if ((a5200_video.antic[0] and $20)<>0) and not waiting then begin
    if row>=row_end then begin
      if mode>=2 then scan:=scan_addr(bytes_line);
    end;
    inc(row);
  end;
end;

function a5200_video_cpu_blocked(is_read:boolean):boolean;
begin
  if not line_prepared then prepare_line;
  // HALT from DMA stops every CPU bus cycle. RDY from WSYNC does
  // not stop NMOS 6502 write cycles. The default keeps read callers compatible.
  Result:=dma_slots[a5200_video.cycle] or
    (is_read and a5200_video.wsync and (wsync_delay=0));
end;

procedure a5200_video_tick;
var
  i:integer;
begin
  if not line_prepared then prepare_line;
  // CHBASE reaches the character generator two machine cycles after a write.
  chbase_latched:=chbase_pending;
  chbase_pending:=a5200_video.antic[9];
  // A new character row must not use a font captured before its DLI write.
  // Read its glyphs at their individual font DMA slots, after CHBASE latching.
  if glyph_fetch_index[a5200_video.cycle]>=0 then
    fetch_character_glyph(glyph_fetch_index[a5200_video.cycle]);
  if wsync_delay>0 then dec(wsync_delay);
  if line_active and (a5200_video.cycle=7) and ((a5200_video.antic[0] and $20)<>0) and (row>=row_end) and ((instruction and $80)<>0) then interrupt_video($80);
  if (a5200_video.line=248) and (a5200_video.cycle=6) then interrupt_video($40);
  if (a5200_video.gtia[29] and 4)<>0 then
    for i:=0 to 3 do a5200_video.trigger_latch[i]:=a5200_video.trigger_latch[i] and a5200_video.trigger[i];
  inc(a5200_video.cycle);
  if a5200_video.cycle=105 then a5200_video.wsync:=false;
  if a5200_video.cycle=A5200_CYCLES_LINE then begin
    render_line;
    a5200_video.cycle:=0;
    line_prepared:=false;
    // A late WSYNC remains pending until cycle 105 of the next line.
    inc(a5200_video.line);
    if a5200_video.line=A5200_LINES then begin
      a5200_video.line:=0;
      inc(a5200_video.frame_number);
      Move(a5200_video.working,a5200_video.completed,SizeOf(a5200_video.completed));
    end;
  end;
end;

procedure a5200_video_present;
var
  row:array[0..A5200_WIDTH-1]of word;
  x,y:integer;
begin
  for y:=0 to A5200_HEIGHT-1 do begin
    for x:=0 to A5200_WIDTH-1 do begin
      if not a5200_show_overscan and ((x<A5200_TV_LEFT) or (x>=A5200_TV_RIGHT)) then
        row[x]:=paleta[0]
      else row[x]:=paleta[a5200_video.completed[y,x]];
    end;
    putpixel(0,y,A5200_WIDTH,@row[0],1);
  end;
  actualiza_trozo(0,0,A5200_WIDTH,A5200_HEIGHT,1,0,0,A5200_WIDTH,A5200_HEIGHT,PANT_TEMP);
end;

end.
