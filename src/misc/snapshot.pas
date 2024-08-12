unit snapshot;

interface
uses {$IFDEF windows}windows,{$ENDIF}
     sysutils,spectrum_misc,ay_8910,dialogs,nz80,z80_sp,file_engine,
     init_games,ppi8255,tms99xx,pal_engine,sn_76496,m6502,misc_functions,
     i2cmem,lenguaje,sg1000,sms,sega_gg,sega_vdp,super_cassette_vision,upd1771,
     upd7810,chip8_hw,n2a03,nes_ppu,nes_mappers,gb,gb_mappers,gb_sound,lr35902;

type
  tmain_block=packed record
      nombre:array[0..3] of ansichar;
      longitud:dword;
      unused:array[0..1] of byte;
  end;
  tmain_header=packed record
      magic:array[0..3] of ansichar;
      version:word;
      unused:array[0..3] of byte;
  end;
  //Spectrum
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
  //SZX
type
  tszx_header=packed record
    magic:array[0..3] of ansichar;
    major_version,minor_version,tipo_maquina,flags:byte;
  end;
  tszx_block=packed record
    name:array[0..3] of ansichar;
    longitud:dword;
  end;
  tszx_ramp=packed record
    flags:word;
    numero:byte;
    data:array[0..$3fff] of byte;
  end;

const
  SIZE_MH=sizeof(tmain_header);
  SIZE_BLK=sizeof(tmain_block);

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
//C64
function abrir_prg(data:pbyte;long:dword):boolean;
function abrir_vsf(data:pbyte;long:dword):boolean;
//Snaphot master
function snapshot_w(nombre:string):boolean;
function snapshot_r(data:pbyte;long:dword):boolean;
function snapshot_main_write:string;

implementation
uses spectrum_48k,spectrum_128k,spectrum_3,amstrad_cpc,coleco,principal,main_engine,
     nes,commodore64,pv2000,pv1000;

procedure spectrum_change_model(model:byte);
begin
//Es el mismo modelo?
if main_vars.tipo_maquina=model then begin
  llamadas_maquina.reset;
  exit;
end;
//Cerrar el Spectrum y cambiar el modelo
llamadas_maquina.close;
todos_false;
reset_dsp;
principal1.BitBtn10.Enabled:=false;
case model of
  0,5:begin //Spectrum 48k y Spectrum 16k
      if model=0 then main_vars.tipo_maquina:=tipo_cambio_maquina(principal1.Spectrum48K1)
        else main_vars.tipo_maquina:=tipo_cambio_maquina(principal1.Spectrum16K1);
      llamadas_maquina.iniciar:=iniciar_48k;
    end;
  1,4:begin //Spectrum 128k y Spectrum +2
      if model=1 then main_vars.tipo_maquina:=tipo_cambio_maquina(principal1.Spectrum128K1)
        else main_vars.tipo_maquina:=tipo_cambio_maquina(principal1.Spectrum21);
      llamadas_maquina.iniciar:=iniciar_128k;
    end;
  2,3:begin //Spectrum +3 y Spectrum +2A
      if model=2 then begin
        main_vars.tipo_maquina:=tipo_cambio_maquina(principal1.Spectrum31);
        principal1.BitBtn10.Enabled:=true;
      end else main_vars.tipo_maquina:=tipo_cambio_maquina(principal1.Spectrum2A1);
      llamadas_maquina.iniciar:=iniciar_3;
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
        spec128_outbyte($7ffd,sna_regs_128k.reg_7ffd);
        copymemory(@memoria_128k[var_spectrum.marco[3],0],ptemp,16384);
        for f:=0 to 7 do
           if ((f<>2) and (f<>5) and (f<>var_spectrum.marco[3])) then begin
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
             copymemory(ptemp,@memoria_128k[var_spectrum.marco[3],0],$4000);inc(ptemp,$4000);
             getmem(sna_regs_128k,sizeof(tsna_regs_128k));
             sna_regs_128k.pc:=spec_z80_reg.pc;
             sna_regs_128k.reg_7ffd:=var_spectrum.old_7ffd;
             sna_regs_128k.trdos:=0;
             copymemory(ptemp,sna_regs_128k,4);inc(ptemp,4);
             longitud:=27+$4000*3+4;
             freemem(sna_regs_128k);
             for temp:=0 to 7 do
                if ((temp<>2) and (temp<>5) and (temp<>var_spectrum.marco[3])) then begin
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
spec_z80_reg.de2.w:=(buffer[6] shl 8)+buffer[7];
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
//Sonido (uso interno) 36 + 37
temp:=(buffer[38] shl 8)+buffer[39];
spec_z80_reg.halt_opcode:=(temp=1);
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
spec_z80_reg:=spec_z80.get_internal_r;
getmem(sp_regs,38);
copymemory(sp_regs,datos,38);inc(datos,38);
if ((sp_regs.nombre<>'SP') or ((sp_regs.long+38)<long))then exit;
//Puede ser 16K o 48K
if sp_regs.long<16385 then spectrum_change_model(5)
   else spectrum_change_model(0);
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
var_spectrum.haz_flash:=(sp_regs.misc and $20)<>0;
if (sp_regs.misc and 8)<>0 then spec_z80_reg.im:=0
  else spec_z80_reg.im:=((sp_regs.misc and 2) shr 1)+1;
freemem(sp_regs);
abrir_sp:=true;
end;

//SZX
type
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
if (szx_header.magic<>'ZXST') then begin
  freemem(szx_header);
  exit;
end;
case szx_header.tipo_maquina of
  0:spectrum_change_model(5);
  1:spectrum_change_model(0);
  2:spectrum_change_model(1);
  3:spectrum_change_model(4);
  4:spectrum_change_model(3);
  5:spectrum_change_model(2);
    else begin
      MessageDlg('Modelo no de Spectrum soportado.'+chr(10)+chr(13)+'Spectrum model not supported.', mtInformation,[mbOk], 0);
      freemem(szx_header);
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
    spec_z80_reg.halt_opcode:=(szx_regs.misc=2);
    //opppssss!!!
    if szx_regs.estados_t_irq<40 then var_spectrum.irq_pos:=szx_regs.estados_t_irq;
    if szx_regs.estados_t<71000 then spec_z80.contador:=szx_regs.estados_t;
    freemem(szx_regs);
  end;
  if szx_block.name='SPCR' then begin
    getmem(szx_spcr,sizeof(tszx_spcr));
    copymemory(szx_spcr,data,9);
    case szx_header.tipo_maquina of
      2,3:spec128_outbyte($7ffd,szx_spcr.reg_7ffd);
      4,5:spec3_outbyte($7ffd,szx_spcr.reg_7ffd);
    end;
    case szx_header.tipo_maquina of
      4,5:spec3_outbyte($1ffd,szx_spcr.reg_1ffd);
    end;
    case szx_header.tipo_maquina of
      0,1:spec48_outbyte($fe,szx_spcr.reg_fe);
      2,3:spec128_outbyte(szx_spcr.reg_fe,$fe);
      4,5:spec3_outbyte($fe,szx_spcr.reg_fe);
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
      if temp_long<>16384 then begin
        freemem(szx_header);
        freemem(szx_ramp);
        exit;
      end;
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
szx_crtr.minor_version:=$0602;
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
szx_regs.estados_t_irq:=var_spectrum.irq_pos;
szx_regs.misc:=byte(spec_z80_reg.halt_opcode) shl 1;
copymemory(ptemp,szx_block,8);inc(ptemp,8);longitud:=longitud+8;
copymemory(ptemp,szx_regs,37);inc(ptemp,37);longitud:=longitud+37;
freemem(szx_regs);
//Valores de la ULA
szx_block.name:='SPCR';
szx_block.longitud:=8;
getmem(szx_spcr,sizeof(tszx_spcr));
szx_spcr.borde:=borde.color;
szx_spcr.reg_7ffd:=var_spectrum.old_7ffd;
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
                inc(porigen);f:=f+1;
                if porigen^=$ed then begin
                        inc(porigen);f:=f+1;
                        contador:=porigen^;
                        inc(porigen);f:=f+1;
                        for g:=1 to contador do begin
                                pdestino^:=porigen^;
                                inc(pdestino);cont_final:=cont_final+1;
                        end;
                        inc(porigen);f:=f+1;
                end else begin
                        pdestino^:=$ed;
                        inc(pdestino);cont_final:=cont_final+1;
                end;
        end else begin
                pdestino^:=porigen^;
                inc(pdestino);cont_final:=cont_final+1;
                inc(porigen);f:=f+1;
        end;
