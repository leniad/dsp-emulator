unit fd1089;
interface
uses {$IFDEF WINDOWS}windows,{$endif}misc_functions;

const
  fd_typeA=1;
  fd_typeB=2;

procedure fd1089_decrypt(size:dword;srcptr,opcodesptr,dataptr:pword;m_key:pbyte;fd_type:byte);

implementation
const
  s_basetable_fd1089:array[0..$ff] of byte=(
	$00,$1c,$76,$6a,$5e,$42,$24,$38,$4b,$67,$ad,$81,$e9,$c5,$03,$2f,
	$45,$69,$af,$83,$e7,$cb,$01,$2d,$02,$1e,$78,$64,$5c,$40,$2a,$36,
	$32,$2e,$44,$58,$e4,$f8,$9e,$82,$29,$05,$cf,$e3,$93,$bf,$79,$55,
	$3f,$13,$d5,$f9,$85,$a9,$63,$4f,$b8,$a4,$c2,$de,$6e,$72,$18,$04,
	$0c,$10,$7a,$66,$fc,$e0,$86,$9a,$47,$6b,$a1,$8d,$bb,$97,$51,$7d,
	$17,$3b,$fd,$d1,$eb,$c7,$0d,$21,$a0,$bc,$da,$c6,$50,$4c,$26,$3a,
	$3e,$22,$48,$54,$46,$5a,$3c,$20,$25,$09,$c3,$ef,$c1,$ed,$2b,$07,
	$6d,$41,$87,$ab,$89,$a5,$6f,$43,$1a,$06,$60,$7c,$62,$7e,$14,$08,
	$0a,$16,$70,$6c,$dc,$c0,$aa,$b6,$4d,$61,$a7,$8b,$f7,$db,$11,$3d,
	$5b,$77,$bd,$91,$e1,$cd,$0b,$27,$80,$9c,$f6,$ea,$56,$4a,$2c,$30,
	$b0,$ac,$ca,$d6,$ee,$f2,$98,$84,$37,$1b,$dd,$f1,$95,$b9,$73,$5f,
	$39,$15,$df,$f3,$9b,$b7,$71,$5d,$b2,$ae,$c4,$d8,$ec,$f0,$96,$8a,
	$a8,$b4,$d2,$ce,$d0,$cc,$a6,$ba,$1f,$33,$f5,$d9,$fb,$d7,$1d,$31,
	$57,$7b,$b1,$9d,$b3,$9f,$59,$75,$8c,$90,$fa,$e6,$f4,$e8,$8e,$92,
	$12,$0e,$68,$74,$e2,$fe,$94,$88,$65,$49,$8f,$a3,$99,$b5,$7f,$53,
	$35,$19,$d3,$ff,$c9,$e5,$23,$0f,$be,$a2,$c8,$d4,$4e,$52,$34,$28);
  s_addr_params:array[0..15,0..8] of byte=(
	( $23, 6,4,5,7,3,0,1,2 ),
	( $92, 2,5,3,6,7,1,0,4 ),
	( $b8, 6,7,4,2,0,5,1,3 ),
	( $74, 5,3,7,1,4,6,0,2 ),
	( $cf, 7,4,1,0,6,2,3,5 ),
	( $c4, 3,1,6,4,5,0,2,7 ),
	( $51, 5,7,2,4,3,1,6,0 ),
	( $14, 7,2,0,6,1,3,4,5 ),
	( $7f, 3,5,6,0,2,1,7,4 ),
	( $03, 2,3,4,0,6,7,5,1 ),
	( $96, 3,1,7,5,2,4,6,0 ),
	( $30, 7,6,2,3,0,4,5,1 ),
	( $e2, 1,0,3,7,4,5,2,6 ),
	( $72, 1,6,0,5,7,2,4,3 ),
	( $f5, 0,4,1,2,6,5,7,3 ),
	( $5b, 0,7,5,3,1,4,2,6 ));
  // data decryption parameters for the A variant
  s_data_params_a:array[0..15,0..8] of byte=(
	( $55, 6,5,1,0,7,4,2,3 ),
	( $94, 7,6,4,2,0,5,1,3 ),
	( $8d, 1,4,2,3,0,6,7,5 ),
	( $9a, 4,3,5,6,0,2,1,7 ),
	( $72, 4,3,7,0,5,6,1,2 ),
	( $ff, 1,7,2,3,6,4,5,0 ),
	( $06, 6,5,3,2,4,1,0,7 ),
	( $c5, 3,5,1,4,2,7,0,6 ),
	( $ec, 4,7,5,1,6,0,2,3 ),
	( $89, 3,5,0,6,1,2,7,4 ),
	( $5c, 1,3,0,7,5,2,4,6 ),
	( $3f, 7,3,0,2,4,6,1,5 ),
	( $57, 6,4,7,2,1,5,3,0 ),
	( $f7, 6,3,7,0,5,4,2,1 ),
	( $3a, 6,1,3,2,7,4,5,0 ),
	( $ac, 1,6,3,5,0,7,4,2 ));

