unit upd7810;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     cpu_misc,vars_hide,main_engine,timer_engine,dialogs,sysutils,upd7810_tables;

type
  band_upd7810=record
     zf,f1,f7,sk,hc,l1,l0,cy:boolean;
  end;
  nreg_upd7810=record
        psw:band_upd7810;
        va,bc,de,hl,va2,bc2,de2,hl2:parejas;
        ea,ea2:word;
  end;
  upd7810_cb=function:byte;
  upd7810_cb_2=procedure(valor:byte);
  upd7810_cb_3=function(mask:byte):byte;
  npreg_upd7810=^nreg_upd7810;
  cpu_upd7810=class(cpu_class)
                constructor create(clock:dword;cpu:byte);
                destructor free;
              public
                ram:array[0..$ff] of byte;
                procedure reset;
                procedure run(maximo:single);
                procedure change_an(an0,an1,an2,an3,an4,an5,an6,an7:upd7810_cb);
                procedure change_in(ca,cb,cc,cd,cf:upd7810_cb_3);
                procedure change_out(ca,cb,cc,cd,cf:upd7810_cb_2);
                procedure set_input_line(irqline,state:byte);
                procedure set_input_line_7801(irqline,state:byte);
                function save_snapshot(data:pbyte):word;
                procedure load_snapshot(data:pbyte);
              private
                cpu_type:byte;
                ppc,pc,sp:word;
                iff,iff_pending:boolean;
                adcnt,irr:word;
	              adtot,tmpcr,mkl,mkh:byte;
                tm,cnt,ecnt:parejas;
                panm,anm,mm,mf,ci,smh,sml:byte;
                ma,mb,mc,mcc:byte;
                etmm,tmm:byte;
                pa_in,pb_in,pc_in,pd_in,pf_in:byte;
	              pa_out,pb_out,pc_out,pd_out,pf_out:byte;
                txd,rdx,sck,to_,co0,co1:byte;
                adout,adin,adrange:integer;
                ovc0:integer;
                shdone:boolean;
                r:npreg_upd7810;
                an_func:array[0..7] of upd7810_cb;
                cr:array[0..3] of byte;
                pa_out_cb,pb_out_cb,pc_out_cb,pd_out_cb,pf_out_cb:upd7810_cb_2;
                pa_in_cb,pb_in_cb,pc_in_cb,pd_in_cb,pf_in_cb:upd7810_cb_3;
                nmi,int1,int2:byte;
                procedure take_irq_7810;
                procedure take_irq_7801;
                procedure opcode_48;
                procedure opcode_4c;
                procedure opcode_4d;
                procedure opcode_60;
                procedure opcode_64;
                procedure opcode_70;
                procedure opcode_74;
                procedure handle_timers_7810(estados:byte);
                procedure handle_timers_7801(estados:byte);
                procedure write_port(port,valor:byte);
                function read_port(port:byte):byte;
                procedure ZHC_SUB(after,before:word;carry:boolean);
                procedure ZHC_ADD(after,before:word;carry:boolean);
                function dame_band:byte;
                procedure poner_band(valor:byte);
                procedure EQI_X(reg:pbyte);
                procedure NEI_X(reg:pbyte);
                procedure ANI_X(reg:pbyte);
                procedure XRI_X(reg:pbyte);
                procedure OFFI_X(reg:pbyte);
                procedure ONI_X(reg:pbyte);
                procedure ORI_X(reg:pbyte);
                procedure SUI_X(reg:pbyte);
                procedure ACI_X(reg:pbyte);
                procedure ADI_X(reg:pbyte);
                procedure LTI_X(reg:pbyte);
                procedure ADD_X_A(reg:pbyte);
                procedure ADC_X_A(reg:pbyte);
                procedure SUB_X_A(reg:pbyte);
                procedure XRA_A_X(reg:pbyte);
                procedure XRA_X_A(reg:pbyte);
                procedure ORA_A_X(reg:pbyte);
                procedure GTA_A_X(reg:pbyte);
                procedure ADD_A_X(reg:pbyte);
                procedure ADC_A_X(reg:pbyte);
                procedure SUB_A_X(reg:pbyte);
                procedure NEA_A_X(reg:pbyte);
                procedure NEA_X_A(reg:pbyte);
                procedure EQA_A_X(reg:pbyte);
                procedure LTA_A_X(reg:pbyte);
                procedure GTI_X(reg:pbyte);
                procedure SBI_X(reg:pbyte);
                procedure ADINC_X(reg:pbyte);
                procedure ANA_X_A(reg:pbyte);
                procedure OFFA_A_X(reg:pbyte);
                procedure SBB_X_A(reg:pbyte);
                procedure SUINB_X(reg:pbyte);
                procedure SUBNB_A_X(reg:pbyte);
                procedure SBB_A_X(reg:pbyte);
                procedure ADDNC_X_A(reg:pbyte);
                procedure ORA_X_A(reg:pbyte);
                procedure SUBNB_X_A(reg:pbyte);
                procedure ONA_A_X(reg:pbyte);
                procedure GTA_X_A(reg:pbyte);
                procedure LTA_X_A(reg:pbyte);
                procedure EQA_X_A(reg:pbyte);
                procedure ADDNC_A_X(reg:pbyte);
            end;

const
  UPD7810_INTF1=0;
  UPD7810_INTF2=1;
  UPD7810_INTF0=2;
  UPD7810_INTFE1=4;
  CPU_7810=0;
  CPU_7801=1;

var
  upd7810_0:cpu_upd7810;

implementation

const
  INTFNMI = $0001;
  INTFT0  = $0002;
  INTFT1  = $0004;
  INTF1   = $0008;
  INTF2   = $0010;
  INTFE0  = $0020;
  INTFE1  = $0040;
  INTFEIN = $0080;
  INTFAD  = $0100;
  INTFSR  = $0200;
  INTFST  = $0400;
  INTER   = $0800;
  INTOV   = $1000;
  INTF0   = $2000;

  UPD7810_PORTA=0;
  UPD7810_PORTB=1;
  UPD7810_PORTC=2;
  UPD7810_PORTD=3;
  UPD7810_PORTF=4;

constructor cpu_upd7810.create(clock:dword;cpu:byte);
var
  divisor:byte;
begin
  case cpu of
    CPU_7810:divisor:=3;
    CPU_7801:divisor:=2;
  end;
  getmem(self.r,sizeof(nreg_upd7810));
  fillchar(self.r^,sizeof(nreg_upd7810),0);
  self.numero_cpu:=cpu_main_init(clock div divisor);
  self.clock:=clock div divisor;
  self.tframes:=(clock/divisor/llamadas_maquina.scanlines)/llamadas_maquina.fps_max;
  self.cpu_type:=cpu;
  pa_in_cb:=nil;
  pb_in_cb:=nil;
  pc_in_cb:=nil;
  pd_in_cb:=nil;
  pf_in_cb:=nil;
  pa_out_cb:=nil;
  pb_out_cb:=nil;
  pc_out_cb:=nil;
  pd_out_cb:=nil;
  pf_out_cb:=nil;
  an_func[0]:=nil;
  an_func[1]:=nil;
  an_func[2]:=nil;
  an_func[3]:=nil;
  an_func[4]:=nil;
  an_func[5]:=nil;
  an_func[6]:=nil;
  an_func[7]:=nil;
end;

destructor cpu_upd7810.free;
begin
  freemem(self.r);
end;

procedure cpu_upd7810.reset;
begin
  self.pc:=0;
  self.ppc:=0;
  self.sp:=0;
  self.mkl:=$ff;
  self.mkh:=$ff;
  self.iff:=false;
  self.iff_pending:=false;
  self.r.psw.zf:=false;
  self.r.psw.sk:=false;
  self.r.psw.hc:=false;
  self.r.psw.l1:=false;
  self.r.psw.l0:=false;
  self.r.psw.cy:=false;
  self.r.psw.f1:=false;
  self.r.psw.f7:=false;
  self.r.va.w:=0;
  self.r.bc.w:=0;
  self.r.hl.w:=0;
  self.r.de.w:=0;
  self.r.bc2.w:=0;
  self.r.hl2.w:=0;
  self.r.de2.w:=0;
  self.mm:=0;
  self.mf:=$ff;
  self.anm:=0;
  self.panm:=$ff;
  self.ma:=$ff;
  self.mb:=$ff;
  self.mc:=$ff;
  self.mcc:=0;
  self.cr[0]:=0;
  self.cr[1]:=0;
  self.cr[2]:=0;
  self.cr[3]:=0;
  self.tm.w:=0;
  self.cnt.w:=0;
  self.tmm:=$ff;
  self.etmm:=$ff;
  self.ecnt.w:=0;
  self.ci:=0;
  self.smh:=0;
  self.sml:=0;
  self.shdone:=false;
  self.adout:=0;
  self.adin:=0;
  self.adrange:=0;
  self.pa_in:=0;
	self.pb_in:=0;
	self.pc_in:=0;
	self.pd_in:=0;
	self.pf_in:=0;
	self.pa_out:=0;
	self.pb_out:=0;
	self.pc_out:=0;
	self.pd_out:=0;
	self.pf_out:=0;
  self.txd:=0;
  self.rdx:=0;
  self.sck:=0;
  self.to_:=0;
  self.co0:=0;
  self.co1:=0;
  self.nmi:=CLEAR_LINE;
  self.int1:=CLEAR_LINE;
  self.ovc0:=0;
  self.int2:=1; //Invertido!!!!
  if self.cpu_type=CPU_7801 then begin
     self.ma:=0;
     self.int2:=0;
  end;
end;

procedure cpu_upd7810.change_an(an0,an1,an2,an3,an4,an5,an6,an7:upd7810_cb);
begin
  self.an_func[0]:=an0;
  self.an_func[1]:=an1;
  self.an_func[2]:=an2;
  self.an_func[3]:=an3;
  self.an_func[4]:=an4;
  self.an_func[5]:=an5;
  self.an_func[6]:=an6;
  self.an_func[7]:=an7;
end;

procedure cpu_upd7810.change_in(ca,cb,cc,cd,cf:upd7810_cb_3);
begin
  self.pa_in_cb:=ca;
  self.pb_in_cb:=cb;
  self.pc_in_cb:=cc;
  self.pd_in_cb:=cd;
  self.pf_in_cb:=cf;
end;

procedure cpu_upd7810.change_out(ca,cb,cc,cd,cf:upd7810_cb_2);
begin
  self.pa_out_cb:=ca;
  self.pb_out_cb:=cb;
  self.pc_out_cb:=cc;
  self.pd_out_cb:=cd;
  self.pf_out_cb:=cf;
end;

procedure cpu_upd7810.ZHC_SUB(after,before:word;carry:boolean);
begin
  self.r.psw.zf:=(after=0);
  if (before=after) then self.r.psw.cy:=carry
     else self.r.psw.cy:=(after>before);
  self.r.psw.hc:=(after and 15)>(before and 15);
end;

procedure cpu_upd7810.ZHC_ADD(after,before:word;carry:boolean);
begin
  self.r.psw.zf:=(after=0);
  if (after=before) then self.r.psw.cy:=carry
     else self.r.psw.cy:=(after<before);
  self.r.psw.hc:=(after and 15)<(before and 15);
end;

function cpu_upd7810.dame_band:byte;
var
  tempb:byte;
begin
  tempb:=0;
  if self.r.psw.cy then tempb:=tempb or $01;
  if self.r.psw.f1 then tempb:=tempb or $02;
  if self.r.psw.l0 then tempb:=tempb or $04;
  if self.r.psw.l1 then tempb:=tempb or $08;
  if self.r.psw.hc then tempb:=tempb or $10;
  if self.r.psw.sk then tempb:=tempb or $20;
  if self.r.psw.zf then tempb:=tempb or $40;
  if self.r.psw.f7 then tempb:=tempb or $80;
  dame_band:=tempb;
end;

procedure cpu_upd7810.poner_band(valor:byte);
begin
  self.r.psw.cy:=(valor and $01)<>0;
  self.r.psw.f1:=(valor and $02)<>0;
  self.r.psw.l0:=(valor and $04)<>0;
  self.r.psw.l1:=(valor and $08)<>0;
  self.r.psw.hc:=(valor and $10)<>0;
  self.r.psw.sk:=(valor and $20)<>0;
  self.r.psw.zf:=(valor and $40)<>0;
  self.r.psw.f7:=(valor and $80)<>0;
end;

procedure cpu_upd7810.set_input_line(irqline,state:byte);
begin
	case irqline of
	  INPUT_LINE_NMI:begin // NMI is falling edge sensitive
		                if ((self.nmi=CLEAR_LINE) and (state=ASSERT_LINE)) then self.irr:=self.irr or INTFNMI;
		                self.nmi:=state;
                   end;
	  UPD7810_INTF1:begin // INT1 is rising edge sensitive
		                if ((self.int1=CLEAR_LINE) and (state=ASSERT_LINE)) then self.irr:=self.irr or INTF1;
		                self.int1:=state;
                  end;
	  UPD7810_INTF2:begin
		                // INT2 is falling edge sensitive */
		                // we store the physical state (inverse of the logical state) */
		                // to keep the handling of port C consistent with the upd7801 */
		                if (((not(self.int2) and 1)=CLEAR_LINE) and (state=ASSERT_LINE)) then self.irr:=self.irr or INTF2;
                    self.int2:=not(state) and 1;
                  end;
  end;
end;

procedure cpu_upd7810.set_input_line_7801(irqline,state:byte);
begin
	case irqline of
	  UPD7810_INTF0:begin // INT0 is level sensitive
		                if (state=ASSERT_LINE) then self.irr:=self.irr or INTF0
                      else self.irr:=self.irr and INTF0;
                   end;
	  UPD7810_INTF1:begin //INT1 is rising edge sensitive
		                if ((self.int1=CLEAR_LINE) and (state=ASSERT_LINE)) then self.irr:=self.irr or INTF1;
		                self.int1:=state;
                  end;
	  UPD7810_INTF2:begin //INT2 is rising or falling edge sensitive
		                if (self.mkl and $20)<>0 then begin
			                if ((self.int2=CLEAR_LINE) and (state=ASSERT_LINE)) then self.irr:=self.irr or INTF2;
                    end else if ((self.int2=ASSERT_LINE) and (state=CLEAR_LINE)) then self.irr:=self.irr or INTF2;
                    self.int2:=state;
                  end;
  end;
end;

procedure cpu_upd7810.take_irq_7810;
var
	vector:word;
	irqline:integer;
begin
  // global interrupt disable?
	if not(self.iff) and ((self.irr and INTFNMI)=0) then exit;
  vector:=0;
  irqline:=0;
	// check the interrupts in priority sequence
	if (self.irr and INTFNMI)<>0 then begin
		// Nonmaskable interrupt
		irqline:=INPUT_LINE_NMI;
		vector:=$0004;
		self.irr:=self.irr and not(INTFNMI);
	end else
	  if (((self.irr and INTFT0)<>0) and ((self.mkl and $02)=0)) then begin
		  vector:=$0008;
		  if (self.mkl and $4)<>0 then self.irr:=self.irr and not(INTFT0);
	  end else
	    if (((self.irr and INTFT1)<>0) and ((self.mkl and $04)=0)) then begin
		    vector:=$0008;
		    if (self.mkl and $2)<>0 then self.irr:=self.irr and not(INTFT1);
	    end else
	      if (((self.irr and INTF1)<>0) and ((self.mkl and $08)=0)) then begin
		      irqline:=UPD7810_INTF1;
		      vector:=$0010;
		      if (self.mkl and $10)<>0 then self.irr:=self.irr and not(INTF1);
	      end else
	        if (((self.irr and INTF2)<>0) and ((self.mkl and $10)=0)) then begin
		        irqline:=UPD7810_INTF2;
		        vector:=$0010;
		        if (self.mkl and $8)<>0 then self.irr:=self.irr and not(INTF2);
	        end else
	          if (((self.irr and INTFE0)<>0) and ((self.mkl and $20)=0)) then begin
		          vector:=$0018;
		          if (self.mkl and $40)<>0 then self.irr:=self.irr and not(INTFE0);
	          end else
	            if (((self.irr and INTFE1)<>0) and ((self.mkl and $40)=0)) then begin
		            vector:=$0018;
		            if (self.mkl and $20)<>0 then self.irr:=self.irr and not(INTFE1);
	            end else
	              if (((self.irr and INTFEIN)<>0) and ((self.mkl and $80)=0)) then begin
		              vector:=0020;
                  if (self.mkh and $1)<>0 then self.irr:=self.irr and not(INTFEIN);
	              end else
	                if (((self.irr and INTFAD)<>0) and ((self.mkh and $1)=0)) then begin
		                vector:=$0020;
                    if (self.mkl and $80)<>0 then self.irr:=self.irr and not(INTFAD);
	                end else
	                  if (((self.irr and INTFSR)<>0) and ((self.mkh and $02)=0)) then begin
		                  vector:=$0028;
		                  if (self.mkh and $4)<>0 then self.irr:=self.irr and not(INTFSR);
	                  end else
                      if (((self.irr and INTFST)<>0) and ((self.mkh and $04)=0)) then begin
		                    vector:=$0028;
                        if (self.mkh and $2)<>0 then self.irr:=self.irr and not(INTFST);
                      end;
	if (vector<>0) then begin
		// acknowledge external IRQ
    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		//if (irqline<>0) then standard_irq_callback(irqline);
    self.sp:=self.sp-1;
    self.putbyte(self.sp,self.dame_band);
		self.sp:=self.sp-1;
    self.putbyte(self.sp,self.pc shr 8);
		self.sp:=self.sp-1;
    self.putbyte(self.sp,self.pc and $ff);
		self.iff:=false;
    self.iff_pending:=false;
    self.r.psw.sk:=false;
    self.r.psw.l0:=false;
    self.r.psw.l1:=false;
		self.pc:=vector;
	end;
end;

procedure cpu_upd7810.handle_timers_7810(estados:byte);
begin
	//**** TIMER 0
        // timer 0 upcounter reset ?
	if (self.tmm and $10)<>0 then self.cnt.l:=0  //cnt0
	   else MessageDlg('Timer 0!', mtInformation,[mbOk], 0);
  //**** TIMER 1
        // timer 1 upcounter reset ?
	if (self.tmm and $80)<>0 then self.cnt.h:=0  //cnt1
	   else MessageDlg('Timer 1!', mtInformation,[mbOk], 0);
  //**** TIMER F/F - timer F/F source is clock divided by 3 ? */
	if (self.tmm and $3)=$2 then MessageDlg('Timer F!', mtInformation,[mbOk], 0);
	//**** ETIMER - ECNT clear */
	if (self.etmm and $c)=$0 then self.ecnt.l:=0
	   else if (((self.etmm and $03)=0) or (((self.etmm and $3)=1) and (self.ci<>0))) then begin
	  MessageDlg('Timer ETMM!', mtInformation,[mbOk], 0);
        end;
  //SIO
  if (self.smh and $3)<>0 then MessageDlg('Timer SIO!', mtInformation,[mbOk], 0);
  //ADC
  self.adcnt:=self.adcnt+estados;
	if (self.panm<>self.anm) then begin
		// reset A/D converter */
		self.adcnt:=0;
		if (self.anm and $10)<>0 then self.adtot:=144
		  else self.adtot:=192;
		self.adout:=0;
		self.shdone:=false;
		if (self.anm and $01)<>0 then begin
			// select mode
			self.adin:=(self.anm shr 1) and $07;
		end else begin
			// scan mode
			self.adin:=0;
			self.adrange:=(self.anm shr 1) and $04;
		end;
	end;
	self.panm:=self.anm;
  if (self.anm and $1)<>0 then begin
    // select mode
    if not(self.shdone) then begin
       if addr(self.an_func[self.adin])<>nil then self.tmpcr:=self.an_func[self.adin];
       self.shdone:=true;
    end;
    if (self.adcnt>self.adtot) then begin
       self.adcnt:=self.adcnt-self.adtot;
       self.cr[self.adout]:=self.tmpcr;
       self.adout:=(self.adout+1) and $03;
       if (self.adout=0) then self.irr:=self.irr or INTFAD;
       self.shdone:=false;
    end;
  end else begin
    // scan mode
    if not(self.shdone) then begin
       if addr(an_func[self.adin or self.adrange])<>nil then self.tmpcr:=an_func[self.adin or self.adrange];
       self.shdone:=true;
    end;
    if (self.adcnt>self.adtot) then begin
       self.adcnt:=self.adcnt-self.adtot;
       self.cr[self.adout]:=self.tmpcr;
       self.adin:=(self.adin+1) and $03;
       self.adout:=(self.adout+1) and $03;
       if (self.adout=0) then self.irr:=self.irr or INTFAD;
       self.shdone:=false;
    end;
  end;
