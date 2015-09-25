unit config_sms;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Buttons,main_engine,sound_engine,sn_76496;

type

  { TSMSConfig }

  TSMSConfig = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  SMSConfig: TSMSConfig;

implementation
uses sega_vdp,sms,nz80;

{ TSMSConfig }

procedure TSMSConfig.FormShow(Sender: TObject);
begin
if vdp.is_pal then begin
  radiobutton2.Checked:=true;
  radiobutton1.Checked:=false;
end else begin
  radiobutton1.Checked:=true;
  radiobutton2.Checked:=false;
end;
if mapper_sms.bios_loaded then begin
  groupbox2.Enabled:=true;
  radiobutton3.Checked:=mapper_sms.bios_enabled;
  radiobutton4.Checked:=not(mapper_sms.bios_enabled);
end else groupbox2.Enabled:=false;
end;

procedure TSMSConfig.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
case key of
  13:SpeedButton1Click(nil);
  27:Speedbutton2click(nil);
end;
end;

procedure TSMSConfig.SpeedButton1Click(Sender: TObject);
begin
if radiobutton1.Checked then begin //NTSC
  if vdp.is_pal then begin
    llamadas_maquina.fps_max:=FPS_NTSC;
    valor_sync:=(1000000/FPS_NTSC)*(cont_micro/1000000);
    close_audio;
    iniciar_audio(false);
    close_video;
    screen_init(1,284,243);
    iniciar_video(284,243);
    main_z80.clock:=CLOCK_NTSC;
    main_z80.tframes:=(CLOCK_NTSC/LINES_NTSC)/FPS_NTSC;
    sound_engine_change_clock(CLOCK_NTSC);
    sn_76496_0.free;
    sn_76496_0:=sn76496_chip.Create(CLOCK_NTSC);
    vdp.is_pal:=false;
    vdp.VIDEO_VISIBLE_Y_TOTAL:=243;
    vdp.VIDEO_Y_TOTAL:=LINES_NTSC;
    vdp.LINEAS_TOP_BORDE:=27;
    vdp.LINEAS_Y_BORDE_INFERIOR:=216;
    vdp.LINEAS_Y_SYNC:=235;
  end;
end else begin //PAL
  if not(vdp.is_pal) then begin
    llamadas_maquina.fps_max:=FPS_PAL;
    valor_sync:=(1000000/FPS_PAL)*(cont_micro/1000000);
    close_audio;
    iniciar_audio(false);
    close_video;
    screen_init(1,284,294);
    iniciar_video(284,294);
    main_z80.clock:=CLOCK_PAL;
    main_z80.tframes:=(CLOCK_PAL/LINES_PAL)/FPS_PAL;
    sound_engine_change_clock(CLOCK_PAL);
    sn_76496_0.free;
    sn_76496_0:=sn76496_chip.Create(CLOCK_PAL);
    vdp.is_pal:=true;
    vdp.VIDEO_VISIBLE_Y_TOTAL:=294;
    vdp.VIDEO_Y_TOTAL:=LINES_PAL;
    vdp.LINEAS_TOP_BORDE:=54;
    vdp.LINEAS_Y_BORDE_INFERIOR:=240;
    vdp.LINEAS_Y_SYNC:=259;
  end;
end;
if mapper_sms.bios_loaded then begin
  mapper_sms.bios_enabled:=radiobutton3.checked;
  mapper_sms.bios_show:=radiobutton3.checked;
end;
close;
end;

procedure TSMSConfig.SpeedButton2Click(Sender: TObject);
begin
  close;
end;

initialization
  {$I config_sms.lrs}

end.

