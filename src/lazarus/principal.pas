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
     init_games,tape_window,timer_engine,misc_functions,
     //Devices
     vars_hide;

type

  { Tprincipal1 }
  Tprincipal1 = class(TForm)
    BitBtn1: TBitBtn;
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
    BitBtn5: TBitBtn;
    BitBtn6: TBitBtn;
    BitBtn8: TBitBtn;
    BitBtn9: TBitBtn;
    btncfg: TBitBtn;
    Edit1: TEdit;
    GroupBox1: TGroupBox;
    Image1: TImage;
    ImageList2: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    leds20111: TMenuItem;
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
    Configuracion1: TMenuItem;
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
    AsteroidsHW1: TMenuItem;
    bt1: TMenuItem;
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
    ddragon3_hw: TMenuItem;
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
    Gradius31: TMenuItem;
    centipede1: TMenuItem;
    MenuItem29: TMenuItem;
    karnov1: TMenuItem;
    chelnov1: TMenuItem;
    MenuItem30: TMenuItem;
    aliens1: TMenuItem;
    MenuItem31: TMenuItem;
    gbusters1: TMenuItem;
    MenuItem32: TMenuItem;
    hypersports1: TMenuItem;
    Megazone1: TMenuItem;
    ajax1: TMenuItem;
    ddragon31: TMenuItem;
    ctribe1: TMenuItem;
    Asteroids1: TMenuItem;
    llander1: TMenuItem;
    crushroller1: TMenuItem;
    MenuItem33: TMenuItem;
    gauntlet1: TMenuItem;
    cclimber1: TMenuItem;
    MenuItem34: TMenuItem;
    donkeykongii1: TMenuItem;
    donkeykongjr1: TMenuItem;
    mariobros1: TMenuItem;
    MenuItem35: TMenuItem;
    ikari1: TMenuItem;
    athena1: TMenuItem;
    MenuItem36: TMenuItem;
    gaunt21: TMenuItem;
    MenuItem37: TMenuItem;
    defender1: TMenuItem;
    ddragon_sh1: TMenuItem;
    mayday1: TMenuItem;
    colony71: TMenuItem;
    Bosconian1: TMenuItem;
    FantasyZone21: TMenuItem;
    Amazon1: TMenuItem;
    GalivanHW1: TMenuItem;
    Galivan1: TMenuItem;
    dangar1: TMenuItem;
    gwarrior1: TMenuItem;
    indydoom1: TMenuItem;
    MarbleMadness1: TMenuItem;
    BadLands1: TMenuItem;
    lastduelhw: TMenuItem;
    lasduel1: TMenuItem;
    madgear1: TMenuItem;
    lastduel1: TMenuItem;
    c641: TMenuItem;
    gigas1: TMenuItem;
    gigasm21: TMenuItem;
    MenuItem38: TMenuItem;
    armedf1: TMenuItem;
    crazyclimber21: TMenuItem;
    Legion1: TMenuItem;
    aso1: TMenuItem;
    firetrap1: TMenuItem;
    MenuItem39: TMenuItem;
    casanova1: TMenuItem;
    MenuItem40: TMenuItem;
    flagrall1: TMenuItem;
    MenuItem41: TMenuItem;
    bloodbros1: TMenuItem;
    MenuItem42: TMenuItem;
    baraduke1: TMenuItem;
    genpeitd1: TMenuItem;
    MenuItem43: TMenuItem;
    alteredbeast1: TMenuItem;
    goldenaxe1: TMenuItem;
    dynamitedux1: TMenuItem;
    eswat1: TMenuItem;
    aurail1: TMenuItem;
    MenuItem44: TMenuItem;
    Hellfire1: TMenuItem;
    BurgerTime1: TMenuItem;
    lnc1: TMenuItem;
    karatechamp1: TMenuItem;
    exterm1: TMenuItem;
    genesis1: TMenuItem;
    DoRunRun1: TMenuItem;
    dowild1: TMenuItem;
    jjack1: TMenuItem;
    KickRider1: TMenuItem;
    idsoccer1: TMenuItem;
    ccastles1: TMenuItem;
    flower1: TMenuItem;
    StarForce1: TMenuItem;
    baluba1: TMenuItem;
    senjyo1: TMenuItem;
    spdodgeb1: TMenuItem;
    slyspy1: TMenuItem;
    bdash1: TMenuItem;
    MrDoCastle1: TMenuItem;
    mrdocastlehw: TMenuItem;
    robokid1: TMenuItem;
    mspactwin1: TMenuItem;
    twineagle1: TMenuItem;
    thunderl1: TMenuItem;
    thundercade1: TMenuItem;
    Setahw1: TMenuItem;
    mmonkey1: TMenuItem;
    scv1: TMenuItem;
    passingshot1: TMenuItem;
    wndrmomo1: TMenuItem;
    returnishtar1: TMenuItem;
    metrocross1: TMenuItem;
    skysmasher1: TMenuItem;
    N1945K32: TMenuItem;
    puzzle3x31: TMenuItem;
    Panel2: TPanel;
    segagg1: TMenuItem;
    terraforce1: TMenuItem;
    pbillrd1: TMenuItem;
    omega1: TMenuItem;
    Salamander1: TMenuItem;
    TerraCre1: TMenuItem;
    SpeakandRescue1: TMenuItem;
    riddleofp1: TMenuItem;
    OpaOpa1: TMenuItem;
    tetrisse1: TMenuItem;
    transformer1: TMenuItem;
    segasysteme1: TMenuItem;
    Route16HW1: TMenuItem;
    HangOnJr1: TMenuItem;
    SlapShooter1: TMenuItem;
    Route161: TMenuItem;
    sg10001: TMenuItem;
    peterpak1: TMenuItem;
    tnk31: TMenuItem;
    tetrisatari1: TMenuItem;
    retofinv1: TMenuItem;
    sauro1: TMenuItem;
    Vendetta1: TMenuItem;
    xevious1: TMenuItem;
    spacefb1: TMenuItem;
    trackfield1: TMenuItem;
    simpsons1: TMenuItem;
    thunderx1: TMenuItem;
    scontra1: TMenuItem;
    spaceinvaders1: TMenuItem;
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
    TerraCreHW1: TMenuItem;
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
    SenjyoHW: TMenuItem;
    Pacmanhw1: TMenuItem;
    PhoenixHW: TMenuItem;
    Z801: TMenuItem;
    Ordenadores8bits1: TMenuItem;
    N3X1: TMenuItem;
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
    Panel1: TPanel;
    Timer1: TTimer;
    Timer2: TTimer;
    procedure Acercade1Click(Sender: TObject);
    procedure BitBtn12Click(Sender: TObject);
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
  public
    { public declarations }
  end;
  procedure sync_all;

