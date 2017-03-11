unit tap_tzx;

{
 - Version 3.5
     - Mejoradas las cargas de los formatos, ahora uso bloques de datos
     - PZX
         - Corregidos algunos bloques
         - Mejorado el soporte de pulsos muy grandes
 - Version 3.4.1
     - Corregido CSW v1.0
 - Version 3.4
     - Mejorado el soporte de 'Genealized Data' (bloque $19) pulsos de 256 simbolos
     - Limpieza del bloque $19
}

interface

uses nz80,{$IFDEF WINDOWS}windows,{$ENDIF}grids,dialogs,main_engine,
     spectrum_misc,sysutils,lenguaje,misc_functions,tape_window,file_engine,
     lenslock,samples;

const
    MAX_TZX=$fff;

type
  tcsw_header=packed record
    magic:array[0..21] of ansichar;
    terminator:byte;
    major:byte;
    minor:byte;
  end;
  ttzx_header=packed record
    magic:array[0..6] of ansichar;
    eot:byte;
    major:byte;
    minor:byte;
  end;
  tpzx_header=packed record
    name:array[0..3] of ansichar;
    size:dword;
  end;
  tpzx_data=packed record
    bit_count:dword;
    tail:word;
    p0:byte;
    p1:byte;
  end;
  ttap_header=packed record
    size:word;
    flag:byte;
    header:byte;
    file_name:array[0..9] of ansichar;
    info:array[0..6] of byte;
  end;

  tsimbolos=record
              valor:array[0..$ff] of word;
              flag,total_sym:byte;
            end;
  ptsimbolos=^tsimbolos;
  tipo_datos_tzx=record
           tipo_bloque:byte;
           lcabecera:word;
           lsinc1:word;
           lsinc2:word;
           lcero:word;
           luno:word;
           ltono_cab:word;
           lbyte:byte;
           lpausa:word;
           lbloque:dword;
           salta_bloque:smallint;
           datos:Pbyte;
           crc32:dword;
           checksum:byte;
           pulsos_sym:array[0..$FF] of ptsimbolos;
           num_pulsos:word;
           pulse_num:byte;
           inicial:byte;
          end;
  ptipo_datos_tzx=^tipo_datos_tzx;
  tipo_cinta_tzx=record
            es_tap:boolean;
            play_tape:boolean;
            cargada:boolean;
            play_once:boolean;
            en_pausa:boolean;
            grupo:boolean;
            indice_cinta:word;
            estado_actual,bit_actual:byte;
            estados:dword;
            datos_tzx:array[0..MAX_TZX] of ptipo_datos_tzx;
            indice_saltos,indice_select:array[0..MAX_TZX] of word;
            value:byte;
            name:string;
          end;

var
 cinta_tzx:tipo_cinta_tzx;
 datos_totales_tzx:dword;

procedure vaciar_cintas;
procedure play_cinta_tap(z80_val:npreg_z80);
procedure play_cinta_tzx;
procedure siguiente_bloque_tzx;
function abrir_tap(datos:pbyte;long:integer):boolean;
function abrir_tzx(data:pbyte;long:integer):boolean;
function abrir_csw(data:pbyte;long:integer):boolean;
function abrir_wav(data:pbyte;long:integer):boolean;
function abrir_pzx(data:pbyte;long:integer):boolean;

implementation
uses spectrum_48k,spectrum_128k,spectrum_3;

const
  tabla_tzx:array[1..8] of byte=(128,64,32,16,8,4,2,1);

var
 indice_vuelta,indice_llamadas:word;
 tzx_contador_datos:integer;
 tzx_ultimo_bit,tzx_contador_loop:byte;
 tzx_temp,tzx_pulsos:dword;
 tzx_estados_necesarios:longword;
 tzx_datos_p:Pbyte;


function sacar_word(datos:pbyte):word;
var
  temp_w:word;
begin
  temp_w:=datos^;
  inc(datos);
  sacar_word:=temp_w or (datos^ shl 8);
end;

procedure zero_tape_data(num:word);
var
  f:byte;
begin
  cinta_tzx.datos_tzx[num].tipo_bloque:=0;
  cinta_tzx.datos_tzx[num].lcabecera:=0;
  cinta_tzx.datos_tzx[num].lsinc1:=0;
  cinta_tzx.datos_tzx[num].lsinc2:=0;
  cinta_tzx.datos_tzx[num].lcero:=0;
  cinta_tzx.datos_tzx[num].luno:=0;
  cinta_tzx.datos_tzx[num].ltono_cab:=0;
  cinta_tzx.datos_tzx[num].lbyte:=0;
  cinta_tzx.datos_tzx[num].lpausa:=0;
  cinta_tzx.datos_tzx[num].lbloque:=0;
  cinta_tzx.datos_tzx[num].salta_bloque:=0;
  cinta_tzx.datos_tzx[num].datos:=nil;
  cinta_tzx.datos_tzx[num].crc32:=0;
  cinta_tzx.datos_tzx[num].checksum:=0;
  cinta_tzx.datos_tzx[num].inicial:=0;
  for f:=0 to $ff do cinta_tzx.datos_tzx[num].pulsos_sym[f]:=nil;
end;

function calcular_pulso_inicial(datos:byte;num_pulsos:word):byte;
begin
case num_pulsos of
  2:calcular_pulso_inicial:=(datos and $80) shr 7;
  256:calcular_pulso_inicial:=datos;
end;
end;

function calcular_bit_actual_inicial(num_pulsos:word):byte;
begin
  case num_pulsos of
    2:calcular_bit_actual_inicial:=$80;
    256:calcular_bit_actual_inicial:=1;
  end;
end;

procedure play_cinta_tzx;
var
  temp_jump:smallint;
  ptemp:pbyte;
begin
if cinta_tzx.estados<=tzx_estados_necesarios then exit;
main_vars.mensaje_principal:='    '+leng[main_vars.idioma].mensajes[1]+': '+inttostr(datos_totales_tzx);
cinta_tzx.estados:=cinta_tzx.estados-tzx_estados_necesarios;
if cinta_tzx.en_pausa then begin
  cinta_tzx.indice_cinta:=cinta_tzx.indice_cinta+1;
  if cinta_tzx.es_tap then main_screen.rapido:=false;
  siguiente_bloque_tzx;
  cinta_tzx.en_pausa:=false;
  exit;
end;
if cinta_tzx.es_tap then begin
  cinta_tzx.es_tap:=false;
  main_screen.rapido:=true;