end;
longitud:=cont_final;
end;

//Z80
function abrir_z80(datos:pbyte;long:integer;es_dsp:boolean):boolean;
var
  longitud,contador:integer;
  f:byte;
  puntero:pointer;
  spec_z80_reg:npreg_z80;
  z80_regs:^tz80_regs;
  z80_ext:^tz80_ext;
  z80_ram:^tz80_ram;
  ptemp:pbyte;
begin
abrir_z80:=false;
spec_z80_reg:=spec_z80.get_internal_r;
getmem(z80_regs,sizeof(tz80_regs));
copymemory(z80_regs,datos,30);inc(datos,30);
longitud:=30;
puntero:=nil;
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
                  freemem(z80_ext);
                  freemem(z80_regs);
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
                    spec128_outbyte($7ffd,z80_ext.reg_7ffd);
                  end;
          2,3:begin
                    ay8910_0.reset;
                    for f:=0 to $f do ay8910_0.set_reg(f,z80_ext.ay_regs[f]);
                    ay8910_0.control(z80_ext.reg_fffd);
                    spec3_outbyte($7ffd,z80_ext.reg_7ffd);
                    if (z80_ext.long=55) then spec3_outbyte($1ffd,z80_ext.reg_1ffd);
                  end;
        end;
        spec_z80_reg.pc:=z80_ext.pc;
        freemem(z80_ext);
        //Memoria
        getmem(z80_ram,sizeof(tz80_ram));
        while longitud<>long do begin
                copymemory(z80_ram,datos,2);
                //Comprobar si la pagina esta comprimida, si la longitud no es $ffff--> lo esta
                if z80_ram.longitud<>$ffff then begin
                  //ERROR: Snapshot no valido!!, si esta comprimido y ocupa mas de $4000 --> esta mal
                  if z80_ram.longitud>$4000 then begin
                    freemem(z80_ram);
                    freemem(z80_regs);
                    exit;
                  end;
                  //Copio el resto de los datos
                  copymemory(z80_ram,datos,z80_ram.longitud+3);
                  inc(datos,z80_ram.longitud+3);inc(longitud,z80_ram.longitud+3);
                  contador:=z80_ram.longitud;
                  getmem(puntero,$5000); //Siempre un poco mas por si acaso
                  if es_dsp then Decompress_zlib(pointer(@z80_ram.datos[0]),$4000,pointer(puntero),contador)
                    else descomprimir_z80(puntero,@z80_ram.datos[0],contador);
                  copymemory(@z80_ram.datos[0],puntero,$4000);
                  freemem(puntero);
                  puntero:=nil;
                end else begin //Si no esta comprimida, copio los datos, pero con longitud fija de $4000
                  copymemory(z80_ram,datos,$4000+3);
                  z80_ram.longitud:=$4000;
                  inc(datos,z80_ram.longitud+3);inc(longitud,z80_ram.longitud+3);
                end;
                case main_vars.tipo_maquina of
                  0,5:case z80_ram.numero of //Spectrum 48k
                          0:begin
                              copymemory(@memoria[0],@z80_ram.datos[0],$4000);
                              rom_cambiada_48:=true;
                            end;
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
            //IMPORTANTE: Son 30 bytes de la cabecera + 4 bytes que marcan el fin del bloque
            //En la version 2 y 3 no es necesario tener en cuenta esto porque la longitud
            //esta dentro de la cabecera del bloque
            contador:=long-30-4;
            if contador>$c000 then exit;
            //Por si acaso, cojo mas memoria de la necesaria...
            getmem(ptemp,60000);
            descomprimir_z80(ptemp,datos,contador);
            copymemory(@memoria[$4000],ptemp,$c000);
            freemem(ptemp);
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
spec_z80_reg.r:=spec_z80_reg.r or ((z80_regs.misc and 1) shl 7);
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
var_spectrum.issue2:=(z80_regs.misc2 and 4)=0;
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
z80_regs.misc2:=spec_z80_reg.im or (byte(var_spectrum.issue2) shl 2);
z80_ext.long:=55; //Grabo snapshot version 3
z80_ext.pc:=spec_z80_reg.pc;
case main_vars.tipo_maquina of
  0,5:z80_ext.hw_mode:=0;
  1,4:begin
      z80_ext.hw_mode:=4;
      z80_ext.reg_7ffd:=var_spectrum.old_7ffd;
      z80_ext.reg_fffd:=ay8910_0.get_control;
      for f:=0 to 15 do z80_ext.ay_regs[f]:=ay8910_0.get_reg(f);
    end;
  2,3:begin
      z80_ext.hw_mode:=7;
      z80_ext.reg_7ffd:=var_spectrum.old_7ffd;
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
  tcpc_chunk=packed record
      name:array[0..3] of ansichar;
      size:dword;
    end;

function grabar_amstrad_sna(nombre:string):boolean;
var
  f:byte;
  long:dword;
  pdatos,ptemp:pbyte;
  main_z80_reg:npreg_z80;
  cpc_sna:^tcpc_sna;
  cpc_chunk:^tcpc_chunk;
  buffer:array[0..9] of byte;
begin
main_z80_reg:=z80_0.get_internal_r;
getmem(pdatos,$50000);
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
cpc_sna.rom_config:=cpc_ga.rom_selected;
//PIA a,b,c,control
cpc_sna.ppi_a:=cpc_ppi.port_a_read_latch;
cpc_sna.ppi_c:=cpc_ppi.port_c_write_latch;
cpc_sna.ppi_control:=pia8255_0.read(3);
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
if z80_0.get_irq<>CLEAR_LINE then cpc_sna.irq:=1;
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
//Y ahora grabo chunks con las ROMs cambiadas (si las hay)
case cpc_ga.cpc_model of
  1,2,3:begin
           getmem(cpc_chunk,sizeof(tcpc_chunk));
           cpc_chunk.name:='LOCL';
           cpc_chunk.size:=10;
           copymemory(ptemp,cpc_chunk,8);
           inc(ptemp,8);
           inc(long,8);
           buffer[0]:=cpc_ga.cpc_model;
           copymemory(ptemp,@buffer[0],10);
           freemem(cpc_chunk);
           inc(ptemp,10);
           inc(long,10);
        end;
  4:begin
      getmem(cpc_chunk,sizeof(tcpc_chunk));
      cpc_chunk.name:='LROM';
      cpc_chunk.size:=$4000;
      copymemory(ptemp,cpc_chunk,8);
      inc(ptemp,8);
      inc(long,8);
      //copymemory(ptemp,@cpc_low_rom[0],$4000);
      copymemory(ptemp,@cpc_rom[16].data,$4000);
      freemem(cpc_chunk);
      inc(ptemp,$4000);
      inc(long,$4000);
  end;
