unit gb_mappers;
interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     main_engine,sysutils,file_engine,dialogs;
type
  tmapper_calls=record
      ext_ram_getbyte:function (direccion:word):byte;
      ext_ram_putbyte:procedure (direccion:word;valor:byte);
      rom_putbyte:procedure (direccion:word;valor:byte);
  end;
  tgb_mapper=class
        constructor create;
        destructor free;
      public
        mapper:byte;
        crc32:dword;
        ram_size:byte;
        rom_size:word;
        calls:tmapper_calls;
        rom_bank:array[0..$1ff,$0..$3fff] of byte;
        ram_bank:array[0..$f,$0..$1fff] of byte;
        procedure reset;
        procedure set_mapper(mapper:byte;crc32:dword;rom_size:word;ram_size:byte);
        function save_snapshot(datos:pbyte):dword;
        procedure load_snapshot(datos:pbyte);
      private
        regs:array[0..5] of byte;
        mbc1_shift,mbc1_mask,ram_nbank,ram_nbank2:byte;
        ram_enable,rtc_ready,map_enable,rom_mode:boolean;
        rom_nbank,rom_nbank2:word;
        //mmm01
        mux_mmc01,mode_mmc01,mode_we:boolean;
        ramb_masked,ramb_we,romb_we,ramb_mmc01:byte;
        romb_mmc01,romb_base:word;
        //mbc6
        rom_banka_enabled,rom_bankb_enabled:boolean;
    end;
var
  gb_mapper_0:tgb_mapper;

implementation
uses gb;

constructor tgb_mapper.create;
begin
end;

destructor tgb_mapper.free;
begin
end;

procedure tgb_mapper.reset;
begin
//El banco 0+1 siempre es el mismo
copymemory(@memoria[$0],@self.rom_bank[0,0],$4000);
copymemory(@memoria[$4000],@self.rom_bank[1,0],$4000);
self.map_enable:=false;
self.ram_enable:=false;
self.rom_mode:=false;
self.rom_nbank:=1;
self.rom_nbank2:=1;
self.ram_nbank:=0;
self.rtc_ready:=false;
case self.mapper of
  1..3:begin
          self.regs[0]:=1;
          self.regs[1]:=0;
       end;
  $b..$d:begin
          copymemory(@memoria[$0],@self.rom_bank[self.rom_size-2,0],$4000);
          copymemory(@memoria[$4000],@self.rom_bank[self.rom_size-1,0],$4000);
  end;
  $c1:self.map_enable:=true;
end;
end;

function tgb_mapper.save_snapshot(datos:pbyte):dword;
var
  temp:pbyte;
  buffer:array[0..29] of byte;
  size:dword;
begin
  temp:=datos;
  copymemory(temp,@self.rom_bank,sizeof(self.rom_bank));
  size:=sizeof(self.rom_bank);
  inc(temp,sizeof(self.rom_bank));
  copymemory(temp,@self.ram_bank,sizeof(self.ram_bank));
  size:=size+sizeof(self.ram_bank);
  inc(temp,sizeof(self.ram_bank));
  copymemory(temp,@self.regs,sizeof(self.regs));
  size:=size+sizeof(self.regs);
  inc(temp,sizeof(self.regs));
  buffer[0]:=self.mapper;
  copymemory(@buffer[1],@self.crc32,4);
  buffer[5]:=self.ram_size;
  copymemory(@buffer[6],@self.rom_size,2);
  buffer[8]:=self.mbc1_shift;
  buffer[9]:=self.mbc1_mask;
  buffer[10]:=self.ram_nbank;
  buffer[11]:=byte(self.ram_enable);
  buffer[12]:=byte(self.rtc_ready);
  buffer[13]:=byte(self.map_enable);
  buffer[14]:=byte(self.rom_mode);
  copymemory(@buffer[15],@self.rom_nbank,2);
  copymemory(@buffer[17],@self.rom_nbank2,2);
  buffer[19]:=byte(self.mux_mmc01);
  buffer[20]:=byte(self.mode_mmc01);
  buffer[21]:=byte(self.mode_we);
  buffer[22]:=self.ramb_masked;
  buffer[23]:=self.ramb_we;
  buffer[24]:=self.romb_we;
  buffer[25]:=self.ramb_mmc01;
  copymemory(@buffer[26],@self.romb_mmc01,2);
  copymemory(@buffer[28],@self.romb_base,2);
  copymemory(temp,@buffer[0],30);
  save_snapshot:=size+30;
