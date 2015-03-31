unit snapshot;

interface
uses {$IFDEF windows}windows,{$ENDIF}
     sysutils,spectrum_misc,ay_8910,dialogs,nz80,z80_sp,forms,file_engine,
     init_games,tap_tzx,tape_window,rom_engine,ppi8255;

//Spectrum
function abrir_sna(datos:pbyte;long:integer):boolean;
function abrir_sp(datos:pbyte;long:integer):boolean;
function abrir_zx(datos:pbyte;long:integer):boolean;
function abrir_szx(data:pbyte;long:integer):boolean;
function abrir_z80(datos:pbyte;long:integer;es_dsp:boolean):boolean;
function grabar_sna(nombre:string):boolean;
function grabar_szx(nombre:string):boolean;
function grabar_z80(nombre:string;es_dsp:boolean):boolean;
procedure descomprimir_z80(destino,origen:pbyte;longitud:word);
procedure spectrum_change_model(model:byte);
//Amstrad CPC
function abrir_sna_cpc(data:pbyte;long:integer):boolean;
function grabar_amstrad_sna(nombre:string):boolean;

var
  buffer_test:array[0..256] of byte;

implementation
uses spectrum_48k,spectrum_128k,spectrum_3,amstrad_cpc,principal,main_engine;

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
      if model=0 then main_vars.tipo_maquina:=tipo_cambio_maquina(form1.Spectrum48K1)
        else main_vars.tipo_maquina:=tipo_cambio_maquina(form1.Spectrum16K1);
      Cargar_Spectrum48K;
    end;
  1,4:begin //Spectrum 128k y Spectrum +2
      if model=1 then main_vars.tipo_maquina:=tipo_cambio_maquina(form1.Spectrum128K1)
        else main_vars.tipo_maquina:=tipo_cambio_maquina(form1.Spectrum21);
      Cargar_Spectrum128K;
    end;
  2,3:begin //Spectrum +3 y Spectrum +2A
      if model=2 then main_vars.tipo_maquina:=tipo_cambio_maquina(form1.Spectrum31)
        else main_vars.tipo_maquina:=tipo_cambio_maquina(form1.Spectrum2A1);
      Cargar_Spectrum3;
    end;
end;
llamadas_maquina.iniciar;
end;

function abrir_szx(data:pbyte;long:integer):boolean;
var
  longitud,lbloque,temp4:integer;
  temp,tmaquina:byte;
  cadena:string;
  datos:boolean;
  ram_sp:pbyte;
  temp3:word;
  spec_z80_reg:npreg_z80;
begin
abrir_szx:=false;
longitud:=0;
cadena:='';
for temp:=0 to 3 do begin
  cadena:=cadena+chr(data^);
  inc(data);inc(longitud);
end;
if cadena<>'ZXST' then exit;
inc(data,2);inc(longitud,2);
tmaquina:=data^;
case tmaquina of
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
inc(data,2);inc(longitud,2);
while longitud<>long do begin
  cadena:='';
  for temp:=0 to 3 do begin
        cadena:=cadena+chr(data^);
        inc(data);inc(longitud);
  end;
  copymemory(@lbloque,data,4);
  inc(data,4);inc(longitud,4);
  datos:=false;
  if cadena='Z80R' then begin
    datos:=true;
    getmem(spec_z80_reg,sizeof(nreg_z80));
    spec_z80_reg.a:=data^;
    inc(data);inc(longitud); //A
    spec_z80_reg.f.s:=(data^ and 128)<>0;
    spec_z80_reg.f.z:=(data^ and 64)<>0;
    spec_z80_reg.f.bit5:=(data^ and 32)<>0;
    spec_z80_reg.f.h:=(data^ and 16)<>0;
    spec_z80_reg.f.bit3:=(data^ and 8)<>0;
    spec_z80_reg.f.p_v:=(data^ and 4)<>0;
    spec_z80_reg.f.n:=(data^ and 2)<>0;
    spec_z80_reg.f.c:=(data^ and 1)<>0;
    inc(data);inc(longitud); //F
    copymemory(@spec_z80_reg.bc.w,data,2);
    inc(data,2);inc(longitud,2); //BC
    copymemory(@spec_z80_reg.de.w,data,2);
    inc(data,2);inc(longitud,2); //DE
    copymemory(@spec_z80_reg.hl.w,data,2);
    inc(data,2);inc(longitud,2); //HL
    spec_z80_reg.a2:=data^; //A2
    inc(data);inc(longitud);
    spec_z80_reg.f2.s:=(data^ and 128)<>0;
    spec_z80_reg.f2.z:=(data^ and 64)<>0;
    spec_z80_reg.f2.bit5:=(data^ and 32)<>0;
    spec_z80_reg.f2.h:=(data^ and 16)<>0;
    spec_z80_reg.f2.bit3:=(data^ and 8)<>0;
    spec_z80_reg.f2.p_v:=(data^ and 4)<>0;
    spec_z80_reg.f2.n:=(data^ and 2)<>0;
    spec_z80_reg.f2.c:=(data^ and 1)<>0;
    inc(data);inc(longitud); //F2
    copymemory(@spec_z80_reg.bc2.w,data,2);
    inc(data,2);inc(longitud,2); //BC2
    copymemory(@spec_z80_reg.de2.w,data,2);
    inc(data,2);inc(longitud,2); //DE2
    copymemory(@spec_z80_reg.hl2.w,data,2);
    inc(data,2);inc(longitud,2); //HL2
    copymemory(@spec_z80_reg.ix.w,data,2);
    inc(data,2);inc(longitud,2); //IX
    copymemory(@spec_z80_reg.iy.w,data,2);
    inc(data,2);inc(longitud,2); //IY
    copymemory(@spec_z80_reg.sp,data,2);
    inc(data,2);inc(longitud,2); //SP
    copymemory(@spec_z80_reg.pc,data,2);
    inc(data,2);inc(longitud,2); //PC
    spec_z80_reg.i:=data^;
    inc(data);inc(longitud); //I
    spec_z80_reg.r:=data^;
    inc(data);inc(longitud); //R
    temp:=data^;spec_z80_reg.iff1:=temp<>0;
    inc(data);inc(longitud); //IFF1
    temp:=data^;spec_z80_reg.iff2:=temp<>0;
    inc(data);inc(longitud); //IFF2
    spec_z80_reg.im:=data^;
    inc(data);inc(longitud); //IM
    inc(data,5);inc(longitud,5);
    temp:=data^;spec_z80.halt:=(temp=2);
    inc(data,3);inc(longitud,3);
    spec_z80.set_internal_r(spec_z80_reg);
    freemem(spec_z80_reg);
  end;
  if cadena='SPCR' then begin
    datos:=true;
    borde.color:=data^;
    inc(data);inc(longitud);
    temp:=data^;
    inc(data);inc(longitud);
    case tmaquina of
      2,3:spec128_outbyte(temp,$7ffd);
      4,5:spec3_outbyte(temp,$7ffd);
    end;
    temp:=data^;
    inc(data);inc(longitud);
    case tmaquina of
      4,5:spec3_outbyte(temp,$1ffd);
    end;
    temp:=data^;
    inc(data);inc(longitud);
    temp:=(temp and $f8) or borde.color;
    case tmaquina of
      0,1:spec48_outbyte(temp,$fe);
      2,3:spec128_outbyte(temp,$fe);
      4,5:spec3_outbyte(temp,$fe);
    end;
    inc(data,4);inc(longitud,4);
  end;
  if cadena='RAMP' then begin
    datos:=true;
    copymemory(@temp3,data,2);
    inc(data,2);
    temp:=data^;
    inc(data);
    if temp3=1 then begin
      getmem(ram_sp,16384);
      Decompress_zlib(data,lbloque-3,pointer(ram_sp),temp4);
    end else ram_sp:=data;
    case tmaquina of
      1:case temp of
          0:copymemory(@memoria[$c000],ram_sp,$4000);
          2:copymemory(@memoria[$8000],ram_sp,$4000);
          5:copymemory(@memoria[$4000],ram_sp,$4000);
        end;
      2,3:copymemory(@memoria_128k[temp,0],ram_sp,$4000);
      4,5:copymemory(@memoria_3[temp,0],ram_sp,$4000);
      0:copymemory(@memoria[$4000],ram_sp,$4000);
    end;
    if temp3=1 then begin
      freemem(ram_sp);
      ram_sp:=nil;
    end;
    inc(data,lbloque-3);
    inc(longitud,lbloque);
  end;
  if ((cadena='AY'+chr(0)+chr(0)) and (tmaquina<>1)) then begin
    datos:=true;
    inc(data);inc(longitud);
    temp:=data^;
    inc(data);inc(longitud);
    for temp3:=0 to $f do begin
      ay8910_0.control(temp3);
      if tmaquina=2 then spec128_outbyte(data^,$bffd)
        else spec3_outbyte(data^,$bffd);
      inc(data);inc(longitud);
    end;
    ay8910_0.control(temp);
  end;
  if not(datos) then begin
    inc(data,lbloque);
    inc(longitud,lbloque);
  end;
