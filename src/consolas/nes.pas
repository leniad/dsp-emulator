unit nes;

interface

type
    tnes_machine=record
            joy1,joy2,joy1_read,joy2_read,cpu_open_bus:byte;
            sram_present,val_4016:boolean;
           end;

function iniciar_nes:boolean;

var
  nes_0:tnes_machine;
  nv_ram_name:string;

implementation
uses principal,snapshot,main_engine,nes_ppu,controls_engine,sysutils,dialogs,
     misc_functions,sound_engine,file_engine,n2a03,m6502,nes_mappers;

function nes_getbyte(direccion:word):byte;forward;

var
  nes_dma_pending,nes_dma_active,nes_dmc_active,nes_apu_irq_level:boolean;
  nes_dma_page:byte;

procedure eventos_nes;
var
  temp_r:preg_m6502;
begin
  if event.arcade then begin
    //Player 1
    if arcade_input.but1[0] then nes_0.joy1_read:=(nes_0.joy1_read or 1) else nes_0.joy1_read:=(nes_0.joy1_read and $fe);
    if arcade_input.but0[0] then nes_0.joy1_read:=(nes_0.joy1_read or 2) else nes_0.joy1_read:=(nes_0.joy1_read and $fd);
    if arcade_input.coin[0] then nes_0.joy1_read:=(nes_0.joy1_read or 4) else nes_0.joy1_read:=(nes_0.joy1_read and $fb);
    if arcade_input.start[0] then nes_0.joy1_read:=(nes_0.joy1_read or 8) else nes_0.joy1_read:=(nes_0.joy1_read and $f7);
    if arcade_input.up[0] then nes_0.joy1_read:=(nes_0.joy1_read or $10) else nes_0.joy1_read:=(nes_0.joy1_read and $ef);
    if arcade_input.down[0] then nes_0.joy1_read:=(nes_0.joy1_read or $20) else nes_0.joy1_read:=(nes_0.joy1_read and $df);
    if arcade_input.left[0] then nes_0.joy1_read:=(nes_0.joy1_read or $40) else nes_0.joy1_read:=(nes_0.joy1_read and $bf);
    if arcade_input.right[0] then nes_0.joy1_read:=(nes_0.joy1_read or $80) else nes_0.joy1_read:=(nes_0.joy1_read and $7f);
    //Player 2
    if arcade_input.but1[1] then nes_0.joy2_read:=(nes_0.joy2_read or 1) else nes_0.joy2_read:=(nes_0.joy2_read and $fe);
    if arcade_input.but0[1] then nes_0.joy2_read:=(nes_0.joy2_read or 2) else nes_0.joy2_read:=(nes_0.joy2_read and $fd);
    if arcade_input.coin[1] then nes_0.joy2_read:=(nes_0.joy2_read or 4) else nes_0.joy2_read:=(nes_0.joy2_read and $fb);
    if arcade_input.start[1] then nes_0.joy2_read:=(nes_0.joy2_read or 8) else nes_0.joy2_read:=(nes_0.joy2_read and $f7);
    if arcade_input.up[1] then nes_0.joy2_read:=(nes_0.joy2_read or $10) else nes_0.joy2_read:=(nes_0.joy2_read and $ef);
    if arcade_input.down[1] then nes_0.joy2_read:=(nes_0.joy2_read or $20) else nes_0.joy2_read:=(nes_0.joy2_read and $df);
    if arcade_input.left[1] then nes_0.joy2_read:=(nes_0.joy2_read or $40) else nes_0.joy2_read:=(nes_0.joy2_read and $bf);
    if arcade_input.right[1] then nes_0.joy2_read:=(nes_0.joy2_read or $80) else nes_0.joy2_read:=(nes_0.joy2_read and $7f);
    //Soft Reset
    if keyboard[KEYBOARD_f5] then begin
        temp_r:=n2a03_0.m6502.get_internal_r;
        temp_r.p.int:=true;
        temp_r.sp:=temp_r.sp-3;
        temp_r.pc:=nes_getbyte($fffc)+(nes_getbyte($fffd)shl 8);
    end;
  end;
