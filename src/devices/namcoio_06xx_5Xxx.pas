unit namcoio_06xx_5Xxx;

interface
uses main_engine,timer_engine,mb88xx,rom_engine,cpu_misc,samples;

const
  NONE=0;
  IO50XX_0=4;
  IO50XX_1=5;
  IO51XX=1;
  IO53XX=2;
  IO54XX=3;

type
  read_chip=function:byte;
  write_chip=procedure(data:byte);
  read_req_chip=procedure;
  tipo_50xx=record
    frames:single;
    latched_cmd:byte;
    latched_rw:byte;
    port_o:byte;
    timer:byte;
    mb88:cpu_mb88xx;
  end;
  tipo_51xx=record
  	mode,coincred_mode,credits,in_count,lastcoins,lastbuttons:byte;
    coins_per_cred,creds_per_coin,coins:array[0..1] of byte;
    remap_joy,kludge:boolean;
    read_port:array[0..1] of pbyte;
    write_port:array[0..1] of write_chip;
  end;
  tipo_53xx=record
    port_o:byte;
    timer:byte;
    frame:single;
    mb88:cpu_mb88xx;
  end;
  tipo_54xx=record
    latched_cmd,old_sam,old_sam2:byte;
    timer:byte;
    frame:single;
    mb88:cpu_mb88xx;
  end;
  tipo_06xx=record
    control:byte;
    fread:array[0..3] of read_chip;
    fwrite:array[0..3] of write_chip;
    fread_req:array[0..3] of read_req_chip;
    nmi_timer:byte;
  end;

//Namco 06XX
procedure namco_06xx_init(num:byte;chip0,chip1,chip2,chip3:byte;nmi_function:exec_type_simple);
procedure namcoio_06xx_reset(num:byte);
function namco_06xx_data_r(dir,num:byte):byte;
procedure namco_06xx_data_w(dir,num,data:byte);
function namco_06xx_ctrl_r(num:byte):byte;
procedure namco_06xx_ctrl_w(num,data:byte);
//50XX
function namcoio_50xx_init(num:byte;zip_name:string):boolean;
procedure run_namco_50xx(num:byte);
procedure namcoio_50xx_reset(num:byte);
procedure namco_50xx_close(num:byte);
//51XX
procedure namcoio_51xx_init(in0,in1:pbyte);
procedure namcoio_51xx_reset(kludge:boolean);
//53XX
function namcoio_53xx_init(port_k:cpu_inport_call;port_r_r:type_mb88xx_inport_r;zip_name:string):boolean;
procedure namco_53xx_o_w(valor:byte);
procedure namcoio_53xx_reset;
procedure run_namco_53xx;
procedure namco_53xx_close;
//54XX
function namcoio_54xx_init(zip_name:string):boolean;
procedure run_namco_54xx;
procedure namcoio_54xx_reset;
procedure namco_54xx_close;

var
  namco_06xx:array[0..1] of tipo_06xx;
  namco_50xx:array[0..1] of tipo_50xx;
  namco_51xx:tipo_51xx;
  namco_53xx:tipo_53xx;
  namco_54xx:tipo_54xx;

implementation
const
  namco_50xx_rom:tipo_roms=(n:'50xx.bin';l:$800;p:0;crc:$a0acbaf7);
  namco_53xx_rom:tipo_roms=(n:'53xx.bin';l:$400;p:0;crc:$b326fecb);
  namco_54xx_rom:tipo_roms=(n:'54xx.bin';l:$400;p:0;crc:$ee7357e0);

//Namco 50XX
function namco_50xx_k_r_0:byte;
begin
  namco_50xx_k_r_0:=namco_50xx[0].latched_cmd shr 4;
end;

function namco_50xx_k_r_1:byte;
begin
  namco_50xx_k_r_1:=namco_50xx[1].latched_cmd shr 4;
end;

procedure namco_50xx_o_w_0(valor:byte);
begin
	if (valor and $10)<>0 then namco_50xx[0].port_o:=(namco_50xx[0].port_o and $f) or ((valor and $f) shl 4)
    else namco_50xx[0].port_o:=(namco_50xx[0].port_o and $f0) or (valor and $f);