end;
abrir_szx:=true;
end;

function abrir_zx(datos:pbyte;long:integer):boolean;
var
  puntero:pbyte;
  buffer:array[0..50] of byte;
  temp:word;
  spec_z80_reg:npreg_z80;
begin
abrir_zx:=false;
if long<>49486 then exit;
spectrum_change_model(0);
puntero:=datos;
inc(puntero,132);
copymemory(@memoria[$4000],puntero,49152);
inc(puntero,49152);
//este formato viene de Amiga, por lo tanto tiene invertido el byte mas significativo
inc(puntero,142);
getmem(spec_z80_reg,sizeof(nreg_z80));
spec_z80_reg.iff1:=(puntero^=1);
inc(puntero,8);
copymemory(@buffer[0],puntero,50);
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
spec_z80.set_internal_r(spec_z80_reg);
freemem(spec_z80_reg);
abrir_zx:=true;
end;

function abrir_sp(datos:pbyte;long:integer):boolean;
var
  buffer:array[0..37] of byte;
  puntero:pbyte;
  cadena:string;
  longitud,tempw:word;
  spec_z80_reg:npreg_z80;
begin
abrir_sp:=false;
spectrum_change_model(0); //Solo puede ser 48K
puntero:=datos;
copymemory(@buffer[0],puntero,38);
inc(puntero,38);
cadena:=chr(buffer[0])+chr(buffer[1]);
if cadena<>'SP' then exit;
copymemory(@longitud,@buffer[2],2); //longitud
if longitud+38<long then exit;
copymemory(@tempw,@buffer[4],2);
copymemory(@memoria[tempw],puntero,longitud);
getmem(spec_z80_reg,sizeof(nreg_z80));
copymemory(@spec_z80_reg.bc.w,@buffer[6],2);
copymemory(@spec_z80_reg.de.w,@buffer[8],2);
copymemory(@spec_z80_reg.hl.w,@buffer[10],2);
spec_z80_reg.a:=buffer[13];
spec_z80_reg.f.s:=(buffer[12] and 128)<>0;
spec_z80_reg.f.z:=(buffer[12] and 64)<>0;
spec_z80_reg.f.bit5:=(buffer[12] and 32)<>0;
spec_z80_reg.f.h:=(buffer[12] and 16)<>0;
spec_z80_reg.f.bit3:=(buffer[12] and 8)<>0;
spec_z80_reg.f.p_v:=(buffer[12] and 4)<>0;
spec_z80_reg.f.n:=(buffer[12] and 2)<>0;
spec_z80_reg.f.c:=(buffer[12] and 1)<>0;
copymemory(@spec_z80_reg.ix.w,@buffer[14],2);
copymemory(@spec_z80_reg.iy.w,@buffer[16],2);
copymemory(@spec_z80_reg.bc2.w,@buffer[18],2);
copymemory(@spec_z80_reg.de2.w,@buffer[20],2);
copymemory(@spec_z80_reg.hl2.w,@buffer[22],2);
spec_z80_reg.a2:=buffer[25];
spec_z80_reg.f2.s:=(buffer[24] and 128)<>0;
spec_z80_reg.f2.z:=(buffer[24] and 64)<>0;
spec_z80_reg.f2.bit5:=(buffer[24] and 32)<>0;
spec_z80_reg.f2.h:=(buffer[24] and 16)<>0;
spec_z80_reg.f2.bit3:=(buffer[24] and 8)<>0;
spec_z80_reg.f2.p_v:=(buffer[24] and 4)<>0;
spec_z80_reg.f2.n:=(buffer[24] and 2)<>0;
spec_z80_reg.f2.c:=(buffer[24] and 1)<>0;
spec_z80_reg.r:=buffer[26];
spec_z80_reg.i:=buffer[27];
copymemory(@spec_z80_reg.sp,@buffer[28],2);
copymemory(@spec_z80_reg.pc,@buffer[30],2);
borde.color:=buffer[34];
spec_z80_reg.iff1:=buffer[36]<>0;
if (buffer[36] and 8)<>0 then spec_z80_reg.im:=0
  else if (buffer[36] and 2)<>0 then spec_z80_reg.im:=2 else spec_z80_reg.im:=1;
spec_z80.set_internal_r(spec_z80_reg);
freemem(spec_z80_reg);
abrir_sp:=true;
end;

procedure descomprimir_z80(destino,origen:pbyte;longitud:word);
var
  pdestino,porigen:pbyte;
  g,contador,f:word;
begin
pdestino:=destino;
porigen:=origen;
f:=0;
while (f<longitud) do begin
        if porigen^=$ed then begin
                inc(porigen);
                inc(f);
                if porigen^=$ed then begin
                        inc(porigen);
                        inc(f);
                        contador:=porigen^;
                        inc(porigen);
                        inc(f);
                        for g:=1 to contador do begin
                                pdestino^:=porigen^;
                                inc(pdestino);
                        end;
                        inc(porigen);
                        inc(f);
                end else begin
                        pdestino^:=$ed;
                        inc(pdestino);
                end;
        end else begin
                pdestino^:=porigen^;
                inc(pdestino);
                inc(porigen);
                inc(f);
        end;
