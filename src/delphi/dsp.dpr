program dsp;

uses
  Forms,
  coleco in '..\CONSOLAS\coleco.pas',
  gb in '..\CONSOLAS\gb.pas',
  yiearkungfu_hw in '..\arcade\yiearkungfu_hw.pas',
  asteroids_hw in '..\arcade\asteroids_hw.pas',
  blacktiger_hw in '..\arcade\blacktiger_hw.pas',
  bombjack_hw in '..\arcade\bombjack_hw.pas',
  bubblebobble_hw in '..\arcade\bubblebobble_hw.pas',
  burgertime_hw in '..\arcade\burgertime_hw.pas',
  cityconnection_hw in '..\arcade\cityconnection_hw.pas',
  commando_hw in '..\arcade\commando_hw.pas',
  donkeykong_hw in '..\arcade\donkeykong_hw.pas',
  expressraider_hw in '..\arcade\expressraider_hw.pas',
  galaxian_hw in '..\arcade\galaxian_hw.pas',
  greenberet_hw in '..\arcade\greenberet_hw.pas',
  skykid_hw in '..\arcade\skykid_hw.pas',
  jackal_hw in '..\arcade\jackal_hw.pas',
  m62_hw in '..\arcade\m62_hw.pas',
  ladybug_hw in '..\arcade\ladybug_hw.pas',
  mikie_hw in '..\arcade\mikie_hw.pas',
  mysteriousstones_hw in '..\arcade\mysteriousstones_hw.pas',
  pacman_hw in '..\arcade\pacman_hw.pas',
  phoenix_hw in '..\arcade\phoenix_hw.pas',
  pooyan_hw in '..\arcade\pooyan_hw.pas',
  popeye_hw in '..\arcade\popeye_hw.pas',
  prehistoricisle_hw in '..\arcade\prehistoricisle_hw.pas',
  psychic5_hw in '..\arcade\psychic5_hw.pas',
  rallyx_hw in '..\arcade\rallyx_hw.pas',
  tecmo_hw in '..\arcade\tecmo_hw.pas',
  superbasketball_hw in '..\arcade\superbasketball_hw.pas',
  shaolinsroad_hw in '..\arcade\shaolinsroad_hw.pas',
  shootout_hw in '..\arcade\shootout_hw.pas',
  snowbros_hw in '..\arcade\snowbros_hw.pas',
  sonson_hw in '..\arcade\sonson_hw.pas',
  starforce_hw in '..\arcade\starforce_hw.pas',
  system1_hw in '..\arcade\system1_hw.pas',
  system1_hw_misc in '..\arcade\system1_hw_misc.pas',
  system2_hw_misc in '..\arcade\system2_hw_misc.pas',
  tehkanworldcup_hw in '..\arcade\tehkanworldcup_hw.pas',
  terracresta_hw in '..\arcade\terracresta_hw.pas',
  tigerroad_hw in '..\arcade\tigerroad_hw.pas',
  toki_hw in '..\arcade\toki_hw.pas',
  vigilante_hw in '..\arcade\vigilante_hw.pas',
  m6809 in '..\cpu\m6809.pas',
  z80daisy in '..\cpu\z80\z80daisy.pas',
  ppi8255 in '..\devices\ppi8255.pas',
  upd765 in '..\devices\upd765.pas',
  z80ctc in '..\devices\z80ctc.pas',
  z80pio in '..\devices\z80pio.pas',
  gfx_engine in '..\misc\gfx_engine.pas',
  main_engine in '..\misc\main_engine.pas',
  controls_engine in '..\misc\controls_engine.pas',
  init_games in '..\misc\init_games.pas',
  lenguaje in '..\misc\lenguaje.pas',
  snapshot in '..\misc\snapshot.pas',
  tap_tzx in '..\misc\tap_tzx.pas',
  timer_engine in '..\misc\timer_engine.pas',
  amstrad_cpc in '..\ordenadores\amstrad_cpc.pas',
  poke_spectrum in '..\ordenadores\misc\poke_spectrum.pas',
  spectrum_3 in '..\ordenadores\spectrum_3.pas',
  spectrum_48k in '..\ordenadores\spectrum_48k.pas',
  spectrum_128k in '..\ordenadores\spectrum_128k.pas',
  spectrum_misc in '..\ordenadores\misc\spectrum_misc.pas',
  ym_3812 in '..\snd\ym_3812.pas',
  asteroids_hw_audio in '..\snd\asteroids_hw_audio.pas',
  ay_8910 in '..\snd\ay_8910.pas',
  dac in '..\snd\dac.pas',
  fm_2151 in '..\snd\fm_2151.pas',
  fmopl in '..\snd\fmopl.pas',
  fmopn in '..\snd\fmopn.pas',
  konami_snd in '..\snd\konami_snd.pas',
  msm5205 in '..\snd\msm5205.pas',
  namco_snd in '..\snd\namco_snd.pas',
  phoenix_audio_digital in '..\snd\phoenix_audio_digital.pas',
  samples in '..\snd\samples.pas',
  sn_76496 in '..\snd\sn_76496.pas',
  tms36xx in '..\snd\tms36xx.pas',
  vlm_5030 in '..\snd\vlm_5030.pas',
  ym_2151 in '..\snd\ym_2151.pas',
  ym_2203 in '..\snd\ym_2203.pas',
  acercade in 'acercade.pas' {AboutBox},
  cargar_dsk in 'cargar_dsk.pas' {load_dsk},
  config in 'config.pas' {ConfigSP},
  config_general in 'config_general.pas' {MConfig},
  LoadRom in 'LoadRom.pas' {FLoadRom},
  poke_memoria in 'poke_memoria.pas' {poke_spec},
  nes_ppu in '..\CONSOLAS\nes_ppu.pas',
  principal in 'principal.pas' {principal1},
  m680x in '..\cpu\m680x.pas',
  contra_hw in '..\arcade\contra_hw.pas',
  mappy_hw in '..\arcade\mappy_hw.pas',
  rastan_hw in '..\arcade\rastan_hw.pas',
  taitosnd in '..\snd\taitosnd.pas',
  namcoio_56xx_58xx in '..\devices\namcoio_56xx_58xx.pas',
  legendarywings_hw in '..\arcade\legendarywings_hw.pas',
  streetfighter_hw in '..\arcade\streetfighter_hw.pas',
  galaga_hw in '..\arcade\galaga_hw.pas',
  namcoio_06xx_5Xxx in '..\devices\namcoio_06xx_5Xxx.pas',
  xaindsleena_hw in '..\arcade\xaindsleena_hw.pas',
  suna8_hw in '..\arcade\suna8_hw.pas',
  nmk16_hw in '..\arcade\nmk16_hw.pas',
  knucklejoe_hw in '..\arcade\knucklejoe_hw.pas',
  wardner_hw in '..\arcade\wardner_hw.pas',
  tms32010 in '..\cpu\tms32010.pas',
  gaelco_hw in '..\arcade\gaelco_hw.pas',
  exedexes_hw in '..\arcade\exedexes_hw.pas',
  gunsmoke_hw in '..\arcade\gunsmoke_hw.pas',
  redefine in 'redefine.pas' {redefine1},
  hw_1942 in '..\arcade\hw_1942.pas',
  mb88xx in '..\cpu\mb88xx.pas',
  jailbreak_hw in '..\arcade\jailbreak_hw.pas',
  circuscharlie_hw in '..\arcade\circuscharlie_hw.pas',
  ironhorse_hw in '..\arcade\ironhorse_hw.pas',
  m72_hw in '..\arcade\m72_hw.pas',
  breakthru_hw in '..\arcade\breakthru_hw.pas',
  dec8_hw in '..\arcade\dec8_hw.pas',
  doubledragon_hw in '..\arcade\doubledragon_hw.pas',
  hd6309 in '..\cpu\hd6309.pas',
  mrdo_hw in '..\arcade\mrdo_hw.pas',
  epos_hw in '..\arcade\epos_hw.pas',
  oki6295 in '..\snd\oki6295.pas',
  slapfight_hw in '..\arcade\slapfight_hw.pas',
  legendkage_hw in '..\arcade\legendkage_hw.pas',
  cabal_hw in '..\arcade\cabal_hw.pas',
  seibu_sound in '..\snd\seibu_sound.pas',
  cps1_hw in '..\arcade\cps1_hw.pas',
  qsound in '..\snd\qsound.pas',
  cargar_spec in 'cargar_spec.pas' {load_spec},
  gb_sound in '..\snd\gb_sound.pas',
  rom_engine in '..\misc\rom_engine.pas',
  misc_functions in '..\misc\misc_functions.pas',
  system16a_hw in '..\arcade\system16a_hw.pas',
  pal_engine in '..\misc\pal_engine.pas',
  timepilot84_hw in '..\arcade\timepilot84_hw.pas',
  tutankham_hw in '..\arcade\tutankham_hw.pas',
  m6805 in '..\cpu\m6805.pas',
  pang_hw in '..\arcade\pang_hw.pas',
  ninjakid2_hw in '..\arcade\ninjakid2_hw.pas',
  mc8123 in '..\devices\mc8123.pas',
  gng_hw in '..\arcade\gng_hw.pas',
  system86_hw in '..\arcade\system86_hw.pas',
  rocnrope_hw in '..\arcade\rocnrope_hw.pas',
  konami_decrypt in '..\arcade\misc\konami_decrypt.pas',
  gaelco_hw_decrypt in '..\arcade\misc\gaelco_hw_decrypt.pas',
  kabuki_decript in '..\arcade\misc\kabuki_decript.pas',
  mcs51 in '..\cpu\mcs51.pas',
  kyugo_hw in '..\arcade\kyugo_hw.pas',
  thenewzealandstory_hw in '..\arcade\thenewzealandstory_hw.pas',
  pacland_hw in '..\arcade\pacland_hw.pas',
  mariobros_hw in '..\arcade\mariobros_hw.pas',
  solomonkey_hw in '..\arcade\solomonkey_hw.pas',
  combatschool_hw in '..\arcade\combatschool_hw.pas',
  konami_video in '..\arcade\misc\konami_video.pas',
  kaneco_pandora in '..\arcade\misc\kaneco_pandora.pas',
  heavyunit_hw in '..\arcade\heavyunit_hw.pas',
  uchild in 'uchild.pas' {frChild},
  upd7759 in '..\snd\upd7759.pas',
  sound_engine in '..\misc\sound_engine.pas',
  snk68_hw in '..\arcade\snk68_hw.pas',
  megasys1_hw in '..\arcade\megasys1_hw.pas',
  timepilot_hw in '..\arcade\timepilot_hw.pas',
  pengo_hw in '..\arcade\pengo_hw.pas',
  sega_decrypt in '..\arcade\misc\sega_decrypt.pas',
  galaga_stars_const in '..\arcade\misc\galaga_stars_const.pas',
  tape_window in 'tape_window.pas' {tape_window1},
  file_engine in '..\misc\file_engine.pas',
  lenslock in 'lenslock.pas' {lenslock1},
  twincobra_hw in '..\arcade\twincobra_hw.pas',
  jrpacman_hw in '..\arcade\jrpacman_hw.pas',
  dec0_hw in '..\arcade\dec0_hw.pas',
  hu6280 in '..\cpu\hu6280.pas',
  cavemanninja_hw in '..\arcade\cavemanninja_hw.pas',
  deco_decr in '..\arcade\misc\deco_decr.pas',
  funkyjet_hw in '..\arcade\funkyjet_hw.pas',
  superburgertime_hw in '..\arcade\superburgertime_hw.pas',
  deco_common in '..\arcade\misc\deco_common.pas',
  dietgogo_hw in '..\arcade\dietgogo_hw.pas',
  m68000 in '..\cpu\m68000.pas',
  m6502 in '..\cpu\m6502.pas',
  lr35902 in '..\cpu\lr35902.pas',
  actfancer_hw in '..\arcade\actfancer_hw.pas',
  deco_bac06 in '..\arcade\misc\deco_bac06.pas',
  arabian_hw in '..\arcade\arabian_hw.pas',
  n2a03 in '..\cpu\n2a03.pas',
  higemaru_hw in '..\arcade\higemaru_hw.pas',
  arcade_config in 'arcade_config.pas' {config_arcade},
  bagman_hw in '..\arcade\bagman_hw.pas',
  bagman_pal in '..\arcade\misc\bagman_pal.pas',
  chip8_hw in '..\consolas\chip8_hw.pas',
  nes_mappers in '..\consolas\nes_mappers.pas',
  nes in '..\consolas\nes.pas',
  gb_mappers in '..\consolas\gb_mappers.pas',
  tms99xx in '..\devices\tms99xx.pas',
  zaxxon_hw in '..\arcade\zaxxon_hw.pas',
  nz80 in '..\cpu\z80\nz80.pas',
  z80_sp in '..\cpu\z80\z80_sp.pas',
  nec_v20_v30 in '..\cpu\nec_v20_v30.pas',
  kangaroo_hw in '..\arcade\kangaroo_hw.pas',
  bioniccommando_hw in '..\arcade\bioniccommando_hw.pas',
  wwfsuperstars_hw in '..\arcade\wwfsuperstars_hw.pas',
  qsnapshot in '..\misc\qsnapshot.pas',
  rainbowislands_hw in '..\arcade\rainbowislands_hw.pas',
  rainbow_cchip in '..\arcade\misc\rainbow_cchip.pas',
  spectrum_load in '..\ordenadores\misc\spectrum_load.pas',
  volfied_hw in '..\arcade\volfied_hw.pas',
  volfied_cchip in '..\arcade\misc\volfied_cchip.pas',
  operationwolf_hw in '..\arcade\operationwolf_hw.pas',
  opwolf_cchip in '..\arcade\misc\opwolf_cchip.pas',
  joystick_calibrate in 'joystick_calibrate.pas' {joy_calibration},
  eeprom in '..\devices\eeprom.pas',
  outrun_hw in '..\arcade\outrun_hw.pas',
  taitosj_hw in '..\arcade\taitosj_hw.pas',
  fd1089 in '..\devices\fd1089.pas',
  vars_hide in '..\misc\vars_hide.pas',
  vulgus_hw in '..\arcade\vulgus_hw.pas',
  ddragon3_hw in '..\arcade\ddragon3_hw.pas',
  blockout_hw in '..\arcade\blockout_hw.pas',
  foodfight_hw in '..\arcade\foodfight_hw.pas',
  pokey in '..\snd\pokey.pas',
  disk_file_format in '..\misc\disk_file_format.pas',
  ipf_disk in '..\misc\ipf_disk.pas',
  nemesis_hw in '..\arcade\nemesis_hw.pas',
  pirates_hw in '..\arcade\pirates_hw.pas',
  junofirst_hw in '..\arcade\junofirst_hw.pas',
  gyruss_hw in '..\arcade\gyruss_hw.pas',
  freekick_hw in '..\arcade\freekick_hw.pas',
  boogiewings_hw in '..\arcade\boogiewings_hw.pas',
  pinballaction_hw in '..\arcade\pinballaction_hw.pas',
  sms in '..\consolas\sms.pas',
  sega_vdp in '..\consolas\sega_vdp.pas',
  config_sms in 'config_sms.pas' {SMSConfig},
  lib_sdl2 in '..\misc\lib_sdl2.pas',
  renegade_hw in '..\arcade\renegade_hw.pas',
  generic_adpcm in '..\snd\generic_adpcm.pas',
  tmnt_hw in '..\arcade\tmnt_hw.pas',
  eepromser in '..\devices\eepromser.pas',
  gradius3_hw in '..\arcade\gradius3_hw.pas',
  rom_export in '..\misc\rom_export.pas',
  config_cpc in 'config_cpc.pas' {ConfigCPC},
  spaceinvaders_hw in '..\arcade\spaceinvaders_hw.pas',
  centipede_hw in '..\arcade\centipede_hw.pas',
  karnov_hw in '..\arcade\karnov_hw.pas',
  konami in '..\cpu\konami.pas',
  aliens_hw in '..\arcade\aliens_hw.pas',
  thunderx_hw in '..\arcade\thunderx_hw.pas',
  device_functions in '..\misc\device_functions.pas',
  simpsons_hw in '..\arcade\simpsons_hw.pas',
  deco_104 in '..\devices\deco_104.pas',
  deco_146 in '..\devices\deco_146.pas',
  k051960 in '..\devices\k051960.pas',
  k052109 in '..\devices\k052109.pas',
  k053244_k053245 in '..\devices\k053244_k053245.pas',
  k053246_k053247_k055673 in '..\devices\k053246_k053247_k055673.pas',
  k053251 in '..\devices\k053251.pas',
  k007232 in '..\snd\k007232.pas',
  k053260 in '..\snd\k053260.pas',
  cpu_misc in '..\cpu\cpu_misc.pas',
  trackandfield_hw in '..\arcade\trackandfield_hw.pas',
  hypersports_hw in '..\arcade\hypersports_hw.pas',
  mcs48 in '..\cpu\mcs48.pas',
  megazone_hw in '..\arcade\megazone_hw.pas',
  i8243 in '..\devices\i8243.pas',
  spacefirebird_hw in '..\arcade\spacefirebird_hw.pas',
  ajax_hw in '..\arcade\ajax_hw.pas',
  k051316 in '..\devices\k051316.pas',
  vendetta_hw in '..\arcade\vendetta_hw.pas',
  k054000 in '..\devices\k054000.pas',
  deco_16ic in '..\arcade\misc\deco_16ic.pas',
  gauntlet_hw in '..\arcade\gauntlet_hw.pas',
  sauro_hw in '..\arcade\sauro_hw.pas',
  crazyclimber_hw in '..\arcade\crazyclimber_hw.pas',
  crazyclimber_hw_dac in '..\snd\crazyclimber_hw_dac.pas',
  returnofinvaders_hw in '..\arcade\returnofinvaders_hw.pas',
  sm510 in '..\cpu\sm510.pas',
  gnw_510 in '..\gnw\gnw_510.pas',
  m6845 in '..\devices\m6845.pas',
  tetris_atari_hw in '..\arcade\tetris_atari_hw.pas',
  slapstic in '..\arcade\misc\slapstic.pas',
  snk_hw in '..\arcade\snk_hw.pas',
  atari_system1 in '..\arcade\atari_system1.pas',
  atari_mo in '..\arcade\misc\atari_mo.pas',
  williams_hw in '..\arcade\williams_hw.pas',
  pia6821 in '..\devices\pia6821.pas',
  taito_cchip in '..\arcade\misc\taito_cchip.pas',
  upd7810 in '..\cpu\upd7810.pas',
  upd7810_tables in '..\cpu\upd7810_tables.pas',
  sg1000 in '..\consolas\sg1000.pas',
  systeme_hw in '..\arcade\systeme_hw.pas',
  route16_hw in '..\arcade\route16_hw.pas',
  k005289 in '..\snd\k005289.pas',
  badlands_hw in '..\arcade\badlands_hw.pas',
  nb1412_m2 in '..\arcade\misc\nb1412_m2.pas',
  galivan_hw in '..\arcade\galivan_hw.pas',
  lastduel_hw in '..\arcade\lastduel_hw.pas',
  commodore64 in '..\ordenadores\commodore64.pas',
  mos6526 in '..\ordenadores\misc\mos6526.pas',
  mos6566 in '..\ordenadores\misc\mos6566.pas',
  mos6526_old in '..\ordenadores\misc\mos6526_old.pas',
  sid_sound in '..\snd\sid_sound.pas',
  sid_tables in '..\snd\sid_tables.pas',
  d64_file_format in '..\misc\d64_file_format.pas',
  armedf_hw in '..\arcade\armedf_hw.pas',
  nb1414_m4 in '..\arcade\misc\nb1414_m4.pas',
  sega_gg in '..\consolas\sega_gg.pas',
  gnw_dkjr_const in '..\gnw\gnw_dkjr_const.pas',
  gnw_dkong2_const in '..\gnw\gnw_dkong2_const.pas',
  gnw_mariobros_const in '..\gnw\gnw_mariobros_const.pas',
  firetrap_hw in '..\arcade\firetrap_hw.pas',
  hw_3x3puzzle in '..\arcade\hw_3x3puzzle.pas',
  hw_1945k3 in '..\arcade\hw_1945k3.pas',
  bloodbros_hw in '..\arcade\bloodbros_hw.pas',
  baraduke_hw in '..\arcade\baraduke_hw.pas',
  system16b_hw in '..\arcade\system16b_hw.pas',
  sega_315_5195 in '..\arcade\misc\sega_315_5195.pas',
  sega_pcm in '..\snd\sega_pcm.pas',
  config_gb in 'config_gb.pas' {configgb};

{$R *.res}

begin
  Application.Initialize;
  Application.Title:='DSP Emulator';
  Application.CreateForm(Tprincipal1, principal1);
  Application.CreateForm(Tload_spec, load_spec);
  Application.CreateForm(Tredefine1, redefine1);
  Application.CreateForm(Ttape_window1, tape_window1);
  Application.CreateForm(Tlenslock1, lenslock1);
  Application.CreateForm(TMConfig, MConfig);
  Application.CreateForm(TConfigSP, ConfigSP);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(Tload_dsk, load_dsk);
  Application.CreateForm(TFLoadRom, FLoadRom);
  Application.CreateForm(Tconfig_arcade, config_arcade);
  Application.CreateForm(Tjoy_calibration, joy_calibration);
  Application.CreateForm(TSMSConfig, SMSConfig);
  Application.CreateForm(TConfigCPC, ConfigCPC);
  Application.CreateForm(Tconfiggb, configgb);
  Application.Run;
end.
