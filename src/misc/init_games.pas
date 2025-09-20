unit init_games;

interface
uses sysutils,main_engine,rom_engine,rom_export,lenguaje,
  //Computer
  spectrum_48k,spectrum_128k,spectrum_3,amstrad_cpc,commodore64,
  //Console
  nes,coleco,gb,sms,sg1000,sega_gg,super_cassette_vision,
  //Arcade
  phoenix_hw,bombjack_hw,pacman_hw,mysteriousstones_hw,donkeykong_hw,
  greenberet_hw,blacktiger_hw,commando_hw,gng_hw,mikie_hw,shaolinsroad_hw,
  yiearkungfu_hw,asteroids_hw,sonson_hw,starforce_hw,tecmo_hw,system1_hw,
  rallyx_hw,pooyan_hw,cityconnection_hw,burgertime_hw,expressraider_hw,
  superbasketball_hw,ladybug_hw,tehkanworldcup_hw,popeye_hw,psychic5_hw,
  terracresta_hw,m62_hw,shootout_hw,vigilante_hw,jackal_hw,bubblebobble_hw,
  galaxian_hw,prehistoricisle_hw,tigerroad_hw,snowbros_hw,toki_hw,contra_hw,
  mappy_hw,rastan_hw,legendarywings_hw,streetfighter_hw,galaga_hw,xaindsleena_hw,
  suna8_hw,nmk16_hw,knucklejoe_hw,wardner_hw,gaelco_hw,exedexes_hw,gunsmoke_hw,
  hw_1942,jailbreak_hw,circuscharlie_hw,ironhorse_hw,m72_hw,breakthru_hw,
  dec8_hw,doubledragon_hw,mrdo_hw,epos_hw,slapfight_hw,legendkage_hw,cabal_hw,
  cps1_hw,system16a_hw,timepilot84_hw,tutankham_hw,pang_hw,ninjakid2_hw,
  skykid_hw,system86_hw,rocnrope_hw,kyugo_hw,thenewzealandstory_hw,pacland_hw,
  mariobros_hw,solomonkey_hw,combatschool_hw,heavyunit_hw,snk68_hw,megasys1_hw,
  timepilot_hw,pengo_hw,twincobra_hw,jrpacman_hw,dec0_hw,funkyjet_hw,
  superburgertime_hw,cavemanninja_hw,dietgogo_hw,actfancer_hw,
  arabian_hw,higemaru_hw,bagman_hw,chip8_hw,zaxxon_hw,kangaroo_hw,
  bioniccommando_hw,wwfsuperstars_hw,rainbowislands_hw,volfied_hw,
  operationwolf_hw,outrun_hw,taitosj_hw,vulgus_hw,ddragon3_hw,blockout_hw,
  foodfight_hw,nemesis_hw,pirates_hw,junofirst_hw,gyruss_hw,freekick_hw,
  boogiewings_hw,pinballaction_hw,renegade_hw,tmnt_hw,gradius3_hw,
  spaceinvaders_hw,centipede_hw,karnov_hw,aliens_hw,thunderx_hw,simpsons_hw,
  trackandfield_hw,hypersports_hw,megazone_hw,spacefirebird_hw,ajax_hw,
  vendetta_hw,gauntlet_hw,sauro_hw,crazyclimber_hw,returnofinvaders_hw,gnw_510,
  tetris_atari_hw,snk_hw,atari_system1,williams_hw,systeme_hw,route16_hw,
  badlands_hw,galivan_hw,lastduel_hw,armedf_hw,firetrap_hw,hw_3x3puzzle,
  hw_1945k3,bloodbros_hw,baraduke_hw,system16b_hw,toaplan1_hw,karatechamp_hw,
  seta_hw,genesis,mrdocastle_hw,crystalcastles_hw,flower_hw,superdodgeball_hw,
  mcr_hw,arkanoid_hw,sidearms_hw,speedrumbler_hw,chinagate_hw,magmax_hw,
  ambush_hw,superduck_hw,hangon_hw,shadow_warriors_hw,raiden_hw,twins_hw,
  oric_hw,missilecommand_hw,gaplus_hw,pv1000,pv2000,m63_hw,diverboy_hw,
  mugsmashers_hw,steelforce_hw,bankpanic_hw,appoooh_hw,hw_88games,dooyong_hw,
  blueprint_hw,unico_hw,kikikaikai_hw,lasso_hw,finalstarforce_hw,wyvernf0_hw,
  taito_b_hw;

type
  tgame_desc=record
              name,year:string;
              snd:byte;
              hi:boolean;
              zip:string;
              grid:word;
              company:string;
              rom:ptipo_roms;
              samples:ptsample_file;
              tipo:word;
            end;