end;
case cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].tipo_bloque of
        $10,$11,$14:begin //cargas normal, turbo y datos puros
                   case cinta_tzx.estado_actual of
                        0:begin   //cabecera
                            cinta_tzx.value:=cinta_tzx.value Xor 64;
                            If tzx_temp<cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].ltono_cab  Then begin
                                tzx_estados_necesarios:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lcabecera;
                                tzx_temp:=tzx_temp+1;
                            end else begin
                                tzx_temp:=0;
                                if tzx_datos_p<>nil then begin
                                  cinta_tzx.estado_actual:=1;
                                  tzx_estados_necesarios:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lsinc1;
                                end else cinta_tzx.estado_actual:=4;
                            end;
                          end;
                        1:begin  //sync 1
                                cinta_tzx.value:=cinta_tzx.value Xor 64;
                                cinta_tzx.estado_actual:=2;
                                tzx_estados_necesarios:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lsinc2;
                          end;
                        2:begin  //sync 2
                                cinta_tzx.value:=cinta_tzx.value Xor 64;
                                cinta_tzx.estado_actual:=3;
                                if (tzx_datos_p^ and 128)<>0 then tzx_estados_necesarios:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].luno
                                        else tzx_estados_necesarios:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lcero;
                                cinta_tzx.bit_actual:=128;
                                tzx_pulsos:=2;
                                tzx_ultimo_bit:=1;
                          end;
                        3:begin  //datos
                                cinta_tzx.value:=cinta_tzx.value Xor 64;
                                tzx_pulsos:=tzx_pulsos-1; //hago la forma de la onda
                                if tzx_pulsos=0 then begin
                                  if cinta_tzx.bit_actual>tzx_ultimo_bit then begin //no estoy en el ultimo bit
                                        cinta_tzx.bit_actual:=cinta_tzx.bit_actual shr 1; //pillo el siguiente
                                        tzx_pulsos:=2;
                                        if (tzx_datos_p^ and cinta_tzx.bit_actual)<>0 then tzx_estados_necesarios:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].luno
                                           else tzx_estados_necesarios:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lcero;
                                  end else begin //estoy en el ultimo bit
                                      tzx_contador_datos:=tzx_contador_datos+1;
                                      datos_totales_tzx:=datos_totales_tzx+1;
                                      inc(tzx_datos_p); //incremento el byte en los datos
                                      if tzx_contador_datos<cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lbloque then begin  {¿se ha acabado?}
                                        if tzx_contador_datos=(cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lbloque-1) then tzx_ultimo_bit:=tabla_tzx[cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lbyte] else tzx_ultimo_bit:=1;
                                        cinta_tzx.bit_actual:=128;
                                        tzx_pulsos:=2;
                                        if (tzx_datos_p^ and 128)<>0 then tzx_estados_necesarios:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].luno
                                           else tzx_estados_necesarios:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lcero;
                                      end else begin   //pasar al otro bloque
                                        tzx_estados_necesarios:= cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lpausa*(llamadas_maquina.velocidad_cpu div 1000);
                                        cinta_tzx.en_pausa:=true;
                                      end;
                                  end;
                                end else if (tzx_datos_p^ and cinta_tzx.bit_actual)<>0 then tzx_estados_necesarios:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].luno
                                           else tzx_estados_necesarios:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lcero;
                                           //no ha completado la onda
                          end;
                        4:cinta_tzx.en_pausa:=true;
                   end; //del estado_actual
                 end;
        $12:begin //tono puro
                cinta_tzx.value:=cinta_tzx.value Xor 64;
                If tzx_temp<cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].ltono_cab Then begin
                        tzx_estados_necesarios:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lcabecera;
                        tzx_temp:=tzx_temp+1;
                end else begin
                  cinta_tzx.indice_cinta:=cinta_tzx.indice_cinta+1;
                  siguiente_bloque_tzx;
                end;
            end;
         $13:begin //secuencia de pulsos
                cinta_tzx.value:=cinta_tzx.value Xor 64;
                if tzx_pulsos<cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lbloque then begin
                        tzx_pulsos:=tzx_pulsos+1;
                        tzx_estados_necesarios:=sacar_word(tzx_datos_p);
                        inc(tzx_datos_p,2);
                        case tzx_estados_necesarios of
                          $FFFD:begin  //mismo pulso
                                 cinta_tzx.value:=cinta_tzx.value xor $40;
                                 tzx_estados_necesarios:=sacar_word(tzx_datos_p);
                                 inc(tzx_datos_p,2);
                                end;
                          $FFFE:begin  //forzar 0
                                 cinta_tzx.value:=$0;
                                 tzx_estados_necesarios:=sacar_word(tzx_datos_p);
                                 inc(tzx_datos_p,2);
                                end;
                          $FFFF:begin //forzar 1
                                 cinta_tzx.value:=$40;
                                 tzx_estados_necesarios:=sacar_word(tzx_datos_p);
                                 inc(tzx_datos_p,2);
                                end;
                        end;
                end else begin
                  cinta_tzx.indice_cinta:=cinta_tzx.indice_cinta+1;
                  siguiente_bloque_tzx;
                end;
            end;
        $15:begin //direct recording
                if cinta_tzx.bit_actual>tzx_ultimo_bit then begin //no estoy en el ultimo bit
                  tzx_estados_necesarios:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].luno;
                  cinta_tzx.bit_actual:=cinta_tzx.bit_actual shr 1; //pillo el siguiente
                  if (tzx_datos_p^ and cinta_tzx.bit_actual)<>0 then cinta_tzx.value:=$40 else cinta_tzx.value:=0;
                end else begin //estoy en el ultimo bit
                  tzx_estados_necesarios:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].luno;
                  tzx_contador_datos:=tzx_contador_datos+1;
                  datos_totales_tzx:=datos_totales_tzx+1;
                  inc(tzx_datos_p); //incremento el byte en los datos
                  if tzx_contador_datos<cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lbloque then begin  //¿se ha acabado?
                    if tzx_contador_datos=(cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lbloque-1) then tzx_ultimo_bit:=tabla_tzx[cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lbyte] else tzx_ultimo_bit:=1;
                    cinta_tzx.bit_actual:=128;
                    if (tzx_datos_p^ and 128)<>0 then cinta_tzx.value:=$40 else cinta_tzx.value:=0;
                  end else begin   //pasar al otro bloque
                    tzx_estados_necesarios:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lpausa*(llamadas_maquina.velocidad_cpu div 1000);
                    cinta_tzx.en_pausa:=true;
                  end;
                end;
            end;
        $19:begin  //datos especiales
                tzx_pulsos:=tzx_pulsos-1; //hago la forma de la onda
                cinta_tzx.value:=cinta_tzx.value xor $40;
                //Se ha terminado la onda...
                if tzx_pulsos=0 then begin
                  //estoy en el ultimo bit?
                  if cinta_tzx.bit_actual>1 then begin
                    //no
                    cinta_tzx.bit_actual:=cinta_tzx.bit_actual shr 1;
                    if (tzx_datos_p^ and cinta_tzx.bit_actual)<>0 then cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].pulse_num:=1
                      else cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].pulse_num:=0;
                    tzx_pulsos:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].pulsos_sym[cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].pulse_num].total_sym;
                    tzx_estados_necesarios:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].pulsos_sym[cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].pulse_num].valor[tzx_pulsos];
                  end else begin //estoy en el ultimo bit
                    tzx_contador_datos:=tzx_contador_datos+1;
                    datos_totales_tzx:=datos_totales_tzx+1;
                    //incremento el byte en los datos
                    inc(tzx_datos_p);
                    //se ha acabado?
                    if tzx_contador_datos<cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lbloque then begin
                      //No se ha acabado
                      //Calcular el pulso...
                      cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].pulse_num:=calcular_pulso_inicial(tzx_datos_p^,cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].num_pulsos);
                      cinta_tzx.bit_actual:=calcular_bit_actual_inicial(cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].num_pulsos);
                      tzx_pulsos:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].pulsos_sym[cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].pulse_num].total_sym;
                      tzx_estados_necesarios:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].pulsos_sym[cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].pulse_num].valor[tzx_pulsos];
                      case cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].pulsos_sym[cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].pulse_num].flag of
                              1:cinta_tzx.value:=cinta_tzx.value Xor 64;
                              2:cinta_tzx.value:=0;
                              3:cinta_tzx.value:=$40;
                      end;
                    end else begin  //Se ha terminado... hago la pausa
                      tzx_estados_necesarios:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lpausa*(llamadas_maquina.velocidad_cpu div 1000);
                      cinta_tzx.en_pausa:=true;
                    end;
                  end;
                end else begin
                  //Sigo haciendo la forma de la onda...
                  tzx_estados_necesarios:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].pulsos_sym[cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].pulse_num].valor[tzx_pulsos];
                end;
            end;
        $23:begin  //saltar a bloque
                cinta_tzx.indice_cinta:=cinta_tzx.indice_cinta+cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].salta_bloque;
                siguiente_bloque_tzx;
            end;
        $26:begin  //Call sequence
              if indice_llamadas<cinta_tzx.datos_tzx[indice_vuelta].lbloque then begin
                ptemp:=cinta_tzx.datos_tzx[indice_vuelta].datos;
                inc(ptemp,indice_llamadas*2);
                temp_jump:=smallint(sacar_word(ptemp));
                cinta_tzx.indice_cinta:=cinta_tzx.indice_cinta+temp_jump;
                indice_llamadas:=indice_llamadas+1;
              end else cinta_tzx.indice_cinta:=cinta_tzx.indice_cinta+1;
              siguiente_bloque_tzx;
            end;
         $f3:begin //secuencia de pulsos grandes
                cinta_tzx.value:=cinta_tzx.value Xor 64;
                if tzx_pulsos<cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lbloque then begin
                        tzx_pulsos:=tzx_pulsos+1;
                        tzx_estados_necesarios:=sacar_word(tzx_datos_p);
                        inc(tzx_datos_p,2);
                        tzx_estados_necesarios:=tzx_estados_necesarios or (sacar_word(tzx_datos_p) shl 16);
                        inc(tzx_datos_p,2);
                end else begin
                  cinta_tzx.indice_cinta:=cinta_tzx.indice_cinta+1;
                  siguiente_bloque_tzx;
                end;
            end;
        else begin
          cinta_tzx.indice_cinta:=cinta_tzx.indice_cinta+1;
          siguiente_bloque_tzx;
        end;
end;  //del tipo
end;

procedure siguiente_bloque_tzx;
var
   {$ifndef fpc}p:TGridRect;{$endif}
   f:byte;
   cadena:string;
   ptemp:pbyte;
begin
if not(cinta_tzx.grupo) then begin
  datos_totales_tzx:=0;
  {$ifndef fpc}
    p:=tape_window1.StringGrid1.Selection;
    p.top:=cinta_tzx.indice_saltos[cinta_tzx.indice_cinta];
    if ((tape_window1.StringGrid1.Row>6) and (tape_window1.StringGrid1.Row<(tape_window1.StringGrid1.RowCount-6)) and (tzx_contador_loop=0)) then tape_window1.StringGrid1.TopRow:=tape_window1.StringGrid1.Row-4;
    p.Bottom:=p.top;
    tape_window1.stringgrid1.Selection:=p;
    tape_window1.StringGrid1.Refresh;
  {$endif}
end;
cinta_tzx.estados:=0;
cinta_tzx.en_pausa:=false;
tzx_temp:=0;
tzx_datos_p:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].datos;
tzx_contador_datos:=0;
  case cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].tipo_bloque of
      $10,$11:begin //datos normal y turbo
{                   case cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].inicial of
                      1:cinta_tzx.value:=$40;
                      2:cinta_tzx.value:=$0;
                   end;}
                   tzx_estados_necesarios:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lcabecera;
                   cinta_tzx.estado_actual:=0;
                 end;
        $12:begin  //tono puro
                   tzx_estados_necesarios:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lcabecera;
                   tzx_temp:=1;
                 end;
        $13:begin  //secuencias de pulsos
                tzx_estados_necesarios:=sacar_word(tzx_datos_p);
                inc(tzx_datos_p,2);
                case tzx_estados_necesarios of
                  $FFFD:begin  //mismo pulso
                         cinta_tzx.value:=cinta_tzx.value xor $40;
                         tzx_estados_necesarios:=sacar_word(tzx_datos_p);
                         inc(tzx_datos_p,2);
                        end;
                  $FFFE:begin  //forzar 0
                         cinta_tzx.value:=0;
                         tzx_estados_necesarios:=sacar_word(tzx_datos_p);
                         inc(tzx_datos_p,2);
                        end;
                  $FFFF:begin //forzar 1
                         cinta_tzx.value:=$40;
                         tzx_estados_necesarios:=sacar_word(tzx_datos_p);
                         inc(tzx_datos_p,2);
                        end;
                  end;
                tzx_pulsos:=1;
            end;
        $14:begin //datos puros
                cinta_tzx.estado_actual:=3;
                if (tzx_datos_p^ and 128)<>0 then tzx_estados_necesarios:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].luno
                        else tzx_estados_necesarios:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lcero;
                cinta_tzx.bit_actual:=128;
                tzx_pulsos:=2;
                if (cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lbloque-1)=0 then tzx_ultimo_bit:=tabla_tzx[cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lbyte] else tzx_ultimo_bit:=1;
            end;
        $15:begin //direct recording
                tzx_estados_necesarios:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].luno;
                cinta_tzx.bit_actual:=128;
                if (cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lbloque-1)=0 then tzx_ultimo_bit:=tabla_tzx[cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lbyte] else tzx_ultimo_bit:=1;
            end;
        $19:begin //datos especiales
                //Calcular el simbolo
                cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].pulse_num:=calcular_pulso_inicial(tzx_datos_p^,cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].num_pulsos);
                cinta_tzx.bit_actual:=calcular_bit_actual_inicial(cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].num_pulsos);
                tzx_pulsos:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].pulsos_sym[cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].pulse_num].total_sym;
                //Aplicar simbolo
                tzx_estados_necesarios:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].pulsos_sym[cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].pulse_num].valor[tzx_pulsos];
                case (cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].pulsos_sym[cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].pulse_num].flag and 3) of
                      1:cinta_tzx.value:=cinta_tzx.value xor $40;
                      2:cinta_tzx.value:=0;
                      3:cinta_tzx.value:=$40;
                end;
            end;
        $20:begin //pausa
                tzx_estados_necesarios:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lpausa*(llamadas_maquina.velocidad_cpu div 1000);
                if tzx_estados_necesarios=0 then tape_window1.fStopCinta(nil);
                {if cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].datos^=0 then cinta_tzx.value:=0
                  else cinta_tzx.value:=$40}
            end;
        $21:begin //inicio grupo
                cinta_tzx.grupo:=true;
                tzx_estados_necesarios:=0;
            end;
        $22:begin //fin grupo
                cinta_tzx.grupo:=false;
                tzx_estados_necesarios:=0;
            end;
        $28,$30,$32,$33,$35,$23,$5a:tzx_estados_necesarios:=0;
        $2b:begin //Set signal level
              tzx_estados_necesarios:=0;
              if cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].datos^=0 then cinta_tzx.value:=$40
                 else cinta_tzx.value:=0;
            end;
        $31:begin
              cadena:='';
              ptemp:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].datos;
              for f:=1 to cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lbloque do begin
                cadena:=cadena+chr(ptemp^);
                inc(ptemp);
              end;
              MessageDlg(cadena, mtInformation,[mbOk], 0);
            end;
        $24:begin //loop start
                tzx_contador_loop:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lbloque;
                cinta_tzx.indice_cinta:=cinta_tzx.indice_cinta+1;
                siguiente_bloque_tzx;
            end;
        $25:begin //loop end
                dec(tzx_contador_loop);
                if tzx_contador_loop>0 then begin
                  cinta_tzx.indice_cinta:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lbloque;
                  siguiente_bloque_tzx;
                end else begin
                  cinta_tzx.indice_cinta:=cinta_tzx.indice_cinta+1;
                  siguiente_bloque_tzx;
                end;
            end;
        $26:begin
             indice_vuelta:=cinta_tzx.indice_cinta;
             indice_llamadas:=0;
             tzx_estados_necesarios:=0;
            end;
        $27:begin
              if cinta_tzx.datos_tzx[cinta_tzx.indice_cinta+1].tipo_bloque=$22 then cinta_tzx.grupo:=false;
              cinta_tzx.indice_cinta:=indice_vuelta;
              tzx_estados_necesarios:=0;
            end;
        $2a:if ((main_vars.tipo_maquina=0) or (main_vars.tipo_maquina=5)) then tape_window1.fStopCinta(nil) //stop if 48K
              else tzx_estados_necesarios:=0;
        $f3:begin  //secuencias de pulsos muy grandes
                tzx_estados_necesarios:=sacar_word(tzx_datos_p);
                inc(tzx_datos_p,2);
                tzx_estados_necesarios:=tzx_estados_necesarios or (sacar_word(tzx_datos_p) shl 16);
                inc(tzx_datos_p,2);
                tzx_pulsos:=1;
            end;
        $fe:begin //final de la cinta, la paro y me voy al principio
              cinta_tzx.indice_cinta:=0;
              tape_window1.StringGrid1.TopRow:=0;
              siguiente_bloque_tzx;
              cinta_tzx.play_once:=true;
              tape_window1.fStopCinta(nil);
            end;
      end;
{$ifdef fpc}
if not(cinta_tzx.grupo) then begin
    tape_window1.StringGrid1.row:=cinta_tzx.indice_saltos[cinta_tzx.indice_cinta];
    if ((tape_window1.StringGrid1.Row>6) and (tape_window1.StringGrid1.Row<(tape_window1.StringGrid1.RowCount-6)) and (tzx_contador_loop=0)) then tape_window1.StringGrid1.TopRow:=tape_window1.StringGrid1.Row-4;
