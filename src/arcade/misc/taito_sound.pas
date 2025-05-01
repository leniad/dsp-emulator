unit taito_sound;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}nz80,main_engine,ym_2151,
     msm5205,ym_2203;

type
  tc0140syt_chip=class
    constructor create(clock:dword;frames_div:word;sound_type:byte);
    destructor free;
    public
      z80:cpu_z80;
      ym2151:ym2151_chip;
      snd_rom:array[0..$7fff] of byte;
      snd_bank_rom:array[0..3,$0..$3fff] of byte;
      procedure port_w(valor:byte);
      procedure comm_w(valor:byte);
      function comm_r:byte;
      procedure slave_port_w(valor:byte);
      procedure slave_comm_w(valor:byte);
      function slave_comm_r:byte;
      procedure reset;
      procedure run;
    private
  	  slavedata:array[0..3] of byte;
  	  masterdata:array[0..3] of byte;
      ram:array[0..$1fff] of byte;
  	  mainmode:byte;
  	  submode:byte;
  	  status:byte;
  	  nmi_enabled:boolean;
  	  nmi_req:boolean;
      sound_bank:byte;
      frame:single;
      adpcm_b,adpcm_c:array[0..5] of byte;
      sound_type:byte;
      procedure interrupt_controller;
  end;

const
  SOUND_RASTAN=1;
  SOUND_OPWOLF=2;
  SOUND_VOLFIED=3;
  SOUND_RAINBOWI=4;
  SOUND_TAITOB=5;
  SOUND_MASTERW=6;

var
  tc0140syt_0:tc0140syt_chip;

implementation
const
  TC0140SYT_PORT01_FULL=1;
  TC0140SYT_PORT23_FULL=2;
  TC0140SYT_PORT01_FULL_MASTER=4;
  TC0140SYT_PORT23_FULL_MASTER=8;

//Rastan
function rastan_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$3fff:rastan_snd_getbyte:=tc0140syt_0.snd_rom[direccion];
  $4000..$7fff:rastan_snd_getbyte:=tc0140syt_0.snd_bank_rom[tc0140syt_0.sound_bank,direccion and $3fff];
  $8000..$8fff:rastan_snd_getbyte:=tc0140syt_0.ram[direccion and $fff];
  $9001:rastan_snd_getbyte:=tc0140syt_0.ym2151.status;
  $a001:rastan_snd_getbyte:=tc0140syt_0.slave_comm_r;
end;
end;

procedure rastan_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:; //ROM
  $8000..$8fff:tc0140syt_0.ram[direccion and $fff]:=valor;
  $9000:tc0140syt_0.ym2151.reg(valor);
  $9001:tc0140syt_0.ym2151.write(valor);
  $a000:tc0140syt_0.slave_port_w(valor);
  $a001:tc0140syt_0.slave_comm_w(valor);
  $b000:msm5205_0.pos:=(msm5205_0.pos and $ff) or (valor shl 8);
  $c000:msm5205_0.reset_w(false);
  $d000:begin
           msm5205_0.reset_w(true);
           msm5205_0.pos:=msm5205_0.pos and $ff00;
        end;
end;
end;

procedure rastan_snd_adpcm;
begin
if msm5205_0.data_val<>-1 then begin
		msm5205_0.data_w(msm5205_0.data_val and $f);
		msm5205_0.data_val:=-1;
    msm5205_0.pos:=(msm5205_0.pos+1) and $ffff;
end else begin
		msm5205_0.data_val:=msm5205_0.rom_data[msm5205_0.pos];
		msm5205_0.data_w(msm5205_0.data_val shr 4);
end;
end;

procedure rastan_sound_update;
begin
  tc0140syt_0.ym2151.update;
  msm5205_0.update;
end;

procedure rastan_sound_bank(valor:byte);
begin
  tc0140syt_0.sound_bank:=valor and 3;
end;

procedure tc0140syt_irq(irqstate:byte);
begin
  tc0140syt_0.z80.change_irq(irqstate);
end;

