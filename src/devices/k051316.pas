unit k051316;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}gfx_engine;

type
     t_k051316_cb=procedure(var code:dword;var color:word;var priority_mask:word);
     k051316_chip=class
              constructor create(pant:byte;call_back:t_k051316_cb;rom:pbyte;rom_size:dword);
              destructor free;
          public
              function read(direccion:word):byte;
              procedure write(direccion:word;valor:byte);
          private
              ram:array[0..$7ff] of byte;
              rom:pbyte;
              rom_size,rom_mask:dword;
              k051316_cb:t_k051316_cb;
              pant:byte;
     end;

var
   k051316_0:k051316_chip;

implementation

constructor k051316_chip.create(pant:byte;call_back:t_k051316_cb;rom:pbyte;rom_size:dword);
begin
  self.pant:=pant;
  self.rom:=rom;
  self.rom_size:=rom_size;
  self.rom_mask:=rom_size-1;
  self.k051316_cb:=call_back;
end;

destructor k051316_chip.free;
begin
end;

function k051316_chip.read(direccion:word):byte;
begin
  read:=self.ram[direccion];
end;

procedure k051316_chip.write(direccion:word;valor:byte);
begin
  self.ram[direccion]:=valor;
end;

end.

