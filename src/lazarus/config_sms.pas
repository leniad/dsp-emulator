unit config_sms;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Buttons,main_engine,sound_engine,sn_76496,rom_engine;

type

  { TSMSConfig }

  TSMSConfig = class(TForm)
    GroupBox1: TGroupBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
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
case sms_model of
  0:begin //pal
      radiobutton2.Checked:=true;
      radiobutton1.Checked:=false;
      radiobutton3.Checked:=false;
  end;
  1:begin //ntsc JP
      radiobutton2.Checked:=false;
      radiobutton1.Checked:=true;
      radiobutton3.Checked:=false;
  end;
  2:begin //ntsc US
      radiobutton2.Checked:=false;
      radiobutton1.Checked:=false;
      radiobutton3.Checked:=true;
  end;
end;
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
var
  dir:string;
begin
dir:=directory.arcade_list_roms[find_rom_multiple_dirs('sms.zip')];
if radiobutton1.Checked then begin //NTSC JP
  if sms_model<>1 then begin
    sms_model:=1;
    carga_rom_zip(dir+'sms.zip',sms_bios_j.n,@mapper_sms.bios[0],sms_bios_j.l,sms_bios_j.crc,false);
    llamadas_maquina.fps_max:=FPS_NTSC;
    valor_sync:=(1/FPS_NTSC)*cont_micro;
    close_audio;
    iniciar_audio(false);
    close_video;
    screen_init(1,284,243);
    iniciar_video(284,243);
    z80_0.clock:=CLOCK_NTSC;
    z80_0.tframes:=(CLOCK_NTSC/LINES_NTSC)/FPS_NTSC;
    sound_engine_change_clock(CLOCK_NTSC);
    sn_76496_0.free;
    sn_76496_0:=sn76496_chip.Create(CLOCK_NTSC);
    vdp_0.video_ntsc(vdp_0.video_mode);
  end;
end;
if radiobutton2.Checked then begin //PAL
  if sms_model<>0 then begin
    sms_model:=0;
    carga_rom_zip(dir+'sms.zip',sms_bios.n,@mapper_sms.bios[0],sms_bios.l,sms_bios.crc,false);
    llamadas_maquina.fps_max:=FPS_PAL;
    valor_sync:=(1/FPS_PAL)*cont_micro;
    close_audio;
    iniciar_audio(false);
    close_video;
    screen_init(1,284,294);
    iniciar_video(284,294);
    z80_0.clock:=CLOCK_PAL;
    z80_0.tframes:=(CLOCK_PAL/LINES_PAL)/FPS_PAL;
    sound_engine_change_clock(CLOCK_PAL);
    sn_76496_0.change_clock(CLOCK_PAL);
    vdp_0.video_pal(vdp_0.video_mode);
    //ym2413_0.change_clock(CLOCK_PAL);
  end;
end;
if radiobutton3.Checked then begin //NTSC JP
  if sms_model<>2 then begin
    sms_model:=2;
    carga_rom_zip(dir+'sms.zip',sms_bios.n,@mapper_sms.bios[0],sms_bios.l,sms_bios.crc,false);
    llamadas_maquina.fps_max:=FPS_NTSC;
    valor_sync:=(1/FPS_NTSC)*cont_micro;
    close_audio;
    iniciar_audio(false);
    close_video;
    screen_init(1,284,243);
    iniciar_video(284,243);
    z80_0.clock:=CLOCK_NTSC;
    z80_0.tframes:=(CLOCK_NTSC/LINES_NTSC)/FPS_NTSC;
    sound_engine_change_clock(CLOCK_NTSC);
    sn_76496_0.change_clock(CLOCK_NTSC);
    vdp_0.video_ntsc(vdp_0.video_mode);
    //ym2413.change_clock(CLOCK_NTSC);
  end;
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

