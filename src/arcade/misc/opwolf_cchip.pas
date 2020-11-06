unit opwolf_cchip;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     controls_engine,timer_engine;

procedure opwolf_init_cchip(num:byte);
procedure opwolf_cchip_reset;
function opwolf_cchip_data_r(direccion:word):word;
procedure opwolf_cchip_data_w(direccion,valor:word);
function opwolf_cchip_status_r:word;
procedure opwolf_cchip_status_w(valor:word);
procedure opwolf_cchip_bank_w(valor:word);
procedure opwolf_timer;
procedure opwolf_timer_callback;

implementation
uses operationwolf_hw;

const
  level_data:array[0..6,0..$cb] of word=((
	$0480,$1008,$0300,$5701,$0001,$0010,$0480,$1008,
	$0300,$5701,$0001,$002b,$0780,$0009,$0300,$4a01,
	$0004,$0020,$0780,$1208,$0300,$5d01,$0004,$0030,
	$0780,$0209,$0300,$4c01,$0004,$0038,$0780,$0309,
	$0300,$4d01,$0004,$0048,$0980,$1108,$0300,$5a01,
	$c005,$0018,$0980,$0109,$0300,$4b01,$c005,$0028,
	$0b80,$020a,$0000,$6401,$8006,$0004,$0c80,$010b,
	$0000,$f201,$8006,$8002,$0b80,$020a,$0000,$6401,
	$8006,$0017,$0c80,$010b,$0000,$f201,$8006,$8015,
	$0b80,$020a,$0000,$6401,$0007,$0034,$0c80,$010b,
	$0000,$f201,$0007,$8032,$0b80,$020a,$0000,$6401,
	$8006,$803e,$0c80,$010b,$0000,$f201,$8006,$803d,
	$0b80,$100a,$0000,$6001,$0007,$0008,$0b80,$100a,
	$0000,$6001,$0007,$000b,$0b80,$100a,$0000,$6001,
	$0007,$001b,$0b80,$100a,$0000,$6001,$0007,$001e,
	$0b80,$100a,$0000,$6001,$8007,$0038,$0b80,$100a,
	$0000,$6001,$8007,$003b,$0b80,$100a,$0000,$6001,
	$0007,$8042,$0b80,$100a,$0000,$6001,$0007,$8045,
	$0c80,$000b,$0000,$f101,$800b,$8007,$0c80,$000b,
	$0000,$f101,$800b,$801a,$0c80,$000b,$0000,$f101,
	$000c,$8037,$0c80,$000b,$0000,$f101,$800b,$0042,
	$0c80,$d04b,$0000,$f301,$8006,$8009,$0c80,$d04b,
	$0000,$f301,$8006,$801c,$0c80,$d04b,$0000,$f301,
	$8006,$0044,$0c80,$030b,$0000,$f401,$0008,$0028,
	$0c80,$030b,$0000,$f401,$0008,$804b,$0c00,$040b,
	$0000,$f501,$0008,$8026),
 ($0780,$0209,$0300,$4c01,$0004,$0010,$0780,$0209,
	$0300,$4c01,$4004,$0020,$0780,$0309,$0300,$4d01,
	$e003,$0030,$0780,$0309,$0300,$4d01,$8003,$0040,
	$0780,$0209,$0300,$4c01,$8004,$0018,$0780,$0309,
	$0300,$4d01,$c003,$0028,$0b80,$000b,$0000,$0b02,
	$8009,$0029,$0b80,$0409,$0000,$0f02,$8008,$8028,
	$0b80,$040a,$0000,$3502,$000a,$8028,$0b80,$050a,
	$0000,$1002,$8006,$8028,$0b80,$120a,$0000,$3602,
	$0008,$004d,$0b80,$120a,$0000,$3602,$0008,$004f,
	$0b80,$120a,$0000,$3602,$0008,$0001,$0b80,$120a,
	$0000,$3602,$0008,$0003,$0b80,$130a,$0000,$3a02,
	$0007,$0023,$0b80,$130a,$0000,$3a02,$0007,$8025,
	$0b80,$130a,$0000,$3a02,$8009,$0023,$0b80,$130a,
	$0000,$3a02,$8009,$8025,$0b80,$140a,$0000,$3e02,
	$0007,$000d,$0b80,$140a,$0000,$3e02,$0007,$800f,
	$0b80,$000b,$0000,$0102,$0007,$804e,$0b80,$d24b,
	$0000,$0302,$0007,$000e,$0b80,$000b,$0000,$0402,
	$8006,$0020,$0b80,$d34b,$0000,$0502,$8006,$0024,
	$0b80,$000b,$0000,$0602,$8009,$0001,$0b80,$d44b,
	$0000,$0702,$800b,$800b,$0b80,$d54b,$0000,$0802,
	$800b,$000e,$0b80,$000b,$0000,$0902,$800b,$0010,
	$0b80,$000b,$0000,$0a02,$0009,$0024,$0b80,$d64b,
	$0000,$0c02,$000c,$8021,$0b80,$000b,$0000,$0d02,
	$000c,$0025,$0b80,$000b,$0000,$0e02,$8009,$004e,
	$0b80,$0609,$0300,$4e01,$8006,$8012,$0b80,$0609,
	$0300,$4e01,$0007,$8007),
 ($0480,$000b,$0300,$4501,$0001,$0018,$0480,$000b,
	$0300,$4501,$2001,$0030,$0780,$1208,$0300,$5d01,
	$0004,$0010,$0780,$1208,$0300,$5d01,$2004,$001c,
	$0780,$1208,$0300,$5d01,$e003,$0026,$0780,$1208,
	$0300,$5d01,$8003,$0034,$0780,$1208,$0300,$5d01,
	$3004,$0040,$0780,$010c,$0300,$4601,$4004,$0022,
	$0780,$010c,$0300,$4601,$6004,$0042,$0780,$000c,
	$0500,$7b01,$800b,$0008,$0780,$010c,$0300,$4601,
	$2004,$0008,$0000,$0000,$0000,$f001,$0000,$0000,
	$0000,$0000,$0000,$f001,$0000,$0000,$0000,$0000,
	$0000,$f001,$0000,$0000,$0b80,$000b,$0000,$1902,
	$000b,$0004,$0b80,$000b,$0000,$1a02,$0009,$8003,
	$0b80,$000b,$0000,$1902,$000b,$000c,$0b80,$000b,
	$0000,$1a02,$0009,$800b,$0b80,$000b,$0000,$1902,
	$000b,$001c,$0b80,$000b,$0000,$1a02,$0009,$801b,
	$0b80,$000b,$0000,$1902,$000b,$002c,$0b80,$000b,
	$0000,$1a02,$0009,$802b,$0b80,$000b,$0000,$1902,
	$000b,$0044,$0b80,$000b,$0000,$1a02,$0009,$8043,
	$0b80,$000b,$0000,$1902,$000b,$004c,$0b80,$000b,
	$0000,$1a02,$0009,$804b,$0b80,$020c,$0300,$4801,
	$a009,$0010,$0b80,$020c,$0300,$4801,$a009,$0028,
	$0b80,$020c,$0300,$4801,$a009,$0036,$0000,$0000,
	$0000,$f001,$0000,$0000,$0000,$0000,$0000,$f001,
	$0000,$0000,$0000,$0000,$0000,$f001,$0000,$0000,
	$0000,$0000,$0000,$f001,$0000,$0000,$0000,$0000,
	$0000,$f001,$0000,$0000),
 ($0480,$000b,$0300,$4501,$0001,$0018,$0480,$000b,
	$0300,$4501,$2001,$002b,$0780,$010c,$0300,$4601,
	$0004,$000d,$0780,$000c,$0500,$7b01,$800b,$0020,
	$0780,$010c,$0300,$4601,$2004,$0020,$0780,$010c,
	$0300,$4601,$8003,$0033,$0780,$010c,$0300,$4601,
	$0004,$003c,$0780,$010c,$0300,$4601,$d003,$0045,
	$0780,$000c,$0500,$7b01,$900b,$0041,$0780,$010c,
	$0300,$4601,$3004,$0041,$0b80,$020c,$0300,$4801,
	$0007,$0000,$0b80,$410a,$0000,$2b02,$e006,$4049,
	$0b80,$020c,$0300,$4801,$8007,$000b,$0b80,$000b,
	$0000,$2702,$800a,$8005,$0b80,$000b,$0000,$1e02,
	$0008,$800e,$0b80,$000b,$0000,$1f02,$8007,$0011,
	$0b80,$000b,$0000,$2802,$000b,$0012,$0b80,$000b,
	$0000,$2002,$0007,$8015,$0b80,$000b,$0000,$2102,
	$0007,$801b,$0b80,$000b,$0000,$2902,$800a,$001a,
	$0b80,$000b,$0000,$2202,$8007,$001e,$0b80,$000b,
	$0000,$1e02,$0008,$0025,$0b80,$000b,$0000,$2302,
	$8007,$802c,$0b80,$000b,$0000,$2802,$000b,$8028,
	$0b80,$020c,$0300,$4801,$0007,$0030,$0b80,$400a,
	$0000,$2e02,$4007,$002d,$0b80,$000b,$0000,$2702,
	$800a,$8035,$0b80,$020c,$0300,$4801,$8007,$0022,
	$0b80,$000b,$0000,$2402,$8007,$0047,$0b80,$000b,
	$0000,$2a02,$800a,$004b,$0b80,$000b,$0000,$2502,
	$0007,$804b,$0b80,$000b,$0000,$2602,$0007,$004e,
	$0b80,$020c,$0300,$4801,$0007,$8043,$0b80,$020c,
	$0300,$4801,$8007,$803d),
 ($0780,$0209,$0300,$4c01,$0004,$0010,$0780,$0209,
	$0300,$4c01,$4004,$0020,$0780,$0309,$0300,$4d01,
	$e003,$0030,$0780,$0309,$0300,$4d01,$8003,$0040,
	$0780,$0209,$0300,$4c01,$8004,$0018,$0780,$0309,
	$0300,$4d01,$c003,$0028,$0780,$000b,$0300,$5601,
	$8004,$0008,$0780,$000b,$0300,$5601,$8004,$0038,
	$0780,$000b,$0300,$5501,$8004,$0048,$0980,$0509,
	$0f00,$0f01,$4005,$4007,$0980,$0509,$0f00,$0f01,
	$4005,$4037,$0b80,$030a,$0000,$1302,$8006,$0040,
	$0b80,$110a,$0000,$1502,$8008,$8048,$0b80,$110a,
	$0000,$1502,$8008,$8049,$0b80,$000b,$0000,$f601,
	$0007,$8003,$0b80,$000b,$0000,$f701,$0007,$0005,
	$0b80,$000b,$0000,$f901,$0007,$8008,$0b80,$000b,
	$0000,$f901,$0007,$0010,$0b80,$000b,$0000,$fa01,
	$0007,$8013,$0b80,$000b,$0000,$f801,$800b,$800b,
	$0b80,$000b,$0000,$0002,$800b,$801a,$0b80,$000b,
	$0000,$f901,$0007,$8017,$0b80,$000b,$0000,$fa01,
	$0007,$001b,$0b80,$000b,$0000,$f801,$800b,$0013,
	$0b80,$000b,$0000,$4202,$800b,$0016,$0b80,$000b,
	$0000,$fb01,$8007,$8020,$0b80,$000b,$0000,$f601,
	$0007,$8023,$0b80,$000b,$0000,$4202,$800b,$800e,
	$0b80,$000b,$0000,$4302,$800b,$801d,$0b80,$000b,
	$0000,$f701,$0007,$0025,$0b80,$000b,$0000,$fd01,
	$8006,$003f,$0b80,$000b,$0000,$fe01,$0007,$0046,
	$0b80,$000b,$0000,$ff01,$8007,$8049,$0b80,$000b,
	$0000,$fc01,$8009,$0042),
 ($0480,$1008,$0300,$5701,$0001,$0010,$0480,$1008,
	$0300,$5701,$0001,$002b,$0780,$0009,$0300,$4a01,
	$0004,$0020,$0780,$1208,$0300,$5d01,$0004,$0030,
	$0780,$0209,$0300,$4c01,$0004,$0038,$0780,$0309,
	$0300,$4d01,$0004,$0048,$0980,$1108,$0300,$5a01,
	$c005,$0018,$0980,$0109,$0300,$4b01,$c005,$0028,
	$0b80,$020a,$0000,$6401,$8006,$0004,$0c80,$010b,
	$0000,$f201,$8006,$8002,$0b80,$020a,$0000,$6401,
	$8006,$0017,$0c80,$010b,$0000,$f201,$8006,$8015,
	$0b80,$020a,$0000,$6401,$0007,$0034,$0c80,$010b,
	$0000,$f201,$0007,$8032,$0b80,$020a,$0000,$6401,
	$8006,$803e,$0c80,$010b,$0000,$f201,$8006,$803d,
	$0b80,$100a,$0000,$6001,$0007,$0008,$0b80,$100a,
	$0000,$6001,$0007,$000b,$0b80,$100a,$0000,$6001,
	$0007,$001b,$0b80,$100a,$0000,$6001,$0007,$001e,
	$0b80,$100a,$0000,$6001,$8007,$0038,$0b80,$100a,
	$0000,$6001,$8007,$003b,$0b80,$100a,$0000,$6001,
	$0007,$8042,$0b80,$100a,$0000,$6001,$0007,$8045,
	$0c80,$000b,$0000,$f101,$800b,$8007,$0c80,$000b,
	$0000,$f101,$800b,$801a,$0c80,$000b,$0000,$f101,
	$000c,$8037,$0c80,$000b,$0000,$f101,$800b,$0042,
	$0c80,$d04b,$0000,$f301,$8006,$8009,$0c80,$d04b,
	$0000,$f301,$8006,$801c,$0c80,$d04b,$0000,$f301,
	$8006,$0044,$0c80,$030b,$0000,$f401,$0008,$0028,
	$0c80,$030b,$0000,$f401,$0008,$804b,$0c00,$040b,
	$0000,$f501,$0008,$8026),
 ($0000,$1008,$0300,$5701,$0001,$0010,$0000,$1008,
	$0300,$5701,$0001,$002b,$0000,$0000,$0000,$0000,
	$0000,$0000,$0700,$0009,$0300,$4a01,$0004,$0020,
	$0700,$1208,$0300,$5d01,$0004,$0030,$0700,$0209,
	$0300,$4c01,$0004,$0038,$0700,$0309,$0300,$4d01,
	$0004,$0048,$0900,$1108,$0300,$5a01,$c005,$0018,
	$0900,$0109,$0300,$4b01,$c005,$0028,$0000,$000b,
	$0000,$0000,$0018,$0000,$0000,$000b,$0000,$0000,
	$0018,$0000,$0000,$000b,$0000,$0000,$0018,$0000,
	$0000,$000b,$0000,$0000,$0018,$0000,$0000,$000b,
	$0000,$0000,$0018,$0000,$0000,$000b,$0000,$0000,
	$0018,$0000,$0000,$000b,$0000,$0000,$0018,$0000,
	$0000,$000b,$0000,$0000,$0018,$0000,$0000,$000b,
	$0000,$0000,$0018,$0000,$0980,$db4c,$0000,$3202,
	$0006,$0004,$0b80,$0609,$0300,$4e01,$5006,$8002,
	$0b80,$0609,$0300,$4e01,$5006,$8003,$0b80,$0609,
	$0300,$4e01,$5006,$8004,$0b80,$0609,$0300,$4e01,
	$5006,$0008,$0b80,$0609,$0300,$4e01,$5006,$0010,
	$0b80,$0609,$0300,$4e01,$5006,$0012,$0b80,$0609,
	$0300,$4e01,$5006,$0014,$0b80,$0609,$0300,$4e01,
	$5006,$0016,$0b80,$0609,$0300,$4e01,$5006,$0018,
	$0b80,$0609,$0300,$4e01,$5006,$0020,$0b80,$0609,
	$0300,$4e01,$5006,$0023,$0b80,$0609,$0300,$4e01,
	$5006,$0030,$0b80,$0609,$0300,$4e01,$5006,$0038,
	$0b80,$0609,$0300,$4e01,$5006,$0040,$0b80,$0609,
	$0300,$4e01,$5006,$0042));