end;
{$endif}
end;

procedure play_cinta_tap(z80_val:npreg_z80);
var
  checksum:byte;
  f,tam_bloque:word;
  ptemp:pbyte;
  bt:band_z80;
begin
main_screen.rapido:=true;
cinta_tzx.es_tap:=true;
ptemp:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].datos;
if cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lbloque>1 then begin
  checksum:=ptemp^;
  inc(ptemp);
end else begin
  checksum:=$ff;
end;
if checksum=z80_val.a2 then begin
    if z80_val.de.w>cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lbloque then tam_bloque:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lbloque else tam_bloque:=z80_val.de.w;
    for f:=0 to (tam_bloque-1) do begin
        case main_vars.tipo_maquina of
          0,5:spec48_putbyte(z80_val.ix.w+f,ptemp^); //48k and 16k
          1,4:spec128_putbyte(z80_val.ix.w+f,ptemp^); //128k and +2
          2,3:spec3_putbyte(z80_val.ix.w+f,ptemp^); //+2A and +3
        end;
        checksum:=checksum xor ptemp^;
        inc(ptemp);
    end;
    z80_val.f.c:=(checksum=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].checksum);
    z80_val.ix.w:=z80_val.ix.w+tam_bloque;
    z80_val.de.w:=0;
end;
datos_totales_tzx:=datos_totales_tzx+cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lbloque;
bt:=z80_val.f;z80_val.f:=z80_val.f2;z80_val.f2:=bt;
z80_val.pc:=$05e2;
tzx_estados_necesarios:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lpausa*(llamadas_maquina.velocidad_cpu div 1000);
cinta_tzx.en_pausa:=true;
end;

procedure vaciar_cintas;
var
  temp:word;
  f:byte;
begin
if not(tape_window1.Showing) then exit;
if cinta_tzx.cargada then begin
  cinta_tzx.en_pausa:=false;
  cinta_tzx.cargada:=false;
  if cinta_tzx.play_tape then cinta_tzx.play_tape:=false;
  temp:=0;
  while cinta_tzx.datos_tzx[temp]<>nil do begin
        for f:=0 to $ff do begin
          if cinta_tzx.datos_tzx[temp].pulsos_sym[f]<>nil then begin
            freemem(cinta_tzx.datos_tzx[temp].pulsos_sym[f]);
            cinta_tzx.datos_tzx[temp].pulsos_sym[f]:=nil;
          end;
        end;
        if cinta_tzx.datos_tzx[temp].datos<>nil then begin
          freemem(cinta_tzx.datos_tzx[temp].datos);
          cinta_tzx.datos_tzx[temp].datos:=nil;
        end;
        freemem(cinta_tzx.datos_tzx[temp]);
        cinta_tzx.datos_tzx[temp]:=nil;
        temp:=temp+1;
  end;
  fillchar(cinta_tzx.indice_saltos,MAX_TZX*2,0);
  fillchar(cinta_tzx.indice_select,MAX_TZX*2,0);
end;
cinta_tzx.es_tap:=false;
cinta_tzx.indice_cinta:=0;
llamadas_maquina.open_file:='';
change_caption;
tape_window1.stringgrid1.RowCount:=1;
var_spectrum.sd_1:=false;
if lenslock1.Showing then lenslock1.Close;
lenslok.activo:=false;
tape_window1.label2.caption:='';
end;

procedure analizar_tzx;
var
  indice:integer;
begin
indice:=0;
//comprobar LensLok
tape_window1.label2.caption:='';
var_spectrum.sd_1:=false;
lenslok.activo:=false;
lenslok.indice:=255;
while cinta_tzx.datos_tzx[indice].tipo_bloque<>$fe do begin
  case cinta_tzx.datos_tzx[indice].crc32 of
   $92DC40D8:var_spectrum.sd_1:=true; //Camelot Warriors con SD1
   $45169147,$ead7b3a9:begin //TT RACER
              lenslok.indice:=6;
              lenslok.activo:=true;
              break;
             end;
   $8B28031E,$881bd3e1:begin  //TOMAHAWK Spectrum & Amstrad
              lenslok.indice:=5;
              lenslok.activo:=true;
              break;
             end;
   $D6F54F87:begin //ART STUDIO
              lenslok.indice:=1;
              lenslok.activo:=true;
              break;
             end;
   $FAA60847,$DC38C227:begin //ELITE
              lenslok.indice:=2;
              lenslok.activo:=true;
              break;
             end;
   $F278B4A0,$1B81DD6D:begin //ACE
              lenslok.indice:=0;
              lenslok.activo:=true;
              break;
             end;
   $90152601:cinta_tzx.datos_tzx[indice].lbloque:=32; //Corrijo los cargadores de Amstrad de Opera
  end;
indice:=indice+1;
end;
tape_window1.label2.caption:='';
if lenslok.activo then begin
  lenslock1.combobox1.ItemIndex:=lenslok.indice;
  lenslock1.Show;
  tape_window1.label2.caption:='LensLok Protection Active';
end;
if var_spectrum.sd_1 then tape_window1.label2.caption:='SD1 Protection Active';
end;

//Ficheros TAP
function abrir_tap(datos:pbyte;long:integer):boolean;
var
  longitud:integer;
  indice:byte;
  cadena:string;
  tap_header:^ttap_header;
begin
abrir_tap:=false;
if datos=nil then exit;
getmem(tap_header,sizeof(ttap_header));
vaciar_cintas;
indice:=0;       //posicion de la cinta
longitud:=0;   //longitud que llevo
while longitud<long do begin
        getmem(cinta_tzx.datos_tzx[indice],sizeof(tipo_datos_tzx));
        zero_tape_data(indice);
        cinta_tzx.datos_tzx[indice].tipo_bloque:=$10;
        cinta_tzx.datos_tzx[indice].lpausa:=2000;
        cinta_tzx.datos_tzx[indice].lcabecera:=2168;
        cinta_tzx.datos_tzx[indice].lsinc1:=667;
        cinta_tzx.datos_tzx[indice].lsinc2:=735;
        cinta_tzx.datos_tzx[indice].lcero:=855;
        cinta_tzx.datos_tzx[indice].luno:=1710;
        cinta_tzx.datos_tzx[indice].lbyte:=8;
        //Recojo los datos
        copymemory(tap_header,datos,20);
        //Control de errores! Si la longitud es 0 que se salga!!
        if tap_header.size=0 then break;
        //Avanzo hasta los datos (quito la longitud que no es del Spectrum)
        inc(datos,2);inc(longitud,2);
        cinta_tzx.datos_tzx[indice].lbloque:=tap_header.size;
        if tap_header.flag=0 then cinta_tzx.datos_tzx[indice].ltono_cab:=8064
          else cinta_tzx.datos_tzx[indice].ltono_cab:=3220;
        if tap_header.size>0 then getmem(cinta_tzx.datos_tzx[indice].datos,tap_header.size)
          else getmem(cinta_tzx.datos_tzx[indice].datos,1);
        copymemory(cinta_tzx.datos_tzx[indice].datos,datos,tap_header.size);
        cinta_tzx.datos_tzx[indice].crc32:=calc_crc(cinta_tzx.datos_tzx[indice].datos,tap_header.size);
        //Avanzo el resto, menos uno, para ir al final y poner el checksum
        inc(datos,tap_header.size-1);inc(longitud,tap_header.size);
        if tap_header.size>1 then begin
          cinta_tzx.datos_tzx[indice].checksum:=datos^;
          inc(datos);
        end else cinta_tzx.datos_tzx[indice].checksum:=$ff;
        //Pongo los datos del bloque si la longitud del bloque es mayor que 20!
        if tap_header.size>18 then begin
          case tap_header.flag of
            $00:cadena:=leng[main_vars.idioma].cinta[0]+': '+tap_header.file_name; //cabecera
            $ff:cadena:=leng[main_vars.idioma].cinta[1]; //bytes
              else cadena:=leng[main_vars.idioma].cinta[2]; //datos
          end;
        end;
        tape_window1.stringgrid1.Cells[0,indice]:=cadena;
        tape_window1.stringgrid1.Cells[1,indice]:=inttostr(tap_header.size);
        //tape_window1.stringgrid1.Cells[2,temp]:=inttohex(cinta_tzx.datos_tzx[temp].crc32,8);
        indice:=indice+1;
        cinta_tzx.indice_saltos[indice]:=indice;
        cinta_tzx.indice_select[indice]:=indice;
        tape_window1.stringgrid1.RowCount:=tape_window1.stringgrid1.RowCount+1;
