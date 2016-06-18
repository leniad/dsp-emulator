unit z80pio;

interface
uses z80daisy,misc_functions,main_engine;

const
  MODE_OUTPUT=0;
  MODE_INPUT=1;
  MODE_BIDIRECTIONAL=2;
  MODE_BIT_CONTROL=3;

  ANY=0;
  IOR=1;
  MASK=2;

  ICW_ENABLE_INT=$80;
  ICW_AND_OR=$40;
  ICW_AND=$40;
  ICW_OR=$00;
  ICW_HIGH_LOW=$20;
  ICW_HIGH=$20;
  ICW_LOW=$00;
  ICW_MASK_FOLLOWS=$10;

  PORT_A=0;
  PORT_B=1;

type
  tm_in_p_func=function:byte;
  tm_out_p_func=procedure(valor:byte);
	tm_out_rdy_func=procedure(state:boolean);
  tm_out_int_func=procedure(state:byte);
  tipo_z80pio_port=record
		m_mode:integer;					// mode register
		m_next_control_word:integer;	// next control word
		m_input:byte;				// input latch
		m_output:byte;				// output latch
		m_ior:byte;				// input/output register
		m_rdy:boolean;					// ready
		m_stb:boolean;					// strobe
		// interrupts
		m_ie:boolean;					// interrupt enabled
		m_ip:boolean;					// interrupt pending
		m_ius:boolean;					// interrupt under service
		m_icw:byte;				// interrupt control word
		m_vector:byte;				// interrupt vector
		m_mask:byte;				// interrupt mask
		m_match:boolean;				// logic equation match
    m_in_p_func:tm_in_p_func;
		m_out_p_func:tm_out_p_func;
		m_out_rdy_func:tm_out_rdy_func;
  end;
  ptipo_z80pio_port=^tipo_z80pio_port;
  tipo_z80_pio=record
    m_port:array[0..1] of ptipo_z80pio_port;
    m_out_int_func:tm_out_int_func;
  end;
  ptipo_z80pio=^tipo_z80_pio;

var
    z80_pio:array[0..1] of ptipo_z80pio;
    procedure z80pio_init(num:byte;int_func:tm_out_int_func=nil;infunc_a:tm_in_p_func=nil;outfunc_a:tm_out_p_func=nil;rdyfunc_a:tm_out_rdy_func=nil;infunc_b:tm_in_p_func=nil;outfunc_b:tm_out_p_func=nil;rdyfunc_b:tm_out_rdy_func=nil);
    procedure z80pio_close(num:byte);
		procedure z80pio_reset(num:byte);
    function z80pio_c_r(num:byte):byte;
    procedure z80pio_c_w(num,port,valor:byte);
    function z80pio_d_r(num,port:byte):byte;
    procedure z80pio_d_w(num,port,valor:byte);
    function z80pio_cd_ba_r(num:byte;offset:word):byte;
    function z80pio_ba_cd_r(num:byte;offset:word):byte;
    procedure z80pio_cd_ba_w(num:byte;offset:word;valor:byte);
    procedure z80pio_ba_cd_w(num:byte;offset:word;valor:byte);
    procedure z80pio_astb_w(num:byte;state:boolean);
    procedure z80pio_bstb_w(num:byte;state:boolean);
    function z80pio_port_read(num,port:byte):byte;
    //Daisy
    function z80pio_irq_state(num:byte):byte;
    function z80pio_irq_ack(num:byte):byte;
    procedure z80pio_irq_reti(num:byte);

implementation

procedure z80pio_init(num:byte;int_func:tm_out_int_func;infunc_a:tm_in_p_func;outfunc_a:tm_out_p_func;rdyfunc_a:tm_out_rdy_func;infunc_b:tm_in_p_func;outfunc_b:tm_out_p_func;rdyfunc_b:tm_out_rdy_func);
var
  pio:ptipo_z80pio;
