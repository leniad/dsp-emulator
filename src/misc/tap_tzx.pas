unit tap_tzx;

{
 - Version 3.4.1
     - Corregido CSW v1.0
 - Version 3.4
     - Mejorado el soporte de 'Genealized Data' (bloque $19) pulsos de 256 simbolos
     - Limpiza del bloque $19
}

interface

uses nz80,z80_sp,{$IFDEF WINDOWS}windows,{$ENDIF}dialogs,main_engine,spectrum_misc,
     principal,grids,sysutils,lenguaje,misc_functions,tape_window,file_engine,
     lenslock,samples;

const
  tabla_tzx:array[1..8] of byte=(128,64,32,16,8,4,2,1);
  max_tzx=$fff;

type
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
            datos_tzx:array[0..max_tzx] of ptipo_datos_tzx;
            indice_saltos,indice_select:array[0..max_tzx] of word;
            value:byte;
          end;

var
 cinta_tzx:tipo_cinta_tzx;
 indice_vuelta,indice_llamadas:word;
 tzx_contador_datos,datos_totales:integer;
 tzx_ultimo_bit,tzx_contador_loop:byte;
 tzx_temp,tzx_pulsos:dword;
 tzx_estados_necesarios:longword;
 tzx_datos_p:Pbyte;

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
  for f:=0 to $ff do
    cinta_tzx.datos_tzx[num].pulsos_sym[f]:=nil;
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
main_vars.mensaje_general:='    '+leng[main_vars.idioma].mensajes[1]+': '+inttostr(datos_totales);
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
                        0:begin   {cabecera}
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
                        1:begin  {sync 1}
                                cinta_tzx.value:=cinta_tzx.value Xor 64;
                                cinta_tzx.estado_actual:=2;
                                tzx_estados_necesarios:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lsinc2;
                          end;
                        2:begin  {sync 2}
                                cinta_tzx.value:=cinta_tzx.value Xor 64;
                                cinta_tzx.estado_actual:=3;
                                if (tzx_datos_p^ and 128)<>0 then tzx_estados_necesarios:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].luno
                                        else tzx_estados_necesarios:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lcero;
                                cinta_tzx.bit_actual:=128;
                                tzx_pulsos:=2;
                                tzx_ultimo_bit:=1;
                          end;
                        3:begin  {datos}
                                cinta_tzx.value:=cinta_tzx.value Xor 64;
                                tzx_pulsos:=tzx_pulsos-1; {hago la forma de la onda)}
                                if tzx_pulsos=0 then begin
                                  if cinta_tzx.bit_actual>tzx_ultimo_bit then begin {no estoy en el ultimo bit}
                                        cinta_tzx.bit_actual:=cinta_tzx.bit_actual shr 1; {pillo el siguiente}
                                        tzx_pulsos:=2;
                                        if (tzx_datos_p^ and cinta_tzx.bit_actual)<>0 then tzx_estados_necesarios:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].luno
                                           else tzx_estados_necesarios:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lcero;
                                  end else begin {estoy en el ultimo bit}
                                      tzx_contador_datos:=tzx_contador_datos+1;
                                      datos_totales:=datos_totales+1;
                                      inc(tzx_datos_p); {incremento el byte en los datos}
                                      if tzx_contador_datos<cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lbloque then begin  {¿se ha acabado?}
                                        if tzx_contador_datos=(cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lbloque-1) then tzx_ultimo_bit:=tabla_tzx[cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lbyte] else tzx_ultimo_bit:=1;
                                        cinta_tzx.bit_actual:=128;
                                        tzx_pulsos:=2;
                                        if (tzx_datos_p^ and 128)<>0 then tzx_estados_necesarios:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].luno
                                           else tzx_estados_necesarios:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lcero;
                                      end else begin   {pasar al otro bloque}
                                        tzx_estados_necesarios:= cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lpausa*(llamadas_maquina.velocidad_cpu div 1000);
                                        cinta_tzx.en_pausa:=true;
                                      end;
                                  end;
                                end else if (tzx_datos_p^ and cinta_tzx.bit_actual)<>0 then tzx_estados_necesarios:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].luno
                                           else tzx_estados_necesarios:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lcero;
                                           {no ha completado la onda}
                          end;
                        4:cinta_tzx.en_pausa:=true;
                   end; {del estado_actual}
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
        $15:case cinta_tzx.estado_actual of  //direct recording
            0:begin
                if cinta_tzx.bit_actual>tzx_ultimo_bit then begin {no estoy en el ultimo bit}
                  tzx_estados_necesarios:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].luno;
                  cinta_tzx.bit_actual:=cinta_tzx.bit_actual shr 1; {pillo el siguiente}
                  if (tzx_datos_p^ and cinta_tzx.bit_actual)<>0 then cinta_tzx.value:=64 else cinta_tzx.value:=0;
                end else begin {estoy en el ultimo bit}
                  tzx_estados_necesarios:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].luno;
                  tzx_contador_datos:=tzx_contador_datos+1;
                  datos_totales:=datos_totales+1;
                  inc(tzx_datos_p); {incremento el byte en los datos}
                  if tzx_contador_datos<cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lbloque then begin  {¿se ha acabado?}
                    if tzx_contador_datos=(cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lbloque-1) then tzx_ultimo_bit:=tabla_tzx[cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lbyte] else tzx_ultimo_bit:=1;
                    cinta_tzx.bit_actual:=128;
                    if (tzx_datos_p^ and 128)<>0 then cinta_tzx.value:=64 else cinta_tzx.value:=0;
                  end else begin   {pasar al otro bloque}
                    tzx_estados_necesarios:= cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lpausa*(llamadas_maquina.velocidad_cpu div 1000);
                    cinta_tzx.en_pausa:=true;
                  end;
                end;
               end;
            end;
        $19:begin  {datos especiales}
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
                    datos_totales:=datos_totales+1;
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
end;  {del tipo}
end;

procedure siguiente_bloque_tzx;
var
   p:TGridRect;
   f:byte;
   cadena:string;
   ptemp:pbyte;
begin
if not(cinta_tzx.grupo) then begin
  datos_totales:=0;
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
                cinta_tzx.estado_actual:=0;
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
                tzx_estados_necesarios:= cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lpausa*(llamadas_maquina.velocidad_cpu div 1000);
                if tzx_estados_necesarios=0 then tape_window1.fStopCinta(nil);
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
        $31:begin
              cadena:='';
              ptemp:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].datos;
              for f:=0 to cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lbloque do begin
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
        f:word;
        checksum,dato:byte;
        tam_bloque:word;
        ptemp:Pbyte;
        bt:band_z80;
