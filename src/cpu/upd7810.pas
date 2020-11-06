unit upd7810;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     cpu_misc,vars_hide,main_engine,timer_engine,dialogs,sysutils,upd7810_tables;

type
  band_upd7810 = record
     zf,f1,f7,sk,hc,l1,l0,cy:boolean;
  end;
  nreg_upd7810=packed record
        psw:band_upd7810;
        va,bc,de,hl,bc2,de2,hl2:parejas;
        ea:word;
  end;
  upd7810_cb=function:byte;
  upd7810_cb_2=procedure(valor:byte);
  upd7810_cb_3=function(mask:byte):byte;
  npreg_upd7810=^nreg_upd7810;
  cpu_upd7810=class(cpu_class)
                constructor create(clock:dword;frames_div:single);
                destructor free;
              public
                ram:array[0..$ff] of byte;
                procedure reset;
                procedure run(maximo:single);
                procedure change_an(an0,an1,an2,an3,an4,an5,an6,an7:upd7810_cb);
                procedure change_in(ca,cb,cc,cd,cf:upd7810_cb_3);
                procedure set_input_line(irqline,state:byte);
              private
                ppc,pc,sp:word;
                iff,iff_pending:boolean;
                adcnt,irr:word;
	              adtot,tmpcr,mkl,mkh:byte;
                cnt,ecnt:parejas;
                panm,anm,mm,mf,ci,smh,sml:byte;
                ma,mb,mc,mcc:byte;
                etmm,tmm:byte;
                pa_in,pb_in,pc_in,pd_in,pf_in:byte;
	              pa_out,pb_out,pc_out,pd_out,pf_out:byte;
                txd,rdx,sck,to_,co0,co1:byte;
                adout,adin,adrange:integer;
                shdone:boolean;
                r:npreg_upd7810;
                an_func:array[0..7] of upd7810_cb;
                cr:array[0..3] of byte;
                pa_out_cb,pb_out_cb,pc_out_cb,pd_out_cb,pf_out_cb:upd7810_cb_2;
                pa_in_cb,pb_in_cb,pc_in_cb,pd_in_cb,pf_in_cb:upd7810_cb_3;
                nmi,int1,int2:byte;
                procedure take_irq;
                procedure opcode_48;
                procedure opcode_4c;
                procedure opcode_4d;
                procedure opcode_60;
                procedure opcode_64;
                procedure opcode_70;
                procedure opcode_74;
                procedure handle_timers(estados:byte);
                procedure write_port(port,valor:byte);
                function read_port(port:byte):byte;
                procedure ZHC_SUB(after,before:word;carry:boolean);
                procedure ZHC_ADD(after,before:word;carry:boolean);
                function dame_band:byte;
                procedure poner_band(valor:byte);
                procedure EQI_A;
                procedure NEI_A;
                procedure ANI_A;
                procedure XRI_A;
                procedure GTI_A;
                procedure OFFI_A;
                procedure ONI_A;
                procedure ORI_A;
                procedure SUI_A;
                procedure ADI_A;
            end;

const
  UPD7810_INTF1=0;
  UPD7810_INTF2=1;
  UPD7810_INTF0=2;
  UPD7810_INTFE1=4;

implementation

const
  INTNMI  = $0001;
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

constructor cpu_upd7810.create(clock:dword;frames_div:single);
begin
  getmem(self.r,sizeof(nreg_upd7810));
  fillchar(self.r^,sizeof(nreg_upd7810),0);
  self.numero_cpu:=cpu_main_init(clock div 3);
  self.clock:=clock div 3;
  self.tframes:=(clock/3/frames_div)/llamadas_maquina.fps_max;
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
  self.int2:=1; //Invertido!!!!
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
		                if ((self.nmi=CLEAR_LINE) and (state=ASSERT_LINE)) then self.irr:=self.irr or INTNMI;
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

procedure cpu_upd7810.take_irq;
var
	vector:word;
	irqline:integer;
