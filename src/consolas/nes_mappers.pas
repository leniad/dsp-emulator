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
}

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nes_ppu,main_engine,n2a03;

type
  tnes_mapper=packed record
              prg:array[0..31,0..$3fff] of byte;
              chr:array[0..63,0..$1fff] of byte;
              name_table:array[0..1,0..$fff] of byte;
              reg:array[0..3] of byte;
              dreg:array[0..7] of byte;
              serial_cnt,last_prg,last_chr,valor_map,latch1,latch2:byte;
              counter:word;
              irq_ena,reload,chr_extra_ena:boolean;
              ppu_read:procedure (address:word);
           end;

//Mappers
procedure mapper_1_write_rom(direccion:word;valor:byte);
procedure mapper_1_irq(estados_t:word);
procedure mapper_2_write_rom(direccion:word;valor:byte);
procedure mapper_3_write_rom(direccion:word;valor:byte);
procedure mapper_4_write_rom(direccion:word;valor:byte);
procedure mapper_4_line;
procedure mapper_4_wram_write(direccion:word;valor:byte);
procedure mapper_mmc6_write_rom(direccion:word;valor:byte);
function mapper_mmc6_wram_read(direccion:word):byte;
procedure mapper_mmc6_wram_write(direccion:word;valor:byte);
procedure mapper_7_write_rom(direccion:word;valor:byte);
procedure mapper_9_write_rom(direccion:word;valor:byte);
procedure mapper_9_ppu_read(direccion:word);
procedure mapper_11_write_rom(direccion:word;valor:byte);
procedure mapper_12_write_rom(direccion:word;valor:byte);
procedure mapper_66_write_rom(direccion:word;valor:byte);
procedure mapper_67_write_rom(direccion:word;valor:byte);
procedure mapper_67_irq(estados_t:word);
procedure mapper_68_write_rom(direccion:word;valor:byte);
procedure mapper_71_write_rom(direccion:word;valor:byte);
procedure mapper_87_write_rom(direccion:word;valor:byte);
procedure mapper_93_write_rom(direccion:word;valor:byte);
procedure mapper_94_write_rom(direccion:word;valor:byte);
procedure mapper_147_write_rom(direccion:word;valor:byte);
procedure mapper_180_write_rom(direccion:word;valor:byte);
procedure mapper_185_write_rom(direccion:word;valor:byte);
procedure mapper_221_write_rom(direccion:word;valor:byte);

var
  mapper_nes:^tnes_mapper;

implementation
uses nes;

procedure mapper_1_mirror;
begin
case (mapper_nes.reg[0] and 3) of
  0:ppu_nes.mirror:=MIRROR_LOW;
  1:ppu_nes.mirror:=MIRROR_HIGH;
  2:ppu_nes.mirror:=MIRROR_VERTICAL; //Vertical
  3:ppu_nes.mirror:=MIRROR_HORIZONTAL; //Horizontal
end;
end;

procedure mapper_1_chr;
var
  tempb:byte;
begin
  if ppu_nes.chr_rom then begin
    //VROM de 4Kb, en la cebecera se cuentan de 8kb lo multiplico por 2
    if (mapper_nes.reg[0] and $10)<>0 then begin
          tempb:=mapper_nes.reg[1] mod (mapper_nes.last_chr shl 1);
          copymemory(@ppu_nes.mem[$0],@mapper_nes.chr[tempb shr 1,$1000*(tempb and 1)],$1000);
          tempb:=mapper_nes.reg[2] mod (mapper_nes.last_chr shl 1);
          copymemory(@ppu_nes.mem[$1000],@mapper_nes.chr[tempb shr 1,$1000*(tempb and 1)],$1000);
        end else begin //VROM de 8Kb
          tempb:=mapper_nes.reg[1] mod mapper_nes.last_chr;
          copymemory(@ppu_nes.mem[$0],@mapper_nes.chr[tempb,0],$2000);
        end;
      end;
end;

procedure mapper_1_prg;
var
  tempb:byte;
