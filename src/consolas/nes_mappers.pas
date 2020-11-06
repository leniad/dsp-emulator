unit nes_mappers;
{
02/07
Añadidos mappers 68, 93, 94, 180 y 185
Corregidos bits en mappers 1,2 y 3

05/07
Añadidos mapper 12 y 9

18/12/18
Añadido mapper 11 y 147
Corregido mapper 67 y 185
Añadido pequeño delay en mapper 1

28/09
Corregidos graficos mapper 4
Añadido mapper 15
}

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nes_ppu,main_engine,n2a03,dialogs,ay_8910;

type
  nes_mmc5=packed record
              regs:array[0..$30] of byte;
              ram:array[0..$3ff] of byte;
           end;
  tnes_mapper=packed record
              prg:array[0..31,0..$3fff] of byte;
              prg_ram:array[0..63,0..$1fff] of byte; //PRG_RAM!
              chr:array[0..63,0..$1fff] of byte;
              reg:array[0..3] of byte;
              dreg:array[0..15] of byte;
              chr_map:array[0..1] of byte;
              shift,mode,cpu_count,serial_cnt,last_prg,last_chr,valor_map,latch0,latch1:byte;
              needirqdelay,reload_counter,counter:integer;
              prg_ena,forceclock,irq_ena,reload,chr_extra_ena,prg_ram_writeble,prg_ram_enable:boolean;
              mapper,submapper:byte;
              mm5:nes_mmc5;
              ppu_read:procedure (address:word);
           end;

//Mappers OK
procedure mapper_1_write_rom(direccion:word;valor:byte);
procedure mapper_1_delay(estados_t:word);
procedure mapper_2_write_rom(direccion:word;valor:byte);
procedure mapper_3_write_rom(direccion:word;valor:byte);
procedure mapper_4_write_rom(direccion:word;valor:byte);
procedure mapper_4_line;
procedure mapper_mmc6_write_rom(direccion:word;valor:byte);
function mapper_mmc6_wram_read(direccion:word):byte;
procedure mapper_mmc6_wram_write(direccion:word;valor:byte);
procedure mapper_7_write_rom(direccion:word;valor:byte);
procedure mapper_9_write_rom(direccion:word;valor:byte);
procedure mapper_9_ppu_read(direccion:word);
procedure mapper_11_write_rom(direccion:word;valor:byte);
procedure mapper_13_write_rom(direccion:word;valor:byte);
procedure mapper_15_write_rom(direccion:word;valor:byte);
procedure mapper_18_write_rom(direccion:word;valor:byte);
procedure mapper_18_irq(estados_t:word);
procedure mapper_34_write_rom(direccion:word;valor:byte);
procedure mapper_42_write_rom(direccion:word;valor:byte);
procedure mapper_42_irq(estados_t:word);
procedure mapper_66_write_rom(direccion:word;valor:byte);
procedure mapper_67_write_rom(direccion:word;valor:byte);
procedure mapper_67_irq(estados_t:word);
procedure mapper_68_write_rom(direccion:word;valor:byte);
procedure mapper_71_write_rom(direccion:word;valor:byte);
procedure mapper_87_write_rom(direccion:word;valor:byte);
procedure mapper_93_write_rom(direccion:word;valor:byte);
procedure mapper_94_write_rom(direccion:word;valor:byte);
procedure mapper_180_write_rom(direccion:word;valor:byte);
procedure mapper_185_write_rom(direccion:word;valor:byte);
procedure mapper_221_write_rom(direccion:word;valor:byte);

//Nuevos
procedure mapper_21_write_rom(direccion:word;valor:byte);
procedure mapper_22_write_rom(direccion:word;valor:byte);
procedure mapper_23_write_rom(direccion:word;valor:byte);
procedure mapper_33_write_rom(direccion:word;valor:byte);
procedure mapper_41_write_rom(direccion:word;valor:byte);
procedure mapper_48_write_rom(direccion:word;valor:byte);
procedure mapper_57_write_rom(direccion:word;valor:byte);
procedure mapper_65_write_rom(direccion:word;valor:byte);
procedure mapper_65_irq(estados_t:word);
procedure mapper_70_write_rom(direccion:word;valor:byte);
procedure mapper_73_write_rom(direccion:word;valor:byte);
procedure mapper_73_irq(estados_t:word);
procedure mapper_75_write_rom(direccion:word;valor:byte);
procedure mapper_76_write_rom(direccion:word;valor:byte);
procedure mapper_79_write_rom(direccion:word;valor:byte);
procedure mapper_88_write_rom(direccion:word;valor:byte);
procedure mapper_95_write_rom(direccion:word;valor:byte);
procedure mapper_113_write_rom(direccion:word;valor:byte);
function mapper_143_read_rom(direccion:word):byte;
procedure mapper_145_write_rom(direccion:word;valor:byte);
procedure mapper_147_write_rom(direccion:word;valor:byte);
procedure mapper_148_write_rom(direccion:word;valor:byte);
procedure mapper_149_write_rom(direccion:word;valor:byte);
function mapper_150_read_rom(direccion:word):byte;
procedure mapper_150_write_rom(direccion:word;valor:byte);
procedure mapper_152_write_rom(direccion:word;valor:byte);
procedure mapper_154_write_rom(direccion:word;valor:byte);
procedure mapper_172_write_rom(direccion:word;valor:byte);
function mapper_172_read(direccion:word):byte;
procedure mapper_184_write_rom(direccion:word;valor:byte);
procedure mapper_243_write_rom(direccion:word;valor:byte);
procedure mapper_vrc_irq(estados_t:word);

//A revisar
procedure mapper_12_write_rom(direccion:word;valor:byte);
procedure mapper_89_write_rom(direccion:word;valor:byte);
procedure mapper_116_write_rom(direccion:word;valor:byte);

//Trabajando
procedure mapper_64_write_rom(direccion:word;valor:byte);
procedure mapper_64_irq(estados_t:word);
procedure mapper_64_line;
procedure mapper_85_write_rom(direccion:word;valor:byte);

//Viendo
procedure mapper_32_write_rom(direccion:word;valor:byte);
procedure mapper_105_write_rom(direccion:word;valor:byte);
procedure mapper_105_irq(estados_t:word);
procedure mapper_206_write_rom(direccion:word;valor:byte);

//Estoy con ello!!
procedure mapper_58_write_rom(direccion:word;valor:byte);
procedure mapper_132_write_rom(direccion:word;valor:byte);
function mapper_132_read_exp(direccion:word):byte;
procedure mapper_132_write_exp(direccion:word;valor:byte);
procedure mapper_173_write_rom(direccion:word;valor:byte);
procedure mapper_133_write_rom(direccion:word;valor:byte);
procedure mapper_137_write_rom(direccion:word;valor:byte);
procedure mapper_139_write_rom(direccion:word;valor:byte);
procedure mapper_142_write_rom(direccion:word;valor:byte);
procedure mapper_142_irq(estados_t:word);
procedure mapper_212_write_rom(direccion:word;valor:byte);
function mapper_212_read_exp(direccion:word):byte;
procedure mapper_5_write_extended(direccion:word;valor:byte);
procedure mapper_5_write_rom(direccion:word;valor:byte);
function mapper_5_read_rom(direccion:word):byte;
procedure mapper_69_write_rom(direccion:word;valor:byte);
procedure mapper_69_irq(estados_t:word);
function mapper_69_read_prg_ram(direccion:word):byte;
procedure mapper_69_write_prg_ram(direccion:word;valor:byte);
procedure mapper_69_update_sound;

//all mappers
procedure mapper_reset;

var
  mapper_nes:^tnes_mapper;

implementation
uses nes;

procedure set_prg_16(pos:word;bank:word);
var
  tempb:byte;
begin
  tempb:=bank mod mapper_nes.last_prg;
  copymemory(@memoria[pos],@mapper_nes.prg[tempb,0],$4000);
end;

procedure set_prg_32(bank:word);
var
  tempb:byte;
begin
  if mapper_nes.last_prg=1 then set_prg_16($8000,bank)
  else begin
    tempb:=(bank mod (mapper_nes.last_prg shr 1)) shl 1;
    copymemory(@memoria[$8000],@mapper_nes.prg[tempb,0],$4000);
    copymemory(@memoria[$c000],@mapper_nes.prg[tempb or 1,0],$4000);
  end;
end;

procedure set_prg_8(pos:word;bank:word);
var
  tempb:byte;
begin
  tempb:=bank mod (mapper_nes.last_prg shl 1);
  copymemory(@memoria[pos],@mapper_nes.prg[tempb shr 1,$2000*(tempb and 1)],$2000);
end;

procedure set_chr_8(bank:word);
var
  tempb:byte;
begin
  tempb:=bank mod mapper_nes.last_chr;
  copymemory(@ppu_nes.chr[mapper_nes.chr_map[0],0],@mapper_nes.chr[tempb,0],$1000);
  copymemory(@ppu_nes.chr[mapper_nes.chr_map[1],0],@mapper_nes.chr[tempb,$1000],$1000);
end;

procedure set_chr_4(pos:word;bank:word);
var
  tempb:byte;
begin
  tempb:=bank mod (mapper_nes.last_chr shl 1);
  copymemory(@ppu_nes.chr[mapper_nes.chr_map[(pos shr 12) and 1],0],@mapper_nes.chr[tempb shr 1,$1000*(tempb and 1)],$1000);
end;

procedure set_chr_2(pos:word;bank:word);
var
  tempb:byte;
begin
  tempb:=bank mod (mapper_nes.last_chr shl 2);
  copymemory(@ppu_nes.chr[mapper_nes.chr_map[(pos shr 12) and 1],$800*((pos shr 11) and 1)],@mapper_nes.chr[tempb shr 2,$800*(tempb and 3)],$800);
end;

procedure set_chr_1(pos:word;bank:word);
var
  tempb:byte;
begin
  tempb:=bank mod (mapper_nes.last_chr shl 3);
  copymemory(@ppu_nes.chr[mapper_nes.chr_map[(pos shr 12) and 1],$400*((pos shr 10) and 3)],@mapper_nes.chr[tempb shr 3,$400*(tempb and 7)],$400);
end;

procedure mapper_1_delay(estados_t:word);
begin
  mapper_nes.counter:=mapper_nes.counter+estados_t;
end;

procedure mapper_1_chr;
begin
  if (mapper_nes.reg[0] and $10)<>0 then begin  //4kb
      if ppu_nes.write_chr then begin
        mapper_nes.chr_map[0]:=mapper_nes.reg[1];
        mapper_nes.chr_map[1]:=mapper_nes.reg[2];
        if ((mapper_nes.reg[1]>3) or (mapper_nes.reg[2]>3)) then begin
          MessageDlg('NES: Mapper 1 chr ram',mtInformation,[mbOk], 0);
        end;
      end else begin
        set_chr_4($0,mapper_nes.reg[1]);
        set_chr_4($1000,mapper_nes.reg[2]);
      end;
  end else begin //8Kb
      if ppu_nes.write_chr then begin
        mapper_nes.chr_map[0]:=0;
        mapper_nes.chr_map[1]:=1;
      end else begin
        set_chr_8((mapper_nes.reg[1] and $1f) shr 1);
      end;
  end;
end;

procedure mapper_1_prg;
var
  tempb,extra:byte;
begin
extra:=0;
//Usado por SxROM
if mapper_nes.last_prg>16 then extra:=mapper_nes.reg[1] and $10;
tempb:=((mapper_nes.reg[3] and $f) or extra) mod mapper_nes.last_prg;
case ((mapper_nes.reg[0] shr 2) and $3) of
    $0,$1:begin  //32Kb
        copymemory(@memoria[$8000],@mapper_nes.prg[tempb and $fe,0],$4000);
        copymemory(@memoria[$c000],@mapper_nes.prg[tempb or 1,0],$4000);
       end;
    $2:begin  //16k+16k --> primero fijo al banco 0
        copymemory(@memoria[$8000],@mapper_nes.prg[0 or extra,0],$4000);
        copymemory(@memoria[$c000],@mapper_nes.prg[tempb,0],$4000);
       end;
    $3:begin  //16k + 16k --> segundo fijo al ultimo banco que siempre es 15 o menos!!
        copymemory(@memoria[$8000],@mapper_nes.prg[tempb,0],$4000);
        copymemory(@memoria[$c000],@mapper_nes.prg[($f or extra) mod mapper_nes.last_prg,0],$4000);
       end;
end;
if mapper_nes.submapper=0 then mapper_nes.prg_ram_enable:=(mapper_nes.reg[3] and $10)=0;
end;

procedure mapper_1_write_rom(direccion:word;valor:byte);
begin
if ((mapper_nes.counter<2) and (mapper_nes.serial_cnt=0)) then exit;
if (valor and $80)<>0 then begin
  //Reset!!
  mapper_nes.serial_cnt:=0;
  mapper_nes.valor_map:=0;
  //ATENCION --> Necesario para 'Robocop 3'
  mapper_nes.reg[0]:=mapper_nes.reg[0] or $c;
  mapper_nes.counter:=0;
  copymemory(@memoria[$c000],@mapper_nes.prg[$f mod mapper_nes.last_prg,0],$4000);
