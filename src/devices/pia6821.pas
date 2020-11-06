unit pia6821;

interface

type
in_handler=function:byte;
out_handler=procedure(valor:byte);
irq_handler=procedure(state:boolean);
pia6821_chip=class
      constructor Create;
      destructor free;
    public
      irq_a_state,irq_b_state:boolean;
      procedure reset;
      function read(dir:byte):byte;
      procedure write(dir,valor:byte);
      procedure change_in_out(in_a,in_b:in_handler;out_a,out_b:out_handler);
      procedure change_irq(irq_a,irq_b:irq_handler);
      procedure ca1_w(state:boolean);
      procedure cb1_w(state:boolean);
      procedure portb_w(valor:byte);
    private
      ctl_a,ctl_b,ddr_a,ddr_b,in_a,in_b,port_a_z_mask,out_a,out_b:byte;
      logged_ca1_not_connected,in_ca1_pushed,logged_ca2_not_connected,in_ca2_pushed,in_ca1,in_ca2,irq_a1,irq_a2,irq_b1,irq_b2:boolean;
      out_ca2,out_cb2,out_ca2_needs_pulled,in_a_pushed,in_b_pushed,logged_port_a_not_connected,logged_port_b_not_connected:boolean;
      out_cb2_needs_pulled,last_out_cb2_z,out_a_needs_pulled,out_b_needs_pulled:boolean;
      logged_cb1_not_connected,logged_cb2_not_connected,in_cb1_pushed,in_cb2_pushed,in_cb1:boolean;
      in_ca1_handler:function:boolean;
      in_ca2_handler:function:boolean;
      in_cb1_handler:function:boolean;
      ca2_handler:procedure(ca2_out:boolean);
      cb2_handler:procedure(cb2_out:boolean);
      irqa_handler:irq_handler;
      irqb_handler:irq_handler;
      in_a_handler:in_handler;
      in_b_handler:in_handler;
      out_a_handler:out_handler;
      out_b_handler:out_handler;
      function ddr_a_r:byte;
      function ddr_b_r:byte;
      function control_a_r:byte;
      procedure ca2_w(state:boolean);
      procedure update_interrupts;
      procedure set_out_ca2(data:boolean);
      procedure set_out_cb2(data:boolean);
      function port_a_r:byte;
      function get_in_a_value:byte;
      function port_b_r:byte;
      function get_in_b_value:byte;
      function cb2_output_z:boolean;
      function control_b_r:byte;
      procedure port_a_w(valor:byte);
      procedure ddr_a_w(valor:byte);
      procedure control_a_w(valor:byte);
      procedure port_b_w(valor:byte);
      procedure send_to_out_a_func;
      procedure send_to_out_b_func;
      function get_out_a_value:byte;
      function get_out_b_value:byte;
      procedure ddr_b_w(valor:byte);
      procedure control_b_w(valor:byte);
  end;
var
  pia6821_0,pia6821_1,pia6821_2:pia6821_chip;

implementation
const
  PIA_IRQ1=$80;
  PIA_IRQ2=$40;

function irq1_enabled(c:byte):boolean;    begin irq1_enabled:=((c shr 0) and 1)<>0; end;
function c1_low_to_high(c:byte):boolean;  begin c1_low_to_high:=((c shr 1) and 1)<>0; end;
function c1_high_to_low(c:byte):boolean;  begin c1_high_to_low:=((c shr 1) and 1)=0; end;
function output_selected(c:byte):boolean; begin output_selected:=((c shr 2) and 1)<>0; end;
function irq2_enabled(c:byte):boolean;    begin irq2_enabled:=((c shr 3) and 1)<>0; end;
function strobe_e_reset(c:byte):boolean;  begin strobe_e_reset:=((c shr 3) and 1)<>0; end;
function strobe_c1_reset(c:byte):boolean; begin strobe_c1_reset:=((c shr 3) and 1)=0; end;
function c2_set(c:byte):boolean;          begin c2_set:=((c shr 3) and 1)<>0; end;
function c2_low_to_high(c:byte):boolean;  begin c2_low_to_high:=((c shr 4) and 1)<>0; end;
function c2_high_to_low(c:byte):boolean;  begin c2_high_to_low:=((c shr 4) and 1)=0; end;
function c2_set_mode(c:byte):boolean;     begin c2_set_mode:=((c shr 4) and 1)<>0; end;
function c2_strobe_mode(c:byte):boolean;  begin c2_strobe_mode:=((c shr 4) and 1)=0; end;
function c2_output(c:byte):boolean;       begin c2_output:=((c shr 5) and 1)<>0; end;
function c2_input(c:byte):boolean;        begin c2_input:=((c shr 5) and 1)=0; end;

