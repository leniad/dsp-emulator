unit spectrum_3;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     main_engine,ay_8910,z80_sp,upd765,controls_engine,spectrum_128k,cargar_dsk,
     forms,rom_engine,pal_engine,sound_engine,z80pio,gfx_engine;

const
  plus3_rom:array[0..3] of tipo_roms=(
        (n:'plus3-0.rom';l:$4000;p:0;crc:$30c9f490),(n:'plus3-1.rom';l:$4000;p:$4000;crc:$a7916b3f),
        (n:'plus3-2.rom';l:$4000;p:$8000;crc:$c9a0b748),(n:'plus3-3.rom';l:$4000;p:$c000;crc:$b88fd6e3));
  ram_bank:array[0..3,0..3] of byte=((0,1,2,3),(4,5,6,7),(4,5,6,3),(4,7,6,3));

var
   old_1ffd:byte;
   memoria_3:array[0..11,0..$3fff] of byte;
   paginacion_especial,disk_present:boolean;
   linea_3:word;

function iniciar_3:boolean;
//CPU
procedure spec3_putbyte(direccion:word;valor:byte);
procedure spec3_outbyte(puerto:word;valor:byte);

implementation
uses tap_tzx,spectrum_misc;

procedure spectrum3_loaddisk;
begin
load_dsk.showmodal;
end;

procedure spec3_reset;
begin
reset_misc;
ay8910_0.reset;
ay8910_1.reset;
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
begin
//Esto esta mal!! deberia ser 228T, pero si pongo 228 Gauntlet no funciona
if (direccion and $c000)=$4000 then spec_z80.contador:=spec_z80.contador+var_spectrum.retraso[linea_3*227+spec_z80.contador];
end;

procedure spec3_retraso_puerto(puerto:word);
begin
//NO hay!
spec_z80.contador:=spec_z80.contador+4;
end;

procedure spectrum3_main;
begin
init_controls(true,true,true,false);
while EmuStatus=EsRunning do begin
  for linea_3:=0 to 310 do begin  //16 lineas despues IRQ
    if mouse.tipo=MGUNSTICK then evalua_gunstick;
    eventos_spectrum;
    spec_z80.run(228);
    borde.borde_spectrum(linea_3);
    video_128k(linea_3,@memoria_3[var_spectrum.pantalla_128k,0]);
    spec_z80.contador:=spec_z80.contador-228;
  end;
  if spec_z80.contador<28 then begin
     spec_z80.change_irq(IRQ_DELAY);
     var_spectrum.irq_pos:=spec_z80.contador;
  end;
  var_spectrum.flash:=(var_spectrum.flash+1) and $f;
  if var_spectrum.flash=0 then var_spectrum.haz_flash:=not(var_spectrum.haz_flash);
  video_sync;
end;
end;

function spec3_inbyte(puerto:word):byte;
var
  temp:byte;
begin
temp:=$ff;
if (puerto and 1)=0 then begin
  if (puerto and $8000)=0 then temp:=temp and var_spectrum.keyB_SPC;
  if (puerto and $4000)=0 then temp:=temp and var_spectrum.keyH_ENT;
  if (puerto and $2000)=0 then temp:=temp and var_spectrum.keyY_P;
  if (puerto and $1000)=0 then temp:=temp and var_spectrum.key6_0;
  if (puerto and $800)=0 then temp:=temp and var_spectrum.key1_5;
  if (puerto and $400)=0 then temp:=temp and var_spectrum.keyQ_T;
  if (puerto and $200)=0 then temp:=temp and var_spectrum.keyA_G;
  if (puerto and $100)=0 then temp:=temp and var_spectrum.keyCAPS_V;
  spec3_inbyte:=(temp and $bf) or cinta_tzx.value or var_spectrum.altavoz;
end else begin
  if (((puerto and $20)=0) and (var_spectrum.tipo_joy=JKEMPSTON) and (mouse.tipo<>MAMX)) then
  temp:=var_spectrum.joy_val;
  if (((puerto and $7f)=$7f) and (var_spectrum.tipo_joy=JFULLER)) then temp:=var_spectrum.joy_val;
  if puerto=$ff3b then begin
      case ulaplus.mode of
        0:temp:=ulaplus.paleta[ulaplus.last_reg];
        1:temp:=byte(ulaplus.activa);
      end;
  end;
  case (puerto and $f002) of
    $c000,$d000,$e000,$f000:case var_spectrum.ay_select of //fffd
                              0:temp:=ay8910_0.read;
                              1:temp:=ay8910_1.read;
                            end;
    $3000:if disk_present then temp:=ReadFDCData; //3ffd
    $2000:if disk_present then temp:=ReadFDCStatus; //2ffd
  end;
  if mouse.tipo<>MNONE then begin
      if mouse.tipo=MAMX then begin //AMX Mouse
        if (puerto and $80)<>0 then temp:=mouse.botones
          else temp:=pio_0.cd_ba_r(puerto shr 5);
      end;
      if mouse.tipo=MKEMPSTON then begin //Kempston Mouse
        case puerto of
            $fadf:temp:=mouse.botones;
            $fbdf:temp:=mouse.x;
            $fddf:temp:=mouse.y;
        end;
      end;
  end;
  spec3_inbyte:=temp;
