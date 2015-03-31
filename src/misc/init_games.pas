unit init_games;

interface
uses sysutils,main_engine,
  //Computer
  spectrum_48k,spectrum_128k,spectrum_3,amstrad_cpc,
  //Console
  nes,coleco,gb,
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
  foodfight_hw,nemesis_hw,pirates_hw,junofirst_hw;

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
  games_cont=212;
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
  //*** Consoles
  (name:'NES';year:'198X';snd:1;hi:false;zip:'';grid:1000;company:'Nintendo'),
  (name:'ColecoVision';year:'1980';snd:1;hi:false;zip:'coleco.zip';grid:1001;company:'Coleco'),
  (name:'GameBoy/GameBoy Color';year:'198X';snd:1;hi:false;zip:'';grid:1002;company:'Nintendo'),
  (name:'CHIP 8';year:'197X';snd:1;hi:false;zip:'';grid:1003;company:'-'));

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
  0:form1.CambiarMaquina(form1.Spectrum48K1);
  1:form1.CambiarMaquina(form1.Spectrum128K1);
  2:form1.CambiarMaquina(form1.Spectrum31);
  3:form1.CambiarMaquina(form1.Spectrum2a1);
  4:form1.CambiarMaquina(form1.Spectrum21);
  5:form1.CambiarMaquina(form1.Spectrum16K1);
  7:form1.CambiarMaquina(form1.cpc1);
  8:form1.CambiarMaquina(form1.cpc6641);
  9:form1.CambiarMaquina(form1.cpc61281);
  10:form1.CambiarMaquina(form1.Pacman1);
  11:form1.CambiarMaquina(form1.Phoenix1);
  12:form1.CambiarMaquina(form1.MisteriousStone1);
  13:form1.CambiarMaquina(form1.BombJack1);
  14:form1.CambiarMaquina(form1.Frogger1);
  15:form1.CambiarMaquina(form1.Dkong1);
  16:form1.CambiarMaquina(form1.Blacktiger1);
  17:form1.CambiarMaquina(form1.Gberet1);
  18:form1.CambiarMaquina(form1.Commando1);
  19:form1.CambiarMaquina(form1.gng1);
  20:form1.CambiarMaquina(form1.Mikie1);
  21:form1.CambiarMaquina(form1.Shaolin1);
  22:form1.CambiarMaquina(form1.Yiear1);
  23:form1.CambiarMaquina(form1.Asteroids1);
  24:form1.CambiarMaquina(form1.SonSon1);
  25:form1.CambiarMaquina(form1.StarForce1);
  26:form1.CambiarMaquina(form1.Rygar1);
  27:form1.CambiarMaquina(form1.PitfallII1);
  28:form1.CambiarMaquina(form1.Pooyan1);
  29:form1.CambiarMaquina(form1.jungler1);
  30:form1.CambiarMaquina(form1.citycon1);
  31:form1.CambiarMaquina(form1.burgertime1);
  32:form1.CambiarMaquina(form1.expressraider1);
  33:form1.CambiarMaquina(form1.superbasketball1);
  34:form1.CambiarMaquina(form1.ladybug1);
  35:form1.CambiarMaquina(form1.teddy1);
  36:form1.CambiarMaquina(form1.wboy1);
  37:form1.CambiarMaquina(form1.wbml1);
  38:form1.CambiarMaquina(form1.tehkanwc1);
  39:form1.CambiarMaquina(form1.popeye1);
  40:form1.CambiarMaquina(form1.psychic51);
  41:form1.CambiarMaquina(form1.terracre1);
  42:form1.CambiarMaquina(form1.kungfum1);
  43:form1.CambiarMaquina(form1.shootout1);
  44:form1.CambiarMaquina(form1.vigilante1);
  45:form1.CambiarMaquina(form1.jackal1);
  46:form1.CambiarMaquina(form1.bubblebobble1);
  47:form1.CambiarMaquina(form1.galaxian1);
  48:form1.CambiarMaquina(form1.jumpb1);
  49:form1.CambiarMaquina(form1.mooncresta1);
  50:form1.CambiarMaquina(form1.rallyx1);
  51:form1.CambiarMaquina(form1.prehisle1);
  52:form1.CambiarMaquina(form1.tigerRoad1);
  53:form1.CambiarMaquina(form1.f1dream1);
  54:form1.CambiarMaquina(form1.snowbros1);
  55:form1.CambiarMaquina(form1.toki1);
  56:form1.CambiarMaquina(form1.contra1);
  57:form1.CambiarMaquina(form1.mappy1);
  58:form1.CambiarMaquina(form1.rastan1);
  59:form1.CambiarMaquina(form1.legendw1);
  60:form1.CambiarMaquina(form1.sectionz1);
  61:form1.CambiarMaquina(form1.trojan1);
  62:form1.CambiarMaquina(form1.sf1);
  63:form1.CambiarMaquina(form1.digdug21);
  64:form1.CambiarMaquina(form1.spacman1);
  65:form1.CambiarMaquina(form1.galaga1);
  66:form1.CambiarMaquina(form1.xain1);
  67:form1.CambiarMaquina(form1.hardhead1);
  68:form1.CambiarMaquina(form1.hardhead21);
  69:form1.CambiarMaquina(form1.sbombers1);
  70:form1.CambiarMaquina(form1.newrallyx1);
  71:form1.CambiarMaquina(form1.bjtwin1);
  72:form1.CambiarMaquina(form1.spelunker1);
  73:form1.CambiarMaquina(form1.spelunker21);
  74:form1.CambiarMaquina(form1.ldrun1);
  75:form1.CambiarMaquina(form1.ldrun21);
  76:form1.CambiarMaquina(form1.knjoe1);
  77:form1.CambiarMaquina(form1.wardner1);
  78:form1.CambiarMaquina(form1.bigkarnak1);
  79:form1.CambiarMaquina(form1.exedexes1);
  80:form1.CambiarMaquina(form1.gunsmoke1);
  81:form1.CambiarMaquina(form1.n19421);
  82:form1.CambiarMaquina(form1.n19431);
  83:form1.CambiarMaquina(form1.n1943kai1);
  84:form1.CambiarMaquina(form1.jailbreak1);
  85:form1.CambiarMaquina(form1.circusc1);
  86:form1.CambiarMaquina(form1.ironhorse1);
  87:form1.CambiarMaquina(form1.rtype1);
  88:form1.CambiarMaquina(form1.mspacman1);
  89:form1.CambiarMaquina(form1.brkthru1);
  90:form1.CambiarMaquina(form1.darwin1);
  91:form1.CambiarMaquina(form1.srd1);
  92:form1.CambiarMaquina(form1.ddragon1);
  93:form1.CambiarMaquina(form1.mrdo1);
  94:form1.CambiarMaquina(form1.theglob1);
  95:form1.CambiarMaquina(form1.superglob1);
  96:form1.CambiarMaquina(form1.ddragon21);
  97:form1.CambiarMaquina(form1.silkworm1);
  98:form1.CambiarMaquina(form1.tigerh1);
  99:form1.CambiarMaquina(form1.slapfight1);
  100:form1.CambiarMaquina(form1.legendofkage1);
  101:form1.CambiarMaquina(form1.thoop1);
  102:form1.CambiarMaquina(form1.cabal1);
  103:form1.CambiarMaquina(form1.ghouls1);
  104:form1.CambiarMaquina(form1.ffight1);
  105:form1.CambiarMaquina(form1.kod1);
  106:form1.CambiarMaquina(form1.sf21);
  107:form1.CambiarMaquina(form1.strider1);
  108:form1.CambiarMaquina(form1.wonder31);
  109:form1.CambiarMaquina(form1.ccommando1);
  110:form1.CambiarMaquina(form1.knights1);
  111:form1.CambiarMaquina(form1.sf2ce1);
  112:form1.CambiarMaquina(form1.dino1);
  113:form1.CambiarMaquina(form1.punisher1);
  114:form1.CambiarMaquina(form1.shinobi1);
  115:form1.CambiarMaquina(form1.alexkid1);
  116:form1.CambiarMaquina(form1.fantasyzone1);
  117:form1.CambiarMaquina(form1.tp841);
  118:form1.CambiarMaquina(form1.tutankhm1);
  119:form1.CambiarMaquina(form1.Pang1);
  120:form1.CambiarMaquina(form1.ninjakid21);
  121:form1.CambiarMaquina(form1.arkarea1);
  122:form1.CambiarMaquina(form1.mnight1);
  123:form1.CambiarMaquina(form1.skykid1);
  124:form1.CambiarMaquina(form1.rthunder1);
  125:form1.CambiarMaquina(form1.hopmappy1);
  126:form1.CambiarMaquina(form1.skykiddx1);
  127:form1.CambiarMaquina(form1.rocnrope1);
  128:form1.CambiarMaquina(form1.repulse1);
  129:form1.CambiarMaquina(form1.tnzs1);
  130:form1.CambiarMaquina(form1.insectorx1);
  131:form1.CambiarMaquina(form1.pacland1);
  132:form1.CambiarMaquina(form1.mariob1);
  133:form1.CambiarMaquina(form1.solomon1);
  134:form1.CambiarMaquina(form1.combatsc1);
  135:form1.CambiarMaquina(form1.hvyunit1);
  136:form1.CambiarMaquina(form1.pow1);
  137:form1.CambiarMaquina(form1.streetsm1);
  138:form1.CambiarMaquina(form1.p471);
  139:form1.CambiarMaquina(form1.rodland1);
  140:form1.CambiarMaquina(form1.saintdragon1);
  141:form1.CambiarMaquina(form1.TimePilot1);
  142:form1.CambiarMaquina(form1.Pengo1);
  143:form1.CambiarMaquina(form1.Scramble1);
  144:form1.CambiarMaquina(form1.Scobra1);
  145:form1.CambiarMaquina(form1.Amidar1);
  146:form1.CambiarMaquina(form1.twincobr1);
  147:form1.CambiarMaquina(form1.FlyingShark1);
  148:form1.CambiarMaquina(form1.JrPacman1);
  149:form1.CambiarMaquina(form1.Ikari31);
  150:form1.CambiarMaquina(form1.searchar1);
  151:form1.CambiarMaquina(form1.Choplifter1);
  152:form1.CambiarMaquina(form1.mrviking1);
  153:form1.CambiarMaquina(form1.SegaNinja1);
  154:form1.CambiarMaquina(form1.UpnDown1);
  155:form1.CambiarMaquina(form1.flicky1);
  156:form1.CambiarMaquina(form1.robocop1);
  157:form1.CambiarMaquina(form1.baddudes1);
  158:form1.CambiarMaquina(form1.hippo1);
  159:form1.CambiarMaquina(form1.tumblep1);
  160:form1.CambiarMaquina(form1.funkyjet1);
  161:form1.CambiarMaquina(form1.SuperBurgerTime1);
  162:form1.CambiarMaquina(form1.cninja1);
  163:form1.CambiarMaquina(form1.robocop21);
  164:form1.CambiarMaquina(form1.DietGo1);
  165:form1.CambiarMaquina(form1.actfancer1);
  166:form1.CambiarMaquina(form1.arabian1);
  167:form1.CambiarMaquina(form1.digdug1);
  168:form1.CambiarMaquina(form1.dkongjr1);
  169:form1.CambiarMaquina(form1.dkong31);
  170:form1.CambiarMaquina(form1.higemaru1);
  171:form1.CambiarMaquina(form1.bagman1);
  172:form1.CambiarMaquina(form1.sbagman1);
  173:form1.CambiarMaquina(form1.squash1);
  174:form1.CambiarMaquina(form1.biomtoy1);
  175:form1.CambiarMaquina(form1.congo1);
  176:form1.CambiarMaquina(form1.kangaroo1);
  177:form1.CambiarMaquina(form1.bionicc1);
  178:form1.CambiarMaquina(form1.wwfsuperstar1);
  179:form1.CambiarMaquina(form1.rbisland1);
  180:form1.CambiarMaquina(form1.rbislande1);
  181:form1.CambiarMaquina(form1.Volfied1);
  182:form1.CambiarMaquina(form1.Opwolf1);
  183:form1.CambiarMaquina(form1.SPang1);
  184:form1.CambiarMaquina(form1.Outrun1);
  185:form1.CambiarMaquina(form1.elevator1);
  186:form1.CambiarMaquina(form1.aliensyn1);
  187:form1.CambiarMaquina(form1.wb31);
  188:form1.CambiarMaquina(form1.zaxxon1);
  189:form1.CambiarMaquina(form1.jungleking1);
  190:form1.CambiarMaquina(form1.hharry1);
  191:form1.CambiarMaquina(form1.rtype21);
  192:form1.CambiarMaquina(form1.todruaga1);
  193:form1.CambiarMaquina(form1.motos1);
  194:form1.CambiarMaquina(form1.drgnbstr1);
  195:form1.CambiarMaquina(form1.vulgus1);
  196:form1.CambiarMaquina(form1.ddragon31);
  197:form1.CambiarMaquina(form1.blockout1);
  198:form1.CambiarMaquina(form1.tetris1);
  199:form1.CambiarMaquina(form1.foodf1);
  200:form1.CambiarMaquina(form1.snapjack1);
  201:form1.CambiarMaquina(form1.cavenger1);
  202:form1.CambiarMaquina(form1.pleiads1);
  203:form1.CambiarMaquina(form1.mrgoemon1);
  204:form1.CambiarMaquina(form1.nemesis1);
  205:form1.CambiarMaquina(form1.twinbee1);
  206:form1.CambiarMaquina(form1.pirates1);
  207:form1.CambiarMaquina(form1.genixfamily1);
  208:form1.CambiarMaquina(form1.junofirst1);
  1000:form1.CambiarMaquina(form1.NES1);
  1001:form1.CambiarMaquina(form1.colecovision1);
  1002:form1.CambiarMaquina(form1.Gameboy1);
  1003:form1.CambiarMaquina(form1.CHIP81);