begin
  getmem(z80_pio[num],sizeof(tipo_z80_pio));
  pio:=z80_pio[num];
  getmem(pio.m_port[PORT_A],sizeof(tipo_z80pio_port));
  getmem(pio.m_port[PORT_B],sizeof(tipo_z80pio_port));
  pio.m_port[PORT_A].m_in_p_func:=infunc_a;
  pio.m_port[PORT_A].m_out_p_func:=outfunc_a;
  pio.m_port[PORT_A].m_out_rdy_func:=rdyfunc_a;
  pio.m_port[PORT_B].m_in_p_func:=infunc_b;
  pio.m_port[PORT_B].m_out_p_func:=outfunc_b;
  pio.m_port[PORT_B].m_out_rdy_func:=rdyfunc_b;
  pio.m_out_int_func:=int_func;
end;

procedure z80pio_close(num:byte);
begin
if z80_pio[num]<>nil then begin
  if z80_pio[num].m_port[PORT_A]<>nil then freemem(z80_pio[num].m_port[PORT_A]);
  if z80_pio[num].m_port[PORT_B]<>nil then freemem(z80_pio[num].m_port[PORT_B]);
  z80_pio[num].m_port[PORT_A]:=nil;
  z80_pio[num].m_port[PORT_B]:=nil;
  freemem(z80_pio[num]);
  z80_pio[num]:=nil;
end;
end;

procedure set_rdy(port:ptipo_z80pio_port;state:boolean);
begin
	if (port.m_rdy<>state) then begin
  	port.m_rdy:=state;
    if @port.m_out_rdy_func<>nil then port.m_out_rdy_func(state);
  end;
end;

function interrupt_signalled(port:ptipo_z80pio_port):boolean;
var
    data,mask:byte;
    match:boolean;
begin
	if (port.m_mode=MODE_BIT_CONTROL) then begin
		// fetch input data (ignore output lines)
		data:= (port.m_input and port.m_ior) or (port.m_output and not(port.m_ior));
		mask:=not(port.m_mask);
		match:=false;
		data:=data and mask;
		if (((port.m_icw and $60)=0) and (data<>mask)) then match:=true
  		else if (((port.m_icw and $60)=$20) and (data<>0)) then match:=true
    		else if (((port.m_icw and $60)=$40) and (data=0)) then match:=true
      		else if (((port.m_icw and $60)=$60) and (data=mask)) then match:=true;
		if (not(port.m_match) and match) then begin
			// trigger interrupt
			port.m_ip:=true;
		end;
		port.m_match:=match;
	end;
	interrupt_signalled:=(port.m_ie and port.m_ip and not(port.m_ius));
end;

procedure check_interrupts(pio:ptipo_z80pio);
var
  state,f:byte;
begin
	state:=CLEAR_LINE;
	for f:=0 to 1 do if interrupt_signalled(pio.m_port[f]) then state:=ASSERT_LINE;
  if @pio.m_out_int_func<>nil then pio.m_out_int_func(state);
end;

procedure set_mode(pio:ptipo_z80pio;port,mode:byte);
var
    pio_port:ptipo_z80pio_port;
begin
    pio_port:=pio.m_port[port];
case mode of
	MODE_OUTPUT:begin
            		// enable data output
                if @pio_port.m_out_p_func<>nil then pio_port.m_out_p_func(pio_port.m_output);
            		// assert ready line
            		set_rdy(pio_port,true);
            		// set mode register
            		pio_port.m_mode:=mode;
          		end;
	MODE_INPUT:begin
            		// set mode register
            		pio_port.m_mode:=mode;
              end;
	MODE_BIDIRECTIONAL:begin
                if (port=PORT_B) then begin
                  //CACA!!!
                end else begin
		              // set mode register
			            pio_port.m_mode:=mode;
                end;
              end;
	MODE_BIT_CONTROL:begin
		            if ((port=PORT_A) or (pio.m_port[PORT_A].m_mode<>MODE_BIDIRECTIONAL)) then begin
          			  // clear ready line
			            set_rdy(pio_port,false);
		            end;
            		// disable interrupts until IOR is written
		            pio_port.m_ie:=false;
            		check_interrupts(pio);
            		// set logic equation to false
            		pio_port.m_match:=false;
            		// next word is I/O register
            		pio_port.m_next_control_word:=IOR;
            		// set mode register
            		pio_port.m_mode:=mode;
              end;
  end;
end;

