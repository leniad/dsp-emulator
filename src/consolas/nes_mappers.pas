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
     nes_ppu,main_engine,n2a03,dialogs,ay_8910,sysutils;

type
  tnes_mapper_calls=record
           read_expansion:function(direccion:word):byte;
           write_expansion:procedure(direccion:word;valor:byte);
           read_prg_ram:function(direccion:word):byte;
           write_prg_ram:procedure(direccion:word;valor:byte);
           write_rom:procedure(direccion:word;valor:byte);
           read_rom:function(direccion:word):byte;
           line_ack:procedure(force:boolean);
           ppu_read:procedure(address:word);
           end;
  tnes_mapper=class
              constructor create;
              destructor free;
              public
                prg:array[0..31,0..$3fff] of byte;
                chr,prg_ram:array[0..63,0..$1fff] of byte;
                chr_map:array[0..1] of byte;
                mapper:word;
                submapper,last_prg,last_chr:byte;
                prg_ram_enable:boolean;
                calls:tnes_mapper_calls;
                procedure reset;
                function save_snapshot(data:pbyte):dword;
                procedure load_snapshot(data:pbyte);
                function set_mapper(mapper:word;submapper:byte):boolean;
              private
                regs:array[0..$30] of byte;
                dregs:array[0..15] of byte;
                shift,mode,serial_cnt,valor_map,latch0,latch1:byte;
                needirqdelay,reload_counter,counter:integer;
                forceclock,clock_mode,prg_ena,irq_ena,reload,chr_extra_ena,prg_ram_writeble:boolean;
                //mmc5
                ram:array[0..$3ff] of byte;
                mul1,mul2:byte;
           end;

//Mappers OK
//1,2,3,4,mmc6,7,9,10,11,13,15,18,34,42,66,67,68,71,87,93,94,180,185,221
//21,22,23,33,41,48,57,65,70,73,75,76,79,88,95,113,143,145,147,148,149,150,152,154,172,84,243
//A revisar
//12,89,116,mmc6
//Trabajando
//64,85
//Viendo
//32,105,206
//Estoy con ello!!
//5,58,69,132,133,137,139,142,173,212

var
  nes_mapper_0:tnes_mapper;

implementation
uses nes;

constructor tnes_mapper.create;
begin
end;

destructor tnes_mapper.free;
begin
end;

procedure prg_ram_write(direccion:word;valor:byte);
begin
  if not(nes_mapper_0.prg_ram_writeble) then exit;
  if not(nes_mapper_0.prg_ram_enable) then exit;
  memoria[direccion]:=valor;
end;

function prg_ram_read(direccion:word):byte;
begin
  if not(nes_mapper_0.prg_ram_enable) then prg_ram_read:=ppu_nes_0.open_bus
    else prg_ram_read:=memoria[direccion];
end;

function tnes_mapper.save_snapshot(data:pbyte):dword;
var
  temp:pbyte;
  buffer:array[0..32] of byte;
  size:dword;
begin
  temp:=data;
  copymemory(temp,@self.prg,sizeof(self.prg));
  size:=sizeof(self.prg);
  inc(temp,sizeof(self.prg));
  copymemory(temp,@self.chr,sizeof(self.chr));
  size:=size+sizeof(self.chr);
  inc(temp,sizeof(self.chr));
  copymemory(temp,@self.prg_ram,sizeof(self.prg_ram));
  size:=size+sizeof(self.prg_ram);
  inc(temp,sizeof(self.prg_ram));
  copymemory(temp,@self.regs,sizeof(self.regs));
  size:=size+sizeof(self.regs);
  inc(temp,sizeof(self.regs));
  copymemory(temp,@self.dregs,sizeof(self.dregs));
  size:=size+sizeof(self.dregs);
  inc(temp,sizeof(self.dregs));
  copymemory(temp,@self.chr_map,sizeof(self.chr_map));
  size:=size+sizeof(self.chr_map);
  inc(temp,sizeof(self.chr_map));
  copymemory(temp,@self.ram,sizeof(self.ram));
  size:=size+sizeof(self.ram);
  inc(temp,sizeof(self.ram));
  buffer[0]:=self.shift;
  buffer[1]:=self.mode;
  //buffer[2]:=self.cpu_count;
  buffer[3]:=self.serial_cnt;
  buffer[4]:=self.last_prg;
  buffer[5]:=self.last_chr;
  buffer[6]:=self.valor_map;
  buffer[7]:=self.latch0;
  buffer[8]:=self.latch1;
  buffer[9]:=self.mapper;
  copymemory(@buffer[9],@self.mapper,2);
  buffer[11]:=self.submapper;
  copymemory(@buffer[12],@self.needirqdelay,4);
  copymemory(@buffer[16],@self.reload_counter,4);
  copymemory(@buffer[20],@self.counter,4);
  buffer[24]:=byte(self.prg_ena);
  buffer[25]:=byte(self.clock_mode);
  buffer[26]:=byte(self.irq_ena);
  buffer[27]:=byte(self.reload);
  buffer[28]:=byte(self.chr_extra_ena);
  buffer[29]:=byte(self.prg_ram_writeble);
  buffer[30]:=byte(self.prg_ram_enable);
  buffer[31]:=self.mul1;
  buffer[32]:=self.mul2;
  copymemory(temp,@buffer[0],33);
  save_snapshot:=size+33;
end;

procedure tnes_mapper.load_snapshot(data:pbyte);
var
  temp:pbyte;
  buffer:array[0..32] of byte;
  size:word;
begin
  temp:=data;
  copymemory(@self.prg,temp,sizeof(self.prg));
  inc(temp,sizeof(self.prg));
  copymemory(@self.chr,temp,sizeof(self.chr));
  inc(temp,sizeof(self.chr));
  copymemory(@self.prg_ram,temp,sizeof(self.prg_ram));
  inc(temp,sizeof(self.prg_ram));
  copymemory(@self.regs,temp,sizeof(self.regs));
  inc(temp,sizeof(self.regs));
  copymemory(@self.dregs,temp,sizeof(self.dregs));
  inc(temp,sizeof(self.dregs));
  copymemory(@self.chr_map,temp,sizeof(self.chr_map));
  inc(temp,sizeof(self.chr_map));
  copymemory(@self.ram,temp,sizeof(self.ram));
  inc(temp,sizeof(self.ram));
  copymemory(@buffer[0],temp,33);
  self.shift:=buffer[0];
  self.mode:=buffer[1];
  //self.cpu_count:=buffer[2];
  self.serial_cnt:=buffer[3];
  self.last_prg:=buffer[4];
  self.last_chr:=buffer[5];
  self.valor_map:=buffer[6];
  self.latch0:=buffer[7];
  self.latch1:=buffer[8];
  copymemory(@self.mapper,@buffer[9],2);
  self.submapper:=buffer[11];
  copymemory(@self.needirqdelay,@buffer[12],4);
  copymemory(@self.reload_counter,@buffer[16],4);
  copymemory(@self.counter,@buffer[20],4);
  self.prg_ena:=buffer[24]<>0;
  self.clock_mode:=buffer[25]<>0;
  self.irq_ena:=buffer[26]<>0;
  self.reload:=buffer[27]<>0;
  self.chr_extra_ena:=buffer[28]<>0;
  self.prg_ram_writeble:=buffer[29]<>0;
  self.prg_ram_enable:=buffer[30]<>0;
  self.mul1:=buffer[31];
  self.mul2:=buffer[32];
end;

procedure set_prg_16(pos:word;bank:word);
var
  tempb:byte;
begin
  tempb:=bank mod nes_mapper_0.last_prg;
  copymemory(@memoria[pos],@nes_mapper_0.prg[tempb,0],$4000);
end;

procedure set_prg_32(bank:word);
var
  tempb:byte;
begin
  if nes_mapper_0.last_prg=1 then set_prg_16($8000,bank)
  else begin
    tempb:=(bank mod (nes_mapper_0.last_prg shr 1)) shl 1;
    copymemory(@memoria[$8000],@nes_mapper_0.prg[tempb,0],$4000);
    copymemory(@memoria[$c000],@nes_mapper_0.prg[tempb or 1,0],$4000);
  end;
end;

procedure set_prg_8(pos:word;bank:word);
var
  tempb:byte;
begin
  tempb:=bank mod (nes_mapper_0.last_prg shl 1);
  copymemory(@memoria[pos],@nes_mapper_0.prg[tempb shr 1,$2000*(tempb and 1)],$2000);
end;

procedure set_chr_8(bank:word);
var
  tempb:byte;
begin
  tempb:=bank mod nes_mapper_0.last_chr;
  copymemory(@ppu_nes_0.chr[nes_mapper_0.chr_map[0],0],@nes_mapper_0.chr[tempb,0],$1000);
  copymemory(@ppu_nes_0.chr[nes_mapper_0.chr_map[1],0],@nes_mapper_0.chr[tempb,$1000],$1000);
end;

procedure set_chr_4(pos:word;bank:word);
var
  tempb:byte;
begin
  tempb:=bank mod (nes_mapper_0.last_chr shl 1);
  copymemory(@ppu_nes_0.chr[nes_mapper_0.chr_map[(pos shr 12) and 1],0],@nes_mapper_0.chr[tempb shr 1,$1000*(tempb and 1)],$1000);
end;

procedure set_chr_2(pos:word;bank:word);
var
  tempb:byte;
begin
  tempb:=bank mod (nes_mapper_0.last_chr shl 2);
  copymemory(@ppu_nes_0.chr[nes_mapper_0.chr_map[(pos shr 12) and 1],$800*((pos shr 11) and 1)],@nes_mapper_0.chr[tempb shr 2,$800*(tempb and 3)],$800);
end;

procedure set_chr_1(pos:word;bank:word);
var
  tempb:byte;
begin
  tempb:=bank mod (nes_mapper_0.last_chr shl 3);
  copymemory(@ppu_nes_0.chr[nes_mapper_0.chr_map[(pos shr 12) and 1],$400*((pos shr 10) and 3)],@nes_mapper_0.chr[tempb shr 3,$400*(tempb and 7)],$400);
end;

procedure mapper_1_delay(estados_t:word);
begin
  nes_mapper_0.counter:=nes_mapper_0.counter+estados_t;
end;

//Mappers!
procedure mapper_1_chr;
begin
  if (nes_mapper_0.regs[0] and $10)<>0 then begin  //4kb
      if ppu_nes_0.write_chr then begin
        nes_mapper_0.chr_map[0]:=nes_mapper_0.regs[1];
        nes_mapper_0.chr_map[1]:=nes_mapper_0.regs[2];
        if ((nes_mapper_0.regs[1]>3) or (nes_mapper_0.regs[2]>3)) then begin
          MessageDlg('NES: Mapper 1 chr ram',mtInformation,[mbOk], 0);
        end;
      end else begin
        set_chr_4($0,nes_mapper_0.regs[1]);
        set_chr_4($1000,nes_mapper_0.regs[2]);
      end;
  end else begin //8Kb
      if ppu_nes_0.write_chr then begin
        nes_mapper_0.chr_map[0]:=0;
        nes_mapper_0.chr_map[1]:=1;
      end else begin
        set_chr_8((nes_mapper_0.regs[1] and $1f) shr 1);
      end;
  end;
end;

procedure mapper_1_prg;
var
  tempb,extra:byte;
begin
extra:=0;
//Usado por SxROM
if nes_mapper_0.last_prg>16 then extra:=nes_mapper_0.regs[1] and $10;
tempb:=((nes_mapper_0.regs[3] and $f) or extra) mod nes_mapper_0.last_prg;
case ((nes_mapper_0.regs[0] shr 2) and $3) of
    $0,$1:begin  //32Kb
        copymemory(@memoria[$8000],@nes_mapper_0.prg[tempb and $fe,0],$4000);
        copymemory(@memoria[$c000],@nes_mapper_0.prg[tempb or 1,0],$4000);
       end;
    $2:begin  //16k+16k --> primero fijo al banco 0
        copymemory(@memoria[$8000],@nes_mapper_0.prg[0 or extra,0],$4000);
        copymemory(@memoria[$c000],@nes_mapper_0.prg[tempb,0],$4000);
       end;
    $3:begin  //16k + 16k --> segundo fijo al ultimo banco que siempre es 15 o menos!!
        copymemory(@memoria[$8000],@nes_mapper_0.prg[tempb,0],$4000);
        copymemory(@memoria[$c000],@nes_mapper_0.prg[($f or extra) mod nes_mapper_0.last_prg,0],$4000);
       end;
end;
if nes_mapper_0.submapper=0 then nes_mapper_0.prg_ram_enable:=(nes_mapper_0.regs[3] and $10)=0;
end;

procedure mapper_1_write_rom(direccion:word;valor:byte);
begin
if ((nes_mapper_0.counter<2) and (nes_mapper_0.serial_cnt=0)) then exit;
if (valor and $80)<>0 then begin
  //Reset!!
  nes_mapper_0.serial_cnt:=0;
  nes_mapper_0.valor_map:=0;
  //ATENCION --> Necesario para 'Robocop 3'
  nes_mapper_0.regs[0]:=nes_mapper_0.regs[0] or $c;
  nes_mapper_0.counter:=0;
  copymemory(@memoria[$c000],@nes_mapper_0.prg[$f mod nes_mapper_0.last_prg,0],$4000);