const
  //Tipos diferentes
  ARCADE=1;
  COMPUTER=2;
  GNW=4;
  CONSOLE=8;
  SPORT=$10;
  RUN_GUN=$20;
  SHOT=$40;
  MAZE=$80;
  FIGHT=$100;
  DRIVE=$200;
  SOUND_TIPO:array[0..4] of string=('NO','YES','SAMPLES','YES+SAMPLES','PARTIAL');
  GAMES_CONT=436;
  GAMES_DESC:array[1..GAMES_CONT] of tgame_desc=(
  //Computers
  (name:'Spectrum 48K';year:'1982';snd:1;hi:false;zip:'spectrum';grid:0;company:'Sinclair';rom:@spectrum;tipo:COMPUTER),
  (name:'Spectrum 128K';year:'1986';snd:1;hi:false;zip:'spec128';grid:1;company:'Sinclair';rom:@spec128;tipo:COMPUTER),
  (name:'Spectrum +3';year:'1987';snd:1;hi:false;zip:'plus3';grid:2;company:'Amstrad';rom:@plus3;tipo:COMPUTER),
  (name:'Spectrum +2A';year:'1987';snd:1;hi:false;zip:'plus3';grid:3;company:'Amstrad';rom:@plus3;tipo:COMPUTER),
  (name:'Spectrum +2';year:'1986';snd:1;hi:false;zip:'plus2';grid:4;company:'Amstrad';rom:@spec_plus2;tipo:COMPUTER),
  (name:'Spectrum 16K';year:'1982';snd:1;hi:false;zip:'spectrum';grid:5;company:'Sinclair';rom:@spectrum;tipo:COMPUTER),
  (name:'Amstrad CPC 464';year:'1984';snd:1;hi:false;zip:'cpc464';grid:7;company:'Amstrad';rom:@cpc464;tipo:COMPUTER),
  (name:'Amstrad CPC 664';year:'1984';snd:1;hi:false;zip:'cpc664';grid:8;company:'Amstrad';rom:@cpc664;tipo:COMPUTER),
  (name:'Amstrad CPC 6128';year:'1985';snd:1;hi:false;zip:'cpc6128';grid:9;company:'Amstrad';rom:@cpc6128;tipo:COMPUTER),
  (name:'Commodore 64';year:'1982';snd:1;hi:false;zip:'c64';grid:3000;company:'Commodore';rom:@c64;tipo:COMPUTER),
  (name:'Oric Atmos';year:'1984';snd:1;hi:false;zip:'orica';grid:3001;company:'Tangerine';rom:@orica;tipo:COMPUTER),
  (name:'Oric 1';year:'1983';snd:1;hi:false;zip:'oric1';grid:3002;company:'Tangerine';rom:@oric1;tipo:COMPUTER),
  //Arcade
  (name:'Pacman';year:'1980';snd:1;hi:false;zip:'pacman';grid:10;company:'Namco';rom:@pacman;tipo:ARCADE or MAZE),
  (name:'Phoenix';year:'1980';snd:1;hi:false;zip:'phoenix';grid:11;company:'Amstar Electronics';rom:@phoenix;tipo:ARCADE or SHOT),
  (name:'Mysterious Stones';year:'1984';snd:1;hi:false;zip:'mystston';grid:12;company:'Technos';rom:@mystston;tipo:ARCADE or RUN_GUN),
  (name:'Bomb Jack';year:'1984';snd:1;hi:false;zip:'bombjack';grid:13;company:'Tehkan';rom:@bombjack;tipo:ARCADE or MAZE),
  (name:'Frogger';year:'1981';snd:1;hi:true;zip:'frogger';grid:14;company:'Konami';rom:@frogger;tipo:ARCADE or MAZE),
  (name:'Donkey Kong';year:'1981';snd:2;hi:false;zip:'dkong';grid:15;company:'Nintendo';rom:@dkong;samples:@dkong_samples;tipo:ARCADE or MAZE),
  (name:'Black Tiger';year:'1986';snd:1;hi:true;zip:'blktiger';grid:16;company:'Capcom';rom:@blktiger;tipo:ARCADE or RUN_GUN),
  (name:'Green Beret';year:'1985';snd:1;hi:true;zip:'gberet';grid:17;company:'Konami';rom:@gberet;tipo:ARCADE or RUN_GUN),
  (name:'Commando';year:'1985';snd:1;hi:false;zip:'commando';grid:18;company:'Capcom';rom:@commando;tipo:ARCADE or RUN_GUN or SHOT),
  (name:'Ghosts''n Goblins';year:'1985';snd:1;hi:false;zip:'gng';grid:19;company:'Capcom';rom:@gng;tipo:ARCADE or RUN_GUN),
  (name:'Mikie';year:'1985';snd:1;hi:false;zip:'mikie';grid:20;company:'Konami';rom:@mikie;tipo:ARCADE or MAZE),
  (name:'Shaolin''s Road';year:'1985';snd:1;hi:false;zip:'shaolins';grid:21;company:'Konami';rom:@shaolins;tipo:ARCADE or MAZE),
  (name:'Yie Ar Kung-Fu';year:'1985';snd:1;hi:false;zip:'yiear';grid:22;company:'Konami';rom:@yiear;tipo:ARCADE or FIGHT),
  (name:'Asteroids';year:'1979';snd:2;hi:false;zip:'asteroid';grid:23;company:'Atari';rom:@asteroid;samples:@asteroid_samples;tipo:ARCADE or SHOT),
  (name:'Son Son';year:'1984';snd:1;hi:false;zip:'sonson';grid:24;company:'Capcom';rom:@sonson;tipo:ARCADE or RUN_GUN),
  (name:'Star Force';year:'1984';snd:1;hi:false;zip:'starforc';grid:25;company:'Tehkan';rom:@starforc;tipo:ARCADE or SHOT),
  (name:'Rygar';year:'1986';snd:1;hi:false;zip:'rygar';grid:26;company:'Tecmo';rom:@rygar;tipo:ARCADE or RUN_GUN),
  (name:'Pitfall II';year:'1984';snd:1;hi:false;zip:'pitfall2';grid:27;company:'Sega';rom:@pitfall2;tipo:ARCADE or RUN_GUN),
  (name:'Pooyan';year:'1982';snd:1;hi:false;zip:'pooyan';grid:28;company:'Konami';rom:@pooyan;tipo:ARCADE or SHOT),
  (name:'Jungler';year:'1981';snd:1;hi:false;zip:'jungler';grid:29;company:'Konami';rom:@jungler;tipo:ARCADE or MAZE),
  (name:'City Connection';year:'1986';snd:1;hi:false;zip:'citycon';grid:30;company:'Jaleco';rom:@citycon;tipo:ARCADE or DRIVE),
  (name:'Burger Time';year:'1982';snd:1;hi:false;zip:'btime';grid:31;company:'Deco';rom:@btime;tipo:ARCADE or MAZE),
  (name:'Express Raider';year:'1986';snd:1;hi:false;zip:'exprraid';grid:32;company:'Deco';rom:@exprraid;tipo:ARCADE or RUN_GUN),
  (name:'Super Basketball';year:'1984';snd:1;hi:false;zip:'sbasketb';grid:33;company:'Konami';rom:@sbasketb;tipo:ARCADE or SPORT),
  (name:'Lady Bug';year:'1981';snd:1;hi:false;zip:'ladybug';grid:34;company:'Universal';rom:@ladybug;tipo:ARCADE or MAZE),
  (name:'Teddy Boy Blues';year:'1985';snd:1;hi:false;zip:'teddybb';grid:35;company:'Sega';rom:@teddybb;tipo:ARCADE or RUN_GUN),
  (name:'Wonder Boy';year:'1986';snd:1;hi:false;zip:'wboy';grid:36;company:'Sega';rom:@wboy;tipo:ARCADE or RUN_GUN),
  (name:'Wonder Boy in Monster Land';year:'1987';snd:1;hi:false;zip:'wbml';grid:37;company:'Sega';rom:@wbml;tipo:ARCADE or RUN_GUN),
  (name:'Tehkan World Cup';year:'1985';snd:1;hi:false;zip:'tehkanwc';grid:38;company:'Tehkan';rom:@tehkanwc;tipo:ARCADE or SPORT),
  (name:'Popeye';year:'1982';snd:1;hi:false;zip:'popeye';grid:39;company:'Nintendo';rom:@popeye;tipo:ARCADE or MAZE),
  (name:'Psychic 5';year:'1987';snd:1;hi:false;zip:'psychic5';grid:40;company:'Jaleco';rom:@psychic5;tipo:ARCADE or RUN_GUN),
  (name:'Terra Cresta';year:'1985';snd:1;hi:false;zip:'terracre';grid:41;company:'Nichibutsu';rom:@terracre;tipo:ARCADE or SHOT),
  (name:'Kung-Fu Master';year:'1987';snd:1;hi:false;zip:'kungfum';grid:42;company:'Irem';rom:@kungfum;tipo:ARCADE or FIGHT),
  (name:'Shoot Out';year:'1985';snd:1;hi:false;zip:'shootout';grid:43;company:'Data East';rom:@shootout;tipo:ARCADE or SHOT),
  (name:'Vigilante';year:'1988';snd:1;hi:false;zip:'vigilant';grid:44;company:'Irem';rom:@vigilant;tipo:ARCADE or FIGHT),
  (name:'Jackal';year:'1986';snd:1;hi:false;zip:'jackal';grid:45;company:'Konami';rom:@jackal;tipo:ARCADE or RUN_GUN),
  (name:'Bubble Bobble';year:'1986';snd:1;hi:false;zip:'bublbobl';grid:46;company:'Taito';rom:@bublbobl;tipo:ARCADE or MAZE),
  (name:'Galaxian';year:'1979';snd:4;hi:false;zip:'galaxian';grid:47;company:'Namco';rom:@galaxian;samples:@galaxian_samples;tipo:ARCADE or SHOT),
  (name:'Jump Bug';year:'1981';snd:1;hi:false;zip:'jumpbug';grid:48;company:'Rock-Ola';rom:@jumpbug;tipo:ARCADE or RUN_GUN),
  (name:'Moon Cresta';year:'1980';snd:4;hi:false;zip:'mooncrst';grid:49;company:'Nichibutsu';rom:@mooncrst;samples:@mooncrst_samples;tipo:ARCADE or SHOT),
  (name:'Rally X';year:'1980';snd:3;hi:false;zip:'rallyx';grid:50;company:'Namco';rom:@rallyx;samples:@rallyx_samples;tipo:ARCADE or DRIVE or MAZE),
  (name:'Prehistoric Isle in 1930';year:'1989';snd:1;hi:false;zip:'prehisle';grid:51;company:'SNK';rom:@prehisle;tipo:ARCADE or SHOT),
  (name:'Tiger Road';year:'1987';snd:1;hi:false;zip:'tigeroad';grid:52;company:'Capcom';rom:@tigeroad;tipo:ARCADE or RUN_GUN),
  (name:'F1 Dream';year:'1988';snd:1;hi:false;zip:'f1dream';grid:53;company:'Capcom';rom:@f1dream;tipo:ARCADE or SPORT or DRIVE),
  (name:'Snowbros';year:'1990';snd:1;hi:false;zip:'snowbros';grid:54;company:'Toaplan';rom:@snowbros;tipo:ARCADE or MAZE),
  (name:'Toki';year:'1989';snd:1;hi:false;zip:'toki';grid:55;company:'TAD';rom:@toki;tipo:ARCADE or RUN_GUN),
  (name:'Contra';year:'1987';snd:1;hi:false;zip:'contra';grid:56;company:'Konami';rom:@contra;tipo:ARCADE or RUN_GUN),
  (name:'Mappy';year:'1983';snd:1;hi:false;zip:'mappy';grid:57;company:'Namco';rom:@mappy;tipo:ARCADE or MAZE),
  (name:'Rastan';year:'1987';snd:1;hi:false;zip:'rastan';grid:58;company:'Taito';rom:@rastan;tipo:ARCADE or RUN_GUN),
  (name:'Legendary Wings';year:'1986';snd:1;hi:false;zip:'lwings';grid:59;company:'Capcom';rom:@lwings_roms;tipo:ARCADE or RUN_GUN or SHOT),
  (name:'Section Z';year:'1985';snd:1;hi:false;zip:'sectionz';grid:60;company:'Capcom';rom:@sectionz_roms;tipo:ARCADE or RUN_GUN or SHOT),
  (name:'Trojan';year:'1986';snd:1;hi:false;zip:'trojan';grid:61;company:'Capcom';rom:@trojan_roms;tipo:ARCADE or RUN_GUN),
  (name:'Street Fighter';year:'1987';snd:1;hi:false;zip:'sf';grid:62;company:'Capcom';rom:@sfighter;tipo:ARCADE or FIGHT),
  (name:'DigDug II';year:'1985';snd:1;hi:false;zip:'digdug2';grid:63;company:'Namco';rom:@digdug2;tipo:ARCADE or MAZE),
  (name:'Super Pacman';year:'1985';snd:1;hi:false;zip:'superpac';grid:64;company:'Namco';rom:@spacman;tipo:ARCADE or MAZE),
  (name:'Galaga';year:'1981';snd:3;hi:false;zip:'galaga';grid:65;company:'Namco';rom:@galaga;samples:@galaga_samples;tipo:ARCADE or SHOT),
  (name:'Xain''d Sleena';year:'1986';snd:1;hi:false;zip:'xsleena';grid:66;company:'Technos';rom:@xsleena;tipo:ARCADE or RUN_GUN),
  (name:'Hard Head';year:'1988';snd:1;hi:false;zip:'hardhead';grid:67;company:'Suna';rom:@hardhead;tipo:ARCADE or RUN_GUN),
  (name:'Hard Head 2';year:'1989';snd:1;hi:false;zip:'hardhea2';grid:68;company:'Suna';rom:@hardhea2;tipo:ARCADE or RUN_GUN),
  (name:'Saboten Bombers';year:'1992';snd:1;hi:false;zip:'sabotenb';grid:69;company:'NMK';rom:@sabotenb;tipo:ARCADE or MAZE),
  (name:'New Rally X';year:'1981';snd:3;hi:false;zip:'nrallyx';grid:70;company:'Namco';rom:@nrallyx;samples:@rallyx_samples;tipo:ARCADE or DRIVE or MAZE),
  (name:'Bomb Jack Twin';year:'1993';snd:1;hi:false;zip:'bjtwin';grid:71;company:'NMK';rom:@bjtwin;tipo:ARCADE or MAZE),
  (name:'Spelunker';year:'1985';snd:1;hi:false;zip:'spelunkr';grid:72;company:'Broderbound';rom:@spelunkr;tipo:ARCADE or MAZE),
  (name:'Spelunker II';year:'1986';snd:1;hi:false;zip:'spelunk2';grid:73;company:'Broderbound';rom:@spelunk2;tipo:ARCADE or MAZE),
  (name:'Lode Runner';year:'1984';snd:1;hi:false;zip:'ldrun';grid:74;company:'Irem';rom:@ldrun;tipo:ARCADE or MAZE),
  (name:'Lode Runner II';year:'1984';snd:1;hi:false;zip:'ldrun2';grid:75;company:'Irem';rom:@ldrun2;tipo:ARCADE or MAZE),
  (name:'Knuckle Joe';year:'1985';snd:1;hi:false;zip:'kncljoe';grid:76;company:'Taito';rom:@kncljoe;tipo:ARCADE or FIGHT),
  (name:'Wardner';year:'1987';snd:1;hi:false;zip:'wardner';grid:77;company:'Taito';rom:@wardner;tipo:ARCADE or RUN_GUN),
  (name:'Big Karnak';year:'1991';snd:1;hi:false;zip:'bigkarnk';grid:78;company:'Gaelco';rom:@bigkarnk;tipo:ARCADE or RUN_GUN),
  (name:'Exed-Exes';year:'1985';snd:1;hi:false;zip:'exedexes';grid:79;company:'Capcom';rom:@exedexes;tipo:ARCADE or SHOT),
  (name:'Gun.Smoke';year:'1985';snd:1;hi:false;zip:'gunsmoke';grid:80;company:'Capcom';rom:@gunsmoke;tipo:ARCADE or RUN_GUN or SHOT),
  (name:'1942';year:'1984';snd:1;hi:false;zip:'1942';grid:81;company:'Capcom';rom:@hw1942;tipo:ARCADE or SHOT),
  (name:'1943';year:'1987';snd:1;hi:false;zip:'1943';grid:82;company:'Capcom';rom:@hw1943;tipo:ARCADE or SHOT),
  (name:'1943 Kai';year:'1987';snd:1;hi:false;zip:'1943kai';grid:83;company:'Capcom';rom:@hw1943kai;tipo:ARCADE or SHOT),
  (name:'Jail Break';year:'1986';snd:1;hi:false;zip:'jailbrek';grid:84;company:'Konami';rom:@jailbrek;tipo:ARCADE or RUN_GUN),
  (name:'Circus Charlie';year:'1984';snd:1;hi:false;zip:'circusc';grid:85;company:'Konami';rom:@circusc;tipo:ARCADE or RUN_GUN),
  (name:'Iron Horse';year:'1986';snd:1;hi:false;zip:'ironhors';grid:86;company:'Konami';rom:@ironhors;tipo:ARCADE or RUN_GUN),
  (name:'R-Type';year:'1987';snd:1;hi:false;zip:'rtype';grid:87;company:'Irem';rom:@rtype;tipo:ARCADE or SHOT),
  (name:'MS. Pac-man';year:'1981';snd:1;hi:false;zip:'mspacman';grid:88;company:'Namco';rom:@mspacman;tipo:ARCADE or MAZE),
  (name:'Break Thru';year:'1986';snd:1;hi:false;zip:'brkthru';grid:89;company:'Data East';rom:@brkthru;tipo:ARCADE or RUN_GUN or DRIVE),
  (name:'Darwin 4078';year:'1986';snd:1;hi:false;zip:'darwin';grid:90;company:'Data East';rom:@darwin;tipo:ARCADE or SHOT),
  (name:'Super Real Darwin';year:'1987';snd:1;hi:false;zip:'srdarwin';grid:91;company:'Data East';rom:@srdarwin_roms;tipo:ARCADE or SHOT),
  (name:'Double Dragon';year:'1987';snd:1;hi:false;zip:'ddragon';grid:92;company:'Taito';rom:@ddragon_roms;tipo:ARCADE or FIGHT),
  (name:'Mr. Do!';year:'1982';snd:1;hi:false;zip:'mrdo';grid:93;company:'Universal';rom:@mrdo_roms;tipo:ARCADE or MAZE),
  (name:'The Glob';year:'1983';snd:1;hi:false;zip:'theglob';grid:94;company:'Epos';rom:@theglob_roms;tipo:ARCADE or MAZE),
  (name:'Super Glob';year:'1983';snd:1;hi:false;zip:'suprglob';grid:95;company:'Epos';rom:@suprglob_roms;tipo:ARCADE or MAZE),
  (name:'Double Dragon II - The Revenge';year:'1988';snd:1;hi:false;zip:'ddragon2';grid:96;company:'Technos';rom:@ddragon2_roms;tipo:ARCADE or FIGHT),
  (name:'Silk Worm';year:'1988';snd:1;hi:false;zip:'silkworm';grid:97;company:'Tecmo';rom:@silkworm;tipo:ARCADE or RUN_GUN or SHOT or DRIVE),
  (name:'Tiger Heli';year:'1985';snd:1;hi:false;zip:'tigerh';grid:98;company:'Taito';rom:@tigerh_roms;tipo:ARCADE or SHOT),
  (name:'Slap Fight';year:'1986';snd:1;hi:false;zip:'slapfigh';grid:99;company:'Taito';rom:@slapfigh_roms;tipo:ARCADE or SHOT),
  (name:'The Legend of Kage';year:'1984';snd:1;hi:false;zip:'lkage';grid:100;company:'Taito';rom:@lkage;tipo:ARCADE or RUN_GUN),
  (name:'Thunder Hoop';year:'1992';snd:1;hi:false;zip:'thoop';grid:101;company:'Gaelco';rom:@thoop;tipo:ARCADE or RUN_GUN),
  (name:'Cabal';year:'1988';snd:1;hi:false;zip:'cabal';grid:102;company:'TAD';rom:@cabal;tipo:ARCADE or RUN_GUN),
  (name:'Ghouls''n Ghosts';year:'1988';snd:1;hi:false;zip:'ghouls';grid:103;company:'Capcom';rom:@ghouls;tipo:ARCADE or RUN_GUN),
  (name:'Final Fight';year:'1989';snd:1;hi:false;zip:'ffight';grid:104;company:'Capcom';rom:@ffight;tipo:ARCADE or FIGHT),
  (name:'The King of Dragons';year:'1991';snd:1;hi:false;zip:'kod';grid:105;company:'Capcom';rom:@kod;tipo:ARCADE or FIGHT),
  (name:'Street Fighter II - The World Warrior';year:'1991';snd:1;hi:false;zip:'sf2';grid:106;company:'Capcom';rom:@sf2;tipo:ARCADE or FIGHT),
  (name:'Strider';year:'1989';snd:1;hi:false;zip:'strider';grid:107;company:'Capcom';rom:@strider;tipo:ARCADE or RUN_GUN),
  (name:'Three Wonders';year:'1991';snd:1;hi:false;zip:'3wonders';grid:108;company:'Capcom';rom:@wonder3;tipo:ARCADE or RUN_GUN),
  (name:'Captain Commando';year:'1991';snd:1;hi:false;zip:'captcomm';grid:109;company:'Capcom';rom:@captcomm;tipo:ARCADE or RUN_GUN),
  (name:'Knights of the Round';year:'1991';snd:1;hi:false;zip:'knights';grid:110;company:'Capcom';rom:@knights;tipo:ARCADE or RUN_GUN),
  (name:'Street Fighter II'': Champion Edition';year:'1992';snd:1;hi:false;zip:'sf2ce';grid:111;company:'Capcom';rom:@sf2ce;tipo:ARCADE or FIGHT),
  (name:'Cadillacs and Dinosaurs';year:'1992';snd:1;hi:false;zip:'dino';grid:112;company:'Capcom';rom:@dino;tipo:ARCADE or FIGHT),
  (name:'The Punisher';year:'1993';snd:1;hi:false;zip:'punisher';grid:113;company:'Capcom';rom:@punisher;tipo:ARCADE or FIGHT),
  (name:'Shinobi';year:'1987';snd:1;hi:false;zip:'shinobi';grid:114;company:'Sega';rom:@shinobi;tipo:ARCADE or RUN_GUN),
  (name:'Alex Kidd';year:'1986';snd:1;hi:false;zip:'alexkidd';grid:115;company:'Sega';rom:@alexkidd;tipo:ARCADE or RUN_GUN),
  (name:'Fantasy Zone';year:'1986';snd:1;hi:false;zip:'fantzone';grid:116;company:'Sega';rom:@fantzone;tipo:ARCADE or RUN_GUN),
  (name:'Time Pilot ''84';year:'1984';snd:1;hi:false;zip:'tp84';grid:117;company:'Konami';rom:@tp84;tipo:ARCADE or SHOT),
  (name:'Tutankham';year:'1982';snd:1;hi:false;zip:'tutankhm';grid:118;company:'Konami';rom:@tutankhm;tipo:ARCADE or MAZE),
  (name:'Pang';year:'1989';snd:1;hi:false;zip:'pang';grid:119;company:'Capcom';rom:@pang;tipo:ARCADE or SHOT),
  (name:'Ninja Kid II';year:'1987';snd:1;hi:false;zip:'ninjakd2';grid:120;company:'UPL';rom:@ninjakd2;tipo:ARCADE or RUN_GUN),
  (name:'Ark Area';year:'1988';snd:1;hi:false;zip:'arkarea';grid:121;company:'UPL';rom:@arkarea;tipo:ARCADE or SHOT),
  (name:'Mutant Night';year:'1987';snd:1;hi:false;zip:'mnight';grid:122;company:'UPL';rom:@mnight;tipo:ARCADE or RUN_GUN),
  (name:'Sky Kid';year:'1985';snd:1;hi:false;zip:'skykid';grid:123;company:'Namco';rom:@skykid;tipo:ARCADE or SHOT),
  (name:'Rolling Thunder';year:'1986';snd:1;hi:false;zip:'rthunder';grid:124;company:'Namco';rom:@rthunder;tipo:ARCADE or RUN_GUN),
  (name:'Hopping Mappy';year:'1986';snd:1;hi:false;zip:'hopmappy';grid:125;company:'Namco';rom:@hopmappy;tipo:ARCADE or MAZE),
  (name:'Sky Kid Deluxe';year:'1986';snd:1;hi:false;zip:'skykiddx';grid:126;company:'Namco';rom:@skykiddx;tipo:ARCADE or SHOT),
  (name:'Roc''n Rope';year:'1983';snd:1;hi:false;zip:'rocnrope';grid:127;company:'Konami';rom:@rocnrope;tipo:ARCADE or MAZE),
  (name:'Repulse';year:'1985';snd:1;hi:false;zip:'repulse';grid:128;company:'Crux/Sega';rom:@repulse;tipo:ARCADE or SHOT),
  (name:'The NewZealand Story';year:'1988';snd:1;hi:false;zip:'tnzs';grid:129;company:'Taito';rom:@tnzs;tipo:ARCADE or RUN_GUN),
  (name:'Insector X';year:'1989';snd:1;hi:false;zip:'insectx';grid:130;company:'Taito';rom:@insectx;tipo:ARCADE or SHOT),
  (name:'Pacland';year:'1984';snd:1;hi:false;zip:'pacland';grid:131;company:'Namco';rom:@pacland;tipo:ARCADE or RUN_GUN),
  (name:'Mario Bros.';year:'1983';snd:2;hi:false;zip:'mario';grid:132;company:'Nintendo';rom:@mario;samples:@mario_samples;tipo:ARCADE or MAZE),
  (name:'Solomon''s Key';year:'1986';snd:1;hi:false;zip:'solomon';grid:133;company:'Tecmo';rom:@solomon;tipo:ARCADE or MAZE),
  (name:'Combat School';year:'1988';snd:1;hi:false;zip:'combatsc';grid:134;company:'Konami';rom:@combatsc;tipo:ARCADE or RUN_GUN),
  (name:'Heavy Unit';year:'1988';snd:1;hi:false;zip:'hvyunit';grid:135;company:'Taito';rom:@hvyunit;tipo:ARCADE or SHOT),
  (name:'P.O.W. - Prisoners of War';year:'1988';snd:1;hi:false;zip:'pow';grid:136;company:'SNK';rom:@pow;tipo:ARCADE or RUN_GUN),
  (name:'Street Smart';year:'1988';snd:1;hi:false;zip:'streetsm';grid:137;company:'SNK';rom:@streetsm;tipo:ARCADE or FIGHT),
  (name:'P47 - Phantom Fighter';year:'1989';snd:1;hi:false;zip:'p47';grid:138;company:'Jaleco';rom:@p47;tipo:ARCADE or SHOT),
  (name:'Rod-Land';year:'1990';snd:1;hi:false;zip:'rodland';grid:139;company:'Jaleco';rom:@rodland;tipo:ARCADE or MAZE),
  (name:'Saint Dragon';year:'1989';snd:1;hi:false;zip:'stdragon';grid:140;company:'Jaleco';rom:@stdragon;tipo:ARCADE or SHOT),
  (name:'Time Pilot';year:'1982';snd:1;hi:false;zip:'timeplt';grid:141;company:'Konami';rom:@timeplt;tipo:ARCADE or SHOT),
  (name:'Pengo';year:'1982';snd:1;hi:false;zip:'pengo';grid:142;company:'Sega';rom:@pengo;tipo:ARCADE or MAZE),
  (name:'Scramble';year:'1981';snd:1;hi:false;zip:'scramble';grid:143;company:'Konami';rom:@scramble;tipo:ARCADE or SHOT),
  (name:'Super Cobra';year:'1981';snd:1;hi:false;zip:'scobra';grid:144;company:'Konami';rom:@scobra;tipo:ARCADE or SHOT),
  (name:'Amidar';year:'1982';snd:1;hi:false;zip:'amidar';grid:145;company:'Konami';rom:@amidar_roms;tipo:ARCADE or MAZE),
  (name:'Twin Cobra';year:'1987';snd:1;hi:false;zip:'twincobr';grid:146;company:'Taito';rom:@twincobr;tipo:ARCADE or SHOT),
  (name:'Flying Shark';year:'1987';snd:1;hi:false;zip:'fshark';grid:147;company:'Taito';rom:@fshark;tipo:ARCADE or SHOT),
  (name:'Jr. Pac-Man';year:'1983';snd:1;hi:false;zip:'jrpacman';grid:148;company:'Bally Midway';rom:@jrpacman;tipo:ARCADE or MAZE),
  (name:'Ikari III - The Rescue';year:'1989';snd:1;hi:false;zip:'ikari3';grid:149;company:'SNK';rom:@ikari3;tipo:ARCADE or FIGHT),
  (name:'Search and Rescue';year:'1989';snd:1;hi:false;zip:'searchar';grid:150;company:'SNK';rom:@searchar;tipo:ARCADE or RUN_GUN),
  (name:'Choplifter';year:'1985';snd:1;hi:false;zip:'choplift';grid:151;company:'Sega';rom:@choplift;tipo:ARCADE or SHOT or RUN_GUN),
  (name:'Mister Viking';year:'1983';snd:1;hi:false;zip:'mrviking';grid:152;company:'Sega';rom:@mrviking;tipo:ARCADE or RUN_GUN),
  (name:'Sega Ninja';year:'1985';snd:1;hi:false;zip:'seganinj';grid:153;company:'Sega';rom:@seganinj;tipo:ARCADE or RUN_GUN),
  (name:'Up''n Down';year:'1983';snd:1;hi:false;zip:'upndown';grid:154;company:'Sega';rom:@upndown;tipo:ARCADE or DRIVE or MAZE),
  (name:'Flicky';year:'1984';snd:1;hi:false;zip:'flicky';grid:155;company:'Sega';rom:@flicky;tipo:ARCADE or MAZE),
  (name:'Robocop';year:'1988';snd:1;hi:false;zip:'robocop';grid:156;company:'Data East';rom:@robocop;tipo:ARCADE or RUN_GUN),
  (name:'Baddudes vs. DragonNinja';year:'1988';snd:1;hi:false;zip:'baddudes';grid:157;company:'Data East';rom:@baddudes;tipo:ARCADE or FIGHT or RUN_GUN),
  (name:'Hippodrome';year:'1989';snd:1;hi:false;zip:'hippodrm';grid:158;company:'Data East';rom:@hippodrm;tipo:ARCADE or FIGHT),
  (name:'Tumble Pop';year:'1991';snd:1;hi:false;zip:'tumblep';grid:159;company:'Data East';rom:@tumblep;tipo:ARCADE or MAZE),
  (name:'Funky Jet';year:'1992';snd:1;hi:false;zip:'funkyjet';grid:160;company:'Mitchell';rom:@funkyjet;tipo:ARCADE or MAZE),
  (name:'Super Burger Time';year:'1990';snd:1;hi:false;zip:'supbtime';grid:161;company:'Data East';rom:@supbtime;tipo:ARCADE),
  (name:'Caveman Ninja';year:'1991';snd:1;hi:false;zip:'cninja';grid:162;company:'Data East';rom:@cninja;tipo:ARCADE or RUN_GUN),
  (name:'Robocop 2';year:'1991';snd:1;hi:false;zip:'robocop2';grid:163;company:'Data East';rom:@robocop2;tipo:ARCADE or RUN_GUN),
  (name:'Diet Go Go';year:'1992';snd:1;hi:false;zip:'dietgo';grid:164;company:'Data East';rom:@dietgo;tipo:ARCADE or MAZE),
  (name:'Act-Fancer Cybernetick Hyper Weapon';year:'1989';snd:1;hi:false;zip:'actfancr';grid:165;company:'Data East';rom:@actfancer;tipo:ARCADE or RUN_GUN),
  (name:'Arabian';year:'1983';snd:1;hi:false;zip:'arabian';grid:166;company:'Sun Electronics';rom:@arabian;tipo:ARCADE or MAZE),
  (name:'Dig Dug';year:'1982';snd:1;hi:false;zip:'digdug';grid:167;company:'Namco';rom:@digdug;tipo:ARCADE or MAZE),
  (name:'Donkey Kong Jr.';year:'1982';snd:2;hi:false;zip:'dkongjr';grid:168;company:'Nintendo';rom:@dkongjr;samples:@dkjr_samples;tipo:ARCADE or MAZE),
  (name:'Donkey Kong 3';year:'1983';snd:1;hi:false;zip:'dkong3';grid:169;company:'Nintendo';rom:@dkong3;tipo:ARCADE or MAZE),
  (name:'Pirate Ship Higemaru';year:'1984';snd:1;hi:false;zip:'higemaru';grid:170;company:'Capcom';rom:@higemaru;tipo:ARCADE or MAZE),
  (name:'Bagman';year:'1982';snd:4;hi:false;zip:'bagman';grid:171;company:'Valadon Automation';rom:@bagman;tipo:ARCADE or MAZE),
  (name:'Super Bagman';year:'1984';snd:4;hi:false;zip:'sbagman';grid:172;company:'Valadon Automation';rom:@sbagman;tipo:ARCADE or MAZE),
  (name:'Squash';year:'1992';snd:1;hi:false;zip:'squash';grid:173;company:'Gaelco';rom:@squash;tipo:ARCADE or SPORT),
  (name:'Biomechanical Toy';year:'1995';snd:1;hi:false;zip:'biomtoy';grid:174;company:'Gaelco';rom:@biomtoy;tipo:ARCADE or RUN_GUN),
  (name:'Congo Bongo';year:'1983';snd:3;hi:false;zip:'congo';grid:175;company:'Sega';rom:@congo;samples:@congo_samples;tipo:ARCADE or MAZE),
  (name:'Kangaroo';year:'1982';snd:1;hi:false;zip:'kangaroo';grid:176;company:'Sun Electronics';rom:@kangaroo;tipo:ARCADE or MAZE),
  (name:'Bionic Commando';year:'1987';snd:1;hi:false;zip:'bionicc';grid:177;company:'Capcom';rom:@bionicc;tipo:ARCADE or RUN_GUN),
  (name:'WWF Superstar';year:'1989';snd:1;hi:false;zip:'wwfsstar';grid:178;company:'Technos Japan';rom:@wwfsstar;tipo:ARCADE or SPORT),
  (name:'Rainbow Islands';year:'1987';snd:1;hi:false;zip:'rbisland';grid:179;company:'Taito';rom:@rbisland;tipo:ARCADE or RUN_GUN),
  (name:'Rainbow Islands Extra';year:'1987';snd:1;hi:false;zip:'rbislande';grid:180;company:'Taito';rom:@rbislande;tipo:ARCADE or RUN_GUN),
  (name:'Volfied';year:'1989';snd:1;hi:false;zip:'volfied';grid:181;company:'Taito';rom:@volfied;tipo:ARCADE or MAZE),
  (name:'Operation Wolf';year:'1987';snd:1;hi:false;zip:'opwolf';grid:182;company:'Taito';rom:@opwolf;tipo:ARCADE or RUN_GUN or SHOT),
  (name:'Super Pang';year:'1990';snd:1;hi:false;zip:'spang';grid:183;company:'Capcom';rom:@spang;tipo:ARCADE or SHOT),
  (name:'Outrun';year:'1989';snd:1;hi:false;zip:'outrun';grid:184;company:'Sega';rom:@outrun;tipo:ARCADE or DRIVE),
  (name:'Elevator Action';year:'1983';snd:1;hi:false;zip:'elevator';grid:185;company:'Taito';rom:@elevator;tipo:ARCADE or RUN_GUN),
  (name:'Alien Syndrome';year:'1988';snd:1;hi:false;zip:'aliensyn';grid:186;company:'Sega';rom:@aliensyn;tipo:ARCADE or RUN_GUN),
  (name:'Wonder Boy III - Monster Lair';year:'1987';snd:1;hi:false;zip:'wb3';grid:187;company:'Sega';rom:@wb3;tipo:ARCADE or RUN_GUN),
  (name:'Zaxxon';year:'1982';snd:2;hi:false;zip:'zaxxon';grid:188;company:'Sega';rom:@zaxxon;samples:@zaxxon_samples;tipo:ARCADE or SHOT),
  (name:'Jungle King';year:'1982';snd:1;hi:false;zip:'junglek';grid:189;company:'Taito';rom:@junglek;tipo:ARCADE or RUN_GUN),
  (name:'Hammerin'' Harry';year:'1990';snd:1;hi:false;zip:'hharry';grid:190;company:'Irem';rom:@hharry;tipo:ARCADE or RUN_GUN),
  (name:'R-Type II';year:'1989';snd:1;hi:false;zip:'rtype2';grid:191;company:'Irem';rom:@rtype2;tipo:ARCADE or SHOT),
  (name:'The Tower of Druaga';year:'1984';snd:1;hi:false;zip:'todruaga';grid:192;company:'Namco';rom:@todruaga;tipo:ARCADE or MAZE),
  (name:'Motos';year:'1985';snd:1;hi:false;zip:'motos';grid:193;company:'Namco';rom:@motos;tipo:ARCADE or MAZE),
  (name:'Dragon Buster';year:'1984';snd:1;hi:false;zip:'drgnbstr';grid:194;company:'Namco';rom:@drgnbstr;tipo:ARCADE or MAZE or RUN_GUN),
  (name:'Vulgus';year:'1984';snd:1;hi:false;zip:'vulgus';grid:195;company:'Capcom';rom:@vulgus;tipo:ARCADE or SHOT),
  (name:'Double Dragon 3 - The Rosetta Stone';year:'1990';snd:1;hi:false;zip:'ddragon3';grid:196;company:'Technos';rom:@ddragon3;tipo:ARCADE or FIGHT),
  (name:'Block Out';year:'1990';snd:1;hi:false;zip:'blockout';grid:197;company:'Technos';rom:@blockout;tipo:ARCADE),
  (name:'Tetris (Sega)';year:'1988';snd:1;hi:false;zip:'tetris';grid:198;company:'Sega';rom:@tetris;tipo:ARCADE),
  (name:'Food Fight';year:'1982';snd:1;hi:false;zip:'foodf';grid:199;company:'Atari';rom:@foodf;tipo:ARCADE or MAZE),
  (name:'Snap Jack';year:'1982';snd:1;hi:false;zip:'snapjack';grid:200;company:'Universal';rom:@snapjack;tipo:ARCADE or RUN_GUN),
  (name:'Cosmic Avenger';year:'1981';snd:1;hi:false;zip:'cavenger';grid:201;company:'Universal';rom:@cavenger;tipo:ARCADE or SHOT),
  (name:'Pleiads';year:'1981';snd:0;hi:false;zip:'pleiads';grid:202;company:'Tehkan';rom:@pleiads;tipo:ARCADE or SHOT),
  (name:'Mr. Goemon';year:'1986';snd:1;hi:false;zip:'mrgoemon';grid:203;company:'Konami';rom:@mrgoemon;tipo:ARCADE or RUN_GUN),
  (name:'Nemesis';year:'1985';snd:1;hi:false;zip:'nemesis';grid:204;company:'Konami';rom:@nemesis;tipo:ARCADE or SHOT),
  (name:'Twinbee';year:'1985';snd:1;hi:false;zip:'twinbee';grid:205;company:'Konami';rom:@twinbee;tipo:ARCADE or SHOT),
  (name:'Pirates';year:'1994';snd:1;hi:false;zip:'pirates';grid:206;company:'NIX';rom:@pirates;tipo:ARCADE or RUN_GUN),
  (name:'Genix Family';year:'1994';snd:1;hi:false;zip:'genix';grid:207;company:'NIX';rom:@genix;tipo:ARCADE or RUN_GUN),
  (name:'Juno First';year:'1983';snd:1;hi:false;zip:'junofrst';grid:208;company:'Konami';rom:@junofrst;tipo:ARCADE or SHOT),
  (name:'Gyruss';year:'1983';snd:1;hi:false;zip:'gyruss';grid:209;company:'Konami';rom:@gyruss;tipo:ARCADE or SHOT),
  (name:'Boogie Wings';year:'1992';snd:1;hi:false;zip:'boogwing';grid:210;company:'Data East';rom:@boogwing;tipo:ARCADE or RUN_GUN),
  (name:'Free Kick';year:'1987';snd:1;hi:false;zip:'freekick';grid:211;company:'Nihon System';rom:@freekick;tipo:ARCADE or SPORT),
  (name:'Pinball Action';year:'1985';snd:1;hi:false;zip:'pbaction';grid:212;company:'Tehkan';rom:@pbaction;tipo:ARCADE),
  (name:'Renegade';year:'1986';snd:1;hi:false;zip:'renegade';grid:213;company:'Technos Japan';rom:@renegade;tipo:ARCADE or FIGHT),
  (name:'Teenage Mutant Ninja Turtles';year:'1989';snd:1;hi:false;zip:'tmnt';grid:214;company:'Konami';rom:@tmnt;tipo:ARCADE or FIGHT),
  (name:'Sunset Riders';year:'1991';snd:1;hi:false;zip:'ssriders';grid:215;company:'Konami';rom:@ssriders;tipo:ARCADE or RUN_GUN or FIGHT),
  (name:'Gradius III';year:'1991';snd:1;hi:false;zip:'gradius3';grid:216;company:'Konami';rom:@gradius3;tipo:ARCADE or SHOT),
  (name:'Space Invaders';year:'1978';snd:2;hi:false;zip:'invaders';grid:217;company:'Taito';rom:@spaceinv;samples:@spaceinv_samples;tipo:ARCADE or SHOT),
  (name:'Centipede';year:'1980';snd:1;hi:false;zip:'centiped';grid:218;company:'Atari';rom:@centipede;tipo:ARCADE or SHOT),
  (name:'Karnov';year:'1987';snd:1;hi:false;zip:'karnov';grid:219;company:'Data East';rom:@karnov;tipo:ARCADE or RUN_GUN),
  (name:'Chelnov';year:'1987';snd:1;hi:false;zip:'chelnov';grid:220;company:'Data East';rom:@chelnov;tipo:ARCADE or RUN_GUN),
  (name:'Aliens';year:'1990';snd:1;hi:false;zip:'aliens';grid:221;company:'Konami';rom:@aliens;tipo:ARCADE or RUN_GUN),
  (name:'Super Contra';year:'1988';snd:1;hi:false;zip:'scontra';grid:222;company:'Konami';rom:@scontra;tipo:ARCADE or RUN_GUN),
  (name:'Gang Busters';year:'1988';snd:1;hi:false;zip:'gbusters';grid:223;company:'Konami';rom:@gbusters;tipo:ARCADE or RUN_GUN),
  (name:'Thunder Cross';year:'1988';snd:1;hi:false;zip:'thunderx';grid:224;company:'Konami';rom:@thunderx;tipo:ARCADE or SHOT),
  (name:'The Simpsons';year:'1991';snd:1;hi:false;zip:'simpsons';grid:225;company:'Konami';rom:@simpsons;tipo:ARCADE or RUN_GUN or FIGHT),
  (name:'Track & Field';year:'1983';snd:1;hi:false;zip:'trackfld';grid:226;company:'Konami';rom:@trackfield;tipo:ARCADE or SPORT),
  (name:'Hyper Sports';year:'1984';snd:1;hi:false;zip:'hyperspt';grid:227;company:'Konami';rom:@hypersports;tipo:ARCADE or SPORT),
  (name:'Megazone';year:'1983';snd:1;hi:false;zip:'megazone';grid:228;company:'Konami';rom:@megazone;tipo:ARCADE or SHOT),
  (name:'Space Fire Bird';year:'1980';snd:4;hi:false;zip:'spacefb';grid:229;company:'Nintendo';rom:@spacefb;samples:@spacefb_samples;tipo:ARCADE or SHOT),
  (name:'Ajax';year:'1987';snd:1;hi:false;zip:'ajax';grid:230;company:'Konami';rom:@ajax;tipo:ARCADE or SHOT),
  (name:'Xevious';year:'1982';snd:3;hi:false;zip:'xevious';grid:231;company:'Namco';rom:@xevious;samples:@xevious_samples;tipo:ARCADE or SHOT),
  (name:'The Combatribes';year:'1990';snd:1;hi:false;zip:'ctribe';grid:232;company:'Technos';rom:@ctribe;tipo:ARCADE or FIGHT),
  (name:'Lunar Lander';year:'1979';snd:0;hi:false;zip:'llander';grid:233;company:'Atari';rom:@llander;tipo:ARCADE),
  (name:'Crush Roller';year:'1981';snd:1;hi:false;zip:'crush';grid:234;company:'Alpha Denshi Co./Kural Samno Electric, Ltd.';rom:@crush;tipo:ARCADE or MAZE),
  (name:'Vendetta';year:'1991';snd:1;hi:false;zip:'vendetta';grid:235;company:'Konami';rom:@vendetta;tipo:ARCADE or FIGHT),
  (name:'Gauntlet';year:'1985';snd:1;hi:false;zip:'gauntlet';grid:236;company:'Atari';rom:@gauntlet2p;tipo:ARCADE or RUN_GUN),
  (name:'Sauro';year:'1987';snd:1;hi:false;zip:'sauro';grid:237;company:'Tecfri';rom:@sauro;tipo:ARCADE or SHOT),
  (name:'Crazy Climber';year:'1980';snd:1;hi:false;zip:'cclimber';grid:238;company:'Nichibutsu';rom:@cclimber;tipo:ARCADE),
  (name:'Return of the Invaders';year:'1985';snd:1;hi:false;zip:'retofinv';grid:239;company:'Taito';rom:@retofinv;tipo:ARCADE or SHOT),
  (name:'Tetris (Atari)';year:'1988';snd:1;hi:false;zip:'atetris';grid:240;company:'Atari Games';rom:@tetris_atari;tipo:ARCADE),
  (name:'Ikari Warriors';year:'1986';snd:1;hi:false;zip:'ikari';grid:241;company:'SNK';rom:@ikari;tipo:ARCADE or RUN_GUN),
  (name:'Athena';year:'1986';snd:1;hi:false;zip:'athena';grid:242;company:'SNK';rom:@athena;tipo:ARCADE or RUN_GUN),
  (name:'T.N.K III';year:'1986';snd:1;hi:false;zip:'tnk3';grid:243;company:'SNK';rom:@tnk3;tipo:ARCADE or RUN_GUN),
  (name:'Peter Pack Rat';year:'1984';snd:1;hi:false;zip:'peterpak';grid:244;company:'Atari';rom:@peterpak;tipo:ARCADE),
  (name:'Gauntlet II';year:'1986';snd:1;hi:false;zip:'gaunt2';grid:245;company:'Atari';rom:@gaunt2;tipo:ARCADE or RUN_GUN),
  (name:'Defender';year:'1980';snd:1;hi:false;zip:'defender';grid:246;company:'Williams';rom:@defender;tipo:ARCADE or SHOT),
  (name:'Fire Ball';year:'1992';snd:1;hi:false;zip:'fball';grid:247;company:'FM Works';rom:@fball_roms;tipo:ARCADE or MAZE),
  (name:'Mayday';year:'1980';snd:1;hi:false;zip:'mayday';grid:248;company:'Williams';rom:@mayday;tipo:ARCADE or SHOT),
  (name:'Colony 7';year:'1981';snd:1;hi:false;zip:'colony7';grid:249;company:'Williams';rom:@colony7;tipo:ARCADE or SHOT),
  (name:'Bosconian';year:'1981';snd:3;hi:false;zip:'bosco';grid:250;company:'Namco';rom:@bosco;samples:@bosco_samples;tipo:ARCADE or SHOT),
  (name:'HangOn Jr.';year:'1985';snd:1;hi:false;zip:'hangonjr';grid:251;company:'Sega';rom:@hangonjr;tipo:ARCADE or SPORT or DRIVE),
  (name:'Slap Shooter';year:'1986';snd:1;hi:false;zip:'slapshtr';grid:252;company:'Sega';rom:@slapshtr;tipo:ARCADE or SPORT),
  (name:'Fantasy Zone II: The Tears of Opa-Opa';year:'1988';snd:1;hi:false;zip:'fantzn2';grid:253;company:'Sega';rom:@fantzn2;tipo:ARCADE or SHOT),
  (name:'Opa Opa';year:'1987';snd:1;hi:false;zip:'opaopa';grid:254;company:'Sega';rom:@opaopa;tipo:ARCADE or MAZE),
  (name:'Tetris (Sega System E)';year:'1988';snd:1;hi:false;zip:'tetrisse';grid:255;company:'Sega';rom:@tetrisse;tipo:ARCADE),
  (name:'Transformer';year:'1986';snd:1;hi:false;zip:'transfrm';grid:256;company:'Sega';rom:@transfrm;tipo:ARCADE or SHOT),
  (name:'Riddle of Pythagoras';year:'1986';snd:1;hi:false;zip:'ridleofp';grid:257;company:'Sega';rom:@ridleofp;tipo:ARCADE or MAZE),
  (name:'Route 16';year:'1981';snd:1;hi:false;zip:'route16';grid:258;company:'Sun Electronics';rom:@route16;tipo:ARCADE or DRIVE),
  (name:'Speak & Rescue';year:'1980';snd:1;hi:false;zip:'speakres';grid:259;company:'Sun Electronics';rom:@speakres;tipo:ARCADE or SHOT),
  (name:'Galactic Warriors';year:'1985';snd:1;hi:false;zip:'gwarrior';grid:260;company:'Konami';rom:@gwarrior;tipo:ARCADE or FIGHT),
  (name:'Salamander';year:'1986';snd:1;hi:false;zip:'salamand';grid:261;company:'Konami';rom:@salamander;tipo:ARCADE or SHOT),
  (name:'Bad Lands';year:'1989';snd:1;hi:false;zip:'badlands';grid:262;company:'Atari';rom:@badlands;tipo:ARCADE or DRIVE),
  (name:'Indiana Jones and the Temple of Doom';year:'1985';snd:1;hi:false;zip:'indytemp';grid:263;company:'Atari';rom:@indytemp;tipo:ARCADE or RUN_GUN),
  (name:'Marble Madness';year:'1984';snd:1;hi:false;zip:'marble';grid:264;company:'Atari';rom:@marble;tipo:ARCADE or MAZE),
  (name:'Soldier Girl Amazon';year:'1986';snd:1;hi:false;zip:'amazon';grid:265;company:'Nichibutsu';rom:@amazon;tipo:ARCADE or RUN_GUN),
  (name:'Cosmo Police Galivan';year:'1985';snd:1;hi:false;zip:'galivan';grid:266;company:'Nichibutsu';rom:@galivan;tipo:ARCADE or RUN_GUN),
  (name:'Ufo Robo Dangar';year:'1986';snd:1;hi:false;zip:'dangar';grid:267;company:'Nichibutsu';rom:@dangar;tipo:ARCADE or SHOT),
  (name:'Last Duel';year:'1988';snd:1;hi:false;zip:'lastduel';grid:268;company:'Capcom';rom:@lastduel;tipo:ARCADE or DRIVE),
  (name:'Mad Gear';year:'1989';snd:1;hi:false;zip:'madgear';grid:269;company:'Capcom';rom:@madgear;tipo:ARCADE or DRIVE),
  (name:'Led Storm Rally 2011';year:'1989';snd:1;hi:false;zip:'leds2011';grid:270;company:'Capcom';rom:@leds2011;tipo:ARCADE or DRIVE),
  (name:'Gigas';year:'1986';snd:1;hi:false;zip:'gigas';grid:271;company:'Sega';rom:@gigas;tipo:ARCADE or MAZE),
  (name:'Gigas Mark II';year:'1986';snd:1;hi:false;zip:'gigasm2';grid:272;company:'Sega';rom:@gigasm2;tipo:ARCADE or MAZE),
  (name:'Omega';year:'1986';snd:1;hi:false;zip:'omega';grid:273;company:'Nihon System';rom:@omega;tipo:ARCADE or MAZE),
  (name:'Perfect Billard';year:'1987';snd:1;hi:false;zip:'pbillrd';grid:274;company:'Nihon System';rom:@pbillrd;tipo:ARCADE or SPORT),
  (name:'Armed F';year:'1988';snd:1;hi:false;zip:'armedf';grid:275;company:'Nichibutsu';rom:@armedf;tipo:ARCADE or SHOT),
  (name:'Terra Force';year:'1987';snd:1;hi:false;zip:'terraf';grid:276;company:'Nichibutsu';rom:@terraf;tipo:ARCADE or SHOT),
  (name:'Crazy Climber 2';year:'1988';snd:1;hi:false;zip:'cclimbr2';grid:277;company:'Nichibutsu';rom:@cclimbr2;tipo:ARCADE),
  (name:'Legion - Spinner-87';year:'1987';snd:1;hi:false;zip:'legion';grid:278;company:'Nichibutsu';rom:@legion;tipo:ARCADE or SHOT or DRIVE),
  (name:'ASO - Armored Scrum Object';year:'1985';snd:1;hi:false;zip:'aso';grid:279;company:'SNK';rom:@aso;tipo:ARCADE or SHOT),
  (name:'Fire Trap';year:'1986';snd:1;hi:false;zip:'firetrap';grid:280;company:'Woodplace Inc.';rom:@firetrap;tipo:ARCADE),
  (name:'3x3 Puzzle';year:'1998';snd:1;hi:false;zip:'3x3puzzl';grid:281;company:'Ace Enterprise';rom:@puzz3x3;tipo:ARCADE),
  (name:'Casanova';year:'199?';snd:1;hi:false;zip:'casanova';grid:282;company:'Promat';rom:@casanova;tipo:ARCADE or MAZE),
  (name:'1945k III';year:'2000';snd:1;hi:false;zip:'1945kiii';grid:283;company:'Oriental Soft';rom:@k31945;tipo:ARCADE or SHOT),
  (name:'96 Flag Rally';year:'2000';snd:1;hi:false;zip:'flagrall';grid:284;company:'Promat';rom:@flagrall;tipo:ARCADE or DRIVE),
  (name:'Blood Bros.';year:'1990';snd:1;hi:false;zip:'bloodbro';grid:285;company:'TAD Corporation';rom:@bloodbros;tipo:ARCADE or RUN_GUN),
  (name:'Sky Smasher';year:'1990';snd:1;hi:false;zip:'skysmash';grid:286;company:'Nihon System';rom:@skysmash;tipo:ARCADE or SHOT),
  (name:'Baraduke';year:'1985';snd:1;hi:false;zip:'baraduke';grid:287;company:'Namco';rom:@baraduke;tipo:ARCADE or RUN_GUN),
  (name:'Metro-Cross';year:'1985';snd:1;hi:false;zip:'metrocrs';grid:288;company:'Namco';rom:@metrocross;tipo:ARCADE or RUN_GUN),
  (name:'The Return of Ishtar';year:'1986';snd:1;hi:false;zip:'roishtar';grid:289;company:'Namco';rom:@roishtar;tipo:ARCADE or MAZE),
  (name:'Genpei ToumaDen';year:'1986';snd:1;hi:false;zip:'genpeitd';grid:290;company:'Namco';rom:@genpeitd;tipo:ARCADE or RUN_GUN),
  (name:'Wonder Momo';year:'1987';snd:1;hi:false;zip:'wndrmomo';grid:291;company:'Namco';rom:@wndrmomo;tipo:ARCADE or RUN_GUN),
  (name:'Altered Beast';year:'1988';snd:1;hi:false;zip:'altbeast';grid:292;company:'Sega';rom:@altbeast;tipo:ARCADE or FIGHT),
  (name:'Golden Axe';year:'1989';snd:1;hi:false;zip:'goldnaxe';grid:293;company:'Sega';rom:@goldnaxe;tipo:ARCADE or FIGHT),
  (name:'Dynamite Dux';year:'1988';snd:1;hi:false;zip:'ddux1';grid:294;company:'Sega';rom:@ddux;tipo:ARCADE or FIGHT),
  (name:'E-Swat - Cyber Police';year:'1989';snd:1;hi:false;zip:'eswat';grid:295;company:'Sega';rom:@eswat;tipo:ARCADE or RUN_GUN or FIGHT),
  (name:'Passing Shot';year:'1988';snd:1;hi:false;zip:'passsht';grid:296;company:'Sega';rom:@passsht;tipo:ARCADE or SPORT),
  (name:'Aurail';year:'1990';snd:1;hi:false;zip:'aurail';grid:297;company:'Sega';rom:@aurail;tipo:ARCADE or RUN_GUN),
  (name:'Hellfire';year:'1989';snd:1;hi:false;zip:'hellfire';grid:298;company:'Toaplan';rom:@hellfire;tipo:ARCADE or RUN_GUN),
  (name:'Lock''n''Chase';year:'1981';snd:1;hi:false;zip:'lnc';grid:299;company:'Deco';rom:@lnc;tipo:ARCADE or MAZE),
  (name:'Minky Monkey';year:'1982';snd:1;hi:false;zip:'mmonkey';grid:300;company:'Deco';rom:@mmonkey;tipo:ARCADE or MAZE),
  (name:'Karate Champ';year:'1984';snd:1;hi:false;zip:'kchamp';grid:301;company:'Data East';rom:@karatechamp;tipo:ARCADE or SPORT or FIGHT),
  (name:'Thundercade';year:'1987';snd:1;hi:false;zip:'tndrcade';grid:302;company:'Seta';rom:@tndrcade;tipo:ARCADE or SHOT),
  (name:'Twin Eagle - Revenge Joe''s Brother';year:'1988';snd:1;hi:false;zip:'twineagl';grid:303;company:'Seta';rom:@twineagl;tipo:ARCADE or SHOT),
  (name:'Thunder & Lightning';year:'1990';snd:1;hi:false;zip:'thunderl';grid:304;company:'Seta';rom:@thunderl;tipo:ARCADE or MAZE),
  (name:'Ms Pac Man Twin';year:'1992';snd:1;hi:false;zip:'mspactwin';grid:305;company:'Susilu';rom:@mspactwin;tipo:ARCADE or MAZE),
  (name:'Extermination';year:'1987';snd:1;hi:false;zip:'extrmatn';grid:306;company:'Taito';rom:@extrmatn;tipo:ARCADE or RUN_GUN),
  (name:'Atomic Robo-kid';year:'1988';snd:1;hi:false;zip:'robokid';grid:307;company:'UPL';rom:@robokid;tipo:ARCADE or RUN_GUN),
  (name:'Mr. Do''s Castle';year:'1983';snd:1;hi:false;zip:'docastle';grid:308;company:'Universal';rom:@docastle;tipo:ARCADE or MAZE),
  (name:'Do! Run Run';year:'1984';snd:1;hi:false;zip:'dorunrun';grid:309;company:'Universal';rom:@dorunrun;tipo:ARCADE or MAZE),
  (name:'Mr. Do''s Wild Ride';year:'1984';snd:1;hi:false;zip:'dowild';grid:310;company:'Universal';rom:@dowild;tipo:ARCADE or MAZE),
  (name:'Jumping Jack';year:'1984';snd:1;hi:false;zip:'jjack';grid:311;company:'Universal';rom:@jjack;tipo:ARCADE),
  (name:'Kick Rider';year:'1984';snd:1;hi:false;zip:'kickridr';grid:312;company:'Universal';rom:@kickridr;tipo:ARCADE or SPORT or DRIVE),
  (name:'Indoor Soccer';year:'1985';snd:1;hi:false;zip:'idsoccer';grid:313;company:'Universal';rom:@idsoccer;tipo:ARCADE or SPORT),
  (name:'Crystal Castles';year:'1983';snd:1;hi:false;zip:'ccastles';grid:314;company:'Atari';rom:@ccastles;tipo:ARCADE or MAZE),
  (name:'Flower';year:'1986';snd:1;hi:false;zip:'flower';grid:315;company:'Clarue';rom:@flower;tipo:ARCADE or SHOT),
  (name:'SlySpy';year:'1989';snd:1;hi:false;zip:'slyspy';grid:316;company:'Data East';rom:@slyspy;tipo:ARCADE or RUN_GUN),
  (name:'Boulder Dash I-II';year:'1990';snd:1;hi:false;zip:'bouldash';grid:317;company:'Data East';rom:@bouldash;tipo:ARCADE or MAZE),
  (name:'Super Dodge Ball';year:'1987';snd:1;hi:false;zip:'spdodgeb';grid:318;company:'Technos';rom:@sdodgeball;tipo:ARCADE or SPORT),
  (name:'Senjyo';year:'1983';snd:1;hi:false;zip:'senjyo';grid:319;company:'Tehkan';rom:@senjyo;tipo:ARCADE or SHOT),
  (name:'Baluba-louk no Densetsu';year:'1986';snd:1;hi:false;zip:'baluba';grid:320;company:'Able Corp, Ltd.';rom:@baluba;tipo:ARCADE or RUN_GUN),
  (name:'Joust';year:'1982';snd:1;hi:false;zip:'joust';grid:321;company:'Williams';rom:@joust;tipo:ARCADE or MAZE),
  (name:'Robotron';year:'1982';snd:1;hi:false;zip:'robotron';grid:322;company:'Williams';rom:@robotron;tipo:ARCADE or RUN_GUN),
  (name:'Stargate';year:'1981';snd:1;hi:false;zip:'stargate';grid:323;company:'Williams';rom:@stargate;tipo:ARCADE or SHOT),
  (name:'Tapper';year:'1983';snd:1;hi:false;zip:'tapper';grid:324;company:'Bally Midway';rom:@tapper;tipo:ARCADE),
  (name:'Arkanoid';year:'1986';snd:1;hi:false;zip:'arkanoid';grid:325;company:'Taito';rom:@arkanoid;tipo:ARCADE or MAZE),
  (name:'Side Arms - Hyper Dyne';year:'1986';snd:1;hi:false;zip:'sidearms';grid:326;company:'Capcom';rom:@sidearms;tipo:ARCADE or RUN_GUN or SHOT),
  (name:'The Speed Rumbler';year:'1986';snd:1;hi:false;zip:'srumbler';grid:327;company:'Capcom';rom:@speedr;tipo:ARCADE or RUN_GUN),
  (name:'China Gate';year:'1988';snd:1;hi:false;zip:'chinagat';grid:328;company:'Technos Japan';rom:@chinagate;tipo:ARCADE or RUN_GUN or FIGHT),
  (name:'Mag Max';year:'1985';snd:1;hi:false;zip:'magmax';grid:329;company:'Nichibutsu';rom:@magmax;tipo:ARCADE or RUN_GUN),
  (name:'S.R.D. Mission';year:'1986';snd:1;hi:false;zip:'srdmissn';grid:330;company:'Kyugo/Sega';rom:@srdmission;tipo:ARCADE or SHOT),
  (name:'Airwolf';year:'1987';snd:1;hi:false;zip:'airwolf';grid:331;company:'Kyugo';rom:@airwolf;tipo:ARCADE or SHOT),
  (name:'Ambush';year:'1983';snd:1;hi:false;zip:'ambush';grid:332;company:'Tecfri';rom:@ambush;tipo:ARCADE or SHOT),
  (name:'Super Duck';year:'1992';snd:1;hi:false;zip:'supduck';grid:333;company:'Comad';rom:@superduck;tipo:ARCADE or MAZE),
  (name:'Hang-On';year:'1985';snd:1;hi:false;zip:'hangon';grid:334;company:'Sega';rom:@hangon;tipo:ARCADE or SPORT),
  (name:'Enduro Racer';year:'1986';snd:1;hi:false;zip:'enduror';grid:335;company:'Sega';rom:@enduror;tipo:ARCADE or SPORT),
  (name:'Space Harrier';year:'1985';snd:1;hi:false;zip:'sharrier';grid:336;company:'Sega';rom:@sharrier_roms;tipo:ARCADE or RUN_GUN),
  (name:'64th Street - A detective story';year:'1991';snd:1;hi:false;zip:'64street';grid:337;company:'Jaleco';rom:@th64_roms;tipo:ARCADE or FIGHT),
  (name:'Shadow Warriors';year:'1988';snd:1;hi:false;zip:'shadoww';grid:338;company:'Tecmo';rom:@shadoww_roms;tipo:ARCADE or FIGHT),
  (name:'Wild Fang/Tecmo Knight';year:'1989';snd:1;hi:false;zip:'wildfang';grid:339;company:'Tecmo';rom:@wildfang_roms;tipo:ARCADE or FIGHT),
  (name:'Raiden';year:'1990';snd:1;hi:false;zip:'raiden';grid:340;company:'Seibu Kaihatsu';rom:@raiden_roms;tipo:ARCADE or SHOT),
  (name:'Twins';year:'1993';snd:1;hi:false;zip:'twins';grid:341;company:'Ecogames';rom:@twins_roms;tipo:ARCADE or MAZE),
  (name:'Twins (Electronic Devices)';year:'1994';snd:1;hi:false;zip:'twinsed1';grid:342;company:'Ecogames';rom:@twinsed1_roms;tipo:ARCADE or MAZE),
  (name:'Hot Blocks - Tetrix II';year:'1993';snd:1;hi:false;zip:'hotblock';grid:343;company:'NIX?';rom:@hotblock_roms;tipo:ARCADE or MAZE),
  (name:'Missile Command';year:'1980';snd:1;hi:false;zip:'missile';grid:344;company:'Atari';rom:@missile_roms;tipo:ARCADE or SHOT),
  (name:'Super Missile Attack';year:'1981';snd:1;hi:false;zip:'suprmatk';grid:345;company:'Atari';rom:@suprmatk_roms;tipo:ARCADE or SHOT),
  (name:'Super Zaxxon';year:'1982';snd:3;hi:false;zip:'szaxxon';grid:346;company:'Sega';rom:@szaxxon_roms;samples:@zaxxon_samples;tipo:ARCADE or SHOT),
  (name:'Future Spy';year:'1984';snd:3;hi:false;zip:'futspy';grid:347;company:'Sega';rom:@futspy_roms;samples:@zaxxon_samples;tipo:ARCADE or SHOT),
  (name:'Millipede';year:'1982';snd:1;hi:false;zip:'milliped';grid:348;company:'Atari';rom:@milliped_roms;tipo:ARCADE or SHOT),
  (name:'Gaplus';year:'1984';snd:3;hi:false;zip:'gaplus';grid:349;company:'Namco';rom:@gaplus_roms;samples:@gaplus_samples;tipo:ARCADE or SHOT),
  (name:'Super Xevious';year:'1984';snd:3;hi:false;zip:'sxevious';grid:350;company:'Namco';rom:@sxevious_roms;samples:@xevious_samples;tipo:ARCADE or SHOT),
  (name:'Grobda';year:'1984';snd:1;hi:false;zip:'grobda';grid:351;company:'Namco';rom:@grobda_roms;tipo:ARCADE or SHOT),
  (name:'Pac & Pal';year:'1983';snd:1;hi:false;zip:'pacnpal';grid:352;company:'Namco';rom:@pacnpal_roms;tipo:ARCADE or MAZE),
  (name:'Birdiy';year:'1983';snd:1;hi:false;zip:'birdiy';grid:353;company:'Mama Top';rom:@birdiy_roms;tipo:ARCADE or MAZE),
  (name:'Wily Tower';year:'1984';snd:1;hi:false;zip:'wilytowr';grid:354;company:'Irem';rom:@wilytower_roms;tipo:ARCADE or MAZE),
  (name:'Fighting Basketball';year:'1984';snd:1;hi:false;zip:'fghtbskt';grid:355;company:'Irem';rom:@fightbasket_roms;tipo:ARCADE or SPORT),
  (name:'Diverboy';year:'1992';snd:1;hi:false;zip:'diverboy';grid:356;company:'Gamart';rom:@diverboy_roms;tipo:ARCADE or MAZE),
  (name:'Mug Smashers';year:'1990';snd:1;hi:false;zip:'mugsmash';grid:357;company:'Electronic Devices Italy';rom:@mugsmash_roms;tipo:ARCADE or FIGHT),
  (name:'Steel Force';year:'1994';snd:1;hi:false;zip:'stlforce';grid:358;company:'Ecogames';rom:@steelforce_roms;tipo:ARCADE or MAZE or SHOT),
  (name:'Twin Brats';year:'1995';snd:1;hi:false;zip:'twinbrat';grid:359;company:'Ecogames';rom:@twinbrats_roms;tipo:ARCADE or MAZE),
  (name:'Mortal Race';year:'1995';snd:1;hi:false;zip:'mortalr';grid:360;company:'Ecogames';rom:@mortalrace_roms;tipo:ARCADE or DRIVE),
  (name:'Bank Panic';year:'1985';snd:1;hi:false;zip:'bankp';grid:361;company:'Sanritsu/Sega';rom:@bankpanic_roms;tipo:ARCADE or SHOT),
  (name:'Combat Hawk';year:'1987';snd:1;hi:false;zip:'combh';grid:362;company:'Sanritsu/Sega';rom:@combathawk_roms;tipo:ARCADE or SHOT),
  (name:'Ant Eater';year:'1982';snd:1;hi:false;zip:'anteater';grid:363;company:'Tago Electronics';rom:@anteater_roms;tipo:ARCADE or MAZE),
  (name:'Appoooh';year:'1984';snd:1;hi:false;zip:'appoooh';grid:364;company:'Sanritsu/Sega';rom:@appoooh_roms;tipo:ARCADE or SPORT),
  (name:'Robo Wres 2001';year:'1986';snd:1;hi:false;zip:'robowres';grid:365;company:'Sanritsu/Sega';rom:@robowres_roms;tipo:ARCADE or SPORT),
  (name:'Armored Car';year:'1981';snd:1;hi:false;zip:'armorcar';grid:366;company:'Stern Electronics';rom:@armoredcar_roms;tipo:ARCADE or MAZE),
  (name:'88 Games';year:'1988';snd:1;hi:false;zip:'88games';grid:367;company:'Konami';rom:@hw88games_roms;tipo:ARCADE or SPORT),
  (name:'Avengers';year:'1987';snd:1;hi:false;zip:'avengers';grid:368;company:'Capcom';rom:@avengers_roms;tipo:ARCADE or RUN_GUN),
  (name:'The End';year:'1980';snd:1;hi:false;zip:'theend';grid:369;company:'Konami';rom:@theend_roms;tipo:ARCADE or SHOT),
  (name:'Battle of Atlantis';year:'1981';snd:1;hi:false;zip:'atlantis';grid:370;company:'Comsoft';rom:@atlantis_roms;tipo:ARCADE or SHOT),
  (name:'Blue Hawk';year:'1993';snd:1;hi:false;zip:'bluehawk';grid:371;company:'Dooyong';rom:@bluehawk_roms;tipo:ARCADE or SHOT),
  (name:'The Last Day';year:'1990';snd:1;hi:false;zip:'lastday';grid:372;company:'Dooyong';rom:@lastday_roms;tipo:ARCADE or SHOT),
  (name:'Gulf Storm';year:'1991';snd:1;hi:false;zip:'gulfstrm';grid:373;company:'Dooyong';rom:@gulfstorm_roms;tipo:ARCADE or SHOT),
  (name:'Pollux';year:'1991';snd:1;hi:false;zip:'pollux';grid:374;company:'Dooyong';rom:@pollux_roms;tipo:ARCADE or SHOT),
  (name:'Flying Tiger';year:'1992';snd:1;hi:false;zip:'flytiger';grid:375;company:'Dooyong';rom:@flytiger_roms;tipo:ARCADE or SHOT),
  (name:'Sky Skipper';year:'1981';snd:1;hi:false;zip:'skyskipr';grid:376;company:'Nintendo';rom:@skyskipper_roms;tipo:ARCADE or SHOT),
  (name:'Blue Print';year:'1982';snd:1;hi:false;zip:'blueprnt';grid:377;company:'Zilec Electronics/Bally Midway';rom:@blueprint_roms;tipo:ARCADE or MAZE),
  (name:'Saturn';year:'1983';snd:1;hi:false;zip:'saturnzi';grid:378;company:'Zilec Electronics/Jaleco';rom:@saturnzi_roms;tipo:ARCADE or SHOT),
  (name:'Grasspin';year:'1983';snd:1;hi:false;zip:'grasspin';grid:379;company:'Zilec Electronics/Jaleco';rom:@grasspin_roms;tipo:ARCADE or MAZE),
  (name:'BurglarX';year:'1997';snd:1;hi:false;zip:'burglarx';grid:380;company:'Unico';rom:@burglarx_roms;tipo:ARCADE or MAZE),
  (name:'Zero Point';year:'1998';snd:1;hi:false;zip:'zeropnt';grid:381;company:'Unico';rom:@zeropnt_roms;tipo:ARCADE or SHOT),
  (name:'Calipso';year:'1982';snd:1;hi:false;zip:'calipso';grid:382;company:'Tago Electronics';rom:@calipso_roms;tipo:ARCADE or MAZE),
  (name:'Calorie Kun vs Moguranian';year:'1986';snd:1;hi:false;zip:'calorie';grid:383;company:'Sega';rom:@caloriekun_roms;tipo:ARCADE or MAZE),
  (name:'Gardia';year:'1986';snd:1;hi:false;zip:'gardia';grid:384;company:'Sega';rom:@gardia_roms;tipo:ARCADE or SHOT),
  (name:'Cavelon';year:'1983';snd:1;hi:false;zip:'cavelon';grid:385;company:'Jetsoft';rom:@cavelon_roms;tipo:ARCADE or MAZE),
  (name:'Come Back Toto';year:'1996';snd:1;hi:false;zip:'toto';grid:386;company:'SoftClub';rom:@toto_roms;tipo:ARCADE or MAZE),
  (name:'Hyper Pacman';year:'1995';snd:1;hi:false;zip:'hyperpac';grid:387;company:'SemiCom';rom:@hyperpac_roms;tipo:ARCADE or MAZE),
  (name:'KiKi KaiKai';year:'1986';snd:1;hi:false;zip:'kikikai';grid:388;company:'Taito';rom:@kikikaikai_roms;tipo:ARCADE or RUN_GUN OR MAZE),
  (name:'Kick and Run';year:'1986';snd:1;hi:false;zip:'kicknrun';grid:389;company:'Taito';rom:@kickrun_roms;tipo:ARCADE or SPORT),
  (name:'Lasso';year:'1982';snd:1;hi:false;zip:'lasso';grid:390;company:'SNK';rom:@lasso_roms;tipo:ARCADE or RUN_GUN),
  (name:'Chameleon';year:'1983';snd:1;hi:false;zip:'chameleo';grid:391;company:'Jaleco';rom:@chameleo_roms;tipo:ARCADE or MAZE),
  (name:'Last Mission';year:'1986';snd:1;hi:false;zip:'lastmisn';grid:392;company:'Data East';rom:@lastmisn_roms;tipo:ARCADE or SHOT),
  (name:'Shackled';year:'1986';snd:1;hi:false;zip:'shackled';grid:393;company:'Data East';rom:@shackled_roms;tipo:ARCADE or MAZE),
  (name:'Gondomania';year:'1987';snd:1;hi:false;zip:'gondo';grid:394;company:'Data East';rom:@gondo_roms;tipo:ARCADE or SHOT),
  (name:'Garyo Retsuden';year:'1987';snd:1;hi:false;zip:'garyoret';grid:395;company:'Data East';rom:@garyoret_roms;tipo:ARCADE or SHOT),
  (name:'Captain Silver';year:'1987';snd:1;hi:false;zip:'csilver';grid:396;company:'Data East';rom:@csilver_roms;tipo:ARCADE or RUN_GUN),
  (name:'Cobra-Command';year:'1988';snd:1;hi:false;zip:'cobracom';grid:397;company:'Data East';rom:@cobracom_roms;tipo:ARCADE or SHOT),
  (name:'The Real Ghostbusters';year:'1987';snd:1;hi:false;zip:'ghostb';grid:398;company:'Data East';rom:@ghostb_roms;tipo:ARCADE or RUN_GUN),
  (name:'Psycho-Nics Oscar';year:'1987';snd:1;hi:false;zip:'oscar';grid:399;company:'Data East';rom:@oscar_roms;tipo:ARCADE or RUN_GUN),
  (name:'Road Fighter';year:'1984';snd:1;hi:false;zip:'roadf';grid:400;company:'Konami';rom:@roadf_roms;tipo:ARCADE or DRIVE),
  (name:'Ponpoko';year:'1982';snd:1;hi:false;zip:'ponpoko';grid:401;company:'Sigma';rom:@ponpoko_roms;tipo:ARCADE or MAZE),
  (name:'Woodpecker';year:'1981';snd:1;hi:false;zip:'woodpeck';grid:402;company:'Amenip';rom:@woodpeck_roms;tipo:ARCADE or MAZE),
  (name:'Eyes';year:'1982';snd:1;hi:false;zip:'eyes';grid:403;company:'Techstar';rom:@eyes_roms;tipo:ARCADE or MAZE),
  (name:'Ali Baba and 40 Thieves';year:'1982';snd:1;hi:false;zip:'alibaba';grid:404;company:'Sega';rom:@alibaba_roms;tipo:ARCADE or MAZE),
  (name:'Piranha';year:'1981';snd:1;hi:false;zip:'piranha';grid:405;company:'GL';rom:@piranha_roms;tipo:ARCADE or MAZE),
  (name:'Final Star Force';year:'1992';snd:1;hi:false;zip:'fstarfrc';grid:406;company:'Tecmo';rom:@finalstarforce_roms;tipo:ARCADE or SHOT),
  (name:'Wyvern F-0';year:'1985';snd:1;hi:false;zip:'wyvernf0';grid:407;company:'Taito';rom:@wyvernf0_roms;tipo:ARCADE or SHOT),
  (name:'Riot City';year:'1991';snd:1;hi:false;zip:'riotcity';grid:408;company:'Sega/Westone';rom:@riotcity_roms;tipo:ARCADE or FIGHT),
  (name:'SDI - Strategic Defense Initiative';year:'1987';snd:1;hi:false;zip:'sdib';grid:409;company:'Sega';rom:@sdi_roms;tipo:ARCADE or SHOT),
  (name:'Cotton';year:'1991';snd:1;hi:false;zip:'cotton';grid:410;company:'Sega';rom:@cotton_roms;tipo:ARCADE or SHOT),
  (name:'Discs of Tron';year:'1983';snd:1;hi:false;zip:'dotron';grid:411;company:'Bally Midway';rom:@dotron_roms;tipo:ARCADE or SHOT),
  (name:'Tron';year:'1981';snd:1;hi:false;zip:'tron';grid:412;company:'Bally Midway';rom:@tron_roms;tipo:ARCADE or SHOT),
  (name:'Timber';year:'1984';snd:1;hi:false;zip:'timber';grid:413;company:'Bally Midway';rom:@timber_roms;tipo:ARCADE or RUN_GUN),
  (name:'Satan''s Hollow';year:'1981';snd:1;hi:false;zip:'shollow';grid:414;company:'Bally Midway';rom:@shollow_roms;tipo:ARCADE or SHOT),
  (name:'Domino Man';year:'1982';snd:1;hi:false;zip:'domino';grid:415;company:'Bally Midway';rom:@domino_roms;tipo:ARCADE or MAZE),
  (name:'Wacko';year:'1982';snd:1;hi:false;zip:'wacko';grid:416;company:'Bally Midway';rom:@wacko_roms;tipo:ARCADE or MAZE),
  (name:'Nastar';year:'1988';snd:1;hi:false;zip:'nastar';grid:417;company:'Taito';rom:@nastar_roms;tipo:ARCADE or RUN_GUN or FIGHT),
  (name:'Master of Weapon';year:'1989';snd:1;hi:false;zip:'masterw';grid:418;company:'Taito';rom:@masterw_roms;tipo:ARCADE or SHOT),
  //*** Consoles
  (name:'NES';year:'198X';snd:1;hi:false;zip:'';grid:1000;company:'Nintendo';tipo:CONSOLE),
  (name:'ColecoVision';year:'1980';snd:1;hi:false;zip:'coleco';grid:1001;company:'Coleco';rom:@coleco_;tipo:CONSOLE),
  (name:'GameBoy';year:'198X';snd:1;hi:false;zip:'gameboy';grid:1002;company:'Nintendo';rom:@gameboy;tipo:CONSOLE),
  (name:'GameBoy Color';year:'198X';snd:1;hi:false;zip:'gbcolor';grid:1002;company:'Nintendo';rom:@gbcolor;tipo:CONSOLE),
  (name:'CHIP 8';year:'197X';snd:1;hi:false;zip:'';grid:1003;company:'-';tipo:CONSOLE),
  (name:'Master System';year:'1986';snd:1;hi:false;zip:'sms';grid:1004;company:'Sega';rom:@sms_;tipo:CONSOLE),
  (name:'SG-1000';year:'1985';snd:1;hi:false;zip:'';grid:1005;company:'Sega';tipo:CONSOLE),
  (name:'GameGear';year:'1990';snd:1;hi:false;zip:'';grid:1006;company:'Sega';tipo:CONSOLE),
  (name:'Super Cassette Vision';year:'1984';snd:1;hi:false;zip:'scv';grid:1007;company:'Epoch';rom:@scv;tipo:CONSOLE),
  (name:'Genesis/Megadrive';year:'1988';snd:1;hi:false;zip:'';grid:1008;company:'Sega';tipo:CONSOLE),
  (name:'PV-1000';year:'1983';snd:1;hi:false;zip:'';grid:1009;company:'Casio';tipo:CONSOLE),
  (name:'PV-2000';year:'1983';snd:1;hi:false;zip:'pv2000';grid:1010;company:'Casio';rom:@pv2000_rom;tipo:CONSOLE),
  //G&W
  (name:'Donkey Kong Jr';year:'1983';snd:1;hi:false;zip:'gnw_dj101';grid:2000;company:'Nintendo';rom:@gnw_dj101;tipo:GNW),
  (name:'Donkey Kong II';year:'1983';snd:1;hi:false;zip:'gnw_jr55';grid:2001;company:'Nintendo';rom:@gnw_jr55;tipo:GNW),
  (name:'Mario Bros';year:'1983';snd:1;hi:false;zip:'gnw_mw56';grid:2002;company:'Nintendo';rom:@gnw_mw56;tipo:GNW));