procedure reset_port(pio:ptipo_z80pio;port:byte);
var
  pio_port:ptipo_z80pio_port;
begin
  pio_port:=pio.m_port[port];
  // set mode 1
	set_mode(pio,port,MODE_INPUT);
	// reset interrupt enable flip-flops
	pio_port.m_icw:=pio_port.m_icw and not(ICW_ENABLE_INT);
	pio_port.m_ie:=false;
	pio_port.m_ip:=false;
  pio_port.m_ius:=false;
  pio_port.m_match:=false;
	// reset all bits of the data I/O register
  pio_port.m_ior:=0;
	// set all bits of the mask control register
  pio_port.m_mask:=$ff;
	// reset output register
  pio_port.m_output:=0;
	// clear ready line
	set_rdy(pio_port,false);
  pio_port.m_next_control_word:=0;
  pio_port.m_input:=0;
  pio_port.m_vector:=0;
end;

procedure z80pio_reset(num:byte);
begin
  reset_port(z80_pio[num],PORT_A);
  reset_port(z80_pio[num],PORT_B);
end;

function control_read(pio:ptipo_z80pio):byte;
begin
	control_read:=(pio.m_port[PORT_A].m_icw and $c0) or (pio.m_port[PORT_B].m_icw shr 4);
end;

function z80pio_c_r(num:byte):byte;
begin
  z80pio_c_r:=control_read(z80_pio[num]);
end;

function data_read(pio:ptipo_z80pio;pio_port:ptipo_z80pio_port):byte;
var
	data:byte;
begin
  data:=0;
	case pio_port.m_mode of
	  MODE_OUTPUT:data:=pio_port.m_output;
	  MODE_INPUT:begin
              		if not(pio_port.m_stb) then begin
              			// input port data
              			if @pio_port.m_in_p_func<>nil then pio_port.m_input:=pio_port.m_in_p_func;
		              end;
		              data:=pio_port.m_input;
              		// clear ready line
		              set_rdy(pio_port,false);
              		// assert ready line
		              set_rdy(pio_port,true);
                end;
	  MODE_BIDIRECTIONAL:begin
                  data:=pio_port.m_input;
              		// clear ready line
		              set_rdy(pio.m_port[PORT_B],false);
		              // assert ready line
		              set_rdy(pio.m_port[PORT_B],true);
                end;
	  MODE_BIT_CONTROL:begin
                  // input port data
		              if @pio_port.m_in_p_func<>nil then pio_port.m_input:=pio_port.m_in_p_func;
                  data:=(pio_port.m_input and pio_port.m_ior) or (pio_port.m_output and (pio_port.m_ior xor $ff));
                end;
  end;
  data_read:=data;
end;

function z80pio_d_r(num,port:byte):byte;
begin
  z80pio_d_r:=data_read(z80_pio[num],z80_pio[num].m_port[port]);
end;

function z80pio_cd_ba_r(num:byte;offset:word):byte;
var
  index:byte;
begin
  index:=bit_n(offset,0);
  if bit_n(offset,1)<>0 then z80pio_cd_ba_r:=z80pio_c_r(num)
    else z80pio_cd_ba_r:=z80pio_d_r(num,index);
end;

function z80pio_ba_cd_r(num:byte;offset:word):byte;
var
  index:byte;
begin
  index:=bit_n(offset,1);
  if bit_n(offset,0)<>0 then z80pio_ba_cd_r:=z80pio_c_r(num)
    else z80pio_ba_cd_r:=z80pio_d_r(num,index);
end;

procedure control_write(pio:ptipo_z80pio;port,data:byte);
var
  pio_port:ptipo_z80pio_port;
