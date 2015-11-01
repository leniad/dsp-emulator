unit init_games;

interface
uses sysutils,main_engine,
  //Computer
  spectrum_48k,spectrum_128k,spectrum_3,amstrad_cpc,
  //Console
  nes,coleco,gb,sms,
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
  timepilot_hw,pengo_hw,twincobra_hw,jrpacman_hw,dec0_hw,tumblepop_hw,
  funkyjet_hw,superburgertime_hw,cavemanninja_hw,dietgogo_hw,actfancer_hw,
  arabian_hw,higemaru_hw,bagman_hw,chip8_hw,zaxxon_hw,kangaroo_hw,
  bioniccommando_hw,wwfsuperstars_hw,rainbowislands_hw,volfied_hw,
  operationwolf_hw,outrun_hw,taitosj_hw,vulgus_hw,ddragon3_hw,blockout_hw,
  foodfight_hw,nemesis_hw,pirates_hw,junofirst_hw,gyruss_hw,freekick_hw,
  boogiewings_hw,pinballaction_hw,renegade_hw;

type
  tgame_desc=record
              name,year:string;
              snd:byte;
              hi:boolean;
              zip:string;
              grid:word;
              company:string;
            end;
const
  sound_tipo:array[0..4] of string=('NO','YES','SAMPLES','YES+SAMPLES','PARTIAL');
  games_cont=218;
  games_desc:array[1..games_cont] of tgame_desc=(
  //Computers
  (name:'Spectrum 48K';year:'1982';snd:1;hi:false;zip:'spectrum.zip';grid:0;company:'Sinclair'),
  (name:'Spectrum 128K';year:'1986';snd:1;hi:false;zip:'spec128.zip';grid:1;company:'Sinclair'),
  (name:'Spectrum +3';year:'1987';snd:1;hi:false;zip:'plus3.zip';grid:2;company:'Amstrad'),
  (name:'Spectrum +2A';year:'1987';snd:1;hi:false;zip:'plus3.zip';grid:3;company:'Amstrad'),
  (name:'Spectrum +2';year:'1986';snd:1;hi:false;zip:'plus2.zip';grid:4;company:'Amstrad'),
  (name:'Spectrum 16K';year:'1982';snd:1;hi:false;zip:'spectrum.zip';grid:5;company:'Sinclair'),
  (name:'Amstrad CPC 464';year:'1984';snd:1;hi:false;zip:'cpc464.zip';grid:7;company:'Amstrad'),
  (name:'Amstrad CPC 664';year:'1984';snd:1;hi:false;zip:'cpc664.zip';grid:8;company:'Amstrad'),
  (name:'Amstrad CPC 6128';year:'1985';snd:1;hi:false;zip:'cpc6128.zip';grid:9;company:'Amstrad'),
  //Arcade
  (name:'Pacman';year:'1980';snd:1;hi:false;zip:'pacman.zip';grid:10;company:'Namco'),
  (name:'Phoenix';year:'1980';snd:1;hi:false;zip:'phoenix.zip';grid:11;company:'Amstar Electronics'),
  (name:'Mysterious Stones';year:'1984';snd:1;hi:false;zip:'mystston.zip';grid:12;company:'Technos'),
  (name:'Bomb Jack';year:'1984';snd:1;hi:false;zip:'bombjack.zip';grid:13;company:'Tehkan'),
  (name:'Frogger';year:'1981';snd:1;hi:true;zip:'frogger.zip';grid:14;company:'Konami'),
  (name:'Donkey Kong';year:'1981';snd:2;hi:false;zip:'dkong.zip';grid:15;company:'Nintendo'),
  (name:'Black Tiger';year:'1986';snd:1;hi:true;zip:'blktiger.zip';grid:16;company:'Capcom'),
  (name:'Green Beret';year:'1985';snd:1;hi:true;zip:'gberet.zip';grid:17;company:'Konami'),
  (name:'Commando';year:'1985';snd:1;hi:false;zip:'commando.zip';grid:18;company:'Capcom'),
  (name:'Ghosts''n Goblins';year:'1985';snd:1;hi:false;zip:'gng.zip';grid:19;company:'Capcom'),
  (name:'Mikie';year:'1985';snd:1;hi:false;zip:'mikie.zip';grid:20;company:'Konami'),
  (name:'Shaolin''s Road';year:'1985';snd:1;hi:false;zip:'shaolins.zip';grid:21;company:'Konami'),
  (name:'Yie Ar Kung-Fu';year:'1985';snd:1;hi:false;zip:'yiear.zip';grid:22;company:'Konami'),
  (name:'Asteroids';year:'1979';snd:3;hi:false;zip:'asteroid.zip';grid:23;company:'Atari'),
  (name:'Son Son';year:'1984';snd:1;hi:false;zip:'sonson.zip';grid:24;company:'Capcom'),
  (name:'Star Force';year:'1984';snd:1;hi:false;zip:'starforc.zip';grid:25;company:'Tehkan'),
  (name:'Rygar';year:'1986';snd:1;hi:false;zip:'rygar.zip';grid:26;company:'Tecmo'),
  (name:'Pitfall II';year:'1984';snd:1;hi:false;zip:'pitfall2.zip';grid:27;company:'Sega'),
  (name:'Pooyan';year:'1982';snd:1;hi:false;zip:'pooyan.zip';grid:28;company:'Konami'),
  (name:'Jungler';year:'1981';snd:1;hi:false;zip:'jungler.zip';grid:29;company:'Konami'),
  (name:'City Connection';year:'1986';snd:1;hi:false;zip:'citycon.zip';grid:30;company:'Jaleco'),
  (name:'Burger Time';year:'1982';snd:1;hi:false;zip:'btime.zip';grid:31;company:'Deco'),
  (name:'Express Raider';year:'1986';snd:1;hi:false;zip:'exprraid.zip';grid:32;company:'Deco'),
  (name:'Super Basketball';year:'1984';snd:1;hi:false;zip:'sbasketb.zip';grid:33;company:'Konami'),
  (name:'Lady Bug';year:'1981';snd:1;hi:false;zip:'ladybug.zip';grid:34;company:'Universal'),
  (name:'Teddy Boy Blues';year:'1985';snd:1;hi:false;zip:'teddybb.zip';grid:35;company:'Sega'),
  (name:'Wonder Boy';year:'1986';snd:1;hi:false;zip:'wboy.zip';grid:36;company:'Sega'),
  (name:'Wonder Boy in Monster Land';year:'1987';snd:1;hi:false;zip:'wbml.zip';grid:37;company:'Sega'),
  (name:'Tehkan World Cup';year:'1985';snd:1;hi:false;zip:'tehkanwc.zip';grid:38;company:'Tehkan'),
  (name:'Popeye';year:'1982';snd:1;hi:false;zip:'popeye.zip';grid:39;company:'Nintendo'),
  (name:'Psychic 5';year:'1987';snd:1;hi:false;zip:'psychic5.zip';grid:40;company:'Jaleco'),
  (name:'Terra Cresta';year:'198X';snd:1;hi:false;zip:'terracre.zip';grid:41;company:'Nichibutsu'),
  (name:'Kung-Fu Master';year:'1987';snd:1;hi:false;zip:'kungfum.zip';grid:42;company:'Irem'),
  (name:'Shoot Out';year:'1985';snd:1;hi:false;zip:'shootout.zip';grid:43;company:'Data East'),
  (name:'Vigilante';year:'1988';snd:1;hi:false;zip:'vigilant.zip';grid:44;company:'Irem'),
  (name:'Jackal';year:'1986';snd:1;hi:false;zip:'jackal.zip';grid:45;company:'Konami'),
  (name:'Bubble Bobble';year:'1986';snd:1;hi:false;zip:'bublbobl.zip';grid:46;company:'Taito'),
  (name:'Galaxian';year:'1980';snd:2;hi:false;zip:'galaxian.zip';grid:47;company:'Namco'),
  (name:'Jump Bug';year:'1981';snd:1;hi:false;zip:'jumpbug.zip';grid:48;company:'Rock-Ola'),
  (name:'Moon Cresta';year:'1980';snd:0;hi:false;zip:'mooncrst.zip';grid:49;company:'Nichibutsu'),
  (name:'Rally X';year:'1980';snd:3;hi:false;zip:'rallyx.zip';grid:50;company:'Namco'),
  (name:'Prehistoric Isle in 1930';year:'1989';snd:1;hi:false;zip:'prehisle.zip';grid:51;company:'SNK'),
  (name:'Tiger Road';year:'1987';snd:1;hi:false;zip:'tigeroad.zip';grid:52;company:'Capcom'),
  (name:'F1 Dream';year:'1988';snd:1;hi:false;zip:'f1dream.zip';grid:53;company:'Capcom'),
  (name:'Snowbros';year:'1980';snd:1;hi:false;zip:'snowbros.zip';grid:54;company:'Toaplan'),
  (name:'Toki';year:'1989';snd:1;hi:false;zip:'toki.zip';grid:55;company:'TAD'),
  (name:'Contra';year:'1987';snd:1;hi:false;zip:'contra.zip';grid:56;company:'Konami'),
  (name:'Mappy';year:'1983';snd:1;hi:false;zip:'mappy.zip';grid:57;company:'Namco'),
  (name:'Rastan';year:'1987';snd:1;hi:false;zip:'rastan.zip';grid:58;company:'Taito'),
  (name:'Legendary Wings';year:'1986';snd:1;hi:false;zip:'lwings.zip';grid:59;company:'Capcom'),
  (name:'Section Z';year:'1985';snd:1;hi:false;zip:'sectionz.zip';grid:60;company:'Capcom'),
  (name:'Trojan';year:'1986';snd:1;hi:false;zip:'trojan.zip';grid:61;company:'Capcom'),
  (name:'Street Fighter';year:'1987';snd:1;hi:false;zip:'sf.zip';grid:62;company:'Capcom'),
  (name:'DigDug II';year:'1985';snd:1;hi:false;zip:'digdug2.zip';grid:63;company:'Namco'),
  (name:'Super Pacman';year:'1985';snd:1;hi:false;zip:'superpac.zip';grid:64;company:'Namco'),
  (name:'Galaga';year:'1981';snd:1;hi:false;zip:'galaga.zip';grid:65;company:'Namco'),
  (name:'Xain''d Sleena';year:'1986';snd:1;hi:false;zip:'xsleena.zip';grid:66;company:'Technos'),
  (name:'Hard Head';year:'1988';snd:1;hi:false;zip:'hardhead.zip';grid:67;company:'Suna'),
  (name:'Hard Head 2';year:'1989';snd:0;hi:false;zip:'hardhea2.zip';grid:68;company:'Suna'),
  (name:'Saboten Bombers';year:'1992';snd:1;hi:false;zip:'sabotenb.zip';grid:69;company:'NMK'),
  (name:'New Rally X';year:'1981';snd:3;hi:false;zip:'nrallyx.zip';grid:70;company:'Namco'),
  (name:'Bomb Jack Twin';year:'1993';snd:1;hi:false;zip:'bjtwin.zip';grid:71;company:'NMK'),
  (name:'Spelunker';year:'1985';snd:1;hi:false;zip:'spelunkr.zip';grid:72;company:'Broderbound'),
  (name:'Spelunker II';year:'1986';snd:1;hi:false;zip:'spelunk2.zip';grid:73;company:'Broderbound'),
  (name:'Lode Runner';year:'1984';snd:1;hi:false;zip:'ldrun.zip';grid:74;company:'Irem'),
  (name:'Lode Runner II';year:'1984';snd:1;hi:false;zip:'ldrun2.zip';grid:75;company:'Irem'),
  (name:'Knuckle Joe';year:'1985';snd:1;hi:false;zip:'kncljoe.zip';grid:76;company:'Taito'),
  (name:'Wardner';year:'1987';snd:1;hi:false;zip:'wardner.zip';grid:77;company:'Taito'),
  (name:'Big Karnak';year:'1991';snd:1;hi:false;zip:'bigkarnk.zip';grid:78;company:'Gaelco'),
  (name:'Exed-Exes';year:'1985';snd:1;hi:false;zip:'exedexes.zip';grid:79;company:'Capcom'),
  (name:'Gun.Smoke';year:'1985';snd:1;hi:false;zip:'gunsmoke.zip';grid:80;company:'Capcom'),
  (name:'1942';year:'1984';snd:1;hi:false;zip:'1942.zip';grid:81;company:'Capcom'),
  (name:'1943';year:'1987';snd:1;hi:false;zip:'1943.zip';grid:82;company:'Capcom'),
  (name:'1943 Kai';year:'1987';snd:1;hi:false;zip:'1943kai.zip';grid:83;company:'Capcom'),
  (name:'Jail Break';year:'1986';snd:1;hi:false;zip:'jailbrek.zip';grid:84;company:'Konami'),
  (name:'Circus Chalie';year:'1984';snd:1;hi:false;zip:'circusc.zip';grid:85;company:'Konami'),
  (name:'Iron Horse';year:'1986';snd:1;hi:false;zip:'ironhors.zip';grid:86;company:'Konami'),
  (name:'R-Type';year:'1987';snd:0;hi:false;zip:'rtype.zip';grid:87;company:'Irem'),
  (name:'MS. Pac-man';year:'1981';snd:1;hi:false;zip:'mspacman.zip';grid:88;company:'Namco'),
  (name:'Break Thru';year:'1986';snd:1;hi:false;zip:'brkthru.zip';grid:89;company:'Data East'),
  (name:'Darwin 4078';year:'1986';snd:1;hi:false;zip:'darwin.zip';grid:90;company:'Data East'),
  (name:'Super Real Darwin';year:'1987';snd:1;hi:false;zip:'srdarwin.zip';grid:91;company:'Data East'),
  (name:'Double Dragon';year:'1987';snd:1;hi:false;zip:'ddragon.zip';grid:92;company:'Taito'),
  (name:'Mr. Do!';year:'1982';snd:1;hi:false;zip:'mrdo.zip';grid:93;company:'Universal'),
  (name:'The Glob';year:'1983';snd:1;hi:false;zip:'theglob.zip';grid:94;company:'Epos'),
  (name:'Super Glob';year:'1983';snd:1;hi:false;zip:'suprglob.zip';grid:95;company:'Epos'),
  (name:'Double Dragon II - The Revenge';year:'1988';snd:1;hi:false;zip:'ddragon2.zip';grid:96;company:'Technos'),
  (name:'Silk Worm';year:'1988';snd:1;hi:false;zip:'silkworm.zip';grid:97;company:'Tecmo'),
  (name:'Tiger Heli';year:'1985';snd:1;hi:false;zip:'tigerh.zip';grid:98;company:'Taito'),
  (name:'Slap Fight';year:'1986';snd:1;hi:false;zip:'slapfigh.zip';grid:99;company:'Taito'),
  (name:'The Legend of Kage';year:'1984';snd:1;hi:false;zip:'lkage.zip';grid:100;company:'Taito'),
  (name:'Thunder Hoop';year:'1992';snd:1;hi:false;zip:'thoop.zip';grid:101;company:'Gaelco'),
  (name:'Cabal';year:'1988';snd:1;hi:false;zip:'cabal.zip';grid:102;company:'TAD'),
  (name:'Ghouls''n Ghosts';year:'1988';snd:1;hi:false;zip:'ghouls.zip';grid:103;company:'Capcom'),
  (name:'Final Fight';year:'1989';snd:1;hi:false;zip:'ffight.zip';grid:104;company:'Capcom'),
  (name:'The King of Dragons';year:'1991';snd:1;hi:false;zip:'kod.zip';grid:105;company:'Capcom'),
  (name:'Street Fighter II - The World Warrior';year:'1991';snd:1;hi:false;zip:'sf2.zip';grid:106;company:'Capcom'),
  (name:'Strider';year:'1989';snd:1;hi:false;zip:'strider.zip';grid:107;company:'Capcom'),
  (name:'Three Wonders';year:'1991';snd:1;hi:false;zip:'3wonders.zip';grid:108;company:'Capcom'),
  (name:'Captain Commando';year:'1991';snd:1;hi:false;zip:'captcomm.zip';grid:109;company:'Capcom'),
  (name:'Knights of the Round';year:'1991';snd:1;hi:false;zip:'knights.zip';grid:110;company:'Capcom'),
  (name:'Street Fighter II'': Champion Edition';year:'1992';snd:1;hi:false;zip:'sf2ce.zip';grid:111;company:'Capcom'),
  (name:'Cadillacs and Dinosaurs';year:'1992';snd:1;hi:false;zip:'dino.zip';grid:112;company:'Capcom'),
  (name:'The Punisher';year:'1993';snd:1;hi:false;zip:'punisher.zip';grid:113;company:'Capcom'),
  (name:'Shinobi';year:'1987';snd:4;hi:false;zip:'shinobi.zip';grid:114;company:'Sega'),
  (name:'Alex Kidd';year:'1986';snd:4;hi:false;zip:'alexkidd.zip';grid:115;company:'Sega'),
  (name:'Fantasy Zone';year:'1986';snd:4;hi:false;zip:'fantzone.zip';grid:116;company:'Sega'),
  (name:'Time Pilot ''84';year:'1984';snd:1;hi:false;zip:'tp84.zip';grid:117;company:'Konami'),
  (name:'Tutankham';year:'1982';snd:1;hi:false;zip:'tutankhm.zip';grid:118;company:'Konami'),
  (name:'Pang';year:'1989';snd:4;hi:false;zip:'pang.zip';grid:119;company:'Capcom'),
  (name:'Ninja Kid II';year:'1987';snd:4;hi:false;zip:'ninjakd2.zip';grid:120;company:'UPL'),
  (name:'Ark Area';year:'1988';snd:1;hi:false;zip:'arkarea.zip';grid:121;company:'UPL'),
  (name:'Mutant Night';year:'1987';snd:1;hi:false;zip:'mnight.zip';grid:122;company:'UPL'),
  (name:'Sky Kid';year:'1985';snd:1;hi:false;zip:'skykid.zip';grid:123;company:'Namco'),
  (name:'Rolling Thunder';year:'1986';snd:4;hi:false;zip:'rthunder.zip';grid:124;company:'Namco'),
  (name:'Hopping Mappy';year:'1986';snd:4;hi:false;zip:'hopmappy.zip';grid:125;company:'Namco'),
  (name:'Sky Kid Deluxe';year:'1986';snd:4;hi:false;zip:'skykiddx.zip';grid:126;company:'Namco'),
  (name:'Roc''n Rope';year:'1983';snd:1;hi:false;zip:'rocnrope.zip';grid:127;company:'Konami'),
  (name:'Repulse';year:'1985';snd:1;hi:false;zip:'repulse.zip';grid:128;company:'Sega'),
  (name:'The NewZealand Story';year:'1988';snd:1;hi:false;zip:'tnzs.zip';grid:129;company:'Taito'),
  (name:'Insector X';year:'1989';snd:1;hi:false;zip:'insectx.zip';grid:130;company:'Taito'),
  (name:'Pacland';year:'1984';snd:4;hi:false;zip:'pacland.zip';grid:131;company:'Namco'),
  (name:'Mario Bros.';year:'1983';snd:2;hi:false;zip:'mario.zip';grid:132;company:'Nintendo'),
  (name:'Solomon''s Key';year:'1986';snd:1;hi:false;zip:'solomon.zip';grid:133;company:'Tecmo'),
  (name:'Combat School';year:'1988';snd:1;hi:false;zip:'combatsc.zip';grid:134;company:'Konami'),
  (name:'Heavy Unit';year:'1988';snd:1;hi:false;zip:'hvyunit.zip';grid:135;company:'Taito'),
  (name:'P.O.W. - Prisoners of War';year:'1988';snd:1;hi:false;zip:'pow.zip';grid:136;company:'SNK'),
  (name:'Street Smart';year:'1988';snd:1;hi:false;zip:'streetsm.zip';grid:137;company:'SNK'),
  (name:'P47 - Phantom Fighter';year:'1989';snd:1;hi:false;zip:'p47.zip';grid:138;company:'Jaleco'),
  (name:'Rod-Land';year:'1990';snd:1;hi:false;zip:'rodland.zip';grid:139;company:'Jaleco'),
  (name:'Saint Dragon';year:'1989';snd:1;hi:false;zip:'stdragon.zip';grid:140;company:'Jaleco'),
  (name:'Time Pilot';year:'1982';snd:1;hi:false;zip:'timeplt.zip';grid:141;company:'Konami'),
  (name:'Pengo';year:'1982';snd:1;hi:false;zip:'pengo.zip';grid:142;company:'Sega'),
  (name:'Scramble';year:'1981';snd:1;hi:false;zip:'scramble.zip';grid:143;company:'Konami'),
  (name:'Super Cobra';year:'1981';snd:1;hi:false;zip:'scobra.zip';grid:144;company:'Konami'),
  (name:'Amidar';year:'1981';snd:1;hi:false;zip:'amidar.zip';grid:145;company:'Konami'),
  (name:'Twin Cobra';year:'1987';snd:1;hi:false;zip:'twincobr.zip';grid:146;company:'Taito'),
  (name:'Flying Shark';year:'1987';snd:1;hi:false;zip:'fshark.zip';grid:147;company:'Taito'),
  (name:'Jr. Pac-Man';year:'1983';snd:1;hi:false;zip:'jrpacman.zip';grid:148;company:'Bally Midway'),
  (name:'Ikari III - The Rescue';year:'1989';snd:1;hi:false;zip:'ikari3.zip';grid:149;company:'SNK'),
  (name:'Search and Rescue';year:'1989';snd:1;hi:false;zip:'searchar.zip';grid:150;company:'SNK'),
  (name:'Choplifter';year:'1985';snd:1;hi:false;zip:'choplift.zip';grid:151;company:'Sega'),
  (name:'Mister Viking';year:'1983';snd:1;hi:false;zip:'mrviking.zip';grid:152;company:'Sega'),
  (name:'Sega Ninja';year:'1985';snd:1;hi:false;zip:'seganinj.zip';grid:153;company:'Sega'),
  (name:'Up''n Down';year:'1983';snd:1;hi:false;zip:'upndown.zip';grid:154;company:'Sega'),
  (name:'Flicky';year:'1984';snd:1;hi:false;zip:'flicky.zip';grid:155;company:'Sega'),
  (name:'Robocop';year:'1988';snd:1;hi:false;zip:'robocop.zip';grid:156;company:'Data East'),
  (name:'Baddudes vs. DragonNinja';year:'1988';snd:1;hi:false;zip:'baddudes.zip';grid:157;company:'Data East'),
  (name:'Hippodrome';year:'1989';snd:1;hi:false;zip:'hippodrm.zip';grid:158;company:'Data East'),
  (name:'Tumble Pop';year:'1991';snd:1;hi:false;zip:'tumblep.zip';grid:159;company:'Data East'),
  (name:'Funky Jet';year:'1992';snd:1;hi:false;zip:'funkyjet.zip';grid:160;company:'Mitchell'),
  (name:'Super Burger Time';year:'1990';snd:1;hi:false;zip:'supbtime.zip';grid:161;company:'Data East'),
  (name:'Caveman Ninja';year:'1991';snd:1;hi:false;zip:'cninja.zip';grid:162;company:'Data East'),
  (name:'Robocop 2';year:'1991';snd:1;hi:false;zip:'robocop2.zip';grid:163;company:'Data East'),
  (name:'Diet Go Go';year:'1992';snd:1;hi:false;zip:'dietgo.zip';grid:164;company:'Data East'),
  (name:'Act-Fancer Cybernetick Hyper Weapon';year:'1989';snd:1;hi:false;zip:'actfancr.zip';grid:165;company:'Data East'),
  (name:'Arabian';year:'1983';snd:1;hi:false;zip:'arabian.zip';grid:166;company:'Sun Electronics'),
  (name:'Dig Dug';year:'1982';snd:1;hi:false;zip:'digdug.zip';grid:167;company:'Namco'),
  (name:'Donkey Kong Jr.';year:'1982';snd:2;hi:false;zip:'dkongjr.zip';grid:168;company:'Nintendo'),
  (name:'Donkey Kong 3';year:'1983';snd:1;hi:false;zip:'dkong3.zip';grid:169;company:'Nintendo'),
  (name:'Pirate Ship Higemaru';year:'1984';snd:1;hi:false;zip:'higemaru.zip';grid:170;company:'Capcom'),
  (name:'Bagman';year:'1982';snd:4;hi:false;zip:'bagman.zip';grid:171;company:'Valadon Automation'),
  (name:'Super Bagman';year:'1984';snd:4;hi:false;zip:'sbagman.zip';grid:172;company:'Valadon Automation'),
  (name:'Squash';year:'1992';snd:1;hi:false;zip:'squash.zip';grid:173;company:'Gaelco'),
  (name:'Biomechanical Toy';year:'1995';snd:1;hi:false;zip:'biomtoy.zip';grid:174;company:'Gaelco'),
  (name:'Congo Bongo';year:'1983';snd:3;hi:false;zip:'congo.zip';grid:175;company:'Sega'),
  (name:'Kangaroo';year:'1982';snd:1;hi:false;zip:'kangaroo.zip';grid:176;company:'Sun Electronics'),
  (name:'Bionic Commando';year:'1987';snd:1;hi:false;zip:'bionicc.zip';grid:177;company:'Capcom'),
  (name:'WWF Superstar';year:'1989';snd:1;hi:false;zip:'wwfsstar.zip';grid:178;company:'Technos Japan'),
  (name:'Rainbow Islands';year:'1987';snd:1;hi:false;zip:'rbisland.zip';grid:179;company:'Taito'),
  (name:'Rainbow Islands Extra';year:'1987';snd:1;hi:false;zip:'rbislande.zip';grid:180;company:'Taito'),
  (name:'Volfied';year:'1989';snd:1;hi:false;zip:'volfied.zip';grid:181;company:'Taito'),
  (name:'Operation Wolf';year:'1987';snd:1;hi:false;zip:'opwolf.zip';grid:182;company:'Taito'),
  (name:'Super Pang';year:'1990';snd:4;hi:false;zip:'spang.zip';grid:183;company:'Capcom'),
  (name:'Outrun';year:'1989';snd:0;hi:false;zip:'outrun.zip';grid:184;company:'Sega'),
  (name:'Elevator Action';year:'1989';snd:1;hi:false;zip:'elevator.zip';grid:185;company:'Taito'),
  (name:'Alien Syndrome';year:'1988';snd:1;hi:false;zip:'aliensyn.zip';grid:186;company:'Sega'),
  (name:'Wonder Boy III - Monster Lair';year:'1987';snd:1;hi:false;zip:'wb3.zip';grid:187;company:'Sega'),
  (name:'Zaxxon';year:'1982';snd:2;hi:false;zip:'zaxxon.zip';grid:188;company:'Sega'),
  (name:'Jungle King';year:'1982';snd:1;hi:false;zip:'junglek.zip';grid:189;company:'Taito'),
  (name:'Hammerin'' Harry';year:'1990';snd:1;hi:false;zip:'hharry.zip';grid:190;company:'Irem'),
  (name:'R-Type 2';year:'1989';snd:1;hi:false;zip:'rtype2.zip';grid:191;company:'Irem'),
  (name:'The Tower of Druaga';year:'1984';snd:1;hi:false;zip:'todruaga.zip';grid:192;company:'Namco'),
  (name:'Motos';year:'1985';snd:1;hi:false;zip:'motos.zip';grid:193;company:'Namco'),
  (name:'Dragon Buster';year:'1984';snd:1;hi:false;zip:'drgnbstr.zip';grid:194;company:'Namco'),
  (name:'Vulgus';year:'1984';snd:1;hi:false;zip:'vulgus.zip';grid:195;company:'Capcom'),
  (name:'Double Dragon 3 - The Rosetta Stone';year:'1990';snd:1;hi:false;zip:'ddragon3.zip';grid:196;company:'Technos'),
  (name:'Block Out';year:'1990';snd:1;hi:false;zip:'blockout.zip';grid:197;company:'Technos'),
  (name:'Tetris';year:'1988';snd:1;hi:false;zip:'tetris.zip';grid:198;company:'Sega'),
  (name:'Food Fight';year:'1982';snd:1;hi:false;zip:'foodf.zip';grid:199;company:'Atari'),
  (name:'Snap Jack';year:'1982';snd:1;hi:false;zip:'snapjack.zip';grid:200;company:'Universal'),
  (name:'Cosmic Avenger';year:'1981';snd:1;hi:false;zip:'cavenger.zip';grid:201;company:'Universal'),
  (name:'Pleiads';year:'1981';snd:0;hi:false;zip:'pleiads.zip';grid:202;company:'Tehkan'),
  (name:'Mr. Goemon';year:'1986';snd:1;hi:false;zip:'mrgoemon.zip';grid:203;company:'Konami'),
  (name:'Nemesis';year:'1985';snd:1;hi:false;zip:'nemesis.zip';grid:204;company:'Konami'),
  (name:'Twinbee';year:'1985';snd:1;hi:false;zip:'twinbee.zip';grid:205;company:'Konami'),
  (name:'Pirates';year:'1994';snd:1;hi:false;zip:'pirates.zip';grid:206;company:'NIX'),
  (name:'Genix Family';year:'1994';snd:1;hi:false;zip:'genix.zip';grid:207;company:'NIX'),
  (name:'Juno First';year:'1983';snd:1;hi:false;zip:'junofrst.zip';grid:208;company:'Konami'),
  (name:'Gyruss';year:'1983';snd:1;hi:false;zip:'gyruss.zip';grid:209;company:'Konami'),
  (name:'Boogie Wings';year:'1992';snd:1;hi:false;zip:'boogwing.zip';grid:210;company:'Data East'),
  (name:'Free Kick';year:'1987';snd:1;hi:false;zip:'freekick.zip';grid:211;company:'Nihon System'),
  (name:'Pinball Action';year:'1985';snd:1;hi:false;zip:'pbaction.zip';grid:212;company:'Tehkan'),
  (name:'Renegade';year:'1986';snd:1;hi:false;zip:'renegade.zip';grid:213;company:'Technos Japan'),
  //*** Consoles
  (name:'NES';year:'198X';snd:1;hi:false;zip:'';grid:1000;company:'Nintendo'),
  (name:'ColecoVision';year:'1980';snd:1;hi:false;zip:'coleco.zip';grid:1001;company:'Coleco'),
  (name:'GameBoy/GameBoy Color';year:'198X';snd:1;hi:false;zip:'';grid:1002;company:'Nintendo'),
  (name:'CHIP 8';year:'197X';snd:1;hi:false;zip:'';grid:1003;company:'-'),
  (name:'Sega Master System';year:'1985';snd:1;hi:false;zip:'';grid:1004;company:'Sega'));