end;
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
while total<16384 do begin
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
  if total=16383 then begin  //si estoy en el ultimo byte no puedo comprimir
      pdestino^:=porigen^;
      inc(total);
      inc(long);
  end;
end;  //del while
if long>16384 then begin
  copymemory(destino,origen,16384);
  comprimir_z80:=$FFFF;
end else comprimir_z80:=long;
end;

function abrir_z80(datos:pbyte;long:integer;es_dsp:boolean):boolean;
var
  buffer:array[0..29] of byte;
  buffer2:array[0..49151] of byte;
  buffer3:array[0..56] of byte;
  buffer4:array[0..3] of byte;
  f,pos_memoria:integer;
  g,contador:word;
  puntero:pointer;
  spec_z80_reg:npreg_z80;
begin
abrir_z80:=false;
getmem(puntero,16384);
copymemory(@buffer[0],datos,30);
inc(datos,30);dec(long,30);
getmem(spec_z80_reg,sizeof(nreg_z80));
if ((buffer[6]=0) and (buffer[7]=0)) then begin  //version 2.xx o 3.xx
        copymemory(@g,datos,2);    //si g=23 es version 2, si 54 o 55 es version 3
        inc(datos,2);dec(long,2);
        copymemory(@buffer3[2],datos,g);
        inc(datos,g);dec(long,g);
        case buffer3[4] of
                0,1:spectrum_change_model(0); //Modo 48k
                3:if g=23 then spectrum_change_model(1)
                    else spectrum_change_model(0);
                4,5,6:spectrum_change_model(1); //Modo 128K
                7,8:spectrum_change_model(2); //Modo +3
                12:spectrum_change_model(3); //Modo +2A
                13:spectrum_change_model(4); //Modo +2
                else begin
                  freemem(spec_z80_reg);
                  freemem(puntero);
                  MessageDlg('Modelo no de Spectrum soportado.'+chr(10)+chr(13)+'Spectrum model not supported.', mtInformation,[mbOk], 0);
                  exit;
                end;
        end;  //del case
        copymemory(@spec_z80_reg.pc,@buffer3[2],2);
        while long>0 do begin
                copymemory(@buffer4[0],datos,3);
                inc(datos,3);dec(long,3);
                copymemory(@contador,@buffer4[0],2);
                case main_vars.tipo_maquina of
                    0:begin
                        case buffer4[2] of
                          0:pos_memoria:=0;
                          4:pos_memoria:=$8000;
                          5:pos_memoria:=$c000;
                          8:pos_memoria:=$4000;
                          else begin
                            freemem(spec_z80_reg);
                            freemem(puntero);
                            exit;
                          end;
                        end;
                        if contador=$FFFF then begin
                          copymemory(@memoria[pos_memoria],datos,16384);
                          inc(datos,16384);dec(long,16384);
                        end else begin
                          if es_dsp then Decompress_zlib(datos,contador,puntero,f)
                            else descomprimir_z80(puntero,datos,contador);
                          copymemory(@memoria[pos_memoria],puntero,16384);
                          inc(datos,contador);dec(long,contador);
                        end;
                    end;
                  1,4:begin //Spectrum 128k o Spectrum +2
                         spec128_outbyte(buffer3[5],$7ffd);
                         for f:=0 to $f do begin
                           ay8910_0.control(f);
                           spec128_outbyte(buffer3[9+f],$bffd);
                         end;
                         ay8910_0.control(buffer3[8]);
                        case buffer4[2] of
                          0,1:begin
                                if contador=$FFFF then begin
                                        copymemory(@memoria_128k[buffer4[2],0],datos,16384);
                                        inc(datos,16384);dec(long,16384);
                                end else begin
                                        if es_dsp then Decompress_zlib(pointer(datos),contador,puntero,f)
                                          else descomprimir_z80(puntero,datos,contador);
                                        copymemory(@memoria_128k[buffer4[2],0],puntero,16384);
                                        inc(datos,contador);dec(long,contador);
                                end;
                              end;
                          3,4,5,6,7,8,9,10:begin
                                                if contador=$FFFF then begin
                                                   copymemory(@memoria_128k[buffer4[2]-3,0],datos,16384);
                                                   inc(datos,16384);dec(long,16384);
                                                end else begin
                                                  if es_dsp then Decompress_zlib(datos,contador,puntero,f)
                                                    else descomprimir_z80(puntero,datos,contador);
                                                  copymemory(@memoria_128k[buffer4[2]-3,0],puntero,16384);
                                                  inc(datos,contador);dec(long,contador);
                                                end;
                                           end;
                          else begin
                                freemem(spec_z80_reg);
                                freemem(puntero);
                                exit;
                          end;
                        end;
                   end;
                2,3:begin //Spectrum +3 y Spectrum +2A
                      spec3_outbyte(buffer3[5],$7ffd);
                      spec3_outbyte(buffer3[56],$1ffd);
                      for f:=0 to $f do begin
                       ay8910_0.control(f);
                       spec3_outbyte(buffer3[9+f],$bffd);
                      end;
                      ay8910_0.control(buffer3[8]);
                      case buffer4[2] of
                          0,1:begin
                                if contador=$FFFF then begin
                                        copymemory(@memoria_3[buffer4[2],0],datos,16384);
                                        inc(datos,16384);dec(long,16384);
                                end else begin
                                        if es_dsp then Decompress_zlib(pointer(datos),contador,puntero,f)
                                          else descomprimir_z80(puntero,datos,contador);
                                        copymemory(@memoria_3[buffer4[2],0],puntero,16384);
                                        inc(datos,contador);dec(long,contador);
                                end;
                              end;
                          3,4,5,6,7,8,9,10:begin
                                                if contador=$FFFF then begin
                                                   copymemory(@memoria_3[buffer4[2]-3,0],datos,16384);
                                                   inc(datos,16384);dec(long,16384);
                                                end else begin
                                                  if es_dsp then Decompress_zlib(datos,contador,puntero,f)
                                                    else descomprimir_z80(puntero,datos,contador);
                                                  copymemory(@memoria_3[buffer4[2]-3,0],puntero,16384);
                                                  inc(datos,contador);dec(long,contador);
                                                end;
                                           end;
                          else begin
                                freemem(spec_z80_reg);
                                freemem(puntero);
                                exit;
                          end;
                        end;
                end;
                end;
        end;
end else begin //version 1.XX solo 48k
        spectrum_change_model(0);
        copymemory(@spec_z80_reg.pc,@buffer[6],2);
        if (buffer[12] and $20)<>0 then begin //comprimido
                descomprimir_z80(@memoria[16384],datos,long-4);
                inc(datos,long-4);
                copymemory(@buffer2[0],datos,4);
                if ((buffer2[0]<>0) and (buffer2[1]<>$ed) and (buffer2[2]<>$ed) and (buffer2[3]<>0)) then begin
                    freemem(spec_z80_reg);
                    freemem(puntero);
                    exit;
                end;
        end else //sin comprimir
                copymemory(@memoria[0],datos,49152);