end;
for f:=1 to 6 do begin
  if cpc_rom[f].enabled then begin
    getmem(cpc_chunk,sizeof(tcpc_chunk));
    cpc_chunk.name:='ROM';
    cpc_chunk.name[3]:=ansichar(chr(48+f));
    cpc_chunk.size:=$4000;
    copymemory(ptemp,cpc_chunk,8);
    inc(ptemp,8);
    inc(long,8);
    copymemory(ptemp,@cpc_rom[f].data,$4000);
    freemem(cpc_chunk);
    inc(ptemp,$4000);
    inc(long,$4000);
  end;
end;
grabar_amstrad_sna:=write_file(nombre,pdatos,long);
freemem(pdatos);
end;

procedure decompress_chunk(origen,destino:pbyte;longitud:dword);
var
   posicion:dword;
   mark,rep,data,f:byte;
begin
posicion:=0;
while posicion<>longitud do begin
   mark:=origen^;
   inc(origen);
   inc(posicion);
   //Tiene repeticiones?
   if mark=$e5 then begin
       rep:=origen^;
       inc(origen);
       inc(posicion);
       //Caso especial...
       if rep=0 then begin
          destino^:=$e5;
          inc(destino);
       end else begin
          data:=origen^;
          inc(origen);
          inc(posicion);
          for f:=1 to rep do begin
              destino^:=data;
              inc(destino);
          end;
       end;
   end else begin
       destino^:=mark;
       inc(destino);
   end;
end;
end;

function abrir_sna_cpc(data:pbyte;longitud:integer):boolean;
var
  f:byte;
  position:integer;
  main_z80_reg:npreg_z80;
  cpc_sna:^tcpc_sna;
  cpc_chunk:^tcpc_chunk;
  mem_temp,mem_temp2:pbyte;
begin
abrir_sna_cpc:=false;
getmem(cpc_sna,sizeof(tcpc_sna));
copymemory(cpc_sna,data,$100);
inc(data,$100);
position:=256;
if (cpc_sna.magic)<>'MV - SNA' then begin
  freemem(cpc_sna);
  exit;
end;
main_z80_reg:=z80_0.get_internal_r;
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
write_ram(0,cpc_sna.ram_config);
//CRT
cpc_crt.reg:=cpc_sna.crt_index and $1f;
for f:=0 to 17 do cpc_crt.regs[f]:=cpc_sna.crt_regs[f];
if cpc_crt.regs[1]<50 then cpc_crt.pixel_visible:=cpc_crt.regs[1]*8
  else cpc_crt.pixel_visible:=49*8;
cpc_crt.char_total:=(cpc_crt.regs[0]+1)*8;
//ROM
cpc_outbyte($df00,cpc_sna.rom_config);
//PIA a,b,c,control
cpc_ppi.port_a_read_latch:=cpc_sna.ppi_a;
//Port b nada...
port_c_write(cpc_sna.ppi_c);
cpc_outbyte($f782,cpc_sna.ppi_control);
//PSG control,reg
for f:=0 to $f do ay8910_0.set_reg(f,cpc_sna.ay_regs[f]);
ay8910_0.control(cpc_sna.ay_control);
case cpc_sna.mem_size of
  0:; //La informacion de la memoria viene adjunta en Chuncks
  64:for f:=0 to 3 do begin
         copymemory(@cpc_mem[f,0],data,$4000);
         inc(data,$4000);
         position:=position+$4000;
     end;
  128:for f:=0 to 7 do begin
         copymemory(@cpc_mem[f,0],data,$4000);
         inc(data,$4000);
         position:=position+$4000;
      end;
  else exit; //Si hay mas memoria, es otro modelo --> No soportado
end;
case cpc_sna.version of
  1:begin
      case cpc_sna.mem_size of
           64:begin
                 main_vars.tipo_maquina:=7;
                 llamadas_maquina.caption:='Amstrad CPC 464';
           end;
           128:begin
                 main_vars.tipo_maquina:=9;
                 llamadas_maquina.caption:='Amstrad CPC 6128';
           end;
      end;
      cpc_load_roms;
    end;
  2,3:begin
      case cpc_sna.hw_type of
        0,5:begin
          main_vars.tipo_maquina:=7;
          llamadas_maquina.caption:='Amstrad CPC 464';
        end;
        1:begin
          main_vars.tipo_maquina:=8;
          llamadas_maquina.caption:='Amstrad CPC 664';
        end;
        2,4:begin
          main_vars.tipo_maquina:=9;
          llamadas_maquina.caption:='Amstrad CPC 6128';
        end;
        3:begin  //Desconocido?
           case cpc_sna.mem_size of
                64:begin
                       main_vars.tipo_maquina:=7;
                       llamadas_maquina.caption:='Amstrad CPC 464';
                   end;
               128:begin
                       main_vars.tipo_maquina:=9;
                       llamadas_maquina.caption:='Amstrad CPC 6128';
                   end;
               else exit;
           end;
          end;
        else exit; //Modelo no soportado
      end;
      cpc_load_roms;
      if cpc_sna.version=3 then begin
        cpc_ga.lines_sync:=cpc_sna.ga_lines_sync;
        cpc_ga.lines_count:=cpc_sna.ga_lines_count;
        if cpc_sna.irq<>0 then z80_0.change_irq(ASSERT_LINE)
           else z80_0.change_irq(CLEAR_LINE);
        getmem(cpc_chunk,sizeof(tcpc_chunk));
        while position<>longitud do begin //Hay chunks??
           copymemory(cpc_chunk,data,8);
           inc(data,8);
           position:=position+8;
           if cpc_chunk.name='MEM0' then begin
              getmem(mem_temp,$10000);
              decompress_chunk(data,mem_temp,cpc_chunk.size);
              mem_temp2:=mem_temp;
              for f:=0 to 3 do begin
                  copymemory(@cpc_mem[f,0],mem_temp2,$4000);
                  inc(mem_temp2,$4000);
              end;
              freemem(mem_temp);
           end;
           if cpc_chunk.name='MEM1' then begin
              getmem(mem_temp,$10000);
              decompress_chunk(data,mem_temp,cpc_chunk.size);
              mem_temp2:=mem_temp;
              for f:=0 to 3 do begin
                  copymemory(@cpc_mem[4+f,0],mem_temp2,$4000);
                  inc(mem_temp2,$4000);
              end;
              freemem(mem_temp);
           end;
           if ((cpc_chunk.name[0]='R') and (cpc_chunk.name[1]='O') and (cpc_chunk.name[2]='M')) then
                copymemory(@cpc_rom[strtoint(cpc_chunk.name[3])].data,data,$4000);
           if cpc_chunk.name='LROM' then begin
                //copymemory(@cpc_low_rom[0],data,$4000);
                copymemory(@cpc_rom[16].data,data,$4000);
                cpc_ga.cpc_model:=4;
           end;
           if cpc_chunk.name='LOCL' then cpc_ga.cpc_model:=data^;
           if cpc_chunk.name='CPC+' then exit; //Es un CPC plus de verdad!
           inc(data,cpc_chunk.size);
           position:=position+cpc_chunk.size;
        end;
        freemem(cpc_chunk);
      end;
    end;