end;
end;

procedure todos_false;
begin
//Computer
form1.Spectrum48K1.Checked:=false;
form1.Spectrum128K1.Checked:=false;
form1.Spectrum31.Checked:=false;
form1.Spectrum2A1.Checked:=false;
form1.Spectrum21.Checked:=false;
form1.Spectrum16k1.Checked:=false;
form1.CPC1.Checked:=false;
form1.CPC6641.Checked:=false;
form1.CPC61281.Checked:=false;
//Arcade
form1.phoenix1.Checked:=false;
form1.bombjack1.Checked:=false;
form1.pacman1.Checked:=false;
form1.frogger1.Checked:=false;
form1.dkong1.Checked:=false;
form1.blacktiger1.Checked:=false;
form1.gberet1.Checked:=false;
form1.StarForce1.Checked:=false;
form1.PitfallII1.Checked:=false;
form1.jungler1.Checked:=false;
form1.pooyan1.Checked:=false;
form1.Rygar1.Checked:=false;
form1.misteriousstone1.Checked:=false;
form1.Commando1.Checked:=false;
form1.gng1.Checked:=false;
form1.mikie1.Checked:=false;
form1.shaolin1.Checked:=false;
form1.yiear1.Checked:=false;
form1.asteroids1.Checked:=false;
form1.sonson1.Checked:=false;
form1.citycon1.Checked:=false;
form1.BurgerTime1.Checked:=false;
form1.ExpressRaider1.Checked:=false;
form1.superbasketball1.Checked:=false;
form1.teddy1.Checked:=false;
form1.wboy1.Checked:=false;
form1.wbml1.Checked:=false;
form1.ladybug1.Checked:=false;
form1.tehkanwc1.Checked:=false;
form1.popeye1.Checked:=false;
form1.Psychic51.Checked:=false;
form1.terracre1.Checked:=false;
form1.kungfum1.Checked:=false;
form1.shootout1.Checked:=false;
form1.Vigilante1.Checked:=false;
form1.bubblebobble1.Checked:=false;
form1.Jackal1.checked:=false;
form1.Galaxian1.Checked:=false;
form1.jumpb1.Checked:=false;
form1.mooncresta1.Checked:=false;
form1.RallyX1.Checked:=false;
form1.prehisle1.Checked:=false;
form1.TigerRoad1.Checked:=false;
form1.F1Dream1.Checked:=false;
form1.Snowbros1.Checked:=false;
form1.toki1.Checked:=false;
form1.Contra1.Checked:=false;
form1.Mappy1.Checked:=false;
form1.Rastan1.Checked:=false;
form1.legendw1.Checked:=false;
form1.SectionZ1.Checked:=false;
form1.Trojan1.Checked:=false;
form1.SF1.Checked:=false;
form1.DigDug21.Checked:=false;
form1.SPacman1.Checked:=false;
form1.Galaga1.Checked:=false;
form1.Xain1.Checked:=false;
form1.HardHead1.Checked:=false;
form1.hardhead21.checked:=false;
form1.sbombers1.Checked:=false;
form1.NewRallyX1.Checked:=false;
form1.bjtwin1.Checked:=false;
form1.Spelunker1.Checked:=false;
form1.Spelunker21.Checked:=false;
form1.ldrun1.Checked:=false;
form1.ldrun21.Checked:=false;
form1.knJoe1.Checked:=false;
form1.Wardner1.Checked:=false;
form1.BigKarnak1.Checked:=false;
form1.ExedExes1.Checked:=false;
form1.GunSmoke1.Checked:=false;
form1.N19421.Checked:=false;
form1.N19431.Checked:=false;
form1.N1943kai1.Checked:=false;
form1.JailBreak1.Checked:=false;
form1.Circusc1.Checked:=false;
form1.IronHorse1.Checked:=false;
form1.RType1.Checked:=false;
form1.MSPacman1.Checked:=false;
form1.BrkThru1.Checked:=false;
form1.Darwin1.Checked:=false;
form1.SRD1.Checked:=false;
form1.ddragon1.Checked:=false;
form1.MrDo1.Checked:=false;
form1.theglob1.Checked:=false;
form1.superglob1.Checked:=false;
form1.ddragon21.Checked:=false;
form1.Silkworm1.Checked:=false;
form1.tigerh1.Checked:=false;
form1.SlapFight1.Checked:=false;
form1.LegendofKage1.Checked:=false;
form1.thoop1.checked:=false;
form1.Cabal1.Checked:=false;
form1.ghouls1.Checked:=false;
form1.ffight1.Checked:=false;
form1.kod1.Checked:=false;
form1.sf21.Checked:=false;
form1.strider1.Checked:=false;
form1.wonder31.Checked:=false;
form1.ccommando1.Checked:=false;
form1.knights1.Checked:=false;
form1.sf2ce1.Checked:=false;
form1.dino1.Checked:=false;
form1.Punisher1.Checked:=false;
form1.Shinobi1.Checked:=false;
form1.AlexKid1.Checked:=false;
form1.FantasyZone1.Checked:=false;
form1.tp841.Checked:=false;
form1.tutankhm1.Checked:=false;
form1.Pang1.Checked:=false;
form1.ninjakid21.Checked:=false;
form1.ArkArea1.Checked:=false;
form1.mnight1.Checked:=false;
form1.SkyKid1.Checked:=false;
form1.rthunder1.Checked:=false;
form1.hopmappy1.Checked:=false;
form1.skykiddx1.Checked:=false;
form1.RocnRope1.Checked:=false;
form1.repulse1.checked:=false;
form1.tnzs1.Checked:=false;
form1.InsectorX1.Checked:=false;
form1.Pacland1.Checked:=false;
form1.mariob1.Checked:=false;
form1.Solomon1.Checked:=false;
form1.combatsc1.Checked:=false;
form1.hvyunit1.Checked:=false;
form1.pow1.Checked:=false;
form1.streetsm1.checked:=false;
form1.P471.Checked:=false;
form1.RodLand1.Checked:=false;
form1.SaintDragon1.Checked:=false;
form1.TimePilot1.Checked:=false;
form1.Pengo1.Checked:=false;
form1.scramble1.checked:=false;
form1.scobra1.Checked:=false;
form1.Amidar1.Checked:=false;
form1.twincobr1.checked:=false;
form1.FlyingShark1.Checked:=false;
form1.JrPacMan1.Checked:=false;
form1.Ikari31.Checked:=false;
form1.Searchar1.Checked:=false;
form1.Choplifter1.Checked:=false;
form1.mrviking1.Checked:=false;
form1.SegaNinja1.Checked:=false;
form1.UpnDown1.Checked:=false;
form1.flicky1.Checked:=false;
form1.robocop1.Checked:=false;
form1.Baddudes1.Checked:=false;
form1.Hippo1.Checked:=false;
form1.tumblep1.checked:=false;
form1.funkyjet1.checked:=false;
form1.SuperBurgerTime1.Checked:=false;
form1.cninja1.Checked:=false;
form1.Robocop21.Checked:=false;
form1.DietGo1.Checked:=false;
form1.ActFancer1.Checked:=false;
form1.Arabian1.Checked:=false;
form1.DigDug1.Checked:=false;
form1.dkongjr1.Checked:=false;
form1.dkong31.Checked:=false;
form1.Higemaru1.Checked:=false;
form1.Bagman1.Checked:=false;
form1.sBagman1.Checked:=false;
form1.squash1.Checked:=false;
form1.biomtoy1.Checked:=false;
form1.congo1.Checked:=false;
form1.kangaroo1.Checked:=false;
form1.bionicc1.Checked:=false;
form1.wwfsuperstar1.Checked:=false;
form1.rbisland1.checked:=false;
form1.rbislande1.checked:=false;
form1.Volfied1.Checked:=false;
form1.opwolf1.Checked:=false;
form1.spang1.checked:=false;
form1.Outrun1.Checked:=false;
form1.elevator1.checked:=false;
form1.aliensyn1.checked:=false;
form1.wb31.checked:=false;
form1.zaxxon1.checked:=false;
form1.jungleking1.checked:=false;
form1.hharry1.Checked:=false;
form1.RType21.Checked:=false;
form1.todruaga1.checked:=false;
form1.motos1.checked:=false;
form1.drgnbstr1.checked:=false;
form1.vulgus1.checked:=false;
form1.ddragon31.Checked:=false;
form1.BlockOut1.Checked:=false;
form1.tetris1.checked:=false;
form1.foodf1.checked:=false;
form1.snapjack1.checked:=false;
form1.cavenger1.Checked:=false;
form1.pleiads1.checked:=false;
form1.MrGoemon1.Checked:=false;
form1.Nemesis1.Checked:=false;
form1.twinbee1.Checked:=false;
form1.Pirates1.Checked:=false;
form1.GenixFamily1.Checked:=false;
form1.junofirst1.checked:=false;
//consolas
form1.NES1.Checked:=false;
form1.colecovision1.Checked:=false;
form1.GameBoy1.Checked:=false;
form1.chip81.checked:=false;
//Resto
form1.BitBtn9.visible:=false;
form1.BitBtn10.visible:=false;
form1.BitBtn11.visible:=false;
form1.BitBtn12.visible:=false;
form1.BitBtn14.visible:=false;
form1.BitBtn9.enabled:=false;
form1.BitBtn10.enabled:=false;
form1.BitBtn11.enabled:=false;
form1.BitBtn12.enabled:=false;
form1.BitBtn14.enabled:=false;
form1.Panel2.Visible:=false;
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
  13:Cargar_BJ;
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
  //consolas
  1000:Cargar_NES;
  1001:Cargar_coleco;
  1002:Cargar_gb;
  1003:Cargar_chip8;