end;

procedure nes_clock;
begin
  n2a03_0.clock_cpu;
  nes_mapper_0.cpu_tick;
  ppu_nes_0.tick;
  ppu_nes_0.tick;
  ppu_nes_0.tick;
end;

procedure nes_mapper_irq_changed(active:boolean);
begin
  if active or nes_apu_irq_level then n2a03_0.m6502.change_irq(ASSERT_LINE)
    else n2a03_0.m6502.change_irq(CLEAR_LINE);
end;

procedure nes_apu_irq_changed(status:byte);
begin
  nes_apu_irq_level:=status<>CLEAR_LINE;
  nes_mapper_irq_changed(nes_mapper_0.ext.irq_asserted);
end;

procedure nes_dmc_dma;
var
  a:word;
  v:byte;
  i,stalls:integer;
begin
  if (nes_dmc_active or not(n2a03_0.dmc_request(a))) then exit;
  nes_dmc_active:=true;
  // Halt + dummy + optional alignment + sample get. Requests wait for a read.
  stalls:=3+integer(nes_mapper_0.ext.cpu_clock and 1);
  for i:=1 to stalls-1 do nes_clock;
  nes_clock;
  v:=nes_getbyte(a);
  n2a03_0.dmc_complete(v);
  inc(n2a03_0.m6502.contador,stalls);
  nes_dmc_active:=false;
end;

procedure nes_bus_cycle(is_read:boolean);
var
  i,extra:integer;
  v:byte;
begin
  if (is_read and not(nes_dmc_active)) then nes_dmc_dma;
  if (is_read and nes_dma_pending and not(nes_dma_active)) then begin
    nes_dma_pending:=false;
    nes_dma_active:=true;
    extra:=1+integer(nes_mapper_0.ext.cpu_clock and 1);
    for i:=1 to extra do nes_clock;
    for i:=0 to 255 do begin
      nes_dmc_dma;nes_clock;
      v:=nes_getbyte(word(nes_dma_page)*256+i);
      nes_clock;
      ppu_nes_0.sprite_ram[ppu_nes_0.sprite_ram_pos]:=v;
      ppu_nes_0.sprite_ram_pos:=byte((integer(ppu_nes_0.sprite_ram_pos)+1)and $ff);
    end;
    inc(n2a03_0.m6502.contador,512+extra);
    nes_dma_active:=false;
  end;
  nes_clock;
end;

procedure nes_principal;
var
  serial:cardinal;
begin
  while EmuStatus=EsRunning do begin
    serial:=ppu_nes_0.pipe.frame_serial;
    repeat
      n2a03_0.m6502.run(1);
    until (ppu_nes_0.pipe.frame_serial<>serial);
    eventos_nes;
    actualiza_trozo(0,0,256,240,2,0,0,256,240,PANT_TEMP);
    video_sync;
  end;
end;

function nes_getbyte(direccion:word):byte;
var
  v:byte;
begin
  v:=nes_0.cpu_open_bus;
  case direccion of
    $0000..$1fff:v:=memoria[direccion and $7ff];
    $2000..$3fff:case direccion and 7 of
      2:begin
        v:=(ppu_nes_0.status and $e0) or (ppu_nes_0.open_bus and $1f);
        if ((ppu_nes_0.linea=241) and (ppu_nes_0.pipe.dot<=1)) then ppu_nes_0.pipe.suppress_vblank:=true;
        ppu_nes_0.status:=ppu_nes_0.status and $7f;
        ppu_nes_0.dir_first:=true;
        ppu_nes_0.update_nmi;
        ppu_nes_0.open_bus:=v;
      end;
      4:begin
          v:=ppu_nes_0.sprite_ram[ppu_nes_0.sprite_ram_pos];
          ppu_nes_0.open_bus:=v;
        end;
      7:v:=ppu_nes_0.read;
      else v:=ppu_nes_0.open_bus;
    end;
    $4000..$4013,$4015:v:=n2a03_0.read(direccion);
    $4016:begin
      if (nes_0.joy1<8) then v:=(v and $e0) or ((nes_0.joy1_read shr nes_0.joy1) and 1)
        else v:=(v and $e0) or 1;
      if (not(nes_0.val_4016) and (nes_0.joy1<8)) then inc(nes_0.joy1);
    end;
    $4017:begin
      if (nes_0.joy2<8) then v:=(v and $e0) or ((nes_0.joy2_read shr nes_0.joy2) and 1)
        else v:=(v and $e0) or 1;
      if (not(nes_0.val_4016) and (nes_0.joy2<8)) then inc(nes_0.joy2);
    end;
    $4020..$5fff:if (@nes_mapper_0.calls.read_expansion<>nil) then v:=nes_mapper_0.calls.read_expansion(direccion);
    $6000..$7fff:v:=nes_mapper_0.calls.read_prg_ram(direccion);
    $8000..$ffff:if (@nes_mapper_0.calls.read_rom<>nil) then v:=nes_mapper_0.calls.read_rom(direccion)
                    else v:=memoria[direccion];
  end;
  nes_0.cpu_open_bus:=v;
  result:=v;
