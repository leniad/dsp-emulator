unit gb_mappers;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     main_engine;

type
  tgb_mapper=record
      ext_ram_getbyte:function (direccion:word):byte;
      ext_ram_putbyte:procedure (direccion:word;valor:byte);
      rom_putbyte:procedure (direccion:word;valor:byte);
  end;

//Mappers
procedure gb_putbyte_mbc1(direccion:word;valor:byte);
function gb_get_ext_ram_mbc1(direccion:word):byte;
procedure gb_put_ext_ram_mbc1(direccion:word;valor:byte);
procedure gb_putbyte_mmm01(direccion:word;valor:byte);
function gb_get_ext_ram_mmm01(direccion:word):byte;
procedure gb_put_ext_ram_mmm01(direccion:word;valor:byte);
procedure gb_putbyte_mbc2(direccion:word;valor:byte);
function gb_get_ext_ram_mbc2(direccion:word):byte;
procedure gb_put_ext_ram_mbc2(direccion:word;valor:byte);
function gb_get_ext_ram_mbc5(direccion:word):byte;
procedure gb_put_ext_ram_mbc5(direccion:word;valor:byte);
procedure gb_putbyte_mbc5(direccion:word;valor:byte);
procedure gb_putbyte_huc1(direccion:word;valor:byte);
function gb_get_ext_ram_huc1(direccion:word):byte;
procedure gb_put_ext_ram_huc1(direccion:word;valor:byte);


var
  gb_mapper:tgb_mapper;
  rom_bank:array[0..$1ff,$0..$3fff] of byte;
  ram_bank:array[0..$f,$0..$1fff] of byte;
  reg1,reg2,reg3,reg4,ram_nbank:byte;
  map_enable,rom_mode:boolean;
  rom_nbank:word;
  //mmm01
  mux_mmc01,mode_mmc01,mode_we:boolean;
  ramb_masked,ramb_we,romb_we,ramb_mmc01:byte;
  romb_mmc01,romb_base:word;


implementation
uses gb;

//MBC1
function gb_get_ext_ram_mbc1(direccion:word):byte;
begin
if not(ram_enable) then gb_get_ext_ram_mbc1:=$ff
else case gb_head.ram_size of
        0:gb_get_ext_ram_mbc1:=$ff;
        1:gb_get_ext_ram_mbc1:=ram_bank[0,direccion and $7ff];  //2k
        2:gb_get_ext_ram_mbc1:=ram_bank[0,direccion and $1fff];  //8k
        3:gb_get_ext_ram_mbc1:=ram_bank[ram_nbank,direccion and $1fff];  //Banks
     end;
end;

procedure gb_put_ext_ram_mbc1(direccion:word;valor:byte);
begin
if ram_enable then case gb_head.ram_size of
                     0:;
                     1:ram_bank[0,direccion and $7ff]:=valor;  //2k
                     2:ram_bank[0,direccion and $1fff]:=valor;  //8k
                     3:ram_bank[ram_nbank,direccion and $1fff]:=valor;  //Banks
                   end;
end;

procedure gb_putbyte_mbc1(direccion:word;valor:byte);
begin
case direccion of
  $0000..$1fff:ram_enable:=((valor and $f)=$a);
  $2000..$3fff:begin
                  reg1:=valor and $1f;
                  if (reg1=0) then reg1:=reg1 or 1;
               end;
  $4000..$5fff:reg2:=valor and $3;
  $6000..$7fff:rom_mode:=(valor and 1)<>0;
end;
if rom_mode then ram_nbank:=reg2
  else ram_nbank:=0;
rom_nbank:=reg1 or (reg2 shl 5);
copymemory(@memoria[$4000],@rom_bank[rom_nbank mod gb_head.rom_size,0],$4000);
if rom_mode then copymemory(@memoria[$0],@rom_bank[(reg2 shl 5) mod gb_head.rom_size,0],$4000)
  else copymemory(@memoria[$0],@rom_bank[0,0],$4000);
end;

//MMM01
function gb_get_ext_ram_mmm01(direccion:word):byte;
begin
if not(ram_enable) then gb_get_ext_ram_mmm01:=$ff
else case gb_head.ram_size of
        0:gb_get_ext_ram_mmm01:=$ff;
        1:gb_get_ext_ram_mmm01:=ram_bank[0,direccion and $7ff];  //2k
        2:gb_get_ext_ram_mmm01:=ram_bank[0,direccion and $1fff];  //8k
        3:gb_get_ext_ram_mmm01:=ram_bank[ram_nbank,direccion and $1fff];  //Banks
     end;
end;

procedure gb_put_ext_ram_mmm01(direccion:word;valor:byte);
begin
if ram_enable then case gb_head.ram_size of
                     0:;
                     1:ram_bank[0,direccion and $7ff]:=valor;  //2k
                     2:ram_bank[0,direccion and $1fff]:=valor;  //8k
                     3:ram_bank[ram_nbank,direccion and $1fff]:=valor;  //Banks
                   end;
end;

procedure gb_putbyte_mmm01(direccion:word;valor:byte);
begin
valor:=valor and $7f;
case direccion of
  $0000..$1fff:begin
                  ram_enable:=(valor and $a)<>0;
                  if not(map_enable) then begin
                    ramb_we:=(valor shr 4) and 3;
                    map_enable:=(valor and $40)=0;
                  end;
               end;
  $2000..$3fff:begin
                  if not(map_enable) then romb_mmc01:=(romb_mmc01 and not($60)) or (valor and $60);
			            romb_mmc01:=(romb_mmc01 and (not($1f) or romb_we)) or (valor and ($1f and not(romb_we)));
               end;
  $4000..$5fff:begin
                  if not(map_enable) then begin
				              mode_we:=(valor and $40)=0;
				              romb_mmc01:=(romb_mmc01 and not($180)) or ((valor and $30) shl 3);
				              ramb_mmc01:=(ramb_mmc01 and not($0c)) or (valor and $0c);
			            end;
			            ramb_mmc01:=(ramb_mmc01 and (not($03) or ramb_we)) or (valor and ($03 and not(ramb_we)));
               end;
  $6000..$7fff:begin
                  if not(map_enable) then begin
				            mux_mmc01:=(valor and $40)<>0;
				            // m_romb_nwe is aligned to RA14, hence >> 1 instead of >> 2
				            romb_we:=(valor and $3c) shr 1;
			            end;
			            if not(mode_we) then mode_mmc01:=(valor and $01)=0;
               end;
