unit nec_v20_v30;
{
v1.1
 Añadidos muchos opcodes
 Añadidos al reset todos los registros
v1.2
Corregidos opcodes $f2 y $f3
}

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     main_engine,dialogs,sysutils,vars_hide,cpu_misc,timer_engine;

const
  NEC_V20=0;
  NEC_V30=1;
  NEC_V33=2;
  NMI_IRQ=1;
  INT_IRQ=2;

type
        band_nec=record
          SignVal,AuxVal,OverVal,ZeroVal,CarryVal,ParityVal,t,i,d,m:boolean;
        end;
        reg_nec=record
            eo,ip,old_pc:word;
            aw,cw,dw,bw:parejas;
            sp,bp,ix,iy:parejas;
            f:band_nec;
            ds1_r,ps_r,ds0_r,ss_r:word;
            ea:dword;
        end;
        preg_nec=^reg_nec;
        cpu_nec=class(cpu_class)
            constructor create(clock:dword;tipo:byte);
            destructor free;
          public
            procedure reset;
            procedure run(maximo:single);
            procedure change_ram_calls(getbyte:tgetbyte16;putbyte:tputbyte16);
            procedure change_io_calls(inbyte:tgetbyte;outbyte:tputbyte);
            procedure change_io_calls16(inword:tgetword;outword:tputword);
            procedure set_input(irqline,state:byte;vect_req:byte=$ff);
          private
            getbyte:tgetbyte16;
            putbyte:tputbyte16;
            r:preg_nec;
            prefetch_size,prefetch_cycles,tipo_cpu:byte;
            prefix_base:dword;
            prefetch_count:integer;
            prefetch_reset,seg_prefix:boolean;
            no_interrupt:boolean;
            irq_pending:byte;
            inbyte:tgetbyte;
            outbyte:tputbyte;
            inword:tgetword;
            outword:tputword;
            vect_req:byte;
            //procedure init_nec(tipo:byte);
            procedure nec_interrupt(vect_num:word);
            procedure GetEA(ModRM:byte);
            procedure write_word(dir:dword;x:word);
            function read_word(dir:dword):word;
            function fetch:byte;
            function fetchword:word;
            procedure do_prefetch(previous_icount:integer);
            function DefaultBase(Seg:byte):dword;
            procedure CLKW(v20o,v30o,v33o,v20e,v30e,v33e:byte;addr:word);
            procedure CLKM(v20,v30,v33,v20m,v30m,v33m,ModRM:byte);
            procedure CLKR(v20o,v30o,v33o,v20e,v30e,v33e,vall:byte;ModRM:byte);
            procedure CLKS(clk_v20,clk_v30,clk_v33:byte);
            function RegByte(ModRM:byte):byte;
            function GetRMByte(ModRM:byte):byte;
            function RegWord(ModRM:byte):word;
            function GetRMWord(ModRM:byte):word;
            procedure PutRMWord(ModRM:byte;valor:word);
            procedure PutbackRMByte(ModRM,valor:byte);
            procedure PutBackRegByte(ModRM,valor:byte);
            procedure PutbackRMWord(ModRM:byte;valor:word);
            procedure PutBackRegWord(ModRM:byte;valor:word);
            procedure PutRMByte(ModRM,valor:byte);
            procedure PutImmRMByte(ModRM:byte);
            procedure PutImmRMWord(ModRM:byte);
            procedure SetSZPF_Byte(x:byte);
            procedure SetSZPF_Word(x:word);
            function GetMemB(Seg:byte;Off:word):byte;
            function GetMemW(Seg:byte;Off:word):word;
            procedure PutMemB(Seg:byte;Off:word;x:byte);
            procedure PutMemW(Seg:byte;Off,x:word);
            function IncWordReg(tmp:word):word;
            function DecWordReg(tmp:word):word;
            function ANDB(src,dst:byte):byte;
            function ANDW(src,dst:word):word;
            function ADDB(src:word;dst:byte):byte;
            function ADDW(src:dword;dst:word):word;
            function ORB(src,dst:byte):byte;
            function ORW(src,dst:word):word;
            function SUBB(src:word;dst:byte):byte;
            function SUBW(src:dword;dst:word):word;
            function XORB(src,dst:byte):byte;
            function XORW(src,dst:word):word;
            function SHR_BYTE(c,dst:byte):byte;
            function SHR_WORD(c:byte;dst:word):word;
            function SHL_BYTE(c,dst:byte):byte;
            function SHL_WORD(c:byte;dst:word):word;
            procedure SHRA_WORD(c:byte;dst:word;ModRM:byte);
            function ROR_BYTE(dst:byte):byte;
            function ROR_WORD(dst:word):word;
            function ROL_BYTE(dst:byte):byte;
            function ROL_WORD(dst:word):word;
            function ROLC_BYTE(dst:byte):byte;
            function ROLC_WORD(dst:word):word;
            function RORC_BYTE(dst:byte):byte;
            function RORC_WORD(dst:word):word;
            procedure ADD4S;
            procedure i_jmp(flag:boolean);
            procedure i_movsb;
            procedure i_movsw;
            procedure i_lodsb;
            procedure i_stosb;
            procedure i_lodsw;
            procedure i_stosw;
            procedure i_scasb;
            procedure i_scasw;
            procedure ADJ4(param1,param2:shortint);
            procedure ejecuta_instruccion(instruccion:byte);
            procedure PUSH(val:word);
            procedure i_pushf;
            function BITOP_WORD(ModRM:byte):word;
            function BITOP_BYTE(ModRM:byte):byte;
        end;

var
  nec_0,nec_1:cpu_nec;

implementation
var
  prev_icount:integer;
const
  parity_table:array[0..$ff] of boolean=(
    true, false, false, true, false, true, true, false, false, true, true, false, true, false, false, true, false, true, true, false, true, false,
    false, true, true, false, false, true, false, true, true, false, false, true, true, false, true, false, false, true, true, false, false, true,
    false, true, true, false, true, false, false, true, false, true, true, false, false, true, true, false, true, false, false, true, false, true,
    true, false, true, false, false, true, true, false, false, true, false, true, true, false, true, false, false, true, false, true, true, false,
    false, true, true, false, true, false, false, true, true, false, false, true, false, true, true, false, false, true, true, false, true, false,
    false, true, false, true, true, false, true, false, false, true, true, false, false, true, false, true, true, false, false, true, true, false,
    true, false, false, true, true, false, false, true, false, true, true, false, true, false, false, true, false, true, true, false, false, true,
    true, false, true, false, false, true, true, false, false, true, false, true, true, false, false, true, true, false, true, false, false, true,
    false, true, true, false, true, false, false, true, true, false, false, true, false, true, true, false, true, false, false, true, false, true,
    true, false, false, true, true, false, true, false, false, true, false, true, true, false, true, false, false, true, true, false, false, true,
    false, true, true, false, false, true, true, false, true, false, false, true, true, false, false, true, false, true, true, false, true, false,
    false, true, false, true, true, false, false, true, true, false, true, false, false, true);
    DS1=0;
    PS=1;
    SS=2;
    DS0=3;
    NEC_NMI_VECTOR=2;

function inbyte_ff(direccion:word):byte;
begin
  inbyte_ff:=$ff;
  MessageDlg('in byte sin funcion',mtInformation,[mbOk],0);
end;

function inword_ff(direccion:dword):word;
begin
  inword_ff:=$ffff;
  MessageDlg('in word sin funcion',mtInformation,[mbOk],0);
end;

procedure outbyte_ff(direccion:word;valor:byte);
begin
    MessageDlg('out byte sin funcion',mtInformation,[mbOk],0);
end;

procedure outword_ff(direccion:dword;valor:word);
begin
    MessageDlg('out word sin funcion',mtInformation,[mbOk],0);
end;

constructor cpu_nec.create(clock:dword;tipo:byte);
begin
getmem(self.r,sizeof(reg_nec));
fillchar(self.r^,sizeof(reg_nec),0);
self.numero_cpu:=cpu_main_init(clock);
self.clock:=clock;
self.tframes:=(clock/llamadas_maquina.scanlines)/llamadas_maquina.fps_max;
case tipo of
    0:;
    1:begin
        	self.prefetch_size:=6;		// 3 words
	        self.prefetch_cycles:=2;		// two cycles per byte / four per word
          self.tipo_cpu:=tipo;
      end;
  end;
self.inbyte:=inbyte_ff;
self.outbyte:=outbyte_ff;
self.inword:=inword_ff;
self.outword:=outword_ff;
self.despues_instruccion:=nil;
end;

destructor cpu_nec.free;
begin
freemem(self.r);
end;

procedure cpu_nec.reset;
begin
r.ip:=0;
r.f.T:=false;
r.f.i:=false;
r.f.D:=false;
r.f.SignVal:=false;
r.f.AuxVal:=false;
r.f.OverVal:=false;
r.f.ZeroVal:=true;
r.f.CarryVal:=false;
r.f.ParityVal:=true;
r.f.m:=true;
self.vect_req:=$ff;
self.irq_pending:=0;
self.prefetch_reset:=true;
r.ps_r:=$ffff;
r.ds1_r:=0;
r.ds0_r:=0;
r.ss_r:=0;
r.aw.w:=0;
r.cw.w:=0;
r.dw.w:=0;
r.bw.w:=0;
r.sp.w:=0;
r.bp.w:=0;
r.ix.w:=0;
r.iy.w:=0;
r.ea:=0;
r.eo:=0;
end;

procedure cpu_nec.change_ram_calls(getbyte:tgetbyte16;putbyte:tputbyte16);
begin
  self.getbyte:=getbyte;
  self.putbyte:=putbyte;
end;

procedure cpu_nec.change_io_calls(inbyte:tgetbyte;outbyte:tputbyte);
begin
  if @inbyte<>nil then self.inbyte:=inbyte;
  if @outbyte<>nil then self.outbyte:=outbyte;
end;

procedure cpu_nec.change_io_calls16(inword:tgetword;outword:tputword);
begin
  if @inword<>nil then self.inword:=inword;
  if @outword<>nil then self.outword:=outword;
end;

procedure cpu_nec.GetEA(ModRM:byte);
var
  EO:word;
  EA:dword;
  tempb:byte;
  E16:word;
begin
case ModRM of
  $00,$08,$10,$18,$20,$28,$30,$38:begin
        EO:=r.bw.w+r.ix.w;
        EA:=self.DefaultBase(DS0)+EO;
      end;
  $01,$09,$11,$19,$21,$29,$31,$39:begin
        EO:=r.bw.w+r.iy.w;
        EA:=self.DefaultBase(DS0)+EO;
      end;
  $02,$0a,$12,$1a,$22,$2a,$32,$3a:begin //01_05
       EO:=r.bp.w+r.ix.w;
       EA:=self.DefaultBase(SS)+EO;
      end;
  $04,$0c,$14,$1c,$24,$2c,$34,$3c:begin
        EO:=r.ix.w;
        EA:=self.DefaultBase(DS0)+EO;
      end;
  $05,$0d,$15,$1d,$25,$2d,$35,$3d:begin
        EO:=r.iy.w;
        EA:=self.DefaultBase(DS0)+EO;
      end;
  $06,$0e,$16,$1e,$26,$2e,$36,$3e:begin
        EO:=self.fetch;
        EO:=EO+(self.FETCH shl 8);
        EA:=self.DefaultBase(DS0)+EO;
      end;
  $07,$0f,$17,$1f,$27,$2f,$37,$3f:begin
        EO:=r.bw.w;
        EA:=self.DefaultBase(DS0)+EO;
      end;
  $40,$48,$50,$58,$60,$68,$70,$78:begin
        tempb:=self.fetch;
        EO:=r.bw.w+r.ix.w+shortint(tempb);
        EA:=self.DefaultBase(DS0)+EO;
      end;
  $41,$49,$51,$59,$61,$69,$71,$79:begin
        tempb:=self.fetch;
        EO:=r.bw.w+r.iy.w+shortint(tempb);
        EA:=self.DefaultBase(DS0)+EO;
      end;
  $42,$4a,$52,$5a,$62,$6a,$72,$7a:begin
        tempb:=self.fetch;
        EO:=r.bp.w+r.ix.w+shortint(tempb);
        EA:=self.DefaultBase(SS)+EO;
      end;
  $43,$4b,$53,$5b,$63,$6b,$73,$7b:begin
        tempb:=self.fetch;
        EO:=r.bp.w+r.iy.w+shortint(tempb);
        EA:=self.DefaultBase(SS)+EO;
      end;
  $44,$4c,$54,$5c,$64,$6c,$74,$7c:begin
        tempb:=self.fetch;
        EO:=r.ix.w+shortint(tempb);
        EA:=self.DefaultBase(DS0)+EO;
      end;
  $45,$4d,$55,$5d,$65,$6d,$75,$7d:begin
        tempb:=self.fetch;
        EO:=r.iy.w+shortint(tempb);
        EA:=self.DefaultBase(DS0)+EO;
      end;
  $46,$4e,$56,$5e,$66,$6e,$76,$7e:begin
        tempb:=self.fetch;
        EO:=r.bp.w+shortint(tempb);
        EA:=self.DefaultBase(SS)+EO;
      end;
  $47,$4f,$57,$5f,$67,$6f,$77,$7f:begin
        tempb:=self.fetch;
        EO:=r.bw.w+shortint(tempb);
        EA:=self.DefaultBase(DS0)+EO;
      end;
  $80,$88,$90,$98,$a0,$a8,$b0,$b8:begin
        E16:=self.FETCH;
        E16:=E16+(self.FETCH shl 8);
        EO:=r.bw.w+r.ix.w+smallint(E16);
        EA:=self.DefaultBase(DS0)+EO;
      end;
  $81,$89,$91,$99,$a1,$a9,$b1,$b9:begin
        E16:=self.FETCH;
        E16:=E16+(self.FETCH shl 8);
        EO:=r.bw.w+r.iy.w+smallint(E16);
        EA:=self.DefaultBase(DS0)+EO;
      end;
  $84,$8c,$94,$9c,$a4,$ac,$b4,$bc:begin
        E16:=self.FETCH;
        E16:=E16+(self.FETCH shl 8);
        EO:=r.ix.w+smallint(E16);
        EA:=self.DefaultBase(DS0)+EO;
      end;
  $85,$8d,$95,$9d,$a5,$ad,$b5,$bd:begin
        E16:=self.FETCH;
        E16:=E16+(self.FETCH shl 8);
        EO:=r.iy.w+smallint(E16);
        EA:=self.DefaultBase(DS0)+EO;
      end;
  $86,$8e,$96,$9e,$a6,$ae,$b6,$be:begin
        E16:=self.FETCH;
        E16:=E16+(self.FETCH shl 8);
        EO:=r.bp.w+smallint(E16);
        EA:=self.DefaultBase(SS)+EO;
      end;
  $87,$8f,$97,$9f,$a7,$af,$b7,$bf:begin
        E16:=self.FETCH;
        E16:=E16+(self.FETCH shl 8);
        EO:=r.bw.w+smallint(E16);
        EA:=self.DefaultBase(DS0)+EO;
      end;
  else MessageDlg('GetEA No Implementado ModRM '+inttohex(ModRM,10)+'. PC='+inttohex((r.ps_r shl 4)+r.ip,10), mtInformation,[mbOk], 0);
