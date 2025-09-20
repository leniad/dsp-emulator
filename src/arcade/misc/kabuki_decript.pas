unit kabuki_decript;

interface
{$IFDEF WINDOWS}uses windows;{$ENDIF}

procedure kabuki_cps1_decode(rom,dest_op,dest_data:pbyte;swap_key1,swap_key2:dword;addr_key:word;xor_key:byte);
procedure kabuki_mitchell_decode(rom,dest_op,dest_data:pbyte;banks:byte;swap_key1,swap_key2:dword;addr_key:word;xor_key:byte);

implementation

function bitswap1(src,key,select:integer):integer;inline;
begin
	if (select and (1 shl ((key shr 0) and 7)))<>0 then
		src:=(src and $fc) or ((src and $01) shl 1) or ((src and $02) shr 1);
	if (select and (1 shl ((key shr 4) and 7)))<>0 then
		src:=(src and $f3) or ((src and $04) shl 1) or ((src and $08) shr 1);
	if (select and (1 shl ((key shr 8) and 7)))<>0 then
		src:=(src and $cf) or ((src and $10) shl 1) or ((src and $20) shr 1);
	if (select and (1 shl ((key shr 12) and 7)))<>0 then
		src:=(src and $3f) or ((src and $40) shl 1) or ((src and $80) shr 1);
  bitswap1:=src;
end;

function bitswap2(src,key,select:integer):integer;inline;
begin
	if (select and (1 shl ((key shr 12) and 7)))<>0 then
		src:=(src and $fc) or ((src and $01) shl 1) or ((src and $02) shr 1);
	if (select and (1 shl ((key shr 8) and 7)))<>0 then
		src:=(src and $f3) or ((src and $04) shl 1) or ((src and $08) shr 1);
	if (select and (1 shl ((key shr 4) and 7)))<>0 then
		src:=(src and $cf) or ((src and $10) shl 1) or ((src and $20) shr 1);
	if (select and (1 shl ((key shr 0) and 7)))<>0 then
		src:=(src and $3f) or ((src and $40) shl 1) or ((src and $80) shr 1);
  bitswap2:=src;
end;


function bytedecode(src,swap_key1,swap_key2,xor_key,select:integer):byte;inline;
begin
	src:= bitswap1(src,swap_key1 and $ffff,select and $ff);
	src:=((src and $7f) shl 1) or ((src and $80) shr 7);
	src:= bitswap2(src,swap_key1 shr 16,select and $ff);
	src:=src xor xor_key;
	src:= ((src and $7f) shl 1) or ((src and $80) shr 7);
	src:= bitswap2(src,swap_key2 and $ffff,select shr 8);
	src:= ((src and $7f) shl 1) or ((src and $80) shr 7);
	src:= bitswap1(src,swap_key2 shr 16,select shr 8);
	bytedecode:=src;
end;

procedure kabuki_decode(rom,dest_op,dest_data:pbyte;base_addr,long:integer;swap_key1,swap_key2:dword;addr_key:word;xor_key:byte);inline;
var
  ptemp1,ptemp2,ptemp3:pbyte;
  f,pos:integer;
begin
  ptemp1:=rom;
  ptemp2:=dest_op;
  ptemp3:=dest_data;
	for f:=0 to (long-1) do begin
		// decode opcodes */
		pos:=(f+base_addr)+addr_key;
		ptemp2^:=bytedecode(ptemp1^,swap_key1,swap_key2,xor_key,pos);
    inc(ptemp2);
		// decode data */
		pos:=((f+base_addr) xor $1fc0)+addr_key+1;
		ptemp3^:=bytedecode(ptemp1^,swap_key1,swap_key2,xor_key,pos);
    inc(ptemp3);
    inc(ptemp1);
	end;
end;


procedure kabuki_cps1_decode(rom,dest_op,dest_data:pbyte;swap_key1,swap_key2:dword;addr_key:word;xor_key:byte);
begin
  kabuki_decode(rom,dest_op,dest_data,$0000,$8000,swap_key1,swap_key2,addr_key,xor_key);
end;

procedure kabuki_mitchell_decode(rom,dest_op,dest_data:pbyte;banks:byte;swap_key1,swap_key2:dword;addr_key:word;xor_key:byte);
var
  ptemp1,ptemp2,ptemp3:pbyte;
  f:byte;
begin
  ptemp1:=rom;
  inc(ptemp1,$10000);
  ptemp2:=dest_op;
  inc(ptemp2,$10000);
  ptemp3:=dest_data;
  inc(ptemp3,$10000);
  kabuki_decode(rom,dest_op,dest_data,$0000,$8000,swap_key1,swap_key2,addr_key,xor_key);
  for f:=0 to (banks-1) do begin
    kabuki_decode(ptemp1,ptemp2,ptemp3,$8000,$4000,swap_key1,swap_key2,addr_key,xor_key);
    inc(ptemp1,$4000);
    inc(ptemp2,$4000);
    inc(ptemp3,$4000);
  end;
end;

end.