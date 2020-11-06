unit mc8123;

interface
uses {$IFDEF WINDOWS}windows,{$else}main_engine,{$endif}
     misc_functions;

procedure mc8123_decrypt_rom(keyrgn,rom_src,rom_opc:pbyte;size:dword);

implementation

function decrypt_type0(val,param,swap:integer):integer;
begin
	if (swap=0) then val:=BITSWAP8(val,7,5,3,1,2,0,6,4);
	if (swap=1) then val:=BITSWAP8(val,5,3,7,2,1,0,4,6);
	if (swap=2) then val:=BITSWAP8(val,0,3,4,6,7,1,5,2);
	if (swap=3) then val:=BITSWAP8(val,0,7,3,2,6,4,1,5);

	if (BIT(param,3) and BIT(val,7)) then val:=val xor ((1 shl 5) or (1 shl 3) or (1 shl 0));
	if (BIT(param,2) and BIT(val,6)) then val:=val xor ((1 shl 7) or (1 shl 2) or (1 shl 1));
	if (BIT(val,6)) then val:=val xor (1 shl 7);
	if (BIT(param,1) and BIT(val,7)) then val:=val xor (1 shl 6);
	if (BIT(val,2)) then val:=val xor ((1 shl 5) or (1 shl 0));

	val:=val xor ((1 shl 4) or (1 shl 3) or (1 shl 1));

	if (BIT(param,2)) then val:=val xor ((1 shl 5) or (1 shl 2) or (1 shl 0));
	if (BIT(param,1)) then val:=val xor ((1 shl 7) or (1 shl 6));
	if (BIT(param,0)) then val:=val xor((1 shl 5) or (1 shl 0));

	if (BIT(param,0)) then val:=BITSWAP8(val,7,6,5,1,4,3,2,0);

	decrypt_type0:=val;
end;

function decrypt_type1a(val,param,swap:integer):integer;
begin
	if (swap=0) then val:=BITSWAP8(val,4,2,6,5,3,7,1,0);
	if (swap=1) then val:=BITSWAP8(val,6,0,5,4,3,2,1,7);
	if (swap=2) then val:=BITSWAP8(val,2,3,6,1,4,0,7,5);
	if (swap=3) then val:=BITSWAP8(val,6,5,1,3,2,7,0,4);

	if (BIT(param,2)) then val:=BITSWAP8(val,7,6,1,5,3,2,4,0);

	if (BIT(val,1)) then val:=val xor (1 shl 0);
	if (BIT(val,6)) then val:=val xor (1 shl 3);
	if (BIT(val,7)) then val:=val xor ((1 shl 6) or (1 shl 3));
	if (BIT(val,2)) then val:=val xor ((1 shl 6) or (1 shl 3) or (1 shl 1));
	if (BIT(val,4)) then val:=val xor ((1 shl 7) or (1 shl 6) or (1 shl 2));

	if (BIT_n(val,7) xor BIT_n(val,2))<>0 then val:=val xor (1 shl 4);

	val:=val xor ((1 shl 6) or (1 shl 3) or (1 shl 1) or (1 shl 0));

	if (BIT(param,3)) then val:=val xor ((1 shl 7) or (1 shl 2));
	if (BIT(param,1)) then val:=val xor ((1 shl 6) or (1 shl 3));

	if (BIT(param,0)) then val:=BITSWAP8(val,7,6,1,4,3,2,5,0);

	decrypt_type1a:=val;
end;

