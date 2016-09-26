unit config_sms;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.StdCtrls,main_engine,sound_engine,sn_76496;

type
  TSMSConfig = class(TForm)
    GroupBox1: TGroupBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    GroupBox2: TGroupBox;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    procedure FormShow(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SMSConfig: TSMSConfig;

implementation
uses sega_vdp,sms,nz80;

{$R *.dfm}

procedure TSMSConfig.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
case key of
  13:SpeedButton1Click(nil);
  27:Speedbutton2click(nil);
end;
end;

procedure TSMSConfig.FormShow(Sender: TObject);
begin
if vdp_0.is_pal then begin
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

procedure TSMSConfig.SpeedButton1Click(Sender: TObject);
begin
if radiobutton1.Checked then begin //NTSC
  if vdp_0.is_pal then begin
    llamadas_maquina.fps_max:=FPS_NTSC;
    valor_sync:=(1/FPS_NTSC)*cont_micro;
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
    vdp_0.set_ntsc_video;
  end;
end else begin //PAL
  if not(vdp_0.is_pal) then begin
    llamadas_maquina.fps_max:=FPS_PAL;
    valor_sync:=(1/FPS_PAL)*cont_micro;
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
    vdp_0.set_pal_video;
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

end.