end;

procedure namco_50xx_o_w_1(valor:byte);
begin
	if (valor and $10)<>0 then namco_50xx[1].port_o:=(namco_50xx[1].port_o and $f) or ((valor and $f) shl 4)
    else namco_50xx[1].port_o:=(namco_50xx[1].port_o and $f0) or (valor and $f);
end;

function namco_50xx_r_r_0(port:byte):byte;
begin
  case port of
    0:namco_50xx_r_r_0:=namco_50xx[0].latched_cmd and $f;
    2:namco_50xx_r_r_0:=namco_50xx[0].latched_rw and 1;
  end;
end;

function namco_50xx_r_r_1(port:byte):byte;
begin
  case port of
    0:namco_50xx_r_r_1:=namco_50xx[1].latched_cmd and $f;
    2:namco_50xx_r_r_1:=namco_50xx[1].latched_rw and 1;
  end;
end;

function namcoio_50XX_read_0:byte;
begin
  namcoio_50XX_read_0:=namco_50xx[0].port_o;
  namco_50xx[0].latched_rw:=1;
  namco_50xx[0].mb88.set_irq_line(ASSERT_LINE);
  timers.enabled(namco_50xx[0].timer,true);
end;

function namcoio_50XX_read_1:byte;
begin
  namcoio_50XX_read_1:=namco_50xx[1].port_o;
  namco_50xx[1].latched_rw:=1;
  namco_50xx[1].mb88.set_irq_line(ASSERT_LINE);
  timers.enabled(namco_50xx[1].timer,true);
end;

procedure namcoio_50XX_write_0(valor:byte);
begin
  namco_50xx[0].latched_cmd:=valor;
  namco_50xx[0].latched_rw:=0;
  namco_50xx[0].mb88.set_irq_line(ASSERT_LINE);
  timers.enabled(namco_50xx[0].timer,true);
end;

procedure namcoio_50XX_write_1(valor:byte);
begin
  namco_50xx[1].latched_cmd:=valor;
  namco_50xx[1].latched_rw:=0;
  namco_50xx[1].mb88.set_irq_line(ASSERT_LINE);
  timers.enabled(namco_50xx[1].timer,true);
end;

procedure namcoio_50xx_read_req_0;
begin
  namco_50xx[0].latched_rw:=1;
  namco_50xx[0].mb88.set_irq_line(ASSERT_LINE);
  timers.enabled(namco_50xx[0].timer,true);
end;

procedure namcoio_50xx_read_req_1;
begin
  namco_50xx[1].latched_rw:=1;
  namco_50xx[1].mb88.set_irq_line(ASSERT_LINE);
  timers.enabled(namco_50xx[1].timer,true);
end;

procedure namcoio_50xx_irq_clear_0;
begin
	namco_50xx[0].mb88.set_irq_line(CLEAR_LINE);
  timers.enabled(namco_50xx[0].timer,false);
end;

procedure namcoio_50xx_irq_clear_1;
begin
	namco_50xx[1].mb88.set_irq_line(CLEAR_LINE);
  timers.enabled(namco_50xx[1].timer,false);
end;

function namcoio_50xx_init(num:byte;zip_name:string):boolean;
begin
namco_50xx[num].mb88:=cpu_mb88xx.Create(1536000,264);
namco_50xx[num].frames:=namco_50xx[num].mb88.tframes;
//namco 50XX clock 1536000*0.000021=32.256
case num of
  0:begin
      namco_50xx[0].mb88.change_io_calls(namco_50xx_k_r_0,namco_50xx_o_w_0,nil,nil,namco_50xx_r_r_0,nil);
      namco_50xx[0].timer:=timers.init(namco_50xx[0].mb88.numero_cpu,32.256,namcoio_50xx_irq_clear_0,nil,false);
  end;
  1:begin
      namco_50xx[1].mb88.change_io_calls(namco_50xx_k_r_1,namco_50xx_o_w_1,nil,nil,namco_50xx_r_r_1,nil);
      namco_50xx[1].timer:=timers.init(namco_50xx[1].mb88.numero_cpu,32.256,namcoio_50xx_irq_clear_1,nil,false);
  end;
