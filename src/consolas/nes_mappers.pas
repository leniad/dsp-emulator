unit nes_mappers;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6502,nes_ppu,main_engine;

type
  tmapper1=record
              prg:array[0..31,0..$3fff] of byte;
              chr:array[0..31,0..$1fff] of byte;
              name_table:array[0..1,0..$fff] of byte;
              reg:array[0..3] of byte;
              last_prg,last_chr:byte;
              dreg:array[0..7] of byte;
              serial_cnt:byte;
              valor_map:byte;
              irq_ena,reload:boolean;
           end;

//Mappers
procedure mapper_1_write_rom(direccion:word;valor:byte);
procedure mapper_2_write_rom(direccion:word;valor:byte);
procedure mapper_3_write_rom(direccion:word;valor:byte);
procedure mapper_4_write_rom(direccion:word;valor:byte);
procedure mapper_4_line;
procedure mapper_7_write_rom(direccion:word;valor:byte);
procedure mapper_66_write_rom(direccion:word;valor:byte);
procedure mapper_87_write_rom(direccion:word;valor:byte);

var
  mapper_nes:tmapper1;

implementation
uses nes;

procedure mapper_1_mirror;
begin
case (mapper_nes.reg[0] and 3) of
  0,1:ppu_mirror:=MIRROR_SINGLE_0;
  2:ppu_mirror:=MIRROR_VERTICAL; //Vertical
  3:ppu_mirror:=MIRROR_HORIZONTAL; //Horizontal
end;
end;

procedure mapper_1_chr;
var
  tempb:byte;
begin
  if ppu_chr_rom then begin
    //VROM de 4Kb, en la cebecera se cuentan de 8kb lo multiplico por 2
    if (mapper_nes.reg[0] and $10)<>0 then begin
          tempb:=mapper_nes.reg[1] mod ((mapper_nes.last_chr+1) shl 1);
          copymemory(@ppu_mem[$0],@mapper_nes.chr[tempb shr 1,$1000*(tempb and 1)],$1000);
          tempb:=mapper_nes.reg[2] mod ((mapper_nes.last_chr+1) shl 1);
          copymemory(@ppu_mem[$1000],@mapper_nes.chr[tempb shr 1,$1000*(tempb and 1)],$1000);
        end else begin //VROM de 8Kb
          tempb:=mapper_nes.reg[1] mod (mapper_nes.last_chr+1);
          copymemory(@ppu_mem[$0],@mapper_nes.chr[tempb,0],$2000);
        end;
      end;
end;

procedure mapper_1_prg;
var
  tempb:byte;
begin
case (mapper_nes.reg[0] and $c) of
    $c:begin
        tempb:=mapper_nes.reg[3] mod (mapper_nes.last_prg+1);
        copymemory(@memoria[$8000],@mapper_nes.prg[tempb,0],$4000);
        copymemory(@memoria[$c000],@mapper_nes.prg[mapper_nes.last_prg,0],$4000);
       end;
    $8:begin
        tempb:=mapper_nes.reg[3] mod (mapper_nes.last_prg+1);
        copymemory(@memoria[$8000],@mapper_nes.prg[0,0],$4000);
        copymemory(@memoria[$c000],@mapper_nes.prg[tempb,0],$4000);
       end;
    $0,$4:begin  //32Kb
        tempb:=(mapper_nes.reg[3] shr 1) mod ((mapper_nes.last_prg+1) shr 1);
        copymemory(@memoria[$8000],@mapper_nes.prg[tempb,0],$4000);
        copymemory(@memoria[$c000],@mapper_nes.prg[tempb+1,0],$4000);
       end;
end;
end;

procedure mapper_1_write_rom(direccion:word;valor:byte);
begin
if (valor and $80)<>0 then begin
  mapper_nes.serial_cnt:=0;
  mapper_nes.valor_map:=0;
  mapper_nes.reg[0]:=$1c;
end else begin
  mapper_nes.valor_map:=mapper_nes.valor_map or ((valor and 1) shl mapper_nes.serial_cnt);
  mapper_nes.serial_cnt:=mapper_nes.serial_cnt+1;
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


procedure mapper_2_write_rom(direccion:word;valor:byte);
begin
valor:=valor mod (mapper_nes.last_prg+1);
copymemory(@memoria[$8000],@mapper_nes.prg[valor,0],$4000);
end;

procedure mapper_3_write_rom(direccion:word;valor:byte);
begin
valor:=valor mod mapper_nes.last_chr;
copymemory(@ppu_mem[$0],@mapper_nes.chr[valor,0],$2000);
end;

procedure mapper_4_update_chr(valor:byte);
var
  base:word;
