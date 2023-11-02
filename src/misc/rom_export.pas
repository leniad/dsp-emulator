unit rom_export;

interface
uses rom_engine,dialogs,main_engine,sysutils,lenguaje,misc_functions;

type
  tsample_file=record
    nombre:string;
  end;
  ptsample_file=^tsample_file;

procedure export_roms;

const
        //Samples
        asteroid_samples:array[0..3] of tsample_file=(
        (nombre:'explode1.wav'),(nombre:'explode2.wav'),(nombre:'explode3.wav'),());
        congo_samples:array[0..5] of tsample_file=(
        (nombre:'gorilla.wav'),(nombre:'bass.wav'),(nombre:'congal.wav'),(nombre:'congah.wav'),(nombre:'rim.wav'),());
        zaxxon_samples:array[0..12] of tsample_file=(
        (nombre:'03.wav'),(nombre:'02.wav'),(nombre:'01.wav'),
        (nombre:'00.wav'),(nombre:'11.wav'),(nombre:'10.wav'),
        (nombre:'08.wav'),(nombre:'23.wav'),(nombre:'21.wav'),
        (nombre:'20.wav'),(nombre:'05.wav'),(nombre:'04.wav'),());
        dkong_samples:array[0..25] of tsample_file=(
        (nombre:'death.wav'),(nombre:'tune01.wav'),(nombre:'tune02.wav'),
        (nombre:'tune03.wav'),(nombre:'tune04.wav'),
        (nombre:'tune05.wav'),(nombre:'tune06.wav'),(nombre:'tune07.wav'),
        (nombre:'tune08_1.wav'),(nombre:'tune08_2.wav'),
        (nombre:'tune09_1.wav'),(nombre:'tune09_2.wav'),
        (nombre:'tune11_1.wav'),(nombre:'tune11_2.wav'),
        (nombre:'tune12.wav'),(nombre:'tune13.wav'),(nombre:'tune14.wav'),(nombre:'tune15.wav'),
        (nombre:'ef01_1.wav'),(nombre:'ef01_2.wav'),(nombre:'ef02.wav'),
        (nombre:'ef03.wav'),(nombre:'ef04.wav'),(nombre:'ef05.wav'),(nombre:'ef06.wav'),());
        dkjr_samples:array[0..22] of tsample_file=(
        (nombre:'death.wav'),(nombre:'tune01.wav'),
        (nombre:'tune02.wav'),(nombre:'tune03.wav'),(nombre:'tune04.wav'),
        (nombre:'tune05.wav'),(nombre:'tune06.wav'),(nombre:'tune07.wav'),
        (nombre:'tune08.wav'),(nombre:'tune09.wav'),(nombre:'tune10.wav'),
        (nombre:'tune11.wav'),(nombre:'tune12.wav'),(nombre:'tune13.wav'),
        (nombre:'tune14.wav'),(nombre:'ef01.wav'),(nombre:'ef02.wav'),(nombre:'ef03.wav'),
        (nombre:'ef04.wav'),(nombre:'ef05.wav'),(nombre:'ef06.wav'),(nombre:'ef07.wav'),());
        mario_samples:array[0..29] of tsample_file=(
        (nombre:'mario_run.wav'),(nombre:'luigi_run.wav'),(nombre:'skid.wav'),(nombre:'bite_death.wav'),(nombre:'death.wav'),
        (nombre:'tune1.wav'),(nombre:'tune2.wav'),(nombre:'tune3.wav'),(nombre:'tune4.wav'),(nombre:'tune5.wav'),(nombre:'tune6.wav'),
        (nombre:'tune7.wav'),(nombre:'tune8.wav'),(nombre:'tune9.wav'),(nombre:'tune10.wav'),(nombre:'tune11.wav'),(nombre:'tune12.wav'),
        (nombre:'tune13.wav'),(nombre:'tune14.wav'),(nombre:'tune15.wav'),(nombre:'tune16.wav'),(nombre:'tune17.wav'),(nombre:'tune18.wav'),(nombre:'tune19.wav'),
        (nombre:'coin.wav'),(nombre:'insert_coin.wav'),(nombre:'turtle.wav'),(nombre:'crab.wav'),(nombre:'fly.wav'),());
        galaxian_samples:array[0..9] of tsample_file=(
        (nombre:'fire.wav'),(nombre:'death.wav'),(nombre:'back1.wav'),(nombre:'back2.wav'),(nombre:'back3.wav'),
        (nombre:'kill.wav'),(nombre:'coin.wav'),(nombre:'music.wav'),(nombre:'extra.wav'),());
        mooncrst_samples:array[0..5] of tsample_file=(
        (nombre:'fire.wav'),(nombre:'death.wav'),(nombre:'back1.wav'),(nombre:'back2.wav'),(nombre:'back3.wav'),());
        rallyx_samples:array[0..1] of tsample_file=((nombre:'bang.wav'),());
        spacefb_samples:array[0..4] of tsample_file=(
        (nombre:'ekilled.wav'),(nombre:'explode1.wav'),(nombre:'explode2.wav'),(nombre:'shipfire.wav'),());
        galaga_samples:array[0..2] of tsample_file=((nombre:'bang.wav'),(nombre:'init.wav'),());
        xevious_samples:array[0..2] of tsample_file=((nombre:'explo1.wav'),(nombre:'explo2.wav'),());
        spaceinv_samples:array[0..9] of tsample_file=(
        (nombre:'1.wav'),(nombre:'2.wav'),(nombre:'3.wav'),(nombre:'4.wav'),(nombre:'5.wav'),
        (nombre:'6.wav'),(nombre:'7.wav'),(nombre:'8.wav'),(nombre:'9.wav'),());
        bosco_samples:array[0..3] of tsample_file=(
        (nombre:'bigbang.wav'),(nombre:'midbang.wav'),(nombre:'shot.wav'),());
        gaplus_samples:array[0..1] of tsample_file=((nombre:'bang.wav'),());
        //Ordenadores
        spectrum:array[0..1] of tipo_roms=(
        (n:'spectrum.rom';l:$4000;p:0;crc:$ddee531f),());
        spec128:array[0..2] of tipo_roms=(
        (n:'128-0.rom';l:$4000;p:0;crc:$e76799d2),(n:'128-1.rom';l:$4000;p:$4000;crc:$b96a36be),());
        spec_plus2:array[0..2] of tipo_roms=(
        (n:'plus2-0.rom';l:$4000;p:0;crc:$5d2e8c66),(n:'plus2-1.rom';l:$4000;p:$4000;crc:$98b1320b),());
        plus3:array[0..4] of tipo_roms=(
        (n:'plus3-0.rom';l:$4000;p:0;crc:$30c9f490),(n:'plus3-1.rom';l:$4000;p:$4000;crc:$a7916b3f),
        (n:'plus3-2.rom';l:$4000;p:$8000;crc:$c9a0b748),(n:'plus3-3.rom';l:$4000;p:$c000;crc:$b88fd6e3),());
        cpc464:array[0..4] of tipo_roms=((n:'cpc464.rom';l:$8000;p:0;crc:$40852f25),(n:'cpc464f.rom';l:$8000;p:0;crc:$17893d60),(n:'cpc464sp.rom';l:$8000;p:0;crc:$338daf2d),(n:'cpc464d.rom';l:$8000;p:0;crc:$260e45c3),());
        cpc664:array[0..2] of tipo_roms=((n:'cpc664.rom';l:$8000;p:0;crc:$9ab5a036),(n:'amsdos.rom';l:$4000;p:0;crc:$1fe22ecd),());
        cpc6128:array[0..5] of tipo_roms=((n:'cpc6128.rom';l:$8000;p:0;crc:$9e827fe1),(n:'cpc6128f.rom';l:$8000;p:0;crc:$1574923b),(n:'cpc6128sp.rom';l:$8000;p:0;crc:$2fa2e7d6),(n:'cpc6128d.rom';l:$8000;p:0;crc:$4704685a),(n:'amsdos.rom';l:$4000;p:0;crc:$1fe22ecd),());
        c64:array [0..3] of tipo_roms=((n:'901227-03.u4';l:$2000;p:$0;crc:$dbe3e7c7),(n:'901226-01.u3';l:$2000;p:$0;crc:$f833d117),(n:'901225-01.u5';l:$1000;p:0;crc:$ec4272ee),());
        orica:array [0..1] of tipo_roms=((n:'basic11b.rom';l:$4000;p:$c000;crc:$c3a92bef),());
        oric1:array [0..1] of tipo_roms=((n:'basic10.rom';l:$4000;p:$0;crc:$f18710b4),());
        //Consolas
        coleco_:array[0..1] of tipo_roms=((n:'coleco.rom';l:$2000;p:0;crc:$3aa93ef3),());
        gameboy:array[0..1] of tipo_roms=((n:'dmg_boot.bin';l:$100;p:0;crc:$59c8598e),());
        gbcolor:array[0..2] of tipo_roms=(
        (n:'gbc_boot.1';l:$100;p:0;crc:$779ea374),(n:'gbc_boot.2';l:$700;p:$200;crc:$f741807d),());
        sms_:array[0..2] of tipo_roms=((n:'mpr-12808.ic2';l:$2000;p:0;crc:$0072ed54),(n:'mpr-11124.ic2';l:$2000;p:0;crc:$48d44a13),());
        scv:array[0..2] of tipo_roms=((n:'upd7801g.s01';l:$1000;p:0;crc:$7ac06182),(n:'epochtv.chr';l:$400;p:$1000;crc:$db521533),());
        pv2000_rom:array[0..1] of tipo_roms=((n:'hn613128pc64.bin';l:$4000;p:0;crc:$8f31f297),());
        //gnw
        gnw_jr55:array[0..1] of tipo_roms=((n:'jr55_cms54c_kms560';l:$1000;p:$0;crc:$46aed0ae),());
        gnw_dj101:array[0..1] of tipo_roms=((n:'dj101';l:$1000;p:$0;crc:$8dcfb5d1),());
        gnw_mw56:array[0..1] of tipo_roms=((n:'mw-56';l:$1000;p:$0;crc:$385e59da),());
        //Pacman
        pacman:array[0..9] of tipo_roms=(
        (n:'pacman.6e';l:$1000;p:0;crc:$c1e6ab10),(n:'pacman.6f';l:$1000;p:$1000;crc:$1a6fb2d4),
        (n:'pacman.6h';l:$1000;p:$2000;crc:$bcdd1beb),(n:'pacman.6j';l:$1000;p:$3000;crc:$817d94e3),
        (n:'82s123.7f';l:$20;p:0;crc:$2fc650bd),(n:'82s126.4a';l:$100;p:$20;crc:$3eb3a8e4),
        (n:'pacman.5e';l:$1000;p:0;crc:$0c944964),(n:'82s126.1m';l:$100;p:0;crc:$a9cc86bf),
        (n:'pacman.5f';l:$1000;p:0;crc:$958fedf9),());
        //MS-Pacman
        mspacman:array[0..12] of tipo_roms=(
        (n:'pacman.6e';l:$1000;p:0;crc:$c1e6ab10),(n:'pacman.6f';l:$1000;p:$1000;crc:$1a6fb2d4),
        (n:'pacman.6h';l:$1000;p:$2000;crc:$bcdd1beb),(n:'pacman.6j';l:$1000;p:$3000;crc:$817d94e3),
        (n:'u5';l:$800;p:$8000;crc:$f45fbbcd),(n:'u6';l:$1000;p:$9000;crc:$a90e7000),
        (n:'u7';l:$1000;p:$b000;crc:$c82cd714),(n:'5e';l:$1000;p:0;crc:$5c281d01),
        (n:'5f';l:$1000;p:0;crc:$615af909),(n:'82s126.1m';l:$100;p:0;crc:$a9cc86bf),
        (n:'82s123.7f';l:$20;p:0;crc:$2fc650bd),(n:'82s126.4a';l:$100;p:$20;crc:$3eb3a8e4),());
        actfancer:array[0..19] of tipo_roms=(
        (n:'fe08-3.bin';l:$10000;p:0;crc:$35f1999d),(n:'fe09-3.bin';l:$10000;p:$10000;crc:$d21416ca),
        (n:'fe10-3.bin';l:$10000;p:$20000;crc:$85535fcc),
        (n:'15';l:$10000;p:0;crc:$a1baf21e),(n:'16';l:$10000;p:$10000;crc:$22e64730),
        (n:'17-1';l:$8000;p:$8000;crc:$289ad106),(n:'18';l:$10000;p:0;crc:$5c55b242),
        (n:'14';l:$10000;p:0;crc:$d6457420),(n:'12';l:$10000;p:$10000;crc:$08787b7a),
        (n:'13';l:$10000;p:$20000;crc:$c30c37dc),(n:'11';l:$10000;p:$30000;crc:$1f006d9f),
        (n:'02';l:$10000;p:$00000;crc:$b1db0efc),(n:'03';l:$8000;p:$10000;crc:$f313e04f),
        (n:'06';l:$10000;p:$18000;crc:$8cb6dd87),(n:'07';l:$8000;p:$28000;crc:$dd345def),
        (n:'00';l:$10000;p:$30000;crc:$d50a9550),(n:'01';l:$8000;p:$40000;crc:$34935e93),
        (n:'04';l:$10000;p:$48000;crc:$bcf41795),(n:'05';l:$8000;p:$58000;crc:$d38b94aa),());
        phoenix:array[0..14] of tipo_roms=(
        (n:'ic45';l:$800;p:0;crc:$9f68086b),(n:'ic46';l:$800;p:$800;crc:$273a4a82),
        (n:'ic47';l:$800;p:$1000;crc:$3d4284b9),(n:'ic48';l:$800;p:$1800;crc:$cb5d9915),
        (n:'h5-ic49.5a';l:$800;p:$2000;crc:$a105e4e7),(n:'h6-ic50.6a';l:$800;p:$2800;crc:$ac5e9ec1),
        (n:'h7-ic51.7a';l:$800;p:$3000;crc:$2eab35b4),(n:'h8-ic52.8a';l:$800;p:$3800;crc:$aff8e9c5),
        (n:'ic23.3d';l:$800;p:0;crc:$3c7e623f),(n:'ic24.4d';l:$800;p:$800;crc:$59916d3b),
        (n:'b1-ic39.3b';l:$800;p:0;crc:$53413e8f),(n:'b2-ic40.4b';l:$800;p:$800;crc:$0be2ba91),
        (n:'mmi6301.ic40';l:$100;p:0;crc:$79350b25),(n:'mmi6301.ic41';l:$100;p:$100;crc:$e176b768),());
        //Pleiads
        pleiads:array[0..14] of tipo_roms=(
        (n:'ic47.r1';l:$800;p:0;crc:$960212c8),(n:'ic48.r2';l:$800;p:$800;crc:$b254217c),
        (n:'ic47.bin';l:$800;p:$1000;crc:$87e700bb),(n:'ic48.bin';l:$800;p:$1800;crc:$2d5198d0),
        (n:'ic51.r5';l:$800;p:$2000;crc:$49c629bc),(n:'ic50.bin';l:$800;p:$2800;crc:$f1a8a00d),
        (n:'ic53.r7';l:$800;p:$3000;crc:$b5f07fbc),(n:'ic52.bin';l:$800;p:$3800;crc:$b1b5a8a6),
        (n:'ic23.bin';l:$800;p:0;crc:$4e30f9e7),(n:'ic24.bin';l:$800;p:$800;crc:$5188fc29),
        (n:'ic39.bin';l:$800;p:0;crc:$85866607),(n:'ic40.bin';l:$800;p:$800;crc:$a841d511),
        (n:'7611-5.33';l:$100;p:0;crc:$e38eeb83),(n:'7611-5.26';l:$100;p:$100;crc:$7a1bcb1e),());
        mystston:array[0..19] of tipo_roms=(
        (n:'rom6.bin';l:$2000;p:$4000;crc:$7bd9c6cd),(n:'rom5.bin';l:$2000;p:$6000;crc:$a83f04a6),
        (n:'rom4.bin';l:$2000;p:$8000;crc:$46c73714),(n:'rom3.bin';l:$2000;p:$A000;crc:$34f8b8a3),
        (n:'rom2.bin';l:$2000;p:$C000;crc:$bfd22cfc),(n:'rom1.bin';l:$2000;p:$E000;crc:$fb163e38),
        (n:'ms6';l:$2000;p:$0000;crc:$85c83806),(n:'ms9';l:$2000;p:$2000;crc:$b146c6ab),
        (n:'ms7';l:$2000;p:$4000;crc:$d025f84d),(n:'ms10';l:$2000;p:$6000;crc:$d85015b5),
        (n:'ms8';l:$2000;p:$8000;crc:$53765d89),(n:'ms11';l:$2000;p:$A000;crc:$919ee527),
        (n:'ms12';l:$2000;p:$0000;crc:$72d8331d),(n:'ms13';l:$2000;p:$2000;crc:$845a1f9b),
        (n:'ms14';l:$2000;p:$4000;crc:$822874b0),(n:'ms15';l:$2000;p:$6000;crc:$4594e53c),
        (n:'ms16';l:$2000;p:$8000;crc:$2f470b0f),(n:'ms17';l:$2000;p:$A000;crc:$38966d1b),
        (n:'ic61';l:$20;p:0;crc:$e802d6cf),());
        bombjack:array[0..16] of tipo_roms=(
        (n:'09_j01b.bin';l:$2000;p:0;crc:$c668dc30),(n:'10_l01b.bin';l:$2000;p:$2000;crc:$52a1e5fb),
        (n:'11_m01b.bin';l:$2000;p:$4000;crc:$b68a062a),(n:'12_n01b.bin';l:$2000;p:$6000;crc:$1d3ecee5),
        (n:'13.1r';l:$2000;p:$c000;crc:$70e0244d),(n:'05_k08t.bin';l:$1000;p:$2000;crc:$e87ec8b1),
        (n:'03_e08t.bin';l:$1000;p:0;crc:$9f0470d5),(n:'04_h08t.bin';l:$1000;p:$1000;crc:$81ec12e6),
        (n:'06_l08t.bin';l:$2000;p:0;crc:$51eebd89),(n:'07_n08t.bin';l:$2000;p:$2000;crc:$9dd98e9d),
        (n:'16_m07b.bin';l:$2000;p:0;crc:$94694097),(n:'15_l07b.bin';l:$2000;p:$2000;crc:$013f58f2),
        (n:'14_j07b.bin';l:$2000;p:$4000;crc:$101c858d),(n:'02_p04t.bin';l:$1000;p:0;crc:$398d4a02),
        (n:'08_r08t.bin';l:$2000;p:$4000;crc:$3155ee7d),(n:'01_h03t.bin';l:$2000;p:0;crc:$8407917d),());
        //Galaxian
        galaxian:array[0..8] of tipo_roms=(
        (n:'galmidw.u';l:$800;p:0;crc:$745e2d61),(n:'galmidw.v';l:$800;p:$800;crc:$9c999a40),
        (n:'galmidw.w';l:$800;p:$1000;crc:$b5894925),(n:'galmidw.y';l:$800;p:$1800;crc:$6b3ca10b),
        (n:'1h.bin';l:$800;p:0;crc:$39fb43a4),(n:'1k.bin';l:$800;p:$800;crc:$7e3f56a2),
        (n:'7l';l:$800;p:$2000;crc:$1b933207),(n:'6l.bpr';l:$20;p:0;crc:$c3ac9467),());
        //Jump Bug
        jumpbug:array[0..14] of tipo_roms=(
        (n:'jb1';l:$1000;p:0;crc:$415aa1b7),(n:'jb2';l:$1000;p:$1000;crc:$b1c27510),
        (n:'jb3';l:$1000;p:$2000;crc:$97c24be2),(n:'jb4';l:$1000;p:$3000;crc:$66751d12),
        (n:'jb5';l:$1000;p:$8000;crc:$e2d66faf),(n:'jb6';l:$1000;p:$9000;crc:$49e0bdfd),
        (n:'jbl';l:$800;p:0;crc:$9a091b0a),(n:'jbm';l:$800;p:$800;crc:$8a0fc082),
        (n:'jbn';l:$800;p:$1000;crc:$155186e0),(n:'jbi';l:$800;p:$1800;crc:$7749b111),
        (n:'jbj';l:$800;p:$2000;crc:$06e8d7df),(n:'jbk';l:$800;p:$2800;crc:$b8dbddf3),
        (n:'jb7';l:$800;p:$a000;crc:$83d71302),(n:'l06_prom.bin';l:$20;p:0;crc:$6a0c7d87),());
        //Moon Cresta
        mooncrst:array[0..13] of tipo_roms=(
        (n:'mc1';l:$800;p:0;crc:$7d954a7a),(n:'mc2';l:$800;p:$800;crc:$44bb7cfa),
        (n:'mc3';l:$800;p:$1000;crc:$9c412104),(n:'mc4';l:$800;p:$1800;crc:$7e9b1ab5),
        (n:'mc5.7r';l:$800;p:$2000;crc:$16c759af),(n:'mc6.8d';l:$800;p:$2800;crc:$69bcafdb),
        (n:'mc7.8e';l:$800;p:$3000;crc:$b50dbc46),(n:'mc8';l:$800;p:$3800;crc:$18ca312b),
        (n:'mcs_b';l:$800;p:0;crc:$fb0f1f81),(n:'mcs_d';l:$800;p:$800;crc:$13932a15),
        (n:'mcs_a';l:$800;p:$1000;crc:$631ebb5a),(n:'mcs_c';l:$800;p:$1800;crc:$24cfd145),
        (n:'l06_prom.bin';l:$20;p:0;crc:$6a0c7d87),());
        //Scramble
        scramble:array[0..14] of tipo_roms=(
        (n:'s1.2d';l:$800;p:0;crc:$ea35ccaa),(n:'s2.2e';l:$800;p:$800;crc:$e7bba1b3),
        (n:'s3.2f';l:$800;p:$1000;crc:$12d7fc3e),(n:'s4.2h';l:$800;p:$1800;crc:$b59360eb),
        (n:'s5.2j';l:$800;p:$2000;crc:$4919a91c),(n:'s6.2l';l:$800;p:$2800;crc:$26a4547b),
        (n:'s7.2m';l:$800;p:$3000;crc:$0bb49470),(n:'s8.2p';l:$800;p:$3800;crc:$6a5740e5),
        (n:'c2.5f';l:$800;p:0;crc:$4708845b),(n:'c1.5h';l:$800;p:$800;crc:$11fd2887),
        (n:'ot1.5c';l:$800;p:0;crc:$bcd297f0),(n:'ot2.5d';l:$800;p:$800;crc:$de7912da),
        (n:'ot3.5e';l:$800;p:$1000;crc:$ba2fa933),(n:'c01s.6e';l:$20;p:0;crc:$4e3caeab),());
        //Super Cobra
        scobra:array[0..12] of tipo_roms=(
        (n:'epr1265.2c';l:$1000;p:0;crc:$a0744b3f),(n:'2e';l:$1000;p:$1000;crc:$8e7245cd),
        (n:'epr1267.2f';l:$1000;p:$2000;crc:$47a4e6fb),(n:'2h';l:$1000;p:$3000;crc:$7244f21c),
        (n:'epr1269.2j';l:$1000;p:$4000;crc:$e1f8a801),(n:'2l';l:$1000;p:$5000;crc:$d52affde),
        (n:'5c';l:$800;p:0;crc:$d4346959),(n:'5d';l:$800;p:$800;crc:$cc025d95),
        (n:'epr1274.5h';l:$800;p:0;crc:$64d113b4),(n:'epr1273.5f';l:$800;p:$800;crc:$a96316d3),
        (n:'5e';l:$800;p:$1000;crc:$1628c53f),(n:'82s123.6e';l:$20;p:0;crc:$9b87f90d),());
        //Frogger
        frogger:array[0..9] of tipo_roms=(
        (n:'frogger.26';l:$1000;p:0;crc:$597696d6),(n:'frogger.27';l:$1000;p:$1000;crc:$b6e6fcc3),
        (n:'frogger.607';l:$800;p:0;crc:$05f7d883),(n:'frogger.606';l:$800;p:$800;crc:$f524ee30),
        (n:'frsm3.7';l:$1000;p:$2000;crc:$aca22ae0),(n:'pr-91.6l';l:32;p:0;crc:$413703bf),
        (n:'frogger.608';l:$800;p:0;crc:$e8ab0256),(n:'frogger.609';l:$800;p:$800;crc:$7380a48f),
        (n:'frogger.610';l:$800;p:$1000;crc:$31d7eb27),());
        //Amidar
        amidar_roms:array[0..10] of tipo_roms=(
        (n:'1.2c';l:$1000;p:0;crc:$621b74de),(n:'2.2e';l:$1000;p:$1000;crc:$38538b98),
        (n:'3.2f';l:$1000;p:$2000;crc:$099ecb24),(n:'4.2h';l:$1000;p:$3000;crc:$ba149a93),
        (n:'5.2j';l:$1000;p:$4000;crc:$eecc1abf),(n:'c2.5f';l:$800;p:0;crc:$2cfe5ede),
        (n:'c2.5d';l:$800;p:$800;crc:$57c4fd0d),(n:'amidar.clr';l:32;p:0;crc:$f940dcc3),
        (n:'s1.5c';l:$1000;p:0;crc:$8ca7b750),(n:'s2.5d';l:$1000;p:$1000;crc:$9b5bdc0a),());
        dkong:array[0..13] of tipo_roms=(
        (n:'c_5et_g.bin';l:$1000;p:0;crc:$ba70b88b),(n:'c_5ct_g.bin';l:$1000;p:$1000;crc:$5ec461ec),
        (n:'c_5bt_g.bin';l:$1000;p:$2000;crc:$1c97d324),(n:'c_5at_g.bin';l:$1000;p:$3000;crc:$b9005ac0),
        (n:'c-2k.bpr';l:$100;p:0;crc:$e273ede5),(n:'c-2j.bpr';l:$100;p:$100;crc:$d6412358),
        (n:'v-5e.bpr';l:$100;p:$200;crc:$b869b8f5),
        (n:'v_5h_b.bin';l:$800;p:0;crc:$12c8c95d),(n:'v_3pt.bin';l:$800;p:$800;crc:$15e9c5e9),
        (n:'l_4m_b.bin';l:$800;p:0;crc:$59f8054d),(n:'l_4n_b.bin';l:$800;p:$800;crc:$672e4714),
        (n:'l_4r_b.bin';l:$800;p:$1000;crc:$feaa59ee),(n:'l_4s_b.bin';l:$800;p:$1800;crc:$20f2ef7e),());
        //Donkey Kong Jr.
        dkongjr:array[0..12] of tipo_roms=(
        (n:'dkj.5b';l:$2000;p:0;crc:$dea28158),(n:'dkj.5c';l:$2000;p:$2000;crc:$6fb5faf6),
        (n:'v-2n.bpr';l:$100;p:$200;crc:$dbf185bf),(n:'dkj.5e';l:$2000;p:$4000;crc:$d042b6a8),
        (n:'c-2e.bpr';l:$100;p:0;crc:$463dc7ad),(n:'c-2f.bpr';l:$100;p:$100;crc:$47ba0042),
        (n:'dkj.3n';l:$1000;p:0;crc:$8d51aca9),(n:'dkj.3p';l:$1000;p:$1000;crc:$4ef64ba5),
        (n:'v_7c.bin';l:$800;p:0;crc:$dc7f4164),(n:'v_7d.bin';l:$800;p:$800;crc:$0ce7dcf6),
        (n:'v_7e.bin';l:$800;p:$1000;crc:$24d1ff17),(n:'v_7f.bin';l:$800;p:$1800;crc:$0f8c083f),());
        //Donkey Kong 3
        dkong3:array[0..15] of tipo_roms=(
        (n:'dk3c.7b';l:$2000;p:0;crc:$38d5f38e),(n:'dk3c.7c';l:$2000;p:$2000;crc:$c9134379),
        (n:'dk3c.7d';l:$2000;p:$4000;crc:$d22e2921),(n:'dk3c.7e';l:$2000;p:$8000;crc:$615f14b7),
        (n:'dkc1-c.1d';l:$200;p:0;crc:$df54befc),(n:'dkc1-c.1c';l:$200;p:$200;crc:$66a77f40),
        (n:'dkc1-v.2n';l:$100;p:$400;crc:$50e33434),
        (n:'dk3v.3n';l:$1000;p:0;crc:$415a99c7),(n:'dk3v.3p';l:$1000;p:$1000;crc:$25744ea0),
        (n:'dk3v.7c';l:$1000;p:0;crc:$8ffa1737),(n:'dk3v.7d';l:$1000;p:$1000;crc:$9ac84686),
        (n:'dk3v.7e';l:$1000;p:$2000;crc:$0c0af3fb),(n:'dk3v.7f';l:$1000;p:$3000;crc:$55c58662),
        (n:'dk3c.5l';l:$2000;p:$e000;crc:$7ff88885),(n:'dk3c.6h';l:$2000;p:$e000;crc:$36d7200c),());
        blktiger:array[0..16] of tipo_roms=(
        (n:'bdu-01a.5e';l:$8000;p:0;crc:$a8f98f22),(n:'bdu-02a.6e';l:$10000;p:$8000;crc:$7bef96e8),
        (n:'bdu-03a.8e';l:$10000;p:$18000;crc:$4089e157),(n:'bd-04.9e';l:$10000;p:$28000;crc:$ed6af6ec),
        (n:'bd-05.10e';l:$10000;p:$38000;crc:$ae59b72e),(n:'bd-15.2n';l:$8000;p:0;crc:$70175d78),
        (n:'bd-08.5a';l:$10000;p:0;crc:$e2f17438),(n:'bd-07.4a';l:$10000;p:$10000;crc:$5fccbd27),
        (n:'bd-10.9a';l:$10000;p:$20000;crc:$fc33ccc6),(n:'bd-09.8a';l:$10000;p:$30000;crc:$f449de01),
        (n:'bd-12.5b';l:$10000;p:0;crc:$c4524993),(n:'bd-11.4b';l:$10000;p:$10000;crc:$7932c86f),
        (n:'bd-14.9b';l:$10000;p:$20000;crc:$dc49593a),(n:'bd-13.8b';l:$10000;p:$30000;crc:$7ed7a122),
        (n:'bd-06.1l';l:$8000;p:0;crc:$2cf54274),(n:'bd.6k';l:$1000;p:0;crc:$ac7d14f1),());
        //Green Beret
        gberet:array[0..11] of tipo_roms=(
        (n:'577l03.10c';l:$4000;p:0;crc:$ae29e4ff),(n:'577l02.8c';l:$4000;p:$4000;crc:$240836a5),
        (n:'577l01.7c';l:$4000;p:$8000;crc:$41fa3e1f),
        (n:'577h09.2f';l:$20;p:0;crc:$c15e7c80),(n:'577h11.6f';l:$100;p:$20;crc:$2a1a992b),
        (n:'577h10.5f';l:$100;p:$120;crc:$e9de1e53),(n:'577l07.3f';l:$4000;p:0;crc:$4da7bd1b),
        (n:'577l06.5e';l:$4000;p:0;crc:$0f1cb0ca),(n:'577l05.4e';l:$4000;p:$4000;crc:$523a8b66),
        (n:'577l08.4f';l:$4000;p:$8000;crc:$883933a4),(n:'577l04.3e';l:$4000;p:$c000;crc:$ccecda4c),());
        //Mr Goemon
        mrgoemon:array[0..8] of tipo_roms=(
        (n:'621d01.10c';l:$8000;p:0;crc:$b2219c56),(n:'621d02.12c';l:$8000;p:$8000;crc:$c3337a97),
        (n:'621a06.5f';l:$20;p:0;crc:$7c90de5f),(n:'621a08.7f';l:$100;p:$20;crc:$2fb244dd),
        (n:'621a07.6f';l:$100;p:$120;crc:$3980acdc),(n:'621a05.6d';l:$4000;p:0;crc:$f0a6dfc5),
        (n:'621d03.4d';l:$8000;p:0;crc:$66f2b973),(n:'621d04.5d';l:$8000;p:$8000;crc:$47df6301),());
        commando:array[0..19] of tipo_roms=(
        (n:'cm04.9m';l:$8000;p:0;crc:$8438b694),(n:'cm03.8m';l:$4000;p:$8000;crc:$35486542),
        (n:'cm02.9f';l:$4000;p:0;crc:$f9cc4a74),
        (n:'vtb1.1d';l:$100;p:0;crc:$3aba15a1),(n:'vtb2.2d';l:$100;p:$100;crc:$88865754),
        (n:'vtb3.3d';l:$100;p:$200;crc:$4c14c3f6),(n:'vt01.5d';l:$4000;p:0;crc:$505726e0),
        (n:'vt05.7e';l:$4000;p:0;crc:$79f16e3d),(n:'vt06.8e';l:$4000;p:$4000;crc:$26fee521),
        (n:'vt07.9e';l:$4000;p:$8000;crc:$ca88bdfd),(n:'vt08.7h';l:$4000;p:$c000;crc:$2019c883),
        (n:'vt09.8h';l:$4000;p:$10000;crc:$98703982),(n:'vt10.9h';l:$4000;p:$14000;crc:$f069d2f8),
        (n:'vt11.5a';l:$4000;p:0;crc:$7b2e1b48),(n:'vt12.6a';l:$4000;p:$4000;crc:$81b417d3),
        (n:'vt13.7a';l:$4000;p:$8000;crc:$5612dbd2),(n:'vt14.8a';l:$4000;p:$c000;crc:$2b2dee36),
        (n:'vt15.9a';l:$4000;p:$10000;crc:$de70babf),(n:'vt16.10a';l:$4000;p:$14000;crc:$14178237),());
        gng:array[0..17] of tipo_roms=(
        (n:'gg3.bin';l:$8000;p:$8000;crc:$9e01c65e),(n:'gg4.bin';l:$4000;p:$4000;crc:$66606beb),
        (n:'gg5.bin';l:$8000;p:$10000;crc:$d6397b2b),(n:'gg1.bin';l:$4000;p:0;crc:$ecfccf07),
        (n:'gg11.bin';l:$4000;p:0;crc:$ddd56fa9),(n:'gg10.bin';l:$4000;p:$4000;crc:$7302529d),(n:'gg9.bin';l:$4000;p:$8000;crc:$20035bda),
        (n:'gg8.bin';l:$4000;p:$c000;crc:$f12ba271),(n:'gg7.bin';l:$4000;p:$10000;crc:$e525207d),(n:'gg6.bin';l:$4000;p:$14000;crc:$2d77e9b2),
        (n:'gg17.bin';l:$4000;p:0;crc:$93e50a8f),(n:'gg16.bin';l:$4000;p:$4000;crc:$06d7e5ca),(n:'gg15.bin';l:$4000;p:$8000;crc:$bc1fe02d),
        (n:'gg14.bin';l:$4000;p:$c000;crc:$6aaf12f9),(n:'gg13.bin';l:$4000;p:$10000;crc:$e80c3fca),(n:'gg12.bin';l:$4000;p:$14000;crc:$7780a925),
        (n:'gg2.bin';l:$8000;p:0;crc:$615f5b6f),());
        mikie:array[0..14] of tipo_roms=(
        (n:'n14.11c';l:$2000;p:$6000;crc:$f698e6dd),(n:'o13.12a';l:$4000;p:$8000;crc:$826e7035),
        (n:'o17.12d';l:$4000;p:$c000;crc:$161c25c8),(n:'n10.6e';l:$2000;p:0;crc:$2cf9d670),
        (n:'001.f1';l:$4000;p:0;crc:$a2ba0df5),(n:'003.f3';l:$4000;p:$4000;crc:$9775ab32),
        (n:'005.h1';l:$4000;p:$8000;crc:$ba44aeef),(n:'007.h3';l:$4000;p:$c000;crc:$31afc153),
        (n:'d19.1i';l:$100;p:$0;crc:$8b83e7cf),(n:'d21.3i';l:$100;p:$100;crc:$3556304a),
        (n:'d20.2i';l:$100;p:$200;crc:$676a0669),(n:'d22.12h';l:$100;p:$300;crc:$872be05c),
        (n:'o11.8i';l:$4000;p:0;crc:$3c82aaf3),(n:'d18.f9';l:$100;p:$400;crc:$7396b374),());
        shaolins:array[0..12] of tipo_roms=(
        (n:'477-l03.d9';l:$2000;p:$6000;crc:$2598dfdd),(n:'477-l04.d10';l:$4000;p:$8000;crc:$0cf0351a),
        (n:'shaolins.a10';l:$2000;p:0;crc:$ff18a7ed),(n:'shaolins.a11';l:$2000;p:$2000;crc:$5f53ae61),
        (n:'477-k02.h15';l:$4000;p:0;crc:$b94e645b),(n:'477-k01.h14';l:$4000;p:$4000;crc:$61bbf797),
        (n:'477j10.a12';l:$100;p:$0;crc:$b09db4b4),(n:'477j11.a13';l:$100;p:$100;crc:$270a2bf3),
        (n:'477j12.a14';l:$100;p:$200;crc:$83e95ea8),(n:'477j09.b8';l:$100;p:$300;crc:$aa900724),
        (n:'477-l05.d11';l:$4000;p:$c000;crc:$654037f8),(n:'477j08.f16';l:$100;p:$400;crc:$80009cf5),());
        yiear:array[0..10] of tipo_roms=(
        (n:'i08.10d';l:$4000;p:$8000;crc:$e2d7458b),(n:'i07.8d';l:$4000;p:$c000;crc:$7db7442e),(n:'g16_1.bin';l:$2000;p:0;crc:$b68fd91d),
        (n:'g15_2.bin';l:$2000;p:$2000;crc:$d9b167c6),
        (n:'g04_5.bin';l:$4000;p:0;crc:$45109b29),(n:'g03_6.bin';l:$4000;p:$4000;crc:$1d650790),
        (n:'g06_3.bin';l:$4000;p:$8000;crc:$e6aa945b),(n:'g05_4.bin';l:$4000;p:$c000;crc:$cc187c22),
        (n:'yiear.clr';l:$20;p:$0;crc:$c283d71f),(n:'a12_9.bin';l:$2000;p:$0;crc:$f75a1539),());
        asteroid:array[0..4] of tipo_roms=(
        (n:'035145-04e.ef2';l:$800;p:$6800;crc:$b503eaf7),(n:'035144-04e.h2';l:$800;p:$7000;crc:$25233192),
        (n:'035143-02.j2';l:$800;p:$7800;crc:$312caa02),(n:'035127-02.np3';l:$800;p:$5000;crc:$8b71fd9e),());
        sonson:array[0..16] of tipo_roms=(
        (n:'ss.01e';l:$4000;p:$4000;crc:$cd40cc54),(n:'ss.02e';l:$4000;p:$8000;crc:$c3476527),
        (n:'ss.03e';l:$4000;p:$c000;crc:$1fd0e729),(n:'ss_6.c11';l:$2000;p:$e000;crc:$1135c48a),
        (n:'ss_7.b6';l:$2000;p:0;crc:$990890b1),(n:'ss_8.b5';l:$2000;p:$2000;crc:$9388ff82),
        (n:'ss_9.m5';l:$2000;p:0;crc:$8cb1cacf),(n:'ss_10.m6';l:$2000;p:$2000;crc:$f802815e),
        (n:'ss_11.m3';l:$2000;p:$4000;crc:$4dbad88a),(n:'ss_12.m4';l:$2000;p:$6000;crc:$aa05e687),
        (n:'ss_13.m1';l:$2000;p:$8000;crc:$66119bfa),(n:'ss_14.m2';l:$2000;p:$a000;crc:$e14ef54e),
        (n:'ssb4.b2';l:$20;p:0;crc:$c8eaf234),(n:'ssb5.b1';l:$20;p:$20;crc:$0e434add),
        (n:'ssb2.c4';l:$100;p:$40;crc:$c53321c6),(n:'ssb3.h7';l:$100;p:$140;crc:$7d2c324a),());
        starforc:array[0..18] of tipo_roms=(
        (n:'3.3p';l:$4000;p:0;crc:$8ba27691),(n:'2.3mn';l:$4000;p:$4000;crc:$0fc4d2d6),
        (n:'7.2fh';l:$1000;p:0;crc:$f4803339),(n:'8.3fh';l:$1000;p:$1000;crc:$96979684),
        (n:'9.3fh';l:$1000;p:$2000;crc:$eead1d5c),(n:'15.10jk';l:$2000;p:0;crc:$c3bda12f),
        (n:'14.9jk';l:$2000;p:$2000;crc:$9e9384fe),(n:'13.8jk';l:$2000;p:$4000;crc:$84603285),
        (n:'12.10de';l:$2000;p:0;crc:$fdd9e38b),(n:'11.9de';l:$2000;p:$2000;crc:$668aea14),
        (n:'10.8de';l:$2000;p:$4000;crc:$c62a19c1),(n:'18.10pq';l:$1000;p:0;crc:$6455c3ad),
        (n:'17.9pq';l:$1000;p:$1000;crc:$68c60d0f),(n:'16.8pq';l:$1000;p:$2000;crc:$ce20b469),
        (n:'1.3hj';l:$2000;p:0;crc:$2735bb22),(n:'6.10lm';l:$4000;p:0;crc:$5468a21d),
        (n:'5.9lm';l:$4000;p:$4000;crc:$f71717f8),(n:'4.8lm';l:$4000;p:$8000;crc:$dd9d68a4),());
        //Rygar
        rygar:array[0..18] of tipo_roms=(
        (n:'5.5p';l:$8000;p:0;crc:$062cd55d),(n:'cpu_5m.bin';l:$4000;p:$8000;crc:$7ac5191b),
        (n:'cpu_5j.bin';l:$8000;p:$10000;crc:$ed76d606),(n:'cpu_8k.bin';l:$8000;p:0;crc:$4d482fb6),
        (n:'vid_6p.bin';l:$8000;p:0;crc:$9eae5f8e),(n:'vid_6o.bin';l:$8000;p:$8000;crc:$5a10a396),
        (n:'vid_6n.bin';l:$8000;p:$10000;crc:$7b12cf3f),(n:'vid_6l.bin';l:$8000;p:$18000;crc:$3cea7eaa),
        (n:'vid_6f.bin';l:$8000;p:0;crc:$9840edd8),(n:'vid_6e.bin';l:$8000;p:$8000;crc:$ff65e074),
        (n:'vid_6c.bin';l:$8000;p:$10000;crc:$89868c85),(n:'vid_6b.bin';l:$8000;p:$18000;crc:$35389a7b),
        (n:'cpu_1f.bin';l:$4000;p:0;crc:$3cc98c5a),(n:'cpu_4h.bin';l:$2000;p:0;crc:$e4a2fa87),
        (n:'vid_6k.bin';l:$8000;p:0;crc:$aba6db9e),(n:'vid_6j.bin';l:$8000;p:$8000;crc:$ae1f2ed6),
        (n:'vid_6h.bin';l:$8000;p:$10000;crc:$46d9e7df),(n:'vid_6g.bin';l:$8000;p:$18000;crc:$45839c9a),());
        //Silkworm
        silkworm:array[0..17] of tipo_roms=(
        (n:'silkworm.4';l:$10000;p:0;crc:$a5277cce),(n:'silkworm.5';l:$10000;p:$10000;crc:$a6c7bb51),
        (n:'silkworm.2';l:$8000;p:0;crc:$e80a1cd9),
        (n:'silkworm.10';l:$10000;p:0;crc:$8c7138bb),(n:'silkworm.11';l:$10000;p:$10000;crc:$6c03c476),
        (n:'silkworm.12';l:$10000;p:$20000;crc:$bb0f568f),(n:'silkworm.13';l:$10000;p:$30000;crc:$773ad0a4),
        (n:'silkworm.14';l:$10000;p:0;crc:$409df64b),(n:'silkworm.15';l:$10000;p:$10000;crc:$6e4052c9),
        (n:'silkworm.16';l:$10000;p:$20000;crc:$9292ed63),(n:'silkworm.17';l:$10000;p:$30000;crc:$3fa4563d),
        (n:'silkworm.1';l:$8000;p:0;crc:$5b553644),(n:'silkworm.3';l:$8000;p:0;crc:$b589f587),
        (n:'silkworm.6';l:$10000;p:0;crc:$1138d159),(n:'silkworm.7';l:$10000;p:$10000;crc:$d96214f7),
        (n:'silkworm.8';l:$10000;p:$20000;crc:$0494b38e),(n:'silkworm.9';l:$10000;p:$30000;crc:$8ce3cdf5),());
        //Pitfall 2
        pitfall2:array[0..13] of tipo_roms=(
        (n:'epr6456a.116';l:$4000;p:0;crc:$bcc8406b),(n:'epr6457a.109';l:$4000;p:$4000;crc:$a016fd2a),
        (n:'epr6474a.62';l:$2000;p:0;crc:$9f1711b9),(n:'epr6473a.61';l:$2000;p:$2000;crc:$8e53b8dd),
        (n:'epr6472a.64';l:$2000;p:$4000;crc:$e0f34a11),(n:'epr6471a.63';l:$2000;p:$6000;crc:$d5bc805c),
        (n:'epr6470a.66';l:$2000;p:$8000;crc:$1439729f),(n:'epr6469a.65';l:$2000;p:$a000;crc:$e4ac6921),
        (n:'epr6458a.96';l:$4000;p:$8000;crc:$5c30b3e8),(n:'epr-6462.120';l:$2000;p:0;crc:$86bb9185),
        (n:'epr6454a.117';l:$4000;p:0;crc:$a5d96780),(n:'epr-6455.05';l:$4000;p:$4000;crc:$32ee64a1),
        (n:'pr-5317.76';l:$100;p:0;crc:$648350b8),());
        //Teddy Boy Blues
        teddybb:array[0..15] of tipo_roms=(
        (n:'epr-6768.116';l:$4000;p:0;crc:$5939817e),(n:'epr-6769.109';l:$4000;p:$4000;crc:$14a98ddd),
        (n:'epr-6747.62';l:$2000;p:0;crc:$a0e5aca7),(n:'epr-6746.61';l:$2000;p:$2000;crc:$cdb77e51),
        (n:'epr-6745.64';l:$2000;p:$4000;crc:$0cab75c3),(n:'epr-6744.63';l:$2000;p:$6000;crc:$0ef8d2cd),
        (n:'epr-6743.66';l:$2000;p:$8000;crc:$c33062b5),(n:'epr-6742.65';l:$2000;p:$a000;crc:$c457e8c5),
        (n:'epr-6770.96';l:$4000;p:$8000;crc:$67b0c7c2),(n:'epr6748x.120';l:$2000;p:0;crc:$c2a1b89d),
        (n:'epr-6735.117';l:$4000;p:0;crc:$1be35a97),(n:'epr-6737.04';l:$4000;p:$4000;crc:$6b53aa7a),
        (n:'epr-6736.110';l:$4000;p:$8000;crc:$565c25d0),(n:'epr-6738.05';l:$4000;p:$c000;crc:$e116285f),
        (n:'pr-5317.76';l:$100;p:0;crc:$648350b8),());
        //Wonder Boy
        wboy:array[0..15] of tipo_roms=(
        (n:'epr-7489.116';l:$4000;p:0;crc:$130f4b70),(n:'epr-7490.109';l:$4000;p:$4000;crc:$9e656733),
        (n:'epr-7497.62';l:$2000;p:0;crc:$08d609ca),(n:'epr-7496.61';l:$2000;p:$2000;crc:$6f61fdf1),
        (n:'epr-7495.64';l:$2000;p:$4000;crc:$6a0d2c2d),(n:'epr-7494.63';l:$2000;p:$6000;crc:$a8e281c7),
        (n:'epr-7493.66';l:$2000;p:$8000;crc:$89305df4),(n:'epr-7492.65';l:$2000;p:$a000;crc:$60f806b1),
        (n:'epr-7491.96';l:$4000;p:$8000;crc:$1f7d0efe),(n:'epr-7498.120';l:$2000;p:0;crc:$78ae1e7b),
        (n:'epr-7485.117';l:$4000;p:0;crc:$c2891722),(n:'epr-7487.04';l:$4000;p:$4000;crc:$2d3a421b),
        (n:'epr-7486.110';l:$4000;p:$8000;crc:$8d622c50),(n:'epr-7488.05';l:$4000;p:$c000;crc:$007c2f1b),
        (n:'pr-5317.76';l:$100;p:0;crc:$648350b8),());
        //Mr Viking
        mrviking:array[0..16] of tipo_roms=(
        (n:'epr-5873.129';l:$2000;p:0;crc:$14d21624),(n:'epr-5874.130';l:$2000;p:$2000;crc:$6df7de87),
        (n:'epr-5875.131';l:$2000;p:$4000;crc:$ac226100),(n:'epr-5876.132';l:$2000;p:$6000;crc:$e77db1dc),
        (n:'epr-5755.133';l:$2000;p:$8000;crc:$edd62ae1),(n:'epr-5756.134';l:$2000;p:$a000;crc:$11974040),
        (n:'epr-5749.86';l:$4000;p:$0;crc:$e24682cd),(n:'epr-5750.93';l:$4000;p:$4000;crc:$6564d1ad),
        (n:'epr-5762.82';l:$2000;p:0;crc:$4a91d08a),(n:'epr-5761.65';l:$2000;p:$2000;crc:$f7d61b65),
        (n:'epr-5760.81';l:$2000;p:$4000;crc:$95045820),(n:'epr-5759.64';l:$2000;p:$6000;crc:$5f9bae4e),
        (n:'epr-5758.80';l:$2000;p:$8000;crc:$808ee706),(n:'epr-5757.63';l:$2000;p:$a000;crc:$480f7074),
        (n:'epr-5763.3';l:$2000;p:0;crc:$d712280d),(n:'pr-5317.106';l:$100;p:0;crc:$648350b8),());
        //Sega Ninja
        seganinj:array[0..15] of tipo_roms=(
        (n:'epr-.116';l:$4000;p:0;crc:$a5d0c9d0),(n:'epr-.109';l:$4000;p:$4000;crc:$b9e6775c),
        (n:'epr-6546.117';l:$4000;p:$0;crc:$a4785692),(n:'epr-6548.04';l:$4000;p:$4000;crc:$bdf278c1),
        (n:'epr-6547.110';l:$4000;p:$8000;crc:$34451b08),(n:'epr-6549.05';l:$4000;p:$c000;crc:$d2057668),
        (n:'epr-6552.96';l:$4000;p:$8000;crc:$f2eeb0d8),(n:'epr-6559.120';l:$2000;p:0;crc:$5a1570ee),
        (n:'epr-6558.62';l:$2000;p:0;crc:$2af9eaeb),(n:'epr-6592.61';l:$2000;p:$2000;crc:$7804db86),
        (n:'epr-6556.64';l:$2000;p:$4000;crc:$79fd26f7),(n:'epr-6590.63';l:$2000;p:$6000;crc:$bf858cad),
        (n:'epr-6554.66';l:$2000;p:$8000;crc:$5ac9d205),(n:'epr-6588.65';l:$2000;p:$a000;crc:$dc931dbb),
        (n:'pr-5317.76';l:$100;p:0;crc:$648350b8),());
        //Up and Down
        upndown:array[0..16] of tipo_roms=(
        (n:'epr5516a.129';l:$2000;p:0;crc:$038c82da),(n:'epr5517a.130';l:$2000;p:$2000;crc:$6930e1de),
        (n:'epr-5518.131';l:$2000;p:$4000;crc:$2a370c99),(n:'epr-5519.132';l:$2000;p:$6000;crc:$9d664a58),
        (n:'epr-5520.133';l:$2000;p:$8000;crc:$208dfbdf),(n:'epr-5521.134';l:$2000;p:$a000;crc:$e7b8d87a),
        (n:'epr-5514.86';l:$4000;p:$0;crc:$fcc0a88b),(n:'epr-5515.93';l:$4000;p:$4000;crc:$60908838),
        (n:'epr-5527.82';l:$2000;p:0;crc:$b2d616f1),(n:'epr-5526.65';l:$2000;p:$2000;crc:$8a8b33c2),
        (n:'epr-5525.81';l:$2000;p:$4000;crc:$e749c5ef),(n:'epr-5524.64';l:$2000;p:$6000;crc:$8b886952),
        (n:'epr-5523.80';l:$2000;p:$8000;crc:$dede35d9),(n:'epr-5522.63';l:$2000;p:$a000;crc:$5e6d9dff),
        (n:'epr-5535.3';l:$2000;p:0;crc:$cf4e4c45),(n:'pr-5317.106';l:$100;p:0;crc:$648350b8),());
        //Flicky
        flicky:array[0..12] of tipo_roms=(
        (n:'epr5978a.116';l:$4000;p:0;crc:$296f1492),(n:'epr5979a.109';l:$4000;p:$4000;crc:$64b03ef9),
        (n:'epr-5855.117';l:$4000;p:$0;crc:$b5f894a1),(n:'epr-5856.110';l:$4000;p:$4000;crc:$266af78f),
        (n:'epr-5868.62';l:$2000;p:0;crc:$7402256b),(n:'epr-5867.61';l:$2000;p:$2000;crc:$2f5ce930),
        (n:'epr-5866.64';l:$2000;p:$4000;crc:$967f1d9a),(n:'epr-5865.63';l:$2000;p:$6000;crc:$03d9a34c),
        (n:'epr-5864.66';l:$2000;p:$8000;crc:$e659f358),(n:'epr-5863.65';l:$2000;p:$a000;crc:$a496ca15),
        (n:'epr-5869.120';l:$2000;p:0;crc:$6d220d4e),(n:'pr-5317.76';l:$100;p:0;crc:$648350b8),());
        wbml:array[0..15] of tipo_roms=(
        (n:'wbml.01';l:$10000;p:0;crc:$66482638),(n:'wbml.02';l:$10000;p:$10000;crc:$48746bb6),
        (n:'wbml.03';l:$10000;p:$20000;crc:$d57ba8aa),
        (n:'wbml.08';l:$8000;p:0;crc:$bbea6afe),(n:'wbml.09';l:$8000;p:$8000;crc:$77567d41),
        (n:'wbml.10';l:$8000;p:$10000;crc:$a52ffbdd),(n:'epr11037.126';l:$8000;p:0;crc:$7a4ee585),
        (n:'epr11028.87';l:$8000;p:0;crc:$af0b3972),(n:'epr11027.86';l:$8000;p:$8000;crc:$277d8f1d),
        (n:'epr11030.89';l:$8000;p:$10000;crc:$f05ffc76),(n:'epr11029.88';l:$8000;p:$18000;crc:$cedc9c61),
        (n:'pr11026.20';l:$100;p:0;crc:$27057298),(n:'pr11025.14';l:$100;p:$100;crc:$41e4d86b),
        (n:'pr11024.8';l:$100;p:$200;crc:$08d71954),(n:'pr5317.37';l:$100;p:0;crc:$648350b8),());
        choplift:array[0..15] of tipo_roms=(
        (n:'epr-7152.ic90';l:$8000;p:0;crc:$fe49d83e),(n:'epr-7153.ic91';l:$8000;p:$8000;crc:$48697666),
        (n:'epr-7154.ic92';l:$8000;p:$10000;crc:$56d6222a),
        (n:'epr-7127.ic4';l:$8000;p:0;crc:$1e708f6d),(n:'epr-7128.ic5';l:$8000;p:$8000;crc:$b922e787),
        (n:'epr-7129.ic6';l:$8000;p:$10000;crc:$bd3b6e6e),(n:'epr-7130.ic126';l:$8000;p:0;crc:$346af118),
        (n:'epr-7121.ic87';l:$8000;p:0;crc:$f2b88f73),(n:'epr-7120.ic86';l:$8000;p:$8000;crc:$517d7fd3),
        (n:'epr-7123.ic89';l:$8000;p:$10000;crc:$8f16a303),(n:'epr-7122.ic88';l:$8000;p:$18000;crc:$7c93f160),
        (n:'pr7119.ic20';l:$100;p:0;crc:$b2a8260f),(n:'pr7118.ic14';l:$100;p:$100;crc:$693e20c7),
        (n:'pr7117.ic8';l:$100;p:$200;crc:$4124307e),(n:'pr5317.ic28';l:$100;p:0;crc:$648350b8),());
        pooyan:array[0..13] of tipo_roms=(
        (n:'1.4a';l:$2000;p:0;crc:$bb319c63),(n:'2.5a';l:$2000;p:$2000;crc:$a1463d98),
        (n:'3.6a';l:$2000;p:$4000;crc:$fe1a9e08),(n:'4.7a';l:$2000;p:$6000;crc:$9e0f9bcc),
        (n:'pooyan.pr1';l:$20;p:0;crc:$a06a6d0e),(n:'pooyan.pr2';l:$100;p:$20;crc:$82748c0b),
        (n:'pooyan.pr3';l:$100;p:$120;crc:$8cd4cd60),
        (n:'8.10g';l:$1000;p:0;crc:$931b29eb),(n:'7.9g';l:$1000;p:$1000;crc:$bbe6d6e4),
        (n:'xx.7a';l:$1000;p:0;crc:$fbe2b368),(n:'xx.8a';l:$1000;p:$1000;crc:$e1795b3d),
        (n:'6.9a';l:$1000;p:0;crc:$b2d8c121),(n:'5.8a';l:$1000;p:$1000;crc:$1097c2b6),());
        //Jungler
        jungler:array[0..10] of tipo_roms=(
        (n:'jungr1';l:$1000;p:0;crc:$5bd6ad15),(n:'jungr2';l:$1000;p:$1000;crc:$dc99f1e3),
        (n:'jungr3';l:$1000;p:$2000;crc:$3dcc03da),(n:'jungr4';l:$1000;p:$3000;crc:$f92e9940),
        (n:'18s030.8b';l:$20;p:0;crc:$55a7e6d1),(n:'tbp24s10.9d';l:$100;p:$20;crc:$d223f7b8),
        (n:'5k';l:$800;p:0;crc:$924262bf),(n:'5m';l:$800;p:$800;crc:$131a08ac),
        (n:'1b';l:$1000;p:0;crc:$f86999c3),(n:'82s129.10g';l:$100;p:0;crc:$c59c51b7),());
        //Rally X
        rallyx:array[0..9] of tipo_roms=(
        (n:'1b';l:$1000;p:0;crc:$5882700d),(n:'rallyxn.1e';l:$1000;p:$1000;crc:$ed1eba2b),
        (n:'rallyxn.1h';l:$1000;p:$2000;crc:$4f98dd1c),(n:'rallyxn.1k';l:$1000;p:$3000;crc:$9aacccf0),
        (n:'rx-1.11n';l:$20;p:0;crc:$c7865434),(n:'rx-7.8p';l:$100;p:$20;crc:$834d4fda),
        (n:'8e';l:$1000;p:0;crc:$277c1de5),(n:'rx-5.3p';l:$100;p:0;crc:$4bad7017),
        (n:'rx1-6.8m';l:$100;p:0;crc:$3c16f62c),());
        //New Rally X
        nrallyx:array[0..10] of tipo_roms=(
        (n:'nrx_prg1.1d';l:$1000;p:0;crc:$ba7de9fc),(n:'nrx_prg2.1e';l:$1000;p:$1000;crc:$eedfccae),
        (n:'nrx_prg3.1k';l:$1000;p:$2000;crc:$b4d5d34a),(n:'nrx_prg4.1l';l:$1000;p:$3000;crc:$7da5496d),
        (n:'nrx1-1.11n';l:$20;p:0;crc:$a0a49017),(n:'nrx1-7.8p';l:$100;p:$20;crc:$4e46f485),
        (n:'nrx_chg1.8e';l:$800;p:0;crc:$1fff38a4),(n:'nrx_chg2.8d';l:$800;p:$800;crc:$85d9fffd),
        (n:'rx1-5.3p';l:$100;p:0;crc:$4bad7017),(n:'rx1-6.8m';l:$100;p:0;crc:$3c16f62c),());
        citycon:array[0..13] of tipo_roms=(
        (n:'c10';l:$4000;p:$4000;crc:$ae88b53c),(n:'c11';l:$8000;p:$8000;crc:$139eb1aa),
        (n:'c1';l:$8000;p:$8000;crc:$1fad7589),(n:'c4';l:$2000;p:0;crc:$a6b32fc6),
        (n:'c12';l:$2000;p:0;crc:$08eaaccd),(n:'c13';l:$2000;p:$2000;crc:$1819aafb),
        (n:'c9';l:$8000;p:0;crc:$8aeb47e6),(n:'c8';l:$4000;p:$8000;crc:$0d7a1eeb),
        (n:'c6';l:$8000;p:$c000;crc:$2246fe9d),(n:'c7';l:$4000;p:$14000;crc:$e8b97de9),
        (n:'c2';l:$8000;p:0;crc:$f2da4f23),(n:'c3';l:$4000;p:$8000;crc:$7ef3ac1b),
        (n:'c5';l:$2000;p:$c000;crc:$c03d8b1b),());
        btime:array[0..15] of tipo_roms=(
        (n:'aa04.9b';l:$1000;p:$c000;crc:$368a25b5),(n:'aa06.13b';l:$1000;p:$d000;crc:$b4ba400d),
        (n:'aa05.10b';l:$1000;p:$e000;crc:$8005bffa),(n:'aa07.15b';l:$1000;p:$f000;crc:$086440ad),
        (n:'aa12.7k';l:$1000;p:$0000;crc:$c4617243),(n:'ab13.9k';l:$1000;p:$1000;crc:$ac01042f),
        (n:'ab10.10k';l:$1000;p:$2000;crc:$854a872a),(n:'ab11.12k';l:$1000;p:$3000;crc:$d4848014),
        (n:'aa8.13k';l:$1000;p:$4000;crc:$8650c788),(n:'ab9.15k';l:$1000;p:$5000;crc:$8dec15e6),
        (n:'ab00.1b';l:$800;p:$0000;crc:$c7a14485),(n:'ab01.3b';l:$800;p:$800;crc:$25b49078),
        (n:'ab02.4b';l:$800;p:$1000;crc:$b8ef56c3),(n:'ab14.12h';l:$1000;p:$e000;crc:$f55e5211),
        (n:'ab03.6b';l:$800;p:$0;crc:$d26bc1f3),());
        exprraid:array[0..18] of tipo_roms=(
        (n:'cz01-2e.16b';l:$4000;p:$4000;crc:$a0ae6756),(n:'cz00-4e.15a';l:$8000;p:$8000;crc:$910f6ccc),
        (n:'cz07.5b';l:$4000;p:$0000;crc:$686bac23),(n:'cz04.8e';l:$8000;p:$0000;crc:$643a1bd3),
        (n:'cz05.8f';l:$8000;p:$10000;crc:$c44570bf),(n:'cz06.8h';l:$8000;p:$18000;crc:$b9bb448b),
        (n:'cz02-1.2a';l:$8000;p:$8000;crc:$552e6112),(n:'cz03.12d';l:$8000;p:$0000;crc:$6ce11971),
        (n:'cz09.16h';l:$8000;p:$0000;crc:$1ed250d1),(n:'cz08.14h';l:$8000;p:$8000;crc:$2293fc61),
        (n:'cz13.16k';l:$8000;p:$10000;crc:$7c3bfd00),(n:'cz12.14k';l:$8000;p:$18000;crc:$ea2294c8),
        (n:'cz11.13k';l:$8000;p:$20000;crc:$b7418335),(n:'cz10.11k';l:$8000;p:$28000;crc:$2f611978),
        (n:'cy-17.5b';l:$100;p:$000;crc:$da31dfbc),(n:'cy-16.6b';l:$100;p:$100;crc:$51f25b4c),
        (n:'cy-15.7b';l:$100;p:$200;crc:$a6168d7f),(n:'cy-14.9b';l:$100;p:$300;crc:$52aad300),());
        sbasketb:array[0..14] of tipo_roms=(
        (n:'405g05.14j';l:$2000;p:$6000;crc:$336dc0ab),(n:'405i03.11j';l:$4000;p:$8000;crc:$d33b82dd),
        (n:'405i01.9j';l:$4000;p:$c000;crc:$1c09cc3f),(n:'405e12.22f';l:$4000;p:0;crc:$e02c54da),
        (n:'405h06.14g';l:$4000;p:0;crc:$cfbbff07),(n:'405h08.17g';l:$4000;p:$4000;crc:$c75901b6),
        (n:'405e17.5a';l:$100;p:$0;crc:$b4c36d57),(n:'405e16.4a';l:$100;p:$100;crc:$0b7b03b8),
        (n:'405e18.6a';l:$100;p:$200;crc:$9e533bad),(n:'405e20.19d';l:$100;p:$300;crc:$8ca6de2f),
        (n:'405e19.16d';l:$100;p:$400;crc:$e0bc782f),(n:'405e15.11f';l:$2000;p:$0;crc:$01bb5ce9),
        (n:'405h10.20g';l:$4000;p:$8000;crc:$95bc5942),(n:'405e13.7a';l:$2000;p:$0;crc:$1ec7458b),());
        //Lady Bug
        ladybug:array[0..12] of tipo_roms=(
        (n:'l1.c4';l:$1000;p:0;crc:$d09e0adb),(n:'l2.d4';l:$1000;p:$1000;crc:$88bc4a0a),
        (n:'l3.e4';l:$1000;p:$2000;crc:$53e9efce),(n:'l4.h4';l:$1000;p:$3000;crc:$ffc424d7),
        (n:'l5.j4';l:$1000;p:$4000;crc:$ad6af809),(n:'l6.k4';l:$1000;p:$5000;crc:$cf1acca4),
        (n:'10-2.k1';l:$20;p:0;crc:$df091e52),(n:'10-1.f4';l:$20;p:$20;crc:$40640d8f),
        (n:'l9.f7';l:$1000;p:0;crc:$77b1da1e),(n:'l0.h7';l:$1000;p:$1000;crc:$aa82e00b),
        (n:'l8.l7';l:$1000;p:0;crc:$8b99910b),(n:'l7.m7';l:$1000;p:$1000;crc:$86a5b448),());
        //Snap Jack
        snapjack:array[0..12] of tipo_roms=(
        (n:'sj1.c4';l:$1000;p:0;crc:$6b30fcda),(n:'sj2.d4';l:$1000;p:$1000;crc:$1f1088d1),
        (n:'sj3.e4';l:$1000;p:$2000;crc:$edd65f3a),(n:'sj4.h4';l:$1000;p:$3000;crc:$f4481192),
        (n:'sj5.j4';l:$1000;p:$4000;crc:$1bff7d05),(n:'sj6.k4';l:$1000;p:$5000;crc:$21793edf),
        (n:'10-2.k1';l:$20;p:0;crc:$cbbd9dd1),(n:'10-1.f4';l:$20;p:$20;crc:$5b16fbd2),
        (n:'sj9.f7';l:$1000;p:0;crc:$ff2011c7),(n:'sj0.h7';l:$1000;p:$1000;crc:$f097babb),
        (n:'sj8.l7';l:$1000;p:0;crc:$b7f105b6),(n:'sj7.m7';l:$1000;p:$1000;crc:$1cdb03a8),());
        //Cosmic Avenger
        cavenger:array[0..12] of tipo_roms=(
        (n:'1.c4';l:$1000;p:0;crc:$9e0cc781),(n:'2.d4';l:$1000;p:$1000;crc:$5ce5b950),
        (n:'3.e4';l:$1000;p:$2000;crc:$bc28218d),(n:'4.h4';l:$1000;p:$3000;crc:$2b32e9f5),
        (n:'5.j4';l:$1000;p:$4000;crc:$d117153e),(n:'6.k4';l:$1000;p:$5000;crc:$c7d366cb),
        (n:'10-2.k1';l:$20;p:0;crc:$42a24dd5),(n:'10-1.f4';l:$20;p:$20;crc:$d736b8de),
        (n:'9.f7';l:$1000;p:0;crc:$63357785),(n:'0.h7';l:$1000;p:$1000;crc:$52ad1133),
        (n:'8.l7';l:$1000;p:0;crc:$b022bf2d),(n:'8.l7';l:$1000;p:$1000;crc:$b022bf2d),());
        tehkanwc:array[0..11] of tipo_roms=(
        (n:'twc-1.bin';l:$4000;p:0;crc:$34d6d5ff),(n:'twc-2.bin';l:$4000;p:$4000;crc:$7017a221),
        (n:'twc-3.bin';l:$4000;p:$8000;crc:$8b662902),(n:'twc-4.bin';l:$8000;p:0;crc:$70a9f883),
        (n:'twc-6.bin';l:$4000;p:0;crc:$e3112be2),(n:'twc-12.bin';l:$4000;p:0;crc:$a9e274f8),
        (n:'twc-8.bin';l:$8000;p:0;crc:$055a5264),(n:'twc-7.bin';l:$8000;p:$8000;crc:$59faebe7),
        (n:'twc-11.bin';l:$8000;p:0;crc:$669389fc),(n:'twc-9.bin';l:$8000;p:$8000;crc:$347ef108),
        (n:'twc-5.bin';l:$4000;p:0;crc:$444b5544),());
        popeye:array[0..13] of tipo_roms=(
        (n:'tpp2-c_f.7a';l:$2000;p:0;crc:$9af7c821),(n:'tpp2-c_f.7b';l:$2000;p:$2000;crc:$c3704958),
        (n:'tpp2-c_f.7c';l:$2000;p:$4000;crc:$5882ebf9),(n:'tpp2-c_f.7e';l:$2000;p:$6000;crc:$ef8649ca),
        (n:'tpp2-c.4a';l:$20;p:0;crc:$375e1602),(n:'tpp2-c.3a';l:$20;p:$20;crc:$e950bea1),
        (n:'tpp2-c.5b';l:$100;p:$40;crc:$c5826883),(n:'tpp2-c.5a';l:$100;p:$140;crc:$c576afba),
        (n:'tpp2-v.5n';l:$1000;p:0;crc:$cca61ddd),
        (n:'tpp2-v.1e';l:$2000;p:0;crc:$0f2cd853),(n:'tpp2-v.1f';l:$2000;p:$2000;crc:$888f3474),
        (n:'tpp2-v.1j';l:$2000;p:$4000;crc:$7e864668),(n:'tpp2-v.1k';l:$2000;p:$6000;crc:$49e1d170),());
        psychic5:array[0..8] of tipo_roms=(
        (n:'myp5d';l:$8000;p:0;crc:$1d40a8c7),(n:'myp5e';l:$10000;p:$8000;crc:$2fa7e8c0),
        (n:'myp5a';l:$10000;p:0;crc:$6efee094),(n:'p5f';l:$8000;p:0;crc:$04d7e21c),
        (n:'p5b';l:$10000;p:0;crc:$7e3f87d4),(n:'p5c';l:$10000;p:$10000;crc:$8710fedb),
        (n:'myp5g';l:$10000;p:0;crc:$617b074b),(n:'myp5h';l:$10000;p:$10000;crc:$a9dfbe67),());
        terracre:array[0..22] of tipo_roms=(
        (n:'1a_4b.rom';l:$4000;p:1;crc:$76f17479),(n:'1a_4d.rom';l:$4000;p:$0;crc:$8119f06e),
        (n:'1a_6b.rom';l:$4000;p:$8001;crc:$ba4b5822),(n:'1a_6d.rom';l:$4000;p:$8000;crc:$ca4852f6),
        (n:'1a_7b.rom';l:$4000;p:$10001;crc:$d0771bba),(n:'1a_7d.rom';l:$4000;p:$10000;crc:$029d59d9),
        (n:'1a_9b.rom';l:$4000;p:$18001;crc:$69227b56),(n:'1a_9d.rom';l:$4000;p:$18000;crc:$5a672942),
        (n:'tc1a_10f.bin';l:$100;p:0;crc:$ce07c544),(n:'tc1a_11f.bin';l:$100;p:$100;crc:$566d323a),
        (n:'tc1a_12f.bin';l:$100;p:$200;crc:$7ea63946),(n:'tc2a_2g.bin';l:$100;p:$300;crc:$08609bad),
        (n:'tc2a_4e.bin';l:$100;p:$400;crc:$2c43991f),(n:'2a_16b.rom';l:$2000;p:0;crc:$591a3804),
        (n:'tc2a_15b.bin';l:$4000;p:0;crc:$790ddfa9),(n:'tc2a_17b.bin';l:$4000;p:$4000;crc:$d4531113),
        (n:'1a_15f.rom';l:$8000;p:0;crc:$984a597f),(n:'1a_17f.rom';l:$8000;p:$8000;crc:$30e297ff),
        (n:'2a_6e.rom';l:$4000;p:0;crc:$bcf7740b),(n:'2a_7e.rom';l:$4000;p:$4000;crc:$a70b565c),
        (n:'2a_6g.rom';l:$4000;p:$8000;crc:$4a9ec3e6),(n:'2a_7g.rom';l:$4000;p:$c000;crc:$450749fc),());
        //Kung-Fu Master
        kungfum:array[0..27] of tipo_roms=(
        (n:'a-4e-c.bin';l:$4000;p:0;crc:$b6e2d083),(n:'a-4d-c.bin';l:$4000;p:$4000;crc:$7532918e),
        (n:'g-1j-.bin';l:$100;p:0;crc:$668e6bca),(n:'g-1f-.bin';l:$100;p:$100;crc:$964b6495),
        (n:'g-1h-.bin';l:$100;p:$200;crc:$550563e1),(n:'b-1m-.bin';l:$100;p:$300;crc:$76c05a9c),
        (n:'b-1n-.bin';l:$100;p:$400;crc:$23f06b99),(n:'b-1l-.bin';l:$100;p:$500;crc:$35e45021),
        (n:'g-4c-a.bin';l:$2000;p:0;crc:$6b2cc9c8),(n:'g-4d-a.bin';l:$2000;p:$2000;crc:$c648f558),
        (n:'b-5f-.bin';l:$20;p:$600;crc:$7a601c3d),(n:'g-4e-a.bin';l:$2000;p:$4000;crc:$fbe9276e),
        (n:'a-3e-.bin';l:$2000;p:$a000;crc:$58e87ab0),(n:'a-3f-.bin';l:$2000;p:$c000;crc:$c81e31ea),
        (n:'a-3h-.bin';l:$2000;p:$e000;crc:$d99fb995),
        (n:'b-4k-.bin';l:$2000;p:0;crc:$16fb5150),(n:'b-4f-.bin';l:$2000;p:$2000;crc:$67745a33),
        (n:'b-4l-.bin';l:$2000;p:$4000;crc:$bd1c2261),(n:'b-4h-.bin';l:$2000;p:$6000;crc:$8ac5ed3a),
        (n:'b-3n-.bin';l:$2000;p:$8000;crc:$28a213aa),(n:'b-4n-.bin';l:$2000;p:$a000;crc:$d5228df3),
        (n:'b-4m-.bin';l:$2000;p:$c000;crc:$b16de4f2),(n:'b-3m-.bin';l:$2000;p:$e000;crc:$eba0d66b),
        (n:'b-4c-.bin';l:$2000;p:$10000;crc:$01298885),(n:'b-4e-.bin';l:$2000;p:$12000;crc:$c77b87d4),
        (n:'b-4d-.bin';l:$2000;p:$14000;crc:$6a70615f),(n:'b-4a-.bin';l:$2000;p:$16000;crc:$6189d626),());
        //Spelunker
        spelunkr:array[0..28] of tipo_roms=(
        (n:'spra.4e';l:$4000;p:0;crc:$cf811201),(n:'spra.4d';l:$4000;p:$4000;crc:$bb4faa4f),
        (n:'sprm.7c';l:$4000;p:$8000;crc:$fb6197e2),(n:'sprm.7b';l:$4000;p:$c000;crc:$26bb25a4),
        (n:'sprm.2k';l:$100;p:0;crc:$fd8fa991),(n:'sprm.2j';l:$100;p:$100;crc:$0e3890b4),
        (n:'sprm.2h';l:$100;p:$200;crc:$0478082b),(n:'sprb.1m';l:$100;p:$300;crc:$8d8cccad),
        (n:'sprb.1n';l:$100;p:$400;crc:$c40e1cb2),(n:'sprb.1l';l:$100;p:$500;crc:$3ec46248),
        (n:'sprm.4p';l:$4000;p:0;crc:$4dfe2e63),(n:'sprm.4l';l:$4000;p:$4000;crc:$239f2cd4),
        (n:'sprb.5p';l:$20;p:$600;crc:$746c6238),(n:'sprm.4m';l:$4000;p:$8000;crc:$d6d07d70),
        (n:'spra.3d';l:$4000;p:$8000;crc:$4110363c),(n:'spra.3f';l:$4000;p:$c000;crc:$67a9d2e6),
        (n:'sprb.4k';l:$4000;p:0;crc:$e7f0e861),(n:'sprb.4f';l:$4000;p:$4000;crc:$32663097),
        (n:'sprb.3p';l:$4000;p:$8000;crc:$8fbaf373),(n:'sprb.4p';l:$4000;p:$c000;crc:$37069b76),
        (n:'sprb.4c';l:$4000;p:$10000;crc:$cfe46a88),(n:'sprb.4e';l:$4000;p:$14000;crc:$11c48979),
        (n:'sprm.1d';l:$4000;p:0;crc:$4ef7ae89),(n:'sprm.1e';l:$4000;p:$4000;crc:$a3755180),
        (n:'sprm.3c';l:$4000;p:$8000;crc:$b4008e6a),(n:'sprm.3b';l:$4000;p:$c000;crc:$f61cf012),
        (n:'sprm.1c';l:$4000;p:$10000;crc:$58b21c76),(n:'sprm.1b';l:$4000;p:$14000;crc:$a95cb3e5),());
        //Spelunker II
        spelunk2:array[0..26] of tipo_roms=(
        (n:'sp2-a.4e';l:$4000;p:0;crc:$96c04bbb),(n:'sp2-a.4d';l:$4000;p:$4000;crc:$cb38c2ff),
        (n:'sp2-r.7d';l:$8000;p:$8000;crc:$558837ea),(n:'sp2-r.7c';l:$8000;p:$10000;crc:$4b380162),
        (n:'sp2-r.1k';l:$200;p:0;crc:$31c1bcdc),(n:'sp2-r.2k';l:$100;p:$200;crc:$1cf5987e),
        (n:'sp2-r.2j';l:$100;p:$300;crc:$1acbe2a5),(n:'sp2-b.1m';l:$100;p:$400;crc:$906104c7),
        (n:'sp2-b.1n';l:$100;p:$500;crc:$5a564c06),(n:'sp2-b.1l';l:$100;p:$600;crc:$8f4a2e3c),
        (n:'sp2-r.7b';l:$4000;p:$18000;crc:$7709a1fe),(n:'sp2-b.5p';l:$20;p:$700;crc:$cd126f6a),
        (n:'sp2-r.4l';l:$4000;p:0;crc:$6a4b2d8b),(n:'sp2-r.4m';l:$4000;p:$4000;crc:$e1368b61),
        (n:'sp2-a.3d';l:$4000;p:$8000;crc:$839ec7e2),(n:'sp2-a.3f';l:$4000;p:$c000;crc:$ad3ce898),
        (n:'sp2-b.4k';l:$4000;p:0;crc:$6cb67a17),(n:'sp2-b.4f';l:$4000;p:$4000;crc:$e4a1166f),
        (n:'sp2-b.3n';l:$4000;p:$8000;crc:$f59e8b76),(n:'sp2-b.4n';l:$4000;p:$c000;crc:$fa65bac9),
        (n:'sp2-b.4c';l:$4000;p:$10000;crc:$1caf7013),(n:'sp2-b.4e';l:$4000;p:$14000;crc:$780a463b),
        (n:'sp2-r.1d';l:$8000;p:0;crc:$c19fa4c9),(n:'sp2-r.3b';l:$8000;p:$8000;crc:$366604af),
        (n:'sp2-r.4p';l:$4000;p:$8000;crc:$fc138e13),(n:'sp2-r.1b';l:$8000;p:$10000;crc:$3a0c4d47),());
        //Lode Runner
        ldrun:array[0..19] of tipo_roms=(
        (n:'lr-a-4e';l:$2000;p:0;crc:$5d7e2a4d),(n:'lr-a-4d';l:$2000;p:$2000;crc:$96f20473),
        (n:'lr-a-4b';l:$2000;p:$4000;crc:$b041c4a9),(n:'lr-a-4a';l:$2000;p:$6000;crc:$645e42aa),
        (n:'lr-e-3m';l:$100;p:0;crc:$53040416),(n:'lr-e-3l';l:$100;p:$100;crc:$67786037),
        (n:'lr-e-3n';l:$100;p:$200;crc:$5b716837),(n:'lr-b-1m';l:$100;p:$300;crc:$4bae1c25),
        (n:'lr-b-1n';l:$100;p:$400;crc:$9cd3db94),(n:'lr-b-1l';l:$100;p:$500;crc:$08d8cf9a),
        (n:'lr-e-2d';l:$2000;p:0;crc:$24f9b58d),(n:'lr-e-2j';l:$2000;p:$2000;crc:$43175e08),
        (n:'lr-b-5p';l:$20;p:$600;crc:$e01f69e2),(n:'lr-e-2f';l:$2000;p:$4000;crc:$e0317124),
        (n:'lr-a-3f';l:$2000;p:$c000;crc:$7a96accd),(n:'lr-a-3h';l:$2000;p:$e000;crc:$3f7f3939),
        (n:'lr-b-4k';l:$2000;p:0;crc:$8141403e),(n:'lr-b-3n';l:$2000;p:$2000;crc:$55154154),
        (n:'lr-b-4c';l:$2000;p:$4000;crc:$924e34d0),());
        //Lode Runner II
        ldrun2:array[0..25] of tipo_roms=(
        (n:'lr2-a-4e.a';l:$2000;p:0;crc:$22313327),(n:'lr2-a-4d';l:$2000;p:$2000;crc:$ef645179),
        (n:'lr2-a-4a.a';l:$2000;p:$4000;crc:$b11ddf59),(n:'lr2-a-4a';l:$2000;p:$6000;crc:$470cc8a1),
        (n:'lr2-h-1c.a';l:$2000;p:$8000;crc:$7ebcadbc),(n:'lr2-h-1d.a';l:$2000;p:$a000;crc:$64cbb7f9),
        (n:'lr2-h-3m';l:$100;p:0;crc:$2c5d834b),(n:'lr2-h-3l';l:$100;p:$100;crc:$3ae69aca),
        (n:'lr2-h-3n';l:$100;p:$200;crc:$2b28aec5),(n:'lr2-b-1m';l:$100;p:$300;crc:$4ec9bb3d),
        (n:'lr2-b-1n';l:$100;p:$400;crc:$1daf1fa4),(n:'lr2-b-1l';l:$100;p:$500;crc:$c8fb708a),
        (n:'lr2-h-1e';l:$2000;p:0;crc:$9d63a8ff),(n:'lr2-h-1j';l:$2000;p:$2000;crc:$40332bbd),
        (n:'lr2-b-5p';l:$20;p:$600;crc:$e01f69e2),(n:'lr2-h-1h';l:$2000;p:$4000;crc:$9404727d),
        (n:'lr2-a-3e';l:$2000;p:$a000;crc:$853f3898),(n:'lr2-a-3f';l:$2000;p:$c000;crc:$7a96accd),
        (n:'lr2-a-3h';l:$2000;p:$e000;crc:$2a0e83ca),
        (n:'lr2-b-4k';l:$2000;p:0;crc:$79909871),(n:'lr2-b-4f';l:$2000;p:$2000;crc:$06ba1ef4),
        (n:'lr2-b-3n';l:$2000;p:$4000;crc:$3cc5893f),(n:'lr2-b-4n';l:$2000;p:$6000;crc:$49c12f42),
        (n:'lr2-b-4c';l:$2000;p:$8000;crc:$fbe6d24c),(n:'lr2-b-4e';l:$2000;p:$a000;crc:$75172d1f),());
        shootout:array[0..13] of tipo_roms=(
        (n:'cu00.b1';l:$8000;p:$0;crc:$090edeb6),(n:'cu02.c3';l:$8000;p:$8000;crc:$2a913730),
        (n:'cu01.c1';l:$4000;p:$10000;crc:$8843c3ae),(n:'cu11.h19';l:$4000;p:$0;crc:$eff00460),
        (n:'cu04.c7';l:$8000;p:$0;crc:$ceea6b20),(n:'cu03.c5';l:$8000;p:$8000;crc:$b786bb3e),
        (n:'cu06.c10';l:$8000;p:$10000;crc:$2ec1d17f),(n:'cu05.c9';l:$8000;p:$18000;crc:$dd038b85),
        (n:'cu08.c13';l:$8000;p:$20000;crc:$91290933),(n:'cu07.c12';l:$8000;p:$28000;crc:$19b6b94f),
        (n:'cu09.j1';l:$4000;p:$c000;crc:$c4cbd558),(n:'cu10.h17';l:$8000;p:$0;crc:$3854c877),
        (n:'gb08.k10';l:$100;p:$0;crc:$509c65b6),());
        vigilant:array[0..13] of tipo_roms=(
        (n:'VG_A-8H-E.ic55';l:$8000;p:0;crc:$0d4e6866),(n:'VG_A-8L-A.ic57';l:$10000;p:$8000;crc:$690d812f),
        (n:'VG_B-4F-.ic34';l:$10000;p:0;crc:$01579d20),(n:'VG_B-4J-.ic35';l:$10000;p:$10000;crc:$4f5872f0),
        (n:'VG_B-6L-.ic62';l:$20000;p:0;crc:$fbe9552d),(n:'VG_B-6K-.ic61';l:$20000;p:$20000;crc:$ae09d5c0),
        (n:'VG_B-6P-.ic64';l:$20000;p:$40000;crc:$afb77461),(n:'VG_B-6N-.ic63';l:$20000;p:$60000;crc:$5065cd35),
        (n:'VG_A-4D-.ic26';l:$10000;p:0;crc:$9b85101d),(n:'VG_A-5J-.ic37';l:$10000;p:0;crc:$10582b2d),
        (n:'VG_B-1D-.ic2';l:$10000;p:$00000;crc:$81b1ee5c),(n:'VG_B-1F-.ic3';l:$10000;p:$10000;crc:$d0d33673),
        (n:'VG_B-1H-.ic4';l:$10000;p:$20000;crc:$aae81695),());
        jackal:array[0..9] of tipo_roms=(
        (n:'j-v02.rom';l:$10000;p:$0;crc:$0b7e0584),(n:'j-v03.rom';l:$4000;p:$10000;crc:$3e0dfb83),
        (n:'631r08.bpr';l:$100;p:0;crc:$7553a172),(n:'631r09.bpr';l:$100;p:$100;crc:$a74dd86c),
        (n:'631t04.bin';l:$20000;p:0;crc:$457f42f0),(n:'631t05.bin';l:$20000;p:$1;crc:$732b3fc1),
        (n:'631t06.bin';l:$20000;p:$40000;crc:$2d10e56e),(n:'631t07.bin';l:$20000;p:$40001;crc:$4961c397),
        (n:'631t01.bin';l:$8000;p:$8000;crc:$b189af6a),());
        bublbobl:array[0..18] of tipo_roms=(
        (n:'a78-06-1.51';l:$8000;p:0;crc:$567934b6),(n:'a78-05-1.52';l:$10000;p:$8000;crc:$9f8ee242),
        (n:'a78-09.12';l:$8000;p:0;crc:$20358c22),(n:'a78-10.13';l:$8000;p:$8000;crc:$930168a9),
        (n:'a78-11.14';l:$8000;p:$10000;crc:$9773e512),(n:'a78-12.15';l:$8000;p:$18000;crc:$d045549b),
        (n:'a78-13.16';l:$8000;p:$20000;crc:$d0af35c5),(n:'a78-14.17';l:$8000;p:$28000;crc:$7b5369a8),
        (n:'a78-15.30';l:$8000;p:$40000;crc:$6b61a413),(n:'a78-16.31';l:$8000;p:$48000;crc:$b5492d97),
        (n:'a78-17.32';l:$8000;p:$50000;crc:$d69762d5),(n:'a78-18.33';l:$8000;p:$58000;crc:$9f243b68),
        (n:'a78-19.34';l:$8000;p:$60000;crc:$66e9438c),(n:'a78-20.35';l:$8000;p:$68000;crc:$9ef863ad),
        (n:'a78-07.46';l:$8000;p:0;crc:$4f9a26e8),(n:'a71-25.41';l:$100;p:0;crc:$2d0f8545),
        (n:'a78-08.37';l:$8000;p:0;crc:$ae11a07b),(n:'a78-01.17';l:$1000;p:$f000;crc:$b1bfb53d),());
        prehisle:array[0..10] of tipo_roms=(
        (n:'gt-e2.2h';l:$20000;p:0;crc:$7083245a),(n:'gt-e3.3h';l:$20000;p:$1;crc:$6d8cdf58),
        (n:'gt15.b15';l:$8000;p:0;crc:$ac652412),(n:'gt.11';l:$10000;p:0;crc:$b4f0fcf0),
        (n:'pi8914.b14';l:$40000;p:0;crc:$207d6187),(n:'pi8916.h16';l:$40000;p:0;crc:$7cffe0f6),
        (n:'gt1.1';l:$10000;p:0;crc:$80a4c093),(n:'gt4.4';l:$20000;p:0;crc:$85dfb9ec),
        (n:'pi8910.k14';l:$80000;p:0;crc:$5a101b0b),(n:'gt.5';l:$20000;p:$80000;crc:$3d3ab273),());
        //Tiger Road
        tigeroad:array[0..17] of tipo_roms=(
        (n:'tre_02.6j';l:$20000;p:0;crc:$c394add0),(n:'tre_04.6k';l:$20000;p:$1;crc:$73bfbf4a),
        (n:'tru_05.12k';l:$8000;p:0;crc:$f9a7c9bf),(n:'tr_01.10d';l:$8000;p:0;crc:$74a9f08c),
        (n:'tr-01a.3f';l:$20000;p:0;crc:$a8aa2e59),(n:'tr-04a.3h';l:$20000;p:$20000;crc:$8863a63c),
        (n:'tr-02a.3j';l:$20000;p:$40000;crc:$1a2c5f89),(n:'tr-05.3l';l:$20000;p:$60000;crc:$5bf453b3),
        (n:'tr-03a.2f';l:$20000;p:$80000;crc:$1e0537ea),(n:'tr-06a.2h';l:$20000;p:$a0000;crc:$b636c23a),
        (n:'tr-07a.2j';l:$20000;p:$c0000;crc:$5f907d4d),(n:'tr_08.2l';l:$20000;p:$e0000;crc:$adee35e2),
        (n:'tr_13.7l';l:$8000;p:0;crc:$a79be1eb),(n:'tr-09a.3b';l:$20000;p:0;crc:$3d98ad1e),
        (n:'tr-10a.2b';l:$20000;p:$20000;crc:$8f6f03d7),(n:'tr-11a.3d';l:$20000;p:$40000;crc:$cd9152e5),
        (n:'tr-12a.2d';l:$20000;p:$60000;crc:$7d8a99d0),());
        //F1 Dream
        f1dream:array[0..16] of tipo_roms=(
        (n:'06j_02.bin';l:$20000;p:0;crc:$3c2ec697),(n:'06k_03.bin';l:$20000;p:$1;crc:$85ebad91),
        (n:'12k_04.bin';l:$8000;p:0;crc:$4b9a7524),(n:'8751.mcu';l:$1000;p:0;crc:$c8e6075c),
        (n:'10d_01.bin';l:$8000;p:0;crc:$361caf00),(n:'03f_12.bin';l:$10000;p:0;crc:$bc13e43c),
        (n:'01f_10.bin';l:$10000;p:$10000;crc:$f7617ad9),(n:'03h_14.bin';l:$10000;p:$20000;crc:$e33cd438),
        (n:'02f_11.bin';l:$10000;p:$30000;crc:$4aa49cd7),(n:'17f_09.bin';l:$10000;p:$40000;crc:$ca622155),
        (n:'02h_13.bin';l:$10000;p:$50000;crc:$2a63961e),(n:'07l_15.bin';l:$8000;p:0;crc:$978758b7),
        (n:'03b_06.bin';l:$10000;p:0;crc:$5e54e391),(n:'02b_05.bin';l:$10000;p:$10000;crc:$cdd119fd),
        (n:'03d_08.bin';l:$10000;p:$20000;crc:$811f2e22),(n:'02d_07.bin';l:$10000;p:$30000;crc:$aa9a1233),());
        snowbros:array[0..4] of tipo_roms=(
        (n:'sn6.bin';l:$20000;p:0;crc:$4899ddcf),(n:'sn5.bin';l:$20000;p:$1;crc:$ad310d3f),
        (n:'sbros-1.41';l:$80000;p:0;crc:$16f06b3a),(n:'sbros-4.29';l:$8000;p:0;crc:$e6eab4e4),());
        toki:array[0..13] of tipo_roms=(
        (n:'l10_6.bin';l:$20000;p:0;crc:$94015d91),(n:'k10_4e.bin';l:$20000;p:$1;crc:$531bd3ef),
        (n:'tokijp.005';l:$10000;p:$40000;crc:$d6a82808),(n:'tokijp.003';l:$10000;p:$40001;crc:$a01a5b10),
        (n:'tokijp.001';l:$10000;p:0;crc:$8aa964a2),(n:'tokijp.002';l:$10000;p:$10000;crc:$86e87e48),
        (n:'toki.ob1';l:$80000;p:0;crc:$a27a80ba),(n:'toki.ob2';l:$80000;p:$80000;crc:$fa687718),
        (n:'toki.bk1';l:$80000;p:0;crc:$fdaa5f4b),(n:'toki.bk2';l:$80000;p:0;crc:$d86ac664),
        (n:'tokijp.008';l:$2000;p:0;crc:$6c87c4c5),(n:'tokijp.007';l:$10000;p:$10000;crc:$a67969c4),
        (n:'tokijp.009';l:$20000;p:0;crc:$ae7a6b8b),());
        contra:array[0..11] of tipo_roms=(
        (n:'633m03.18a';l:$10000;p:$0;crc:$d045e1da),(n:'633i02.17a';l:$10000;p:$10000;crc:$b2f7bd9a),
        (n:'633e08.10g';l:$100;p:0;crc:$9f0949fa),(n:'633e09.12g';l:$100;p:$100;crc:$14ca5e19),
        (n:'633f10.18g';l:$100;p:$200;crc:$2b244d84),(n:'633f11.20g';l:$100;p:$300;crc:$14ca5e19),
        (n:'633e04.7d';l:$40000;p:0;crc:$14ddc542),(n:'633e05.7f';l:$40000;p:$1;crc:$42185044),
        (n:'633e06.16d';l:$40000;p:0;crc:$9cf6faae),(n:'633e07.16f';l:$40000;p:$1;crc:$f2d06638),
        (n:'633e01.12a';l:$8000;p:$8000;crc:$d1549255),());
        //Mappy
        mappy:array[0..11] of tipo_roms=(
        (n:'mpx_3.1d';l:$2000;p:$a000;crc:$52e6c708),(n:'mp1_2.1c';l:$2000;p:$c000;crc:$a958a61c),
        (n:'mpx_1.1b';l:$2000;p:$e000;crc:$203766d4),
        (n:'mp1-5.5b';l:$20;p:0;crc:$56531268),(n:'mp1-6.4c';l:$100;p:$20;crc:$50765082),
        (n:'mp1-7.5k';l:$100;p:$120;crc:$5396bd78),(n:'mp1_5.3b';l:$1000;p:0;crc:$16498b9f),
        (n:'mp1_6.3m';l:$2000;p:0;crc:$f2d9647a),(n:'mp1_7.3n';l:$2000;p:$2000;crc:$757cf2b6),
        (n:'mp1_4.1k';l:$2000;p:$e000;crc:$8182dd5b),(n:'mp1-3.3m';l:$100;p:0;crc:$16a9166a),());
        //Dig Dug 2
        digdug2:array[0..11] of tipo_roms=(
        (n:'d23_3.1d';l:$4000;p:$8000;crc:$cc155338),(n:'d23_1.1b';l:$4000;p:$c000;crc:$40e46af8),
        (n:'d21-5.5b';l:$20;p:0;crc:$9b169db5),(n:'d21-6.4c';l:$100;p:$20;crc:$55a88695),
        (n:'d21-7.5k';l:$100;p:$120;crc:$9c55feda),(n:'d21_5.3b';l:$1000;p:0;crc:$afcb4509),
        (n:'d21_6.3m';l:$4000;p:0;crc:$df1f4ad8),(n:'d21_7.3n';l:$4000;p:$4000;crc:$ccadb3ea),
        (n:'d21_4.1k';l:$2000;p:$e000;crc:$737443b1),(n:'d21-3.3m';l:$100;p:0;crc:$e0074ee2),
        (n:'53xx.bin';l:$400;p:0;crc:$b326fecb),());
        //Super Pacman
        spacman:array[0..9] of tipo_roms=(
        (n:'sp1-2.1c';l:$2000;p:$c000;crc:$4bb33d9c),(n:'sp1-1.1b';l:$2000;p:$e000;crc:$846fbb4a),
        (n:'superpac.4c';l:$20;p:0;crc:$9ce22c46),(n:'superpac.4e';l:$100;p:$20;crc:$1253c5c1),
        (n:'superpac.3l';l:$100;p:$120;crc:$d4d7026f),(n:'sp1-6.3c';l:$1000;p:0;crc:$91c5935c),
        (n:'spv-2.3f';l:$2000;p:0;crc:$670a42f2),(n:'spc-3.1k';l:$1000;p:$f000;crc:$04445ddb),
        (n:'superpac.3m';l:$100;p:0;crc:$ad43688f),());
        //The Tower of Druaga
        todruaga:array[0..10] of tipo_roms=(
        (n:'td2_3.1d';l:$4000;p:$8000;crc:$fbf16299),(n:'td2_1.1b';l:$4000;p:$c000;crc:$b238d723),
        (n:'td1-5.5b';l:$20;p:0;crc:$122cc395),(n:'td1-6.4c';l:$100;p:$20;crc:$8c661d6a),
        (n:'td1-7.5k';l:$400;p:$120;crc:$a86c74dd),(n:'td1_5.3b';l:$1000;p:0;crc:$d32b249f),
        (n:'td1_6.3m';l:$2000;p:0;crc:$e827e787),(n:'td1_7.3n';l:$2000;p:$2000;crc:$962bd060),
        (n:'td1_4.1k';l:$2000;p:$e000;crc:$ae9d06d9),(n:'td1-3.3m';l:$100;p:0;crc:$07104c40),());
        //Motos
        motos:array[0..10] of tipo_roms=(
        (n:'mo1_3.1d';l:$4000;p:$8000;crc:$1104abb2),(n:'mo1_1.1b';l:$4000;p:$c000;crc:$57b157e2),
        (n:'mo1-5.5b';l:$20;p:0;crc:$71972383),(n:'mo1-6.4c';l:$100;p:$20;crc:$730ba7fb),
        (n:'mo1-7.5k';l:$100;p:$120;crc:$7721275d),(n:'mo1_5.3b';l:$1000;p:0;crc:$5d4a2a22),
        (n:'mo1_6.3m';l:$4000;p:0;crc:$2f0e396e),(n:'mo1_7.3n';l:$4000;p:$4000;crc:$cf8a3b86),
        (n:'mo1_4.1k';l:$2000;p:$e000;crc:$55e45d21),(n:'mo1-3.3m';l:$100;p:0;crc:$2accdfb4),());
        rastan:array[0..16] of tipo_roms=(
        (n:'b04-38.19';l:$10000;p:0;crc:$1c91dbb1),(n:'b04-37.7';l:$10000;p:$1;crc:$ecf20bdd),
        (n:'b04-40.20';l:$10000;p:$20000;crc:$0930d4b3),(n:'b04-39.8';l:$10000;p:$20001;crc:$d95ade5e),
        (n:'b04-42.21';l:$10000;p:$40000;crc:$1857a7cb),(n:'b04-43-1.9';l:$10000;p:$40001;crc:$ca4702ff),
        (n:'b04-01.40';l:$20000;p:0;crc:$cd30de19),(n:'b04-03.39';l:$20000;p:$20000;crc:$ab67e064),
        (n:'b04-02.67';l:$20000;p:$40000;crc:$54040fec),(n:'b04-04.66';l:$20000;p:$60000;crc:$94737e93),
        (n:'b04-19.49';l:$10000;p:0;crc:$ee81fdd8),(n:'b04-05.15';l:$20000;p:0;crc:$c22d94ac),
        (n:'b04-07.14';l:$20000;p:$20000;crc:$b5632a51),(n:'b04-06.28';l:$20000;p:$40000;crc:$002ccf39),
        (n:'b04-08.27';l:$20000;p:$60000;crc:$feafca05),(n:'b04-20.76';l:$10000;p:0;crc:$fd1a34cc),());
        //legendary wings
        lwings:array[0..17] of tipo_roms=(
        (n:'6c_lw01.bin';l:$8000;p:0;crc:$b55a7f60),(n:'7c_lw02.bin';l:$8000;p:$8000;crc:$a5efbb1b),
        (n:'9c_lw03.bin';l:$8000;p:$10000;crc:$ec5cc201),(n:'11e_lw04.bin';l:$8000;p:0;crc:$a20337a2),
        (n:'9h_lw05.bin';l:$4000;p:0;crc:$091d923c),
        (n:'3j_lw17.bin';l:$8000;p:0;crc:$5ed1bc9b),(n:'1j_lw11.bin';l:$8000;p:$8000;crc:$2a0790d6),
        (n:'3h_lw16.bin';l:$8000;p:$10000;crc:$e8834006),(n:'1h_lw10.bin';l:$8000;p:$18000;crc:$b693f5a5),
        (n:'3e_lw14.bin';l:$8000;p:0;crc:$5436392c),(n:'1e_lw08.bin';l:$8000;p:$8000;crc:$b491bbbb),
        (n:'3d_lw13.bin';l:$8000;p:$10000;crc:$fdd1908a),(n:'1d_lw07.bin';l:$8000;p:$18000;crc:$5c73d406),
        (n:'3b_lw12.bin';l:$8000;p:$20000;crc:$32e17b3c),(n:'1b_lw06.bin';l:$8000;p:$28000;crc:$52e533c1),
        (n:'3f_lw15.bin';l:$8000;p:$30000;crc:$99e134ba),(n:'1f_lw09.bin';l:$8000;p:$38000;crc:$c8f28777),());
        //section Z
        sectionz:array[0..17] of tipo_roms=(
        (n:'6c_sz01.bin';l:$8000;p:0;crc:$69585125),(n:'7c_sz02.bin';l:$8000;p:$8000;crc:$22f161b8),
        (n:'9c_sz03.bin';l:$8000;p:$10000;crc:$4c7111ed),(n:'11e_sz04.bin';l:$8000;p:0;crc:$a6073566),
        (n:'9h_sz05.bin';l:$4000;p:0;crc:$3173ba2e),
        (n:'3j_sz17.bin';l:$8000;p:0;crc:$8df7b24a),(n:'1j_sz11.bin';l:$8000;p:$8000;crc:$685d4c54),
        (n:'3h_sz16.bin';l:$8000;p:$10000;crc:$500ff2bb),(n:'1h_sz10.bin';l:$8000;p:$18000;crc:$00b3d244),
        (n:'3e_sz14.bin';l:$8000;p:0;crc:$63782e30),(n:'1e_sz08.bin';l:$8000;p:$8000;crc:$d57d9f13),
        (n:'3d_sz13.bin';l:$8000;p:$10000;crc:$1b3d4d7f),(n:'1d_sz07.bin';l:$8000;p:$18000;crc:$f5b3a29f),
        (n:'3b_sz12.bin';l:$8000;p:$20000;crc:$11d47dfd),(n:'1b_sz06.bin';l:$8000;p:$28000;crc:$df703b68),
        (n:'3f_sz15.bin';l:$8000;p:$30000;crc:$36bb9bf7),(n:'1f_sz09.bin';l:$8000;p:$38000;crc:$da8f06c9),());
        //Trojan
        trojan:array[0..25] of tipo_roms=(
        (n:'t4';l:$8000;p:0;crc:$c1bbeb4e),(n:'t6';l:$8000;p:$8000;crc:$d49592ef),
        (n:'tb05.bin';l:$8000;p:$10000;crc:$9273b264),(n:'tb02.bin';l:$8000;p:0;crc:$21154797),
        (n:'tb01.bin';l:$4000;p:0;crc:$1c0f91b2),(n:'tb03.bin';l:$4000;p:0;crc:$581a2b4c),
        (n:'tb18.bin';l:$8000;p:0;crc:$862c4713),(n:'tb16.bin';l:$8000;p:$8000;crc:$d86f8cbd),
        (n:'tb17.bin';l:$8000;p:$10000;crc:$12a73b3f),(n:'tb15.bin';l:$8000;p:$18000;crc:$bb1a2769),
        (n:'tb22.bin';l:$8000;p:$20000;crc:$39daafd4),(n:'tb20.bin';l:$8000;p:$28000;crc:$94615d2a),
        (n:'tb21.bin';l:$8000;p:$30000;crc:$66c642bd),(n:'tb19.bin';l:$8000;p:$38000;crc:$81d5ab36),
        (n:'tb13.bin';l:$8000;p:0;crc:$285a052b),(n:'tb09.bin';l:$8000;p:$8000;crc:$aeb693f7),
        (n:'tb12.bin';l:$8000;p:$10000;crc:$dfb0fe5c),(n:'tb08.bin';l:$8000;p:$18000;crc:$d3a4c9d1),
        (n:'tb11.bin';l:$8000;p:$20000;crc:$00f0f4fd),(n:'tb07.bin';l:$8000;p:$28000;crc:$dff2ee02),
        (n:'tb14.bin';l:$8000;p:$30000;crc:$14bfac18),(n:'tb10.bin';l:$8000;p:$38000;crc:$71ba8a6d),
        (n:'tb25.bin';l:$8000;p:0;crc:$6e38c6fa),(n:'tb24.bin';l:$8000;p:$8000;crc:$14fc6cf2),
        (n:'tb23.bin';l:$8000;p:0;crc:$eda13c0e),());
        sfighter:array[0..40] of tipo_roms=(
        (n:'sfd-19.2a';l:$10000;p:0;crc:$faaf6255),(n:'sfd-22.2c';l:$10000;p:$1;crc:$e1fe3519),
        (n:'sfd-20.3a';l:$10000;p:$20000;crc:$44b915bd),(n:'sfd-23.3c';l:$10000;p:$20001;crc:$79c43ff8),
        (n:'sfd-21.4a';l:$10000;p:$40000;crc:$e8db799b),(n:'sfd-24.4c';l:$10000;p:$40001;crc:$466a3440),
        (n:'sf-02.7k';l:$8000;p:0;crc:$4a9ac534),(n:'sfu-00.1h';l:$20000;p:$0;crc:$a7cce903),
        (n:'sf-01.1k';l:$20000;p:$20000;crc:$86e0f0d5),(n:'sf-27.4d';l:$4000;p:0;crc:$2b09b36d),
        (n:'sf-39.2k';l:$20000;p:0;crc:$cee3d292),(n:'sf-38.1k';l:$20000;p:$20000;crc:$2ea99676),
        (n:'sf-41.4k';l:$20000;p:$40000;crc:$e0280495),(n:'sf-40.3k';l:$20000;p:$60000;crc:$c70b30de),
        (n:'sf-25.1d';l:$20000;p:0;crc:$7f23042e),(n:'sf-28.1e';l:$20000;p:$20000;crc:$92f8b91c),
        (n:'sf-30.1g';l:$20000;p:$40000;crc:$b1399856),(n:'sf-34.1h';l:$20000;p:$60000;crc:$96b6ae2e),
        (n:'sf-26.2d';l:$20000;p:$80000;crc:$54ede9f5),(n:'sf-29.2e';l:$20000;p:$a0000;crc:$f0649a67),
        (n:'sf-31.2g';l:$20000;p:$c0000;crc:$8f4dd71a),(n:'sf-35.2h';l:$20000;p:$e0000;crc:$70c00fb4),
        (n:'sf-15.1m';l:$20000;p:0;crc:$fc0113db),(n:'sf-16.2m';l:$20000;p:$20000;crc:$82e4a6d3),
        (n:'sf-11.1k';l:$20000;p:$40000;crc:$e112df1b),(n:'sf-12.2k';l:$20000;p:$60000;crc:$42d52299),
        (n:'sf-07.1h';l:$20000;p:$80000;crc:$49f340d9),(n:'sf-08.2h';l:$20000;p:$a0000;crc:$95ece9b1),
        (n:'sf-03.1f';l:$20000;p:$c0000;crc:$5ca05781),(n:'sf-17.3m';l:$20000;p:$e0000;crc:$69fac48e),
        (n:'sf-18.4m';l:$20000;p:$100000;crc:$71cfd18d),(n:'sf-13.3k';l:$20000;p:$120000;crc:$fa2eb24b),
        (n:'sf-14.4k';l:$20000;p:$140000;crc:$ad955c95),(n:'sf-09.3h';l:$20000;p:$160000;crc:$41b73a31),
        (n:'sf-10.4h';l:$20000;p:$180000;crc:$91c41c50),(n:'sf-05.3f';l:$20000;p:$1a0000;crc:$538c7cbe),
        (n:'sf-37.4h';l:$10000;p:0;crc:$23d09d3d),(n:'sf-36.3h';l:$10000;p:$10000;crc:$ea16df6c),
        (n:'sf-32.3g';l:$10000;p:$0;crc:$72df2bd9),(n:'sf-33.4g';l:$10000;p:$10000;crc:$3e99d3d5),());
        //Galaga
        galaga:array[0..14] of tipo_roms=(
        (n:'gg1_1b.3p';l:$1000;p:0;crc:$ab036c9f),(n:'gg1_2b.3m';l:$1000;p:$1000;crc:$d9232240),
        (n:'gg1_3.2m';l:$1000;p:$2000;crc:$753ce503),(n:'gg1_4b.2l';l:$1000;p:$3000;crc:$499fcc76),
        (n:'gg1_5b.3f';l:$1000;p:0;crc:$bb5caae3),(n:'gg1_7b.2c';l:$1000;p:0;crc:$d016686b),
        (n:'prom-5.5n';l:$20;p:0;crc:$54603c6b),(n:'prom-4.2n';l:$100;p:$20;crc:$59b6edab),
        (n:'prom-3.1c';l:$100;p:$120;crc:$4a04bb6b),(n:'gg1_9.4l';l:$1000;p:0;crc:$58b2f47c),
        (n:'prom-1.1d';l:$100;p:0;crc:$7a2815b4),(n:'gg1_11.4d';l:$1000;p:0;crc:$ad447c80),
        (n:'gg1_10.4f';l:$1000;p:$1000;crc:$dd6f1afc),(n:'54xx.bin';l:$400;p:0;crc:$ee7357e0),());
        //Dig Dug
        digdug:array[0..19] of tipo_roms=(
        (n:'dd1a.1';l:$1000;p:0;crc:$a80ec984),(n:'dd1a.2';l:$1000;p:$1000;crc:$559f00bd),
        (n:'dd1a.3';l:$1000;p:$2000;crc:$8cbc6fe1),(n:'dd1a.4';l:$1000;p:$3000;crc:$d066f830),
        (n:'dd1a.5';l:$1000;p:0;crc:$6687933b),(n:'dd1a.6';l:$1000;p:$1000;crc:$843d857f),
        (n:'136007.113';l:$20;p:0;crc:$4cb9da99),(n:'136007.111';l:$100;p:$20;crc:$00c7c419),
        (n:'136007.112';l:$100;p:$120;crc:$e9b3e08e),(n:'136007.110';l:$100;p:0;crc:$7a2815b4),
        (n:'dd1.7';l:$1000;p:0;crc:$a41bce72),(n:'dd1.9';l:$800;p:0;crc:$f14a6fe1),
        (n:'dd1.15';l:$1000;p:0;crc:$e22957c8),(n:'dd1.14';l:$1000;p:$1000;crc:$2829ec99),
        (n:'dd1.13';l:$1000;p:$2000;crc:$458499e9),(n:'dd1.12';l:$1000;p:$3000;crc:$c58252a0),
        (n:'dd1.11';l:$1000;p:0;crc:$7b383983),(n:'dd1.10b';l:$1000;p:0;crc:$2cf399c2),
        (n:'53xx.bin';l:$400;p:0;crc:$b326fecb),());
        xsleena:array[0..29] of tipo_roms=(
        (n:'p9-08.ic66';l:$8000;p:$0;crc:$5179ae3f),(n:'pa-09.ic65';l:$8000;p:$8000;crc:$10a7c800),
        (n:'p1-0.ic29';l:$8000;p:$0;crc:$a1a860e2),(n:'p0-0.ic15';l:$8000;p:$8000;crc:$948b9757),
        (n:'p2-0.ic49';l:$8000;p:$8000;crc:$a5318cb8),(n:'pz-0.113';l:$800;p:$0;crc:$a432a907),
        (n:'pb-01.ic24';l:$8000;p:0;crc:$83c00dd8),
        (n:'p5-0.ic44';l:$8000;p:0;crc:$5c6c453c),(n:'p4-0.ic45';l:$8000;p:$8000;crc:$59d87a9a),
        (n:'p3-0.ic46';l:$8000;p:$10000;crc:$84884a2e),(n:'p6-0.ic43';l:$8000;p:$20000;crc:$8d637639),
        (n:'p7-0.ic42';l:$8000;p:$28000;crc:$71eec4e6),(n:'p8-0.ic41';l:$8000;p:$30000;crc:$7fc9704f),
        (n:'pk-0.ic136';l:$8000;p:0;crc:$11eb4247),(n:'pl-0.ic135';l:$8000;p:$8000;crc:$422b536e),
        (n:'pm-0.ic134';l:$8000;p:$10000;crc:$828c1b0c),(n:'pn-0.ic133';l:$8000;p:$18000;crc:$d37939e0),
        (n:'pc-0.ic114';l:$8000;p:$20000;crc:$8f0aa1a7),(n:'pd-0.ic113';l:$8000;p:$28000;crc:$45681910),
        (n:'pe-0.ic112';l:$8000;p:$30000;crc:$a8eeabc8),(n:'pf-0.ic111';l:$8000;p:$38000;crc:$e59a2f27),
        (n:'po-0.ic131';l:$8000;p:0;crc:$252976ae),(n:'pp-0.ic130';l:$8000;p:$8000;crc:$e6f1e8d5),
        (n:'pq-0.ic129';l:$8000;p:$10000;crc:$785381ed),(n:'pr-0.ic128';l:$8000;p:$18000;crc:$59754e3d),
        (n:'pg-0.ic109';l:$8000;p:$20000;crc:$4d977f33),(n:'ph-0.ic108';l:$8000;p:$28000;crc:$3f3b62a0),
        (n:'pi-0.ic107';l:$8000;p:$30000;crc:$76641ee3),(n:'pj-0.ic106';l:$8000;p:$38000;crc:$37671f36),());
        //Hard Head
        hardhead:array[0..18] of tipo_roms=(
        (n:'p1';l:$8000;p:0;crc:$c6147926),(n:'p2';l:$8000;p:$8000;crc:$faa2cf9a),
        (n:'p3';l:$8000;p:$10000;crc:$3d24755e),(n:'p4';l:$8000;p:$18000;crc:$0241ac79),
        (n:'p7';l:$8000;p:$20000;crc:$beba8313),(n:'p8';l:$8000;p:$28000;crc:$211a9342),
        (n:'p9';l:$8000;p:$30000;crc:$2ad430c4),(n:'p10';l:$8000;p:$38000;crc:$b6894517),
        (n:'p5';l:$8000;p:$0;crc:$e9aa6fba),(n:'p5';l:$8000;p:$8000;crc:$e9aa6fba),
        (n:'p6';l:$8000;p:$10000;crc:$15d5f5dd),(n:'p6';l:$8000;p:$18000;crc:$15d5f5dd),
        (n:'p11';l:$8000;p:$20000;crc:$055f4c29),(n:'p11';l:$8000;p:$28000;crc:$055f4c29),
        (n:'p12';l:$8000;p:$30000;crc:$9582e6db),(n:'p12';l:$8000;p:$38000;crc:$9582e6db),
        (n:'p14';l:$8000;p:0;crc:$41314ac1),(n:'p13';l:$8000;p:0;crc:$493c0b41),());
        //Hard Head 2
        hardhea2:array[0..15] of tipo_roms=(
        (n:'hrd-hd9';l:$8000;p:0;crc:$69c4c307),(n:'hrd-hd10';l:$10000;p:$10000;crc:$77ec5b0a),
        (n:'hrd-hd11';l:$10000;p:$20000;crc:$12af8f8e),(n:'hrd-hd12';l:$10000;p:$30000;crc:$35d13212),
        (n:'hrd-hd13';l:$10000;p:$40000;crc:$3225e7d7),
        (n:'hrd-hd1';l:$10000;p:$0;crc:$7e7b7a58),(n:'hrd-hd2';l:$10000;p:$10000;crc:$303ec802),
        (n:'hrd-hd3';l:$10000;p:$20000;crc:$3353b2c7),(n:'hrd-hd4';l:$10000;p:$30000;crc:$dbc1f9c1),
        (n:'hrd-hd5';l:$10000;p:$40000;crc:$f738c0af),(n:'hrd-hd6';l:$10000;p:$50000;crc:$bf90d3ca),
        (n:'hrd-hd7';l:$10000;p:$60000;crc:$992ce8cb),(n:'hrd-hd8';l:$10000;p:$70000;crc:$359597a4),
        (n:'hrd-hd15';l:$10000;p:0;crc:$bcbd88c3),(n:'hrd-hd14';l:$8000;p:0;crc:$79a3be51),());
        //Saboten Bombers
        sabotenb:array[0..7] of tipo_roms=(
        (n:'ic76.sb1';l:$40000;p:0;crc:$b2b0b2cf),(n:'ic75.sb2';l:$40000;p:$1;crc:$367e87b7),
        (n:'ic35.sb3';l:$10000;p:0;crc:$eb7bc99d),(n:'ic32.sb4';l:$200000;p:0;crc:$24c62205),
        (n:'ic100.sb5';l:$200000;p:0;crc:$b20f166e),(n:'ic30.sb6';l:$100000;p:0;crc:$288407af),
        (n:'ic27.sb7';l:$100000;p:0;crc:$43e33a7e),());
        //Bomb Jack Twin
        bjtwin:array[0..7] of tipo_roms=(
        (n:'93087-1.bin';l:$20000;p:0;crc:$93c84e2d),(n:'93087-2.bin';l:$20000;p:$1;crc:$30ff678a),
        (n:'93087-3.bin';l:$10000;p:0;crc:$aa13df7c),(n:'93087-4.bin';l:$100000;p:0;crc:$8a4f26d0),
        (n:'93087-5.bin';l:$100000;p:0;crc:$bb06245d),(n:'93087-6.bin';l:$100000;p:0;crc:$372d46dd),
        (n:'93087-7.bin';l:$100000;p:0;crc:$8da67808),());
        kncljoe:array[0..18] of tipo_roms=(
        (n:'kj-1.bin';l:$4000;p:0;crc:$4e4f5ff2),(n:'kj-2.bin';l:$4000;p:$4000;crc:$cb11514b),
        (n:'kjclr1.bin';l:$100;p:0;crc:$c3378ac2),(n:'kjclr2.bin';l:$100;p:$100;crc:$2126da97),
        (n:'kjclr3.bin';l:$100;p:$200;crc:$fde62164),(n:'kjprom5.bin';l:$20;p:$300;crc:$5a81dd9f),
        (n:'kj-3.bin';l:$4000;p:$8000;crc:$0f50697b),(n:'kjprom4.bin';l:$100;p:$320;crc:$48dc2066),
        (n:'kj-4.bin';l:$8000;p:0;crc:$a499ea10),(n:'kj-6.bin';l:$8000;p:$8000;crc:$815f5c0a),
        (n:'kj-7.bin';l:$4000;p:0;crc:$121fcccb),(n:'kj-9.bin';l:$4000;p:$4000;crc:$affbe3eb),
        (n:'kj-5.bin';l:$8000;p:$10000;crc:$11111759),(n:'kj-8.bin';l:$4000;p:$8000;crc:$e057e72a),
        (n:'kj-10.bin';l:$4000;p:0;crc:$74d3ba33),(n:'kj-11.bin';l:$4000;p:$4000;crc:$8ea01455),
        (n:'kj-12.bin';l:$4000;p:$8000;crc:$33367c41),(n:'kj-13.bin';l:$2000;p:$6000;crc:$0a0be3f5),());
        wardner:array[0..28] of tipo_roms=(
        (n:'wardner.17';l:$8000;p:0;crc:$c5dd56fd),(n:'b25-18.rom';l:$10000;p:$8000;crc:$9aab8ee2),
        (n:'b25-19.rom';l:$10000;p:$18000;crc:$95b68813),(n:'wardner.20';l:$8000;p:$28000;crc:$347f411b),
        (n:'wardner.07';l:$4000;p:0;crc:$1392b60d),(n:'wardner.06';l:$4000;p:$4000;crc:$0ed848da),
        (n:'b25-16.rom';l:$8000;p:0;crc:$e5202ff8),(n:'wardner.05';l:$4000;p:$8000;crc:$79792c86),
        (n:'b25-01.rom';l:$10000;p:0;crc:$42ec01fb),(n:'b25-02.rom';l:$10000;p:$10000;crc:$6c0130b7),
        (n:'b25-03.rom';l:$10000;p:$20000;crc:$b923db99),(n:'b25-04.rom';l:$10000;p:$30000;crc:$8059573c),
        (n:'b25-12.rom';l:$8000;p:0;crc:$15d08848),(n:'b25-15.rom';l:$8000;p:$8000;crc:$cdd2d408),
        (n:'b25-14.rom';l:$8000;p:$10000;crc:$5a2aef4f),(n:'b25-13.rom';l:$8000;p:$18000;crc:$be21db2b),
        (n:'b25-08.rom';l:$8000;p:0;crc:$883ccaa3),(n:'b25-11.rom';l:$8000;p:$8000;crc:$d6ebd510),
        (n:'b25-10.rom';l:$8000;p:$10000;crc:$b9a61e81),(n:'b25-09.rom';l:$8000;p:$18000;crc:$585411b7),
        (n:'82s137.1d';l:$400;p:0;crc:$cc5b3f53),(n:'82s137.1e';l:$400;p:$400;crc:$47351d55),
        (n:'82s137.3d';l:$400;p:$800;crc:$70b537b9),(n:'82s137.3e';l:$400;p:$c00;crc:$6edb2de8),
        (n:'82s131.3b';l:$200;p:$1000;crc:$9dfffaff),(n:'82s131.3a';l:$200;p:$1200;crc:$712bad47),
        (n:'82s131.2a';l:$200;p:$1400;crc:$ac843ca6),(n:'82s131.1a';l:$200;p:$1600;crc:$50452ff8),());
        //Big Karnak
        bigkarnk:array[0..12] of tipo_roms=(
        (n:'d16';l:$40000;p:0;crc:$44fb9c73),(n:'d19';l:$40000;p:$1;crc:$ff79dfdd),
        (n:'h5' ;l:$80000;p:$0;crc:$20e239ff),(n:'h5'; l:$80000;p:$80000;crc:$20e239ff),
        (n:'h10';l:$80000;p:$100000;crc:$ab442855),(n:'h10';l:$80000;p:$180000;crc:$ab442855),
        (n:'h8' ;l:$80000;p:$200000;crc:$83dce5a3),(n:'h8'; l:$80000;p:$280000;crc:$83dce5a3),
        (n:'h6' ;l:$80000;p:$300000;crc:$24e84b24),(n:'h6'; l:$80000;p:$380000;crc:$24e84b24),
        (n:'d5';l:$10000;p:0;crc:$3b73b9c5),(n:'d1';l:$40000;p:0;crc:$26444ad1),());
        //Thunder Hoop
        thoop:array[0..7] of tipo_roms=(
        (n:'th18dea1.040';l:$80000;p:0;crc:$59bad625),(n:'th161eb4.020';l:$40000;p:$1;crc:$6add61ed),
        (n:'c09' ;l:$100000;p:$0;crc:$06f0edbf),(n:'c10'; l:$100000;p:$100000;crc:$2d227085),
        (n:'c11';l:$100000;p:$200000;crc:$7403ef7e),(n:'c12';l:$100000;p:$300000;crc:$29a5ca36),
        (n:'sound';l:$100000;p:0;crc:$99f80961),());
        //Squash
        squash:array[0..7] of tipo_roms=(
        (n:'squash.d18';l:$20000;p:0;crc:$ce7aae96),(n:'squash.d16';l:$20000;p:$1;crc:$8ffaedd7),
        (n:'squash.c09' ;l:$80000;p:$0;crc:$0bb91c69),(n:'squash.c10'; l:$80000;p:$80000;crc:$892a035c),
        (n:'squash.c11';l:$80000;p:$100000;crc:$9e19694d),(n:'squash.c12';l:$80000;p:$180000;crc:$5c440645),
        (n:'squash.d01';l:$80000;p:0;crc:$a1b9651b),());
        //Biomechanical Toy
        biomtoy:array[0..12] of tipo_roms=(
        (n:'d18';l:$80000;p:0;crc:$4569ce64),(n:'d16';l:$80000;p:$1;crc:$739449bd),
        (n:'h6' ;l:$80000;p:$0;crc:$9416a729),(n:'j6'; l:$80000;p:$80000;crc:$e923728b),
        (n:'h7';l:$80000;p:$100000;crc:$9c984d7b),(n:'j7';l:$80000;p:$180000;crc:$0e18fac2),
        (n:'h9' ;l:$80000;p:$200000;crc:$8c1f6718),(n:'j9'; l:$80000;p:$280000;crc:$1c93f050),
        (n:'h10';l:$80000;p:$300000;crc:$aca1702b),(n:'j10';l:$80000;p:$380000;crc:$8e3e96cc),
        (n:'c1';l:$80000;p:0;crc:$0f02de7e),(n:'c3';l:$80000;p:$80000;crc:$914e4bbc),());
        exedexes:array[0..20] of tipo_roms=(
        (n:'11m_ee04.bin';l:$4000;p:0;crc:$44140dbd),(n:'10m_ee03.bin';l:$4000;p:$4000;crc:$bf72cfba),
        (n:'09m_ee02.bin';l:$4000;p:$8000;crc:$7ad95e2f),(n:'11e_ee01.bin';l:$4000;p:0;crc:$73cdf3b2),
        (n:'02d_e-02.bin';l:$100;p:0;crc:$8d0d5935),(n:'03d_e-03.bin';l:$100;p:$100;crc:$d3c17efc),
        (n:'04d_e-04.bin';l:$100;p:$200;crc:$58ba964c),(n:'06f_e-05.bin';l:$100;p:$300;crc:$35a03579),
        (n:'l04_e-10.bin';l:$100;p:$400;crc:$1dfad87a),(n:'c04_e-07.bin';l:$100;p:$500;crc:$850064e0),
        (n:'l09_e-11.bin';l:$100;p:$600;crc:$2bb68710),(n:'l10_e-12.bin';l:$100;p:$700;crc:$173184ef),
        (n:'j11_ee10.bin';l:$4000;p:0;crc:$bc83e265),(n:'j12_ee11.bin';l:$4000;p:$4000;crc:$0e0f300d),
        (n:'05c_ee00.bin';l:$2000;p:0;crc:$cadb75bd),(n:'h01_ee08.bin';l:$4000;p:0;crc:$96a65c1d),
        (n:'a03_ee06.bin';l:$4000;p:0;crc:$6039bdd1),(n:'a02_ee05.bin';l:$4000;p:$4000;crc:$b32d8252),
        (n:'c01_ee07.bin';l:$4000;p:0;crc:$3625a68d),(n:'h04_ee09.bin';l:$2000;p:$4000;crc:$6057c907),());
        //Gun Smoke
        gunsmoke:array[0..30] of tipo_roms=(
        (n:'09n_gs03.bin';l:$8000;p:0;crc:$40a06cef),(n:'10n_gs04.bin';l:$8000;p:$8000;crc:$8d4b423f),
        (n:'12n_gs05.bin';l:$8000;p:$10000;crc:$2b5667fb),(n:'14h_gs02.bin';l:$8000;p:0;crc:$cd7a2c38),
        (n:'03b_g-01.bin';l:$100;p:0;crc:$02f55589),(n:'04b_g-02.bin';l:$100;p:$100;crc:$e1e36dd9),
        (n:'05b_g-03.bin';l:$100;p:$200;crc:$989399c0),(n:'09d_g-04.bin';l:$100;p:$300;crc:$906612b5),
        (n:'14a_g-06.bin';l:$100;p:$400;crc:$4a9da18b),(n:'15a_g-07.bin';l:$100;p:$500;crc:$cb9394fc),
        (n:'09f_g-09.bin';l:$100;p:$600;crc:$3cee181e),(n:'08f_g-08.bin';l:$100;p:$700;crc:$ef91cdd2),
        (n:'06n_gs22.bin';l:$8000;p:0;crc:$dc9c508c),(n:'04n_gs21.bin';l:$8000;p:$8000;crc:$68883749),
        (n:'03n_gs20.bin';l:$8000;p:$10000;crc:$0be932ed),(n:'01n_gs19.bin';l:$8000;p:$18000;crc:$63072f93),
        (n:'06l_gs18.bin';l:$8000;p:$20000;crc:$f69a3c7c),(n:'04l_gs17.bin';l:$8000;p:$28000;crc:$4e98562a),
        (n:'03l_gs16.bin';l:$8000;p:$30000;crc:$0d99c3b3),(n:'01l_gs15.bin';l:$8000;p:$38000;crc:$7f14270e),
        (n:'06c_gs13.bin';l:$8000;p:0;crc:$f6769fc5),(n:'05c_gs12.bin';l:$8000;p:$8000;crc:$d997b78c),
        (n:'04c_gs11.bin';l:$8000;p:$10000;crc:$125ba58e),(n:'02c_gs10.bin';l:$8000;p:$18000;crc:$f469c13c),
        (n:'06a_gs09.bin';l:$8000;p:$20000;crc:$539f182d),(n:'05a_gs08.bin';l:$8000;p:$28000;crc:$e87e526d),
        (n:'04a_gs07.bin';l:$8000;p:$30000;crc:$4382c0d2),(n:'02a_gs06.bin';l:$8000;p:$38000;crc:$4cafe7a6),
        (n:'11f_gs01.bin';l:$4000;p:0;crc:$b61ece9b),(n:'11c_gs14.bin';l:$8000;p:0;crc:$0af4f7eb),());
        //1943
        hw1943:array[0..36] of tipo_roms=(
        (n:'bmu01c.12d';l:$8000;p:0;crc:$c686cc5c),(n:'bmu02c.13d';l:$10000;p:$8000;crc:$d8880a41),
        (n:'bmu03c.14d';l:$10000;p:$18000;crc:$3f0ee26c),(n:'bm04.5h';l:$8000;p:0;crc:$ee2bd2d7),
        (n:'bm.7k';l:$1000;p:0;crc:$cf4781bf),(n:'bm1.12a';l:$100;p:0;crc:$74421f18),
        (n:'bm2.13a';l:$100;p:$100;crc:$ac27541f),(n:'bm3.14a';l:$100;p:$200;crc:$251fb6ff),
        (n:'bm5.7f';l:$100;p:$300;crc:$206713d0),(n:'bm10.7l';l:$100;p:$400;crc:$33c2491c),
        (n:'bm9.6l';l:$100;p:$500;crc:$aeea4af7),(n:'bm12.12m';l:$100;p:$600;crc:$c18aa136),
        (n:'bm11.12l';l:$100;p:$700;crc:$405aae37),(n:'bm8.8c';l:$100;p:$800;crc:$c2010a9e),
        (n:'bm7.7c';l:$100;p:$900;crc:$b56f30c3),(n:'bm05.4k';l:$8000;p:0;crc:$46cb9d3d),
        (n:'bm06.10a';l:$8000;p:0;crc:$97acc8af),(n:'bm07.11a';l:$8000;p:$8000;crc:$d78f7197),
        (n:'bm08.12a';l:$8000;p:$10000;crc:$1a626608),(n:'bm09.14a';l:$8000;p:$18000;crc:$92408400),
        (n:'bm10.10c';l:$8000;p:$20000;crc:$8438a44a),(n:'bm11.11c';l:$8000;p:$28000;crc:$6c69351d),
        (n:'bm12.12c';l:$8000;p:$30000;crc:$5e7efdb7),(n:'bm13.14c';l:$8000;p:$38000;crc:$1143829a),
        (n:'bm15.10f';l:$8000;p:0;crc:$6b1a0443),(n:'bm16.11f';l:$8000;p:$8000;crc:$23c908c2),
        (n:'bm17.12f';l:$8000;p:$10000;crc:$46bcdd07),(n:'bm18.14f';l:$8000;p:$18000;crc:$e6ae7ba0),
        (n:'bm19.10j';l:$8000;p:$20000;crc:$868ababc),(n:'bm20.11j';l:$8000;p:$28000;crc:$0917e5d4),
        (n:'bm21.12j';l:$8000;p:$30000;crc:$9bfb0d89),(n:'bm22.14j';l:$8000;p:$38000;crc:$04f3c274),
        (n:'bm24.14k';l:$8000;p:0;crc:$11134036),(n:'bm25.14l';l:$8000;p:$8000;crc:$092cf9c1),
        (n:'bm14.5f';l:$8000;p:0;crc:$4d3c6401),(n:'bm23.8k';l:$8000;p:$8000;crc:$a52aecbd),());
        //1943 kai
        hw1943kai:array[0..36] of tipo_roms=(
        (n:'bmk01.12d';l:$8000;p:0;crc:$7d2211db),(n:'bmk02.13d';l:$10000;p:$8000;crc:$2ebbc8c5),
        (n:'bmk03.14d';l:$10000;p:$18000;crc:$475a6ac5),(n:'bmk04.5h';l:$8000;p:0;crc:$25f37957),
        (n:'bmk1.12a';l:$100;p:0;crc:$e001ea33),(n:'bmk2.13a';l:$100;p:$100;crc:$af34d91a),
        (n:'bmk3.14a';l:$100;p:$200;crc:$43e9f6ef),(n:'bmk5.7f';l:$100;p:$300;crc:$41878934),
        (n:'bmk10.7l';l:$100;p:$400;crc:$de44b748),(n:'bmk9.6l';l:$100;p:$500;crc:$59ea57c0),
        (n:'bmk12.12m';l:$100;p:$600;crc:$8765f8b0),(n:'bmk11.12l';l:$100;p:$700;crc:$87a8854e),
        (n:'bmk8.8c';l:$100;p:$800;crc:$dad17e2d),(n:'bmk7.7c';l:$100;p:$900;crc:$76307f8d),
        (n:'bmk05.4k';l:$8000;p:0;crc:$884a8692),(n:'bm.7k';l:$1000;p:0;crc:$cf4781bf),
        (n:'bmk06.10a';l:$8000;p:0;crc:$5f7e38b3),(n:'bmk07.11a';l:$8000;p:$8000;crc:$ff3751fd),
        (n:'bmk08.12a';l:$8000;p:$10000;crc:$159d51bd),(n:'bmk09.14a';l:$8000;p:$18000;crc:$8683e3d2),
        (n:'bmk10.10c';l:$8000;p:$20000;crc:$1e0d9571),(n:'bmk11.11c';l:$8000;p:$28000;crc:$f1fc5ee1),
        (n:'bmk12.12c';l:$8000;p:$30000;crc:$0f50c001),(n:'bmk13.14c';l:$8000;p:$38000;crc:$fd1acf8e),
        (n:'bmk15.10f';l:$8000;p:0;crc:$6b1a0443),(n:'bmk16.11f';l:$8000;p:$8000;crc:$9416fe0d),
        (n:'bmk17.12f';l:$8000;p:$10000;crc:$3d5acab9),(n:'bmk18.14f';l:$8000;p:$18000;crc:$7b62da1d),
        (n:'bmk19.10j';l:$8000;p:$20000;crc:$868ababc),(n:'bmk20.11j';l:$8000;p:$28000;crc:$b90364c1),
        (n:'bmk21.12j';l:$8000;p:$30000;crc:$8c7fe74a),(n:'bmk22.14j';l:$8000;p:$38000;crc:$d5ef8a0e),
        (n:'bmk24.14k';l:$8000;p:0;crc:$bf186ef2),(n:'bmk25.14l';l:$8000;p:$8000;crc:$a755faf1),
        (n:'bmk14.5f';l:$8000;p:0;crc:$cf0f5a53),(n:'bmk23.8k';l:$8000;p:$8000;crc:$17f77ef9),());
        hw1942:array[0..23] of tipo_roms=(
        (n:'srb-03.m3';l:$4000;p:0;crc:$d9dafcc3),(n:'srb-04.m4';l:$4000;p:$4000;crc:$da0cf924),
        (n:'srb-05.m5';l:$4000;p:$8000;crc:$d102911c),(n:'srb-06.m6';l:$2000;p:$c000;crc:$466f8248),
        (n:'srb-07.m7';l:$4000;p:$10000;crc:$0d31038c),(n:'sr-01.c11';l:$4000;p:0;crc:$bd87f06b),
        (n:'sb-5.e8';l:$100;p:0;crc:$93ab8153),(n:'sb-6.e9';l:$100;p:$100;crc:$8ab44f7d),
        (n:'sb-7.e10';l:$100;p:$200;crc:$f4ade9a4),(n:'sb-0.f1';l:$100;p:$300;crc:$6047d91b),
        (n:'sb-4.d6';l:$100;p:$400;crc:$4858968d),(n:'sb-8.k3';l:$100;p:$500;crc:$f6fad943),
        (n:'sr-02.f2';l:$2000;p:0;crc:$6ebca191),
        (n:'sr-08.a1';l:$2000;p:0;crc:$3884d9eb),(n:'sr-09.a2';l:$2000;p:$2000;crc:$999cf6e0),
        (n:'sr-10.a3';l:$2000;p:$4000;crc:$8edb273a),(n:'sr-11.a4';l:$2000;p:$6000;crc:$3a2726c3),
        (n:'sr-12.a5';l:$2000;p:$8000;crc:$1bd3d8bb),(n:'sr-13.a6';l:$2000;p:$a000;crc:$658f02c4),
        (n:'sr-14.l1';l:$4000;p:0;crc:$2528bec6),(n:'sr-15.l2';l:$4000;p:$4000;crc:$f89287aa),
        (n:'sr-16.n1';l:$4000;p:$8000;crc:$024418f8),(n:'sr-17.n2';l:$4000;p:$c000;crc:$e2c7e489),());
        jailbrek:array[0..13] of tipo_roms=(
        (n:'507p03.11d';l:$4000;p:$8000;crc:$a0b88dfd),(n:'507p02.9d';l:$4000;p:$c000;crc:$444b7d8e),
        (n:'507l08.4f';l:$4000;p:0;crc:$e3b7a226),(n:'507j09.5f';l:$4000;p:$4000;crc:$504f0912),
        (n:'507j04.3e';l:$4000;p:0;crc:$0d269524),(n:'507j05.4e';l:$4000;p:$4000;crc:$27d4f6f4),
        (n:'507j06.5e';l:$4000;p:$8000;crc:$717485cb),(n:'507j07.3f';l:$4000;p:$c000;crc:$e933086f),
        (n:'507j10.1f';l:$20;p:0;crc:$f1909605),(n:'507j11.2f';l:$20;p:$20;crc:$f70bb122),
        (n:'507j13.7f';l:$100;p:$40;crc:$d4fe5c97),(n:'507j12.6f';l:$100;p:$140;crc:$0266c7db),
        (n:'507l01.8c';l:$4000;p:$0;crc:$0c8a3605),());
        circusc:array[0..18] of tipo_roms=(
        (n:'380_s05.3h';l:$2000;p:$6000;crc:$48feafcf),(n:'380_r04.4h';l:$2000;p:$8000;crc:$c283b887),
        (n:'380_r03.5h';l:$2000;p:$a000;crc:$e90c0e86),(n:'380_q02.6h';l:$2000;p:$c000;crc:$4d847dc6),
        (n:'380_l14.5c';l:$2000;p:0;crc:$607df0fb),(n:'380_l15.7c';l:$2000;p:$2000;crc:$a6ad30e1),
        (n:'380_j12.4a';l:$2000;p:0;crc:$56e5b408),(n:'380_j13.5a';l:$2000;p:$2000;crc:$5aca0193),
        (n:'380_j06.11e';l:$2000;p:0;crc:$df0405c6),(n:'380_j07.12e';l:$2000;p:$2000;crc:$23dfe3a6),
        (n:'380_j08.13e';l:$2000;p:$4000;crc:$3ba95390),(n:'380_j09.14e';l:$2000;p:$6000;crc:$a9fba85a),
        (n:'380_j10.15e';l:$2000;p:$8000;crc:$0532347e),(n:'380_j11.16e';l:$2000;p:$a000;crc:$e1725d24),
        (n:'380_j18.2a';l:$20;p:0;crc:$10dd4eaa),(n:'380_j17.7b';l:$100;p:$20;crc:$13989357),
        (n:'380_q01.7h';l:$2000;p:$e000;crc:$18c20adf),(n:'380_j16.10c';l:$100;p:$120;crc:$c244f2aa),());
        ironhors:array[0..12] of tipo_roms=(
        (n:'560_k03.13c';l:$8000;p:$4000;crc:$395351b4),(n:'560_k02.12c';l:$4000;p:$c000;crc:$1cff3d59),
        (n:'560_h01.10c';l:$4000;p:0;crc:$2b17930f),(n:'560_h06.08f';l:$8000;p:0;crc:$f21d8c93),
        (n:'560_h05.07f';l:$8000;p:$1;crc:$60107859),(n:'560_h07.09f';l:$8000;p:$10000;crc:$c761ec73),
        (n:'560_h04.06f';l:$8000;p:$10001;crc:$c1486f61),(n:'03f_h08.bin';l:$100;p:0;crc:$9f6ddf83),
        (n:'04f_h09.bin';l:$100;p:$100;crc:$e6773825),(n:'05f_h10.bin';l:$100;p:$200;crc:$30a57860),
        (n:'10f_h12.bin';l:$100;p:$300;crc:$5eb33e73),(n:'10f_h11.bin';l:$100;p:$400;crc:$a63e37d8),());
        //Rtype
        rtype:array[0..24] of tipo_roms=(
        (n:'rt_r-h0-b.1b';l:$10000;p:1;crc:$591c7754),(n:'rt_r-l0-b.3b';l:$10000;p:$0;crc:$a1928df0),
        (n:'rt_r-h1-b.1c';l:$10000;p:$20001;crc:$a9d71eca),(n:'rt_r-l1-b.3c';l:$10000;p:$20000;crc:$0df3573d),
        (n:'rt_b-a0.3c';l:$8000;p:0;crc:$4e212fb0),(n:'rt_b-a1.3d';l:$8000;p:$8000;crc:$8a65bdff),
        (n:'rt_b-a2.3a';l:$8000;p:$10000;crc:$5a4ae5b9),(n:'rt_b-a3.3e';l:$8000;p:$18000;crc:$73327606),
        (n:'rt_b-b0.3j';l:$8000;p:0;crc:$a7b17491),(n:'rt_b-b1.3k';l:$8000;p:$8000;crc:$b9709686),
        (n:'rt_b-b2.3h';l:$8000;p:$10000;crc:$433b229a),(n:'rt_b-b3.3f';l:$8000;p:$18000;crc:$ad89b072),
        (n:'rt_r-00.1h';l:$10000;p:0;crc:$dad53bc0),(n:'rt_r-01.1j';l:$8000;p:$10000;crc:$5e441e7f),
        (n:'rt_r-01.1j';l:$8000;p:$18000;crc:$5e441e7f),(n:'rt_r-10.1k';l:$10000;p:$20000;crc:$d6a66298),
        (n:'rt_r-11.1l';l:$8000;p:$30000;crc:$791df4f8),(n:'rt_r-11.1l';l:$8000;p:$38000;crc:$791df4f8),
        (n:'rt_r-20.3h';l:$10000;p:$40000;crc:$fc247c8a),(n:'rt_r-21.3j';l:$8000;p:$50000;crc:$ed793841),
        (n:'rt_r-21.3j';l:$8000;p:$58000;crc:$ed793841),(n:'rt_r-30.3k';l:$10000;p:$60000;crc:$eb02a1cb),
        (n:'rt_r-31.3l';l:$8000;p:$70000;crc:$8558355d),(n:'rt_r-31.3l';l:$8000;p:$78000;crc:$8558355d),());
        //Hammering Harry
        hharry:array[0..14] of tipo_roms=(
        (n:'a-h0-v.rom';l:$20000;p:1;crc:$c52802a5),(n:'a-l0-v.rom';l:$20000;p:$0;crc:$f463074c),
        (n:'a-h1-0.rom';l:$10000;p:$60001;crc:$3ae21335),(n:'a-l1-0.rom';l:$10000;p:$60000;crc:$bc6ac5f9),
        (n:'hh_a0.rom';l:$20000;p:0;crc:$c577ba5f),(n:'hh_a1.rom';l:$20000;p:$20000;crc:$429d12ab),
        (n:'hh_a2.rom';l:$20000;p:$40000;crc:$b5b163b0),(n:'hh_a3.rom';l:$20000;p:$60000;crc:$8ef566a1),
        (n:'hh_00.rom';l:$20000;p:0;crc:$ec5127ef),(n:'hh_10.rom';l:$20000;p:$20000;crc:$def65294),
        (n:'hh_20.rom';l:$20000;p:$40000;crc:$bb0d6ad4),(n:'hh_30.rom';l:$20000;p:$60000;crc:$4351044e),
        (n:'a-sp-0.rom';l:$10000;p:0;crc:$80e210e7),(n:'a-v0-0.rom';l:$20000;p:0;crc:$faaacaff),());
        //R-Type 2
        rtype2:array[0..18] of tipo_roms=(
        (n:'rt2-a-h0-d.54';l:$20000;p:1;crc:$d8ece6f4),(n:'rt2-a-l0-d.60';l:$20000;p:$0;crc:$32cfb2e4),
        (n:'rt2-a-h1-d.53';l:$20000;p:$40001;crc:$4f6e9b15),(n:'rt2-a-l1-d.59';l:$20000;p:$40000;crc:$0fd123bf),
        (n:'ic50.7s';l:$20000;p:0;crc:$f3f8736e),(n:'ic51.7u';l:$20000;p:$20000;crc:$b4c543af),
        (n:'ic56.8s';l:$20000;p:$40000;crc:$4cb80d66),(n:'ic57.8u';l:$20000;p:$60000;crc:$bee128e0),
        (n:'ic65.9r';l:$20000;p:$80000;crc:$2dc9c71a),(n:'ic66.9u';l:$20000;p:$a0000;crc:$7533c428),
        (n:'ic63.9m';l:$20000;p:$c0000;crc:$a6ad67f2),(n:'ic64.9p';l:$20000;p:$e0000;crc:$3686d555),
        (n:'ic31.6l';l:$20000;p:0;crc:$2cd8f913),(n:'ic21.4l';l:$20000;p:$20000;crc:$5033066d),
        (n:'ic32.6m';l:$20000;p:$40000;crc:$ec3a0450),(n:'ic22.4m';l:$20000;p:$60000;crc:$db6176fc),
        (n:'ic17.4f';l:$10000;p:0;crc:$73ffecb4),(n:'ic14.4c';l:$20000;p:0;crc:$637172d5),());
        //Break Thru
        brkthru:array[0..14] of tipo_roms=(
        (n:'brkthru.1';l:$4000;p:$0;crc:$cfb4265f),(n:'brkthru.2';l:$8000;p:$4000;crc:$fa8246d9),
        (n:'brkthru.4';l:$8000;p:$c000;crc:$8cabf252),(n:'brkthru.3';l:$8000;p:$14000;crc:$2f2c40c2),
        (n:'brkthru.5';l:$8000;p:$8000;crc:$c309435f),(n:'brkthru.12';l:$2000;p:0;crc:$58c0b29b),
        (n:'brkthru.9';l:$8000;p:0;crc:$f54e50a7),(n:'brkthru.10';l:$8000;p:$8000;crc:$fd156945),
        (n:'brkthru.7';l:$8000;p:0;crc:$920cc56a),(n:'brkthru.6';l:$8000;p:$8000;crc:$fd3cee40),
        (n:'brkthru.11';l:$8000;p:$10000;crc:$c152a99b),(n:'brkthru.8';l:$8000;p:$10000;crc:$f67ee64e),
        (n:'brkthru.13';l:$100;p:0;crc:$aae44269),(n:'brkthru.14';l:$100;p:$100;crc:$f2d4822a),());
        //Darwin
        darwin:array[0..14] of tipo_roms=(
        (n:'darw_04.rom';l:$4000;p:$0;crc:$0eabf21c),(n:'darw_05.rom';l:$8000;p:$4000;crc:$e771f864),
        (n:'darw_07.rom';l:$8000;p:$c000;crc:$97ac052c),(n:'darw_06.rom';l:$8000;p:$14000;crc:$2a9fb208),
        (n:'darw_08.rom';l:$8000;p:$8000;crc:$6b580d58),(n:'darw_09.rom';l:$2000;p:0;crc:$067b4cf5),
        (n:'darw_10.rom';l:$8000;p:0;crc:$487a014c),(n:'darw_11.rom';l:$8000;p:$8000;crc:$548ce2d1),
        (n:'darw_03.rom';l:$8000;p:0;crc:$57d0350d),(n:'darw_02.rom';l:$8000;p:$8000;crc:$559a71ab),
        (n:'darw_12.rom';l:$8000;p:$10000;crc:$faba5fef),(n:'darw_01.rom';l:$8000;p:$10000;crc:$15a16973),
        (n:'df.12';l:$100;p:0;crc:$89b952ef),(n:'df.13';l:$100;p:$100;crc:$d595e91d),());
        srdarwin:array[0..13] of tipo_roms=(
        (n:'dy01-e.b14';l:$10000;p:$0;crc:$176e9299),(n:'dy00.b16';l:$10000;p:$10000;crc:$2bf6b461),
        (n:'dy03.b4';l:$10000;p:$0000;crc:$44f2a4f9),(n:'dy02.b5';l:$10000;p:$10000;crc:$522d9a9e),
        (n:'dy05.b6';l:$4000;p:$0000;crc:$8780e8a3),(n:'dy04.d7';l:$8000;p:$8000;crc:$2ae3591c),
        (n:'dy07.h16';l:$8000;p:$0000;crc:$97eaba60),(n:'dy06.h14';l:$8000;p:$8000;crc:$c279541b),
        (n:'dy09.k13';l:$8000;p:$10000;crc:$d30d1745),(n:'dy08.k11';l:$8000;p:$18000;crc:$71d645fd),
        (n:'dy11.k16';l:$8000;p:$20000;crc:$fd9ccc5b),(n:'dy10.k14';l:$8000;p:$28000;crc:$88770ab8),
        (n:'id8751h.mcu';l:$1000;p:0;crc:$11cd6ca4),());
        //Double Dragon
        ddragon:array[0..21] of tipo_roms=(
        (n:'21j-1-5.26';l:$8000;p:$0;crc:$42045dfd),(n:'21j-2-3.25';l:$8000;p:$8000;crc:$5779705e),
        (n:'21j-3.24';l:$8000;p:$10000;crc:$3bdea613),(n:'21j-4-1.23';l:$8000;p:$18000;crc:$728f87b9),
        (n:'63701.bin';l:$4000;p:$c000;crc:$f5232d03),(n:'21j-0-1';l:$8000;p:$8000;crc:$9efa95bb),
        (n:'21j-5';l:$8000;p:0;crc:$7a8b8db4),(n:'21j-8';l:$10000;p:0;crc:$7c435887),
        (n:'21j-9';l:$10000;p:$10000;crc:$c6640aed),(n:'21j-i';l:$10000;p:$20000;crc:$5effb0a0),
        (n:'21j-j';l:$10000;p:$30000;crc:$5fb42e7c),(n:'21j-a';l:$10000;p:0;crc:$574face3),
        (n:'21j-b';l:$10000;p:$10000;crc:$40507a76),(n:'21j-c';l:$10000;p:$20000;crc:$bb0bc76f),
        (n:'21j-d';l:$10000;p:$30000;crc:$cb4f231b),(n:'21j-e';l:$10000;p:$40000;crc:$a0a0c261),
        (n:'21j-f';l:$10000;p:$50000;crc:$6ba152f6),(n:'21j-g';l:$10000;p:$60000;crc:$3220a0b6),
        (n:'21j-h';l:$10000;p:$70000;crc:$65c7517d),(n:'21j-6';l:$10000;p:0;crc:$34755de3),
        (n:'21j-7';l:$10000;p:$10000;crc:$904de6f8),());
        //Double Dragon II
        ddragon2:array[0..17] of tipo_roms=(
        (n:'26a9-04.bin';l:$8000;p:$0;crc:$f2cfc649),(n:'26aa-03.bin';l:$8000;p:$8000;crc:$44dd5d4b),
        (n:'26ab-0.bin';l:$8000;p:$10000;crc:$49ddddcd),(n:'26ac-0e.63';l:$8000;p:$18000;crc:$57acad2c),
        (n:'26ae-0.bin';l:$10000;p:$0;crc:$ea437867),(n:'26ad-0.bin';l:$8000;p:$0;crc:$75e36cd6),
        (n:'26a8-0e.19';l:$10000;p:0;crc:$4e80cd36),
        (n:'26j4-0.bin';l:$20000;p:0;crc:$a8c93e76),(n:'26j5-0.bin';l:$20000;p:$20000;crc:$ee555237),
        (n:'26j0-0.bin';l:$20000;p:0;crc:$db309c84),(n:'26j1-0.bin';l:$20000;p:$20000;crc:$c3081e0c),
        (n:'26af-0.bin';l:$20000;p:$40000;crc:$3a615aad),(n:'26j2-0.bin';l:$20000;p:$60000;crc:$589564ae),
        (n:'26j3-0.bin';l:$20000;p:$80000;crc:$daf040d6),(n:'26a10-0.bin';l:$20000;p:$a0000;crc:$6d16d889),
        (n:'26j6-0.bin';l:$20000;p:0;crc:$a84b2a29),(n:'26j7-0.bin';l:$20000;p:$20000;crc:$bc6a48d5),());
        mrdo:array[0..13] of tipo_roms=(
        (n:'a4-01.bin';l:$2000;p:0;crc:$03dcfba2),(n:'c4-02.bin';l:$2000;p:$2000;crc:$0ecdd39c),
        (n:'e4-03.bin';l:$2000;p:$4000;crc:$358f5dc2),(n:'f4-04.bin';l:$2000;p:$6000;crc:$f4190cfc),
        (n:'u02--2.bin';l:$20;p:0;crc:$238a65d7),(n:'t02--3.bin';l:$20;p:$20;crc:$ae263dc0),
        (n:'f10--1.bin';l:$20;p:$40;crc:$16ee4ca2),
        (n:'s8-09.bin';l:$1000;p:0;crc:$aa80c5b6),(n:'u8-10.bin';l:$1000;p:$1000;crc:$d20ec85b),
        (n:'r8-08.bin';l:$1000;p:0;crc:$dbdc9ffa),(n:'n8-07.bin';l:$1000;p:$1000;crc:$4b9973db),
        (n:'h5-05.bin';l:$1000;p:0;crc:$e1218cc5),(n:'k5-06.bin';l:$1000;p:$1000;crc:$b1f68b04),());
        //The Glob
        theglob:array[0..9] of tipo_roms=(
        (n:'globu10.bin';l:$1000;p:0;crc:$08fdb495),(n:'globu9.bin';l:$1000;p:$1000;crc:$827cd56c),
        (n:'globu8.bin';l:$1000;p:$2000;crc:$d1219966),(n:'globu7.bin';l:$1000;p:$3000;crc:$b1649da7),
        (n:'globu6.bin';l:$1000;p:$4000;crc:$b3457e67),(n:'globu5.bin';l:$1000;p:$5000;crc:$89d582cd),
        (n:'globu4.bin';l:$1000;p:$6000;crc:$7ee9fdeb),(n:'globu11.bin';l:$800;p:$7000;crc:$9e05dee3),
        (n:'82s123.u66';l:$20;p:0;crc:$f4f6ddc5),());
        //Super Glob
        suprglob:array[0..9] of tipo_roms=(
        (n:'u10';l:$1000;p:0;crc:$c0141324),(n:'u9';l:$1000;p:$1000;crc:$58be8128),
        (n:'u8';l:$1000;p:$2000;crc:$6d088c16),(n:'u7';l:$1000;p:$3000;crc:$b2768203),
        (n:'u6';l:$1000;p:$4000;crc:$976c8f46),(n:'u5';l:$1000;p:$5000;crc:$340f5290),
        (n:'u4';l:$1000;p:$6000;crc:$173bd589),(n:'u11';l:$800;p:$7000;crc:$d45b740d),
        (n:'82s123.u66';l:$20;p:0;crc:$f4f6ddc5),());
        //Tiger Heli
        tigerh:array[0..18] of tipo_roms=(
        (n:'a47_00-1.8p';l:$4000;p:0;crc:$4be73246),(n:'a47_01-1.8n';l:$4000;p:$4000;crc:$aad04867),
        (n:'a47_02-1.8k';l:$4000;p:$8000;crc:$4843f15c),(n:'a47_03.12d';l:$2000;p:0;crc:$d105260f),
        (n:'82s129.12q';l:$100;p:0;crc:$2c69350d),(n:'82s129.12m';l:$100;p:$100;crc:$7142e972),
        (n:'a47_14.6a';l:$800;p:0;crc:$4042489f),(n:'82s129.12n';l:$100;p:$200;crc:$25f273f2),
        (n:'a47_05.6f';l:$2000;p:0;crc:$c5325b49),(n:'a47_04.6g';l:$2000;p:$2000;crc:$cd59628e),
        (n:'a47_13.8j';l:$4000;p:0;crc:$739a7e7e),(n:'a47_12.6j';l:$4000;p:$4000;crc:$c064ecdb),
        (n:'a47_11.8h';l:$4000;p:$8000;crc:$744fae9b),(n:'a47_10.6h';l:$4000;p:$c000;crc:$e1cf844e),
        (n:'a47_09.4m';l:$4000;p:0;crc:$31fae8a8),(n:'a47_08.6m';l:$4000;p:$4000;crc:$e539af2b),
        (n:'a47_07.6n';l:$4000;p:$8000;crc:$02fdd429),(n:'a47_06.6p';l:$4000;p:$c000;crc:$11fbcc8c),());
        //Slap Fight
        slapfigh:array[0..17] of tipo_roms=(
        (n:'a77_00.8p';l:$8000;p:0;crc:$674c0e0f),(n:'a77_01.8n';l:$8000;p:$8000;crc:$3c42e4a7),
        (n:'a77_02.12d';l:$2000;p:0;crc:$87f4705a),(n:'a77_13.6a';l:$800;p:0;crc:$a70c81d9),
        (n:'21_82s129.12q';l:$100;p:0;crc:$a0efaf99),(n:'20_82s129.12m';l:$100;p:$100;crc:$a56d57e5),
        (n:'19_82s129.12n';l:$100;p:$200;crc:$5cbf9fbf),
        (n:'a77_04.6f';l:$2000;p:0;crc:$2ac7b943),(n:'a77_03.6g';l:$2000;p:$2000;crc:$33cadc93),
        (n:'a77_12.8j';l:$8000;p:0;crc:$8545d397),(n:'a77_11.7j';l:$8000;p:$8000;crc:$b1b7b925),
        (n:'a77_10.8h';l:$8000;p:$10000;crc:$422d946b),(n:'a77_09.7h';l:$8000;p:$18000;crc:$587113ae),
        (n:'a77_08.6k';l:$8000;p:0;crc:$b6358305),(n:'a77_07.6m';l:$8000;p:$8000;crc:$e92d9d60),
        (n:'a77_06.6n';l:$8000;p:$10000;crc:$5faeeea3),(n:'a77_05.6p';l:$8000;p:$18000;crc:$974e2ea9),());
        lkage:array[0..9] of tipo_roms=(
        (n:'a54-01-2.37';l:$8000;p:0;crc:$60fd9734),(n:'a54-02-2.38';l:$8000;p:$8000;crc:$878a25ce),
        (n:'a54-04.54';l:$8000;p:0;crc:$541faf9a),(n:'a54-09.53';l:$800;p:0;crc:$0e8b8846),
        (n:'a54-03.51';l:$4000;p:0;crc:$493e76d8),
        (n:'a54-05-1.84';l:$4000;p:0;crc:$0033c06a),(n:'a54-06-1.85';l:$4000;p:$4000;crc:$9f04d9ad),
        (n:'a54-07-1.86';l:$4000;p:$8000;crc:$b20561a4),(n:'a54-08-1.87';l:$4000;p:$c000;crc:$3ff3b230),());
        cabal:array[0..25] of tipo_roms=(
        (n:'13.7h';l:$10000;p:0;crc:$00abbe0c),(n:'11.6h';l:$10000;p:$1;crc:$44736281),
        (n:'12.7j';l:$10000;p:$20000;crc:$d763a47c),(n:'10.6j';l:$10000;p:$20001;crc:$96d5e8af),
        (n:'5-6s';l:$4000;p:0;crc:$6a76955a),
        (n:'sp_rom1.bin';l:$10000;p:0;crc:$34d3cac8),(n:'sp_rom2.bin';l:$10000;p:$1;crc:$4e49c28e),
        (n:'sp_rom3.bin';l:$10000;p:$20000;crc:$7065e840),(n:'sp_rom4.bin';l:$10000;p:$20001;crc:$6a0e739d),
        (n:'sp_rom5.bin';l:$10000;p:$40000;crc:$0e1ec30e),(n:'sp_rom6.bin';l:$10000;p:$40001;crc:$581a50c1),
        (n:'sp_rom7.bin';l:$10000;p:$60000;crc:$55c44764),(n:'sp_rom8.bin';l:$10000;p:$60001;crc:$702735c9),
        (n:'bg_rom1.bin';l:$10000;p:0;crc:$1023319b),(n:'bg_rom2.bin';l:$10000;p:$1;crc:$3b6d2b09),
        (n:'bg_rom3.bin';l:$10000;p:$20000;crc:$420b0801),(n:'bg_rom4.bin';l:$10000;p:$20001;crc:$77bc7a60),
        (n:'bg_rom5.bin';l:$10000;p:$40000;crc:$543fcb37),(n:'bg_rom6.bin';l:$10000;p:$40001;crc:$0bc50075),
        (n:'bg_rom7.bin';l:$10000;p:$60000;crc:$d28d921e),(n:'bg_rom8.bin';l:$10000;p:$60001;crc:$67e4fe47),
        (n:'4-3n';l:$2000;p:0;crc:$4038eff2),(n:'3-3p';l:$8000;p:$8000;crc:$d9defcbf),
        (n:'2-1s';l:$10000;p:0;crc:$850406b4),(n:'1-1u';l:$10000;p:$10000;crc:$8b3e0789),());
        //Ghouls and ghosts
        ghouls:array[0..26] of tipo_roms=(
        (n:'dme_29.10h';l:$20000;p:0;crc:$166a58a2),(n:'dme_30.10j';l:$20000;p:$1;crc:$7ac8407a),
        (n:'dme_27.9h';l:$20000;p:$40000;crc:$f734b2be),(n:'dme_28.9j';l:$20000;p:$40001;crc:$03d3e714),
        (n:'dm-17.7j';l:$80000;p:$80000;crc:$3ea1b0f2),(n:'dm_26.10a';l:$10000;p:0;crc:$3692f6e5),
        (n:'dm-05.3a';l:$80000;p:0;crc:$0ba9c0b0),(n:'dm-07.3f';l:$80000;p:2;crc:$5d760ab9),
        (n:'dm-06.3c';l:$80000;p:4;crc:$4ba90b59),(n:'dm-08.3g';l:$80000;p:6;crc:$4bdee9de),
        (n:'09.4a';l:$10000;p:$200000;crc:$ae24bb19),(n:'18.7a';l:$10000;p:$200001;crc:$d34e271a),
        (n:'13.4e';l:$10000;p:$200002;crc:$3f70dd37),(n:'22.7e';l:$10000;p:$200003;crc:$7e69e2e6),
        (n:'11.4c';l:$10000;p:$200004;crc:$37c9b6c6),(n:'20.7c';l:$10000;p:$200005;crc:$2f1345b4),
        (n:'15.4g';l:$10000;p:$200006;crc:$3c2a212a),(n:'24.7g';l:$10000;p:$200007;crc:$889aac05),
        (n:'10.4b';l:$10000;p:$280000;crc:$bcc0f28c),(n:'19.7b';l:$10000;p:$280001;crc:$2a40166a),
        (n:'14.4f';l:$10000;p:$280002;crc:$20f85c03),(n:'23.7f';l:$10000;p:$280003;crc:$8426144b),
        (n:'12.4d';l:$10000;p:$280004;crc:$da088d61),(n:'21.7d';l:$10000;p:$280005;crc:$17e11df0),
        (n:'16.4h';l:$10000;p:$280006;crc:$f187ba1c),(n:'25.7h';l:$10000;p:$280007;crc:$29f79c78),());
        //Final Fight
        ffight:array[0..12] of tipo_roms=(
        (n:'ff_36.11f';l:$20000;p:0;crc:$f9a5ce83),(n:'ff_42.11h';l:$20000;p:$1;crc:$65f11215),
        (n:'ff_37.12f';l:$20000;p:$40000;crc:$e1033784),(n:'ffe_43.12h';l:$20000;p:$40001;crc:$995e968a),
        (n:'ff-32m.8h';l:$80000;p:$80000;crc:$c747696e),(n:'ff_09.12b';l:$10000;p:0;crc:$b8367eb5),
        (n:'ff-5m.7a';l:$80000;p:0;crc:$9c284108),(n:'ff-7m.9a';l:$80000;p:2;crc:$a7584dfb),
        (n:'ff-1m.3a';l:$80000;p:4;crc:$0b605e44),(n:'ff-3m.5a';l:$80000;p:6;crc:$52291cd2),
        (n:'ff_18.11c';l:$20000;p:0;crc:$375c66e7),(n:'ff_19.12c';l:$20000;p:$20000;crc:$1ef137f9),());
        //King of Dragons
        kod:array[0..19] of tipo_roms=(
        (n:'kde_30.11e';l:$20000;p:$00000;crc:$c7414fd4),(n:'kde_37.11f';l:$20000;p:$00001;crc:$a5bf40d2),
        (n:'kde_31.12e';l:$20000;p:$40000;crc:$1fffc7bd),(n:'kde_38.12f';l:$20000;p:$40001;crc:$89e57a82),
        (n:'kde_28.9e'; l:$20000;p:$80000;crc:$9367bcd9),(n:'kde_35.9f'; l:$20000;p:$80001;crc:$4ca6a48a),
        (n:'kde_29.10e';l:$20000;p:$c0000;crc:$6a0ba878),(n:'kde_36.10f';l:$20000;p:$c0001;crc:$b509b39d),
        (n:'kd_9.12a';l:$10000;p:0;crc:$bac6ec26),
        (n:'kd-5m.4a';l:$80000;p:$000000;crc:$e45b8701),(n:'kd-7m.6a';l:$80000;p:$000002;crc:$a7750322),
        (n:'kd-1m.3a';l:$80000;p:$000004;crc:$5f74bf78),(n:'kd-3m.5a';l:$80000;p:$000006;crc:$5e5303bf),
        (n:'kd-6m.4c';l:$80000;p:$200000;crc:$113358f3),(n:'kd-8m.6c';l:$80000;p:$200002;crc:$38853c44),
        (n:'kd-2m.3c';l:$80000;p:$200004;crc:$9ef36604),(n:'kd-4m.5c';l:$80000;p:$200006;crc:$402b9b4f),
        (n:'kd_18.11c';l:$20000;p:0;crc:$69ecb2c8),(n:'kd_19.12c';l:$20000;p:$20000;crc:$02d851c1),());
        //Street Fighter 2
        sf2:array[0..23] of tipo_roms=(
        (n:'sf2e_30g.11e';l:$20000;p:$00000;crc:$fe39ee33),(n:'sf2e_37g.11f';l:$20000;p:$00001;crc:$fb92cd74),
        (n:'sf2e_31g.12e';l:$20000;p:$40000;crc:$69a0a301),(n:'sf2e_38g.12f';l:$20000;p:$40001;crc:$5e22db70),
        (n:'sf2e_28g.9e' ;l:$20000;p:$80000;crc:$8bf9f1e5),(n:'sf2e_35g.9f'; l:$20000;p:$80001;crc:$626ef934),
        (n:'sf2_29b.10e' ;l:$20000;p:$c0000;crc:$bb4af315),(n:'sf2_36b.10f'; l:$20000;p:$c0001;crc:$c02a13eb),
        (n:'sf2_09.12a';l:$10000;p:0;crc:$a4823a1b),
        (n:'sf2-5m.4a';l:$80000;p:$000000;crc:$22c9cc8e),(n:'sf2-7m.6a';l:$80000;p:$000002;crc:$57213be8),
        (n:'sf2-1m.3a';l:$80000;p:$000004;crc:$ba529b4f),(n:'sf2-3m.5a';l:$80000;p:$000006;crc:$4b1b33a8),
        (n:'sf2-6m.4c';l:$80000;p:$200000;crc:$2c7e2229),(n:'sf2-8m.6c';l:$80000;p:$200002;crc:$b5548f17),
        (n:'sf2-2m.3c';l:$80000;p:$200004;crc:$14b84312),(n:'sf2-4m.5c';l:$80000;p:$200006;crc:$5e9cd89a),
        (n:'sf2-13m.4d';l:$80000;p:$400000;crc:$994bfa58),(n:'sf2-15m.6d';l:$80000;p:$400002;crc:$3e66ad9d),
        (n:'sf2-9m.3d';l:$80000;p:$400004;crc:$c1befaa8),(n:'sf2-11m.5d';l:$80000;p:$400006;crc:$0627c831),
        (n:'sf2_18.11c';l:$20000;p:0;crc:$7f162009),(n:'sf2_19.12c';l:$20000;p:$20000;crc:$beade53f),());
        //Strider
        strider:array[0..16] of tipo_roms=(
        (n:'30.11f';l:$20000;p:$00000;crc:$da997474),(n:'35.11h';l:$20000;p:$00001;crc:$5463aaa3),
        (n:'31.12f';l:$20000;p:$40000;crc:$d20786db),(n:'36.12h';l:$20000;p:$40001;crc:$21aa2863),
        (n:'st-14.8h';l:$80000;p:$80000;crc:$9b3cfc08),(n:'09.12b';l:$10000;p:0;crc:$2ed403bc),
        (n:'st-2.8a';l:$80000;p:$000000;crc:$4eee9aea),(n:'st-11.10a';l:$80000;p:$000002;crc:$2d7f21e4),
        (n:'st-5.4a';l:$80000;p:$000004;crc:$7705aa46),(n:'st-9.6a';l:$80000;p:$000006;crc:$5b18b722),
        (n:'st-1.7a';l:$80000;p:$200000;crc:$005f000b),(n:'st-10.9a';l:$80000;p:$200002;crc:$b9441519),
        (n:'st-4.3a';l:$80000;p:$200004;crc:$b7d04e8b),(n:'st-8.5a';l:$80000;p:$200006;crc:$6b4713b4),
        (n:'18.11c';l:$20000;p:0;crc:$4386bc80),(n:'19.12c';l:$20000;p:$20000;crc:$444536d7),());
        //3 Wonder
        wonder3:array[0..19] of tipo_roms=(
        (n:'rte_30a.11f';l:$20000;p:$00000;crc:$ef5b8b33),(n:'rte_35a.11h';l:$20000;p:$00001;crc:$7d705529),
        (n:'rte_31a.12f';l:$20000;p:$40000;crc:$32835e5e),(n:'rte_36a.12h';l:$20000;p:$40001;crc:$7637975f),
        (n:'rt_28a.9f' ;l:$20000;p:$80000;crc:$054137c8),(n:'rt_33a.9h'; l:$20000;p:$80001;crc:$7264cb1b),
        (n:'rte_29a.10f' ;l:$20000;p:$c0000;crc:$cddaa919),(n:'rte_34a.10h'; l:$20000;p:$c0001;crc:$ed52e7e5),
        (n:'rt_9.12b';l:$10000;p:0;crc:$abfca165),
        (n:'rt-5m.7a';l:$80000;p:$000000;crc:$86aef804),(n:'rt-7m.9a';l:$80000;p:$000002;crc:$4f057110),
        (n:'rt-1m.3a';l:$80000;p:$000004;crc:$902489d0),(n:'rt-3m.5a';l:$80000;p:$000006;crc:$e35ce720),
        (n:'rt-6m.8a';l:$80000;p:$200000;crc:$13cb0e7c),(n:'rt-8m.10a';l:$80000;p:$200002;crc:$1f055014),
        (n:'rt-2m.4a';l:$80000;p:$200004;crc:$e9a034f4),(n:'rt-4m.6a';l:$80000;p:$200006;crc:$df0eea8b),
        (n:'rt_18.11c';l:$20000;p:0;crc:$26b211ab),(n:'rt_19.12c';l:$20000;p:$20000;crc:$dbe64ad0),());
        //Captain Commando
        captcomm:array[0..15] of tipo_roms=(
        (n:'cce_23d.8f';l:$80000;p:$00000;crc:$42c814c5),(n:'cc_22d.7f';l:$80000;p:$80000;crc:$0fd34195),
        (n:'cc_24d.9e';l:$20000;p:$100000;crc:$3a794f25),(n:'cc_28d.9f';l:$20000;p:$100001;crc:$fc3c2906),
        (n:'cc_09.11a';l:$10000;p:0;crc:$698e8b58),
        (n:'cc-5m.3a';l:$80000;p:$000000;crc:$7261d8ba),(n:'cc-7m.5a';l:$80000;p:$000002;crc:$6a60f949),
        (n:'cc-1m.4a';l:$80000;p:$000004;crc:$00637302),(n:'cc-3m.6a';l:$80000;p:$000006;crc:$cc87cf61),
        (n:'cc-6m.7a';l:$80000;p:$200000;crc:$28718bed),(n:'cc-8m.9a';l:$80000;p:$200002;crc:$d4acc53a),
        (n:'cc-2m.8a';l:$80000;p:$200004;crc:$0c69f151),(n:'cc-4m.10a';l:$80000;p:$200006;crc:$1f9ebb97),
        (n:'cc_18.11c';l:$20000;p:0;crc:$6de2c2db),(n:'cc_19.12c';l:$20000;p:$20000;crc:$b99091ae),());
        //Knights of the round
        knights:array[0..13] of tipo_roms=(
        (n:'kr_23e.8f';l:$80000;p:$00000;crc:$1b3997eb),(n:'kr_22.7f';l:$80000;p:$80000;crc:$d0b671a9),
        (n:'kr_09.11a';l:$10000;p:0;crc:$5e44d9ee),
        (n:'kr-5m.3a';l:$80000;p:$000000;crc:$9e36c1a4),(n:'kr-7m.5a';l:$80000;p:$000002;crc:$c5832cae),
        (n:'kr-1m.4a';l:$80000;p:$000004;crc:$f095be2d),(n:'kr-3m.6a';l:$80000;p:$000006;crc:$179dfd96),
        (n:'kr-6m.7a';l:$80000;p:$200000;crc:$1f4298d2),(n:'kr-8m.9a';l:$80000;p:$200002;crc:$37fa8751),
        (n:'kr-2m.8a';l:$80000;p:$200004;crc:$0200bc3d),(n:'kr-4m.10a';l:$80000;p:$200006;crc:$0bb2b4e7),
        (n:'kr_18.11c';l:$20000;p:0;crc:$da69d15f),(n:'kr_19.12c';l:$20000;p:$20000;crc:$bfc654e9),());
        //Street Fighter II': Champion Edition
        sf2ce:array[0..18] of tipo_roms=(
        (n:'s92e_23b.8f';l:$80000;p:$00000;crc:$0aaa1a3a),(n:'s92_22b.7f';l:$80000;p:$80000;crc:$2bbe15ed),
        (n:'s92_21a.6f';l:$80000;p:$100000;crc:$925a7877),(n:'s92_09.11a';l:$10000;p:0;crc:$08f6b60e),
        (n:'s92-1m.3a';l:$80000;p:$000000;crc:$03b0d852),(n:'s92-3m.5a';l:$80000;p:$000002;crc:$840289ec),
        (n:'s92-2m.4a';l:$80000;p:$000004;crc:$cdb5f027),(n:'s92-4m.6a';l:$80000;p:$000006;crc:$e2799472),
        (n:'s92-5m.7a';l:$80000;p:$200000;crc:$ba8a2761),(n:'s92-7m.9a';l:$80000;p:$200002;crc:$e584bfb5),
        (n:'s92-6m.8a';l:$80000;p:$200004;crc:$21e3f87d),(n:'s92-8m.10a';l:$80000;p:$200006;crc:$befc47df),
        (n:'s92-10m.3c';l:$80000;p:$400000;crc:$960687d5),(n:'s92-12m.5c';l:$80000;p:$400002;crc:$978ecd18),
        (n:'s92-11m.4c';l:$80000;p:$400004;crc:$d6ec9a0a),(n:'s92-13m.6c';l:$80000;p:$400006;crc:$ed2c67f6),
        (n:'s92_18.11c';l:$20000;p:0;crc:$7f162009),(n:'s92_19.12c';l:$20000;p:$20000;crc:$beade53f),());
         //Cadillacs and Dinosaurs
        dino:array[0..16] of tipo_roms=(
        (n:'cde_23a.8f';l:$80000;p:$00000;crc:$8f4e585e),(n:'cde_22a.7f';l:$80000;p:$80000;crc:$9278aa12),
        (n:'cde_21a.6f';l:$80000;p:$100000;crc:$66d23de2),(n:'cd_q.5k';l:$20000;p:0;crc:$605fdb0b),
        (n:'cd-1m.3a';l:$80000;p:$000000;crc:$8da4f917),(n:'cd-3m.5a';l:$80000;p:$000002;crc:$6c40f603),
        (n:'cd-2m.4a';l:$80000;p:$000004;crc:$09c8fc2d),(n:'cd-4m.6a';l:$80000;p:$000006;crc:$637ff38f),
        (n:'cd-5m.7a';l:$80000;p:$200000;crc:$470befee),(n:'cd-7m.9a';l:$80000;p:$200002;crc:$22bfb7a3),
        (n:'cd-6m.8a';l:$80000;p:$200004;crc:$e7599ac4),(n:'cd-8m.10a';l:$80000;p:$200006;crc:$211b4b15),
        (n:'cd-q1.1k';l:$80000;p:$00000;crc:$60927775),(n:'cd-q2.2k';l:$80000;p:$80000;crc:$770f4c47),
        (n:'cd-q3.3k';l:$80000;p:$100000;crc:$2f273ffc),(n:'cd-q4.4k';l:$80000;p:$180000;crc:$2c67821d),());
        //The Punisher
        punisher:array[0..22] of tipo_roms=(
        (n:'pse_26.11e';l:$20000;p:$000000;crc:$389a99d2),(n:'pse_30.11f';l:$20000;p:$000001;crc:$68fb06ac),
        (n:'pse_27.12e';l:$20000;p:$040000;crc:$3eb181c3),(n:'pse_31.12f';l:$20000;p:$040001;crc:$37108e7b),
        (n:'pse_24.9e';l:$20000;p:$080000;crc:$0f434414),(n:'pse_28.9f';l:$20000;p:$080001;crc:$b732345d),
        (n:'pse_25.10e';l:$20000;p:$0c0000;crc:$b77102e2),(n:'pse_29.10f';l:$20000;p:$0c0001;crc:$ec037bce),
        (n:'ps_21.6f';l:$80000;p:$100000;crc:$8affa5a9),(n:'ps_q.5k';l:$20000;p:0;crc:$49ff4446),
        (n:'ps-1m.3a';l:$80000;p:$000000;crc:$77b7ccab),(n:'ps-3m.5a';l:$80000;p:$000002;crc:$0122720b),
        (n:'ps-2m.4a';l:$80000;p:$000004;crc:$64fa58d4),(n:'ps-4m.6a';l:$80000;p:$000006;crc:$60da42c8),
        (n:'ps-5m.7a';l:$80000;p:$200000;crc:$c54ea839),(n:'ps-7m.9a';l:$80000;p:$200002;crc:$04c5acbd),
        (n:'ps-6m.8a';l:$80000;p:$200004;crc:$a544f4cc),(n:'ps-8m.10a';l:$80000;p:$200006;crc:$8f02f436),
        (n:'ps-q1.1k';l:$80000;p:$00000;crc:$31fd8726),(n:'ps-q2.2k';l:$80000;p:$80000;crc:$980a9eef),
        (n:'ps-q3.3k';l:$80000;p:$100000;crc:$0dd44491),(n:'ps-q4.4k';l:$80000;p:$180000;crc:$bed42f03),());
        //Shinobi
        shinobi:array[0..18] of tipo_roms=(
        (n:'epr-12010.43';l:$10000;p:0;crc:$7df7f4a2),(n:'epr-12008.26';l:$10000;p:$1;crc:$f5ae64cd),
        (n:'epr-12011.42';l:$10000;p:$20000;crc:$9d46e707),(n:'epr-12009.25';l:$10000;p:$20001;crc:$7961d07e),
        (n:'epr-11267.12';l:$8000;p:0;crc:$dd50b745),(n:'7751.bin';l:$400;p:0;crc:$6a9534fc),
        (n:'epr-11268.1';l:$8000;p:0;crc:$6d7966da),(n:'epr-11264.95';l:$10000;p:0;crc:$46627e7d),
        (n:'epr-11265.94';l:$10000;p:$10000;crc:$87d0f321),(n:'epr-11266.93';l:$10000;p:$20000;crc:$efb4af87),
        (n:'epr-11290.10';l:$10000;p:1;crc:$611f413a),(n:'epr-11294.11';l:$10000;p:$0;crc:$5eb00fc1),
        (n:'epr-11291.17';l:$10000;p:$20001;crc:$3c0797c0),(n:'epr-11295.18';l:$10000;p:$20000;crc:$25307ef8),
        (n:'epr-11292.23';l:$10000;p:$40001;crc:$c29ac34e),(n:'epr-11296.24';l:$10000;p:$40000;crc:$04a437f8),
        (n:'epr-11293.29';l:$10000;p:$60001;crc:$41f41063),(n:'epr-11297.30';l:$10000;p:$60000;crc:$b6e1fd72),());
        //Alex Kidd
        alexkidd:array[0..19] of tipo_roms=(
        (n:'epr-10447.43';l:$10000;p:0;crc:$29e87f71),(n:'epr-10445.26';l:$10000;p:$1;crc:$25ce5b6f),
        (n:'epr-10448.42';l:$10000;p:$20000;crc:$05baedb5),(n:'epr-10446.25';l:$10000;p:$20001;crc:$cd61d23c),
        (n:'epr-10434.12';l:$8000;p:0;crc:$77141cce),(n:'epr-10431.95';l:$8000;p:0;crc:$a7962c39),
        (n:'epr-10432.94';l:$8000;p:$8000;crc:$db8cd24e),(n:'epr-10433.93';l:$8000;p:$10000;crc:$e163c8c2),
        (n:'epr-10437.10';l:$8000;p:1;crc:$522f7618),(n:'epr-10441.11';l:$8000;p:$0;crc:$74e3a35c),
        (n:'epr-10438.17';l:$8000;p:$10001;crc:$738a6362),(n:'epr-10442.18';l:$8000;p:$10000;crc:$86cb9c14),
        (n:'epr-10439.23';l:$8000;p:$20001;crc:$b391aca7),(n:'epr-10443.24';l:$8000;p:$20000;crc:$95d32635),
        (n:'epr-10440.29';l:$8000;p:$30001;crc:$23939508),(n:'epr-10444.30';l:$8000;p:$30000;crc:$82115823),
        (n:'epr-10435.1';l:$8000;p:0;crc:$ad89f6e3),(n:'epr-10436.2';l:$8000;p:$8000;crc:$96c76613),
        (n:'7751.bin';l:$400;p:0;crc:$6a9534fc),());
        //Fantasy Zone
        fantzone:array[0..16] of tipo_roms=(
        (n:'epr-7385a.43';l:$8000;p:0;crc:$4091af42),(n:'epr-7382a.26';l:$8000;p:$1;crc:$77d67bfd),
        (n:'epr-7386a.42';l:$8000;p:$10000;crc:$b0a67cd0),(n:'epr-7383a.25';l:$8000;p:$10001;crc:$5f79b2a9),
        (n:'epr-7387.41';l:$8000;p:$20000;crc:$0acd335d),(n:'epr-7384.24';l:$8000;p:$20001;crc:$fd909341),
        (n:'epr-7535a.12';l:$8000;p:0;crc:$bc1374fa),(n:'epr-7388.95';l:$8000;p:0;crc:$8eb02f6b),
        (n:'epr-7389.94';l:$8000;p:$8000;crc:$2f4f71b8),(n:'epr-7390.93';l:$8000;p:$10000;crc:$d90609c6),
        (n:'epr-7392.10';l:$8000;p:1;crc:$5bb7c8b6),(n:'epr-7396.11';l:$8000;p:$0;crc:$74ae4b57),
        (n:'epr-7393.17';l:$8000;p:$10001;crc:$14fc7e82),(n:'epr-7397.18';l:$8000;p:$10000;crc:$e05a1e25),
        (n:'epr-7394.23';l:$8000;p:$20001;crc:$531ca13f),(n:'epr-7398.24';l:$8000;p:$20000;crc:$68807b49),());
        //Alien Syndrome
        aliensyn:array[0..23] of tipo_roms=(
        (n:'epr-10804.43';l:$8000;p:0;crc:$23f78b83),(n:'epr-10802.26';l:$8000;p:$1;crc:$996768bd),
        (n:'epr-10805.42';l:$8000;p:$10000;crc:$53d7fe50),(n:'epr-10803.25';l:$8000;p:$10001;crc:$0536dd33),
        (n:'epr-10732.41';l:$8000;p:$20000;crc:$c5712bfc),(n:'epr-10729.24';l:$8000;p:$20001;crc:$3e520e30),
        (n:'317-0037.key';l:$2000;p:0;crc:$68bb7745),(n:'epr-10705.12';l:$8000;p:0;crc:$777b749e),
        (n:'epr-10739.95';l:$10000;p:0;crc:$a29ec207),(n:'epr-10740.94';l:$10000;p:$10000;crc:$47f93015),
        (n:'epr-10741.93';l:$10000;p:$20000;crc:$4970739c),(n:'7751.bin';l:$400;p:0;crc:$6a9534fc),
        (n:'epr-10709.10';l:$10000;p:1;crc:$addf0a90),(n:'epr-10713.11';l:$10000;p:$0;crc:$ececde3a),
        (n:'epr-10710.17';l:$10000;p:$20001;crc:$992369eb),(n:'epr-10714.18';l:$10000;p:$20000;crc:$91bf42fb),
        (n:'epr-10711.23';l:$10000;p:$40001;crc:$29166ef6),(n:'epr-10715.24';l:$10000;p:$40000;crc:$a7c57384),
        (n:'epr-10712.29';l:$10000;p:$60001;crc:$876ad019),(n:'epr-10716.30';l:$10000;p:$60000;crc:$40ba1d48),
        (n:'epr-10706.1';l:$8000;p:0;crc:$aa114acc),(n:'epr-10707.2';l:$8000;p:$8000;crc:$800c1d82),
        (n:'epr-10708.4';l:$8000;p:$10000;crc:$5921ef52),());
        //WB3
        wb3:array[0..17] of tipo_roms=(
        (n:'epr-12120.43';l:$10000;p:0;crc:$cbd8c99b),(n:'epr-12118.26';l:$10000;p:$1;crc:$e9a3280c),
        (n:'epr-12121.42';l:$10000;p:$20000;crc:$5e44c0a9),(n:'epr-12119.25';l:$10000;p:$20001;crc:$01ed3ef9),
        (n:'317-0086.key';l:$2000;p:0;crc:$5b8e7076),(n:'epr-12089.12';l:$8000;p:0;crc:$8321eb0b),
        (n:'epr-12086.95';l:$10000;p:0;crc:$45b949df),(n:'epr-12087.94';l:$10000;p:$10000;crc:$6f0396b7),
        (n:'epr-12088.83';l:$10000;p:$20000;crc:$ba8c0749),(n:'epr-12090.10';l:$10000;p:1;crc:$aeeecfca),
        (n:'epr-12094.11';l:$10000;p:$0;crc:$615e4927),(n:'epr-12091.17';l:$10000;p:$20001;crc:$8409a243),
        (n:'epr-12095.18';l:$10000;p:$20000;crc:$e774ec2c),(n:'epr-12092.23';l:$10000;p:$40001;crc:$5c2f0d90),
        (n:'epr-12096.24';l:$10000;p:$40000;crc:$0cd59d6e),(n:'epr-12093.29';l:$10000;p:$60001;crc:$4891e7bb),
        (n:'epr-12097.30';l:$10000;p:$60000;crc:$e645902c),());
        //Tetris
        tetris:array[0..9] of tipo_roms=(
        (n:'xepr12201.rom';l:$8000;p:1;crc:$343c0670),(n:'xepr12200.rom';l:$8000;p:$0;crc:$0b694740),
        (n:'317-0093.key';l:$2000;p:0;crc:$e0064442),(n:'epr-12205.rom';l:$8000;p:0;crc:$6695dc99),
        (n:'epr-12202.rom';l:$10000;p:0;crc:$2f7da741),(n:'epr-12203.rom';l:$10000;p:$10000;crc:$a6e58ec5),
        (n:'epr-12204.rom';l:$10000;p:$20000;crc:$0ae98e23),
        (n:'epr-12169.b1';l:$8000;p:1;crc:$dacc6165),(n:'epr-12170.b5';l:$8000;p:$0;crc:$87354e42),());
        tp84:array[0..17] of tipo_roms=(
        (n:'388_f04.7j';l:$2000;p:$8000;crc:$605f61c7),(n:'388_05.8j';l:$2000;p:$a000;crc:$4b4629a4),
        (n:'388_f06.9j';l:$2000;p:$c000;crc:$dbd5333b),(n:'388_07.10j';l:$2000;p:$e000;crc:$a45237c4),
        (n:'388d14.2c';l:$100;p:0;crc:$d737eaba),(n:'388d15.2d';l:$100;p:$100;crc:$2f6a9a2a),
        (n:'388d16.1e';l:$100;p:$200;crc:$2e21329b),(n:'388d18.1f';l:$100;p:$300;crc:$61d2d398),
        (n:'388_f08.10d';l:$2000;p:$e000;crc:$36462ff1),(n:'388j17.16c';l:$100;p:$400;crc:$13c4e198),
        (n:'388_h02.2j';l:$2000;p:0;crc:$05c7508f),(n:'388_d01.1j';l:$2000;p:$2000;crc:$498d90b7),
        (n:'388_e09.12a';l:$2000;p:$0;crc:$cd682f30),(n:'388_e10.13a';l:$2000;p:$2000;crc:$888d4bd6),
        (n:'388_e11.14a';l:$2000;p:$4000;crc:$9a220b39),(n:'388_e12.15a';l:$2000;p:$6000;crc:$fac98397),
        (n:'388j13.6a';l:$2000;p:$0;crc:$c44414da),());
        tutankhm:array[0..17] of tipo_roms=(
        (n:'m1.1h';l:$1000;p:$0;crc:$da18679f),(n:'m2.2h';l:$1000;p:$1000;crc:$a0f02c85),
        (n:'3j.3h';l:$1000;p:$2000;crc:$ea03a1ab),(n:'m4.4h';l:$1000;p:$3000;crc:$bd06fad0),
        (n:'m5.5h';l:$1000;p:$4000;crc:$bf9fd9b0),(n:'j6.6h';l:$1000;p:$5000;crc:$fe079c5b),
        (n:'c1.1i';l:$1000;p:$6000;crc:$7eb59b21),(n:'c2.2i';l:$1000;p:$7000;crc:$6615eff3),
        (n:'c3.3i';l:$1000;p:$8000;crc:$a10d4444),(n:'c4.4i';l:$1000;p:$9000;crc:$58cd143c),
        (n:'c5.5i';l:$1000;p:$a000;crc:$d7e7ae95),(n:'c6.6i';l:$1000;p:$b000;crc:$91f62b82),
        (n:'c7.7i';l:$1000;p:$c000;crc:$afd0a81f),(n:'c8.8i';l:$1000;p:$d000;crc:$dabb609b),
        (n:'c9.9i';l:$1000;p:$e000;crc:$8ea9c6a6),
        (n:'s1.7a';l:$1000;p:0;crc:$b52d01fa),(n:'s2.8a';l:$1000;p:$1000;crc:$9db5c0ce),());
        //Pang
        pang:array[0..9] of tipo_roms=(
        (n:'pang6.bin';l:$8000;p:0;crc:$68be52cd),(n:'pang7.bin';l:$20000;p:$10000;crc:$4a2e70f6),
        (n:'bb1.bin';l:$20000;p:0;crc:$c52e5b8e),
        (n:'bb10.bin';l:$20000;p:0;crc:$fdba4f6e),(n:'bb9.bin';l:$20000;p:$20000;crc:$39f47a63),
        (n:'pang_09.bin';l:$20000;p:0;crc:$3a5883f5),(n:'bb3.bin';l:$20000;p:$20000;crc:$79a8ed08),
        (n:'pang_11.bin';l:$20000;p:$80000;crc:$166a16ae),(n:'bb5.bin';l:$20000;p:$a0000;crc:$2fb3db6c),());
        //Super Pang
        spang:array[0..11] of tipo_roms=(
        (n:'spe_06.rom';l:$8000;p:0;crc:$1af106fb),(n:'spe_07.rom';l:$20000;p:$10000;crc:$208b5f54),
        (n:'spe_08.rom';l:$20000;p:$30000;crc:$2bc03ade),(n:'spe_01.rom';l:$20000;p:0;crc:$2d19c133),
        (n:'spj10_2k.bin';l:$20000;p:0;crc:$eedd0ade),(n:'spj09_1k.bin';l:$20000;p:$20000;crc:$04b41b75),
        (n:'spe_02.rom';l:$20000;p:0;crc:$63c9dfd2),(n:'03.f2';l:$20000;p:$20000;crc:$3ae28bc1),
        (n:'spe_04.rom';l:$20000;p:$80000;crc:$9d7b225b),(n:'05.g2';l:$20000;p:$a0000;crc:$4a060884),
        (n:'eeprom-spang.bin';l:$80;p:0;crc:$deae1291),());
        //Ninja Kid II
        ninjakd2:array[0..13] of tipo_roms=(
        (n:'1.3s';l:$8000;p:0;crc:$3cdbb906),(n:'2.3q';l:$8000;p:$8000;crc:$b5ce9a1a),
        (n:'3.3r';l:$8000;p:$10000;crc:$ad275654),(n:'4.3p';l:$8000;p:$18000;crc:$e7692a77),
        (n:'5.3m';l:$8000;p:$20000;crc:$5dac9426),(n:'6.3h';l:$10000;p:0;crc:$d3a18a79),
        (n:'12.5n';l:$8000;p:0;crc:$db5657a9),(n:'8.6l';l:$10000;p:0;crc:$1b79c50a),
        (n:'7.6n';l:$10000;p:$10000;crc:$0be5cd13),(n:'11.2n';l:$10000;p:0;crc:$41a714b3),
        (n:'10.2r';l:$10000;p:$10000;crc:$c913c4ab),(n:'ninjakd2.key';l:$2000;p:0;crc:$ec25318f),
        (n:'9.6c';l:$10000;p:0;crc:$c1d2d170),());
        //Ark Area
        arkarea:array[0..13] of tipo_roms=(
        (n:'arkarea.008';l:$8000;p:0;crc:$1ce1b5b9),(n:'arkarea.009';l:$8000;p:$8000;crc:$db1c81d1),
        (n:'arkarea.010';l:$8000;p:$10000;crc:$5a460dae),(n:'arkarea.011';l:$8000;p:$18000;crc:$63f022c9),
        (n:'arkarea.012';l:$8000;p:$20000;crc:$3c4c65d5),(n:'arkarea.013';l:$8000;p:0;crc:$2d409d58),
        (n:'arkarea.007';l:$10000;p:0;crc:$d5684a27),(n:'arkarea.006';l:$10000;p:$10000;crc:$2c0567d6),
        (n:'arkarea.004';l:$8000;p:0;crc:$69e36af2),(n:'arkarea.005';l:$10000;p:$20000;crc:$9886004d),
        (n:'arkarea.003';l:$10000;p:0;crc:$6f45a308),(n:'arkarea.002';l:$10000;p:$10000;crc:$051d3482),
        (n:'arkarea.001';l:$10000;p:$20000;crc:$09d11ab7),());
        //Mutant Night
        mnight:array[0..13] of tipo_roms=(
        (n:'1.j19';l:$8000;p:0;crc:$56678d14),(n:'2.j17';l:$8000;p:$8000;crc:$2a73f88e),
        (n:'3.j16';l:$8000;p:$10000;crc:$c5e42bb4),(n:'4.j14';l:$8000;p:$18000;crc:$df6a4f7a),
        (n:'5.j12';l:$8000;p:$20000;crc:$9c391d1b),(n:'6.j7';l:$10000;p:0;crc:$a0782a31),
        (n:'13.b10';l:$8000;p:0;crc:$37b8221f),(n:'9.e11';l:$10000;p:0;crc:$4883059c),
        (n:'8.e12';l:$10000;p:$10000;crc:$02b91445),(n:'7.e14';l:$10000;p:$20000;crc:$9f08d160),
        (n:'12.b20';l:$10000;p:0;crc:$4d37e0f4),(n:'11.b22';l:$10000;p:$10000;crc:$b22cbbd3),
        (n:'10.b23';l:$10000;p:$20000;crc:$65714070),());
        //Sky Kid
        skykid:array[0..14] of tipo_roms=(
        (n:'sk2_2.6c';l:$4000;p:$0;crc:$ea8a5822),(n:'sk1-1c.6b';l:$4000;p:$4000;crc:$7abe6c6c),
        (n:'sk1_3.6d';l:$4000;p:$8000;crc:$314b8765),(n:'sk1_6.6l';l:$2000;p:0;crc:$58b731b9),
        (n:'sk1_8.10n';l:$4000;p:0;crc:$44bb7375),(n:'sk1_7.10m';l:$4000;p:$4000;crc:$3454671d),
        (n:'sk2_4.3c';l:$2000;p:$8000;crc:$a460d0e0),(n:'cus63-63a1.mcu';l:$1000;p:$f000;crc:$6ef08fb3),
        (n:'sk1-1.2n';l:$100;p:$0;crc:$0218e726),(n:'sk1-2.2p';l:$100;p:$100;crc:$fc0d5b85),
        (n:'sk1-3.2r';l:$100;p:$200;crc:$d06b620b),(n:'sk1-4.5n';l:$200;p:$300;crc:$c697ac72),
        (n:'sk1_5.7e';l:$2000;p:0;crc:$c33a498e),(n:'sk1-5.6n';l:$200;p:$500;crc:$161514a4),());
        //Dragon Buster
        drgnbstr:array[0..14] of tipo_roms=(
        (n:'db1_2b.6c';l:$4000;p:$0;crc:$0f11cd17),(n:'db1_1.6b';l:$4000;p:$4000;crc:$1c7c1821),
        (n:'db1_3.6d';l:$4000;p:$8000;crc:$6da169ae),(n:'db1_6.6l';l:$2000;p:0;crc:$c080b66c),
        (n:'db1_8.10n';l:$4000;p:0;crc:$11942c61),(n:'db1_7.10m';l:$4000;p:$4000;crc:$cc130fe2),
        (n:'db1_4.3c';l:$2000;p:$8000;crc:$8a0b1fc1),(n:'cus60-60a1.mcu';l:$1000;p:$f000;crc:$076ea82a),
        (n:'db1-1.2n';l:$100;p:$0;crc:$3f8cce97),(n:'db1-2.2p';l:$100;p:$100;crc:$afe32436),
        (n:'db1-3.2r';l:$100;p:$200;crc:$c95ff576),(n:'db1-4.5n';l:$200;p:$300;crc:$b2180c21),
        (n:'db1_5.7e';l:$2000;p:0;crc:$28129aed),(n:'db1-5.6n';l:$200;p:$500;crc:$5e2b3f74),());
        //Rolling Thunder
        rthunder:array[0..28] of tipo_roms=(
        (n:'rt1_17.f1';l:$10000;p:0;crc:$766af455),(n:'rt1_18.h1';l:$10000;p:$10000;crc:$3f9f2f5d),
        (n:'rt3_19.k1';l:$10000;p:$20000;crc:$c16675e9),(n:'rt3_20.m1';l:$10000;p:$30000;crc:$c470681b),
        (n:'rt3_2b.12c';l:$8000;p:$0;crc:$a7ea46ee),(n:'rt3_3.12d';l:$8000;p:$8000;crc:$a13f601c),
        (n:'rt1_7.7r';l:$10000;p:0;crc:$a85efa39),(n:'rt1_8.7s';l:$8000;p:$10000;crc:$f7a95820),
        (n:'rt1_5.4r';l:$8000;p:0;crc:$d0fc470b),(n:'rt1_6.4s';l:$4000;p:$8000;crc:$6b57edb2),
        (n:'rt1_9.12h';l:$10000;p:0;crc:$8e070561),(n:'rt1_10.12k';l:$10000;p:$10000;crc:$cb8fb607),
        (n:'rt1_11.12l';l:$10000;p:$20000;crc:$2bdf5ed9),(n:'rt1_12.12m';l:$10000;p:$30000;crc:$e6c6c7dc),
        (n:'rt1_13.12p';l:$10000;p:$40000;crc:$489686d7),(n:'rt1_14.12r';l:$10000;p:$50000;crc:$689e56a8),
        (n:'rt1_15.12t';l:$10000;p:$60000;crc:$1d8bf2ca),(n:'rt1_16.12u';l:$10000;p:$70000;crc:$1bbcf37b),
        (n:'rt3_4.6b';l:$8000;p:$4000;crc:$00cf293f),(n:'cus60-60a1.mcu';l:$1000;p:$f000;crc:$076ea82a),
        (n:'rt1-1.3r';l:$200;p:$0;crc:$8ef3bb9d),(n:'rt1-2.3s';l:$200;p:$200;crc:$6510a8f2),
        (n:'rt1-3.4v';l:$800;p:$400;crc:$95c7d944),(n:'rt1-4.5v';l:$800;p:$c00;crc:$1391fec9),
        (n:'rt3_1b.9c';l:$8000;p:$8000;crc:$7d252a1b),(n:'rt1-5.6u';l:$20;p:$1400;crc:$e4130804),
        (n:'rt1_21.f3';l:$10000;p:$0;crc:$454968f3),(n:'rt2_22.h3';l:$10000;p:$20000;crc:$fe963e72),());
        //Hopping Mappy
        hopmappy:array[0..12] of tipo_roms=(
        (n:'hm1_1.9c';l:$8000;p:$8000;crc:$1a83914e),(n:'hm1_2.12c';l:$4000;p:$c000;crc:$c46cda65),
        (n:'hm1_6.7r';l:$4000;p:$0;crc:$fd0e8887),(n:'hm1_5.4r';l:$4000;p:$0;crc:$9c4f31ae),
        (n:'hm1_3.6b';l:$2000;p:$8000;crc:$6496e1db),(n:'cus60-60a1.mcu';l:$1000;p:$f000;crc:$076ea82a),
        (n:'hm1-1.3r';l:$200;p:$0;crc:$cc801088),(n:'hm1-2.3s';l:$200;p:$200;crc:$a1cb71c5),
        (n:'hm1-3.4v';l:$800;p:$400;crc:$e362d613),(n:'hm1-4.5v';l:$800;p:$c00;crc:$678252b4),
        (n:'hm1_4.12h';l:$8000;p:$0;crc:$78719c52),(n:'hm1-5.6u';l:$20;p:$1400;crc:$475bf500),());
        //Sky Kid Deluxe
        skykiddx:array[0..16] of tipo_roms=(
        (n:'sk3_1b.9c';l:$8000;p:$0;crc:$767b3514),(n:'sk3_2.9d';l:$8000;p:$8000;crc:$74b8f8e2),
        (n:'sk3_9.7r';l:$8000;p:$0;crc:$48675b17),(n:'sk3_10.7s';l:$4000;p:$8000;crc:$7418465a),
        (n:'sk3_7.4r';l:$8000;p:$0;crc:$4036b735),(n:'sk3_8.4s';l:$4000;p:$8000;crc:$044bfd21),
        (n:'sk3_5.12h';l:$8000;p:$0;crc:$5c7d4399),(n:'sk3_6.12k';l:$8000;p:$8000;crc:$c908a3b2),
        (n:'sk3_4.6b';l:$4000;p:$8000;crc:$e6cae2d6),(n:'cus60-60a1.mcu';l:$1000;p:$f000;crc:$076ea82a),
        (n:'sk3-1.3r';l:$200;p:$0;crc:$9e81dedd),(n:'sk3-2.3s';l:$200;p:$200;crc:$cbfec4dd),
        (n:'sk3-3.4v';l:$800;p:$400;crc:$81714109),(n:'sk3-4.5v';l:$800;p:$c00;crc:$1bf25acc),
        (n:'sk3_3.12c';l:$8000;p:$8000;crc:$6d1084c4),(n:'sk3-5.6u';l:$20;p:$1400;crc:$e4130804),());
        rocnrope:array[0..16] of tipo_roms=(
        (n:'rr1.1h';l:$2000;p:$6000;crc:$83093134),(n:'rr2.2h';l:$2000;p:$8000;crc:$75af8697),
        (n:'rr3.3h';l:$2000;p:$a000;crc:$b21372b1),(n:'rr4.4h';l:$2000;p:$c000;crc:$7acb2a05),
        (n:'rnr_7a.snd';l:$1000;p:0;crc:$75d2c4e2),(n:'rnr_8a.snd';l:$1000;p:$1000;crc:$ca4325ae),
        (n:'rnr_a11.vid';l:$2000;p:0;crc:$afdaba5e),(n:'rnr_a12.vid';l:$2000;p:$2000;crc:$054cafeb),
        (n:'rnr_a9.vid';l:$2000;p:$4000;crc:$9d2166b2),(n:'rnr_a10.vid';l:$2000;p:$6000;crc:$aff6e22f),
        (n:'rnr_h12.vid';l:$2000;p:0;crc:$e2114539),(n:'rnr_h11.vid';l:$2000;p:$2000;crc:$169a8f3f),
        (n:'a17_prom.bin';l:$20;p:0;crc:$22ad2c3e),(n:'b16_prom.bin';l:$100;p:$20;crc:$750a9677),
        (n:'rnr_h5.vid';l:$2000;p:$e000;crc:$150a6264),(n:'rocnrope.pr3';l:$100;p:$120;crc:$b5c75a27),());
        repulse:array[0..20] of tipo_roms=(
        (n:'repulse.b5';l:$2000;p:0;crc:$fb2b7c9d),(n:'repulse.b6';l:$2000;p:$2000;crc:$99129918),
        (n:'1.f2';l:$2000;p:0;crc:$c485c621),(n:'2.h2';l:$2000;p:$2000;crc:$b3c6a886),
        (n:'3.j2';l:$2000;p:$4000;crc:$197e314c),(n:'repulse.b4';l:$2000;p:$6000;crc:$86b267f3),
        (n:'7.j4';l:$2000;p:$4000;crc:$57a8e900),(n:'repulse.a11';l:$1000;p:0;crc:$8e1de90a),
        (n:'15.9h';l:$2000;p:0;crc:$c9213469),(n:'16.10h';l:$2000;p:$2000;crc:$7de5d39e),
        (n:'8.6a';l:$4000;p:0;crc:$0e9f757e),(n:'9.7a';l:$4000;p:$4000;crc:$f7d2e650),
        (n:'10.8a';l:$4000;p:$8000;crc:$e717baf4),(n:'11.9a';l:$4000;p:$c000;crc:$04b2250b),
        (n:'12.10a';l:$4000;p:$10000;crc:$d110e140),(n:'13.11a';l:$4000;p:$14000;crc:$8fdc713c),
        (n:'b.1j';l:$100;p:0;crc:$3ea35431),(n:'g.1h';l:$100;p:$100;crc:$acd7a69e),
        (n:'17.11h';l:$2000;p:$4000;crc:$0ba5f72c),(n:'r.1f';l:$100;p:$200;crc:$b7f48b41),());
        //The NewZealand Story
        tnzs:array[0..11] of tipo_roms=(
        (n:'b53-24.1';l:$20000;p:0;crc:$d66824c6),(n:'b53-25.3';l:$10000;p:0;crc:$d6ac4e71),
        (n:'b53-26.34';l:$10000;p:0;crc:$cfd5649c),
        (n:'b53-16.8';l:$20000;p:0;crc:$c3519c2a),(n:'b53-17.7';l:$20000;p:$20000;crc:$2bf199e8),
        (n:'b53-18.6';l:$20000;p:$40000;crc:$92f35ed9),(n:'b53-19.5';l:$20000;p:$60000;crc:$edbb9581),
        (n:'b53-22.4';l:$20000;p:$80000;crc:$59d2aef6),(n:'b53-23.3';l:$20000;p:$a0000;crc:$74acfb9b),
        (n:'b53-20.2';l:$20000;p:$c0000;crc:$095d0dc0),(n:'b53-21.1';l:$20000;p:$e0000;crc:$9800c54d),());
        //Insector X
        insectx:array[0..4] of tipo_roms=(
        (n:'b97-03.u32';l:$20000;p:0;crc:$18eef387),(n:'b97-07.u38';l:$10000;p:0;crc:$324b28c9),
        (n:'b97-01.u1';l:$80000;p:0;crc:$d00294b1),(n:'b97-02.u2';l:$80000;p:$80000;crc:$db5a7434),());
        pacland:array[0..19] of tipo_roms=(
        (n:'pl5_01b.8b';l:$4000;p:$0;crc:$b0ea7631),(n:'pl5_02.8d';l:$4000;p:$4000;crc:$d903e84e),
        (n:'pl1_3.8e';l:$4000;p:$8000;crc:$aa9fa739),(n:'pl1_4.8f';l:$4000;p:$c000;crc:$2b895a90),
        (n:'pl1_5.8h';l:$4000;p:$10000;crc:$7af66200),(n:'pl3_6.8j';l:$4000;p:$14000;crc:$2ffe3319),
        (n:'pl2_12.6n';l:$2000;p:0;crc:$a63c8726),(n:'pl4_13.6t';l:$2000;p:0;crc:$3ae582fd),
        (n:'pl1-9.6f';l:$4000;p:0;crc:$f5d5962b),(n:'pl1-8.6e';l:$4000;p:$4000;crc:$a2ebfa4a),
        (n:'pl1-10.7e';l:$4000;p:$8000;crc:$c7cf1904),(n:'pl1-11.7f';l:$4000;p:$c000;crc:$6621361a),
        (n:'pl1_7.3e';l:$2000;p:$8000;crc:$8c5becae),(n:'cus60-60a1.mcu';l:$1000;p:$f000;crc:$076ea82a),
        (n:'pl1-2.1t';l:$400;p:$0;crc:$472885de),(n:'pl1-1.1r';l:$400;p:$400;crc:$a78ebdaf),
        (n:'pl1-5.5t';l:$400;p:$800;crc:$4b7ee712),(n:'pl1-4.4n';l:$400;p:$c00;crc:$3a7be418),
        (n:'pl1-3.6l';l:$400;p:$1000;crc:$80558da8),());
        mario:array[0..13] of tipo_roms=(
        (n:'tma1-c-7f_f.7f';l:$2000;p:0;crc:$c0c6e014),(n:'tma1-c-7e_f.7e';l:$2000;p:$2000;crc:$94fb60d6),
        (n:'tma1-c-7d_f.7d';l:$2000;p:$4000;crc:$dcceb6c1),(n:'tma1-c-7c_f.7c';l:$1000;p:$f000;crc:$4a63d96b),
        (n:'tma1-c-4p_1.4p';l:$200;p:0;crc:$8187d286),
        (n:'tma1-v-3f.3f';l:$1000;p:0;crc:$28b0c42c),(n:'tma1-v-3j.3j';l:$1000;p:$1000;crc:$0c8cc04d),
        (n:'tma1-v-7m.7m';l:$1000;p:0;crc:$22b7372e),(n:'tma1-v-7n.7n';l:$1000;p:$1000;crc:$4f3a1f47),
        (n:'tma1-v-7p.7p';l:$1000;p:$2000;crc:$56be6ccd),(n:'tma1-v-7s.7s';l:$1000;p:$3000;crc:$56f1d613),
        (n:'tma1-v-7t.7t';l:$1000;p:$4000;crc:$641f0008),(n:'tma1-v-7u.7u';l:$1000;p:$5000;crc:$7baf5309),());
        solomon:array[0..12] of tipo_roms=(
        (n:'6.3f';l:$4000;p:0;crc:$645eb0f3),(n:'7.3h';l:$8000;p:$4000;crc:$1bf5c482),
        (n:'8.3jk';l:$8000;p:$c000;crc:$0a6cdefc),(n:'1.3jk';l:$4000;p:0;crc:$fa6e562e),
        (n:'12.3t';l:$8000;p:$0;crc:$b371291c),(n:'11.3r';l:$8000;p:$8000;crc:$6f94d2af),
        (n:'2.5lm';l:$4000;p:0;crc:$80fa2be3),(n:'3.6lm';l:$4000;p:$4000;crc:$236106b4),
        (n:'4.7lm';l:$4000;p:$8000;crc:$088fe5d9),(n:'5.8lm';l:$4000;p:$c000;crc:$8366232a),
        (n:'10.3p';l:$8000;p:$0;crc:$8310c2a1),(n:'9.3m';l:$8000;p:$8000;crc:$ab7e6c42),());
        combatsc:array[0..12] of tipo_roms=(
        (n:'611g01.rom';l:$10000;p:$0;crc:$857ffffe),(n:'611g02.rom';l:$20000;p:$10000;crc:$9ba05327),
        (n:'611g06.h14';l:$100;p:0;crc:$f916129a),(n:'611g05.h15';l:$100;p:$100;crc:$207a7b07),
        (n:'611g10.h6';l:$100;p:$200;crc:$f916129a),(n:'611g09.h7';l:$100;p:$300;crc:$207a7b07),
        (n:'611g07.rom';l:$40000;p:0;crc:$73b38720),(n:'611g08.rom';l:$40000;p:$1;crc:$46e7d28c),
        (n:'611g11.rom';l:$40000;p:0;crc:$69687538),(n:'611g12.rom';l:$40000;p:$1;crc:$9c6bf898),
        (n:'611g03.rom';l:$8000;p:$0;crc:$2a544db5),(n:'611g04.rom';l:$20000;p:0;crc:$2987e158),());
        hvyunit:array[0..13] of tipo_roms=(
        (n:'b73_10.5c';l:$20000;p:0;crc:$ca52210f),(n:'b73_11.5p';l:$10000;p:0;crc:$cb451695),
        (n:'b73_12.7e';l:$10000;p:0;crc:$d1d24fab),(n:'mermaid.bin';l:$e00;p:0;crc:$88c5dd27),
        (n:'b73_08.2f';l:$80000;p:0;crc:$f83dd808),(n:'b73_07.2c';l:$10000;p:$100000;crc:$5cffa42c),
        (n:'b73_06.2b';l:$10000;p:$120000;crc:$a98e4aea),(n:'b73_01.1b';l:$10000;p:$140000;crc:$3a8a4489),
        (n:'b73_02.1c';l:$10000;p:$160000;crc:$025c536c),(n:'b73_03.1d';l:$10000;p:$180000;crc:$ec6020cf),
        (n:'b73_04.1f';l:$10000;p:$1a0000;crc:$f7badbb2),(n:'b73_05.1h';l:$10000;p:$1c0000;crc:$b8e829d2),
        (n:'b73_09.2p';l:$80000;p:0;crc:$537c647f),());
        //POW
        pow:array[0..22] of tipo_roms=(
        (n:'dg1ver1.j14';l:$20000;p:0;crc:$8e71a8af),(n:'dg2ver1.l14';l:$20000;p:$1;crc:$4287affc),
        (n:'dg9.l25';l:$8000;p:0;crc:$df864a08),(n:'dg10.m25';l:$8000;p:$8000;crc:$9e470d53),
        (n:'dg8.e25';l:$10000;p:0;crc:$d1d61da3),(n:'dg7.d20';l:$10000;p:0;crc:$aba9a9d3),
        (n:'snk880.11a';l:$20000;p:$0;crc:$e70fd906),(n:'snk880.15a';l:$20000;p:$1;crc:$7a90e957),
        (n:'snk880.12a';l:$20000;p:$40000;crc:$628b1aed),(n:'snk880.16a';l:$20000;p:$40001;crc:$e40a6c13),
        (n:'snk880.13a';l:$20000;p:$80000;crc:$19dc8868),(n:'snk880.17a';l:$20000;p:$80001;crc:$c7931cc2),
        (n:'snk880.14a';l:$20000;p:$c0000;crc:$47cd498b),(n:'snk880.18a';l:$20000;p:$c0001;crc:$eed72232),
        (n:'snk880.19a';l:$20000;p:$100000;crc:$1775b8dd),(n:'snk880.23a';l:$20000;p:$100001;crc:$adb6ad68),
        (n:'snk880.20a';l:$20000;p:$140000;crc:$f8e752ec),(n:'snk880.24a';l:$20000;p:$140001;crc:$dd41865a),
        (n:'snk880.21a';l:$20000;p:$180000;crc:$27e9fffe),(n:'snk880.25a';l:$20000;p:$180001;crc:$055759ad),
        (n:'snk880.22a';l:$20000;p:$1c0000;crc:$aa9c00d8),(n:'snk880.26a';l:$20000;p:$1c0001;crc:$9bc261c5),());
        //Street Smart
        streetsm:array[0..12] of tipo_roms=(
        (n:'s2-1ver2.14h';l:$20000;p:0;crc:$655f4773),(n:'s2-2ver2.14k';l:$20000;p:$1;crc:$efae4823),
        (n:'s2-9.25l';l:$8000;p:0;crc:$09b6ac67),(n:'s2-10.25m';l:$8000;p:$8000;crc:$89e4ee6f),
        (n:'s2-5.16c';l:$10000;p:0;crc:$ca4b171e),(n:'s2-6.18d';l:$20000;p:0;crc:$47db1605),
        (n:'stsmart.900';l:$80000;p:$0;crc:$a8279a7e),(n:'stsmart.902';l:$80000;p:$80000;crc:$2f021aa1),
        (n:'stsmart.901';l:$80000;p:$200000;crc:$c305af12),(n:'stsmart.903';l:$80000;p:$280000;crc:$73c16d35),
        (n:'stsmart.904';l:$80000;p:$100000;crc:$167346f7),(n:'stsmart.905';l:$80000;p:$300000;crc:$a5beb4e2),());
        //Ikari 3
        ikari3:array[0..28] of tipo_roms=(
        (n:'ik3-2-ver1.c10';l:$20000;p:0;crc:$1bae8023),(n:'ik3-3-ver1.c9';l:$20000;p:$1;crc:$10e38b66),
        (n:'ik3-7.bin';l:$8000;p:0;crc:$0b4804df),(n:'ik3-8.bin';l:$8000;p:$8000;crc:$10ab4e50),
        (n:'ik3-5.bin';l:$10000;p:0;crc:$ce6706fc),(n:'ik3-6.bin';l:$20000;p:0;crc:$59d256a4),
        (n:'ik3-23.bin';l:$20000;p:$000000;crc:$d0fd5c77),(n:'ik3-13.bin';l:$20000;p:$000001;crc:$9a56bd32),
        (n:'ik3-22.bin';l:$20000;p:$040000;crc:$4878d883),(n:'ik3-12.bin';l:$20000;p:$040001;crc:$0ce6a10a),
        (n:'ik3-21.bin';l:$20000;p:$080000;crc:$50d0fbf0),(n:'ik3-11.bin';l:$20000;p:$080001;crc:$e4e2be43),
        (n:'ik3-20.bin';l:$20000;p:$0c0000;crc:$9a851efc),(n:'ik3-10.bin';l:$20000;p:$0c0001;crc:$ac222372),
        (n:'ik3-19.bin';l:$20000;p:$100000;crc:$4ebdba89),(n:'ik3-9.bin';l:$20000;p:$100001;crc:$c33971c2),
        (n:'ik3-14.bin';l:$20000;p:$200000;crc:$453bea77),(n:'ik3-24.bin';l:$20000;p:$200001;crc:$e9b26d68),
        (n:'ik3-15.bin';l:$20000;p:$240000;crc:$781a81fc),(n:'ik3-25.bin';l:$20000;p:$240001;crc:$073b03f1),
        (n:'ik3-16.bin';l:$20000;p:$280000;crc:$80ba400b),(n:'ik3-26.bin';l:$20000;p:$280001;crc:$9c613561),
        (n:'ik3-17.bin';l:$20000;p:$2c0000;crc:$0cc3ce4a),(n:'ik3-27.bin';l:$20000;p:$2c0001;crc:$16dd227e),
        (n:'ik3-18.bin';l:$20000;p:$300000;crc:$ba106245),(n:'ik3-28.bin';l:$20000;p:$300001;crc:$711715ae),
        (n:'ik3-1.c8';l:$10000;p:0;crc:$47e4d256),(n:'ik3-4.c12';l:$10000;p:$1;crc:$a43af6b5),());
        //Search and Rescue
        searchar:array[0..14] of tipo_roms=(
        (n:'bhw.2';l:$20000;p:0;crc:$e1430138),(n:'bhw.3';l:$20000;p:$1;crc:$ee1f9374),
        (n:'bh.7';l:$8000;p:0;crc:$b0f1b049),(n:'bh.8';l:$8000;p:$8000;crc:$174ddba7),
        (n:'bh.5';l:$10000;p:0;crc:$53e2fa76),(n:'bh.v1';l:$20000;p:0;crc:$07a6114b),
        (n:'bh.c1';l:$80000;p:$000000;crc:$1fb8f0ae),(n:'bh.c3';l:$80000;p:$080000;crc:$fd8bc407),
        (n:'bh.c2';l:$80000;p:$200000;crc:$7c803767),(n:'bh.c4';l:$80000;p:$280000;crc:$eede7c43),
        (n:'bh.c5';l:$80000;p:$100000;crc:$1d30acc3),(n:'bh.c6';l:$80000;p:$300000;crc:$9f785cd9),
        (n:'bhw.1';l:$20000;p:0;crc:$62b60066),(n:'bhw.4';l:$20000;p:$1;crc:$16d8525c),());
        //P47
        p47:array[0..20] of tipo_roms=(
        (n:'p47us3.bin';l:$20000;p:0;crc:$022e58b8),(n:'p47us1.bin';l:$20000;p:$1;crc:$ed926bd8),
        (n:'p47j_9.bin';l:$10000;p:0;crc:$ffcf318e),(n:'p47j_19.bin';l:$10000;p:$1;crc:$adb8c12e),
        (n:'p47j_5.bin';l:$20000;p:0;crc:$fe65b65c),(n:'p47j_6.bin';l:$20000;p:$20000;crc:$e191d2d2),
        (n:'p47j_23.bin';l:$20000;p:0;crc:$6e9bc864),(n:'p47j_23.bin';l:$20000;p:$20000;crc:$6e9bc864),
        (n:'p47j_12.bin';l:$20000;p:$40000;crc:$5268395f),(n:'p47us16.bin';l:$10000;p:0;crc:$5a682c8f),
        (n:'p47j_27.bin';l:$20000;p:0;crc:$9e2bde8e),(n:'p47j_18.bin';l:$20000;p:$20000;crc:$29d8f676),
        (n:'p47j_26.bin';l:$20000;p:$40000;crc:$4d07581a),(n:'p47j_26.bin';l:$20000;p:$60000;crc:$4d07581a),
        (n:'p47j_20.bin';l:$20000;p:0;crc:$2ed53624),(n:'p47j_21.bin';l:$20000;p:$20000;crc:$6f56b56d),
        (n:'p47j_10.bin';l:$20000;p:0;crc:$b9d79c1e),(n:'p47j_11.bin';l:$20000;p:$20000;crc:$fa0d1887),
        (n:'p47j_7.bin';l:$20000;p:$40000;crc:$f77723b7),(n:'p-47.14m';l:$200;p:0;crc:$1d877538),());
        //Rod-Land
        rodland:array[0..13] of tipo_roms=(
        (n:'jaleco_rod_land_2.rom2';l:$20000;p:0;crc:$c7e00593),(n:'jaleco_rod_land_1.rom1';l:$20000;p:$1;crc:$2e748ca1),
        (n:'jaleco_rod_land_3.rom3';l:$10000;p:$40000;crc:$62fdf6d7),(n:'jaleco_rod_land_4.rom4';l:$10000;p:$40001;crc:$44163c86),
        (n:'jaleco_rod_land_5.rom5';l:$10000;p:0;crc:$c1617c28),(n:'jaleco_rod_land_6.rom6';l:$10000;p:$1;crc:$663392b2),
        (n:'lh534h31.rom14';l:$80000;p:0;crc:$8201e1bb),(n:'lh534h32.rom18';l:$80000;p:0;crc:$f3b30ca6),
        (n:'lh2311j0.rom19';l:$20000;p:0;crc:$124d7e8f),(n:'lh534h33.rom23';l:$80000;p:0;crc:$936db174),
        (n:'lh5321t5.rom10';l:$40000;p:0;crc:$e1d1cd99),(n:'s202000dr.rom8';l:$40000;p:0;crc:$8a49d3a7),
        (n:'ps89013a.14m';l:$200;p:0;crc:$8914e72d),());
        //saint dragon
        stdragon:array[0..22] of tipo_roms=(
        (n:'jsd-02.bin';l:$20000;p:0;crc:$cc29ab19),(n:'jsd-01.bin';l:$20000;p:$1;crc:$67429a57),
        (n:'jsd-05.bin';l:$10000;p:0;crc:$8c04feaa),(n:'jsd-06.bin';l:$10000;p:$1;crc:$0bb62f3a),
        (n:'jsd-11.bin';l:$20000;p:0;crc:$2783b7b1),(n:'jsd-12.bin';l:$20000;p:$20000;crc:$89466ab7),
        (n:'jsd-13.bin';l:$20000;p:$40000;crc:$9896ae82),(n:'jsd-14.bin';l:$20000;p:$60000;crc:$7e8da371),
        (n:'jsd-15.bin';l:$20000;p:0;crc:$e296bf59),(n:'jsd-16.bin';l:$20000;p:$20000;crc:$d8919c06),
        (n:'jsd-17.bin';l:$20000;p:$40000;crc:$4f7ad563),(n:'jsd-18.bin';l:$20000;p:$60000;crc:$1f4da822),
        (n:'jsd-20.bin';l:$20000;p:0;crc:$2c6e93bb),(n:'jsd-21.bin';l:$20000;p:$20000;crc:$864bcc61),
        (n:'jsd-22.bin';l:$20000;p:$40000;crc:$44fe2547),(n:'jsd-23.bin';l:$20000;p:$60000;crc:$6b010e1a),
        (n:'jsd-09.bin';l:$20000;p:0;crc:$e366bc5a),(n:'jsd-10.bin';l:$20000;p:$20000;crc:$4a8f4fe6),
        (n:'jsd-07.bin';l:$20000;p:0;crc:$6a48e979),(n:'jsd-08.bin';l:$20000;p:$20000;crc:$40704962),
        (n:'jsd-19.bin';l:$10000;p:0;crc:$25ce807d),(n:'prom.14m';l:$200;p:0;crc:$1d877538),());
        timeplt:array[0..11] of tipo_roms=(
        (n:'tm1';l:$2000;p:0;crc:$1551f1b9),(n:'tm2';l:$2000;p:$2000;crc:$58636cb5),
        (n:'tm3';l:$2000;p:$4000;crc:$ff4e0d83),(n:'tm6';l:$2000;p:0;crc:$c2507f40),
        (n:'tm4';l:$2000;p:0;crc:$7e437c3e),(n:'tm5';l:$2000;p:$2000;crc:$e8ca87b9),
        (n:'timeplt.b4';l:$20;p:0;crc:$34c91839),(n:'timeplt.b5';l:$20;p:$20;crc:$463b2b07),
        (n:'timeplt.e9';l:$100;p:$40;crc:$4bbb2150),(n:'timeplt.e12';l:$100;p:$140;crc:$f7b7663e),
        (n:'tm7';l:$1000;p:0;crc:$d66da813),());
        pengo:array[0..13] of tipo_roms=(
        (n:'ep1689c.8';l:$1000;p:0;crc:$f37066a8),(n:'ep1690b.7';l:$1000;p:$1000;crc:$baf48143),
        (n:'ep1691b.15';l:$1000;p:$2000;crc:$adf0eba0),(n:'ep1692b.14';l:$1000;p:$3000;crc:$a086d60f),
        (n:'ep1693b.21';l:$1000;p:$4000;crc:$b72084ec),(n:'ep1694b.20';l:$1000;p:$5000;crc:$94194a89),
        (n:'ep5118b.32';l:$1000;p:$6000;crc:$af7b12c4),(n:'ep5119c.31';l:$1000;p:$7000;crc:$933950fe),
        (n:'pr1633.78';l:$20;p:0;crc:$3a5844ec),(n:'pr1634.88';l:$400;p:$20;crc:$766b139b),
        (n:'pr1635.51';l:$100;p:0;crc:$c29dea27),
        (n:'ep1640.92';l:$2000;p:$0;crc:$d7eec6cd),(n:'ep1695.105';l:$2000;p:$4000;crc:$5bfd26e9),());
        //Twin Cobra
        twincobr:array[0..22] of tipo_roms=(
        (n:'b30-01';l:$10000;p:0;crc:$07f64d13),(n:'b30-03';l:$10000;p:$1;crc:$41be6978),
        (n:'tc15';l:$8000;p:$20000;crc:$3a646618),(n:'tc13';l:$8000;p:$20001;crc:$d7d1e317),
        (n:'tc11';l:$4000;p:0;crc:$0a254133),(n:'tc03';l:$4000;p:$4000;crc:$e9e2d4b1),
        (n:'tc12';l:$8000;p:0;crc:$e37b3c44),(n:'tc04';l:$4000;p:$8000;crc:$a599d845),
        (n:'tc20';l:$10000;p:0;crc:$cb4092b8),(n:'tc19';l:$10000;p:$10000;crc:$9cb8675e),
        (n:'tc18';l:$10000;p:$20000;crc:$806fb374),(n:'tc17';l:$10000;p:$30000;crc:$4264bff8),
        (n:'tc01';l:$10000;p:0;crc:$15b3991d),(n:'tc02';l:$10000;p:$10000;crc:$d9e2e55d),
        (n:'tc06';l:$10000;p:$20000;crc:$13daeac8),(n:'tc05';l:$10000;p:$30000;crc:$8cc79357),
        (n:'tc07';l:$8000;p:0;crc:$b5d48389),(n:'tc08';l:$8000;p:$8000;crc:$97f20fdc),
        (n:'tc09';l:$8000;p:$10000;crc:$170c01db),(n:'tc10';l:$8000;p:$18000;crc:$44f5accd),
        (n:'dsp_22.bin';l:$800;p:0;crc:$79389a71),(n:'dsp_21.bin';l:$800;p:$1;crc:$2d135376),());
        //Flying Shark
        fshark:array[0..26] of tipo_roms=(
        (n:'b02_18-1.m8';l:$10000;p:0;crc:$04739e02),(n:'b02_17-1.p8';l:$10000;p:$1;crc:$fd6ef7a8),
        (n:'b02_07-1.h11';l:$4000;p:0;crc:$e669f80e),(n:'b02_06-1.h10';l:$4000;p:$4000;crc:$5e53ae47),
        (n:'b02_16.l5';l:$8000;p:0;crc:$cdd1a153),(n:'b02_05-1.h8';l:$4000;p:$8000;crc:$a8b05bd0),
        (n:'b02_01.d15';l:$10000;p:0;crc:$2234b424),(n:'b02_02.d16';l:$10000;p:$10000;crc:$30d4c9a8),
        (n:'b02_03.d17';l:$10000;p:$20000;crc:$64f3d88f),(n:'b02_04.d20';l:$10000;p:$30000;crc:$3b23a9fc),
        (n:'b02_12.h20';l:$8000;p:0;crc:$733b9997),(n:'b02_15.h24';l:$8000;p:$8000;crc:$8b70ef32),
        (n:'b02_14.h23';l:$8000;p:$10000;crc:$f711ba7d),(n:'b02_13.h21';l:$8000;p:$18000;crc:$62532cd3),
        (n:'b02_08.h13';l:$8000;p:0;crc:$ef0cf49c),(n:'b02_11.h18';l:$8000;p:$8000;crc:$f5799422),
        (n:'b02_10.h16';l:$8000;p:$10000;crc:$4bd099ff),(n:'b02_09.h15';l:$8000;p:$18000;crc:$230f1582),
        (n:'82s137-1.mcu';l:$400;p:0;crc:$cc5b3f53),(n:'82s137-2.mcu';l:$400;p:$400;crc:$47351d55),
        (n:'82s137-3.mcu';l:$400;p:$800;crc:$70b537b9),(n:'82s137-4.mcu';l:$400;p:$c00;crc:$6edb2de8),
        (n:'82s137-5.mcu';l:$400;p:$1000;crc:$f35b978a),(n:'82s137-6.mcu';l:$400;p:$1400;crc:$0459e51b),
        (n:'82s137-7.mcu';l:$400;p:$1800;crc:$cbf3184b),(n:'82s137-8.mcu';l:$400;p:$1c00;crc:$8246a05c),());
        //JR. Pac-man
        jrpacman:array[0..11] of tipo_roms=(
        (n:'jrp8d.bin';l:$2000;p:0;crc:$e3fa972e),(n:'jrp8e.bin';l:$2000;p:$2000;crc:$ec889e94),
        (n:'jrp8h.bin';l:$2000;p:$8000;crc:$35f1fc6e),(n:'jrp8j.bin';l:$2000;p:$a000;crc:$9737099e),
        (n:'jrprom.9e';l:$100;p:$0;crc:$029d35c4),(n:'jrprom.9f';l:$100;p:$100;crc:$eee34a79),
        (n:'jrp8k.bin';l:$2000;p:$c000;crc:$5252dd97),(n:'jrprom.9p';l:$100;p:$200;crc:$9f6ea9d8),
        (n:'jrp2c.bin';l:$2000;p:0;crc:$0527ff9b),(n:'jrp2e.bin';l:$2000;p:$2000;crc:$73477193),
        (n:'jrprom.7p';l:$100;p:0;crc:$a9cc86bf),());
        //Robocop
        robocop:array[0..25] of tipo_roms=(
        (n:'ep05-4.11c';l:$10000;p:0;crc:$29c35379),(n:'ep01-4.11b';l:$10000;p:$1;crc:$77507c69),
        (n:'ep04-3';l:$10000;p:$20000;crc:$39181778),(n:'ep00-3';l:$10000;p:$20001;crc:$e128541f),
        (n:'en_24_mb7124e.a2';l:$200;p:$0;crc:$b8e2ca98),
        (n:'ep23';l:$10000;p:0;crc:$a77e4ab1),(n:'ep22';l:$10000;p:$10000;crc:$9fbd6903),
        (n:'ep03-3';l:$8000;p:$8000;crc:$5b164b24),(n:'ep02';l:$10000;p:0;crc:$711ce46f),
        (n:'ep20';l:$10000;p:0;crc:$1d8d38b8),(n:'ep21';l:$10000;p:$10000;crc:$187929b2),
        (n:'ep18';l:$10000;p:$20000;crc:$b6580b5e),(n:'ep19';l:$10000;p:$30000;crc:$9bad01c7),
        (n:'ep14';l:$8000;p:0;crc:$ca56ceda),(n:'ep15';l:$8000;p:$8000;crc:$a945269c),
        (n:'ep16';l:$8000;p:$10000;crc:$e7fa4d58),(n:'ep17';l:$8000;p:$18000;crc:$84aae89d),
        (n:'ep07';l:$10000;p:$00000;crc:$495d75cf),(n:'ep06';l:$8000;p:$10000;crc:$a2ae32e2),
        (n:'ep11';l:$10000;p:$20000;crc:$62fa425a),(n:'ep10';l:$8000;p:$30000;crc:$cce3bd95),
        (n:'ep09';l:$10000;p:$40000;crc:$11bed656),(n:'ep08';l:$8000;p:$50000;crc:$c45c7b4c),
        (n:'ep13';l:$10000;p:$60000;crc:$8fca9f28),(n:'ep12';l:$8000;p:$70000;crc:$3cd1d0c3),());
        //Baddudes
        baddudes:array[0..23] of tipo_roms=(
        (n:'ei04-1.3c';l:$10000;p:0;crc:$4bf158a7),(n:'ei01-1.3a';l:$10000;p:$1;crc:$74f5110c),
        (n:'ei06.6c';l:$10000;p:$40000;crc:$3ff8da57),(n:'ei03.6a';l:$10000;p:$40001;crc:$f8f2bd94),
        (n:'ei25.15j';l:$8000;p:0;crc:$bcf59a69),(n:'ei26.16j';l:$8000;p:$8000;crc:$9aff67b8),
        (n:'ei31.9a';l:$1000;p:$0;crc:$2a8745d2),(n:'ei07.8a';l:$8000;p:$8000;crc:$9fb1ef4b),
        (n:'ei08.2c';l:$10000;p:0;crc:$3c87463e),(n:'ei18.14d';l:$10000;p:0;crc:$05cfc3e5),
        (n:'ei20.17d';l:$10000;p:$10000;crc:$e11e988f),(n:'ei22.14f';l:$10000;p:$20000;crc:$b893d880),
        (n:'ei24.17f';l:$10000;p:$30000;crc:$6f226dda),(n:'ei30.9j';l:$10000;p:$20000;crc:$982da0d1),
        (n:'ei28.9f';l:$10000;p:$30000;crc:$f01ebb3b),
        (n:'ei15.16c';l:$10000;p:$00000;crc:$a38a7d30),(n:'ei16.17c';l:$8000;p:$10000;crc:$17e42633),
        (n:'ei11.16a';l:$10000;p:$20000;crc:$3a77326c),(n:'ei12.17a';l:$8000;p:$30000;crc:$fea2a134),
        (n:'ei13.13c';l:$10000;p:$40000;crc:$e5ae2751),(n:'ei14.14c';l:$8000;p:$50000;crc:$e83c760a),
        (n:'ei09.13a';l:$10000;p:$60000;crc:$6901e628),(n:'ei10.14a';l:$8000;p:$70000;crc:$eeee8a1a),());
        //Hippodrome
        hippodrm:array[0..25] of tipo_roms=(
        (n:'ew02';l:$10000;p:0;crc:$df0d7dc6),(n:'ew01';l:$10000;p:$1;crc:$d5670aa7),
        (n:'ew05';l:$10000;p:$20000;crc:$c76d65ec),(n:'ew00';l:$10000;p:$20001;crc:$e9b427a6),
        (n:'ew08';l:$10000;p:$0;crc:$53010534),
        (n:'ew14';l:$10000;p:0;crc:$71ca593d),(n:'ew13';l:$10000;p:$10000;crc:$86be5fa7),
        (n:'ew04';l:$8000;p:$8000;crc:$9871b98d),(n:'ew03';l:$10000;p:0;crc:$b606924d),
        (n:'ew19';l:$8000;p:0;crc:$6b80d7a3),(n:'ew18';l:$8000;p:$8000;crc:$78d3d764),
        (n:'ew20';l:$8000;p:$10000;crc:$ce9f5de3),(n:'ew21';l:$8000;p:$18000;crc:$487a7ba2),
        (n:'ew24';l:$8000;p:0;crc:$4e1bc2a4),(n:'ew25';l:$8000;p:$8000;crc:$9eb47dfb),
        (n:'ew23';l:$8000;p:$10000;crc:$9ecf479e),(n:'ew22';l:$8000;p:$18000;crc:$e55669aa),
        (n:'ew15';l:$10000;p:$00000;crc:$95423914),(n:'ew16';l:$10000;p:$10000;crc:$96233177),
        (n:'ew10';l:$10000;p:$20000;crc:$4c25dfe8),(n:'ew11';l:$10000;p:$30000;crc:$f2e007fc),
        (n:'ew06';l:$10000;p:$40000;crc:$e4bb8199),(n:'ew07';l:$10000;p:$50000;crc:$470b6989),
        (n:'ew17';l:$10000;p:$60000;crc:$8c97c757),(n:'ew12';l:$10000;p:$70000;crc:$a2d244bc),());
        tumblep:array[0..7] of tipo_roms=(
        (n:'hl00-1.f12';l:$40000;p:0;crc:$fd697c1b),(n:'hl01-1.f13';l:$40000;p:$1;crc:$d5a62a3f),
        (n:'hl02-.f16';l:$10000;p:$0;crc:$a5cab888),(n:'map-02.rom';l:$80000;p:0;crc:$dfceaa26),
        (n:'hl03-.j15';l:$20000;p:0;crc:$01b81da0),
        (n:'map-01.rom';l:$80000;p:0;crc:$e81ffa09),(n:'map-00.rom';l:$80000;p:$1;crc:$8c879cfe),());
        funkyjet:array[0..7] of tipo_roms=(
        (n:'jk00.12f';l:$40000;p:0;crc:$712089c1),(n:'jk01.13f';l:$40000;p:$1;crc:$be3920d7),
        (n:'jk02.16f';l:$10000;p:$0;crc:$748c0bd8),(n:'mat02';l:$80000;p:0;crc:$e4b94c7e),
        (n:'jk03.15h';l:$20000;p:0;crc:$69a0eaf7),
        (n:'mat01';l:$80000;p:0;crc:$24093a8d),(n:'mat00';l:$80000;p:$80000;crc:$fbda0228),());
        supbtime:array[0..7] of tipo_roms=(
        (n:'gk03';l:$20000;p:0;crc:$aeaeed61),(n:'gk04';l:$20000;p:$1;crc:$2bc5a4eb),
        (n:'gc06.bin';l:$10000;p:$0;crc:$e0e6c0f4),(n:'mae02.bin';l:$80000;p:0;crc:$a715cca0),
        (n:'gc05.bin';l:$20000;p:0;crc:$2f2246ff),
        (n:'mae00.bin';l:$80000;p:1;crc:$30043094),(n:'mae01.bin';l:$80000;p:$0;crc:$434af3fb),());
        //Caveman Ninja
        cninja:array[0..18] of tipo_roms=(
        (n:'gn-02-3.1k';l:$20000;p:0;crc:$39aea12a),(n:'gn-05-2.3k';l:$20000;p:$1;crc:$0f4360ef),
        (n:'gn-01-2.1j';l:$20000;p:$40000;crc:$f740ef7e),(n:'gn-04-2.3j';l:$20000;p:$40001;crc:$c98fcb62),
        (n:'gn-00.rom';l:$20000;p:$80000;crc:$0b110b16),(n:'gn-03.rom';l:$20000;p:$80001;crc:$1e28e697),
        (n:'gl-09.rom';l:$10000;p:$0;crc:$5a2d4752),(n:'gl-08.rom';l:$10000;p:1;crc:$33a2b400),
        (n:'gl-07.rom';l:$10000;p:$0;crc:$ca8bef96),(n:'mag-02.rom';l:$80000;p:$0;crc:$de89c69a),
        (n:'mag-00.rom';l:$80000;p:$0;crc:$a8f05d33),(n:'mag-01.rom';l:$80000;p:$80000;crc:$5b399eed),
        (n:'mag-07.rom';l:$80000;p:0;crc:$08eb5264),(n:'gl-06.rom';l:$20000;p:0;crc:$d92e519d),
        (n:'mag-03.rom';l:$80000;p:0;crc:$2220eb9f),(n:'mag-05.rom';l:$80000;p:$1;crc:$56a53254),
        (n:'mag-04.rom';l:$80000;p:$100000;crc:$144b94cc),(n:'mag-06.rom';l:$80000;p:$100001;crc:$82d44749),());
        //Robocop 2
        robocop2:array[0..24] of tipo_roms=(
        (n:'gq-03.k1';l:$20000;p:0;crc:$a7e90c28),(n:'gq-07.k3';l:$20000;p:$1;crc:$d2287ec1),
        (n:'gq-02.j1';l:$20000;p:$40000;crc:$6777b8a0),(n:'gq-06.j3';l:$20000;p:$40001;crc:$e11e27b5),
        (n:'go-01-1.h1';l:$20000;p:$80000;crc:$ab5356c0),(n:'go-05-1.h3';l:$20000;p:$80001;crc:$ce21bda5),
        (n:'go-00.f1';l:$20000;p:$c0000;crc:$a93369ea),(n:'go-04.f3';l:$20000;p:$c0001;crc:$ee2f6ad9),
        (n:'gp10-1.y6';l:$10000;p:1;crc:$d25d719c),(n:'gp11-1.z6';l:$10000;p:0;crc:$030ded47),
        (n:'gp-09.k13';l:$10000;p:$0;crc:$4a4e0f8d),(n:'gp-08.j13';l:$20000;p:0;crc:$365183b1),
        (n:'mah-04.z4';l:$80000;p:$0;crc:$9b6ca18c),(n:'mah-03.y4';l:$80000;p:$80000;crc:$37894ddc),
        (n:'mah-01.z1';l:$80000;p:0;crc:$26e0dfff),(n:'mah-00.y1';l:$80000;p:$80000;crc:$7bd69e41),
        (n:'mah-11.f13';l:$80000;p:0;crc:$642bc692),(n:'mah-02.a1';l:$80000;p:$100000;crc:$328a247d),
        (n:'mah-05.y9';l:$80000;p:$000000;crc:$6773e613),(n:'mah-08.y12';l:$80000;p:$000001;crc:$88d310a5),
        (n:'mah-06.z9';l:$80000;p:$100000;crc:$27a8808a),(n:'mah-09.z12';l:$80000;p:$100001;crc:$a58c43a7),
        (n:'mah-07.a9';l:$80000;p:$200000;crc:$526f4190),(n:'mah-10.a12';l:$80000;p:$200001;crc:$14b770da),());
        dietgo:array[0..7] of tipo_roms=(
        (n:'jy00-2.h4';l:$40000;p:1;crc:$014dcf62),(n:'jy01-2.h5';l:$40000;p:$0;crc:$793ebd83),
        (n:'jy02.m14';l:$10000;p:$0;crc:$4e3492a5),(n:'may00';l:$100000;p:0;crc:$234d1f8d),
        (n:'may03';l:$80000;p:0;crc:$b6e42bae),
        (n:'may01';l:$100000;p:0;crc:$2da57d04),(n:'may02';l:$100000;p:$1;crc:$3a66a713),());
        //arabian
        arabian:array[0..9] of tipo_roms=(
        (n:'ic1rev2.87';l:$2000;p:0;crc:$5e1c98b8),(n:'ic2rev2.88';l:$2000;p:$2000;crc:$092f587e),
        (n:'ic3rev2.89';l:$2000;p:$4000;crc:$15145f23),(n:'ic4rev2.90';l:$2000;p:$6000;crc:$32b77b44),
        (n:'tvg-91.ic84';l:$2000;p:0;crc:$c4637822),(n:'tvg-92.ic85';l:$2000;p:$2000;crc:$f7c6866d),
        (n:'tvg-93.ic86';l:$2000;p:$4000;crc:$71acd48d),(n:'tvg-94.ic87';l:$2000;p:$6000;crc:$82160b9a),
        (n:'sun-8212.ic3';l:$800;p:0;crc:$8869611e),());
        higemaru:array[0..10] of tipo_roms=(
        (n:'hg4.p12';l:$2000;p:0;crc:$dc67a7f9),(n:'hg5.m12';l:$2000;p:$2000;crc:$f65a4b68),
        (n:'hg6.p11';l:$2000;p:$4000;crc:$5f5296aa),(n:'hg7.m11';l:$2000;p:$6000;crc:$dc5d455d),
        (n:'hgb3.l6';l:$20;p:0;crc:$629cebd8),(n:'hgb5.m4';l:$100;p:$20;crc:$dbaa4443),
        (n:'hgb1.h7';l:$100;p:$120;crc:$07c607ce),(n:'hg3.m1';l:$2000;p:0;crc:$b37b88c8),
        (n:'hg1.c14';l:$2000;p:0;crc:$ef4c2f5d),(n:'hg2.e14';l:$2000;p:$2000;crc:$9133f804),());
        //bagman
        bagman:array[0..12] of tipo_roms=(
        (n:'e9_b05.bin';l:$1000;p:0;crc:$e0156191),(n:'f9_b06.bin';l:$1000;p:$1000;crc:$7b758982),
        (n:'f9_b07.bin';l:$1000;p:$2000;crc:$302a077b),(n:'k9_b08.bin';l:$1000;p:$3000;crc:$f04293cb),
        (n:'m9_b09s.bin';l:$1000;p:$4000;crc:$68e83e4f),(n:'n9_b10.bin';l:$1000;p:$5000;crc:$1d6579f7),
        (n:'p3.bin';l:$20;p:0;crc:$2a855523),(n:'r3.bin';l:$20;p:$20;crc:$ae6f1019),
        (n:'e1_b02.bin';l:$1000;p:0;crc:$4a0a6b55),(n:'j1_b04.bin';l:$1000;p:$1000;crc:$c680ef04),
        (n:'c1_b01.bin';l:$1000;p:0;crc:$705193b2),(n:'f1_b03s.bin';l:$1000;p:$1000;crc:$dba1eda7),());
        //Super Bagman
        sbagman:array[0..16] of tipo_roms=(
        (n:'5.9e';l:$1000;p:0;crc:$1b1d6b0a),(n:'6.9f';l:$1000;p:$1000;crc:$ac49cb82),
        (n:'7.9j';l:$1000;p:$2000;crc:$9a1c778d),(n:'8.9k';l:$1000;p:$3000;crc:$b94fbb73),
        (n:'9.9m';l:$1000;p:$4000;crc:$601f34ba),(n:'10.9n';l:$1000;p:$5000;crc:$5f750918),
        (n:'13.8d';l:$1000;p:$6000;crc:$944a4453),(n:'14.8f';l:$1000;p:$7000;crc:$83b10139),
        (n:'15.8j';l:$1000;p:$8000;crc:$fe924879),(n:'16.8k';l:$1000;p:$9000;crc:$b77eb1f5),
        (n:'p3.bin';l:$20;p:0;crc:$2a855523),(n:'r3.bin';l:$20;p:$20;crc:$ae6f1019),
        (n:'2.1e';l:$1000;p:0;crc:$f4d3d4e6),(n:'4.1j';l:$1000;p:$1000;crc:$2c6a510d),
        (n:'1.1c';l:$1000;p:0;crc:$a046ff44),(n:'3.1f';l:$1000;p:$1000;crc:$a4422da4),());
        //Congo
        congo:array[0..19] of tipo_roms=(
        (n:'congo_rev_c_rom1.u21';l:$2000;p:0;crc:$09355b5b),(n:'congo_rev_c_rom2a.u22';l:$2000;p:$2000;crc:$1c5e30ae),
        (n:'congo_rev_c_rom3.u23';l:$2000;p:$4000;crc:$5ee1132c),(n:'congo_rev_c_rom4.u24';l:$2000;p:$6000;crc:$5332b9bf),
        (n:'mr019.u87';l:$100;p:0;crc:$b788d8ae),(n:'mr019.u87';l:$100;p:$100;crc:$b788d8ae),
        (n:'tip_top_rom_8.u93';l:$2000;p:0;crc:$db99a619),(n:'tip_top_rom_9.u94';l:$2000;p:$2000;crc:$93e2309e),
        (n:'tip_top_rom_5.u76';l:$1000;p:0;crc:$7bf6ba2b),(n:'tip_top_rom_10.u95';l:$2000;p:$4000;crc:$f27a9407),
        (n:'tip_top_rom_12.u78';l:$2000;p:0;crc:$15e3377a),(n:'tip_top_rom_13.u79';l:$2000;p:$2000;crc:$1d1321c8),
        (n:'tip_top_rom_11.u77';l:$2000;p:$4000;crc:$73e2709f),(n:'tip_top_rom_14.u104';l:$2000;p:$6000;crc:$bf9169fe),
        (n:'tip_top_rom_16.u106';l:$2000;p:$8000;crc:$cb6d5775),(n:'tip_top_rom_15.u105';l:$2000;p:$a000;crc:$7b15a7a4),
        (n:'tip_top_rom_17.u19';l:$2000;p:0;crc:$5024e673),
        (n:'congo6.u57';l:$2000;p:0;crc:$d637f02b),(n:'congo7.u58';l:$2000;p:$2000;crc:$80927943),());
        //Zaxxon
        zaxxon:array[0..17] of tipo_roms=(
        (n:'zaxxon3.u27';l:$2000;p:0;crc:$6e2b4a30),(n:'zaxxon2.u28';l:$2000;p:$2000;crc:$1c9ea398),
        (n:'zaxxon1.u29';l:$1000;p:$4000;crc:$1c123ef9),
        (n:'zaxxon.u98';l:$100;p:0;crc:$6cc6695b),(n:'zaxxon.u72';l:$100;p:$100;crc:$deaa21f7),
        (n:'zaxxon14.u68';l:$800;p:0;crc:$07bf8c52),(n:'zaxxon15.u69';l:$800;p:$800;crc:$c215edcb),
        (n:'zaxxon6.u113';l:$2000;p:0;crc:$6e07bb68),(n:'zaxxon5.u112';l:$2000;p:$2000;crc:$0a5bce6a),
        (n:'zaxxon11.u77';l:$2000;p:0;crc:$eaf0dd4b),(n:'zaxxon12.u78';l:$2000;p:$2000;crc:$1c5369c7),
        (n:'zaxxon13.u79';l:$2000;p:$4000;crc:$ab4e8a9a),(n:'zaxxon8.u91';l:$2000;p:0;crc:$28d65063),
        (n:'zaxxon7.u90';l:$2000;p:$2000;crc:$6284c200),(n:'zaxxon4.u111';l:$2000;p:$4000;crc:$a5bf1465),
        (n:'zaxxon10.u93';l:$2000;p:$4000;crc:$a95e61fd),(n:'zaxxon9.u92';l:$2000;p:$6000;crc:$7e42691f),());
        kangaroo:array[0..11] of tipo_roms=(
        (n:'tvg_75.0';l:$1000;p:0;crc:$0d18c581),(n:'tvg_76.1';l:$1000;p:$1000;crc:$5978d37a),
        (n:'tvg_77.2';l:$1000;p:$2000;crc:$522d1097),(n:'tvg_78.3';l:$1000;p:$3000;crc:$063da970),
        (n:'tvg_79.4';l:$1000;p:$4000;crc:$9e5cf8ca),(n:'tvg_80.5';l:$1000;p:$5000;crc:$2fc18049),
        (n:'tvg_83.v0';l:$1000;p:0;crc:$c0446ca6),(n:'tvg_85.v2';l:$1000;p:$1000;crc:$72c52695),
        (n:'tvg_84.v1';l:$1000;p:$2000;crc:$e4cb26c2),(n:'tvg_86.v3';l:$1000;p:$3000;crc:$9e6a599f),
        (n:'tvg_81.8';l:$1000;p:0;crc:$fb449bfd),());
        bionicc:array[0..25] of tipo_roms=(
        (n:'tse_02.1a';l:$10000;p:0;crc:$e4aeefaa),(n:'tse_04.1b';l:$10000;p:$1;crc:$d0c8ec75),
        (n:'tse_03.2a';l:$10000;p:$20000;crc:$b2ac0a45),(n:'tse_05.2b';l:$10000;p:$20001;crc:$a79cb406),
        (n:'ts_01b.4e';l:$8000;p:0;crc:$a9a6cafa),(n:'ts.2f';l:$1000;p:0;crc:$3ed7f0be),
        (n:'tsu_08.8l';l:$8000;p:0;crc:$9bf0b7a2),(n:'tsu_07.5l';l:$8000;p:0;crc:$9469efa4),
        (n:'tsu_06.4l';l:$8000;p:$8000;crc:$40bf0eb4),(n:'ts_12.17f';l:$8000;p:0;crc:$e4b4619e),
        (n:'ts_11.15f';l:$8000;p:$8000;crc:$ab30237a),(n:'ts_17.17g';l:$8000;p:$10000;crc:$deb657e4),
        (n:'ts_16.15g';l:$8000;p:$18000;crc:$d363b5f9),(n:'ts_13.18f';l:$8000;p:$20000;crc:$a8f5a004),
        (n:'ts_18.18g';l:$8000;p:$28000;crc:$3b36948c),(n:'ts_23.18j';l:$8000;p:$30000;crc:$bbfbe58a),
        (n:'ts_24.18k';l:$8000;p:$38000;crc:$f156e564),(n:'tse_10.13f';l:$8000;p:0;crc:$d28eeacc),
        (n:'tsu_09.11f';l:$8000;p:$8000;crc:$6a049292),(n:'tse_15.13g';l:$8000;p:$10000;crc:$9b5593c0),
        (n:'tsu_14.11g';l:$8000;p:$18000;crc:$46b2ad83),(n:'tse_20.13j';l:$8000;p:$20000;crc:$b03db778),
        (n:'tsu_19.11j';l:$8000;p:$28000;crc:$b5c82722),(n:'tse_22.17j';l:$8000;p:$30000;crc:$d4dedeb3),
        (n:'tsu_21.15j';l:$8000;p:$38000;crc:$98777006),());
        wwfsstar:array[0..14] of tipo_roms=(
        (n:'24ac-0_j-1.34';l:$20000;p:0;crc:$ec8fd2c9),(n:'24ad-0_j-1.35';l:$20000;p:$1;crc:$54e614e4),
        (n:'24a9-0.46';l:$20000;p:0;crc:$703ff08f),(n:'24j8-0.45';l:$20000;p:$20000;crc:$61138487),
        (n:'24ab-0.12';l:$8000;p:0;crc:$1e44f8aa),(n:'24aa-0_j.58';l:$20000;p:0;crc:$b9201b36),
        (n:'c951.114';l:$80000;p:0;crc:$fa76d1f0),(n:'24j4-0.115';l:$40000;p:$80000;crc:$c4a589a3),
        (n:'24j5-0.116';l:$40000;p:$0c0000;crc:$d6bca436),(n:'c950.117';l:$80000;p:$100000;crc:$cca5703d),
        (n:'24j2-0.118';l:$40000;p:$180000;crc:$dc1b7600),(n:'24j3-0.119';l:$40000;p:$1c0000;crc:$3ba12d43),
        (n:'24j7-0.113';l:$40000;p:0;crc:$e0a1909e),(n:'24j6-0.112';l:$40000;p:$40000;crc:$77932ef8),());
        rbisland:array[0..11] of tipo_roms=(
        (n:'b22-10-1.19';l:$10000;p:0;crc:$e34a50ca),(n:'b22-11-1.20';l:$10000;p:$1;crc:$6a31a093),
        (n:'b22-08-1.21';l:$10000;p:$20000;crc:$15d6e17a),(n:'b22-09-1.22';l:$10000;p:$20001;crc:$454e66bc),
        (n:'b22-03.23';l:$20000;p:$40000;crc:$3ebb0fb8),(n:'b22-04.24';l:$20000;p:$40001;crc:$91625e7f),
        (n:'b22-01.2';l:$80000;p:0;crc:$b76c9168),(n:'b22-14.43';l:$10000;p:0;crc:$113c1a5b),
        (n:'b22-02.5';l:$80000;p:0;crc:$1b87ecf0),
        (n:'b22-12.7';l:$10000;p:$80000;crc:$67a76dc6),(n:'b22-13.6';l:$10000;p:$80001;crc:$2fda099f),());
        rbislande:array[0..11] of tipo_roms=(
        (n:'b39-01.19';l:$10000;p:0;crc:$50690880),(n:'b39-02.20';l:$10000;p:$1;crc:$4dead71f),
        (n:'b39-03.21';l:$10000;p:$20000;crc:$4a4cb785),(n:'b39-04.22';l:$10000;p:$20001;crc:$4caa53bd),
        (n:'b22-03.23';l:$20000;p:$40000;crc:$3ebb0fb8),(n:'b22-04.24';l:$20000;p:$40001;crc:$91625e7f),
        (n:'b22-01.2';l:$80000;p:0;crc:$b76c9168),(n:'b22-14.43';l:$10000;p:0;crc:$113c1a5b),
        (n:'b22-02.5';l:$80000;p:0;crc:$1b87ecf0),
        (n:'b22-12.7';l:$10000;p:$80000;crc:$67a76dc6),(n:'b22-13.6';l:$10000;p:$80001;crc:$2fda099f),());
        volfied:array[0..17] of tipo_roms=(
        (n:'c04-12-1.30';l:$10000;p:0;crc:$afb6a058),(n:'c04-08-1.10';l:$10000;p:$1;crc:$19f7e66b),
        (n:'c04-11-1.29';l:$10000;p:$20000;crc:$1aaf6e9b),(n:'c04-25-1.9';l:$10000;p:$20001;crc:$b39e04f9),
        (n:'c04-20.7';l:$20000;p:$0;crc:$0aea651f),(n:'c04-22.9';l:$20000;p:$1;crc:$f405d465),
        (n:'c04-19.6';l:$20000;p:$40000;crc:$231493ae),(n:'c04-21.8';l:$20000;p:$40001;crc:$8598d38e),
        (n:'c04-06.71';l:$8000;p:0;crc:$b70106b2),
        (n:'c04-16.2';l:$20000;p:$0;crc:$8c2476ef),(n:'c04-18.4';l:$20000;p:$1;crc:$7665212c),
        (n:'c04-15.1';l:$20000;p:$40000;crc:$7c50b978),(n:'c04-17.3';l:$20000;p:$40001;crc:$c62fdeb8),
        (n:'c04-10.15';l:$10000;p:$80000;crc:$429b6b49),(n:'c04-09.14';l:$10000;p:$80001;crc:$c78cf057),
        (n:'c04-10.15';l:$10000;p:$a0000;crc:$429b6b49),(n:'c04-09.14';l:$10000;p:$a0001;crc:$c78cf057),());
        opwolf:array[0..8] of tipo_roms=(
        (n:'b20-05-02.40';l:$10000;p:0;crc:$3ffbfe3a),(n:'b20-03-02.30';l:$10000;p:$1;crc:$fdabd8a5),
        (n:'b20-04.39';l:$10000;p:$20000;crc:$216b4838),(n:'b20-20.29';l:$10000;p:$20001;crc:$d244431a),
        (n:'b20-07.10';l:$10000;p:0;crc:$45c7ace3),(n:'b20-13.13';l:$80000;p:0;crc:$f6acdab1),
        (n:'b20-14.72';l:$80000;p:0;crc:$89f889e5),(n:'b20-08.21';l:$80000;p:0;crc:$f3e19c64),());
        //Outrun
        outrun:array[0..31] of tipo_roms=(
        (n:'epr-10380b.133';l:$10000;p:0;crc:$1f6cadad),(n:'epr-10382b.118';l:$10000;p:$1;crc:$c4c3fa1a),
        (n:'epr-10381b.132';l:$10000;p:$20000;crc:$be8c412b),(n:'epr-10383b.117';l:$10000;p:$20001;crc:$10a2014a),
        (n:'epr-10327a.76';l:$10000;p:0;crc:$e28a5baf),(n:'epr-10329a.58';l:$10000;p:$1;crc:$da131c81),
        (n:'epr-10328a.75';l:$10000;p:$20000;crc:$d5ec5e5d),(n:'epr-10330a.57';l:$10000;p:$20001;crc:$ba9ec82a),
        (n:'opr-10268.99';l:$8000;p:0;crc:$95344b04),(n:'opr-10232.102';l:$8000;p:$8000;crc:$776ba1eb),
        (n:'opr-10267.100';l:$8000;p:$10000;crc:$a85bb823),(n:'opr-10231.103';l:$8000;p:$18000;crc:$8908bcbf),
        (n:'opr-10266.101';l:$8000;p:$20000;crc:$9f6f1a74),(n:'opr-10230.104';l:$8000;p:$28000;crc:$686f5e50),
        (n:'mpr-10371.9';l:$20000;p:0;crc:$7cc86208),(n:'mpr-10373.10';l:$20000;p:$1;crc:$b0d26ac9),
        (n:'mpr-10375.11';l:$20000;p:$2;crc:$59b60bd7),(n:'mpr-10377.12';l:$20000;p:$3;crc:$17a1b04a),
        (n:'mpr-10372.13';l:$20000;p:$80000;crc:$b557078c),(n:'mpr-10374.14';l:$20000;p:$80001;crc:$8051e517),
        (n:'mpr-10376.15';l:$20000;p:$80002;crc:$f3b8f318),(n:'mpr-10378.16';l:$20000;p:$80003;crc:$a1062984),
        (n:'opr-10186.47';l:$8000;p:0;crc:$22794426),(n:'opr-10185.11';l:$8000;p:$8000;crc:$22794426),
        (n:'opr-10193.66';l:$8000;p:$0000;crc:$bcd10dde),(n:'opr-10192.67';l:$8000;p:$10000;crc:$770f1270),
        (n:'opr-10191.68';l:$8000;p:$20000;crc:$20a284ab),(n:'opr-10190.69';l:$8000;p:$30000;crc:$7cab70e2),
        (n:'opr-10189.70';l:$8000;p:$40000;crc:$01366b54),(n:'opr-10188.71';l:$8000;p:$50000;crc:$bad30ad9),
        (n:'epr-10187.88';l:$8000;p:0;crc:$a10abaa9),());
        //Elevator Action
        elevator:array[0..12] of tipo_roms=(
        (n:'ba3__01.2764.ic1';l:$2000;p:0;crc:$da775a24),(n:'ba3__02.2764.ic2';l:$2000;p:$2000;crc:$fbfd8b3a),
        (n:'ba3__03-1.2764.ic3';l:$2000;p:$4000;crc:$a2e69833),(n:'ba3__04-1.2764.ic6';l:$2000;p:$6000;crc:$2b78c462),
        (n:'ba3__09.2732.ic70';l:$1000;p:0;crc:$6d5f57cb),(n:'ba3__10.2732.ic71';l:$1000;p:$1000;crc:$f0a769a1),
        (n:'ba3__11.mc68705p3.ic24';l:$800;p:0;crc:$9ce75afc),(n:'eb16.22';l:$100;p:0;crc:$b833b5ea),
        (n:'ba3__05.2764.ic4';l:$2000;p:0;crc:$6c4ee58f),(n:'ba3__06.2764.ic5';l:$2000;p:$2000;crc:$41ab0afc),
        (n:'ba3__07.2764.ic9';l:$2000;p:$4000;crc:$efe43731),(n:'ba3__08.2764.ic10';l:$2000;p:$6000;crc:$3ca20696),());
        //Jungle King
        junglek:array[0..21] of tipo_roms=(
        (n:'kn21-1.bin';l:$1000;p:0;crc:$45f55d30),(n:'kn22-1.bin';l:$1000;p:$1000;crc:$07cc9a21),
        (n:'kn43.bin';l:$1000;p:$2000;crc:$a20e5a48),(n:'kn24.bin';l:$1000;p:$3000;crc:$19ea7f83),
        (n:'kn25.bin';l:$1000;p:$4000;crc:$844365ea),(n:'kn46.bin';l:$1000;p:$5000;crc:$27a95fd5),
        (n:'kn47.bin';l:$1000;p:$6000;crc:$5c3199e0),(n:'kn28.bin';l:$1000;p:$7000;crc:$194a2d09),
        (n:'kn37.bin';l:$1000;p:0;crc:$dee7f5d4),(n:'kn38.bin';l:$1000;p:$1000;crc:$bffd3d21),
        (n:'kn60.bin';l:$1000;p:$8000;crc:$1a9c0a26),(n:'kn59-1.bin';l:$1000;p:$2000;crc:$cee485fc),
        (n:'kn29.bin';l:$1000;p:0;crc:$8f83c290),(n:'kn30.bin';l:$1000;p:$1000;crc:$89fd19f1),
        (n:'kn51.bin';l:$1000;p:$2000;crc:$70e8fc12),(n:'kn52.bin';l:$1000;p:$3000;crc:$bcbac1a3),
        (n:'kn53.bin';l:$1000;p:$4000;crc:$b946c87d),(n:'kn34.bin';l:$1000;p:$5000;crc:$320db2e1),
        (n:'kn55.bin';l:$1000;p:$6000;crc:$70aef58f),(n:'kn56.bin';l:$1000;p:$7000;crc:$932eb667),
        (n:'eb16.22';l:$100;p:0;crc:$b833b5ea),());
        vulgus:array[0..23] of tipo_roms=(
        (n:'vulgus.002';l:$2000;p:0;crc:$e49d6c5d),(n:'vulgus.003';l:$2000;p:$2000;crc:$51acef76),
        (n:'vulgus.004';l:$2000;p:$4000;crc:$489e7f60),(n:'vulgus.005';l:$2000;p:$6000;crc:$de3a24a8),
        (n:'1-8n.bin';l:$2000;p:$8000;crc:$6ca5ca41),(n:'1-11c.bin';l:$2000;p:0;crc:$3bd2acf4),
        (n:'e8.bin';l:$100;p:0;crc:$06a83606),(n:'e9.bin';l:$100;p:$100;crc:$beacf13c),
        (n:'e10.bin';l:$100;p:$200;crc:$de1fb621),(n:'d1.bin';l:$100;p:$300;crc:$7179080d),
        (n:'j2.bin';l:$100;p:$400;crc:$d0842029),(n:'c9.bin';l:$100;p:$500;crc:$7a1f0bd6),
        (n:'1-3d.bin';l:$2000;p:0;crc:$8bc5d7a5),
        (n:'2-2n.bin';l:$2000;p:0;crc:$6db1b10d),(n:'2-3n.bin';l:$2000;p:$2000;crc:$5d8c34ec),
        (n:'2-4n.bin';l:$2000;p:$4000;crc:$0071a2e3),(n:'2-5n.bin';l:$2000;p:$6000;crc:$4023a1ec),
        (n:'2-2a.bin';l:$2000;p:0;crc:$e10aaca1),(n:'2-3a.bin';l:$2000;p:$2000;crc:$8da520da),
        (n:'2-4a.bin';l:$2000;p:$4000;crc:$206a13f1),(n:'2-5a.bin';l:$2000;p:$6000;crc:$b6d81984),
        (n:'2-6a.bin';l:$2000;p:$8000;crc:$5a26b38f),(n:'2-7a.bin';l:$2000;p:$a000;crc:$1e1ca773),());
        ddragon3:array[0..16] of tipo_roms=(
        (n:'30a14-0.ic78';l:$40000;p:1;crc:$f42fe016),(n:'30a15-0.ic79';l:$20000;p:$0;crc:$ad50e92c),
        (n:'30a13-0.ic43';l:$10000;p:0;crc:$1e974d9b),(n:'30j-8.ic73';l:$80000;p:0;crc:$c3ad40f3),
        (n:'30j-3.ic9';l:$80000;p:0;crc:$b3151871),(n:'30a12-0.ic8';l:$10000;p:$80000;crc:$20d64bea),
        (n:'30j-2.ic11';l:$80000;p:$100000;crc:$41c6fb08),(n:'30a11-0.ic10';l:$10000;p:$180000;crc:$785d71b0),
        (n:'30j-1.ic13';l:$80000;p:$200000;crc:$67a6f114),(n:'30a10-0.ic12';l:$10000;p:$280000;crc:$15e43d12),
        (n:'30j-0.ic15';l:$80000;p:$300000;crc:$f15dafbe),(n:'30a9-0.ic14';l:$10000;p:$380000;crc:$5a47e7a4),
        (n:'30j-7.ic4';l:$40000;p:0;crc:$89d58d32),(n:'30j-6.ic5';l:$40000;p:$1;crc:$9bf1538e),
        (n:'30j-5.ic6';l:$40000;p:$80000;crc:$8f671a62),(n:'30j-4.ic7';l:$40000;p:$80001;crc:$0f74ea1c),());
        blockout:array[0..4] of tipo_roms=(
        (n:'bo29a0-2.bin';l:$20000;p:0;crc:$b0103427),(n:'bo29a1-2.bin';l:$20000;p:$1;crc:$5984d5a2),
        (n:'bo29e3-0.bin';l:$8000;p:0;crc:$3ea01f78),(n:'bo29e2-0.bin';l:$20000;p:0;crc:$15c5a99d),());
        foodf:array[0..12] of tipo_roms=(
        (n:'136020-301.8c';l:$2000;p:1;crc:$dfc3d5a8),(n:'136020-302.9c';l:$2000;p:$0;crc:$ef92dc5c),
        (n:'136020-303.8d';l:$2000;p:$4001;crc:$64b93076),(n:'136020-204.9d';l:$2000;p:$4000;crc:$ea596480),
        (n:'136020-305.8e';l:$2000;p:$8001;crc:$e6cff1b1),(n:'136020-306.9e';l:$2000;p:$8000;crc:$95159a3e),
        (n:'136020-307.8f';l:$2000;p:$c001;crc:$17828dbb),(n:'136020-208.9f';l:$2000;p:$c000;crc:$608690c9),
        (n:'136020-109.6lm';l:$2000;p:0;crc:$c13c90eb),(n:'136020-110.4e';l:$2000;p:0;crc:$8870e3d6),
        (n:'136020-111.4d';l:$2000;p:$2000;crc:$84372edf),(n:'foodf.nv';l:$100;p:0;crc:$a4186b13),());
        nemesis:array[0..11] of tipo_roms=(
        (n:'456-d01.12a';l:$8000;p:0;crc:$35ff1aaa),(n:'456-d05.12c';l:$8000;p:$1;crc:$23155faa),
        (n:'456-d02.13a';l:$8000;p:$10000;crc:$ac0cf163),(n:'456-d06.13c';l:$8000;p:$10001;crc:$023f22a9),
        (n:'456-d03.14a';l:$8000;p:$20000;crc:$8cefb25f),(n:'456-d07.14c';l:$8000;p:$20001;crc:$d50b82cb),
        (n:'456-d04.15a';l:$8000;p:$30000;crc:$9ca75592),(n:'456-d08.15c';l:$8000;p:$30001;crc:$03c0b7f5),
        (n:'456-d09.9c';l:$4000;p:0;crc:$26bf9636),(n:'400-a01.fse';l:$100;p:$0;crc:$5827b1e8),
        (n:'400-a02.fse';l:$100;p:$100;crc:$2f44f970),());
        twinbee:array[0..7] of tipo_roms=(
        (n:'400-a01.fse';l:$100;p:$0;crc:$5827b1e8),(n:'400-a02.fse';l:$100;p:$100;crc:$2f44f970),
        (n:'400-a06.15l';l:$8000;p:0;crc:$b99d8cff),(n:'400-a04.10l';l:$8000;p:$1;crc:$d02c9552),
        (n:'400-e03.5l';l:$2000;p:0;crc:$a5a8e57d),(n:'412-a07.17l';l:$20000;p:$0;crc:$d93c5499),
        (n:'412-a05.12l';l:$20000;p:$1;crc:$2b357069),());
        //Pirates
        pirates:array[0..11] of tipo_roms=(
        (n:'r_449b.bin';l:$80000;p:0;crc:$224aeeda),(n:'l_5c1e.bin';l:$80000;p:$1;crc:$46740204),
        (n:'p4_4d48.bin';l:$80000;p:0;crc:$89fda216),(n:'p2_5d74.bin';l:$80000;p:$80000;crc:$40e069b4),
        (n:'p1_7b30.bin';l:$80000;p:$100000;crc:$26d78518),(n:'p8_9f4f.bin';l:$80000;p:$180000;crc:$f31696ea),
        (n:'s1_6e89.bin';l:$80000;p:0;crc:$c78a276f),(n:'s2_6df3.bin';l:$80000;p:$80000;crc:$9f0bad96),
        (n:'s4_fdcc.bin';l:$80000;p:$100000;crc:$8916ddb5),(n:'s8_4b7c.bin';l:$80000;p:$180000;crc:$1c41bd2c),
        (n:'s89_49d4.bin';l:$80000;p:0;crc:$63a739ec),());
        //Genix Family
        genix:array[0..11] of tipo_roms=(
        (n:'1.15';l:$80000;p:0;crc:$d26abfb0),(n:'2.16';l:$80000;p:$1;crc:$a14a25b4),
        (n:'7.34';l:$40000;p:0;crc:$58da8aac),(n:'9.35';l:$40000;p:$80000;crc:$96bad9a8),
        (n:'8.48';l:$40000;p:$100000;crc:$0ddc58b6),(n:'10.49';l:$40000;p:$180000;crc:$2be308c5),
        (n:'6.69';l:$40000;p:0;crc:$b8422af7),(n:'5.70';l:$40000;p:$80000;crc:$e46125c5),
        (n:'4.71';l:$40000;p:$100000;crc:$7a8ed21b),(n:'3.72';l:$40000;p:$180000;crc:$f78bd6ca),
        (n:'0.31';l:$80000;p:0;crc:$80d087bc),());
        junofrst:array[0..14] of tipo_roms=(
        (n:'jfa_b9.bin';l:$2000;p:$a000;crc:$f5a7ab9d),(n:'jfb_b10.bin';l:$2000;p:$c000;crc:$f20626e0),
        (n:'jfc1_a4.bin';l:$2000;p:$0;crc:$03ccbf1d),(n:'jfc2_a5.bin';l:$2000;p:$2000;crc:$cb372372),
        (n:'jfc3_a6.bin';l:$2000;p:$4000;crc:$879d194b),(n:'jfc4_a7.bin';l:$2000;p:$6000;crc:$f28af80b),
        (n:'jfc5_a8.bin';l:$2000;p:$8000;crc:$0539f328),(n:'jfc6_a9.bin';l:$2000;p:$a000;crc:$1da2ad6e),
        (n:'jfs1_j3.bin';l:$1000;p:0;crc:$235a2893),(n:'jfs2_p4.bin';l:$1000;p:0;crc:$d0fa5d5f),
        (n:'jfs3_c7.bin';l:$2000;p:$0;crc:$aeacf6db),(n:'jfs4_d7.bin';l:$2000;p:$2000;crc:$206d954c),
        (n:'jfc_a10.bin';l:$2000;p:$e000;crc:$1e7744a7),(n:'jfs5_e7.bin';l:$2000;p:$4000;crc:$1eb87a6e),());
        gyruss:array[0..15] of tipo_roms=(
        (n:'gyrussk.1';l:$2000;p:0;crc:$c673b43d),(n:'gyrussk.2';l:$2000;p:$2000;crc:$a4ec03e4),
        (n:'gyrussk.3';l:$2000;p:$4000;crc:$27454a98),(n:'gyrussk.9';l:$2000;p:$e000;crc:$822bf27e),
        (n:'gyrussk.1a';l:$2000;p:0;crc:$f4ae1c17),(n:'gyrussk.2a';l:$2000;p:$2000;crc:$ba498115),
        (n:'gyrussk.3a';l:$1000;p:$0;crc:$3f9b5dea),(n:'gyrussk.4';l:$2000;p:$0;crc:$27d8329b),
        (n:'gyrussk.6';l:$2000;p:0;crc:$c949db10),(n:'gyrussk.5';l:$2000;p:$2000;crc:$4f22411a),
        (n:'gyrussk.8';l:$2000;p:$4000;crc:$47cd1fbc),(n:'gyrussk.7';l:$2000;p:$6000;crc:$8e8d388c),
        (n:'gyrussk.pr3';l:$20;p:0;crc:$98782db3),(n:'gyrussk.pr1';l:$100;p:$20;crc:$7ed057de),
        (n:'gyrussk.pr2';l:$100;p:$120;crc:$de823a81),());
        boogwing:array[0..18] of tipo_roms=(
        (n:'kn_00-2.2b';l:$40000;p:0;crc:$e38892b9),(n:'kn_02-2.2e';l:$40000;p:$1;crc:$8426efef),
        (n:'kn_01-2.4b';l:$40000;p:$80000;crc:$3ad4b54c),(n:'kn_03-2.4e';l:$40000;p:$80001;crc:$10b61f4a),
        (n:'km06.18p';l:$10000;p:$0;crc:$3e8bc4e1),(n:'mbd-02.10e';l:$80000;p:0;crc:$b25aa721),
        (n:'km05.9e';l:$10000;p:0;crc:$d10aef95),(n:'km04.8e';l:$10000;p:$1;crc:$329323a8),
        (n:'mbd-01.9b';l:$100000;p:0;crc:$d7de4f4b),(n:'mbd-00.8b';l:$100000;p:$100000;crc:$adb20ba9),
        (n:'mbd-03.13b';l:$100000;p:0;crc:$cf798f2c),(n:'mbd-04.14b';l:$100000;p:$100000;crc:$d9764d0b),
        (n:'mbd-05.16b';l:$200000;p:1;crc:$1768c66a),(n:'mbd-06.17b';l:$200000;p:$0;crc:$7750847a),
        (n:'mbd-07.18b';l:$200000;p:1;crc:$241faac1),(n:'mbd-08.19b';l:$200000;p:$0;crc:$f13b1e56),
        (n:'mbd-10.17p';l:$80000;p:0;crc:$f159f76a),(n:'mbd-09.16p';l:$80000;p:0;crc:$f44f2f87),());
        //Freekick
        freekick:array[0..14] of tipo_roms=(
        (n:'ns6201-a_1987.10_free_kick.cpu';l:$d000;p:0;crc:$6d172850),(n:'11.1e';l:$8000;p:0;crc:$a6030ba9),
        (n:'24s10n.8j';l:$100;p:0;crc:$53a6bc21),(n:'24s10n.7j';l:$100;p:$100;crc:$38dd97d8),
        (n:'24s10n.8k';l:$100;p:$200;crc:$18e66087),(n:'24s10n.7k';l:$100;p:$300;crc:$bc21797a),
        (n:'24s10n.8h';l:$100;p:$400;crc:$8aac5fd0),(n:'24s10n.7h';l:$100;p:$500;crc:$a507f941),
        (n:'12.1h';l:$4000;p:0;crc:$fb82e486),(n:'13.1j';l:$4000;p:$4000;crc:$3ad78ee2),
        (n:'15.1m';l:$4000;p:0;crc:$0fa7c13c),(n:'16.1p';l:$4000;p:$4000;crc:$2b996e89),
        (n:'14.1l';l:$4000;p:$8000;crc:$0185695f),(n:'17.1r';l:$4000;p:$8000;crc:$e7894def),());
        pbaction:array[0..14] of tipo_roms=(
        (n:'b-p7.bin';l:$4000;p:0;crc:$8d6dcaae),(n:'b-n7.bin';l:$4000;p:$4000;crc:$d54d5402),
        (n:'b-l7.bin';l:$2000;p:$8000;crc:$e7412d68),(n:'a-e3.bin';l:$2000;p:0;crc:$0e53a91f),
        (n:'a-s6.bin';l:$2000;p:0;crc:$9a74a8e1),(n:'a-s7.bin';l:$2000;p:$2000;crc:$5ca6ad3c),
        (n:'a-s8.bin';l:$2000;p:$4000;crc:$9f00b757),(n:'b-f7.bin';l:$2000;p:$4000;crc:$af6e9817),
        (n:'b-c7.bin';l:$2000;p:0;crc:$d1795ef5),(n:'b-d7.bin';l:$2000;p:$2000;crc:$f28df203),
        (n:'a-j5.bin';l:$4000;p:0;crc:$21efe866),(n:'a-j6.bin';l:$4000;p:$4000;crc:$7f984c80),
        (n:'a-j7.bin';l:$4000;p:$8000;crc:$df69e51b),(n:'a-j8.bin';l:$4000;p:$c000;crc:$0094cb8b),());
        renegade:array[0..26] of tipo_roms=(
        (n:'nb-5.ic51';l:$8000;p:$0;crc:$ba683ddf),(n:'na-5.ic52';l:$8000;p:$8000;crc:$de7e7df4),
        (n:'nc-5.bin';l:$8000;p:$0;crc:$9adfaa5d),(n:'n0-5.ic13';l:$8000;p:$8000;crc:$3587de3b),
        (n:'n1-5.ic1';l:$8000;p:$0;crc:$4a9f47f3),(n:'n6-5.ic28';l:$8000;p:$8000;crc:$d62a0aa8),
        (n:'n7-5.ic27';l:$8000;p:$10000;crc:$7ca5a532),(n:'n2-5.ic14';l:$8000;p:$18000;crc:$8d2e7982),
        (n:'n8-5.ic26';l:$8000;p:$20000;crc:$0dba31d3),(n:'n9-5.ic25';l:$8000;p:$28000;crc:$5b621b6a),
        (n:'nh-5.bin';l:$8000;p:$0;crc:$dcd7857c),(n:'nd-5.bin';l:$8000;p:$8000;crc:$2de1717c),
        (n:'nj-5.bin';l:$8000;p:$10000;crc:$0f96a18e),(n:'nn-5.bin';l:$8000;p:$18000;crc:$1bf15787),
        (n:'ne-5.bin';l:$8000;p:$20000;crc:$924c7388),(n:'nk-5.bin';l:$8000;p:$28000;crc:$69499a94),
        (n:'ni-5.bin';l:$8000;p:$30000;crc:$6f597ed2),(n:'nf-5.bin';l:$8000;p:$38000;crc:$0efc8d45),
        (n:'nl-5.bin';l:$8000;p:$40000;crc:$14778336),(n:'no-5.bin';l:$8000;p:$48000;crc:$147dd23b),
        (n:'ng-5.bin';l:$8000;p:$50000;crc:$a8ee3720),(n:'nm-5.bin';l:$8000;p:$58000;crc:$c100258e),
        (n:'n5-5.ic31';l:$8000;p:$0;crc:$7ee43a3c),(n:'n4-5.ic32';l:$8000;p:$10000;crc:$6557564c),
        (n:'nz-5.ic97';l:$800;p:$0;crc:$32e47560),(n:'n3-5.ic33';l:$8000;p:$18000;crc:$78fd6190),());
        //TMNT
        tmnt:array[0..16] of tipo_roms=(
        (n:'963-u23.j17';l:$20000;p:0;crc:$58bec748),(n:'963-u24.k17';l:$20000;p:$1;crc:$dce87c8d),
        (n:'963-u21.j15';l:$10000;p:$40000;crc:$abce5ead),(n:'963-u22.k15';l:$10000;p:$40001;crc:$4ecc8d6b),
        (n:'963e20.g13';l:$8000;p:0;crc:$1692a6d6),(n:'963a28.h27';l:$80000;p:0;crc:$db4769a8),
        (n:'963a29.k27';l:$80000;p:$2;crc:$8069cd2e),(n:'963a17.h4';l:$80000;p:0;crc:$b5239a44),
        (n:'963a15.k4';l:$80000;p:$2;crc:$1f324eed),(n:'963a18.h6';l:$80000;p:$100000;crc:$dd51adef),
        (n:'963a16.k6';l:$80000;p:$100002;crc:$d4bd9984),(n:'963a30.g7';l:$100;p:0;crc:$abd82680),
        (n:'963a31.g19';l:$100;p:$100;crc:$f8004a1c),(n:'963a27.d18';l:$20000;p:0;crc:$2dfd674b),
        (n:'963a25.d5';l:$80000;p:0;crc:$fca078c7),(n:'963a26.c13';l:$20000;p:0;crc:$e2ac3063),());
        //Sunset Riders
        ssriders:array[0..11] of tipo_roms=(
        (n:'064ebd02.8e';l:$40000;p:0;crc:$8deef9ac),(n:'064ebd03.8g';l:$40000;p:$1;crc:$2370c107),
        (n:'064eab04.10e';l:$20000;p:$80000;crc:$ef2315bd),(n:'064eab05.10g';l:$20000;p:$80001;crc:$51d6fbc4),
        (n:'064e01.2f';l:$10000;p:0;crc:$44b9bc52),(n:'064e12.16k';l:$80000;p:0;crc:$e2bdc619),
        (n:'064e11.12k';l:$80000;p:$2;crc:$2d8ca8b0),(n:'064e09.7l';l:$100000;p:0;crc:$4160c372),
        (n:'064e07.3l';l:$100000;p:$2;crc:$64dd673c),(n:'ssriders_ebd.nv';l:$80;p:0;crc:$cbc903f6),
        (n:'064e06.1d';l:$100000;p:0;crc:$59810df9),());
        //gradius3
        gradius3:array[0..24] of tipo_roms=(
        (n:'945_r13.f15';l:$20000;p:0;crc:$cffd103f),(n:'945_r12.e15';l:$20000;p:$1;crc:$0b968ef6),
        (n:'945_m09.r17';l:$20000;p:0;crc:$b4a6df25),(n:'945_m08.n17';l:$20000;p:$1;crc:$74e981d2),
        (n:'945_l06b.r11';l:$20000;p:$40000;crc:$83772304),(n:'945_l06a.n11';l:$20000;p:$40001;crc:$e1fd75b6),
        (n:'945_l07c.r15';l:$20000;p:$80000;crc:$c1e399b6),(n:'945_l07a.n15';l:$20000;p:$80001;crc:$96222d04),
        (n:'945_l07d.r13';l:$20000;p:$c0000;crc:$4c16d4bd),(n:'945_l07b.n13';l:$20000;p:$c0001;crc:$5e209d01),
        (n:'945_a02.l3';l:$80000;p:0;crc:$4dfffd74),(n:'945_a01.h3';l:$80000;p:2;crc:$339d6dd2),
        (n:'945_l04a.k6';l:$20000;p:$100000;crc:$884e21ee),(n:'945_l04c.m6';l:$20000;p:$100001;crc:$45bcd921),
        (n:'945_l03a.e6';l:$20000;p:$100002;crc:$a67ef087),(n:'945_l03c.h6';l:$20000;p:$100003;crc:$a56be17a),
        (n:'945_l04b.k8';l:$20000;p:$180000;crc:$843bc67d),(n:'945_l04d.m8';l:$20000;p:$180001;crc:$0a98d08e),
        (n:'945_l03b.e8';l:$20000;p:$180002;crc:$933e68b9),(n:'945_l03d.h8';l:$20000;p:$180003;crc:$f375e87b),
        (n:'945_a10.b15';l:$40000;p:0;crc:$1d083e10),(n:'945_l11a.c18';l:$20000;p:$40000;crc:$6043f4eb),
        (n:'945_r05.d9';l:$10000;p:0;crc:$c8c45365),(n:'945_l11b.c20';l:$20000;p:$60000;crc:$89ea3baf),());
        //Space Invaders
        spaceinv:array[0..4] of tipo_roms=(
        (n:'invaders.h';l:$800;p:0;crc:$734f5ad8),(n:'invaders.g';l:$800;p:$800;crc:$6bfaca4a),
        (n:'invaders.f';l:$800;p:$1000;crc:$0ccead96),(n:'invaders.e';l:$800;p:$1800;crc:$14e538b0),());
        centipede:array[0..6] of tipo_roms=(
        (n:'136001-407.d1';l:$800;p:$2000;crc:$c4d995eb),(n:'136001-408.e1';l:$800;p:$2800;crc:$bcdebe1b),
        (n:'136001-409.fh1';l:$800;p:$3000;crc:$66d7b04a),(n:'136001-410.j1';l:$800;p:$3800;crc:$33ce4640),
        (n:'136001-211.f7';l:$800;p:0;crc:$880acfb9),(n:'136001-212.hj7';l:$800;p:$800;crc:$b1397029),());
        karnov:array[0..23] of tipo_roms=(
        (n:'dn08-6.j15';l:$10000;p:0;crc:$4c60837f),(n:'dn11-6.j20';l:$10000;p:$1;crc:$cd4abb99),
        (n:'dn07-.j14';l:$10000;p:$20000;crc:$fc14291b),(n:'dn10-.j18';l:$10000;p:$20001;crc:$a4a34e37),
        (n:'dn06-5.j13';l:$10000;p:$40000;crc:$29d64e42),(n:'dn09-5.j17';l:$10000;p:$40001;crc:$072d7c49),
        (n:'dn-5.k14';l:$1000;p:$0;crc:$d056de4e),(n:'dn05-5.f3';l:$8000;p:$8000;crc:$fa1a31a8),
        (n:'dn00-.c5';l:$8000;p:$0;crc:$0ed77c6d),(n:'dn04-.d18';l:$10000;p:0;crc:$a9121653),
        (n:'dn01-.c15';l:$10000;p:$10000;crc:$18697c9e),(n:'dn03-.d15';l:$10000;p:$20000;crc:$90d9dd9c),
        (n:'dn02-.c18';l:$10000;p:$30000;crc:$1e04d7b9),(n:'dn12-.f8';l:$10000;p:$00000;crc:$9806772c),
        (n:'dn14-5.f11';l:$8000;p:$10000;crc:$ac9e6732),(n:'dn13-.f9';l:$10000;p:$20000;crc:$a03308f9),
        (n:'dn15-5.f12';l:$8000;p:$30000;crc:$8933fcb8),(n:'dn16-.f13';l:$10000;p:$40000;crc:$55e63a11),
        (n:'dn17-5.f15';l:$8000;p:$50000;crc:$b70ae950),(n:'dn18-.f16';l:$10000;p:$60000;crc:$2ad53213),
        (n:'dn19-5.f18';l:$8000;p:$70000;crc:$8fd4fa40),(n:'dn-21.k8';l:$400;p:$0;crc:$aab0bb93),
        (n:'dn-20.l6';l:$400;p:$400;crc:$02f78ffb),());
        chelnov:array[0..19] of tipo_roms=(
        (n:'ee08-e.j16';l:$10000;p:0;crc:$8275cc3a),(n:'ee11-e.j19';l:$10000;p:$1;crc:$889e40a0),
        (n:'a-j14.bin';l:$10000;p:$20000;crc:$51465486),(n:'a-j18.bin';l:$10000;p:$20001;crc:$d09dda33),
        (n:'ee06-e.j13';l:$10000;p:$40000;crc:$55acafdb),(n:'ee09-e.j17';l:$10000;p:$40001;crc:$303e252c),
        (n:'ee05-.f3';l:$8000;p:$8000;crc:$6a8936b4),(n:'ee00-e.c5';l:$8000;p:$0;crc:$e06e5c6b),
        (n:'ee04-.d18';l:$10000;p:0;crc:$96884f95),(n:'ee01-.c15';l:$10000;p:$10000;crc:$f4b54057),
        (n:'ee03-.d15';l:$10000;p:$20000;crc:$7178e182),(n:'ee02-.c18';l:$10000;p:$30000;crc:$9d7c45ae),
        (n:'ee12-.f8';l:$10000;p:$00000;crc:$9b1c53a5),(n:'ee13-.f9';l:$10000;p:$20000;crc:$72b8ae3e),
        (n:'ee14-.f13';l:$10000;p:$40000;crc:$d8f4bbde),(n:'ee15-.f15';l:$10000;p:$60000;crc:$81e3e68b),
        (n:'ee21.k8';l:$400;p:$0;crc:$b1db6586),(n:'ee20.l6';l:$400;p:$400;crc:$41816132),
        (n:'ee-e.k14';l:$1000;p:$0;crc:$b7045395),());
        //aliens
        aliens:array[0..12] of tipo_roms=(
        (n:'875_j01.c24';l:$20000;p:0;crc:$6a529cd6),(n:'875_j02.e24';l:$10000;p:$20000;crc:$56c20971),
        (n:'875_b03.g04';l:$8000;p:0;crc:$1ac4d283),(n:'875b11.k13';l:$80000;p:0;crc:$89c5c885),
        (n:'875b12.k19';l:$80000;p:2;crc:$ea6bdc17),(n:'875b07.j13';l:$40000;p:100000;crc:$e9c56d66),
        (n:'875b08.j19';l:$40000;p:100002;crc:$f9387966),(n:'875b10.k08';l:$80000;p:0;crc:$0b1035b1),
        (n:'875b09.k02';l:$80000;p:2;crc:$e76b3c19),(n:'875b06.j08';l:$40000;p:100000;crc:$081a0566),
        (n:'875b05.j02';l:$40000;p:100002;crc:$19a261f2),(n:'875b04.e05';l:$40000;p:0;crc:$4e209ac8),());
        //super contra
        scontra:array[0..39] of tipo_roms=(
        (n:'775-e02.k11';l:$10000;p:0;crc:$a61c0ead),(n:'775-e03.k13';l:$10000;p:$10000;crc:$00b02622),
        (n:'775-c01.bin';l:$8000;p:0;crc:$0ced785a),
        (n:'775-a07a.bin';l:$20000;p:0;crc:$e716bdf3),(n:'775-a07e.bin';l:$20000;p:1;crc:$0986e3a5),
        (n:'775-a08a.bin';l:$20000;p:2;crc:$3ddd11a4),(n:'775-a08e.bin';l:$20000;p:3;crc:$1007d963),
        (n:'775-f07c.bin';l:$10000;p:$80000;crc:$b0b30915),(n:'775-f07g.bin';l:$10000;p:$80001;crc:$fbed827d),
        (n:'775-f08c.bin';l:$10000;p:$80002;crc:$53abdaec),(n:'775-f08g.bin';l:$10000;p:$80003;crc:$3df85a6e),
        (n:'775-f07d.bin';l:$10000;p:$c0000;crc:$f184be8e),(n:'775-f07h.bin';l:$10000;p:$c0001;crc:$7b56c348),
        (n:'775-f08d.bin';l:$10000;p:$c0002;crc:$102dcace),(n:'775-f08h.bin';l:$10000;p:$c0003;crc:$ad9d7016),
        (n:'775-a05a.bin';l:$10000;p:0;crc:$a0767045),(n:'775-a05e.bin';l:$10000;p:1;crc:$2f656f08),
        (n:'775-a06a.bin';l:$10000;p:2;crc:$77a34ad0),(n:'775-a06e.bin';l:$10000;p:3;crc:$8a910c94),
        (n:'775-a05b.bin';l:$10000;p:$40000;crc:$ab8ad4fd),(n:'775-a05f.bin';l:$10000;p:$40001;crc:$1c0eb1b6),
        (n:'775-a06b.bin';l:$10000;p:$40002;crc:$563fb565),(n:'775-a06f.bin';l:$10000;p:$40003;crc:$e14995c0),
        (n:'775-f05c.bin';l:$10000;p:$80000;crc:$5647761e),(n:'775-f05g.bin';l:$10000;p:$80001;crc:$a1692cca),
        (n:'775-f06c.bin';l:$10000;p:$80002;crc:$5ee6f3c1),(n:'775-f06g.bin';l:$10000;p:$80003;crc:$2645274d),
        (n:'775-f05d.bin';l:$10000;p:$c0000;crc:$ad676a6f),(n:'775-f05h.bin';l:$10000;p:$c0001;crc:$3f925bcf),
        (n:'775-f06d.bin';l:$10000;p:$c0002;crc:$c8b764fa),(n:'775-f06h.bin';l:$10000;p:$c0003;crc:$d6595f59),
        (n:'775-a04a.bin';l:$10000;p:$0;crc:$7efb2e0f),(n:'775-a04b.bin';l:$10000;p:$10000;crc:$f41a2b33),
        (n:'775-a04c.bin';l:$10000;p:$20000;crc:$e4e58f14),(n:'775-a04d.bin';l:$10000;p:$30000;crc:$d46736f6),
        (n:'775-f04e.bin';l:$10000;p:$40000;crc:$fbf7e363),(n:'775-f04f.bin';l:$10000;p:$50000;crc:$b031ef2d),
        (n:'775-f04g.bin';l:$10000;p:$60000;crc:$ee107bbb),(n:'775-f04h.bin';l:$10000;p:$70000;crc:$fb0fab46),());
        gbusters:array[0..8] of tipo_roms=(
        (n:'878n02.k13';l:$10000;p:0;crc:$51697aaa),(n:'878j03.k15';l:$10000;p:$10000;crc:$3943a065),
        (n:'878h01.f8';l:$8000;p:0;crc:$96feafaa),(n:'878c07.h27';l:$40000;p:0;crc:$eeed912c),
        (n:'878c08.k27';l:$40000;p:2;crc:$4d14626d),(n:'878c05.h5';l:$40000;p:0;crc:$01f4aea5),
        (n:'878c06.k5';l:$40000;p:2;crc:$edfaaaaf),(n:'878c04.d5';l:$40000;p:0;crc:$9e982d1c),());
        thunderx:array[0..19] of tipo_roms=(
        (n:'873-s02.k13';l:$10000;p:0;crc:$6619333a),(n:'873-s03.k15';l:$10000;p:$10000;crc:$2aec2699),
        (n:'873-f01.f8';l:$8000;p:0;crc:$ea35ffa3),
        (n:'873c06a.f6';l:$10000;p:0;crc:$0e340b67),(n:'873c06c.f5';l:$10000;p:1;crc:$ef0e72cd),
        (n:'873c07a.f4';l:$10000;p:2;crc:$a8aab84f),(n:'873c07c.f3';l:$10000;p:3;crc:$2521009a),
        (n:'873c06b.e6';l:$10000;p:$40000;crc:$97ad202e),(n:'873c06d.e5';l:$10000;p:$40001;crc:$8393d42e),
        (n:'873c07b.e4';l:$10000;p:$40002;crc:$12a2b8ba),(n:'873c07d.e3';l:$10000;p:$40003;crc:$fae9f965),
        (n:'873c04a.f11';l:$10000;p:0;crc:$f7740bf3),(n:'873c04c.f10';l:$10000;p:1;crc:$5dacbd2b),
        (n:'873c05a.f9';l:$10000;p:2;crc:$d73e107d),(n:'873c05c.f8';l:$10000;p:3;crc:$59903200),
        (n:'873c04b.e11';l:$10000;p:$40000;crc:$9ac581da),(n:'873c04d.e10';l:$10000;p:$40001;crc:$44a4668c),
        (n:'873c05b.e9';l:$10000;p:$40002;crc:$81059b99),(n:'873c05d.e8';l:$10000;p:$40003;crc:$7fa3d7df),());
        simpsons:array[0..14] of tipo_roms=(
        (n:'072-g02.16c';l:$20000;p:0;crc:$580ce1d6),(n:'072-p01.17c';l:$20000;p:$20000;crc:$07ceeaea),
        (n:'072-013.13c';l:$20000;p:$40000;crc:$8781105a),(n:'072-012.15c';l:$20000;p:$60000;crc:$244f9289),
        (n:'072-g03.6g';l:$20000;p:0;crc:$76c1850c),(n:'072-b07.18h';l:$80000;p:0;crc:$ba1ec910),
        (n:'072-b06.16h';l:$80000;p:2;crc:$cf2bbcab),(n:'072-b08.3n';l:$100000;p:0;crc:$7de500ad),
        (n:'072-b09.8n';l:$100000;p:2;crc:$aa085093),(n:'072-b10.12n';l:$100000;p:4;crc:$577dbd53),
        (n:'072-b11.16l';l:$100000;p:6;crc:$55fab05d),(n:'072-d05.1f';l:$100000;p:0;crc:$1397a73b),
        (n:'072-d04.1d';l:$40000;p:2;crc:$78778013),(n:'simpsons2p.12c.nv';l:$80;p:0;crc:$fbac4e30),());
        trackfield:array[0..17] of tipo_roms=(
        (n:'a01_e01.bin';l:$2000;p:$6000;crc:$2882f6d4),(n:'a02_e02.bin';l:$2000;p:$8000;crc:$1743b5ee),
        (n:'a03_k03.bin';l:$2000;p:$a000;crc:$6c0d1ee9),(n:'a04_e04.bin';l:$2000;p:$c000;crc:$21d6c448),
        (n:'a05_e05.bin';l:$2000;p:$e000;crc:$f08c7b7e),(n:'h16_e12.bin';l:$2000;p:0;crc:$50075768),
        (n:'h15_e11.bin';l:$2000;p:$2000;crc:$dda9e29f),(n:'h14_e10.bin';l:$2000;p:$4000;crc:$c2166a5c),
        (n:'c11_d06.bin';l:$2000;p:0;crc:$82e2185a),(n:'c12_d07.bin';l:$2000;p:$2000;crc:$800ff1f1),
        (n:'c13_d08.bin';l:$2000;p:$4000;crc:$d9faf183),(n:'c14_d09.bin';l:$2000;p:$6000;crc:$5886c802),
        (n:'361b16.f1';l:$20;p:$0;crc:$d55f30b5),(n:'361b17.b16';l:$100;p:$20;crc:$d2ba4d32),
        (n:'361b18.e15';l:$100;p:$120;crc:$053e5861),(n:'c9_d15.bin';l:$2000;p:$0;crc:$f546a56b),
        (n:'c2_d13.bin';l:$2000;p:$0;crc:$95bf79b6),());
        hypersports:array[0..24] of tipo_roms=(
        (n:'c01';l:$2000;p:$4000;crc:$0c720eeb),(n:'c02';l:$2000;p:$6000;crc:$560258e0),
        (n:'c03';l:$2000;p:$8000;crc:$9b01c7e6),(n:'c04';l:$2000;p:$a000;crc:$10d7e9a2),
        (n:'c05';l:$2000;p:$c000;crc:$b105a8cd),(n:'c06';l:$2000;p:$e000;crc:$1a34a849),
        (n:'c26';l:$2000;p:0;crc:$a6897eac),(n:'c24';l:$2000;p:$2000;crc:$5fb230c0),
        (n:'c22';l:$2000;p:$4000;crc:$ed9271a0),(n:'c20';l:$2000;p:$6000;crc:$183f4324),
        (n:'c14';l:$2000;p:0;crc:$c72d63be),(n:'c13';l:$2000;p:$2000;crc:$76565608),
        (n:'c12';l:$2000;p:$4000;crc:$74d2cc69),(n:'c11';l:$2000;p:$6000;crc:$66cbcb4d),
        (n:'c18';l:$2000;p:$8000;crc:$ed25e669),(n:'c17';l:$2000;p:$a000;crc:$b145b39f),
        (n:'c16';l:$2000;p:$c000;crc:$d7ff9f2b),(n:'c15';l:$2000;p:$e000;crc:$f3d454e6),
        (n:'c03_c27.bin';l:$20;p:$0;crc:$bc8a5956),(n:'j12_c28.bin';l:$100;p:$20;crc:$2c891d59),
        (n:'a09_c29.bin';l:$100;p:$120;crc:$811a3f3f),(n:'c08';l:$2000;p:$0;crc:$e8f8ea78),
        (n:'c10';l:$2000;p:$0;crc:$3dc1a6ff),(n:'c09';l:$2000;p:$2000;crc:$9b525c3e),());
        megazone:array[0..16] of tipo_roms=(
        (n:'319_l07.11h';l:$2000;p:$6000;crc:$73b616ca),(n:'319_l06.9h';l:$2000;p:$8000;crc:$0ced03f9),
        (n:'319_l05.8h';l:$2000;p:$a000;crc:$9dc3b5a1),(n:'319_l04.7h';l:$2000;p:$c000;crc:$785b983d),
        (n:'319_l03.6h';l:$2000;p:$e000;crc:$a5318686),(n:'319e02.6d';l:$2000;p:$0;crc:$d5d45edb),
        (n:'319e01.3a';l:$1000;p:$0;crc:$ed5725a0),(n:'319_g12.8c';l:$2000;p:0;crc:$07b8b24b),
        (n:'319_g13.10c';l:$2000;p:$2000;crc:$3d8f3743),(n:'319e11.3e';l:$2000;p:0;crc:$965a7ff6),
        (n:'319e09.2e';l:$2000;p:$2000;crc:$5eaa7f3e),(n:'319e10.3d';l:$2000;p:$4000;crc:$7bb1aeee),
        (n:'319e08.2d';l:$2000;p:$6000;crc:$6add71b1),(n:'319b18.a16';l:$20;p:$0;crc:$23cb02af),
        (n:'319b16.c6';l:$100;p:$20;crc:$5748e933),(n:'319b17.a11';l:$100;p:$120;crc:$1fbfce73),());
        spacefb:array[0..13] of tipo_roms=(
        (n:'tst-c-u.5e';l:$800;p:0;crc:$79c3527e),(n:'tst-c-u.5f';l:$800;p:$800;crc:$c0973965),
        (n:'tst-c-u.5h';l:$800;p:$1000;crc:$02c60ec5),(n:'tst-c-u.5i';l:$800;p:$1800;crc:$76fd18c7),
        (n:'tst-c-u.5j';l:$800;p:$2000;crc:$df52c97c),(n:'tst-c-u.5k';l:$800;p:$2800;crc:$1713300c),
        (n:'tst-c-u.5m';l:$800;p:$3000;crc:$6286f534),(n:'tst-c-u.5n';l:$800;p:$3800;crc:$1c9f91ee),
        (n:'tst-v-a.5k';l:$800;p:0;crc:$236e1ff7),(n:'tst-v-a.6k';l:$800;p:$800;crc:$bf901a4e),
        (n:'4i.vid';l:$100;p:0;crc:$528e8533),(n:'ic20.snd';l:$400;p:0;crc:$1c8670b3),
        (n:'mb7051.3n';l:$20;p:0;crc:$465d07af),());
        //ajax
        ajax:array[0..43] of tipo_roms=(
        (n:'770_m01.n11';l:$10000;p:0;crc:$4a64e53a),(n:'770_l02.n12';l:$10000;p:$10000;crc:$ad7d592b),
        (n:'770_l05.i16';l:$8000;p:0;crc:$ed64fbb2),(n:'770_f04.g16';l:$10000;p:$8000;crc:$e0e4ec9c),
        (n:'770_h03.f16';l:$8000;p:0;crc:$2ffd2afc),
        (n:'770c13-a.f3';l:$10000;p:0;crc:$4ef6fff2),(n:'770c13-c.f4';l:$10000;p:1;crc:$97ffbab6),
        (n:'770c12-a.f5';l:$10000;p:2;crc:$6c0ade68),(n:'770c12-c.f6';l:$10000;p:3;crc:$61fc39cc),
        (n:'770c13-b.e3';l:$10000;p:$40000;crc:$86fdd706),(n:'770c13-d.e4';l:$10000;p:$40001;crc:$7d7acb2d),
        (n:'770c12-b.e5';l:$10000;p:$40002;crc:$5f221cc6),(n:'770c12-d.e6';l:$10000;p:$40003;crc:$f1edb2f4),
        (n:'770c09-a.f8';l:$10000;p:0;crc:$76690fb8),(n:'770c09-e.f9';l:$10000;p:1;crc:$17b482c9),
        (n:'770c08-a.f10';l:$10000;p:2;crc:$efd29a56),(n:'770c08-e.f11';l:$10000;p:3;crc:$6d43afde),
        (n:'770c09-b.e8';l:$10000;p:$40000;crc:$cd1709d1),(n:'770c09-f.e9';l:$10000;p:$40001;crc:$cba4b47e),
        (n:'770c08-b.e10';l:$10000;p:$40002;crc:$f3374014),(n:'770c08-f.e11';l:$10000;p:$40003;crc:$f5ba59aa),
        (n:'770c09-c.d8';l:$10000;p:$80000;crc:$bfd080b8),(n:'770c09-g.d9';l:$10000;p:$80001;crc:$77d58ea0),
        (n:'770c08-c.d10';l:$10000;p:$80002;crc:$28e7088f),(n:'770c08-g.d11';l:$10000;p:$80003;crc:$17da8f6d),
        (n:'770c09-d.c8';l:$10000;p:$c0000;crc:$6f955600),(n:'770c09-h.c9';l:$10000;p:$c0001;crc:$494a9090),
        (n:'770c08-d.c10';l:$10000;p:$c0002;crc:$91591777),(n:'770c08-h.c11';l:$10000;p:$c0003;crc:$d97d4b15),
        (n:'770c06.f4';l:$40000;p:0;crc:$d0c592ee),(n:'770c07.h4';l:$40000;p:$40000;crc:$0b399fb1),
        (n:'770c10-a.a7';l:$10000;p:0;crc:$e45ec094),(n:'770c10-b.a6';l:$10000;p:$10000;crc:$349db7d3),
        (n:'770c10-c.a5';l:$10000;p:$20000;crc:$71cb1f05),(n:'770c10-d.a4';l:$10000;p:$30000;crc:$e8ab1844),
        (n:'770c11-a.c6';l:$10000;p:0;crc:$8cccd9e0),(n:'770c11-b.c5';l:$10000;p:$10000;crc:$0af2fedd),
        (n:'770c11-c.c4';l:$10000;p:$20000;crc:$7471f24a),(n:'770c11-d.c3';l:$10000;p:$30000;crc:$a58be323),
        (n:'770c11-e.b7';l:$10000;p:$40000;crc:$dd553541),(n:'770c11-f.b6';l:$10000;p:$50000;crc:$3f78bd0f),
        (n:'770c11-g.b5';l:$10000;p:$60000;crc:$078c51b2),(n:'770c11-h.b4';l:$10000;p:$70000;crc:$7300c2e1),());
        xevious:array[0..27] of tipo_roms=(
        (n:'xvi_1.3p';l:$1000;p:0;crc:$09964dda),(n:'xvi_2.3m';l:$1000;p:$1000;crc:$60ecce84),
        (n:'xvi_3.2m';l:$1000;p:$2000;crc:$79754b7d),(n:'xvi_4.2l';l:$1000;p:$3000;crc:$c7d4bbf0),
        (n:'xvi_5.3f';l:$1000;p:$0;crc:$c85b703f),(n:'xvi_6.3j';l:$1000;p:$1000;crc:$e18cdaad),
        (n:'xvi_7.2c';l:$1000;p:0;crc:$dd35cf1c),(n:'xvi_12.3b';l:$1000;p:0;crc:$088c8b26),
        (n:'xvi-8.6a';l:$100;p:0;crc:$5cc2727f),(n:'xvi-9.6d';l:$100;p:$100;crc:$5c8796cc),
        (n:'xvi-10.6e';l:$100;p:$200;crc:$3cb60975),(n:'xvi-7.4h';l:$200;p:$300;crc:$22d98032),
        (n:'xvi-6.4f';l:$200;p:$500;crc:$3a7599f0),(n:'xvi-4.3l';l:$200;p:$700;crc:$fd8b9d91),
        (n:'xvi-5.3m';l:$200;p:$900;crc:$bf906d82),(n:'xvi-2.7n';l:$100;p:0;crc:$550f06bc),
        (n:'xvi_15.4m';l:$2000;p:0;crc:$dc2c0ecb),(n:'xvi_17.4p';l:$2000;p:$2000;crc:$dfb587ce),
        (n:'xvi_16.4n';l:$1000;p:$4000;crc:$605ca889),(n:'xvi_18.4r';l:$2000;p:$5000;crc:$02417d19),
        (n:'xvi_13.3c';l:$1000;p:$0;crc:$de60ba25),(n:'xvi_14.3d';l:$1000;p:$1000;crc:$535cdbbc),
        (n:'xvi_9.2a';l:$1000;p:0;crc:$57ed9879),(n:'xvi_10.2b';l:$2000;p:$1000;crc:$ae3ba9e5),
        (n:'xvi_11.2c';l:$1000;p:$3000;crc:$31e244dd),(n:'50xx.bin';l:$800;p:0;crc:$a0acbaf7),
        (n:'54xx.bin';l:$400;p:0;crc:$ee7357e0),());
        //The Combatribes
        ctribe:array[0..18] of tipo_roms=(
        (n:'28a16-2.ic26';l:$20000;p:1;crc:$c46b2e63),(n:'28a15-2.ic25';l:$20000;p:$0;crc:$3221c755),
        (n:'28j17-0.104';l:$10000;p:$40001;crc:$8c2c6dbd),(n:'28a10-0.ic89';l:$8000;p:0;crc:$4346de13),
        (n:'28j9-0.ic83';l:$20000;p:0;crc:$f92a7f4a),(n:'28j8-0.ic82';l:$20000;p:$20000;crc:$1a3a0b39),
        (n:'28j3-0.ic77';l:$80000;p:0;crc:$1ac2a461),(n:'28a14-0.ic60';l:$10000;p:$80000;crc:$972faddb),
        (n:'28j2-0.ic78';l:$80000;p:$100000;crc:$8c796707),(n:'28a13-0.ic61';l:$10000;p:$180000;crc:$eb3ab374),
        (n:'28j1-0.ic97';l:$80000;p:$200000;crc:$1c9badbd),(n:'28a12-0.ic85';l:$10000;p:$280000;crc:$c602ac97),
        (n:'28j0-0.ic98';l:$80000;p:$300000;crc:$ba73c49e),(n:'28a11-0.ic86';l:$10000;p:$380000;crc:$4da1d8e5),
        (n:'28j7-0.ic11';l:$40000;p:0;crc:$a8b773f1),(n:'28j6-0.ic13';l:$40000;p:$1;crc:$617530fc),
        (n:'28j5-0.ic12';l:$40000;p:$80000;crc:$cef0a821),(n:'28j4-0.ic14';l:$40000;p:$80001;crc:$b84fda09),());
        llander:array[0..7] of tipo_roms=(
        (n:'034572-02.f1';l:$800;p:$6000;crc:$b8763eea),(n:'034571-02.de1';l:$800;p:$6800;crc:$77da4b2f),
        (n:'034570-01.c1';l:$800;p:$7000;crc:$2724e591),(n:'034569-02.b1';l:$800;p:$7800;crc:$72837a4e),
        (n:'034599-01.r3';l:$800;p:$4800;crc:$355a9371),(n:'034598-01.np3';l:$800;p:$5000;crc:$9c4ffa68),
        (n:'034597-01.m3';l:$800;p:$5800;crc:$503f992e),());
        crush:array[0..9] of tipo_roms=(
        (n:'crushkrl.6e';l:$1000;p:0;crc:$a8dd8f54),(n:'crushkrl.6f';l:$1000;p:$1000;crc:$91387299),
        (n:'crushkrl.6h';l:$1000;p:$2000;crc:$d4455f27),(n:'crushkrl.6j';l:$1000;p:$3000;crc:$d59fc251),
        (n:'maketrax.5e';l:$1000;p:0;crc:$91bad2da),(n:'maketrax.5f';l:$1000;p:0;crc:$aea79f55),
        (n:'82s123.7f';l:$20;p:0;crc:$2fc650bd),(n:'2s140.4a';l:$100;p:$20;crc:$63efb927),
        (n:'82s126.1m';l:$100;p:0;crc:$a9cc86bf),());
        vendetta:array[0..10] of tipo_roms=(
        (n:'081u01.17c';l:$40000;p:0;crc:$b4d9ade5),(n:'081b02';l:$10000;p:0;crc:$4c604d9b),
        (n:'081a09';l:$80000;p:0;crc:$b4c777a9),(n:'081a08';l:$80000;p:2;crc:$272ac8d9),
        (n:'081a04';l:$100000;p:0;crc:$464b9aa4),(n:'081a05';l:$100000;p:2;crc:$4e173759),
        (n:'081a06';l:$100000;p:4;crc:$e9fe6d80),(n:'081a07';l:$100000;p:6;crc:$8a22b29a),
        (n:'081a03';l:$100000;p:0;crc:$14b6baea),(n:'vendetta.nv';l:$80;p:0;crc:$fbac4e30),());
        gauntlet2p:array[0..20] of tipo_roms=(
        (n:'136041-507.9a';l:$8000;p:0;crc:$8784133f),(n:'136041-508.9b';l:$8000;p:$1;crc:$2843bde3),
        (n:'136037-205.10a';l:$4000;p:$38000;crc:$6d99ed51),(n:'136037-206.10b';l:$4000;p:$38001;crc:$545ead91),
        (n:'136041-609.7a';l:$8000;p:$40000;crc:$5b4ee415),(n:'136041-610.7b';l:$8000;p:$40001;crc:$41f5c9e2),
        (n:'136037-120.16r';l:$4000;p:$4000;crc:$6ee7f3cc),(n:'136037-119.16s';l:$8000;p:$8000;crc:$fa19861f),
        (n:'136037-111.1a';l:$8000;p:0;crc:$91700f33),(n:'136037-112.1b';l:$8000;p:$8000;crc:$869330be),
        (n:'136037-113.1l';l:$8000;p:$10000;crc:$d497d0a8),(n:'136037-114.1mn';l:$8000;p:$18000;crc:$29ef9882),
        (n:'136037-115.2a';l:$8000;p:$20000;crc:$9510b898),(n:'136037-116.2b';l:$8000;p:$28000;crc:$11e0ac5b),
        (n:'136037-117.2l';l:$8000;p:$30000;crc:$29a5db41),(n:'136037-118.2mn';l:$8000;p:$38000;crc:$8bf3b263),
        (n:'74s472-136037-101.7u';l:$200;p:0;crc:$2964f76f),(n:'74s472-136037-102.5l';l:$200;p:$200;crc:$4d4fec6c),
        (n:'136037-104.6p';l:$4000;p:0;crc:$6c276a1d),(n:'74s287-136037-103.4r';l:$100;p:$400;crc:$6c5ccf08),());
        sauro:array[0..14] of tipo_roms=(
        (n:'sauro-2.bin';l:$8000;p:0;crc:$19f8de25),(n:'sauro-1.bin';l:$8000;p:$8000;crc:$0f8b876f),
        (n:'sauro-3.bin';l:$8000;p:0;crc:$0d501e1b),(n:'82s137-3.bin';l:$400;p:0;crc:$d52c4cd0),
        (n:'82s137-2.bin';l:$400;p:$400;crc:$c3e96d5d),(n:'82s137-1.bin';l:$400;p:$800;crc:$bdfcf00c),
        (n:'sauro-6.bin';l:$8000;p:0;crc:$4b77cb0f),(n:'sauro-7.bin';l:$8000;p:$8000;crc:$187da060),
        (n:'sauro-4.bin';l:$8000;p:$0;crc:$9b617cda),(n:'sauro-5.bin';l:$8000;p:$8000;crc:$a6e2640d),
        (n:'sauro-8.bin';l:$8000;p:$0;crc:$e08b5d5e),(n:'sauro-9.bin';l:$8000;p:$8000;crc:$7c707195),
        (n:'sauro-10.bin';l:$8000;p:$10000;crc:$c93380d1),(n:'sauro-11.bin';l:$8000;p:$18000;crc:$f47982a8),());
        cclimber:array[0..16] of tipo_roms=(
        (n:'cc11';l:$1000;p:0;crc:$217ec4ff),(n:'cc10';l:$1000;p:$1000;crc:$b3c26cef),
        (n:'cc09';l:$1000;p:$2000;crc:$6db0879c),(n:'cc08';l:$1000;p:$3000;crc:$f48c5fe3),
        (n:'cc07';l:$1000;p:$4000;crc:$3e873baf),(n:'cclimber.pr1';l:$20;p:0;crc:$751c3325),
        (n:'cclimber.pr2';l:$20;p:$20;crc:$ab1940fa),(n:'cclimber.pr3';l:$20;p:$40;crc:$71317756),
        (n:'cc06';l:$800;p:0;crc:$481b64cc),(n:'cc05';l:$800;p:$1000;crc:$2c33b760),
        (n:'cc04';l:$800;p:$2000;crc:$332347cb),(n:'cc03';l:$800;p:$3000;crc:$4e4b3658),
        (n:'cc02';l:$800;p:$0;crc:$14f3ecc9),(n:'cc01';l:$800;p:$800;crc:$21c0f9fb),
        (n:'cc13';l:$1000;p:$0;crc:$e0042f75),(n:'cc12';l:$1000;p:$1000;crc:$5da13aaa),());
        retofinv:array[0..20] of tipo_roms=(
        (n:'a37__03.ic70';l:$2000;p:$0;crc:$eae7459d),(n:'a37__02.ic71';l:$2000;p:$2000;crc:$72895e37),
        (n:'a37__01.ic72';l:$2000;p:$4000;crc:$505dd20b),(n:'a37__04.ic62';l:$2000;p:$0;crc:$d2899cc1),
        (n:'a37__05.ic17';l:$2000;p:$0;crc:$9025abea),(n:'a37__09.ic37';l:$800;p:$0;crc:$6a6d008d),
        (n:'a37__16.gfxboard.ic61';l:$2000;p:$0;crc:$4e3f501c),(n:'a37__14.gfxboard.ic55';l:$2000;p:0;crc:$ef7f8651),
        (n:'a37__15.gfxboard.ic56';l:$2000;p:$2000;crc:$03b40905),(n:'a37__10.gfxboard.ic8';l:$2000;p:$0;crc:$6afdeec8),
        (n:'a37__11.gfxboard.ic9';l:$2000;p:$2000;crc:$d3dc9da3),(n:'a37__12.gfxboard.ic10';l:$2000;p:$4000;crc:$d10b2eed),
        (n:'a37__13.gfxboard.ic11';l:$2000;p:$6000;crc:$00ca6b3d),(n:'a37-06.ic13';l:$100;p:$0;crc:$e9643b8b),
        (n:'a37-07.ic4';l:$100;p:$100;crc:$e8f34e11),(n:'a37-08.ic3';l:$100;p:$200;crc:$50030af0),
        (n:'a37-17.gfxboard.ic36';l:$400;p:$0;crc:$c63cf10e),(n:'a37-18.gfxboard.ic37';l:$400;p:$800;crc:$6db07bd1),
        (n:'a37-19.gfxboard.ic83';l:$400;p:$400;crc:$a92aea27),(n:'a37-20.gfxboard.ic84';l:$400;p:$c00;crc:$77a7aaf6),());
        tetris_atari:array[0..2] of tipo_roms=((n:'136066-1100.45f';l:$10000;p:$0;crc:$2acbdb09),
        (n:'136066-1101.35a';l:$10000;p:$0;crc:$84a1939f),());
        ikari:array[0..20] of tipo_roms=(
        (n:'1.rom';l:$10000;p:0;crc:$52a8b2dd),(n:'2.rom';l:$10000;p:0;crc:$45364d55),
        (n:'3.rom';l:$10000;p:0;crc:$56a26699),(n:'7.rom';l:$4000;p:0;crc:$a7eb4917),
        (n:'17.rom';l:$8000;p:0;crc:$e0dba976),(n:'18.rom';l:$8000;p:$8000;crc:$24947d5f),
        (n:'19.rom';l:$8000;p:$10000;crc:$9ee59e91),(n:'20.rom';l:$8000;p:$18000;crc:$5da7ec1a),
        (n:'8.rom';l:$8000;p:0;crc:$9827c14a),(n:'9.rom';l:$8000;p:$8000;crc:$545c790c),
        (n:'10.rom';l:$8000;p:$10000;crc:$ec9ba07e),(n:'11.rom';l:$8000;p:0;crc:$5c75ea8f),
        (n:'14.rom';l:$8000;p:$8000;crc:$3293fde4),(n:'12.rom';l:$8000;p:$10000;crc:$95138498),
        (n:'15.rom';l:$8000;p:$18000;crc:$65a61c99),(n:'13.rom';l:$8000;p:$20000;crc:$315383d7),
        (n:'16.rom';l:$8000;p:$28000;crc:$e9b03e07),(n:'7122er.prm';l:$400;p:0;crc:$b9bf2c2c),
        (n:'7122eg.prm';l:$400;p:$800;crc:$0703a770),(n:'7122eb.prm';l:$400;p:$1000;crc:$0a11cdde),());
        athena:array[0..14] of tipo_roms=(
        (n:'up02_p4.rom';l:$4000;p:0;crc:$900a113c),(n:'up02_m4.rom';l:$8000;p:$4000;crc:$61c69474),
        (n:'up02_p8.rom';l:$4000;p:0;crc:$df50af7e),(n:'up02_m8.rom';l:$8000;p:$4000;crc:$f3c933df),
        (n:'up02_g6.rom';l:$4000;p:0;crc:$42dbe029),(n:'up02_k6.rom';l:$8000;p:$4000;crc:$596f1c8a),
        (n:'up01_d2.rom';l:$4000;p:0;crc:$18b4bcca),(n:'up01_b2.rom';l:$8000;p:0;crc:$f269c0eb),
        (n:'up01_p2.rom';l:$8000;p:0;crc:$c63a871f),(n:'up01_s2.rom';l:$8000;p:$8000;crc:$760568d8),
        (n:'up01_t2.rom';l:$8000;p:$10000;crc:$57b35c73),(n:'up02_c2.rom';l:$400;p:0;crc:$294279ae),
        (n:'up02_b1.rom';l:$400;p:$400;crc:$d25c9099),(n:'up02_c1.rom';l:$400;p:$800;crc:$a4a4e7dc),());
        tnk3:array[0..17] of tipo_roms=(
        (n:'tnk3-p1.bin';l:$4000;p:0;crc:$0d2a8ca9),(n:'tnk3-p2.bin';l:$4000;p:$4000;crc:$0ae0a483),
        (n:'tnk3-p3.bin';l:$4000;p:$8000;crc:$d16dd4db),(n:'tnk3-p4.bin';l:$4000;p:0;crc:$01b45a90),
        (n:'tnk3-p5.bin';l:$4000;p:$4000;crc:$60db6667),(n:'tnk3-p6.bin';l:$4000;p:$8000;crc:$4761fde7),
        (n:'tnk3-p10.bin';l:$4000;p:0;crc:$7bf0a517),(n:'tnk3-p11.bin';l:$4000;p:$4000;crc:$0569ce27),
        (n:'tnk3-p14.bin';l:$2000;p:0;crc:$1fd18c43),(n:'tnk3-p12.bin';l:$4000;p:0;crc:$ff495a16),
        (n:'tnk3-p13.bin';l:$4000;p:$4000;crc:$f8344843),(n:'tnk3-p7.bin';l:$4000;p:0;crc:$06b92c88),
        (n:'tnk3-p8.bin';l:$4000;p:$4000;crc:$63d0e2eb),(n:'tnk3-p9.bin';l:$4000;p:$8000;crc:$872e3fac),
        (n:'7122.2';l:$400;p:0;crc:$34c06bc6),(n:'7122.1';l:$400;p:$400;crc:$6d0ac66a),
        (n:'7122.0';l:$400;p:$800;crc:$4662b4c8),());
        peterpak:array[0..27] of tipo_roms=(
        (n:'136032.205.l13';l:$4000;p:$0;crc:$88d0be26),(n:'136032.206.l12';l:$4000;p:$1;crc:$3c79ef05),
        (n:'136032.104.f5';l:$2000;p:0;crc:$7a29dc07),(n:'136028.142';l:$4000;p:$0;crc:$4f9fc020),
        (n:'136028.143';l:$4000;p:$1;crc:$9fb257cc),(n:'136028.144';l:$4000;p:$8000;crc:$50267619),
        (n:'136028.145';l:$4000;p:$8001;crc:$7b6a5004),(n:'136028.146';l:$4000;p:$10000;crc:$4183a67a),
        (n:'136028.147';l:$4000;p:$10001;crc:$14e2d97b),(n:'136028.148';l:$4000;p:$20000;crc:$230e8ba9),
        (n:'136028.149';l:$4000;p:$20001;crc:$0ff0c13a),
        (n:'136028.101';l:$4000;p:$8000;crc:$ff712aa2),(n:'136028.102';l:$4000;p:$c000;crc:$89ea21a1),
        (n:'136028.138';l:$8000;p:0;crc:$53eaa018),(n:'136028.139';l:$8000;p:$10000;crc:$354a19cb),
        (n:'136028.140';l:$8000;p:$20000;crc:$8d2c4717),(n:'136028.141';l:$8000;p:$30000;crc:$bf59ea19),
        (n:'136028.150';l:$8000;p:$80000;crc:$83362483),(n:'136028.151';l:$8000;p:$90000;crc:$6e95094e),
        (n:'136028.152';l:$8000;p:$a0000;crc:$9553f084),(n:'136028.153';l:$8000;p:$b0000;crc:$c2a9b028),
        (n:'136028.105';l:$4000;p:$104000;crc:$ac9a5a44),(n:'136028.108';l:$4000;p:$114000;crc:$51941e64),
        (n:'136028.111';l:$4000;p:$124000;crc:$246599f3),(n:'136028.114';l:$4000;p:$134000;crc:$918a5082),
        (n:'136028.136';l:$200;p:0;crc:$861cfa36),(n:'136028.137';l:$200;p:$200;crc:$8507e5ea),());
        gaunt2:array[0..30] of tipo_roms=(
        (n:'136037-1307.9a';l:$8000;p:0;crc:$46fe8743),(n:'136037-1308.9b';l:$8000;p:$1;crc:$276e15c4),
        (n:'136043-1105.10a';l:$4000;p:$38000;crc:$45dfda47),(n:'136043-1106.10b';l:$4000;p:$38001;crc:$343c029c),
        (n:'136044-2109.7a';l:$8000;p:$40000;crc:$1102ab96),(n:'136044-2110.7b';l:$8000;p:$40001;crc:$d2203a2b),
        (n:'136044-2121.6a';l:$8000;p:$50000;crc:$753982d7),(n:'136044-2122.6b';l:$8000;p:$50001;crc:$879149ea),
        (n:'136043-1120.16r';l:$4000;p:$4000;crc:$5c731006),(n:'136043-1119.16s';l:$8000;p:$8000;crc:$dc3591e7),
        (n:'136043-1111.1a';l:$8000;p:0;crc:$09df6e23),(n:'136037-112.1b';l:$8000;p:$8000;crc:$869330be),
        (n:'136043-1123.1c';l:$4000;p:$10000;crc:$e4c98f01),(n:'136043-1123.1c';l:$4000;p:$14000;crc:$e4c98f01),
        (n:'136043-1113.1l';l:$8000;p:$18000;crc:$33cb476e),(n:'136037-114.1mn';l:$8000;p:$20000;crc:$29ef9882),
        (n:'136043-1124.1p';l:$4000;p:$28000;crc:$c4857879),(n:'136043-1124.1p';l:$4000;p:$2c000;crc:$c4857879),
        (n:'136043-1115.2a';l:$8000;p:$30000;crc:$f71e2503),(n:'136037-116.2b';l:$8000;p:$38000;crc:$11e0ac5b),
        (n:'136043-1125.2c';l:$4000;p:$40000;crc:$d9c2c2d1),(n:'136043-1125.2c';l:$4000;p:$44000;crc:$d9c2c2d1),
        (n:'136043-1117.2l';l:$8000;p:$48000;crc:$9e30b2e9),(n:'136037-118.2mn';l:$8000;p:$50000;crc:$8bf3b263),
        (n:'136043-1126.2p';l:$4000;p:$58000;crc:$a32c732a),(n:'136043-1126.2p';l:$4000;p:$5c000;crc:$a32c732a),
        (n:'74s472-136037-101.7u';l:$200;p:0;crc:$2964f76f),(n:'74s472-136037-102.5l';l:$200;p:$200;crc:$4d4fec6c),
        (n:'82s129-136043-1103.4r';l:$100;p:$400;crc:$32ae1fa9),(n:'136043-1104.6p';l:$4000;p:0;crc:$bddc3dfc),());
        defender:array[0..12] of tipo_roms=(
        (n:'defend.1';l:$800;p:$0;crc:$c3e52d7e),(n:'defend.4';l:$800;p:$800;crc:$9a72348b),
        (n:'defend.2';l:$1000;p:$1000;crc:$89b75984),(n:'defend.3';l:$1000;p:$2000;crc:$94f51e9b),
        (n:'defend.9';l:$800;p:$3000;crc:$6870e8a5),(n:'defend.12';l:$800;p:$3800;crc:$f1f88938),
        (n:'defend.8';l:$800;p:$4000;crc:$b649e306),(n:'defend.11';l:$800;p:$4800;crc:$9deaf6d9),
        (n:'defend.7';l:$800;p:$5000;crc:$339e092e),(n:'defend.10';l:$800;p:$5800;crc:$a543b167),
        (n:'defend.6';l:$800;p:$9000;crc:$65f4efd1),(n:'defend.snd';l:$800;p:$f800;crc:$fefd5b48),());
        mayday:array[0..8] of tipo_roms=(
        (n:'mayday.c';l:$1000;p:$0;crc:$a1ff6e62),(n:'mayday.b';l:$1000;p:$1000;crc:$62183aea),
        (n:'mayday.a';l:$1000;p:$2000;crc:$5dcb113f),(n:'mayday.d';l:$1000;p:$3000;crc:$ea6a4ec8),
        (n:'mayday.e';l:$1000;p:$4000;crc:$0d797a3e),(n:'mayday.f';l:$1000;p:$5000;crc:$ee8bfcd6),
        (n:'mayday.g';l:$1000;p:$9000;crc:$d9c065e7),(n:'ic28-8.bin';l:$800;p:$f800;crc:$fefd5b48),());
        colony7:array[0..10] of tipo_roms=(
        (n:'cs03.bin';l:$1000;p:$0;crc:$7ee75ae5),(n:'cs02.bin';l:$1000;p:$1000;crc:$c60b08cb),
        (n:'cs01.bin';l:$1000;p:$2000;crc:$1bc97436),(n:'cs06.bin';l:$800;p:$3000;crc:$318b95af),
        (n:'cs04.bin';l:$800;p:$3800;crc:$d740faee),(n:'cs07.bin';l:$800;p:$4000;crc:$0b23638b),
        (n:'cs05.bin';l:$800;p:$4800;crc:$59e406a8),(n:'cs08.bin';l:$800;p:$5000;crc:$3bfde87a),
        (n:'cs08.bin';l:$800;p:$5800;crc:$3bfde87a),(n:'cs11.bin';l:$800;p:$f800;crc:$6032293c),());
        bosco:array[0..21] of tipo_roms=(
        (n:'bos3_1.3n';l:$1000;p:0;crc:$96021267),(n:'bos1_2.3m';l:$1000;p:$1000;crc:$2d8f3ebe),
        (n:'bos1_3.3l';l:$1000;p:$2000;crc:$c80ccfa5),(n:'bos1_4b.3k';l:$1000;p:$3000;crc:$a3f7f4ab),
        (n:'bos1_5c.3j';l:$1000;p:$0;crc:$a7c8e432),(n:'bos3_6.3h';l:$1000;p:$1000;crc:$4543cf82),
        (n:'bos1_7.3e';l:$1000;p:0;crc:$d45a4911),(n:'bos1_14.5d';l:$1000;p:0;crc:$a956d3c5),
        (n:'bos1_13.5e';l:$1000;p:0;crc:$e869219c),(n:'bos1-4.2r';l:$100;p:0;crc:$9b69b543),
        (n:'bos1-6.6b';l:$20;p:0;crc:$d2b96fb0),(n:'bos1-5.4m';l:$100;p:$20;crc:$4e15d59c),
        (n:'bos1-3.2d';l:$20;p:$120;crc:$b88d5ba9),(n:'bos1-7.7h';l:$20;p:$140;crc:$87d61353),
        (n:'bos1-1.1d';l:$100;p:$0;crc:$de2316c6),(n:'bos1-2.5c';l:$100;p:$100;crc:$77245b66),
        (n:'bos1_9.5n';l:$1000;p:$0;crc:$09acc978),(n:'bos1_10.5m';l:$1000;p:$1000;crc:$e571e959),
        (n:'bos1_11.5k';l:$1000;p:$2000;crc:$17ac9511),(n:'50xx.bin';l:$800;p:0;crc:$a0acbaf7),
        (n:'54xx.bin';l:$400;p:0;crc:$ee7357e0),());
        hangonjr:array[0..5] of tipo_roms=(
        (n:'epr-7257b.ic7';l:$8000;p:0;crc:$d63925a7),(n:'epr-7258.ic5';l:$8000;p:0;crc:$ee3caab3),
        (n:'epr-7259.ic4';l:$8000;p:$8000;crc:$d2ba9bc9),(n:'epr-7260.ic3';l:$8000;p:$10000;crc:$e14da070),
        (n:'epr-7261.ic2';l:$8000;p:$18000;crc:$3810cbf5),());
        slapshtr:array[0..5] of tipo_roms=(
        (n:'epr-7351.ic7';l:$8000;p:0;crc:$894adb04),(n:'epr-7352.ic5';l:$8000;p:$8000;crc:$61c938b6),
        (n:'epr-7353.ic4';l:$8000;p:$10000;crc:$8ee2951a),(n:'epr-7354.ic3';l:$8000;p:$18000;crc:$41482aa0),
        (n:'epr-7355.ic2';l:$8000;p:$20000;crc:$c67e1aef),());
        fantzn2:array[0..6] of tipo_roms=(
        (n:'epr-11416.ic7';l:$8000;p:0;crc:$76db7b7b),(n:'epr-11415.ic5';l:$10000;p:$8000;crc:$57b45681),
        (n:'epr-11413.ic3';l:$10000;p:$18000;crc:$a231dc85),(n:'epr-11414.ic4';l:$10000;p:$28000;crc:$6f7a9f5f),
        (n:'epr-11412.ic2';l:$10000;p:$38000;crc:$b14db5af),(n:'317-0057.key';l:$2000;p:0;crc:$ee43d0f0),());
        opaopa:array[0..6] of tipo_roms=(
        (n:'epr-11054.ic7';l:$8000;p:0;crc:$024b1244),(n:'epr-11053.ic5';l:$8000;p:$8000;crc:$6bc41d6e),
        (n:'epr-11052.ic4';l:$8000;p:$10000;crc:$395c1d0a),(n:'epr-11051.ic3';l:$8000;p:$18000;crc:$4ca132a2),
        (n:'epr-11050.ic2';l:$8000;p:$20000;crc:$a165e2ef),(n:'317-0042.key';l:$2000;p:0;crc:$d6312538),());
        tetrisse:array[0..3] of tipo_roms=(
        (n:'epr-12213.7';l:$8000;p:0;crc:$ef3c7a38),(n:'epr-12212.5';l:$8000;p:$8000;crc:$28b550bf),
        (n:'epr-12211.4';l:$8000;p:$10000;crc:$5aa114e9),());
        transfrm:array[0..5] of tipo_roms=(
        (n:'epr-7605.ic7';l:$8000;p:0;crc:$ccf1d123),(n:'epr-7347.ic5';l:$8000;p:$8000;crc:$df0f639f),
        (n:'epr-7348.ic4';l:$8000;p:$10000;crc:$0f38ea96),(n:'epr-7606.ic3';l:$8000;p:$18000;crc:$9d485df6),
        (n:'epr-7350.ic2';l:$8000;p:$20000;crc:$0052165d),());
        ridleofp:array[0..5] of tipo_roms=(
        (n:'epr-10426.bin';l:$8000;p:0;crc:$4404c7e7),(n:'epr-10425.bin';l:$8000;p:$8000;crc:$35964109),
        (n:'epr-10424.bin';l:$8000;p:$10000;crc:$fcda1dfa),(n:'epr-10423.bin';l:$8000;p:$18000;crc:$0b87244f),
        (n:'epr-10422.bin';l:$8000;p:$20000;crc:$14781e56),());
        route16:array[0..12] of tipo_roms=(
        (n:'stvg54.a0';l:$800;p:0;crc:$b8471cdc),(n:'stvg55.a1';l:$800;p:$800;crc:$3ec52fe5),
        (n:'stvg56.a2';l:$800;p:$1000;crc:$a8e92871),(n:'stvg57.a3';l:$800;p:$1800;crc:$a0fc9fc5),
        (n:'stvg58.a4';l:$800;p:$2000;crc:$cc95c02c),(n:'stvg59.a5';l:$800;p:$2800;crc:$a39ef648),
        (n:'stvg60.b0';l:$800;p:0;crc:$fef605f3),(n:'stvg61.b1';l:$800;p:$800;crc:$d0d6c189),
        (n:'stvg62.b2';l:$800;p:$1000;crc:$defc5797),(n:'stvg63.b3';l:$800;p:$1800;crc:$88d94a66),
        (n:'mb7052.59';l:$100;p:0;crc:$08793ef7),(n:'mb7052.61';l:$100;p:$100;crc:$08793ef7),());
        speakres:array[0..10] of tipo_roms=(
        (n:'speakres.1';l:$800;p:0;crc:$6026e4ea),(n:'speakres.2';l:$800;p:$800;crc:$93f0d4da),
        (n:'speakres.3';l:$800;p:$1000;crc:$a3874304),(n:'speakres.4';l:$800;p:$1800;crc:$f484be3a),
        (n:'speakres.5';l:$800;p:$2000;crc:$61b12a67),(n:'speakres.6  ';l:$800;p:$2800;crc:$220e0ab2),
        (n:'speakres.7';l:$800;p:0;crc:$d417be13),(n:'speakres.8';l:$800;p:$800;crc:$d417be13),
        (n:'im5623.f10';l:$100;p:0;crc:$08793ef7),(n:'im5623.f12';l:$100;p:$100;crc:$08793ef7),());
        gwarrior:array[0..7] of tipo_roms=(
        (n:'400-a01.fse';l:$100;p:$0;crc:$5827b1e8),(n:'400-a02.fse';l:$100;p:$100;crc:$2f44f970),
        (n:'400-a06.15l';l:$8000;p:0;crc:$b99d8cff),(n:'400-a04.10l';l:$8000;p:$1;crc:$d02c9552),
        (n:'400-e03.5l';l:$2000;p:0;crc:$a5a8e57d),(n:'578-a07.17l';l:$20000;p:$0;crc:$0aedacb5),
        (n:'578-a05.12l';l:$20000;p:$1;crc:$76240e2e),());
        salamander:array[0..7] of tipo_roms=(
        (n:'587-d02.18b';l:$10000;p:0;crc:$a42297f9),(n:'587-d05.18c';l:$10000;p:$1;crc:$f9130b0a),
        (n:'587-c03.17b';l:$20000;p:$40000;crc:$e5caf6e6),(n:'587-c06.17c';l:$20000;p:$40001;crc:$c2f567ea),
        (n:'587-d09.11j';l:$8000;p:0;crc:$5020972c),(n:'587-d08.8g';l:$4000;p:0;crc:$f9ac6b82),
        (n:'587-c01.10a';l:$20000;p:0;crc:$09fe0632),());
        badlands:array[0..14] of tipo_roms=(
        (n:'136074-1008.20f';l:$10000;p:0;crc:$a3da5774),(n:'136074-1006.27f';l:$10000;p:$1;crc:$aa03b4f3),
        (n:'136074-1009.17f';l:$10000;p:$20000;crc:$0e2e807f),(n:'136074-1007.24f';l:$10000;p:$20001;crc:$99a20c2c),
        (n:'136074-1018.9c';l:$10000;p:$0;crc:$a05fd146),(n:'136074-1012.4n';l:$10000;p:0;crc:$5d124c6c),
        (n:'136074-1013.2n';l:$10000;p:$10000;crc:$b1ec90d6),(n:'136074-1014.4s';l:$10000;p:$20000;crc:$248a6845),
        (n:'136074-1015.2s';l:$10000;p:$30000;crc:$792296d8),(n:'136074-1016.4u';l:$10000;p:$40000;crc:$878f7c66),
        (n:'136074-1017.2u';l:$10000;p:$50000;crc:$ad0071a3),(n:'136074-1010.14r';l:$10000;p:0;crc:$c15f629e),
        (n:'136074-1011.10r';l:$10000;p:$10000;crc:$fb0b6717),(n:'136074-1019.14t';l:$10000;p:$20000;crc:$0e26bff6),());
        indytemp:array[0..32] of tipo_roms=(
        (n:'136036.432';l:$8000;p:$0;crc:$d888cdf1),(n:'136036.431';l:$8000;p:$1;crc:$b7ac7431),
        (n:'136036.434';l:$8000;p:$10000;crc:$802495fd),(n:'136036.433';l:$8000;p:$10001;crc:$3a914e5c),
        (n:'136036.456';l:$4000;p:$20000;crc:$ec146b09),(n:'136036.457';l:$4000;p:$20001;crc:$6628de01),
        (n:'136036.358';l:$4000;p:$28000;crc:$d9351106),(n:'136036.359';l:$4000;p:$28001;crc:$e731caea),
        (n:'136036.153';l:$4000;p:$4000;crc:$95294641),(n:'136036.154';l:$4000;p:$8000;crc:$cbfc6adb),
        (n:'136036.155';l:$4000;p:$c000;crc:$4c8233ac),(n:'136036.135';l:$8000;p:0;crc:$ffa8749c),
        (n:'136036.139';l:$8000;p:$10000;crc:$b682bfca),(n:'136036.143';l:$8000;p:$20000;crc:$7697da26),
        (n:'136036.136';l:$8000;p:$80000;crc:$b2b403aa),(n:'136036.140';l:$8000;p:$90000;crc:$ec0c19ca),
        (n:'136036.144';l:$8000;p:$a0000;crc:$4407df98),(n:'136036.148';l:$8000;p:$b0000;crc:$70dce06d),
        (n:'136036.137';l:$8000;p:$100000;crc:$3f352547),(n:'136036.141';l:$8000;p:$110000;crc:$9cbdffd0),
        (n:'136036.145';l:$8000;p:$120000;crc:$e828e64b),(n:'136036.149';l:$8000;p:$130000;crc:$81503a23),
        (n:'136036.138';l:$8000;p:$180000;crc:$48c4d79d),(n:'136036.142';l:$8000;p:$190000;crc:$7faae75f),
        (n:'136036.146';l:$8000;p:$1a0000;crc:$8ae5a7b5),(n:'136036.150';l:$8000;p:$1b0000;crc:$a10c4bd9),
        (n:'136036.147';l:$8000;p:$30000;crc:$4e9d664c),(n:'136036.152';l:$200;p:0;crc:$4f96e57c),
        (n:'136036.151';l:$200;p:$200;crc:$7daf351f),(n:'136032.205.l13';l:$4000;p:$0;crc:$88d0be26),
        (n:'136032.206.l12';l:$4000;p:$1;crc:$3c79ef05),(n:'136032.104.f5';l:$2000;p:0;crc:$7a29dc07),());
        marble:array[0..30] of tipo_roms=(
        (n:'136033.623';l:$4000;p:$0;crc:$284ed2e9),(n:'136033.624';l:$4000;p:$1;crc:$d541b021),
        (n:'136033.625';l:$4000;p:$8000;crc:$563755c7),(n:'136033.626';l:$4000;p:$8001;crc:$860feeb3),
        (n:'136033.627';l:$4000;p:$10000;crc:$d1dbd439),(n:'136033.628';l:$4000;p:$10001;crc:$957d6801),
        (n:'136033.229';l:$4000;p:$18000;crc:$c81d5c14),(n:'136033.630';l:$4000;p:$18001;crc:$687a09f7),
        (n:'136033.107';l:$4000;p:$20000;crc:$f3b8745b),(n:'136033.108';l:$4000;p:$20001;crc:$e51eecaa),
        (n:'136033.421';l:$4000;p:$8000;crc:$78153dc3),(n:'136033.422';l:$4000;p:$c000;crc:$2e66300e),
        (n:'136033.137';l:$4000;p:0;crc:$7a45f5c1),(n:'136033.138';l:$4000;p:$4000;crc:$7e954a88),
        (n:'136033.139';l:$4000;p:$10000;crc:$1eb1bb5f),(n:'136033.140';l:$4000;p:$14000;crc:$8a82467b),
        (n:'136033.141';l:$4000;p:$20000;crc:$52448965),(n:'136033.142';l:$4000;p:$24000;crc:$b4a70e4f),
        (n:'136033.143';l:$4000;p:$30000;crc:$7156e449),(n:'136033.144';l:$4000;p:$34000;crc:$4c3e4c79),
        (n:'136033.145';l:$4000;p:$40000;crc:$9062be7f),(n:'136033.146';l:$4000;p:$44000;crc:$14566dca),
        (n:'136033.149';l:$4000;p:$84000;crc:$b6658f06),(n:'136033.151';l:$4000;p:$94000;crc:$84ee1c80),
        (n:'136033.153';l:$4000;p:$a4000;crc:$daa02926),(n:'136033.118';l:$200;p:0;crc:$2101b0ed),
        (n:'136033.119';l:$200;p:$200;crc:$19f6e767),(n:'136032.205.l13';l:$4000;p:$0;crc:$88d0be26),
        (n:'136032.206.l12';l:$4000;p:$1;crc:$3c79ef05),(n:'136032.104.f5';l:$2000;p:0;crc:$7a29dc07),());
        amazon:array[0..21] of tipo_roms=(
        (n:'11.4d';l:$8000;p:0;crc:$6c7f85c5),(n:'9.4b';l:$8000;p:$1;crc:$e1b7a989),
        (n:'12.6d';l:$8000;p:$10000;crc:$4de8a3ee),(n:'10.6b';l:$8000;p:$10001;crc:$d86bad81),
        (n:'1.15b';l:$4000;p:0;crc:$55a8b5e7),(n:'2.17b';l:$4000;p:$4000;crc:$427a7cca),
        (n:'3.18b';l:$4000;p:$8000;crc:$b8cceaf7),(n:'8.16g';l:$2000;p:0;crc:$0cec8644),
        (n:'13.15f';l:$8000;p:0;crc:$415ff4d9),(n:'14.17f';l:$8000;p:$8000;crc:$492b5c48),
        (n:'15.18f';l:$8000;p:$10000;crc:$b1ac0b9d),(n:'4.6e';l:$4000;p:0;crc:$f77ced7a),
        (n:'5.7e';l:$4000;p:$4000;crc:$16ef1465),(n:'6.6g';l:$4000;p:$8000;crc:$936ec941),
        (n:'7.7g';l:$4000;p:$c000;crc:$66dd718e),(n:'clr.10f';l:$100;p:0;crc:$6440b341),
        (n:'clr.11f';l:$100;p:$100;crc:$271e947f),(n:'clr.12f';l:$100;p:$200;crc:$7d38621b),
        (n:'2g';l:$100;p:$300;crc:$44ca16b9),(n:'4e';l:$100;p:$400;crc:$035f2c7b),
        (n:'16.18g';l:$2000;p:0;crc:$1d8d592b),());
        galivan:array[0..19] of tipo_roms=(
        (n:'1.1b';l:$8000;p:0;crc:$1e66b3f8),(n:'2.3b';l:$4000;p:$8000;crc:$a45964f1),
        (n:'gv3.4b';l:$4000;p:$c000;crc:$82f0c5e6),(n:'gv11.14b';l:$4000;p:0;crc:$05f1a0e3),
        (n:'gv12.15b';l:$8000;p:$4000;crc:$5b7a0d6d),(n:'gv4.13d';l:$4000;p:0;crc:$162490b4),
        (n:'gv7.14f';l:$8000;p:0;crc:$eaa1a0db),(n:'gv8.15f';l:$8000;p:$8000;crc:$f174a41e),
        (n:'gv9.17f';l:$8000;p:$10000;crc:$edc60f5d),(n:'gv10.19f';l:$8000;p:$18000;crc:$41f27fca),
        (n:'gv14.4f';l:$8000;p:0;crc:$03e2229f),(n:'gv13.1f';l:$8000;p:$8000;crc:$bca9e66b),
        (n:'gv6.19d';l:$4000;p:0;crc:$da38168b),(n:'gv5.17d';l:$4000;p:$4000;crc:$22492d2a),
        (n:'mb7114e.9f';l:$100;p:0;crc:$de782b3e),(n:'mb7114e.10f';l:$100;p:$100;crc:$0ae2a857),
        (n:'mb7114e.11f';l:$100;p:$200;crc:$7ba8b9d1),(n:'mb7114e.2d';l:$100;p:$300;crc:$75466109),
        (n:'mb7114e.7f';l:$100;p:$400;crc:$06538736),());
        dangar:array[0..19] of tipo_roms=(
        (n:'8.1b';l:$8000;p:0;crc:$fe4a3fd6),(n:'9.3b';l:$4000;p:$8000;crc:$809d280f),
        (n:'10.4b';l:$4000;p:$c000;crc:$99a3591b),(n:'13.b14';l:$4000;p:0;crc:$3e041873),
        (n:'14.b15';l:$8000;p:$4000;crc:$488e3463),(n:'5.13d';l:$4000;p:0;crc:$40cb378a),
        (n:'1.14f';l:$8000;p:0;crc:$d59ed1f1),(n:'2.15f';l:$8000;p:$8000;crc:$dfdb931c),
        (n:'3.17f';l:$8000;p:$10000;crc:$6954e8c3),(n:'4.19f';l:$8000;p:$18000;crc:$4af6a8bf),
        (n:'12.f4';l:$8000;p:0;crc:$55711884),(n:'11.f1';l:$8000;p:$8000;crc:$8cf11419),
        (n:'7.19d';l:$4000;p:0;crc:$6dba32cf),(n:'6.17d';l:$4000;p:$4000;crc:$6c899071),
        (n:'82s129.9f';l:$100;p:0;crc:$b29f6a07),(n:'82s129.10f';l:$100;p:$100;crc:$c6de5ecb),
        (n:'82s129.11f';l:$100;p:$200;crc:$a5bbd6dc),(n:'82s129.2d';l:$100;p:$300;crc:$a4ac95a5),
        (n:'82s129.7f';l:$100;p:$400;crc:$29bc6216),());
        lastduel:array[0..13] of tipo_roms=(
        (n:'ldu_06b.13k';l:$20000;p:0;crc:$0e71acaf),(n:'ldu_05b.12k';l:$20000;p:$1;crc:$47a85bea),
        (n:'ldu_04b.11k';l:$10000;p:$40000;crc:$aa4bf001),(n:'ldu_03b.9k';l:$10000;p:$40001;crc:$bbaac8ab),
        (n:'ld_02.16h';l:$10000;p:0;crc:$91834d0c),(n:'ld_01.12f';l:$8000;p:0;crc:$ad3c6f87),
        (n:'ld-09.12a';l:$20000;p:0;crc:$6efadb74),(n:'ld-10.17a';l:$20000;p:$1;crc:$b8d3b2e3),
        (n:'ld-11.12b';l:$20000;p:$2;crc:$49d4dbbd),(n:'ld-12.17b';l:$20000;p:$3;crc:$313e5338),
        (n:'ld-15.6p';l:$20000;p:1;crc:$d977a175),(n:'ld-13.6m';l:$20000;p:$0;crc:$bc25729f),
        (n:'ld-14.15n';l:$80000;p:0;crc:$d0653739),());
        madgear:array[0..18] of tipo_roms=(
        (n:'mg_04.8b';l:$20000;p:0;crc:$b112257d),(n:'mg_03.7b';l:$20000;p:$1;crc:$b2672465),
        (n:'mg_02.6b';l:$20000;p:$40000;crc:$9f5ebe16),(n:'mg_01.5b';l:$20000;p:$40001;crc:$1cea2af0),
        (n:'mg_05.14j';l:$10000;p:0;crc:$2fbfc945),(n:'mg_06.10k';l:$8000;p:0;crc:$382ee59b),
        (n:'mg_m11.rom0';l:$10000;p:$2;crc:$ee319a64),(n:'mg_m07.rom2';l:$10000;p:$40002;crc:$e5c0b211),
        (n:'mg_m12.rom1';l:$10000;p:$0;crc:$887ef120),(n:'mg_m08.rom3';l:$10000;p:$40000;crc:$59709aa3),
        (n:'mg_m13.rom0';l:$10000;p:$3;crc:$eae07db4),(n:'mg_m09.rom2';l:$10000;p:$40003;crc:$40ee83eb),
        (n:'mg_m14.rom1';l:$10000;p:$1;crc:$21e5424c),(n:'mg_m10.rom3';l:$10000;p:$40001;crc:$b64afb54),
        (n:'ls-12.7l';l:$40000;p:0;crc:$6c1b2c6c),(n:'ls-11.2l';l:$80000;p:0;crc:$6bf81c64),
        (n:'ls-06.10e';l:$20000;p:0;crc:$88d39a5b),(n:'ls-05.12e';l:$20000;p:$20000;crc:$b06e03b5),());
        leds2011:array[0..12] of tipo_roms=(
        (n:'lse_04.8b';l:$20000;p:0;crc:$166c0576),(n:'lse_03.7b';l:$20000;p:$1;crc:$0c8647b6),
        (n:'ls-02.6b';l:$20000;p:$40000;crc:$05c0285e),(n:'ls-01.5b';l:$20000;p:$40001;crc:$8bf934dd),
        (n:'ls-07.14j';l:$10000;p:0;crc:$98af7838),(n:'ls-08.10k';l:$8000;p:0;crc:$8803cf49),
        (n:'ls-10.13a';l:$40000;p:$0;crc:$db2c5883),(n:'ls-09.5a';l:$40000;p:$1;crc:$89949efb),
        (n:'ls-12.7l';l:$40000;p:0;crc:$6c1b2c6c),(n:'ls-11.2l';l:$80000;p:0;crc:$6bf81c64),
        (n:'ls-06.10e';l:$20000;p:0;crc:$88d39a5b),(n:'ls-05.12e';l:$20000;p:$20000;crc:$b06e03b5),());
        gigas:array[0..15] of tipo_roms=(
        (n:'8.8n';l:$4000;p:0;crc:$34ea8262),(n:'7.8r';l:$8000;p:$4000;crc:$43653909),
        (n:'317-5002.key';l:$2000;p:0;crc:$86a7e5f6),(n:'tbp24s10n.3a';l:$100;p:0;crc:$a784e71f),
        (n:'tbp24s10n.4d';l:$100;p:$100;crc:$376df30c),(n:'tbp24s10n.4a';l:$100;p:$200;crc:$4edff5bd),
        (n:'tbp24s10n.3d';l:$100;p:$300;crc:$fe201a4e),(n:'tbp24s10n.3b';l:$100;p:$400;crc:$5796cc4a),
        (n:'tbp24s10n.3c';l:$100;p:$500;crc:$28b5ee4c),(n:'4.3k';l:$4000;p:0;crc:$8ed78981),
        (n:'5.3h';l:$4000;p:$4000;crc:$0645ec2d),(n:'6.3g';l:$4000;p:$8000;crc:$99e9cb27),
        (n:'1.3p';l:$4000;p:0;crc:$d78fae6e),(n:'3.3l';l:$4000;p:$4000;crc:$37df4a4c),
        (n:'2.3n';l:$4000;p:$8000;crc:$3a46e354),());
        gigasm2:array[0..15] of tipo_roms=(
        (n:'18.8n';l:$4000;p:0;crc:$32e83d80),(n:'17.8r';l:$8000;p:$4000;crc:$460dadd2),
        (n:'14.3k';l:$4000;p:0;crc:$20b3405f),(n:'15.3h';l:$4000;p:$4000;crc:$d04ecfa8),
        (n:'16.3g';l:$4000;p:$8000;crc:$33776801),(n:'11.3p';l:$4000;p:0;crc:$f64cbd1e),
        (n:'13.3l';l:$4000;p:$4000;crc:$c228df19),(n:'12.3n';l:$4000;p:$8000;crc:$a6ad9ce2),
        (n:'tbp24s10n.3a';l:$100;p:0;crc:$a784e71f),(n:'tbp24s10n.4d';l:$100;p:$100;crc:$376df30c),
        (n:'tbp24s10n.4a';l:$100;p:$200;crc:$4edff5bd),(n:'tbp24s10n.3d';l:$100;p:$300;crc:$fe201a4e),
        (n:'tbp24s10n.3b';l:$100;p:$400;crc:$5796cc4a),(n:'tbp24s10n.3c';l:$100;p:$500;crc:$28b5ee4c),
        (n:'317-5002.key';l:$2000;p:0;crc:$86a7e5f6),());
        omega:array[0..15] of tipo_roms=(
        (n:'17.m10';l:$4000;p:0;crc:$c7de0993),(n:'8.n10';l:$8000;p:$4000;crc:$9bb61910),
        (n:'tbp24s10n.3f';l:$100;p:0;crc:$75ec7472),(n:'tbp24s10n.4f';l:$100;p:$100;crc:$5113a114),
        (n:'tbp24s10n.3g';l:$100;p:$200;crc:$b6b5d4a0),(n:'tbp24s10n.4g';l:$100;p:$300;crc:$931bc299),
        (n:'tbp24s10n.3e';l:$100;p:$400;crc:$899e089d),(n:'tbp24s10n.4e';l:$100;p:$500;crc:$28321dd8),
        (n:'4.f10';l:$4000;p:0;crc:$bf780a8e),(n:'5.h10';l:$4000;p:$4000;crc:$b491647f),
        (n:'6.j10';l:$4000;p:$8000;crc:$65beba5b),(n:'3.d10';l:$4000;p:0;crc:$c678b202),
        (n:'1.a10';l:$4000;p:$4000;crc:$e0aeada9),(n:'2.c10';l:$4000;p:$8000;crc:$dbc0a47f),
        (n:'omega.key';l:$2000;p:0;crc:$0a63943f),());
        pbillrd:array[0..15] of tipo_roms=(
        (n:'pb.18';l:$4000;p:0;crc:$9e6275ac),(n:'pb.7';l:$8000;p:$4000;crc:$dd438431),
        (n:'pb.9';l:$4000;p:$c000;crc:$089ce80a),(n:'82s129.3a';l:$100;p:0;crc:$44802169),
        (n:'82s129.4d';l:$100;p:$100;crc:$69ca07cc),(n:'82s129.4a';l:$100;p:$200;crc:$145f950a),
        (n:'82s129.3d';l:$100;p:$300;crc:$43d24e17),(n:'82s129.3b';l:$100;p:$400;crc:$7fdc872c),
        (n:'82s129.3c';l:$100;p:$500;crc:$cc1657e5),(n:'pb.4';l:$4000;p:0;crc:$2f4d4dd3),
        (n:'pb.5';l:$4000;p:$4000;crc:$9dfccbd3),(n:'pb.6';l:$4000;p:$8000;crc:$b5c3f6f6),
        (n:'10619.3r';l:$2000;p:0;crc:$3296b9d9),(n:'10621.3m';l:$2000;p:$4000;crc:$3dca8e4b),
        (n:'10620.3n';l:$2000;p:$8000;crc:$ee76b079),());
        armedf:array[0..14] of tipo_roms=(
        (n:'06.3d';l:$10000;p:0;crc:$0f9015e2),(n:'01.3f';l:$10000;p:$1;crc:$816ff7c5),
        (n:'07.5d';l:$10000;p:$20000;crc:$5b3144a5),(n:'02.4f';l:$10000;p:$20001;crc:$fa10c29d),
        (n:'af_08.rom';l:$10000;p:$40000;crc:$d1d43600),(n:'af_03.rom';l:$10000;p:$40001;crc:$bbe1fe2d),
        (n:'af_10.rom';l:$10000;p:0;crc:$c5eacb87),(n:'09.11c';l:$8000;p:0;crc:$5c6993d5),
        (n:'af_14.rom';l:$10000;p:0;crc:$8c5dc5a7),(n:'af_13.rom';l:$10000;p:$10000;crc:$136a58a3),
        (n:'af_04.rom';l:$10000;p:0;crc:$44d3af4f),(n:'af_05.rom';l:$10000;p:$10000;crc:$92076cab),
        (n:'af_11.rom';l:$20000;p:0;crc:$b46c473c),(n:'af_12.rom';l:$20000;p:$20000;crc:$23cb6bfe),());
        terraf:array[0..15] of tipo_roms=(
        (n:'8.6e';l:$10000;p:0;crc:$fd58fa06),(n:'3.6h';l:$10000;p:$1;crc:$54823a7d),
        (n:'7.4e';l:$10000;p:$20000;crc:$fde8de7e),(n:'2.4h';l:$10000;p:$20001;crc:$db987414),
        (n:'6.3e';l:$10000;p:$40000;crc:$a5bb8c3b),(n:'1.3h';l:$10000;p:$40001;crc:$d2de6d28),
        (n:'11.17k';l:$10000;p:0;crc:$4407d475),(n:'10.11c';l:$4000;p:0;crc:$ac705812),
        (n:'9.11e';l:$8000;p:0;crc:$bc6f7cbc),(n:'15.8a';l:$10000;p:0;crc:$2144d8e0),
        (n:'14.6a';l:$10000;p:$10000;crc:$744f5c9e),(n:'5.15h';l:$10000;p:0;crc:$25d23dfd),
        (n:'4.13h';l:$10000;p:$10000;crc:$b9b0fe27),(n:'12.7d';l:$10000;p:0;crc:$2d1f2ceb),
        (n:'13.9d';l:$10000;p:$1;crc:$1d2f92d6),());
        cclimbr2:array[0..18] of tipo_roms=(
        (n:'4.bin';l:$10000;p:0;crc:$7922ea14),(n:'1.bin';l:$10000;p:$1;crc:$2ac7ed67),
        (n:'6.bin';l:$10000;p:$20000;crc:$7905c992),(n:'5.bin';l:$10000;p:$20001;crc:$47be6c1e),
        (n:'3.bin';l:$10000;p:$40000;crc:$1fb110d6),(n:'2.bin';l:$10000;p:$40001;crc:$0024c15b),
        (n:'11.bin';l:$4000;p:0;crc:$fe0175be),(n:'12.bin';l:$8000;p:$4000;crc:$5ddf18f2),
        (n:'9.bin';l:$4000;p:0;crc:$740d260f),(n:'10.bin';l:$8000;p:0;crc:$7f475266),
        (n:'17.bin';l:$10000;p:0;crc:$e24bb2d7),(n:'18.bin';l:$10000;p:$10000;crc:$56834554),
        (n:'7.bin';l:$10000;p:0;crc:$cbdd3906),(n:'8.bin';l:$10000;p:$10000;crc:$b2a613c0),
        (n:'15.bin';l:$10000;p:0;crc:$4bf838be),(n:'13.bin';l:$10000;p:$10000;crc:$6b6ec999),
        (n:'16.bin';l:$10000;p:$20000;crc:$21a265c5),(n:'14.bin';l:$10000;p:$30000;crc:$f426a4ad),());
        legion:array[0..13] of tipo_roms=(
        (n:'lg1.bin';l:$10000;p:0;crc:$c4aeb724),(n:'lg3.bin';l:$10000;p:$1;crc:$777e4935),
        (n:'legion.1b';l:$10000;p:$20000;crc:$c306660a),(n:'legion.1d';l:$10000;p:$20001;crc:$c2e45e1e),
        (n:'legion.1h';l:$4000;p:0;crc:$2ca4f7f0),(n:'legion.1i';l:$8000;p:$4000;crc:$79f4a827),
        (n:'lg7.bin';l:$4000;p:0;crc:$533e2b58),(n:'lg8.bin';l:$8000;p:0;crc:$e0596570),
        (n:'legion.1l';l:$10000;p:0;crc:$29b8adaa),(n:'legion.1e';l:$10000;p:0;crc:$a9d70faf),
        (n:'legion.1f';l:$8000;p:$10000;crc:$f018313b),(n:'legion.1k';l:$10000;p:0;crc:$ff5a0db9),
        (n:'legion.1j';l:$10000;p:$10000;crc:$bae220c8),());
        aso:array[0..17] of tipo_roms=(
        (n:'p1.8d';l:$4000;p:0;crc:$84981f3c),(n:'p2.7d';l:$4000;p:$4000;crc:$cfe912a6),
        (n:'p3.5d';l:$4000;p:$8000;crc:$39a666d2),(n:'p4.3d';l:$4000;p:0;crc:$a4122355),
        (n:'p5.2d';l:$4000;p:$4000;crc:$9879e506),(n:'p6.1d';l:$4000;p:$8000;crc:$c0bfdf1f),
        (n:'p7.4f';l:$4000;p:0;crc:$dbc19736),(n:'p8.3f';l:$4000;p:$4000;crc:$537726a9),
        (n:'p9.2f';l:$4000;p:$8000;crc:$aef5a4f4),(n:'p14.1h';l:$2000;p:0;crc:$8baa2253),
        (n:'p10.14h';l:$8000;p:0;crc:$00dff996),(n:'p11.11h';l:$8000;p:0;crc:$7feac86c),
        (n:'p12.9h';l:$8000;p:$8000;crc:$6895990b),(n:'p13.8h';l:$8000;p:$c000;crc:$87a81ce1),
        (n:'mb7122h.12f';l:$400;p:0;crc:$5b0a0059),(n:'mb7122h.13f';l:$400;p:$400;crc:$37e28dd8),
        (n:'mb7122h.14f';l:$400;p:$800;crc:$c3fd1dd3),());
        firetrap:array[0..22] of tipo_roms=(
        (n:'di-02.4a';l:$8000;p:0;crc:$3d1e4bf7),(n:'di-01.3a';l:$8000;p:$8000;crc:$9bbae38b),
        (n:'di-00-a.2a';l:$8000;p:$10000;crc:$f39e2cf4),(n:'di-17.10j';l:$8000;p:0;crc:$8605f6b9),
        (n:'di-18.12j';l:$8000;p:$8000;crc:$49508c93),(n:'di-12.16h';l:$1000;p:0;crc:$6340a4d7),
        (n:'di-03.17c';l:$2000;p:0;crc:$46721930),(n:'di-06.3e';l:$8000;p:$0;crc:$441d9154),
        (n:'di-04.2e';l:$8000;p:$8000;crc:$8e6e7eec),(n:'di-07.6e';l:$8000;p:$10000;crc:$ef0a7e23),
        (n:'di-05.4e';l:$8000;p:$18000;crc:$ec080082),(n:'di-09.3j';l:$8000;p:$0;crc:$d11e28e8),
        (n:'di-08.2j';l:$8000;p:$8000;crc:$c32a21d8),(n:'di-11.6j';l:$8000;p:$10000;crc:$6424d5c3),
        (n:'di-10.4j';l:$8000;p:$18000;crc:$9b89300a),(n:'di-16.17h';l:$8000;p:$0;crc:$0de055d7),
        (n:'di-13.13h';l:$8000;p:$8000;crc:$869219da),(n:'di-14.14h';l:$8000;p:$10000;crc:$6b65812e),
        (n:'di-15.15h';l:$8000;p:$18000;crc:$3e27f77d),(n:'firetrap.3b';l:$100;p:$0;crc:$8bb45337),
        (n:'firetrap.4b';l:$100;p:$100;crc:$d5abfc64),(n:'firetrap.1a';l:$100;p:$200;crc:$d67f3514),());
        puzz3x3:array[0..15] of tipo_roms=(
        (n:'1.bin';l:$20000;p:0;crc:$e9c39ee7),(n:'2.bin';l:$20000;p:$1;crc:$524963be),
        (n:'3.bin';l:$80000;p:0;crc:$53c2aa6a),(n:'4.bin';l:$80000;p:1;crc:$fb0b76fd),
        (n:'5.bin';l:$80000;p:2;crc:$b6c1e108),(n:'6.bin';l:$80000;p:3;crc:$47cb0e8e),
        (n:'7.bin';l:$20000;p:0;crc:$45b1f58b),(n:'8.bin';l:$20000;p:1;crc:$c0d404a7),
        (n:'9.bin';l:$20000;p:2;crc:$6b303aa9),(n:'10.bin';l:$20000;p:3;crc:$6d0107bc),
        (n:'11.bin';l:$20000;p:0;crc:$e124c0b5),(n:'12.bin';l:$20000;p:1;crc:$ae4a8707),
        (n:'13.bin';l:$20000;p:2;crc:$f06925d1),(n:'14.bin';l:$20000;p:3;crc:$07252636),
        (n:'15.bin';l:$80000;p:0;crc:$d3aff355),());
        casanova:array[0..20] of tipo_roms=(
        (n:'casanova.u7';l:$40000;p:1;crc:$869c2bf2),(n:'casanova.u8';l:$40000;p:$0;crc:$9df77f4b),
        (n:'casanova.u23';l:$80000;p:0;crc:$4bd4e5b1),(n:'casanova.u25';l:$80000;p:1;crc:$5461811b),
        (n:'casanova.u27';l:$80000;p:2;crc:$dd178379),(n:'casanova.u29';l:$80000;p:3;crc:$36469f9e),
        (n:'casanova.u81';l:$80000;p:$200000;crc:$9eafd37d),(n:'casanova.u83';l:$80000;p:$200001;crc:$9d4ce407),
        (n:'casanova.u85';l:$80000;p:$200002;crc:$113c6e3a),(n:'casanova.u87';l:$80000;p:$200003;crc:$61bd80f8),
        (n:'casanova.u45';l:$80000;p:0;crc:$530d78bc),(n:'casanova.u43';l:$80000;p:1;crc:$1462d7d6),
        (n:'casanova.u41';l:$80000;p:2;crc:$95f67e82),(n:'casanova.u39';l:$80000;p:3;crc:$97d4095a),
        (n:'casanova.u54';l:$80000;p:0;crc:$e60bf0db),(n:'casanova.u52';l:$80000;p:1;crc:$708f779c),
        (n:'casanova.u50';l:$80000;p:2;crc:$c73b5e98),(n:'casanova.u48';l:$80000;p:3;crc:$af9f59c5),
        (n:'casanova.su2';l:$80000;p:0;crc:$84a8320e),(n:'casanova.su3';l:$40000;p:$80000;crc:$334a2d1a),());
        k31945:array[0..7] of tipo_roms=(
        (n:'prg-1.u51';l:$80000;p:1;crc:$6b345f27),(n:'prg-2.u52';l:$80000;p:$0;crc:$ce09b98c),
        (n:'m16m-1.u62';l:$200000;p:0;crc:$0b9a6474),(n:'m16m-2.u63';l:$200000;p:2;crc:$368a8c2e),
        (n:'m16m-3.u61';l:$200000;p:0;crc:$32fc80dd),(n:'snd-1.su7';l:$80000;p:0;crc:$bbb7f0ff),
        (n:'snd-2.su4';l:$80000;p:0;crc:$47e3952e),());
        flagrall:array[0..14] of tipo_roms=(
        (n:'11_u34.bin';l:$40000;p:1;crc:$24dd439d),(n:'12_u35.bin';l:$40000;p:$0;crc:$373b71a5),
        (n:'1_u5.bin';l:$80000;p:0;crc:$9377704b),(n:'5_u6.bin';l:$80000;p:1;crc:$1ac0bd0c),
        (n:'2_u7.bin';l:$80000;p:2;crc:$5f6db2b3),(n:'6_u8.bin';l:$80000;p:3;crc:$79e4643c),
        (n:'3_u58.bin';l:$40000;p:$200000;crc:$c913df7d),(n:'4_u59.bin';l:$40000;p:$200001;crc:$cb192384),
        (n:'7_u60.bin';l:$40000;p:$200002;crc:$f187a7bf),(n:'8_u61.bin';l:$40000;p:$200003;crc:$b73fa441),
        (n:'10_u102.bin';l:$80000;p:0;crc:$b1fd3279),(n:'9_u103.bin';l:$80000;p:$80000;crc:$01e6d654),
        (n:'13_su4.bin';l:$80000;p:0;crc:$7b0630b3),(n:'14_su6.bin';l:$40000;p:$80000;crc:$593b038f),());
        bloodbros:array[0..10] of tipo_roms=(
        (n:'2.u021.7n';l:$20000;p:1;crc:$204dca6e),(n:'1.u022.8n';l:$20000;p:$0;crc:$ac6719e7),
        (n:'4.u023.7l';l:$20000;p:$40001;crc:$fd951c2c),(n:'3.u024.8l';l:$20000;p:$40000;crc:$18d3c460),
        (n:'bb_07.u1016.6a';l:$10000;p:0;crc:$411b94e8),(n:'bb_05.u061.6f';l:$10000;p:0;crc:$04ba6d19),
        (n:'bb_06.u063.6d';l:$10000;p:$10000;crc:$7092e35b),(n:'blood_bros_bk__=c=1990_tad_corp.u064.4d';l:$100000;p:0;crc:$1aa87ee6),
        (n:'blood_bros_obj__=c=1990_tad_corp.u078.2n';l:$100000;p:0;crc:$d27c3952),(n:'bb_08.u095.5a';l:$20000;p:0;crc:$deb1b975),());
        skysmash:array[0..10] of tipo_roms=(
        (n:'rom5';l:$20000;p:0;crc:$867f9897),(n:'rom6';l:$20000;p:$1;crc:$e9c1d308),
        (n:'rom7';l:$20000;p:$40000;crc:$d209db4d),(n:'rom8';l:$20000;p:$40001;crc:$d3646728),
        (n:'rom2';l:$10000;p:0;crc:$75b194cf),(n:'rom3';l:$10000;p:0;crc:$fbb241be),
        (n:'rom4';l:$10000;p:$10000;crc:$ad3cde81),(n:'rom9';l:$100000;p:0;crc:$b0a5eecf),
        (n:'rom10';l:$80000;p:0;crc:$1bbcda5d),(n:'rom1';l:$20000;p:0;crc:$e69986f6),());
        baraduke:array[0..15] of tipo_roms=(
        (n:'bd1_3.9c';l:$2000;p:$6000;crc:$ea2ea790),(n:'bd1_1.9a';l:$4000;p:$8000;crc:$4e9f2bdc),
        (n:'bd1_2.9b';l:$4000;p:$c000;crc:$40617fcd),(n:'bd1_4b.3b';l:$4000;p:$8000;crc:$a47ecd32),
        (n:'cus60-60a1.mcu';l:$1000;p:$f000;crc:$076ea82a),(n:'bd1_5.3j';l:$2000;p:0;crc:$706b7fee),
        (n:'bd1_8.4p';l:$4000;p:0;crc:$b0bb0710),(n:'bd1_7.4n';l:$4000;p:$4000;crc:$0d7ebec9),
        (n:'bd1_6.4m';l:$4000;p:$8000;crc:$e5da0896),(n:'bd1_9.8k';l:$4000;p:0;crc:$87a29acc),
        (n:'bd1_10.8l';l:$4000;p:$4000;crc:$72b6d20c),(n:'bd1_11.8m';l:$4000;p:$8000;crc:$3076af9c),
        (n:'bd1_12.8n';l:$4000;p:$c000;crc:$8b4c09a3),(n:'bd1-1.1n';l:$800;p:$0;crc:$0d78ebc6),
        (n:'bd1-2.2m';l:$800;p:$800;crc:$03f7241f),());
        metrocross:array[0..12] of tipo_roms=(
        (n:'mc1-3.9c';l:$2000;p:$6000;crc:$3390b33c),(n:'mc1-1.9a';l:$4000;p:$8000;crc:$10b0977e),
        (n:'mc1-2.9b';l:$4000;p:$c000;crc:$5c846f35),(n:'mc1-4.3b';l:$2000;p:$8000;crc:$9c88f898),
        (n:'cus60-60a1.mcu';l:$1000;p:$f000;crc:$076ea82a),(n:'mc1-5.3j';l:$2000;p:0;crc:$9b5ea33a),
        (n:'mc1-7.4p';l:$4000;p:0;crc:$c9dfa003),(n:'mc1-6.4n';l:$4000;p:$4000;crc:$9686dc3c),
        (n:'mc1-8.8k';l:$4000;p:0;crc:$265b31fa),(n:'mc1-9.8l';l:$4000;p:$4000;crc:$541ec029),
        (n:'mc1-1.1n';l:$800;p:$0;crc:$32a78a8b),(n:'mc1-2.2m';l:$800;p:$800;crc:$6f4dca7b),());
        roishtar:array[0..21] of tipo_roms=(
        (n:'ri1_2.9d';l:$2000;p:$4000;crc:$fcd58d91),(n:'ri1_1c.9c';l:$8000;p:$8000;crc:$14acbacb),
        (n:'ri1_3.12c';l:$8000;p:$8000;crc:$a39829f7),(n:'ri1_14.7r';l:$4000;p:$0;crc:$de8154b4),
        (n:'ri1_15.7s';l:$2000;p:$4000;crc:$4298822b),(n:'ri1_12.4r';l:$4000;p:$0;crc:$557e54d3),
        (n:'ri1_13.4s';l:$2000;p:$4000;crc:$9ebe8e32),(n:'ri1_5.12h';l:$8000;p:$0;crc:$46b59239),
        (n:'ri1_6.12k';l:$8000;p:$8000;crc:$94d9ef48),(n:'ri1_7.12l';l:$8000;p:$10000;crc:$da802b59),
        (n:'ri1_8.12m';l:$8000;p:$18000;crc:$16b88b74),(n:'ri1_9.12p';l:$8000;p:$20000;crc:$f3de3c2a),
        (n:'ri1_10.12r';l:$8000;p:$28000;crc:$6dacc70d),(n:'ri1_11.12t';l:$8000;p:$30000;crc:$fb6bc533),
        (n:'ri1_4.6b';l:$8000;p:$0;crc:$552172b8),(n:'cus60-60a1.mcu';l:$1000;p:$8000;crc:$076ea82a),
        (n:'ri1-1.3r';l:$200;p:$0;crc:$29cd0400),(n:'ri1-2.3s';l:$200;p:$200;crc:$02fd278d),
        (n:'ri1-3.4v';l:$800;p:$400;crc:$cbd7e53f),(n:'ri1-4.5v';l:$800;p:$c00;crc:$22921617),
        (n:'ri1-5.6u';l:$20;p:$1400;crc:$e2188075),());
        genpeitd:array[0..25] of tipo_roms=(
        (n:'gt1_1b.9c';l:$8000;p:$8000;crc:$75396194),(n:'gt1_10b.f1';l:$10000;p:$0;crc:$5721ad0d),
        (n:'gt1_2.12c';l:$4000;p:$c000;crc:$302f2cb6),(n:'gt1_7.7r';l:$10000;p:0;crc:$ea77a211),
        (n:'gt1_4.4s';l:$8000;p:$10000;crc:$1b128a2e),(n:'gt1_5.4r';l:$8000;p:0;crc:$44d58b06),
        (n:'rt1_6.4s';l:$4000;p:$8000;crc:$db8d45b0),(n:'gt1_11.12h';l:$20000;p:0;crc:$3181a5fe),
        (n:'gt1_12.12k';l:$20000;p:$20000;crc:$76b729ab),(n:'gt1_13.12l';l:$20000;p:$40000;crc:$e332a36e),
        (n:'gt1_14.12m';l:$20000;p:$60000;crc:$e5ffaef5),(n:'gt1_15.12p';l:$20000;p:$80000;crc:$198b6878),
        (n:'gt1_16.12r';l:$20000;p:$a0000;crc:$801e29c7),(n:'gt1_8.12t';l:$10000;p:$c0000;crc:$ad7bc770),
        (n:'gt1_9.12u';l:$10000;p:$e0000;crc:$d95a5fd7),(n:'gt1_3.6b';l:$8000;p:$4000;crc:$315cd988),
        (n:'cus60-60a1.mcu';l:$1000;p:$f000;crc:$076ea82a),(n:'gt1-1.3r';l:$200;p:$0;crc:$2f0ddddb),
        (n:'gt1-2.3s';l:$200;p:$200;crc:$87d27025),(n:'gt1-3.4v';l:$800;p:$400;crc:$c178de99),
        (n:'gt1-4.5v';l:$800;p:$c00;crc:$9f48ef17),(n:'gt1-5.6u';l:$20;p:$1400;crc:$e4130804),
        (n:'gt1_17.f3';l:$20000;p:$0;crc:$26181ff8),(n:'gt1_18.h3';l:$20000;p:$20000;crc:$7ef9e5ea),
        (n:'gt1_19.k3';l:$20000;p:$40000;crc:$38e11f6c),());
        wndrmomo:array[0..26] of tipo_roms=(
        (n:'wm1_1.9c';l:$8000;p:$8000;crc:$34b50bf0),(n:'wm1_16.f1';l:$10000;p:$0;crc:$e565f8f3),
        (n:'wm1_2.12c';l:$8000;p:$8000;crc:$3181efd0),(n:'wm1_6.7r';l:$8000;p:0;crc:$93955fbb),
        (n:'wm1_7.7s';l:$4000;p:$8000;crc:$7d662527),(n:'wm1_4.4r';l:$8000;p:0;crc:$bbe67836),
        (n:'wm1_5.4s';l:$4000;p:$8000;crc:$a81b481f),(n:'wm1_8.12h';l:$10000;p:0;crc:$14f52e72),
        (n:'wm1_9.12k';l:$10000;p:$10000;crc:$16f8cdae),(n:'wm1_10.12l';l:$10000;p:$20000;crc:$bfbc1896),
        (n:'wm1_11.12m';l:$10000;p:$30000;crc:$d775ddb2),(n:'wm1_12.12p';l:$10000;p:$40000;crc:$de64c12f),
        (n:'wm1_13.12r';l:$10000;p:$50000;crc:$cfe589ad),(n:'wm1_14.12t';l:$10000;p:$60000;crc:$2ae21a53),
        (n:'wm1_15.12u';l:$10000;p:$70000;crc:$b5c98be0),(n:'wm1_3.6b';l:$8000;p:$4000;crc:$55f01df7),
        (n:'cus60-60a1.mcu';l:$1000;p:$f000;crc:$076ea82a),(n:'wm1-1.3r';l:$200;p:$0;crc:$1af8ade8),
        (n:'wm1-2.3s';l:$200;p:$200;crc:$8694e213),(n:'wm1-3.4v';l:$800;p:$400;crc:$2ffaf9a4),
        (n:'wm1-4.5v';l:$800;p:$c00;crc:$f4e83e0b),(n:'wm1-5.6u';l:$20;p:$1400;crc:$e4130804),
        (n:'wm1_17.f3';l:$10000;p:$0;crc:$bea3c318),(n:'wm1_18.h3';l:$10000;p:$20000;crc:$6d73bcc5),
        (n:'wm1_19.k3';l:$10000;p:$40000;crc:$d288e912),(n:'wm1_20.m3';l:$10000;p:$60000;crc:$076a72cb),());
        altbeast:array[0..17] of tipo_roms=(
        (n:'epr-11907.a7';l:$20000;p:0;crc:$29e0c3ad),(n:'epr-11906.a5';l:$20000;p:$1;crc:$4c9e9cd8),
        (n:'epr-11671.a10';l:$8000;p:0;crc:$2b71343b),(n:'opr-11672.a11';l:$20000;p:$8000;crc:$bbd7f460),
        (n:'opr-11673.a12';l:$20000;p:$1;crc:$400c4a36),(n:'317-0078.c2';l:$1000;p:0;crc:$8101925f),
        (n:'opr-11674.a14';l:$20000;p:0;crc:$a57a66d5),(n:'opr-11675.a15';l:$20000;p:$20000;crc:$2ef2f144),
        (n:'opr-11676.a16';l:$20000;p:$40000;crc:$0c04acac),(n:'epr-11677.b1';l:$20000;p:1;crc:$a01425cd),
        (n:'epr-11681.b5';l:$20000;p:$0;crc:$d9e03363),(n:'epr-11678.b2';l:$20000;p:$40001;crc:$17a9fc53),
        (n:'epr-11682.b6';l:$20000;p:$40000;crc:$e3f77c5e),(n:'epr-11679.b3';l:$20000;p:$80001;crc:$14dcc245),
        (n:'epr-11683.b7';l:$20000;p:$80000;crc:$f9a60f06),(n:'epr-11680.b4';l:$20000;p:$c0001;crc:$f43dcdec),
        (n:'epr-11684.b8';l:$20000;p:$c0000;crc:$b20c0edb),());
         goldnaxe:array[0..14] of tipo_roms=(
        (n:'epr-12545.ic2';l:$40000;p:0;crc:$a97c4e4d),(n:'epr-12544.ic1';l:$40000;p:$1;crc:$5e38f668),
        (n:'epr-12390.ic8';l:$8000;p:0;crc:$399fc5f5),(n:'mpr-12384.ic6';l:$20000;p:$8000;crc:$6218d8e7),
        (n:'317-0123a.c2';l:$1000;p:0;crc:$cf19e7d4),(n:'epr-12385.ic19';l:$20000;p:0;crc:$b8a4e7e0),
        (n:'epr-12386.ic20';l:$20000;p:$20000;crc:$25d7d779),(n:'epr-12387.ic21';l:$20000;p:$40000;crc:$c7fcadf3),
        (n:'mpr-12378.ic9';l:$40000;p:1;crc:$119e5a82),(n:'mpr-12379.ic12';l:$40000;p:$0;crc:$1a0e8c57),
        (n:'mpr-12380.ic10';l:$40000;p:$80001;crc:$bb2c0853),(n:'mpr-12381.ic13';l:$40000;p:$80000;crc:$81ba6ecc),
        (n:'mpr-12382.ic11';l:$40000;p:$100001;crc:$81601c6f),(n:'mpr-12383.ic14';l:$40000;p:$100000;crc:$5dbacf7a),());
        ddux:array[0..13] of tipo_roms=(
        (n:'epr-12189.a7';l:$20000;p:0;crc:$558e9b5d),(n:'epr-12188.a5';l:$20000;p:$1;crc:$802a240f),
        (n:'epr-11915.a8';l:$20000;p:$40000;crc:$d8ed3132),(n:'epr-11913.a6';l:$20000;p:$40001;crc:$30c6cb92),
        (n:'epr-11916.a10';l:$8000;p:0;crc:$7ab541cf),(n:'317-0095.c2';l:$1000;p:0;crc:$b06b4ca7),
        (n:'mpr-11917.a14';l:$10000;p:0;crc:$6f772190),(n:'mpr-11918.a15';l:$10000;p:$10000;crc:$c731db95),
        (n:'mpr-11919.a16';l:$10000;p:$20000;crc:$64d5a491),(n:'mpr-11920.b1';l:$20000;p:$1;crc:$e5d1e3cd),
        (n:'mpr-11922.b5';l:$20000;p:$0;crc:$70b0c4dd),(n:'mpr-11921.b2';l:$20000;p:$40001;crc:$61d2358c),
        (n:'mpr-11923.b6';l:$20000;p:$40000;crc:$c9ffe47d),());
        eswat:array[0..13] of tipo_roms=(
        (n:'bootleg_epr-12659.a2';l:$40000;p:0;crc:$3157f69d),(n:'bootleg_epr-12658.a1';l:$40000;p:$1;crc:$0feb544b),
        (n:'epr-12617.a13';l:$8000;p:0;crc:$7efecf23),(n:'mpr-12616.a11';l:$40000;p:$8000;crc:$254347c2),
        (n:'mpr-12624.b11';l:$40000;p:0;crc:$375a5ec4),(n:'mpr-12625.b12';l:$40000;p:$40000;crc:$3b8c757e),
        (n:'mpr-12626.b13';l:$40000;p:$80000;crc:$3efca25c),(n:'mpr-12618.b1';l:$40000;p:1;crc:$0d1530bf),
        (n:'mpr-12621.b4';l:$40000;p:$0;crc:$18ff0799),(n:'mpr-12619.b2';l:$40000;p:$80001;crc:$32069246),
        (n:'mpr-12622.b5';l:$40000;p:$80000;crc:$a3dfe436),(n:'mpr-12620.b3';l:$40000;p:$100001;crc:$f6b096e0),
        (n:'mpr-12623.b6';l:$40000;p:$100000;crc:$6773fef6),());
        passsht:array[0..16] of tipo_roms=(
        (n:'bootleg_epr-11871.a4';l:$10000;p:0;crc:$f009c017),(n:'bootleg_epr-11870.a1';l:$10000;p:$1;crc:$9cd5f12f),
        (n:'epr-11857.a7';l:$8000;p:0;crc:$789edc06),(n:'epr-11858.a8';l:$8000;p:$8000;crc:$08ab0018),
        (n:'epr-11859.a9';l:$8000;p:$18000;crc:$8673e01b),(n:'epr-11860.a10';l:$8000;p:$28000;crc:$10263746),
        (n:'epr-11861.a11';l:$8000;p:$38000;crc:$38b54a71),(n:'opr-11854.b9';l:$10000;p:0;crc:$d31c0b6c),
        (n:'opr-11855.b10';l:$10000;p:$10000;crc:$b78762b4),(n:'opr-11856.b11';l:$10000;p:$20000;crc:$ea49f666),
        (n:'opr-11862.b1';l:$10000;p:1;crc:$b6e94727),(n:'opr-11865.b5';l:$10000;p:$0;crc:$17e8d5d5),
        (n:'opr-11863.b2';l:$10000;p:$20001;crc:$3e670098),(n:'opr-11866.b6';l:$10000;p:$20000;crc:$50eb71cc),
        (n:'opr-11864.b3';l:$10000;p:$40001;crc:$05733ca8),(n:'opr-11867.b7';l:$10000;p:$40000;crc:$81e49697),());
        aurail:array[0..28] of tipo_roms=(
        (n:'epr-13577.a7';l:$20000;p:0;crc:$6701b686),(n:'epr-13576.a5';l:$20000;p:$1;crc:$1e428d94),
        (n:'epr-13447.a8';l:$20000;p:$40000;crc:$70a52167),(n:'epr-13445.a6';l:$20000;p:$40001;crc:$28dfc3dd),
        (n:'epr-13448.a10';l:$8000;p:0;crc:$b5183fb9),(n:'mpr-13449.a11';l:$20000;p:$8000;crc:$d3d9aaf9),
        (n:'mpr-13450.a14';l:$20000;p:0;crc:$0fc4a7a8),(n:'mpr-13465.b14';l:$20000;p:$20000;crc:$e08135e0),
        (n:'mpr-13451.a15';l:$20000;p:$40000;crc:$1c49852f),(n:'mpr-13466.b15';l:$20000;p:$60000;crc:$e14c6684),
        (n:'mpr-13452.a16';l:$20000;p:$80000;crc:$047bde5e),(n:'mpr-13467.b16';l:$20000;p:$a0000;crc:$6309fec4),
        (n:'mpr-13453.b1';l:$20000;p:1;crc:$5fa0a9f8),(n:'mpr-13457.b5';l:$20000;p:$0;crc:$0d1b54da),
        (n:'mpr-13454.b2';l:$20000;p:$40001;crc:$5f6b33b1),(n:'mpr-13458.b6';l:$20000;p:$40000;crc:$bad340c3),
        (n:'mpr-13455.b3';l:$20000;p:$80001;crc:$4e80520b),(n:'mpr-13459.b7';l:$20000;p:$80000;crc:$7e9165ac),
        (n:'mpr-13456.b4';l:$20000;p:$c0001;crc:$5733c428),(n:'mpr-13460.b8';l:$20000;p:$c0000;crc:$66b8f9b3),
        (n:'mpr-13440.a1';l:$20000;p:1;crc:$4f370b2b),(n:'mpr-13461.b10';l:$20000;p:$0;crc:$f76014bf),
        (n:'mpr-13441.a2';l:$20000;p:$40001;crc:$37cf9cb4),(n:'mpr-13462.b11';l:$20000;p:$40000;crc:$1061e7da),
        (n:'mpr-13442.a3';l:$20000;p:$80001;crc:$049698ef),(n:'mpr-13463.b12';l:$20000;p:$80000;crc:$7dbcfbf1),
        (n:'mpr-13443.a4';l:$20000;p:$c0001;crc:$77a8989e),(n:'mpr-13464.b13';l:$20000;p:$c0000;crc:$551df422),());
        hellfire:array[0..11] of tipo_roms=(
        (n:'b90_14.0';l:$20000;p:0;crc:$101df9f5),(n:'b90_15.1';l:$20000;p:$1;crc:$e67fd452),
        (n:'b90_03.2';l:$8000;p:0;crc:$4058fa67),
        (n:'b90_04.3';l:$20000;p:0;crc:$ea6150fc),(n:'b90_05.4';l:$20000;p:$1;crc:$bb52c507),
        (n:'b90_06.5';l:$20000;p:$40000;crc:$cf5b0252),(n:'b90_07.6';l:$20000;p:$40001;crc:$b98af263),
        (n:'b90_11.10';l:$20000;p:0;crc:$c33e543c),(n:'b90_10.9';l:$20000;p:$1;crc:$35fd1092),
        (n:'b90_09.8';l:$20000;p:$40000;crc:$cf01009e),(n:'b90_08.7';l:$20000;p:$40001;crc:$3404a5e3),());
        lnc:array[0..12] of tipo_roms=(
        (n:'s3-3d';l:$1000;p:$c000;crc:$1ab4f2c2),(n:'s2-3c';l:$1000;p:$d000;crc:$5e46b789),
        (n:'s1-3b';l:$1000;p:$e000;crc:$1308a32e),(n:'s0-3a';l:$1000;p:$f000;crc:$beb4b1fc),
        (n:'sa-1h';l:$1000;p:$e000;crc:$379387ec),(n:'s4-11l';l:$1000;p:$0000;crc:$a2162a9e),
        (n:'s5-11m';l:$1000;p:$1000;crc:$12f1c2db),(n:'s6-13l';l:$1000;p:$2000;crc:$d21e2a57),
        (n:'s7-13m';l:$1000;p:$3000;crc:$c4f247cd),(n:'s8-15l';l:$1000;p:$4000;crc:$672a92d0),
        (n:'s9-15m';l:$1000;p:$5000;crc:$87c8ee9a),(n:'sc-5m';l:$20;p:$0;crc:$2a976ebe),());
        mmonkey:array[0..12] of tipo_roms=(
        (n:'mmonkey.e4';l:$1000;p:$c000;crc:$8d31bf6a),(n:'mmonkey.d4';l:$1000;p:$d000;crc:$e54f584a),
        (n:'mmonkey.b4';l:$1000;p:$e000;crc:$399a161e),(n:'mmonkey.a4';l:$1000;p:$f000;crc:$f7d3d1e3),
        (n:'mmonkey.h1';l:$1000;p:$e000;crc:$5bcb2e81),(n:'mmonkey.l11';l:$1000;p:$0000;crc:$b6aa8566),
        (n:'mmonkey.m11';l:$1000;p:$1000;crc:$6cc4d0c4),(n:'mmonkey.l13';l:$1000;p:$2000;crc:$2a343b7e),
        (n:'mmonkey.m13';l:$1000;p:$3000;crc:$0230b50d),(n:'mmonkey.l14';l:$1000;p:$4000;crc:$922bb3e1),
        (n:'mmonkey.m14';l:$1000;p:$5000;crc:$f943e28c),(n:'mmi6331.m5';l:$20;p:$0;crc:$55e28b32),());
        karatechamp:array[0..30] of tipo_roms=(
        (n:'b014.bin';l:$2000;p:0;crc:$0000d1a0),(n:'b015.bin';l:$2000;p:$2000;crc:$03fae67e),
        (n:'b016.bin';l:$2000;p:$4000;crc:$3b6e1d08),(n:'b017.bin';l:$2000;p:$6000;crc:$c1848d1a),
        (n:'b018.bin';l:$2000;p:$8000;crc:$b824abc7),(n:'b019.bin';l:$2000;p:$a000;crc:$3b487a46),
        (n:'b026.bin';l:$2000;p:0;crc:$999ed2c7),(n:'b025.bin';l:$2000;p:$2000;crc:$33171e07),
        (n:'b024.bin';l:$2000;p:$4000;crc:$910b48b9),(n:'b023.bin';l:$2000;p:$6000;crc:$47f66aac),
        (n:'b022.bin';l:$2000;p:$8000;crc:$5928e749),(n:'b021.bin';l:$2000;p:$a000;crc:$ca17e3ba),
        (n:'b020.bin';l:$2000;p:$c000;crc:$ada4f2cd),(n:'b000.bin';l:$2000;p:0;crc:$a4fa98a1),
        (n:'b001.bin';l:$2000;p:$4000;crc:$fea09f7c),(n:'b013.bin';l:$2000;p:0;crc:$eaad4168),
        (n:'b004.bin';l:$2000;p:$2000;crc:$10a47e2d),(n:'b012.bin';l:$2000;p:$4000;crc:$b4842ea9),
        (n:'b003.bin';l:$2000;p:$6000;crc:$8cd166a5),(n:'b011.bin';l:$2000;p:$8000;crc:$4cbd3aa3),
        (n:'b002.bin';l:$2000;p:$a000;crc:$6be342a6),(n:'b007.bin';l:$2000;p:$c000;crc:$cb91d16b),
        (n:'b010.bin';l:$2000;p:$e000;crc:$489c9c04),(n:'b006.bin';l:$2000;p:$10000;crc:$7346db8a),
        (n:'b009.bin';l:$2000;p:$12000;crc:$b78714fc),(n:'b005.bin';l:$2000;p:$14000;crc:$b2557102),
        (n:'b008.bin';l:$2000;p:$16000;crc:$c85aba0e),(n:'br27';l:$100;p:0;crc:$f683c54a),
        (n:'br26';l:$100;p:$100;crc:$3ddbb6c4),(n:'br25';l:$100;p:$200;crc:$ba4a5651),());
        tndrcade:array[0..13] of tipo_roms=(
        (n:'ua0-4.u19';l:$20000;p:0;crc:$73bd63eb),(n:'ua0-2.u17';l:$20000;p:$1;crc:$e96194b1),
        (n:'ua0-3.u18';l:$20000;p:$40000;crc:$0a7b1c41),(n:'ua0-1.u16';l:$20000;p:$40001;crc:$fa906626),
        (n:'ua0-10.u12';l:$40000;p:0;crc:$aa7b6757),(n:'ua0-11.u13';l:$40000;p:$40000;crc:$11eaf931),
        (n:'ua0-12.u14';l:$40000;p:$80000;crc:$00b5381c),(n:'ua0-13.u15';l:$40000;p:$c0000;crc:$8f9a0ed3),
        (n:'ua0-6.u8';l:$40000;p:$100000;crc:$14ecc7bb),(n:'ua0-7.u9';l:$40000;p:$140000;crc:$ff1a4e68),
        (n:'ua0-8.u10';l:$40000;p:$180000;crc:$936e1884),(n:'ua0-9.u11';l:$40000;p:$1c0000;crc:$e812371c),
        (n:'ua10-5.u24';l:$20000;p:0;crc:$8eff6122),());
        twineagl:array [0..12] of tipo_roms=((n:'ua2-1';l:$80000;p:0;crc:$5c3fe531),(n:'ua2-2';l:$2000;p:0;crc:$783ca84e),
        (n:'ua2-4';l:$40000;p:0;crc:$8b7532d6),(n:'ua2-3';l:$40000;p:$1;crc:$1124417a),
        (n:'ua2-6';l:$40000;p:$80000;crc:$99d8dbba),(n:'ua2-5';l:$40000;p:$80001;crc:$6e450d28),
        (n:'ua2-7';l:$80000;p:0;crc:$fce56907),(n:'ua2-8';l:$80000;p:$1;crc:$7d3a8d73),
        (n:'ua2-9';l:$80000;p:$100000;crc:$a451eae9),(n:'ua2-10';l:$80000;p:$100001;crc:$5bbe1f56),
        (n:'ua2-11';l:$80000;p:$80000;crc:$624e6057),(n:'ua2-12';l:$80000;p:$80000;crc:$3068ff64),());
        thunderl:array[0..8] of tipo_roms=(
        (n:'m4';l:$8000;p:0;crc:$1e6b9462),(n:'m5';l:$8000;p:$1;crc:$7e82793e),
        (n:'t17';l:$20000;p:0;crc:$599a632a),(n:'t16';l:$20000;p:$1;crc:$3aeef91c),
        (n:'t15';l:$20000;p:$40000;crc:$b97a7b56),(n:'t14';l:$20000;p:$40001;crc:$79c707be),
        (n:'r28';l:$80000;p:0;crc:$a043615d),(n:'r27';l:$80000;p:$80000;crc:$cb8425a3),());
        mspactwin:array[0..8] of tipo_roms=(
        (n:'m27256.bin';l:$8000;p:0;crc:$77a99184),(n:'4__2716.5d';l:$800;p:0;crc:$483c1d1c),
        (n:'2__2716.5g';l:$800;p:$800;crc:$c08d73a2),(n:'3__2516.5f';l:$800;p:$1000;crc:$22b0188a),
        (n:'1__2516.5j';l:$800;p:$1800;crc:$0a8c46a0),(n:'mb7051.8h';l:$20;p:0;crc:$ff344446),
        (n:'82s129.4a';l:$100;p:$20;crc:$a8202d0d),(n:'mb7052.1k';l:$100;p:0;crc:$a9cc86bf),());
        extrmatn:array[0..10] of tipo_roms=(
        (n:'b06-05.11c';l:$10000;p:0;crc:$918e1fe3),(n:'b06-06.9c';l:$10000;p:$10000;crc:$8842e105),
        (n:'b06-19.4e';l:$10000;p:0;crc:$8de43ed9),(n:'b06__14.1g';l:$800;p:0;crc:$28907072),
        (n:'b06-01.13a';l:$20000;p:0;crc:$d2afbf7e),(n:'b06-02.10a';l:$20000;p:$20000;crc:$e0c2757a),
        (n:'b06-03.7a';l:$20000;p:$40000;crc:$ee80ab9d),(n:'b06-04.4a';l:$20000;p:$60000;crc:$3697ace4),
        (n:'b06-09.15f';l:$200;p:0;crc:$f388b361),(n:'b06-08.17f';l:$200;p:$200;crc:$10c9aac3),());
        robokid:array[0..31] of tipo_roms=(
        (n:'robokid1.18j';l:$10000;p:0;crc:$378c21fc),(n:'robokid2.18k';l:$10000;p:$10000;crc:$ddef8c5a),
        (n:'robokid3.15k';l:$10000;p:$20000;crc:$05295ec3),(n:'robokid4.12k';l:$10000;p:$30000;crc:$3bc3977f),
        (n:'robokid.k7';l:$10000;p:0;crc:$f490a2e9),(n:'robokid.b9';l:$8000;p:0;crc:$fac59c3f),
        (n:'robokid.15f';l:$10000;p:0;crc:$ba61f5ab),(n:'robokid.16f';l:$10000;p:$10000;crc:$d9b399ce),
        (n:'robokid.17f';l:$10000;p:$20000;crc:$afe432b9),(n:'robokid.18f';l:$10000;p:$30000;crc:$a0aa2a84),
        (n:'robokid.19c';l:$10000;p:0;crc:$02220421),(n:'robokid.20c';l:$10000;p:$10000;crc:$02d59bc2),
        (n:'robokid.17d';l:$10000;p:$20000;crc:$2fa29b99),(n:'robokid.18d';l:$10000;p:$30000;crc:$ae15ce02),
        (n:'robokid.19d';l:$10000;p:$40000;crc:$784b089e),(n:'robokid.20d';l:$10000;p:$50000;crc:$b0b395ed),
        (n:'robokid.19f';l:$10000;p:$60000;crc:$0f9071c6),
        (n:'robokid.12c';l:$10000;p:0;crc:$0ab45f94),(n:'robokid.14c';l:$10000;p:$10000;crc:$029bbd4a),
        (n:'robokid.15c';l:$10000;p:$20000;crc:$7de67ebb),(n:'robokid.16c';l:$10000;p:$30000;crc:$53c0e582),
        (n:'robokid.17c';l:$10000;p:$40000;crc:$0cae5a1e),(n:'robokid.18c';l:$10000;p:$50000;crc:$56ac7c8a),
        (n:'robokid.15d';l:$10000;p:$60000;crc:$cd632a4d),(n:'robokid.16d';l:$10000;p:$70000;crc:$18d92b2b),
        (n:'robokid.12a';l:$10000;p:0;crc:$e64d1c10),(n:'robokid.14a';l:$10000;p:$10000;crc:$8f9371e4),
        (n:'robokid.15a';l:$10000;p:$20000;crc:$469204e7),(n:'robokid.16a';l:$10000;p:$30000;crc:$4e340815),
        (n:'robokid.17a';l:$10000;p:$40000;crc:$f0863106),(n:'robokid.18a';l:$10000;p:$50000;crc:$fdff7441),());
        docastle:array[0..12] of tipo_roms=(
        (n:'01p_a1.bin';l:$2000;p:0;crc:$17c6fc24),(n:'01n_a2.bin';l:$2000;p:$2000;crc:$1d2fc7f4),
        (n:'01l_a3.bin';l:$2000;p:$4000;crc:$71a70ba9),(n:'01k_a4.bin';l:$2000;p:$6000;crc:$479a745e),
        (n:'07n_a0.bin';l:$4000;p:0;crc:$f23b5cdb),(n:'01d.bin';l:$200;p:0;crc:$2747ca77),
        (n:'03a_a5.bin';l:$4000;p:0;crc:$0636b8f4),(n:'04m_a6.bin';l:$2000;p:0;crc:$3bbc9b26),
        (n:'04l_a7.bin';l:$2000;p:$2000;crc:$3dfaa9d1),(n:'04j_a8.bin';l:$2000;p:$4000;crc:$9afb16e9),
        (n:'04h_a9.bin';l:$2000;p:$6000;crc:$af24bce0),(n:'09c.bin';l:$200;p:0;crc:$066f52bc),());
        dorunrun:array[0..12] of tipo_roms=(
        (n:'2764.p1';l:$2000;p:0;crc:$95c86f8e),(n:'2764.l1';l:$2000;p:$4000;crc:$e9a65ba7),
        (n:'2764.k1';l:$2000;p:$6000;crc:$b1195d3d),(n:'2764.n1';l:$2000;p:$8000;crc:$6a8160d1),
        (n:'27128.p7';l:$4000;p:0;crc:$8b06d461),(n:'bprom2.bin';l:$200;p:0;crc:$2747ca77),
        (n:'27128.a3';l:$4000;p:0;crc:$4be96dcf),(n:'2764.m4';l:$2000;p:0;crc:$4bb231a0),
        (n:'2764.l4';l:$2000;p:$2000;crc:$0c08508a),(n:'2764.j4';l:$2000;p:$4000;crc:$79287039),
        (n:'2764.h4';l:$2000;p:$6000;crc:$523aa999),(n:'dorunrun.clr';l:$100;p:0;crc:$d5bab5d5),());
        dowild:array[0..12] of tipo_roms=(
        (n:'w1';l:$2000;p:0;crc:$097de78b),(n:'w3';l:$2000;p:$4000;crc:$fc6a1cbb),
        (n:'w4';l:$2000;p:$6000;crc:$8aac1d30),(n:'w2';l:$2000;p:$8000;crc:$0914ab69),
        (n:'w10';l:$4000;p:0;crc:$d1f37fba),(n:'8300b-2';l:$200;p:0;crc:$2747ca77),
        (n:'w5';l:$4000;p:0;crc:$b294b151),(n:'w6';l:$2000;p:0;crc:$57e0208b),
        (n:'w7';l:$2000;p:$2000;crc:$5001a6f7),(n:'w8';l:$2000;p:$4000;crc:$ec503251),
        (n:'w9';l:$2000;p:$6000;crc:$af7bd7eb),(n:'dowild.clr';l:$100;p:0;crc:$a703dea5),());
        jjack:array[0..12] of tipo_roms=(
        (n:'j1.bin';l:$2000;p:0;crc:$87f29bd2),(n:'j3.bin';l:$2000;p:$4000;crc:$35b0517e),
        (n:'j4.bin';l:$2000;p:$6000;crc:$35bb316a),(n:'j2.bin';l:$2000;p:$8000;crc:$dec52e80),
        (n:'j0.bin';l:$4000;p:0;crc:$ab042f04),(n:'bprom2.bin';l:$200;p:0;crc:$2747ca77),
        (n:'j5.bin';l:$4000;p:0;crc:$75038ff9),(n:'j6.bin';l:$2000;p:0;crc:$5937bd7b),
        (n:'j7.bin';l:$2000;p:$2000;crc:$cf8ae8e7),(n:'j8.bin';l:$2000;p:$4000;crc:$84f6fc8c),
        (n:'j9.bin';l:$2000;p:$6000;crc:$3f9bb09f),(n:'bprom1.bin';l:$200;p:0;crc:$2f0955f2),());
        kickridr:array[0..12] of tipo_roms=(
        (n:'k1';l:$2000;p:0;crc:$dfdd1ab4),(n:'k3';l:$2000;p:$4000;crc:$412244da),
        (n:'k4';l:$2000;p:$6000;crc:$a67dd2ec),(n:'k2';l:$2000;p:$8000;crc:$e193fb5c),
        (n:'k10';l:$4000;p:0;crc:$6843dbc0),(n:'8300b-2';l:$200;p:0;crc:$2747ca77),
        (n:'k5';l:$4000;p:0;crc:$3f7d7e49),(n:'k6';l:$2000;p:0;crc:$94252ed3),
        (n:'k7';l:$2000;p:$2000;crc:$7ef2420e),(n:'k8';l:$2000;p:$4000;crc:$29bed201),
        (n:'k9';l:$2000;p:$6000;crc:$847584d3),(n:'kickridr.clr';l:$100;p:0;crc:$73ec281c),());
        idsoccer:array[0..15] of tipo_roms=(
        (n:'id01';l:$2000;p:0;crc:$f1c3bf09),(n:'id02';l:$2000;p:$2000;crc:$184e6af0),
        (n:'id03';l:$2000;p:$6000;crc:$22524661),(n:'id04';l:$2000;p:$8000;crc:$e8cd95fd),
        (n:'id10';l:$4000;p:0;crc:$6c8b2037),(n:'id_8p';l:$200;p:0;crc:$2747ca77),
        (n:'id05';l:$4000;p:0;crc:$a57c7a11),(n:'id06';l:$8000;p:0;crc:$b42a6f4a),
        (n:'id07';l:$8000;p:$8000;crc:$fa2b1c77),(n:'id08';l:$8000;p:$10000;crc:$5e97eab9),
        (n:'id09';l:$8000;p:$18000;crc:$a2a69223),(n:'id_3d.clr';l:$200;p:0;crc:$a433ff62),
        (n:'is1';l:$4000;p:0;crc:$9eb76196),(n:'is3';l:$4000;p:$8000;crc:$27bebba3),
        (n:'is4';l:$4000;p:$c000;crc:$dd5ffaa2),());
        ccastles:array[0..11] of tipo_roms=(
        (n:'136022-403.1k';l:$2000;p:$0;crc:$81471ae5),(n:'136022-404.1l';l:$2000;p:$2000;crc:$820daf29),
        (n:'136022-405.1n';l:$2000;p:$4000;crc:$4befc296),(n:'136022-102.1h';l:$2000;p:$6000;crc:$f6ccfbd4),
        (n:'136022-101.1f';l:$2000;p:$8000;crc:$e2e17236),(n:'136022-106.8d';l:$2000;p:$0;crc:$9d1d89fc),
        (n:'136022-107.8b';l:$2000;p:$2000;crc:$39960b7d),(n:'82s129-136022-108.7k';l:$100;p:$0;crc:$6ed31e3b),
        (n:'82s129-136022-109.6l';l:$100;p:$100;crc:$b3515f1a),(n:'82s129-136022-110.11l';l:$100;p:$200;crc:$068bdc7e),
        (n:'82s129-136022-111.10k';l:$100;p:$300;crc:$c29c18d9),());
        flower:array[0..17] of tipo_roms=(
        (n:'1.5j';l:$8000;p:0;crc:$a4c3af78),(n:'2.5f';l:$8000;p:0;crc:$7c7ee2d8),
        (n:'3.d9';l:$4000;p:0;crc:$8866c2b0),(n:'10.13e';l:$2000;p:0;crc:$62f9b28c),
        (n:'8.10e';l:$2000;p:0;crc:$f85eb20f),(n:'6.7e';l:$2000;p:$2000;crc:$3e97843f),
        (n:'9.12e';l:$2000;p:$4000;crc:$f1d9915e),(n:'15.9e';l:$2000;p:$6000;crc:$1cad9f72),
        (n:'14.19e';l:$2000;p:0;crc:$11b491c5),(n:'13.17e';l:$2000;p:$2000;crc:$ea743986),
        (n:'12.16e';l:$2000;p:$4000;crc:$e3779f7f),(n:'11.14e';l:$2000;p:$6000;crc:$8801b34f),
        (n:'4.12a';l:$8000;p:0;crc:$851ed9fd),(n:'5.16a';l:$4000;p:0;crc:$42fa2853),
        (n:'82s129.k3';l:$100;p:0;crc:$5aab7b41),(n:'82s129.k2';l:$100;p:$200;crc:$ababb072),
        (n:'82s129.k1';l:$100;p:$300;crc:$d311ed0d),());
        slyspy:array[0..16] of tipo_roms=(
        (n:'fa14-4.17l';l:$10000;p:0;crc:$60f16e31),(n:'fa12-4.9l';l:$10000;p:$1;crc:$b9b9fdcf),
        (n:'fa15.19l';l:$10000;p:$20000;crc:$04a79266),(n:'fa13.11l';l:$10000;p:$20001;crc:$641cc4b3),
        (n:'fa05.11a';l:$8000;p:0;crc:$09802924),(n:'fa04.9a';l:$8000;p:$8000;crc:$ec25b895),
        (n:'fa10.5h';l:$10000;p:$0;crc:$dfd2ff25),(n:'fa11.11k';l:$20000;p:0;crc:$4e547bad),
        (n:'fa07.17a';l:$10000;p:$0;crc:$e932268b),(n:'fa06.15a';l:$10000;p:$10000;crc:$c4dd38c0),
        (n:'fa09.22a';l:$20000;p:$0;crc:$1395e9be),(n:'fa08.21a';l:$20000;p:$20000;crc:$4d7464db),
        (n:'fa01.4a';l:$20000;p:$0;crc:$99b0cd92),(n:'fa03.7a';l:$20000;p:$20000;crc:$0e7ea74d),
        (n:'fa00.2a';l:$20000;p:$40000;crc:$f7df3fd7),(n:'fa02.5a';l:$20000;p:$60000;crc:$84e8da9d),());
        bouldash:array[0..18] of tipo_roms=(
        (n:'fw-15-2.17l';l:$10000;p:0;crc:$ca19a967),(n:'fw-12-2.9l';l:$10000;p:$1;crc:$242bdc2a),
        (n:'fw-16-2.19l';l:$10000;p:$20000;crc:$b7217265),(n:'fw-13-2.11l';l:$10000;p:$20001;crc:$19209ef4),
        (n:'fw-17-2.20l';l:$10000;p:$40000;crc:$78a632a1),(n:'fw-14-2.13l';l:$10000;p:$40001;crc:$69b6112d),
        (n:'fn-04';l:$10000;p:0;crc:$40f5a760),(n:'fn-05';l:$10000;p:$20000;crc:$824f2168),
        (n:'fn-10';l:$10000;p:$0;crc:$c74106e7),(n:'fn-11';l:$10000;p:0;crc:$990fd8d9),
        (n:'fn-07';l:$10000;p:$0;crc:$eac6a3b3),(n:'fn-06';l:$10000;p:$10000;crc:$3feee292),
        (n:'fn-09';l:$20000;p:$0;crc:$c2b27bd2),(n:'fn-08';l:$20000;p:$20000;crc:$5ac97178),
        (n:'fn-01';l:$10000;p:$0;crc:$9333121b),(n:'fn-03';l:$10000;p:$10000;crc:$254ba60f),
        (n:'fn-00';l:$10000;p:$20000;crc:$ec18d098),(n:'fn-02';l:$10000;p:$30000;crc:$4f060cba),());
        sdodgeball:array[0..11] of tipo_roms=(
        (n:'22a-04.139';l:$10000;p:$0;crc:$66071fda),(n:'22j5-0.33';l:$8000;p:$8000;crc:$c31e264e),
        (n:'22ja-0.162';l:$4000;p:$c000;crc:$7162a97b),(n:'22a-4.121';l:$20000;p:$0;crc:$acc26051),
        (n:'22a-3.107';l:$20000;p:$20000;crc:$10bb800d),(n:'22a-1.2';l:$20000;p:$0;crc:$3bd1c3ec),
        (n:'22a-2.35';l:$20000;p:$20000;crc:$409e1be1),(n:'22j6-0.83';l:$10000;p:$0;crc:$744a26e3),
        (n:'22j7-0.82';l:$10000;p:$10000;crc:$2fa1de21),(n:'mb7132e.158';l:$400;p:$0;crc:$7e623722),
        (n:'mb7122e.159';l:$400;p:$400;crc:$69706e8d),());
        senjyo:array[0..20] of tipo_roms=(
        (n:'08m_05t.bin';l:$2000;p:0;crc:$b1f3544d),(n:'08k_04t.bin';l:$2000;p:$2000;crc:$e34468a8),
        (n:'08j_03t.bin';l:$2000;p:$4000;crc:$c33aedee),(n:'08f_02t.bin';l:$2000;p:$6000;crc:$0ef4db9e),
        (n:'02h_01t.bin';l:$2000;p:0;crc:$c1c24455),(n:'08h_08b.bin';l:$1000;p:0;crc:$0c875994),
        (n:'08f_07b.bin';l:$1000;p:$1000;crc:$497bea8e),(n:'08d_06b.bin';l:$1000;p:$2000;crc:$4ef69b00),
        (n:'05n_16m.bin';l:$1000;p:0;crc:$0d3e00fb),(n:'05k_15m.bin';l:$2000;p:$2000;crc:$93442213),
        (n:'07n_18m.bin';l:$1000;p:0;crc:$d50fced3),(n:'07k_17m.bin';l:$2000;p:$2000;crc:$10c3a5f0),
        (n:'09n_20m.bin';l:$1000;p:0;crc:$54cb8126),(n:'09k_19m.bin';l:$2000;p:$1000;crc:$373e047c),
        (n:'08p_13b.bin';l:$2000;p:0;crc:$40127efd),(n:'08s_14b.bin';l:$2000;p:$2000;crc:$42648ffa),
        (n:'08m_11b.bin';l:$2000;p:$4000;crc:$ccc4680b),(n:'08n_12b.bin';l:$2000;p:$6000;crc:$742fafed),
        (n:'08j_09b.bin';l:$2000;p:$8000;crc:$1ee63b5c),(n:'08k_10b.bin';l:$2000;p:$a000;crc:$a9f41ec9),());
        baluba:array[0..18] of tipo_roms=(
        (n:'0';l:$4000;p:0;crc:$0e2ebe32),(n:'1';l:$4000;p:$4000;crc:$cde97076),
        (n:'15';l:$1000;p:0;crc:$3dda0d84),(n:'16';l:$1000;p:$1000;crc:$3ebc79d8),
        (n:'17';l:$1000;p:$2000;crc:$c4430deb),(n:'9';l:$2000;p:0;crc:$90f88c43),
        (n:'10';l:$2000;p:$2000;crc:$ab117070),(n:'11';l:$2000;p:$4000;crc:$e13b44b0),
        (n:'12';l:$2000;p:0;crc:$a6541c8d),(n:'13';l:$2000;p:$2000;crc:$afccdd18),
        (n:'14';l:$2000;p:$4000;crc:$69542e65),(n:'8';l:$1000;p:0;crc:$31e97ef9),
        (n:'7';l:$1000;p:$1000;crc:$5915c5e2),(n:'6';l:$1000;p:$2000;crc:$ad6881da),
        (n:'2';l:$2000;p:0;crc:$441fbc64),(n:'5';l:$4000;p:0;crc:$3b6b6e96),
        (n:'4';l:$4000;p:$4000;crc:$dd954124),(n:'3';l:$4000;p:$8000;crc:$7ac24983),());
        joust:array[0..13] of tipo_roms=(
        (n:'joust_rom_10b_3006-22.a7';l:$1000;p:$0;crc:$3f1c4f89),(n:'joust_rom_11b_3006-23.c7';l:$1000;p:$1000;crc:$ea48b359),
        (n:'joust_rom_12b_3006-24.e7';l:$1000;p:$2000;crc:$c710717b),(n:'joust_rom_1b_3006-13.e4';l:$1000;p:$3000;crc:$fe41b2af),
        (n:'joust_rom_2b_3006-14.c4';l:$1000;p:$4000;crc:$501c143c),(n:'joust_rom_3b_3006-15.a4';l:$1000;p:$5000;crc:$43f7161d),
        (n:'joust_rom_4b_3006-16.e5';l:$1000;p:$6000;crc:$db5571b6),(n:'joust_rom_5b_3006-17.c5';l:$1000;p:$7000;crc:$c686bb6b),
        (n:'joust_rom_6b_3006-18.a5';l:$1000;p:$8000;crc:$fac5f2cf),(n:'joust_rom_7b_3006-19.e6';l:$1000;p:$9000;crc:$81418240),
        (n:'joust_rom_8b_3006-20.c6';l:$1000;p:$a000;crc:$ba5359ba),(n:'joust_rom_9b_3006-21.a6';l:$1000;p:$b000;crc:$39643147),
        (n:'video_sound_rom_4_std_780.ic12';l:$1000;p:$f000;crc:$f1835bdd),());
        robotron:array[0..13] of tipo_roms=(
        (n:'2084_rom_10b_3005-22.a7';l:$1000;p:$0;crc:$13797024),(n:'2084_rom_11b_3005-23.c7';l:$1000;p:$1000;crc:$7e3c1b87),
        (n:'2084_rom_12b_3005-24.e7';l:$1000;p:$2000;crc:$645d543e),(n:'2084_rom_1b_3005-13.e4';l:$1000;p:$3000;crc:$66c7d3ef),
        (n:'2084_rom_2b_3005-14.c4';l:$1000;p:$4000;crc:$5bc6c614),(n:'2084_rom_3b_3005-15.a4';l:$1000;p:$5000;crc:$e99a82be),
        (n:'2084_rom_4b_3005-16.e5';l:$1000;p:$6000;crc:$afb1c561),(n:'2084_rom_5b_3005-17.c5';l:$1000;p:$7000;crc:$62691e77),
        (n:'2084_rom_6b_3005-18.a5';l:$1000;p:$8000;crc:$bd2c853d),(n:'2084_rom_7b_3005-19.e6';l:$1000;p:$9000;crc:$49ac400c),
        (n:'2084_rom_8b_3005-20.c6';l:$1000;p:$a000;crc:$3a96e88c),(n:'2084_rom_9b_3005-21.a6';l:$1000;p:$b000;crc:$b124367b),
        (n:'video_sound_rom_3_std_767.ic12';l:$1000;p:$f000;crc:$c56c1d28),());
        //Stargate
        stargate:array[0..13] of tipo_roms=(
        (n:'stargate_rom_10-a_3002-10.a7';l:$1000;p:$0;crc:$60b07ff7),(n:'stargate_rom_11-a_3002-11.c7';l:$1000;p:$1000;crc:$7d2c5daf),
        (n:'stargate_rom_12-a_3002-12.e7';l:$1000;p:$2000;crc:$a0396670),(n:'stargate_rom_1-a_3002-1.e4';l:$1000;p:$3000;crc:$88824d18),
        (n:'stargate_rom_2-a_3002-2.c4';l:$1000;p:$4000;crc:$afc614c5),(n:'stargate_rom_3-a_3002-3.a4';l:$1000;p:$5000;crc:$15077a9d),
        (n:'stargate_rom_4-a_3002-4.e5';l:$1000;p:$6000;crc:$a8b4bf0f),(n:'stargate_rom_5-a_3002-5.c5';l:$1000;p:$7000;crc:$2d306074),
        (n:'stargate_rom_6-a_3002-6.a5';l:$1000;p:$8000;crc:$53598dde),(n:'stargate_rom_7-a_3002-7.e6';l:$1000;p:$9000;crc:$23606060),
        (n:'stargate_rom_8-a_3002-8.c6';l:$1000;p:$a000;crc:$4ec490c7),(n:'stargate_rom_9-a_3002-9.a6';l:$1000;p:$b000;crc:$88187b64),
        (n:'video_sound_rom_2_std_744.ic12';l:$800;p:$f800;crc:$2fcf6c4d),());
        tapper:array[0..18] of tipo_roms=(
        (n:'tapper_c.p.u._pg_0_1c_1-27-84.1c';l:$4000;p:0;crc:$bb060bb0),(n:'tapper_c.p.u._pg_1_2c_1-27-84.2c';l:$4000;p:$4000;crc:$fd9acc22),
        (n:'tapper_c.p.u._pg_2_3c_1-27-84.3c';l:$4000;p:$8000;crc:$b3755d41),(n:'tapper_c.p.u._pg_3_4c_1-27-84.4c';l:$2000;p:$c000;crc:$77273096),
        (n:'tapper_sound_snd_0_a7_12-7-83.a7';l:$1000;p:0;crc:$0e8bb9d5),(n:'tapper_sound_snd_1_a8_12-7-83.a8';l:$1000;p:$1000;crc:$0cf0e29b),
        (n:'tapper_sound_snd_2_a9_12-7-83.a9';l:$1000;p:$2000;crc:$31eb6dc6),(n:'tapper_sound_snd_3_a10_12-7-83.a10';l:$1000;p:$3000;crc:$01a9be6a),
        (n:'tapper_c.p.u._bg_1_6f_12-7-83.6f';l:$4000;p:0;crc:$2a30238c),(n:'tapper_c.p.u._bg_0_5f_12-7-83.5f';l:$4000;p:$4000;crc:$394ab576),
        (n:'tapper_video_fg_1_a7_12-7-83.a7';l:$4000;p:0;crc:$32509011),(n:'tapper_video_fg_0_a8_12-7-83.a8';l:$4000;p:$4000;crc:$8412c808),
        (n:'tapper_video_fg_3_a5_12-7-83.a5';l:$4000;p:$8000;crc:$818fffd4),(n:'tapper_video_fg_2_a6_12-7-83.a6';l:$4000;p:$c000;crc:$67e37690),
        (n:'tapper_video_fg_5_a3_12-7-83.a3';l:$4000;p:$10000;crc:$800f7c8a),(n:'tapper_video_fg_4_a4_12-7-83.a4';l:$4000;p:$14000;crc:$32674ee6),
        (n:'tapper_video_fg_7_a1_12-7-83.a1';l:$4000;p:$18000;crc:$070b4c81),(n:'tapper_video_fg_6_a2_12-7-83.a2';l:$4000;p:$1c000;crc:$a37aef36),());
        arkanoid:array[0..9] of tipo_roms=(
        (n:'a75-01-1.ic17';l:$8000;p:$0;crc:$5bcda3b0),(n:'a75-11.ic16';l:$8000;p:$8000;crc:$eafd7191),
        (n:'a75__06.ic14';l:$800;p:$0;crc:$0be83647),(n:'a75-03.ic64';l:$8000;p:0;crc:$038b74ba),
        (n:'a75-04.ic63';l:$8000;p:$8000;crc:$71fae199),(n:'a75-05.ic62';l:$8000;p:$10000;crc:$c76374e2),
        (n:'a75-07.ic24';l:$200;p:$0;crc:$0af8b289),(n:'a75-08.ic23';l:$200;p:$200;crc:$abb002fb),
        (n:'a75-09.ic22';l:$200;p:$400;crc:$a7c6c277),());
        sidearms:array[0..23] of tipo_roms=(
        (n:'sa03.bin';l:$8000;p:0;crc:$e10fe6a0),(n:'a_14e.rom';l:$8000;p:$8000;crc:$4925ed03),
        (n:'a_12e.rom';l:$8000;p:$10000;crc:$81d0ece7),(n:'a_04k.rom';l:$8000;p:0;crc:$34efe2d2),
        (n:'b_11j.rom';l:$8000;p:0;crc:$134dc35b),(n:'a_10j.rom';l:$4000;p:0;crc:$651fef75),
        (n:'b_13d.rom';l:$8000;p:0;crc:$3c59afe1),(n:'b_13e.rom';l:$8000;p:$8000;crc:$64bc3b77),
        (n:'b_13f.rom';l:$8000;p:$10000;crc:$e6bcea6f),(n:'b_13g.rom';l:$8000;p:$18000;crc:$c71a3053),
        (n:'b_14d.rom';l:$8000;p:$20000;crc:$826e8a97),(n:'b_14e.rom';l:$8000;p:$28000;crc:$6cfc02a4),
        (n:'b_14f.rom';l:$8000;p:$30000;crc:$9b9f6730),(n:'b_14g.rom';l:$8000;p:$38000;crc:$ef6af630),
        (n:'b_11b.rom';l:$8000;p:0;crc:$eb6f278c),(n:'b_13b.rom';l:$8000;p:$8000;crc:$e91b4014),
        (n:'b_11a.rom';l:$8000;p:$10000;crc:$2822c522),(n:'b_13a.rom';l:$8000;p:$18000;crc:$3e8a9f75),
        (n:'b_12b.rom';l:$8000;p:$20000;crc:$86e43eda),(n:'b_14b.rom';l:$8000;p:$28000;crc:$076e92d1),
        (n:'b_12a.rom';l:$8000;p:$30000;crc:$ce107f3c),(n:'b_14a.rom';l:$8000;p:$38000;crc:$dba06076),
        (n:'b_03d.rom';l:$8000;p:0;crc:$6f348008),());
        speedr:array[0..28] of tipo_roms=(
        (n:'rc04.14e';l:$8000;p:$0;crc:$a68ce89c),(n:'rc03.13e';l:$8000;p:$8000;crc:$87bda812),
        (n:'rc02.12e';l:$8000;p:$10000;crc:$d8609cca),(n:'rc01.11e';l:$8000;p:$18000;crc:$27ec4776),
        (n:'rc09.14f';l:$8000;p:$20000;crc:$2146101d),(n:'rc08.13f';l:$8000;p:$28000;crc:$838369a6),
        (n:'rc07.12f';l:$8000;p:$30000;crc:$de785076),(n:'rc06.11f';l:$8000;p:$38000;crc:$a70f4fd4),
        (n:'rc05.2f';l:$8000;p:0;crc:$0177cebe),(n:'rc10.6g';l:$4000;p:0;crc:$adabe271),
        (n:'rc11.11a';l:$8000;p:$0;crc:$5fa042ba),(n:'rc12.13a';l:$8000;p:$8000;crc:$a2db64af),
        (n:'rc13.14a';l:$8000;p:$10000;crc:$f1df5499),(n:'rc14.15a';l:$8000;p:$18000;crc:$b22b31b3),
        (n:'rc15.11c';l:$8000;p:$20000;crc:$ca3a3af3),(n:'rc16.13c';l:$8000;p:$28000;crc:$c49a4a11),
        (n:'rc17.14c';l:$8000;p:$30000;crc:$aa80aaab),(n:'rc18.15c';l:$8000;p:$38000;crc:$ce67868e),
        (n:'rc20.15e';l:$8000;p:$0;crc:$3924c861),(n:'rc19.14e';l:$8000;p:$8000;crc:$ff8f9129),
        (n:'rc22.15f';l:$8000;p:$10000;crc:$ab64161c),(n:'rc21.14f';l:$8000;p:$18000;crc:$fd64bcd1),
        (n:'rc24.15h';l:$8000;p:$20000;crc:$c972af3e),(n:'rc23.14h';l:$8000;p:$28000;crc:$8c9abf57),
        (n:'rc26.15j';l:$8000;p:$30000;crc:$d4f1732f),(n:'rc25.14j';l:$8000;p:$38000;crc:$d2a4ea4f),
        (n:'63s141.12a';l:$100;p:$0;crc:$8421786f),(n:'63s141.13a';l:$100;p:$100;crc:$6048583f),());
        chinagate:array[0..14] of tipo_roms=(
        (n:'cgate51.bin';l:$20000;p:$0;crc:$439a3b19),(n:'23j4-0.48';l:$20000;p:$0;crc:$2914af38),
        (n:'23j0-0.40';l:$8000;p:$0;crc:$9ffcadb6),(n:'cgate18.bin';l:$20000;p:0;crc:$8d88d64d),
        (n:'chinagat_a-13';l:$10000;p:0;crc:$b745cac4),(n:'chinagat_a-12';l:$10000;p:$10000;crc:$3c864299),
        (n:'chinagat_a-15';l:$10000;p:$20000;crc:$2f268f37),(n:'chinagat_a-14';l:$10000;p:$30000;crc:$aef814c8),
        (n:'23j7-0.103';l:$20000;p:0;crc:$2f445030),(n:'23j8-0.102';l:$20000;p:$20000;crc:$237f725a),
        (n:'23j9-0.101';l:$20000;p:$40000;crc:$8caf6097),(n:'23ja-0.100';l:$20000;p:$60000;crc:$f678594f),
        (n:'23j1-0.53';l:$20000;p:0;crc:$f91f1001),(n:'23j2-0.52';l:$20000;p:$20000;crc:$8b6f26e9),());
        magmax:array[0..29] of tipo_roms=(
        (n:'1.3b';l:$4000;p:1;crc:$33793cbb),(n:'6.3d';l:$4000;p:$0;crc:$677ef450),
        (n:'2.5b';l:$4000;p:$8001;crc:$1a0c84df),(n:'7.5d';l:$4000;p:$8000;crc:$01c35e95),
        (n:'3.6b';l:$2000;p:$10001;crc:$d06e6cae),(n:'8.6d';l:$2000;p:$10000;crc:$790a82be),
        (n:'15.17b';l:$2000;p:0;crc:$19e7b983),(n:'16.18b';l:$2000;p:$2000;crc:$055e3126),
        (n:'17.3e';l:$2000;p:0;crc:$8e305b2e),(n:'18.5e';l:$2000;p:$2000;crc:$14c55a60),
        (n:'19.6e';l:$2000;p:$4000;crc:$fa4141d8),(n:'20.3g';l:$2000;p:$8000;crc:$6fa3918b),
        (n:'21.5g';l:$2000;p:$a000;crc:$dd52eda4),(n:'22.6g';l:$2000;p:$c000;crc:$4afc98ff),
        (n:'mag_e.10f';l:$100;p:0;crc:$75e4f06a),(n:'mag_d.10e';l:$100;p:$100;crc:$34b6a6e3),
        (n:'mag_a.10d';l:$100;p:$200;crc:$a7ea7718),(n:'mag_g.2e';l:$100;p:$300;crc:$830be358),
        (n:'mag_b.14d';l:$100;p:$400;crc:$a0fb7297),(n:'mag_c.15d';l:$100;p:$500;crc:$d84a6f78),
        (n:'4.18b';l:$2000;p:0;crc:$1550942e),(n:'5.20b';l:$2000;p:$1;crc:$3b93017f),
        (n:'9.18d';l:$2000;p:$4000;crc:$9ecc9ab8),(n:'10.20d';l:$2000;p:$6000;crc:$e2ff7293),
        (n:'11.15f';l:$2000;p:$8000;crc:$91f3edb6),(n:'12.17f';l:$2000;p:$a000;crc:$99771eff),
        (n:'13.18f';l:$2000;p:$c000;crc:$75f30159),(n:'14.20f';l:$2000;p:$e000;crc:$96babcba),
        (n:'23.15g';l:$2000;p:0;crc:$a7471da2),());
        srdmission:array[0..18] of tipo_roms=(
        (n:'5.t2';l:$4000;p:0;crc:$a682b48c),(n:'7.t3';l:$4000;p:$4000;crc:$1719c58c),
        (n:'1.t7';l:$4000;p:0;crc:$dc48595e),(n:'3.t8';l:$4000;p:$4000;crc:$216be1e8),
        (n:'15.4a';l:$1000;p:0;crc:$4961f7fd),(n:'17.9h';l:$2000;p:0;crc:$41211458),
        (n:'18.10h';l:$2000;p:$2000;crc:$740eccd4),(n:'16.11h';l:$2000;p:$4000;crc:$c1f4a5db),
        (n:'14.6a';l:$4000;p:0;crc:$3d4c0447),(n:'13.7a';l:$4000;p:$4000;crc:$22414a67),
        (n:'12.8a';l:$4000;p:$8000;crc:$61e34283),(n:'11.9a';l:$4000;p:$c000;crc:$bbbaffef),
        (n:'10.10a';l:$4000;p:$10000;crc:$de564f97),(n:'9.11a';l:$4000;p:$14000;crc:$890dc815),
        (n:'mr.1j';l:$100;p:0;crc:$110a436e),(n:'mg.1h';l:$100;p:$100;crc:$0fbfd9f0),
        (n:'mb.1f';l:$100;p:$200;crc:$a342890c),(n:'m2.5j';l:$20;p:$300;crc:$190a55ad),());
        airwolf:array[0..13] of tipo_roms=(
        (n:'b.2s';l:$8000;p:0;crc:$8c993cce),(n:'a.7s';l:$8000;p:0;crc:$a3c7af5c),
        (n:'f.4a';l:$1000;p:0;crc:$4df44ce9),(n:'09h_14.bin';l:$2000;p:0;crc:$25e57e1f),
        (n:'10h_13.bin';l:$2000;p:$2000;crc:$cf0de5e9),(n:'11h_12.bin';l:$2000;p:$4000;crc:$4050c048),
        (n:'e.6a';l:$8000;p:0;crc:$e8fbc7d2),(n:'d.8a';l:$8000;p:$8000;crc:$c5d4156b),
        (n:'c.10a';l:$8000;p:$10000;crc:$de91dfb1),(n:'01j.bin';l:$100;p:0;crc:$6a94b2a3),
        (n:'01h.bin';l:$100;p:$100;crc:$ec0923d3),(n:'01f.bin';l:$100;p:$200;crc:$ade97052),
        (n:'74s288-2.bin';l:$20;p:$300;crc:$190a55ad),());
        ambush:array[0..8] of tipo_roms=(
        (n:'a1.i7';l:$2000;p:0;crc:$31b85d9d),(n:'a2.g7';l:$2000;p:$2000;crc:$8328d88a),
        (n:'a3.f7';l:$2000;p:$4000;crc:$8db57ab5),(n:'a4.e7';l:$2000;p:$6000;crc:$4a34d2a4),
        (n:'fa1.m4';l:$2000;p:$0;crc:$ad10969e),(n:'fa2.n4';l:$2000;p:$2000;crc:$e7f134ba),
        (n:'a.bpr';l:$100;p:$0;crc:$5f27f511),(n:'b.bpr';l:$100;p:$100;crc:$1b03fd3b),());
        superduck:array[0..18] of tipo_roms=(
        (n:'5.u16n';l:$20000;p:0;crc:$837a559a),(n:'6.u16l';l:$20000;p:$1;crc:$508e9905),
        (n:'4.su6';l:$8000;p:0;crc:$d75863ea),(n:'3.cu15';l:$8000;p:0;crc:$b1cacca4),
        (n:'11.ul29';l:$20000;p:0;crc:$1b6958a4),(n:'12.ul30';l:$20000;p:$20000;crc:$3e6bd24b),
        (n:'13.ul31';l:$20000;p:$40000;crc:$bff7b7cd),(n:'14.ul32';l:$20000;p:$60000;crc:$97a7310b),
        (n:'7.uu29';l:$20000;p:0;crc:$f3251b20),(n:'8.uu30';l:$20000;p:$20000;crc:$03c60cbd),
        (n:'9.uu31';l:$20000;p:$40000;crc:$9b6d3430),(n:'10.uu32';l:$20000;p:$6000;crc:$beed2616),
        (n:'15.u1d';l:$20000;p:0;crc:$81bf1f27),(n:'16.u2d';l:$20000;p:1;crc:$9573d6ec),
        (n:'17.u1c';l:$20000;p:2;crc:$21ef14d4),(n:'18.u2c';l:$20000;p:3;crc:$33dd0674),
        (n:'2.su12';l:$20000;p:0;crc:$745d42fb),(n:'1.su13';l:$80000;p:$20000;crc:$7fb1ed42),());
        hangon:array[0..28] of tipo_roms=(
        (n:'epr-6918a.ic22';l:$8000;p:0;crc:$20b1c2b0),(n:'epr-6916a.ic8';l:$8000;p:$1;crc:$7d9db1bf),
        (n:'epr-6917a.ic20';l:$8000;p:$10000;crc:$fea12367),(n:'epr-6915a.ic6';l:$8000;p:$10001;crc:$ac883240),
        (n:'epr-6920.ic63';l:$8000;p:0;crc:$1c95013e),(n:'epr-6919.ic51';l:$8000;p:$1;crc:$6ca30d69),
        (n:'epr-6833.ic73';l:$4000;p:0;crc:$3b942f5f),(n:'epr-6841.ic38';l:$8000;p:0;crc:$54d295dc),
        (n:'epr-6842.ic23';l:$8000;p:$8000;crc:$f677b568),(n:'epr-6843.ic7';l:$8000;p:$10000;crc:$a257f0da),
        (n:'epr-6819.ic27';l:$8000;p:1;crc:$469dad07),(n:'epr-6820.ic34';l:$8000;p:0;crc:$87cbc6de),
        (n:'epr-6821.ic28';l:$8000;p:$10001;crc:$15792969),(n:'epr-6822.ic35';l:$8000;p:$10000;crc:$e9718de5),
        (n:'epr-6823.ic29';l:$8000;p:$20001;crc:$49422691),(n:'epr-6824.ic36';l:$8000;p:$20000;crc:$701deaa4),
        (n:'epr-6825.ic30';l:$8000;p:$30001;crc:$6e23c8b4),(n:'epr-6826.ic37';l:$8000;p:$30000;crc:$77d0de2c),
        (n:'epr-6827.ic31';l:$8000;p:$40001;crc:$7fa1bfb6),(n:'epr-6828.ic38';l:$8000;p:$40000;crc:$8e880c93),
        (n:'epr-6829.ic32';l:$8000;p:$50001;crc:$7ca0952d),(n:'epr-6830.ic39';l:$8000;p:$50000;crc:$b1a63aef),
        (n:'epr-6845.ic18';l:$8000;p:$60001;crc:$ba08c9b8),(n:'epr-6846.ic25';l:$8000;p:$60000;crc:$f21e57a3),
        (n:'epr-6840.ic108';l:$8000;p:0;crc:$581230e3),(n:'epr-6831.ic5';l:$8000;p:$0;crc:$cfef5481),
        (n:'epr-6832.ic6';l:$8000;p:$8000;crc:$4165aea5),(n:'epr-6844.ic123';l:$2000;p:0;crc:$e3ec7bd6),());
        enduror:array[0..49] of tipo_roms=(
        (n:'epr-7640a.ic97';l:$8000;p:0;crc:$1d1dc5d4),(n:'epr-7636a.ic84';l:$8000;p:$1;crc:$84131639),
        (n:'epr-7641.ic98';l:$8000;p:$10000;crc:$2503ae7c),(n:'epr-7637.ic85';l:$8000;p:$10001;crc:$82a27a8c),
        (n:'epr-7642.ic99';l:$8000;p:$20000;crc:$1c453bea),(n:'epr-7638.ic86';l:$8000;p:$20001;crc:$70544779),
        (n:'epr-7634a.ic54';l:$8000;p:0;crc:$aec83731),(n:'epr-7635a.ic67';l:$8000;p:$1;crc:$b2fce96f),
        (n:'epr-7682.ic58';l:$8000;p:$0;crc:$c4efbf48),(n:'epr-7633.ic1';l:$8000;p:0;crc:$6f146210),
        (n:'epr-7644.ic31';l:$8000;p:0;crc:$e7a4ff90),(n:'epr-7645.ic46';l:$8000;p:$8000;crc:$4caa0095),
        (n:'epr-7646.ic60';l:$8000;p:$10000;crc:$7e432683),(n:'317-0013a.key';l:$2000;p:0;crc:$a965b2da),
        (n:'epr-7678.ic36';l:$8000;p:0;crc:$9fb5e656),(n:'epr-7670.ic28';l:$8000;p:1;crc:$dbbe2f6e),
        (n:'epr-7662.ic18';l:$8000;p:2;crc:$cb0c13c5),(n:'epr-7654.ic8';l:$8000;p:3;crc:$2db6520d),
        (n:'epr-7677.ic35';l:$8000;p:$20000;crc:$7764765b),(n:'epr-7669.ic27';l:$8000;p:$20001;crc:$f9525faa),
        (n:'epr-7661.ic17';l:$8000;p:$20002;crc:$fe93a79b),(n:'epr-7653.ic7';l:$8000;p:$20003;crc:$46a52114),
        (n:'epr-7676.ic34';l:$8000;p:$40000;crc:$2e42e0d4),(n:'epr-7668.ic26';l:$8000;p:$40001;crc:$e115ce33),
        (n:'epr-7660.ic16';l:$8000;p:$40002;crc:$86dfbb68),(n:'epr-7652.ic6';l:$8000;p:$40003;crc:$2880cfdb),
        (n:'epr-7675.ic33';l:$8000;p:$60000;crc:$05cd2d61),(n:'epr-7667.ic25';l:$8000;p:$60001;crc:$923bde9d),
        (n:'epr-7659.ic15';l:$8000;p:$60002;crc:$629dc8ce),(n:'epr-7651.ic5';l:$8000;p:$60003;crc:$d7902bad),
        (n:'epr-7674.ic32';l:$8000;p:$80000;crc:$1a129acf),(n:'epr-7666.ic24';l:$8000;p:$80001;crc:$23697257),
        (n:'epr-7658.ic14';l:$8000;p:$80002;crc:$1677f24f),(n:'epr-7650.ic4';l:$8000;p:$80003;crc:$642635ec),
        (n:'epr-7673.ic31';l:$8000;p:$a0000;crc:$82602394),(n:'epr-7665.ic23';l:$8000;p:$a0001;crc:$12d77607),
        (n:'epr-7657.ic13';l:$8000;p:$a0002;crc:$8158839c),(n:'epr-7649.ic3';l:$8000;p:$a0003;crc:$4edba14c),
        (n:'epr-7672.ic30';l:$8000;p:$c0000;crc:$d11452f7),(n:'epr-7664.ic22';l:$8000;p:$c0001;crc:$0df2cfad),
        (n:'epr-7656.ic12';l:$8000;p:$c0002;crc:$6c741272),(n:'epr-7648.ic2';l:$8000;p:$c0003;crc:$983ea830),
        (n:'epr-7671.ic29';l:$8000;p:$e0000;crc:$b0c7fdc6),(n:'epr-7663.ic21';l:$8000;p:$e0001;crc:$2b0b8f08),
        (n:'epr-7655.ic11';l:$8000;p:$e0002;crc:$3433fe7b),(n:'epr-7647.ic1';l:$8000;p:$e0003;crc:$2e7fbec0),
        (n:'epr-7681.ic8';l:$8000;p:$0;crc:$bc0c4d12),(n:'epr-7680.ic7';l:$8000;p:$10000;crc:$627b3c8c),
        (n:'epr-6844.ic123';l:$2000;p:0;crc:$e3ec7bd6),());
        sharrier_roms:array[0..52] of tipo_roms=(
        (n:'epr-7188a.ic97';l:$8000;p:0;crc:$45e173c3),(n:'epr-7184a.ic84';l:$8000;p:$1;crc:$e1934a51),
        (n:'epr-7189.ic98';l:$8000;p:$10000;crc:$40b1309f),(n:'epr-7185.ic85';l:$8000;p:$10001;crc:$ce78045c),
        (n:'epr-7190.ic99';l:$8000;p:$20000;crc:$f6391091),(n:'epr-7186.ic86';l:$8000;p:$20001;crc:$79b367d7),
        (n:'epr-7191.ic100';l:$8000;p:$30000;crc:$6171e9d3),(n:'epr-7187.ic87';l:$8000;p:$30001;crc:$70cb72ef),
        (n:'epr-7182.ic54';l:$8000;p:0;crc:$d7c535b6),(n:'epr-7183.ic67';l:$8000;p:$1;crc:$a6153af8),
        (n:'epr-7234.ic73';l:$4000;p:0;crc:$d6397933),(n:'epr-7233.ic72';l:$4000;p:$4000;crc:$504e76d9),
        (n:'epr-7196.ic31';l:$8000;p:0;crc:$347fa325),(n:'epr-7197.ic46';l:$8000;p:$8000;crc:$39d98bd1),
        (n:'epr-7198.ic60';l:$8000;p:$10000;crc:$3da3ea6b),(n:'epr-6844.ic123';l:$2000;p:0;crc:$e3ec7bd6),
        (n:'epr-7230.ic36';l:$8000;p:0;crc:$93e2d264),(n:'epr-7222.ic28';l:$8000;p:1;crc:$edbf5fc3),
        (n:'epr-7214.ic18';l:$8000;p:2;crc:$e8c537d8),(n:'epr-7206.ic8';l:$8000;p:3;crc:$22844fa4),
        (n:'epr-7229.ic35';l:$8000;p:$20000;crc:$cd6e7500),(n:'epr-7221.ic27';l:$8000;p:$20001;crc:$41f25a9c),
        (n:'epr-7213.ic17';l:$8000;p:$20002;crc:$5bb09a67),(n:'epr-7205.ic7';l:$8000;p:$20003;crc:$dcaa2ebf),
        (n:'epr-7228.ic34';l:$8000;p:$40000;crc:$d5e15e66),(n:'epr-7220.ic26';l:$8000;p:$40001;crc:$ac62ae2e),
        (n:'epr-7212.ic16';l:$8000;p:$40002;crc:$9c782295),(n:'epr-7204.ic6';l:$8000;p:$40003;crc:$3711105c),
        (n:'epr-7227.ic33';l:$8000;p:$60000;crc:$60d7c1bb),(n:'epr-7219.ic25';l:$8000;p:$60001;crc:$f6330038),
        (n:'epr-7211.ic15';l:$8000;p:$60002;crc:$60737b98),(n:'epr-7203.ic5';l:$8000;p:$60003;crc:$70fb5ebb),
        (n:'epr-7226.ic32';l:$8000;p:$80000;crc:$6d7b5c97),(n:'epr-7218.ic24';l:$8000;p:$80001;crc:$cebf797c),
        (n:'epr-7210.ic14';l:$8000;p:$80002;crc:$24596a8b),(n:'epr-7202.ic4';l:$8000;p:$80003;crc:$b537d082),
        (n:'epr-7225.ic31';l:$8000;p:$a0000;crc:$5e784271),(n:'epr-7217.ic23';l:$8000;p:$a0001;crc:$510e5e10),
        (n:'epr-7209.ic13';l:$8000;p:$a0002;crc:$7a2dad15),(n:'epr-7201.ic3';l:$8000;p:$a0003;crc:$f5ba4e08),
        (n:'epr-7224.ic30';l:$8000;p:$c0000;crc:$ec42c9ef),(n:'epr-7216.ic22';l:$8000;p:$c0001;crc:$6d4a7d7a),
        (n:'epr-7208.ic12';l:$8000;p:$c0002;crc:$0f732717),(n:'epr-7200.ic2';l:$8000;p:$c0003;crc:$fc3bf8f3),
        (n:'epr-7223.ic29';l:$8000;p:$e0000;crc:$ed51fdc4),(n:'epr-7215.ic21';l:$8000;p:$e0001;crc:$dfe75f3d),
        (n:'epr-7207.ic11';l:$8000;p:$e0002;crc:$a2c07741),(n:'epr-7199.ic1';l:$8000;p:$e0003;crc:$b191e22f),
        (n:'epr-7181.ic2';l:$8000;p:0;crc:$b4740419),(n:'315-5163a.ic32';l:$1000;p:0;crc:$203dffeb),
        (n:'epr-7231.ic5';l:$8000;p:$0;crc:$871c6b14),(n:'epr-7232.ic6';l:$8000;p:$8000;crc:$4b59340c),());
        th64_roms:array[0..12] of tipo_roms=(
        (n:'64th_03.rom';l:$40000;p:0;crc:$ed6c6942),(n:'64th_02.rom';l:$40000;p:$1;crc:$0621ed1d),
        (n:'64th_08.rom';l:$10000;p:0;crc:$632be0c1),(n:'64th_07.rom';l:$10000;p:$1;crc:$13595d01),
        (n:'64th_01.rom';l:$80000;p:0;crc:$06222f90),(n:'64th_06.rom';l:$80000;p:0;crc:$2bfcdc75),
        (n:'64th_09.rom';l:$20000;p:0;crc:$a4a97db4),(n:'64th_05.rom';l:$80000;p:$0;crc:$a89a7020),
        (n:'64th_04.rom';l:$80000;p:$80000;crc:$98f83ef6),(n:'64th_11.rom';l:$20000;p:0;crc:$b0b8a65c),
        (n:'64th_10.rom';l:$40000;p:0;crc:$a3390561),(n:'pr91009.12';l:$200;p:0;crc:$c69423d6),());
        shadoww_roms:array[0..21] of tipo_roms=(
        (n:'shadowa_1.3s';l:$20000;p:0;crc:$8290d567),(n:'shadowa_2.4s';l:$20000;p:$1;crc:$f3f08921),
        (n:'gaiden_3.4b';l:$10000;p:0;crc:$75fd3e6a),(n:'gaiden_5.7a';l:$10000;p:0;crc:$8d4035f7),
        (n:'14.3a';l:$20000;p:0;crc:$1ecfddaa),(n:'15.3b';l:$20000;p:$20000;crc:$1291a696),
        (n:'16.1a';l:$20000;p:$40000;crc:$140b47ca),(n:'17.1b';l:$20000;p:$60000;crc:$7638cccb),
        (n:'18.6a';l:$20000;p:0;crc:$3fadafd6),(n:'19.6b';l:$20000;p:$20000;crc:$ddae9d5b),
        (n:'20.4b';l:$20000;p:$40000;crc:$08cf7a93),(n:'21.4b';l:$20000;p:$60000;crc:$1ac892f5),
        (n:'6.3m';l:$20000;p:0;crc:$e7ccdf9f),(n:'7.1m';l:$20000;p:$1;crc:$016bec95),
        (n:'8.3n';l:$20000;p:$40000;crc:$7ef7f880),(n:'9.1n';l:$20000;p:$40001;crc:$6e9b7fd3),
        (n:'10.3r';l:$20000;p:$80000;crc:$a6451dec),(n:'11.1r';l:$20000;p:$80001;crc:$7fbfdf5e),
        (n:'12.3s';l:$20000;p:$c0000;crc:$94a836d8),(n:'13.1s';l:$20000;p:$c0001;crc:$e9caea3b),
        (n:'4.4a';l:$20000;p:0;crc:$b0e0faf9),());
        wildfang_roms:array[0..12] of tipo_roms=(
        (n:'1.3st';l:$20000;p:0;crc:$ab876c9b),(n:'2.5st';l:$20000;p:$1;crc:$1dc74b3b),
        (n:'tkni3.bin';l:$10000;p:0;crc:$15623ec7),(n:'tkni5.bin';l:$10000;p:0;crc:$5ed15896),
        (n:'14.3a';l:$20000;p:0;crc:$0d20c10c),(n:'15.3b';l:$20000;p:$20000;crc:$3f40a6b4),
        (n:'16.1a';l:$20000;p:$40000;crc:$0f31639e),(n:'17.1b';l:$20000;p:$60000;crc:$f32c158e),
        (n:'tkni6.bin';l:$80000;p:0;crc:$f68fafb1),(n:'tkni9.bin';l:$80000;p:0;crc:$d22f4239),
        (n:'tkni8.bin';l:$80000;p:$1;crc:$4931b184),(n:'tkni4.bin';l:$20000;p:0;crc:$a7a1dbcf),());
        raiden_roms:array[0..13] of tipo_roms=(
        (n:'1.u0253';l:$10000;p:0;crc:$a4b12785),(n:'2.u0252';l:$10000;p:$1;crc:$17640bd5),
        (n:'3.u022';l:$20000;p:$20000;crc:$f6af09d0),(n:'4j.u023';l:$20000;p:$20001;crc:$505c4c5d),
        (n:'5.u042';l:$20000;p:0;crc:$ed03562e),(n:'6.u043';l:$20000;p:1;crc:$a19d5b5d),
        (n:'8.u212';l:$10000;p:0;crc:$cbe055c7),(n:'9';l:$8000;p:1;crc:$1922b25e),
        (n:'10';l:$8000;p:0;crc:$5f90786a),(n:'sei420';l:$80000;p:0;crc:$da151f0b),
        (n:'sei430';l:$80000;p:0;crc:$ac1f57ac),(n:'sei440';l:$80000;p:0;crc:$946d7bde),
        (n:'7.u203';l:$10000;p:0;crc:$8f927822),());
        twins_roms:array[0..3] of tipo_roms=(
        (n:'2.u8';l:$80000;p:$0;crc:$1ec942b0),(n:'1.u9';l:$80000;p:$1;crc:$4417ff34),
        (n:'24c02.u15';l:$100;p:$0;crc:$2ff05b0e),());
        twinsed1_roms:array[0..3] of tipo_roms=(
        (n:'1.bin';l:$80000;p:$0;crc:$d5ef7b0d),(n:'2.bin';l:$80000;p:$1;crc:$8a5392f4),
        (n:'24c02.u15';l:$100;p:$0;crc:$2ff05b0e),());
        hotblock_roms:array[0..2] of tipo_roms=(
        (n:'hotblk5.ic4';l:$80000;p:$0;crc:$5f90f776),(n:'hotblk6.ic5';l:$80000;p:$80000;crc:$3176d231),());
        missile_roms:array[0..7] of tipo_roms=(
        (n:'035820-02.h1';l:$800;p:$5000;crc:$7a62ce6a),(n:'035821-02.jk1';l:$800;p:$5800;crc:$df3bd57f),
        (n:'035822-03e.kl1';l:$800;p:$6000;crc:$1a2f599a),(n:'035823-02.ln1';l:$800;p:$6800;crc:$82e552bb),
        (n:'035824-02.np1';l:$800;p:$7000;crc:$606e42e0),(n:'035825-02.r1';l:$800;p:$7800;crc:$f752eaeb),
        (n:'035826-01.l6';l:$20;p:0;crc:$86a22140),());
        suprmatk_roms:array[0..9] of tipo_roms=(
        (n:'035820-02.c1';l:$800;p:$5000;crc:$7a62ce6a),(n:'035821-02.b1';l:$800;p:$5800;crc:$df3bd57f),
        (n:'035822-02.a1';l:$800;p:$6000;crc:$a1cd384a),(n:'035823-02.a5';l:$800;p:$6800;crc:$82e552bb),
        (n:'035824-02.b5';l:$800;p:$7000;crc:$606e42e0),(n:'035825-02.c5';l:$800;p:$7800;crc:$f752eaeb),
        (n:'e0.d5';l:$800;p:$8000;crc:$d0b20179),(n:'e1.e5';l:$800;p:$8800;crc:$c6c818a3),
        (n:'035826-01.l6';l:$20;p:0;crc:$86a22140),());
        szaxxon_roms:array[0..17] of tipo_roms=(
        (n:'1804e.u27';l:$2000;p:0;crc:$af7221da),(n:'1803e.u28';l:$2000;p:$2000;crc:$1b90fb2a),
        (n:'1802e.u29';l:$1000;p:$4000;crc:$07258b4a),(n:'pr-5168.u98';l:$100;p:0;crc:$15727a9f),
        (n:'pr-5167.u72';l:$100;p:$100;crc:$deaa21f7),(n:'1815b.u68';l:$800;p:0;crc:$bccf560c),
        (n:'1816b.u69';l:$800;p:$800;crc:$d28c628b),(n:'1807b.u113';l:$2000;p:0;crc:$f51af375),
        (n:'1806b.u112';l:$2000;p:$2000;crc:$a7de021d),(n:'1805b.u111';l:$2000;p:$4000;crc:$5bfb3b04),
        (n:'1812e.u77';l:$2000;p:0;crc:$1503ae41),(n:'1813e.u78';l:$2000;p:$2000;crc:$3b53d83f),
        (n:'1814e.u79';l:$2000;p:$4000;crc:$581e8793),(n:'1809b.u91';l:$2000;p:0;crc:$dd1b52df),
        (n:'1808b.u90';l:$2000;p:$2000;crc:$b5bc07f0),(n:'1811b.u93';l:$2000;p:$4000;crc:$68e84174),
        (n:'1810b.u92';l:$2000;p:$6000;crc:$a509994b),());
        futspy_roms:array[0..17] of tipo_roms=(
        (n:'fs_snd.u27';l:$2000;p:0;crc:$7578fe7f),(n:'fs_snd.u28';l:$2000;p:$2000;crc:$8ade203c),
        (n:'fs_snd.u29';l:$1000;p:$4000;crc:$734299c3),(n:'futrprom.u98';l:$100;p:0;crc:$9ba2acaa),
        (n:'futrprom.u72';l:$100;p:$100;crc:$f9e26790),(n:'fs_snd.u68';l:$800;p:0;crc:$305fae2d),
        (n:'fs_snd.u69';l:$800;p:$800;crc:$3c5658c0),(n:'fs_vid.u113';l:$2000;p:0;crc:$36d2bdf6),
        (n:'fs_vid.u112';l:$2000;p:$2000;crc:$3740946a),(n:'fs_vid.u111';l:$2000;p:$4000;crc:$4cd4df98),
        (n:'fs_vid.u77';l:$4000;p:0;crc:$1b93c9ec),(n:'fs_vid.u78';l:$4000;p:$4000;crc:$50e55262),
        (n:'fs_vid.u79';l:$4000;p:$8000;crc:$bfb02e3e),(n:'fs_vid.u91';l:$2000;p:0;crc:$86da01f4),
        (n:'fs_vid.u90';l:$2000;p:$2000;crc:$2bd41d2d),(n:'fs_vid.u93';l:$2000;p:$4000;crc:$b82b4997),
        (n:'fs_vid.u92';l:$2000;p:$6000;crc:$af4015af),());
        milliped_roms:array[0..6] of tipo_roms=(
        (n:'136013-104.mn1';l:$1000;p:$4000;crc:$40711675),(n:'136013-103.l1';l:$1000;p:$5000;crc:$fb01baf2),
        (n:'136013-102.jk1';l:$1000;p:$6000;crc:$62e137e0),(n:'136013-101.h1';l:$1000;p:$7000;crc:$46752c7d),
        (n:'136013-107.r5';l:$800;p:0;crc:$68c3437a),(n:'136013-106.p5';l:$800;p:$800;crc:$f4468045),());
        gaplus_roms:array[0..19] of tipo_roms=(
        (n:'gp2-4.8d';l:$2000;p:$a000;crc:$e525d75d),(n:'gp2-3b.8c';l:$2000;p:$c000;crc:$d77840a4),
        (n:'gp2-2b.8b';l:$2000;p:$e000;crc:$b3cb90db),(n:'gp2-8.11d';l:$2000;p:$a000;crc:$42b9fd7c),
        (n:'gp2-7.11c';l:$2000;p:$c000;crc:$0621f7df),(n:'gp2-6.11b';l:$2000;p:$e000;crc:$75b18652),
        (n:'gp2-1.4b';l:$2000;p:$e000;crc:$ed8aa206),(n:'gp2-5.8s';l:$2000;p:0;crc:$f3d19987),
        (n:'gp2-11.11p';l:$2000;p:0;crc:$57740ff9),(n:'gp2-10.11n';l:$2000;p:$2000;crc:$6cd8ce11),
        (n:'gp2-12.11r';l:$2000;p:$4000;crc:$7316a1f1),(n:'gp2-9.11m';l:$2000;p:$6000;crc:$e6a9ae67),
        (n:'gp2-3.1p';l:$100;p:$0;crc:$a5091352),(n:'gp2-1.1n';l:$100;p:$100;crc:$8bc8022a),
        (n:'gp2-2.2n';l:$100;p:$200;crc:$8dabc20b),(n:'gp2-7.6s';l:$100;p:$300;crc:$2faa3e09),
        (n:'gp2-6.6p';l:$200;p:$400;crc:$6f99c2da),(n:'gp2-5.6n';l:$200;p:$600;crc:$c7d31657),
        (n:'gp2-4.3f';l:$100;p:$800;crc:$2d9fbdd8),());
        sxevious_roms:array[0..25] of tipo_roms=(
        (n:'cpu_3p.rom';l:$1000;p:0;crc:$1c8d27d5),(n:'cpu_3m.rom';l:$1000;p:$1000;crc:$fd04e615),
        (n:'xv3_3.2m';l:$1000;p:$2000;crc:$294d5404),(n:'xv3_4.2l';l:$1000;p:$3000;crc:$6a44bf92),
        (n:'xv3_5.3f';l:$1000;p:$0;crc:$d4bd3d81),(n:'xv3_6.3j';l:$1000;p:$1000;crc:$af06be5f),
        (n:'xvi_7.2c';l:$1000;p:0;crc:$dd35cf1c),(n:'xvi_12.3b';l:$1000;p:0;crc:$088c8b26),
        (n:'xvi-8.6a';l:$100;p:0;crc:$5cc2727f),(n:'xvi-9.6d';l:$100;p:$100;crc:$5c8796cc),
        (n:'xvi-10.6e';l:$100;p:$200;crc:$3cb60975),(n:'xvi-7.4h';l:$200;p:$300;crc:$22d98032),
        (n:'xvi-6.4f';l:$200;p:$500;crc:$3a7599f0),(n:'xvi-4.3l';l:$200;p:$700;crc:$fd8b9d91),
        (n:'xvi-5.3m';l:$200;p:$900;crc:$bf906d82),(n:'xvi-2.7n';l:$100;p:0;crc:$550f06bc),
        (n:'xvi_15.4m';l:$2000;p:0;crc:$dc2c0ecb),(n:'xvi_17.4p';l:$2000;p:$2000;crc:$dfb587ce),
        (n:'xvi_16.4n';l:$1000;p:$4000;crc:$605ca889),(n:'xvi_18.4r';l:$2000;p:$5000;crc:$02417d19),
        (n:'xvi_13.3c';l:$1000;p:$0;crc:$de60ba25),(n:'xvi_14.3d';l:$1000;p:$1000;crc:$535cdbbc),
        (n:'xvi_9.2a';l:$1000;p:0;crc:$57ed9879),(n:'xvi_10.2b';l:$2000;p:$1000;crc:$ae3ba9e5),
        (n:'xvi_11.2c';l:$1000;p:$3000;crc:$31e244dd),());
        grobda_roms:array[0..11] of tipo_roms=(
        (n:'gr2-3.1d';l:$2000;p:$a000;crc:$8e3a23be),(n:'gr2-2.1c';l:$2000;p:$c000;crc:$19ffa83d),
        (n:'gr2-1.1b';l:$2000;p:$e000;crc:$0089b13a),(n:'gr1-6.4c';l:$20;p:0;crc:$c65efa77),
        (n:'gr1-5.4e';l:$100;p:$20;crc:$a0f66911),(n:'gr1-4.3l';l:$100;p:$120;crc:$f1f2c234),
        (n:'gr1-7.3c';l:$1000;p:0;crc:$4ebfabfd),(n:'gr1-5.3f';l:$2000;p:0;crc:$eed43487),
        (n:'gr1-6.3e';l:$2000;p:$2000;crc:$cebb7362),(n:'gr1-4.1k';l:$2000;p:$e000;crc:$3fe78c08),
        (n:'gr1-3.3m';l:$100;p:0;crc:$66eb1467),());
        pacnpal_roms:array[0..10] of tipo_roms=(
        (n:'pap1-3b.1d';l:$2000;p:$a000;crc:$ed64a565),(n:'pap1-2b.1c';l:$2000;p:$c000;crc:$15308bcf),
        (n:'pap3-1.1b';l:$2000;p:$e000;crc:$3cac401c),(n:'pap1-6.4c';l:$20;p:0;crc:$52634b41),
        (n:'pap1-5.4e';l:$100;p:$20;crc:$ac46203c),(n:'pap1-4.3l';l:$100;p:$120;crc:$686bde84),
        (n:'pap1-6.3c';l:$1000;p:0;crc:$a36b96cb),(n:'pap1-5.3f';l:$2000;p:0;crc:$fb6f56e3),
        (n:'pap1-4.1k';l:$1000;p:$e000;crc:$330e20de),(n:'pap1-3.3m';l:$100;p:0;crc:$94782db5),());
        birdiy_roms:array[0..9] of tipo_roms=(
        (n:'a6.6a';l:$1000;p:0;crc:$3a58f8ad),(n:'c6.6c';l:$1000;p:$1000;crc:$fec61ea2),
        (n:'a4.4a';l:$1000;p:$2000;crc:$3392783b),(n:'c4.4c';l:$1000;p:$3000;crc:$2391d83d),
        (n:'n82s123n.10n';l:$20;p:0;crc:$ff344446),(n:'n82s129n.9m';l:$100;p:$20;crc:$63efb927),
        (n:'c1.1c';l:$1000;p:0;crc:$8f6bf54f),(n:'n82s129n.4k';l:$100;p:0;crc:$a9cc86bf),
        (n:'c3.3c';l:$1000;p:0;crc:$10b55440),());
        wilytower_roms:array[0..23] of tipo_roms=(
        (n:'wt4e.bin';l:$2000;p:0;crc:$a38e4b8a),(n:'wt4h.bin';l:$2000;p:$2000;crc:$c1405ceb),
        (n:'wt4j.bin';l:$2000;p:$4000;crc:$379fb1c3),(n:'wt4k.bin';l:$2000;p:$6000;crc:$2dd6f9c7),
        (n:'wt_a-4m.bin';l:$2000;p:$8000;crc:$c1f8a7d5),(n:'wt_a-4n.bin';l:$2000;p:$a000;crc:$b212f7d2),
        (n:'wt_a-5s-.bpr';l:$100;p:0;crc:$041950e7),(n:'wt_a-5r-.bpr';l:$100;p:$100;crc:$bc04bf25),
        (n:'wt_a-5p-.bpr';l:$100;p:$200;crc:$ed819a19),(n:'wt_b-9l-.bpr';l:$20;p:$300;crc:$d2728744),
        (n:'wt_b-5e.bin';l:$1000;p:0;crc:$fe45df43),(n:'wt_b-5f.bin';l:$1000;p:$1000;crc:$87a17eff),
        (n:'wtb5a.bin';l:$2000;p:0;crc:$efc1cbfa),(n:'wtb5b.bin';l:$2000;p:$2000;crc:$ab4bfd07),
        (n:'wtb5d.bin';l:$2000;p:$4000;crc:$40f23e1d),(n:'wt4d.bin';l:$1000;p:$0;crc:$25a171bf),
        (n:'wt2j.bin';l:$1000;p:0;crc:$d1bf0670),(n:'wt3k.bin';l:$1000;p:$1000;crc:$83c39a0e),
        (n:'wt_a-3m.bin';l:$1000;p:$2000;crc:$e7e468ae),(n:'wt_a-3n.bin';l:$1000;p:$3000;crc:$0741d1a9),
        (n:'wt_a-3p.bin';l:$1000;p:$4000;crc:$7299f362),(n:'wt_a-3s.bin';l:$1000;p:$5000;crc:$9b37d50d),
        (n:'wt_a-6d.bin';l:$1000;p:$0;crc:$a5dde29b),());
        fightbasket_roms:array[0..25] of tipo_roms=(
        (n:'fb14.0f';l:$2000;p:0;crc:$82032853),(n:'fb13.2f';l:$2000;p:$2000;crc:$5306df0f),
        (n:'fb12.3f';l:$2000;p:$4000;crc:$ee9210d4),(n:'fb10.6f';l:$2000;p:$8000;crc:$6b47efba),
        (n:'fb09.7f';l:$2000;p:$a000;crc:$be69e087),(n:'fb_r.9e';l:$100;p:0;crc:$c5cdc8ba),
        (n:'fb_g.10e';l:$100;p:$100;crc:$1460c936),(n:'fb_b.11e';l:$100;p:$200;crc:$fca5bf0e),
        (n:'fb08.12f';l:$1000;p:0;crc:$271cd7b8),(n:'fb21.25e';l:$2000;p:0;crc:$02843591),
        (n:'fb22.23e';l:$2000;p:$2000;crc:$cd51d8e7),(n:'fb23.22e';l:$2000;p:$4000;crc:$62bcac87),
        (n:'fb07.0b';l:$1000;p:$0;crc:$50432dbd),(n:'fb16.35a';l:$2000;p:0;crc:$d1bf0670),
        (n:'fb15.37a';l:$2000;p:$2000;crc:$83c39a0e),(n:'fb18.32a';l:$2000;p:$4000;crc:$e7e468ae),
        (n:'fb17.34a';l:$2000;p:$6000;crc:$0741d1a9),(n:'fb20.29a';l:$2000;p:$8000;crc:$7299f362),
        (n:'fb19.31a';l:$2000;p:$a000;crc:$9b37d50d),(n:'fb06.12a';l:$2000;p:$0;crc:$bea3df99),
        (n:'fb01.42a';l:$2000;p:0;crc:$1200b220),(n:'fb02.41a';l:$2000;p:$2000;crc:$0b67aa82),
        (n:'fb03.40a';l:$2000;p:$4000;crc:$c71269ed),(n:'fb04.39a';l:$2000;p:$6000;crc:$02ddc42d),
        (n:'fb05.38a';l:$2000;p:$8000;crc:$72ea6b49),());

implementation
uses principal,init_games;

procedure export_roms;
var
  fichero:textfile;
  f:word;
  rom_data:tgame_desc;
  rom_file:ptipo_roms;
  sample_file:ptsample_file;
  nombre_fichero,change_name:string;
  indice,tempb:byte;
begin
tempb:=main_vars.system_type;
main_vars.system_type:=SEXPORT;
if not(SaveRom(nombre_fichero,indice)) then begin
  main_vars.system_type:=tempb;
  exit;
end;
main_vars.system_type:=tempb;
if FileExists(nombre_fichero) then begin                                         //Respuesta 'NO' es 7
  if MessageDlg(leng[main_vars.idioma].mensajes[3], mtWarning, [mbYes]+[mbNo],0)=7 then exit;
end;
{$I-}
assignfile(fichero,nombre_fichero);
rewrite(fichero);
if ioresult<>0 then begin
  MessageDlg('Cannot write file: "'+nombre_fichero+'"',mtError,[mbOk], 0);
  exit;
end;
writeln(fichero,'<?xml version="1.0"?>');
writeln(fichero,'<!DOCTYPE datafile PUBLIC "-//DSP Emulator ROM Datafile//" "http://www.github.com/leniad">');
writeln(fichero,'');
writeln(fichero,'<datafile>');
writeln(fichero,'  <header>');
writeln(fichero,'    <name>DSP Emulator</name>');
writeln(fichero,'    <description>DSP Emulator '+DSP_VERSION+'</description>');
writeln(fichero,'    <category>EMULATION</category>');
writeln(fichero,'    <version>'+DSP_VERSION+'</version>');
writeln(fichero,'    <date>'+DateToStr(date)+'</date>');
writeln(fichero,'    <author>Leniad</author>');
writeln(fichero,'    <email>leniad2@hotmail.com</email>');
writeln(fichero,'    <homepage>http://www.github.com/leniad/</homepage>');
writeln(fichero,'    <url>--</url>');
writeln(fichero,'    <comment>--</comment>');
writeln(fichero,'    <clrmamepro/>');
writeln(fichero,'  </header>');
for f:=1 to games_cont do begin
  rom_data:=games_desc[f];
  if rom_data.zip<>'' then begin
    if ((rom_data.grid=5) or (rom_data.grid=3) or (rom_data.grid=247)) then continue;
    writeln(fichero,'  <game name="'+rom_data.zip+'">');
    change_name:=StringReplace(rom_data.name,'&','&amp;',[rfReplaceAll, rfIgnoreCase]);
    case rom_data.grid of
      0:writeln(fichero,'   <description>Spectrum 16K/48K</description>');
      2:writeln(fichero,'   <description>Spectrum +2A/+3</description>');
      else writeln(fichero,'   <description>'+change_name+'</description>');
    end;
    writeln(fichero,'   <year>'+rom_data.year+'</year>');
    writeln(fichero,'   <manufacturer>'+rom_data.company+'</manufacturer>');
    rom_file:=rom_data.rom;
    repeat
      writeln(fichero,'   <rom name="'+rom_file.n+'" size="'+inttostr(rom_file.l)+'" crc="'+inttohex(rom_file.crc,8)+'"/>');
      inc(rom_file);
    until rom_file.n='';
    case rom_data.grid of
      346,347:rom_data:=games_desc[191]; //Super Zaxxon y Future Spy
      350:rom_data:=games_desc[234]; //Super Xevious
    end;
    if rom_data.samples<>nil then begin
      sample_file:=rom_data.samples;
      repeat
        writeln(fichero,'   <sample name="'+sample_file.nombre+'"/>');
        inc(sample_file);
      until sample_file.nombre='';
    end;
    writeln(fichero,'   </game>');
  end;
end;
writeln(fichero,'</datafile>');
close(fichero);
{$I+}

end;

end.
