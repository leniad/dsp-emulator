unit principal;
//{$SetPeFlags $20}
//{$DEFINE FINAL}
interface

uses
  lib_sdl2,Windows,SysUtils,Forms,graphics,uchild,Classes,Dialogs,StdCtrls,ExtCtrls,
  Buttons,Grids,ComCtrls,Menus,ImgList,Controls,messages,System.ImageList,
  //graphics
  jpeg,gifimg,pngimage,
  //misc
  poke_spectrum,main_engine,sound_engine,tape_window,lenguaje,init_games,
  controls_engine,LoadRom,config_general,timer_engine,misc_functions,
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
    consonido1: TMenuItem;
    BombJackHW: TMenuItem;
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
    BitBtn5: TBitBtn;
    BitBtn6: TBitBtn;
    btncfg: TBitBtn;
    BitBtn8: TBitBtn;
    gng1: TMenuItem;
    German1: TMenuItem;
    Mikie1: TMenuItem;
    Shaolin1: TMenuItem;
    Yiear1: TMenuItem;
    AsteroidsHW1: TMenuItem;
    Z801: TMenuItem;
    M65021: TMenuItem;
    M68091: TMenuItem;
    SonSon1: TMenuItem;
    BitBtn19: TBitBtn;
    SenjyoHW1: TMenuItem;
    Rygar1: TMenuItem;
    PitfallII1: TMenuItem;
    Pooyan1: TMenuItem;
    Jungler1: TMenuItem;
    CityCon1: TMenuItem;
    BurgerTimeHW1: TMenuItem;
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
    PopeyeHW1: TMenuItem;
    Psychic51: TMenuItem;
    Brazil1: TMenuItem;
    M680001: TMenuItem;
    TerraCreHW1: TMenuItem;
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
    SnowBrosHW1: TMenuItem;
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
    Dec8HW1: TMenuItem;
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
    kyugohw1: TMenuItem;
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
    TimePilot1: TMenuItem;
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
    ddragon3_HW: TMenuItem;
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
    CentipedeHW1: TMenuItem;
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
    HyperSportsHW1: TMenuItem;
    HyperSports1: TMenuItem;
    Megazone1: TMenuItem;
    spacefb1: TMenuItem;
    Ajax1: TMenuItem;
    Xevious1: TMenuItem;
    ddragon31: TMenuItem;
    ctribe1: TMenuItem;
    BitBtn3: TBitBtn;
    Asteroids1: TMenuItem;
    llander1: TMenuItem;
    CrushRoller1: TMenuItem;
    Vendetta1: TMenuItem;
    GauntletHW1: TMenuItem;
    Gauntlet1: TMenuItem;
    Sauro1: TMenuItem;
    cclimber1: TMenuItem;
    retofinv1: TMenuItem;
    GameandWatch1: TMenuItem;
    DonkeyKongjr1: TMenuItem;
    DonkeyKongII1: TMenuItem;
    MarioBros1: TMenuItem;
    TetrisAtari1: TMenuItem;
    SNK1: TMenuItem;
    Ikari1: TMenuItem;
    Athena1: TMenuItem;
    tnk31: TMenuItem;
    AtariSystem11: TMenuItem;
    peterpak1: TMenuItem;
    Gaunt21: TMenuItem;
    WilliamsHW1: TMenuItem;
    Defender1: TMenuItem;
    ddragon_sh1: TMenuItem;
    Mayday1: TMenuItem;
    Colony71: TMenuItem;
    Bosconian1: TMenuItem;
    SG10001: TMenuItem;
    SegaSystemE1: TMenuItem;
    HangOnJr1: TMenuItem;
    SlapShooter1: TMenuItem;
    FantasyZone21: TMenuItem;
    OpaOpa1: TMenuItem;
    tetrisse1: TMenuItem;
    transformer1: TMenuItem;
    riddleofp1: TMenuItem;
    Route16HW1: TMenuItem;
    Route161: TMenuItem;
    SpeakandRescue1: TMenuItem;
    gwarrior1: TMenuItem;
    Salamander1: TMenuItem;
    BadLands1: TMenuItem;
    indydoom1: TMenuItem;
    MarbleMadness1: TMenuItem;
    TerraCre1: TMenuItem;
    Amazon1: TMenuItem;
    GalivanHW1: TMenuItem;
    Galivan1: TMenuItem;
    Dangar1: TMenuItem;
    LastDuelHW1: TMenuItem;
    LastDuel1: TMenuItem;
    MadGear1: TMenuItem;
    leds20111: TMenuItem;
    c641: TMenuItem;
    Gigas1: TMenuItem;
    Gigasm21: TMenuItem;
    Omega1: TMenuItem;
    pbillrd1: TMenuItem;
    ArmedFHW1: TMenuItem;
    ArmedF1: TMenuItem;
    TerraForce1: TMenuItem;
    CrazyClimber21: TMenuItem;
    Legion1: TMenuItem;
    SegaGG1: TMenuItem;
    aso1: TMenuItem;
    Firetrap1: TMenuItem;
    puzzle3x3HW: TMenuItem;
    puzzle3x31: TMenuItem;
    Casanova1: TMenuItem;
    N1945KIII1: TMenuItem;
    N1945K32: TMenuItem;
    flagrall1: TMenuItem;
    BloodBrosHW1: TMenuItem;
    BloodBros1: TMenuItem;
    SkySmasher1: TMenuItem;
    BaradukeHW1: TMenuItem;
    Baraduke1: TMenuItem;
    MetroCross1: TMenuItem;
    returnishtar1: TMenuItem;
    genpeitd1: TMenuItem;
    wndrmomo1: TMenuItem;
    SegaSystem16BHW1: TMenuItem;
    AlteredBeast1: TMenuItem;
    GoldenAxe1: TMenuItem;
    DynamiteDux1: TMenuItem;
    eswat1: TMenuItem;
    PassingShot1: TMenuItem;
    Aurail1: TMenuItem;
    oaplan1HW1: TMenuItem;
    Hellfire1: TMenuItem;
    scv1: TMenuItem;
    BurgerTime1: TMenuItem;
    lnc1: TMenuItem;
    mmonkey1: TMenuItem;
    KarateChamp1: TMenuItem;
    SetaHW1: TMenuItem;
    thundercade1: TMenuItem;
    twineagle1: TMenuItem;
    thunderl1: TMenuItem;
    mspactwin1: TMenuItem;
    exterm1: TMenuItem;
    robokid1: TMenuItem;
    genesis1: TMenuItem;
    MrDoCasttleHW1: TMenuItem;
    MrDoCastle1: TMenuItem;
    DoRunRun1: TMenuItem;
    dowild1: TMenuItem;
    jjack1: TMenuItem;
    KickRider1: TMenuItem;
    idsoccer1: TMenuItem;
    ccastles1: TMenuItem;
    Flower1: TMenuItem;
    SlySpy1: TMenuItem;
    bdash1: TMenuItem;
    spdodgeb1: TMenuItem;
    Senjyo1: TMenuItem;
    StarForce1: TMenuItem;
    Baluba1: TMenuItem;
    Joust1: TMenuItem;
    Robotron1: TMenuItem;
    Stargate1: TMenuItem;
    MCR1: TMenuItem;
    tapper1: TMenuItem;
    Image2: TImage;
    Arkanoid1: TMenuItem;
    SideArms1: TMenuItem;
    SpeedRumbler1: TMenuItem;
    ChinaGate1: TMenuItem;
    MagMax1: TMenuItem;
    Repulse1: TMenuItem;
    SRDMission1: TMenuItem;
    Airwolf1: TMenuItem;
    Ambush1: TMenuItem;
    SuperDuck1: TMenuItem;
    HangOnHW1: TMenuItem;
    HangOn1: TMenuItem;
    EnduroRacer1: TMenuItem;
    SpaceHarrier1: TMenuItem;
    N64thStreet1: TMenuItem;
    ShadowWarriorsHW1: TMenuItem;
    ShadowWarriors1: TMenuItem;
    wildfang1: TMenuItem;
    Raiden1: TMenuItem;
    winsHW1: TMenuItem;
    twins1: TMenuItem;
    twinsed1: TMenuItem;
    HotBlock1: TMenuItem;
    angerine1: TMenuItem;
    Oric1_1: TMenuItem;
    OricAtmos1: TMenuItem;
    MissileCommandHW1: TMenuItem;
    MissileCommand1: TMenuItem;
    SuperMissileAttack1: TMenuItem;
    SuperZaxxon1: TMenuItem;
    FutureSpy1: TMenuItem;
    Centipede1: TMenuItem;
    Millipede1: TMenuItem;
    Gaplus1: TMenuItem;
    SuperXevious1: TMenuItem;
    Grobda1: TMenuItem;
    PacnPal1: TMenuItem;
    pv1000: TMenuItem;
    pv2000: TMenuItem;
    Birdiy1: TMenuItem;
    M63HW1: TMenuItem;
    WilyTower1: TMenuItem;
    FightingBasketball1: TMenuItem;
    Diverboy1: TMenuItem;
    MugSmashers1: TMenuItem;
    SteelForceHW1: TMenuItem;
    SteelForce1: TMenuItem;
    twinbrats1: TMenuItem;
    MortalRace1: TMenuItem;
    BankPanicHW1: TMenuItem;
    BankPanic1: TMenuItem;
    CombatHawk1: TMenuItem;
    AntEater1: TMenuItem;
    AppooohHW1: TMenuItem;
    Appoooh1: TMenuItem;
    RoboWres1: TMenuItem;
    ArmoredCar1: TMenuItem;
    N88Games1: TMenuItem;
    Avengers1: TMenuItem;
    TheEnd1: TMenuItem;
    BattleofAtlantis1: TMenuItem;
    DooyongHW1: TMenuItem;
    BlueHawk1: TMenuItem;
    LastDay1: TMenuItem;
    GulfStorm1: TMenuItem;
    Pollux1: TMenuItem;
    FlyingTiger1: TMenuItem;
    Popeye1: TMenuItem;
    SkySkipper1: TMenuItem;
    BluePrintHW1: TMenuItem;
    BLuePrint1: TMenuItem;
    Saturn1: TMenuItem;
    Grasspin1: TMenuItem;
    UnicoHW1: TMenuItem;
    BurglarX1: TMenuItem;
    ZeroPoint1: TMenuItem;
    Calipso1: TMenuItem;
    Gardia1: TMenuItem;
    Cavelon1: TMenuItem;
    SnowBros1: TMenuItem;
    ComeBackToto1: TMenuItem;
    HyperPacman1: TMenuItem;
    BombJack1: TMenuItem;
    CalorieKun1: TMenuItem;
    KiKiKaiKaiHW1: TMenuItem;
    KiKiKaiKai1: TMenuItem;
    KickandRun1: TMenuItem;
    LassoHW1: TMenuItem;
    Lasso1: TMenuItem;
    Chameleon1: TMenuItem;
    SRD1: TMenuItem;
    LastMission1: TMenuItem;
    Shackled1: TMenuItem;
    Gondomania1: TMenuItem;
    GaryoRetsuden1: TMenuItem;
    CaptainSilver1: TMenuItem;
    CobraCommand1: TMenuItem;
    Ghostbusters1: TMenuItem;
    oscar1: TMenuItem;
    RoadFighter1: TMenuItem;
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
{$IFDEF WINDOWS}
{$IFDEF FINAL}
SetPriorityClass(GetCurrentProcess, NORMAL_PRIORITY_CLASS);
SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_HIGHEST);
{$ENDIF}
{$ENDIF}
Init_sdl_lib;
timers:=timer_eng.create;
EmuStatus:=EsStoped;
main_vars.cadena_dir:='\';
directory.Base:=ExtractFilePath(application.ExeName);
file_ini_load;
if not DirectoryExists(Directory.Preview) then CreateDir(Directory.Preview);
if not DirectoryExists(Directory.Arcade_nvram) then CreateDir(Directory.Arcade_nvram);
if not DirectoryExists(directory.qsnapshot) then CreateDir(directory.qsnapshot);
leer_idioma;
cambiar_idioma(main_vars.idioma);
fix_screen_pos(415,325);
case main_screen.video_mode of
  1,3,5,6:begin
        principal1.Left:=(screen.Width div 2)-(principal1.Width div 2);
        principal1.Top:=(screen.Height div 2)-(principal1.Height div 2);
      end;
  2,4:begin
        principal1.Left:=(screen.Width div 2)-principal1.Width;
        principal1.Top:=(screen.Height div 2)-principal1.Height;
      end;