var
  cchip_ram:array[0..($400*8)-1] of byte;
  current_cmd,current_bank,cc_timer,cchip_last_7a,cchip_last_04,cchip_last_05,c588,c589,c58a:byte;
  cchip_coins,cchip_coins_for_credit,cchip_credits_for_coin:array[0..1] of byte;

procedure updateDifficulty(mode:byte);
begin
	// The game is made up of 6 rounds, when you complete the
	// sixth you return to the start but with harder difficulty.
	if (mode=0) then begin
		case (cchip_ram[$15] and $3) of // Dipswitch B
		  3:begin
    			cchip_ram[$2c]:=$31;
    			cchip_ram[$77]:=$05;
    			cchip_ram[$25]:=$0f;
    			cchip_ram[$26]:=$0b;
			  end;
		  0:begin
          cchip_ram[$2c]:=$20;
          cchip_ram[$77]:=$06;
          cchip_ram[$25]:=$07;
          cchip_ram[$26]:=$03;
			  end;
		  1:begin
          cchip_ram[$2c]:=$31;
          cchip_ram[$77]:=$05;
          cchip_ram[$25]:=$0f;
          cchip_ram[$26]:=$0b;
			  end;
		  2:begin
          cchip_ram[$2c]:=$3c;
          cchip_ram[$77]:=$04;
          cchip_ram[$25]:=$13;
          cchip_ram[$26]:=$0f;
        end;
		end;
	end else begin
		case (cchip_ram[$15] and 3) of // Dipswitch B
		  3:begin
          cchip_ram[$2c]:=$46;
          cchip_ram[$77]:=$05;
          cchip_ram[$25]:=$11;
          cchip_ram[$26]:=$0e;
			  end;
		  0:begin
          cchip_ram[$2c]:=$30;
          cchip_ram[$77]:=$06;
          cchip_ram[$25]:=$0b;
          cchip_ram[$26]:=$03;
			  end;
		  1:begin
          cchip_ram[$2c]:=$3a;
          cchip_ram[$77]:=$05;
          cchip_ram[$25]:=$0f;
          cchip_ram[$26]:=$09;
			  end;
		  2:begin
          cchip_ram[$2c]:=$4c;
          cchip_ram[$77]:=$04;
          cchip_ram[$25]:=$19;
          cchip_ram[$26]:=$11;
			  end;
		end;
	end;
