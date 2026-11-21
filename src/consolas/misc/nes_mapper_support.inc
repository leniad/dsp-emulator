procedure mapper_irq(active:boolean);
begin
  if nes_mapper_0.ext.irq_asserted=active then exit;
  nes_mapper_0.ext.irq_asserted:=active;
  if (@nes_mapper_0.irq_changed<>nil) then nes_mapper_0.irq_changed(active)
    else if active then n2a03_0.m6502.change_irq(ASSERT_LINE)
      else n2a03_0.m6502.change_irq(CLEAR_LINE);
end;

procedure mmc5_irq_update;
begin
  with nes_mapper_0.ext do
    mapper_irq((m5_pending and m5_irq_enable)or(m5_pcm_pending and m5_pcm_irq_enable));
end;

procedure mmc1_sync;
var
  extra,n,mode,cb,rb,mask:integer;
begin
  with nes_mapper_0 do begin
    if last_prg=0 then exit;
    case regs[0]and 3 of
      0:ppu_nes_0.mirror:=MIRROR_LOW;
      1:ppu_nes_0.mirror:=MIRROR_HIGH;
      2:ppu_nes_0.mirror:=MIRROR_VERTICAL;
      3:ppu_nes_0.mirror:=MIRROR_HORIZONTAL;
    end;
    extra:=0;
    cb:=regs[1];
    if ((regs[0]and $10)<>0) and ext.last_a12 then cb:=regs[2];
    if (regs[0]and $10)<>0 then begin
      if ppu_nes_0.write_chr then begin
        chr_map[0]:=regs[1]and 1;
        chr_map[1]:=regs[2]and 1;
        set_chr_4(0,regs[1]and 1);
        set_chr_4($1000,regs[2]and 1);
      end else begin
          set_chr_4(0,regs[1]);
          set_chr_4($1000,regs[2]);
      end;
    end else begin
      chr_map[0]:=0;
      chr_map[1]:=1;
      if ppu_nes_0.write_chr then set_chr_8(0)
        else set_chr_8((regs[1]and $1e)shr 1);
    end;
    if last_prg>16 then extra:=cb and $10;
    n:=(regs[3]and $0f)or extra;
    mode:=(regs[0]shr 2)and 3;
    case mode of
      0,1:begin
            set_prg_16($8000,n and $fe);
            set_prg_16($c000,n or 1);
         end;
      2:begin
            set_prg_16($8000,extra);
            set_prg_16($c000,n);
        end;
      3:begin
            set_prg_16($8000,n);
            set_prg_16($c000,extra or $0f);
        end;
    end;
    prg_ram_enable:=(regs[3]and $10)=0;
    // SNROM reuses CHR A16 as a second SRAM chip-enable.
    if ppu_nes_0.write_chr and (last_prg<=16) and (ram_bytes<=$2000) and ((cb and $10)<>0) then prg_ram_enable:=false;
    // 001:5 denotes the fixed-PRG SEROM/SHROM/SH1ROM family.
    if submapper=5 then set_prg_32(0);
    rb:=0;
    if ram_bytes>$4000 then rb:=(cb shr 2) and 3
      else if ram_bytes>$2000 then rb:=(cb shr 3) and 1;
    ext.ram_bank:=rb;
    // Explicit NES 2.0 sizes drive SRAM banking; unknown iNES defaults to 8K.
  end;
end;

procedure mmc1_write(a:word;v:byte);
var
  r:integer;
begin
  with nes_mapper_0 do begin
    if (v and $80)<>0 then begin
      serial_cnt:=0;
      valor_map:=0;
      regs[0]:=regs[0] or $0c;
      ext.last_write:=ext.cpu_clock;
      ext.seen_write:=true;
      mmc1_sync;
      exit;
    end;
    if ext.seen_write and (ext.cpu_clock-ext.last_write<2) then begin
      ext.last_write:=ext.cpu_clock;
      exit;
    end;
    ext.last_write:=ext.cpu_clock;
    ext.seen_write:=true;
    valor_map:=valor_map or((v and 1) shl serial_cnt);
    inc(serial_cnt);
    if serial_cnt=5 then begin
      r:=(a shr 13) and 3;
      regs[r]:=valor_map;
      serial_cnt:=0;
      valor_map:=0;
      mmc1_sync;
    end;
  end;
end;