end else begin
  mapper_nes.valor_map:=mapper_nes.valor_map or ((valor and 1) shl mapper_nes.serial_cnt);
  mapper_nes.serial_cnt:=mapper_nes.serial_cnt+1;
  mapper_nes.counter:=0;
  if mapper_nes.serial_cnt=5 then begin
    mapper_nes.reg[(direccion shr 13) and 3]:=mapper_nes.valor_map;
    case (mapper_nes.reg[0] and 3) of //Mirror
      0:ppu_nes.mirror:=MIRROR_LOW;
      1:ppu_nes.mirror:=MIRROR_HIGH;
      2:ppu_nes.mirror:=MIRROR_VERTICAL;
      3:ppu_nes.mirror:=MIRROR_HORIZONTAL;
    end;
    mapper_1_chr;
    mapper_1_prg;
    mapper_nes.valor_map:=0;
    mapper_nes.serial_cnt:=0;
  end;
  end;
end;

procedure mapper_2_write_rom(direccion:word;valor:byte);
begin
  set_prg_16($8000,valor);
end;

procedure mapper_3_write_rom(direccion:word;valor:byte);
begin
  set_chr_8(valor and $3);
end;

procedure mapper_4_update_chr(valor:byte);
var
  base_chr:word;
begin
if not(ppu_nes.write_chr) then begin
  //Las paginas de CHR son de 1K siempre!! Cuando copia 2K copia 1K+1K
  base_chr:=(valor and $80) shl 5;
  set_chr_1($0 xor base_chr,mapper_nes.dreg[0] and $fe);
  set_chr_1($400 xor base_chr,mapper_nes.dreg[0] or 1);
  set_chr_1($800 xor base_chr,mapper_nes.dreg[1] and $fe);
  set_chr_1($c00 xor base_chr,mapper_nes.dreg[1] or 1);
  set_chr_1($1000 xor base_chr,mapper_nes.dreg[2]);
  set_chr_1($1400 xor base_chr,mapper_nes.dreg[3]);
  set_chr_1($1800 xor base_chr,mapper_nes.dreg[4]);
  set_chr_1($1c00 xor base_chr,mapper_nes.dreg[5]);
end;
end;

procedure mapper_4_update_prg(valor:byte);
var
  temp1,temp2:byte;
begin
temp1:=mapper_nes.dreg[6] mod (mapper_nes.last_prg shl 1);
temp2:=mapper_nes.dreg[7] mod (mapper_nes.last_prg shl 1);
set_prg_8($a000,temp2);
if (valor and $40)=0 then begin
  set_prg_8($8000,temp1);
  set_prg_8($c000,(mapper_nes.last_prg shl 1)-2);
end else begin
  set_prg_8($8000,(mapper_nes.last_prg shl 1)-2);
  set_prg_8($c000,temp1);
end;
end;

procedure mapper_4_write_rom(direccion:word;valor:byte);
begin
case (direccion and $e001) of
  $8000:begin
          if ((valor and $40)<>(mapper_nes.reg[0] and $40)) then mapper_4_update_prg(valor);
		      if ((valor and $80)<>(mapper_nes.reg[0] and $80)) then mapper_4_update_chr(valor);
          mapper_nes.reg[0]:=valor;
        end;
  $8001:begin
          if (mapper_nes.reg[0] and 7)<2 then valor:=valor and $fe;
          mapper_nes.dreg[mapper_nes.reg[0] and 7]:=valor;
          mapper_4_update_prg(mapper_nes.reg[0]);
          mapper_4_update_chr(mapper_nes.reg[0]);
        end;
  $a000:if ppu_nes.mirror<>MIRROR_FOUR_SCREEN then begin //Usado por Gauntlet!!!
          if (valor and 1)=0 then ppu_nes.mirror:=MIRROR_VERTICAL
            else ppu_nes.mirror:=MIRROR_HORIZONTAL;
        end;
  $a001:begin
          mapper_nes.prg_ram_enable:=(valor and $80)<>0;
          mapper_nes.prg_ram_writeble:=(valor and $40)=0;
          mapper_nes.reg[3]:=valor;
        end;
  $c000:mapper_nes.reg[2]:=valor;
  $c001:begin
          mapper_nes.reload:=true;
          mapper_nes.reg[1]:=0;
        end;
  $e000:begin
             mapper_nes.irq_ena:=false;
             n2a03_0.m6502.change_irq(CLEAR_LINE);
        end;
  $e001:mapper_nes.irq_ena:=true;
end;
end;

procedure mapper_4_line;
begin
if (ppu_nes.control2 and $18)<>0 then begin
  if ((mapper_nes.reg[1]=0) or mapper_nes.reload) then begin
    mapper_nes.reg[1]:=mapper_nes.reg[2];
    mapper_nes.reload:=false;
  end else mapper_nes.reg[1]:=mapper_nes.reg[1]-1;
  if (mapper_nes.reg[1]=0) then begin
    mapper_nes.reload:=true;
    if mapper_nes.irq_ena then n2a03_0.m6502.change_irq(ASSERT_LINE);
  end;
end;
end;

procedure mapper_5_update_prg;
begin
case (mapper_nes.mm5.regs[0] and 3) of
  0:set_prg_32(mapper_nes.mm5.regs[$17] and $7f); //32k
  1:begin //16k+16k
      set_prg_16($8000,mapper_nes.mm5.regs[$15] and $7f);
      set_prg_16($c000,mapper_nes.mm5.regs[$17] and $7f);
    end;
  2:begin //16k+8k+8k
      set_prg_16($8000,mapper_nes.mm5.regs[$15] and $7f);
      set_prg_8($c000,mapper_nes.mm5.regs[$16] and $7f);
      set_prg_8($e000,mapper_nes.mm5.regs[$17] and $7f);
    end;
  3:begin //8k+8k+8k+8k
      set_prg_8($8000,mapper_nes.mm5.regs[$14] and $7f);
      set_prg_8($a000,mapper_nes.mm5.regs[$15] and $7f);
      set_prg_8($c000,mapper_nes.mm5.regs[$16] and $7f);
      set_prg_8($e000,mapper_nes.mm5.regs[$17] and $7f);
    end;
end;
end;

procedure mapper_5_update_chr;
begin
case (mapper_nes.mm5.regs[1] and 3) of
  0:set_chr_8(mapper_nes.mm5.regs[$27]);  //8k
  1:begin //4k
      set_chr_4(0,mapper_nes.mm5.regs[$23]);
      set_chr_4($1000,mapper_nes.mm5.regs[$27]);
    end;
  2:begin //2k
      set_chr_2(0,mapper_nes.mm5.regs[$21]);
      set_chr_2($800,mapper_nes.mm5.regs[$23]);
      set_chr_2($1000,mapper_nes.mm5.regs[$25]);
      set_chr_2($1800,mapper_nes.mm5.regs[$27]);
    end;
  3:begin //1k
      set_chr_1(0,mapper_nes.mm5.regs[$20]);
      set_chr_1($400,mapper_nes.mm5.regs[$21]);
      set_chr_1($800,mapper_nes.mm5.regs[$22]);
      set_chr_1($c00,mapper_nes.mm5.regs[$23]);
      set_chr_1($1000,mapper_nes.mm5.regs[$24]);
      set_chr_1($1400,mapper_nes.mm5.regs[$25]);
      set_chr_1($1800,mapper_nes.mm5.regs[$26]);
      set_chr_1($1c00,mapper_nes.mm5.regs[$27]);
    end;
end;
end;

procedure mapper_5_write_extended(direccion:word;valor:byte);
begin
case direccion of
  $5100..$512b:mapper_nes.mm5.regs[direccion and $3f]:=valor;
end;
mapper_5_update_prg;
mapper_5_update_chr;
end;

procedure mapper_5_write_rom(direccion:word;valor:byte);
begin
case (mapper_nes.mm5.regs[0] and 3) of
  0:; //32k todo ROM
  1:case direccion of
        $8000..$9fff:if (mapper_nes.mm5.regs[$15] and $80)=0 then mapper_nes.prg_ram[mapper_nes.mm5.regs[$15] and $e,direccion and $1fff]:=valor;
        $a000..$bfff:if (mapper_nes.mm5.regs[$15] and $80)=0 then mapper_nes.prg_ram[(mapper_nes.mm5.regs[$15] and $e) or 1,direccion and $1fff]:=valor;
        $c000..$ffff:;
    end;
  2:case direccion of
        $8000..$9fff:if (mapper_nes.mm5.regs[$15] and $80)=0 then mapper_nes.prg_ram[mapper_nes.mm5.regs[$15] and $e,direccion and $1fff]:=valor;
        $a000..$bfff:if (mapper_nes.mm5.regs[$15] and $80)=0 then mapper_nes.prg_ram[(mapper_nes.mm5.regs[$15] and $e) or 1,direccion and $1fff]:=valor;
        $c000..$dfff:if (mapper_nes.mm5.regs[$16] and $80)=0 then mapper_nes.prg_ram[mapper_nes.mm5.regs[$16] and $f,direccion and $1fff]:=valor;
        $e000..$ffff:;
    end;
  3:case direccion of
        $8000..$9fff:if (mapper_nes.mm5.regs[$14] and $80)=0 then mapper_nes.prg_ram[mapper_nes.mm5.regs[$14] and $f,direccion and $1fff]:=valor;
        $a000..$bfff:if (mapper_nes.mm5.regs[$15] and $80)=0 then mapper_nes.prg_ram[mapper_nes.mm5.regs[$15] and $f,direccion and $1fff]:=valor;
        $c000..$dfff:if (mapper_nes.mm5.regs[$16] and $80)=0 then mapper_nes.prg_ram[mapper_nes.mm5.regs[$16] and $f,direccion and $1fff]:=valor;
        $e000..$ffff:;
    end;
end;
end;

function mapper_5_read_rom(direccion:word):byte;
begin
case (mapper_nes.mm5.regs[0] and 3) of
  0:mapper_5_read_rom:=memoria[direccion];
  1:case direccion of
        $8000..$9fff:if (mapper_nes.mm5.regs[$15] and $80)=0 then mapper_5_read_rom:=mapper_nes.prg_ram[mapper_nes.mm5.regs[$15] and $e,direccion and $1fff]
                        else mapper_5_read_rom:=memoria[direccion];
        $a000..$bfff:if (mapper_nes.mm5.regs[$15] and $80)=0 then mapper_5_read_rom:=mapper_nes.prg_ram[(mapper_nes.mm5.regs[$15] and $e) or 1,direccion and $1fff]
                      else mapper_5_read_rom:=memoria[direccion];
        $c000..$ffff:mapper_5_read_rom:=memoria[direccion];
    end;
  2:case direccion of
        $8000..$9fff:if (mapper_nes.mm5.regs[$15] and $80)=0 then mapper_5_read_rom:=mapper_nes.prg_ram[mapper_nes.mm5.regs[$15] and $e,direccion and $1fff]
                      else mapper_5_read_rom:=memoria[direccion];
        $a000..$bfff:if (mapper_nes.mm5.regs[$15] and $80)=0 then mapper_5_read_rom:=mapper_nes.prg_ram[(mapper_nes.mm5.regs[$15] and $e) or 1,direccion and $1fff]
                      else mapper_5_read_rom:=memoria[direccion];
        $c000..$dfff:if (mapper_nes.mm5.regs[$16] and $80)=0 then mapper_5_read_rom:=mapper_nes.prg_ram[mapper_nes.mm5.regs[$16] and $f,direccion and $1fff]
                      else mapper_5_read_rom:=memoria[direccion];
        $e000..$ffff:mapper_5_read_rom:=memoria[direccion];
    end;
  3:case direccion of
        $8000..$9fff:if (mapper_nes.mm5.regs[$14] and $80)=0 then mapper_5_read_rom:=mapper_nes.prg_ram[mapper_nes.mm5.regs[$14] and $f,direccion and $1fff]
                      else mapper_5_read_rom:=memoria[direccion];
        $a000..$bfff:if (mapper_nes.mm5.regs[$15] and $80)=0 then mapper_5_read_rom:=mapper_nes.prg_ram[mapper_nes.mm5.regs[$15] and $f,direccion and $1fff]
                      else mapper_5_read_rom:=memoria[direccion];
        $c000..$dfff:if (mapper_nes.mm5.regs[$16] and $80)=0 then mapper_5_read_rom:=mapper_nes.prg_ram[mapper_nes.mm5.regs[$16] and $f,direccion and $1fff]
                      else mapper_5_read_rom:=memoria[direccion];
        $e000..$ffff:mapper_5_read_rom:=memoria[direccion];
    end;
end;
end;

procedure mapper_mmc6_write_rom(direccion:word;valor:byte);
begin
direccion:=direccion and $e001;
case direccion of
  $8000:begin //Especifico de MMC6
          if ((valor and $40)<>(mapper_nes.reg[0] and $40)) then mapper_4_update_prg(valor);
		      if ((valor and $80)<>(mapper_nes.reg[0] and $80)) then mapper_4_update_chr(valor);
          mapper_nes.prg_ram_enable:=(valor and $20)<>0;
          mapper_nes.reg[0]:=valor;
        end;
  $8001:begin
          mapper_nes.dreg[mapper_nes.reg[0] and 7]:=valor;
          mapper_4_update_prg(mapper_nes.reg[0]);
          mapper_4_update_chr(mapper_nes.reg[0]);
        end;
  $a000:if ppu_nes.mirror<>MIRROR_FOUR_SCREEN then begin
          if (valor and 1)=0 then ppu_nes.mirror:=MIRROR_VERTICAL
            else ppu_nes.mirror:=MIRROR_HORIZONTAL;
        end;
  $a001:mapper_nes.reg[3]:=valor; //Especifico de MMC6
  $c000:begin
            mapper_nes.reg[2]:=valor;
            mapper_nes.reload:=true;
        end;
  $c001:mapper_nes.reload:=true;
  $e000:begin
             mapper_nes.irq_ena:=false;
             n2a03_0.m6502.change_irq(CLEAR_LINE);
        end;
  $e001:mapper_nes.irq_ena:=true;
