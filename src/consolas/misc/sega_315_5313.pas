unit sega_315_5313;

interface
uses sn_76496,windows;

type
  irq_type=procedure(state:boolean);
  vdp_dma_read=function(address:dword):word;
  vdp_5313_chip=class
    constructor create(pal:boolean);
    destructor free;
  public
    function read(direccion:byte):word;
    procedure write(direccion:byte;valor:word);
    procedure reset;
    procedure handle_scanline(linea:word);
    procedure handle_eof;
    procedure change_irqs(sndirq,irq4,irq6:irq_type);
    procedure change_dma_reader(reader:vdp_dma_read);
    procedure irq_ack(level:byte);
    procedure sound_update;
    procedure set_region(pal:boolean);
    procedure set_hpos(master_clock:integer);
    procedure change_lightgun_irq(callback:irq_type);
    procedure lightgun_position(x,y,xoffset,yoffset:integer);
    procedure lightgun_step(master_clock:integer;enabled:boolean);
    procedure lightgun_disable;
    function lightgun_th:boolean;
    function take_dma_clocks:integer;
  private
    vdp_pal,vblank_flag,sprite_collision,sprite_overflow:boolean;
    command_pending,irq4_pending,irq6_pending,vram_fill_pending:boolean;
    imode_odd_frame,vdp_code:byte;
    current_line,hpos,hcounter,visible_scanlines:integer;
    dma_clocks:integer;
    command_part1:word;
    vdp_address:dword; // A16 is latched even with the console's 64 KiB VRAM.
    regs:array[0..$1f] of byte;
    vram:array[0..$ffff] of byte;
    cram:array[0..$3f] of word;
    vsram:array[0..$3f] of word;
    colors:array[0..191] of word;
    pixels:array[0..239,0..319] of word;
    lv4irqline_callback,lv6irqline_callback,sndirq_callback:irq_type;
    dma_reader:vdp_dma_read;
    lightgun_irq:irq_type;
    gun_x,gun_y,gun_raw_y,gun_offset:integer;
    gun_fired,gun_hit,gun_latched,gun_temporary:boolean;
    gun_hv:word;
    sega_psg:sn76496_chip;
    function vword(address:integer):word;
    function data_port_read:word;
    procedure data_port_write(value:word);
    procedure control_port_write(value:word);
    procedure write_target(value:word);
    procedure run_dma;
    procedure update_palette(index:integer);
    procedure render_line(y:integer);
    function pattern_pixel(attr:word;px,py:integer):byte;
  end;
var
  vdp_5313_0:vdp_5313_chip;

const
  PAL_TOTAL_SCANLINES=313;
  NTSC_TOTAL_SCANLINES=262;
  PSG_CLOCK_NTSC=3579545;

implementation
uses main_engine,gfx_engine,pal_engine;

constructor vdp_5313_chip.create(pal:boolean);
var
  clock:dword;
begin
 vdp_pal:=pal;
 if pal then clock:=53203424 div 15
    else clock:=53693175 div 15;
 sega_psg:=sn76496_chip.Create(clock);
 screen_init(1,320,240);
 iniciar_video(320,240);
 reset;
end;

destructor vdp_5313_chip.free;
begin
 sega_psg.free;
end;

procedure vdp_5313_chip.change_irqs(sndirq,irq4,irq6:irq_type);
begin
 sndirq_callback:=sndirq;
 lv4irqline_callback:=irq4;
 lv6irqline_callback:=irq6;
end;

procedure vdp_5313_chip.irq_ack(level:byte);
begin
 if (level=2) and Assigned(lightgun_irq) then lightgun_irq(false);
 if level=6 then begin
  irq6_pending:=false;
  if Assigned(lv6irqline_callback) then lv6irqline_callback(false);
 end;
 if level=4 then begin
  irq4_pending:=false;
  if Assigned(lv4irqline_callback) then lv4irqline_callback(false);
 end;
end;

procedure vdp_5313_chip.change_dma_reader(reader:vdp_dma_read);
begin
  dma_reader:=reader;
end;

procedure vdp_5313_chip.set_region(pal:boolean);
begin
 vdp_pal:=pal;
 if pal then sega_psg.change_clock(53203424 div 15)
    else sega_psg.change_clock(53693175 div 15);
end;

procedure vdp_5313_chip.sound_update;
begin
  sega_psg.update;
