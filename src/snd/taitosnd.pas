unit taitosnd;

interface
uses nz80,main_engine;

const
  TC0140SYT_PORT01_FULL=$01;
  TC0140SYT_PORT23_FULL=$02;
  TC0140SYT_PORT01_FULL_MASTER=$04;
  TC0140SYT_PORT23_FULL_MASTER=$08;

type
  t_TC0140SYT=record
  	slavedata:array[0..3] of byte;	// Data on master->slave port (4 nibbles) */
  	masterdata:array[0..3] of byte;// Data on slave->master port (4 nibbles) */
  	mainmode:byte;		// Access mode on master cpu side */
  	submode:byte;		// Access mode on slave cpu side */
  	status:byte;		// Status data */
  	nmi_enabled:boolean;	// 1 if slave cpu has nmi's enabled */
  	nmi_req:boolean;		// 1 if slave cpu has a pending nmi */
  end;
var
  TC0140SYT:t_TC0140SYT;

procedure taitosound_port_w(valor:byte);
procedure taitosound_comm_w(valor:byte);
function taitosound_comm_r:byte;
procedure taitosound_slave_port_w(valor:byte);
procedure taitosound_slave_comm_w(valor:byte);
function taitosound_slave_comm_r:byte;
procedure taitosound_reset;

implementation

procedure Interrupt_Controller;
begin
	if (tc0140syt.nmi_req and tc0140syt.nmi_enabled) then begin
    snd_z80.change_nmi(PULSE_LINE);
		tc0140syt.nmi_req:=false;
	end;
end;

procedure taitosound_port_w(valor:byte);
begin
	tc0140syt.mainmode:=valor and $f;
end;

procedure taitosound_comm_w(valor:byte);
begin
	valor:=valor and $0f;	//this is important, otherwise ballbros won't work*/
	case tc0140syt.mainmode of
		$00:begin		// mode #0
			    tc0140syt.slavedata[tc0140syt.mainmode]:=valor;
          tc0140syt.mainmode:=tc0140syt.mainmode+1;
			  end;
		$01:begin		// mode #1
    			tc0140syt.slavedata[tc0140syt.mainmode]:=valor;
          tc0140syt.mainmode:=tc0140syt.mainmode+1;
		    	tc0140syt.status:=tc0140syt.status or TC0140SYT_PORT01_FULL;
    			tc0140syt.nmi_req:=true;
        end;
		$02:begin		// mode #2
			    tc0140syt.slavedata[tc0140syt.mainmode]:=valor;
          tc0140syt.mainmode:=tc0140syt.mainmode+1;
			  end;
		$03:begin		// mode #3
    			tc0140syt.slavedata[tc0140syt.mainmode]:=valor;
          tc0140syt.mainmode:=tc0140syt.mainmode+1;
    			tc0140syt.status:=tc0140syt.status or TC0140SYT_PORT23_FULL;
    			tc0140syt.nmi_req:=true;
        end;
		$04:begin		// port status
    			// this does a hi-lo transition to reset the sound cpu */
    			if (valor<>0) then snd_z80.reset;
            //cpu_spin(space->cpu); /* otherwise no sound in driftout */
        end;
	end;
end;

function taitosound_comm_r:byte;
begin
	case tc0140syt.mainmode of
		$00:begin		// mode #0
			    taitosound_comm_r:=tc0140syt.masterdata[tc0140syt.mainmode];
          tc0140syt.mainmode:=tc0140syt.mainmode+1;
        end;
		$01:begin		// mode #1
    			tc0140syt.status:=tc0140syt.status and not(TC0140SYT_PORT01_FULL_MASTER);
			    taitosound_comm_r:=tc0140syt.masterdata[tc0140syt.mainmode];
          tc0140syt.mainmode:=tc0140syt.mainmode+1;
        end;
		$02:begin		// mode #2
			    taitosound_comm_r:=tc0140syt.masterdata[tc0140syt.mainmode];
          tc0140syt.mainmode:=tc0140syt.mainmode+1;
        end;
		$03:begin		// mode #3
    			tc0140syt.status:=tc0140syt.status and not(TC0140SYT_PORT23_FULL_MASTER);
		    	taitosound_comm_r:=tc0140syt.masterdata[tc0140syt.mainmode];
          tc0140syt.mainmode:=tc0140syt.mainmode+1;
        end;
		$04:taitosound_comm_r:=tc0140syt.status;		// port status
		  else taitosound_comm_r:=0;
	end;
end;

//SLAVE
procedure taitosound_slave_port_w(valor:byte);
begin
	tc0140syt.submode:=valor and $f;
end;

procedure taitosound_slave_comm_w(valor:byte);
begin
	valor:=valor and $0f;
	case tc0140syt.submode of
		$00:begin		// mode #0
    			tc0140syt.masterdata[tc0140syt.submode]:=valor;
          tc0140syt.submode:=tc0140syt.submode+1;
        end;
		$01:begin		// mode #1
    			tc0140syt.masterdata[tc0140syt.submode]:=valor;
          tc0140syt.submode:=tc0140syt.submode+1;
    			tc0140syt.status:=tc0140syt.status or TC0140SYT_PORT01_FULL_MASTER;
    			//cpu_spin(space->cpu); /* writing should take longer than emulated, so spin */
			  end;
		$02:begin		// mode #2
    			tc0140syt.masterdata[tc0140syt.submode]:=valor;
          tc0140syt.submode:=tc0140syt.submode+1;
			  end;
		$03:begin		// mode #3
    			tc0140syt.masterdata[tc0140syt.submode]:=valor;
          tc0140syt.submode:=tc0140syt.submode+1;
    			tc0140syt.status:=tc0140syt.status or TC0140SYT_PORT23_FULL_MASTER;
			    //cpu_spin(space->cpu); /* writing should take longer than emulated, so spin */
			  end;
		$04:;		// port status
		$05:tc0140syt.nmi_enabled:=false;		// nmi disable
		$06:tc0140syt.nmi_enabled:=true;		// nmi enable
	end;
	Interrupt_Controller;
end;

function taitosound_slave_comm_r:byte;
var
  res:byte;
begin
	case tc0140syt.submode of
		$00:begin		// mode #0
    			res:=tc0140syt.slavedata[tc0140syt.submode];
          tc0140syt.submode:=tc0140syt.submode+1;
			  end;
		$01:begin		// mode #1
    			tc0140syt.status:=tc0140syt.status and not(TC0140SYT_PORT01_FULL);
		    	res:=tc0140syt.slavedata[tc0140syt.submode];
          tc0140syt.submode:=tc0140syt.submode+1;
        end;
		02:begin		// mode #2
    			res:=tc0140syt.slavedata[tc0140syt.submode];
          tc0140syt.submode:=tc0140syt.submode+1;
			 end;
		$03:begin		// mode #3
    			tc0140syt.status:=tc0140syt.status and not(TC0140SYT_PORT23_FULL);
    			res:=tc0140syt.slavedata[tc0140syt.submode];
          tc0140syt.submode:=tc0140syt.submode+1;
        end;
		$04:res:= tc0140syt.status;		// port status
    	 else res:=0;
    end;
	Interrupt_Controller;
  taitosound_slave_comm_r:=res;
end;

procedure taitosound_reset;
begin
  fillchar(TC0140SYT.slavedata[0],4,0);
  fillchar(TC0140SYT.masterdata[0],4,0);
  TC0140SYT.mainmode:=0;
  TC0140SYT.submode:=0;
  TC0140SYT.status:=0;
  TC0140SYT.nmi_enabled:=false;
  TC0140SYT.nmi_req:=false;
end;

end.