//Operation Wolf
procedure opwolf_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:;
  $8000..$8fff:tc0140syt_0.ram[direccion and $fff]:=valor;
  $9000:tc0140syt_0.ym2151.reg(valor);
  $9001:tc0140syt_0.ym2151.write(valor);
  $a000:tc0140syt_0.slave_port_w(valor);
  $a001:tc0140syt_0.slave_comm_w(valor);
  $b000..$b006:begin
                  tc0140syt_0.adpcm_b[direccion and $7]:=valor;
                	if ((direccion and $7)=$04) then begin
                		msm5205_0.pos:=(tc0140syt_0.adpcm_b[0]+(tc0140syt_0.adpcm_b[1] shl 8))*16;
                		msm5205_0.end_:=(tc0140syt_0.adpcm_b[2]+(tc0140syt_0.adpcm_b[3] shl 8))*16;
                		msm5205_0.reset_w(false);
                  end;
	             end;
  $c000..$c006:begin
                  tc0140syt_0.adpcm_c[direccion and $7]:=valor;
                	if ((direccion and $7)=$04) then begin
                		msm5205_1.pos:=(tc0140syt_0.adpcm_c[0]+(tc0140syt_0.adpcm_c[1] shl 8))*16;
                		msm5205_1.end_:=(tc0140syt_0.adpcm_c[2]+(tc0140syt_0.adpcm_c[3] shl 8))*16;
                		msm5205_1.reset_w(false);
	                end;
               end;
  end;
end;

procedure opwolf_sound_update;
begin
  tc0140syt_0.ym2151.update;
  msm5205_0.update;
  msm5205_1.update;
end;

//Volfied
function volfied_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff:volfied_snd_getbyte:=tc0140syt_0.snd_rom[direccion];
  $8000..$87ff:volfied_snd_getbyte:=tc0140syt_0.ram[direccion and $7ff];
  $8801:volfied_snd_getbyte:=tc0140syt_0.slave_comm_r;
  $9000:volfied_snd_getbyte:=ym2203_0.status;
  $9001:volfied_snd_getbyte:=ym2203_0.read;
end;
end;

procedure volfied_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:; //ROM
  $8000..$87ff:tc0140syt_0.ram[direccion and $7ff]:=valor;
  $8800:tc0140syt_0.slave_port_w(valor);
  $8801:tc0140syt_0.slave_comm_w(valor);
  $9000:ym2203_0.control(valor);
  $9001:ym2203_0.write(valor);
end;
end;

procedure volfied_update_sound;
begin
  ym2203_0.update;
end;

//Rainbow Island
procedure rainbow_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:; //ROM
  $8000..$8fff:tc0140syt_0.ram[direccion and $fff]:=valor;
  $9000:tc0140syt_0.ym2151.reg(valor);
  $9001:tc0140syt_0.ym2151.write(valor);
  $a000:tc0140syt_0.slave_port_w(valor);
  $a001:tc0140syt_0.slave_comm_w(valor);
end;
end;

procedure rainbow_sound_update;
begin
  tc0140syt_0.ym2151.update;
end;

//TaitoB
function taitob_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$3fff:taitob_snd_getbyte:=tc0140syt_0.snd_rom[direccion];
  $4000..$7fff:taitob_snd_getbyte:=tc0140syt_0.snd_bank_rom[tc0140syt_0.sound_bank,direccion and $3fff];
  $c000..$dfff:taitob_snd_getbyte:=tc0140syt_0.ram[direccion and $1fff];
  $e000:taitob_snd_getbyte:=ym2203_0.status;
  $e001:taitob_snd_getbyte:=ym2203_0.read;
  $e002..$e003:taitob_snd_getbyte:=0; //ymadpcm
  $e201:taitob_snd_getbyte:=tc0140syt_0.slave_comm_r;
end;
end;

procedure taitob_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:; //ROM
  $c000..$dfff:tc0140syt_0.ram[direccion and $1fff]:=valor;
  $e000:ym2203_0.control(valor);
  $e001:ym2203_0.write(valor);
  $e002..$e003:; //ym
  $e200:tc0140syt_0.slave_port_w(valor);
  $e201:tc0140syt_0.slave_comm_w(valor);
  $f200:tc0140syt_0.sound_bank:=valor and 3;
end;
end;

procedure taitob_sound_update;
begin
  //ym.update;
end;

//Master of Weapon
function masterw_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$3fff:masterw_snd_getbyte:=tc0140syt_0.snd_rom[direccion];
  $4000..$7fff:masterw_snd_getbyte:=tc0140syt_0.snd_bank_rom[tc0140syt_0.sound_bank,direccion and $3fff];
  $8000..$8fff:masterw_snd_getbyte:=tc0140syt_0.ram[direccion and $fff];
  $9000:masterw_snd_getbyte:=ym2203_0.status;
  $9001:masterw_snd_getbyte:=ym2203_0.read;
  $a001:masterw_snd_getbyte:=tc0140syt_0.slave_comm_r;
