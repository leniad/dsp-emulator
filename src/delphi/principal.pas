unit principal;

//{$SetPeFlags $20}

interface

uses
  lib_sdl2,Windows,SysUtils,Forms,graphics,uchild,Classes,Dialogs,StdCtrls,ExtCtrls,
  Buttons,Grids,ComCtrls,Menus,ImgList,Controls,messages,System.ImageList,
  //graphics
  jpeg,gifimg,pngimage,
  //misc
  poke_spectrum,main_engine,sound_engine,tape_window,lenguaje,init_games,
  controls_engine,LoadRom,config_general,
  //other...
  vars_hide;

type
  Tprincipal1 = class(TForm)
    MainMenu1: TMainMenu;
    Archivo1: TMenuItem;
    Opciones1: TMenuItem;
    Arcade1: TMenuItem;
    Spect_menu: TMenuItem;
    uProcesador1: TMenuItem;
    Reset1: TMenuItem;
    Pausa1: TMenuItem;
    Audio1: TMenuItem;
    Video1: TMenuItem;
    Salir1: TMenuItem;
    Ejecutar1: TMenuItem;
    NES1: TMenuItem;
    Timer1: TTimer;
    Spectrum128K1: TMenuItem;
    N110251: TMenuItem;
    N220501: TMenuItem;
    N441001: TMenuItem;
    BombJack1: TMenuItem;
    PacmanHW1: TMenuItem;
    Emulacion1: TMenuItem;
    Ordenadores8bits1: TMenuItem;
    Consolas1: TMenuItem;
    Phoenix_hw: TMenuItem;
    N1: TMenuItem;
    Acercade1: TMenuItem;
    Idioma1: TMenuItem;
    Castellano1: TMenuItem;
    Ingles1: TMenuItem;
    Frogger1: TMenuItem;
    MisteriousStone1: TMenuItem;
    Spectrum31: TMenuItem;
    SinSonido1: TMenuItem;
    N1X1: TMenuItem;
    N2X1: TMenuItem;
    Catalan1: TMenuItem;
    GameBoy1: TMenuItem;
    French1: TMenuItem;
    ImageList2: TImageList;
    CPC_menu: TMenuItem;
    dkonghw1: TMenuItem;
    BlackTiger1: TMenuItem;
    GberetHW: TMenuItem;
    Commando1: TMenuItem;
    Panel1: TPanel;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn5: TBitBtn;
    BitBtn6: TBitBtn;
    btncfg: TBitBtn;
    BitBtn8: TBitBtn;
    gng1: TMenuItem;
    German1: TMenuItem;
    Mikie1: TMenuItem;
    Shaolin1: TMenuItem;
    Yiear1: TMenuItem;
    SaveDialog1: TSaveDialog;
    Asteroids1: TMenuItem;
    Z801: TMenuItem;
    M65021: TMenuItem;
    M68091: TMenuItem;
    SonSon1: TMenuItem;
    BitBtn19: TBitBtn;
    StarForce1: TMenuItem;
    Rygar1: TMenuItem;
    PitfallII1: TMenuItem;
    Pooyan1: TMenuItem;
    Jungler1: TMenuItem;
    CityCon1: TMenuItem;
    BurgerTime1: TMenuItem;
    ExpressRaider1: TMenuItem;
    SuperBasketball1: TMenuItem;
    LadyBug_menu: TMenuItem;
    ScanLines1: TMenuItem;
    ScanLines2X1: TMenuItem;
    System11: TMenuItem;
    teddy1: TMenuItem;
    wboy1: TMenuItem;
    wbml1: TMenuItem;
    tehkanwc1: TMenuItem;
    Popeye1: TMenuItem;
    Psychic51: TMenuItem;
    Brazil1: TMenuItem;
    M680001: TMenuItem;
    TerraCre1: TMenuItem;
    KungFuM1: TMenuItem;
    ShootOut1: TMenuItem;
    Vigilante1: TMenuItem;
    BitBtn13: TBitBtn;
    Colecovision1: TMenuItem;
    Configuracion1: TMenuItem;
    LstRoms: TMenuItem;
    Jackal1: TMenuItem;
    CPC6641: TMenuItem;
    CPC61281: TMenuItem;
    BubbleBobble1: TMenuItem;
    Galaxian1: TMenuItem;
    JumpB1: TMenuItem;
    MoonCresta1: TMenuItem;
    N3X1: TMenuItem;
    GalaxianHardware1: TMenuItem;
    RallyXHardware1: TMenuItem;
    RallyX1: TMenuItem;
    Prehisle1: TMenuItem;
    TigerRoadHW1: TMenuItem;
    TigerRoad1: TMenuItem;
    F1Dream1: TMenuItem;
    SnowBros1: TMenuItem;
    Toki1: TMenuItem;
    FullScreen1: TMenuItem;
    Timer2: TTimer;
    Contra1: TMenuItem;
    MappyHW1: TMenuItem;
    Rastan1: TMenuItem;
    LegendaryWingsHardware1: TMenuItem;
    legendw1: TMenuItem;
    SectionZ1: TMenuItem;
    Trojan1: TMenuItem;
    SF1: TMenuItem;
    Mappy1: TMenuItem;
    DigDug21: TMenuItem;
    SPacman1: TMenuItem;
    GalagaHardware1: TMenuItem;
    Galaga1: TMenuItem;
    Xain1: TMenuItem;
    SunaHardware1: TMenuItem;
    HardHead1: TMenuItem;
    HardHead21: TMenuItem;
    sbombers1: TMenuItem;
    NewRallyX1: TMenuItem;
    NMK161: TMenuItem;
    bjtwin1: TMenuItem;
    IremM62Hardware1: TMenuItem;
    Spelunker1: TMenuItem;
    Spelunker21: TMenuItem;
    ldrun1: TMenuItem;
    ldrun21: TMenuItem;
    knJoe1: TMenuItem;
    Wardner1: TMenuItem;
    Gaelco1: TMenuItem;
    BigKarnak1: TMenuItem;
    ExedExes1: TMenuItem;
    GunSmokehw1: TMenuItem;
    N19421: TMenuItem;
    N19431: TMenuItem;
    GunSmoke1: TMenuItem;
    N1943Kai1: TMenuItem;
    JailBreak1: TMenuItem;
    Circusc1: TMenuItem;
    IronHorse1: TMenuItem;
    NEC1: TMenuItem;
    IremM721: TMenuItem;
    RType1: TMenuItem;
    Pacman1: TMenuItem;
    MSPacman1: TMenuItem;
    BreakThruHawrdware1: TMenuItem;
    BrkThru1: TMenuItem;
    Darwin1: TMenuItem;
    SRD1: TMenuItem;
    HD63091: TMenuItem;
    ddragon_hw: TMenuItem;
    MrDo1: TMenuItem;
    theglob1: TMenuItem;
    EposHardware1: TMenuItem;
    SuperGlob1: TMenuItem;
    ecmoHardware1: TMenuItem;
    Silkworm1: TMenuItem;
    SlapFightHardware1: TMenuItem;
    tigerh1: TMenuItem;
    SlapFight1: TMenuItem;
    LegendofKage1: TMenuItem;
    thoop1: TMenuItem;
    Cabal1: TMenuItem;
    CPS11: TMenuItem;
    ghouls1: TMenuItem;
    ffight1: TMenuItem;
    kod1: TMenuItem;
    sf21: TMenuItem;
    Strider1: TMenuItem;
    wonder31: TMenuItem;
    ccommando1: TMenuItem;
    knights1: TMenuItem;
    sf2ce1: TMenuItem;
    dino1: TMenuItem;
    Italiano1: TMenuItem;
    Punisher1: TMenuItem;
    Spectrum48K1: TMenuItem;
    CPC1: TMenuItem;
    Spectrum2A1: TMenuItem;
    Spectrum21: TMenuItem;
    Spectrum16K1: TMenuItem;
    SegaSystem161: TMenuItem;
    Shinobi1: TMenuItem;
    AlexKid1: TMenuItem;
    FantasyZone1: TMenuItem;
    tp841: TMenuItem;
    tutankhm1: TMenuItem;
    PangHW1: TMenuItem;
    upl1: TMenuItem;
    ninjakid21: TMenuItem;
    ArkArea1: TMenuItem;
    mnight1: TMenuItem;
    SkyKidHW1: TMenuItem;
    NamcoSystem861: TMenuItem;
    rthunder1: TMenuItem;
    hopmappy1: TMenuItem;
    skykiddx1: TMenuItem;
    RocnRope1: TMenuItem;
    Repulse1: TMenuItem;
    heNewZelandStoryHardware1: TMenuItem;
    tnzs1: TMenuItem;
    InsectorX1: TMenuItem;
    Pacland1: TMenuItem;
    mariob1: TMenuItem;
    Solomon1: TMenuItem;
    combatsc1: TMenuItem;
    hvyunit1: TMenuItem;
    SNK68kHW1: TMenuItem;
    pow1: TMenuItem;
    StreetSm1: TMenuItem;
    Megasys1Hardware1: TMenuItem;
    P471: TMenuItem;
    RodLand1: TMenuItem;
    SaintDragon1: TMenuItem;
    OpenDialog1: TOpenDialog;
    TimePilot1: TMenuItem;
    Timer4: TTimer;
    Pengo1: TMenuItem;
    Scramble1: TMenuItem;
    scobra1: TMenuItem;
    Amidar1: TMenuItem;
    Panel2: TPanel;
    BitBtn9: TBitBtn;
    BitBtn10: TBitBtn;
    BitBtn11: TBitBtn;
    BitBtn12: TBitBtn;
    BitBtn14: TBitBtn;
    winCobraHardware1: TMenuItem;
    TwinCobr1: TMenuItem;
    FlyingShark1: TMenuItem;
    JrPacMan1: TMenuItem;
    Ikari31: TMenuItem;
    Searchar1: TMenuItem;
    Choplifter1: TMenuItem;
    mrviking1: TMenuItem;
    SegaNinja1: TMenuItem;
    UpnDown1: TMenuItem;
    Flicky1: TMenuItem;
    DECO161: TMenuItem;
    Robocop1: TMenuItem;
    Baddudes1: TMenuItem;
    Hippo1: TMenuItem;
    TumbleP1: TMenuItem;
    FunkyJet1: TMenuItem;
    SuperBurgerTime1: TMenuItem;
    CavemanNinjaHW1: TMenuItem;
    cninja1: TMenuItem;
    Robocop21: TMenuItem;
    DietGo1: TMenuItem;
    Hu62801: TMenuItem;
    ActFancer1: TMenuItem;
    Arabian1: TMenuItem;
    DigDug1: TMenuItem;
    dkong1: TMenuItem;
    dkongjr1: TMenuItem;
    dkong31: TMenuItem;
    Higemaru1: TMenuItem;
    BagmanHW1: TMenuItem;
    Bagman1: TMenuItem;
    SBagman1: TMenuItem;
    Squash1: TMenuItem;
    ddragon1: TMenuItem;
    ddragon21: TMenuItem;
    biomtoy1: TMenuItem;
    CHIP81: TMenuItem;
    ZaxxonHW1: TMenuItem;
    Congo1: TMenuItem;
    Kangaroo1: TMenuItem;
    Bionicc1: TMenuItem;
    wwfsuperstar1: TMenuItem;
    RainbowIslandsHW1: TMenuItem;
    rbisland1: TMenuItem;
    rbislande1: TMenuItem;
    Volfied1: TMenuItem;
    opwolf1: TMenuItem;
    Pang1: TMenuItem;
    SPang1: TMenuItem;
    Outrun1: TMenuItem;
    aitoSJ1: TMenuItem;
    elevator1: TMenuItem;
    AlienSyn1: TMenuItem;
    wb31: TMenuItem;
    Zaxxon1: TMenuItem;
    JungleKing1: TMenuItem;
    hharry1: TMenuItem;
    RType21: TMenuItem;
    todruaga1: TMenuItem;
    Motos1: TMenuItem;
    SkyKid1: TMenuItem;
    drgnbstr1: TMenuItem;
    Vulgus1: TMenuItem;
    ddragon31: TMenuItem;
    BlockOut1: TMenuItem;
    tetris1: TMenuItem;
    Foodf1: TMenuItem;
    Timer3: TTimer;
    Panel3: TPanel;
    StatusBar1: TStatusBar;
    Image1: TImage;
    LadyBug1: TMenuItem;
    SnapJack1: TMenuItem;
    cavenger1: TMenuItem;
    Phoenix1: TMenuItem;
    Pleiads1: TMenuItem;
    Gberet1: TMenuItem;
    MrGoemon1: TMenuItem;
    NemesisHW1: TMenuItem;
    Nemesis1: TMenuItem;
    twinbee1: TMenuItem;
    PiratesHW1: TMenuItem;
    Pirates1: TMenuItem;
    GenixFamily1: TMenuItem;
    JunoFirst1: TMenuItem;
    Gyruss1: TMenuItem;
    FreeKickHW1: TMenuItem;
    FreeKick1: TMenuItem;
    boogwins1: TMenuItem;
    pbaction1: TMenuItem;
    SegaMS1: TMenuItem;
    Renegade1: TMenuItem;
    tmnthw1: TMenuItem;
    tmnt1: TMenuItem;
    ssriders1: TMenuItem;
    Gradius31: TMenuItem;
    BitBtn1: TBitBtn;
    SpaceInvaders1: TMenuItem;
    Centipede1: TMenuItem;
    KarnovHW1: TMenuItem;
    Karnov1: TMenuItem;
    Chelnov1: TMenuItem;
    KonamiCPU1: TMenuItem;
    Aliens1: TMenuItem;
    hunderCrossHW1: TMenuItem;
    scontra1: TMenuItem;
    gbusters1: TMenuItem;
    thunderx1: TMenuItem;
    simpsons1: TMenuItem;
    Trackfield1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure Ejecutar1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure CambiarMaquina(Sender: TObject);
    procedure CambiaAudio(Sender: TObject);
    procedure Reset1Click(Sender: TObject);
    procedure Acercade1Click(Sender: TObject);
    procedure Salir1Click(Sender: TObject);
    procedure IdiomaClick(Sender: TObject);
    procedure FormClose(Sender:TObject;var Action:TCloseAction);
    procedure CambiarVideo(Sender: TObject);
    procedure fSlow(Sender: TObject);
    procedure fFast(Sender: TObject);
    procedure fLoadCinta(Sender: TObject);
    procedure fSaveSnapShot(Sender: TObject);
    procedure fPoke(Sender: TObject);
    procedure fSaveGIF(Sender: TObject);
    procedure ffastload(Sender: TObject);
    procedure fConfigurar(Sender: TObject);
    procedure fConfigurar_general(Sender: TObject);
    procedure fLoadCartucho(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure LstRomsClick(Sender: TObject);
    procedure Timer4Timer(Sender: TObject);
    procedure Timer3Timer(Sender: TObject);

  private
    { Private declarations }
    procedure WndProc(var Message:TMessage); override;
  public
    { Public declarations }
  end;

var
  //Main Vars
  principal1:Tprincipal1;
  Child:TfrChild;
  //Misc Vars
  tipo_new:word;
  fila_dibujo:word;
  //Status bitmap
  status_bitmap:tbitmap;

implementation
uses acercade,file_engine,poke_memoria,lenslock,spectrum_misc,tap_tzx;

{$R *.dfm}
//Para evitar que cuando se pulsa ALT se vaya al menu añado esta funcion...
procedure Tprincipal1.WndProc(var Message:TMessage);
begin
if not((Message.Msg=WM_SYSCOMMAND) and (Message.WParam=SC_KEYMENU)) then inherited WndProc(Message);
end;

procedure Tprincipal1.FormCreate(Sender: TObject);
begin
SetPriorityClass(GetCurrentProcess, NORMAL_PRIORITY_CLASS);
SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_HIGHEST);
Init_sdl_lib;
status_bitmap:=TBitmap.Create;
EmuStatus:=EsStoped;
main_vars.cadena_dir:='\';
directory.Base:=extractfiledir(application.ExeName)+main_vars.cadena_dir;
file_ini_load;
if not DirectoryExists(Directory.Preview) then CreateDir(Directory.Preview);
if not DirectoryExists(Directory.Arcade_nvram) then CreateDir(Directory.Arcade_nvram);
if not DirectoryExists(directory.qsnapshot) then CreateDir(directory.qsnapshot);
main_vars.lenguaje_ok:=leer_idioma;
principal1.idiomaclick(nil);
principal1.timer2.Enabled:=true;
end;