end else begin
  nes_mapper_0.valor_map:=nes_mapper_0.valor_map or ((valor and 1) shl nes_mapper_0.serial_cnt);
  nes_mapper_0.serial_cnt:=nes_mapper_0.serial_cnt+1;
  nes_mapper_0.counter:=0;
  if nes_mapper_0.serial_cnt=5 then begin
    nes_mapper_0.regs[(direccion shr 13) and 3]:=nes_mapper_0.valor_map;
    case (nes_mapper_0.regs[0] and 3) of //Mirror
      0:ppu_nes_0.mirror:=MIRROR_LOW;
      1:ppu_nes_0.mirror:=MIRROR_HIGH;
      2:ppu_nes_0.mirror:=MIRROR_VERTICAL;
      3:ppu_nes_0.mirror:=MIRROR_HORIZONTAL;
    end;
    mapper_1_chr;
    mapper_1_prg;
    nes_mapper_0.valor_map:=0;
    nes_mapper_0.serial_cnt:=0;
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
if not(ppu_nes_0.write_chr) then begin
  //Las paginas de CHR son de 1K siempre!! Cuando copia 2K copia 1K+1K
  base_chr:=(valor and $80) shl 5;
  set_chr_1($0 xor base_chr,nes_mapper_0.dregs[0] and $fe);
  set_chr_1($400 xor base_chr,nes_mapper_0.dregs[0] or 1);
  set_chr_1($800 xor base_chr,nes_mapper_0.dregs[1] and $fe);
  set_chr_1($c00 xor base_chr,nes_mapper_0.dregs[1] or 1);
  set_chr_1($1000 xor base_chr,nes_mapper_0.dregs[2]);
  set_chr_1($1400 xor base_chr,nes_mapper_0.dregs[3]);
  set_chr_1($1800 xor base_chr,nes_mapper_0.dregs[4]);
  set_chr_1($1c00 xor base_chr,nes_mapper_0.dregs[5]);
end;
end;

procedure mapper_4_update_prg(valor:byte);
var
  temp1,temp2:byte;
begin
temp1:=nes_mapper_0.dregs[6] mod (nes_mapper_0.last_prg shl 1);
temp2:=nes_mapper_0.dregs[7] mod (nes_mapper_0.last_prg shl 1);
set_prg_8($a000,temp2);
if (valor and $40)=0 then begin
  set_prg_8($8000,temp1);
  set_prg_8($c000,(nes_mapper_0.last_prg shl 1)-2);
end else begin
  set_prg_8($8000,(nes_mapper_0.last_prg shl 1)-2);
  set_prg_8($c000,temp1);
end;
end;

procedure mapper_4_write_rom(direccion:word;valor:byte);
begin
case (direccion and $e001) of
  $8000:begin
          if ((valor and $40)<>(nes_mapper_0.regs[0] and $40)) then mapper_4_update_prg(valor);
		      if ((valor and $80)<>(nes_mapper_0.regs[0] and $80)) then mapper_4_update_chr(valor);
          nes_mapper_0.regs[0]:=valor;
        end;
  $8001:begin
          if (nes_mapper_0.regs[0] and 7)<2 then valor:=valor and $fe;
          nes_mapper_0.dregs[nes_mapper_0.regs[0] and 7]:=valor;
          mapper_4_update_prg(nes_mapper_0.regs[0]);
          mapper_4_update_chr(nes_mapper_0.regs[0]);
        end;
  $a000:if ppu_nes_0.mirror<>MIRROR_FOUR_SCREEN then begin //Usado por Gauntlet!!!
          if (valor and 1)=0 then ppu_nes_0.mirror:=MIRROR_VERTICAL
            else ppu_nes_0.mirror:=MIRROR_HORIZONTAL;
        end;
  $a001:begin
          nes_mapper_0.prg_ram_enable:=(valor and $80)<>0;
          nes_mapper_0.prg_ram_writeble:=(valor and $40)=0;
          nes_mapper_0.regs[3]:=valor;
        end;
  $c000:nes_mapper_0.regs[2]:=valor;
  $c001:nes_mapper_0.reload:=true;
  $e000:begin
             nes_mapper_0.irq_ena:=false;
             n2a03_0.m6502.change_irq(CLEAR_LINE);
        end;
  $e001:nes_mapper_0.irq_ena:=true;
end;
end;

procedure mapper_4_line(force:boolean);
begin
//IMPORTANTE: Revisar Gauntlet II si toco algo
//if ((ppu_nes_0.linea<240) or (ppu_nes_0.linea=261) or force) then begin
if (ppu_nes_0.control2 and $18)<>0 then begin //IMPORTANTE KingQuest V quiere esto
  if ((nes_mapper_0.counter=0) or nes_mapper_0.reload) then begin
    nes_mapper_0.counter:=nes_mapper_0.regs[2];
    nes_mapper_0.reload:=false;
  end else nes_mapper_0.counter:=nes_mapper_0.counter-1;
  if (nes_mapper_0.counter=0) then begin
    nes_mapper_0.reload:=true;
    if nes_mapper_0.irq_ena then n2a03_0.m6502.change_irq(ASSERT_LINE);
  end;
end;
end;

procedure mapper_5_update_prg;
begin
case (nes_mapper_0.regs[0] and 3) of
  0:set_prg_32((nes_mapper_0.regs[$17] and $7f) shr 2); //32k
  1:begin //16k+16k
      set_prg_16($8000,(nes_mapper_0.regs[$15] and $7f) shr 1);
      set_prg_16($c000,(nes_mapper_0.regs[$17] and $7f) shr 1);
    end;
  2:begin //16k+8k+8k
      set_prg_16($8000,(nes_mapper_0.regs[$15] and $7f) shr 1);
      set_prg_8($c000,nes_mapper_0.regs[$16] and $7f);
      set_prg_8($e000,nes_mapper_0.regs[$17] and $7f);
    end;
  3:begin //8k+8k+8k+8k
      set_prg_8($8000,nes_mapper_0.regs[$14] and $7f);
      set_prg_8($a000,nes_mapper_0.regs[$15] and $7f);
      set_prg_8($c000,nes_mapper_0.regs[$16] and $7f);
      set_prg_8($e000,nes_mapper_0.regs[$17] and $7f);
    end;
end;
end;

procedure mapper_5_update_chr;
begin
case (nes_mapper_0.regs[1] and 3) of
    0:set_chr_8(nes_mapper_0.regs[$27]);  //8k
    1:begin //4k
        set_chr_4(0,nes_mapper_0.regs[$23]);
        set_chr_4($1000,nes_mapper_0.regs[$27]);
      end;
    2:begin //2k
        set_chr_2(0,nes_mapper_0.regs[$21]);
        set_chr_2($800,nes_mapper_0.regs[$23]);
        set_chr_2($1000,nes_mapper_0.regs[$25]);
        set_chr_2($1800,nes_mapper_0.regs[$27]);
      end;
    3:begin //1k
        set_chr_1(0,nes_mapper_0.regs[$20]);
        set_chr_1($400,nes_mapper_0.regs[$21]);
        set_chr_1($800,nes_mapper_0.regs[$22]);
        set_chr_1($c00,nes_mapper_0.regs[$23]);
        set_chr_1($1000,nes_mapper_0.regs[$24]);
        set_chr_1($1400,nes_mapper_0.regs[$25]);
        set_chr_1($1800,nes_mapper_0.regs[$26]);
        set_chr_1($1c00,nes_mapper_0.regs[$27]);
      end;
end;
end;

procedure mapper_5_update_chr_high;
begin
  case (nes_mapper_0.regs[1] and 3) of
      0:set_chr_8(nes_mapper_0.regs[$2b]);  //8k
      1:begin //4k
          set_chr_4(0,nes_mapper_0.regs[$2b]);
          set_chr_4($1000,nes_mapper_0.regs[$2b]);
        end;
      2:begin //2k
         set_chr_2(0,nes_mapper_0.regs[$29]);
         set_chr_2($800,nes_mapper_0.regs[$2b]);
         set_chr_2($1000,nes_mapper_0.regs[$29]);
         set_chr_2($1800,nes_mapper_0.regs[$2b]);
        end;
      3:begin //1k
          set_chr_1(0,nes_mapper_0.regs[$28]);
          set_chr_1($400,nes_mapper_0.regs[$29]);
          set_chr_1($800,nes_mapper_0.regs[$2a]);
          set_chr_1($c00,nes_mapper_0.regs[$2b]);
          set_chr_1($1000,nes_mapper_0.regs[$28]);
          set_chr_1($1400,nes_mapper_0.regs[$29]);
          set_chr_1($1800,nes_mapper_0.regs[$2a]);
          set_chr_1($1c00,nes_mapper_0.regs[$2b]);
        end;
  end;
end;

function mapper_5_read_extended(direccion:word):byte;
begin
case direccion of
  5205:mapper_5_read_extended:=(nes_mapper_0.mul1*nes_mapper_0.mul2) and $ff;
  5206:mapper_5_read_extended:=(nes_mapper_0.mul1*nes_mapper_0.mul2) shr 8;
end;
end;

procedure mapper_5_write_extended(direccion:word;valor:byte);
begin
case direccion of
  $5100..$5112,$5118..$511f,$512c..$5130:nes_mapper_0.regs[direccion and $3f]:=valor;
  $5113..$5117:begin
                  nes_mapper_0.regs[direccion and $3f]:=valor;
                  mapper_5_update_prg;
               end;
  $5120..$512b:begin
                  nes_mapper_0.regs[direccion and $3f]:=valor;
                  mapper_5_update_chr;
               end;
  $5205:nes_mapper_0.mul1:=valor;
  $5206:nes_mapper_0.mul2:=valor;
end;
end;

procedure mapper_5_write_rom(direccion:word;valor:byte);
begin
case (nes_mapper_0.regs[0] and 3) of
  0:; //32k todo ROM
  1:case direccion of
        $8000..$9fff:if (nes_mapper_0.regs[$15] and $80)=0 then nes_mapper_0.prg_ram[nes_mapper_0.regs[$15] and $e,direccion and $1fff]:=valor;
        $a000..$bfff:if (nes_mapper_0.regs[$15] and $80)=0 then nes_mapper_0.prg_ram[(nes_mapper_0.regs[$15] and $e) or 1,direccion and $1fff]:=valor;
        $c000..$ffff:;
    end;
  2:case direccion of
        $8000..$9fff:if (nes_mapper_0.regs[$15] and $80)=0 then nes_mapper_0.prg_ram[nes_mapper_0.regs[$15] and $e,direccion and $1fff]:=valor;
        $a000..$bfff:if (nes_mapper_0.regs[$15] and $80)=0 then nes_mapper_0.prg_ram[(nes_mapper_0.regs[$15] and $e) or 1,direccion and $1fff]:=valor;
        $c000..$dfff:if (nes_mapper_0.regs[$16] and $80)=0 then nes_mapper_0.prg_ram[nes_mapper_0.regs[$16] and $f,direccion and $1fff]:=valor;
        $e000..$ffff:;
    end;
  3:case direccion of
        $8000..$9fff:if (nes_mapper_0.regs[$14] and $80)=0 then nes_mapper_0.prg_ram[nes_mapper_0.regs[$14] and $f,direccion and $1fff]:=valor;
        $a000..$bfff:if (nes_mapper_0.regs[$15] and $80)=0 then nes_mapper_0.prg_ram[nes_mapper_0.regs[$15] and $f,direccion and $1fff]:=valor;
        $c000..$dfff:if (nes_mapper_0.regs[$16] and $80)=0 then nes_mapper_0.prg_ram[nes_mapper_0.regs[$16] and $f,direccion and $1fff]:=valor;
        $e000..$ffff:;
    end;
end;
end;

function mapper_5_read_rom(direccion:word):byte;
begin
case (nes_mapper_0.regs[0] and 3) of
  0:mapper_5_read_rom:=memoria[direccion];
  1:case direccion of
        $8000..$9fff:if (nes_mapper_0.regs[$15] and $80)=0 then mapper_5_read_rom:=nes_mapper_0.prg_ram[nes_mapper_0.regs[$15] and $e,direccion and $1fff]
                        else mapper_5_read_rom:=memoria[direccion];
        $a000..$bfff:if (nes_mapper_0.regs[$15] and $80)=0 then mapper_5_read_rom:=nes_mapper_0.prg_ram[(nes_mapper_0.regs[$15] and $e) or 1,direccion and $1fff]
                      else mapper_5_read_rom:=memoria[direccion];
        $c000..$ffff:mapper_5_read_rom:=memoria[direccion];
    end;
  2:case direccion of
        $8000..$9fff:if (nes_mapper_0.regs[$15] and $80)=0 then mapper_5_read_rom:=nes_mapper_0.prg_ram[nes_mapper_0.regs[$15] and $e,direccion and $1fff]
                      else mapper_5_read_rom:=memoria[direccion];
        $a000..$bfff:if (nes_mapper_0.regs[$15] and $80)=0 then mapper_5_read_rom:=nes_mapper_0.prg_ram[(nes_mapper_0.regs[$15] and $e) or 1,direccion and $1fff]
                      else mapper_5_read_rom:=memoria[direccion];
        $c000..$dfff:if (nes_mapper_0.regs[$16] and $80)=0 then mapper_5_read_rom:=nes_mapper_0.prg_ram[nes_mapper_0.regs[$16] and $f,direccion and $1fff]
                      else mapper_5_read_rom:=memoria[direccion];
        $e000..$ffff:mapper_5_read_rom:=memoria[direccion];
    end;
  3:case direccion of
        $8000..$9fff:if (nes_mapper_0.regs[$14] and $80)=0 then mapper_5_read_rom:=nes_mapper_0.prg_ram[nes_mapper_0.regs[$14] and $f,direccion and $1fff]
                      else mapper_5_read_rom:=memoria[direccion];
        $a000..$bfff:if (nes_mapper_0.regs[$15] and $80)=0 then mapper_5_read_rom:=nes_mapper_0.prg_ram[nes_mapper_0.regs[$15] and $f,direccion and $1fff]
                      else mapper_5_read_rom:=memoria[direccion];
        $c000..$dfff:if (nes_mapper_0.regs[$16] and $80)=0 then mapper_5_read_rom:=nes_mapper_0.prg_ram[nes_mapper_0.regs[$16] and $f,direccion and $1fff]
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
          if ((valor and $40)<>(nes_mapper_0.regs[0] and $40)) then mapper_4_update_prg(valor);
		      if ((valor and $80)<>(nes_mapper_0.regs[0] and $80)) then mapper_4_update_chr(valor);
          nes_mapper_0.prg_ram_enable:=(valor and $20)<>0;
          nes_mapper_0.regs[0]:=valor;
        end;
  $8001:begin
          nes_mapper_0.dregs[nes_mapper_0.regs[0] and 7]:=valor;
          mapper_4_update_prg(nes_mapper_0.regs[0]);
          mapper_4_update_chr(nes_mapper_0.regs[0]);
        end;
  $a000:if ppu_nes_0.mirror<>MIRROR_FOUR_SCREEN then begin
          if (valor and 1)=0 then ppu_nes_0.mirror:=MIRROR_VERTICAL
            else ppu_nes_0.mirror:=MIRROR_HORIZONTAL;
        end;
  $a001:nes_mapper_0.regs[3]:=valor; //Especifico de MMC6
  $c000:nes_mapper_0.regs[2]:=valor;
  $c001:nes_mapper_0.reload:=true;
  $e000:begin
             nes_mapper_0.irq_ena:=false;
             n2a03_0.m6502.change_irq(CLEAR_LINE);
        end;
  $e001:nes_mapper_0.irq_ena:=true;