end;
end;

function tipo_cambio_maquina(sender:TObject):word;
var
  tipo,f:word;
begin
//Computers
if sender=form1.Spectrum48K1 then begin
  tipo:=0;
  form1.Spectrum48K1.Checked:=true;
end;
if sender=form1.Spectrum128K1 then begin
  tipo:=1;
  form1.Spectrum128K1.Checked:=true;
end;
if sender=form1.Spectrum31 then begin
  tipo:=2;
  form1.Spectrum31.Checked:=true;
end;
if sender=form1.Spectrum2A1 then begin
  tipo:=3;
  form1.Spectrum2A1.Checked:=true;
end;
if sender=form1.Spectrum21 then begin
  tipo:=4;
  form1.Spectrum21.Checked:=true;
end;
if sender=form1.Spectrum16k1 then begin
  tipo:=5;
  form1.Spectrum16K1.Checked:=true;
end;
if sender=form1.CPC1 then begin
  tipo:=7;
  form1.CPC1.Checked:=true;
end;
if sender=form1.CPC6641 then begin
  tipo:=8;
  form1.CPC6641.Checked:=true;
end;
if sender=form1.CPC61281 then begin
  tipo:=9;
  form1.CPC61281.Checked:=true;
end;
//Arcade
if sender=form1.Pacman1 then begin
  tipo:=10;
  form1.pacman1.Checked:=true;