var
  orden_games:array[1..GAMES_CONT] of word;

procedure load_game(numero:word);
procedure todos_false;
procedure menus_false(driver:word);
procedure cargar_maquina(tmaquina:word);
function tipo_cambio_maquina(sender:TObject):word;

implementation
uses principal;

procedure load_game(numero:word);
begin
case numero of
  0:principal1.CambiarMaquina(principal1.Spectrum48K1);
  1:principal1.CambiarMaquina(principal1.Spectrum128K1);
  2:principal1.CambiarMaquina(principal1.Spectrum31);
  3:principal1.CambiarMaquina(principal1.Spectrum2a1);
  4:principal1.CambiarMaquina(principal1.Spectrum21);
  5:principal1.CambiarMaquina(principal1.Spectrum16K1);
  7:principal1.CambiarMaquina(principal1.cpc1);
  8:principal1.CambiarMaquina(principal1.cpc6641);
  9:principal1.CambiarMaquina(principal1.cpc61281);
  3000:principal1.CambiarMaquina(principal1.c641);
  3001:principal1.CambiarMaquina(principal1.oricatmos1);
  3002:principal1.CambiarMaquina(principal1.oric1_1);
  10:principal1.CambiarMaquina(principal1.Pacman1);
  11:principal1.CambiarMaquina(principal1.Phoenix1);
  12:principal1.CambiarMaquina(principal1.MisteriousStone1);
  13:principal1.CambiarMaquina(principal1.BombJack1);
  14:principal1.CambiarMaquina(principal1.Frogger1);
  15:principal1.CambiarMaquina(principal1.Dkong1);
  16:principal1.CambiarMaquina(principal1.Blacktiger1);
  17:principal1.CambiarMaquina(principal1.Gberet1);
  18:principal1.CambiarMaquina(principal1.Commando1);
  19:principal1.CambiarMaquina(principal1.gng1);
  20:principal1.CambiarMaquina(principal1.Mikie1);
  21:principal1.CambiarMaquina(principal1.Shaolin1);
  22:principal1.CambiarMaquina(principal1.Yiear1);
  23:principal1.CambiarMaquina(principal1.Asteroids1);
  24:principal1.CambiarMaquina(principal1.SonSon1);
  25:principal1.CambiarMaquina(principal1.StarForce1);
  26:principal1.CambiarMaquina(principal1.Rygar1);
  27:principal1.CambiarMaquina(principal1.PitfallII1);
  28:principal1.CambiarMaquina(principal1.Pooyan1);
  29:principal1.CambiarMaquina(principal1.jungler1);
  30:principal1.CambiarMaquina(principal1.citycon1);
  31:principal1.CambiarMaquina(principal1.burgertime1);
  32:principal1.CambiarMaquina(principal1.expressraider1);
  33:principal1.CambiarMaquina(principal1.superbasketball1);
  34:principal1.CambiarMaquina(principal1.ladybug1);
  35:principal1.CambiarMaquina(principal1.teddy1);
  36:principal1.CambiarMaquina(principal1.wboy1);
  37:principal1.CambiarMaquina(principal1.wbml1);
  38:principal1.CambiarMaquina(principal1.tehkanwc1);
  39:principal1.CambiarMaquina(principal1.popeye1);
  40:principal1.CambiarMaquina(principal1.psychic51);
  41:principal1.CambiarMaquina(principal1.terracre1);
  42:principal1.CambiarMaquina(principal1.kungfum1);
  43:principal1.CambiarMaquina(principal1.shootout1);
  44:principal1.CambiarMaquina(principal1.vigilante1);
  45:principal1.CambiarMaquina(principal1.jackal1);
  46:principal1.CambiarMaquina(principal1.bubblebobble1);
  47:principal1.CambiarMaquina(principal1.galaxian1);
  48:principal1.CambiarMaquina(principal1.jumpb1);
  49:principal1.CambiarMaquina(principal1.mooncresta1);
  50:principal1.CambiarMaquina(principal1.rallyx1);
  51:principal1.CambiarMaquina(principal1.prehisle1);
  52:principal1.CambiarMaquina(principal1.tigerRoad1);
  53:principal1.CambiarMaquina(principal1.f1dream1);
  54:principal1.CambiarMaquina(principal1.snowbros1);
  55:principal1.CambiarMaquina(principal1.toki1);
  56:principal1.CambiarMaquina(principal1.contra1);
  57:principal1.CambiarMaquina(principal1.mappy1);
  58:principal1.CambiarMaquina(principal1.rastan1);
  59:principal1.CambiarMaquina(principal1.legendw1);
  60:principal1.CambiarMaquina(principal1.sectionz1);
  61:principal1.CambiarMaquina(principal1.trojan1);
  62:principal1.CambiarMaquina(principal1.sf1);
  63:principal1.CambiarMaquina(principal1.digdug21);
  64:principal1.CambiarMaquina(principal1.spacman1);
  65:principal1.CambiarMaquina(principal1.galaga1);
  66:principal1.CambiarMaquina(principal1.xain1);
  67:principal1.CambiarMaquina(principal1.hardhead1);
  68:principal1.CambiarMaquina(principal1.hardhead21);
  69:principal1.CambiarMaquina(principal1.sbombers1);
  70:principal1.CambiarMaquina(principal1.newrallyx1);
  71:principal1.CambiarMaquina(principal1.bjtwin1);
  72:principal1.CambiarMaquina(principal1.spelunker1);
  73:principal1.CambiarMaquina(principal1.spelunker21);
  74:principal1.CambiarMaquina(principal1.ldrun1);
  75:principal1.CambiarMaquina(principal1.ldrun21);
  76:principal1.CambiarMaquina(principal1.knjoe1);
  77:principal1.CambiarMaquina(principal1.wardner1);
  78:principal1.CambiarMaquina(principal1.bigkarnak1);
  79:principal1.CambiarMaquina(principal1.exedexes1);
  80:principal1.CambiarMaquina(principal1.gunsmoke1);
  81:principal1.CambiarMaquina(principal1.n19421);
  82:principal1.CambiarMaquina(principal1.n19431);
  83:principal1.CambiarMaquina(principal1.n1943kai1);
  84:principal1.CambiarMaquina(principal1.jailbreak1);
  85:principal1.CambiarMaquina(principal1.circusc1);
  86:principal1.CambiarMaquina(principal1.ironhorse1);
  87:principal1.CambiarMaquina(principal1.rtype1);
  88:principal1.CambiarMaquina(principal1.mspacman1);
  89:principal1.CambiarMaquina(principal1.brkthru1);
  90:principal1.CambiarMaquina(principal1.darwin1);
  91:principal1.CambiarMaquina(principal1.srd1);
  92:principal1.CambiarMaquina(principal1.ddragon1);
  93:principal1.CambiarMaquina(principal1.mrdo1);
  94:principal1.CambiarMaquina(principal1.theglob1);
  95:principal1.CambiarMaquina(principal1.superglob1);
  96:principal1.CambiarMaquina(principal1.ddragon21);
  97:principal1.CambiarMaquina(principal1.silkworm1);
  98:principal1.CambiarMaquina(principal1.tigerh1);
  99:principal1.CambiarMaquina(principal1.slapfight1);
  100:principal1.CambiarMaquina(principal1.legendofkage1);
  101:principal1.CambiarMaquina(principal1.thoop1);
  102:principal1.CambiarMaquina(principal1.cabal1);
  103:principal1.CambiarMaquina(principal1.ghouls1);
  104:principal1.CambiarMaquina(principal1.ffight1);
  105:principal1.CambiarMaquina(principal1.kod1);
  106:principal1.CambiarMaquina(principal1.sf21);
  107:principal1.CambiarMaquina(principal1.strider1);
  108:principal1.CambiarMaquina(principal1.wonder31);
  109:principal1.CambiarMaquina(principal1.ccommando1);
  110:principal1.CambiarMaquina(principal1.knights1);
  111:principal1.CambiarMaquina(principal1.sf2ce1);
  112:principal1.CambiarMaquina(principal1.dino1);
  113:principal1.CambiarMaquina(principal1.punisher1);
  114:principal1.CambiarMaquina(principal1.shinobi1);
  115:principal1.CambiarMaquina(principal1.alexkid1);
  116:principal1.CambiarMaquina(principal1.fantasyzone1);
  117:principal1.CambiarMaquina(principal1.tp841);
  118:principal1.CambiarMaquina(principal1.tutankhm1);
  119:principal1.CambiarMaquina(principal1.Pang1);
  120:principal1.CambiarMaquina(principal1.ninjakid21);
  121:principal1.CambiarMaquina(principal1.arkarea1);
  122:principal1.CambiarMaquina(principal1.mnight1);
  123:principal1.CambiarMaquina(principal1.skykid1);
  124:principal1.CambiarMaquina(principal1.rthunder1);
  125:principal1.CambiarMaquina(principal1.hopmappy1);
  126:principal1.CambiarMaquina(principal1.skykiddx1);
  127:principal1.CambiarMaquina(principal1.rocnrope1);
  128:principal1.CambiarMaquina(principal1.repulse1);
  129:principal1.CambiarMaquina(principal1.tnzs1);
  130:principal1.CambiarMaquina(principal1.insectorx1);
  131:principal1.CambiarMaquina(principal1.pacland1);
  132:principal1.CambiarMaquina(principal1.mariob1);
  133:principal1.CambiarMaquina(principal1.solomon1);
  134:principal1.CambiarMaquina(principal1.combatsc1);
  135:principal1.CambiarMaquina(principal1.hvyunit1);
  136:principal1.CambiarMaquina(principal1.pow1);
  137:principal1.CambiarMaquina(principal1.streetsm1);
  138:principal1.CambiarMaquina(principal1.p471);
  139:principal1.CambiarMaquina(principal1.rodland1);
  140:principal1.CambiarMaquina(principal1.saintdragon1);
  141:principal1.CambiarMaquina(principal1.TimePilot1);
  142:principal1.CambiarMaquina(principal1.Pengo1);
  143:principal1.CambiarMaquina(principal1.Scramble1);
  144:principal1.CambiarMaquina(principal1.Scobra1);
  145:principal1.CambiarMaquina(principal1.Amidar1);
  146:principal1.CambiarMaquina(principal1.twincobr1);
  147:principal1.CambiarMaquina(principal1.FlyingShark1);
  148:principal1.CambiarMaquina(principal1.JrPacman1);
  149:principal1.CambiarMaquina(principal1.Ikari31);
  150:principal1.CambiarMaquina(principal1.searchar1);
  151:principal1.CambiarMaquina(principal1.Choplifter1);
  152:principal1.CambiarMaquina(principal1.mrviking1);
  153:principal1.CambiarMaquina(principal1.SegaNinja1);
  154:principal1.CambiarMaquina(principal1.UpnDown1);
  155:principal1.CambiarMaquina(principal1.flicky1);
  156:principal1.CambiarMaquina(principal1.robocop1);
  157:principal1.CambiarMaquina(principal1.baddudes1);
  158:principal1.CambiarMaquina(principal1.hippo1);
  159:principal1.CambiarMaquina(principal1.tumblep1);
  160:principal1.CambiarMaquina(principal1.funkyjet1);
  161:principal1.CambiarMaquina(principal1.SuperBurgerTime1);
  162:principal1.CambiarMaquina(principal1.cninja1);
  163:principal1.CambiarMaquina(principal1.robocop21);
  164:principal1.CambiarMaquina(principal1.DietGo1);
  165:principal1.CambiarMaquina(principal1.actfancer1);
  166:principal1.CambiarMaquina(principal1.arabian1);
  167:principal1.CambiarMaquina(principal1.digdug1);
  168:principal1.CambiarMaquina(principal1.dkongjr1);
  169:principal1.CambiarMaquina(principal1.dkong31);
  170:principal1.CambiarMaquina(principal1.higemaru1);
  171:principal1.CambiarMaquina(principal1.bagman1);
  172:principal1.CambiarMaquina(principal1.sbagman1);
  173:principal1.CambiarMaquina(principal1.squash1);
  174:principal1.CambiarMaquina(principal1.biomtoy1);
  175:principal1.CambiarMaquina(principal1.congo1);
  176:principal1.CambiarMaquina(principal1.kangaroo1);
  177:principal1.CambiarMaquina(principal1.bionicc1);
  178:principal1.CambiarMaquina(principal1.wwfsuperstar1);
  179:principal1.CambiarMaquina(principal1.rbisland1);
  180:principal1.CambiarMaquina(principal1.rbislande1);
  181:principal1.CambiarMaquina(principal1.Volfied1);
  182:principal1.CambiarMaquina(principal1.Opwolf1);
  183:principal1.CambiarMaquina(principal1.SPang1);
  184:principal1.CambiarMaquina(principal1.Outrun1);
  185:principal1.CambiarMaquina(principal1.elevator1);
  186:principal1.CambiarMaquina(principal1.aliensyn1);
  187:principal1.CambiarMaquina(principal1.wb31);
  188:principal1.CambiarMaquina(principal1.zaxxon1);
  189:principal1.CambiarMaquina(principal1.jungleking1);
  190:principal1.CambiarMaquina(principal1.hharry1);
  191:principal1.CambiarMaquina(principal1.rtype21);
  192:principal1.CambiarMaquina(principal1.todruaga1);
  193:principal1.CambiarMaquina(principal1.motos1);
  194:principal1.CambiarMaquina(principal1.drgnbstr1);
  195:principal1.CambiarMaquina(principal1.vulgus1);
  196:principal1.CambiarMaquina(principal1.ddragon31);
  197:principal1.CambiarMaquina(principal1.blockout1);
  198:principal1.CambiarMaquina(principal1.tetris1);
  199:principal1.CambiarMaquina(principal1.foodf1);
  200:principal1.CambiarMaquina(principal1.snapjack1);
  201:principal1.CambiarMaquina(principal1.cavenger1);
  202:principal1.CambiarMaquina(principal1.pleiads1);
  203:principal1.CambiarMaquina(principal1.mrgoemon1);
  204:principal1.CambiarMaquina(principal1.nemesis1);
  205:principal1.CambiarMaquina(principal1.twinbee1);
  206:principal1.CambiarMaquina(principal1.pirates1);
  207:principal1.CambiarMaquina(principal1.genixfamily1);
  208:principal1.CambiarMaquina(principal1.junofirst1);
  209:principal1.CambiarMaquina(principal1.gyruss1);
  210:principal1.CambiarMaquina(principal1.boogwins1);
  211:principal1.CambiarMaquina(principal1.freekick1);
  212:principal1.CambiarMaquina(principal1.pbaction1);
  213:principal1.CambiarMaquina(principal1.renegade1);
  214:principal1.CambiarMaquina(principal1.tmnt1);
  215:principal1.CambiarMaquina(principal1.ssriders1);
  216:principal1.CambiarMaquina(principal1.gradius31);
  217:principal1.CambiarMaquina(principal1.SpaceInvaders1);
  218:principal1.CambiarMaquina(principal1.Centipede1);
  219:principal1.CambiarMaquina(principal1.Karnov1);
  220:principal1.CambiarMaquina(principal1.chelnov1);
  221:principal1.CambiarMaquina(principal1.aliens1);
  222:principal1.CambiarMaquina(principal1.scontra1);
  223:principal1.CambiarMaquina(principal1.gbusters1);
  224:principal1.CambiarMaquina(principal1.thunderx1);
  225:principal1.CambiarMaquina(principal1.simpsons1);
  226:principal1.CambiarMaquina(principal1.trackfield1);
  227:principal1.CambiarMaquina(principal1.hypersports1);
  228:principal1.CambiarMaquina(principal1.megazone1);
  229:principal1.CambiarMaquina(principal1.spacefb1);
  230:principal1.CambiarMaquina(principal1.ajax1);
  231:principal1.CambiarMaquina(principal1.xevious1);
  232:principal1.CambiarMaquina(principal1.ctribe1);
  233:principal1.CambiarMaquina(principal1.llander1);
  234:principal1.CambiarMaquina(principal1.crushroller1);
  235:principal1.CambiarMaquina(principal1.vendetta1);
  236:principal1.CambiarMaquina(principal1.gauntlet1);
  237:principal1.CambiarMaquina(principal1.sauro1);
  238:principal1.CambiarMaquina(principal1.cclimber1);
  239:principal1.CambiarMaquina(principal1.retofinv1);
  240:principal1.CambiarMaquina(principal1.tetrisatari1);
  241:principal1.CambiarMaquina(principal1.ikari1);
  242:principal1.CambiarMaquina(principal1.athena1);
  243:principal1.CambiarMaquina(principal1.tnk31);
  244:principal1.CambiarMaquina(principal1.peterpak1);
  245:principal1.CambiarMaquina(principal1.gaunt21);
  246:principal1.CambiarMaquina(principal1.defender1);
  247:principal1.CambiarMaquina(principal1.fireball1);
  248:principal1.CambiarMaquina(principal1.mayday1);
  249:principal1.CambiarMaquina(principal1.colony71);
  250:principal1.CambiarMaquina(principal1.bosconian1);
  251:principal1.CambiarMaquina(principal1.hangonjr1);
  252:principal1.CambiarMaquina(principal1.slapshooter1);
  253:principal1.CambiarMaquina(principal1.fantasyzone21);
  254:principal1.CambiarMaquina(principal1.opaopa1);
  255:principal1.CambiarMaquina(principal1.tetrisse1);
  256:principal1.CambiarMaquina(principal1.transformer1);
  257:principal1.CambiarMaquina(principal1.riddleofp1);
  258:principal1.CambiarMaquina(principal1.route161);
  259:principal1.CambiarMaquina(principal1.speakandrescue1);
  260:principal1.CambiarMaquina(principal1.gwarrior1);
  261:principal1.CambiarMaquina(principal1.salamander1);
  262:principal1.CambiarMaquina(principal1.badlands1);
  263:principal1.CambiarMaquina(principal1.indydoom1);
  264:principal1.CambiarMaquina(principal1.marblemadness1);
  265:principal1.CambiarMaquina(principal1.amazon1);
  266:principal1.CambiarMaquina(principal1.galivan1);
  267:principal1.CambiarMaquina(principal1.dangar1);
  268:principal1.CambiarMaquina(principal1.lastduel1);
  269:principal1.CambiarMaquina(principal1.madgear1);
  270:principal1.CambiarMaquina(principal1.leds20111);
  271:principal1.CambiarMaquina(principal1.gigas1);
  272:principal1.CambiarMaquina(principal1.gigasm21);
  273:principal1.CambiarMaquina(principal1.omega1);
  274:principal1.CambiarMaquina(principal1.pbillrd1);
  275:principal1.CambiarMaquina(principal1.armedf1);
  276:principal1.CambiarMaquina(principal1.terraforce1);
  277:principal1.CambiarMaquina(principal1.crazyclimber21);
  278:principal1.CambiarMaquina(principal1.legion1);
  279:principal1.CambiarMaquina(principal1.aso1);
  280:principal1.CambiarMaquina(principal1.firetrap1);
  281:principal1.CambiarMaquina(principal1.puzzle3x31);
  282:principal1.CambiarMaquina(principal1.casanova1);
  283:principal1.CambiarMaquina(principal1.N1945K32);
  284:principal1.CambiarMaquina(principal1.flagrall1);
  285:principal1.CambiarMaquina(principal1.bloodbros1);
  286:principal1.CambiarMaquina(principal1.skysmasher1);
  287:principal1.CambiarMaquina(principal1.baraduke1);
  288:principal1.CambiarMaquina(principal1.metrocross1);
  289:principal1.CambiarMaquina(principal1.returnishtar1);
  290:principal1.CambiarMaquina(principal1.genpeitd1);
  291:principal1.CambiarMaquina(principal1.wndrmomo1);
  292:principal1.CambiarMaquina(principal1.AlteredBeast1);
  293:principal1.CambiarMaquina(principal1.Goldenaxe1);
  294:principal1.CambiarMaquina(principal1.DynamiteDux1);
  295:principal1.CambiarMaquina(principal1.eswat1);
  296:principal1.CambiarMaquina(principal1.passingshot1);
  297:principal1.CambiarMaquina(principal1.aurail1);
  298:principal1.CambiarMaquina(principal1.hellfire1);
  299:principal1.CambiarMaquina(principal1.lnc1);
  300:principal1.CambiarMaquina(principal1.mmonkey1);
  301:principal1.CambiarMaquina(principal1.karatechamp1);
  302:principal1.CambiarMaquina(principal1.thundercade1);
  303:principal1.CambiarMaquina(principal1.twineagle1);
  304:principal1.CambiarMaquina(principal1.thunderl1);
  305:principal1.CambiarMaquina(principal1.mspactwin1);
  306:principal1.CambiarMaquina(principal1.exterm1);
  307:principal1.CambiarMaquina(principal1.robokid1);
  308:principal1.CambiarMaquina(principal1.mrdocastle1);
  309:principal1.CambiarMaquina(principal1.dorunrun1);
  310:principal1.CambiarMaquina(principal1.dowild1);
  311:principal1.CambiarMaquina(principal1.jjack1);
  312:principal1.CambiarMaquina(principal1.kickrider1);
  313:principal1.CambiarMaquina(principal1.idsoccer1);
  314:principal1.CambiarMaquina(principal1.ccastles1);
  315:principal1.CambiarMaquina(principal1.flower1);
  316:principal1.CambiarMaquina(principal1.slyspy1);
  317:principal1.CambiarMaquina(principal1.bdash1);
  318:principal1.CambiarMaquina(principal1.spdodgeb1);
  319:principal1.CambiarMaquina(principal1.senjyo1);
  320:principal1.CambiarMaquina(principal1.baluba1);
  321:principal1.CambiarMaquina(principal1.joust1);
  322:principal1.CambiarMaquina(principal1.robotron1);
  323:principal1.CambiarMaquina(principal1.stargate1);
  324:principal1.CambiarMaquina(principal1.tapper1);
  325:principal1.CambiarMaquina(principal1.arkanoid1);
  326:principal1.CambiarMaquina(principal1.sidearms1);
  327:principal1.CambiarMaquina(principal1.speedrumbler1);
  328:principal1.CambiarMaquina(principal1.chinagate1);
  329:principal1.CambiarMaquina(principal1.magmax1);
  330:principal1.CambiarMaquina(principal1.SRDMission1);
  331:principal1.CambiarMaquina(principal1.airwolf1);
  332:principal1.CambiarMaquina(principal1.ambush1);
  333:principal1.CambiarMaquina(principal1.superduck1);
  334:principal1.CambiarMaquina(principal1.hangon1);
  335:principal1.CambiarMaquina(principal1.enduroracer1);
  336:principal1.CambiarMaquina(principal1.spaceharrier1);
  337:principal1.CambiarMaquina(principal1.N64thstreet1);
  338:principal1.CambiarMaquina(principal1.ShadowWarriors1);
  339:principal1.CambiarMaquina(principal1.wildfang1);
  340:principal1.CambiarMaquina(principal1.raiden1);
  341:principal1.CambiarMaquina(principal1.twins1);
  342:principal1.CambiarMaquina(principal1.twinsed1);
  343:principal1.CambiarMaquina(principal1.hotblocks1);
  344:principal1.CambiarMaquina(principal1.missilecommand1);
  345:principal1.CambiarMaquina(principal1.supermissileattack1);
  346:principal1.CambiarMaquina(principal1.superzaxxon1);
  347:principal1.CambiarMaquina(principal1.futurespy1);
  348:principal1.CambiarMaquina(principal1.millipede1);
  349:principal1.CambiarMaquina(principal1.gaplus1);
  350:principal1.CambiarMaquina(principal1.superxevious1);
  351:principal1.CambiarMaquina(principal1.grobda1);
  352:principal1.CambiarMaquina(principal1.pacnpal1);
  353:principal1.CambiarMaquina(principal1.birdiy1);
  354:principal1.CambiarMaquina(principal1.wilytower1);
  355:principal1.CambiarMaquina(principal1.FightingBasketball1);
  356:principal1.CambiarMaquina(principal1.diverboy1);
  357:principal1.CambiarMaquina(principal1.mugsmashers1);
  358:principal1.CambiarMaquina(principal1.steelforce1);
  359:principal1.CambiarMaquina(principal1.twinbrats1);
  360:principal1.CambiarMaquina(principal1.mortalrace1);
  361:principal1.CambiarMaquina(principal1.bankpanic1);
  362:principal1.CambiarMaquina(principal1.combathawk1);
  363:principal1.CambiarMaquina(principal1.anteater1);
  364:principal1.CambiarMaquina(principal1.appoooh1);
  365:principal1.CambiarMaquina(principal1.robowres1);
  366:principal1.CambiarMaquina(principal1.armoredcar1);
  367:principal1.CambiarMaquina(principal1.n88games1);
  368:principal1.CambiarMaquina(principal1.avengers1);
  369:principal1.CambiarMaquina(principal1.theend1);
  370:principal1.CambiarMaquina(principal1.battleofatlantis1);
  371:principal1.CambiarMaquina(principal1.bluehawk1);
  372:principal1.CambiarMaquina(principal1.lastday1);
  373:principal1.CambiarMaquina(principal1.gulfstorm1);
  374:principal1.CambiarMaquina(principal1.pollux1);
  375:principal1.CambiarMaquina(principal1.flyingtiger1);
  376:principal1.CambiarMaquina(principal1.skyskipper1);
  377:principal1.CambiarMaquina(principal1.blueprint1);
  378:principal1.CambiarMaquina(principal1.saturn1);
  379:principal1.CambiarMaquina(principal1.grasspin1);
  380:principal1.CambiarMaquina(principal1.burglarx1);
  381:principal1.CambiarMaquina(principal1.zeropoint1);
  382:principal1.CambiarMaquina(principal1.calipso1);
  383:principal1.CambiarMaquina(principal1.caloriekun1);
  384:principal1.CambiarMaquina(principal1.gardia1);
  385:principal1.CambiarMaquina(principal1.cavelon1);
  386:principal1.CambiarMaquina(principal1.comebacktoto1);
  387:principal1.CambiarMaquina(principal1.hyperpacman1);
  388:principal1.CambiarMaquina(principal1.kikikaikai1);
  389:principal1.CambiarMaquina(principal1.kickandrun1);
  390:principal1.CambiarMaquina(principal1.lasso1);
  391:principal1.CambiarMaquina(principal1.chameleon1);
  392:principal1.CambiarMaquina(principal1.lastmission1);
  393:principal1.CambiarMaquina(principal1.shackled1);
  394:principal1.CambiarMaquina(principal1.gondomania1);
  395:principal1.CambiarMaquina(principal1.garyoretsuden1);
  396:principal1.CambiarMaquina(principal1.captainsilver1);
  397:principal1.CambiarMaquina(principal1.cobracommand1);
  398:principal1.CambiarMaquina(principal1.ghostbusters1);
  399:principal1.CambiarMaquina(principal1.oscar1);
  400:principal1.CambiarMaquina(principal1.roadfighter1);
  401:principal1.CambiarMaquina(principal1.ponpoko1);
  402:principal1.CambiarMaquina(principal1.woodpecker1);
  403:principal1.CambiarMaquina(principal1.eyes1);
  404:principal1.CambiarMaquina(principal1.alibaba1);
  405:principal1.CambiarMaquina(principal1.piranha1);
  406:principal1.CambiarMaquina(principal1.finalstarforce1);
  407:principal1.CambiarMaquina(principal1.WyvernF01);
  408:principal1.CambiarMaquina(principal1.RiotCity1);
  409:principal1.CambiarMaquina(principal1.sdi1);
  410:principal1.CambiarMaquina(principal1.cotton1);
  411:principal1.CambiarMaquina(principal1.dotron1);
  412:principal1.CambiarMaquina(principal1.tron1);
  413:principal1.CambiarMaquina(principal1.timber1);
  414:principal1.CambiarMaquina(principal1.shollow1);
  415:principal1.CambiarMaquina(principal1.domino1);
  416:principal1.CambiarMaquina(principal1.wacko1);
  417:principal1.CambiarMaquina(principal1.nastar1);
  418:principal1.CambiarMaquina(principal1.masterw1);
  1000:principal1.CambiarMaquina(principal1.NES1);
  1001:principal1.CambiarMaquina(principal1.colecovision1);
  1002:principal1.CambiarMaquina(principal1.Gameboy1);
  1003:principal1.CambiarMaquina(principal1.CHIP81);
  1004:principal1.CambiarMaquina(principal1.SegaMS1);
  1005:principal1.CambiarMaquina(principal1.SG10001);
  1006:principal1.CambiarMaquina(principal1.SegaGG1);
  1007:principal1.CambiarMaquina(principal1.SCV1);
  1008:principal1.CambiarMaquina(principal1.genesis1);
  1009:principal1.CambiarMaquina(principal1.pv1000);
  1010:principal1.CambiarMaquina(principal1.pv2000);
  2000:principal1.CambiarMaquina(principal1.DonkeyKongjr1);
  2001:principal1.CambiarMaquina(principal1.DonkeyKongII1);
  2002:principal1.CambiarMaquina(principal1.MarioBros1);
