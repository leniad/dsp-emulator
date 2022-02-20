unit nz80;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     cpu_misc,z80daisy,timer_engine,dialogs,vars_hide,main_engine;

const
    paridad:array [0..255] of boolean=(
        True,False,False,True,False,True,True,False,False,True,True,
        False,True,False,False,True,False,True,True,False,True,False,
        False,True,True,False,False,True,False,True,True,False,False,
        True,True,False,True,False,False,True,True,False,False,True,
        False,True,True,False,True,False,False,True,False,True,True,
        False,False,True,True,False,True,False,False,True,False,True,
        True,False,True,False,False,True,True,False,False,True,False,
        True,True,False,True,False,False,True,False,True,True,False,
        False,True,True,False,True,False,False,True,True,False,False,
        True,False,True,True,False,False,True,True,False,True,False,
        False,True,False,True,True,False,True,False,False,True,True,
        False,False,True,False,True,True,False,False,True,True,False,
        True,False,False,True,True,False,False,True,False,True,True,
        False,True,False,False,True,False,True,True,False,False,True,
        True,False,True,False,False,True,True,False,False,True,False,
        True,True,False,False,True,True,False,True,False,False,True,
        False,True,True,False,True,False,False,True,True,False,False,
        True,False,True,True,False,True,False,False,True,False,True,
        True,False,False,True,True,False,True,False,False,True,False,
        True,True,False,True,False,False,True,True,False,False,True,
        False,True,True,False,False,True,True,False,True,False,False,
        True,True,False,False,True,False,True,True,False,True,False,
        False,True,False,True,True,False,False,True,True,False,True,
        False,False,True);

type
  band_z80 = record
     c,n,p_v,bit3,h,bit5,z,s:boolean;
  end;
  tdespues_instruccion=procedure (estados_t:word);
  type_raised=function:byte;
  nreg_z80=packed record
        ppc,pc,sp:word;
        bc,de,hl:parejas;
        bc2,de2,hl2:parejas;
        wz:word;
        ix,iy:parejas;
        iff1,iff2,halt_opcode:boolean;
        a,a2,i,r:byte;
        f,f2:band_z80;
        im:byte;
  end;
  npreg_z80=^nreg_z80;
  cpu_z80=class(cpu_class)
          constructor create(clock:dword;frames_div:single);
          destructor free;
        public
          daisy:boolean;
          im2_lo,im0:byte;
          procedure reset;
          procedure run(maximo:single);
          //procedure change_timmings(z80t_set,z80t_cb_set,z80t_dd_set,z80t_ddcb_set,z80t_ed_set,z80t_ex_set:pbyte);
          procedure change_io_calls(in_port:tgetbyte;out_port:tputbyte);
          procedure change_misc_calls(despues_instruccion:tdespues_instruccion;raised_z80:type_raised);
          function get_safe_pc:word;
          function get_internal_r:npreg_z80;
          procedure set_internal_r(r:npreg_z80);
          function save_snapshot(data:pbyte):word;
          procedure load_snapshot(data:pbyte);
        protected
          after_ei:boolean;
          r:npreg_z80;
          in_port:tgetbyte;
          out_port:tputbyte;
          //pila
          procedure push_sp(reg:word);
          function pop_sp:word;
          //opcodes
          procedure and_a(valor:byte);
          procedure or_a(valor:byte);
          procedure xor_a(valor:byte);
          procedure cp_a(valor:byte);
          procedure sra_8(reg:pbyte);
          procedure sla_8(reg:pbyte);
          procedure sll_8(reg:pbyte);
          procedure srl_8(reg:pbyte);
          procedure rlc_8(reg:pbyte);
          procedure rr_8(reg:pbyte);
          procedure rrc_8(reg:pbyte);
          procedure rl_8(reg:pbyte);
          function dec_8(valor:byte):byte;
          function inc_8(valor:byte):byte;
          procedure add_8(valor:byte);
          procedure adc_8(valor:byte);
          procedure sub_8(valor:byte);
          procedure sbc_8(valor:byte);
          procedure bit_8(bit,valor:byte);
          procedure bit_7(valor:byte);
          function add_16(valor1,valor2:word):word;
          function adc_hl(valor:word):word;
          function sbc_hl(valor:word):word;
        private
          raised_z80:type_raised;
          function call_nmi:byte;
          function call_irq:byte;
          //resto de opcodes
          function exec_cb:byte;
          function exec_dd_fd(tipo:boolean):byte;
          function exec_dd_cb(tipo:boolean):byte;
          function exec_ed:byte;
        end;

var
  z80_0,z80_1,z80_2:cpu_z80;

implementation
const
        z80t:array[0..255] of byte=(
      //0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
        4,10, 7, 6, 4, 4, 7, 4, 4,11, 7, 6, 4, 4, 7, 4,  //0                          *
        8,10, 7, 6, 4, 4, 7, 4,12,11, 7, 6, 4, 4, 7, 4,  //10
        7,10,16, 6, 4, 4, 7, 4, 7,11,16, 6, 4, 4, 7, 4,  //20
        7,10,13, 6,11,11,10, 4, 7,11,13, 6, 4, 4, 7, 4,  //30
        4, 4, 4, 4, 4, 4, 7, 4, 4, 4, 4, 4, 4, 4, 7, 4,  //40
        4, 4, 4, 4, 4, 4, 7, 4, 4, 4, 4, 4, 4, 4, 7, 4,  //50
        4, 4, 4, 4, 4, 4, 7, 4, 4, 4, 4, 4, 4, 4, 7, 4,  //60
        7, 7, 7, 7, 7, 7, 4, 7, 4, 4, 4, 4, 4, 4, 7, 4,  //70
        4, 4, 4, 4, 4, 4, 7, 4, 4, 4, 4, 4, 4, 4, 7, 4,  //80
        4, 4, 4, 4, 4, 4, 7, 4, 4, 4, 4, 4, 4, 4, 7, 4,  //90
        4, 4, 4, 4, 4, 4, 7, 4, 4, 4, 4, 4, 4, 4, 7, 4,  //A0
        4, 4, 4, 4, 4, 4, 7, 4, 4, 4, 4, 4, 4, 4, 7, 4,  //B0
        5,10,10,10,10,11, 7,11, 5,10,10, 0,10,17, 7,11,  //C0
        5,10,10,11,10,11, 7,11, 5, 4,10,11,10, 0, 7,11,  //D0
        5,10,10,19,10,11, 7,11, 5, 4,10, 4,10, 0, 7,11,  //E0
        5,10,10, 4,10,11, 7,11, 5, 6,10, 4,10, 0, 7,11); //F0

         z80t_cb:array[0..255] of byte=(
      //0 1 2 3 4 5  6 7 8 9 a b c d  e f
        8, 8, 8, 8, 8, 8,15, 8, 8, 8, 8, 8, 8, 8,15, 8,
        8, 8, 8, 8, 8, 8,15, 8, 8, 8, 8, 8, 8, 8,15, 8,
        8, 8, 8, 8, 8, 8,15, 8, 8, 8, 8, 8, 8, 8,15, 8,
        8, 8, 8, 8, 8, 8,15, 8, 8, 8, 8, 8, 8, 8,15, 8,
        8, 8, 8, 8, 8, 8,12, 8, 8, 8, 8, 8, 8, 8,12, 8,
        8, 8, 8, 8, 8, 8,12, 8, 8, 8, 8, 8, 8, 8,12, 8,
        8, 8, 8, 8, 8, 8,12, 8, 8, 8, 8, 8, 8, 8,12, 8,
        8, 8, 8, 8, 8, 8,12, 8, 8, 8, 8, 8, 8, 8,12, 8,
        8, 8, 8, 8, 8, 8,15, 8, 8, 8, 8, 8, 8, 8,15, 8,
        8, 8, 8, 8, 8, 8,15, 8, 8, 8, 8, 8, 8, 8,15, 8,
        8, 8, 8, 8, 8, 8,15, 8, 8, 8, 8, 8, 8, 8,15, 8,
        8, 8, 8, 8, 8, 8,15, 8, 8, 8, 8, 8, 8, 8,15, 8,
        8, 8, 8, 8, 8, 8,15, 8, 8, 8, 8, 8, 8, 8,15, 8,
        8, 8, 8, 8, 8, 8,15, 8, 8, 8, 8, 8, 8, 8,15, 8,
        8, 8, 8, 8, 8, 8,15, 8, 8, 8, 8, 8, 8, 8,15, 8,
        8, 8, 8, 8, 8, 8,15, 8, 8, 8, 8, 8, 8, 8,15, 8);

        z80t_dd:array[0..255] of byte=( //cb_xy
      //0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
        8,14,11,10, 8, 8,11, 8, 8,15,11,10, 8, 8,11, 8,
       12,14,11,10, 8, 8,11, 8,16,15,11,10, 8, 8,11, 8,
       11,14,20,10, 8, 8,11, 8,11,15,20,10, 8, 8,11, 8,
       11,14,17,10,23,23,19, 8,11,15,17,10, 8, 8,11, 8,
        8, 8, 8, 8, 8, 8,19, 8, 8, 8, 8, 8, 8, 8,19, 8,
        8, 8, 8, 8, 8, 8,19, 8, 8, 8, 8, 8, 8, 8,19, 8,
      	8, 8, 8, 8, 8, 8,19, 8, 8, 8, 8, 8, 8, 8,19, 8,
       19,19,19,19,19,19, 8,19, 8, 8, 8, 8, 8, 8,19, 8,
      	8, 8, 8, 8, 8, 8,19, 8, 8, 8, 8, 8, 8, 8,19, 8,
      	8, 8, 8, 8, 8, 8,19, 8, 8, 8, 8, 8, 8, 8,19, 8,
      	8, 8, 8, 8, 8, 8,19, 8, 8, 8, 8, 8, 8, 8,19, 8,
      	8, 8, 8, 8, 8, 8,19, 8, 8, 8, 8, 8, 8, 8,19, 8,
      	9,14,14,14,14,15,11,15, 9,14,14, 0,14,21,11,15,
      	9,14,14,15,14,15,11,15, 9, 8,14,15,14, 4,11,15,
      	9,14,14,23,14,15,11,15, 9, 8,14, 8,14, 4,11,15,
      	9,14,14, 8,14,15,11,15, 9,10,14, 8,14, 4,11,15);

        z80t_ddcb:array[0..255] of byte=(
      //0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
        23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,
        23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,
        23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,
        23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,
        20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,
        20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,
        20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,
        20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,
        23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,
        23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,
        23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,
        23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,
        23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,
        23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,
        23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,
        23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23);

        z80t_ed:array[0..255] of byte=(
      //0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
        8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,  //00
        8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,  //10
        8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,  //20
        8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,  //30
       12,12,15,20, 8,14, 8, 9,12,12,15,20, 8,14, 8, 9,  //40
       12,12,15,20, 8,14, 8, 9,12,12,15,20, 8,14, 8, 9,  //50
       12,12,15,20, 8,14, 8,18,12,12,15,20, 8,14, 8,18,
       12,12,15,20, 8,14, 8, 8,12,12,15,20, 8,14, 8, 8,  //70
        8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
        8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,  //90
       16,16,16,16, 8, 8, 8, 8,16,16,16,16, 8, 8, 8, 8,  //a0
       16,16,16,16, 8, 8, 8, 8,16,16,16,16, 8, 8, 8, 8,
        8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
        8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
        8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
        8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8); //F0

        z80t_ex:array[0..255] of byte=(
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	      5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // DJNZ
	      5, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, // JR NZ/JR Z
	      5, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, // JR NC/JR C
	      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	      5, 5, 5, 5, 0, 0, 0, 0, 5, 5, 5, 5, 0, 0, 0, 0, // LDIR/CPIR/INIR/OTIR LDDR/CPDR/INDR/OTDR
	      6, 0, 0, 0, 7, 0, 0, 2, 6, 0, 0, 0, 7, 0, 0, 2,
	      6, 0, 0, 0, 7, 0, 0, 2, 6, 0, 0, 0, 7, 0, 0, 2,
	      6, 0, 0, 0, 7, 0, 0, 2, 6, 0, 0, 0, 7, 0, 0, 2,
	      6, 0, 0, 0, 7, 0, 0, 2, 6, 0, 0, 0, 7, 0, 0, 2);


procedure cpu_z80.and_a(valor:byte);
begin
 r.a:=r.a and valor;
 r.f.s:=(r.a and $80)<>0;
 r.f.z:=(r.a=0);
 r.f.bit5:=(r.a and $20)<>0;
 r.f.h:=true;
 r.f.bit3:=(r.a and 8)<>0;
 r.f.p_v:=paridad[r.a];
 r.f.n:=false;
 r.f.c:=false;
end;

procedure cpu_z80.or_a(valor:byte);
begin
 r.a:=r.a or valor;
 r.f.s:=(r.a and $80)<>0;
 r.f.z:=(r.a=0);
 r.f.bit5:=(r.a and $20)<>0;
 r.f.h:=false;
 r.f.bit3:=(r.a and 8)<>0;
 r.f.p_v:=paridad[r.a];
 r.f.n:=false;
 r.f.c:=false;
end;

procedure cpu_z80.xor_a(valor:byte);
begin
 r.a:=r.a xor valor;
 r.f.s:=(r.a and $80)<>0;
 r.f.z:=(r.a=0);
 r.f.bit5:=(r.a and $20)<>0;
 r.f.h:= false;
 r.f.bit3:=(r.a and 8)<>0 ;
 r.f.p_v:=paridad[r.a];
 r.f.n:=false;
 r.f.c:=false;
end;

procedure cpu_z80.cp_a(valor:byte);
var
  temp:byte;
begin
 temp:=r.a-valor;
 r.f.s:=(temp and $80)<>0;
 r.f.z:=(temp=0);
 r.f.bit5:=(valor and $20)<>0;
 r.f.h:=(((r.a and $f)-(valor and $f)) and $10)<>0;
 r.f.bit3:=(valor and 8)<>0;
 r.f.p_v:=((r.a xor valor) and (r.a xor temp) and $80)<>0;
 r.f.n:=true;
 r.f.c:=(r.a-valor)<0;
end;

procedure cpu_z80.sra_8(reg:pbyte);
begin
 r.f.c:=(reg^ and $1)<>0;
 reg^:=(reg^ shr 1) or (reg^ and $80);
 r.f.h:=false;
 r.f.n:=false;
 r.f.p_v:=paridad[reg^];
 r.f.s:=(reg^ and $80)<>0;
 r.f.z:=(reg^=0);
 r.f.bit5:=(reg^ and $20)<>0;
 r.f.bit3:=(reg^ and 8)<>0;
end;

procedure cpu_z80.sla_8(reg:pbyte);
begin
 r.f.c:=(reg^ and $80)<>0;
 reg^:=reg^ shl 1;
 r.f.h:=false;
 r.f.n:=false;
 r.f.p_v:=paridad[reg^];
 r.f.s:=(reg^ and $80)<>0;
 r.f.z:=(reg^=0);
 r.f.bit5:=(reg^ and $20)<>0;
 r.f.bit3:=(reg^ and 8)<>0;
end;

procedure cpu_z80.sll_8(reg:pbyte);
begin
 r.f.c:=(reg^ and $80)<>0;
 reg^:=(reg^ shl 1) or 1;
 r.f.h:=false;
 r.f.n:=false;
 r.f.p_v:=paridad[reg^];
 r.f.s:=(reg^ and $80)<>0;
 r.f.z:=(reg^=0);
 r.f.bit5:=(reg^ and $20)<>0;
 r.f.bit3:=(reg^ and 8)<>0;
end;

procedure cpu_z80.srl_8(reg:pbyte);
begin
 r.f.h:=false;
 r.f.n:=false;
 r.f.c:=(reg^ and 1)<>0;
 reg^:=reg^ shr 1;
 r.f.bit5:=(reg^ and $20)<>0;
 r.f.bit3:=(reg^ and 8)<>0;
 r.f.p_v:=paridad[reg^];
 r.f.z:=(reg^=0);
 r.f.s:=(reg^ and $80)<>0;
end;

procedure cpu_z80.rlc_8(reg:pbyte);
begin
 r.f.c:=(reg^ and $80)<>0;
 reg^:=(reg^ shl 1) or byte(r.f.c);
 r.f.bit5:=(reg^ and $20)<>0;
 r.f.bit3:=(reg^ and 8)<>0;
 r.f.p_v:=paridad[reg^];
 r.f.h:=false;
 r.f.n:=false;
 r.f.z:=(reg^=0);
 r.f.s:=(reg^ and $80)<>0;
end;

procedure cpu_z80.rr_8(reg:pbyte);
begin
 r.f.n:=r.f.c;
 r.f.c:=(reg^ and 1)<>0;
 reg^:=(reg^ shr 1) or (byte(r.f.n) shl 7);
 r.f.h:=false;
 r.f.n:=false;
 r.f.p_v:=paridad[reg^];
 r.f.s:=(reg^ and $80)<>0;
 r.f.z:=(reg^=0);
 r.f.bit5:=(reg^ and $20)<>0;
 r.f.bit3:=(reg^ and 8)<>0;
end;

procedure cpu_z80.rrc_8(reg:pbyte);
begin
 r.f.c:=(reg^ and $1)<>0;
 reg^:=(reg^ shr 1) or (byte(r.f.c) shl 7);
 r.f.bit5:=(reg^ and $20)<>0;
 r.f.bit3:=(reg^ and 8)<>0;
 r.f.p_v:=paridad[reg^];
 r.f.h:=false;
 r.f.n:=false;
 r.f.z:=(reg^=0);
 r.f.s:=(reg^ and $80)<>0;
end;

procedure cpu_z80.rl_8(reg:pbyte);
begin
 r.f.n:=r.f.c;
 r.f.c:=(reg^ and $80)<>0;
 reg^:=(reg^ shl 1) or byte(r.f.n);
 r.f.h:=false;
 r.f.n:=false;
 r.f.p_v:=paridad[reg^];
 r.f.s:=(reg^ and $80)<>0;
 r.f.z:=(reg^=0);
 r.f.bit5:=(reg^ and $20)<>0;
 r.f.bit3:=(reg^ and 8)<>0;
end;

function cpu_z80.dec_8(valor:byte):byte;
var
  tempb:byte;
begin
 r.f.h:=(((valor and $f)-1) and $10)<>0;
 r.f.p_v:=(valor=$80);
 tempb:=valor-1;
 r.f.s:=(tempb and $80)<>0;
 r.f.z:=(tempb=0);
 r.f.bit5:=(tempb and $20)<>0;
 r.f.bit3:=(tempb and 8)<>0;
 r.f.n:=true;
 dec_8:=tempb;
end;

function cpu_z80.inc_8(valor:byte):byte;
var
  tempb:byte;
begin
 r.f.h:=(((valor and $f)+1) and $10)<>0;
 r.f.p_v:=(valor=$7f);
 tempb:=valor+1;
 r.f.s:=(tempb and $80)<>0;
 r.f.z:=(tempb=0);
 r.f.bit5:=(tempb and $20)<>0;
 r.f.bit3:=(tempb and 8)<>0;
 r.f.n:=false;
 inc_8:=tempb;
end;

procedure cpu_z80.add_8(valor:byte);
var
  temp:byte;
begin
 temp:=r.a+valor;
 r.f.p_v:=(((r.a Xor (not valor)) and $ffff) and (r.a xor temp) and $80)<>0;
 r.f.h :=(((r.a and $f)+(valor and $f)) and $10) <> 0;
 r.f.s:= (temp and $80)<>0;
 r.f.z:=(temp=0);
 r.f.bit5:=(temp and $20)<>0;
 r.f.bit3:=(temp and 8)<>0;
 r.f.n:=false;
 r.f.c:=((r.a+valor) and $100)<>0;
 r.a:=temp;
end;

procedure cpu_z80.adc_8(valor:byte);
var
  carry,temp:byte;