begin
  pio_port:=pio.m_port[port];
  case (pio_port.m_next_control_word) of
	  ANY:begin
		      if not(BIT(data, 0)) then begin
      			// load interrupt vector
			      pio_port.m_vector:=data;
			      // set interrupt enable
			      pio_port.m_icw:=pio_port.m_icw or ICW_ENABLE_INT;
			      pio_port.m_ie:=true;
			      check_interrupts(pio);
		      end else begin
			      case (data and $0f) of
              $f:set_mode(pio,port,data shr 6); // select operating mode
              $07:begin // set interrupt control word
				            pio_port.m_icw:=data;
  				          if (pio_port.m_icw and ICW_MASK_FOLLOWS)<>0 then begin
            					// disable interrupts until mask is written
            					pio_port.m_ie:=false;
            					// reset pending interrupts
  					          pio_port.m_ip:=false;
  					          check_interrupts(pio);
  					          // set logic equation to false
  					          pio_port.m_match:=false;
  					          // next word is mask control
  					          pio_port.m_next_control_word:=MASK;
  				          end;
                 end;
			        $03:begin // set interrupt enable flip-flop
                    pio_port.m_icw:=(data and $80) or (pio_port.m_icw and $7f);
				            // set interrupt enable
            				pio_port.m_ie:=BIT(pio_port.m_icw,7);
            				check_interrupts(pio);
                  end;
            end; //case data and $f
		      end; //del if
		    end; //ANY
	  IOR:begin // data direction register
		      pio_port.m_ior:=data;
		      // set interrupt enable
      		pio_port.m_ie:=BIT(pio_port.m_icw, 7);
      		check_interrupts(pio);
      		// next word is any
      		pio_port.m_next_control_word:=ANY;
		    end;
	  MASK:begin // interrupt mask
      		pio_port.m_mask:=data;
      		// set interrupt enable
      		pio_port.m_ie:=BIT(pio_port.m_icw, 7);
      		check_interrupts(pio);
      		// next word is any
      		pio_port.m_next_control_word:=ANY;
    		 end;
	end;
end;

procedure z80pio_c_w(num,port,valor:byte);
begin
  control_write(z80_pio[num],port,valor);
end;

procedure data_write(pio_port:ptipo_z80pio_port;data:byte);
begin
	case (pio_port.m_mode) of
	  MODE_OUTPUT:begin
              		// clear ready line
               		set_rdy(pio_port,false);
              		// latch output data
              		pio_port.m_output:=data;
		              // output data to port
                  if @pio_port.m_out_p_func<>nil then pio_port.m_out_p_func(data);
		              // assert ready line
		              set_rdy(pio_port,true);
		            end;
	  MODE_INPUT:pio_port.m_output:=data; // latch output data
	  MODE_BIDIRECTIONAL:begin
              		// clear ready line
		              set_rdy(pio_port,false);
		              // latch output data
		              pio_port.m_output:=data;
		              if not(pio_port.m_stb) then begin
              			// output data to port
                    if @pio_port.m_out_p_func<>nil then pio_port.m_out_p_func(data);
                  end;
              		// assert ready line
              		set_rdy(pio_port,true);
		            end;
	  MODE_BIT_CONTROL:begin
              		// latch output data
		              pio_port.m_output:=data;
              		// output data to port
                  if @pio_port.m_out_p_func<>nil then pio_port.m_out_p_func(pio_port.m_ior or (pio_port.m_output and (pio_port.m_ior xor $ff)));
                end;
  end;
end;

procedure z80pio_d_w(num,port,valor:byte);
begin
  data_write(z80_pio[num].m_port[port],valor);
end;

procedure z80pio_cd_ba_w(num:byte;offset:word;valor:byte);
var
  index:byte;
begin
	index:=BIT_n(offset,0);
  if BIT_n(offset,1)<>0 then z80pio_c_w(num,index,valor)
    else z80pio_d_w(num,index,valor);
end;

procedure z80pio_ba_cd_w(num:byte;offset:word;valor:byte);
var
  index:byte;
begin
	index:=BIT_n(offset,1);
  if BIT_n(offset,0)<>0 then z80pio_c_w(num,index,valor)
    else z80pio_d_w(num,index,valor);
end;

procedure trigger_interrupt(pio:ptipo_z80pio;port:byte);
begin
	pio.m_port[port].m_ip:=true;
	check_interrupts(pio);
end;

procedure z80pio_strobe(num,port:byte;state:boolean);
var
  pio:ptipo_z80pio;
  pio_port:ptipo_z80pio_port;
