unit snapshot;

interface
uses {$IFDEF windows}windows,{$ENDIF}
     sysutils,spectrum_misc,ay_8910,dialogs,nz80,z80_sp,forms,file_engine,
     init_games,rom_engine,ppi8255,tms99xx,pal_engine,sn_76496;

//Spectrum
function abrir_sna(datos:pbyte;long:integer):boolean;
function grabar_sna(nombre:string):boolean;
function abrir_sp(datos:pbyte;long:integer):boolean;
function abrir_zx(datos:pbyte;long:integer):boolean;
function abrir_szx(data:pbyte;long:integer):boolean;
function grabar_szx(nombre:string):boolean;
function abrir_z80(datos:pbyte;long:integer;es_dsp:boolean):boolean;
function grabar_z80(nombre:string;es_dsp:boolean):boolean;
procedure descomprimir_z80(destino,origen:pbyte;var longitud:integer);
procedure spectrum_change_model(model:byte);
//Amstrad CPC
function abrir_sna_cpc(data:pbyte;longitud:integer):boolean;
function grabar_amstrad_sna(nombre:string):boolean;
//Coleco
function abrir_coleco_snapshot(data:pbyte;long:dword):boolean;
function grabar_coleco_snapshot(nombre:string):boolean;

implementation
uses spectrum_48k,spectrum_128k,spectrum_3,amstrad_cpc,coleco,principal,main_engine;

procedure spectrum_change_model(model:byte);
begin
//Es el mismo modelo?
if main_vars.tipo_maquina=model then begin
  llamadas_maquina.reset;
  exit;
end;
//Cerrar el Spectrum y cambiar el modelo
llamadas_maquina.cerrar;
todos_false;
reset_dsp;
case model of
  0,5:begin //Spectrum 48k y Spectrum 16k
      if model=0 then main_vars.tipo_maquina:=tipo_cambio_maquina(principal1.Spectrum48K1)
        else main_vars.tipo_maquina:=tipo_cambio_maquina(principal1.Spectrum16K1);
      Cargar_Spectrum48K;
    end;
  1,4:begin //Spectrum 128k y Spectrum +2
      if model=1 then main_vars.tipo_maquina:=tipo_cambio_maquina(principal1.Spectrum128K1)
        else main_vars.tipo_maquina:=tipo_cambio_maquina(principal1.Spectrum21);
      Cargar_Spectrum128K;
    end;
  2,3:begin //Spectrum +3 y Spectrum +2A
      if model=2 then main_vars.tipo_maquina:=tipo_cambio_maquina(principal1.Spectrum31)
        else main_vars.tipo_maquina:=tipo_cambio_maquina(principal1.Spectrum2A1);
      Cargar_Spectrum3;
    end;
end;
llamadas_maquina.iniciar;
end;

//Spectrum .SNA
type
  tsna_regs=packed record
    i:byte;
    hl2,de2,bc2:word;
    flags2,a2:byte;
    hl,de,bc,iy,ix:word;
    iff,r,flags,a:byte;
    sp:word;
    im,color_borde:byte;
  end;
  tsna_regs_128k=packed record
    pc:word;
    reg_7ffd,trdos:byte;
  end;

function abrir_sna(datos:pbyte;long:integer):boolean;
var
  f:word;
  spec_z80_reg:npreg_z80;
  sna_regs:^tsna_regs;
  sna_regs_128k:^tsna_regs_128k;
  ptemp:pbyte;
begin
//Soporta 16k, 48k y 128k!!
abrir_sna:=false;
spec_z80_reg:=spec_z80.get_internal_r;
getmem(sna_regs,sizeof(tsna_regs));
copymemory(sna_regs,datos,27);inc(datos,27);
if ((long-27)>$c000) then begin
        getmem(sna_regs_128k,sizeof(tsna_regs_128k));
        getmem(ptemp,$4000);
        spectrum_change_model(1);
        copymemory(@memoria_128k[5,0],datos,$4000);inc(datos,$4000);
        copymemory(@memoria_128k[2,0],datos,$4000);inc(datos,$4000);
        copymemory(ptemp,datos,$4000);inc(datos,$4000);
        copymemory(sna_regs_128k,datos,4);inc(datos,4);
        spec_z80_reg.pc:=sna_regs_128k.pc;
        spec_z80_reg.sp:=sna_regs.sp;
        ay8910_0.reset;
        spec128_outbyte(sna_regs_128k.reg_7ffd,$7ffd);
        copymemory(@memoria_128k[marco[3],0],ptemp,16384);
        for f:=0 to 7 do
           if ((f<>2) and (f<>5) and (f<>marco[3])) then begin
                copymemory(@memoria_128k[f,0],datos,16384);
                inc(datos,16384);
           end;
        freemem(ptemp);
        freemem(sna_regs_128k);
end else begin
        if ((long-27)<49152) then begin //Spectrum 16k
            spectrum_change_model(5);
            copymemory(@memoria[$4000],datos,$4000);
        end else begin //Spectrum 48k
            spectrum_change_model(0);
            copymemory(@memoria[$4000],datos,$c000);
        end;
        spec_z80_reg.sp:=sna_regs.sp;
        copymemory(@spec_z80_reg.pc,@memoria[spec_z80_reg.sp],2);
        spec_z80_reg.sp:=spec_z80_reg.sp+2;
end;
spec_z80_reg.i:=sna_regs.i;
spec_z80_reg.hl2.w:=sna_regs.hl2;
spec_z80_reg.de2.w:=sna_regs.de2;
spec_z80_reg.bc2.w:=sna_regs.bc2;
spec_z80_reg.f2.s:=(sna_regs.flags2 and $80)<>0;
spec_z80_reg.f2.z:=(sna_regs.flags2 and $40)<>0;
spec_z80_reg.f2.bit5:=(sna_regs.flags2 and $20)<>0;
spec_z80_reg.f2.h:=(sna_regs.flags2 and $10)<>0;
spec_z80_reg.f2.bit3:=(sna_regs.flags2 and 8)<>0;
spec_z80_reg.f2.p_v:=(sna_regs.flags2 and 4)<>0;
spec_z80_reg.f2.n:=(sna_regs.flags2 and 2)<>0;
spec_z80_reg.f2.c:=(sna_regs.flags2 and 1)<>0;
spec_z80_reg.a2:=sna_regs.a2;
spec_z80_reg.hl.w:=sna_regs.hl;
spec_z80_reg.de.w:=sna_regs.de;
spec_z80_reg.bc.w:=sna_regs.bc;
spec_z80_reg.iy.w:=sna_regs.iy;
spec_z80_reg.ix.w:=sna_regs.ix;
spec_z80_reg.iff2:=(sna_regs.iff and 4)<>0;
spec_z80_reg.iff1:=(sna_regs.iff and 2)<>0;
spec_z80_reg.r:=sna_regs.r;
spec_z80_reg.f.s:=(sna_regs.flags and $80)<>0;
spec_z80_reg.f.z:=(sna_regs.flags and $40)<>0;
spec_z80_reg.f.bit5:=(sna_regs.flags and $20)<>0;
spec_z80_reg.f.h:=(sna_regs.flags and $10)<>0;
spec_z80_reg.f.bit3:=(sna_regs.flags and 8)<>0;
spec_z80_reg.f.p_v:=(sna_regs.flags and 4)<>0;
spec_z80_reg.f.n:=(sna_regs.flags and 2)<>0;
spec_z80_reg.f.c:=(sna_regs.flags and 1)<>0;
spec_z80_reg.a:=sna_regs.a;
spec_z80_reg.im:=sna_regs.im;
borde.color:=sna_regs.color_borde and 7;
freemem(sna_regs);
abrir_sna:=true;
end;

function grabar_sna(nombre:string):boolean;
var
  sna_regs:^tsna_regs;
  sna_regs_128k:^tsna_regs_128k;
  temp,old1,old2:byte;
  spec_z80_reg:npreg_z80;
  pdatos,ptemp:pbyte;
  longitud:dword;
