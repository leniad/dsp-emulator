unit principal;

{$mode delphi}{$H+}
{$ifdef darwin}
        {$linklib SDL2_mixer}
{$endif}

interface

uses lib_sdl2,{$IFDEF WINDOWS}windows,{$else}LCLType,{$endif}
     Classes,SysUtils,FileUtil,LResources,Forms,Controls,
     Graphics,Dialogs,Menus,ExtCtrls,ComCtrls,StdCtrls,Grids,Buttons,
     {$ifndef windows}LMessages,{$endif}
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
    Image2: TImage;
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
    BombJackHW1: TMenuItem;
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
    centipedehw1: TMenuItem;
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
    Joust1: TMenuItem;
    MenuItem45: TMenuItem;
    arkanoid1: TMenuItem;
    chinagate1: TMenuItem;
    magmax1: TMenuItem;
    ambush1: TMenuItem;
    airwolf1: TMenuItem;
    MenuItem46: TMenuItem;
    hangon1: TMenuItem;
    enduroracer1: TMenuItem;
    MenuItem47: TMenuItem;
    MenuItem48: TMenuItem;
    hotblocks1: TMenuItem;
    MenuItem49: TMenuItem;
    MenuItem50: TMenuItem;
    centipede1: TMenuItem;
    Gaplus1: TMenuItem;
    grobda1: TMenuItem;
    birdiy1: TMenuItem;
    MenuItem51: TMenuItem;
    FightingBasketball1: TMenuItem;
    diverboy1: TMenuItem;
    MenuItem52: TMenuItem;
    MenuItem53: TMenuItem;
    bankpanic1: TMenuItem;
    combathawk1: TMenuItem;
    anteater1: TMenuItem;
    MenuItem54: TMenuItem;
    appoooh1: TMenuItem;
    armoredcar1: TMenuItem;
    avengers1: TMenuItem;
    battleofatlantis1: TMenuItem;
    calipso1: TMenuItem;
    cavelon1: TMenuItem;
    MenuItem55: TMenuItem;
    burglarx1: TMenuItem;
    MenuItem56: TMenuItem;
    bluehawk1: TMenuItem;
    lastday1: TMenuItem;
    gulfstorm1: TMenuItem;
    flyingtiger1: TMenuItem;
    MenuItem57: TMenuItem;
    blueprint1: TMenuItem;
    grasspin1: TMenuItem;
    gardia1: TMenuItem;
    hyperpacman1: TMenuItem;
    BombJack1: TMenuItem;
    caloriekun1: TMenuItem;
    MenuItem58: TMenuItem;
    kikikaikai1: TMenuItem;
    kickandrun1: TMenuItem;
    MenuItem59: TMenuItem;
    Lasso1: TMenuItem;
    chameleon1: TMenuItem;
    lastmission1: TMenuItem;
    gondomania1: TMenuItem;
    garyoretsuden1: TMenuItem;
    captainsilver1: TMenuItem;
    cobracommand1: TMenuItem;
    ghostbusters1: TMenuItem;
    eyes1: TMenuItem;
    alibaba1: TMenuItem;
    MenuItem60: TMenuItem;
    finalstarforce1: TMenuItem;
    fireball1: TMenuItem;
    cotton1: TMenuItem;
    dotron1: TMenuItem;
    Auto1: TMenuItem;
    Pausa1: TMenuItem;
    tron1: TMenuItem;
    timber1: TMenuItem;
    shollow1: TMenuItem;
    domino1: TMenuItem;
    wacko1: TMenuItem;
    MenuItem67: TMenuItem;
    nastar1: TMenuItem;
    masterw1: TMenuItem;
    sdi1: TMenuItem;
    RiotCity1: TMenuItem;
    WyvernF01: TMenuItem;
    piranha1: TMenuItem;
    woodpecker1: TMenuItem;
    ponpoko1: TMenuItem;
    roadfighter1: TMenuItem;
    oscar1: TMenuItem;
    shackled1: TMenuItem;
    SRD1: TMenuItem;
    snowbros1: TMenuItem;
    comebacktoto1: TMenuItem;
    popeye1: TMenuItem;
    skyskipper1: TMenuItem;
    saturn1: TMenuItem;
    pollux1: TMenuItem;
    zeropoint1: TMenuItem;
    theend1: TMenuItem;
    n88games1: TMenuItem;
    robowres1: TMenuItem;
    MortalRace1: TMenuItem;
    twinbrats1: TMenuItem;
    steelforce1: TMenuItem;
    mugsmashers1: TMenuItem;
    wilytower1: TMenuItem;
    pv2000: TMenuItem;
    pv1000: TMenuItem;
    pacnpal1: TMenuItem;
    superxevious1: TMenuItem;
    millipede1: TMenuItem;
    superzaxxon1: TMenuItem;
    futurespy1: TMenuItem;
    missilecommand1: TMenuItem;
    supermissileattack1: TMenuItem;
    oric1_1: TMenuItem;
    oricatmos1: TMenuItem;
    twinsed1: TMenuItem;
    Twins1: TMenuItem;
    raiden1: TMenuItem;
    ShadowWarriors1: TMenuItem;
    wildfang1: TMenuItem;
    n64thstreet1: TMenuItem;
    spaceharrier1: TMenuItem;
    superduck1: TMenuItem;
    srdmission1: TMenuItem;
    Repulse1: TMenuItem;
    speedrumbler1: TMenuItem;
    sidearms1: TMenuItem;
    tapper1: TMenuItem;
    robotron1: TMenuItem;
    stargate1: TMenuItem;
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
    tnzs1: TMenuItem;
    kyugohw1: TMenuItem;
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
    dec8_menu: TMenuItem;
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
    SnowBrosHW1: TMenuItem;
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
    PopeyeHW1: TMenuItem;
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
    consonido1: TMenuItem;
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
    procedure BitBtn3Click(Sender: TObject);
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
  private
    { private declarations }
    {$IFDEF WINDOWS}
    procedure WindowMove(var Msg:TWMMove); message WM_MOVE;
    {$else}
    procedure WindowMove(var Msg:TLMMove); message LM_MOVE;
    {$endif}
  public
    { public declarations }
  end;
  procedure sync_all;