end;
end;

procedure todos_false;
begin
//Computer
principal1.Spectrum48K1.Checked:=false;
principal1.Spectrum128K1.Checked:=false;
principal1.Spectrum31.Checked:=false;
principal1.Spectrum2A1.Checked:=false;
principal1.Spectrum21.Checked:=false;
principal1.Spectrum16k1.Checked:=false;
principal1.CPC1.Checked:=false;
principal1.CPC6641.Checked:=false;
principal1.CPC61281.Checked:=false;
principal1.c641.Checked:=false;
principal1.oricatmos1.Checked:=false;
principal1.oric1_1.Checked:=false;
//Arcade
principal1.phoenix1.Checked:=false;
principal1.bombjack1.Checked:=false;
principal1.pacman1.Checked:=false;
principal1.frogger1.Checked:=false;
principal1.dkong1.Checked:=false;
principal1.blacktiger1.Checked:=false;
principal1.gberet1.Checked:=false;
principal1.StarForce1.Checked:=false;
principal1.PitfallII1.Checked:=false;
principal1.jungler1.Checked:=false;
principal1.pooyan1.Checked:=false;
principal1.Rygar1.Checked:=false;
principal1.misteriousstone1.Checked:=false;
principal1.Commando1.Checked:=false;
principal1.gng1.Checked:=false;
principal1.mikie1.Checked:=false;
principal1.shaolin1.Checked:=false;
principal1.yiear1.Checked:=false;
principal1.asteroids1.Checked:=false;
principal1.sonson1.Checked:=false;
principal1.citycon1.Checked:=false;
principal1.BurgerTime1.Checked:=false;
principal1.ExpressRaider1.Checked:=false;
principal1.superbasketball1.Checked:=false;
principal1.teddy1.Checked:=false;
principal1.wboy1.Checked:=false;
principal1.wbml1.Checked:=false;
principal1.ladybug1.Checked:=false;
principal1.tehkanwc1.Checked:=false;
principal1.popeye1.Checked:=false;
principal1.Psychic51.Checked:=false;
principal1.terracre1.Checked:=false;
principal1.kungfum1.Checked:=false;
principal1.shootout1.Checked:=false;
principal1.Vigilante1.Checked:=false;
principal1.bubblebobble1.Checked:=false;
principal1.Jackal1.checked:=false;
principal1.Galaxian1.Checked:=false;
principal1.jumpb1.Checked:=false;
principal1.mooncresta1.Checked:=false;
principal1.RallyX1.Checked:=false;
principal1.prehisle1.Checked:=false;
principal1.TigerRoad1.Checked:=false;
principal1.F1Dream1.Checked:=false;
principal1.Snowbros1.Checked:=false;
principal1.toki1.Checked:=false;
principal1.Contra1.Checked:=false;
principal1.Mappy1.Checked:=false;
principal1.Rastan1.Checked:=false;
principal1.legendw1.Checked:=false;
principal1.SectionZ1.Checked:=false;
principal1.Trojan1.Checked:=false;
principal1.SF1.Checked:=false;
principal1.DigDug21.Checked:=false;
principal1.SPacman1.Checked:=false;
principal1.Galaga1.Checked:=false;
principal1.Xain1.Checked:=false;
principal1.HardHead1.Checked:=false;
principal1.hardhead21.checked:=false;
principal1.sbombers1.Checked:=false;
principal1.NewRallyX1.Checked:=false;
principal1.bjtwin1.Checked:=false;
principal1.Spelunker1.Checked:=false;
principal1.Spelunker21.Checked:=false;
principal1.ldrun1.Checked:=false;
principal1.ldrun21.Checked:=false;
principal1.knJoe1.Checked:=false;
principal1.Wardner1.Checked:=false;
principal1.BigKarnak1.Checked:=false;
principal1.ExedExes1.Checked:=false;
principal1.GunSmoke1.Checked:=false;
principal1.N19421.Checked:=false;
principal1.N19431.Checked:=false;
principal1.N1943kai1.Checked:=false;
principal1.JailBreak1.Checked:=false;
principal1.Circusc1.Checked:=false;
principal1.IronHorse1.Checked:=false;
principal1.RType1.Checked:=false;
principal1.MSPacman1.Checked:=false;
principal1.BrkThru1.Checked:=false;
principal1.Darwin1.Checked:=false;
principal1.SRD1.Checked:=false;
principal1.ddragon1.Checked:=false;
principal1.MrDo1.Checked:=false;
principal1.theglob1.Checked:=false;
principal1.superglob1.Checked:=false;
principal1.ddragon21.Checked:=false;
principal1.Silkworm1.Checked:=false;
principal1.tigerh1.Checked:=false;
principal1.SlapFight1.Checked:=false;
principal1.LegendofKage1.Checked:=false;
principal1.thoop1.checked:=false;
principal1.Cabal1.Checked:=false;
principal1.ghouls1.Checked:=false;
principal1.ffight1.Checked:=false;
principal1.kod1.Checked:=false;
principal1.sf21.Checked:=false;
principal1.strider1.Checked:=false;
principal1.wonder31.Checked:=false;
principal1.ccommando1.Checked:=false;
principal1.knights1.Checked:=false;
principal1.sf2ce1.Checked:=false;
principal1.dino1.Checked:=false;
principal1.Punisher1.Checked:=false;
principal1.Shinobi1.Checked:=false;
principal1.AlexKid1.Checked:=false;
principal1.FantasyZone1.Checked:=false;
principal1.tp841.Checked:=false;
principal1.tutankhm1.Checked:=false;
principal1.Pang1.Checked:=false;
principal1.ninjakid21.Checked:=false;
principal1.ArkArea1.Checked:=false;
principal1.mnight1.Checked:=false;
principal1.SkyKid1.Checked:=false;
principal1.rthunder1.Checked:=false;
principal1.hopmappy1.Checked:=false;
principal1.skykiddx1.Checked:=false;
principal1.RocnRope1.Checked:=false;
principal1.repulse1.checked:=false;
principal1.tnzs1.Checked:=false;
principal1.InsectorX1.Checked:=false;
principal1.Pacland1.Checked:=false;
principal1.mariob1.Checked:=false;
principal1.Solomon1.Checked:=false;
principal1.combatsc1.Checked:=false;
principal1.hvyunit1.Checked:=false;
principal1.pow1.Checked:=false;
principal1.streetsm1.checked:=false;
principal1.P471.Checked:=false;
principal1.RodLand1.Checked:=false;
principal1.SaintDragon1.Checked:=false;
principal1.TimePilot1.Checked:=false;
principal1.Pengo1.Checked:=false;
principal1.scramble1.checked:=false;
principal1.scobra1.Checked:=false;
principal1.Amidar1.Checked:=false;
principal1.twincobr1.checked:=false;
principal1.FlyingShark1.Checked:=false;
principal1.JrPacMan1.Checked:=false;
principal1.Ikari31.Checked:=false;
principal1.Searchar1.Checked:=false;
principal1.Choplifter1.Checked:=false;
principal1.mrviking1.Checked:=false;
principal1.SegaNinja1.Checked:=false;
principal1.UpnDown1.Checked:=false;
principal1.flicky1.Checked:=false;
principal1.robocop1.Checked:=false;
principal1.Baddudes1.Checked:=false;
principal1.Hippo1.Checked:=false;
principal1.tumblep1.checked:=false;
principal1.funkyjet1.checked:=false;
principal1.SuperBurgerTime1.Checked:=false;
principal1.cninja1.Checked:=false;
principal1.Robocop21.Checked:=false;
principal1.DietGo1.Checked:=false;
principal1.ActFancer1.Checked:=false;
principal1.Arabian1.Checked:=false;
principal1.DigDug1.Checked:=false;
principal1.dkongjr1.Checked:=false;
principal1.dkong31.Checked:=false;
principal1.Higemaru1.Checked:=false;
principal1.Bagman1.Checked:=false;
principal1.sBagman1.Checked:=false;
principal1.squash1.Checked:=false;
principal1.biomtoy1.Checked:=false;
principal1.congo1.Checked:=false;
principal1.kangaroo1.Checked:=false;
principal1.bionicc1.Checked:=false;
principal1.wwfsuperstar1.Checked:=false;
principal1.rbisland1.checked:=false;
principal1.rbislande1.checked:=false;
principal1.Volfied1.Checked:=false;
principal1.opwolf1.Checked:=false;
principal1.spang1.checked:=false;
principal1.Outrun1.Checked:=false;
principal1.elevator1.checked:=false;
principal1.aliensyn1.checked:=false;
principal1.wb31.checked:=false;
principal1.zaxxon1.checked:=false;
principal1.jungleking1.checked:=false;
principal1.hharry1.Checked:=false;
principal1.RType21.Checked:=false;
principal1.todruaga1.checked:=false;
principal1.motos1.checked:=false;
principal1.drgnbstr1.checked:=false;
principal1.vulgus1.checked:=false;
principal1.ddragon31.Checked:=false;
principal1.BlockOut1.Checked:=false;
principal1.tetris1.checked:=false;
principal1.foodf1.checked:=false;
principal1.snapjack1.checked:=false;
principal1.cavenger1.Checked:=false;
principal1.pleiads1.checked:=false;
principal1.MrGoemon1.Checked:=false;
principal1.Nemesis1.Checked:=false;
principal1.twinbee1.Checked:=false;
principal1.Pirates1.Checked:=false;
principal1.GenixFamily1.Checked:=false;
principal1.junofirst1.checked:=false;
principal1.gyruss1.checked:=false;
principal1.boogwins1.checked:=false;
principal1.freekick1.checked:=false;
principal1.pbaction1.checked:=false;
principal1.renegade1.checked:=false;
principal1.tmnt1.checked:=false;
principal1.ssriders1.checked:=false;
principal1.gradius31.checked:=false;
principal1.SpaceInvaders1.Checked:=false;
principal1.centipede1.checked:=false;
principal1.karnov1.checked:=false;
principal1.chelnov1.checked:=false;
principal1.aliens1.checked:=false;
principal1.scontra1.checked:=false;
principal1.gbusters1.checked:=false;
principal1.thunderx1.checked:=false;
principal1.simpsons1.checked:=false;
principal1.trackfield1.checked:=false;
principal1.HyperSports1.Checked:=false;
principal1.megazone1.checked:=false;
principal1.spacefb1.checked:=false;
principal1.ajax1.checked:=false;
principal1.xevious1.checked:=false;
principal1.ctribe1.checked:=false;
principal1.llander1.checked:=false;
principal1.crushroller1.checked:=false;
principal1.vendetta1.checked:=false;
principal1.gauntlet1.checked:=false;
principal1.sauro1.checked:=false;
principal1.cclimber1.checked:=false;
principal1.retofinv1.checked:=false;
principal1.tetrisatari1.Checked:=false;
principal1.ikari1.Checked:=false;
principal1.athena1.Checked:=false;
principal1.tnk31.Checked:=false;
principal1.peterpak1.Checked:=false;
principal1.gaunt21.Checked:=false;
principal1.defender1.Checked:=false;
principal1.fireball1.Checked:=false;
principal1.mayday1.Checked:=false;
principal1.colony71.Checked:=false;
principal1.bosconian1.Checked:=false;
principal1.hangonjr1.Checked:=false;
principal1.slapshooter1.Checked:=false;
principal1.fantasyzone21.Checked:=false;
principal1.opaopa1.Checked:=false;
principal1.tetrisse1.Checked:=false;
principal1.transformer1.Checked:=false;
principal1.riddleofp1.Checked:=false;
principal1.route161.Checked:=false;
principal1.speakandrescue1.Checked:=false;
principal1.gwarrior1.Checked:=false;
principal1.salamander1.Checked:=false;
principal1.badlands1.Checked:=false;
principal1.indydoom1.Checked:=false;
principal1.marblemadness1.Checked:=false;
principal1.amazon1.Checked:=false;
principal1.galivan1.Checked:=false;
principal1.dangar1.Checked:=false;
principal1.lastduel1.Checked:=false;
principal1.madgear1.Checked:=false;
principal1.leds20111.Checked:=false;
principal1.gigas1.Checked:=false;
principal1.gigasm21.Checked:=false;
principal1.omega1.Checked:=false;
principal1.pbillrd1.Checked:=false;
principal1.armedf1.Checked:=false;
principal1.terraforce1.Checked:=false;
principal1.crazyclimber21.Checked:=false;
principal1.legion1.Checked:=false;
principal1.aso1.Checked:=false;
principal1.firetrap1.Checked:=false;
principal1.puzzle3x31.Checked:=false;
principal1.casanova1.Checked:=false;
principal1.N1945K32.Checked:=false;
principal1.flagrall1.Checked:=false;
principal1.bloodbros1.Checked:=false;
principal1.skysmasher1.Checked:=false;
principal1.baraduke1.Checked:=false;
principal1.MetroCross1.Checked:=false;
principal1.returnishtar1.Checked:=false;
principal1.genpeitd1.Checked:=false;
principal1.wndrmomo1.Checked:=false;
principal1.AlteredBeast1.checked:=false;
principal1.goldenaxe1.checked:=false;
principal1.dynamitedux1.checked:=false;
principal1.eswat1.checked:=false;
principal1.passingshot1.checked:=false;
principal1.aurail1.checked:=false;
principal1.hellfire1.checked:=false;
principal1.lnc1.checked:=false;
principal1.mmonkey1.checked:=false;
principal1.karatechamp1.checked:=false;
principal1.thundercade1.checked:=false;
principal1.twineagle1.checked:=false;
principal1.thunderl1.checked:=false;
principal1.mspactwin1.checked:=false;
principal1.exterm1.checked:=false;
principal1.robokid1.checked:=false;
principal1.mrdocastle1.checked:=false;
principal1.dorunrun1.checked:=false;
principal1.dowild1.checked:=false;
principal1.jjack1.checked:=false;
principal1.kickrider1.checked:=false;
principal1.idsoccer1.checked:=false;
principal1.ccastles1.checked:=false;
principal1.flower1.checked:=false;
principal1.slyspy1.checked:=false;
principal1.bdash1.checked:=false;
principal1.spdodgeb1.checked:=false;
principal1.senjyo1.checked:=false;
principal1.baluba1.checked:=false;
principal1.joust1.checked:=false;
principal1.robotron1.checked:=false;
principal1.stargate1.checked:=false;
principal1.tapper1.checked:=false;
principal1.arkanoid1.checked:=false;
principal1.sidearms1.checked:=false;
principal1.speedrumbler1.checked:=false;
principal1.chinagate1.checked:=false;
principal1.magmax1.checked:=false;
principal1.SRDMission1.Checked:=false;
principal1.airwolf1.Checked:=false;
principal1.ambush1.Checked:=false;
principal1.superduck1.Checked:=false;
principal1.hangon1.Checked:=false;
principal1.enduroracer1.Checked:=false;
principal1.spaceharrier1.Checked:=false;
principal1.N64thstreet1.Checked:=false;
principal1.shadowwarriors1.Checked:=false;
principal1.wildfang1.Checked:=false;
principal1.raiden1.Checked:=false;
principal1.twins1.Checked:=false;
principal1.twinsed1.Checked:=false;
principal1.hotblocks1.Checked:=false;
principal1.missilecommand1.Checked:=false;
principal1.supermissileattack1.Checked:=false;
principal1.superzaxxon1.Checked:=false;
principal1.futurespy1.Checked:=false;
principal1.millipede1.Checked:=false;
principal1.gaplus1.Checked:=false;
principal1.superxevious1.Checked:=false;
principal1.grobda1.Checked:=false;
principal1.pacnpal1.Checked:=false;
principal1.birdiy1.Checked:=false;
principal1.wilytower1.Checked:=false;
principal1.FightingBasketball1.Checked:=false;
principal1.diverboy1.Checked:=false;
principal1.mugsmashers1.Checked:=false;
principal1.steelforce1.Checked:=false;
principal1.twinbrats1.Checked:=false;
principal1.mortalrace1.Checked:=false;
principal1.bankpanic1.Checked:=false;
principal1.combathawk1.Checked:=false;
principal1.anteater1.Checked:=false;
principal1.appoooh1.Checked:=false;
principal1.robowres1.Checked:=false;
principal1.armoredcar1.Checked:=false;
principal1.n88games1.Checked:=false;
principal1.avengers1.Checked:=false;
principal1.theend1.Checked:=false;
principal1.battleofatlantis1.Checked:=false;
principal1.bluehawk1.Checked:=false;
principal1.lastday1.Checked:=false;
principal1.gulfstorm1.Checked:=false;
principal1.pollux1.Checked:=false;
principal1.flyingtiger1.Checked:=false;
principal1.skyskipper1.Checked:=false;
principal1.blueprint1.Checked:=false;
principal1.saturn1.Checked:=false;
principal1.grasspin1.Checked:=false;
principal1.burglarx1.Checked:=false;
principal1.ZeroPoint1.Checked:=false;
principal1.calipso1.Checked:=false;
principal1.caloriekun1.Checked:=false;
principal1.gardia1.Checked:=false;
principal1.cavelon1.Checked:=false;
principal1.comebacktoto1.Checked:=false;
principal1.hyperpacman1.Checked:=false;
principal1.kikikaikai1.Checked:=false;
principal1.kickandrun1.Checked:=false;
principal1.lasso1.Checked:=false;
principal1.chameleon1.Checked:=false;
principal1.lastmission1.Checked:=false;
principal1.shackled1.Checked:=false;
principal1.gondomania1.Checked:=false;
principal1.GaryoRetsuden1.Checked:=false;
principal1.captainsilver1.Checked:=false;
principal1.cobracommand1.Checked:=false;
principal1.ghostbusters1.Checked:=false;
principal1.oscar1.Checked:=false;
principal1.roadfighter1.Checked:=false;
principal1.ponpoko1.Checked:=false;
principal1.woodpecker1.Checked:=false;
principal1.eyes1.Checked:=false;
principal1.alibaba1.Checked:=false;
principal1.piranha1.Checked:=false;
principal1.finalstarforce1.Checked:=false;
principal1.WyvernF01.Checked:=false;
principal1.riotcity1.Checked:=false;
principal1.sdi1.Checked:=false;
principal1.cotton1.Checked:=false;
principal1.dotron1.Checked:=false;
principal1.tron1.Checked:=false;
principal1.timber1.Checked:=false;
principal1.shollow1.Checked:=false;
principal1.domino1.Checked:=false;
principal1.wacko1.Checked:=false;
principal1.nastar1.Checked:=false;
principal1.masterw1.Checked:=false;
//consolas
principal1.NES1.Checked:=false;
principal1.colecovision1.Checked:=false;
principal1.GameBoy1.Checked:=false;
principal1.chip81.checked:=false;
principal1.segams1.checked:=false;
principal1.sg10001.checked:=false;
principal1.segagg1.checked:=false;
principal1.scv1.checked:=false;
principal1.genesis1.checked:=false;
principal1.pv1000.checked:=false;
principal1.pv2000.checked:=false;
//gnw
principal1.DonkeyKongjr1.checked:=false;
principal1.DonkeyKongII1.checked:=false;
principal1.MarioBros1.checked:=false;
end;

