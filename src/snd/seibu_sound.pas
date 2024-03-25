unit seibu_sound;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     sound_engine,misc_functions,main_engine,nz80,ym_3812,oki6295,
     ym_2151,msm5205;

type
  seibu_adpcm_chip=class
      constructor create;
      procedure free;
    public
      procedure reset;
      procedure adr_w(dir:word;valor:byte);
      procedure ctl_w(valor:byte);
    private
      msm5205_num:byte;
  end;
  seibu_snd_type=class(snd_chip_class)
      constructor create(snd_type:byte;clock,cpu_sync:dword;snd_rom:pbyte;encrypted:boolean;amp:single=1);
      destructor free;
   public
      z80:cpu_z80;
      adpcm_0,adpcm_1:seibu_adpcm_chip;
      sound_rom:array[0..1,0..$7fff] of byte;
      input:byte;
      procedure reset;
      function get(direccion:byte):byte;
      procedure put(direccion,valor:byte);
      function oki_6295_get_rom_addr:pbyte;
      procedure adpcm_load_roms(adpcm_rom:pbyte;size:dword);
   private
      main2sub_pending,sub2main_pending,encrypted:boolean;
      sound_latch,sub2main:array[0..1] of byte;
      decrypt:array[0..$1fff] of byte;
      snd_type,snd_bank,irq1,irq2:byte;
      procedure update_irq_lines(param:byte);
      procedure decript_sound;
  end;
const
  RESET_ASSERT=0;
  RST10_ASSERT=1;
	RST10_CLEAR=2;
  RST18_ASSERT=3;
	RST18_CLEAR=4;
  SEIBU_ADPCM=0;
  SEIBU_OKI=1;
var
  seibu_snd_0:seibu_snd_type;
  num_msm5205:integer=-1;

implementation

function oki_getbyte(direccion:word):byte;
begin
case direccion of
  0..$1fff:if seibu_snd_0.z80.opcode then oki_getbyte:=seibu_snd_0.decrypt[direccion]
              else oki_getbyte:=mem_snd[direccion];
  $2000..$27ff:oki_getbyte:=mem_snd[direccion];
  $4008:oki_getbyte:=ym3812_0.status;
  $4010:oki_getbyte:=seibu_snd_0.sound_latch[0];
  $4011:oki_getbyte:=seibu_snd_0.sound_latch[1];
  $4012:oki_getbyte:=byte(seibu_snd_0.sub2main_pending);
  $4013:oki_getbyte:=seibu_snd_0.input;
  $6000:oki_getbyte:=oki_6295_0.read;
  $8000..$ffff:oki_getbyte:=seibu_snd_0.sound_rom[seibu_snd_0.snd_bank,direccion and $7fff];
  else if seibu_snd_0.z80.opcode then oki_getbyte:=seibu_snd_0.decrypt[direccion]
              else oki_getbyte:=mem_snd[direccion];
end;
end;

procedure oki_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$1fff,$8000..$ffff:; //ROM
  $2000..$27ff:mem_snd[direccion]:=valor;
  $4000:begin
          seibu_snd_0.main2sub_pending:=false;
        	seibu_snd_0.sub2main_pending:=true;
        end;
  $4001:;//seibu_update_irq_lines(RESET_ASSERT);
  $4002:;
  $4003:seibu_snd_0.update_irq_lines(RST18_CLEAR);
  $4007:seibu_snd_0.snd_bank:=valor and 1;
  $4008:ym3812_0.control(valor);
  $4009:ym3812_0.write(valor);
  $4018:seibu_snd_0.sub2main[0]:=valor;
  $4019:seibu_snd_0.sub2main[1]:=valor;
  $6000:oki_6295_0.write(valor);
end;
end;

procedure oki_sound_update;
begin
  ym3812_0.update;
  oki_6295_0.update;
end;