begin
tempb:=mapper_nes.reg[3] and $f;
case (mapper_nes.reg[0] and $c) of
    $c:begin
        tempb:=tempb mod mapper_nes.last_prg;
        copymemory(@memoria[$8000],@mapper_nes.prg[tempb,0],$4000);
        copymemory(@memoria[$c000],@mapper_nes.prg[$f mod mapper_nes.last_prg,0],$4000); //(mapper_nes.last_prg-1)
       end;
    $8:begin
        tempb:=tempb mod mapper_nes.last_prg;
        copymemory(@memoria[$8000],@mapper_nes.prg[0,0],$4000);
        copymemory(@memoria[$c000],@mapper_nes.prg[tempb,0],$4000);
       end;
    $0,$4:begin  //32Kb
        tempb:=(tempb shr 1) mod (mapper_nes.last_prg shr 1);
        copymemory(@memoria[$8000],@mapper_nes.prg[tempb,0],$4000);
        copymemory(@memoria[$c000],@mapper_nes.prg[tempb+1,0],$4000);
       end;
end;
sram_enable:=(mapper_nes.reg[3] and $10)=0;
end;

procedure mapper_1_write_rom(direccion:word;valor:byte);
begin
if ((mapper_nes.counter<2) and (mapper_nes.serial_cnt=0)) then exit;
if (valor and $80)<>0 then begin
  mapper_nes.serial_cnt:=0;
  mapper_nes.valor_map:=0;
  mapper_nes.reg[0]:=$c;
  mapper_nes.counter:=0;
end else begin
  mapper_nes.valor_map:=mapper_nes.valor_map or ((valor and 1) shl mapper_nes.serial_cnt);
  mapper_nes.serial_cnt:=mapper_nes.serial_cnt+1;
  mapper_nes.counter:=0;
  if mapper_nes.serial_cnt=5 then begin
    mapper_nes.reg[(direccion shr 13) and 3]:=mapper_nes.valor_map;
    mapper_1_mirror;
    mapper_1_chr;
    mapper_1_prg;
    mapper_nes.valor_map:=0;
    mapper_nes.serial_cnt:=0;
  end;
  end;
end;

procedure mapper_1_irq(estados_t:word);
begin
  mapper_nes.counter:=mapper_nes.counter+estados_t;
end;

procedure mapper_2_write_rom(direccion:word;valor:byte);
begin
valor:=valor mod mapper_nes.last_prg;
copymemory(@memoria[$8000],@mapper_nes.prg[valor,0],$4000);
end;

procedure mapper_3_write_rom(direccion:word;valor:byte);
begin
  valor:=valor mod mapper_nes.last_chr;
  copymemory(@ppu_nes.mem[$0],@mapper_nes.chr[valor,0],$2000);
end;

procedure mapper_4_update_chr(valor:byte);
var
  base:word;
  temp0,temp1,temp2,temp3,temp4,temp5:byte;
begin
temp0:=(mapper_nes.dreg[0] shr 3) mod mapper_nes.last_chr;
temp1:=(mapper_nes.dreg[1] shr 3) mod mapper_nes.last_chr;
temp2:=(mapper_nes.dreg[2] shr 3) mod mapper_nes.last_chr;
temp3:=(mapper_nes.dreg[3] shr 3) mod mapper_nes.last_chr;
temp4:=(mapper_nes.dreg[4] shr 3) mod mapper_nes.last_chr;
temp5:=(mapper_nes.dreg[5] shr 3) mod mapper_nes.last_chr;
if (valor and $80)=0 then begin
  copymemory(@ppu_nes.mem[$0],@mapper_nes.chr[temp0,$400*(mapper_nes.dreg[0] and 7)],$800);
  copymemory(@ppu_nes.mem[$800],@mapper_nes.chr[temp1,$400*(mapper_nes.dreg[1] and 7)],$800);
  copymemory(@ppu_nes.mem[$1000],@mapper_nes.chr[temp2,$400*(mapper_nes.dreg[2] and 7)],$400);
  copymemory(@ppu_nes.mem[$1400],@mapper_nes.chr[temp3,$400*(mapper_nes.dreg[3] and 7)],$400);
  copymemory(@ppu_nes.mem[$1800],@mapper_nes.chr[temp4,$400*(mapper_nes.dreg[4] and 7)],$400);
  copymemory(@ppu_nes.mem[$1c00],@mapper_nes.chr[temp5,$400*(mapper_nes.dreg[5] and 7)],$400);