begin
base:=(valor and $80) shl 5;
copymemory(@ppu_mem[base xor 0],@mapper_nes.chr[mapper_nes.dreg[0] shr 3,$400*(mapper_nes.dreg[0] and $6)],$800);
copymemory(@ppu_mem[base xor $800],@mapper_nes.chr[mapper_nes.dreg[1] shr 3,$400*(mapper_nes.dreg[1] and $6)],$800);
copymemory(@ppu_mem[base xor $1000],@mapper_nes.chr[mapper_nes.dreg[2] shr 3,$400*(mapper_nes.dreg[2] and $7)],$400);
copymemory(@ppu_mem[base xor $1400],@mapper_nes.chr[mapper_nes.dreg[3] shr 3,$400*(mapper_nes.dreg[3] and $7)],$400);
copymemory(@ppu_mem[base xor $1800],@mapper_nes.chr[mapper_nes.dreg[4] shr 3,$400*(mapper_nes.dreg[4] and $7)],$400);
copymemory(@ppu_mem[base xor $1c00],@mapper_nes.chr[mapper_nes.dreg[5] shr 3,$400*(mapper_nes.dreg[5] and $7)],$400);
end;

procedure mapper_4_update_prg(valor:byte);
var
  base:word;
begin
base:=(valor and $40) shl 8;
copymemory(@memoria[base xor $8000],@mapper_nes.prg[mapper_nes.dreg[6] shr 1,$2000*(mapper_nes.dreg[6] and 1)],$2000);
copymemory(@memoria[base xor $c000],@mapper_nes.prg[mapper_nes.last_prg,0],$2000);
copymemory(@memoria[$a000],@mapper_nes.prg[mapper_nes.dreg[7] shr 1,$2000*(mapper_nes.dreg[7] and 1)],$2000);
end;

procedure mapper_4_write_rom(direccion:word;valor:byte);
begin
direccion:=direccion and $e001;
case direccion of
  $8000:begin
          mapper_nes.reg[0]:=valor;  //command
          if ppu_chr_rom then mapper_4_update_chr(valor);
          mapper_4_update_prg(valor);
        end;
  $8001:begin
          case (mapper_nes.reg[0] and 7) of
            0..5:mapper_nes.dreg[mapper_nes.reg[0] and 7]:=valor mod ((mapper_nes.last_chr+1) shl 3);
            6,7:mapper_nes.dreg[mapper_nes.reg[0] and 7]:=valor mod ((mapper_nes.last_prg+1) shl 1);
          end;
          if ppu_chr_rom then mapper_4_update_chr(mapper_nes.reg[0]);
          mapper_4_update_prg(mapper_nes.reg[0]);
        end;
  $a000:if ppu_mirror<>MIRROR_FOUR_SCREEN then begin //Usado por Guntlet!!!
          if (valor and 1)=0 then ppu_mirror:=MIRROR_VERTICAL //Vertical
            else ppu_mirror:=MIRROR_HORIZONTAL; //Horizontal
        end;
  $a001:;
  $c000:mapper_nes.reg[2]:=valor;
  $c001:mapper_nes.reload:=true;
  $e000:begin
          mapper_nes.irq_ena:=false;
          main_m6502.pedir_irq:=CLEAR_LINE;
        end;
  $e001:mapper_nes.irq_ena:=true;
end;
end;

procedure mapper_4_line;
var
  count:word;
begin
  if ((mapper_nes.reg[1]=0) or mapper_nes.reload) then begin
    mapper_nes.reg[1]:=mapper_nes.reg[2];
    mapper_nes.reload:=false;
  end else begin
    count:=mapper_nes.reg[1];
    mapper_nes.reg[1]:=mapper_nes.reg[1]-1;
    if ((count<>0) and (mapper_nes.reg[1]=0)) then
        if mapper_nes.irq_ena then main_m6502.pedir_irq:=HOLD_LINE;
  end;
end;

procedure mapper_7_write_rom(direccion:word;valor:byte);
begin
valor:=(valor and $f) mod (mapper_nes.last_prg shr 1);
copymemory(@memoria[$8000],@mapper_nes.prg[valor shl 1,0],$4000);
copymemory(@memoria[$c000],@mapper_nes.prg[(valor shl 1)+1,0],$4000);
if (valor and $8)=0 then ppu_mirror:=MIRROR_SINGLE_0
  else ppu_mirror:=MIRROR_SINGLE_1;
end;

procedure mapper_66_write_rom(direccion:word;valor:byte);
var
  tempb:byte;
begin
tempb:=(valor and $f) mod mapper_nes.last_chr;
copymemory(@ppu_mem[0],@mapper_nes.chr[tempb,0],$2000);
tempb:=((valor and $f0) shr 4) mod (mapper_nes.last_prg shl 1);
copymemory(@memoria[$8000],@mapper_nes.prg[tempb shl 1,0],$4000);
copymemory(@memoria[$c000],@mapper_nes.prg[(tempb shl 1)+1,0],$4000);
end;

procedure mapper_87_write_rom(direccion:word;valor:byte);
begin
valor:=(valor shr 1) mod mapper_nes.last_chr;
copymemory(@ppu_mem[$0],@mapper_nes.chr[valor,0],$2000);
end;

end.