function adpcm_getbyte(direccion:word):byte;
begin
case direccion of
  0..$1fff:if seibu_snd_0.z80.opcode then adpcm_getbyte:=seibu_snd_0.decrypt[direccion]
              else adpcm_getbyte:=mem_snd[direccion];
  $2000..$27ff,$8000..$ffff:adpcm_getbyte:=mem_snd[direccion];
  $4008:adpcm_getbyte:=ym2151_0.status;
  $4010:adpcm_getbyte:=seibu_snd_0.sound_latch[0];
  $4011:adpcm_getbyte:=seibu_snd_0.sound_latch[1];
  $4012:adpcm_getbyte:=byte(seibu_snd_0.sub2main_pending);
  $4013:adpcm_getbyte:=seibu_snd_0.input;
end;
end;

procedure adpcm_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$1fff,$8000..$ffff:; //ROM
  $2000..$27ff:mem_snd[direccion]:=valor;
  $4001,$4002:;
  $4003:seibu_snd_0.update_irq_lines(RST18_CLEAR);
  $4005:seibu_snd_0.adpcm_0.adr_w(0,valor);
  $4006:seibu_snd_0.adpcm_0.adr_w(1,valor);
  $4008:ym2151_0.reg(valor);
  $4009:ym2151_0.write(valor);
  $4018:seibu_snd_0.sub2main[0]:=valor;
  $4019:seibu_snd_0.sub2main[1]:=valor;
  $401a:seibu_snd_0.adpcm_0.ctl_w(valor);
  $401b:;
  $6005:seibu_snd_0.adpcm_1.adr_w(0,valor);
  $6006:seibu_snd_0.adpcm_1.adr_w(1,valor);
  $601a:seibu_snd_0.adpcm_1.ctl_w(valor);
end;
end;

procedure adpcm_sound_update;
begin
  ym2151_0.update;
  msm5205_0.update;
  msm5205_1.update;
end;

procedure snd_irq(irqstate:byte);
begin
  if irqstate=1 then seibu_snd_0.update_irq_lines(RST10_ASSERT)
    else seibu_snd_0.update_irq_lines(RST10_CLEAR);
end;

constructor seibu_snd_type.create(snd_type:byte;clock,cpu_sync:dword;snd_rom:pbyte;encrypted:boolean;amp:single=1);
begin
  self.z80:=cpu_z80.create(clock,cpu_sync);
  self.snd_type:=snd_type;
  self.encrypted:=encrypted;
  //Copio los datos en las dos memorias, por si no estan cifrados...
  copymemory(@self.decrypt,snd_rom,$2000);
  copymemory(@mem_snd,snd_rom,$2000);
  case snd_type of
    SEIBU_ADPCM:begin
        self.z80.change_ram_calls(adpcm_getbyte,adpcm_putbyte);
        self.z80.init_sound(adpcm_sound_update);
        self.adpcm_0:=seibu_adpcm_chip.create;
        self.adpcm_1:=seibu_adpcm_chip.create;
        ym2151_0:=ym2151_chip.create(clock,amp);
        ym2151_0.change_irq_func(snd_irq);
    end;
    SEIBU_OKI:begin
        self.z80.change_ram_calls(oki_getbyte,oki_putbyte);
        self.z80.init_sound(oki_sound_update);
        ym3812_0:=ym3812_chip.create(YM3812_FM,clock,amp);
        ym3812_0.change_irq_calls(snd_irq);
        oki_6295_0:=snd_okim6295.create(1000000,OKIM6295_PIN7_HIGH,0.40);
    end;
  end;
end;

destructor seibu_snd_type.free;
begin
  self.z80.free;
  case self.snd_type of
    SEIBU_ADPCM:begin
        self.adpcm_0.free;
        self.adpcm_1.free;
        if ym2151_0<>nil then ym2151_0.free;
    end;
    SEIBU_OKI:begin
        if ym3812_0<>nil then ym3812_0.free;
        if oki_6295_0<>nil then oki_6295_0.free;
    end;
  end;
end;

procedure seibu_snd_type.reset;
begin
 self.irq1:=$ff;
 self.irq2:=$ff;
 self.main2sub_pending:=false;
 self.sub2main_pending:=false;
 self.sound_latch[0]:=0;
 self.sound_latch[1]:=0;
 self.z80.reset;
 self.snd_bank:=0;
 if self.encrypted then self.decript_sound;
 case self.snd_type of
    SEIBU_ADPCM:begin
        ym2151_0.reset;
        self.adpcm_0.reset;
        self.adpcm_1.reset;
    end;
    SEIBU_OKI:begin
        ym3812_0.reset;
        oki_6295_0.reset;
    end;
 end;