function mmc1_ram_read(a:word):byte;
var
  off:integer;
begin
  result:=nes_0.cpu_open_bus;
  with nes_mapper_0 do if prg_ram_enable and (ram_bytes>0) then begin
    off:=(ext.ram_bank*$2000+(a and $1fff)) mod ram_bytes;
    result:=prg_ram[off div $2000,off and $1fff];
  end;
end;

procedure mmc1_ram_write(a:word;v:byte);
var
  off:integer;
begin
  with nes_mapper_0 do if prg_ram_enable and prg_ram_writeble and (ram_bytes>0)then begin
    off:=(ext.ram_bank*$2000+(a and $1fff)) mod ram_bytes;
    prg_ram[off div $2000,off and $1fff]:=v;
  end;
end;

procedure mmc2_after_read(a:word);
var
  leftfd,leftfe:boolean;
begin
  with nes_mapper_0 do begin
    leftfd:=a=$0fd8;
    leftfe:=a=$0fe8;
    if mapper=10 then begin
        leftfd:=(a>=$0fd8) and (a<=$0fdf);
        leftfe:=(a>=$0fe8) and (a<=$0fef);
    end;
    if leftfd then begin
      latch0:=$fd;
      set_chr_4(0,regs[0]);
    end else if leftfe then begin
                latch0:=$fe;
                set_chr_4(0,regs[1]);
             end else if (a>=$1fd8) and (a<=$1fdf) then begin
                          latch1:=$fd;
                          set_chr_4($1000,regs[2]);
                      end else if (a>=$1fe8) and (a<=$1fef) then begin
                                  latch1:=$fe;
                                  set_chr_4($1000,regs[3]);
                               end;
  end;
end;

function mmc5_ram_offset(bank,offset:integer):integer;
var
  nv,work:integer;
begin
  Result:=-1;
  with nes_mapper_0 do begin
    if ram_bytes<=0 then Exit;
    bank:=bank and 7;
    if not nes20 or(ram_bytes>=$10000) then begin
        Result:=(bank*$2000+offset) mod ram_bytes;
        exit;
    end;
    nv:=nvram_bytes;work:=ram_bytes-nv;
    if(nv>0)and(work>0)then begin
      if bank<4 then Result:=(bank*$2000+offset) mod nv
        else Result:=nv+((bank-4)*$2000+offset) mod work;
      exit;
    end;
    if ram_bytes=$4000 then bank:=(bank shr 2)and 1
      else if bank>=4 then exit;
    Result:=(bank*$2000+offset) mod ram_bytes;
  end;
end;

function mmc5_cpu_bank(a:word;var is_ram:boolean):integer;
var
  idx,v,base:integer;
begin
  with nes_mapper_0 do begin
    if a<$8000 then begin
        is_ram:=true;
        result:=regs[$13] and 7;
        exit;
    end;
    idx:=(a-$8000)shr 13;
    is_ram:=false;
    case regs[0]and 3 of
      0:begin
          v:=regs[$17];
          base:=(v and $7c)+idx;
        end;
      1:begin
          if idx<2 then v:=regs[$15] else v:=regs[$17];
          base:=(v and $7e)+(idx and 1);
          is_ram:=(idx<2) and ((v and $80)=0);
        end;
      2:begin
          if idx<2 then begin
              v:=regs[$15];
              base:=(v and $7e)+idx;
          end else begin
                      v:=regs[$14+idx];
                      base:=v and $7f;
                   end;
          is_ram:=(idx<3) and ((v and $80)=0);
        end;
      else begin
              v:=regs[$14+idx];
              base:=v and $7f;
              is_ram:=(idx<3) and ((v and $80)=0);
           end;
    end;
    Result:=base;
  end;
end;

procedure mmc5_sync_prg;
var
  a,n:integer;
  r:boolean;
begin
  for a:=0 to 3 do begin
    n:=mmc5_cpu_bank($8000+a*$2000,r);
    // Cache ROM for existing debugger/reset-vector callers. CPU reads use the map.
    if not r then set_prg_8($8000+a*$2000,n);
  end;
end;

procedure mmc5_audio_write(a:word;v:byte);
const
  length_table:array[0..31]of byte=(10,254,20,2,40,4,80,6,160,8,60,10,14,12,26,14,12,16,24,18,48,20,96,22,192,24,72,26,16,28,32,30);