end;
end;

function mapper_mmc6_wram_read(direccion:word):byte;
begin
if (not(mapper_nes.prg_ram_enable) or ((mapper_nes.reg[3] and $a0)=0)) then begin //Si esta disabled o si estan desabilitados los dos bancos --> open bus
  mapper_mmc6_wram_read:=direccion and $ff;
  exit;
end;
case direccion of
  $6000..$6fff:mapper_mmc6_wram_read:=direccion and $ff;
  $7000..$71ff,$7400..$75ff,$7800..$79ff,$7c00..$7dff:if ((mapper_nes.reg[3] and $20)<>0) then mapper_mmc6_wram_read:=memoria[$7000+(direccion and $1ff)]
                                                        else mapper_mmc6_wram_read:=0;
  $7200..$73ff,$7600..$77ff,$7a00..$7bff,$7e00..$7fff:if ((mapper_nes.reg[3] and $80)<>0) then mapper_mmc6_wram_read:=memoria[$7200+(direccion and $1ff)]
                                                        else mapper_mmc6_wram_read:=0;
end;
end;

procedure mapper_mmc6_wram_write(direccion:word;valor:byte);
begin
if not(mapper_nes.prg_ram_enable) then exit; //Si esta disabled, no hago nada
case direccion of
  $6000..$6fff:;
  $7000..$71ff,$7400..$75ff,$7800..$79ff,$7c00..$7dff:if ((mapper_nes.reg[3] and $30)=$30) then memoria[$7000+(direccion and $1ff)]:=valor;
  $7200..$73ff,$7600..$77ff,$7a00..$7bff,$7e00..$7fff:if ((mapper_nes.reg[3] and $c0)=$c0) then memoria[$7200+(direccion and $1ff)]:=valor;
end;
end;

procedure mapper_7_write_rom(direccion:word;valor:byte);
begin
set_prg_32(valor and $f);
if (valor and $10)=0 then ppu_nes.mirror:=MIRROR_LOW
  else ppu_nes.mirror:=MIRROR_HIGH;
end;

procedure mapper_9_write_rom(direccion:word;valor:byte);
begin
case (direccion shr 12) of
  $a:set_prg_8($8000,valor and $f);
  $b:mapper_nes.reg[0]:=valor and $1f;
  $c:mapper_nes.reg[1]:=valor and $1f;
  $d:mapper_nes.reg[2]:=valor and $1f;
  $e:mapper_nes.reg[3]:=valor and $1f;
  $f:if (valor and 1)<>0 then ppu_nes.mirror:=MIRROR_HORIZONTAL
        else ppu_nes.mirror:=MIRROR_VERTICAL;
end;
end;

procedure mapper_9_ppu_read(direccion:word);
begin
if mapper_nes.reload then begin
  set_chr_4($0,mapper_nes.reg[mapper_nes.latch0]);
  set_chr_4($1000,mapper_nes.reg[mapper_nes.latch1]);
  mapper_nes.reload:=false;
end;
case (direccion and $3ff0) of
  $0fd0:begin //latch0 $fd
          mapper_nes.reload:=mapper_nes.latch0<>0;
          mapper_nes.latch0:=0;
       end;
  $0fe0:begin //latch0 $fe
          mapper_nes.reload:=mapper_nes.latch0<>1;
          mapper_nes.latch0:=1;
       end;
  $1fd0:begin //latch1 $fd
          mapper_nes.reload:=mapper_nes.latch1<>2;
          mapper_nes.latch1:=2;
        end;
  $1fe0:begin //latch1 $fe
          mapper_nes.reload:=mapper_nes.latch1<>3;
          mapper_nes.latch1:=3;
        end;
end;
end;

procedure mapper_11_write_rom(direccion:word;valor:byte);
begin
  set_prg_32(valor and $3);
  if mapper_nes.last_chr<>0 then set_chr_8(valor shr 4);
end;

procedure mapper_12_write_rom(direccion:word;valor:byte);
begin
case direccion of
  $4000..$5fff:mapper_nes.latch1:=valor;
  else mapper_4_write_rom(direccion,valor);
end;
end;

procedure mapper_13_write_rom(direccion:word;valor:byte);
begin
  mapper_nes.chr_map[1]:=valor and 3;
end;

procedure mapper_15_write_rom(direccion:word;valor:byte);
var
  tempb:byte;
begin
tempb:=(valor and $3f) mod mapper_nes.last_prg;
case (direccion and 3) of
    0:begin //32k banks
        copymemory(@memoria[$8000],@mapper_nes.prg[tempb,0],$4000);
        copymemory(@memoria[$c000],@mapper_nes.prg[tempb or 1,0],$4000);
      end;
    1:begin //128k
        copymemory(@memoria[$8000],@mapper_nes.prg[tempb,0],$4000);
        tempb:=((valor and $3f) or 7) mod mapper_nes.last_prg;
        copymemory(@memoria[$c000],@mapper_nes.prg[tempb,0],$4000);
      end;
    2:begin //8kb banks
        copymemory(@memoria[$8000],@mapper_nes.prg[tempb,$2000*((valor and $80) shr 7)],$2000);
        //Mirrors!!
        copymemory(@memoria[$a000],@memoria[$8000],$2000);
        copymemory(@memoria[$c000],@memoria[$8000],$2000);
        copymemory(@memoria[$e000],@memoria[$8000],$2000);
      end;
    3:begin //16k banks
        copymemory(@memoria[$8000],@mapper_nes.prg[tempb,0],$4000);
        //Mirrors!!
        copymemory(@memoria[$c000],@memoria[$8000],$4000);
      end;
  end;
  if (valor and $40)=0 then ppu_nes.mirror:=MIRROR_VERTICAL
    else ppu_nes.mirror:=MIRROR_HORIZONTAL;
end;

procedure mapper_18_write_rom(direccion:word;valor:byte);
begin
case (direccion and $f003) of
  $8000:begin
          mapper_nes.reg[0]:=(mapper_nes.reg[0] and $f0) or (valor and $f);
          set_prg_8($8000,mapper_nes.reg[0]);
        end;
  $8001:begin
          mapper_nes.reg[0]:=(mapper_nes.reg[0] and $f) or ((valor and $f) shl 4);
          set_prg_8($8000,mapper_nes.reg[0]);
        end;
  $8002:begin
          mapper_nes.reg[1]:=(mapper_nes.reg[1] and $f0) or (valor and $f);
          set_prg_8($a000,mapper_nes.reg[1]);
        end;
  $8003:begin
          mapper_nes.reg[1]:=(mapper_nes.reg[1] and $f) or ((valor and $f) shl 4);
          set_prg_8($a000,mapper_nes.reg[1]);
        end;
  $9000:begin
          mapper_nes.reg[2]:=(mapper_nes.reg[2] and $f0) or (valor and $f);
          set_prg_8($c000,mapper_nes.reg[2]);
        end;
  $9001:begin
          mapper_nes.reg[2]:=(mapper_nes.reg[2] and $f) or ((valor and $f) shl 4);
          set_prg_8($c000,mapper_nes.reg[2]);
        end;
  $a000:begin
          mapper_nes.dreg[0]:=(mapper_nes.dreg[0] and $f0) or (valor and $f);
          set_chr_1($0,mapper_nes.dreg[0]);
        end;
  $a001:begin
          mapper_nes.dreg[0]:=(mapper_nes.dreg[0] and $f) or ((valor and $f) shl 4);
          set_chr_1($0,mapper_nes.dreg[0]);
        end;
  $a002:begin
          mapper_nes.dreg[1]:=(mapper_nes.dreg[1] and $f0) or (valor and $f);
          set_chr_1($400,mapper_nes.dreg[1]);
        end;
  $a003:begin
          mapper_nes.dreg[1]:=(mapper_nes.dreg[1] and $f) or ((valor and $f) shl 4);
          set_chr_1($400,mapper_nes.dreg[1]);
        end;
  $b000:begin
          mapper_nes.dreg[2]:=(mapper_nes.dreg[2] and $f0) or (valor and $f);
          set_chr_1($800,mapper_nes.dreg[2]);
        end;
  $b001:begin
          mapper_nes.dreg[2]:=(mapper_nes.dreg[2] and $f) or ((valor and $f) shl 4);
          set_chr_1($800,mapper_nes.dreg[2]);
        end;
  $b002:begin
          mapper_nes.dreg[3]:=(mapper_nes.dreg[3] and $f0) or (valor and $f);
          set_chr_1($c00,mapper_nes.dreg[3]);
        end;
  $b003:begin
          mapper_nes.dreg[3]:=(mapper_nes.dreg[3] and $f) or ((valor and $f) shl 4);
          set_chr_1($c00,mapper_nes.dreg[3]);
        end;
  $c000:begin
          mapper_nes.dreg[4]:=(mapper_nes.dreg[4] and $f0) or (valor and $f);
          set_chr_1($1000,mapper_nes.dreg[4]);
        end;
  $c001:begin
          mapper_nes.dreg[4]:=(mapper_nes.dreg[4] and $f) or ((valor and $f) shl 4);
          set_chr_1($1000,mapper_nes.dreg[4]);
        end;
  $c002:begin
          mapper_nes.dreg[5]:=(mapper_nes.dreg[5] and $f0) or (valor and $f);
          set_chr_1($1400,mapper_nes.dreg[5]);
        end;
  $c003:begin
          mapper_nes.dreg[5]:=(mapper_nes.dreg[5] and $f) or ((valor and $f) shl 4);
          set_chr_1($1400,mapper_nes.dreg[5]);
        end;
  $d000:begin
          mapper_nes.dreg[6]:=(mapper_nes.dreg[6] and $f0) or (valor and $f);
          set_chr_1($1800,mapper_nes.dreg[6]);
        end;
  $d001:begin
          mapper_nes.dreg[6]:=(mapper_nes.dreg[6] and $f) or ((valor and $f) shl 4);
          set_chr_1($1800,mapper_nes.dreg[6]);
        end;
  $d002:begin
          mapper_nes.dreg[7]:=(mapper_nes.dreg[7] and $f0) or (valor and $f);
          set_chr_1($1c00,mapper_nes.dreg[7]);
        end;
  $d003:begin
          mapper_nes.dreg[7]:=(mapper_nes.dreg[7] and $f) or ((valor and $f) shl 4);
          set_chr_1($1c00,mapper_nes.dreg[7]);
        end;
  $e000:mapper_nes.reload_counter:=(mapper_nes.reload_counter and $fff0) or (valor and $f);
  $e001:mapper_nes.reload_counter:=(mapper_nes.reload_counter and $ff0f) or ((valor and $f) shl 4);
  $e002:mapper_nes.reload_counter:=(mapper_nes.reload_counter and $f0ff) or ((valor and $f) shl 8);
  $e003:mapper_nes.reload_counter:=(mapper_nes.reload_counter and $0fff) or ((valor and $f) shl 12);
  $f000:begin
          mapper_nes.counter:=mapper_nes.reload_counter;
          n2a03_0.m6502.change_irq(CLEAR_LINE);
        end;
  $f001:begin
          mapper_nes.irq_ena:=(valor and 1)<>0;
          mapper_nes.reg[3]:=(valor shr 1) and 7;
          n2a03_0.m6502.change_irq(CLEAR_LINE);
        end;
  $f002:case (valor and 3) of
          0:ppu_nes.mirror:=MIRROR_HORIZONTAL;
          1:ppu_nes.mirror:=MIRROR_VERTICAL;
          2:ppu_nes.mirror:=MIRROR_LOW;
          3:ppu_nes.mirror:=MIRROR_HIGH;
        end;
  //$f003:UPD7756;
end;
end;

procedure mapper_18_irq(estados_t:word);
var
  temp:integer;
begin
if mapper_nes.irq_ena then begin
  case mapper_nes.reg[3] of
    0:begin //16bits
          mapper_nes.counter:=mapper_nes.counter-estados_t;
          if mapper_nes.counter<0 then begin
            n2a03_0.m6502.change_irq(ASSERT_LINE);
            mapper_nes.counter:=mapper_nes.counter+$ffff;
          end;
      end;
    1:begin //12bits
          temp:=mapper_nes.counter and $fff;
          temp:=temp-estados_t;
          if temp<0 then begin
            n2a03_0.m6502.change_irq(ASSERT_LINE);
            temp:=temp+$fff;
          end;
          mapper_nes.counter:=(mapper_nes.counter and $f000) or (temp and $fff)
      end;
    2,3:begin //8bits
          temp:=mapper_nes.counter and $ff;
          temp:=temp-estados_t;
          if temp<0 then begin
            n2a03_0.m6502.change_irq(ASSERT_LINE);
            temp:=temp+$ff;
          end;
          mapper_nes.counter:=(mapper_nes.counter and $ff00) or (temp and $ff)
      end;
    4..7:begin //4bits
          temp:=mapper_nes.counter and $f;
          temp:=temp-estados_t;
          if temp<0 then begin
            n2a03_0.m6502.change_irq(ASSERT_LINE);
            temp:=temp+$f;
          end;
          mapper_nes.counter:=(mapper_nes.counter and $fff0) or (temp and $f)
      end;
  end;
