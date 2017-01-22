unit spectrum_3;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     main_engine,ay_8910,z80_sp,upd765,controls_engine,spectrum_128k,cargar_dsk,
     forms,rom_engine,pal_engine,sound_engine,z80pio,disk_file_format,
     misc_functions;

const
  plus3_rom:array[0..4] of tipo_roms=(
        (n:'plus3-0.rom';l:$4000;p:0;crc:$30c9f490),(n:'plus3-1.rom';l:$4000;p:$4000;crc:$a7916b3f),
        (n:'plus3-2.rom';l:$4000;p:$8000;crc:$c9a0b748),(n:'plus3-3.rom';l:$4000;p:$c000;crc:$b88fd6e3),());
  ram_bank:array[0..3,0..3] of byte=((0,1,2,3),(4,5,6,7),(4,5,6,3),(4,7,6,3));

var
   old_1ffd:byte;
   memoria_3:array[0..11,0..$3fff] of byte;
   paginacion_especial,disk_present:boolean;
   linea:word;

procedure Cargar_Spectrum3;
function iniciar_3:boolean;
procedure spec3_reset;
function spectrum3_loaddisk:boolean;
//CPU
procedure spectrum3_main;
function spec3_getbyte(direccion:word):byte;
procedure spec3_putbyte(direccion:word;valor:byte);
function spec3_inbyte(puerto:word):byte;
procedure spec3_outbyte(puerto:word;valor:byte);
procedure spec3_retraso_memoria(direccion:word);
procedure spec3_retraso_puerto(puerto:word);

implementation
uses tap_tzx,spectrum_misc;

procedure Cargar_Spectrum3;
begin
case main_vars.tipo_maquina of
  2:begin
      llamadas_maquina.cartuchos:=spectrum3_loaddisk;
      disk_present:=true;
  end;
  3:begin
      llamadas_maquina.cartuchos:=nil;
      disk_present:=false;
  end;
end;
llamadas_maquina.iniciar:=iniciar_3;
llamadas_maquina.bucle_general:=spectrum3_main;
llamadas_maquina.close:=spec_cerrar_comun;
llamadas_maquina.cintas:=spectrum_tapes;
llamadas_maquina.reset:=spec3_reset;
llamadas_maquina.grabar_snapshot:=grabar_spec;
llamadas_maquina.fps_max:=50;
llamadas_maquina.velocidad_cpu:=3546900;
var_spectrum.samples_audio:=llamadas_maquina.velocidad_cpu/freq_base_audio;
var_spectrum.samples_beeper:=llamadas_maquina.velocidad_cpu/(freq_base_audio*var_spectrum.beeper_oversample);
llamadas_maquina.configurar:=spectrum_config;
end;

function spectrum3_loaddisk:boolean;
begin
load_dsk.show;
while load_dsk.Showing do application.ProcessMessages;
spectrum3_loaddisk:=true;
end;

function iniciar_3:boolean;
const
  cmem3:array[0..127] of byte=(
   1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,
   1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,
   1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,
   1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2,1,0,7,6,5,4,3,2);
var
  f:integer;
  h:byte;
  mem_temp:array[0..$ffff] of byte;
begin
iniciar_3:=false;
//Iniciar el Z80 y pantalla
if not(spec_comun) then exit;
spec_z80.change_ram_calls(spec3_getbyte,spec3_putbyte);
spec_z80.change_io_calls(spec3_inbyte,spec3_outbyte);
spec_z80.change_retraso_call(spec3_retraso_memoria,spec3_retraso_puerto);
ay8910_0:=ay8910_chip.create(1773400,AY8912,1);
ay8910_0.change_io_calls(spec128_lg,nil,nil,nil);
if not(cargar_roms(@mem_temp[0],@plus3_rom[0],'plus3.zip',0)) then exit;
copymemory(@memoria_3[8,0],@mem_temp[0],$4000);
copymemory(@memoria_3[9,0],@mem_temp[$4000],$4000);
copymemory(@memoria_3[10,0],@mem_temp[$8000],$4000);
copymemory(@memoria_3[11,0],@mem_temp[$c000],$4000);
fillchar(var_spectrum.retraso[0],71000,0);
f:=14364;
for h:=0 to 191 do begin
  copymemory(@var_spectrum.retraso[f],@cmem3[0],128);
  inc(f,228);
  end;
case var_spectrum.audio_128k of
  0:iniciar_audio(false);
  1,2:iniciar_audio(true);
end;
spec3_reset;
iniciar_3:=true;
end;

procedure spec3_reset;
var
  f:byte;
begin
reset_misc;
for f:=0 to 7 do fillchar(memoria_3[f],16384,0);
ay8910_0.reset;
var_spectrum.marco[0]:=8;
var_spectrum.marco[1]:=5;
var_spectrum.marco[2]:=2;
var_spectrum.marco[3]:=0;
paginacion_activa:=true;
paginacion_especial:=false;
var_spectrum.pantalla_128k:=5;
old_1ffd:=0;
var_spectrum.old_7ffd:=7;
ResetFDC;
end;