var
  ch,r:integer;
begin
  with nes_mapper_0.ext do begin
    if a<$5008 then begin
      ch:=(a shr 2)and 1;
      r:=a and 3;
      pulses[ch].regs[r]:=v;
      if r in[2,3] then pulses[ch].timer:=pulses[ch].regs[2] or ((pulses[ch].regs[3] and 7) shl 8);
      if r=3 then begin
        if (m5_enable and (1 shl ch))<>0 then pulses[ch].length_count:=length_table[v shr 3] and $fe;
        pulses[ch].sequence:=0;
        pulses[ch].env_start:=true;
      end;
    end else case a of
      $5010:begin
              m5_pcm_mode:=(v and 1)<>0;
              m5_pcm_irq_enable:=(v and $80)<>0;
              if not m5_pcm_irq_enable then m5_pcm_pending:=false;
            end;
      $5011:if not m5_pcm_mode and(v<>0)then m5_pcm:=v;
      $5015:begin
              m5_enable:=v and 3;
              for ch:=0 to 1 do if(v and (1 shl ch))=0 then pulses[ch].length_count:=0;
            end;
    end;
  end;
  mmc5_irq_update;
end;

function mmc5_cpu_read(a:word):byte;
var
  bank,n:integer;
  r:boolean;
begin
  result:=nes_0.cpu_open_bus;
  with nes_mapper_0 do begin
    if a>=$6000 then begin
      bank:=mmc5_cpu_bank(a,r);
      if r then begin
        n:=mmc5_ram_offset(bank,a and $1fff);
        if n>=0 then result:=prg_ram[n div $2000,n and $1fff];
      end else if last_prg<>0 then begin
        n:=bank mod (integer(last_prg)*2);
        result:=prg[n div 2,(n and 1)*$2000+(a and $1fff)];
      end;
      if (a>=$8000) and (a<=$bfff) and ext.m5_pcm_mode then begin
        if result=0 then ext.m5_pcm_pending:=true
          else ext.m5_pcm:=Result;
        mmc5_irq_update;
      end;
      if (a=$fffa) or (a=$fffb)then begin
        ext.m5_inframe:=false;
        ext.m5_scanline:=0;
        ext.m5_nt_repeat:=0;
        ext.m5_pending:=false;
        mmc5_irq_update;
      end;
      exit;
    end;
    if (a>=$5c00) and (a<=$5fff)then begin
      if(regs[4]and 3)>=2 then result:=ram[a and $3ff];
      exit;
    end;
    case a of
      $5010:begin
              result:=byte(ext.m5_pcm_pending) shl 7;
              ext.m5_pcm_pending:=false;
              mmc5_irq_update;
            end;
      $5015:begin
              result:=0;
              if ext.pulses[0].length_count>0 then Result:=Result or 1;
              if ext.pulses[1].length_count>0 then Result:=Result or 2;
            end;
      $5204:begin
              result:=(byte(ext.m5_pending) shl 7) or (byte(ext.m5_inframe) shl 6) or (Result and $3f);
              ext.m5_pending:=false;
              mmc5_irq_update;
            end;
      $5205:Result:=(word(mul1)*mul2) and $ff;
      $5206:Result:=(word(mul1)*mul2) shr 8;
    end;
  end;
end;

procedure mmc5_cpu_write(a:word;v:byte);
var
  n,bank:integer;
  r:boolean;
begin
  with nes_mapper_0 do begin
    if a>=$6000 then begin
      bank:=mmc5_cpu_bank(a,r);
      if r and ((regs[2] and 3)=2) and ((regs[3] and 3)=1) then begin
        n:=mmc5_ram_offset(bank,a and $1fff);
        if n>=0 then prg_ram[n div $2000,n and $1fff]:=v;
      end;
      exit;
    end;
    if (a>=$5000) and (a<=$5015) then begin
        mmc5_audio_write(a,v);
        exit;
    end;
    if (a>=$5c00) and (a<=$5fff) then begin
      case regs[4] and 3 of
        0,1:if ext.m5_inframe then ram[a and $3ff]:=v else ram[a and $3ff]:=0;
        2:ram[a and $3ff]:=v;
      end;
      exit;
    end;
    case a of
      $5100:begin
              regs[0]:=v and 3;
              mmc5_sync_prg;
            end;
      $5101:regs[1]:=v and 3;
      $5102..$5107:regs[a and $3f]:=v;
      $5113..$5117:begin
                      regs[a and $3f]:=v;
                      mmc5_sync_prg;
                   end;
      $5120..$512b:begin
                      n:=a-$5120;
                      ext.m5_chr[n]:=v or((regs[$30] and 3) shl 8);
                      ext.m5_last_chr:=n;
                   end;
      $5130:regs[$30]:=v and 3;
      $5200:ext.scratch[$200]:=v;
      $5201:ext.scratch[$201]:=v;
      $5202:ext.scratch[$202]:=v;
      $5203:ext.m5_irq_target:=v;
      $5204:begin
              ext.m5_irq_enable:=(v and $80)<>0;
              mmc5_irq_update;
            end;
      $5205:mul1:=v;
      $5206:mul2:=v;
    end;
  end;