procedure Tprincipal1.Ejecutar1Click(Sender: TObject);
begin
BitBtn3.Enabled:=true;
if EmuStatus=EsRuning then begin //Pausa
  timer1.Enabled:=false;
  EmuStatus:=EsPause;
  principal1.BitBtn3.Glyph:=nil;
  principal1.imagelist2.GetBitmap(5,principal1.BitBtn3.Glyph);
end else begin //Play
  EmuStatus:=EsRuning;
  timer1.Enabled:=true;
  Windows.SetFocus(child.Handle);
  principal1.BitBtn3.Glyph:=nil;
  principal1.imagelist2.GetBitmap(6,principal1.BitBtn3.Glyph);
  if @llamadas_maquina.bucle_general<>nil then llamadas_maquina.bucle_general;
end;
end;

procedure Tprincipal1.CambiarMaquina(Sender:TObject);
var
  tipo:word;
begin
todos_false;
tipo:=tipo_cambio_maquina(sender);
if main_vars.tipo_maquina<>tipo then begin
  menus_false(tipo);
  if tipo>9 then begin
    if tape_window1.Showing then tape_window1.close;
    if lenslock1.Showing then lenslock1.close;
  end;
  if main_vars.driver_ok then EmuStatus:=EsPause;
  tipo_new:=tipo;
  timer3.Enabled:=true;
