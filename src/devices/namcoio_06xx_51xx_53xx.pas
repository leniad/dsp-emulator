unit namcoio_06xx_51xx_53xx;

interface
uses main_engine,timer_engine,mb88xx,rom_engine;

//Namco 06XX
procedure namco_06xx_init(num:byte;chip0,chip1,chip2,chip3:byte;nmi_function:exec_type);
procedure namcoio_06xx_reset(num:byte);
function namco_06xx_data_r(dir,num:byte):byte;
procedure namco_06xx_data_w(dir,num,data:byte);
function namco_06xx_ctrl_r(num:byte):byte;
procedure namco_06xx_ctrl_w(num,data:byte);
//51XX
procedure namcoio_51xx_reset;
//53XX
procedure namcoio_53xx_init(port_k:cpu_inport_call;port_r_r:type_mb88xx_inport_r;zip_name:string);
procedure namco_53xx_o_w(valor:byte);
procedure namcoio_53xx_reset;
procedure run_namco_53xx;
procedure namco_53xx_close;

type
  read_chip=function:byte;
  write_chip=procedure(data:byte);
  read_req_chip=procedure;
  tipo_51xx=record
  	mode,coincred_mode,credits,in_count,lastcoins,lastbuttons:byte;
    coins_per_cred,creds_per_coin,coins:array[0..1] of byte;
    remap_joy:boolean;
    read_port:array[0..3] of read_chip;
    write_port:array[0..1] of write_chip;
  end;
  tipo_53xx=record
    port_o:byte;
    timer:byte;
    frame:single;
  end;
  tipo_06xx=record
    control:byte;
    fread:array[0..3] of read_chip;
    fwrite:array[0..3] of write_chip;
    fread_req:array[0..3] of read_req_chip;
    nmi_timer:byte;
  end;

const
  NONE=0;
  IO51XX=1;
  IO53XX=2;
  namco_53xx_rom:tipo_roms=(n:'53xx.bin';l:$400;p:0;crc:$b326fecb);

var
  namco_06xx:array[0..1] of tipo_06xx;
  namco_51xx:tipo_51xx;
  namco_53xx:tipo_53xx;

implementation

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
			1:begin	// set coinage
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
			0:res:=namco_51xx.read_port[0] or (namco_51xx.read_port[1] shl 4);
			1:res:=namco_51xx.read_port[2] or (namco_51xx.read_port[3] shl 4);
			2:res:=0;	// nothing?
    end;
    namco_51xx.in_count:=(namco_51xx.in_count+1) and $3;
	end	else begin 	// credits mode
		case namco_51xx.in_count of
			0:begin	// number of credits in BCD format
					in_:=not(namco_51xx.read_port[0] or (namco_51xx.read_port[1] shl 4));
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
  				if (not(namco_51xx.read_port[1]) and $8)<>0 then begin //check test mode switch */
	  				namcoio_51XX_read:=$bb;
            exit;
          end;
			  	res:=(namco_51xx.credits div 10)*16+namco_51xx.credits mod 10;
        end;
			1:begin
					joy:=namco_51xx.read_port[2] and $0f;
					in_:=not(namco_51xx.read_port[0]);
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
					joy:=namco_51xx.read_port[3] and $0f;
					in_:=not(namco_51xx.read_port[0]);
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

procedure namcoio_51xx_reset;
begin
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
  main_mb88xx.Free;
end;

procedure run_namco_53xx;
begin
  main_mb88xx.run(namco_53xx.frame);
  namco_53xx.frame:=namco_53xx.frame+main_mb88xx.tframes-main_mb88xx.contador;
end;

procedure namcoio_53xx_irq_clear;
begin
	main_mb88xx.set_irq_line(CLEAR_LINE);
  timer[namco_53xx.timer].enabled:=false;
end;

procedure namcoio_53xx_read_req;
begin
  main_mb88xx.set_irq_line(ASSERT_LINE);
	// The execution time of one instruction is ~4us, so we must make sure to
	// give the cpu time to poll the /IRQ input before we clear it.
	// The input clock to the 06XX interface chip is 64H, that is
	// 18432000/6/64 = 48kHz, so it makes sense for the irq line to be
	// asserted for one clock cycle ~= 21us.
  timer[namco_53xx.timer].enabled:=true;
end;

function namcoio_53xx_read:byte;
var
  res:byte;
begin
  namcoio_53xx_read_req;
  res:=namco_53xx.port_o;
  namcoio_53xx_read:=res;
end;

procedure namcoio_53xx_init(port_k:cpu_inport_call;port_r_r:type_mb88xx_inport_r;zip_name:string);
begin
main_mb88xx:=cpu_mb88xx.Create(1536000,264);
main_mb88xx.change_io_calls(port_k,namco_53xx_o_w,nil,nil,port_r_r,nil);
namco_53xx.frame:=main_mb88xx.tframes;
//namco 53XX clock 1536000*0.000021=32.256
namco_53xx.timer:=init_timer(main_mb88xx.numero_cpu,32,namcoio_53xx_irq_clear,false);
//rom
if not(cargar_roms(main_mb88xx.get_rom_addr,@namco_53xx_rom,zip_name,1)) then exit;
end;

procedure namcoio_53xx_reset;
begin
  main_mb88xx.reset;
  namco_53xx.port_o:=0;
  timer[namco_53xx.timer].enabled:=false;
end;

procedure namco_53xx_o_w(valor:byte);
var
  res:byte;
begin
  res:=(valor and $0f);
	if (valor and $10)<>0 then namco_53xx.port_o:=(namco_53xx.port_o and $0f) or (res shl 4)
	  else namco_53xx.port_o:=(namco_53xx.port_o and $f0) or res;
end;

//Namco 06XX
procedure namcoio_06xx_reset(num:byte);
begin
  namco_06xx[num].control:=0;
  timer[namco_06xx[num].nmi_timer].enabled:=false;
end;

procedure namco_06xx_init(num:byte;chip0,chip1,chip2,chip3:byte;nmi_function:exec_type);
procedure none_chip(io,num:byte);
begin
  namco_06xx[io].fread[num]:=nil;
  namco_06xx[io].fwrite[num]:=nil;
  namco_06xx[io].fread_req[num]:=nil;
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
begin
  {Namco 06xx clock 48000Hz -> Z80 Clock 3072000*0.0002=614,4}
  namco_06xx[num].nmi_timer:=init_timer(0,614.4,nmi_function,false);
  case chip0 of
    IO51XX:namco_51xx_chip(num,0);  //51XX
    IO53XX:namco_53xx_chip(num,0); //53XX
  end;
  case chip1 of
    NONE:none_chip(num,1);
    IO51XX:namco_51xx_chip(num,1);  //51XX
    IO53XX:namco_53xx_chip(num,1);  //53XX
  end;
  case chip2 of
    NONE:none_chip(num,2);
    IO51XX:namco_51xx_chip(num,2);  //51XX
    IO53XX:namco_53xx_chip(num,2);  //53XX
  end;
  case chip3 of
    NONE:none_chip(num,3);
    IO51XX:namco_51xx_chip(num,3);  //51XX
    IO53XX:namco_53xx_chip(num,3);  //53XX
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
    timer[namco_06xx[num].nmi_timer].enabled:=false;
    exit;
  end;
  timer[namco_06xx[num].nmi_timer].enabled:=true;
  //read request
  if (data and $10)<>0 then begin
			for f:=0 to 3 do
				if ((data and (1 shl f))<>0) then
          if @namco_06xx[num].fread_req[f]<>nil then namco_06xx[num].fread_req[f];
  end;
end;

end.
