unit spectrum_48k;
interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,z80_sp,misc_functions,graphics,controls_engine,dialogs,lenguaje,
     sysutils,rom_engine,main_engine,gfx_engine,extctrls,pal_engine,
     sound_engine,z80pio,file_engine;

var
    rom_cambiada_48:boolean=false;

function iniciar_48k:boolean;
procedure spec48_putbyte(direccion:word;valor:byte);
procedure spec48_outbyte(puerto:word;valor:byte);
procedure borde_48_full(linea:word);

implementation

uses tap_tzx,spectrum_misc;

var
    spec_16k:boolean;
    linea:word;

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
  if ((spec_z80_reg.i>=$40) and (spec_z80_reg.i<=$7f)) then video:=memoria[$4000+tabla_scr[linea]+x+spec_z80_reg.r]
    else video:=memoria[$4000+tabla_scr[linea]+x];
  if (var_spectrum.buffer_video[tabla_scr[linea]+x] or (((atrib and $80)<>0) and not(main_screen.rapido))) then begin
    var_spectrum.buffer_video[tabla_scr[linea]+x]:=false;
    poner_linea:=true;
    pant_x:=48+(x shl 3);
    if (ulaplus.activa and ulaplus.enabled) then begin
      temp:=((((atrib and $80) shr 6)+((atrib and $40) shr 6)) shl 4)+16;
      color2:=temp+((atrib shr 3) and 7)+8;
      color:=temp+(atrib and 7);
    end else begin
      color2:=(atrib shr 3) and 7;
      color:=atrib and 7;
      if (atrib and 64)<>0 then begin
        color:=color+8;
        color2:=color2+8;
      end;
      if (((atrib and 128)<>0) and var_spectrum.haz_flash) then begin
        temp:=color;
        color:=color2;
        color2:=temp;
      end;
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
  f:word;
  ptemp:pword;
  posicion:dword;
begin
if (main_screen.rapido and ((linea and 7)<>0) or (borde.tipo=0) or (linea<15) or (linea>296)) then exit;
fillchar(borde.buffer[linea*224+borde.posicion],spec_z80.contador-borde.posicion,borde.color);
borde.posicion:=spec_z80.contador-224;
//El borde izquierdo lo rellena en la linea siguiente!!! Para que la linea 16 o la linea 295 (princio y
//final) tengan borde, tengo que dejar que entre.
if linea=15 then exit;
//24t borde iqz --> 48pixels
ptemp:=punbuf;
posicion:=(linea-1)*224;
for f:=200 to 223 do begin
  ptemp^:=paleta[borde.buffer[posicion+f]];
  inc(ptemp);
  ptemp^:=paleta[borde.buffer[posicion+f]];
  inc(ptemp);
end;
putpixel(0,linea-16,48,punbuf,1);
actualiza_trozo_simple(0,linea-16,48,1,1);
//Como el es borde izquierdo, si estoy en la linea 296 me salgo, ya no hay resto de borde
if linea=296 then exit;
//24t borde der --> 48 pixels
//Pongo los datos donde tocan, el borde izquierdo los coje de la linea anterior
posicion:=linea*224;
ptemp:=punbuf;
for f:=128 to 151 do begin
  ptemp^:=paleta[borde.buffer[posicion+f]];
  inc(ptemp);
  ptemp^:=paleta[borde.buffer[posicion+f]];
  inc(ptemp);
end;
putpixel(304,linea-16,48,punbuf,1);
actualiza_trozo_simple(304,linea-16,48,1,1);
//128t Centro pantalla --> 256 pixels
if ((linea>63) and (linea<256)) then exit;
ptemp:=punbuf;
for f:=0 to 127 do begin
    ptemp^:=paleta[borde.buffer[posicion+f]];
    inc(ptemp);
    ptemp^:=paleta[borde.buffer[posicion+f]];
    inc(ptemp);
end;
putpixel(48,linea-16,256,punbuf,1);
actualiza_trozo_simple(48,linea-16,256,1,1);
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
  if spec_z80.contador<28 then begin
     spec_z80.change_irq(IRQ_DELAY);
     var_spectrum.irq_pos:=spec_z80.contador;
  end;
  var_spectrum.flash:=(var_spectrum.flash+1) and $f;
  if var_spectrum.flash=0 then var_spectrum.haz_flash:=not(var_spectrum.haz_flash);
  if mouse.tipo=MGUNSTICK then evalua_gunstick;
  eventos_spectrum;
  video_sync;