end;
end;

procedure Tprincipal1.Timer1Timer(Sender: TObject);
var
  velocidad:integer;
begin
statusbar1.Panels[2].Text:=main_vars.mensaje_general;
velocidad:=trunc((main_vars.frames_sec*100)/llamadas_maquina.fps_max);
statusbar1.Panels[0].Text:='FPS: '+inttostr(main_vars.frames_sec);
statusbar1.panels[1].text:=leng[main_vars.idioma].mensajes[0]+': '+inttostr(velocidad)+'%';
main_vars.frames_sec:=0;
end;

procedure Tprincipal1.Timer2Timer(Sender: TObject);
var
  tipo:word;
begin
//Inicializa las ventanas
timer2.Enabled:=false;
Child:=TfrChild.Create(application);
principal1.Caption:=principal1.Caption+dsp_version;
tipo:=main_vars.tipo_maquina;
main_vars.tipo_maquina:=255;
if not(main_vars.auto_exec) then begin
  principal1.LstRomsClick(nil);
  exit;
end;
load_game(tipo);
end;

procedure Tprincipal1.Timer3Timer(Sender: TObject);
begin
timer3.Enabled:=false;
if @llamadas_maquina.close<>nil then llamadas_maquina.close;
reset_dsp;
main_vars.tipo_maquina:=tipo_new;
cargar_maquina(main_vars.tipo_maquina);
QueryPerformanceFrequency(Int64((@cont_micro)^));
valor_sync:=(1000000/llamadas_maquina.fps_max)*(cont_micro/1000000);
if @llamadas_maquina.iniciar<>nil then main_vars.driver_ok:=llamadas_maquina.iniciar
  else main_vars.driver_ok:=false;
