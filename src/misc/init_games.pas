unit init_games;

interface
uses sysutils,main_engine,rom_engine,rom_export,
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
  boogiewings_hw,pinballaction_hw,renegade_hw,tmnt_hw,gradius3_hw,
  spaceinvaders_hw,centipede_hw,karnov_hw,aliens_hw,thunderx_hw,simpsons_hw,
  trackandfield_hw,hypersports_hw,megazone_hw,spacefirebird_hw,ajax_hw,
  vendetta_hw,gauntlet_hw,sauro_hw,crazyclimber_hw,returnofinvaders_hw,gnw_510,
  tetris_atari_hw,snk_hw;

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
            end;
const
  sound_tipo:array[0..4] of string=('NO','YES','SAMPLES','YES+SAMPLES','PARTIAL');
  games_cont=252;
  games_desc:array[1..games_cont] of tgame_desc=(
  //Computers
  (name:'Spectrum 48K';year:'1982';snd:1;hi:false;zip:'spectrum';grid:0;company:'Sinclair';rom:@spectrum),
  (name:'Spectrum 128K';year:'1986';snd:1;hi:false;zip:'spec128';grid:1;company:'Sinclair';rom:@spec128),
  (name:'Spectrum +3';year:'1987';snd:1;hi:false;zip:'plus3';grid:2;company:'Amstrad';rom:@plus3),
  (name:'Spectrum +2A';year:'1987';snd:1;hi:false;zip:'plus3';grid:3;company:'Amstrad';rom:@plus3),
  (name:'Spectrum +2';year:'1986';snd:1;hi:false;zip:'plus2';grid:4;company:'Amstrad';rom:@spec_plus2),
  (name:'Spectrum 16K';year:'1982';snd:1;hi:false;zip:'spectrum';grid:5;company:'Sinclair';rom:@spectrum),
  (name:'Amstrad CPC 464';year:'1984';snd:1;hi:false;zip:'cpc464';grid:7;company:'Amstrad';rom:@cpc464),
  (name:'Amstrad CPC 664';year:'1984';snd:1;hi:false;zip:'cpc664';grid:8;company:'Amstrad';rom:@cpc664),
  (name:'Amstrad CPC 6128';year:'1985';snd:1;hi:false;zip:'cpc6128';grid:9;company:'Amstrad';rom:@cpc6128),
  //Arcade
  (name:'Pacman';year:'1980';snd:1;hi:false;zip:'pacman';grid:10;company:'Namco';rom:@pacman),
  (name:'Phoenix';year:'1980';snd:1;hi:false;zip:'phoenix';grid:11;company:'Amstar Electronics';rom:@phoenix),
  (name:'Mysterious Stones';year:'1984';snd:1;hi:false;zip:'mystston';grid:12;company:'Technos';rom:@mystston),
  (name:'Bomb Jack';year:'1984';snd:1;hi:false;zip:'bombjack';grid:13;company:'Tehkan';rom:@bombjack),
  (name:'Frogger';year:'1981';snd:1;hi:true;zip:'frogger';grid:14;company:'Konami';rom:@frogger),
  (name:'Donkey Kong';year:'1981';snd:2;hi:false;zip:'dkong';grid:15;company:'Nintendo';rom:@dkong;samples:@dkong_samples),
  (name:'Black Tiger';year:'1986';snd:1;hi:true;zip:'blktiger';grid:16;company:'Capcom';rom:@blktiger),
  (name:'Green Beret';year:'1985';snd:1;hi:true;zip:'gberet';grid:17;company:'Konami';rom:@gberet),
  (name:'Commando';year:'1985';snd:1;hi:false;zip:'commando';grid:18;company:'Capcom';rom:@commando),
  (name:'Ghosts''n Goblins';year:'1985';snd:1;hi:false;zip:'gng';grid:19;company:'Capcom';rom:@gng),
  (name:'Mikie';year:'1985';snd:1;hi:false;zip:'mikie';grid:20;company:'Konami';rom:@mikie),
  (name:'Shaolin''s Road';year:'1985';snd:1;hi:false;zip:'shaolins';grid:21;company:'Konami';rom:@shaolins),
  (name:'Yie Ar Kung-Fu';year:'1985';snd:1;hi:false;zip:'yiear';grid:22;company:'Konami';rom:@yiear),
  (name:'Asteroids';year:'1979';snd:3;hi:false;zip:'asteroid';grid:23;company:'Atari';rom:@asteroid;samples:@asteroid_samples),
  (name:'Son Son';year:'1984';snd:1;hi:false;zip:'sonson';grid:24;company:'Capcom';rom:@sonson),
  (name:'Star Force';year:'1984';snd:1;hi:false;zip:'starforc';grid:25;company:'Tehkan';rom:@starforc),
  (name:'Rygar';year:'1986';snd:1;hi:false;zip:'rygar';grid:26;company:'Tecmo';rom:@rygar),
  (name:'Pitfall II';year:'1984';snd:1;hi:false;zip:'pitfall2';grid:27;company:'Sega';rom:@pitfall2),
  (name:'Pooyan';year:'1982';snd:1;hi:false;zip:'pooyan';grid:28;company:'Konami';rom:@pooyan),
  (name:'Jungler';year:'1981';snd:1;hi:false;zip:'jungler';grid:29;company:'Konami';rom:@jungler),
  (name:'City Connection';year:'1986';snd:1;hi:false;zip:'citycon';grid:30;company:'Jaleco';rom:@citycon),
  (name:'Burger Time';year:'1982';snd:1;hi:false;zip:'btime';grid:31;company:'Deco';rom:@btime),
  (name:'Express Raider';year:'1986';snd:1;hi:false;zip:'exprraid';grid:32;company:'Deco';rom:@exprraid),
  (name:'Super Basketball';year:'1984';snd:1;hi:false;zip:'sbasketb';grid:33;company:'Konami';rom:@sbasketb),
  (name:'Lady Bug';year:'1981';snd:1;hi:false;zip:'ladybug';grid:34;company:'Universal';rom:@ladybug),
  (name:'Teddy Boy Blues';year:'1985';snd:1;hi:false;zip:'teddybb';grid:35;company:'Sega';rom:@teddybb),
  (name:'Wonder Boy';year:'1986';snd:1;hi:false;zip:'wboy';grid:36;company:'Sega';rom:@wboy),
  (name:'Wonder Boy in Monster Land';year:'1987';snd:1;hi:false;zip:'wbml';grid:37;company:'Sega';rom:@wbml),
  (name:'Tehkan World Cup';year:'1985';snd:1;hi:false;zip:'tehkanwc';grid:38;company:'Tehkan';rom:@tehkanwc),
  (name:'Popeye';year:'1982';snd:1;hi:false;zip:'popeye';grid:39;company:'Nintendo';rom:@popeye),
  (name:'Psychic 5';year:'1987';snd:1;hi:false;zip:'psychic5';grid:40;company:'Jaleco';rom:@psychic5),
  (name:'Terra Cresta';year:'198X';snd:1;hi:false;zip:'terracre';grid:41;company:'Nichibutsu';rom:@terracre),
  (name:'Kung-Fu Master';year:'1987';snd:1;hi:false;zip:'kungfum';grid:42;company:'Irem';rom:@kungfum),
  (name:'Shoot Out';year:'1985';snd:1;hi:false;zip:'shootout';grid:43;company:'Data East';rom:@shootout),
  (name:'Vigilante';year:'1988';snd:1;hi:false;zip:'vigilant';grid:44;company:'Irem';rom:@vigilant),
  (name:'Jackal';year:'1986';snd:1;hi:false;zip:'jackal';grid:45;company:'Konami';rom:@jackal),
  (name:'Bubble Bobble';year:'1986';snd:1;hi:false;zip:'bublbobl';grid:46;company:'Taito';rom:@bublbobl),
  (name:'Galaxian';year:'1980';snd:2;hi:false;zip:'galaxian';grid:47;company:'Namco';rom:@galaxian;samples:@galaxian_samples),
  (name:'Jump Bug';year:'1981';snd:1;hi:false;zip:'jumpbug';grid:48;company:'Rock-Ola';rom:@jumpbug),
  (name:'Moon Cresta';year:'1980';snd:0;hi:false;zip:'mooncrst';grid:49;company:'Nichibutsu';rom:@mooncrst;samples:@mooncrst_samples),
  (name:'Rally X';year:'1980';snd:3;hi:false;zip:'rallyx';grid:50;company:'Namco';rom:@rallyx;samples:@rallyx_samples),
  (name:'Prehistoric Isle in 1930';year:'1989';snd:1;hi:false;zip:'prehisle';grid:51;company:'SNK';rom:@prehisle),
  (name:'Tiger Road';year:'1987';snd:1;hi:false;zip:'tigeroad';grid:52;company:'Capcom';rom:@tigeroad),
  (name:'F1 Dream';year:'1988';snd:1;hi:false;zip:'f1dream';grid:53;company:'Capcom';rom:@f1dream),
  (name:'Snowbros';year:'1980';snd:1;hi:false;zip:'snowbros';grid:54;company:'Toaplan';rom:@snowbros),
  (name:'Toki';year:'1989';snd:1;hi:false;zip:'toki';grid:55;company:'TAD';rom:@toki),
  (name:'Contra';year:'1987';snd:1;hi:false;zip:'contra';grid:56;company:'Konami';rom:@contra),
  (name:'Mappy';year:'1983';snd:1;hi:false;zip:'mappy';grid:57;company:'Namco';rom:@mappy),
  (name:'Rastan';year:'1987';snd:1;hi:false;zip:'rastan';grid:58;company:'Taito';rom:@rastan),
  (name:'Legendary Wings';year:'1986';snd:1;hi:false;zip:'lwings';grid:59;company:'Capcom';rom:@lwings),
  (name:'Section Z';year:'1985';snd:1;hi:false;zip:'sectionz';grid:60;company:'Capcom';rom:@sectionz),
  (name:'Trojan';year:'1986';snd:1;hi:false;zip:'trojan';grid:61;company:'Capcom';rom:@trojan),
  (name:'Street Fighter';year:'1987';snd:1;hi:false;zip:'sf';grid:62;company:'Capcom';rom:@sfighter),
  (name:'DigDug II';year:'1985';snd:1;hi:false;zip:'digdug2';grid:63;company:'Namco';rom:@digdug2),
  (name:'Super Pacman';year:'1985';snd:1;hi:false;zip:'superpac';grid:64;company:'Namco';rom:@spacman),
  (name:'Galaga';year:'1981';snd:1;hi:false;zip:'galaga';grid:65;company:'Namco';rom:@galaga;samples:@galaga_samples),
  (name:'Xain''d Sleena';year:'1986';snd:1;hi:false;zip:'xsleena';grid:66;company:'Technos';rom:@xsleena),
  (name:'Hard Head';year:'1988';snd:1;hi:false;zip:'hardhead';grid:67;company:'Suna';rom:@hardhead),
  (name:'Hard Head 2';year:'1989';snd:0;hi:false;zip:'hardhea2';grid:68;company:'Suna';rom:@hardhea2),
  (name:'Saboten Bombers';year:'1992';snd:1;hi:false;zip:'sabotenb';grid:69;company:'NMK';rom:@sabotenb),
  (name:'New Rally X';year:'1981';snd:3;hi:false;zip:'nrallyx';grid:70;company:'Namco';rom:@nrallyx),
  (name:'Bomb Jack Twin';year:'1993';snd:1;hi:false;zip:'bjtwin';grid:71;company:'NMK';rom:@bjtwin),
  (name:'Spelunker';year:'1985';snd:1;hi:false;zip:'spelunkr';grid:72;company:'Broderbound';rom:@spelunkr),
  (name:'Spelunker II';year:'1986';snd:1;hi:false;zip:'spelunk2';grid:73;company:'Broderbound';rom:@spelunk2),
  (name:'Lode Runner';year:'1984';snd:1;hi:false;zip:'ldrun';grid:74;company:'Irem';rom:@ldrun),
  (name:'Lode Runner II';year:'1984';snd:1;hi:false;zip:'ldrun2';grid:75;company:'Irem';rom:@ldrun2),
  (name:'Knuckle Joe';year:'1985';snd:1;hi:false;zip:'kncljoe';grid:76;company:'Taito';rom:@kncljoe),
  (name:'Wardner';year:'1987';snd:1;hi:false;zip:'wardner';grid:77;company:'Taito';rom:@wardner),
  (name:'Big Karnak';year:'1991';snd:1;hi:false;zip:'bigkarnk';grid:78;company:'Gaelco';rom:@bigkarnk),
  (name:'Exed-Exes';year:'1985';snd:1;hi:false;zip:'exedexes';grid:79;company:'Capcom';rom:@exedexes),
  (name:'Gun.Smoke';year:'1985';snd:1;hi:false;zip:'gunsmoke';grid:80;company:'Capcom';rom:@gunsmoke),
  (name:'1942';year:'1984';snd:1;hi:false;zip:'1942';grid:81;company:'Capcom';rom:@hw1942),
  (name:'1943';year:'1987';snd:1;hi:false;zip:'1943';grid:82;company:'Capcom';rom:@hw1943),
  (name:'1943 Kai';year:'1987';snd:1;hi:false;zip:'1943kai';grid:83;company:'Capcom';rom:@hw1943kai),
  (name:'Jail Break';year:'1986';snd:1;hi:false;zip:'jailbrek';grid:84;company:'Konami';rom:@jailbrek),
  (name:'Circus Chalie';year:'1984';snd:1;hi:false;zip:'circusc';grid:85;company:'Konami';rom:@circusc),
  (name:'Iron Horse';year:'1986';snd:1;hi:false;zip:'ironhors';grid:86;company:'Konami';rom:@ironhors),
  (name:'R-Type';year:'1987';snd:0;hi:false;zip:'rtype';grid:87;company:'Irem';rom:@rtype),
  (name:'MS. Pac-man';year:'1981';snd:1;hi:false;zip:'mspacman';grid:88;company:'Namco';rom:@mspacman),
  (name:'Break Thru';year:'1986';snd:1;hi:false;zip:'brkthru';grid:89;company:'Data East';rom:@brkthru),
  (name:'Darwin 4078';year:'1986';snd:1;hi:false;zip:'darwin';grid:90;company:'Data East';rom:@darwin),
  (name:'Super Real Darwin';year:'1987';snd:1;hi:false;zip:'srdarwin';grid:91;company:'Data East';rom:@srdarwin),
  (name:'Double Dragon';year:'1987';snd:1;hi:false;zip:'ddragon';grid:92;company:'Taito';rom:@ddragon),
  (name:'Mr. Do!';year:'1982';snd:1;hi:false;zip:'mrdo';grid:93;company:'Universal';rom:@mrdo),
  (name:'The Glob';year:'1983';snd:1;hi:false;zip:'theglob';grid:94;company:'Epos';rom:@theglob),
  (name:'Super Glob';year:'1983';snd:1;hi:false;zip:'suprglob';grid:95;company:'Epos';rom:@suprglob),
  (name:'Double Dragon II - The Revenge';year:'1988';snd:1;hi:false;zip:'ddragon2';grid:96;company:'Technos';rom:@ddragon2),
  (name:'Silk Worm';year:'1988';snd:1;hi:false;zip:'silkworm';grid:97;company:'Tecmo';rom:@silkworm),
  (name:'Tiger Heli';year:'1985';snd:1;hi:false;zip:'tigerh';grid:98;company:'Taito';rom:@tigerh),
  (name:'Slap Fight';year:'1986';snd:1;hi:false;zip:'slapfigh';grid:99;company:'Taito';rom:@slapfigh),
  (name:'The Legend of Kage';year:'1984';snd:1;hi:false;zip:'lkage';grid:100;company:'Taito';rom:@lkage),
  (name:'Thunder Hoop';year:'1992';snd:1;hi:false;zip:'thoop';grid:101;company:'Gaelco';rom:@thoop),
  (name:'Cabal';year:'1988';snd:1;hi:false;zip:'cabal';grid:102;company:'TAD';rom:@cabal),
  (name:'Ghouls''n Ghosts';year:'1988';snd:1;hi:false;zip:'ghouls';grid:103;company:'Capcom';rom:@ghouls),
  (name:'Final Fight';year:'1989';snd:1;hi:false;zip:'ffight';grid:104;company:'Capcom';rom:@ffight),
  (name:'The King of Dragons';year:'1991';snd:1;hi:false;zip:'kod';grid:105;company:'Capcom';rom:@kod),
  (name:'Street Fighter II - The World Warrior';year:'1991';snd:1;hi:false;zip:'sf2';grid:106;company:'Capcom';rom:@sf2),
  (name:'Strider';year:'1989';snd:1;hi:false;zip:'strider';grid:107;company:'Capcom';rom:@strider),
  (name:'Three Wonders';year:'1991';snd:1;hi:false;zip:'3wonders';grid:108;company:'Capcom';rom:@wonder3),
  (name:'Captain Commando';year:'1991';snd:1;hi:false;zip:'captcomm';grid:109;company:'Capcom';rom:@captcomm),
  (name:'Knights of the Round';year:'1991';snd:1;hi:false;zip:'knights';grid:110;company:'Capcom';rom:@knights),
  (name:'Street Fighter II'': Champion Edition';year:'1992';snd:1;hi:false;zip:'sf2ce';grid:111;company:'Capcom';rom:@sf2ce),
  (name:'Cadillacs and Dinosaurs';year:'1992';snd:1;hi:false;zip:'dino';grid:112;company:'Capcom';rom:@dino),
  (name:'The Punisher';year:'1993';snd:1;hi:false;zip:'punisher';grid:113;company:'Capcom';rom:@punisher),
  (name:'Shinobi';year:'1987';snd:4;hi:false;zip:'shinobi';grid:114;company:'Sega';rom:@shinobi),
  (name:'Alex Kidd';year:'1986';snd:4;hi:false;zip:'alexkidd';grid:115;company:'Sega';rom:@alexkidd),
  (name:'Fantasy Zone';year:'1986';snd:4;hi:false;zip:'fantzone';grid:116;company:'Sega';rom:@fantzone),
  (name:'Time Pilot ''84';year:'1984';snd:1;hi:false;zip:'tp84';grid:117;company:'Konami';rom:@tp84),
  (name:'Tutankham';year:'1982';snd:1;hi:false;zip:'tutankhm';grid:118;company:'Konami';rom:@tutankhm),
  (name:'Pang';year:'1989';snd:4;hi:false;zip:'pang';grid:119;company:'Capcom';rom:@pang),
  (name:'Ninja Kid II';year:'1987';snd:4;hi:false;zip:'ninjakd2';grid:120;company:'UPL';rom:@ninjakd2),
  (name:'Ark Area';year:'1988';snd:1;hi:false;zip:'arkarea';grid:121;company:'UPL';rom:@arkarea),
  (name:'Mutant Night';year:'1987';snd:1;hi:false;zip:'mnight';grid:122;company:'UPL';rom:@mnight),
  (name:'Sky Kid';year:'1985';snd:1;hi:false;zip:'skykid';grid:123;company:'Namco';rom:@skykid),
  (name:'Rolling Thunder';year:'1986';snd:4;hi:false;zip:'rthunder';grid:124;company:'Namco';rom:@rthunder),
  (name:'Hopping Mappy';year:'1986';snd:4;hi:false;zip:'hopmappy';grid:125;company:'Namco';rom:@hopmappy),
  (name:'Sky Kid Deluxe';year:'1986';snd:4;hi:false;zip:'skykiddx';grid:126;company:'Namco';rom:@skykiddx),
  (name:'Roc''n Rope';year:'1983';snd:1;hi:false;zip:'rocnrope';grid:127;company:'Konami';rom:@rocnrope),
  (name:'Repulse';year:'1985';snd:1;hi:false;zip:'repulse';grid:128;company:'Sega';rom:@repulse),
  (name:'The NewZealand Story';year:'1988';snd:1;hi:false;zip:'tnzs';grid:129;company:'Taito';rom:@tnzs),
  (name:'Insector X';year:'1989';snd:1;hi:false;zip:'insectx';grid:130;company:'Taito';rom:@insectx),
  (name:'Pacland';year:'1984';snd:4;hi:false;zip:'pacland';grid:131;company:'Namco';rom:@pacland),
  (name:'Mario Bros.';year:'1983';snd:2;hi:false;zip:'mario';grid:132;company:'Nintendo';rom:@mario;samples:@mario_samples),
  (name:'Solomon''s Key';year:'1986';snd:1;hi:false;zip:'solomon';grid:133;company:'Tecmo';rom:@solomon),
  (name:'Combat School';year:'1988';snd:1;hi:false;zip:'combatsc';grid:134;company:'Konami';rom:@combatsc),
  (name:'Heavy Unit';year:'1988';snd:1;hi:false;zip:'hvyunit';grid:135;company:'Taito';rom:@hvyunit),
  (name:'P.O.W. - Prisoners of War';year:'1988';snd:1;hi:false;zip:'pow';grid:136;company:'SNK';rom:@pow),
  (name:'Street Smart';year:'1988';snd:1;hi:false;zip:'streetsm';grid:137;company:'SNK';rom:@streetsm),
  (name:'P47 - Phantom Fighter';year:'1989';snd:1;hi:false;zip:'p47';grid:138;company:'Jaleco';rom:@p47),
  (name:'Rod-Land';year:'1990';snd:1;hi:false;zip:'rodland';grid:139;company:'Jaleco';rom:@rodland),
  (name:'Saint Dragon';year:'1989';snd:1;hi:false;zip:'stdragon';grid:140;company:'Jaleco';rom:@stdragon),
  (name:'Time Pilot';year:'1982';snd:1;hi:false;zip:'timeplt';grid:141;company:'Konami';rom:@timeplt),
  (name:'Pengo';year:'1982';snd:1;hi:false;zip:'pengo';grid:142;company:'Sega';rom:@pengo),
  (name:'Scramble';year:'1981';snd:1;hi:false;zip:'scramble';grid:143;company:'Konami';rom:@scramble),
  (name:'Super Cobra';year:'1981';snd:1;hi:false;zip:'scobra';grid:144;company:'Konami';rom:@scobra),
  (name:'Amidar';year:'1981';snd:1;hi:false;zip:'amidar';grid:145;company:'Konami';rom:@amidar),
  (name:'Twin Cobra';year:'1987';snd:1;hi:false;zip:'twincobr';grid:146;company:'Taito';rom:@twincobr),
  (name:'Flying Shark';year:'1987';snd:1;hi:false;zip:'fshark';grid:147;company:'Taito';rom:@fshark),
  (name:'Jr. Pac-Man';year:'1983';snd:1;hi:false;zip:'jrpacman';grid:148;company:'Bally Midway';rom:@jrpacman),
  (name:'Ikari III - The Rescue';year:'1989';snd:1;hi:false;zip:'ikari3';grid:149;company:'SNK';rom:@ikari3),
  (name:'Search and Rescue';year:'1989';snd:1;hi:false;zip:'searchar';grid:150;company:'SNK';rom:@searchar),
  (name:'Choplifter';year:'1985';snd:1;hi:false;zip:'choplift';grid:151;company:'Sega';rom:@choplift),
  (name:'Mister Viking';year:'1983';snd:1;hi:false;zip:'mrviking';grid:152;company:'Sega';rom:@mrviking),
  (name:'Sega Ninja';year:'1985';snd:1;hi:false;zip:'seganinj';grid:153;company:'Sega';rom:@seganinj),
  (name:'Up''n Down';year:'1983';snd:1;hi:false;zip:'upndown';grid:154;company:'Sega';rom:@upndown),
  (name:'Flicky';year:'1984';snd:1;hi:false;zip:'flicky';grid:155;company:'Sega';rom:@flicky),
  (name:'Robocop';year:'1988';snd:1;hi:false;zip:'robocop';grid:156;company:'Data East';rom:@robocop),
  (name:'Baddudes vs. DragonNinja';year:'1988';snd:1;hi:false;zip:'baddudes';grid:157;company:'Data East';rom:@baddudes),
  (name:'Hippodrome';year:'1989';snd:1;hi:false;zip:'hippodrm';grid:158;company:'Data East';rom:@hippodrm),
  (name:'Tumble Pop';year:'1991';snd:1;hi:false;zip:'tumblep';grid:159;company:'Data East';rom:@tumblep),
  (name:'Funky Jet';year:'1992';snd:1;hi:false;zip:'funkyjet';grid:160;company:'Mitchell';rom:@funkyjet),
  (name:'Super Burger Time';year:'1990';snd:1;hi:false;zip:'supbtime';grid:161;company:'Data East';rom:@supbtime),
  (name:'Caveman Ninja';year:'1991';snd:1;hi:false;zip:'cninja';grid:162;company:'Data East';rom:@cninja),
  (name:'Robocop 2';year:'1991';snd:1;hi:false;zip:'robocop2';grid:163;company:'Data East';rom:@robocop2),
  (name:'Diet Go Go';year:'1992';snd:1;hi:false;zip:'dietgo';grid:164;company:'Data East';rom:@dietgo),
  (name:'Act-Fancer Cybernetick Hyper Weapon';year:'1989';snd:1;hi:false;zip:'actfancr';grid:165;company:'Data East';rom:@actfancer),
  (name:'Arabian';year:'1983';snd:1;hi:false;zip:'arabian';grid:166;company:'Sun Electronics';rom:@arabian),
  (name:'Dig Dug';year:'1982';snd:1;hi:false;zip:'digdug';grid:167;company:'Namco';rom:@digdug),
  (name:'Donkey Kong Jr.';year:'1982';snd:2;hi:false;zip:'dkongjr';grid:168;company:'Nintendo';rom:@dkongjr;samples:@dkjr_samples),
  (name:'Donkey Kong 3';year:'1983';snd:1;hi:false;zip:'dkong3';grid:169;company:'Nintendo';rom:@dkong3),
  (name:'Pirate Ship Higemaru';year:'1984';snd:1;hi:false;zip:'higemaru';grid:170;company:'Capcom';rom:@higemaru),
  (name:'Bagman';year:'1982';snd:4;hi:false;zip:'bagman';grid:171;company:'Valadon Automation';rom:@bagman),
  (name:'Super Bagman';year:'1984';snd:4;hi:false;zip:'sbagman';grid:172;company:'Valadon Automation';rom:@sbagman),
  (name:'Squash';year:'1992';snd:1;hi:false;zip:'squash';grid:173;company:'Gaelco';rom:@squash),
  (name:'Biomechanical Toy';year:'1995';snd:1;hi:false;zip:'biomtoy';grid:174;company:'Gaelco';rom:@biomtoy),
  (name:'Congo Bongo';year:'1983';snd:3;hi:false;zip:'congo';grid:175;company:'Sega';rom:@congo;samples:@congo_samples),
  (name:'Kangaroo';year:'1982';snd:1;hi:false;zip:'kangaroo';grid:176;company:'Sun Electronics';rom:@kangaroo),
  (name:'Bionic Commando';year:'1987';snd:1;hi:false;zip:'bionicc';grid:177;company:'Capcom';rom:@bionicc),
  (name:'WWF Superstar';year:'1989';snd:1;hi:false;zip:'wwfsstar';grid:178;company:'Technos Japan';rom:@wwfsstar),
  (name:'Rainbow Islands';year:'1987';snd:1;hi:false;zip:'rbisland';grid:179;company:'Taito';rom:@rbisland),
  (name:'Rainbow Islands Extra';year:'1987';snd:1;hi:false;zip:'rbislande';grid:180;company:'Taito';rom:@rbislande),
  (name:'Volfied';year:'1989';snd:1;hi:false;zip:'volfied';grid:181;company:'Taito';rom:@volfied),
  (name:'Operation Wolf';year:'1987';snd:1;hi:false;zip:'opwolf';grid:182;company:'Taito';rom:@opwolf),
  (name:'Super Pang';year:'1990';snd:4;hi:false;zip:'spang';grid:183;company:'Capcom';rom:@spang),
  (name:'Outrun';year:'1989';snd:0;hi:false;zip:'outrun';grid:184;company:'Sega';rom:@outrun),
  (name:'Elevator Action';year:'1989';snd:1;hi:false;zip:'elevator';grid:185;company:'Taito';rom:@elevator),
  (name:'Alien Syndrome';year:'1988';snd:1;hi:false;zip:'aliensyn';grid:186;company:'Sega';rom:@aliensyn),
  (name:'Wonder Boy III - Monster Lair';year:'1987';snd:1;hi:false;zip:'wb3';grid:187;company:'Sega';rom:@wb3),
  (name:'Zaxxon';year:'1982';snd:2;hi:false;zip:'zaxxon';grid:188;company:'Sega';rom:@zaxxon;samples:@zaxxon_samples),
  (name:'Jungle King';year:'1982';snd:1;hi:false;zip:'junglek';grid:189;company:'Taito';rom:@junglek),
  (name:'Hammerin'' Harry';year:'1990';snd:1;hi:false;zip:'hharry';grid:190;company:'Irem';rom:@hharry),
  (name:'R-Type 2';year:'1989';snd:1;hi:false;zip:'rtype2';grid:191;company:'Irem';rom:@rtype2),
  (name:'The Tower of Druaga';year:'1984';snd:1;hi:false;zip:'todruaga';grid:192;company:'Namco';rom:@todruaga),
  (name:'Motos';year:'1985';snd:1;hi:false;zip:'motos';grid:193;company:'Namco';rom:@motos),
  (name:'Dragon Buster';year:'1984';snd:1;hi:false;zip:'drgnbstr';grid:194;company:'Namco';rom:@drgnbstr),
  (name:'Vulgus';year:'1984';snd:1;hi:false;zip:'vulgus';grid:195;company:'Capcom';rom:@vulgus),
  (name:'Double Dragon 3 - The Rosetta Stone';year:'1990';snd:1;hi:false;zip:'ddragon3';grid:196;company:'Technos';rom:@ddragon3),
  (name:'Block Out';year:'1990';snd:1;hi:false;zip:'blockout';grid:197;company:'Technos';rom:@blockout),
  (name:'Tetris';year:'1988';snd:1;hi:false;zip:'tetris';grid:198;company:'Sega';rom:@tetris),
  (name:'Food Fight';year:'1982';snd:1;hi:false;zip:'foodf';grid:199;company:'Atari';rom:@foodf),
  (name:'Snap Jack';year:'1982';snd:1;hi:false;zip:'snapjack';grid:200;company:'Universal';rom:@snapjack),
  (name:'Cosmic Avenger';year:'1981';snd:1;hi:false;zip:'cavenger';grid:201;company:'Universal';rom:@cavenger),
  (name:'Pleiads';year:'1981';snd:0;hi:false;zip:'pleiads';grid:202;company:'Tehkan';rom:@pleiads),
  (name:'Mr. Goemon';year:'1986';snd:1;hi:false;zip:'mrgoemon';grid:203;company:'Konami';rom:@mrgoemon),
  (name:'Nemesis';year:'1985';snd:1;hi:false;zip:'nemesis';grid:204;company:'Konami';rom:@nemesis),
  (name:'Twinbee';year:'1985';snd:1;hi:false;zip:'twinbee';grid:205;company:'Konami';rom:@twinbee),
  (name:'Pirates';year:'1994';snd:1;hi:false;zip:'pirates';grid:206;company:'NIX';rom:@pirates),
  (name:'Genix Family';year:'1994';snd:1;hi:false;zip:'genix';grid:207;company:'NIX';rom:@genix),
  (name:'Juno First';year:'1983';snd:1;hi:false;zip:'junofrst';grid:208;company:'Konami';rom:@junofrst),
  (name:'Gyruss';year:'1983';snd:1;hi:false;zip:'gyruss';grid:209;company:'Konami';rom:@gyruss),
  (name:'Boogie Wings';year:'1992';snd:1;hi:false;zip:'boogwing';grid:210;company:'Data East';rom:@boogwing),
  (name:'Free Kick';year:'1987';snd:1;hi:false;zip:'freekick';grid:211;company:'Nihon System';rom:@freekick),
  (name:'Pinball Action';year:'1985';snd:1;hi:false;zip:'pbaction';grid:212;company:'Tehkan';rom:@pbaction),
  (name:'Renegade';year:'1986';snd:1;hi:false;zip:'renegade';grid:213;company:'Technos Japan';rom:@renegade),
  (name:'Teenage Mutant Ninja Turtles';year:'1989';snd:1;hi:false;zip:'tmnt';grid:214;company:'Konami';rom:@tmnt),
  (name:'Sunset Riders';year:'1991';snd:1;hi:false;zip:'ssriders';grid:215;company:'Konami';rom:@ssriders),
  (name:'Gradius III';year:'1991';snd:1;hi:false;zip:'gradius3';grid:216;company:'Konami';rom:@gradius3),
  (name:'Space Invaders';year:'1978';snd:2;hi:false;zip:'invaders';grid:217;company:'Taito';rom:@spaceinv),
  (name:'Centipede';year:'1980';snd:1;hi:false;zip:'centiped';grid:218;company:'Atari';rom:@centipede),
  (name:'Karnov';year:'1987';snd:1;hi:false;zip:'karnov';grid:219;company:'Data East';rom:@karnov),
  (name:'Chelnov';year:'1987';snd:1;hi:false;zip:'chelnov';grid:220;company:'Data East';rom:@chelnov),
  (name:'Aliens';year:'1990';snd:1;hi:false;zip:'aliens';grid:221;company:'Konami';rom:@aliens),
  (name:'Super Contra';year:'1988';snd:1;hi:false;zip:'scontra';grid:222;company:'Konami';rom:@scontra),
  (name:'Gang Busters';year:'1988';snd:1;hi:false;zip:'gbusters';grid:223;company:'Konami';rom:@gbusters),
  (name:'Thunder Cross';year:'1988';snd:1;hi:false;zip:'thunderx';grid:224;company:'Konami';rom:@thunderx),
  (name:'The Simpsons';year:'1991';snd:1;hi:false;zip:'simpsons';grid:225;company:'Konami';rom:@simpsons),
  (name:'Track & Field';year:'1983';snd:1;hi:false;zip:'trackfld';grid:226;company:'Konami';rom:@trackfield),
  (name:'Hyper Sports';year:'1984';snd:1;hi:false;zip:'hyperspt';grid:227;company:'Konami';rom:@hypersports),
  (name:'Megazone';year:'1983';snd:1;hi:false;zip:'megazone';grid:228;company:'Konami';rom:@megazone),
  (name:'Space Fire Bird';year:'1980';snd:1;hi:false;zip:'spacefb';grid:229;company:'Nintendo';rom:@spacefb;samples:@spacefb_samples),
  (name:'Ajax';year:'1987';snd:1;hi:false;zip:'ajax';grid:230;company:'Konami';rom:@ajax),
  (name:'Xevious';year:'1982';snd:1;hi:false;zip:'xevious';grid:231;company:'Namco';rom:@xevious;samples:@xevious_samples),
  (name:'The Combatribes';year:'1990';snd:1;hi:false;zip:'ctribe';grid:232;company:'Technos';rom:@ctribe),
  (name:'Lunar Lander';year:'1979';snd:0;hi:false;zip:'llander';grid:233;company:'Atari';rom:@llander),
  (name:'Crush Roller';year:'1981';snd:1;hi:false;zip:'crush';grid:234;company:'Alpha Denshi Co./Kural Samno Electric, Ltd.';rom:@crush),
  (name:'Vendetta';year:'1991';snd:1;hi:false;zip:'vendetta';grid:235;company:'Konami';rom:@vendetta),
  (name:'Gauntlet';year:'1991';snd:1;hi:false;zip:'gauntlet';grid:236;company:'Atari';rom:@gauntlet),
  (name:'Sauro';year:'1987';snd:1;hi:false;zip:'sauro';grid:237;company:'Tecfri';rom:@sauro),
  (name:'Crazy Climber';year:'1980';snd:1;hi:false;zip:'cclimber';grid:238;company:'Nichibutsu';rom:@cclimber),
  (name:'Return of the Invaders';year:'1985';snd:1;hi:false;zip:'retofinv';grid:239;company:'Taito';rom:@retofinv),
  (name:'Tetris';year:'1988';snd:1;hi:false;zip:'atetris';grid:240;company:'Atari Games';rom:@tetris),
  (name:'Ikari Warriors';year:'1986';snd:1;hi:false;zip:'ikari';grid:241;company:'SNK';rom:@ikari),
  (name:'Athena';year:'1986';snd:1;hi:false;zip:'athena';grid:242;company:'SNK';rom:@athena),
  (name:'T.N.K III';year:'1986';snd:1;hi:false;zip:'tnk3';grid:243;company:'SNK';rom:@tnk3),
  //*** Consoles
  (name:'NES';year:'198X';snd:1;hi:false;zip:'';grid:1000;company:'Nintendo'),
  (name:'ColecoVision';year:'1980';snd:1;hi:false;zip:'coleco';grid:1001;company:'Coleco';rom:@coleco_),
  (name:'GameBoy';year:'198X';snd:1;hi:false;zip:'gameboy';grid:1002;company:'Nintendo';rom:@gameboy),
  (name:'GameBoy Color';year:'198X';snd:1;hi:false;zip:'gbcolor';grid:1002;company:'Nintendo';rom:@gbcolor),
  (name:'CHIP 8';year:'197X';snd:1;hi:false;zip:'';grid:1003;company:'-'),
  (name:'Sega Master System';year:'1985';snd:1;hi:false;zip:'sms';grid:1004;company:'Sega';rom:@sms_),
  //G&W
  (name:'Dokey Kong Jr';year:'1983';snd:1;hi:false;zip:'gnw_dj101';grid:2000;company:'Nintendo';rom:@gnw_dj101),
  (name:'Dokey Kong II';year:'1983';snd:1;hi:false;zip:'gnw_jr55';grid:2001;company:'Nintendo';rom:@gnw_jr55),
  (name:'Mario Bros';year:'1983';snd:1;hi:false;zip:'gnw_mw56';grid:2002;company:'Nintendo';rom:@gnw_mw56));