end;
spec_z80_reg.a:=buffer[0];
spec_z80_reg.f.s:=(buffer[1] and 128)<>0;
spec_z80_reg.f.z:=(buffer[1] and 64)<>0;
spec_z80_reg.f.bit5:=(buffer[1] and 32)<>0;
spec_z80_reg.f.h:=(buffer[1] and 16)<>0;
spec_z80_reg.f.bit3:=(buffer[1] and 8)<>0;
spec_z80_reg.f.p_v:=(buffer[1] and 4)<>0;
spec_z80_reg.f.n:=(buffer[1] and 2)<>0;
spec_z80_reg.f.c:=(buffer[1] and 1)<>0;
copymemory(@spec_z80_reg.bc.w,@buffer[2],2);
copymemory(@spec_z80_reg.hl.w,@buffer[4],2);
copymemory(@spec_z80_reg.sp,@buffer[8],2);
spec_z80_reg.i:=buffer[10];
spec_z80_reg.r:=buffer[11] and $7f;
if buffer[12]=255 then buffer[12]:=1;
if (buffer[12] and 1)<>0 then spec_z80_reg.r:=(spec_z80_reg.r or $80);
borde.color:=(buffer[12] and $0e) shr 1;
copymemory(@spec_z80_reg.de.w,@buffer[13],2);
copymemory(@spec_z80_reg.bc2.w,@buffer[15],2);
copymemory(@spec_z80_reg.de2.w,@buffer[17],2);
copymemory(@spec_z80_reg.hl2.w,@buffer[19],2);
spec_z80_reg.a2:=buffer[21];
spec_z80_reg.f2.s:=(buffer[22] and 128)<>0;
spec_z80_reg.f2.z:=(buffer[22] and 64)<>0;
spec_z80_reg.f2.bit5:=(buffer[22] and 32)<>0;
spec_z80_reg.f2.h:=(buffer[22] and 16)<>0;
spec_z80_reg.f2.bit3:=(buffer[22] and 8)<>0;
spec_z80_reg.f2.p_v:=(buffer[22] and 4)<>0;
spec_z80_reg.f2.n:=(buffer[22] and 2)<>0;
spec_z80_reg.f2.c:=(buffer[22] and 1)<>0;
copymemory(@spec_z80_reg.iy.w,@buffer[23],2);
copymemory(@spec_z80_reg.ix.w,@buffer[25],2);
spec_z80_reg.iff1:=(buffer[27]<>0);
spec_z80_reg.iff2:=(buffer[28]<>0);
spec_z80_reg.im:=buffer[29] and 3;
spec_z80.set_internal_r(spec_z80_reg);
freemem(spec_z80_reg);
freemem(puntero);
abrir_z80:=true;
end;

function abrir_sna(datos:pbyte;long:integer):boolean;
var
  buffer:array[0..26] of byte;
  buffer2:array[0..3] of byte;
  buffer3:array[0..16383] of byte;
  f:word;
  spec_z80_reg:npreg_z80;
begin
abrir_sna:=false;
if long<49179 then exit;
copymemory(@buffer[0],datos,27);
inc(datos,27);dec(long,27);
getmem(spec_z80_reg,sizeof(nreg_z80));
if long>49152 then begin
        spectrum_change_model(1);
        copymemory(@memoria_128k[5],datos,16384);
        inc(datos,16384);
        copymemory(@memoria_128k[2],datos,16384);
        inc(datos,16384);
        copymemory(@buffer3[0],datos,16384);
        inc(datos,16384);
        copymemory(@buffer2[0],datos,4);
        inc(datos,4);
        for f:=0 to 7 do
           if ((f<>2) and (f<>5) and (f<>(buffer2[2] and $7))) then begin
                copymemory(@memoria_128k[f],datos,16384);
                inc(datos,16384);
           end;
        copymemory(@spec_z80_reg.pc,@buffer2[0],2);
        copymemory(@memoria_128k[(buffer2[2] and $7)],@buffer3[0],16384);
        copymemory(@spec_z80_reg.sp,@buffer[23],2);
        spec128_outbyte(buffer2[2],$7ffd);
end else begin
        spectrum_change_model(0);
        copymemory(@memoria[16384],datos,long);
        copymemory(@spec_z80_reg.sp,@buffer[23],2);
        copymemory(@spec_z80_reg.pc,@memoria[spec_z80_reg.sp],2);
        inc(spec_z80_reg.sp,2);
end;
spec_z80_reg.i:=buffer[0];
copymemory(@spec_z80_reg.hl2.w,@buffer[1],2);
copymemory(@spec_z80_reg.de2.w,@buffer[3],2);
copymemory(@spec_z80_reg.bc2.w,@buffer[5],2);
spec_z80_reg.a2:=buffer[8];
spec_z80_reg.f2.s:=(buffer[7] and 128)<>0;
spec_z80_reg.f2.z:=(buffer[7] and 64)<>0;
spec_z80_reg.f2.bit5:=(buffer[7] and 32)<>0;
spec_z80_reg.f2.h:=(buffer[7] and 16)<>0;
spec_z80_reg.f2.bit3:=(buffer[7] and 8)<>0;
spec_z80_reg.f2.p_v:=(buffer[7] and 4)<>0;
spec_z80_reg.f2.n:=(buffer[7] and 2)<>0;
spec_z80_reg.f2.c:=(buffer[7] and 1)<>0;
copymemory(@spec_z80_reg.hl.w,@buffer[9],2);
copymemory(@spec_z80_reg.de.w,@buffer[11],2);
copymemory(@spec_z80_reg.bc.w,@buffer[13],2);
copymemory(@spec_z80_reg.iy.w,@buffer[15],2);
copymemory(@spec_z80_reg.ix.w,@buffer[17],2);
spec_z80_reg.iff2:=(buffer[19] and 4)<>0;
spec_z80_reg.iff1:=(buffer[19] and 2)<>0;
spec_z80_reg.r:=buffer[20];
spec_z80_reg.a:=buffer[22];
spec_z80_reg.f.s:=(buffer[21] and 128)<>0;
spec_z80_reg.f.z:=(buffer[21] and 64)<>0;
spec_z80_reg.f.bit5:=(buffer[21] and 32)<>0;
spec_z80_reg.f.h:=(buffer[21] and 16)<>0;
spec_z80_reg.f.bit3:=(buffer[21] and 8)<>0;
spec_z80_reg.f.p_v:=(buffer[21] and 4)<>0;
spec_z80_reg.f.n:=(buffer[21] and 2)<>0;
spec_z80_reg.f.c:=(buffer[21] and 1)<>0;
spec_z80_reg.im:=buffer[25];
borde.color:=buffer[26];
spec_z80.set_internal_r(spec_z80_reg);
freemem(spec_z80_reg);
abrir_sna:=true;
end;

function grabar_sna(nombre:string):boolean;
var
  fichero:file of byte;
  buffer:array[0..26] of byte;
  temp:byte;
  spec_z80_reg:npreg_z80;
