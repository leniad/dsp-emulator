unit spectrum_128k;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}main_engine,ay_8910,z80_sp,sysutils,
     controls_engine,dialogs,rom_engine,pal_engine,sound_engine,z80pio,
     gfx_engine;

const
  spec128_rom:array[0..2] of tipo_roms=(
        (n:'128-0.rom';l:$4000;p:0;crc:$e76799d2),(n:'128-1.rom';l:$4000;p:$4000;crc:$b96a36be),());
  spec_plus2_rom:array[0..2] of tipo_roms=(
        (n:'plus2-0.rom';l:$4000;p:0;crc:$5d2e8c66),(n:'plus2-1.rom';l:$4000;p:$4000;crc:$98b1320b),());

var
   memoria_128k:array[0..9,0..$3fff] of byte;
   paginacion_activa:boolean;
   linea:word;

procedure Cargar_Spectrum128K;
procedure spectrum128_main;
function spec128_getbyte(direccion:word):byte;
procedure spec128_putbyte(direccion:word;valor:byte);
function spec128_inbyte(puerto:word):byte;
procedure spec128_outbyte(valor:byte;puerto:word);
function iniciar_128k:boolean;
procedure spec128k_reset;
procedure spec128_retraso_memoria(direccion:word);
procedure spec128_retraso_puerto(puerto:word);
function spec128_lg():byte;
//Video
procedure borde_128_full(linea:word);
procedure video_128k(linea:word;pvideo:pbyte);

implementation
uses tap_tzx,principal,spectrum_misc;

function spec128_lg:byte;
begin
spec128_lg:=mouse.lg_val;
end;

procedure Cargar_Spectrum128K;
begin
principal1.panel2.Visible:=true;
llamadas_maquina.iniciar:=iniciar_128k;
llamadas_maquina.bucle_general:=spectrum128_main;
llamadas_maquina.reset:=spec128k_reset;
llamadas_maquina.cintas:=spectrum_tapes;
llamadas_maquina.grabar_snapshot:=grabar_spec;
llamadas_maquina.fps_max:=50;
llamadas_maquina.close:=spec_cerrar_comun;
llamadas_maquina.configurar:=spectrum_config;
llamadas_maquina.velocidad_cpu:=3546900;
var_spectrum.samples_audio:=llamadas_maquina.velocidad_cpu/freq_base_audio;
var_spectrum.samples_beeper:=llamadas_maquina.velocidad_cpu/(freq_base_audio*var_spectrum.beeper_oversample);
end;

function iniciar_128k:boolean;
var
 f,g,pos:integer;
 h,m:byte;
 mem_temp:array[0..$7fff] of byte;
begin
iniciar_128k:=false;
//Iniciar el Z80 y pantalla
if not(spec_comun) then exit;
spec_z80.change_ram_calls(spec128_getbyte,spec128_putbyte);
spec_z80.change_io_calls(spec128_inbyte,spec128_outbyte);
spec_z80.change_retraso_call(spec128_retraso_memoria,spec128_retraso_puerto);
ay8910_0:=ay8910_chip.create(1773400,1);
ay8910_0.change_io_calls(spec128_lg,nil,nil,nil);
case main_vars.tipo_maquina of
  1:if not(cargar_roms(@mem_temp[0],@spec128_rom[0],'spec128.zip',0)) then exit;
  4:if not(cargar_roms(@mem_temp[0],@spec_plus2_rom[0],'plus2.zip',0)) then exit;
end;
copymemory(@memoria_128k[8,0],@mem_temp[0],$4000);
copymemory(@memoria_128k[9,0],@mem_temp[$4000],$4000);
fillchar(var_spectrum.retraso[0],71000,0);
f:=14361;
for h:=0 to 191 do begin
  copymemory(@var_spectrum.retraso[f],@cmemory[0],128);
  f:=f+228;
end;
fillchar(var_spectrum.ft_bus[0],71000*2,$ff);
pos:=14361;  //realmente deberia ser 14368
for h:=0 to 191 do begin
  f:=(h mod $8)*$100;
  g:=$1800;
  for m:=0 to 15 do begin
    var_spectrum.ft_bus[pos]:=f; //4000
    inc(pos);inc(f);
    var_spectrum.ft_bus[pos]:=g; //5800
    inc(pos);inc(g);
    var_spectrum.ft_bus[pos]:=f; //4001
    inc(pos);inc(f);
    var_spectrum.ft_bus[pos]:=g; //5801
    inc(pos);inc(g);
    inc(pos,4); //idle
  end;
  inc(pos,100);
end;
case var_spectrum.audio_128k of
  0:iniciar_audio(false);
  1,2:iniciar_audio(true);
end;
spec128k_reset;
iniciar_128k:=true;
end;

procedure spec128k_reset;
var
  f:byte;
begin
reset_misc;
for f:=0 to 7 do fillchar(memoria_128k[f],16384,0);
ay8910_0.reset;
var_spectrum.marco[0]:=8;
var_spectrum.marco[1]:=5;
var_spectrum.marco[2]:=2;
var_spectrum.marco[3]:=0;
var_spectrum.pantalla_128k:=5;
paginacion_activa:=true;
end;