end else begin
  copymemory(@ppu_nes.mem[$0],@mapper_nes.chr[temp2,$400*(mapper_nes.dreg[2] and 7)],$400);
  copymemory(@ppu_nes.mem[$400],@mapper_nes.chr[temp3,$400*(mapper_nes.dreg[3] and 7)],$400);
  copymemory(@ppu_nes.mem[$800],@mapper_nes.chr[temp4,$400*(mapper_nes.dreg[4] and 7)],$400);
  copymemory(@ppu_nes.mem[$c00],@mapper_nes.chr[temp5,$400*(mapper_nes.dreg[5] and 7)],$400);
  copymemory(@ppu_nes.mem[$1000],@mapper_nes.chr[temp0,$400*(mapper_nes.dreg[0] and 7)],$800);
  copymemory(@ppu_nes.mem[$1800],@mapper_nes.chr[temp1,$400*(mapper_nes.dreg[1] and 7)],$800);
end;
end;

procedure mapper_4_update_prg(valor:byte);
var
  temp1,temp2:byte;
begin
temp1:=(mapper_nes.dreg[6] shr 1) mod mapper_nes.last_prg;
temp2:=(mapper_nes.dreg[7] shr 1) mod mapper_nes.last_prg;
if (valor and $40)=0 then begin
  copymemory(@memoria[$8000],@mapper_nes.prg[temp1,$2000*(mapper_nes.dreg[6] and 1)],$2000);
  copymemory(@memoria[$a000],@mapper_nes.prg[temp2,$2000*(mapper_nes.dreg[7] and 1)],$2000);
  copymemory(@memoria[$c000],@mapper_nes.prg[mapper_nes.last_prg-1,0],$2000);
  copymemory(@memoria[$e000],@mapper_nes.prg[mapper_nes.last_prg-1,$2000],$2000);
end else begin
  copymemory(@memoria[$8000],@mapper_nes.prg[mapper_nes.last_prg-1,0],$2000);
  copymemory(@memoria[$a000],@mapper_nes.prg[temp2,$2000*(mapper_nes.dreg[7] and 1)],$2000);
  copymemory(@memoria[$c000],@mapper_nes.prg[temp1,$2000*(mapper_nes.dreg[6] and 1)],$2000);
  copymemory(@memoria[$e000],@mapper_nes.prg[mapper_nes.last_prg-1,$2000],$2000);
end;
end;

procedure mapper_4_write_rom(direccion:word;valor:byte);
begin
direccion:=direccion and $e001;
case direccion of
  $8000:mapper_nes.reg[0]:=valor;  //command
  $8001:begin
          mapper_nes.dreg[mapper_nes.reg[0] and 7]:=valor;
          if ppu_nes.chr_rom then mapper_4_update_chr(mapper_nes.reg[0]);
          mapper_4_update_prg(mapper_nes.reg[0]);
        end;
  $a000:if ppu_nes.mirror<>MIRROR_FOUR_SCREEN then begin //Usado por Gauntlet!!!
          if (valor and 1)=0 then ppu_nes.mirror:=MIRROR_VERTICAL //Vertical
            else ppu_nes.mirror:=MIRROR_HORIZONTAL; //Horizontal
        end;
  $a001:begin
          sram_enable:=(valor and $80)<>0;
          mapper_nes.reg[3]:=valor;
        end;
  $c000:mapper_nes.reg[2]:=valor;
  $c001:mapper_nes.reload:=true;
  $e000:mapper_nes.irq_ena:=false;
  $e001:mapper_nes.irq_ena:=true;
end;
end;

procedure mapper_4_wram_write(direccion:word;valor:byte);
begin
if not(sram_enable) then exit;
if (mapper_nes.reg[3]=0) then memoria[direccion]:=valor;
end;

procedure mapper_4_line;
var
  count:byte;