end;

procedure tgb_mapper.load_snapshot(datos:pbyte);
var
  temp:pbyte;
  buffer:array[0..29] of byte;
begin
  temp:=datos;
  copymemory(@self.rom_bank,temp,sizeof(self.rom_bank));
  inc(temp,sizeof(self.rom_bank));
  copymemory(@self.ram_bank,temp,sizeof(self.ram_bank));
  inc(temp,sizeof(self.ram_bank));
  copymemory(@self.regs,temp,sizeof(self.regs));
  inc(temp,sizeof(self.regs));
  copymemory(@buffer[0],temp,30);
  self.mapper:=buffer[0];
  copymemory(@self.crc32,@buffer[1],4);
  self.ram_size:=buffer[5];
  copymemory(@self.rom_size,@buffer[6],2);
  self.mbc1_shift:=buffer[8];
  self.mbc1_mask:=buffer[9];
  self.ram_nbank:=buffer[10];
  self.ram_enable:=buffer[11]<>0;
  self.rtc_ready:=buffer[12]<>0;
  self.map_enable:=buffer[13]<>0;
  self.rom_mode:=buffer[14]<>0;
  copymemory(@self.rom_nbank,@buffer[15],2);
  copymemory(@self.rom_nbank2,@buffer[17],2);
  self.mux_mmc01:=buffer[19]<>0;
  self.mode_mmc01:=buffer[20]<>0;
  self.mode_we:=buffer[21]<>0;
  self.ramb_masked:=buffer[22];
  self.ramb_we:=buffer[23];
  self.romb_we:=buffer[24];
  self.ramb_mmc01:=buffer[25];
  copymemory(@self.romb_mmc01,@buffer[26],2);
  copymemory(@self.romb_base,@buffer[28],2);
end;

//MBC1
function get_ext_ram_mbc1(direccion:word):byte;
begin
if not(gb_mapper_0.ram_enable) then get_ext_ram_mbc1:=$ff
else case gb_mapper_0.ram_size of
        0:get_ext_ram_mbc1:=$ff;
        1:get_ext_ram_mbc1:=gb_mapper_0.ram_bank[0,direccion and $7ff];  //2k
        2:get_ext_ram_mbc1:=gb_mapper_0.ram_bank[0,direccion and $1fff];  //8k
        3:get_ext_ram_mbc1:=gb_mapper_0.ram_bank[gb_mapper_0.ram_nbank,direccion and $1fff];  //Banks
     end;
end;

procedure put_ext_ram_mbc1(direccion:word;valor:byte);
begin
if gb_mapper_0.ram_enable then case gb_mapper_0.ram_size of
                     0:;
                     1:gb_mapper_0.ram_bank[0,direccion and $7ff]:=valor;  //2k
                     2:gb_mapper_0.ram_bank[0,direccion and $1fff]:=valor;  //8k
                     3:gb_mapper_0.ram_bank[gb_mapper_0.ram_nbank,direccion and $1fff]:=valor;  //Banks
                   end;
end;

procedure putbyte_mbc1(direccion:word;valor:byte);
var
  tempb:byte;
begin
case (direccion and $e000) of
  $0:gb_mapper_0.ram_enable:=((valor and $f)=$a);
  $2000:begin
          gb_mapper_0.regs[0]:=valor and $1f;
          if gb_mapper_0.regs[0]=0 then gb_mapper_0.regs[0]:=1;
        end;
  $4000:gb_mapper_0.regs[1]:=valor and $3;
  $6000:gb_mapper_0.rom_mode:=(valor and 1)<>0;