procedure video_128k(linea:word;pvideo:pbyte);
var
        nlinea1,nlinea2,x,color2,color,atrib,video,temp:byte;
        pant_x,pos_video:word;
        poner_linea:boolean;
        ptemp:pword;
        ptvideo:pbyte;
begin
poner_linea:=false;
case linea of
        63..254:begin
                nlinea1:=linea-63;
                nlinea2:=linea-15;
                pos_video:=((linea-63) shr 3) shl 5;
                for x:=0 to 31 do begin
                      ptvideo:=pvideo;
                      inc(ptvideo,$1800+pos_video);
                      atrib:=ptvideo^;
                      ptvideo:=pvideo;
                      inc(ptvideo,tabla_scr[nlinea1]+x);
                      video:=ptvideo^;
                      if (var_spectrum.buffer_video[tabla_scr[nlinea1]+x] or (((atrib and $80)<>0)) and not(main_screen.rapido)) then begin
                        var_spectrum.buffer_video[tabla_scr[nlinea1]+x]:=false;
                        poner_linea:=true;
                        pant_x:=48+(x shl 3);
                        if (ulaplus.activa and ulaplus.enabled) then begin
                          temp:=((((atrib and $80) shr 6)+((atrib and $40) shr 6)) shl 4)+16;
                          color2:=temp+((atrib shr 3) and 7)+8;
                          color:=temp+(atrib and 7);
                        end else begin
                          color2:=(atrib shr 3) and 7;
                          color:=atrib and 7;
                          if (atrib and 64)<>0 then begin color:=color+8;color2:=color2+8;end;
                          if ((atrib and 128)<>0) and var_spectrum.haz_flash then begin temp:=color;color:=color2;color2:=temp;end;
                        end;
                        ptemp:=punbuf;
                        if (video and 128)<>0 then ptemp^:=paleta[color] else ptemp^:=paleta[color2];
                        inc(ptemp);
                        if (video and 64)<>0 then ptemp^:=paleta[color] else ptemp^:=paleta[color2];
                        inc(ptemp);
                        if (video and 32)<>0 then ptemp^:=paleta[color] else ptemp^:=paleta[color2];
                        inc(ptemp);
                        if (video and 16)<>0 then ptemp^:=paleta[color] else ptemp^:=paleta[color2];
                        inc(ptemp);
                        if (video and 8)<>0 then ptemp^:=paleta[color] else ptemp^:=paleta[color2];
                        inc(ptemp);
                        if (video and 4)<>0 then ptemp^:=paleta[color] else ptemp^:=paleta[color2];
                        inc(ptemp);
                        if (video and 2)<>0 then ptemp^:=paleta[color] else ptemp^:=paleta[color2];
                        inc(ptemp);
                        if (video and 1)<>0 then ptemp^:=paleta[color] else ptemp^:=paleta[color2];
                        putpixel(pant_x,nlinea2,8,punbuf,1);
                      end;
                      inc(pos_video);
                  end;
        end; {del selector}
        else exit;
end; {del case}
if poner_linea then actualiza_trozo_simple(48,nlinea2,256,1,1);
end;

procedure borde_128_full(linea:word);
var
        linea_actual:word;
        ptemp:pword;
        f:word;
        posicion:dword;
begin
if ((main_screen.rapido and ((linea and 7)<>0)) or (borde.tipo=0) or (linea<14) or (linea>302)) then exit;
fillchar(borde.buffer[linea*228+borde.posicion],spec_z80.contador-borde.posicion,borde.color);
borde.posicion:=spec_z80.contador-228;
if linea=14 then exit;
linea_actual:=linea-15;
ptemp:=punbuf;
posicion:=(linea-1)*228;
//24t borde iqz --> 48 pixels
for f:=203 to 227 do begin
  ptemp^:=paleta[borde.buffer[posicion+f]];
  inc(ptemp);
  ptemp^:=paleta[borde.buffer[posicion+f]];
  inc(ptemp);
end;
putpixel(0,linea_actual,48,punbuf,1);
actualiza_trozo_simple(0,linea_actual,48,1,1);
//24t borde der --> 48 pixels
ptemp:=punbuf;
posicion:=linea*228;
for f:=128 to 151 do begin
  ptemp^:=paleta[borde.buffer[posicion+f]];
  inc(ptemp);
  ptemp^:=paleta[borde.buffer[posicion+f]];
  inc(ptemp);
end;
putpixel(304,linea_actual,48,punbuf,1);
actualiza_trozo_simple(304,linea_actual,48,1,1);
if ((linea>62) and (linea<255)) then exit;
//128t Centro pantalla --> 256 pixels
ptemp:=punbuf;
for f:=0 to 127 do begin
    ptemp^:=paleta[borde.buffer[posicion+f]];
    inc(ptemp);
    ptemp^:=paleta[borde.buffer[posicion+f]];
    inc(ptemp);
