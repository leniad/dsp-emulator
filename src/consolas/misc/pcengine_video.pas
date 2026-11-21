unit pcengine_video;
interface

const
  PCE_MAX_WIDTH=512;
  PCE_MAX_HEIGHT=256;
  PCE_MASTER_CLOCK=21477270;
  PCE_LINE_CLOCKS=1365;

type
  tpce_irq=procedure(state:boolean);
  tpcengine_video=class
  public
    total_lines:integer;
    constructor create(irq:tpce_irq);
    procedure reset;
    function vdc_read(port:byte):byte;
    procedure vdc_write(port,value:byte);
    function vce_read(port:byte):byte;
    procedure vce_write(port,value:byte);
    procedure scanline(line:integer);
    procedure latch_scroll;
    procedure latch_horizontal;
    function horizontal_latch_clock:integer;
    function scroll_latch_clock:integer;
    procedure hblank;
    procedure present;
    function width:integer;
  private
    regs:array[0..31] of word;
    vram:array[0..$7fff] of word;
    sat:array[0..255] of word;
    palette:array[0..511] of word;
    rgb:array[0..511] of word;
    pixels:array[0..PCE_MAX_HEIGHT-1,0..PCE_MAX_WIDTH-1] of word;
    raster_count:integer;
    pending_y,output_y:integer;
    selected,status,vce_control:byte;
    vce_address,read_buffer,write_buffer:word;
    sat_pending,vblank_done:boolean;
    sat_countdown,dma_countdown,shown_width,scroll_y:integer;
    shown_height:integer;
    latched_y,latched_x:integer;
    irq_callback:tpce_irq;
    procedure irq_update;
    procedure set_status(mask:byte);
    procedure update_color(index:integer);
    procedure dma;
    procedure render(y:integer);
    function vr(a:integer):word;
    function increment_vram:integer;
  end;

var
  pcevideo_0:tpcengine_video;

implementation
uses main_engine,gfx_engine,pal_engine;

const
  CROP_TOP=1;
  CROP_BOTTOM=7;

constructor tpcengine_video.create(irq:tpce_irq);
begin
  irq_callback:=irq;
  shown_width:=256;
  shown_height:=0;
  reset;
end;

function tpcengine_video.vr(a:integer):word;
begin
  if (a>=0) and (a<$8000) then result:=vram[a]
    else result:=0;
end;

function tpcengine_video.increment_vram:integer;
const
  steps:array[0..3] of integer=(1,32,64,128);
begin
  result:=steps[(regs[5] shr 11) and 3];
end;

function tpcengine_video.width:integer;
begin
  result:=((regs[$b] and $7f)+1)*8;
  if result>512 then result:=512;
  if result<8 then result:=8;
end;

procedure tpcengine_video.irq_update;
var
  pending:boolean;
begin
 pending:=((status and byte(regs[5]) and 7)<>0) or
   (((status and $20)<>0) and ((regs[5] and 8)<>0)) or
   (((status and 8)<>0) and ((regs[$f] and 1)<>0)) or
   (((status and $10)<>0)and ((regs[$f] and 2)<>0));
 if Assigned(irq_callback) then irq_callback(pending);
end;

procedure tpcengine_video.set_status(mask:byte);
begin
  status:=status or mask;
  irq_update;
end;

procedure tpcengine_video.update_color(index:integer);
var
  c:tcolor;
  v:word;
  k:integer;
begin
 v:=palette[index];
 c.r:=((v shr 3) and 7)*255 div 7;
 c.g:=((v shr 6) and 7)*255 div 7;
 c.b:=(v and 7)*255 div 7;
 if (vce_control and $80)<>0 then begin
    k:=(integer(c.r)*30+integer(c.g)*59+integer(c.b)*11)div 100;
    c.r:=k;
    c.g:=k;
    c.b:=k;
 end;
 set_pal_color(c,index);
 rgb[index]:=paleta[index];
end;

procedure tpcengine_video.reset;
var
  i:integer;
