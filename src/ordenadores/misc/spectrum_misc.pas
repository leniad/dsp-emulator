unit spectrum_misc;

interface

uses {$IFDEF WINDOWS}windows,{$ENDIF}
     principal,nz80,z80_sp,spectrum_128k,ay_8910,controls_engine,sysutils,
     forms,lenguaje,spectrum_48k,dialogs,spectrum_3,upd765,cargar_spec,
     gfx_engine,main_engine,graphics,pal_engine,sound_engine,tape_window,
     z80pio,z80daisy,disk_file_format,timer_engine,misc_functions,qsnapshot;

const
        tabla_scr:array[0..191] of word=(
        0,    256, 512, 768,1024,1280,1536,1792,
        32,   288, 544, 800,1056,1312,1568,1824,
        64,   320, 576, 832,1088,1344,1600,1856,
        96,   352, 608, 864,1120,1376,1632,1888,
        128,  384, 640, 896,1152,1408,1664,1920,
        160,  416, 672, 928,1184,1440,1696,1952,
        192,  448, 704, 960,1216,1472,1728,1984,
        224,  480, 736, 992,1248,1504,1760,2016,
        2048,2304,2560,2816,3072,3328,3584,3840,
        2080,2336,2592,2848,3104,3360,3616,3872,
        2112,2368,2624,2880,3136,3392,3648,3904,
        2144,2400,2656,2912,3168,3424,3680,3936,
        2176,2432,2688,2944,3200,3456,3712,3968,
        2208,2464,2720,2976,3232,3488,3744,4000,
        2240,2496,2752,3008,3264,3520,3776,4032,
        2272,2528,2784,3040,3296,3552,3808,4064,
        4096,4352,4608,4864,5120,5376,5632,5888,
        4128,4384,4640,4896,5152,5408,5664,5920,
        4160,4416,4672,4928,5184,5440,5696,5952,
        4192,4448,4704,4960,5216,5472,5728,5984,
        4224,4480,4736,4992,5248,5504,5760,6016,
        4256,4512,4768,5024,5280,5536,5792,6048,
        4288,4544,4800,5056,5312,5568,5824,6080,
        4320,4576,4832,5088,5344,5600,5856,6112);
        spec_paleta:array[0..15] of integer=(
        $000000,$C00000,$0000C0,$C000C0,
        $00C000,$C0C000,$00C0C0,$C0C0C0,
        $000000,$FF0000,$0000FF,$FF00FF,
        $00FF00,$FFFF00,$00FFFF,$FFFFFF);
        gif_paleta:array[0..15] of integer=(
        $000000,$E70000,$0000E7,$E700E7,
        $00E700,$E7E700,$00E7E7,$E7E7E7,
        $000000,$FF0000,$0000FF,$FF00FF,
        $00FF00,$FFFF00,$00FFFF,$FFFFFF);
        cmemory:array[0..127] of byte=(
          6,5,4,3,2,1,0,0,6,5,4,3,2,1,0,0,6,5,4,3,2,1,0,0,6,5,4,3,2,1,0,0,
          6,5,4,3,2,1,0,0,6,5,4,3,2,1,0,0,6,5,4,3,2,1,0,0,6,5,4,3,2,1,0,0,
          6,5,4,3,2,1,0,0,6,5,4,3,2,1,0,0,6,5,4,3,2,1,0,0,6,5,4,3,2,1,0,0,
          6,5,4,3,2,1,0,0,6,5,4,3,2,1,0,0,6,5,4,3,2,1,0,0,6,5,4,3,2,1,0,0);
        JKEMPSTON=1;
        JCURSOR=2;
        JSINCLAIR1=3;
        JSINCLAIR2=4;
        JFULLER=5;
        MNONE=0;
        MGUNSTICK=1;
        MKEMPSTON=2;
        MAMX=3;

type
  tmouse_spectrum=record
    //General
    tipo,botones:byte;
    x,y,x_act,y_act:word;
    //AMX Mouse
    data_a,data_b:byte;
    //Gunstick
    lg_val:byte;
    gs_activa:boolean;
  end;
  tinterface2_spectrum=record
    retraso:dword;
    cargado,hay_if2:boolean;
    rom:array[0..$7fff] of byte;
  end;
  tborde_spectrum=record
    borde_spectrum:procedure(linea:word);
    buffer:array[0..312*250] of byte;
    tipo,color,posicion:byte;
  end;
  tulaplus_spectrum=record
    paleta:array[0..63] of byte;
    last_reg,mode:byte;
    activa,enabled:boolean;
  end;
  tvar_spectrum=record
    //Video
    flash,pantalla_128k,old_7ffd:byte;
    haz_flash:boolean;
    atrib_scr:array[0..191] of word;
    //Keyboard
    key6_0,keyY_P,key1_5,keyQ_T,keyH_ENT,keyCAPS_V,keyA_G,keyB_SPC:byte;
    kb_0,kb_1,kb_2,kb_3,kb_4:boolean;
    adr_8,adr_9,adr_10,adr_11,adr_12,adr_13,adr_14,adr_15:boolean;
    key_spec:array [0..255] of boolean;
    tipo_joy,joy_val:byte;
    //Audio
    valor_beeper:word;
    speaker_oversample,audio_load,turbo_sound:boolean;
    altavoz,audio_128k,ear_channel,speaker_timer,ay_select:byte;
    //Memoria
    retraso:array[0..71000] of byte;
    marco:array[0..3] of byte;
    //Misc
    irq_pos:byte;
    issue2,sd_1,fastload:boolean;
  end;

var
      ulaplus:tulaplus_spectrum;
      var_spectrum:tvar_spectrum;
      interface2:tinterface2_spectrum;
      mouse:tmouse_spectrum;
      borde:tborde_spectrum;

function spectrum_mensaje:string;
procedure borde_normal(linea:word);
procedure eventos_spectrum;
function spec_comun(clock:dword):boolean;
procedure spec_cerrar_comun;
procedure spectrum_tapes;
procedure grabar_spec;
procedure reset_misc;
procedure spectrum_despues_instruccion(estados_t:byte);
procedure evalua_gunstick;
procedure spec_a_pantalla(posicion_memoria:pbyte;imagen1:Tbitmap);
//AMX Mouse
procedure pio_int_main(state:byte);
function pio_read_porta:byte;
function pio_read_portb:byte;