end;

procedure vdp_5313_chip.set_hpos(master_clock:integer);
begin
  hpos:=master_clock mod 3420;
end;

function vdp_5313_chip.take_dma_clocks:integer;
begin
  Result:=dma_clocks;
  dma_clocks:=0;
end;

procedure vdp_5313_chip.change_lightgun_irq(callback:irq_type);
begin
 lightgun_irq:=callback;
end;

procedure vdp_5313_chip.lightgun_disable;
begin
 gun_x:=-1;
 gun_y:=-1;
 gun_hit:=false;
 gun_latched:=false;
 gun_temporary:=false;
 if Assigned(lightgun_irq) then lightgun_irq(false);
end;

procedure vdp_5313_chip.lightgun_position(x,y,xoffset,yoffset:integer);
begin
 // Keep viewport coordinates: a game can change H32/H40 after frame start.
 gun_x:=x;
 gun_raw_y:=y;
 gun_y:=y+yoffset;
 gun_offset:=xoffset;
 gun_fired:=false;
 if (x<0) or (x>=320) or (y<0) or (y>=240) or (gun_y<0) or (gun_y>=240) then begin
    gun_x:=-1;
    gun_y:=-1;
 end;
end;

procedure vdp_5313_chip.lightgun_step(master_clock:integer;enabled:boolean);
var
  width,dotclocks,h,period,active_x:integer;
begin
 if not enabled or gun_fired or (gun_x<0) or (current_line<>gun_y) then exit;
 width:=256;
 dotclocks:=10;
 period:=171;
 if (regs[12] and 1)<>0 then begin
    width:=320;
    dotclocks:=8;
    period:=210;
 end;
 active_x:=gun_x-(320-width) div 2;
 if (active_x<0) or (active_x>=width) or (gun_raw_y>=visible_scanlines) or (gun_y>=visible_scanlines) then exit;
 if master_clock<active_x*dotclocks then exit;
 gun_fired:=true;
 gun_hit:=true;
 // Menacer software expands the raw horizontal range to the display width.
 h:=((active_x*289 div width) div 2+gun_offset) mod period;
 if h<0 then inc(h,period);
 if period=210 then begin
    if h>$b6 then inc(h,$2e);
 end else if h>$93 then inc(h,$55);
 gun_hv:=((current_line and 255) shl 8)or(h and 255);
 gun_latched:=true;
 // T2 reads the counter without M3: keep this estimate for the hit line only.
 gun_temporary:=(regs[0] and 2)=0;
 if ((regs[11] and 8)<>0) and Assigned(lightgun_irq) then lightgun_irq(true);
end;

function vdp_5313_chip.lightgun_th:boolean;
begin
 Result:=not gun_hit;
end;

procedure vdp_5313_chip.update_palette(index:integer);
const
  levels:array[0..7] of byte=(0,36,73,109,146,182,219,255);
var
  c:tcolor;
  v:word;
  r,g,b,k:integer;
begin
 v:=cram[index];
 r:=levels[(v shr 1) and 7];
 g:=levels[(v shr 5) and 7];
 b:=levels[(v shr 9) and 7];
 for k:=0 to 2 do begin
  case k of
   1:begin
      c.r:=r div 2;
      c.g:=g div 2;
      c.b:=b div 2;
    end;
   2:begin
      c.r:=128+r div 2;
      c.g:=128+g div 2;
      c.b:=128+b div 2;
     end;
   else begin
            c.r:=r;
            c.g:=g;
            c.b:=b;
        end;
  end;
  set_pal_color(c,index+k*64);colors[index+k*64]:=paleta[index+k*64];
 end;
end;

procedure vdp_5313_chip.reset;
var
  i:integer;
begin
 FillChar(regs,SizeOf(regs),0);
 FillChar(vram,SizeOf(vram),0);
 FillChar(cram,SizeOf(cram),0);
 lightgun_disable;
 FillChar(vsram,SizeOf(vsram),0);
 FillChar(pixels,SizeOf(pixels),0);
 for i:=0 to 63 do update_palette(i);
 vblank_flag:=false;
 sprite_collision:=false;
 sprite_overflow:=false;
 command_pending:=false;
 irq4_pending:=false;
 irq6_pending:=false;
 vram_fill_pending:=false;
 command_part1:=0;
 vdp_address:=0;
 vdp_code:=0;
 current_line:=0;
 hpos:=0;
 hcounter:=0;
 visible_scanlines:=224;
 imode_odd_frame:=0;
 dma_clocks:=0;
 sega_psg.reset;
 if (@lv4irqline_callback<>nil) then lv4irqline_callback(false);
 if (@lv6irqline_callback<>nil) then lv6irqline_callback(false);
 if (@sndirq_callback<>nil) then sndirq_callback(false);