end;
freemem(cpc_sna);
abrir_sna_cpc:=true;
end;

//Coleco
function abrir_coleco_snapshot(data:pbyte;long:dword):boolean;
type
  ttms_v1=record
      regs:array[0..7] of byte;
      colour,pattern,nametbl,spriteattribute,spritepattern,colourmask,patternmask,nAddr:word;
      latch,nVR,status_reg,nFGColor,nBGColor,wkey:byte;
      int:boolean;
      TMS9918A_VRAM_SIZE:word;
      memory:array[0..$3fff] of byte;
      dBackMem:array[0..$ffff] of byte;
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
  tsn76496_v1=packed record
      UpdateStep:dword;
    	VolTable:array[0..15] of integer;
    	Registers:array[0..7] of integer;
    	LastRegister:byte;
    	Volume,Period,Count:array [0..3] of integer;
      Output:array [0..3] of byte;
    	RNG:cardinal;
    	NoiseFB:integer;
  end;
var
  ptemp,ptemp2,ptemp3:pbyte;
  longitud,descomprimido:integer;
  main_z80_reg:npreg_z80;
  tms_v1:^ttms_v1;
  z80_v1:^tz80_v1;
  z80_v2:^tz80_v2;
  z80_v2_ext:^tz80_v2_ext;
  sn76496_v1:^tsn76496_v1;
  coleco_header:^tmain_header;
  coleco_block:^tmain_block;
  tempb:byte;
begin
abrir_coleco_snapshot:=false;
getmem(coleco_header,SIZE_MH);
copymemory(coleco_header,data,SIZE_MH);
inc(data,SIZE_MH);longitud:=SIZE_MH;
if coleco_header.magic<>'CLSN' then begin
  freemem(coleco_header);
  exit;
end;
if ((coleco_header.version<>1) and (coleco_header.version<>2) and (coleco_header.version<>$1002) and (coleco_header.version<>$220) and (coleco_header.version<>$300) and (coleco_header.version<>$301) and (coleco_header.version<>$310)) then begin
   freemem(coleco_header);
   exit;
end;
getmem(coleco_block,sizeof(tmain_block));
while longitud<long do begin
  copymemory(coleco_block,data,SIZE_BLK);
  inc(data,SIZE_BLK);inc(longitud,SIZE_BLK);
  if coleco_block.nombre='CRAM' then begin
    getmem(ptemp,$10000);
    decompress_zlib(data,coleco_block.longitud,pointer(ptemp),descomprimido);
    case coleco_header.version of
      $300,$301,$310:copymemory(@memoria[0],ptemp,descomprimido)
        else copymemory(@memoria[$2000],ptemp,descomprimido);
    end;
    freemem(ptemp);
  end;
  if coleco_block.nombre='Z80R' then begin
    case coleco_header.version of
     $1:begin //Version 1.00
          getmem(z80_v1,sizeof(tz80_v1));
          copymemory(z80_v1,data,68);
          main_z80_reg:=z80_0.get_internal_r;
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
          main_z80_reg.halt_opcode:=z80_v1.halt;
          z80_0.change_irq(z80_v1.pedir_irq);
          z80_0.change_nmi(z80_v1.pedir_nmi);
          {z80_0.nmi_state:=(ptemp^<>0);}
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
          z80_0.contador:=z80_v1.contador;
          main_z80_reg.im:=z80_v1.im;
          z80_0.im2_lo:=z80_v1.im2_lo;
          z80_0.im0:=z80_v1.im0;
          freemem(z80_v1);
      end;
      $2:begin //Version 2.00
          main_z80_reg:=z80_0.get_internal_r;
          ptemp:=data;
          getmem(z80_v2,sizeof(tz80_v2));
          copymemory(z80_v2,ptemp,46);
          inc(ptemp,46);
          copymemory(main_z80_reg,z80_v2,45);
          getmem(z80_v2_ext,sizeof(tz80_v2_ext));
          copymemory(z80_v2_ext,ptemp,9);
          main_z80_reg.halt_opcode:=z80_v2_ext.halt;
          z80_0.change_irq(z80_v2_ext.pedir_irq);
          z80_0.change_nmi(z80_v2_ext.pedir_nmi);
          z80_0.contador:=z80_v2_ext.contador;
          z80_0.im2_lo:=z80_v2_ext.im2_lo;
          z80_0.im0:=z80_v2_ext.im0;
          freemem(z80_v2_ext);
          freemem(z80_v2);
        end;
     $1002,$220:begin //Version 2.X
          ptemp:=data;
          getmem(ptemp2,60);
          ptemp3:=ptemp2;
          copymemory(ptemp3,ptemp,45);
          inc(ptemp,46);inc(ptemp3,45);
          copymemory(ptemp3,ptemp,12);
          z80_0.load_snapshot(ptemp2);
          freemem(ptemp2);
        end;
      $300,$301,$310:z80_0.load_snapshot(data); //Version 3.X
    end;
  end;
  if coleco_block.nombre='TMSR' then begin
    getmem(ptemp,sizeof(ttms_v1));
    decompress_zlib(data,coleco_block.longitud,pointer(ptemp),descomprimido);
    case coleco_header.version of
  $1,$2,$1002:begin
            getmem(tms_v1,sizeof(ttms_v1));
            copymemory(tms_v1,ptemp,sizeof(ttms_v1));
            copymemory(@tms_0.regs,@tms_v1.regs[0],8);
            tms_0.color:=tms_v1.colour;
            tms_0.pattern:=tms_v1.pattern;
            tms_0.nametbl:=tms_v1.nametbl;
            tms_0.spriteattribute:=tms_v1.spriteattribute;
            tms_0.spritepattern:=tms_v1.spritepattern;
            tms_0.colormask:=tms_v1.colourmask;
            tms_0.patternmask:=tms_v1.patternmask;
            tms_0.addr:=tms_v1.nAddr;
            tms_0.status_reg:=tms_v1.status_reg;
            tms_0.fgcolor:=tms_v1.nFGColor;
            tms_0.bgcolor:=tms_v1.nbgcolor;
            tms_0.int:=tms_v1.int;
            copymemory(@tms_0.mem[0],@tms_v1.memory[0],$4000);
            freemem(tms_v1);
        end;
      $220,$300,$301,$310:tms_0.load_snapshot(ptemp);
    end;
    freemem(ptemp);
    tms_0.change_irq(coleco_interrupt);
    tms_0.pant:=1;
    if tms_0.bgcolor=0 then paleta[0]:=0
      else paleta[0]:=paleta[tms_0.bgcolor];
  end;
  if coleco_block.nombre='MISC' then begin
    getmem(ptemp,$100000);
    decompress_zlib(data,coleco_block.longitud,pointer(ptemp),descomprimido);
    copymemory(@coleco_0,ptemp,descomprimido);
    freemem(ptemp);
  end;
  if coleco_block.nombre='7649' then begin
    case coleco_header.version of
      $301,$310:sn_76496_0.load_snapshot(data);
        else begin
            getmem(sn76496_v1,sizeof(tsn76496_v1));
            copymemory(sn76496_v1,data,sizeof(tsn76496_v1));
            sn_76496_0.UpdateStep:=sn76496_v1.UpdateStep;
            for tempb:=0 to 15 do sn_76496_0.VolTable[tempb]:=sn76496_v1.VolTable[tempb];
            for tempb:=0 to 7 do sn_76496_0.Registers[tempb]:=sn76496_v1.Registers[tempb];
            sn_76496_0.LastRegister:=sn76496_v1.LastRegister;
            for tempb:=0 to 3 do sn_76496_0.Volume[tempb]:=sn76496_v1.Volume[tempb];
            for tempb:=0 to 3 do sn_76496_0.Count[tempb]:=sn76496_v1.Count[tempb];
            for tempb:=0 to 3 do sn_76496_0.Period[tempb]:=sn76496_v1.Period[tempb];
            for tempb:=0 to 3 do sn_76496_0.Output[tempb]:=sn76496_v1.Output[tempb];
            sn_76496_0.RNG:=sn76496_v1.RNG;
            sn_76496_0.NoiseFB:=sn76496_v1.NoiseFB;
            freemem(sn76496_v1);
        end;
    end;
  end;
  if coleco_block.nombre='AY89' then ay8910_0.load_snapshot(data);
  if coleco_block.nombre='I2CM' then begin
    if i2cmem_0<>nil then i2cmem_0.free;
    case coleco_0.eprom_type of
      1:i2cmem_0:=i2cmem_chip.create(I2C_24C08);
      2:i2cmem_0:=i2cmem_chip.create(I2C_24C256);
    end;
    i2cmem_0.load_snapshot(data);
  end;
  inc(data,coleco_block.longitud);inc(longitud,coleco_block.longitud);