begin
  count:=mapper_nes.reg[1];
  mapper_nes.reg[1]:=mapper_nes.reg[1]-1;
  if ((count=0) or mapper_nes.reload) then begin
    mapper_nes.reg[1]:=mapper_nes.reg[2];
    mapper_nes.reload:=false;
  end else begin
    if ((count<>0) and (mapper_nes.reg[1]=0)) then
        if mapper_nes.irq_ena then n2a03_0.m6502.change_irq(HOLD_LINE);
  end;
end;

procedure mapper_mmc6_write_rom(direccion:word;valor:byte);
begin
direccion:=direccion and $e001;
case direccion of
  $8000:mapper_nes.reg[0]:=valor;  //command
  $8001:begin
          mapper_nes.dreg[mapper_nes.reg[0] and 7]:=valor;
          if ppu_nes.chr_rom then mapper_4_update_chr(mapper_nes.reg[0]);
          mapper_4_update_prg(mapper_nes.reg[0]);
          sram_enable:=(valor and $20)=0;
        end;
  $a000:if ppu_nes.mirror<>MIRROR_FOUR_SCREEN then begin //Usado por Gauntlet!!!
          if (valor and 1)=0 then ppu_nes.mirror:=MIRROR_VERTICAL //Vertical
            else ppu_nes.mirror:=MIRROR_HORIZONTAL; //Horizontal
        end;
  $a001:if sram_enable then mapper_nes.reg[3]:=valor;
  $c000:mapper_nes.reg[2]:=valor;
  $c001:mapper_nes.reload:=true;
  $e000:mapper_nes.irq_ena:=false;
  $e001:mapper_nes.irq_ena:=true;
end;
end;

function mapper_mmc6_wram_read(direccion:word):byte;
begin
if not(sram_enable) then begin
  mapper_mmc6_wram_read:=direccion and $ff;
  exit;
end;
if (((mapper_nes.reg[3] and $20)=0) and ((mapper_nes.reg[3] and $80)=0)) then begin
  mapper_mmc6_wram_read:=direccion and $ff;
  exit;
end;
case direccion of
  $6000..$6fff:mapper_mmc6_wram_read:=direccion and $ff;
  $7000..$71ff,$7400..$75ff,$7800..$79ff,$7c00..$7dff:if ((mapper_nes.reg[3] and $10)<>0) then mapper_mmc6_wram_read:=memoria[$7000+(direccion and $1ff)]
                                                        else mapper_mmc6_wram_read:=0;
  $7200..$73ff,$7600..$77ff,$7a00..$7bff,$7e00..$7fff:if ((mapper_nes.reg[3] and $40)<>0) then mapper_mmc6_wram_read:=memoria[$7200+(direccion and $1ff)]
                                                        else mapper_mmc6_wram_read:=0;
end;
end;

procedure mapper_mmc6_wram_write(direccion:word;valor:byte);
begin
if not(sram_enable) then valor:=0;
case direccion of
  $6000..$6fff:memoria[direccion]:=direccion and $ff;
  $7000..$71ff,$7400..$75ff,$7800..$79ff,$7c00..$7dff:if (((mapper_nes.reg[3] and $20)<>0) and ((mapper_nes.reg[3] and $10)<>0)) then memoria[$7000+(direccion and $1ff)]:=valor;
  $7200..$73ff,$7600..$77ff,$7a00..$7bff,$7e00..$7fff:if (((mapper_nes.reg[3] and $80)<>0) and ((mapper_nes.reg[3] and $40)<>0)) then memoria[$7200+(direccion and $1ff)]:=valor;
end;
end;

procedure mapper_7_write_rom(direccion:word;valor:byte);
begin
valor:=((valor and $7) mod (mapper_nes.last_prg shr 1)) shl 1;
copymemory(@memoria[$8000],@mapper_nes.prg[valor,0],$4000);
copymemory(@memoria[$c000],@mapper_nes.prg[valor+1,0],$4000);
if (valor and $10)=0 then ppu_nes.mirror:=MIRROR_LOW
  else ppu_nes.mirror:=MIRROR_HIGH;