end;

function vdp_5313_chip.vword(address:integer):word;
begin
  Result:=(word(vram[address and $ffff]) shl 8) or vram[(address+1) and $ffff];
end;

procedure vdp_5313_chip.write_target(value:word);
var
  a:integer;
begin
 case vdp_code and 15 of
  1:begin
      if (regs[1] and $84)=$84 then begin
        // Mode 5, 128 KiB access wiring on a stock 64 KiB console.
        // Only D0-D7 reach VRAM. A0 is unused; A1 and A10 select lanes.
        a:=((vdp_address and $3fc) or ((vdp_address shr 1) and $fc01) or ((vdp_address shr 9) and 2)) xor 1;
        vram[a]:=value and $ff;
      end else begin
        a:=vdp_address and $fffe;
        if (vdp_address and 1)<>0 then value:=(value shr 8) or (value shl 8);
        vram[a]:=value shr 8;
        vram[a+1]:=value and $ff;
      end;
    end;
  3:begin
      a:=(vdp_address shr 1) and 63;
      cram[a]:=value and $eee;
      update_palette(a);
    end;
  5:begin
      a:=(vdp_address shr 1) and 63;
      if a<40 then vsram[a]:=value and $7ff;
    end;
 end;
 vdp_address:=(vdp_address+regs[15]) and $1ffff;
end;

function vdp_5313_chip.data_port_read:word;
var
  a:integer;
begin
 command_pending:=false;
 a:=vdp_address shr 1;
 Result:=$ffff;
 case vdp_code and 15 of
  0:Result:=vword(vdp_address and $fffe);
  4:if (a and 63)<40 then Result:=vsram[a and 63];
  8:Result:=cram[a and 63];
  12:Result:=$ff00 or vram[(vdp_address xor 1) and $ffff];
 end;
 vdp_address:=(vdp_address+regs[15]) and $1ffff;
end;

procedure vdp_5313_chip.data_port_write(value:word);
var
  count,n:integer;
begin
 command_pending:=false;
 if vram_fill_pending then begin
  vram_fill_pending:=false;
  n:=regs[19] or (integer(regs[20]) shl 8);
  if n=0 then n:=65536;
  // Low byte is a normal data-port byte; the high byte fills the opposite lane.
  vram[vdp_address and $ffff]:=value and $ff;
  for count:=1 to n do begin
   vram[(vdp_address xor 1) and $ffff]:=value shr 8;
   vdp_address:=(vdp_address+regs[15]) and $1ffff;
  end;
  regs[19]:=0;
  regs[20]:=0;
 end else write_target(value);
end;

procedure vdp_5313_chip.run_dma;
var
  source,source_base:dword;
  n,i,mode,words_per_line:integer;
  value:word;
begin
 if (regs[1] and $10)=0 then exit;
 n:=regs[19] or (integer(regs[20]) shl 8);
 if n=0 then n:=65536;
 mode:=regs[23] shr 6;
 if mode=2 then begin
  if (vdp_code and 15)=1 then vram_fill_pending:=true;
  exit;
 end;
 if mode=3 then begin
  // VRAM copy uses CD4 (command $30), not the CPU-write code $01.
  if(vdp_code and $10)=0 then exit;
  source:=regs[21] or (dword(regs[22]) shl 8);
  for i:=1 to n do begin
   vram[vdp_address and $ffff]:=vram[source and $ffff];
   source:=(source+1) and $ffff;
   vdp_address:=(vdp_address+regs[15]) and $1ffff;
  end;
  regs[21]:=source and $ff;
  regs[22]:=(source shr 8) and $ff;
 end else begin
  if not((vdp_code and 15) in [1,3,5]) then exit;
  source:=(dword(regs[21]) or (dword(regs[22]) shl 8) or (dword(regs[23] and $7f) shl 16)) shl 1;
  source_base:=source and $fe0000;
  for i:=1 to n do begin
   if (@dma_reader<>nil) then value:=dma_reader(source)
    else value:=$ffff;
   write_target(value);
   source:=source_base or ((source+2) and $1ffff);
  end;
  regs[21]:=(source shr 1)and $ff;
  regs[22]:=(source shr 9)and $ff;
  // High source register does not carry across the 128 KiB DMA boundary.
  // Approximate bus occupancy; FIFO/slot-accurate arbitration is not implemented.
  if vblank_flag or ((regs[1] and $40)=0) then begin
    words_per_line:=167;
    if (regs[12] and 1)<>0 then words_per_line:=205;
  end else begin
    words_per_line:=16;
    if (regs[12] and 1)<>0 then words_per_line:=18;
  end;
  // In 128 KiB access mode a VRAM word uses one byte-write slot.
  if ((vdp_code and 15)=1) and ((regs[1] and $84)=$84) then
    words_per_line:=words_per_line*2;
  inc(dma_clocks,(int64(n)*3420+words_per_line*7-1) div (words_per_line*7));
 end;
 regs[19]:=0;
 regs[20]:=0;