function rearrange_key(table:byte;opcode:boolean):byte;
begin
	if not(opcode) then begin
		table:=table xor (1 shl 4);
		table:=table xor (1 shl 5);
		if (BIT(not(table),3)) then table:=table xor (1 shl 1);
		table:=BITSWAP8(table,1,0,6,4,3,5,2,7);
		if (BIT(table,6)) then table:=BITSWAP8(table,7,6,2,4,5,3,1,0);
	end else begin
		table:=table xor (1 shl 2);
		table:=table xor (1 shl 3);
		table:=table xor (1 shl 4);
		if (BIT(not(table),3)) then table:=table xor (1 shl 5);
		if (BIT(table,7)) then table:=table xor (1 shl 6);
		table:=BITSWAP8(table,5,7,6,4,2,3,1,0);
		if (BIT(table,6)) then table:=BITSWAP8(table,7,6,5,3,2,4,1,0);
	end;
	if (BIT(table,6)) then begin
		if (BIT(table,5)) then table:=table xor (1 shl 4);
	end else begin
		if (BIT(not(table),4)) then table:=table xor (1 shl 5);
	end;
	rearrange_key:=table;
end;

function decode_a(val,key:byte;opcode:boolean):byte;
var
  table,family:byte;
  xorval,s0,s1,s2,s3,s4,s5,s6,s7:byte;
begin
	// special case - don't decrypt
	if (key=$0) then begin
		decode_a:=val;
    exit;
  end;
	table:=rearrange_key(key, opcode);
  xorval:=s_addr_params[table shr 4,0];
  s7:=s_addr_params[table shr 4,1];
  s6:=s_addr_params[table shr 4,2];
  s5:=s_addr_params[table shr 4,3];
  s4:=s_addr_params[table shr 4,4];
  s3:=s_addr_params[table shr 4,5];
  s2:=s_addr_params[table shr 4,6];
  s1:=s_addr_params[table shr 4,7];
  s0:=s_addr_params[table shr 4,8];
	val:=BITSWAP8(val,s7,s6,s5,s4,s3,s2,s1,s0) xor xorval;
	if (BIT(table,3)) then val:=val xor $01;
	if (BIT(table,0)) then val:=val xor $b1;
	if opcode then val:=val xor $34;
	if not(opcode) then begin
		if (BIT(table,6)) then val:=val xor $01;
  end;
	val:=s_basetable_fd1089[val];
	family:=table and $07;
	if not(opcode) then begin
		if (BIT(not(table),6) and BIT(table,2)) then family:=family xor 8;
		if (BIT(table,4)) then family:=family xor 8;
	end else begin
		if (BIT(table,6) and BIT(table,2)) then family:=family xor 8;
		if (BIT(table,5)) then family:=family xor 8;
	end;
	if (BIT(table,0)) then begin
		if (BIT(val,0)) then val:=val xor $c0;
		if (BIT(not(val),6) xor BIT(val,4)) then val:=BITSWAP8(val,7,6,5,4,1,0,2,3);
	end else begin
		if (BIT(not(val),6) xor BIT(val,4)) then val:=BITSWAP8(val,7,6,5,4,0,1,3,2);
	end;
	if (BIT(not(val),6)) then val:=BITSWAP8(val,7,6,5,4,2,3,0,1);
	xorval:=s_data_params_a[family,0];
  s7:=s_data_params_a[family,1];
  s6:=s_data_params_a[family,2];
  s5:=s_data_params_a[family,3];
  s4:=s_data_params_a[family,4];
  s3:=s_data_params_a[family,5];
  s2:=s_data_params_a[family,6];
  s1:=s_data_params_a[family,7];
  s0:=s_data_params_a[family,8];
	val:=val xor xorval;
	val:=BITSWAP8(val,s7,s6,s5,s4,s3,s2,s1,s0);
	decode_a:=val;