end;
tempb:=((gb_mapper_0.regs[0] and gb_mapper_0.mbc1_mask) or (gb_mapper_0.regs[1] shl gb_mapper_0.mbc1_shift)) mod gb_mapper_0.rom_size;
if gb_mapper_0.rom_nbank<>tempb then begin
   copymemory(@memoria[$4000],@gb_mapper_0.rom_bank[tempb mod gb_mapper_0.rom_size,0],$4000);
   gb_mapper_0.rom_nbank:=tempb;
end;
if gb_mapper_0.rom_mode then begin
   tempb:=(gb_mapper_0.regs[1] shl gb_mapper_0.mbc1_shift) mod gb_mapper_0.rom_size;
   gb_mapper_0.ram_nbank:=gb_mapper_0.regs[1];
end else begin
    tempb:=0;
    gb_mapper_0.ram_nbank:=0;
end;
if tempb<>gb_mapper_0.rom_nbank2 then begin
   copymemory(@memoria[0],@gb_mapper_0.rom_bank[tempb,0],$4000);
   gb_mapper_0.rom_nbank2:=tempb;
end;
end;

//MMM01
function get_ext_ram_mmm01(direccion:word):byte;
begin
if not(gb_mapper_0.ram_enable) then get_ext_ram_mmm01:=$ff
else case gb_mapper_0.ram_size of
        0:get_ext_ram_mmm01:=$ff;
        1:get_ext_ram_mmm01:=gb_mapper_0.ram_bank[0,direccion and $7ff];  //2k
        2:get_ext_ram_mmm01:=gb_mapper_0.ram_bank[0,direccion and $1fff];  //8k
        3:get_ext_ram_mmm01:=gb_mapper_0.ram_bank[gb_mapper_0.ram_nbank,direccion and $1fff];  //Banks
     end;
end;

procedure put_ext_ram_mmm01(direccion:word;valor:byte);
begin
if gb_mapper_0.ram_enable then case gb_mapper_0.ram_size of
    0:;
    1:gb_mapper_0.ram_bank[0,direccion and $7ff]:=valor;  //2k
    2:gb_mapper_0.ram_bank[0,direccion and $1fff]:=valor;  //8k
    3:gb_mapper_0.ram_bank[gb_mapper_0.ram_nbank,direccion and $1fff]:=valor;  //Banks
end;
end;

procedure putbyte_mmm01(direccion:word;valor:byte);
begin
valor:=valor and $7f;
case direccion of
  $0000..$1fff:begin
                  gb_mapper_0.ram_enable:=(valor and $a)<>0;
                  if not(gb_mapper_0.map_enable) then begin
                    gb_mapper_0.ramb_we:=(valor shr 4) and 3;
                    gb_mapper_0.map_enable:=(valor and $40)=0;
                  end;
               end;
  $2000..$3fff:begin
                  if not(gb_mapper_0.map_enable) then gb_mapper_0.romb_mmc01:=(gb_mapper_0.romb_mmc01 and not($60)) or (valor and $60);
			            gb_mapper_0.romb_mmc01:=(gb_mapper_0.romb_mmc01 and (not($1f) or gb_mapper_0.romb_we)) or (valor and ($1f and not(gb_mapper_0.romb_we)));
               end;
  $4000..$5fff:begin
                  if not(gb_mapper_0.map_enable) then begin
				              gb_mapper_0.mode_we:=(valor and $40)=0;
				              gb_mapper_0.romb_mmc01:=(gb_mapper_0.romb_mmc01 and not($180)) or ((valor and $30) shl 3);
				              gb_mapper_0.ramb_mmc01:=(gb_mapper_0.ramb_mmc01 and not($0c)) or (valor and $0c);
			            end;
			            gb_mapper_0.ramb_mmc01:=(gb_mapper_0.ramb_mmc01 and (not($03) or gb_mapper_0.ramb_we)) or (valor and ($03 and not(gb_mapper_0.ramb_we)));
               end;
  $6000..$7fff:begin
                  if not(gb_mapper_0.map_enable) then begin
				            gb_mapper_0.mux_mmc01:=(valor and $40)<>0;
				            // m_romb_nwe is aligned to RA14, hence >> 1 instead of >> 2
				            gb_mapper_0.romb_we:=(valor and $3c) shr 1;
			            end;
			            if not(gb_mapper_0.mode_we) then gb_mapper_0.mode_mmc01:=(valor and $01)=0;
               end;
