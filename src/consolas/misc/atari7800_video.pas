unit atari7800_video;
interface

uses main_engine;

const
  A78_WIDTH=320;
  A78_HEIGHT=288;
  A78_MASTER_NTSC=7159090;
  A78_MASTER_PAL=7093788;
  A78_LINE_CLOCKS=454;
  A78_HBLANK_CLOCKS=134;
  A78_LINES_NTSC=263;
  A78_LINES_PAL=313;
  A78_VBLANK_LINES=5; // MSTAT rises at line 258 NTSC / 308 PAL.
type
  ta78_dma_read=function(address:word):byte;
  ta78_nmi=procedure;
  ta78_video=record
    regs:array[0..31] of byte;
    line,clock,lines:integer;
    frame_number:cardinal;
    wsync:boolean;
    dma_until:integer;
    completed,working:array[0..A78_HEIGHT-1,0..A78_WIDTH-1] of byte;
  end;

var
  a7800_video:ta78_video;

procedure a7800_video_init(read_dma:ta78_dma_read;nmi:ta78_nmi;pal:boolean);
procedure a7800_video_reset(pal:boolean);
procedure a7800_video_tick;
function a7800_video_blocked(is_read:boolean):boolean;
function a7800_maria_read(reg:byte):byte;
procedure a7800_maria_write(reg,value:byte);
procedure a7800_video_present;

implementation
uses pal_engine,gfx_engine;

var
  dma_read:ta78_dma_read;
  nmi_callback:ta78_nmi;
  dll,display_list:word;
  offset,hpos,palette,write_mode:integer;
  hole8,hole16,zone_dli:boolean;
  line_ram:array[0..159] of byte;
  prepared,dma_started:boolean;
  dli_clock:integer;

function fetch(a:word):byte;
begin
  if (@dma_read<>nil) then Result:=dma_read(a)
    else Result:=$ff;
end;

procedure load_zone;
var
  b:byte;
begin
 b:=fetch(dll);
 offset:=b and 15;
 hole8:=(b and $20)<>0;
 hole16:=(b and $40)<>0;
 zone_dli:=(b and $80)<>0;
 display_list:=(word(fetch(word(dll+1))) shl 8)or fetch(word(dll+2));
end;

procedure store_cell(v:byte);
begin
 if hpos<160 then begin
  if v<>0 then line_ram[hpos]:=v
    else if (a7800_video.regs[$1c] and 4)<>0 then line_ram[hpos]:=0;
 end;
 hpos:=(hpos+1)and 255;
end;

procedure graphic(var address:word);
var
  b:byte;
  hole:boolean;
begin
 hole:=(address>=$8000) and ((hole8 and ((address and $800)<>0))or(hole16 and((address and $1000)<>0)));
 if hole then b:=0
  else b:=fetch(address);
 if write_mode<>0 then begin
  if (b and $cc)<>0 then store_cell(byte((palette and 16)or(b and 12)or(b shr 6)))
   else store_cell(0);
  if (b and $33)<>0 then store_cell(byte((palette and 16)or((b shr 4)and 3)or((b and 3)shl 2)))
   else store_cell(0);
 end else begin
  if(b and $c0)<>0 then store_cell(byte(palette or(b shr 6)))
    else store_cell(0);
  if(b and $30)<>0 then store_cell(byte(palette or((b shr 4)and 3)))
    else store_cell(0);
  if(b and $0c)<>0 then store_cell(byte(palette or((b shr 2)and 3)))
    else store_cell(0);
  if(b and 3)<>0 then store_cell(byte(palette or(b and 3)))
    else store_cell(0);
 end;
 address:=word(address+1);
end;

function build_line:integer;
var
  dp,addr,map:word;
  mode,b:byte;
  width,i,objects:integer;
  indirect:boolean;