end;
//No puedo evitar este timer... Hasta que no está creada la ventana de la aplicacion no puedo crear la ventana interior
principal1.timer2.Enabled:=true;
end;

procedure Tprincipal1.Ejecutar1Click(Sender: TObject);
begin
principal1.BitBtn3.Glyph:=nil;
if EmuStatus=EsRunning then begin //Cambiar a pausa
  timer1.Enabled:=false;
  EmuStatus:=EsPause;
  principal1.imagelist2.GetBitmap(5,principal1.BitBtn3.Glyph);
  principal1.BitBtn3.Hint:=leng[main_vars.idioma].hints[1];
end else begin //Cambiar a play
  EmuStatus:=EsRunning;
  timer1.Enabled:=true;
  principal1.imagelist2.GetBitmap(6,principal1.BitBtn3.Glyph);
  principal1.BitBtn3.Hint:=leng[main_vars.idioma].hints[2];
  if @llamadas_maquina.bucle_general<>nil then begin
    if not(main_screen.pantalla_completa) then Windows.SetFocus(child.Handle);
    llamadas_maquina.bucle_general;
  end;
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
  //Pongo la emulacion en pausa para que terminen todos los procesos, y luego ejecuto el timer3 para cambio de driver
  if main_vars.driver_ok then EmuStatus:=EsPause;
  tipo_new:=tipo;
  timer3.Enabled:=true;
