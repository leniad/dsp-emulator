unit config;

interface

uses
  lib_sdl2,Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,ComCtrls,lenguaje,spectrum_misc,main_engine,
  sound_engine,z80pio,z80daisy,z80_sp,misc_functions;

type
  TConfigSP = class(TForm)
    GroupBox1: TGroupBox;
    Button1: TButton;
    Button2: TButton;
    GroupBox2: TGroupBox;
    Edit1: TEdit;
    Button3: TButton;
    GroupBox3: TGroupBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    GroupBox5: TGroupBox;
    RadioButton7: TRadioButton;
    RadioButton8: TRadioButton;
    RadioButton9: TRadioButton;
    GroupBox7: TGroupBox;
    RadioButton12: TRadioButton;
    RadioButton13: TRadioButton;
    GroupBox11: TGroupBox;
    GroupBox8: TGroupBox;
    RadioButton14: TRadioButton;
    RadioButton15: TRadioButton;
    RadioButton16: TRadioButton;
    GroupBox10: TGroupBox;
    RadioButton21: TRadioButton;
    RadioButton22: TRadioButton;
    GroupBox9: TGroupBox;
    RadioButton17: TRadioButton;
    RadioButton18: TRadioButton;
    GroupBox12: TGroupBox;
    GroupBox4: TGroupBox;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    RadioButton5: TRadioButton;
    RadioButton6: TRadioButton;
    GroupBox6: TGroupBox;
    RadioButton10: TRadioButton;
    RadioButton11: TRadioButton;
    RadioButton19: TRadioButton;
    RadioButton20: TRadioButton;
    GroupBox13: TGroupBox;
    TrackBar1: TTrackBar;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    GroupBox14: TGroupBox;
    RadioButton23: TRadioButton;
    RadioButton24: TRadioButton;
    RadioButton25: TRadioButton;
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormKeyUp(Sender:TObject;var Key:word;Shift:TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ConfigSP:TConfigSP;

implementation
uses principal,spectrum_48k,spectrum_128k,lenslock;

{$R *.dfm}

procedure TConfigSP.Button2Click(Sender: TObject);
begin
close;
end;

procedure TConfigSP.FormShow(Sender: TObject);
begin
TrackBar1.Position:=var_spectrum.beeper_oversample;
if ((main_vars.tipo_maquina=0) or (main_vars.tipo_maquina=5)) then begin
    if var_spectrum.issue2 then radiobutton1.Checked:=true else radiobutton2.Checked:=true;
    groupbox8.Enabled:=false;
    radiobutton14.Enabled:=false;
    radiobutton15.Enabled:=false;
    radiobutton16.Enabled:=false;
    groupbox3.Enabled:=true;
    radiobutton1.Enabled:=true;
    radiobutton2.Enabled:=true;
end else begin
    groupbox3.Enabled:=false;
    radiobutton1.Enabled:=false;
    radiobutton2.Enabled:=false;
    groupbox8.Enabled:=true;
    radiobutton14.Enabled:=true;
    radiobutton15.Enabled:=true;
    radiobutton16.Enabled:=true;
end;
  //Las otras opciones
  if var_spectrum.tipo_joy=JKEMPSTON then radiobutton3.checked:=true
    else if var_spectrum.tipo_joy=JCURSOR then radiobutton4.checked:=true
      else if var_spectrum.tipo_joy=JSINCLAIR1 then radiobutton5.checked:=true
        else if var_spectrum.tipo_joy=JSINCLAIR2 then radiobutton6.checked:=true
          else if var_spectrum.tipo_joy=JFULLER then radiobutton25.checked:=true;
  if ulaplus.enabled then radiobutton23.Checked:=true
    else radiobutton24.Checked:=true;
  //emulacion del borde
  case borde.tipo  of
    0:radiobutton7.Checked:=true;
    1:radiobutton8.Checked:=true;
    2:radiobutton9.checked:=true;
  end;
  //Seleccion de raton
  case mouse.tipo of
     0:radiobutton10.Checked:=true;
     1:radiobutton11.Checked:=true;
     2:radiobutton19.Checked:=true;
     3:radiobutton20.Checked:=true;
  end;
  //Filtro Beeper
  if var_spectrum.beeper_filter then radiobutton17.Checked:=true
    else radiobutton18.Checked:=true;
  //Audio load
  if var_spectrum.audio_load then radiobutton21.Checked:=true
    else radiobutton22.Checked:=true;
  case main_vars.tipo_maquina of
    0,5:edit1.Text:=Directory.spectrum_48;
    1,4:edit1.Text:=Directory.spectrum_128;
    2,3:edit1.Text:=Directory.spectrum_3;
  end;
  //Lenslock
  groupbox7.Enabled:=true;
  radiobutton12.Enabled:=true;
  radiobutton13.Enabled:=true;
  if lenslok.activo then radiobutton12.Checked:=true
    else radiobutton13.Checked:=true;
  //Audio 128K
  case var_spectrum.audio_128k of
    0:radiobutton14.Checked:=true;
    1:radiobutton15.Checked:=true;
    2:radiobutton16.Checked:=true;
  end;
Button2.Caption:=leng[main_vars.idioma].mensajes[8];
end;

procedure TConfigSP.FormKeyUp(Sender:TObject;var Key:word;Shift:TShiftState);
begin
case key of
  13:Button1Click(nil);
  27:button2click(nil);
end;
end;

procedure TConfigSP.Button1Click(Sender: TObject);
var
  cadena:string;
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
          else if radiobutton25.Checked then begin
            var_spectrum.tipo_joy:=JFULLER;
            var_spectrum.joy_val:=$ff;
          end;
  if radiobutton7.checked then borde.tipo:=0;
  if RadioButton8.Checked then begin
    borde.tipo:=1;
    borde.borde_spectrum:=borde_normal;
  end;
  if radiobutton9.Checked then begin
    borde.tipo:=2;
    fillchar(borde.buffer,71136,16);
    case main_vars.tipo_maquina of
      0,5:borde.borde_spectrum:=borde_48_full;
      1,2,3,4:borde.borde_spectrum:=borde_128_full;
    end;
  end;
  var_spectrum.beeper_filter:=radiobutton17.Checked;
  var_spectrum.audio_load:=radiobutton21.Checked;
  if radiobutton10.Checked then mouse.tipo:=MNONE
    else if radiobutton11.Checked then mouse.tipo:=MGUNSTICK
      else if radiobutton19.Checked then mouse.tipo:=MKEMPSTON
        else if radiobutton20.Checked then mouse.tipo:=MAMX;
  if (mouse.tipo<>0) then sdl_showcursor(1)
    else sdl_showcursor(0);
  if mouse.tipo=3 then begin
    z80pio_init(0,pio_int_main,pio_read_porta,nil,nil,pio_read_portb,nil,nil);
    z80daisy_init(Z80_PIO_TYPE,Z80_DAISY_NONE,Z80_DAISY_NONE,0,0,0);
    z80pio_reset(0);
    spec_z80.daisy:=true;
  end;
  lenslok.activo:=radiobutton12.Checked;
  if lenslok.activo then lenslock1.Show;
  if RadioButton14.Checked then new_audio:=0;
  if RadioButton15.Checked then new_audio:=1;
  if RadioButton16.Checked then new_audio:=2;
  if new_audio<>var_spectrum.audio_128k then begin
    var_spectrum.audio_128k:=new_audio;
    close_audio;
    case var_spectrum.audio_128k of
      0:iniciar_audio(false);
      1,2:iniciar_audio(true);
    end;
  end;
  cadena:=changefileext(extractfilename(edit1.text),'');
  case main_vars.tipo_maquina of
    0,5:if Edit1.text<>Directory.spectrum_48 then begin
        Directory.spectrum_48:=Edit1.text;
        necesita_reset:=true;
        end;
    1,4:if Edit1.text<>Directory.spectrum_128 then begin
        Directory.spectrum_128:=Edit1.text;
        necesita_reset:=true;
        end;
    2,3:if Edit1.text<>Directory.spectrum_3 then begin
        Directory.spectrum_3:=Edit1.text;
        necesita_reset:=true;
        end;
  end;
  var_spectrum.beeper_oversample:=trackbar1.Position;
end;
var_spectrum.samples_beeper:=llamadas_maquina.velocidad_cpu/(freq_base_audio*var_spectrum.beeper_oversample);
if necesita_reset then begin
  main_vars.driver_ok:=llamadas_maquina.iniciar;
  if not(main_vars.driver_ok) then begin
    principal1.Ejecutar1click(nil);
  end;
end;
ulaplus.enabled:=radiobutton23.checked;
close;
end;

procedure TConfigSP.Button3Click(Sender: TObject);
var
  file_name:string;
begin
if OpenRom(StROM,file_name) then Edit1.Text:=file_name;
end;

end.