procedure spec3_retraso_memoria(direccion:word);
var
  estados:byte;
  posicion:dword;
begin
estados:=0;
posicion:=linea*228+spec_z80.contador;
case (direccion and $c000) of
  $4000:estados:=var_spectrum.retraso[posicion];
  $c000:if (var_spectrum.marco[3]>3) then estados:=var_spectrum.retraso[posicion];
end;
spec_z80.contador:=spec_z80.contador+estados;
end;

procedure spec3_retraso_puerto(puerto:word);
var
  estados:byte;
  posicion:dword;
begin
posicion:=linea*228+spec_z80.contador;
if (puerto and $c000)=$4000 then begin //Contenida
    if (puerto and 1)<>0 then begin //ultimo bit 1
       estados:=var_spectrum.retraso[posicion]+1;
       estados:=estados+var_spectrum.retraso[posicion+estados]+1;
       estados:=estados+var_spectrum.retraso[posicion+estados]+1;
       estados:=estados+var_spectrum.retraso[posicion+estados]+1;
    end else begin //ultimo bit 0
      estados:=var_spectrum.retraso[posicion]+1;
      estados:=estados+var_spectrum.retraso[posicion+estados]+3;
    end;
end else begin
    if (puerto and 1)<>0 then estados:=4 //ultimo bit 1
       else estados:=1+var_spectrum.retraso[posicion+1]+3; //ultimo bit 0
end;
spec_z80.contador:=spec_z80.contador+estados;
end;


procedure spectrum3_main;
begin
init_controls(true,true,true,false);
while EmuStatus=EsRuning do begin
  for linea:=0 to 310 do begin  //16 lineas despues IRQ
    spec_z80.run(228);
    borde.borde_spectrum(linea);
    video_128k(linea,@memoria_3[var_spectrum.pantalla_128k,0]);
    spec_z80.contador:=spec_z80.contador-228;
  end;
  spec_z80.change_irq(IRQ_DELAY);
  var_spectrum.irq_pos:=0;
  var_spectrum.flash:=(var_spectrum.flash+1) and $f;
  if var_spectrum.flash=0 then var_spectrum.haz_flash:=not(var_spectrum.haz_flash);
  if mouse.tipo=MGUNSTICK then evalua_gunstick;
  eventos_spectrum;
  video_sync;
end;
end;

function spec3_inbyte(puerto:word):byte;
var
        temp:byte;
begin
if (((puerto and $1f)=$1f) and (var_spectrum.tipo_joy=JKEMPSTON) and (mouse.tipo<>MAMX)) then begin
  spec3_inbyte:=var_spectrum.joy_val;
  exit;
end;
if (((puerto and $7f)=$7f) and (var_spectrum.tipo_joy=JFULLER)) then begin
  spec3_inbyte:=var_spectrum.joy_val;
  exit;
end;
if (puerto and 1)=0 then begin
  temp:=$FF;
  If (puerto And $8000)=0 Then temp:=temp And var_spectrum.keyB_SPC;
  If (puerto And $4000)=0 Then temp:=temp And var_spectrum.keyH_ENT;
  If (puerto And $2000)=0 Then temp:=temp And var_spectrum.keyY_P;
  If (puerto And $1000)=0 Then temp:=temp And var_spectrum.key6_0;
  If (puerto And $800)=0 Then temp:=temp And var_spectrum.key1_5;
  If (puerto And $400)=0 Then temp:=temp And var_spectrum.keyQ_T;
  If (puerto And $200)=0 Then temp:=temp And var_spectrum.keyA_G;
  If (puerto And $100)=0 Then temp:=temp and var_spectrum.keyCAPS_V;
  spec3_inbyte:=(temp and $BF) or cinta_tzx.value or var_spectrum.altavoz;
  exit;
end;
if puerto=$ff3b then begin
  case ulaplus.mode of
    0:spec3_inbyte:=ulaplus.paleta[ulaplus.last_reg];
    1:if ulaplus.activa then spec3_inbyte:=1
        else spec3_inbyte:=0;
  end;
  exit;
end;
case (puerto and $F002) of
  $C000,$D000,$E000,$F000:begin
    spec3_inbyte:=ay8910_0.read; //fffd
    exit;
  end;
  $3000,$1000:begin
    if disk_present then spec3_inbyte:=ReadFDCData //3ffd
                else spec3_inbyte:=$ff;
    exit;
  end;
  $2000:begin
          if disk_present then spec3_inbyte:=ReadFDCStatus //2ffd
            else spec3_inbyte:=$ff;
          exit;
        end;