var
  orden_games:array[1..games_cont] of word;

procedure load_game(numero:word);
procedure todos_false;
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
  1000:principal1.CambiarMaquina(principal1.NES1);
  1001:principal1.CambiarMaquina(principal1.colecovision1);
  1002:principal1.CambiarMaquina(principal1.Gameboy1);
  1003:principal1.CambiarMaquina(principal1.CHIP81);
  1004:principal1.CambiarMaquina(principal1.SegaMS1);
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
//consolas
principal1.NES1.Checked:=false;
principal1.colecovision1.Checked:=false;
principal1.GameBoy1.Checked:=false;
principal1.chip81.checked:=false;
principal1.segams1.checked:=false;
//Resto
principal1.BitBtn9.visible:=false;
principal1.BitBtn10.visible:=false;
principal1.BitBtn11.visible:=false;
principal1.BitBtn12.visible:=false;
principal1.BitBtn14.visible:=false;
principal1.BitBtn9.enabled:=false;
principal1.BitBtn10.enabled:=false;
principal1.BitBtn11.enabled:=false;
principal1.BitBtn12.enabled:=false;
principal1.BitBtn14.enabled:=false;
principal1.Panel2.Visible:=false;
end;

procedure cargar_maquina(tmaquina:word);
begin
case tmaquina of
  0,5:Cargar_Spectrum48K;
  1,4:Cargar_Spectrum128K;
  2,3:Cargar_Spectrum3;
  7,8,9:Cargar_amstrad_CPC;
  //arcade
  10,88:Cargar_Pacman;
  11,202:Cargar_Phoenix;
  12:Cargar_MS;
  13:Cargar_bombjack;
  14,47,48,49,143,144,145:Cargar_hgalaxian;
  15,168,169:Cargar_Dkong;
  16:Cargar_BlkTiger;
  17,203:Cargar_Gberet;
  18:Cargar_Commando;
  19:Cargar_gng;
  20:Cargar_mikie;
  21:Cargar_Shaolin;
  22:Cargar_Yiear;
  23:Cargar_as;
  24:cargar_sonson;
  25:Cargar_starforce;
  26,97:Cargar_tecmo;
  27,35,36,37,151,152,153,154,155:Cargar_system1;
  28:Cargar_pooyan;
  29,50,70:Cargar_rallyxh;
  30:Cargar_citycon;
  31:Cargar_btime;
  32:Cargar_expraid;
  33:Cargar_sbasketb;
  34,200,201:Cargar_ladybug;
  38:Cargar_tehkanwc;
  39:Cargar_popeye;
  40:Cargar_psychic5;
  41:Cargar_terracre;
  42,72,73,74,75:Cargar_irem_m62;
  43:Cargar_shootout;
  44:Cargar_vigilante;
  45:Cargar_jackal;
  46:Cargar_bublbobl;
  51:Cargar_prehisle;
  52,53:Cargar_tigeroad;
  54:Cargar_snowbros;
  55:Cargar_toki;
  56:Cargar_contra;
  57,63,64,192,193:Cargar_mappyhw;
  58:Cargar_rastan;
  59,60,61:Cargar_hlwings;
  62:Cargar_SFighter;
  65,167:Cargar_galagahw;
  66:Cargar_xain;
  67,68:Cargar_suna_hw;
  69,71:Cargar_nmk16;
  76:Cargar_knjoe;
  77:Cargar_wardnerhw;
  78,101,173,174:Cargar_gaelco_hw;
  79:Cargar_exedexes_hw;
  80,82,83:Cargar_gunsmokehw;
  81:Cargar_hw1942;
  84:Cargar_jailbreak;
  85:Cargar_circusc;
  86:Cargar_ironhorse;
  87,190,191:Cargar_irem_m72;
  89,90:Cargar_brkthru;
  91:Cargar_dec8;
  92,96:Cargar_ddragon;
  93:Cargar_mrdo;
  94,95:Cargar_epos_hw;
  98,99:Cargar_sf_hw;
  100:Cargar_lk_hw;
  102:Cargar_cabal;
  103,104,105,106,107,108,109,110,111,112,113:Cargar_cps1;
  114,115,116,186,187,198:Cargar_system16a;
  117:Cargar_tp84;
  118:Cargar_Tutankham;
  119,183:Cargar_Pang;
  120,121,122:Cargar_ninjakid2;
  123,194:Cargar_skykid;
  124,125,126:Cargar_system86;
  127:Cargar_rocnrope;
  128:Cargar_kyugo_hw;
  129,130:Cargar_tnzs;
  131:Cargar_pacland;
  132:Cargar_mario;
  133:Cargar_solomon;
  134:Cargar_combatsc;
  135:Cargar_hvyunit;
  136,137,149,150:Cargar_snk68;
  138,139,140:Cargar_megasys1;
  141:Cargar_timepilot;
  142:Cargar_pengo;
  146,147:Cargar_twincobra;
  148:Cargar_JrPacman;
  156,157,158:Cargar_DEC0;
  159:Cargar_tumblep;
  160:Cargar_funkyjet;
  161:Cargar_supbtime;
  162,163:Cargar_cninja;
  164:Cargar_Dietgo;
  165:Cargar_actfancer;
  166:Cargar_Arabian;
  170:Cargar_Higemaru;
  171,172:Cargar_bagman;
  175,188:Cargar_zaxxon;
  176:Cargar_kangaroo;
  177:Cargar_bionicc;
  178:Cargar_wwfsstar;
  179,180:Cargar_rainbow;
  181:Cargar_volfied;
  182:Cargar_opwolf;
  184:Cargar_outrun;
  185,189:Cargar_Taitosj;
  195:Cargar_vulgus;
  196:Cargar_ddragon3;
  197:Cargar_blockout;
  199:Cargar_foodf;
  204,205:Cargar_nemesis;
  206,207:Cargar_pirates;
  208:Cargar_junofrst;
  209:Cargar_gyruss;
  210:Cargar_boogwing;
  211:Cargar_freekick;
  212:Cargar_pinballaction;
  213:Cargar_renegade;
  //consolas
  1000:Cargar_NES;
  1001:Cargar_coleco;
  1002:Cargar_gb;
  1003:Cargar_chip8;
  1004:Cargar_SMS;
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