begin
 carry:=byte(r.f.c);
 temp:=r.a+valor+carry;
 r.f.p_v:=(((r.a xor (not valor)) and $ffff) and ((r.a xor temp) and $80))<>0;
 r.f.h:=(((r.a and $f)+(valor And $f)+carry) and $10)<>0;
 r.f.s:= (temp and $80)<>0;
 r.f.z:=(temp=0);
 r.f.bit5:=(temp and $20)<>0;
 r.f.bit3:=(temp and 8)<>0;
 r.f.n:=false;
 r.f.c:=((r.a+valor+carry) and $100)<>0;
 r.a:=temp;
end;

procedure cpu_z80.sub_8(valor:byte);
var
  temp:byte;
  temp2:word;
begin
 temp2:=r.a-valor;
 temp:=temp2 and $ff;
 r.f.h:=(((r.a and $0f)-(valor and $0f)) and $10)<>0;
 r.f.p_v:=(((r.a xor valor) and (r.a xor temp)) and $80)<>0;
 r.f.s:= (temp and $80)<>0;
 r.f.z:=(temp=0);
 r.f.bit5:=(temp and $20)<>0;
 r.f.bit3:=(temp and 8)<>0;
 r.f.n:=true;
 r.f.c:=(temp2 and $100)<>0;
 r.a:=temp;
end;

procedure cpu_z80.sbc_8(valor:byte);
var
  carry,temp:byte;
begin
 carry:=byte(r.f.c);
 temp:=r.a-valor-carry;
 r.f.h:=(((r.a and $0f)-(valor and $0f)-carry) and $10)<>0;
 r.f.p_v:=(((r.a xor valor) and (r.a xor temp)) and $80)<>0;
 r.f.s:= (temp and $80)<>0;
 r.f.z:=(temp=0);
 r.f.bit5:=(temp and $20)<>0;
 r.f.bit3:=(temp and 8)<>0;
 r.f.n:=true;
 r.f.c:=((r.a-valor-carry) and $100)<>0;
 r.a:=temp;
end;

procedure cpu_z80.bit_8(bit,valor:byte);
begin
r.f.h:=true;
r.f.n:=false;
r.f.s:=false;
r.f.z:=not((valor and (1 shl bit))<>0);
r.f.p_v:=r.f.z;
r.f.bit5:=(valor and $20)<>0;
r.f.bit3:=(valor and $8)<>0;
end;

procedure cpu_z80.bit_7(valor:byte);
begin
r.f.z:=not((valor and $80)<>0);
r.f.h:=true;
r.f.n:=false;
r.f.p_v:=r.f.z;
r.f.s:=(valor and $80)<>0;
r.f.bit5:=(valor and $20)<>0;
r.f.bit3:=(valor and $8)<>0;
end;

function cpu_z80.add_16(valor1,valor2:word):word;
var
  templ:dword;
begin
  templ:=valor1+valor2;
  r.wz:=valor1+1;
  r.f.bit3:=(templ and $800)<>0;
  r.f.bit5:=(templ and $2000)<>0;
  r.f.c:=(templ and $10000)<>0;
  r.f.h:=(((valor1 and $fff)+(valor2 and $fff)) and $1000)<>0;
  r.f.n:=False;
  add_16:=templ;
end;

function cpu_z80.adc_hl(valor:word):word;
var
  templ:dword;
  carry:byte;
begin
 carry:=byte(r.f.c);
 templ:=r.hl.w+valor+carry;
 r.wz:=r.hl.w+1;
 r.f.h:=((r.hl.w xor templ xor valor) and $1000)<>0;
 r.f.n:=false;
 r.f.c:=(templ and $10000)<>0;
 r.f.s:=(templ and $8000)<>0;
 r.f.bit5:=(templ and $2000)<>0;
 r.f.bit3:=(templ and $800)<>0;
 r.f.z:=((templ and $ffff)=0);
 r.f.p_v:=((valor xor r.hl.w xor $8000) and (valor xor templ) and $8000)<>0;
 adc_hl:=templ;
end;

function cpu_z80.sbc_hl(valor:word):word;
var
  carry:byte;
  templ:dword;
begin
  carry:=byte(r.f.c);
  r.wz:=r.hl.w+1;
  templ:=r.hl.w-valor-carry;
  r.f.h:=((r.hl.w xor templ xor valor) and $1000)<>0;
  r.f.n:=true;
  r.f.s:=(templ and $8000)<>0;
  r.f.bit3:=(templ and $800)<>0;
  r.f.bit5:=(templ and $2000)<>0;
  r.f.z:=((templ and $ffff)=0);
  r.f.c:=(templ and $10000)<>0;
  r.f.P_V:=((valor xor r.hl.w) and (r.hl.w xor templ) and $8000)<>0;
  sbc_hl:=templ;
end;

constructor cpu_z80.create(clock:dword;frames_div:single);
begin
getmem(self.r,sizeof(nreg_z80));
fillchar(self.r^,sizeof(nreg_z80),0);
self.numero_cpu:=cpu_main_init(clock);
self.clock:=clock;
self.tframes:=(clock/frames_div)/llamadas_maquina.fps_max;
self.in_port:=nil;
self.out_port:=nil;
self.despues_instruccion:=nil;
self.raised_z80:=nil;
end;

destructor cpu_z80.free;
begin
freemem(self.r);
end;

procedure cpu_z80.reset;
begin
  r.sp:=$ffff;
  r.pc:=0;
  r.a:=0;r.bc.w:=0;r.de.w:=0;r.hl.w:=0;
  r.a2:=0;r.bc2.w:=0;r.de2.w:=0;r.hl2.w:=0;
  r.wz:=0;
  r.ix.w:=$ffff;
  r.iy.w:=$ffff;
  r.iff1:=false;
  r.iff2:=false;
  r.i:=0;
  r.r:=0;
  r.im:=0;
  r.f.c:=false;r.f.n:=false;r.f.p_v:=false;r.f.bit3:=false;r.f.h:=false;r.f.bit5:=false;r.f.z:=true;r.f.s:=false;
  r.f2.c:=false;r.f2.n:=false;r.f2.p_v:=false;r.f2.bit3:=false;r.f2.h:=false;r.f2.bit5:=false;r.f2.z:=false;r.f2.s:=false;
  self.change_nmi(CLEAR_LINE);
  self.pedir_irq:=CLEAR_LINE;
  self.change_reset(CLEAR_LINE);
  self.change_halt(CLEAR_LINE);
  self.r.halt_opcode:=false;
  self.im2_lo:=$FF;
  self.im0:=$FF;
  self.opcode:=false;
  self.after_ei:=false;
end;

function cpu_z80.get_safe_pc:word;
begin
  get_safe_pc:=self.r.ppc;
end;

function cpu_z80.get_internal_r:npreg_z80;
begin
  get_internal_r:=self.r;
end;

procedure cpu_z80.set_internal_r(r:npreg_z80);
begin
  copymemory(self.r,r,sizeof(nreg_z80));
end;

function cpu_z80.save_snapshot(data:pbyte):word;
var
  temp:pbyte;
  buffer:array[0..11] of byte;
  size:word;
begin
  temp:=data;
  copymemory(temp,self.r,sizeof(nreg_z80));
  inc(temp,sizeof(nreg_z80));size:=sizeof(nreg_z80);
  buffer[0]:=byte(self.r.halt_opcode);
  buffer[1]:=byte(self.daisy);
  buffer[2]:=byte(self.after_ei);
  buffer[3]:=self.pedir_irq;
  buffer[4]:=self.pedir_nmi;
  buffer[5]:=self.nmi_state;
  copymemory(@buffer[6],@self.contador,4);
  buffer[10]:=self.im2_lo;
  buffer[11]:=self.im0;
  copymemory(temp,@buffer[0],12);
  save_snapshot:=size+12;
end;

procedure cpu_z80.load_snapshot(data:pbyte);
var
  temp:pbyte;
begin
  temp:=data;
  copymemory(self.r,temp,sizeof(nreg_z80));
  inc(temp,sizeof(nreg_z80));
  self.r.halt_opcode:=temp^<>0;inc(temp);
  self.daisy:=(temp^<>0);inc(temp);
  self.after_ei:=(temp^<>0);inc(temp);
  self.pedir_irq:=temp^;inc(temp);
  self.pedir_nmi:=temp^;inc(temp);
  self.nmi_state:=temp^;inc(temp);
  copymemory(@self.contador,temp,4);inc(temp,4);
  self.im2_lo:=temp^;inc(temp);
  self.im0:=temp^;
end;

procedure cpu_z80.change_io_calls(in_port:tgetbyte;out_port:tputbyte);
begin
  self.in_port:=in_port;
  self.out_port:=out_port;
end;

procedure cpu_z80.change_misc_calls(despues_instruccion:tdespues_instruccion;raised_z80:type_raised);
begin
  self.despues_instruccion:=despues_instruccion;
  self.raised_z80:=raised_z80;
end;

function cpu_z80.call_nmi:byte;
begin
call_nmi:=0;
self.r.halt_opcode:=false;
if self.nmi_state<>CLEAR_LINE then exit;
r.r:=((r.r+1) and $7f) or (r.r and $80);
self.push_sp(r.pc);
r.IFF1:=false;
r.pc:=$66;
r.wz:=$66;
call_nmi:=11;
if (self.pedir_nmi=PULSE_LINE) then self.pedir_nmi:=CLEAR_LINE;
if (self.pedir_nmi=ASSERT_LINE) then self.nmi_state:=ASSERT_LINE;
end;

function cpu_z80.call_irq:byte;
var
  posicion:word;
  estados_t:byte;
begin
call_irq:=0;
if not(r.iff1) then exit; //se esta ejecutando otra
self.r.halt_opcode:=false;
r.r:=((r.r+1) and $7f) or (r.r and $80);
if @self.raised_z80<>nil then estados_t:=self.raised_z80
  else estados_t:=0;
if self.pedir_irq=HOLD_LINE then self.pedir_irq:=CLEAR_LINE;
push_sp(r.pc);
r.IFF2:=false;
r.IFF1:=false;
Case r.im of
        0:begin
            if self.daisy then MessageDlg('Mierda!!! Daisy chain en IM0!!', mtInformation,[mbOk], 0);
            r.pc:=self.im0 and $38;
            estados_t:=estados_t+12;
          end;
        1:begin
            r.pc:=$38;
            estados_t:=estados_t+13;
        end;
        2:begin
            if self.daisy then posicion:=z80daisy_ack
              else posicion:=self.im2_lo;
            posicion:=posicion or (r.i shl 8);
            r.pc:=self.getbyte(posicion)+(self.getbyte(posicion+1) shl 8);
            estados_t:=estados_t+19;
        end;
end;
r.wz:=r.pc;
call_irq:=estados_t;
end;

procedure cpu_z80.push_sp(reg:word);
begin
r.sp:=r.sp-2;
self.putbyte(r.sp+1,reg shr 8);
self.putbyte(r.sp,reg and $ff);
end;

function cpu_z80.pop_sp:word;
var
  temp:word;
begin
temp:=self.getbyte(r.sp);
temp:=temp+(self.getbyte(r.sp+1) shl 8);
r.sp:=r.sp+2;
pop_sp:=temp;
end;

procedure cpu_z80.run(maximo:single);
var
 instruccion,temp:byte;
 posicion:parejas;
 ban_temp
 :band_z80;
 irq_temp:boolean;
 cantidad_t:word;
 pestados:integer;
begin
irq_temp:=false;
self.contador:=0;
while self.contador<maximo do begin
if self.pedir_halt<>CLEAR_LINE then begin
  self.contador:=trunc(maximo);
  exit;
end;
pestados:=self.contador;
if self.pedir_reset<>CLEAR_LINE then begin
  temp:=self.pedir_reset;
  self.reset;
  if temp=ASSERT_LINE then begin
    self.pedir_reset:=ASSERT_LINE;
    self.contador:=trunc(maximo);
    exit;
  end;
end;
r.ppc:=r.pc;
self.estados_demas:=0;
if not(self.after_ei) then begin
  if self.pedir_nmi<>CLEAR_LINE then self.estados_demas:=self.call_nmi
  else begin
      if self.daisy then irq_temp:=z80daisy_state;
      if (irq_temp or (self.pedir_irq<>CLEAR_LINE)) then self.estados_demas:=self.call_irq;
  end;