begin
grabar_sna:=false;
{$I-}
assignfile(fichero,nombre);
rewrite(fichero);
spec_z80_reg:=spec_z80.get_internal_r;
buffer[0]:=spec_z80_reg.i;
buffer[1]:=spec_z80_reg.hl2.l;
buffer[2]:=spec_z80_reg.hl2.h;
buffer[3]:=spec_z80_reg.de2.l;
buffer[4]:=spec_z80_reg.de2.h;
buffer[5]:=spec_z80_reg.bc2.l;
buffer[6]:=spec_z80_reg.bc2.h;
temp:=0;
if spec_z80_reg.f2.s then temp:=temp or $80;
if spec_z80_reg.f2.z then temp:=temp or $40;
if spec_z80_reg.f2.bit5 then temp:=temp or $20;
if spec_z80_reg.f2.h then temp:=temp or $10;
if spec_z80_reg.f2.bit3 then temp:=temp or 8;
if spec_z80_reg.f2.p_v then temp:=temp or 4;
if spec_z80_reg.f2.n then temp:=temp or 2;
if spec_z80_reg.f2.c then temp:=temp or 1;
buffer[7]:=temp;
buffer[8]:=spec_z80_reg.a2;
buffer[9]:=spec_z80_reg.hl.l;
buffer[10]:=spec_z80_reg.hl.h;
buffer[11]:=spec_z80_reg.de.l;
buffer[12]:=spec_z80_reg.de.h;
buffer[13]:=spec_z80_reg.bc.l;
buffer[14]:=spec_z80_reg.bc.h;
buffer[15]:=spec_z80_reg.iy.l;
buffer[16]:=spec_z80_reg.iy.h;
buffer[17]:=spec_z80_reg.ix.l;
buffer[18]:=spec_z80_reg.ix.h;
if spec_z80_reg.iff1 then temp:=temp or 2;
if spec_z80_reg.iff2 then temp:=temp or 4;
buffer[19]:=temp;
buffer[20]:=spec_z80_reg.r;
temp:=0;
if spec_z80_reg.f.s then temp:=temp or $80;
if spec_z80_reg.f.z then temp:=temp or $40;
if spec_z80_reg.f.bit5 then temp:=temp or $20;
if spec_z80_reg.f.h then temp:=temp or $10;
if spec_z80_reg.f.bit3 then temp:=temp or 8;
if spec_z80_reg.f.p_v then temp:=temp or 4;
if spec_z80_reg.f.n then temp:=temp or 2;
if spec_z80_reg.f.c then temp:=temp or 1;
buffer[21]:=temp;
buffer[22]:=spec_z80_reg.a;
buffer[25]:=spec_z80_reg.im;
buffer[26]:=borde.color;
case main_vars.tipo_maquina of
        0,5:begin
             memoria[spec_z80_reg.sp-1]:=spec_z80_reg.pc shr 8;
             memoria[spec_z80_reg.sp-2]:=spec_z80_reg.pc and $ff;
             dec(spec_z80_reg.sp,2);
             buffer[23]:=spec_z80_reg.sp and $ff;
             buffer[24]:=spec_z80_reg.sp shr 8;
             inc(spec_z80_reg.sp,2);
             blockwrite(fichero,buffer[0],27);
             blockwrite(fichero,memoria[16384],49152);
          end;
        1,4:begin
             buffer[23]:=spec_z80_reg.sp and $ff;
             buffer[24]:=spec_z80_reg.sp shr 8;
             blockwrite(fichero,buffer[0],27);
             blockwrite(fichero,memoria_128k[5,0],16384);
             blockwrite(fichero,memoria_128k[2,0],16384);
             blockwrite(fichero,memoria_128k[marco[3],0],16384);
             buffer[0]:=spec_z80_reg.pc shr 8;
             buffer[1]:=spec_z80_reg.pc and $ff;
             buffer[2]:=old_7ffd;
             buffer[3]:=0;
             blockwrite(fichero,buffer[0],4);
             for temp:=0 to 7 do
                if ((temp<>2) and (temp<>5) and (temp<>marco[3])) then blockwrite(fichero,memoria_128k[temp,0],16384);
          end;
        else MessageDlg('Modelo no soportado formato SNA.'+chr(10)+chr(13)+'Model not supported for SNA format.', mtInformation,[mbOk], 0);
end;
close(fichero);
{$I+}
grabar_sna:=true;
end;

function grabar_z80(nombre:string;es_dsp:boolean):boolean;
const
  spectrum_48_scr:array[0..2] of byte=(8,4,5);
var
  r,datos:integer;
  fichero:file of byte;
  buffer:array[0..87] of byte;
  comprimido:pbyte;
  buffer3:array[0..2] of byte;
  temp:byte;
  spec_z80_reg:npreg_z80;
procedure write_data;
begin
  if r=$FFFF then begin
    buffer3[0]:=$ff;
    buffer3[1]:=$ff;
    r:=$4000;
  end else begin
    buffer3[0]:=r and $ff;
    buffer3[1]:=r shr 8;
  end;
  blockwrite(fichero,buffer3[0],3);
  blockwrite(fichero,comprimido^,r);
end;
begin
grabar_z80:=false;
{$I-}
//Grabo snapshot version 3, por el +3
assignfile(fichero,nombre);
rewrite(fichero);
spec_z80_reg:=spec_z80.get_internal_r;
buffer[0]:=spec_z80_reg.a;
temp:=0;
if spec_z80_reg.f.s then temp:=temp or $80;
if spec_z80_reg.f.z then temp:=temp or $40;
if spec_z80_reg.f.bit5 then temp:=temp or $20;
if spec_z80_reg.f.h then temp:=temp or $10;
if spec_z80_reg.f.bit3 then temp:=temp or 8;
if spec_z80_reg.f.p_v then temp:=temp or 4;
if spec_z80_reg.f.n then temp:=temp or 2;
if spec_z80_reg.f.c then temp:=temp or 1;
buffer[1]:=temp;
buffer[2]:=spec_z80_reg.bc.l;
buffer[3]:=spec_z80_reg.bc.h;
buffer[4]:=spec_z80_reg.hl.l;
buffer[5]:=spec_z80_reg.hl.h;
buffer[6]:=0;
buffer[7]:=0;
buffer[8]:=spec_z80_reg.sp and $ff;
buffer[9]:=spec_z80_reg.sp shr 8;
buffer[10]:=spec_z80_reg.i;
buffer[11]:=spec_z80_reg.r;
temp:=$20 or (borde.color shl 1);
if (spec_z80_reg.r and $80)=1 then temp:=temp or 1;
buffer[12]:=temp;
buffer[13]:=spec_z80_reg.de.l;
buffer[14]:=spec_z80_reg.de.h;
buffer[15]:=spec_z80_reg.bc2.l;
buffer[16]:=spec_z80_reg.bc2.h;
buffer[17]:=spec_z80_reg.de2.l;
buffer[18]:=spec_z80_reg.de2.h;
buffer[19]:=spec_z80_reg.hl2.l;
buffer[20]:=spec_z80_reg.hl2.h;
buffer[21]:=spec_z80_reg.a2;
temp:=0;
if spec_z80_reg.f2.s then temp:=temp or $80;
if spec_z80_reg.f2.z then temp:=temp or $40;
if spec_z80_reg.f2.bit5 then temp:=temp or $20;
if spec_z80_reg.f2.h then temp:=temp or $10;
if spec_z80_reg.f2.bit3 then temp:=temp or 8;
if spec_z80_reg.f2.p_v then temp:=temp or 4;
if spec_z80_reg.f2.n then temp:=temp or 2;
if spec_z80_reg.f2.c then temp:=temp or 1;
buffer[22]:=temp;
buffer[23]:=spec_z80_reg.iy.l;
buffer[24]:=spec_z80_reg.iy.h;
buffer[25]:=spec_z80_reg.ix.l;
buffer[26]:=spec_z80_reg.ix.h;
buffer[27]:=byte(spec_z80_reg.iff1);
buffer[28]:=byte(spec_z80_reg.iff2);
buffer[29]:=spec_z80_reg.im;
buffer[30]:=55;
buffer[31]:=0;
buffer[32]:=spec_z80_reg.pc and $ff;
buffer[33]:=spec_z80_reg.pc shr 8;
case main_vars.tipo_maquina of
  0,5:buffer[34]:=0;
  1,4:begin
      buffer[34]:=4;
      buffer[35]:=old_7ffd;
      buffer[38]:=ay8910_0.get_control;
      for datos:=0 to 15 do buffer[39+datos]:=ay8910_0.get_reg(datos);
    end;
  2,3:begin
      buffer[34]:=7;
      buffer[35]:=old_7ffd;
      buffer[38]:=ay8910_0.get_control;
      buffer[86]:=old_1ffd;
      for datos:=0 to 15 do buffer[39+datos]:=ay8910_0.get_reg(datos);
    end;
