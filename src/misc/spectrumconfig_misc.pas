unit spectrumconfig_misc;

interface

procedure spectrumconfig_show;
procedure spectrumconfig_button1;

implementation
uses principal,spectrum_misc,main_engine,config,lenslock,lenguaje,spectrum_48k,
     spectrum_128k,controls_engine,timer_engine,sound_engine,z80pio,z80daisy,z80_sp;

procedure spectrumconfig_show;
var
  f:integer;
begin
  f:=(principal1.left+(principal1.width div 2))-(configsp.Width div 2);
  if f<0 then configsp.Left:=0
    else configsp.Left:=f;
  f:=(principal1.top+(principal1.Height div 2))-(configsp.Height div 2);
  if f<0 then configsp.Top:=0
    else configsp.Top:=f;
  if var_spectrum.issue2 then configsp.radiobutton1.Checked:=true else configsp.radiobutton2.Checked:=true;
  //Las otras opciones
  if var_spectrum.tipo_joy=JKEMPSTON then configsp.radiobutton3.checked:=true
    else if var_spectrum.tipo_joy=JCURSOR then configsp.radiobutton4.checked:=true
      else if var_spectrum.tipo_joy=JSINCLAIR1 then configsp.radiobutton5.checked:=true
        else if var_spectrum.tipo_joy=JSINCLAIR2 then configsp.radiobutton6.checked:=true
          else if var_spectrum.tipo_joy=JFULLER then configsp.radiobutton25.checked:=true;
  if ulaplus.enabled then configsp.radiobutton23.Checked:=true
    else configsp.radiobutton24.Checked:=true;
  //emulacion del borde
  case borde.tipo  of
    0:configsp.radiobutton7.Checked:=true;
    1:configsp.radiobutton8.Checked:=true;
    2:configsp.radiobutton9.checked:=true;
  end;
  //Seleccion de raton
  case mouse.tipo of
     0:configsp.radiobutton10.Checked:=true;
     1:configsp.radiobutton11.Checked:=true;
     2:configsp.radiobutton19.Checked:=true;
     3:configsp.radiobutton20.Checked:=true;
  end;
  //Speaker oversample
  if var_spectrum.speaker_oversample then configsp.radiobutton17.Checked:=true
    else configsp.radiobutton18.Checked:=true;
  //Tape audio
  if var_spectrum.audio_load then configsp.radiobutton21.Checked:=true
    else configsp.radiobutton22.Checked:=true;
  //Turbo Sound
  if var_spectrum.turbo_sound then configsp.radiobutton26.Checked:=true
    else configsp.radiobutton27.Checked:=true;
  configsp.edit1.Text:=Directory.spectrum_48;
  configsp.edit2.Text:=Directory.spectrum_128;
  configsp.edit3.Text:=Directory.spectrum_3;
  //Lenslock
  configsp.groupbox7.Enabled:=true;
  configsp.radiobutton12.Enabled:=true;
  configsp.radiobutton13.Enabled:=true;
  if lenslok.activo then configsp.radiobutton12.Checked:=true
    else configsp.radiobutton13.Checked:=true;
  //Audio 128K
  case var_spectrum.audio_128k of
    0:configsp.radiobutton14.Checked:=true;
    1:configsp.radiobutton15.Checked:=true;
    2:configsp.radiobutton16.Checked:=true;
  end;
configsp.Button2.Caption:=leng.mensajes[8];
end;

procedure spectrumconfig_button1;
var
  new_audio:byte;
  necesita_reset:boolean;
begin
necesita_reset:=false;
with ConfigSP do begin
  var_spectrum.issue2:=radiobutton1.Checked;
  if radiobutton3.Checked then var_spectrum.tipo_joy:=JKEMPSTON
    else if radiobutton4.Checked then var_spectrum.tipo_joy:=JCURSOR
      else if radiobutton5.Checked then var_spectrum.tipo_joy:=JSINCLAIR1
        else if radiobutton6.Checked then var_spectrum.tipo_joy:=JSINCLAIR2
          else if radiobutton25.Checked then var_spectrum.tipo_joy:=JFULLER;
  if var_spectrum.tipo_joy=JKEMPSTON then var_spectrum.joy_val:=$e0
    else var_spectrum.joy_val:=$ff;
  if radiobutton7.checked then borde.tipo:=0;
  if RadioButton8.Checked then begin
    borde.tipo:=1;
    borde.borde_spectrum:=borde_normal;
  end;
  if radiobutton9.Checked then begin
    borde.tipo:=2;
    fillchar(borde.buffer,78000,$80);
    case main_vars.tipo_maquina of
      0,5:borde.borde_spectrum:=borde_48_full;
      1,2,3,4:borde.borde_spectrum:=borde_128_full;
    end;
  end;
  var_spectrum.audio_load:=radiobutton21.Checked;
  var_spectrum.turbo_sound:=radiobutton26.checked;
  if not(var_spectrum.turbo_sound) then var_spectrum.ay_select:=0;
  if radiobutton10.Checked then mouse.tipo:=MNONE
    else if radiobutton11.Checked then mouse.tipo:=MGUNSTICK
      else if radiobutton19.Checked then mouse.tipo:=MKEMPSTON
        else if radiobutton20.Checked then mouse.tipo:=MAMX;
  init_mouse(mouse.tipo<>0);
  if mouse.tipo=3 then begin
    pio_0:=tz80pio.create;
    pio_0.change_calls(pio_int_main,pio_read_porta,nil,nil,pio_read_portb,nil,nil);
    z80daisy_init(Z80_PIO0_TYPE);
    pio_0.reset;
    spec_z80.enable_daisy;
  end;
  lenslok.activo:=radiobutton12.Checked;
  if lenslok.activo then lenslock1.Show;
  if RadioButton14.Checked then new_audio:=0;
  if RadioButton15.Checked then new_audio:=1;
  if RadioButton16.Checked then new_audio:=2;
  //Speaker oversample
  var_spectrum.speaker_oversample:=radiobutton17.Checked;
  timers.timer[var_spectrum.speaker_timer].time_final:=sound_status.cpu_clock/(FREQ_BASE_AUDIO*(1+(7*byte(var_spectrum.speaker_oversample))));
  timers.reset(var_spectrum.speaker_timer);
  if new_audio<>var_spectrum.audio_128k then begin
    var_spectrum.audio_128k:=new_audio;
    close_audio;
    case var_spectrum.audio_128k of
      0:iniciar_audio(false);
      1,2:iniciar_audio(true);
    end;
  end;
  if Edit1.text<>Directory.spectrum_48 then begin
    Directory.spectrum_48:=Edit1.text;
    necesita_reset:=true;
  end;
  if Edit2.text<>Directory.spectrum_128 then begin
    Directory.spectrum_128:=Edit2.text;
    necesita_reset:=true;
  end;
  if Edit3.text<>Directory.spectrum_3 then begin
    Directory.spectrum_3:=Edit3.text;
    necesita_reset:=true;
  end;
end;
if necesita_reset then begin
  main_vars.driver_ok:=llamadas_maquina.iniciar;
  if not(main_vars.driver_ok) then principal1.Ejecutar1click(nil);
end;
ulaplus.enabled:=configsp.radiobutton23.checked;
end;

end.