end;
//rom
namcoio_50xx_init:=roms_load(namco_50xx[num].mb88.get_rom_addr,namco_50xx_rom,true,true,zip_name);
end;

procedure namco_50xx_close(num:byte);
begin
namco_50xx[num].mb88.free;
end;

procedure run_namco_50xx(num:byte);
begin
  namco_50xx[num].mb88.run(namco_50xx[num].mb88.tframes);
  namco_50xx[num].frames:=namco_50xx[num].frames+namco_50xx[num].mb88.tframes-namco_50xx[num].mb88.contador;
end;

procedure namcoio_50xx_reset(num:byte);
begin
  namco_50xx[num].mb88.reset;
  namco_50xx[num].latched_cmd:=0;
  namco_50xx[num].latched_rw:=0;
  timers.enabled(namco_50xx[num].timer,false);
end;

//Namco 51XX
procedure namcoio_51XX_write(data:byte);
begin
  data:=data and $7;
	if (namco_51xx.coincred_mode<>0) then begin
		case (namco_51xx.coincred_mode) of
			4:namco_51xx.coins_per_cred[0]:=data;
			3:namco_51xx.creds_per_coin[0]:=data;
			2:namco_51xx.coins_per_cred[1]:=data;
			1:namco_51xx.creds_per_coin[1]:=data;
		end;
    namco_51xx.coincred_mode:=namco_51xx.coincred_mode-1;
	end	else begin
		case data of
			0:;	// nop
			1:if namco_51xx.kludge then begin	// set coinage
          namco_51xx.coincred_mode:=6;
          namco_51xx.remap_joy:=true;
        end else begin
				  namco_51xx.coincred_mode:=4;
				  // this is a good time to reset the credits counter */
				  namco_51xx.credits:=0;
        end;
			2:begin	// go in "credits" mode and enable start buttons
  				namco_51xx.mode:=1;
  				namco_51xx.in_count:=0;
				end;
			3:namco_51xx.remap_joy:=false; // disable joystick remapping
			4:namco_51xx.remap_joy:=true; // enable joystick remapping
			5:begin	// go in "switch" mode
				  namco_51xx.mode:=0;
				  namco_51xx.in_count:=0;
				end;
    end;
	end;
end;

function namcoio_51XX_read:byte;
var
  res,in_,toggle,on_:byte;
  joy:integer;
const
  joy_map:array[0..15] of byte=($f,$e,$d,$5,$c,$9,$7,$6,$b,$3,$a,$4,$1,$2,$0,$8);
