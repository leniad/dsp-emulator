unit volfied_cchip;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     controls_engine,timer_engine;

const
  palette_data:array[1..$11,0..$4f] of word=((
	$0000, $de7b, $de03, $5e01, $5e02, $c07b, $0000, $de7b,
	$0058, $4079, $407a, $407b, $d47b, $0000, $0000, $0000,
	$0000, $104a, $ce41, $8c39, $5252, $d662, $4a31, $0000,
	$1e00, $1000, $9e01, $1e02, $de02, $0000, $0000, $0000,
	$0000, $de7b, $de03, $5e01, $5e02, $c07b, $0000, $de7b,
	$0058, $4079, $407a, $407b, $d47b, $0000, $0000, $0000,
	$0000, $104a, $ce41, $8c39, $5252, $d662, $4a31, $0000,
	$1e00, $1000, $9e01, $1e02, $de02, $0000, $0000, $0000,
	$0000, $d62a, $1002, $ce01, $5a3b, $de7b, $4a31, $0000,
	$1e00, $1000, $9e01, $1e02, $de02, $0038, $0e38, $0000),

 ($0000, $de7b, $de03, $5e01, $5e02, $c07b, $0000, $de7b,
	$0058, $4079, $407a, $407b, $d47b, $0000, $0000, $0000,
	$0000, $4008, $0029, $c641, $4c52, $5473, $de7b, $1863,
	$524a, $ce39, $0821, $9c01, $1200, $8001, $c002, $ce39,
	$0000, $de7b, $de03, $5e01, $5e02, $c07b, $0000, $de7b,
	$0058, $4079, $407a, $407b, $d47b, $0000, $0000, $0000,
	$0000, $0000, $4a29, $ce39, $de7b, $4001, $4002, $c003,
	$9e01, $1e00, $0078, $0e00, $5401, $0040, $de03, $1600,
	$0000, $4208, $0c39, $d061, $547a, $1472, $de7b, $de7b,
	$187b, $947a, $0821, $9e79, $1040, $8079, $c07a, $0000),

 ($0000, $de7b, $de03, $5e01, $5e02, $c07b, $0000, $de7b,
	$0058, $4079, $407a, $407b, $d47b, $0000, $0000, $0000,
	$0000, $c038, $4049, $c059, $406a, $c07a, $4208, $0821,
	$8c31, $1042, $9c73, $1e03, $1a02, $0c00, $1860, $1e78,
	$0000, $de7b, $de03, $5e01, $5e02, $c07b, $0000, $de7b,
	$0058, $4079, $407a, $407b, $d47b, $0000, $0000, $0000,
	$0000, $0000, $4a29, $ce39, $de7b, $4001, $4002, $c003,
	$9e01, $1e00, $0078, $0e00, $5401, $0040, $de03, $1600,
	$0000, $c001, $4002, $8002, $c002, $c002, $0001, $c001,
	$9201, $c002, $c003, $0003, $8002, $4001, $c002, $4003),

 ($0000, $de7b, $de03, $5e01, $5e02, $c07b, $0000, $de7b,
	$0058, $4079, $407a, $407b, $d47b, $0000, $0000, $0000,
	$0000, $1042, $ce39, $8c31, $524a, $d65a, $4a29, $0000,
	$1e00, $1000, $8c21, $ce29, $0039, $0038, $0e38, $0038,
	$0000, $de7b, $de03, $5e01, $5e02, $c07b, $0000, $de7b,
	$0058, $4079, $407a, $407b, $d47b, $0000, $0000, $0000,
	$0000, $de7b, $1e00, $c003, $1042, $de03, $0000, $d65a,
	$ce39, $8c31, $4a29, $0078, $c07b, $1e02, $1e78, $c003,
	$0000, $1002, $ce01, $8c01, $5202, $d602, $4a01, $0000,
	$1e00, $1000, $0000, $0000, $0000, $0000, $0000, $0000),

 ($0000, $de7b, $de03, $5e01, $5e02, $c07b, $0000, $de7b,
	$0058, $4079, $407a, $407b, $d47b, $0000, $0000, $0000,
	$0000, $1200, $1600, $1a00, $9e01, $8021, $c029, $0032,
	$803a, $4208, $0821, $1042, $d65a, $9c73, $de03, $5c02,
	$0000, $de7b, $de03, $5e01, $5e02, $c07b, $0000, $de7b,
	$0058, $4079, $407a, $407b, $d47b, $0000, $0000, $0000,
	$0000, $de7b, $1e00, $c003, $1042, $de03, $0000, $d65a,
	$ce39, $8c31, $4a29, $0078, $c07b, $1e02, $1e78, $c003,
	$0000, $5202, $d602, $5a03, $de03, $8021, $c029, $0032,
	$803a, $4208, $0821, $1042, $d65a, $9c73, $de03, $5c02),

 ($0000, $de7b, $de03, $5e01, $5e02, $c07b, $0000, $de7b,
	$0058, $4079, $407a, $407b, $d47b, $0000, $0000, $0000,
	$0000, $9e52, $9028, $9428, $9828, $9e28, $4208, $de7b,
	$de03, $9c02, $c03a, $0063, $586b, $9252, $8a31, $5e31,
	$0000, $de7b, $de03, $5e01, $5e02, $c07b, $0000, $de7b,
	$0058, $4079, $407a, $407b, $d47b, $0000, $0000, $0000,
	$0000, $de7b, $1e00, $c003, $1042, $de03, $0000, $d65a,
	$ce39, $8c31, $4a29, $0078, $c07b, $1e02, $1e78, $c003,
	$0263, $9e52, $8058, $0879, $8c79, $107a, $4208, $de7b,
	$de01, $1e01, $c03a, $0063, $586b, $9252, $8a31, $527a),

 ($0000, $de7b, $de03, $5e01, $5e02, $c07b, $0000, $de7b,
	$0058, $4079, $407a, $407b, $d47b, $0000, $0000, $0000,
	$0000, $c038, $4049, $c059, $406a, $c07a, $4208, $0821,
	$8c31, $1042, $9c73, $1e03, $1a02, $0c00, $1860, $1e78,
	$0000, $de7b, $de03, $5e01, $5e02, $c07b, $0000, $de7b,
	$0058, $4079, $407a, $407b, $d47b, $0000, $0000, $0000,
	$0000, $0000, $4a29, $ce39, $de7b, $4001, $4002, $c003,
	$9e01, $1e00, $0078, $0e00, $5401, $0040, $de03, $1600,
	$0000, $8001, $0002, $8002, $0003, $8003, $4208, $0821,
	$8c31, $1042, $9c73, $1e00, $5c02, $0c00, $1860, $1e78),

 ($0000, $de7b, $de03, $5e01, $5e02, $c07b, $0000, $de7b,
	$0058, $4079, $407a, $407b, $d47b, $0000, $0000, $0000,
	$0000, $1042, $ce39, $8c31, $524a, $d65a, $4a29, $0000,
	$1e00, $1000, $9e01, $5e02, $5e03, $0038, $0e38, $0000,
	$0000, $de7b, $de03, $5e01, $5e02, $c07b, $0000, $de7b,
	$0058, $4079, $407a, $407b, $d47b, $0000, $0000, $0000,
	$0000, $de7b, $1e00, $c003, $1042, $de03, $0000, $d65a,
	$ce39, $8c31, $4a29, $0078, $c07b, $1e02, $1e78, $c003,
	$0000, $5202, $1002, $ce19, $9432, $1843, $8c11, $0000,
	$1e00, $1000, $9e01, $5e02, $5e03, $0038, $0e38, $0000),

 ($0000, $de7b, $de03, $5e01, $5e02, $c07b, $0000, $de7b,
	$0058, $4079, $407a, $407b, $d47b, $0000, $0000, $0000,
	$0000, $1048, $1250, $1458, $1660, $d418, $9e02, $c203,
	$4208, $4a29, $8c31, $1042, $1e78, $166b, $0c38, $1868,
	$0000, $de7b, $de03, $5e01, $5e02, $c07b, $0000, $de7b,
	$0058, $4079, $407a, $407b, $d47b, $0000, $0000, $0000,
	$0000, $de7b, $1e00, $c003, $1042, $de03, $0000, $d65a,
	$ce39, $8c31, $4a29, $0078, $c07b, $1e02, $1e78, $c003,
	$0000, $1600, $1a21, $5c29, $de39, $d418, $9e02, $c203,
	$4208, $4a29, $8c31, $1042, $1e42, $186b, $9210, $9e31),

 ($0000, $de7b, $de03, $5e01, $5e02, $c07b, $0000, $de7b,
	$0058, $4079, $407a, $407b, $d47b, $0000, $0000, $0000,
	$0000, $0000, $0038, $4a29, $ce39, $9452, $9218, $de7b,
	$c001, $c003, $de03, $1403, $cc01, $4a01, $0668, $4672,
	$0000, $de7b, $de03, $5e01, $5e02, $c07b, $0000, $de7b,
	$0058, $4079, $407a, $407b, $d47b, $0000, $0000, $0000,
	$0000, $de7b, $1e00, $c003, $1042, $de03, $0000, $d65a,
	$ce39, $8c31, $4a29, $0078, $c07b, $1e02, $1e78, $c003,
	$0000, $0000, $0038, $4a29, $5401, $9c02, $9218, $de7b,
	$0003, $c003, $5e02, $de01, $5201, $d200, $0668, $4672),

 ($0000, $de7b, $de03, $5e01, $5e02, $c07b, $0000, $de7b,
	$0058, $4079, $407a, $407b, $d47b, $0000, $0000, $0000,
	$0050, $8001, $c001, $0002, $c002, $d043, $9c73, $524a,
	$ce39, $8c31, $4208, $de03, $9c02, $1e60, $1a00, $1000,
	$0000, $de7b, $de03, $5e01, $5e02, $c07b, $0000, $de7b,
	$0058, $4079, $407a, $407b, $d47b, $0000, $0000, $0000,
	$0000, $de7b, $1e00, $c003, $1042, $de03, $0000, $d65a,
	$ce39, $8c31, $4a29, $0078, $c07b, $1e02, $1e78, $c003,
	$0000, $8c01, $ce01, $1002, $d62a, $de4b, $9c73, $5202,
	$ce01, $8c01, $4208, $de03, $9c02, $1e60, $1a00, $1000),

 ($0000, $de7b, $de03, $5e01, $5e02, $c07b, $0000, $de7b,
	$0058, $4079, $407a, $407b, $d47b, $0000, $0000, $0000,
	$0000, $0000, $0038, $4a29, $ce39, $9452, $9218, $9e52,
	$c001, $c003, $1e00, $1400, $0c00, $4a01, $0668, $4672,
	$0000, $de7b, $de03, $5e01, $5e02, $c07b, $0000, $de7b,
	$0058, $4079, $407a, $407b, $d47b, $0000, $0000, $0000,
	$0000, $de7b, $1e00, $c003, $1042, $de03, $0000, $d65a,
	$ce39, $8c31, $4a29, $0078, $c07b, $1e02, $1e78, $c003,
	$0000, $0000, $0038, $4a29, $ce39, $9452, $9218, $de7b,
	$c001, $c003, $de03, $1403, $cc01, $4a01, $0668, $4672),

 ($0000, $de7b, $de03, $5e01, $5e02, $c07b, $0000, $de7b,
	$0058, $4079, $407a, $407b, $d47b, $0000, $0000, $0000,
	$0078, $4208, $1052, $9462, $1873, $5a73, $de7b, $1863,
	$524a, $ce39, $0821, $1600, $1000, $d201, $de03, $0a42,
	$0000, $de7b, $de03, $5e01, $5e02, $c07b, $0000, $de7b,
	$0058, $4079, $407a, $407b, $d47b, $0000, $0000, $0000,
	$0078, $4208, $1052, $9462, $1873, $5a73, $de7b, $1863,
	$524a, $ce39, $0821, $1600, $1000, $d201, $de03, $0a42,
	$0000, $4208, $5029, $9431, $d839, $5a4a, $9e52, $5862,
	$de4b, $8e39, $0821, $1600, $1000, $d201, $1e00, $0a42),

 ($0000, $de7b, $de03, $5e01, $5e02, $c07b, $0000, $de7b,
	$0058, $4079, $407a, $407b, $d47b, $0000, $0000, $0000,
	$0000, $0e01, $5001, $9201, $d401, $1602, $1200, $1600,
	$4208, $0821, $8c31, $1042, $5a6b, $8001, $0002, $9a02,
	$0000, $de7b, $de03, $5e01, $5e02, $c07b, $0000, $de7b,
	$0058, $4079, $407a, $407b, $d47b, $0000, $0000, $0000,
	$0000, $0000, $4a29, $ce39, $de7b, $4001, $4002, $c003,
	$9e01, $1e00, $0078, $0e00, $5401, $0040, $de03, $1600,
	$0000, $8a21, $0a32, $4c3a, $8e4a, $504b, $d203, $c003,
	$4208, $0821, $8c31, $1042, $5a6b, $8001, $0002, $545b),

 ($0000, $de7b, $de03, $5e01, $5e02, $c07b, $0000, $de7b,
	$0058, $4079, $407a, $407b, $d47b, $0000, $0000, $0000,
	$0000, $c038, $4049, $c059, $406a, $c07a, $0000, $0821,
	$9c31, $1042, $9c73, $1e02, $1a02, $0c00, $4002, $c001,
	$0000, $de7b, $de03, $5e01, $5e02, $c07b, $0000, $de7b,
	$0058, $4079, $407a, $407b, $d47b, $0000, $0000, $0000,
	$0000, $de7b, $1e00, $c003, $1042, $de03, $0000, $d65a,
	$ce39, $8c31, $4a29, $0078, $c07b, $1e02, $1e78, $c003,
	$0000, $ce00, $5201, $d601, $5a02, $de02, $0000, $0821,
	$8c31, $1042, $9c73, $1e03, $1a02, $0c00, $9e01, $0e00),

 ($0000, $de7b, $de03, $5e01, $5e02, $c07b, $0000, $de7b,
	$0058, $4079, $407a, $407b, $d47b, $0000, $0000, $0000,
	$0000, $0601, $8a09, $0e1a, $922a, $163b, $de7b, $d65a,
	$ce39, $0821, $0000, $0c00, $5208, $1a02, $9e03, $ce39,
	$0000, $de7b, $de03, $5e01, $5e02, $c07b, $0000, $de7b,
	$0058, $4079, $407a, $407b, $d47b, $0000, $0000, $0000,
	$0000, $1400, $8002, $0068, $0000, $5e01, $5e02, $1e03,
	$de03, $ce39, $ce39, $ce39, $ce39, $ce39, $ce39, $ce39,
	$0078, $4208, $1052, $9462, $1873, $5a73, $de7b, $1863,
	$524a, $ce39, $0821, $1600, $1000, $d201, $de03, $0a42),

 ($0000, $4a29, $8c31, $ce39, $1042, $524a, $9452, $d65a,
	$1863, $0000, $de39, $de7b, $c001, $8002, $1800, $1e00,
	$0000, $de7b, $1e00, $0000, $0000, $0000, $0000, $0000,
	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000,
	$1e00, $1e00, $1e00, $1e00, $1e00, $1e00, $1e00, $1e00,
	$1e00, $1e00, $1e00, $1e00, $1e00, $1e00, $1e00, $1e00,
	$de03, $de03, $de03, $de03, $de03, $de03, $de03, $de03,
	$de03, $de03, $de03, $de03, $de03, $de03, $de03, $de03,
	$de03, $0e00, $9e4a, $0000, $1042, $de7b, $9452, $4a29,
	$ce39, $1c02, $0000, $0000, $0000, $0000, $0000, $0000));