end;

procedure vdp_5313_chip.control_port_write(value:word);
var
  r:integer;
begin
 if command_pending then begin
  command_pending:=false;
  vdp_address:=(command_part1 and $3fff) or ((value and 7) shl 14);
  vdp_code:=((command_part1 shr 14) and 3) or ((value shr 2) and $3c);
  if (vdp_code and $20)<>0 then run_dma;
 end else if(value and $c000)=$8000 then begin
            r:=(value shr 8) and 31;
            regs[r]:=value and $ff;
            if (r=0) and ((value and 2)=0) then gun_latched:=false;
            vdp_code:=0;
            if (r=0) and (@lv4irqline_callback<>nil) then lv4irqline_callback(irq4_pending and ((regs[0] and $10)<>0));
            if (r=1) and (@lv6irqline_callback<>nil) then lv6irqline_callback(irq6_pending and ((regs[1] and $20)<>0));
          end else begin
            vram_fill_pending:=false;
            command_part1:=value;
            command_pending:=true;
            vdp_address:=(vdp_address and $1c000) or (value and $3fff);
            vdp_code:=(vdp_code and $3c) or (value shr 14);
          end;
end;

function vdp_5313_chip.read(direccion:byte):word;
var
  v,h:integer;
begin
 case direccion and $1e of
  0,2:Result:=data_port_read;
  4,6:begin
        Result:=$3600 or byte(vdp_pal) or (byte(hpos>=2560) shl 2)
          or (byte(vblank_flag or ((regs[1] and $40)=0)) shl 3)
          or (word(imode_odd_frame) shl 4) or (byte(sprite_collision) shl 5)
          or (byte(sprite_overflow) shl 6) or (byte(irq6_pending) shl 7);
        command_pending:=false;
        sprite_collision:=false;
        sprite_overflow:=false;
  end;
  8,10,12,14:begin
        if gun_latched then begin
          Result:=gun_hv;
          exit;
        end;
        v:=current_line;
        if not vdp_pal then begin
          if v>234 then dec(v,6);
        end else if visible_scanlines=240 then begin
                    if v>266 then dec(v,56);
                 end else if v>258 then dec(v,56);
        if (regs[12] and 1)<>0 then begin
            h:=hpos div 8;
            if h>182 then inc(h,28);
        end else begin
            h:=hpos div 10;
            if h>147 then inc(h,86);
        end;
        Result:=((v and 255) shl 8) or (h and 255);
       end;
  else Result:=$ffff;
 end;
end;

procedure vdp_5313_chip.write(direccion:byte;valor:word);
begin
 case direccion and $1e of
  0,2:data_port_write(valor);
  4,6:control_port_write(valor);
  $10,$12,$14,$16:sega_psg.write(valor and $ff);
 end;
end;

function vdp_5313_chip.pattern_pixel(attr:word;px,py:integer):byte;
var
  height,base:integer;
  b:byte;
begin
 height:=8;
 if (regs[12] and 6)=6 then height:=16;
 if (attr and $800)<>0 then px:=7-px;
 if (attr and $1000)<>0 then py:=height-1-py;
 base:=(attr and $7ff)*height*4+py*4+(px shr 1);
 b:=vram[base and $ffff];
 if (px and 1)=0 then b:=b shr 4;
 Result:=b and 15;
 if Result<>0 then Result:=Result or ((attr shr 9) and $30);