end;
gb_mapper_0.rom_nbank:=gb_mapper_0.romb_mmc01 and not($1e0 or gb_mapper_0.romb_we);
gb_mapper_0.romb_base:=gb_mapper_0.romb_mmc01 and ($1e0 or gb_mapper_0.romb_we);
if gb_mapper_0.mode_mmc01 then gb_mapper_0.ramb_masked:=gb_mapper_0.ramb_mmc01
  else gb_mapper_0.ramb_masked:=gb_mapper_0.ramb_mmc01 and not($03);
// zero-adjust RA18..RA14
if gb_mapper_0.rom_nbank=0 then gb_mapper_0.rom_nbank:=1;
// if unmapped, force
if not(gb_mapper_0.map_enable) then gb_mapper_0.rom_nbank:=1;
// RB 0 logic
// if (!(offset & 0x4000)) romb = 0x00; !!!!!!
// combine with base
gb_mapper_0.rom_nbank:=gb_mapper_0.rom_nbank or gb_mapper_0.romb_base;
	// multiplex with AA14..AA13
if gb_mapper_0.mux_mmc01 then gb_mapper_0.rom_nbank:=(gb_mapper_0.rom_nbank and not($60)) or ((gb_mapper_0.ramb_masked and $03) shl 5);
// if unmapped, force
if not(gb_mapper_0.map_enable) then gb_mapper_0.rom_nbank:=gb_mapper_0.rom_nbank or $1fe;
copymemory(@memoria[$4000],@gb_mapper_0.rom_bank[gb_mapper_0.rom_nbank mod gb_mapper_0.rom_size,0],$4000);
end;

//MBC2
function get_ext_ram_mbc2(direccion:word):byte;
begin
if gb_mapper_0.ram_enable then get_ext_ram_mbc2:=gb_mapper_0.ram_bank[0,direccion and $1ff]
  else get_ext_ram_mbc2:=$ff;
end;

procedure put_ext_ram_mbc2(direccion:word;valor:byte);
begin
if gb_mapper_0.ram_enable then gb_mapper_0.ram_bank[0,direccion and $1ff]:=$f0 or (valor and $f);
end;

procedure putbyte_mbc2(direccion:word;valor:byte);
var
   tempb:byte;
begin
tempb:=gb_mapper_0.rom_nbank;
valor:=valor and $f;
case direccion of
  $0..$3fff:begin
                 if ((direccion and $100)=0) then gb_mapper_0.ram_enable:=(valor=$a);
                 if ((direccion and $100)<>0) then if (valor=0) then tempb:=1
                                                      else tempb:=valor;
            end;
end;
if gb_mapper_0.rom_nbank<>tempb then begin
   copymemory(@memoria[$4000],@gb_mapper_0.rom_bank[tempb mod gb_mapper_0.rom_size,0],$4000);
   gb_mapper_0.rom_nbank:=tempb;
end;
end;

//MBC3
procedure putbyte_mbc3(direccion:word;valor:byte);
var
   tempb:byte;
   date:tdatetime;
   hora,min,sec,mili:word;
begin
tempb:=gb_mapper_0.rom_nbank;
case direccion of
  0..$1fff:gb_mapper_0.ram_enable:=((valor and $f)=$a);
  $2000..$3fff:begin
                 valor:=valor and $7f;
                 if valor=0 then tempb:=1
                    else tempb:=valor;
  end;
  $4000..$5fff:gb_mapper_0.ram_nbank:=valor;
  $6000..$7fff:begin //RTC
                  if (gb_mapper_0.rtc_ready and (valor=0)) then gb_mapper_0.rtc_ready:=false;
                  if (not(gb_mapper_0.rtc_ready) and (valor=1)) then begin
                     gb_mapper_0.rtc_ready:=true;
                     date:=time;
                     decodetime(date,hora,min,sec,mili);
                     gb_mapper_0.regs[0]:=sec;
                     gb_mapper_0.regs[1]:=min;
                     gb_mapper_0.regs[2]:=hora;
                  end;
               end;