end;

procedure nes_putbyte(direccion:word;valor:byte);
begin
  nes_0.cpu_open_bus:=valor;
  if ((direccion>=$2000) and (direccion<$4000)) then ppu_nes_0.open_bus:=valor;
  case direccion of
    0..$1fff:memoria[direccion and $7ff]:=valor;
    $2000..$3fff:begin
        case (direccion and 7) of
            0:begin
                ppu_nes_0.control1:=valor;
                ppu_nes_0.update_nmi;
                ppu_nes_0.sprite_size:=8 shl ((valor shr 5) and 1);
                ppu_nes_0.pos_bg:=(valor shr 4) and 1;
                ppu_nes_0.pos_spt:=(valor shr 3) and 1;
                ppu_nes_0.address_temp:=(ppu_nes_0.address_temp and $73ff) or ((valor and $3) shl 10);
              end;
            1:begin
                ppu_nes_0.control2:=valor;
                //Salida de video en grises!  Noah's Ark lo usa!
                if (valor and 1)<>0 then ppu_nes_0.pal_mask:=$30
                  else ppu_nes_0.pal_mask:=$3f;
              end;
            3:ppu_nes_0.sprite_ram_pos:=valor;
            4:begin
                //Si esta renderizando escribe $ff!!
                if ((ppu_nes_0.linea<240) and ((ppu_nes_0.control2 and $18)<>0)) then valor:=$ff;
                ppu_nes_0.sprite_ram[ppu_nes_0.sprite_ram_pos]:=valor;
                ppu_nes_0.sprite_ram_pos:=byte((integer(ppu_nes_0.sprite_ram_pos)+1) and $ff);
              end;
            5:begin
                if ppu_nes_0.dir_first then begin
                  ppu_nes_0.address_temp:=ppu_nes_0.address_temp and $7fe0;
                  ppu_nes_0.address_temp:=ppu_nes_0.address_temp or ((valor and $f8) shr 3);
                  ppu_nes_0.tile_x_offset:=valor and $7;
                end else begin
                  ppu_nes_0.address_temp:=ppu_nes_0.address_temp and $c1f;
                  ppu_nes_0.address_temp:=ppu_nes_0.address_temp or ((valor and $f8) shl 2);
                  ppu_nes_0.address_temp:=ppu_nes_0.address_temp or ((valor and $7) shl 12);
                end;
                ppu_nes_0.dir_first:=not(ppu_nes_0.dir_first);
              end;
            6:begin
                if ppu_nes_0.dir_first then begin
                  ppu_nes_0.address_temp:=ppu_nes_0.address_temp and $ff;
                  ppu_nes_0.address_temp:=ppu_nes_0.address_temp or ((valor and $3f) shl 8);
                end else begin
                  ppu_nes_0.address_temp:=ppu_nes_0.address_temp and $7f00;
                  ppu_nes_0.address_temp:=ppu_nes_0.address_temp or valor;
                  ppu_nes_0.address:=ppu_nes_0.address_temp;
                  ppu_nes_0.cpu_address_changed;
                end;
                ppu_nes_0.dir_first:=not(ppu_nes_0.dir_first);
              end;
            7:ppu_nes_0.write(valor);
          end;
          end;
        $4000..$4013,$4015,$4017:n2a03_0.write(direccion,valor);
        $4014:begin
                nes_dma_page:=valor;
                nes_dma_pending:=true;
              end;
        $4016:begin
                if (((valor and 1)=0) and nes_0.val_4016) then begin
                  nes_0.joy1:=0;
                  nes_0.joy2:=0;
                end;
                nes_0.val_4016:=(valor and 1)<>0;
                if nes_0.val_4016 then begin
                  nes_0.joy1:=0;
                  nes_0.joy2:=0;
                end;
              end;
        $4020..$5fff:if @nes_mapper_0.calls.write_expansion<>nil then nes_mapper_0.calls.write_expansion(direccion,valor); //Expansion Area
        $6000..$7fff:nes_mapper_0.calls.write_prg_ram(direccion,valor); //PRG-RAM
        $8000..$ffff:if @nes_mapper_0.calls.write_rom<>nil then nes_mapper_0.calls.write_rom(direccion,valor); //PRG-ROM Area
  end;