end;
end;

procedure mapper_22_write_rom(direccion:word;valor:byte);
begin
  direccion:=(direccion and $fffc) or ((direccion and 1) shl 1) or ((direccion and 2) shr 1);
  case (direccion and $f003) of
    $8000..$8003:set_prg_8($8000,valor and $1f);
    $9000..$9003:if (valor and 1)<>0 then ppu_nes.mirror:=MIRROR_HORIZONTAL
                    else ppu_nes.mirror:=MIRROR_VERTICAL;
    $a000..$a003:set_prg_8($a000,valor and $1f);
    $b000:begin
            mapper_nes.dreg[0]:=valor and $f;
            set_chr_1($0,(mapper_nes.dreg[0] or (mapper_nes.dreg[1] shl 4)) shr 1);
          end;
    $b001:begin
            mapper_nes.dreg[1]:=valor and $1f;
            set_chr_1($0,(mapper_nes.dreg[0] or (mapper_nes.dreg[1] shl 4)) shr 1);
          end;
    $b002:begin
            mapper_nes.dreg[2]:=valor and $f;
            set_chr_1($400,(mapper_nes.dreg[2] or (mapper_nes.dreg[3] shl 4)) shr 1);
          end;
    $b003:begin
            mapper_nes.dreg[3]:=valor and $1f;
            set_chr_1($400,(mapper_nes.dreg[2] or (mapper_nes.dreg[3] shl 4)) shr 1);
          end;
    $c000:begin
            mapper_nes.dreg[4]:=valor and $f;
            set_chr_1($800,(mapper_nes.dreg[4] or (mapper_nes.dreg[5] shl 4)) shr 1);
          end;
    $c001:begin
            mapper_nes.dreg[5]:=valor and $1f;
            set_chr_1($800,(mapper_nes.dreg[4] or (mapper_nes.dreg[5] shl 4)) shr 1);
          end;
    $c002:begin
            mapper_nes.dreg[6]:=valor and $f;
            set_chr_1($c00,(mapper_nes.dreg[6] or (mapper_nes.dreg[7] shl 4)) shr 1);
          end;
    $c003:begin
            mapper_nes.dreg[7]:=valor and $1f;
            set_chr_1($c00,(mapper_nes.dreg[6] or (mapper_nes.dreg[7] shl 4)) shr 1);
          end;
    $d000:begin
            mapper_nes.dreg[8]:=valor and $f;
            set_chr_1($1000,(mapper_nes.dreg[8] or (mapper_nes.dreg[9] shl 4)) shr 1);
          end;
    $d001:begin
            mapper_nes.dreg[9]:=valor and $1f;
            set_chr_1($1000,(mapper_nes.dreg[8] or (mapper_nes.dreg[9] shl 4)) shr 1);
          end;
    $d002:begin
            mapper_nes.dreg[10]:=valor and $f;
            set_chr_1($1400,(mapper_nes.dreg[10] or (mapper_nes.dreg[11] shl 4)) shr 1);
          end;
    $d003:begin
            mapper_nes.dreg[11]:=valor and $1f;
            set_chr_1($1400,(mapper_nes.dreg[10] or (mapper_nes.dreg[11] shl 4)) shr 1);
          end;
    $e000:begin
            mapper_nes.dreg[12]:=valor and $f;
            set_chr_1($1800,(mapper_nes.dreg[12] or (mapper_nes.dreg[13] shl 4)) shr 1);
          end;
    $e001:begin
            mapper_nes.dreg[13]:=valor and $1f;
            set_chr_1($1800,(mapper_nes.dreg[12] or (mapper_nes.dreg[13] shl 4)) shr 1);
          end;
    $e002:begin
            mapper_nes.dreg[14]:=valor and $f;
            set_chr_1($1c00,(mapper_nes.dreg[14] or (mapper_nes.dreg[15] shl 4)) shr 1);
          end;
    $e003:begin
            mapper_nes.dreg[15]:=valor and $1f;
            set_chr_1($1c00,(mapper_nes.dreg[14] or (mapper_nes.dreg[15] shl 4)) shr 1);
          end;
  end;
end;

procedure vrc_chr(direccion:word;valor:byte);
begin
case direccion of
    $b000:begin
            mapper_nes.dreg[0]:=valor and $f;
            set_chr_1($0,mapper_nes.dreg[0] or (mapper_nes.dreg[1] shl 4));
          end;
    $b001:begin
            mapper_nes.dreg[1]:=valor and $1f;
            set_chr_1($0,mapper_nes.dreg[0] or (mapper_nes.dreg[1] shl 4));
          end;
    $b002:begin
            mapper_nes.dreg[2]:=valor and $f;
            set_chr_1($400,mapper_nes.dreg[2] or (mapper_nes.dreg[3] shl 4));
          end;
    $b003:begin
            mapper_nes.dreg[3]:=valor and $1f;
            set_chr_1($400,mapper_nes.dreg[2] or (mapper_nes.dreg[3] shl 4));
          end;
    $c000:begin
            mapper_nes.dreg[4]:=valor and $f;
            set_chr_1($800,mapper_nes.dreg[4] or (mapper_nes.dreg[5] shl 4));
          end;
    $c001:begin
            mapper_nes.dreg[5]:=valor and $1f;
            set_chr_1($800,mapper_nes.dreg[4] or (mapper_nes.dreg[5] shl 4));
          end;
    $c002:begin
            mapper_nes.dreg[6]:=valor and $f;
            set_chr_1($c00,mapper_nes.dreg[6] or (mapper_nes.dreg[7] shl 4));
          end;
    $c003:begin
            mapper_nes.dreg[7]:=valor and $1f;
            set_chr_1($c00,mapper_nes.dreg[6] or (mapper_nes.dreg[7] shl 4));
          end;
    $d000:begin
            mapper_nes.dreg[8]:=valor and $f;
            set_chr_1($1000,mapper_nes.dreg[8] or (mapper_nes.dreg[9] shl 4));
          end;
    $d001:begin
            mapper_nes.dreg[9]:=valor and $1f;
            set_chr_1($1000,mapper_nes.dreg[8] or (mapper_nes.dreg[9] shl 4));
          end;
    $d002:begin
            mapper_nes.dreg[10]:=valor and $f;
            set_chr_1($1400,mapper_nes.dreg[10] or (mapper_nes.dreg[11] shl 4));
          end;
    $d003:begin
            mapper_nes.dreg[11]:=valor and $1f;
            set_chr_1($1400,mapper_nes.dreg[10] or (mapper_nes.dreg[11] shl 4));
          end;
    $e000:begin
            mapper_nes.dreg[12]:=valor and $f;
            set_chr_1($1800,mapper_nes.dreg[12] or (mapper_nes.dreg[13] shl 4));
          end;
    $e001:begin
            mapper_nes.dreg[13]:=valor and $1f;
            set_chr_1($1800,mapper_nes.dreg[12] or (mapper_nes.dreg[13] shl 4));
          end;
    $e002:begin
            mapper_nes.dreg[14]:=valor and $f;
            set_chr_1($1c00,mapper_nes.dreg[14] or (mapper_nes.dreg[15] shl 4));
          end;
    $e003:begin
            mapper_nes.dreg[15]:=valor and $1f;
            set_chr_1($1c00,mapper_nes.dreg[14] or (mapper_nes.dreg[15] shl 4));
          end;
end;
end;

procedure vrc4_prg;
begin
if mapper_nes.reg[1]=0 then begin
  set_prg_8($8000,mapper_nes.reg[0]);
  set_prg_8($c000,(mapper_nes.last_prg shl 1)-2);
end else begin
  set_prg_8($c000,mapper_nes.reg[0]);
  set_prg_8($8000,(mapper_nes.last_prg shl 1)-2);
end;
end;

procedure mapper_21_write_rom(direccion:word;valor:byte);
begin
   case mapper_nes.submapper of
    0:direccion:=(direccion and $fff8) or ((direccion and 7) shr 1);
    1:direccion:=(direccion and $ff00) or ((direccion and $c0) shr 6);
    2:direccion:=(direccion and $fff0) or ((direccion and $c) shr 2);
    3:direccion:=(direccion and $fffc) or ((direccion and 1) shl 1) or ((direccion and 2) shr 1);
    4:direccion:=(direccion and $fff0) or ((direccion and 4) shr 1) or ((direccion and 8) shr 3);
   end;
  case (direccion and $f003) of
    $8000..$8003:begin
                    mapper_nes.reg[0]:=valor and $1f;
                    vrc4_prg;
                 end;
    $9000..$9001:case (valor and 3) of
                  0:ppu_nes.mirror:=MIRROR_VERTICAL;
                  1:ppu_nes.mirror:=MIRROR_HORIZONTAL;
                  2:ppu_nes.mirror:=MIRROR_LOW;
                  3:ppu_nes.mirror:=MIRROR_HIGH;
                 end;
    $9002:begin
            mapper_nes.reg[1]:=(valor shr 1) and 1;
            vrc4_prg;
          end;
    $9003:;
    $a000..$a003:set_prg_8($a000,valor and $1f);
    $b000..$efff:vrc_chr(direccion and $f003,valor);
    $f000:mapper_nes.reload_counter:=(mapper_nes.reload_counter and $f0) or (valor and $f);
    $f001:mapper_nes.reload_counter:=(mapper_nes.reload_counter and $0f) or ((valor and $f) shl 4);
    $f002:begin
            mapper_nes.latch1:=valor;
            n2a03_0.m6502.change_irq(CLEAR_LINE);
            if (valor and 2)<>0 then begin
              mapper_nes.counter:=mapper_nes.reload_counter;
              mapper_nes.needirqdelay:=0;
              mapper_nes.irq_ena:=true;
            end else mapper_nes.irq_ena:=false;
          end;
    $f003:begin
            n2a03_0.m6502.change_irq(CLEAR_LINE);
            mapper_nes.irq_ena:=(mapper_nes.latch1 and 1)<>0;
          end;
  end;
end;

procedure mapper_23_write_rom(direccion:word;valor:byte);
begin
  if mapper_nes.submapper=1 then direccion:=(direccion and $fffc) or ((direccion and 1) shl 1) or ((direccion and 2) shr 1);
  case (direccion and $f003) of
    $8000..$8003:set_prg_8($8000,valor and $1f);
    $9000..$9003:if (valor and 1)<>0 then ppu_nes.mirror:=MIRROR_HORIZONTAL
                    else ppu_nes.mirror:=MIRROR_VERTICAL;
    $a000..$a003:set_prg_8($a000,valor and $1f);
    $b000..$efff:if mapper_nes.last_chr<>0 then vrc_chr(direccion and $f003,valor);
  end;
end;

procedure mapper_32_update_prg;
begin
if (mapper_nes.reg[1] and $2)=0 then begin //prg type 0
  set_prg_8($8000,mapper_nes.reg[0]);
  set_prg_8($c000,(mapper_nes.last_prg shl 1)-2);
end else begin //prg type 1
  set_prg_8($8000,0);
  set_prg_8($c000,mapper_nes.reg[0]);
end;
end;

procedure mapper_32_write_rom(direccion:word;valor:byte);
begin
case (direccion and $f000) of
  $8000:begin //PRG 0
          mapper_nes.reg[0]:=valor and $1f;
          mapper_32_update_prg;
        end;
  $9000:if mapper_nes.submapper<>1 then begin
          mapper_nes.reg[1]:=valor and $3;
          mapper_32_update_prg;
          if (valor and $1)=0 then ppu_nes.mirror:=MIRROR_VERTICAL
            else ppu_nes.mirror:=MIRROR_HORIZONTAL;
        end;
  $a000:set_prg_8($a000,valor and $1f); //PRG 1
  $b000:set_chr_1($400*(direccion and $7),valor);
end;
end;

procedure mapper_33_write_rom(direccion:word;valor:byte);
begin
  case (direccion and $a003) of
    $8000:begin
            set_prg_8($8000,valor and $3f);
            if (valor and $40)=0 then ppu_nes.mirror:=MIRROR_VERTICAL
              else ppu_nes.mirror:=MIRROR_HORIZONTAL;
          end;
    $8001:set_prg_8($a000,valor and $3f);
    $8002:set_chr_2(0,valor);
    $8003:set_chr_2($800,valor);
    $a000:set_chr_1($1000,valor);
    $a001:set_chr_1($1400,valor);
    $a002:set_chr_1($1800,valor);
    $a003:set_chr_1($1c00,valor);
  end;
end;

procedure mapper_34_write_rom(direccion:word;valor:byte);
begin
  if direccion<$8000 then memoria[direccion]:=valor;
  case direccion of
    $7ffd:mapper_nes.reg[0]:=valor and 1;
    $7ffe:mapper_nes.reg[1]:=valor and $f;
    $7fff:mapper_nes.reg[2]:=valor and $f;
      else if (mapper_nes.last_chr=0) then mapper_nes.reg[0]:=valor and $3;
  end;
  set_prg_32(mapper_nes.reg[0]);
  if mapper_nes.last_chr<>0 then begin
    set_chr_4($0,mapper_nes.reg[1]);
    set_chr_4($1000,mapper_nes.reg[2]);
  end;
end;