end;

procedure opwolf_init_cchip(num:byte);
begin
  timers.init(num,8000000/60,opwolf_timer,nil,true);
  cc_timer:=timers.init(num,80000,opwolf_timer_callback,nil,false);
end;

function opwolf_cchip_data_r(direccion:word):word;
begin
  direccion:=direccion shr 1;
	opwolf_cchip_data_r:=cchip_ram[(current_bank*$400)+direccion];
end;

procedure opwolf_cchip_data_w(direccion,valor:word);
var
  coin_table:array[0..1] of dword;
  coin_offset:array[0..1] of byte;
  slot:byte;
begin
  direccion:=direccion shr 1;
  cchip_ram[(current_bank*$400)+direccion]:=valor and $ff;
	if (current_bank=0) then begin
		// Dip switch A is written here by the 68k - precalculate the coinage values
		// Shouldn't we directly read the values from the ROM area ?
		if (direccion=$14) then begin
      coin_table[0]:=$03ffde;
      coin_table[1]:=$03ffee;
			coin_offset[0]:=12-(4*((valor and $30) shr 4));
			coin_offset[1]:=12-(4*((valor and $c0) shr 6));
			for slot:=0 to 1 do begin
				if (coin_table[slot]<>0) then begin
					cchip_coins_for_credit[slot]:=rom[(coin_table[slot]+coin_offset[slot]+0) shr 1] and $ff;
					cchip_credits_for_coin[slot]:=rom[(coin_table[slot]+coin_offset[slot]+2) shr 1] and $ff;
				end;
			end;
		end;
		// Dip switch B
		if (direccion=$15) then updateDifficulty(0);
	end;