end;

//Main
procedure nes_reset;
var
  r:preg_m6502;
  ret:word;
  i:integer;
begin
  n2a03_0.m6502.change_bus_cycle(nil);
  ppu_nes_0.reset;
  //IMPORTANTE: Primero reset al mapper para que coloque correctamente las ROMS!!!!!
  nes_mapper_0.reset;
  n2a03_0.reset;
  nes_dma_pending:=false;
  nes_dma_active:=false;
  nes_dmc_active:=false;
  for i:=1 to 7 do nes_clock;
  if(nes_mapper_0.mapper=6)and nes_mapper_0.trainer_present then begin
    r:=n2a03_0.m6502.get_internal_r;
    ret:=word((integer(r.pc)-1)and $ffff);
    memoria[$100+r.sp]:=ret shr 8;r.sp:=byte((integer(r.sp)-1)and $ff);
    memoria[$100+r.sp]:=ret and $ff;r.sp:=byte((integer(r.sp)-1)and $ff);
    r.pc:=$7003;
    for i:=1 to 6 do nes_clock;
  end;
  n2a03_0.m6502.change_bus_cycle(nes_bus_cycle);
  frame_main:=n2a03_0.m6502.tframes;
  nes_0.joy1:=0;
  nes_0.joy2:=0;
  nes_0.joy1_read:=0;
  nes_0.joy2_read:=0;
  nes_0.val_4016:=false;
end;

function abrir_cartucho(datos:pbyte;longitud:integer):boolean;
type
  tnes_header=packed record
    magic:array[0..2] of ansichar;
    magic2,prg_rom,chr_rom,flags6,flags7,flags8,flags9,flags10:byte;
    unused1:array[0..4] of byte;
  end;
var
  nes_header:tnes_header;
  ptemp:pbyte;
  f,submapper:byte;
  prg_count,chr_count,needed,ramshift,nvshift:integer;
  is20:boolean;
  mapper:word;
  crc32,rom_crc32:dword;