end;

function decode_b(val,key:byte;opcode:boolean):word;
var
  table:byte;
  xorval,s7,s6,s5,s4,s3,s2,s1,s0:byte;
begin
	// special case - don't decrypt
	if (key=$0) then begin
		decode_b:=val;
    exit;
  end;
	table:=rearrange_key(key,opcode);
  xorval:=s_addr_params[table shr 4,0];
  s7:=s_addr_params[table shr 4,1];
  s6:=s_addr_params[table shr 4,2];
  s5:=s_addr_params[table shr 4,3];
  s4:=s_addr_params[table shr 4,4];
  s3:=s_addr_params[table shr 4,5];
  s2:=s_addr_params[table shr 4,6];
  s1:=s_addr_params[table shr 4,7];
  s0:=s_addr_params[table shr 4,8];
	val:=BITSWAP8(val,s7,s6,s5,s4,s3,s2,s1,s0) xor xorval;
	if BIT(table,3) then val:=val xor $01;
	if BIT(table,0) then val:=val xor $b1;
	if opcode then val:=val xor $34;
	if not(opcode) then begin
    if (BIT(table,6)) then val:=val xor $01;
  end;
	val:=s_basetable_fd1089[val];
	xorval:=0;
	if not(opcode) then begin
		if (BIT(not(table),6) and BIT(table,2)) then xorval:=xorval xor $01;
		if (BIT(table,4)) then xorval:=xorval xor $01;
	end else begin
		if (BIT(table,6) and BIT(table,2)) then xorval:=xorval xor $01;
		if (BIT(table,5)) then xorval:=xorval xor $01;
	end;
	val:=val xor xorval;
	if (BIT(table,2)) then begin
		val:=BITSWAP8(val,7,6,5,4,1,0,3,2);
		if (BIT(table,0) xor BIT(table,1)) then val:=BITSWAP8(val,7,6,5,4,0,1,3,2);
	end	else begin
		val:=BITSWAP8(val,7,6,5,4,3,2,0,1);
		if (BIT(table,0) xor BIT(table,1)) then val:=BITSWAP8(val,7,6,5,4,1,0,2,3);
	end;
	decode_b:=val;
end;

function decrypt_one(addr:dword;val:word;key:pbyte;opcode:boolean;fd_type:byte):word;
var
  tbl_num:dword;
  src:word;
  ptemp:pbyte;
begin
  ptemp:=key;
  if not(opcode) then inc(ptemp,$1000);
	// pick the translation table from bits ff022a of the address
	tbl_num:=((addr and $000002) shr 1) or ((addr and $000008) shr 2) or ((addr and $000020) shr 3) or ((addr and $000200) shr 6) or ((addr and $ff0000) shr 12);
  inc(ptemp,tbl_num);
	src:=((val and $0008) shr 3) or ((val and $0040) shr 5) or ((val and $fc00) shr 8);
	if fd_type=fd_typeA then src:=decode_a(src,ptemp^,opcode)
    else src:=decode_b(src,ptemp^,opcode);
	src:=((src and $01) shl 3) or	((src and $02) shl 5) or ((src and $fc) shl 8);
	decrypt_one:=(val and not($fc48)) or src;
end;

procedure fd1089_decrypt(size:dword;srcptr,opcodesptr,dataptr:pword;m_key:pbyte;fd_type:byte);
var
  offset,half_size:dword;
  src:word;
  ptemp,ptemp2,ptemp3:pword;
begin
  ptemp:=srcptr;
  ptemp2:=opcodesptr;
  ptemp3:=dataptr;
  half_size:=(size shr 1)-1;
	for offset:=0 to half_size do begin
		src:=ptemp^;
    inc(ptemp);
		ptemp2^:=decrypt_one(offset shl 1,src,m_key,true,fd_type);
    inc(ptemp2);
		ptemp3^:=decrypt_one(offset shl 1,src,m_key,false,fd_type);
    inc(ptemp3);
	end;
end;

end.
