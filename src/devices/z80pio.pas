unit z80pio;

interface
uses z80daisy,misc_functions,cpu_misc,main_engine;

const
  PIO_PORT_A=0;
  PIO_PORT_B=1;

type
	tout_rdy_func=procedure(state:boolean);
  tout_int_func=procedure(state:byte);

  tipo_port=record
		mode:byte;					    // mode register
		next_control_word:byte;	// next control word
		input:byte;				      // input latch
		output:byte;				    // output latch
		ior:byte;				        // input/output register
		rdy:boolean;					  // ready
		stb:boolean;					  // strobe
		// interrupts
		ie:boolean;					    // interrupt enabled
		ip:boolean;					    // interrupt pending
		ius:boolean;					  // interrupt under service
		icw:byte;				        // interrupt control word
		vector:byte;				    // interrupt vector
		mask:byte;				      // interrupt mask
		match:boolean;				  // logic equation match
    in_p_func:cpu_inport_call;
		out_p_func:cpu_outport_call;
		out_rdy_func:tout_rdy_func;
  end;
  tz80pio=class
        constructor create;
        destructor free;
      public
        pio_port:array[0..1] of tipo_port;
        procedure reset;
        procedure change_calls(int_func:tout_int_func=nil;infunc_a:cpu_inport_call=nil;outfunc_a:cpu_outport_call=nil;rdyfunc_a:tout_rdy_func=nil;infunc_b:cpu_inport_call=nil;outfunc_b:cpu_outport_call=nil;rdyfunc_b:tout_rdy_func=nil);
        function cd_ba_r(offset:word):byte;
        function ba_cd_r(offset:word):byte;
        procedure cd_ba_w(offset:word;valor:byte);
        procedure ba_cd_w(offset:word;valor:byte);
        procedure astb_w(state:boolean);
        procedure bstb_w(state:boolean);
        function port_read(port:byte):byte;
      private
        out_int_func:tout_int_func;
        procedure reset_port(port:byte);
        procedure set_mode(port,mode:byte);
        procedure set_rdy(port:byte;state:boolean);
        procedure check_interrupts;
        function interrupt_signalled(port:byte):boolean;
        procedure strobe(port:byte;state:boolean);
        procedure trigger_interrupt(port:byte);
        function c_r:byte;
        procedure c_w(port,valor:byte);
        function d_r(port:byte):byte;
        procedure d_w(port,valor:byte);
        function irq_state:byte;
        function irq_ack:byte;
        procedure irq_reti;
  end;

var
    pio_0:tz80pio;
    function pio0_irq_state:byte;
    function pio0_irq_ack:byte;
    procedure pio0_irq_reti;

implementation

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

constructor tz80pio.create;
begin
end;

destructor tz80pio.free;
begin
end;

procedure tz80pio.reset_port(port:byte);
begin
  // set mode 1
	self.set_mode(port,MODE_INPUT);
	// reset interrupt enable flip-flops
	self.pio_port[port].icw:=self.pio_port[port].icw and not(ICW_ENABLE_INT);
	self.pio_port[port].ie:=false;
	self.pio_port[port].ip:=false;
  self.pio_port[port].ius:=false;
  self.pio_port[port].match:=false;
	// reset all bits of the data I/O register
  self.pio_port[port].ior:=0;
	// set all bits of the mask control register
  self.pio_port[port].mask:=$ff;
	// reset output register
  self.pio_port[port].output:=0;
	// clear ready line
	self.set_rdy(port,false);
  self.pio_port[port].next_control_word:=0;
  self.pio_port[port].input:=0;
  self.pio_port[port].vector:=0;
end;

procedure tz80pio.change_calls(int_func:tout_int_func=nil;infunc_a:cpu_inport_call=nil;outfunc_a:cpu_outport_call=nil;rdyfunc_a:tout_rdy_func=nil;infunc_b:cpu_inport_call=nil;outfunc_b:cpu_outport_call=nil;rdyfunc_b:tout_rdy_func=nil);
begin
  self.pio_port[PIO_PORT_A].in_p_func:=infunc_a;
  self.pio_port[PIO_PORT_A].out_p_func:=outfunc_a;
  self.pio_port[PIO_PORT_A].out_rdy_func:=rdyfunc_a;
  self.pio_port[PIO_PORT_B].in_p_func:=infunc_b;
  self.pio_port[PIO_PORT_B].out_p_func:=outfunc_b;
  self.pio_port[PIO_PORT_B].out_rdy_func:=rdyfunc_b;
  self.out_int_func:=int_func;