begin
  abrir_cartucho:=false;
  if longitud<16 then Exit;
  submapper:=0;
  ptemp:=datos;
  copymemory(@nes_header,ptemp,sizeof(tnes_header));
  crc32:=calc_crc(ptemp,longitud);
  inc(ptemp,sizeof(tnes_header));
  if ((nes_header.magic<>'NES') or (nes_header.magic2<>$1a)) then exit;
  is20:=(nes_header.flags7 and $0c)=8;
  prg_count:=nes_header.prg_rom;
  chr_count:=nes_header.chr_rom;
  if is20 then begin
    // Exponent/multiplier encoding is explicitly rejected in this build.
    if(nes_header.flags9 and $0f)=$0f then Exit;
    if(nes_header.flags9 and $f0)=$f0 then Exit;
    prg_count:=prg_count+((nes_header.flags9 and $0f)shl 8);
    chr_count:=chr_count+((nes_header.flags9 and $f0)shl 4);
  end;
  if ((prg_count<1) or (prg_count>64) or (chr_count>128)) then exit;
  needed:=16+prg_count*$4000+chr_count*$2000;
  nes_mapper_0.trainer_present:=(nes_header.flags6 and 4)<>0;
  if nes_mapper_0.trainer_present then inc(needed,512);
  if longitud<needed then exit;
  if nes_mapper_0.trainer_present then begin
    copymemory(@nes_mapper_0.trainer[0],ptemp,512);
    inc(ptemp,512);
  end;
  nes_mapper_0.nes20:=is20;
  nes_mapper_0.battery:=(nes_header.flags6 and 2)<>0;
  nes_mapper_0.ram_bytes:=$2000;nes_mapper_0.chr_ram_bytes:=$2000;
  nes_mapper_0.nvram_bytes:=0;
  if is20 then begin
    ramshift:=nes_header.flags10 and $f;
    nvshift:=nes_header.flags10 shr 4;
    nes_mapper_0.ram_bytes:=0;
    if ramshift<>0 then nes_mapper_0.ram_bytes:=64 shl ramshift;
    if nvshift<>0 then begin
      nes_mapper_0.nvram_bytes:=64 shl nvshift;
      inc(nes_mapper_0.ram_bytes,nes_mapper_0.nvram_bytes);
    end;
    ramshift:=nes_header.unused1[0] and $f;
    nvshift:=nes_header.unused1[0] shr 4;
    nes_mapper_0.chr_ram_bytes:=0;
    if ramshift<>0 then nes_mapper_0.chr_ram_bytes:=64 shl ramshift;
    if nvshift<>0 then inc(nes_mapper_0.chr_ram_bytes,64 shl nvshift);
  end else if nes_header.flags8<>0 then nes_mapper_0.ram_bytes:=integer(nes_header.flags8)*$2000;
  if nes_mapper_0.ram_bytes>SizeOf(nes_mapper_0.prg_ram) then exit;
  if nes_mapper_0.chr_ram_bytes>SizeOf(nes_mapper_0.chr) then exit;
  //Vacio las ROMs/RAM/CHR
  fillchar(nes_mapper_0.prg,sizeof(nes_mapper_0.prg),0);
  fillchar(nes_mapper_0.chr,sizeof(nes_mapper_0.chr),0);
  fillchar(nes_mapper_0.prg_ram,sizeof(nes_mapper_0.prg_ram),0);
  //Pos 4 Numero de paginas de ROM de 16k 1-255
  nes_mapper_0.last_prg:=prg_count;
  for f:=0 to (nes_mapper_0.last_prg-1) do begin
    copymemory(@nes_mapper_0.prg[f,0],ptemp,$4000);
    inc(ptemp,$4000);
  end;
  copymemory(@memoria[$8000],@nes_mapper_0.prg[0,0],$4000);
  if nes_mapper_0.last_prg=1 then copymemory(@memoria[$c000],@nes_mapper_0.prg[0,0],$4000)
    else copymemory(@memoria[$c000],@nes_mapper_0.prg[1,0],$4000);
  //Pos 5 Numero de paginas de CHR de 8k 0-255
  nes_mapper_0.last_chr:=chr_count;
  //chr ram es un caso diferente... tiene paginacion y dos paginas que se pueden intercambiar
  //Lo activo solo si el mapper lo necesita... Uso igual la memoria chr del MAPPER!!!
  if nes_mapper_0.last_chr=0 then begin
    ppu_nes_0.write_chr:=true;
    fillchar(nes_mapper_0.chr[0,0],$2000,0);
  end else begin
    ppu_nes_0.write_chr:=false;
    for f:=0 to (nes_mapper_0.last_chr-1) do begin
      copymemory(@nes_mapper_0.chr[f,0],ptemp,$2000);
      inc(ptemp,$2000);
    end;
    copymemory(@ppu_nes_0.chr[0,0],@nes_mapper_0.chr[0,0],$1000);
    copymemory(@ppu_nes_0.chr[1,0],@nes_mapper_0.chr[0,$1000],$1000);
  end;
  //Pos 6 bit7-4 mapper low - bit3 4 screen - bit2 trainer - bit1 battery - bit0 mirror
  //Pos 7 bit7-4 mapper high
  //Si la pos 7 tiene la marca 'XXXX10XX'--> iNes 2.0
  if (nes_header.flags7 and $c)=8 then begin
    //MessageDlg('NES: Cabecera iNes 2.0',mtInformation,[mbOk], 0);
    //Falta por implementar el resto... http://wiki.nesdev.com/w/index.php/NES_2.0
    submapper:=(nes_header.flags8 and $f0) shr 4;
    mapper:=(nes_header.flags6 shr 4) or (nes_header.flags7 and $f0) or ((nes_header.flags8 and $f) shl 8);
  end else begin
    //Si las pos 12,13,14 y 15 <>0 --> Archaic
    if ((nes_header.unused1[1]<>0) and (nes_header.unused1[2]<>0) and (nes_header.unused1[3]<>0) and (nes_header.unused1[4]<>0)) then begin
      mapper:=nes_header.flags6 shr 4;
    end else begin //iNes
      mapper:=(nes_header.flags6 shr 4) or (nes_header.flags7 and $f0);
      if (nes_header.flags9 and 1)<>0 then MessageDlg('NES: PAL ROM Found', mtError,[mbOk], 0);
    end;
  end;
  nes_0.sram_present:=nes_mapper_0.battery;
  ppu_nes_0.mirror:=MIRROR_VERTICAL;
  if (nes_header.flags6 and 8)<>0 then ppu_nes_0.mirror:=MIRROR_FOUR_SCREEN
    else if (nes_header.flags6 and 1)=0 then ppu_nes_0.mirror:=MIRROR_HORIZONTAL;
  //Parches!!!
  case crc32 of
    $3fc29044,$2ed79b73,$76124d08:submapper:=1; //MMC6
    $50f66538:memoria[$fffd]:=$ca; //Urban chan e-games
    $7a5cc019:begin
                memoria[$fb14]:=$04;
                memoria[$fb15]:=$04;
              end;
    $42edbce2,$acc2b74a,$d8dfd3d1:submapper:=1;
    $51ce0655,$761e1fc9,$57d8330a,$e1539190:begin
                mapper:=206;
                ppu_nes_0.mirror:=MIRROR_FOUR_SCREEN;
              end;
    $d327f0a:mapper:=154;
    $4433ba0a:mapper:=87;
    $3c7b0120,$ad893bf7,$2fb7d5b9,$977f982,$d994d5ff,$f07d31b2,$e476313e,$103f0755,$63d71cda,$a8a1c2eb,$c8e5e815,$6fdf50d0,$154a31b6:mapper:=206;
    $d122ba8d,$62e7aec5,$6ee61da3:mapper:=152;
  end;
  rom_crc32:=calc_crc(@nes_mapper_0.chr[0,0],$2000);
  if ((mapper=243) and (rom_crc32<>$282dcb3a) and (rom_crc32<>$331802e2)) then mapper:=150;
  case rom_crc32 of
    $19c5c4aa:if mapper=25 then begin //VRC2-c
                submapper:=1;
                mapper:=23;
              end;
    $824324fa,$87c17609,$3b31f998:if mapper=25 then submapper:=3; //VRC4-b
    $f82b8e59:if mapper=21 then submapper:=1; //VRC4-c
    $ae17c652,$23f896a7:if mapper=25 then submapper:=4; //VRC4-d
    $a30927de,$7b790220,$c2cf279a,$88b512d6,$eb9fd289:if mapper=23 then begin //VRC4-e
                submapper:=2;
                mapper:=21;
              end;
    $bd493548:submapper:=1; //VRC7-b
    $7ff2dc2b,$6add6cd6,$1557191a,$8f03a735,$e8d170d8,$cc06cf3e:if mapper=33 then mapper:=48;
    $f47f0bca:if mapper=173 then mapper:=132;
    $1a145504,$19c33692:if mapper=79 then mapper:=173;
    $479fb8e6:mapper:=133;
  end;
  if mapper=6 then begin
    if not is20 then submapper:=1;
    nes_mapper_0.battery:=false;nes_0.sram_present:=false;
  end;
  if ((mapper=5) and not(is20)) then nes_mapper_0.ram_bytes:=$10000;
  if (nes_mapper_0.battery and (nes_mapper_0.nvram_bytes=0)) then nes_mapper_0.nvram_bytes:=nes_mapper_0.ram_bytes;
  abrir_cartucho:=nes_mapper_0.set_mapper(mapper,submapper);
  if result then begin
    if (nes_mapper_0.trainer_present and (mapper<>6)) then copymemory(@memoria[$7000],@nes_mapper_0.trainer[0],512);
    if nes_mapper_0.battery then nes_mapper_0.load_battery(nv_ram_name);
  end;
