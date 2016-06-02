unit k053246_k053247_k055673;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}main_engine,gfx_engine;

type
     t_k053247_cb=procedure(var code:dword;var color:word;var priority_mask:word);
     k053246_chip=class
              constructor create(pant:byte;call_back:t_k053247_cb;rom:pbyte;rom_size:dword);
              destructor free;
          public
              function is_irq_enabled:boolean;
              function read(direccion:byte):byte;
              procedure write(direccion,valor:byte);
              procedure set_objcha_line(status:byte);
          private
              kx46_regs:array[0..7] of byte;
	            kx47_regs:array[0..15] of word;
              objcha_line:byte;
              rom:pbyte;
              rom_size,rom_mask:dword;
              k053247_cb:t_k053247_cb;
              pant:byte;
     end;

var
   k053246_0:k053246_chip;

implementation

constructor k053246_chip.create(pant:byte;call_back:t_k053247_cb;rom:pbyte;rom_size:dword);
begin
  self.pant:=pant;
  self.rom:=rom;
  self.rom_size:=rom_size;
  self.rom_mask:=rom_size-1;
  self.k053247_cb:=call_back;
end;

destructor k053246_chip.free;
begin
end;

function k053246_chip.is_irq_enabled:boolean;
begin
     is_irq_enabled:=(kx46_regs[5] and $10)<>0
end;

function k053246_chip.read(direccion:byte):byte;
var
   addr:dword;
begin
  if self.objcha_line=ASSERT_LINE then begin
    addr:=(kx46_regs[6] shl 17) or (kx46_regs[7] shl 9) or (kx46_regs[4] shl 1) or ((direccion and 1) xor 1);
    read:=self.rom[addr and self.rom_mask];
  end else read:=0;
end;

procedure k053246_chip.write(direccion,valor:byte);
begin
     self.kx46_regs[direccion]:=valor;
end;

procedure k053246_chip.set_objcha_line(status:byte);
begin
  self.objcha_line:=status;
end;

end.