begin
  vector:=0;
  irqline:=0;
	// global interrupt disable? */
	if not(self.iff) and ((self.irr and INTNMI)=0) then exit;
	// check the interrupts in priority sequence */
	if (self.irr and INTNMI)<>0 then begin
		// Nonmaskable interrupt */
		irqline:=INPUT_LINE_NMI;
		vector:=$0004;
		self.irr:=self.irr and not(INTNMI);
	end else
	  if (((self.irr and INTFT0)<>0) and ((self.mkl and $02)=0)) then begin
		  vector:=$0008;
		  if (self.mkl and $4)<>0 then self.irr:=self.irr and not(INTFT0);
	  end else
	    if (((self.irr and INTFT1)<>0) and ((self.mkl and $04)=0)) then begin
		    vector:=$0008;
		    if (self.mkl and $2)<>0 then self.irr:=self.irr and not(INTF1);
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

procedure cpu_upd7810.handle_timers(estados:byte);
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
      // volfied code checks bit 0x80, old code set bit 0x01, TODO: verify which bits are set on real hw
      if self.tmpcr<>0 then self.cr[self.adout]:=$ff
        else self.cr[self.adout]:=0;
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
      if self.tmpcr<>0 then self.cr[self.adout]:=$ff
        else self.cr[self.adout]:=0;
			self.adin:=(self.adin+1) and $07;
			self.adout:=(self.adout+1) and $03;
			if (self.adout=0) then self.irr:=self.irr or INTFAD;
			self.shdone:=false;
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
		                valor:=(valor and not(self.ma)) or self.ma; // NS20031401
		                if addr(self.pa_out_cb)<>nil then self.pa_out_cb(valor);
                  end;
	  UPD7810_PORTB:begin
		                self.pb_out:=valor;
		                valor:=(valor and not(self.mb)) or self.mb; // NS20031401
		                if addr(self.pb_out_cb)<>nil then self.pb_out_cb(valor);
		              end;
	  UPD7810_PORTC:begin
		                self.pc_out:=valor;
		                valor:=(valor and not(self.mc)) or self.mc; // NS20031401
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
		                    $00:valor:=self.pd_in; // PD input mode, PF port mode
                        $01:valor:=self.pd_out; // PD output mode, PF port mode
		                      else exit; // PD extension mode, PF port/extension mode
		                end;
                    if addr(self.pd_out_cb)<>nil then self.pd_out_cb(valor);
                  end;
	  UPD7810_PORTF:begin
                    self.pf_out:=valor;
                    valor:=(valor and not(self.mf)) or (self.pf_in and self.mf);
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

procedure cpu_upd7810.EQI_A;
var
  tempb:byte;
begin
  tempb:=self.r.va.l-self.getbyte(self.pc);
  self.pc:=self.pc+1;
  ZHC_SUB(tempb,self.r.va.l,false);
  //SKIP_Z
  if self.r.psw.zf then self.r.psw.sk:=true;
end;

procedure cpu_upd7810.NEI_A;
var
	tempb:byte;
begin
  tempb:=self.r.va.l-self.getbyte(self.pc);
  self.pc:=self.pc+1;
  ZHC_SUB(tempb,self.r.va.l,false);
  //SKIP_NZ;
  if not(self.r.psw.zf) then self.r.psw.sk:=true;
end;

procedure cpu_upd7810.ANI_A;
begin
  self.r.va.l:=self.r.va.l and self.getbyte(self.pc);
  self.pc:=self.pc+1;
  self.r.psw.zf:=(self.r.va.l=0);
end;

procedure cpu_upd7810.XRI_A;
begin
  self.r.va.l:=self.r.va.l xor self.getbyte(self.pc);
  self.pc:=self.pc+1;
  self.r.psw.zf:=(self.r.va.l=0);
end;

procedure cpu_upd7810.GTI_A;
var
  tempw:word;
begin
  tempw:=self.r.va.l-self.getbyte(self.pc)-1;
  self.pc:=self.pc+1;
  ZHC_SUB(tempw,self.r.va.l,false);
  //SKIP_NC;
  if not(self.r.psw.cy) then self.r.psw.sk:=true;
end;

procedure cpu_upd7810.OFFI_A;
var
  tempb:byte;
begin
  tempb:=self.getbyte(self.pc);
  self.pc:=self.pc+1;
  if ((self.r.va.l and tempb)=0) then self.r.psw.sk:=true;
end;

procedure cpu_upd7810.ONI_A;
var
  tempb:byte;
begin
  tempb:=self.getbyte(self.pc);
  self.pc:=self.pc+1;
  if ((self.r.va.l and tempb)<>0) then self.r.psw.sk:=true;
end;