begin
 // DMA setup/shutdown: 24 clocks at the end of a zone, 16 otherwise.
 if offset=0 then Result:=24
  else Result:=16;
 FillChar(line_ram,SizeOf(line_ram),0);
 dp:=display_list;
 objects:=0;
 repeat
  mode:=fetch(word(dp+1));
  if(mode and $5f)=0 then break;
  inc(objects);
  if objects>128 then break;
  addr:=fetch(dp)or(word(fetch(word(dp+2)))shl 8);
  indirect:=false;
  if(mode and 31)<>0 then begin
   inc(Result,8);
   palette:=(mode and $e0)shr 3;
   hpos:=fetch(word(dp+3));
   width:=32-(mode and 31);
   dp:=word(dp+4);
  end else begin
   inc(Result,10);
   b:=fetch(word(dp+3));
   palette:=(b and $e0)shr 3;
   width:=32-(b and 31);
   hpos:=fetch(word(dp+4));
   indirect:=(mode and $20)<>0;
   write_mode:=mode and $80;
   dp:=word(dp+5);
  end;
  if not indirect then begin
   addr:=word(addr+(offset shl 8));
   for i:=1 to width do begin
    if Result+3>426 then break;
    inc(Result,3);
    graphic(addr);
   end;
  end else begin
   map:=addr;
   for i:=1 to width do begin
    if Result+6>426 then break;
    b:=fetch(map);
    map:=word(map+1);
    addr:=b or(word(byte(a7800_video.regs[$14]+offset)) shl 8);
    // Indirect: map byte + first graphic byte = 6 clocks in total.
    inc(Result,6);
    graphic(addr);
    if(a7800_video.regs[$1c]and $10)<>0 then begin
     if Result+3>426 then break;
     inc(Result,3);
     graphic(addr);
    end;
   end;
  end;
 until Result>=426;
end;

function color(v:byte):byte;
begin
 if(v and 3)=0 then Result:=a7800_video.regs[0]
  else Result:=a7800_video.regs[v and 31];
 if (a7800_video.regs[$1c] and $80)<>0 then Result:=Result and 15;
end;

procedure emit_line;
var
  i,y,mode:integer;
  b,c,d:byte;
begin
 // Keep overscan out of the virtual image. DMA still runs on its original lines.
 if a7800_video.line<26 then exit;
 if a7800_video.lines=A78_LINES_NTSC then begin
  if a7800_video.line>248 then exit;
 end else if a7800_video.line>297 then exit;
 y:=a7800_video.line-17;
 if a7800_video.lines=A78_LINES_NTSC then inc(y,24);
 if (y<0) or (y>=A78_HEIGHT) then exit;
 mode:=a7800_video.regs[$1c] and 3;
 for i:=0 to 159 do begin
  b:=line_ram[i];
  case mode of
   2:begin
    c:=color((b and 16) or ((b and 8) shr 3) or (b and 2));
    d:=color((b and 16) or ((b and 4) shr 2) or ((b and 1) shl 1));
   end;
   3:begin
      c:=color(b and 30);
      d:=color((b and 28) or ((b and 1)shl 1));
     end;
   else begin
          c:=color(b);
          d:=c;
        end;
  end;
  a7800_video.working[y,i*2]:=c;
  a7800_video.working[y,i*2+1]:=d;
 end;
end;

procedure prepare_dma;
var
  cycles:integer;
  first_dma:boolean;