end;
r.eo:=EO;
r.ea:=EA;
end;

procedure cpu_nec.write_word(dir:dword;x:word);
begin
  self.putbyte(dir,x and $ff);
  self.putbyte(dir+1,x shr 8);
end;

function cpu_nec.read_word(dir:dword):word;
var
  tmp:byte;
begin
  tmp:=self.getbyte(dir);
  read_word:=tmp+(self.getbyte(dir+1) shl 8);
end;

function cpu_nec.fetch:byte;
begin
  self.prefetch_count:=self.prefetch_count-1;
	fetch:=self.getbyte((r.ps_r shl 4)+r.ip);
  r.ip:=r.ip+1;
end;

function cpu_nec.fetchword:word;
begin
  fetchword:=self.fetch+(self.fetch shl 8);
end;

procedure cpu_nec.do_prefetch(previous_icount:integer);
var
  diff:integer;
begin
  diff:=self.contador-previous_ICount;
	{ The implementation is not accurate, but comes close.
     * It does not respect that the V30 will fetch two bytes
     * at once directly, but instead uses only 2 cycles instead
     * of 4. There are however only very few sources publicy
     * available and they are vague.}
	while (self.prefetch_count<0) do begin
		self.prefetch_count:=self.prefetch_count+1;
		if (diff>self.prefetch_cycles) then diff:=diff-self.prefetch_cycles
  		else self.contador:=self.contador-self.prefetch_cycles;
	end;
	if self.prefetch_reset then begin
		self.prefetch_count:=0;
		self.prefetch_reset:=false;
		exit;
	end;
	while ((diff>=self.prefetch_cycles) and (self.prefetch_count<self.prefetch_size)) do begin
		diff:=diff-self.prefetch_cycles;
		self.prefetch_count:=self.prefetch_count+1;
	end;
end;

procedure cpu_nec.CLKS(clk_v20,clk_v30,clk_v33:byte);
begin
  case self.tipo_cpu of
    0:self.contador:=self.contador+clk_v20;
    1:self.contador:=self.contador+clk_v30;
    2:self.contador:=self.contador+clk_v33;
  end;
end;

procedure cpu_nec.CLKW(v20o,v30o,v33o,v20e,v30e,v33e:byte;addr:word);
begin
  case self.tipo_cpu of
    0:if (addr and 1)<>0 then self.contador:=self.contador+v20o
        else self.contador:=self.contador+v20e;
    1:if (addr and 1)<>0 then self.contador:=self.contador+v30o
        else self.contador:=self.contador+v30e;
    2:if (addr and 1)<>0 then self.contador:=self.contador+v33o
        else self.contador:=self.contador+v33e;
  end;
end;

procedure cpu_nec.CLKM(v20,v30,v33,v20m,v30m,v33m,ModRM:byte);
begin
   case self.tipo_cpu of
    0:if (ModRM>=$c0) then self.contador:=self.contador+v20
        else self.contador:=self.contador+v20m;
    1:if (ModRM>=$c0) then self.contador:=self.contador+v30
        else self.contador:=self.contador+v30m;
    2:if (ModRM>=$c0) then self.contador:=self.contador+v33
        else self.contador:=self.contador+v33m;
   end;
end;

procedure cpu_nec.CLKR(v20o,v30o,v33o,v20e,v30e,v33e,vall:byte;ModRM:byte);
begin
if (ModRM>=$c0) then begin
  self.contador:=self.contador+vall;
end else begin
  if (self.r.ea and 1)<>0 then begin
    case self.tipo_cpu of
      0:self.contador:=self.contador+v20o;
      1:self.contador:=self.contador+v30o;
      2:self.contador:=self.contador+v33o;
    end;
  end else begin
    case self.tipo_cpu of
      0:self.contador:=self.contador+v20e;
      1:self.contador:=self.contador+v30e;
      2:self.contador:=self.contador+v33e;
    end;
  end;
end;
end;

function cpu_nec.RegByte(ModRM:byte):byte;
begin
case ((ModRM and $38) shr 3) of
  0:RegByte:=r.aw.l;
  1:RegByte:=r.cw.l;
  2:RegByte:=r.dw.l;
  3:RegByte:=r.bw.l;
  4:RegByte:=r.aw.h;
  5:RegByte:=r.cw.h;
  6:RegByte:=r.dw.h;
  7:RegByte:=r.bw.h;
end;
end;

function cpu_nec.GetRMByte(ModRM:byte):byte;
begin
if (ModRM>=$c0) then begin
    case (modRM and $7) of
      0:GetRMByte:=r.aw.l;
      1:GetRMByte:=r.cw.l;
      2:GetRMByte:=r.dw.l;
      3:GetRMByte:=r.bw.l;
      4:GetRMByte:=r.aw.h;
      5:GetRMByte:=r.cw.h;
      6:GetRMByte:=r.dw.h;
      7:GetRMByte:=r.bw.h;
    end;
end else begin
    self.GetEA(ModRM);
    GetRMByte:=self.getbyte(r.ea);
end;
end;

function cpu_nec.RegWord(ModRM:byte):word;
begin
case ((ModRM and $38) shr 3) of
  0:RegWord:=r.aw.w;
  1:RegWord:=r.cw.w;
  2:RegWord:=r.dw.w;
  3:RegWord:=r.bw.w;
  4:RegWord:=r.sp.w;
  5:RegWord:=r.bp.w;
  6:RegWord:=r.ix.w;
  7:RegWord:=r.iy.w;
end;
end;

function cpu_nec.GetRMWord(ModRM:byte):word;
begin
if (ModRM>=$c0) then begin
    case (ModRM and 7) of
      0:GetRMWord:=r.aw.w;
      1:GetRMWord:=r.cw.w;
      2:GetRMWord:=r.dw.w;
      3:GetRMWord:=r.bw.w;
      4:GetRMWord:=r.sp.w;
      5:GetRMWord:=r.bp.w;
      6:GetRMWord:=r.ix.w;
      7:GetRMWord:=r.iy.w;
    end;
end else begin
    self.GetEA(ModRM);
    GetRMWord:=self.read_word(r.ea);
end;
end;

procedure cpu_nec.PutRMByte(ModRM,valor:byte);
begin
	if (ModRM>=$c0) then begin
    case (modRM and 7) of
      0:r.aw.l:=valor;
      1:r.cw.l:=valor;
      2:r.dw.l:=valor;
      3:r.bw.l:=valor;
      4:r.aw.h:=valor;
      5:r.cw.h:=valor;
      6:r.dw.h:=valor;
      7:r.bw.h:=valor;
    end;
  end else begin
    self.GetEA(ModRM);
    self.putbyte(r.ea,valor);
  end;
end;

procedure cpu_nec.PutbackRMByte(ModRM,valor:byte);
begin
	if (ModRM>=$c0) then begin
    case (modRM and 7) of
      0:r.aw.l:=valor;
      1:r.cw.l:=valor;
      2:r.dw.l:=valor;
      3:r.bw.l:=valor;
      4:r.aw.h:=valor;
      5:r.cw.h:=valor;
      6:r.dw.h:=valor;
      7:r.bw.h:=valor;
    end;
  end else self.putbyte(r.ea,valor);
end;

procedure cpu_nec.PutBackRegByte(ModRM,valor:byte);
begin
case ((ModRM and $38) shr 3) of
  0:r.aw.l:=valor;
  1:r.cw.l:=valor;
  2:r.dw.l:=valor;
  3:r.bw.l:=valor;
  4:r.aw.h:=valor;
  5:r.cw.h:=valor;
  6:r.dw.h:=valor;
  7:r.bw.h:=valor;
end;
end;

procedure cpu_nec.PutRMWord(ModRM:byte;valor:word);
begin
	if (ModRM>=$c0) then begin
    case (modRM and 7) of
      0:r.aw.w:=valor;
      1:r.cw.w:=valor;
      2:r.dw.w:=valor;
      3:r.bw.w:=valor;
      4:r.sp.w:=valor;
      5:r.bp.w:=valor;
      6:r.ix.w:=valor;
      7:r.iy.w:=valor;
    end;
  end else begin
    self.GetEA(ModRM);
    self.write_word(r.ea,valor);
  end;
end;

procedure cpu_nec.PutbackRMWord(ModRM:byte;valor:word);
begin
	if (ModRM>=$c0) then begin
    case (modRM and $7) of
      0:r.aw.w:=valor;
      1:r.cw.w:=valor;
      2:r.dw.w:=valor;
      3:r.bw.w:=valor;
      4:r.sp.w:=valor;
      5:r.bp.w:=valor;
      6:r.ix.w:=valor;
      7:r.iy.w:=valor;
    end;
  end else self.write_word(r.ea,valor);
end;

procedure cpu_nec.PutBackRegWord(ModRM:byte;valor:word);
begin
case ((ModRM and $38) shr 3) of
  0:r.aw.w:=valor;
  1:r.cw.w:=valor;
  2:r.dw.w:=valor;
  3:r.bw.w:=valor;
  4:r.sp.w:=valor;
  5:r.bp.w:=valor;
  6:r.ix.w:=valor;
  7:r.iy.w:=valor;
end;
end;

procedure cpu_nec.PutImmRMByte(ModRM:byte);
var
  valor:byte;
begin
	if (ModRM>=$c0)	then begin
    valor:=self.fetch;
    case (modRM and 7) of
      0:r.aw.l:=valor;
      1:r.cw.l:=valor;
      2:r.dw.l:=valor;
      3:r.bw.l:=valor;
      4:r.aw.h:=valor;
      5:r.cw.h:=valor;
      6:r.dw.h:=valor;
      7:r.bw.h:=valor;
    end;
  end	else begin
		self.GetEA(ModRM);
    valor:=self.fetch;
    self.putbyte(r.ea,valor);
	end;
end;

procedure cpu_nec.PutImmRMWord(ModRM:byte);
var
  valor:word;
begin
	if (ModRM>=$c0) then begin
    valor:=self.FETCHWORD;
    case (modRM and 7) of
      0:r.aw.w:=valor;
      1:r.cw.w:=valor;
      2:r.dw.w:=valor;
      3:r.bw.w:=valor;
      4:r.sp.w:=valor;
      5:r.bp.w:=valor;
      6:r.ix.w:=valor;
      7:r.iy.w:=valor;
    end;
	end else begin
    self.GetEA(ModRM);
		valor:=self.FETCHWORD;
    self.write_word(r.ea,valor);
	end;
end;

procedure cpu_nec.SetSZPF_Byte(x:byte);
begin
 r.f.SignVal:=(x and $80)<>0;
 r.f.ZeroVal:=(x=0);
 r.f.ParityVal:=parity_table[x];
end;

procedure cpu_nec.SetSZPF_Word(x:word);
begin
  r.f.SignVal:=(x and $8000)<>0;
  r.f.ZeroVal:=(x=0);
  r.f.ParityVal:=parity_table[x and $ff];
end;

function cpu_nec.DefaultBase(Seg:byte):dword;
begin
  if (self.seg_prefix and ((Seg=DS0) or (Seg=SS))) then begin
    DefaultBase:=self.prefix_base;
  end else begin
    case Seg of
      DS1:DefaultBase:=r.ds1_r shl 4;
      PS:DefaultBase:=r.ps_r shl 4;
      SS:DefaultBase:=r.ss_r shl 4;
      DS0:DefaultBase:=r.ds0_r shl 4;
    end;
   end;
end;

function cpu_nec.GetMemB(Seg:byte;Off:word):byte;
begin
 GetMemB:=self.getbyte(DefaultBase(Seg)+Off);
end;

function cpu_nec.GetMemW(Seg:byte;Off:word):word;
begin
 GetMemW:=self.read_word(self.DefaultBase(Seg)+Off);
end;

procedure cpu_nec.PutMemB(Seg:byte;Off:word;x:byte);
begin
   self.putbyte(DefaultBase(Seg)+Off,x);
end;

procedure cpu_nec.PutMemW(Seg:byte;Off,x:word);
begin
   self.write_word(self.DefaultBase(Seg)+Off,x);
end;

function cpu_nec.IncWordReg(tmp:word):word;
var
  tmp1:word;
begin
	tmp1:=tmp+1;
	r.f.OverVal:=(tmp=$7fff);
  r.f.AuxVal:=((tmp1 xor (tmp xor 1)) and $10)<>0;
	self.SetSZPF_Word(tmp1);
	IncWordReg:=tmp1;
end;

function cpu_nec.DecWordReg(tmp:word):word;
var
  tmp1:dword;
begin
	tmp1:=tmp-1;
	r.f.OverVal:=(tmp=$8000);
  r.f.AuxVal:=((tmp1 xor (tmp xor 1)) and $10)<>0;
	self.SetSZPF_Word(tmp1);
	DecWordReg:=tmp1;
end;

//INSTRUCIONES
function cpu_nec.ANDB(src,dst:byte):byte;
begin
  dst:=dst and src;
  r.f.CarryVal:=false;
  r.f.OverVal:=false;
  r.f.AuxVal:=false;
  self.SetSZPF_Byte(dst);
  ANDB:=dst;
end;

function cpu_nec.ANDW(src,dst:word):word;
begin
  dst:=dst and src;
  r.f.CarryVal:=false;
  r.f.OverVal:=false;
  r.f.AuxVal:=false;
  self.SetSZPF_Word(dst);
  andw:=dst;
end;

//OJO: que puede venir con carry sumado!
function cpu_nec.ADDB(src:word;dst:byte):byte;
var
  res:word;
begin
  res:=dst+src;
  r.f.CarryVal:=(res and $100)<>0;
  r.f.OverVal:=((res xor src) and (res xor dst) and $80)<>0;
  r.f.AuxVal:=((res xor (src xor dst)) and $10)<>0;
  self.SetSZPF_Byte(res);
  ADDB:=res;
end;

function cpu_nec.ADDW(src:dword;dst:word):word;
var
  res:dword;
begin
 res:=dst+src;
 r.f.CarryVal:=(res and $10000)<>0;
 r.f.OverVal:=((res xor src) and (res xor dst) and $8000)<>0;
 r.f.AuxVal:=((res xor (src xor dst)) and $10)<>0;
 self.SetSZPF_Word(res);
 ADDW:=res;
end;

function cpu_nec.ORB(src,dst:byte):byte;
begin
   dst:=dst or src;
   r.f.CarryVal:=false;
   r.f.OverVal:=false;
   r.f.AuxVal:=false;
   self.SetSZPF_Byte(dst);
   ORB:=dst;
end;

function cpu_nec.ORW(src,dst:word):word;
begin
   dst:=dst or src;
   r.f.CarryVal:=false;
   r.f.OverVal:=false;
   r.f.AuxVal:=false;
   self.SetSZPF_word(dst);
   ORW:=dst;
end;

function cpu_nec.SUBB(src:word;dst:byte):byte;
var
  res:word;