begin
  pio:=z80_pio[num];
  pio_port:=pio.m_port[port];
	if (pio.m_port[PORT_A].m_mode=MODE_BIDIRECTIONAL) then begin
		if (pio_port.m_rdy) then begin // port ready
			if (pio_port.m_stb and not(state)) then begin // falling edge
				if (port=PORT_A) then if @pio_port.m_out_p_func<>nil then pio_port.m_out_p_func(pio_port.m_output)
				  else if @pio_port.m_in_p_func<>nil then pio.m_port[PORT_A].m_input:=pio_port.m_in_p_func;
			end else begin
        if (not(pio_port.m_stb) and state) then begin // rising edge
				  trigger_interrupt(pio,port);
				  // clear ready line
				  set_rdy(pio_port,false);
			  end;
      end;
		end;
	end	else begin
		case pio_port.m_mode of
		  MODE_OUTPUT:begin
              			if (pio_port.m_rdy) then begin
              				if (not(pio_port.m_stb) and state) then begin // rising edge
              					trigger_interrupt(pio,port);
              					// clear ready line
              					set_rdy(pio_port,false);
				              end;
			              end;
                  end;
	   MODE_INPUT:begin
			            if not(state) then begin
            				// input port data
                    if @pio_port.m_in_p_func<>nil then pio_port.m_input:=pio_port.m_in_p_func;
                  end else begin
                    if (not(pio_port.m_stb) and state) then begin // rising edge
            				  trigger_interrupt(pio,port);
              				// clear ready line
              				set_rdy(pio_port,false);
                    end;
                  end;
                end;
  end;
end;
pio_port.m_stb:=state;
end;

procedure z80pio_astb_w(num:byte;state:boolean);
begin
  z80pio_strobe(num,PORT_A,state);
end;

procedure z80pio_bstb_w(num:byte;state:boolean);
begin
  z80pio_strobe(num,PORT_B,state);
end;

function read(pio:ptipo_z80pio;port:byte):byte;
var
  data:byte;
  pio_port:ptipo_z80pio_port;
begin
  pio_port:=pio.m_port[port];
	data:=$ff;
	case pio_port.m_mode of
    MODE_OUTPUT:data:=pio_port.m_output;
	  MODE_BIDIRECTIONAL:if port=PORT_A then data:=pio_port.m_output;
	  MODE_BIT_CONTROL:data:=pio_port.m_ior or (pio_port.m_output and (pio_port.m_ior xor $ff));
  end;
	read:=data;
end;

function z80pio_port_read(num,port:byte):byte;
begin
 z80pio_port_read:=read(z80_pio[num],port and 1);
end;

//Daisy Chain
function z80pio_irq_state(num:byte):byte;
var
  state,f:byte;
  pio_port:ptipo_z80pio_port;
begin
	state:=0;
	for f:=0 to 1 do begin
    pio_port:=z80_pio[num].m_port[f];
		if pio_port.m_ius then begin
        z80pio_irq_state:=Z80_DAISY_IEO;
        exit;
    end else begin     			// interrupt pending
      if (pio_port.m_ie and pio_port.m_ip) then state:=Z80_DAISY_INT;
    end;
	end;
	z80pio_irq_state:=state;
end;

function z80pio_irq_ack(num:byte):byte;
var
  f:byte;
  pio_port:ptipo_z80pio_port;
begin
	for f:=0 to 1 do begin
    pio_port:=z80_pio[num].m_port[f];
		if (pio_port.m_ip) then begin
			// clear interrupt pending flag
			pio_port.m_ip:=false;
			// set interrupt under service flag
			pio_port.m_ius:=true;
			check_interrupts(z80_pio[num]);
			z80pio_irq_ack:=pio_port.m_vector;
      exit;
		end;
	end;
	z80pio_irq_ack:=0;
end;

procedure z80pio_irq_reti(num:byte);
var
  f:byte;
  pio_port:ptipo_z80pio_port;
begin
	for f:=0 to 1 do begin
    pio_port:=z80_pio[num].m_port[f];
		if pio_port.m_ius then begin
			// clear interrupt under service flag
			pio_port.m_ius:=false;
			check_interrupts(z80_pio[num]);
			exit;
		end;
	end;
end;

end.