end;
if sender=form1.Phoenix1 then begin
  tipo:=11;
  form1.phoenix1.Checked:=true;
end;
if sender=form1.MisteriousStone1 then begin
  tipo:=12;
  form1.misteriousstone1.Checked:=true;
end;
if sender=form1.BombJack1 then begin
  tipo:=13;
  form1.bombjack1.Checked:=true;
end;
if sender=form1.Frogger1 then begin
  tipo:=14;
  form1.frogger1.Checked:=true;
end;
if sender=form1.Dkong1 then begin
  tipo:=15;
  form1.dkong1.Checked:=true;
end;
if sender=form1.BlackTiger1 then begin
  tipo:=16;
  form1.blacktiger1.Checked:=true;
end;
if sender=form1.Gberet1 then begin
  tipo:=17;
  form1.gberet1.Checked:=true;
end;
if sender=form1.Commando1 then begin
  tipo:=18;
  form1.commando1.Checked:=true;
end;
if sender=form1.gng1 then begin
  tipo:=19;
  form1.gng1.Checked:=true;
end;
if sender=form1.Mikie1 then begin
  tipo:=20;
  form1.mikie1.Checked:=true;
end;
if sender=form1.Shaolin1 then begin
  tipo:=21;
  form1.shaolin1.Checked:=true;