end;
freemem(tap_header);
tape_window1.stringgrid1.RowCount:=tape_window1.stringgrid1.RowCount-1;
//Si es el ultimo bloque, le quito la pausa...
cinta_tzx.datos_tzx[indice-1].lpausa:=0;
//Creo el bloque final
getmem(cinta_tzx.datos_tzx[indice],sizeof(tipo_datos_tzx));
zero_tape_data(indice);
cinta_tzx.datos_tzx[indice].tipo_bloque:=$fe;
cinta_tzx.datos_tzx[indice].lbloque:=1;
getmem(cinta_tzx.datos_tzx[indice].datos,1);
//Valores finales
cinta_tzx.play_tape:=false;
cinta_tzx.cargada:=true;
abrir_tap:=true;
siguiente_bloque_tzx;
analizar_tzx;
end;

//Ficheros WAV
function abrir_wav(data:pbyte;long:integer):boolean;
var
  ptemp_w,ptemp_w2:pword;
  ltemp,f:dword;
  ptemp_b:pbyte;
  temp_w:word;
  pos,vtemp:byte;
begin
abrir_wav:=false;
if not(convert_wav(data,ptemp_w,long,ltemp)) then exit;
vaciar_cintas;
//Crear el tipo de datos de la cinta
getmem(cinta_tzx.datos_tzx[0],sizeof(tipo_datos_tzx));
zero_tape_data(0);
cinta_tzx.datos_tzx[0].tipo_bloque:=$15;
cinta_tzx.datos_tzx[0].lpausa:=0;
cinta_tzx.datos_tzx[0].luno:=trunc(llamadas_maquina.velocidad_cpu/44100);
cinta_tzx.datos_tzx[0].lbloque:=ltemp div 8;
if (ltemp mod 8)<>0 then cinta_tzx.datos_tzx[0].lbloque:=cinta_tzx.datos_tzx[0].lbloque+1;
cinta_tzx.datos_tzx[0].lbyte:=ltemp mod 8;
getmem(cinta_tzx.datos_tzx[0].datos,cinta_tzx.datos_tzx[0].lbloque);
ptemp_b:=cinta_tzx.datos_tzx[0].datos;
//Descomprimir los datos
ptemp_w2:=ptemp_w;
pos:=0;
vtemp:=0;
for f:=0 to (ltemp-1) do begin
  temp_w:=ptemp_w2^;
  inc(ptemp_w2);
  if (temp_w and $8000)<>0 then vtemp:=vtemp or tabla_tzx[pos+1];
  pos:=pos+1;
  if pos=8 then begin
    ptemp_b^:=vtemp;
    inc(ptemp_b);
    vtemp:=0;
    pos:=0;
  end;
end;
if pos<>0 then ptemp_b^:=vtemp;
freemem(ptemp_w);
//Pongo la info
tape_window1.stringgrid1.RowCount:=1;
tape_window1.stringgrid1.Cells[0,0]:='Wave File';
tape_window1.stringgrid1.Cells[1,0]:=inttostr(cinta_tzx.datos_tzx[0].lbloque);
//Creo el bloque final
getmem(cinta_tzx.datos_tzx[1],sizeof(tipo_datos_tzx));
zero_tape_data(1);
cinta_tzx.datos_tzx[1].tipo_bloque:=$fe;
cinta_tzx.datos_tzx[1].lbloque:=1;
getmem(cinta_tzx.datos_tzx[1].datos,1);
//Valores finales
cinta_tzx.play_tape:=false;
cinta_tzx.cargada:=true;
siguiente_bloque_tzx;
abrir_wav:=true;
end;

//Ficheros CSW
type
  tcsw_t1=packed record
    sample_rate:word;
    compression:byte;
    flags:byte;
    unused:array[0..2] of byte;
  end;
  tcsw_t2=packed record
    sample_rate:dword;
    pulse_total:dword;
    compression:byte;
    flags:byte;
    header:byte;
    application:array[0..15] of ansichar;
  end;

function descomprimir_csw(datos_in,datos_out:pbyte;long_final:dword;polaridad_inicial:byte):dword;
var
  tempb,polaridad,pos_bit,dato_final:byte;
  contador,f,long_temp,longitud:dword;
begin
//Para el bucle de despues...
polaridad:=polaridad_inicial;
pos_bit:=7;
dato_final:=0;
long_temp:=0;
longitud:=0;
while longitud<long_final do begin
  tempb:=datos_in^;
  inc(datos_in);inc(longitud);
  //Si la duracion es mayor de 255 pulsos se almacena de la siguiente forma
  // 00 [duracion del pulso con cuatro bytes]
  //Si el pulso no es 0, simplemente es un contador
  if tempb=0 then begin
    copymemory(@contador,datos_in,4);
    inc(datos_in,4);inc(longitud,4);
  end else contador:=tempb;
  //Bucle de descompresion
  for f:=0 to (contador-1) do begin
    dato_final:=dato_final+(polaridad shl pos_bit);
    dec(pos_bit);
    //He terminado de ver los bits?
    if pos_bit=$FF then begin
      pos_bit:=7;
      datos_out^:=dato_final;
      inc(datos_out);
      dato_final:=0;
      inc(long_temp);
    end;
  end;
  //Invierto la polaridad
  polaridad:=polaridad xor 1;
end;
descomprimir_csw:=long_temp;
end;

function abrir_csw(data:pbyte;long:integer):boolean;
var
  long_final,longitud:integer;
  sample_rate:dword;
  datos_out,datos_out2:pbyte;
  csw_header:^tcsw_header;
  csw_t1:^tcsw_t1;
  csw_t2:^tcsw_t2;
begin
abrir_csw:=false;
if data=nil then exit;
vaciar_cintas;
getmem(csw_header,sizeof(tcsw_header));
longitud:=0;
copymemory(csw_header,data,25);
inc(data,25);inc(longitud,25);
if csw_header.magic<>'Compressed Square Wave' then begin
  freemem(csw_header);
  exit;
end;
getmem(csw_t1,sizeof(tcsw_t1));
getmem(csw_t2,sizeof(tcsw_t2));
case csw_header.major of
  1:begin
      copymemory(csw_t1,data,7);
      inc(data,7);inc(longitud,7);
      getmem(datos_out,long*10);
      long_final:=descomprimir_csw(data,datos_out,long-longitud,csw_t1.flags and 1);
      sample_rate:=csw_t1.sample_rate;
    end;
  2:begin
      copymemory(csw_t2,data,sizeof(tcsw_t2));
      inc(data,csw_t2.header+27);inc(longitud,csw_t2.header+27);
      sample_rate:=csw_t2.sample_rate;
      case csw_t2.compression of
        $01:begin
              getmem(datos_out,long*10);
              long_final:=descomprimir_csw(data,datos_out,long-longitud,csw_t2.flags and 1);
            end;
        $02:begin
              datos_out2:=nil;
              Decompress_zlib(pointer(data),long-longitud,pointer(datos_out2),long_final);
              getmem(datos_out,long_final*10);
              long_final:=descomprimir_csw(datos_out2,datos_out,long_final,csw_t2.flags and 1);
              freemem(datos_out2);
            end;
      end;
    end;
end;
//Creo el tipo de dato de la cinta
getmem(cinta_tzx.datos_tzx[0],sizeof(tipo_datos_tzx));
zero_tape_data(0);
cinta_tzx.datos_tzx[0].tipo_bloque:=$15;
cinta_tzx.datos_tzx[0].lpausa:=0;
cinta_tzx.datos_tzx[0].luno:=trunc(llamadas_maquina.velocidad_cpu/sample_rate);
cinta_tzx.datos_tzx[0].lbyte:=8;
cinta_tzx.datos_tzx[0].lbloque:=long_final;
getmem(cinta_tzx.datos_tzx[0].datos,long_final);
copymemory(cinta_tzx.datos_tzx[0].datos,datos_out,long_final);
freemem(datos_out);
//Pongo la info
if csw_header.minor<10 then tape_window1.stringgrid1.Cells[0,0]:='Compressed Square Wave v'+inttostr(csw_header.major)+'.0'+inttostr(csw_header.minor)
  else tape_window1.stringgrid1.Cells[0,0]:='Compressed Square Wave v'+inttostr(csw_header.major)+'.'+inttostr(csw_header.minor);
tape_window1.stringgrid1.RowCount:=1;
tape_window1.stringgrid1.Cells[1,0]:=inttostr(long_final);
//Creo el bloque final
getmem(cinta_tzx.datos_tzx[1],sizeof(tipo_datos_tzx));
zero_tape_data(1);
cinta_tzx.datos_tzx[1].tipo_bloque:=$fe;
cinta_tzx.datos_tzx[1].lbloque:=1;
getmem(cinta_tzx.datos_tzx[1].datos,1);
//Valores finales
cinta_tzx.play_tape:=false;
cinta_tzx.cargada:=true;
siguiente_bloque_tzx;
freemem(csw_header);
freemem(csw_t1);
freemem(csw_t2);
abrir_csw:=true;
end;

//TZX file format
type
  ttzx_cpc_header=packed record
    sync:byte;
    name:array[0..15] of ansichar;
    part:byte;
  end;
  ttzx_type_10=packed record
    pause:word;
    size:word;
  end;
  ttzx_type_11=packed record
    pilot_pulse:word;
    sync1:word;
    sync2:word;
    zero_bit:word;
    one_bit:word;
    pilot_length:word;
    last_byte:byte;
    pause:word;
    size1:word;
    size2:byte;
  end;
  ttzx_type_12=packed record
    one_pulse:word;
    number_pulse:word;
  end;
  ttzx_type_14=packed record
    zero_bit:word;
    one_bit:word;
    last_byte:byte;
    pause:word;
    size1:word;
    size2:byte;
  end;
  ttzx_type_15=packed record
    tstates:word;
    pause:word;
    last_byte:byte;
    size1:word;
    size2:byte;
  end;
  ttzx_type_19=packed record
    size:dword;
    pause:word;
    totp:dword;
    npp:byte;
    asp:byte;
    totd:dword;
    npd:byte;
    asd:byte;
  end;
  ttzx_gen_word=packed record
    valor:word;
  end;
  ttzx_type_35=packed record
    name:array[0..15] of ansichar;
    size:dword;
  end;