end;
end;

procedure spec48_retraso_memoria(direccion:word);
begin
  if (direccion and $c000)=$4000 then spec_z80.contador:=spec_z80.contador+var_spectrum.retraso[linea*224+spec_z80.contador];
end;

procedure spec48_retraso_puerto(puerto:word);
var
  estados:byte;
  posicion:dword;
begin
posicion:=linea*224+spec_z80.contador;
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
        $4000..$57ff:var_spectrum.buffer_video[direccion and $1fff]:=true;
        $5800..$5aff:begin
                        temp:=((direccion and $3ff) shr 5) shl 3;
                        temp2:=direccion and $1f;
                        for f:=0 to 7 do var_spectrum.buffer_video[tabla_scr[temp+f]+temp2]:=true;
                     end;
end;
end;

function spec48_inbyte(puerto:word):byte;
var
  cont,temp:byte;
  col,lin:word;
begin
temp:=$ff;
if (puerto and 1)=0 then begin //ULA
  if var_spectrum.sd_1 then temp:=$df;
  if (puerto and $8000)=0 then temp:=temp and var_spectrum.keyB_SPC;
  if (puerto and $4000)=0 then temp:=temp and var_spectrum.keyH_ENT;
  if (puerto and $2000)=0 then temp:=temp and var_spectrum.keyY_P;
  if (puerto and $1000)=0 then temp:=temp and var_spectrum.key6_0;
  if (puerto and $800)=0 then temp:=temp and var_spectrum.key1_5;
  if (puerto and $400)=0 then temp:=temp and var_spectrum.keyQ_T;
  if (puerto and $200)=0 then temp:=temp and var_spectrum.keyA_G;
  if (puerto and $100)=0 then temp:=temp and var_spectrum.keyCAPS_V;
  spec48_inbyte:=(temp and $bf) or cinta_tzx.value or var_spectrum.altavoz;
end else begin //Resto
    //Floating bus
    cont:=spec_z80.contador mod 224;
    lin:=linea+(spec_z80.contador div 224);
    if ((lin>63) and (lin<256) and (cont<128)) then begin
      lin:=lin-64;
      col:=$4000+((cont and $f8) shr 2);// div 8)*2);
      case (cont and 7) of
        0,1,2,7:;
        6:temp:=memoria[var_spectrum.atrib_scr[lin]+(col+1)];
        4:temp:=memoria[var_spectrum.atrib_scr[lin]+col];
        5:temp:=memoria[tabla_scr[lin]+(col+1)];
        3:temp:=memoria[tabla_scr[lin]+col];
      end;
    end;
    //kempston
    if (((puerto and $20)=0) and (var_spectrum.tipo_joy=JKEMPSTON) and (mouse.tipo<>MAMX)) then
      temp:=var_spectrum.joy_val;
    //fuller
    if (((puerto and $7f)=$7f) and (var_spectrum.tipo_joy=JFULLER)) then temp:=var_spectrum.joy_val;
    //ula plus
    if ((puerto=$ff3b) and ulaplus.enabled) then begin
        case ulaplus.mode of
          0:temp:=ulaplus.paleta[ulaplus.last_reg];
          1:temp:=byte(ulaplus.activa);
        end;
    end;
    //Mouse --> revisar https://velesoft.speccy.cz/zxporty-cz.htm
    if mouse.tipo<>MNONE then begin
        if mouse.tipo=MAMX then begin //AMX Mouse
            if (puerto and $80)<>0 then temp:=mouse.botones
              else temp:=z80pio_cd_ba_r(0,(puerto shr 5) and $3);
        end;
        if mouse.tipo=MKEMPSTON then begin //Kempston Mouse
          case puerto of
            $fadf:temp:=mouse.botones;
            $fbdf:temp:=mouse.x;
            $ffdf:temp:=mouse.y;
          end;
        end;
    end;
    spec48_inbyte:=temp;
end;
end;

procedure spec48_outbyte(puerto:word;valor:byte);
var
  color:tcolor;