end;
end;

//Timer para poner mensajes...
procedure Tprincipal1.Timer1Timer(Sender: TObject);
var
  velocidad:word;
begin
velocidad:=trunc((main_vars.frames_sec*100)/llamadas_maquina.fps_max);
statusbar1.Panels[0].Text:='FPS: '+inttostr(main_vars.frames_sec);
statusbar1.panels[1].text:=leng[main_vars.idioma].mensajes[0]+': '+inttostr(velocidad)+'%';
statusbar1.Panels[2].Text:=main_vars.mensaje_principal;
main_vars.frames_sec:=0;
end;

//Inicializar DSP...
procedure Tprincipal1.Timer2Timer(Sender: TObject);
var
  tipo:word;
begin
timer2.Enabled:=false;
if SDL_WasInit(libSDL_INIT_VIDEO)=0 then begin
  SDL_SetHint(libSDL_HINT_JOYSTICK_ALLOW_BACKGROUND_EVENTS,'1');
  if (SDL_init(libSDL_INIT_VIDEO or libSDL_INIT_JOYSTICK or libSDL_INIT_NOPARACHUTE)<0) then begin
    MessageDlg('SDL2 library can not be initialized.', mtError,[mbOk], 0);
    halt(0);
  end;
  controls_start;
end;
Child:=TfrChild.Create(application);
child.Width:=1;
child.Height:=1;
principal1.Caption:=principal1.Caption+DSP_VERSION;
tipo:=main_vars.tipo_maquina;
main_vars.tipo_maquina:=$ffff;
if not(main_vars.auto_exec) then begin
  principal1.LstRomsClick(nil);
  exit;