end;

procedure mapper_9_write_rom(direccion:word;valor:byte);
var
  tempb:byte;
begin
case ((direccion shr 12) and 7) of
  $2:begin
        tempb:=valor mod (mapper_nes.last_prg shl 1);
        copymemory(@memoria[$8000],@mapper_nes.prg[tempb shr 1,$2000*(tempb and 1)],$2000);
      end;
  $3:begin
        mapper_nes.reg[0]:=(valor and $1f) mod (mapper_nes.last_chr shl 1);
        if (mapper_nes.latch1=$fd) then copymemory(@ppu_nes.mem[$0],@mapper_nes.chr[mapper_nes.reg[0] shr 1,$1000*(mapper_nes.reg[0] and 1)],$1000);
     end;
  $4:begin
        mapper_nes.reg[1]:=(valor and $1f) mod (mapper_nes.last_chr shl 1);
        if (mapper_nes.latch1=$fe) then copymemory(@ppu_nes.mem[$0],@mapper_nes.chr[mapper_nes.reg[1] shr 1,$1000*(mapper_nes.reg[1] and 1)],$1000);
     end;
  $5:begin
        mapper_nes.reg[2]:=(valor and $1f) mod (mapper_nes.last_chr shl 1);
        if mapper_nes.latch2=$fd then copymemory(@ppu_nes.mem[$1000],@mapper_nes.chr[mapper_nes.reg[2] shr 1,$1000*(mapper_nes.reg[2] and 1)],$800);
  end;
  $6:begin
        mapper_nes.reg[3]:=(valor and $1f) mod (mapper_nes.last_chr shl 1);
        if mapper_nes.latch2=$fe then copymemory(@ppu_nes.mem[$1000],@mapper_nes.chr[mapper_nes.reg[3] shr 1,$1000*(mapper_nes.reg[3] and 1)],$1000);
     end;
  $7:if (valor and 1)<>0 then ppu_nes.mirror:=MIRROR_HORIZONTAL
        else ppu_nes.mirror:=MIRROR_VERTICAL;
end;
end;

procedure mapper_9_ppu_read(direccion:word);
begin
case (direccion and $3ff0) of
      $0fd0:begin
              mapper_nes.latch1:=$fd;
              copymemory(@ppu_nes.mem[0],@mapper_nes.chr[mapper_nes.reg[0] shr 1,$1000*(mapper_nes.reg[0] and 1)],$1000);
            end;
      $0fe0:begin
              mapper_nes.latch1:=$fe;
              copymemory(@ppu_nes.mem[0],@mapper_nes.chr[mapper_nes.reg[1] shr 1,$1000*(mapper_nes.reg[1] and 1)],$1000);
            end;
      $1fd0:begin
              mapper_nes.latch2:=$fd;
              copymemory(@ppu_nes.mem[$1000],@mapper_nes.chr[mapper_nes.reg[2] shr 1,$1000*(mapper_nes.reg[2] and 1)],$1000);
            end;
      $1fe0:begin
              mapper_nes.latch2:=$fe;
              copymemory(@ppu_nes.mem[$1000],@mapper_nes.chr[mapper_nes.reg[3] shr 1,$1000*(mapper_nes.reg[3] and 1)],$1000);
            end;
   end;
end;

procedure mapper_11_write_rom(direccion:word;valor:byte);
var
  temp:byte;
begin
if direccion>$7fff then begin
  temp:=((valor and 3) mod (mapper_nes.last_prg shr 1)) shl 1;
  copymemory(@memoria[$8000],@mapper_nes.prg[temp,0],$4000);
  copymemory(@memoria[$c000],@mapper_nes.prg[temp+1,0],$4000);
  temp:=(valor shr 4) mod mapper_nes.last_chr;
  copymemory(@ppu_nes.mem[0],@mapper_nes.chr[temp,0],$2000);
end;
end;

