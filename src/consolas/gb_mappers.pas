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
function gb_get_ext_ram_mbc5(direccion:word):byte;
procedure gb_put_ext_ram_mbc5(direccion:word;valor:byte);
procedure gb_putbyte_mbc5(direccion:word;valor:byte);

var
  gb_mapper:tgb_mapper;
  rom_bank:array[0..$1ff,$0..$3fff] of byte;
  ram_bank:array[0..$f,$0..$1fff] of byte;
  ram_size,ram_nbank,rom_nbank:byte;
  rom_size:word;
  rom_mode:boolean;

implementation
uses gb;

//MBC1
function gb_get_ext_ram_mbc1(direccion:word):byte;
begin
case ram_size of
  1:gb_get_ext_ram_mbc1:=ram_bank[0,direccion and $7ff];  //2k
  2:gb_get_ext_ram_mbc1:=ram_bank[0,direccion and $1fff];  //8k
  3:gb_get_ext_ram_mbc1:=ram_bank[ram_nbank,direccion and $1fff];  //Banks
end;
end;

procedure gb_put_ext_ram_mbc1(direccion:word;valor:byte);
begin
case ram_size of
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
                  if ((valor and $1f)=0) then valor:=1;
                  rom_nbank:=(rom_nbank and $e0)+(valor and $1f);
               end;
  $4000..$5fff:begin
                  if rom_mode then begin //8Kbyte RAM, 2Mbyte ROM
                    rom_nbank:=(rom_nbank and $1f)+((valor and $3) shl 5);
                    ram_nbank:=0;
                  end else begin  //32Kbyte RAM, 512Kbyte ROM
                    rom_nbank:=rom_nbank and $1f;
                    ram_nbank:=valor and $3;
                  end;
               end;
  $6000..$7fff:rom_mode:=(valor and 1)=0;
end;
if (rom_nbank and $1f)=0 then rom_nbank:=rom_nbank or 1;
copymemory(@memoria[$4000],@rom_bank[rom_nbank mod rom_size,0],$4000);
end;

//MBC5
function gb_get_ext_ram_mbc5(direccion:word):byte;
begin
case ram_size of
  1:gb_get_ext_ram_mbc5:=ram_bank[0,direccion and $1fff];
  2,3:gb_get_ext_ram_mbc5:=ram_bank[ram_nbank,direccion and $1fff];  //32k o 128Kb
end;
end;

procedure gb_put_ext_ram_mbc5(direccion:word;valor:byte);
begin
case ram_size of
  1:ram_bank[0,direccion and $1fff]:=valor;
  2,3:ram_bank[ram_nbank,direccion and $1fff]:=valor;
end;
end;

procedure gb_putbyte_mbc5(direccion:word;valor:byte);
begin
case direccion of
  $0000..$1fff:ram_enable:=(valor and $a)=$a;
  $2000..$2fff:rom_nbank:=(rom_nbank and $100)+valor;
  $3000..$3fff:rom_nbank:=(rom_nbank and $ff)+((valor and 1) shl 8);
  $4000..$5fff:ram_nbank:=valor and $f;
end;
copymemory(@memoria[$4000],@rom_bank[rom_nbank mod rom_size,0],$4000);
end;

end.