end;
if mouse.tipo<>MNONE then begin
  if mouse.tipo=MAMX then begin //AMX Mouse
    if (puerto and $80)<>0 then spec3_inbyte:=mouse.botones
        else spec3_inbyte:=z80pio_cd_ba_r(0,puerto shr 5);
    exit;
  end;
  if mouse.tipo=MKEMPSTON then begin //Kempston Mouse
    case puerto of
      $FADF:spec3_inbyte:=mouse.botones;
      $FBDF:spec3_inbyte:=mouse.x;
      $FFDF:spec3_inbyte:=mouse.y;
    end;
    exit;
  end;
end;
end;

procedure memoria_spectrum3;
begin
paginacion_activa:=(var_spectrum.old_7ffd and $20)=0;
paginacion_especial:=(old_1ffd and $1)<>0;
if not(paginacion_especial) then begin //Paginacion normal
  var_spectrum.marco[0]:=((var_spectrum.old_7ffd shr 4) and $1)+((old_1ffd shr 1) and $2)+8;
  var_spectrum.marco[1]:=5;
  var_spectrum.marco[2]:=2;
  var_spectrum.marco[3]:=var_spectrum.old_7ffd and $7;
end else copymemory(@var_spectrum.marco[0],@ram_bank[(old_1ffd shr 1) and $3,0],4);
end;

procedure spec3_outbyte(puerto:word;valor:byte);
var
        old_pant:byte;
        color:tcolor;
begin
        if (puerto and 1)=0 then begin
          if borde.tipo=2 then begin
            fillchar(borde.buffer[linea*228+borde.posicion],spec_z80.contador-borde.posicion,borde.color);
            borde.posicion:=spec_z80.contador;
          end;
          if (ulaplus.activa and ulaplus.enabled) then borde.color:=(valor and 7)+16
            else borde.color:=valor and 7;
          var_spectrum.altavoz:=(valor and $10) shl 2;
          exit;
        end;
        if ((puerto=$bf3b) and ulaplus.enabled) then begin
          ulaplus.mode:=valor shr 6;
          if ulaplus.mode=0 then ulaplus.last_reg:=valor and $3f;
          exit;
        end;
        if ((puerto=$ff3b) and ulaplus.enabled) then begin
          fillchar(var_spectrum.buffer_video[0],6144,1);
          fillchar(borde.buffer[0],78000,$80);
          case ulaplus.mode of
            0:begin
                ulaplus.paleta[ulaplus.last_reg]:=valor;
                color.b:=$21*(valor and 1)+$47*(valor and 1)+$97*((valor shr 1) and 1);
                color.r:=$21*((valor shr 2) and 1)+$47*((valor shr 3) and 1)+$97*((valor shr 4) and 1);
                color.g:=$21*((valor shr 5) and 1)+$47*((valor shr 6) and 1)+$97*((valor shr 7) and 1);
                set_pal_color(color,ulaplus.last_reg+16);
              end;
            1:ulaplus.activa:=(valor and 1)<>0;
          end;
          exit;
        end;
        case (puerto and $F002) of
          $C000,$D000,$E000,$F000:ay8910_0.control(valor); //fffd
          $8000,$9000,$A000,$B000:ay8910_0.write(valor); //bffd
          $4000,$5000,$6000,$7000:begin //7ffd
                  if not(paginacion_activa) then exit;
                  old_pant:=((valor and 8) shr 2)+5;
                  if old_pant<>var_spectrum.pantalla_128k then begin
                    var_spectrum.pantalla_128k:=old_pant;
                    fillchar(var_spectrum.buffer_video[0],6144,1);
                  end;
                  var_spectrum.old_7ffd:=valor;
                  memoria_spectrum3;
                end;
          $3000:if disk_present then WriteFDCData(valor); //3ffd
          $1000:begin //1ffd
                   old_1ffd:=valor;
                   memoria_spectrum3;
                end;
        end;
        if mouse.tipo=MAMX then z80pio_cd_ba_w(0,puerto shr 5,valor);
end;

procedure spec3_putbyte(direccion:word;valor:byte);
var
  temp,temp3:word;
  f:byte;
  dir1,dir2:word;
begin
dir1:=direccion shr 14;
dir2:=direccion and $3fff;
if (not(paginacion_especial) and (dir1=0)) then exit;
memoria_3[var_spectrum.marco[dir1],dir2]:=valor;
if (var_spectrum.pantalla_128k=var_spectrum.marco[dir1]) then begin
  case dir2 of
    0..$17ff:var_spectrum.buffer_video[dir2]:=true;
    $1800..$1aff:begin
                    temp:=((dir2-$1800) shr 5) shl 3;
                    temp3:=((dir2-$1800) and $1f);
                    for f:=0 to 7 do var_spectrum.buffer_video[tabla_scr[temp+f]+temp3]:=true;
                  end;
  end;
end;
end;

function spec3_getbyte(direccion:word):byte;  
var
  temp:byte;
  temp2:word;
begin
temp:=direccion shr 14;
temp2:=direccion and $3fff;
spec3_getbyte:=memoria_3[var_spectrum.marco[temp],temp2];
end;

end.