end;
end;

function mapper_mmc6_wram_read(direccion:word):byte;
begin
if (not(nes_mapper_0.prg_ram_enable) or ((nes_mapper_0.regs[3] and $a0)=0)) then begin //Si esta disabled o si estan desabilitados los dos bancos --> open bus
  mapper_mmc6_wram_read:=direccion and $ff;
  exit;
end;
case direccion of
  $6000..$6fff:mapper_mmc6_wram_read:=direccion and $ff;
  $7000..$71ff,$7400..$75ff,$7800..$79ff,$7c00..$7dff:if ((nes_mapper_0.regs[3] and $20)<>0) then mapper_mmc6_wram_read:=memoria[$7000+(direccion and $1ff)]
                                                        else mapper_mmc6_wram_read:=0;
  $7200..$73ff,$7600..$77ff,$7a00..$7bff,$7e00..$7fff:if ((nes_mapper_0.regs[3] and $80)<>0) then mapper_mmc6_wram_read:=memoria[$7200+(direccion and $1ff)]
                                                        else mapper_mmc6_wram_read:=0;
end;
end;

procedure mapper_mmc6_wram_write(direccion:word;valor:byte);
begin
if not(nes_mapper_0.prg_ram_enable) then exit; //Si esta disabled, no hago nada
case direccion of
  $6000..$6fff:;
  $7000..$71ff,$7400..$75ff,$7800..$79ff,$7c00..$7dff:if ((nes_mapper_0.regs[3] and $30)=$30) then memoria[$7000+(direccion and $1ff)]:=valor;
  $7200..$73ff,$7600..$77ff,$7a00..$7bff,$7e00..$7fff:if ((nes_mapper_0.regs[3] and $c0)=$c0) then memoria[$7200+(direccion and $1ff)]:=valor;
end;
end;

procedure mapper_7_write_rom(direccion:word;valor:byte);
begin
set_prg_32(valor and $f);
if (valor and $10)=0 then ppu_nes_0.mirror:=MIRROR_LOW
  else ppu_nes_0.mirror:=MIRROR_HIGH;
end;

procedure mapper_9_write_rom(direccion:word;valor:byte);
begin
case (direccion shr 12) of
  $a:set_prg_8($8000,valor and $f);
  $b:begin
        nes_mapper_0.regs[0]:=valor and $1f;
        if (nes_mapper_0.latch0=$fd) then set_chr_4($0,valor and $1f);
     end;
  $c:begin
        nes_mapper_0.regs[1]:=valor and $1f;
        if (nes_mapper_0.latch0=$fe) then set_chr_4($0,valor and $1f);
     end;
  $d:begin
        nes_mapper_0.regs[2]:=valor and $1f;
        if (nes_mapper_0.latch1=$fd) then set_chr_4($1000,valor and $1f);
     end;
  $e:begin
        nes_mapper_0.regs[3]:=valor and $1f;
        if (nes_mapper_0.latch1=$fe) then set_chr_4($1000,valor and $1f);
     end;
  $f:if (valor and 1)<>0 then ppu_nes_0.mirror:=MIRROR_HORIZONTAL
        else ppu_nes_0.mirror:=MIRROR_VERTICAL;
end;
end;

procedure mapper_9_ppu_read(direccion:word);
begin
case (direccion and $3ff0) of
  $0fd0:begin
          nes_mapper_0.latch0:=$fd;
          set_chr_4($0,nes_mapper_0.regs[0]);
       end;
  $0fe0:begin
          nes_mapper_0.latch0:=$fe;
          set_chr_4($0,nes_mapper_0.regs[1]);
       end;
  $1fd0:begin
          nes_mapper_0.latch1:=$fd;
          set_chr_4($1000,nes_mapper_0.regs[2]);
        end;
  $1fe0:begin
          nes_mapper_0.latch1:=$fe;
          set_chr_4($1000,nes_mapper_0.regs[3]);
        end;
end;
end;
procedure mapper_10_write_rom(direccion:word;valor:byte);
begin
case ((direccion shr 12) and 7) of
  $2:set_prg_16($8000,valor and $f);
  $3:begin
        nes_mapper_0.regs[0]:=valor and $1f;
        if (nes_mapper_0.latch0=$fd) then set_chr_4($0,valor and $1f);
     end;
  $4:begin
        nes_mapper_0.regs[1]:=valor and $1f;
        if (nes_mapper_0.latch0=$fe) then set_chr_4($0,valor and $1f);
     end;
  $5:begin
        nes_mapper_0.regs[2]:=valor and $1f;
        if (nes_mapper_0.latch1=$fd) then set_chr_4($1000,valor and $1f);
     end;
  $6:begin
        nes_mapper_0.regs[3]:=valor and $1f;
        if (nes_mapper_0.latch1=$fe) then set_chr_4($1000,valor and $1f);
     end;
  $7:if (valor and 1)<>0 then ppu_nes_0.mirror:=MIRROR_HORIZONTAL
        else ppu_nes_0.mirror:=MIRROR_VERTICAL;
end;
end;
procedure mapper_11_write_rom(direccion:word;valor:byte);
begin
  set_prg_32(valor and $3);
  if nes_mapper_0.last_chr<>0 then set_chr_8(valor shr 4);
end;
procedure mapper_12_write_rom(direccion:word;valor:byte);
begin
case direccion of
  $4000..$5fff:nes_mapper_0.latch1:=valor;
  else mapper_4_write_rom(direccion,valor);
end;
end;
procedure mapper_13_write_rom(direccion:word;valor:byte);
begin
  nes_mapper_0.chr_map[1]:=valor and 3;
end;

procedure mapper_15_write_rom(direccion:word;valor:byte);
var
  tempb:byte;
begin
tempb:=(valor and $3f) mod nes_mapper_0.last_prg;
case (direccion and 3) of
    0:begin //32k banks
        copymemory(@memoria[$8000],@nes_mapper_0.prg[tempb,0],$4000);
        copymemory(@memoria[$c000],@nes_mapper_0.prg[tempb or 1,0],$4000);
      end;
    1:begin //128k
        copymemory(@memoria[$8000],@nes_mapper_0.prg[tempb,0],$4000);
        tempb:=((valor and $3f) or 7) mod nes_mapper_0.last_prg;
        copymemory(@memoria[$c000],@nes_mapper_0.prg[tempb,0],$4000);
      end;
    2:begin //8kb banks
        copymemory(@memoria[$8000],@nes_mapper_0.prg[tempb,$2000*((valor and $80) shr 7)],$2000);
        //Mirrors!!
        copymemory(@memoria[$a000],@memoria[$8000],$2000);
        copymemory(@memoria[$c000],@memoria[$8000],$2000);
        copymemory(@memoria[$e000],@memoria[$8000],$2000);
      end;
    3:begin //16k banks
        copymemory(@memoria[$8000],@nes_mapper_0.prg[tempb,0],$4000);
        //Mirrors!!
        copymemory(@memoria[$c000],@memoria[$8000],$4000);
      end;
  end;
  if (valor and $40)=0 then ppu_nes_0.mirror:=MIRROR_VERTICAL
    else ppu_nes_0.mirror:=MIRROR_HORIZONTAL;
end;

procedure mapper_18_write_rom(direccion:word;valor:byte);
begin
case (direccion and $f003) of
  $8000:begin
          nes_mapper_0.regs[0]:=(nes_mapper_0.regs[0] and $f0) or (valor and $f);
          set_prg_8($8000,nes_mapper_0.regs[0]);
        end;
  $8001:begin
          nes_mapper_0.regs[0]:=(nes_mapper_0.regs[0] and $f) or ((valor and $f) shl 4);
          set_prg_8($8000,nes_mapper_0.regs[0]);
        end;
  $8002:begin
          nes_mapper_0.regs[1]:=(nes_mapper_0.regs[1] and $f0) or (valor and $f);
          set_prg_8($a000,nes_mapper_0.regs[1]);
        end;
  $8003:begin
          nes_mapper_0.regs[1]:=(nes_mapper_0.regs[1] and $f) or ((valor and $f) shl 4);
          set_prg_8($a000,nes_mapper_0.regs[1]);
        end;
  $9000:begin
          nes_mapper_0.regs[2]:=(nes_mapper_0.regs[2] and $f0) or (valor and $f);
          set_prg_8($c000,nes_mapper_0.regs[2]);
        end;
  $9001:begin
          nes_mapper_0.regs[2]:=(nes_mapper_0.regs[2] and $f) or ((valor and $f) shl 4);
          set_prg_8($c000,nes_mapper_0.regs[2]);
        end;
  $a000:begin
          nes_mapper_0.dregs[0]:=(nes_mapper_0.dregs[0] and $f0) or (valor and $f);
          set_chr_1($0,nes_mapper_0.dregs[0]);
        end;
  $a001:begin
          nes_mapper_0.dregs[0]:=(nes_mapper_0.dregs[0] and $f) or ((valor and $f) shl 4);
          set_chr_1($0,nes_mapper_0.dregs[0]);
        end;
  $a002:begin
          nes_mapper_0.dregs[1]:=(nes_mapper_0.dregs[1] and $f0) or (valor and $f);
          set_chr_1($400,nes_mapper_0.dregs[1]);
        end;
  $a003:begin
          nes_mapper_0.dregs[1]:=(nes_mapper_0.dregs[1] and $f) or ((valor and $f) shl 4);
          set_chr_1($400,nes_mapper_0.dregs[1]);
        end;
  $b000:begin
          nes_mapper_0.dregs[2]:=(nes_mapper_0.dregs[2] and $f0) or (valor and $f);
          set_chr_1($800,nes_mapper_0.dregs[2]);
        end;
  $b001:begin
          nes_mapper_0.dregs[2]:=(nes_mapper_0.dregs[2] and $f) or ((valor and $f) shl 4);
          set_chr_1($800,nes_mapper_0.dregs[2]);
        end;
  $b002:begin
          nes_mapper_0.dregs[3]:=(nes_mapper_0.dregs[3] and $f0) or (valor and $f);
          set_chr_1($c00,nes_mapper_0.dregs[3]);
        end;
  $b003:begin
          nes_mapper_0.dregs[3]:=(nes_mapper_0.dregs[3] and $f) or ((valor and $f) shl 4);
          set_chr_1($c00,nes_mapper_0.dregs[3]);
        end;
  $c000:begin
          nes_mapper_0.dregs[4]:=(nes_mapper_0.dregs[4] and $f0) or (valor and $f);
          set_chr_1($1000,nes_mapper_0.dregs[4]);
        end;
  $c001:begin
          nes_mapper_0.dregs[4]:=(nes_mapper_0.dregs[4] and $f) or ((valor and $f) shl 4);
          set_chr_1($1000,nes_mapper_0.dregs[4]);
        end;
  $c002:begin
          nes_mapper_0.dregs[5]:=(nes_mapper_0.dregs[5] and $f0) or (valor and $f);
          set_chr_1($1400,nes_mapper_0.dregs[5]);
        end;
  $c003:begin
          nes_mapper_0.dregs[5]:=(nes_mapper_0.dregs[5] and $f) or ((valor and $f) shl 4);
          set_chr_1($1400,nes_mapper_0.dregs[5]);
        end;
  $d000:begin
          nes_mapper_0.dregs[6]:=(nes_mapper_0.dregs[6] and $f0) or (valor and $f);
          set_chr_1($1800,nes_mapper_0.dregs[6]);
        end;
  $d001:begin
          nes_mapper_0.dregs[6]:=(nes_mapper_0.dregs[6] and $f) or ((valor and $f) shl 4);
          set_chr_1($1800,nes_mapper_0.dregs[6]);
        end;
  $d002:begin
          nes_mapper_0.dregs[7]:=(nes_mapper_0.dregs[7] and $f0) or (valor and $f);
          set_chr_1($1c00,nes_mapper_0.dregs[7]);
        end;
  $d003:begin
          nes_mapper_0.dregs[7]:=(nes_mapper_0.dregs[7] and $f) or ((valor and $f) shl 4);
          set_chr_1($1c00,nes_mapper_0.dregs[7]);
        end;
  $e000:nes_mapper_0.reload_counter:=(nes_mapper_0.reload_counter and $fff0) or (valor and $f);
  $e001:nes_mapper_0.reload_counter:=(nes_mapper_0.reload_counter and $ff0f) or ((valor and $f) shl 4);
  $e002:nes_mapper_0.reload_counter:=(nes_mapper_0.reload_counter and $f0ff) or ((valor and $f) shl 8);
  $e003:nes_mapper_0.reload_counter:=(nes_mapper_0.reload_counter and $0fff) or ((valor and $f) shl 12);
  $f000:begin
          nes_mapper_0.counter:=nes_mapper_0.reload_counter;
          n2a03_0.m6502.change_irq(CLEAR_LINE);
        end;
  $f001:begin
          nes_mapper_0.irq_ena:=(valor and 1)<>0;
          nes_mapper_0.regs[3]:=(valor shr 1) and 7;
          n2a03_0.m6502.change_irq(CLEAR_LINE);
        end;
  $f002:case (valor and 3) of
          0:ppu_nes_0.mirror:=MIRROR_HORIZONTAL;
          1:ppu_nes_0.mirror:=MIRROR_VERTICAL;
          2:ppu_nes_0.mirror:=MIRROR_LOW;
          3:ppu_nes_0.mirror:=MIRROR_HIGH;
        end;
  // $f003:UPD7756;
end;
end;

procedure mapper_18_irq(estados_t:word);
var
  temp:integer;