begin
grabar_sna:=false;
spec_z80_reg:=spec_z80.get_internal_r;
getmem(sna_regs,sizeof(tsna_regs));
fillchar(sna_regs^,sizeof(tsna_regs),0);
sna_regs.i:=spec_z80_reg.i;
sna_regs.hl2:=spec_z80_reg.hl2.w;
sna_regs.de2:=spec_z80_reg.de2.w;
sna_regs.bc2:=spec_z80_reg.bc2.w;
if spec_z80_reg.f2.s then sna_regs.flags2:=sna_regs.flags2 or $80;
if spec_z80_reg.f2.z then sna_regs.flags2:=sna_regs.flags2 or $40;
if spec_z80_reg.f2.bit5 then sna_regs.flags2:=sna_regs.flags2 or $20;
if spec_z80_reg.f2.h then sna_regs.flags2:=sna_regs.flags2 or $10;
if spec_z80_reg.f2.bit3 then sna_regs.flags2:=sna_regs.flags2 or 8;
if spec_z80_reg.f2.p_v then sna_regs.flags2:=sna_regs.flags2 or 4;
if spec_z80_reg.f2.n then sna_regs.flags2:=sna_regs.flags2 or 2;
if spec_z80_reg.f2.c then sna_regs.flags2:=sna_regs.flags2 or 1;
sna_regs.a2:=spec_z80_reg.a2;
sna_regs.hl:=spec_z80_reg.hl.w;
sna_regs.de:=spec_z80_reg.de.w;
sna_regs.bc:=spec_z80_reg.bc.w;
sna_regs.iy:=spec_z80_reg.iy.w;
sna_regs.ix:=spec_z80_reg.ix.w;
if spec_z80_reg.iff1 then sna_regs.iff:=sna_regs.iff or 2;
if spec_z80_reg.iff2 then sna_regs.iff:=sna_regs.iff or 4;
sna_regs.r:=spec_z80_reg.r;
if spec_z80_reg.f.s then sna_regs.flags:=sna_regs.flags or $80;
if spec_z80_reg.f.z then sna_regs.flags:=sna_regs.flags or $40;
if spec_z80_reg.f.bit5 then sna_regs.flags:=sna_regs.flags or $20;
if spec_z80_reg.f.h then sna_regs.flags:=sna_regs.flags or $10;
if spec_z80_reg.f.bit3 then sna_regs.flags:=sna_regs.flags or 8;
if spec_z80_reg.f.p_v then sna_regs.flags:=sna_regs.flags or 4;
if spec_z80_reg.f.n then sna_regs.flags:=sna_regs.flags or 2;
if spec_z80_reg.f.c then sna_regs.flags:=sna_regs.flags or 1;
sna_regs.a:=spec_z80_reg.a;
sna_regs.im:=spec_z80_reg.im;
sna_regs.color_borde:=borde.color;
getmem(pdatos,$30000);
ptemp:=pdatos;
case main_vars.tipo_maquina of
        0,5:begin
             old1:=memoria[spec_z80_reg.sp-1];
             old2:=memoria[spec_z80_reg.sp-2];
             memoria[spec_z80_reg.sp-1]:=spec_z80_reg.pc shr 8;
             memoria[spec_z80_reg.sp-2]:=spec_z80_reg.pc and $ff;
             sna_regs.sp:=spec_z80_reg.sp-2;
             copymemory(ptemp,sna_regs,27);inc(ptemp,27);
             if main_vars.tipo_maquina=5 then begin //Spectrum 16k
                copymemory(ptemp,@memoria[$4000],$4000);
                longitud:=27+$4000;
             end else begin //Spectrum 48k
                copymemory(ptemp,@memoria[$4000],$c000);
                longitud:=27+$c000;
             end;
             memoria[spec_z80_reg.sp-1]:=old1;
             memoria[spec_z80_reg.sp-2]:=old2;
          end;
        1,4:begin
             sna_regs.sp:=spec_z80_reg.sp;
             copymemory(ptemp,sna_regs,27);inc(ptemp,27);
             copymemory(ptemp,@memoria_128k[5,0],16384);inc(ptemp,$4000);
             copymemory(ptemp,@memoria_128k[2,0],16384);inc(ptemp,$4000);
             copymemory(ptemp,@memoria_128k[marco[3],0],$4000);inc(ptemp,$4000);
             getmem(sna_regs_128k,sizeof(tsna_regs_128k));
             sna_regs_128k.pc:=spec_z80_reg.pc;
             sna_regs_128k.reg_7ffd:=old_7ffd;
             sna_regs_128k.trdos:=0;
             copymemory(ptemp,sna_regs_128k,4);inc(ptemp,4);
             longitud:=27+$4000*3+4;
             freemem(sna_regs_128k);
             for temp:=0 to 7 do
                if ((temp<>2) and (temp<>5) and (temp<>marco[3])) then begin
                   copymemory(ptemp,@memoria_128k[temp,0],$4000);
                   inc(ptemp,$4000);
                   longitud:=longitud+$4000;
                end;
          end;
        else begin
             MessageDlg('Modelo no soportado formato SNA.'+chr(10)+chr(13)+'Model not supported for SNA format.', mtInformation,[mbOk], 0);
             exit;
        end;
end;
freemem(sna_regs);
grabar_sna:=write_file(nombre,pdatos,longitud);
freemem(pdatos);
end;

//Spectrum .ZX
function abrir_zx(datos:pbyte;long:integer):boolean;
var
  buffer:array[0..50] of byte;
  temp:word;
  spec_z80_reg:npreg_z80;
begin
abrir_zx:=false;
if long<>49486 then exit;
spectrum_change_model(0);
//Los 132 primeros bytes son de la ROM del spectrum, los ignoro
inc(datos,132);
copymemory(@memoria[$4000],datos,49152);inc(datos,49152);
//132 bytes sin uso + 10 bytes de configuracion interna
inc(datos,142);
spec_z80_reg:=spec_z80.get_internal_r;
spec_z80_reg.iff1:=(datos^=1);inc(datos);
//2 bytes sin uso + 1 byte color/monocromo + 4 bytes sin uso
inc(datos,7);
//este formato viene de Amiga, por lo tanto tiene invertido el byte mas significativo
//Los bytes del buffer que no se usan, siempre son 0 (sin uso)
copymemory(@buffer[0],datos,50);
spec_z80_reg.bc.w:=(buffer[0] shl 8)+buffer[1];
spec_z80_reg.bc2.w:=(buffer[2] shl 8)+buffer[3];
spec_z80_reg.de.w:=(buffer[4] shl 8)+buffer[5];
spec_z80_reg.de2.w:=(buffer[6] shl 8)+buffer[6];
spec_z80_reg.hl.w:=(buffer[8] shl 8)+buffer[9];
spec_z80_reg.hl2.w:=(buffer[10] shl 8)+buffer[11];
spec_z80_reg.ix.w:=(buffer[12] shl 8)+buffer[13];
spec_z80_reg.iy.w:=(buffer[14] shl 8)+buffer[15];
spec_z80_reg.i:=buffer[16];
spec_z80_reg.r:=buffer[17];
spec_z80_reg.a2:=buffer[21];
spec_z80_reg.a:=buffer[23];
spec_z80_reg.f2.s:=(buffer[25] and 128)<>0;
spec_z80_reg.f2.z:=(buffer[25] and 64)<>0;
spec_z80_reg.f2.bit5:=(buffer[25] and 32)<>0;
spec_z80_reg.f2.h:=(buffer[25] and 16)<>0;
spec_z80_reg.f2.bit3:=(buffer[25] and 8)<>0;
spec_z80_reg.f2.p_v:=(buffer[25] and 4)<>0;
spec_z80_reg.f2.n:=(buffer[25] and 2)<>0;
spec_z80_reg.f2.c:=(buffer[25] and 1)<>0;
spec_z80_reg.f.s:=(buffer[27] and 128)<>0;
spec_z80_reg.f.z:=(buffer[27] and 64)<>0;
spec_z80_reg.f.bit5:=(buffer[27] and 32)<>0;
spec_z80_reg.f.h:=(buffer[27] and 16)<>0;
spec_z80_reg.f.bit3:=(buffer[27] and 8)<>0;
spec_z80_reg.f.p_v:=(buffer[27] and 4)<>0;
spec_z80_reg.f.n:=(buffer[27] and 2)<>0;
spec_z80_reg.f.c:=(buffer[27] and 1)<>0;
spec_z80_reg.pc:=(buffer[30] shl 8)+buffer[31];
spec_z80_reg.sp:=(buffer[34] shl 8)+buffer[35];
temp:=(buffer[40] shl 8)+buffer[41];
case temp of
  $0000:spec_z80_reg.im:=1;
  $0001:spec_z80_reg.im:=2;
  $ffff:spec_z80_reg.im:=0;
end;
abrir_zx:=true;
end;

//Spectrum .SP
function abrir_sp(datos:pbyte;long:integer):boolean;
type
  tsp_regs=packed record
    nombre:array[0..1] of ansichar;
    long,pos,bc,de,hl:word;
    flags,a:byte;
    ix,iy,bc2,de2,hl2:word;
    flags2,a2,r,i:byte;
    sp,pc,reserved1:word;
    borde_color,reserved2:byte;
    misc:word;
  end;
var
  spec_z80_reg:npreg_z80;
  sp_regs:^tsp_regs;
begin
abrir_sp:=false;
spectrum_change_model(0); //Solo puede ser 48K
spec_z80_reg:=spec_z80.get_internal_r;
getmem(sp_regs,38);
copymemory(sp_regs,datos,38);inc(datos,38);
if ((sp_regs.nombre<>'SP') or ((sp_regs.long+38)<long))then exit;
copymemory(@memoria[sp_regs.pos],datos,sp_regs.long);
spec_z80_reg.bc.w:=sp_regs.bc;
spec_z80_reg.de.w:=sp_regs.de;
spec_z80_reg.hl.w:=sp_regs.hl;
spec_z80_reg.f.s:=(sp_regs.flags and $80)<>0;
spec_z80_reg.f.z:=(sp_regs.flags and $40)<>0;
spec_z80_reg.f.bit5:=(sp_regs.flags and $20)<>0;
spec_z80_reg.f.h:=(sp_regs.flags and $10)<>0;
spec_z80_reg.f.bit3:=(sp_regs.flags and 8)<>0;
spec_z80_reg.f.p_v:=(sp_regs.flags and 4)<>0;
spec_z80_reg.f.n:=(sp_regs.flags and 2)<>0;
spec_z80_reg.f.c:=(sp_regs.flags and 1)<>0;
spec_z80_reg.a:=sp_regs.a;
spec_z80_reg.ix.w:=sp_regs.ix;
spec_z80_reg.iy.w:=sp_regs.iy;
spec_z80_reg.bc2.w:=sp_regs.bc2;
spec_z80_reg.de2.w:=sp_regs.de2;
spec_z80_reg.hl2.w:=sp_regs.hl2;
spec_z80_reg.f2.s:=(sp_regs.flags2 and $80)<>0;
spec_z80_reg.f2.z:=(sp_regs.flags2 and $40)<>0;
spec_z80_reg.f2.bit5:=(sp_regs.flags2 and $20)<>0;
spec_z80_reg.f2.h:=(sp_regs.flags2 and $10)<>0;
spec_z80_reg.f2.bit3:=(sp_regs.flags2 and 8)<>0;
spec_z80_reg.f2.p_v:=(sp_regs.flags2 and 4)<>0;
spec_z80_reg.f2.n:=(sp_regs.flags2 and 2)<>0;
spec_z80_reg.f2.c:=(sp_regs.flags2 and 1)<>0;
spec_z80_reg.a2:=sp_regs.a2;
spec_z80_reg.r:=sp_regs.r;
spec_z80_reg.i:=sp_regs.i;
spec_z80_reg.sp:=sp_regs.sp;
spec_z80_reg.pc:=sp_regs.pc;
spec48_outbyte(sp_regs.borde_color,$fe);
spec_z80_reg.iff1:=(sp_regs.misc and 1)<>0;
spec_z80_reg.iff2:=(sp_regs.misc and 4)<>0;
//interrupt --> bit 5
haz_flash:=(sp_regs.misc and $20)<>0;
if (sp_regs.misc and 8)<>0 then spec_z80_reg.im:=0
  else spec_z80_reg.im:=((sp_regs.misc and 2) shr 1)+1;
freemem(sp_regs);
abrir_sp:=true;
end;