end;
end;

procedure spec3_outbyte(puerto:word;valor:byte);
var
        old_pant:byte;
        color:tcolor;
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
begin
        if (puerto and 1)=0 then begin
          if borde.tipo=2 then begin
            fillchar(borde.buffer[linea_3*228+borde.posicion],spec_z80.contador-borde.posicion,borde.color);
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
          reset_gfx;
          fillchar(borde.buffer,78000,$80);
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
        case (puerto and $f002) of
          $c000,$d000,$e000,$f000:begin //fffd
                  if (var_spectrum.turbo_sound and ((valor and $9c)=$9c)) then var_spectrum.ay_select:=not(valor) and 1;
                  case var_spectrum.ay_select of
                    0:ay8910_0.control(valor);
                    1:ay8910_1.control(valor);
                  end;
              end;
          $8000,$9000,$a000,$b000:case var_spectrum.ay_select of  //bffd
                                      0:ay8910_0.write(valor);
                                      1:ay8910_1.write(valor);
                                  end;
          $4000,$5000,$6000,$7000:begin //7ffd
                  if not(paginacion_activa) then exit;
                  old_pant:=((valor and 8) shr 2)+5;
                  if old_pant<>var_spectrum.pantalla_128k then begin
                    var_spectrum.pantalla_128k:=old_pant;
                    reset_gfx;
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
        if mouse.tipo=MAMX then pio_0.cd_ba_w(puerto shr 5,valor);
end;

procedure spec3_putbyte(direccion:word;valor:byte);
var
  temp,temp3:word;
  f:byte;
  dir1,dir2:word;
begin
dir1:=direccion shr 14;
if (not(paginacion_especial) and (dir1=0)) then exit;
dir2:=direccion and $3fff;
memoria_3[var_spectrum.marco[dir1],dir2]:=valor;
if (var_spectrum.pantalla_128k=var_spectrum.marco[dir1]) then begin
  case dir2 of
    0..$17ff:gfx[1].buffer[dir2]:=true;
    $1800..$1aff:begin
                    temp:=((dir2-$1800) shr 5) shl 3;
                    temp3:=((dir2-$1800) and $1f);
                    for f:=0 to 7 do gfx[1].buffer[tabla_scr[temp+f]+temp3]:=true;
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
case var_spectrum.audio_128k of
  0:iniciar_audio(false);
  1,2:iniciar_audio(true);
end;
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
llamadas_maquina.bucle_general:=spectrum3_main;
llamadas_maquina.reset:=spec3_reset;
llamadas_maquina.fps_max:=17734475/5/70908;
iniciar_3:=false;
//Iniciar el Z80 y pantalla
if not(spec_comun(17734475 div 5)) then exit;
spec_z80.change_ram_calls(spec3_getbyte,spec3_putbyte);
spec_z80.change_io_calls(spec3_inbyte,spec3_outbyte);
spec_z80.change_retraso_call(spec3_retraso_memoria,spec3_retraso_puerto);
ay8910_0:=ay8910_chip.create(17734475 div 10,AY8912);
ay8910_0.change_io_calls(spec128_lg,nil,nil,nil);
ay8910_1:=ay8910_chip.create(17734475 div 10,AY8912);
if not(roms_load(@mem_temp,plus3_rom)) then exit;
copymemory(@memoria_3[8,0],@mem_temp[0],$4000);
copymemory(@memoria_3[9,0],@mem_temp[$4000],$4000);
copymemory(@memoria_3[10,0],@mem_temp[$8000],$4000);
copymemory(@memoria_3[11,0],@mem_temp[$c000],$4000);
fillchar(var_spectrum.retraso[0],71000,0);
f:=14361;
for h:=0 to 191 do begin
  copymemory(@var_spectrum.retraso[f],@cmem3[0],128);
  inc(f,228);
  end;
iniciar_3:=true;
end;

end.