var
  principal1: Tprincipal1;

implementation
uses tap_tzx,spectrum_misc,acercade,lenslock,file_engine;
var
  //Misc Vars
  tipo_new:word;
  //Status bitmap
  status_bitmap:tbitmap;

{ Tprincipal1 }
procedure sync_all;
begin
if window_render<>nil then begin
   if not(main_screen.pantalla_completa) then sdl_raisewindow(window_render);
   cont_sincroniza:=sdl_getticks();
   valor_sync:=1000/llamadas_maquina.fps_max;
   cont_micro:=valor_sync;
   SDL_ClearQueuedAudio(sound_device);
end;
end;

procedure Tprincipal1.fSaveGIF(Sender: TObject);
var
  r:integer;
  nombre:string;
  indice:byte;
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
if SaveRom(StBitmap,nombre,indice) then begin
  case indice of
    1:nombre:=ChangeFileExt(nombre,'.png');
    2:nombre:=ChangeFileExt(nombre,'.jpg');
    3:nombre:=ChangeFileExt(nombre,'.gif');
  end;
  if FileExists(nombre) then begin
    r:=application.messagebox(pansichar(leng[main_vars.idioma].mensajes[3]),pansichar(leng[main_vars.idioma].mensajes[6]), MB_YESNO or MB_ICONWARNING);
    if r=IDNO then begin
       sync_all;
       exit;
    end;
    deletefile(nombre);
  end;
  Directory.spectrum_image:=extractfiledir(nombre)+main_vars.cadena_dir;
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
  case indice of
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
sync_all;
end;

procedure Tprincipal1.Timer1Timer(Sender: TObject);
var
  velocidad:integer;
begin
statusbar1.Panels[2].Text:=main_vars.mensaje_principal;
velocidad:=round((main_vars.frames_sec*100)/llamadas_maquina.fps_max);
statusbar1.Panels[0].Text:='FPS: '+inttostr(main_vars.frames_sec);
statusbar1.panels[1].text:=leng[main_vars.idioma].mensajes[0]+': '+inttostr(velocidad)+'%';
main_vars.frames_sec:=0;
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

procedure Tprincipal1.FormCreate(Sender: TObject);
{$ifdef darwin}
var
  cadena:string;f:word;count:byte;
{$endif}
begin
{$ifdef windows}
//SetPriorityClass(GetCurrentProcess, NORMAL_PRIORITY_CLASS);
//SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_HIGHEST);
main_vars.cadena_dir:='\';
{$else}
main_vars.cadena_dir:='/';
{$endif}
Init_sdl_lib;
timers:=timer_eng.create;
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
file_ini_load;
if not DirectoryExists(Directory.Preview) then CreateDir(Directory.Preview);
if not DirectoryExists(Directory.Arcade_nvram) then CreateDir(Directory.Arcade_nvram);
if not DirectoryExists(directory.qsnapshot) then CreateDir(directory.qsnapshot);
leer_idioma;
principal1.idiomaclick(nil);
principal1.timer2.Enabled:=true;
end;