implementation
uses tap_tzx,snapshot,config;

procedure evalua_gunstick;
var
  gs_temp:byte;
begin
if mouse.gs_activa then begin
    mouse.gs_activa:=false;
    var_spectrum.key6_0:=var_spectrum.key6_0 or 4;
    var_spectrum.joy_val:=(var_spectrum.joy_val and $fb);
    mouse.lg_val:=mouse.lg_val and $ef;
end;
case main_vars.tipo_maquina of
  0,5:gs_temp:=memoria[$5800+mouse.y+mouse.x];
  1,4:gs_temp:=memoria_128k[var_spectrum.pantalla_128k,$1800+mouse.y+mouse.x];
  2,3:gs_temp:=memoria_3[var_spectrum.pantalla_128k,$1800+mouse.y+mouse.x];
end;
if ((gs_temp=63) or (gs_temp=127)) then begin
  mouse.gs_activa:=true;
  var_spectrum.key6_0:=var_spectrum.key6_0 and $fb;
  var_spectrum.joy_val:=(var_spectrum.joy_val or 4);
  mouse.lg_val:=mouse.lg_val or $10;
end;
end;

procedure borde_normal(linea:word);
var
  linea_actual:word;
begin
//if ((main_screen.rapido and ((linea and 7)<>0)) or (borde.tipo=0) or (linea<16) or (linea>295)) then exit;
if ((borde.tipo=0) or (linea<16) or (linea>295) or (borde.buffer[linea]=borde.color)) then exit;
borde.buffer[linea]:=borde.color;
linea_actual:=linea-16;
case linea of
        16..63,256..295:begin
                          single_line(0,linea_actual,paleta[borde.color],352,1);
                          actualiza_trozo(0,linea_actual,352,1,1,0,linea_actual,352,1,PANT_TEMP);
                        end;
        64..255:begin
                    single_line(0,linea_actual,paleta[borde.color],48,1);
                    actualiza_trozo(0,linea_actual,48,1,1,0,linea_actual,48,1,PANT_TEMP);
                    single_line(304,linea_actual,paleta[borde.color],48,1);
                    actualiza_trozo(304,linea_actual,48,1,1,304,linea_actual,48,1,PANT_TEMP);
                end;
end;
end;

procedure teclado_matriz;
begin
end;

procedure eventos_spectrum;
begin
if (event.mouse and (mouse.tipo<>MNONE)) then begin
  case mouse.tipo of
    MGUNSTICK:begin  //Gunstick
        if raton.y<48 then mouse.y:=0
          else if raton.y>239 then mouse.y:=$ff
            else mouse.y:=(((raton.y-48) and $f8) shl 2);
        if raton.x<48 then mouse.x:=0
          else if raton.x>303 then mouse.x:=$ff
            else mouse.x:=(raton.x-48) shr 3;
        if raton.button1 then begin
           var_spectrum.key6_0:=(var_spectrum.key6_0 and $fe);
           var_spectrum.joy_val:=(var_spectrum.joy_val or $10);
           mouse.lg_val:=mouse.lg_val and $df;
        end else begin
          var_spectrum.key6_0:=(var_spectrum.key6_0 or 1);
          var_spectrum.joy_val:=(var_spectrum.joy_val and $ef);
          mouse.lg_val:=mouse.lg_val or $20;
        end;
      end;
    MKEMPSTON:begin
        if raton.y<48 then mouse.y:=$ff
          else if raton.y>239 then mouse.y:=0
            else mouse.y:=255-trunc((raton.y-48)*1.333);
        if raton.x<48 then mouse.x:=0
          else if raton.x>303 then mouse.x:=$ff
            else mouse.x:=raton.x-48;
        if raton.button2 then mouse.botones:=mouse.botones and $fe
          else mouse.botones:=mouse.botones or 1;
        if raton.button1 then mouse.botones:=mouse.botones and $fd
          else mouse.botones:=mouse.botones or 2;
      end;
    MAMX:begin
        if (raton.y<48) then mouse.y:=0
          else if (raton.y>239) then mouse.y:=$e1
            else mouse.y:=trunc((raton.y-48)*1.17647);
        if raton.x<48 then mouse.x:=0
          else if raton.x>303 then mouse.x:=$12b
            else mouse.x:=trunc((raton.x-48)*1.17647);
        if raton.button1 then mouse.botones:=mouse.botones and $7f
          else mouse.botones:=mouse.botones or $80;
        if raton.button2 then mouse.botones:=mouse.botones and $df // $bf
          else mouse.botones:=mouse.botones or $20;
        if mouse.x<>mouse.x_act then begin
          pio_0.astb_w(false);
          pio_0.astb_w(true);
        end;
        if mouse.y<>mouse.y_act then begin
          pio_0.bstb_w(false);
          pio_0.bstb_w(true);
        end;
    end;
  end;