var
  principal1: Tprincipal1;

implementation
uses tap_tzx,spectrum_misc,acercade,lenslock,file_engine,arcade_config,
     config,config_cpc,config_sms,config_gb;

var
  //Misc Vars
  tipo_new:word;
  estado_actual:TEmuStatus;

{ Tprincipal1 }
procedure sync_all;
begin
if window_render<>nil then begin
   //if not(main_screen.pantalla_completa) then sdl_raisewindow(window_render);
   cont_sincroniza:=sdl_getticks();
   valor_sync:=1000/llamadas_maquina.fps_max;
   cont_micro:=valor_sync;
   SDL_ClearQueuedAudio(sound_device);
   SDL_RaiseWindow(window_render);
end;
if not(main_screen.pantalla_completa) then sdl_raisewindow(window_render);
end;

//Continuar con la emulacion...
procedure restart_emu;
begin
if not(main_screen.pantalla_completa) then sync_all;
if main_vars.driver_ok then begin
  EmuStatus:=estado_actual;
  llamadas_maquina.bucle_general;
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
estado_actual:=EmuStatus;
EmuStatus:=EsPause;
if saverom(nombre,indice,SBITMAP) then begin
  case indice of
    1:nombre:=ChangeFileExt(nombre,'.png');
    2:nombre:=ChangeFileExt(nombre,'.jpg');
    3:nombre:=ChangeFileExt(nombre,'.gif');
  end;
  if FileExists(nombre) then begin
    r:=application.messagebox(pansichar(leng.mensajes[3]),pansichar(leng.mensajes[6]), MB_YESNO or MB_ICONWARNING);
    if r=IDNO then begin
       restart_emu;
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
restart_emu;
end;

procedure Tprincipal1.IdiomaClick(Sender: TObject);
var
  tmp_idioma:byte;