if not(main_vars.driver_ok) then begin
  EmuStatus:=EsStoped;
  principal1.timer1.Enabled:=false;
  principal1.BitBtn1.Enabled:=false;
  principal1.BitBtn2.Enabled:=false;
  principal1.BitBtn3.Enabled:=false;
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
  QueryPerformanceCounter(Int64((@cont_sincroniza)^));
  if not(main_screen.pantalla_completa) then Windows.SetFocus(child.Handle);
  principal1.ejecutar1click(nil);
end;
end;

procedure Tprincipal1.Timer4Timer(Sender: TObject);
begin
timer4.Enabled:=false;
EmuStatus:=EmuStatusTemp;
timer1.Enabled:=true;
if not(main_screen.pantalla_completa) then Windows.SetFocus(child.Handle);
llamadas_maquina.bucle_general;
end;

procedure Tprincipal1.CambiaAudio(Sender: TObject);
var
  tmp_audio:byte;
begin
if sound_status.hay_tsonido then begin
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
end;
Windows.SetFocus(child.Handle);
end;

procedure Tprincipal1.Reset1Click(Sender: TObject);
begin
main_screen.flip_main_screen:=false;
if @llamadas_maquina.reset<>nil then llamadas_maquina.reset;
Windows.SetFocus(child.Handle);
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