function decrypt_type1b(val,param,swap:integer):integer;
begin
	if (swap=0) then val:=BITSWAP8(val,1,0,3,2,5,6,4,7);
	if (swap=1) then val:=BITSWAP8(val,2,0,5,1,7,4,6,3);
	if (swap=2) then val:=BITSWAP8(val,6,4,7,2,0,5,1,3);
	if (swap=3) then val:=BITSWAP8(val,7,1,3,6,0,2,5,4);

	if (BIT(val,2) and BIT(val,0)) then val:=val xor ((1 shl 7) or (1 shl 4));

	if (BIT(val,7)) then val:=val xor (1 shl 2);
	if (BIT(val,5)) then val:=val xor ((1 shl 7) or (1 shl 2));
	if (BIT(val,1)) then val:=val xor (1 shl 5);
	if (BIT(val,6)) then val:=val xor (1 shl 1);
	if (BIT(val,4)) then val:=val xor ((1 shl 6) or (1 shl 5));
	if (BIT(val,0)) then val:=val xor ((1 shl 6) or (1 shl 2) or (1 shl 1));
	if (BIT(val,3)) then val:=val xor ((1 shl 7) or (1 shl 6) or (1 shl 2) or (1 shl 1) or (1 shl 0));

	val:=val xor ((1 shl 6) or (1 shl 4) or (1 shl 0));

	if (BIT(param,3)) then val:=val xor ((1 shl 4) or (1 shl 1));
	if (BIT(param,2)) then val:=val xor ((1 shl 7) or (1 shl 6) or (1 shl 3) or (1 shl 0));
	if (BIT(param,1)) then val:=val xor ((1 shl 4) or (1 shl 3));
	if (BIT(param,0)) then val:=val xor ((1 shl 6) or (1 shl 2) or (1 shl 1) or (1 shl 0));

	decrypt_type1b:=val;
end;

function decrypt_type2a(val,param,swap:integer):integer;
begin
	if (swap=0) then val:=BITSWAP8(val,0,1,4,3,5,6,2,7);
	if (swap=1) then val:=BITSWAP8(val,6,3,0,5,7,4,1,2);
	if (swap=2) then val:=BITSWAP8(val,1,6,4,5,0,3,7,2);
	if (swap=3) then val:=BITSWAP8(val,4,6,7,5,2,3,1,0);

	if (BIT(val,3) or (BIT(param,1) and BIT(val,2))) then val:=BITSWAP8(val,6,0,7,4,3,2,1,5);

	if (BIT(val,5)) then val:=val xor (1 shl 7);
	if (BIT(val,6)) then val:=val xor (1 shl 5);
	if (BIT(val,0)) then val:=val xor (1 shl 6);
	if (BIT(val,4)) then val:=val xor ((1 shl 3) or (1 shl 0));
	if (BIT(val,1)) then val:=val xor (1 shl 2);

	val:=val xor ((1 shl 7) or (1 shl 6) or (1 shl 5) or (1 shl 4) or (1 shl 1));

	if (BIT(param,2)) then val:=val xor ((1 shl 4) or (1 shl 3) or (1 shl 2) or (1 shl 1) or (1 shl 0));

	if (BIT(param,3)) then begin
		if (BIT(param,0)) then val:=BITSWAP8(val,7,6,5,3,4,1,2,0)
		  else val:=BITSWAP8(val,7,6,5,1,2,4,3,0);
	end else begin
		if (BIT(param,0)) then val:=BITSWAP8(val,7,6,5,2,1,3,4,0);
	end;

	decrypt_type2a:=val;
end;

function decrypt_type2b(val,param,swap:integer):integer;
begin
	// only 0x20 possible encryptions for this method - all others have 0x40
	// this happens because BIT(param,2) cancels the other three

	if (swap=0) then val:=BITSWAP8(val,1,3,4,6,5,7,0,2);
	if (swap=1) then val:=BITSWAP8(val,0,1,5,4,7,3,2,6);
	if (swap=2) then val:=BITSWAP8(val,3,5,4,1,6,2,0,7);
	if (swap=3) then val:=BITSWAP8(val,5,2,3,0,4,7,6,1);

	if (BIT(val,7) and BIT(val,3)) then val:=val xor ((1 shl 6) or (1 shl 4) or (1 shl 0));

	if (BIT(val,7)) then val:=val xor (1 shl 2);
	if (BIT(val,5)) then val:=val xor ((1 shl 7) or (1 shl 3));
	if (BIT(val,1)) then val:=val xor (1 shl 5);
	if (BIT(val,4)) then val:=val xor ((1 shl 7) or (1 shl 5) or (1 shl 3) or (1 shl 1));

	if (BIT(val,7) and BIT(val,5)) then val:=val xor ((1 shl 4) or (1 shl 0));

	if (BIT(val,5) and BIT(val,1)) then val:=val xor ((1 shl 4) or (1 shl 0));

	if (BIT(val,6)) then val:=val xor ((1 shl 7) or (1 shl 5));
	if (BIT(val,3)) then val:=val xor ((1 shl 7) or (1 shl 6) or (1 shl 5) or (1 shl 1));
	if (BIT(val,2)) then val:=val xor ((1 shl 3) or (1 shl 1));

	val:=val xor ((1 shl 7) or (1 shl 3) or (1 shl 2) or (1 shl 1));

	if (BIT(param,3)) then val:=val xor ((1 shl 6) or (1 shl 3) or (1 shl 1));
	if (BIT(param,2)) then val:=val xor ((1 shl 7) or (1 shl 6) or (1 shl 5) or (1 shl 3) or (1 shl 2) or (1 shl 1));	// same as the other three combined
	if (BIT(param,1)) then val:=val xor (1 shl 7);
	if (BIT(param,0)) then val:=val xor ((1 shl 5) or (1 shl 2));

	decrypt_type2b:=val;