procedure Tprincipal1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
timer1.Enabled:=false;
EmuStatus:=EsPause;
if cinta_tzx.cargada then vaciar_cintas;
if ((addr(llamadas_maquina.close)<>nil) and main_vars.driver_ok) then llamadas_maquina.close;
reset_dsp;
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
  else exit;
if main_screen.video_mode=nuevo then exit;
if main_vars.driver_ok then begin
    if nuevo=6 then pasar_pantalla_completa
      else begin
        main_screen.old_video_mode:=main_screen.video_mode;
        main_screen.video_mode:=nuevo;
        cambiar_video;
        sync_all;
      end;
end;
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

procedure Tprincipal1.BitBtn12Click(Sender: TObject);
begin
//Nada de momento...
//focus
end;

procedure Tprincipal1.BitBtn14Click(Sender: TObject);
begin
var_spectrum.fastload:=not(var_spectrum.fastload);
BitBtn14.Glyph:=nil;
if var_spectrum.fastload then principal1.imagelist2.GetBitmap(0,principal1.BitBtn14.Glyph)
  else imagelist2.GetBitmap(1,principal1.BitBtn14.Glyph);
sync_all;
end;

procedure Tprincipal1.BitBtn8Click(Sender: TObject);
begin
if @llamadas_maquina.configurar=nil then begin
   sync_all;
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
principal1.BitBtn3.Glyph:=nil;
if emustatus=EsRuning then begin
   principal1.imagelist2.GetBitmap(5,principal1.BitBtn3.Glyph);
   timer1.Enabled:=false;
   EmuStatus:=EsPause;
   SDL_ClearQueuedAudio(sound_device);
   SDL_PauseAudioDevice(sound_device,1);
end else begin
   principal1.imagelist2.GetBitmap(6,principal1.BitBtn3.Glyph);
   EmuStatus:=EsRuning;
   timer1.Enabled:=true;
   SDL_PauseAudioDevice(sound_device,0);
   sync_all;
end;
if addr(llamadas_maquina.bucle_general)<>nil then llamadas_maquina.bucle_general();
end;

procedure Tprincipal1.fSlow(Sender: TObject);
begin
main_vars.vactual:=(main_vars.vactual+1) and 3;
valor_sync:=1000/(llamadas_maquina.fps_max/(main_vars.vactual+1));
//if not(main_screen.pantalla_completa) then sdl_raisewindow(window_render);
cont_sincroniza:=sdl_getticks();
cont_micro:=valor_sync;
SDL_ClearQueuedAudio(sound_device);
end;

procedure Tprincipal1.fFast(Sender: TObject);
begin
main_screen.rapido:=not(main_screen.rapido);
sync_all;
end;

procedure Tprincipal1.Reset1Click(Sender: TObject);
begin
main_vars.mensaje_principal:='';
if addr(llamadas_maquina.reset)<>nil then llamadas_maquina.reset;
sync_all;
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
sync_all;
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
sync_all;
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
if SDL_WasInit(libSDL_INIT_VIDEO)=0 then
  if (SDL_init(libSDL_INIT_VIDEO or libSDL_INIT_JOYSTICK or libSDL_INIT_NOPARACHUTE or libSDL_INIT_AUDIO)<0) then halt(0);
principal1.Caption:=principal1.Caption+dsp_version;
tipo:=main_vars.tipo_maquina;
main_vars.tipo_maquina:=$ffff;
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
if ((@llamadas_maquina.close<>nil) and main_vars.driver_ok) then llamadas_maquina.close;
main_vars.tipo_maquina:=tipo_new;
reset_dsp;
cargar_maquina(main_vars.tipo_maquina);
//focus
main_vars.driver_ok:=false;
if @llamadas_maquina.iniciar<>nil then main_vars.driver_ok:=llamadas_maquina.iniciar;
timers.autofire_init;
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
  sync_all;
  principal1.ejecutar1click(nil);
end;
end;

procedure Tprincipal1.Timer4Timer(Sender: TObject);
begin
timer4.Enabled:=false;
if not(main_vars.driver_ok) then exit;
EmuStatus:=EmuStatusTemp;
timer1.Enabled:=true;
sync_all;
llamadas_maquina.bucle_general;
end;

initialization
  {$I principal.lrs}

end.