end;
if event.keyboard then begin
  if ((keyboard[KEYBOARD_F1]) and cinta_tzx.cargada) then begin
    if cinta_tzx.play_tape then tape_window1.fStopCinta(nil)
      else tape_window1.fPlayCinta(nil);
  end;
  if ((keyboard[KEYBOARD_F5]) and (main_vars.tipo_maquina=2)) then begin
    clear_disk(0);
    change_caption('');
  end;
  if false then teclado_matriz
    else copymemory(@var_spectrum.key_spec[0],@keyboard[0],256);
  if var_spectrum.key_spec[KEYBOARD_1] then var_spectrum.key1_5:=(var_spectrum.key1_5 and $fe) else var_spectrum.key1_5:=(var_spectrum.key1_5 or 1);
  if var_spectrum.key_spec[KEYBOARD_2] then var_spectrum.key1_5:=(var_spectrum.key1_5 and $fd) else var_spectrum.key1_5:=(var_spectrum.key1_5 or 2);
  if var_spectrum.key_spec[KEYBOARD_3] then var_spectrum.key1_5:=var_spectrum.key1_5 and $fb else var_spectrum.key1_5:=var_spectrum.key1_5 or 4;
  if var_spectrum.key_spec[KEYBOARD_4] then var_spectrum.key1_5:=var_spectrum.key1_5 and $f7 else var_spectrum.key1_5:=var_spectrum.key1_5 or 8;
  if var_spectrum.key_spec[KEYBOARD_5] then var_spectrum.key1_5:=var_spectrum.key1_5 and $ef else var_spectrum.key1_5:=var_spectrum.key1_5 or $10;
  if var_spectrum.key_spec[KEYBOARD_0] then var_spectrum.key6_0:=var_spectrum.key6_0 and $fe else var_spectrum.key6_0:=var_spectrum.key6_0 or 1;
  if var_spectrum.key_spec[KEYBOARD_9] then var_spectrum.key6_0:=var_spectrum.key6_0 and $fd else var_spectrum.key6_0:=var_spectrum.key6_0 or 2;
  if var_spectrum.key_spec[KEYBOARD_8] then var_spectrum.key6_0:=var_spectrum.key6_0 and $fb else var_spectrum.key6_0:=var_spectrum.key6_0 or 4;
  if var_spectrum.key_spec[KEYBOARD_7] then var_spectrum.key6_0:=var_spectrum.key6_0 and $f7 else var_spectrum.key6_0:=var_spectrum.key6_0 or 8;
  if var_spectrum.key_spec[KEYBOARD_6] then var_spectrum.key6_0:=var_spectrum.key6_0 and $ef else var_spectrum.key6_0:=var_spectrum.key6_0 or $10;
  if var_spectrum.key_spec[KEYBOARD_Q] then var_spectrum.keyQ_T:=var_spectrum.keyQ_T and $fe else var_spectrum.keyQ_T:=var_spectrum.keyQ_T or 1;
  if var_spectrum.key_spec[KEYBOARD_W] then var_spectrum.keyQ_T:=var_spectrum.keyQ_T and $fd else var_spectrum.keyQ_T:=var_spectrum.keyQ_T or 2;
  if var_spectrum.key_spec[KEYBOARD_E] then var_spectrum.keyQ_T:=var_spectrum.keyQ_T and $fb else var_spectrum.keyQ_T:=var_spectrum.keyQ_T or 4;
  if var_spectrum.key_spec[KEYBOARD_R] then var_spectrum.keyQ_T:=var_spectrum.keyQ_T and $f7 else var_spectrum.keyQ_T:=var_spectrum.keyQ_T or 8;
  if var_spectrum.key_spec[KEYBOARD_T] then var_spectrum.keyQ_T:=var_spectrum.keyQ_T and $ef else var_spectrum.keyQ_T:=var_spectrum.keyQ_T or $10;
  if var_spectrum.key_spec[KEYBOARD_P] then var_spectrum.keyY_P:=var_spectrum.keyY_P and $fe else var_spectrum.keyY_P:=var_spectrum.keyY_P or 1;
  if var_spectrum.key_spec[KEYBOARD_O] then var_spectrum.keyY_P:=var_spectrum.keyY_P and $fd else var_spectrum.keyY_P:=var_spectrum.keyY_P or 2;
  if var_spectrum.key_spec[KEYBOARD_I] then var_spectrum.keyY_P:=var_spectrum.keyY_P and $fb else var_spectrum.keyY_P:=var_spectrum.keyY_P or 4;
  if var_spectrum.key_spec[KEYBOARD_U] then var_spectrum.keyY_P:=var_spectrum.keyY_P and $f7 else var_spectrum.keyY_P:=var_spectrum.keyY_P or 8;
  if var_spectrum.key_spec[KEYBOARD_Y] then var_spectrum.keyY_P:=var_spectrum.keyY_P and $ef else var_spectrum.keyY_P:=var_spectrum.keyY_P or $10;
  if var_spectrum.key_spec[KEYBOARD_RETURN] then var_spectrum.keyH_ENT:=var_spectrum.keyH_ENT and $fe else var_spectrum.keyH_ENT:=var_spectrum.keyH_ENT or 1;
  if var_spectrum.key_spec[KEYBOARD_L] then var_spectrum.keyH_ENT:=var_spectrum.keyH_ENT and $fd else var_spectrum.keyH_ENT:=var_spectrum.keyH_ENT or 2;
  if var_spectrum.key_spec[KEYBOARD_K] then var_spectrum.keyH_ENT:=var_spectrum.keyH_ENT and $fb else var_spectrum.keyH_ENT:=var_spectrum.keyH_ENT or 4;
  if var_spectrum.key_spec[KEYBOARD_J] then var_spectrum.keyH_ENT:=var_spectrum.keyH_ENT and $f7 else var_spectrum.keyH_ENT:=var_spectrum.keyH_ENT or 8;
  if var_spectrum.key_spec[KEYBOARD_H] then var_spectrum.keyH_ENT:=var_spectrum.keyH_ENT and $ef else var_spectrum.keyH_ENT:=var_spectrum.keyH_ENT or $10;
  if var_spectrum.key_spec[KEYBOARD_A] then var_spectrum.keyA_G:=var_spectrum.keyA_G and $fe else var_spectrum.keyA_G:=var_spectrum.keyA_G or 1;
  if var_spectrum.key_spec[KEYBOARD_S] then var_spectrum.keyA_G:=var_spectrum.keyA_G and $fd else var_spectrum.keyA_G:=var_spectrum.keyA_G or 2;
  if var_spectrum.key_spec[KEYBOARD_D] then var_spectrum.keyA_G:=var_spectrum.keyA_G and $fb else var_spectrum.keyA_G:=var_spectrum.keyA_G or 4;
  if var_spectrum.key_spec[KEYBOARD_F] then var_spectrum.keyA_G:=var_spectrum.keyA_G and $f7 else var_spectrum.keyA_G:=var_spectrum.keyA_G or 8;
  if var_spectrum.key_spec[KEYBOARD_G] then var_spectrum.keyA_G:=var_spectrum.keyA_G and $ef else var_spectrum.keyA_G:=var_spectrum.keyA_G or $10;
  if (var_spectrum.key_spec[KEYBOARD_LCTRL] or var_spectrum.key_spec[KEYBOARD_RCTRL]) then var_spectrum.keyCAPS_V:=(var_spectrum.keyCAPS_V and $fe) else var_spectrum.keyCAPS_V:=(var_spectrum.keyCAPS_V or 1);
  if var_spectrum.key_spec[KEYBOARD_Z] then var_spectrum.keyCAPS_V:=var_spectrum.keyCAPS_V and $fd else var_spectrum.keyCAPS_V:=var_spectrum.keyCAPS_V or 2;
  if var_spectrum.key_spec[KEYBOARD_X] then var_spectrum.keyCAPS_V:=var_spectrum.keyCAPS_V and $fb else var_spectrum.keyCAPS_V:=var_spectrum.keyCAPS_V or 4;
  if var_spectrum.key_spec[KEYBOARD_C] then var_spectrum.keyCAPS_V:=var_spectrum.keyCAPS_V and $f7 else var_spectrum.keyCAPS_V:=var_spectrum.keyCAPS_V or 8;
  if var_spectrum.key_spec[KEYBOARD_V] then var_spectrum.keyCAPS_V:=var_spectrum.keyCAPS_V and $ef else var_spectrum.keyCAPS_V:=var_spectrum.keyCAPS_V or $10;
  if var_spectrum.key_spec[KEYBOARD_SPACE] then var_spectrum.keyB_SPC:=var_spectrum.keyB_SPC and $fe else var_spectrum.keyB_SPC:=var_spectrum.keyB_SPC or 1;
  if (var_spectrum.key_spec[KEYBOARD_LSHIFT] or var_spectrum.key_spec[KEYBOARD_RSHIFT]) then var_spectrum.keyB_SPC:=var_spectrum.keyB_SPC and $fd else var_spectrum.keyB_SPC:=var_spectrum.keyB_SPC or 2;
  if var_spectrum.key_spec[KEYBOARD_M] then var_spectrum.keyB_SPC:=var_spectrum.keyB_SPC and $fb else var_spectrum.keyB_SPC:=var_spectrum.keyB_SPC or 4;
  if var_spectrum.key_spec[KEYBOARD_N] then var_spectrum.keyB_SPC:=var_spectrum.keyB_SPC and $f7 else var_spectrum.keyB_SPC:=var_spectrum.keyB_SPC or 8;
  if var_spectrum.key_spec[KEYBOARD_B] then var_spectrum.keyB_SPC:=var_spectrum.keyB_SPC and $ef else var_spectrum.keyB_SPC:=var_spectrum.keyB_SPC or $10;
  //Teclas del Spectrum +  y siguientes
  if var_spectrum.key_spec[KEYBOARD_FILA2_T2] then begin //CAPS+1 Edit
    var_spectrum.key1_5:=(var_spectrum.key1_5 and $fe);
    var_spectrum.keyCAPS_V:=var_spectrum.keyCAPS_V and $fe;
  end;
  if var_spectrum.key_spec[KEYBOARD_capslock] then begin //CAPS+2
    var_spectrum.key1_5:=var_spectrum.key1_5 and $fd;
    var_spectrum.keyCAPS_V:=var_spectrum.keyCAPS_V and $fe;
  end;
  if var_spectrum.key_spec[KEYBOARD_FILA0_T1] then begin //CAPS+3 True Video
    var_spectrum.key1_5:=var_spectrum.key1_5 and $fb;
    var_spectrum.keyCAPS_V:=var_spectrum.keyCAPS_V and $fe;
  end;
  if var_spectrum.key_spec[KEYBOARD_FILA0_T2] then begin //CAPS+4 Inv Video
    var_spectrum.key1_5:=var_spectrum.key1_5 and $f7;
    var_spectrum.keyCAPS_V:=var_spectrum.keyCAPS_V and $fe;
  end;
  if var_spectrum.key_spec[KEYBOARD_FILA0_T0] then begin //CAPS+9 Graphics
    var_spectrum.key6_0:=var_spectrum.key6_0 and $fd;
    var_spectrum.keyCAPS_V:=var_spectrum.keyCAPS_V and $fe;
  end;
  if var_spectrum.key_spec[KEYBOARD_BACKSPACE] then begin //CAPS+0
    var_spectrum.key6_0:=var_spectrum.key6_0 and $fe;
    var_spectrum.keyCAPS_V:=var_spectrum.keyCAPS_V and $fe;
  end;
  if var_spectrum.key_spec[KEYBOARD_escape] then begin //CAPS+SPACE Break
    var_spectrum.keyB_SPC:=var_spectrum.keyB_SPC and $fe;
    var_spectrum.keyCAPS_V:=var_spectrum.keyCAPS_V and $fe;
  end;
  if var_spectrum.key_spec[KEYBOARD_tab] then begin //CAPS+SHIFT Extended Mode
    var_spectrum.keyB_SPC:=var_spectrum.keyB_SPC and $fd;
    var_spectrum.keyCAPS_V:=var_spectrum.keyCAPS_V and $fe;
  end;
  if var_spectrum.key_spec[KEYBOARD_FILA3_T0] then begin // "
    var_spectrum.keyB_SPC:=var_spectrum.keyB_SPC and $fd;
    var_spectrum.keyY_P:=var_spectrum.keyY_P and $fe;
  end;
  if var_spectrum.key_spec[KEYBOARD_FILA3_T3] then begin // ;
    var_spectrum.keyB_SPC:=var_spectrum.keyB_SPC and $fd;
    var_spectrum.keyY_P:=var_spectrum.keyY_P and $fd;
  end;
  if var_spectrum.key_spec[KEYBOARD_FILA3_T2] then begin // .
    var_spectrum.keyB_SPC:=var_spectrum.keyB_SPC and $fd;
    var_spectrum.keyB_SPC:=var_spectrum.keyB_SPC and $fb;
  end;
  if var_spectrum.key_spec[KEYBOARD_FILA3_T1] then begin // ,
    var_spectrum.keyB_SPC:=var_spectrum.keyB_SPC and $fd;
    var_spectrum.keyB_SPC:=var_spectrum.keyB_SPC and $f7;
  end;