procedure Tprincipal1.Salir1Click(Sender: TObject);
begin
close;
end;

procedure Tprincipal1.IdiomaClick(Sender: TObject);
var
  tmp_idioma:byte;
begin
if sender<>nil then tmp_idioma:= Tmenuitem(sender).tag
  else begin
    tmp_idioma:=main_vars.idioma;
    main_vars.idioma:=255;
  end;
if main_vars.idioma<>tmp_idioma then begin
  main_vars.idioma:=tmp_idioma;
  cambiar_idioma(main_vars.idioma);
end;
if child<>nil then Windows.SetFocus(child.Handle);
end;

procedure Tprincipal1.LstRomsClick(Sender: TObject);
begin
timer1.Enabled:=false;
EmuStatusTemp:=EmuStatus;
EmuStatus:=EsPause;
FLoadRom.Show;
while FLoadRom.Showing do application.ProcessMessages;
Windows.SetFocus(child.Handle);
end;

procedure Tprincipal1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
timer1.Enabled:=false;
EmuStatus:=EsPause;
if cinta_tzx.cargada then vaciar_cintas;
if ((@llamadas_maquina.close<>nil) and main_vars.driver_ok) then llamadas_maquina.close;
reset_dsp;
file_ini_save;
if joystick_def[0]<>nil then close_joystick(arcade_input.num_joystick[0]);
if joystick_def[1]<>nil then close_joystick(arcade_input.num_joystick[1]);
SDL_DestroyWindow(window_render);
SDL_VideoQuit;
SDL_Quit;
status_bitmap.Destroy;
close_sdl_lib;
halt(0);
end;