end;
buffer[36]:=0;
buffer[37]:=1;
blockwrite(fichero,buffer[0],87);
getmem(comprimido,$10000);
case main_vars.tipo_maquina of
  0,5:for temp:=0 to 2 do begin
        if es_dsp then Compress_zlib(@memoria[$4000+(temp*$4000)],16384,pointer(comprimido),r)
           else r:=comprimir_z80(@memoria[$4000+(temp*$4000)],comprimido);
        buffer3[2]:=spectrum_48_scr[temp];
        write_data;
      end;
    1,4:for temp:=3 to 10 do begin
        if es_dsp then Compress_zlib(@memoria_128k[temp-3,0],16384,pointer(comprimido),r)
          else r:=comprimir_z80(@memoria_128k[temp-3,0],comprimido);
        buffer3[2]:=temp;
        write_data;
      end;
    2,3:for temp:=3 to 10 do begin
        if es_dsp then Compress_zlib(@memoria_3[temp-3,0],16384,pointer(comprimido),r)
          else r:=comprimir_z80(@memoria_3[temp-3,0],comprimido);
        buffer3[2]:=temp;
        write_data;
      end;
end;
freemem(comprimido);
close(fichero);
{$I+}
grabar_z80:=true;
end;

function pagina_ram(numero:byte;destino:pbyte):integer;
var
  puntero,puntero2:pbyte;
  long:integer;
begin
getmem(puntero,$4000);
case main_vars.tipo_maquina of
  0:case numero of
        0:puntero2:=@memoria[$c000];
        2:puntero2:=@memoria[$8000];
        5:puntero2:=@memoria[$4000];
    end;
  1,4:puntero2:=@memoria_128k[numero,0];
  2,3:puntero2:=@memoria_3[numero,0];
  5:puntero2:=@memoria[$4000];
end;
Compress_zlib(puntero2,$4000,pointer(puntero),long);
//Ahora pongo los datos
puntero2:=destino;
puntero2^:=ord('R');inc(puntero2);
puntero2^:=ord('A');inc(puntero2);
puntero2^:=ord('M');inc(puntero2);
puntero2^:=ord('P');inc(puntero2);
puntero2^:=((long+3) mod 256);inc(puntero2); //longitud
puntero2^:=((long+3) div 256);inc(puntero2);
puntero2^:=0;inc(puntero2);
puntero2^:=0;inc(puntero2);
puntero2^:=1;inc(puntero2);   //word comprimido
puntero2^:=0;inc(puntero2);  //Comprimido
puntero2^:=numero;inc(puntero2); //Numero pagina
copymemory(puntero2,puntero,long);
pagina_ram:=long+11;
freemem(puntero);
end;

function grabar_szx(nombre:string):boolean;
var
  cadena:string;
  salida:pbyte;
  cantidad:integer;
  f:byte;
  fichero:file of byte;
  buffer:array[0..80] of byte;
  spec_z80_reg:npreg_z80;
begin
grabar_szx:=false;
{$I-}
assignfile(fichero,nombre);
rewrite(fichero);
buffer[0]:=ord('Z');
buffer[1]:=ord('X');
buffer[2]:=ord('S');
buffer[3]:=ord('T');
buffer[4]:=1;
buffer[5]:=1;
case main_vars.tipo_maquina of
  0:buffer[6]:=1;
  1:buffer[6]:=2;
  2:buffer[6]:=5;
  3:buffer[6]:=4;
  4:buffer[6]:=3;
  5:buffer[6]:=0;