end;

procedure tz80pio.reset;
begin
  self.reset_port(PIO_PORT_A);
  self.reset_port(PIO_PORT_B);
end;

procedure tz80pio.set_mode(port,mode:byte);
begin
case mode of
	MODE_OUTPUT:begin
            		// enable data output
                if @self.pio_port[port].out_p_func<>nil then self.pio_port[port].out_p_func(self.pio_port[port].output);
            		// assert ready line
            		set_rdy(port,true);
            		// set mode register
            		self.pio_port[port].mode:=mode;
          		end;
	MODE_INPUT:begin
            		// set mode register
            		self.pio_port[port].mode:=mode;
              end;
	MODE_BIDIRECTIONAL:begin
                if (port=PIO_PORT_B) then begin
                  //CACA!!!
                end else begin
		              // set mode register
			            self.pio_port[port].mode:=mode;
                end;
              end;
	MODE_BIT_CONTROL:begin
		            if ((port=PIO_PORT_A) or (self.pio_port[PIO_PORT_A].mode<>MODE_BIDIRECTIONAL)) then begin
          			  // clear ready line
			            set_rdy(port,false);
		            end;
            		// disable interrupts until IOR is written
		            self.pio_port[port].ie:=false;
            		self.check_interrupts;
            		// set logic equation to false
            		self.pio_port[port].match:=false;
            		// next word is I/O register
            		self.pio_port[port].next_control_word:=IOR;
            		// set mode register
            		self.pio_port[port].mode:=mode;
              end;
  end;
end;

procedure tz80pio.set_rdy(port:byte;state:boolean);
begin
	if (self.pio_port[port].rdy<>state) then begin
  	self.pio_port[port].rdy:=state;
    if @self.pio_port[port].out_rdy_func<>nil then self.pio_port[port].out_rdy_func(state);
  end;
end;

procedure tz80pio.check_interrupts;
var
  state,f:byte;
begin
	state:=CLEAR_LINE;
	for f:=0 to 1 do if interrupt_signalled(f) then state:=ASSERT_LINE;
  if @self.out_int_func<>nil then self.out_int_func(state);
end;

function tz80pio.interrupt_signalled(port:byte):boolean;
var
    data,mask:byte;
    match:boolean;
begin
	if (self.pio_port[port].mode=MODE_BIT_CONTROL) then begin
		// fetch input data (ignore output lines)
		data:=(self.pio_port[port].input and self.pio_port[port].ior) or (self.pio_port[port].output and not(self.pio_port[port].ior));
		mask:=not(self.pio_port[port].mask);
		match:=false;
		data:=data and mask;
		if (((self.pio_port[port].icw and $60)=0) and (data<>mask)) then match:=true
  		else if (((self.pio_port[port].icw and $60)=$20) and (data<>0)) then match:=true
    		else if (((self.pio_port[port].icw and $60)=$40) and (data=0)) then match:=true
      		else if (((self.pio_port[port].icw and $60)=$60) and (data=mask)) then match:=true;
		if (not(self.pio_port[port].match) and match) then begin
			// trigger interrupt
			self.pio_port[port].ip:=true;
		end;
		self.pio_port[port].match:=match;
	end;
	interrupt_signalled:=(self.pio_port[port].ie and self.pio_port[port].ip and not(self.pio_port[port].ius));
end;

procedure tz80pio.strobe(port:byte;state:boolean);
begin
	if (self.pio_port[PIO_PORT_A].mode=MODE_BIDIRECTIONAL) then begin
		if (self.pio_port[port].rdy) then begin // port ready
			if (self.pio_port[port].stb and not(state)) then begin // falling edge
				if (port=PIO_PORT_A) then if @self.pio_port[port].out_p_func<>nil then self.pio_port[port].out_p_func(self.pio_port[port].output)
				  else if @self.pio_port[port].in_p_func<>nil then self.pio_port[PIO_PORT_A].input:=self.pio_port[port].in_p_func;
			end else begin
        if (not(self.pio_port[port].stb) and state) then begin // rising edge
				  self.trigger_interrupt(port);
				  // clear ready line
				  self.set_rdy(port,false);
			  end;
      end;
		end;
	end	else begin
		case self.pio_port[port].mode of
		  MODE_OUTPUT:begin
              			if (self.pio_port[port].rdy) then begin
              				if (not(self.pio_port[port].stb) and state) then begin // rising edge
              					self.trigger_interrupt(port);
              					// clear ready line
              					self.set_rdy(port,false);
				              end;
			              end;
                  end;
	   MODE_INPUT:begin
			            if not(state) then begin
            				// input port data
                    if @self.pio_port[port].in_p_func<>nil then self.pio_port[port].input:=self.pio_port[port].in_p_func;
                  end else begin
                    if (not(self.pio_port[port].stb) and state) then begin // rising edge
            				  self.trigger_interrupt(port);
              				// clear ready line
              				self.set_rdy(port,false);
                    end;
                  end;
                end;
  end;
