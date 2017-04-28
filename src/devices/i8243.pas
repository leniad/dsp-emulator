unit i8243;

interface
uses cpu_misc;

type
  i8243_chip=class
                constructor create;
                destructor free;
             public
                procedure reset;
                procedure change_calls(readhandler:tgetbyte;writehandler:tputbyte);
                function p2_r:byte;
                procedure p2_w(valor:byte);
                procedure prog_w(valor:byte);
             private
                p2:byte;
	              p2out:byte;
	              prog:byte;
                opcode:byte;
                p:array[0..3] of byte;
                read:tgetbyte;
                write:tputbyte;
  end;

const
  MCS48_EXPANDER_OP_READ=0;
	MCS48_EXPANDER_OP_WRITE=1;
	MCS48_EXPANDER_OP_OR=2;
	MCS48_EXPANDER_OP_AND=3;

implementation

constructor i8243_chip.create;
begin
end;

destructor i8243_chip.free;
begin
end;

procedure i8243_chip.reset;
begin
  self.p2:=$f;
	self.p2out:=$f;
	self.prog:=1;
end;

procedure i8243_chip.change_calls(readhandler:tgetbyte;writehandler:tputbyte);
begin
  self.read:=readhandler;
  self.write:=writehandler;
end;

function i8243_chip.p2_r:byte;
begin
  p2_r:=self.p2out;
end;

procedure i8243_chip.p2_w(valor:byte);
begin
  self.p2:=valor and $f;
end;

procedure i8243_chip.prog_w(valor:byte);
begin
	// only care about low bit
	valor:=valor and 1;
	// on high->low transition state, latch opcode/port
	if ((self.prog<>0) and (valor=0)) then begin
		self.opcode:=self.p2;
		// if this is a read opcode, copy result to p2out
		if ((self.opcode shr 2)=MCS48_EXPANDER_OP_READ) then begin
			if (addr(self.read)<>nil) then self.p[self.opcode and 3]:=self.read(self.opcode and 3);
			self.p2out:=self.p[self.opcode and 3] and $f;
		end;
	end // on low->high transition state, act on opcode
	else
  if ((self.prog=0) and (valor<>0)) then begin
		case (self.opcode shr 2) of
			MCS48_EXPANDER_OP_WRITE:begin
				self.p[self.opcode and 3]:=self.p2 and $f;
				self.write(self.opcode and 3,self.p[self.opcode and 3]);
      end;
			MCS48_EXPANDER_OP_OR:begin
				self.p[self.opcode and 3]:=self.p[self.opcode and 3] or (self.p2 and $0f);
        self.write(self.opcode and 3,self.p[self.opcode and 3]);
      end;
			MCS48_EXPANDER_OP_AND:begin
				self.p[self.opcode and 3]:=self.p[self.opcode and 3] and (self.p2 and $0f);
        self.write(self.opcode and 3,self.p[self.opcode and 3]);
      end;
    end;
	end;
	// remember the state */
	self.prog:=valor;
end;

end.