procedure mapper_41_write_rom(direccion:word;valor:byte);
begin
case direccion of
  $6000..$67ff:begin
                  mapper_nes.reg[0]:=direccion and $7;
                  set_prg_32(direccion and $7);
                  if (direccion and $20)=0 then ppu_nes.mirror:=MIRROR_VERTICAL
                    else ppu_nes.mirror:=MIRROR_HORIZONTAL;
                  mapper_nes.reg[1]:=(mapper_nes.reg[1] and 3) or ((direccion shr 1) and $c);
                  set_chr_8(mapper_nes.reg[1]);
               end;
  $8000..$ffff:if mapper_nes.reg[0]>3 then begin
                  mapper_nes.reg[1]:=(mapper_nes.reg[1] and $c) or (valor and 3);
                  set_chr_8(mapper_nes.reg[1]);
               end;
end;
end;

procedure mapper_42_write_rom(direccion:word;valor:byte);
begin
case (direccion and $e003) of
  $8000:set_chr_8(valor and $f);
  $e000:set_prg_8($6000,valor and $f);
  $e001:if (valor and $8)=0 then ppu_nes.mirror:=MIRROR_VERTICAL
          else ppu_nes.mirror:=MIRROR_HORIZONTAL;
  $e002:if (valor and 2)=0 then begin
          mapper_nes.irq_ena:=false;
          n2a03_0.m6502.change_irq(CLEAR_LINE);
          mapper_nes.counter:=0;
        end else mapper_nes.irq_ena:=true;
end;
end;

procedure mapper_42_irq(estados_t:word);
begin
if mapper_nes.irq_ena then begin
  mapper_nes.counter:=mapper_nes.counter+estados_t;
  if mapper_nes.counter>=$8000 then mapper_nes.counter:=mapper_nes.counter-$8000;
  if mapper_nes.counter>=$6000 then n2a03_0.m6502.change_irq(ASSERT_LINE)
    else n2a03_0.m6502.change_irq(CLEAR_LINE);
end;
end;

procedure mapper_48_write_rom(direccion:word;valor:byte);
begin
  case (direccion and $e003) of
    $8000:set_prg_8($8000,valor and $3f);
    $8001:set_prg_8($a000,valor and $3f);
    $8002:set_chr_2(0,valor);
    $8003:set_chr_2($800,valor);
    $a000:set_chr_1($1000,valor);
    $a001:set_chr_1($1400,valor);
    $a002:set_chr_1($1800,valor);
    $a003:set_chr_1($1c00,valor);
    $c000:mapper_nes.reg[2]:=valor xor $ff; //irq reload
    $c001:begin  //irq clear
            mapper_nes.reload:=true;
            mapper_nes.reg[1]:=0;
          end;
    $c002:mapper_nes.irq_ena:=true; //irq enable
    $c003:begin  //irq enable
             mapper_nes.irq_ena:=false; //irq ack
             n2a03_0.m6502.change_irq(CLEAR_LINE);
        end;
    $e000:if (valor and $40)=0 then ppu_nes.mirror:=MIRROR_VERTICAL
              else ppu_nes.mirror:=MIRROR_HORIZONTAL;
  end;
end;

procedure mapper_57_write_rom(direccion:word;valor:byte);
begin
case (direccion and $8800) of
  $8000:mapper_nes.reg[0]:=valor;
  $8800:mapper_nes.reg[1]:=valor
end;
  if (mapper_nes.reg[1] and $10)<>0 then begin
    set_prg_32(((mapper_nes.reg[1] shr 5) and 6) shr 1);
  end else begin
    set_prg_16($8000,(mapper_nes.reg[1] shr 5) and 7);
    set_prg_16($c000,(mapper_nes.reg[1] shr 5) and 7);
  end;
  set_chr_8(((mapper_nes.reg[0] and $40) shr 3) or ((mapper_nes.reg[0] or mapper_nes.reg[1]) and $7));
  if (mapper_nes.reg[1] and $8)=0 then ppu_nes.mirror:=MIRROR_VERTICAL
    else ppu_nes.mirror:=MIRROR_HORIZONTAL;
end;

procedure mapper_58_write_rom(direccion:word;valor:byte);
begin
  if (direccion and $80)<>0 then ppu_nes.mirror:=MIRROR_HORIZONTAL
    else ppu_nes.mirror:=MIRROR_VERTICAL;
  set_chr_8((direccion shr 3) and 7);
  if (direccion and $40)<>0 then begin
    set_prg_16($8000,direccion and $7);
    set_prg_16($c000,direccion and $7);
  end else set_prg_32((direccion and 6) shr 1);
end;

procedure mapper_64_write_rom(direccion:word;valor:byte);
var
  tempw:word;
begin
case (direccion and $e001) of
  $8000:mapper_nes.latch1:=valor;
  $8001:begin
          mapper_nes.dreg[mapper_nes.latch1 and $f]:=valor;
          if (mapper_nes.latch1 and $40)<>0 then begin
            set_prg_8($8000,mapper_nes.dreg[$f]);
            set_prg_8($a000,mapper_nes.dreg[6]);
            set_prg_8($c000,mapper_nes.dreg[7]);
          end else begin
            set_prg_8($8000,mapper_nes.dreg[6]);
            set_prg_8($a000,mapper_nes.dreg[7]);
            set_prg_8($c000,mapper_nes.dreg[$f]);
          end;
          tempw:=(mapper_nes.latch1 and $80) shl 5;
          if (mapper_nes.latch1 and $20)<>0 then begin
            set_chr_1($400 xor tempw,mapper_nes.dreg[8]);
            set_chr_1($c00 xor tempw,mapper_nes.dreg[9]);
          end else begin
            set_chr_1($400 xor tempw,mapper_nes.dreg[0]+1);
            set_chr_1($c00 xor tempw,mapper_nes.dreg[1]+1);
          end;
          set_chr_1($0 xor tempw,mapper_nes.dreg[0]);
          set_chr_1($800 xor tempw,mapper_nes.dreg[1]);
          set_chr_1($1000 xor tempw,mapper_nes.dreg[2]);
          set_chr_1($1400 xor tempw,mapper_nes.dreg[3]);
          set_chr_1($1800 xor tempw,mapper_nes.dreg[4]);
          set_chr_1($1c00 xor tempw,mapper_nes.dreg[5]);
        end;
  $a000:if (valor and $1)<>0 then ppu_nes.mirror:=MIRROR_HORIZONTAL
                else ppu_nes.mirror:=MIRROR_VERTICAL;
  $c000:mapper_nes.reload_counter:=valor;
  $c001:begin //irq type
          if (mapper_nes.prg_ena and ((valor and 1)=0)) then mapper_nes.forceclock:=true;
          mapper_nes.prg_ena:=(valor and 1)<>0;
          if mapper_nes.prg_ena then mapper_nes.cpu_count:=0;
          mapper_nes.reload:=true;
        end;
  $e000:begin
          mapper_nes.irq_ena:=false;
          n2a03_0.m6502.change_irq(CLEAR_LINE);
        end;
  $e001:mapper_nes.irq_ena:=true;
end;
end;

procedure mapper_64_count(contador:byte);
begin
if mapper_nes.reload then begin
  if (mapper_nes.reload_counter<=1) then mapper_nes.counter:=mapper_nes.reload_counter+1
    else mapper_nes.counter:=mapper_nes.reload_counter+2;
  mapper_nes.reload:=false;
end else if(mapper_nes.counter=0) then mapper_nes.counter:=mapper_nes.reload_counter+1;
mapper_nes.counter:=mapper_nes.counter-1;
if((mapper_nes.counter=0) and mapper_nes.irq_ena) then mapper_nes.needirqdelay:=contador;
end;

procedure mapper_64_irq(estados_t:word);
var
  f:byte;
begin
for f:=1 to estados_t do begin
  if(mapper_nes.needirqdelay<>0) then begin
    mapper_nes.needirqdelay:=mapper_nes.needirqdelay-1;
    if (mapper_nes.needirqdelay=0) then n2a03_0.m6502.change_irq(ASSERT_LINE);
  end;
  if (mapper_nes.prg_ena or mapper_nes.forceclock) then begin
	  		mapper_nes.cpu_count:=(mapper_nes.cpu_count+1) and $3;
		  	if (mapper_nes.cpu_count=0) then begin
          mapper_64_count(1);
			  	mapper_nes.forceclock:=false;
        end;
  end;
end;
end;

procedure mapper_64_line;
begin
  if not(mapper_nes.prg_ena) then mapper_64_count(1);
end;

procedure mapper_65_write_rom(direccion:word;valor:byte);
begin
case (direccion and $f007) of
  $8000:set_prg_8($8000,valor);
  $9001:if (valor and $80)<>0 then ppu_nes.mirror:=MIRROR_HORIZONTAL
          else ppu_nes.mirror:=MIRROR_VERTICAL;
  $9003:begin
          n2a03_0.m6502.change_irq(CLEAR_LINE);
          mapper_nes.irq_ena:=(valor and $80)<>0;
        end;
  $9004:begin
          n2a03_0.m6502.change_irq(CLEAR_LINE);
          mapper_nes.counter:=mapper_nes.reload_counter;
        end;
  $9005:mapper_nes.reload_counter:=(mapper_nes.reload_counter and $ff) or (valor shl 8);
  $9006:mapper_nes.reload_counter:=(mapper_nes.reload_counter and $ff00) or valor;
  $a000:set_prg_8($a000,valor);
  $b000..$b007:set_chr_1($400*(direccion and $7),valor);
  $c000:set_prg_8($c000,valor);
end;
end;

procedure mapper_65_irq(estados_t:word);
begin
if mapper_nes.irq_ena then begin
  if mapper_nes.counter<>0 then begin
    mapper_nes.counter:=mapper_nes.counter-estados_t;
    if mapper_nes.counter<=0 then begin
        mapper_nes.counter:=0;
        n2a03_0.m6502.change_irq(ASSERT_LINE);
    end;
  end;
end;
end;

procedure mapper_66_write_rom(direccion:word;valor:byte);
begin
set_chr_8(valor and $3);
set_prg_32((valor and $30) shr 4);
end;

procedure mapper_67_write_rom(direccion:word;valor:byte);
begin
case (direccion shr 12) of
  $8:set_chr_2($0,valor);
  $9:set_chr_2($800,valor);
  $a:set_chr_2($1000,valor);
  $b:set_chr_2($1800,valor);
  //Escribe dos veces la cantidad de estados T para la IRQ
  $c:begin
      case mapper_nes.latch1 of
        0:mapper_nes.reg[0]:=valor;
        1:mapper_nes.counter:=(mapper_nes.reg[0] shl 8) or valor;
      end;
      mapper_nes.latch1:=mapper_nes.latch1 xor 1;
     end;
  $d:begin
      n2a03_0.m6502.change_irq(CLEAR_LINE);
      mapper_nes.latch1:=0;
      mapper_nes.irq_ena:=(valor and $10)<>0;
    end;
  $e:case (valor and 3) of
          0:ppu_nes.mirror:=MIRROR_VERTICAL;
          1:ppu_nes.mirror:=MIRROR_HORIZONTAL;
          2:ppu_nes.mirror:=MIRROR_LOW;
          3:ppu_nes.mirror:=MIRROR_HIGH;
        end;
  $f:set_prg_16($8000,valor);
end;
end;

procedure mapper_67_irq(estados_t:word);
begin
if mapper_nes.irq_ena then begin
  mapper_nes.counter:=mapper_nes.counter-estados_t;
  if (mapper_nes.counter<0) then begin
    n2a03_0.m6502.change_irq(ASSERT_LINE);
    mapper_nes.irq_ena:=false;
  end;
end;
end;

procedure mapper_68_write_rom(direccion:word;valor:byte);
var
  tempb:byte;
begin
case ((direccion shr 12) and $f) of
  $8:set_chr_2($0,valor);
  $9:set_chr_2($800,valor);
  $a:set_chr_2($1000,valor);
  $b:set_chr_2($1800,valor);
  $c:if mapper_nes.chr_extra_ena then begin
        tempb:=($80 or (valor and $7f)) mod (mapper_nes.last_chr shl 3);
        copymemory(@ppu_nes.name_table[0,0],@mapper_nes.chr[tempb shr 3,$400*(tempb and 7)],$400);
     end;
  $d:if mapper_nes.chr_extra_ena then begin
        tempb:=($80 or (valor and $7f)) mod (mapper_nes.last_chr shl 3);
        copymemory(@ppu_nes.name_table[1,0],@mapper_nes.chr[tempb shr 3,$400*(tempb and 7)],$400);
     end;
  $e:begin
        case (valor and 3) of
          0:ppu_nes.mirror:=MIRROR_VERTICAL;
          1:ppu_nes.mirror:=MIRROR_HORIZONTAL;
          2,3:ppu_nes.mirror:=MIRROR_LOW;
        end;
        mapper_nes.chr_extra_ena:=(valor and $10)<>0;
     end;
  $f:begin
        set_prg_16($8000,valor and $f);
        mapper_nes.prg_ram_enable:=(valor and $10)<>0;
     end;
end;
end;