var
  cchip_ram:array[0..($400*8)-1] of byte;
  current_cmd,current_flag,current_bank,cc_port,cc_timer:byte;

procedure volfied_init_cchip(num:byte);
procedure volfied_cchip_reset;
function volfied_cchip_ram_r(direccion:word):word;
procedure volfied_cchip_ram_w(direccion,valor:word);
function volfied_cchip_ctrl_r:word;
procedure volfied_cchip_ctrl_w(valor:word);
procedure volfied_cchip_bank_w(valor:word);
procedure volfied_timer;

implementation
procedure volfied_init_cchip(num:byte);
begin
  cc_timer:=init_timer(num,1,volfied_timer,false);
end;

function volfied_cchip_ram_r(direccion:word):word;
begin
  direccion:=direccion shr 1;
  // Check for input ports */
	if (current_bank=0) then begin
		case direccion of
  		$03:volfied_cchip_ram_r:=marcade.in0; //ioport("F00007")->read();    /* STARTn + SERVICE1 */
		  $04:volfied_cchip_ram_r:=marcade.in1; //return ioport("F00009")->read();    /* COINn */
		  $05:volfied_cchip_ram_r:=marcade.in2; // return ioport("F0000B")->read();    /* Player controls + TILT */
		  $06:volfied_cchip_ram_r:=$ff; // return ioport("F0000D")->read();    /* Player controls (cocktail) */
		  $08:volfied_cchip_ram_r:=cc_port;
      $3fe:volfied_cchip_ram_r:=current_cmd; // Current command status
      $3ff:volfied_cchip_ram_r:=2*current_flag;    // fixes freeze after shield runs out
        else volfied_cchip_ram_r:=cchip_ram[(current_bank*$400)+direccion];
		end;
    exit;
	end;
	// Unknown
	if ((current_bank=2) and (direccion=$005)) then begin
		{ Not fully understood - Game writes:
            0001a0c2:  volfied c write 0005 00aa
            0001a0ca:  volfied c write 0006 0055
            0001a0d2:  volfied c write 0004 0065
            Then expects $7c to replace the $aa some time later.}
		volfied_cchip_ram_r:=$7c; // makes worm in round 1 appear
    exit;
	end;
	// Unknown - some kind of timer
	volfied_cchip_ram_r:=cchip_ram[(current_bank*$400)+direccion];