end;

function opwolf_cchip_status_r:word;
begin
  opwolf_cchip_status_r:=$1;
end;

procedure opwolf_cchip_status_w(valor:word);
begin
cchip_ram[$3d]:=1;
cchip_ram[$7a]:=1;
updateDifficulty(0);
end;

procedure opwolf_cchip_bank_w(valor:word);
begin
  current_bank:=valor and $7;
end;

procedure opwolf_cchip_reset;
begin
	current_bank:=0;
  current_cmd:=0;
	cchip_last_7a:=0;
	cchip_last_04:=$fc;
	cchip_last_05:=$ff;
	c588:=0;
	c589:=0;
	c58a:=0;
  cchip_coins[0]:=0;
	cchip_coins[1]:=0;
  cchip_coins_for_credit[0]:=1;
	cchip_credits_for_coin[0]:=1;
	cchip_coins_for_credit[1]:=1;
	cchip_credits_for_coin[1]:=1;
end;

procedure opwolf_timer;
var
  slot:integer;
begin
	// Update input ports, these are used by both the 68k directly and by the c-chip
	cchip_ram[$4]:=marcade.in0;// ioport("IN0")->read();
	cchip_ram[$5]:=marcade.in1;// ioport("IN1")->read();
	// Coin slots
	if (cchip_ram[$4]<>cchip_last_04) then begin
		slot:=-1;
		if (cchip_ram[$4] and 1)<>0 then slot:=0;
		if (cchip_ram[$4] and 2)<>0 then slot:=1;
		if (slot<>-1) then begin
			cchip_coins[slot]:=cchip_coins[slot]+1;
			if (cchip_coins[slot]>=cchip_coins_for_credit[slot]) then begin
				cchip_ram[$53]:=cchip_ram[$53]+cchip_credits_for_coin[slot];
				cchip_ram[$51]:=$55;
				cchip_ram[$52]:=$55;
				cchip_coins[slot]:=cchip_coins[slot]-cchip_coins_for_credit[slot];
			end;
		end;
		if (cchip_ram[$53]>9) then cchip_ram[$53]:=9;
	end;
	cchip_last_04:=cchip_ram[$4];
	// Service switch
	if (cchip_ram[$5]<>cchip_last_05) then begin
		if ((cchip_ram[$5] and 4)=0) then begin
			cchip_ram[$53]:=cchip_ram[$53]+1;
			cchip_ram[$51]:=$55;
			cchip_ram[$52]:=$55;
		end;
	end;
	cchip_last_05:=cchip_ram[$5];
	// Special handling for last level
	if (cchip_ram[$1b]=$6) then begin
		// Check for triggering final helicopter (end boss)
		if (c58a=0) then begin
			if (((cchip_ram[$72] and $7f)>=8) and (cchip_ram[$74]=0) and (cchip_ram[$1c]=0) and (cchip_ram[$1d]=0) and (cchip_ram[$1f]=0)) then begin
				cchip_ram[$30]:=1;
				cchip_ram[$74]:=1;
				c58a:=1;
			end;
		end;
		if (cchip_ram[$1a]=$90) then cchip_ram[$74]:=0;
		if (c58a<>0) then begin
			if ((c589=0) and (cchip_ram[$27]=0) and (cchip_ram[$75]=0) and (cchip_ram[$1c]=0) and (cchip_ram[$1d]=0) and (cchip_ram[$1e]=0) and (cchip_ram[$1f]=0)) then begin
				cchip_ram[$31]:=1;
				cchip_ram[$75]:=1;
				c589:=1;
			end;
		end;
		if (cchip_ram[$2b]=$1) then begin
			cchip_ram[$2b]:=0;
			if (cchip_ram[$30]=$1) then begin
				if (cchip_ram[$1a]<>$90) then cchip_ram[$1a]:=cchip_ram[$1a]-1;
			end;
			if (cchip_ram[$72]=$9) then begin
				if (cchip_ram[$76]<>$4) then cchip_ram[$76]:=3;
			end else begin
				// This timer is derived from the bootleg rather than the real board, I'm not 100% sure about it
				c588:=c588 or $80;
				cchip_ram[$72]:=c588;
				c588:=c588+1;
				cchip_ram[$1a]:=cchip_ram[$1a]-1;
				cchip_ram[$1a]:=cchip_ram[$1a]-1;
				cchip_ram[$1a]:=cchip_ram[$1a]-1;
			end;
		end;
		// Update difficulty settings
		if (cchip_ram[$76]=0) then begin
			cchip_ram[$76]:=1;
			updateDifficulty(1);
		end;
	end;
	// These variables are cleared every frame during attract mode and the intro.
	if (cchip_ram[$34]<2) then begin
		updateDifficulty(0);
		cchip_ram[$76]:=0;
		cchip_ram[$75]:=0;
		cchip_ram[$74]:=0;
		cchip_ram[$72]:=0;
		cchip_ram[$71]:=0;
		cchip_ram[$70]:=0;
		cchip_ram[$66]:=0;
		cchip_ram[$2b]:=0;
		cchip_ram[$30]:=0;
		cchip_ram[$31]:=0;
		cchip_ram[$32]:=0;
		cchip_ram[$27]:=0;
		c588:=0;
		c589:=0;
		c58a:=0;
	end;
	// Check for level completion (all enemies destroyed)
	if ((cchip_ram[$1c]=0) and (cchip_ram[$1d]=0) and (cchip_ram[$1e]=0) and (cchip_ram[$1f]=0) and (cchip_ram[$20]=0)) then begin
		// Special handling for end of level 6
 		if (cchip_ram[$1b]=$6) then begin
			// Don't signal end of level until final boss is destroyed
			if (cchip_ram[$27]=$1) then cchip_ram[$32]:=1;
		end else begin
			// Signal end of level
			cchip_ram[$32]:=1;
		end;
	end;
	if (cchip_ram[$e]=1) then begin
		cchip_ram[$e]:=$fd;
		cchip_ram[$61]:=$04;
	end;
	// Access level data command (address $f5 goes from 1 -> 0)
	if ((cchip_ram[$7a]=0) and (cchip_last_7a<>0) and (current_cmd<>$f5)) then begin
		// Simulate time for command to execute (exact timing unknown, this is close)
		current_cmd:=$f5;
    timers.enabled(cc_timer,true);
	end;
	cchip_last_7a:=cchip_ram[$7a];
	// This seems to some kind of periodic counter - results are expected
	// by the 68k when the counter reaches $a
	if (cchip_ram[$7f]=$a) then begin
		cchip_ram[$fe]:=$f7;
		cchip_ram[$ff]:=$6e;
	end;
	// These are set every frame
	cchip_ram[$64]:=0;
	cchip_ram[$66]:=0;
end;

procedure opwolf_timer_callback;
var
  i,level:byte;
begin
timers.enabled(cc_timer,false);
if (current_cmd=$f5) then begin
		level:=cchip_ram[$1b];
		for i:=0 to $cb do begin
			cchip_ram[$200+i*2+0]:=level_data[level,i] shr 8;
			cchip_ram[$200+i*2+1]:=level_data[level,i] and $ff;
		end;
		// The bootleg cchip writes 0 to these locations - hard to tell what the real one writes
		cchip_ram[$0]:=0;
		cchip_ram[$76]:=0;
		cchip_ram[$75]:=0;
		cchip_ram[$74]:=0;
		cchip_ram[$72]:=0;
		cchip_ram[$71]:=0;
		cchip_ram[$70]:=0;
		cchip_ram[$66]:=0;
		cchip_ram[$2b]:=0;
		cchip_ram[$30]:=0;
		cchip_ram[$31]:=0;
		cchip_ram[$32]:=0;
		cchip_ram[$27]:=0;
		c588:=0;
		c589:=0;
		c58a:=0;
		cchip_ram[$1a]:=0;
		cchip_ram[$7a]:=1; // Signal command complete
end;
current_cmd:=0;
end;

end.
