unit spectrum_48k;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,z80_sp,misc_functions,graphics,controls_engine,dialogs,lenguaje,
     sysutils,rom_engine,main_engine,gfx_engine,extctrls,pal_engine,
     sound_engine,z80pio;

var
    rom_cambiada_48:boolean=false;

procedure Cargar_Spectrum48K;
function iniciar_48k:boolean;
procedure spec48k_reset;
//CPU
procedure spectrum48_main;
function spec48_getbyte(direccion:word):byte;
procedure spec48_putbyte(direccion:word;valor:byte);
function spec48_inbyte(puerto:word):byte;
procedure spec48_outbyte(valor:byte;puerto:word);
procedure spec48_retraso_memoria(direccion:word);
procedure spec48_retraso_puerto(puerto:word);
//Video
procedure borde_48_full(linea:word);

implementation
uses tap_tzx,spectrum_misc;
var
    spec_16k:boolean;
    linea:word;

procedure Cargar_Spectrum48K;
begin
if main_vars.tipo_maquina=0 then spec_16k:=false
  else spec_16k:=true;
llamadas_maquina.iniciar:=iniciar_48k;
llamadas_maquina.bucle_general:=spectrum48_main;
llamadas_maquina.cintas:=spectrum_tapes;
llamadas_maquina.reset:=spec48k_reset;
llamadas_maquina.grabar_snapshot:=grabar_spec;
llamadas_maquina.fps_max:=50;
llamadas_maquina.cerrar:=spec_cerrar_comun;
llamadas_maquina.configurar:=spectrum_config;
llamadas_maquina.velocidad_cpu:=3500000;
samples_audio:=llamadas_maquina.velocidad_cpu/44100;
samples_beeper:=llamadas_maquina.velocidad_cpu/(44100*beeper_oversample);
interface2.hay_if2:=false;
end;

function iniciar_48k:boolean;
var
  rom_cargada:boolean;
  f,g,pos:integer;
  h,m:byte;
  cadena:string;
begin
iniciar_48k:=false;
//Iniciar el Z80 y pantalla
if not(spec_comun) then exit;
spec_z80.change_retraso_call(spec48_retraso_memoria,spec48_retraso_puerto);
spec_z80.change_ram_calls(spec48_getbyte,spec48_putbyte);
spec_z80.change_io_calls(spec48_inbyte,spec48_outbyte);
cadena:=solo_nombre(changefileext(extractfilename(Directory.spectrum_48),''));
if extension_fichero(Directory.spectrum_48)='ZIP' then rom_cargada:=carga_rom_zip(Directory.spectrum_48,cadena+'.ROM',@memoria[0],$4000,0,false)
  else rom_cargada:=carga_rom_sp(Directory.spectrum_48,@memoria[0],$4000);
if not(rom_cargada) then begin
  MessageDlg(leng[main_vars.idioma].errores[0]+' "'+Directory.spectrum_48+'"', mtError,[mbOk], 0);
  exit;
end;
iniciar_audio(false);
fillchar(retraso[0],70000,0);
f:=14335;  //24 del borde
for h:=0 to 191 do begin
  copymemory(@retraso[f],@cmemory[0],128);
  inc(f,224);
end;
pos:=14335; //deberia ser 14338
fillchar(ft_bus[0],70000*2,$ff);
for h:=0 to 191 do begin
  f:=$4000+((h mod $8)*$100);
  g:=$5800;
  for m:=0 to 15 do begin
    ft_bus[pos]:=f; //4000
    inc(pos);inc(f);
    ft_bus[pos]:=g; //5800
    inc(pos);inc(g);
    ft_bus[pos]:=f; //4001
    inc(pos);inc(f);
    ft_bus[pos]:=g; //5801
    inc(pos);inc(g);
    inc(pos,4);  //idle
  end;
  inc(pos,96);
end;
spec48k_reset;
iniciar_48k:=true;
end;

procedure spec48k_reset;
begin
reset_misc;
if not(rom_cambiada_48) then change_caption(llamadas_maquina.caption);
fillchar(memoria[$4000],49152,0);
end;