procedure menus_false(driver:word);
begin
principal1.BitBtn1.visible:=false; //Configurar ordenador/consola
principal1.BitBtn10.visible:=false; //Disco
principal1.BitBtn11.visible:=false; //Save Snapshot
principal1.BitBtn9.visible:=false; //Load Snapshot
principal1.BitBtn12.visible:=false; //Poke
principal1.BitBtn14.visible:=false; //Fast
principal1.Panel2.visible:=false; //Lateral
principal1.BitBtn2.Enabled:=true;
principal1.BitBtn3.Enabled:=true; //Play/Pause
principal1.BitBtn5.Enabled:=true;
principal1.BitBtn6.Enabled:=true;
principal1.BitBtn19.Enabled:=true;
principal1.BitBtn1.Enabled:=true;
principal1.BitBtn9.Enabled:=true;
principal1.BitBtn10.Enabled:=true;
principal1.BitBtn11.Enabled:=true;
principal1.BitBtn12.Enabled:=true;
principal1.BitBtn14.Enabled:=true;
principal1.BitBtn8.enabled:=false; //Arcade config
principal1.BitBtn10.Hint:=leng.hints[8];
case driver of
  0..6:begin
          principal1.Panel2.visible:=true;
          principal1.BitBtn1.visible:=true; //Configurar ordenador/consola
          principal1.BitBtn10.visible:=true;  //Disco
          principal1.BitBtn10.enabled:=(driver=2);
          principal1.BitBtn11.visible:=true; //Save Snapshot
          principal1.BitBtn9.visible:=true; //Load Snapshot
          principal1.BitBtn12.visible:=true; //Poke
          principal1.BitBtn14.visible:=true; //Fast
       end;
  7..9:begin  //Amstrad CPC
          principal1.Panel2.visible:=true;
          principal1.BitBtn1.visible:=true; //Configurar ordenador/consola
          principal1.BitBtn10.enabled:=(driver<>7); //Disco
          principal1.BitBtn10.visible:=true;  //Disco
          principal1.BitBtn11.visible:=true; //Save Snapshot
          principal1.BitBtn9.visible:=true; //Load Snapshot
       end;
  3000:begin //C64
          principal1.Panel2.visible:=true;
          principal1.BitBtn1.visible:=true; //Configurar ordenador/consola
          principal1.BitBtn10.visible:=true; //Disco
          principal1.BitBtn10.enabled:=true;
          principal1.BitBtn11.visible:=true; //Save Snapshot
          principal1.BitBtn9.visible:=true; //Load Snapshot
       end;
  3001,3002:begin //Oric
          principal1.Panel2.visible:=true;
          //principal1.BitBtn1.visible:=true; //Configurar ordenador/consola
          //principal1.BitBtn1.enabled:=true;
          principal1.BitBtn10.visible:=true; //Disco
          principal1.BitBtn10.enabled:=true;
          principal1.BitBtn11.visible:=false; //Save Snapshot
          principal1.BitBtn9.visible:=true; //Load Snapshot
       end;
  10..999:principal1.BitBtn8.enabled:=true;  //Arcade
  1008:begin
          principal1.Panel2.visible:=true;
          principal1.BitBtn10.visible:=true; //Cartucho
          principal1.BitBtn10.Hint:=leng.hints[20];
       end;
  1000,1001,1003,1005,1006,1007,1009,1010:begin
          principal1.Panel2.visible:=true;
          principal1.BitBtn10.visible:=true; //Cartcuho
          principal1.BitBtn11.visible:=true; //Snapshot
          principal1.BitBtn10.Hint:=leng.hints[20];
       end;
  1002,1004:begin
          principal1.Panel2.visible:=true;
          principal1.BitBtn1.visible:=true; //Config
          principal1.BitBtn10.visible:=true; //Cartucho
          principal1.BitBtn11.visible:=true; //Snapshot
          principal1.BitBtn10.Hint:=leng.hints[20];
       end;