end;

procedure cpu_upd7810.take_irq_7801;
var
   vector:word;
   irqline:integer;
begin
  // global interrupt disable?
	if not(self.iff) then exit;
  vector:=0;
  irqline:=0;
	if (((self.irr and INTF0)<>0) and ((self.mkl and $01)=0)) then begin
	   vector:=$0004;
     irqline:=UPD7810_INTF0;
	   self.irr:=self.irr and not(INTF0);
	end;
  if (((self.irr and INTFT0)<>0) and ((self.mkl and $02)=0)) then begin
      vector:=$0008;
      self.irr:=self.irr and not(INTFT0);
  end;
  if (((self.irr and INTF1)<>0) and ((self.mkl and $04)=0)) then begin
      irqline:=UPD7810_INTF1;
      vector:=$0010;
      self.irr:=self.irr and not(INTF1);
  end;
  if (((self.irr and INTF2)<>0) and ((self.mkl and $8)=0)) then begin
      irqline:=UPD7810_INTF2;
      vector:=$0020;
      self.irr:=self.irr and not(INTF2);
  end;
  if (((self.irr and INTFST)<>0) and ((self.mkl and $10)=0)) then begin
      vector:=$0040;
      self.irr:=self.irr and not(INTFST);
  end;
	if (vector<>0) then begin
		// acknowledge external IRQ
    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		//if (irqline<>0) then standard_irq_callback(irqline);
    self.sp:=self.sp-1;
    self.putbyte(self.sp,self.dame_band);
    self.sp:=self.sp-1;
    self.putbyte(self.sp,self.pc shr 8);
		self.sp:=self.sp-1;
    self.putbyte(self.sp,self.pc and $ff);
		self.iff:=false;
    self.iff_pending:=false;
    self.r.psw.sk:=false;
    self.r.psw.l0:=false;
    self.r.psw.l1:=false;
		self.pc:=vector;
	end;
end;

procedure cpu_upd7810.handle_timers_7801(estados:byte);
begin
  if (self.ovc0<>0) then begin
       self.ovc0:=self.ovc0-estados;
		  // Check if timer expired
		  if (self.ovc0<=0) then begin
			  self.irr:=self.irr or INTFT0;
			  // Reset the timer flip/fliop
			  self.to_:=0;
        //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!11
			  //m_to_func(TO);
			  // Reload the timer
			  self.ovc0:=8*(self.tm.l+((self.tm.h and $0f) shl 8));
		  end;
  end;
end;

function cpu_upd7810.read_port(port:byte):byte;
var
  valor:byte;
begin
	valor:=$ff;
	case port of
	  UPD7810_PORTA:begin
		    if ((self.ma<>0) and (addr(self.pa_in_cb)<>nil)) then self.pa_in:=self.pa_in_cb(self.ma);
		    valor:=(self.pa_in and self.ma) or (self.pa_out and not(self.ma));
      end;
	  UPD7810_PORTB:begin
		    if ((self.mb<>0) and (addr(self.pb_in_cb)<>nil)) then self.pb_in:=self.pb_in_cb(self.mb);
		    valor:=(self.pb_in and self.mb) or (self.pb_out and not(self.mb));
		  end;
	  UPD7810_PORTC:begin
		    if ((self.mc<>0) and (addr(self.pc_in_cb)<>nil)) then self.pc_in:=self.pc_in_cb(self.mc);
		    valor:=(self.pc_in and self.mc) or (self.pc_out and not(self.mc));
		    if (self.mcc and $01)<>0 then begin // PC0 = TxD output
            valor:=valor and not($01);
            if (self.txd and 1)<>0 then valor:=valor or $01;
        end;
		    if (self.mcc and $02)<>0 then begin // PC1 = RxD input
            valor:=valor and not($02);
            if (self.rdx and 1)<>0 then valor:=valor or $02;
        end;
        if (self.mcc and $04)<>0 then begin // PC2 = SCK input/output
            valor:=valor and not($04);
            if (self.sck and 1)<>0 then valor:=valor or $04;
        end;
        if (self.mcc and $08)<>0 then begin // PC3 = TI/INT2 input
            valor:=valor and not($08);
            if (self.int2 and 1)<>0 then valor:=valor or $08;
        end;
        if (self.mcc and $10)<>0 then begin // PC4 = TO output
            valor:=valor and not($10);
            if (self.to_ and 1)<>0 then valor:=valor or $10;
        end;
        if (self.mcc and $20)<>0 then begin // PC5 = CI input
            valor:=valor and not($20);
            if (self.ci and 1)<>0 then valor:=valor or $20;
        end;
        if (self.mcc and $40)<>0 then begin // PC6 = CO0 output
            valor:=valor and not($40);
            if (self.co0 and 1)<>0 then valor:=valor or $40;
        end;
        if (self.mcc and $80)<>0 then begin // PC7 = CO1 output
            valor:=valor and not($80);
            if (self.co1 and 1)<>0 then valor:=valor or $80;
        end;
		  end;
	  UPD7810_PORTD:begin
		      if addr(self.pd_in_cb)<>nil then self.pd_in:=self.pd_in_cb(0);
		      case (self.mm and $07) of
		        $00:valor:=self.pd_in; // PD input mode, PF port mode */
		        $01:valor:=self.pd_out; // PD output mode, PF port mode */
		        else valor:=$ff; // PD extension mode, PF port/extension mode */
		      end;
		    end;
	  UPD7810_PORTF:begin
		      if ((self.mf<>0) and (addr(self.pf_in_cb)<>nil)) then self.pf_in:=self.pf_in_cb(self.mf);
		        case (self.mm and $06) of
		          $00:valor:=(self.pf_in and self.mf) or (self.pf_out and not(self.mf)); // PD input/output mode, PF port mode */
		          $02:begin // PD extension mode, PF0-3 extension mode, PF4-7 port mode */
			            valor:=(self.pf_in and self.mf) or (self.pf_out and not(self.mf));
			            valor:=valor or $0f;
                end;
              $04:begin // PD extension mode, PF0-5 extension mode, PF6-7 port mode */
			            valor:=(self.pf_in and self.mf) or (self.pf_out and not(self.mf));
			            valor:=valor or $3f;   // what would we see on the lower bits here? */
                end;
              $06:valor:=$ff;    // what would we see on the lower bits here? */
		        end;
          end;
  end;
	read_port:=valor;
end;

procedure cpu_upd7810.write_port(port,valor:byte);
begin
	case port of
	  UPD7810_PORTA:begin
		                self.pa_out:=valor;
		                valor:=(valor and not(self.ma)) or ($ff and self.ma); // NS20031401
		                if addr(self.pa_out_cb)<>nil then self.pa_out_cb(valor);
                  end;
	  UPD7810_PORTB:begin
		                self.pb_out:=valor;
		                valor:=(valor and not(self.mb)) or ($ff and self.mb); // NS20031401
		                if addr(self.pb_out_cb)<>nil then self.pb_out_cb(valor);
		              end;
	  UPD7810_PORTC:begin
		                self.pc_out:=valor;
		                valor:=(valor and not(self.mc)) or ($ff and self.mc); // NS20031401
                    if (self.mcc and $01)<>0 then begin // PC0 = TxD output */
                        valor:=valor and not($01);
                        if (self.txd and 1)<>0 then valor:=valor or $01;
                    end;
		                if (self.mcc and $02)<>0 then begin // PC1 = RxD input
                       valor:=valor and not($02);
                       if (self.rdx and 1)<>0 then valor:=valor or $02;
                    end;
                    if (self.mcc and $04)<>0 then begin // PC2 = SCK input/output
                       valor:=valor and not($04);
                       if (self.sck and 1)<>0 then valor:=valor or $04;
                    end;
                    if (self.mcc and $08)<>0 then begin // PC3 = TI/INT2 input
                       valor:=valor and not($08);
                       if (self.int2 and 1)<>0 then valor:=valor or $08;
                    end;
                    if (self.mcc and $10)<>0 then begin // PC4 = TO output
                       valor:=valor and not($10);
                       if (self.to_ and 1)<>0 then valor:=valor or $10;
                    end;
                    if (self.mcc and $20)<>0 then begin // PC5 = CI input
                       valor:=valor and not($20);
                       if (self.ci and 1)<>0 then valor:=valor or $20;
                    end;
                    if (self.mcc and $40)<>0 then begin // PC6 = CO0 output
                       valor:=valor and not($40);
                       if (self.co0 and 1)<>0 then valor:=valor or $40;
                    end;
                    if (self.mcc and $80)<>0 then begin // PC7 = CO1 output
                       valor:=valor and not($80);
                       if (self.co1 and 1)<>0 then valor:=valor or $80;
                    end;
                    if addr(self.pc_out_cb)<>nil then self.pc_out_cb(valor);
		            end;
	  UPD7810_PORTD:begin
		                self.pd_out:=valor;
                    case (self.mm and $07) of
		                    $00:valor:=$ff; // PD input mode, PF port mode
                        $01:valor:=self.pd_out; // PD output mode, PF port mode
		                      else exit; // PD extension mode, PF port/extension mode
		                end;
                    if addr(self.pd_out_cb)<>nil then self.pd_out_cb(valor);
                  end;
	  UPD7810_PORTF:begin
                    self.pf_out:=valor;
                    valor:=(valor and not(self.mf)) or ($ff and self.mf);
		                case (self.mm and $06) of
		                  $00:; // PD input/output mode, PF port mode */
		                  $02:valor:=valor or $0f; //PD extension mode, PF0-3 extension mode, PF4-7 port mode */
		                  $04:valor:=valor or $3f; // PD extension mode, PF0-5 extension mode, PF6-7 port mode */
		                  $06:valor:=valor or $ff;
                    end;
                    if addr(self.pf_out_cb)<>nil then self.pf_out_cb(valor);
                  end;
  end;
end;

procedure cpu_upd7810.ADDNC_A_X(reg:pbyte);
var
  tempb:byte;
begin
	tempb:=self.r.va.l+reg^;
	self.ZHC_ADD(tempb,self.r.va.l,false);
	self.r.va.l:=tempb;
	if not(self.r.psw.cy) then self.r.psw.sk:=true; //SKIP_NC;
end;

procedure cpu_upd7810.EQA_X_A(reg:pbyte);
var
  tempb:byte;
begin
	tempb:=reg^-self.r.va.l;
	self.ZHC_SUB(tempb,reg^,false);
  if self.r.psw.zf then self.r.psw.sk:=true; //SKIP_Z
end;

procedure cpu_upd7810.LTA_X_A(reg:pbyte);
var
  tempb:byte;
begin
  tempb:=reg^-self.r.va.l;
  self.ZHC_SUB(tempb,reg^,false);
  if self.r.psw.cy then self.r.psw.sk:=true;  //SKIP_CY
end;

procedure cpu_upd7810.GTA_X_A(reg:pbyte);
var
  tempw:word;
begin
	tempw:=reg^-self.r.va.l-1;
	self.ZHC_SUB(tempw,reg^,false);
	if not(self.r.psw.cy) then self.r.psw.sk:=true; //SKIP_NC;
end;

procedure cpu_upd7810.ONA_A_X(reg:pbyte);
begin
	if (self.r.va.l and reg^)<>0 then begin
    self.r.psw.zf:=false;
    self.r.psw.sk:=true;
  end else self.r.psw.zf:=true;
end;

procedure cpu_upd7810.SUBNB_X_A(reg:pbyte);
var
  tempb:byte;
begin
	tempb:=reg^-self.r.va.l;
	self.ZHC_SUB(tempb,reg^,false);
	reg^:=tempb;
	if not(self.r.psw.cy) then self.r.psw.sk:=true; //SKIP_NC;
end;

procedure cpu_upd7810.ORA_X_A(reg:pbyte);
begin
  reg^:=reg^ or self.r.va.l;
  self.r.psw.zf:=(reg^=0);
end;

procedure cpu_upd7810.ADDNC_X_A(reg:pbyte);
var
  tempb:byte;
begin
	tempb:=reg^+self.r.va.l;
	self.ZHC_ADD(tempb,reg^,false);
	reg^:=tempb;
	if not(self.r.psw.cy) then self.r.psw.sk:=true; //SKIP_NC;
end;

procedure cpu_upd7810.SBB_A_X(reg:pbyte);
var
  tempb:byte;
begin
	tempb:=self.r.va.l-reg^-byte(self.r.psw.cy);
	self.ZHC_SUB(tempb,self.r.va.l,self.r.psw.cy);
	self.r.va.l:=tempb;
end;

procedure cpu_upd7810.SUBNB_A_X(reg:pbyte);
var
  tempb:byte;
begin
	tempb:=self.r.va.l-reg^;
	self.ZHC_SUB(tempb,self.r.va.l,false);
	self.r.va.l:=tempb;
	if not(self.r.psw.cy) then self.r.psw.sk:=true; //SKIP_NC;
end;

procedure cpu_upd7810.SUINB_X(reg:pbyte);
var
  tempb:byte;
begin
	tempb:=reg^-self.getbyte(self.pc);
  self.pc:=self.pc+1;
	self.ZHC_SUB(tempb,reg^,false);
	reg^:=tempb;
	if not(self.r.psw.cy) then self.r.psw.sk:=true; //SKIP_NC;
end;

procedure cpu_upd7810.SBB_X_A(reg:pbyte);
var
  tempb:byte;
begin
	tempb:=reg^-self.r.va.l-byte(self.r.psw.cy);
	self.ZHC_SUB(tempb,reg^,self.r.psw.cy);
	reg^:=tempb;
end;

procedure cpu_upd7810.OFFA_A_X(reg:pbyte);
begin
	if (self.r.va.l and reg^)<>0 then self.r.psw.zf:=false
	  else begin
		  self.r.psw.zf:=true;
      self.r.psw.sk:=true;
    end;
end;

procedure cpu_upd7810.ANA_X_A(reg:pbyte);
begin
	reg^:=reg^ and self.r.va.l;
  self.r.psw.zf:=(reg^=0); //SET_Z
end;

procedure cpu_upd7810.ADINC_X(reg:pbyte);
var
  tempb:byte;
begin
  tempb:=reg^+self.getbyte(self.pc);
  self.pc:=self.pc+1;
	self.ZHC_ADD(tempb,reg^,false);
	reg^:=tempb;
	if not(self.r.psw.cy) then self.r.psw.sk:=true; //SKIP_NC;
end;

procedure cpu_upd7810.SBI_X(reg:pbyte);
var
  tempb:byte;
begin
  tempb:=reg^-self.getbyte(self.pc)-byte(self.r.psw.cy);
  self.pc:=self.pc+1;
	self.ZHC_SUB(tempb,reg^,self.r.psw.cy);
	reg^:=tempb;
end;

procedure cpu_upd7810.GTI_X(reg:pbyte);
var
  tempw:word;
begin
  tempw:=reg^-self.getbyte(self.pc)-1;
  self.pc:=self.pc+1;
	self.ZHC_SUB(tempw,reg^,false);
	if not(self.r.psw.cy) then self.r.psw.sk:=true; //SKIP_NC;
end;

procedure cpu_upd7810.LTA_A_X(reg:pbyte);
var
  tempb:byte;
begin
	tempb:=self.r.va.l-reg^;
	self.ZHC_SUB(tempb,self.r.va.l,false);
	if self.r.psw.cy then self.r.psw.sk:=true;  //SKIP_CY
end;

procedure cpu_upd7810.EQA_A_X(reg:pbyte);
var
  tempb:byte;
begin
  tempb:=self.r.va.l-reg^;
  self.ZHC_SUB(tempb,self.r.va.l,false);
  if self.r.psw.zf then self.r.psw.sk:=true; //SKIP_Z
end;

procedure cpu_upd7810.NEA_A_X(reg:pbyte);
var
  tempb:byte;
begin
  tempb:=self.r.va.l-reg^;
  self.ZHC_SUB(tempb,self.r.va.l,false);
  if not(self.r.psw.zf) then self.r.psw.sk:=true;
end;

procedure cpu_upd7810.NEA_X_A(reg:pbyte);
var
  tempb:byte;
begin
  tempb:=reg^-self.r.va.l;
  self.ZHC_SUB(tempb,reg^,false);
  if not(self.r.psw.zf) then self.r.psw.sk:=true;
end;

procedure cpu_upd7810.SUB_A_X(reg:pbyte);
var
  tempb:byte;
begin
  tempb:=self.r.va.l-reg^;
  self.ZHC_SUB(tempb,self.r.va.l,false);
  self.r.va.l:=tempb;
end;

procedure cpu_upd7810.ADC_A_X(reg:pbyte);
var
  tempb:byte;
begin
  tempb:=self.r.va.l+reg^+byte(self.r.psw.cy);
  self.ZHC_ADD(tempb,self.r.va.l,self.r.psw.cy);
  self.r.va.l:=tempb;
end;

procedure cpu_upd7810.ADD_A_X(reg:pbyte);
var
  tempb:byte;
begin
  tempb:=self.r.va.l+reg^;
  self.ZHC_ADD(tempb,self.r.va.l,false);
  self.r.va.l:=tempb;
end;

procedure cpu_upd7810.GTA_A_X(reg:pbyte);
var
  tempw:word;
begin
  tempw:=self.r.va.l-reg^-1;
  self.ZHC_SUB(tempw,self.r.va.l,false);
  if not(self.r.psw.cy) then self.r.psw.sk:=true; //SKIP_NC;
end;

procedure cpu_upd7810.ORA_A_X(reg:pbyte);
begin
  self.r.va.l:=self.r.va.l or reg^;
  self.r.psw.zf:=(self.r.va.l=0);
end;

procedure cpu_upd7810.XRA_A_X(reg:pbyte);
begin
  self.r.va.l:=self.r.va.l xor reg^;
  self.r.psw.zf:=(self.r.va.l=0);
end;

procedure cpu_upd7810.XRA_X_A(reg:pbyte);
begin
  self.r.va.l:=reg^ xor self.r.va.l;
  self.r.psw.zf:=(reg^=0);
end;

procedure cpu_upd7810.SUB_X_A(reg:pbyte);
var
  tempb:byte;
begin
  tempb:=reg^-self.r.va.l;
  self.ZHC_SUB(tempb,reg^,false);
  reg^:=tempb;
end;

procedure cpu_upd7810.ADC_X_A(reg:pbyte);
var
  tempb:byte;
begin
  tempb:=reg^+self.r.va.l+byte(self.r.psw.cy);
  self.ZHC_ADD(tempb,reg^,self.r.psw.cy);
  reg^:=tempb;