end;
if event.arcade then begin
  if mouse.tipo=MAMX then begin
    if arcade_input.but0[0] then mouse.botones:=mouse.botones and $bf
          else mouse.botones:=mouse.botones or $40;
  end;
  case var_spectrum.tipo_joy of
    JKEMPSTON:begin
                if arcade_input.up[0] then var_spectrum.joy_val:=(var_spectrum.joy_val or 8) else var_spectrum.joy_val:=(var_spectrum.joy_val and $f7);
                if arcade_input.down[0] then var_spectrum.joy_val:=(var_spectrum.joy_val or 4) else var_spectrum.joy_val:=(var_spectrum.joy_val and $fb);
                if arcade_input.left[0] then var_spectrum.joy_val:=(var_spectrum.joy_val or 2) else var_spectrum.joy_val:=(var_spectrum.joy_val and $fd);
                if arcade_input.right[0] then var_spectrum.joy_val:=(var_spectrum.joy_val or 1) else var_spectrum.joy_val:=(var_spectrum.joy_val and $fe);
                if arcade_input.but0[0] then var_spectrum.joy_val:=(var_spectrum.joy_val or $10) else var_spectrum.joy_val:=(var_spectrum.joy_val and $ef);
              end;
    JFULLER:begin
                if arcade_input.but0[0] then var_spectrum.joy_val:=(var_spectrum.joy_val and $7f) else var_spectrum.joy_val:=(var_spectrum.joy_val or $80);
                if arcade_input.down[0] then var_spectrum.joy_val:=(var_spectrum.joy_val and $fd) else var_spectrum.joy_val:=(var_spectrum.joy_val or 2);
                if arcade_input.left[0] then var_spectrum.joy_val:=(var_spectrum.joy_val and $fb) else var_spectrum.joy_val:=(var_spectrum.joy_val or 4);
                if arcade_input.right[0] then var_spectrum.joy_val:=(var_spectrum.joy_val and $f7) else var_spectrum.joy_val:=(var_spectrum.joy_val or 8);
                if arcade_input.up[0] then var_spectrum.joy_val:=(var_spectrum.joy_val and $fe) else var_spectrum.joy_val:=(var_spectrum.joy_val or 1);
              end;
    JCURSOR:begin
                 if arcade_input.but0[0] then var_spectrum.key6_0:=(var_spectrum.key6_0 and $fe) else var_spectrum.key6_0:=(var_spectrum.key6_0 or 1);
                 if arcade_input.left[0] then begin //CAPS+5
                    var_spectrum.key1_5:=var_spectrum.key1_5 and $ef;
                    var_spectrum.keyCAPS_V:=var_spectrum.keyCAPS_V and $fe;
                 end;
                 if arcade_input.down[0] then begin //CAPS+6
                    var_spectrum.key6_0:=var_spectrum.key6_0 and $ef;
                    var_spectrum.keyCAPS_V:=var_spectrum.keyCAPS_V and $fe;
                 end;
                 if arcade_input.up[0] then begin //CAPS+7
                    var_spectrum.key6_0:=var_spectrum.key6_0 and $f7;
                    var_spectrum.keyCAPS_V:=var_spectrum.keyCAPS_V and $fe;
                 end;
                 if arcade_input.right[0] then begin //CAPS+8
                    var_spectrum.key6_0:=var_spectrum.key6_0 and $fb;
                    var_spectrum.keyCAPS_V:=var_spectrum.keyCAPS_V and $fe;
                 end;
            end;
    JSINCLAIR1:begin
                 if arcade_input.but0[0] then var_spectrum.key6_0:=var_spectrum.key6_0 and $fe else var_spectrum.key6_0:=var_spectrum.key6_0 or 1;
                 if arcade_input.up[0] then var_spectrum.key6_0:=var_spectrum.key6_0 and $fd else var_spectrum.key6_0:=var_spectrum.key6_0 or 2;
                 if arcade_input.down[0] then var_spectrum.key6_0:=var_spectrum.key6_0 and $fb else var_spectrum.key6_0:=var_spectrum.key6_0 or 4;
                 if arcade_input.right[0] then var_spectrum.key6_0:=var_spectrum.key6_0 and $f7 else var_spectrum.key6_0:=var_spectrum.key6_0 or 8;
                 if arcade_input.left[0] then var_spectrum.key6_0:=var_spectrum.key6_0 and $ef else var_spectrum.key6_0:=var_spectrum.key6_0 or $10;
               end;
    JSINCLAIR2:begin
                 if arcade_input.left[0] then var_spectrum.key1_5:=(var_spectrum.key1_5 and $fe) else var_spectrum.key1_5:=(var_spectrum.key1_5 or 1);
                 if arcade_input.right[0] then var_spectrum.key1_5:=(var_spectrum.key1_5 and $fd) else var_spectrum.key1_5:=(var_spectrum.key1_5 or 2);
                 if arcade_input.down[0] then var_spectrum.key1_5:=var_spectrum.key1_5 and $fb else var_spectrum.key1_5:=var_spectrum.key1_5 or 4;
                 if arcade_input.up[0] then var_spectrum.key1_5:=var_spectrum.key1_5 and $f7 else var_spectrum.key1_5:=var_spectrum.key1_5 or 8;
                 if arcade_input.but0[0] then var_spectrum.key1_5:=var_spectrum.key1_5 and $ef else var_spectrum.key1_5:=var_spectrum.key1_5 or $10;
               end;
  end;