end;
end;

procedure cargar_maquina(tmaquina:word);
begin
case tmaquina of
  0,5:llamadas_maquina.iniciar:=iniciar_48k;
  1,4:llamadas_maquina.iniciar:=iniciar_128k;
  2,3:llamadas_maquina.iniciar:=iniciar_3;
  7,8,9:llamadas_maquina.iniciar:=iniciar_cpc;
  3000:llamadas_maquina.iniciar:=iniciar_c64;
  3001,3002:llamadas_maquina.iniciar:=iniciar_oric;
  //arcade
  10,88,234,305,353,401,402,403,404,405:llamadas_maquina.iniciar:=iniciar_pacman;
  11,202:llamadas_maquina.iniciar:=iniciar_phoenix;
  12:llamadas_maquina.iniciar:=iniciar_ms;
  13,383:llamadas_maquina.iniciar:=iniciar_bombjack;
  14,47,48,49,143,144,145,363,366,369,370,382,385:llamadas_maquina.iniciar:=iniciar_galaxian;
  15,168,169:llamadas_maquina.iniciar:=iniciar_dkong;
  16:llamadas_maquina.iniciar:=iniciar_blktiger;
  17,203:llamadas_maquina.iniciar:=iniciar_gberet;
  18:llamadas_maquina.iniciar:=iniciar_commando;
  19:llamadas_maquina.iniciar:=iniciar_gng;
  20:llamadas_maquina.iniciar:=iniciar_mikie;
  21:llamadas_maquina.iniciar:=iniciar_shaolin;
  22:llamadas_maquina.iniciar:=iniciar_yiear;
  23,233:llamadas_maquina.iniciar:=iniciar_as;
  24:llamadas_maquina.iniciar:=iniciar_sonson;
  25,319,320:llamadas_maquina.iniciar:=iniciar_starforce;
  26,97:llamadas_maquina.iniciar:=iniciar_tecmo;
  27,35,36,37,151,152,153,154,155,384:cargar_system1; //Este lo dejo!!
  28:llamadas_maquina.iniciar:=iniciar_pooyan;
  29,50,70:llamadas_maquina.iniciar:=iniciar_rallyxh;
  30:llamadas_maquina.iniciar:=iniciar_citycon;
  31,299,300:llamadas_maquina.iniciar:=iniciar_btime;
  32:llamadas_maquina.iniciar:=iniciar_expraid;
  33:llamadas_maquina.iniciar:=iniciar_sbasketb;
  34,200,201:llamadas_maquina.iniciar:=iniciar_ladybug;
  38:llamadas_maquina.iniciar:=iniciar_tehkanwc;
  39,376:llamadas_maquina.iniciar:=iniciar_popeye;
  40:llamadas_maquina.iniciar:=iniciar_psychic5;
  41,265:llamadas_maquina.iniciar:=iniciar_terracre;
  42,72,73,74,75:llamadas_maquina.iniciar:=iniciar_irem_m62;
  43:llamadas_maquina.iniciar:=iniciar_shootout;
  44:llamadas_maquina.iniciar:=iniciar_vigilante;
  45:llamadas_maquina.iniciar:=iniciar_jackal;
  46:llamadas_maquina.iniciar:=iniciar_bublbobl;
  51:llamadas_maquina.iniciar:=iniciar_prehisle;
  52,53:llamadas_maquina.iniciar:=iniciar_tigeroad;
  54,386,387:llamadas_maquina.iniciar:=iniciar_snowbros;
  55:llamadas_maquina.iniciar:=iniciar_toki;
  56:llamadas_maquina.iniciar:=iniciar_contra;
  57,63,64,192,193,351,352:llamadas_maquina.iniciar:=iniciar_mappyhw;
  58:llamadas_maquina.iniciar:=iniciar_rastan;
  59,60,61,247,368:llamadas_maquina.iniciar:=iniciar_lwings;
  62:llamadas_maquina.iniciar:=iniciar_sfighter;
  65,167,231,250,350:llamadas_maquina.iniciar:=iniciar_galagahw;
  66:llamadas_maquina.iniciar:=iniciar_xain;
  67,68:llamadas_maquina.iniciar:=iniciar_suna_hw;
  69,71:llamadas_maquina.iniciar:=iniciar_nmk16;
  76:llamadas_maquina.iniciar:=iniciar_knjoe;
  77:llamadas_maquina.iniciar:=iniciar_wardnerhw;
  78,101,173,174:llamadas_maquina.iniciar:=iniciar_gaelco_hw;
  79:llamadas_maquina.iniciar:=iniciar_exedexes_hw;
  80,82,83:llamadas_maquina.iniciar:=iniciar_gunsmokehw;
  81:llamadas_maquina.iniciar:=iniciar_hw1942;
  84:llamadas_maquina.iniciar:=iniciar_jailbreak;
  85:llamadas_maquina.iniciar:=iniciar_circusc;
  86:llamadas_maquina.iniciar:=iniciar_ironhorse;
  87,190,191:llamadas_maquina.iniciar:=iniciar_irem_m72;
  89,90:llamadas_maquina.iniciar:=iniciar_brkthru;
  91,392,393,394,395,396,397,398,399:llamadas_maquina.iniciar:=iniciar_dec8;
  92,96:llamadas_maquina.iniciar:=iniciar_ddragon;
  93:llamadas_maquina.iniciar:=iniciar_mrdo;
  94,95:llamadas_maquina.iniciar:=iniciar_epos_hw;
  98,99:llamadas_maquina.iniciar:=iniciar_sf_hw;
  100:llamadas_maquina.iniciar:=iniciar_lk_hw;
  102:llamadas_maquina.iniciar:=iniciar_cabal;
  103,104,105,106,107,108,109,110,111,112,113:llamadas_maquina.iniciar:=iniciar_cps1;
  114,115,116,186,187,198:llamadas_maquina.iniciar:=iniciar_system16a;
  117:llamadas_maquina.iniciar:=iniciar_tp84;
  118:llamadas_maquina.iniciar:=iniciar_tutankham;
  119,183:llamadas_maquina.iniciar:=iniciar_pang;
  120,121,122,307:llamadas_maquina.iniciar:=iniciar_upl;
  123,194:llamadas_maquina.iniciar:=iniciar_skykid;
  124,125,126,289,290,291:llamadas_maquina.iniciar:=iniciar_system86;
  127:llamadas_maquina.iniciar:=iniciar_rocnrope;
  128,330,331:llamadas_maquina.iniciar:=iniciar_kyugo_hw;
  129,130,306:llamadas_maquina.iniciar:=iniciar_tnzs;
  131:llamadas_maquina.iniciar:=iniciar_pacland;
  132:llamadas_maquina.iniciar:=iniciar_mario;
  133:llamadas_maquina.iniciar:=iniciar_solomon;
  134:llamadas_maquina.iniciar:=iniciar_combatsc;
  135:llamadas_maquina.iniciar:=iniciar_hvyunit;
  136,137,149,150:llamadas_maquina.iniciar:=iniciar_snk68;
  138,139,140,337:llamadas_maquina.iniciar:=iniciar_megasys1;
  141:llamadas_maquina.iniciar:=timepilot_iniciar;
  142:llamadas_maquina.iniciar:=iniciar_pengo;
  146,147:llamadas_maquina.iniciar:=iniciar_twincobra;
  148:llamadas_maquina.iniciar:=iniciar_jrpacman;
  156,157,158,316,317:llamadas_maquina.iniciar:=iniciar_dec0;
  160:llamadas_maquina.iniciar:=iniciar_funkyjet;
  159,161:llamadas_maquina.iniciar:=iniciar_supbtime;
  162,163:llamadas_maquina.iniciar:=iniciar_cninja;
  164:llamadas_maquina.iniciar:=iniciar_dietgo;
  165:llamadas_maquina.iniciar:=iniciar_actfancer;
  166:llamadas_maquina.iniciar:=iniciar_arabian;
  170:llamadas_maquina.iniciar:=iniciar_higemaru;
  171,172:llamadas_maquina.iniciar:=iniciar_bagman;
  175,188,346,347:llamadas_maquina.iniciar:=iniciar_zaxxon;
  176:llamadas_maquina.iniciar:=iniciar_kangaroo;
  177:llamadas_maquina.iniciar:=iniciar_bionicc;
  178:llamadas_maquina.iniciar:=iniciar_wwfsstar;
  179,180:llamadas_maquina.iniciar:=iniciar_rainbow;
  181:llamadas_maquina.iniciar:=iniciar_volfied;
  182:llamadas_maquina.iniciar:=iniciar_opwolf;
  184:llamadas_maquina.iniciar:=iniciar_outrun;
  185,189:llamadas_maquina.iniciar:=taitosj_iniciar;
  195:llamadas_maquina.iniciar:=iniciar_vulgus;
  196,232:llamadas_maquina.iniciar:=iniciar_ddragon3;
  197:llamadas_maquina.iniciar:=iniciar_blockout;
  199:llamadas_maquina.iniciar:=iniciar_foodf;
  204,205,260,261:llamadas_maquina.iniciar:=iniciar_nemesis;
  206,207:llamadas_maquina.iniciar:=iniciar_pirates;
  208:llamadas_maquina.iniciar:=iniciar_junofrst;
  209:llamadas_maquina.iniciar:=gyruss_iniciar;
  210:llamadas_maquina.iniciar:=iniciar_boogwing;
  211,271,272,273,274:llamadas_maquina.iniciar:=iniciar_freekick;
  212:llamadas_maquina.iniciar:=iniciar_pinballaction;
  213:llamadas_maquina.iniciar:=iniciar_renegade;
  214,215:llamadas_maquina.iniciar:=iniciar_tmnt;
  216:llamadas_maquina.iniciar:=iniciar_gradius3;
  217:llamadas_maquina.iniciar:=iniciar_spaceinv;
  218,348:llamadas_maquina.iniciar:=iniciar_centipede;
  219,220:llamadas_maquina.iniciar:=iniciar_karnov;
  221:llamadas_maquina.iniciar:=iniciar_aliens;
  222,223,224:llamadas_maquina.iniciar:=iniciar_thunderx;
  225:llamadas_maquina.iniciar:=iniciar_simpsons;
  226:llamadas_maquina.iniciar:=iniciar_trackfield;
  227,400:llamadas_maquina.iniciar:=iniciar_hypersports;
  228:llamadas_maquina.iniciar:=iniciar_megazone;
  229:llamadas_maquina.iniciar:=iniciar_spacefb;
  230:llamadas_maquina.iniciar:=iniciar_ajax;
  235:llamadas_maquina.iniciar:=iniciar_vendetta;
  236,245:llamadas_maquina.iniciar:=iniciar_gauntlet;
  237:llamadas_maquina.iniciar:=iniciar_sauro;
  238:llamadas_maquina.iniciar:=iniciar_cclimber;
  239:llamadas_maquina.iniciar:=iniciar_retofinv;
  240:llamadas_maquina.iniciar:=iniciar_tetris;
  241,242,243,279:llamadas_maquina.iniciar:=iniciar_snk;
  244,263,264:llamadas_maquina.iniciar:=iniciar_atari_sys1;
  246,248,249,321,322,323:llamadas_maquina.iniciar:=iniciar_williams;
  251,252,253,254,255,256,257:llamadas_maquina.iniciar:=iniciar_systeme;
  258,259:llamadas_maquina.iniciar:=iniciar_route16_hw;
  262:llamadas_maquina.iniciar:=iniciar_badlands;
  266,267:llamadas_maquina.iniciar:=iniciar_galivan;
  268,269,270:llamadas_maquina.iniciar:=iniciar_lastduel;
  275,276,277,278:llamadas_maquina.iniciar:=iniciar_armedf;
  280:llamadas_maquina.iniciar:=iniciar_firetrap;
  281,282:llamadas_maquina.iniciar:=iniciar_puzz3x3;
  283,284:llamadas_maquina.iniciar:=iniciar_k31945;
  285,286:llamadas_maquina.iniciar:=iniciar_bloodbros;
  287,288:llamadas_maquina.iniciar:=iniciar_baraduke;
  292,293,294,295,296,297,408,409,410:llamadas_maquina.iniciar:=iniciar_system16b;
  298:llamadas_maquina.iniciar:=iniciar_toaplan1;
  301:llamadas_maquina.iniciar:=karatechamp_iniciar;
  302,303,304:llamadas_maquina.iniciar:=iniciar_seta;
  308,309,310,311,312,313:llamadas_maquina.iniciar:=iniciar_mrdocastle;
  314:llamadas_maquina.iniciar:=iniciar_ccastles;
  315:llamadas_maquina.iniciar:=iniciar_flower;
  318:llamadas_maquina.iniciar:=iniciar_sdodgeball;
  324,411,412,413,414,415,416:llamadas_maquina.iniciar:=iniciar_mcr;
  325:llamadas_maquina.iniciar:=iniciar_arkanoid;
  326:llamadas_maquina.iniciar:=iniciar_sidearms;
  327:llamadas_maquina.iniciar:=iniciar_speedr;
  328:llamadas_maquina.iniciar:=iniciar_chinagate;
  329:llamadas_maquina.iniciar:=iniciar_magmax;
  332:llamadas_maquina.iniciar:=iniciar_ambush;
  333:llamadas_maquina.iniciar:=iniciar_superduck;
  334,335,336:llamadas_maquina.iniciar:=iniciar_hangon;
  338,339:llamadas_maquina.iniciar:=iniciar_shadoww;
  340:llamadas_maquina.iniciar:=iniciar_raiden;
  341,342,343:llamadas_maquina.iniciar:=iniciar_twins;
  344,345:llamadas_maquina.iniciar:=iniciar_missilec;
  349:llamadas_maquina.iniciar:=iniciar_gaplus;
  354,355:llamadas_maquina.iniciar:=iniciar_irem_m63;
  356:llamadas_maquina.iniciar:=iniciar_diverboy;
  357:llamadas_maquina.iniciar:=iniciar_mugsmash;
  358,359,360:llamadas_maquina.iniciar:=iniciar_steelforce;
  361,362:llamadas_maquina.iniciar:=iniciar_bankpanic;
  364,365:llamadas_maquina.iniciar:=iniciar_appoooh;
  367:llamadas_maquina.iniciar:=iniciar_hw88games;
  371,372,373,374,375:llamadas_maquina.iniciar:=iniciar_dooyong;
  377,378,379:llamadas_maquina.iniciar:=iniciar_blueprint;
  380,381:llamadas_maquina.iniciar:=iniciar_unico;
  388,389:llamadas_maquina.iniciar:=iniciar_kikikaikai;
  390,391:llamadas_maquina.iniciar:=iniciar_lasso;
  406:llamadas_maquina.iniciar:=iniciar_finalstarforce;
  407:llamadas_maquina.iniciar:=iniciar_wyvernf0;
  417,418:llamadas_maquina.iniciar:=iniciar_taito_b;
  //consolas
  1000:llamadas_maquina.iniciar:=iniciar_nes;
  1001:llamadas_maquina.iniciar:=iniciar_coleco;
  1002:llamadas_maquina.iniciar:=iniciar_gb;
  1003:llamadas_maquina.iniciar:=iniciar_chip8;
  1004:llamadas_maquina.iniciar:=iniciar_sms;
  1005:llamadas_maquina.iniciar:=iniciar_sg;
  1006:llamadas_maquina.iniciar:=iniciar_gg;
  1007:llamadas_maquina.iniciar:=iniciar_scv;
  1008:Cargar_genesis;
  1009:llamadas_maquina.iniciar:=iniciar_pv1000;
  1010:llamadas_maquina.iniciar:=iniciar_pv2000;
  //gnw
  2000..2002:cargar_gnw_510;
end;
end;

function tipo_cambio_maquina(sender:TObject):word;
var
  tipo,f:word;
begin
//Computers
if sender=principal1.Spectrum48K1 then begin
  tipo:=0;
  principal1.Spectrum48K1.Checked:=true;
end;
if sender=principal1.Spectrum128K1 then begin
  tipo:=1;
  principal1.Spectrum128K1.Checked:=true;
end;
if sender=principal1.Spectrum31 then begin
  tipo:=2;
  principal1.Spectrum31.Checked:=true;
end;
if sender=principal1.Spectrum2A1 then begin
  tipo:=3;
  principal1.Spectrum2A1.Checked:=true;