end;
freemem(coleco_block);
freemem(coleco_header);
abrir_coleco_snapshot:=true;
end;

//C64
//PRG
function abrir_prg(data:pbyte;long:dword):boolean;
var
   hi,lo:byte;
   dest,f:word;
begin
  //Los dos primeros bytes es la direccion de destino, el resto son los datos
	abrir_prg:=false;
	lo:=data^;
  inc(data);
	hi:=data^;
  inc(data);
	dest:=(hi shl 8) or (lo);;
  for f:=0 to (long-2) do begin
    c64_putbyte(dest+f,data^);
    inc(data);
  end;
	abrir_prg:=true;
end;

//VSF
const
  VSF_HEAD=22;
type
tvsf_header=packed record
    magic:array[0..18] of ansichar;
    vmajor,vminor:byte;
    machinename:array[0..15] of ansichar;
    version_magic:array[0..12] of ansichar;
    version_major,version_minor,version_micro,version_zero:byte;
    svnversion:dword;
end;

tvsf_block_head=packed record
    modulename:array[0..15] of ansichar;
    vmajor,vminor:byte;
    size_:dword;
end;

tvsf_maincpu=packed record
    clk:dword;
    ac,xr,yr,sp:byte;
    pc:word;
    st:byte;
    lastopcode,irqclk,nmiclk,none1,none2:dword;
end;

tvsf_c64mem=packed record
    cpudata,cpudir,exrom,game:byte;
end;

function abrir_vsf(data:pbyte;long:dword):boolean;
var
  vsf_header:^tvsf_header;
  vsf_block_head:^tvsf_block_head;
  vsf_maincpu:^tvsf_maincpu;
  vsf_c64mem:^tvsf_c64mem;
  c64_cpu:preg_m6502;
  posicion:dword;
begin
abrir_vsf:=false;
getmem(vsf_header,sizeof(tvsf_header));
copymemory(vsf_header,data,sizeof(tvsf_header));
inc(data,sizeof(tvsf_header));
posicion:=sizeof(tvsf_header);
if copy(vsf_header.magic,1,18)<>'VICE Snapshot File' then begin
  freemem(vsf_header);
  exit;
end;
if copy(vsf_header.machinename,1,3)<>'C64' then begin
  freemem(vsf_header);
  exit;
end;
freemem(vsf_header);
getmem(vsf_block_head,VSF_HEAD);
while posicion<>long do begin
  copymemory(vsf_block_head,data,VSF_HEAD);
  inc(data,VSF_HEAD);
  if copy(vsf_block_head.modulename,1,7)='MAINCPU' then begin
    getmem(vsf_maincpu,sizeof(tvsf_maincpu));
    copymemory(vsf_maincpu,data,sizeof(tvsf_maincpu));
    c64_cpu:=m6502_0.get_internal_r;
    c64_cpu.a:=vsf_maincpu.ac;
    c64_cpu.x:=vsf_maincpu.xr;
    c64_cpu.y:=vsf_maincpu.yr;
    c64_cpu.sp:=vsf_maincpu.sp;
    c64_cpu.pc:=vsf_maincpu.pc;
    c64_cpu.p.n:=(vsf_maincpu.sp and $80)<>0;
    c64_cpu.p.o_v:=(vsf_maincpu.sp and $40)<>0;
    c64_cpu.p.dec:=(vsf_maincpu.sp and 8)<>0;
    c64_cpu.p.int:=(vsf_maincpu.sp and 4)<>0;
    c64_cpu.p.z:=(vsf_maincpu.sp and 2)<>0;
    c64_cpu.p.c:=(vsf_maincpu.sp and 1)<>0;
    inc(data,vsf_block_head.size_-VSF_HEAD);
    inc(posicion,vsf_block_head.size_);
  end else
  if copy(vsf_block_head.modulename,1,6)='C64MEM' then begin
    getmem(vsf_c64mem,sizeof(tvsf_c64mem));
    copymemory(vsf_c64mem,data,sizeof(tvsf_c64mem));
    inc(data,sizeof(tvsf_c64mem));
    c64_putbyte(0,vsf_c64mem.cpudata);
    c64_putbyte(1,vsf_c64mem.cpudir);
    copymemory(@memoria,data,$10000);
    inc(data,vsf_block_head.size_-VSF_HEAD-sizeof(tvsf_c64mem));
    inc(posicion,vsf_block_head.size_);
  end else begin
  //if copy(vsf_block_head.modulename,1,7)='C64CART' then begin
    inc(data,vsf_block_head.size_-VSF_HEAD);
    inc(posicion,vsf_block_head.size_);
  end;
end;
freemem(vsf_block_head);
abrir_vsf:=true;
end;

function snapshot_w(nombre:string):boolean;
var
  longitud:integer;
  snapshot_header:^tmain_header;
  snapshot_block:^tmain_block;
  pdata,ptemp:pbyte;

procedure write_main_header(magic:string;version:word);
var
  f:byte;
begin
fillchar(snapshot_header^,SIZE_MH,0);
for f:=0 to 3 do snapshot_header.magic[f]:=ansichar(magic[f+1]);
snapshot_header.version:=version;
copymemory(ptemp,snapshot_header,SIZE_MH);
inc(ptemp,SIZE_MH);
longitud:=SIZE_MH;  //Simpre va este bloque primero!!!
end;

procedure write_ram(ram_orig:pbyte;ram_size:dword);
var
  ptemp2:pbyte;
  blk_size:integer;