end;
if gb_mapper_0.rom_nbank<>tempb then begin
   copymemory(@memoria[$4000],@gb_mapper_0.rom_bank[tempb mod gb_mapper_0.rom_size,0],$4000);
   gb_mapper_0.rom_nbank:=tempb;
end;
end;

function get_ext_ram_mbc3(direccion:word):byte;
begin
  get_ext_ram_mbc3:=$ff;
  if (gb_mapper_0.ram_enable and (gb_mapper_0.ram_nbank<4)) then get_ext_ram_mbc3:=gb_mapper_0.ram_bank[gb_mapper_0.ram_nbank,direccion and $1fff];
  if ((gb_mapper_0.ram_nbank>=8) and (gb_mapper_0.ram_nbank<=$c)) then get_ext_ram_mbc3:=gb_mapper_0.regs[gb_mapper_0.ram_nbank-8];
end;

procedure put_ext_ram_mbc3(direccion:word;valor:byte);
begin
  if (gb_mapper_0.ram_enable and (gb_mapper_0.ram_nbank<4)) then gb_mapper_0.ram_bank[gb_mapper_0.ram_nbank,direccion and $1fff]:=valor;
  if ((gb_mapper_0.ram_nbank>=8) and (gb_mapper_0.ram_nbank<=$c)) then gb_mapper_0.regs[gb_mapper_0.ram_nbank-8]:=valor;
end;

//MBC5
function get_ext_ram_mbc5(direccion:word):byte;
begin
if not(gb_mapper_0.ram_enable) then get_ext_ram_mbc5:=$ff
  else case gb_mapper_0.ram_size of
        0:get_ext_ram_mbc5:=$ff;
        1:get_ext_ram_mbc5:=gb_mapper_0.ram_bank[0,direccion and $1fff];
        else get_ext_ram_mbc5:=gb_mapper_0.ram_bank[gb_mapper_0.ram_nbank,direccion and $1fff];  //32k o 128Kb
       end;
end;

procedure put_ext_ram_mbc5(direccion:word;valor:byte);
begin
if gb_mapper_0.ram_enable then
  case gb_mapper_0.ram_size of
    0:;
    1:gb_mapper_0.ram_bank[0,direccion and $1fff]:=valor;
      else gb_mapper_0.ram_bank[gb_mapper_0.ram_nbank,direccion and $1fff]:=valor;
  end;
end;

procedure putbyte_mbc5(direccion:word;valor:byte);
var
   tempw:word;
begin
tempw:=gb_mapper_0.rom_nbank;
case direccion of
  $0000..$1fff:gb_mapper_0.ram_enable:=((valor and $f)=$a);
  $2000..$2fff:tempw:=(tempw and $100) or valor;
  $3000..$3fff:tempw:=(tempw and $ff) or ((valor and 1) shl 8);
  $4000..$5fff:gb_mapper_0.ram_nbank:=valor and $f;
end;
if gb_mapper_0.rom_nbank<>tempw then begin
   copymemory(@memoria[$4000],@gb_mapper_0.rom_bank[tempw mod gb_mapper_0.rom_size,0],$4000);
   gb_mapper_0.rom_nbank:=tempw;
end;
end;

//MBC6
procedure putbyte_mbc6(direccion:word;valor:byte);
var
   tempb,tempb2:byte;
begin
tempb:=gb_mapper_0.rom_nbank;
tempb2:=gb_mapper_0.rom_nbank2;
case direccion of
  $0000..$3ff:gb_mapper_0.ram_enable:=((valor and $f)=$a);
  $400..$7ff:gb_mapper_0.ram_nbank:=valor and $7;
  $800..$bff:gb_mapper_0.ram_nbank2:=valor and $7;
  $c00..$fff:gb_mapper_0.rom_mode:=(valor and 1)=0; //flash enable
  $1000:gb_mapper_0.mode_we:=(valor and 1)<>0; //flash write enable
  $2000..$27ff:tempb:=valor and $7f;
  $2800..$2fff:if valor=0 then gb_mapper_0.rom_banka_enabled:=true //ROM/flash select bankA
                  else if valor=8 then gb_mapper_0.rom_banka_enabled:=false;
  $3000..$37ff:tempb2:=valor and $7f;
  $3800..$3fff:if valor=0 then gb_mapper_0.rom_bankb_enabled:=true //ROM/flash select bankB
                  else if valor=8 then gb_mapper_0.rom_bankb_enabled:=false;