//Spectrum .SZX
type
  tszx_header=packed record
    magic:array[0..3] of ansichar;
    major_version,minor_version,tipo_maquina,flags:byte;
  end;
  tszx_block=packed record
    name:array[0..3] of ansichar;
    longitud:dword;
  end;
  tszx_regs=packed record
    a,flags:byte;
    bc,de,hl:word;
    a2,flags2:byte;
    bc2,de2,hl2,ix,iy,sp,pc:word;
    i,r,iff1,iff2,im:byte;
    estados_t:dword;
    estados_t_irq,misc:byte;
    memptr:word;
  end;
  tszx_spcr=packed record
    borde,reg_7ffd,reg_1ffd,reg_eff7,reg_fe:byte;
    reserved1,reserved2,reserved3,reserved14:byte;
  end;
  tszx_ramp=packed record
    flags:word;
    numero:byte;
    data:array[0..$3fff] of byte;
  end;
  tszx_ay=packed record
    flags,reg_fffd:byte;
    regs:array[0..15] of byte;
  end;
  tszx_rom=packed record
    flags:word;
    longitud:dword;
    data:array[0..$ffff] of byte;
  end;

function abrir_szx(data:pbyte;long:integer):boolean;
var
  longitud,temp_long:integer;
  temp:byte;
  ram_sp:pbyte;
  spec_z80_reg:npreg_z80;
  szx_header:^tszx_header;
  szx_block:^tszx_block;
  szx_regs:^tszx_regs;
  szx_spcr:^tszx_spcr;
  szx_ramp:^tszx_ramp;
  szx_ay:^tszx_ay;
  szx_rom:^tszx_rom;
begin
abrir_szx:=false;
getmem(szx_header,sizeof(tszx_header));
copymemory(szx_header,data,8);inc(data,8);longitud:=8;
if (szx_header.magic<>'ZXST') then exit;
case szx_header.tipo_maquina of
  0:spectrum_change_model(5);
  1:spectrum_change_model(0);
  2:spectrum_change_model(1);
  3:spectrum_change_model(4);
  4:spectrum_change_model(3);
  5:spectrum_change_model(2);
    else begin
      MessageDlg('Modelo no de Spectrum soportado.'+chr(10)+chr(13)+'Spectrum model not supported.', mtInformation,[mbOk], 0);
      exit;
    end;
end;
getmem(szx_block,sizeof(tszx_block));
while longitud<>long do begin
  copymemory(szx_block,data,8);inc(data,8);inc(longitud,8);
  if szx_block.name='Z80R' then begin
    getmem(szx_regs,sizeof(tszx_regs));
    spec_z80_reg:=spec_z80.get_internal_r;
    copymemory(szx_regs,data,37);
    spec_z80_reg.a:=szx_regs.a;
    spec_z80_reg.f.s:=(szx_regs.flags and $80)<>0;
    spec_z80_reg.f.z:=(szx_regs.flags and $40)<>0;
    spec_z80_reg.f.bit5:=(szx_regs.flags and $20)<>0;
    spec_z80_reg.f.h:=(szx_regs.flags and $10)<>0;
    spec_z80_reg.f.bit3:=(szx_regs.flags and 8)<>0;
    spec_z80_reg.f.p_v:=(szx_regs.flags and 4)<>0;
    spec_z80_reg.f.n:=(szx_regs.flags and 2)<>0;
    spec_z80_reg.f.c:=(szx_regs.flags and 1)<>0;
    spec_z80_reg.bc.w:=szx_regs.bc;
    spec_z80_reg.de.w:=szx_regs.de;
    spec_z80_reg.hl.w:=szx_regs.hl;
    spec_z80_reg.a2:=szx_regs.a2;
    spec_z80_reg.f2.s:=(szx_regs.flags2 and $80)<>0;
    spec_z80_reg.f2.z:=(szx_regs.flags2 and $40)<>0;
    spec_z80_reg.f2.bit5:=(szx_regs.flags2 and $20)<>0;
    spec_z80_reg.f2.h:=(szx_regs.flags2 and $10)<>0;
    spec_z80_reg.f2.bit3:=(szx_regs.flags2 and 8)<>0;
    spec_z80_reg.f2.p_v:=(szx_regs.flags2 and 4)<>0;
    spec_z80_reg.f2.n:=(szx_regs.flags2 and 2)<>0;
    spec_z80_reg.f2.c:=(szx_regs.flags2 and 1)<>0;
    spec_z80_reg.bc2.w:=szx_regs.bc2;
    spec_z80_reg.de2.w:=szx_regs.de2;
    spec_z80_reg.hl2.w:=szx_regs.hl2;
    spec_z80_reg.ix.w:=szx_regs.ix;
    spec_z80_reg.iy.w:=szx_regs.iy;
    spec_z80_reg.sp:=szx_regs.sp;
    spec_z80_reg.pc:=szx_regs.pc;
    spec_z80_reg.i:=szx_regs.i;
    spec_z80_reg.r:=szx_regs.r;
    spec_z80_reg.iff1:=szx_regs.iff1<>0;
    spec_z80_reg.iff2:=szx_regs.iff2<>0;
    spec_z80_reg.im:=szx_regs.im;
    spec_z80.halt:=(szx_regs.misc=2);
    //opppssss!!!
    if szx_regs.estados_t_irq<40 then spectrum_irq_pos:=szx_regs.estados_t_irq;
    if szx_regs.estados_t<71000 then spec_z80.contador:=szx_regs.estados_t;
    freemem(szx_regs);
  end;
  if szx_block.name='SPCR' then begin
    getmem(szx_spcr,sizeof(tszx_spcr));
    copymemory(szx_spcr,data,9);
    case szx_header.tipo_maquina of
      2,3:spec128_outbyte(szx_spcr.reg_7ffd,$7ffd);
      4,5:spec3_outbyte(szx_spcr.reg_7ffd,$7ffd);
    end;
    case szx_header.tipo_maquina of
      4,5:spec3_outbyte(szx_spcr.reg_1ffd,$1ffd);
    end;
    case szx_header.tipo_maquina of
      0,1:spec48_outbyte(szx_spcr.reg_fe,$fe);
      2,3:spec128_outbyte(szx_spcr.reg_fe,$fe);
      4,5:spec3_outbyte(szx_spcr.reg_fe,$fe);
    end;
    borde.color:=szx_spcr.borde;
    freemem(szx_spcr);
  end;
  if szx_block.name='RAMP' then begin
    getmem(szx_ramp,sizeof(tszx_ramp));
    copymemory(szx_ramp,data,szx_block.longitud);
    if (szx_ramp.flags and 1)<>0 then begin //Pagina RAM comprimida
      getmem(ram_sp,$4000);
      Decompress_zlib(pointer(@szx_ramp.data[0]),szx_block.longitud-3,pointer(ram_sp),temp_long);
      if temp_long<>16384 then exit;
    end else ram_sp:=@szx_ramp.data[0]; //Sin comprimir
    case szx_header.tipo_maquina of
      1:case szx_ramp.numero of
          0:copymemory(@memoria[$c000],ram_sp,$4000);
          2:copymemory(@memoria[$8000],ram_sp,$4000);
          5:copymemory(@memoria[$4000],ram_sp,$4000);
        end;
      2,3:copymemory(@memoria_128k[szx_ramp.numero,0],ram_sp,$4000);
      4,5:copymemory(@memoria_3[szx_ramp.numero,0],ram_sp,$4000);
      0:copymemory(@memoria[$4000],ram_sp,$4000);
    end;
    //Si he reservado memoria para descomprimir, la libero
    if (szx_ramp.flags and 1)<>0 then freemem(ram_sp);
    freemem(szx_ramp);
  end;
  if szx_block.name='AY' then begin
    ay8910_0.reset;
    getmem(szx_ay,sizeof(tszx_ay));
    copymemory(szx_ay,data,18);
    for temp:=0 to $f do ay8910_0.set_reg(temp,szx_ay.regs[temp]);
    ay8910_0.control(szx_ay.reg_fffd);
    freemem(szx_ay);
  end;
  if szx_block.name='ROM' then begin
    getmem(szx_rom,sizeof(tszx_rom));
    copymemory(szx_rom,data,szx_block.longitud);
    rom_cambiada_48:=true;
    ram_sp:=@memoria[0];
    Decompress_zlib(pointer(@szx_rom.data[0]),szx_block.longitud-6,pointer(ram_sp),temp_long);
    freemem(szx_rom);
end;
  inc(data,szx_block.longitud);
  inc(longitud,szx_block.longitud);
end;
freemem(szx_header);
abrir_szx:=true;
end;

function grabar_szx(nombre:string):boolean;
type
    tszx_crtr=packed record
      creator:array[0..31] of ansichar;
      major_version,minor_version:word;
    end;
const
   spec48_ram:array[0..2] of byte=(5,2,0);
var
  pdatos,ptemp:pbyte;
  cantidad,longitud:integer;
  f:byte;
  spec_z80_reg:npreg_z80;
  szx_header:^tszx_header;
  szx_block:^tszx_block;
  szx_regs:^tszx_regs;
  szx_spcr:^tszx_spcr;
  szx_ramp:^tszx_ramp;
  szx_ay:^tszx_ay;
  szx_crtr:^tszx_crtr;
  szx_rom:^tszx_rom;
begin
getmem(pdatos,$30000);
ptemp:=pdatos;
getmem(szx_header,sizeof(tszx_header));
szx_header.magic:='ZXST';
szx_header.major_version:=1;
szx_header.minor_version:=2;
case main_vars.tipo_maquina of
  0:szx_header.tipo_maquina:=1;
  1:szx_header.tipo_maquina:=2;
  2:szx_header.tipo_maquina:=5;
  3:szx_header.tipo_maquina:=4;
  4:szx_header.tipo_maquina:=3;
  5:szx_header.tipo_maquina:=0;