end;
putpixel(48,linea_actual,256,punbuf,1);
actualiza_trozo_simple(48,linea_actual,256,1,1);
end;

procedure spectrum128_main;
begin
init_controls(true,true,true,false);
while EmuStatus=EsRuning do begin
  for linea:=0 to 310 do begin
    spec_z80.run(228);
    borde.borde_spectrum(linea);
    video_128k(linea,@memoria_128k[var_spectrum.pantalla_128k,0]);
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

procedure spec128_retraso_memoria(direccion:word);
var
  estados:byte;
  posicion:dword;
begin
estados:=0;
posicion:=linea*228+spec_z80.contador;
case (direccion and $c000) of
  $4000:estados:=var_spectrum.retraso[posicion];
  $c000:if ((var_spectrum.marco[3] and 1)<>0) then estados:=var_spectrum.retraso[posicion];
end;
spec_z80.contador:=spec_z80.contador+estados;
end;

procedure spec128_retraso_puerto(puerto:word);
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

function spec128_getbyte(direccion:word):byte;
begin
spec128_getbyte:=memoria_128k[var_spectrum.marco[direccion shr 14],direccion and $3fff];
end;

procedure spec128_putbyte(direccion:word;valor:byte);
var
  temp,temp3,dir2:word;
  dir1,f:byte;
begin
dir1:=direccion shr 14;
if dir1=0 then exit;
dir2:=direccion and $3fff;
memoria_128k[var_spectrum.marco[dir1],dir2]:=valor;
if (var_spectrum.pantalla_128k=var_spectrum.marco[dir1]) then begin
  case dir2 of
    0..$17ff:var_spectrum.buffer_video[dir2]:=true;
    $1800..$1aff:begin
                  temp:=((dir2-$1800) shr 5) shl 3;
                  temp3:=(dir2-$1800) and $1f;
                  for f:=0 to 7 do var_spectrum.buffer_video[tabla_scr[temp+f]+temp3]:=true;
               end;
  end;
end;
end;

function spec128_inbyte(puerto:word):byte;
var
  temp:byte;
begin
if (((puerto and $20)=$0) and (var_spectrum.tipo_joy=JKEMPSTON) and (mouse.tipo<>MAMX)) then begin
  spec128_inbyte:=var_spectrum.kempston;
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
  spec128_inbyte:=(temp and $bf) or cinta_tzx.value or var_spectrum.altavoz;
  exit;
end;
if ((puerto=$ff3b) and ulaplus.enabled) then begin
  case ulaplus.mode of
    0:spec128_inbyte:=ulaplus.paleta[ulaplus.last_reg];
    1:if ulaplus.activa then spec128_inbyte:=1
        else spec128_inbyte:=0;
  end;
  exit;
end;
case (puerto and $F002) of
  $C000,$D000,$E000,$F000:begin  //fffd
    spec128_inbyte:=ay8910_0.read;
    exit;
  end;
end;
if mouse.tipo<>MNONE then begin
  if mouse.tipo=MAMX then begin //AMX Mouse
    if (puerto and $80)<>0 then spec128_inbyte:=mouse.botones
        else spec128_inbyte:=z80pio_cd_ba_r(0,puerto shr 5);
    exit;
  end;
  if mouse.tipo=MKEMPSTON then begin //Kempston Mouse
    case puerto of
      $FADF:spec128_inbyte:=mouse.botones;
      $FBDF:spec128_inbyte:=mouse.x;
      $FFDF:spec128_inbyte:=mouse.y;
    end;
    exit;
  end;
end;
if var_spectrum.ft_bus[linea*228+spec_z80.contador]=$ffff then spec128_inbyte:=$FF
  else spec128_inbyte:=memoria_128k[var_spectrum.pantalla_128k,var_spectrum.ft_bus[linea*228+spec_z80.contador]];
end;

procedure spec128_outbyte(valor:byte;puerto:word);
var
  old_pant:byte;
  color:tcolor;
begin
        if (puerto and $1)=0 then begin
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
          $C000,$D000,$E000,$F000:begin
              ay8910_0.control(valor); //fffd
              exit;
          end;
          $8000,$9000,$A000,$B000:begin
                ay8910_0.write(valor); //bffd
                exit;
          end;
          $1000,$4000,$5000,$6000,$7000:begin //7ffd
                  old_pant:=((valor and 8) shr 2)+5;
                  if old_pant<>var_spectrum.pantalla_128k then begin
                    var_spectrum.pantalla_128k:=old_pant;
                    fillchar(var_spectrum.buffer_video[0],6144,1);
                  end;
                  var_spectrum.old_7ffd:=valor;
                  if not(paginacion_activa) then exit;
                  paginacion_activa:=(var_spectrum.old_7ffd and $20)=0;
                  var_spectrum.marco[0]:=((var_spectrum.old_7ffd shr 4) and $1)+8;
                  var_spectrum.marco[3]:=var_spectrum.old_7ffd and $7;
                  exit;
                end;
        end;
        if mouse.tipo=MAMX then z80pio_cd_ba_w(0,puerto shr 5,valor);
end;

end.