begin
if (puerto and 1)=0 then begin //ULA
  if borde.tipo=2 then begin
      fillchar(borde.buffer[linea*224+borde.posicion],spec_z80.contador-borde.posicion,borde.color);
      borde.posicion:=spec_z80.contador;
    end;
  if (ulaplus.activa and ulaplus.enabled) then borde.color:=(valor and 7)+16
    else borde.color:=valor and 7;
  var_spectrum.altavoz:=(valor and $10) shl 2;
  //Aqui se puede ver la dependencia del puerto $FE del
  //altavoz y del ear (Issue 2 y 3). Lo que entra por el
  //altavoz,el ear o el mic afecta a el bit 6... por
  //ejemplo en 'Ole toro' solo acepta pulsaciones de
  //teclado cuando suena la musica, Abu Simbel no empieza
  //correctamente, Rasputin no suena la musica y no
  //empieza al pulsar 0 --> Gracias Pera Putnik!!
  if not(cinta_tzx.play_tape) then begin
    if (valor and ($10+(8*byte(var_spectrum.issue2))))=0 then cinta_tzx.value:=0
      else cinta_tzx.value:=$40;
    {if var_spectrum.issue2 then begin
      if (valor and $18)=0 then cinta_tzx.value:=0 else cinta_tzx.value:=$40;
    end else begin
      if (valor and $10)=0 then cinta_tzx.value:=0 else cinta_tzx.value:=$40;
    end;}
  end;
end else begin
  if ((puerto=$bf3b) and ulaplus.enabled) then begin
    ulaplus.mode:=valor shr 6;
    if ulaplus.mode=0 then ulaplus.last_reg:=valor and $3f;
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
          fillchar(var_spectrum.buffer_video[0],6144,1);
        end;
      1:ulaplus.activa:=(valor and 1)<>0;
    end;
  end;
  if mouse.tipo=MAMX then z80pio_cd_ba_w(0,(puerto shr 5) and 3,valor);
end;
end;

procedure spec48k_reset;
begin
  reset_misc;
end;

function iniciar_48k:boolean;
var
  rom_cargada:boolean;
  f:dword;
  h:byte;
  pos:integer;
  cadena:string;
begin
if main_vars.tipo_maquina=0 then spec_16k:=false
  else spec_16k:=true;
llamadas_maquina.bucle_general:=spectrum48_main;
llamadas_maquina.cintas:=spectrum_tapes;
llamadas_maquina.reset:=spec48k_reset;
llamadas_maquina.grabar_snapshot:=grabar_spec;
llamadas_maquina.fps_max:=3500000/69888;
llamadas_maquina.close:=spec_cerrar_comun;
llamadas_maquina.configurar:=spectrum_config;
interface2.hay_if2:=false;
iniciar_48k:=false;
//Iniciar el Z80 y pantalla
if not(spec_comun(14000000 div 4)) then exit;
spec_z80.change_retraso_call(spec48_retraso_memoria,spec48_retraso_puerto);
spec_z80.change_ram_calls(spec48_getbyte,spec48_putbyte);
spec_z80.change_io_calls(spec48_inbyte,spec48_outbyte);
//El audio se inicializa en 'spec_comun'
cadena:=file_name_only(changefileext(extractfilename(Directory.spectrum_48),''));
//Aqui utilizo la memoria de la CPU de sonido como buffer...
if extension_fichero(Directory.spectrum_48)='ZIP' then rom_cargada:=carga_rom_zip(Directory.spectrum_48,cadena+'.ROM',@mem_snd[0],$4000,0,false)
  else begin
    read_file(Directory.spectrum_48,@mem_snd,pos);
    rom_cargada:=(pos=$4000);
  end;
//Si ha ido mal me quejo, si ha ido bien copio la ROM a la memoria
if not(rom_cargada) then begin
  MessageDlg(leng[main_vars.idioma].errores[0]+' "'+Directory.spectrum_48+'"', mtError,[mbOk], 0);
  exit;
end else copymemory(@memoria,@mem_snd,$4000);
iniciar_audio(false);
fillchar(var_spectrum.retraso,70000,0);
f:=14335;  //24 del borde
for h:=0 to 191 do begin
  copymemory(@var_spectrum.retraso[f],@cmemory,128);
  inc(f,224);
end;
spec48k_reset;
iniciar_48k:=true;
end;

end.
