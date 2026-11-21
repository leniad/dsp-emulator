unit taito_tc0180vcu;

interface
uses main_engine,gfx_engine;

type
  tc0180vcu_chip=class
    constructor create(pant:byte;txt_color,bg_color,fg_color,gen_color:word);
    destructor free;
    public
      function read(direccion:dword):word;
      procedure write(direccion:dword;valor:word;mem_mask:word=$ffff);
      procedure reset;
      procedure draw;
      procedure draw_sprites;
      procedure vblank_update;
    private
      pant:byte;
      fg_rambank,bg_rambank:array[0..1] of word;
      tx_rambank:word;
      framebuffer_page,video_control:byte;
      fb_color_base,bg_color_base,fg_color_base,tx_color_base:word;
      ctrl:array[0..$f] of word;
      ram:array[0..$9fff] of word;
      framebuffer:array[0..1,0..255,0..511] of word;
      function tile_pixel(layer:byte;x,y:integer):word;
      procedure sprite_tile(code,color:word;flipx,flipy:boolean;x,y,w,h:integer);
  end;

var
  tc0180vcu_0:tc0180vcu_chip;

implementation
uses pal_engine;

constructor tc0180vcu_chip.create(pant:byte;txt_color,bg_color,fg_color,gen_color:word);
begin
  self.pant:=pant;
  self.tx_color_base:=txt_color;
  self.bg_color_base:=bg_color;
  self.fg_color_base:=fg_color;
  self.fb_color_base:=gen_color shl 4;
  fillchar(self.ram,$a000*2,0);
  fillchar(self.framebuffer,$40000*2,0);
  reset;
end;

destructor tc0180vcu_chip.free;
begin
end;

procedure tc0180vcu_chip.reset;
begin
  fillchar(self.ctrl,4,0);
  fillchar(self.fg_rambank,4,0);
  fillchar(self.bg_rambank,4,0);
  self.tx_rambank:=0;
  self.framebuffer_page:=0;
  self.video_control:=0;
end;

function tc0180vcu_chip.read(direccion:dword):word;
var
  offset,sy,sx:integer;
begin
  result:=$ffff;
  case direccion of
    0..$13fff:result:=ram[direccion shr 1];
    $18000..$1801f:result:=ctrl[(direccion and $1f) shr 1];
    $40000..$7ffff:begin
      offset:=(direccion-$40000) shr 1;
      sy:=offset shr 8;sx:=(offset and $ff)*2;
      result:=word((framebuffer[sy shr 8,sy and $ff,sx] shl 8) or framebuffer[sy shr 8,sy and $ff,sx+1]);
    end;
  end;
end;

procedure tc0180vcu_chip.write(direccion:dword;valor:word;mem_mask:word);
var
  offset,sy,sx:integer;
begin
  case direccion of
    0..$13fff:ram[direccion shr 1]:=(ram[direccion shr 1] and (word(not mem_mask))) or (valor and mem_mask);
    $18000..$1801f:begin
      offset:=(direccion and $1f) shr 1;
      valor:=(ctrl[offset] and (word(not mem_mask))) or (valor and mem_mask);
      if ctrl[offset]=valor then exit;
      ctrl[offset]:=valor;
      case offset of
        0:begin
          fg_rambank[0]:=((valor shr 8)and 7)shl 12;
          fg_rambank[1]:=((valor shr 12)and 7)shl 12;
        end;
        1:begin
          bg_rambank[0]:=((valor shr 8)and 7)shl 12;
          bg_rambank[1]:=((valor shr 12)and 7)shl 12;
        end;
        6:tx_rambank:=((valor shr 8)and $f)shl 11;
        7:begin
          video_control:=valor shr 8;
          if (video_control and $80)<>0 then framebuffer_page:=((video_control xor $ff)and $40)shr 6;
        end;
      end;
    end;
    $40000..$7ffff:begin
      offset:=(direccion-$40000)shr 1;
      sy:=offset shr 8;
      sx:=(offset and $ff)*2;
      if (mem_mask and $ff00)<>0 then framebuffer[sy shr 8,sy and $ff,sx]:=valor shr 8;
      if (mem_mask and $00ff)<>0 then framebuffer[sy shr 8,sy and $ff,sx+1]:=valor and $ff;
    end;
  end;