end;
if sender=principal1.Spectrum21 then begin
  tipo:=4;
  principal1.Spectrum21.Checked:=true;
end;
if sender=principal1.Spectrum16k1 then begin
  tipo:=5;
  principal1.Spectrum16K1.Checked:=true;
end;
if sender=principal1.CPC1 then begin
  tipo:=7;
  principal1.CPC1.Checked:=true;
end;
if sender=principal1.CPC6641 then begin
  tipo:=8;
  principal1.CPC6641.Checked:=true;
end;
if sender=principal1.CPC61281 then begin
  tipo:=9;
  principal1.CPC61281.Checked:=true;
end;
if sender=principal1.c641 then begin
  tipo:=3000;
  principal1.c641.Checked:=true;
end;
if sender=principal1.oricatmos1 then begin
  tipo:=3001;
  principal1.oricatmos1.Checked:=true;
end;
if sender=principal1.oric1_1 then begin
  tipo:=3002;
  principal1.oric1_1.Checked:=true;
end;
//Arcade
if sender=principal1.Pacman1 then begin
  tipo:=10;
  principal1.pacman1.Checked:=true;
end;
if sender=principal1.Phoenix1 then begin
  tipo:=11;
  principal1.phoenix1.Checked:=true;
end;
if sender=principal1.MisteriousStone1 then begin
  tipo:=12;
  principal1.misteriousstone1.Checked:=true;
end;
if sender=principal1.BombJack1 then begin
  tipo:=13;
  principal1.bombjack1.Checked:=true;
end;
if sender=principal1.Frogger1 then begin
  tipo:=14;
  principal1.frogger1.Checked:=true;
end;
if sender=principal1.Dkong1 then begin
  tipo:=15;
  principal1.dkong1.Checked:=true;
end;
if sender=principal1.BlackTiger1 then begin
  tipo:=16;
  principal1.blacktiger1.Checked:=true;
end;
if sender=principal1.Gberet1 then begin
  tipo:=17;
  principal1.gberet1.Checked:=true;
end;
if sender=principal1.Commando1 then begin
  tipo:=18;
  principal1.commando1.Checked:=true;
end;
if sender=principal1.gng1 then begin
  tipo:=19;
  principal1.gng1.Checked:=true;
end;
if sender=principal1.Mikie1 then begin
  tipo:=20;
  principal1.mikie1.Checked:=true;
end;
if sender=principal1.Shaolin1 then begin
  tipo:=21;
  principal1.shaolin1.Checked:=true;
end;
if sender=principal1.Yiear1 then begin
  tipo:=22;
  principal1.Yiear1.Checked:=true;
end;
if sender=principal1.Asteroids1 then begin
  tipo:=23;
  principal1.asteroids1.Checked:=true;
end;
if sender=principal1.Sonson1 then begin
  tipo:=24;
  principal1.sonson1.Checked:=true;
end;
if sender=principal1.starforce1 then begin
  tipo:=25;
  principal1.starforce1.Checked:=true;
end;
if sender=principal1.rygar1 then begin
  tipo:=26;
  principal1.rygar1.Checked:=true;
end;
if sender=principal1.pitfallII1 then begin
  tipo:=27;
  principal1.PitfallII1.Checked:=true;
end;
if sender=principal1.pooyan1 then begin
  tipo:=28;
  principal1.pooyan1.Checked:=true;
end;
if sender=principal1.jungler1 then begin
  tipo:=29;
  principal1.jungler1.Checked:=true;
end;
if sender=principal1.citycon1 then begin
  tipo:=30;
  principal1.citycon1.Checked:=true;
end;
if sender=principal1.burgertime1 then begin
  tipo:=31;
  principal1.burgertime1.Checked:=true;
end;
if sender=principal1.expressraider1 then begin
  tipo:=32;
  principal1.expressraider1.Checked:=true;
end;
if sender=principal1.superbasketball1 then begin
  tipo:=33;
  principal1.superbasketball1.Checked:=true;
end;
if sender=principal1.ladybug1 then begin
  tipo:=34;
  principal1.ladybug1.Checked:=true;
end;
if sender=principal1.teddy1 then begin
  tipo:=35;
  principal1.teddy1.Checked:=true;
end;
if sender=principal1.wboy1 then begin
  tipo:=36;
  principal1.wboy1.Checked:=true;
end;
if sender=principal1.wbml1 then begin
  tipo:=37;
  principal1.wbml1.Checked:=true;
end;
if sender=principal1.tehkanwc1 then begin
  tipo:=38;
  principal1.tehkanwc1.Checked:=true;
end;
if sender=principal1.popeye1 then begin
  tipo:=39;
  principal1.popeye1.Checked:=true;
end;
if sender=principal1.psychic51 then begin
  tipo:=40;
  principal1.psychic51.Checked:=true;
end;
if sender=principal1.terracre1 then begin
  tipo:=41;
  principal1.terracre1.Checked:=true;
end;
if sender=principal1.kungfum1 then begin
  tipo:=42;
  principal1.kungfum1.Checked:=true;
end;
if sender=principal1.shootout1 then begin
  tipo:=43;
  principal1.shootout1.Checked:=true;
end;
if sender=principal1.vigilante1 then begin
  tipo:=44;
  principal1.vigilante1.Checked:=true;
end;
if sender=principal1.jackal1 then begin
  tipo:=45;
  principal1.jackal1.Checked:=true;
end;
if sender=principal1.bubblebobble1 then begin
  tipo:=46;
  principal1.bubblebobble1.Checked:=true;
end;
if sender=principal1.galaxian1 then begin
  tipo:=47;
  principal1.galaxian1.Checked:=true;
end;
if sender=principal1.jumpb1 then begin
  tipo:=48;
  principal1.jumpb1.Checked:=true;
end;
if sender=principal1.mooncresta1 then begin
  tipo:=49;
  principal1.mooncresta1.Checked:=true;
end;
if sender=principal1.rallyx1 then begin
  tipo:=50;
  principal1.rallyx1.Checked:=true;
end;
if sender=principal1.prehisle1 then begin
  tipo:=51;
  principal1.prehisle1.Checked:=true;
end;
if sender=principal1.TigerRoad1 then begin
  tipo:=52;
  principal1.tigerroad1.Checked:=true;
end;
if sender=principal1.F1Dream1 then begin
  tipo:=53;
  principal1.f1dream1.Checked:=true;
end;
if sender=principal1.Snowbros1 then begin
  tipo:=54;
  principal1.snowbros1.Checked:=true;
end;
if sender=principal1.Toki1 then begin
  tipo:=55;
  principal1.toki1.Checked:=true;
end;
if sender=principal1.Contra1 then begin
  tipo:=56;
  principal1.contra1.Checked:=true;
end;
if sender=principal1.Mappy1 then begin
  tipo:=57;
  principal1.mappy1.Checked:=true;
end;
if sender=principal1.Rastan1 then begin
  tipo:=58;
  principal1.rastan1.Checked:=true;
end;
if sender=principal1.Legendw1 then begin
  tipo:=59;
  principal1.legendw1.Checked:=true;
end;
if sender=principal1.SectionZ1 then begin
  tipo:=60;
  principal1.sectionz1.Checked:=true;
end;
if sender=principal1.Trojan1 then begin
  tipo:=61;
  principal1.trojan1.Checked:=true;
end;
if sender=principal1.SF1 then begin
  tipo:=62;
  principal1.sf1.Checked:=true;
end;
if sender=principal1.digdug21 then begin
  tipo:=63;
  principal1.digdug21.Checked:=true;
end;
if sender=principal1.spacman1 then begin
  tipo:=64;
  principal1.SPacman1.Checked:=true;
end;
if sender=principal1.galaga1 then begin
  tipo:=65;
  principal1.galaga1.Checked:=true;
end;
if sender=principal1.xain1 then begin
  tipo:=66;
  principal1.xain1.Checked:=true;
end;
if sender=principal1.hardhead1 then begin
  tipo:=67;
  principal1.hardhead1.Checked:=true;
end;
if sender=principal1.hardhead21 then begin
  tipo:=68;
  principal1.hardhead21.Checked:=true;
end;
if sender=principal1.sbombers1 then begin
  tipo:=69;
  principal1.sbombers1.Checked:=true;
end;
if sender=principal1.NewRallyX1 then begin
  tipo:=70;
  principal1.newrallyx1.Checked:=true;
end;
if sender=principal1.bjtwin1 then begin
  tipo:=71;
  principal1.bjtwin1.Checked:=true;
end;
if sender=principal1.spelunker1 then begin
  tipo:=72;
  principal1.Spelunker1.Checked:=true;
end;
if sender=principal1.spelunker21 then begin
  tipo:=73;
  principal1.Spelunker21.Checked:=true;
end;
if sender=principal1.ldrun1 then begin
  tipo:=74;
  principal1.ldrun1.Checked:=true;
end;
if sender=principal1.ldrun21 then begin
  tipo:=75;
  principal1.ldrun21.Checked:=true;
end;
if sender=principal1.knjoe1 then begin
  tipo:=76;
  principal1.knjoe1.Checked:=true;
end;
if sender=principal1.wardner1 then begin
  tipo:=77;
  principal1.wardner1.Checked:=true;
end;
if sender=principal1.bigkarnak1 then begin
  tipo:=78;
  principal1.bigkarnak1.Checked:=true;
end;
if sender=principal1.exedexes1 then begin
  tipo:=79;
  principal1.exedexes1.Checked:=true;
end;
if sender=principal1.gunsmoke1 then begin
  tipo:=80;
  principal1.gunsmoke1.Checked:=true;
end;
if sender=principal1.n19421 then begin
  tipo:=81;
  principal1.n19421.Checked:=true;
end;
if sender=principal1.n19431 then begin
  tipo:=82;
  principal1.n19431.Checked:=true;
end;
if sender=principal1.n1943kai1 then begin
  tipo:=83;
  principal1.n1943kai1.Checked:=true;
end;
if sender=principal1.jailbreak1 then begin
  tipo:=84;
  principal1.jailbreak1.Checked:=true;
end;
if sender=principal1.circusc1 then begin
  tipo:=85;
  principal1.circusc1.Checked:=true;
end;
if sender=principal1.ironhorse1 then begin
  tipo:=86;
  principal1.ironhorse1.Checked:=true;
end;
if sender=principal1.rtype1 then begin
  tipo:=87;
  principal1.rtype1.Checked:=true;
end;
if sender=principal1.mspacman1 then begin
  tipo:=88;
  principal1.mspacman1.Checked:=true;
end;
if sender=principal1.brkthru1 then begin
  tipo:=89;
  principal1.brkthru1.Checked:=true;
end;
if sender=principal1.darwin1 then begin
  tipo:=90;
  principal1.darwin1.Checked:=true;
end;
if sender=principal1.srd1 then begin
  tipo:=91;
  principal1.srd1.Checked:=true;
end;
if sender=principal1.ddragon1 then begin
  tipo:=92;
  principal1.ddragon1.Checked:=true;
end;
if sender=principal1.mrdo1 then begin
  tipo:=93;
  principal1.mrdo1.Checked:=true;
end;
if sender=principal1.theglob1 then begin
  tipo:=94;
  principal1.theglob1.Checked:=true;
end;
if sender=principal1.superglob1 then begin
  tipo:=95;
  principal1.superglob1.Checked:=true;
end;
if sender=principal1.ddragon21 then begin
  tipo:=96;
  principal1.ddragon21.Checked:=true;
end;
if sender=principal1.silkworm1 then begin
  tipo:=97;
  principal1.silkworm1.Checked:=true;
end;
if sender=principal1.tigerh1 then begin
  tipo:=98;
  principal1.tigerh1.Checked:=true;
end;
if sender=principal1.SlapFight1 then begin
  tipo:=99;
  principal1.slapfight1.Checked:=true;
end;
if sender=principal1.LegendofKage1 then begin
  tipo:=100;
  principal1.legendofkage1.Checked:=true;
end;
if sender=principal1.thoop1 then begin
  tipo:=101;
  principal1.thoop1.Checked:=true;
end;
if sender=principal1.cabal1 then begin
  tipo:=102;
  principal1.cabal1.Checked:=true;
end;
if sender=principal1.ghouls1 then begin
  tipo:=103;
  principal1.ghouls1.Checked:=true;
end;
if sender=principal1.ffight1 then begin
  tipo:=104;
  principal1.ffight1.Checked:=true;
end;
if sender=principal1.kod1 then begin
  tipo:=105;
  principal1.kod1.Checked:=true;
end;
if sender=principal1.sf21 then begin
  tipo:=106;
  principal1.sf21.Checked:=true;
end;
if sender=principal1.strider1 then begin
  tipo:=107;
  principal1.strider1.Checked:=true;
end;
if sender=principal1.wonder31 then begin
  tipo:=108;
  principal1.wonder31.Checked:=true;
end;
if sender=principal1.ccommando1 then begin
  tipo:=109;
  principal1.ccommando1.Checked:=true;
end;
if sender=principal1.knights1 then begin
  tipo:=110;
  principal1.knights1.Checked:=true;
end;
if sender=principal1.sf2ce1 then begin
  tipo:=111;
  principal1.sf2ce1.Checked:=true;
end;
if sender=principal1.dino1 then begin
  tipo:=112;
  principal1.dino1.Checked:=true;
end;
if sender=principal1.punisher1 then begin
  tipo:=113;
  principal1.punisher1.Checked:=true;
end;
if sender=principal1.shinobi1 then begin
  tipo:=114;
  principal1.shinobi1.Checked:=true;
end;
if sender=principal1.alexkid1 then begin
  tipo:=115;
  principal1.alexkid1.Checked:=true;
end;
if sender=principal1.fantasyzone1 then begin
  tipo:=116;
  principal1.fantasyzone1.Checked:=true;
end;
if sender=principal1.tp841 then begin
  tipo:=117;
  principal1.tp841.Checked:=true;
end;
if sender=principal1.Tutankhm1 then begin
  tipo:=118;
  principal1.tutankhm1.Checked:=true;
end;
if sender=principal1.Pang1 then begin
  tipo:=119;
  principal1.pang1.Checked:=true;
end;
if sender=principal1.ninjakid21 then begin
  tipo:=120;
  principal1.ninjakid21.Checked:=true;
end;
if sender=principal1.arkarea1 then begin
  tipo:=121;
  principal1.arkarea1.Checked:=true;
end;
if sender=principal1.mnight1 then begin
  tipo:=122;
  principal1.mnight1.Checked:=true;
end;
if sender=principal1.skykid1 then begin
  tipo:=123;
  principal1.skykid1.Checked:=true;
end;
if sender=principal1.rthunder1 then begin
  tipo:=124;
  principal1.rthunder1.Checked:=true;
end;
if sender=principal1.hopmappy1 then begin
  tipo:=125;
  principal1.hopmappy1.Checked:=true;
end;
if sender=principal1.skykiddx1 then begin
  tipo:=126;
  principal1.skykiddx1.Checked:=true;
end;
if sender=principal1.rocnrope1 then begin
  tipo:=127;
  principal1.rocnrope1.Checked:=true;
end;
if sender=principal1.repulse1 then begin
  tipo:=128;
  principal1.repulse1.Checked:=true;
end;
if sender=principal1.tnzs1 then begin
  tipo:=129;
  principal1.tnzs1.Checked:=true;
end;
if sender=principal1.insectorx1 then begin
  tipo:=130;
  principal1.insectorx1.Checked:=true;
end;
if sender=principal1.pacland1 then begin
  tipo:=131;
  principal1.pacland1.Checked:=true;
end;
if sender=principal1.mariob1 then begin
  tipo:=132;
  principal1.mariob1.Checked:=true;
end;
if sender=principal1.solomon1 then begin
  tipo:=133;
  principal1.solomon1.Checked:=true;
end;
if sender=principal1.combatsc1 then begin
  tipo:=134;
  principal1.combatsc1.Checked:=true;
end;
if sender=principal1.hvyunit1 then begin
  tipo:=135;
  principal1.hvyunit1.Checked:=true;
end;
if sender=principal1.pow1 then begin
  tipo:=136;
  principal1.pow1.Checked:=true;
end;
if sender=principal1.streetsm1 then begin
  tipo:=137;
  principal1.streetsm1.Checked:=true;
end;
if sender=principal1.p471 then begin
  tipo:=138;
  principal1.p471.Checked:=true;
end;
if sender=principal1.rodland1 then begin
  tipo:=139;
  principal1.rodland1.Checked:=true;
end;
if sender=principal1.saintdragon1 then begin
  tipo:=140;
  principal1.saintdragon1.Checked:=true;
end;
if sender=principal1.timepilot1 then begin
  tipo:=141;
  principal1.timepilot1.Checked:=true;
end;
if sender=principal1.pengo1 then begin
  tipo:=142;
  principal1.pengo1.Checked:=true;
end;
if sender=principal1.scramble1 then begin
  tipo:=143;
  principal1.scramble1.Checked:=true;
end;
if sender=principal1.scobra1 then begin
  tipo:=144;
  principal1.scobra1.Checked:=true;
end;
if sender=principal1.amidar1 then begin
  tipo:=145;
  principal1.amidar1.Checked:=true;
end;
if sender=principal1.twincobr1 then begin
  tipo:=146;
  principal1.twincobr1.Checked:=true;
end;
if sender=principal1.FlyingShark1 then begin
  tipo:=147;
  principal1.flyingshark1.Checked:=true;
end;
if sender=principal1.JrPacman1 then begin
  tipo:=148;
  principal1.jrpacman1.Checked:=true;
end;
if sender=principal1.ikari31 then begin
  tipo:=149;
  principal1.ikari31.Checked:=true;
end;
if sender=principal1.searchar1 then begin
  tipo:=150;
  principal1.searchar1.Checked:=true;
end;
if sender=principal1.Choplifter1 then begin
  tipo:=151;
  principal1.Choplifter1.Checked:=true;
end;
if sender=principal1.mrviking1 then begin
  tipo:=152;
  principal1.mrviking1.Checked:=true;
end;
if sender=principal1.SegaNinja1 then begin
  tipo:=153;
  principal1.seganinja1.Checked:=true;
end;
if sender=principal1.UpnDown1 then begin
  tipo:=154;
  principal1.upndown1.Checked:=true;
end;
if sender=principal1.flicky1 then begin
  tipo:=155;
  principal1.flicky1.Checked:=true;
end;
if sender=principal1.robocop1 then begin
  tipo:=156;
  principal1.robocop1.Checked:=true;
end;
if sender=principal1.baddudes1 then begin
  tipo:=157;
  principal1.baddudes1.Checked:=true;
end;
if sender=principal1.hippo1 then begin
  tipo:=158;
  principal1.hippo1.Checked:=true;
end;
if sender=principal1.TumbleP1 then begin
  tipo:=159;
  principal1.tumblep1.Checked:=true;
end;
if sender=principal1.funkyjet1 then begin
  tipo:=160;
  principal1.funkyjet1.Checked:=true;
end;
if sender=principal1.SuperBurgerTime1 then begin
  tipo:=161;
  principal1.superburgertime1.Checked:=true;
end;
if sender=principal1.cninja1 then begin
  tipo:=162;
  principal1.cninja1.Checked:=true;
end;
if sender=principal1.robocop21 then begin
  tipo:=163;
  principal1.robocop21.Checked:=true;
end;
if sender=principal1.dietgo1 then begin
  tipo:=164;
  principal1.dietgo1.Checked:=true;
end;
if sender=principal1.actfancer1 then begin
  tipo:=165;
  principal1.ActFancer1.Checked:=true;
end;
if sender=principal1.arabian1 then begin
  tipo:=166;
  principal1.arabian1.Checked:=true;
end;
if sender=principal1.digdug1 then begin
  tipo:=167;
  principal1.digdug1.Checked:=true;
end;
if sender=principal1.dkongjr1 then begin
  tipo:=168;
  principal1.dkongjr1.Checked:=true;
end;
if sender=principal1.dkong31 then begin
  tipo:=169;
  principal1.dkong31.Checked:=true;
end;
if sender=principal1.higemaru1 then begin
  tipo:=170;
  principal1.higemaru1.Checked:=true;
end;
if sender=principal1.bagman1 then begin
  tipo:=171;
  principal1.bagman1.Checked:=true;
end;
if sender=principal1.sbagman1 then begin
  tipo:=172;
  principal1.sbagman1.Checked:=true;
end;
if sender=principal1.squash1 then begin
  tipo:=173;
  principal1.squash1.Checked:=true;
end;
if sender=principal1.biomtoy1 then begin
  tipo:=174;
  principal1.biomtoy1.Checked:=true;
end;
if sender=principal1.congo1 then begin
  tipo:=175;
  principal1.congo1.Checked:=true;
end;
if sender=principal1.kangaroo1 then begin
  tipo:=176;
  principal1.kangaroo1.Checked:=true;
end;
if sender=principal1.bionicc1 then begin
  tipo:=177;
  principal1.bionicc1.Checked:=true;
end;
if sender=principal1.wwfsuperstar1 then begin
  tipo:=178;
  principal1.wwfsuperstar1.Checked:=true;
end;
if sender=principal1.rbisland1 then begin
  tipo:=179;
  principal1.rbisland1.Checked:=true;
end;
if sender=principal1.rbislande1 then begin
  tipo:=180;
  principal1.rbislande1.Checked:=true;
end;
if sender=principal1.volfied1 then begin
  tipo:=181;
  principal1.volfied1.Checked:=true;
end;
if sender=principal1.opwolf1 then begin
  tipo:=182;
  principal1.opwolf1.Checked:=true;
end;
if sender=principal1.sPang1 then begin
  tipo:=183;
  principal1.spang1.Checked:=true;
end;
if sender=principal1.outrun1 then begin
  tipo:=184;
  principal1.outrun1.Checked:=true;
end;
if sender=principal1.elevator1 then begin
  tipo:=185;
  principal1.elevator1.Checked:=true;
end;
if sender=principal1.aliensyn1 then begin
  tipo:=186;
  principal1.aliensyn1.Checked:=true;
end;
if sender=principal1.wb31 then begin
  tipo:=187;
  principal1.wb31.Checked:=true;
end;
if sender=principal1.zaxxon1 then begin
  tipo:=188;
  principal1.zaxxon1.Checked:=true;
end;
if sender=principal1.jungleking1 then begin
  tipo:=189;
  principal1.jungleking1.Checked:=true;
end;
if sender=principal1.hharry1 then begin
  tipo:=190;
  principal1.hharry1.Checked:=true;
end;
if sender=principal1.rtype21 then begin
  tipo:=191;
  principal1.rtype21.Checked:=true;
end;
if sender=principal1.todruaga1 then begin
  tipo:=192;
  principal1.todruaga1.Checked:=true;
end;
if sender=principal1.motos1 then begin
  tipo:=193;
  principal1.motos1.Checked:=true;
end;
if sender=principal1.drgnbstr1 then begin
  tipo:=194;
  principal1.drgnbstr1.Checked:=true;
end;
if sender=principal1.vulgus1 then begin
  tipo:=195;
  principal1.vulgus1.Checked:=true;
end;
if sender=principal1.ddragon31 then begin
  tipo:=196;
  principal1.ddragon31.Checked:=true;
end;
if sender=principal1.blockout1 then begin
  tipo:=197;
  principal1.blockout1.Checked:=true;
end;
if sender=principal1.tetris1 then begin
  tipo:=198;
  principal1.tetris1.Checked:=true;
end;
if sender=principal1.foodf1 then begin
  tipo:=199;
  principal1.foodf1.Checked:=true;
end;
if sender=principal1.snapjack1 then begin
  tipo:=200;
  principal1.snapjack1.Checked:=true;
end;
if sender=principal1.cavenger1 then begin
  tipo:=201;
  principal1.cavenger1.Checked:=true;
end;
if sender=principal1.pleiads1 then begin
  tipo:=202;
  principal1.pleiads1.Checked:=true;
end;
if sender=principal1.mrgoemon1 then begin
  tipo:=203;
  principal1.mrgoemon1.Checked:=true;
end;
if sender=principal1.nemesis1 then begin
  tipo:=204;
  principal1.nemesis1.Checked:=true;
end;
if sender=principal1.twinbee1 then begin
  tipo:=205;
  principal1.twinbee1.Checked:=true;
end;
if sender=principal1.pirates1 then begin
  tipo:=206;
  principal1.pirates1.Checked:=true;
end;
if sender=principal1.genixfamily1 then begin
  tipo:=207;
  principal1.genixfamily1.Checked:=true;
end;
if sender=principal1.junofirst1 then begin
  tipo:=208;
  principal1.junofirst1.Checked:=true;
end;
if sender=principal1.gyruss1 then begin
  tipo:=209;
  principal1.gyruss1.Checked:=true;
end;
if sender=principal1.boogwins1 then begin
  tipo:=210;
  principal1.boogwins1.Checked:=true;
end;
if sender=principal1.freekick1 then begin
  tipo:=211;
  principal1.freekick1.Checked:=true;
end;
if sender=principal1.pbaction1 then begin
  tipo:=212;
  principal1.pbaction1.Checked:=true;
end;
if sender=principal1.renegade1 then begin
  tipo:=213;
  principal1.renegade1.Checked:=true;
end;
if sender=principal1.tmnt1 then begin
  tipo:=214;
  principal1.tmnt1.Checked:=true;
end;
if sender=principal1.ssriders1 then begin
  tipo:=215;
  principal1.ssriders1.Checked:=true;
end;
if sender=principal1.gradius31 then begin
  tipo:=216;
  principal1.gradius31.Checked:=true;
end;
if sender=principal1.SpaceInvaders1 then begin
  tipo:=217;
  principal1.SpaceInvaders1.Checked:=true;
end;
if sender=principal1.centipede1 then begin
  tipo:=218;
  principal1.centipede1.Checked:=true;
end;
if sender=principal1.karnov1 then begin
  tipo:=219;
  principal1.karnov1.Checked:=true;
