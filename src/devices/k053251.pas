unit k053251;

interface
const
    K053251_CI0=0;
		K053251_CI1=1;
		K053251_CI2=2;
		K053251_CI3=3;
		K053251_CI4=4;

type
    k053251_chip=class
        constructor Create;
        destructor free;
    public
        dirty_tmap:array[0..4] of boolean;
        procedure reset;
        procedure lsb_w(direccion,valor:word);
        function get_priority(ci:byte):byte;
        function get_palette_index(ci:byte):byte;
        procedure write(direccion:word;valor:byte);
    private
        ram:array[0..$f] of byte;
        palette_index:array[0..4] of byte;
        procedure reset_indexes;
    end;

var
  k053251_0:k053251_chip;

procedure konami_sortlayers3(layer,pri:pbyte);

implementation

procedure konami_sortlayers3(layer,pri:pbyte);
procedure SWAP(a,b:byte);
var
  t:byte;
begin
	if (pri[a]<pri[b]) then begin
		t:=pri[a];pri[a]:=pri[b];pri[b]:=t;
		t:=layer[a];layer[a]:=layer[b];layer[b]:=t;
	end;
end;
begin
	SWAP(0,1);
	SWAP(0,2);
	SWAP(1,2);
end;

constructor k053251_chip.Create;
begin
end;

destructor k053251_chip.free;
begin
end;

procedure k053251_chip.reset_indexes;
begin
	self.palette_index[0]:=32*((self.ram[9] shr 0) and 3);
	self.palette_index[1]:=32*((self.ram[9] shr 2) and 3);
	self.palette_index[2]:=32*((self.ram[9] shr 4) and 3);
	self.palette_index[3]:=16*((self.ram[10] shr 0) and 7);
	self.palette_index[4]:=16*((self.ram[10] shr 3) and 7);
end;

procedure k053251_chip.reset;
var
  f:byte;
begin
	for f:=0 to $f do self.ram[f]:=0;
	for f:=0 to 4 do self.dirty_tmap[f]:=false;
	self.reset_indexes();
end;

procedure k053251_chip.write(direccion:word;valor:byte);
var
  i,newind:byte;
begin
	valor:=valor and $3f;
	if (self.ram[direccion]<>valor) then begin
    self.ram[direccion]:=valor;
    case direccion of
      9:begin // palette base index
          for i:=0 to 2 do begin
				    newind:=32*((valor shr (2*i)) and 3);
				    if (self.palette_index[i]<>newind) then begin
					    self.palette_index[i]:=newind;
					    self.dirty_tmap[i]:=true;
				    end;
			    end;
      end;
      10:begin // palette base index
          for i:=0 to 1 do begin
				    newind:=16*((valor shr (3*i)) and 7);
				    if (self.palette_index[3+i]<>newind) then begin
					    self.palette_index[3+i]:=newind;
					    self.dirty_tmap[3+i]:=true;
				    end;
			    end;
         end;
    end;
	end;
end;

procedure k053251_chip.lsb_w(direccion,valor:word);
begin
	self.write(direccion,valor and $ff);
end;

function k053251_chip.get_priority(ci:byte):byte;
begin
	get_priority:=self.ram[ci];
end;

function k053251_chip.get_palette_index(ci:byte):byte;
begin
	get_palette_index:=self.palette_index[ci];
end;

end.