procedure video48k(linea:word);
var
  x,color2,color,atrib,video,temp:byte;
  pant_x,pos_video:word;
  ptemp:pword;
  spec_z80_reg:npreg_z80;
  poner_linea:boolean;
begin
if ((linea<64) or (linea>255)) then exit
  else linea:=linea-64;
poner_linea:=false;
pos_video:=(linea and $f8) shl 2;
spec_z80_reg:=spec_z80.get_internal_r;
for x:=0 to 31 do begin
  atrib:=memoria[$5800+pos_video];
  if ((spec_z80_reg.i>=$40) and (spec_z80_reg.i<=$7F)) then video:=memoria[$4000+tabla_scr[linea]+x+spec_z80_reg.r]
    else video:=memoria[$4000+tabla_scr[linea]+x];
  if ((buffer_video[tabla_scr[linea]+x]) or (((atrib and $80)<>0)) and not(main_screen.rapido)) then begin
    buffer_video[tabla_scr[linea]+x]:=false;
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
      if (((atrib and 128)<>0) and haz_flash) then begin temp:=color;color:=color2;color2:=temp;end;
    end;
    if not(poner_linea) then exit;
    ptemp:=punbuf;
    if (video and $80)<>0 then ptemp^:=paleta[color] else ptemp^:=paleta[color2];
    inc(ptemp);
    if (video and $40)<>0 then ptemp^:=paleta[color] else ptemp^:=paleta[color2];
    inc(ptemp);
    if (video and $20)<>0 then ptemp^:=paleta[color] else ptemp^:=paleta[color2];
    inc(ptemp);
    if (video and $10)<>0 then ptemp^:=paleta[color] else ptemp^:=paleta[color2];
    inc(ptemp);
    if (video and 8)<>0 then ptemp^:=paleta[color] else ptemp^:=paleta[color2];
    inc(ptemp);
    if (video and 4)<>0 then ptemp^:=paleta[color] else ptemp^:=paleta[color2];
    inc(ptemp);
    if (video and 2)<>0 then ptemp^:=paleta[color] else ptemp^:=paleta[color2];
    inc(ptemp);
    if (video and 1)<>0 then ptemp^:=paleta[color] else ptemp^:=paleta[color2];
    putpixel(pant_x,linea+48,8,punbuf,1);
  end;
  pos_video:=pos_video+1;
end;
if poner_linea then actualiza_trozo_simple(48,linea+48,256,1,1);
end;

procedure borde_48_full(linea:word);
var
        linea_actual:word;
        ptemp:pword;
        f:word;
        posicion:dword;
begin
//Si lo pongo antes no rellena la linea 15!!!!
if ((main_screen.rapido and ((linea and 7)<>0)) or (linea<15) or (linea>303)) then exit;
fillchar(borde.buffer[linea*224+borde.posicion],spec_z80.contador-borde.posicion,borde.color);
borde.posicion:=spec_z80.contador-224;
if linea=15 then exit;
linea_actual:=linea-16;
//24t borde iqz --> 48pixels
ptemp:=punbuf;
posicion:=(linea-1)*224;
for f:=200 to 223 do begin
  ptemp^:=paleta[borde.buffer[posicion+f]];
  inc(ptemp);
  ptemp^:=paleta[borde.buffer[posicion+f]];
  inc(ptemp);
end;
putpixel(0,linea_actual,48,punbuf,1);
actualiza_trozo_simple(0,linea_actual,48,1,1);
//24t borde der --> 48 pixels
posicion:=linea*224;
ptemp:=punbuf;
for f:=128 to 151 do begin
  ptemp^:=paleta[borde.buffer[posicion+f]];
  inc(ptemp);
  ptemp^:=paleta[borde.buffer[posicion+f]];
  inc(ptemp);
end;
putpixel(304,linea_actual,48,punbuf,1);
actualiza_trozo_simple(304,linea_actual,48,1,1);
//128t Centro pantalla --> 256 pixels
if ((linea>63) and (linea<256)) then exit;
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