procedure mapper_69_write_rom(direccion:word;valor:byte);
begin
case (direccion and $e000) of
  $8000:mapper_nes.latch1:=valor and $f;
  $a000:begin
          case (mapper_nes.latch1 and $f) of
            0:set_chr_1(0,valor);
            1:set_chr_1($400,valor);
            2:set_chr_1($800,valor);
            3:set_chr_1($c00,valor);
            4:set_chr_1($1000,valor);
            5:set_chr_1($1400,valor);
            6:set_chr_1($1800,valor);
            7:set_chr_1($1c00,valor);
            8:begin
                if (valor and $40)=0 then set_prg_8($6000,valor and $3f);
                mapper_nes.latch0:=valor;
              end;
            9:set_prg_8($8000,valor);
            $a:set_prg_8($a000,valor);
            $b:set_prg_8($c000,valor);
            $c:case (valor and $3) of
                0:ppu_nes.mirror:=MIRROR_VERTICAL;
                1:ppu_nes.mirror:=MIRROR_HORIZONTAL;
                2:ppu_nes.mirror:=MIRROR_LOW;
                3:ppu_nes.mirror:=MIRROR_HIGH;
               end;
            $d:begin
                mapper_nes.irq_ena:=(valor and 1)<>0;
                mapper_nes.reload:=(valor and $80)<>0;
               end;
            $e:mapper_nes.reload_counter:=(mapper_nes.reload_counter and $ff00) or valor;
            $f:mapper_nes.reload_counter:=(mapper_nes.reload_counter and $ff) or (valor shl 8);
          end;
        end;
  $c000:ay8910_0.Control(valor and $f);
  $e000:ay8910_0.Write(valor);
end;
end;

procedure mapper_69_irq(estados_t:word);
begin
if mapper_nes.reload then begin
  mapper_nes.reload_counter:=mapper_nes.reload_counter-estados_t;
  if mapper_nes.reload_counter<0 then begin
    mapper_nes.reload_counter:=mapper_nes.reload_counter+$ffff;
    if mapper_nes.irq_ena then n2a03_0.m6502.change_irq(HOLD_LINE);
  end;
end;
end;

function mapper_69_read_prg_ram(direccion:word):byte;
begin
if (mapper_nes.latch0 and $40)<>0 then begin
  if (mapper_nes.latch0 and $80)<>0 then mapper_69_read_prg_ram:=mapper_nes.prg_ram[mapper_nes.latch0 and $3f,direccion and $1fff]
    else mapper_69_read_prg_ram:=ppu_nes.open_bus;
end else mapper_69_read_prg_ram:=memoria[direccion];
end;

procedure mapper_69_write_prg_ram(direccion:word;valor:byte);
begin
if ((mapper_nes.latch0 and $c0)=$c0) then mapper_nes.prg_ram[mapper_nes.latch0 and $3f,direccion and $1fff]:=valor;
end;

procedure mapper_69_update_sound;
begin
  AY8910_0.update;
end;

procedure mapper_70_write_rom(direccion:word;valor:byte);
begin
set_chr_8(valor and $f);
set_prg_16($8000,(valor and $f0) shr 4);
end;

procedure mapper_71_write_rom(direccion:word;valor:byte);
begin
case direccion of
  $9000..$9fff:if (valor and $10)<>0 then ppu_nes.mirror:=MIRROR_HIGH
                  else ppu_nes.mirror:=MIRROR_LOW;
  $c000..$ffff:set_prg_16($8000,valor and $f);
end;
end;

procedure mapper_73_write_rom(direccion:word;valor:byte);
begin
case (direccion shr 12) of
  $8:mapper_nes.reload_counter:=(mapper_nes.reload_counter and $fff0) or (valor and $f);
  $9:mapper_nes.reload_counter:=(mapper_nes.reload_counter and $ff0f) or ((valor and $f) shl 4);
  $a:mapper_nes.reload_counter:=(mapper_nes.reload_counter and $f0ff) or ((valor and $f) shl 8);
  $b:mapper_nes.reload_counter:=(mapper_nes.reload_counter and $0fff) or ((valor and $f) shl 12);
  $c:begin
      mapper_nes.latch1:=valor;
      n2a03_0.m6502.change_irq(CLEAR_LINE);
      if (valor and 2)<>0 then begin
        mapper_nes.counter:=mapper_nes.reload_counter;
        mapper_nes.irq_ena:=true;
      end else mapper_nes.irq_ena:=false;
     end;
  $d:begin
      n2a03_0.m6502.change_irq(CLEAR_LINE);
      mapper_nes.irq_ena:=(mapper_nes.latch1 and 1)<>0;
    end;
  $f:set_prg_16($8000,valor);
end;
end;

procedure mapper_73_irq(estados_t:word);
var
  tempw:word;
begin
if mapper_nes.irq_ena then begin
  if (mapper_nes.latch1 and 4)<>0 then begin
    tempw:=(mapper_nes.counter and $ff)+estados_t;
    if (tempw>$ff) then begin
      n2a03_0.m6502.change_irq(ASSERT_LINE);
      mapper_nes.counter:=(mapper_nes.counter and $ff00) or (mapper_nes.reload_counter and $ff);
    end else mapper_nes.counter:=(mapper_nes.counter and $ff00) or tempw;
  end else begin
    mapper_nes.counter:=mapper_nes.counter+estados_t;
    if (mapper_nes.counter>$ffff) then begin
      n2a03_0.m6502.change_irq(ASSERT_LINE);
      mapper_nes.counter:=mapper_nes.reload_counter;
    end;
  end;
end;
end;

procedure mapper_75_write_rom(direccion:word;valor:byte);
begin
case (direccion shr 12) of
  $8:set_prg_8($8000,valor and $f);
  $9:begin
      if (valor and $1)<>0 then ppu_nes.mirror:=MIRROR_HORIZONTAL
        else ppu_nes.mirror:=MIRROR_VERTICAL;
      mapper_nes.reg[0]:=(mapper_nes.reg[0] and $f) or ((valor and 2) shl 3);
      mapper_nes.reg[1]:=(mapper_nes.reg[1] and $f) or ((valor and 4) shl 2);
      set_chr_4($0,mapper_nes.reg[0]);
      set_chr_4($1000,mapper_nes.reg[1]);
     end;
  $a:set_prg_8($a000,valor and $f);
  $c:set_prg_8($c000,valor and $f);
  $e:begin
      mapper_nes.reg[0]:=(mapper_nes.reg[0] and $10) or (valor and $f);
      set_chr_4($0,mapper_nes.reg[0]);
     end;
  $f:begin
      mapper_nes.reg[1]:=(mapper_nes.reg[1] and $10) or (valor and $f);
      set_chr_4($1000,mapper_nes.reg[1]);
     end;
end;
end;

procedure mapper_76_write_rom(direccion:word;valor:byte);
begin
direccion:=direccion and $8001;
case direccion of
  $8000:mapper_nes.reg[0]:=valor and 7;
  $8001:case mapper_nes.reg[0] of
          2:set_chr_2($0,valor and $3f);
          3:set_chr_2($800,valor and $3f);
          4:set_chr_2($1000,valor and $3f);
          5:set_chr_2($1800,valor and $3f);
          6:set_prg_8($8000,valor and $3f);
          7:set_prg_8($a000,valor and $3f);
        end;
end;
end;

procedure mapper_79_write_rom(direccion:word;valor:byte);
begin
if (direccion and $e100)=$4100 then begin
  set_prg_32((valor shr 3) and 1);
  set_chr_8(valor and $7);
end;
end;

procedure mapper_85_write_rom(direccion:word;valor:byte);
begin
  if mapper_nes.submapper=1 then direccion:=(direccion and $ffe7) or ((direccion and 8) shl 1) or ((direccion and $10) shr 1);
  case (direccion and $f038) of
    $8000:set_prg_8($8000,valor and $3f);
    $8010:set_prg_8($a000,valor and $3f);
    $9000:set_prg_8($c000,valor and $3f);
    $9010,$9030:; //FM chip
    $a000:if mapper_nes.last_chr<>0 then set_chr_1($0,valor);
    $a010:if mapper_nes.last_chr<>0 then set_chr_1($400,valor);
    $b000:if mapper_nes.last_chr<>0 then set_chr_1($800,valor);
    $b010:if mapper_nes.last_chr<>0 then set_chr_1($c00,valor);
    $c000:if mapper_nes.last_chr<>0 then set_chr_1($1000,valor);
    $c010:if mapper_nes.last_chr<>0 then set_chr_1($1400,valor);
    $d000:if mapper_nes.last_chr<>0 then set_chr_1($1800,valor);
    $d010:if mapper_nes.last_chr<>0 then set_chr_1($1c00,valor);
    $e000:begin
            case (valor and 3) of
               0:ppu_nes.mirror:=MIRROR_VERTICAL;
               1:ppu_nes.mirror:=MIRROR_HORIZONTAL;
               2:ppu_nes.mirror:=MIRROR_LOW;
               3:ppu_nes.mirror:=MIRROR_HIGH;
            end;
            mapper_nes.prg_ram_writeble:=(valor and $80)<>0;
          end;
    $e010:mapper_nes.reload_counter:=valor;
    $f000:begin
            mapper_nes.latch1:=valor;
            n2a03_0.m6502.change_irq(CLEAR_LINE);
            if (valor and 2)<>0 then begin
              mapper_nes.counter:=mapper_nes.reload_counter;
              mapper_nes.needirqdelay:=0;
              mapper_nes.irq_ena:=true;
            end else mapper_nes.irq_ena:=false;
          end;
    $f010:begin
            n2a03_0.m6502.change_irq(CLEAR_LINE);
            mapper_nes.irq_ena:=(mapper_nes.latch1 and 1)<>0;
          end;
  end;
end;

procedure mapper_87_write_rom(direccion:word;valor:byte);
begin
valor:=(valor shr 1) or ((valor and 1) shl 1);
set_chr_8(valor);
end;

procedure mapper_88_write_rom(direccion:word;valor:byte);
begin
direccion:=direccion and $8001;
case direccion of
  $8000:mapper_nes.reg[0]:=valor;
  $8001:case (mapper_nes.reg[0] and $7) of
          0:set_chr_2(0,(valor shr 1) and $3f);
          1:set_chr_2($800,(valor shr 1) and $3f);
          2:set_chr_1($1000,valor or $40);
          3:set_chr_1($1400,valor or $40);
          4:set_chr_1($1800,valor or $40);
          5:set_chr_1($1c00,valor or $40);
          6:set_prg_8($8000,valor and $f);
          7:set_prg_8($a000,valor and $f);
        end;
end;
end;

procedure mapper_89_write_rom(direccion:word;valor:byte);
begin
set_prg_16($8000,(valor shr 4) and $7);
set_chr_8(((valor and $80) shr 4) or (valor and $7));
if (valor and $8)<>0 then ppu_nes.mirror:=MIRROR_HIGH
  else ppu_nes.mirror:=MIRROR_LOW;
end;

procedure mapper_93_write_rom(direccion:word;valor:byte);
begin
set_prg_16($8000,(valor and $70) shr 4);
ppu_nes.write_chr:=(valor and 1)<>0;
end;

procedure mapper_94_write_rom(direccion:word;valor:byte);
begin
set_prg_16($8000,(valor shr 2) and $7);
end;

procedure mapper_95_nametable;
var
  tempb:byte;
begin
  tempb:=mapper_nes.reg[1]+(mapper_nes.reg[2] shl 1);
  case tempb of
    0:ppu_nes.mirror:=MIRROR_LOW;
    1:ppu_nes.mirror:=MIRROR_HORIZONTAL;
    2:ppu_nes.mirror:=MIRROR_MAP95;
    3:ppu_nes.mirror:=MIRROR_HIGH;
  end;
end;

procedure mapper_95_write_rom(direccion:word;valor:byte);
begin
direccion:=direccion and $8001;
case direccion of
  $8000:mapper_nes.reg[0]:=valor and 7;
  $8001:case mapper_nes.reg[0] of
          0:begin
              set_chr_2($0,(valor shr 1) and $1f);
              mapper_nes.reg[1]:=(valor shr 5) and 1;
              mapper_95_nametable;
            end;
          1:begin
              set_chr_2($800,(valor shr 1) and $1f);
              mapper_nes.reg[2]:=(valor shr 5) and 1;
              mapper_95_nametable;
            end;
          2:set_chr_1($1000,valor and $3f);
          3:set_chr_1($1400,valor and $3f);
          4:set_chr_1($1800,valor and $3f);
          5:set_chr_1($1c00,valor and $3f);
          6:set_prg_8($8000,valor and $f);
          7:set_prg_8($a000,valor and $f);
        end;
end;
end;

procedure mapper_105_write_rom(direccion:word;valor:byte);
begin
if (valor and $80)<>0 then begin
  //Reset!!
  mapper_nes.serial_cnt:=0;
  mapper_nes.valor_map:=0;
  mapper_nes.reg[0]:=mapper_nes.reg[0] or $c;
  mapper_nes.counter:=0;
  set_prg_32(0);