end;

procedure abrir_nes;
var
  extension,nombre_file,romfile:string;
  datos:pbyte;
  longitud:integer;
begin
  if not(openrom(romfile,SNES)) then exit;
  getmem(datos,$400000);
  if not(extract_data(romfile,datos,longitud,nombre_file,SNES)) then begin
    freemem(datos);
    exit;
  end;
  extension:=extension_fichero(nombre_file);
  //Guardar la SRAM
  if nes_0.sram_present then nes_mapper_0.save_battery(nv_ram_name);
  if @n2a03_0.additional_sound<>nil then n2a03_0.add_more_sound(nil);
  if extension='DSP' then snapshot_r(datos,longitud,SNES);
  if extension='NES' then begin
    nv_ram_name:=Directory.Arcade_nvram+ChangeFileExt(nombre_file,'.nv');
    if abrir_cartucho(datos,longitud) then begin
      if nes_0.sram_present then nv_ram_name:=Directory.Arcade_nvram+ChangeFileExt(nombre_file,'.nv');
      nes_reset;
    end;
  end;
  freemem(datos);
  main_vars.nombre_caption:=nombre_file;
  change_caption;
  Directory.Nes:=ExtractFilePath(romfile);
end;

procedure grabar_nes;
var
  nombre:string;
begin
  nombre:=snapshot_main_write(SNES);
  Directory.nes:=ExtractFilePath(nombre);