end;
end;

//Audio!!
procedure spectrum_beeper_sound;
var
  res:smallint;
begin
  res:=(var_spectrum.valor_beeper+(cinta_tzx.value*byte(var_spectrum.audio_load)*byte(cinta_tzx.play_tape))) shl (4+(3*byte(not(var_spectrum.speaker_oversample))));
  tsample[var_spectrum.ear_channel,sound_status.posicion_sonido]:=res;
  //Copio el contenido del speaker para emular el stereo
  if sound_status.stereo then tsample[var_spectrum.ear_channel,sound_status.posicion_sonido+1]:=res;
  var_spectrum.valor_beeper:=0;
end;

procedure beeper_get;
begin
  var_spectrum.valor_beeper:=var_spectrum.valor_beeper+var_spectrum.altavoz;
end;

procedure spectrum_ay8912_sound;
var
  audio:pinteger;
  audio_buff:array[0..3] of integer;
begin
audio:=ay8910_0.update_internal;
copymemory(@audio_buff[0],pbyte(audio),4*sizeof(integer));
case var_spectrum.audio_128k of
  0:tsample[ay8910_0.get_sample_num,sound_status.posicion_sonido]:=audio_buff[0];
  1:begin
        tsample[ay8910_0.get_sample_num,sound_status.posicion_sonido]:=audio_buff[1]*2+audio_buff[2];
        tsample[ay8910_0.get_sample_num,sound_status.posicion_sonido+1]:=audio_buff[3]*2+audio_buff[2];
      end;
  2:begin
        tsample[ay8910_0.get_sample_num,sound_status.posicion_sonido]:=audio_buff[1]*2+audio_buff[3];
        tsample[ay8910_0.get_sample_num,sound_status.posicion_sonido+1]:=audio_buff[2]*2+audio_buff[3];
      end;
  end;
