program dsp;

{$mode delphi}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, principal, acercade, LoadRom, config_general, redefine, cargar_dsk,
  tape_window, cargar_spec, lenslock, config, arcade_config,
  config_sms, config_cpc, misc_functions, config_gb;

{$IFDEF WINDOWS}
{$IFDEF CPU32}
{$R dsp.rc}
{$ENDIF}
{$ENDIF}

{$IFDEF UNIX}{$R dsp.res}{$ENDIF}

begin
  Application.Scaled:=True;
  Application.Title:='DSP Emulator';
  Application.Initialize;
  Application.CreateForm(Tprincipal1, principal1);
  Application.CreateForm(Ttape_window1, tape_window1);
  Application.CreateForm(Tlenslock1, lenslock1);
  Application.CreateForm(TAboutbox, Aboutbox);
  Application.CreateForm(Tconfig_arcade, config_arcade);
  Application.CreateForm(Tconfigcpc, configcpc);
  Application.CreateForm(TConfigSP, ConfigSP);
  Application.CreateForm(TFLoadRom, FLoadRom);
  Application.CreateForm(Tload_dsk, load_dsk);
  Application.CreateForm(Tload_spec, load_spec);
  Application.CreateForm(TMConfig, MConfig);
  Application.CreateForm(Tredefine1, redefine1);
  Application.CreateForm(TSMSConfig, SMSConfig);
  Application.CreateForm(Tconfiggb, configgb);
  Application.Run;
end.