begin
if nes_mapper_0.irq_ena then begin
  case nes_mapper_0.regs[3] of
    0:begin //16bits
          nes_mapper_0.counter:=nes_mapper_0.counter-estados_t;
          if nes_mapper_0.counter<0 then begin
            n2a03_0.m6502.change_irq(ASSERT_LINE);
            nes_mapper_0.counter:=nes_mapper_0.counter+$ffff;
          end;
      end;
    1:begin //12bits
          temp:=nes_mapper_0.counter and $fff;
          temp:=temp-estados_t;
          if temp<0 then begin
            n2a03_0.m6502.change_irq(ASSERT_LINE);
            temp:=temp+$fff;
          end;
          nes_mapper_0.counter:=(nes_mapper_0.counter and $f000) or (temp and $fff)
      end;
    2,3:begin //8bits
          temp:=nes_mapper_0.counter and $ff;
          temp:=temp-estados_t;
          if temp<0 then begin
            n2a03_0.m6502.change_irq(ASSERT_LINE);
            temp:=temp+$ff;
          end;
          nes_mapper_0.counter:=(nes_mapper_0.counter and $ff00) or (temp and $ff)
      end;
    4..7:begin //4bits
          temp:=nes_mapper_0.counter and $f;
          temp:=temp-estados_t;
          if temp<0 then begin
            n2a03_0.m6502.change_irq(ASSERT_LINE);
            temp:=temp+$f;
          end;
          nes_mapper_0.counter:=(nes_mapper_0.counter and $fff0) or (temp and $f)
      end;
  end;
end;
end;

procedure mapper_22_write_rom(direccion:word;valor:byte);
begin
  direccion:=(direccion and $fffc) or ((direccion and 1) shl 1) or ((direccion and 2) shr 1);
  case (direccion and $f003) of
    $8000..$8003:set_prg_8($8000,valor and $1f);
    $9000..$9003:if (valor and 1)<>0 then ppu_nes_0.mirror:=MIRROR_HORIZONTAL
                    else ppu_nes_0.mirror:=MIRROR_VERTICAL;
    $a000..$a003:set_prg_8($a000,valor and $1f);
    $b000:begin
            nes_mapper_0.dregs[0]:=valor and $f;
            set_chr_1($0,(nes_mapper_0.dregs[0] or (nes_mapper_0.dregs[1] shl 4)) shr 1);
          end;
    $b001:begin
            nes_mapper_0.dregs[1]:=valor and $1f;
            set_chr_1($0,(nes_mapper_0.dregs[0] or (nes_mapper_0.dregs[1] shl 4)) shr 1);
          end;
    $b002:begin
            nes_mapper_0.dregs[2]:=valor and $f;
            set_chr_1($400,(nes_mapper_0.dregs[2] or (nes_mapper_0.dregs[3] shl 4)) shr 1);
          end;
    $b003:begin
            nes_mapper_0.dregs[3]:=valor and $1f;
            set_chr_1($400,(nes_mapper_0.dregs[2] or (nes_mapper_0.dregs[3] shl 4)) shr 1);
          end;
    $c000:begin
            nes_mapper_0.dregs[4]:=valor and $f;
            set_chr_1($800,(nes_mapper_0.dregs[4] or (nes_mapper_0.dregs[5] shl 4)) shr 1);
          end;
    $c001:begin
            nes_mapper_0.dregs[5]:=valor and $1f;
            set_chr_1($800,(nes_mapper_0.dregs[4] or (nes_mapper_0.dregs[5] shl 4)) shr 1);
          end;
    $c002:begin
            nes_mapper_0.dregs[6]:=valor and $f;
            set_chr_1($c00,(nes_mapper_0.dregs[6] or (nes_mapper_0.dregs[7] shl 4)) shr 1);
          end;
    $c003:begin
            nes_mapper_0.dregs[7]:=valor and $1f;
            set_chr_1($c00,(nes_mapper_0.dregs[6] or (nes_mapper_0.dregs[7] shl 4)) shr 1);
          end;
    $d000:begin
            nes_mapper_0.dregs[8]:=valor and $f;
            set_chr_1($1000,(nes_mapper_0.dregs[8] or (nes_mapper_0.dregs[9] shl 4)) shr 1);
          end;
    $d001:begin
            nes_mapper_0.dregs[9]:=valor and $1f;
            set_chr_1($1000,(nes_mapper_0.dregs[8] or (nes_mapper_0.dregs[9] shl 4)) shr 1);
          end;
    $d002:begin
            nes_mapper_0.dregs[10]:=valor and $f;
            set_chr_1($1400,(nes_mapper_0.dregs[10] or (nes_mapper_0.dregs[11] shl 4)) shr 1);
          end;
    $d003:begin
            nes_mapper_0.dregs[11]:=valor and $1f;
            set_chr_1($1400,(nes_mapper_0.dregs[10] or (nes_mapper_0.dregs[11] shl 4)) shr 1);
          end;
    $e000:begin
            nes_mapper_0.dregs[12]:=valor and $f;
            set_chr_1($1800,(nes_mapper_0.dregs[12] or (nes_mapper_0.dregs[13] shl 4)) shr 1);
          end;
    $e001:begin
            nes_mapper_0.dregs[13]:=valor and $1f;
            set_chr_1($1800,(nes_mapper_0.dregs[12] or (nes_mapper_0.dregs[13] shl 4)) shr 1);
          end;
    $e002:begin
            nes_mapper_0.dregs[14]:=valor and $f;
            set_chr_1($1c00,(nes_mapper_0.dregs[14] or (nes_mapper_0.dregs[15] shl 4)) shr 1);
          end;
    $e003:begin
            nes_mapper_0.dregs[15]:=valor and $1f;
            set_chr_1($1c00,(nes_mapper_0.dregs[14] or (nes_mapper_0.dregs[15] shl 4)) shr 1);
          end;
  end;
end;
procedure vrc_chr(direccion:word;valor:byte);
begin
case direccion of
    $b000:begin
            nes_mapper_0.dregs[0]:=valor and $f;
            set_chr_1($0,nes_mapper_0.dregs[0] or (nes_mapper_0.dregs[1] shl 4));
          end;
    $b001:begin
            nes_mapper_0.dregs[1]:=valor and $1f;
            set_chr_1($0,nes_mapper_0.dregs[0] or (nes_mapper_0.dregs[1] shl 4));
          end;
    $b002:begin
            nes_mapper_0.dregs[2]:=valor and $f;
            set_chr_1($400,nes_mapper_0.dregs[2] or (nes_mapper_0.dregs[3] shl 4));
          end;
    $b003:begin
            nes_mapper_0.dregs[3]:=valor and $1f;
            set_chr_1($400,nes_mapper_0.dregs[2] or (nes_mapper_0.dregs[3] shl 4));
          end;
    $c000:begin
            nes_mapper_0.dregs[4]:=valor and $f;
            set_chr_1($800,nes_mapper_0.dregs[4] or (nes_mapper_0.dregs[5] shl 4));
          end;
    $c001:begin
            nes_mapper_0.dregs[5]:=valor and $1f;
            set_chr_1($800,nes_mapper_0.dregs[4] or (nes_mapper_0.dregs[5] shl 4));
          end;
    $c002:begin
            nes_mapper_0.dregs[6]:=valor and $f;
            set_chr_1($c00,nes_mapper_0.dregs[6] or (nes_mapper_0.dregs[7] shl 4));
          end;
    $c003:begin
            nes_mapper_0.dregs[7]:=valor and $1f;
            set_chr_1($c00,nes_mapper_0.dregs[6] or (nes_mapper_0.dregs[7] shl 4));
          end;
    $d000:begin
            nes_mapper_0.dregs[8]:=valor and $f;
            set_chr_1($1000,nes_mapper_0.dregs[8] or (nes_mapper_0.dregs[9] shl 4));
          end;
    $d001:begin
            nes_mapper_0.dregs[9]:=valor and $1f;
            set_chr_1($1000,nes_mapper_0.dregs[8] or (nes_mapper_0.dregs[9] shl 4));
          end;
    $d002:begin
            nes_mapper_0.dregs[10]:=valor and $f;
            set_chr_1($1400,nes_mapper_0.dregs[10] or (nes_mapper_0.dregs[11] shl 4));
          end;
    $d003:begin
            nes_mapper_0.dregs[11]:=valor and $1f;
            set_chr_1($1400,nes_mapper_0.dregs[10] or (nes_mapper_0.dregs[11] shl 4));
          end;
    $e000:begin
            nes_mapper_0.dregs[12]:=valor and $f;
            set_chr_1($1800,nes_mapper_0.dregs[12] or (nes_mapper_0.dregs[13] shl 4));
          end;
    $e001:begin
            nes_mapper_0.dregs[13]:=valor and $1f;
            set_chr_1($1800,nes_mapper_0.dregs[12] or (nes_mapper_0.dregs[13] shl 4));
          end;
    $e002:begin
            nes_mapper_0.dregs[14]:=valor and $f;
            set_chr_1($1c00,nes_mapper_0.dregs[14] or (nes_mapper_0.dregs[15] shl 4));
          end;
    $e003:begin
            nes_mapper_0.dregs[15]:=valor and $1f;
            set_chr_1($1c00,nes_mapper_0.dregs[14] or (nes_mapper_0.dregs[15] shl 4));
          end;
end;
end;
procedure vrc4_prg;
begin
if nes_mapper_0.regs[1]=0 then begin
  set_prg_8($8000,nes_mapper_0.regs[0]);
  set_prg_8($c000,(nes_mapper_0.last_prg shl 1)-2);
end else begin
  set_prg_8($c000,nes_mapper_0.regs[0]);
  set_prg_8($8000,(nes_mapper_0.last_prg shl 1)-2);
end;
end;

procedure mapper_21_write_rom(direccion:word;valor:byte);
begin
   case nes_mapper_0.submapper of
    0:direccion:=(direccion and $fff8) or ((direccion and 7) shr 1);
    1:direccion:=(direccion and $ff00) or ((direccion and $c0) shr 6);
    2:direccion:=(direccion and $fff0) or ((direccion and $c) shr 2);
    3:direccion:=(direccion and $fffc) or ((direccion and 1) shl 1) or ((direccion and 2) shr 1);
    4:direccion:=(direccion and $fff0) or ((direccion and 4) shr 1) or ((direccion and 8) shr 3);
   end;
  case (direccion and $f003) of
    $8000..$8003:begin
                    nes_mapper_0.regs[0]:=valor and $1f;
                    vrc4_prg;
                 end;
    $9000..$9001:case (valor and 3) of
                  0:ppu_nes_0.mirror:=MIRROR_VERTICAL;
                  1:ppu_nes_0.mirror:=MIRROR_HORIZONTAL;
                  2:ppu_nes_0.mirror:=MIRROR_LOW;
                  3:ppu_nes_0.mirror:=MIRROR_HIGH;
                 end;
    $9002:begin
            nes_mapper_0.regs[1]:=(valor shr 1) and 1;
            vrc4_prg;
          end;
    $9003:;
    $a000..$a003:set_prg_8($a000,valor and $1f);
    $b000..$efff:vrc_chr(direccion and $f003,valor);
    $f000:nes_mapper_0.reload_counter:=(nes_mapper_0.reload_counter and $f0) or (valor and $f);
    $f001:nes_mapper_0.reload_counter:=(nes_mapper_0.reload_counter and $0f) or ((valor and $f) shl 4);
    $f002:begin
            nes_mapper_0.latch1:=valor;
            n2a03_0.m6502.change_irq(CLEAR_LINE);
            if (valor and 2)<>0 then begin
              nes_mapper_0.counter:=nes_mapper_0.reload_counter;
              nes_mapper_0.needirqdelay:=0;
              nes_mapper_0.irq_ena:=true;
            end else nes_mapper_0.irq_ena:=false;
          end;
    $f003:begin
            n2a03_0.m6502.change_irq(CLEAR_LINE);
            nes_mapper_0.irq_ena:=(nes_mapper_0.latch1 and 1)<>0;
          end;
  end;
end;

procedure mapper_23_write_rom(direccion:word;valor:byte);
begin
  if nes_mapper_0.submapper=1 then direccion:=(direccion and $fffc) or ((direccion and 1) shl 1) or ((direccion and 2) shr 1);
  case (direccion and $f003) of
    $8000..$8003:set_prg_8($8000,valor and $1f);
    $9000..$9003:if (valor and 1)<>0 then ppu_nes_0.mirror:=MIRROR_HORIZONTAL
                    else ppu_nes_0.mirror:=MIRROR_VERTICAL;
    $a000..$a003:set_prg_8($a000,valor and $1f);
    $b000..$efff:if nes_mapper_0.last_chr<>0 then vrc_chr(direccion and $f003,valor);
  end;
end;

procedure mapper_32_update_prg;
begin
if (nes_mapper_0.regs[1] and $2)=0 then begin //prg type 0
  set_prg_8($8000,nes_mapper_0.regs[0]);
  set_prg_8($c000,(nes_mapper_0.last_prg shl 1)-2);
end else begin //prg type 1
  set_prg_8($8000,0);
  set_prg_8($c000,nes_mapper_0.regs[0]);
end;
end;

procedure mapper_32_write_rom(direccion:word;valor:byte);
begin
case (direccion and $f000) of
  $8000:begin //PRG 0
          nes_mapper_0.regs[0]:=valor and $1f;
          mapper_32_update_prg;
        end;
  $9000:if nes_mapper_0.submapper<>1 then begin
          nes_mapper_0.regs[1]:=valor and $3;
          mapper_32_update_prg;
          if (valor and $1)=0 then ppu_nes_0.mirror:=MIRROR_VERTICAL
            else ppu_nes_0.mirror:=MIRROR_HORIZONTAL;
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
            if (valor and $40)=0 then ppu_nes_0.mirror:=MIRROR_VERTICAL
              else ppu_nes_0.mirror:=MIRROR_HORIZONTAL;
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
    $7ffd:nes_mapper_0.regs[0]:=valor and 1;
    $7ffe:nes_mapper_0.regs[1]:=valor and $f;
    $7fff:nes_mapper_0.regs[2]:=valor and $f;
      else if (nes_mapper_0.last_chr=0) then nes_mapper_0.regs[0]:=valor and $3;
  end;
  set_prg_32(nes_mapper_0.regs[0]);
  if nes_mapper_0.last_chr<>0 then begin
    set_chr_4($0,nes_mapper_0.regs[1]);
    set_chr_4($1000,nes_mapper_0.regs[2]);
  end;