end;
if sender=principal1.chelnov1 then begin
  tipo:=220;
  principal1.chelnov1.Checked:=true;
end;
if sender=principal1.aliens1 then begin
  tipo:=221;
  principal1.aliens1.Checked:=true;
end;
if sender=principal1.scontra1 then begin
  tipo:=222;
  principal1.scontra1.Checked:=true;
end;
if sender=principal1.gbusters1 then begin
  tipo:=223;
  principal1.gbusters1.Checked:=true;
end;
if sender=principal1.thunderx1 then begin
  tipo:=224;
  principal1.thunderx1.Checked:=true;
end;
if sender=principal1.simpsons1 then begin
  tipo:=225;
  principal1.simpsons1.Checked:=true;
end;
if sender=principal1.trackfield1 then begin
  tipo:=226;
  principal1.trackfield1.Checked:=true;
end;
if sender=principal1.hypersports1 then begin
  tipo:=227;
  principal1.hypersports1.Checked:=true;
end;
if sender=principal1.megazone1 then begin
  tipo:=228;
  principal1.megazone1.Checked:=true;
end;
if sender=principal1.spacefb1 then begin
  tipo:=229;
  principal1.spacefb1.Checked:=true;
end;
if sender=principal1.ajax1 then begin
  tipo:=230;
  principal1.ajax1.Checked:=true;
end;
if sender=principal1.xevious1 then begin
  tipo:=231;
  principal1.xevious1.Checked:=true;
end;
if sender=principal1.ctribe1 then begin
  tipo:=232;
  principal1.ctribe1.Checked:=true;
end;
if sender=principal1.llander1 then begin
  tipo:=233;
  principal1.llander1.Checked:=true;
end;
if sender=principal1.crushroller1 then begin
  tipo:=234;
  principal1.crushroller1.Checked:=true;
end;
if sender=principal1.vendetta1 then begin
  tipo:=235;
  principal1.vendetta1.Checked:=true;
end;
if sender=principal1.gauntlet1 then begin
  tipo:=236;
  principal1.gauntlet1.Checked:=true;
end;
if sender=principal1.sauro1 then begin
  tipo:=237;
  principal1.sauro1.Checked:=true;
end;
if sender=principal1.cclimber1 then begin
  tipo:=238;
  principal1.cclimber1.Checked:=true;
end;
if sender=principal1.retofinv1 then begin
  tipo:=239;
  principal1.retofinv1.Checked:=true;
end;
if sender=principal1.tetrisatari1 then begin
  tipo:=240;
  principal1.tetrisatari1.Checked:=true;
end;
if sender=principal1.ikari1 then begin
  tipo:=241;
  principal1.ikari1.Checked:=true;
end;
if sender=principal1.athena1 then begin
  tipo:=242;
  principal1.athena1.Checked:=true;
end;
if sender=principal1.tnk31 then begin
  tipo:=243;
  principal1.tnk31.Checked:=true;
end;
if sender=principal1.peterpak1 then begin
  tipo:=244;
  principal1.peterpak1.Checked:=true;
end;
if sender=principal1.gaunt21 then begin
  tipo:=245;
  principal1.gaunt21.Checked:=true;
end;
if sender=principal1.defender1 then begin
  tipo:=246;
  principal1.defender1.Checked:=true;
end;
if sender=principal1.fireball1 then begin
  tipo:=247;
  principal1.fireball1.Checked:=true;
end;
if sender=principal1.mayday1 then begin
  tipo:=248;
  principal1.mayday1.Checked:=true;
end;
if sender=principal1.colony71 then begin
  tipo:=249;
  principal1.colony71.Checked:=true;
end;
if sender=principal1.bosconian1 then begin
  tipo:=250;
  principal1.bosconian1.Checked:=true;
end;
if sender=principal1.hangonjr1 then begin
  tipo:=251;
  principal1.hangonjr1.Checked:=true;
end;
if sender=principal1.slapshooter1 then begin
  tipo:=252;
  principal1.slapshooter1.Checked:=true;
end;
if sender=principal1.fantasyzone21 then begin
  tipo:=253;
  principal1.fantasyzone21.Checked:=true;
end;
if sender=principal1.opaopa1 then begin
  tipo:=254;
  principal1.opaopa1.Checked:=true;
end;
if sender=principal1.tetrisse1 then begin
  tipo:=255;
  principal1.tetrisse1.Checked:=true;
end;
if sender=principal1.transformer1 then begin
  tipo:=256;
  principal1.transformer1.Checked:=true;
end;
if sender=principal1.riddleofp1 then begin
  tipo:=257;
  principal1.riddleofp1.Checked:=true;
end;
if sender=principal1.route161 then begin
  tipo:=258;
  principal1.route161.Checked:=true;
end;
if sender=principal1.speakandrescue1 then begin
  tipo:=259;
  principal1.speakandrescue1.Checked:=true;
end;
if sender=principal1.gwarrior1 then begin
  tipo:=260;
  principal1.gwarrior1.Checked:=true;
end;
if sender=principal1.salamander1 then begin
  tipo:=261;
  principal1.salamander1.Checked:=true;
end;
if sender=principal1.badlands1 then begin
  tipo:=262;
  principal1.badlands1.Checked:=true;
end;
if sender=principal1.indydoom1 then begin
  tipo:=263;
  principal1.indydoom1.Checked:=true;
end;
if sender=principal1.marblemadness1 then begin
  tipo:=264;
  principal1.marblemadness1.Checked:=true;
end;
if sender=principal1.amazon1 then begin
  tipo:=265;
  principal1.amazon1.Checked:=true;
end;
if sender=principal1.galivan1 then begin
  tipo:=266;
  principal1.galivan1.Checked:=true;
end;
if sender=principal1.dangar1 then begin
  tipo:=267;
  principal1.dangar1.Checked:=true;
end;
if sender=principal1.lastduel1 then begin
  tipo:=268;
  principal1.lastduel1.Checked:=true;
end;
if sender=principal1.madgear1 then begin
  tipo:=269;
  principal1.madgear1.Checked:=true;
end;
if sender=principal1.leds20111 then begin
  tipo:=270;
  principal1.leds20111.Checked:=true;
end;
if sender=principal1.gigas1 then begin
  tipo:=271;
  principal1.gigas1.Checked:=true;
end;
if sender=principal1.gigasm21 then begin
  tipo:=272;
  principal1.gigasm21.Checked:=true;
end;
if sender=principal1.omega1 then begin
  tipo:=273;
  principal1.omega1.Checked:=true;
end;
if sender=principal1.pbillrd1 then begin
  tipo:=274;
  principal1.pbillrd1.Checked:=true;
end;
if sender=principal1.armedf1 then begin
  tipo:=275;
  principal1.armedf1.Checked:=true;
end;
if sender=principal1.terraforce1 then begin
  tipo:=276;
  principal1.terraforce1.Checked:=true;
end;
if sender=principal1.crazyclimber21 then begin
  tipo:=277;
  principal1.crazyclimber21.Checked:=true;
end;
if sender=principal1.legion1 then begin
  tipo:=278;
  principal1.legion1.Checked:=true;
end;
if sender=principal1.aso1 then begin
  tipo:=279;
  principal1.aso1.Checked:=true;
end;
if sender=principal1.firetrap1 then begin
  tipo:=280;
  principal1.firetrap1.Checked:=true;
end;
if sender=principal1.puzzle3x31 then begin
  tipo:=281;
  principal1.puzzle3x31.Checked:=true;
end;
if sender=principal1.casanova1 then begin
  tipo:=282;
  principal1.casanova1.Checked:=true;
end;
if sender=principal1.N1945K32 then begin
  tipo:=283;
  principal1.N1945K32.Checked:=true;
end;
if sender=principal1.flagrall1 then begin
  tipo:=284;
  principal1.flagrall1.Checked:=true;
end;
if sender=principal1.bloodbros1 then begin
  tipo:=285;
  principal1.bloodbros1.Checked:=true;
end;
if sender=principal1.skysmasher1 then begin
  tipo:=286;
  principal1.skysmasher1.Checked:=true;
end;
if sender=principal1.baraduke1 then begin
  tipo:=287;
  principal1.baraduke1.Checked:=true;
end;
if sender=principal1.metrocross1 then begin
  tipo:=288;
  principal1.metrocross1.Checked:=true;
end;
if sender=principal1.returnishtar1 then begin
  tipo:=289;
  principal1.returnishtar1.Checked:=true;
end;
if sender=principal1.genpeitd1 then begin
  tipo:=290;
  principal1.genpeitd1.Checked:=true;
end;
if sender=principal1.wndrmomo1 then begin
  tipo:=291;
  principal1.wndrmomo1.Checked:=true;
end;
if sender=principal1.AlteredBeast1 then begin
  tipo:=292;
  principal1.AlteredBeast1.Checked:=true;
end;
if sender=principal1.Goldenaxe1 then begin
  tipo:=293;
  principal1.Goldenaxe1.Checked:=true;
end;
if sender=principal1.dynamitedux1 then begin
  tipo:=294;
  principal1.dynamitedux1.Checked:=true;
end;
if sender=principal1.eswat1 then begin
  tipo:=295;
  principal1.eswat1.Checked:=true;
end;
if sender=principal1.passingshot1 then begin
  tipo:=296;
  principal1.passingshot1.Checked:=true;
end;
if sender=principal1.aurail1 then begin
  tipo:=297;
  principal1.aurail1.Checked:=true;
end;
if sender=principal1.hellfire1 then begin
  tipo:=298;
  principal1.hellfire1.Checked:=true;
end;
if sender=principal1.lnc1 then begin
  tipo:=299;
  principal1.lnc1.Checked:=true;
end;
if sender=principal1.mmonkey1 then begin
  tipo:=300;
  principal1.mmonkey1.Checked:=true;
end;
if sender=principal1.karatechamp1 then begin
  tipo:=301;
  principal1.karatechamp1.Checked:=true;
end;
if sender=principal1.thundercade1 then begin
  tipo:=302;
  principal1.thundercade1.Checked:=true;
end;
if sender=principal1.twineagle1 then begin
  tipo:=303;
  principal1.twineagle1.Checked:=true;
end;
if sender=principal1.thunderl1 then begin
  tipo:=304;
  principal1.thunderl1.Checked:=true;
end;
if sender=principal1.mspactwin1 then begin
  tipo:=305;
  principal1.mspactwin1.Checked:=true;
end;
if sender=principal1.exterm1 then begin
  tipo:=306;
  principal1.exterm1.Checked:=true;
end;
if sender=principal1.robokid1 then begin
  tipo:=307;
  principal1.robokid1.Checked:=true;
end;
if sender=principal1.mrdocastle1 then begin
  tipo:=308;
  principal1.mrdocastle1.Checked:=true;
end;
if sender=principal1.dorunrun1 then begin
  tipo:=309;
  principal1.dorunrun1.Checked:=true;
end;
if sender=principal1.dowild1 then begin
  tipo:=310;
  principal1.dowild1.Checked:=true;
end;
if sender=principal1.jjack1 then begin
  tipo:=311;
  principal1.jjack1.Checked:=true;
end;
if sender=principal1.kickrider1 then begin
  tipo:=312;
  principal1.kickrider1.Checked:=true;
end;
if sender=principal1.idsoccer1 then begin
  tipo:=313;
  principal1.idsoccer1.Checked:=true;
end;
if sender=principal1.ccastles1 then begin
  tipo:=314;
  principal1.ccastles1.Checked:=true;
end;
if sender=principal1.flower1 then begin
  tipo:=315;
  principal1.flower1.Checked:=true;
end;
if sender=principal1.slyspy1 then begin
  tipo:=316;
  principal1.slyspy1.Checked:=true;
end;
if sender=principal1.bdash1 then begin
  tipo:=317;
  principal1.bdash1.Checked:=true;
end;
if sender=principal1.spdodgeb1 then begin
  tipo:=318;
  principal1.spdodgeb1.Checked:=true;
end;
if sender=principal1.senjyo1 then begin
  tipo:=319;
  principal1.senjyo1.Checked:=true;
end;
if sender=principal1.baluba1 then begin
  tipo:=320;
  principal1.baluba1.Checked:=true;
end;
if sender=principal1.joust1 then begin
  tipo:=321;
  principal1.joust1.Checked:=true;
end;
if sender=principal1.robotron1 then begin
  tipo:=322;
  principal1.robotron1.Checked:=true;
end;
if sender=principal1.stargate1 then begin
  tipo:=323;
  principal1.stargate1.Checked:=true;
end;
if sender=principal1.tapper1 then begin
  tipo:=324;
  principal1.tapper1.Checked:=true;
end;
if sender=principal1.arkanoid1 then begin
  tipo:=325;
  principal1.arkanoid1.Checked:=true;
end;
if sender=principal1.sidearms1 then begin
  tipo:=326;
  principal1.sidearms1.Checked:=true;
end;
if sender=principal1.speedrumbler1 then begin
  tipo:=327;
  principal1.speedrumbler1.Checked:=true;
end;
if sender=principal1.chinagate1 then begin
  tipo:=328;
  principal1.chinagate1.Checked:=true;
end;
if sender=principal1.magmax1 then begin
  tipo:=329;
  principal1.magmax1.Checked:=true;
end;
if sender=principal1.SRDMission1 then begin
  tipo:=330;
  principal1.SRDMission1.Checked:=true;
end;
if sender=principal1.airwolf1 then begin
  tipo:=331;
  principal1.airwolf1.Checked:=true;
end;
if sender=principal1.ambush1 then begin
  tipo:=332;
  principal1.ambush1.Checked:=true;
end;
if sender=principal1.superduck1 then begin
  tipo:=333;
  principal1.superduck1.Checked:=true;
end;
if sender=principal1.hangon1 then begin
  tipo:=334;
  principal1.hangon1.Checked:=true;
end;
if sender=principal1.enduroracer1 then begin
  tipo:=335;
  principal1.enduroracer1.Checked:=true;
end;
if sender=principal1.spaceharrier1 then begin
  tipo:=336;
  principal1.spaceharrier1.Checked:=true;
end;
if sender=principal1.N64thstreet1 then begin
  tipo:=337;
  principal1.N64thstreet1.Checked:=true;
end;
if sender=principal1.shadowwarriors1 then begin
  tipo:=338;
  principal1.shadowwarriors1.Checked:=true;
end;
if sender=principal1.wildfang1 then begin
  tipo:=339;
  principal1.wildfang1.Checked:=true;
end;
if sender=principal1.raiden1 then begin
  tipo:=340;
  principal1.raiden1.Checked:=true;
end;
if sender=principal1.twins1 then begin
  tipo:=341;
  principal1.twins1.Checked:=true;
end;
if sender=principal1.twinsed1 then begin
  tipo:=342;
  principal1.twinsed1.Checked:=true;
end;
if sender=principal1.hotblocks1 then begin
  tipo:=343;
  principal1.hotblocks1.Checked:=true;
end;
if sender=principal1.missilecommand1 then begin
  tipo:=344;
  principal1.missilecommand1.Checked:=true;
end;
if sender=principal1.supermissileattack1 then begin
  tipo:=345;
  principal1.supermissileattack1.Checked:=true;
end;
if sender=principal1.superzaxxon1 then begin
  tipo:=346;
  principal1.superzaxxon1.Checked:=true;
end;
if sender=principal1.futurespy1 then begin
  tipo:=347;
  principal1.futurespy1.Checked:=true;
end;
if sender=principal1.millipede1 then begin
  tipo:=348;
  principal1.millipede1.Checked:=true;
end;
if sender=principal1.gaplus1 then begin
  tipo:=349;
  principal1.gaplus1.Checked:=true;
end;
if sender=principal1.superxevious1 then begin
  tipo:=350;
  principal1.superxevious1.Checked:=true;
end;
if sender=principal1.grobda1 then begin
  tipo:=351;
  principal1.grobda1.Checked:=true;
end;
if sender=principal1.pacnpal1 then begin
  tipo:=352;
  principal1.pacnpal1.Checked:=true;
end;
if sender=principal1.birdiy1 then begin
  tipo:=353;
  principal1.birdiy1.Checked:=true;
end;
if sender=principal1.wilytower1 then begin
  tipo:=354;
  principal1.wilytower1.Checked:=true;
end;
if sender=principal1.FightingBasketball1 then begin
  tipo:=355;
  principal1.FightingBasketball1.Checked:=true;
end;
if sender=principal1.diverboy1 then begin
  tipo:=356;
  principal1.diverboy1.Checked:=true;
end;
if sender=principal1.MugSmashers1 then begin
  tipo:=357;
  principal1.MugSmashers1.Checked:=true;
end;
if sender=principal1.steelforce1 then begin
  tipo:=358;
  principal1.steelforce1.Checked:=true;
end;
if sender=principal1.twinbrats1 then begin
  tipo:=359;
  principal1.twinbrats1.Checked:=true;
end;
if sender=principal1.mortalrace1 then begin
  tipo:=360;
  principal1.mortalrace1.Checked:=true;
end;
if sender=principal1.bankpanic1 then begin
  tipo:=361;
  principal1.bankpanic1.Checked:=true;
end;
if sender=principal1.combathawk1 then begin
  tipo:=362;
  principal1.combathawk1.Checked:=true;
end;
if sender=principal1.anteater1 then begin
  tipo:=363;
  principal1.anteater1.Checked:=true;
end;
if sender=principal1.appoooh1 then begin
  tipo:=364;
  principal1.appoooh1.Checked:=true;
end;
if sender=principal1.robowres1 then begin
  tipo:=365;
  principal1.robowres1.Checked:=true;
end;
if sender=principal1.armoredcar1 then begin
  tipo:=366;
  principal1.armoredcar1.Checked:=true;
end;
if sender=principal1.n88games1 then begin
  tipo:=367;
  principal1.n88games1.Checked:=true;
end;
if sender=principal1.avengers1 then begin
  tipo:=368;
  principal1.avengers1.Checked:=true;
end;
if sender=principal1.theend1 then begin
  tipo:=369;
  principal1.theend1.Checked:=true;
end;
if sender=principal1.battleofatlantis1 then begin
  tipo:=370;
  principal1.battleofatlantis1.Checked:=true;
end;
if sender=principal1.bluehawk1 then begin
  tipo:=371;
  principal1.bluehawk1.Checked:=true;
end;
if sender=principal1.lastday1 then begin
  tipo:=372;
  principal1.lastday1.Checked:=true;
end;
if sender=principal1.gulfstorm1 then begin
  tipo:=373;
  principal1.gulfstorm1.Checked:=true;
end;
if sender=principal1.pollux1 then begin
  tipo:=374;
  principal1.pollux1.Checked:=true;
end;
if sender=principal1.flyingtiger1 then begin
  tipo:=375;
  principal1.flyingtiger1.Checked:=true;
end;
if sender=principal1.skyskipper1 then begin
  tipo:=376;
  principal1.skyskipper1.Checked:=true;
end;
if sender=principal1.blueprint1 then begin
  tipo:=377;
  principal1.blueprint1.Checked:=true;
end;
if sender=principal1.saturn1 then begin
  tipo:=378;
  principal1.saturn1.Checked:=true;
end;
if sender=principal1.grasspin1 then begin
  tipo:=379;
  principal1.grasspin1.Checked:=true;
end;
if sender=principal1.burglarx1 then begin
  tipo:=380;
  principal1.burglarx1.Checked:=true;
end;
if sender=principal1.zeropoint1 then begin
  tipo:=381;
  principal1.zeropoint1.Checked:=true;
end;
if sender=principal1.calipso1 then begin
  tipo:=382;
  principal1.calipso1.Checked:=true;
end;
if sender=principal1.caloriekun1 then begin
  tipo:=383;
  principal1.caloriekun1.Checked:=true;
end;
if sender=principal1.gardia1 then begin
  tipo:=384;
  principal1.gardia1.Checked:=true;
end;
if sender=principal1.cavelon1 then begin
  tipo:=385;
  principal1.cavelon1.Checked:=true;
end;
if sender=principal1.comebacktoto1 then begin
  tipo:=386;
  principal1.comebacktoto1.Checked:=true;
end;
if sender=principal1.hyperpacman1 then begin
  tipo:=387;
  principal1.hyperpacman1.Checked:=true;
end;
if sender=principal1.kikikaikai1 then begin
  tipo:=388;
  principal1.kikikaikai1.Checked:=true;
end;
if sender=principal1.kickandrun1 then begin
  tipo:=389;
  principal1.kickandrun1.Checked:=true;
end;
if sender=principal1.lasso1 then begin
  tipo:=390;
  principal1.lasso1.Checked:=true;
end;
if sender=principal1.chameleon1 then begin
  tipo:=391;
  principal1.chameleon1.Checked:=true;
end;
if sender=principal1.lastmission1 then begin
  tipo:=392;
  principal1.lastmission1.Checked:=true;
end;
if sender=principal1.shackled1 then begin
  tipo:=393;
  principal1.shackled1.Checked:=true;
end;
if sender=principal1.gondomania1 then begin
  tipo:=394;
  principal1.Gondomania1.Checked:=true;
end;
if sender=principal1.garyoretsuden1 then begin
  tipo:=395;
  principal1.garyoretsuden1.Checked:=true;
end;
if sender=principal1.captainsilver1 then begin
  tipo:=396;
  principal1.captainsilver1.Checked:=true;
end;
if sender=principal1.cobracommand1 then begin
  tipo:=397;
  principal1.cobracommand1.Checked:=true;
end;
if sender=principal1.ghostbusters1 then begin
  tipo:=398;
  principal1.ghostbusters1.Checked:=true;
end;
if sender=principal1.oscar1 then begin
  tipo:=399;
  principal1.oscar1.Checked:=true;
end;
if sender=principal1.roadfighter1 then begin
  tipo:=400;
  principal1.roadfighter1.Checked:=true;
end;
if sender=principal1.ponpoko1 then begin
  tipo:=401;
  principal1.ponpoko1.Checked:=true;
end;
if sender=principal1.woodpecker1 then begin
  tipo:=402;
  principal1.woodpecker1.Checked:=true;
end;
if sender=principal1.eyes1 then begin
  tipo:=403;
  principal1.eyes1.Checked:=true;
end;
if sender=principal1.alibaba1 then begin
  tipo:=404;
  principal1.alibaba1.Checked:=true;
end;
if sender=principal1.piranha1 then begin
  tipo:=405;
  principal1.piranha1.Checked:=true;
end;
if sender=principal1.finalstarforce1 then begin
  tipo:=406;
  principal1.finalstarforce1.Checked:=true;
end;
if sender=principal1.WyvernF01 then begin
  tipo:=407;
  principal1.WyvernF01.Checked:=true;
end;
if sender=principal1.riotcity1 then begin
  tipo:=408;
  principal1.riotcity1.Checked:=true;
end;
if sender=principal1.sdi1 then begin
  tipo:=409;
  principal1.sdi1.Checked:=true;
end;
if sender=principal1.cotton1 then begin
  tipo:=410;
  principal1.cotton1.Checked:=true;
end;
if sender=principal1.dotron1 then begin
  tipo:=411;
  principal1.dotron1.Checked:=true;
end;
if sender=principal1.tron1 then begin
  tipo:=412;
  principal1.tron1.Checked:=true;
end;
if sender=principal1.timber1 then begin
  tipo:=413;
  principal1.timber1.Checked:=true;
end;
if sender=principal1.shollow1 then begin
  tipo:=414;
  principal1.shollow1.Checked:=true;
end;
if sender=principal1.domino1 then begin
  tipo:=415;
  principal1.domino1.Checked:=true;
end;
if sender=principal1.wacko1 then begin
  tipo:=416;
  principal1.wacko1.Checked:=true;
end;
if sender=principal1.nastar1 then begin
  tipo:=417;
  principal1.nastar1.Checked:=true;
end;
if sender=principal1.masterw1 then begin
  tipo:=418;
  principal1.masterw1.Checked:=true;
end;
//consolas
if sender=principal1.NES1 then begin
  tipo:=1000;
  principal1.NES1.Checked:=true;
end;
if sender=principal1.colecovision1 then begin
  tipo:=1001;
  principal1.colecovision1.Checked:=true;
end;
if sender=principal1.gameboy1 then begin
  tipo:=1002;
  principal1.GameBoy1.Checked:=true;
end;
if sender=principal1.chip81 then begin
  tipo:=1003;
  principal1.CHIP81.Checked:=true;
end;
if sender=principal1.segams1 then begin
  tipo:=1004;
  principal1.segams1.Checked:=true;
end;
if sender=principal1.sg10001 then begin
  tipo:=1005;
  principal1.sg10001.Checked:=true;
end;
if sender=principal1.segagg1 then begin
  tipo:=1006;
  principal1.segagg1.Checked:=true;
end;
if sender=principal1.scv1 then begin
  tipo:=1007;
  principal1.scv1.Checked:=true;
end;
if sender=principal1.genesis1 then begin
  tipo:=1008;
  principal1.genesis1.Checked:=true;
end;
if sender=principal1.pv1000 then begin
  tipo:=1009;
  principal1.pv1000.Checked:=true;
end;
if sender=principal1.pv2000 then begin
  tipo:=1010;
  principal1.pv2000.Checked:=true;
end;
//GNW
if sender=principal1.DonkeyKongjr1 then begin
  tipo:=2000;
  principal1.DonkeyKongjr1.Checked:=true;
end;
if sender=principal1.DonkeyKongII1 then begin
  tipo:=2001;
  principal1.DonkeyKongII1.Checked:=true;
end;
if sender=principal1.MarioBros1 then begin
  tipo:=2002;
  principal1.MarioBros1.Checked:=true;
end;
//Buscar el nombre de la maquina
for f:=1 to games_cont do begin
  if games_desc[f].grid=tipo then begin
    llamadas_maquina.caption:=games_desc[f].name;
    break;
  end;
end;
//Dar el numero de maquina emulada
tipo_cambio_maquina:=tipo;
end;

end.