procedure Tprincipal1.fSaveSnapShot(Sender: TObject);
begin
timer1.Enabled:=false;
EmuStatusTemp:=EmuStatus;
EmuStatus:=EsPause;
if @llamadas_maquina.grabar_snapshot<>nil then llamadas_maquina.grabar_snapshot;
timer4.Enabled:=true;
end;

procedure Tprincipal1.fPoke(Sender: TObject);
begin
//Pausa1Click(nil);
//form3.show;
if not(cinta_tzx.cargada) then exit;
iniciar_BBDD_poke;
buscar_BBDD;
//Ejecutar1click(nil);
end;

procedure Tprincipal1.fConfigurar_general(Sender: TObject);
begin
timer1.Enabled:=false;
EmuStatusTemp:=EmuStatus;
EmuStatus:=EsPause;
MConfig.Show;
while MConfig.Showing do application.ProcessMessages;
timer4.enabled:=true;
end;

procedure Tprincipal1.fSaveGif(Sender: TObject);
var
  r:integer;
  nombre:string;
  nombre2:ansistring;
  rect2:libsdl_rect;
  temp_s:libsdlP_Surface;
  gif:tgifimage;
  png:TPngImage;
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
    r:=MessageBox(0,pointer(leng[main_vars.idioma].mensajes[3]), pointer(leng[main_vars.idioma].mensajes[6]), MB_YESNO or MB_ICONWARNING);
    if r=IDNO then begin
      Windows.SetFocus(child.Handle);
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
         PNG:=TPngImage.Create;
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
        gif.Optimize([ooMerge, ooCleanup, ooColorMap], rmNone, dmNearest, 8);
        gif.SaveToFile(nombre);
        gif.free;
    end;
  end;
  imagen1.Free;