end;
szx_header.flags:=0;
copymemory(ptemp,szx_header,8);inc(ptemp,8);longitud:=8;
freemem(szx_header);
getmem(szx_block,sizeof(tszx_block));
getmem(szx_crtr,sizeof(tszx_crtr));
szx_block.name:='CRTR';
szx_block.longitud:=36;
szx_crtr.creator:='DSP Emulator                    ';
szx_crtr.major_version:=$0001;
szx_crtr.minor_version:=$0600;
copymemory(ptemp,szx_block,8);inc(ptemp,8);longitud:=longitud+8;
copymemory(ptemp,szx_crtr,36);inc(ptemp,36);longitud:=longitud+36;
freemem(szx_crtr);
//Registros
szx_block.name:='Z80R';
szx_block.longitud:=37;
spec_z80_reg:=spec_z80.get_internal_r;
getmem(szx_regs,sizeof(tszx_regs));
fillchar(szx_regs^,sizeof(tszx_regs),0);
szx_regs.a:=spec_z80_reg.a;
if spec_z80_reg.f.s then szx_regs.flags:=szx_regs.flags or $80;
if spec_z80_reg.f.z then szx_regs.flags:=szx_regs.flags or $40;
if spec_z80_reg.f.bit5 then szx_regs.flags:=szx_regs.flags or $20;
if spec_z80_reg.f.h then szx_regs.flags:=szx_regs.flags or $10;
if spec_z80_reg.f.bit3 then szx_regs.flags:=szx_regs.flags or 8;
if spec_z80_reg.f.p_v then szx_regs.flags:=szx_regs.flags or 4;
if spec_z80_reg.f.n then szx_regs.flags:=szx_regs.flags or 2;
if spec_z80_reg.f.c then szx_regs.flags:=szx_regs.flags or 1;
szx_regs.bc:=spec_z80_reg.bc.w;
szx_regs.de:=spec_z80_reg.de.w;
szx_regs.hl:=spec_z80_reg.hl.w;
szx_regs.a2:=spec_z80_reg.a2;
if spec_z80_reg.f2.s then szx_regs.flags2:=szx_regs.flags2 or $80;
if spec_z80_reg.f2.z then szx_regs.flags2:=szx_regs.flags2 or $40;
if spec_z80_reg.f2.bit5 then szx_regs.flags2:=szx_regs.flags2 or $20;
if spec_z80_reg.f2.h then szx_regs.flags2:=szx_regs.flags2 or $10;
if spec_z80_reg.f2.bit3 then szx_regs.flags2:=szx_regs.flags2 or 8;
if spec_z80_reg.f2.p_v then szx_regs.flags2:=szx_regs.flags2 or 4;
if spec_z80_reg.f2.n then szx_regs.flags2:=szx_regs.flags2 or 2;
if spec_z80_reg.f2.c then szx_regs.flags2:=szx_regs.flags2 or 1;
szx_regs.bc2:=spec_z80_reg.bc2.w;
szx_regs.de2:=spec_z80_reg.de2.w;
szx_regs.hl2:=spec_z80_reg.hl2.w;
szx_regs.ix:=spec_z80_reg.ix.w;
szx_regs.iy:=spec_z80_reg.iy.w;
szx_regs.sp:=spec_z80_reg.sp;
szx_regs.pc:=spec_z80_reg.pc;
szx_regs.i:=spec_z80_reg.i;
szx_regs.r:=spec_z80_reg.r;
szx_regs.iff1:=byte(spec_z80_reg.iff1);
szx_regs.iff2:=byte(spec_z80_reg.iff2);
szx_regs.im:=spec_z80_reg.im;
szx_regs.estados_t:=spec_z80.contador;
szx_regs.estados_t_irq:=spectrum_irq_pos;
szx_regs.misc:=byte(spec_z80.halt) shl 1;
copymemory(ptemp,szx_block,8);inc(ptemp,8);longitud:=longitud+8;
copymemory(ptemp,szx_regs,37);inc(ptemp,37);longitud:=longitud+37;
freemem(szx_regs);
//Valores de la ULA
szx_block.name:='SPCR';
szx_block.longitud:=8;
getmem(szx_spcr,sizeof(tszx_spcr));
szx_spcr.borde:=borde.color;
szx_spcr.reg_7ffd:=old_7ffd;
szx_spcr.reg_1ffd:=old_1ffd;
copymemory(ptemp,szx_block,8);inc(ptemp,8);longitud:=longitud+8;
copymemory(ptemp,szx_spcr,8);inc(ptemp,8);longitud:=longitud+8;
freemem(szx_spcr);
//Memoria
szx_block.name:='RAMP';
getmem(szx_ramp,sizeof(tszx_ramp));
szx_ramp.flags:=1; //Comprimida
case main_vars.tipo_maquina of
  0:for f:=0 to 2 do begin //Spectrum 48k
         Compress_zlib(pointer(@memoria[$4000+(f*$4000)]),$4000,pointer(@szx_ramp.data[0]),cantidad);
         szx_ramp.numero:=spec48_ram[f];
         szx_block.longitud:=cantidad+3;
         copymemory(ptemp,szx_block,8);inc(ptemp,8);longitud:=longitud+8;
         copymemory(ptemp,szx_ramp,cantidad+3);inc(ptemp,cantidad+3);longitud:=longitud+cantidad+3;
    end;
  1,2,3,4:begin //Spectrum 128,+2,+2A o +3
      for f:=0 to 7 do begin
          case main_vars.tipo_maquina of
               1,4:Compress_zlib(pointer(@memoria_128k[f,0]),$4000,pointer(@szx_ramp.data[0]),cantidad);
               2,3:Compress_zlib(pointer(@memoria_3[f,0]),$4000,pointer(@szx_ramp.data[0]),cantidad);
          end;
          szx_ramp.numero:=f;
          szx_block.longitud:=cantidad+3;
          copymemory(ptemp,szx_block,8);inc(ptemp,8);longitud:=longitud+8;
          copymemory(ptemp,szx_ramp,cantidad+3);inc(ptemp,cantidad+3);longitud:=longitud+cantidad+3;
      end;
      //Y despues el AY
      szx_block.name:='AY'+char(0)+char(0);
      szx_block.longitud:=18;
      getmem(szx_ay,sizeof(tszx_ay));
      szx_ay.reg_fffd:=ay8910_0.get_control;
      for f:=0 to 15 do szx_ay.regs[f]:=ay8910_0.get_reg(f);
      szx_ay.flags:=0;
      copymemory(ptemp,szx_block,8);inc(ptemp,8);longitud:=longitud+8;
      copymemory(ptemp,szx_ay,18);inc(ptemp,18);longitud:=longitud+18;
      freemem(szx_ay);
    end;
  5:begin //Spectrum 16k
      Compress_zlib(pointer(@memoria[$4000]),$4000,pointer(@szx_rom.data[0]),cantidad);
      szx_ramp.numero:=5;
      szx_block.longitud:=cantidad+3;
      copymemory(ptemp,szx_block,8);inc(ptemp,8);longitud:=longitud+8;
      copymemory(ptemp,szx_ramp,cantidad+3);inc(ptemp,cantidad+3);longitud:=longitud+cantidad+3;
    end;
end;
//Si he modificado la ROM del spectrum la guardo
if rom_cambiada_48 then begin
  getmem(szx_rom,sizeof(tszx_rom));
  szx_block.name:='ROM'+char(0);
  szx_rom.flags:=1; //Comprimida!
  Compress_zlib(pointer(@memoria[0]),$4000,pointer(@szx_rom.data[0]),cantidad);
  szx_block.longitud:=cantidad+6;
  copymemory(ptemp,szx_block,8);inc(ptemp,8);longitud:=longitud+8;
  copymemory(ptemp,szx_rom,cantidad+6);inc(ptemp,cantidad+6);longitud:=longitud+cantidad+6;
  freemem(szx_rom);
end;
freemem(szx_ramp);
freemem(szx_block);
grabar_szx:=write_file(nombre,pdatos,longitud);
freemem(pdatos);
end;

//Spectrum .Z80
type
  tz80_regs=packed record
    a,flags:byte;
    bc,hl,pc,sp:word;
    i,r,misc:byte;
    de,bc2,de2,hl2:word;
    a2,flags2:byte;
    iy,ix:word;
    iff1,iff2,misc2:byte;
  end;
  tz80_ext=packed record
    long,pc:word;
    hw_mode,reg_7ffd,unused1,modify_hw,reg_fffd:byte;
    ay_regs:array[0..15] of byte;
    low_t:word;
    hi_t:byte;
    unused2:array[0..27] of byte;
    reg_1ffd:byte;
  end;
  tz80_ram=packed record
    longitud:word;
    numero:byte;
    datos:array[0..$3fff] of byte;
  end;

procedure descomprimir_z80(destino,origen:pbyte;var longitud:integer);
var
  pdestino,porigen:pbyte;
  g,contador,f:word;
  cont_final:word;
begin
pdestino:=destino;
porigen:=origen;
f:=0;
cont_final:=0;
while (f<longitud) do begin
        if porigen^=$ed then begin
                inc(porigen);
                f:=f+1;
                if porigen^=$ed then begin
                        inc(porigen);
                        f:=f+1;
                        contador:=porigen^;
                        inc(porigen);
                        f:=f+1;
                        for g:=1 to contador do begin
                                pdestino^:=porigen^;
                                inc(pdestino);
                                cont_final:=cont_final+1;
                        end;
                        inc(porigen);
                        f:=f+1;
                end else begin
                        pdestino^:=$ed;
                        inc(pdestino);
                        cont_final:=cont_final+1;
                end;
        end else begin
                pdestino^:=porigen^;
                inc(pdestino);
                inc(porigen);
                f:=f+1;
                cont_final:=cont_final+1;
        end;
end;
longitud:=cont_final;
end;

function abrir_z80(datos:pbyte;long:integer;es_dsp:boolean):boolean;
var
  longitud,contador:integer;
  f:byte;
  puntero:pointer;
  spec_z80_reg:npreg_z80;
  z80_regs:^tz80_regs;
  z80_ext:^tz80_ext;
  z80_ram:^tz80_ram;