constructor pia6821_chip.Create;
begin
  self.in_ca1_handler:=nil;
  self.in_ca2_handler:=nil;
  self.in_cb1_handler:=nil;
  self.cb2_handler:=nil;
  self.irqa_handler:=nil;
  self.irqb_handler:=nil;
  self.in_a_handler:=nil;
  self.in_b_handler:=nil;
  self.out_a_handler:=nil;
  self.out_b_handler:=nil;
end;

destructor pia6821_chip.free;
begin
end;

procedure pia6821_chip.change_in_out(in_a,in_b:in_handler;out_a,out_b:out_handler);
begin
  self.in_a_handler:=in_a;
  self.in_b_handler:=in_b;
  self.out_a_handler:=out_a;
  self.out_b_handler:=out_b;
end;

procedure pia6821_chip.change_irq(irq_a,irq_b:irq_handler);
begin
  self.irqa_handler:=irq_a;
  self.irqb_handler:=irq_b;
end;

procedure pia6821_chip.reset;
begin
  self.logged_ca1_not_connected:=false;
  self.in_ca1_pushed:=false;
  self.logged_ca2_not_connected:=false;
  self.in_ca2_pushed:=false;
  self.ctl_a:=0;
  self.ctl_b:=0;
  self.ddr_a:=0;
  self.ddr_b:=0;
  self.irq_a1:=false;
  self.irq_a2:=false;
  self.irq_b1:=false;
  self.irq_b2:=false;
  self.irq_a_state:=false;
  self.irq_b_state:=false;
  self.in_ca1:=true;
  self.in_ca2:=true;
  self.out_ca2:=false;
  self.out_cb2:=false;
  self.out_ca2_needs_pulled:=false;
  self.out_cb2_needs_pulled:=false;
  self.in_a_pushed:=false;
  self.in_b_pushed:=false;
  self.in_a:=$ff;
  self.in_b:=0;
  self.out_a:=0;
  self.out_b:=0;
  self.port_a_z_mask:=0;
  self.logged_port_a_not_connected:=false;
  self.logged_port_b_not_connected:=false;
  self.last_out_cb2_z:=false;
  self.logged_cb1_not_connected:=false;
  self.logged_cb2_not_connected:=false;
  self.in_cb1_pushed:=false;
  self.in_cb2_pushed:=false;
  self.in_cb1:=false;
  self.out_a_needs_pulled:=false;
  self.out_b_needs_pulled:=false;
  if addr(self.irqa_handler)<>nil then self.irqa_handler(false);
  if addr(self.irqb_handler)<>nil then self.irqb_handler(false);
end;

function pia6821_chip.ddr_a_r:byte;
begin
	ddr_a_r:=self.ddr_a;
end;

function pia6821_chip.ddr_b_r:byte;
begin
	ddr_b_r:=self.ddr_b;
end;

procedure pia6821_chip.update_interrupts;
var
  new_state:boolean;
begin
	// start with IRQ A
	new_state:=(self.irq_a1 and irq1_enabled(self.ctl_a)) or (self.irq_a2 and irq2_enabled(self.ctl_a));
	if (new_state<>self.irq_a_state) then begin
		self.irq_a_state:=new_state;
		if (addr(irqa_handler)<>nil) then irqa_handler(self.irq_a_state);
	end;
	// then do IRQ B
	new_state:=(self.irq_b1 and irq1_enabled(self.ctl_b)) or (self.irq_b2 and irq2_enabled(self.ctl_b));
	if (new_state<>self.irq_b_state) then begin
		self.irq_b_state:=new_state;
		if (addr(irqb_handler)<>nil) then self.irqb_handler(self.irq_b_state);
	end;
end;