begin
 FillChar(regs,SizeOf(regs),0);
 FillChar(vram,SizeOf(vram),0);
 FillChar(sat,SizeOf(sat),0);
 FillChar(palette,SizeOf(palette),0);
 FillChar(pixels,SizeOf(pixels),0);
 regs[$b]:=31;
 regs[$c]:=$0f02;
 regs[$d]:=239;
 raster_count:=-1;
 pending_y:=-1;
 output_y:=-1;
 selected:=0;
 status:=0;
 vce_control:=0;
 vce_address:=0;
 read_buffer:=0;
 write_buffer:=0;
 sat_pending:=false;
 vblank_done:=false;
 sat_countdown:=0;
 dma_countdown:=0;
 scroll_y:=0;
 latched_y:=0;
 latched_x:=0;
 for i:=0 to 511 do update_color(i);
 total_lines:=262;
 irq_update;
end;

function tpcengine_video.vdc_read(port:byte):byte;
begin
 result:=0;
 case port and 3 of
   0:begin
        result:=status;
        if dma_countdown<>0 then result:=result or $40;
        status:=0;irq_update;
     end;
   2:result:=read_buffer and $ff;
   3:begin
      result:=read_buffer shr 8;
      if selected=2 then begin
          regs[1]:=word(regs[1]+increment_vram);
          read_buffer:=vr(regs[1]);
      end;
   end;
 end;
end;

procedure tpcengine_video.dma;
var
  i,n,ss,ds:integer;
  source,dest:word;
begin
 n:=integer(regs[$12])+1;
 source:=regs[$10];
 dest:=regs[$11];
 ss:=1;
 ds:=1;
 if (regs[$f] and 4)<>0 then ss:=-1;
 if (regs[$f] and 8)<>0 then ds:=-1;
 for i:=1 to n do begin
   if dest<$8000 then vram[dest]:=vr(source);
   source:=word(integer(source)+ss);
   dest:=word(integer(dest)+ds);
 end;
 regs[$10]:=source;
 regs[$11]:=dest;
 regs[$12]:=$ffff;
 dma_countdown:=1+n div 228;
end;

procedure tpcengine_video.vdc_write(port,value:byte);
var
  r:integer;
begin
 case port and 3 of
   0:selected:=value and 31;
   2,3:begin
     r:=selected;
     if (port and 1)=0 then regs[r]:=(regs[r] and $ff00) or value
       else regs[r]:=(regs[r] and $ff) or (word(value) shl 8);
     case r of
       1:read_buffer:=vr(regs[1]);
       2:begin
         write_buffer:=regs[2];
         if(port and 1)<>0 then begin
           if regs[0]<$8000 then vram[regs[0]]:=write_buffer;
           regs[0]:=word(regs[0]+increment_vram);
         end;
       end;
       5,$f:irq_update;
       6:regs[6]:=regs[6] and $3ff;
       8:begin
            scroll_y:=regs[8] and $1ff;
         end;
       $12:if (port and 1)<>0 then dma;
       $13:if (port and 1)<>0 then sat_pending:=true;
     end;
   end;
 end;
end;

function tpcengine_video.vce_read(port:byte):byte;
begin
 result:=$ff;
 case port and 7 of
   4:result:=palette[vce_address]and $ff;
   5:begin
        result:=$fe or (palette[vce_address] shr 8);
        vce_address:=(vce_address+1) and 511;
     end;
 end;
end;

procedure tpcengine_video.vce_write(port,value:byte);
var
  i:integer;old:byte;
begin
 case port and 7 of
   0:begin
      old:=vce_control;
      vce_control:=value;
      if ((old xor value) and $80)<>0 then for i:=0 to 511 do update_color(i);
      if (vce_control and 4)<>0 then total_lines:=262
        else total_lines:=263;
     end;
   2:vce_address:=(vce_address and $100) or value;
   3:vce_address:=(vce_address and $ff) or (word(value and 1) shl 8);
   4:begin
        palette[vce_address]:=(palette[vce_address] and $100) or value;
        update_color(vce_address);
     end;
   5:begin
        palette[vce_address]:=(palette[vce_address]and $ff) or (word(value and 1) shl 8);
        update_color(vce_address);
        vce_address:=(vce_address+1) and 511;
     end;
 end;
end;

procedure tpcengine_video.render(y:integer);
const
  map_width:array[0..3] of integer=(32,64,128,128);
  heights:array[0..3] of integer=(16,32,64,64);
var
  bg:array[0..511] of byte;
  sp:array[0..511] of word;
  owner:array[0..511] of smallint;
  x,w,mw,mh,sx,sy,a,tile,row,bitn,pen,i,sx0,sy0,h,sw,py,px,col,pattern,attr,cells:integer;
  v1,v2,att:word;
  visible:boolean;