end;
rom_nbank:=romb_mmc01 and not($1e0 or romb_we);
romb_base:=romb_mmc01 and ($1e0 or romb_we);
if mode_mmc01 then ramb_masked:=ramb_mmc01
  else ramb_masked:=ramb_mmc01 and not($03);
// zero-adjust RA18..RA14
if rom_nbank=0 then rom_nbank:=1;
// if unmapped, force
if not(map_enable) then rom_nbank:=1;
// RB 0 logic
// if (!(offset & 0x4000)) romb = 0x00; !!!!!!
// combine with base
rom_nbank:=rom_nbank or romb_base;
	// multiplex with AA14..AA13
if mux_mmc01 then rom_nbank:=(rom_nbank and not($60)) or ((ramb_masked and $03) shl 5);
// if unmapped, force
if not(map_enable) then rom_nbank:=rom_nbank or $1fe;
copymemory(@memoria[$4000],@rom_bank[rom_nbank mod gb_head.rom_size,0],$4000);
end;

//MBC2
function gb_get_ext_ram_mbc2(direccion:word):byte;
begin
if not(ram_enable) then begin
  gb_get_ext_ram_mbc2:=$ff;
  exit;
end;
if direccion<$a200 then gb_get_ext_ram_mbc2:=ram_bank[0,direccion and $1ff]
  else gb_get_ext_ram_mbc2:=$ff;
end;

procedure gb_put_ext_ram_mbc2(direccion:word;valor:byte);
begin
if not(ram_enable) then exit;
if direccion<$a200 then ram_bank[0,direccion and $1ff]:=$f0 or (valor and $f);
end;

procedure gb_putbyte_mbc2(direccion:word;valor:byte);
begin
case direccion of
  $0000..$1fff:if ((direccion and $100)=0) then ram_enable:=(valor and $f)=$a;
  $2000..$3fff:if ((direccion and $100)<>0) then rom_nbank:=(valor and $1f);
end;
copymemory(@memoria[$4000],@rom_bank[rom_nbank mod gb_head.rom_size,0],$4000);
end;

//MBC5
function gb_get_ext_ram_mbc5(direccion:word):byte;
begin
if not(ram_enable) then gb_get_ext_ram_mbc5:=$ff
  else case gb_head.ram_size of
        0:gb_get_ext_ram_mbc5:=$ff;
        1:gb_get_ext_ram_mbc5:=ram_bank[0,direccion and $1fff];
        else gb_get_ext_ram_mbc5:=ram_bank[ram_nbank,direccion and $1fff];  //32k o 128Kb
       end;
end;

procedure gb_put_ext_ram_mbc5(direccion:word;valor:byte);
begin
if ram_enable then
  case gb_head.ram_size of
    0:;
    1:ram_bank[0,direccion and $1fff]:=valor;
      else ram_bank[ram_nbank,direccion and $1fff]:=valor;
  end;
end;

procedure gb_putbyte_mbc5(direccion:word;valor:byte);
begin
case direccion of
  $0000..$1fff:ram_enable:=((valor and $f)=$a);
  $2000..$2fff:rom_nbank:=(rom_nbank and $100) or valor;
  $3000..$3fff:rom_nbank:=(rom_nbank and $ff) or ((valor and 1) shl 8);
  $4000..$5fff:ram_nbank:=(valor and $f);
end;
copymemory(@memoria[$4000],@rom_bank[rom_nbank mod gb_head.rom_size,0],$4000);
end;

//Huc1
function gb_get_ext_ram_huc1(direccion:word):byte;
begin
if ram_enable then gb_get_ext_ram_huc1:=$c0 //$c0 luz off, $c1 luz on
  else case gb_head.ram_size of
          0:gb_get_ext_ram_huc1:=$ff;
          1:gb_get_ext_ram_huc1:=ram_bank[0,direccion and $7ff];  //2k
          2:gb_get_ext_ram_huc1:=ram_bank[0,direccion and $1fff];  //8k
          3:gb_get_ext_ram_huc1:=ram_bank[ram_nbank,direccion and $1fff];  //Banks
       end;
end;

procedure gb_put_ext_ram_huc1(direccion:word;valor:byte);
begin
if not(ram_enable) then case gb_head.ram_size of
                      0:;
                      1:ram_bank[0,direccion and $7ff]:=valor;  //2k
                      2:ram_bank[0,direccion and $1fff]:=valor;  //8k
                      3:ram_bank[ram_nbank,direccion and $1fff]:=valor;  //Banks
                   end;
end;

procedure gb_putbyte_huc1(direccion:word;valor:byte);
begin
case direccion of
  $0000..$1fff:ram_enable:=((valor and $f)=$e);
  $2000..$3fff:begin
                  rom_nbank:=valor and $3f;
                  if (rom_nbank=0) then rom_nbank:=rom_nbank or 1;
               end;
  $4000..$5fff:ram_nbank:=valor and $3;
end;
copymemory(@memoria[$4000],@rom_bank[rom_nbank mod gb_head.rom_size,0],$4000);
end;


end.