begin
abrir_z80:=false;
spec_z80_reg:=spec_z80.get_internal_r;
getmem(z80_regs,sizeof(tz80_regs));
copymemory(z80_regs,datos,30);inc(datos,30);
longitud:=30;
if z80_regs.misc=$ff then z80_regs.misc:=1;
if (z80_regs.pc=0) then begin  //version 2 o 3
        getmem(z80_ext,sizeof(tz80_ext));
        copymemory(z80_ext,datos,2);  //si long 23 es version 2, si 54 o 55 es version 3
        copymemory(z80_ext,datos,z80_ext.long+2);
        inc(datos,z80_ext.long+2);inc(longitud,z80_ext.long+2);
        //Cambiar tipo de spectrum
        case z80_ext.hw_mode of
                0,1:if (z80_ext.modify_hw and $80)<>0 then spectrum_change_model(5) //Modo 16k
                      else spectrum_change_model(0); //Modo 48k
                //2:Samram
                3:if z80_ext.long=23 then spectrum_change_model(1) //Modo 128k
                    else if (z80_ext.modify_hw and $80)<>0 then spectrum_change_model(5) //Modo 16k
                          else spectrum_change_model(0); //Modo 48k
                4,5,6:if (z80_ext.modify_hw and $80)<>0 then spectrum_change_model(4) //Modo +2
                        else spectrum_change_model(1); //Modo 128K
                7,8:if (z80_ext.modify_hw and $80)<>0 then spectrum_change_model(3) //Modo +2A
                      else spectrum_change_model(2); //Modo +3
                12:spectrum_change_model(3); //Modo +2A
                13:spectrum_change_model(4); //Modo +2
                else begin
                  freemem(puntero);
                  MessageDlg('Modelo no de Spectrum soportado.'+chr(10)+chr(13)+'Spectrum model not supported.', mtInformation,[mbOk], 0);
                  exit;
                end;
        end;
        //Poner registros del audio
        case main_vars.tipo_maquina of
          1,4:begin
                    ay8910_0.reset;
                    for f:=0 to $f do ay8910_0.set_reg(f,z80_ext.ay_regs[f]);
                    ay8910_0.control(z80_ext.reg_fffd);
                    spec128_outbyte(z80_ext.reg_7ffd,$7ffd);
                  end;
          2,3:begin
                    ay8910_0.reset;
                    for f:=0 to $f do ay8910_0.set_reg(f,z80_ext.ay_regs[f]);
                    ay8910_0.control(z80_ext.reg_fffd);
                    spec3_outbyte(z80_ext.reg_7ffd,$7ffd);
                    if (z80_ext.long=55) then spec3_outbyte(z80_ext.reg_1ffd,$1ffd);
                  end;
        end;
        spec_z80_reg.pc:=z80_ext.pc;
        freemem(z80_ext);
        //Memoria
        getmem(z80_ram,sizeof(tz80_ram));
        while longitud<>long do begin
                copymemory(z80_ram,datos,2);
                copymemory(z80_ram,datos,z80_ram.longitud+3);
                inc(datos,z80_ram.longitud+3);inc(longitud,z80_ram.longitud+3);
                if z80_ram.longitud<>$FFFF then begin //esta comprimida
                  contador:=z80_ram.longitud;
                  getmem(puntero,$4000);
                  if es_dsp then Decompress_zlib(pointer(@z80_ram.datos[0]),$4000,pointer(puntero),contador)
                    else descomprimir_z80(puntero,@z80_ram.datos[0],contador);
                  if contador<>$4000 then exit;
                  copymemory(@z80_ram.datos[0],puntero,$4000);
                  freemem(puntero);
                end; //Si no esta comprimida copio directamente los datos...
                case main_vars.tipo_maquina of
                  0,5:case z80_ram.numero of //Spectrum 48k
                          0:copymemory(@memoria[0],@z80_ram.datos[0],$4000);
                          4:copymemory(@memoria[$8000],@z80_ram.datos[0],$4000);
                          5:copymemory(@memoria[$c000],@z80_ram.datos[0],$4000);
                          8:copymemory(@memoria[$4000],@z80_ram.datos[0],$4000);
                          else exit;
                      end;
                  1,4:case z80_ram.numero of //Spectrum 128k o Spectrum +2
                          0,1:copymemory(@memoria_128k[z80_ram.numero+8,0],@z80_ram.datos[0],$4000);
                          3..10:copymemory(@memoria_128k[z80_ram.numero-3,0],@z80_ram.datos[0],$4000);
                          else exit;
                      end;
                  2,3:case z80_ram.numero of //Spectrum +3 y Spectrum +2A
                          0,1:copymemory(@memoria_3[z80_ram.numero+8,0],@z80_ram.datos[0],$4000);
                          3..10:copymemory(@memoria_3[z80_ram.numero-3,0],@z80_ram.datos[0],$4000);
                          else exit;
                      end;
                end;
        end;
        freemem(z80_ram);
end else begin //version 1.XX solo 48k
        spectrum_change_model(0);
        spec_z80_reg.pc:=z80_regs.pc;
        if (z80_regs.misc and $20)<>0 then begin //comprimido
            contador:=long-30;
            if contador>$c000 then exit;
            descomprimir_z80(@memoria[$4000],datos,contador);
        end else copymemory(@memoria[$4000],datos,$c000); //Si no esta comprimida copio directamente los datos...
end;
spec_z80_reg.a:=z80_regs.a;
spec_z80_reg.f.s:=(z80_regs.flags and $80)<>0;
spec_z80_reg.f.z:=(z80_regs.flags and $40)<>0;
spec_z80_reg.f.bit5:=(z80_regs.flags and $20)<>0;
spec_z80_reg.f.h:=(z80_regs.flags and $10)<>0;
spec_z80_reg.f.bit3:=(z80_regs.flags and 8)<>0;
spec_z80_reg.f.p_v:=(z80_regs.flags and 4)<>0;
spec_z80_reg.f.n:=(z80_regs.flags and 2)<>0;
spec_z80_reg.f.c:=(z80_regs.flags and 1)<>0;
spec_z80_reg.bc.w:=z80_regs.bc;
spec_z80_reg.hl.w:=z80_regs.hl;
spec_z80_reg.sp:=z80_regs.sp;
spec_z80_reg.i:=z80_regs.i;
spec_z80_reg.r:=z80_regs.r and $7f;
if (z80_regs.misc and 1)<>0 then spec_z80_reg.r:=(spec_z80_reg.r or $80);
borde.color:=(z80_regs.misc and $0e) shr 1;
spec_z80_reg.de.w:=z80_regs.de;
spec_z80_reg.bc2.w:=z80_regs.bc2;
spec_z80_reg.de2.w:=z80_regs.de2;
spec_z80_reg.hl2.w:=z80_regs.hl2;
spec_z80_reg.a2:=z80_regs.a2;
spec_z80_reg.f2.s:=(z80_regs.flags2 and $80)<>0;
spec_z80_reg.f2.z:=(z80_regs.flags2 and $40)<>0;
spec_z80_reg.f2.bit5:=(z80_regs.flags2 and $20)<>0;
spec_z80_reg.f2.h:=(z80_regs.flags2 and $10)<>0;
spec_z80_reg.f2.bit3:=(z80_regs.flags2 and 8)<>0;
spec_z80_reg.f2.p_v:=(z80_regs.flags2 and 4)<>0;
spec_z80_reg.f2.n:=(z80_regs.flags2 and 2)<>0;
spec_z80_reg.f2.c:=(z80_regs.flags2 and 1)<>0;
spec_z80_reg.iy.w:=z80_regs.iy;
spec_z80_reg.ix.w:=z80_regs.ix;
spec_z80_reg.iff1:=(z80_regs.iff1<>0);
spec_z80_reg.iff2:=(z80_regs.iff2<>0);
spec_z80_reg.im:=z80_regs.misc2 and 3;
issue2:=(z80_regs.misc2 and 4)<>0;
freemem(z80_regs);
abrir_z80:=true;
end;

function comprimir_z80(origen,destino:pbyte):word;
var
  porigen,porigen_4,pdestino:pbyte;
  contador:word;
  long,total:word;
  base:byte;
begin
porigen:=origen;
pdestino:=destino;
total:=0;
long:=0;
while total<$4000 do begin
  base:=porigen^;  //primer byte
  porigen_4:=porigen;
  inc(porigen);
  inc(total);
  contador:=1;
  if (porigen^=base) then begin
    while ((porigen^=base) and (contador<>255) and (total<>16384)) do begin
      inc(porigen);
      inc(contador);
      inc(total);
    end;
    if ((contador>4) or (base=$ed)) then begin
      pdestino^:=$ed;inc(pdestino);
      pdestino^:=$ed;inc(pdestino);
      pdestino^:=contador;inc(pdestino);
      pdestino^:=base;inc(pdestino);
      inc(long,4);
    end else begin
        copymemory(pdestino,porigen_4,contador);
        inc(pdestino,contador);
        inc(long,contador);
    end;
  end else begin   //son bytes sueltos
    pdestino^:=base;
    inc(pdestino);
    inc(long);
    if base=$ed then begin  //si el byte es $ed hay que meter el siguiente, para no meter tres ed seguidos!!!
      pdestino^:=porigen^;
      inc(total);
      inc(long);
      inc(pdestino);
      inc(porigen);
    end;
  end;
  if total=$3fff then begin  //si estoy en el ultimo byte no puedo comprimir
      pdestino^:=porigen^;
      inc(total);
      inc(long);
  end;
end;  //del while
if long>$4000 then begin
  copymemory(destino,origen,$4000);
  comprimir_z80:=$ffff;
end else comprimir_z80:=long;
end;

function grabar_z80(nombre:string;es_dsp:boolean):boolean;
const
  spec48_ram:array[0..2] of byte=(8,4,5);
var
  r,long:integer;
  f:byte;
  pdatos,ptemp:pbyte;
  spec_z80_reg:npreg_z80;
  z80_regs:^tz80_regs;
  z80_ext:^tz80_ext;
  z80_ram:^tz80_ram;