begin
	if (namco_51xx.mode=0) then begin	// switch mode
		case namco_51xx.in_count of
			0:res:=namco_51xx.read_port[0]^;
			1:res:=namco_51xx.read_port[1]^;
			2:res:=0;	// nothing?
    end;
    namco_51xx.in_count:=(namco_51xx.in_count+1) and $3;
	end	else begin 	// credits mode
		case namco_51xx.in_count of
			0:begin	// number of credits in BCD format
					in_:=not(namco_51xx.read_port[0]^);
					toggle:=in_ xor namco_51xx.lastcoins;
					namco_51xx.lastcoins:=in_;
					if (namco_51xx.coins_per_cred[0]>0) then begin
						if (namco_51xx.credits>=99) then begin
              if @namco_51xx.write_port[1]<>nil then namco_51xx.write_port[1](1);	// coin lockout
						end	else begin
							if @namco_51xx.write_port[1]<>nil then namco_51xx.write_port[1](0);	// coin lockout
							// check if the user inserted a coin */
							if (toggle and in_ and $10)<>0 then begin
								namco_51xx.coins[0]:=namco_51xx.coins[0]+1;
								if @namco_51xx.write_port[0]<>nil then namco_51xx.write_port[0]($04);	// coin counter
								if @namco_51xx.write_port[0]<>nil then namco_51xx.write_port[0]($0c);
								if (namco_51xx.coins[0]>=namco_51xx.coins_per_cred[0]) then begin
									namco_51xx.credits:=namco_51xx.credits+namco_51xx.creds_per_coin[0];
									namco_51xx.coins[0]:=namco_51xx.coins[0]-namco_51xx.coins_per_cred[0];
								end;
							end;
							if (toggle and in_ and $20)<>0 then begin
								namco_51xx.coins[1]:=namco_51xx.coins[1]+1;
								if @namco_51xx.write_port[0]<>nil then namco_51xx.write_port[0]($08);	// coin counter
								if @namco_51xx.write_port[0]<>nil then namco_51xx.write_port[0]($0c);
								if (namco_51xx.coins[1]>=namco_51xx.coins_per_cred[1]) then begin
									namco_51xx.credits:=namco_51xx.credits+namco_51xx.creds_per_coin[1];
									namco_51xx.coins[1]:=namco_51xx.coins[1]-namco_51xx.coins_per_cred[1];
								end;
							end;  //del tst
						end;  //credits >99
					end else begin // free play
            namco_51xx.credits:= 100;
          end;
					if (namco_51xx.mode=1) then begin
					 	on_:=(main_vars.frames_sec and $10) shr 4;
						if (namco_51xx.credits>=2) then if @namco_51xx.write_port[0]<>nil then namco_51xx.write_port[0]($0c or 3*on_)	// lamps
						    else if (namco_51xx.credits>=1) then if @namco_51xx.write_port[0]<>nil then namco_51xx.write_port[0]($0c or 2*on_)	// lamps
                  else if @namco_51xx.write_port[0]<>nil then namco_51xx.write_port[0]($0c);	// lamps off
						// check for 1 player start button */
						if (toggle and in_ and $04)<>0 then begin
							if (namco_51xx.credits>=1) then begin
								namco_51xx.credits:=namco_51xx.credits-1;
								namco_51xx.mode:=2;
								if @namco_51xx.write_port[0]<>nil then namco_51xx.write_port[0]($0c);	// lamps off
							end;
						end;
						// check for 2 players start button */
            if (toggle and in_ and $08)<>0 then begin
              if (namco_51xx.credits>= 2) then begin
                namco_51xx.credits:=namco_51xx.credits-2;
                namco_51xx.mode:=2;
                if @namco_51xx.write_port[0]<>nil then namco_51xx.write_port[0]($0c);	// lamps off
              end;
            end;
					end;  //Del mode=1
  				if (not(namco_51xx.read_port[0]^ shr 4) and $8)<>0 then begin //check test mode switch */
	  				namcoio_51XX_read:=$bb;
            exit;
          end;
			  	res:=(namco_51xx.credits div 10)*16+namco_51xx.credits mod 10;
        end;
			1:begin
					joy:=namco_51xx.read_port[1]^ and $0f;
					in_:=not(namco_51xx.read_port[0]^ and $0f);
					toggle:=in_ xor namco_51xx.lastbuttons;
					namco_51xx.lastbuttons:=(namco_51xx.lastbuttons and 2) or (in_ and 1);
					// remap joystick */
					if namco_51xx.remap_joy then joy:=joy_map[joy];
					// fire */
					joy:=joy or ((((toggle and in_ and $01) xor 1) and 1) shl 4);
					joy:=joy or ((((in_ and $01) xor 1) and 1) shl 5);
					res:=joy;
				end;
			2:begin
					joy:=namco_51xx.read_port[1]^ shr 4;
					in_:=not(namco_51xx.read_port[0]^ and $0f);
					toggle:=in_ xor namco_51xx.lastbuttons;
					namco_51xx.lastbuttons:=(namco_51xx.lastbuttons and 1) or (in_ and 2);
					// remap joystick */
					if (namco_51xx.remap_joy) then joy:=joy_map[joy];
					// fire */
					joy:=joy or (((toggle and in_ and $02) xor 2) and $2) shl 3;
					joy:=joy or (((in_ and $02) xor 2) and $2) shl 4;
					res:=joy;
				end;
		end;
	end;
  namco_51xx.in_count:=(namco_51xx.in_count+1) mod 3;
  namcoio_51XX_read:=res;