begin
fillchar(snapshot_block^,SIZE_BLK,0);
snapshot_block.nombre:='CRAM';
ptemp2:=ptemp;
inc(ptemp2,SIZE_BLK);
compress_zlib(ram_orig,ram_size,ptemp2,blk_size);
snapshot_block.longitud:=blk_size;
copymemory(ptemp,snapshot_block,SIZE_BLK);
inc(ptemp,blk_size+SIZE_BLK);
inc(longitud,blk_size+SIZE_BLK);
end;

procedure write_tms99X8;
var
  ptemp2,ptemp3:pbyte;
  tms_size,blk_size:integer;
begin
fillchar(snapshot_block^,SIZE_BLK,0);
snapshot_block.nombre:='TMSR';
ptemp2:=ptemp;
inc(ptemp2,SIZE_BLK);
getmem(ptemp3,$5000);
tms_size:=tms_0.save_snapshot(ptemp3);
compress_zlib(ptemp3,tms_size,ptemp2,blk_size);
freemem(ptemp3);
snapshot_block.longitud:=blk_size;
copymemory(ptemp,snapshot_block,SIZE_BLK);
inc(ptemp,blk_size+SIZE_BLK);
inc(longitud,blk_size+SIZE_BLK);
end;

procedure write_z80;
var
  ptemp2:pbyte;
  blk_size:integer;
begin
fillchar(snapshot_block^,SIZE_BLK,0);
snapshot_block.nombre:='Z80R';
ptemp2:=ptemp;
inc(ptemp2,SIZE_BLK);
blk_size:=z80_0.save_snapshot(ptemp2);
snapshot_block.longitud:=blk_size;
copymemory(ptemp,snapshot_block,SIZE_BLK);
inc(ptemp,blk_size+SIZE_BLK);
inc(longitud,blk_size+SIZE_BLK);
end;

procedure write_sn76496;
var
  ptemp2:pbyte;
  blk_size:integer;
begin
fillchar(snapshot_block^,SIZE_BLK,0);
snapshot_block.nombre:='7649';
ptemp2:=ptemp;
inc(ptemp2,SIZE_BLK);
blk_size:=sn_76496_0.save_snapshot(ptemp2);
snapshot_block.longitud:=blk_size;
copymemory(ptemp,snapshot_block,SIZE_BLK);
inc(ptemp,blk_size+SIZE_BLK);
inc(longitud,blk_size+SIZE_BLK);
end;

procedure write_misc(pmisc:pbyte;misc_size:integer);
var
  ptemp2:pbyte;
  blk_size:integer;
begin
fillchar(snapshot_block^,SIZE_BLK,0);
snapshot_block.nombre:='MISC';
ptemp2:=ptemp;
inc(ptemp2,SIZE_BLK);
compress_zlib(pmisc,misc_size,ptemp2,blk_size);
snapshot_block.longitud:=blk_size;
copymemory(ptemp,snapshot_block,SIZE_BLK);
inc(ptemp,blk_size+SIZE_BLK);
inc(longitud,blk_size+SIZE_BLK);
end;

procedure write_ay891X;
var
  ptemp2:pbyte;
  blk_size:integer;
begin
fillchar(snapshot_block^,SIZE_BLK,0);
snapshot_block.nombre:='AY89';
ptemp2:=ptemp;
inc(ptemp2,SIZE_BLK);
blk_size:=ay8910_0.save_snapshot(ptemp2);
snapshot_block.longitud:=blk_size;
copymemory(ptemp,snapshot_block,SIZE_BLK);
inc(ptemp,blk_size+SIZE_BLK);
inc(longitud,blk_size+SIZE_BLK);
end;

procedure write_i2cmem;
var
  ptemp2,ptemp3:pbyte;
  tms_size,blk_size:integer;
begin
fillchar(snapshot_block^,SIZE_BLK,0);
snapshot_block.nombre:='I2CM';
ptemp2:=ptemp;
inc(ptemp2,SIZE_BLK);
getmem(ptemp3,$9000);
tms_size:=i2cmem_0.save_snapshot(ptemp3);
compress_zlib(ptemp3,tms_size,ptemp2,blk_size);
freemem(ptemp3);
snapshot_block.longitud:=blk_size;
copymemory(ptemp,snapshot_block,SIZE_BLK);
inc(ptemp,blk_size+SIZE_BLK);
inc(longitud,blk_size+SIZE_BLK);
end;

procedure write_smsvdp;
var
  ptemp2,ptemp3:pbyte;
  tms_size,blk_size:integer;
begin
fillchar(snapshot_block^,SIZE_BLK,0);
snapshot_block.nombre:='VDP0';
ptemp2:=ptemp;
inc(ptemp2,SIZE_BLK);
getmem(ptemp3,$10000);
tms_size:=vdp_0.save_snapshot(ptemp3);
compress_zlib(ptemp3,tms_size,ptemp2,blk_size);
freemem(ptemp3);
snapshot_block.longitud:=blk_size;
copymemory(ptemp,snapshot_block,SIZE_BLK);
inc(ptemp,blk_size+SIZE_BLK);
inc(longitud,blk_size+SIZE_BLK);
end;

procedure write_upd1771;
var
  ptemp2,ptemp3:pbyte;
  tms_size,blk_size:integer;
begin
fillchar(snapshot_block^,SIZE_BLK,0);
snapshot_block.nombre:='1771';
ptemp2:=ptemp;
inc(ptemp2,SIZE_BLK);
getmem(ptemp3,$10000);
tms_size:=upd1771_0.save_snapshot(ptemp3);
compress_zlib(ptemp3,tms_size,ptemp2,blk_size);
freemem(ptemp3);
snapshot_block.longitud:=blk_size;
copymemory(ptemp,snapshot_block,SIZE_BLK);
inc(ptemp,blk_size+SIZE_BLK);
inc(longitud,blk_size+SIZE_BLK);
end;

procedure write_upd7810;
var
  ptemp2:pbyte;
  blk_size:integer;
begin
fillchar(snapshot_block^,SIZE_BLK,0);
snapshot_block.nombre:='7810';
ptemp2:=ptemp;
inc(ptemp2,SIZE_BLK);
blk_size:=upd7810_0.save_snapshot(ptemp2);
snapshot_block.longitud:=blk_size;
copymemory(ptemp,snapshot_block,SIZE_BLK);
inc(ptemp,blk_size+SIZE_BLK);
inc(longitud,blk_size+SIZE_BLK);
end;

procedure write_n2a03(n2a03:cpu_n2a03);
var
  ptemp2:pbyte;
  blk_size:integer;
begin
fillchar(snapshot_block^,SIZE_BLK,0);
snapshot_block.nombre:='2A03';
ptemp2:=ptemp;
inc(ptemp2,SIZE_BLK);
blk_size:=n2a03.save_snapshot(ptemp2);
snapshot_block.longitud:=blk_size;
copymemory(ptemp,snapshot_block,SIZE_BLK);
inc(ptemp,blk_size+SIZE_BLK);
inc(longitud,blk_size+SIZE_BLK);
end;

procedure write_nes_ppu;
var
  ptemp2,ptemp3:pbyte;
  tms_size,blk_size:integer;