end;
if gb_mapper_0.rom_nbank<>tempb then begin
   copymemory(@memoria[$4000],@gb_mapper_0.rom_bank[(tempb shr 1) mod gb_mapper_0.rom_size,$2000*(tempb and 1)],$2000);
   gb_mapper_0.rom_nbank:=tempb;
end;
if gb_mapper_0.rom_nbank2<>tempb2 then begin
   copymemory(@memoria[$6000],@gb_mapper_0.rom_bank[(tempb2 shr 1) mod gb_mapper_0.rom_size,$2000*(tempb2 and 1)],$2000);
   gb_mapper_0.rom_nbank2:=tempb2;
end;

end;

function get_ext_ram_mbc6(direccion:word):byte;
begin
  get_ext_ram_mbc6:=$ff;
  if gb_mapper_0.ram_enable then begin
    case direccion of
      $a000..$afff:get_ext_ram_mbc6:=gb_mapper_0.ram_bank[gb_mapper_0.ram_nbank,direccion and $fff];
      $b000..$bfff:get_ext_ram_mbc6:=gb_mapper_0.ram_bank[gb_mapper_0.ram_nbank2 or $8,direccion and $fff];
    end;
  end;
end;

procedure put_ext_ram_mbc6(direccion:word;valor:byte);
begin
if gb_mapper_0.ram_enable then begin
  case direccion of
      $a000..$afff:gb_mapper_0.ram_bank[gb_mapper_0.ram_nbank,direccion and $fff]:=valor;
      $b000..$bfff:gb_mapper_0.ram_bank[gb_mapper_0.ram_nbank2 or $8,direccion and $fff]:=valor;
    end;
end;
end;

//MBC7
procedure putbyte_mbc7(direccion:word;valor:byte);
var
   tempb:byte;
begin
tempb:=gb_mapper_0.rom_nbank;
case direccion of
  $0000..$1fff:gb_mapper_0.ram_enable:=((valor and $f)=$a);
  $2000..$3fff:tempb:=valor;
  $4000..$5fff:gb_mapper_0.ram_nbank:=valor and $f;
end;
if gb_mapper_0.rom_nbank<>tempb then begin
   copymemory(@memoria[$4000],@gb_mapper_0.rom_bank[tempb mod gb_mapper_0.rom_size,0],$4000);
   gb_mapper_0.rom_nbank:=tempb;
end;
end;

function get_ext_ram_mbc7(direccion:word):byte;
begin
  get_ext_ram_mbc7:=$ff;
  if gb_mapper_0.ram_enable then get_ext_ram_mbc7:=gb_mapper_0.ram_bank[gb_mapper_0.ram_nbank,direccion and $1fff];
end;

procedure put_ext_ram_mbc7(direccion:word;valor:byte);
begin
if gb_mapper_0.ram_enable then gb_mapper_0.ram_bank[gb_mapper_0.ram_nbank,direccion and $1fff]:=valor;
end;

//Wisdom Tree
procedure putbyte_wtree(direccion:word;valor:byte);
var
  tempb:word;
begin
tempb:=(direccion and $ff) shl 1;
copymemory(@memoria[$0],@gb_mapper_0.rom_bank[(tempb and $1fe) mod gb_mapper_0.rom_size,0],$4000);
copymemory(@memoria[$4000],@gb_mapper_0.rom_bank[(tempb or 1) mod gb_mapper_0.rom_size,0],$4000);
end;

//M161
procedure putbyte_m161(direccion:word;valor:byte);
var
  tempb:word;