end;

procedure ffe_sync;
var
  mode,v,i,n,cb:integer;
begin
  with nes_mapper_0 do begin
    v:=ext.ffe_latch;
    mode:=ext.ffe_mode;
    if (ext.ffe_addr and 1)=0 then begin
      for i:=0 to 3 do set_prg_8($8000+i*$2000,ext.ffe_prg[i]);
    end else case mode of
      0:begin
          set_prg_16($8000,v and 7);
          set_prg_16($c000,7);
        end;
      1:begin
          set_prg_16($8000,(v shr 2)and 15);
          set_prg_16($c000,7);
        end;
      2:begin
          set_prg_16($8000,v and 15);
          set_prg_16($c000,15);
        end;
      3:begin
          set_prg_16($8000,15);
          set_prg_16($c000,v and 15);
        end;
      4:set_prg_32((v shr 4)and 3);
      5,6,7:set_prg_32(3);
    end;
    cb:=0;
    if mode in[1,4,5]then cb:=v and 3;
    if mode=3 then cb:=(v shr 4)and 3;
    if mode=6 then cb:=v and 1;
    if(ext.ffe_addr and 1)=0 then cb:=v and 3;
    set_chr_8(cb);
  end;
end;

function ffe_read(a:word):byte;
begin
  result:=nes_0.cpu_open_bus;
  with nes_mapper_0 do case a of
    $4500:Result:=(ext.ffe_mode shl 2) or ((ext.ffe_map and $10) shr 2)or(ext.ffe_map and 3) or $40;
    $4501:Result:=(ext.ffe_latch and $fc) or (ext.ffe_addr and 3);
    $5000..$5fff:Result:=ext.scratch[a and $fff];
    $6000..$7fff:Result:=prg_ram[(ext.ffe_control shr 4)and 3,a and $1fff];
    $8000..$ffff:Result:=memoria[a];
  end;
end;

procedure ffe_write(a:word;v:byte);
var
  i,n:integer;
begin
  with nes_mapper_0 do begin
    if a>=$8000 then begin
      i:=(a-$8000)shr 13;
      if (ext.ffe_map and 2)<>0 then begin
        ext.ffe_latch:=v;
        ext.ffe_prg[i]:=v shr 2;
        ffe_sync;
      end else begin
        // PRG DRAM is writable when the latch is disabled.
        n:=ext.prg_pages[i];
        prg[n div 2,(n and 1)*$2000+(a and $1fff)]:=v;
        ffe_sync;
      end;
      exit;
    end;
    if (a>=$5000) and (a<=$5fff) then begin
        ext.scratch[a and $fff]:=v;
        exit;
    end;
    if (a>=$6000) and (a<=$7fff) then begin
        prg_ram[(ext.ffe_control shr 4)and 3,a and $1fff]:=v;
        exit;
    end;
    case a of
      $4025:begin
              ext.ffe_fds:=v;
              ext.ffe_fds_div:=0;
              if(v and $80)=0 then mapper_irq(false);
            end;
      $42fc..$42ff:begin
        ext.ffe_map:=(v and $f0)or(a and 3);
        ext.ffe_mode:=v shr 5;
        if(a and 1)=0 then begin
          if(v and $10)=0 then ppu_nes_0.mirror:=MIRROR_LOW else ppu_nes_0.mirror:=MIRROR_HIGH;
        end else if(v and $10)=0 then ppu_nes_0.mirror:=MIRROR_VERTICAL else ppu_nes_0.mirror:=MIRROR_HORIZONTAL;
        ffe_sync;
      end;
      $43fc..$43ff:begin
                      ext.ffe_addr:=a and 3;
                      ext.ffe_latch:=(ext.ffe_latch and $fc) or (v and 3);
                      ffe_sync;
                   end;
      $4500:ext.ffe_control:=v;
      $4501:begin
              ext.ffe_irq_enable:=false;
              mapper_irq(false);
            end;
      $4502:begin
              ext.ffe_irq:=(ext.ffe_irq and $ff00) or v;
              mapper_irq(false);
            end;
      $4503:begin
              ext.ffe_irq:=(ext.ffe_irq and $ff) or (word(v) shl 8);
              ext.ffe_irq_enable:=true;
              mapper_irq(false);
            end;
      $4504..$4507:begin
        i:=a-$4504;
        if (ext.ffe_addr and 2)=0 then ext.ffe_prg[i]:=v and $3f
          else begin
                  ext.ffe_prg[i]:=v shr 2;
                  ext.ffe_latch:=(ext.ffe_latch and $fc) or (v and 3);
               end;
        ffe_sync;
      end;
      $4510..$451b:ext.ffe_chr[a-$4510]:=v;
    end;
  end;