end;

procedure cpu_upd7810.ADD_X_A(reg:pbyte);
var
  tempb:byte;
begin
  tempb:=reg^+self.r.va.l;
  self.ZHC_ADD(tempb,reg^,false);
  reg^:=tempb;
end;

procedure cpu_upd7810.LTI_X(reg:pbyte);
var
  tempb:byte;
begin
	tempb:=reg^-self.getbyte(self.pc);
  self.pc:=self.pc+1;
	self.ZHC_SUB(tempb,reg^,false);
	if self.r.psw.cy then self.r.psw.sk:=true;  //SKIP_CY
end;

procedure cpu_upd7810.EQI_X(reg:pbyte);
var
  tempb:byte;
begin
  tempb:=reg^-self.getbyte(self.pc);
  self.pc:=self.pc+1;
  self.ZHC_SUB(tempb,reg^,false);
  if self.r.psw.zf then self.r.psw.sk:=true; //SKIP_Z
end;

procedure cpu_upd7810.NEI_X(reg:pbyte);
var
	tempb:byte;
begin
  tempb:=reg^-self.getbyte(self.pc);
  self.pc:=self.pc+1;
  self.ZHC_SUB(tempb,reg^,false);
  if not(self.r.psw.zf) then self.r.psw.sk:=true; //SKIP_NZ;
end;

procedure cpu_upd7810.ANI_X(reg:pbyte);
begin
  reg^:=reg^ and self.getbyte(self.pc);
  self.pc:=self.pc+1;
  self.r.psw.zf:=(reg^=0);
end;

procedure cpu_upd7810.XRI_X(reg:pbyte);
begin
  reg^:=reg^ xor self.getbyte(self.pc);
  self.pc:=self.pc+1;
  self.r.psw.zf:=(reg^=0);
end;

procedure cpu_upd7810.OFFI_X(reg:pbyte);
var
  tempb:byte;
begin
  tempb:=self.getbyte(self.pc);
  self.pc:=self.pc+1;
  if ((reg^ and tempb)=0) then self.r.psw.sk:=true;
end;

procedure cpu_upd7810.ONI_X(reg:pbyte);
var
  tempb:byte;
begin
  tempb:=self.getbyte(self.pc);
  self.pc:=self.pc+1;
  if ((reg^ and tempb)<>0) then self.r.psw.sk:=true;
end;

procedure cpu_upd7810.ORI_X(reg:pbyte);
begin
  reg^:=reg^ or self.getbyte(self.pc);
  self.pc:=self.pc+1;
  self.r.psw.zf:=(reg^=0);
end;

procedure cpu_upd7810.SUI_X(reg:pbyte);
var
  tempb:byte;
begin
  tempb:=reg^-self.getbyte(self.pc);
  self.pc:=self.pc+1;
  self.ZHC_SUB(tempb,reg^,false);
  reg^:=tempb;
end;

procedure cpu_upd7810.ACI_X(reg:pbyte);
var
  tempb:byte;
begin
  tempb:=reg^+self.getbyte(self.pc)+byte(self.r.psw.cy);
  self.pc:=self.pc+1;
  ZHC_ADD(tempb,reg^,self.r.psw.cy);
  reg^:=tempb;
end;

procedure cpu_upd7810.ADI_X(reg:pbyte);
var
  tempb:byte;
begin
  tempb:=reg^+self.getbyte(self.pc);
  self.pc:=self.pc+1;
  ZHC_ADD(tempb,reg^,false);
  reg^:=tempb;
end;

procedure cpu_upd7810.run(maximo:single);
var
  instruccion,tempb,l,h,adj:byte;
  tempw:word;
  booltemp:boolean;