begin
if gb_mapper_0.map_enable then begin
  tempb:=(valor and $7) shl 1;
  copymemory(@memoria[$0],@gb_mapper_0.rom_bank[(tempb and $e) mod gb_mapper_0.rom_size,0],$4000);
  copymemory(@memoria[$4000],@gb_mapper_0.rom_bank[(tempb or 1) mod gb_mapper_0.rom_size,0],$4000);
  gb_mapper_0.map_enable:=false;
end;
end;

//Huc1
function get_ext_ram_huc1(direccion:word):byte;
begin
if gb_mapper_0.ram_enable then get_ext_ram_huc1:=$c0 //$c0 luz off, $c1 luz on
  else case gb_mapper_0.ram_size of
          0:get_ext_ram_huc1:=$ff;
          1:get_ext_ram_huc1:=gb_mapper_0.ram_bank[0,direccion and $7ff];  //2k
          2:get_ext_ram_huc1:=gb_mapper_0.ram_bank[0,direccion and $1fff];  //8k
          3:get_ext_ram_huc1:=gb_mapper_0.ram_bank[gb_mapper_0.ram_nbank,direccion and $1fff];  //Banks
       end;
end;

procedure put_ext_ram_huc1(direccion:word;valor:byte);
begin
if not(gb_mapper_0.ram_enable) then
  case gb_mapper_0.ram_size of
    0:;
    1:gb_mapper_0.ram_bank[0,direccion and $7ff]:=valor;  //2k
    2:gb_mapper_0.ram_bank[0,direccion and $1fff]:=valor;  //8k
    3:gb_mapper_0.ram_bank[gb_mapper_0.ram_nbank,direccion and $1fff]:=valor;  //Banks
  end;
end;

procedure putbyte_huc1(direccion:word;valor:byte);
var
   tempb:byte;
begin
tempb:=gb_mapper_0.rom_nbank;
case (direccion and $e000) of
  $0:gb_mapper_0.ram_enable:=((valor and $f)=$e);
  $2000:begin
             tempb:=valor and $3f;
             if (tempb=0) then tempb:=1;
        end;
  $4000:gb_mapper_0.ram_nbank:=valor and $3;
end;
if gb_mapper_0.rom_nbank<>tempb then begin
   copymemory(@memoria[$4000],@gb_mapper_0.rom_bank[tempb mod gb_mapper_0.rom_size,0],$4000);
   gb_mapper_0.rom_nbank:=tempb;
end;
end;

procedure tgb_mapper.set_mapper(mapper:byte;crc32:dword;rom_size:word;ram_size:byte);
var
  longitud:integer;