if var_spectrum.turbo_sound then begin
  audio:=ay8910_1.update_internal;
  copymemory(@audio_buff[0],pbyte(audio),4*sizeof(integer));
  case var_spectrum.audio_128k of
    0:tsample[ay8910_1.get_sample_num,sound_status.posicion_sonido]:=audio_buff[0];
    1:begin
          tsample[ay8910_1.get_sample_num,sound_status.posicion_sonido]:=audio_buff[1]*2+audio_buff[2];
          tsample[ay8910_1.get_sample_num,sound_status.posicion_sonido+1]:=audio_buff[3]*2+audio_buff[2];
        end;
    2:begin
          tsample[ay8910_1.get_sample_num,sound_status.posicion_sonido]:=audio_buff[1]*2+audio_buff[3];
          tsample[ay8910_1.get_sample_num,sound_status.posicion_sonido+1]:=audio_buff[2]*2+audio_buff[3];
        end;
    end;
  end;
end;

//Quick save/load
procedure spec_qload(nombre:string);
var
  data:pbyte;
  buffer:array[0..11] of byte;
  f:byte;
begin
if not(open_qsnapshot_load('spec'+inttostr(main_vars.tipo_maquina)+nombre)) then exit;
getmem(data,200);
//MISC
loaddata_qsnapshot(@buffer);
linea_48:=buffer[0] or (buffer[1] shl 8);
rom_cambiada_48:=buffer[2]<>0;
spec_16k:=buffer[3]<>0;
linea_128:=buffer[4] or (buffer[5] shl 8);
paginacion_activa:=buffer[6]<>0;
linea_3:=buffer[7] or (buffer[8] shl 8);
old_1ffd:=buffer[9];
paginacion_especial:=buffer[10]<>0;
disk_present:=buffer[11]<>0;
//CPU
loaddata_qsnapshot(data);
spec_z80.load_snapshot(data);
//SND+MEM
case main_vars.tipo_maquina of
  0,5:loaddata_qsnapshot(@memoria[0]);
  1,2,3,4:begin
            loaddata_qsnapshot(data);
            ay8910_0.load_snapshot(data);
            loaddata_qsnapshot(data);
            ay8910_1.load_snapshot(data);
            if main_vars.tipo_maquina=1 then for f:=0 to 9 do loaddata_qsnapshot(@memoria_128k[f,0])
              else for f:=0 to 11 do loaddata_qsnapshot(@memoria_3[f,0]);
          end;
end;
//Vars
loaddata_qsnapshot(@ulaplus);
loaddata_qsnapshot(@var_spectrum);
loaddata_qsnapshot(@interface2);
loaddata_qsnapshot(@mouse);
loaddata_qsnapshot(@borde);
borde.borde_spectrum:=borde_normal;
close_qsnapshot;
end;

procedure spec_qsave(nombre:string);
var
  data:pbyte;
  size:dword;
  buffer:array[0..11] of byte;
  f:byte;
begin
open_qsnapshot_save('spec'+inttostr(main_vars.tipo_maquina)+nombre);
getmem(data,200);
//MISC
buffer[0]:=linea_48 and $ff;
buffer[1]:=linea_48 shr 8;
buffer[2]:=byte(rom_cambiada_48);
buffer[3]:=byte(spec_16k);
buffer[4]:=linea_128 and $ff;
buffer[5]:=linea_128 shr 8;
buffer[6]:=byte(paginacion_activa);
buffer[7]:=linea_3 and $ff;
buffer[8]:=linea_3 shr 8;
buffer[9]:=old_1ffd;
buffer[10]:=byte(paginacion_especial);
buffer[11]:=byte(disk_present);
savedata_qsnapshot(@buffer,12);
//CPU
size:=spec_z80.save_snapshot(data);
savedata_qsnapshot(data,size);
//SND+MEM
case main_vars.tipo_maquina of
  0,5:savedata_qsnapshot(@memoria[0],$10000);
  1,2,3,4:begin
            size:=ay8910_0.save_snapshot(data);
            savedata_qsnapshot(data,size);
            size:=ay8910_1.save_snapshot(data);
            savedata_qsnapshot(data,size);
            if main_vars.tipo_maquina=1 then for f:=0 to 9 do savedata_qsnapshot(@memoria_128k[f,0],$4000)
              else for f:=0 to 11 do savedata_qsnapshot(@memoria_3[f,0],$4000);
          end;
end;
//Vars
size:=sizeof(tulaplus_spectrum);
savedata_qsnapshot(@ulaplus,size);
size:=sizeof(tvar_spectrum);
savedata_qsnapshot(@var_spectrum,size);
size:=sizeof(tinterface2_spectrum);
savedata_qsnapshot(@interface2,size);
size:=sizeof(tmouse_spectrum);
savedata_qsnapshot(@mouse,size);
size:=sizeof(tborde_spectrum);
savedata_qsnapshot(@borde,size);
freemem(data);
close_qsnapshot;
end;