procedure mapper_12_write_rom(direccion:word;valor:byte);
begin
direccion:=direccion and $e001;
case direccion of
  $4000..$4001:mapper_nes.reg[3]:=valor;
  $8000:mapper_nes.reg[0]:=valor;
  $8001:begin
          case (mapper_nes.reg[0] and 7) of
            0..1:mapper_nes.dreg[mapper_nes.reg[0] and 7]:=(valor+((mapper_nes.reg[3] and $1) shl 8)) mod (mapper_nes.last_chr shl 3);
            2..5:mapper_nes.dreg[mapper_nes.reg[0] and 7]:=(valor+((mapper_nes.reg[3] and $10) shl 4)) mod (mapper_nes.last_chr shl 3);
            6,7:mapper_nes.dreg[mapper_nes.reg[0] and 7]:=(valor and $3f) mod (mapper_nes.last_prg shl 1);
          end;
          if ppu_nes.chr_rom then mapper_4_update_chr(mapper_nes.reg[0]);
          mapper_4_update_prg(mapper_nes.reg[0]);
        end;
  $a000:if ppu_nes.mirror<>MIRROR_FOUR_SCREEN then begin
          if (valor and 1)=0 then ppu_nes.mirror:=MIRROR_VERTICAL //Vertical
            else ppu_nes.mirror:=MIRROR_HORIZONTAL; //Horizontal
        end;
  $a001:sram_enable:=(valor and $40)=0;
  $c000:mapper_nes.reg[2]:=valor;
  $c001:mapper_nes.reload:=true;
  $e000:mapper_nes.irq_ena:=false;
  $e001:mapper_nes.irq_ena:=true;
end;
end;

procedure mapper_66_write_rom(direccion:word;valor:byte);
var
  tempb:byte;
begin
tempb:=(valor and $3) mod mapper_nes.last_chr;
copymemory(@ppu_nes.mem[0],@mapper_nes.chr[tempb,0],$2000);
tempb:=(((valor and $30) shr 4) mod (mapper_nes.last_prg shr 1)) shl 1;
copymemory(@memoria[$8000],@mapper_nes.prg[tempb,0],$4000);
copymemory(@memoria[$c000],@mapper_nes.prg[tempb+1,0],$4000);
end;

procedure mapper_67_write_rom(direccion:word;valor:byte);
var
  tempb:byte;
begin
tempb:=valor mod (mapper_nes.last_chr shl 2);
case (direccion shr 12) of
  $8:copymemory(@ppu_nes.mem[$0],@mapper_nes.chr[tempb shr 2,$800*(tempb and $3)],$800);
  $9:copymemory(@ppu_nes.mem[$800],@mapper_nes.chr[tempb shr 2,$800*(tempb and $3)],$800);
  $a:copymemory(@ppu_nes.mem[$1000],@mapper_nes.chr[tempb shr 2,$800*(tempb and $3)],$800);
  $b:copymemory(@ppu_nes.mem[$1800],@mapper_nes.chr[tempb shr 2,$800*(tempb and $3)],$800);
  //Escribe dos veces la cantidad de estados T para la IRQ
  $c:begin
      case mapper_nes.latch1 of
        0:mapper_nes.reg[0]:=valor;
        1:mapper_nes.counter:=(mapper_nes.reg[0] shl 8) or valor;
      end;
      mapper_nes.latch1:=mapper_nes.latch1 xor 1;
     end;
  $d:begin
      if mapper_nes.irq_ena then n2a03_0.m6502.change_irq(HOLD_LINE);
      mapper_nes.latch1:=0;
      mapper_nes.irq_ena:=(valor and $10)<>0;
    end;
  $e:case (valor and 3) of
          0:ppu_nes.mirror:=MIRROR_VERTICAL; //Vertical
          1:ppu_nes.mirror:=MIRROR_HORIZONTAL; //Horizontal
          2:ppu_nes.mirror:=MIRROR_LOW;
          3:ppu_nes.mirror:=MIRROR_HIGH;
        end;
  $f:begin
          tempb:=valor mod mapper_nes.last_prg;
          copymemory(@memoria[$8000],@mapper_nes.prg[tempb,0],$4000);
        end;
end;
end;

procedure mapper_67_irq(estados_t:word);
var
  tempw:integer;
