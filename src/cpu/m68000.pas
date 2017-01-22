unit m68000;

{
06/01/09 - Version 1.0 - Aqui empieza todo!!
15/02/10 - Version 2.0 - Renovado el emulador
  analizados todos los bits de los opcodes.
06/08/10 - Corregidos
           Opcode ABCD
           EA indirecto indexado con desplazamiento tipo word y añadido long (corrige Rastan)
           Opcodes tipo $e cantidad de repeticiones cuando es un registro (corrige demo F1 dream)
           Corregidas las condiciones de salto (corrige Snow Bros)
           Añadidos dos opcodes de movep
           Añadido un opcode bclr 32 bits
           Limpieza opcodes bclr, bset, bcmp, bchg
05/09/10   Corregido movem
20/09/10   Corregido sbcd
23/09/10   Corregido asl.b
25/12/10   Añadido TAS y algunos modos de direccionamiento
20/04/11   Añadidos mas modos de dir en movem y corregido privilegio en 'move from sr'
           corregido flag 'c' en cmpi.l
14/12/12   Convertido a Clase
27/01/13   Añadido STOP
14/02/13   Añadido movem.l opcode $33 direccionamiento $30..$37
04/06/14   Opcode $6Xff --> Illegal
13/07/14   Añadido opcodes negx y dirs pea $28..$38
02/08/14   Corregido STOP
14/09/14   Añadida asl.w
12/10/14   Revisados los opcodes $Exxx
}

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     sysutils,dialogs,cpu_misc,timer_engine,vars_hide,main_engine;

type
        band_m68000=record
                t,s,i,x,n,z,v,c:boolean;
                im:byte;
        end;
        reg_m68000=record
                pc:dparejas;
                ppc:dparejas;
                d:array[0..7] of dparejas;
                a:array[0..7] of dparejas;
                usp,isp,sp:pdparejas;
                cc:band_m68000;
        end;
        preg_m68000=^reg_m68000;
        cpu_m68000=class(cpu_class)
            constructor create(clock:dword;frames_div:word);
            destructor free;
          public
            getword_:tgetword;
            putword_:tputword;
            halt:boolean;
            irq:array[0..7] of byte;
            access_8bits_hi_dir,access_8bits_lo_dir:boolean;
            r:preg_m68000;
            procedure reset;
            procedure run(maximo:single);
            function get_internal_r:preg_m68000;
            procedure change_ram16_calls(getword:tgetword;putword:tputword);
            function save_snapshot(data:pbyte):word;
            procedure load_snapshot(data:pbyte);
          private
            //r:preg_m68000;
            ea:dword;
            prefetch:boolean;
            temp:dparejas;
            procedure poner_band(pila:word);
            function getbyte(addr:dword):byte;
            procedure putbyte(addr:dword;val:byte);
            function getword(addr:dword):word;
            procedure putword(addr:dword;val:word);
            //byte
            function leerdir_b(dir:byte):byte;
            procedure ponerdir_b2(des,res:byte);
            procedure ponerdir_b(des,res:byte);
            //word
            function leerdir_w(dir:byte):word;
            procedure ponerdir_w2(des:byte;res:word);
            procedure ponerdir_w(des:byte;res:word);
            //dword
            function leerdir_l(dir:byte):dword;
            procedure ponerdir_l2(des:byte;res:dword);
            procedure ponerdir_l(des:byte;res:dword);
            //EA
            function leerdir_ea(dir:byte):dword;
        end;

var
    m68000_0,m68000_1:cpu_m68000;

implementation
const
  m68ki_shift_8_table:array[0..64] of byte=(
  $00, $80, $c0, $e0, $f0, $f8, $fc, $fe, $ff, $ff, $ff, $ff,
	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,
	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,
	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,
	$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,
	$ff, $ff, $ff, $ff, $ff);
  m68ki_shift_16_table:array[0..64] of word=(
	$0000, $8000, $c000, $e000, $f000, $f800, $fc00, $fe00, $ff00,
	$ff80, $ffc0, $ffe0, $fff0, $fff8, $fffc, $fffe, $ffff, $ffff,
	$ffff, $ffff, $ffff, $ffff, $ffff, $ffff, $ffff, $ffff, $ffff,
	$ffff, $ffff, $ffff, $ffff, $ffff, $ffff, $ffff, $ffff, $ffff,
	$ffff, $ffff, $ffff, $ffff, $ffff, $ffff, $ffff, $ffff, $ffff,
	$ffff, $ffff, $ffff, $ffff, $ffff, $ffff, $ffff, $ffff, $ffff,
	$ffff, $ffff, $ffff, $ffff, $ffff, $ffff, $ffff, $ffff, $ffff,
	$ffff, $ffff);
  m68ki_shift_32_table:array[0..64] of dword=(
	$00000000, $80000000, $c0000000, $e0000000, $f0000000, $f8000000,
	$fc000000, $fe000000, $ff000000, $ff800000, $ffc00000, $ffe00000,
	$fff00000, $fff80000, $fffc0000, $fffe0000, $ffff0000, $ffff8000,
	$ffffc000, $ffffe000, $fffff000, $fffff800, $fffffc00, $fffffe00,
	$ffffff00, $ffffff80, $ffffffc0, $ffffffe0, $fffffff0, $fffffff8,
	$fffffffc, $fffffffe, $ffffffff, $ffffffff, $ffffffff, $ffffffff,
	$ffffffff, $ffffffff, $ffffffff, $ffffffff, $ffffffff, $ffffffff,
	$ffffffff, $ffffffff, $ffffffff, $ffffffff, $ffffffff, $ffffffff,
	$ffffffff, $ffffffff, $ffffffff, $ffffffff, $ffffffff, $ffffffff,
	$ffffffff, $ffffffff, $ffffffff, $ffffffff, $ffffffff, $ffffffff,
	$ffffffff, $ffffffff, $ffffffff, $ffffffff, $ffffffff);

  addr_mask=$fffffe;

constructor cpu_m68000.create(clock:dword;frames_div:word);
begin
getmem(self.r,sizeof(reg_m68000));
fillchar(self.r^,sizeof(reg_m68000),0);
self.numero_cpu:=cpu_main_init(clock);
self.clock:=clock;
self.tframes:=(clock/frames_div)/llamadas_maquina.fps_max;
end;

destructor cpu_m68000.free;
begin
if Self.r<>nil then begin
  freemem(self.r);
  self.r:=nil;
end;
end;

function cpu_m68000.getword(addr:dword):word;
begin
getword:=self.getword_(addr and addr_mask);
end;

procedure cpu_m68000.putword(addr:dword;val:word);
begin
self.putword_(addr and addr_mask,val);
end;

function cpu_m68000.get_internal_r:preg_m68000;
begin
  get_internal_r:=self.r;
end;

procedure cpu_m68000.change_ram16_calls(getword:tgetword;putword:tputword);
begin
  self.getword_:=getword;
  self.putword_:=putword;
end;

procedure cpu_m68000.reset;
var
  f:byte;
begin
r.cc.s:=true;
r.cc.z:=true;
self.prefetch:=false;
r.cc.im:=7;
r.sp:=@r.a[7];
r.isp:=@r.a[7];
r.usp:=@self.temp;
self.opcode:=true;
r.sp.wh:=self.getword(0);
r.sp.wl:=self.getword(2);
r.pc.wh:=self.getword(4);
r.pc.wl:=self.getword(6);
for f:=0 to 7 do self.irq[f]:=CLEAR_LINE;
self.change_halt(CLEAR_LINE);
self.change_reset(CLEAR_LINE);
self.halt:=false;
self.access_8bits_hi_dir:=false;
self.access_8bits_lo_dir:=false;
end;

procedure cpu_m68000.poner_band(pila:word);
var
  temp:dword;
begin
if (r.cc.s and ((pila and $2000)=0)) then begin //quita supervisor
  temp:=r.a[7].l;
  r.usp:=@r.a[7];
  r.a[7].l:=self.temp.l;
  r.isp:=@self.temp;
  self.temp.l:=temp;
  r.cc.s:=false;
end else begin
  if (not(r.cc.s) and ((pila and $2000)<>0)) then begin //pone supervisor
    temp:=r.a[7].l;
    r.isp:=@r.a[7];
    r.a[7].l:=self.temp.l;
    r.usp:=@self.temp;
    self.temp.l:=temp;
    r.cc.s:=true;
  end;
end;
r.cc.t:=(pila and $8000)<>0;
r.cc.im:=(pila shr 8) and 7;
r.cc.x:=(pila and $10)<>0;
r.cc.n:=(pila and $8)<>0;
r.cc.z:=(pila and $4)<>0;
r.cc.v:=(pila and $2)<>0;
r.cc.c:=(pila and $1)<>0;
end;

function coger_band(r:preg_m68000):word;inline;
var
  pila:word;
begin
pila:=byte(r.cc.t) shl 15; // $8000
pila:=pila or (byte(r.cc.s) shl 13); // $2000
pila:=pila or (r.cc.im shl 8);
pila:=pila or (byte(r.cc.x) shl 4);
pila:=pila or (byte(r.cc.n) shl 3);
pila:=pila or (byte(r.cc.z) shl 2);
pila:=pila or (byte(r.cc.v) shl 1);
coger_band:=pila or byte(r.cc.c);
end;

function cpu_m68000.save_snapshot(data:pbyte):word;
var
  temp:pbyte;
  size,temp_w:word;
begin
  temp:=data;
  copymemory(temp,@self.irq[0],8);inc(temp,8);size:=8;
  copymemory(temp,@self.r.pc,sizeof(dparejas));inc(temp,sizeof(dparejas));size:=size+sizeof(dparejas);
  copymemory(temp,@self.r.ppc,sizeof(dparejas));inc(temp,sizeof(dparejas));size:=size+sizeof(dparejas);
  copymemory(temp,@self.r.d[0],sizeof(dparejas)*8);inc(temp,sizeof(dparejas)*8);size:=size+(sizeof(dparejas)*8);
  copymemory(temp,@self.r.a[0],sizeof(dparejas)*8);inc(temp,sizeof(dparejas)*8);size:=size+(sizeof(dparejas)*8);
  temp_w:=coger_band(self.r);
  copymemory(temp,@temp_w,2);inc(temp,2);size:=size+2;
  copymemory(temp,@self.ea,4);inc(temp,4);size:=size+4;
  temp^:=byte(self.prefetch);inc(temp);size:=size+1;
  copymemory(temp,@self.temp,sizeof(dparejas));size:=size+sizeof(dparejas);
  save_snapshot:=size;
end;

procedure cpu_m68000.load_snapshot(data:pbyte);
var
  temp:pbyte;
  temp_w:word;
begin
  temp:=data;
  copymemory(@self.irq[0],temp,8);inc(temp,8);
  copymemory(@self.r.pc,temp,sizeof(dparejas));inc(temp,sizeof(dparejas));
  copymemory(@self.r.ppc,temp,sizeof(dparejas));inc(temp,sizeof(dparejas));
  copymemory(@self.r.d[0],temp,sizeof(dparejas)*8);inc(temp,sizeof(dparejas)*8);
  copymemory(@self.r.a[0],temp,sizeof(dparejas)*8);inc(temp,sizeof(dparejas)*8);
  copymemory(@temp_w,temp,2);inc(temp,2);
  poner_band(temp_w);
  copymemory(@self.ea,temp,4);inc(temp,4);
  self.prefetch:=(temp^<>0);inc(temp);
  copymemory(@self.temp,temp,sizeof(dparejas));
end;

function cpu_m68000.getbyte(addr:dword):byte;
var
  tempw:word;
begin
if (addr and 1)<>0 then begin
  self.access_8bits_hi_dir:=true;
  tempw:=self.getword(addr);
  getbyte:=tempw and $ff;
  self.access_8bits_hi_dir:=false;
end else begin
  self.access_8bits_lo_dir:=true;
  tempw:=self.getword(addr);
  getbyte:=tempw shr 8;
  self.access_8bits_lo_dir:=false;
end;
end;

procedure cpu_m68000.putbyte(addr:dword;val:byte);
var
  tempw:word;
begin
tempw:=self.getword(addr);
if (addr and 1)<>0 then begin
  self.access_8bits_hi_dir:=true;
  self.putword(addr,(tempw and $ff00) or val);
  self.access_8bits_hi_dir:=false;
end else begin
  self.access_8bits_lo_dir:=true;
  self.putword(addr,(tempw and $ff) or (val shl 8));
  self.access_8bits_lo_dir:=false;
end;
end;

function cpu_m68000.leerdir_b(dir:byte):byte;
var
  des:byte;
  desp:word;
begin
case dir of
  $0..$7:begin //registro DX Dn
            leerdir_b:=r.d[dir and $7].l0;
            exit;
         end;
  $8..$f:begin //registro AX An
            leerdir_b:=r.a[dir and $7].l0;
            exit;
         end;
  $10..$17:self.ea:=r.a[dir and $7].l;  //Registro indirecto AX (An)
  $18..$1f:begin  //indirecto con postincremento (An)+
              self.ea:=r.a[dir and $7].l;
              r.a[dir and $7].l:=self.ea+1;
           end;
  $20..$27:begin //AX predecremento -(An)
              r.a[(dir and $7)].l:=r.a[(dir and $7)].l-1;
              self.ea:=r.a[dir and $7].l;
           end;
  $28..$2f:begin  //AX indirecto con desplazamiento d(An)
              desp:=self.getword(r.pc.l);
              r.pc.l:=r.pc.l+2;
              self.ea:=r.a[dir and $7].l+smallint(desp);
           end;
  $30..$37:begin  //AX indirecto indexado con desplazamiento d(An,ix)
              desp:=self.getword(r.pc.l);
              r.pc.l:=r.pc.l+2;
              des:=desp and $ff;
              if (desp and $8000)<>0 then begin
                if (desp and $800)<>0 then self.ea:=r.a[dir and $7].l+r.a[(desp shr 12) and $7].l+shortint(des)
                  else self.ea:=r.a[dir and $7].l+smallint(r.a[(desp shr 12) and $7].wl)+shortint(des);
              end else begin
                if (desp and $800)<>0 then self.ea:=r.a[dir and $7].l+r.d[(desp shr 12) and $7].l+shortint(des)
                  else self.ea:=r.a[dir and $7].l+smallint(r.d[(desp shr 12) and $7].wl)+shortint(des);
              end;
           end;
  $38:begin //word indirecto xxx.W
        self.ea:=smallint(self.getword(r.pc.l));
        r.pc.l:=r.pc.l+2;
      end;
  $39:begin  //indirecto long xxx.L
        self.ea:=self.getword(r.pc.l) shl 16;
        self.ea:=self.ea or self.getword(r.pc.l+2);
        r.pc.l:=r.pc.l+4;
      end;
  $3a:begin //d(PC)
        self.ea:=r.pc.l+smallint(self.getword(r.pc.l));
        r.pc.l:=r.pc.l+2;
      end;
  $3b:begin  //d(PC,ix)
        desp:=self.getword(r.pc.l);
        des:=desp and $ff;
        if (desp and $8000)<>0 then begin
          if (desp and $800)<>0 then self.ea:=r.pc.l+r.a[(desp shr 12) and $7].l+shortint(des)
            else self.ea:=r.pc.l+smallint(r.a[(desp shr 12) and $7].wl)+shortint(des);
        end else begin
          if (desp and $800)<>0 then self.ea:=r.pc.l+r.d[(desp shr 12) and $7].l+shortint(des)
            else self.ea:=r.pc.l+smallint(r.d[(desp shr 12) and $7].wl)+shortint(des);
        end;
        r.pc.l:=r.pc.l+2;
      end;
  $3c:begin  //inmediato word  #nnnn
        self.ea:=r.pc.l;
        leerdir_b:=self.getword(self.ea) and $ff;
        r.pc.l:=r.pc.l+2;
        exit;
      end
  else MessageDlg('Mierda direccionamiento origen.b - '+inttohex(r.pc.l,10)+' - '+inttohex(dir,2), mtInformation,[mbOk], 0);
end;
self.opcode:=false;
leerdir_b:=self.getbyte(self.ea);
self.opcode:=true;
end;

procedure cpu_m68000.ponerdir_b2(des,res:byte);
begin
case des of
           $0..$7:r.d[des and $7].l0:=res;  //registro DX
           $8..$f:r.a[des and $7].l0:=res;  //registro AX
           $10..$17,  //Registro indirecto AX
           $18..$1f,  //indirecto con postincremento
           $20..$27, //AX predecremento
           $28..$2f,  ////AX indirecto con desplazamiento
           $30..$37,  //AX indirecto indexado con desplazamiento
           $38,$39:self.putbyte(self.ea,res);
           else MessageDlg('Mierda direccionamiento poner_b2 - '+inttohex(des,2)+' - '+inttohex(r.pc.l,10), mtInformation,[mbOk], 0);
        end;
end;

procedure cpu_m68000.ponerdir_b(des,res:byte);
var
  desp:word;
  despl:byte;
begin
case des of
           $0..$7:begin //registro DX
                    r.d[des and $7].l0:=res;
                    exit;
                  end;
           $8..$f:begin //registro AX
                    r.a[des and $7].l0:=res;
                    exit;
                  end;
           $10..$17:self.ea:=r.a[des and $7].l;  //Registro indirecto AX
           $18..$1f:begin  //indirecto con postincremento
                      self.ea:=r.a[des and $7].l;
                      r.a[des and $7].l:=r.a[des and $7].l+1;
                    end;
           $20..$27:begin //AX predecremento
                      r.a[(des and $7)].l:=r.a[(des and $7)].l-1;
                      self.ea:=r.a[(des and $7)].l;
                    end;
           $28..$2f:begin  ////AX indirecto con desplazamiento
                      desp:=self.getword(r.pc.l);
                      r.pc.l:=r.pc.l+2;
                      self.ea:=r.a[des and $7].l+smallint(desp);
                    end;
           $30..$37:begin  //AX indirecto indexado con desplazamiento
                      desp:=self.getword(r.pc.l);
                      r.pc.l:=r.pc.l+2;
                      despl:=desp and $ff;
                      if (desp and $8000)<>0 then begin
                        if (desp and $800)<>0 then self.ea:=r.a[des and $7].l+r.a[(desp shr 12) and $7].l+shortint(despl)
                          else self.ea:=r.a[des and $7].l+smallint(r.a[(desp shr 12) and $7].wl)+shortint(despl);
                      end else begin
                        if (desp and $800)<>0 then self.ea:=r.a[des and $7].l+r.d[(desp shr 12) and $7].l+shortint(despl)
                          else self.ea:=r.a[des and $7].l+smallint(r.d[(desp shr 12) and $7].wl)+shortint(despl);
                      end;
           end;
           $38:begin //word indirecto
                  self.ea:=smallint(self.getword(r.pc.l));
                  r.pc.l:=r.pc.l+2;
               end;
           $39:begin //indirecto long
                  self.ea:=self.getword(r.pc.l) shl 16;
                  self.ea:=self.ea or self.getword(r.pc.l+2);
                  r.pc.l:=r.pc.l+4;
                 end;
           else MessageDlg('Mierda direccionamiento poner_b - '+inttohex(des,2)+' - '+inttohex(r.ppc.l,10), mtInformation,[mbOk], 0);
end;
self.putbyte(self.ea,res);
end;

function cpu_m68000.leerdir_w(dir:byte):word;
var
  desp:dword;
  des:byte;
begin
case dir of
  $0..$7:begin //registro DX
            leerdir_w:=r.d[dir and $7].wl;
            exit;
         end;
  $8..$f:begin //registro AX
            leerdir_w:=r.a[dir and $7].wl;
            exit;
         end;
  $10..$17:self.ea:=r.a[dir and $7].l;  //Registro indirecto AX
  $18..$1f:begin // (registro de direccion)+
            self.ea:=r.a[(dir and $7)].l;
            r.a[(dir and $7)].l:=self.ea+2;
           end;
  $20..$27:begin //AX predecremento
              r.a[(dir and $7)].l:=r.a[(dir and $7)].l-2;
              self.ea:=r.a[(dir and $7)].l;
           end;
  $28..$2f:begin  //AX indirecto con desplazamiento
              desp:=self.getword(r.pc.l);
              r.pc.l:=r.pc.l+2;
              self.ea:=r.a[dir and $7].l+smallint(desp);
           end;
  $30..$37:begin  //AX indirecto indexado con desplazamiento
              desp:=self.getword(r.pc.l);
              r.pc.l:=r.pc.l+2;
              des:=desp and $ff;
              if (desp and $8000)<>0 then begin
                if (desp and $800)<>0 then self.ea:=r.a[dir and $7].l+r.a[(desp shr 12) and $7].l+shortint(des)
                  else self.ea:=r.a[dir and $7].l+smallint(r.a[(desp shr 12) and $7].wl)+shortint(des);
              end else begin
                if (desp and $800)<>0 then self.ea:=r.a[dir and $7].l+r.d[(desp shr 12) and $7].l+shortint(des)
                  else self.ea:=r.a[dir and $7].l+smallint(r.d[(desp shr 12) and $7].wl)+shortint(des);
              end;
           end;
  $38:begin //word indirecto
        self.ea:=smallint(self.getword(r.pc.l));
        r.pc.l:=r.pc.l+2;
      end;
  $39:begin  //indirecto inmediato l
        self.ea:=self.getword(r.pc.l) shl 16;
        self.ea:=self.ea or self.getword(r.pc.l+2);
        r.pc.l:=r.pc.l+4;
     end;
  $3a:begin
        desp:=self.getword(r.pc.l);
        self.ea:=r.pc.l+smallint(desp);
        r.pc.l:=r.pc.l+2;
      end;
  $3b:begin
        desp:=self.getword(r.pc.l);
        des:=desp and $ff;
        if (desp and $8000)<>0 then begin
          if (desp and $800)<>0 then self.ea:=r.pc.l+r.a[(desp shr 12) and $7].l+shortint(des)
            else self.ea:=r.pc.l+smallint(r.a[(desp shr 12) and $7].wl)+shortint(des);
        end else begin
          if (desp and $800)<>0 then self.ea:=r.pc.l+r.d[(desp shr 12) and $7].l+shortint(des)
            else self.ea:=r.pc.l+smallint(r.d[(desp shr 12) and $7].wl)+shortint(des);
        end;
        r.pc.l:=r.pc.l+2;
      end;
  $3c:begin  //inmediato
        self.ea:=r.pc.l;
        leerdir_w:=self.getword(self.ea);
        r.pc.l:=r.pc.l+2;
        exit;
      end;