end;
load_game(tipo);
end;

//Cambio de maquina...
procedure Tprincipal1.Timer3Timer(Sender: TObject);
begin
timer3.Enabled:=false;
if ((@llamadas_maquina.close<>nil) and main_vars.driver_ok) then llamadas_maquina.close;
sound_engine_close;
main_vars.tipo_maquina:=tipo_new;
reset_dsp;
cargar_maquina(main_vars.tipo_maquina);
main_vars.driver_ok:=false;
if @llamadas_maquina.iniciar<>nil then main_vars.driver_ok:=llamadas_maquina.iniciar;
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
  timers.autofire_init;
  QueryPerformanceFrequency(cont_micro);
  valor_sync:=(1/llamadas_maquina.fps_max)*cont_micro;
  QueryPerformanceCounter(cont_sincroniza);
  principal1.BitBtn3.Glyph:=nil;
  principal1.imagelist2.GetBitmap(6,principal1.BitBtn3.Glyph);
  timer1.Enabled:=true;
  principal1.Enabled:=true;
  EmuStatus:=EsRunning;
  if not(main_screen.pantalla_completa) then Windows.SetFocus(child.Handle);
  llamadas_maquina.bucle_general;
end;
end;

//Continuar con la emulacion...
procedure restart_emu;
begin
principal1.Enabled:=true;
if not(main_screen.pantalla_completa) then Windows.SetFocus(child.Handle);
if main_vars.driver_ok then begin
  EmuStatus:=EsRunning;
  principal1.timer1.Enabled:=true;
  llamadas_maquina.bucle_general;