end;

procedure namcoio_51xx_init(in0,in1:pbyte);
begin
  namco_51xx.read_port[0]:=in0;
  namco_51xx.read_port[1]:=in1;
end;

procedure namcoio_51xx_reset(kludge:boolean);
begin
  namco_51xx.kludge:=kludge;
  namco_51xx.credits:=0;
	namco_51xx.coins[0]:=0;
	namco_51xx.coins_per_cred[0]:=1;
	namco_51xx.creds_per_coin[0]:=1;
	namco_51xx.coins[1]:=0;
	namco_51xx.coins_per_cred[1]:=1;
	namco_51xx.creds_per_coin[1]:=1;
	namco_51xx.in_count:=0;
  namco_51xx.mode:=0;
  namco_51xx.coincred_mode:=0;
  namco_51xx.credits:=0;
  namco_51xx.lastcoins:=0;
  namco_51xx.lastbuttons:=$FF;
end;

//Namco 53XX
procedure namco_53xx_close;
begin
namco_53xx.mb88.free;
end;

procedure run_namco_53xx;
begin
  namco_53xx.mb88.run(namco_53xx.frame);
  namco_53xx.frame:=namco_53xx.frame+namco_53xx.mb88.tframes-namco_53xx.mb88.contador;
end;

procedure namcoio_53xx_irq_clear;
begin
	namco_53xx.mb88.set_irq_line(CLEAR_LINE);
  timers.enabled(namco_53xx.timer,false);
end;

procedure namcoio_53xx_read_req;
begin
  namco_53xx.mb88.set_irq_line(ASSERT_LINE);
	// The execution time of one instruction is ~4us, so we must make sure to
	// give the cpu time to poll the /IRQ input before we clear it.
	// The input clock to the 06XX interface chip is 64H, that is
	// 18432000/6/64 = 48kHz, so it makes sense for the irq line to be
	// asserted for one clock cycle ~= 21us.
  timers.enabled(namco_53xx.timer,true);
end;

function namcoio_53xx_read:byte;
begin
  namcoio_53xx_read:=namco_53xx.port_o;
  namcoio_53xx_read_req;
end;

function namcoio_53xx_init(port_k:cpu_inport_call;port_r_r:type_mb88xx_inport_r;zip_name:string):boolean;
begin
namco_53xx.mb88:=cpu_mb88xx.Create(1536000,264);
namco_53xx.mb88.change_io_calls(port_k,namco_53xx_o_w,nil,nil,port_r_r,nil);
namco_53xx.frame:=namco_53xx.mb88.tframes;
//namco 53XX clock 1536000*0.000021=32.256
namco_53xx.timer:=timers.init(namco_53xx.mb88.numero_cpu,32.256,namcoio_53xx_irq_clear,nil,false);
//rom
namcoio_53xx_init:=roms_load(namco_53xx.mb88.get_rom_addr,namco_53xx_rom,true,true,zip_name);
end;

procedure namcoio_53xx_reset;
begin
  namco_53xx.mb88.reset;
  namco_53xx.port_o:=0;
  timers.enabled(namco_53xx.timer,false);
end;

procedure namco_53xx_o_w(valor:byte);
var
  res:byte;
begin
  res:=(valor and $0f);
	if (valor and $10)<>0 then namco_53xx.port_o:=(namco_53xx.port_o and $0f) or (res shl 4)
	  else namco_53xx.port_o:=(namco_53xx.port_o and $f0) or res;
end;

//Namco 54XX
function namco_54xx_k_r:byte;
begin
  namco_54xx_k_r:=namco_54xx.latched_cmd shr 4;
end;

procedure namco_54xx_o_w(valor:byte);
begin
if (valor and $f)<>0 then begin
  if (((valor and $f)<>0) and (namco_54xx.old_sam=0)) then begin
	  if (valor and $10)<>0 then start_sample(1)
      else
      case (valor and $f) of
        13:start_sample(0);
        1,2,3,4,6,8,11,15:; //nada!
      end;
  end;