begin
   res:=dst-src;
   r.f.CarryVal:=(res and $100)<>0;
   r.f.OverVal:=((dst xor src) and (dst xor res) and $80)<>0;
   r.f.AuxVal:=((res xor (src xor dst)) and $10)<>0;
   self.SetSZPF_Byte(res);
   SUBB:=res;
end;

function cpu_nec.SUBW(src:dword;dst:word):word;
var
  res:dword;
begin
 res:=dst-src;
 r.f.CarryVal:=(res and $10000)<>0;
 r.f.OverVal:=((dst xor src) and (dst xor res) and $8000)<>0;
 r.f.AuxVal:=((res xor (src xor dst)) and $10)<>0;
 self.SetSZPF_Word(res);
 SUBW:=res;
end;

function cpu_nec.XORB(src,dst:byte):byte;
begin
  dst:=dst xor src;
  r.f.CarryVal:=false;
  r.f.OverVal:=false;
  r.f.AuxVal:=false;
  self.SetSZPF_Byte(dst);
  XORB:=dst;
end;

function cpu_nec.XORW(src,dst:word):word;
begin
  dst:=dst xor src;
  r.f.CarryVal:=false;
  r.f.OverVal:=false;
  r.f.AuxVal:=false;
  self.SetSZPF_Word(dst);
  XORW:=dst;
end;

function cpu_nec.SHR_BYTE(c,dst:byte):byte;
begin
   self.contador:=self.contador+c;
   dst:=dst shr (c-1);
   r.f.CarryVal:=(dst and 1)<>0;
   dst:=dst shr 1;
   self.SetSZPF_Byte(dst);
   SHR_BYTE:=dst;
end;

function cpu_nec.SHR_WORD(c:byte;dst:word):word;
begin
  self.contador:=self.contador+c;
  dst:=dst shr (c-1);
  r.f.CarryVal:=(dst and 1)<>0;
  dst:=dst shr 1;
  self.SetSZPF_Word(dst);
  SHR_WORD:=dst;
end;

function cpu_nec.SHL_BYTE(c,dst:byte):byte;
var
   res:word;
begin
   self.contador:=self.contador+c;
   res:=dst shl c;
   r.f.CarryVal:=(res and $100)<>0;
   self.SetSZPF_Byte(res);
   SHL_BYTE:=res;
end;

function cpu_nec.SHL_WORD(c:byte;dst:word):word;
var
  res:dword;
begin
  self.contador:=self.contador+c;
  res:=dst shl c;
  r.f.CarryVal:=(res and $10000)<>0;
  self.SetSZPF_Word(res);
  SHL_WORD:=res;
end;

function cpu_nec.ROL_BYTE(dst:byte):byte;
begin
  r.f.CarryVal:=(dst and $80)<>0;
  ROL_BYTE:=(dst shl 1)+byte(r.f.CarryVal);
end;

function cpu_nec.ROL_WORD(dst:word):word;
begin
   r.f.CarryVal:=(dst and $8000)<>0;
   ROL_WORD:=(dst shl 1)+byte(r.f.CarryVal);
end;

function cpu_nec.ROR_BYTE(dst:byte):byte;
begin
   r.f.CarryVal:=(dst and 1)<>0;
   ROR_BYTE:=(dst shr 1)+(byte(r.f.CarryVal) shl 7);
end;

function cpu_nec.ROR_WORD(dst:word):word;
begin
   r.f.CarryVal:=(dst and 1)<>0;
   ROR_WORD:=(dst shr 1)+(byte(r.f.CarryVal) shl 15);
end;

function cpu_nec.ROLC_BYTE(dst:byte):byte;
var
  temp:word;
begin
  temp:=(dst shl 1)+byte(r.f.CarryVal);
  r.f.CarryVal:=(temp and $100)<>0;
  ROLC_BYTE:=temp;
end;

function cpu_nec.ROLC_WORD(dst:word):word;
var
  temp:dword;
begin
  temp:=(dst shl 1)+byte(r.f.CarryVal);
  r.f.CarryVal:=(temp and $10000)<>0;
  ROLC_WORD:=temp;
end;

function cpu_nec.RORC_BYTE(dst:byte):byte;
var
  temp:word;
begin
 temp:=dst+(byte(r.f.CarryVal) shl 8);
 r.f.CarryVal:=(temp and 1)<>0;
 RORC_BYTE:=temp shr 1;
end;

function cpu_nec.RORC_WORD(dst:word):word;
var
  temp:dword;
begin
 temp:=dst+(byte(r.f.CarryVal) shl 16);
 r.f.CarryVal:=(temp and 1)<>0;
 RORC_WORD:=temp shr 1;
end;

procedure cpu_nec.SHRA_WORD(c:byte;dst:word;ModRM:byte);
function sshr(num:integer;fac:byte):integer;
begin
  if num<0 then sshr:=-(abs(num) shr fac)
    else sshr:=num shr fac;
end;
var
  temp:smallint;
begin
  self.contador:=self.contador+c;
  temp:=smallint(dst);
  temp:=sshr(temp,c-1);
  r.f.CarryVal:=(temp and 1)<>0;
  temp:=sshr(temp,1);
  dst:=temp;
  self.SetSZPF_Word(dst);
  PutbackRMWord(ModRM,dst);
end;

procedure cpu_nec.ADD4S;
const
  table:array [0..2] of byte=(18,19,19);
var
  di,si,result:word;
  count,i,tmp,tmp2,v1,v2:byte;
begin
	count:=(r.cw.l+1) div 2;
	di:=r.iy.w;
	si:=r.ix.w;
	if self.seg_prefix then MessageDlg('Warning: seg_prefix defined for add4s', mtInformation,[mbOk],0);
  r.f.ZeroVal:=false;
  r.f.CarryVal:=false;
	for i:=0 to (count-1) do begin
    self.contador:=self.contador+table[self.tipo_cpu];
		tmp:=self.GetMemB(DS0,si);
		tmp2:=self.GetMemB(DS1,di);
		v1:=(tmp shr 4)*10+(tmp and $f);
		v2:=(tmp2 shr 4)*10+(tmp2 and $f);
    result:=v1+v2+byte(r.f.CarryVal);
    r.f.CarryVal:=(result>99);
		result:=result mod 100;
		v1:=((result div 10) shl 4) or (result mod 10);
		self.PutMemB(DS1,di,v1);
		if (v1<>0) then r.f.ZeroVal:=true;
		si:=si+1;
		di:=di+1;
	end;
end;

//MACROS INSTRUCCIONES
procedure cpu_nec.i_jmp(flag:boolean);
const
  table:array [0..2] of byte=(18,19,19);
var
  tmp:byte;
begin
	self.prefetch_reset:=true;
	tmp:=self.FETCH;
	if flag then begin
    r.ip:=r.ip+shortint(tmp);
    self.contador:=self.contador+table[self.tipo_cpu];
	end;
end;

procedure cpu_nec.i_movsb;
var
  tmp:byte;
begin
  tmp:=self.GetMemB(DS0,r.ix.w);
  self.PutMemB(DS1,r.iy.w,tmp);
  r.iy.w:=r.iy.w-2*byte(r.f.D)+1;
  r.ix.w:=r.ix.w-2*byte(r.f.D)+1;
  CLKS(8,8,6);
end;

procedure cpu_nec.i_movsw;
var
  tmp:word;
begin
  tmp:=self.GetMemW(DS0,r.ix.w);
  self.PutMemW(DS1,r.iy.w,tmp);
  r.ix.w:=r.ix.w-4*byte(r.f.D)+2;
  r.iy.w:=r.iy.w-4*byte(r.f.D)+2;
  CLKS(16,16,10);
end;

procedure cpu_nec.i_lodsb;
begin
  r.aw.l:=self.GetMemB(DS0,r.ix.w);
  r.ix.w:=r.ix.w-2*byte(r.f.D)+1;
  CLKS(4,4,3);
end;

procedure cpu_nec.i_stosb;
begin
  self.PutMemB(DS1,r.iy.w,r.aw.l);
  r.iy.w:=r.iy.w-2*byte(r.f.D)+1;
  CLKS(4,4,3);
end;

procedure cpu_nec.i_lodsw;
begin
  r.aw.w:=self.GetMemW(DS0,r.ix.w);
  r.ix.w:=r.ix.w-4*byte(r.f.D)+2;
  self.CLKW(8,8,5,8,4,3,r.ix.w);
end;

procedure cpu_nec.i_stosw;
begin
  self.PutMemW(DS1,r.iy.w,r.aw.w);
  r.iy.w:=r.iy.w-4*byte(r.f.D)+2;
  self.CLKW(8,8,5,8,4,3,r.iy.w);
end;

procedure cpu_nec.i_scasb;
var
  src,dst:byte;
begin
  src:=self.GetMemB(DS1,r.iy.w);
  dst:=r.aw.l;
  self.SUBB(src,dst);
  r.iy.w:=r.iy.w-2*byte(r.f.d)+1;
  CLKS(4,4,3);
end;

procedure cpu_nec.i_scasw;
var
  src,dst:word;
begin
  src:=self.GetMemW(DS1,r.iy.w);
  dst:=r.aw.w;
  self.SUBW(src,dst);
  r.iy.w:=r.iy.w-4*byte(r.f.D)+2;
  self.CLKW(8,8,5,8,4,3,r.iy.w);
end;

procedure cpu_nec.ADJ4(param1,param2:shortint);
var
  tmp:word;
begin
	if (r.f.AuxVal or ((r.aw.l and $f)>9)) then begin
		tmp:=r.aw.l+param1;
    r.aw.l:=tmp;
    self.r.f.AuxVal:=true;
    if ((tmp and $100)<>0) then self.r.f.CarryVal:=true;
	end;
	if (r.f.CarryVal or (r.aw.l>$9f)) then begin
		r.aw.l:=r.aw.l+param2;
    r.f.CarryVal:=true;
  end;
	SetSZPF_Byte(r.aw.l)
end;

procedure cpu_nec.PUSH(val:word);
begin
   self.r.sp.w:=self.r.sp.w-2;
   self.write_word((self.r.ss_r shl 4)+self.r.sp.w,val);
end;

procedure cpu_nec.i_pushf;
var
  temp:word;
begin
  temp:=$7002;
  if r.f.CarryVal then temp:=1;
  if r.f.ParityVal then temp:=temp+4;
  if r.f.AuxVal then temp:=temp+$10;
  if r.f.ZeroVal then temp:=temp+$40;
  if r.f.SignVal then temp:=temp+$80;
  if r.f.t then temp:=temp+$100;
  if r.f.I then temp:=temp+$200;
  if r.f.D then temp:=temp+$400;
  if r.f.OverVal then temp:=temp+$800;
  if r.f.m then temp:=temp+$8000;
  PUSH(temp);
  CLKS(12,8,3);
end;

function cpu_nec.BITOP_BYTE(ModRM:byte):byte;
begin
	if (ModRM>=$c0) then
      case (ModRM and 7) of
        0:BITOP_BYTE:=r.aw.l;
        1:BITOP_BYTE:=r.cw.l;
        2:BITOP_BYTE:=r.dw.l;
        3:BITOP_BYTE:=r.bw.l;
        4:BITOP_BYTE:=r.aw.h;
        5:BITOP_BYTE:=r.cw.h;
        6:BITOP_BYTE:=r.dw.h;
        7:BITOP_BYTE:=r.bw.h;
      end
	  else begin
		  self.GetEA(ModRM);
		  BITOP_BYTE:=self.getbyte(r.ea);
    end;
end;

function cpu_nec.BITOP_WORD(ModRM:byte):word;
begin
	if (ModRM>=$c0) then
     case (ModRM and 7) of
        0:BITOP_WORD:=r.aw.w;
        1:BITOP_WORD:=r.cw.w;
        2:BITOP_WORD:=r.dw.w;
        3:BITOP_WORD:=r.bw.w;
        4:BITOP_WORD:=r.sp.w;
        5:BITOP_WORD:=r.bp.w;
        6:BITOP_WORD:=r.ix.w;
        7:BITOP_WORD:=r.iy.w;
      end
	  else begin
		  self.GetEA(ModRM);
		  BITOP_WORD:=self.read_word(r.ea);
    end;
end;

procedure cpu_nec.ejecuta_instruccion(instruccion:byte);
var
  tmpw,tmpw1:word;
  ModRM,srcb,dstb,c:byte;
  srcw,dstw:word;
  tmpb,tmpb1:byte;
  tmpdw,tmpdw1:dword;
  tmpi:integer;

function POP:word;
begin
   pop:=read_word((r.ss_r shl 4)+r.sp.w);
   r.sp.w:=r.sp.w+2;
end;

procedure ExpandFlags(temp:word);
begin
  r.f.CarryVal:=(temp and 1)<>0;
  r.f.ParityVal:=(temp and 4)<>0;
  r.f.AuxVal:=(temp and $10)<>0;
  r.f.ZeroVal:=(temp and $40)<>0;
  r.f.SignVal:=(temp and $80)<>0;
  r.f.t:=(temp and $100)<>0;
  r.f.i:=(temp and $200)<>0;
  r.f.d:=(temp and $400)<>0;
  r.f.OverVal:=(temp and $800)<>0;
  r.f.m:=(temp and $8000)<>0;
end;

procedure i_popf;
var
  tmp:word;
begin
   tmp:=POP;
   ExpandFlags(tmp);
   CLKS(12,8,5);
   if r.f.t then MessageDlg('trap despues o_popf', mtInformation,[mbOk],0);
end;

procedure DEF_br8;
begin
ModRM:=self.fetch;
srcb:=RegByte(ModRM);
dstb:=GetRMByte(ModRM);
end;

procedure DEF_wr16;
begin
ModRM:=fetch;
srcw:=RegWord(ModRM);
dstw:=GetRMWord(ModRM);
end;

procedure DEF_r8b;
begin
ModRM:=fetch;
dstb:=RegByte(ModRM);
srcb:=GetRMByte(ModRM);
end;

procedure DEF_r16w;
begin
ModRM:=fetch;
dstw:=RegWord(ModRM);
srcw:=GetRMWord(ModRM);
end;

procedure DEF_ald8;
begin
srcb:=fetch;
dstb:=r.aw.l;
end;

procedure DEF_axd16;
begin
srcw:=fetchword;
dstw:=r.aw.w;
end;