end;

procedure mapper_41_write_rom(direccion:word;valor:byte);
begin
case direccion of
  $6000..$67ff:begin
                  nes_mapper_0.regs[0]:=direccion and $7;
                  set_prg_32(direccion and $7);
                  if (direccion and $20)=0 then ppu_nes_0.mirror:=MIRROR_VERTICAL
                    else ppu_nes_0.mirror:=MIRROR_HORIZONTAL;
                  nes_mapper_0.regs[1]:=(nes_mapper_0.regs[1] and 3) or ((direccion shr 1) and $c);
                  set_chr_8(nes_mapper_0.regs[1]);
               end;
  $8000..$ffff:if nes_mapper_0.regs[0]>3 then begin
                  nes_mapper_0.regs[1]:=(nes_mapper_0.regs[1] and $c) or (valor and 3);
                  set_chr_8(nes_mapper_0.regs[1]);
               end;
end;
end;

procedure mapper_42_write_rom(direccion:word;valor:byte);
begin
case (direccion and $e003) of
  $8000:set_chr_8(valor and $f);
  $e000:set_prg_8($6000,valor and $f);
  $e001:if (valor and $8)=0 then ppu_nes_0.mirror:=MIRROR_VERTICAL
          else ppu_nes_0.mirror:=MIRROR_HORIZONTAL;
  $e002:if (valor and 2)=0 then begin
          nes_mapper_0.irq_ena:=false;
          n2a03_0.m6502.change_irq(CLEAR_LINE);
          nes_mapper_0.counter:=0;
        end else nes_mapper_0.irq_ena:=true;
end;
end;

procedure mapper_42_irq(estados_t:word);
begin
if nes_mapper_0.irq_ena then begin
  nes_mapper_0.counter:=nes_mapper_0.counter+estados_t;
  if nes_mapper_0.counter>=$8000 then nes_mapper_0.counter:=nes_mapper_0.counter-$8000;
  if nes_mapper_0.counter>=$6000 then n2a03_0.m6502.change_irq(ASSERT_LINE)
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
    $c000:nes_mapper_0.regs[2]:=valor xor $ff; //irq reload
    $c001:begin  //irq clear
            nes_mapper_0.reload:=true;
            nes_mapper_0.regs[1]:=0;
          end;
    $c002:nes_mapper_0.irq_ena:=true; //irq enable
    $c003:begin  //irq enable
             nes_mapper_0.irq_ena:=false; //irq ack
             n2a03_0.m6502.change_irq(CLEAR_LINE);
        end;
    $e000:if (valor and $40)=0 then ppu_nes_0.mirror:=MIRROR_VERTICAL
              else ppu_nes_0.mirror:=MIRROR_HORIZONTAL;
  end;
end;

procedure mapper_57_write_rom(direccion:word;valor:byte);
begin
case (direccion and $8800) of
  $8000:nes_mapper_0.regs[0]:=valor;
  $8800:nes_mapper_0.regs[1]:=valor
end;
  if (nes_mapper_0.regs[1] and $10)<>0 then begin
    set_prg_32(((nes_mapper_0.regs[1] shr 5) and 6) shr 1);
  end else begin
    set_prg_16($8000,(nes_mapper_0.regs[1] shr 5) and 7);
    set_prg_16($c000,(nes_mapper_0.regs[1] shr 5) and 7);
  end;
  set_chr_8(((nes_mapper_0.regs[0] and $40) shr 3) or ((nes_mapper_0.regs[0] or nes_mapper_0.regs[1]) and $7));
  if (nes_mapper_0.regs[1] and $8)=0 then ppu_nes_0.mirror:=MIRROR_VERTICAL
    else ppu_nes_0.mirror:=MIRROR_HORIZONTAL;
end;

procedure mapper_58_write_rom(direccion:word;valor:byte);
begin
  if (direccion and $80)<>0 then ppu_nes_0.mirror:=MIRROR_HORIZONTAL
    else ppu_nes_0.mirror:=MIRROR_VERTICAL;
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
  $8000:nes_mapper_0.latch1:=valor;
  $8001:begin
          nes_mapper_0.regs[nes_mapper_0.latch1 and $f]:=valor;
          if (nes_mapper_0.latch1 and $40)<>0 then begin
            set_prg_8($8000,nes_mapper_0.regs[$f]);
            set_prg_8($a000,nes_mapper_0.regs[6]);
            set_prg_8($c000,nes_mapper_0.regs[7]);
          end else begin
            set_prg_8($8000,nes_mapper_0.regs[6]);
            set_prg_8($a000,nes_mapper_0.regs[7]);
            set_prg_8($c000,nes_mapper_0.regs[$f]);
          end;
          tempw:=(nes_mapper_0.latch1 and $80) shl 5;
          if (nes_mapper_0.latch1 and $20)<>0 then begin
            set_chr_1($400 xor tempw,nes_mapper_0.regs[8]);
            set_chr_1($c00 xor tempw,nes_mapper_0.regs[9]);
          end else begin
            set_chr_1($400 xor tempw,nes_mapper_0.regs[0]+1);
            set_chr_1($c00 xor tempw,nes_mapper_0.regs[1]+1);
          end;
          set_chr_1($0 xor tempw,nes_mapper_0.regs[0]);
          set_chr_1($800 xor tempw,nes_mapper_0.regs[1]);
          set_chr_1($1000 xor tempw,nes_mapper_0.regs[2]);
          set_chr_1($1400 xor tempw,nes_mapper_0.regs[3]);
          set_chr_1($1800 xor tempw,nes_mapper_0.regs[4]);
          set_chr_1($1c00 xor tempw,nes_mapper_0.regs[5]);
        end;
  $a000:if (valor and $1)<>0 then ppu_nes_0.mirror:=MIRROR_HORIZONTAL
                else ppu_nes_0.mirror:=MIRROR_VERTICAL;
  $c000:nes_mapper_0.reload_counter:=valor;
  $c001:begin //irq type
          if (nes_mapper_0.clock_mode and ((valor and 1)=0)) then nes_mapper_0.forceclock:=true;
          nes_mapper_0.clock_mode:=(valor and 1)<>0;
          if nes_mapper_0.clock_mode then nes_mapper_0.latch0:=0;
          nes_mapper_0.reload:=true;
        end;
  $e000:begin
          nes_mapper_0.irq_ena:=false;
          n2a03_0.m6502.change_irq(CLEAR_LINE);
        end;
  $e001:nes_mapper_0.irq_ena:=true;
end;
end;

procedure mapper_64_count(contador:byte);
begin
if nes_mapper_0.reload then begin
  if (nes_mapper_0.reload_counter<=1) then nes_mapper_0.counter:=nes_mapper_0.reload_counter+1
    else nes_mapper_0.counter:=nes_mapper_0.reload_counter+2;
  nes_mapper_0.reload:=false;
end else if (nes_mapper_0.counter=0) then nes_mapper_0.counter:=nes_mapper_0.reload_counter+1;
nes_mapper_0.counter:=nes_mapper_0.counter-1;
if ((nes_mapper_0.counter=0) and nes_mapper_0.irq_ena) then nes_mapper_0.needirqdelay:=1;
end;

procedure mapper_64_irq(estados_t:word);
var
  f:word;
begin
for f:=1 to estados_t do begin
  if(nes_mapper_0.needirqdelay<>0) then begin
    nes_mapper_0.needirqdelay:=nes_mapper_0.needirqdelay-1;
    if (nes_mapper_0.needirqdelay=0) then n2a03_0.m6502.change_irq(ASSERT_LINE);
  end;
  if (nes_mapper_0.clock_mode or nes_mapper_0.forceclock) then begin
	  nes_mapper_0.latch0:=(nes_mapper_0.latch0+1) and $3;
		if (nes_mapper_0.latch0=0) then begin
      mapper_64_count(1);
      nes_mapper_0.forceclock:=false;
    end;
  end;
end;
end;

procedure mapper_64_line(force:boolean);
begin
if not(nes_mapper_0.clock_mode) then begin
  //if ((ppu_nes_0.linea<240) or (ppu_nes_0.linea=261) or force) then begin
    mapper_64_count(1);
  //end;
end;
end;

procedure mapper_65_write_rom(direccion:word;valor:byte);
begin
case (direccion and $f007) of
  $8000:set_prg_8($8000,valor);
  $9001:if (valor and $80)<>0 then ppu_nes_0.mirror:=MIRROR_HORIZONTAL
          else ppu_nes_0.mirror:=MIRROR_VERTICAL;
  $9003:begin
          n2a03_0.m6502.change_irq(CLEAR_LINE);
          nes_mapper_0.irq_ena:=(valor and $80)<>0;
        end;
  $9004:begin
          n2a03_0.m6502.change_irq(CLEAR_LINE);
          nes_mapper_0.counter:=nes_mapper_0.reload_counter;
        end;
  $9005:nes_mapper_0.reload_counter:=(nes_mapper_0.reload_counter and $ff) or (valor shl 8);
  $9006:nes_mapper_0.reload_counter:=(nes_mapper_0.reload_counter and $ff00) or valor;
  $a000:set_prg_8($a000,valor);
  $b000..$b007:set_chr_1($400*(direccion and $7),valor);
  $c000:set_prg_8($c000,valor);
end;
end;

procedure mapper_65_irq(estados_t:word);
begin
if nes_mapper_0.irq_ena then begin
  if nes_mapper_0.counter<>0 then begin
    nes_mapper_0.counter:=nes_mapper_0.counter-estados_t;
    if nes_mapper_0.counter<=0 then begin
        nes_mapper_0.counter:=0;
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
      case nes_mapper_0.latch1 of
        0:nes_mapper_0.regs[0]:=valor;
        1:nes_mapper_0.counter:=(nes_mapper_0.regs[0] shl 8) or valor;
      end;
      nes_mapper_0.latch1:=nes_mapper_0.latch1 xor 1;
     end;
  $d:begin
      n2a03_0.m6502.change_irq(CLEAR_LINE);
      nes_mapper_0.latch1:=0;
      nes_mapper_0.irq_ena:=(valor and $10)<>0;
    end;
  $e:case (valor and 3) of
          0:ppu_nes_0.mirror:=MIRROR_VERTICAL;
          1:ppu_nes_0.mirror:=MIRROR_HORIZONTAL;
          2:ppu_nes_0.mirror:=MIRROR_LOW;
          3:ppu_nes_0.mirror:=MIRROR_HIGH;
        end;
  $f:set_prg_16($8000,valor);
end;
end;

procedure mapper_67_irq(estados_t:word);
begin
if nes_mapper_0.irq_ena then begin
  nes_mapper_0.counter:=nes_mapper_0.counter-estados_t;
  if (nes_mapper_0.counter<0) then begin
    n2a03_0.m6502.change_irq(ASSERT_LINE);
    nes_mapper_0.irq_ena:=false;
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
  $c:if nes_mapper_0.chr_extra_ena then begin
        tempb:=($80 or (valor and $7f)) mod (nes_mapper_0.last_chr shl 3);
        copymemory(@ppu_nes_0.name_table[0,0],@nes_mapper_0.chr[tempb shr 3,$400*(tempb and 7)],$400);
     end;
  $d:if nes_mapper_0.chr_extra_ena then begin
        tempb:=($80 or (valor and $7f)) mod (nes_mapper_0.last_chr shl 3);
        copymemory(@ppu_nes_0.name_table[1,0],@nes_mapper_0.chr[tempb shr 3,$400*(tempb and 7)],$400);
     end;
  $e:begin
        case (valor and 3) of
          0:ppu_nes_0.mirror:=MIRROR_VERTICAL;
          1:ppu_nes_0.mirror:=MIRROR_HORIZONTAL;
          2,3:ppu_nes_0.mirror:=MIRROR_LOW;
        end;
        nes_mapper_0.chr_extra_ena:=(valor and $10)<>0;
     end;
  $f:begin
        set_prg_16($8000,valor and $f);
        nes_mapper_0.prg_ram_enable:=(valor and $10)<>0;
     end;
end;
end;

procedure mapper_69_write_rom(direccion:word;valor:byte);
begin
case (direccion and $e000) of
  $8000:nes_mapper_0.latch1:=valor and $f;
  $a000:begin
          case (nes_mapper_0.latch1 and $f) of
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
                nes_mapper_0.latch0:=valor;
              end;
            9:set_prg_8($8000,valor);
            $a:set_prg_8($a000,valor);
            $b:set_prg_8($c000,valor);
            $c:case (valor and $3) of
                0:ppu_nes_0.mirror:=MIRROR_VERTICAL;
                1:ppu_nes_0.mirror:=MIRROR_HORIZONTAL;
                2:ppu_nes_0.mirror:=MIRROR_LOW;
                3:ppu_nes_0.mirror:=MIRROR_HIGH;
               end;
            $d:begin
                nes_mapper_0.irq_ena:=(valor and 1)<>0;
                nes_mapper_0.reload:=(valor and $80)<>0;
               end;
            $e:nes_mapper_0.reload_counter:=(nes_mapper_0.reload_counter and $ff00) or valor;
            $f:nes_mapper_0.reload_counter:=(nes_mapper_0.reload_counter and $ff) or (valor shl 8);
          end;
        end;
  $c000:ay8910_0.Control(valor and $f);
  $e000:ay8910_0.Write(valor);
end;
end;

procedure mapper_69_irq(estados_t:word);
begin
if nes_mapper_0.reload then begin
  nes_mapper_0.reload_counter:=nes_mapper_0.reload_counter-estados_t;
  if nes_mapper_0.reload_counter<0 then begin
    nes_mapper_0.reload_counter:=nes_mapper_0.reload_counter+$ffff;
    if nes_mapper_0.irq_ena then n2a03_0.m6502.change_irq(HOLD_LINE);
  end;
end;
end;

function mapper_69_read_prg_ram(direccion:word):byte;
begin
if (nes_mapper_0.latch0 and $40)<>0 then begin
  if (nes_mapper_0.latch0 and $80)<>0 then mapper_69_read_prg_ram:=nes_mapper_0.prg_ram[nes_mapper_0.latch0 and $3f,direccion and $1fff]
    else mapper_69_read_prg_ram:=ppu_nes_0.open_bus;
