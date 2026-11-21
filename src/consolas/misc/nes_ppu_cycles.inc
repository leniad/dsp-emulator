function nesppu_chip.palette_read(a:word):byte;
begin
  a:=a and $1f;
  if (a and $13)=$10 then a:=a and $0f;
  result:=pal_ram[a];
end;

procedure nesppu_chip.update_nmi;
var
  level:boolean;
begin
  level:=((status and control1 and $80)<>0);
  if (level and not(pipe.nmi_level)) then n2a03_0.m6502.change_nmi(PULSE_LINE);
  if (not(level) and pipe.nmi_level) then n2a03_0.m6502.change_nmi(CLEAR_LINE);
  pipe.nmi_level:=level;
end;

procedure nesppu_chip.cpu_address_changed;
begin
  nes_mapper_0.ppu_address(address and $3fff,pipe.clock,false);
end;

function nesppu_chip.bus_read(a:word;kind:byte;tile_x,screen_y:integer):byte;
begin
  a:=a and $3fff;
  if a>=$3f00 then begin
    result:=palette_read(a);
    exit;
  end;
  nes_mapper_0.ppu_address(a,pipe.clock,true);
  if disable_chr and(a<$2000)then result:=a and $ff
    else result:=nes_mapper_0.ppu_data(a,kind,tile_x,screen_y);
end;

procedure nesppu_chip.inc_x;
begin
  if(address and $1f)=31 then address:=address xor $41f
    else inc(address);
end;

procedure nesppu_chip.inc_y;
var
  y:integer;
begin
  if(address and $7000)<>$7000 then inc(address,$1000)
  else begin
    address:=address and $0fff;
    y:=(address shr 5)and 31;
    if y=29 then begin
      y:=0;
      address:=address xor $800;
    end else if y=31 then y:=0
                else inc(y);
    address:=(address and $7c1f) or (y shl 5);
  end;
end;

procedure nesppu_chip.load_shifters;
begin
  pipe.bglo:=(pipe.bglo and $ff00) or pipe.lo;
  pipe.bghi:=(pipe.bghi and $ff00) or pipe.hi;
  pipe.atlo:=pipe.atlo and $ff00;
  pipe.athi:=pipe.athi and $ff00;
  if(pipe.attr and 1)<>0 then pipe.atlo:=pipe.atlo or $ff;
  if(pipe.attr and 2)<>0 then pipe.athi:=pipe.athi or $ff;
end;

procedure nesppu_chip.fetch_sprites;
var
  f,target,row,n,tile,table:integer;
begin
  pipe.next_count:=0;
  target:=linea+1;
  for f:=0 to 63 do begin
    if (target<1) or (target>239) then break;
    row:=target-integer(sprite_ram[f*4])-1;
    if (row<0) or (row>=sprite_size) then continue;
    n:=pipe.next_count;
    if n>=8 then begin
      status:=status or $20;
      break;
    end;
    with pipe.next_sprites[n]do begin
      x:=sprite_ram[f*4+3];
      attr:=sprite_ram[f*4+2];
      number:=f;
      tile:=sprite_ram[f*4+1];
      if (attr and $80)<>0 then row:=sprite_size-1-row;
      if sprite_size=16 then begin
        table:=tile and 1;
        tile:=(tile and $fe)+(row div 8);
      end else table:=(control1 shr 3)and 1;
      pattern:=table*$1000+tile*16+(row and 7);lo:=0;hi:=0;
    end;
    inc(pipe.next_count);
  end;
  for n:=pipe.next_count to 7 do begin
    fillchar(pipe.next_sprites[n],SizeOf(tnes_sprite_fetch),$ff);
    if sprite_size=16 then pipe.next_sprites[n].pattern:=$1ff7
      else pipe.next_sprites[n].pattern:=((control1 and 8)shl 9)+$ff7;
  end;
end;

procedure nesppu_chip.draw_pixel;
var
  x,mask,bg,bgpal,sp,sppal,i,idx:integer;behind,zero:boolean;
begin
  x:=pipe.dot-1;mask:=$8000 shr tile_x_offset;bg:=0;bgpal:=0;sp:=0;sppal:=0;behind:=false;zero:=false;
  if (control2 and 8)<>0 then
    if (x>=8) or ((control2 and 2)<>0) then begin
      bg:=byte((pipe.bglo and mask)<>0)+2*byte((pipe.bghi and mask)<>0);
      bgpal:=byte((pipe.atlo and mask)<>0)+2*byte((pipe.athi and mask)<>0);
    end;
  if(control2 and $10)<>0 then if(x>=8)or((control2 and 4)<>0) then
    for i:=0 to pipe.sprite_count-1 do with pipe.sprites[i]do
      if (self.pipe.dot-1>=integer(x)) and (self.pipe.dot-1<integer(x)+8) then begin
        idx:=7-(self.pipe.dot-1-integer(x));
        sp:=((lo shr idx)and 1)+2*((hi shr idx)and 1);
        if sp<>0 then begin
          sppal:=attr and 3;
          behind:=(attr and $20)<>0;
          zero:=number=0;
          break;
        end;
      end;
  if (zero and (bg<>0) and (sp<>0) and(x<>255)) then status:=status or $40;
  idx:=0;
  if bg<>0 then idx:=bgpal*4+bg;
  if ((sp<>0) and ((bg=0) or not(behind))) then idx:=$10+sppal*4+sp;
  if (control2 and $18)=0 then if(address and $3f00)=$3f00 then idx:=address and $1f;
  pipe.pixels[x]:=set_emphasis(paleta[palette_read($3f00+idx) and pal_mask]);
end;

procedure nesppu_chip.tick;
function nes_reverse(v:byte):byte;
var
  i:integer;
