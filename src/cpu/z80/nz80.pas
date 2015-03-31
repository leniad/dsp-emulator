unit nz80;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     main_engine,z80daisy,timer_engine,dialogs,sysutils,vars_hide;

type
  band_z80 = record
     c,n,p_v,bit3,h,bit5,z,s:boolean;
  end;
  tdespues_instruccion=procedure(estados_t:word);
  type_raised=function:byte;
  nreg_z80=record
        ppc,pc,sp:word;
        bc,de,hl:parejas;
        bc2,de2,hl2:parejas;
        ix,iy:parejas;
        iff1,iff2:boolean;
        a,a2,i,r:byte;
        f,f2:band_z80;
        im:byte;
  end;
  npreg_z80=^nreg_z80;
  cpu_z80=class(cpu_class)
          constructor create(clock:dword;frames_div:word);
          procedure free;
          destructor destroy;
        public
          daisy,halt:boolean;
          pedir_irq,pedir_nmi,im2_lo,im0:byte;
          procedure reset;
          procedure run(maximo:single);
          procedure clear_nmi;
          procedure change_timmings(z80t_set,z80t_cb_set,z80t_dd_set,z80t_ddcb_set,z80t_ed_set,z80t_ex_set:pbyte);
          procedure change_io_calls(in_port:cpu_inport_full;out_port:cpu_outport_full);
          procedure change_misc_calls(despues_instruccion:tdespues_instruccion;raised_z80:type_raised);
          function get_internal_r:npreg_z80;
          procedure set_internal_r(r:npreg_z80);
          function save_snapshot(data:pbyte):word;
          procedure load_snapshot(data:pbyte);
        protected
          r:npreg_z80;
          after_ei:boolean;
          nmi_state:byte;
          raised_z80:type_raised;
          in_port:cpu_inport_full;
          out_port:cpu_outport_full;
          despues_instruccion:tdespues_instruccion;
          function call_nmi:byte;
          function call_irq:byte;
          //resto de opcodes
          function exec_cb:byte;
          function exec_dd_fd(tipo:boolean):byte;
          function exec_dd_cb(tipo:boolean):byte;
          function exec_ed:byte;
          {pila}
          procedure push_sp(reg:word);
          function pop_sp:word;
        end;