begin
if mapper_nes.irq_ena then begin
  tempw:=mapper_nes.counter-estados_t;
  if (tempw<0) then n2a03_0.m6502.change_irq(HOLD_LINE)
    else mapper_nes.counter:=tempw;
end;
end;

procedure mapper_68_write_rom(direccion:word;valor:byte);
var
  tempb:byte;
begin
tempb:=valor mod (mapper_nes.last_chr shl 2);
case ((direccion shr 12) and $f) of
  $8:copymemory(@ppu_nes.mem[$0],@mapper_nes.chr[tempb shr 2,$800*(tempb and $3)],$800);
  $9:copymemory(@ppu_nes.mem[$800],@mapper_nes.chr[tempb shr 2,$800*(tempb and $3)],$800);
  $a:copymemory(@ppu_nes.mem[$1000],@mapper_nes.chr[tempb shr 2,$800*(tempb and $3)],$800);
  $b:copymemory(@ppu_nes.mem[$1800],@mapper_nes.chr[tempb shr 2,$800*(tempb and $3)],$800);
  $c:if mapper_nes.chr_extra_ena then begin
        tempb:=($80+(valor and $7f)) mod (mapper_nes.last_chr shl 3);
        copymemory(@ppu_nes.mem[$2000],@mapper_nes.chr[tempb shr 3,$400*(tempb and $7)],$400);
        case ppu_nes.mirror of
                    MIRROR_HORIZONTAL:copymemory(@ppu_nes.mem[$2400],@mapper_nes.chr[tempb shr 3,$400*(tempb and $7)],$400);
                    MIRROR_VERTICAL:copymemory(@ppu_nes.mem[$2800],@mapper_nes.chr[tempb shr 3,$400*(tempb and $7)],$400);
        end;
     end;
  $d:if mapper_nes.chr_extra_ena then begin
        tempb:=($80+(valor and $7f)) mod (mapper_nes.last_chr shl 3);
        copymemory(@ppu_nes.mem[$2c00],@mapper_nes.chr[tempb shr 3,$400*(tempb and $7)],$400);
        case ppu_nes.mirror of
                    MIRROR_HORIZONTAL:copymemory(@ppu_nes.mem[$2800],@mapper_nes.chr[tempb shr 3,$400*(tempb and $7)],$400);
                    MIRROR_VERTICAL:copymemory(@ppu_nes.mem[$2400],@mapper_nes.chr[tempb shr 3,$400*(tempb and $7)],$400);
        end;
     end;
  $e:begin
        case (valor and 1) of
          0:ppu_nes.mirror:=MIRROR_VERTICAL; //Vertical
          1:ppu_nes.mirror:=MIRROR_HORIZONTAL; //Horizontal
        end;
        mapper_nes.chr_extra_ena:=(valor and $10)<>0;
     end;
  $f:begin
        tempb:=(valor and $f) mod mapper_nes.last_prg;
        copymemory(@memoria[$8000],@mapper_nes.prg[tempb,0],$4000);
        sram_enable:=(valor and $10)<>0;
     end;
end;
end;

procedure mapper_71_write_rom(direccion:word;valor:byte);
begin
case direccion of
  $8000..$9fff:if ((valor shr 4) and 1)<>0 then ppu_nes.mirror:=MIRROR_HIGH
                  else ppu_nes.mirror:=MIRROR_LOW;
  $c000..$ffff:begin
                  valor:=(valor and $f) mod mapper_nes.last_prg;
                  copymemory(@memoria[$8000],@mapper_nes.prg[valor,0],$4000);
               end;
end;
end;

procedure mapper_87_write_rom(direccion:word;valor:byte);
begin
valor:=((valor shr 1) or ((valor and 1) shl 1)) mod mapper_nes.last_chr;
copymemory(@ppu_nes.mem[$0],@mapper_nes.chr[valor,0],$2000);
end;

procedure mapper_93_write_rom(direccion:word;valor:byte);
begin
valor:=(valor shr 4) mod mapper_nes.last_prg;
copymemory(@memoria[$8000],@mapper_nes.prg[valor,0],$4000);
if (valor and 1)<>0 then ppu_nes.mirror:=MIRROR_HORIZONTAL
  else ppu_nes.mirror:=MIRROR_VERTICAL;