end else begin
  mapper_nes.valor_map:=mapper_nes.valor_map or ((valor and 1) shl mapper_nes.serial_cnt);
  mapper_nes.serial_cnt:=mapper_nes.serial_cnt+1;
  mapper_nes.counter:=0;
  if mapper_nes.serial_cnt=5 then begin
    mapper_nes.reg[(direccion shr 13) and 3]:=mapper_nes.valor_map;
    case (mapper_nes.reg[0] and 3) of //Mirror
      0:ppu_nes.mirror:=MIRROR_LOW;
      1:ppu_nes.mirror:=MIRROR_HIGH;
      2:ppu_nes.mirror:=MIRROR_VERTICAL;
      3:ppu_nes.mirror:=MIRROR_HORIZONTAL;
    end;
    if (mapper_nes.reg[1] and $10)=0 then begin
      mapper_nes.irq_ena:=true;
      if mapper_nes.latch1=$ff then mapper_nes.latch1:=$fe;
    end else begin
      mapper_nes.counter:=0;
      n2a03_0.m6502.change_irq(CLEAR_LINE);
      mapper_nes.irq_ena:=false;
      if mapper_nes.latch1=$fe then begin
        mapper_nes.prg_ena:=true;
        mapper_nes.latch1:=$fd;
      end;
    end;
    if mapper_nes.prg_ena then mapper_1_prg;
    mapper_nes.valor_map:=0;
    mapper_nes.serial_cnt:=0;
  end;
end;
end;

procedure mapper_105_irq(estados_t:word);
begin
if mapper_nes.irq_ena then begin
  mapper_nes.counter:=mapper_nes.counter+estados_t;
  if (mapper_nes.counter>=$2800000) then n2a03_0.m6502.change_irq(ASSERT_LINE);
end;
end;

procedure mapper_113_write_rom(direccion:word;valor:byte);
begin
if (direccion and $e100)=$4100 then begin
  if (valor and $80)<>0 then ppu_nes.mirror:=MIRROR_HORIZONTAL
    else ppu_nes.mirror:=MIRROR_VERTICAL;
  set_prg_32((valor shr 3) and 7);
  set_chr_8((valor and 7) or ((valor shr 3) and 8));
end;
end;

procedure mapper_116_write_rom(direccion:word;valor:byte);
begin
if (direccion<$8000) then begin
  if (direccion and $c100)=$4100 then begin
    mapper_nes.mode:=valor and 3;
    n2a03_0.m6502.change_despues_instruccion(nil);
    llamadas_nes.line_ack:=nil;
    case (valor and 3) of
      0:begin  //vrc2-b
          set_prg_16($8000,0);
          set_prg_16($c000,mapper_nes.last_prg-1);
          mapper_nes.prg_ram_enable:=true;
        end;
      1:begin //mapper 4
          llamadas_nes.line_ack:=mapper_4_line;
          mapper_nes.irq_ena:=false;
          mapper_nes.dreg[1]:=2;
          mapper_nes.dreg[2]:=4;
          mapper_nes.dreg[3]:=5;
          mapper_nes.dreg[4]:=6;
          mapper_nes.dreg[5]:=7;
          mapper_nes.dreg[7]:=1;
          mapper_4_update_chr(0);
          mapper_4_update_prg(0);
          set_prg_16($8000,mapper_nes.last_prg-1);
          set_prg_16($c000,mapper_nes.last_prg-1);
        end;
      2,3:begin
            n2a03_0.m6502.change_despues_instruccion(mapper_1_delay); //mapper 1
            mapper_nes.serial_cnt:=0;
            mapper_nes.prg_ram_enable:=true;
            mapper_nes.reg[0]:=$c;
            set_prg_16($8000,0);
            set_prg_16($c000,mapper_nes.last_prg-1);
          end;
    end;
  end;
end else case mapper_nes.mode of
          0:mapper_23_write_rom(direccion,valor);
          1:mapper_4_write_rom(direccion,valor);
          2,3:mapper_1_write_rom(direccion,valor);
         end;
end;

procedure mapper_132_write_rom(direccion:word;valor:byte);
begin
case (direccion and $8000) of
  $8000:begin
          set_prg_32(mapper_nes.reg[3] shr 2);
          set_chr_8(mapper_nes.reg[3] and $3);
        end;
end;
end;

function mapper_132_read_exp(direccion:word):byte;
begin
case (direccion and $e100) of
  $4100:mapper_132_read_exp:=(ppu_nes.open_bus and $f0) or ((mapper_nes.reg[1] and 8) xor (mapper_nes.reg[0] shl 3)) or mapper_nes.reg[3];
end;
end;

procedure mapper_132_write_exp(direccion:word;valor:byte);
begin
case (direccion and $e103) of
  $4100:if mapper_nes.reg[2]<>0 then mapper_nes.reg[3]:=(mapper_nes.reg[3]+1) and $7
          else begin
              if mapper_nes.reg[0]<>0 then mapper_nes.reg[3]:=(not(mapper_nes.reg[1] and $7)) and $7
                else mapper_nes.reg[3]:=mapper_nes.reg[1] and $7;
          end;
  $4101:mapper_nes.reg[0]:=valor and 1;
  $4102:mapper_nes.reg[1]:=valor and $f;
  $4103:mapper_nes.reg[2]:=valor and 1;
end;
end;

procedure mapper_133_write_rom(direccion:word;valor:byte);
begin
  case (direccion and $e100) of
    $4100:begin
            set_prg_32((valor and 4) shr 2);
            set_chr_8(valor and $3);
          end;
  end;
end;

procedure mapper_137_write_rom(direccion:word;valor:byte);
begin
case (direccion and $c101) of
  $4100:mapper_nes.latch1:=valor and 7;
  $4101:begin
          mapper_nes.dreg[mapper_nes.latch1]:=valor and 7;
          mapper_nes.reload:=(mapper_nes.dreg[7] and 1)<>0;
          set_chr_1(0,mapper_nes.dreg[0]);
          if mapper_nes.reload then begin
              set_chr_1($400,mapper_nes.dreg[0] or ((mapper_nes.dreg[4] and 1) shl 4));
              set_chr_1($800,mapper_nes.dreg[0] or ((mapper_nes.dreg[4] and 2) shl 3));
              set_chr_1($c00,mapper_nes.dreg[0] or ((mapper_nes.dreg[4] and 4) shl 2) or ((mapper_nes.dreg[6] and 1) shl 3));
          end else begin
              set_chr_1($400,mapper_nes.dreg[1] or ((mapper_nes.dreg[4] and 1) shl 4));
              set_chr_1($800,mapper_nes.dreg[2] or ((mapper_nes.dreg[4] and 2) shl 3));
              set_chr_1($c00,mapper_nes.dreg[3] or ((mapper_nes.dreg[4] and 4) shl 2) or ((mapper_nes.dreg[6] and 1) shl 3));
          end;
          set_prg_32(mapper_nes.dreg[5]);
          if mapper_nes.reload then begin
              ppu_nes.mirror:=MIRROR_HORIZONTAL;
          end else case ((mapper_nes.dreg[7] shr 1) and 3) of
              0:ppu_nes.mirror:=MIRROR_HORIZONTAL;
              1:ppu_nes.mirror:=MIRROR_VERTICAL;
              2:ppu_nes.mirror:=MIRROR_MAP139;
              3:ppu_nes.mirror:=MIRROR_LOW;
          end;
        end;
end;
end;

procedure mapper_139_write_rom(direccion:word;valor:byte);
var
  tempb:byte;
begin
case (direccion and $c101) of
  $4100:mapper_nes.latch1:=valor and 7;
  $4101:begin
          mapper_nes.dreg[mapper_nes.latch1]:=valor and 7;
          mapper_nes.reload:=(mapper_nes.dreg[7] and 1)<>0;
          tempb:=mapper_nes.dreg[4] shl 3;
          if mapper_nes.reload then set_chr_8(mapper_nes.dreg[0] or tempb)
            else begin
                set_chr_2(0,(mapper_nes.dreg[0] or tempb) shl mapper_nes.shift);
                set_chr_2($800,((mapper_nes.dreg[1] or tempb) shl mapper_nes.shift) or mapper_nes.reg[0]);
                set_chr_2($1000,((mapper_nes.dreg[2] or tempb) shl mapper_nes.shift) or mapper_nes.reg[1]);
                set_chr_2($1800,((mapper_nes.dreg[3] or tempb) shl mapper_nes.shift) or mapper_nes.reg[2]);
            end;
          set_prg_32(mapper_nes.dreg[5]);
          case ((mapper_nes.dreg[7] shr 1) and 3) of
                  0:ppu_nes.mirror:=MIRROR_VERTICAL;
                  1:ppu_nes.mirror:=MIRROR_HORIZONTAL;
                  2:ppu_nes.mirror:=MIRROR_MAP139;
                  3:ppu_nes.mirror:=MIRROR_LOW;
          end;
        end;
end;
end;

procedure mapper_142_write_rom(direccion:word;valor:byte);
var
  tempb:byte;
begin
case (direccion shr 12) of
  $8:mapper_nes.reload_counter:=(mapper_nes.reload_counter and $fff0) or (valor and $f);
  $9:mapper_nes.reload_counter:=(mapper_nes.reload_counter and $ff0f) or ((valor and $f) shl 4);
  $a:mapper_nes.reload_counter:=(mapper_nes.reload_counter and $f0ff) or ((valor and $f) shl 8);
  $b:mapper_nes.reload_counter:=(mapper_nes.reload_counter and $0fff) or ((valor and $f) shl 12);
  $c:begin
      n2a03_0.m6502.change_irq(CLEAR_LINE);
      if (valor<>0) then begin
        mapper_nes.counter:=mapper_nes.reload_counter;
        mapper_nes.irq_ena:=true;
      end else mapper_nes.irq_ena:=false;
     end;
  $d:n2a03_0.m6502.change_irq(CLEAR_LINE);
  $e:mapper_nes.latch1:=(valor and $f)-1;
  $f:begin
      if (mapper_nes.latch1<3) then mapper_nes.dreg[mapper_nes.latch1]:=(mapper_nes.dreg[mapper_nes.latch1 and $10]) or (valor and $f)
        else if (mapper_nes.latch1<4) then begin
          mapper_nes.dreg[mapper_nes.latch1]:=valor;
          set_prg_8($6000,valor);
        end;
      case (direccion and $fc00) of
        $f000:begin
                tempb:=direccion and 3;
                if (tempb<3) then mapper_nes.dreg[tempb]:=(valor and $10) or (mapper_nes.dreg[tempb] and $f);
              end;
        $f800:if (valor and $1)<>0 then ppu_nes.mirror:=MIRROR_VERTICAL
                else ppu_nes.mirror:=MIRROR_HORIZONTAL;
        $fc00:set_chr_1((direccion and 7)*$400,valor);
      end;
      set_prg_8($8000,mapper_nes.dreg[0]);
      set_prg_8($a000,mapper_nes.dreg[1]);
      set_prg_8($c000,mapper_nes.dreg[2]);
     end;
end;
end;

procedure mapper_142_irq(estados_t:word);
begin
if mapper_nes.irq_ena then begin
    mapper_nes.counter:=mapper_nes.counter+estados_t;
    if (mapper_nes.counter>$ffff) then begin
      n2a03_0.m6502.change_irq(ASSERT_LINE);
      mapper_nes.counter:=mapper_nes.reload_counter;
    end;
end;
end;

function mapper_143_read_rom(direccion:word):byte;
begin
if (direccion and $100)<>0 then mapper_143_read_rom:=(not(direccion) and $3f) or (ppu_nes.open_bus and $c0)
  else mapper_143_read_rom:=0;
end;

procedure mapper_145_write_rom(direccion:word;valor:byte);
begin
if (direccion and $e100)=$4100 then set_chr_8((valor shr 7) and 1);
end;

procedure mapper_147_write_rom(direccion:word;valor:byte);
begin
if (direccion and $103)=$102 then begin
  set_prg_32(((valor shr 2) and 1) or ((valor and $80) shr 6));
  set_chr_8((valor shr 3) and $f);
end;
end;

procedure mapper_148_write_rom(direccion:word;valor:byte);
begin
set_prg_32((valor shr 3) and 1);
set_chr_8(valor and $7);
end;

procedure mapper_149_write_rom(direccion:word;valor:byte);
begin
set_chr_8((valor shr 7) and 1);
end;

function mapper_150_read_rom(direccion:word):byte;
begin
  if (direccion and $c101)=$4101 then mapper_150_read_rom:=mapper_nes.dreg[mapper_nes.latch1];
end;

procedure mapper_150_write_rom(direccion:word;valor:byte);
begin
case (direccion and $c101) of
  $4100:mapper_nes.latch1:=valor;
  $4101:begin
          mapper_nes.dreg[mapper_nes.latch1]:=valor;
          set_chr_8(((mapper_nes.dreg[4] and 1) shl 2) or (mapper_nes.dreg[6] and 3));
          if mapper_nes.latch1=2 then set_prg_32(mapper_nes.dreg[2] and $1)
            else set_prg_32(mapper_nes.dreg[5] and $3);
          case ((mapper_nes.dreg[7] shr 1) and 3) of
                0:ppu_nes.mirror:=MIRROR_MAP243;
                1:ppu_nes.mirror:=MIRROR_HORIZONTAL;
                2:ppu_nes.mirror:=MIRROR_VERTICAL;
                3:ppu_nes.mirror:=MIRROR_HIGH;
              end;
          end;
end;
end;

procedure mapper_152_write_rom(direccion:word;valor:byte);
begin
if (valor and $80)=0 then ppu_nes.mirror:=MIRROR_LOW
  else ppu_nes.mirror:=MIRROR_HIGH;
set_chr_8(valor and $f);
set_prg_16($8000,(valor shr 4) and 7);
end;