procedure spectrum48_main;
begin
init_controls(true,true,true,false);
while EmuStatus=EsRuning do begin
  for linea:=0 to 311 do begin
    spec_z80.run(224);
    borde.borde_spectrum(linea);
    video48k(linea);
    spec_z80.contador:=spec_z80.contador-224;
  end;
  spec_z80.pedir_irq:=IRQ_DELAY;
  spectrum_irq_pos:=spec_z80.contador;
  flash:=(flash+1) and $f;
  if flash=0 then haz_flash:=not(haz_flash);
  if mouse.tipo=1 then evalua_gunstick;
  eventos_spectrum;
  video_sync;
end;
end;

procedure spec48_retraso_memoria(direccion:word);
var
  estados:byte;
begin
case direccion of
  $4000..$7fff:estados:=retraso[linea*224+spec_z80.contador];
    else estados:=0;
end;
spec_z80.contador:=spec_z80.contador+estados;
end;

procedure spec48_retraso_puerto(puerto:word);
var
  estados,estados_f:byte;
  posicion:dword;
begin
posicion:=linea*224+spec_z80.contador;
case puerto of
  $4000..$7fff:begin
                 if (puerto and 1)<>0 then begin //ultimo bit 1
                    estados:=retraso[posicion]+1;
                    posicion:=posicion+estados;
                    estados_f:=estados;
                    //
                    estados:=retraso[posicion]+1;
                    posicion:=posicion+estados;
                    estados_f:=estados_f+estados;
                    //
                    estados:=retraso[posicion]+1;
                    posicion:=posicion+estados;
                    estados_f:=estados_f+estados;
                    //
                    estados:=retraso[posicion]+1;
                    estados_f:=estados_f+estados;
                 end else begin //ultimo bit 0
                    estados:=retraso[posicion]+1;
                    posicion:=posicion+estados;
                    estados_f:=estados;
                    //
                    estados:=retraso[posicion]+3;
                    estados_f:=estados_f+estados;
                 end;
               end;
  else begin
          if (puerto and 1)<>0 then estados_f:=4 //ultimo bit 1
            else estados_f:=1+retraso[posicion+1]+3; //ultimo bit 0
       end;
end;
spec_z80.contador:=spec_z80.contador+estados_f;
end;

function spec48_getbyte(direccion:word):byte;
begin
if spec_16k then spec48_getbyte:=memoria[direccion and $7fff]
  else spec48_getbyte:=memoria[direccion];
end;

procedure spec48_putbyte(direccion:word;valor:byte);
var
        temp,temp2:word;
        f:byte;
begin
if spec_16k then direccion:=direccion and $7fff;
if ((memoria[direccion]=valor) or (direccion<$4000)) then exit; //Si es igual me salgo
memoria[direccion]:=valor;
case direccion of
        $4000..$57ff:buffer_video[direccion and $1fff]:=true;
        $5800..$5aff:begin
                        temp:=((direccion and $3ff) shr 5) shl 3;
                        temp2:=direccion and $1F;
                        for f:=0 to 7 do buffer_video[tabla_scr[temp+f]+temp2]:=true;
                     end;
end;
end;

function spec48_inbyte(puerto:word):byte;
var
  temp:byte;
begin
if (((puerto and $20)=$0) and jkempston and (mouse.tipo<>3)) then begin
  spec48_inbyte:=kempston;
  exit;
end;
if (puerto and 1)=0 then begin
  if sd_1 then temp:=$DF else temp:=$FF;
  If (puerto And $8000)=0 Then temp:=temp And keyB_SPC;
  If (puerto And $4000)=0 Then temp:=temp And keyH_ENT;
  If (puerto And $2000)=0 Then temp:=temp And keyY_P;
  If (puerto And $1000)=0 Then temp:=temp And key6_0;
  If (puerto And $800)=0 Then temp:=temp And key1_5;
  If (puerto And $400)=0 Then temp:=temp And keyQ_T;
  If (puerto And $200)=0 Then temp:=temp And keyA_G;
  If (puerto And $100)=0 Then temp:=temp and keyCAPS_V;
  spec48_inbyte:=(temp and $bf) or cinta_tzx.value or altavoz;
  exit;