begin
 prepared:=true;
 a7800_video.dma_until:=0;
 if (a7800_video.regs[$1c]and $60)<>$40 then begin
    FillChar(line_ram,SizeOf(line_ram),0);
    emit_line;
    exit;
 end;
 if (a7800_video.line<16) or (a7800_video.line>a7800_video.lines-A78_VBLANK_LINES) then exit;
 // Even a first enable on the final display line must not start a new DMA.
 if a7800_video.line=a7800_video.lines-A78_VBLANK_LINES then begin
  emit_line;
  exit;
 end;
 first_dma:=(a7800_video.line=16)or not dma_started;
 // DMA may be enabled after line 16; latch the DLL on the first active DMA.
 if first_dma then begin
  dma_started:=true;
  dll:=a7800_video.regs[$10] or (word(a7800_video.regs[$0c])shl 8);
  load_zone;
  FillChar(line_ram,SizeOf(line_ram),0);
  write_mode:=0;
 end else emit_line;
 // The final display line only emits the buffer prepared by the previous DMA.
 // Fetching another zone here would generate a spurious DLI at VBLANK.
 if a7800_video.line<a7800_video.lines-A78_VBLANK_LINES then begin
  // The CPU can change this DLL pointer between scanlines of the same zone.
  display_list:=(word(fetch(word(dll+1))) shl 8)or fetch(word(dll+2));
  cycles:=build_line;
  if first_dma then inc(cycles,8);
  a7800_video.dma_until:=28+cycles;
  if a7800_video.dma_until>A78_LINE_CLOCKS-2 then a7800_video.dma_until:=A78_LINE_CLOCKS-2;
  // Deliver the DLI one master clock after DMA releases the CPU bus.
  if zone_dli then begin
   zone_dli:=false;
   dli_clock:=a7800_video.dma_until+1;
  end;
  if offset=0 then begin
    dll:=word(dll+3);
    load_zone;
    // The next zone DLI belongs to the final DMA of the previous zone.
    if zone_dli then begin
     zone_dli:=false;
     dli_clock:=a7800_video.dma_until+1;
    end;
  end else dec(offset);
 end;
end;

procedure a7800_video_reset(pal:boolean);
begin
 fillchar(a7800_video,SizeOf(a7800_video),0);
 if pal then a7800_video.lines:=A78_LINES_PAL
  else a7800_video.lines:=A78_LINES_NTSC;
 a7800_video.regs[$1c]:=$60;
 prepared:=false;
 dma_started:=false;
 dli_clock:=-1;
 fillchar(line_ram,SizeOf(line_ram),0);
 dll:=0;
 display_list:=0;
 offset:=0;
 write_mode:=0;
 zone_dli:=false;
end;

procedure a7800_video_init(read_dma:ta78_dma_read;nmi:ta78_nmi;pal:boolean);
begin
  dma_read:=read_dma;
  nmi_callback:=nmi;
  a7800_video_reset(pal);
end;

function a7800_maria_read(reg:byte):byte;
begin
 if(reg and 31)=$08 then begin
  if(a7800_video.line<16) or (a7800_video.line>=a7800_video.lines-A78_VBLANK_LINES) then Result:=$80
    else Result:=0;
 end else Result:=$ff;
end;

procedure a7800_maria_write(reg,value:byte);
begin
 reg:=reg and 31;
 if reg=$04 then a7800_video.wsync:=true
  else if reg<>$08 then a7800_video.regs[reg]:=value;
end;

function a7800_video_blocked(is_read:boolean):boolean;
begin
 if(a7800_video.clock=28) and not prepared then prepare_dma;
 Result:=(is_read and a7800_video.wsync) or ((a7800_video.clock>=28) and (a7800_video.clock<a7800_video.dma_until));
end;

procedure a7800_video_tick;
begin
 if a7800_video.clock=dli_clock then begin
  dli_clock:=-1;
  if Assigned(nmi_callback) then nmi_callback;
 end;
 if(a7800_video.clock=28) and not prepared then prepare_dma;
 inc(a7800_video.clock);
 if a7800_video.clock=A78_LINE_CLOCKS then begin
  a7800_video.clock:=0;
  a7800_video.wsync:=false;
  a7800_video.dma_until:=0;
  prepared:=false;
  inc(a7800_video.line);
  if a7800_video.line=a7800_video.lines then begin
   a7800_video.line:=0;
   dma_started:=false;
   inc(a7800_video.frame_number);
   Move(a7800_video.working,a7800_video.completed,SizeOf(a7800_video.completed));
  end;
 end;
end;

procedure a7800_video_present;
var
  row:array[0..A78_WIDTH-1] of word;
  x,y:integer;
begin
 for y:=0 to A78_HEIGHT-1 do begin
  for x:=0 to A78_WIDTH-1 do row[x]:=paleta[a7800_video.completed[y,x]];
  putpixel(0,y,A78_WIDTH,@row[0],1);
 end;
 actualiza_trozo(0,0,A78_WIDTH,A78_HEIGHT,1,0,0,A78_WIDTH,A78_HEIGHT,PANT_TEMP);
end;

end.