end;

procedure vdp_5313_chip.render_line(y:integer);
const
  dim:array[0..3] of integer=(32,64,32,128);
var
    pens,rank,light:array[0..319] of byte;
    spens:array[0..319] of byte;
    sprio:array[0..319] of boolean;
    x,active_width,left,plane,base,pw,ph,hsbase,hs,vs,wx,wy,sx,sy,ty,th:integer;
    attr:word;
    p:byte;
    pr,addr,link,limit,sprcount,pixelcount,sprx,spry,w,h,row,col,px,py,tile,i:integer;
    win,vertical_window,masked:boolean;
begin
 active_width:=256;
 if (regs[12] and 1)<>0 then active_width:=320;
 left:=(320-active_width) div 2;
 FillChar(pens,SizeOf(pens),regs[7]and 63);
 FillChar(rank,SizeOf(rank),0);
 FillChar(light,SizeOf(light),0);
 FillChar(spens,SizeOf(spens),0);
 if (regs[1] and $40)<>0 then begin
  // Intensity and visible-layer priority are separate signals in S/H mode.
  if (regs[12] and 8)<>0 then FillChar(light,SizeOf(light),1);
  th:=8;
  ty:=y;
  if (regs[12] and 6)=6 then begin
      th:=16;
      ty:=y*2+imode_odd_frame;
  end;
  pw:=dim[regs[16] and 3];
  ph:=dim[(regs[16] shr 4) and 3];
  hsbase:=(regs[13] and $3f) shl 10;
  case regs[11] and 3 of
   1:inc(hsbase,(y and 7)*4);
   2:inc(hsbase,(y and not 7)*4);
   3:inc(hsbase,y*4);
  end;
  vertical_window:=y<(regs[18] and 31)*8;
  if (regs[18]and $80)<>0 then vertical_window:=not vertical_window;
  for plane:=1 downto 0 do begin
   if plane=0 then base:=(regs[2] and $38) shl 10
    else base:=(regs[4] and 7) shl 13;
   hs:=vword(hsbase+plane*2);
   for x:=0 to active_width-1 do begin
    win:=false;
    if plane=0 then begin
     win:=x<(regs[17] and 31)*16;
     if(regs[17] and $80)<>0 then win:=not win;
     win:=win or vertical_window;
    end;
    if win then begin
     wx:=x;
     wy:=ty;
     addr:=(regs[3] and $3e) shl 10;
     if active_width=320 then addr:=(regs[3] and $3c) shl 10;
     i:=32;
     if active_width=320 then i:=64;
     attr:=vword(addr+((wy div th)*i+(wx div 8))*2);
     p:=pattern_pixel(attr,wx and 7,wy mod th);
    end else begin
     if (regs[11] and 4)<>0 then vs:=vsram[((x div 16)*2+plane) mod 40]
        else vs:=vsram[plane];
     sx:=(x-hs) and (pw*8-1);
     sy:=(ty+vs) and (ph*th-1);
     attr:=vword(base+((sy div th)*pw+(sx div 8))*2);
     p:=pattern_pixel(attr,sx and 7,sy mod th);
    end;
    // A high-priority tile also selects normal intensity when its pixel is transparent.
    if ((regs[12]and 8)<>0) and ((attr and $8000)<>0) then light[x+left]:=0;
    if (p and 15)=0 then continue;
    pr:=2-plane;
    if (attr and $8000)<>0 then inc(pr,3);
    if pr>=rank[x+left] then begin
        pens[x+left]:=p;
        rank[x+left]:=pr;
    end;
   end;
  end;
  base:=(regs[5] and $7f) shl 9;
  limit:=64;
  if active_width=320 then begin
      base:=base and $fc00;
      limit:=80;
  end;
  link:=0;
  sprcount:=0;
  pixelcount:=0;
  masked:=false;
  for i:=0 to limit-1 do begin
    addr:=base+link*8;
    spry:=(vword(addr) and $3ff)-128;
    attr:=vword(addr+2);
    w:=((attr shr 10) and 3)+1;
    h:=((attr shr 8) and 3)+1;
    row:=ty-spry;
    if (row>=0) and (row<h*th) then begin
        inc(sprcount);
        if sprcount>active_width div 16 then begin
            sprite_overflow:=true;
            break;
        end;
        sprx:=vword(addr+6) and $1ff;
        if (sprx=0) and (pixelcount<>0) then masked:=true;
        inc(pixelcount,w*8);
        attr:=vword(addr+4);
        if not masked then for col:=0 to w*8-1 do begin
          if pixelcount-w*8+col>=active_width then begin
            sprite_overflow:=true;
            break;
          end;
          x:=sprx-128+col;
          if (x<0) or (x>=active_width) then continue;
          px:=col;
          py:=row;
          if (attr and $800)<>0 then px:=w*8-1-px;
          if (attr and $1000)<>0 then py:=h*th-1-py;
          tile:=((attr and $7ff)+(px div 8)*h+py div th) and $7ff;
          p:=pattern_pixel((attr and $e000) or tile,px and 7,py mod th);
          if (p and 15)=0 then continue;
          if spens[x]<>0 then sprite_collision:=true
            else begin
                    spens[x]:=p;
                    sprio[x]:=(attr and $8000)<>0;
                 end;
        end;
    end;
    link:=vword(addr+2) and $7f;
    if link=0 then break;
  end;
  for x:=0 to active_width-1 do if spens[x]<>0 then begin
    pr:=3;
    if sprio[x]then pr:=6;
    if pr>=rank[x+left]then begin
        if((regs[12]and 8)<>0) and (spens[x]>=62)then begin
          if spens[x]=62 then begin
            // Highlight raises shadow to normal, and normal to highlight.
            if light[x+left]=1 then light[x+left]:=0
              else light[x+left]:=2;
          end else light[x+left]:=1;
        end else begin
            pens[x+left]:=spens[x];
            // Low-priority sprites inherit the background intensity. Pen 14
            // in palettes 0-2 always displays at normal intensity.
            if ((regs[12]and 8)<>0) and (sprio[x] or ((spens[x] and 15)=14)) then light[x+left]:=0;
            rank[x+left]:=pr;
        end;
   end;
  end;
  if (regs[0] and $20)<>0 then for x:=left to left+7 do begin
    pens[x]:=regs[7] and 63;
    rank[x]:=0;
    if(regs[12] and 8)<>0 then light[x]:=1;
  end;
 end;
 for x:=0 to 319 do pixels[y,x]:=colors[pens[x]+light[x]*64];