function abrir_tzx(data:pbyte;long:integer):boolean;
var
  g,h,temp,contador,inicio_grupo,pulsos_total,asp_tzx,asd_tzx,tempw:word;
  long_final,punto_loop,f,longitud:integer;
  ptemp:pbyte;
  cadena,cadena2,nombre_grupo:string;
  tempb,selector:byte;
  fin_grupo:boolean;
  crc_grupo:dword;
  pulsos:array[0..$FFFF] of word;
  simbolos:array[0..$1F] of tsimbolos;
  tzx_cpc_header:^ttzx_cpc_header;
  tzx_header:^ttzx_header;
  tap_header:^ttap_header;
  tzx_type_10:^ttzx_type_10;
  tzx_type_11:^ttzx_type_11;
  tzx_type_12:^ttzx_type_12;
  tzx_type_14:^ttzx_type_14;
  tzx_type_15:^ttzx_type_15;
  tzx_type_19:^ttzx_type_19;
  tzx_type_35:^ttzx_type_35;
  tzx_gen_word:^ttzx_gen_word;
begin
abrir_tzx:=false;
if data=nil then exit;
getmem(tzx_header,sizeof(ttzx_header));
copymemory(tzx_header,data,10);
//si no es una cinta TZX me salgo
if tzx_header.magic<>'ZXTape!' then begin
  freemem(tzx_header);
  exit;
