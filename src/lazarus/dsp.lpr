program dsp;

{$mode delphi}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, principal, acercade, LoadRom, config_general, redefine,
  cargar_dsk, tape_window, cargar_spec, lenslock, config, arcade_config, 
joystick_calibration, dac, SDL2;

{$IFDEF WINDOWS}
{$IFDEF CPU32}
{$R dsp.rc}
{$ENDIF}
{$ENDIF}

{$IFDEF UNIX}{$R dsp.res}{$ENDIF}

begin
  Application.Title:='DSP Emulator';
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm4, Form4);
  Application.CreateForm(TForm7, Form7);
  Application.CreateForm(TForm5, Form5);
  Application.CreateForm(TMConfig, MConfig);
  Application.CreateForm(TConfigSP, ConfigSP);
  Application.CreateForm(TAboutbox, Aboutbox);
  Application.CreateForm(TForm6, Form6);
  Application.CreateForm(TFLoadRom, FLoadRom);
  Application.CreateForm(Tconfig_arcade, config_arcade);
  Application.CreateForm(TForm8, Form8);
  Application.Run;
end.

