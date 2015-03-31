unit konami_decrypt;

interface
procedure konami1_decode(source,dest:pbyte;long:word);

implementation

procedure konami1_decode(source,dest:pbyte;long:word);
var
  xormask:byte;
  f:word;
  psource,pdest:pbyte;
begin
psource:=source;
pdest:=dest;
for f:=0 to (long-1) do begin
  xormask:=0;
	if (f and $02)<>0 then xormask:=xormask or $80
  	else xormask:=xormask or $20;
	if (f and $08)<>0 then xormask:=xormask or $08
  	else xormask:=xormask or $02;
	pdest^:=psource^ xor xormask;
  inc(psource);
  inc(pdest);
end;
end;

end.