begin
 if (y<0) or (y>=256) or (output_y<0) or (output_y>=256) then exit;
 w:=width;
 FillChar(bg,SizeOf(bg),0);
 FillChar(sp,SizeOf(sp),0);
 FillChar(owner,SizeOf(owner),$ff);
 if (regs[5]and $80)<>0 then begin
   mw:=map_width[(regs[9] shr 4) and 3];
   mh:=32;
   if (regs[9] and $40)<>0 then mh:=64;
   sy:=latched_y and (mh*8-1);
   for x:=0 to w-1 do begin
     sx:=(x+latched_x) and (mw*8-1);
     att:=vr((sy shr 3)*mw+(sx shr 3));
     tile:=att and $fff;
     a:=tile*16+(sy and 7);
     v1:=vr(a);
     v2:=vr(a+8);
     bitn:=7-(sx and 7);
     pen:=((v1 shr bitn) and 1) or (((v1 shr (bitn+8)) and 1) shl 1) or (((v2 shr bitn) and 1) shl 2) or (((v2 shr (bitn+8)) and 1) shl 3);
     if pen<>0 then bg[x]:=((att shr 8) and $f0) or pen;
   end;
 end;
 if (regs[5]and $40)<>0 then begin
   cells:=0;
   for i:=0 to 63 do begin
     sy0:=(sat[i*4] and $3ff)-64;
     sx0:=(sat[i*4+1] and $3ff)-32;
     attr:=sat[i*4+3];
     h:=heights[(attr shr 12) and 3];
     sw:=16;
     if (attr and $100)<>0 then sw:=32;
     row:=y-sy0;
     if (row<0) or (row>=h) then continue;
     inc(cells,sw div 16);
     if cells>16 then begin
        if (regs[5] and 2)<>0 then set_status(2);
        break;
     end;
     pattern:=(sat[i*4+2] shr 1) and $3ff;
     if h>=32 then pattern:=pattern and not 2;
     if h=64 then pattern:=pattern and not 6;
     if sw=32 then pattern:=pattern and not 1;
     py:=row;
     if(attr and $8000)<>0 then py:=h-1-py;
     for col:=0 to sw-1 do begin
       x:=sx0+col;
       if(x<0) or (x>=w) then continue;
       px:=col;
       if (attr and $800)<>0 then px:=sw-1-px;
       tile:=pattern+(py div 16)*2+(px div 16);
       a:=tile*64+(py and 15);
       bitn:=15-(px and 15);
       if (regs[9] and $0c)=$04 then begin
          // 2bpp sprite mode: pattern bit 0 selects planes 0/1 or 2/3.
          a:=a+((sat[i*4+2] and 1) shl 5);
          pen:=((vr(a) shr bitn) and 1) or (((vr(a+16) shr bitn) and 1) shl 1);
       end else pen:=((vr(a) shr bitn) and 1) or (((vr(a+16) shr bitn) and 1) shl 1) or (((vr(a+32) shr bitn) and 1) shl 2) or (((vr(a+48) shr bitn) and 1) shl 3);
       if pen=0 then continue;
       if owner[x]>=0 then begin
          if(owner[x]=0) and ((regs[5] and 1)<>0) then set_status(1);
          continue;
       end;
       owner[x]:=i;sp[x]:=$100 or ((attr and 15) shl 4) or pen;
       if (attr and $80)<>0 then sp[x]:=sp[x] or $8000;
     end;
   end;
 end;
 for x:=0 to w-1 do begin
   visible:=(sp[x]<>0) and (((sp[x] and $8000)<>0) or (bg[x]=0));
   if visible then pixels[output_y,x]:=rgb[sp[x] and 511]
    else pixels[output_y,x]:=rgb[bg[x]];
 end;
end;

procedure tpcengine_video.scanline(line:integer);
var
  first,height,y,i:integer;
