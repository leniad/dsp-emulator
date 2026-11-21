unit genesis_cartridges;

interface
uses main_engine,eepromser;

const
  MAX_CARTRIDGE=$800000;

var
  cart_sbb_protection:boolean;
  cart_ssf2_mapper,cart_pier_solar:boolean;
  pier_regs:array[0..7] of byte;
  pier_banks:array[0..2] of byte;
  pier_unlock_reads:byte;
  pier_spi:record
      pins,phase,bits,command,shift,status,outbit,address_bytes:byte;
      address:word;
      wrote:boolean;
  end;
  save_ram,rom:array of byte;
  cart_name:string;
  cart_banks:array[0..7] of byte;
  save_start,save_end:dword;
  save_step:integer;
  eeprom,save_enabled,save_readonly:boolean;
  x24c01_0:x24c01_chip;

  procedure pier_register_write(address:dword;value:byte);
  procedure pier_spi_reset;
  procedure reset_cartridge;
  procedure save_cartridge;
  procedure close_cartridge;
  function cart_byte(address:dword):byte;
  procedure cart_write(address:dword;value:byte);

implementation
uses sysutils,file_engine;

function cart_byte(address:dword):byte;
var
  index:dword;
begin
 if eeprom and (address>=$200000) and (address<$400000) then begin
    if(address and 1)<>0 then result:=$fe or x24c01_0.do_read
      else result:=$ff;
  exit;
 end;
 if save_enabled and (Length(save_ram)>0) and (address>=save_start) and (address<=save_end)
   and ((save_step=1) or ((address and 1)=(save_start and 1))) then begin
      index:=(address-save_start) div save_step;
      result:=save_ram[index];
 end else begin
   index:=address;
   if cart_pier_solar then begin
     if pier_unlock_reads<>0 then index:=address and $7fff
       else if (address>=$280000) and (address<$400000) then index:=(dword(pier_banks[(address-$280000) shr 19]) shl 19) or (address and $7ffff);
   end;
   if cart_ssf2_mapper and (address<$400000) then index:=(dword(cart_banks[address shr 19]) shl 19) or (address and $7ffff);
   if index<dword(Length(rom)) then result:=rom[index]
     else result:=$ff;
 end;
end;

procedure cart_write(address:dword;value:byte);
var
  index:dword;
begin
 if eeprom and (address>=$200000) and (address<$400000) then begin
    if(address and 1)<>0 then x24c01_0.lines_write(value and 1,(value shr 1) and 1);
    exit;
 end;
 if save_enabled and not save_readonly and (Length(save_ram)>0) and (address>=save_start) and (address<=save_end)
  and((save_step=1) or ((address and 1)=(save_start and 1)))then begin
      index:=(address-save_start) div save_step;
      if save_ram[index]<>value then save_ram[index]:=value;
 end;
end;

procedure close_cartridge;
begin
save_cartridge;
if cart_pier_solar then begin
  cart_pier_solar:=false;
  pier_unlock_reads:=0;
end;
if eeprom then freeandnil(x24c01_0);
eeprom:=false;
save_start:=0;
save_end:=0;
save_step:=1;
setlength(save_ram,0);
end;

procedure reset_cartridge;
var
  f:byte;
begin
  for f:=0 to 7 do cart_banks[f]:=f; // SSF2 power-on/reset mapping; first bank stays fixed.
  if eeprom then x24c01_0.reset;
  if cart_pier_solar then begin
      FillChar(pier_regs,SizeOf(pier_regs),0);
      FillChar(pier_banks,SizeOf(pier_banks),0);
      pier_regs[0]:=1;
      pier_spi_reset;
  end;
  save_readonly:=false;
end;

procedure save_cartridge;
begin
 if eeprom then
    if x24c01_0.dirty then x24c01_0.write_data(ChangeFileExt(cart_name,'.nv'));
 if Length(save_ram)<>0 then begin
   if cart_pier_solar then write_file(Directory.Arcade_nvram+ChangeFileExt(cart_name,'.nv'),@save_ram[0],Length(save_ram))
     else write_file(Directory.Arcade_nvram+ChangeFileExt(cart_name,'.nv'),@save_ram[0],Length(save_ram));
 end;