end;

procedure nes_cerrar;
begin
  if nes_0.sram_present then nes_mapper_0.save_battery(nv_ram_name);
  nes_mapper_0.free;
  ppu_nes_0.free;
end;

function iniciar_nes:boolean;
begin
  principal1.BitBtn10.Glyph:=nil;
  principal1.imagelist2.GetBitmap(2,principal1.BitBtn10.Glyph);
  llamadas_maquina.bucle_general:=nes_principal;
  llamadas_maquina.close:=nes_cerrar;
  llamadas_maquina.reset:=nes_reset;
  llamadas_maquina.cartuchos:=abrir_nes;
  llamadas_maquina.grabar_snapshot:=grabar_nes;
  llamadas_maquina.fps_max:=NTSC_REFRESH;
  llamadas_maquina.scanlines:=NTSC_LINES;
  iniciar_audio(false);
  screen_init(1,512,1,true);
  screen_init(2,256,240);
  iniciar_video(256,240);
  //Main CPU
  n2a03_0:=cpu_n2a03.create(NTSC_clock);
  n2a03_0.m6502.change_ram_calls(nes_getbyte,nes_putbyte);
  n2a03_0.m6502.change_bus_cycle(nes_bus_cycle);
  n2a03_0.change_internals(nes_getbyte);
  ppu_nes_0:=nesppu_chip.create;
  nes_mapper_0:=tnes_mapper.create;
  nes_apu_irq_level:=false;
  nes_dmc_active:=false;
  nes_mapper_0.irq_changed:=nes_mapper_irq_changed;
  n2a03_0.change_irq_call(nes_apu_irq_changed);
  n2a03_0.set_external_clock(true);
  if main_vars.console_init then abrir_nes;
  iniciar_nes:=true;
end;

end.