end;

procedure volfied_cchip_ram_w(direccion,valor:word);
begin
  direccion:=direccion shr 1;
	cchip_ram[(current_bank*$400)+direccion]:=valor;
	if (current_bank=0) then begin
		if (direccion=$008) then cc_port:=valor;
		if (direccion=$3fe) then begin
      {*******************
      (This table stored in ROM at $146a8)
      (Level number stored at $100198.b, from $100118.b, from $100098.b)
      (Level number at $b34 stored to $100098.b)
      round 01 => data $0A
      round 02 => data $01
      round 03 => data $03
      round 04 => data $08
      round 05 => data $05
      round 06 => data $04
      round 07 => data $0B
      round 08 => data $09
      round 09 => data $07
      round 10 => data $06
      round 11 => data $0E
      round 12 => data $0D
      round 13 => data $02
      round 14 => data $0C
      round 15 => data $0F
      round 16 => data $10
      final    => data $11
      ********************}
			current_cmd:=valor;
			// Palette request cmd - verified to take around 122242 68000 cycles to complete
			if ((current_cmd>=$1) and (current_cmd<$12)) then begin
        timer[cc_timer].time_final:=122242;
        timer[cc_timer].enabled:=true;
			end
			// Unknown cmd - verified to take around 105500 68000 cycles to complete
			  else if ((current_cmd>=$81) and (current_cmd<$92)) then begin
          timer[cc_timer].time_final:=105500;
          timer[cc_timer].enabled:=true;
        end else begin
				  //logerror("unknown cchip cmd %02x\n", data);
				  current_cmd:=0;
			  end;
		end;
		// Some kind of timer command
		if (direccion=$3ff) then current_flag:=valor;
	end;