begin
  if crc32=$c38a775 then mapper:=$c1;
  if ((crc32=$5bfc3ef5) or (crc32=$6dbaa5e8)) then begin
    mapper:=mapper+10;
    rom_size:=32;
  end;
  //$5bfc3ef5
  self.mapper:=mapper;
  self.crc32:=crc32;
  self.rom_size:=rom_size;
  self.ram_size:=ram_size;
  self.calls.ext_ram_getbyte:=nil;
  self.calls.ext_ram_putbyte:=nil;
  self.calls.rom_putbyte:=nil;
  case mapper of
    0:; //No mapper
    $01..$03:begin  //mbc1
          self.calls.rom_putbyte:=putbyte_mbc1;
          case crc32 of
            $b91d6c8d,$509a6b73,$f724b5ce,$b1a8dfd0,$339f1694,$ad376905,$7d1d8fdc,$18b4a02:begin
                self.mbc1_mask:=$f;
                self.mbc1_shift:=4;
            end;
            else begin
                    self.mbc1_mask:=$1f;
                    self.mbc1_shift:=5;
                 end;
          end;
          case mapper of
            1:;
            2:begin //RAM
                self.calls.ext_ram_getbyte:=get_ext_ram_mbc1;
                self.calls.ext_ram_putbyte:=put_ext_ram_mbc1;
              end;
            3:begin //RAM + Battery
                self.calls.ext_ram_getbyte:=get_ext_ram_mbc1;
                self.calls.ext_ram_putbyte:=put_ext_ram_mbc1;
                if read_file_size(nv_ram_name,longitud) then read_file(nv_ram_name,@self.ram_bank[0,0],longitud);
                gb_0.hay_nvram:=true;
              end;
          end;
      end;
      $5,$6:begin //mbc2
        self.calls.rom_putbyte:=putbyte_mbc2;
        self.calls.ext_ram_getbyte:=get_ext_ram_mbc2;
        self.calls.ext_ram_putbyte:=put_ext_ram_mbc2;
        gb_mapper_0.ram_size:=0;
        if mapper=6 then begin //Battery (No extra RAM!)
           if read_file_size(nv_ram_name,longitud) then read_file(nv_ram_name,@self.ram_bank[0,0],longitud);
           gb_0.hay_nvram:=true;
        end;
      end;
      $b..$d:begin //mmm01
            self.calls.rom_putbyte:=putbyte_mmm01;
            self.calls.ext_ram_getbyte:=get_ext_ram_mmm01;
            self.calls.ext_ram_putbyte:=put_ext_ram_mmm01;
          end;
      $f..$13:begin //mbc3
            self.calls.rom_putbyte:=putbyte_mbc3;
            case mapper of
                $f:begin //Timer + Battery
                      if read_file_size(nv_ram_name,longitud) then read_file(nv_ram_name,@self.ram_bank[0,0],longitud);
                      gb_0.hay_nvram:=true;
                   end;
                $10,$13:begin //[Timer] + RAM + Battery
                           self.calls.ext_ram_getbyte:=get_ext_ram_mbc3;
                           self.calls.ext_ram_putbyte:=put_ext_ram_mbc3;
                           if read_file_size(nv_ram_name,longitud) then read_file(nv_ram_name,@self.ram_bank[0,0],longitud);
                           gb_0.hay_nvram:=true;
                        end;
                $11:;
                $12:begin //RAM
                      self.calls.ext_ram_getbyte:=get_ext_ram_mbc3;
                      self.calls.ext_ram_putbyte:=put_ext_ram_mbc3;
                end;
            end;
          end;
      $19..$1e:begin //mbc5
          self.calls.rom_putbyte:=putbyte_mbc5;
          case mapper of
            $19,$1c:; // [Rumble]
            $1a,$1d:begin //RAM + [Rumble]
                      self.calls.ext_ram_getbyte:=get_ext_ram_mbc5;
                      self.calls.ext_ram_putbyte:=put_ext_ram_mbc5;
                    end;
            $1b,$1e:begin //RAM + Battery + [Rumble]
                      self.calls.ext_ram_getbyte:=get_ext_ram_mbc5;
                      self.calls.ext_ram_putbyte:=put_ext_ram_mbc5;
                      if read_file_size(nv_ram_name,longitud) then read_file(nv_ram_name,@self.ram_bank[0,0],longitud);
                      gb_0.hay_nvram:=true;
                    end;
          end;
         end;
      $20:begin
             self.calls.rom_putbyte:=putbyte_mbc6;
             self.calls.ext_ram_getbyte:=get_ext_ram_mbc6;
             self.calls.ext_ram_putbyte:=put_ext_ram_mbc6;
          end;
      $22:begin //RAM + Acelerometro
             self.calls.rom_putbyte:=putbyte_mbc7;
             self.calls.ext_ram_getbyte:=get_ext_ram_mbc7;
             self.calls.ext_ram_putbyte:=put_ext_ram_mbc7;
          end;
      $c0:begin  //Wisdom Tree
              self.calls.rom_putbyte:=putbyte_wtree;
          end;
      $c1:begin
          self.calls.rom_putbyte:=putbyte_m161;
          end;
      $ff:begin //HuC-1 (RAM+Battery)
            self.calls.rom_putbyte:=putbyte_huc1;
            self.calls.ext_ram_getbyte:=get_ext_ram_huc1;
            self.calls.ext_ram_putbyte:=put_ext_ram_huc1;
            if read_file_size(nv_ram_name,longitud) then read_file(nv_ram_name,@self.ram_bank[0,0],longitud);
            gb_0.hay_nvram:=true;
          end;
      else MessageDlg('Mapper '+inttohex(mapper,2)+' no implementado', mtInformation,[mbOk], 0);
  end;
end;

end.