begin
grabar_z80:=false;
getmem(pdatos,$30000);
ptemp:=pdatos;
spec_z80_reg:=spec_z80.get_internal_r;
getmem(z80_regs,sizeof(tz80_regs));
getmem(z80_ext,sizeof(tz80_ext));
fillchar(z80_regs^,sizeof(tz80_regs),0);
fillchar(z80_ext^,sizeof(tz80_ext),0);
z80_regs.a:=spec_z80_reg.a;
if spec_z80_reg.f.s then z80_regs.flags:=z80_regs.flags or $80;
if spec_z80_reg.f.z then z80_regs.flags:=z80_regs.flags or $40;
if spec_z80_reg.f.bit5 then z80_regs.flags:=z80_regs.flags or $20;
if spec_z80_reg.f.h then z80_regs.flags:=z80_regs.flags or $10;
if spec_z80_reg.f.bit3 then z80_regs.flags:=z80_regs.flags or 8;
if spec_z80_reg.f.p_v then z80_regs.flags:=z80_regs.flags or 4;
if spec_z80_reg.f.n then z80_regs.flags:=z80_regs.flags or 2;
if spec_z80_reg.f.c then z80_regs.flags:=z80_regs.flags or 1;
z80_regs.bc:=spec_z80_reg.bc.w;
z80_regs.hl:=spec_z80_reg.hl.w;
z80_regs.sp:=spec_z80_reg.sp;
z80_regs.i:=spec_z80_reg.i;
z80_regs.r:=spec_z80_reg.r;
z80_regs.misc:=(borde.color shl 1) or ((spec_z80_reg.r and $80) shr 7);
z80_regs.de:=spec_z80_reg.de.w;
z80_regs.bc2:=spec_z80_reg.bc2.w;
z80_regs.de2:=spec_z80_reg.de2.w;
z80_regs.hl2:=spec_z80_reg.hl2.w;
z80_regs.a2:=spec_z80_reg.a2;
if spec_z80_reg.f2.s then z80_regs.flags2:=z80_regs.flags2 or $80;
if spec_z80_reg.f2.z then z80_regs.flags2:=z80_regs.flags2 or $40;
if spec_z80_reg.f2.bit5 then z80_regs.flags2:=z80_regs.flags2 or $20;
if spec_z80_reg.f2.h then z80_regs.flags2:=z80_regs.flags2 or $10;
if spec_z80_reg.f2.bit3 then z80_regs.flags2:=z80_regs.flags2 or 8;
if spec_z80_reg.f2.p_v then z80_regs.flags2:=z80_regs.flags2 or 4;
if spec_z80_reg.f2.n then z80_regs.flags2:=z80_regs.flags2 or 2;
if spec_z80_reg.f2.c then z80_regs.flags2:=z80_regs.flags2 or 1;
z80_regs.iy:=spec_z80_reg.iy.w;
z80_regs.ix:=spec_z80_reg.ix.w;
z80_regs.iff1:=byte(spec_z80_reg.iff1);
z80_regs.iff2:=byte(spec_z80_reg.iff2);
z80_regs.misc2:=spec_z80_reg.im or (byte(issue2) shl 2);
z80_ext.long:=55; //Grabo snapshot version 3
z80_ext.pc:=spec_z80_reg.pc;
case main_vars.tipo_maquina of
  0,5:z80_ext.hw_mode:=0;
  1,4:begin
      z80_ext.hw_mode:=4;
      z80_ext.reg_7ffd:=old_7ffd;
      z80_ext.reg_fffd:=ay8910_0.get_control;
      for f:=0 to 15 do z80_ext.ay_regs[f]:=ay8910_0.get_reg(f);
    end;
  2,3:begin
      z80_ext.hw_mode:=7;
      z80_ext.reg_7ffd:=old_7ffd;
      z80_ext.reg_fffd:=ay8910_0.get_control;
      z80_ext.reg_1ffd:=old_1ffd;
      for f:=0 to 15 do z80_ext.ay_regs[f]:=ay8910_0.get_reg(f);
    end;
end;
if ((main_vars.tipo_maquina=3) or (main_vars.tipo_maquina=4) or (main_vars.tipo_maquina=5)) then z80_ext.modify_hw:=$80;
copymemory(ptemp,z80_regs,30);inc(ptemp,30);
copymemory(ptemp,z80_ext,57);inc(ptemp,57);
long:=87;
freemem(z80_regs);
freemem(z80_ext);
getmem(z80_ram,sizeof(tz80_ram));
case main_vars.tipo_maquina of
    0:begin
          for f:=0 to 2 do begin
            if es_dsp then Compress_zlib(pointer(@memoria[$4000+(f*$4000)]),$4000,pointer(@z80_ram.datos[0]),r)
              else r:=comprimir_z80(@memoria[$4000+(f*$4000)],@z80_ram.datos[0]);
            z80_ram.longitud:=r;
            if r=$ffff then r:=$4000;
            z80_ram.numero:=spec48_ram[f];
            copymemory(ptemp,z80_ram,r+3);inc(ptemp,r+3);inc(long,r+3);
          end;
          if rom_cambiada_48 then begin
             if es_dsp then Compress_zlib(pointer(@memoria[0]),$4000,pointer(@z80_ram.datos[0]),r)
              else r:=comprimir_z80(@memoria[0],@z80_ram.datos[0]);
            z80_ram.longitud:=r;
            if r=$ffff then r:=$4000;
            z80_ram.numero:=0;
            copymemory(ptemp,z80_ram,r+3);inc(ptemp,r+3);inc(long,r+3);
          end;
      end;
    1,4:for f:=0 to 7 do begin
        if es_dsp then Compress_zlib(pointer(@memoria_128k[f,0]),$4000,pointer(@z80_ram.datos[0]),r)
          else r:=comprimir_z80(@memoria_128k[f,0],@z80_ram.datos[0]);
        z80_ram.longitud:=r;
        if r=$ffff then r:=$4000;
        z80_ram.numero:=f-3;
        copymemory(ptemp,z80_ram,r+3);inc(ptemp,r+3);inc(long,r+3);
      end;
    2,3:for f:=0 to 7 do begin
        if es_dsp then Compress_zlib(pointer(@memoria_3[f,0]),$4000,pointer(@z80_ram.datos[0]),r)
          else r:=comprimir_z80(@memoria_3[f,0],@z80_ram.datos[0]);
        z80_ram.longitud:=r;
        if r=$ffff then r:=$4000;
        z80_ram.numero:=f-3;
        copymemory(ptemp,z80_ram,r+3);inc(ptemp,r+3);inc(long,r+3);
      end;
     5:begin
        if es_dsp then Compress_zlib(pointer(@memoria[$4000]),$4000,pointer(@z80_ram.datos[0]),r)
           else r:=comprimir_z80(@memoria[$4000],@z80_ram.datos[0]);
        z80_ram.longitud:=r;
        if r=$ffff then r:=$4000;
        z80_ram.numero:=5;
        copymemory(ptemp,z80_ram,r+3);inc(ptemp,r+3);inc(long,r+3);
      end;
end;
freemem(z80_ram);
grabar_z80:=write_file(nombre,pdatos,long);
freemem(pdatos);
end;

//Amstrad CPC .SNA
type
  tcpc_sna=packed record
      magic:array[0..7] of ansichar;
      unused1:array[0..7] of byte;
      version,flags,a:byte;
      bc,de,hl:word;
      r,i,iff1,iff2:byte;
      ix,iy,sp,pc:word;
      im,flags2,a2:byte;
      bc2,de2,hl2:word;
      ga_pen:byte;
      ga_pal:array[0..16] of byte;
      ga_conf,ram_config,crt_index:byte;
      crt_regs:array[0..17] of byte;
      rom_config,ppi_a,ppi_b,ppi_c,ppi_control,ay_control:byte;
      ay_regs:array[0..15] of byte;
      mem_size:word;
      hw_type,int_number:byte;
      multimode:array[0..5] of byte;
      unused2:array[0..$3c] of byte;
      ga_lines_sync,ga_lines_count,irq:byte;
      unused3:array[0..$4a] of byte;
    end;

function grabar_amstrad_sna(nombre:string):boolean;
var
  f:byte;
  long:dword;
  pdatos,ptemp:pbyte;
  main_z80_reg:npreg_z80;
  cpc_sna:^tcpc_sna;
begin
grabar_amstrad_sna:=false;
main_z80_reg:=main_z80.get_internal_r;
getmem(pdatos,$30000);
ptemp:=pdatos;
getmem(cpc_sna,sizeof(tcpc_sna));
fillchar(cpc_sna^,sizeof(tcpc_sna),0);
cpc_sna.magic:='MV - SNA';
cpc_sna.version:=3;
if main_z80_reg.f.s then cpc_sna.flags:=cpc_sna.flags or $80;
if main_z80_reg.f.z then cpc_sna.flags:=cpc_sna.flags or $40;
if main_z80_reg.f.bit5 then cpc_sna.flags:=cpc_sna.flags or $20;
if main_z80_reg.f.h then cpc_sna.flags:=cpc_sna.flags or $10;
if main_z80_reg.f.bit3 then cpc_sna.flags:=cpc_sna.flags or $8;
if main_z80_reg.f.p_v then cpc_sna.flags:=cpc_sna.flags or $4;
if main_z80_reg.f.n then cpc_sna.flags:=cpc_sna.flags or $2;
if main_z80_reg.f.c then cpc_sna.flags:=cpc_sna.flags or $1;
cpc_sna.a:=main_z80_reg.a;
cpc_sna.bc:=main_z80_reg.bc.w;
cpc_sna.de:=main_z80_reg.de.w;
cpc_sna.hl:=main_z80_reg.hl.w;
cpc_sna.r:=main_z80_reg.r;
cpc_sna.i:=main_z80_reg.i;
cpc_sna.iff1:=byte(main_z80_reg.iff1);
cpc_sna.iff2:=byte(main_z80_reg.iff2);
cpc_sna.ix:=main_z80_reg.ix.w;
cpc_sna.iy:=main_z80_reg.iy.w;
cpc_sna.sp:=main_z80_reg.sp;
cpc_sna.pc:=main_z80_reg.pc;
cpc_sna.im:=main_z80_reg.im;
if main_z80_reg.f2.s then cpc_sna.flags2:=cpc_sna.flags2 or $80;
if main_z80_reg.f2.z then cpc_sna.flags2:=cpc_sna.flags2 or $40;
if main_z80_reg.f2.bit5 then cpc_sna.flags2:=cpc_sna.flags2 or $20;
if main_z80_reg.f2.h then cpc_sna.flags2:=cpc_sna.flags2 or $10;
if main_z80_reg.f2.bit3 then cpc_sna.flags2:=cpc_sna.flags2 or $8;
if main_z80_reg.f2.p_v then cpc_sna.flags2:=cpc_sna.flags2 or $4;
if main_z80_reg.f2.n then cpc_sna.flags2:=cpc_sna.flags2 or $2;
if main_z80_reg.f2.c then cpc_sna.flags2:=cpc_sna.flags2 or $1;
cpc_sna.a2:=main_z80_reg.a2;
cpc_sna.bc2:=main_z80_reg.bc2.w;
cpc_sna.de2:=main_z80_reg.de2.w;
cpc_sna.hl2:=main_z80_reg.hl2.w;
//GA
cpc_sna.ga_pen:=cpc_ga.pen;
copymemory(@cpc_sna.ga_pal,@cpc_ga.pal[0],17);
cpc_sna.ga_conf:=cpc_ga.video_mode+(byte(not cpc_ga.rom_low) shl 2)+(byte(not cpc_ga.rom_high) shl 3);
//RAM
cpc_sna.ram_config:=cpc_ga.marco_latch;
//CRT
cpc_sna.crt_index:=cpc_crt.reg;
copymemory(@cpc_sna.crt_regs,@cpc_crt.regs[0],18);
//ROM
if cpc_ga.rom_selected=9 then cpc_sna.rom_config:=0
  else cpc_sna.rom_config:=7;