end;

procedure ffe_irq_clock;
begin
  with nes_mapper_0.ext do if ffe_irq_enable then begin
    ffe_irq:=word((integer(ffe_irq)+1)and $ffff);
    if ffe_irq=0 then mapper_irq(true);
  end;
end;

procedure tnes_mapper.ppu_address(a:word;clock:int64;is_read:boolean);
var
  hi:boolean;
  old:integer;
begin
  a:=a and $3fff;
  ext.ppu_clock:=clock;
  hi:=(a and $1000)<>0;
  // Only SxROM boards that reuse CHR lines can affect PRG/RAM on A12.
  // Ordinary CHR-ROM banks (e.g. Pirates!) must not rebuild the CPU map.
  if (mapper=1) and ((last_prg>16) or (ram_bytes>$2000) or ppu_nes_0.write_chr) and ((regs[0]and $10)<>0)and(ext.last_a12<>hi) and
    (((regs[1] xor regs[2]) and $1c)<>0) then begin
      ext.last_a12:=hi;
      mmc1_sync;
  end;
  if mapper=4 then begin
    if not hi and ext.last_a12 then ext.a12_low:=clock;
    if hi and not ext.last_a12 and(clock-ext.a12_low>=10)then begin
      old:=counter;
      if (counter=0)or reload then counter:=regs[2]
        else dec(counter);
      if (counter=0) and irq_ena and (not ext.mmc3_revision_a or (old>0) or reload) then mapper_irq(true);
      reload:=false;
    end;
  end;
  if (mapper=6) and hi and not ext.last_a12 and ((ext.ffe_control and 8)<>0) then ffe_irq_clock;
  ext.last_a12:=hi;
  if(mapper=5) and is_read then begin
    ext.last_ppu_read:=ext.cpu_clock;
    if(a>=$2000)and(a<$3000)then begin
      if ext.m5_nt_addr=a then inc(ext.m5_nt_repeat)
        else ext.m5_nt_repeat:=1;
      ext.m5_nt_addr:=a;
      if ext.m5_nt_repeat=3 then begin
        ext.m5_nt_repeat:=0;
        if not ext.m5_inframe then begin
          ext.m5_inframe:=true;
          ext.m5_scanline:=0;
        end else begin
            inc(ext.m5_scanline);
            if ext.m5_scanline=ext.m5_irq_target then begin
                ext.m5_pending:=true;
                mmc5_irq_update;
            end;
          end;
      end;
    end else begin
                ext.m5_nt_repeat:=0;
                ext.m5_nt_addr:=-1;
             end;
  end;
end;

function mapper_raw_chr(offset:integer;writable:boolean):byte;
var
  size:integer;
begin
  with nes_mapper_0 do begin
    if writable then size:=chr_ram_bytes
      else size:=integer(last_chr)*$2000;
    if size<=0 then begin
      result:=ppu_nes_0.open_bus;
      exit;
    end;
    offset:=offset mod size;
    result:=chr[offset div $2000,offset and $1fff];
  end;
end;

function ffe_chr_page(a:word):integer;
var
  n:integer;