end;
self.after_ei:=false;
if self.r.halt_opcode then r.pc:=r.pc-1;
self.opcode:=true;
instruccion:=self.getbyte(r.pc);
self.opcode:=false;
r.pc:=r.pc+1;
r.r:=((r.r+1) and $7f) or (r.r and $80);
case instruccion of
        $00,$40,$49,$52,$5b,$64,$6d,$7f:{nop};
        $01:begin {ld BC,nn}
                r.bc.l:=self.getbyte(r.pc);
                r.bc.h:=self.getbyte(r.pc+1);
                r.pc:=r.pc+2;
            end;
        $02:begin //ld (BC),A
              self.putbyte(r.bc.w,r.a);
              r.wz:=((r.bc.w+1) and $ff) or (r.a shl 8);
            end;
        $03:r.bc.w:=r.bc.w+1;  {inc BC}
        $04:r.bc.h:=inc_8(r.bc.h); //inc B
        $05:r.bc.h:=dec_8(r.bc.h); //dec B
        $06:begin {ld B,n}
                r.bc.h:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
            end;
        $07:begin   //rlca
               r.f.c:=(r.a and $80)<>0;
               r.a:=(r.a shl 1) or byte(r.f.c);
               r.f.bit5:=(r.a and $20)<>0;
               r.f.bit3:=(r.a and 8)<>0;
               r.f.h:=false;
               r.f.n:=false;
            end;
        $08:begin { ex AF,AF'}
                ban_temp:=r.f;
                r.f:=r.f2;
                r.f2:=ban_temp;
                temp:=r.a;
                r.a:=r.a2;
                r.a2:=temp;
            end;
        $09:r.hl.w:=add_16(r.hl.w,r.bc.w); //add HL,BC
        $0a:begin //ld A,(BC)
              r.a:=self.getbyte(r.bc.w);
              r.wz:=r.bc.w+1;
            end;
        $0b:r.bc.w:=r.bc.w-1;  {dec BC}
        $0c:r.bc.l:=inc_8(r.bc.l); //inc C
        $0d:r.bc.l:=dec_8(r.bc.l); //dec C
        $0e:begin {ld C,n}
                r.bc.l:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
            end;
        $0f:begin   //rrca
                r.f.c:=(r.a and 1)<>0;
                r.a:=(r.a shr 1) or (byte(r.f.c) shl 7);
                r.f.bit5:=(r.a and $20) <>0;
                r.f.bit3:=(r.a and 8)<>0;
                r.f.h:=false;
                r.f.n:=false;
            end;
        $10:begin //dnjz (PC+e)
                r.bc.h:=r.bc.h-1;
                r.pc:=r.pc+1;
                if r.bc.h<>0 then begin
                        temp:=self.getbyte(r.pc-1);
                        r.pc:=r.pc+shortint(temp);
                        self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
                        r.wz:=r.pc;
                end;
            end;
        $11:begin {ld DE,nn}
                r.de.l:=self.getbyte(r.pc);
                r.de.h:=self.getbyte(r.pc+1);
                r.pc:=r.pc+2;
            end;
        $12:begin //ld (DE),A
              self.putbyte(r.de.w,r.a);
              r.wz:=((r.de.w+1) and $ff) or (r.a shl 8);
            end;
        $13:r.de.w:=r.de.w+1;  {inc DE}
        $14:r.de.h:=inc_8(r.de.h); //inc D
        $15:r.de.h:=dec_8(r.de.h); //dec D
        $16:begin {ld D,n}
                r.de.h:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
            end;
        $17:begin  //rla
                r.f.h:=(r.a and $80)<>0;
                r.a:=(r.a shl 1) or byte(r.f.c);
                r.f.bit5:=(r.a and $20)<>0;
                r.f.bit3:=(r.a and 8)<>0;
                r.f.c:=r.f.h;
                r.f.h:=false;
                r.f.n:=false;
            end;
        $18:begin  //jr e
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                r.pc:=r.pc+shortint(temp);
                r.wz:=r.pc;
            end;
        $19:r.hl.w:=add_16(r.hl.w,r.de.w); //add HL,DE
        $1a:begin //ld A,(DE)
                r.a:=self.getbyte(r.de.w);
                r.wz:=r.de.w+1;
            end;
        $1b:r.de.w:=r.de.w-1;  {dec DE}
        $1c:r.de.l:=inc_8(r.de.l); //inc E
        $1d:r.de.l:=dec_8(r.de.l); //dec E
        $1e:begin {ld E,n}
                r.de.l:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
            end;
        $1f:begin //rra
                r.f.h:=(r.a and 1)<>0;
                r.a:=(r.a shr 1) or (byte(r.f.c) shl 7);
                r.f.n:=false;
                r.f.c:=r.f.h;
                r.f.h:=false;
                r.f.bit5:=(r.a and $20)<>0;
                r.f.bit3:=(r.a and 8)<>0;
            end;
        $20:begin  //jr NZ,(PC+e)
                r.pc:=r.pc+1;
                if not(r.f.z) then begin
                        temp:=self.getbyte(r.pc-1);
                        r.pc:=r.pc+shortint(temp);
                        self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
                        r.wz:=r.pc;
                end;
            end;
        $21:begin {ld HL,nn}
                r.hl.l:=self.getbyte(r.pc);
                r.hl.h:=self.getbyte(r.pc+1);
                r.pc:=r.pc+2;
            end;
        $22:begin {ld (nn),HL}
                posicion.l:=self.getbyte(r.pc);
                posicion.h:=self.getbyte(r.pc+1);
                r.pc:=r.pc+2;
                self.putbyte(posicion.w,r.hl.l);
                self.putbyte(posicion.w+1,r.hl.h);
                r.wz:=posicion.w+1;
            end;
        $23:r.hl.w:=r.hl.w+1;  {inc HL}
        $24:r.hl.h:=inc_8(r.hl.h); //inc H
        $25:r.hl.h:=dec_8(r.hl.h); //dec H
        $26:begin {ld H,n}
                r.hl.h:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
            end;
        $27:begin   {daa}
                temp:=0;
                if (r.f.h or ((r.a and $0f)>9)) then temp:=temp or 6;
                if (r.f.c or (r.a>$9f)) then temp:=temp or $60;
                if ((r.a>$8f) and ((r.a and $0F) > 9)) then temp:=temp or $60;
                if (r.a>$99) then r.f.c:=True;
                if r.f.n then begin
                        r.f.h:=(((r.a and $0f)-(temp and $0f)) and $10)<>0;
                        r.a:=r.a-temp;
                end else begin
                        r.f.h:=(((r.a and $0f)+(temp and $0f)) and $10)<>0;
                        r.a:=r.a+temp;
                end;
                r.f.p_v:=paridad[r.a];
                r.f.s:=(r.a and $80) <>0;
                r.f.z:=(r.a=0);
                r.f.bit5:=(r.a and $20)<>0;
                r.f.bit3:=(r.a and 8)<>0;
            end;
        $28:begin  //jr Z,(PC+e)
                r.pc:=r.pc+1;
                if r.f.z then begin
                        temp:=self.getbyte(r.pc-1);
                        r.pc:=r.pc+shortint(temp);
                        self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
                        r.wz:=r.pc;
                end;
            end;
        $29:r.hl.w:=add_16(r.hl.w,r.hl.w); //add HL,HL
        $2a:begin  {ld HL,(nn)}
                posicion.h:=self.getbyte(r.pc+1);
                posicion.l:=self.getbyte(r.pc);
                r.pc:=r.pc+2;
                r.hl.l:=self.getbyte(posicion.w);
                r.hl.h:=self.getbyte(posicion.w+1);
                r.wz:=posicion.w+1;
            end;
        $2b:r.hl.w:=r.hl.w-1;  {dec HL}
        $2c:r.hl.l:=inc_8(r.hl.l); //inc L
        $2d:r.hl.l:=dec_8(r.hl.l); //dec L
        $2e:begin {ld L,n}
                r.hl.l:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
            end;
        $2f:begin {cpl}
                r.a:=r.a xor $FF;
                r.f.bit5:=(r.a and $20)<>0;
                r.f.bit3:=(r.a and 8)<>0;
                r.f.h:=true;
                r.f.n:=true;
            end;
        $30:begin  //jr NC,(PC+e)
                r.pc:=r.pc+1;
                if not(r.f.c) then begin
                        temp:=self.getbyte(r.pc-1);
                        r.pc:=r.pc+shortint(temp);
                        self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
                        r.wz:=r.pc;
                end;
            end;
        $31:begin {ld SP,nn}
                r.sp:=self.getbyte(r.pc)+(self.getbyte(r.pc+1) shl 8);
                r.pc:=r.pc+2;
            end;
        $32:begin {ld (nn),A}
                posicion.h:=self.getbyte(r.pc+1);
                posicion.l:=self.getbyte(r.pc);
                r.pc:=r.pc+2;
                self.putbyte(posicion.w,r.a);
                r.wz:=((posicion.w+1) and $ff) or (r.a shl 8);
            end;
        $33:r.sp:=r.sp+1;  {inc SP}
        $34:begin  //inc (HL)
                temp:=inc_8(self.getbyte(r.hl.w));
                self.putbyte(r.hl.w,temp);
            end;
        $35:begin  //dec (HL)
                temp:=dec_8(self.getbyte(r.hl.w));
                self.putbyte(r.hl.w,temp);
            end;
        $36:begin {ld (HL),n}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                self.putbyte(r.hl.w,temp);
            end;
        $37:begin  {scf}
                r.f.bit5:=(r.a and $20)<>0;
                r.f.bit3:=(r.a and 8)<>0;
                r.f.c:=true;
                r.f.h:=false;
                r.f.n:=false;
            end;
        $38:begin  //jr C,(PC+e)
                r.pc:=r.pc+1;
                if r.f.c then begin
                        temp:=self.getbyte(r.pc-1);
                        r.pc:=r.pc+shortint(temp);
                        self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
                        r.wz:=r.pc;
                end;
            end;
        $39:r.hl.w:=add_16(r.hl.w,r.sp); //add HL,SP
        $3a:begin {ld A,(nn)}
                posicion.h:=self.getbyte(r.pc+1);
                posicion.l:=self.getbyte(r.pc);
                r.pc:=r.pc+2;
                r.a:=self.getbyte(posicion.w);
                r.wz:=posicion.w+1;
            end;
        $3b:r.sp:=r.sp-1;  {dec SP}
        $3c:r.a:=inc_8(r.a); //inc A
        $3d:r.a:=dec_8(r.a); //dec A
        $3e:begin {ld A,n}
                r.a:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
            end;
        $3f:begin   {ccf}
                r.f.bit5:=(r.a and $20)<>0;
                r.f.bit3:=(r.a and 8)<>0;
                r.f.h:=r.f.c;
                r.f.n:=false;
                r.f.c:=not(r.f.c);
            end;
        {'$'40: igual que el nop ld B,B}
        $41:r.bc.h:=r.bc.l; {ld B,C}
        $42:r.bc.h:=r.de.h; {ld B,D}
        $43:r.bc.h:=r.de.l; {ld B,E}
        $44:r.bc.h:=r.hl.h; {ld B,H}
        $45:r.bc.h:=r.hl.l; {ld B,L}
        $46:r.bc.h:=self.getbyte(r.hl.w); {ld B,(HL)}
        $47:r.bc.h:=r.a; {ld B,A}
        $48:r.bc.l:=r.bc.h; {ld C,B}
        {'$'49: igual que el nop ld C,C}
        $4a:r.bc.l:=r.de.h; {ld C,D}
        $4b:r.bc.l:=r.de.l; {ld C,E}
        $4c:r.bc.l:=r.hl.h; {ld C,H}
        $4d:r.bc.l:=r.hl.l; {ld C,L}
        $4e:r.bc.l:=self.getbyte(r.hl.w); {ld C,(HL)}
        $4f:r.bc.l:=r.a; {ld C,A}
        $50:r.de.h:=r.bc.h; {ld D,B}
        $51:r.de.h:=r.bc.l; {ld D,C}
        {'$'52 igual que el nop ld D,D}
        $53:r.de.h:=r.de.l; {ld D,E}
        $54:r.de.h:=r.hl.h; {ld D,H}
        $55:r.de.h:=r.hl.l; {ld D,L}
        $56:r.de.h:=self.getbyte(r.hl.w); {ld D,(HL)}
        $57:r.de.h:=r.a; {ld D,A}
        $58:r.de.l:=r.bc.h; {ld E,B}
        $59:r.de.l:=r.bc.l; {ld E,C}
        $5a:r.de.l:=r.de.h; {ld E,D}
        {'$'5b igual que el nop ld E,E}
        $5c:r.de.l:=r.hl.h; {ld E,H}
        $5d:r.de.l:=r.hl.l; {ld E,L}
        $5e:r.de.l:=self.getbyte(r.hl.w); {ld E,(HL)}
        $5f:r.de.l:=r.a; {ld E,A}
        $60:r.hl.h:=r.bc.h; {ld H,B}
        $61:r.hl.h:=r.bc.l; {ld H,C}
        $62:r.hl.h:=r.de.h; {ld H,D}
        $63:r.hl.h:=r.de.l; {ld H,E}
        {'$'64: igual que el nop ld H,H}
        $65:r.hl.h:=r.hl.l; {ld H,L}
        $66:r.hl.h:=self.getbyte(r.hl.w); {ld H,(HL)}
        $67:r.hl.h:=r.a; {ld H,A}
        $68:r.hl.l:=r.bc.h; {ld L,B}
        $69:r.hl.l:=r.bc.l; {ld L,C}
        $6a:r.hl.l:=r.de.h; {ld L,D}
        $6b:r.hl.l:=r.de.l; {ld L,E}
        $6c:r.hl.l:=r.hl.h; {ld L,H}
        {'$'6d: igual que el nop ld L,L}
        $6e:r.hl.l:=self.getbyte(r.hl.w); {ld L,(HL)}
        $6f:r.hl.l:=r.a; {ld L,A}
        $70:self.putbyte(r.hl.w,r.bc.h); {ld (HL),B}
        $71:self.putbyte(r.hl.w,r.bc.l); {ld (HL),C}
        $72:self.putbyte(r.hl.w,r.de.h); {ld (HL),D}
        $73:self.putbyte(r.hl.w,r.de.l); {ld (HL),E}
        $74:self.putbyte(r.hl.w,r.hl.h); {ld (HL),H}
        $75:self.putbyte(r.hl.w,r.hl.l); {ld (HL),L}
        $76:self.r.halt_opcode:=true; //halt
        $77:self.putbyte(r.hl.w,r.a); {ld (HL),A}
        $78:r.a:=r.bc.h; {ld A,B}
        $79:r.a:=r.bc.l; {ld A,C}
        $7a:r.a:=r.de.h; {ld A,D}
        $7b:r.a:=r.de.l; {ld A,E}
        $7c:r.a:=r.hl.h; {ld A,H}
        $7d:r.a:=r.hl.l; {ld A,L}
        $7e:r.a:=self.getbyte(r.hl.w); {ld A,(HL)}
        {'$'7f: igual que el nop ld A,A}
        $80:add_8(r.bc.h); {add A,B}
        $81:add_8(r.bc.l); {add A,C}
        $82:add_8(r.de.h); {add A,D}
        $83:add_8(r.de.l); {add A,E}
        $84:add_8(r.hl.h); {add A,H}
        $85:add_8(r.hl.l); {add A,L}
        $86:add_8(self.getbyte(r.hl.w));  {add A,(HL)}
        $87:add_8(r.a); {add A,A}
        $88:adc_8(r.bc.h); {adc A,B}
        $89:adc_8(r.bc.l); {adc A,C}
        $8a:adc_8(r.de.h); {adc A,D}
        $8b:adc_8(r.de.l); {adc A,E}
        $8c:adc_8(r.hl.h); {adc A,H}
        $8d:adc_8(r.hl.l); {adc A,L}
        $8e:adc_8(self.getbyte(r.hl.w)); {adc A,(HL)}
        $8f:adc_8(r.a); {adc A,A}
        $90:sub_8(r.bc.h); {sub B}
        $91:sub_8(r.bc.l); {sub C}
        $92:sub_8(r.de.h); {sub D}
        $93:sub_8(r.de.l); {sub E}
        $94:sub_8(r.hl.h); {sub H}
        $95:sub_8(r.hl.l); {sub L}
        $96:sub_8(self.getbyte(r.hl.w));  {sub (HL)}
        $97:sub_8(r.a); {sub A}
        $98:sbc_8(r.bc.h); {sbc A,B}
        $99:sbc_8(r.bc.l); {sbc A,C}
        $9a:sbc_8(r.de.h); {sbc A,D}
        $9b:sbc_8(r.de.l); {sbc A,E}
        $9c:sbc_8(r.hl.h); {sbc A,H}
        $9d:sbc_8(r.hl.l); {sbc A,L}
        $9e:sbc_8(self.getbyte(r.hl.w)); {sbc A,(HL)}
        $9f:sbc_8(r.a); {sbc A,A}
        $a0:and_a(r.bc.h);  {and A,B}
        $a1:and_a(r.bc.l);  {and A,C}
        $a2:and_a(r.de.h);  {and A,D}
        $a3:and_a(r.de.l); {and A,E}
        $a4:and_a(r.hl.h); {and A,H}
        $a5:and_a(r.hl.l); {and A,L}
        $a6:and_a(self.getbyte(r.hl.w)); {and A,(HL)}
        $a7:and_a(r.a); {and A,A}
        $a8:xor_a(r.bc.h); {xor A,B}
        $a9:xor_a(r.bc.l); {xor A,C}
        $aa:xor_a(r.de.h); {xor A,D}
        $ab:xor_a(r.de.l); {xor A,E}
        $ac:xor_a(r.hl.h); {xor A,H}
        $ad:xor_a(r.hl.l); {xor A,L}
        $ae:xor_a(self.getbyte(r.hl.w)); {xor A,(HL)}
        $af:begin {xor A,A}
                r.a:=0;
                r.f.s:=false;
                r.f.z:=true;
                r.f.bit5:=false;
                r.f.h:=false;
                r.f.bit3:=false;
                r.f.p_v:=true;
                r.f.n:=false;
                r.f.c:=false;
             end;
        $b0:or_a(r.bc.h); {or B}
        $b1:or_a(r.bc.l); {or C}
        $b2:or_a(r.de.h); {or D}
        $b3:or_a(r.de.l); {or E}
        $b4:or_a(r.hl.h); {or H}
        $b5:or_a(r.hl.l); {or L}
        $b6:or_a(self.getbyte(r.hl.w));   {or (HL)}
        $b7:or_a(r.a); {or A}
        $b8:cp_a(r.bc.h); {cp B}
        $b9:cp_a(r.bc.l); {cp C}
        $ba:cp_a(r.de.h); {cp D}
        $bb:cp_a(r.de.l); {cp E}
        $bc:cp_a(r.hl.h); {cp H}
        $bd:cp_a(r.hl.l); {cp L}
        $be:cp_a(self.getbyte(r.hl.w)); {cp (HL)}
        $bf:cp_a(r.a); {cp A}
        $c0:if not(r.f.z) then begin //ret NZ
                r.pc:=self.pop_sp;
                r.wz:=r.pc;
                self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
             end;
        $c1:r.bc.w:=self.pop_sp;  {pop BC}
        $c2:begin  //jp NZ,nn
                if not(r.f.z) then begin
                    posicion.h:=self.getbyte(r.pc+1);
                    posicion.l:=self.getbyte(r.pc);
                    r.pc:=posicion.w;
                end else r.pc:=r.pc+2;
                r.wz:=r.pc;
            end;
        $c3:begin {jp nn}
                posicion.h:=self.getbyte(r.pc+1);
                posicion.l:=self.getbyte(r.pc);
                r.pc:=posicion.w;
                r.wz:=posicion.w;
             end;
        $c4:begin   //call NZ,nn
                r.pc:=r.pc+2;
                if not(r.f.z) then begin
                        self.push_sp(r.pc);
                        posicion.h:=self.getbyte(r.pc-1);
                        posicion.l:=self.getbyte(r.pc-2);
                        r.pc:=posicion.w;
                        self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
                end;
                r.wz:=r.pc;
             end;
        $c5:self.push_sp(r.bc.w);  {push BC}
        $c6:begin {add A,n}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                add_8(temp);
             end;
        $c7:begin  //rst 00H
                self.push_sp(r.pc);
                r.pc:=0;
                r.wz:=0;
             end;
        $c8:if r.f.z then begin //ret Z
                r.pc:=self.pop_sp;
                r.wz:=r.pc;
                self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
             end;
        $c9:begin //ret
                r.pc:=pop_sp;
                r.wz:=r.pc;
            end;
        $ca:begin //jp Z,nn
                if r.f.z then begin
                    posicion.h:=self.getbyte(r.pc+1);
                    posicion.l:=self.getbyte(r.pc);
                    r.pc:=posicion.w;
                end else r.pc:=r.pc+2;
                r.wz:=r.pc;
            end;
        $cb:self.estados_demas:=self.estados_demas+self.exec_cb;
        $cc:begin   //call Z,nn
                r.pc:=r.pc+2;
                if r.f.z then begin
                        self.push_sp(r.pc);
                        posicion.h:=self.getbyte(r.pc-1);
                        posicion.l:=self.getbyte(r.pc-2);
                        r.pc:=posicion.w;
                        self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
                end;
                r.wz:=r.pc;
             end;
        $cd:begin   {call nn}
                posicion.h:=self.getbyte(r.pc+1);
                posicion.l:=self.getbyte(r.pc);
                r.wz:=posicion.w;
                r.pc:=r.pc+2;
                self.push_sp(r.pc);
                r.pc:=posicion.w;
             end;
        $ce:begin   {adc A,n}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                adc_8(temp);
             end;
        $cf:begin  //rst 08H
                self.push_sp(r.pc);
                r.pc:=$8;
                r.wz:=$8;
             end;
        $d0:if not(r.f.c) then begin //ret NC
                r.pc:=pop_sp;
                r.wz:=r.pc;
                self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
             end;
        $d1:r.de.w:=pop_sp;  {pop DE}
        $d2:begin  //jp NC,nn
                if not(r.f.c) then begin
                    posicion.h:=self.getbyte(r.pc+1);
                    posicion.l:=self.getbyte(r.pc);
                    r.pc:=posicion.w;
                end else r.pc:=r.pc+2;
                r.wz:=r.pc;
            end;
        $d3:begin {out (n),A}
                posicion.l:=self.getbyte(r.pc);
                posicion.h:=r.a;
                r.pc:=r.pc+1;
                if @self.out_port<>nil then self.out_port(posicion.w,r.a);
                r.wz:=((posicion.l+1) and $ff) or (r.a shl 8);
             end;
        $d4:begin   //call NC,nn
                r.pc:=r.pc+2;
                if not(r.f.c) then begin
                        self.push_sp(r.pc);
                        posicion.h:=self.getbyte(r.pc-1);
                        posicion.l:=self.getbyte(r.pc-2);
                        r.pc:=posicion.w;
                        self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
                end;
                r.wz:=r.pc;
             end;
        $d5:self.push_sp(r.de.w);  {push DE}
        $d6:begin {sub n}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                sub_8(temp);
             end;
        $d7:begin  //rst 10H
                self.push_sp(r.pc);
                r.pc:=$10;
                r.wz:=$10;
             end;
        $d8:if r.f.c then begin //ret C
                r.pc:=pop_sp;
                r.wz:=r.pc;
                self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
             end;
        $d9:begin {exx}
                posicion:=r.bc;
                r.bc:=r.bc2;
                r.bc2:=posicion;
                posicion:=r.de;
                r.de:=r.de2;
                r.de2:=posicion;
                posicion:=r.hl;
                r.hl:=r.hl2;
                r.hl2:=posicion;
             end;
        $da:begin //jp C,nn
                if r.f.c then begin
                    posicion.h:=self.getbyte(r.pc+1);
                    posicion.l:=self.getbyte(r.pc);
                    r.pc:=posicion.w;
                end else r.pc:=r.pc+2;
                r.wz:=r.pc;
            end;
        $db:begin  //in A,(n)
                posicion.l:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                posicion.h:=r.a;
                if @self.in_port<>nil then r.a:=self.in_port(posicion.w)
                  else r.a:=$ff;
                r.wz:=posicion.w+1;
             end;
        $dc:begin   //call C,nn
                r.pc:=r.pc+2;
                if r.f.c then begin
                        self.push_sp(r.pc);
                        posicion.h:=self.getbyte(r.pc-1);
                        posicion.l:=self.getbyte(r.pc-2);
                        r.pc:=posicion.w;
                        self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
                end;
                r.wz:=r.pc;
             end;
        $dd:self.estados_demas:=self.estados_demas+self.exec_dd_fd(true);
        $de:begin {sbc A,n}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                sbc_8(temp);
            end;
        $df:begin  //rst 18H
                self.push_sp(r.pc);
                r.pc:=$18;
                r.wz:=$18;
             end;
        $e0:if not(r.f.p_v) then begin //ret PO
                r.pc:=self.pop_sp;
                r.wz:=r.pc;
                self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
             end;
        $e1:r.hl.w:=pop_sp;  {pop HL}
        $e2:begin //jp PO,nn
                if not(r.f.p_v) then begin
                    posicion.h:=self.getbyte(r.pc+1);
                    posicion.l:=self.getbyte(r.pc);
                    r.pc:=posicion.w;
                end else r.pc:=r.pc+2;
                r.wz:=r.pc;
            end;
        $e3:begin   {ex (sp),hl}
                posicion.w:=pop_sp;
                self.push_sp(r.hl.w);
                r.hl:=posicion;
                r.wz:=posicion.w;
             end;
        $e4:begin   //call PO,nn
                r.pc:=r.pc+2;
                if not(r.f.p_v) then begin
                        self.push_sp(r.pc);
                        posicion.h:=self.getbyte(r.pc-1);
                        posicion.l:=self.getbyte(r.pc-2);
                        r.pc:=posicion.w;
                        self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
                end;
                r.wz:=r.pc;
             end;
        $e5:self.push_sp(r.hl.w);  {push HL}
        $e6:begin {and A,n}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                and_a(temp);
             end;
        $e7:begin  //rst 20H
                self.push_sp(r.pc);
                r.pc:=$20;
                r.wz:=$20;
             end;
        $e8:if r.f.p_v then begin //ret PE
                r.pc:=pop_sp;
                r.wz:=r.pc;
                self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
             end;
        $e9:r.pc:=r.hl.w; {jp (HL)}
        $ea:begin //jp PE,nn
                if r.f.p_v then begin
                    posicion.h:=self.getbyte(r.pc+1);
                    posicion.l:=self.getbyte(r.pc);
                    r.pc:=posicion.w;
                end else r.pc:=r.pc+2;
                r.wz:=r.pc;
            end;
        $eb:begin { ex DE,HL}
                posicion:=r.de;
                r.de:=r.hl;
                r.hl:=posicion;
             end;
        $ec:begin   //call PE,nn
                r.pc:=r.pc+2;
                if r.f.p_v then begin
                        self.push_sp(r.pc);
                        posicion.h:=self.getbyte(r.pc-1);
                        posicion.l:=self.getbyte(r.pc-2);
                        r.pc:=posicion.w;
                        self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
                end;
                r.wz:=r.pc;
             end;
        $ed:self.estados_demas:=self.estados_demas+exec_ed;
        $ee:begin  {xor A,n}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                xor_a(temp);
              end;
        $ef:begin  //rst 28H
                self.push_sp(r.pc);
                r.pc:=$28;
                r.wz:=$28;
             end;
        $f0:if not(r.f.s) then begin //ret NP
                r.pc:=self.pop_sp;
                r.wz:=r.pc;
                self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
             end;
        $f1:begin  {pop AF}
                posicion.w:=pop_sp;
                r.a:=posicion.h;
                if (posicion.l and 128)<>0 then r.f.s:=true else r.f.s:=false;
                if (posicion.l and 64)<>0 then r.f.z:=true else r.f.z:=false;
                if (posicion.l and 32)<>0 then r.f.bit5:=true else r.f.bit5:=false;
                if (posicion.l and 16)<>0 then r.f.h:=true else r.f.h:=false;
                if (posicion.l and 8)<>0 then r.f.bit3:=true else r.f.bit3:=false;
                if (posicion.l and 4)<>0 then r.f.p_v:=true else r.f.p_v:=false;
                if (posicion.l and 2)<>0 then r.f.n:=true else r.f.n:=false;
                if (posicion.l and 1)<>0 then r.f.c:=true else r.f.c:=false;
                end;
        $f2:begin //jp P,nn
                if not(r.f.s) then begin
                    posicion.h:=self.getbyte(r.pc+1);
                    posicion.l:=self.getbyte(r.pc);
                    r.pc:=posicion.w;
                end else r.pc:=r.pc+2;
                r.wz:=r.pc;
            end;
        $f3:begin {di}
                r.iff1:=false;
                r.iff2:=false;
              end;
        $f4:begin   //call P,nn
                r.pc:=r.pc+2;
                if not(r.f.s) then begin
                        self.push_sp(r.pc);
                        posicion.h:=self.getbyte(r.pc-1);
                        posicion.l:=self.getbyte(r.pc-2);
                        r.pc:=posicion.w;
                        self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
                end;
                r.wz:=r.pc;
             end;
        $f5:begin  //push AF
                posicion.h:=r.a;
                posicion.l:=byte(r.f.s) shl 7;
                posicion.l:=posicion.l or (byte(r.f.z) shl 6);
                posicion.l:=posicion.l or (byte(r.f.bit5) shl 5);
                posicion.l:=posicion.l or (byte(r.f.h) shl 4);
                posicion.l:=posicion.l or (byte(r.f.bit3) shl 3);
                posicion.l:=posicion.l or (byte(r.f.p_v) shl 2);
                posicion.l:=posicion.l or (byte(r.f.n) shl 1);
                posicion.l:=posicion.l or byte(r.f.c);
                self.push_sp(posicion.w);
             end;
        $f6:begin {or n}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                or_a(temp);
             end;
        $f7:begin  //rst 30H
                self.push_sp(r.pc);
                r.pc:=$30;
                r.wz:=$30;
             end;
        $f8:if r.f.s then begin //ret M
                r.pc:=self.pop_sp;
                r.wz:=r.pc;
                self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
             end;
        $f9:r.sp:=r.hl.w; {ld SP,HL}
        $fa:begin  //jp M,nn
                if r.f.s then begin
                    posicion.h:=self.getbyte(r.pc+1);
                    posicion.l:=self.getbyte(r.pc);
                    r.pc:=posicion.w;
                end else r.pc:=r.pc+2;
                r.wz:=r.pc;
            end;
        $fb:begin   {ei}
                r.iff1:=true;
                r.iff2:=true;
                self.after_ei:=true;
             end;
        $fc:begin   //call M,nn
                r.pc:=r.pc+2;
                if r.f.s then begin
                        self.push_sp(r.pc);
                        posicion.h:=self.getbyte(r.pc-1);
                        posicion.l:=self.getbyte(r.pc-2);
                        r.pc:=posicion.w;
                        self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
                end;
                r.wz:=r.pc;
             end;
        $fd:self.estados_demas:=self.estados_demas+self.exec_dd_fd(false);
        $fe:begin  {cp n}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                cp_a(temp);
            end;
        $ff:begin  //rst 38H
                self.push_sp(r.pc);
                r.pc:=$38;
                r.wz:=$38;
             end;
end; {del case}
cantidad_t:=z80t[instruccion]+self.estados_demas;
if @self.despues_instruccion<>nil then self.despues_instruccion(cantidad_t);
self.contador:=self.contador+cantidad_t;
timers.update(self.contador-pestados,self.numero_cpu);
end; {del while}
end;

function cpu_z80.exec_cb:byte;
var
        instruccion,temp:byte;
begin
self.opcode:=true;
instruccion:=self.getbyte(r.pc);
self.opcode:=false;
r.pc:=r.pc+1;
r.r:=((r.r+1) and $7f) or (r.r and $80);
case instruccion of
        $00:rlc_8(@r.bc.h); {rlc B}
        $01:rlc_8(@r.bc.l); {rlc C}
        $02:rlc_8(@r.de.h); {rlc D}
        $03:rlc_8(@r.de.l); {rlc E}
        $04:rlc_8(@r.hl.h); {rlc H}
        $05:rlc_8(@r.hl.l); {rlc L}
        $06:begin {rlc (HL)}
                temp:=self.getbyte(r.hl.w);
                rlc_8(@temp);
                self.putbyte(r.hl.w,temp);
            end;
        $07:rlc_8(@r.a); {rlc A}
        $08:rrc_8(@r.bc.h); {rrc B}
        $09:rrc_8(@r.bc.l); {rrc C}
        $0a:rrc_8(@r.de.h); {rrc D}
        $0b:rrc_8(@r.de.l); {rrc E}
        $0c:rrc_8(@r.hl.h); {rrc H}
        $0d:rrc_8(@r.hl.l); {rrc L}
        $0e:begin {rrc (HL)}
                temp:=self.getbyte(r.hl.w);
                rrc_8(@temp);
                self.putbyte(r.hl.w,temp);
            end;
        $0f:rrc_8(@r.a); {rrc A}
        $10:rl_8(@r.bc.h); {rl B}
        $11:rl_8(@r.bc.l); {rl C}
        $12:rl_8(@r.de.h); {rl D}
        $13:rl_8(@r.de.l); {rl E}
        $14:rl_8(@r.hl.h); {rl H}
        $15:rl_8(@r.hl.l); {rl L}
        $16:begin
                temp:=self.getbyte(r.hl.w);
                rl_8(@temp); {rl (HL)}
                self.putbyte(r.hl.w,temp);
            end;
        $17:rl_8(@r.a); {rl A}
        $18:rr_8(@r.bc.h); {rr B}
        $19:rr_8(@r.bc.l); {rr C}
        $1a:rr_8(@r.de.h); {rr D}
        $1b:rr_8(@r.de.l); {rr E}
        $1c:rr_8(@r.hl.h); {rr H}
        $1d:rr_8(@r.hl.l); {rr L}
        $1e:begin
                temp:=self.getbyte(r.hl.w);
                rr_8(@temp); {rr (HL)}
                self.putbyte(r.hl.w,temp);
            end;
        $1f:rr_8(@r.a); {rr A}
        $20:sla_8(@r.bc.h); {sla B}
        $21:sla_8(@r.bc.l); {sla C}
        $22:sla_8(@r.de.h); {sla D}
        $23:sla_8(@r.de.l); {sla E}
        $24:sla_8(@r.hl.h); {sla H}
        $25:sla_8(@r.hl.l); {sla L}
        $26:begin {sla (HL)}
                temp:=self.getbyte(r.hl.w);
                sla_8(@temp);
                self.putbyte(r.hl.w,temp);
            end;
        $27:sla_8(@r.a); {sla A}
        $28:sra_8(@r.bc.h); //sra B
        $29:sra_8(@r.bc.l); //sra C
        $2a:sra_8(@r.de.h); //sra D
        $2b:sra_8(@r.de.l); //sra E
        $2c:sra_8(@r.hl.h); //sra H
        $2d:sra_8(@r.hl.l); //sra L
        $2e:begin //sra (HL)
                temp:=self.getbyte(r.hl.w);
                sra_8(@temp);
                self.putbyte(r.hl.w,temp);
            end;
        $2f:sra_8(@r.a); //sra A
        $30:sll_8(@r.bc.h); {sll B}
        $31:sll_8(@r.bc.l); {sll C}
        $32:sll_8(@r.de.h); {sll D}
        $33:sll_8(@r.de.l); {sll E}
        $34:sll_8(@r.hl.h); {sll H}
        $35:sll_8(@r.hl.l); {sll L}
        $36:begin  {sll (HL)}
                temp:=self.getbyte(r.hl.w);
                sll_8(@temp);
                self.putbyte(r.hl.w,temp);
            end;
        $37:sll_8(@r.a); {sll a}
        $38:srl_8(@r.bc.h); {srl B}
        $39:srl_8(@r.bc.l); {srl C}
        $3a:srl_8(@r.de.h); {srl D}
        $3b:srl_8(@r.de.l); {srl E}
        $3c:srl_8(@r.hl.h); {srl H}
        $3d:srl_8(@r.hl.l); {srl L}
        $3e:begin  {srl (HL)}
                temp:=self.getbyte(r.hl.w);
                srl_8(@temp);
                self.putbyte(r.hl.w,temp);
            end;
        $3f:srl_8(@r.a); {srl a}
        $40:bit_8(0,r.bc.h);  {bit 0,B}
        $41:bit_8(0,r.bc.l);  {bit 0,C}
        $42:bit_8(0,r.de.h);  {bit 0,D}
        $43:bit_8(0,r.de.l);  {bit 0,E}
        $44:bit_8(0,r.hl.h);  {bit 0,H}
        $45:bit_8(0,r.hl.l);  {bit 0,L}
        $46:begin //bit 0,(HL)
              bit_8(0,self.getbyte(r.hl.w));
              r.f.bit5:=(r.wz and $2000)<>0;
              r.f.bit3:=(r.wz and $800)<>0;
            end;
        $47:bit_8(0,r.a);  {bit 0,A}
        $48:bit_8(1,r.bc.h);  {bit 1,B}
        $49:bit_8(1,r.bc.l);  {bit 1,C}
        $4a:bit_8(1,r.de.h);  {bit 1,D}
        $4b:bit_8(1,r.de.l);  {bit 1,E}
        $4c:bit_8(1,r.hl.h);  {bit 1,H}
        $4d:bit_8(1,r.hl.l);  {bit 1,L}
        $4e:begin //bit 1,(HL)
              bit_8(1,self.getbyte(r.hl.w));
              r.f.bit5:=(r.wz and $2000)<>0;
              r.f.bit3:=(r.wz and $800)<>0;
            end;
        $4f:bit_8(1,r.a);  {bit 1,A}
        $50:bit_8(2,r.bc.h);  {bit 2,B}
        $51:bit_8(2,r.bc.l);  {bit 2,C}
        $52:bit_8(2,r.de.h);  {bit 2,D}
        $53:bit_8(2,r.de.l);  {bit 2,E}
        $54:bit_8(2,r.hl.h);  {bit 2,H}
        $55:bit_8(2,r.hl.l);  {bit 2,L}
        $56:begin //bit 2,(HL)
              bit_8(2,self.getbyte(r.hl.w));
              r.f.bit5:=(r.wz and $2000)<>0;
              r.f.bit3:=(r.wz and $800)<>0;
            end;
        $57:bit_8(2,r.a);  {bit 2,A}
        $58:bit_8(3,r.bc.h);  {bit 3,B}
        $59:bit_8(3,r.bc.l);  {bit 3,C}
        $5a:bit_8(3,r.de.h);  {bit 3,D}
        $5b:bit_8(3,r.de.l);  {bit 3,E}
        $5c:bit_8(3,r.hl.h);  {bit 3,H}
        $5d:bit_8(3,r.hl.l);  {bit 3,L}
        $5e:begin //bit 3,(HL)
              bit_8(3,self.getbyte(r.hl.w));
              r.f.bit5:=(r.wz and $2000)<>0;
              r.f.bit3:=(r.wz and $800)<>0;
            end;
        $5f:bit_8(3,r.a);  {bit 3,A}
        $60:bit_8(4,r.bc.h);  {bit 4,B}
        $61:bit_8(4,r.bc.l);  {bit 4,C}
        $62:bit_8(4,r.de.h);  {bit 4,D}
        $63:bit_8(4,r.de.l);  {bit 4,E}
        $64:bit_8(4,r.hl.h);  {bit 4,H}
        $65:bit_8(4,r.hl.l);  {bit 4,L}
        $66:begin //bit 4,(HL)
              bit_8(4,self.getbyte(r.hl.w));
              r.f.bit5:=(r.wz and $2000)<>0;
              r.f.bit3:=(r.wz and $800)<>0;
            end;
        $67:bit_8(4,r.a);  {bit 4,A}
        $68:bit_8(5,r.bc.h);  {bit 5,B}
        $69:bit_8(5,r.bc.l);  {bit 5,C}
        $6a:bit_8(5,r.de.h);  {bit 5,D}
        $6b:bit_8(5,r.de.l);  {bit 5,E}
        $6c:bit_8(5,r.hl.h);  {bit 5,H}
        $6d:bit_8(5,r.hl.l);  {bit 5,L}
        $6e:begin //bit 5,(HL)
              bit_8(5,self.getbyte(r.hl.w));
              r.f.bit5:=(r.wz and $2000)<>0;
              r.f.bit3:=(r.wz and $800)<>0;
            end;
        $6f:bit_8(5,r.a);  {bit 5,A}
        $70:bit_8(6,r.bc.h);  {bit 6,B}
        $71:bit_8(6,r.bc.l);  {bit 6,C}
        $72:bit_8(6,r.de.h);  {bit 6,D}
        $73:bit_8(6,r.de.l);  {bit 6,E}
        $74:bit_8(6,r.hl.h);  {bit 6,H}
        $75:bit_8(6,r.hl.l);  {bit 6,L}
        $76:begin //bit 6,(HL)
              bit_8(6,self.getbyte(r.hl.w));
              r.f.bit5:=(r.wz and $2000)<>0;
              r.f.bit3:=(r.wz and $800)<>0;
            end;
        $77:bit_8(6,r.a);  {bit 6,A}
        $78:bit_7(r.bc.h);  {bit 7,B}
        $79:bit_7(r.bc.l);  {bit 7,C}
        $7a:bit_7(r.de.h);  {bit 7,D}
        $7b:bit_7(r.de.l);  {bit 7,E}
        $7c:bit_7(r.hl.h);  {bit 7,H}
        $7d:bit_7(r.hl.l);  {bit 7,L}
        $7e:begin //bit 7,(HL)
              bit_7(self.getbyte(r.hl.w));
              r.f.bit5:=(r.wz and $2000)<>0;
              r.f.bit3:=(r.wz and $800)<>0;
            end;
        $7f:bit_7(r.a);  {bit 7,A}
        $80:r.bc.h:=(r.bc.h and $fe); {res 0,B}
        $81:r.bc.l:=(r.bc.l and $fe); {res 0,C}
        $82:r.de.h:=(r.de.h and $fe); {res 0,D}
        $83:r.de.l:=(r.de.l and $fe); {res 0,E}
        $84:r.hl.h:=(r.hl.h and $fe); {res 0,H}
        $85:r.hl.l:=(r.hl.l and $fe); {res 0,L}
        $86:begin  {res 0,(hl)}
                  temp:=(self.getbyte(r.hl.w) and $fe);
                  self.putbyte(r.hl.w,temp);
             end;
        $87:r.a:=r.a and $fe; {res 0,A}
        $88:r.bc.h:=r.bc.h and $fd; {res 1,B}
        $89:r.bc.l:=r.bc.l and $fd; {res 1,C}
        $8a:r.de.h:=r.de.h and $fd; {res 1,D}
        $8b:r.de.l:=r.de.l and $fd; {res 1,E}
        $8c:r.hl.h:=r.hl.h and $fd; {res 1,H}
        $8d:r.hl.l:=r.hl.l and $fd; {res 1,L}
        $8e:begin  {res 1,(hl)}
                  temp:=(self.getbyte(r.hl.w) and $fd);
                  self.putbyte(r.hl.w,temp);
             end;
        $8f:r.a:=r.a and $fd; {res 1,A}
        $90:r.bc.h:=r.bc.h and $fb; {res 2,B}
        $91:r.bc.l:=r.bc.l and $fb; {res 2,C}
        $92:r.de.h:=r.de.h and $fb; {res 2,D}
        $93:r.de.l:=r.de.l and $fb; {res 2,E}
        $94:r.hl.h:=r.hl.h and $fb; {res 2,H}
        $95:r.hl.l:=r.hl.l and $fb; {res 2,L}
        $96:begin  {res 2,(HL)}
                  temp:=self.getbyte(r.hl.w) and $fb;
                  self.putbyte(r.hl.w,temp);
             end;
        $97:r.a:=r.a and $fb; {res 2,A}
        $98:r.bc.h:=r.bc.h and $f7; {res 3,B}
        $99:r.bc.l:=r.bc.l and $f7; {res 3,C}
        $9a:r.de.h:=r.de.h and $f7; {res 3,D}
        $9b:r.de.l:=r.de.l and $f7; {res 3,E}
        $9c:r.hl.h:=r.hl.h and $f7; {res 3,H}
        $9d:r.hl.l:=r.hl.l and $f7; {res 3,L}
        $9e:begin  {res 3,(HL)}
                  temp:=self.getbyte(r.hl.w) and $f7;
                  self.putbyte(r.hl.w,temp);
             end;
        $9f:r.a:=r.a and $f7; {res 3,A}
        $a0:r.bc.h:=r.bc.h and $ef; {res 4,B}
        $a1:r.bc.l:=r.bc.l and $ef; {res 4,C}
        $a2:r.de.h:=r.de.h and $ef; {res 4,D}
        $a3:r.de.l:=r.de.l and $ef; {res 4,E}
        $a4:r.hl.h:=r.hl.h and $ef; {res 4,H}
        $a5:r.hl.l:=r.hl.l and $ef; {res 4,L}
        $a6:begin  {res 4,(HL)}
                  temp:=self.getbyte(r.hl.w) and $ef;
                  self.putbyte(r.hl.w,temp);
             end;
        $a7:r.a:=r.a and $ef; {res 4,A}
        $a8:r.bc.h:=r.bc.h and $df; {res 5,B}
        $a9:r.bc.l:=r.bc.l and $df; {res 5,C}
        $aa:r.de.h:=r.de.h and $df; {res 5,D}
        $ab:r.de.l:=r.de.l and $df; {res 5,E}
        $ac:r.hl.h:=r.hl.h and $df; {res 5,H}
        $ad:r.hl.l:=r.hl.l and $df; {res 5,L}
        $ae:begin  {res 5,(HL)}
                  temp:=self.getbyte(r.hl.w) and $df;
                  self.putbyte(r.hl.w,temp);
             end;
        $af:r.a:=r.a and $df; {res 5,A}
        $b0:r.bc.h:=r.bc.h and $bf; {res 6,B}
        $b1:r.bc.l:=r.bc.l and $bf; {res 6,C}
        $b2:r.de.h:=r.de.h and $bf; {res 6,D}
        $b3:r.de.l:=r.de.l and $bf; {res 6,E}
        $b4:r.hl.h:=r.hl.h and $bf; {res 6,H}
        $b5:r.hl.l:=r.hl.l and $bf; {res 6,L}
        $b6:begin  {res 6,(HL)}
                  temp:=self.getbyte(r.hl.w) and $bf;
                  self.putbyte(r.hl.w,temp);
             end;
        $b7:r.a:=r.a and $bf; {res 6,A}
        $b8:r.bc.h:=r.bc.h and $7f; {res 7,B}
        $b9:r.bc.l:=r.bc.l and $7f; {res 7,C}
        $ba:r.de.h:=r.de.h and $7f; {res 7,D}
        $bb:r.de.l:=r.de.l and $7f; {res 7,E}
        $bc:r.hl.h:=r.hl.h and $7f; {res 7,H}
        $bd:r.hl.l:=r.hl.l and $7f; {res 7,L}
        $be:begin  {res 7,(HL)}
                  temp:=self.getbyte(r.hl.w) and $7f;
                  self.putbyte(r.hl.w,temp);
             end;
        $bf:r.a:=r.a and $7f; {res 7,A}
        $c0:r.bc.h:=r.bc.h or $1; {set 0,B}
        $c1:r.bc.l:=r.bc.l or $1; {set 0,C}
        $c2:r.de.h:=r.de.h or $1; {set 0,D}
        $c3:r.de.l:=r.de.l or $1; {set 0,E}
        $c4:r.hl.h:=r.hl.h or $1; {set 0,H}
        $c5:r.hl.l:=r.hl.l or $1; {set 0,L}
        $c6:begin  {set 0,(HL)}
                  temp:=self.getbyte(r.hl.w) or 1;
                  self.putbyte(r.hl.w,temp);
             end;
        $c7:r.a:=r.a or $1; {set 0,A}
        $c8:r.bc.h:=r.bc.h or $2; {set 1,B}
        $c9:r.bc.l:=r.bc.l or $2; {set 1,C}
        $ca:r.de.h:=r.de.h or $2; {set 1,D}
        $cb:r.de.l:=r.de.l or $2; {set 1,E}
        $cc:r.hl.h:=r.hl.h or $2; {set 1,H}
        $cd:r.hl.l:=r.hl.l or $2; {set 1,L}
        $ce:begin  {set 1,(HL)}
                  temp:=self.getbyte(r.hl.w) or 2;
                  self.putbyte(r.hl.w,temp);
             end;
        $cf:r.a:=r.a or $2; {set 1,A}
        $d0:r.bc.h:=r.bc.h or $4; {set 2,B}
        $d1:r.bc.l:=r.bc.l or $4; {set 2,C}
        $d2:r.de.h:=r.de.h or $4; {set 2,D}
        $d3:r.de.l:=r.de.l or $4; {set 2,E}
        $d4:r.hl.h:=r.hl.h or $4; {set 2,H}
        $d5:r.hl.l:=r.hl.l or $4; {set 2,L}
        $d6:begin  {set 2,(HL)}
                  temp:=self.getbyte(r.hl.w) or 4;
                  self.putbyte(r.hl.w,temp);
             end;
        $d7:r.a:=r.a or $4; {set 2,A}
        $d8:r.bc.h:=r.bc.h or $8; {set 3,B}
        $d9:r.bc.l:=r.bc.l or $8; {set 3,C}
        $da:r.de.h:=r.de.h or $8; {set 3,D}
        $db:r.de.l:=r.de.l or $8; {set 3,E}
        $dc:r.hl.h:=r.hl.h or $8; {set 3,H}
        $dd:r.hl.l:=r.hl.l or $8; {set 3,L}
        $de:begin  {set 3,(HL)}
                  temp:=self.getbyte(r.hl.w) or 8;
                  self.putbyte(r.hl.w,temp);
             end;
        $df:r.a:=r.a or $8; {set 3,A}
        $e0:r.bc.h:=r.bc.h or $10; {set 4,B}
        $e1:r.bc.l:=r.bc.l or $10; {set 4,C}
        $e2:r.de.h:=r.de.h or $10; {set 4,D}
        $e3:r.de.l:=r.de.l or $10; {set 4,E}
        $e4:r.hl.h:=r.hl.h or $10; {set 4,H}
        $e5:r.hl.l:=r.hl.l or $10; {set 4,L}
        $e6:begin  {set 4,(HL)}
                  temp:=self.getbyte(r.hl.w) or $10;
                  self.putbyte(r.hl.w,temp);
             end;
        $e7:r.a:=r.a or $10; {set 4,A}
        $e8:r.bc.h:=r.bc.h or $20; {set 5,B}
        $e9:r.bc.l:=r.bc.l or $20; {set 5,C}
        $ea:r.de.h:=r.de.h or $20; {set 5,D}
        $eb:r.de.l:=r.de.l or $20; {set 5,E}
        $ec:r.hl.h:=r.hl.h or $20; {set 5,H}
        $ed:r.hl.l:=r.hl.l or $20; {set 5,L}
        $ee:begin  {set 5,(HL)}
                  temp:=self.getbyte(r.hl.w) or $20;
                  self.putbyte(r.hl.w,temp);
             end;
        $ef:r.a:=r.a or $20; {set 5,A}
        $f0:r.bc.h:=r.bc.h or $40; {set 6,B}
        $f1:r.bc.l:=r.bc.l or $40; {set 6,C}
        $f2:r.de.h:=r.de.h or $40; {set 6,D}
        $f3:r.de.l:=r.de.l or $40; {set 6,E}
        $f4:r.hl.h:=r.hl.h or $40; {set 6,H}
        $f5:r.hl.l:=r.hl.l or $40; {set 6,L}
        $f6:begin  {set 6,(HL)}
                  temp:=self.getbyte(r.hl.w) or $40;
                  self.putbyte(r.hl.w,temp);
             end;
        $f7:r.a:=r.a or $40; {set 6,A}
        $f8:r.bc.h:=r.bc.h or $80; {set 7,B}
        $f9:r.bc.l:=r.bc.l or $80; {set 7,C}
        $fa:r.de.h:=r.de.h or $80; {set 7,D}
        $fb:r.de.l:=r.de.l or $80; {set 7,E}
        $fc:r.hl.h:=r.hl.h or $80; {set 7,H}
        $fd:r.hl.l:=r.hl.l or $80; {set 7,L}
        $fe:begin  {set 7,(HL)}
                  temp:=self.getbyte(r.hl.w) or $80;
                  self.putbyte(r.hl.w,temp);
             end;
        $ff:r.a:=r.a or $80; {set 7,A}
end;
exec_cb:=z80t_cb[instruccion];
end;

function cpu_z80.exec_dd_fd(tipo:boolean):byte;
var
 instruccion,temp:byte;
 temp2:word;
 registro:pparejas;
 posicion:parejas;
 estados_dd_cb:byte;
begin
if tipo then registro:=@r.ix else registro:=@r.iy;
temp2:=registro.w;
estados_dd_cb:=0;
self.opcode:=true;
instruccion:=self.getbyte(r.pc);
self.opcode:=false;
r.pc:=r.pc+1;
r.r:=((r.r+1) and $7f) or (r.r and $80);
case instruccion of
        $09:registro.w:=add_16(registro.w,r.bc.w); //add IX,BC
        $19:registro.w:=add_16(registro.w,r.de.w); //add IX,DE
        $21:begin {ld IX,nn}
                registro.h:=self.getbyte(r.pc+1);
                registro.l:=self.getbyte(r.pc);
                r.pc:=r.pc+2;
            end;
        $22:begin {ld (nn),IX}
                posicion.h:=self.getbyte(r.pc+1);
                posicion.l:=self.getbyte(r.pc);
                r.pc:=r.pc+2;
                self.putbyte(posicion.w,registro.l);
                self.putbyte(posicion.w+1,registro.h);
                r.wz:=posicion.w+1;
            end;
        $23:registro.w:=registro.w+1; {inc IX}
        $24:registro.h:=inc_8(registro.h);  //inc IXh
        $25:registro.h:=dec_8(registro.h); //dec IXh
        $26:begin  {ld IXh,n}
                registro^.h:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
            end;
        $29:registro.w:=add_16(registro.w,registro.w); //add IX,IX
        $2a:begin {ld (IX,(nn)}
                posicion.h:=self.getbyte(r.pc+1);
                posicion.l:=self.getbyte(r.pc);
                r.pc:=r.pc+2;
                registro^.l:=self.getbyte(posicion.w);
                registro^.h:=self.getbyte(posicion.w+1);
                r.wz:=posicion.w+1;
            end;
        $2b:registro^.w:=registro^.w-1; {dec IX}
        $2c:registro.l:=inc_8(registro.l); //inc IXl
        $2d:registro.l:=dec_8(registro.l); //dec IXl
        $2e:begin  {ld IXl,n}
                registro^.l:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
            end;
        $34:begin {inc (IX+d)} //debo tener en cuenta que temp2=registro.w
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                r.wz:=temp2;
                temp:=inc_8(self.getbyte(temp2));
                self.putbyte(temp2,temp);
            end;
        $35:begin {dec (IX+d)}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                r.wz:=temp2;
                temp:=dec_8(self.getbyte(temp2));
                self.putbyte(temp2,temp);
           end;
        $36:begin {ld (IX+d),n}
                temp:=self.getbyte(r.pc);
                temp2:=temp2+shortint(temp);
                temp:=self.getbyte(r.pc+1);
                r.wz:=temp2;
                r.pc:=r.pc+2;
                self.putbyte(temp2,temp);
            end;
        $39:registro.w:=add_16(registro.w,r.sp); //add IX,SP
        $44:r.bc.h:=registro^.h; {ld B,IXh}
        $45:r.bc.h:=registro^.l; {ld B,IXl}
        $46:begin {ld B,(IX+d)}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                r.wz:=temp2;
                r.bc.h:=self.getbyte(temp2);
            end;
        $4c:r.bc.l:=registro^.h; {ld C,IXh}
        $4d:r.bc.l:=registro^.l; {ld C,IXl}
        $4e:begin {ld C,(IX+d)}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                r.wz:=temp2;
                r.bc.l:=self.getbyte(temp2);
            end;
        $54:r.de.h:=registro^.h;  {ld D,IXh}
        $55:r.de.h:=registro^.l;  {ld D,IXl}
        $56:begin {ld D,(IX+d)}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                r.wz:=temp2;
                r.de.h:=self.getbyte(temp2);
            end;
        $5c:r.de.l:=registro^.h;  {ld E,IXh}
        $5d:r.de.l:=registro^.l;  {ld E,IXh}
        $5e:begin {ld E,(IX+d)}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                r.wz:=temp2;
                r.de.l:=self.getbyte(temp2);
            end;
        $60:registro^.h:=r.bc.h;  {ld IXh,B}
        $61:registro^.h:=r.bc.l;  {ld IXh,C}
        $62:registro^.h:=r.de.h;  {ld IXh,D}
        $63:registro^.h:=r.de.l;  {ld IXh,E}
        $64:;
        $65:registro^.h:=registro^.l;  {ld IXh,IXl}
        $66:begin {ld H,(IX+d)}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                r.wz:=temp2;
                r.hl.h:=self.getbyte(temp2);
            end;
        $67:registro^.h:=r.a;  {ld IXh,A}
        $68:registro^.l:=r.bc.h;  {ld IXl,B}
        $69:registro^.l:=r.bc.l;  {ld IXl,C}
        $6a:registro^.l:=r.de.h;  {ld IXl,D}
        $6b:registro^.l:=r.de.l;  {ld IXl,E}
        $6c:registro^.l:=registro^.h;  {ld IXl,IXh}
        $6d:; {ld IXl,IXl}
        $6e:begin {ld L,(IX+d)}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                r.wz:=temp2;
                r.hl.l:=self.getbyte(temp2);
            end;
        $6f:registro^.l:=r.a; {ld IXl,A}
        $70:begin {ld (IX+d),B}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                r.wz:=temp2;
                self.putbyte(temp2,r.bc.h);
            end;
        $71:begin {ld (IX+d),C}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                r.wz:=temp2;
                self.putbyte(temp2,r.bc.l);
            end;
        $72:begin {ld (IX+d),D}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                r.wz:=temp2;
                self.putbyte(temp2,r.de.h);
            end;
        $73:begin {ld (IX+d),E}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                r.wz:=temp2;
                self.putbyte(temp2,r.de.l);
            end;
        $74:begin {ld (IX+d),H}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                r.wz:=temp2;
                self.putbyte(temp2,r.hl.h);
            end;
        $75:begin {ld (IX+d),L}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                r.wz:=temp2;
                self.putbyte(temp2,r.hl.l);
            end;
        $77:begin {ld (IX+d),A}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                r.wz:=temp2;
                self.putbyte(temp2,r.a);
            end;
        $7c:r.a:=registro^.h;  {ld A,IXh}
        $7d:r.a:=registro^.l; {ld A,IXl}
        $7e:begin {ld A,(IX+d)}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                r.wz:=temp2;
                r.a:=self.getbyte(temp2);
            end;
        $84:add_8(registro^.h);  {add A,IXh}
        $85:add_8(registro^.l);  {add A,IXl}
        $86:begin {add A,(IX+d)}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                r.wz:=temp2;
                temp:=self.getbyte(temp2);
                add_8(temp);
            end;
        $8c:adc_8(registro^.h);  {adc A,IXh}
        $8d:adc_8(registro^.l);  {adc A,IXl}
        $8e:begin {adc A,(IX+d)}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                r.wz:=temp2;
                temp:=self.getbyte(temp2);
                adc_8(temp);
        end;
        $94:sub_8(registro^.h); {sub IXh}
        $95:sub_8(registro^.l); {sub IXh}
        $96:begin {sub (IX+d)}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                r.wz:=temp2;
                temp:=self.getbyte(temp2);
                sub_8(temp);
        end;
        $9c:sbc_8(registro^.h); {sbc IXh}
        $9d:sbc_8(registro^.l); {sbc IXl}
        $9e:begin {sbc (IX+d)}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                r.wz:=temp2;
                temp:=self.getbyte(temp2);
                sbc_8(temp);
        end;
        $a4:and_a(registro^.h); {and IXh}
        $a5:and_a(registro^.l); {and IXl}
        $a6:begin {and A,(IX+d)}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                r.wz:=temp2;
                temp:=self.getbyte(temp2);
                and_a(temp);
        end;
        $ac:xor_a(registro^.h); {xor IXh}
        $ad:xor_a(registro^.l); {xor IXl}
        $ae:begin {xor A,(IX+d)}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                r.wz:=temp2;
                temp:=self.getbyte(temp2);
                xor_a(temp);
              end;
        $b4:or_a(registro^.h);  {or IXh}
        $b5:or_a(registro^.l);  {or IXl}
        $b6:begin  {or (IX+d)}
                 temp:=self.getbyte(r.pc);
                 r.pc:=r.pc+1;
                 temp2:=temp2+shortint(temp);
                 r.wz:=temp2;
                 temp:=self.getbyte(temp2);
                 or_a(temp);
             end;
        $bc:cp_a(registro^.h); {cp IXh}
        $bd:cp_a(registro^.l); {cp IXl}
        $be:begin {cp (IX+d)}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                r.wz:=temp2;
                temp:=self.getbyte(temp2);
                cp_a(temp);
        end;
        $dd,$fd:estados_demas:=estados_demas+self.exec_dd_cb(tipo);
        $cb:estados_dd_cb:=self.exec_dd_cb(tipo);
        $e1:registro.w:=self.pop_sp;  {pop IX}
        $e3:begin   {ex (SP),IX}
                posicion.w:=self.pop_sp;
                self.push_sp(registro^.w);
                registro^.w:=posicion.w;
                r.wz:=posicion.w;
             end;
        $e5:self.push_sp(registro^.w);  {push IX}
        $e9:r.pc:=registro^.w; {jp IX}
        $f9:r.sp:=registro^.w; {ld SP,IX}
        else r.pc:=r.pc-1;
end;
exec_dd_fd:=z80t_dd[instruccion]+estados_dd_cb;
end;

function cpu_z80.exec_dd_cb(tipo:boolean):byte;
var
 instruccion,tempb:byte;
 temp2:word;
begin
if tipo then temp2:=r.ix.w else temp2:=r.iy.w;
//NO, NO y NO se considera un opcode
instruccion:=self.getbyte(r.pc);
temp2:=temp2+shortint(instruccion);
instruccion:=self.getbyte(r.pc+1);
r.pc:=r.pc+2;
r.wz:=temp2;
case instruccion of
        $00:begin {ld B,rlc (IX+d) >23t<}
                r.bc.h:=self.getbyte(temp2);
                rlc_8(@r.bc.h);
                self.putbyte(temp2,r.bc.h);
            end;
        $01:begin {ld C,rlc (IX+d) >23t<}
                r.bc.l:=self.getbyte(temp2);
                rlc_8(@r.bc.l);
                self.putbyte(temp2,r.bc.l);
            end;
        $02:begin {ld D,rlc (IX+d) >23t<}
                r.de.h:=self.getbyte(temp2);
                rlc_8(@r.de.h);
                self.putbyte(temp2,r.de.h);
            end;
        $03:begin {ld E,rlc (IX+d) >23t<}
                r.de.l:=self.getbyte(temp2);
                rlc_8(@r.de.l);
                self.putbyte(temp2,r.de.l);
            end;
        $04:begin {ld H,rlc (IX+d) >23t<}
                r.hl.h:=self.getbyte(temp2);
                rlc_8(@r.hl.h);
                self.putbyte(temp2,r.hl.h);
            end;
        $05:begin {ld L,rlc (IX+d) >23t<}
                r.hl.l:=self.getbyte(temp2);
                rlc_8(@r.hl.l);
                self.putbyte(temp2,r.hl.l);
            end;
        $06:begin {rlc (IX+d) >23t<}
                tempb:=self.getbyte(temp2);
                rlc_8(@tempb);
                self.putbyte(temp2,tempb);
            end;
        $07:begin {ld A,rlc (IX+d) >23t<}
                r.a:=self.getbyte(temp2);
                rlc_8(@r.a);
                self.putbyte(temp2,r.a);
            end;
        $08:begin {ld B,rrc (IX+d) >23t<}
                r.bc.h:=self.getbyte(temp2);
                rrc_8(@r.bc.h);
                self.putbyte(temp2,r.bc.h);
            end;
        $09:begin {ld C,rrc (IX+d) >23t<}
                r.bc.l:=self.getbyte(temp2);
                rrc_8(@r.bc.l);
                self.putbyte(temp2,r.bc.l);
            end;
        $0a:begin {ld D,rrc (IX+d) >23t<}
                r.de.h:=self.getbyte(temp2);
                rrc_8(@r.de.h);
                self.putbyte(temp2,r.de.h);
            end;
        $0b:begin {ld E,rrc (IX+d) >23t<}
                r.de.l:=self.getbyte(temp2);
                rrc_8(@r.de.l);
                self.putbyte(temp2,r.de.l);
            end;
        $0c:begin {ld H,rrc (IX+d) >23t<}
                r.hl.h:=self.getbyte(temp2);
                rrc_8(@r.hl.h);
                self.putbyte(temp2,r.hl.h);
            end;
        $0d:begin {ld L,rlc (IX+d) >23t<}
                r.hl.l:=self.getbyte(temp2);
                rrc_8(@r.hl.l);
                self.putbyte(temp2,r.hl.l);
            end;
        $0e:begin   {rrc (IX+d)}
                tempb:=self.getbyte(temp2);
                rrc_8(@tempb);
                self.putbyte(temp2,tempb);
            end;
        $0f:begin {ld A,rrc (IX+d)}
                r.a:=self.getbyte(temp2);
                rrc_8(@r.a);
                self.putbyte(temp2,r.a);
            end;
        $10:begin {ld B,rl (IX+d)}
                r.bc.h:=self.getbyte(temp2);
                rl_8(@r.bc.h);
                self.putbyte(temp2,r.bc.h);
            end;
        $11:begin {ld C,rl (IX+d)}
                r.bc.l:=self.getbyte(temp2);
                rl_8(@r.bc.l);
                self.putbyte(temp2,r.bc.l);
            end;
        $12:begin {ld D,rl (IX+d)}
                r.de.h:=self.getbyte(temp2);
                rl_8(@r.de.h);
                self.putbyte(temp2,r.de.h);
            end;
        $13:begin {ld E,rl (IX+d)}
                r.de.l:=self.getbyte(temp2);
                rl_8(@r.de.l);
                self.putbyte(temp2,r.de.l);
            end;
        $14:begin {ld H,rl (IX+d)}
                r.hl.h:=self.getbyte(temp2);
                rl_8(@r.hl.h);
                self.putbyte(temp2,r.hl.h);
            end;
        $15:begin {ld L,rlc (IX+d)}
                r.hl.l:=self.getbyte(temp2);
                rl_8(@r.hl.l);
                self.putbyte(temp2,r.hl.l);
            end;
        $16:begin {rl (IX+d)}
                tempb:=self.getbyte(temp2);
                rl_8(@tempb);
                self.putbyte(temp2,tempb);
            end;
        $17:begin {ld A,rl (IX+d)}
                r.a:=self.getbyte(temp2);
                rl_8(@r.a);
                self.putbyte(temp2,r.a);
            end;
        $18:begin {ld B,rr (IX+d)}
                r.bc.h:=self.getbyte(temp2);
                rr_8(@r.bc.h);
                self.putbyte(temp2,r.bc.h);
            end;
        $19:begin {ld C,rr (IX+d)}
                r.bc.l:=self.getbyte(temp2);
                rr_8(@r.bc.l);
                self.putbyte(temp2,r.bc.l);
            end;
        $1a:begin {ld D,rr (IX+d)}
                r.de.h:=self.getbyte(temp2);
                rr_8(@r.de.h);
                self.putbyte(temp2,r.de.h);
            end;
        $1b:begin {ld E,rr (IX+d)}
                r.de.l:=self.getbyte(temp2);
                rr_8(@r.de.l);
                self.putbyte(temp2,r.de.l);
            end;
        $1c:begin {ld H,rr (IX+d)}
                r.hl.h:=self.getbyte(temp2);
                rr_8(@r.hl.h);
                self.putbyte(temp2,r.hl.h);
            end;
        $1d:begin {ld L,rr (IX+d)}
                r.hl.l:=self.getbyte(temp2);
                rr_8(@r.hl.l);
                self.putbyte(temp2,r.hl.l);
            end;
        $1e:begin  {rr (IX+d)}
                tempb:=self.getbyte(temp2);
                rr_8(@tempb);
                self.putbyte(temp2,tempb);
            end;
        $1f:begin {ld A,rr (IX+d)}
                r.a:=self.getbyte(temp2);
                rr_8(@r.a);
                self.putbyte(temp2,r.a);
            end;
        $20:begin {ld B,sla (IX+d)}
                r.bc.h:=self.getbyte(temp2);
                sla_8(@r.bc.h);
                self.putbyte(temp2,r.bc.h);
            end;
        $21:begin {ld C,sla (IX+d)}
                r.bc.l:=self.getbyte(temp2);
                sla_8(@r.bc.l);
                self.putbyte(temp2,r.bc.l);
            end;
        $22:begin {ld D,sla (IX+d)}
                r.de.h:=self.getbyte(temp2);
                sla_8(@r.de.h);
                self.putbyte(temp2,r.de.h);
            end;
        $23:begin {ld E,sla (IX+d)}
                r.de.l:=self.getbyte(temp2);
                rlc_8(@r.de.l);
                self.putbyte(temp2,r.de.l);
            end;
        $24:begin {ld H,sla (IX+d)}
                r.hl.h:=self.getbyte(temp2);
                sla_8(@r.hl.h);
                self.putbyte(temp2,r.hl.h);
            end;
        $25:begin {ld L,sla (IX+d)}
                r.hl.l:=self.getbyte(temp2);
                sla_8(@r.hl.l);
                self.putbyte(temp2,r.hl.l);
            end;
        $26:begin  {sla (IX+d)}
                tempb:=self.getbyte(temp2);
                sla_8(@tempb);
                self.putbyte(temp2,tempb);
            end;
        $27:begin {ld A,sla (IX+d)}
                r.a:=self.getbyte(temp2);
                sla_8(@r.a);
                self.putbyte(temp2,r.a);
            end;
        $28:begin //ld B,sra (IX+d)
                r.bc.h:=self.getbyte(temp2);
                sra_8(@r.bc.h);
                self.putbyte(temp2,r.bc.h);
            end;
        $29:begin //ld C,sra (IX+d)
                r.bc.l:=self.getbyte(temp2);
                sra_8(@r.bc.l);
                self.putbyte(temp2,r.bc.l);
            end;
        $2a:begin //ld D,sra (IX+d)
                r.de.h:=self.getbyte(temp2);
                sra_8(@r.de.h);
                self.putbyte(temp2,r.de.h);
            end;
        $2b:begin //ld E,sra (IX+d)
                r.de.l:=self.getbyte(temp2);
                sra_8(@r.de.l);
                self.putbyte(temp2,r.de.l);
            end;
        $2c:begin //ld H,sra (IX+d)
                r.hl.h:=self.getbyte(temp2);
                sra_8(@r.hl.h);
                self.putbyte(temp2,r.hl.h);
            end;
        $2d:begin //ld L,sra (IX+d)
                r.hl.l:=self.getbyte(temp2);
                sra_8(@r.hl.l);
                self.putbyte(temp2,r.hl.l);
            end;
        $2e:begin  //sra (IX+d)
                tempb:=self.getbyte(temp2);
                sra_8(@tempb);
                self.putbyte(temp2,tempb);
            end;
        $2f:begin {ld A,sra (IX+d)}
                r.a:=self.getbyte(temp2);
                sra_8(@r.a);
                self.putbyte(temp2,r.a);
            end;
        $30:begin {ld B,sll (IX+d)}
                r.bc.h:=self.getbyte(temp2);
                sll_8(@r.bc.h);
                self.putbyte(temp2,r.bc.h);
            end;
        $31:begin {ld C,sll (IX+d)}
                r.bc.l:=self.getbyte(temp2);
                sll_8(@r.bc.l);
                self.putbyte(temp2,r.bc.l);
            end;
        $32:begin {ld D,sll (IX+d)}
                r.de.h:=self.getbyte(temp2);
                sll_8(@r.de.h);
                self.putbyte(temp2,r.de.h);
            end;
        $33:begin {ld E,sll (IX+d)}
                r.de.l:=self.getbyte(temp2);
                sll_8(@r.de.l);
                self.putbyte(temp2,r.de.l);
            end;
        $34:begin {ld H,sll (IX+d)}
                r.hl.h:=self.getbyte(temp2);
                sll_8(@r.hl.h);
                self.putbyte(temp2,r.hl.h);
            end;
        $35:begin {ld L,sll (IX+d)}
                r.hl.l:=self.getbyte(temp2);
                sll_8(@r.hl.l);
                self.putbyte(temp2,r.hl.l);
            end;
        $36:begin {sll (IX+d)}
                tempb:=self.getbyte(temp2);
                sll_8(@tempb);
                self.putbyte(temp2,tempb);
            end;
        $37:begin {ld A,sll (IX+d)}
                r.a:=self.getbyte(temp2);
                sll_8(@r.a);
                self.putbyte(temp2,r.a);
            end;
        $38:begin {ld B,srl (IX+d)}
                r.bc.h:=self.getbyte(temp2);
                srl_8(@r.bc.h);
                self.putbyte(temp2,r.bc.h);
            end;
        $39:begin {ld C,srl (IX+d)}
                r.bc.l:=self.getbyte(temp2);
                srl_8(@r.bc.l);
                self.putbyte(temp2,r.bc.l);
            end;
        $3a:begin {ld D,srl (IX+d)}
                r.de.h:=self.getbyte(temp2);
                srl_8(@r.de.h);
                self.putbyte(temp2,r.de.h);
            end;
        $3b:begin {ld E,srl (IX+d)}
                r.de.l:=self.getbyte(temp2);
                srl_8(@r.de.l);
                self.putbyte(temp2,r.de.l);
            end;
        $3c:begin {ld H,srl (IX+d)}
                r.hl.h:=self.getbyte(temp2);
                srl_8(@r.hl.h);
                self.putbyte(temp2,r.hl.h);
            end;
        $3d:begin {ld L,srl (IX+d)}
                r.hl.l:=self.getbyte(temp2);
                srl_8(@r.hl.l);
                self.putbyte(temp2,r.hl.l);
            end;
        $3e:begin  {srl (IX+d)}
                tempb:=self.getbyte(temp2);
                srl_8(@tempb);
                self.putbyte(temp2,tempb);
            end;
        $3f:begin {ld A,srl (IX+d)}
                r.a:=self.getbyte(temp2);
                srl_8(@r.a);
                self.putbyte(temp2,r.a);
            end;
        $40..$47:begin {bit 0,(IX+d)}
                 tempb:=self.getbyte(temp2);
                 bit_8(0,tempb);
                 r.f.bit5:=(temp2 and $2000)<>0;
                 r.f.bit3:=(temp2 and $800)<>0;
            end;
        $48..$4f:begin {bit 1,(IX+d)}
                 tempb:=self.getbyte(temp2);
                 bit_8(1,tempb);
                 r.f.bit5:=(temp2 and $2000)<>0;
                 r.f.bit3:=(temp2 and $800)<>0;
            end;
        $50..$57:begin {bit 2,(IX+d)}
                 tempb:=self.getbyte(temp2);
                 bit_8(2,tempb);
                 r.f.bit5:=(temp2 and $2000)<>0;
                 r.f.bit3:=(temp2 and $800)<>0;
            end;
        $58..$5f:begin {bit 3,(IX+d)}
                 tempb:=self.getbyte(temp2);
                 bit_8(3,tempb);
                 r.f.bit5:=(temp2 and $2000)<>0;
                 r.f.bit3:=(temp2 and $800)<>0;
            end;
        $60..$67:begin {bit 4,(IX+d)}
                 tempb:=self.getbyte(temp2);
                 bit_8(4,tempb);
                 r.f.bit5:=(temp2 and $2000)<>0;
                 r.f.bit3:=(temp2 and $800)<>0;
            end;
        $68..$6f:begin {bit 5,(IX+d)}
                 tempb:=self.getbyte(temp2);
                 bit_8(5,tempb);
                 r.f.bit5:=(temp2 and $2000)<>0;
                 r.f.bit3:=(temp2 and $800)<>0;
            end;
        $70..$77:begin {bit 6,(IX+d)}
                 tempb:=self.getbyte(temp2);
                 bit_8(6,tempb);
                 r.f.bit5:=(temp2 and $2000)<>0;
                 r.f.bit3:=(temp2 and $800)<>0;
            end;
        $78..$7f:begin {bit 7,(IX+d)}
                 tempb:=self.getbyte(temp2);
                 bit_7(tempb);
                 r.f.bit5:=(temp2 and $2000)<>0;
                 r.f.bit3:=(temp2 and $800)<>0;
            end;
        $80:begin {ld B,res 0,(IX+d)}
                 r.bc.h:=self.getbyte(temp2) and $fe;
                 self.putbyte(temp2,r.bc.h);
            end;
        $81:begin {ld C,res 0,(IX+d)}
                 r.bc.l:=self.getbyte(temp2) and $fe;
                 self.putbyte(temp2,r.bc.l);
            end;
        $82:begin {ld D,res 0,(IX+d)}
                 r.de.h:=self.getbyte(temp2) and $fe;
                 self.putbyte(temp2,r.de.h);
            end;
        $83:begin {ld E,res 0,(IX+d)}
                 r.de.l:=self.getbyte(temp2) and $fe;
                 self.putbyte(temp2,r.de.l);
            end;
        $84:begin {ld H,res 0,(IX+d)}
                 r.hl.h:=self.getbyte(temp2) and $fe;
                 self.putbyte(temp2,r.hl.h);
            end;
        $85:begin {ld L,res 0,(IX+d)}
                 r.hl.l:=self.getbyte(temp2) and $fe;
                 self.putbyte(temp2,r.hl.l);
            end;
        $86:begin {res 0,(IX+d)}
                 tempb:=self.getbyte(temp2) and $fe;
                 self.putbyte(temp2,tempb);
            end;
        $87:begin		// LD A,RES 0,(REGISTER+dd) */
                  r.a:=self.getbyte(temp2) and $fe;
                  self.putbyte(temp2,r.a);
            end;
        $88:begin		// LD B,RES 1,(REGISTER+dd) */
                  r.bc.h:=self.getbyte(temp2) and $fd;
                  self.putbyte(temp2,r.bc.h);
            end;
        $89:begin		// LD C,RES 1,(REGISTER+dd) */
                  r.bc.l:=self.getbyte(temp2) and $fd;
                  self.putbyte(temp2,r.bc.l);
            end;
        $8a:begin		// LD D,RES 1,(REGISTER+dd) */
                  r.de.h:=self.getbyte(temp2) and $fd;
                  self.putbyte(temp2,r.de.h);
            end;
        $8b:begin		// LD E,RES 1,(REGISTER+dd) */
                  r.de.l:=self.getbyte(temp2) and $fd;
                  self.putbyte(temp2,r.de.l);
            end;
        $8c:begin		// LD H,RES 1,(REGISTER+dd) */
                  r.hl.h:=self.getbyte(temp2) and $fd;
                  self.putbyte(temp2,r.hl.h);
            end;
        $8d:begin		// LD L,RES 1,(REGISTER+dd) */
                  r.hl.l:=self.getbyte(temp2) and $fd;
                  self.putbyte(temp2,r.hl.l);
            end;
        $8e:begin {res 1,(IX+d)}
                 tempb:=self.getbyte(temp2) and $fd;
                 self.putbyte(temp2,tempb);
            end;
        $8f:begin {ld A,res 1,(IX+d)}
                 r.a:=self.getbyte(temp2) and $fd;
                 self.putbyte(temp2,r.a);
            end;
        $90:begin {ld B,res 2,(IX+d)}
                 r.bc.h:=self.getbyte(temp2) and $fb;
                 self.putbyte(temp2,r.bc.h);
            end;
        $91:begin {ld C,res 2,(IX+d)}
                 r.bc.l:=self.getbyte(temp2) and $fb;
                 self.putbyte(temp2,r.bc.l);
            end;
        $92:begin {ld D,res 2,(IX+d)}
                 r.de.h:=self.getbyte(temp2) and $fb;
                 self.putbyte(temp2,r.de.h);
            end;
        $93:begin {ld E,res 2,(IX+d)}
                 r.de.l:=self.getbyte(temp2) and $fb;
                 self.putbyte(temp2,r.de.l);
            end;
        $94:begin {ld H,res 2,(IX+d)}
                 r.hl.h:=self.getbyte(temp2) and $fb;
                 self.putbyte(temp2,r.hl.h);
            end;
        $95:begin {ld L,res 2,(IX+d)}
                 r.hl.l:=self.getbyte(temp2) and $fb;
                 self.putbyte(temp2,r.hl.l);
            end;
        $96:begin {res 2,(IX+d)}
                 tempb:=self.getbyte(temp2) and $fb;
                 self.putbyte(temp2,tempb);
            end;
        $97:begin {ld A,res 2,(IX+d)}
                 r.a:=self.getbyte(temp2) and $fb;
                 self.putbyte(temp2,r.a);
            end;
        $98:begin {ld B,res 3,(IX+d)}
                 r.bc.h:=self.getbyte(temp2) and $f7;
                 self.putbyte(temp2,r.bc.h);
            end;
        $99:begin {ld C,res 3,(IX+d)}
                 r.bc.l:=self.getbyte(temp2) and $f7;
                 self.putbyte(temp2,r.bc.l);
            end;
        $9a:begin {ld D,res 3,(IX+d)}
                 r.de.h:=self.getbyte(temp2) and $f7;
                 self.putbyte(temp2,r.de.h);
            end;
        $9b:begin {ld E,res 3,(IX+d)}
                 r.de.l:=self.getbyte(temp2) and $f7;
                 self.putbyte(temp2,r.de.l);
            end;
        $9c:begin {ld H,res 3,(IX+d)}
                 r.hl.h:=self.getbyte(temp2) and $f7;
                 self.putbyte(temp2,r.hl.h);
            end;
        $9d:begin {ld L,res 3,(IX+d)}
                 r.hl.l:=self.getbyte(temp2) and $f7;
                 self.putbyte(temp2,r.hl.l);
            end;
        $9e:begin {res 3,(IX+d)}
                 tempb:=self.getbyte(temp2) and $f7;
                 self.putbyte(temp2,tempb);
            end;
        $9f:begin {ld A,res 3,(IX+d)}
                 r.a:=self.getbyte(temp2) and $f7;
                 self.putbyte(temp2,r.a);
            end;
        $a0:begin {ld B,res 4,(IX+d)}
                 r.bc.h:=self.getbyte(temp2) and $ef;
                 self.putbyte(temp2,r.bc.h);
            end;
        $a1:begin {ld C,res 4,(IX+d)}
                 r.bc.l:=self.getbyte(temp2) and $ef;
                 self.putbyte(temp2,r.bc.l);
            end;
        $a2:begin {ld D,res 4,(IX+d)}
                 r.de.h:=self.getbyte(temp2) and $ef;
                 self.putbyte(temp2,r.de.h);
            end;
        $a3:begin {ld E,res 4,(IX+d)}
                 r.de.l:=self.getbyte(temp2) and $ef;
                 self.putbyte(temp2,r.de.l);
            end;
        $a4:begin {ld H,res 4,(IX+d)}
                 r.hl.h:=self.getbyte(temp2) and $ef;
                 self.putbyte(temp2,r.hl.h);
            end;
        $a5:begin {ld L,res 4,(IX+d)}
                 r.hl.l:=self.getbyte(temp2) and $ef;
                 self.putbyte(temp2,r.hl.l);
            end;
        $a6:begin {res 4,(IX+d)}
                 tempb:=self.getbyte(temp2) and $ef;
                 self.putbyte(temp2,tempb);
            end;
        $a7:begin {ld A,res 4,(IX+d)}
                 r.a:=self.getbyte(temp2) and $ef;
                 self.putbyte(temp2,r.a);
            end;
        $a8:begin {ld B,res 5,(IX+d)}
                 r.bc.h:=self.getbyte(temp2) and $df;
                 self.putbyte(temp2,r.bc.h);
            end;
        $a9:begin {ld C,res 5,(IX+d)}
                 r.bc.l:=self.getbyte(temp2) and $df;
                 self.putbyte(temp2,r.bc.l);
            end;
        $aa:begin {ld D,res 5,(IX+d)}
                 r.de.h:=self.getbyte(temp2) and $df;
                 self.putbyte(temp2,r.de.h);
            end;
        $ab:begin {ld E,res 5,(IX+d)}
                 r.de.l:=self.getbyte(temp2) and $df;
                 self.putbyte(temp2,r.de.l);
            end;
        $ac:begin {ld H,res 5,(IX+d)}
                 r.hl.h:=self.getbyte(temp2) and $df;
                 self.putbyte(temp2,r.hl.h);
            end;
        $ad:begin {ld L,res 5,(IX+d)}
                 r.hl.l:=self.getbyte(temp2) and $df;
                 self.putbyte(temp2,r.hl.l);
            end;
        $ae:begin {res 5,(IX+d)}
                 tempb:=self.getbyte(temp2) and $df;
                 self.putbyte(temp2,tempb);
            end;
        $af:begin {ld A,res 5,(IX+d)}
                 r.a:=self.getbyte(temp2) and $df;
                 self.putbyte(temp2,r.a);
            end;
        $b0:begin {ld B,res 6,(IX+d)}
                 r.bc.h:=self.getbyte(temp2) and $bf;
                 self.putbyte(temp2,r.bc.h);
            end;
        $b1:begin {ld C,res 6,(IX+d)}
                 r.bc.l:=self.getbyte(temp2) and $bf;
                 self.putbyte(temp2,r.bc.l);
            end;
        $b2:begin {ld D,res 6,(IX+d)}
                 r.de.h:=self.getbyte(temp2) and $bf;
                 self.putbyte(temp2,r.de.h);
            end;
        $b3:begin {ld E,res 6,(IX+d)}
                 r.de.l:=self.getbyte(temp2) and $bf;
                 self.putbyte(temp2,r.de.l);
            end;
        $b4:begin {ld H,res 6,(IX+d)}
                 r.hl.h:=self.getbyte(temp2) and $bf;
                 self.putbyte(temp2,r.hl.h);
            end;
        $b5:begin {ld L,res 6,(IX+d)}
                 r.hl.l:=self.getbyte(temp2) and $bf;
                 self.putbyte(temp2,r.hl.l);
            end;
        $b6:begin {res 6,(IX+d)}
                 tempb:=self.getbyte(temp2) and $bf;
                 self.putbyte(temp2,tempb);
            end;
        $b7:begin {ld A,res 6,(IX+d)}
                 r.a:=self.getbyte(temp2) and $bf;
                 self.putbyte(temp2,r.a);
            end;
        $b8:begin {ld B,res 7,(IX+d)}
                 r.bc.h:=self.getbyte(temp2) and $7f;
                 self.putbyte(temp2,r.bc.h);
            end;
        $b9:begin {ld C,res 7,(IX+d)}
                 r.bc.l:=self.getbyte(temp2) and $7f;
                 self.putbyte(temp2,r.bc.l);
            end;
        $ba:begin {ld D,res 7,(IX+d)}
                 r.de.h:=self.getbyte(temp2) and $7f;
                 self.putbyte(temp2,r.de.h);
            end;
        $bb:begin {ld E,res 7,(IX+d)}
                 r.de.l:=self.getbyte(temp2) and $7f;
                 self.putbyte(temp2,r.de.l);
            end;
        $bc:begin {ld H,res 7,(IX+d)}
                 r.hl.h:=self.getbyte(temp2) and $7f;
                 self.putbyte(temp2,r.hl.h);
            end;
        $bd:begin {ld L,res 7,(IX+d)}
                 r.hl.l:=self.getbyte(temp2) and $7f;
                 self.putbyte(temp2,r.hl.l);
            end;
        $be:begin {res 7,(IX+d)}
                 tempb:=self.getbyte(temp2) and $7f;
                 self.putbyte(temp2,tempb);
            end;
        $bf:begin {ld A,res 7,(IX+d)}
                 r.a:=self.getbyte(temp2) and $7f;
                 self.putbyte(temp2,r.a);
            end;
        $c0:begin {ld B,set 0,(IX+d)}
                 r.bc.h:=self.getbyte(temp2) or 1;
                 self.putbyte(temp2,r.bc.h);
            end;
        $c1:begin {ld C,set 0,(IX+d)}
                 r.bc.l:=self.getbyte(temp2) or 1;
                 self.putbyte(temp2,r.bc.l);
            end;
        $c2:begin {ld D,set 0,(IX+d)}
                 r.de.h:=self.getbyte(temp2) or 1;
                 self.putbyte(temp2,r.de.h);
            end;
        $c3:begin {ld E,set 0,(IX+d)}
                 r.de.l:=self.getbyte(temp2) or 1;
                 self.putbyte(temp2,r.de.l);
            end;
        $c4:begin {ld H,set 0,(IX+d)}
                 r.hl.h:=self.getbyte(temp2) or 1;
                 self.putbyte(temp2,r.hl.h);
            end;
        $c5:begin {ld L,set 0,(IX+d)}
                 r.hl.l:=self.getbyte(temp2) or 1;
                 self.putbyte(temp2,r.hl.l);
            end;
        $c6:begin {set 0,(IX+d)}
                 tempb:=self.getbyte(temp2) or 1;
                 self.putbyte(temp2,tempb);
              end;
        $c7:begin {ld A,set 0,(IX+d)}
                 r.a:=self.getbyte(temp2) or 1;
                 self.putbyte(temp2,r.a);
            end;
        $c8:begin {ld B,set 1,(IX+d)}
                 r.bc.h:=self.getbyte(temp2) or 2;
                 self.putbyte(temp2,r.bc.h);
            end;
        $c9:begin {ld C,set 1,(IX+d)}
                 r.bc.l:=self.getbyte(temp2) or 2;
                 self.putbyte(temp2,r.bc.l);
            end;
        $ca:begin {ld D,set 1,(IX+d)}
                 r.de.h:=self.getbyte(temp2) or 2;
                 self.putbyte(temp2,r.de.h);
            end;
        $cb:begin {ld E,set 1,(IX+d)}
                 r.de.l:=self.getbyte(temp2) or 2;
                 self.putbyte(temp2,r.de.l);
            end;
        $cc:begin {ld H,set 1,(IX+d)}
                 r.hl.h:=self.getbyte(temp2) or 2;
                 self.putbyte(temp2,r.hl.h);
            end;
        $cd:begin {ld L,set 1,(IX+d)}
                 r.hl.l:=self.getbyte(temp2) or 2;
                 self.putbyte(temp2,r.hl.l);
            end;
        $ce:begin {set 1,(IX+d)}
                 tempb:=self.getbyte(temp2) or 2;
                 self.putbyte(temp2,tempb);
              end;

        $cf:begin {ld A,set 1,(IX+d)}
                 r.a:=self.getbyte(temp2) or 2;
                 self.putbyte(temp2,r.a);
            end;
        $d0:begin {ld B,set 2,(IX+d)}
                 r.bc.h:=self.getbyte(temp2) or 4;
                 self.putbyte(temp2,r.bc.h);
            end;
        $d1:begin {ld C,set 2,(IX+d)}
                 r.bc.l:=self.getbyte(temp2) or 4;
                 self.putbyte(temp2,r.bc.l);
            end;
        $d2:begin {ld D,set 2,(IX+d)}
                 r.de.h:=self.getbyte(temp2) or 4;
                 self.putbyte(temp2,r.de.h);
            end;
        $d3:begin {ld E,set 2,(IX+d)}
                 r.de.l:=self.getbyte(temp2) or 4;
                 self.putbyte(temp2,r.de.l);
            end;
        $d4:begin {ld H,set 2,(IX+d)}
                 r.hl.h:=self.getbyte(temp2) or 4;
                 self.putbyte(temp2,r.hl.h);
            end;
        $d5:begin {ld L,set 2,(IX+d)}
                 r.hl.l:=self.getbyte(temp2) or 4;
                 self.putbyte(temp2,r.hl.l);
            end;
        $d6:begin {set 2,(IX+d)}
                 tempb:=self.getbyte(temp2) or 4;
                 self.putbyte(temp2,tempb);
              end;
        $d7:begin {ld A,set 2,(IX+d)}
                 r.a:=self.getbyte(temp2) or 4;
                 self.putbyte(temp2,r.a);
            end;
        $d8:begin {ld B,set 3,(IX+d)}
                 r.bc.h:=self.getbyte(temp2) or 8;
                 self.putbyte(temp2,r.bc.h);
            end;
        $d9:begin {ld C,set 3,(IX+d)}
                 r.bc.l:=self.getbyte(temp2) or 8;
                 self.putbyte(temp2,r.bc.l);
            end;
        $da:begin {ld D,set 3,(IX+d)}
                 r.de.h:=self.getbyte(temp2) or 8;
                 self.putbyte(temp2,r.de.h);
            end;
        $db:begin {ld E,set 3,(IX+d)}
                 r.de.l:=self.getbyte(temp2) or 8;
                 self.putbyte(temp2,r.de.l);
            end;
        $dc:begin {ld H,set 3,(IX+d)}
                 r.hl.h:=self.getbyte(temp2) or 8;
                 self.putbyte(temp2,r.hl.h);
            end;
        $dd:begin {ld L,set 3,(IX+d)}
                 r.hl.l:=self.getbyte(temp2) or 8;
                 self.putbyte(temp2,r.hl.l);
            end;
        $de:begin {set 3,(IX+d)}
                 tempb:=self.getbyte(temp2) or 8;
                 self.putbyte(temp2,tempb);
              end;
        $df:begin {ld A,set 3,(IX+d)}
                 r.a:=self.getbyte(temp2) or 8;
                 self.putbyte(temp2,r.a);
            end;
        $e0:begin {ld B,set 4,(IX+d)}
                 r.bc.h:=self.getbyte(temp2) or $10;
                 self.putbyte(temp2,r.bc.h);
            end;
        $e1:begin {ld C,set 4,(IX+d)}
                 r.bc.l:=self.getbyte(temp2) or $10;
                 self.putbyte(temp2,r.bc.l);
            end;
        $e2:begin {ld D,set 4,(IX+d)}
                 r.de.h:=self.getbyte(temp2) or $10;
                 self.putbyte(temp2,r.de.h);
            end;
        $e3:begin {ld E,set 4,(IX+d)}
                 r.de.l:=self.getbyte(temp2) or $10;
                 self.putbyte(temp2,r.de.l);
            end;
        $e4:begin {ld H,set 4,(IX+d)}
                 r.hl.h:=self.getbyte(temp2) or $10;
                 self.putbyte(temp2,r.hl.h);
            end;
        $e5:begin {ld L,set 4,(IX+d)}
                 r.hl.l:=self.getbyte(temp2) or $10;
                 self.putbyte(temp2,r.hl.l);
            end;
        $e6:begin {set 4,(IX+d)}
                 tempb:=self.getbyte(temp2) or $10;
                 self.putbyte(temp2,tempb);
              end;
        $e7:begin {ld A,set 4,(IX+d)}
                 r.a:=self.getbyte(temp2) or $10;
                 self.putbyte(temp2,r.a);
            end;
        $e8:begin {ld B,set 5,(IX+d)}
                 r.bc.h:=self.getbyte(temp2) or $20;
                 self.putbyte(temp2,r.bc.h);
            end;
        $e9:begin {ld C,set 5,(IX+d)}
                 r.bc.l:=self.getbyte(temp2) or $20;
                 self.putbyte(temp2,r.bc.l);
            end;
        $ea:begin {ld D,set 5,(IX+d)}
                 r.de.h:=self.getbyte(temp2) or $20;
                 self.putbyte(temp2,r.de.h);
            end;
        $eb:begin {ld E,set 5,(IX+d)}
                 r.de.l:=self.getbyte(temp2) or $20;
                 self.putbyte(temp2,r.de.l);
            end;
        $ec:begin {ld H,set 5,(IX+d)}
                 r.hl.h:=self.getbyte(temp2) or $20;
                 self.putbyte(temp2,r.hl.h);
            end;
        $ed:begin {ld L,set 5,(IX+d)}
                 r.hl.l:=self.getbyte(temp2) or $20;
                 self.putbyte(temp2,r.hl.l);
            end;
        $ee:begin {set 5,(IX+d)}
                 tempb:=self.getbyte(temp2) or $20;
                 self.putbyte(temp2,tempb);
              end;
        $ef:begin {ld A,set 5,(IX+d)}
                 r.a:=self.getbyte(temp2) or $20;
                 self.putbyte(temp2,r.a);
            end;
        $f0:begin {ld B,set 6,(IX+d)}
                 r.bc.h:=self.getbyte(temp2) or $40;
                 self.putbyte(temp2,r.bc.h);
            end;
        $f1:begin {ld C,set 6,(IX+d)}
                 r.bc.l:=self.getbyte(temp2) or $40;
                 self.putbyte(temp2,r.bc.l);
            end;
        $f2:begin {ld D,set 6,(IX+d)}
                 r.de.h:=self.getbyte(temp2) or $40;
                 self.putbyte(temp2,r.de.h);
            end;
        $f3:begin {ld E,set 6,(IX+d)}
                 r.de.l:=self.getbyte(temp2) or $40;
                 self.putbyte(temp2,r.de.l);
            end;
        $f4:begin {ld H,set 6,(IX+d)}
                 r.hl.h:=self.getbyte(temp2) or $40;
                 self.putbyte(temp2,r.hl.h);
            end;
        $f5:begin {ld L,set 6,(IX+d)}
                 r.hl.l:=self.getbyte(temp2) or $40;
                 self.putbyte(temp2,r.hl.l);
            end;
        $f6:begin {set 6,(IX+d)}
                 tempb:=self.getbyte(temp2) or $40;
                 self.putbyte(temp2,tempb);
              end;
        $f7:begin {ld A,set 6,(IX+d)}
                 r.a:=self.getbyte(temp2) or $40;
                 self.putbyte(temp2,r.a);
            end;
        $f8:begin {ld B,set 7,(IX+d)}
                 r.bc.h:=self.getbyte(temp2) or $80;
                 self.putbyte(temp2,r.bc.h);
            end;
        $f9:begin {ld C,set 7,(IX+d)}
                 r.bc.l:=self.getbyte(temp2) or $80;
                 self.putbyte(temp2,r.bc.l);
            end;
        $fa:begin {ld D,set 7,(IX+d)}
                 r.de.h:=self.getbyte(temp2) or $80;
                 self.putbyte(temp2,r.de.h);
            end;
        $fb:begin {ld E,set 7,(IX+d)}
                 r.de.l:=self.getbyte(temp2) or $80;
                 self.putbyte(temp2,r.de.l);
            end;
        $fc:begin {ld H,set 7,(IX+d)}
                 r.hl.h:=self.getbyte(temp2) or $80;
                 self.putbyte(temp2,r.hl.h);
            end;
        $fd:begin {ld L,set 7,(IX+d)}
                 r.hl.l:=self.getbyte(temp2) or $80;
                 self.putbyte(temp2,r.hl.l);
            end;
        $fe:begin {set 7,(IX+d)}
                 tempb:=self.getbyte(temp2) or $80;
                 self.putbyte(temp2,tempb);
              end;
        $ff:begin {ld A,set 7,(IX+d)}
                 r.a:=self.getbyte(temp2) or $80;
                 self.putbyte(temp2,r.a);
            end;
end;
exec_dd_cb:=z80t_ddcb[instruccion];
end;

function cpu_z80.exec_ed:byte;
var
        instruccion,temp,temp2,temp3:byte;
        posicion:parejas;
        estados_demas:byte;
        tempw:word;
begin
estados_demas:=0;
self.opcode:=true;
instruccion:=self.getbyte(r.pc);
self.opcode:=false;
r.pc:=r.pc+1;
r.r:=((r.r+1) and $7f) or (r.r and $80);
case instruccion of
        $00..$3f,$77,$7f..$9f,$a4..$a7,$ac..$af,$b4..$b7,$bc..$ff:; {nop*2}
        $40:begin {in B,(c)}
                if @self.in_port<>nil then r.bc.h:=self.in_port(r.bc.w)
                  else r.bc.h:=$ff;
                r.f.z:=(r.bc.h=0);
                r.f.s:=(r.bc.h And $80) <> 0;
                r.f.bit3:=(r.bc.h And 8) <> 0;
                r.f.bit5:=(r.bc.h And $20) <> 0;
                r.f.p_v:= paridad[r.bc.h];
                r.f.n:=false;
                r.f.h:=false;
            end;
        $41:if @self.out_port<>nil then self.out_port(r.bc.w,r.bc.h); {out (C),B}
        $42:r.hl.w:=sbc_hl(r.bc.w); //sbc HL,BC
        $43:begin {ld (nn),BC}
                posicion.h:=self.getbyte(r.pc+1);
                posicion.l:=self.getbyte(r.pc);
                r.pc:=r.pc+2;
                self.putbyte(posicion.w,r.bc.l);
                self.putbyte(posicion.w+1,r.bc.h);
                r.wz:=posicion.w+1;
            end;
        $44,$4c,$54,$5c,$64,$6c,$74,$7c:begin  {neg}
                temp:=r.a;
                r.a:=0;
                sub_8(temp);
            end;
        $45,$55,$65,$75:begin  {retn}
                r.pc:=pop_sp;
                r.wz:=r.pc;
                r.iff1:=r.iff2;
            end;
        $46,$4e,$66,$6e:r.im:=0; {im 0}
        $47:r.i:=r.a;  {ld I,A}
        $48:begin {in C,(C)}
                if @self.in_port<>nil then r.bc.l:=self.in_port(r.bc.w)
                  else r.bc.l:=$ff;
                r.f.z:=(r.bc.l=0);
                r.f.s:=(r.bc.l And $80) <> 0;
                r.f.bit3:=(r.bc.l And 8) <> 0;
                r.f.bit5:=(r.bc.l And $20) <> 0;
                r.f.p_v:=paridad[r.bc.l];
                r.f.n:=false;
                r.f.h:=false;
            end;
        $49:if @self.out_port<>nil then self.out_port(r.bc.w,r.bc.l); {out (C),C}
        $4a:r.hl.w:=adc_hl(r.bc.w); //adc HL,BC
        $4b:begin  {ld BC,(nn)}
                posicion.h:=self.getbyte(r.pc+1);
                posicion.l:=self.getbyte(r.pc);
                r.pc:=r.pc+2;;
                r.bc.l:=self.getbyte(posicion.w);
                r.bc.h:=self.getbyte(posicion.w+1);
                r.wz:=posicion.w+1;
            end;
        {4c: neg}
        $4d,$5d,$6d,$7d:begin   {reti}
                r.iff1:=r.iff2;
                r.pc:=pop_sp;
                r.wz:=r.pc;
                if self.daisy then z80daisy_reti;
            end;
        {4e: im 0}
        $4f:r.r:=r.a; {ld R,A}
        $50:begin {in D,(c)}
                if @self.in_port<>nil then r.de.h:=self.in_port(r.bc.w)
                  else r.de.h:=$ff;
                r.f.z:=(r.de.h=0);
                r.f.s:=(r.de.h And $80) <> 0;
                r.f.bit3:=(r.de.h And 8) <> 0;
                r.f.bit5:=(r.de.h And $20) <> 0;
                r.f.p_v:= paridad[r.de.h];
                r.f.n:=false;
                r.f.h:=false;
            end;
        $51:if @self.out_port<>nil then self.out_port(r.bc.w,r.de.h); {out (C),D}
        $52:r.hl.w:=sbc_hl(r.de.w); //sbc HL,DE
        $53:begin {ld (nn),DE}
                posicion.h:=self.getbyte(r.pc+1);
                posicion.l:=self.getbyte(r.pc);
                r.pc:=r.pc+2;;
                self.putbyte(posicion.w,r.de.l);
                self.putbyte(posicion.w+1,r.de.h);
                r.wz:=posicion.w+1;
            end;
        {54: neg
        $55:retn}
        $56,$76:r.im:=1; {im 1}
        $57:begin  {ld A,I}
                r.a:=r.i;
                r.f.s:=false;
                r.f.z:=(r.a=0);
                r.f.bit5:=false;
                r.f.h:=false;
                r.f.bit3:=false;
                r.f.p_v:=r.iff2;
                r.f.n:=false;
            end;
        $58:begin  {in E,(C)}
                if @self.in_port<>nil then r.de.l:=self.in_port(r.bc.w)
                  else r.de.l:=$ff;
                r.f.z:=(r.de.l=0);
                r.f.s:=(r.de.l And $80) <> 0;
                r.f.bit3:=(r.de.l And 8) <> 0;
                r.f.bit5:=(r.de.l And $20) <> 0;
                r.f.p_v:= paridad[r.de.l];
                r.f.n:=false;
                r.f.h:=false;
            end;
        $59:if @self.out_port<>nil then self.out_port(r.bc.w,r.de.l); {out (C),E}
        $5a:r.hl.w:=adc_hl(r.de.w); //adc HL,DE
        $5b:begin  {ld DE,(nn)}
                posicion.h:=self.getbyte(r.pc+1);
                posicion.l:=self.getbyte(r.pc);
                r.pc:=r.pc+2;;
                r.de.l:=self.getbyte(posicion.w);
                r.de.h:=self.getbyte(posicion.w+1);
                r.wz:=posicion.w+1;
            end;
        {5c:neg
        5d:reti}
        $5e,$7e:r.im:=2; {im 2}
        $5f:begin  {ld A,R}
                r.a:=r.r;
                r.f.h:=false;
                r.f.n:=false;
                r.f.p_v:=r.iff2;
                r.f.bit5:=false;
                r.f.bit3:=false;
                r.f.s:=false;
                r.f.z:=(r.a=0);
            end;
        $60:begin  {in H,(c)}
                if @self.in_port<>nil then r.hl.h:=self.in_port(r.bc.w)
                  else r.hl.h:=$ff;
                r.f.z:=(r.hl.h=0);
                r.f.s:=(r.hl.h And $80) <> 0;
                r.f.bit3:=(r.hl.h And 8) <> 0;
                r.f.bit5:=(r.hl.h And $20) <> 0;
                r.f.p_v:= paridad[r.hl.h];
                r.f.n:=false;
                r.f.h:=false;
            end;
        $61:if @self.out_port<>nil then self.out_port(r.bc.w,r.hl.h); {out (C),H}
        $62:r.hl.w:=sbc_hl(r.hl.w); //sbc HL,HL
        $63:begin {ld (nn),HL}
                posicion.h:=self.getbyte(r.pc+1);
                posicion.l:=self.getbyte(r.pc);
                r.pc:=r.pc+2;;
                self.putbyte(posicion.w,r.hl.l);
                self.putbyte(posicion.w+1,r.hl.h);
                r.wz:=posicion.w+1;
            end;
        {64:neg
        $65:retn
        $66:im 0}
        $67:begin //rrd
                temp2:=self.getbyte(r.hl.w);
                r.wz:=r.hl.w+1;
                temp:=(r.a and $F)*16;
                r.a:=(r.a and $F0)+ (temp2 and $F);
                temp2:=(temp2 div 16) + temp;
                self.putbyte(r.hl.w,temp2);
                r.f.s:=(r.a and $80)<>0;
                r.f.z:=(r.a=0);
                r.f.bit5:=(r.a and $20)<>0;
                r.f.h:=false;
                r.f.bit3:=(r.a and 8)<>0;
                r.f.p_v:=paridad[r.a];
                r.f.n:=false;
            end;
        $68:begin {in L,(c)}
                if @self.in_port<>nil then r.hl.l:=self.in_port(r.bc.w)
                  else r.hl.l:=$ff;
                r.f.z:=(r.hl.l=0);
                r.f.s:=(r.hl.l And $80) <> 0;
                r.f.bit3:=(r.hl.l And 8) <> 0;
                r.f.bit5:=(r.hl.l And $20) <> 0;
                r.f.p_v:= paridad[r.hl.l];
                r.f.n:=false;
                r.f.h:=false;
             end;
        $69:if @self.out_port<>nil then self.out_port(r.bc.w,r.hl.l); {out (C),L}
        $6a:r.hl.w:=adc_hl(r.hl.w); //adc HL,HL
        $6b:begin  {ld HL,(nn)}
                posicion.h:=self.getbyte(r.pc+1);
                posicion.l:=self.getbyte(r.pc);
                r.pc:=r.pc+2;;
                r.hl.l:=self.getbyte(posicion.w);
                r.hl.h:=self.getbyte(posicion.w+1);
                r.wz:=posicion.w+1;
            end;
        {6c:neg
        $6d:reti
        $6e:im 0}
        $6f:begin  //rld
                temp2:=self.getbyte(r.hl.w);
                r.wz:=r.hl.w+1;
                temp:=r.a and $0f;
                r.a:=(r.a  and $F0)+ (temp2 div 16);
                temp2:=(temp2*16) + temp;
                self.putbyte(r.hl.w,temp2);
                r.f.s:=(r.a and $80)<>0;
                r.f.z:=(r.a=0);
                r.f.bit5:=(r.a and $20)<>0;
                r.f.h:=false;
                r.f.bit3:=(r.a and 8)<>0;
                r.f.p_v:=paridad[r.a];
                r.f.n:=false;
            end;
        $70:begin  {in (C)}
                if @self.in_port<>nil then temp:=self.in_port(r.bc.w)
                  else temp:=$ff;
                r.f.z:=(temp=0);
                r.f.s:=(temp And $80) <> 0;
                r.f.bit3:=(temp And 8) <> 0;
                r.f.bit5:=(temp And $20) <> 0;
                r.f.p_v:= paridad[temp];
                r.f.n:=false;
                r.f.h:=false;
            end;
        $71:if @self.out_port<>nil then self.out_port(r.bc.w,0); {out (C),0}
        $72:r.hl.w:=sbc_hl(r.sp); //sbc HL,SP
        $73:begin {ld (nn),SP}
                posicion.h:=self.getbyte(r.pc+1);
                posicion.l:=self.getbyte(r.pc);
                r.pc:=r.pc+2;;
                self.putbyte(posicion.w,r.sp and $ff);
                self.putbyte(posicion.w+1,r.sp shr 8);
                r.wz:=posicion.w+1;
            end;
        {74:neg
        $75:retn
        $76:im 1
        $77:nop*2}
        $78:begin  //in A,(C)
                if @self.in_port<>nil then r.a:=self.in_port(r.bc.w)
                  else r.a:=$ff;
                r.f.z:=(r.a=0);
                r.f.s:=(r.a And $80) <> 0;
                r.f.bit3:=(r.a And 8) <> 0;
                r.f.bit5:=(r.a And $20) <> 0;
                r.f.p_v:= paridad[r.a];
                r.f.n:=false;
                r.f.h:=false;
                r.wz:=r.bc.w+1;
            end;
        $79:begin  //out (C),A
                if @self.out_port<>nil then self.out_port(r.bc.w,r.a);
                r.wz:=r.bc.w+1;
            end;
        $7a:r.hl.w:=adc_hl(r.sp); //adc HL,SP
        $7b:begin  {ld SP,(nn)}
                posicion.h:=self.getbyte(r.pc+1);
                posicion.l:=self.getbyte(r.pc);
                r.pc:=r.pc+2;;
                r.sp:=self.getbyte(posicion.w)+(self.getbyte(posicion.w+1) shl 8);
                r.wz:=posicion.w+1;
            end;
        {7c:neg
        $7d:reti
        $7e:im 2
        $7f..9c:nop*2}
        $a0:begin   //ldi
                 temp:=self.getbyte(r.hl.w);
                 r.hl.w:=r.hl.w+1;
                 self.putbyte(r.de.w,temp);
                 r.de.w:=r.de.w+1;
                 r.bc.w:=r.bc.w-1;
                 r.f.p_v:=(r.bc.w<>0);
                 r.f.n:=false;
                 r.f.h:=false;
                 temp:=temp+r.a;
                 r.f.bit5:=(temp and 2)<>0;
                 r.f.bit3:=(temp and 8)<>0;
            end;
        $a1:begin  //cpi el primer programa que lo usa una demo!!!
                 //08 de feb 2003
                 temp2:=self.getbyte(r.hl.w);
                 temp:=r.a-temp2;
                 temp3:=r.a xor temp2 xor temp;
                 r.wz:=r.wz+1;
                 r.hl.w:=r.hl.w+1;
                 r.bc.w:=r.bc.w-1;
                 r.f.p_v:=(r.bc.w<>0);
                 r.f.n:=true;
                 r.f.s:=(temp and $80) <>0;
                 r.f.z:=(temp=0);
                 r.f.h:=(temp3 and 16) <> 0;
                 r.f.bit5:=((temp-((temp3 and 16) shr 4)) and 2)<>0;
                 r.f.bit3:=((temp-((temp3 shr 4) and 1)) and 8)<>0;
             end;
        $a2:begin  //ini
                   //Primer juego que lo usa Titan 09 de Sep 2006
                 if @self.in_port<>nil then temp:=self.in_port(r.bc.w)
                  else temp:=$ff;
                 r.wz:=r.bc.w+1;
                 r.bc.h:=r.bc.h-1;
                 self.putbyte(r.hl.w,temp);
                 r.hl.w:=r.hl.w+1;
                 r.f.n:=(temp and $80)<>0;
                 tempw:=temp+r.bc.l+1;
                 r.f.h:=(tempw and $100)<>0;
                 r.f.c:=(tempw and $100)<>0;
                 r.f.p_v:=paridad[(tempw and $7) xor r.bc.h];
                 r.f.z:=(r.bc.h=0);
                 r.f.bit5:=(r.bc.h and $20)<>0;
                 r.f.bit3:=(r.bc.h and 8)<>0;
                 r.f.s:=(r.bc.h and $80)<>0;
            end;
        $a3:begin //outi el primer programa que lo usa una demo!!!
                 //08 de feb 2003
                 temp:=self.getbyte(r.hl.w);
                 r.bc.h:=r.bc.h-1;
                 r.wz:=r.bc.w+1;
                 if @self.out_port<>nil then self.out_port(r.bc.w,self.getbyte(r.hl.w));
                 r.hl.w:=r.hl.w+1;
                 r.f.n:=(temp and $80)<>0;
                 tempw:=temp+r.hl.l;
                 r.f.h:=(tempw and $100)<>0;
                 r.f.c:=(tempw and $100)<>0;
                 r.f.p_v:=paridad[(tempw and $7) xor r.bc.h];
                 r.f.z:=(r.bc.h=0);
                 r.f.bit5:=(r.bc.h and $20)<>0;
                 r.f.bit3:=(r.bc.h and 8)<>0;
                 r.f.s:=(r.bc.h and $80)<>0;
             end;
        {$a4..$a7:nop*2}
        $a8:begin  {ldd}
                temp:=self.getbyte(r.hl.w);
                r.hl.w:=r.hl.w-1;
                self.putbyte(r.de.w,temp);
                r.de.w:=r.de.w-1;
                r.bc.w:=r.bc.w-1;
                r.f.n:=false;
                r.f.h:=false;
                r.f.p_v:=(r.bc.w<>0);
                r.f.bit5:=((r.a+temp) and $2)<>0;
                r.f.bit3:=((r.a+temp) and $8)<>0;
            end;
        $a9:begin //cpd el primer juego que la usa Ace 2
                 //20-09-04
                 temp2:=self.getbyte(r.hl.w);
                 temp:=r.a-temp2;
                 temp3:=r.a xor temp2 xor temp;
                 r.wz:=r.wz-1;
                 r.hl.w:=r.hl.w-1;
                 r.bc.w:=r.bc.w-1;
                 r.f.s:=(temp and $80) <>0;
                 r.f.z:=(temp=0);
                 r.f.h:=(temp3 and 16) <> 0;
                 r.f.p_v:=(r.bc.w<>0);
                 r.f.n:=true;
                 r.f.bit5:=((temp-((temp3 and 16) shr 4)) and 2)<>0;
                 r.f.bit3:=((temp-((temp3 shr 4) and 1)) and 8)<>0;
           end;
        $aa:begin   //ind añadido el 03-12-08 usado por CPC test
                 if @self.in_port<>nil then temp:=self.in_port(r.bc.w)
                   else temp:=$ff;
                 r.wz:=r.bc.w-1;
                 r.bc.h:=r.bc.h-1;
                 self.putbyte(r.hl.w,temp);
                 r.hl.w:=r.hl.w-1;
                 r.f.n:=(temp and $80)<>0;
                 tempw:=temp+r.bc.l-1;
                 r.f.h:=(tempw and $100)<>0;
                 r.f.c:=(tempw and $100)<>0;
                 r.f.p_v:=paridad[(tempw and $7) xor r.bc.h];
                 r.f.z:=(r.bc.h=0);
                 r.f.bit5:=(r.bc.h and $20)<>0;
                 r.f.bit3:=(r.bc.h and 8)<>0;
                 r.f.s:=(r.bc.h and $80)<>0;
            end;
        $ab:begin   //outd
                 temp:=self.getbyte(r.hl.w);
                 r.bc.h:=r.bc.h-1;
                 r.wz:=r.bc.w-1;
                 if @self.out_port<>nil then self.out_port(r.bc.w,self.getbyte(r.hl.w));
                 dec(r.hl.w);
                 r.f.n:=(temp and $80)<>0;
                 tempw:=temp+r.hl.l;
                 r.f.h:=(tempw and $100)<>0;
                 r.f.c:=(tempw and $100)<>0;
                 r.f.p_v:=paridad[(tempw and $7) xor r.bc.h];
                 r.f.z:=(r.bc.h=0);
                 r.f.bit5:=(r.bc.h and $20)<>0;
                 r.f.bit3:=(r.bc.h and 8)<>0;
                 r.f.s:=(r.bc.h and $80)<>0;
            end;
        {ac..$af:nop*2}
        $b0:begin //ldir
                 temp:=self.getbyte(r.hl.w);
                 r.hl.w:=r.hl.w+1;
                 self.putbyte(r.de.w,temp);
                 r.de.w:=r.de.w+1;
                 r.bc.w:=r.bc.w-1;
                 if (r.bc.w<>0) then begin
                        r.pc:=r.pc-2;
                        r.wz:=r.pc+1;
                        estados_demas:=z80t_ex[instruccion];
                 end;
                 r.f.p_v:=(r.bc.w<>0);
                 r.f.n:=false;
                 r.f.h:=false;
                 temp:=temp+r.a;
                 r.f.bit5:=(temp and 2)<>0;
                 r.f.bit3:=(temp and 8)<>0;
             end;
        $b1:begin  //cpir
                temp2:=self.getbyte(r.hl.w);
                temp:=r.a-temp2;
                temp3:=r.a xor temp2 xor temp;
                r.wz:=r.wz+1;
                r.hl.w:=r.hl.w+1;
                r.bc.w:=r.bc.w-1;
                r.f.s:=(temp and $80) <>0;
                r.f.z:=(temp=0);
                r.f.h:=(temp3 and 16) <> 0;
                r.f.p_v:=(r.bc.w<>0);
                r.f.n:=true;
                r.f.bit5:=((temp-((temp3 and 16) shr 4)) and 2)<>0;
                r.f.bit3:=((temp-((temp3 shr 4) and 1)) and 8)<>0;
                If (r.f.p_v and not(r.f.z)) then begin
                  estados_demas:=z80t_ex[instruccion];
                  r.pc:=r.pc-2;
                  r.wz:=r.pc+1;
                end;
            end;
        $b2:begin  //inir añadido el 05-10-08, lo usa una rom de Coleco!
                if @self.in_port<>nil then temp:=self.in_port(r.bc.w)
                  else temp:=$ff;
                r.wz:=r.bc.w+1;
                r.bc.h:=r.bc.h-1;
                self.putbyte(r.hl.w,temp);
                r.hl.w:=r.hl.w+1;
                r.f.n:=(temp and $80)<>0;
                tempw:=temp+r.bc.l+1;
                r.f.h:=(tempw and $100)<>0;
                r.f.c:=(tempw and $100)<>0;
                r.f.p_v:=paridad[(tempw and $7) xor r.bc.h];
                r.f.z:=(r.bc.h=0);
                r.f.bit5:=(r.bc.h and $20)<>0;
                r.f.bit3:=(r.bc.h and 8)<>0;
                r.f.s:=(r.bc.h and $80)<>0;
                if r.bc.h<>0 then begin
                  r.pc:=r.pc-2;
                  estados_demas:=z80t_ex[instruccion];
                end;
           end;
        $b3:begin //otir añadido el dia 18-09-04
                temp:=self.getbyte(r.hl.w);
                r.bc.h:=r.bc.h-1;
                r.wz:=r.bc.w+1;
                if @self.out_port<>nil then self.out_port(r.bc.w,self.getbyte(r.hl.w));
                r.hl.w:=r.hl.w+1;
                r.f.n:=(temp and $80)<>0;
                tempw:=temp+r.hl.l;
                r.f.h:=(tempw and $100)<>0;
                r.f.c:=(tempw and $100)<>0;
                r.f.p_v:=paridad[(tempw and $7) xor r.bc.h];
                r.f.z:=(r.bc.h=0);
                r.f.bit5:=(r.bc.h and $20)<>0;
                r.f.bit3:=(r.bc.h and 8)<>0;
                if r.bc.h<>0 then begin
                  r.pc:=r.pc-2;
                  estados_demas:=z80t_ex[instruccion];
                end;
            end;
        { $b4..$b7:nop*2}
        $b8:begin //lddr
                temp:=self.getbyte(r.hl.w);
                r.hl.w:=r.hl.w-1;
                self.putbyte(r.de.w,temp);
                r.de.w:=r.de.w-1;
                r.bc.w:=r.bc.w-1;
                r.f.n:=false;
                r.f.h:=false;
                r.f.p_v:=(r.bc.w<>0);
                r.f.bit5:=((r.a+temp) and $2)<>0;
                r.f.bit3:=((r.a+temp) and $8)<>0;
                if (r.bc.w<>0) then begin
                  r.pc:=r.pc-2;
                  estados_demas:=z80t_ex[instruccion];
                  r.wz:=r.pc+1;
                end;
             end;
        $b9:begin   //cpdr
                 temp2:=self.getbyte(r.hl.w);
                 temp:=r.a-temp2;
                 temp3:=r.a xor temp2 xor temp;
                 r.wz:=r.wz-1;
                 r.hl.w:=r.hl.w-1;
                 r.bc.w:=r.bc.w-1;
                 r.f.s:=(temp and $80) <>0;
                 r.f.z:=(temp=0);
                 r.f.h:=(temp3 and 16) <> 0;
                 r.f.p_v:=(r.bc.w<>0);
                 r.f.n:=true;
                 r.f.bit5:=((temp-((temp3 and 16) shr 4)) and 2)<>0;
                 r.f.bit3:=((temp-((temp3 shr 4) and 1)) and 8)<>0;
                 if r.f.p_v and not(r.f.z) then begin
                     r.pc:=r.pc-2;
                     estados_demas:=z80t_ex[instruccion];
                     r.wz:=r.pc+1;
                 end;
             end;
        $ba:begin  //indr  >16t<
                 if @self.in_port<>nil then temp:=self.in_port(r.bc.w)
                  else temp:=$ff;
                 self.putbyte(r.hl.w,temp);
                 r.wz:=r.bc.w-1;
                 r.bc.h:=r.bc.h-1;
                 r.f.n:=(temp and $80)<>0;
                 tempw:=temp+r.bc.l-1;
                 r.f.h:=(tempw and $100)<>0;
                 r.f.c:=(tempw and $100)<>0;
                 r.f.p_v:=paridad[(tempw and $7) xor r.bc.h];
                 r.f.z:=(r.bc.h=0);
                 r.f.bit5:=(r.bc.h and $20)<>0;
                 r.f.bit3:=(r.bc.h and 8)<>0;
                 r.f.s:=(r.bc.h and $80)<>0;
                 if (r.bc.h<>0) then begin
                        estados_demas:=z80t_ex[instruccion];
                        dec(r.pc,2);
                 end;
                 r.hl.w:=r.hl.w-1;
            end;
        $bb:begin //otdr
                temp:=self.getbyte(r.hl.w);
                dec(r.bc.h);
                r.wz:=r.bc.w-1;
                if @self.out_port<>nil then self.out_port(r.bc.w,temp);
                dec(r.hl.w);
                r.f.n:=(temp and $80)<>0;
                tempw:=temp+r.hl.l;
                r.f.h:=(tempw and $100)<>0;
                r.f.c:=(tempw and $100)<>0;
                r.f.p_v:=paridad[(tempw and $7) xor r.bc.h];
                r.f.z:=(r.bc.h=0);
                r.f.bit5:=(r.bc.h and $20)<>0;
                r.f.bit3:=(r.bc.h and 8)<>0;
                r.f.s:=(r.bc.h and $80)<>0;
                if (r.bc.h<>0) then begin
                    estados_demas:=z80t_ex[instruccion];
                    dec(r.pc,2);
                end;
            end;
end;
exec_ed:=z80t_ed[instruccion]+estados_demas;
end;

end.