begin
tmp_idioma:=Tmenuitem(sender).Tag;
if main_vars.idioma<>tmp_idioma then begin
  main_vars.idioma:=tmp_idioma;
  cambiar_idioma(tmp_idioma);
end;
sync_all;
end;

procedure Tprincipal1.Timer1Timer(Sender: TObject);
var
  velocidad:integer;
begin
if EmuStatus=EsRunning then begin
   statusbar1.Panels[2].Text:=main_vars.mensaje_principal;
   velocidad:=round((main_vars.frames_sec*100)/llamadas_maquina.fps_max);
   statusbar1.Panels[0].Text:='FPS: '+inttostr(main_vars.frames_sec);
   statusbar1.panels[1].text:=leng.mensajes[0]+': '+inttostr(velocidad)+'%';
   main_vars.frames_sec:=0;
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
EmuStatus:=EsStoped;
directory.Base:=ExtractFilePath(application.ExeName);
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
cambiar_idioma(main_vars.idioma);
if not DirectoryExists(Directory.Preview) then CreateDir(Directory.Preview);
if not DirectoryExists(Directory.Arcade_nvram) then CreateDir(Directory.Arcade_nvram);
if not DirectoryExists(directory.qsnapshot) then CreateDir(directory.qsnapshot);
case main_screen.video_mode of
  1,3,5:begin
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

procedure Tprincipal1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
timer1.Enabled:=false;
EmuStatus:=EsPause;
if cinta_tzx.cargada then vaciar_cintas;
if ((addr(llamadas_maquina.close)<>nil) and main_vars.driver_ok) then llamadas_maquina.close;
sound_engine_close;
reset_dsp;
file_ini_save;
close_joystick;
sdl_videoquit;
sdl_quit;
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
aboutbox.showmodal;
sync_all;
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
if var_spectrum.fastload then begin
  principal1.imagelist2.GetBitmap(0,principal1.BitBtn14.Glyph);
  cinta_tzx.stop_tap:=true;
end else begin
  principal1.imagelist2.GetBitmap(1,principal1.BitBtn14.Glyph);
  cinta_tzx.stop_tap:=false;
end;
sync_all;
end;

procedure Tprincipal1.BitBtn3Click(Sender: TObject);
begin
if EmuStatus=EsPause then ejecutar1click(nil)
   else pausa1click(nil);
end;

procedure Tprincipal1.BitBtn8Click(Sender: TObject);
begin
case main_vars.tipo_maquina of
  0..5:ConfigSP.showmodal;
  7..9:configcpc.showmodal;
  10..999:config_arcade.showmodal;
  1002:configgb.showmodal;
  1004:SMSConfig.Showmodal;
end;
sync_all;
end;

procedure Tprincipal1.fLoadCinta(Sender: TObject);
begin
estado_actual:=EmuStatus;
EmuStatus:=EsPause;
if addr(llamadas_maquina.cintas)<>nil then llamadas_maquina.cintas;
restart_emu;
end;

procedure Tprincipal1.fSaveSnapShot(Sender: TObject);
begin
estado_actual:=EmuStatus;
EmuStatus:=EsPause;
if addr(llamadas_maquina.grabar_snapshot)<>nil then llamadas_maquina.grabar_snapshot;
restart_emu;
end;

procedure Tprincipal1.Ejecutar1Click(Sender: TObject);
begin
if EmuStatus<>EsRunning then begin
   principal1.BitBtn3.Glyph:=nil;
   principal1.imagelist2.GetBitmap(6,principal1.BitBtn3.Glyph);
   EmuStatus:=EsRunning;
   SDL_PauseAudioDevice(sound_device,0);
   sync_all;
   if @llamadas_maquina.bucle_general<>nil then llamadas_maquina.bucle_general;
end;
end;

procedure Tprincipal1.fSlow(Sender: TObject);
begin
sync_all;
main_vars.vactual:=(main_vars.vactual+1) and 3;
valor_sync:=1000/(llamadas_maquina.fps_max/(main_vars.vactual+1));
cont_micro:=valor_sync;
end;

procedure Tprincipal1.fFast(Sender: TObject);
begin
main_screen.rapido:=not(main_screen.rapido);
sync_all;
end;

