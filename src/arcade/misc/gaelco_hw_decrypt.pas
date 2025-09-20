unit gaelco_hw_decrypt;

{Gaelco video RAM encryption
Thanks to GAELCO SA for information on the algorithm.}

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     misc_functions;

function gaelco_dec(offset,data:word;param1:byte;param2:word;thispc:dword):word;

var
  lastpc:dword;
  lastoffset,lastencword,lastdecword:word;

implementation

function decrypt(param1:byte;param2:word;enc_prev_word,dec_prev_word,enc_word:word):word;inline;
var
  swap,type_:byte;
  res,k:word;
begin
	swap:=(BIT_n(dec_prev_word, 8) shl 1) or BIT_n(dec_prev_word, 7);
	type_:=(BIT_n(dec_prev_word,12) shl 1) or BIT_n(dec_prev_word, 2);
 	res:=0;
	k:=0;
	case swap of
		0:res:=BITSWAP16(enc_word,  1, 2, 0,14,12,15, 4, 8,13, 7, 3, 6,11, 5,10, 9);
		1:res:=BITSWAP16(enc_word, 14,10, 4,15, 1, 6,12,11, 8, 0, 9,13, 7, 3, 5, 2);
		2:res:=BITSWAP16(enc_word,  2,13,15, 1,12, 8,14, 4, 6, 0, 9, 5,10, 7, 3,11);
		3:res:=BITSWAP16(enc_word,  3, 8, 1,13,14, 4,15, 0,10, 2, 7,12, 6,11, 9, 5);
	end;
	res:=res xor param2;
	case type_ of
		0:k:=	(0 shl 0)+(1 shl 1)+(0 shl 2)+(1 shl 3)+(1 shl 4)+(1 shl 5);
		1:k:=(BIT_n(dec_prev_word, 0) shl 0)+
				  (BIT_n(dec_prev_word, 1) shl 1)+
  				(BIT_n(dec_prev_word, 1) shl 2)+
  				(BIT_n(enc_prev_word, 3) shl 3)+
  				(BIT_n(enc_prev_word, 8) shl 4)+
  				(BIT_n(enc_prev_word,15) shl 5);
		2:k:=	(BIT_n(enc_prev_word, 5) shl 0) +
				(BIT_n(dec_prev_word, 5) shl 1) +
				(BIT_n(enc_prev_word, 7) shl 2) +
				(BIT_n(enc_prev_word, 3) shl 3) +
				(BIT_n(enc_prev_word,13) shl 4) +
				(BIT_n(enc_prev_word,14) shl 5);
		3:k:=(BIT_n(enc_prev_word, 0) shl 0) +
				(BIT_n(enc_prev_word, 9) shl 1) +
				(BIT_n(enc_prev_word, 6) shl 2) +
				(BIT_n(dec_prev_word, 4) shl 3) +
				(BIT_n(enc_prev_word, 2) shl 4) +
				(BIT_n(dec_prev_word,11) shl 5);
	end;
	k:=k xor param1;
	res:=(res and $ffc0) or ((res+k) and $003f);
	res:=res xor param1;
	case type_ of
		0:k:=(BIT_n(enc_word, 9) shl 0) +
				(BIT_n(res,2)       shl 1) +
				(BIT_n(enc_word, 5) shl 2) +
				(BIT_n(res,5)       shl 3) +
				(BIT_n(res,4)       shl 4);
    1:k:=(BIT_n(dec_prev_word, 2) shl 0) +	// always 1
				(BIT_n(enc_prev_word, 4) shl 1) +
				(BIT_n(dec_prev_word,14) shl 2) +
				(BIT_n(res, 1)           shl 3) +
				(BIT_n(dec_prev_word,12) shl 4);	// always 0
    2:k:=(BIT_n(enc_prev_word, 6) shl 0) +
				(BIT_n(dec_prev_word, 6) shl 1) +
				(BIT_n(dec_prev_word,15) shl 2) +
				(BIT_n(res,0)            shl 3) +
				(BIT_n(dec_prev_word, 7) shl 4);
    3:k:=(BIT_n(dec_prev_word, 2) shl 0) +	// always 1
				(BIT_n(dec_prev_word, 9) shl 1) +
				(BIT_n(enc_prev_word, 5) shl 2) +
				(BIT_n(dec_prev_word, 1) shl 3) +
				(BIT_n(enc_prev_word,10) shl 4);
  end;
	k:=k xor param1;
	res:=(res and $003f) or ((res + (k shl 6)) and $07c0) or ((res+(k shl 11)) and $f800);
	res:=res xor ((param1 shl 6) or (param1 shl 11));
	decrypt:=BITSWAP16(res,2,6,0,11,14,12,7,10,5,4,8,3,9,1,13,15);
end;

function gaelco_dec(offset,data:word;param1:byte;param2:word;thispc:dword):word;
var
  decode:word;
begin
	// check if 2nd half of 32 bit
	if ((lastpc=thispc) and (offset=lastoffset+1)) then begin
		lastpc:=0;
		decode:=decrypt(param1,param2,lastencword,lastdecword,data);
	end else begin
		// code as 1st word
		lastpc:=thispc;
		lastoffset:=offset;
		lastencword:=data;
		// high word returned
		decode:=decrypt(param1,param2,0,0,data);
		lastdecword:=decode;
	end;
	gaelco_dec:=decode;
end;

end.