end;
if sender=form1.Yiear1 then begin
  tipo:=22;
  form1.Yiear1.Checked:=true;
end;
if sender=form1.Asteroids1 then begin
  tipo:=23;
  form1.asteroids1.Checked:=true;
end;
if sender=form1.Sonson1 then begin
  tipo:=24;
  form1.sonson1.Checked:=true;
end;
if sender=form1.starforce1 then begin
  tipo:=25;
  form1.starforce1.Checked:=true;
end;
if sender=form1.rygar1 then begin
  tipo:=26;
  form1.rygar1.Checked:=true;
end;
if sender=form1.pitfallII1 then begin
  tipo:=27;
  form1.PitfallII1.Checked:=true;
end;
if sender=form1.pooyan1 then begin
  tipo:=28;
  form1.pooyan1.Checked:=true;
end;
if sender=form1.jungler1 then begin
  tipo:=29;
  form1.jungler1.Checked:=true;
end;
if sender=form1.citycon1 then begin
  tipo:=30;
  form1.citycon1.Checked:=true;
end;
if sender=form1.burgertime1 then begin
  tipo:=31;
  form1.burgertime1.Checked:=true;
end;
if sender=form1.expressraider1 then begin
  tipo:=32;
  form1.expressraider1.Checked:=true;
end;
if sender=form1.superbasketball1 then begin
  tipo:=33;
  form1.superbasketball1.Checked:=true;
end;
if sender=form1.ladybug1 then begin
  tipo:=34;
  form1.ladybug1.Checked:=true;
end;
if sender=form1.teddy1 then begin
  tipo:=35;
  form1.teddy1.Checked:=true;
end;
if sender=form1.wboy1 then begin
  tipo:=36;
  form1.wboy1.Checked:=true;
end;
if sender=form1.wbml1 then begin
  tipo:=37;
  form1.wbml1.Checked:=true;
end;
if sender=form1.tehkanwc1 then begin
  tipo:=38;
  form1.tehkanwc1.Checked:=true;
end;
if sender=form1.popeye1 then begin
  tipo:=39;
  form1.popeye1.Checked:=true;
end;
if sender=form1.psychic51 then begin
  tipo:=40;
  form1.psychic51.Checked:=true;
end;
if sender=form1.terracre1 then begin
  tipo:=41;
  form1.terracre1.Checked:=true;
end;
if sender=form1.kungfum1 then begin
  tipo:=42;
  form1.kungfum1.Checked:=true;
end;
if sender=form1.shootout1 then begin
  tipo:=43;
  form1.shootout1.Checked:=true;
end;
if sender=form1.vigilante1 then begin
  tipo:=44;
  form1.vigilante1.Checked:=true;
end;
if sender=form1.jackal1 then begin
  tipo:=45;
  form1.jackal1.Checked:=true;
end;
if sender=form1.bubblebobble1 then begin
  tipo:=46;
  form1.bubblebobble1.Checked:=true;
end;
if sender=form1.galaxian1 then begin
  tipo:=47;
  form1.galaxian1.Checked:=true;
end;
if sender=form1.jumpb1 then begin
  tipo:=48;
  form1.jumpb1.Checked:=true;
end;
if sender=form1.mooncresta1 then begin
  tipo:=49;
  form1.mooncresta1.Checked:=true;
end;
if sender=form1.rallyx1 then begin
  tipo:=50;
  form1.rallyx1.Checked:=true;
end;
if sender=form1.prehisle1 then begin
  tipo:=51;
  form1.prehisle1.Checked:=true;
end;
if sender=form1.TigerRoad1 then begin
  tipo:=52;
  form1.tigerroad1.Checked:=true;
end;
if sender=form1.F1Dream1 then begin
  tipo:=53;
  form1.f1dream1.Checked:=true;
end;
if sender=form1.Snowbros1 then begin
  tipo:=54;
  form1.snowbros1.Checked:=true;
end;
if sender=form1.Toki1 then begin
  tipo:=55;
  form1.toki1.Checked:=true;