end;
self.pio_port[port].stb:=state;
end;

procedure tz80pio.trigger_interrupt(port:byte);
begin
	self.pio_port[port].ip:=true;
	self.check_interrupts;
end;

function tz80pio.c_r:byte;
begin
  c_r:=(self.pio_port[PIO_PORT_A].icw and $c0) or (self.pio_port[PIO_PORT_B].icw shr 4);
end;

procedure tz80pio.c_w(port,valor:byte);
begin
  case (self.pio_port[port].next_control_word) of
	  ANY:begin
		      if not(BIT(valor,0)) then begin
      			// load interrupt vector
			      self.pio_port[port].vector:=valor;
			      // set interrupt enable
			      self.pio_port[port].icw:=self.pio_port[port].icw or ICW_ENABLE_INT;
			      self.pio_port[port].ie:=true;
			      self.check_interrupts;
		      end else begin
			      case (valor and $0f) of
              $f:self.set_mode(port,valor shr 6); // select operating mode
              $07:begin // set interrupt control word
				            self.pio_port[port].icw:=valor;
  				          if (self.pio_port[port].icw and ICW_MASK_FOLLOWS)<>0 then begin
            					// disable interrupts until mask is written
            					self.pio_port[port].ie:=false;
            					// reset pending interrupts
  					          self.pio_port[port].ip:=false;
  					          self.check_interrupts;
  					          // set logic equation to false
  					          self.pio_port[port].match:=false;
  					          // next word is mask control
  					          self.pio_port[port].next_control_word:=MASK;
  				          end;
                 end;
			        $03:begin // set interrupt enable flip-flop
                    self.pio_port[port].icw:=(valor and $80) or (self.pio_port[port].icw and $7f);
				            // set interrupt enable
            				self.pio_port[port].ie:=BIT(self.pio_port[port].icw,7);
            				self.check_interrupts;
                  end;
            end; //case data and $f
		      end; //del if
		    end; //ANY
	  IOR:begin // data direction register
		      self.pio_port[port].ior:=valor;
		      // set interrupt enable
      		self.pio_port[port].ie:=BIT(self.pio_port[port].icw, 7);
      		self.check_interrupts;
      		// next word is any
      		self.pio_port[port].next_control_word:=ANY;
		    end;
	  MASK:begin // interrupt mask
      		self.pio_port[port].mask:=valor;
      		// set interrupt enable
      		self.pio_port[port].ie:=BIT(self.pio_port[port].icw, 7);
      		self.check_interrupts;
      		// next word is any
      		self.pio_port[port].next_control_word:=ANY;
    		 end;
	end;
end;

function tz80pio.d_r(port:byte):byte;
var
	data:byte;
begin
  data:=0;
	case self.pio_port[port].mode of
	  MODE_OUTPUT:data:=self.pio_port[port].output;
	  MODE_INPUT:begin
              		if not(self.pio_port[port].stb) then begin
              			// input port data
              			if @self.pio_port[port].in_p_func<>nil then self.pio_port[port].input:=self.pio_port[port].in_p_func;
		              end;
		              data:=self.pio_port[port].input;
              		// clear ready line
		              self.set_rdy(port,false);
              		// assert ready line
		              self.set_rdy(port,true);
                end;
	  MODE_BIDIRECTIONAL:begin
                  data:=self.pio_port[port].input;
              		// clear ready line
		              self.set_rdy(PIO_PORT_B,false);
		              // assert ready line
		              self.set_rdy(PIO_PORT_B,true);
                end;
	  MODE_BIT_CONTROL:begin
                  // input port data
		              if @self.pio_port[port].in_p_func<>nil then self.pio_port[port].input:=self.pio_port[port].in_p_func;
                  data:=(self.pio_port[port].input and self.pio_port[port].ior) or (self.pio_port[port].output and (self.pio_port[port].ior xor $ff));
                end;
  end;
  d_r:=data;
end;