begin
self.contador:=0;
while self.contador<maximo do begin
  self.ppc:=self.pc;
  instruccion:=self.getbyte(self.pc);
  self.pc:=self.pc+1;
  tempb:=self.getbyte(self.pc); //Para las instrucciones de 2bytes!!
  //clear L1 or L0??
  case instruccion of
    $34,$6f:self.r.psw.l1:=false;
    $69:self.r.psw.l0:=false;
      else begin
        self.r.psw.l1:=false;
        self.r.psw.l0:=false;
      end;
  end;
  //Calcular cuanto tarda el opcode
  if self.cpu_type=CPU_7801 then begin
    case instruccion of
      $48:self.estados_demas:=ops_7801_48[tempb].t;
      $4c:self.estados_demas:=ops_7801_4c[tempb].t;
      $4d:self.estados_demas:=ops_7801_4d[tempb].t;
      $60:self.estados_demas:=8;
      $64:self.estados_demas:=ops_7801_64[tempb].t;
      $70:self.estados_demas:=ops_7801_70[tempb].t;
      $74:self.estados_demas:=ops_7801_74[tempb].t;
        else self.estados_demas:=main_7801_ops[instruccion].t;
    end;
  end else begin
    case instruccion of
      $48:self.estados_demas:=ops_48[tempb].t;
      $4c:self.estados_demas:=ops_4c[tempb].t;
      $4d:self.estados_demas:=ops_4d[tempb].t;
      $60:self.estados_demas:=8;
      $64:self.estados_demas:=ops_64[tempb].t;
      $70:self.estados_demas:=ops_70[tempb].t;
      $74:self.estados_demas:=ops_74[tempb].t;
        else self.estados_demas:=main_ops[instruccion].t;
    end;
  end;
  //self.handle_timers_7801(self.estados_demas);
  if (self.r.psw.sk and (instruccion<>$72)) then begin
   //Skip, no hacer nada!
   if self.cpu_type=CPU_7801 then begin
    case instruccion of
      $48:self.pc:=self.pc+(ops_7801_48[tempb].s-1);
      $4c:self.pc:=self.pc+(ops_7801_4c[tempb].s-1);
      $4d:self.pc:=self.pc+(ops_7801_4d[tempb].s-1);
      $60:self.pc:=self.pc+1;
      $64:self.pc:=self.pc+(ops_7801_64[tempb].s-1);
      $70:self.pc:=self.pc+(ops_70[tempb].s-1);
      $74:self.pc:=self.pc+(ops_7801_74[tempb].s-1);
        else self.pc:=self.pc+(main_7801_ops[instruccion].s-1);
    end;
   end else begin
    case instruccion of
      $48:self.pc:=self.pc+(ops_48[tempb].s-1);
      $4c:self.pc:=self.pc+(ops_4c[tempb].s-1);
      $4d:self.pc:=self.pc+(ops_4d[tempb].s-1);
      $60:self.pc:=self.pc+1;
      $64:self.pc:=self.pc+(ops_64[tempb].s-1);
      $70:self.pc:=self.pc+(ops_70[tempb].s-1);
      $74:self.pc:=self.pc+(ops_74[tempb].s-1);
        else self.pc:=self.pc+(main_ops[instruccion].s-1);
    end;
   end;
   self.r.psw.sk:=false;
  end else begin
   case instruccion of
    $0:; //nop
    $1:if self.cpu_type=CPU_7801 then begin //HALT
        self.contador:=trunc(maximo);
        self.pc:=self.pc-1;
       end else MessageDlg('Instruccion: $1 desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
    $2:self.sp:=self.sp+1; //INX_SP
    $4:begin //LXI_S
        self.sp:=self.getbyte(self.pc) or (self.getbyte(self.pc+1) shl 8);
        self.pc:=self.pc+2;
       end;
    $5:begin //ANIW_wa
        tempw:=(self.r.va.h shl 8) or self.getbyte(self.pc);
        tempb:=self.getbyte(tempw) and self.getbyte(self.pc+1);
        self.pc:=self.pc+2;
        self.putbyte(tempw,tempb);
        self.r.psw.zf:=(tempb=0);
       end;
    $7:self.ANI_X(@self.r.va.l);  //ANI_A
    $8:if self.cpu_type=CPU_7801 then begin  //RET
        self.pc:=self.getbyte(self.sp) or (self.getbyte(self.sp+1) shl 8);
        self.sp:=self.sp+2;
       end else MessageDlg('Instruccion: $8 desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
    $a:self.r.va.l:=self.r.bc.h; //MOV_A_B
    $b:self.r.va.l:=self.r.bc.l; //MOV_A_C
    $c:self.r.va.l:=self.r.de.h; //MOV_A_D
    $d:self.r.va.l:=self.r.de.l; //MOV_A_E
    $e:self.r.va.l:=self.r.hl.h; //MOV_A_H
    $f:self.r.va.l:=self.r.hl.l; //MOV_A_L
    $10:begin //EXA
          tempw:=self.r.ea;self.r.ea:=self.r.ea2;self.r.ea2:=tempw;
	        tempw:=self.r.va.w;self.r.va.w:=self.r.va2.w;self.r.va2.w:=tempw;
        end;
    $11:begin //EXX
          tempw:=self.r.bc.w;self.r.bc.w:=self.r.bc2.w;self.r.bc2.w:=tempw;
          tempw:=self.r.de.w;self.r.de.w:=self.r.de2.w;self.r.de2.w:=tempw;
          tempw:=self.r.hl.w;self.r.hl.w:=self.r.hl2.w;self.r.hl2.w:=tempw;
        end;
    $12:self.r.bc.w:=self.r.bc.w+1; //INX_BC
    $13:self.r.bc.w:=self.r.bc.w-1; //DCX_BC
    $14:begin //LXI_B
          self.r.bc.l:=self.getbyte(self.pc);
          self.r.bc.h:=self.getbyte(self.pc+1);
          self.pc:=self.pc+2;
        end;
    $15:begin //ORIW_wa
          tempw:=(self.r.va.h shl 8) or self.getbyte(self.pc);
          tempb:=self.getbyte(tempw) or self.getbyte(self.pc+1);
          self.pc:=self.pc+2;
          self.putbyte(tempw,tempb);
          self.r.psw.zf:=(tempb=0); //SET_Z
        end;
    $16:self.XRI_X(@self.r.va.l);  //XRI_A
    $17:self.ORI_X(@self.r.va.l);  //ORI_A
    $18:if self.cpu_type=CPU_7801 then begin //RETS
          self.pc:=self.getbyte(self.sp) or (self.getbyte(self.sp+1) shl 8);
          self.sp:=self.sp+2;
          self.r.psw.sk:=true; // skip one instruction
        end else MessageDlg('Instruccion: $18 desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
    $19:if self.cpu_type=CPU_7801 then begin //STM_7801
          // Set the timer flip/fliop
          self.to_:=1;
          //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	        //m_to_func(self.to_);
	        // Reload the timer
	        self.ovc0:=8*(self.tm.l+((self.tm.h and $f) shl 8));
        end else MessageDlg('Instruccion: $19 desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
    $1a:self.r.bc.h:=self.r.va.l; //MOV_B_A
    $1b:self.r.bc.l:=self.r.va.l; //MOV_C_A
    $1c:self.r.de.h:=self.r.va.l; //MOV_D_A
    $1d:self.r.de.l:=self.r.va.l; //MOV_E_A
    $1e:self.r.hl.h:=self.r.va.l; //MOV_H_A
    $1f:self.r.hl.l:=self.r.va.l; //MOV_L_A
    $20:if self.cpu_type=CPU_7801 then begin //INRW_wa
          booltemp:=self.r.psw.cy;
	        tempw:=(self.r.va.h shl 8) or self.getbyte(self.pc);
          self.pc:=self.pc+1;
          tempb:=self.getbyte(tempw);
	        ZHC_ADD((tempb+1) and $ff,tempb,false);
	        self.putbyte(tempw,tempb+1);
	        if self.r.psw.cy then self.r.psw.sk:=true;  //SKIP_CY
	        self.r.psw.cy:=booltemp;
        end else MessageDlg('Instruccion: $20 desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
    $21:if self.cpu_type=CPU_7801 then begin //TABLE
          tempw:=self.pc+self.r.va.l+1;
	        self.r.bc.l:=self.getbyte(tempw);
          self.r.bc.h:=self.getbyte(tempw+1);
        end else MessageDlg('Instruccion: $21 desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
    $22:self.r.de.w:=self.r.de.w+1; //INX_DE
    $23:self.r.de.w:=self.r.de.w-1; //DCX_DE
    $24:begin //LXI_D_w
          self.r.de.l:=self.getbyte(self.pc);
          self.r.de.h:=self.getbyte(self.pc+1);
          self.pc:=self.pc+2;
        end;
    $25:begin //GTIW_wa
          tempw:=(self.r.va.h shl 8) or self.getbyte(self.pc);
          l:=self.getbyte(tempw);
          tempw:=l-self.getbyte(self.pc+1)-1;
          self.pc:=self.pc+2;
	        self.ZHC_SUB(tempw,l,false);
          if not(self.r.psw.cy) then self.r.psw.sk:=true; //SKIP_NC;
        end;
    $26:self.ADINC_X(@self.r.va.l);  //ADINC_A
    $27:self.GTI_X(@self.r.va.l); //GTI_A
    $28:if self.cpu_type=CPU_7801 then begin //LDAW_wa
          tempw:=(self.r.va.h shl 8) or self.getbyte(self.pc);
          self.pc:=self.pc+1;
	        self.r.va.l:=self.getbyte(tempw);
        end else MessageDlg('Instruccion: $28 desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
    $29:self.r.va.l:=self.getbyte(self.r.bc.w); //LDAX_B
    $2a:self.r.va.l:=self.getbyte(self.r.de.w); //LDAX_D
    $2b:self.r.va.l:=self.getbyte(self.r.hl.w); //LDAX_H
    $2c:begin //LDAX_Dp
          self.r.va.l:=self.getbyte(self.r.de.w);
          self.r.de.w:=self.r.de.w+1;
        end;
    $2d:begin //LDAX_Hp
          self.r.va.l:=self.getbyte(self.r.hl.w);
          self.r.hl.w:=self.r.hl.w+1;
        end;
    $2e:begin //LDAX_Dm
          self.r.va.l:=self.getbyte(self.r.de.w);
          self.r.de.w:=self.r.de.w-1;
        end;
    $2f:begin //LDAX_Hm
          self.r.va.l:=self.getbyte(self.r.hl.w);
          self.r.hl.w:=self.r.hl.w-1;
        end;
    $30:if ((self.cpu_type=CPU_7801) or (self.cpu_type=CPU_7810)) then  begin //DCRW_wa
          booltemp:=self.r.psw.cy;
          tempw:=(self.r.va.h shl 8)+self.getbyte(self.pc);
          self.pc:=self.pc+1;
          l:=self.getbyte(tempw);
          tempb:=l-1;
	        ZHC_SUB(tempb,l,false);
          self.putbyte(tempw,tempb);
	        if self.r.psw.cy then self.r.psw.sk:=true;
          if self.cpu_type=CPU_7801 then self.r.psw.cy:=booltemp;
        end else MessageDlg('Instruccion: $30 desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
    $31:begin //BLOCK
          self.putbyte(self.r.de.w,self.getbyte(self.r.hl.w));
          self.r.de.w:=self.r.de.w+1;
          self.r.hl.w:=self.r.hl.w+1;
          self.r.bc.l:=self.r.bc.l-1;
	        if (self.r.bc.l=$ff) then self.r.psw.cy:=true
	          else begin
                  self.r.psw.cy:=false;
                  self.pc:=self.pc-1;
            end;
          end;
    $32:self.r.hl.w:=self.r.hl.w+1; //INX_HL
    $33:self.r.hl.w:=self.r.hl.w-1; //DCX_HL
    $34:begin //LXI_H
           if self.r.psw.l0 then begin // overlay active?
              self.pc:=self.pc+2;
           end else begin
              self.r.hl.l:=self.getbyte(self.pc);
              self.r.hl.h:=self.getbyte(self.pc+1);
              self.pc:=self.pc+2;
	            self.r.psw.l0:=true;
           end;
        end;
    $35:begin //LTIW_wa
          tempw:=(self.r.va.h shl 8) or self.getbyte(self.pc);
          l:=self.getbyte(tempw);
          tempb:=l-self.getbyte(self.pc+1);
          self.pc:=self.pc+2;
	        self.ZHC_SUB(tempb,l,false);
	        if self.r.psw.cy then self.r.psw.sk:=true;  //SKIP_CY
        end;
    $36:begin  //SUINB_A
          self.SUI_X(@self.r.va.l);
          if not(self.r.psw.cy) then self.r.psw.sk:=true; //SKIP_NC
        end;
    $37:begin //LTI_A
          tempb:=self.r.va.l-self.getbyte(self.pc);
          self.pc:=self.pc+1;
	        self.ZHC_SUB(tempb,self.r.va.l,false);
          if self.r.psw.cy then self.r.psw.sk:=true;  //SKIP_CY
        end;
    $38:if self.cpu_type=CPU_7801 then begin //STAW_wa
           tempw:=(self.r.va.h shl 8) or self.getbyte(self.pc);
           self.pc:=self.pc+1;
           self.putbyte(tempw,self.r.va.l);
        end else MessageDlg('Instruccion: $38 desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
    $39:self.putbyte(self.r.bc.w,self.r.va.l); //STAX_B
    $3a:self.putbyte(self.r.de.w,self.r.va.l); //STAX_D
    $3b:self.putbyte(self.r.hl.w,self.r.va.l); //STAX_H
    $3c:begin  //STAX_Dp
          self.putbyte(self.r.de.w,self.r.va.l);
          self.r.de.w:=self.r.de.w+1;
        end;
    $3d:begin //STAX_Hp
          self.putbyte(self.r.hl.w,self.r.va.l);
          self.r.hl.w:=self.r.hl.w+1;
        end;
    $3e:begin  //STAX_Dm
          self.putbyte(self.r.de.w,self.r.va.l);
          self.r.de.w:=self.r.de.w-1;
        end;
    $3f:begin //STAX_Hm
          self.putbyte(self.r.hl.w,self.r.va.l);
          self.r.hl.w:=self.r.hl.w-1;
        end;
    $40:if self.cpu_type=CPU_7810 then begin //CALL
            tempw:=self.getbyte(self.pc) or (self.getbyte(self.pc+1) shl 8);
            self.pc:=self.pc+2;
            self.sp:=self.sp-1;
            self.putbyte(self.sp,self.pc shr 8);
            self.sp:=self.sp-1;
            self.putbyte(self.sp,self.pc and $ff);
            self.pc:=tempw;
          end else MessageDlg('Instruccion: $40 desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
    $41:if ((self.cpu_type=CPU_7801) or (self.cpu_type=CPU_7810)) then begin //INR_A
          booltemp:=self.r.psw.cy;
          tempb:=self.r.va.l+1;
	        ZHC_ADD(tempb,self.r.va.l,false);
          self.r.va.l:=tempb;
	        if self.r.psw.cy then self.r.psw.sk:=true;  //SKIP_CY
          if self.cpu_type=CPU_7801 then self.r.psw.cy:=booltemp;
        end else MessageDlg('Instruccion: $41 desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
    $42:if ((self.cpu_type=CPU_7801) or (self.cpu_type=CPU_7810)) then begin //INR_B
          booltemp:=self.r.psw.cy;
          tempb:=self.r.bc.h+1;
	        ZHC_ADD(tempb,self.r.bc.h,false);
          self.r.bc.h:=tempb;
	        if self.r.psw.cy then self.r.psw.sk:=true;  //SKIP_CY
          if self.cpu_type=CPU_7801 then self.r.psw.cy:=booltemp;
        end else MessageDlg('Instruccion: $42 desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
    $43:if ((self.cpu_type=CPU_7801) or (self.cpu_type=CPU_7810)) then begin //INR_C
          booltemp:=self.r.psw.cy;
          tempb:=self.r.bc.l+1;
	        ZHC_ADD(tempb,self.r.bc.l,false);
          self.r.bc.l:=tempb;
	        if self.r.psw.cy then self.r.psw.sk:=true;  //SKIP_CY
          if self.cpu_type=CPU_7801 then self.r.psw.cy:=booltemp;
        end else MessageDlg('Instruccion: $43 desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
    $44:if self.cpu_type=CPU_7810 then begin //LXI_EA
          self.r.ea:=self.getbyte(self.pc) or (self.getbyte(self.pc+1) shl 8);
          self.pc:=self.pc+2;
        end else if self.cpu_type=CPU_7801 then begin //CALL_w
            tempw:=self.getbyte(self.pc) or (self.getbyte(self.pc+1) shl 8);
            self.pc:=self.pc+2;
            self.sp:=self.sp-1;
            self.putbyte(self.sp,self.pc shr 8);
            self.sp:=self.sp-1;
            self.putbyte(self.sp,self.pc and $ff);
            self.pc:=tempw;
        end else MessageDlg('Instruccion: $44 desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
    $45:begin  //ONIW_wa
          tempw:=(self.r.va.h shl 8) or self.getbyte(self.pc);
          tempb:=self.getbyte(self.pc+1);
          self.pc:=self.pc+2;
	        self.r.psw.sk:=(self.getbyte(tempw) and tempb)<>0;
        end;
    $46:self.ADI_X(@self.r.va.l); //ADI_A
    $47:self.ONI_X(@self.r.va.l); //ONI_A
    $48:self.opcode_48; //opc_48
    $49:begin //MVIX_BC_xx
          tempb:=self.getbyte(self.pc);
          self.pc:=self.pc+1;
          self.putbyte(self.r.bc.w,tempb);
        end;
    $4a:begin //MVIX_DE_xx
          tempb:=self.getbyte(self.pc);
          self.pc:=self.pc+1;
          self.putbyte(self.r.de.w,tempb);
        end;
    $4b:begin  //MVIX_HL_xx
          tempb:=self.getbyte(self.pc);
          self.pc:=self.pc+1;
          self.putbyte(self.r.hl.w,tempb);
        end;
    $4c:self.opcode_4c; //opc_4c
    $4d:self.opcode_4d; //opc_4d
    $4e,$4f:begin //JRE
          tempb:=self.getbyte(self.pc);
          self.pc:=self.pc+1;
          if (instruccion and 1)<>0 then self.pc:=self.pc-(256-tempb)
	          else self.pc:=self.pc+tempb;
        end;
    $50:if self.cpu_type=CPU_7810 then begin //EHX
          tempw:=self.r.hl.w;
          self.r.hl.w:=self.r.hl2.w;
          self.r.hl2.w:=tempw;
        end else MessageDlg('Instruccion: $50 desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
    $51:if ((self.cpu_type=CPU_7810) or (self.cpu_type=CPU_7801)) then begin //DCR_A
          booltemp:=self.r.psw.cy;
          tempb:=self.r.va.l-1;
	        ZHC_SUB(tempb,self.r.va.l,false);
	        self.r.va.l:=tempb;
          if self.r.psw.cy then self.r.psw.sk:=true;  //SKIP_CY
          if self.cpu_type=CPU_7801 then self.r.psw.cy:=booltemp;
        end else MessageDlg('Instruccion: $51 desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
    $52:if ((self.cpu_type=CPU_7810) or (self.cpu_type=CPU_7801)) then begin //DCR_B
          booltemp:=self.r.psw.cy;
          tempb:=self.r.bc.h-1;
	        ZHC_SUB(tempb,self.r.bc.h,false);
	        self.r.bc.h:=tempb;
          if self.r.psw.cy then self.r.psw.sk:=true;  //SKIP_CY
          if self.cpu_type=CPU_7801 then self.r.psw.cy:=booltemp;
        end else MessageDlg('Instruccion: $52 desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
    $53:if ((self.cpu_type=CPU_7810) or (self.cpu_type=CPU_7801)) then begin //DCR_C
          booltemp:=self.r.psw.cy;
          tempb:=self.r.bc.l-1;
	        ZHC_SUB(tempb,self.r.bc.l,false);
	        self.r.bc.l:=tempb;
          if self.r.psw.cy then self.r.psw.sk:=true;  //SKIP_CY
          if self.cpu_type=CPU_7801 then self.r.psw.cy:=booltemp;
        end else MessageDlg('Instruccion: $53 desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
    $54:self.pc:=self.getbyte(self.pc) or (self.getbyte(self.pc+1) shl 8); //jmp_w
    $55:begin //OFFIW_wa
          tempw:=(self.r.va.h shl 8) or self.getbyte(self.pc);
          tempb:=self.getbyte(self.pc+1);
          self.pc:=self.pc+2;
          self.r.psw.sk:=(self.getbyte(tempw) and tempb)=0;
        end;
    $56:self.ACI_X(@self.r.va.l);  //ACI_A
    $57:self.OFFI_x(@self.r.va.l); //OFFI_A
    $58:begin //BIT_0_wa
          tempw:=(self.r.va.h shl 8) or self.getbyte(self.pc);
          self.pc:=self.pc+1;
          tempb:=self.getbyte(tempw);
          self.r.psw.sk:=(tempb and $1)<>0;
        end;
    $59:begin //BIT_1_wa
          tempw:=(self.r.va.h shl 8) or self.getbyte(self.pc);
          self.pc:=self.pc+1;
          tempb:=self.getbyte(tempw);
          self.r.psw.sk:=(tempb and $2)<>0;
        end;
    $5a:begin //BIT_2_wa
          tempw:=(self.r.va.h shl 8) or self.getbyte(self.pc);
          self.pc:=self.pc+1;
          tempb:=self.getbyte(tempw);
          self.r.psw.sk:=(tempb and $4)<>0;
        end;
    $5b:begin //BIT_3_wa
          tempw:=(self.r.va.h shl 8) or self.getbyte(self.pc);
          self.pc:=self.pc+1;
          tempb:=self.getbyte(tempw);
          self.r.psw.sk:=(tempb and $8)<>0;
        end;
    $5c:begin //BIT_4_wa
          tempw:=(self.r.va.h shl 8) or self.getbyte(self.pc);
          self.pc:=self.pc+1;
          tempb:=self.getbyte(tempw);
          self.r.psw.sk:=(tempb and $10)<>0;
        end;
    $5d:begin //BIT_5_wa
          tempw:=(self.r.va.h shl 8) or self.getbyte(self.pc);
          self.pc:=self.pc+1;
          tempb:=self.getbyte(tempw);
          self.r.psw.sk:=(tempb and $20)<>0;
        end;
    $5e:begin //BIT_6_wa
          tempw:=(self.r.va.h shl 8) or self.getbyte(self.pc);
          self.pc:=self.pc+1;
          tempb:=self.getbyte(tempw);
          self.r.psw.sk:=(tempb and $40)<>0;
        end;
    $5f:begin //BIT_7_wa
          tempw:=(self.r.va.h shl 8) or self.getbyte(self.pc);
          self.pc:=self.pc+1;
          tempb:=self.getbyte(tempw);
          self.r.psw.sk:=(tempb and $80)<>0;
        end;
    $60:self.opcode_60;  //opc_60
    $61:begin //DAA
          l:=self.r.va.l and $0f;
          h:=self.r.va.l shr 4;
          adj:=0;
          booltemp:=self.r.psw.cy;
	        if not(self.r.psw.hc) then begin
		        if (l<10) then begin
			        if not((h<10) and not(self.r.psw.cy)) then adj:=$60;
		        end else begin
			        if ((h<9) and not(self.r.psw.cy)) then adj:=$06
			          else adj:=$66;
		        end;
          end else if (l<3) then begin
		        if ((h<10) and not(self.r.psw.cy)) then adj:=$06
		          else adj:=$66;
	        end;
	        tempb:=self.r.va.l+adj;
	        self.ZHC_ADD(tempb,self.r.va.l,self.r.psw.cy);
	        self.r.psw.cy:=self.r.psw.cy or booltemp;
	        self.r.va.l:=tempb;
        end;
    $62:begin //RETI
          self.pc:=self.getbyte(self.sp) or (self.getbyte(self.sp+1) shl 8);
          self.poner_band(self.getbyte(self.sp+2));
          self.sp:=self.sp+3;
        end;
    $63:if self.cpu_type=CPU_7801 then begin //CALB
          self.sp:=self.sp-1;
	        self.putbyte(self.sp,self.pc shr 8);
          self.sp:=self.sp-1;
	        self.putbyte(self.sp,self.pc and $ff);
	        self.pc:=self.r.bc.w;
        end else MessageDlg('Instruccion: $63 desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
    $64:self.opcode_64;  //opc_64
    $65:begin //NEIW_wa
            tempw:=(self.r.va.h shl 8) or self.getbyte(self.pc);
            l:=self.getbyte(tempw);
            tempb:=l-self.getbyte(self.pc+1);
            self.pc:=self.pc+2;
	          self.ZHC_SUB(tempb,l,false);
	          if not(self.r.psw.zf) then self.r.psw.sk:=true; //SKIP_NZ
        end;
    $66:self.SUI_X(@self.r.va.l); //SUI_A
    $67:self.NEI_X(@self.r.va.l); //NEI_A
    $68:begin //MVI_V_xx
         self.r.va.h:=self.getbyte(self.pc);
         self.pc:=self.pc+1;
        end;
    $69:if self.r.psw.l1 then begin //MVI_A_xx
            self.pc:=self.pc+1;
        end else begin
            self.r.va.l:=self.getbyte(self.pc);
            self.pc:=self.pc+1;
	          self.r.psw.l1:=true;
        end;
    $6a:begin //MVI_B_xx
          self.r.bc.h:=self.getbyte(self.pc);
          self.pc:=self.pc+1;
        end;
    $6b:begin //MVI_C_xx
          self.r.bc.l:=self.getbyte(self.pc);
          self.pc:=self.pc+1;
        end;
    $6c:begin //MVI_D_xx
          self.r.de.h:=self.getbyte(self.pc);
          self.pc:=self.pc+1;
        end;
    $6d:begin //MVI_E_xx
          self.r.de.l:=self.getbyte(self.pc);
          self.pc:=self.pc+1;
        end;
    $6e:begin //MVI_H_xx
          self.r.hl.h:=self.getbyte(self.pc);
          self.pc:=self.pc+1;
        end;
    $6f:if self.r.psw.l0 then begin //MVI_L_xx
            self.pc:=self.pc+1;
        end else begin
            self.r.hl.l:=self.getbyte(self.pc);
            self.pc:=self.pc+1;
	          self.r.psw.l0:=true;
        end;
    $70:self.opcode_70;  //opc_70
    $71:begin  //MVIW_wa_xx
          tempw:=(self.r.va.h shl 8) or self.getbyte(self.pc);
          tempb:=self.getbyte(self.pc+1);
          self.pc:=self.pc+2;
          self.putbyte(tempw,tempb);
        end;
    $73:if self.cpu_type=CPU_7801 then begin //JB
          self.pc:=self.r.bc.w;
        end else MessageDlg('Instruccion: $73 desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
    $74:self.opcode_74;  //opc_74
    $75:begin //EQIW_wa
          tempw:=(self.r.va.h shl 8) or self.getbyte(self.pc);
          l:=self.getbyte(tempw);
          tempb:=l-self.getbyte(self.pc+1);
          self.pc:=self.pc+2;
          self.ZHC_SUB(tempb,l,false);
          if self.r.psw.zf then self.r.psw.sk:=true; //SKIP_Z
        end;
    $76:self.SBI_X(@self.r.va.l); //SBI_A_xx
    $77:self.EQI_X(@self.r.va.l); //EQI_A
    $78..$7f:begin //CALF
          tempw:=(($8+(instruccion and $7)) shl 8) or self.getbyte(self.pc);
	        self.pc:=self.pc+1;
          self.sp:=self.sp-1;
          self.putbyte(self.sp,self.pc shr 8);
          self.sp:=self.sp-1;
          self.putbyte(self.sp,self.pc and $ff);
	        self.pc:=tempw;
        end;
    $80..$9f:begin  //CALT
                if self.cpu_type=CPU_7810 then tempw:=$80+2*(instruccion and $1f)
                  else tempw:=$80+2*(instruccion and $3f);
                self.sp:=self.sp-1;
                self.putbyte(self.sp,self.pc shr 8);
                self.sp:=self.sp-1;
                self.putbyte(self.sp,self.pc and $ff);
                self.pc:=self.getbyte(tempw) or (self.getbyte(tempw+1) shl 8);
             end;
    $a0..$bf:if self.cpu_type=CPU_7810 then begin
                case instruccion of
                    $a0:begin //POP_VA
                            self.r.va.l:=self.getbyte(self.sp);
                            self.r.va.h:=self.getbyte(self.sp+1);
                            self.sp:=self.sp+2;
                        end;
                    $a1:begin //POP_BC
                            self.r.bc.l:=self.getbyte(self.sp);
                            self.r.bc.h:=self.getbyte(self.sp+1);
                            self.sp:=self.sp+2;
                        end;
                    $a2:begin //POP_DE
                            self.r.de.l:=self.getbyte(self.sp);
                            self.r.de.h:=self.getbyte(self.sp+1);
                            self.sp:=self.sp+2;
                        end;
                    $a3:begin //POP_HL
                            self.r.hl.l:=self.getbyte(self.sp);
                            self.r.hl.h:=self.getbyte(self.sp+1);
                            self.sp:=self.sp+2;
                        end;
                    $a4:begin //POP_EA
                            self.r.ea:=self.getbyte(self.sp) or (self.getbyte(self.sp+1) shl 8);
                            self.sp:=self.sp+2;
                        end;
                    $a6:self.r.ea:=self.r.de.w; //DMOV_EA_DE
                    $aa:self.iff_pending:=true; //EI
                    $b0:begin //PUSH_VA
                            self.sp:=self.sp-1;
                            self.putbyte(self.sp,self.r.va.h);
                            self.sp:=self.sp-1;
                            self.putbyte(self.sp,self.r.va.l);
                        end;
                    $b1:begin //PUSH_BC
                            self.sp:=self.sp-1;
                            self.putbyte(self.sp,self.r.bc.h);
                            self.sp:=self.sp-1;
                            self.putbyte(self.sp,self.r.bc.l);
                        end;
                    $b2:begin //PUSH_DE
                            self.sp:=self.sp-1;
                            self.putbyte(self.sp,self.r.de.h);
                            self.sp:=self.sp-1;
                            self.putbyte(self.sp,self.r.de.l);
                        end;
                    $b3:begin //PUSH_HL
                            self.sp:=self.sp-1;
                            self.putbyte(self.sp,self.r.hl.h);
                            self.sp:=self.sp-1;
                            self.putbyte(self.sp,self.r.hl.l);
                        end;
                    $b4:begin //PUSH_EA
                            self.sp:=self.sp-1;
                            self.putbyte(self.sp,self.r.ea shr 8);
                            self.sp:=self.sp-1;
                            self.putbyte(self.sp,self.r.ea and $ff);
                        end;
                    $b5:self.r.bc.w:=self.r.ea; //DMOV_BC_EA
                    $b6:self.r.de.w:=self.r.ea; //DMOV_DE_EA
                    $b7:self.r.hl.w:=self.r.ea; //DMOV_HL_EA
                    $b8:begin //RET
                            self.pc:=self.getbyte(self.sp) or (self.getbyte(self.sp+1) shl 8);
                            self.sp:=self.sp+2;
                        end;
                    $ba:begin  //DI
                            self.iff:=false;
                            self.iff_pending:=false;
                        end;
                    else MessageDlg('Instruccion CPU 7810: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
                end;
            end else begin //CALT 7801
                        tempw:=$80+2*(instruccion and $3f);
                        self.sp:=self.sp-1;
                        self.putbyte(self.sp,self.pc shr 8);
                        self.sp:=self.sp-1;
                        self.putbyte(self.sp,self.pc and $ff);
	                      self.pc:=self.getbyte(tempw) or (self.getbyte(tempw+1) shl 8);
                      end;
    $c0..$ff:self.pc:=self.pc+(shortint(instruccion shl 2) shr 2); //JR
      else MessageDlg('Instruccion: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
   end;
  end;
  if self.cpu_type=CPU_7810 then begin
     self.handle_timers_7810(self.estados_demas);
     self.take_irq_7810;
  end else if self.cpu_type=CPU_7801 then begin
     self.handle_timers_7801(self.estados_demas);
     self.take_irq_7801;
  end;
  self.iff:=self.iff_pending;
  self.contador:=self.contador+self.estados_demas;
  timers.update(self.estados_demas,self.numero_cpu);
end;
end;

procedure cpu_upd7810.opcode_48;
var
  instruccion,tempb,tempb2:byte;
  tempw:word;
begin
  instruccion:=self.getbyte(self.pc);
  self.pc:=self.pc+1;
  case instruccion of
      $0:if self.cpu_type=CPU_7801 then begin //SKIT_F0
            if (self.irr and INTF0)<>0 then self.r.psw.sk:=true;
	          self.irr:=self.irr and not(INTF0);
         end else MessageDlg('Instruccion 48: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
      $1:if self.cpu_type=CPU_7801 then begin //SKIT_FT0
            if (self.irr and INTFT0)<>0 then self.r.psw.sk:=true;
	          self.irr:=self.irr and not(INTFT0);
         end else MessageDlg('Instruccion 48: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
      $2:if self.cpu_type=CPU_7801 then begin //SKIT_F1
            if (self.irr and INTF1)<>0 then self.r.psw.sk:=true;
	          self.irr:=self.irr and not(INTF1);
         end else MessageDlg('Instruccion 48: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
      $3:if self.cpu_type=CPU_7801 then begin //SKIT_F2
            if (self.irr and INTF2)<>0 then self.r.psw.sk:=true;
	          self.irr:=self.irr and not(INTF2);
         end else MessageDlg('Instruccion 48: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
      $4:if self.cpu_type=CPU_7801 then begin //SKIT_FST
            if (self.irr and INTFST)<>0 then self.r.psw.sk:=true;
	          self.irr:=self.irr and not(INTFST);
         end else MessageDlg('Instruccion 48: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
      $7:if self.cpu_type=CPU_7810 then begin //SLLC_C
            self.r.psw.cy:=(self.r.bc.l and $80)<>0;
            self.r.bc.l:=self.r.bc.l shl 1;
	          if self.r.psw.cy then self.r.psw.sk:=true; //SKIP_CY;
         end else MessageDlg('Instruccion 48: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
      $a:if self.r.psw.cy then self.r.psw.sk:=true; //SK_CY
      $c:if self.r.psw.zf then self.r.psw.sk:=true; //SK_Z
      $e:if self.cpu_type=CPU_7801 then begin //PUSH_VA
             self.sp:=self.sp-1;
             self.putbyte(self.sp,self.r.va.h);
             self.sp:=self.sp-1;
             self.putbyte(self.sp,self.r.va.l);
         end else MessageDlg('Instruccion 48: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
      $f:if self.cpu_type=CPU_7801 then begin //POP_VA
             self.r.va.l:=self.getbyte(self.sp);
             self.r.va.h:=self.getbyte(self.sp+1);
             self.sp:=self.sp+2;
         end else MessageDlg('Instruccion 48: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
      $1a:if not(self.r.psw.cy) then self.r.psw.sk:=true; //SKN_CY
      $1c:if not(self.r.psw.zf) then self.r.psw.sk:=true; //SKN_Z
      $1e:if self.cpu_type=CPU_7801 then begin //PUSH_BC
            self.sp:=self.sp-1;
            self.putbyte(self.sp,self.r.bc.h);
            self.sp:=self.sp-1;
            self.putbyte(self.sp,self.r.bc.l);
          end else MessageDlg('Instruccion 48: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
      $1f:if self.cpu_type=CPU_7801 then begin //POP_BC
             self.r.bc.l:=self.getbyte(self.sp);
             self.r.bc.h:=self.getbyte(self.sp+1);
             self.sp:=self.sp+2;
         end else MessageDlg('Instruccion 48: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
      $20:if self.cpu_type=CPU_7801 then self.iff_pending:=true //EI
            else MessageDlg('Instruccion 48: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
      $21:if self.cpu_type=CPU_7810 then begin //SLR_A
            self.r.psw.cy:=(self.r.va.l and 1)<>0;
	          self.r.va.l:=self.r.va.l shr 1;
          end else MessageDlg('Instruccion 48: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
      $24:if self.cpu_type=CPU_7801 then begin  //DI
            self.iff:=false;
            self.iff_pending:=false;
          end else MessageDlg('Instruccion 48: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
      $2a:self.r.psw.cy:=false; //CLC
      $2b:self.r.psw.cy:=true; //STC
      $2e:if self.cpu_type=CPU_7801 then begin //PUSH_DE
            self.sp:=self.sp-1;
            self.putbyte(self.sp,self.r.de.h);
            self.sp:=self.sp-1;
            self.putbyte(self.sp,self.r.de.l);
          end else MessageDlg('Instruccion 48: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
      $2f:if self.cpu_type=CPU_7810 then self.r.ea:=self.r.va.l*self.r.bc.l //MUL_C
            else if self.cpu_type=CPU_7801 then begin //POP_DE
                    self.r.de.l:=self.getbyte(self.sp);
                    self.r.de.h:=self.getbyte(self.sp+1);
                    self.sp:=self.sp+2;
                 end else MessageDlg('Instruccion 48: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
      $30:if self.cpu_type=CPU_7801 then begin //RLL_A
            tempb:=byte(self.r.psw.cy);
            self.r.psw.cy:=(self.r.va.l and $80)<>0;
	          self.r.va.l:=(self.r.va.l shl 1) or tempb;
          end else MessageDlg('Instruccion 48: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
      $31:begin //RLR_A
            tempb:=byte(self.r.psw.cy) shl 7;
            self.r.psw.cy:=(self.r.va.l and 1)<>0;
	          self.r.va.l:=(self.r.va.l shr 1) or tempb;
          end;
      $32:if self.cpu_type=CPU_7801 then begin //RLL_C
            tempb:=byte(self.r.psw.cy);
            self.r.psw.cy:=(self.r.bc.l and $80)<>0;
	          self.r.bc.l:=(self.r.bc.l shl 1) or tempb;
          end else MessageDlg('Instruccion 48: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
      $33:begin //RLR_C
            tempb:=byte(self.r.psw.cy) shl 7;
            self.r.psw.cy:=(self.r.bc.l and 1)<>0;
	          self.r.bc.l:=(self.r.bc.l shr 1) or tempb;
          end;
      $34:if self.cpu_type=CPU_7801 then begin //SLL_A
            self.r.psw.cy:=(self.r.va.l and $80)<>0;
            self.r.va.l:=self.r.va.l shl 1;
         end else MessageDlg('Instruccion 48: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
      $35:if self.cpu_type=CPU_7810 then begin //RLL_A
            tempb:=byte(self.r.psw.cy);
            self.r.psw.cy:=(self.r.va.l and $80)<>0;
	          self.r.va.l:=(self.r.va.l shl 1) or tempb;
          end else if self.cpu_type=CPU_7801 then begin //SLR_A
            self.r.psw.cy:=(self.r.va.l and 1)<>0;
	          self.r.va.l:=self.r.va.l shr 1;
          end else MessageDlg('Instruccion 48: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
      $36:if self.cpu_type=CPU_7801 then begin //SLL_C
            self.r.psw.cy:=(self.r.bc.l and $80)<>0;
	          self.r.bc.l:=self.r.bc.l shl 1;
          end else MessageDlg('Instruccion 48: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
      $37:if self.cpu_type=CPU_7801 then begin //SLR_C
            self.r.psw.cy:=(self.r.bc.l and $1)<>0;
	          self.r.bc.l:=self.r.bc.l shr 1;
          end else MessageDlg('Instruccion 48: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
      $38:begin //RLD
            tempb:=self.getbyte(self.r.hl.w);
            tempb2:=(tempb shl 4) or (self.r.va.l and $f);
            self.r.va.l:=(self.r.va.l and $f0) or (tempb shr 4);
            self.putbyte(self.r.hl.w,tempb2);
          end;
      $39:begin //RRD
            tempb:=self.getbyte(self.r.hl.w);
	          tempb2:=(self.r.va.l shl 4) or (tempb shr 4);
	          self.r.va.l:=(self.r.va.l and $f0) or (tempb and $0f);
	          self.putbyte(self.r.hl.w,tempb2);
          end;
      $3a:if self.cpu_type=CPU_7810 then self.r.va.l:=not(self.r.va.l)+1  //NEGA
            else MessageDlg('Instruccion 48: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
      $3e:if self.cpu_type=CPU_7801 then begin //PUSH_HL
            self.sp:=self.sp-1;
            self.putbyte(self.sp,self.r.hl.h);
            self.sp:=self.sp-1;
            self.putbyte(self.sp,self.r.hl.l);
          end else MessageDlg('Instruccion 48: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
      $3f:if self.cpu_type=CPU_7801 then begin //POP_HL
             self.r.hl.l:=self.getbyte(self.sp);
             self.r.hl.h:=self.getbyte(self.sp+1);
             self.sp:=self.sp+2;
         end else MessageDlg('Instruccion 48: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
      $40..$ff:if self.cpu_type=CPU_7810 then begin
                  case instruccion of
                    $82:self.r.ea:=self.getbyte(self.r.de.w) or (self.getbyte(self.r.de.w+1) shl 8); //LDEAX_D
                    $83:self.r.ea:=self.getbyte(self.r.hl.w) or (self.getbyte(self.r.hl.w+1) shl 8); //LDEAX_H
                    $8c:begin //LDEAX_H_A
                          tempw:=self.r.hl.w+self.r.va.l;
                          self.r.ea:=self.getbyte(tempw) or (self.getbyte(tempw+1) shl 8);
                        end;
                    $93:begin  //STEAX_H
                          self.putbyte(self.r.hl.w,self.r.ea and $ff);
                          self.putbyte(self.r.hl.w+1,self.r.ea shr 8);
                        end;
                    $94:begin  //STEAX_Dp
                          self.putbyte(self.r.de.w,self.r.ea and $ff);
                          self.putbyte(self.r.de.w+1,self.r.ea shr 8);
                          self.r.de.w:=self.r.de.w+2;
                        end;
                    else MessageDlg('Instruccion 48: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
                  end
                end else MessageDlg('Instruccion 48: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
      else MessageDlg('Instruccion 48: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
  end;
end;

procedure cpu_upd7810.opcode_4c;
var
  instruccion:byte;
begin
  instruccion:=self.getbyte(self.pc);
  self.pc:=self.pc+1;
  case instruccion of
     $c0:self.r.va.l:=self.read_port(UPD7810_PORTA); //MOV_A_PA
     $c1:self.r.va.l:=self.read_port(UPD7810_PORTB); //MOV_A_PB
     $c2:self.r.va.l:=self.read_port(UPD7810_PORTC); //MOV_A_PC
     $c3:if self.cpu_type=CPU_7810 then self.r.va.l:=self.read_port(UPD7810_PORTD) //MOV_A_PD
            else MessageDlg('Instruccion 4C: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
     $c5:if self.cpu_type=CPU_7810 then self.r.va.l:=self.read_port(UPD7810_PORTF) //MOV_A_PF
            else MessageDlg('Instruccion 4C: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
     $e0:if self.cpu_type=CPU_7810 then self.r.va.l:=self.cr[0] //MOV_A_CR0
            else MessageDlg('Instruccion 4C: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
     $e1:if self.cpu_type=CPU_7810 then self.r.va.l:=self.cr[1] //MOV_A_CR1
            else MessageDlg('Instruccion 4C: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
     $e2:if self.cpu_type=CPU_7810 then self.r.va.l:=self.cr[2] //MOV_A_CR2
            else MessageDlg('Instruccion 4C: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
     $e3:if self.cpu_type=CPU_7810 then self.r.va.l:=self.cr[3] //MOV_A_CR3
            else MessageDlg('Instruccion 4C: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
      else MessageDlg('Instruccion 4C: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
  end;
end;

procedure cpu_upd7810.opcode_4d;
var
  instruccion:byte;
begin
  instruccion:=self.getbyte(self.pc);
  self.pc:=self.pc+1;
  case instruccion of
    $c0:self.write_port(UPD7810_PORTA,self.r.va.l); //MOV_PA_A
    $c1:self.write_port(UPD7810_PORTB,self.r.va.l); //MOV_PB_A
    $c2:self.write_port(UPD7810_PORTC,self.r.va.l); //MOV_PC_A
    $c3:if self.cpu_type=CPU_7801 then self.mkl:=self.r.va.l //MOV_MKL_A
          else MessageDlg('Instruccion 4D: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
    $c4:if self.cpu_type=CPU_7801 then begin //MOV_MB_A
          if self.mb<>self.r.va.l then begin
            self.mb:=self.r.va.l;
            self.write_port(UPD7810_PORTB,self.pb_out);
          end;
        end else MessageDlg('Instruccion 4D: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
    $c5:if self.cpu_type=CPU_7801 then begin //MOV_MC_A
          self.mc:=$84 or (self.r.va.l and $3);
        end else MessageDlg('Instruccion 4D: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
    $c6:if self.cpu_type=CPU_7801 then self.tm.l:=self.r.va.l //MOV_TM0_A
          else MessageDlg('Instruccion 4D: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
    $c7:if self.cpu_type=CPU_7801 then self.tm.h:=self.r.va.l //MOV_TM1_A
          else MessageDlg('Instruccion 4D: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
    $d0:if self.cpu_type=CPU_7810 then self.mm:=self.r.va.l //MOV_MM_A
          else MessageDlg('Instruccion 4D: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
    $d2:if self.cpu_type=CPU_7810 then begin //MOV_MA_A
          if self.ma<>self.r.va.l then begin
            self.ma:=self.r.va.l;
            self.write_port(UPD7810_PORTA,self.pa_out);
          end;
        end else MessageDlg('Instruccion 4D: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
    $d3:if self.cpu_type=CPU_7810 then begin //MOV_MB_A
          if self.mb<>self.r.va.l then begin
            self.mb:=self.r.va.l;
            self.write_port(UPD7810_PORTB,self.pb_out);
          end;
          end else MessageDlg('Instruccion 4D: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
    $d4:if self.cpu_type=CPU_7810 then begin //MOV_MC_A
          if self.mc<>self.r.va.l then begin
            self.mc:=self.r.va.l;
            self.write_port(UPD7810_PORTC,self.pc_out);
          end;
          end else MessageDlg('Instruccion 4D: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
    $d7:if self.cpu_type=CPU_7810 then begin  //MOV_MF_A
           if self.mf<>self.r.va.l then begin
            self.mf:=self.r.va.l;
            self.write_port(UPD7810_PORTF,self.pf_out);
           end;
          end else MessageDlg('Instruccion 4D: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
    else MessageDlg('Instruccion 4D: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
  end;
end;
procedure cpu_upd7810.opcode_60;
var
  instruccion:byte;
begin
  instruccion:=self.getbyte(self.pc);
  self.pc:=self.pc+1;
  case instruccion of
      $08:self.ANA_X_A(@self.r.va.h);
      $09:self.ANA_X_A(@self.r.va.l);
      $0a:self.ANA_X_A(@self.r.bc.h);
      $0b:self.ANA_X_A(@self.r.bc.l);
      $0c:self.ANA_X_A(@self.r.de.h);
      $0d:self.ANA_X_A(@self.r.de.l);
      $0e:self.ANA_X_A(@self.r.hl.h);
      $0f:self.ANA_X_A(@self.r.hl.l);
      $10:self.XRA_X_A(@self.r.va.h);
      $11,$91:self.XRA_X_A(@self.r.va.l);
      $12:self.XRA_X_A(@self.r.bc.h);
      $13:self.XRA_X_A(@self.r.bc.l);
      $14:self.XRA_X_A(@self.r.de.h);
      $15:self.XRA_X_A(@self.r.de.l);
      $16:self.XRA_X_A(@self.r.hl.h);
      $17:self.XRA_X_A(@self.r.hl.l);
      $18:self.ORA_X_A(@self.r.va.h);
      $19:self.ORA_X_A(@self.r.va.l);
      $1a:self.ORA_X_A(@self.r.bc.h);
      $1b:self.ORA_X_A(@self.r.bc.l);
      $1c:self.ORA_X_A(@self.r.de.h);
      $1d:self.ORA_X_A(@self.r.de.l);
      $1e:self.ORA_X_A(@self.r.hl.h);
      $1f:self.ORA_X_A(@self.r.hl.l);
      $20:self.ADDNC_X_A(@self.r.va.h);
      $21:self.ADDNC_X_A(@self.r.va.l);
      $22:self.ADDNC_X_A(@self.r.bc.h);
      $23:self.ADDNC_X_A(@self.r.bc.l);
      $24:self.ADDNC_X_A(@self.r.de.h);
      $25:self.ADDNC_X_A(@self.r.de.l);
      $26:self.ADDNC_X_A(@self.r.hl.h);
      $27:self.ADDNC_X_A(@self.r.hl.l);
      $28:self.GTA_X_A(@self.r.va.h);
      $29:self.GTA_X_A(@self.r.va.l);
      $2a:self.GTA_X_A(@self.r.bc.h);
      $2b:self.GTA_X_A(@self.r.bc.l);
      $2c:self.GTA_X_A(@self.r.de.h);
      $2d:self.GTA_X_A(@self.r.de.l);
      $2e:self.GTA_X_A(@self.r.hl.h);
      $2f:self.GTA_X_A(@self.r.hl.l);
      $30:self.SUBNB_X_A(@self.r.va.h);
      $31:self.SUBNB_X_A(@self.r.va.l);
      $32:self.SUBNB_X_A(@self.r.bc.h);
      $33:self.SUBNB_X_A(@self.r.bc.l);
      $34:self.SUBNB_X_A(@self.r.de.h);
      $35:self.SUBNB_X_A(@self.r.de.l);
      $36:self.SUBNB_X_A(@self.r.hl.h);
      $37:self.SUBNB_X_A(@self.r.hl.l);
      $38:self.LTA_X_A(@self.r.va.h);
      $39:self.LTA_X_A(@self.r.va.l);
      $3a:self.LTA_X_A(@self.r.bc.h);
      $3b:self.LTA_X_A(@self.r.bc.l);
      $3c:self.LTA_X_A(@self.r.de.h);
      $3d:self.LTA_X_A(@self.r.de.l);
      $3e:self.LTA_X_A(@self.r.hl.h);
      $3f:self.LTA_X_A(@self.r.hl.l);
      $40:self.ADD_X_A(@self.r.va.h);   //ADD_V_A
      $41,$c1:self.ADD_X_A(@self.r.va.l);  //ADD_A_A
      $42:self.ADD_X_A(@self.r.bc.h);  //ADD_B_A
      $43:self.ADD_X_A(@self.r.bc.l);  //ADD_C_A
      $44:self.ADD_X_A(@self.r.de.h);  //ADD_D_A
      $45:self.ADD_X_A(@self.r.de.l);  //ADD_E_A
      $46:self.ADD_X_A(@self.r.hl.h); //ADD_H_A
      $47:self.ADD_X_A(@self.r.hl.l); //ADD_L_A
      $50:self.ADC_X_A(@self.r.va.h);
      $51:self.ADC_X_A(@self.r.va.l);
      $52:self.ADC_X_A(@self.r.bc.h);
      $53:self.ADC_X_A(@self.r.bc.l);
      $54:self.ADC_X_A(@self.r.de.h);
      $55:self.ADC_X_A(@self.r.de.l);
      $56:self.ADC_X_A(@self.r.hl.h);
      $57:self.ADC_X_A(@self.r.hl.l);
      $60:self.SUB_X_A(@self.r.va.h); //SUB_V_A
      $61:self.SUB_X_A(@self.r.va.l); //SUB_A_A
      $62:self.SUB_X_A(@self.r.bc.h); //SUB_B_A
      $63:self.SUB_X_A(@self.r.bc.l); //SUB_C_A
      $64:self.SUB_X_A(@self.r.de.h); //SUB_D_A
      $65:self.SUB_X_A(@self.r.de.l); //SUB_E_A
      $66:self.SUB_X_A(@self.r.hl.h); //SUB_H_A
      $67:self.SUB_X_A(@self.r.hl.l); //SUB_L_A
      $68:self.NEA_X_A(@self.r.va.h);
      $69:self.NEA_X_A(@self.r.va.l);
      $6a:self.NEA_X_A(@self.r.bc.h);
      $6b:self.NEA_X_A(@self.r.bc.l);
      $6c:self.NEA_X_A(@self.r.de.h);
      $6d:self.NEA_X_A(@self.r.de.l);
      $6e:self.NEA_X_A(@self.r.hl.h);
      $6f:self.NEA_X_A(@self.r.hl.l);
      $70:self.SBB_X_A(@self.r.va.h);
      $71:self.SBB_X_A(@self.r.va.l);
      $72:self.SBB_X_A(@self.r.bc.h);
      $73:self.SBB_X_A(@self.r.bc.l);
      $74:self.SBB_X_A(@self.r.de.h);
      $75:self.SBB_X_A(@self.r.de.l);
      $76:self.SBB_X_A(@self.r.hl.h);
      $77:self.SBB_X_A(@self.r.hl.l);
      $78:self.EQA_X_A(@self.r.va.h);
      $79:self.EQA_X_A(@self.r.va.l);
      $7a:self.EQA_X_A(@self.r.bc.h);
      $7b:self.EQA_X_A(@self.r.bc.l);
      $7c:self.EQA_X_A(@self.r.de.h);
      $7d:self.EQA_X_A(@self.r.de.l);
      $7e:self.EQA_X_A(@self.r.hl.h);
      $7f:self.EQA_X_A(@self.r.hl.l);
      $88:begin   //ANA_A_V
            self.r.va.l:=self.r.va.l and self.r.va.h;
	          self.r.psw.zf:=(self.r.va.l=0); //SET_Z
          end;
      $89:begin
            self.r.va.l:=self.r.va.l and self.r.va.l;
	          self.r.psw.zf:=(self.r.va.l=0); //SET_Z
          end;
      $8a:begin
            self.r.va.l:=self.r.va.l and self.r.bc.h;
	          self.r.psw.zf:=(self.r.va.l=0); //SET_Z
          end;
      $8b:begin
            self.r.va.l:=self.r.va.l and self.r.bc.l;
	          self.r.psw.zf:=(self.r.va.l=0); //SET_Z
          end;
      $8c:begin
            self.r.va.l:=self.r.va.l and self.r.de.h;
	          self.r.psw.zf:=(self.r.va.l=0); //SET_Z
          end;
      $8d:begin
            self.r.va.l:=self.r.va.l and self.r.de.l;
	          self.r.psw.zf:=(self.r.va.l=0); //SET_Z
          end;
      $8e:begin
            self.r.va.l:=self.r.va.l and self.r.hl.h;
	          self.r.psw.zf:=(self.r.va.l=0); //SET_Z
          end;
      $8f:begin
            self.r.va.l:=self.r.va.l and self.r.hl.l;
	          self.r.psw.zf:=(self.r.va.l=0); //SET_Z
          end;
      $90:self.XRA_A_X(@self.r.va.h);
      $92:self.XRA_A_X(@self.r.bc.h);
      $93:self.XRA_A_X(@self.r.bc.l); //XRA_A_C
      $94:self.XRA_A_X(@self.r.de.h);
      $95:self.XRA_A_X(@self.r.de.l);
      $96:self.XRA_A_X(@self.r.hl.h);
      $97:self.XRA_A_X(@self.r.hl.l);
      $98:self.ORA_A_X(@self.r.va.h);
      $99:self.ORA_A_X(@self.r.va.l);
      $9a:self.ORA_A_X(@self.r.bc.h);  //ORA_A_B
      $9b:self.ORA_A_X(@self.r.bc.l);  //ORA_A_C
      $9c:self.ORA_A_X(@self.r.de.h);
      $9d:self.ORA_A_X(@self.r.de.l);
      $9e:self.ORA_A_X(@self.r.hl.h); //ORA_A_H
      $9f:self.ORA_A_X(@self.r.hl.l); //ORA_A_L
      $a0:self.ADDNC_A_X(@self.r.va.h);
      $a1:self.ADDNC_A_X(@self.r.va.l);
      $a2:self.ADDNC_A_X(@self.r.bc.h);
      $a3:self.ADDNC_A_X(@self.r.bc.l);
      $a4:self.ADDNC_A_X(@self.r.de.h);
      $a5:self.ADDNC_A_X(@self.r.de.l);
      $a6:self.ADDNC_A_X(@self.r.hl.h);
      $a7:self.ADDNC_A_X(@self.r.hl.l);
      $a8:self.GTA_A_X(@self.r.va.h);  //GTA_A_V
      $a9:self.GTA_A_X(@self.r.va.l); //GTA_A_A
      $aa:self.GTA_A_X(@self.r.bc.h); //GTA_A_B
      $ab:self.GTA_A_X(@self.r.bc.l); //GTA_A_C
      $ac:self.GTA_A_X(@self.r.de.h); //GTA_A_D
      $ad:self.GTA_A_X(@self.r.de.l); //GTA_A_E
      $ae:self.GTA_A_X(@self.r.hl.h); //GTA_A_H
      $af:self.GTA_A_X(@self.r.hl.l); //GTA_A_L
      $b0:self.SUBNB_A_X(@self.r.va.h);
      $b1:self.SUBNB_A_X(@self.r.va.l);
      $b2:self.SUBNB_A_X(@self.r.bc.h);
      $b3:self.SUBNB_A_X(@self.r.bc.l);
      $b4:self.SUBNB_A_X(@self.r.de.h);
      $b5:self.SUBNB_A_X(@self.r.de.l);
      $b6:self.SUBNB_A_X(@self.r.hl.h);
      $b7:self.SUBNB_A_X(@self.r.hl.l);
      $b8:self.LTA_A_X(@self.r.va.h);
      $b9:self.LTA_A_X(@self.r.va.l);
      $ba:self.LTA_A_X(@self.r.bc.h);
      $bb:self.LTA_A_X(@self.r.bc.l);
      $bc:self.LTA_A_X(@self.r.de.h);
      $bd:self.LTA_A_X(@self.r.de.l);
      $be:self.LTA_A_X(@self.r.hl.h);
      $bf:self.LTA_A_X(@self.r.hl.l);
      $c0:self.ADD_A_X(@self.r.va.h);
      $c2:self.ADD_A_X(@self.r.bc.h);  //ADD_A_B
      $c3:self.ADD_A_X(@self.r.bc.l); //ADD_A_C
      $c4:self.ADD_A_X(@self.r.de.h); //ADD_A_D
      $c5:self.ADD_A_X(@self.r.de.l); //ADD_A_E
      $c6:self.ADD_A_X(@self.r.hl.h); //ADD_A_H
      $c7:self.ADD_A_X(@self.r.hl.l); //ADD_A_L
      $c8:self.ONA_A_X(@self.r.va.h);
      $c9:self.ONA_A_X(@self.r.va.l);
      $ca:self.ONA_A_X(@self.r.bc.h);
      $cb:self.ONA_A_X(@self.r.bc.l);
      $cc:self.ONA_A_X(@self.r.de.h);
      $cd:self.ONA_A_X(@self.r.de.l);
      $ce:self.ONA_A_X(@self.r.hl.h);
      $cf:self.ONA_A_X(@self.r.hl.l);
      $d0:self.ADC_A_X(@self.r.va.h);
      $d1:self.ADC_A_X(@self.r.va.l);
      $d2:self.ADC_A_X(@self.r.bc.h);  //ADC_A_B
      $d3:self.ADC_A_X(@self.r.bc.l);  //ADC_A_B
      $d4:self.ADC_A_X(@self.r.de.h);
      $d5:self.ADC_A_X(@self.r.de.l);
      $d6:self.ADC_A_X(@self.r.hl.h);
      $d7:self.ADC_A_X(@self.r.hl.l);
      $d8:self.OFFA_A_X(@self.r.va.h);
      $d9:self.OFFA_A_X(@self.r.va.l);
      $da:self.OFFA_A_X(@self.r.bc.h);
      $db:self.OFFA_A_X(@self.r.bc.l);
      $dc:self.OFFA_A_X(@self.r.de.h);
      $dd:self.OFFA_A_X(@self.r.de.l);
      $de:self.OFFA_A_X(@self.r.hl.h);
      $df:self.OFFA_A_X(@self.r.hl.l);
      $e0:self.SUB_A_X(@self.r.va.h);
      $e1:self.SUB_A_X(@self.r.va.l);
      $e2:self.SUB_A_X(@self.r.bc.h);  //SUB_A_B
      $e3:self.SUB_A_X(@self.r.bc.l); //SUB_A_C
      $e4:self.SUB_A_X(@self.r.de.h);
      $e5:self.SUB_A_X(@self.r.de.l);
      $e6:self.SUB_A_X(@self.r.hl.h);
      $e7:self.SUB_A_X(@self.r.hl.l);
      $e8:self.NEA_A_X(@self.r.va.h);
      $e9:self.NEA_A_X(@self.r.va.l);
      $ea:self.NEA_A_X(@self.r.bc.h);  //NEA_A_B
      $eb:self.NEA_A_X(@self.r.bc.l);
      $ec:self.NEA_A_X(@self.r.de.h);
      $ed:self.NEA_A_X(@self.r.de.l);
      $ee:self.NEA_A_X(@self.r.hl.h);
      $ef:self.NEA_A_X(@self.r.hl.l);
      $f0:self.SBB_A_X(@self.r.va.h);
      $f1:self.SBB_A_X(@self.r.va.l);
      $f2:self.SBB_A_X(@self.r.bc.h);
      $f3:self.SBB_A_X(@self.r.bc.l);
      $f4:self.SBB_A_X(@self.r.de.h);
      $f5:self.SBB_A_X(@self.r.de.l);
      $f6:self.SBB_A_X(@self.r.hl.h);
      $f7:self.SBB_A_X(@self.r.hl.l);
      $f8:self.EQA_A_X(@self.r.va.h);  //EQA_A_V
      $f9:self.EQA_A_X(@self.r.va.l);
      $fa:self.EQA_A_X(@self.r.bc.h);  //EQA_A_B
      $fb:self.EQA_A_X(@self.r.bc.l); //EQA_A_C
      $fc:self.EQA_A_X(@self.r.de.h); //EQA_A_D
      $fd:self.EQA_A_X(@self.r.de.l); //EQA_A_E
      $fe:self.EQA_A_X(@self.r.hl.h); //EQA_A_H
      $ff:self.EQA_A_X(@self.r.hl.l); //EQA_A_L
      else MessageDlg('Instruccion 60: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
  end;
end;
procedure cpu_upd7810.opcode_64;
var
  instruccion,tempb,portt:byte;
  tempw:word;
begin
 instruccion:=self.getbyte(self.pc);
 self.pc:=self.pc+1;
 if self.cpu_type=CPU_7810 then begin
  case instruccion of
    $0:begin //MVI_PA
        tempb:=self.getbyte(self.pc);
        self.pc:=self.pc+1;
        self.write_port(UPD7810_PORTA,tempb);
       end;
    $1:begin //MVI_PB
        tempb:=self.getbyte(self.pc);
        self.pc:=self.pc+1;
        self.write_port(UPD7810_PORTB,tempb);
       end;
    $2:begin //MVI_PC
        tempb:=self.getbyte(self.pc);
        self.pc:=self.pc+1;
        self.write_port(UPD7810_PORTC,tempb);
       end;
    $5:begin //MVI_PF
        tempb:=self.getbyte(self.pc);
        self.pc:=self.pc+1;
        self.write_port(UPD7810_PORTF,tempb);
       end;
    $6:begin //MVI_MKH
        self.mkh:=self.getbyte(self.pc);
        self.pc:=self.pc+1;
       end;
    $7:begin //MVI_MKL
        self.mkl:=self.getbyte(self.pc);
        self.pc:=self.pc+1;
       end;
    $80:begin //MVI_ANM
        self.anm:=self.getbyte(self.pc);
        self.pc:=self.pc+1;
       end;
    else MessageDlg('Instruccion 64: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
  end;
 end else if self.cpu_type=CPU_7801 then begin
              case instruccion of
                  $8:self.ANI_X(@self.r.va.h);
                  $9:self.ANI_X(@self.r.va.l);
                  $a:self.ANI_X(@self.r.bc.h);
                  $b:self.ANI_X(@self.r.bc.l);
                  $c:self.ANI_X(@self.r.de.h);
                  $d:self.ANI_X(@self.r.de.l);
                  $e:self.ANI_X(@self.r.hl.h);
                  $f:self.ANI_X(@self.r.hl.l);
                  $10:self.XRI_X(@self.r.va.h);
                  $11:self.XRI_X(@self.r.va.l);
                  $12:self.XRI_X(@self.r.bc.h);
                  $13:self.XRI_X(@self.r.bc.l);
                  $14:self.XRI_X(@self.r.de.h);
                  $15:self.XRI_X(@self.r.de.l);
                  $16:self.XRI_X(@self.r.hl.h);
                  $17:self.XRI_X(@self.r.hl.l);
                  $18:self.ORI_X(@self.r.va.h);
                  $19:self.ORI_X(@self.r.va.l);
                  $1a:self.ORI_X(@self.r.bc.h);
                  $1b:self.ORI_X(@self.r.bc.l);
                  $1c:self.ORI_X(@self.r.de.h);
                  $1d:self.ORI_X(@self.r.de.l);
                  $1e:self.ORI_X(@self.r.hl.h);
                  $1f:self.ORI_X(@self.r.hl.l);
                  $20:begin //ADINC_V_xx
                        self.ADI_X(@self.r.va.h);
                        if not(self.r.psw.cy) then self.r.psw.sk:=true;
                      end;
                  $21:begin //ADINC_A_xx
                        self.ADI_X(@self.r.va.l);
                        if not(self.r.psw.cy) then self.r.psw.sk:=true;
                      end;
                  $22:begin //ADINC_B_xx
                        self.ADI_X(@self.r.bc.h);
                        if not(self.r.psw.cy) then self.r.psw.sk:=true;
                      end;
                  $23:begin //ADINC_C_xx
                        self.ADI_X(@self.r.bc.l);
                        if not(self.r.psw.cy) then self.r.psw.sk:=true;
                      end;
                  $24:begin //ADINC_D_xx
                        self.ADI_X(@self.r.de.h);
                        if not(self.r.psw.cy) then self.r.psw.sk:=true;
                      end;
                  $25:begin //ADINC_E_xx
                        self.ADI_X(@self.r.de.l);
                        if not(self.r.psw.cy) then self.r.psw.sk:=true;
                      end;
                  $26:begin //ADINC_H_xx
                        self.ADI_X(@self.r.hl.h);
                        if not(self.r.psw.cy) then self.r.psw.sk:=true;
                      end;
                  $27:begin //ADINC_L_xx
                        self.ADI_X(@self.r.hl.l);
                        if not(self.r.psw.cy) then self.r.psw.sk:=true;
                      end;
                  $28:self.GTI_X(@self.r.va.h);
                  $29:self.GTI_X(@self.r.va.l);
                  $2a:self.GTI_X(@self.r.bc.h);
                  $2b:self.GTI_X(@self.r.bc.l);
                  $2c:self.GTI_X(@self.r.de.h);
                  $2d:self.GTI_X(@self.r.de.l);
                  $2e:self.GTI_X(@self.r.hl.h);
                  $2f:self.GTI_X(@self.r.hl.l);
                  $30:self.SUINB_X(@self.r.va.h);
                  $31:self.SUINB_X(@self.r.va.l);
                  $32:self.SUINB_X(@self.r.bc.h);
                  $33:self.SUINB_X(@self.r.bc.l);
                  $34:self.SUINB_X(@self.r.de.h);
                  $35:self.SUINB_X(@self.r.de.l);
                  $36:self.SUINB_X(@self.r.hl.h);
                  $37:self.SUINB_X(@self.r.hl.l);
                  $38:self.LTI_X(@self.r.va.h);
                  $39:self.LTI_X(@self.r.va.l);
                  $3a:self.LTI_X(@self.r.bc.h);
                  $3b:self.LTI_X(@self.r.bc.l);
                  $3c:self.LTI_X(@self.r.de.h);
                  $3d:self.LTI_X(@self.r.de.l);
                  $3e:self.LTI_X(@self.r.hl.h);
                  $3f:self.LTI_X(@self.r.hl.l);
                  $40:self.ADI_X(@self.r.va.h);
                  $41:self.ADI_X(@self.r.va.l);
                  $42:self.ADI_X(@self.r.bc.h);
                  $43:self.ADI_X(@self.r.bc.l);
                  $44:self.ADI_X(@self.r.de.h);
                  $45:self.ADI_X(@self.r.de.l);
                  $46:self.ADI_X(@self.r.hl.h);
                  $47:self.ADI_X(@self.r.hl.l);
                  $48:self.ONI_X(@self.r.va.h);
                  $49:self.ONI_X(@self.r.va.l);
                  $4a:self.ONI_X(@self.r.bc.h);
                  $4b:self.ONI_X(@self.r.bc.l);
                  $4c:self.ONI_X(@self.r.de.h);
                  $4d:self.ONI_X(@self.r.de.l);
                  $4e:self.ONI_X(@self.r.hl.h);
                  $4f:self.ONI_X(@self.r.hl.l);
                  $50:self.ACI_X(@self.r.va.h);
                  $51:self.ACI_X(@self.r.va.l);
                  $52:self.ACI_X(@self.r.bc.h);
                  $53:self.ACI_X(@self.r.bc.l);
                  $54:self.ACI_X(@self.r.de.h);
                  $55:self.ACI_X(@self.r.de.l);
                  $56:self.ACI_X(@self.r.hl.h);
                  $57:self.ACI_X(@self.r.hl.l);
                  $58:self.OFFI_X(@self.r.va.h);
                  $59:self.OFFI_X(@self.r.va.l);
                  $5a:self.OFFI_X(@self.r.bc.h);
                  $5b:self.OFFI_X(@self.r.bc.l);
                  $5c:self.OFFI_X(@self.r.de.h);
                  $5d:self.OFFI_X(@self.r.de.l);
                  $5e:self.OFFI_X(@self.r.hl.h);
                  $5f:self.OFFI_X(@self.r.hl.l);
                  $60:self.SUI_X(@self.r.va.h);
                  $61:self.SUI_X(@self.r.va.l);
                  $62:self.SUI_X(@self.r.bc.h);
                  $63:self.SUI_X(@self.r.bc.l);
                  $64:self.SUI_X(@self.r.de.h);
                  $65:self.SUI_X(@self.r.de.l);
                  $66:self.SUI_X(@self.r.hl.h);
                  $67:self.SUI_X(@self.r.hl.l);
                  $68:self.NEI_X(@self.r.va.h);
                  $69:self.NEI_X(@self.r.va.l);
                  $6a:self.NEI_X(@self.r.bc.h);
                  $6b:self.NEI_X(@self.r.bc.l);
                  $6c:self.NEI_X(@self.r.de.h);
                  $6d:self.NEI_X(@self.r.de.l);
                  $6e:self.NEI_X(@self.r.hl.h);
                  $6f:self.NEI_X(@self.r.hl.l);
                  $70:self.SBI_X(@self.r.va.h);
                  $71:self.SBI_X(@self.r.va.l);
                  $72:self.SBI_X(@self.r.bc.h);
                  $73:self.SBI_X(@self.r.bc.l);
                  $74:self.SBI_X(@self.r.de.h);
                  $75:self.SBI_X(@self.r.de.l);
                  $76:self.SBI_X(@self.r.hl.h);
                  $77:self.SBI_X(@self.r.hl.l);
                  $78:self.EQI_X(@self.r.va.h);
                  $79:self.EQI_X(@self.r.va.l);
                  $7a:self.EQI_X(@self.r.bc.h);
                  $7b:self.EQI_X(@self.r.bc.l);
                  $7c:self.EQI_X(@self.r.de.h);
                  $7d:self.EQI_X(@self.r.de.l);
                  $7e:self.EQI_X(@self.r.hl.h);
                  $7f:self.EQI_X(@self.r.hl.l);
                  $8a:begin //ANI_PC_xx
                        tempb:=self.read_port(UPD7810_PORTC) and self.getbyte(self.pc);
                        self.pc:=self.pc+1;
                        self.write_port(UPD7810_PORTC,tempb);
                        self.r.psw.zf:=(tempb=0); //SET_Z
                      end;
                  $8b:begin //ANI_MKL_xx
	                      self.mkl:=self.mkl and self.getbyte(self.pc);
                        self.pc:=self.pc+1;
                        self.r.psw.zf:=(self.mkl=0);
                      end;
                  $93:begin //XRI_MKL_xx
	                      self.mkl:=self.mkl xor self.getbyte(self.pc);
                        self.pc:=self.pc+1;
                        self.r.psw.zf:=(self.mkl=0);
                      end;
                  $9a:begin //ORI_PC_xx
                        tempb:=self.read_port(UPD7810_PORTC) or self.getbyte(self.pc);
                        self.pc:=self.pc+1;
                        self.write_port(UPD7810_PORTC,tempb);
                        self.r.psw.zf:=(tempb=0);
                      end;
                  $9b:begin //ORI_MKL
                        self.mkl:=self.mkl or self.getbyte(self.pc);
                        self.pc:=self.pc+1;
                        self.r.psw.zf:=(self.mkl=0);
                      end;
                  $a8:begin //GTI_PA
                        portt:=self.read_port(UPD7810_PORTA);
                        tempw:=portt-self.getbyte(self.pc)-1;
                        self.pc:=self.pc+1;
	                      self.ZHC_SUB(tempw,portt,false);
                        if not(self.r.psw.cy) then self.r.psw.sk:=true; //SKIP_NC;
                      end;
                  $ca:begin //ONI_PC_xx
                        portt:=self.read_port(UPD7810_PORTC);
                        tempb:=self.getbyte(self.pc);
                        self.pc:=self.pc+1;
	                      if (portt and tempb)<>0 then self.r.psw.sk:=true;
                      end;
                  $cb:begin //ONI_MKL_xx
                        tempb:=self.getbyte(self.pc);
                        self.pc:=self.pc+1;
                        if (self.mkl and tempb)<>0 then self.r.psw.sk:=true;
                      end;
                  $da:begin //OFFI_PC_xx
                        portt:=self.read_port(UPD7810_PORTC);
                        tempb:=self.getbyte(self.pc);
                        self.pc:=self.pc+1;
                        if (portt and tempb)=0 then self.r.psw.sk:=true;
                      end;
                  $db:self.OFFI_X(@self.mkl); //OFFI_MKL_xx
                  else MessageDlg('Instruccion 64: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
              end;
          end else MessageDlg('Instruccion 64: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
end;
procedure cpu_upd7810.opcode_70;
var
  instruccion:byte;
  tempw:word;
  tempb:byte;
begin
  instruccion:=self.getbyte(self.pc);
  self.pc:=self.pc+1;
  case instruccion of
      $e:begin //SSPD_w
            tempw:=self.getbyte(self.pc) or (self.getbyte(self.pc+1) shl 8);
            self.pc:=self.pc+2;
            self.putbyte(tempw,self.sp and $ff);
            self.putbyte(tempw+1,self.sp shr 8);
          end;
      $f:begin //LSPD_w
            tempw:=self.getbyte(self.pc) or (self.getbyte(self.pc+1) shl 8);
            self.pc:=self.pc+2;
            self.sp:=self.getbyte(tempw) or (self.getbyte(tempw+1) shl 8);
         end;
      $1e:begin //SBCD_w
            tempw:=self.getbyte(self.pc) or (self.getbyte(self.pc+1) shl 8);
            self.pc:=self.pc+2;
            self.putbyte(tempw,self.r.bc.l);
            self.putbyte(tempw+1,self.r.bc.h);
          end;
      $1f:begin //LBCD_w
            tempw:=self.getbyte(self.pc) or (self.getbyte(self.pc+1) shl 8);
            self.pc:=self.pc+2;
            self.r.bc.l:=self.getbyte(tempw);
            self.r.bc.h:=self.getbyte(tempw+1);
          end;
      $2e:begin //SDED_w
            tempw:=self.getbyte(self.pc) or (self.getbyte(self.pc+1) shl 8);
            self.pc:=self.pc+2;
            self.putbyte(tempw,self.r.de.l);
            self.putbyte(tempw+1,self.r.de.h);
          end;
      $2f:begin//LDED_w
            tempw:=self.getbyte(self.pc) or (self.getbyte(self.pc+1) shl 8);
            self.pc:=self.pc+2;
            self.r.de.l:=self.getbyte(tempw);
            self.r.de.h:=self.getbyte(tempw+1);
          end;
      $3e:begin //SHLD_w
            tempw:=self.getbyte(self.pc) or (self.getbyte(self.pc+1) shl 8);
            self.pc:=self.pc+2;
            self.putbyte(tempw,self.r.hl.l);
            self.putbyte(tempw+1,self.r.hl.h);
          end;
      $3f:begin//LHLD_w
            tempw:=self.getbyte(self.pc) or (self.getbyte(self.pc+1) shl 8);
            self.pc:=self.pc+2;
            self.r.hl.l:=self.getbyte(tempw);
            self.r.hl.h:=self.getbyte(tempw+1);
          end;
      $41:if self.cpu_type=CPU_7810 then begin //EADD_EA_A
	          tempw:=self.r.ea+self.r.va.l;
	          ZHC_ADD(tempw,self.r.ea,false);
	          self.r.ea:=tempw;
          end else MessageDlg('Instruccion 70: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
      $68:begin //MOV_V_w
            tempw:=self.getbyte(self.pc) or (self.getbyte(self.pc+1) shl 8);
            self.pc:=self.pc+2;
            self.r.va.h:=self.getbyte(tempw);
          end;
      $69:begin //MOV_A_w
            tempw:=self.getbyte(self.pc) or (self.getbyte(self.pc+1) shl 8);
            self.pc:=self.pc+2;
            self.r.va.l:=self.getbyte(tempw);
          end;
      $6a:begin //MOV_B_w
            tempw:=self.getbyte(self.pc) or (self.getbyte(self.pc+1) shl 8);
            self.pc:=self.pc+2;
            self.r.bc.h:=self.getbyte(tempw);
          end;
      $6b:begin //MOV_C_w
            tempw:=self.getbyte(self.pc) or (self.getbyte(self.pc+1) shl 8);
            self.pc:=self.pc+2;
            self.r.bc.l:=self.getbyte(tempw);
          end;
      $6c:begin //MOV_D_w
            tempw:=self.getbyte(self.pc) or (self.getbyte(self.pc+1) shl 8);
            self.pc:=self.pc+2;
            self.r.de.h:=self.getbyte(tempw);
          end;
      $6d:begin //MOV_E_w
            tempw:=self.getbyte(self.pc) or (self.getbyte(self.pc+1) shl 8);
            self.pc:=self.pc+2;
            self.r.de.l:=self.getbyte(tempw);
          end;
      $6e:begin //MOV_H_w
            tempw:=self.getbyte(self.pc) or (self.getbyte(self.pc+1) shl 8);
            self.pc:=self.pc+2;
            self.r.hl.h:=self.getbyte(tempw);
          end;
      $6f:begin //MOV_L_w
            tempw:=self.getbyte(self.pc) or (self.getbyte(self.pc+1) shl 8);
            self.pc:=self.pc+2;
            self.r.hl.l:=self.getbyte(tempw);
          end;
      $78:begin //MOV_w_V
            tempw:=self.getbyte(self.pc) or (self.getbyte(self.pc+1) shl 8);
            self.pc:=self.pc+2;
            self.putbyte(tempw,self.r.va.h);
          end;
      $79:begin //MOV_w_A
            tempw:=self.getbyte(self.pc) or (self.getbyte(self.pc+1) shl 8);
            self.pc:=self.pc+2;
            self.putbyte(tempw,self.r.va.l);
          end;
      $7a:begin //MOV_w_B
            tempw:=self.getbyte(self.pc) or (self.getbyte(self.pc+1) shl 8);
            self.pc:=self.pc+2;
            self.putbyte(tempw,self.r.bc.h);
          end;
      $7b:begin //MOV_w_C
            tempw:=self.getbyte(self.pc) or (self.getbyte(self.pc+1) shl 8);
            self.pc:=self.pc+2;
            self.putbyte(tempw,self.r.bc.l);
          end;
      $7c:begin //MOV_w_D
            tempw:=self.getbyte(self.pc) or (self.getbyte(self.pc+1) shl 8);
            self.pc:=self.pc+2;
            self.putbyte(tempw,self.r.de.h);
          end;
      $7d:begin //MOV_w_E
            tempw:=self.getbyte(self.pc) or (self.getbyte(self.pc+1) shl 8);
            self.pc:=self.pc+2;
            self.putbyte(tempw,self.r.de.l);
          end;
      $7e:begin //MOV_w_H
            tempw:=self.getbyte(self.pc) or (self.getbyte(self.pc+1) shl 8);
            self.pc:=self.pc+2;
            self.putbyte(tempw,self.r.hl.h);
          end;
      $7f:begin //MOV_w_L
            tempw:=self.getbyte(self.pc) or (self.getbyte(self.pc+1) shl 8);
            self.pc:=self.pc+2;
            self.putbyte(tempw,self.r.hl.l);
          end;
      $89:begin //ANAX_B
            self.r.va.l:=self.r.va.l and self.getbyte(self.r.bc.w);
            self.r.psw.zf:=(self.r.va.l=0); //SET_Z
          end;
      $8a:begin //ANAX_D
            self.r.va.l:=self.r.va.l and self.getbyte(self.r.de.w);
            self.r.psw.zf:=(self.r.va.l=0); //SET_Z
          end;
      $8b:begin //ANAX_H
            self.r.va.l:=self.r.va.l and self.getbyte(self.r.hl.w);
            self.r.psw.zf:=(self.r.va.l=0); //SET_Z
          end;
      $8d:begin //ANAX_Hp
            self.r.va.l:=self.r.va.l and self.getbyte(self.r.hl.w);
            self.r.hl.w:=self.r.hl.w+1;
            self.r.psw.zf:=(self.r.va.l=0); //SET_Z
          end;
      $91:begin //XRAX_B
            self.r.va.l:=self.r.va.l xor self.getbyte(self.r.bc.w);
	          self.r.psw.zf:=(self.r.va.l=0); //SET_Z
          end;
      $92:begin //XRAX_D
            self.r.va.l:=self.r.va.l xor self.getbyte(self.r.de.w);
	          self.r.psw.zf:=(self.r.va.l=0); //SET_Z
          end;
      $93:begin //XRAX_H
            self.r.va.l:=self.r.va.l xor self.getbyte(self.r.hl.w);
	          self.r.psw.zf:=(self.r.va.l=0); //SET_Z
          end;
      $99:begin //ORAX_B
            self.r.va.l:=self.r.va.l or self.getbyte(self.r.bc.w);
	          self.r.psw.zf:=(self.r.va.l=0); //SET_Z
          end;
      $9a:begin //ORAX_D
            self.r.va.l:=self.r.va.l or self.getbyte(self.r.de.w);
	          self.r.psw.zf:=(self.r.va.l=0); //SET_Z
          end;
      $9b:begin //ORAX_H
            self.r.va.l:=self.r.va.l or self.getbyte(self.r.hl.w);
	          self.r.psw.zf:=(self.r.va.l=0); //SET_Z
          end;
      $9c:begin //ORAX_Dp
            self.r.va.l:=self.r.va.l or self.getbyte(self.r.de.w);
            self.r.de.w:=self.r.de.w+1;
	          self.r.psw.zf:=(self.r.va.l=0); //SET_Z
          end;
      $9d:begin //ORAX_Hp
            self.r.va.l:=self.r.va.l or self.getbyte(self.r.hl.w);
            self.r.hl.w:=self.r.hl.w+1;
	          self.r.psw.zf:=(self.r.va.l=0); //SET_Z
          end;
      $9e:begin //ORAX_Dm
            self.r.va.l:=self.r.va.l or self.getbyte(self.r.de.w);
            self.r.de.w:=self.r.de.w-1;
	          self.r.psw.zf:=(self.r.va.l=0); //SET_Z
          end;
      $9f:begin //ORAX_Hm
            self.r.va.l:=self.r.va.l or self.getbyte(self.r.hl.w);
            self.r.hl.w:=self.r.hl.w-1;
	          self.r.psw.zf:=(self.r.va.l=0); //SET_Z
          end;
      $a2:begin //ADDNCX_D
            tempb:=self.r.va.l+self.getbyte(self.r.de.w);
	          self.ZHC_ADD(tempb,self.r.va.l,false);
	          self.r.va.l:=tempb;
	          if not(self.r.psw.cy) then self.r.psw.sk:=true; //SKIP_NC
          end;
      $a3:begin //ADDNCX_H
            tempb:=self.r.va.l+self.getbyte(self.r.hl.w);
	          self.ZHC_ADD(tempb,self.r.va.l,false);
	          self.r.va.l:=tempb;
	          if not(self.r.psw.cy) then self.r.psw.sk:=true; //SKIP_NC
          end;
      $a9:begin //GTAX_B
            tempw:=self.r.va.l-self.getbyte(self.r.bc.w)-1;
	          self.ZHC_SUB(tempw,self.r.va.l,false);
	          if not(self.r.psw.cy) then self.r.psw.sk:=true; //SKIP_NC
          end;
      $aa:begin //GTAX_D
            tempw:=self.r.va.l-self.getbyte(self.r.de.w)-1;
	          self.ZHC_SUB(tempw,self.r.va.l,false);
	          if not(self.r.psw.cy) then self.r.psw.sk:=true; //SKIP_NC
          end;
      $ab:begin //GTAX_H
            tempw:=self.r.va.l-self.getbyte(self.r.hl.w)-1;
	          self.ZHC_SUB(tempw,self.r.va.l,false);
	          if not(self.r.psw.cy) then self.r.psw.sk:=true; //SKIP_NC
          end;
      $ac:begin //GTAX_Dp
            tempw:=self.r.va.l-self.getbyte(self.r.de.w)-1;
            self.r.de.w:=self.r.de.w+1;
	          self.ZHC_SUB(tempw,self.r.va.l,false);
            if not(self.r.psw.cy) then self.r.psw.sk:=true; //SKIP_NC
          end;
      $b1:begin //SUBNBX_B
            tempb:=self.r.va.l-self.getbyte(self.r.bc.w);
	          self.ZHC_SUB(tempb,self.r.va.l,false);
	          self.r.va.l:=tempb;
	          if not(self.r.psw.cy) then self.r.psw.sk:=true; //SKIP_NC
          end;
      $b2:begin //SUBNBX_D
            tempb:=self.r.va.l-self.getbyte(self.r.de.w);
	          self.ZHC_SUB(tempb,self.r.va.l,false);
	          self.r.va.l:=tempb;
	          if not(self.r.psw.cy) then self.r.psw.sk:=true; //SKIP_NC
          end;
      $b3:begin //SUBNBX_H
            tempb:=self.r.va.l-self.getbyte(self.r.hl.w);
	          self.ZHC_SUB(tempb,self.r.va.l,false);
	          self.r.va.l:=tempb;
	          if not(self.r.psw.cy) then self.r.psw.sk:=true; //SKIP_NC
          end;
      $b4:begin //SUBNBX_Dp
             tempb:=self.r.va.l-self.getbyte(self.r.de.w);
	           self.r.de.w:=self.r.de.w+1;
	           self.ZHC_SUB(tempb,self.r.va.l,false);
	           self.r.va.l:=tempb;
             if not(self.r.psw.cy) then self.r.psw.sk:=true; //SKIP_NC;
          end;
      $b5:begin //SUBNBX_Hp
             tempb:=self.r.va.l-self.getbyte(self.r.hl.w);
	           self.r.hl.w:=self.r.hl.w+1;
	           self.ZHC_SUB(tempb,self.r.va.l,false);
	           self.r.va.l:=tempb;
             if not(self.r.psw.cy) then self.r.psw.sk:=true; //SKIP_NC;
          end;
      $b6:begin //SUBNBX_Dm
             tempb:=self.r.va.l-self.getbyte(self.r.de.w);
	           self.r.de.w:=self.r.de.w-1;
	           self.ZHC_SUB(tempb,self.r.va.l,false);
	           self.r.va.l:=tempb;
             if not(self.r.psw.cy) then self.r.psw.sk:=true; //SKIP_NC;
          end;
      $b7:begin //SUBNBX_Hm
             tempb:=self.r.va.l-self.getbyte(self.r.hl.w);
             self.r.hl.w:=self.r.hl.w-1;
	           self.ZHC_SUB(tempb,self.r.va.l,false);
             self.r.va.l:=tempb;
             if not(self.r.psw.cy) then self.r.psw.sk:=true; //SKIP_NC;
          end;
      $b9:begin //LTAX_B
             tempb:=self.r.va.l-self.getbyte(self.r.bc.w);
	            ZHC_SUB(tempb,self.r.va.l,false);
	            if self.r.psw.cy then self.r.psw.sk:=true;  //SKIP_CY
          end;
      $ba:begin //LTAX_D
              tempb:=self.r.va.l-self.getbyte(self.r.de.w);
	            ZHC_SUB(tempb,self.r.va.l,false);
	            if self.r.psw.cy then self.r.psw.sk:=true;  //SKIP_CY
          end;
      $bb:begin //LTAX_H
              tempb:=self.r.va.l-self.getbyte(self.r.hl.w);
	            ZHC_SUB(tempb,self.r.va.l,false);
	            if self.r.psw.cy then self.r.psw.sk:=true;  //SKIP_CY
          end;
      $bc:begin //LTAX_Dp
              tempb:=self.r.va.l-self.getbyte(self.r.de.w);
              self.r.de.w:=self.r.de.w+1;
	            self.ZHC_SUB(tempb,self.r.va.l,false);
	            if self.r.psw.cy then self.r.psw.sk:=true;  //SKIP_CY
          end;
      $c1:begin //ADDX_B
              tempb:=self.r.va.l+self.getbyte(self.r.bc.w);
	            ZHC_ADD(tempb,self.r.va.l,false);
	            self.r.va.l:=tempb;
          end;
      $c2:begin //ADDX_D
              tempb:=self.r.va.l+self.getbyte(self.r.de.w);
	            ZHC_ADD(tempb,self.r.va.l,false);
	            self.r.va.l:=tempb;
          end;
      $c3:begin  //ADDX_H
            tempb:=self.r.va.l+self.getbyte(self.r.hl.w);
	          ZHC_ADD(tempb,self.r.va.l,false);
	          self.r.va.l:=tempb;
          end;
      $c4:begin //ADDX_Dp
            tempb:=self.r.va.l+self.getbyte(self.r.de.w);
            self.r.de.w:=self.r.de.w+1;
	          self.ZHC_ADD(tempb,self.r.va.l,false);
	          self.r.va.l:=tempb;
          end;
      $c5:begin //ADDX_Hp
            tempb:=self.r.va.l+self.getbyte(self.r.hl.w);
            self.r.hl.w:=self.r.hl.w+1;
	          ZHC_ADD(tempb,self.r.va.l,false);
	          self.r.va.l:=tempb;
          end;
      $c6:begin //ADDX_Dm
            tempb:=self.r.va.l+self.getbyte(self.r.de.w);
            self.r.de.w:=self.r.de.w-1;
	          self.ZHC_ADD(tempb,self.r.va.l,false);
	          self.r.va.l:=tempb;
          end;
      $c7:begin //ADDX_Hm
            tempb:=self.r.va.l+self.getbyte(self.r.hl.w);
            self.r.hl.w:=self.r.hl.w-1;
	          self.ZHC_ADD(tempb,self.r.va.l,false);
	          self.r.va.l:=tempb;
          end;
      $ca:begin //ONAX_D
            if (self.r.va.l and self.getbyte(self.r.de.w))<>0 then begin
              self.r.psw.zf:=false;
              self.r.psw.sk:=true;
            end else self.r.psw.zf:=true;
          end;
      $cb:begin //ONAX_H
            if (self.r.va.l and self.getbyte(self.r.hl.w))<>0 then begin
              self.r.psw.zf:=false;
              self.r.psw.sk:=true;
            end else self.r.psw.zf:=true;
          end;
      $d1:begin //ADCX_B
            tempb:=self.r.va.l+self.getbyte(self.r.bc.w)+byte(self.r.psw.cy);
	          ZHC_ADD(tempb,self.r.va.l,false);
	          self.r.va.l:=tempb;
          end;
      $d2:begin //ADCX_D
            tempb:=self.r.va.l+self.getbyte(self.r.de.w)+byte(self.r.psw.cy);
	          ZHC_ADD(tempb,self.r.va.l,false);
	          self.r.va.l:=tempb;
          end;
      $d3:begin //ADCX_H
            tempb:=self.r.va.l+self.getbyte(self.r.hl.w)+byte(self.r.psw.cy);
	          ZHC_ADD(tempb,self.r.va.l,false);
	          self.r.va.l:=tempb;
          end;
      $d5:begin //ADCX_Hp
            tempb:=self.r.va.l+self.getbyte(self.r.hl.w)+byte(self.r.psw.cy);
            self.r.hl.w:=self.r.hl.w+1;
	          self.ZHC_ADD(tempb,self.r.va.l,false);
	          self.r.va.l:=tempb;
          end;
      $d6:begin //ADCX_Dm
            tempb:=self.r.va.l+self.getbyte(self.r.de.w)+byte(self.r.psw.cy);
            self.r.de.w:=self.r.de.w-1;
	          ZHC_ADD(tempb,self.r.va.l,false);
	          self.r.va.l:=tempb;
          end;
      $d7:begin //ADCX_Hm
            tempb:=self.r.va.l+self.getbyte(self.r.hl.w)+byte(self.r.psw.cy);
            self.r.hl.w:=self.r.hl.w-1;
	          ZHC_ADD(tempb,self.r.va.l,false);
	          self.r.va.l:=tempb;
          end;
      $d9:begin //OFFAX_B
            if (self.r.va.l and self.getbyte(self.r.bc.w))<>0 then self.r.psw.zf:=false
              else begin
                self.r.psw.zf:=true;
                self.r.psw.sk:=true;
              end;
          end;
      $da:begin //OFFAX_D
            if (self.r.va.l and self.getbyte(self.r.de.w))<>0 then self.r.psw.zf:=false
              else begin
                self.r.psw.zf:=true;
                self.r.psw.sk:=true;
              end;
          end;
      $db:begin //OFFAX_H
            if (self.r.va.l and self.getbyte(self.r.hl.w))<>0 then self.r.psw.zf:=false
              else begin
                self.r.psw.zf:=true;
                self.r.psw.sk:=true;
              end;
          end;
      $e1:begin //SUBX_B
            tempb:=self.r.va.l-self.getbyte(self.r.bc.w);
	          self.ZHC_SUB(tempb,self.r.va.l,false);
	          self.r.va.l:=tempb;
          end;
      $e2:begin //SUBX_D
            tempb:=self.r.va.l-self.getbyte(self.r.de.w);
	          self.ZHC_SUB(tempb,self.r.va.l,false);
	          self.r.va.l:=tempb;
          end;
      $e3:begin //SUBX_H
            tempb:=self.r.va.l-self.getbyte(self.r.hl.w);
	          self.ZHC_SUB(tempb,self.r.va.l,false);
	          self.r.va.l:=tempb;
          end;
      $e4:begin //SUBX_Dp
            tempb:=self.r.va.l-self.getbyte(self.r.de.w);
	          self.ZHC_SUB(tempb,self.r.va.l,false);
	          self.r.va.l:=tempb;
	          self.r.de.w:=self.r.de.w+1;
          end;
      $e5:begin //SUBX_Hp
            tempb:=self.r.va.l-self.getbyte(self.r.hl.w);
	          self.ZHC_SUB(tempb,self.r.va.l,false);
	          self.r.va.l:=tempb;
	          self.r.hl.w:=self.r.hl.w+1;
          end;
      $e6:begin //SUBX_Dm
            tempb:=self.r.va.l-self.getbyte(self.r.de.w);
	          self.ZHC_SUB(tempb,self.r.va.l,false);
	          self.r.va.l:=tempb;
	          self.r.de.w:=self.r.de.w-1;
          end;
      $e7:begin //SUBX_Hm
            tempb:=self.r.va.l-self.getbyte(self.r.hl.w);
	          self.ZHC_SUB(tempb,self.r.va.l,false);
	          self.r.va.l:=tempb;
	          self.r.hl.w:=self.r.hl.w-1;
          end;
      $e9:begin //NEAX_B
            tempb:=self.r.va.l-self.getbyte(self.r.bc.w);
	          self.ZHC_SUB(tempb,self.r.va.l,false);
          	if not(self.r.psw.zf) then self.r.psw.sk:=true; //SKIP_NZ
          end;
      $ea:begin //NEAX_D
            tempb:=self.r.va.l-self.getbyte(self.r.de.w);
	          self.ZHC_SUB(tempb,self.r.va.l,false);
          	if not(self.r.psw.zf) then self.r.psw.sk:=true; //SKIP_NZ
          end;
      $eb:begin //NEAX_H
            tempb:=self.r.va.l-self.getbyte(self.r.hl.w);
	          self.ZHC_SUB(tempb,self.r.va.l,false);
          	if not(self.r.psw.zf) then self.r.psw.sk:=true; //SKIP_NZ
          end;
      $ec:begin //NEAX_Dp
            tempb:=self.r.va.l-self.getbyte(self.r.de.w);
            self.r.de.w:=self.r.de.w+1;
	          self.ZHC_SUB(tempb,self.r.va.l,false);
          	if not(self.r.psw.zf) then self.r.psw.sk:=true; //SKIP_NZ
          end;
      $ed:begin //NEAX_Hp
            tempb:=self.r.va.l-self.getbyte(self.r.hl.w);
            self.r.hl.w:=self.r.hl.w+1;
	          self.ZHC_SUB(tempb,self.r.va.l,false);
          	if not(self.r.psw.zf) then self.r.psw.sk:=true; //SKIP_NZ
          end;
      $f2:begin //SBBX_D
            tempb:=self.r.va.l-self.getbyte(self.r.de.w)-byte(self.r.psw.cy);
	          self.ZHC_SUB(tempb,self.r.va.l,self.r.psw.cy);
	          self.r.va.l:=tempb;
          end;
      $f3:begin //SBBX_H
            tempb:=self.r.va.l-self.getbyte(self.r.hl.w)-byte(self.r.psw.cy);
	          self.ZHC_SUB(tempb,self.r.va.l,self.r.psw.cy);
	          self.r.va.l:=tempb;
          end;
      $f4:begin //SBBX_Dp
            tempb:=self.r.va.l-self.getbyte(self.r.de.w)-byte(self.r.psw.cy);
            self.r.de.w:=self.r.de.w+1;
	          self.ZHC_SUB(tempb,self.r.va.l,self.r.psw.cy);
	          self.r.va.l:=tempb;
          end;
      $f7:begin //SBBX_Hm
            tempb:=self.r.va.l-self.getbyte(self.r.hl.w)-byte(self.r.psw.cy);
            self.r.hl.w:=self.r.hl.w-1;
	          self.ZHC_SUB(tempb,self.r.va.l,self.r.psw.cy);
	          self.r.va.l:=tempb;
          end;
      $f9:begin //EQAX_B
            tempb:=self.r.va.l-self.getbyte(self.r.bc.w);
	          self.ZHC_SUB(tempb,self.r.va.l,false);
	          if self.r.psw.zf then self.r.psw.sk:=true; //SKIP_Z
          end;
      $fa:begin //EQAX_D
            tempb:=self.r.va.l-self.getbyte(self.r.de.w);
	          self.ZHC_SUB(tempb,self.r.va.l,false);
	          if self.r.psw.zf then self.r.psw.sk:=true; //SKIP_Z
          end;
      $fb:begin //EQAX_H
            tempb:=self.r.va.l-self.getbyte(self.r.hl.w);
	          self.ZHC_SUB(tempb,self.r.va.l,false);
	          if self.r.psw.zf then self.r.psw.sk:=true; //SKIP_Z
          end;
      $fc:begin //EQAX_Dp
            tempb:=self.r.va.l-self.getbyte(self.r.de.w);
	          self.r.de.w:=self.r.de.w+1;
	          self.ZHC_SUB(tempb,self.r.va.l,false);
            if self.r.psw.zf then self.r.psw.sk:=true; //SKIP_Z
          end;
      $fd:begin //EQAX_Hp
            tempb:=self.r.va.l-self.getbyte(self.r.hl.w);
            self.r.hl.w:=self.r.hl.w+1;
	          self.ZHC_SUB(tempb,self.r.va.l,false);
            if self.r.psw.zf then self.r.psw.sk:=true; //SKIP_Z
          end;
      $fe:begin //EQAX_Dm
            tempb:=self.r.va.l-self.getbyte(self.r.de.w);
	          self.r.de.w:=self.r.de.w-1;
	          self.ZHC_SUB(tempb,self.r.va.l,false);
            if self.r.psw.zf then self.r.psw.sk:=true; //SKIP_Z
          end;
      $ff:begin //EQAX_Hm
            tempb:=self.r.va.l-self.getbyte(self.r.hl.w);
	          self.r.hl.w:=self.r.hl.w-1;
	          self.ZHC_SUB(tempb,self.r.va.l,false);
            if self.r.psw.zf then self.r.psw.sk:=true; //SKIP_Z
          end;
      else MessageDlg('Instruccion 70: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
  end;
end;
procedure cpu_upd7810.opcode_74;
var
  instruccion:byte;
  tempw:word;
  tempb:byte;
begin
 instruccion:=self.getbyte(self.pc);
 self.pc:=self.pc+1;
 if self.cpu_type=CPU_7810 then begin
  case instruccion of
     $9:self.ANI_X(@self.r.va.l);
     $11:self.XRI_X(@self.r.va.l);
     $19:self.ORI_X(@self.r.va.l);
     $29:self.GTI_X(@self.r.va.l);
     $41:self.ADI_X(@self.r.va.l);
     $49:self.ONI_X(@self.r.va.l);
     $59:self.OFFI_X(@self.r.va.l);
     $61:self.SUI_X(@self.r.va.l);
     $69:self.NEI_X(@self.r.va.l);
     $79:self.EQI_X(@self.r.va.l);
     $c6:begin //DADD_EA_DE
           tempw:=self.r.ea+self.r.de.w;
	         ZHC_ADD(tempw,self.r.ea,false);
	         self.r.ea:=tempw;
        end;
     $c7:begin //DADD_EA_HL
           tempw:=self.r.ea+self.r.hl.w;
           ZHC_ADD(tempw,self.r.ea,false);
           self.r.ea:=tempw;
         end;
      else MessageDlg('Instruccion 74: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
  end;
 end else begin
  case instruccion of
    $88:begin //ANAW_wa
            tempw:=(self.r.va.h shl 8) or self.getbyte(self.pc);
            self.pc:=self.pc+1;
            self.r.va.l:=self.r.va.l and self.getbyte(tempw);
            self.r.psw.zf:=(self.r.va.l=0);
        end;
    $90:begin //XRAW_wa
            tempw:=(self.r.va.h shl 8) or self.getbyte(self.pc);
            self.pc:=self.pc+1;
            self.r.va.l:=self.r.va.l xor self.getbyte(tempw);
            self.r.psw.zf:=(self.r.va.l=0); //SET_Z
        end;
    $98:begin //ORAW_wa
            tempw:=(self.r.va.h shl 8) or self.getbyte(self.pc);
            self.pc:=self.pc+1;
            self.r.va.l:=self.r.va.l or self.getbyte(tempw);
            self.r.psw.zf:=(self.r.va.l=0); //SET_Z
        end;
    $a0:begin //ADDNCW_wa
            tempw:=(self.r.va.h shl 8) or self.getbyte(self.pc);
            self.pc:=self.pc+1;
            tempb:=self.r.va.l+self.getbyte(tempw);
	          self.ZHC_ADD(tempb,self.r.va.l,false);
	          self.r.va.l:=tempb;
	          if not(self.r.psw.cy) then self.r.psw.sk:=true; //SKIP_NC;
        end;
    $a8:begin //GTAW_wa
            tempw:=(self.r.va.h shl 8) or self.getbyte(self.pc);
            self.pc:=self.pc+1;
            tempb:=self.getbyte(tempw);
            tempw:=self.r.va.l-tempb-1;
	          self.ZHC_SUB(tempw,self.r.va.l,false);
	          if not(self.r.psw.cy) then self.r.psw.sk:=true; //SKIP_NC;
        end;
    $b0:begin //SUBNBW_wa
            tempw:=(self.r.va.h shl 8) or self.getbyte(self.pc);
            self.pc:=self.pc+1;
            tempb:=self.r.va.l-self.getbyte(tempw);
	          ZHC_SUB(tempb,self.r.va.l,false);
	          self.r.va.l:=tempb;
            if not(self.r.psw.cy) then self.r.psw.sk:=true; //SKIP_NC;
        end;
    $b8:begin //LTAW_wa
            tempw:=(self.r.va.h shl 8) or self.getbyte(self.pc);
            self.pc:=self.pc+1;
            tempb:=self.r.va.l-self.getbyte(tempw);
	          self.ZHC_SUB(tempb,self.r.va.l,false);
            if self.r.psw.cy then self.r.psw.sk:=true;  //SKIP_CY
        end;
    $c0:begin //ADDW_wa
            tempw:=(self.r.va.h shl 8) or self.getbyte(self.pc);
            self.pc:=self.pc+1;
            tempb:=self.r.va.l+self.getbyte(tempw);
            ZHC_ADD(tempb,self.r.va.l,false);
            self.r.va.l:=tempb;
         end;
    $c8:begin //ONAW_wa
            tempw:=(self.r.va.h shl 8) or self.getbyte(self.pc);
            self.pc:=self.pc+1;
            if (self.r.va.l and self.getbyte(tempw))<>0 then begin
              self.r.psw.zf:=false;
              self.r.psw.sk:=true;
            end else self.r.psw.zf:=true;
        end;
    $d0:begin //ADCW_wa
            tempw:=(self.r.va.h shl 8) or self.getbyte(self.pc);
            self.pc:=self.pc+1;
            tempb:=self.r.va.l+getbyte(tempw)+byte(self.r.psw.cy);
            ZHC_ADD(tempb,self.r.va.l,self.r.psw.cy);
            self.r.va.l:=tempb;
        end;
    $d8:begin //OFFAW_wa
            tempw:=(self.r.va.h shl 8) or self.getbyte(self.pc);
            self.pc:=self.pc+1;
	          if (self.r.va.l and self.getbyte(tempw))<>0 then self.r.psw.zf:=false
	          else begin
              self.r.psw.zf:=true;
              self.r.psw.sk:=true;
            end;
        end;
    $e0:begin //SUBW_wa
            tempw:=(self.r.va.h shl 8) or self.getbyte(self.pc);
            self.pc:=self.pc+1;
	          tempb:=self.r.va.l-self.getbyte(tempw);
	          self.ZHC_SUB(tempb,self.r.va.l,false);
	          self.r.va.l:=tempb;
        end;
    $e8:begin //NEAW_wa
            tempw:=(self.r.va.h shl 8) or self.getbyte(self.pc);
            self.pc:=self.pc+1;
            tempb:=self.r.va.l-self.getbyte(tempw);
	          self.ZHC_SUB(tempb,self.r.va.l,false);
            if not(self.r.psw.zf) then self.r.psw.sk:=true; //SKIP_NZ;
        end;
    $f8:begin //EQAW_wa
            tempw:=(self.r.va.h shl 8) or self.getbyte(self.pc);
            self.pc:=self.pc+1;
            tempb:=self.r.va.l-self.getbyte(tempw);
	          self.ZHC_SUB(tempb,self.r.va.l,false);
            if self.r.psw.zf then self.r.psw.sk:=true; //SKIP_Z
        end;
    else MessageDlg('Instruccion 74: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.ppc,10), mtInformation,[mbOk], 0);
  end;
 end;
end;

function cpu_upd7810.save_snapshot(data:pbyte):word;
var
  temp:pbyte;
  buffer:array[0..75] of byte;
  size:word;
begin
temp:=data;
copymemory(temp,self.r,sizeof(nreg_upd7810));
inc(temp,sizeof(nreg_upd7810));
size:=sizeof(nreg_upd7810);
copymemory(temp,@ram[0],$100);
inc(temp,$100);
size:=size+$100;
buffer[0]:=self.cpu_type;
copymemory(@buffer[1],@self.ppc,2);
copymemory(@buffer[3],@self.pc,2);
copymemory(@buffer[5],@self.sp,2);
buffer[7]:=byte(self.iff);
buffer[8]:=byte(self.iff_pending);
copymemory(@buffer[9],@self.adcnt,2);
copymemory(@buffer[11],@self.irr,2);
buffer[13]:=self.adtot;
buffer[14]:=self.tmpcr;
buffer[15]:=self.mkl;
buffer[16]:=self.mkh;
copymemory(@buffer[17],@self.tm,2);
copymemory(@buffer[19],@self.cnt,2);
copymemory(@buffer[21],@self.ecnt,2);
buffer[23]:=self.panm;
buffer[24]:=self.anm;
buffer[25]:=self.mm;
buffer[26]:=self.mf;
buffer[27]:=self.ci;
buffer[28]:=self.smh;
buffer[29]:=self.sml;
buffer[30]:=self.ma;
buffer[31]:=self.mb;
buffer[32]:=self.mc;
buffer[33]:=self.mcc;
buffer[34]:=self.etmm;
buffer[35]:=self.tmm;
buffer[36]:=self.pa_in;
buffer[37]:=self.pb_in;
buffer[38]:=self.pc_in;
buffer[39]:=self.pd_in;
buffer[40]:=self.pf_in;
buffer[41]:=self.pa_out;
buffer[42]:=self.pb_out;
buffer[43]:=self.pc_out;
buffer[44]:=self.pd_out;
buffer[45]:=self.pf_out;
buffer[46]:=self.txd;
buffer[47]:=self.rdx;
buffer[48]:=self.sck;
buffer[49]:=self.to_;
buffer[50]:=self.co0;
buffer[51]:=self.co1;
copymemory(@buffer[52],@self.adout,4);
copymemory(@buffer[56],@self.adin,4);
copymemory(@buffer[60],@self.adrange,4);
copymemory(@buffer[64],@self.ovc0,4);
buffer[68]:=byte(self.shdone);
copymemory(@buffer[69],@self.cr,4);
buffer[73]:=self.nmi;
buffer[74]:=self.int1;
buffer[75]:=self.int2;
copymemory(temp,@buffer[0],76);
save_snapshot:=size+76;
end;

procedure cpu_upd7810.load_snapshot(data:pbyte);
var
  temp:pbyte;
  buffer:array[0..75] of byte;
  size:word;
begin
temp:=data;
copymemory(self.r,temp,sizeof(nreg_upd7810));
inc(temp,sizeof(nreg_upd7810));
copymemory(@ram[0],temp,$100);
inc(temp,$100);
copymemory(@buffer[0],temp,76);
self.cpu_type:=buffer[0];
copymemory(@self.ppc,@buffer[1],2);
copymemory(@self.pc,@buffer[3],2);
copymemory(@self.sp,@buffer[5],2);
self.iff:=buffer[7]<>0;
self.iff_pending:=buffer[8]<>0;
copymemory(@self.adcnt,@buffer[9],2);
copymemory(@self.irr,@buffer[11],2);
self.adtot:=buffer[13];
self.tmpcr:=buffer[14];
self.mkl:=buffer[15];
self.mkh:=buffer[16];
copymemory(@self.tm,@buffer[17],2);
copymemory(@self.cnt,@buffer[19],2);
copymemory(@self.ecnt,@buffer[21],2);
self.panm:=buffer[23];
self.anm:=buffer[24];
self.mm:=buffer[25];
self.mf:=buffer[26];
self.ci:=buffer[27];
self.smh:=buffer[28];
self.sml:=buffer[29];
self.ma:=buffer[30];
self.mb:=buffer[31];
self.mc:=buffer[32];
self.mcc:=buffer[33];
self.etmm:=buffer[34];
self.tmm:=buffer[35];
self.pa_in:=buffer[36];
self.pb_in:=buffer[37];
self.pc_in:=buffer[38];
self.pd_in:=buffer[39];
self.pf_in:=buffer[40];
self.pa_out:=buffer[41];
self.pb_out:=buffer[42];
self.pc_out:=buffer[43];
self.pd_out:=buffer[44];
self.pf_out:=buffer[45];
self.txd:=buffer[46];
self.rdx:=buffer[47];
self.sck:=buffer[48];
self.to_:=buffer[49];
self.co0:=buffer[50];
self.co1:=buffer[51];
copymemory(@self.adout,@buffer[52],4);
copymemory(@self.adin,@buffer[56],4);
copymemory(@self.adrange,@buffer[60],4);
copymemory(@self.ovc0,@buffer[64],4);
self.shdone:=buffer[68]<>0;
copymemory(@self.cr,@buffer[69],4);
self.nmi:=buffer[73];
self.int1:=buffer[74];
self.int2:=buffer[75];
end;

end.
