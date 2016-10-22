unit taitosnd;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}nz80,main_engine;

const
  TC0140SYT_PORT01_FULL=$01;
  TC0140SYT_PORT23_FULL=$02;
  TC0140SYT_PORT01_FULL_MASTER=$04;
  TC0140SYT_PORT23_FULL_MASTER=$08;

type
  tc0140syt_chip=class
    constructor create(clock:dword;frames_div:word);
    destructor free;
    public
      z80:cpu_z80;
      procedure port_w(valor:byte);
      procedure comm_w(valor:byte);
      function comm_r:byte;
      procedure slave_port_w(valor:byte);
      procedure slave_comm_w(valor:byte);
      function slave_comm_r:byte;
      procedure reset;
    private
  	  slavedata:array[0..3] of byte;	// Data on master->slave port (4 nibbles) */
  	  masterdata:array[0..3] of byte;// Data on slave->master port (4 nibbles) */
  	  mainmode:byte;		// Access mode on master cpu side */
  	  submode:byte;		// Access mode on slave cpu side */
  	  status:byte;		// Status data */
  	  nmi_enabled:boolean;	// 1 if slave cpu has nmi's enabled */
  	  nmi_req:boolean;		// 1 if slave cpu has a pending nmi */
      procedure interrupt_controller;
  end;
var
  tc0140syt_0:tc0140syt_chip;

implementation

constructor tc0140syt_chip.create(clock:dword;frames_div:word);
begin
  self.z80:=cpu_z80.create(clock,frames_div);
end;

destructor tc0140syt_chip.free;
begin
  self.z80.free;
end;

procedure tc0140syt_chip.reset;
begin
  fillchar(self.slavedata[0],4,0);
  fillchar(self.masterdata[0],4,0);
  self.mainmode:=0;
  self.submode:=0;
  self.status:=0;
  self.nmi_enabled:=false;
  self.nmi_req:=false;
  self.z80.reset;
end;

procedure tc0140syt_chip.port_w(valor:byte);
begin
	self.mainmode:=valor and $f;
end;

procedure tc0140syt_chip.comm_w(valor:byte);
begin
	valor:=valor and $0f;	//this is important, otherwise ballbros won't work
	case self.mainmode of
		$00:begin		// mode #0
			    self.slavedata[self.mainmode]:=valor;
          self.mainmode:=self.mainmode+1;
			  end;
		$01:begin		// mode #1
    			self.slavedata[self.mainmode]:=valor;
          self.mainmode:=self.mainmode+1;
		    	self.status:=self.status or TC0140SYT_PORT01_FULL;
    			self.nmi_req:=true;
        end;
		$02:begin		// mode #2
			    self.slavedata[self.mainmode]:=valor;
          self.mainmode:=self.mainmode+1;
			  end;
		$03:begin		// mode #3
    			self.slavedata[self.mainmode]:=valor;
          self.mainmode:=self.mainmode+1;
    			self.status:=self.status or TC0140SYT_PORT23_FULL;
          self.nmi_req:=true;
        end;
		$04:begin		// port status
    			// this does a hi-lo transition to reset the sound cpu */
    			if (valor<>0) then self.reset;
            //cpu_spin(space->cpu); /* otherwise no sound in driftout */
        end;
	end;
end;

function tc0140syt_chip.comm_r:byte;
begin
	case self.mainmode of
		$00:begin		// mode #0
			    comm_r:=self.masterdata[self.mainmode];
          self.mainmode:=self.mainmode+1;
        end;
		$01:begin		// mode #1
    			self.status:=self.status and not(TC0140SYT_PORT01_FULL_MASTER);
			    comm_r:=self.masterdata[self.mainmode];
          self.mainmode:=self.mainmode+1;
        end;
		$02:begin		// mode #2
			    comm_r:=self.masterdata[self.mainmode];
          self.mainmode:=self.mainmode+1;
        end;
		$03:begin		// mode #3
    			self.status:=self.status and not(TC0140SYT_PORT23_FULL_MASTER);
		    	comm_r:=self.masterdata[self.mainmode];
          self.mainmode:=self.mainmode+1;
        end;
		$04:comm_r:=self.status;		// port status
		  else comm_r:=0;
	end;
end;

//SLAVE
procedure tc0140syt_chip.interrupt_controller;
begin
	if (self.nmi_req and self.nmi_enabled) then begin
    self.z80.change_nmi(PULSE_LINE);
		self.nmi_req:=false;
	end;
end;

procedure tc0140syt_chip.slave_port_w(valor:byte);
begin
	self.submode:=valor and $f;
end;

procedure tc0140syt_chip.slave_comm_w(valor:byte);
begin
	valor:=valor and $0f;
	case self.submode of
		$00:begin		// mode #0
    			self.masterdata[self.submode]:=valor;
          self.submode:=self.submode+1;
        end;
		$01:begin		// mode #1
    			self.masterdata[self.submode]:=valor;
          self.submode:=self.submode+1;
    			self.status:=self.status or TC0140SYT_PORT01_FULL_MASTER;
    			//cpu_spin(space->cpu); /* writing should take longer than emulated, so spin */
			  end;
		$02:begin		// mode #2
    			self.masterdata[self.submode]:=valor;
          self.submode:=self.submode+1;
			  end;
		$03:begin		// mode #3
    			self.masterdata[self.submode]:=valor;
          self.submode:=self.submode+1;
    			self.status:=self.status or TC0140SYT_PORT23_FULL_MASTER;
			    //cpu_spin(space->cpu); /* writing should take longer than emulated, so spin */
			  end;
		$04:;		// port status
		$05:self.nmi_enabled:=false;		// nmi disable
		$06:self.nmi_enabled:=true;		// nmi enable
	end;
	Interrupt_Controller;
end;

function tc0140syt_chip.slave_comm_r:byte;
var
  res:byte;
begin
	case self.submode of
		$00:begin		// mode #0
    			res:=self.slavedata[self.submode];
          self.submode:=self.submode+1;
			  end;
		$01:begin		// mode #1
    			self.status:=self.status and not(TC0140SYT_PORT01_FULL);
		    	res:=self.slavedata[self.submode];
          self.submode:=self.submode+1;
        end;
		02:begin		// mode #2
    			res:=self.slavedata[self.submode];
          self.submode:=self.submode+1;
			 end;
		$03:begin		// mode #3
    			self.status:=self.status and not(TC0140SYT_PORT23_FULL);
    			res:=self.slavedata[self.submode];
          self.submode:=self.submode+1;
        end;
		$04:res:= self.status;		// port status
    	 else res:=0;
    end;
	Interrupt_Controller;
  slave_comm_r:=res;
end;

end.