begin
  with nes_mapper_0.ext do begin
    if(ffe_control and 1)=0 then begin
      Result:=chr_pages[a shr 10];
      exit;
    end;
    n:=a shr 10;
    result:=ffe_chr[n];
    if(ffe_control and 4)=0 then begin
      if a<$1000 then begin
        if ffe_fd0 then n:=0
          else n:=2;
      end else begin
        if ffe_fd1 then n:=4
          else n:=6;
      end;
      inc(n,(a shr 10)and 1);
      result:=(ffe_chr[n] and $fc) or ((a shr 10) and 3);
    end;
  end;
end;

function tnes_mapper.ppu_data(a:word;kind:byte;tile_x,screen_y:integer):byte;
var
  n,page,shift,nt,source,off,sy,splitcol:integer;
  chra,split,chrw:boolean;
begin
  a:=a and $3fff;
  if a<$2000 then begin
    if mapper=5 then begin
      chra:=(ppu_nes_0.sprite_size=8) or (kind in[5,6]) or ((kind=0) and (ext.m5_last_chr<8));
      if not chra and (ext.m5_split) and (kind in[3,4]) then begin
        off:=integer(ext.scratch[$202])*$1000+ext.m5_split_tile*16+(ext.m5_split_y and 7)+(a and 8);
      end else if not chra and ((regs[4] and 3)=1) and (kind in[3,4]) then begin
        page:=((regs[$30] and 3) shl 6) or (ext.m5_ex_attr and $3f);
        off:=page*$1000+(a and $fff);
      end else begin
        shift:=3-(regs[1]and 3);
        n:=a shr 10;
        if chra then n:=((n shr shift)shl shift)+(1 shl shift)-1
          else n:=8+((((n and 3)shr shift)shl shift)+(1 shl shift)-1);
        // 8K/4K background mode always uses register $512B.
        if not chra and (shift>=2) then n:=11;
        page:=integer(ext.m5_chr[n]) shl shift;
        page:=page+((a shr 10) and ((1 shl shift)-1));
        off:=page*$400+(a and $3ff);
      end;
      result:=mapper_raw_chr(off,ppu_nes_0.write_chr);Exit;
    end;
    if mapper=6 then begin
      page:=ffe_chr_page(a);
      result:=mapper_raw_chr(page*$400+(a and $3ff),true);
      if(a and $1ff8)=$0fd8 then ext.ffe_fd0:=true;
      if(a and $1ff8)=$0fe8 then ext.ffe_fd0:=false;
      if(a and $1ff8)=$1fd8 then ext.ffe_fd1:=true;
      if(a and $1ff8)=$1fe8 then ext.ffe_fd1:=false;
      exit;
    end;
    if mapper in[1,2,3,4,9,10]then begin
      page:=ext.chr_pages[a shr 10];
      result:=mapper_raw_chr(page*$400+(a and $3ff),ppu_nes_0.write_chr);
      if mapper in[9,10]then mmc2_after_read(a);
    end else begin
      result:=ppu_nes_0.chr[chr_map[a shr 12],a and $fff];
      if (@calls.ppu_read<>nil) then calls.ppu_read(a);
    end;
    exit;
  end;
  if a<$3f00 then begin
    a:=$2000 or(a and $fff);
    nt:=(a shr 10)and 3;
    off:=a and $3ff;
    if mapper=5 then begin
      split:=false;
      if kind in[1,2] then begin
        splitcol:=ext.scratch[$200] and $1f;
        split:=((ext.scratch[$200] and $80)<>0) and ((regs[4] and 3)<2) and (tile_x>=0) and (tile_x<32);
        if (ext.scratch[$200] and $40)=0 then split:=split and (tile_x<splitcol)
          else split:=split and (tile_x>=splitcol);
      end;
      if kind=1 then begin
        ext.m5_split:=split;
        if split then begin
          sy:=(screen_y+ext.scratch[$201]) mod 240;
          ext.m5_split_y:=sy;
          ext.m5_split_tile:=ram[(sy div 8)*32+tile_x];
          result:=ext.m5_split_tile;
          exit;
        end;
        ext.m5_ex_index:=off;
        ext.m5_ex_attr:=ram[off];
      end;
      if (kind=2) and split then begin
        sy:=(screen_y+ext.scratch[$201]) mod 240;
        n:=$3c0+(sy div 32)*8+(tile_x div 4);
        shift:=((sy div 8) and 2)*2+(tile_x and 2);
        result:=((ram[n] shr shift) and 3)*$55;
        exit;
      end;
      if (kind=2) and ((regs[4] and 3)=1) then begin
          result:=(ext.m5_ex_attr shr 6)*$55;
          exit;
      end;
      source:=(regs[5] shr (nt*2)) and 3;
      case source of
        0,1:Result:=ppu_nes_0.name_table[source,off];
        2:if (regs[4] and 3)=0 then Result:=ram[off]else Result:=0;
        else if off<$3c0 then Result:=regs[6]
              else Result:=(regs[7]and 3)*$55;
      end;
    end else if(mapper=6) and ((ext.ffe_control and 2)=0) then result:=mapper_raw_chr(integer(ext.ffe_chr[8+nt])*$400+off,true)
              else result:=ppu_nes_0.name_table[MIRROR_TYPES[ppu_nes_0.mirror,nt],off];
    exit;
  end;
  result:=0; // Palette RAM is internal to the PPU and never reaches cartridge data.
