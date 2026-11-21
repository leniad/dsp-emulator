unit neogeo_video;
interface

type

    tneogeo_video=class
      constructor create;
      destructor free;
    public
      ng_palette:array[0..$1fff]of word;
      ng_palette_bank:integer;
      ng_animation:byte;
      ng_fix_source,ng_shadow,ng_animation_disabled:boolean;
      ng_animation_speed:byte;
      ng_sprites:array of byte;
      ng_fix_cart,ng_fix_bios,ng_zoom:array[0..$1fffff] of byte;
      modulo,read_buffer:word;
      procedure reset;
      procedure video_frame;
      procedure video_line(line:integer);
      procedure video_present;
      procedure vram_write(v:word);
      procedure palette_write(index:word;v:word);
      procedure video_decode(raw:pbyte;size:cardinal);
      procedure vram_address(v:word);
    private
      address:word;
      animation_div:integer;
      rgb:array[0..$3fff]of word;
      pixels:array[0..224-1,0..320-1] of word;
      ng_vram:array[0..$87ff]of word;
      palette_valid:array[0..$1fff] of boolean;
    end;

var
  nvideo_0:tneogeo_video;

implementation
uses main_engine,gfx_engine,pal_engine;

constructor tneogeo_video.create;
begin
  screen_init(1,320,224);
  iniciar_video(320,224);
end;

destructor tneogeo_video.free;
begin
end;

procedure tneogeo_video.reset;
begin
 self.address:=0;
 self.modulo:=1;
 self.read_buffer:=0;
 self.ng_palette_bank:=0;
 self.ng_fix_source:=false;
 self.ng_shadow:=false;
 self.ng_animation:=0;
 self.ng_animation_speed:=0;
 self.animation_div:=0;
 self.ng_animation_disabled:=false;
end;

procedure tneogeo_video.video_frame;
begin
 if self.animation_div=0 then begin
    self.animation_div:=self.ng_animation_speed;
    inc(self.ng_animation);
 end else dec(self.animation_div);
end;

procedure tneogeo_video.video_line(line:integer);
const
  zoom_x:array[0..15]of word=($0080,$0880,$0888,$2888,$288a,$2a8a,$2aaa,$aaaa,$aaea,$baea,$baeb,$bbeb,$bbef,$fbef,$fbff,$ffff);
var
    n,x,y,rows,zx,zy,ctl,zctl,sy,yl,tile,py,i,xx,pal,code,attr,src,pen,count,output_x,j,fixoffs,base,shadowbase:integer;
    inv:boolean;
    mask:word;
    fix:pbyte;
begin
 if (line<16) or (line>=240) then exit;
 sy:=line-16;
 shadowbase:=0;
 if ng_shadow then shadowbase:=$2000;
 for i:=0 to 319 do pixels[sy,i]:=rgb[shadowbase+ng_palette_bank+$fff];
 x:=0;
 y:=0;
 rows:=0;
 zx:=15;
 zy:=255;
 count:=0;
 for n:=0 to 380 do begin
  ctl:=ng_vram[$8200+n];
  zctl:=ng_vram[$8000+n];
  if (ctl and $40)<>0 then begin
      x:=(x+zx+1) and $1ff;
      zx:=(zctl shr 8) and 15;
  end else begin
      y:=$200-(ctl shr 7);
      x:=ng_vram[$8400+n] shr 7;
      rows:=ctl and 63;
      zy:=zctl and 255;
      zx:=(zctl shr 8) and 15;
  end;
  if rows=0 then continue;
  yl:=(line-y)and 511;
  if (rows<32) and (yl>=rows*16) then continue;
  inc(count);
  if count>96 then break;
  if (x>=320) and (x<=$1f0) then continue;
  inv:=(yl and 256)<>0;
  yl:=yl and 255;
  if inv then yl:=yl xor 255;
  if rows>32 then begin
      yl:=yl mod((zy+1)*2);
      if yl>zy then begin
        yl:=(zy+1)*2-1-yl;
        inv:=not inv;
      end;
  end;
  tile:=ng_zoom[zy*256+yl];
  py:=tile and 15;
  tile:=tile shr 4;
  if inv then begin
      py:=py xor 15;
      tile:=tile xor 31;
  end;
  attr:=ng_vram[n*64+tile*2+1];
  code:=ng_vram[n*64+tile*2] or ((attr and $f0) shl 12);
  if not ng_animation_disabled then begin
   if (attr and 8)<>0 then code:=(code and not 7) or (ng_animation and 7)
    else if (attr and 4)<>0 then code:=(code and not 3) or (ng_animation and 3);
  end;
  if (attr and 2)<>0 then py:=py xor 15;
  mask:=zoom_x[zx];
  output_x:=x;
  pal:=ng_palette_bank+(attr shr 8)*16;
  for i:=0 to 15 do begin
   if(mask and $8000)<>0 then begin
    xx:=i;
    if (attr and 1)<>0 then xx:=15-i;
    src:=(code*256+py*16+xx) and (length(ng_sprites)-1);
    pen:=ng_sprites[src];
    j:=output_x and 511;
    if (pen<>0) and (j<320) then pixels[sy,j]:=rgb[shadowbase+pal+pen];
    inc(output_x);
   end;
   mask:=word(mask shl 1);
  end;
 end;
 if ng_fix_source then fix:=@ng_fix_cart[0]
    else fix:=@ng_fix_bios[0];
 for x:=0 to 39 do begin
  attr:=ng_vram[$7000+x*32+(line shr 3)];
  code:=attr and $fff;
  pal:=ng_palette_bank+(attr shr 12)*16;
  base:=code*32+(line and 7);
  for i:=0 to 3 do begin
   case i of
      0:fixoffs:=$10;
      1:fixoffs:=$18;
      2:fixoffs:=0;
      else fixoffs:=8;
   end;
   pen:=fix[base+fixoffs];
   j:=x*8+i*2;
   if(pen and 15)<>0 then pixels[sy,j]:=rgb[shadowbase+pal+(pen and 15)];
   if(pen shr 4)<>0 then pixels[sy,j+1]:=rgb[shadowbase+pal+(pen shr 4)];
  end;
 end;