begin
main_screen.rapido:=true;
cinta_tzx.es_tap:=true;
ptemp:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].datos;
checksum:=ptemp^;
inc(ptemp);
if checksum=z80_val.a2 then begin
    if z80_val.de.w>cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lbloque then tam_bloque:=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lbloque else tam_bloque:=z80_val.de.w;
    for f:=0 to (tam_bloque-1) do begin
        dato:=ptemp^;
        spec_z80.putbyte(z80_val.ix.w+f,dato);
        checksum:=checksum xor dato;
        inc(ptemp);
    end;
    z80_val.f.c:=checksum=cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].checksum;
    z80_val.ix.w:=z80_val.ix.w+tam_bloque;
    z80_val.de.w:=0;
end;
datos_totales:=datos_totales+cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].lbloque;
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
  fillchar(cinta_tzx.indice_saltos,max_tzx*2,0);
  fillchar(cinta_tzx.indice_select,max_tzx*2,0);
end;
cinta_tzx.es_tap:=false;
cinta_tzx.indice_cinta:=0;
//for temp:=0 to (tape_window1.stringgrid1.RowCount-1) do tape_window1.StringGrid1.Cells[0,temp]:='';
tape_window1.stringgrid1.RowCount:=1;
sd_1:=false;
if lenslock1.Showing then lenslock1.Close;
lenslok.activo:=false;
main_vars.mensaje_general:='';
tape_window1.label2.caption:='';
end;

procedure analizar_tzx;
var
  indice:integer;
begin
indice:=0;
//comprobar LensLok
tape_window1.label2.caption:='';
sd_1:=false;
lenslok.activo:=false;
lenslok.indice:=255;
while cinta_tzx.datos_tzx[indice].tipo_bloque<>$fe do begin
  case cinta_tzx.datos_tzx[indice].crc32 of
   $92DC40D8:sd_1:=true; //Camelot Warriors con SD1
   $45169147,$ead7b3a9:begin
              lenslok.indice:=6;
              lenslok.activo:=true;
              break;  //TT RACER
             end;
   $8B28031E:begin
              lenslok.indice:=5;
              lenslok.activo:=true;
              break;  //TOMAHAWK
             end;
   $D6F54F87:begin
              lenslok.indice:=1;
              lenslok.activo:=true;
              break;    //ART STUDIO
             end;
   $FAA60847,$DC38C227:begin
              lenslok.indice:=2;  //ELITE
              lenslok.activo:=true;
              break;
             end;
   $F278B4A0,$1B81DD6D:begin
              lenslok.indice:=0;  //ACE
              lenslok.activo:=true;
              break;
             end;
  end;
indice:=indice+1;
end;
tape_window1.label2.caption:='';
if lenslok.activo then begin
  lenslock1.Show;
  tape_window1.label2.caption:='LensLok Protection Active';
end;
if sd_1 then tape_window1.label2.caption:='SD1 Protection Active';
end;

function abrir_tap(datos:pbyte;long:integer):boolean;
var
  f,temp:word;
  cadena:string;
  longitud:integer;
  tipo_bloque:byte;
  ptemp:pbyte;
begin
abrir_tap:=false;
if datos=nil then exit;
vaciar_cintas;
temp:=0;       //posicion de la cinta
longitud:=0;   //longitud que llevo
while longitud<long do begin
        getmem(cinta_tzx.datos_tzx[temp],sizeof(tipo_datos_tzx));
        zero_tape_data(temp);
        cinta_tzx.datos_tzx[temp].lbloque:=sacar_word(datos);
        inc(datos,2);inc(longitud,2);
        cinta_tzx.datos_tzx[temp].tipo_bloque:=$10;
        cinta_tzx.datos_tzx[temp].lpausa:=500;
        cinta_tzx.datos_tzx[temp].lcabecera:=2168;
        cinta_tzx.datos_tzx[temp].lsinc1:=667;
        cinta_tzx.datos_tzx[temp].lsinc2:=735;
        cinta_tzx.datos_tzx[temp].lcero:=855;
        cinta_tzx.datos_tzx[temp].luno:=1710;
        cinta_tzx.datos_tzx[temp].lbyte:=8;
        tipo_bloque:=datos^;
        if tipo_bloque=0 then cinta_tzx.datos_tzx[temp].ltono_cab:=8064 else cinta_tzx.datos_tzx[temp].ltono_cab:=3220;
        if cinta_tzx.datos_tzx[temp].lbloque>0 then getmem(cinta_tzx.datos_tzx[temp].datos,cinta_tzx.datos_tzx[temp].lbloque)
          else getmem(cinta_tzx.datos_tzx[temp].datos,1);
        copymemory(cinta_tzx.datos_tzx[temp].datos,datos,cinta_tzx.datos_tzx[temp].lbloque);
        cinta_tzx.datos_tzx[temp].crc32:=calc_crc(cinta_tzx.datos_tzx[temp].datos,cinta_tzx.datos_tzx[temp].lbloque);
        inc(datos,cinta_tzx.datos_tzx[temp].lbloque-1);inc(longitud,cinta_tzx.datos_tzx[temp].lbloque-1);
        cinta_tzx.datos_tzx[temp].checksum:=datos^;
        inc(datos);inc(longitud);
        case tipo_bloque of
                $00:begin
                        cadena:=leng[main_vars.idioma].cinta[0]+': '; //cabecera
                        ptemp:=cinta_tzx.datos_tzx[temp].datos;
                        inc(ptemp);
                        for f:=1 to 10 do begin
                          cadena:=cadena+chr(ptemp^);
                          inc(ptemp);
                        end;
                  end;
                $ff:cadena:=leng[main_vars.idioma].cinta[1]; //bytes
                else cadena:=leng[main_vars.idioma].cinta[2]; //datos
        end;
        tape_window1.stringgrid1.Cells[0,temp]:=cadena;
        tape_window1.stringgrid1.Cells[1,temp]:=inttostr(cinta_tzx.datos_tzx[temp].lbloque);
        tape_window1.stringgrid1.Cells[2,temp]:=inttohex(cinta_tzx.datos_tzx[temp].crc32,8);
        inc(temp);
        cinta_tzx.indice_saltos[temp]:=temp;
        cinta_tzx.indice_select[temp]:=temp;
        tape_window1.stringgrid1.RowCount:=tape_window1.stringgrid1.RowCount+1;