end;
buffer[7]:=0;
blockwrite(fichero,buffer[0],8);
buffer[0]:=ord('C');
buffer[1]:=ord('R');
buffer[2]:=ord('T');
buffer[3]:=ord('R');
buffer[4]:=36;
buffer[5]:=0;
buffer[6]:=0;
buffer[7]:=0;
cadena:='DSP Emulator                    ';
for f:=1 to 32 do buffer[7+f]:=ord(cadena[f]);
buffer[40]:=0;
buffer[41]:=1;
buffer[42]:=4;
buffer[43]:=2;
blockwrite(fichero,buffer[0],44);
//Registros
buffer[0]:=ord('Z');
buffer[1]:=ord('8');
buffer[2]:=ord('0');
buffer[3]:=ord('R');
buffer[4]:=37;
buffer[5]:=0;
buffer[6]:=0;
buffer[7]:=0;
spec_z80_reg:=spec_z80.get_internal_r;
buffer[8]:=spec_z80_reg.a;
buffer[9]:=0;
if spec_z80_reg.f.s then buffer[9]:=buffer[9] or 128;
if spec_z80_reg.f.z then buffer[9]:=buffer[9] or 64;
if spec_z80_reg.f.bit5 then buffer[9]:=buffer[9] or 32;
if spec_z80_reg.f.h then buffer[9]:=buffer[9] or 16;
if spec_z80_reg.f.bit3 then buffer[9]:=buffer[9] or 8;
if spec_z80_reg.f.p_v then buffer[9]:=buffer[9] or 4;
if spec_z80_reg.f.n then buffer[9]:=buffer[9] or 2;
if spec_z80_reg.f.c then buffer[9]:=buffer[9] or 1;
buffer[10]:=spec_z80_reg.bc.l;
buffer[11]:=spec_z80_reg.bc.h;
buffer[12]:=spec_z80_reg.de.l;
buffer[13]:=spec_z80_reg.de.h;
buffer[14]:=spec_z80_reg.hl.l;
buffer[15]:=spec_z80_reg.hl.h;
buffer[16]:=spec_z80_reg.a2;
buffer[17]:=0;
if spec_z80_reg.f2.s then buffer[17]:=buffer[17] or 128;
if spec_z80_reg.f2.z then buffer[17]:=buffer[17] or 64;
if spec_z80_reg.f2.bit5 then buffer[17]:=buffer[17] or 32;
if spec_z80_reg.f2.h then buffer[17]:=buffer[17] or 16;
if spec_z80_reg.f2.bit3 then buffer[17]:=buffer[17] or 8;
if spec_z80_reg.f2.p_v then buffer[17]:=buffer[17] or 4;
if spec_z80_reg.f2.n then buffer[17]:=buffer[17] or 2;
if spec_z80_reg.f2.c then buffer[17]:=buffer[17] or 1;
buffer[18]:=spec_z80_reg.bc2.l;
buffer[19]:=spec_z80_reg.bc2.h;
buffer[20]:=spec_z80_reg.de2.l;
buffer[21]:=spec_z80_reg.de2.h;
buffer[22]:=spec_z80_reg.hl2.l;
buffer[23]:=spec_z80_reg.hl2.h;
buffer[24]:=spec_z80_reg.ix.l;
buffer[25]:=spec_z80_reg.ix.h;
buffer[26]:=spec_z80_reg.iy.l;
buffer[27]:=spec_z80_reg.iy.h;
buffer[28]:=spec_z80_reg.sp and $ff;
buffer[29]:=spec_z80_reg.sp shr 8;
buffer[30]:=spec_z80_reg.pc and $ff;
buffer[31]:=spec_z80_reg.pc shr 8;
buffer[32]:=spec_z80_reg.i;
buffer[33]:=spec_z80_reg.r;
buffer[34]:=byte(spec_z80_reg.iff1);
buffer[35]:=byte(spec_z80_reg.iff2);
buffer[36]:=spec_z80_reg.im;
buffer[37]:=0;
buffer[38]:=0;
buffer[39]:=0;
buffer[40]:=0; //dword
buffer[41]:=0;
if spec_z80.halt then buffer[42]:=2 else buffer[42]:=0;
buffer[43]:=0;
buffer[44]:=0;
blockwrite(fichero,buffer[0],45);
buffer[0]:=ord('S');
buffer[1]:=ord('P');
buffer[2]:=ord('C');
buffer[3]:=ord('R');
buffer[4]:=8;
buffer[5]:=0;
buffer[6]:=0;
buffer[7]:=0;
buffer[8]:=borde.color;
buffer[9]:=old_7ffd;
buffer[10]:=old_1ffd;
buffer[11]:=0;
buffer[12]:=0;
buffer[13]:=0;
buffer[14]:=0;
buffer[15]:=0;
blockwrite(fichero,buffer[0],16);
getmem(salida,$4100);
case main_vars.tipo_maquina of
  0:begin //Spectrum 48k
      cantidad:=pagina_ram(0,salida);
      blockwrite(fichero,salida^,cantidad);
      cantidad:=pagina_ram(2,salida);
      blockwrite(fichero,salida^,cantidad);
      cantidad:=pagina_ram(5,salida);
      blockwrite(fichero,salida^,cantidad);
    end;
  1,2,3,4:begin
      for f:=0 to 7 do begin
        cantidad:=pagina_ram(f,salida);
        blockwrite(fichero,salida^,cantidad);
      end;
      //Y despues el AY
      buffer[0]:=ord('A');
      buffer[1]:=ord('Y');
      buffer[2]:=0;
      buffer[3]:=0;
      buffer[4]:=18;
      buffer[5]:=0;
      buffer[6]:=0;
      buffer[7]:=0;
      buffer[8]:=0;
      buffer[9]:=ay8910_0.get_control;
      for f:=0 to 15 do buffer[10+f]:=ay8910_0.get_reg(f);
      blockwrite(fichero,buffer[0],26);
    end;
    5:begin //Spectrum 16k
        cantidad:=pagina_ram(5,salida);
        blockwrite(fichero,salida^,cantidad);
    end;
end;
freemem(salida);
close(fichero);
{$I+}
grabar_szx:=true;
end;

//Amstrad CPC
function grabar_amstrad_sna(nombre:string):boolean;
var
  fichero:file of byte;
  buffer:array[0..$ff] of byte;
  main_z80_reg:npreg_z80;
  f:byte;
begin
grabar_amstrad_sna:=false;
{$I-}
assignfile(fichero,nombre);
rewrite(fichero);
main_z80_reg:=main_z80.get_internal_r;
fillchar(buffer[0],$100,0);
//MV - SNA
buffer[0]:=ord('M');
buffer[1]:=ord('V');
buffer[2]:=ord(' ');
buffer[3]:=ord('-');
buffer[4]:=ord(' ');
buffer[5]:=ord('S');
buffer[6]:=ord('N');
buffer[7]:=ord('A');
buffer[16]:=3;
blockwrite(fichero,buffer[0],17);
if main_z80_reg.f.s then buffer[0]:=buffer[0] or $80;
if main_z80_reg.f.z then buffer[0]:=buffer[0] or $40;
if main_z80_reg.f.bit5 then buffer[0]:=buffer[0] or $20;
if main_z80_reg.f.h then buffer[0]:=buffer[0] or $10;
if main_z80_reg.f.bit3 then buffer[0]:=buffer[0] or $8;
if main_z80_reg.f.p_v then buffer[0]:=buffer[0] or $4;
if main_z80_reg.f.n then buffer[0]:=buffer[0] or $2;
if main_z80_reg.f.c then buffer[0]:=buffer[0] or $1;
buffer[1]:=main_z80_reg.a;
copymemory(@buffer[2],@main_z80_reg.bc.w,2);
copymemory(@buffer[4],@main_z80_reg.de.w,2);
copymemory(@buffer[6],@main_z80_reg.hl.w,2);
buffer[8]:=main_z80_reg.r;
buffer[9]:=main_z80_reg.i;
buffer[10]:=byte(main_z80_reg.iff1);
buffer[11]:=byte(main_z80_reg.iff2);
copymemory(@buffer[12],@main_z80_reg.ix.w,2);
copymemory(@buffer[14],@main_z80_reg.iy.w,2);
copymemory(@buffer[16],@main_z80_reg.sp,2);
copymemory(@buffer[18],@main_z80_reg.pc,2);
buffer[20]:=main_z80_reg.im;
if main_z80_reg.f2.s then buffer[21]:=buffer[21] or $80;
if main_z80_reg.f2.z then buffer[21]:=buffer[21] or $40;
if main_z80_reg.f2.bit5 then buffer[21]:=buffer[21] or $20;
if main_z80_reg.f2.h then buffer[21]:=buffer[21] or $10;
if main_z80_reg.f2.bit3 then buffer[21]:=buffer[21] or $8;
if main_z80_reg.f2.p_v then buffer[21]:=buffer[21] or $4;
if main_z80_reg.f2.n then buffer[21]:=buffer[21] or $2;
if main_z80_reg.f2.c then buffer[21]:=buffer[21] or $1;
buffer[22]:=main_z80_reg.a2;
copymemory(@buffer[23],@main_z80_reg.bc2.w,2);
copymemory(@buffer[25],@main_z80_reg.de2.w,2);
copymemory(@buffer[27],@main_z80_reg.hl2.w,2);
//GA
buffer[29]:=current_pen;
copymemory(@buffer[30],@cpcpal[0],17);
buffer[47]:=cpc_video_mode+(byte(not lowrom) shl 2)+(byte(not highrom) shl 3);
buffer[48]:=old_marco;
//CRT
buffer[49]:=current_crtc_reg;
copymemory(@buffer[50],@crtcreg[0],18);
if rom_selected=9 then buffer[68]:=0
  else buffer[68]:=7;