end;

procedure vdp_5313_chip.handle_scanline(linea:word);
begin
 current_line:=linea;
 gun_hit:=false;
 if gun_temporary then begin
    gun_latched:=false;
    gun_temporary:=false;
 end;
 hpos:=0;
 if linea=0 then begin
  vblank_flag:=false;
  // Pending requests belong to the VDP latch, not to the video frame.
  // Only reset or the CPU interrupt-acknowledge cycle clears them.
  hcounter:=regs[10];
  sprite_collision:=false;
  sprite_overflow:=false;
  visible_scanlines:=224;
  if (regs[1] and 8)<>0 then visible_scanlines:=240;
 end;
 if linea<visible_scanlines then begin
  render_line(linea);
  dec(hcounter);
  if hcounter<0 then begin
   hcounter:=regs[10];
   irq4_pending:=true;
   if (@lv4irqline_callback<>nil) and ((regs[0] and $10)<>0) then lv4irqline_callback(true);
  end;
 end else hcounter:=regs[10];
 if linea=visible_scanlines then begin
  vblank_flag:=true;
  irq6_pending:=true;
  if (@lv6irqline_callback<>nil) and ((regs[1] and $20)<>0) then lv6irqline_callback(true);
  if (@sndirq_callback<>nil) then sndirq_callback(true);
 end;
 if(linea=visible_scanlines+1)and Assigned(sndirq_callback)then sndirq_callback(false);
end;

procedure vdp_5313_chip.handle_eof;
var
  y:integer;
  blank:array[0..319]of word;
begin
 FillChar(blank,SizeOf(blank),0);
 for y:=0 to 239 do if y<visible_scanlines then putpixel(0,y,320,@pixels[y,0],1)
                        else putpixel(0,y,320,@blank[0],1);
 actualiza_trozo(0,0,320,240,1,0,0,320,240,PANT_TEMP);
 imode_odd_frame:=imode_odd_frame xor 1;
end;

end.