end;
tape_window1.stringgrid1.RowCount:=tape_window1.stringgrid1.RowCount-1;
getmem(cinta_tzx.datos_tzx[temp],sizeof(tipo_datos_tzx));
zero_tape_data(temp);
cinta_tzx.datos_tzx[temp].tipo_bloque:=$fe;
cinta_tzx.datos_tzx[temp].lbloque:=1;
getmem(cinta_tzx.datos_tzx[temp].datos,1);
cinta_tzx.play_tape:=false;
cinta_tzx.cargada:=true;
abrir_tap:=true;
siguiente_bloque_tzx;
analizar_tzx;
end;

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
ptemp_w2:=ptemp_w;
vaciar_cintas;
getmem(cinta_tzx.datos_tzx[0],sizeof(tipo_datos_tzx));
zero_tape_data(0);
cinta_tzx.datos_tzx[0].tipo_bloque:=$15;
cinta_tzx.datos_tzx[0].lpausa:=0;
cinta_tzx.datos_tzx[0].luno:=llamadas_maquina.velocidad_cpu div 44100;
cinta_tzx.datos_tzx[0].lbloque:=(ltemp div 8)+1;
getmem(cinta_tzx.datos_tzx[0].datos,cinta_tzx.datos_tzx[0].lbloque);
ptemp_b:=cinta_tzx.datos_tzx[0].datos;
pos:=0;
vtemp:=0;
for f:=0 to (ltemp-1) do begin
  copymemory(@temp_w,ptemp_w2,2);
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
if pos<>0 then begin
  ptemp_b^:=vtemp;
  cinta_tzx.datos_tzx[0].lbyte:=pos;
end;
freemem(ptemp_w);
tape_window1.stringgrid1.RowCount:=1;
tape_window1.stringgrid1.Cells[0,0]:='Wave File';
tape_window1.stringgrid1.Cells[1,0]:=inttostr(cinta_tzx.datos_tzx[0].lbloque);
getmem(cinta_tzx.datos_tzx[1],sizeof(tipo_datos_tzx));
zero_tape_data(1);
cinta_tzx.datos_tzx[1].tipo_bloque:=$fe;
cinta_tzx.datos_tzx[1].lbloque:=1;
getmem(cinta_tzx.datos_tzx[1].datos,1);
cinta_tzx.play_tape:=false;
cinta_tzx.cargada:=true;
siguiente_bloque_tzx;
abrir_wav:=true;
end;

function abrir_csw(data:pbyte;long:integer):boolean;
var
  temp,pos_bit:byte;
  contador,f:word;
  cadena:string;
  longitud:integer;
  sample_rate:dword;
  tipo_compresion,polaridad,version:byte;
  punt1,punt2,final_dat:pbyte;
  long_final:integer;
begin
abrir_csw:=false;
if data=nil then exit;
vaciar_cintas;
cadena:='';
longitud:=0;
pos_bit:=7;
sample_rate:=0;
for temp:=0 to 21 do begin
  cadena:=cadena+chr(data^);
  inc(data);inc(longitud);
end;
if cadena<>'Compressed Square Wave' then exit;
inc(data);inc(longitud); //Terminator
version:=data^; //Mayor version
inc(data,2);inc(longitud,2); //Minor version
case version of
  1:begin
      copymemory(@sample_rate,data,2); //Sample Rate (WORD)
      inc(data,2);
      tipo_compresion:=data^; //Compression type
      inc(data);
      polaridad:=(data^ and 1); //Polaridad
      inc(data);inc(longitud,7); //3 byes reserved
    end;
  2:begin
      copymemory(@sample_rate,data,4);  //Sample Rate (DWORD)
      inc(data,8); //Total number of pulses
      tipo_compresion:=data^; //Compression Type
      inc(data);
      polaridad:=(data^ and 1); //Polarity
      inc(data);
      temp:=data^;
      //descripcion del software que ha hecho el CSW
      inc(data,temp+17);inc(longitud,temp+27);
    end;
end;
getmem(cinta_tzx.datos_tzx[0],sizeof(tipo_datos_tzx));
zero_tape_data(0);
cinta_tzx.datos_tzx[0].tipo_bloque:=$15;
cinta_tzx.datos_tzx[0].lpausa:=0;
cinta_tzx.datos_tzx[0].luno:=llamadas_maquina.velocidad_cpu div sample_rate;
case tipo_compresion of
  $01:final_dat:=data;
  $02:begin
        final_dat:=nil;
        Decompress_zlib(pointer(data),long-longitud,pointer(final_dat),long_final);
        longitud:=0;
        long:=long_final;
        data:=final_dat;
      end;
end;
getmem(punt1,long*10);
punt2:=punt1;
temp:=0;
long_final:=0;
while longitud<long do begin
  contador:=final_dat^;
  inc(final_dat);inc(longitud);
  if contador=0 then begin
    copymemory(@contador,final_dat,4);
    inc(final_dat,4);inc(longitud,4);
  end;
  for f:=0 to (contador-1) do begin
    temp:=temp+(polaridad shl pos_bit);
    dec(pos_bit);
    if pos_bit=$FF then begin
      pos_bit:=7;
      punt2^:=temp;
      inc(punt2);
      temp:=0;
      inc(long_final);
    end;
  end;
  polaridad:=polaridad xor 1;
end;
if tipo_compresion=2 then begin
  final_dat:=data;
  freemem(final_dat);
end;
cinta_tzx.datos_tzx[0].lbyte:=(1 shl pos_bit);
cinta_tzx.datos_tzx[0].lbloque:=long_final;
getmem(cinta_tzx.datos_tzx[0].datos,cinta_tzx.datos_tzx[0].lbloque);
copymemory(cinta_tzx.datos_tzx[0].datos,punt1,cinta_tzx.datos_tzx[0].lbloque);
freemem(punt1);
tape_window1.stringgrid1.Cells[0,0]:='Compressed Square Wave v'+inttostr(tipo_compresion)+'.0';
//form1.stringgrid1.Cells[0,0]:='=>';
tape_window1.stringgrid1.RowCount:=1;
tape_window1.stringgrid1.Cells[1,0]:=inttostr(long_final);
abrir_csw:=true;
getmem(cinta_tzx.datos_tzx[1],sizeof(tipo_datos_tzx));
zero_tape_data(1);
cinta_tzx.datos_tzx[1].tipo_bloque:=$fe;
cinta_tzx.datos_tzx[1].lbloque:=1;
getmem(cinta_tzx.datos_tzx[1].datos,1);
cinta_tzx.play_tape:=false;
cinta_tzx.cargada:=true;
siguiente_bloque_tzx;
end;

function abrir_tzx(data:pbyte;long:integer):boolean;
var

  g,h,temp,contador,inicio_grupo:word;
  temp2:dword;
  long_final,punto_loop:integer;
  ptemp,puntero:pbyte;
  cadena,cadena2,nombre_grupo:string;
  f,longitud:integer;
  selector:byte;
  fin_grupo:boolean;
  t1,t3,t5:byte;
  t2,t4:word;
  tmp1,tmp2,tmp3,crc_grupo:dword;
  pulsos:array[0..$FFFF] of word;
  simbolos:array[0..$1F] of tsimbolos;
  pulsos_total,long_pausa:word;
begin
abrir_tzx:=false;
if data=nil then exit;
longitud:=0;  //longitud que llevo
cadena:='';
for temp:=0 to 6 do begin
        cadena:=cadena+chr(data^);
        inc(data);inc(longitud);