procedure pia6821_chip.set_out_ca2(data:boolean);
begin
  if (data<>self.out_ca2) then begin
     self.out_ca2:=data;
     // send to output function
     if (addr(self.ca2_handler)<>nil) then self.ca2_handler(self.out_ca2)
        else self.out_ca2_needs_pulled:=true;
  end;
end;

procedure pia6821_chip.ca1_w(state:boolean);
begin
	// the new state has caused a transition
	if ((self.in_ca1<>state) and ((state and c1_low_to_high(self.ctl_a)) or (not(state) and c1_high_to_low(self.ctl_a)))) then begin
		// mark the IRQ
		self.irq_a1:=true;
		// update externals
		update_interrupts;
		// CA2 is configured as output and in read strobe mode and cleared by a CA1 transition
		if(c2_output(self.ctl_a) and c2_strobe_mode(self.ctl_a) and strobe_c1_reset(self.ctl_a)) then set_out_ca2(true);
	end;
	// set the new value for CA1
	self.in_ca1:=state;
	self.in_ca1_pushed:=true;
end;

procedure pia6821_chip.ca2_w(state:boolean);
begin
	// if input mode and the new state has caused a transition
	if(c2_input(self.ctl_a) and (self.in_ca2<>state) and ((state and c2_low_to_high(self.ctl_a)) or (not(state) and c2_high_to_low(self.ctl_a)))) then begin
		// mark the IRQ
		self.irq_a2:=true;
		// update externals
		update_interrupts;
	end;
	// set the new value for CA2
	self.in_ca2:=state;
	self.in_ca2_pushed:=true;
end;

function pia6821_chip.control_a_r:byte;
var
	ret:byte;
begin
  // update CA1 & CA2 if callback exists, these in turn may update IRQ's
  if (addr(self.in_ca1_handler)<>nil) then begin
    ca1_w(self.in_ca1_handler);
  end else if(not(logged_ca1_not_connected) and not(in_ca1_pushed)) then begin
      self.logged_ca1_not_connected:=true;
  end;
  if (addr(in_ca2_handler)<>nil) then begin
     ca2_w(in_ca2_handler);
  end else if (not(self.logged_ca2_not_connected) and c2_input(ctl_a) and not(in_ca2_pushed)) then begin
      self.logged_ca2_not_connected:=true;
  end;
  // read control register
  ret:=ctl_a;
  // set the IRQ flags if we have pending IRQs
  if irq_a1 then ret:=ret or PIA_IRQ1;
  if (irq_a2 and c2_input(ctl_a)) then ret:=ret or PIA_IRQ2;
  control_a_r:=ret;
end;

function pia6821_chip.get_in_a_value:byte;
var
  port_a_data,ret:byte;
begin
	port_a_data:=0;
	// update the input
	if (addr(in_a_handler)<>nil) then begin
		port_a_data:=self.in_a_handler;
	end else begin
		if (self.in_a_pushed) then begin
			port_a_data:=self.in_a;
		end else begin
			// mark all pins disconnected
			self.port_a_z_mask:=$ff;
			if (not(self.logged_port_a_not_connected) and (self.ddr_a<>$ff)) then self.logged_port_a_not_connected:=true;
		end;
        end;
	// - connected pins are always read
	// - disconnected pins read the output buffer in output mode
	// - disconnected pins are HI in input mode
	ret:=(not(self.port_a_z_mask) and port_a_data) or
	     (self.port_a_z_mask and self.ddr_a and self.out_a) or
	     (self.port_a_z_mask and not(self.ddr_a));
	get_in_a_value:=ret;
end;

function pia6821_chip.port_a_r:byte;
var
  ret:byte;
begin
  ret:=self.get_in_a_value;
	// IRQ flags implicitly cleared by a read
	self.irq_a1:=false;
	self.irq_a2:=false;
	self.update_interrupts;
	// CA2 is configured as output and in read strobe mode
	if (c2_output(self.ctl_a) and c2_strobe_mode(self.ctl_a)) then begin
		// this will cause a transition low
		set_out_ca2(false);
		// if the CA2 strobe is cleared by the E, reset it right away
		if (strobe_e_reset(self.ctl_a)) then set_out_ca2(true);
	end;
	port_a_r:=ret;
end;

function pia6821_chip.get_in_b_value:byte;
var
	port_b_data,ret:byte;