end;

function tc0180vcu_chip.tile_pixel(layer:byte;x,y:integer):word;
var
  tile,attr,code,color,px,py,ngfx:integer;
  p:pbyte;
begin
  if layer=2 then begin
    x:=x and $1ff;
    y:=y and $ff;
    tile:=(y shr 3)*64+(x shr 3);
    attr:=ram[tx_rambank+tile];
    code:=((attr and $7ff) or ((ctrl[4+((attr shr 11) and 1)] shr 8) shl 11));
    color:=(tx_color_base+((attr shr 12) and $f)) shl 4;
    px:=x and 7;
    py:=y and 7;
    ngfx:=0;
  end else begin
    x:=x and $3ff;
    y:=y and $3ff;
    tile:=(y shr 4)*64+(x shr 4);
    if layer=0 then begin
      code:=ram[bg_rambank[0]+tile];
      attr:=ram[bg_rambank[1]+tile];
      color:=(bg_color_base+(attr and $3f)) shl 4;
    end else begin
      code:=ram[fg_rambank[0]+tile];
      attr:=ram[fg_rambank[1]+tile];
      color:=(fg_color_base+(attr and $3f)) shl 4;
    end;
    px:=x and 15;
    py:=y and 15;
    ngfx:=1;
    if (attr and $40)<>0 then px:=15-px;
    if (attr and $80)<>0 then py:=15-py;
  end;
  result:=0;
  if (gfx[ngfx].datos=nil) or (gfx[ngfx].elements=0) then exit;
  code:=code mod integer(gfx[ngfx].elements);
  p:=gfx[ngfx].datos;
  inc(p,code*gfx[ngfx].x*gfx[ngfx].y+py*gfx[ngfx].x+px);
  // Zero pen is transparent only on FG and TX; BG pen zero is opaque.
  if ((layer<>0) and (p^=0)) then exit;
  result:=color+p^;
end;

procedure tc0180vcu_chip.draw;
var
  x,y,lx,ly,fbx,fby,bgx,bgy,fgx,fgy,bh,fh,bi,fi:integer;
  c,s,p:word;
  flip,all_sprites:boolean;
  line:array[0..319] of word;
begin
  if (video_control and $20)=0 then begin
    // Video disabled is palette entry zero, irrespective of the BG colour base.
    for x:=0 to 319 do line[x]:=paleta[0];
    for y:=16 to 239 do putpixel(ADD_SPRITE,y+ADD_SPRITE,320,@line[0],self.pant);
    exit;
  end;
  flip:=(video_control and $10)<>0;
  all_sprites:=(video_control and 8)<>0;
  bh:=256-(ctrl[3] shr 8);
  fh:=256-(ctrl[2] shr 8);
  for y:=16 to 239 do begin
    ly:=y;
    if flip then ly:=255-y;
    bi:=ly div bh;
    fi:=ly div fh;
    // Scroll entries are spaced by two words per line in each block.
    bgx:=ram[$9e00+bi*2*bh];
    bgy:=ram[$9e01+bi*2*bh];
    fgx:=ram[$9c00+fi*2*fh];
    fgy:=ram[$9c01+fi*2*fh];
    for x:=0 to 319 do begin
      lx:=x;
      fbx:=x;
      fby:=y;
      if flip then begin
        lx:=319-x;
        fbx:=319-x;
        fby:=255-y;
      end;
      c:=tile_pixel(0,lx-bgx,ly-bgy);
      s:=framebuffer[framebuffer_page,fby,fbx];
      if ((not all_sprites) and (s<>0) and ((s and $10)<>0)) then c:=fb_color_base+s;
      p:=tile_pixel(1,lx-fgx,ly-fgy);
      if p<>0 then c:=p;
      if ((s<>0) and (all_sprites or ((s and $10)=0))) then c:=fb_color_base+s;
      p:=tile_pixel(2,lx,ly);
      if p<>0 then c:=p;
      line[x]:=paleta[c and $fff];
    end;
    putpixel(ADD_SPRITE,y+ADD_SPRITE,320,@line[0],self.pant);
  end;
end;