end else mapper_69_read_prg_ram:=memoria[direccion];
end;

procedure mapper_69_write_prg_ram(direccion:word;valor:byte);
begin
if ((nes_mapper_0.latch0 and $c0)=$c0) then nes_mapper_0.prg_ram[nes_mapper_0.latch0 and $3f,direccion and $1fff]:=valor;
end;

procedure mapper_69_update_sound;
begin
  ay8910_0.update;
end;

procedure mapper_70_write_rom(direccion:word;valor:byte);
begin
set_chr_8(valor and $f);
set_prg_16($8000,(valor and $f0) shr 4);
end;

procedure mapper_71_write_rom(direccion:word;valor:byte);
begin
case direccion of
  $9000..$9fff:if (valor and $10)<>0 then ppu_nes_0.mirror:=MIRROR_HIGH
                  else ppu_nes_0.mirror:=MIRROR_LOW;
  $c000..$ffff:set_prg_16($8000,valor and $f);
end;
end;

procedure mapper_73_write_rom(direccion:word;valor:byte);
begin
case (direccion shr 12) of
  $8:nes_mapper_0.reload_counter:=(nes_mapper_0.reload_counter and $fff0) or (valor and $f);
  $9:nes_mapper_0.reload_counter:=(nes_mapper_0.reload_counter and $ff0f) or ((valor and $f) shl 4);
  $a:nes_mapper_0.reload_counter:=(nes_mapper_0.reload_counter and $f0ff) or ((valor and $f) shl 8);
  $b:nes_mapper_0.reload_counter:=(nes_mapper_0.reload_counter and $0fff) or ((valor and $f) shl 12);
  $c:begin
      nes_mapper_0.latch1:=valor;
      n2a03_0.m6502.change_irq(CLEAR_LINE);
      if (valor and 2)<>0 then begin
        nes_mapper_0.counter:=nes_mapper_0.reload_counter;
        nes_mapper_0.irq_ena:=true;
      end else nes_mapper_0.irq_ena:=false;
     end;
  $d:begin
      n2a03_0.m6502.change_irq(CLEAR_LINE);
      nes_mapper_0.irq_ena:=(nes_mapper_0.latch1 and 1)<>0;
    end;
  $f:set_prg_16($8000,valor);
end;
end;

procedure mapper_73_irq(estados_t:word);
var
  tempw:word;
begin
if nes_mapper_0.irq_ena then begin
  if (nes_mapper_0.latch1 and 4)<>0 then begin
    tempw:=(nes_mapper_0.counter and $ff)+estados_t;
    if (tempw>$ff) then begin
      n2a03_0.m6502.change_irq(ASSERT_LINE);
      nes_mapper_0.counter:=(nes_mapper_0.counter and $ff00) or (nes_mapper_0.reload_counter and $ff);
    end else nes_mapper_0.counter:=(nes_mapper_0.counter and $ff00) or tempw;
  end else begin
    nes_mapper_0.counter:=nes_mapper_0.counter+estados_t;
    if (nes_mapper_0.counter>$ffff) then begin
      n2a03_0.m6502.change_irq(ASSERT_LINE);
      nes_mapper_0.counter:=nes_mapper_0.reload_counter;
    end;
  end;
end;
end;

procedure mapper_75_write_rom(direccion:word;valor:byte);
begin
case (direccion shr 12) of
  $8:set_prg_8($8000,valor and $f);
  $9:begin
      if (valor and $1)<>0 then ppu_nes_0.mirror:=MIRROR_HORIZONTAL
        else ppu_nes_0.mirror:=MIRROR_VERTICAL;
      nes_mapper_0.regs[0]:=(nes_mapper_0.regs[0] and $f) or ((valor and 2) shl 3);
      nes_mapper_0.regs[1]:=(nes_mapper_0.regs[1] and $f) or ((valor and 4) shl 2);
      set_chr_4($0,nes_mapper_0.regs[0]);
      set_chr_4($1000,nes_mapper_0.regs[1]);
     end;
  $a:set_prg_8($a000,valor and $f);
  $c:set_prg_8($c000,valor and $f);
  $e:begin
      nes_mapper_0.regs[0]:=(nes_mapper_0.regs[0] and $10) or (valor and $f);
      set_chr_4($0,nes_mapper_0.regs[0]);
     end;
  $f:begin
      nes_mapper_0.regs[1]:=(nes_mapper_0.regs[1] and $10) or (valor and $f);
      set_chr_4($1000,nes_mapper_0.regs[1]);
     end;
end;
end;

procedure mapper_76_write_rom(direccion:word;valor:byte);
begin
direccion:=direccion and $8001;
case direccion of
  $8000:nes_mapper_0.regs[0]:=valor and 7;
  $8001:case nes_mapper_0.regs[0] of
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
  if nes_mapper_0.submapper=1 then direccion:=(direccion and $ffe7) or ((direccion and 8) shl 1) or ((direccion and $10) shr 1);
  case (direccion and $f038) of
    $8000:set_prg_8($8000,valor and $3f);
    $8010:set_prg_8($a000,valor and $3f);
    $9000:set_prg_8($c000,valor and $3f);
    $9010,$9030:; //FM chip
    $a000:if nes_mapper_0.last_chr<>0 then set_chr_1($0,valor);
    $a010:if nes_mapper_0.last_chr<>0 then set_chr_1($400,valor);
    $b000:if nes_mapper_0.last_chr<>0 then set_chr_1($800,valor);
    $b010:if nes_mapper_0.last_chr<>0 then set_chr_1($c00,valor);
    $c000:if nes_mapper_0.last_chr<>0 then set_chr_1($1000,valor);
    $c010:if nes_mapper_0.last_chr<>0 then set_chr_1($1400,valor);
    $d000:if nes_mapper_0.last_chr<>0 then set_chr_1($1800,valor);
    $d010:if nes_mapper_0.last_chr<>0 then set_chr_1($1c00,valor);
    $e000:begin
            case (valor and 3) of
               0:ppu_nes_0.mirror:=MIRROR_VERTICAL;
               1:ppu_nes_0.mirror:=MIRROR_HORIZONTAL;
               2:ppu_nes_0.mirror:=MIRROR_LOW;
               3:ppu_nes_0.mirror:=MIRROR_HIGH;
            end;
            nes_mapper_0.prg_ram_writeble:=(valor and $80)<>0;
          end;
    $e010:nes_mapper_0.reload_counter:=valor;
    $f000:begin
            nes_mapper_0.latch1:=valor;
            n2a03_0.m6502.change_irq(CLEAR_LINE);
            if (valor and 2)<>0 then begin
              nes_mapper_0.counter:=nes_mapper_0.reload_counter;
              nes_mapper_0.needirqdelay:=0;
              nes_mapper_0.irq_ena:=true;
            end else nes_mapper_0.irq_ena:=false;
          end;
    $f010:begin
            n2a03_0.m6502.change_irq(CLEAR_LINE);
            nes_mapper_0.irq_ena:=(nes_mapper_0.latch1 and 1)<>0;
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
  $8000:nes_mapper_0.regs[0]:=valor;
  $8001:case (nes_mapper_0.regs[0] and $7) of
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
if (valor and $8)<>0 then ppu_nes_0.mirror:=MIRROR_HIGH
  else ppu_nes_0.mirror:=MIRROR_LOW;
end;

procedure mapper_93_write_rom(direccion:word;valor:byte);
begin
set_prg_16($8000,(valor and $70) shr 4);
ppu_nes_0.write_chr:=(valor and 1)<>0;
end;

procedure mapper_94_write_rom(direccion:word;valor:byte);
begin
set_prg_16($8000,(valor shr 2) and $7);
end;

procedure mapper_95_nametable;
var
  tempb:byte;
begin
  tempb:=nes_mapper_0.regs[1]+(nes_mapper_0.regs[2] shl 1);
  case tempb of
    0:ppu_nes_0.mirror:=MIRROR_LOW;
    1:ppu_nes_0.mirror:=MIRROR_HORIZONTAL;
    2:ppu_nes_0.mirror:=MIRROR_MAP95;
    3:ppu_nes_0.mirror:=MIRROR_HIGH;
  end;
end;

procedure mapper_95_write_rom(direccion:word;valor:byte);
begin
direccion:=direccion and $8001;
case direccion of
  $8000:nes_mapper_0.regs[0]:=valor and 7;
  $8001:case nes_mapper_0.regs[0] of
          0:begin
              set_chr_2($0,(valor shr 1) and $1f);
              nes_mapper_0.regs[1]:=(valor shr 5) and 1;
              mapper_95_nametable;
            end;
          1:begin
              set_chr_2($800,(valor shr 1) and $1f);
              nes_mapper_0.regs[2]:=(valor shr 5) and 1;
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
  nes_mapper_0.serial_cnt:=0;
  nes_mapper_0.valor_map:=0;
  nes_mapper_0.regs[0]:=nes_mapper_0.regs[0] or $c;
  nes_mapper_0.counter:=0;
  set_prg_32(0);
end else begin
  nes_mapper_0.valor_map:=nes_mapper_0.valor_map or ((valor and 1) shl nes_mapper_0.serial_cnt);
  nes_mapper_0.serial_cnt:=nes_mapper_0.serial_cnt+1;
  nes_mapper_0.counter:=0;
  if nes_mapper_0.serial_cnt=5 then begin
    nes_mapper_0.regs[(direccion shr 13) and 3]:=nes_mapper_0.valor_map;
    case (nes_mapper_0.regs[0] and 3) of //Mirror
      0:ppu_nes_0.mirror:=MIRROR_LOW;
      1:ppu_nes_0.mirror:=MIRROR_HIGH;
      2:ppu_nes_0.mirror:=MIRROR_VERTICAL;
      3:ppu_nes_0.mirror:=MIRROR_HORIZONTAL;
    end;
    if (nes_mapper_0.regs[1] and $10)=0 then begin
      nes_mapper_0.irq_ena:=true;
      if nes_mapper_0.latch1=$ff then nes_mapper_0.latch1:=$fe;
    end else begin
      nes_mapper_0.counter:=0;
      n2a03_0.m6502.change_irq(CLEAR_LINE);
      nes_mapper_0.irq_ena:=false;
      if nes_mapper_0.latch1=$fe then begin
        nes_mapper_0.prg_ena:=true;
        nes_mapper_0.latch1:=$fd;
      end;
    end;
    if nes_mapper_0.prg_ena then mapper_1_prg;
    nes_mapper_0.valor_map:=0;
    nes_mapper_0.serial_cnt:=0;
  end;
end;
end;

procedure mapper_105_irq(estados_t:word);
begin
if nes_mapper_0.irq_ena then begin
  nes_mapper_0.counter:=nes_mapper_0.counter+estados_t;
  if (nes_mapper_0.counter>=$2800000) then n2a03_0.m6502.change_irq(ASSERT_LINE);
end;
end;

procedure mapper_113_write_rom(direccion:word;valor:byte);
begin
if (direccion and $e100)=$4100 then begin
  if (valor and $80)<>0 then ppu_nes_0.mirror:=MIRROR_HORIZONTAL
    else ppu_nes_0.mirror:=MIRROR_VERTICAL;
  set_prg_32((valor shr 3) and 7);
  set_chr_8((valor and 7) or ((valor shr 3) and 8));
end;
end;

procedure mapper_116_write_rom(direccion:word;valor:byte);
begin
if (direccion<$8000) then begin
  if (direccion and $c100)=$4100 then begin
    nes_mapper_0.mode:=valor and 3;
    n2a03_0.m6502.change_despues_instruccion(nil);
    nes_mapper_0.calls.line_ack:=nil;
    case (valor and 3) of
      0:begin  //vrc2-b
          set_prg_16($8000,0);
          set_prg_16($c000,nes_mapper_0.last_prg-1);
          nes_mapper_0.prg_ram_enable:=true;
        end;
      1:begin //mapper 4
          nes_mapper_0.calls.line_ack:=mapper_4_line;
          nes_mapper_0.irq_ena:=false;
          nes_mapper_0.dregs[1]:=2;
          nes_mapper_0.dregs[2]:=4;
          nes_mapper_0.dregs[3]:=5;
          nes_mapper_0.dregs[4]:=6;
          nes_mapper_0.dregs[5]:=7;
          nes_mapper_0.dregs[7]:=1;
          mapper_4_update_chr(0);
          mapper_4_update_prg(0);
          set_prg_16($8000,nes_mapper_0.last_prg-1);
          set_prg_16($c000,nes_mapper_0.last_prg-1);
        end;
      2,3:begin
            n2a03_0.m6502.change_despues_instruccion(mapper_1_delay); //mapper 1
            nes_mapper_0.serial_cnt:=0;
            nes_mapper_0.prg_ram_enable:=true;
            nes_mapper_0.regs[0]:=$c;
            set_prg_16($8000,0);
            set_prg_16($c000,nes_mapper_0.last_prg-1);
          end;
    end;
  end;
end else case nes_mapper_0.mode of
          0:mapper_23_write_rom(direccion,valor);
          1:mapper_4_write_rom(direccion,valor);
          2,3:mapper_1_write_rom(direccion,valor);
         end;
end;

procedure mapper_132_write_rom(direccion:word;valor:byte);
begin
case (direccion and $8000) of
  $8000:begin
          set_prg_32(nes_mapper_0.regs[3] shr 2);
          set_chr_8(nes_mapper_0.regs[3] and $3);
        end;
end;
end;

function mapper_132_read_exp(direccion:word):byte;
begin
case (direccion and $e100) of
  $4100:mapper_132_read_exp:=(ppu_nes_0.open_bus and $f0) or ((nes_mapper_0.regs[1] and 8) xor (nes_mapper_0.regs[0] shl 3)) or nes_mapper_0.regs[3];
end;
end;