procedure tz80pio.d_w(port,valor:byte);
begin
	case (self.pio_port[port].mode) of
	  MODE_OUTPUT:begin
              		// clear ready line
               		self.set_rdy(port,false);
              		// latch output data
              		self.pio_port[port].output:=valor;
		              // output data to port
                  if @self.pio_port[port].out_p_func<>nil then self.pio_port[port].out_p_func(valor);
		              // assert ready line
		              self.set_rdy(port,true);
		            end;
	  MODE_INPUT:self.pio_port[port].output:=valor; // latch output data
	  MODE_BIDIRECTIONAL:begin
              		// clear ready line
		              self.set_rdy(port,false);
		              // latch output data
		              self.pio_port[port].output:=valor;
		              if not(self.pio_port[port].stb) then begin
              			// output data to port
                    if @self.pio_port[port].out_p_func<>nil then self.pio_port[port].out_p_func(valor);
                  end;
              		// assert ready line
              		self.set_rdy(port,true);
		            end;
	  MODE_BIT_CONTROL:begin
              		// latch output data
		              self.pio_port[port].output:=valor;
              		// output data to port
                  if @self.pio_port[port].out_p_func<>nil then self.pio_port[port].out_p_func(self.pio_port[port].ior or (self.pio_port[port].output and (self.pio_port[port].ior xor $ff)));
                end;
  end;
end;

function tz80pio.cd_ba_r(offset:word):byte;
var
  index:byte;
begin
  index:=bit_n(offset,0);
  if bit_n(offset,1)<>0 then cd_ba_r:=self.c_r
    else cd_ba_r:=self.d_r(index);
end;

function tz80pio.ba_cd_r(offset:word):byte;
var
  index:byte;
begin
  index:=bit_n(offset,1);
  if bit_n(offset,0)<>0 then ba_cd_r:=self.c_r
    else ba_cd_r:=self.d_r(index);
end;

procedure tz80pio.cd_ba_w(offset:word;valor:byte);
var
  index:byte;
begin
	index:=BIT_n(offset,0);
  if BIT_n(offset,1)<>0 then self.c_w(index,valor)
    else self.d_w(index,valor);
end;

procedure tz80pio.ba_cd_w(offset:word;valor:byte);
var
  index:byte;
begin
	index:=BIT_n(offset,1);
  if BIT_n(offset,0)<>0 then self.c_w(index,valor)
    else self.d_w(index,valor);
end;

procedure tz80pio.astb_w(state:boolean);
begin
  self.strobe(PIO_PORT_A,state);
end;

procedure tz80pio.bstb_w(state:boolean);
begin
  self.strobe(PIO_PORT_B,state);
end;

function tz80pio.port_read(port:byte):byte;
var
  data:byte;
begin
  port:=port and 1;
	data:=$ff;
	case self.pio_port[port].mode of
    MODE_OUTPUT:data:=self.pio_port[port].output;
	  MODE_BIDIRECTIONAL:if port=PIO_PORT_A then data:=self.pio_port[port].output;
	  MODE_BIT_CONTROL:data:=self.pio_port[port].ior or (self.pio_port[port].output and (self.pio_port[port].ior xor $ff));
  end;
	port_read:=data;
end;

//Daisy Chain
function tz80pio.irq_state:byte;
var
  state,f:byte;
begin
	state:=0;
	for f:=0 to 1 do begin
		if self.pio_port[f].ius then begin
        irq_state:=Z80_DAISY_IEO;
        exit;
    end else begin     			// interrupt pending
      if (self.pio_port[f].ie and self.pio_port[f].ip) then state:=Z80_DAISY_INT;
    end;
	end;
	irq_state:=state;
end;

function tz80pio.irq_ack:byte;
var
  f:byte;
begin
	for f:=0 to 1 do begin
		if (self.pio_port[f].ip) then begin
			// clear interrupt pending flag
			self.pio_port[f].ip:=false;
			// set interrupt under service flag
			self.pio_port[f].ius:=true;
			self.check_interrupts;
			irq_ack:=self.pio_port[f].vector;
      exit;
		end;
	end;
	irq_ack:=0;
end;

procedure tz80pio.irq_reti;
var
  f:byte;
begin
	for f:=0 to 1 do begin
		if self.pio_port[f].ius then begin
			// clear interrupt under service flag
			self.pio_port[f].ius:=false;
			self.check_interrupts;
			exit;
		end;
	end;
end;

function pio0_irq_state:byte;
begin
  pio0_irq_state:=pio_0.irq_state;
end;

function pio0_irq_ack:byte;
begin
  pio0_irq_ack:=pio_0.irq_ack;
end;

procedure pio0_irq_reti;
begin
  pio_0.irq_reti;
end;

end.