else MessageDlg('Mierda error de direccionamiento origen.w - '+inttostr(r.pc.l)+' - '+inttostr(dir), mtInformation,[mbOk], 0);
end;
self.opcode:=false;
leerdir_w:=self.getword(self.ea);
self.opcode:=true;
end;

procedure cpu_m68000.ponerdir_w2(des:byte;res:word);
begin
case des of
  $0..$7:r.d[des and $7].wl:=res; //registro DX
  $8..$f:begin
            if (res and $8000)<>0 then MessageDlg('Mierda > $8000 ponerdir.w', mtInformation,[mbOk], 0);
            r.a[des and $7].wl:=res; //registro AX
         end;
  $10..$17,  // indirecto con AX
  $18..$1f, // (registro de direccion)+
  $20..$27, //AX predecremento
  $28..$2f,  //  AX indirecto con desplazamiento
  $30..$37,  //AX indirecto indexado con desplazamiento
  $38, //word indirecto
  $39:self.putword(self.ea,res);  //indirecto long
    else MessageDlg('Mierda error de direccionamiento lea destino.w - '+inttohex(des,2)+' - '+inttohex(r.pc.l,$10), mtInformation,[mbOk], 0);
end;
end;

procedure cpu_m68000.ponerdir_w(des:byte;res:word);
var
  desp:word;
  despl:byte;
begin
case des of
  $0..$7:begin //registro DX
            r.d[des and $7].wl:=res;
            exit;
         end;
  $8..$f:begin //registro AX
            if (res and $8000)<>0 then MessageDlg('Mierda > $8000 ponerdir.w', mtInformation,[mbOk], 0);
            r.a[des and $7].wl:=res;
            exit;
         end;
  $10..$17:self.ea:=r.a[(des and $7)].l;  // indirecto con AX
  $18..$1f:begin // (registro de direccion)+
              self.ea:=r.a[(des and $7)].l;
              r.a[(des and $7)].l:=r.a[(des and $7)].l+2;
           end;
  $20..$27:begin //AX predecremento
              r.a[(des and $7)].l:=r.a[(des and $7)].l-2;
              self.ea:=r.a[(des and $7)].l;
           end;
  $28..$2f:begin  //  AX indirecto con desplazamiento
              desp:=self.getword(r.pc.l);
              r.pc.l:=r.pc.l+2;
              self.ea:=r.a[des and $7].l+smallint(desp);
           end;
  $30..$37:begin  //AX indirecto indexado con desplazamiento
              desp:=self.getword(r.pc.l);
              r.pc.l:=r.pc.l+2;
              despl:=desp and $ff;
              if (desp and $8000)<>0 then begin
                if (desp and $800)<>0 then self.ea:=r.a[des and $7].l+r.a[(desp shr 12) and $7].l+shortint(despl)
                  else self.ea:=r.a[des and $7].l+smallint(r.a[(desp shr 12) and $7].wl)+shortint(despl);
              end else begin
                if (desp and $800)<>0 then self.ea:=r.a[des and $7].l+r.d[(desp shr 12) and $7].l+shortint(despl)
                  else self.ea:=r.a[des and $7].l+smallint(r.d[(desp shr 12) and $7].wl)+shortint(despl);
              end;
           end;
  $38:begin //word indirecto
        self.ea:=smallint(self.getword(r.pc.l));
        r.pc.l:=r.pc.l+2;
      end;
  $39:begin  //indirecto long
        self.ea:=self.getword(r.pc.l) shl 16;
        self.ea:=self.ea or self.getword(r.pc.l+2);
        r.pc.l:=r.pc.l+4;
      end;
  else MessageDlg('Mierda error de direccionamiento destino.w - '+inttostr(des)+' - '+inttostr(r.pc.l), mtInformation,[mbOk], 0);
end;
self.putword(self.ea,res);
end;

function cpu_m68000.leerdir_l(dir:byte):dword;
var
  desp:word;
  des:byte;
begin
case dir of
  $0..$7:begin //registro DX
            leerdir_l:=r.d[dir and 7].l;
            exit;
         end;
  $8..$f:begin //registro AX
            leerdir_l:=r.a[dir and 7].l;
            exit;
         end;
  $10..$17:self.ea:=r.a[(dir and $7)].l;  //Registro indirecto AX
  $18..$1f:begin // registro AX con post incremento
            self.ea:=r.a[dir and $7].l;
            r.a[dir and $7].l:=r.a[dir and $7].l+4;
           end;
  $20..$27:begin //AX predecremento
            r.a[(dir and $7)].l:=r.a[(dir and $7)].l-4;
            self.ea:=r.a[(dir and $7)].l;
           end;
  $28..$2f:begin  ////AX indirecto con desplazamiento
              desp:=self.getword(r.pc.l);
              r.pc.l:=r.pc.l+2;
              self.ea:=r.a[dir and $7].l+smallint(desp);
           end;
  $30..$37:begin  //AX indirecto indexado con desplazamiento
              desp:=self.getword(r.pc.l);
              r.pc.l:=r.pc.l+2;
              des:=desp and $ff;
              if (desp and $8000)<>0 then begin
                if (desp and $800)<>0 then self.ea:=r.a[dir and $7].l+r.a[(desp shr 12) and $7].l+shortint(des)
                  else self.ea:=r.a[dir and $7].l+smallint(r.a[(desp shr 12) and $7].wl)+shortint(des);
              end else begin
                if (desp and $800)<>0 then self.ea:=r.a[dir and $7].l+r.d[(desp shr 12) and $7].l+shortint(des)
                  else self.ea:=r.a[dir and $7].l+smallint(r.d[(desp shr 12) and $7].wl)+shortint(des);
              end;
           end;
  $38:begin //word indirecto
        self.ea:=smallint(self.getword(r.pc.l));
        r.pc.l:=r.pc.l+2;
      end;
  $39:begin  //indirecto long
        self.ea:=(self.getword(r.pc.l) shl 16) or self.getword(r.pc.l+2);
        r.pc.l:=r.pc.l+4;
      end;
  $3a:begin
        desp:=self.getword(r.pc.l);
        self.ea:=r.pc.l+smallint(desp);
        r.pc.l:=r.pc.l+2;
      end;
  $3b:begin
        desp:=self.getword(r.pc.l);
        des:=desp and $ff;
        if (desp and $8000)<>0 then begin
          if (desp and $800)<>0 then self.ea:=r.pc.l+r.a[(desp shr 12) and $7].l+shortint(des)
            else self.ea:=r.pc.l+smallint(r.a[(desp shr 12) and $7].wl)+shortint(des);
        end else begin
          if (desp and $800)<>0 then self.ea:=r.pc.l+r.d[(desp shr 12) and $7].l+shortint(des)
            else self.ea:=r.pc.l+smallint(r.d[(desp shr 12) and $7].wl)+shortint(des);
        end;
        r.pc.l:=r.pc.l+2;
      end;
  $3c:begin // inmediato
        leerdir_l:=(self.getword(r.pc.l) shl 16) or self.getword(r.pc.l+2);
        self.ea:=r.pc.l;
        r.pc.l:=r.pc.l+4;
        exit;
      end;
  else MessageDlg('Mierda error de direccionamiento origen.l - '+inttostr(dir)+' - '+inttostr(r.pc.l), mtInformation,[mbOk], 0);
end;
self.opcode:=false;
leerdir_l:=(self.getword(self.ea) shl 16) or self.getword(self.ea+2);
self.opcode:=true;
end;

procedure cpu_m68000.ponerdir_l2(des:byte;res:dword);
begin
case des of
  $0..$7:r.d[des and $7].l:=res;
  $8..$f:r.a[des and $7].l:=res; //registro AX
  $10..$17, //indirecto AX
  $18..$1f,  // (registro de direccion)+
  $20..$27,   // -(registro de direccion)
  $28..$2f,    //  AX indirecto con desplazamiento
  $30..$37,    //AX indirecto indexado con desplazamiento
  $38,$39:begin  //indirecto inmediato l
            self.putword(self.ea,res shr 16);
            self.putword(self.ea+2,res and $FFFF);
          end;
  else MessageDlg('Mierda error de direccionamiento corto destino.l - '+inttohex(des,4)+' - '+inttohex(r.pc.l,10), mtInformation,[mbOk], 0);
end;
end;

procedure cpu_m68000.ponerdir_l(des:byte;res:dword);
var
  desp:word;
  despl:byte;
begin
case des of
  $0..$7:begin //registro DX
            r.d[des and $7].l:=res;
            exit;
         end;
  $8..$f:begin //registro AX
            r.a[des and $7].l:=res;
            exit;
         end;
  $10..$17:self.ea:=r.a[des and $7].l; //indirecto AX
  $18..$1f:begin // (registro de direccion)+
              self.ea:=r.a[(des and $7)].l;
              r.a[(des and $7)].l:=self.ea+4;
           end;
  $20..$27:begin // -(registro de direccion)
              r.a[(des and $7)].l:=r.a[(des and $7)].l-4;
              self.ea:=r.a[(des and $7)].l;
           end;
  $28..$2f:begin  //  AX indirecto con desplazamiento
              desp:=self.getword(r.pc.l);
              r.pc.l:=r.pc.l+2;
              self.ea:=r.a[des and $7].l+smallint(desp);
           end;
  $30..$37:begin  //AX indirecto indexado con desplazamiento
              desp:=self.getword(r.pc.l);
              r.pc.l:=r.pc.l+2;
              despl:=desp and $ff;
              if (desp and $8000)<>0 then begin
                if (desp and $800)<>0 then self.ea:=r.a[des and $7].l+r.a[(desp shr 12) and $7].l+shortint(despl)
                  else self.ea:=r.a[des and $7].l+smallint(r.a[(desp shr 12) and $7].wl)+shortint(despl);
              end else begin
                if (desp and $800)<>0 then self.ea:=r.a[des and $7].l+r.d[(desp shr 12) and $7].l+shortint(despl)
                  else self.ea:=r.a[des and $7].l+smallint(r.d[(desp shr 12) and $7].wl)+shortint(despl);
              end;
           end;
  $38:begin //word indirecto
        self.ea:=smallint(self.getword(r.pc.l));
        r.pc.l:=r.pc.l+2;
      end;
  $39:begin  //indirecto inmediato l
        self.ea:=(self.getword(r.pc.l) shl 16) or self.getword(r.pc.l+2);
        r.pc.l:=r.pc.l+4;
      end;
  else MessageDlg('Mierda error de direccionamiento destino.l - '+inttohex(des,4)+' - '+inttohex(r.pc.l,10), mtInformation,[mbOk], 0);
end;
self.putword(self.ea,res shr 16);
self.putword(self.ea+2,res and $FFFF);
end;

function cpu_m68000.leerdir_ea(dir:byte):dword;
var
  res:dword;
  tempw:word;
  tempb:byte;
begin
case dir of
  $10..$1f,$20..$27:res:=r.a[dir and 7].l;
  $28..$2f:begin
              tempw:=self.getword(r.pc.l);
              r.pc.l:=r.pc.l+2;
              res:=r.a[dir and $7].l+smallint(tempw);
            end;
  $30..$37:begin
              tempw:=self.getword(r.pc.l);
              r.pc.l:=r.pc.l+2;
              tempb:=tempw and $ff;
              if (tempw and $8000)<>0 then begin
                if (tempw and $800)<>0 then res:=r.a[dir and $7].l+r.a[(tempw shr 12) and $7].l+shortint(tempb)
                  else res:=r.a[dir and $7].l+smallint(r.a[(tempw shr 12) and $7].wl)+shortint(tempb);
              end else begin
                if (tempw and $800)<>0 then res:=r.a[dir and $7].l+r.d[(tempw shr 12) and $7].l+shortint(tempb)
                  else res:=r.a[dir and $7].l+smallint(r.d[(tempw shr 12) and $7].wl)+shortint(tempb);
              end;
            end;
  $38:begin
        res:=smallint(self.getword(r.pc.l));
        r.pc.l:=r.pc.l+2;
      end;
  $39:begin
        res:=self.getword(r.pc.l) shl 16;
        res:=res or self.getword(r.pc.l+2);
        r.pc.l:=r.pc.l+4;
      end;
  $3a:begin
        tempw:=self.getword(r.pc.l);
        res:=r.pc.l+smallint(tempw);
        r.pc.l:=r.pc.l+2;
      end;
  $3b:begin
        tempw:=self.getword(r.pc.l);
        tempb:=tempw and $ff;
        if (tempw and $8000)<>0 then begin
          if (tempw and $800)<>0 then res:=r.pc.l+r.a[(tempw shr 12) and $7].l+shortint(tempb)
            else res:=r.pc.l+smallint(r.a[(tempw shr 12) and $7].wl)+shortint(tempb);
        end else begin
          if (tempw and $800)<>0 then res:=r.pc.l+r.d[(tempw shr 12) and $7].l+shortint(tempb)
            else res:=r.pc.l+smallint(r.d[(tempw shr 12) and $7].wl)+shortint(tempb);
        end;
        r.pc.l:=r.pc.l+2;
      end;
  else MessageDlg('Mierda EA error en dir '+inttohex(dir,2)+' - '+inttohex(r.pc.l,10), mtInformation,[mbOk], 0);
end;
leerdir_ea:=res;
end;

function condicion(r:preg_m68000;tipo:byte):boolean;inline;
begin
  case tipo of
    $00:condicion:=true;
    $01:condicion:=false;
    $02:condicion:=(not(r.cc.c) and not(r.cc.z)); //hi
    $03:condicion:=(r.cc.c or r.cc.z); //LS
    $04:condicion:=not(r.cc.c); //cc
    $05:condicion:=r.cc.c;  //cs
    $06:condicion:=not(r.cc.z); //ne
    $07:condicion:=r.cc.z;  //eq
    $08:condicion:=not(r.cc.v); //vc
    $09:condicion:=r.cc.v; //vs
    $0a:condicion:=not(r.cc.n); //plus
    $0b:condicion:=r.cc.n; //mi
    $0c:condicion:=not(r.cc.n xor r.cc.v); //ge
    $0d:condicion:=r.cc.n xor r.cc.v;  //lt
    $0e:condicion:=(not(r.cc.n xor r.cc.v) and not(r.cc.z)); //gt
    $0f:condicion:=((r.cc.n xor r.cc.v)) or r.cc.z; //le
  end;
end;

function calc_move_t_bw(dir,dest:byte):byte;
const
  caso_1:array[0..7] of byte=(4,4,8,8,8,12,14,12);
  caso_2:array[0..7] of byte=(8,8,12,12,12,16,18,16);
  caso_3:array[0..7] of byte=(10,10,14,14,14,18,20,18);
  caso_4:array[0..7] of byte=(12,12,16,16,16,20,22,20);
  caso_5:array[0..7] of byte=(14,14,18,18,18,22,24,22);
  caso_6:array[0..7] of byte=(16,16,20,20,20,24,26,24);
var
  res:byte;
begin
case dir of
  $0..$f:res:=caso_1[dest shr 3];  //Dn y An
  $10..$1f,$3c:res:=caso_2[dest shr 3];  //(An) y (An)+
  $20..$27:res:=caso_3[dest shr 3];  //-(An)
  $28..$2f,$38,$3a:res:=caso_4[dest shr 3];    //  d(An)  xxx.W d(PC)
  $30..$37,$3b:res:=caso_5[dest shr 3];    // d(An,ix)
  $39:res:=caso_6[dest shr 3];  // xxx.L
end;
if dest=39 then res:=res+4;
calc_move_t_bw:=res;
end;

function calc_move_t_l(dir,dest:byte):byte;
const
  caso_1:array[0..7] of byte=(4,4,12,12,12,16,18,16);
  caso_2:array[0..7] of byte=(12,12,20,20,20,24,26,24);
  caso_3:array[0..7] of byte=(14,14,22,22,22,26,28,26);
  caso_4:array[0..7] of byte=(16,16,24,24,24,28,30,28);
  caso_5:array[0..7] of byte=(18,18,24,24,24,28,30,28);
  caso_6:array[0..7] of byte=(20,20,28,28,28,32,34,32);
var
  res:byte;
begin
case dir of
  $0..$f:res:=caso_1[dest shr 3];  //Dn y An
  $10..$1f,$3c:res:=caso_2[dest shr 3];  //(An) y (An)+
  $20..$27:res:=caso_3[dest shr 3];  //-(An)
  $28..$2f,$38,$3a:res:=caso_4[dest shr 3];    //  d(An)  xxx.W d(PC)
  $30..$37,$3b:res:=caso_5[dest shr 3];    // d(An,ix)
  $39:res:=caso_6[dest shr 3];  // xxx.L
end;
if dest=39 then res:=res+4;
calc_move_t_l:=res;
end;


function calc_ea_t_bw(dir:byte):byte;
begin
case dir of
  $0..$f:calc_ea_t_bw:=0;  //Dn y An
  $10..$1f:calc_ea_t_bw:=4;  //(An) y (An)+
  $20..$27:calc_ea_t_bw:=6;  //-(An)
  $28..$2f:calc_ea_t_bw:=8;    //  d(An)
  $30..$37:calc_ea_t_bw:=10;    // d(An,ix)
  $38:calc_ea_t_bw:=8; // xxx.W
  $39:calc_ea_t_bw:=12;  // xxx.L
  $3a:calc_ea_t_bw:=8; //d(PC)
  $3b:calc_ea_t_bw:=10; // d(PC,ix)
  $3c:calc_ea_t_bw:=4; // imm
end;
end;

function calc_ea_t_l(dir:byte):byte;
begin
case dir of
  $0..$f:calc_ea_t_l:=0;  //Dn y An
  $10..$1f:calc_ea_t_l:=8;  //(An) y (An)+
  $20..$27:calc_ea_t_l:=10;  //-(An)
  $28..$2f:calc_ea_t_l:=12;    //  d(An)
  $30..$37:calc_ea_t_l:=14;    // d(An,ix)
  $38:calc_ea_t_l:=12; // xxx.W
  $39:calc_ea_t_l:=16;  // xxx.L
  $3a:calc_ea_t_l:=12; //d(PC)
  $3b:calc_ea_t_l:=14; // d(PC,ix)
  $3c:calc_ea_t_l:=8; // imm
end;
end;

procedure cpu_m68000.run(maximo:single);
var
  instruccion,tempw,tempw2:word;
  dir,dest,orig,tempb,tempb2,tempb3,f:byte;
  templ,templ2,templ3:dword;
  tempdl:uint64;
  pcontador:integer;
  remainder,quotient,divisor:integer;
begin
self.contador:=0;
while self.contador<maximo do begin
if self.pedir_reset<>CLEAR_LINE then begin
  tempb:=self.pedir_reset;
  self.reset;
  if tempb=ASSERT_LINE then self.pedir_reset:=ASSERT_LINE;
  self.contador:=trunc(maximo);
  exit;
end;
if self.pedir_halt<>CLEAR_LINE then begin
  self.contador:=trunc(maximo);
  exit;
end;
pcontador:=self.contador;
for f:=7 downto 1 do begin
    if ((r.cc.im<f) and (self.irq[f]<>CLEAR_LINE)) then begin
      self.halt:=false;
      self.prefetch:=false;
      self.contador:=self.contador+44;
      tempw:=coger_band(self.r);
      self.poner_band(tempw or $2000);
      r.sp.l:=r.sp.l-6;
      self.putword(r.sp.l,tempw);
      self.putword(r.sp.l+2,r.pc.wh);
      self.putword(r.sp.l+4,r.pc.wl);
      self.opcode:=false;
      r.pc.wh:=self.getword($64+((f-1)*4));
      r.pc.wl:=self.getword($64+2+((f-1)*4));
      self.opcode:=true;
      if self.irq[f]=HOLD_LINE then self.irq[f]:=CLEAR_LINE;
      r.cc.im:=f;
      break;
    end;
end;
if self.halt then begin
  self.contador:=trunc(maximo);
  exit;