end;
if sender=form1.Contra1 then begin
  tipo:=56;
  form1.contra1.Checked:=true;
end;
if sender=form1.Mappy1 then begin
  tipo:=57;
  form1.mappy1.Checked:=true;
end;
if sender=form1.Rastan1 then begin
  tipo:=58;
  form1.rastan1.Checked:=true;
end;
if sender=form1.Legendw1 then begin
  tipo:=59;
  form1.legendw1.Checked:=true;
end;
if sender=form1.SectionZ1 then begin
  tipo:=60;
  form1.sectionz1.Checked:=true;
end;
if sender=form1.Trojan1 then begin
  tipo:=61;
  form1.trojan1.Checked:=true;
end;
if sender=form1.SF1 then begin
  tipo:=62;
  form1.sf1.Checked:=true;
end;
if sender=form1.digdug21 then begin
  tipo:=63;
  form1.digdug21.Checked:=true;
end;
if sender=form1.spacman1 then begin
  tipo:=64;
  form1.SPacman1.Checked:=true;
end;
if sender=form1.galaga1 then begin
  tipo:=65;
  form1.galaga1.Checked:=true;
end;
if sender=form1.xain1 then begin
  tipo:=66;
  form1.xain1.Checked:=true;
end;
if sender=form1.hardhead1 then begin
  tipo:=67;
  form1.hardhead1.Checked:=true;
end;
if sender=form1.hardhead21 then begin
  tipo:=68;
  form1.hardhead21.Checked:=true;
end;
if sender=form1.sbombers1 then begin
  tipo:=69;
  form1.sbombers1.Checked:=true;
end;
if sender=form1.NewRallyX1 then begin
  tipo:=70;
  form1.newrallyx1.Checked:=true;
end;
if sender=form1.bjtwin1 then begin
  tipo:=71;
  form1.bjtwin1.Checked:=true;
end;
if sender=form1.spelunker1 then begin
  tipo:=72;
  form1.Spelunker1.Checked:=true;
end;
if sender=form1.spelunker21 then begin
  tipo:=73;
  form1.Spelunker21.Checked:=true;
end;
if sender=form1.ldrun1 then begin
  tipo:=74;
  form1.ldrun1.Checked:=true;
end;
if sender=form1.ldrun21 then begin
  tipo:=75;
  form1.ldrun21.Checked:=true;
end;
if sender=form1.knjoe1 then begin
  tipo:=76;
  form1.knjoe1.Checked:=true;
end;
if sender=form1.wardner1 then begin
  tipo:=77;
  form1.wardner1.Checked:=true;
end;
if sender=form1.bigkarnak1 then begin
  tipo:=78;
  form1.bigkarnak1.Checked:=true;
end;
if sender=form1.exedexes1 then begin
  tipo:=79;
  form1.exedexes1.Checked:=true;
end;
if sender=form1.gunsmoke1 then begin
  tipo:=80;
  form1.gunsmoke1.Checked:=true;
end;
if sender=form1.n19421 then begin
  tipo:=81;
  form1.n19421.Checked:=true;
end;
if sender=form1.n19431 then begin
  tipo:=82;
  form1.n19431.Checked:=true;
end;
if sender=form1.n1943kai1 then begin
  tipo:=83;
  form1.n1943kai1.Checked:=true;
end;
if sender=form1.jailbreak1 then begin
  tipo:=84;
  form1.jailbreak1.Checked:=true;
end;
if sender=form1.circusc1 then begin
  tipo:=85;
  form1.circusc1.Checked:=true;
end;
if sender=form1.ironhorse1 then begin
  tipo:=86;
  form1.ironhorse1.Checked:=true;
end;
if sender=form1.rtype1 then begin
  tipo:=87;
  form1.rtype1.Checked:=true;
end;
if sender=form1.mspacman1 then begin
  tipo:=88;
  form1.mspacman1.Checked:=true;
end;
if sender=form1.brkthru1 then begin
  tipo:=89;
  form1.brkthru1.Checked:=true;
end;
if sender=form1.darwin1 then begin
  tipo:=90;
  form1.darwin1.Checked:=true;
end;
if sender=form1.srd1 then begin
  tipo:=91;
  form1.srd1.Checked:=true;
end;
if sender=form1.ddragon1 then begin
  tipo:=92;
  form1.ddragon1.Checked:=true;
end;
if sender=form1.mrdo1 then begin
  tipo:=93;
  form1.mrdo1.Checked:=true;
end;
if sender=form1.theglob1 then begin
  tipo:=94;
  form1.theglob1.Checked:=true;
end;
if sender=form1.superglob1 then begin
  tipo:=95;
  form1.superglob1.Checked:=true;
end;
if sender=form1.ddragon21 then begin
  tipo:=96;
  form1.ddragon21.Checked:=true;
end;
if sender=form1.silkworm1 then begin
  tipo:=97;
  form1.silkworm1.Checked:=true;
end;
if sender=form1.tigerh1 then begin
  tipo:=98;
  form1.tigerh1.Checked:=true;
end;
if sender=form1.SlapFight1 then begin
  tipo:=99;
  form1.slapfight1.Checked:=true;
end;
if sender=form1.LegendofKage1 then begin
  tipo:=100;
  form1.legendofkage1.Checked:=true;
end;
if sender=form1.thoop1 then begin
  tipo:=101;
  form1.thoop1.Checked:=true;
end;
if sender=form1.cabal1 then begin
  tipo:=102;
  form1.cabal1.Checked:=true;
end;
if sender=form1.ghouls1 then begin
  tipo:=103;
  form1.ghouls1.Checked:=true;
end;
if sender=form1.ffight1 then begin
  tipo:=104;
  form1.ffight1.Checked:=true;
end;
if sender=form1.kod1 then begin
  tipo:=105;
  form1.kod1.Checked:=true;
end;
if sender=form1.sf21 then begin
  tipo:=106;
  form1.sf21.Checked:=true;
end;
if sender=form1.strider1 then begin
  tipo:=107;
  form1.strider1.Checked:=true;