end;
namco_54xx.old_sam:=valor and $f;
end;

function namco_54xx_r_r(port:byte):byte;
begin
  if port=0 then namco_54xx_r_r:=namco_54xx.latched_cmd and $f
    else namco_54xx_r_r:=$ff;
end;

procedure namco_54xx_r_w(port,valor:byte);
begin
  if port=1 then begin
    if ((valor=11) and (namco_54xx.old_sam2=0)) then start_sample(2);
    namco_54xx.old_sam2:=valor;
  end;
end;

procedure namcoio_54XX_write(valor:byte);
begin
  namco_54xx.latched_cmd:=valor;
  namco_54xx.mb88.set_irq_line(ASSERT_LINE);
  timers.enabled(namco_54xx.timer,true);
end;

procedure namcoio_54xx_irq_clear;
begin
	namco_54xx.mb88.set_irq_line(CLEAR_LINE);
  timers.enabled(namco_54xx.timer,false);
end;

function namcoio_54xx_init(zip_name:string):boolean;
begin
namco_54xx.mb88:=cpu_mb88xx.Create(1536000,264);
namco_54xx.mb88.change_io_calls(namco_54xx_k_r,namco_54xx_o_w,nil,nil,namco_54xx_r_r,namco_54xx_r_w);
namco_54xx.frame:=namco_54xx.mb88.tframes;
//namco 53XX clock 1536000*0.000021=32.256
namco_54xx.timer:=timers.init(namco_54xx.mb88.numero_cpu,32.256,namcoio_54xx_irq_clear,nil,false);
//rom
namcoio_54xx_init:=roms_load(namco_54xx.mb88.get_rom_addr,namco_54xx_rom,true,true,zip_name);
end;

procedure namco_54xx_close;
begin
  namco_54xx.mb88.free;
end;

procedure run_namco_54xx;
begin
  namco_54xx.mb88.run(namco_54xx.frame);
  namco_54xx.frame:=namco_54xx.frame+namco_54xx.mb88.tframes-namco_54xx.mb88.contador;
end;

procedure namcoio_54xx_reset;
begin
  namco_54xx.mb88.reset;
  namco_54xx.latched_cmd:=0;
  timers.enabled(namco_54xx.timer,false);
  namco_54xx.old_sam:=0;
  namco_54xx.old_sam2:=0;
end;

//Namco 06XX
procedure namcoio_06xx_reset(num:byte);
begin
  namco_06xx[num].control:=0;
  timers.enabled(namco_06xx[num].nmi_timer,false);
end;

procedure namco_06xx_init(num:byte;chip0,chip1,chip2,chip3:byte;nmi_function:exec_type_simple);
procedure none_chip(io,num:byte);
begin
  namco_06xx[io].fread[num]:=nil;
  namco_06xx[io].fwrite[num]:=nil;
  namco_06xx[io].fread_req[num]:=nil;
end;
procedure namco_50xx_chip(io,num,num50:byte);
begin
  case num50 of
    0:begin
        namco_06xx[io].fread[num]:=namcoio_50XX_read_0;
        namco_06xx[io].fwrite[num]:=namcoio_50XX_write_0;
        namco_06xx[io].fread_req[num]:=namcoio_50xx_read_req_0;
    end;
    1:begin
        namco_06xx[io].fread[num]:=namcoio_50XX_read_1;
        namco_06xx[io].fwrite[num]:=namcoio_50XX_write_1;
        namco_06xx[io].fread_req[num]:=namcoio_50xx_read_req_1;
    end;
  end;
end;
procedure namco_51xx_chip(io,num:byte);
begin
  namco_06xx[io].fread[num]:=namcoio_51XX_read;
  namco_06xx[io].fwrite[num]:=namcoio_51XX_write;
  namco_06xx[io].fread_req[num]:=nil;
end;
procedure namco_53xx_chip(io,num:byte);
begin
  namco_06xx[io].fread[num]:=namcoio_53xx_read;
  namco_06xx[io].fwrite[num]:=nil;
  namco_06xx[io].fread_req[num]:=namcoio_53xx_read_req;