end;

procedure tnes_mapper.ppu_store(a:word;value:byte);
var
  page,off,nt,source:integer;
  allow:boolean;
begin
  a:=a and $3fff;
  if a<$2000 then begin
    if not ppu_nes_0.write_chr and (mapper<>6) then exit;
    if mapper=6 then begin
      allow:=(ext.ffe_mode<4) or ((ext.ffe_map and 2)=0);
      if not allow then exit;
      page:=ffe_chr_page(a);
    end else page:=ext.chr_pages[a shr 10];
    if mapper in[1,2,3,4,5,6,9,10] then begin
      if chr_ram_bytes<=0 then exit;
      off:=(page*$400+(a and $3ff)) mod chr_ram_bytes;
      chr[off div $2000,off and $1fff]:=value;
    end else ppu_nes_0.chr[chr_map[a shr 12],a and $fff]:=value;
  end else if a<$3f00 then begin
    nt:=(a shr 10)and 3;
    off:=a and $3ff;
    if mapper=5 then begin
      source:=(regs[5] shr (nt*2)) and 3;
      if source<2 then ppu_nes_0.name_table[source,off]:=value
        else if (source=2) and ((regs[4]and 3)=0) then ram[off]:=value;
    end else if (mapper=6) and ((ext.ffe_control and 2)=0) then begin
                off:=(integer(ext.ffe_chr[8+nt])*$400+off) mod chr_ram_bytes;
                chr[off div $2000,off and $1fff]:=value;
              end else ppu_nes_0.name_table[MIRROR_TYPES[ppu_nes_0.mirror,nt],off]:=value;
  end;
end;

procedure tnes_mapper.cpu_tick;
const
  duties:array[0..3]of byte=($40,$60,$78,$9f);
var
  ch,vol,sample:integer;
begin
  Inc(ext.cpu_clock);
  if mapper=5 then begin
    if ext.m5_inframe and (ext.cpu_clock-ext.last_ppu_read>=3) then begin
      ext.m5_inframe:=false;
      ext.m5_nt_repeat:=0;
    end;
    inc(ext.audio_div,240);
    if ext.audio_div>=NTSC_CLOCK then begin
      dec(ext.audio_div,NTSC_CLOCK);
      ext.audio_half:=ext.audio_half xor 1;
      for ch:=0 to 1 do with ext.pulses[ch] do begin
        if env_start then begin
            env_start:=false;
            env_decay:=15;
            env_div:=regs[0] and 15;
        end else if env_div=0 then begin
                    env_div:=regs[0]and 15;
                    if env_decay>0 then Dec(env_decay)
                      else if (regs[0] and $20)<>0 then env_decay:=15;
                 end else dec(env_div);
        if (length_count>0) and ((regs[0] and $20)=0)then dec(length_count);
      end;
    end;
    sample:=-integer(ext.m5_pcm)*64;
    for ch:=0 to 1 do with ext.pulses[ch] do begin
      if divider<=0 then begin
          divider:=2*(timer+1);
          sequence:=(sequence+1) and 7;
      end;
      dec(divider);
      if (regs[0]and $10)<>0 then vol:=regs[0] and 15 else vol:=env_decay;
      if (length_count>0) and ((duties[regs[0] shr 6] and (1 shl sequence))<>0) then dec(sample,vol*192);
    end;
    inc(ext.audio_sum,sample);
    inc(ext.audio_count);
  end else if mapper=6 then begin
    if(ext.ffe_control and 8)=0 then ffe_irq_clock;
    if(ext.ffe_fds and $80)<>0 then begin
      inc(ext.ffe_fds_div,3);
      if ext.ffe_fds_div>=448 then begin
        dec(ext.ffe_fds_div,448);
        mapper_irq(true);
      end;
    end;
  end;