begin
fillchar(snapshot_block^,SIZE_BLK,0);
snapshot_block.nombre:='NPPU';
ptemp2:=ptemp;
inc(ptemp2,SIZE_BLK);
getmem(ptemp3,$10000);
tms_size:=ppu_nes_0.save_snapshot(ptemp3);
compress_zlib(ptemp3,tms_size,ptemp2,blk_size);
freemem(ptemp3);
snapshot_block.longitud:=blk_size;
copymemory(ptemp,snapshot_block,SIZE_BLK);
inc(ptemp,blk_size+SIZE_BLK);
inc(longitud,blk_size+SIZE_BLK);
end;

procedure write_nes_mapper;
var
  ptemp2,ptemp3:pbyte;
  tms_size,blk_size:integer;
begin
fillchar(snapshot_block^,SIZE_BLK,0);
snapshot_block.nombre:='NMAP';
ptemp2:=ptemp;
inc(ptemp2,SIZE_BLK);
getmem(ptemp3,$900000);
tms_size:=nes_mapper_0.save_snapshot(ptemp3);
compress_zlib(ptemp3,tms_size,ptemp2,blk_size);
freemem(ptemp3);
snapshot_block.longitud:=blk_size;
copymemory(ptemp,snapshot_block,SIZE_BLK);
inc(ptemp,blk_size+SIZE_BLK);
inc(longitud,blk_size+SIZE_BLK);
end;

procedure write_gb_mapper;
var
  ptemp2,ptemp3:pbyte;
  tms_size,blk_size:integer;
begin
fillchar(snapshot_block^,SIZE_BLK,0);
snapshot_block.nombre:='NMAP';
ptemp2:=ptemp;
inc(ptemp2,SIZE_BLK);
getmem(ptemp3,$900000);
tms_size:=gb_mapper_0.save_snapshot(ptemp3);
compress_zlib(ptemp3,tms_size,ptemp2,blk_size);
freemem(ptemp3);
snapshot_block.longitud:=blk_size;
copymemory(ptemp,snapshot_block,SIZE_BLK);
inc(ptemp,blk_size+SIZE_BLK);
inc(longitud,blk_size+SIZE_BLK);
end;

procedure write_gb_snd;
var
  ptemp2:pbyte;
  blk_size:integer;
begin
fillchar(snapshot_block^,SIZE_BLK,0);
snapshot_block.nombre:='GBSN';
ptemp2:=ptemp;
inc(ptemp2,SIZE_BLK);
blk_size:=gb_snd_0.save_snapshot(ptemp2);
snapshot_block.longitud:=blk_size;
copymemory(ptemp,snapshot_block,SIZE_BLK);
inc(ptemp,blk_size+SIZE_BLK);
inc(longitud,blk_size+SIZE_BLK);
end;

procedure write_lr35902;
var
  ptemp2:pbyte;
  blk_size:integer;
begin
fillchar(snapshot_block^,SIZE_BLK,0);
snapshot_block.nombre:='LR35';
ptemp2:=ptemp;
inc(ptemp2,SIZE_BLK);
blk_size:=lr35902_0.save_snapshot(ptemp2);
snapshot_block.longitud:=blk_size;
copymemory(ptemp,snapshot_block,SIZE_BLK);
inc(ptemp,blk_size+SIZE_BLK);
inc(longitud,blk_size+SIZE_BLK);
end;

begin
//Cabeceras y espacio en memoria
getmem(snapshot_header,SIZE_MH);
fillchar(snapshot_header^,SIZE_MH,0);
getmem(snapshot_block,SIZE_BLK);
fillchar(snapshot_block^,SIZE_BLK,0);
getmem(pdata,$1000000);
ptemp:=pdata;
case main_vars.system_type of
  SNES:begin
            write_main_header('NES0',$1);
            write_ram(@memoria[0],$10000);
            write_misc(@nes_0,sizeof(tnes_machine));
            write_n2a03(n2a03_0);
            write_nes_ppu;
            write_nes_mapper;
       end;
  SGB:begin
            write_main_header('GBC0',$1);
            write_ram(@memoria[0],$10000);
            write_misc(@gb_0,sizeof(tgameboy_machine));
            write_lr35902;
            write_gb_mapper;
            write_gb_snd;
       end;
  SCOLECO:begin
            write_main_header('CLSN',$310);
            write_ram(@memoria[0],$10000);
            write_misc(@coleco_0,sizeof(tcoleco_machine));
            write_tms99x8;
            write_z80;
            write_sn76496;
            write_ay891x;
            if coleco_0.eprom_type<>0 then write_i2cmem;
          end;
  SCHIP8:begin
            write_main_header('CHP8',$1);
            write_ram(@memoria[0],$10000);
            write_misc(@chip8_0,sizeof(tchip8));
         end;
  SSMS:begin
            write_main_header('SMS0',$1);
            write_misc(@sms_0,sizeof(tmastersystem));
            write_z80;
            write_sn76496;
            write_smsvdp;
         end;
  SGG:begin
            write_main_header('SGG0',$1);
            write_misc(@gg_0,sizeof(tmastersystem));
            write_z80;
            write_sn76496;
            write_smsvdp;
         end;
  SSG1000:begin
            write_main_header('SG1K',$1);
            write_ram(@memoria[0],$10000);
            write_misc(@sg1000_0,sizeof(tpv1000));
            write_z80;
            write_tms99x8;
         end;
  SSUPERCASSETTE:begin
            write_main_header('SCVI',$1);
            write_ram(@memoria[0],$10000);
            write_misc(@scv_0,sizeof(scv_0));
            write_upd1771;
            write_upd7810;
         end;
  SPV1000:begin
            write_main_header('PV1K',$1);
            write_ram(@memoria[0],$10000);
            write_misc(@pv1000_0,sizeof(tpv1000));
            write_z80;
         end;
  SPV2000:begin
            write_main_header('PV2K',$1);
            write_ram(@memoria[0],$10000);
            write_misc(@pv2000_0,sizeof(tpv2000));
            write_tms99x8;
            write_z80;
            write_sn76496;
         end;
end;
//Final
freemem(snapshot_header);
freemem(snapshot_block);
snapshot_w:=write_file(nombre,pdata,longitud);
freemem(pdata);
end;

function snapshot_r(data:pbyte;long:dword):boolean;
var
  snapshot_header:^tmain_header;
  snapshot_block:^tmain_block;
  system:byte;
  longitud:dword;

procedure load_ram(ram_dest:pbyte);
var
  ptemp:pbyte;
  blk_size:integer;
begin
getmem(ptemp,$10000);
decompress_zlib(data,snapshot_block.longitud,pointer(ptemp),blk_size);
copymemory(ram_dest,ptemp,blk_size);
freemem(ptemp);
end;

procedure load_tms99X8;
var
  ptemp:pbyte;
  blk_size:integer;
begin
getmem(ptemp,$5000);
decompress_zlib(data,snapshot_block.longitud,pointer(ptemp),blk_size);
tms_0.load_snapshot(ptemp);
freemem(ptemp);
end;

procedure load_misc(misc_dest:pbyte);
var
  ptemp:pbyte;
  blk_size:integer;
begin
getmem(ptemp,$200000);
decompress_zlib(data,snapshot_block.longitud,pointer(ptemp),blk_size);
copymemory(misc_dest,ptemp,blk_size);
freemem(ptemp);
end;

procedure load_smsvdp;
var
  ptemp:pbyte;
  blk_size:integer;