end;
inc(data,3);inc(longitud,3);
if cadena<>'ZXTape!' then exit;  //si no es una cinta TZX me salgo
vaciar_cintas;
long_final:=0; //longitud total del bloque
temp:=0;      //posicion saltos, siempre se incrementa
contador:=0;  //posicion cinta, solo se incrementa si no esta en un grupo
cinta_tzx.grupo:=false;  //indica si estoy dentro de un grupo
fin_grupo:=false; //corregir posicion cuando acaba el grupo
inicio_grupo:=0;
cinta_tzx.estados:=0;
while longitud<long do begin
        getmem(cinta_tzx.datos_tzx[temp],sizeof(tipo_datos_tzx));
        zero_tape_data(temp);
        cinta_tzx.datos_tzx[temp].lbloque:=0;
        selector:=data^;
        inc(data);inc(longitud);
        case selector of
                $10:begin  {carga normal con cabecera}
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$10;
                          cinta_tzx.datos_tzx[temp].lpausa:=sacar_word(data);
                          inc(data,2);
                          cinta_tzx.datos_tzx[temp].lbloque:=sacar_word(data);
                          inc(data,2);inc(longitud,4);
                          getmem(cinta_tzx.datos_tzx[temp].datos,cinta_tzx.datos_tzx[temp].lbloque);
                          copymemory(cinta_tzx.datos_tzx[temp].datos,data,cinta_tzx.datos_tzx[temp].lbloque);
                          inc(data,cinta_tzx.datos_tzx[temp].lbloque-1);inc(longitud,cinta_tzx.datos_tzx[temp].lbloque);
                          cinta_tzx.datos_tzx[temp].checksum:=data^;
                          inc(data);
                          cinta_tzx.datos_tzx[temp].lcabecera:=2168;
                          cinta_tzx.datos_tzx[temp].lsinc1:=667;
                          cinta_tzx.datos_tzx[temp].lsinc2:=735;
                          cinta_tzx.datos_tzx[temp].lcero:=855;
                          cinta_tzx.datos_tzx[temp].luno:=1710;
                          cinta_tzx.datos_tzx[temp].lbyte:=8;
                          cadena:='Datos';
                          cinta_tzx.datos_tzx[temp].ltono_cab:=3220;
                          inc(long_final,cinta_tzx.datos_tzx[temp].lbloque);
                          if ((main_vars.tipo_maquina=0) or (main_vars.tipo_maquina=1) or (main_vars.tipo_maquina=2) or (main_vars.tipo_maquina=3) or (main_vars.tipo_maquina=4) or (main_vars.tipo_maquina=5)) then begin
                           puntero:=cinta_tzx.datos_tzx[temp].datos;
                           if cinta_tzx.datos_tzx[temp].datos<>nil then
                           case puntero^ of
                              $00:begin
                                    cinta_tzx.datos_tzx[temp].ltono_cab:=8064;
                                    cadena:=leng[main_vars.idioma].cinta[0]+': '; //cabecera
                                    inc(puntero,2);
                                    for f:=0 to 9 do begin
                                      cadena:=cadena+chr(puntero^);
                                      inc(puntero);
                                    end;
                                  end;
                              $ff:cadena:=leng[main_vars.idioma].cinta[1]; //bytes
                           end;
                          end;
                       end;
                    $11:begin {carga turbo con cabecera}
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$11;
                          cinta_tzx.datos_tzx[temp].lcabecera:=sacar_word(data);
                          inc(data,2);
                          cinta_tzx.datos_tzx[temp].lsinc1:=sacar_word(data);
                          inc(data,2);
                          cinta_tzx.datos_tzx[temp].lsinc2:=sacar_word(data);
                          inc(data,2);
                          cinta_tzx.datos_tzx[temp].lcero:=sacar_word(data);
                          inc(data,2);
                          cinta_tzx.datos_tzx[temp].luno:=sacar_word(data);
                          inc(data,2);
                          cinta_tzx.datos_tzx[temp].ltono_cab:=sacar_word(data);
                          inc(data,2);
                          cinta_tzx.datos_tzx[temp].lbyte:=data^;
                          inc(data);
                          cinta_tzx.datos_tzx[temp].lpausa:=sacar_word(data);
                          inc(data,2);
                          cinta_tzx.datos_tzx[temp].lbloque:=sacar_word(data);
                          inc(data,2);
                          inc(cinta_tzx.datos_tzx[temp].lbloque,data^*65536);
                          inc(data);inc(longitud,18);
                          getmem(cinta_tzx.datos_tzx[temp].datos,cinta_tzx.datos_tzx[temp].lbloque);
                          copymemory(cinta_tzx.datos_tzx[temp].datos,data,cinta_tzx.datos_tzx[temp].lbloque);
                          inc(data,cinta_tzx.datos_tzx[temp].lbloque);inc(longitud,cinta_tzx.datos_tzx[temp].lbloque);
                          cadena:=leng[main_vars.idioma].cinta[3]; //bytes turbo
                          inc(long_final,cinta_tzx.datos_tzx[temp].lbloque);
                          if ((main_vars.tipo_maquina=7) or (main_vars.tipo_maquina=8) or (main_vars.tipo_maquina=9)) then begin
                           puntero:=cinta_tzx.datos_tzx[temp].datos;
                           if cinta_tzx.datos_tzx[temp].datos<>nil then
                           if puntero^=$2c then begin //sync byte
                            cadena:=leng[main_vars.idioma].cinta[0]+': ';
                            inc(puntero);
                            for f:=0 to 15 do begin
                              if puntero^=0 then cadena:=cadena+' '
                                else cadena:=cadena+chr(puntero^);
                              inc(puntero);
                            end;
                            cadena:=cadena+'('+chr(48+(puntero^ div 10))+chr(48+(puntero^ mod 10))+')';
                           end;
                          end;
                       end;
                    $12:begin  {tono puro}
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$12;
                          cinta_tzx.datos_tzx[temp].lcabecera:=sacar_word(data);
                          inc(data,2);
                          cinta_tzx.datos_tzx[temp].ltono_cab:=sacar_word(data);
                          inc(data,2);inc(longitud,4);
                          getmem(cinta_tzx.datos_tzx[temp].datos,1);
                          cadena:=leng[main_vars.idioma].cinta[4]; //Tono Puro
                          cadena2:=' ';
                        end;
                    $13:begin {secuencia de pulsos}
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$13;
                          cinta_tzx.datos_tzx[temp].lbloque:=data^;
                          inc(data);inc(longitud);
                          getmem(cinta_tzx.datos_tzx[temp].datos,(cinta_tzx.datos_tzx[temp].lbloque*2));
                          copymemory(cinta_tzx.datos_tzx[temp].datos,data,(cinta_tzx.datos_tzx[temp].lbloque*2));
                          inc(data,(cinta_tzx.datos_tzx[temp].lbloque*2));inc(longitud,(cinta_tzx.datos_tzx[temp].lbloque*2));
                          cadena:=leng[main_vars.idioma].cinta[5]; //Secuencia Pulsos
                          cadena2:=' ';
                        end;
                    $14:begin  {datos puros}
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$14;
                          cinta_tzx.datos_tzx[temp].lcero:=sacar_word(data);
                          inc(data,2);
                          cinta_tzx.datos_tzx[temp].luno:=sacar_word(data);
                          inc(data,2);
                          cinta_tzx.datos_tzx[temp].lbyte:=data^;
                          inc(data);
                          cinta_tzx.datos_tzx[temp].lpausa:=sacar_word(data);
                          inc(data,2);
                          cinta_tzx.datos_tzx[temp].lbloque:=sacar_word(data);
                          inc(data,2);
                          inc(cinta_tzx.datos_tzx[temp].lbloque,data^*65536);
                          inc(data);inc(longitud,10);
                          getmem(cinta_tzx.datos_tzx[temp].datos,cinta_tzx.datos_tzx[temp].lbloque);
                          copymemory(cinta_tzx.datos_tzx[temp].datos,data,cinta_tzx.datos_tzx[temp].lbloque);
                          inc(data,cinta_tzx.datos_tzx[temp].lbloque);inc(longitud,cinta_tzx.datos_tzx[temp].lbloque);
                          cadena:=leng[main_vars.idioma].cinta[6]; //Datos Puros
                          inc(long_final,cinta_tzx.datos_tzx[temp].lbloque);
                        end;
                    $15:begin  //direct recording
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$15;
                          cinta_tzx.datos_tzx[temp].luno:=sacar_word(data);
                          inc(data,2);
                          cinta_tzx.datos_tzx[temp].lpausa:=sacar_word(data);
                          inc(data,2);
                          cinta_tzx.datos_tzx[temp].lbyte:=data^;
                          inc(data);
                          cinta_tzx.datos_tzx[temp].lbloque:=sacar_word(data);
                          inc(data,2);
                          inc(cinta_tzx.datos_tzx[temp].lbloque,data^*65536);
                          inc(data);inc(longitud,8);
                          getmem(cinta_tzx.datos_tzx[temp].datos,cinta_tzx.datos_tzx[temp].lbloque);
                          copymemory(cinta_tzx.datos_tzx[temp].datos,data,cinta_tzx.datos_tzx[temp].lbloque);
                          inc(data,cinta_tzx.datos_tzx[temp].lbloque);inc(longitud,cinta_tzx.datos_tzx[temp].lbloque);
                          cadena:=leng[main_vars.idioma].cinta[7]; //Grabacion Directa
                          inc(long_final,cinta_tzx.datos_tzx[temp].lbloque);
                        end;
                    $19:begin
                          tmp3:=sacar_word(data);
                          inc(data,2);inc(longitud,2);
                          tmp3:=tmp3+(sacar_word(data)*65536);
                          inc(data,2);inc(longitud,2);
                          //La pausa es del último bloque!!!!
                          long_pausa:=sacar_word(data);
                          inc(data,2);inc(longitud,2);
                          //PILOT
                          //totp
                          tmp1:=sacar_word(data);
                          inc(data,2);inc(longitud,2);
                          tmp1:=tmp1+(sacar_word(data)*65536);
                          inc(data,2);inc(longitud,2);
                          //npp
                          t1:=data^;
                          inc(data);inc(longitud);
                          //asp
                          t2:=data^;
                          inc(data);inc(longitud);
                          if t2=0 then t2:=256;
                          //DATA
                          //totd
                          tmp2:=sacar_word(data);
                          inc(data,2);inc(longitud,2);
                          tmp2:=tmp2+(sacar_word(data)*65536);
                          inc(data,2);inc(longitud,2);
                          //npd
                          t3:=data^;
                          inc(data);inc(longitud);
                          //asd
                          t4:=data^;
                          inc(data);inc(longitud);
                          if t4=0 then t4:=256;
                          //Creo grupo
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$21;
                          getmem(cinta_tzx.datos_tzx[temp].datos,1);
                          nombre_grupo:=leng[main_vars.idioma].cinta[10]+': Generalized Data';
                          inicio_grupo:=temp;
                          cinta_tzx.indice_saltos[temp]:=contador;
                          inc(temp);
                          //PILOT
                          //Si no hay simbolos no cojo nada
                          if tmp1<>0 then begin
                          //cojo los simbolos del alfabeto
                            for f:=1 to t2 do begin
                                simbolos[f-1].flag:=data^;
                                inc(data);inc(longitud);
                                for g:=t1 downto 1 do begin
                                  simbolos[f-1].valor[g-1]:=sacar_word(data);
                                  inc(data,2);inc(longitud,2);
                                end;
                            end;
                            //Y ahora relaciono repeticiones con simbolos
                            pulsos_total:=0;
                            for f:=1 to tmp1 do begin
                              //¿que simbolo es?
                              t5:=data^;
                              inc(data);inc(longitud);
                              //ver si el simbolo tiene flag
                              case simbolos[t5].flag of
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
                              temp2:=sacar_word(data);
                              inc(data,2);inc(longitud,2);
                              for g:=1 to temp2 do begin
                                for h:=0 to (t1-1) do begin
                                  pulsos[pulsos_total]:=simbolos[t5].valor[h];
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
                          if tmp2<>0 then begin
                            getmem(cinta_tzx.datos_tzx[temp],sizeof(tipo_datos_tzx));
                            zero_tape_data(temp);
                            //Simbolos de los datos
                            for f:=1 to t4 do begin
                              getmem(cinta_tzx.datos_tzx[temp].pulsos_sym[f-1],sizeof(tsimbolos));
                              fillchar(cinta_tzx.datos_tzx[temp].pulsos_sym[f-1]^,sizeof(tsimbolos),0);
                              cinta_tzx.datos_tzx[temp].pulsos_sym[f-1].flag:=data^;
                              cinta_tzx.datos_tzx[temp].pulsos_sym[f-1].total_sym:=t3;
                              inc(data);inc(longitud);
                              for g:=t3 downto 1 do begin
                                cinta_tzx.datos_tzx[temp].pulsos_sym[f-1].valor[g]:=sacar_word(data);
                                inc(data,2);inc(longitud,2);
                              end;
                            end;
                            cinta_tzx.datos_tzx[temp].num_pulsos:=t4;
                            case t4 of
                              2:cinta_tzx.datos_tzx[temp].lbloque:=tmp2 div 8;
                              256:cinta_tzx.datos_tzx[temp].lbloque:=tmp2;
                                else MessageDlg('Simbolos div extraño!! '+inttostr(t4), mtInformation,[mbOk], 0);
                            end;
                            cinta_tzx.datos_tzx[temp].tipo_bloque:=$19;
                            getmem(cinta_tzx.datos_tzx[temp].datos,cinta_tzx.datos_tzx[temp].lbloque);
                            copymemory(cinta_tzx.datos_tzx[temp].datos,data,cinta_tzx.datos_tzx[temp].lbloque);
                            inc(data,cinta_tzx.datos_tzx[temp].lbloque);
                            inc(longitud,cinta_tzx.datos_tzx[temp].lbloque);
                            long_final:=long_final+cinta_tzx.datos_tzx[temp].lbloque;
                            cinta_tzx.indice_saltos[temp]:=contador;
                            cinta_tzx.datos_tzx[temp].lpausa:=long_pausa;
                            inc(temp);
                          end;
                          getmem(cinta_tzx.datos_tzx[temp],sizeof(tipo_datos_tzx));
                          zero_tape_data(temp);
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$22;
                          getmem(cinta_tzx.datos_tzx[temp].datos,1);
                          fin_grupo:=true;
                    end;
                    $20:begin {pausa}
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$20;
                          cinta_tzx.datos_tzx[temp].lcabecera:=0;
                          cinta_tzx.datos_tzx[temp].lpausa:=sacar_word(data);
                          inc(data,2);inc(longitud,2);
                          getmem(cinta_tzx.datos_tzx[temp].datos,1);
                          if not(cinta_tzx.grupo) then begin
                            if cinta_tzx.datos_tzx[temp].lpausa=0 then begin
                                cadena:=leng[main_vars.idioma].cinta[8]; //STOP the tape
                                cadena2:=' ';
                            end else begin
                                cadena:=leng[main_vars.idioma].cinta[9]; //Pausa
                                cadena2:=inttostr(cinta_tzx.datos_tzx[temp].lpausa)+'ms.';
                            end;
                          end;
                          end;
                    $21:begin   {inicio del grupo}
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$21;
                          cinta_tzx.datos_tzx[temp].lcabecera:=0;
                          cinta_tzx.datos_tzx[temp].lbloque:=data^;
                          inc(data);inc(longitud);
                          getmem(cinta_tzx.datos_tzx[temp].datos,cinta_tzx.datos_tzx[temp].lbloque);
                          copymemory(cinta_tzx.datos_tzx[temp].datos,data,cinta_tzx.datos_tzx[temp].lbloque);
                          inc(data,cinta_tzx.datos_tzx[temp].lbloque);inc(longitud,cinta_tzx.datos_tzx[temp].lbloque);
                          nombre_grupo:=leng[main_vars.idioma].cinta[10]+': '; //grupo
                          ptemp:=cinta_tzx.datos_tzx[temp].datos;
                          for f:=0 to (cinta_tzx.datos_tzx[temp].lbloque-1) do begin
                            nombre_grupo:=nombre_grupo+chr(ptemp^);
                            inc(ptemp);
                          end;
                          inicio_grupo:=temp;
                          cinta_tzx.grupo:=true;
                        end;
                    $22:begin {fin grupo}
                          cadena:=nombre_grupo;
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$22;
                          getmem(cinta_tzx.datos_tzx[temp].datos,1);
                          cinta_tzx.grupo:=false;
                          fin_grupo:=true;
                        end;
                    $23:begin //saltar a posicion
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$23;
                          getmem(cinta_tzx.datos_tzx[temp].datos,1);
                          cinta_tzx.datos_tzx[temp].salta_bloque:=smallint(sacar_word(data));
                          inc(data,2);inc(longitud,2);
                          cadena:=leng[main_vars.idioma].cinta[11]+' '+inttostr(cinta_tzx.datos_tzx[temp].salta_bloque);
                          cadena2:=' ';
                        end;
                    $24:begin  {loop}
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$24;
                          cinta_tzx.datos_tzx[temp].lbloque:=sacar_word(data);
                          inc(data,2);inc(longitud,2);
                          getmem(cinta_tzx.datos_tzx[temp].datos,1);
                          punto_loop:=temp+1;
                          cadena:=leng[main_vars.idioma].cinta[12]; //Loop
                          cadena2:=' ';
                         end;
                    $25:begin {loop next}
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$25;
                          getmem(cinta_tzx.datos_tzx[temp].datos,1);
                          cinta_tzx.datos_tzx[temp].lbloque:=punto_loop;
                          cadena:=leng[main_vars.idioma].cinta[13];  //fin del loop
                          cadena2:=' ';
                        end;
                    $26:begin //Call sequence
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$26;
                          cinta_tzx.datos_tzx[temp].lbloque:=sacar_word(data);
                          inc(data,2);inc(longitud,2);
                          getmem(cinta_tzx.datos_tzx[temp].datos,cinta_tzx.datos_tzx[temp].lbloque);
                          copymemory(cinta_tzx.datos_tzx[temp].datos,data,cinta_tzx.datos_tzx[temp].lbloque*2);
                          inc(data,cinta_tzx.datos_tzx[temp].lbloque*2);inc(longitud,cinta_tzx.datos_tzx[temp].lbloque*2);
                          cadena:='Call Sequence';
                          cadena2:=' ';
                        end;
                    $27:begin //Return Call sequence
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$27;
                          getmem(cinta_tzx.datos_tzx[temp].datos,1);
                          cadena:='Return';
                          cadena2:=' ';
                        end;
                    $28:begin //select block
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$28;
                          cinta_tzx.datos_tzx[temp].lbloque:=sacar_word(data);
                          inc(data,2);inc(longitud,2);
                          getmem(cinta_tzx.datos_tzx[temp].datos,cinta_tzx.datos_tzx[temp].lbloque);
                          inc(data,cinta_tzx.datos_tzx[temp].lbloque);inc(longitud,cinta_tzx.datos_tzx[temp].lbloque);
                          cadena:='Select Block';
                          cadena2:=' ';
                        end;
                    $2a:begin  //stop the tape if 48k
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$2a;
                          getmem(cinta_tzx.datos_tzx[temp].datos,1);
                          inc(data,4);inc(longitud,4);
                          cadena:=leng[main_vars.idioma].cinta[14];
                          cadena2:=' ';
                        end;
                    $30:begin
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$30;
                          cinta_tzx.datos_tzx[temp].lcabecera:=0;
                          cinta_tzx.datos_tzx[temp].lbloque:=data^;
                          inc(data);inc(longitud);
                          getmem(cinta_tzx.datos_tzx[temp].datos,cinta_tzx.datos_tzx[temp].lbloque);
                          copymemory(cinta_tzx.datos_tzx[temp].datos,data,cinta_tzx.datos_tzx[temp].lbloque);
                          inc(data,cinta_tzx.datos_tzx[temp].lbloque);inc(longitud,cinta_tzx.datos_tzx[temp].lbloque);
                          //tape_window1.StringGrid1.cells[0,contador]:='';
                          puntero:=cinta_tzx.datos_tzx[temp].datos;
                          cadena:=leng[main_vars.idioma].cinta[15]+': ';
                          cadena2:=' ';
                          for f:=1 to cinta_tzx.datos_tzx[temp].lbloque do begin
                                cadena:=cadena+chr(puntero^);
                                inc(puntero);
                          end;
                        end;
                    $31:begin  //mensaje
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$31;
                          cinta_tzx.datos_tzx[temp].lpausa:=data^*1000;
                          inc(data);
                          cinta_tzx.datos_tzx[temp].lcabecera:=0;
                          cinta_tzx.datos_tzx[temp].lbloque:=data^;
                          inc(data);inc(longitud,2);
                          getmem(cinta_tzx.datos_tzx[temp].datos,cinta_tzx.datos_tzx[temp].lbloque);
                          copymemory(cinta_tzx.datos_tzx[temp].datos,data,cinta_tzx.datos_tzx[temp].lbloque);
                          inc(data,cinta_tzx.datos_tzx[temp].lbloque);inc(longitud,cinta_tzx.datos_tzx[temp].lbloque);
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
                          cinta_tzx.datos_tzx[temp].tipo_bloque:=$35;
                          puntero:=data;
                          inc(data,$10);inc(longitud,$10);
                          tmp3:=sacar_word(data);
                          inc(data,2);inc(longitud,2);
                          tmp3:=tmp3+(sacar_word(data)*65536);
                          inc(data,2);inc(longitud,2);
                          cinta_tzx.datos_tzx[temp].lbloque:=tmp3;
                          cinta_tzx.datos_tzx[temp].lcabecera:=0;
                          getmem(cinta_tzx.datos_tzx[temp].datos,cinta_tzx.datos_tzx[temp].lbloque);
                          copymemory(cinta_tzx.datos_tzx[temp].datos,data,cinta_tzx.datos_tzx[temp].lbloque);
                          inc(data,cinta_tzx.datos_tzx[temp].lbloque);inc(longitud,cinta_tzx.datos_tzx[temp].lbloque);
                          cadena:='Custom Block: ''';
                          for tmp3:=0 to $f do begin
                            cadena:=cadena+char(puntero^);
                            inc(puntero);
                          end;
                          cadena:=cadena+'''';
                          cadena2:=' ';
                        end;
                    $5A:begin
                          getmem(cinta_tzx.datos_tzx[temp].datos,1);
                          inc(data,9);inc(longitud,9);
                          cadena:='Glue!';
                          cadena2:=' ';
                    end;
                    else begin
                            MessageDlg('Bloque TZX desconocido: '+inttohex(selector,2), mtInformation,[mbOk], 0);
                            exit;
                    end;
                end; {del case}
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
          tape_window1.stringgrid1.Cells[2,contador]:=inttohex(cinta_tzx.datos_tzx[temp].crc32,8);
          inc(contador);
          long_final:=0;
        end;
        if fin_grupo then begin
          tape_window1.stringgrid1.RowCount:=tape_window1.stringgrid1.RowCount+1;
          fin_grupo:=false;
          tape_window1.stringgrid1.Cells[0,contador]:=nombre_grupo;
          tape_window1.stringgrid1.Cells[2,contador]:=inttohex(crc_grupo,8);
          cinta_tzx.indice_select[contador]:=inicio_grupo;
          cinta_tzx.datos_tzx[temp].crc32:=crc_grupo;
          inc(contador);
          long_final:=0;
        end;
        inc(temp);
end; {del while not}
tape_window1.stringgrid1.RowCount:=tape_window1.stringgrid1.RowCount-1;
getmem(cinta_tzx.datos_tzx[temp],sizeof(tipo_datos_tzx));
zero_tape_data(temp);
cinta_tzx.datos_tzx[temp].tipo_bloque:=$fe;
cinta_tzx.datos_tzx[temp].lbloque:=1;
getmem(cinta_tzx.datos_tzx[temp].datos,1);
cinta_tzx.play_tape:=false;
cinta_tzx.cargada:=true;
cinta_tzx.play_once:=false;
siguiente_bloque_tzx;
abrir_tzx:=true;
analizar_tzx;
end;

function abrir_pzx(data:pbyte;long:integer):boolean;
var
  f,temp,temp2,contador,contador2,puls_total_long:integer;
  cadena,cadena2,cadena3:string;
  longitud:integer;
  lbloque,temp3:dword;
  ptemp:pbyte;
  pulsos_long:array[0..$10000] of dword;
  datos_ok:boolean;
begin
//inicio
abrir_pzx:=false;
if data=nil then exit;
longitud:=0;  //longitud que llevo
cadena:='';
cinta_tzx.grupo:=false;
for temp:=0 to 3 do begin
        cadena:=cadena+chr(data^);
        inc(data);inc(longitud);
end;
if cadena<>'PZXT' then exit;  //si no es una cinta PZX me salgo
lbloque:=sacar_word(data);
inc(data,2);inc(longitud,2);
lbloque:=lbloque+(sacar_word(data)*65536);
inc(data,2);inc(longitud,2);
inc(data,lbloque);inc(longitud,lbloque);
vaciar_cintas;
contador:=0; //posicion en la cinta
cinta_tzx.estados:=0;
//bucle
while longitud<long do begin
  cadena3:='';
  if contador>$ff0 then begin
    MessageDlg('Cinta PZX demasiado grande.', mtInformation,[mbOk], 0);
    vaciar_cintas;
    exit;
  end;
  getmem(cinta_tzx.datos_tzx[contador],sizeof(tipo_datos_tzx));
  zero_tape_data(contador);
  cadena:='';
  for temp:=0 to 3 do begin
        cadena:=cadena+chr(data^);
        inc(data);inc(longitud);
  end;
  lbloque:=sacar_word(data);
  inc(data,2);inc(longitud,2);
  lbloque:=lbloque+(sacar_word(data) shl 16);
  inc(data,2);inc(longitud,2);  //saco la longitud
  ptemp:=data;  //puntero a los datos del bloque
  inc(data,lbloque);inc(longitud,lbloque);  //La incremento
  datos_ok:=false;
  if cadena='PULS' then begin
    temp2:=0;
    puls_total_long:=0;
    while temp2<lbloque do begin
      temp3:=sacar_word(ptemp);
      inc(ptemp,2);inc(temp2,2);
      contador2:=1;
      if (temp3 and $8000)<>0 then begin
        contador2:=(temp3 and $7FFF);
        if contador2=0 then begin
          contador2:=1;
          temp3:=sacar_word(ptemp);
          inc(ptemp,2);inc(temp2,2);
        end else begin
          temp3:=sacar_word(ptemp);
          inc(ptemp,2);inc(temp2,2);
          if (temp3 and $8000)<>0 then begin
            temp3:=((temp3 and $7FFF) shl 16)+sacar_word(ptemp);
            inc(ptemp,2);inc(temp2,2);
          end;
        end;
      end;
      //Hay demasiados pulsos??
      if (puls_total_long+contador2)>$ffff then begin
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
        inc(contador);
        getmem(cinta_tzx.datos_tzx[contador],sizeof(tipo_datos_tzx));
        zero_tape_data(contador);
        puls_total_long:=0;
      end;
      for f:=1 to contador2 do begin
          pulsos_long[puls_total_long]:=temp3;
          inc(puls_total_long);
      end;
    end;
    getmem(cinta_tzx.datos_tzx[contador].datos,puls_total_long*4);
    copymemory(cinta_tzx.datos_tzx[contador].datos,@pulsos_long[0],puls_total_long*4);
    cinta_tzx.datos_tzx[contador].lbloque:=puls_total_long;
    cinta_tzx.datos_tzx[contador].tipo_bloque:=$F3;
    cadena3:=leng[main_vars.idioma].cinta[5]; //Secuencia Pulsos
    cadena2:=' ';
    cinta_tzx.datos_tzx[contador].inicial:=0;
    datos_ok:=true;
  end;
  if cadena='PAUS' then begin
    cinta_tzx.datos_tzx[contador].tipo_bloque:=$20;
    temp3:=sacar_word(ptemp);
    inc(ptemp,2);
    temp3:=((temp3+(sacar_word(ptemp)*65536)) and $7FFFFFFF) div (llamadas_maquina.velocidad_cpu div 1000);
    cinta_tzx.datos_tzx[contador].lpausa:=temp3;
    getmem(cinta_tzx.datos_tzx[contador].datos,1);
    cadena3:=leng[main_vars.idioma].cinta[9]; //Pausa
    cadena2:=inttostr(temp3)+'ms.';
    datos_ok:=true;
  end;
  if cadena='DATA' then begin
    //Solo hay dos simbolos
    getmem(cinta_tzx.datos_tzx[contador].pulsos_sym[0],sizeof(tsimbolos));
    fillchar(cinta_tzx.datos_tzx[contador].pulsos_sym[0]^,sizeof(tsimbolos),0);
    getmem(cinta_tzx.datos_tzx[contador].pulsos_sym[1],sizeof(tsimbolos));
    fillchar(cinta_tzx.datos_tzx[contador].pulsos_sym[1]^,sizeof(tsimbolos),0);
    cinta_tzx.datos_tzx[contador].num_pulsos:=2;
    //Longitud bits 0--30
    temp3:=sacar_word(ptemp);
    inc(ptemp,2);
    temp3:=temp3+(sacar_word(ptemp)*65536);
    inc(ptemp,2);
    //Bit 31 valor inicial del ear...
    if (temp3 and $80000000)<>0 then cinta_tzx.datos_tzx[contador].inicial:=2
      else cinta_tzx.datos_tzx[contador].inicial:=1;
    temp3:=temp3 and $7FFFFFFF;
    inc(ptemp,2); //tail
    //pulsos para formar la longitud del 0
    temp:=ptemp^;
    inc(ptemp);
    //pulsos para formar la longitud del 1
    temp2:=ptemp^;
    inc(ptemp);
    cinta_tzx.datos_tzx[contador].pulsos_sym[0].total_sym:=temp;
    for f:=1 to temp do begin
      cinta_tzx.datos_tzx[contador].pulsos_sym[0].valor[f]:=sacar_word(ptemp);
      cinta_tzx.datos_tzx[contador].pulsos_sym[0].flag:=0;
      inc(ptemp,2);
    end;
    cinta_tzx.datos_tzx[contador].pulsos_sym[1].total_sym:=temp2;
    for f:=1 to temp do begin
      cinta_tzx.datos_tzx[contador].pulsos_sym[1].valor[f]:=sacar_word(ptemp);
      cinta_tzx.datos_tzx[contador].pulsos_sym[1].flag:=0;
      inc(ptemp,2);
    end;
    cinta_tzx.datos_tzx[contador].lbloque:=temp3 div 8;
    temp:=temp3 mod 8;
    if temp=0 then cinta_tzx.datos_tzx[contador].lbyte:=8
      else begin
        inc(cinta_tzx.datos_tzx[contador].lbloque);
        cinta_tzx.datos_tzx[contador].lbyte:=temp;
      end;
    cinta_tzx.datos_tzx[contador].tipo_bloque:=$19;
    getmem(cinta_tzx.datos_tzx[contador].datos,cinta_tzx.datos_tzx[contador].lbloque);
    copymemory(cinta_tzx.datos_tzx[contador].datos,ptemp,cinta_tzx.datos_tzx[contador].lbloque);
    cadena3:='Generalized Data';
    datos_ok:=true;
  end;
  if cadena='BRWS' then begin
    cinta_tzx.datos_tzx[contador].tipo_bloque:=$30;
    cinta_tzx.datos_tzx[contador].lbloque:=lbloque;
    getmem(cinta_tzx.datos_tzx[contador].datos,lbloque);
    copymemory(cinta_tzx.datos_tzx[contador].datos,ptemp,lbloque);
    //tape_window1.StringGrid1.cells[0,contador]:='';
    ptemp:=cinta_tzx.datos_tzx[contador].datos;
    cadena3:=leng[main_vars.idioma].cinta[15]+': ';
    cadena2:=' ';
    for f:=1 to cinta_tzx.datos_tzx[contador].lbloque do begin
      cadena3:=cadena3+chr(ptemp^);
      inc(ptemp);
    end;
    datos_ok:=true;
  end;
  if cadena='STOP' then begin
    temp2:=sacar_word(ptemp);
    if temp2=1 then begin //Stop if 48K
      cinta_tzx.datos_tzx[contador].tipo_bloque:=$2a;
      cadena3:=leng[main_vars.idioma].cinta[14];
    end else begin //Stop the tape
      cinta_tzx.datos_tzx[contador].tipo_bloque:=$20;
      cadena3:=leng[main_vars.idioma].cinta[8];
    end;
    getmem(cinta_tzx.datos_tzx[contador].datos,1);
    cadena2:=' ';
    datos_ok:=true;
  end;
  if cadena='PZXT' then begin
    cinta_tzx.datos_tzx[contador].tipo_bloque:=$5a;
    getmem(cinta_tzx.datos_tzx[contador].datos,1);
    cadena3:='Glue!';
    cadena2:=' ';
    datos_ok:=true;
  end;
  if not(datos_ok) then begin
     MessageDlg('Bloque desconocido '+cadena, mtInformation,[mbOk], 0);
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