end;
if sender=form1.wonder31 then begin
  tipo:=108;
  form1.wonder31.Checked:=true;
end;
if sender=form1.ccommando1 then begin
  tipo:=109;
  form1.ccommando1.Checked:=true;
end;
if sender=form1.knights1 then begin
  tipo:=110;
  form1.knights1.Checked:=true;
end;
if sender=form1.sf2ce1 then begin
  tipo:=111;
  form1.sf2ce1.Checked:=true;
end;
if sender=form1.dino1 then begin
  tipo:=112;
  form1.dino1.Checked:=true;
end;
if sender=form1.punisher1 then begin
  tipo:=113;
  form1.punisher1.Checked:=true;
end;
if sender=form1.shinobi1 then begin
  tipo:=114;
  form1.shinobi1.Checked:=true;
end;
if sender=form1.alexkid1 then begin
  tipo:=115;
  form1.alexkid1.Checked:=true;
end;
if sender=form1.fantasyzone1 then begin
  tipo:=116;
  form1.fantasyzone1.Checked:=true;
end;
if sender=form1.tp841 then begin
  tipo:=117;
  form1.tp841.Checked:=true;
end;
if sender=form1.Tutankhm1 then begin
  tipo:=118;
  form1.tutankhm1.Checked:=true;
end;
if sender=form1.Pang1 then begin
  tipo:=119;
  form1.pang1.Checked:=true;
end;
if sender=form1.ninjakid21 then begin
  tipo:=120;
  form1.ninjakid21.Checked:=true;
end;
if sender=form1.arkarea1 then begin
  tipo:=121;
  form1.arkarea1.Checked:=true;
end;
if sender=form1.mnight1 then begin
  tipo:=122;
  form1.mnight1.Checked:=true;
end;
if sender=form1.skykid1 then begin
  tipo:=123;
  form1.skykid1.Checked:=true;
end;
if sender=form1.rthunder1 then begin
  tipo:=124;
  form1.rthunder1.Checked:=true;
end;
if sender=form1.hopmappy1 then begin
  tipo:=125;
  form1.hopmappy1.Checked:=true;
end;
if sender=form1.skykiddx1 then begin
  tipo:=126;
  form1.skykiddx1.Checked:=true;
end;
if sender=form1.rocnrope1 then begin
  tipo:=127;
  form1.rocnrope1.Checked:=true;
end;
if sender=form1.repulse1 then begin
  tipo:=128;
  form1.repulse1.Checked:=true;
end;
if sender=form1.tnzs1 then begin
  tipo:=129;
  form1.tnzs1.Checked:=true;
end;
if sender=form1.insectorx1 then begin
  tipo:=130;
  form1.insectorx1.Checked:=true;
end;
if sender=form1.pacland1 then begin
  tipo:=131;
  form1.pacland1.Checked:=true;
end;
if sender=form1.mariob1 then begin
  tipo:=132;
  form1.mariob1.Checked:=true;
end;
if sender=form1.solomon1 then begin
  tipo:=133;
  form1.solomon1.Checked:=true;
end;
if sender=form1.combatsc1 then begin
  tipo:=134;
  form1.combatsc1.Checked:=true;
end;
if sender=form1.hvyunit1 then begin
  tipo:=135;
  form1.hvyunit1.Checked:=true;
end;
if sender=form1.pow1 then begin
  tipo:=136;
  form1.pow1.Checked:=true;
end;
if sender=form1.streetsm1 then begin
  tipo:=137;
  form1.streetsm1.Checked:=true;
end;
if sender=form1.p471 then begin
  tipo:=138;
  form1.p471.Checked:=true;
end;
if sender=form1.rodland1 then begin
  tipo:=139;
  form1.rodland1.Checked:=true;
end;
if sender=form1.saintdragon1 then begin
  tipo:=140;
  form1.saintdragon1.Checked:=true;
end;
if sender=form1.timepilot1 then begin
  tipo:=141;
  form1.timepilot1.Checked:=true;
end;
if sender=form1.pengo1 then begin
  tipo:=142;
  form1.pengo1.Checked:=true;
end;
if sender=form1.scramble1 then begin
  tipo:=143;
  form1.scramble1.Checked:=true;
end;
if sender=form1.scobra1 then begin
  tipo:=144;
  form1.scobra1.Checked:=true;
end;
if sender=form1.amidar1 then begin
  tipo:=145;
  form1.amidar1.Checked:=true;
end;
if sender=form1.twincobr1 then begin
  tipo:=146;
  form1.twincobr1.Checked:=true;
end;
if sender=form1.FlyingShark1 then begin
  tipo:=147;
  form1.flyingshark1.Checked:=true;
end;
if sender=form1.JrPacman1 then begin
  tipo:=148;
  form1.jrpacman1.Checked:=true;
end;
if sender=form1.ikari31 then begin
  tipo:=149;
  form1.ikari31.Checked:=true;
end;
if sender=form1.searchar1 then begin
  tipo:=150;
  form1.searchar1.Checked:=true;
end;
if sender=form1.Choplifter1 then begin
  tipo:=151;
  form1.Choplifter1.Checked:=true;
end;
if sender=form1.mrviking1 then begin
  tipo:=152;
  form1.mrviking1.Checked:=true;
end;
if sender=form1.SegaNinja1 then begin
  tipo:=153;
  form1.seganinja1.Checked:=true;
end;
if sender=form1.UpnDown1 then begin
  tipo:=154;
  form1.upndown1.Checked:=true;
end;
if sender=form1.flicky1 then begin
  tipo:=155;
  form1.flicky1.Checked:=true;
end;
if sender=form1.robocop1 then begin
  tipo:=156;
  form1.robocop1.Checked:=true;
end;
if sender=form1.baddudes1 then begin
  tipo:=157;
  form1.baddudes1.Checked:=true;
end;
if sender=form1.hippo1 then begin
  tipo:=158;
  form1.hippo1.Checked:=true;
end;
if sender=form1.TumbleP1 then begin
  tipo:=159;
  form1.tumblep1.Checked:=true;
end;
if sender=form1.funkyjet1 then begin
  tipo:=160;
  form1.funkyjet1.Checked:=true;