end;
timer4.Enabled:=true;
end;

procedure Tprincipal1.ffastload(Sender: TObject);
begin
var_spectrum.fastload:=not(var_spectrum.fastload);
BitBtn14.Glyph:=nil;
if var_spectrum.fastload then principal1.imagelist2.GetBitmap(0,principal1.BitBtn14.Glyph)
  else imagelist2.GetBitmap(1,principal1.BitBtn14.Glyph);
if not(main_screen.pantalla_completa) then Windows.SetFocus(child.Handle);
end;

procedure Tprincipal1.fSlow(Sender: TObject);
begin
main_vars.vactual:=(main_vars.vactual+1) and 3;
valor_sync:=(1000000/(llamadas_maquina.fps_max/(main_vars.vactual+1)))*(cont_micro/1000000);
if not(main_screen.pantalla_completa) then Windows.SetFocus(child.Handle);
end;

procedure Tprincipal1.fFast(Sender: TObject);
begin
main_screen.rapido:=not(main_screen.rapido);
QueryPerformanceCounter(Int64((@cont_sincroniza)^));
if not(main_screen.pantalla_completa) then Windows.SetFocus(child.Handle);
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
if main_vars.driver_ok then begin
    if nuevo=6 then begin
      pasar_pantalla_completa;
    end else begin
      cambiar_video;
      if main_vars.tipo_maquina<7 then begin
        fillchar(var_spectrum.buffer_video[0],6144,1);
        fillchar(borde.buffer[0],78000,$80);
      end;
    end;
end;
Windows.SetFocus(child.Handle);
end;

procedure Tprincipal1.fLoadCartucho(Sender: TObject);
begin
timer1.Enabled:=false;
EmuStatusTemp:=EmuStatus;
EmuStatus:=EsPause;
if @llamadas_maquina.cartuchos<>nil then
  if not(llamadas_maquina.cartuchos) then MessageDlg('ROM/Cartucho/Snapshot no valido'+chr(10)+chr(13)+'ROM/Cartrigde/Snapshot not valid',mtError,[mbOk],0);
timer4.Enabled:=true;
end;

procedure Tprincipal1.fLoadCinta(Sender: TObject);
begin
timer1.Enabled:=false;
EmuStatusTemp:=EmuStatus;
EmuStatus:=EsPause;
if @llamadas_maquina.cintas<>nil then
  if not(llamadas_maquina.cintas) then MessageDlg('Cinta/Snapshot no valido'+chr(10)+chr(13)+'Tape/Snapshot not valid',mtError,[mbOk],0);
timer4.Enabled:=true;
end;

procedure Tprincipal1.fConfigurar(Sender: TObject);
begin
if (@llamadas_maquina.configurar=nil) then begin
    Windows.SetFocus(child.Handle);
    exit;
end;
timer1.Enabled:=false;
EmuStatusTemp:=EmuStatus;
EmuStatus:=EsPause;
llamadas_maquina.configurar;
timer4.Enabled:=true;
end;

end.