end;
end;

procedure Tprincipal1.CambiaAudio(Sender: TObject);
var
  tmp_audio:byte;
begin
if sound_status.hay_tsonido then begin
  if sender<>nil then tmp_audio:=Tmenuitem(sender).Tag
    else tmp_audio:=byte(sound_status.hay_sonido);
  case tmp_audio of
    0:if sound_status.hay_sonido then begin ////No sound
        SinSonido1.Checked:=true;
        ConSonido1.Checked:=false;
        sound_status.hay_sonido:=false;
      end;
    1:if not(sound_status.hay_sonido) then begin //Sound
        SinSonido1.Checked:=false;
        ConSonido1.Checked:=true;
        sound_status.hay_sonido:=true;
      end;
  end;
end;
if not(main_screen.pantalla_completa) then Windows.SetFocus(child.Handle);
end;

procedure Tprincipal1.Reset1Click(Sender: TObject);
begin
main_vars.mensaje_principal:='';
if @llamadas_maquina.reset<>nil then llamadas_maquina.reset;
if not(main_screen.pantalla_completa) then Windows.SetFocus(child.Handle);
end;

procedure Tprincipal1.Acercade1Click(Sender: TObject);
begin
aboutbox.showmodal;
end;

procedure Tprincipal1.Salir1Click(Sender: TObject);
begin
close;
end;

procedure Tprincipal1.IdiomaClick(Sender: TObject);
var
  tmp_idioma:byte;
begin
if sender<>nil then tmp_idioma:=Tmenuitem(sender).tag
  else begin
    tmp_idioma:=main_vars.idioma;
    main_vars.idioma:=255;
  end;
if main_vars.idioma<>tmp_idioma then begin
  main_vars.idioma:=tmp_idioma;
  cambiar_idioma(main_vars.idioma);
end;
if not(main_screen.pantalla_completa) then Windows.SetFocus(child.Handle);
end;

procedure Tprincipal1.LstRomsClick(Sender: TObject);
begin
FLoadRom.Showmodal;
end;

procedure Tprincipal1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
timer1.Enabled:=false;
EmuStatus:=EsPause;
if cinta_tzx.cargada then vaciar_cintas;
if ((@llamadas_maquina.close<>nil) and main_vars.driver_ok) then llamadas_maquina.close;
sound_engine_close;
reset_dsp;
file_ini_save;
close_joystick;
SDL_DestroyWindow(window_render);
SDL_VideoQuit;
SDL_Quit;
close_sdl_lib;
halt(0);
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
MConfig.Showmodal;
end;