procedure mapper_154_write_rom(direccion:word;valor:byte);
begin
direccion:=direccion and $8001;
case direccion of
  $8000:begin
          mapper_nes.reg[0]:=valor;
          if (valor and $40)<>0 then ppu_nes.mirror:=MIRROR_HIGH
            else ppu_nes.mirror:=MIRROR_LOW;
        end;
  $8001:case (mapper_nes.reg[0] and $7) of
          0:set_chr_2(0,(valor shr 1) and $3f);
          1:set_chr_2($800,(valor shr 1) and $3f);
          2:set_chr_1($1000,valor or $40);
          3:set_chr_1($1400,valor or $40);
          4:set_chr_1($1800,valor or $40);
          5:set_chr_1($1c00,valor or $40);
          6:set_prg_8($8000,valor and $f);
          7:set_prg_8($a000,valor and $f);
        end;
end;
end;

function mapper_172_read(direccion:word):byte;
begin
  mapper_172_read:=(mapper_nes.reg[1] xor mapper_nes.reg[2]) or $40;
end;

procedure mapper_172_write_rom(direccion:word;valor:byte);
begin
case (direccion and $e103) of
  $4100..$4103:mapper_nes.reg[direccion and $3]:=valor;
  $8000..$ffff:begin
                  if ((mapper_nes.dreg[1] and $20)=0) then ppu_nes.mirror:=MIRROR_HORIZONTAL
                    else ppu_nes.mirror:=MIRROR_VERTICAL;
                  set_prg_32((mapper_nes.reg[2] shr 2) and $f);
                  set_chr_8((((valor xor mapper_nes.reg[2]) shr 3) and $02) or (((valor xor mapper_nes.reg[2]) shr 5) and $01));
               end;
end;
end;

procedure mapper_173_write_rom(direccion:word;valor:byte);
begin
case (direccion and $8000) of
  $8000:begin
          set_prg_32(mapper_nes.reg[3] shr 2);
          set_chr_8((mapper_nes.reg[3] and $1) or (not(mapper_nes.reg[0]) shl 1));
        end;
end;
end;

procedure mapper_180_write_rom(direccion:word;valor:byte);
begin
set_prg_16($c000,valor and $7);
end;

procedure mapper_184_write_rom(direccion:word;valor:byte);
begin
set_chr_4(0,valor and $7);
set_chr_4($1000,4 or ((valor shr 4) and $7));
end;

procedure mapper_185_write_rom(direccion:word;valor:byte);
begin
ppu_nes.disable_chr:=true;
if ((((valor and $f)<>0) and (valor<>$13)) or (mapper_nes.latch1=$21)) then begin
      if not((valor=$21) and (mapper_nes.latch1<>$13)) then begin
        ppu_nes.disable_chr:=false;
        set_chr_8(valor and $3);
      end;
end;
mapper_nes.latch1:=valor;
end;

procedure mapper_206_write_rom(direccion:word;valor:byte);
begin
direccion:=direccion and $8001;
case direccion of
  $8000:mapper_nes.reg[0]:=valor and 7;
  $8001:case mapper_nes.reg[0] of
          0:set_chr_2(0,(valor shr 1) and $1f);
          1:set_chr_2($800,(valor shr 1) and $1f);
          2:set_chr_1($1000,valor and $3f);
          3:set_chr_1($1400,valor and $3f);
          4:set_chr_1($1800,valor and $3f);
          5:set_chr_1($1c00,valor and $3f);
          6:set_prg_8($8000,valor and $f);
          7:set_prg_8($a000,valor and $f);
        end;
end;
end;

procedure mapper_212_write_rom(direccion:word;valor:byte);
begin
  set_chr_8(direccion and $7);
  if (direccion and $8)<>0 then ppu_nes.mirror:=MIRROR_HORIZONTAL
    else ppu_nes.mirror:=MIRROR_VERTICAL;
  if (direccion and $4000)<>0 then set_prg_32((direccion and $6) shr 1)
    else begin
      set_prg_16($8000,direccion and $7);
      set_prg_16($c000,direccion and $7);
    end;
end;

function mapper_212_read_exp(direccion:word):byte;
begin
  if (direccion and $e010)=$6000 then mapper_212_read_exp:=$80 or ppu_nes.open_bus;
end;

procedure update_221;
var
  tempb,tempb2:byte;
begin
  if (mapper_nes.reg[0] and 1)=0 then begin
    tempb:=mapper_nes.reg[1];
    tempb2:=mapper_nes.reg[1];
  end else begin
    if (mapper_nes.reg[0] and $80)<>0 then begin
      tempb:=mapper_nes.reg[1];
      tempb2:=$7;
    end else begin
      tempb:=(mapper_nes.reg[1] and $6) or 0;
      tempb2:=(mapper_nes.reg[1] and $6) or 1;
    end;
  end;
	set_prg_16($8000,tempb or ((mapper_nes.reg[0] and $70) shr 1));
	set_prg_16($c000,tempb2 or ((mapper_nes.reg[0] and $70) shr 1));
end;

procedure mapper_221_write_rom(direccion:word;valor:byte);
begin
case direccion of
  $8000..$bfff:begin
                  if (direccion and $1)<>0 then ppu_nes.mirror:=MIRROR_HORIZONTAL
                      else ppu_nes.mirror:=MIRROR_VERTICAL;
                  mapper_nes.reg[0]:=(direccion shr 1) and $ff;
               end;
  $c000..$ffff:begin
                 mapper_nes.reg[1]:=direccion and 7;
                 ppu_nes.write_chr:=(direccion and $8)=0;
               end;
end;
update_221;
end;

procedure mapper_243_write_rom(direccion:word;valor:byte);
begin
case (direccion and $c101) of
  $4100:mapper_nes.latch1:=valor and 7;
  $4101:begin
          mapper_nes.dreg[mapper_nes.latch1]:=valor;
          case mapper_nes.latch1 of
            0,1,3:;
            2,4,6:set_chr_8(((mapper_nes.dreg[2] and 1) shl 3) or (mapper_nes.dreg[4] and 1) or ((mapper_nes.dreg[6] and 3) shl 1));
            5:set_prg_32(valor);
            7:case ((valor shr 1) and 3) of
                0:ppu_nes.mirror:=MIRROR_MAP243;
                1:ppu_nes.mirror:=MIRROR_HORIZONTAL;
                2:ppu_nes.mirror:=MIRROR_VERTICAL;
                3:ppu_nes.mirror:=MIRROR_HIGH;
              end;
          end;
        end;
end;
end;

procedure mapper_vrc_irq(estados_t:word);
procedure clock_irq(estados:byte);
begin
  mapper_nes.counter:=mapper_nes.counter+estados;
  if (mapper_nes.counter>$ff) then begin
    n2a03_0.m6502.change_irq(ASSERT_LINE);
    mapper_nes.counter:=mapper_nes.reload_counter;
  end;
end;
begin
if mapper_nes.irq_ena then begin
  if (mapper_nes.latch1 and 4)=0 then begin
    mapper_nes.needirqdelay:=mapper_nes.needirqdelay+(estados_t*3);
    if (mapper_nes.needirqdelay>341) then begin
      mapper_nes.needirqdelay:=mapper_nes.needirqdelay-341;
      clock_irq(1);
    end;
  end else begin
    clock_irq(estados_t);
  end;
end;
end;


procedure mapper_reset;
begin
  mapper_nes.prg_ram_writeble:=false;
  mapper_nes.prg_ram_enable:=false;
  mapper_nes.latch0:=0;
  mapper_nes.latch1:=0;
  mapper_nes.reload:=false;
  mapper_nes.counter:=0;
  mapper_nes.irq_ena:=false;
  mapper_nes.reload_counter:=0;
  mapper_nes.serial_cnt:=0;
  fillchar(mapper_nes.reg,4,0);
  fillchar(mapper_nes.dreg,16,0);
  fillchar(mapper_nes.mm5.regs,$31,0);
  mapper_nes.chr_map[0]:=0;
  mapper_nes.chr_map[1]:=1;
  mapper_nes.forceclock:=false;
  mapper_nes.needirqdelay:=0;
  mapper_nes.cpu_count:=0;
  mapper_nes.shift:=0;
  case mapper_nes.mapper of
    1:begin
          mapper_nes.prg_ram_writeble:=true;
          mapper_nes.reg[0]:=$c;
          set_prg_16($8000,0);
          set_prg_16($c000,mapper_nes.last_prg-1);
      end;
    2,33,48,57,64,65,67,70,76,79,88,89,93,94,95,146,152,154,180,206:begin
          set_prg_16($8000,0);
          set_prg_16($c000,mapper_nes.last_prg-1);
      end;
    4,12:begin
          mapper_nes.prg_ram_writeble:=true;
          mapper_nes.prg_ram_enable:=true;
          mapper_nes.dreg[1]:=2;
          mapper_nes.dreg[2]:=4;
          mapper_nes.dreg[3]:=5;
          mapper_nes.dreg[4]:=6;
          mapper_nes.dreg[5]:=7;
          mapper_nes.dreg[7]:=1;
          mapper_4_update_chr(0);
          mapper_4_update_prg(0);
          set_prg_16($8000,mapper_nes.last_prg-1);
          set_prg_16($c000,mapper_nes.last_prg-1);
      end;
    5:begin
        mapper_nes.mm5.regs[0]:=3;
        mapper_nes.mm5.regs[$17]:=$ff;
        set_prg_16($8000,mapper_nes.last_prg-2);
        set_prg_16($c000,mapper_nes.last_prg-1);
        mapper_nes.prg_ram_writeble:=true;
        mapper_nes.prg_ram_enable:=true;
      end;
    7,15,145,148,149,150,184,243:set_prg_32(0);
    9:begin
        set_prg_8($8000,0);
        set_prg_8($a000,(mapper_nes.last_prg shl 1)-3);
        set_prg_8($c000,(mapper_nes.last_prg shl 1)-2);
        set_prg_8($e000,(mapper_nes.last_prg shl 1)-1);
        set_chr_4(0,4);
        set_chr_4($1000,0);
      end;
    11,58,212,213:begin
        set_prg_32(0);
        if mapper_nes.last_chr<>0 then set_chr_8(0);
      end;
    18,21,22,23,25,85:begin
          set_prg_16($8000,0);
          set_prg_16($c000,mapper_nes.last_prg-1);
          mapper_nes.prg_ram_enable:=true;
          mapper_nes.prg_ram_writeble:=true;
       end;
    32:begin
          if mapper_nes.submapper=1 then ppu_nes.mirror:=MIRROR_HIGH;
          set_prg_16($8000,0);
          set_prg_16($c000,mapper_nes.last_prg-1);
       end;
    34:begin
          mapper_nes.reg[0]:=0;
          mapper_nes.reg[1]:=0;
          mapper_nes.reg[2]:=1;
          mapper_nes.prg_ram_enable:=true;
          mapper_nes.prg_ram_writeble:=true;
          set_prg_32(mapper_nes.last_prg shr 1);
       end;
    41:begin
          set_prg_32(0);
          set_chr_8(0);
       end;
    42:begin
          mapper_nes.prg_ram_enable:=true; //Solo ROM
          copymemory(@memoria[$8000],@mapper_nes.prg[mapper_nes.last_prg-2,0],$4000);
          copymemory(@memoria[$c000],@mapper_nes.prg[mapper_nes.last_prg-1,0],$4000);
       end;
    68:begin
          set_prg_16($8000,0);
          set_prg_16($c000,mapper_nes.last_prg-1);
          mapper_nes.prg_ram_writeble:=true;
       end;
    69:begin
          set_prg_16($8000,mapper_nes.last_prg-2);
          set_prg_16($c000,mapper_nes.last_prg-1);
          AY8910_0.reset;
      end;
    71:copymemory(@memoria[$c000],@mapper_nes.prg[(mapper_nes.last_prg-1),0],$4000);
    73:begin
          set_prg_16($8000,0);
          set_prg_16($c000,mapper_nes.last_prg-1);
          mapper_nes.prg_ram_writeble:=true;
          mapper_nes.prg_ram_enable:=true;
       end;
    75:set_prg_8($e000,(mapper_nes.last_prg shl 1)-1);
    105:begin
          set_prg_32(0);
          mapper_nes.latch1:=$ff;
          mapper_nes.prg_ena:=false;
        end;
    116:begin
          fillchar(mapper_nes.reg,4,$ff);
          fillchar(mapper_nes.dreg,16,$ff);
          set_prg_16($8000,0);
          set_prg_16($c000,mapper_nes.last_prg-1);
          mapper_nes.mode:=0;
        end;
    132,138,173:set_prg_32(0);
    137:begin
          set_prg_32(0);
          //IMPORTANTISIMO!!!!
          set_chr_4($1000,(mapper_nes.last_chr shl 1)-1);
        end;
    139:begin
          set_prg_32(0);
          mapper_nes.shift:=2;
          mapper_nes.reg[0]:=1;
          mapper_nes.reg[1]:=2;
          mapper_nes.reg[2]:=3;
        end;
    141:begin
          set_prg_32(0);
          mapper_nes.shift:=1;
          mapper_nes.reg[0]:=1;
          mapper_nes.reg[2]:=1;
        end;
    142:begin
          set_prg_8($e000,(mapper_nes.last_prg shl 1)-1);
          mapper_nes.prg_ram_enable:=true; //Solo ROM
        end;
    147:copymemory(@memoria[$c000],@mapper_nes.prg[1,0],$4000);
    221:begin
          set_prg_16($8000,0);
          set_prg_16($c000,0);
        end;
  end;
end;

end.