procedure cpu_upd7810.ORI_A;
begin
  self.r.va.l:=self.r.va.l or self.getbyte(self.pc);
  self.pc:=self.pc+1;
  self.r.psw.zf:=(self.r.va.l=0);
end;

procedure cpu_upd7810.SUI_A;
var
  tempb:byte;
begin
  tempb:=self.r.va.l-self.getbyte(self.pc);
  self.pc:=self.pc+1;
  ZHC_SUB(tempb,self.r.va.l,false);
  self.r.va.l:=tempb;
end;

procedure cpu_upd7810.ADI_A;
var
  tempb:byte;
begin
  tempb:=self.r.va.l+self.getbyte(self.pc);
  self.pc:=self.pc+1;
  ZHC_ADD(tempb,self.r.va.l,false);
  self.r.va.l:=tempb;
end;

procedure cpu_upd7810.run(maximo:single);
var
  instruccion,tempb:byte;
  tempw:word;
begin
self.contador:=0;
while self.contador<maximo do begin
  self.ppc:=self.pc;
  instruccion:=self.getbyte(self.pc);
  self.pc:=self.pc+1;
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
  case instruccion of
      $48:self.estados_demas:=ops_48[tempb].t;
      $4c:self.estados_demas:=ops_4c[tempb].t;
      $4d:self.estados_demas:=ops_4d[tempb].t;
      $60:self.estados_demas:=ops_60[tempb].t;
      $64:self.estados_demas:=ops_64[tempb].t;
      $70:self.estados_demas:=ops_70[tempb].t;
      $74:self.estados_demas:=ops_74[tempb].t;
        else self.estados_demas:=main_ops[instruccion].t;
  end;
  self.handle_timers(self.estados_demas);
  if (self.r.psw.sk and (instruccion<>$72)) then begin
   //Skip, no hacer nada!
   tempb:=self.getbyte(self.pc);
   case instruccion of
      $48:self.pc:=self.pc+(ops_48[tempb].s-1);
      $4c:self.pc:=self.pc+(ops_4c[tempb].s-1);
      $4d:self.pc:=self.pc+(ops_4d[tempb].s-1);
      $60:self.pc:=self.pc+(ops_60[tempb].s-1);
      $64:self.pc:=self.pc+(ops_64[tempb].s-1);
      $70:self.pc:=self.pc+(ops_70[tempb].s-1);
      $74:self.pc:=self.pc+(ops_74[tempb].s-1);
        else self.pc:=self.pc+(main_ops[instruccion].s-1);
   end;
   self.r.psw.sk:=false;
  end else begin
   case instruccion of
    $0:; //nop
    $4:begin //LXI_S
          self.sp:=self.getbyte(self.pc) or (self.getbyte(self.pc+1) shl 8);
          self.pc:=self.pc+2;
       end;
    $7:self.ANI_A;
    $a:self.r.va.l:=self.r.bc.h; //MOV_A_B
    $b:self.r.va.l:=self.r.bc.l; //MOV_A_C
    $c:self.r.va.l:=self.r.de.h; //MOV_A_D
    $d:self.r.va.l:=self.r.de.l; //MOV_A_E
    $e:self.r.va.l:=self.r.hl.h; //MOV_A_H
    $f:self.r.va.l:=self.r.hl.l; //MOV_A_L
    $11:begin //EXX
          tempw:=self.r.bc.w;self.r.bc.w:=self.r.bc2.w;self.r.bc2.w:=tempw;
          tempw:=self.r.de.w;self.r.de.w:=self.r.de2.w;self.r.de2.w:=tempw;
          tempw:=self.r.hl.w;self.r.hl.w:=self.r.hl2.w;self.r.hl2.w:=tempw;
        end;
    $13:self.r.bc.w:=self.r.bc.w-1; //DCX_BC
    $14:begin //LXI_B
          self.r.bc.l:=self.getbyte(self.pc);
          self.r.bc.h:=self.getbyte(self.pc+1);
          self.pc:=self.pc+2;
        end;
    $16:self.XRI_A;
    $17:self.ORI_A;
    $1a:self.r.bc.h:=self.r.va.l; //MOV_B_A
    $1b:self.r.bc.l:=self.r.va.l; //MOV_C_A
    $1c:self.r.de.h:=self.r.va.l; //MOV_D_A
    $1d:self.r.de.l:=self.r.va.l; //MOV_E_A
    $1e:self.r.hl.h:=self.r.va.l; //MOV_H_A
    $1f:self.r.hl.l:=self.r.va.l; //MOV_L_A
    $24:begin //LXI_D_w
          self.r.de.l:=self.getbyte(self.pc);
          self.r.de.h:=self.getbyte(self.pc+1);
          self.pc:=self.pc+2;
        end;
    $27:self.GTI_A;
    $2b:self.r.va.l:=self.getbyte(self.r.hl.w); //LDAX_H
    $2d:begin //LDAX_Hp
          self.r.va.l:=self.getbyte(self.r.hl.w);
          self.r.hl.w:=self.r.hl.w+1;
        end;
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
    $3b:self.putbyte(self.r.hl.w,self.r.va.l); //STAX_H
    $3c:begin  //STAX_Dp
          self.putbyte(self.r.de.w,self.r.va.l);
          self.r.de.w:=self.r.de.w+1;
        end;
    $3d:begin //STAX_Hp
          self.putbyte(self.r.hl.w,self.r.va.l);
          self.r.hl.w:=self.r.hl.w+1;
        end;
    $40:begin //CALL
          tempw:=self.getbyte(self.pc) or (self.getbyte(self.pc+1) shl 8);
          self.pc:=self.pc+2;
          self.sp:=self.sp-1;
          self.putbyte(self.sp,self.pc shr 8);
          self.sp:=self.sp-1;
          self.putbyte(self.sp,self.pc and $ff);
          self.pc:=tempw;
        end;
    $41:begin  //INR_A
          tempb:=self.r.va.l+1;
	        ZHC_ADD(tempb,self.r.va.l,false);
          self.r.va.l:=tempb;
	        if self.r.psw.cy then self.r.psw.sk:=true;  //SKIP_CY
        end;
    $44:begin //LXI_EA
          self.r.ea:=self.getbyte(self.pc) or (self.getbyte(self.pc+1) shl 8);
          self.pc:=self.pc+2;
        end;
    $46:self.ADI_A;
    $47:self.ONI_A;
    $48:self.opcode_48; //opc_48
    $4b:begin  //MVIX_HL
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
    $50:begin //EHX
          tempw:=self.r.hl.w;
          self.r.hl.w:=self.r.hl2.w;
          self.r.hl2.w:=tempw;
        end;
    $51:begin //DCR_A
          tempb:=self.r.va.l-1;
	        ZHC_SUB(tempb,self.r.va.l,false);
	        self.r.va.l:=tempb;
          if self.r.psw.cy then self.r.psw.sk:=true;  //SKIP_CY
        end;
    $52:begin //DCR_B
          tempb:=self.r.bc.h-1;
	        ZHC_SUB(tempb,self.r.bc.h,false);
	        self.r.bc.h:=tempb;
          if self.r.psw.cy then self.r.psw.sk:=true;  //SKIP_CY
        end;
    $53:begin //DCR_C
          tempb:=self.r.bc.l-1;
	        ZHC_SUB(tempb,self.r.bc.l,false);
	        self.r.bc.l:=tempb;
          if self.r.psw.cy then self.r.psw.sk:=true;  //SKIP_CY
        end;
    $54:self.pc:=self.getbyte(self.pc) or (self.getbyte(self.pc+1) shl 8); //jmp_w
    $57:self.OFFI_A;
    $5e:begin //BIT_6_wa
          tempw:=(self.r.va.w and $ff00) or self.getbyte(self.pc);
          self.pc:=self.pc+1;
          tempb:=self.getbyte(tempw);
          if (tempb and $40)<>0 then self.r.psw.sk:=true;
        end;
    $60:self.opcode_60;  //opc_60
    $62:begin //RETI
          self.pc:=self.getbyte(self.sp) or (self.getbyte(self.sp+1) shl 8);
          self.poner_band(self.getbyte(self.sp+2));
          self.sp:=self.sp+3;
        end;
    $64:self.opcode_64;  //opc_64
    $66:self.SUI_A;
    $67:self.NEI_A;
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
    $70:self.opcode_70;  //opc_70
    $71:begin  //MVIW_wa_xx
          tempw:=(self.r.va.w and $ff00) or self.getbyte(self.pc);
          tempb:=self.getbyte(self.pc+1);
          self.pc:=self.pc+2;
          self.putbyte(tempw,tempb);
        end;
    $74:self.opcode_74;  //opc_74
    $77:self.EQI_A;
    $80..$9f:begin  //CALT
	        tempw:=$80+2*(instruccion and $1f);
          self.sp:=self.sp-1;
          self.putbyte(self.sp,self.pc shr 8);
          self.sp:=self.sp-1;
          self.putbyte(self.sp,self.pc and $ff);
          self.pc:=self.getbyte(tempw) or (self.getbyte(tempw+1) shl 8);
        end;
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
            self.r.ea:=self.getbyte(self.sp);
            self.r.ea:=self.r.ea or (self.getbyte(self.sp+1) shl 8);
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
    $c0..$ff:self.pc:=self.pc+(shortint(instruccion shl 2) div 4); //jr
      else MessageDlg('Instruccion: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.pc,10), mtInformation,[mbOk], 0);
   end;
  end;
  self.take_irq;
  self.iff:=self.iff_pending;
  self.handle_timers(self.estados_demas);
  self.contador:=self.contador+self.estados_demas;
  timers.update(self.estados_demas,self.numero_cpu);
end;
end;

procedure cpu_upd7810.opcode_48;
var
  instruccion,tempb:byte;
  tempw:word;
begin
  instruccion:=self.getbyte(self.pc);
  self.pc:=self.pc+1;
  case instruccion of
      $7:begin //SLLC_C
            self.r.psw.cy:=(self.r.bc.l and $80)<>0;
            self.r.bc.l:=self.r.bc.l shl 1;
	          if self.r.psw.cy then self.r.psw.sk:=true; //SKIP_CY;
         end;
      $a:if self.r.psw.cy then self.r.psw.sk:=true; //SK_CY
      $c:if self.r.psw.zf then self.r.psw.sk:=true; //SK_Z
      $1a:if not(self.r.psw.cy) then self.r.psw.sk:=true; //SKN_CY
      $1c:if not(self.r.psw.zf) then self.r.psw.sk:=true; //SKN_Z
      $21:begin //SLR_A
            self.r.psw.cy:=(self.r.va.l and 1)<>0;
	          self.r.va.l:=self.r.va.l shr 1;
          end;
      $2a:self.r.psw.cy:=false; //CLC
      $2f:self.r.ea:=self.r.va.l*self.r.bc.l; //MUL_C
      $31:begin //RLR_A
            tempb:=byte(self.r.psw.cy) shl 7;
            self.r.psw.cy:=(self.r.va.l and 1)<>0;
	          self.r.va.l:=(self.r.va.l shr 1) or tempb;
          end;
      $35:begin //RLL_A
            tempb:=byte(self.r.psw.cy);
            self.r.psw.cy:=(self.r.va.l and $80)<>0;
	          self.r.va.l:=(self.r.va.l shl 1) or tempb;
          end;
      $3a:self.r.va.l:=not(self.r.va.l)+1;  //NEGA
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
      else MessageDlg('Instruccion 48: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.pc,10), mtInformation,[mbOk], 0);
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
     $c3:self.r.va.l:=self.read_port(UPD7810_PORTD); //MOV_A_PD
     $c5:self.r.va.l:=self.read_port(UPD7810_PORTF); //MOV_A_PF
     $e0:self.r.va.l:=self.cr[0]; //MOV_A_CR0
     $e1:self.r.va.l:=self.cr[1]; //MOV_A_CR1
     $e2:self.r.va.l:=self.cr[2]; //MOV_A_CR2
     $e3:self.r.va.l:=self.cr[3]; //MOV_A_CR3
      else MessageDlg('Instruccion 4C: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.pc,10), mtInformation,[mbOk], 0);
  end;
end;

procedure cpu_upd7810.opcode_4d;
var
  instruccion:byte;
begin
  instruccion:=self.getbyte(self.pc);
  self.pc:=self.pc+1;
  case instruccion of
    $c0:self.write_port(UPD7810_PORTA,self.r.va.l);
    $c1:self.write_port(UPD7810_PORTB,self.r.va.l);
    $c2:self.write_port(UPD7810_PORTC,self.r.va.l);
    $d0:self.mm:=self.r.va.l; //MOV_MM_A
    $d2:self.ma:=self.r.va.l; //MOV_MA_A
    $d3:self.mb:=self.r.va.l; //MOV_MA_B
    $d4:self.mc:=self.r.va.l; //MOV_MA_C
    $d7:self.mf:=self.r.va.l; //MOV_MF_A
      else MessageDlg('Instruccion 4D: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.pc,10), mtInformation,[mbOk], 0);
  end;
end;

procedure cpu_upd7810.opcode_60;
var
  instruccion:byte;
  tempb:byte;
begin
  instruccion:=self.getbyte(self.pc);
  self.pc:=self.pc+1;
  case instruccion of
      $11,$91:begin //XRA_A_A
            self.r.va.l:=self.r.va.l xor self.r.va.l;
            self.r.psw.zf:=(self.r.va.l=0);
          end;
      $1a:begin //ORA_B_A
            self.r.bc.h:=self.r.bc.h or self.r.va.l;
	          self.r.psw.zf:=(self.r.bc.h=0);
          end;
      $41,$c1:begin  //ADD_A_A
            tempb:=self.r.va.l+self.r.va.l;
	          ZHC_ADD(tempb,self.r.va.l,false);
	          self.r.va.l:=tempb;
          end;
      $93:begin //XRA_A_C
            self.r.va.l:=self.r.va.l xor self.r.bc.l;
            self.r.psw.zf:=(self.r.va.l=0);
          end;
      $9a:begin //ORA_A_B
            self.r.va.l:=self.r.va.l or self.r.bc.h;
            self.r.psw.zf:=(self.r.va.l=0);
          end;
      $9b:begin //ORA_A_C
            self.r.va.l:=self.r.va.l or self.r.bc.l;
            self.r.psw.zf:=(self.r.va.l=0);
          end;
      $9e:begin //ORA_A_H
            self.r.va.l:=self.r.va.l or self.r.hl.h;
            self.r.psw.zf:=(self.r.va.l=0);
          end;
      $c2:begin //ADD_A_B
            tempb:=self.r.va.l+self.r.bc.h;
	          ZHC_ADD(tempb,self.r.va.l,false);
	          self.r.va.l:=tempb;
          end;
      $c3:begin //ADD_A_C
            tempb:=self.r.va.l+self.r.bc.l;
	          ZHC_ADD(tempb,self.r.va.l,false);
	          self.r.va.l:=tempb;
          end;
      $c7:begin //ADD_A_L
            tempb:=self.r.va.l+self.r.hl.l;
	          ZHC_ADD(tempb,self.r.va.l,false);
            self.r.va.l:=tempb;
          end;
      $d2:begin  //ADC_A_B
            tempb:=self.r.va.l+self.r.bc.h+byte(self.r.psw.cy);
	          ZHC_ADD(tempb,self.r.va.l,self.r.psw.cy);
	          self.r.va.l:=tempb;
          end;
      $ea:begin //NEA_A_B
            tempb:=self.r.va.l-self.r.bc.h;
	          ZHC_SUB(tempb,self.r.va.l,false);
            if not(self.r.psw.zf) then self.r.psw.sk:=true;
          end;
      else MessageDlg('Instruccion 60: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.pc,10), mtInformation,[mbOk], 0);
  end;
end;

procedure cpu_upd7810.opcode_64;
var
  instruccion,tempb:byte;
begin
  instruccion:=self.getbyte(self.pc);
  self.pc:=self.pc+1;
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
    else MessageDlg('Instruccion 64: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.pc,10), mtInformation,[mbOk], 0);
  end;
end;

procedure cpu_upd7810.opcode_70;
var
  instruccion:byte;
  tempw:word;
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
      $41:begin //EADD_EA_A
	          tempw:=self.r.ea+self.r.va.l;
	          ZHC_ADD(tempw,self.r.ea,false);
	          self.r.ea:=tempw;
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
      else MessageDlg('Instruccion 70: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.pc,10), mtInformation,[mbOk], 0);
  end;
end;

procedure cpu_upd7810.opcode_74;
var
  instruccion:byte;
  tempw:word;
begin
  instruccion:=self.getbyte(self.pc);
  self.pc:=self.pc+1;
  case instruccion of
     $9:self.ANI_A;
     $11:self.XRI_A;
     $19:self.ORI_A;
     $29:self.GTI_A;
     $41:self.ADI_A;
     $49:self.ONI_A;
     $59:self.OFFI_A;
     $61:self.SUI_A;
     $69:self.NEI_A;
     $79:self.EQI_A;
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
      else MessageDlg('Instruccion 74: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(self.pc,10), mtInformation,[mbOk], 0);
  end;
end;

end.