end;
inc(data,10);longitud:=10;
vaciar_cintas;
long_final:=0; //longitud total del bloque
temp:=0;      //posicion saltos, siempre se incrementa
contador:=0;  //posicion cinta, solo se incrementa si no esta en un grupo
cinta_tzx.grupo:=false;  //indica si estoy dentro de un grupo
fin_grupo:=false; //corregir posicion cuando acaba el grupo
inicio_grupo:=0;
cinta_tzx.estados:=0;
while longitud<long do begin
        //Creo el bloque de la cinta
        getmem(cinta_tzx.datos_tzx[temp],sizeof(tipo_datos_tzx));
        zero_tape_data(temp);
        cinta_tzx.datos_tzx[temp].lbloque:=0;
        selector:=data^;
        inc(data);inc(longitud);
        case selector of
                $10:begin //carga normal con cabecera
                          getmem(tzx_type_10,sizeof(ttzx_type_10));
                          copymemory(tzx_type_10,data,4);
                          inc(data,4);inc(longitud,4);
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$10;
                          cinta_tzx.datos_tzx[temp].lpausa:=tzx_type_10.pause;
                          cinta_tzx.datos_tzx[temp].lbloque:=tzx_type_10.size;
                          cinta_tzx.datos_tzx[temp].lcabecera:=2168;
                          cinta_tzx.datos_tzx[temp].lsinc1:=667;
                          cinta_tzx.datos_tzx[temp].lsinc2:=735;
                          cinta_tzx.datos_tzx[temp].lcero:=855;
                          cinta_tzx.datos_tzx[temp].luno:=1710;
                          cinta_tzx.datos_tzx[temp].lbyte:=8;
                          cinta_tzx.datos_tzx[temp].ltono_cab:=3220;
                          getmem(cinta_tzx.datos_tzx[temp].datos,tzx_type_10.size);
                          copymemory(cinta_tzx.datos_tzx[temp].datos,data,tzx_type_10.size);
                          //El ultimo byte es el checksum
                          inc(data,tzx_type_10.size-1);inc(longitud,tzx_type_10.size);
                          inc(long_final,tzx_type_10.size);
                          freemem(tzx_type_10);
                          cinta_tzx.datos_tzx[temp].checksum:=data^;inc(data);
                          cadena:=leng[main_vars.idioma].cinta[2]; //datos
                          if ((main_vars.tipo_maquina=0) or (main_vars.tipo_maquina=1) or (main_vars.tipo_maquina=2) or (main_vars.tipo_maquina=3) or (main_vars.tipo_maquina=4) or (main_vars.tipo_maquina=5)) then begin
                              ptemp:=cinta_tzx.datos_tzx[temp].datos;dec(ptemp,2);
                              getmem(tap_header,sizeof(ttap_header));
                              copymemory(tap_header,ptemp,20);
                              case tap_header.flag of
                                $00:begin
                                      cinta_tzx.datos_tzx[temp].ltono_cab:=8064;
                                      cadena:=leng[main_vars.idioma].cinta[0]+': '+tap_header.file_name; //cabecera
                                    end;
                                $ff:cadena:=leng[main_vars.idioma].cinta[1]; //bytes
                                  else cadena:=leng[main_vars.idioma].cinta[2]; //datos
                              end;
                              freemem(tap_header);
                          end;
                       end;
                    $11:begin //carga turbo con cabecera
                          getmem(tzx_type_11,sizeof(ttzx_type_11));
                          copymemory(tzx_type_11,data,18);
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$11;
                          cinta_tzx.datos_tzx[temp].lcabecera:=tzx_type_11.pilot_pulse;
                          cinta_tzx.datos_tzx[temp].lsinc1:=tzx_type_11.sync1;
                          cinta_tzx.datos_tzx[temp].lsinc2:=tzx_type_11.sync2;
                          cinta_tzx.datos_tzx[temp].lcero:=tzx_type_11.zero_bit;
                          cinta_tzx.datos_tzx[temp].luno:=tzx_type_11.one_bit;
                          cinta_tzx.datos_tzx[temp].ltono_cab:=tzx_type_11.pilot_length;
                          cinta_tzx.datos_tzx[temp].lbyte:=tzx_type_11.last_byte;
                          cinta_tzx.datos_tzx[temp].lpausa:=tzx_type_11.pause;
                          cinta_tzx.datos_tzx[temp].lbloque:=tzx_type_11.size1+(tzx_type_11.size2*65536);
                          freemem(tzx_type_11);
                          inc(data,18);inc(longitud,18);
                          getmem(cinta_tzx.datos_tzx[temp].datos,cinta_tzx.datos_tzx[temp].lbloque);
                          copymemory(cinta_tzx.datos_tzx[temp].datos,data,cinta_tzx.datos_tzx[temp].lbloque);
                          inc(data,cinta_tzx.datos_tzx[temp].lbloque);inc(longitud,cinta_tzx.datos_tzx[temp].lbloque);
                          cadena:=leng[main_vars.idioma].cinta[3]; //bytes turbo
                          inc(long_final,cinta_tzx.datos_tzx[temp].lbloque);
                          if ((main_vars.tipo_maquina=7) or (main_vars.tipo_maquina=8) or (main_vars.tipo_maquina=9)) then begin
                              ptemp:=cinta_tzx.datos_tzx[temp].datos;
                              getmem(tzx_cpc_header,sizeof(ttzx_cpc_header));
                              copymemory(tzx_cpc_header,ptemp,18);
                              if tzx_cpc_header.sync=$2c then begin
                                cadena:=leng[main_vars.idioma].cinta[0]+': '+tzx_cpc_header.name;
                                cadena:=cadena+' ('+chr(48+(tzx_cpc_header.part div 10))+chr(48+(tzx_cpc_header.part mod 10))+')';
                              end;
                              freemem(tzx_cpc_header);
                          end;
                       end;
                    $12:begin  //tono puro
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$12;
                          getmem(tzx_type_12,sizeof(ttzx_type_12));
                          copymemory(tzx_type_12,data,4);
                          inc(data,4);inc(longitud,4);
                          cinta_tzx.datos_tzx[temp].lcabecera:=tzx_type_12.one_pulse;
                          cinta_tzx.datos_tzx[temp].ltono_cab:=tzx_type_12.number_pulse;
                          getmem(cinta_tzx.datos_tzx[temp].datos,1);
                          cadena:=leng[main_vars.idioma].cinta[4]; //Tono Puro
                          cadena2:=' ';
                          freemem(tzx_type_12);
                        end;
                    $13:begin //secuencia de pulsos
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$13;
                          tempb:=data^;
                          inc(data);inc(longitud);
                          //Cojo la cantidad de pulsos
                          cinta_tzx.datos_tzx[temp].lbloque:=tempb;
                          getmem(cinta_tzx.datos_tzx[temp].datos,tempb*2);
                          //Los guardo (los pulsos son word!! por lo que es la longitud*2)
                          copymemory(cinta_tzx.datos_tzx[temp].datos,data,tempb*2);
                          inc(data,tempb*2);inc(longitud,tempb*2);
                          cadena:=leng[main_vars.idioma].cinta[5]; //Secuencia Pulsos
                          cadena2:=' ';
                        end;
                    $14:begin  //datos puros
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$14;
                          getmem(tzx_type_14,sizeof(ttzx_type_14));
                          copymemory(tzx_type_14,data,10);
                          inc(data,10);inc(longitud,10);
                          cinta_tzx.datos_tzx[temp].lcero:=tzx_type_14.zero_bit;
                          cinta_tzx.datos_tzx[temp].luno:=tzx_type_14.one_bit;
                          cinta_tzx.datos_tzx[temp].lbyte:=tzx_type_14.last_byte;
                          cinta_tzx.datos_tzx[temp].lpausa:=tzx_type_14.pause;
                          cinta_tzx.datos_tzx[temp].lbloque:=tzx_type_14.size1+(tzx_type_14.size2*65536);
                          freemem(tzx_type_14);
                          getmem(cinta_tzx.datos_tzx[temp].datos,cinta_tzx.datos_tzx[temp].lbloque);
                          copymemory(cinta_tzx.datos_tzx[temp].datos,data,cinta_tzx.datos_tzx[temp].lbloque);
                          inc(data,cinta_tzx.datos_tzx[temp].lbloque);inc(longitud,cinta_tzx.datos_tzx[temp].lbloque);
                          cadena:=leng[main_vars.idioma].cinta[6]; //Datos Puros
                          inc(long_final,cinta_tzx.datos_tzx[temp].lbloque);
                        end;
                    $15:begin  //direct recording
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$15;
                          getmem(tzx_type_15,sizeof(ttzx_type_15));
                          copymemory(tzx_type_15,data,8);
                          inc(data,8);inc(longitud,8);
                          cinta_tzx.datos_tzx[temp].luno:=tzx_type_15.tstates;
                          cinta_tzx.datos_tzx[temp].lpausa:=tzx_type_15.pause;
                          cinta_tzx.datos_tzx[temp].lbyte:=tzx_type_15.last_byte;
                          cinta_tzx.datos_tzx[temp].lbloque:=tzx_type_15.size1+(tzx_type_15.size2*65536);
                          freemem(tzx_type_15);
                          getmem(cinta_tzx.datos_tzx[temp].datos,cinta_tzx.datos_tzx[temp].lbloque);
                          copymemory(cinta_tzx.datos_tzx[temp].datos,data,cinta_tzx.datos_tzx[temp].lbloque);
                          inc(data,cinta_tzx.datos_tzx[temp].lbloque);inc(longitud,cinta_tzx.datos_tzx[temp].lbloque);
                          cadena:=leng[main_vars.idioma].cinta[7]; //Grabacion Directa
                          inc(long_final,cinta_tzx.datos_tzx[temp].lbloque);
                        end;
                    $19:begin
                          getmem(tzx_type_19,sizeof(ttzx_type_19));
                          copymemory(tzx_type_19,data,18);
                          inc(data,18);inc(longitud,18);
                          //asp
                          if tzx_type_19.asp=0 then asp_tzx:=256
                            else asp_tzx:=tzx_type_19.asp;
                          //asd
                          if tzx_type_19.asd=0 then asd_tzx:=256
                            else asd_tzx:=tzx_type_19.asd;
                          //Creo grupo
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$21;
                          getmem(cinta_tzx.datos_tzx[temp].datos,1);
                          nombre_grupo:=leng[main_vars.idioma].cinta[10]+': Generalized Data';
                          inicio_grupo:=temp;
                          cinta_tzx.indice_saltos[temp]:=contador;
                          inc(temp);
                          //PILOT
                          //Si no hay simbolos no cojo nada
                          if tzx_type_19.totp<>0 then begin
                            //cojo los simbolos del alfabeto
                            for f:=1 to asp_tzx do begin
                                simbolos[f-1].flag:=data^;
                                inc(data);inc(longitud);
                                for g:=tzx_type_19.npp downto 1 do begin
                                  simbolos[f-1].valor[g-1]:=sacar_word(data);
                                  inc(data,2);inc(longitud,2);
                                end;
                            end;
                            //Y ahora relaciono repeticiones con simbolos
                            pulsos_total:=0;
                            for f:=1 to tzx_type_19.totp do begin
                              //¿que simbolo es?
                              tempb:=data^;
                              inc(data);inc(longitud);
                              //ver si el simbolo tiene flag
                              case simbolos[tempb].flag of
                                1:begin
                                     pulsos[pulsos_total]:=$FFFD;
                                     inc(pulsos_total);
                                  end;
                                2:begin
                                     pulsos[pulsos_total]:=$FFFE;
                                     inc(pulsos_total);
                                  end;
                                3:begin
                                     pulsos[pulsos_total]:=$FFFF;
                                     inc(pulsos_total);
                                  end;
                              end;
                              //cuantas veces lo repito?
                              copymemory(@tempw,data,2);
                              inc(data,2);inc(longitud,2);
                              for g:=1 to tempw do begin
                                for h:=0 to (tzx_type_19.npp-1) do begin
                                  pulsos[pulsos_total]:=simbolos[tempb].valor[h];
                                  if pulsos[pulsos_total]<>0 then inc(pulsos_total);
                                end;
                              end;
                            end;
                            //Y ahora lo convierto en un bloque de pulsos
                            getmem(cinta_tzx.datos_tzx[temp],sizeof(tipo_datos_tzx));
                            zero_tape_data(temp);
                            getmem(cinta_tzx.datos_tzx[temp].datos,pulsos_total*2);
                            copymemory(cinta_tzx.datos_tzx[temp].datos,@pulsos[0],pulsos_total*2);
                            cinta_tzx.datos_tzx[temp].lbloque:=pulsos_total;
                            cinta_tzx.datos_tzx[temp].tipo_bloque:=$13;
                            cinta_tzx.datos_tzx[temp].inicial:=0;
                            cinta_tzx.datos_tzx[temp].crc32:=calc_crc(cinta_tzx.datos_tzx[temp].datos,cinta_tzx.datos_tzx[temp].lbloque);
                            long_final:=0;
                            cinta_tzx.indice_saltos[temp]:=contador;
                            inc(temp);
                          end;
                          //DATOS
                          if tzx_type_19.totd<>0 then begin
                            getmem(cinta_tzx.datos_tzx[temp],sizeof(tipo_datos_tzx));
                            zero_tape_data(temp);
                            //Simbolos de los datos
                            for f:=1 to asd_tzx do begin
                              getmem(cinta_tzx.datos_tzx[temp].pulsos_sym[f-1],sizeof(tsimbolos));
                              fillchar(cinta_tzx.datos_tzx[temp].pulsos_sym[f-1]^,sizeof(tsimbolos),0);
                              cinta_tzx.datos_tzx[temp].pulsos_sym[f-1].flag:=data^;
                              cinta_tzx.datos_tzx[temp].pulsos_sym[f-1].total_sym:=tzx_type_19.npd;
                              inc(data);inc(longitud);
                              for g:=tzx_type_19.npd downto 1 do begin
                                cinta_tzx.datos_tzx[temp].pulsos_sym[f-1].valor[g]:=sacar_word(data);
                                inc(data,2);inc(longitud,2);
                              end;
                            end;
                            cinta_tzx.datos_tzx[temp].num_pulsos:=asd_tzx;
                            case asd_tzx of
                              2:cinta_tzx.datos_tzx[temp].lbloque:=tzx_type_19.totd div 8;
                              256:cinta_tzx.datos_tzx[temp].lbloque:=tzx_type_19.totd;
                                else MessageDlg('Simbolos div extraño!! '+inttostr(asd_tzx), mtInformation,[mbOk], 0);
                            end;
                            cinta_tzx.datos_tzx[temp].tipo_bloque:=$19;
                            getmem(cinta_tzx.datos_tzx[temp].datos,cinta_tzx.datos_tzx[temp].lbloque);
                            copymemory(cinta_tzx.datos_tzx[temp].datos,data,cinta_tzx.datos_tzx[temp].lbloque);
                            inc(data,cinta_tzx.datos_tzx[temp].lbloque);
                            inc(longitud,cinta_tzx.datos_tzx[temp].lbloque);
                            long_final:=long_final+cinta_tzx.datos_tzx[temp].lbloque;
                            cinta_tzx.indice_saltos[temp]:=contador;
                            cinta_tzx.datos_tzx[temp].lpausa:=tzx_type_19.pause;
                            inc(temp);
                          end;
                          getmem(cinta_tzx.datos_tzx[temp],sizeof(tipo_datos_tzx));
                          zero_tape_data(temp);
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$22;
                          getmem(cinta_tzx.datos_tzx[temp].datos,1);
                          fin_grupo:=true;
                          freemem(tzx_type_19);
                    end;
                    $20:begin //pausa
                          getmem(tzx_gen_word,sizeof(ttzx_gen_word));
                          copymemory(tzx_gen_word,data,2);
                          inc(data,2);inc(longitud,2);
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$20;
                          cinta_tzx.datos_tzx[temp].lcabecera:=0;
                          cinta_tzx.datos_tzx[temp].lpausa:=tzx_gen_word.valor;
                          getmem(cinta_tzx.datos_tzx[temp].datos,1);
                          if not(cinta_tzx.grupo) then begin
                            if tzx_gen_word.valor=0 then begin
                                cadena:=leng[main_vars.idioma].cinta[8]; //STOP the tape
                                cadena2:=' ';
                            end else begin
                                cadena:=leng[main_vars.idioma].cinta[9]; //Pausa
                                cadena2:=inttostr(tzx_gen_word.valor)+'ms.';
                            end;
                          end;
                          freemem(tzx_gen_word);
                          end;
                    $21:begin   //inicio del grupo
                          tempb:=data^;
                          inc(data);inc(longitud);
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$21;
                          cinta_tzx.datos_tzx[temp].lcabecera:=0;
                          cinta_tzx.datos_tzx[temp].lbloque:=tempb;
                          getmem(cinta_tzx.datos_tzx[temp].datos,tempb);
                          copymemory(cinta_tzx.datos_tzx[temp].datos,data,tempb);
                          inc(data,tempb);inc(longitud,tempb);
                          nombre_grupo:=leng[main_vars.idioma].cinta[10]+': '; //grupo
                          ptemp:=cinta_tzx.datos_tzx[temp].datos;
                          for f:=0 to (tempb-1) do begin
                            nombre_grupo:=nombre_grupo+chr(ptemp^);
                            inc(ptemp);
                          end;
                          inicio_grupo:=temp;
                          cinta_tzx.grupo:=true;
                        end;
                    $22:begin //fin grupo
                          cadena:=nombre_grupo;
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$22;
                          getmem(cinta_tzx.datos_tzx[temp].datos,1);
                          cinta_tzx.grupo:=false;
                          fin_grupo:=true;
                        end;
                    $23:begin //saltar a posicion
                          getmem(tzx_gen_word,sizeof(ttzx_gen_word));
                          copymemory(tzx_gen_word,data,2);
                          inc(data,2);inc(longitud,2);
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$23;
                          getmem(cinta_tzx.datos_tzx[temp].datos,1);
                          cinta_tzx.datos_tzx[temp].salta_bloque:=smallint(tzx_gen_word.valor);
                          cadena:=leng[main_vars.idioma].cinta[11]+' '+inttostr(smallint(tzx_gen_word.valor));
                          cadena2:=' ';
                          freemem(tzx_gen_word);
                        end;
                    $24:begin  //loop
                          getmem(tzx_gen_word,sizeof(ttzx_gen_word));
                          copymemory(tzx_gen_word,data,2);
                          inc(data,2);inc(longitud,2);
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$24;
                          cinta_tzx.datos_tzx[temp].lbloque:=tzx_gen_word.valor;
                          getmem(cinta_tzx.datos_tzx[temp].datos,1);
                          punto_loop:=temp+1;
                          cadena:=leng[main_vars.idioma].cinta[12]; //Loop
                          cadena2:=' ';
                          freemem(tzx_gen_word);
                         end;
                    $25:begin //loop next
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$25;
                          getmem(cinta_tzx.datos_tzx[temp].datos,1);
                          cinta_tzx.datos_tzx[temp].lbloque:=punto_loop;
                          cadena:=leng[main_vars.idioma].cinta[13];  //fin del loop
                          cadena2:=' ';
                        end;
                    $26:begin //Call sequence
                          getmem(tzx_gen_word,sizeof(ttzx_gen_word));
                          copymemory(tzx_gen_word,data,2);
                          inc(data,2);inc(longitud,2);
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$26;
                          cinta_tzx.datos_tzx[temp].lbloque:=tzx_gen_word.valor;
                          getmem(cinta_tzx.datos_tzx[temp].datos,tzx_gen_word.valor);
                          copymemory(cinta_tzx.datos_tzx[temp].datos,data,tzx_gen_word.valor*2);
                          inc(data,tzx_gen_word.valor*2);inc(longitud,tzx_gen_word.valor*2);
                          cadena:='Call Sequence';
                          cadena2:=' ';
                          freemem(tzx_gen_word);
                        end;
                    $27:begin //Return Call sequence
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$27;
                          getmem(cinta_tzx.datos_tzx[temp].datos,1);
                          cadena:='Return';
                          cadena2:=' ';
                        end;
                    $28:begin //select block
                          getmem(tzx_gen_word,sizeof(ttzx_gen_word));
                          copymemory(tzx_gen_word,data,2);
                          inc(data,2);inc(longitud,2);
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$28;
                          cinta_tzx.datos_tzx[temp].lbloque:=tzx_gen_word.valor;
                          getmem(cinta_tzx.datos_tzx[temp].datos,tzx_gen_word.valor);
                          copymemory(cinta_tzx.datos_tzx[temp].datos,data,tzx_gen_word.valor);
                          inc(data,tzx_gen_word.valor);inc(longitud,tzx_gen_word.valor);
                          cadena:='Select Block';
                          cadena2:=' ';
                          freemem(tzx_gen_word);
                        end;
                    $2a:begin  //stop the tape if 48k
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$2a;
                          getmem(cinta_tzx.datos_tzx[temp].datos,1);
                          inc(data,4);inc(longitud,4);
                          cadena:=leng[main_vars.idioma].cinta[14];
                          cadena2:=' ';
                        end;
                    $2b:begin //Set signal level
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$2b;
                          getmem(cinta_tzx.datos_tzx[temp].datos,1);
                          inc(data,4);inc(longitud,4);
                          cinta_tzx.datos_tzx[temp].datos^:=data^;
                          inc(data);inc(longitud);
                          cadena:='Set Signal Level';
                          cadena2:=' ';
                        end;
                    $30:begin //Text description
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$30;
                          cinta_tzx.datos_tzx[temp].lcabecera:=0;
                          tempb:=data^;
                          inc(data);inc(longitud);
                          cinta_tzx.datos_tzx[temp].lbloque:=tempb;
                          getmem(cinta_tzx.datos_tzx[temp].datos,tempb);
                          copymemory(cinta_tzx.datos_tzx[temp].datos,data,tempb);
                          inc(data,tempb);inc(longitud,tempb);
                          ptemp:=cinta_tzx.datos_tzx[temp].datos;
                          cadena:=leng[main_vars.idioma].cinta[15]+': ';
                          for f:=1 to tempb do begin
                                cadena:=cadena+chr(ptemp^);
                                inc(ptemp);
                          end;
                          cadena2:=' ';
                        end;
                    $31:begin  //mensaje
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$31;
                          cinta_tzx.datos_tzx[temp].lpausa:=data^*1000;
                          inc(data);
                          cinta_tzx.datos_tzx[temp].lcabecera:=0;
                          tempb:=data^;
                          cinta_tzx.datos_tzx[temp].lbloque:=tempb;
                          inc(data);inc(longitud,2);
                          getmem(cinta_tzx.datos_tzx[temp].datos,tempb);
                          copymemory(cinta_tzx.datos_tzx[temp].datos,data,tempb);
                          inc(data,tempb);inc(longitud,tempb);
                          cadena:=leng[main_vars.idioma].cinta[16];
                          cadena2:=' ';
                        end;
                    $32,$33:begin  //informacion
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=selector;
                          cinta_tzx.datos_tzx[temp].lcabecera:=0;
                          if selector=$32 then begin
                            cinta_tzx.datos_tzx[temp].lbloque:=sacar_word(data);
                            inc(data,2);inc(longitud,2);
                            cadena:=leng[main_vars.idioma].cinta[17]; //Archivo
                          end else begin
                            cinta_tzx.datos_tzx[temp].lbloque:=data^*3;
                            inc(data);inc(longitud);
                            cadena:=leng[main_vars.idioma].cinta[18]; //Hardware
                          end;
                          getmem(cinta_tzx.datos_tzx[temp].datos,cinta_tzx.datos_tzx[temp].lbloque);
                          copymemory(cinta_tzx.datos_tzx[temp].datos,data,cinta_tzx.datos_tzx[temp].lbloque);
                          inc(data,cinta_tzx.datos_tzx[temp].lbloque);inc(longitud,cinta_tzx.datos_tzx[temp].lbloque);
                          cadena2:=' ';
                        end;
                    $35:begin  //custom Data Block
                          getmem(tzx_type_35,sizeof(ttzx_type_35));
                          copymemory(tzx_type_35,data,20);
                          inc(data,20);inc(longitud,20);
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$35;
                          cinta_tzx.datos_tzx[temp].lbloque:=tzx_type_35.size;
                          cinta_tzx.datos_tzx[temp].lcabecera:=0;
                          getmem(cinta_tzx.datos_tzx[temp].datos,tzx_type_35.size);
                          copymemory(cinta_tzx.datos_tzx[temp].datos,data,tzx_type_35.size);
                          inc(data,tzx_type_35.size);inc(longitud,tzx_type_35.size);
                          cadena:='Custom Block: '''+tzx_type_35.name+'''';
                          cadena2:=' ';
                          freemem(tzx_type_35);
                        end;
                    $5A:begin //glue
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$5a;
                          getmem(cinta_tzx.datos_tzx[temp].datos,1);
                          inc(data,9);inc(longitud,9);
                          cadena:='Glue!';
                          cadena2:=' ';
                    end;
                    else begin
                            MessageDlg('Bloque TZX desconocido: '+inttohex(selector,2), mtInformation,[mbOk], 0);
                            exit;
                    end;
                end; //del case
        cinta_tzx.indice_saltos[temp]:=contador;
        if cinta_tzx.datos_tzx[temp].datos<>nil then cinta_tzx.datos_tzx[temp].crc32:=calc_crc(cinta_tzx.datos_tzx[temp].datos,cinta_tzx.datos_tzx[temp].lbloque)
           else cinta_tzx.datos_tzx[temp].crc32:=0;
        crc_grupo:=(crc_grupo+cinta_tzx.datos_tzx[temp].crc32) and $FFFFFFFF;
        if cadena2='' then tape_window1.stringgrid1.Cells[1,contador]:=inttostr(long_final)
            else tape_window1.stringgrid1.Cells[1,contador]:=cadena2;
        cadena2:='';
        if (not(cinta_tzx.grupo) and not(fin_grupo)) then begin
          tape_window1.stringgrid1.RowCount:=tape_window1.stringgrid1.RowCount+1;
          cinta_tzx.indice_select[contador]:=temp;
          tape_window1.stringgrid1.Cells[0,contador]:=cadena;
          //tape_window1.stringgrid1.Cells[2,contador]:=inttohex(cinta_tzx.datos_tzx[temp].crc32,8);
          inc(contador);
          long_final:=0;
        end;
        if fin_grupo then begin
          tape_window1.stringgrid1.RowCount:=tape_window1.stringgrid1.RowCount+1;
          fin_grupo:=false;
          tape_window1.stringgrid1.Cells[0,contador]:=nombre_grupo;
          //tape_window1.stringgrid1.Cells[2,contador]:=inttohex(crc_grupo,8);
          cinta_tzx.indice_select[contador]:=inicio_grupo;
          cinta_tzx.datos_tzx[temp].crc32:=crc_grupo;
          inc(contador);
          long_final:=0;
        end;
        inc(temp);
end; //del while not
freemem(tzx_header);
//Creo el bloque final
tape_window1.stringgrid1.RowCount:=tape_window1.stringgrid1.RowCount-1;
getmem(cinta_tzx.datos_tzx[temp],sizeof(tipo_datos_tzx));
zero_tape_data(temp);
cinta_tzx.datos_tzx[temp].tipo_bloque:=$fe;
cinta_tzx.datos_tzx[temp].lbloque:=1;
getmem(cinta_tzx.datos_tzx[temp].datos,1);
//Datos finales
cinta_tzx.play_tape:=false;
cinta_tzx.cargada:=true;
cinta_tzx.play_once:=false;
siguiente_bloque_tzx;
abrir_tzx:=true;
analizar_tzx;
end;

//Ficheros PZX
type
  tpzx_pulse=packed record
    pulse_length:word;
    duration1:word;
    duration2:word;
  end;
  tpzx_pause=packed record
    pause:dword;
  end;

function abrir_pzx(data:pbyte;long:integer):boolean;
const
  MAX_PULSES=$1000;
var
  cadena2,cadena3:string;
  longitud:integer;
  pulsos_long:array[0..(MAX_PULSES-1)] of dword;
  datos_ok:boolean;
  tempw,contador,pulse_count,puls_total_long:word;
  f,tempdw,pulse_length,pzx_tail:dword;
  ptemp:pbyte;
  pzx_header:^tpzx_header;
  pzx_pulse:^tpzx_pulse;
  pzx_data:^tpzx_data;
  pzx_pause:^tpzx_pause;
begin
//inicio
abrir_pzx:=false;
if data=nil then exit;
cinta_tzx.grupo:=false;
getmem(pzx_header,sizeof(tpzx_header));
copymemory(pzx_header,data,8);
inc(data,8);longitud:=8;
if pzx_header.name<>'PZXT' then begin
  freemem(pzx_header);
  exit;
end;
//Aqui dentro hay informacion, pero de momento no la muestro...
inc(data,pzx_header.size);inc(longitud,pzx_header.size);
vaciar_cintas;
contador:=0; //posicion en la cinta
cinta_tzx.estados:=0;
//bucle
while longitud<long do begin
  cadena3:='';
  //Si tiene mas de 4080 bloques, no puedo cargar mas...
  if contador>(MAX_TZX-16) then begin
    MessageDlg('Cinta PZX demasiado grande.', mtInformation,[mbOk], 0);
    vaciar_cintas;
    freemem(pzx_header);
    exit;
  end;
  //Creo el bloque de la cinta...
  getmem(cinta_tzx.datos_tzx[contador],sizeof(tipo_datos_tzx));
  zero_tape_data(contador);
  copymemory(pzx_header,data,8);
  inc(data,8);inc(longitud,8);
  ptemp:=data;
  inc(data,pzx_header.size);inc(longitud,pzx_header.size);  //La incremento
  datos_ok:=false;
  if pzx_header.name='PULS' then begin
    tempdw:=0;
    puls_total_long:=0;
    getmem(pzx_pulse,sizeof(tpzx_pulse));
    while tempdw<pzx_header.size do begin
      //Cojo el contador
      copymemory(pzx_pulse,ptemp,6);
      inc(ptemp,2);inc(tempdw,2);
      pulse_count:=1;
      //Si tiene el bit 15, es que se repite...
      pulse_length:=pzx_pulse.pulse_length;
      if (pulse_length>$8000) then begin
        pulse_count:=pulse_length and $7FFF;
        pulse_length:=pzx_pulse.duration1;
        inc(ptemp,2);inc(tempdw,2);
      end;
      //Si tiene el bit 15, la duracion se basa en duracion2 de la cabecera...
      if (pulse_length and $8000)<>0 then begin
        pulse_length:=((pulse_length and $7fff) shl 16) or pzx_pulse.duration2;
        inc(ptemp,2);inc(tempdw,2);
      end;
      //Creo un bloque de pulsos en la cinta...
      for f:=1 to pulse_count do begin
        pulsos_long[puls_total_long]:=pulse_length;
        //Si es muy grande, creo un bloque y vuelvo a empezar...
        if puls_total_long=(MAX_PULSES-1) then begin
          getmem(cinta_tzx.datos_tzx[contador].datos,MAX_PULSES*4);
          copymemory(cinta_tzx.datos_tzx[contador].datos,@pulsos_long[0],MAX_PULSES*4);
          cinta_tzx.datos_tzx[contador].lbloque:=MAX_PULSES;
          cinta_tzx.datos_tzx[contador].tipo_bloque:=$F3;
          cinta_tzx.datos_tzx[contador].inicial:=0;
          cinta_tzx.indice_saltos[contador]:=contador;
          cinta_tzx.indice_select[contador]:=contador;
          cinta_tzx.datos_tzx[contador].crc32:=calc_crc(cinta_tzx.datos_tzx[contador].datos,MAX_PULSES);
          tape_window1.stringgrid1.RowCount:=tape_window1.stringgrid1.RowCount+1;
          tape_window1.stringgrid1.Cells[1,contador]:=' ';
          tape_window1.stringgrid1.Cells[0,contador]:=leng[main_vars.idioma].cinta[5];
          puls_total_long:=0;
          //Otro bloque...
          inc(contador);
          getmem(cinta_tzx.datos_tzx[contador],sizeof(tipo_datos_tzx));
          zero_tape_data(contador);
        end else puls_total_long:=puls_total_long+1;
      end;
    end;
    //Ya he terminado de coger los datos, resto de datos en un ultimo bloque
    getmem(cinta_tzx.datos_tzx[contador].datos,puls_total_long*4);
    copymemory(cinta_tzx.datos_tzx[contador].datos,@pulsos_long[0],puls_total_long*4);
    cinta_tzx.datos_tzx[contador].lbloque:=puls_total_long;
    cinta_tzx.datos_tzx[contador].tipo_bloque:=$F3;
    cinta_tzx.datos_tzx[contador].inicial:=0;
    cinta_tzx.indice_saltos[contador]:=contador;
    cinta_tzx.indice_select[contador]:=contador;
    cinta_tzx.datos_tzx[contador].crc32:=calc_crc(cinta_tzx.datos_tzx[contador].datos,cinta_tzx.datos_tzx[contador].lbloque);
    tape_window1.stringgrid1.RowCount:=tape_window1.stringgrid1.RowCount+1;
    tape_window1.stringgrid1.Cells[1,contador]:=' ';
    tape_window1.stringgrid1.Cells[0,contador]:=leng[main_vars.idioma].cinta[5];
    cadena3:=leng[main_vars.idioma].cinta[5]; //Secuencia Pulsos
    cadena2:=' ';
    cinta_tzx.datos_tzx[contador].inicial:=0;
    datos_ok:=true;
    freemem(pzx_pulse);
  end;
  if pzx_header.name='PAUS' then begin
    getmem(pzx_pause,sizeof(tpzx_pause));
    copymemory(pzx_pause,ptemp,4);
    cinta_tzx.datos_tzx[contador].tipo_bloque:=$20;
    inc(ptemp,4);
    cinta_tzx.datos_tzx[contador].lpausa:=(pzx_pause.pause and $7fffffff) div (llamadas_maquina.velocidad_cpu div 1000);
    getmem(cinta_tzx.datos_tzx[contador].datos,1);
    cinta_tzx.datos_tzx[contador].datos^:=pzx_pause.pause shr 31;
    cadena3:=leng[main_vars.idioma].cinta[9]; //Pausa
    cadena2:=inttostr(cinta_tzx.datos_tzx[contador].lpausa)+'ms.';
    datos_ok:=true;
  end;
  if pzx_header.name='DATA' then begin
    getmem(pzx_data,sizeof(tpzx_data));
    //Solo hay dos simbolos
    getmem(cinta_tzx.datos_tzx[contador].pulsos_sym[0],sizeof(tsimbolos));
    fillchar(cinta_tzx.datos_tzx[contador].pulsos_sym[0]^,sizeof(tsimbolos),0);
    getmem(cinta_tzx.datos_tzx[contador].pulsos_sym[1],sizeof(tsimbolos));
    fillchar(cinta_tzx.datos_tzx[contador].pulsos_sym[1]^,sizeof(tsimbolos),0);
    cinta_tzx.datos_tzx[contador].num_pulsos:=2;
    copymemory(pzx_data,ptemp,8);
    inc(ptemp,8);
    //pulsos finales, los creo despues de arreglar las vistas...
    pzx_tail:=pzx_data.tail;
    //Bit 0-30 longitud el bit 31 valor inicial del ear...
    if (pzx_data.bit_count and $80000000)<>0 then cinta_tzx.datos_tzx[contador].inicial:=3
      else cinta_tzx.datos_tzx[contador].inicial:=2;
    pzx_data.bit_count:=pzx_data.bit_count and $7FFFFFFF;
    //pulsos para formar la longitud del 0
    cinta_tzx.datos_tzx[contador].pulsos_sym[0].total_sym:=pzx_data.p0;
    for f:=1 to pzx_data.p0 do begin
      cinta_tzx.datos_tzx[contador].pulsos_sym[0].valor[f]:=sacar_word(ptemp);
      cinta_tzx.datos_tzx[contador].pulsos_sym[0].flag:=0;
      inc(ptemp,2);
    end;
    //pulsos para formar la longitud del 1
    cinta_tzx.datos_tzx[contador].pulsos_sym[1].total_sym:=pzx_data.p1;
    for f:=1 to pzx_data.p1 do begin
      cinta_tzx.datos_tzx[contador].pulsos_sym[1].valor[f]:=sacar_word(ptemp);
      cinta_tzx.datos_tzx[contador].pulsos_sym[1].flag:=0;
      inc(ptemp,2);
    end;
    cinta_tzx.datos_tzx[contador].lbloque:=pzx_data.bit_count div 8;
    if (pzx_data.bit_count mod 8)=0 then begin
      cinta_tzx.datos_tzx[contador].lbyte:=8;
    end else begin
      cinta_tzx.datos_tzx[contador].lbloque:=cinta_tzx.datos_tzx[contador].lbloque+1;
      cinta_tzx.datos_tzx[contador].lbyte:=pzx_data.bit_count mod 8;
    end;
    cinta_tzx.datos_tzx[contador].tipo_bloque:=$19;
    getmem(cinta_tzx.datos_tzx[contador].datos,cinta_tzx.datos_tzx[contador].lbloque);
    copymemory(cinta_tzx.datos_tzx[contador].datos,ptemp,cinta_tzx.datos_tzx[contador].lbloque);
    cadena3:='Generalized Data';
    freemem(pzx_data);
    datos_ok:=true;
  end;
  if pzx_header.name='BRWS' then begin
    cinta_tzx.datos_tzx[contador].tipo_bloque:=$30;
    cinta_tzx.datos_tzx[contador].lbloque:=pzx_header.size;
    getmem(cinta_tzx.datos_tzx[contador].datos,pzx_header.size);
    copymemory(cinta_tzx.datos_tzx[contador].datos,ptemp,pzx_header.size);
    cadena3:=leng[main_vars.idioma].cinta[15]+': ';
    cadena2:=' ';
    for f:=1 to pzx_header.size do begin
      cadena3:=cadena3+chr(ptemp^);
      inc(ptemp);
    end;
    datos_ok:=true;
  end;
  if pzx_header.name='STOP' then begin
    tempw:=sacar_word(ptemp);
    case tempw of
      0:begin
          cinta_tzx.datos_tzx[contador].tipo_bloque:=$20;
          cadena3:=leng[main_vars.idioma].cinta[8];
        end;
      1:begin
          cinta_tzx.datos_tzx[contador].tipo_bloque:=$2a;
          cadena3:=leng[main_vars.idioma].cinta[14];
        end;
    end;
    getmem(cinta_tzx.datos_tzx[contador].datos,1);
    cadena2:=' ';
    datos_ok:=true;
  end;
  if pzx_header.name='PZXT' then begin
    cinta_tzx.datos_tzx[contador].tipo_bloque:=$5a;
    getmem(cinta_tzx.datos_tzx[contador].datos,1);
    cadena3:='Glue!';
    cadena2:=' ';
    datos_ok:=true;
  end;
  if not(datos_ok) then begin
     MessageDlg('Bloque desconocido '+pzx_header.name, mtInformation,[mbOk], 0);
     vaciar_cintas;
     exit;
  end;
  //Pongo descripcion
  cinta_tzx.indice_saltos[contador]:=contador;
  cinta_tzx.indice_select[contador]:=contador;
  cinta_tzx.datos_tzx[contador].crc32:=calc_crc(cinta_tzx.datos_tzx[contador].datos,cinta_tzx.datos_tzx[contador].lbloque);
  tape_window1.stringgrid1.RowCount:=tape_window1.stringgrid1.RowCount+1;
  if cadena2='' then tape_window1.stringgrid1.Cells[1,contador]:=inttostr(cinta_tzx.datos_tzx[contador].lbloque)
      else tape_window1.stringgrid1.Cells[1,contador]:=cadena2;
  cadena2:='';
  tape_window1.stringgrid1.Cells[0,contador]:=cadena3;
  //Tail del data...
    if pzx_tail<>0 then begin
      inc(contador);
      getmem(cinta_tzx.datos_tzx[contador],sizeof(tipo_datos_tzx));
      zero_tape_data(contador);
      getmem(cinta_tzx.datos_tzx[contador].datos,4);
      copymemory(cinta_tzx.datos_tzx[contador].datos,@pzx_tail,4);
      cinta_tzx.datos_tzx[contador].lbloque:=1;
      cinta_tzx.datos_tzx[contador].tipo_bloque:=$F3;
      cinta_tzx.datos_tzx[contador].inicial:=0;
      cinta_tzx.indice_saltos[contador]:=contador;
      cinta_tzx.indice_select[contador]:=contador;
      tape_window1.stringgrid1.RowCount:=tape_window1.stringgrid1.RowCount+1;
      tape_window1.stringgrid1.Cells[1,contador]:=' ';
      tape_window1.stringgrid1.Cells[0,contador]:='Tail Pulse';
      pzx_tail:=0;
    end;
  inc(contador);
end; //fin del while
//final
tape_window1.stringgrid1.RowCount:=tape_window1.stringgrid1.RowCount-1;
getmem(cinta_tzx.datos_tzx[contador],sizeof(tipo_datos_tzx));
zero_tape_data(contador);
cinta_tzx.datos_tzx[contador].tipo_bloque:=$fe;
cinta_tzx.datos_tzx[contador].lbloque:=1;
getmem(cinta_tzx.datos_tzx[contador].datos,1);
cinta_tzx.play_tape:=false;
cinta_tzx.cargada:=true;
cinta_tzx.play_once:=false;
siguiente_bloque_tzx;
abrir_pzx:=true;
analizar_tzx;
end;

end.