procedure Tprincipal1.Reset1Click(Sender: TObject);
begin
main_vars.mensaje_principal:='';
if addr(llamadas_maquina.reset)<>nil then begin
   reset_game_general;
   llamadas_maquina.reset;
end;
sync_all;
end;

procedure Tprincipal1.CambiaAudio(Sender: TObject);
begin
if sound_status.hay_tsonido then begin
  sound_status.sonido_activo:=(Tmenuitem(sender).Tag)<>0;
  sinSonido1.Checked:=not(sound_status.sonido_activo);
  conSonido1.Checked:=sound_status.sonido_activo;
end;
sync_all;
end;

procedure Tprincipal1.fLoadCartucho(Sender: TObject);
begin
estado_actual:=EmuStatus;
EmuStatus:=EsPause;
if addr(llamadas_maquina.cartuchos)<>nil then llamadas_maquina.cartuchos;
restart_emu;
end;

procedure Tprincipal1.LstRomsClick(Sender: TObject);
begin
FLoadRom.Showmodal;
sync_all;
end;

procedure Tprincipal1.Pausa1Click(Sender: TObject);
begin
principal1.BitBtn3.Glyph:=nil;
principal1.imagelist2.GetBitmap(5,principal1.BitBtn3.Glyph);
EmuStatus:=EsPause;
SDL_ClearQueuedAudio(sound_device);
SDL_PauseAudioDevice(sound_device,1);
end;

procedure Tprincipal1.Salir1Click(Sender: TObject);
begin
  principal1.close;
end;

procedure Tprincipal1.Timer2Timer(Sender: TObject);
var
  tipo:word;
  sdl_res:integer;
begin
timer2.Enabled:=false;
sdl_res:=-1;
if SDL_WasInit(libSDL_INIT_VIDEO)=0 then begin
  SDL_SetHint(libSDL_HINT_JOYSTICK_ALLOW_BACKGROUND_EVENTS,'1');
  sdl_res:=SDL_init(libSDL_INIT_VIDEO or libSDL_INIT_JOYSTICK or libSDL_INIT_NOPARACHUTE or libSDL_INIT_AUDIO);
  controls_start;
end;
if sdl_res<0 then begin
   MessageDlg('SDL2 Mixer library not found.'+chr(10)+chr(13)+'Please read the documentation!', mtError,[mbOk], 0);
   halt(0);
end;
principal1.Caption:=principal1.Caption+dsp_version;
tipo:=main_vars.tipo_maquina;
main_vars.tipo_maquina:=$ffff;
if not(main_vars.auto_exec) then principal1.LstRomsClick(nil)
   else load_game(tipo);
end;

procedure Tprincipal1.fConfigurar_general(Sender: TObject);
begin
MConfig.Showmodal;
sync_all;
end;

procedure Tprincipal1.Timer3Timer(Sender: TObject);
begin
timer3.enabled:=false;
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
  if ((marcade.dswa_val=nil) and (marcade.dswa_val2=nil)) then bitbtn8.Enabled:=false
    else bitbtn8.Enabled:=true;
  timers.autofire_init;
  principal1.BitBtn3.Glyph:=nil;
  principal1.imagelist2.GetBitmap(6,principal1.BitBtn3.Glyph);
  timer1.Enabled:=true;
  EmuStatus:=EsRunning;
  sync_all;
  if @llamadas_maquina.reset<>nil then begin
     reset_game_general;
     llamadas_maquina.reset;
  end;
  llamadas_maquina.bucle_general;
end;
end;

{$IFDEF WINDOWS}
procedure Tprincipal1.WindowMove(var Msg:TWMMove);
{$else}
procedure Tprincipal1.WindowMove(var Msg:TLMMove);
{$endif}
begin
if Msg.Result=0 then begin
   if window_render<>nil then begin
      SDL_SetWindowPosition(window_render,Msg.xpos+5,msg.ypos+principal1.Height+panel1.Height+statusbar1.Height+LAZARUS_SCR_POS);
      sync_all;
   end;
end;
end;

initialization
  {$I principal.lrs}

end.