//PIA a,b,c,control
cpc_sna.ppi_a:=cpc_ppi.port_a_read_latch;
cpc_sna.ppi_c:=cpc_ppi.port_c_write_latch;
cpc_sna.ppi_control:=pia_8255[0].control;
//AY
cpc_sna.ay_control:=ay8910_0.get_control;
for f:=0 to $f do cpc_sna.ay_regs[f]:=ay8910_0.get_reg(f);
case main_vars.tipo_maquina of
  7,8:cpc_sna.mem_size:=64;
    9:cpc_sna.mem_size:=128;
end;
cpc_sna.hw_type:=main_vars.tipo_maquina-7;
cpc_sna.ga_lines_sync:=cpc_ga.lines_sync;
cpc_sna.ga_lines_count:=cpc_ga.lines_count;
if main_z80.pedir_irq<>CLEAR_LINE then cpc_sna.irq:=1;
copymemory(ptemp,cpc_sna,$100);inc(ptemp,$100);long:=$100;
freemem(cpc_sna);
//Datos
case main_vars.tipo_maquina of
  7,8:for f:=0 to 3 do begin
          copymemory(ptemp,@cpc_mem[f,0],$4000);
          inc(ptemp,$4000);
          inc(long,$4000);
      end;
  9:for f:=0 to 7 do begin
          copymemory(ptemp,@cpc_mem[f,0],$4000);
          inc(ptemp,$4000);
          inc(long,$4000);
    end;
end;
grabar_amstrad_sna:=write_file(nombre,pdatos,long);
freemem(pdatos);
end;

function abrir_sna_cpc(data:pbyte;longitud:integer):boolean;
var
  f:byte;
  main_z80_reg:npreg_z80;
  cpc_sna:^tcpc_sna;

procedure init_rom_amstrad;
var
  memoria_temp:array[0..$7fff] of byte;
begin
case main_vars.tipo_maquina of
  7:if not(cargar_roms(@memoria_temp[0],@cpc464_rom,'cpc464.zip',1)) then exit;
  8:begin
      if not(cargar_roms(@cpc_mem[10,0],@ams_rom,'cpc664.zip',1)) then exit;
      if not(cargar_roms(@memoria_temp[0],@cpc646_rom,'cpc664.zip',1)) then exit;
  end;
  9:begin
      if not(cargar_roms(@cpc_mem[10,0],@ams_rom,'cpc6128.zip',1)) then exit;
      if not(cargar_roms(@memoria_temp[0],@cpc6128_rom,'cpc6128.zip',1)) then exit;
  end;
end;
copymemory(@cpc_mem[8,0],@memoria_temp[0],$4000);
copymemory(@cpc_mem[9,0],@memoria_temp[$4000],$4000);
end;

begin
abrir_sna_cpc:=false;
getmem(cpc_sna,sizeof(tcpc_sna));
copymemory(cpc_sna,data,$100);
inc(data,$100);
if (cpc_sna.magic)<>'MV - SNA' then exit;
main_z80_reg:=main_z80.get_internal_r;
main_z80_reg.f.s:=(cpc_sna.flags and $80)<>0;
main_z80_reg.f.z:=(cpc_sna.flags and $40)<>0;
main_z80_reg.f.bit5:=(cpc_sna.flags and $20)<>0;
main_z80_reg.f.h:=(cpc_sna.flags and $10)<>0;
main_z80_reg.f.bit3:=(cpc_sna.flags and 8)<>0;
main_z80_reg.f.p_v:=(cpc_sna.flags and 4)<>0;
main_z80_reg.f.n:=(cpc_sna.flags and 2)<>0;
main_z80_reg.f.c:=(cpc_sna.flags and 1)<>0;
main_z80_reg.a:=cpc_sna.a;
main_z80_reg.bc.w:=cpc_sna.bc;
main_z80_reg.de.w:=cpc_sna.de;
main_z80_reg.hl.w:=cpc_sna.hl;
main_z80_reg.r:=cpc_sna.r;
main_z80_reg.i:=cpc_sna.i;
main_z80_reg.iff1:=cpc_sna.iff1<>0;
main_z80_reg.iff2:=cpc_sna.iff2<>0;
main_z80_reg.ix.w:=cpc_sna.ix;
main_z80_reg.iy.w:=cpc_sna.iy;
main_z80_reg.sp:=cpc_sna.sp;
main_z80_reg.pc:=cpc_sna.pc;
main_z80_reg.im:=cpc_sna.im;
main_z80_reg.f2.s:=(cpc_sna.flags2 and $80)<>0;
main_z80_reg.f2.z:=(cpc_sna.flags2 and $40)<>0;
main_z80_reg.f2.bit5:=(cpc_sna.flags2 and $20)<>0;
main_z80_reg.f2.h:=(cpc_sna.flags2 and $10)<>0;
main_z80_reg.f2.bit3:=(cpc_sna.flags2 and 8)<>0;
main_z80_reg.f2.p_v:=(cpc_sna.flags2 and 4)<>0;
main_z80_reg.f2.n:=(cpc_sna.flags2 and 2)<>0;
main_z80_reg.f2.c:=(cpc_sna.flags2 and 1)<>0;
main_z80_reg.a2:=cpc_sna.a2;
main_z80_reg.bc2.w:=cpc_sna.bc2;
main_z80_reg.de2.w:=cpc_sna.de2;
main_z80_reg.hl2.w:=cpc_sna.hl2;
//GA
cpc_ga.pen:=cpc_sna.ga_pen;
copymemory(@cpc_ga.pal[0],@cpc_sna.ga_pal[0],17);
write_ga($80+(cpc_sna.ga_conf and $3f));
//RAM
copymemory(@cpc_ga.marco[0],@ram_banks[(cpc_sna.ram_config and 7),0],4);
//CRT
cpc_crt.vsync_cont:=0;
cpc_crt.reg:=cpc_sna.crt_index and $1f;
for f:=0 to 17 do cpc_crt.regs[f]:=cpc_sna.crt_regs[f];
cpc_calc_crt;
cpc_calcular_dir_scr;
//ROM
cpc_outbyte(cpc_sna.rom_config,$df00);
//PIA a,b,c,control
cpc_ppi.port_a_read_latch:=cpc_sna.ppi_a;
//Port b nada...
port_c_write(cpc_sna.ppi_c);
cpc_outbyte(cpc_sna.ppi_control,$f782);
//PSG control,reg
for f:=0 to $f do ay8910_0.set_reg(f,cpc_sna.ay_regs[f]);
ay8910_0.control(cpc_sna.ay_control);
case cpc_sna.mem_size of
  64:for f:=0 to 3 do begin
         copymemory(@cpc_mem[f,0],data,$4000);
         inc(data,$4000);
     end;
  128:for f:=0 to 7 do begin
         copymemory(@cpc_mem[f,0],data,$4000);
         inc(data,$4000);
      end;
  else exit; //Si hay mas memoria, es otro modelo --> No soportado
end;
case cpc_sna.version of
  1:begin
      case cpc_sna.mem_size of
           64:begin
                 main_vars.tipo_maquina:=8;
                 llamadas_maquina.caption:='Amstrad CPC 664';
           end;
           128:begin
                 main_vars.tipo_maquina:=9;
                 llamadas_maquina.caption:='Amstrad CPC 6128';
           end;
      end;
      init_rom_amstrad;
    end;
  2,3:begin
      case cpc_sna.hw_type of
        0:begin
          main_vars.tipo_maquina:=7;
          llamadas_maquina.caption:='Amstrad CPC 464';
        end;
        1:begin
          main_vars.tipo_maquina:=8;
          llamadas_maquina.caption:='Amstrad CPC 664';
        end;
        2:begin
          main_vars.tipo_maquina:=9;
          llamadas_maquina.caption:='Amstrad CPC 6128';
        end;
        else exit; //Modelo no soportado
      end;
      init_rom_amstrad;
      if cpc_sna.version=3 then begin
        cpc_ga.lines_sync:=cpc_sna.ga_lines_sync;
        cpc_ga.lines_count:=cpc_sna.ga_lines_count;
        if cpc_sna.irq<>0 then main_z80.pedir_irq:=PULSE_LINE
           else main_z80.pedir_irq:=CLEAR_LINE;
      end;
    end;
end;
freemem(cpc_sna);
abrir_sna_cpc:=true;
end;

//Coleco .CSN o .DSP
type
  tcoleco_header=packed record
      magic:array[0..3] of ansichar;
      version:word;
      unused:array[0..3] of byte;
  end;

  tcoleco_block=packed record
      nombre:array[0..3] of ansichar;
      longitud:dword;
      unused:array[0..1] of byte;
  end;

function abrir_coleco_snapshot(data:pbyte;long:dword):boolean;
type
  ttms_v1=record
      regs:array[0..7] of byte;
      colour,pattern,nametbl,spriteattribute,spritepattern,colourmask,patternmask,nAddr:word;
      latch,nVR,status_reg,nFGColor,nBGColor,wkey:byte;
      int:boolean;
      TMS9918A_VRAM_SIZE:word;
      memory:array[0..$3FFF] of byte;
      dBackMem:array[0..$FFFF] of byte;
      IRQ_Handler:procedure(int:boolean);
      pant:byte;
  end;
  tz80_v1=packed record
      ppc,pc,sp:word;
      bc,de,hl:word;
      bc2,de2,hl2:word;
      ix,iy:word;
      iff1,iff2,halt:boolean;
      pedir_irq,pedir_nmi,nmi_state:byte;
      a,a2,i,r:byte;
      f,f2:array[0..7] of boolean;
      contador:dword;
      im,im2_lo,im0:byte;
      daisy,opcode,after_ei:boolean;
      numero_cpu:byte;
      tframes:single;
      enabled:boolean;
      estados_demas:word
  end;
  tz80_v2=packed record
        ppc,pc,sp:word;
        bc,de,hl:word;
        bc2,de2,hl2:word;
        ix,iy:word;
        iff1,iff2:boolean;
        a,a2,i,r:byte;
        f,f2:band_z80;
        im,unused1:byte;
  end;
  tz80_v2_ext=packed record
      halt:boolean;
      pedir_irq,pedir_nmi:byte;
      contador:dword;
      im2_lo,im0:byte;
  end;