begin
case instruccion of
    $00:begin  //i_add_br8
          DEF_br8;
          dstb:=ADDB(srcb,dstb);
          PutbackRMByte(ModRM,dstb);
          CLKM(2,2,2,16,16,7,ModRM);
        end;
    $01:begin  //i_add_wr16
          DEF_wr16;
          dstw:=ADDW(srcw,dstw);
          PutbackRMWord(ModRM,dstw);
          CLKR(24,24,11,24,16,7,2,ModRM);
        end;
    $02:begin //i_add_r8b
          DEF_r8b;
          dstb:=ADDB(srcb,dstb);
          PutBackRegByte(ModRM,dstb);
          CLKM(2,2,2,11,11,6,ModRM);
        end;
    $03:begin //add_r16w
          DEF_r16w;
          dstw:=ADDW(srcw,dstw);
          PutBackRegWord(ModRM,dstw);
          CLKR(15,15,8,15,11,6,2,ModRM);
        end;
    $04:begin //i_add_ald8
          DEF_ald8;
          r.aw.l:=ADDB(srcb,dstb);
          CLKS(4,4,2);
        end;
    $05:begin  //i_add_axd16
          DEF_axd16;
          r.aw.w:=ADDW(srcw,dstw);
          CLKS(4,4,2);
        end;
    $06:begin  //i_push_es
          PUSH(r.ds1_r);
          CLKS(12,8,3);
        end;
    $07:begin //i_pop_es
          r.ds1_r:=POP;
          CLKS(12,8,5);
        end;
    $08:begin  //i_or_br8   01_05
          DEF_br8;
          dstb:=ORB(srcb,dstb);
          PutbackRMByte(ModRM,dstb);
          CLKM(2,2,2,16,16,7,ModRM);
        end;
    $09:begin //i_or_wr16  01_05
          DEF_wr16;
          dstw:=ORW(srcw,dstw);
          PutbackRMWord(ModRM,dstw);
          CLKR(24,24,11,24,16,7,2,ModRM);
        end;
    $0a:begin  //i_or_r8b
          DEF_r8b;
          dstb:=ORB(srcb,dstb);
          PutBackRegByte(ModRM,dstb);
          CLKM(2,2,2,11,11,6,ModRM);
        end;
    $0b:begin  //i_or_r16w  28_04
          DEF_r16w;
          dstw:=ORW(srcw,dstw);
          PutbackRegWord(ModRM,dstw);
          CLKR(15,15,8,15,11,6,2,ModRM);
        end;
    $0c:begin //i_or_ald8
          DEF_ald8;
          r.aw.l:=ORB(srcb,dstb);
          CLKS(4,4,2);
        end;
    $0d:begin //i_or_axd16
          DEF_axd16;
          r.aw.w:=ORW(srcw,dstw);
          CLKS(4,4,2);
        end;
    $0e:begin  //i_push_ps
          PUSH(r.ps_r);
          CLKS(12,8,3);
        end;
    $0f:begin  //i_pre_nec
	        case self.FETCH of
		        {case 0x10 : BITOP_BYTE;	CLKS(3,3,4); tmp2 = nec_state->regs.b[CL] & 0x7;	nec_state->ZeroVal = (tmp & (1<<tmp2)) ? 1 : 0;	nec_state->CarryVal=nec_state->OverVal=0; break; /* Test */
		        case 0x11 : BITOP_WORD;	CLKS(3,3,4); tmp2 = nec_state->regs.b[CL] & 0xf;	nec_state->ZeroVal = (tmp & (1<<tmp2)) ? 1 : 0;	nec_state->CarryVal=nec_state->OverVal=0; break; /* Test */
		        case 0x12 : BITOP_BYTE;	CLKS(5,5,4); tmp2 = nec_state->regs.b[CL] & 0x7;	tmp &= ~(1<<tmp2);	PutbackRMByte(ModRM,tmp);	break; /* Clr */
		        case 0x13 : BITOP_WORD;	CLKS(5,5,4); tmp2 = nec_state->regs.b[CL] & 0xf;	tmp &= ~(1<<tmp2);	PutbackRMWord(ModRM,tmp);	break; /* Clr */
		        case 0x14 : BITOP_BYTE;	CLKS(4,4,4); tmp2 = nec_state->regs.b[CL] & 0x7;	tmp |= (1<<tmp2);	PutbackRMByte(ModRM,tmp);	break; /* Set */
		        case 0x15 : BITOP_WORD;	CLKS(4,4,4); tmp2 = nec_state->regs.b[CL] & 0xf;	tmp |= (1<<tmp2);	PutbackRMWord(ModRM,tmp);	break; /* Set */
		        case 0x16 : BITOP_BYTE;	CLKS(4,4,4); tmp2 = nec_state->regs.b[CL] & 0x7;	BIT_NOT;			PutbackRMByte(ModRM,tmp);	break; /* Not */
		        case 0x17 : BITOP_WORD;	CLKS(4,4,4); tmp2 = nec_state->regs.b[CL] & 0xf;	BIT_NOT;			PutbackRMWord(ModRM,tmp);	break; /* Not */
		        case 0x1e : BITOP_BYTE;	CLKS(5,5,4); tmp2 = (FETCH()) & 0x7;	BIT_NOT;				PutbackRMByte(ModRM,tmp);	break; /* Not */
		        case 0x1f : BITOP_WORD;	CLKS(5,5,4); tmp2 = (FETCH()) & 0xf;	BIT_NOT;				PutbackRMWord(ModRM,tmp);	break; /* Not */}
            $18:begin //TEST BYTE
                  ModRM:=fetch;
                  tmpb:=BITOP_BYTE(ModRM);
                  CLKS(4,4,4);
                  tmpb1:=fetch and 7;
                  r.f.ZeroVal:=(tmpb and (1 shl tmpb1))=0;
                  r.f.CarryVal:=false;
                  r.f.OverVal:=false;
                end;
            $19:begin //TEST WORD
                  ModRM:=fetch;
                  tmpw:=BITOP_WORD(ModRM);
                  CLKS(4,4,4);
                  tmpb:=fetch and $f;
                  r.f.ZeroVal:=(tmpw and (1 shl tmpb))=0;
                  r.f.CarryVal:=false;
                  r.f.OverVal:=false;
                end;
            $1a:begin  //CLR BYTE
                   ModRM:=fetch;
                   tmpb:=BITOP_BYTE(ModRM);
                   CLKS(6,6,4);
                   tmpb1:=fetch and 7;
                   tmpb:=tmpb and not(1 shl tmpb1);
                   PutbackRMByte(ModRM,tmpb);
                end;
            $1b:begin //CLR WORD
                  ModRM:=fetch;
                  tmpw:=BITOP_WORD(ModRM);
                  CLKS(6,6,4);
                  tmpb:=fetch and $f;
                  tmpw:=tmpw and not(1 shl tmpb);
                  PutbackRMWord(ModRM,tmpw);
                end;
            $1c:begin //SET BYTE
                  ModRM:=fetch;
                  tmpb:=self.BITOP_BYTE(ModRM);
                  CLKS(5,5,4);
                  tmpb1:=fetch and $7;
                  tmpb:=tmpb or (1 shl tmpb1);
                  PutbackRMByte(ModRM,tmpb);
                end;
            $1d:begin //SET WORD
                  ModRM:=fetch;
                  tmpw:=self.BITOP_WORD(ModRM);
                  CLKS(5,5,4);
                  tmpb:=fetch and $f;
                  tmpw:=tmpw or (1 shl tmpb);
                  PutbackRMWord(ModRM,tmpw);
                end;
		        $20:begin
                  self.ADD4S;
                  CLKS(7,7,2);
                end;
{		        case 0x22 :	SUB4S; CLKS(7,7,2); break;
        		case 0x26 :	CMP4S; CLKS(7,7,2); break;
        		case 0x28 : ModRM = FETCH(); tmp = GetRMByte(ModRM); tmp <<= 4; tmp |= nec_state->regs.b[AL] & 0xf; nec_state->regs.b[AL] = (nec_state->regs.b[AL] & 0xf0) | ((tmp>>8)&0xf); tmp &= 0xff; PutbackRMByte(ModRM,tmp); CLKM(13,13,9,28,28,15); break;
        		case 0x2a : ModRM = FETCH(); tmp = GetRMByte(ModRM); tmp2 = (nec_state->regs.b[AL] & 0xf)<<4; nec_state->regs.b[AL] = (nec_state->regs.b[AL] & 0xf0) | (tmp&0xf); tmp = tmp2 | (tmp>>4);	PutbackRMByte(ModRM,tmp); CLKM(17,17,13,32,32,19); break;
        		case 0x31 : ModRM = FETCH(); ModRM=0; logerror("%06x: Unimplemented bitfield INS\n",PC(nec_state)); break;
        		case 0x33 : ModRM = FETCH(); ModRM=0; logerror("%06x: Unimplemented bitfield EXT\n",PC(nec_state)); break;
        		case 0x92 : CLK(2); break; /* V25/35 FINT */
        		case 0xe0 : ModRM = FETCH(); ModRM=0; logerror("%06x: V33 unimplemented BRKXA (break to expansion address)\n",PC(nec_state)); break;
        		case 0xf0 : ModRM = FETCH(); ModRM=0; logerror("%06x: V33 unimplemented RETXA (return from expansion address)\n",PC(nec_state)); break;
        		case 0xff : ModRM = FETCH(); ModRM=0; logerror("%06x: unimplemented BRKEM (break to 8080 emulation mode)\n",PC(nec_state)); break;}
		        else MessageDlg('$F otro...'+inttohex(((r.ps_r shl 4)+r.ip)-1,10)+' INST: '+inttohex(instruccion,4)+' oldPC: '+inttohex(((r.ps_r shl 4)+r.old_pc)-1,10), mtInformation,[mbOk],0);
          end;
        end;
    $10:begin  //i_adc_br8
          DEF_br8;
          tmpw:=srcb+byte(r.f.CarryVal);
          dstb:=ADDB(tmpw,dstb);
          PutbackRMByte(ModRM,dstb);
          CLKM(2,2,2,16,16,7,ModRM);
        end;
    $11:begin //i_adc_wr16 29_04
          DEF_wr16;
          tmpdw:=srcw+byte(r.f.CarryVal);
          dstw:=ADDW(tmpdw,dstw);
          PutbackRMWord(ModRM,dstw);
          CLKR(24,24,11,24,16,7,2,ModRM);
        end;
    $12:begin  //i_adc_r8b  01_05
          DEF_r8b;
          tmpw:=srcb+byte(r.f.CarryVal);
          dstb:=ADDB(tmpw,dstb);
          PutBackRegByte(ModRM,dstb);
          CLKM(2,2,2,11,11,6,ModRM);
        end;
    $13:begin //i_adc_r16w 01_05
          DEF_r16w;
          tmpdw:=srcw+byte(r.f.CarryVal);
          dstw:=ADDW(tmpdw,dstw);
          PutBackRegWord(ModRM,dstw);
          CLKR(15,15,8,15,11,6,2,ModRM);
        end;
    $1b:begin //i_sbb_r16w 01_05
          DEF_r16w;
          tmpdw:=srcw+byte(r.f.CarryVal);
          dstw:=SUBW(tmpdw,dstw);
          PutBackRegWord(ModRM,dstw);
          CLKR(15,15,8,15,11,6,2,ModRM);
        end;
    $1e:begin //i_push_ds
          PUSH(r.ds0_r);
          CLKS(12,8,3);
        end;
    $1f:begin //i_pop_ds
          r.ds0_r:=POP;
          CLKS(12,8,5);
        end;
    $20:begin //i_and_br8  01_05
          DEF_br8;
          dstb:=ANDB(srcb,dstb);
          PutbackRMByte(ModRM,dstb);
          CLKM(2,2,2,16,16,7,ModRM);
        end;
    $21:begin //i_and_wr16 01_05
          DEF_wr16;
          dstw:=ANDW(srcw,dstw);
          PutbackRMWord(ModRM,dstw);
          CLKR(24,24,11,24,16,7,2,ModRM);
        end;
    $22:begin //i_and_r8b
          DEF_r8b;
          dstb:=ANDB(srcb,dstb);
          PutBackRegByte(ModRM,dstb);
          CLKM(2,2,2,11,11,6,ModRM);
        end;
    $23:begin //i_and_r16w
          DEF_r16w;
          dstw:=ANDW(srcw,dstw);
          PutBackRegWord(ModRM,dstw);
          CLKR(15,15,8,15,11,6,2,ModRM);
        end;
    $24:begin //and_ald8
          DEF_ald8;
          r.aw.l:=ANDB(srcb,dstb);
          CLKS(4,4,2);
        end;
    $25:begin  //i_and_axd16
          DEF_axd16;
          r.aw.w:=ANDW(srcw,dstw);
          CLKS(4,4,2);
        end;
    $26:begin //i_es
          self.seg_prefix:=true;
          self.prefix_base:=r.ds1_r shl 4;
          self.contador:=self.contador+2;
          ejecuta_instruccion(self.fetch);
          self.seg_prefix:=false;
        end;
    $27:begin  //i_daa
          ADJ4(6,$60);
          CLKS(3,3,2);
        end;
    $28:begin  //i_sub_br8
          DEF_br8;
          dstb:=SUBB(srcb,dstb);
          PutbackRMByte(ModRM,dstb);
          CLKM(2,2,2,16,16,7,ModRM);
        end;
    $29:begin  //i_sub_wr16
          DEF_wr16;
          dstw:=SUBW(srcw,dstw);
          PutbackRMWord(ModRM,dstw);
          CLKR(24,24,11,24,16,7,2,ModRM);
        end;
    $2a:begin  //i_sub_r8b
          DEF_r8b;
          dstb:=SUBB(srcb,dstb);
          PutBackRegByte(ModRM,dstb);
          CLKM(2,2,2,11,11,6,ModRM);
        end;
    $2b:begin //sub_r16w
           DEF_r16w;
           dstw:=SUBW(srcw,dstw);
           PutBackRegWord(ModRM,dstw);
           CLKR(15,15,8,15,11,6,2,ModRM);
        end;
    $2c:begin  //i_sub_ald8
           DEF_ald8;
           r.aw.l:=SUBB(srcb,dstb);
           CLKS(4,4,2);
        end;
    $2d:begin  //i_sub_axd16
           DEF_axd16;
           r.aw.w:=SUBW(srcw,dstw);
           CLKS(4,4,2);
        end;
    $2e:begin  //i_cs 28_04
          self.seg_prefix:=true;
          self.prefix_base:=r.ps_r shl 4;
          self.contador:=self.contador+2;
          ejecuta_instruccion(self.fetch);
          self.seg_prefix:=false;
        end;
    $2f:begin //i_das
            self.ADJ4(-6,-$60);
            CLKS(3,3,2);
        end;
    $30:begin  //i_xor_br8
           DEF_br8;
           dstb:=XORB(srcb,dstb);
           PutbackRMByte(ModRM,dstb);
           CLKM(2,2,2,16,16,7,ModRM);
        end;
    $31:begin //i_xor_wr16
            DEF_wr16;
            dstw:=XORW(srcw,dstw);
            PutbackRMWord(ModRM,dstw);
            CLKR(24,24,11,24,16,7,2,ModRM);
        end;
    $32:begin //i_xor_r8b
            DEF_r8b;
            dstb:=XORB(srcb,dstb);
            PutBackRegByte(ModRM,dstb);
            CLKM(2,2,2,11,11,6,ModRM);
        end;
    $33:begin //xor_r16w
          DEF_r16w;
          dstw:=XORW(srcw,dstw);
          PutBackRegWord(ModRM,dstw);
          CLKR(15,15,8,15,11,6,2,ModRM);
        end;
    $34:begin //i_xor_ald8
          DEF_ald8;
          r.aw.l:=XORB(srcb,dstb);
          CLKS(4,4,2);
        end;
    $35:begin  //i_xor_axd16
          DEF_axd16;
          r.aw.w:=XORW(srcw,dstw);
          CLKS(4,4,2);
        end;
    $36:begin  //i_ss
          self.seg_prefix:=true;
          self.prefix_base:=r.ss_r shl 4;
          self.contador:=self.contador+2;
          ejecuta_instruccion(fetch);
          self.seg_prefix:=false;
        end;
    $38:begin  //i_cmp_br8
          DEF_br8;
          SUBB(srcb,dstb);
          CLKM(2,2,2,11,11,6,ModRM);
        end;
    $39:begin  //i_cmp_wr16
          DEF_wr16;
          SUBW(srcw,dstw);
          CLKR(15,15,8,15,11,6,2,ModRM);
        end;
    $3a:begin  //i_cmp_r8b
          DEF_r8b;
          SUBB(srcb,dstb);
          CLKM(2,2,2,11,11,6,ModRM);
        end;
    $3b:begin //i_cmp_r16w
          DEF_r16w;
          SUBW(srcw,dstw);
          CLKR(15,15,8,15,11,6,2,ModRM);
        end;
    $3c:begin  //i_cmp_ald8
          DEF_ald8;
          SUBB(srcb,dstb);
          CLKS(4,4,2);
        end;
    $3d:begin  //i_cmp_axd16
          DEF_axd16;
          SUBW(srcw,dstw);
          CLKS(4,4,2);
        end;
    $3e:begin //i_ds 29_04
          seg_prefix:=true;
          prefix_base:=r.ds0_r shl 4;
          self.contador:=self.contador+2;
          ejecuta_instruccion(self.fetch);
          seg_prefix:=false;
        end;
    $40:begin //inc_ax
          r.aw.w:=IncWordReg(r.aw.w);
          self.contador:=self.contador+2;
        end;
    $41:begin //inc_cx
          r.cw.w:=IncWordReg(r.cw.w);
          self.contador:=self.contador+2;
        end;
    $42:begin //inc_dx
          r.dw.w:=IncWordReg(r.dw.w);
          self.contador:=self.contador+2;
        end;
    $43:begin //inc_bx
          r.bw.w:=IncWordReg(r.bw.w);
          self.contador:=self.contador+2;
        end;
    $44:begin //inc_sp
          r.sp.w:=IncWordReg(r.sp.w);
          self.contador:=self.contador+2;
        end;
    $45:begin //inc_bp
          r.bp.w:=IncWordReg(r.bp.w);
          self.contador:=self.contador+2;
        end;
    $46:begin //inc_si
          r.ix.w:=IncWordReg(r.ix.w);
          self.contador:=self.contador+2;
        end;
    $47:begin //inc_di
          r.iy.w:=IncWordReg(r.iy.w);
          self.contador:=self.contador+2;
        end;
    $48:begin //dec_ax
          r.aw.w:=decWordReg(r.aw.w);
          self.contador:=self.contador+2;
        end;
    $49:begin //dec_cx
          r.cw.w:=DecWordReg(r.cw.w);
          self.contador:=self.contador+2;
        end;
    $4a:begin //dec_dx
          r.dw.w:=DecWordReg(r.dw.w);
          self.contador:=self.contador+2;
        end;
    $4b:begin //dec_bx
          r.bw.w:=DecWordReg(r.bw.w);
          self.contador:=self.contador+2;
        end;
    $4c:begin //dec_sp
          r.sp.w:=DecWordReg(r.sp.w);
          self.contador:=self.contador+2;
        end;
    $4d:begin //dec_bp
          r.bp.w:=DecWordReg(r.bp.w);
          self.contador:=self.contador+2;
        end;
    $4e:begin //dec_si
          r.ix.w:=DecWordReg(r.ix.w);
          self.contador:=self.contador+2;
        end;
    $4f:begin //dec_di
          r.iy.w:=DecWordReg(r.iy.w);
          self.contador:=self.contador+2;
        end;
    $50:begin //i_push_ax
          PUSH(r.aw.w);
          CLKS(12,8,3);
        end;
    $51:begin //i_push_cx
          PUSH(r.cw.w);
          CLKS(12,8,3);
        end;
    $52:begin //i_push_dx
          PUSH(r.dw.w);
          CLKS(12,8,3);
        end;
    $53:begin //i_push_bx
          PUSH(r.bw.w);
          CLKS(12,8,3);
        end;
    $54:begin //i_push_sp
          PUSH(r.sp.w);
          CLKS(12,8,3);
        end;
    $55:begin //i_push_bp
          PUSH(r.bp.w);
          CLKS(12,8,3);
        end;
    $56:begin //i_push_si
          PUSH(r.ix.w);
          CLKS(12,8,3);
        end;
    $57:begin //i_push_di
          PUSH(r.iy.w);
          CLKS(12,8,3);
        end;
    $58:begin //i_pop_ax
          r.aw.w:=POP;
          CLKS(12,8,5);
        end;
    $59:begin //i_pop_cx
          r.cw.w:=POP;
          CLKS(12,8,5);
        end;
    $5a:begin //i_pop_dx
          r.dw.w:=POP;
          CLKS(12,8,5);
        end;
    $5b:begin //i_pop_bx
          r.bw.w:=POP;
          CLKS(12,8,5);
        end;
    $5c:begin //i_pop_sp
          r.sp.w:=POP;
          CLKS(12,8,5);
        end;
    $5d:begin //i_pop_bp
          r.bp.w:=POP;
          CLKS(12,8,5);
        end;
    $5e:begin //i_pop_si
          r.ix.w:=POP;
          CLKS(12,8,5);
        end;
    $5f:begin //i_pop_di
          r.iy.w:=POP;
          CLKS(12,8,5);
        end;
    $60:begin //i_pusha
	        tmpw:=r.sp.w;
	        PUSH(r.aw.w);
          PUSH(r.cw.w);
	        PUSH(r.dw.w);
	        PUSH(r.bw.w);
          PUSH(tmpw);
	        PUSH(r.bp.w);
	        PUSH(r.ix.w);
	        PUSH(r.iy.w);
	        CLKS(67,35,20);
        end;
    $61:begin //i_popa
	        r.iy.w:=POP;
          r.ix.w:=POP;
          r.bp.w:=POP;
          POP;
          r.bw.w:=POP;
          r.dw.w:=POP;
          r.cw.w:=POP;
          r.aw.w:=POP;
          CLKS(75,43,22);
        end;
    $68:begin //i_push_d16
          tmpw:=fetchword;
          PUSH(tmpw);
          CLKW(12,12,5,12,8,5,r.sp.w);
        end;
    $6a:begin //i_push_d8
          tmpw:=shortint(fetch);
          self.PUSH(tmpw);
          CLKW(11,11,5,11,7,3,r.sp.w);
        end;
    $6b:begin //i_imul_d8
            DEF_r16w;
            tmpi:=shortint(fetch);
            tmpi:=smallint(srcw)*tmpi;
            r.f.CarryVal:=((tmpi div $8000)<>0) and ((tmpi div $8000)<>-1);
            r.f.OverVal:=r.f.CarryVal;
            PutBackRegWord(ModRM,word(tmpi));
            if (ModRM>=$c0) then self.contador:=self.contador+31
              else self.contador:=self.contador+39;
        end;
    $70:begin //jo
          i_JMP(r.f.OverVal);
          CLKS(4,4,3);
        end;
    $71:begin //jno
          i_JMP(not(r.f.OverVal));
          CLKS(4,4,3);
        end;
    $72:begin //i_jc
          i_JMP(r.f.CarryVal);
          CLKS(4,4,3);
        end;
    $73:begin //i_jnc
          i_JMP(not(r.f.CarryVal));
          CLKS(4,4,3);
        end;
    $74:begin
          i_JMP(r.f.ZeroVal);
          CLKS(4,4,3);
        end;
    $75:begin //jnz
          i_JMP(not(r.f.ZeroVal));
          CLKS(4,4,3);
        end;
    $76:begin //i_jce
          i_JMP((r.f.CarryVal or r.f.ZeroVal));
          CLKS(4,4,3);
        end;
    $77:begin //i_jnce
          i_JMP(not(r.f.CarryVal or r.f.ZeroVal));
          CLKS(4,4,3);
        end;
    $78:begin  //i_js
          i_JMP(r.f.SignVal);
          CLKS(4,4,3);
        end;
    $79:begin //i_jns
          i_JMP(not(r.f.SignVal));
          CLKS(4,4,3);
        end;
    $7a:begin //i_jp
          i_JMP(r.f.ParityVal);
          CLKS(4,4,3);
        end;
    $7b:begin  //i_jnp
          i_JMP(not(r.f.ParityVal));
          CLKS(4,4,3);
        end;
    $7c:begin //i_jl
          i_JMP(((r.f.SignVal<>r.f.OverVal) and not(r.f.ZeroVal)));
          CLKS(4,4,3);
        end;
    $7d:begin //i_jnl
          i_JMP((r.f.ZeroVal or (r.f.SignVal=r.f.OverVal)));
          CLKS(4,4,3);
        end;
    $7e:begin //i_jle
          i_JMP((r.f.ZeroVal or (r.f.SignVal<>r.f.OverVal)));
          CLKS(4,4,3);
        end;
    $7f:begin //i_jnle
          i_JMP(((r.f.SignVal=r.f.OverVal) and not(r.f.ZeroVal)));
          CLKS(4,4,3);
        end;
    $80:begin //i_80pre
          ModRM:=fetch;
          dstb:=GetRMByte(ModRM); //dst
          srcb:=fetch;  //src
    	    if (ModRM>=$c0) then CLKS(4,4,2)
            else if ((ModRM and $38)=$38) then CLKS(13,13,6)
                else CLKS(18,18,7);
      	  case (ModRM and $38) of
	          $00:begin //ADDB
                  dstb:=ADDB(srcb,dstb);
                  PutbackRMByte(ModRM,dstb);
                end;
      	    $08:begin  //ORB
                  dstb:=ORB(srcb,dstb);
                  PutbackRMByte(ModRM,dstb);
                end;
      	    $10:begin //ADDB CF 28/04
                  tmpw:=srcb+byte(r.f.CarryVal);
                  dstb:=ADDB(tmpw,dstb);
                  PutbackRMByte(ModRM,dstb);
                end;
      	    $18:MessageDlg('$80 SUBB CF', mtInformation,[mbOk],0);// src+=CF;	SUBB;	PutbackRMByte(ModRM,dst);
        		$20:begin //ANDB
                  dstb:=ANDB(srcb,dstb);
                  PutbackRMByte(ModRM,dstb);
                end;
    	      $28:begin
                  dstb:=SUBB(srcb,dstb);
                  PutbackRMByte(ModRM,dstb);
                end;
      	    $30:begin  //XORB
                  dstb:=XORB(srcb,dstb);
                  PutbackRMByte(ModRM,dstb);
                end;
      	    $38:SUBB(srcb,dstb);		 // CMPB
          end;
        end;
    $81:begin //i_81pre
          ModRM:=fetch;
          dstw:=GetRMWord(ModRM);
          srcw:=fetchword;
        	if (ModRM>=$c0) then CLKS(4,4,2)
            else if ((ModRM and $38)=$38) then CLKW(17,17,8,17,13,6,r.ea)
              else CLKW(26,26,11,26,18,7,r.ea);
          case (ModRM and $38) of
            $00:begin  //ADDW
                  dstw:=ADDW(srcw,dstw);
                  PutbackRMWord(ModRM,dstw);
                end;
  	        $08:begin
                   dstw:=ORW(srcw,dstw);
                   PutbackRMWord(ModRM,dstw);
                end;
      	    $10:MessageDlg('$81 ADDW CF', mtInformation,[mbOk],0);// src+=CF;	ADDW;	PutbackRMWord(ModRM,dst);	break;
      	    $18:MessageDlg('$81 SUBW CF', mtInformation,[mbOk],0);// src+=CF;	SUBW;	PutbackRMWord(ModRM,dst);	break;
        		$20:begin //ANDW
                  dstw:=ANDW(srcw,dstw);
                  PutBackRMWord(ModRM,dstw);
                end;
       	    $28:begin
                  dstw:=SUBW(srcw,dstw);
                  PutbackRMWord(ModRM,dstw);
                end;
      	    $30:begin  //XORW  01_05
                  dstw:=XORW(srcw,dstw);
                  PutbackRMWord(ModRM,dstw);
                end;
      	    $38:SUBW(srcw,dstw);	// CMP
          end;
        end;
    $82:begin //i_82pre
          ModRM:=fetch;
          dstb:=GetRMByte(ModRM); //dst
          srcb:=shortint(fetch);  //src
    	    if (ModRM>=$c0) then CLKS(4,4,2)
            else if ((ModRM and $38)=$38) then CLKS(13,13,6)
                else CLKS(18,18,7);
      	  case (ModRM and $38) of
	          $00:begin //ADDB
                  dstb:=ADDB(srcb,dstb);
                  PutbackRMByte(ModRM,dstb);
                end;
      	    $08:begin  //ORB
                  dstb:=ORB(srcb,dstb);
                  PutbackRMByte(ModRM,dstb);
                end;
      	    $10:begin //ADDB CF 28/04
                  tmpw:=srcb+byte(r.f.CarryVal);
                  dstb:=ADDB(tmpw,dstb);
                  PutbackRMByte(ModRM,dstb);
                end;
      	    $18:MessageDlg('$80 SUBB CF', mtInformation,[mbOk],0);// src+=CF;	SUBB;	PutbackRMByte(ModRM,dst);
        		$20:begin //ANDB
                  dstb:=ANDB(srcb,dstb);
                  PutbackRMByte(ModRM,dstb);
                end;
    	      $28:begin
                  dstb:=SUBB(srcb,dstb);
                  PutbackRMByte(ModRM,dstb);
                end;
      	    $30:begin  //XORB
                  dstb:=XORB(srcb,dstb);
                  PutbackRMByte(ModRM,dstb);
                end;
      	    $38:SUBB(srcb,dstb);		 // CMPB
          end;
        end;
    $83:begin //i_83pre
          ModRM:=fetch;
          dstw:=GetRMWord(ModRM);  //dst
          srcw:=shortint(fetch); //src
          if (ModRM>=$c0) then CLKS(4,4,2)
            else if ((ModRM and $38)=$38) then CLKW(17,17,8,17,13,6,r.ea)
              else CLKW(26,26,11,26,18,7,r.ea);
          case (ModRM and $38) of
      	    $00:begin  //ADDW
                  dstw:=ADDW(srcw,dstw);
                  PutbackRMWord(ModRM,dstw);
                end;
  	        $08:begin
                  dstw:=ORW(srcw,dstw);
                  PutbackRMWord(ModRM,dstw);
                end;
      	    $10:begin // 01_05
                   tmpdw:=srcw+byte(r.f.CarryVal);
                   dstw:=ADDW(tmpdw,dstw);
                   PutbackRMWord(ModRM,dstw);
                end;
      	    $18:MessageDlg('$83 SUBW CF', mtInformation,[mbOk],0);// src+=CF;	SUBW;	PutbackRMWord(ModRM,dst);	break;
        		$20:begin
                   dstw:=ANDW(srcw,dstw);
                   PutBackRMWord(ModRM,dstw);
                end;
       	    $28:begin
                  dstw:=SUBW(srcw,dstw);
                  PutbackRMWord(ModRM,dstw);
                end;
      	    $30:begin
                  dstw:=XORW(srcw,dstw);
                  PutbackRMWord(ModRM,dstw);
                end;
      	    $38:SUBW(srcw,dstw);	// CMP
          end;
        end;
    $84:begin  //i_test_br8 28_04
          DEF_br8;
          ANDB(srcb,dstb);
          CLKM(2,2,2,10,10,6,ModRM);
        end;
    $85:begin  //i_test_wr16
          DEF_wr16;
          ANDW(srcw,dstw);
          CLKR(14,14,8,14,10,6,2,ModRM);
        end;
    $86:begin //i_xchg_br8
          DEF_br8;
          PutBackRegByte(ModRM,dstb);
          PutbackRMByte(ModRM,srcb);
          CLKM(3,3,3,16,18,8,ModRM);
        end;
    $87:begin  //i_xchg_wr16
          DEF_wr16;
          PutBackRegWord(ModRM,dstw);
          PutbackRMWord(ModRM,srcw);
          CLKR(24,24,12,24,16,8,3,ModRM);
        end;
    $88:begin  //i_mov_br8
          ModRM:=fetch;
          srcb:=RegByte(ModRM);
          PutRMByte(ModRM,srcb);
          CLKM(2,2,2,9,9,3,ModRM);
        end;
    $89:begin  //i_mov_wr16
          ModRM:=fetch;
          srcw:=RegWord(ModRM);
          PutRMWord(ModRM,srcw);
          CLKR(13,13,5,13,9,3,2,ModRM);
        end;
    $8a:begin //i_mov_r8b
          ModRM:=fetch;
          srcb:=GetRMByte(ModRM);  //src
          PutBackRegByte(ModRM,srcb);
          CLKM(2,2,2,11,11,5,ModRM);
        end;
    $8b:begin //i_mov_r16w
          ModRM:=fetch;
          srcw:=GetRMWord(ModRM); //src
          PutBackRegWord(ModRM,srcw);
          CLKR(15,15,7,15,11,5,2,ModRM);
        end;
    $8c:begin //i_mov_wsreg
          ModRM:=fetch;
	        case (ModRM and $38) of
		        $00:PutRMWord(ModRM,r.DS1_r);
		        $08:PutRMWord(ModRM,r.PS_r);
		        $10:PutRMWord(ModRM,r.SS_r);
		        $18:PutRMWord(ModRM,r.DS0_r);
              else MessageDlg('$8c MOV Sreg - Invalid', mtInformation,[mbOk],0);
          end;
          CLKR(14,14,5,14,10,3,2,ModRM);
        end;
    $8d:begin //i_lea
          ModRM:=fetch;
          if (ModRM>=$c0) then //logerror("LDEA invalid mode %Xh\n", ModRM)
            halt(0)
            else begin
              self.GetEA(ModRM);
              PutBackRegWord(ModRM,r.EO);
            end;
          CLKS(4,4,2);
        end;
    $8e:begin //mov_sregw
          ModRM:=fetch;
          srcw:=GetRMWord(ModRM); //src
          CLKR(15,15,7,15,11,5,2,ModRM);
          case (ModRM and $38) of
        	    $00:r.ds1_r:=srcw; // mov es,ew
              $08:r.ps_r:=srcw; // mov cs,ew
	            $10:r.ss_r:=srcw; // mov ss,ew
	            $18:r.ds0_r:=srcw;// mov ds,ew
              else MessageDlg('$8e Mov Sreg invalido', mtInformation,[mbOk],0);
          end;
          self.no_interrupt:=true;
        end;
    $8f:begin   //i_popw
          ModRM:=fetch;
          dstw:=POP;
          PutRMWord(ModRM,dstw);
          self.contador:=self.contador+21;
        end;
    $90:self.contador:=self.contador+3; //nop
    $91:begin //i_xchg_axcx
           dstw:=r.cw.w;
           r.cw.w:=r.aw.w;
           r.aw.w:=dstw;
           self.contador:=self.contador+3;
        end;
    $92:begin //i_xchg_axdx
           dstw:=r.dw.w;
           r.dw.w:=r.aw.w;
           r.aw.w:=dstw;
           self.contador:=self.contador+3;
        end;
    $93:begin //i_xchg_axbx
           dstw:=r.bw.w;
           r.bw.w:=r.aw.w;
           r.aw.w:=dstw;
           self.contador:=self.contador+3;
        end;
    $94:begin //i_xchg_axsp
           dstw:=r.sp.w;
           r.sp.w:=r.aw.w;
           r.aw.w:=dstw;
           self.contador:=self.contador+3;
        end;
    $95:begin //i_xchg_axbp
           dstw:=r.bp.w;
           r.bp.w:=r.aw.w;
           r.aw.w:=dstw;
           self.contador:=self.contador+3;
        end;
    $96:begin //i_xchg_axsi
           dstw:=r.ix.w;
           r.ix.w:=r.aw.w;
           r.aw.w:=dstw;
           self.contador:=self.contador+3;
        end;
    $97:begin //i_xchg_axdi
           dstw:=r.iy.w;
           r.iy.w:=r.aw.w;
           r.aw.w:=dstw;
           self.contador:=self.contador+3;
        end;
    $98:begin  //i_cbw
          if (r.aw.l and $80)<>0 then r.aw.h:=$ff
            else r.aw.h:=0;
          self.contador:=self.contador+2;
        end;
    $99:begin //i_cwd 29_04
          if (r.aw.h and $80)<>0 then r.dw.w:=$ffff
            else r.dw.w:=0;
          self.contador:=self.contador+4;
        end;
    $9a:begin //i_call_far
          tmpw:=self.fetchword;  //tmp
          tmpw1:=self.fetchword;  //tmp2
          PUSH(r.ps_r);
          PUSH(r.ip);
          r.ip:=tmpw;
          r.ps_r:=tmpw1;
          self.prefetch_reset:=true;
          CLKW(29,29,13,29,21,9,r.sp.w);
        end;
    $9c:i_pushf;
    $9d:i_popf;
    $a0:begin //mov_aldisp
          srcw:=self.fetchword;
          r.aw.l:=GetMemB(DS0,srcw);
          CLKS(10,10,5);
        end;
    $a1:begin //mov_axdisp
          srcw:=self.fetchword;
          r.aw.w:=GetMemW(DS0,srcw);
          CLKW(14,14,7,14,10,5,srcw);
        end;
    $a2:begin //i_mov_dispal
          srcw:=self.fetchword;  //addr
          PutMemB(DS0,srcw,r.aw.l);
          CLKS(9,9,3);
        end;
    $a3:begin  //i_mov_dispax
          srcw:=self.fetchword;
          PutMemW(DS0,srcw,r.aw.w);
          CLKW(13,13,5,13,9,3,srcw);
        end;
    $a4:self.i_movsb;
    $a5:self.i_movsw;
    $a8:begin  //i_test_ald8
          DEF_ald8;
          ANDB(srcb,dstb);
          CLKS(4,4,2);
        end;
    $a9:begin //i_test_axd16
          DEF_axd16;
          ANDW(srcw,dstw);
          CLKS(4,4,2);
        end;
    $aa:self.i_stosb;
    $ab:self.i_stosw;
    $ac:self.i_lodsb;
    $ad:self.i_lodsw;
    $ae:self.i_scasb;
    $af:self.i_scasw;
    $b0:begin //mov_ald8
          r.aw.l:=fetch;
          CLKS(4,4,2);
        end;
    $b1:begin //mov_cld8
          r.cw.l:=fetch;
          CLKS(4,4,2);
        end;
    $b2:begin //mov_dld8
          r.dw.l:=fetch;
          CLKS(4,4,2);
        end;
    $b3:begin //mov_bld8
          r.bw.l:=fetch;
          CLKS(4,4,2);
        end;
    $b4:begin //mov_ahd8
          r.aw.h:=fetch;
          CLKS(4,4,2);
        end;
    $b5:begin //mov_chd8
          r.cw.h:=fetch;
          CLKS(4,4,2);
        end;
    $b6:begin //mov_dhd8
          r.dw.h:=fetch;
          CLKS(4,4,2);
        end;
    $b7:begin //mov_bhd8
          r.bw.h:=fetch;
          CLKS(4,4,2);
        end;
    $b8:begin //mov_axd16
          r.aw.l:=fetch;
          r.aw.h:=fetch;
          CLKS(4,4,2);
        end;
    $b9:begin //mov_cxd16
          r.cw.l:=fetch;
          r.cw.h:=fetch;
          CLKS(4,4,2);
        end;
    $ba:begin //mov_dxd16
          r.dw.l:=fetch;
          r.dw.h:=fetch;
          CLKS(4,4,2);
        end;
    $bb:begin //mov_bxd16
          r.bw.l:=fetch;
          r.bw.h:=fetch;
          CLKS(4,4,2);
        end;
    $bc:begin //mov_spd16
          r.sp.w:=fetchword;
          CLKS(4,4,2);
        end;
    $bd:begin //mov_bpd16
          r.bp.w:=fetchword;
          CLKS(4,4,2);
        end;
    $be:begin //mov_sid16
          r.ix.w:=fetchword;
          CLKS(4,4,2);
        end;
    $bf:begin //mov_did16
          r.iy.w:=fetchword;
          CLKS(4,4,2);
        end;
    $c0:begin  //i_rotshft_bd8
	        ModRM:=fetch;
          srcb:=GetRMByte(ModRM);
          dstb:=srcb;
	        c:=fetch;
	        CLKM(7,7,2,19,19,6,ModRM);
	        if (c<>0) then case (ModRM and $38) of
		          $00:begin // 03_05
                     repeat
                        dstb:=ROL_BYTE(dstb);
                        c:=c-1;
                        self.contador:=self.contador+1;
                     until not(c>0);
                     PutbackRMByte(ModRM,dstb);
                  end;
		          $08:begin
                    repeat
                      dstb:=ROR_BYTE(dstb);
                      c:=c-1;
                      self.contador:=self.contador+1;
                    until not(c>0);
                    PutbackRMByte(ModRM,dstb);
                  end;
		          $10:MessageDlg('$c0 ROLC_BYTE!', mtInformation,[mbOk],0);
		          $18:MessageDlg('$c0 RORC_BYTE!', mtInformation,[mbOk],0);
		          $20:begin
                    dstb:=SHL_BYTE(c,dstb);
                    self.PutbackRMByte(ModRM,dstb);
                  end;
		          $28:begin
                    dstb:=SHR_BYTE(c,dstb);
                    self.PutbackRMByte(ModRM,dstb);
                  end;
		          $30:MessageDlg('$c0 SHLA_BYTE indefinido!', mtInformation,[mbOk],0);
		          $38:MessageDlg('$c0 SHRA_BYTE!', mtInformation,[mbOk],0);// SHRA_BYTE(c); break;
	        end;
        end;
    $c1:begin  //i_rotshft_wd8
	        ModRM:=fetch;
          srcw:=GetRMWord(ModRM);
          dstw:=srcw;
	        c:=fetch;
	        CLKM(7,7,2,27,19,6,ModRM);
          if (c<>0) then case (ModRM and $38) of
		          $00:begin //03_05
                    repeat
                       dstw:=ROL_WORD(dstw);
                       c:=c-1;
                       self.contador:=self.contador+1;
                    until not(c>0);
                    PutbackRMWord(ModRM,dstw);
                  end;
		          $08:begin //03_05
                    repeat
                       dstw:=ROR_WORD(dstw);
                       c:=c-1;
                       self.contador:=self.contador+1;
                    until not(c>0);
                    PutbackRMWord(ModRM,dstw);
                  end;
		          $10:MessageDlg('$c1 ROLC_WORD!', mtInformation,[mbOk],0);// do { ROLC_WORD; c--; CLK(1); } {while (c>0); PutbackRMWord(ModRM,(WORD)dst); break;
 		          $18:MessageDlg('$c1 RORC_WORD!', mtInformation,[mbOk],0); // do { RORC_WORD; c--; CLK(1); }{ while (c>0); PutbackRMWord(ModRM,(WORD)dst); break;
 		          $20:begin
                    dstw:=SHL_WORD(c,dstw);
                    self.PutbackRMWord(ModRM,dstw);
                  end;
		          $28:begin
                    dstw:=SHR_WORD(c,dstw);
                    self.PutbackRMWord(ModRM,dstw);
                  end;
		          $30:MessageDlg('$c1 SHLA_WORD indefinido!', mtInformation,[mbOk],0);
		          $38:SHRA_WORD(c,dstw,ModRM); //03_05
	        end;
        end;
    $c3:begin //i_ret
          r.ip:=POP;
          self.prefetch_reset:=true;
          CLKS(19,19,10);
        end;
    $c4:begin //i_les_dw   01_05
          ModRM:=fetch;
          tmpw:=GetRMWord(ModRM);
          PutBackRegWord(ModRM,tmpw);
          r.ds1_r:=self.read_word((r.ea and $f0000) or ((r.ea+2) and $ffff));
          CLKW(26,26,14,26,18,10,r.ea);
        end;
    $c5:begin //i_lds_dw  01_05
          ModRM:=fetch;
          tmpw:=GetRMWord(ModRM);
          PutBackRegWord(ModRM,tmpw);
          r.ds0_r:=self.read_word((r.ea and $f0000) or ((r.ea+2) and $ffff));
          CLKW(26,26,14,26,18,10,r.ea);
        end;
    $c6:begin //i_mov_bd8
          ModRM:=fetch;
          PutImmRMByte(ModRM);
          if ModRM>=$c0 then self.contador:=self.contador+4
            else self.contador:=self.contador+11;
        end;
    $c7:begin  //i_mov_wd16
          ModRM:=fetch;
          PutImmRMWord(ModRM);
          if ModRM>=$c0 then self.contador:=self.contador+4
            else self.contador:=self.contador+15;
        end;
    $c8:begin  //i_enter
          tmpw:=fetch;
	        self.contador:=self.contador+23;
          tmpw:=tmpw+(fetch shl 8);
	        tmpb:=fetch;
          self.PUSH(r.bp.w);
          r.bp.w:=r.sp.w;
          r.sp.w:=r.sp.w-tmpw;
	        for tmpb1:=1 to tmpb do begin
		        self.PUSH(self.GetMemW(SS,r.bp.w-tmpb1*2));
            self.contador:=self.contador+16;
	        end;
	        if tmpb<>0 then self.PUSH(r.bp.w);
        end;
    $c9:begin //i_leave
          r.sp.w:=r.bp.w;
          r.bp.w:=POP;
          self.contador:=self.contador+8;
        end;
    $cb:begin  //i_retf
          r.ip:=POP;
          r.ps_r:=POP;
          self.prefetch_reset:=true;
          CLKS(29,29,16);
        end;
    $cf:begin  //i_iret
          r.ip:=POP;
          r.ps_r:=POP;
          i_popf;
          self.prefetch_reset:=true;
          CLKS(39,39,19);
        end;
    $d0:begin  //i_rotshft_b
	        ModRM:=fetch;
          srcb:=GetRMByte(ModRM);
          dstb:=srcb;
        	CLKM(6,6,2,16,16,7,ModRM);
          case (ModRM and $38) of
        		$00:begin // 01_05
                  dstb:=ROL_BYTE(dstb);
                  PutbackRMByte(ModRM,dstb);
                  r.f.OverVal:=((srcb xor dstb) and $80)<>0;
                end;
        		$08:begin // 01_05
                  dstb:=ROR_BYTE(dstb);
                  PutbackRMByte(ModRM,dstb);
                  r.f.OverVal:=((srcb xor dstb) and $80)<>0;
                end;
        		$10:begin
                  dstb:=ROLC_BYTE(dstb);
                  PutbackRMByte(ModRM,dstb);
                  r.f.OverVal:=((srcb xor dstb) and $80)<>0;
                end;
        		$18:begin
                  dstb:=RORC_BYTE(dstb);
                  PutbackRMByte(ModRM,dstb);
                  r.f.OverVal:=((srcb xor dstb) and $80)<>0;
                end;
        		$20:begin  //SHL_BYTE
                  dstb:=SHL_BYTE(1,dstb);
                  self.PutbackRMByte(ModRM,dstb);
                  r.f.OverVal:=((srcb xor dstb) and $80)<>0;
                end;
        		$28:begin
                  dstb:=SHR_BYTE(1,dstb);
                  self.PutbackRMByte(ModRM,dstb);
                  r.f.OverVal:=((srcb xor dstb) and $80)<>0;
                end;
        		$30:MessageDlg('$d0 SHLA_BYTE Invalido!', mtInformation,[mbOk],0);
        		$38:MessageDlg('$d0 SHRA_BYTE', mtInformation,[mbOk],0);// SHRA_BYTE(1); nec_state->OverVal = 0; break;
	        end;
        end;
    $d1:begin  //i_rotshft_w
          ModRM:=fetch;
          srcw:=GetRMWord(ModRM);
          dstw:=srcw;
          CLKM(6,6,2,24,16,7,ModRM);
	        case (ModRM and $38) of
            $00:begin
                  dstw:=ROL_WORD(dstw);
                  PutbackRMWord(ModRM,dstw);
                  r.f.OverVal:=((srcw xor dstw) and $8000)<>0;
                end;
		        $08:begin
                  dstw:=ROR_WORD(dstw);
                  PutbackRMWord(ModRM,dstw);
                  r.f.OverVal:=((srcw xor dstw) and $8000)<>0;
                end;
		        $10:begin
                  dstw:=ROLC_WORD(dstw);
                  PutbackRMWord(ModRM,dstw);
                  r.f.OverVal:=((srcw xor dstw) and $8000)<>0;
                end;
		        $18:MessageDlg('$d1 RORC_WORD', mtInformation,[mbOk],0);//RORC_WORD; PutbackRMWord(ModRM,(WORD)dst); nec_state->OverVal = (src^dst)&0x8000; break;
		        $20:begin //28_04
                  dstw:=SHL_WORD(1,dstw);
                  self.PutbackRMWord(ModRM,dstw);
                  r.f.OverVal:=((srcw xor dstw) and $8000)<>0;
                end;
		        $28:begin
                  dstw:=SHR_WORD(1,dstw);
                  self.PutbackRMWord(ModRM,dstw);
                  r.f.OverVal:=((srcw xor dstw) and $8000)<>0;
                end;
		        $30:MessageDlg('$d1 SHLA_WORD Invalido!', mtInformation,[mbOk],0);
		        $38:begin
                  SHRA_WORD(1,dstw,ModRM);
                  r.f.OverVal:=false;
                end;
	        end;
        end;
    $d2:begin //i_rotshft_bcl
          ModRM:=fetch;
          srcb:=GetRMByte(ModRM);
          dstb:=srcb;
          c:=r.cw.l;
	        CLKM(7,7,2,19,19,6,ModRM);
	        if (c<>0) then case (ModRM and $38) of
		        $00:begin
                   repeat
                      dstb:=ROL_BYTE(dstb);
                      c:=c-1;
                      self.contador:=self.contador+1;
                   until not(c>0);
                   PutbackRMByte(ModRM,dstb);
                end;
		        $08:MessageDlg('$d2 ROR_BYTE', mtInformation,[mbOk],0); // do { ROR_BYTE;  c--; CLK(1); }// while (c>0); PutbackRMByte(ModRM,(BYTE)dst); break;
            $10:begin
                   repeat
                      dstb:=ROLC_BYTE(dstb);
                      c:=c-1;
                      self.contador:=self.contador+1;
                   until not(c>0);
                   PutbackRMByte(ModRM,dstb);
                end;
		        $18:begin
                   repeat
                      dstb:=RORC_BYTE(dstb);
                      c:=c-1;
                      self.contador:=self.contador+1;
                   until not(c>0);
                   PutbackRMByte(ModRM,dstb);
                end;
		        $20:begin
                  dstb:=SHL_BYTE(c,dstb);
                  self.PutbackRMByte(ModRM,dstb);
                end;
		        $28:begin
                  dstb:=SHR_BYTE(c,dstb);
                  self.PutbackRMByte(ModRM,dstb);
                end;
		        $30:MessageDlg('$d2 SHLA_BYTE Invalido!', mtInformation,[mbOk],0);
		        $38:MessageDlg('$d2 SHRA_BYTE', mtInformation,[mbOk],0); // SHRA_BYTE(c); break;
	        end;
        end;
    $d3:begin //i_rotshft_wcl
          ModRM:=fetch;
          srcw:=GetRMWord(ModRM);
          dstw:=srcw;
          c:=r.cw.l;
	        CLKM(7,7,2,19,19,6,ModRM);
	        if (c<>0) then case (ModRM and $38) of
		        $00:MessageDlg('$d3 ROL_WORD', mtInformation,[mbOk],0); // do { ROL_BYTE;  c--; CLK(1); } //while (c>0); PutbackRMByte(ModRM,(BYTE)dst); break;
		        $08:MessageDlg('$d3 ROR_WORD', mtInformation,[mbOk],0); // do { ROR_BYTE;  c--; CLK(1); }// while (c>0); PutbackRMByte(ModRM,(BYTE)dst); break;
            $10:MessageDlg('$d3 ROLC_WORD', mtInformation,[mbOk],0);
		        $18:MessageDlg('$d3 RORC_WORD', mtInformation,[mbOk],0);
		        $20:begin
                  dstw:=SHL_WORD(c,dstw);
                  self.PutbackRMWord(ModRM,dstw);
                end;
		        $28:begin
                  dstw:=SHR_WORD(c,dstw);
                  self.PutbackRMWord(ModRM,dstw);
                end;
		        $30:MessageDlg('$d3 SHLA_WORD Invalido!', mtInformation,[mbOk],0);
		        $38:SHRA_WORD(c,dstw,ModRM);
	        end;
        end;
    $e1:begin //i_loope
            tmpb:=fetch;
            r.cw.w:=r.cw.w-1;
            if (r.f.ZeroVal and (r.cw.w<>0)) then begin
              r.ip:=r.ip+shortint(tmpb);
              CLKS(14,14,6);
            end else CLKS(5,5,3);
        end;
    $e2:begin //i_loop
            tmpb:=fetch;
            r.cw.w:=r.cw.w-1;
            if (r.cw.w<>0) then begin
              r.ip:=r.ip+shortint(tmpb);
              CLKS(13,13,6);
            end else CLKS(5,5,3);
        end;
    $e3:begin //i_jcxz
            tmpb:=fetch;
            if (r.cw.w=0) then begin
              r.ip:=r.ip+shortint(tmpb);
              CLKS(13,13,6);
            end else CLKS(5,5,3);
        end;
    $e4:begin //i_inal
         tmpb:=fetch;
         self.r.aw.l:=self.inbyte(tmpb);
         CLKS(9,9,5);
        end;
    $e5:begin //inax
         tmpb:=fetch;
         r.aw.w:=self.inword(tmpb);
         CLKW(13,13,7,13,9,5,tmpb);
        end;
    $e6:begin //outal
         tmpb:=fetch;
         self.outbyte(tmpb,r.aw.l);
         CLKS(8,8,3);
        end;
    $e7:begin //outax
          tmpb:=fetch;
          self.outword(tmpb,r.aw.w);
          CLKW(12,12,5,12,8,3,tmpb);
        end;
    $e8:begin //i_call_d16
          tmpw:=self.fetchword;
          PUSH(r.ip);
          r.ip:=r.ip+smallint(tmpw);
          self.prefetch_reset:=true;
          self.contador:=self.contador+24;
        end;
    $e9:begin //jmp_d16
          tmpw:=self.fetchword;
          r.ip:=r.ip+smallint(tmpw);
          self.prefetch_reset:=true;
          self.contador:=self.contador+15;
        end;
    $ea:begin  //jump_far
           tmpw:=self.fetchword;
           tmpw1:=self.fetchword;
           r.ip:=tmpw;
           r.ps_r:=tmpw1;
           self.prefetch_reset:=true;
           self.contador:=self.contador+27;
        end;
    $eb:begin //i_jmp_d8
            tmpb:=fetch;
            r.ip:=r.ip+shortint(tmpb);
            self.contador:=self.contador+12;
        end;
    $ec:begin //i_inaldx
              self.r.aw.l:=self.inbyte(self.r.dw.w);
              CLKS(8,8,5);
        end;
    $ee:begin //i_outdxal
            self.outbyte(self.r.dw.w,self.r.aw.l);
            CLKS(8,8,3);
        end;
    $ef:begin //i_outdxax
            self.outword(self.r.dw.w,self.r.aw.w);
            CLKW(12,12,5,12,8,3,r.dw.w)
        end;
    $f2:begin //i_repne 29_04
            tmpb:=fetch;
            tmpw:=r.cw.w;
            case tmpb of
              $26:begin
                    seg_prefix:=true;
                    prefix_base:=r.ds1_r shl 4;
                    tmpb:=fetch;
                    self.contador:=self.contador+2;
                  end;
              $2e:begin
                    seg_prefix:=true;
                    prefix_base:=r.ps_r shl 4;
                    tmpb:=fetch;
                    self.contador:=self.contador+2;
                  end;
		          $36:begin
                    seg_prefix:=true;
                    prefix_base:=r.ss_r shl 4;
                    tmpb:=fetch;
                    self.contador:=self.contador+2;
                  end;
		          $3e:begin
                    seg_prefix:=true;
                    prefix_base:=r.ds0_r shl 4;
                    tmpb:=fetch;
                    self.contador:=self.contador+2;
                  end;
            end;
            self.contador:=self.contador+2;
            case tmpb of
		     {    $6c:  CLK(2); if (c) do { i_insb();  c--; } //while (c>0); Wreg(CW)=c; break;
      {       $6d:  CLK(2); if (c) do { i_insw();  c--; } //while (c>0); Wreg(CW)=c; break;
      {    		$6e:  CLK(2); if (c) do { i_outsb(); c--; } //while (c>0); Wreg(CW)=c; break;
       {   		$6f:  CLK(2); if (c) do { i_outsw(); c--; } //while (c>0); Wreg(CW)=c; break;
        {  		$a4:  CLK(2); if (c) do { i_movsb(); c--; } //while (c>0); Wreg(CW)=c; break;
          {		$a6:  CLK(2); if (c) do { i_cmpsb(); c--; } //while (c>0 && ZF==0);    Wreg(CW)=c; break;
           {	$a7:  CLK(2); if (c) do { i_cmpsw(); c--; } //while (c>0 && ZF==0);    Wreg(CW)=c; break;
           {	$aa:  CLK(2); if (c) do { i_stosb(); c--; } //while (c>0); Wreg(CW)=c; break;
           {	$ab:  CLK(2); if (c) do { i_stosw(); c--; } //while (c>0); Wreg(CW)=c; break;
           {	$ac:  CLK(2); if (c) do { i_lodsb(); c--; } //while (c>0); Wreg(CW)=c; break;
           {	$ad:  CLK(2); if (c) do { i_lodsw(); c--; } //while (c>0); Wreg(CW)=c; break;
              $a4:if (tmpw<>0) then begin
                    repeat
                      self.i_movsb;
                      tmpw:=tmpw-1;
                    until not(tmpw>0);
                    r.cw.w:=tmpw;
                  end;
              $a5:if (tmpw<>0) then begin
                    repeat
                      self.i_movsw;
                      tmpw:=tmpw-1;
                    until not(tmpw>0);
                    r.cw.w:=tmpw;
                  end;
           	  $ae:if (tmpw<>0) then begin
                    repeat
                      self.i_scasb;
                      tmpw:=tmpw-1;
                    until not((tmpw>0) and not(r.f.ZeroVal));
                    r.cw.w:=tmpw;
                  end;
           	  $af:if (tmpw<>0) then begin
                    repeat
                      self.i_scasw;
                      tmpw:=tmpw-1;
                    until not((tmpw>0) and not(r.f.ZeroVal));
                    r.cw.w:=tmpw;
                  end;
              else MessageDlg('$f2 Mal! '+inttohex(tmpb,10), mtInformation,[mbOk],0);
	          end;
	        seg_prefix:=false;
        end;
    $f3:begin //repe
            tmpb:=fetch;  //next
            tmpw:=r.cw.w;  //c
            case tmpb of // Puede que coja esto o NO!!!
        	    $26:begin
                    self.seg_prefix:=true;
                    self.prefix_base:=r.ds1_r shl 4;
                    tmpb:=self.fetch;
                    self.contador:=self.contador+2;
                  end;
        	    $2e:begin
                    self.seg_prefix:=true;
                    self.prefix_base:=r.ps_r shl 4;
                    tmpb:=self.fetch;
                    self.contador:=self.contador+2;
                  end;
      	      $36:begin
                    self.seg_prefix:=true;
                    self.prefix_base:=r.ss_r shl 4;
                    tmpb:=self.fetch;
                    self.contador:=self.contador+2;
                  end;
        	    $3e:begin
                    self.seg_prefix:=true;
                    self.prefix_base:=r.ds0_r shl 4;
                    tmpb:=self.fetch;
                    self.contador:=self.contador+2;
                  end;
            end;
            self.contador:=self.contador+2;
            case tmpb of
        	    $6c:MessageDlg('$f3 i_insb', mtInformation,[mbOk],0);
        	    $6d:MessageDlg('$f3 i_insw', mtInformation,[mbOk],0);
        	    $6e:MessageDlg('$f3 i_outsb', mtInformation,[mbOk],0);
        	    $6f:MessageDlg('$f3 i_outsw', mtInformation,[mbOk],0);
        	    $a4:if (tmpw<>0) then begin  //i_movsb
                    repeat
                       self.i_movsb;
                       tmpw:=tmpw-1;
                    until not(tmpw>0);
                    r.cw.w:=tmpw;
                  end;
        	    $a5:if (tmpw<>0) then begin //i_movsw
                    repeat
                       self.i_movsw;
                       tmpw:=tmpw-1;
                    until not(tmpw>0);
                    r.cw.w:=tmpw;
                  end;
        	    $a6:MessageDlg('$f3 i_cmpsb', mtInformation,[mbOk],0);
        	    $a7:MessageDlg('$f3 i_cmpsw', mtInformation,[mbOk],0);
        	    $aa:if (tmpw<>0) then begin
                    repeat
                       self.i_stosb;
                       tmpw:=tmpw-1;
                    until not(tmpw>0);
                    r.cw.w:=tmpw;
                  end;
        	    $ab:if (tmpw<>0) then begin
                    repeat
                       self.i_stosw;
                       tmpw:=tmpw-1;
                    until not(tmpw>0);
                    r.cw.w:=tmpw;
                  end;
        	    $ac:if (tmpw<>0) then begin
                    repeat
                       self.i_lodsb;
                       tmpw:=tmpw-1;
                    until not(tmpw>0);
                    r.cw.w:=tmpw;
                  end;
        	    $ad:if (tmpw<>0) then begin
                    repeat
                       self.i_lodsw;
                       tmpw:=tmpw-1;
                    until not(tmpw>0);
                    r.cw.w:=tmpw;
                  end;
        	    $ae:if (tmpw<>0) then begin
                    repeat
                       self.i_scasb;
                       tmpw:=tmpw-1;
                    until not((tmpw>0) and r.f.ZeroVal);
                    r.cw.w:=tmpw;
                  end;
        	    $af:if (tmpw<>0) then begin
                    repeat
                       self.i_scasw;
                       tmpw:=tmpw-1;
                    until not((tmpw>0) and r.f.ZeroVal);
                    r.cw.w:=tmpw;
                  end;
          		else MessageDlg('$f3 REPE invalido', mtInformation,[mbOk],0);
            end;
          	self.seg_prefix:=false;
        end;
    $f6:begin //i_f6pre
	         ModRM:=self.fetch;
           tmpb:=GetRMByte(ModRM); //tmp
           case (ModRM and $38) of
		          $00:begin //TEST
                    tmpb:=tmpb and fetch;
                    r.f.CarryVal:=false;
                    r.f.OverVal:=false;
                    SetSZPF_Byte(tmpb);
                    if (ModRM>=$c0) then self.contador:=self.contador+4
                      else self.contador:=self.contador+11;
                  end;
		          $08:MessageDlg('Opcode indefinido $f6 08', mtInformation,[mbOk], 0);
		          $10:begin //29_04
                    PutbackRMByte(ModRM,not(tmpb));
                    if (ModRM>=$c0) then self.contador:=self.contador+2
                      else self.contador:=self.contador+16;
                  end;
		          $18:begin
                    r.f.CarryVal:=(tmpb<>0);
                    tmpw:=not(tmpb)+1;
                    SetSZPF_Byte(tmpw);
                    PutbackRMByte(ModRM,tmpw);
                    if (ModRM>=$c0) then self.contador:=self.contador+2
                      else self.contador:=self.contador+16;
                  end;
		          $20:begin //MULU
                    tmpdw:=r.aw.l*tmpb;
                    r.aw.w:=tmpdw;
                    r.f.OverVal:=(r.aw.h<>0);
                    r.f.CarryVal:=r.f.OverVal;
                    if (ModRM>=$c0) then self.contador:=self.contador+30
                      else self.contador:=self.contador+36;
                  end;
		          $28:MessageDlg('$f6 MUL', mtInformation,[mbOk], 0); // result = (INT16)((INT8)nec_state->regs.b[AL])*(INT16)((INT8)tmp); nec_state->regs.w[AW]=(WORD)result; nec_state->CarryVal=nec_state->OverVal=(nec_state->regs.b[AH]!=0); nec_state->icount-=(ModRM >=0xc0 )?30:36; break; /* MUL */
              $30:if (tmpb<>0) then begin
                     tmpw:=r.aw.w;
	                   tmpb1:=tmpw mod tmpb;
                     tmpw:=tmpw div tmpb;
	                   if (tmpw>$ff) then MessageDlg('$f6 DIVUB mod>$ff', mtInformation,[mbOk], 0)
                      else begin
		                      r.aw.l:=tmpw;
		                      r.aw.h:=tmpb1;
	                    end;
                      if (ModRM>=$c0) then self.contador:=self.contador+43
                      else self.contador:=self.contador+53;
                  end else MessageDlg('$f6 DIVUB div por 0', mtInformation,[mbOk], 0);
		          $38:MessageDlg('$f6 DIVB', mtInformation,[mbOk], 0); // if (tmp) { DIVB;  } else nec_interrupt(nec_state, 0,0); nec_state->icount-=(ModRM >=0xc0 )?43:53; break;
           end;
        end;
    $f7:begin  //i_f7pre
           ModRM:=fetch;
           tmpw:=GetRMWord(ModRM);  //tmp
           case (ModRM and $38) of
          		$00:begin  // TEST
                    tmpw1:=self.fetchword;
                    tmpw:=tmpw and tmpw1;
                    r.f.CarryVal:=false;
                    r.f.OverVal:=false;
                    SetSZPF_Word(tmpw);
                    if (ModRM>=$c0) then self.contador:=self.contador+4
                      else self.contador:=self.contador+11;
                  end;
          		$08:MessageDlg('Opcode indefinido $f7 08', mtInformation,[mbOk], 0);
          		$10:begin  // NOT
                    PutbackRMWord(ModRM,not(tmpw));
                    if (ModRM>=$c0) then self.contador:=self.contador+2
                      else self.contador:=self.contador+16;
                  end;
          		$18:begin  //NEG
                    r.f.CarryVal:=(tmpw<>0);
                    tmpdw:=not(tmpw)+1;
                    SetSZPF_Word(tmpdw);
                    PutbackRMWord(ModRM,tmpdw);
                    if (ModRM>=$c0) then self.contador:=self.contador+2
                      else self.contador:=self.contador+16;
                  end;
          		$20:begin //MULU
                    tmpdw:=r.aw.w*tmpw;
                    r.aw.w:=tmpdw and $ffff;
                    r.dw.w:=tmpdw shr 16;
                    r.f.CarryVal:=(r.dw.w<>0);
                    r.f.OverVal:=r.f.CarryVal;
                    if (ModRM>=$c0) then self.contador:=self.contador+30
                      else self.contador:=self.contador+36;
                  end;
          		$28:begin // MUL
                    tmpi:=smallint(r.aw.w)*smallint(tmpw);
                    r.aw.w:=tmpi and $ffff;
                    r.dw.w:=tmpi div $10000;
                    r.f.CarryVal:=(r.dw.w<>0);
                    r.f.OverVal:=r.f.CarryVal;
                    if (ModRM>=$c0) then self.contador:=self.contador+30
                      else self.contador:=self.contador+36;
                   end;
          		$30: if (tmpw<>0) then begin
                    tmpdw:=(r.dw.w shl 16) or r.aw.w;
	                  tmpw1:=tmpdw mod tmpw;
                    tmpdw:=tmpdw div tmpw;
                    if (tmpdw>$ffff) then MessageDlg('$f7 DIVUW mod>$ffff', mtInformation,[mbOk], 0)
                      else begin
                        r.aw.w:=tmpdw;
                        r.dw.w:=tmpw1;
                      end;
                    if (ModRM>=$c0) then self.contador:=self.contador+43
                      else self.contador:=self.contador+53;
                  end else MessageDlg('$f7 DIVUW div por 0', mtInformation,[mbOk], 0);
           		$38:if (tmpw<>0) then begin
                    tmpi:=(smallint(r.dw.w) shl 16) or smallint(r.aw.w);
	                  tmpw1:=tmpi mod smallint(tmpw);
                    tmpi:=tmpi div smallint(tmpw);
                    if (tmpi>$ffff) then MessageDlg('$f7 DIVU mod>$ffff', mtInformation,[mbOk], 0)
                      else begin
                        r.aw.w:=tmpi;
                        r.dw.w:=tmpw1;
                      end;
                    if (ModRM>=$c0) then self.contador:=self.contador+43
                      else self.contador:=self.contador+53;
                  end else MessageDlg('$f7 DIVU div por 0', mtInformation,[mbOk], 0);
           end;
        end;
    $f8:begin //i_clc
           r.f.CarryVal:=false;
           self.contador:=self.contador+2;
        end;
    $f9:begin //i_stc
           r.f.CarryVal:=true;
           self.contador:=self.contador+2;
        end;
    $fa:begin //di
           r.f.I:=false;
           self.contador:=self.contador+2;
        end;
    $fb:begin //ei
           r.f.I:=true;
           self.contador:=self.contador+2;
        end;
    $fc:begin //cld
           r.f.d:=false;
           self.contador:=self.contador+2;
        end;
    $fd:begin //std
           r.f.d:=true;
           self.contador:=self.contador+2;
        end;
    $fe:begin  //fepre
           ModRM:=fetch;  //modmr
           tmpb:=GetRMByte(ModRM);  //tmp
           case (ModRM and $38) of
    	        $00:begin  // INC
                     tmpw:=tmpb+1;
                     r.f.OverVal:=(tmpb=$7f);
                     r.f.AuxVal:=((tmpw xor (tmpb xor 1)) and $10)<>0;
                     SetSZPF_Byte(tmpw);
                     PutbackRMByte(ModRM,tmpw);
                     CLKM(2,2,2,16,16,7,ModRM);
                  end;
		          $08:begin // DEC
                     tmpw:=tmpb-1;
                     r.f.OverVal:=(tmpb=$80);
                     r.f.AuxVal:=((tmpw xor (tmpb xor 1)) and $10)<>0;
                     SetSZPF_Byte(tmpw);
                     PutbackRMByte(ModRM,tmpw);
                     CLKM(2,2,2,16,16,7,ModRM);
                  end;
              else MessageDlg('Instruccion $fe no implementada', mtInformation,[mbOk], 0);
           end;
        end;
    $ff:begin  //i_ffpre
          ModRM:=fetch;
          tmpw:=GetRMWord(ModRM);  //tmp
          case (ModRM and $38) of
          	  $00:begin  //INC
                    tmpdw:=tmpw+1;  //tmp1
                    r.f.OverVal:=(tmpw=$7fff);
                    r.f.AuxVal:=((tmpdw xor (tmpw xor 1)) and $10)<>0;
                    SetSZPF_Word(tmpdw);
                    PutbackRMWord(ModRM,tmpdw);
                    CLKM(2,2,2,24,16,7,ModRM);
                  end;
        		  $08:begin  //DEC
                    tmpdw:=tmpw-1;  //tmp1
                    r.f.OverVal:=(tmpw=$8000);
                    r.f.AuxVal:=((tmpdw xor (tmpw xor 1)) and $10)<>0;
                    SetSZPF_Word(tmpdw);
                    PutbackRMWord(ModRM,tmpdw);
                    CLKM(2,2,2,24,16,7,ModRM);
                  end;
        		  $10:begin // CALL
                    PUSH(r.ip);
                    r.ip:=tmpw;
                    self.prefetch_reset:=true;
                    if (ModRM>=$c0) then self.contador:=self.contador+16
                      else self.contador:=self.contador+20;
                  end;
         		  $18:MessageDlg('FF CALL_FAR', mtInformation,[mbOk], 0); // tmp1 = nec_state->sregs[PS]; nec_state->sregs[PS] = GetnextRMWord; PUSH(tmp1); PUSH(nec_state->ip); nec_state->ip = tmp; CHANGE_PC; nec_state->icount-=(ModRM >=0xc0 )?16:26; break; /* CALL FAR */
        		  $20:begin
                    r.ip:=tmpw;
                    self.prefetch_reset:=true;
                    self.contador:=self.contador+13;
                  end;
        		  $28:MessageDlg('FF JMP_FAR', mtInformation,[mbOk], 0); //nec_state->ip = tmp; nec_state->sregs[PS] = GetnextRMWord; CHANGE_PC; nec_state->icount-=15; break; /* JMP FAR */
        		  $30:begin
                    PUSH(tmpw);
                    self.contador:=self.contador+4;
                  end;
        		  else MessageDlg('Instruccion $ff no implementada', mtInformation,[mbOk], 0);
          end;
        end;
    else MessageDlg('Intruccion desconocida NEC PC: '+inttohex(((r.ps_r shl 4)+r.ip)-1,10)+' INST: '+inttohex(instruccion,4)+' oldPC: '+inttohex(((r.ps_r shl 4)+r.old_pc)-1,10), mtInformation,[mbOk], 0);
  end; //del case
end;

procedure cpu_nec.set_input(irqline,state:byte;vect_req:byte=$ff);
begin
case irqline of
  INT_IRQ:begin
            if (state=CLEAR_LINE) then self.irq_pending:=self.irq_pending and not(INT_IRQ)
	          else begin
              self.vect_req:=vect_req;
              self.irq_pending:=self.irq_pending or INT_IRQ;
		          //self.halted:=false;
            end;
          end;
  NMI_IRQ:begin
            if (self.nmi_state=state) then exit;
	          self.nmi_state:=state;
	          if (state<>CLEAR_LINE) then begin
		          self.irq_pending:=self.irq_pending or NMI_IRQ;
		          //self.halted:=false;
            end;
          end;
end;
end;

procedure cpu_nec.nec_interrupt(vect_num:word);
begin
  i_pushf;
  r.f.t:=false;
  r.f.i:=false;
  r.f.m:=true;
	PUSH(r.ps_r);
	PUSH(r.ip);
  r.ip:=read_word(vect_num*4);
  r.ps_r:=read_word(vect_num*4+2);
	self.prefetch_reset:=true;
end;

procedure cpu_nec.run(maximo:single);
var
  instruccion:byte;
begin
self.contador:=0;
while self.contador<maximo do begin
  //IRQ's
  if ((self.irq_pending<>0) and not(self.no_interrupt)) then begin
    if (self.irq_pending and NMI_IRQ)<>0 then begin
      nec_interrupt(NEC_NMI_VECTOR);
      self.irq_pending:=self.irq_pending and not(NMI_IRQ);
      self.nmi_state:=CLEAR_LINE;
      self.contador:=self.contador+9;
    end else if (self.r.f.I and (self.irq_pending<>0)) then begin
                nec_interrupt(self.vect_req);
                self.irq_pending:=self.irq_pending and not(INT_IRQ);
                self.contador:=self.contador+14;
             end;
  end;
  self.no_interrupt:=false;
  {if ((((r.ps_r shl 4)+r.ip)=$eecf5) and (self.numero_cpu=0)) then begin
      r.ip:=0;
      r.ip:=$f5;
  end;}
  self.r.old_pc:=self.r.ip;
  self.opcode:=true;
  instruccion:=self.fetch;
  self.opcode:=false;
  prev_icount:=self.contador;
  self.ejecuta_instruccion(instruccion);
  timers.update(self.contador-prev_icount,self.numero_cpu);
  if @self.despues_instruccion<>nil then self.despues_instruccion(self.contador-prev_icount);
  self.do_prefetch(prev_icount);
end; //del while
end;

end.
