unit taito_cchip;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     rom_engine,upd7810,cpu_misc,main_engine,timer_engine;

type
    cchip_chip=class
        constructor create(clock:dword);
        destructor free;
      public
        upd7810:cpu_upd7810;
        function asic_r(direccion:word):byte;
        procedure asic_w(direccion:word;valor:byte);
        function mem_r(direccion:word):byte;
        procedure mem_w(direccion:word;valor:byte);
        procedure set_int;
        procedure reset;
        function get_eeprom_dir:pbyte;
        procedure change_ad(ad_in:upd7810_cb);
        procedure change_in(ca,cb,cc,cd,cf:upd7810_cb);
      private
          upd4464_ram:array[0..7,0..$3ff] of byte;
          asic_ram:array[0..3] of byte;
          upd4464_bank:byte;
          cchip_rom:array[0..$fff] of byte;
          eeprom:array[0..$1fff] of byte;
          in_ad:function:byte;
          in_ca,in_cb,in_cc,in_cd,in_cf:function:byte;
    end;

var
  cchip_0:cchip_chip;
  cchip_timer:byte;

implementation
const
  tcchip_rom:tipo_roms=(n:'cchip_upd78c11.bin';l:$1000;p:0;crc:$43021521);

procedure cchip_chip.change_ad(ad_in:upd7810_cb);
begin
  self.in_ad:=ad_in;
end;

procedure cchip_chip.change_in(ca,cb,cc,cd,cf:upd7810_cb);
begin
  self.in_ca:=ca;
  self.in_cb:=cb;
  self.in_cc:=cc;
  self.in_cd:=cd;
  self.in_cf:=cf;
end;

function an_0:byte;
begin
  an_0:=(cchip_0.in_ad shr 0) and 1;
end;

function an_1:byte;
begin
  an_1:=(cchip_0.in_ad shr 1) and 1;
end;

function an_2:byte;
begin
  an_2:=(cchip_0.in_ad shr 2) and 1;
end;

function an_3:byte;
begin
  an_3:=(cchip_0.in_ad shr 3) and 1;
end;

function an_4:byte;
begin
  an_4:=(cchip_0.in_ad shr 4) and 1;
end;

function an_5:byte;
begin
  an_5:=(cchip_0.in_ad shr 5) and 1;
end;

function an_6:byte;
begin
  an_6:=(cchip_0.in_ad shr 6) and 1;
end;

function an_7:byte;
begin
  an_7:=(cchip_0.in_ad shr 7) and 1;
end;

function ca_cb(mask:byte):byte;
begin
  if addr(cchip_0.in_ca)<>nil then ca_cb:=cchip_0.in_ca
    else ca_cb:=$ff;
end;

function cb_cb(mask:byte):byte;
begin
  if addr(cchip_0.in_cb)<>nil then cb_cb:=cchip_0.in_cb
    else cb_cb:=$ff;
end;

function cc_cb(mask:byte):byte;
begin
  if addr(cchip_0.in_cc)<>nil then cc_cb:=cchip_0.in_cc
    else cc_cb:=$ff;
end;

function cd_cb(mask:byte):byte;
begin
  if addr(cchip_0.in_cd)<>nil then cd_cb:=cchip_0.in_cd
    else cd_cb:=$ff;
end;

function cf_cb(mask:byte):byte;
begin
  if addr(cchip_0.in_cf)<>nil then cf_cb:=cchip_0.in_cf
    else cf_cb:=$ff;
end;

function cchip_getbyte(direccion:word):byte;
begin
case direccion of
  0..$fff:cchip_getbyte:=cchip_0.cchip_rom[direccion];
  $1000..$13ff:cchip_getbyte:=cchip_0.mem_r(direccion and $3ff);
  $1400..$17ff:cchip_getbyte:=cchip_0.asic_r(direccion and $3ff);
  $2000..$3fff:cchip_getbyte:=cchip_0.eeprom[direccion and $1fff];
  $ff00..$ffff:cchip_getbyte:=cchip_0.upd7810.ram[direccion and $ff];
end;
end;

procedure cchip_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$fff,$2000..$3fff:; //ROM + EEPROM
  $1000..$13ff:cchip_0.mem_w(direccion and $3ff,valor);
  $1400..$17ff:cchip_0.asic_w(direccion and $3ff,valor);
  $ff00..$ffff:cchip_0.upd7810.ram[direccion and $ff]:=valor;
end;
end;

procedure clear_irq;
begin
  timers.enabled(cchip_timer,false);
  cchip_0.upd7810.set_input_line(UPD7810_INTF1,CLEAR_LINE);
end;

constructor cchip_chip.create(clock:dword);
var
  dir:string;
begin
  dir:=directory.arcade_list_roms[find_rom_multiple_dirs('cchip.zip')];
  carga_rom_zip(dir+'cchip.zip',tcchip_rom.n,@self.cchip_rom,tcchip_rom.l,tcchip_rom.crc,false);
  self.upd7810:=cpu_upd7810.create(clock,CPU_7810);
  self.upd7810.change_ram_calls(cchip_getbyte,cchip_putbyte);
  self.upd7810.change_an(an_0,an_1,an_2,an_3,an_4,an_5,an_6,an_7);
  self.upd7810.change_in(ca_cb,cb_cb,cc_cb,cd_cb,cf_cb);
  cchip_timer:=timers.init(self.upd7810.numero_cpu,10,clear_irq,nil,false);
end;

destructor cchip_chip.free;
begin
  self.upd7810.free;
end;

procedure cchip_chip.reset;
begin
  self.asic_ram[0]:=0;
  self.asic_ram[1]:=0;
  self.asic_ram[2]:=0;
  self.asic_ram[3]:=0;
  upd4464_bank:=0;
  self.upd7810.reset;
end;

function cchip_chip.get_eeprom_dir:pbyte;
begin
  get_eeprom_dir:=@self.eeprom;
end;

function cchip_chip.asic_r(direccion:word):byte;
begin
	if (direccion<$200) then asic_r:=self.asic_ram[direccion and 3]// 400-5ff is asic 'ram'
	  else asic_r:=0; // 600-7ff is write-only(?) asic banking reg, may read as open bus or never assert /DTACK on read?
end;

procedure cchip_chip.asic_w(direccion:word;valor:byte);
begin
	if (direccion=$200) then upd4464_bank:=valor
	  else self.asic_ram[direccion and 3]:=valor;
end;

function cchip_chip.mem_r(direccion:word):byte;
begin
  mem_r:=upd4464_ram[upd4464_bank and 7,direccion and $3ff];
end;

procedure cchip_chip.mem_w(direccion:word;valor:byte);
begin
	 upd4464_ram[upd4464_bank and 7,direccion and $3ff]:=valor;
end;

procedure cchip_chip.set_int;
begin
  cchip_0.upd7810.set_input_line(UPD7810_INTF1,ASSERT_LINE);
  timers.enabled(cchip_timer,true);
end;

end.