procedure tc0180vcu_chip.sprite_tile(code,color:word;flipx,flipy:boolean;x,y,w,h:integer);
var
  dx,dy,sx,sy,firstx,lastx,firsty,lasty,stepx,stepy:integer;
  p:pbyte;
  pen:byte;
begin
  if ((w<=0) or (h<=0)) then exit;
  firstx:=0;
  lastx:=w-1;
  firsty:=0;
  lasty:=h-1;
  if x<0 then firstx:=-x;
  if y<16 then firsty:=16-y;
  if x+lastx>319 then lastx:=319-x;
  if y+lasty>239 then lasty:=239-y;
  if (firstx>lastx) or (firsty>lasty) then exit;
  code:=code mod gfx[1].elements;
  p:=gfx[1].datos;
  inc(p,integer(code)*256);
  // Match the fixed-point nearest-neighbour zoom used by MAME drawgfx.
  stepx:=(16 shl 16) div w;
  stepy:=(16 shl 16) div h;
  for dy:=firsty to lasty do begin
    if flipy then sy:=((h-1-dy)*stepy) shr 16
      else sy:=(dy*stepy) shr 16;
    for dx:=firstx to lastx do begin
      if flipx then sx:=((w-1-dx)*stepx) shr 16
        else sx:=(dx*stepx) shr 16;
      pen:=p[sy*16+sx];
      if pen<>0 then framebuffer[framebuffer_page,y+dy,x+dx]:=color+pen;
    end;
  end;
end;

procedure tc0180vcu_chip.draw_sprites;
var
  f,base,code,attr,color,x,y,data,x_num,y_num,x_no,y_no:integer;
  xlatch,ylatch,zoomxlatch,zoomylatch,zoomx,zoomy,zx,zy:integer;
  flipx,flipy,big_sprite:boolean;
begin
  xlatch:=0;
  ylatch:=0;
  x_no:=0;
  y_no:=0;
  x_num:=0;
  y_num:=0;
  zoomxlatch:=0;
  zoomylatch:=0;
  big_sprite:=false;
  for f:=$197 downto 0 do begin
    base:=$8000+f*8;
    code:=ram[base];
    attr:=ram[base+1];
    flipx:=(attr and $4000)<>0;
    flipy:=(attr and $8000)<>0;
    color:=(attr and $3f) shl 4;
    x:=ram[base+2] and $3ff;
    y:=ram[base+3] and $3ff;
    if x>=$200 then dec(x,$400);
    if y>=$200 then dec(y,$400);
    data:=ram[base+5];
    if (data<>0) and not big_sprite then begin
      x_num:=data shr 8;
      y_num:=data and $ff;
      x_no:=0;
      y_no:=0;
      xlatch:=x;
      ylatch:=y;
      zoomxlatch:=ram[base+4] shr 8;
      zoomylatch:=ram[base+4] and $ff;
      big_sprite:=true;
    end;
    zoomx:=ram[base+4] shr 8;
    zoomy:=ram[base+4] and $ff;
    zx:=($100-zoomx) div 16;
    zy:=($100-zoomy) div 16;
    if big_sprite then begin
      zoomx:=zoomxlatch;
      zoomy:=zoomylatch;
      x:=xlatch+(x_no*($ff-zoomx)+15) div 16;
      y:=ylatch+(y_no*($ff-zoomy)+15) div 16;
      zx:=xlatch+((x_no+1)*($ff-zoomx)+15) div 16-x;
      zy:=ylatch+((y_no+1)*($ff-zoomy)+15) div 16-y;
      inc(y_no);
      if y_no>y_num then begin
        y_no:=0;
        inc(x_no);
        if x_no>x_num then big_sprite:=false;
      end;
    end;
    if ((zoomx=0) and (zoomy=0)) then begin
      zx:=16;
      zy:=16;
    end;
    sprite_tile(code,color,flipx,flipy,x,y,zx,zy);
  end;
end;

procedure tc0180vcu_chip.vblank_update;
var
  y:integer;
begin
  // Erase the page just displayed, then select and draw the next page.
  if (video_control and 1)=0 then
    for y:=16 to 239 do fillchar(framebuffer[framebuffer_page,y,0],320*2,0);
  if (video_control and $80)=0 then framebuffer_page:=framebuffer_page xor 1;
  draw_sprites;
end;

end.