end;

procedure mapper_94_write_rom(direccion:word;valor:byte);
begin
valor:=((valor shr 2) and $7) mod mapper_nes.last_prg;
copymemory(@memoria[$8000],@mapper_nes.prg[valor,0],$4000);
end;

procedure mapper_147_write_rom(direccion:word;valor:byte);
var
  temp:byte;
begin
if (direccion and $103)=$102 then begin
  temp:=((((valor shr 2) and 1) or ((valor and $80) shr 6)) mod (mapper_nes.last_prg shr 1))*2;
  copymemory(@memoria[$8000],@mapper_nes.prg[temp,0],$4000);
  copymemory(@memoria[$c000],@mapper_nes.prg[temp+1,0],$4000);
  temp:=((valor shr 3) and $f) mod mapper_nes.last_chr;
  copymemory(@ppu_nes.mem[0],@mapper_nes.chr[temp,0],$2000);
end;
end;

procedure mapper_180_write_rom(direccion:word;valor:byte);
begin
valor:=(valor and $7) mod mapper_nes.last_prg;
copymemory(@memoria[$c000],@mapper_nes.prg[valor,0],$4000);
end;

procedure mapper_185_write_rom(direccion:word;valor:byte);
begin
if (((valor and $f)<>0) and (valor<>$13)) then begin
      ppu_nes.disable_chr:=false;
      valor:=(valor and $3) mod mapper_nes.last_chr;
      copymemory(@ppu_nes.mem[$0],@mapper_nes.chr[valor,0],$2000);
end else ppu_nes.disable_chr:=true;
end;

procedure mapper_221_write_rom(direccion:word;valor:byte);
var
  tempw:word;
begin
case direccion of
  $8000..$8007:mapper_nes.reg[direccion and 3]:=valor and $7f;
  $d000:begin
          if (valor and $80)<>0 then begin
              sram_enable:=true;
              case (valor and 7) of
                 0:begin
                      tempw:=((mapper_nes.reg[3]*4)+3) mod (mapper_nes.last_prg shl 1);
                      copymemory(@memoria[$8000],@mapper_nes.prg[mapper_nes.last_prg-2,0],$4000);
                      copymemory(@memoria[$c000],@mapper_nes.prg[mapper_nes.last_prg-1,0],$4000);
                    end;
                 1:begin
                      tempw:=((mapper_nes.reg[3]*2)+1) mod (mapper_nes.last_prg shl 1);
                      copymemory(@memoria[$6000],@mapper_nes.prg[tempw,tempw and 1],$2000);
                      copymemory(@memoria[$8000],@mapper_nes.prg[mapper_nes.reg[1],0],$4000);
                      copymemory(@memoria[$c000],@mapper_nes.prg[mapper_nes.last_prg-1,0],$4000);
                    end;
                2,3,6,7:begin
                      tempw:=mapper_nes.reg[3] mod (mapper_nes.last_prg shl 1);
                      copymemory(@memoria[$6000],@mapper_nes.prg[tempw,tempw and 1],$2000);
                    end;
                 4:begin
                      tempw:=((mapper_nes.reg[3]*4)+3) mod (mapper_nes.last_prg shl 1);
                      copymemory(@memoria[$8000],@mapper_nes.prg[mapper_nes.reg[3],0],$4000);
                      copymemory(@memoria[$c000],@mapper_nes.prg[mapper_nes.reg[3]+1,0],$4000);
                    end;
                 5:begin
                      tempw:=((mapper_nes.reg[3]*2)+1) mod (mapper_nes.last_prg shl 1);
                      copymemory(@memoria[$6000],@mapper_nes.prg[tempw,tempw and 1],$2000);
                      copymemory(@memoria[$8000],@mapper_nes.prg[mapper_nes.reg[1],0],$4000);
                      copymemory(@memoria[$c000],@mapper_nes.prg[mapper_nes.reg[3],0],$4000);
                    end;
              end;
          end else sram_enable:=false;
        end;
end;
end;

end.