begin
getmem(ptemp,$200000);
decompress_zlib(data,snapshot_block.longitud,pointer(ptemp),blk_size);
vdp_0.load_snapshot(ptemp);
freemem(ptemp);
end;

procedure load_upd1771;
var
  ptemp:pbyte;
  blk_size:integer;
begin
getmem(ptemp,$10000);
decompress_zlib(data,snapshot_block.longitud,pointer(ptemp),blk_size);
upd1771_0.load_snapshot(ptemp);
freemem(ptemp);
end;

procedure load_nes_ppu;
var
  ptemp:pbyte;
  blk_size:integer;
begin
getmem(ptemp,$10000);
decompress_zlib(data,snapshot_block.longitud,pointer(ptemp),blk_size);
ppu_nes_0.load_snapshot(ptemp);
freemem(ptemp);
end;

procedure load_nes_mapper;
var
  ptemp:pbyte;
  blk_size:integer;
begin
getmem(ptemp,$900000);
decompress_zlib(data,snapshot_block.longitud,pointer(ptemp),blk_size);
nes_mapper_0.load_snapshot(ptemp);
freemem(ptemp);
end;

procedure load_gb_mapper;
var
  ptemp:pbyte;
  blk_size:integer;
begin
getmem(ptemp,$900000);
decompress_zlib(data,snapshot_block.longitud,pointer(ptemp),blk_size);
gb_mapper_0.load_snapshot(ptemp);
freemem(ptemp);
end;

begin
snapshot_r:=false;
getmem(snapshot_header,SIZE_MH);
copymemory(snapshot_header,data,SIZE_MH);
system:=$ff;
if snapshot_header.magic='NES0' then system:=SNES;
if snapshot_header.magic='PV1K' then system:=SPV1000;
if snapshot_header.magic='PV2K' then system:=SPV2000;
if snapshot_header.magic='SG1K' then system:=SSG1000;
if snapshot_header.magic='SMS0' then system:=SSMS;
if snapshot_header.magic='SGG0' then system:=SGG;
if snapshot_header.magic='SCVI' then system:=SSUPERCASSETTE;
if snapshot_header.magic='CHP8' then system:=SCHIP8;
if snapshot_header.magic='GBC0' then system:=SGB;
if ((system=$ff) or (system<>main_vars.system_type)) then begin
  MessageDlg('Snapshot no válido para este sistema.'+chr(10)+chr(13)+'Snapshot not valid for this system.', mtInformation,[mbOk], 0);
  freemem(snapshot_header);
  exit;
end;
inc(data,SIZE_MH);
longitud:=SIZE_MH;
getmem(snapshot_block,SIZE_BLK);
while longitud<long do begin
  copymemory(snapshot_block,data,SIZE_BLK);
  inc(data,SIZE_BLK);
  inc(longitud,SIZE_BLK);
  case main_vars.system_type of
    SNES:begin
              if snapshot_block.nombre='CRAM' then load_ram(@memoria[0]);
              if snapshot_block.nombre='MISC' then load_misc(@nes_0);
              if snapshot_block.nombre='2A03' then n2a03_0.load_snapshot(data);
              if snapshot_block.nombre='NPPU' then load_nes_ppu;
              if snapshot_block.nombre='NMAP' then begin
                                                      load_nes_mapper;
                                                      nes_mapper_0.set_mapper(nes_mapper_0.mapper,nes_mapper_0.submapper);
                                                   end;
         end;
    SGB:begin
             if snapshot_block.nombre='CRAM' then load_ram(@memoria[0]);
             if snapshot_block.nombre='MISC' then begin
                                                      load_misc(@gb_0);
                                                      gb_change_model(gb_0.is_gbc,gb_0.unlicensed);
                                                      gb_change_timer;
                                                   end;
             if snapshot_block.nombre='LR35' then lr35902_0.load_snapshot(data);
             if snapshot_block.nombre='NMAP' then begin
                                                      load_gb_mapper;
                                                      gb_mapper_0.set_mapper(gb_mapper_0.mapper,gb_mapper_0.crc32,gb_mapper_0.rom_size,gb_mapper_0.ram_size);
                                                   end;
             if snapshot_block.nombre='GBSN' then gb_snd_0.load_snapshot(data);
        end;
    SCHIP8:begin
              if snapshot_block.nombre='CRAM' then load_ram(@memoria[0]);
              if snapshot_block.nombre='MISC' then load_misc(@chip8_0);
            end;
    SSUPERCASSETTE:begin
              if snapshot_block.nombre='MISC' then load_misc(@scv_0);
              if snapshot_block.nombre='CRAM' then load_ram(@memoria[0]);
              if snapshot_block.nombre='7810' then upd7810_0.load_snapshot(data);
              if snapshot_block.nombre='1771' then load_upd1771;
              end;
    SSMS:begin
              if snapshot_block.nombre='Z80R' then z80_0.load_snapshot(data);
              if snapshot_block.nombre='MISC' then begin
                                                   load_misc(@sms_0);
                                                   change_sms_model(sms_0.model,false);
                                              end;
              if snapshot_block.nombre='VDP0' then load_smsvdp;
              if snapshot_block.nombre='7649' then sn_76496_0.load_snapshot(data);
            end;
    SGG:begin
              if snapshot_block.nombre='Z80R' then z80_0.load_snapshot(data);
              if snapshot_block.nombre='MISC' then load_misc(@gg_0);
              if snapshot_block.nombre='VDP0' then load_smsvdp;
              if snapshot_block.nombre='7649' then sn_76496_0.load_snapshot(data);
            end;
    SSG1000:begin
              if snapshot_block.nombre='CRAM' then load_ram(@memoria[0]);
              if snapshot_block.nombre='Z80R' then z80_0.load_snapshot(data);
              if snapshot_block.nombre='MISC' then load_misc(@sg1000_0);
              if snapshot_block.nombre='TMSR' then load_tms99x8;
            end;
    SPV1000:begin
              if snapshot_block.nombre='CRAM' then load_ram(@memoria[0]);
              if snapshot_block.nombre='Z80R' then z80_0.load_snapshot(data);
              if snapshot_block.nombre='MISC' then load_misc(@pv1000_0);
            end;
    SPV2000:begin
              if snapshot_block.nombre='CRAM' then load_ram(@memoria[0]);
              if snapshot_block.nombre='TMSR' then load_tms99x8;
              if snapshot_block.nombre='Z80R' then z80_0.load_snapshot(data);
              if snapshot_block.nombre='7649' then sn_76496_0.load_snapshot(data);
              if snapshot_block.nombre='MISC' then load_misc(@pv2000_0);
            end;
  end;
  inc(data,snapshot_block.longitud);
  inc(longitud,snapshot_block.longitud);
end;
snapshot_r:=true;
end;

function snapshot_main_write:string;
var
  nombre:string;
  correcto:boolean;
  indice:byte;
begin
if saverom(nombre,indice) then begin
    nombre:=changefileext(nombre,'.dsp');
    if FileExists(nombre) then begin                                         //Respuesta 'NO' es 7
        if MessageDlg(leng[main_vars.idioma].mensajes[3], mtWarning, [mbYes]+[mbNo],0)=7 then exit;
    end;
    correcto:=snapshot_w(nombre);
    if not(correcto) then MessageDlg('No se ha podido guardar el snapshot!',mtError,[mbOk],0);
end else exit;
snapshot_main_write:=nombre;
end;

end.