end;
if ((puerto=$ff3b) and ulaplus.enabled) then begin
  case ulaplus.mode of
    0:spec48_inbyte:=ulaplus.paleta[ulaplus.last_reg];
    1:if ulaplus.activa then spec48_inbyte:=1
        else spec48_inbyte:=0;
  end;
  exit;
end;
if mouse.tipo<>0 then begin
  if mouse.tipo=3 then begin //AMX Mouse
    if (puerto and $80)<>0 then spec48_inbyte:=mouse.botones
        else spec48_inbyte:=z80pio_cd_ba_r(0,(puerto shr 5) and $3);
    exit;
  end;
  if mouse.tipo=2 then begin //Kempston Mouse
    case puerto of
      $FADF:spec48_inbyte:=mouse.botones;
      $FBDF:spec48_inbyte:=mouse.x;
      $FFDF:spec48_inbyte:=mouse.y;
    end;
    exit;
  end;
end;
if ft_bus[linea*224+spec_z80.contador]=$ffff then spec48_inbyte:=$FF
  else spec48_inbyte:=memoria[ft_bus[linea*224+spec_z80.contador]];
end;

procedure spec48_outbyte(valor:byte;puerto:word);
var
  color:tcolor;
begin
if (puerto and 1)=0 then begin
  if borde.tipo=2 then begin
      fillchar(borde.buffer[linea*224+borde.posicion],spec_z80.contador-borde.posicion,borde.color);
      borde.posicion:=spec_z80.contador;
    end;
  if (ulaplus.activa and ulaplus.enabled) then borde.color:=(valor and 7)+16
    else borde.color:=valor and 7;
  altavoz:=(valor and $10) shl 2;
  //Aqui se puede ver la dependencia del puerto $FE del
  //altavoz y del ear (Issue 2 y 3). Lo que entra por el
  //altavoz,el ear o el mic afecta a el bit 6... por
  //ejemplo en 'Ole toro' solo acepta pulsaciones de
  //teclado cuando suena la musica, Abu Simbel no empieza
  //correctamente, Rasputin no suena la musica y no
  //empieza al pulsar 0 --> Gracias Pera Putnik!!
  if not(cinta_tzx.play_tape) then begin
    if issue2 then begin
      if (valor and $18)=0 then cinta_tzx.value:=0 else cinta_tzx.value:=$40;
    end else begin
      if (valor and $10)=0 then cinta_tzx.value:=0 else cinta_tzx.value:=$40;
    end;
  end;
  exit;
end;
if ((puerto=$bf3b) and ulaplus.enabled) then begin
  ulaplus.mode:=valor shr 6;
  if ulaplus.mode=0 then ulaplus.last_reg:=valor and $3f;
  exit;
end;
if ((puerto=$ff3b) and ulaplus.enabled) then begin
  fillchar(buffer_video[0],6144,1);
  fillchar(borde.buffer[0],78000,$80);
  case ulaplus.mode of
    0:begin
        ulaplus.paleta[ulaplus.last_reg]:=valor;
        color.b:=$21*(valor and 1)+$47*(valor and 1)+$97*((valor shr 1) and 1);
        color.r:=$21*((valor shr 2) and 1)+$47*((valor shr 3) and 1)+$97*((valor shr 4) and 1);
        color.g:=$21*((valor shr 5) and 1)+$47*((valor shr 6) and 1)+$97*((valor shr 7) and 1);
        set_pal_color(color,@paleta[ulaplus.last_reg+16]);
      end;
    1:ulaplus.activa:=(valor and 1)<>0;
  end;
  exit;
end;
if mouse.tipo=3 then z80pio_cd_ba_w(0,(puerto shr 5) and 3,valor);
end;

end.