end;
if sender=form1.SuperBurgerTime1 then begin
  tipo:=161;
  form1.superburgertime1.Checked:=true;
end;
if sender=form1.cninja1 then begin
  tipo:=162;
  form1.cninja1.Checked:=true;
end;
if sender=form1.robocop21 then begin
  tipo:=163;
  form1.robocop21.Checked:=true;
end;
if sender=form1.dietgo1 then begin
  tipo:=164;
  form1.dietgo1.Checked:=true;
end;
if sender=form1.actfancer1 then begin
  tipo:=165;
  form1.ActFancer1.Checked:=true;
end;
if sender=form1.arabian1 then begin
  tipo:=166;
  form1.arabian1.Checked:=true;
end;
if sender=form1.digdug1 then begin
  tipo:=167;
  form1.digdug1.Checked:=true;
end;
if sender=form1.dkongjr1 then begin
  tipo:=168;
  form1.dkongjr1.Checked:=true;
end;
if sender=form1.dkong31 then begin
  tipo:=169;
  form1.dkong31.Checked:=true;
end;
if sender=form1.higemaru1 then begin
  tipo:=170;
  form1.higemaru1.Checked:=true;
end;
if sender=form1.bagman1 then begin
  tipo:=171;
  form1.bagman1.Checked:=true;
end;
if sender=form1.sbagman1 then begin
  tipo:=172;
  form1.sbagman1.Checked:=true;
end;
if sender=form1.squash1 then begin
  tipo:=173;
  form1.squash1.Checked:=true;
end;
if sender=form1.biomtoy1 then begin
  tipo:=174;
  form1.biomtoy1.Checked:=true;
end;
if sender=form1.congo1 then begin
  tipo:=175;
  form1.congo1.Checked:=true;
end;
if sender=form1.kangaroo1 then begin
  tipo:=176;
  form1.kangaroo1.Checked:=true;
end;
if sender=form1.bionicc1 then begin
  tipo:=177;
  form1.bionicc1.Checked:=true;
end;
if sender=form1.wwfsuperstar1 then begin
  tipo:=178;
  form1.wwfsuperstar1.Checked:=true;
end;
if sender=form1.rbisland1 then begin
  tipo:=179;
  form1.rbisland1.Checked:=true;
end;
if sender=form1.rbislande1 then begin
  tipo:=180;
  form1.rbislande1.Checked:=true;
end;
if sender=form1.volfied1 then begin
  tipo:=181;
  form1.volfied1.Checked:=true;
end;
if sender=form1.opwolf1 then begin
  tipo:=182;
  form1.opwolf1.Checked:=true;
end;
if sender=form1.sPang1 then begin
  tipo:=183;
  form1.spang1.Checked:=true;
end;
if sender=form1.outrun1 then begin
  tipo:=184;
  form1.outrun1.Checked:=true;
end;
if sender=form1.elevator1 then begin
  tipo:=185;
  form1.elevator1.Checked:=true;
end;
if sender=form1.aliensyn1 then begin
  tipo:=186;
  form1.aliensyn1.Checked:=true;
end;
if sender=form1.wb31 then begin
  tipo:=187;
  form1.wb31.Checked:=true;
end;
if sender=form1.zaxxon1 then begin
  tipo:=188;
  form1.zaxxon1.Checked:=true;
end;
if sender=form1.jungleking1 then begin
  tipo:=189;
  form1.jungleking1.Checked:=true;
end;
if sender=form1.hharry1 then begin
  tipo:=190;
  form1.hharry1.Checked:=true;
end;
if sender=form1.rtype21 then begin
  tipo:=191;
  form1.rtype21.Checked:=true;
end;
if sender=form1.todruaga1 then begin
  tipo:=192;
  form1.todruaga1.Checked:=true;
end;
if sender=form1.motos1 then begin
  tipo:=193;
  form1.motos1.Checked:=true;
end;
if sender=form1.drgnbstr1 then begin
  tipo:=194;
  form1.drgnbstr1.Checked:=true;
end;
if sender=form1.vulgus1 then begin
  tipo:=195;
  form1.vulgus1.Checked:=true;
end;
if sender=form1.ddragon31 then begin
  tipo:=196;
  form1.ddragon31.Checked:=true;
end;
if sender=form1.blockout1 then begin
  tipo:=197;
  form1.blockout1.Checked:=true;
end;
if sender=form1.tetris1 then begin
  tipo:=198;
  form1.tetris1.Checked:=true;
end;
if sender=form1.foodf1 then begin
  tipo:=199;
  form1.foodf1.Checked:=true;
end;
if sender=form1.snapjack1 then begin
  tipo:=200;
  form1.snapjack1.Checked:=true;
end;
if sender=form1.cavenger1 then begin
  tipo:=201;
  form1.cavenger1.Checked:=true;
end;
if sender=form1.pleiads1 then begin
  tipo:=202;
  form1.pleiads1.Checked:=true;
end;
if sender=form1.mrgoemon1 then begin
  tipo:=203;
  form1.mrgoemon1.Checked:=true;
end;
if sender=form1.nemesis1 then begin
  tipo:=204;
  form1.nemesis1.Checked:=true;
end;
if sender=form1.twinbee1 then begin
  tipo:=205;
  form1.twinbee1.Checked:=true;
end;
if sender=form1.pirates1 then begin
  tipo:=206;
  form1.pirates1.Checked:=true;
end;
if sender=form1.genixfamily1 then begin
  tipo:=207;
  form1.genixfamily1.Checked:=true;
end;
if sender=form1.junofirst1 then begin
  tipo:=208;
  form1.junofirst1.Checked:=true;
end;
//consolas
if sender=form1.NES1 then begin
  tipo:=1000;
  form1.NES1.Checked:=true;
end;
if sender=form1.colecovision1 then begin
  tipo:=1001;
  form1.colecovision1.Checked:=true;
end;
if sender=form1.gameboy1 then begin
  tipo:=1002;
  form1.GameBoy1.Checked:=true;
end;
if sender=form1.chip81 then begin
  tipo:=1003;
  form1.CHIP81.Checked:=true;
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