procedure mapper_132_write_exp(direccion:word;valor:byte);
begin
case (direccion and $e103) of
  $4100:if nes_mapper_0.regs[2]<>0 then nes_mapper_0.regs[3]:=(nes_mapper_0.regs[3]+1) and $7
          else begin
              if nes_mapper_0.regs[0]<>0 then nes_mapper_0.regs[3]:=(not(nes_mapper_0.regs[1] and $7)) and $7
                else nes_mapper_0.regs[3]:=nes_mapper_0.regs[1] and $7;
          end;
  $4101:nes_mapper_0.regs[0]:=valor and 1;
  $4102:nes_mapper_0.regs[1]:=valor and $f;
  $4103:nes_mapper_0.regs[2]:=valor and 1;
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
  $4100:nes_mapper_0.latch1:=valor and 7;
  $4101:begin
          nes_mapper_0.dregs[nes_mapper_0.latch1]:=valor and 7;
          nes_mapper_0.reload:=(nes_mapper_0.dregs[7] and 1)<>0;
          set_chr_1(0,nes_mapper_0.dregs[0]);
          if nes_mapper_0.reload then begin
              set_chr_1($400,nes_mapper_0.dregs[0] or ((nes_mapper_0.dregs[4] and 1) shl 4));
              set_chr_1($800,nes_mapper_0.dregs[0] or ((nes_mapper_0.dregs[4] and 2) shl 3));
              set_chr_1($c00,nes_mapper_0.dregs[0] or ((nes_mapper_0.dregs[4] and 4) shl 2) or ((nes_mapper_0.dregs[6] and 1) shl 3));
          end else begin
              set_chr_1($400,nes_mapper_0.dregs[1] or ((nes_mapper_0.dregs[4] and 1) shl 4));
              set_chr_1($800,nes_mapper_0.dregs[2] or ((nes_mapper_0.dregs[4] and 2) shl 3));
              set_chr_1($c00,nes_mapper_0.dregs[3] or ((nes_mapper_0.dregs[4] and 4) shl 2) or ((nes_mapper_0.dregs[6] and 1) shl 3));
          end;
          set_prg_32(nes_mapper_0.dregs[5]);
          if nes_mapper_0.reload then begin
              ppu_nes_0.mirror:=MIRROR_HORIZONTAL;
          end else case ((nes_mapper_0.dregs[7] shr 1) and 3) of
              0:ppu_nes_0.mirror:=MIRROR_HORIZONTAL;
              1:ppu_nes_0.mirror:=MIRROR_VERTICAL;
              2:ppu_nes_0.mirror:=MIRROR_MAP139;
              3:ppu_nes_0.mirror:=MIRROR_LOW;
          end;
        end;
end;
end;

procedure mapper_139_write_rom(direccion:word;valor:byte);
var
  tempb:byte;
begin
case (direccion and $c101) of
  $4100:nes_mapper_0.latch1:=valor and 7;
  $4101:begin
          nes_mapper_0.dregs[nes_mapper_0.latch1]:=valor and 7;
          nes_mapper_0.reload:=(nes_mapper_0.dregs[7] and 1)<>0;
          tempb:=nes_mapper_0.dregs[4] shl 3;
          if nes_mapper_0.reload then set_chr_8(nes_mapper_0.dregs[0] or tempb)
            else begin
                set_chr_2(0,(nes_mapper_0.dregs[0] or tempb) shl nes_mapper_0.shift);
                set_chr_2($800,((nes_mapper_0.dregs[1] or tempb) shl nes_mapper_0.shift) or nes_mapper_0.regs[0]);
                set_chr_2($1000,((nes_mapper_0.dregs[2] or tempb) shl nes_mapper_0.shift) or nes_mapper_0.regs[1]);
                set_chr_2($1800,((nes_mapper_0.dregs[3] or tempb) shl nes_mapper_0.shift) or nes_mapper_0.regs[2]);
            end;
          set_prg_32(nes_mapper_0.dregs[5]);
          case ((nes_mapper_0.dregs[7] shr 1) and 3) of
                  0:ppu_nes_0.mirror:=MIRROR_VERTICAL;
                  1:ppu_nes_0.mirror:=MIRROR_HORIZONTAL;
                  2:ppu_nes_0.mirror:=MIRROR_MAP139;
                  3:ppu_nes_0.mirror:=MIRROR_LOW;
          end;
        end;
end;
end;

procedure mapper_142_write_rom(direccion:word;valor:byte);
var
  tempb:byte;
begin
case (direccion shr 12) of
  $8:nes_mapper_0.reload_counter:=(nes_mapper_0.reload_counter and $fff0) or (valor and $f);
  $9:nes_mapper_0.reload_counter:=(nes_mapper_0.reload_counter and $ff0f) or ((valor and $f) shl 4);
  $a:nes_mapper_0.reload_counter:=(nes_mapper_0.reload_counter and $f0ff) or ((valor and $f) shl 8);
  $b:nes_mapper_0.reload_counter:=(nes_mapper_0.reload_counter and $0fff) or ((valor and $f) shl 12);
  $c:begin
      n2a03_0.m6502.change_irq(CLEAR_LINE);
      if (valor<>0) then begin
        nes_mapper_0.counter:=nes_mapper_0.reload_counter;
        nes_mapper_0.irq_ena:=true;
      end else nes_mapper_0.irq_ena:=false;
     end;
  $d:n2a03_0.m6502.change_irq(CLEAR_LINE);
  $e:nes_mapper_0.latch1:=(valor and $f)-1;
  $f:begin
      if (nes_mapper_0.latch1<3) then nes_mapper_0.dregs[nes_mapper_0.latch1]:=(nes_mapper_0.dregs[nes_mapper_0.latch1 and $10]) or (valor and $f)
        else if (nes_mapper_0.latch1<4) then begin
          nes_mapper_0.dregs[nes_mapper_0.latch1]:=valor;
          set_prg_8($6000,valor);
        end;
      case (direccion and $fc00) of
        $f000:begin
                tempb:=direccion and 3;
                if (tempb<3) then nes_mapper_0.dregs[tempb]:=(valor and $10) or (nes_mapper_0.dregs[tempb] and $f);
              end;
        $f800:if (valor and $1)<>0 then ppu_nes_0.mirror:=MIRROR_VERTICAL
                else ppu_nes_0.mirror:=MIRROR_HORIZONTAL;
        $fc00:set_chr_1((direccion and 7)*$400,valor);
      end;
      set_prg_8($8000,nes_mapper_0.dregs[0]);
      set_prg_8($a000,nes_mapper_0.dregs[1]);
      set_prg_8($c000,nes_mapper_0.dregs[2]);
     end;
end;
end;

procedure mapper_142_irq(estados_t:word);
begin
if nes_mapper_0.irq_ena then begin
    nes_mapper_0.counter:=nes_mapper_0.counter+estados_t;
    if (nes_mapper_0.counter>$ffff) then begin
      n2a03_0.m6502.change_irq(ASSERT_LINE);
      nes_mapper_0.counter:=nes_mapper_0.reload_counter;
    end;
end;
end;

function mapper_143_read_rom(direccion:word):byte;
begin
if (direccion and $100)<>0 then mapper_143_read_rom:=(not(direccion) and $3f) or (ppu_nes_0.open_bus and $c0)
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
  if (direccion and $c101)=$4101 then mapper_150_read_rom:=nes_mapper_0.dregs[nes_mapper_0.latch1];
end;

procedure mapper_150_write_rom(direccion:word;valor:byte);
begin
case (direccion and $c101) of
  $4100:nes_mapper_0.latch1:=valor;
  $4101:begin
          nes_mapper_0.dregs[nes_mapper_0.latch1]:=valor;
          set_chr_8(((nes_mapper_0.dregs[4] and 1) shl 2) or (nes_mapper_0.dregs[6] and 3));
          if nes_mapper_0.latch1=2 then set_prg_32(nes_mapper_0.dregs[2] and $1)
            else set_prg_32(nes_mapper_0.dregs[5] and $3);
          case ((nes_mapper_0.dregs[7] shr 1) and 3) of
                0:ppu_nes_0.mirror:=MIRROR_MAP243;
                1:ppu_nes_0.mirror:=MIRROR_HORIZONTAL;
                2:ppu_nes_0.mirror:=MIRROR_VERTICAL;
                3:ppu_nes_0.mirror:=MIRROR_HIGH;
              end;
          end;
end;
end;

procedure mapper_152_write_rom(direccion:word;valor:byte);
begin
if (valor and $80)=0 then ppu_nes_0.mirror:=MIRROR_LOW
  else ppu_nes_0.mirror:=MIRROR_HIGH;
set_chr_8(valor and $f);
set_prg_16($8000,(valor shr 4) and 7);
end;

procedure mapper_154_write_rom(direccion:word;valor:byte);
begin
direccion:=direccion and $8001;
case direccion of
  $8000:begin
          nes_mapper_0.regs[0]:=valor;
          if (valor and $40)<>0 then ppu_nes_0.mirror:=MIRROR_HIGH
            else ppu_nes_0.mirror:=MIRROR_LOW;
        end;
  $8001:case (nes_mapper_0.regs[0] and $7) of
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
  mapper_172_read:=(nes_mapper_0.regs[1] xor nes_mapper_0.regs[2]) or $40;
end;

procedure mapper_172_write_rom(direccion:word;valor:byte);
begin
case (direccion and $e103) of
  $4100..$4103:nes_mapper_0.regs[direccion and $3]:=valor;
  $8000..$ffff:begin
                  if ((nes_mapper_0.dregs[1] and $20)=0) then ppu_nes_0.mirror:=MIRROR_HORIZONTAL
                    else ppu_nes_0.mirror:=MIRROR_VERTICAL;
                  set_prg_32((nes_mapper_0.regs[2] shr 2) and $f);
                  set_chr_8((((valor xor nes_mapper_0.regs[2]) shr 3) and $02) or (((valor xor nes_mapper_0.regs[2]) shr 5) and $01));
               end;
end;
end;

procedure mapper_173_write_rom(direccion:word;valor:byte);
begin
case (direccion and $8000) of
  $8000:begin
          set_prg_32(nes_mapper_0.regs[3] shr 2);
          set_chr_8((nes_mapper_0.regs[3] and $1) or (not(nes_mapper_0.regs[0]) shl 1));
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
ppu_nes_0.disable_chr:=true;
if ((((valor and $f)<>0) and (valor<>$13)) or (nes_mapper_0.latch1=$21)) then begin
      if not((valor=$21) and (nes_mapper_0.latch1<>$13)) then begin
        ppu_nes_0.disable_chr:=false;
        set_chr_8(valor and $3);
      end;
end;
nes_mapper_0.latch1:=valor;
end;

procedure mapper_206_write_rom(direccion:word;valor:byte);
begin
direccion:=direccion and $8001;
case direccion of
  $8000:nes_mapper_0.regs[0]:=valor and 7;
  $8001:case nes_mapper_0.regs[0] of
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
  if (direccion and $8)<>0 then ppu_nes_0.mirror:=MIRROR_HORIZONTAL
    else ppu_nes_0.mirror:=MIRROR_VERTICAL;
  if (direccion and $4000)<>0 then set_prg_32((direccion and $6) shr 1)
    else begin
      set_prg_16($8000,direccion and $7);
      set_prg_16($c000,direccion and $7);
    end;
end;

function mapper_212_read_exp(direccion:word):byte;
begin
  if (direccion and $e010)=$6000 then mapper_212_read_exp:=$80 or ppu_nes_0.open_bus;
end;

procedure mapper_221_write_rom(direccion:word;valor:byte);
procedure update_221;
var
  tempb,tempb2:byte;
begin
  if (nes_mapper_0.regs[0] and 1)=0 then begin
    tempb:=nes_mapper_0.regs[1];
    tempb2:=nes_mapper_0.regs[1];
  end else begin
    if (nes_mapper_0.regs[0] and $80)<>0 then begin
      tempb:=nes_mapper_0.regs[1];
      tempb2:=$7;
    end else begin
      tempb:=(nes_mapper_0.regs[1] and $6) or 0;
      tempb2:=(nes_mapper_0.regs[1] and $6) or 1;
    end;
  end;
	set_prg_16($8000,tempb or ((nes_mapper_0.regs[0] and $70) shr 1));
	set_prg_16($c000,tempb2 or ((nes_mapper_0.regs[0] and $70) shr 1));
end;
begin
case direccion of
  $8000..$bfff:begin
                  if (direccion and $1)<>0 then ppu_nes_0.mirror:=MIRROR_HORIZONTAL
                      else ppu_nes_0.mirror:=MIRROR_VERTICAL;
                  nes_mapper_0.regs[0]:=(direccion shr 1) and $ff;
               end;
  $c000..$ffff:begin
                 nes_mapper_0.regs[1]:=direccion and 7;
                 ppu_nes_0.write_chr:=(direccion and $8)=0;
               end;
end;
update_221;
end;

procedure mapper_243_write_rom(direccion:word;valor:byte);
begin
case (direccion and $c101) of
  $4100:nes_mapper_0.latch1:=valor and 7;
  $4101:begin
          nes_mapper_0.dregs[nes_mapper_0.latch1]:=valor;
          case nes_mapper_0.latch1 of
            0,1,3:;
            2,4,6:set_chr_8(((nes_mapper_0.dregs[2] and 1) shl 3) or (nes_mapper_0.dregs[4] and 1) or ((nes_mapper_0.dregs[6] and 3) shl 1));
            5:set_prg_32(valor);
            7:case ((valor shr 1) and 3) of
                0:ppu_nes_0.mirror:=MIRROR_MAP243;
                1:ppu_nes_0.mirror:=MIRROR_HORIZONTAL;
                2:ppu_nes_0.mirror:=MIRROR_VERTICAL;
                3:ppu_nes_0.mirror:=MIRROR_HIGH;
              end;
          end;
        end;
end;
end;

procedure mapper_vrc_irq(estados_t:word);
procedure clock_irq(estados:byte);
begin
  nes_mapper_0.counter:=nes_mapper_0.counter+estados;
  if (nes_mapper_0.counter>$ff) then begin
    n2a03_0.m6502.change_irq(ASSERT_LINE);
    nes_mapper_0.counter:=nes_mapper_0.reload_counter;
  end;
end;
begin
if nes_mapper_0.irq_ena then begin
  if (nes_mapper_0.latch1 and 4)=0 then begin
    nes_mapper_0.needirqdelay:=nes_mapper_0.needirqdelay+(estados_t*3);
    if (nes_mapper_0.needirqdelay>341) then begin
      nes_mapper_0.needirqdelay:=nes_mapper_0.needirqdelay-341;
      clock_irq(1);
    end;
  end else begin
    clock_irq(estados_t);
  end;