begin
  // all output, just return buffer
  if (self.ddr_b=$ff) then begin
    ret:=self.out_b;
  end else begin
		// update the input
		if (addr(in_b_handler)<>nil) then begin
			port_b_data:=self.in_b_handler;
		end else begin
			if (self.in_b_pushed) then begin
				port_b_data:=self.in_b;
			end else begin
				if (not(self.logged_port_b_not_connected) and (self.ddr_b<>$ff)) then self.logged_port_b_not_connected:=true;
				// undefined -- need to return something
				port_b_data:=$00;
			end;
		end;
		// the DDR determines if the pin or the output buffer is read
		ret:= (self.out_b and self.ddr_b) or (port_b_data and not(self.ddr_b));
	end;
  get_in_b_value:=ret;
end;

function pia6821_chip.cb2_output_z:boolean;
begin
	cb2_output_z:=c2_output(self.ctl_b);
end;

procedure pia6821_chip.set_out_cb2(data:boolean);
var
  z:boolean;
begin
	z:=cb2_output_z;
	if ((data<>self.out_cb2) or (z<>self.last_out_cb2_z)) then begin
		self.out_cb2:=data;
		self.last_out_cb2_z:=z;
		// send to output function
		if (addr(self.cb2_handler)<>nil) then self.cb2_handler(self.out_cb2)
		  else self.out_cb2_needs_pulled:=true;
	end;
end;

function pia6821_chip.port_b_r:byte;
var
  ret:byte;
begin
	ret:=self.get_in_b_value;
	// This read will implicitly clear the IRQ B1 flag.  If CB2 is in write-strobe
	// mode with CB1 restore, and a CB1 active transition set the flag,
	// clearing it will cause CB2 to go high again.  Note that this is different
	// from what happens with port A.
	if(self.irq_b1 and c2_strobe_mode(self.ctl_b) and strobe_c1_reset(self.ctl_b)) then set_out_cb2(true);
	// IRQ flags implicitly cleared by a read
	self.irq_b1:=false;
	self.irq_b2:=false;
	self.update_interrupts;
	port_b_r:=ret;
end;

procedure pia6821_chip.cb1_w(state:boolean);
begin
	// the new state has caused a transition
 	if ((self.in_cb1<>state) and ((state and c1_low_to_high(self.ctl_b)) or (not(state) and c1_high_to_low(self.ctl_b)))) then begin
		// mark the IRQ
		self.irq_b1:=true;
		// update externals
		self.update_interrupts;
		// If CB2 is configured as a write-strobe output which is reset by a CB1
		// transition, this reset will only happen when a read from port B implicitly
		// clears the IRQ B1 flag.  So we handle the CB2 reset there.  Note that this
		// is different from what happens with port A.
	end;
	// set the new value for CB1
	self.in_cb1:=state;
	self.in_cb1_pushed:=true;
end;

function pia6821_chip.control_b_r:byte;
var
  ret:byte;
begin
	// update CB1 & CB2 if callback exists, these in turn may update IRQ's
	if (addr(self.in_cb1_handler)<>nil) then begin
		cb1_w(in_cb1_handler);
	end else if (not(self.logged_cb1_not_connected) and not(in_cb1_pushed)) then begin
		self.logged_cb1_not_connected:=true;
	end;
	if(not(logged_cb2_not_connected) and c2_input(self.ctl_b) and not(in_cb2_pushed)) then begin
		self.logged_cb2_not_connected:=true;
	end;
	// read control register
	ret:=self.ctl_b;
	// set the IRQ flags if we have pending IRQs
	if(self.irq_b1) then ret:=ret or PIA_IRQ1;
	if(self.irq_b2 and c2_input(self.ctl_b)) then ret:=ret or PIA_IRQ2;
	control_b_r:=ret;
end;

function pia6821_chip.read(dir:byte):byte;
var
	ret:byte;
begin
	case (dir and $03) of
		$00:if (output_selected(ctl_a)) then ret:=port_a_r
			      else ret:=ddr_a_r;
		$01:ret:=control_a_r;
		$02:if (output_selected(ctl_b)) then ret:=port_b_r
			      else ret:=ddr_b_r;
	  $03:ret:=control_b_r;
  end;
