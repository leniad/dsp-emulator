unit principal;

{$mode delphi}{$H+}
{$ifdef darwin}
        {$linklib SDL2_mixer}
{$endif}

interface

uses lib_sdl2,{$IFDEF WINDOWS}windows,{$else}LCLType,{$endif}
     Classes,SysUtils,FileUtil,LResources,Forms,Controls,
     Graphics,Dialogs,Menus,ExtCtrls,ComCtrls,StdCtrls,Grids,Buttons,
     //misc
     sound_engine,lenguaje,controls_engine,main_engine,loadrom,config_general,
     init_games,tape_window,
     //Devices
     vars_hide;

type

  { Tprincipal1 }
  Tprincipal1 = class(TForm)
    BitBtn10: TBitBtn;
    BitBtn11: TBitBtn;
    BitBtn12: TBitBtn;
    BitBtn13: TBitBtn;
    BitBtn14: TBitBtn;
    BitBtn15: TBitBtn;
    BitBtn16: TBitBtn;
    BitBtn17: TBitBtn;
    BitBtn19: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    BitBtn6: TBitBtn;
    BitBtn8: TBitBtn;
    BitBtn9: TBitBtn;
    btncfg: TBitBtn;
    Edit1: TEdit;
    GroupBox1: TGroupBox;
    GroupBox4: TGroupBox;
    Image1: TImage;
    ImageList2: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    MainMenu1: TMainMenu;
    Archivo1: TMenuItem;
    Emulacion1: TMenuItem;
    LstRoms: TMenuItem;
    Idioma1: TMenuItem;
    Castellano1: TMenuItem;
    Ingles1: TMenuItem;
    Catalan1: TMenuItem;
    French1: TMenuItem;
    German1: TMenuItem;
    Brazil1: TMenuItem;
    Audio1: TMenuItem;
    Config1: TMenuItem;
    Ejecutar1: TMenuItem;
    FullScreen1: TMenuItem;
    Arcade1: TMenuItem;
    Consolas1: TMenuItem;
    M65021: TMenuItem;
    M680911: TMenuItem;
    M680001: TMenuItem;
    BombJack1: TMenuItem;
    GalaxianHardware1: TMenuItem;
    dkonghw1: TMenuItem;
    BlackTiger1: TMenuItem;
    gberetHW: TMenuItem;
    Commando1: TMenuItem;
    LadyBugHW: TMenuItem;
    Iremm621: TMenuItem;
    BubbleBobble1: TMenuItem;
    Jungler1: TMenuItem;
    Asteroids1: TMenuItem;
    BurgerTime1: TMenuItem;
    ExpressRaider1: TMenuItem;
    gng1: TMenuItem;
    CityCon1: TMenuItem;
    Jackal1: TMenuItem;
    MappyHW1: TMenuItem;
    LWH1: TMenuItem;
    Legendw1: TMenuItem;
    digdug21: TMenuItem;
    hardhead1: TMenuItem;
    GalagaHW1: TMenuItem;
    galaga1: TMenuItem;
    mappy1: TMenuItem;
    hardhead21: TMenuItem;
    kungfum1: TMenuItem;
    ldrun1: TMenuItem;
    ldrun21: TMenuItem;
    bjtwin1: TMenuItem;
    knjoe1: TMenuItem;
    italiano1: TMenuItem;
    Acercade1: TMenuItem;
    MenuItem1: TMenuItem;
    JailBreak1: TMenuItem;
    Circusc1: TMenuItem;
    IronHorse1: TMenuItem;
    BrkThru1: TMenuItem;
    Darwin1: TMenuItem;
    MenuItem10: TMenuItem;
    ddragon_menu: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    GameBoy1: TMenuItem;
    Colecovision1: TMenuItem;
    alexkid1: TMenuItem;
    fantasyzone1: TMenuItem;
    MenuItem13: TMenuItem;
    arkarea1: TMenuItem;
    MenuItem14: TMenuItem;
    hopmappy1: TMenuItem;
    combatsc1: TMenuItem;
    Contra1: TMenuItem;
    MenuItem15: TMenuItem;
    InsectorX1: TMenuItem;
    mariob1: TMenuItem;
    hvyunit1: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    Frogger1: TMenuItem;
    Galaxian1: TMenuItem;
    JumpB1: TMenuItem;
    Amidar1: TMenuItem;
    MenuItem18: TMenuItem;
    flyingshark1: TMenuItem;
    jrpacman1: TMenuItem;
    ikari31: TMenuItem;
    choplifter1: TMenuItem;
    flicky1: TMenuItem;
    MenuItem19: TMenuItem;
    hippo1: TMenuItem;
    funkyjet1: TMenuItem;
    MenuItem20: TMenuItem;
    cninja1: TMenuItem;
    DietGo1: TMenuItem;
    MenuItem21: TMenuItem;
    actfancer1: TMenuItem;
    digdug1: TMenuItem;
    arabian1: TMenuItem;
    dkong1: TMenuItem;
    dkongjr1: TMenuItem;
    dkong31: TMenuItem;
    higemaru1: TMenuItem;
    MenuItem22: TMenuItem;
    Bagman1: TMenuItem;
    ddragon1: TMenuItem;
    ddragon21: TMenuItem;
    biomtoy1: TMenuItem;
    Chip81: TMenuItem;
    MenuItem23: TMenuItem;
    Congo1: TMenuItem;
    kangaroo1: TMenuItem;
    bionicc1: TMenuItem;
    MenuItem24: TMenuItem;
    MenuItem25: TMenuItem;
    elevator1: TMenuItem;
    aliensyn1: TMenuItem;
    jungleking1: TMenuItem;
    hharry1: TMenuItem;
    drgnbstr1: TMenuItem;
    ddragon31: TMenuItem;
    blockout1: TMenuItem;
    foodf1: TMenuItem;
    LadyBug1: TMenuItem;
    cavenger1: TMenuItem;
    gberet1: TMenuItem;
    MenuItem26: TMenuItem;
    MenuItem27: TMenuItem;
    genixfamily1: TMenuItem;
    junofirst1: TMenuItem;
    gyruss1: TMenuItem;
    MenuItem28: TMenuItem;
    freekick1: TMenuItem;
    boogwins1: TMenuItem;
    ssriders1: TMenuItem;
    TMNT1: TMenuItem;
    TMNT_hw: TMenuItem;
    Renegade1: TMenuItem;
    SegaMS1: TMenuItem;
    pbaction1: TMenuItem;
    pirates1: TMenuItem;
    twinbee1: TMenuItem;
    mrgoemon1: TMenuItem;
    Nemesis1: TMenuItem;
    Phoenix1: TMenuItem;
    pleiads1: TMenuItem;
    snapjack1: TMenuItem;
    Panel5: TPanel;
    StatusBar1: TStatusBar;
    tetris1: TMenuItem;
    Timer3: TTimer;
    vulgus1: TMenuItem;
    SkyKid1: TMenuItem;
    motos1: TMenuItem;
    todruaga1: TMenuItem;
    rtype21: TMenuItem;
    zaxxon1: TMenuItem;
    wb31: TMenuItem;
    outrun1: TMenuItem;
    spang1: TMenuItem;
    Pang1: TMenuItem;
    opwolf1: TMenuItem;
    volfied1: TMenuItem;
    rbisland1: TMenuItem;
    rbislande1: TMenuItem;
    wwfsuperstar1: TMenuItem;
    squash1: TMenuItem;
    sbagman1: TMenuItem;
    Robocop21: TMenuItem;
    superburgertime1: TMenuItem;
    tumblep1: TMenuItem;
    robocop1: TMenuItem;
    baddudes1: TMenuItem;
    upndown1: TMenuItem;
    seganinja1: TMenuItem;
    mrviking1: TMenuItem;
    searchar1: TMenuItem;
    twincobr1: TMenuItem;
    scramble1: TMenuItem;
    scobra1: TMenuItem;
    Pengo1: TMenuItem;
    MoonCresta1: TMenuItem;
    timepilot1: TMenuItem;
    SaintDragon1: TMenuItem;
    rodland1: TMenuItem;
    p471: TMenuItem;
    StreetSm1: TMenuItem;
    pow1: TMenuItem;
    Solomon1: TMenuItem;
    Timer4: TTimer;
    tnzs1: TMenuItem;
    Repulse1: TMenuItem;
    Pacland1: TMenuItem;
    rocnrope1: TMenuItem;
    skykiddx1: TMenuItem;
    rthunder1: TMenuItem;
    skykidhw1: TMenuItem;
    mnight1: TMenuItem;
    ninjakid21: TMenuItem;
    panghw1: TMenuItem;
    tutankhm1: TMenuItem;
    tp841: TMenuItem;
    NES1: TMenuItem;
    RType1: TMenuItem;
    SRD1: TMenuItem;
    MenuItem9: TMenuItem;
    SlapFight1: TMenuItem;
    tigerh1: TMenuItem;
    MenuItem2: TMenuItem;
    CPC1: TMenuItem;
    CPC6641: TMenuItem;
    CPC61281: TMenuItem;
    MenuItem3: TMenuItem;
    BigKarnak1: TMenuItem;
    Cabal1: TMenuItem;
    MenuItem4: TMenuItem;
    ghouls1: TMenuItem;
    ffight1: TMenuItem;
    kod1: TMenuItem;
    ccommando1: TMenuItem;
    knights1: TMenuItem;
    dino1: TMenuItem;
    MenuItem5: TMenuItem;
    ExedExes1: TMenuItem;
    MenuItem6: TMenuItem;
    GunSmoke1: TMenuItem;
    MenuItem7: TMenuItem;
    LegendofKage1: TMenuItem;
    SuperGlob1: TMenuItem;
    theglob1: TMenuItem;
    MrDo1: TMenuItem;
    MenuItem8: TMenuItem;
    N19421: TMenuItem;
    N19431: TMenuItem;
    N1943Kai1: TMenuItem;
    Shinobi1: TMenuItem;
    Punisher1: TMenuItem;
    sf2ce1: TMenuItem;
    wonder31: TMenuItem;
    Strider1: TMenuItem;
    sf21: TMenuItem;
    thoop1: TMenuItem;
    Spectrum31: TMenuItem;
    Spectrum2A1: TMenuItem;
    Spectrum21: TMenuItem;
    Spectrum128K1: TMenuItem;
    Spectrum48K1: TMenuItem;
    Spectrum16K1: TMenuItem;
    Pacman1: TMenuItem;
    mspacman1: TMenuItem;
    Silkworm1: TMenuItem;
    Rygar1: TMenuItem;
    Wardner1: TMenuItem;
    sbombers1: TMenuItem;
    NMK1: TMenuItem;
    Spelunker21: TMenuItem;
    Spelunker1: TMenuItem;
    newrallyx1: TMenuItem;
    sunahw1: TMenuItem;
    xain1: TMenuItem;
    spacman1: TMenuItem;
    sf1: TMenuItem;
    Trojan1: TMenuItem;
    SectionZ1: TMenuItem;
    Rastan1: TMenuItem;
    Toki1: TMenuItem;
    SnowBros1: TMenuItem;
    F1Dream1: TMenuItem;
    TigerRoad1: TMenuItem;
    TigerRoadHW1: TMenuItem;
    Prehisle1: TMenuItem;
    TerraCre1: TMenuItem;
    SuperBasketball1: TMenuItem;
    SonSon1: TMenuItem;
    Yiear1: TMenuItem;
    Shaolin1: TMenuItem;
    Mikie1: TMenuItem;
    ShootOut1: TMenuItem;
    MisteriousStone1: TMenuItem;
    RallyX1: TMenuItem;
    RallyXHardware1: TMenuItem;
    Vigilante1: TMenuItem;
    Psychic51: TMenuItem;
    Popeye1: TMenuItem;
    tehkanwc1: TMenuItem;
    Pooyan1: TMenuItem;
    wbml1: TMenuItem;
    wboy1: TMenuItem;
    teddy1: TMenuItem;
    PitfallII1: TMenuItem;
    System11: TMenuItem;
    Tecmo1: TMenuItem;
    StarForce1: TMenuItem;
    Pacmanhw1: TMenuItem;
    Panel4: TPanel;
    PhoenixHW: TMenuItem;
    Z801: TMenuItem;
    Ordenadores8bits1: TMenuItem;
    N3X1: TMenuItem;
    Panel2: TPanel;
    Panel3: TPanel;
    ScanLines2X1: TMenuItem;
    ScanLines1: TMenuItem;
    N2X1: TMenuItem;
    N1X1: TMenuItem;
    SinSonido1: TMenuItem;
    N441001: TMenuItem;
    N220501: TMenuItem;
    N110251: TMenuItem;
    Pausa1: TMenuItem;
    Reset1: TMenuItem;
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;
    Video1: TMenuItem;
    N1: TMenuItem;
    Salir1: TMenuItem;
    uProcesador1: TMenuItem;
    Opciones1: TMenuItem;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    SaveDialog1: TSaveDialog;
    Timer1: TTimer;
    Timer2: TTimer;
    procedure Acercade1Click(Sender: TObject);
    procedure BitBtn14Click(Sender: TObject);
    procedure BitBtn8Click(Sender: TObject);
    procedure fLoadCinta(Sender: TObject);
    procedure fSaveSnapShot(Sender: TObject);
    procedure CambiarVideo(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure IdiomaClick(Sender: TObject);
    procedure CambiaAudio(Sender: TObject);
    procedure fLoadCartucho(Sender: TObject);
    procedure LstRomsClick(Sender: TObject);
    procedure Pausa1Click(Sender: TObject);
    procedure Salir1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure CambiarMaquina(Sender: TObject);
    procedure Ejecutar1Click(Sender: TObject);
    procedure fFast(Sender: TObject);
    procedure fSlow(Sender: TObject);
    procedure fSaveGIF(Sender: TObject);
    procedure Reset1Click(Sender: TObject);
    procedure fConfigurar_general(Sender: TObject);
    procedure Timer3Timer(Sender: TObject);
    procedure Timer4Timer(Sender: TObject);
  private
    { private declarations }
    {$ifdef windows}
    procedure WndProc(var Message : TMessage); override;
    {$endif}
  public
    { public declarations }
  end;

var
  principal1: Tprincipal1;
const
  SCREEN_DIF=20;

implementation
uses acercade,tap_tzx,spectrum_misc,lenslock,file_engine;
var
  //Misc Vars
  tipo_new:word;
  //Status bitmap
  status_bitmap:tbitmap;

{ Tprincipal1 }
{$ifdef windows}
//Para evitar que cuando se pulsa ALT se vaya al menu añado esta funcion...
procedure Tprincipal1.WndProc(var Message : TMessage);
begin
if ((Message.Msg=WM_SYSCOMMAND) and (Message.WParam=SC_KEYMENU)) then exit;
inherited WndProc(Message);
end;
{$endif}

procedure Tprincipal1.fSaveGIF(Sender: TObject);
var
  r:integer;
  nombre:string;
  nombre2:ansistring;
  rect2:libsdl_rect;
  temp_s:libsdlp_Surface;
  gif:tgifimage;
  png:TPortableNetworkGraphic;
  JPG:TJPEGImage;
  imagen1:tbitmap;
begin
timer1.Enabled:=false;
EmuStatusTemp:=EmuStatus;
EmuStatus:=EsPause;
SaveDialog1.InitialDir:=Directory.spectrum_image;
SaveDialog1.FileName:=llamadas_maquina.caption;
SaveDialog1.Filter:='Imagen PNG(*.PNG)|*.png|Imagen JPG(*.JPG)|*.jpg|Imagen GIF(*.GIF)|*.gif';
SaveDialog1.FilterIndex:=2;
if Savedialog1.execute then begin
  nombre:=savedialog1.FileName;
  case SaveDialog1.FilterIndex of
    1:nombre:=ChangeFileExt(nombre,'.png');
    2:nombre:=ChangeFileExt(nombre,'.jpg');
    3:nombre:=ChangeFileExt(nombre,'.gif');
  end;
  if FileExists(nombre) then begin
    r:=application.messagebox(pansichar(leng[main_vars.idioma].mensajes[3]),pansichar(leng[main_vars.idioma].mensajes[6]), MB_YESNO or MB_ICONWARNING);
    if r=IDNO then begin
      {$ifdef windows}
       if not(main_screen.pantalla_completa) then windows.SetFocus(principal1.Panel4.Handle);
       {$else}
       cont_sincroniza:=sdl_getticks;
       valor_sync:=1000/llamadas_maquina.fps_max;
       cont_micro:=valor_sync;
       {$endif}
       exit;
    end;
    deletefile(nombre);
  end;
  Directory.spectrum_image:=extractfiledir(savedialog1.FileName)+main_vars.cadena_dir;
  rect2.x:=0;
  rect2.y:=0;
  case main_screen.video_mode of
      1,3:begin
            rect2.w:=p_final[0].x;
            rect2.h:=p_final[0].y;
          end;
      2,4:begin
            rect2.w:=p_final[0].x*2;
            rect2.h:=p_final[0].y*2;
          end;
      5:begin
            rect2.w:=p_final[0].x*3;
            rect2.h:=p_final[0].y*3;
          end;
  end;
  temp_s:=SDL_CreateRGBSurface(0,rect2.w,rect2.h,16,0,0,0,0);
  SDL_UpperBlit(pantalla[0],@rect2,temp_s,@rect2);
  nombre2:=directory.Base+'temp.bmp';
  SDL_SaveBMP_RW(temp_s,SDL_RWFromFile(pointer(nombre2),'wb'), 1);
  SDL_FreeSurface(temp_s);
  imagen1:=tbitmap.Create;
  imagen1.LoadFromFile(nombre2);
  deletefile(nombre2);
  case SaveDialog1.FilterIndex of
    1:begin //png
         PNG:=TPortableNetworkGraphic.Create;
         PNG.Assign(imagen1);
         PNG.SaveToFile(nombre);
         PNG.free;
      end;
    2:begin //jpg
         jpg:=TJPEGImage.Create;
         jpg.Assign(imagen1);
         jpg.SaveToFile(nombre);
         jpg.free;
      end;
    3:begin
        gif:=tgifimage.create;
        gif.assign(imagen1);
        gif.SaveToFile(nombre);
        gif.free;
    end;
  end;
  imagen1.Free;
end;
timer4.Enabled:=true;
end;

procedure Tprincipal1.IdiomaClick(Sender: TObject);
var
  tmp_idioma:byte;
begin
if sender<>nil then tmp_idioma:= Tmenuitem(sender).Tag
  else begin
    tmp_idioma:=main_vars.idioma;
    main_vars.idioma:=255;
  end;
if main_vars.idioma<>tmp_idioma then begin
  main_vars.idioma:=tmp_idioma;
  cambiar_idioma(main_vars.idioma);
end;
{$ifdef windows}
if not(main_screen.pantalla_completa) then windows.SetFocus(principal1.Panel4.Handle);
{$else}
cont_sincroniza:=sdl_getticks();
valor_sync:=1000/llamadas_maquina.fps_max;
cont_micro:=valor_sync;
{$endif}
end;

procedure Tprincipal1.Timer1Timer(Sender: TObject);
var
  velocidad:integer;
begin
statusbar1.Panels[2].Text:=main_vars.mensaje_general;
velocidad:=round((main_vars.frames_sec*100)/llamadas_maquina.fps_max);
statusbar1.Panels[0].Text:='FPS: '+inttostr(main_vars.frames_sec);
statusbar1.panels[1].text:=leng[main_vars.idioma].mensajes[0]+': '+inttostr(velocidad)+'%';
main_vars.frames_sec:=0;
end;

procedure Tprincipal1.CambiarMaquina(Sender:TObject);
var
  tipo:word;
begin
Panel1.Visible:=true;
todos_false;
tipo:=tipo_cambio_maquina(sender);
if main_vars.tipo_maquina=tipo then begin
   {$ifdef windows}
   if not(main_screen.pantalla_completa) then windows.SetFocus(principal1.Panel4.Handle);
   {$else}
   cont_sincroniza:=sdl_getticks();
   valor_sync:=1000/llamadas_maquina.fps_max;
   cont_micro:=valor_sync;
   {$endif}
   exit;
end;
if tipo>9 then begin
  if tape_window1.Showing then tape_window1.close;
  if lenslock1.Showing then lenslock1.close;
end;
if main_vars.driver_ok then EmuStatus:=EsPause;
tipo_new:=tipo;
timer3.Enabled:=true;
end;

procedure Tprincipal1.FormCreate(Sender: TObject);
{$ifdef darwin}
var
  cadena:string;f:word;count:byte;
{$endif}
begin
{$ifdef windows}
//SetPriorityClass(GetCurrentProcess, NORMAL_PRIORITY_CLASS);
//SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_HIGHEST);
Init_sdl_lib;
main_vars.cadena_dir:='\';
{$else}
main_vars.cadena_dir:='/';
Init_sdl_lib;
{$endif}
status_bitmap:=TBitmap.Create;
EmuStatus:=EsStoped;
directory.Base:=extractfiledir(application.ExeName)+main_vars.cadena_dir;
{$ifdef darwin}
//OSX: Subir tres veces el directorio para saber el directorio real...
cadena:=directory.Base;
count:=0;
for f:=length(cadena) downto 1 do begin
    if cadena[f]=main_vars.cadena_dir then count:=count+1;
    if count=4 then break;
end;
directory.Base:=copy(cadena,1,f);
{$endif}
if not DirectoryExists(directory.Base+'preview'+main_vars.cadena_dir) then CreateDir(directory.Base+'preview');
file_ini_load;
main_vars.lenguaje_ok:=leer_idioma;
principal1.idiomaclick(nil);
principal1.timer2.Enabled:=true;
end;

procedure Tprincipal1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
timer1.Enabled:=false;
EmuStatus:=EsPause;
if cinta_tzx.cargada then vaciar_cintas;
if ((addr(llamadas_maquina.cerrar)<>nil) and main_vars.driver_ok) then llamadas_maquina.cerrar;
file_ini_save;
if joystick_def[0]<>nil then close_joystick(arcade_input.num_joystick[0]);
if joystick_def[1]<>nil then close_joystick(arcade_input.num_joystick[1]);
sdl_videoquit;
sdl_quit;
status_bitmap.Destroy;
close_sdl_lib;
halt(0);
end;

procedure Tprincipal1.CambiarVideo(Sender: TObject);
var
  nuevo:byte;
begin
if sender<>nil then nuevo:=Tmenuitem(sender).tag
  else begin
    nuevo:=main_screen.video_mode;
    main_screen.video_mode:=255;
  end;
if main_screen.video_mode<>nuevo then main_screen.video_mode:=nuevo;
main_screen.pantalla_completa:=(main_screen.video_mode=6);
if main_vars.driver_ok then begin
  cambiar_video;
  if main_vars.tipo_maquina<7 then begin
    fillchar(buffer_video[0],6144,1);
    fillchar(borde.buffer[0],78000,$80);
  end;
end;
{$ifdef windows}
if not(main_screen.pantalla_completa) then windows.SetFocus(principal1.Panel4.Handle);
{$else}
cont_sincroniza:=sdl_getticks();
valor_sync:=1000/llamadas_maquina.fps_max;
cont_micro:=valor_sync;
{$endif}
end;

procedure Tprincipal1.Acercade1Click(Sender: TObject);
begin
timer1.Enabled:=false;
EmuStatusTemp:=EmuStatus;
EmuStatus:=EsPause;
aboutbox.show;
while aboutbox.Showing do application.ProcessMessages;
timer4.Enabled:=true;
end;

procedure Tprincipal1.BitBtn14Click(Sender: TObject);
begin
fastload:=not(fastload);
BitBtn14.Glyph:=nil;
if fastload then principal1.imagelist2.GetBitmap(0,principal1.BitBtn14.Glyph)
  else imagelist2.GetBitmap(1,principal1.BitBtn14.Glyph);
{$ifdef windows}
if not(main_screen.pantalla_completa) then windows.SetFocus(principal1.Panel4.Handle);
{$endif}
end;

procedure Tprincipal1.BitBtn8Click(Sender: TObject);
begin
if (addr(llamadas_maquina.configurar)=nil) then begin
   {$ifdef windows}
   if not(main_screen.pantalla_completa) then windows.SetFocus(principal1.Panel4.Handle);
   {$else}
   cont_sincroniza:=sdl_getticks();
   valor_sync:=1000/llamadas_maquina.fps_max;
   cont_micro:=valor_sync;
   {$endif}
   exit;
end;
timer1.Enabled:=false;
EmuStatusTemp:=EmuStatus;
EmuStatus:=EsPause;
llamadas_maquina.configurar;
timer4.Enabled:=true;
end;

procedure Tprincipal1.fLoadCinta(Sender: TObject);
begin
timer1.Enabled:=false;
EmuStatusTemp:=EmuStatus;
EmuStatus:=EsPause;
if addr(llamadas_maquina.cintas)<>nil then
  if not(llamadas_maquina.cintas) then MessageDlg('Cinta/Snapshot no valido'+chr(10)+chr(13)+'Tape/Snapshot not valid', mtError,[mbOk], 0);
timer4.Enabled:=true;
end;

procedure Tprincipal1.fSaveSnapShot(Sender: TObject);
begin
timer1.Enabled:=false;
EmuStatusTemp:=EmuStatus;
EmuStatus:=EsPause;
if addr(llamadas_maquina.grabar_snapshot)<>nil then llamadas_maquina.grabar_snapshot;
timer4.enabled:=true;
end;

procedure Tprincipal1.Ejecutar1Click(Sender: TObject);
begin
EmuStatus:=EsRuning;
timer1.Enabled:=true;
BitBtn3.Enabled:=false;
BitBtn4.Enabled:=true;
{$ifdef windows}
if not(main_screen.pantalla_completa) then windows.SetFocus(principal1.Panel4.Handle);
{$else}
cont_sincroniza:=sdl_getticks();
valor_sync:=1000/llamadas_maquina.fps_max;
cont_micro:=valor_sync;
{$endif}
if addr(llamadas_maquina.bucle_general)<>nil then llamadas_maquina.bucle_general();
end;

procedure Tprincipal1.fSlow(Sender: TObject);
begin
main_vars.vactual:=(main_vars.vactual+1) and 3;
{$ifdef windows}
valor_sync:=(1000000/(llamadas_maquina.fps_max/(main_vars.vactual+1)))*(cont_micro/1000000);
if not(main_screen.pantalla_completa) then windows.SetFocus(principal1.Panel4.Handle);
{$else}
valor_sync:=1000/(llamadas_maquina.fps_max/(main_vars.vactual+1));
cont_micro:=valor_sync;
cont_sincroniza:=sdl_getticks();
{$endif}
end;

procedure Tprincipal1.fFast(Sender: TObject);
begin
main_screen.rapido:=not(main_screen.rapido);
{$ifdef windows}
if not(main_screen.pantalla_completa) then windows.SetFocus(principal1.Panel4.Handle);
{$endif}
end;

procedure Tprincipal1.Reset1Click(Sender: TObject);
begin
main_screen.flip_main_screen:=false;
ulaplus.activa:=false;
if addr(llamadas_maquina.reset)<>nil then llamadas_maquina.reset;
{$ifdef windows}
if not(main_screen.pantalla_completa) then windows.SetFocus(principal1.Panel4.Handle);
{$endif}
end;

procedure Tprincipal1.CambiaAudio(Sender: TObject);
var
  tmp_audio:byte;
begin
if not(sound_status.hay_tsonido) then begin
   {$ifdef windows}
   if not(main_screen.pantalla_completa) then windows.SetFocus(principal1.Panel4.Handle);
   {$else}
   cont_sincroniza:=sdl_getticks();
   valor_sync:=1000/llamadas_maquina.fps_max;
   cont_micro:=valor_sync;
   {$endif}
   exit;
end;
if sender<>nil then tmp_audio:= Tmenuitem(sender).Tag
  else begin
  tmp_audio:=sound_status.calidad_audio;
  sound_status.calidad_audio:=255;
end;
if tmp_audio<>sound_status.calidad_audio then begin
  sound_status.calidad_audio:=tmp_audio;
  if sound_status.calidad_audio=3 then begin
      SinSonido1.Checked:=true;
      sound_status.hay_sonido:=false;
  end;
  if sound_status.calidad_audio<>3 then begin
    sound_status.hay_sonido:=true;
    close_audio;
    if sound_status.stereo then iniciar_audio(true)
      else iniciar_audio(false);
  end;
end;
{$ifdef windows}
if not(main_screen.pantalla_completa) then windows.SetFocus(principal1.Panel4.Handle);
{$else}
cont_sincroniza:=sdl_getticks();
valor_sync:=1000/llamadas_maquina.fps_max;
cont_micro:=valor_sync;
{$endif}
end;

procedure Tprincipal1.fLoadCartucho(Sender: TObject);
begin
timer1.Enabled:=false;
EmuStatusTemp:=EmuStatus;
EmuStatus:=EsPause;
if addr(llamadas_maquina.cartuchos)<>nil then
  if not(llamadas_maquina.cartuchos) then MessageDlg('ROM/Cartucho/Snapshot no valido'+chr(10)+chr(13)+'ROM/Cartrigde/Snapshot not valid', mtError,[mbOk], 0);
timer4.Enabled:=true;
end;

procedure Tprincipal1.LstRomsClick(Sender: TObject);
begin
timer1.Enabled:=false;
EmuStatusTemp:=EmuStatus;
EmuStatus:=EsPause;
FLoadRom.Show;
while FLoadRom.Showing do application.ProcessMessages;
{$ifdef windows}
if not(main_screen.pantalla_completa) then windows.SetFocus(principal1.Panel4.Handle);
{$else}
cont_sincroniza:=sdl_getticks();
valor_sync:=1000/llamadas_maquina.fps_max;
cont_micro:=valor_sync;
{$endif}
end;

procedure Tprincipal1.Pausa1Click(Sender: TObject);
begin
timer1.Enabled:=false;
EmuStatus:=EsPause;
BitBtn3.Enabled:=true;
BitBtn4.Enabled:=false;
end;

procedure Tprincipal1.Salir1Click(Sender: TObject);
begin
close;
end;

procedure Tprincipal1.Timer2Timer(Sender: TObject);
var
  tipo:word;
begin
timer2.Enabled:=false;
principal1.Caption:=principal1.Caption+dsp_version;
tipo:=main_vars.tipo_maquina;
main_vars.tipo_maquina:=255;
if not(main_vars.auto_exec) then begin
  principal1.LstRomsClick(nil);
  exit;
end;
load_game(tipo);
end;

procedure Tprincipal1.fConfigurar_general(Sender: TObject);
begin
timer1.Enabled:=false;
EmuStatusTemp:=EmuStatus;
EmuStatus:=EsPause;
MConfig.Show;
while MConfig.Showing do application.ProcessMessages;
timer4.Enabled:=true;
end;

procedure Tprincipal1.Timer3Timer(Sender: TObject);
begin
timer3.enabled:=false;
if ((@llamadas_maquina.cerrar<>nil) and main_vars.driver_ok) then llamadas_maquina.cerrar;
reset_dsp;
main_vars.tipo_maquina:=tipo_new;
cargar_maquina(main_vars.tipo_maquina);
{$ifdef windows}
QueryPerformanceFrequency(Int64((@cont_micro)^));
valor_sync:=(1000000/llamadas_maquina.fps_max)*(cont_micro/1000000);
{$endif}
if @llamadas_maquina.iniciar<>nil then main_vars.driver_ok:=llamadas_maquina.iniciar
  else main_vars.driver_ok:=false;
if not(main_vars.driver_ok) then begin
  EmuStatus:=EsStoped;
  principal1.timer1.Enabled:=false;
  principal1.BitBtn2.Enabled:=false;
  principal1.BitBtn3.Enabled:=false;
  principal1.BitBtn4.Enabled:=false;
  principal1.BitBtn5.Enabled:=false;
  principal1.BitBtn6.Enabled:=false;
  principal1.BitBtn8.Enabled:=false;
  principal1.BitBtn9.Enabled:=false;
  principal1.BitBtn10.Enabled:=false;
  principal1.BitBtn11.Enabled:=false;
  principal1.BitBtn12.Enabled:=false;
  principal1.BitBtn14.Enabled:=false;
  principal1.BitBtn19.Enabled:=false;
end else begin
  principal1.timer1.Enabled:=true;
  principal1.BitBtn2.Enabled:=true;
  principal1.BitBtn5.Enabled:=true;
  principal1.BitBtn6.Enabled:=true;
  principal1.BitBtn19.Enabled:=true;
  principal1.BitBtn8.Enabled:=true;
  {$ifdef windows}
          QueryPerformanceCounter(Int64((@cont_sincroniza)^));
          if not(main_screen.pantalla_completa) then windows.SetFocus(principal1.Panel4.Handle);
  {$else}
         cont_sincroniza:=sdl_getticks();
         valor_sync:=1000/llamadas_maquina.fps_max;
         cont_micro:=valor_sync;
  {$endif}
  principal1.ejecutar1click(nil);
end;
end;

procedure Tprincipal1.Timer4Timer(Sender: TObject);
begin
timer4.Enabled:=false;
EmuStatus:=EmuStatusTemp;
timer1.Enabled:=true;
{$ifdef windows}
if not(main_screen.pantalla_completa) then windows.SetFocus(principal1.Panel4.Handle);
{$else}
cont_sincroniza:=sdl_getticks();
valor_sync:=1000/llamadas_maquina.fps_max;
cont_micro:=valor_sync;
{$endif}
llamadas_maquina.bucle_general;
end;

initialization
  {$I principal.lrs}

end.