var
  ptemp,ptemp2,ptemp3:pbyte;
  longitud,descomprimido:integer;
  main_z80_reg:npreg_z80;
  tms_v1:^ttms_v1;
  z80_v1:^tz80_v1;
  z80_v2:^tz80_v2;
  z80_v2_ext:^tz80_v2_ext;
  coleco_header:^tcoleco_header;
  coleco_block:^tcoleco_block;
begin
abrir_coleco_snapshot:=false;
getmem(coleco_header,sizeof(tcoleco_header));
copymemory(coleco_header,data,10);
//Todos las cabeceras tienen 10bytes
if coleco_header.magic<>'CLSN' then exit;
reset_coleco;
if ((coleco_header.version<>1) and (coleco_header.version<>2) and (coleco_header.version<>$1002) and (coleco_header.version<>$220)) then begin
   freemem(coleco_header);
   exit;
end;
getmem(coleco_block,sizeof(tcoleco_block));
inc(data,10);
longitud:=10;
while longitud<long do begin
  copymemory(coleco_block,data,10);
  inc(data,10);inc(longitud,10);
  if coleco_block.nombre='CRAM' then begin
    getmem(ptemp,$e000);
    decompress_zlib(data,coleco_block.longitud,pointer(ptemp),descomprimido);
    copymemory(@memoria[$2000],ptemp,$e000);
    freemem(ptemp);
  end;
  if coleco_block.nombre='Z80R' then begin
    case coleco_header.version of
     $1:begin //Version 1.00
          getmem(z80_v1,sizeof(tz80_v1));
          copymemory(z80_v1,data,68);
          main_z80_reg:=main_z80.get_internal_r;
          main_z80_reg.ppc:=z80_v1.ppc;
          main_z80_reg.pc:=z80_v1.pc;
          main_z80_reg.sp:=z80_v1.sp;
          main_z80_reg.bc.w:=z80_v1.bc;
          main_z80_reg.de.w:=z80_v1.de;
          main_z80_reg.hl.w:=z80_v1.hl;
          main_z80_reg.bc2.w:=z80_v1.bc2;
          main_z80_reg.de2.w:=z80_v1.de2;
          main_z80_reg.hl2.w:=z80_v1.hl2;
          main_z80_reg.ix.w:=z80_v1.ix;
          main_z80_reg.iy.w:=z80_v1.iy;
          main_z80_reg.iff1:=z80_v1.iff1;
          main_z80_reg.iff2:=z80_v1.iff2;
          main_z80.halt:=z80_v1.halt;
          main_z80.pedir_irq:=z80_v1.pedir_irq;
          main_z80.pedir_nmi:=z80_v1.pedir_nmi;
          {main_z80.nmi_state:=(ptemp^<>0);}
          main_z80_reg.a:=z80_v1.a;
          main_z80_reg.a2:=z80_v1.a2;
          main_z80_reg.i:=z80_v1.i;
          main_z80_reg.r:=z80_v1.r;
          main_z80_reg.f.s:=z80_v1.f[7];
          main_z80_reg.f.z:=z80_v1.f[6];
          main_z80_reg.f.bit5:=z80_v1.f[5];
          main_z80_reg.f.h:=z80_v1.f[4];
          main_z80_reg.f.bit3:=z80_v1.f[3];
          main_z80_reg.f.p_v:=z80_v1.f[2];
          main_z80_reg.f.n:=z80_v1.f[1];
          main_z80_reg.f.c:=z80_v1.f[0];
          main_z80_reg.f2.s:=z80_v1.f2[7];
          main_z80_reg.f2.z:=z80_v1.f2[6];
          main_z80_reg.f2.bit5:=z80_v1.f2[5];
          main_z80_reg.f2.h:=z80_v1.f2[4];
          main_z80_reg.f2.bit3:=z80_v1.f2[3];
          main_z80_reg.f2.p_v:=z80_v1.f2[2];
          main_z80_reg.f2.n:=z80_v1.f2[1];
          main_z80_reg.f2.c:=z80_v1.f2[0];
          main_z80.contador:=z80_v1.contador;
          main_z80_reg.im:=z80_v1.im;
          main_z80.im2_lo:=z80_v1.im2_lo;
          main_z80.im0:=z80_v1.im0;
          freemem(z80_v1);
      end;
      $2:begin //Version 2.00
          main_z80_reg:=main_z80.get_internal_r;
          ptemp:=data;
          getmem(z80_v2,sizeof(tz80_v2));
          copymemory(z80_v2,ptemp,46);
          inc(ptemp,46);
          copymemory(main_z80_reg,z80_v2,45);
          getmem(z80_v2_ext,sizeof(tz80_v2_ext));
          copymemory(z80_v2_ext,ptemp,9);
          main_z80.halt:=z80_v2_ext.halt;
          main_z80.pedir_irq:=z80_v2_ext.pedir_irq;
          main_z80.pedir_nmi:=z80_v2_ext.pedir_nmi;
          main_z80.contador:=z80_v2_ext.contador;
          main_z80.im2_lo:=z80_v2_ext.im2_lo;
          main_z80.im0:=z80_v2_ext.im0;
          freemem(z80_v2_ext);
          freemem(z80_v2);
        end;
     $1002:begin //Version 2.10
          ptemp:=data;
          getmem(ptemp2,60);
          ptemp3:=ptemp2;
          copymemory(ptemp3,ptemp,45);
          inc(ptemp,46);inc(ptemp3,45);
          copymemory(ptemp3,ptemp,12);
          main_z80.load_snapshot(ptemp2);
          freemem(ptemp2);
        end;
      $220:main_z80.load_snapshot(data); //Version 2.20
    end;
  end;
  if coleco_block.nombre='TMSR' then begin
    getmem(ptemp,sizeof(ttms_v1));
    decompress_zlib(data,coleco_block.longitud,pointer(ptemp),descomprimido);
    case coleco_header.version of
  $1,$2,$1002:begin
            getmem(tms_v1,sizeof(ttms_v1));
            copymemory(tms_v1,ptemp,sizeof(ttms_v1));
            copymemory(@tms.regs,@tms_v1.regs[0],8);
            tms.color:=tms_v1.colour;
            tms.pattern:=tms_v1.pattern;
            tms.nametbl:=tms_v1.nametbl;
            tms.spriteattribute:=tms_v1.spriteattribute;
            tms.spritepattern:=tms_v1.spritepattern;
            tms.colormask:=tms_v1.colourmask;
            tms.patternmask:=tms_v1.patternmask;
            tms.addr:=tms_v1.nAddr;
            tms.status_reg:=tms_v1.status_reg;
            tms.fgcolor:=tms_v1.nFGColor;
            tms.bgcolor:=tms_v1.nbgcolor;
            tms.int:=tms_v1.int;
            tms.TMS9918A_VRAM_SIZE:=tms_v1.TMS9918A_VRAM_SIZE;
            copymemory(@tms.memory[0],@tms_v1.memory[0],$4000);
            freemem(tms_v1);
        end;
      $220:copymemory(TMS,ptemp,descomprimido);
    end;
    freemem(ptemp);
    tms.IRQ_Handler:=coleco_interrupt;
    tms.pant:=1;
    if tms.bgcolor=0 then paleta[0]:=0
      else paleta[0]:=paleta[tms.bgcolor];
  end;
  if coleco_block.nombre='7649' then sn_76496_0.load_snapshot(data);
  inc(data,coleco_block.longitud);inc(longitud,coleco_block.longitud);
end;
freemem(coleco_header);
freemem(coleco_block);
abrir_coleco_snapshot:=true;
end;

function grabar_coleco_snapshot(nombre:string):boolean;
var
  longitud,comprimido:integer;
  coleco_header:^tcoleco_header;
  coleco_block:^tcoleco_block;
  pdata,ptemp,ptemp2:pbyte;
begin
grabar_coleco_snapshot:=false;
getmem(coleco_header,sizeof(tcoleco_header));
fillchar(coleco_header^,sizeof(tcoleco_header),0);
coleco_header.magic:='CLSN';
coleco_header.version:=$220;
getmem(pdata,$30000);
ptemp:=pdata;
//Cabecera
copymemory(ptemp,coleco_header,10);
inc(ptemp,10);longitud:=10;
getmem(coleco_block,sizeof(tcoleco_block));
fillchar(coleco_block^,sizeof(tcoleco_block),0);
//Coleco RAM
coleco_block.nombre:='CRAM';
ptemp2:=ptemp;
inc(ptemp2,10);
compress_zlib(@memoria[$2000],$e000,ptemp2,comprimido);
coleco_block.longitud:=comprimido;
copymemory(ptemp,coleco_block,10);
inc(ptemp,10);inc(longitud,10);
inc(ptemp,comprimido);inc(longitud,comprimido);
//TMS9918
fillchar(coleco_block^,sizeof(tcoleco_block),0);
coleco_block.nombre:='TMSR';
ptemp2:=ptemp;
inc(ptemp2,10);
compress_zlib(tms,sizeof(TTMS99XX),ptemp2,comprimido);
coleco_block.longitud:=comprimido;
copymemory(ptemp,coleco_block,10);
inc(ptemp,10);inc(longitud,10);
inc(ptemp,comprimido);inc(longitud,comprimido);
//Z80
fillchar(coleco_block^,sizeof(tcoleco_block),0);
coleco_block.nombre:='Z80R';
ptemp2:=ptemp;
inc(ptemp2,10);
comprimido:=main_z80.save_snapshot(ptemp2);
coleco_block.longitud:=comprimido;
copymemory(ptemp,coleco_block,10);
inc(ptemp,10);inc(longitud,10);
inc(ptemp,comprimido);inc(longitud,comprimido);
//Sound
fillchar(coleco_block^,sizeof(tcoleco_block),0);
coleco_block.nombre:='7649';
ptemp2:=ptemp;
inc(ptemp2,10);
comprimido:=sn_76496_0.save_snapshot(ptemp2);
coleco_block.longitud:=comprimido;
copymemory(ptemp,coleco_block,10);
inc(ptemp,10);inc(longitud,10);
inc(ptemp,comprimido);inc(longitud,comprimido);
//Final
freemem(coleco_header);
freemem(coleco_block);
grabar_coleco_snapshot:=write_file(nombre,pdata,longitud);
freemem(pdata);
end;

end.