end;
end;

function tnes_mapper.set_mapper(mapper:word;submapper:byte):boolean;
begin
  set_mapper:=true;
  self.mapper:=mapper;
  self.submapper:=submapper;
  n2a03_0.m6502.change_despues_instruccion(nil);
  self.calls.read_expansion:=nil;
  self.calls.write_expansion:=nil;
  self.calls.line_ack:=nil;
  self.calls.write_rom:=nil;
  self.calls.ppu_read:=nil;
  self.calls.read_prg_ram:=prg_ram_read;
  self.calls.write_prg_ram:=prg_ram_write;
  case mapper of
      0:;
      1:begin
          self.calls.write_rom:=mapper_1_write_rom;
          n2a03_0.m6502.change_despues_instruccion(mapper_1_delay);
        end;
      2:self.calls.write_rom:=mapper_2_write_rom;
      3:self.calls.write_rom:=mapper_3_write_rom;
      4:begin
            if self.submapper=1 then begin //MMC6
              self.calls.read_prg_ram:=mapper_mmc6_wram_read;
              self.calls.write_prg_ram:=mapper_mmc6_wram_write;
              self.calls.write_rom:=mapper_mmc6_write_rom;
            end else begin
              self.calls.write_rom:=mapper_4_write_rom;
            end;
            self.calls.line_ack:=mapper_4_line;
        end;
      5:begin
          self.calls.read_expansion:=mapper_5_read_extended;
          self.calls.write_expansion:=mapper_5_write_extended;
          self.calls.write_rom:=mapper_5_write_rom;
          self.calls.read_rom:=mapper_5_read_rom;
        end;
      7:self.calls.write_rom:=mapper_7_write_rom;
      9:begin
          self.calls.write_rom:=mapper_9_write_rom;
          self.calls.ppu_read:=mapper_9_ppu_read;
        end;
      10:begin
          self.calls.write_rom:=mapper_10_write_rom;
          self.calls.ppu_read:=mapper_9_ppu_read;
        end;
      11:self.calls.write_rom:=mapper_11_write_rom;
      12:begin
          self.calls.line_ack:=mapper_4_line;
          self.calls.write_rom:=mapper_12_write_rom;
          self.calls.write_expansion:=mapper_12_write_rom;
        end;
      13:begin
          //Tiene 4 paginas de chr en RAM!! uso los registros del mapper para el mapeo
          self.calls.write_rom:=mapper_13_write_rom;
          ppu_nes_0.write_chr:=true;
         end;
      15:self.calls.write_rom:=mapper_15_write_rom;
      18:begin
          self.calls.write_rom:=mapper_18_write_rom;
          n2a03_0.m6502.change_despues_instruccion(mapper_18_irq);
      end;
      21,25:begin
            self.calls.write_rom:=mapper_21_write_rom;
            n2a03_0.m6502.change_despues_instruccion(mapper_vrc_irq);
         end;
      22:self.calls.write_rom:=mapper_22_write_rom;
      23:self.calls.write_rom:=mapper_23_write_rom;
      32:self.calls.write_rom:=mapper_32_write_rom;
      33:self.calls.write_rom:=mapper_33_write_rom;
      34:begin
          self.calls.write_rom:=mapper_34_write_rom;
          self.calls.write_prg_ram:=mapper_34_write_rom;
      end;
      41:begin
          self.calls.write_rom:=mapper_41_write_rom;
          self.calls.write_prg_ram:=mapper_41_write_rom;
      end;
      42:begin
          self.calls.write_rom:=mapper_42_write_rom;
          n2a03_0.m6502.change_despues_instruccion(mapper_42_irq);
      end;
      48:begin
          self.calls.write_rom:=mapper_48_write_rom;
          self.calls.line_ack:=mapper_4_line;
        end;
      57:self.calls.write_rom:=mapper_57_write_rom;
      58,213:self.calls.write_rom:=mapper_58_write_rom;
      64:begin
          self.calls.write_rom:=mapper_64_write_rom;
          n2a03_0.m6502.change_despues_instruccion(mapper_64_irq);
          self.calls.line_ack:=mapper_64_line;
         end;
      65:begin
          self.calls.write_rom:=mapper_65_write_rom;
          n2a03_0.m6502.change_despues_instruccion(mapper_65_irq);
         end;
      66:self.calls.write_rom:=mapper_66_write_rom;
      67:begin
          self.calls.write_rom:=mapper_67_write_rom;
          n2a03_0.m6502.change_despues_instruccion(mapper_67_irq);
         end;
      68:self.calls.write_rom:=mapper_68_write_rom;
      69:begin
          self.calls.write_rom:=mapper_69_write_rom;
          n2a03_0.m6502.change_despues_instruccion(mapper_69_irq);
          self.calls.read_prg_ram:=mapper_69_read_prg_ram;
          self.calls.write_prg_ram:=mapper_69_write_prg_ram;
          if AY8910_0=nil then AY8910_0:=ay8910_chip.create(NTSC_CLOCK,AY8910,2);
          n2a03_0.add_more_sound(mapper_69_update_sound);
      end;
      70:self.calls.write_rom:=mapper_70_write_rom;
      71:self.calls.write_rom:=mapper_71_write_rom;
      73:begin
          self.calls.write_rom:=mapper_73_write_rom;
          n2a03_0.m6502.change_despues_instruccion(mapper_73_irq);
         end;
      75:self.calls.write_rom:=mapper_75_write_rom;
      76:self.calls.write_rom:=mapper_76_write_rom;
      79,146:self.calls.write_expansion:=mapper_79_write_rom;
      85:begin
            self.calls.write_rom:=mapper_85_write_rom;
            n2a03_0.m6502.change_despues_instruccion(mapper_vrc_irq);
         end;
      87:self.calls.write_prg_ram:=mapper_87_write_rom;
      88:self.calls.write_rom:=mapper_88_write_rom;
      89:self.calls.write_rom:=mapper_89_write_rom;
      93:self.calls.write_rom:=mapper_93_write_rom;
      94:self.calls.write_rom:=mapper_94_write_rom;
      95:self.calls.write_rom:=mapper_95_write_rom;
     105:begin
          self.calls.write_rom:=mapper_105_write_rom;
          n2a03_0.m6502.change_despues_instruccion(mapper_105_irq);
         end;
     113:self.calls.write_expansion:=mapper_113_write_rom;
     116:self.calls.write_expansion:=mapper_116_write_rom;
     132:begin
          self.calls.read_expansion:=mapper_132_read_exp;
          self.calls.write_expansion:=mapper_132_write_exp;
          self.calls.write_rom:=mapper_132_write_rom;
         end;
     133:self.calls.write_expansion:=mapper_133_write_rom;
     137:self.calls.write_expansion:=mapper_137_write_rom;
     139,138,141:self.calls.write_expansion:=mapper_139_write_rom;
     142:begin
          self.calls.write_rom:=mapper_142_write_rom;
          n2a03_0.m6502.change_despues_instruccion(mapper_142_irq);
         end;
     143:self.calls.read_expansion:=mapper_143_read_rom;
     145:self.calls.write_expansion:=mapper_145_write_rom;
     147:begin
            self.calls.write_expansion:=mapper_147_write_rom;
            self.calls.write_rom:=mapper_147_write_rom;
         end;
     148:self.calls.write_rom:=mapper_148_write_rom;
     149:self.calls.write_rom:=mapper_149_write_rom;
     150:begin
            self.calls.write_expansion:=mapper_150_write_rom;
            self.calls.read_expansion:=mapper_150_read_rom;
         end;
     152:self.calls.write_rom:=mapper_152_write_rom;
     154:self.calls.write_rom:=mapper_154_write_rom;
     172:begin
            self.calls.write_rom:=mapper_172_write_rom;
            self.calls.write_expansion:=mapper_172_write_rom;
            self.calls.read_expansion:=mapper_172_read;
         end;
     173:begin
          self.calls.read_expansion:=mapper_132_read_exp;
          self.calls.write_expansion:=mapper_132_write_exp;
          self.calls.write_rom:=mapper_173_write_rom;
         end;
     180:self.calls.write_rom:=mapper_180_write_rom;
     184:self.calls.write_prg_ram:=mapper_184_write_rom;
     185:self.calls.write_rom:=mapper_185_write_rom;
     206:self.calls.write_rom:=mapper_206_write_rom;
     212:begin
          self.calls.read_expansion:=mapper_212_read_exp;
          self.calls.write_rom:=mapper_212_write_rom;
         end;
     221:self.calls.write_rom:=mapper_221_write_rom;
     243:self.calls.write_expansion:=mapper_243_write_rom;
      else begin
            MessageDlg('NES: Mapper unknown!!! - Type: '+inttostr(mapper), mtError,[mbOk], 0);
            set_mapper:=false;
           end;
  end;
end;

procedure tnes_mapper.reset;
begin
  self.prg_ram_writeble:=false;
  self.prg_ram_enable:=false;
  self.latch0:=0;
  self.latch1:=0;
  self.reload:=false;
  self.counter:=0;
  self.irq_ena:=false;
  self.reload_counter:=0;
  self.serial_cnt:=0;
  fillchar(self.dregs,16,0);
  fillchar(self.regs,$31,0);
  self.chr_map[0]:=0;
  self.chr_map[1]:=1;
  self.clock_mode:=false;
  self.needirqdelay:=0;
  self.shift:=0;
  fillchar(self.ram,$400,0);
  case self.mapper of
    1:begin
          self.prg_ram_writeble:=true;
          self.regs[0]:=$c;
          set_prg_16($8000,0);
          set_prg_16($c000,self.last_prg-1);
      end;
    2,33,48,57,64,65,67,70,76,79,88,89,93,94,95,146,152,154,180,206:begin
          set_prg_16($8000,0);
          set_prg_16($c000,self.last_prg-1);
      end;
    4,12:begin
          self.prg_ram_writeble:=true;
          self.prg_ram_enable:=true;
          self.dregs[1]:=2;
          self.dregs[2]:=4;
          self.dregs[3]:=5;
          self.dregs[4]:=6;
          self.dregs[5]:=7;
          self.dregs[7]:=1;
          mapper_4_update_chr(0);
          mapper_4_update_prg(0);
          set_prg_16($8000,self.last_prg-1);
          set_prg_16($c000,self.last_prg-1);
      end;
    5:begin
        self.regs[0]:=3;
        self.regs[$17]:=$ff;
        set_prg_16($8000,self.last_prg-2);
        set_prg_16($c000,self.last_prg-1);
        self.prg_ram_writeble:=true;
        self.prg_ram_enable:=true;
        self.mul1:=$ff;
        self.mul2:=$ff;
      end;
    7,15,145,148,149,150,184,243:set_prg_32(0);
    9,10:begin
        set_prg_8($8000,0);
        set_prg_8($a000,(self.last_prg shl 1)-3);
        set_prg_8($c000,(self.last_prg shl 1)-2);
        set_prg_8($e000,(self.last_prg shl 1)-1);
        set_chr_8(0);
        self.regs[0]:=0;
        self.regs[1]:=0;
        self.regs[2]:=0;
        self.regs[3]:=0;
        self.latch0:=$fe;
        self.latch1:=$fe;
      end;
    11,58,212,213:begin
        set_prg_32(0);
        if self.last_chr<>0 then set_chr_8(0);
      end;
    18,21,22,23,25,85:begin
          set_prg_16($8000,0);
          set_prg_16($c000,self.last_prg-1);
          self.prg_ram_enable:=true;
          self.prg_ram_writeble:=true;
       end;
    32:begin
          if self.submapper=1 then ppu_nes_0.mirror:=MIRROR_HIGH;
          set_prg_16($8000,0);
          set_prg_16($c000,self.last_prg-1);
       end;
    34:begin
          self.regs[0]:=0;
          self.regs[1]:=0;
          self.regs[2]:=1;
          self.prg_ram_enable:=true;
          self.prg_ram_writeble:=true;
          set_prg_32(self.last_prg shr 1);
       end;
    41:begin
          set_prg_32(0);
          set_chr_8(0);
       end;
    42:begin
          self.prg_ram_enable:=true; //Solo ROM
          copymemory(@memoria[$8000],@self.prg[self.last_prg-2,0],$4000);
          copymemory(@memoria[$c000],@self.prg[self.last_prg-1,0],$4000);
       end;
    68:begin
          set_prg_16($8000,0);
          set_prg_16($c000,self.last_prg-1);
          self.prg_ram_writeble:=true;
       end;
    69:begin
          set_prg_16($8000,self.last_prg-2);
          set_prg_16($c000,self.last_prg-1);
          AY8910_0.reset;
      end;
    71:copymemory(@memoria[$c000],@self.prg[(self.last_prg-1),0],$4000);
    73:begin
          set_prg_16($8000,0);
          set_prg_16($c000,self.last_prg-1);
          self.prg_ram_writeble:=true;
          self.prg_ram_enable:=true;
       end;
    75:set_prg_8($e000,(self.last_prg shl 1)-1);
    105:begin
          set_prg_32(0);
          self.latch1:=$ff;
          self.prg_ena:=false;
        end;
    116:begin
          fillchar(self.regs,4,$ff);
          fillchar(self.dregs,16,$ff);
          set_prg_16($8000,0);
          set_prg_16($c000,self.last_prg-1);
          self.mode:=0;
        end;
    132,138,173:set_prg_32(0);
    137:begin
          set_prg_32(0);
          //IMPORTANTISIMO!!!!
          set_chr_4($1000,(self.last_chr shl 1)-1);
        end;
    139:begin
          set_prg_32(0);
          self.shift:=2;
          self.regs[0]:=1;
          self.regs[1]:=2;
          self.regs[2]:=3;
        end;
    141:begin
          set_prg_32(0);
          self.shift:=1;
          self.regs[0]:=1;
          self.regs[2]:=1;
        end;
    142:begin
          set_prg_8($e000,(self.last_prg shl 1)-1);
          self.prg_ram_enable:=true; //Solo ROM
        end;
    147:copymemory(@memoria[$c000],@self.prg[1,0],$4000);
    221:begin
          set_prg_16($8000,0);
          set_prg_16($c000,0);
        end;
  end;
end;

end.