end;

procedure mmc5_update_sound;
var
  sample,pos,ch:integer;
begin
  with nes_mapper_0.ext do begin
    if audio_channel<0 then exit;
    if audio_count>0 then sample:=audio_sum div audio_count
      else sample:=0;
    audio_sum:=0;
    audio_count:=0;
    audio_hp:=sample-audio_prev+((audio_hp*255)div 256);
    audio_prev:=sample;
    if audio_hp>32767 then audio_hp:=32767;
    if audio_hp< -32768 then audio_hp:=-32768;
    pos:=sound_status.posicion_sonido;
    ch:=audio_channel;
    if pos<LONG_MAX_AUDIO then tsample[ch,pos]:=audio_hp;
    if sound_status.stereo and (pos+1<LONG_MAX_AUDIO) then tsample[ch,pos+1]:=audio_hp;
  end;
end;

procedure begin_mapper_reset;
var
  ch:integer;
begin
  ch:=nes_mapper_0.ext.audio_channel;
  fillchar(nes_mapper_0.ext,SizeOf(tnes_mapper_state),0);
  nes_mapper_0.ext.audio_channel:=ch;
  nes_mapper_0.ext.last_write:=-100;
  nes_mapper_0.ext.m5_nt_addr:=-1;
end;

procedure finish_mapper_reset;
var
  i:integer;
begin
  with nes_mapper_0 do begin
    for i:=0 to 7 do ext.chr_pages[i]:=i;
    case mapper of
      1:begin
          regs[0]:=$0c;
          mmc1_sync;
        end;
      2,3:set_chr_8(0);
      4:begin
          ext.mmc3_revision_a:=submapper=4;
          if submapper=1 then begin
            prg_ram_enable:=false;
            regs[3]:=0;
          end;
          for i:=0 to 7 do ext.chr_pages[i]:=i;
          set_prg_8($8000,0);set_prg_8($a000,1);
          set_prg_8($c000,integer(last_prg)*2-2);
          set_prg_8($e000,integer(last_prg)*2-1);
        end;
      5:begin
          regs[0]:=3;
          regs[$17]:=$ff;
          mul1:=$ff;
          mul2:=$ff;
          if ext.audio_channel<0 then ext.audio_channel:=init_channel;
          mmc5_sync_prg;
        end;
      6:begin
          ext.ffe_mode:=submapper and 7;ext.ffe_control:=$42;
          ext.ffe_addr:=3;ext.ffe_map:=(ext.ffe_mode shl 5)or 3;
          if ppu_nes_0.mirror=MIRROR_HORIZONTAL then ext.ffe_map:=ext.ffe_map or $10;
          for i:=0 to 11 do ext.ffe_chr[i]:=i;
          for i:=0 to 3 do ext.ffe_prg[i]:=i;
          chr_ram_bytes:=$8000;
          ppu_nes_0.write_chr:=true;
          ffe_sync;
          if trainer_present then CopyMemory(@prg_ram[0,$1000],@trainer[0],512);
        end;
      9,10:begin
              set_chr_4(0,0);
              set_chr_4($1000,0);
           end;
    end;
  end;
end;

procedure tnes_mapper.save_battery(const filename:string);
var
  n:integer;
begin
  if not battery or (filename='') then exit;
  if mapper in[1,5] then begin
      n:=nvram_bytes;
      if n=0 then n:=ram_bytes;
      if n>SizeOf(prg_ram) then n:=SizeOf(prg_ram);
      write_file(filename,@prg_ram,n);
    end else write_file(filename,@memoria[$6000],$2000);
end;

procedure tnes_mapper.load_battery(const filename:string);
var
  longitud:integer;
begin
  if not battery or(filename='') or not fileExists(filename) then exit;
  if mapper in[1,5] then read_file(filename,@prg_ram,longitud)
    else read_file(filename,@memoria[$6000],longitud);
end;