end;
procedure namco_54xx_chip(io,num:byte);
begin
  namco_06xx[io].fread[num]:=nil;
  namco_06xx[io].fwrite[num]:=namcoio_54XX_write;
  namco_06xx[io].fread_req[num]:=nil;
end;
begin
  //Namco 06xx clock 48000Hz --> 200us --> 48000*0.0002 = 9.6
  //Z80 Clock 3072000
  // (3072000*9.6)/48000 = 614.4 --> No funciona?!?!? Con 768 Sip (250us) un 25% mas de tiempo...
  namco_06xx[num].nmi_timer:=timers.init(0,768,nmi_function,nil,false);
  case chip0 of
    IO50XX_0:namco_50xx_chip(num,0,0);  //50XX
    IO50XX_1:namco_50xx_chip(num,0,1);  //50XX
    IO51XX:namco_51xx_chip(num,0);  //51XX
    IO53XX:namco_53xx_chip(num,0); //53XX
    IO54XX:namco_54xx_chip(num,0); //54XX
  end;
  case chip1 of
    NONE:none_chip(num,1);
    IO50XX_0:namco_50xx_chip(num,1,0);  //50XX
    IO50XX_1:namco_50xx_chip(num,1,1);  //50XX
    IO51XX:namco_51xx_chip(num,1);  //51XX
    IO53XX:namco_53xx_chip(num,1);  //53XX
    IO54XX:namco_54xx_chip(num,1); //54XX
  end;
  case chip2 of
    NONE:none_chip(num,2);
    IO50XX_0:namco_50xx_chip(num,2,0);  //50XX
    IO50XX_1:namco_50xx_chip(num,2,1);  //50XX
    IO51XX:namco_51xx_chip(num,2);  //51XX
    IO53XX:namco_53xx_chip(num,2);  //53XX
    IO54XX:namco_54xx_chip(num,2); //54XX
  end;
  case chip3 of
    NONE:none_chip(num,3);
    IO50XX_0:namco_50xx_chip(num,3,0);  //50XX
    IO50XX_1:namco_50xx_chip(num,3,1);  //50XX
    IO51XX:namco_51xx_chip(num,3);  //51XX
    IO53XX:namco_53xx_chip(num,3);  //53XX
    IO54XX:namco_54xx_chip(num,3); //54XX
  end;
end;

function namco_06xx_data_r(dir,num:byte):byte;
var
  res:byte;
  f:byte;
begin
res:=$ff;
if (namco_06xx[num].control and $10)=0 then begin
    res:=0;
end else begin
  for f:=0 to 3 do begin
    if (((namco_06xx[num].control and (1 shl f))<>0) and (@namco_06xx[num].fread[f]<>nil)) then
        res:=res and namco_06xx[num].fread[f];
  end;
end;
namco_06xx_data_r:=res;
end;

procedure namco_06xx_data_w(dir,num,data:byte);
var
  f:byte;
begin
if (namco_06xx[num].control and $10)=0 then begin
  for f:=0 to 3 do begin
    if (((namco_06xx[num].control and (1 shl f))<>0) and (@namco_06xx[num].fwrite[f]<>nil)) then
        namco_06xx[num].fwrite[f](data);
  end;
end;
end;

function namco_06xx_ctrl_r(num:byte):byte;
begin
	namco_06xx_ctrl_r:=namco_06xx[num].control;
end;

procedure namco_06xx_ctrl_w(num,data:byte);
var
  f:byte;
begin
	namco_06xx[num].control:=data;
	if ((data and $0f)=0) then begin
    timers.enabled(namco_06xx[num].nmi_timer,false);
    exit;
  end;
  timers.enabled(namco_06xx[num].nmi_timer,true);
  //read request
  if (data and $10)<>0 then begin
			for f:=0 to 3 do
				if ((data and (1 shl f))<>0) then
          if @namco_06xx[num].fread_req[f]<>nil then namco_06xx[num].fread_req[f];
  end;
end;

end.