//PIA a,b,c,control
buffer[69]:=latch_ppi_read_a;
buffer[71]:=old_port_c_w;
buffer[72]:=pia_8255[0].control;
buffer[73]:=ay8910_0.get_control;
for f:=0 to $f do buffer[74+f]:=ay8910_0.get_reg(f);
case main_vars.tipo_maquina of
  7,8:buffer[90]:=64;
  9:buffer[90]:=128;
end;
//PSG control,reg
buffer[92]:=main_vars.tipo_maquina-7;
buffer[158]:=cont_vsync;
buffer[159]:=byte(crtc_vsync);
buffer[161]:=galc;
buffer[162]:=galines;
if main_z80.pedir_irq<>CLEAR_LINE then buffer[163]:=1;
blockwrite(fichero,buffer[0],239);
//Datos
case main_vars.tipo_maquina of
  7,8:for f:=0 to 3 do blockwrite(fichero,cpc_mem[f,0],$4000);
  9:for f:=0 to 7 do blockwrite(fichero,cpc_mem[f,0],$4000);
end;
close(fichero);
{$I+}
copymemory(@buffer_test[0],@buffer[0],256);
grabar_amstrad_sna:=true;
end;

function abrir_sna_cpc(data:pbyte;long:integer):boolean;
var
  buffer:array[0..239] of byte;
  f,version:byte;
  longitud:dword;
  main_z80_reg:npreg_z80;
  cadena:string;
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
longitud:=0;
for f:=0 to 7 do begin
  cadena:=cadena+chr(data^);
  inc(data);inc(longitud);
end;
if cadena<>'MV - SNA' then exit;
inc(data,8);inc(longitud,8);
version:=data^;
inc(data);inc(longitud);
getmem(main_z80_reg,sizeof(nreg_z80));
copymemory(@buffer[0],data,239);
inc(data,239);inc(longitud,239);
main_z80_reg.f.s:=(buffer[0] and 128)<>0;
main_z80_reg.f.z:=(buffer[0] and 64)<>0;
main_z80_reg.f.bit5:=(buffer[0] and 32)<>0;
main_z80_reg.f.h:=(buffer[0] and 16)<>0;
main_z80_reg.f.bit3:=(buffer[0] and 8)<>0;
main_z80_reg.f.p_v:=(buffer[0] and 4)<>0;
main_z80_reg.f.n:=(buffer[0] and 2)<>0;
main_z80_reg.f.c:=(buffer[0] and 1)<>0;
main_z80_reg.a:=buffer[1];
copymemory(@main_z80_reg.bc.w,@buffer[2],2);
copymemory(@main_z80_reg.de.w,@buffer[4],2);
copymemory(@main_z80_reg.hl.w,@buffer[6],2);
main_z80_reg.r:=buffer[8];
main_z80_reg.i:=buffer[9];
main_z80_reg.iff1:=buffer[10]<>0;
main_z80_reg.iff2:=buffer[11]<>0;
copymemory(@main_z80_reg.ix.w,@buffer[12],2);
copymemory(@main_z80_reg.iy.w,@buffer[14],2);
copymemory(@main_z80_reg.sp,@buffer[16],2);
copymemory(@main_z80_reg.pc,@buffer[18],2);
main_z80_reg.im:=buffer[20];
main_z80_reg.f2.s:=(buffer[21] and 128)<>0;
main_z80_reg.f2.z:=(buffer[21] and 64)<>0;
main_z80_reg.f2.bit5:=(buffer[21] and 32)<>0;
main_z80_reg.f2.h:=(buffer[21] and 16)<>0;
main_z80_reg.f2.bit3:=(buffer[21] and 8)<>0;
main_z80_reg.f2.p_v:=(buffer[21] and 4)<>0;
main_z80_reg.f2.n:=(buffer[21] and 2)<>0;
main_z80_reg.f2.c:=(buffer[21] and 1)<>0;
main_z80_reg.a2:=buffer[22];
copymemory(@main_z80_reg.bc2.w,@buffer[23],2);
copymemory(@main_z80_reg.de2.w,@buffer[25],2);
copymemory(@main_z80_reg.hl2.w,@buffer[27],2);
//GA
current_pen:=buffer[29];
copymemory(@cpcpal[0],@buffer[30],17);
write_ga($80+(buffer[47] and $3f));
copymemory(@mem_marco[0],@ram_banks[(buffer[48] and 7),0],4);
//CRT
write_crtc(0,buffer[49]);
for f:=0 to 17 do write_crtc($100,buffer[50+f]);
cpc_outbyte(buffer[68],$df00);
//PIA a,b,c,control
cpc_outbyte(buffer[72],$f782);
latch_ppi_read_a:=buffer[69];
port_c_write(buffer[71]);
//PSG control,reg
for f:=0 to $f do begin
  ay8910_0.control(f);
  ay8910_0.write(buffer[74+f]);
end;
ay8910_0.control(buffer[73]);
if buffer[90]=128 then begin
  for f:=0 to 7 do begin
    copymemory(@cpc_mem[f,0],data,$4000);
    inc(data,$4000);inc(longitud,$4000);
  end;
end else begin
  for f:=0 to 3 do begin
    copymemory(@cpc_mem[f,0],data,$4000);
    inc(data,$4000);inc(longitud,$4000);
  end;
end;
case version of
  1:begin
      if buffer[90]=128 then begin
        main_vars.tipo_maquina:=9;
        llamadas_maquina.caption:='Amstrad CPC 6128';
      end else begin
        main_vars.tipo_maquina:=8;
        llamadas_maquina.caption:='Amstrad CPC 664';
      end;
      init_rom_amstrad;
    end;
  2,3:begin
      case buffer[92] of
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
      end;
      init_rom_amstrad;
      if version=3 then begin
        cont_vsync:=buffer[158];
        crtc_vsync:=(buffer[159] and 1)<>0;
        galc:=buffer[161] and $3;
        galines:=buffer[162];
        if buffer[163]<>0 then main_z80.pedir_irq:=HOLD_LINE
          else main_z80.pedir_irq:=CLEAR_LINE;
      end;
    end;
end;
if longitud<>long then exit;
main_z80.set_internal_r(main_z80_reg);
freemem(main_z80_reg);
abrir_sna_cpc:=true;
end;

end.