end;

procedure tneogeo_video.video_present;
var
  y:byte;
begin
  for y:=0 to 223 do putpixel(0,y,320,@pixels[y,0],1);
  actualiza_trozo(0,0,320,224,1,0,0,320,224,PANT_TEMP);
end;

procedure tneogeo_video.palette_write(index:word;v:word);
const
  // Normal, oscuro, sombra, oscuro+sombra.
  component_lut:array[0..3,0..31]of byte=(
    (0,8,14,22,30,38,44,52,65,73,79,86,95,103,109,117,
     138,146,152,160,169,176,182,190,203,211,217,225,233,241,247,255),
    (0,8,14,21,30,38,44,51,64,71,77,85,94,101,107,115,
     136,144,150,158,166,174,180,188,200,208,214,221,230,238,244,251),
    (0,4,8,12,17,21,25,29,36,40,44,48,53,57,61,65,
     77,81,85,89,94,98,102,106,113,117,121,125,130,134,138,142),
    (0,4,8,12,17,21,24,29,36,40,43,48,53,57,60,65,
     76,81,84,88,93,98,101,105,112,116,120,124,129,133,137,141)
  );
var
  c:tcolor;
  r,g,b,mode:byte;
  shadow_index:word;
begin
  index:=index and $1fff;
  if palette_valid[index] then
   if ng_palette[index]=v then exit;
  ng_palette[index]:=v;
  r:=((v shr 7) and 30) or ((v shr 14) and 1);
  g:=((v shr 3) and 30) or ((v shr 13) and 1);
  b:=((v shl 1) and 30) or ((v shr 12) and 1);
  mode:=v shr 15;
  fillchar(c,SizeOf(c),0);
  // Color normal.
  c.r:=component_lut[mode,r];
  c.g:=component_lut[mode,g];
  c.b:=component_lut[mode,b];
  set_pal_color(c,index);
  rgb[index]:=paleta[index];
  // Variante con sombra.
  mode:=mode+2;
  shadow_index:=index+$2000;
  c.r:=component_lut[mode,r];
  c.g:=component_lut[mode,g];
  c.b:=component_lut[mode,b];
  set_pal_color(c,shadow_index);
  rgb[shadow_index]:=paleta[shadow_index];
  palette_valid[index]:=true;
end;

procedure tneogeo_video.video_decode(raw:pbyte;size:cardinal);
var
  tile,y,x,b,o,d:integer;
begin
 setlength(ng_sprites,size*2);
 for tile:=0 to (((size div 128)-1)) do
    for y:=0 to 15 do
      for x:=0 to 15 do begin
        b:=tile*128+y*4;
        if x<8 then inc(b,$40);
        o:=x and 7;
        d:=((raw[b+3] shr o) and 1) shl 3 or (((raw[b+1] shr o) and 1) shl 2) or (((raw[b+2] shr o) and 1) shl 1) or ((raw[b] shr o) and 1);
        ng_sprites[tile*256+y*16+x]:=d;
      end;
end;

procedure tneogeo_video.vram_address(v:word);
begin
  if(v and $8000)<>0 then address:=v and $87ff
    else address:=v;
  read_buffer:=ng_vram[address];
end;

procedure tneogeo_video.vram_write(v:word);
begin
  ng_vram[address]:=v;
  self.vram_address((address and $8000) or ((address+modulo)and $7fff));
end;

end.
