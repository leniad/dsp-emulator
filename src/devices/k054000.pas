unit k054000;

interface

type
    k054000_chip=class
        constructor Create;
        destructor free;
    public
        dirty_tmap:array[0..4] of boolean;
        procedure reset;
        function read(direccion:byte):byte;
        procedure write(direccion,valor:byte);
    private
        regs:array[0..$1f] of byte;
    end;

var
  k054000_0:k054000_chip;

implementation

constructor k054000_chip.create;
begin
end;

destructor k054000_chip.free;
begin
end;

procedure k054000_chip.reset;
var
  f:byte;
begin
  for f:=0 to $1f do self.regs[f]:=0;
end;

function k054000_chip.read(direccion:byte):byte;
var
  Acx,Acy,Aax,Aay,Bcx,Bcy,Bax,Bay:integer;
  ret:byte;
begin
	if (direccion<>$18) then begin
		read:=0;
    exit;
  end;
	Acx:=(self.regs[$01] shl 16) or (self.regs[$02] shl 8) or self.regs[$03];
	Acy:=(self.regs[$09] shl 16) or (self.regs[$0a] shl 8) or self.regs[$0b];
	// TODO: this is a hack to make thndrx2 pass the startup check. It is certainly wrong. */
	if (self.regs[$04]=$ff) then Acx:=Acx+3;
	if (self.regs[$0c]=$ff) then Acy:=Acy+3;
	Aax:=self.regs[$06]+1;
	Aay:=self.regs[$07]+1;
	Bcx:=(self.regs[$15] shl 16) or (self.regs[$16] shl 8) or self.regs[$17];
	Bcy:=(self.regs[$11] shl 16) or (self.regs[$12] shl 8) or self.regs[$13];
	Bax:=self.regs[$0e]+1;
	Bay:=self.regs[$0f]+1;
  ret:=0;
	if ((Acx + Aax)<(Bcx-Bax)) then ret:=1;
	if ((Bcx+Bax)<(Acx-Aax)) then ret:=1;
	if ((Acy+Aay)<(Bcy-Bay)) then ret:=1;
	if ((Bcy+Bay)<(Acy-Aay)) then ret:=1;
  read:=ret;
end;

procedure k054000_chip.write(direccion,valor:byte);
begin
  self.regs[direccion]:=valor;
end;

end.