begin
  result:=0;
  for i:=0 to 7 do begin
    result:=(result shl 1)or(v and 1);
    v:=v shr 1;
  end;
end;
var
  a:word;
  phase,slot,tx,sy,i:integer;
  render:boolean;
  dummy:byte;
begin
  Inc(pipe.clock);
  render:=((control2 and $18)<>0) and ((linea<240) or (linea=261));
  if pipe.dot=0 then begin
    pipe.sprite_count:=pipe.next_count;
    copymemory(@pipe.sprites,@pipe.next_sprites,SizeOf(pipe.sprites));
    if linea=240 then inc(pipe.frame_serial);
  end;
  if ((linea=241) and (pipe.dot=1)) then begin
    if not pipe.suppress_vblank then status:=status or $80;
    update_nmi;
  end;
  if ((linea=261) and (pipe.dot=1)) then begin
    status:=status and $1f;
    pipe.suppress_vblank:=false;
    update_nmi;
  end;
  if render and (((pipe.dot>=2) and (pipe.dot<=257)) or ((pipe.dot>=322) and (pipe.dot<=337))) then begin
      pipe.bglo:=word((cardinal(pipe.bglo)shl 1)and $ffff);
      pipe.bghi:=word((cardinal(pipe.bghi)shl 1)and $ffff);
      pipe.atlo:=word((cardinal(pipe.atlo)shl 1)and $ffff);
      pipe.athi:=word((cardinal(pipe.athi)shl 1)and $ffff);
  end;
  if ((linea<240) and (pipe.dot>=1) and (pipe.dot<=256)) then begin
    draw_pixel;
    if pipe.dot=256 then putpixel(0,linea,256,@pipe.pixels[0],2);
  end;
  if render then begin
    if (((pipe.dot>=1) and (pipe.dot<=256)) or ((pipe.dot>=321) and (pipe.dot<=336))) then begin
      phase:=pipe.dot and 7;
      if pipe.dot<=256 then begin
        tx:=(pipe.dot-1) div 8+2;
        sy:=linea;
      end else begin
        tx:=(pipe.dot-321) div 8;
        sy:=linea+1;
        if sy=262 then sy:=0;
      end;
      case phase of
        1:begin load_shifters;pipe.tile:=bus_read($2000 or(address and $fff),1,tx,sy);end;
        3:begin
            a:=$23c0 or(address and $c00)or((address shr 4)and $38)or((address shr 2)and 7);
            dummy:=bus_read(a,2,tx,sy);
            pipe.attr:=(dummy shr(((address shr 4)and 4)or(address and 2)))and 3;
          end;
        4:begin a:=((control1 and $10)shl 8)+word(pipe.tile)*16+((address shr 12)and 7);nes_mapper_0.ppu_address(a,pipe.clock,false);end;
        6:begin a:=((control1 and $10)shl 8)+word(pipe.tile)*16+8+((address shr 12)and 7);nes_mapper_0.ppu_address(a,pipe.clock,false);end;
        5:begin a:=((control1 and $10)shl 8)+word(pipe.tile)*16+((address shr 12)and 7);pipe.lo:=bus_read(a,3,tx,sy);end;
        7:begin a:=((control1 and $10)shl 8)+word(pipe.tile)*16+8+((address shr 12)and 7);pipe.hi:=bus_read(a,4,tx,sy);end;
        0:begin
            inc_x;
            nes_mapper_0.ppu_address($2000 or(address and $fff),pipe.clock,false);
          end;
      end;
    end;
    if pipe.dot=256 then inc_y;
    if pipe.dot=257 then begin
      load_shifters;
      address:=(address and $7be0) or (address_temp and $41f);
      fetch_sprites;
      if (@nes_mapper_0.calls.line_ack<>nil) then nes_mapper_0.calls.line_ack(false);
    end;
    if(linea=261)and(pipe.dot>=280)and(pipe.dot<=304)then address:=(address and $41f)or(address_temp and $7be0);
    if ((pipe.dot>=257) and (pipe.dot<=320)) then begin
      slot:=(pipe.dot-257) div 8;
      phase:=(pipe.dot-257) and 7;
      case phase of
        0,2:dummy:=bus_read($2000 or(address and $fff),7);
        3:nes_mapper_0.ppu_address(pipe.next_sprites[slot].pattern,pipe.clock,false);
        5:nes_mapper_0.ppu_address(pipe.next_sprites[slot].pattern+8,pipe.clock,false);
        7:nes_mapper_0.ppu_address($2000 or(address and $fff),pipe.clock,false);
        4:pipe.next_sprites[slot].lo:=bus_read(pipe.next_sprites[slot].pattern,5);
        6:begin
          pipe.next_sprites[slot].hi:=bus_read(pipe.next_sprites[slot].pattern+8,6);
          if(pipe.next_sprites[slot].attr and $40)<>0 then begin
            pipe.next_sprites[slot].lo:=nes_reverse(pipe.next_sprites[slot].lo);
            pipe.next_sprites[slot].hi:=nes_reverse(pipe.next_sprites[slot].hi);
          end;
        end;
      end;
    end;
    if pipe.dot=337 then load_shifters;
    if ((pipe.dot=337) or (pipe.dot=339)) then dummy:=bus_read($2000 or(address and $fff),7);
  end;
  // Odd NTSC frames omit the last pre-render dot only while rendering.
  if(linea=261)and(pipe.dot=339)and pipe.odd and render then begin
    pipe.dot:=0;
    linea:=0;
    pipe.odd:=not pipe.odd;
  end else begin
    inc(pipe.dot);
    if pipe.dot=341 then begin
      pipe.dot:=0;
      inc(linea);
      if linea=262 then begin
        linea:=0;
        pipe.odd:=not pipe.odd;
      end;
    end;
  end;
end;