end;

function seibu_snd_type.get(direccion:byte):byte;
var
  ret:byte;
begin
ret:=$ff;
case direccion of
    2:ret:=sub2main[0];
    3:ret:=sub2main[1];
    5:ret:=byte(main2sub_pending);
end;
get:=ret;
end;

procedure seibu_snd_type.put(direccion,valor:byte);
begin
case direccion of
  0:sound_latch[0]:=valor;
  1:sound_latch[1]:=valor;
  4:self.update_irq_lines(RST18_ASSERT);
  2,6:begin
          sub2main_pending:=false;
          main2sub_pending:=true;
       end;
end;
end;

procedure seibu_snd_type.update_irq_lines(param:byte);
begin
	case param of
		RESET_ASSERT:begin
        irq1:=$ff;
        irq2:=$ff;
      end;
		RST10_ASSERT:irq1:=$d7;
		RST10_CLEAR:irq1:=$ff;
    RST18_ASSERT:irq2:=$df;
		RST18_CLEAR:irq2:=$ff;
  end;
  self.z80.im0:=self.irq1 and self.irq2;
	if (self.irq1 and self.irq2)=$ff then self.z80.change_irq(CLEAR_LINE)
  	else self.z80.change_irq(ASSERT_LINE);
end;

procedure seibu_snd_type.decript_sound;
var
  f,pos:dword;
  data_in:array[0..$1fff] of byte;
function decrypt_data(a:word;src:byte):byte;
begin
  if (BIT(a,9)  and  BIT(a,8)) then src:=src xor $80;
	if (BIT(a,11) and  BIT(a,4) and BIT(a,1)) then src:=src xor $40;
	if (BIT(a,11) and not(BIT(a,8)) and BIT(a,1)) then src:=src xor $04;
	if (BIT(a,13) and not(BIT(a,6)) and BIT(a,4)) then src:=src xor $02;
	if (not(BIT(a,11)) and  BIT(a,9) and BIT(a,2)) then src:=src xor $01;
	if (BIT(a,13) and  BIT(a,4)) then src:=BITSWAP8(src,7,6,5,4,3,2,0,1);
	if (BIT(a, 8) and  BIT(a,4)) then src:=BITSWAP8(src,7,6,5,4,2,3,1,0);
  decrypt_data:=src;
end;
function decrypt_opcode(a:word;src:byte):byte;
begin
  if (BIT(a,9) and BIT(a,8)) then src:=src xor $80;
	if (BIT(a,11) and  BIT(a,4) and  BIT(a,1)) then src:=src xor $40;
	if (not(BIT(a,13)) and BIT(a,12)) then src:=src xor $20;
	if (not(BIT(a,6)) and BIT(a,1)) then src:=src xor $10;
	if (not(BIT(a,12)) and BIT(a,2)) then src:=src xor $08;
	if (BIT(a,11) and not(BIT(a,8)) and BIT(a,1)) then src:=src xor $04;
	if (BIT(a,13) and not(BIT(a,6)) and BIT(a,4)) then src:=src xor $02;
	if (not(BIT(a,11)) and BIT(a,9) and BIT(a,2)) then src:=src xor $01;
	if (BIT(a,13) and BIT(a,4)) then src:=BITSWAP8(src,7,6,5,4,3,2,0,1);
	if (BIT(a, 8) and BIT(a,4)) then src:=BITSWAP8(src,7,6,5,4,2,3,1,0);
	if (BIT(a,12) and  BIT(a,9)) then src:=BITSWAP8(src,7,6,4,5,3,2,1,0);
	if (BIT(a,11) and not(BIT(a,6))) then src:=BITSWAP8(src,6,7,5,4,3,2,1,0);
  decrypt_opcode:=src;
end;
begin
  //Copio los datos temporalmente a un buffer, los voy a machacar...
  copymemory(@data_in,@self.decrypt,$2000);
  for f:=0 to $1fff do begin
    pos:=BITSWAP24(f,23,22,21,20,19,18,17,16,13,14,15,12,11,10,9,8,7,6,5,4,3,2,1,0);
    mem_snd[f]:=decrypt_data(f,data_in[pos]);
		self.decrypt[f]:=decrypt_opcode(f,data_in[pos]);
  end;