function spec_comun(clock:dword):boolean;
var
  colores:tpaleta;
  f:byte;
begin
spec_comun:=false;
llamadas_maquina.cintas:=spectrum_tapes;
llamadas_maquina.close:=spec_cerrar_comun;
llamadas_maquina.grabar_snapshot:=grabar_spec;
llamadas_maquina.save_qsnap:=spec_qsave;
llamadas_maquina.load_qsnap:=spec_qload;
spec_z80:=cpu_z80_sp.create(clock);
if borde.tipo=2 then begin
  case main_vars.tipo_maquina of
    0,5:borde.borde_spectrum:=borde_48_full;
    1,2,3,4:borde.borde_spectrum:=borde_128_full;
  end;
end else borde.borde_spectrum:=borde_normal;
//Beeper audio (comun para todos)
spec_z80.init_sound(spectrum_beeper_sound);
var_spectrum.speaker_timer:=timers.init(spec_z80.numero_cpu,spec_z80.clock/(FREQ_BASE_AUDIO*(1+(7*byte(var_spectrum.speaker_oversample)))),beeper_get,nil,true);
//AY8912
if main_vars.tipo_maquina<>0 then timers.init(spec_z80.numero_cpu,clock/FREQ_BASE_AUDIO,spectrum_ay8912_sound,nil,true);
principal1.BitBtn10.Glyph:=nil;
principal1.BitBtn12.Enabled:=false;
principal1.ImageList2.GetBitmap(3,principal1.BitBtn10.Glyph);
if not(cinta_tzx.cargada) then begin
  principal1.BitBtn14.Glyph:=nil;
  principal1.BitBtn14.Enabled:=false;
  principal1.imagelist2.GetBitmap(1,principal1.BitBtn14.Glyph);
  //Fastload disabled
  var_spectrum.fastload:=false;
end;
//Tape Stop
cinta_tzx.play_tape:=false;
tape_window1.BitBtn1.Enabled:=true;
tape_window1.BitBtn2.Enabled:=false;
screen_init(1,352,280,false,true);
iniciar_video(352,280);
//Direccion atributos
for f:=0 to 191 do var_spectrum.atrib_scr[f]:=6144+(32*(f div 8));
//Paleta general
for f:=0 to 15 do begin
  colores[f].b:=spec_paleta[f] shr 16;
  colores[f].g:=(spec_paleta[f] shr 8) and $ff;
  colores[f].r:=spec_paleta[f] and $ff;
end;
//los colores iniciales de la ULA+
for f:=16 to 79 do begin
  colores[f].b:=0;
  colores[f].g:=0;
  colores[f].r:=0;
end;
set_pal(colores,80);
var_spectrum.haz_flash:=false;
if mouse.tipo<>MNONE then show_mouse_cursor
  else hide_mouse_cursor;
//iniciar un canal para el ear (el otro lo inicia el AY si hace falta)
var_spectrum.ear_channel:=init_channel;
spec_comun:=true;
if cinta_tzx.cargada then tape_window1.show;
end;

procedure reset_misc;
begin
spec_z80.reset;
spec_z80.contador:=0;
var_spectrum.valor_beeper:=0;
if cinta_tzx.cargada then begin
  cinta_tzx.play_once:=false;
  change_caption(cinta_tzx.name);
end else if dsk[0].abierto then change_caption(dsk[0].ImageName)
          else change_caption('');
mouse.lg_val:=$20;
var_spectrum.flash:=0;
var_spectrum.irq_pos:=0;
var_spectrum.altavoz:=0;
var_spectrum.ay_select:=0;
cinta_tzx.value:=0;
//ULA+
ulaplus.activa:=false;
fillchar(ulaplus.paleta[0],64,0);
ulaplus.last_reg:=0;
var_spectrum.key6_0:=$ff;
var_spectrum.key1_5:=$ff;
var_spectrum.keyY_P:=$ff;
var_spectrum.keyQ_T:=$ff;
var_spectrum.keyH_ENT:=$ff;
var_spectrum.keyCAPS_V:=$ff;
var_spectrum.keyA_G:=$ff;
var_spectrum.keyB_SPC:=$ff;
var_spectrum.kb_0:=false;
var_spectrum.kb_1:=false;
var_spectrum.kb_2:=false;
var_spectrum.kb_3:=false;
var_spectrum.kb_4:=false;
var_spectrum.adr_8:=false;
var_spectrum.adr_9:=false;
var_spectrum.adr_10:=false;
var_spectrum.adr_11:=false;
var_spectrum.adr_12:=false;
var_spectrum.adr_13:=false;
var_spectrum.adr_14:=false;
var_spectrum.adr_15:=false;
if mouse.tipo=MAMX then begin
  pio_0:=tz80pio.create;
  pio_0.change_calls(pio_int_main,pio_read_porta,nil,nil,pio_read_portb);
  z80daisy_init(Z80_PIO0_TYPE);
  pio_0.reset;
  spec_z80.enable_daisy;
end;
mouse.x:=0;
mouse.y:=0;
mouse.x_act:=0;
mouse.y_act:=0;
mouse.botones:=$ff;
mouse.data_a:=0;
mouse.data_b:=0;
if interface2.hay_if2 then begin
  interface2.cargado:=false;
  interface2.retraso:=0;
  copymemory(@memoria[0],@interface2.rom[0],$4000);
end;
fillchar(borde.buffer,78000,$80);
end;

procedure spec_cerrar_comun;
begin
rom_cambiada_48:=false;
if main_vars.tipo_maquina=2 then begin
  ResetFDC;
  clear_disk(0);
end;
end;

procedure spectrum_tapes;
begin
load_spec.showmodal;
end;

procedure grabar_spec;
var
  nombre:string;
  correcto:boolean;
  indice:byte;