var
  orden_games:array[1..games_cont] of word;

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
  1000:principal1.CambiarMaquina(principal1.NES1);
  1001:principal1.CambiarMaquina(principal1.colecovision1);
  1002:principal1.CambiarMaquina(principal1.Gameboy1);
  1003:principal1.CambiarMaquina(principal1.CHIP81);
  1004:principal1.CambiarMaquina(principal1.SegaMS1);
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
//consolas
principal1.NES1.Checked:=false;
principal1.colecovision1.Checked:=false;
principal1.GameBoy1.Checked:=false;
principal1.chip81.checked:=false;
principal1.segams1.checked:=false;
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
principal1.BitBtn8.visible:=false; //Config arcade
principal1.Panel2.visible:=false; //Lateral
principal1.BitBtn2.Enabled:=true;
principal1.BitBtn3.Enabled:=true; //Play/Pause
principal1.BitBtn5.Enabled:=true;
principal1.BitBtn6.Enabled:=true;
principal1.BitBtn8.Enabled:=true;
principal1.BitBtn19.Enabled:=true;
principal1.BitBtn1.Enabled:=true;
principal1.BitBtn9.Enabled:=true;
principal1.BitBtn10.Enabled:=true;
principal1.BitBtn11.Enabled:=true;
principal1.BitBtn12.Enabled:=true;
principal1.BitBtn14.Enabled:=true;
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
          principal1.BitBtn10.visible:=true; //Disco
          principal1.BitBtn10.enabled:=(driver<>7); //Disco
          principal1.BitBtn11.visible:=true; //Save Snapshot
          principal1.BitBtn9.visible:=true; //Load Snapshot
       end;
  10..999:principal1.BitBtn8.visible:=true;  //Arcade
  1000,1002,1003:begin //NES y Gameboy
          principal1.Panel2.visible:=true;
          principal1.BitBtn10.visible:=true; //Disco
       end;
  1001:begin //Coleco y Chip8
          principal1.Panel2.visible:=true;
          principal1.BitBtn10.visible:=true; //Disco
          principal1.BitBtn11.visible:=true; //Load Snapshot
       end;
  1004:begin //SMS
          principal1.Panel2.visible:=true;
          principal1.BitBtn10.visible:=true; //Disco
          principal1.BitBtn1.visible:=true; //Configurar ordenador/consola
       end;
  2000..2002:; //G&W