end;
end;

procedure masterw_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:; //ROM
  $8000..$8fff:tc0140syt_0.ram[direccion and $fff]:=valor;
  $9000:ym2203_0.control(valor);
  $9001:ym2203_0.write(valor);
  $a000:tc0140syt_0.slave_port_w(valor);
  $a001:tc0140syt_0.slave_comm_w(valor);
end;
end;

constructor tc0140syt_chip.create(clock:dword;frames_div:word;sound_type:byte);
begin
  self.z80:=cpu_z80.create(clock,frames_div);
  self.sound_type:=sound_type;
  case sound_type of
    SOUND_RASTAN:begin
      self.z80.change_ram_calls(rastan_snd_getbyte,rastan_snd_putbyte);
      self.z80.init_sound(rastan_sound_update);
      self.ym2151:=ym2151_chip.create(4000000);
      self.ym2151.change_port_func(rastan_sound_bank);
      self.ym2151.change_irq_func(tc0140syt_irq);
      msm5205_0:=msm5205_chip.create(384000,MSM5205_S48_4B,1,$10000);
      msm5205_0.change_advance(rastan_snd_adpcm);
    end;
    SOUND_OPWOLF:begin
      self.z80.change_ram_calls(rastan_snd_getbyte,opwolf_snd_putbyte);
      self.z80.init_sound(rastan_sound_update);
      self.ym2151:=ym2151_chip.create(4000000);
      self.ym2151.change_port_func(rastan_sound_bank);
      self.ym2151.change_irq_func(tc0140syt_irq);
      msm5205_0:=MSM5205_chip.create(384000,MSM5205_S48_4B,1,$80000);
      msm5205_1:=MSM5205_chip.create(384000,MSM5205_S48_4B,1,$80000);
    end;
    SOUND_VOLFIED:begin
      self.z80.change_ram_calls(volfied_snd_getbyte,volfied_snd_putbyte);
      self.z80.init_sound(volfied_update_sound);
      ym2203_0:=ym2203_chip.create(4000000);
      ym2203_0.change_irq_calls(tc0140syt_irq);
    end;
    SOUND_RAINBOWI:begin
      self.z80.change_ram_calls(rastan_snd_getbyte,rainbow_snd_putbyte);
      self.z80.init_sound(rainbow_sound_update);
      self.ym2151:=ym2151_chip.create(4000000);
      self.ym2151.change_port_func(rastan_sound_bank);
      self.ym2151.change_irq_func(tc0140syt_irq);
    end;
    SOUND_TAITOB:begin
      self.z80.change_ram_calls(taitob_snd_getbyte,taitob_snd_putbyte);
      self.z80.init_sound(taitob_sound_update);
      ym2203_0:=ym2203_chip.create(4000000);
      ym2203_0.change_irq_calls(tc0140syt_irq);
    end;
    SOUND_MASTERW:begin
      self.z80.change_ram_calls(masterw_snd_getbyte,masterw_snd_putbyte);
      self.z80.init_sound(volfied_update_sound);
      ym2203_0:=ym2203_chip.create(3000000);
      ym2203_0.change_irq_calls(tc0140syt_irq);
      ym2203_0.change_io_calls(nil,nil,rastan_sound_bank,nil);
    end;
  end;
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
  self.sound_bank:=0;
  self.nmi_enabled:=false;
  self.nmi_req:=false;
  self.z80.reset;
  self.frame:=self.z80.tframes;
  fillchar(self.adpcm_b,6,0);
  fillchar(self.adpcm_c,6,0);
  case self.sound_type of
    SOUND_RASTAN:begin
                      self.ym2151.reset;
                      msm5205_0.reset;
                 end;
    SOUND_OPWOLF:begin
                      self.ym2151.reset;
                      msm5205_0.reset;
                      msm5205_1.reset;
                 end;
    SOUND_VOLFIED:ym2203_0.reset;
    SOUND_RAINBOWI:self.ym2151.reset;
    SOUND_TAITOB:ym2203_0.reset;
    SOUND_MASTERW:ym2203_0.reset;
  end;
end;

procedure tc0140syt_chip.run;
begin
  self.z80.run(self.frame);
  self.frame:=self.frame+self.z80.tframes-self.z80.contador;
end;

procedure tc0140syt_chip.port_w(valor:byte);
begin
	self.mainmode:=valor and $f;
end;

procedure tc0140syt_chip.comm_w(valor:byte);
begin
	valor:=valor and $f;
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