procedure Tprincipal1.fSaveGif(Sender: TObject);
var
  r:integer;
  nombre:string;
  indice,tempb:byte;
  nombre2:ansistring;
  rect2:libsdl_rect;
  temp_s:libsdlP_Surface;
  gif:tgifimage;
  png:TPngImage;
  JPG:TJPEGImage;
  imagen1:tbitmap;
begin
principal1.Enabled:=false;
timer1.Enabled:=false;
EmuStatus:=EsPause;
if saverom(nombre,indice,SBITMAP) then begin
  case indice of
    1:nombre:=ChangeFileExt(nombre,'.png');
    2:nombre:=ChangeFileExt(nombre,'.jpg');
    3:nombre:=ChangeFileExt(nombre,'.gif');
  end;
  if FileExists(nombre) then begin
    r:=MessageBox(0,pointer(leng[main_vars.idioma].mensajes[3]), pointer(leng[main_vars.idioma].mensajes[6]), MB_YESNO or MB_ICONWARNING);
    if r=IDNO then begin
      restart_emu;
      exit;
    end;
    deletefile(nombre);
  end;
  Directory.spectrum_image:=ExtractFilePath(nombre);
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
restart_emu;
end;

procedure Tprincipal1.ffastload(Sender: TObject);
begin
var_spectrum.fastload:=not(var_spectrum.fastload);
BitBtn14.Glyph:=nil;
if var_spectrum.fastload then begin
  principal1.imagelist2.GetBitmap(0,principal1.BitBtn14.Glyph);
  cinta_tzx.stop_tap:=true;
end else begin
  principal1.imagelist2.GetBitmap(1,principal1.BitBtn14.Glyph);
  cinta_tzx.stop_tap:=false;
end;
if not(main_screen.pantalla_completa) then Windows.SetFocus(child.Handle);
end;

procedure Tprincipal1.fSlow(Sender: TObject);
begin
main_vars.vactual:=(main_vars.vactual+1) and 3;
valor_sync:=(1/(llamadas_maquina.fps_max/(main_vars.vactual+1)))*cont_micro;
if not(main_screen.pantalla_completa) then Windows.SetFocus(child.Handle);
end;

procedure Tprincipal1.fFast(Sender: TObject);
begin
main_screen.rapido:=not(main_screen.rapido);
QueryPerformanceCounter(cont_sincroniza);
if not(main_screen.pantalla_completa) then Windows.SetFocus(child.Handle);
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
        Windows.SetFocus(child.Handle);
      end;
end;
end;

procedure Tprincipal1.fLoadCartucho(Sender: TObject);
begin
principal1.Enabled:=false;
timer1.Enabled:=false;
EmuStatus:=EsPause;
if @llamadas_maquina.cartuchos<>nil then llamadas_maquina.cartuchos;
restart_emu;
end;

procedure Tprincipal1.fLoadCinta(Sender: TObject);
begin
principal1.Enabled:=false;
timer1.Enabled:=false;
EmuStatus:=EsPause;
if @llamadas_maquina.cintas<>nil then llamadas_maquina.cintas;
restart_emu;
end;

procedure Tprincipal1.fConfigurar(Sender: TObject);
begin
if (@llamadas_maquina.configurar=nil) then begin
    if not(main_screen.pantalla_completa) then Windows.SetFocus(child.Handle);
    exit;
end;
principal1.Enabled:=false;
timer1.Enabled:=false;
EmuStatus:=EsPause;
llamadas_maquina.configurar;
restart_emu;
end;

procedure Tprincipal1.fSaveSnapShot(Sender: TObject);
begin
principal1.Enabled:=false;
timer1.Enabled:=false;
EmuStatus:=EsPause;
if @llamadas_maquina.grabar_snapshot<>nil then llamadas_maquina.grabar_snapshot;
restart_emu;
end;

end.