const
        z80t_m:array[0..255] of byte=(
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

         z80t_cb_m:array[0..255] of byte=(
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

        z80t_dd_m:array[0..255] of byte=(
      //0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
        4+4,10+4, 7+4, 6+4, 4+4, 4+4, 7+4, 4+4, 4+4,11+4, 7+4, 6+4, 4+4, 4+4, 7+4, 4+4,
	8+4,10+4, 7+4, 6+4, 4+4, 4+4, 7+4, 4+4,12+4,11+4, 7+4, 6+4, 4+4, 4+4, 7+4, 4+4,
	7+4,10+4,16+4, 6+4, 4+4, 4+4, 7+4, 4+4, 7+4,11+4,16+4, 6+4, 4+4, 4+4, 7+4, 4+4,
	7+4,10+4,13+4, 6+4,23  ,23  ,19  , 4+4, 7+4,11+4,13+4, 6+4, 4+4, 4+4, 7+4, 4+4,
	4+4, 4+4, 4+4, 4+4, 4+4, 4+4,19  , 4+4, 4+4, 4+4, 4+4, 4+4, 4+4, 4+4,19  , 4+4,
	4+4, 4+4, 4+4, 4+4, 4+4, 4+4,19  , 4+4, 4+4, 4+4, 4+4, 4+4, 4+4, 4+4,19  , 4+4,
	4+4, 4+4, 4+4, 4+4, 4+4, 4+4,19  , 4+4, 4+4, 4+4, 4+4, 4+4, 4+4, 4+4,19  , 4+4,
19  ,19  ,19  ,19  ,19  ,19  , 4+4,19  , 4+4, 4+4, 4+4, 4+4, 4+4, 4+4,19  , 4+4,
	4+4, 4+4, 4+4, 4+4, 4+4, 4+4,19  , 4+4, 4+4, 4+4, 4+4, 4+4, 4+4, 4+4,19  , 4+4,
	4+4, 4+4, 4+4, 4+4, 4+4, 4+4,19  , 4+4, 4+4, 4+4, 4+4, 4+4, 4+4, 4+4,19  , 4+4,
	4+4, 4+4, 4+4, 4+4, 4+4, 4+4,19  , 4+4, 4+4, 4+4, 4+4, 4+4, 4+4, 4+4,19  , 4+4,
	4+4, 4+4, 4+4, 4+4, 4+4, 4+4,19  , 4+4, 4+4, 4+4, 4+4, 4+4, 4+4, 4+4,19  , 4+4,
	5+4,10+4,10+4,10+4,10+4,11+4, 7+4,11+4, 5+4,10+4,10+4, 0  ,10+4,17+4, 7+4,11+4, // cb -> cc_xycb */
	5+4,10+4,10+4,11+4,10+4,11+4, 7+4,11+4, 5+4, 4+4,10+4,11+4,10+4, 4  , 7+4,11+4, // dd -> cc_xy again */
	5+4,10+4,10+4,19+4,10+4,11+4, 7+4,11+4, 5+4, 4+4,10+4, 4+4,10+4, 4  , 7+4,11+4, // ed -> cc_ed */
	5+4,10+4,10+4, 4+4,10+4,11+4, 7+4,11+4, 5+4, 6+4,10+4, 4+4,10+4, 4  , 7+4,11+4); //F0

        z80t_ddcb_m:array[0..255] of byte=(
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

        z80t_ed_m:array[0..255] of byte=(
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

        z80t_ex_m:array[0..255] of byte=(
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

var
  main_z80,sub_z80,snd_z80:cpu_z80;
  z80t,z80t_cb,z80t_dd,z80t_ddcb,z80t_ed,z80t_ex:array[0..$ff] of byte;

implementation

constructor cpu_z80.create(clock:dword;frames_div:word);
begin
getmem(self.r,sizeof(nreg_z80));
fillchar(self.r^,sizeof(nreg_z80),0);
self.numero_cpu:=cpu_quantity;
self.clock:=clock;
self.tframes:=(clock/frames_div)/llamadas_maquina.fps_max;
self.in_port:=nil;
self.out_port:=nil;
self.despues_instruccion:=nil;
self.raised_z80:=nil;
cpu_quantity:=cpu_quantity+1;
copymemory(@z80t[0],@z80t_m[0],$100);
copymemory(@z80t_cb[0],@z80t_cb_m[0],$100);
copymemory(@z80t_dd[0],@z80t_dd_m[0],$100);
copymemory(@z80t_ddcb[0],@z80t_ddcb_m[0],$100);
copymemory(@z80t_ed[0],@z80t_ed_m[0],$100);
copymemory(@z80t_ex[0],@z80t_ex_m[0],$100);
end;

procedure cpu_z80.change_timmings(z80t_set,z80t_cb_set,z80t_dd_set,z80t_ddcb_set,z80t_ed_set,z80t_ex_set:pbyte);
begin
if z80t_set<>nil then copymemory(@z80t[0],@z80t_set[0],$100);
if z80t_cb_set<>nil then copymemory(@z80t_cb[0],@z80t_cb_set[0],$100);
if z80t_dd_set<>nil then copymemory(@z80t_dd[0],@z80t_dd_set[0],$100);
if z80t_ddcb_set<>nil then copymemory(@z80t_ddcb[0],@z80t_ddcb_set[0],$100);
if z80t_ed_set<>nil then copymemory(@z80t_ed[0],@z80t_ed_set[0],$100);
if z80t_ex_set<>nil then copymemory(@z80t_ex[0],@z80t_ex_set[0],$100);
end;

destructor cpu_z80.Destroy;
begin
freemem(self.r);
self.r:=nil;
end;

procedure cpu_z80.Free;
begin
  if Self.r<>nil then Destroy;
end;

procedure cpu_z80.reset;
begin
  r.sp:=$0;
  r.pc:=0;
  r.a:=0;r.bc.w:=0;r.de.w:=0;r.hl.w:=0;
  r.a2:=0;r.bc2.w:=0;r.de2.w:=0;r.hl2.w:=0;
  r.ix.w:=$ffff;
  r.iy.w:=$ffff;
  r.iff1:=false;
  r.iff2:=false;
  r.i:=0;
  r.r:=0;
  r.im:=0;
  r.f.c:=false;r.f.n:=false;r.f.p_v:=false;r.f.bit3:=false;r.f.h:=false;r.f.bit5:=false;r.f.z:=true;r.f.s:=false;
  r.f2.c:=false;r.f2.n:=false;r.f2.p_v:=false;r.f2.bit3:=false;r.f2.h:=false;r.f2.bit5:=false;r.f2.z:=false;r.f2.s:=false;
  self.pedir_nmi:=CLEAR_LINE;
  self.nmi_state:=CLEAR_LINE;
  self.pedir_irq:=CLEAR_LINE;
  self.pedir_reset:=CLEAR_LINE;
  self.pedir_halt:=CLEAR_LINE;
  self.halt:=false;
  self.im2_lo:=$FF;
  self.im0:=$FF;
  self.opcode:=false;
  self.after_ei:=false;
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
  buffer[0]:=byte(self.halt);
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
  self.halt:=(temp^<>0);inc(temp);
  self.daisy:=(temp^<>0);inc(temp);
  self.after_ei:=(temp^<>0);inc(temp);
  self.pedir_irq:=temp^;inc(temp);
  self.pedir_nmi:=temp^;inc(temp);
  self.nmi_state:=temp^;inc(temp);
  copymemory(@self.contador,temp,4);inc(temp,4);
  self.im2_lo:=temp^;inc(temp);
  self.im0:=temp^;
end;

procedure cpu_z80.clear_nmi;
begin
  self.pedir_nmi:=CLEAR_LINE;
  self.nmi_state:=CLEAR_LINE;
end;

procedure cpu_z80.change_io_calls(in_port:cpu_inport_full;out_port:cpu_outport_full);
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
self.halt:=false;
self.pedir_halt:=CLEAR_LINE;
if self.nmi_state<>CLEAR_LINE then exit;
self.push_sp(r.pc);
r.IFF1:=false;
r.pc:=$66;
call_nmi:=11;
if (self.pedir_nmi=PULSE_LINE) then self.pedir_nmi:=CLEAR_LINE;
if (self.pedir_nmi=ASSERT_LINE) then self.nmi_state:=ASSERT_LINE;
end;

function cpu_z80.call_irq:byte;
var
  posicion:parejas;
  estados_t:byte;
begin
call_irq:=0;
self.halt:=false;
if not(r.iff1) then exit; //se esta ejecutando otra
if @self.raised_z80<>nil then estados_t:=self.raised_z80
  else estados_t:=0;
if self.pedir_irq=HOLD_LINE then self.pedir_irq:=CLEAR_LINE;
push_sp(r.pc);
r.IFF2:=false;
r.IFF1:=false;
Case r.im of
        0:begin
            if self.daisy then MessageDlg('Mierda!!! Daisy chain en IM0!!', mtInformation,[mbOk], 0);
            case self.im0 of  //hago la intruccion que viene del bus
              $cf:r.pc:=$8;
              $d7:r.pc:=$10;
              $df:r.pc:=$18;
              $e7:r.pc:=$20;
              $ef:r.pc:=$28;
              $f7:r.pc:=$30;
              $ff:r.pc:=$38;
              else MessageDlg('Mierda!!! IM0 desconocido...'+inttostr(self.im0), mtInformation,[mbOk], 0)
            end;
            estados_t:=estados_t+13;
          end;
        1:begin
            r.pc:=$38;
            estados_t:=estados_t+13;
        end;
        2:begin
            if self.daisy then posicion.l:=z80daisy_ack
              else posicion.l:=self.im2_lo;
            posicion.h:=r.i;
            r.pc:=self.getbyte(posicion.w)+(self.getbyte(posicion.w+1) shl 8);
            estados_t:=estados_t+19;
        end;
end; {del case}
call_irq:=estados_t;
end;

//Functions
{$I z80.inc}

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
 ban_temp:band_z80;
 irq_temp:boolean;
 cantidad_t:word;
begin
irq_temp:=false;
self.contador:=0;
while self.contador<maximo do begin
if self.pedir_reset<>CLEAR_LINE then begin
  if self.pedir_reset<>ALREADY_RESET then begin
    self.reset;
    self.pedir_reset:=ALREADY_RESET;
  end;
  self.contador:=trunc(maximo);
  exit;
end;
self.estados_demas:=0;
r.ppc:=r.pc;
if not(self.after_ei) then begin
  if self.pedir_nmi<>CLEAR_LINE then self.estados_demas:=self.call_nmi
  else begin
      if self.daisy then irq_temp:=z80daisy_state;
      if (irq_temp or (self.pedir_irq<>CLEAR_LINE)) then self.estados_demas:=self.call_irq;
  end;
end;
self.after_ei:=false;
if self.pedir_halt<>CLEAR_LINE then begin
  self.contador:=trunc(maximo);
  exit;
end;
if not(self.halt) then begin
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
        $02:self.putbyte(r.bc.w,r.a);{ld (BC),A}
        $03:r.bc.w:=r.bc.w+1;  {inc BC}
        $04:inc_8(self.r,@r.bc.h); {inc B}
        $05:dec_8(self.r,@r.bc.h); {dec B}
        $06:begin {ld B,n}
                r.bc.h:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
            end;
        $07:begin   {rlca}
               r.f.c:=(r.a and $80)<>0;
               if r.f.c then r.a:=((r.a shl 1) or 1)
                  else r.a:=r.a shl 1;
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
        $09:add_16(self.r,@r.hl,r.bc.w); {add HL,BC}
        $0a:r.a:=self.getbyte(r.bc.w); {ld A,(BC)}
        $0b:r.bc.w:=r.bc.w-1;  {dec BC}
        $0c:inc_8(self.r,@r.bc.l); {inc C}
        $0d:dec_8(self.r,@r.bc.l); {dec C}
        $0e:begin {ld C,n}
                r.bc.l:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
            end;
        $0f:begin   {rrca}
                r.f.c:=(r.a and 1)<>0;
                if r.f.c then r.a:=((r.a shr 1) or $80)
                    else r.a:=r.a shr 1;
                r.f.bit5:=(r.a and $20) <>0;
                r.f.bit3:=(r.a and 8)<>0;
                r.f.h:=false;
                r.f.n:=false;
            end;
        $10:begin {dnjz (PC+e)}
                r.bc.h:=r.bc.h-1;
                r.pc:=r.pc+1;
                if r.bc.h<>0 then begin
                        temp:=self.getbyte(r.pc-1);
                        r.pc:=r.pc+shortint(temp);
                        self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
                end;
            end;
        $11:begin {ld DE,nn}
                r.de.l:=self.getbyte(r.pc);
                r.de.h:=self.getbyte(r.pc+1);
                r.pc:=r.pc+2;
            end;
        $12:self.putbyte(r.de.w,r.a);  {ld (DE),A}
        $13:r.de.w:=r.de.w+1;  {inc DE}
        $14:inc_8(self.r,@r.de.h); {inc D}
        $15:dec_8(self.r,@r.de.h); {dec D}
        $16:begin {ld D,n}
                r.de.h:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
            end;
        $17:begin  {rla}
                r.f.h:=(r.a and $80)<>0;
                if r.f.c then r.a:=((r.a shl 1) or 1)
                    else r.a:=r.a shl 1;
                r.f.bit5:=(r.a and $20)<>0;
                r.f.bit3:=(r.a and 8)<>0;
                r.f.c:=r.f.h;
                r.f.h:=false;
                r.f.n:=false;
            end;
        $18:begin   {jr e}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                r.pc:=r.pc+shortint(temp);
            end;
        $19:add_16(self.r,@r.hl,r.de.w); {add HL,DE}
        $1a:r.a:=self.getbyte(r.de.w); {ld A,(DE)}
        $1b:r.de.w:=r.de.w-1;  {dec DE}
        $1c:inc_8(self.r,@r.de.l); {inc E}
        $1d:dec_8(self.r,@r.de.l); {dec E}
        $1e:begin {ld E,n}
                r.de.l:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
            end;
        $1f:begin {rra}
                r.f.h:=(r.a and 1)<>0;
                if r.f.c then r.a:=((r.a shr 1) or $80)
                    else r.a:=r.a shr 1;
                r.f.n:=false;
                r.f.c:=r.f.h;
                r.f.h:=false;
                r.f.bit5:=(r.a and $20)<>0;
                r.f.bit3:=(r.a and 8)<>0;
            end;
        $20:begin  {jp NZ,(PC+e)}
                r.pc:=r.pc+1;
                if not(r.f.z) then begin
                        temp:=self.getbyte(r.pc-1);
                        r.pc:=r.pc+shortint(temp);
                        self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
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
            end;
        $23:r.hl.w:=r.hl.w+1;  {inc HL}
        $24:inc_8(self.r,@r.hl.h); {inc H}
        $25:dec_8(self.r,@r.hl.h); {dec H}
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
        $28:begin  {jp Z,(PC+e)}
                r.pc:=r.pc+1;
                if r.f.z then begin
                        temp:=self.getbyte(r.pc-1);
                        r.pc:=r.pc+shortint(temp);
                        self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
                end;
            end;
        $29:add_16(self.r,@r.hl,r.hl.w); {add HL,HL}
        $2a:begin  {ld HL,(nn)}
                posicion.h:=self.getbyte(r.pc+1);
                posicion.l:=self.getbyte(r.pc);
                r.pc:=r.pc+2;
                r.hl.l:=self.getbyte(posicion.w);
                r.hl.h:=self.getbyte(posicion.w+1);
            end;
        $2b:r.hl.w:=r.hl.w-1;  {dec HL}
        $2c:inc_8(self.r,@r.hl.l); {inc L}
        $2d:dec_8(self.r,@r.hl.l); {dec L}
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
        $30:begin  {jp NC,(PC+e)}
                r.pc:=r.pc+1;
                if not(r.f.c) then begin
                        temp:=self.getbyte(r.pc-1);
                        r.pc:=r.pc+shortint(temp);
                        self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
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
            end;
        $33:r.sp:=r.sp+1;  {inc SP}
        $34:begin  {inc (HL)}
                temp:=self.getbyte(r.hl.w);
                inc_8(self.r,@temp);
                self.putbyte(r.hl.w,temp);
            end;
        $35:begin  {dec (HL)}
                temp:=self.getbyte(r.hl.w);
                dec_8(self.r,@temp);
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
        $38:begin  {jp C,(PC+e)}
                r.pc:=r.pc+1;
                if r.f.c then begin
                        temp:=self.getbyte(r.pc-1);
                        r.pc:=r.pc+shortint(temp);
                        self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
                end;
            end;
        $39:add_16(self.r,@r.hl,r.sp); {add HL,SP}
        $3a:begin {ld A,(nn)}
                posicion.h:=self.getbyte(r.pc+1);
                posicion.l:=self.getbyte(r.pc);
                r.pc:=r.pc+2;
                r.a:=self.getbyte(posicion.w);
            end;
        $3b:r.sp:=r.sp-1;  {dec SP}
        $3c:inc_8(self.r,@r.a); {inc A}
        $3d:dec_8(self.r,@r.a); {dec A}
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
        $76:self.halt:=true; {halt}
        $77:self.putbyte(r.hl.w,r.a); {ld (HL),A}
        $78:r.a:=r.bc.h; {ld A,B}
        $79:r.a:=r.bc.l; {ld A,C}
        $7a:r.a:=r.de.h; {ld A,D}
        $7b:r.a:=r.de.l; {ld A,E}
        $7c:r.a:=r.hl.h; {ld A,H}
        $7d:r.a:=r.hl.l; {ld A,L}
        $7e:r.a:=self.getbyte(r.hl.w); {ld A,(HL)}
        {'$'7f: igual que el nop ld A,A}
        $80:add_8(self.r,r.bc.h); {add A,B}
        $81:add_8(self.r,r.bc.l); {add A,C}
        $82:add_8(self.r,r.de.h); {add A,D}
        $83:add_8(self.r,r.de.l); {add A,E}
        $84:add_8(self.r,r.hl.h); {add A,H}
        $85:add_8(self.r,r.hl.l); {add A,L}
        $86:add_8(self.r,self.getbyte(r.hl.w));  {add A,(HL)}
        $87:add_8(self.r,r.a); {add A,A}
        $88:adc_8(self.r,r.bc.h); {adc A,B}
        $89:adc_8(self.r,r.bc.l); {adc A,C}
        $8a:adc_8(self.r,r.de.h); {adc A,D}
        $8b:adc_8(self.r,r.de.l); {adc A,E}
        $8c:adc_8(self.r,r.hl.h); {adc A,H}
        $8d:adc_8(self.r,r.hl.l); {adc A,L}
        $8e:adc_8(self.r,self.getbyte(r.hl.w)); {adc A,(HL)}
        $8f:adc_8(self.r,r.a); {adc A,A}
        $90:sub_8(self.r,r.bc.h); {sub B}
        $91:sub_8(self.r,r.bc.l); {sub C}
        $92:sub_8(self.r,r.de.h); {sub D}
        $93:sub_8(self.r,r.de.l); {sub E}
        $94:sub_8(self.r,r.hl.h); {sub H}
        $95:sub_8(self.r,r.hl.l); {sub L}
        $96:sub_8(self.r,self.getbyte(r.hl.w));  {sub (HL)}
        $97:sub_8(self.r,r.a); {sub A}
        $98:sbc_8(self.r,r.bc.h); {sbc A,B}
        $99:sbc_8(self.r,r.bc.l); {sbc A,C}
        $9a:sbc_8(self.r,r.de.h); {sbc A,D}
        $9b:sbc_8(self.r,r.de.l); {sbc A,E}
        $9c:sbc_8(self.r,r.hl.h); {sbc A,H}
        $9d:sbc_8(self.r,r.hl.l); {sbc A,L}
        $9e:sbc_8(self.r,self.getbyte(r.hl.w)); {sbc A,(HL)}
        $9f:sbc_8(self.r,r.a); {sbc A,A}
        $a0:and_a(self.r,r.bc.h);  {and A,B}
        $a1:and_a(self.r,r.bc.l);  {and A,C}
        $a2:and_a(self.r,r.de.h);  {and A,D}
        $a3:and_a(self.r,r.de.l); {and A,E}
        $a4:and_a(self.r,r.hl.h); {and A,H}
        $a5:and_a(self.r,r.hl.l); {and A,L}
        $a6:and_a(self.r,self.getbyte(r.hl.w)); {and A,(HL)}
        $a7:and_a(self.r,r.a); {and A,A}
        $a8:xor_a(self.r,r.bc.h); {xor A,B}
        $a9:xor_a(self.r,r.bc.l); {xor A,C}
        $aa:xor_a(self.r,r.de.h); {xor A,D}
        $ab:xor_a(self.r,r.de.l); {xor A,E}
        $ac:xor_a(self.r,r.hl.h); {xor A,H}
        $ad:xor_a(self.r,r.hl.l); {xor A,L}
        $ae:xor_a(self.r,self.getbyte(r.hl.w)); {xor A,(HL)}
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
        $b0:or_a(self.r,r.bc.h); {or B}
        $b1:or_a(self.r,r.bc.l); {or C}
        $b2:or_a(self.r,r.de.h); {or D}
        $b3:or_a(self.r,r.de.l); {or E}
        $b4:or_a(self.r,r.hl.h); {or H}
        $b5:or_a(self.r,r.hl.l); {or L}
        $b6:or_a(self.r,self.getbyte(r.hl.w));   {or (HL)}
        $b7:or_a(self.r,r.a); {or A}
        $b8:cp_a(self.r,r.bc.h); {cp B}
        $b9:cp_a(self.r,r.bc.l); {cp C}
        $ba:cp_a(self.r,r.de.h); {cp D}
        $bb:cp_a(self.r,r.de.l); {cp E}
        $bc:cp_a(self.r,r.hl.h); {cp H}
        $bd:cp_a(self.r,r.hl.l); {cp L}
        $be:cp_a(self.r,self.getbyte(r.hl.w)); {cp (HL)}
        $bf:cp_a(self.r,r.a); {cp A}
        $c0:if not(r.f.z) then begin {ret NZ}
                r.pc:=self.pop_sp;
                self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
             end;
        $c1:r.bc.w:=self.pop_sp;  {pop BC}
        $c2:if not(r.f.z) then begin {jp NZ,nn}
                        posicion.h:=self.getbyte(r.pc+1);
                        posicion.l:=self.getbyte(r.pc);
                        r.pc:=posicion.w;
            end else r.pc:=r.pc+2;
        $c3:begin {jp nn}
                posicion.h:=self.getbyte(r.pc+1);
                posicion.l:=self.getbyte(r.pc);
                r.pc:=posicion.w;
             end;
        $c4:begin   {call NZ,nn}
                r.pc:=r.pc+2;
                if not(r.f.z) then begin
                        self.push_sp(r.pc);
                        posicion.h:=self.getbyte(r.pc-1);
                        posicion.l:=self.getbyte(r.pc-2);
                        r.pc:=posicion.w;
                        self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
                end;
             end;
        $c5:self.push_sp(r.bc.w);  {push BC}
        $c6:begin {add A,n}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                add_8(self.r,temp);
             end;
        $c7:begin  {rst 00H}
                self.push_sp(r.pc);
                r.pc:=0;
             end;
        $c8:if r.f.z then begin {ret Z}
                r.pc:=self.pop_sp;
                self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
             end;
        $c9:r.pc:=pop_sp;  {ret}
        $ca:if r.f.z then begin {jp Z,nn}
                posicion.h:=self.getbyte(r.pc+1);
                posicion.l:=self.getbyte(r.pc);
                r.pc:=posicion.w;
            end else r.pc:=r.pc+2;
        $cb:self.estados_demas:=self.estados_demas+self.exec_cb;
        $cc:begin   {call Z,nn}
                r.pc:=r.pc+2;
                if r.f.z then begin
                        self.push_sp(r.pc);
                        posicion.h:=self.getbyte(r.pc-1);
                        posicion.l:=self.getbyte(r.pc-2);
                        r.pc:=posicion.w;
                        self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
                end;
             end;
        $cd:begin   {call nn}
                posicion.h:=self.getbyte(r.pc+1);
                posicion.l:=self.getbyte(r.pc);
                r.pc:=r.pc+2;
                self.push_sp(r.pc);
                r.pc:=posicion.w;
             end;
        $ce:begin   {adc A,n}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                adc_8(self.r,temp);
             end;
        $cf:begin  {rst 08H}
                self.push_sp(r.pc);
                r.pc:=$8;
             end;
        $d0:if not(r.f.c) then begin {ret NC}
                r.pc:=pop_sp;
                self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
             end;
        $d1:r.de.w:=pop_sp;  {pop DE}
        $d2:if not(r.f.c) then begin {jp NC,nn}
                posicion.h:=self.getbyte(r.pc+1);
                posicion.l:=self.getbyte(r.pc);
                r.pc:=posicion.w;
             end else r.pc:=r.pc+2;
        $d3:begin {out (n),A}
                posicion.l:=self.getbyte(r.pc);
                posicion.h:=r.a;
                r.pc:=r.pc+1;
                if @self.out_port<>nil then self.out_port(r.a,posicion.w);
             end;
        $d4:begin   {call NC,nn}
                r.pc:=r.pc+2;
                if not(r.f.c) then begin
                        self.push_sp(r.pc);
                        posicion.h:=self.getbyte(r.pc-1);
                        posicion.l:=self.getbyte(r.pc-2);
                        r.pc:=posicion.w;
                        self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
                end;
             end;
        $d5:self.push_sp(r.de.w);  {push DE}
        $d6:begin {sub n}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                sub_8(self.r,temp);
             end;
        $d7:begin  {rst 10H}
                self.push_sp(r.pc);
                r.pc:=$10;
             end;
        $d8:if r.f.c then begin {ret C}
                r.pc:=pop_sp;
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
        $da:if r.f.c then begin {jp C,nn}
                posicion.h:=self.getbyte(r.pc+1);
                posicion.l:=self.getbyte(r.pc);
                r.pc:=posicion.w;
            end else r.pc:=r.pc+2;
        $db:begin  {in A,(n)}
             posicion.l:=self.getbyte(r.pc);
             r.pc:=r.pc+1;
             posicion.h:=r.a;
             if @self.in_port<>nil then r.a:=self.in_port(posicion.w)
              else r.a:=$ff;
             end;
        $dc:begin   {call C,nn}
                r.pc:=r.pc+2;
                if r.f.c then begin
                        self.push_sp(r.pc);
                        posicion.h:=self.getbyte(r.pc-1);
                        posicion.l:=self.getbyte(r.pc-2);
                        r.pc:=posicion.w;
                        self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
                end;
             end;
        $dd:self.estados_demas:=self.estados_demas+self.exec_dd_fd(true);
        $de:begin {sbc A,n}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                sbc_8(self.r,temp);
            end;
        $df:begin  {rst 18H}
                self.push_sp(r.pc);
                r.pc:=$18;
             end;
        $e0:if not(r.f.p_v) then begin {ret PO}
                r.pc:=self.pop_sp;
                self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
             end;
        $e1:r.hl.w:=pop_sp;  {pop HL}
        $e2:if not(r.f.p_v) then begin {jp PO,nn}
                posicion.h:=self.getbyte(r.pc+1);
                posicion.l:=self.getbyte(r.pc);
                r.pc:=posicion.w;
            end else r.pc:=r.pc+2;
        $e3:begin   {ex (sp),hl}
                posicion.w:=pop_sp;
                self.push_sp(r.hl.w);
                r.hl:=posicion;
             end;
        $e4:begin   {call PO,nn}
                r.pc:=r.pc+2;
                if not(r.f.p_v) then begin
                        self.push_sp(r.pc);
                        posicion.h:=self.getbyte(r.pc-1);
                        posicion.l:=self.getbyte(r.pc-2);
                        r.pc:=posicion.w;
                        self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
                end;
             end;
        $e5:self.push_sp(r.hl.w);  {push HL}
        $e6:begin {and A,n}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                and_a(self.r,temp);
             end;
        $e7:begin  {rst 20H}
                self.push_sp(r.pc);
                r.pc:=$20;
             end;
        $e8:if r.f.p_v then begin {ret PE}
                r.pc:=pop_sp;
                self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
             end;
        $e9:r.pc:=r.hl.w; {jp (HL)}
        $ea:if r.f.p_v then begin {jp PE,nn}
                posicion.h:=self.getbyte(r.pc+1);
                posicion.l:=self.getbyte(r.pc);
                r.pc:=posicion.w;
            end else r.pc:=r.pc+2;
        $eb:begin { ex DE,HL}
                posicion:=r.de;
                r.de:=r.hl;
                r.hl:=posicion;
             end;
        $ec:begin   {call PE,nn}
                r.pc:=r.pc+2;
                if r.f.p_v then begin
                        self.push_sp(r.pc);
                        posicion.h:=self.getbyte(r.pc-1);
                        posicion.l:=self.getbyte(r.pc-2);
                        r.pc:=posicion.w;
                        self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
                end;
             end;
        $ed:self.estados_demas:=self.estados_demas+exec_ed;
        $ee:begin  {xor A,n}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                xor_a(self.r,temp);
              end;
        $ef:begin  {rst 28H}
                self.push_sp(r.pc);
                r.pc:=$28;
             end;
        $f0:if not(r.f.s) then begin {ret NP}
                r.pc:=self.pop_sp;
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
        $f2:if not(r.f.s) then begin {jp P,nn}
                posicion.h:=self.getbyte(r.pc+1);
                posicion.l:=self.getbyte(r.pc);
                r.pc:=posicion.w;
             end else r.pc:=r.pc+2;
        $f3:begin {di}
                r.iff1:=false;
                r.iff2:=false;
              end;
        $f4:begin   {call P,nn}
                r.pc:=r.pc+2;
                if not(r.f.s) then begin
                        self.push_sp(r.pc);
                        posicion.h:=self.getbyte(r.pc-1);
                        posicion.l:=self.getbyte(r.pc-2);
                        r.pc:=posicion.w;
                        self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
                end;
             end;
        $f5:begin  {push AF}
                posicion.h:=r.a;
                posicion.l:=0;
                if r.f.s then posicion.l:=posicion.l or $80;
                if r.f.z then posicion.l:=posicion.l or $40;
                if r.f.bit5 then posicion.l:=posicion.l or $20;
                if r.f.h then posicion.l:=posicion.l or $10;
                if r.f.bit3 then posicion.l:=posicion.l or 8;
                if r.f.p_v then posicion.l:=posicion.l or 4;
                if r.f.n then posicion.l:=posicion.l or 2;
                if r.f.c then posicion.l:=posicion.l or 1;
                self.push_sp(posicion.w);
             end;
        $f6:begin {or n}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                or_a(self.r,temp);
             end;
        $f7:begin  {rst 30H}
                self.push_sp(r.pc);
                r.pc:=$30;
             end;
        $f8:if r.f.s then begin {ret M}
                r.pc:=self.pop_sp;
                self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
             end;
        $f9:r.sp:=r.hl.w; {ld SP,HL}
        $fa:if r.f.s then begin {jp M,nn}
                posicion.h:=self.getbyte(r.pc+1);
                posicion.l:=self.getbyte(r.pc);
                r.pc:=posicion.w;
            end else r.pc:=r.pc+2;
        $fb:begin   {ei}
                r.iff1:=true;
                r.iff2:=true;
                self.after_ei:=true;
             end;
        $fc:begin   {call M,nn}
                r.pc:=r.pc+2;
                if r.f.s then begin
                        self.push_sp(r.pc);
                        posicion.h:=self.getbyte(r.pc-1);
                        posicion.l:=self.getbyte(r.pc-2);
                        r.pc:=posicion.w;
                        self.estados_demas:=self.estados_demas+z80t_ex[instruccion];
                end;
             end;
        $fd:self.estados_demas:=self.estados_demas+self.exec_dd_fd(false);
        $fe:begin  {cp n}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                cp_a(self.r,temp);
            end;
        $ff:begin  {rst 38H}
                self.push_sp(r.pc);
                r.pc:=$38;
             end;
  end; {del case}
  cantidad_t:=z80t[instruccion]+self.estados_demas;
  if @self.despues_instruccion<>nil then self.despues_instruccion(cantidad_t);
  self.contador:=self.contador+cantidad_t;
  update_timer(cantidad_t,self.numero_cpu);
end else begin
  if @self.despues_instruccion<>nil then self.despues_instruccion(4);
  self.contador:=self.contador+4;
  update_timer(4,self.numero_cpu);
end;
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
        $00:rlc_8(self.r,@r.bc.h); {rlc B}
        $01:rlc_8(self.r,@r.bc.l); {rlc C}
        $02:rlc_8(self.r,@r.de.h); {rlc D}
        $03:rlc_8(self.r,@r.de.l); {rlc E}
        $04:rlc_8(self.r,@r.hl.h); {rlc H}
        $05:rlc_8(self.r,@r.hl.l); {rlc L}
        $06:begin
                temp:=self.getbyte(r.hl.w);
                rlc_8(self.r,@temp); {rlc (HL)}
                self.putbyte(r.hl.w,temp);
            end;
        $07:rlc_8(self.r,@r.a); {rlc A}
        $08:rrc_8(self.r,@r.bc.h); {rlc B}
        $09:rrc_8(self.r,@r.bc.l); {rlc C}
        $0a:rrc_8(self.r,@r.de.h); {rlc D}
        $0b:rrc_8(self.r,@r.de.l); {rlc E}
        $0c:rrc_8(self.r,@r.hl.h); {rlc H}
        $0d:rrc_8(self.r,@r.hl.l); {rlc L}
        $0e:begin
                temp:=self.getbyte(r.hl.w);
                rrc_8(self.r,@temp); {rlc (HL)}
                self.putbyte(r.hl.w,temp);
            end;
        $0f:rrc_8(self.r,@r.a); {rlc A}
        $10:rl_8(self.r,@r.bc.h); {rl B}
        $11:rl_8(self.r,@r.bc.l); {rl C}
        $12:rl_8(self.r,@r.de.h); {rl D}
        $13:rl_8(self.r,@r.de.l); {rl E}
        $14:rl_8(self.r,@r.hl.h); {rl H}
        $15:rl_8(self.r,@r.hl.l); {rl L}
        $16:begin
                temp:=self.getbyte(r.hl.w);
                rl_8(self.r,@temp); {rl (HL)}
                self.putbyte(r.hl.w,temp);
            end;
        $17:rl_8(self.r,@r.a); {rl A}
        $18:rr_8(self.r,@r.bc.h); {rr B}
        $19:rr_8(self.r,@r.bc.l); {rr C}
        $1a:rr_8(self.r,@r.de.h); {rr D}
        $1b:rr_8(self.r,@r.de.l); {rr E}
        $1c:rr_8(self.r,@r.hl.h); {rr H}
        $1d:rr_8(self.r,@r.hl.l); {rr L}
        $1e:begin
                temp:=self.getbyte(r.hl.w);
                rr_8(self.r,@temp); {rr (HL)}
                self.putbyte(r.hl.w,temp);
            end;
        $1f:rr_8(self.r,@r.a); {rr A}
        $20:sla_8(self.r,@r.bc.h); {sla B}
        $21:sla_8(self.r,@r.bc.l); {sla C}
        $22:sla_8(self.r,@r.de.h); {sla D}
        $23:sla_8(self.r,@r.de.l); {sla E}
        $24:sla_8(self.r,@r.hl.h); {sla H}
        $25:sla_8(self.r,@r.hl.l); {sla L}
        $26:begin
                temp:=self.getbyte(r.hl.w);
                sla_8(self.r,@temp); {sla (HL)}
                self.putbyte(r.hl.w,temp);
            end;
        $27:sla_8(self.r,@r.a); {sla A}
        $28:sra_8(self.r,@r.bc.h); {sra B}
        $29:sra_8(self.r,@r.bc.l); {sra C}
        $2a:sra_8(self.r,@r.de.h); {sra D}
        $2b:sra_8(self.r,@r.de.l); {sra E}
        $2c:sra_8(self.r,@r.hl.h); {sra H}
        $2d:sra_8(self.r,@r.hl.l); {sra L}
        $2e:begin
                temp:=self.getbyte(r.hl.w);
                sra_8(self.r,@temp); {sra (HL)}
                self.putbyte(r.hl.w,temp);
            end;
        $2f:sra_8(self.r,@r.a); {sra A}
        $30:sll_8(self.r,@r.bc.h); {sll B}
        $31:sll_8(self.r,@r.bc.l); {sll C}
        $32:sll_8(self.r,@r.de.h); {sll D}
        $33:sll_8(self.r,@r.de.l); {sll E}
        $34:sll_8(self.r,@r.hl.h); {sll H}
        $35:sll_8(self.r,@r.hl.l); {sll L}
        $36:begin  {sll (HL)}
                temp:=self.getbyte(r.hl.w);
                sll_8(self.r,@temp);
                self.putbyte(r.hl.w,temp);
            end;
        $37:sll_8(self.r,@r.a); {sll a}
        $38:srl_8(self.r,@r.bc.h); {srl B}
        $39:srl_8(self.r,@r.bc.l); {srl C}
        $3a:srl_8(self.r,@r.de.h); {srl D}
        $3b:srl_8(self.r,@r.de.l); {srl E}
        $3c:srl_8(self.r,@r.hl.h); {srl H}
        $3d:srl_8(self.r,@r.hl.l); {srl L}
        $3e:begin  {srl (HL)}
                temp:=self.getbyte(r.hl.w);
                srl_8(self.r,@temp);
                self.putbyte(r.hl.w,temp);
            end;
        $3f:srl_8(self.r,@r.a); {srl a}
        $40:bit_8(self.r,0,r.bc.h);  {bit 0,B}
        $41:bit_8(self.r,0,r.bc.l);  {bit 0,C}
        $42:bit_8(self.r,0,r.de.h);  {bit 0,D}
        $43:bit_8(self.r,0,r.de.l);  {bit 0,E}
        $44:bit_8(self.r,0,r.hl.h);  {bit 0,H}
        $45:bit_8(self.r,0,r.hl.l);  {bit 0,L}
        $46:bit_8(self.r,0,self.getbyte(r.hl.w)); {bit 0,(HL)}
        $47:bit_8(self.r,0,r.a);  {bit 0,A}
        $48:bit_8(self.r,1,r.bc.h);  {bit 1,B}
        $49:bit_8(self.r,1,r.bc.l);  {bit 1,C}
        $4a:bit_8(self.r,1,r.de.h);  {bit 1,D}
        $4b:bit_8(self.r,1,r.de.l);  {bit 1,E}
        $4c:bit_8(self.r,1,r.hl.h);  {bit 1,H}
        $4d:bit_8(self.r,1,r.hl.l);  {bit 1,L}
        $4e:bit_8(self.r,1,self.getbyte(r.hl.w));  {bit 1,(HL)}
        $4f:bit_8(self.r,1,r.a);  {bit 1,A}
        $50:bit_8(self.r,2,r.bc.h);  {bit 2,B}
        $51:bit_8(self.r,2,r.bc.l);  {bit 2,C}
        $52:bit_8(self.r,2,r.de.h);  {bit 2,D}
        $53:bit_8(self.r,2,r.de.l);  {bit 2,E}
        $54:bit_8(self.r,2,r.hl.h);  {bit 2,H}
        $55:bit_8(self.r,2,r.hl.l);  {bit 2,L}
        $56:bit_8(self.r,2,self.getbyte(r.hl.w));  {bit 2,(HL)}
        $57:bit_8(self.r,2,r.a);  {bit 2,A}
        $58:bit_8(self.r,3,r.bc.h);  {bit 3,B}
        $59:bit_8(self.r,3,r.bc.l);  {bit 3,C}
        $5a:bit_8(self.r,3,r.de.h);  {bit 3,D}
        $5b:bit_8(self.r,3,r.de.l);  {bit 3,E}
        $5c:bit_8(self.r,3,r.hl.h);  {bit 3,H}
        $5d:bit_8(self.r,3,r.hl.l);  {bit 3,L}
        $5e:bit_8(self.r,3,self.getbyte(r.hl.w));  {bit 3,(HL)}
        $5f:bit_8(self.r,3,r.a);  {bit 3,A}
        $60:bit_8(self.r,4,r.bc.h);  {bit 4,B}
        $61:bit_8(self.r,4,r.bc.l);  {bit 4,C}
        $62:bit_8(self.r,4,r.de.h);  {bit 4,D}
        $63:bit_8(self.r,4,r.de.l);  {bit 4,E}
        $64:bit_8(self.r,4,r.hl.h);  {bit 4,H}
        $65:bit_8(self.r,4,r.hl.l);  {bit 4,L}
        $66:bit_8(self.r,4,self.getbyte(r.hl.w)); {bit 4,(HL)}
        $67:bit_8(self.r,4,r.a);  {bit 4,A}
        $68:bit_8(self.r,5,r.bc.h);  {bit 5,B}
        $69:bit_8(self.r,5,r.bc.l);  {bit 5,C}
        $6a:bit_8(self.r,5,r.de.h);  {bit 5,D}
        $6b:bit_8(self.r,5,r.de.l);  {bit 5,E}
        $6c:bit_8(self.r,5,r.hl.h);  {bit 5,H}
        $6d:bit_8(self.r,5,r.hl.l);  {bit 5,L}
        $6e:bit_8(self.r,5,self.getbyte(r.hl.w)); {bit 5,(HL)}
        $6f:bit_8(self.r,5,r.a);  {bit 5,A}
        $70:bit_8(self.r,6,r.bc.h);  {bit 6,B}
        $71:bit_8(self.r,6,r.bc.l);  {bit 6,C}
        $72:bit_8(self.r,6,r.de.h);  {bit 6,D}
        $73:bit_8(self.r,6,r.de.l);  {bit 6,E}
        $74:bit_8(self.r,6,r.hl.h);  {bit 6,H}
        $75:bit_8(self.r,6,r.hl.l);  {bit 6,L}
        $76:bit_8(self.r,6,self.getbyte(r.hl.w)); {bit 6,(HL)}
        $77:bit_8(self.r,6,r.a);  {bit 6,A}
        $78:bit_7(self.r,r.bc.h);  {bit 7,B}
        $79:bit_7(self.r,r.bc.l);  {bit 7,C}
        $7a:bit_7(self.r,r.de.h);  {bit 7,D}
        $7b:bit_7(self.r,r.de.l);  {bit 7,E}
        $7c:bit_7(self.r,r.hl.h);  {bit 7,H}
        $7d:bit_7(self.r,r.hl.l);  {bit 7,L}
        $7e:bit_7(self.r,self.getbyte(r.hl.w));  {bit 7,(HL)}
        $7f:bit_7(self.r,r.a);  {bit 7,A}
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
        $09:add_16(self.r,registro,r.bc.w); {add IX,BC}
        $19:add_16(self.r,registro,r.de.w); {add IX,DE}
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
            end;
        $23:registro.w:=registro.w+1; {inc IX}
        $24:begin  {inc IXh}
                temp:=registro.h;
                inc_8(self.r,@temp);
                registro.h:=temp;
            end;
        $25:begin {dec IXh}
                temp:=registro^.h;
                dec_8(self.r,@temp);
                registro^.h:=temp;
            end;
        $26:begin  {ld IXh,n}
                registro^.h:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
            end;
        $29:add_16(self.r,registro,registro^.w); {add IX,IX}
        $2a:begin {ld (IX,(nn)}
                posicion.h:=self.getbyte(r.pc+1);
                posicion.l:=self.getbyte(r.pc);
                r.pc:=r.pc+2;
                registro^.l:=self.getbyte(posicion.w);
                registro^.h:=self.getbyte(posicion.w+1);
            end;
        $2b:registro^.w:=registro^.w-1; {dec IX}
        $2c:begin  {inc IXl}
                temp:=registro^.l;
                inc_8(self.r,@temp);
                registro^.l:=temp;
            end;
        $2d:begin  {dec IXl}
                temp:=registro^.l;
                dec_8(self.r,@temp);
                registro^.l:=temp;
            end;
        $2e:begin  {ld IXl,n}
                registro^.l:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
            end;
        $34:begin {inc (IX+d)} //debo tener en cuenta que temp2=registro.w
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                temp:=self.getbyte(temp2);
                inc_8(self.r,@temp);
                self.putbyte(temp2,temp);
            end;
        $35:begin {dec (IX+d)}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                temp:=self.getbyte(temp2);
                dec_8(self.r,@temp);
                self.putbyte(temp2,temp);
           end;
        $36:begin {ld (IX+d),n}
                temp:=self.getbyte(r.pc);
                temp2:=temp2+shortint(temp);
                temp:=self.getbyte(r.pc+1);
                r.pc:=r.pc+2;
                self.putbyte(temp2,temp);
            end;
        $39:add_16(self.r,registro,r.sp); {add IX,SP}
        $44:r.bc.h:=registro^.h; {ld B,IXh}
        $45:r.bc.h:=registro^.l; {ld B,IXl}
        $46:begin {ld B,(IX+d)}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                r.bc.h:=self.getbyte(temp2);
            end;
        $4c:r.bc.l:=registro^.h; {ld C,IXh}
        $4d:r.bc.l:=registro^.l; {ld C,IXl}
        $4e:begin {ld C,(IX+d)}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                r.bc.l:=self.getbyte(temp2);
            end;
        $54:r.de.h:=registro^.h;  {ld D,IXh}
        $55:r.de.h:=registro^.l;  {ld D,IXl}
        $56:begin {ld D,(IX+d)}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                r.de.h:=self.getbyte(temp2);
            end;
        $5c:r.de.l:=registro^.h;  {ld E,IXh}
        $5d:r.de.l:=registro^.l;  {ld E,IXh}
        $5e:begin {ld E,(IX+d)}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
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
                r.hl.l:=self.getbyte(temp2);
            end;
        $6f:registro^.l:=r.a; {ld IXl,A}
        $70:begin {ld (IX+d),B}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                self.putbyte(temp2,r.bc.h);
            end;
        $71:begin {ld (IX+d),C}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                self.putbyte(temp2,r.bc.l);
            end;
        $72:begin {ld (IX+d),D}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                self.putbyte(temp2,r.de.h);
            end;
        $73:begin {ld (IX+d),E}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                self.putbyte(temp2,r.de.l);
            end;
        $74:begin {ld (IX+d),H}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                self.putbyte(temp2,r.hl.h);
            end;
        $75:begin {ld (IX+d),L}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                self.putbyte(temp2,r.hl.l);
            end;
        $77:begin {ld (IX+d),A}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                self.putbyte(temp2,r.a);
            end;
        $7c:r.a:=registro^.h;  {ld A,IXh}
        $7d:r.a:=registro^.l; {ld A,IXl}
        $7e:begin {ld A,(IX+d)}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                r.a:=self.getbyte(temp2);
            end;
        $84:add_8(self.r,registro^.h);  {add A,IXh}
        $85:add_8(self.r,registro^.l);  {add A,IXl}
        $86:begin {add A,(IX+d)}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                temp:=self.getbyte(temp2);
                add_8(self.r,temp);
            end;
        $8c:adc_8(self.r,registro^.h);  {adc A,IXh}
        $8d:adc_8(self.r,registro^.l);  {adc A,IXl}
        $8e:begin {adc A,(IX+d)}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                temp:=self.getbyte(temp2);
                adc_8(self.r,temp);
        end;
        $94:sub_8(self.r,registro^.h); {sub IXh}
        $95:sub_8(self.r,registro^.l); {sub IXh}
        $96:begin {sub (IX+d)}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                temp:=self.getbyte(temp2);
                sub_8(self.r,temp);
        end;
        $9c:sbc_8(self.r,registro^.h); {sbc IXh}
        $9d:sbc_8(self.r,registro^.l); {sbc IXl}
        $9e:begin {sbc (IX+d)}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                temp:=self.getbyte(temp2);
                sbc_8(self.r,temp);
        end;
        $a4:and_a(self.r,registro^.h); {and IXh}
        $a5:and_a(self.r,registro^.l); {and IXl}
        $a6:begin {and A,(IX+d)}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                temp:=self.getbyte(temp2);
                and_a(self.r,temp);
        end;
        $ac:xor_a(self.r,registro^.h); {xor IXh}
        $ad:xor_a(self.r,registro^.l); {xor IXl}
        $ae:begin {xor A,(IX+d)}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                temp:=self.getbyte(temp2);
                xor_a(self.r,temp);
              end;
        $b4:or_a(self.r,registro^.h);  {or IXh}
        $b5:or_a(self.r,registro^.l);  {or IXl}
        $b6:begin  {or (IX+d)}
                 temp:=self.getbyte(r.pc);
                 r.pc:=r.pc+1;
                 temp2:=temp2+shortint(temp);
                 temp:=self.getbyte(temp2);
                 or_a(self.r,temp);
             end;
        $bc:cp_a(self.r,registro^.h); {cp IXh}
        $bd:cp_a(self.r,registro^.l); {cp IXl}
        $be:begin {cp (IX+d)}
                temp:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                temp2:=temp2+shortint(temp);
                temp:=self.getbyte(temp2);
                cp_a(self.r,temp);
        end;
        $cb:estados_dd_cb:=self.exec_dd_cb(tipo);
        $e1:registro.w:=self.pop_sp;  {pop IX}
        $e3:begin   {ex (SP),IX}
                posicion.w:=self.pop_sp;
                self.push_sp(registro^.w);
                registro^.w:=posicion.w;
             end;
        $e5:self.push_sp(registro^.w);  {push IX}
        $e9:r.pc:=registro^.w; {jp IX}
        $f9:r.sp:=registro^.w; {ld SP,IX}
        else begin
          //MessageDlg('Instruccion desconocida DD. PC= '+inttostr(r.pc.w), mtInformation,[mbOk], 0);
          r.pc:=r.pc-1;
          r.r:=(r.r-1) and $7f;
        end;
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
case instruccion of
        $00:begin {ld B,rlc (IX+d) >23t<}
                r.bc.h:=self.getbyte(temp2);
                rlc_8(self.r,@r.bc.h);
                self.putbyte(temp2,r.bc.h);
            end;
        $01:begin {ld C,rlc (IX+d) >23t<}
                r.bc.l:=self.getbyte(temp2);
                rlc_8(self.r,@r.bc.l);
                self.putbyte(temp2,r.bc.l);
            end;
        $02:begin {ld D,rlc (IX+d) >23t<}
                r.de.h:=self.getbyte(temp2);
                rlc_8(self.r,@r.de.h);
                self.putbyte(temp2,r.de.h);
            end;
        $03:begin {ld E,rlc (IX+d) >23t<}
                r.de.l:=self.getbyte(temp2);
                rlc_8(self.r,@r.de.l);
                self.putbyte(temp2,r.de.l);
            end;
        $04:begin {ld H,rlc (IX+d) >23t<}
                r.hl.h:=self.getbyte(temp2);
                rlc_8(self.r,@r.hl.h);
                self.putbyte(temp2,r.hl.h);
            end;
        $05:begin {ld L,rlc (IX+d) >23t<}
                r.hl.l:=self.getbyte(temp2);
                rlc_8(self.r,@r.hl.l);
                self.putbyte(temp2,r.hl.l);
            end;
        $06:begin {rlc (IX+d) >23t<}
                tempb:=self.getbyte(temp2);
                rlc_8(self.r,@tempb);
                self.putbyte(temp2,tempb);
            end;
        $07:begin {ld A,rlc (IX+d) >23t<}
                r.a:=self.getbyte(temp2);
                rlc_8(self.r,@r.a);
                self.putbyte(temp2,r.a);
            end;
        $08:begin {ld B,rrc (IX+d) >23t<}
                r.bc.h:=self.getbyte(temp2);
                rrc_8(self.r,@r.bc.h);
                self.putbyte(temp2,r.bc.h);
            end;
        $09:begin {ld C,rrc (IX+d) >23t<}
                r.bc.l:=self.getbyte(temp2);
                rrc_8(self.r,@r.bc.l);
                self.putbyte(temp2,r.bc.l);
            end;
        $0a:begin {ld D,rrc (IX+d) >23t<}
                r.de.h:=self.getbyte(temp2);
                rrc_8(self.r,@r.de.h);
                self.putbyte(temp2,r.de.h);
            end;
        $0b:begin {ld E,rrc (IX+d) >23t<}
                r.de.l:=self.getbyte(temp2);
                rrc_8(self.r,@r.de.l);
                self.putbyte(temp2,r.de.l);
            end;
        $0c:begin {ld H,rrc (IX+d) >23t<}
                r.hl.h:=self.getbyte(temp2);
                rrc_8(self.r,@r.hl.h);
                self.putbyte(temp2,r.hl.h);
            end;
        $0d:begin {ld L,rlc (IX+d) >23t<}
                r.hl.l:=self.getbyte(temp2);
                rrc_8(self.r,@r.hl.l);
                self.putbyte(temp2,r.hl.l);
            end;
        $0e:begin   {rrc (IX+d)}
                tempb:=self.getbyte(temp2);
                rrc_8(self.r,@tempb);
                self.putbyte(temp2,tempb);
            end;
        $0f:begin {ld A,rrc (IX+d)}
                r.a:=self.getbyte(temp2);
                rrc_8(self.r,@r.a);
                self.putbyte(temp2,r.a);
            end;
        $10:begin {ld B,rl (IX+d)}
                r.bc.h:=self.getbyte(temp2);
                rl_8(self.r,@r.bc.h);
                self.putbyte(temp2,r.bc.h);
            end;
        $11:begin {ld C,rl (IX+d)}
                r.bc.l:=self.getbyte(temp2);
                rl_8(self.r,@r.bc.l);
                self.putbyte(temp2,r.bc.l);
            end;
        $12:begin {ld D,rl (IX+d)}
                r.de.h:=self.getbyte(temp2);
                rl_8(self.r,@r.de.h);
                self.putbyte(temp2,r.de.h);
            end;
        $13:begin {ld E,rl (IX+d)}
                r.de.l:=self.getbyte(temp2);
                rl_8(self.r,@r.de.l);
                self.putbyte(temp2,r.de.l);
            end;
        $14:begin {ld H,rl (IX+d)}
                r.hl.h:=self.getbyte(temp2);
                rl_8(self.r,@r.hl.h);
                self.putbyte(temp2,r.hl.h);
            end;
        $15:begin {ld L,rlc (IX+d)}
                r.hl.l:=self.getbyte(temp2);
                rl_8(self.r,@r.hl.l);
                self.putbyte(temp2,r.hl.l);
            end;
        $16:begin {rl (IX+d)}
                tempb:=self.getbyte(temp2);
                rl_8(self.r,@tempb);
                self.putbyte(temp2,tempb);
            end;
        $17:begin {ld A,rl (IX+d)}
                r.a:=self.getbyte(temp2);
                rl_8(self.r,@r.a);
                self.putbyte(temp2,r.a);
            end;
        $18:begin {ld B,rr (IX+d)}
                r.bc.h:=self.getbyte(temp2);
                rr_8(self.r,@r.bc.h);
                self.putbyte(temp2,r.bc.h);
            end;
        $19:begin {ld C,rr (IX+d)}
                r.bc.l:=self.getbyte(temp2);
                rr_8(self.r,@r.bc.l);
                self.putbyte(temp2,r.bc.l);
            end;
        $1a:begin {ld D,rr (IX+d)}
                r.de.h:=self.getbyte(temp2);
                rr_8(self.r,@r.de.h);
                self.putbyte(temp2,r.de.h);
            end;
        $1b:begin {ld E,rr (IX+d)}
                r.de.l:=self.getbyte(temp2);
                rr_8(self.r,@r.de.l);
                self.putbyte(temp2,r.de.l);
            end;
        $1c:begin {ld H,rr (IX+d)}
                r.hl.h:=self.getbyte(temp2);
                rr_8(self.r,@r.hl.h);
                self.putbyte(temp2,r.hl.h);
            end;
        $1d:begin {ld L,rr (IX+d)}
                r.hl.l:=self.getbyte(temp2);
                rr_8(self.r,@r.hl.l);
                self.putbyte(temp2,r.hl.l);
            end;
        $1e:begin  {rr (IX+d)}
                tempb:=self.getbyte(temp2);
                rr_8(self.r,@tempb);
                self.putbyte(temp2,tempb);
            end;
        $1f:begin {ld A,rr (IX+d)}
                r.a:=self.getbyte(temp2);
                rr_8(self.r,@r.a);
                self.putbyte(temp2,r.a);
            end;
        $20:begin {ld B,sla (IX+d)}
                r.bc.h:=self.getbyte(temp2);
                sla_8(self.r,@r.bc.h);
                self.putbyte(temp2,r.bc.h);
            end;
        $21:begin {ld C,sla (IX+d)}
                r.bc.l:=self.getbyte(temp2);
                sla_8(self.r,@r.bc.l);
                self.putbyte(temp2,r.bc.l);
            end;
        $22:begin {ld D,sla (IX+d)}
                r.de.h:=self.getbyte(temp2);
                sla_8(self.r,@r.de.h);
                self.putbyte(temp2,r.de.h);
            end;
        $23:begin {ld E,sla (IX+d)}
                r.de.l:=self.getbyte(temp2);
                rlc_8(self.r,@r.de.l);
                self.putbyte(temp2,r.de.l);
            end;
        $24:begin {ld H,sla (IX+d)}
                r.hl.h:=self.getbyte(temp2);
                sla_8(self.r,@r.hl.h);
                self.putbyte(temp2,r.hl.h);
            end;
        $25:begin {ld L,sla (IX+d)}
                r.hl.l:=self.getbyte(temp2);
                sla_8(self.r,@r.hl.l);
                self.putbyte(temp2,r.hl.l);
            end;
        $26:begin  {sla (IX+d)}
                tempb:=self.getbyte(temp2);
                sla_8(self.r,@tempb);
                self.putbyte(temp2,tempb);
            end;
        $27:begin {ld A,sla (IX+d)}
                r.a:=self.getbyte(temp2);
                sla_8(self.r,@r.a);
                self.putbyte(temp2,r.a);
            end;
        $28:begin {ld B,sra (IX+d)}
                r.bc.h:=self.getbyte(temp2);
                sra_8(self.r,@r.bc.h);
                self.putbyte(temp2,r.bc.h);
            end;
        $29:begin {ld C,sra (IX+d)}
                r.bc.l:=self.getbyte(temp2);
                sra_8(self.r,@r.bc.l);
                self.putbyte(temp2,r.bc.l);
            end;
        $2a:begin {ld D,sra (IX+d)}
                r.de.h:=self.getbyte(temp2);
                sra_8(self.r,@r.de.h);
                self.putbyte(temp2,r.de.h);
            end;
        $2b:begin {ld E,sra (IX+d)}
                r.de.l:=self.getbyte(temp2);
                sra_8(self.r,@r.de.l);
                self.putbyte(temp2,r.de.l);
            end;
        $2c:begin {ld H,sra (IX+d)}
                r.hl.h:=self.getbyte(temp2);
                sra_8(self.r,@r.hl.h);
                self.putbyte(temp2,r.hl.h);
            end;
        $2d:begin {ld L,sra (IX+d)}
                r.hl.l:=self.getbyte(temp2);
                sra_8(self.r,@r.hl.l);
                self.putbyte(temp2,r.hl.l);
            end;
        $2e:begin  {sra (IX+d)}
                tempb:=self.getbyte(temp2);
                sra_8(self.r,@tempb);
                self.putbyte(temp2,tempb);
            end;
        $2f:begin {ld A,sra (IX+d)}
                r.a:=self.getbyte(temp2);
                sra_8(self.r,@r.a);
                self.putbyte(temp2,r.a);
            end;
        $30:begin {ld B,sll (IX+d)}
                r.bc.h:=self.getbyte(temp2);
                sll_8(self.r,@r.bc.h);
                self.putbyte(temp2,r.bc.h);
            end;
        $31:begin {ld C,sll (IX+d)}
                r.bc.l:=self.getbyte(temp2);
                sll_8(self.r,@r.bc.l);
                self.putbyte(temp2,r.bc.l);
            end;
        $32:begin {ld D,sll (IX+d)}
                r.de.h:=self.getbyte(temp2);
                sll_8(self.r,@r.de.h);
                self.putbyte(temp2,r.de.h);
            end;
        $33:begin {ld E,sll (IX+d)}
                r.de.l:=self.getbyte(temp2);
                sll_8(self.r,@r.de.l);
                self.putbyte(temp2,r.de.l);
            end;
        $34:begin {ld H,sll (IX+d)}
                r.hl.h:=self.getbyte(temp2);
                sll_8(self.r,@r.hl.h);
                self.putbyte(temp2,r.hl.h);
            end;
        $35:begin {ld L,sll (IX+d)}
                r.hl.l:=self.getbyte(temp2);
                sll_8(self.r,@r.hl.l);
                self.putbyte(temp2,r.hl.l);
            end;
        $36:begin {sll (IX+d)}
                tempb:=self.getbyte(temp2);
                sll_8(self.r,@tempb);
                self.putbyte(temp2,tempb);
            end;
        $37:begin {ld A,sll (IX+d)}
                r.a:=self.getbyte(temp2);
                sll_8(self.r,@r.a);
                self.putbyte(temp2,r.a);
            end;
        $38:begin {ld B,srl (IX+d)}
                r.bc.h:=self.getbyte(temp2);
                srl_8(self.r,@r.bc.h);
                self.putbyte(temp2,r.bc.h);
            end;
        $39:begin {ld C,srl (IX+d)}
                r.bc.l:=self.getbyte(temp2);
                srl_8(self.r,@r.bc.l);
                self.putbyte(temp2,r.bc.l);
            end;
        $3a:begin {ld D,srl (IX+d)}
                r.de.h:=self.getbyte(temp2);
                srl_8(self.r,@r.de.h);
                self.putbyte(temp2,r.de.h);
            end;
        $3b:begin {ld E,srl (IX+d)}
                r.de.l:=self.getbyte(temp2);
                srl_8(self.r,@r.de.l);
                self.putbyte(temp2,r.de.l);
            end;
        $3c:begin {ld H,srl (IX+d)}
                r.hl.h:=self.getbyte(temp2);
                srl_8(self.r,@r.hl.h);
                self.putbyte(temp2,r.hl.h);
            end;
        $3d:begin {ld L,srl (IX+d)}
                r.hl.l:=self.getbyte(temp2);
                srl_8(self.r,@r.hl.l);
                self.putbyte(temp2,r.hl.l);
            end;
        $3e:begin  {srl (IX+d)}
                tempb:=self.getbyte(temp2);
                srl_8(self.r,@tempb);
                self.putbyte(temp2,tempb);
            end;
        $3f:begin {ld A,srl (IX+d)}
                r.a:=self.getbyte(temp2);
                srl_8(self.r,@r.a);
                self.putbyte(temp2,r.a);
            end;
        $40..$47:begin {bit 0,(IX+d)}
                 tempb:=self.getbyte(temp2);
                 bit_8(self.r,0,tempb);
                 r.f.bit5:=(temp2 and $2000)<>0;
                 r.f.bit3:=(temp2 and $800)<>0;
            end;
        $48..$4f:begin {bit 1,(IX+d)}
                 tempb:=self.getbyte(temp2);
                 bit_8(self.r,1,tempb);
                 r.f.bit5:=(temp2 and $2000)<>0;
                 r.f.bit3:=(temp2 and $800)<>0;
            end;
        $50..$57:begin {bit 2,(IX+d)}
                 tempb:=self.getbyte(temp2);
                 bit_8(self.r,2,tempb);
                 r.f.bit5:=(temp2 and $2000)<>0;
                 r.f.bit3:=(temp2 and $800)<>0;
            end;
        $58..$5f:begin {bit 3,(IX+d)}
                 tempb:=self.getbyte(temp2);
                 bit_8(self.r,3,tempb);
                 r.f.bit5:=(temp2 and $2000)<>0;
                 r.f.bit3:=(temp2 and $800)<>0;
            end;
        $60..$67:begin {bit 4,(IX+d)}
                 tempb:=self.getbyte(temp2);
                 bit_8(self.r,4,tempb);
                 r.f.bit5:=(temp2 and $2000)<>0;
                 r.f.bit3:=(temp2 and $800)<>0;
            end;
        $68..$6f:begin {bit 5,(IX+d)}
                 tempb:=self.getbyte(temp2);
                 bit_8(self.r,5,tempb);
                 r.f.bit5:=(temp2 and $2000)<>0;
                 r.f.bit3:=(temp2 and $800)<>0;
            end;
        $70..$77:begin {bit 6,(IX+d)}
                 tempb:=self.getbyte(temp2);
                 bit_8(self.r,6,tempb);
                 r.f.bit5:=(temp2 and $2000)<>0;
                 r.f.bit3:=(temp2 and $800)<>0;
            end;
        $78..$7f:begin {bit 7,(IX+d)}
                 tempb:=self.getbyte(temp2);
                 bit_7(self.r,tempb);
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
        $41:if @self.out_port<>nil then self.out_port(r.bc.h,r.bc.w); {out (C),B}
        $42:sbc_16(self.r,@r.hl,r.bc.w); {sbc HL,BC}
        $43:begin {ld (nn),BC}
                posicion.h:=self.getbyte(r.pc+1);
                posicion.l:=self.getbyte(r.pc);
                r.pc:=r.pc+2;
                self.putbyte(posicion.w,r.bc.l);
                self.putbyte(posicion.w+1,r.bc.h);
            end;
        $44,$4c,$54,$5c,$64,$6c,$74,$7c:begin  {neg}
                temp:=r.a;
                r.a:=0;
                sub_8(self.r,temp);
            end;
        $45,$55,$65,$75:begin  {retn}
                r.pc:=pop_sp;
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
        $49:if @self.out_port<>nil then self.out_port(r.bc.l,r.bc.w); {out (C),C}
        $4a:adc_16(self.r,@r.hl,r.bc.w); {adc HL,BC}
        $4b:begin  {ld BC,(nn)}
                posicion.h:=self.getbyte(r.pc+1);
                posicion.l:=self.getbyte(r.pc);
                r.pc:=r.pc+2;;
                r.bc.l:=self.getbyte(posicion.w);
                r.bc.h:=self.getbyte(posicion.w+1);
            end;
        {4c: neg}
        $4d,$5d,$6d,$7d:begin   {reti}
                r.iff1:=r.iff2;
                r.pc:=pop_sp;
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
        $51:if @self.out_port<>nil then self.out_port(r.de.h,r.bc.w); {out (C),D}
        $52:sbc_16(self.r,@r.hl,r.de.w); {sbc HL,DE}
        $53:begin {ld (nn),DE}
                posicion.h:=self.getbyte(r.pc+1);
                posicion.l:=self.getbyte(r.pc);
                r.pc:=r.pc+2;;
                self.putbyte(posicion.w,r.de.l);
                self.putbyte(posicion.w+1,r.de.h);
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
        $59:if @self.out_port<>nil then self.out_port(r.de.l,r.bc.w); {out (C),E}
        $5a:adc_16(self.r,@r.hl,r.de.w); {adc HL,DE}
        $5b:begin  {ld DE,(nn)}
                posicion.h:=self.getbyte(r.pc+1);
                posicion.l:=self.getbyte(r.pc);
                r.pc:=r.pc+2;;
                r.de.l:=self.getbyte(posicion.w);
                r.de.h:=self.getbyte(posicion.w+1);
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
        $61:if @self.out_port<>nil then self.out_port(r.hl.h,r.bc.w); {out (C),H}
        $62:sbc_16(self.r,@r.hl,r.hl.w); {sbc HL,HL}
        $63:begin {ld (nn),HL}
                posicion.h:=self.getbyte(r.pc+1);
                posicion.l:=self.getbyte(r.pc);
                r.pc:=r.pc+2;;
                self.putbyte(posicion.w,r.hl.l);
                self.putbyte(posicion.w+1,r.hl.h);
            end;
        {64:neg
        $65:retn
        $66:im 0}
        $67:begin {rrd}
                temp2:=self.getbyte(r.hl.w);
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
        $69:if @self.out_port<>nil then self.out_port(r.hl.l,r.bc.w); {out (C),L}
        $6a:adc_16(self.r,@r.hl,r.hl.w); {adc HL,HL}
        $6b:begin  {ld HL,(nn)}
                posicion.h:=self.getbyte(r.pc+1);
                posicion.l:=self.getbyte(r.pc);
                r.pc:=r.pc+2;;
                r.hl.l:=self.getbyte(posicion.w);
                r.hl.h:=self.getbyte(posicion.w+1);
            end;
        {6c:neg
        $6d:reti
        $6e:im 0}
        $6f:begin  {rld}
                temp2:=self.getbyte(r.hl.w);
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
        $71:if @self.out_port<>nil then self.out_port(0,r.bc.w); {out (C),0}
        $72:sbc_16(self.r,@r.hl,r.sp); {sbc HL,SP}
        $73:begin {ld (nn),SP}
                posicion.h:=self.getbyte(r.pc+1);
                posicion.l:=self.getbyte(r.pc);
                r.pc:=r.pc+2;;
                self.putbyte(posicion.w,r.sp and $ff);
                self.putbyte(posicion.w+1,r.sp shr 8);
            end;
        {74:neg
        $75:retn
        $76:im 1
        $77:nop*2}
        $78:begin       {in A,(C)}
                if @self.in_port<>nil then r.a:=self.in_port(r.bc.w)
                  else r.a:=$ff;
                r.f.z:=(r.a=0);
                r.f.s:=(r.a And $80) <> 0;
                r.f.bit3:=(r.a And 8) <> 0;
                r.f.bit5:=(r.a And $20) <> 0;
                r.f.p_v:= paridad[r.a];
                r.f.n:=false;
                r.f.h:=false;
            end;
        $79:if @self.out_port<>nil then self.out_port(r.a,r.bc.w); {out (C),A}
        $7a:adc_16(self.r,@r.hl,r.sp); {adc HL,SP}
        $7b:begin  {ld SP,(nn)}
                posicion.h:=self.getbyte(r.pc+1);
                posicion.l:=self.getbyte(r.pc);
                r.pc:=r.pc+2;;
                r.sp:=self.getbyte(posicion.w)+(self.getbyte(posicion.w+1) shl 8);
            end;
        {7c:neg
        $7d:reti
        $7e:im 2
        $7f..9c:nop*2}
        $a0:begin   {ldi}
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
                 self.putbyte(r.hl.w,temp);
                 r.bc.h:=r.bc.h-1;
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
                 r.bc.h:=r.bc.h-1;
                 if @self.out_port<>nil then self.out_port(self.getbyte(r.hl.w),r.bc.w);
                 r.hl.w:=r.hl.w+1;
                 r.f.z:=(r.bc.h=0);
                 r.f.n:= True;
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
        $ab:begin   {outd}
                 temp:=self.getbyte(r.hl.w);
                 r.bc.h:=r.bc.h-1;
                 if @self.out_port<>nil then self.out_port(self.getbyte(r.hl.w),r.bc.w);
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
        $b0:begin {ldir}
                 temp:=self.getbyte(r.hl.w);
                 r.hl.w:=r.hl.w+1;
                 self.putbyte(r.de.w,temp);
                 r.de.w:=r.de.w+1;
                 r.bc.w:=r.bc.w-1;
                 if (r.bc.w<>0) then begin
                        r.pc:=r.pc-2;
                        estados_demas:=z80t_ex[instruccion];
                 end;
                 r.f.p_v:=(r.bc.w<>0);
                 r.f.n:=false;
                 r.f.h:=false;
                 temp:=temp+r.a;
                 r.f.bit5:=(temp and 2)<>0;
                 r.f.bit3:=(temp and 8)<>0;
             end;
        $b1:begin  {cpir}
                temp2:=self.getbyte(r.hl.w);
                temp:=r.a-temp2;
                temp3:=r.a xor temp2 xor temp;
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
                end;
            end;
        $b2:begin  //inir añadido el 05-10-08, lo usa una rom de Coleco!
                if @self.in_port<>nil then temp:=self.in_port(r.bc.w)
                  else temp:=$ff;
                self.putbyte(r.hl.w,temp);
                r.bc.h:=r.bc.h-1;
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
                if @self.out_port<>nil then self.out_port(self.getbyte(r.hl.w),r.bc.w);
                r.hl.w:=r.hl.w+1;
                r.f.n:=(temp and $80)<>0;
                tempw:=temp+r.hl.l;
                r.f.h:=(tempw and $100)<>0;
                r.f.c:=(tempw and $100)<>0;
                r.f.p_v:=paridad[(tempw and $7) xor r.bc.h];
                r.f.z:=(r.bc.h=0);
                r.f.bit5:=(r.bc.h and $20)<>0;
                r.f.bit3:=(r.bc.h and 8)<>0;
                r.f.z:=(r.bc.h and $80)<>0;
                if r.bc.h<>0 then begin
                  r.pc:=r.pc-2;
                  estados_demas:=z80t_ex[instruccion];
                end;
            end;
        { $b4..$b7:nop*2}
        $b8:begin {lddr}
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
                end;
             end;
        $b9:begin   {cpdr}
                 temp2:=self.getbyte(r.hl.w);
                 temp:=r.a-temp2;
                 temp3:=r.a xor temp2 xor temp;
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
                 end;
             end;
        $ba:begin  //indr  >16t<
                 if @self.in_port<>nil then temp:=self.in_port(r.bc.w)
                  else temp:=$ff;
                 self.putbyte(r.hl.w,temp);
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
                if @self.out_port<>nil then self.out_port(temp,r.bc.w);
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