end;

function volfied_cchip_ctrl_r:word;
begin
  volfied_cchip_ctrl_r:=$1;
end;

procedure volfied_cchip_ctrl_w(valor:word);
begin
end;

procedure volfied_cchip_reset;
begin
	current_bank:=0;
	current_flag:=0;
	cc_port:=0;
	current_cmd:=0;
end;

procedure volfied_cchip_bank_w(valor:word);
begin
  current_bank:=valor and $7;
end;

procedure volfied_timer;
var
  i:byte;
begin
timer[cc_timer].enabled:=false;
// Palette commands - palette data written to bank 0: $10 - $af
if ((current_cmd>=$1) and (current_cmd<$12)) then begin
  for i:=0 to $49 do begin
    cchip_ram[$10+i*2+0]:=palette_data[current_cmd,i] shr 8;
    cchip_ram[$10+i*2+1]:=palette_data[current_cmd,i] and $ff;
  end;
end;
// Unknown command - result written to bank 0: $23
if ((current_cmd>=$81) and (current_cmd<$92)) then begin
		case current_cmd of
  		$81:cchip_ram[$23]:=$f;
  		$82:cchip_ram[$23]:=$1;
  		$83:cchip_ram[$23]:=$6;
  		$84:cchip_ram[$23]:=$f;
  		$85:cchip_ram[$23]:=$9;
  		$86:cchip_ram[$23]:=$6;
  		$87:cchip_ram[$23]:=$6;
  		$88:cchip_ram[$23]:=$f;
  		$89:cchip_ram[$23]:=$8;
  		$8a:cchip_ram[$23]:=$1;
	  	$8b:cchip_ram[$23]:=$a;
      $8c:cchip_ram[$23]:=$1;
  		$8d:cchip_ram[$23]:=$1;
  		$8e:cchip_ram[$23]:=$8;
  		$8f:cchip_ram[$23]:=$6;
  		$90:cchip_ram[$23]:=$a;
  		$91:cchip_ram[$23]:=$0;
    end;
end;
current_cmd:=0;
end;

end.