end;

function decrypt_type3a(val,param,swap:integer):integer;
begin
	if (swap=0) then val:=BITSWAP8(val,5,3,1,7,0,2,6,4);
	if (swap=1) then val:=BITSWAP8(val,3,1,2,5,4,7,0,6);
	if (swap=2) then val:=BITSWAP8(val,5,6,1,2,7,0,4,3);
	if (swap=3) then val:=BITSWAP8(val,5,6,7,0,4,2,1,3);

	if (BIT(val,2)) then val:=val xor ((1 shl 7) or (1 shl 5) or (1 shl 4));
	if (BIT(val,3)) then val:=val xor (1 shl 0);
	if (BIT(param,0)) then val:=BITSWAP8(val,7,2,5,4,3,1,0,6);
	if (BIT(val,1)) then val:=val xor ((1 shl 6) or (1 shl 0));
	if (BIT(val,3)) then val:=val xor ((1 shl 4) or (1 shl 2) or (1 shl 1));
	if (BIT(param,3)) then val:=val xor ((1 shl 4) or (1 shl 3));

	if (BIT(val,3)) then val:=BITSWAP8(val,5,6,7,4,3,2,1,0);

	if (BIT(val,5)) then val:=val xor ((1 shl 2) or (1 shl 1));

	val:=val xor ((1 shl 6) or (1 shl 5) or (1 shl 4) or (1 shl 3));

	if (BIT(param,2)) then val:=val xor (1 shl 7);
	if (BIT(param,1)) then val:=val xor (1 shl 4);
	if (BIT(param,0)) then val:=val xor (1 shl 0);

	decrypt_type3a:=val;
end;

function decrypt_type3b(val,param,swap:integer):integer;
begin
	if (swap=0) then val:=BITSWAP8(val,3,7,5,4,0,6,2,1);
	if (swap=1) then val:=BITSWAP8(val,7,5,4,6,1,2,0,3);
	if (swap=2) then val:=BITSWAP8(val,7,4,3,0,5,1,6,2);
	if (swap=3) then val:=BITSWAP8(val,2,6,4,1,3,7,0,5);

	if (BIT(val,2)) then val:=val xor (1 shl 7);

	if (BIT(val,7)) then val:=BITSWAP8(val,7,6,3,4,5,2,1,0);

	if (BIT(param,3)) then val:=val xor (1 shl 7);

	if (BIT(val,4)) then val:=val xor (1 shl 6);
	if (BIT(val,1)) then val:=val xor ((1 shl 6) or (1 shl 4) or (1 shl 2));

	if (BIT(val,7) and BIT(val,6)) then val:=val xor (1 shl 1);

	if (BIT(val,7)) then val:=val xor (1 shl 1);

	if (BIT(param,3)) then val:=val xor (1 shl 7);
	if (BIT(param,2)) then val:=val xor (1 shl 0);

	if (BIT(param,3)) then val:=BITSWAP8(val,4,6,3,2,5,0,1,7);

	if (BIT(val,4)) then val:=val xor (1 shl 1);
	if (BIT(val,5)) then val:=val xor (1 shl 4);
	if (BIT(val,7)) then val:=val xor (1 shl 2);

	val:=val xor ((1 shl 5) or (1 shl 3) or (1 shl 2));

	if (BIT(param,1)) then val:=val xor (1 shl 7);
	if (BIT(param,0)) then val:=val xor (1 shl 3);

	decrypt_type3b:=val;