end;

//ADPCM
{procedure adpcm_0_update;
var
  tempb:byte;
begin
if not(seibu_snd_0.adpcm_0.playing) then exit;
if (msm5205_0.data_val<>-1) then begin
  msm5205_0.data_w(msm5205_0.data_val and $f);
  msm5205_0.data_val:=-1;
  msm5205_0.pos:=msm5205_0.pos+1;
  if (msm5205_0.pos>=msm5205_0.end_) then begin
		msm5205_0.reset_w(1);
    seibu_snd_0.adpcm_0.playing:=false;
  end;
end else begin
  msm5205_0.data_val:=msm5205_0.rom_data[msm5205_0.pos];
  msm5205_0.data_w(msm5205_0.data_val shr 4);
end;
end;

procedure adpcm_1_update;
var
  tempb:byte;
begin
if not(seibu_snd_0.adpcm_1.playing) then exit;
if (msm5205_1.data_val<>-1) then begin
  msm5205_1.data_w(msm5205_1.data_val and $f);
  msm5205_1.data_val:=-1;
  msm5205_1.pos:=msm5205_1.pos+1;
  if (msm5205_1.pos>=msm5205_1.end_) then begin
		msm5205_1.reset_w(1);
    seibu_snd_0.adpcm_1.playing:=false;
  end;
end else begin
  msm5205_1.data_val:=msm5205_1.rom_data[msm5205_1.pos];
  msm5205_1.data_w(msm5205_1.data_val shr 4);
end;
end;}

constructor seibu_adpcm_chip.create;
begin
  num_msm5205:=num_msm5205+1;
  self.msm5205_num:=num_msm5205;
  case num_msm5205 of
    0:begin
        msm5205_0:=msm5205_chip.create(12000000 div 32,MSM5205_S48_4B,0.4,$10000);
        //msm5205_0.change_advance(adpcm_0_update);
      end;
    1:begin
        msm5205_1:=msm5205_chip.create(12000000 div 32,MSM5205_S48_4B,0.4,$10000);
        //msm5205_1.change_advance(adpcm_1_update);
    end;
  end;
end;

procedure seibu_adpcm_chip.free;
begin
  case self.msm5205_num of
    0:if msm5205_0<>nil then msm5205_0.free;
    1:if msm5205_1<>nil then msm5205_1.free;
  end;
  num_msm5205:=num_msm5205-1;
end;

procedure seibu_adpcm_chip.reset;
begin
  //self.playing:=false;
  case self.msm5205_num of
      0:msm5205_0.reset;
      1:msm5205_1.reset;
  end;
end;

procedure seibu_adpcm_chip.adr_w(dir:word;valor:byte);
begin
if self.msm5205_num=0 then begin
  if (dir<>0) then msm5205_0.end_:=valor shl 8
    else msm5205_0.pos:=valor shl 8;
end else begin
  if (dir<>0) then msm5205_1.end_:=valor shl 8
    else msm5205_1.pos:=valor shl 8;
end;
end;

procedure seibu_adpcm_chip.ctl_w(valor:byte);
begin
  // sequence is 00 02 01 each time.
	case valor of
		0:if self.msm5205_num=0 then msm5205_0.reset_w(true)
          else msm5205_1.reset_w(true);
		1:if self.msm5205_num=0 then msm5205_0.reset_w(false)
          else msm5205_1.reset_w(false);
    2:;
  end;
end;

procedure seibu_snd_type.adpcm_load_roms(adpcm_rom:pbyte;size:dword);
var
  f:dword;
begin
for f:=0 to (size-1) do begin
  msm5205_0.rom_data[f]:=BITSWAP8(adpcm_rom[f],7,5,3,1,6,4,2,0);
  msm5205_1.rom_data[f]:=BITSWAP8(adpcm_rom[size+f],7,5,3,1,6,4,2,0);
end;
end;

function seibu_snd_type.oki_6295_get_rom_addr:pbyte;
begin
  oki_6295_get_rom_addr:=oki_6295_0.get_rom_addr;
end;

end.