end;
end;

procedure cargar_maquina(tmaquina:word);
begin
case tmaquina of
  0,5:Cargar_Spectrum48K;
  1,4:Cargar_Spectrum128K;
  2,3:Cargar_Spectrum3;
  7,8,9:Cargar_amstrad_CPC;
  //arcade
  10,88,234:Cargar_Pacman;
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
  23,233:Cargar_as;
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
  65,167,231:Cargar_galagahw;
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
  196,232:Cargar_ddragon3;
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
  214,215:Cargar_tmnt;
  216:Cargar_gradius3;
  217:Cargar_spaceinv;
  218:Cargar_centipede;
  219,220:Cargar_karnov;
  221:Cargar_aliens;
  222,223,224:Cargar_thunderx;
  225:cargar_simpsons;
  226:cargar_trackfield;
  227:cargar_hypersports;
  228:Cargar_megazone;
  229:Cargar_spacefb;
  230:Cargar_ajax;
  235:Cargar_vendetta;
  236:Cargar_gauntlet;
  237:Cargar_sauro;
  238:Cargar_cclimber;
  239:Cargar_retofinv;
  240:Cargar_tetris;
  241,242,243:Cargar_snk;
  //consolas
  1000:Cargar_NES;
  1001:Cargar_coleco;
  1002:Cargar_gb;
  1003:Cargar_chip8;
  1004:Cargar_SMS;
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