begin
if saverom(nombre,indice,SSPECTRUM) then begin
        case indice of
          1:nombre:=changefileext(nombre,'.szx');
          2:nombre:=changefileext(nombre,'.z80');
          3:nombre:=changefileext(nombre,'.dsp');
          4:nombre:=changefileext(nombre,'.sna');
        end;
        if FileExists(nombre) then begin
            if MessageDlg(leng.mensajes[3], mtWarning, [mbYes]+[mbNo],0)=7 then exit;
        end;
        case indice of
          1:correcto:=grabar_szx(nombre);
          2:correcto:=grabar_z80(nombre,false);
          3:correcto:=grabar_z80(nombre,true);
          4:correcto:=grabar_sna(nombre);
        end;
        if not(correcto) then MessageDlg('No se ha podido guardar el snapshot!',mtError,[mbOk],0)
          else Directory.spectrum_tap_snap:=ExtractFilePath(nombre);
end;
end;

procedure spectrum_despues_instruccion(estados_t:byte);
begin
//Longitud de la IRQ probado con el Soldier of Fortune
var_spectrum.irq_pos:=var_spectrum.irq_pos+estados_t;
if ((var_spectrum.irq_pos>31) and (spec_z80.get_irq<>CLEAR_LINE)) then spec_z80.change_irq(CLEAR_LINE);
if cinta_tzx.cargada then begin
    if cinta_tzx.play_tape then begin
      if (var_spectrum.fastload and (cinta_tzx.datos_tzx[cinta_tzx.indice_cinta].tipo_bloque=$10) and not(cinta_tzx.en_pausa)) then begin
        if (spec_z80.get_safe_pc=$056b) then play_cinta_tap(spec_z80.get_internal_r);
      end else begin
        play_cinta_tzx(estados_t);
      end;
    end else begin
      if ((spec_z80.get_safe_pc=$0556) and not(cinta_tzx.play_once)) then begin
       cinta_tzx.play_once:=true;
       main_screen.rapido:=true;
       tape_window1.fPlayCinta(nil);
      end;
    end;
end;
//Cargar ROMS 32k Interface II
if interface2.hay_if2 and not(interface2.cargado) then begin
  interface2.retraso:=interface2.retraso+estados_t;
  if interface2.retraso>10500000 then begin
    interface2.cargado:=true;
    copymemory(@memoria[0],@interface2.rom[$4000],$4000);
  end;
end;
end;

function spectrum_mensaje:string;
begin
if cinta_tzx.play_tape then
  spectrum_mensaje:='    '+leng.mensajes[1]+': '+inttostr(datos_totales_tzx);
end;

procedure spec_a_pantalla(posicion_memoria:pbyte;imagen1:tbitmap);
var
  bit,x,y,f,atrib,video_col,color,color2:byte;
  pos_video:word;
  pvideo:pbyte;
begin
imagen1.Height:=192;
imagen1.Width:=256;
x:=0;
for y:=0 to 191 do begin
  pos_video:=(y shr 3) shl 5;
  for f:=0 to 31 do begin
    pvideo:=posicion_memoria;
    inc(pvideo,$1800+pos_video);
    atrib:=pvideo^;
    pvideo:=posicion_memoria;
    inc(pvideo,tabla_scr[y]+f);
    video_col:=pvideo^;
    color2:=(atrib shr 3) and 7;
    color:=atrib and 7;
    if (atrib and 64)<>0 then begin inc(color,8);inc(color2,8);end;
    for bit:=0 to 7 do begin
      if (video_col and $80)<>0 then imagen1.Canvas.Pixels[x,y]:=gif_paleta[color]
        else imagen1.Canvas.Pixels[x,y]:=gif_paleta[color2];
      inc(x);
      video_col:=video_col shl 1;
    end;
    {if (video_col and 128)<>0 then imagen1.Canvas.Pixels[x,y]:=gif_paleta[color] else imagen1.Canvas.Pixels[x,y]:=gif_paleta[color2];inc(x);
    if (video_col and 64)<>0 then imagen1.Canvas.Pixels[x,y]:=gif_paleta[color] else imagen1.Canvas.Pixels[x,y]:=gif_paleta[color2];inc(x);
    if (video_col and 32)<>0 then imagen1.Canvas.Pixels[x,y]:=gif_paleta[color] else imagen1.Canvas.Pixels[x,y]:=gif_paleta[color2];inc(x);
    if (video_col and 16)<>0 then imagen1.Canvas.Pixels[x,y]:=gif_paleta[color] else imagen1.Canvas.Pixels[x,y]:=gif_paleta[color2];inc(x);
    if (video_col and 8)<>0 then imagen1.Canvas.Pixels[x,y]:=gif_paleta[color] else imagen1.Canvas.Pixels[x,y]:=gif_paleta[color2];inc(x);
    if (video_col and 4)<>0 then imagen1.Canvas.Pixels[x,y]:=gif_paleta[color] else imagen1.Canvas.Pixels[x,y]:=gif_paleta[color2];inc(x);
    if (video_col and 2)<>0 then imagen1.Canvas.Pixels[x,y]:=gif_paleta[color] else imagen1.Canvas.Pixels[x,y]:=gif_paleta[color2];inc(x);
    if (video_col and 1)<>0 then imagen1.Canvas.Pixels[x,y]:=gif_paleta[color] else imagen1.Canvas.Pixels[x,y]:=gif_paleta[color2];inc(x);}
    inc(pos_video);
  end;
end;
end;

procedure pio_int_main(state:byte);
begin
if mouse.x<>mouse.x_act then begin
  if mouse.x_act<mouse.x then begin
    mouse.data_a:=0;
    mouse.x_act:=mouse.x_act+1;
  end else begin
    mouse.data_a:=1;
    mouse.x_act:=mouse.x_act-1;
  end;
  pio_0.pio_port[PIO_PORT_A].ip:=true;
end;
if mouse.y<>mouse.y_act then begin
  if mouse.y_act<mouse.y then begin
    mouse.data_b:=1;
    mouse.y_act:=mouse.y_act+1;
  end else begin
    mouse.data_b:=0;
    mouse.y_act:=mouse.y_act-1;
  end;
  pio_0.pio_port[PIO_PORT_B].ip:=true;
end;
end;

function pio_read_porta:byte;
begin
  pio_read_porta:=mouse.data_a;
end;

function pio_read_portb:byte;
begin
  pio_read_portb:=mouse.data_b;
end;

end.