read:=ret;
end;

procedure pia6821_chip.port_a_w(valor:byte);
begin
	// buffer the output value
	self.out_a:=valor;
        self.send_to_out_a_func;
end;

function pia6821_chip.get_out_a_value:byte;
var
   ret:byte;
begin
     if (self.ddr_a=$ff) then // all output
        ret:=self.out_a
     else // input pins don't change
        ret:=(self.out_a and self.ddr_a) or (self.get_in_a_value and not(self.ddr_a));
     get_out_a_value:=ret;
end;

procedure pia6821_chip.send_to_out_a_func;
var
   data:byte;
begin
     // input pins are pulled high
     data:=self.get_out_a_value;
     if (addr(self.out_a_handler)<>nil) then self.out_a_handler(data)
        else self.out_a_needs_pulled:=true;
end;

procedure pia6821_chip.ddr_a_w(valor:byte);
begin
	if (self.ddr_a<>valor) then begin
		// DDR changed, call the callback again
		self.ddr_a:=valor;
		self.logged_port_a_not_connected:=false;
                self.send_to_out_a_func;
	end;
end;

procedure pia6821_chip.control_a_w(valor:byte);
var
  temp:boolean;
begin
	// bit 7 and 6 are read only
	valor:=valor and $3f;
	// update the control register
	self.ctl_a:=valor;
	// CA2 is configured as output
	if (c2_output(self.ctl_a)) then begin
		if (c2_set_mode(self.ctl_a)) then // set/reset mode - bit value determines the new output
			temp:=c2_set(self.ctl_a)
		else	// strobe mode - output is always high unless strobed
			temp:=true;
		set_out_ca2(temp);
	end;
	// update externals
	self.update_interrupts;
end;

function pia6821_chip.get_out_b_value:byte;
begin
     // input pins are high-impedance - we just send them as zeros for backwards compatibility
     get_out_b_value:=self.out_b and self.ddr_b;
end;

procedure pia6821_chip.send_to_out_b_func;
var
  data:byte;
begin
     // input pins are high-impedance - we just send them as zeros for backwards compatibility
     data:=self.get_out_b_value;
     if (addr(self.out_b_handler)<>nil) then self.out_b_handler(data)
        else self.out_b_needs_pulled:=true;
end;

procedure pia6821_chip.port_b_w(valor:byte);
begin
     // buffer the output value
     self.out_b:=valor;
     self.send_to_out_b_func;
     // CB2 in write strobe mode
     if (c2_strobe_mode(self.ctl_b)) then begin
          // this will cause a transition low
	  self.set_out_cb2(false);
	  // if the CB2 strobe is cleared by the E, reset it right away
          if (strobe_e_reset(self.ctl_b)) then set_out_cb2(true);
     end;
end;

procedure pia6821_chip.ddr_b_w(valor:byte);
begin
     if (self.ddr_b<>valor) then begin
        // DDR changed, call the callback again
	self.ddr_b:=valor;
	self.logged_port_b_not_connected:=false;
	self.send_to_out_b_func;
     end;
end;

procedure pia6821_chip.control_b_w(valor:byte);
var
   temp:boolean;
begin
	// bit 7 and 6 are read only
	valor:=valor and $3f;
	// update the control register
	self.ctl_b:=valor;
	if (c2_set_mode(self.ctl_b)) then // set/reset mode - bit value determines the new output
	   temp:=c2_set(self.ctl_b)
	else // strobe mode - output is always high unless strobed
	   temp:=true;
	self.set_out_cb2(temp);
	// update externals
	self.update_interrupts;
end;

procedure pia6821_chip.write(dir,valor:byte);
begin
	case (dir and $3) of
		$00:if (output_selected(self.ctl_a)) then port_a_w(valor)
			    else ddr_a_w(valor);
		$01:control_a_w(valor);
		$02:if (output_selected(self.ctl_b)) then port_b_w(valor)
			    else ddr_b_w(valor);
		$03:control_b_w(valor);
  end;
end;

procedure pia6821_chip.portb_w(valor:byte);
begin
	//assert_always(m_in_b_handler.isnull(), "pia_set_input_b() called when in_b_func implemented");
	self.in_b:=valor;
	self.in_b_pushed:=true;
end;

end.