end;

procedure pier_spi_reset;
begin
 FillChar(pier_spi,SizeOf(pier_spi),0);
 pier_spi.pins:=$0c;
 pier_spi.outbit:=1;
end;

procedure pier_register_write(address:dword;value:byte);
procedure pier_spi_byte(value:byte);
var
  limit:integer;
begin
 case pier_spi.phase of
   0:begin
     pier_spi.command:=value;
     case value of
       $06:begin
              pier_spi.status:=pier_spi.status or 2;
              pier_spi.phase:=5;
           end;
       $04:begin
              pier_spi.status:=pier_spi.status and $fd;
              pier_spi.phase:=5;
           end;
       $03,$02:begin
                  pier_spi.address:=0;
                  pier_spi.phase:=1;
              end;
       $05:pier_spi.phase:=2;
       $01:pier_spi.phase:=4;
       else pier_spi.phase:=5;
     end;
   end;
   1:begin
     pier_spi.address:=(pier_spi.address shl 8) or value;
     // Two address bytes, counted separately from the serial bit counter.
     if pier_spi.address_bytes=0 then pier_spi.address_bytes:=1
       else begin
              pier_spi.address_bytes:=0;
              if pier_spi.command=$03 then pier_spi.phase:=2
                else pier_spi.phase:=3;
            end;
   end;
   3:begin
     case (pier_spi.status shr 2) and 3 of
       0:limit:=$10000;
       1:limit:=$c000;
       2:limit:=$8000;
       else limit:=0;
     end;
     if ((pier_spi.status and 2)<>0) and (pier_spi.address<limit) and (Length(save_ram)=$10000) then begin
       save_ram[pier_spi.address]:=value;
       pier_spi.wrote:=true;
     end;
     pier_spi.address:=(pier_spi.address and $ff80) or ((pier_spi.address+1) and $7f);
   end;
   4:begin
     if (pier_spi.status and 2)<>0 then begin
       pier_spi.status:=(pier_spi.status and 2) or (value and $0c);
       pier_spi.wrote:=true;
     end;
     pier_spi.phase:=5;
   end;
 end;
end;
procedure pier_spi_write(pins:byte);
var
  value:byte;
begin
 if (pins and 8)<>0 then begin
   if pier_spi.wrote then pier_spi.status:=pier_spi.status and $fd;
   pier_spi.phase:=0;
   pier_spi.bits:=0;
   pier_spi.shift:=0;
   pier_spi.outbit:=1;
   pier_spi.wrote:=false;
   pier_spi.address_bytes:=0;
 end else if ((pins and 4)<>0) and ((pins and 2)<>0) and ((pier_spi.pins and 2)=0) then begin
   if pier_spi.phase=2 then begin
     if pier_spi.command=$05 then value:=pier_spi.status
       else if Length(save_ram)=$10000 then value:=save_ram[pier_spi.address]
         else value:=$ff;
     pier_spi.outbit:=(value shr (7-pier_spi.bits)) and 1;
     inc(pier_spi.bits);
     if pier_spi.bits=8 then begin
       pier_spi.bits:=0;
       if pier_spi.command=$03 then pier_spi.address:=word(pier_spi.address+1);
     end;
   end else if pier_spi.phase<>5 then begin
     pier_spi.shift:=(pier_spi.shift shl 1) or (pins and 1);
     inc(pier_spi.bits);
     if pier_spi.bits=8 then begin
       value:=pier_spi.shift;
       pier_spi.bits:=0;pier_spi.shift:=0;
       pier_spi_byte(value);
     end;
   end;
 end;
 pier_spi.pins:=pins;
end;
var
  r:integer;
begin
 r:=(address and $0f) shr 1;
 pier_regs[r]:=value;
 case r of
   1..3:if (pier_regs[0] and 2)<>0 then pier_banks[r-1]:=value and 15;
   4:pier_spi_write(value);
 end;
end;

end.