end;
self.opcode:=true;
instruccion:=self.getword(r.pc.l);
r.ppc:=r.pc;
r.pc.l:=r.pc.l+2;
dir:=instruccion and $3f;
dest:=(instruccion shr 9) and 7;
orig:=instruccion and 7;
case (instruccion shr 12) of //cojo solo el primer nibble
   $0:case (instruccion shr 6) and $3f of
        $0:begin
            tempb:=self.getword(r.pc.l);
            r.pc.l:=r.pc.l+2;
            if dir<>$3c then begin  // # ori.b
              if (dir shr 3)<>0 then self.contador:=self.contador+12+calc_ea_t_bw(dir)
                else self.contador:=self.contador+8;
              tempb2:=leerdir_b(dir) or tempb;
              ponerdir_b2(dir,tempb2);
              r.cc.n:=(tempb2 and $80)<>0;
              r.cc.z:=(tempb2=0);
              r.cc.c:=false;
              r.cc.v:=false;
            end else begin   // # ori.b toc
              self.contador:=self.contador+20;
              tempb2:=(coger_band(self.r) and $ff) or tempb;
              r.cc.x:=(tempb2 and $10)<>0;
              r.cc.n:=(tempb2 and $8)<>0;
              r.cc.z:=(tempb2 and $4)<>0;
              r.cc.v:=(tempb2 and $2)<>0;
              r.cc.c:=(tempb2 and $1)<>0;
            end;
           end;
        $1:begin
            tempw:=self.getword(r.pc.l);
            r.pc.l:=r.pc.l+2;
            if dir<>$3c then begin // # ori.w
              if (dir shr 3)<>0 then self.contador:=self.contador+12+calc_ea_t_bw(dir)
                else self.contador:=self.contador+8;
              tempw2:=self.leerdir_w(dir) or tempw;
              self.ponerdir_w2(dir,tempw2);
              r.cc.n:=(tempw2 and $8000)<>0;
              r.cc.z:=(tempw2=0);
              r.cc.c:=false;
              r.cc.v:=false;
            end else begin
              if r.cc.s then begin // # ori.w tos
                self.contador:=self.contador+20;
                tempw2:=coger_band(self.r) or tempw;
                self.poner_band(tempw2);
              end else begin
                MessageDlg('Error de privilegio '+inttohex(r.pc.l,10), mtInformation,[mbOk], 0);
              end;
            end;
           end;
        $2:begin  // # ori.l
            if (dir shr 3)<>0 then self.contador:=self.contador+20+calc_ea_t_l(dir)
              else self.contador:=self.contador+16;
            templ:=self.getword(r.pc.l) shl 16;
            templ:=templ or self.getword(r.pc.l+2);
            r.pc.l:=r.pc.l+4;
            templ2:=self.leerdir_l(dir) or templ;
            self.ponerdir_l2(dir,templ2);
            r.cc.n:=((templ2 shr 24) and $80)<>0;
            r.cc.z:=(templ2=0);
            r.cc.c:=false;
            r.cc.v:=false;
           end;
  $4,$c,$14,$1c,$24,$2c,$34,$3c:begin  // # btst dinamico
              case ((instruccion shr 3) and $7) of
                $00:begin  //32 bits
                      self.contador:=self.contador+6;
                      templ:=1 shl (r.d[dest].l0 and $1f);
                      r.cc.z:=(r.d[orig].l and templ)=0;
                    end;
                $01:begin // # movep.w er
                      self.contador:=self.contador+16;
                      tempw:=self.getword(r.pc.l);
                      if (tempw and $8000)<>0 then MessageDlg('Mierda! movep btst>$8000', mtInformation,[mbOk], 0);
                      templ:=r.a[orig].l+tempw;
                      r.pc.l:=r.pc.l+2;
                      r.d[dest].h0:=self.getbyte(templ);
                      r.d[dest].l0:=self.getbyte(templ+2);
                    end;
                else begin //8bits
                      self.contador:=self.contador+4+calc_ea_t_bw(dir);
                      tempb:=1 shl (r.d[dest].l0 and $7);
                      tempb2:=self.leerdir_b(dir);
                      r.cc.z:=(tempb2 and tempb)=0;
                    end;
              end;
           end;
  $5,$d,$15,$1d,$25,$2d,$35,$3d:begin  // # bchg dinamico
              case ((instruccion shr 3) and $7) of
                0:begin //bchg 32bits
                     self.contador:=self.contador+8;
                     templ:=1 shl (r.d[dest].l0 and $1f);
                     r.cc.z:=(r.d[orig].l and templ)=0;
                     r.d[orig].l:=r.d[orig].l xor templ;
                  end;
                1:begin  // # movep.l er
                    self.contador:=self.contador+24;
                    tempw:=self.getword(r.pc.l);
                    if (tempw and $8000)<>0 then MessageDlg('Mierda! movep bchg>$8000', mtInformation,[mbOk], 0);
                    templ:=r.a[orig].l+tempw;
                    r.pc.l:=r.pc.l+2;
                    r.d[dest].h1:=self.getbyte(templ);
                    r.d[dest].l1:=self.getbyte(templ+2);
                    r.d[dest].h0:=self.getbyte(templ+4);
                    r.d[dest].l0:=self.getbyte(templ+6);
                  end;
                  else begin //bchg 8 bits
                     self.contador:=self.contador+8+calc_ea_t_bw(dir);
                     tempb:=1 shl (r.d[dest].l0 and $7);
                     tempb2:=self.leerdir_b(dir);
                     r.cc.z:=(tempb2 and tempb)=0;
                     tempb2:=tempb2 xor tempb;
                     self.ponerdir_b2(dir,tempb2);
                  end;
              end;
            end;
  $6,$e,$16,$1e,$26,$2e,$36,$3e:begin  // # bclr dinamico
              case ((instruccion shr 3) and $7) of
                $0:begin //32 bits
                      self.contador:=self.contador+10;
                      templ:=1 shl (r.d[dest].l0 and $1f);
                      r.cc.z:=(r.d[orig].l and templ)=0;
                      r.d[orig].l:=r.d[orig].l and not(templ);
                   end;
                $1:begin // # movep.w re
                      self.contador:=self.contador+16;
                      tempw:=self.getword(r.pc.l);
                      if (tempw and $8000)<>0 then MessageDlg('Mierda! movep bclr>$8000', mtInformation,[mbOk], 0);
                      templ:=r.a[orig].l+tempw;
                      r.pc.l:=r.pc.l+2;
                      self.putbyte(templ,r.d[dest].h0);
                      self.putbyte(templ+2,r.d[dest].l0);
                    end;
                else begin //8 bits
                      self.contador:=self.contador+8+calc_ea_t_bw(dir);
                      tempb:=1 shl (r.d[dest].l0 and $7);
                      tempb2:=self.leerdir_b(dir);
                      r.cc.z:=(tempb2 and tempb)=0;
                      tempb2:=tempb2 and not(tempb);
                      self.ponerdir_b2(dir,tempb2);
                end;
              end;
           end;
  7,$f,$17,$1f,$27,$2f,$37,$3f:begin // # bset dinamico
              case ((instruccion shr 3) and $7) of
                $00:begin  //32 bits
                     self.contador:=self.contador+8;
                     templ:=1 shl (r.d[dest].l0 and $1f);
                     r.cc.z:=(r.d[orig].l and templ)=0;
                     r.d[orig].l:=r.d[orig].l or templ;
                    end;
                $01:begin  //movep.l re 14/02/15
                      self.contador:=self.contador+24;
                      tempw:=self.getword(r.pc.l);
                      templ:=r.a[orig].l+smallint(tempw);
                      r.pc.l:=r.pc.l+2;
                      self.putbyte(templ,r.d[dest].h1);
                      self.putbyte(templ+2,r.d[dest].l1);
                      self.putbyte(templ+4,r.d[dest].h0);
                      self.putbyte(templ+6,r.d[dest].l0);
                    end;
                else begin  //8bits
                      self.contador:=self.contador+8+calc_ea_t_bw(dir);
                      tempb:=1 shl (r.d[dest].l0 and $7);
                      tempb2:=self.leerdir_b(dir);
                      r.cc.z:=(tempb2 and tempb)=0;
                      tempb2:=tempb2 or tempb;
                      self.ponerdir_b2(dir,tempb2);
                end;
              end;
            end;
        $8:begin  // # andi.b
            tempb:=self.getword(r.pc.l);
            r.pc.l:=r.pc.l+2;
            if dir<>$3c then begin
              if (dir shr 3)<>0 then self.contador:=self.contador+12+calc_ea_t_bw(dir)
                  else self.contador:=self.contador+8;
              tempb2:=self.leerdir_b(dir) and tempb;
              self.ponerdir_b2(dir,tempb2);
              r.cc.n:=(tempb2 and $80)<>0;
              r.cc.z:=(tempb2=0);
              r.cc.v:=false;
              r.cc.c:=false;
            end else begin // # andi.b tos
              self.contador:=self.contador+20;
              tempb2:=(coger_band(self.r) and $ff) and tempb;
              r.cc.x:=(tempb2 and $10)<>0;
              r.cc.n:=(tempb2 and $8)<>0;
              r.cc.z:=(tempb2 and $4)<>0;
              r.cc.v:=(tempb2 and $2)<>0;
              r.cc.c:=(tempb2 and $1)<>0;
            end;
          end;
        $9:begin  // # andi.w
            tempw:=self.getword(r.pc.l);
            r.pc.l:=r.pc.l+2;
            if dir<>$3c then begin
              if (dir shr 3)<>0 then self.contador:=self.contador+12+calc_ea_t_bw(dir)
                else self.contador:=self.contador+8;
              tempw2:=self.leerdir_w(dir) and tempw;
              self.ponerdir_w2(dir,tempw2);
              r.cc.n:=(tempw2 and $8000)<>0;
              r.cc.z:=(tempw2=0);
              r.cc.v:=false;
              r.cc.c:=false;
            end else begin  // # andi.w tos
              if r.cc.s then begin
                 self.contador:=self.contador+20;
                 tempw2:=coger_band(self.r) and tempw;
                 self.poner_band(tempw2);
              end else begin
                MessageDlg('Error de Privilegio '+inttohex(r.pc.l,10), mtInformation,[mbOk], 0);
              end;
            end;
          end;
        $a:begin  // # andi.l
            if (dir shr 3)<>0 then self.contador:=self.contador+20+calc_ea_t_l(dir)
              else self.contador:=self.contador+16;
            templ:=self.getword(r.pc.l) shl 16;
            templ:=templ or self.getword(r.pc.l+2);
            r.pc.l:=r.pc.l+4;
            templ2:=self.leerdir_l(dir) and templ;
            self.ponerdir_l2(dir,templ2);
            r.cc.n:=((templ2 shr 24) and $80)<>0;
            r.cc.z:=(templ2=0);
            r.cc.v:=false;
            r.cc.c:=false;
          end;
        $10:begin // # subi.b
              if (dir shr 3)<>0 then self.contador:=self.contador+12+calc_ea_t_bw(dir)
                else self.contador:=self.contador+8;
              tempb:=self.getword(r.pc.l) and $ff;
              r.pc.l:=r.pc.l+2;
              tempb2:=self.leerdir_b(dir);
              tempw:=tempb2-tempb;
              self.ponerdir_b2(dir,(tempw and $ff));
              r.cc.v:=(((tempb xor tempb2) and (tempw xor tempb2)) and $80)<>0;
              r.cc.c:=(tempw and $100)<>0;
              r.cc.x:=r.cc.c;
              r.cc.n:=(tempw and $80)<>0;
              r.cc.z:=((tempw and $ff)=0);
            end;
        $11:begin // # subi.w
              if (dir shr 3)<>0 then self.contador:=self.contador+12+calc_ea_t_bw(dir)
                else self.contador:=self.contador+8;
              tempw:=self.getword(r.pc.l);
              r.pc.l:=r.pc.l+2;
              tempw2:=self.leerdir_w(dir);
              templ:=tempw2-tempw;
              self.ponerdir_w2(dir,(templ and $ffff));
              r.cc.v:=((((tempw xor tempw2) and (templ xor tempw2)) shr 8) and $80)<>0;
              r.cc.c:=(templ and $10000)<>0;
              r.cc.x:=r.cc.c;
              r.cc.n:=(templ and $8000)<>0;
              r.cc.z:=((templ and $ffff)=0);
            end;
        $12:begin // # subi.l
              if (dir shr 3)<>0 then self.contador:=self.contador+20+calc_ea_t_l(dir)
                else self.contador:=self.contador+16;
              templ:=self.getword(r.pc.l) shl 16;
              templ:=templ or self.getword(r.pc.l+2);
              r.pc.l:=r.pc.l+4;
              templ2:=self.leerdir_l(dir);
              templ3:=templ2-templ;
              self.ponerdir_l2(dir,templ3);
              r.cc.n:=((templ3 shr 24) and $80)<>0;
              r.cc.z:=(templ3=0);
	            r.cc.v:=((((templ xor templ2) and (templ3 xor templ2)) shr 24) and $80)<>0;
	            r.cc.c:=((((templ and templ3) or (not(templ2) and (templ or templ3))) shr 23) and $100)<>0;
              r.cc.x:=r.cc.c;
            end;
        $18:begin // # addi.b
              if (dir shr 3)<>0 then self.contador:=self.contador+12+calc_ea_t_bw(dir)
                else self.contador:=self.contador+8;
              tempb:=self.getword(r.pc.l) and $ff;
              r.pc.l:=r.pc.l+2;
              tempb2:=self.leerdir_b(dir);
              tempw:=tempb+tempb2;
              self.ponerdir_b2(dir,(tempw and $ff));
              r.cc.v:=(((tempb xor tempw) and (tempb2 xor tempw)) and $80)<>0;
              r.cc.c:=(tempw and $100)<>0;
              r.cc.x:=r.cc.c;
              r.cc.n:=(tempw and $80)<>0;
              r.cc.z:=((tempw and $ff)=0);
            end;
        $19:begin // # addi.w
              if (dir shr 3)<>0 then self.contador:=self.contador+12+calc_ea_t_bw(dir)
                else self.contador:=self.contador+8;
              tempw:=self.getword(r.pc.l);
              r.pc.l:=r.pc.l+2;
              tempw2:=self.leerdir_w(dir);
              templ:=tempw+tempw2;
              self.ponerdir_w2(dir,(templ and $ffff));
              r.cc.v:=((((tempw xor templ) and (tempw2 xor templ)) shr 8) and $80)<>0;
              r.cc.c:=(templ and $10000)<>0;
              r.cc.x:=r.cc.c;
              r.cc.n:=(templ and $8000)<>0;
              r.cc.z:=((templ and $ffff)=0);
            end;
        $1a:begin // # addi.l
              if (dir shr 3)<>0 then self.contador:=self.contador+20+calc_ea_t_l(dir)
                else self.contador:=self.contador+16;
              templ:=self.getword(r.pc.l) shl 16;
              templ:=templ or self.getword(r.pc.l+2);
              r.pc.l:=r.pc.l+4;
              templ2:=self.leerdir_l(dir);
              templ3:=templ+templ2;
              self.ponerdir_l2(dir,templ3);
              r.cc.n:=((templ3 shr 24) and $80)<>0;
              r.cc.z:=(templ3=0);
              r.cc.v:=((((templ xor templ3) and (templ2 xor templ3)) shr 24) and $80)<>0;
              r.cc.c:=(((((templ and templ3) or (not(templ2) and (templ or templ3)))) shr 23) and $100)<>0;
              r.cc.x:=r.cc.c;
            end;
        $20:begin // # btst estatico
              tempw:=self.getword(r.pc.l);
              r.pc.l:=r.pc.l+2;
              if dir<8 then begin
                self.contador:=self.contador+10;
                r.cc.z:=((r.d[orig].l shr (tempw and $1f)) and 1)=0
              end else begin
                   self.contador:=self.contador+8+calc_ea_t_bw(dir);
                   tempb:=self.leerdir_b(dir);
                   r.cc.z:=((tempb shr (tempw and $7)) and 1)=0;
              end;
            end;
        $21:begin // # bchg estatico
              tempw:=self.getword(r.pc.l);
              r.pc.l:=r.pc.l+2;
              if dir<8 then begin
                self.contador:=self.contador+12;
                r.cc.z:=((r.d[orig].l shr (tempw and $1f)) and 1)=0;
                r.d[orig].l:=r.d[orig].l xor (1 shl (tempw and $1f));
              end else begin
                self.contador:=self.contador+12+calc_ea_t_bw(dir);
                tempb:=self.leerdir_b(dir);
                r.cc.z:=((tempb shr (tempw and $7)) and 1)=0;
                tempb:=tempb xor (1 shl (tempw and $7));
                self.ponerdir_b2(dir,tempb);
              end;
            end;
        $22:begin // # bclr estatico
              tempw:=self.getword(r.pc.l);
              r.pc.l:=r.pc.l+2;
              if dir<8 then begin //32bits
                self.contador:=self.contador+14;
                r.cc.z:=((r.d[orig].l shr (tempw and $1f)) and 1)=0;
                r.d[dir].l:=r.d[orig].l and not(1 shl (tempw and $1f));
              end else begin //8 bits
                self.contador:=self.contador+12+calc_ea_t_bw(dir);
                tempb:=self.leerdir_b(dir);
                r.cc.z:=((tempb shr (tempw and $7)) and 1)=0;
                tempb:=tempb and not(1 shl (tempw and $7));
                self.ponerdir_b2(dir,tempb);
              end;
            end;
        $23:begin // # bset estatico
              tempw:=self.getword(r.pc.l);
              r.pc.l:=r.pc.l+2;
              if dir<8 then begin //32bits
                self.contador:=self.contador+12;
                r.cc.z:=((r.d[orig].l shr (tempw and $1f)) and 1)=0;
                r.d[dir].l:=r.d[orig].l or (1 shl (tempw and $1f));
              end else begin //8 bits
                self.contador:=self.contador+12+calc_ea_t_bw(dir);
                tempb:=self.leerdir_b(dir);
                r.cc.z:=((tempb shr (tempw and $7)) and 1)=0;
                tempb:=tempb or (1 shl (tempw and $7));
                self.ponerdir_b2(dir,tempb);
              end;
            end;
        $28:begin  // # eori.b
              tempb:=self.getword(r.pc.l);
              r.pc.l:=r.pc.l+2;
              if dir<>$3c then begin
                if (dir shr 3)<>0 then self.contador:=self.contador+12+calc_ea_t_bw(dir)
                  else self.contador:=self.contador+8;
                tempb2:=self.leerdir_b(dir) xor tempb;
                self.ponerdir_b2(dir,tempb2);
                r.cc.v:=false;
                r.cc.c:=false;
                r.cc.n:=(tempb2 and $80)<>0;
                r.cc.z:=(tempb2=0);
              end else begin // # eori.b toc
                self.contador:=self.contador+20;
                tempb2:=(coger_band(self.r) and $ff) xor tempb;
                r.cc.x:=(tempb2 and $10)<>0;
                r.cc.n:=(tempb2 and $8)<>0;
                r.cc.z:=(tempb2 and $4)<>0;
                r.cc.v:=(tempb2 and $2)<>0;
                r.cc.c:=(tempb2 and $1)<>0;
              end;
            end;
        $29:begin  // # eori.w
              tempw:=self.getword(r.pc.l);
              r.pc.l:=r.pc.l+2;
              if dir<>$3c then begin
                if (dir shr 3)<>0 then self.contador:=self.contador+12+calc_ea_t_bw(dir)
                  else self.contador:=self.contador+8;
                tempw2:=self.leerdir_w(dir) xor tempw;
                self.ponerdir_w2(dir,tempw2);
                r.cc.v:=false;
                r.cc.c:=false;
                r.cc.n:=(tempw2 and $8000)<>0;
                r.cc.z:=(tempw2=0);
              end else begin // # eori.w tos
                self.contador:=self.contador+20;
                MessageDlg('Mierda eori.w tos', mtInformation,[mbOk], 0);
              end;
            end;
        $2a:begin  // # eori.l
              if (dir shr 3)<>0 then self.contador:=self.contador+20+calc_ea_t_l(dir)
                else self.contador:=self.contador+16;
              templ:=self.getword(r.pc.l) shl 16;
              templ:=templ or self.getword(r.pc.l+2);
              r.pc.l:=r.pc.l+4;
              templ2:=self.leerdir_l(dir) xor templ;
              self.ponerdir_l2(dir,templ2);
              r.cc.v:=false;
              r.cc.c:=false;
              r.cc.n:=((templ2 shr 24) and $80)<>0;
              r.cc.z:=(templ2=0);
            end;
        $30:begin // # cmpi.b
              if (dir shr 3)<>0 then self.contador:=self.contador+8+calc_ea_t_bw(dir)
                else self.contador:=self.contador+8;
              tempb:=self.getword(r.pc.l) and $ff;
              r.pc.l:=r.pc.l+2;
              tempb2:=self.leerdir_b(dir);
              tempw:=tempb2-tempb;
              r.cc.n:=(tempw and $80)<>0;
              r.cc.z:=((tempw and $ff)=0);
	            r.cc.v:=(((tempb xor tempb2) and (tempw xor tempb2)) and $80)<>0;
	            r.cc.c:=(tempw and $100)<>0;
              end;
        $31:begin // # cmpi.w
              if (dir shr 3)<>0 then self.contador:=self.contador+8+calc_ea_t_bw(dir)
                else self.contador:=self.contador+8;
              tempw:=self.getword(r.pc.l);
              r.pc.l:=r.pc.l+2;
              tempw2:=self.leerdir_w(dir);
              templ:=tempw2-tempw;
              r.cc.n:=(templ and $8000)<>0;
              r.cc.z:=((templ and $ffff)=0);
	            r.cc.v:=((((tempw xor tempw2) and (templ xor tempw2)) shr 8) and $80)<>0;
	            r.cc.c:=(templ and $10000)<>0;
            end;
        $32:begin  // # cmpi.l
              if (dir shr 3)<>0 then self.contador:=self.contador+12+calc_ea_t_l(dir)
                else self.contador:=self.contador+14;
              templ:=self.getword(r.pc.l) shl 16;
              templ:=templ or self.getword(r.pc.l+2);
              r.pc.l:=r.pc.l+4;
              templ2:=self.leerdir_l(dir);
              templ3:=templ2-templ;
              r.cc.n:=((templ3 shr 24) and $80)<>0;
              r.cc.z:=(templ3=0);
	            r.cc.v:=((((templ xor templ2) and (templ3 xor templ2)) shr 24) and $80)<>0;
	            r.cc.c:=((((templ and templ3) or (not(templ2) and (templ or templ3))) shr 23) and $100)<>0;
            end;
        else MessageDlg('Instruccion $0: '+inttohex((instruccion shr 6) and $3f,10)+' - '+inttohex(r.pc.l,10), mtInformation,[mbOk], 0);
      end;
   $1:begin  //+++++++++++++++ move.b
        tempb:=self.leerdir_b(dir);
        tempb2:=dest or (((instruccion shr 6) and $7) shl 3);
        self.ponerdir_b(tempb2,tempb);
        self.contador:=self.contador+calc_move_t_bw(dir,tempb2);
        r.cc.v:=false;
        r.cc.c:=false;
        r.cc.n:=(tempb and $80)<>0;
        r.cc.z:=(tempb=0);
      end;
   $2:if (instruccion shr 6) and $7=1 then begin //++++++++  movea.l
        self.contador:=self.contador+4;
        r.a[dest].l:=self.leerdir_l(dir);
      end else begin // ++++++++++++++  move.l
        templ:=self.leerdir_l(dir);
        tempb2:=dest or (((instruccion shr 6) and $7) shl 3);
        self.ponerdir_l(tempb2,templ);
        self.contador:=self.contador+calc_move_t_l(dir,tempb2);
        r.cc.v:=false;
        r.cc.c:=false;
        r.cc.n:=((templ shr 24) and $80)<>0;
        r.cc.z:=(templ=0);
      end;
   $3:if (instruccion shr 6) and $7=1 then begin //+++++++++++++++ movea.w
        self.contador:=self.contador+4;
        r.a[dest].l:=smallint(self.leerdir_w(dir));
      end else begin //++++++++++++++++++++ move.w
        tempw:=self.leerdir_w(dir);
        tempb2:=dest or (((instruccion shr 6) and $7) shl 3);
        self.ponerdir_w(tempb2,tempw);
        self.contador:=self.contador+calc_move_t_bw(dir,tempb2);
        r.cc.v:=false;
        r.cc.c:=false;
        r.cc.n:=(tempw and $8000)<>0;
        r.cc.z:=(tempw=0);
      end;
   $4:case (instruccion shr 6) and $3f of
          $02:begin // # negx.l Añadido 13/07
                if (dir shr 3)<>0 then self.contador:=self.contador+12+calc_ea_t_l(dir)
                  else self.contador:=self.contador+6;
                templ:=self.leerdir_l(dir);
                templ2:=0-templ-byte(r.cc.x);
                r.cc.n:=((templ2 shr 24) and $80)<>0;
                r.cc.c:=((((templ and templ2) or (not(0) and (templ or templ2))) shr 23) and $100)<>0;
                r.cc.x:=r.cc.c;
                r.cc.z:=(templ2=0);
                r.cc.v:=(((templ and templ2) shr 24) and $80)<>0;
                self.ponerdir_l2(dir,templ2);
              end;
          $03:begin // # move from sr
                if dir<8 then self.contador:=self.contador+6
                  else self.contador:=self.contador+8+calc_ea_t_bw(dir);
                self.ponerdir_w(dir,coger_band(self.r));
              end;
          $7,$f,$17,$1f,$27,$2f,$37,$3f:begin // # lea
                r.a[dest].l:=self.leerdir_ea(dir);
                case dir of
                  $10..$17:self.contador:=self.contador+4;  //(An)
                  $28..$2f,$38,$3a:self.contador:=self.contador+8; //d(An) xxx.W d(PC)
                  $30..$37,$3b,$39:self.contador:=self.contador+12; //d(An,ix) d(PC,ix) xxx.L
                end
              end;
          $08:begin // # clr.b
                if (dir shr 3)<>0 then self.contador:=self.contador+8+calc_ea_t_bw(dir)
                  else self.contador:=self.contador+4;
                self.ponerdir_b(dir,0);
                r.cc.n:=false;
                r.cc.v:=false;
                r.cc.c:=false;
                r.cc.z:=true;
              end;
          $09:begin // # clr.w
                if (dir shr 3)<>0 then self.contador:=self.contador+8+calc_ea_t_bw(dir)
                  else self.contador:=self.contador+4;
                self.ponerdir_w(dir,0);
                r.cc.n:=false;
                r.cc.v:=false;
                r.cc.c:=false;
                r.cc.z:=true;
              end;
          $0a:begin // # clr.l
                if (dir shr 3)<>0 then self.contador:=self.contador+12+calc_ea_t_l(dir)
                  else self.contador:=self.contador+6;
                self.ponerdir_l(dir,0);
                r.cc.n:=false;
                r.cc.v:=false;
                r.cc.c:=false;
                r.cc.z:=true;
              end;
          $10:begin  // # neg.b
                if (dir shr 3)<>0 then self.contador:=self.contador+8+calc_ea_t_bw(dir)
                  else self.contador:=self.contador+4;
                tempb:=self.leerdir_b(dir);
                tempw:=0-tempb;
                r.cc.n:=(tempw and $80)<>0;
                r.cc.c:=(tempw and $100)<>0;
                r.cc.x:=r.cc.c;
                r.cc.z:=(tempw and $ff)=0;
                r.cc.v:=((tempb and tempw) and $80)<>0;
                self.ponerdir_b2(dir,tempw and $ff);
              end;
          $11:begin  // # neg.w
                if (dir shr 3)<>0 then self.contador:=self.contador+8+calc_ea_t_bw(dir)
                  else self.contador:=self.contador+4;
                tempw:=self.leerdir_w(dir);
                templ:=0-tempw;
                r.cc.n:=(templ and $8000)<>0;
                r.cc.c:=(templ and $10000)<>0;
                r.cc.x:=r.cc.c;
                r.cc.z:=(templ and $ffff)=0;
                r.cc.v:=(((tempw and templ) shr 8) and $80)<>0;
                self.ponerdir_w2(dir,templ and $ffff);
              end;
          $12:begin  // # neg.l
                if (dir shr 3)<>0 then self.contador:=self.contador+12+calc_ea_t_l(dir)
                  else self.contador:=self.contador+6;
                templ:=self.leerdir_l(dir);
                templ2:=0-templ;
                r.cc.n:=((templ2 shr 24) and $80)<>0;
                r.cc.c:=((((templ and templ2) or (not(0) and (templ or templ2))) shr 23) and $100)<>0;
                r.cc.x:=r.cc.c;
                r.cc.z:=(templ2=0);
                r.cc.v:=(((templ and templ2) shr 24) and $80)<>0;
                self.ponerdir_l2(dir,templ2);
              end;
          $13:begin  // # move to ccr
                self.contador:=self.contador+12+calc_ea_t_bw(dir);
                tempw:=self.leerdir_w(dir);
                r.cc.x:=(tempw and $10)<>0;
                r.cc.n:=(tempw and $8)<>0;
                r.cc.z:=(tempw and $4)<>0;
                r.cc.v:=(tempw and $2)<>0;
                r.cc.c:=(tempw and $1)<>0;
              end;
          $18:begin // # not.b
                if (dir shr 3)<>0 then self.contador:=self.contador+8+calc_ea_t_bw(dir)
                  else self.contador:=self.contador+4;
                tempb:=not(self.leerdir_b(dir));
                self.ponerdir_b2(dir,tempb);
                r.cc.c:=false;
                r.cc.v:=false;
                r.cc.n:=(tempb and $80)<>0;
                r.cc.z:=(tempb=0);
              end;
          $19:begin // # not.w
                if (dir shr 3)<>0 then self.contador:=self.contador+8+calc_ea_t_bw(dir)
                  else self.contador:=self.contador+4;
                tempw:=not(self.leerdir_w(dir));
                self.ponerdir_w2(dir,tempw);
                r.cc.c:=false;
                r.cc.v:=false;
                r.cc.n:=(tempw and $8000)<>0;
                r.cc.z:=(tempw=0);
              end;
          $1a:begin // # not.l
                if (dir shr 3)<>0 then self.contador:=self.contador+12+calc_ea_t_l(dir)
                  else self.contador:=self.contador+6;
                templ:=not(self.leerdir_l(dir));
                self.ponerdir_l2(dir,templ);
                r.cc.c:=false;
                r.cc.v:=false;
                r.cc.n:=((templ shr 24) and $80)<>0;
                r.cc.z:=(templ=0);
              end;
          $1b:if r.cc.s then begin //++++ move to sr
                self.contador:=self.contador+12;
                tempw:=self.leerdir_w(dir);
                self.poner_band(tempw);
              end else MessageDlg('Mierda error de privilegio MOVE TO SR'+inttostr(r.pc.l), mtInformation,[mbOk], 0);
          $21:begin // # pea
                case dir of
                   $0..$7:begin  // # swap!!!
                        self.contador:=self.contador+4;
                        templ:=(r.d[orig].wl shl 16) or r.d[orig].wh;
                        r.cc.c:=false;
                        r.cc.v:=false;
                        r.cc.n:=((templ shr 24) and $80)<>0;
                        r.cc.z:=(templ=0);
                        r.d[orig].l:=templ;
                        end;
                   $10..$17:begin // (An)
                        self.contador:=self.contador+12;
                        templ:=r.a[dir and 7].l;
                        r.sp.l:=r.sp.l-4;
                        self.putword(r.sp.l,templ shr 16);
                        self.putword(r.sp.l+2,templ and $FFFF);
                        end;
                   $28..$2f:begin  //Añadido 13/07  d(An)
                        self.contador:=self.contador+16;
                        tempw:=self.getword(r.pc.l);
                        r.pc.l:=r.pc.l+2;
                        templ:=r.a[dir and $7].l+smallint(tempw);
                        r.sp.l:=r.sp.l-4;
                        self.putword(r.sp.l,templ shr 16);
                        self.putword(r.sp.l+2,templ and $FFFF);
                        end;
                   $30..$37:begin //Añadido 13/07  d(An+ix)
                        tempw:=self.getword(r.pc.l);
                        r.pc.l:=r.pc.l+2;
                        tempb:=tempw and $ff;
                        self.contador:=self.contador+20;
                        if (tempw and $8000)<>0 then begin
                            if (tempw and $800)<>0 then templ:=r.a[dir and $7].l+r.a[(tempw shr 12) and $7].l+shortint(tempb)
                              else templ:=r.a[dir and $7].l+smallint(r.a[(tempw shr 12) and $7].wl)+shortint(tempb);
                        end else begin
                            if (tempw and $800)<>0 then templ:=r.a[dir and $7].l+r.d[(tempw shr 12) and $7].l+shortint(tempb)
                              else templ:=r.a[dir and $7].l+smallint(r.d[(tempw shr 12) and $7].wl)+shortint(tempb);
                        end;
                        r.sp.l:=r.sp.l-4;
                        self.putword(r.sp.l,templ shr 16);
                        self.putword(r.sp.l+2,templ and $FFFF);
                        end;
                   $38:begin  //Añadido 13/07  xxx.W
                        self.contador:=self.contador+16;
                        tempw:=smallint(self.getword(r.pc.l));
                        r.pc.l:=r.pc.l+2;
                        r.sp.l:=r.sp.l-4;
                        self.putword(r.sp.l,0);
                        self.putword(r.sp.l+2,tempw);
                        end;
                   $39:begin  // xxx.L
                        self.contador:=self.contador+20;
                        templ:=self.getword(r.pc.l) shl 16;
                        templ:=templ or self.getword(r.pc.l+2);
                        r.pc.l:=r.pc.l+4;
                        r.sp.l:=r.sp.l-4;
                        self.putword(r.sp.l,templ shr 16);
                        self.putword(r.sp.l+2,templ and $FFFF);
                      end;
                   $3a:begin  // d(PC)
                          self.contador:=self.contador+16;
                          tempw:=self.getword(r.pc.l);
                          templ:=r.pc.l+smallint(tempw);
                          r.pc.l:=r.pc.l+2;
                          r.sp.l:=r.sp.l-4;
                          self.putword(r.sp.l,templ shr 16);
                          self.putword(r.sp.l+2,templ and $FFFF);
                       end;
                   else MessageDlg('Mierda pea error de direccionamiento '+inttohex(dir,10)+' - '+inttohex(r.pc.l,10), mtInformation,[mbOk], 0);
                end;
              end;
          $22:begin
                if (dir shr 3)=0 then begin // # ext.w
                   self.contador:=self.contador+4;
                   tempb:=r.d[orig].l0;
                   if (tempb and $80)<>0 then tempw:=$FF00 or tempb
                      else tempw:=tempb;
                   r.cc.c:=false;
                   r.cc.v:=false;
                   r.cc.n:=(tempw and $8000)<>0;
                   r.cc.z:=(tempw=0);
                   r.d[orig].wl:=tempw;
                end else begin  // # movem.w r->m
                  tempw:=self.getword(r.pc.l);
                  r.pc.l:=r.pc.l+2;
                  tempw2:=tempw;
                  tempb2:=0;
                  for tempb:=0 to 15 do begin
                    if (tempw2 and 1)<>0 then tempb2:=tempb2+1;
                    tempw2:=tempw2 shr 1;
                  end;
                  self.contador:=self.contador+(tempb2 shl 2);
                  case dir of
                    $10..$17,$20..$27:self.contador:=self.contador+8;
                    $28..$2f,$38:self.contador:=self.contador+12;
                    $30..$37:self.contador:=self.contador+14;
                    $39:self.contador:=self.contador+16;
                  end;
                  case dir of
                    $10..$17,$28..$2f,$39:begin
                              templ:=self.leerdir_ea(dir);
                              if (tempw and $0001)<>0 then begin
                                self.putword(templ,r.d[0].wl);
                                templ:=templ+2;
                              end;
                              if (tempw and $0002)<>0 then begin
                                self.putword(templ,r.d[1].wl);
                                templ:=templ+2
                              end;
                              if (tempw and $0004)<>0 then begin
                                self.putword(templ,r.d[2].wl);
                                templ:=templ+2;
                              end;
                              if (tempw and $0008)<>0 then begin
                                self.putword(templ,r.d[3].wl);
                                templ:=templ+2;
                              end;
                              if (tempw and $0010)<>0 then begin
                                self.putword(templ,r.d[4].wl);
                                templ:=templ+2;
                              end;
                              if (tempw and $0020)<>0 then begin
                                self.putword(templ,r.d[5].wl);
                                templ:=templ+2;
                              end;
                              if (tempw and $0040)<>0 then begin
                                self.putword(templ,r.d[6].wl);
                                templ:=templ+2;
                              end;
                              if (tempw and $0080)<>0 then begin
                                self.putword(templ,r.d[7].wl);
                                templ:=templ+2;
                              end;
                              if (tempw and $0100)<>0 then begin
                                self.putword(templ,r.a[0].wl);
                                templ:=templ+2;
                              end;
                              if (tempw and $0200)<>0 then begin
                                self.putword(templ,r.a[1].wl);
                                templ:=templ+2;
                              end;
                              if (tempw and $0400)<>0 then begin
                                self.putword(templ,r.a[2].wl);
                                templ:=templ+2;
                              end;
                              if (tempw and $0800)<>0 then begin
                                self.putword(templ,r.a[3].wl);
                                templ:=templ+2;
                              end;
                              if (tempw and $1000)<>0 then begin
                                self.putword(templ,r.a[4].wl);
                                templ:=templ+2;
                              end;
                              if (tempw and $2000)<>0 then begin
                                self.putword(templ,r.a[5].wl);
                                templ:=templ+2;
                              end;
                              if (tempw and $4000)<>0 then begin
                                self.putword(templ,r.a[6].wl);
                                templ:=templ+2;
                              end;
                              if (tempw and $8000)<>0 then begin
                                self.putword(templ,r.a[7].wl);
                              end;
                             end;
                    $20..$27:begin
                            if (tempw and $0001)<>0 then self.ponerdir_w(dir,r.a[7].wl);
                            if (tempw and $0002)<>0 then self.ponerdir_w(dir,r.a[6].wl);
                            if (tempw and $0004)<>0 then self.ponerdir_w(dir,r.a[5].wl);
                            if (tempw and $0008)<>0 then self.ponerdir_w(dir,r.a[4].wl);
                            if (tempw and $0010)<>0 then self.ponerdir_w(dir,r.a[3].wl);
                            if (tempw and $0020)<>0 then self.ponerdir_w(dir,r.a[2].wl);
                            if (tempw and $0040)<>0 then self.ponerdir_w(dir,r.a[1].wl);
                            if (tempw and $0080)<>0 then self.ponerdir_w(dir,r.a[0].wl);
                            if (tempw and $0100)<>0 then self.ponerdir_w(dir,r.d[7].wl);
                            if (tempw and $0200)<>0 then self.ponerdir_w(dir,r.d[6].wl);
                            if (tempw and $0400)<>0 then self.ponerdir_w(dir,r.d[5].wl);
                            if (tempw and $0800)<>0 then self.ponerdir_w(dir,r.d[4].wl);
                            if (tempw and $1000)<>0 then self.ponerdir_w(dir,r.d[3].wl);
                            if (tempw and $2000)<>0 then self.ponerdir_w(dir,r.d[2].wl);
                            if (tempw and $4000)<>0 then self.ponerdir_w(dir,r.d[1].wl);
                            if (tempw and $8000)<>0 then self.ponerdir_w(dir,r.d[0].wl);
                          end;
                    else MessageDlg('Mierda movem.w $22 '+inttohex(dir,2)+' - '+inttohex(r.pc.l,10), mtInformation,[mbOk], 0);
                  end;
                end;
              end;
          $23:if (dir shr 3)=0 then begin // # ext.l
                   self.contador:=self.contador+4;
                   tempw:=r.d[orig].wl;
                   if (tempw and $8000)<>0 then templ:=$FFFF0000 or tempw
                      else templ:=tempw;
                   r.cc.c:=false;
                   r.cc.v:=false;
                   r.cc.n:=((templ shr 24) and $80)<>0;
                   r.cc.z:=(templ=0);
                   r.d[orig].l:=templ;
              end else begin // # movem.l d=0 los bits de dir son destino r-->m
                tempw:=self.getword(r.pc.l);
                r.pc.l:=r.pc.l+2;
                tempw2:=tempw;
                tempb2:=0;
                for tempb:=0 to 15 do begin
                  if (tempw2 and 1)<>0 then tempb2:=tempb2+1;
                  tempw2:=tempw2 shr 1;
                end;
                self.contador:=self.contador+(tempb2 shl 3);
                case dir of
                    $10..$17,$20..$27:self.contador:=self.contador+8;
                    $28..$2f,$38:self.contador:=self.contador+12;
                    $30..$37:self.contador:=self.contador+14;
                    $39:self.contador:=self.contador+16;
                  end;
                case dir of
                  $10..$17,$28..$37,$39:begin  //$30..$37 Añadido 13/07
                              templ:=self.leerdir_ea(dir);
                              if (tempw and $0001)<>0 then begin
                                self.putword(templ,r.d[0].wh);
                                self.putword(templ+2,r.d[0].wl);
                                templ:=templ+4;
                              end;
                              if (tempw and $0002)<>0 then begin
                                self.putword(templ,r.d[1].wh);
                                self.putword(templ+2,r.d[1].wl);
                                templ:=templ+4;
                              end;
                              if (tempw and $0004)<>0 then begin
                                self.putword(templ,r.d[2].wh);
                                self.putword(templ+2,r.d[2].wl);
                                templ:=templ+4;
                              end;
                              if (tempw and $0008)<>0 then begin
                                self.putword(templ,r.d[3].wh);
                                self.putword(templ+2,r.d[3].wl);
                                templ:=templ+4;
                              end;
                              if (tempw and $0010)<>0 then begin
                                self.putword(templ,r.d[4].wh);
                                self.putword(templ+2,r.d[4].wl);
                                templ:=templ+4;
                              end;
                              if (tempw and $0020)<>0 then begin
                                self.putword(templ,r.d[5].wh);
                                self.putword(templ+2,r.d[5].wl);
                                templ:=templ+4;
                              end;
                              if (tempw and $0040)<>0 then begin
                                self.putword(templ,r.d[6].wh);
                                self.putword(templ+2,r.d[6].wl);
                                templ:=templ+4;
                              end;
                              if (tempw and $0080)<>0 then begin
                                self.putword(templ,r.d[7].wh);
                                self.putword(templ+2,r.d[7].wl);
                                templ:=templ+4;
                              end;
                              if (tempw and $0100)<>0 then begin
                                self.putword(templ,r.a[0].wh);
                                self.putword(templ+2,r.a[0].wl);
                                templ:=templ+4;
                              end;
                              if (tempw and $0200)<>0 then begin
                                self.putword(templ,r.a[1].wh);
                                self.putword(templ+2,r.a[1].wl);
                                templ:=templ+4;
                              end;
                              if (tempw and $0400)<>0 then begin
                                self.putword(templ,r.a[2].wh);
                                self.putword(templ+2,r.a[2].wl);
                                templ:=templ+4;
                              end;
                              if (tempw and $0800)<>0 then begin
                                self.putword(templ,r.a[3].wh);
                                self.putword(templ+2,r.a[3].wl);
                                templ:=templ+4;
                              end;
                              if (tempw and $1000)<>0 then begin
                                self.putword(templ,r.a[4].wh);
                                self.putword(templ+2,r.a[4].wl);
                                templ:=templ+4;
                              end;
                              if (tempw and $2000)<>0 then begin
                                self.putword(templ,r.a[5].wh);
                                self.putword(templ+2,r.a[5].wl);
                                templ:=templ+4;
                              end;
                              if (tempw and $4000)<>0 then begin
                                self.putword(templ,r.a[6].wh);
                                self.putword(templ+2,r.a[6].wl);
                                templ:=templ+4;
                              end;
                              if (tempw and $8000)<>0 then begin
                                self.putword(templ,r.a[7].wh);
                                self.putword(templ+2,r.a[7].wl);
                              end;
                             end;
                  $20..$27:begin
                            if (tempw and $0001)<>0 then self.ponerdir_l(dir,r.a[7].l);
                            if (tempw and $0002)<>0 then self.ponerdir_l(dir,r.a[6].l);
                            if (tempw and $0004)<>0 then self.ponerdir_l(dir,r.a[5].l);
                            if (tempw and $0008)<>0 then self.ponerdir_l(dir,r.a[4].l);
                            if (tempw and $0010)<>0 then self.ponerdir_l(dir,r.a[3].l);
                            if (tempw and $0020)<>0 then self.ponerdir_l(dir,r.a[2].l);
                            if (tempw and $0040)<>0 then self.ponerdir_l(dir,r.a[1].l);
                            if (tempw and $0080)<>0 then self.ponerdir_l(dir,r.a[0].l);
                            if (tempw and $0100)<>0 then self.ponerdir_l(dir,r.d[7].l);
                            if (tempw and $0200)<>0 then self.ponerdir_l(dir,r.d[6].l);
                            if (tempw and $0400)<>0 then self.ponerdir_l(dir,r.d[5].l);
                            if (tempw and $0800)<>0 then self.ponerdir_l(dir,r.d[4].l);
                            if (tempw and $1000)<>0 then self.ponerdir_l(dir,r.d[3].l);
                            if (tempw and $2000)<>0 then self.ponerdir_l(dir,r.d[2].l);
                            if (tempw and $4000)<>0 then self.ponerdir_l(dir,r.d[1].l);
                            if (tempw and $8000)<>0 then self.ponerdir_l(dir,r.d[0].l);
                          end;
                    else MessageDlg('Mierda movem.l $23 '+inttohex(dir,2)+' - '+inttohex(r.pc.l,10), mtInformation,[mbOk], 0);
                  end;
                end;
          $28:begin // # tst.b
                if (dir shr 3)<>0 then self.contador:=self.contador+4+calc_ea_t_bw(dir)
                  else self.contador:=self.contador+4;
                tempb:=self.leerdir_b(dir);
                r.cc.v:=false;
                r.cc.c:=false;
                r.cc.n:=(tempb and $80)<>0;
  	            r.cc.z:=(tempb=0);
              end;
          $29:begin // # tst.w
                if (dir shr 3)<>0 then self.contador:=self.contador+4+calc_ea_t_bw(dir)
                  else self.contador:=self.contador+4;
                tempw:=self.leerdir_w(dir);
                r.cc.v:=false;
                r.cc.c:=false;
                r.cc.n:=(tempw and $8000)<>0;
  	            r.cc.z:=(tempw=0);
              end;
          $2a:begin // # tst.l
                if (dir shr 3)<>0 then self.contador:=self.contador+4+calc_ea_t_l(dir)
                  else self.contador:=self.contador+4;
                templ:=self.leerdir_l(dir);
                r.cc.v:=false;
                r.cc.c:=false;
                r.cc.n:=((templ shr 24) and $80)<>0;
  	            r.cc.z:=(templ=0);
              end;
          $2b:begin // # tas
                if (dir shr 3)<>0 then self.contador:=self.contador+10+calc_ea_t_bw(dir)
                  else self.contador:=self.contador+4;
                tempb:=r.d[dir].l0;
                r.cc.z:=(tempb=0);
                r.cc.n:=(tempb and $80)<>0;
                r.cc.v:=false;
                r.cc.c:=false;
                r.d[dir].l0:=tempb or $80;
              end;
          $32:begin // # movem.w  bits dir son origen m-->r
                tempw:=self.getword(r.pc.l);
                r.pc.l:=r.pc.l+2;
                tempw2:=tempw;
                  tempb2:=0;
                  for tempb:=0 to 15 do begin
                    if (tempw2 and 1)<>0 then tempb2:=tempb2+1;
                    tempw2:=tempw2 shr 1;
                  end;
                  self.contador:=self.contador+(tempb2 shl 2);
                  case dir of
                    $10..$1f:self.contador:=self.contador+12;
                    $28..$2f,$38,$3a:self.contador:=self.contador+16;
                    $30..$37,$3b:self.contador:=self.contador+18;
                    $39:self.contador:=self.contador+20;
                  end;
                case dir of
                  $10..$17,$28..$37,$39:begin
                            templ:=self.leerdir_ea(dir);
                            if (tempw and $0001)<>0 then begin
                              r.d[0].l:=smallint(self.getword(templ));
                              templ:=templ+2;
                            end;
                            if (tempw and $0002)<>0 then begin
                              r.d[1].l:=smallint(self.getword(templ));
                              templ:=templ+2;
                            end;
                            if (tempw and $0004)<>0 then begin
                              r.d[2].l:=smallint(self.getword(templ));
                              templ:=templ+2;
                            end;
                            if (tempw and $0008)<>0 then begin
                              r.d[3].l:=smallint(self.getword(templ));
                              templ:=templ+2;
                            end;
                            if (tempw and $0010)<>0 then begin
                              r.d[4].l:=smallint(self.getword(templ));
                              templ:=templ+2;
                            end;
                            if (tempw and $0020)<>0 then begin
                              r.d[5].l:=smallint(self.getword(templ));
                              templ:=templ+2;
                            end;
                            if (tempw and $0040)<>0 then begin
                              r.d[6].l:=smallint(self.getword(templ));
                              templ:=templ+2;
                            end;
                            if (tempw and $0080)<>0 then begin
                              r.d[7].l:=smallint(self.getword(templ));
                              templ:=templ+2;
                            end;
                            if (tempw and $0100)<>0 then begin
                              r.a[0].l:=smallint(self.getword(templ));
                              templ:=templ+2;
                            end;
                            if (tempw and $0200)<>0 then begin
                              r.a[1].l:=smallint(self.getword(templ));
                              templ:=templ+2;
                            end;
                            if (tempw and $0400)<>0 then begin
                              r.a[2].l:=smallint(self.getword(templ));
                              templ:=templ+2;
                            end;
                            if (tempw and $0800)<>0 then begin
                              r.a[3].l:=smallint(self.getword(templ));
                              templ:=templ+2;
                            end;
                            if (tempw and $1000)<>0 then begin
                              r.a[4].l:=smallint(self.getword(templ));
                              templ:=templ+2;
                            end;
                            if (tempw and $2000)<>0 then begin
                              r.a[5].l:=smallint(self.getword(templ));
                              templ:=templ+2;
                            end;
                            if (tempw and $4000)<>0 then begin
                              r.a[6].l:=smallint(self.getword(templ));
                              templ:=templ+2;
                            end;
                            if (tempw and $8000)<>0 then begin
                              r.a[7].l:=smallint(self.getword(templ));
                            end;
                           end;
                  $18..$1f:begin
                            if (tempw and $0001)<>0 then r.d[0].l:=smallint(self.leerdir_w(dir));
                            if (tempw and $0002)<>0 then r.d[1].l:=smallint(self.leerdir_w(dir));
                            if (tempw and $0004)<>0 then r.d[2].l:=smallint(self.leerdir_w(dir));
                            if (tempw and $0008)<>0 then r.d[3].l:=smallint(self.leerdir_w(dir));
                            if (tempw and $0010)<>0 then r.d[4].l:=smallint(self.leerdir_w(dir));
                            if (tempw and $0020)<>0 then r.d[5].l:=smallint(self.leerdir_w(dir));
                            if (tempw and $0040)<>0 then r.d[6].l:=smallint(self.leerdir_w(dir));
                            if (tempw and $0080)<>0 then r.d[7].l:=smallint(self.leerdir_w(dir));
                            if (tempw and $0100)<>0 then r.a[0].l:=smallint(self.leerdir_w(dir));
                            if (tempw and $0200)<>0 then r.a[1].l:=smallint(self.leerdir_w(dir));
                            if (tempw and $0400)<>0 then r.a[2].l:=smallint(self.leerdir_w(dir));
                            if (tempw and $0800)<>0 then r.a[3].l:=smallint(self.leerdir_w(dir));
                            if (tempw and $1000)<>0 then r.a[4].l:=smallint(self.leerdir_w(dir));
                            if (tempw and $2000)<>0 then r.a[5].l:=smallint(self.leerdir_w(dir));
                            if (tempw and $4000)<>0 then r.a[6].l:=smallint(self.leerdir_w(dir));
                            if (tempw and $8000)<>0 then r.a[7].l:=smallint(self.leerdir_w(dir));
                        end
                  else MessageDlg('Mierda movem.w $32 '+inttohex(dir,2)+' - '+inttohex(r.pc.l,10), mtInformation,[mbOk], 0);
                end;
              end;
          $33:begin // # movem.l  bits dir son origen m-->r
                tempw:=self.getword(r.pc.l);
                r.pc.l:=r.pc.l+2;
                tempw2:=tempw;
                tempb2:=0;
                for tempb:=0 to 15 do begin
                    if (tempw2 and 1)<>0 then tempb2:=tempb2+1;
                    tempw2:=tempw2 shr 1;
                end;
                self.contador:=self.contador+(tempb2 shl 3);
                case dir of
                    $10..$1f:self.contador:=self.contador+12;
                    $28..$2f,$38,$3a:self.contador:=self.contador+16;
                    $30..$37,$3b:self.contador:=self.contador+18;
                    $39:self.contador:=self.contador+20;
                  end;
                case dir of
                $10..$17,$28..$37,$39,$3a:begin
                      templ:=self.leerdir_ea(dir);
                      if (tempw and $0001)<>0 then begin
                         r.d[0].wh:=self.getword(templ);
                         r.d[0].wl:=self.getword(templ+2);
                         templ:=templ+4;
                      end;
                      if (tempw and $0002)<>0 then begin
                         r.d[1].wh:=self.getword(templ);
                         r.d[1].wl:=self.getword(templ+2);
                         templ:=templ+4;
                      end;
                      if (tempw and $0004)<>0 then begin
                         r.d[2].wh:=self.getword(templ);
                         r.d[2].wl:=self.getword(templ+2);
                         templ:=templ+4;
                      end;
                      if (tempw and $0008)<>0 then begin
                         r.d[3].wh:=self.getword(templ);
                         r.d[3].wl:=self.getword(templ+2);
                         templ:=templ+4;
                      end;
                      if (tempw and $0010)<>0 then begin
                         r.d[4].wh:=self.getword(templ);
                         r.d[4].wl:=self.getword(templ+2);
                         templ:=templ+4;
                      end;
                      if (tempw and $0020)<>0 then begin
                         r.d[5].wh:=self.getword(templ);
                         r.d[5].wl:=self.getword(templ+2);
                         templ:=templ+4;
                      end;
                      if (tempw and $0040)<>0 then begin
                         r.d[6].wh:=self.getword(templ);
                         r.d[6].wl:=self.getword(templ+2);
                         templ:=templ+4;
                      end;
                      if (tempw and $0080)<>0 then begin
                         r.d[7].wh:=self.getword(templ);
                         r.d[7].wl:=self.getword(templ+2);
                         templ:=templ+4;
                      end;
                      if (tempw and $0100)<>0 then begin
                         r.a[0].wh:=self.getword(templ);
                         r.a[0].wl:=self.getword(templ+2);
                         templ:=templ+4;
                      end;
                      if (tempw and $0200)<>0 then begin
                         r.a[1].wh:=self.getword(templ);
                         r.a[1].wl:=self.getword(templ+2);
                         templ:=templ+4;
                      end;
                      if (tempw and $0400)<>0 then begin
                         r.a[2].wh:=self.getword(templ);
                         r.a[2].wl:=self.getword(templ+2);
                         templ:=templ+4;
                      end;
                      if (tempw and $0800)<>0 then begin
                         r.a[3].wh:=self.getword(templ);
                         r.a[3].wl:=self.getword(templ+2);
                         templ:=templ+4;
                      end;
                      if (tempw and $1000)<>0 then begin
                         r.a[4].wh:=self.getword(templ);
                         r.a[4].wl:=self.getword(templ+2);
                         templ:=templ+4;
                      end;
                      if (tempw and $2000)<>0 then begin
                         r.a[5].wh:=self.getword(templ);
                         r.a[5].wl:=self.getword(templ+2);
                         templ:=templ+4;
                      end;
                      if (tempw and $4000)<>0 then begin
                         r.a[6].wh:=self.getword(templ);
                         r.a[6].wl:=self.getword(templ+2);
                         templ:=templ+4;
                      end;
                      if (tempw and $8000)<>0 then begin
                         r.a[7].wh:=self.getword(templ);
                         r.a[7].wl:=self.getword(templ+2);
                      end;
                end;
                $18..$1f:begin
                            if (tempw and $0001)<>0 then r.d[0].l:=self.leerdir_l(dir); //D0
                            if (tempw and $0002)<>0 then r.d[1].l:=self.leerdir_l(dir);
                            if (tempw and $0004)<>0 then r.d[2].l:=self.leerdir_l(dir);
                            if (tempw and $0008)<>0 then r.d[3].l:=self.leerdir_l(dir);
                            if (tempw and $0010)<>0 then r.d[4].l:=self.leerdir_l(dir);
                            if (tempw and $0020)<>0 then r.d[5].l:=self.leerdir_l(dir);
                            if (tempw and $0040)<>0 then r.d[6].l:=self.leerdir_l(dir);
                            if (tempw and $0080)<>0 then r.d[7].l:=self.leerdir_l(dir);
                            if (tempw and $0100)<>0 then r.a[0].l:=self.leerdir_l(dir);
                            if (tempw and $0200)<>0 then r.a[1].l:=self.leerdir_l(dir);
                            if (tempw and $0400)<>0 then r.a[2].l:=self.leerdir_l(dir);
                            if (tempw and $0800)<>0 then r.a[3].l:=self.leerdir_l(dir);
                            if (tempw and $1000)<>0 then r.a[4].l:=self.leerdir_l(dir);
                            if (tempw and $2000)<>0 then r.a[5].l:=self.leerdir_l(dir);
                            if (tempw and $4000)<>0 then r.a[6].l:=self.leerdir_l(dir);
                            if (tempw and $8000)<>0 then r.a[7].l:=self.leerdir_l(dir);
                        end;
                 else MessageDlg('Mierda movem.l $33 '+inttohex(dir,2)+' - '+inttohex(r.pc.l,10), mtInformation,[mbOk], 0);
                end;
              end;
          $39:case dir of
           $0..$f:begin // # trap
                     self.prefetch:=false;
                     self.contador:=self.contador+38;
                     tempw:=coger_band(self.r);
                     self.poner_band(tempw or $2000);
                     r.sp.l:=r.sp.l-6;
                     self.putword(r.sp.l+4,r.pc.wl);
                     self.putword(r.sp.l+2,r.pc.wh);
                     self.putword(r.sp.l,tempw);
                     self.opcode:=false;
                     r.pc.wh:=self.getword($80+((instruccion and $f)*4));
                     r.pc.wl:=self.getword($80+2+((instruccion and $f)*4));
                     self.opcode:=true;
                  end;
         $10..$17:begin // # link
                    self.contador:=self.contador+16;
                    tempw:=self.getword(r.pc.l);
                    r.pc.l:=r.pc.l+2;
                    r.sp.l:=r.sp.l-4;
                    self.putword(r.sp.l,r.a[orig].wh);
                    self.putword(r.sp.l+2,r.a[orig].wl);
                    r.a[orig].l:=r.sp.l;
                    r.sp.l:=r.sp.l+smallint(tempw);
                  end;
          $18..$1f:begin  // # ulnk
                    self.contador:=self.contador+12;
                    r.sp.l:=r.a[orig].l;
                    r.a[orig].wh:=self.getword(r.sp.l);
                    r.a[orig].wl:=self.getword(r.sp.l+2);
                    r.sp.l:=r.sp.l+4;
                  end;
          $20..$2f:begin
                    self.contador:=self.contador+4;
                    if ((instruccion shr 3) and 1)=1 then r.a[orig].l:=r.usp.l // # move fru
                        else r.usp.l:=r.a[orig].l;  // # move tou
                   end;
              $30:begin  // # reset
                    if r.cc.s then begin
                      self.prefetch:=false;
                      self.contador:=self.contador+40;
                    end else MessageDlg('Mierda error de privilegio reset'+inttostr(r.pc.l), mtInformation,[mbOk], 0);
                  end;
              $31:self.contador:=self.contador+4; // # nop
              $32:begin // # stop
                    self.poner_band(self.getword(r.pc.l));
                    r.pc.l:=r.pc.l+2;
                    self.contador:=self.contador+4;
                    self.halt:=true;
                    if (r.cc.t) then MessageDlg('Mierda: STOP con trap!!'+inttostr(r.pc.l), mtInformation,[mbOk], 0);
                  end;
              $33:begin  // # rte
                    if r.cc.s then begin
                      self.prefetch:=false;
                      self.contador:=self.contador+20;
                      tempw:=self.getword(r.sp.l);
                      r.pc.wh:=self.getword(r.sp.l+2);
                      r.pc.wl:=self.getword(r.sp.l+4);
                      r.sp.l:=r.sp.l+6;
                      self.poner_band(tempw);
                    end else MessageDlg('Mierda error de privilegio rte'+inttostr(r.pc.l), mtInformation,[mbOk], 0);
                  end;
              $35:begin // # rts
                    self.prefetch:=false;
                    self.contador:=self.contador+16;
                    r.pc.wh:=self.getword(r.sp.l);
                    r.pc.wl:=self.getword(r.sp.l+2);
                    r.sp.l:=r.sp.l+4;
                  end;
              $37:begin // # rtr
                    self.prefetch:=false;
                    self.contador:=self.contador+20;
                    self.poner_band(self.getword(r.sp.l));
                    r.pc.wh:=self.getword(r.sp.l+2);
                    r.pc.wl:=self.getword(r.sp.l+4);
                    r.sp.l:=r.sp.l+6;
                  end
                else MessageDlg('Instruccion $4b - $39 desconocida - '+inttohex(instruccion and $3f,2)+' - '+inttohex(r.pc.l,10), mtInformation,[mbOk], 0);
              end;
          $3a:begin // # jsr
                self.prefetch:=false;
                templ:=self.leerdir_ea(dir);
                r.sp.l:=r.sp.l-4;
                self.putword(r.sp.l,r.pc.wh);
                self.putword(r.sp.l+2,r.pc.wl);
                r.pc.l:=templ;
                case dir of
                  $10..$17:self.contador:=self.contador+16;  //(An)
                  $28..$2f,$38,$3a:self.contador:=self.contador+18; //d(An) xxx.W d(PC)
                  $30..$37,$3b:self.contador:=self.contador+22; //d(An,ix) d(PC,ix)
                  $39:self.contador:=self.contador+20; //xxx.L
                end
              end;
          $3b:begin // # jmp
                self.prefetch:=false;
                r.pc.l:=self.leerdir_ea(dir);
                case dir of
                  $10..$17:self.contador:=self.contador+8;  //(An)
                  $28..$2f,$38,$3a:self.contador:=self.contador+10; //d(An) xxx.W d(PC)
                  $30..$37,$3b:self.contador:=self.contador+14; //d(An,ix) d(PC,ix)
                  $39:self.contador:=self.contador+12; //xxx.L
                end
              end;
          else MessageDlg('Instruccion $4: '+inttohex((instruccion shr 6) and $3f,2)+' - '+inttohex(r.ppc.l,10), mtInformation,[mbOk], 0);
      end;
   $5:case ((instruccion shr 6) and $7) of
          $0:begin  // # addq.b
                if (dir shr 3)<>0 then self.contador:=self.contador+8+calc_ea_t_bw(dir)
                    else self.contador:=self.contador+4;
                tempb:=((dest-1) and $7)+1;
                tempb2:=self.leerdir_b(dir);
                tempw:=tempb+tempb2;
                self.ponerdir_b2(dir,(tempw and $ff));
                r.cc.n:=(tempw and $80)<>0;
    	          r.cc.z:=((tempw and $ff)=0);
                r.cc.c:=(tempw and $100)<>0;
                r.cc.x:=r.cc.c;
                r.cc.v:=(((tempb xor tempw) and (tempb2 xor tempw)) and $80)<>0;
             end;
          $1:begin  // # addq.w
                tempb:=((dest-1) and $7)+1;
                if (dir shr 3)<>0 then self.contador:=self.contador+8+calc_ea_t_bw(dir)
                  else self.contador:=self.contador+4;
                if (dir shr 3)<>1 then begin
                  tempw:=self.leerdir_w(dir);
                  templ:=tempw+tempb;
                  self.ponerdir_w2(dir,(templ and $ffff));
                  r.cc.n:=(templ and $8000)<>0;
    	            r.cc.z:=((templ and $ffff)=0);
                  r.cc.c:=(templ and $10000)<>0;
                  r.cc.x:=r.cc.c;
                  r.cc.v:=((((tempb xor templ) and (tempw xor templ)) shr 8) and $80)<>0;
                end else begin
                  r.a[orig].l:=r.a[orig].l+tempb;
                end;
             end;
          $2:begin // # addq.l
                tempb:=((dest-1) and $7)+1;
                if (dir shr 3)<>0 then self.contador:=self.contador+12+calc_ea_t_l(dir)
                  else self.contador:=self.contador+8;
                if (dir shr 3)<>1 then begin
                  templ:=self.leerdir_l(dir);
                  templ2:=templ+tempb;
                  self.ponerdir_l2(dir,templ2);
                  r.cc.n:=((templ shr 24) and $80)<>0;
    	            r.cc.z:=(templ=0);
                  r.cc.c:=((((tempb and templ2) or (not(templ) and (tempb or templ2))) shr 23) and $100)<>0;
                  r.cc.x:=r.cc.c;
                  r.cc.v:=((((tempb xor templ2) and (templ xor templ2)) shr 24) and $80)<>0;
                end else begin
                  r.a[orig].l:=r.a[orig].l+tempb;
                end;
             end;
          $3,$7:if ((dir shr 3) and $7)=1 then begin // # dbcc, dbt y dbf
                      self.contador:=self.contador+12;
                      self.prefetch:=false;
                      if not(condicion(self.r,(instruccion shr 8) and $f)) then begin
                          r.d[orig].wl:=r.d[orig].wl-1;
                          if r.d[orig].wl<>$FFFF then begin
                              self.contador:=self.contador-2;
                              tempw:=self.getword(r.pc.l);
                              r.pc.l:=r.pc.l+smallint(tempw);
                          end else r.pc.l:=r.pc.l+2;
                      end else r.pc.l:=r.pc.l+2;
                end else begin // # scc, st y sf
                    if (dir shr 3)<>0 then self.contador:=self.contador+8+calc_ea_t_bw(dir)
                        else self.contador:=self.contador+4;
                    if condicion(self.r,(instruccion shr 8) and $f) then self.ponerdir_b(dir,$ff)
                        else self.ponerdir_b(dir,0);
             end;
          $4:begin  // # subq.b
                tempb:=((dest-1) and $7)+1;
                if (dir and $7)<>0 then self.contador:=self.contador+8+calc_ea_t_bw(dir)
                    else self.contador:=self.contador+4;
                if (dir shr 3)<>1 then begin
                  tempb2:=self.leerdir_b(dir);
                  tempw:=tempb2-tempb;
                  self.ponerdir_b2(dir,(tempw and $ff));
                  r.cc.n:=(tempw and $80)<>0;
                  r.cc.z:=((tempw and $ff)=0);
                  r.cc.c:=(tempw and $100)<>0;
                  r.cc.x:=r.cc.c;
                  r.cc.v:=(((tempb xor tempb2) and (tempw xor tempb2)) and $80)<>0;
                end else begin
                  MessageDlg('subq.b: '+inttohex(dir,2)+' - '+inttohex(r.ppc.l,10), mtInformation,[mbOk], 0);
                end;
             end;
          $5:begin  // # subq.w
                tempb:=((dest-1) and $7)+1;
                if (dir and $7)<>0 then self.contador:=self.contador+8+calc_ea_t_bw(dir)
                    else self.contador:=self.contador+4;
                if (dir shr 3)<>1 then begin
                    tempw:=self.leerdir_w(dir);
                    templ:=tempw-tempb;
                    self.ponerdir_w2(dir,(templ and $ffff));
                    r.cc.n:=(templ and $8000)<>0;
                    r.cc.z:=((templ and $ffff)=0);
                    r.cc.c:=(templ and $10000)<>0;
                    r.cc.x:=r.cc.c;
                    r.cc.v:=((((tempb xor tempw) and (templ xor tempw)) shr 8) and $80)<>0;
                end else begin
                    r.a[orig].l:=r.a[orig].l-tempb;
                end;
             end;
          $6:begin  // # subq.l
                tempb:=((dest-1) and $7)+1;
                if (dir shr 3)<>0 then self.contador:=self.contador+12+calc_ea_t_l(dir)
                  else self.contador:=self.contador+8;
                if (dir shr 3)<>1 then begin
                  templ2:=self.leerdir_l(dir);
                  templ:=templ2-tempb;
                  self.ponerdir_l2(dir,templ);
                  r.cc.n:=((templ shr 24) and $80)<>0;
                  r.cc.z:=(templ=0);
                  r.cc.v:=((((tempb xor templ2) and (templ xor templ2)) shr 24) and $80)<>0;
                  r.cc.c:=((((tempb and templ) or (not(templ2) and (tempb or templ))) shr 23) and $100)<>0;
                  r.cc.x:=r.cc.c;
                end else begin
                  r.a[orig].l:=r.a[orig].l-tempb;
                end;
             end;
      end; //del case $5
   $6:case (instruccion shr 8) and $f of
          0:begin  // # BRA
              self.contador:=self.contador+10;
              tempb:=instruccion and $FF;
              self.prefetch:=false;
              case tempb of
                $00:begin //desplazamiento 16bits
                      tempw:=self.getword(r.pc.l);
                      r.pc.l:=r.pc.l+smallint(tempw);
                    end;
                $ff:begin  //desplazamiento 32bits
                      MessageDlg('Mierda! BRA de 32bits '+inttostr(r.pc.l), mtInformation,[mbOk], 0);
                   end;
                else begin //desplazamiento 8bits
                     r.pc.l:=r.pc.l+shortint(tempb);
                end;
              end;
            end;
          1:begin  // # BSR
              tempb:=instruccion and $FF;
              self.contador:=self.contador+18;
              self.prefetch:=false;
              case tempb of
                $00:begin //desplazamiento 16bits
                       tempw:=self.getword(r.pc.l);
                       r.sp.l:=r.sp.l-4;
                       self.putword(r.sp.l,(r.pc.l+2) shr 16);
                       self.putword(r.sp.l+2,(r.pc.l+2) and $FFFF);
                       r.pc.l:=r.pc.l+smallint(tempw);
                    end;
                $ff:begin  //desplazamiento 32bits
                        MessageDlg('Mierda! BSR de 32bits '+inttostr(r.pc.l), mtInformation,[mbOk], 0);
                    end;
                else begin //desplazamiento 8bits
                        r.sp.l:=r.sp.l-4;
                        self.putword(r.sp.l,r.pc.l shr 16);
                        self.putword(r.sp.l+2,r.pc.l and $FFFF);
                        r.pc.l:=r.pc.l+shortint(tempb);
                    end;
              end;
            end
          else if condicion(self.r,(instruccion shr 8) and $f) then begin  // # Bcc
                self.contador:=self.contador+10;
                tempb:=(instruccion and $ff);
                self.prefetch:=false;
                case tempb of
                  $00:begin //desplazamiento de 16bits
                        tempw:=self.getword(r.pc.l);
                        r.pc.l:=r.pc.l+smallint(tempw);
                      end;
                  $ff:begin
                        MessageDlg('Mierda! BCC de 32bits '+inttostr(r.ppc.l), mtInformation,[mbOk], 0);
                      end;
                    else begin  //desplazamiento de 8bits
                            r.pc.l:=r.pc.l+shortint(tempb);
                         end;
                  end;
          end else begin //sino hace el salto comprobar si hay 16bits de desplazamiento
              self.contador:=self.contador+8;
              tempb:=(instruccion and $ff);
              case tempb of
                $00:r.pc.l:=r.pc.l+2;
                $ff:;//ILEGAL!!
              end;
          end;
      end;
   $7:begin // # moveq
        self.contador:=self.contador+4;
        r.d[dest].l:=shortint(instruccion and $ff);
        r.cc.c:=false;
        r.cc.v:=false;
        r.cc.z:=(r.d[dest].l=0);
        r.cc.n:=((r.d[dest].l shr 24) and $80)<>0;
      end;
   $8:case ((instruccion shr 6) and $7) of
        $0:begin // # or.b er
              if (dir shr 3)<>0 then self.contador:=self.contador+8+calc_ea_t_bw(dir)
                  else self.contador:=self.contador+4+calc_ea_t_bw(dir);
              tempb:=self.leerdir_b(dir);
              tempb2:=r.d[dest].l0 or tempb;
              r.d[dest].l0:=tempb2;
              r.cc.n:=(tempb2 and $80)<>0;
              r.cc.z:=(tempb2=0);
              r.cc.c:=false;
              r.cc.v:=false;
           end;
        $1:begin  // # or.w er
              if (dir shr 3)<>0 then self.contador:=self.contador+8+calc_ea_t_bw(dir)
                  else self.contador:=self.contador+4+calc_ea_t_bw(dir);
              tempw:=self.leerdir_w(dir);
              tempw2:=r.d[dest].wl or tempw;
              r.d[dest].wl:=tempw2;
              r.cc.n:=(tempw2 and $8000)<>0;
              r.cc.z:=(tempw2=0);
              r.cc.c:=false;
              r.cc.v:=false;
           end;
        $2:begin  // # or.l er
              if (dir shr 3)<>0 then self.contador:=self.contador+12+calc_ea_t_l(dir)
                  else self.contador:=self.contador+6+calc_ea_t_l(dir);
              templ:=self.leerdir_l(dir);
              templ2:=r.d[dest].l or templ;
              r.d[dest].l:=templ2;
              r.cc.n:=((templ2 shr 24) and $80)<>0;
              r.cc.z:=(templ2=0);
              r.cc.c:=false;
              r.cc.v:=false;
           end;
        $3:begin  // # divu
              self.contador:=self.contador+140+calc_ea_t_bw(dir);
              tempw:=self.leerdir_w(dir);
              if tempw<>0 then begin
                  templ:=r.d[dest].l div tempw;
                  if(templ<$10000) then begin
              			r.cc.z:=(templ<>0);
                    r.cc.n:=(templ and $8000)<>0;
              			r.cc.v:=false;
              			r.cc.c:=false;
                    templ2:=r.d[dest].l mod tempw;
                    templ3:=(templ and $ffff) or ((templ2 and $ffff) shl 16);
                    r.d[dest].l:=templ3;
                  end else begin
                    r.cc.v:=true;
                  end;
              end else begin
                  MessageDlg('Mierda! Division por 0'+inttostr(r.pc.l), mtInformation,[mbOk], 0);
              end;
           end;
        $4:case ((dir shr 3) and $7) of
                 $0:begin  // # sbcd rr
                       self.contador:=self.contador+6;
                       tempb:=r.d[dest].l0;
                       tempb2:=r.d[orig].l0;
                       tempw:=(tempb and $f)-(tempb2 and $f)-byte(r.cc.x);
                       r.cc.v:=false;
                       if tempw>9 then tempw:=tempw-6;
                       tempw:=tempw+(tempb and $f0)-(tempb2 and $f0);
                       if (tempw>$99) then begin
                         tempw:=tempw+$a0;
                         r.cc.x:=true;
                         r.cc.c:=true;
                         r.cc.n:=true;
                       end else begin
                         r.cc.n:=false;
                         r.cc.x:=false;
                         r.cc.c:=false;
                       end;
                       r.cc.z:=(tempw and $ff)=0;
                       r.d[dest].l0:=tempw and $ff;
                    end;
                 $1:begin  // # sbcd mm
                      self.contador:=self.contador+18;
                      case (instruccion and $fff) of
                        $10f,$30f,$50f,$70f,$90f,$b0f,$d0f:begin
                               MessageDlg('Instruccion sbcd ay7 '+inttostr(r.pc.l), mtInformation,[mbOk], 0);
                             end;
                        $f04..$f0e:begin
                               MessageDlg('Instruccion sbcd ax7 '+inttostr(r.pc.l), mtInformation,[mbOk], 0);
                             end;
                        $f0f:begin
                               MessageDlg('Instruccion sbcd axy7 '+inttostr(r.pc.l), mtInformation,[mbOk], 0);
                             end;
                        else begin
                          self.opcode:=false;
                          r.a[orig].l:=r.a[orig].l-1;
                          tempb2:=self.getbyte(r.a[orig].l);
                          r.a[dest].l:=r.a[dest].l-1;
                          tempb:=self.getbyte(r.a[dest].l);
                          tempw:=(tempb and $f)-(tempb2 and $f)-byte(r.cc.x);
                          r.cc.v:=false;
                          if tempw>9 then tempw:=tempw-6;
                          tempw:=tempw+(tempb and $f0)-(tempb2 and $f0);
                          if (tempw>$99) then begin
                             tempw:=tempw+$a0;
                             r.cc.x:=true;
                             r.cc.c:=true;
                             r.cc.n:=true;
                          end else begin
                             r.cc.n:=false;
                             r.cc.x:=false;
                             r.cc.c:=false;
                          end;
                          r.cc.z:=(tempw and $ff)=0;
                          self.putbyte(r.a[dest].l,tempw and $ff);
                          self.opcode:=true;
                        end;
                      end;
                    end;
                 else begin  // # or.b re
                    if (dir shr 3)<>0 then self.contador:=self.contador+8+calc_ea_t_bw(dir)
                        else self.contador:=self.contador+4+calc_ea_t_bw(dir);
                    tempb:=r.d[dest].l0;
                    tempb2:=self.leerdir_b(dir) or tempb;
                    self.ponerdir_b2(dir,tempb2);
                    r.cc.n:=(tempb2 and $80)<>0;
                    r.cc.z:=(tempb2=0);
                    r.cc.c:=false;
                    r.cc.v:=false;
                 end;
           end;
        $5:begin // # or.w re
              if (dir shr 3)<>0 then self.contador:=self.contador+8+calc_ea_t_bw(dir)
                  else self.contador:=self.contador+4+calc_ea_t_bw(dir);
              tempw:=r.d[dest].wl;
              tempw2:=self.leerdir_w(dir) or tempw;
              self.ponerdir_w2(dir,tempw2);
              r.cc.n:=(tempw2 and $8000)<>0;
              r.cc.z:=(tempw2=0);
              r.cc.c:=false;
              r.cc.v:=false;
           end;
        $6:begin // # or.l re
              if (dir shr 3)<>0 then self.contador:=self.contador+12+calc_ea_t_l(dir)
                  else self.contador:=self.contador+8+calc_ea_t_l(dir);
              templ:=r.d[dest].l;
              templ2:=self.leerdir_l(dir) or templ;
              self.ponerdir_l2(dir,templ2);
              r.cc.n:=((templ2 shr 24) and $80)<>0;
              r.cc.z:=(templ2=0);
              r.cc.c:=false;
              r.cc.v:=false;
           end;
        $7:begin  // # divs
              self.contador:=self.contador+158+calc_ea_t_bw(dir);
              divisor:=smallint(self.leerdir_w(dir));
              if divisor<>0 then begin
                  templ:=r.d[dest].l;
                  if ((templ=$80000000) and (divisor=-1)) then begin
              			r.cc.z:=true;
              			r.cc.n:=false;
              			r.cc.v:=false;
                    r.cc.c:=false;
              			r.d[dest].l:=0;
                  end else begin
  		              quotient:=integer(templ) div divisor;
	  	              remainder:=integer(templ) mod divisor;
		                if (quotient=smallint(quotient)) then begin
                      r.cc.z:=(quotient<>0);
                      r.cc.n:=(quotient and $8000)<>0;
                      r.cc.v:=false;
                      r.cc.c:=false;
                			r.d[dest].l:=((quotient and $ffff) or (remainder shl 16)) and $ffffffff;
		                end else r.cc.v:=true;
                  end;
              end else begin
                  MessageDlg('Mierda! Division por 0'+inttostr(r.pc.l), mtInformation,[mbOk], 0);
              end;
           end;
      end;  //del case $8
    $9:case ((instruccion shr 6) and $7) of
        $0:begin  // # sub.b er
              self.contador:=self.contador+8+calc_ea_t_bw(dir);
              tempb:=self.leerdir_b(dir);
              tempb2:=r.d[dest].l0;
              tempw:=tempb2-tempb;
              r.d[dest].l0:=tempw and $ff;
              r.cc.n:=(tempw and $80)<>0;
              r.cc.c:=(tempw and $100)<>0;
              r.cc.x:=r.cc.c;
              r.cc.v:=(((tempb xor tempb2) and (tempw xor tempb2)) and $80)<>0;
              r.cc.z:=(tempw and $ff)=0;
           end;
        $1:begin  // # sub.w er
              self.contador:=self.contador+8+calc_ea_t_bw(dir);
              tempw:=self.leerdir_w(dir);
              tempw2:=r.d[dest].wl;
              templ:=tempw2-tempw;
              r.d[dest].wl:=templ and $ffff;
              r.cc.n:=(templ and $8000)<>0;
              r.cc.c:=(templ and $10000)<>0;
              r.cc.x:=r.cc.c;
              r.cc.v:=((((tempw xor tempw2) and (templ xor tempw2)) shr 8) and $80)<>0;
              r.cc.z:=(templ and $ffff)=0;
           end;
        $2:begin  // # sub.l er
              self.contador:=self.contador+12+calc_ea_t_l(dir);
              templ:=self.leerdir_l(dir);
              templ2:=r.d[dest].l;
              templ3:=templ2-templ;
              r.d[dest].l:=templ3;
              r.cc.n:=((templ3 shr 24) and $80)<>0;
              r.cc.z:=(templ3=0);
              r.cc.v:=((((templ xor templ2) and (templ3 xor templ2)) shr 24) and $80)<>0;
              r.cc.c:=((((templ and templ3) or (not(templ2) and (templ or templ3))) shr 23) and $100)<>0;
           end;
        $3:begin // # suba.w
              self.contador:=self.contador+8+calc_ea_t_bw(dir);
              tempw:=self.leerdir_w(dir);
              r.a[dest].l:=r.a[dest].l-smallint(tempw);
           end;
        $4:case ((instruccion shr 3) and $7) of
              $0:begin  // # subx.b rr
                     self.contador:=self.contador+4;
                     tempb:=r.d[orig].l0;
                     tempb2:=r.d[dest].l0;
                     tempw:=tempb2-tempb-byte(r.cc.x);
                     r.d[dest].l0:=tempw and $ff;
                     r.cc.n:=(tempw and $80)<>0;
                     r.cc.c:=(tempw and $100)<>0;
                     r.cc.x:=r.cc.c;
                     r.cc.v:=(((tempb xor tempb2) and (tempw xor tempb2)) and $80)<>0;
                     r.cc.z:=(tempw and $ff)=0;
                 end;
              $1:begin  // # subx.b mm
                     self.contador:=self.contador+18;
                     MessageDlg('Instruccion subx.b mm '+inttostr(r.pc.l), mtInformation,[mbOk], 0);
                 end;
              else begin // # sub.b re
                   self.contador:=self.contador+4+calc_ea_t_bw(dir);
                   tempb:=r.d[dest].l0;
                   tempb2:=self.leerdir_b(dir);
                   tempw:=tempb2-tempb;
                   self.ponerdir_b2(dir,tempw and $ff);
                   r.cc.n:=(tempw and $80)<>0;
                   r.cc.c:=(tempw and $100)<>0;
                   r.cc.x:=r.cc.c;
                   r.cc.v:=(((tempb xor tempb2) and (tempw xor tempb2)) and $80)<>0;
                   r.cc.z:=(tempw and $ff)=0;
              end;
           end;
        $5:case ((instruccion shr 3) and $7) of
                 $0:begin  // # subx.w rr
                     tempw:=r.d[orig].wl;
                     tempw2:=r.d[dest].wl;
                     templ:=tempw2-tempw-byte(r.cc.x);
                     r.cc.n:=(templ and $8000)<>0;
                     r.cc.c:=(templ and $10000)<>0;
                     r.cc.x:=r.cc.c;
                     r.cc.v:=((((tempw xor tempw2) and (templ xor tempw2)) shr 8) and $80)<>0;
                     r.cc.z:=(templ and $ffff)=0;
                     r.d[dest].wl:=templ and $ffff;
                     self.contador:=self.contador+4;
                    end;
                 $1:begin  // # subx.w mm
                      MessageDlg('Instruccion subx.w mm '+inttohex(r.pc.l,10), mtInformation,[mbOk], 0);
                      self.contador:=self.contador+18;
                    end;
                 else begin // # sub.w re
                    self.contador:=self.contador+4+calc_ea_t_bw(dir);
                    tempw:=r.d[dest].wl;
                    tempw2:=self.leerdir_w(dir);
                    templ:=tempw2-tempw;
                    self.ponerdir_w2(dir,templ and $ffff);
                    r.cc.n:=(templ and $8000)<>0;
                    r.cc.c:=(templ and $10000)<>0;
                    r.cc.x:=r.cc.c;
                    r.cc.v:=((((tempw xor tempw2) and (templ xor tempw2)) shr 8) and $80)<>0;
                    r.cc.z:=(templ and $ffff)=0;
                 end;
           end;
        $6:case ((instruccion shr 3) and $7) of
                 $0:begin  // # subx.l rr
                      self.contador:=self.contador+8;
                      templ:=r.d[orig].l;
                      templ2:=r.d[dest].l;
                      templ3:=templ2-templ-byte(r.cc.x);
                      r.d[dest].l:=templ3;
                      r.cc.n:=((templ3 shr 24) and $80)<>0;
                      r.cc.z:=(templ3=0);
                      r.cc.v:=((((templ xor templ2) and (templ3 xor templ2)) shr 24) and $80)<>0;
                      r.cc.c:=((((templ and templ3) or (not(templ2) and (templ or templ3))) shr 23) and $100)<>0;
                      r.cc.x:=r.cc.c;
                    end;
                 $1:begin  // # subx.l mm
                      MessageDlg('Instruccion subx.l mm '+inttostr(r.pc.l), mtInformation,[mbOk], 0);
                      self.contador:=self.contador+30;
                    end;
                 else begin  //sub.l re
                      self.contador:=self.contador+8+calc_ea_t_l(dir);
                      templ:=r.d[dest].l;
                      templ2:=self.leerdir_l(dir);
                      templ3:=templ2-templ;
                      self.ponerdir_l2(dir,templ3);
                      r.cc.n:=((templ3 shr 24) and $80)<>0;
                      r.cc.z:=(templ3=0);
                      r.cc.v:=((((templ xor templ2) and (templ3 xor templ2)) shr 24) and $80)<>0;
                      r.cc.c:=((((templ and templ3) or (not(templ2) and (templ or templ3))) shr 23) and $100)<>0;
                 end;
           end;
        $7:begin  // # suba.l
              self.contador:=self.contador+6+calc_ea_t_l(dir);
              r.a[dest].l:=r.a[dest].l-self.leerdir_l(dir);
           end;
       end;  //del case $9
   $b:case ((instruccion shr 6) and $7) of
        $0:begin //cmp.b
              self.contador:=self.contador+4;
              tempb:=self.leerdir_b(dir);
              tempb2:=r.d[dest].l0;
              tempw:=tempb2-tempb;
              r.cc.n:=(tempw and $80)<>0;
              r.cc.z:=((tempw and $ff)=0);
              r.cc.v:=(((tempb xor tempb2) and (tempw xor tempb2)) and $80)<>0;
              r.cc.c:=(tempw and $100)<>0;
           end;
        $1:begin  //cmp.w
              self.contador:=self.contador+4;
              tempw:=self.leerdir_w(dir);
              tempw2:=r.d[dest].wl;
              templ:=tempw2-tempw;
              r.cc.n:=(templ and $8000)<>0;
              r.cc.z:=((templ and $ffff)=0);
              r.cc.v:=((((tempw xor tempw2) and (templ xor tempw2)) shr 8) and $80)<>0;
              r.cc.c:=(templ and $10000)<>0;
           end;
        $2:begin //cmp.l
              self.contador:=self.contador+6;
              templ:=self.leerdir_l(dir);
              templ2:=r.d[dest].l;
              templ3:=templ2-templ;
              r.cc.n:=((templ3 shr 24) and $80)<>0;
              r.cc.z:=(templ3=0);
              r.cc.v:=((((templ xor templ2) and (templ3 xor templ2)) shr 24) and $80)<>0;
              r.cc.c:=((((templ and templ3) or (not(templ2) and (templ or templ3))) shr 23) and $100)<>0;
            end;
         $3:begin  //cmpa.w
              self.contador:=self.contador+6;
              templ:=cardinal(smallint(self.leerdir_w(dir)));
              templ2:=r.a[dest].l;
              templ3:=templ2-templ;
              r.cc.n:=((templ3 shr 24) and $80)<>0;
	            r.cc.z:=(templ3=0);
  	          r.cc.v:=((((templ xor templ2) and (templ3 xor templ2)) shr 24) and $80)<>0;
	            r.cc.c:=((((templ and templ3) or (not(templ2) and (templ or templ3))) shr 23) and $100)<>0;
            end;
         $4:if ((instruccion shr 3) and $7)=1 then begin
                self.contador:=self.contador+12;
                case (instruccion and $fff) of
                  $10f,$30f,$50f,$70f,$90f,$b0f,$d0f:begin
                      MessageDlg('Instruccion cmpm.b ay7 '+inttostr(r.pc.l), mtInformation,[mbOk], 0);
                    end;
                  $f04..$f0e:begin
                      MessageDlg('Instruccion cmpm.b ax7 '+inttostr(r.pc.l), mtInformation,[mbOk], 0);
                    end;
                  $f0f:begin
                      MessageDlg('Instruccion cmpm.b axy7 '+inttostr(r.pc.l), mtInformation,[mbOk], 0);
                    end;
                  else begin //cmpm.b
                      tempb:=self.getbyte(r.a[orig].l);
                      r.a[orig].l:=r.a[orig].l+1;
                      tempb2:=self.getbyte(r.a[dest].l);
                      r.a[dest].l:=r.a[dest].l+1;
                      tempw:=tempb2-tempb;
                      r.cc.n:=(tempw and $80)<>0;
                      r.cc.z:=((tempw and $ff)=0);
                      r.cc.v:=(((tempb xor tempb2) and (tempw xor tempb2)) and $80)<>0;
                      r.cc.c:=(tempw and $100)<>0;
                  end;
                end;
            end else begin //eor.b
                if (dir shr 3)<>0 then self.contador:=self.contador+8
                  else self.contador:=self.contador+4;
                tempb:=self.leerdir_b(dir);
                tempb2:=tempb xor r.d[dest].l0;
                self.ponerdir_b2(dir,tempb2);
                r.cc.n:=(tempb2 and $80)<>0;
                r.cc.z:=(tempb2=0);
                r.cc.v:=false;
                r.cc.c:=false;
            end;
         $5:begin
              if ((instruccion shr 3) and $7)=1 then begin //cmpm.w
                self.contador:=self.contador+12;
                tempw:=self.getword(r.a[orig].l);
                r.a[orig].l:=r.a[orig].l+2;
                tempw2:=self.getword(r.a[dest].l);
                r.a[dest].l:=r.a[dest].l+2;
                templ:=tempw2-tempw;
                r.cc.n:=(templ and $8000)<>0;
                r.cc.z:=((templ and $ffff)=0);
                r.cc.v:=((((tempw xor tempw2) and (templ xor tempw2)) shr 8) and $80)<>0;
                r.cc.c:=(templ and $10000)<>0;
              end else begin //eor.w
                if (dir shr 3)<>0 then self.contador:=self.contador+8
                  else self.contador:=self.contador+4;
                tempw:=self.leerdir_w(dir);
                tempw2:=tempw xor r.d[dest].wl;
                self.ponerdir_w2(dir,tempw2);
                r.cc.n:=(tempw2 and $8000)<>0;
                r.cc.z:=(tempw2=0);
                r.cc.v:=false;
                r.cc.c:=false;
              end;
            end;
         $6:begin
              if ((instruccion shr 3) and $7)=1 then begin //cmpm.l
                self.contador:=self.contador+20;
                templ:=self.getword(r.a[orig].l) shl 16;
                templ:=templ or self.getword(r.a[orig].l+2);
                r.a[orig].l:=r.a[orig].l+4;
                templ2:=self.getword(r.a[dest].l) shl 16;
                templ2:=templ2 or self.getword(r.a[dest].l+2);
                r.a[dest].l:=r.a[dest].l+4;
                templ3:=templ2-templ;
                r.cc.n:=((templ3 shr 24) and $80)<>0;
	              r.cc.z:=(templ3=0);
	              r.cc.v:=((((templ xor templ2) and (templ3 xor templ2)) shr 24) and $80)<>0;
	              r.cc.c:=((((templ and templ3) or (not(templ2) and (templ or templ3))) shr 23) and $100)<>0;
              end else begin  //eor.l
                if (dir shr 3)<>0 then self.contador:=self.contador+12
                  else self.contador:=self.contador+8;
                templ:=self.leerdir_l(dir);
                templ2:=templ xor r.d[dest].l;
                self.ponerdir_l2(dir,templ2);
                r.cc.n:=((templ2 shr 24) and $80)<>0;
                r.cc.z:=(templ2=0);
                r.cc.v:=false;
                r.cc.c:=false;
              end;
            end;
         $7:begin //cmpa.l
              self.contador:=self.contador+6;
              templ:=self.leerdir_l(dir);
              templ2:=r.a[dest].l;
              templ3:=templ2-templ;
              r.cc.n:=((templ3 shr 24) and $80)<>0;
	            r.cc.z:=(templ3=0);
	            r.cc.v:=((((templ xor templ2) and (templ3 xor templ2)) shr 24) and $80)<>0;
	            r.cc.c:=((((templ and templ3) or (not(templ2) and (templ or templ3))) shr 23) and $100)<>0;
            end;
       end;  //del case principal $b
   $c:case ((instruccion shr 6) and $7) of
            $0:begin  //and.b re
                 self.contador:=self.contador+4;
                 tempb:=self.leerdir_b(dir);
                 tempb2:=r.d[dest].l0 and tempb;
                 r.d[dest].l0:=tempb2;
                 r.cc.n:=(tempb2 and $80)<>0;
                 r.cc.z:=(tempb2=0);
                 r.cc.c:=false;
                 r.cc.v:=false;
               end;
            $1:begin  //and.w re
                 self.contador:=self.contador+4;
                 tempw:=self.leerdir_w(dir);
                 tempw2:=r.d[dest].wl and tempw;
                 r.d[dest].wl:=tempw2;
                 r.cc.n:=(tempw2 and $8000)<>0;
                 r.cc.z:=(tempw2=0);
                 r.cc.c:=false;
                 r.cc.v:=false;
               end;
            $2:begin  //and.l re
                 self.contador:=self.contador+6;
                 templ:=self.leerdir_l(dir);
                 templ2:=r.d[dest].l and templ;
                 r.d[dest].l:=templ2;
                 r.cc.n:=((templ2 shr 24) and $80)<>0;
                 r.cc.z:=(templ2=0);
                 r.cc.c:=false;
                 r.cc.v:=false;
               end;
            $3:begin //mulu
                 self.contador:=self.contador+54;
                 tempw:=self.leerdir_w(dir);
                 tempw2:=r.d[dest].wl;
                 templ:=tempw*tempw2;
                 r.d[dest].l:=templ;
                 r.cc.z:=(templ=0);
                 r.cc.n:=((templ shr 24) and $80)<>0;
                 r.cc.v:=false;
                 r.cc.c:=false;
               end;
            $4:case ((dir shr 3) and $7) of
                 $0:begin  //abcd rr
                      self.contador:=self.contador+6;
                      tempb:=r.d[orig].l0;
                      tempb2:=r.d[dest].l0;
                      tempw:=(tempb and $f)+(tempb2 and $f)+byte(r.cc.x);
                      r.cc.v:=((not(tempw) and $80)<>0);
                      if (tempw>9) then tempw:=tempw+6;
                      tempw:=tempw+(tempb and $f0)+(tempb2 and $f0);
                      r.cc.c:=tempw>$99;
                      r.cc.x:=r.cc.c;
                    	if r.cc.c then tempw:=tempw-$a0;
                      r.cc.v:=r.cc.v and ((tempw and $80)<>0);
             	        r.cc.n:=(tempw and $80)<>0;
                      r.cc.z:=(tempw and $ff)=0;
                      r.d[dest].l0:=tempw and $ff;
                    end;
                 $1:begin  //abcd mm
                      self.contador:=self.contador+18;
                      case (instruccion and $fff) of
                        $10f,$30f,$50f,$70f,$90f,$b0f,$d0f:begin
                               MessageDlg('Instruccion abcd ay7 '+inttostr(r.pc.l), mtInformation,[mbOk], 0);
                             end;
                        $f04..$f0e:begin
                               MessageDlg('Instruccion abcd ax7 '+inttostr(r.pc.l), mtInformation,[mbOk], 0);
                             end;
                        $f0f:begin
                               MessageDlg('Instruccion abcd axy7 '+inttostr(r.pc.l), mtInformation,[mbOk], 0);
                             end;
                        else begin
                               self.opcode:=false;
                               r.a[orig].l:=r.a[orig].l-1;
                               tempb:=self.getbyte(r.a[orig].l);
                               r.a[dest].l:=r.a[dest].l-1;
                               tempb2:=self.getbyte(r.a[dest].l);
                               tempw:=(tempb and $f)+(tempb2 and $f)+byte(r.cc.x);
                               r.cc.v:=(not(tempw) and $80)<>0;
                               if (tempw>9) then tempw:=tempw+6;
       	                       tempw:=(tempw and $ff)+(tempb and $f0)+(tempb2 and $f0);
                               r.cc.c:=tempw>$99;
                               r.cc.x:=r.cc.c;
                             	 if r.cc.c then tempw:=tempw-$a0;
                               r.cc.v:=r.cc.v and ((tempw and $80)<>0);
            	                 r.cc.n:=(tempw and $80)<>0;
                               r.cc.z:=(tempw and $ff)=0;
                               self.putbyte(r.a[dest].l,tempw and $ff);
                               self.opcode:=true;
                        end;
                      end;
                    end;
                 else begin  //and.b re
                      self.contador:=self.contador+8;
                      tempb:=r.d[dest].l0;
                      tempb2:=self.leerdir_b(dir) and tempb;
                      self.ponerdir_b2(dir,tempb2);
                      r.cc.n:=(tempb2 and $80)<>0;
                    	r.cc.z:=(tempb2=0);
                    	r.cc.c:=false;
                    	r.cc.v:=false;
                 end;
               end;
            $5:case ((dir shr 3) and $7) of
                 $0:begin //exg dd
                      self.contador:=self.contador+6;
                      templ:=r.d[dest].l;
                      r.d[dest].l:=r.d[orig].l;
                      r.d[orig].l:=templ;
                    end;
                 $1:begin //exg aa
                      self.contador:=self.contador+6;
                      templ:=r.a[dest].l;
                      r.a[dest].l:=r.a[orig].l;
                      r.a[orig].l:=templ;
                    end;
                 else begin //and.w re
                      self.contador:=self.contador+8;
                      tempw:=r.d[dest].wl;
                      tempw2:=self.leerdir_w(dir) and tempw;
                      self.ponerdir_w2(dir,tempw2);
                      r.cc.n:=(tempw2 and $8000)<>0;
                      r.cc.z:=(tempw2=0);
                      r.cc.c:=false;
                      r.cc.v:=false;
                 end;
               end;
            $6:if ((dir shr 3) and $7)=1 then begin  //exg da
                 self.contador:=self.contador+6;
                 templ:=r.d[dest].l;
                 r.d[dest].l:=r.a[orig].l;
                 r.a[orig].l:=templ;
               end else begin  //and.l re
                 self.contador:=self.contador+12;
                 templ:=r.d[dest].l;
                 templ2:=self.leerdir_l(dir) and templ;
                 self.ponerdir_l2(dir,templ2);
                 r.cc.n:=((templ2 shr 24) and $80)<>0;
                 r.cc.z:=(templ2=0);
                 r.cc.c:=false;
                 r.cc.v:=false;
               end;
            $7:begin //muls
                 self.contador:=self.contador+54;
                 remainder:=smallint(self.leerdir_w(dir));
                 quotient:=smallint(r.d[dest].wl);
                 templ:=remainder*quotient;
                 r.d[dest].l:=templ;
                 r.cc.z:=(templ=0);
               	 r.cc.n:=((templ shr 24) and $80)<>0;
                 r.cc.v:=false;
                 r.cc.c:=false;
               end;
      end;  //del $c
   $d:case ((instruccion shr 6) and $7) of
            $0:begin  //add.b er
                 self.contador:=self.contador+4;
                 tempb:=self.leerdir_b(dir);
                 tempb2:=r.d[dest].l0;
                 tempw:=tempb+tempb2;
                 r.d[dest].l0:=tempw and $ff;
                 r.cc.n:=(tempw and $80)<>0;
                 r.cc.z:=((tempw and $ff)=0);
	               r.cc.v:=((((tempb xor tempw) and (tempb2 xor tempw))) and $80)<>0;
                 r.cc.c:=(tempw and $100)<>0;
	               r.cc.x:=r.cc.c;
               end;
            $1:begin  //add.w er
                 self.contador:=self.contador+4;
                 tempw:=self.leerdir_w(dir);
                 tempw2:=r.d[dest].wl;
                 templ:=tempw+tempw2;
                 r.d[dest].wl:=templ and $ffff;
                 r.cc.n:=(templ and $8000)<>0;
                 r.cc.c:=(templ and $10000)<>0;
                 r.cc.x:=r.cc.c;
                 r.cc.v:=((((tempw xor templ) and (tempw2 xor templ)) shr 8) and $80)<>0;
                 r.cc.z:=((templ and $ffff)=0);
               end;
            $2:begin  //add.l er
                 self.contador:=self.contador+6;
                 templ:=self.leerdir_l(dir);
                 templ2:=r.d[dest].l;
                 templ3:=templ+templ2;
                 r.d[dest].l:=templ3;
                 r.cc.n:=((templ3 shr 24) and $80)<>0;
                 r.cc.z:=(templ3=0);
	               r.cc.v:=((((templ xor templ3) and (templ2 xor templ3)) shr 24) and $80)<>0;
                 r.cc.c:=((((templ and templ2) or (not(templ3) and (templ or templ2))) shr 23) and $100)<>0;
	               r.cc.x:=r.cc.c;
               end;
            $3:begin  //adda.w
                 self.contador:=self.contador+8;
                 tempw:=self.leerdir_w(dir);
                 r.a[dest].l:=r.a[dest].l+smallint(tempw);
               end;
            $4:case ((dir shr 3) and $7) of
                 $0:begin  //addx.b rr
                      self.contador:=self.contador+4;
                      tempb:=r.d[orig].l0;
                      tempb2:=r.d[dest].l0;
                      tempw:=tempb+tempb2+byte(r.cc.x);
                      r.d[dest].l0:=tempw and $ff;
                      r.cc.n:=(tempw and $80)<>0;
                      r.cc.z:=((tempw and $ff)=0);
	                    r.cc.v:=((((tempb xor tempw) and (tempb2 xor tempw))) and $80)<>0;
                      r.cc.c:=(tempw and $100)<>0;
	                    r.cc.x:=r.cc.c;
                    end;
                 $1:begin  //addx.b mm
                      self.contador:=self.contador+18;
                      case (instruccion and $fff) of
                        $10f,$30f,$50f,$70f,$90f,$b0f,$d0f:begin
                               MessageDlg('Instruccion addx.b ay7 '+inttostr(r.pc.l), mtInformation,[mbOk], 0);
                             end;
                        $f04..$f0e:begin
                               MessageDlg('Instruccion addx.b ax7 '+inttostr(r.pc.l), mtInformation,[mbOk], 0);
                             end;
                        $f0f:begin
                               MessageDlg('Instruccion addx.b axy7 '+inttostr(r.pc.l), mtInformation,[mbOk], 0);
                             end;
                        else begin
                          MessageDlg('Instruccion addx.b'+inttostr(r.pc.l), mtInformation,[mbOk], 0);
                        end;
                      end;
                    end;
                    else begin  //add.b re
                      self.contador:=self.contador+8;
                      tempb:=r.d[dest].l0;
                      tempb2:=self.leerdir_b(dir);
                      tempw:=tempb+tempb2;
                      self.ponerdir_b2(dir,tempw and $ff);
                      r.cc.n:=(tempw and $80)<>0;
                      r.cc.z:=((tempw and $ff)=0);
	                    r.cc.v:=((((tempb xor tempw) and (tempb2 xor tempw))) and $80)<>0;
                      r.cc.c:=(tempw and $100)<>0;
	                    r.cc.x:=r.cc.c;
                 end;
               end;
            $5:case ((instruccion shr 3) and $7) of
                 $0:begin  //addx.w rr
                      self.contador:=self.contador+4;
                      tempw:=r.d[orig].wl;
                      tempw2:=r.d[dest].wl;
                      templ:=tempw+tempw2+byte(r.cc.x);
                      r.d[dest].wl:=templ and $ffff;
                      r.cc.n:=(templ and $8000)<>0;
                      r.cc.z:=((templ and $ffff)=0);
      	              r.cc.v:=((((tempw xor templ) and (tempw2 xor templ))) and $8000)<>0;
                      r.cc.c:=(templ and $10000)<>0;
	                    r.cc.x:=r.cc.c;
                    end;
                 $1:begin  //addx.w mm
                      MessageDlg('Instruccion addx.w mm'+inttostr(r.pc.l), mtInformation,[mbOk], 0);
                    end;
                 else begin  //add.w re
                    self.contador:=self.contador+8;
                    tempw:=r.d[dest].wl;
                    tempw2:=self.leerdir_w(dir);
                    templ:=tempw+tempw2;
                    self.ponerdir_w2(dir,templ and $ffff);
                    r.cc.n:=(templ and $8000)<>0;
                    r.cc.c:=(templ and $10000)<>0;
    	              r.cc.x:=r.cc.c;
                    r.cc.v:=((((tempw xor templ) and (tempw2 xor templ)) shr 8) and $80)<>0;
            	      r.cc.z:=((templ and $ffff)=0);
                 end;
               end;
            $6:case ((instruccion shr 3) and $7) of
                 $0:begin  //addx.l rr
                      self.contador:=self.contador+8;
                      templ:=r.d[orig].l;
                      templ2:=r.d[dest].l;
                      templ3:=templ+templ2+byte(r.cc.x);
                      r.d[dest].l:=templ3;
                      r.cc.n:=((templ3 shr 24) and $80)<>0;
                      r.cc.z:=(templ3=0);
    	                r.cc.v:=((((templ xor templ3) and (templ2 xor templ3)) shr 24) and $80)<>0;
                      r.cc.c:=((((templ and templ2) or (not(templ3) and (templ or templ2))) shr 23) and $100)<>0;
	                    r.cc.x:=r.cc.c;
                    end;
                 $1:begin  //addx.l mm
                      MessageDlg('Instruccion addx.l mm'+inttostr(r.pc.l), mtInformation,[mbOk], 0);
                    end;
                 else begin  //add.l re
                    self.contador:=self.contador+12;
                    templ:=r.d[dest].l;
                    templ2:=self.leerdir_l(dir);
                    templ3:=templ+templ2;
                    self.ponerdir_l2(dir,templ3);
                    r.cc.n:=((templ3 shr 24) and $80)<>0;
                    r.cc.z:=(templ3=0);
    	              r.cc.v:=((((templ xor templ3) and (templ2 xor templ3)) shr 24) and $80)<>0;
                    r.cc.c:=((((templ and templ2) or (not(templ3) and (templ or templ2))) shr 23) and $100)<>0;
	                  r.cc.x:=r.cc.c;
                 end;
               end;
            $7:begin
                 self.contador:=self.contador+6;
                 r.a[dest].l:=r.a[dest].l+self.leerdir_l(dir);
               end;
      end;  //del case $d
   $e:if (instruccion shr 6) and $3=$3 then begin
        case (instruccion shr 8) and $f of
               $0:begin //asr.w
                    self.contador:=self.contador+8;
                    tempw:=self.leerdir_w(dir);
                    r.cc.c:=(tempw and $1)<>0;
                    if (tempw and $8000)<>0 then tempw:=(tempw shr 1) or $8000
                      else tempw:=tempw shr 1;
                    self.ponerdir_w2(dir,tempw);
                    r.cc.n:=(tempw and $8000)<>0;
                    r.cc.v:=false;
                    r.cc.z:=(tempw=0);
                    r.cc.x:=r.cc.c;
                  end;
               $1:begin  //asl.w añadida 14/09/2014
                    self.contador:=self.contador+8;
                    tempw:=self.leerdir_w(dir); //src
                    tempw2:=tempw shl 1;
                    self.ponerdir_w2(dir,tempw2); //res
                    r.cc.n:=(tempw2 and $8000)<>0;
                    r.cc.z:=(tempw2=0);
                    r.cc.c:=(tempw and $8000)<>0;
                    r.cc.x:=r.cc.c;
                    tempw:=tempw and $c000;
                    r.cc.v:=not((tempw=0) or (tempw=$c000));
                  end;
               $2:begin  //lsr.w
                    self.contador:=self.contador+8;
                    tempw:=self.leerdir_w(dir);
                    r.cc.c:=(tempw and $1)<>0;
                    tempw:=tempw shr 1;
                    self.ponerdir_w2(dir,tempw);
                    r.cc.n:=false;
                    r.cc.v:=false;
                    r.cc.z:=(tempw=0);
                    r.cc.x:=r.cc.c;
                 end;
               $3:begin  //lsl.w
                    self.contador:=self.contador+8;
                    tempw:=self.leerdir_w(dir);
                    r.cc.c:=(tempw and $8000)<>0;
                    tempw:=tempw shl 1;
                    self.ponerdir_w2(dir,tempw);
                    r.cc.n:=(tempw and $8000)<>0;
                    r.cc.v:=false;
                    r.cc.z:=(tempw=0);
                    r.cc.x:=r.cc.c;
                 end;
               $4:begin //roxr.w
                    self.contador:=self.contador+8;
                    tempw:=self.leerdir_w(dir);
                    templ:=(tempw shr 1) or ((tempw and 1) shl 16) or (byte(r.cc.x) shl 15);
                    self.ponerdir_w2(dir,templ and $ffff);
                    r.cc.n:=(templ and $8000)<>0;
                    r.cc.z:=(templ and $ffff)=0;
                    r.cc.c:=(templ and $10000)<>0;
                    r.cc.x:=r.cc.c;
                    r.cc.v:=false;
                 end;
               $7:begin //rol.w
                    self.contador:=self.contador+8;
                    tempw:=self.leerdir_w(dir);
                    tempw2:=(tempw shl 1) or ((tempw and $8000) shr 15);
                    self.ponerdir_w2(dir,tempw2);
                    r.cc.c:=(tempw and $8000)<>0;
                    r.cc.n:=(tempw2 and $8000)<>0;
                    r.cc.v:=false;
                    r.cc.z:=(tempw2=0);
                  end;
          else MessageDlg('Instruccion $E ''11''. '+inttostr((instruccion shr 8) and $f)+' - '+inttohex(r.ppc.l,10), mtInformation,[mbOk], 0);
        end;
      end else begin
          if ((instruccion shr 5) and 1)=1 then tempb:=r.d[(instruccion shr 9)and 7].l and $3f
            else tempb:=(((instruccion shr 9)-1) and $7)+1;
          self.contador:=self.contador+(tempb*2);
          case (instruccion shr $3) and $3f of
           $00,$04:begin //asr.b
                    self.contador:=self.contador+6;
                    tempb2:=r.d[orig].l0;
                    r.cc.c:=((tempb2 shl (9-tempb)) and $100)<>0;
                    tempb3:=tempb2 shr tempb;
                    if (tempb2 and $80)<>0 then tempb3:=tempb3 or m68ki_shift_8_table[tempb];
                    r.d[orig].l0:=tempb3;
                    r.cc.n:=(tempb3 and $80)<>0;
                    r.cc.z:=(tempb3=0);
                    r.cc.v:=false;
                    r.cc.x:=r.cc.c;
                   end;
           $01,$05:begin //++++++ lsr.b
                    self.contador:=self.contador+6;
                    tempb2:=r.d[orig].l0;
                    r.cc.c:=((tempb2 shl (9-tempb)) and $100)<>0;
                    tempb2:=tempb2 shr tempb;
                    r.d[orig].l0:=tempb2;
                    r.cc.n:=false;
                    r.cc.v:=false;
                    r.cc.z:=(tempb2=0);
                    r.cc.x:=r.cc.c;
                 end;
           $02,$06:begin //roxr.b
                    self.contador:=self.contador+6;
                    tempw:=r.d[orig].l0 or (byte(r.cc.x) shl 8);
                    for tempb2:=1 to tempb do
                      tempw:=(tempw shr 1) or ((tempw and 1) shl 8);
                    r.d[orig].l0:=tempw and $ff;
                    r.cc.n:=(tempw and $80)<>0;
                    r.cc.v:=false;
                    r.cc.z:=(tempw and $ff)=0;
                    r.cc.c:=(tempw and $100)<>0;
                    r.cc.x:=r.cc.c;
                 end;
         $03,$07:begin // +++++ ror.b
                  self.contador:=self.contador+6;
                  tempb3:=r.d[orig].l0;
                  r.cc.c:=((tempb3 shl (9-tempb)) and $100)<>0;
                  for tempb2:=1 to (tempb and $7) do
                      tempb3:=(tempb3 shr 1) or ((tempb3 and 1) shl 7);
                  r.cc.n:=(tempb3 and $80)<>0;
                  r.cc.v:=false;
                  r.cc.z:=(tempb3=0);
                  r.d[orig].l0:=tempb3;
                end;
         $08,$0c:begin //+++++ asr.w
                    self.contador:=self.contador+6;
                    tempw:=r.d[orig].wl;
                    r.cc.c:=((tempw shl (9-tempb)) and $100)<>0;
                    tempw2:=tempw shr tempb;
                    if (tempw and $8000)<>0 then tempw2:=tempw2 or m68ki_shift_16_table[tempb];
                    r.d[orig].wl:=tempw2;
                    r.cc.n:=(tempw2 and $8000)<>0;
                    r.cc.z:=(tempw2=0);
                    r.cc.v:=false;
                    r.cc.x:=r.cc.c;
                 end;
         $09,$0d:begin //++++++ lsr.w
                    self.contador:=self.contador+6;
                    tempw:=r.d[orig].wl;
                    r.cc.c:=((tempw shl (9-tempb)) and $100)<>0;
                    tempw:=tempw shr tempb;
                    r.d[orig].wl:=tempw;
                    r.cc.n:=false;
                    r.cc.z:=(tempw=0);
                    r.cc.v:=false;
                    r.cc.x:=r.cc.c;
                 end;
         $0a,$0e:begin //roxr.w
                    self.contador:=self.contador+6;
                    templ:=r.d[orig].wl or (byte(r.cc.x) shl 16);
                    for tempb2:=1 to tempb do
                      templ:=(templ shr 1) or ((templ and 1) shl 16);
                    r.d[orig].wl:=templ and $ffff;
                    r.cc.c:=(templ and $10000)<>0;
                    r.cc.x:=r.cc.c;
                    r.cc.n:=(templ and $8000)<>0;
                    r.cc.z:=(templ and $ffff)=0;
                    r.cc.v:=false;
                 end;
         $0b,$0f:begin  //++++ ror.w
                    self.contador:=self.contador+6;
                    tempw:=r.d[orig].wl;
                    r.cc.c:=((tempw shl (9-tempb)) and $100)<>0;
                    for tempb2:=1 to tempb do
                      tempw:=(tempw shr 1) or ((tempw and 1) shl 15);
                    r.d[orig].wl:=tempw;
                    r.cc.n:=(tempw and $8000)<>0;
                    r.cc.z:=(tempw=0);
                    r.cc.v:=false;
                 end;

         $10,$14:begin //++++++ asr.l
                    self.contador:=self.contador+8;
                    templ:=r.d[orig].l;
                    r.cc.c:=((templ shl (9-tempb)) and $100)<>0;
                    templ2:=templ shr tempb;
                    if (((templ shr 24) and $80)<>0) then templ2:=templ2 or m68ki_shift_32_table[tempb];
                    r.d[orig].l:=templ2;
                    r.cc.n:=((templ2 shr 24) and $80)<>0;
                    r.cc.z:=(templ2=0);
                    r.cc.v:=false;
                    r.cc.x:=r.cc.c;
                 end;
         $11,$15:begin //++++++ lsr.l
                    self.contador:=self.contador+8;
                    templ:=r.d[orig].l;
                    r.cc.c:=((templ shl (9-tempb)) and $100)<>0;
                    templ:=templ shr tempb;
                    r.d[orig].l:=templ;
                    r.cc.n:=false;
                    r.cc.z:=(templ=0);
                    r.cc.v:=false;
                    r.cc.x:=r.cc.c;
                 end;
         $12,$16:begin  //roxr.l
                    self.contador:=self.contador+8;
                    //WTF???
                    tempdl:=byte(r.cc.x) shl 31;  //No puedo poner directamente shl 32!!
                    tempdl:=r.d[orig].l or (tempdl*2);
                    for tempb2:=1 to tempb do
                      tempdl:=(tempdl shr 1) or ((tempdl and 1) shl 32);
                    r.d[orig].l:=tempdl and $FFFFFFFF;
                    r.cc.c:=((tempdl shr 24) and $100)<>0;
                    r.cc.n:=((tempdl shr 24) and $80)<>0;
                    r.cc.z:=((templ and $ffffffff)=0);
                    r.cc.v:=false;
                 end;
         $13,$17:begin //ror.l
                    self.contador:=self.contador+8;
                    templ:=r.d[orig].l;
                    r.cc.c:=((templ shl (9-tempb)) and $100)<>0;
                    for tempb2:=1 to tempb do
                      templ:=(templ shr 1) or ((templ and 1) shl 31);
                    r.d[orig].l:=templ;
                    r.cc.n:=((templ shr 24) and $80)<>0;
                    r.cc.z:=(templ=0);
                    r.cc.v:=false;
                 end;
         $20,$24:begin //asl.b
                    self.contador:=self.contador+6;
                    tempb3:=r.d[orig].l0;
                    tempw:=tempb3 shl tempb;
                    r.d[orig].l0:=tempw and $ff;
                    r.cc.n:=(tempw and $80)<>0;
                    r.cc.z:=(tempw and $ff)=0;
                    r.cc.c:=((tempb3 shl tempb) and $100)<>0;
                    r.cc.x:=r.cc.c;
                    tempb3:=tempb3 and m68ki_shift_8_table[tempb+1];
                    r.cc.v:=not((tempb3=0) or (tempb3=(m68ki_shift_8_table[tempb+1] and (tempb shl 8))));
             end;
         $21,$25:begin  //lsl.b
                    self.contador:=self.contador+6;
                    tempb3:=r.d[orig].l0;
                    tempw:=tempb3 shl tempb;
                    r.cc.c:=((tempb3 shl tempb) and $100)<>0;
                    r.cc.n:=(tempw and $80)<>0;
                    r.cc.z:=((tempw and $ff)=0);
                    r.cc.v:=false;
                    r.cc.x:=r.cc.c;
                    r.d[orig].l0:=tempw and $ff;
                 end;
        $22,$26:begin //roxl.b
                    self.contador:=self.contador+6;
                    tempw:=r.d[orig].l0 or (byte(r.cc.x) shl 8);
                    for tempb2:=1 to tempb do
                      tempw:=(tempw shl 1) or ((tempw and $100) shr 8);
                    r.cc.c:=(tempw and $100)<>0;
                    r.cc.z:=((tempw and $ff)=0);
                    r.cc.n:=(tempw and $80)<>0;
                    r.cc.v:=false;
                    r.cc.x:=r.cc.c;
                    r.d[orig].l0:=tempw and $ff;
                 end;
         $23,$27:begin //++++ rol.b
                    self.contador:=self.contador+6;
                    tempw:=r.d[orig].l0;
                    r.cc.c:=((tempw shl (tempb and 7)) and $100)<>0;
                    for tempb2:=1 to tempb do
                      tempw:=(tempw shl 1) or ((tempw and $80) shr 7);
                    r.cc.n:=(tempw and $80)<>0;
                    r.cc.v:=false;
                    r.cc.z:=(tempw and $ff)=0;
                    r.d[orig].l0:=tempw and $ff;
                 end;
         $28,$2c:begin  //++++ asl.w
                    self.contador:=self.contador+6;
                    tempw:=r.d[orig].wl;
                    templ:=tempw shl tempb;
                    r.d[orig].wl:=templ and $ffff;
                    r.cc.c:=((tempw shr (8-tempb)) and $100)<>0;
                    r.cc.n:=(templ and $8000)<>0;
                    r.cc.z:=(templ and $ffff)=0;
                    r.cc.x:=r.cc.c;
                    tempw:=tempw and m68ki_shift_16_table[tempb+1];
                    r.cc.v:=not((tempw=0) or (tempw=(m68ki_shift_16_table[tempb+1])));
                 end;
         $29,$2d:begin  //lsl.w
                    self.contador:=self.contador+6;
                    tempw:=r.d[orig].wl;
                    templ:=tempw shl tempb;
                    r.cc.c:=((tempw shr (8-tempb)) and $100)<>0;
                    r.cc.n:=(templ and $8000)<>0;
                    r.cc.z:=(templ and $ffff)=0;
                    r.cc.x:=r.cc.c;
                    r.cc.v:=false;
                    r.d[orig].wl:=templ and $ffff;
                 end;
         $2a,$2e:begin //roxl.w
                    self.contador:=self.contador+6;
                    templ:=r.d[orig].wl or (byte(r.cc.x) shl 16);
                    for tempb2:=1 to tempb do
                      templ:=(templ shl 1) or ((templ and $10000) shr 16);
                    r.cc.c:=(templ and $10000)<>0;
                    r.cc.x:=r.cc.c;
                    r.cc.z:=(templ and $ffff)=0;
                    r.cc.n:=(templ and $8000)<>0;
                    r.cc.v:=false;
                    r.d[orig].wl:=templ and $ffff;
                 end;
         $2b,$2f:begin  //++++ rol.w
                    self.contador:=self.contador+6;
                    templ:=r.d[orig].wl;
                    r.cc.c:=((templ shr (8-tempb)) and $100)<>0;
                    for tempb2:=1 to tempb do
                      templ:=(templ shl 1) or ((templ and $8000) shr 15);
                    r.cc.z:=(templ and $ffff)=0;
                    r.cc.n:=(templ and $8000)<>0;
                    r.cc.v:=false;
                    r.d[orig].wl:=templ and $ffff;
                 end;
         $30,$34:begin  //++++ asl.l
                    self.contador:=self.contador+8;
                    templ:=r.d[orig].l;
                    tempdl:=templ shl tempb;
                    r.cc.n:=((tempdl shr 24) and $80)<>0;
                    r.cc.z:=(tempdl and $ffffffff)=0;
                    r.cc.c:=((templ shr (24-tempb)) and $100)<>0;
                    r.cc.x:=r.cc.c;
                    templ:=templ and m68ki_shift_32_table[tempb+1];
                    r.cc.v:=not((templ=0) or (templ=m68ki_shift_32_table[tempb+1]));
                    r.d[orig].l:=tempdl and $FFFFFFFF;
                 end;
         $31,$35:begin  //++++ lsl.l
                    self.contador:=self.contador+8;
                    tempdl:=r.d[orig].l;
                    r.cc.c:=((tempdl shr (24-tempb)) and $100)<>0;
                    tempdl:=tempdl shl tempb;
                    r.cc.n:=((tempdl shr 24) and $80)<>0;
                    r.cc.z:=(tempdl and $ffffffff)=0;
                    r.cc.x:=r.cc.c;
                    r.cc.v:=false;
                    r.d[orig].l:=tempdl and $ffffffff;
                 end;
         $32:begin  //roxl.l
                    self.contador:=self.contador+8;
                    //WTF?????
                    tempdl:=byte(r.cc.x) shl 31; //No puedo poner shl 32!!!
                    tempdl:=(tempdl*2) or r.d[orig].l;
                    for tempb2:=1 to tempb do
                      tempdl:=(tempdl shl 1) or ((tempdl and $100000000) shr 32);
                    r.cc.c:=((tempdl shr 24) and $100)<>0;
                    r.cc.n:=((tempdl shr 24) and $80)<>0;
                    r.cc.z:=(tempdl and $ffffffff)=0;
                    r.cc.x:=r.cc.c;
                    r.cc.v:=false;
                    r.d[orig].l:=tempdl and $ffffffff;
             end;
         $33,$37:begin  //++++ rol.l
                    self.contador:=self.contador+8;
                    tempdl:=r.d[orig].l;
                    r.cc.c:=((tempdl shr (24-tempb)) and $100)<>0;
                    for tempb2:=1 to tempb do
                      tempdl:=(tempdl shl 1) or ((tempdl and $80000000) shr 31);
                    r.cc.n:=((tempdl shr 24) and $80)<>0;
                    r.cc.v:=false;
                    r.cc.z:=(tempdl and $ffffffff)=0;
                    r.d[orig].l:=tempdl and $ffffffff;
                 end;
         else MessageDlg('Instruccion $E no es ''11''. '+inttohex((instruccion shr 3) and $3f,10)+' - '+inttohex(r.ppc.l,10), mtInformation,[mbOk], 0);
          end;
      end;  //del case $e
   $f:begin  //emulacion 1111
        self.prefetch:=false;
        self.contador:=self.contador+4;
        tempw:=coger_band(self.r);
        self.poner_band(tempw or $2000);
        r.sp.l:=r.sp.l-6;
        self.putword(r.sp.l,tempw);
        self.putword(r.sp.l+2,r.pc.wh);
        self.putword(r.sp.l+4,r.pc.wl-2);
        r.pc.wh:=self.getword($b*4);
        r.pc.wl:=self.getword(($b*4)+2);
      end;
   else MessageDlg('Instruccion: '+inttostr(instruccion)+' (primer nibble). PC='+inttostr(r.pc.l), mtInformation,[mbOk], 0);
end;
//if r.prefetch then self.contador:=self.contador-4;
update_timer(self.contador-pcontador,self.numero_cpu);
self.prefetch:=true;
end;  //del while
end;

end.