begin
 // Keep the viewport fixed: VPR changes move the active display.
 output_y:=line-20;
 first:=(regs[$c] and 31)+1+(regs[$c] shr 8)+2;
 height:=(regs[$d] and $1ff)+1;
 if line=0 then begin
   vblank_done:=false;
   for y:=0 to 255 do for i:=0 to 511 do pixels[y,i]:=rgb[$100];
 end;
 if sat_countdown>0 then begin
    dec(sat_countdown);
    if(sat_countdown=0) and ((regs[$f] and 1)<>0) then set_status(8);
 end;
 if dma_countdown>0 then begin
    dec(dma_countdown);
    if(dma_countdown=0) and ((regs[$f] and 2)<>0) then set_status($10);
 end;
 y:=line-first;
 // Prepare the row now; sample its final scroll and pixels at HBlank.
 pending_y:=y;
 // Keep counting across VSYNC and the frame boundary, including the
 // top blanking lines. Only display start reloads the raster counter.
 // The first active row has count 64; HBlank compares the next count.
 // Air Zonk uses RCR=320 in top blanking to arm the next raster chain.
 if y=0 then raster_count:=64
   else raster_count:=(raster_count+1) and $3ff;
 // Oversized VDW/VPR settings can place the programmed display end
 // beyond this frame. VSYNC still closes the frame and forces VBlank.
 // This scanline implementation applies that fallback on its last line.
 // Acknowledge reads must not allow a second VBlank/SATB DMA this frame.
 if not vblank_done and ((line=first+height) or (line=self.total_lines-1))then begin
   vblank_done:=true;
   if (regs[5] and 8)<>0 then set_status($20);
   if sat_pending or ((regs[$f] and $10)<>0) then begin
     for i:=0 to 255 do sat[i]:=vr((integer(regs[$13])+i) and $7fff);
     sat_pending:=false;
     sat_countdown:=4;
   end;
 end;
end;

// External HSync releases the VDC into an 8-dot phase; BYR latches
// one dot after HDS starts (later when HDS exceeds two character clocks).
function tpcengine_video.scroll_latch_clock:integer;
var hds,n:integer;
begin
 hds:=(regs[$a] shr 8) and $7f;
 n:=9;
 if hds>2 then n:=n+(hds+1)*8-22;
 case vce_control and 3 of
  0:result:=(n*4+2) div 3;
  1:result:=n;
  else result:=(n*2+2) div 3;
 end;
 if result>376 then result:=376;
end;

// BXR is sampled one or two VDC dots after BYR, depending on HDS.
function tpcengine_video.horizontal_latch_clock:integer;
var hds,n:integer;
begin
 hds:=(regs[$a] shr 8) and $7f;
 if hds>2 then n:=9+(hds+1)*8-22+1 else n:=11;
 case vce_control and 3 of
  0:result:=(n*4+2) div 3;
  1:result:=n;
  else result:=(n*2+2) div 3;
 end;
 if result>376 then result:=376;
end;

procedure tpcengine_video.latch_horizontal;
begin
 latched_x:=regs[7];
end;

procedure tpcengine_video.latch_scroll;
begin
 if pending_y=0 then scroll_y:=regs[8] and $1ff
 else if (pending_y>0) and (pending_y<=integer(regs[$d]and $1ff)) then scroll_y:=(scroll_y+1)and $1ff;
 // Preserve this row: subsequent BYR writes affect the internal counter only.
 latched_y:=scroll_y;
end;

procedure tpcengine_video.hblank;
var
  y,height,compare_count:integer;
begin
 // CPU writes during the active part of this line must be visible
 // before committing it. Do this before asserting the next raster IRQ.
 y:=pending_y;height:=(regs[$d]and $1ff)+1;
 if (y>=0) and (y<height) then render(y);
 // At display end the raster count advances before the IRQ comparison.
 // Scroll used by this row was latched near HSync, before later BYR writes.
 compare_count:=(raster_count+1) and $3ff;
 // Display start reloads the next raster count to 64, rather than
 // inheriting the overscan count from the previous frame.
 if pending_y=-1 then compare_count:=64;
 if (raster_count>=0) and (compare_count=(regs[6] and $3ff)) and ((regs[5]and 4)<>0) then set_status(4);
end;

procedure tpcengine_video.present;
var
  y,w,h:integer;
begin
 w:=width;
 h:=240-CROP_TOP-CROP_BOTTOM;
 // Crop presentation only. All scanlines, scroll updates and IRQs still
 // execute, and the complete image remains available in pixels[].
 if (shown_width<>w) or (shown_height<>h) then begin
    shown_width:=w;
    shown_height:=h;
    change_video_size(w,h);
 end;
 for y:=0 to h-1 do putpixel(0,y,w,@pixels[y+CROP_TOP,0],1);
 actualiza_trozo(0,0,w,h,1,0,0,w,h,PANT_TEMP);
end;

end.
