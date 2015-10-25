unit seibu_sound;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     misc_functions,main_engine,nz80,generic_adpcm;

//Sonido
procedure seibu_update_irq_lines(param:byte);
procedure seibu_reset;
function seibu_get(direccion:byte):word;
procedure seibu_put(direccion,valor:byte);
//Desencriptado
procedure decript_seibu_sound(data_in,data_out_opcode,data_out_data:pbyte);
//ADPCM
procedure seibu_adpcm_init(adpcm_rom:pbyte);
procedure seibu_adpcm_close;
procedure seibu_adpcm_reset;
procedure seibu_adpcm_update;
procedure seibu_adpcm_adr_w(num:byte;offset:byte;valor:byte);
procedure seibu_adpcm_ctl_w(num,valor:byte);

var
  main2sub_pending,sub2main_pending:boolean;
  sound_latch,sub2main:array[0..1] of byte;

const
  RESET_ASSERT=0;
  RST10_ASSERT=1;
	RST10_CLEAR=2;
  RST18_ASSERT=3;
	RST18_CLEAR=4;

implementation
var
  irq1,irq2:byte;

procedure seibu_reset;
begin
 irq1:=$ff;
 irq2:=$ff;
 main2sub_pending:=false;
 sub2main_pending:=false;
 sound_latch[0]:=0;
 sound_latch[1]:=0;
end;

function seibu_get(direccion:byte):word;
var
  ret:word;
begin
case direccion of
    4:ret:=sub2main[0];
    6:ret:=sub2main[1];
    $a:if main2sub_pending then ret:=1
          else ret:=0;
    else ret:=$ffff;
end;
seibu_get:=ret;
end;

procedure seibu_put(direccion,valor:byte);
begin
case direccion of
  0:sound_latch[0]:=valor;
  2:sound_latch[1]:=valor;
  8:seibu_update_irq_lines(RST18_ASSERT);
  4,$c:begin
          sub2main_pending:=false;
          main2sub_pending:=true;
       end;
end;
end;

procedure seibu_update_irq_lines(param:byte);
begin
	case param of
		RESET_ASSERT:begin
        irq1:=$ff;
        irq2:=$ff;
      end;
		RST10_ASSERT:irq1:=$d7;
		RST10_CLEAR:irq1:=$ff;
    RST18_ASSERT:irq2:=$df;
		RST18_CLEAR:irq2:=$ff;
  end;
  snd_z80.im0:=irq1 and irq2;
	if (irq1 and irq2)=$ff then snd_z80.pedir_irq:=CLEAR_LINE
  	else snd_z80.pedir_irq:=ASSERT_LINE;
end;

procedure decript_seibu_sound(data_in,data_out_opcode,data_out_data:pbyte);
var
  f,pos:dword;
  ptemp,ptemp_data,ptemp_opcode:pbyte;

function decrypt_data(a:word;src:byte):byte;
begin
  if (BIT(a,9)  and  BIT(a,8)) then src:=src xor $80;
	if (BIT(a,11) and  BIT(a,4) and BIT(a,1)) then src:=src xor $40;
	if (BIT(a,11) and not(BIT(a,8)) and BIT(a,1)) then src:=src xor $04;
	if (BIT(a,13) and not(BIT(a,6)) and BIT(a,4)) then src:=src xor $02;
	if (not(BIT(a,11)) and  BIT(a,9) and BIT(a,2)) then src:=src xor $01;
	if (BIT(a,13) and  BIT(a,4)) then src:=BITSWAP8(src,7,6,5,4,3,2,0,1);
	if (BIT(a, 8) and  BIT(a,4)) then src:=BITSWAP8(src,7,6,5,4,2,3,1,0);
  decrypt_data:=src;
end;

function decrypt_opcode(a:word;src:byte):byte;
begin
  if (BIT(a,9) and BIT(a,8)) then src:=src xor $80;
	if (BIT(a,11) and  BIT(a,4) and  BIT(a,1)) then src:=src xor $40;
	if (not(BIT(a,13)) and BIT(a,12)) then src:=src xor $20;
	if (not(BIT(a,6)) and BIT(a,1)) then src:=src xor $10;
	if (not(BIT(a,12)) and BIT(a,2)) then src:=src xor $08;
	if (BIT(a,11) and not(BIT(a,8)) and BIT(a,1)) then src:=src xor $04;
	if (BIT(a,13) and not(BIT(a,6)) and BIT(a,4)) then src:=src xor $02;
	if (not(BIT(a,11)) and BIT(a,9) and BIT(a,2)) then src:=src xor $01;
	if (BIT(a,13) and BIT(a,4)) then src:=BITSWAP8(src,7,6,5,4,3,2,0,1);
	if (BIT(a, 8) and BIT(a,4)) then src:=BITSWAP8(src,7,6,5,4,2,3,1,0);
	if (BIT(a,12) and  BIT(a,9)) then src:=BITSWAP8(src,7,6,4,5,3,2,1,0);
	if (BIT(a,11) and not(BIT(a,6))) then src:=BITSWAP8(src,6,7,5,4,3,2,1,0);
  decrypt_opcode:=src;
end;

begin
  ptemp_data:=data_out_data;
  ptemp_opcode:=data_out_opcode;
  for f:=0 to $1fff do begin
    pos:=BITSWAP24(f,23,22,21,20,19,18,17,16,13,14,15,12,11,10,9,8,7,6,5,4,3,2,1,0);
    ptemp:=data_in;
    inc(ptemp,pos);
    ptemp_data^:=decrypt_data(f,ptemp^);
		ptemp_opcode^:=decrypt_opcode(f,ptemp^);
    inc(ptemp_data);
    inc(ptemp_opcode);
  end;
end;

//ADPCM
procedure seibu_adpcm_init(adpcm_rom:pbyte);
var
  f:word;
begin
gen_adpcm_init(0,8000,$10000);
gen_adpcm_init(1,8000,$10000);
for f:=0 to $ffff do begin
  gen_adpcm[0].mem[f]:=BITSWAP8(adpcm_rom[f],7,5,3,1,6,4,2,0);
  gen_adpcm[1].mem[f]:=BITSWAP8(adpcm_rom[$10000+f],7,5,3,1,6,4,2,0);
end;
end;

procedure seibu_adpcm_close;
begin
 gen_adpcm_close(0);
 gen_adpcm_close(1);
end;

procedure seibu_adpcm_reset;
begin
 gen_adpcm_reset(0);
 gen_adpcm_reset(1);
end;

procedure seibu_adpcm_update;
begin
  gen_adpcm_update(0);
  gen_adpcm_update(1);
end;

procedure seibu_adpcm_adr_w(num:byte;offset:byte;valor:byte);
begin
	if (offset<>0) then gen_adpcm[num].end_:=valor shl 8
	else begin
		gen_adpcm[num].current:=valor shl 8;
		gen_adpcm[num].nibble:=4;
  end;
end;

procedure seibu_adpcm_ctl_w(num,valor:byte);
begin
	// sequence is 00 02 01 each time.
	case valor of
		0:gen_adpcm[num].signal:=0;
		1:gen_adpcm_timer(num,true);
    2:;
  end;
end;

end.