end;

function decrypt(val,key:integer;opcode:boolean):integer;
var
  type_,swap,param,ret:integer;
begin
	type_:=0;
	swap:=0;
	param:=0;

	key:=key xor $ff;

	// no encryption
	if (key=$00) then begin
    decrypt:=val;
    exit;
  end;

	type_:=type_ xor (BIT_n(key,0) shl 0);
	type_:=type_ xor (BIT_n(key,2) shl 0);
	type_:=type_ xor (BIT_n(key,0) shl 1);
	type_:=type_ xor (BIT_n(key,1) shl 1);
	type_:=type_ xor (BIT_n(key,2) shl 1);
	type_:=type_ xor (BIT_n(key,4) shl 1);
	type_:=type_ xor (BIT_n(key,4) shl 2);
	type_:=type_ xor (BIT_n(key,5) shl 2);

	swap:=swap xor (BIT_n(key,0) shl 0);
	swap:=swap xor (BIT_n(key,1) shl 0);
	swap:=swap xor (BIT_n(key,2) shl 1);
	swap:=swap xor (BIT_n(key,3) shl 1);

	param:=param xor (BIT_n(key,0) shl 0);
	param:=param xor (BIT_n(key,0) shl 1);
	param:=param xor (BIT_n(key,2) shl 1);
	param:=param xor (BIT_n(key,3) shl 1);
	param:=param xor (BIT_n(key,0) shl 2);
	param:=param xor (BIT_n(key,1) shl 2);
	param:=param xor (BIT_n(key,6) shl 2);
	param:=param xor (BIT_n(key,1) shl 3);
	param:=param xor (BIT_n(key,6) shl 3);
	param:=param xor (BIT_n(key,7) shl 3);

	if not(opcode) then begin
		param:=param xor (1 shl 0);
		type_:=type_ xor (1 shl 0);
	end;

	case type_ of
		2:ret:=decrypt_type1a(val,param,swap);
		3:ret:=decrypt_type1b(val,param,swap);
		4:ret:=decrypt_type2a(val,param,swap);
		5:ret:=decrypt_type2b(val,param,swap);
		6:ret:=decrypt_type3a(val,param,swap);
		7:ret:=decrypt_type3b(val,param,swap);
      else ret:=decrypt_type0(val,param,swap);
	end;
  decrypt:=ret;
end;

function mc8123_decrypt(addr:word;val:byte;key:pbyte;opcode:boolean):byte;
var
  tbl_num:integer;
  ptemp:pbyte;
begin
	// pick the translation table from bits fd57 of the address
	tbl_num:=(addr and 7)+((addr and $10) shr 1)+((addr and $40) shr 2)+((addr and $100) shr 3)+((addr and $c00) shr 4)+((addr and $f000) shr 4);
  ptemp:=key;
  if opcode then inc(ptemp,tbl_num)
    else inc(ptemp,tbl_num+$1000);
	mc8123_decrypt:=decrypt(val,ptemp^,opcode);
end;

procedure mc8123_decrypt_rom(keyrgn,rom_src,rom_opc:pbyte;size:dword);
var
  i,adr:dword;
  decrypted1,rom,key,ptemp:pbyte;
  src:byte;
begin
	getmem(decrypted1,size);
  ptemp:=decrypted1;
	rom:=rom_src;
	key:=keyrgn;
	for i:=0 to (size-1) do begin
    if (i>=$c000) then adr:=(i and $3fff) or $8000
      else adr:=i;
		src:=rom^;
		// decode the opcodes */
		ptemp^:=mc8123_decrypt(adr,src,key,true);
		// decode the data */
		rom^:=mc8123_decrypt(adr,src,key,false);
    inc(rom);
    inc(ptemp);
	end;
  copymemory(rom_opc,decrypted1,size);
  freemem(decrypted1);
end;

end.