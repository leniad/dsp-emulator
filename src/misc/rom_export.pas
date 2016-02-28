unit rom_export;

interface
uses rom_engine,dialogs,main_engine,sysutils;

procedure export_roms;

implementation

type
  trom_data=record
      name:string;
      description:string;
      year:string;
      manufacturer:string;
      rom:ptipo_roms;
  end;

const
        TOTAL_ROMS=100  -1;

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
        cpc464:array[0..1] of tipo_roms=((n:'cpc464.rom';l:$8000;p:0;crc:$40852f25),());
        cpc664:array[0..2] of tipo_roms=((n:'cpc664.rom';l:$8000;p:0;crc:$9ab5a036),(n:'amsdos.rom';l:$4000;p:0;crc:$1fe22ecd),());
        cpc6128:array[0..2] of tipo_roms=((n:'cpc6128.rom';l:$8000;p:0;crc:$9e827fe1),(n:'amsdos.rom';l:$4000;p:0;crc:$1fe22ecd),());
        //Pacman
        pacman:array[0..9] of tipo_roms=(
        (n:'pacman.6e';l:$1000;p:0;crc:$c1e6ab10),(n:'pacman.6f';l:$1000;p:$1000;crc:$1a6fb2d4),
        (n:'pacman.6h';l:$1000;p:$2000;crc:$bcdd1beb),(n:'pacman.6j';l:$1000;p:$3000;crc:$817d94e3),
        (n:'82s123.7f';l:$20;p:0;crc:$2fc650bd),(n:'82s126.4a';l:$100;p:$20;crc:$3eb3a8e4),
        (n:'pacman.5e';l:$1000;p:0;crc:$0c944964),
        (n:'82s126.1m';l:$100;p:0;crc:$a9cc86bf),
        (n:'pacman.5f';l:$1000;p:0;crc:$958fedf9),());
        //MS-Pacman
        mspacman:array[0..9] of tipo_roms=(
        (n:'pacman.6e';l:$1000;p:0;crc:$c1e6ab10),(n:'pacman.6f';l:$1000;p:$1000;crc:$1a6fb2d4),
        (n:'pacman.6h';l:$1000;p:$2000;crc:$bcdd1beb),(n:'pacman.6j';l:$1000;p:$3000;crc:$817d94e3),
        (n:'u5';l:$800;p:$8000;crc:$f45fbbcd),(n:'u6';l:$1000;p:$9000;crc:$a90e7000),
        (n:'u7';l:$1000;p:$b000;crc:$c82cd714),
        (n:'5e';l:$1000;p:0;crc:$5c281d01),
        (n:'5f';l:$1000;p:0;crc:$615af909),());
        actfancer:array[0..19] of tipo_roms=(
        (n:'fe08-2.bin';l:$10000;p:0;crc:$0d36fbfa),(n:'fe09-2.bin';l:$10000;p:$10000;crc:$27ce2bb1),
        (n:'10';l:$10000;p:$20000;crc:$cabad137),
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
        (n:'13.1r';l:$2000;p:$c000;crc:$70e0244d),
        (n:'03_e08t.bin';l:$1000;p:0;crc:$9f0470d5),(n:'04_h08t.bin';l:$1000;p:$1000;crc:$81ec12e6),
        (n:'05_k08t.bin';l:$1000;p:$2000;crc:$e87ec8b1),
        (n:'06_l08t.bin';l:$2000;p:0;crc:$51eebd89),(n:'07_n08t.bin';l:$2000;p:$2000;crc:$9dd98e9d),
        (n:'08_r08t.bin';l:$2000;p:$4000;crc:$3155ee7d),
        (n:'16_m07b.bin';l:$2000;p:0;crc:$94694097),(n:'15_l07b.bin';l:$2000;p:$2000;crc:$013f58f2),
        (n:'14_j07b.bin';l:$2000;p:$4000;crc:$101c858d),(n:'02_p04t.bin';l:$1000;p:0;crc:$398d4a02),
        (n:'01_h03t.bin';l:$2000;p:0;crc:$8407917d),());
        //Galaxian
        galaxian:array[0..8] of tipo_roms=(
        (n:'galmidw.u';l:$800;p:0;crc:$745e2d61),(n:'galmidw.v';l:$800;p:$800;crc:$9c999a40),
        (n:'galmidw.w';l:$800;p:$1000;crc:$b5894925),(n:'galmidw.y';l:$800;p:$1800;crc:$6b3ca10b),
        (n:'7l';l:$800;p:$2000;crc:$1b933207),
        (n:'1h.bin';l:$800;p:0;crc:$39fb43a4),(n:'1k.bin';l:$800;p:$800;crc:$7e3f56a2),
        (n:'6l.bpr';l:$20;p:0;crc:$c3ac9467),());
        //Jump Bug
        jumpbug:array[0..14] of tipo_roms=(
        (n:'jb1';l:$1000;p:0;crc:$415aa1b7),(n:'jb2';l:$1000;p:$1000;crc:$b1c27510),
        (n:'jb3';l:$1000;p:$2000;crc:$97c24be2),(n:'jb4';l:$1000;p:$3000;crc:$66751d12),
        (n:'jb5';l:$1000;p:$8000;crc:$e2d66faf),(n:'jb6';l:$1000;p:$9000;crc:$49e0bdfd),
        (n:'jb7';l:$800;p:$a000;crc:$83d71302),
        (n:'jbl';l:$800;p:0;crc:$9a091b0a),(n:'jbm';l:$800;p:$800;crc:$8a0fc082),
        (n:'jbn';l:$800;p:$1000;crc:$155186e0),(n:'jbi';l:$800;p:$1800;crc:$7749b111),
        (n:'jbj';l:$800;p:$2000;crc:$06e8d7df),(n:'jbk';l:$800;p:$2800;crc:$b8dbddf3),
        (n:'l06_prom.bin';l:$20;p:0;crc:$6a0c7d87),());
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
        (n:'5e';l:$800;p:$1000;crc:$1628c53f),
        (n:'epr1274.5h';l:$800;p:0;crc:$64d113b4),(n:'epr1273.5f';l:$800;p:$800;crc:$a96316d3),
        (n:'82s123.6e';l:$20;p:0;crc:$9b87f90d),());
        //Frogger
        frogger:array[0..9] of tipo_roms=(
        (n:'frogger.26';l:$1000;p:0;crc:$597696d6),(n:'frogger.27';l:$1000;p:$1000;crc:$b6e6fcc3),
        (n:'frsm3.7';l:$1000;p:$2000;crc:$aca22ae0),
        (n:'frogger.607';l:$800;p:0;crc:$05f7d883),(n:'frogger.606';l:$800;p:$800;crc:$f524ee30),
        (n:'pr-91.6l';l:32;p:0;crc:$413703bf),
        (n:'frogger.608';l:$800;p:0;crc:$e8ab0256),(n:'frogger.609';l:$800;p:$800;crc:$7380a48f),
        (n:'frogger.610';l:$800;p:$1000;crc:$31d7eb27),());
        //Amidar
        amidar:array[0..9] of tipo_roms=(
        (n:'amidar.2c';l:$1000;p:0;crc:$c294bf27),(n:'amidar.2e';l:$1000;p:$1000;crc:$e6e96826),
        (n:'amidar.2f';l:$1000;p:$2000;crc:$3656be6f),(n:'amidar.2h';l:$1000;p:$3000;crc:$1be170bd),
        (n:'amidar.5f';l:$800;p:0;crc:$5e51e84d),(n:'amidar.5h';l:$800;p:$800;crc:$2f7f1c30),
        (n:'amidar.clr';l:32;p:0;crc:$f940dcc3),
        (n:'amidar.5c';l:$1000;p:0;crc:$c4b66ae4),(n:'amidar.5d';l:$1000;p:$1000;crc:$806785af),());
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
        (n:'dkj.5e';l:$2000;p:$4000;crc:$d042b6a8),
        (n:'c-2e.bpr';l:$100;p:0;crc:$463dc7ad),(n:'c-2f.bpr';l:$100;p:$100;crc:$47ba0042),
        (n:'v-2n.bpr';l:$100;p:$200;crc:$dbf185bf),
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
        (n:'o11.8i';l:$4000;p:0;crc:$3c82aaf3),
        (n:'001.f1';l:$4000;p:0;crc:$a2ba0df5),(n:'003.f3';l:$4000;p:$4000;crc:$9775ab32),
        (n:'005.h1';l:$4000;p:$8000;crc:$ba44aeef),(n:'007.h3';l:$4000;p:$c000;crc:$31afc153),
        (n:'d19.1i';l:$100;p:$0;crc:$8b83e7cf),(n:'d21.3i';l:$100;p:$100;crc:$3556304a),
        (n:'d20.2i';l:$100;p:$200;crc:$676a0669),(n:'d22.12h';l:$100;p:$300;crc:$872be05c),
        (n:'d18.f9';l:$100;p:$400;crc:$7396b374),());
        shaolins:array[0..12] of tipo_roms=(
        (n:'477-l03.d9';l:$2000;p:$6000;crc:$2598dfdd),(n:'477-l04.d10';l:$4000;p:$8000;crc:$0cf0351a),
        (n:'477-l05.d11';l:$4000;p:$c000;crc:$654037f8),
        (n:'shaolins.a10';l:$2000;p:0;crc:$ff18a7ed),(n:'shaolins.a11';l:$2000;p:$2000;crc:$5f53ae61),
        (n:'477-k02.h15';l:$4000;p:0;crc:$b94e645b),(n:'477-k01.h14';l:$4000;p:$4000;crc:$61bbf797),
        (n:'477j10.a12';l:$100;p:$0;crc:$b09db4b4),(n:'477j11.a13';l:$100;p:$100;crc:$270a2bf3),
        (n:'477j12.a14';l:$100;p:$200;crc:$83e95ea8),(n:'477j09.b8';l:$100;p:$300;crc:$aa900724),
        (n:'477j08.f16';l:$100;p:$400;crc:$80009cf5),());
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
        (n:'starforc.3';l:$4000;p:0;crc:$8ba27691),(n:'starforc.2';l:$4000;p:$4000;crc:$0fc4d2d6),
        (n:'starforc.7';l:$1000;p:0;crc:$f4803339),(n:'starforc.8';l:$1000;p:$1000;crc:$96979684),
        (n:'starforc.9';l:$1000;p:$2000;crc:$eead1d5c),
        (n:'starforc.15';l:$2000;p:0;crc:$c3bda12f),(n:'starforc.14';l:$2000;p:$2000;crc:$9e9384fe),
        (n:'starforc.13';l:$2000;p:$4000;crc:$84603285),
        (n:'starforc.12';l:$2000;p:0;crc:$fdd9e38b),(n:'starforc.11';l:$2000;p:$2000;crc:$668aea14),
        (n:'starforc.10';l:$2000;p:$4000;crc:$c62a19c1),
        (n:'starforc.18';l:$1000;p:0;crc:$6455c3ad),(n:'starforc.17';l:$1000;p:$1000;crc:$68c60d0f),
        (n:'starforc.16';l:$1000;p:$2000;crc:$ce20b469),(n:'starforc.1';l:$2000;p:0;crc:$2735bb22),
        (n:'starforc.6';l:$4000;p:0;crc:$5468a21d),(n:'starforc.5';l:$4000;p:$4000;crc:$f71717f8),
        (n:'starforc.4';l:$4000;p:$8000;crc:$dd9d68a4),());
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
        (n:'epr6458a.96';l:$4000;p:$8000;crc:$5c30b3e8),
        (n:'epr6474a.62';l:$2000;p:0;crc:$9f1711b9),(n:'epr6473a.61';l:$2000;p:$2000;crc:$8e53b8dd),
        (n:'epr6472a.64';l:$2000;p:$4000;crc:$e0f34a11),(n:'epr6471a.63';l:$2000;p:$6000;crc:$d5bc805c),
        (n:'epr6470a.66';l:$2000;p:$8000;crc:$1439729f),(n:'epr6469a.65';l:$2000;p:$a000;crc:$e4ac6921),
        (n:'epr-6462.120';l:$2000;p:0;crc:$86bb9185),
        (n:'epr6454a.117';l:$4000;p:0;crc:$a5d96780),(n:'epr-6455.05';l:$4000;p:$4000;crc:$32ee64a1),
        (n:'pr-5317.76';l:$100;p:0;crc:$648350b8),());
        //Teddy Boy Blues
        teddybb:array[0..15] of tipo_roms=(
        (n:'epr-6768.116';l:$4000;p:0;crc:$5939817e),(n:'epr-6769.109';l:$4000;p:$4000;crc:$14a98ddd),
        (n:'epr-6770.96';l:$4000;p:$8000;crc:$67b0c7c2),
        (n:'epr-6747.62';l:$2000;p:0;crc:$a0e5aca7),(n:'epr-6746.61';l:$2000;p:$2000;crc:$cdb77e51),
        (n:'epr-6745.64';l:$2000;p:$4000;crc:$0cab75c3),(n:'epr-6744.63';l:$2000;p:$6000;crc:$0ef8d2cd),
        (n:'epr-6743.66';l:$2000;p:$8000;crc:$c33062b5),(n:'epr-6742.65';l:$2000;p:$a000;crc:$c457e8c5),
        (n:'epr6748x.120';l:$2000;p:0;crc:$c2a1b89d),
        (n:'epr-6735.117';l:$4000;p:0;crc:$1be35a97),(n:'epr-6737.04';l:$4000;p:$4000;crc:$6b53aa7a),
        (n:'epr-6736.110';l:$4000;p:$8000;crc:$565c25d0),(n:'epr-6738.05';l:$4000;p:$c000;crc:$e116285f),
        (n:'pr-5317.76';l:$100;p:0;crc:$648350b8),());
        //Wonder Boy
        wboy:array[0..15] of tipo_roms=(
        (n:'epr-7489.116';l:$4000;p:0;crc:$130f4b70),(n:'epr-7490.109';l:$4000;p:$4000;crc:$9e656733),
        (n:'epr-7491.96';l:$4000;p:$8000;crc:$1f7d0efe),
        (n:'epr-7497.62';l:$2000;p:0;crc:$08d609ca),(n:'epr-7496.61';l:$2000;p:$2000;crc:$6f61fdf1),
        (n:'epr-7495.64';l:$2000;p:$4000;crc:$6a0d2c2d),(n:'epr-7494.63';l:$2000;p:$6000;crc:$a8e281c7),
        (n:'epr-7493.66';l:$2000;p:$8000;crc:$89305df4),(n:'epr-7492.65';l:$2000;p:$a000;crc:$60f806b1),
        (n:'epr-7498.120';l:$2000;p:0;crc:$78ae1e7b),
        (n:'epr-7485.117';l:$4000;p:0;crc:$c2891722),(n:'epr-7487.04';l:$4000;p:$4000;crc:$2d3a421b),
        (n:'epr-7486.110';l:$4000;p:$8000;crc:$8d622c50),(n:'epr-7488.05';l:$4000;p:$c000;crc:$007c2f1b),
        (n:'pr-5317.76';l:$100;p:0;crc:$648350b8),());
        //Mr Viking
        mrviking:array[0..16] of tipo_roms=(
        (n:'epr-5873.129';l:$2000;p:0;crc:$14d21624),(n:'epr-5874.130';l:$2000;p:$2000;crc:$6df7de87),
        (n:'epr-5875.131';l:$2000;p:$4000;crc:$ac226100),(n:'epr-5876.132';l:$2000;p:$6000;crc:$e77db1dc),
        (n:'epr-5755.133';l:$2000;p:$8000;crc:$edd62ae1),(n:'epr-5756.134';l:$2000;p:$a000;crc:$11974040),
        (n:'epr-5749.86';l:$4000;p:$0;crc:$e24682cd),(n:'epr-5750.93';l:$4000;p:$4000;crc:$6564d1ad),
        (n:'epr-5763.3';l:$2000;p:0;crc:$d712280d),
        (n:'epr-5762.82';l:$2000;p:0;crc:$4a91d08a),(n:'epr-5761.65';l:$2000;p:$2000;crc:$f7d61b65),
        (n:'epr-5760.81';l:$2000;p:$4000;crc:$95045820),(n:'epr-5759.64';l:$2000;p:$6000;crc:$5f9bae4e),
        (n:'epr-5758.80';l:$2000;p:$8000;crc:$808ee706),(n:'epr-5757.63';l:$2000;p:$a000;crc:$480f7074),
        (n:'pr-5317.106';l:$100;p:0;crc:$648350b8),());
        //Sega Ninja
        seganinj:array[0..15] of tipo_roms=(
        (n:'epr-.116';l:$4000;p:0;crc:$a5d0c9d0),(n:'epr-.109';l:$4000;p:$4000;crc:$b9e6775c),
        (n:'epr-6552.96';l:$4000;p:$8000;crc:$f2eeb0d8),
        (n:'epr-6546.117';l:$4000;p:$0;crc:$a4785692),(n:'epr-6548.04';l:$4000;p:$4000;crc:$bdf278c1),
        (n:'epr-6547.110';l:$4000;p:$8000;crc:$34451b08),(n:'epr-6549.05';l:$4000;p:$c000;crc:$d2057668),
        (n:'epr-6559.120';l:$2000;p:0;crc:$5a1570ee),
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
        (n:'epr-5535.3';l:$2000;p:0;crc:$cf4e4c45),
        (n:'epr-5527.82';l:$2000;p:0;crc:$b2d616f1),(n:'epr-5526.65';l:$2000;p:$2000;crc:$8a8b33c2),
        (n:'epr-5525.81';l:$2000;p:$4000;crc:$e749c5ef),(n:'epr-5524.64';l:$2000;p:$6000;crc:$8b886952),
        (n:'epr-5523.80';l:$2000;p:$8000;crc:$dede35d9),(n:'epr-5522.63';l:$2000;p:$a000;crc:$5e6d9dff),
        (n:'pr-5317.106';l:$100;p:0;crc:$648350b8),());
        //Flicky
        flicky:array[0..12] of tipo_roms=(
        (n:'epr5978a.116';l:$4000;p:0;crc:$296f1492),(n:'epr5979a.109';l:$4000;p:$4000;crc:$64b03ef9),
        (n:'epr-5855.117';l:$4000;p:$0;crc:$b5f894a1),(n:'epr-5856.110';l:$4000;p:$4000;crc:$266af78f),
        (n:'epr-5869.120';l:$2000;p:0;crc:$6d220d4e),
        (n:'epr-5868.62';l:$2000;p:0;crc:$7402256b),(n:'epr-5867.61';l:$2000;p:$2000;crc:$2f5ce930),
        (n:'epr-5866.64';l:$2000;p:$4000;crc:$967f1d9a),(n:'epr-5865.63';l:$2000;p:$6000;crc:$03d9a34c),
        (n:'epr-5864.66';l:$2000;p:$8000;crc:$e659f358),(n:'epr-5863.65';l:$2000;p:$a000;crc:$a496ca15),
        (n:'pr-5317.76';l:$100;p:0;crc:$648350b8),());
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
        (n:'cz01';l:$4000;p:$4000;crc:$dc8f9fba),(n:'cz00';l:$8000;p:$8000;crc:$a81290bc),
        (n:'cz07';l:$4000;p:$0000;crc:$686bac23),
        (n:'cz04';l:$8000;p:$0000;crc:$643a1bd3),(n:'cz05';l:$8000;p:$10000;crc:$c44570bf),
        (n:'cz06';l:$8000;p:$18000;crc:$b9bb448b),(n:'cz02';l:$8000;p:$8000;crc:$552e6112),
        (n:'cz03';l:$8000;p:$0000;crc:$6ce11971),
        (n:'cz09';l:$8000;p:$0000;crc:$1ed250d1),(n:'cz08';l:$8000;p:$8000;crc:$2293fc61),
        (n:'cz13';l:$8000;p:$10000;crc:$7c3bfd00),(n:'cz12';l:$8000;p:$18000;crc:$ea2294c8),
        (n:'cz11';l:$8000;p:$20000;crc:$b7418335),(n:'cz10';l:$8000;p:$28000;crc:$2f611978),
        (n:'cz17.prm';l:$100;p:$000;crc:$da31dfbc),(n:'cz16.prm';l:$100;p:$100;crc:$51f25b4c),
        (n:'cz15.prm';l:$100;p:$200;crc:$a6168d7f),(n:'cz14.prm';l:$100;p:$300;crc:$52aad300),());
        sbasketb:array[0..14] of tipo_roms=(
        (n:'405g05.14j';l:$2000;p:$6000;crc:$336dc0ab),(n:'405i03.11j';l:$4000;p:$8000;crc:$d33b82dd),
        (n:'405i01.9j';l:$4000;p:$c000;crc:$1c09cc3f),(n:'405e12.22f';l:$4000;p:0;crc:$e02c54da),
        (n:'405h06.14g';l:$4000;p:0;crc:$cfbbff07),(n:'405h08.17g';l:$4000;p:$4000;crc:$c75901b6),
        (n:'405h10.20g';l:$4000;p:$8000;crc:$95bc5942),
        (n:'405e17.5a';l:$100;p:$0;crc:$b4c36d57),(n:'405e16.4a';l:$100;p:$100;crc:$0b7b03b8),
        (n:'405e18.6a';l:$100;p:$200;crc:$9e533bad),(n:'405e20.19d';l:$100;p:$300;crc:$8ca6de2f),
        (n:'405e19.16d';l:$100;p:$400;crc:$e0bc782f),(n:'405e15.11f';l:$2000;p:$0;crc:$01bb5ce9),
        (n:'405e13.7a';l:$2000;p:$0;crc:$1ec7458b),());
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
        (n:'p5d';l:$8000;p:0;crc:$90259249),(n:'p5e';l:$10000;p:$8000;crc:$72298f34),
        (n:'p5a';l:$8000;p:0;crc:$50060ecd),(n:'p5f';l:$8000;p:0;crc:$04d7e21c),
        (n:'p5b';l:$10000;p:0;crc:$7e3f87d4),(n:'p5c';l:$10000;p:$10000;crc:$8710fedb),
        (n:'p5g';l:$10000;p:0;crc:$f9262f32),(n:'p5h';l:$10000;p:$10000;crc:$c411171a),());
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
        (n:'b-5f-.bin';l:$20;p:$600;crc:$7a601c3d),
        (n:'g-4c-a.bin';l:$2000;p:0;crc:$6b2cc9c8),(n:'g-4d-a.bin';l:$2000;p:$2000;crc:$c648f558),
        (n:'g-4e-a.bin';l:$2000;p:$4000;crc:$fbe9276e),
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
        (n:'sprb.5p';l:$20;p:$600;crc:$746c6238),
        (n:'sprm.4p';l:$4000;p:0;crc:$4dfe2e63),(n:'sprm.4l';l:$4000;p:$4000;crc:$239f2cd4),
        (n:'sprm.4m';l:$4000;p:$8000;crc:$d6d07d70),
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
        (n:'sp2-r.7b';l:$4000;p:$18000;crc:$7709a1fe),
        (n:'sp2-r.1k';l:$200;p:0;crc:$31c1bcdc),(n:'sp2-r.2k';l:$100;p:$200;crc:$1cf5987e),
        (n:'sp2-r.2j';l:$100;p:$300;crc:$1acbe2a5),(n:'sp2-b.1m';l:$100;p:$400;crc:$906104c7),
        (n:'sp2-b.1n';l:$100;p:$500;crc:$5a564c06),(n:'sp2-b.1l';l:$100;p:$600;crc:$8f4a2e3c),
        (n:'sp2-b.5p';l:$20;p:$700;crc:$cd126f6a),
        (n:'sp2-r.4l';l:$4000;p:0;crc:$6a4b2d8b),(n:'sp2-r.4m';l:$4000;p:$4000;crc:$e1368b61),
        (n:'sp2-r.4p';l:$4000;p:$8000;crc:$fc138e13),
        (n:'sp2-a.3d';l:$4000;p:$8000;crc:$839ec7e2),(n:'sp2-a.3f';l:$4000;p:$c000;crc:$ad3ce898),
        (n:'sp2-b.4k';l:$4000;p:0;crc:$6cb67a17),(n:'sp2-b.4f';l:$4000;p:$4000;crc:$e4a1166f),
        (n:'sp2-b.3n';l:$4000;p:$8000;crc:$f59e8b76),(n:'sp2-b.4n';l:$4000;p:$c000;crc:$fa65bac9),
        (n:'sp2-b.4c';l:$4000;p:$10000;crc:$1caf7013),(n:'sp2-b.4e';l:$4000;p:$14000;crc:$780a463b),
        (n:'sp2-r.1d';l:$8000;p:0;crc:$c19fa4c9),(n:'sp2-r.3b';l:$8000;p:$8000;crc:$366604af),
        (n:'sp2-r.1b';l:$8000;p:$10000;crc:$3a0c4d47),());
        //Lode Runner
        ldrun:array[0..19] of tipo_roms=(
        (n:'lr-a-4e';l:$2000;p:0;crc:$5d7e2a4d),(n:'lr-a-4d';l:$2000;p:$2000;crc:$96f20473),
        (n:'lr-a-4b';l:$2000;p:$4000;crc:$b041c4a9),(n:'lr-a-4a';l:$2000;p:$6000;crc:$645e42aa),
        (n:'lr-e-3m';l:$100;p:0;crc:$53040416),(n:'lr-e-3l';l:$100;p:$100;crc:$67786037),
        (n:'lr-e-3n';l:$100;p:$200;crc:$5b716837),(n:'lr-b-1m';l:$100;p:$300;crc:$4bae1c25),
        (n:'lr-b-1n';l:$100;p:$400;crc:$9cd3db94),(n:'lr-b-1l';l:$100;p:$500;crc:$08d8cf9a),
        (n:'lr-b-5p';l:$20;p:$600;crc:$e01f69e2),
        (n:'lr-e-2d';l:$2000;p:0;crc:$24f9b58d),(n:'lr-e-2j';l:$2000;p:$2000;crc:$43175e08),
        (n:'lr-e-2f';l:$2000;p:$4000;crc:$e0317124),
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
        (n:'lr2-b-5p';l:$20;p:$600;crc:$e01f69e2),
        (n:'lr2-h-1e';l:$2000;p:0;crc:$9d63a8ff),(n:'lr2-h-1j';l:$2000;p:$2000;crc:$40332bbd),
        (n:'lr2-h-1h';l:$2000;p:$4000;crc:$9404727d),
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
        vigilant:array[0..17] of tipo_roms=(
        (n:'g07_c03.bin';l:$8000;p:0;crc:$9dcca081),(n:'j07_c04.bin';l:$10000;p:$8000;crc:$e0159105),
        (n:'f05_c08.bin';l:$10000;p:0;crc:$01579d20),(n:'h05_c09.bin';l:$10000;p:$10000;crc:$4f5872f0),
        (n:'n07_c12.bin';l:$10000;p:$00000;crc:$10af8eb2),(n:'k07_c10.bin';l:$10000;p:$10000;crc:$9576f304),
        (n:'o07_c13.bin';l:$10000;p:$20000;crc:$b1d9d4dc),(n:'l07_c11.bin';l:$10000;p:$30000;crc:$4598be4a),
        (n:'t07_c16.bin';l:$10000;p:$40000;crc:$f5425e42),(n:'p07_c14.bin';l:$10000;p:$50000;crc:$cb50a17c),
        (n:'v07_c17.bin';l:$10000;p:$60000;crc:$959ba3c7),(n:'s07_c15.bin';l:$10000;p:$70000;crc:$7f2e91c5),
        (n:'d04_c01.bin';l:$10000;p:0;crc:$9b85101d),(n:'g05_c02.bin';l:$10000;p:0;crc:$10582b2d),
        (n:'d01_c05.bin';l:$10000;p:$00000;crc:$81b1ee5c),(n:'e01_c06.bin';l:$10000;p:$10000;crc:$d0d33673),
        (n:'f01_c07.bin';l:$10000;p:$20000;crc:$aae81695),());
        jackal:array[0..9] of tipo_roms=(
        (n:'j-v02.rom';l:$10000;p:$0;crc:$0b7e0584),(n:'j-v03.rom';l:$4000;p:$10000;crc:$3e0dfb83),
        (n:'631r08.bpr';l:$100;p:0;crc:$7553a172),(n:'631r09.bpr';l:$100;p:$100;crc:$a74dd86c),
        (n:'631t04.bin';l:$20000;p:0;crc:$457f42f0),(n:'631t05.bin';l:$20000;p:$1;crc:$732b3fc1),
        (n:'631t06.bin';l:$20000;p:$40000;crc:$2d10e56e),(n:'631t07.bin';l:$20000;p:$40001;crc:$4961c397),
        (n:'631t01.bin';l:$8000;p:$8000;crc:$b189af6a),());
        bublbobl:array[0..18] of tipo_roms=(
        (n:'a78-06-1.51';l:$8000;p:0;crc:$567934b6),(n:'a78-05-1.52';l:$10000;p:$8000;crc:$9f8ee242),
        (n:'a78-08.37';l:$8000;p:0;crc:$ae11a07b),
        (n:'a78-09.12';l:$8000;p:0;crc:$20358c22),(n:'a78-10.13';l:$8000;p:$8000;crc:$930168a9),
        (n:'a78-11.14';l:$8000;p:$10000;crc:$9773e512),(n:'a78-12.15';l:$8000;p:$18000;crc:$d045549b),
        (n:'a78-13.16';l:$8000;p:$20000;crc:$d0af35c5),(n:'a78-14.17';l:$8000;p:$28000;crc:$7b5369a8),
        (n:'a78-15.30';l:$8000;p:$40000;crc:$6b61a413),(n:'a78-16.31';l:$8000;p:$48000;crc:$b5492d97),
        (n:'a78-17.32';l:$8000;p:$50000;crc:$d69762d5),(n:'a78-18.33';l:$8000;p:$58000;crc:$9f243b68),
        (n:'a78-19.34';l:$8000;p:$60000;crc:$66e9438c),(n:'a78-20.35';l:$8000;p:$68000;crc:$9ef863ad),
        (n:'a78-07.46';l:$8000;p:0;crc:$4f9a26e8),(n:'a71-25.41';l:$100;p:0;crc:$2d0f8545),
        (n:'a78-01.17';l:$1000;p:$f000;crc:$b1bfb53d),());
        prehisle:array[0..10] of tipo_roms=(
        (n:'gt-e2.2h';l:$20000;p:0;crc:$7083245a),(n:'gt-e3.3h';l:$20000;p:$1;crc:$6d8cdf58),
        (n:'gt15.b15';l:$8000;p:0;crc:$ac652412),(n:'gt.11';l:$10000;p:0;crc:$b4f0fcf0),
        (n:'pi8914.b14';l:$40000;p:0;crc:$207d6187),(n:'pi8916.h16';l:$40000;p:0;crc:$7cffe0f6),
        (n:'gt1.1';l:$10000;p:0;crc:$80a4c093),(n:'gt4.4';l:$20000;p:0;crc:$85dfb9ec),
        (n:'pi8910.k14';l:$80000;p:0;crc:$5a101b0b),(n:'gt.5';l:$20000;p:$80000;crc:$3d3ab273),());
        //Tiger Road
        tigeroad:array[0..17] of tipo_roms=(
        (n:'tru02.bin';l:$20000;p:0;crc:$8d283a95),(n:'tru04.bin';l:$20000;p:$1;crc:$72e2ef20),
        (n:'tr01.bin';l:$8000;p:0;crc:$74a9f08c),
        (n:'tr-01a.bin';l:$20000;p:0;crc:$a8aa2e59),(n:'tr-04a.bin';l:$20000;p:$20000;crc:$8863a63c),
        (n:'tr-02a.bin';l:$20000;p:$40000;crc:$1a2c5f89),(n:'tr05.bin';l:$20000;p:$60000;crc:$5bf453b3),
        (n:'tr-03a.bin';l:$20000;p:$80000;crc:$1e0537ea),(n:'tr-06a.bin';l:$20000;p:$a0000;crc:$b636c23a),
        (n:'tr-07a.bin';l:$20000;p:$c0000;crc:$5f907d4d),(n:'tr08.bin';l:$20000;p:$e0000;crc:$adee35e2),
        (n:'tr13.bin';l:$8000;p:0;crc:$a79be1eb),
        (n:'tr-09a.bin';l:$20000;p:0;crc:$3d98ad1e),(n:'tr-10a.bin';l:$20000;p:$20000;crc:$8f6f03d7),
        (n:'tr-11a.bin';l:$20000;p:$40000;crc:$cd9152e5),(n:'tr-12a.bin';l:$20000;p:$60000;crc:$7d8a99d0),
        (n:'tru05.bin';l:$8000;p:0;crc:$f9a7c9bf),());
        //F1 Dream
        f1dream:array[0..17] of tipo_roms=(
        (n:'f1d_04.bin';l:$10000;p:0;crc:$903febad),(n:'f1d_05.bin';l:$10000;p:$1;crc:$666fa2a7),
        (n:'f1d_02.bin';l:$10000;p:$20000;crc:$98973c4c),(n:'f1d_03.bin';l:$10000;p:$20001;crc:$3d21c78a),
        (n:'10d_01.bin';l:$8000;p:0;crc:$361caf00),
        (n:'03f_12.bin';l:$10000;p:0;crc:$bc13e43c),(n:'01f_10.bin';l:$10000;p:$10000;crc:$f7617ad9),
        (n:'03h_14.bin';l:$10000;p:$20000;crc:$e33cd438),(n:'02f_11.bin';l:$10000;p:$30000;crc:$4aa49cd7),
        (n:'17f_09.bin';l:$10000;p:$40000;crc:$ca622155),(n:'02h_13.bin';l:$10000;p:$50000;crc:$2a63961e),
        (n:'07l_15.bin';l:$8000;p:0;crc:$978758b7),
        (n:'03b_06.bin';l:$10000;p:0;crc:$5e54e391),(n:'02b_05.bin';l:$10000;p:$10000;crc:$cdd119fd),
        (n:'03d_08.bin';l:$10000;p:$20000;crc:$811f2e22),(n:'02d_07.bin';l:$10000;p:$30000;crc:$aa9a1233),
        (n:'12k_04.bin';l:$8000;p:0;crc:$4b9a7524),());
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
        digdug2:array[0..10] of tipo_roms=(
        (n:'d23_3.1d';l:$4000;p:$8000;crc:$cc155338),(n:'d23_1.1b';l:$4000;p:$c000;crc:$40e46af8),
        (n:'d21-5.5b';l:$20;p:0;crc:$9b169db5),(n:'d21-6.4c';l:$100;p:$20;crc:$55a88695),
        (n:'d21-7.5k';l:$100;p:$120;crc:$9c55feda),(n:'d21_5.3b';l:$1000;p:0;crc:$afcb4509),
        (n:'d21_6.3m';l:$4000;p:0;crc:$df1f4ad8),(n:'d21_7.3n';l:$4000;p:$4000;crc:$ccadb3ea),
        (n:'d21_4.1k';l:$2000;p:$e000;crc:$737443b1),(n:'d21-3.3m';l:$100;p:0;crc:$e0074ee2),());
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
        (n:'b04-35.19';l:$10000;p:0;crc:$1c91dbb1),(n:'b04-37.07';l:$10000;p:$1;crc:$ecf20bdd),
        (n:'b04-40.20';l:$10000;p:$20000;crc:$0930d4b3),(n:'b04-39.08';l:$10000;p:$20001;crc:$d95ade5e),
        (n:'b04-42.21';l:$10000;p:$40000;crc:$1857a7cb),(n:'b04-43.09';l:$10000;p:$40001;crc:$c34b9152),
        (n:'b04-01.40';l:$20000;p:0;crc:$cd30de19),(n:'b04-03.39';l:$20000;p:$20000;crc:$ab67e064),
        (n:'b04-02.67';l:$20000;p:$40000;crc:$54040fec),(n:'b04-04.66';l:$20000;p:$60000;crc:$94737e93),
        (n:'b04-19.49';l:$10000;p:0;crc:$ee81fdd8),
        (n:'b04-05.15';l:$20000;p:0;crc:$c22d94ac),(n:'b04-07.14';l:$20000;p:$20000;crc:$b5632a51),
        (n:'b04-06.28';l:$20000;p:$40000;crc:$002ccf39),(n:'b04-08.27';l:$20000;p:$60000;crc:$feafca05),
        (n:'b04-20.76';l:$10000;p:0;crc:$fd1a34cc),());
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
        (n:'sfe-19';l:$10000;p:0;crc:$8346c3ca),(n:'sfe-22';l:$10000;p:$1;crc:$3a4bfaa8),
        (n:'sfe-20';l:$10000;p:$20000;crc:$b40e67ee),(n:'sfe-23';l:$10000;p:$20001;crc:$477c3d5b),
        (n:'sfe-21';l:$10000;p:$40000;crc:$2547192b),(n:'sfe-24';l:$10000;p:$40001;crc:$79680f4e),
        (n:'sf-27.bin';l:$4000;p:0;crc:$2b09b36d),
        (n:'sf-39.bin';l:$20000;p:0;crc:$cee3d292),(n:'sf-38.bin';l:$20000;p:$20000;crc:$2ea99676),
        (n:'sf-41.bin';l:$20000;p:$40000;crc:$e0280495),(n:'sf-40.bin';l:$20000;p:$60000;crc:$c70b30de),
        (n:'sf-25.bin';l:$20000;p:0;crc:$7f23042e),(n:'sf-28.bin';l:$20000;p:$20000;crc:$92f8b91c),
        (n:'sf-30.bin';l:$20000;p:$40000;crc:$b1399856),(n:'sf-34.bin';l:$20000;p:$60000;crc:$96b6ae2e),
        (n:'sf-26.bin';l:$20000;p:$80000;crc:$54ede9f5),(n:'sf-29.bin';l:$20000;p:$a0000;crc:$f0649a67),
        (n:'sf-31.bin';l:$20000;p:$c0000;crc:$8f4dd71a),(n:'sf-35.bin';l:$20000;p:$e0000;crc:$70c00fb4),
        (n:'sf-37.bin';l:$10000;p:0;crc:$23d09d3d),(n:'sf-36.bin';l:$10000;p:$10000;crc:$ea16df6c),
        (n:'sf-32.bin';l:$10000;p:$0;crc:$72df2bd9),(n:'sf-33.bin';l:$10000;p:$10000;crc:$3e99d3d5),
        (n:'sf-15.bin';l:$20000;p:0;crc:$fc0113db),(n:'sf-16.bin';l:$20000;p:$20000;crc:$82e4a6d3),
        (n:'sf-11.bin';l:$20000;p:$40000;crc:$e112df1b),(n:'sf-12.bin';l:$20000;p:$60000;crc:$42d52299),
        (n:'sf-07.bin';l:$20000;p:$80000;crc:$49f340d9),(n:'sf-08.bin';l:$20000;p:$a0000;crc:$95ece9b1),
        (n:'sf-03.bin';l:$20000;p:$c0000;crc:$5ca05781),(n:'sf-17.bin';l:$20000;p:$e0000;crc:$69fac48e),
        (n:'sf-18.bin';l:$20000;p:$100000;crc:$71cfd18d),(n:'sf-13.bin';l:$20000;p:$120000;crc:$fa2eb24b),
        (n:'sf-14.bin';l:$20000;p:$140000;crc:$ad955c95),(n:'sf-09.bin';l:$20000;p:$160000;crc:$41b73a31),
        (n:'sf-10.bin';l:$20000;p:$180000;crc:$91c41c50),(n:'sf-05.bin';l:$20000;p:$1a0000;crc:$538c7cbe),
        (n:'sf-02.bin';l:$8000;p:0;crc:$4a9ac534),
        (n:'sfu-00';l:$20000;p:$0;crc:$a7cce903),(n:'sf-01.bin';l:$20000;p:$20000;crc:$86e0f0d5),());
        //Galaga
        galaga:array[0..13] of tipo_roms=(
        (n:'gg1_1b.3p';l:$1000;p:0;crc:$ab036c9f),(n:'gg1_2b.3m';l:$1000;p:$1000;crc:$d9232240),
        (n:'gg1_3.2m';l:$1000;p:$2000;crc:$753ce503),(n:'gg1_4b.2l';l:$1000;p:$3000;crc:$499fcc76),
        (n:'gg1_5b.3f';l:$1000;p:0;crc:$bb5caae3),(n:'gg1_7b.2c';l:$1000;p:0;crc:$d016686b),
        (n:'prom-5.5n';l:$20;p:0;crc:$54603c6b),(n:'prom-4.2n';l:$100;p:$20;crc:$59b6edab),
        (n:'prom-3.1c';l:$100;p:$120;crc:$4a04bb6b),(n:'gg1_9.4l';l:$1000;p:0;crc:$58b2f47c),
        (n:'prom-1.1d';l:$100;p:0;crc:$7a2815b4),
        (n:'gg1_11.4d';l:$1000;p:0;crc:$ad447c80),(n:'gg1_10.4f';l:$1000;p:$1000;crc:$dd6f1afc),());
        //Dig Dug
        digdug:array[0..18] of tipo_roms=(
        (n:'dd1a.1';l:$1000;p:0;crc:$a80ec984),(n:'dd1a.2';l:$1000;p:$1000;crc:$559f00bd),
        (n:'dd1a.3';l:$1000;p:$2000;crc:$8cbc6fe1),(n:'dd1a.4';l:$1000;p:$3000;crc:$d066f830),
        (n:'dd1a.5';l:$1000;p:0;crc:$6687933b),(n:'dd1a.6';l:$1000;p:$1000;crc:$843d857f),
        (n:'dd1.7';l:$1000;p:0;crc:$a41bce72),
        (n:'136007.113';l:$20;p:0;crc:$4cb9da99),(n:'136007.111';l:$100;p:$20;crc:$00c7c419),
        (n:'136007.112';l:$100;p:$120;crc:$e9b3e08e),(n:'136007.110';l:$100;p:0;crc:$7a2815b4),
        (n:'dd1.9';l:$800;p:0;crc:$f14a6fe1),
        (n:'dd1.15';l:$1000;p:0;crc:$e22957c8),(n:'dd1.14';l:$1000;p:$1000;crc:$2829ec99),
        (n:'dd1.13';l:$1000;p:$2000;crc:$458499e9),(n:'dd1.12';l:$1000;p:$3000;crc:$c58252a0),
        (n:'dd1.11';l:$1000;p:0;crc:$7b383983),(n:'dd1.10b';l:$1000;p:0;crc:$2cf399c2),());
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
        (n:'hrd-hd15';l:$8000;p:0;crc:$bcbd88c3),(n:'hrd-hd14';l:$8000;p:0;crc:$79a3be51),());
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
        (n:'kj-3.bin';l:$4000;p:$8000;crc:$0f50697b),
        (n:'kjclr1.bin';l:$100;p:0;crc:$c3378ac2),(n:'kjclr2.bin';l:$100;p:$100;crc:$2126da97),
        (n:'kjclr3.bin';l:$100;p:$200;crc:$fde62164),(n:'kjprom5.bin';l:$20;p:$300;crc:$5a81dd9f),
        (n:'kjprom4.bin';l:$100;p:$320;crc:$48dc2066),
        (n:'kj-4.bin';l:$8000;p:0;crc:$a499ea10),(n:'kj-6.bin';l:$8000;p:$8000;crc:$815f5c0a),
        (n:'kj-5.bin';l:$8000;p:$10000;crc:$11111759),
        (n:'kj-7.bin';l:$4000;p:0;crc:$121fcccb),(n:'kj-9.bin';l:$4000;p:$4000;crc:$affbe3eb),
        (n:'kj-8.bin';l:$4000;p:$8000;crc:$e057e72a),
        (n:'kj-10.bin';l:$4000;p:0;crc:$74d3ba33),(n:'kj-11.bin';l:$4000;p:$4000;crc:$8ea01455),
        (n:'kj-12.bin';l:$4000;p:$8000;crc:$33367c41),(n:'kj-13.bin';l:$2000;p:$6000;crc:$0a0be3f5),());
        wardner:array[0..28] of tipo_roms=(
        (n:'wardner.17';l:$8000;p:0;crc:$c5dd56fd),(n:'b25-18.rom';l:$10000;p:$8000;crc:$9aab8ee2),
        (n:'b25-19.rom';l:$10000;p:$18000;crc:$95b68813),(n:'wardner.20';l:$8000;p:$28000;crc:$347f411b),
        (n:'b25-16.rom';l:$8000;p:0;crc:$e5202ff8),
        (n:'wardner.07';l:$4000;p:0;crc:$1392b60d),(n:'wardner.06';l:$4000;p:$4000;crc:$0ed848da),
        (n:'wardner.05';l:$4000;p:$8000;crc:$79792c86),
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
        (n:'d5';l:$10000;p:0;crc:$3b73b9c5),
        (n:'h5' ;l:$80000;p:$0;crc:$20e239ff),(n:'h5'; l:$80000;p:$80000;crc:$20e239ff),
        (n:'h10';l:$80000;p:$100000;crc:$ab442855),(n:'h10';l:$80000;p:$180000;crc:$ab442855),
        (n:'h8' ;l:$80000;p:$200000;crc:$83dce5a3),(n:'h8'; l:$80000;p:$280000;crc:$83dce5a3),
        (n:'h6' ;l:$80000;p:$300000;crc:$24e84b24),(n:'h6'; l:$80000;p:$380000;crc:$24e84b24),
        (n:'d1';l:$40000;p:0;crc:$26444ad1),());
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
        (n:'09m_ee02.bin';l:$4000;p:$8000;crc:$7ad95e2f),
        (n:'11e_ee01.bin';l:$4000;p:0;crc:$73cdf3b2),
        (n:'02d_e-02.bin';l:$100;p:0;crc:$8d0d5935),(n:'03d_e-03.bin';l:$100;p:$100;crc:$d3c17efc),
        (n:'04d_e-04.bin';l:$100;p:$200;crc:$58ba964c),(n:'06f_e-05.bin';l:$100;p:$300;crc:$35a03579),
        (n:'l04_e-10.bin';l:$100;p:$400;crc:$1dfad87a),(n:'c04_e-07.bin';l:$100;p:$500;crc:$850064e0),
        (n:'l09_e-11.bin';l:$100;p:$600;crc:$2bb68710),(n:'l10_e-12.bin';l:$100;p:$700;crc:$173184ef),
        (n:'05c_ee00.bin';l:$2000;p:0;crc:$cadb75bd),
        (n:'j11_ee10.bin';l:$4000;p:0;crc:$bc83e265),(n:'j12_ee11.bin';l:$4000;p:$4000;crc:$0e0f300d),
        (n:'h01_ee08.bin';l:$4000;p:0;crc:$96a65c1d),
        (n:'a03_ee06.bin';l:$4000;p:0;crc:$6039bdd1),(n:'a02_ee05.bin';l:$4000;p:$4000;crc:$b32d8252),
        (n:'c01_ee07.bin';l:$4000;p:0;crc:$3625a68d),(n:'h04_ee09.bin';l:$2000;p:$4000;crc:$6057c907),());

        roms_data:array[0..TOTAL_ROMS] of trom_data=(
        (name:'spectrum';description:'Spectrum 16K/48K';rom:@spectrum),
        (name:'spec128';description:'Spectrum 128K';rom:@spec128),
        (name:'plus2';description:'Spectrum +2';rom:@spec_plus2),
        (name:'plus3';description:'Spectrum +2A/+3';rom:@plus3),
        (name:'cpc464';description:'Amstrad CPC 464';rom:@cpc464),
        (name:'cpc664';description:'Amstrad CPC 664';rom:@cpc664),
        (name:'cpc6128';description:'Amstrad CPC 6128';rom:@cpc6128),
        (name:'pacman';description:'Pacman';rom:@pacman),
        (name:'mspacman';description:'Ms-Pacman';rom:@mspacman),
        (name:'phoenix';description:'Phoenix';rom:@phoenix),
        (name:'pleiads';description:'Pleiads';rom:@pleiads),
        (name:'mystston';description:'Mysterious Stones';rom:@mystston),
        (name:'bombjack';description:'Bomb Jack';rom:@bombjack),
        (name:'galaxian';description:'Galaxian';rom:@galaxian),
        (name:'jumpbug';description:'Jump Bug';rom:@jumpbug),
        (name:'mooncrst';description:'Moon Cresta';rom:@mooncrst),
        (name:'scramble';description:'Scramble';rom:@scramble),
        (name:'scobra';description:'Super Cobra';rom:@scobra),
        (name:'frogger';description:'Frogger';rom:@frogger),
        (name:'amidar';description:'Amidar';rom:@amidar),
        (name:'dkong';description:'Donkey Kong';rom:@dkong),
        (name:'dkongjr';description:'Donkey Kong Jr.';rom:@dkongjr),
        (name:'dkong3';description:'Donkey Kong 3';rom:@dkong3),
        (name:'blktiger';description:'Black Tiger';rom:@blktiger),
        (name:'gberet';description:'Green Beret';rom:@gberet),
        (name:'mrgoemon';description:'Mr. Goemon';rom:@mrgoemon),
        (name:'commando';description:'Commando';rom:@commando),
        (name:'gng';description:'Ghost''n Goblins';rom:@gng),
        (name:'mikie';description:'Mikie';rom:@mikie),
        (name:'shaolins';description:'Shaolin''s Road';rom:@shaolins),
        (name:'yiear';description:'Yie Ar Kung-Fu';rom:@yiear),
        (name:'asteroid';description:'Asteroids';rom:@asteroid),
        (name:'sonson';description:'Sonson';rom:@sonson),
        (name:'starforc';description:'Star Force';rom:@starforc),
        (name:'rygar';description:'Rygar';rom:@rygar),
        (name:'silkworm';description:'Silkworm';rom:@silkworm),
        (name:'pitfall2';description:'Pitfall II';rom:@pitfall2),
        (name:'teddybb';description:'Teddy Boy Blues';rom:@teddybb),
        (name:'wboy';description:'Wonder Boy';rom:@wboy),
        (name:'mrviking';description:'Mr Viking';rom:@mrviking),
        (name:'seganinj';description:'Sega Ninja';rom:@seganinj),
        (name:'upndown';description:'Up''n Down';rom:@upndown),
        (name:'flicky';description:'Flicky';rom:@flicky),
        (name:'wbml';description:'Wonder Boy in Monster Land';rom:@wbml),
        (name:'choplift';description:'Choplifter';rom:@choplift),
        (name:'pooyan';description:'Pooyan';rom:@pooyan),
        (name:'jungler';description:'Jungler';rom:@jungler),
        (name:'rallyx';description:'Rally X';rom:@rallyx),
        (name:'nrallyx';description:'New Rally X';rom:@nrallyx),
        (name:'citycon';description:'City Connection';rom:@citycon),
        (name:'btime';description:'Burger Time';rom:@btime),
        (name:'exprraid';description:'Express Raider';rom:@exprraid),
        (name:'sbasketb';description:'Super Basketball';rom:@sbasketb),
        (name:'ladybug';description:'Lady Bug';rom:@ladybug),
        (name:'snapjack';description:'Snapjack';rom:@snapjack),
        (name:'cavenger';description:'Cosmic Avenger';rom:@cavenger),
        (name:'tehkanwc';description:'Tehkan World Cup';rom:@tehkanwc),
        (name:'popeye';description:'Popeye';rom:@popeye),
        (name:'psychic5';description:'Psychic 5';rom:@psychic5),
        (name:'terracre';description:'Terra Cresta';rom:@terracre),
        (name:'kungfum';description:'Kung-Fu Master';rom:@kungfum),
        (name:'spelunkr';description:'Spelunker';rom:@spelunkr),
        (name:'spelunk2';description:'Spelunker II';rom:@spelunk2),
        (name:'ldrun';description:'Lode Runner';rom:@ldrun),
        (name:'ldrun2';description:'Lode Runner II';rom:@ldrun2),
        (name:'shootout';description:'Shoot Out';rom:@shootout),
        (name:'vigilant';description:'Vigilante';rom:@vigilant),
        (name:'jackal';description:'Jackal';rom:@jackal),
        (name:'bublbobl';description:'Bubble Bobble';rom:@bublbobl),
        (name:'prehisle';description:'Prehistoric Isle in 1930';rom:@prehisle),
        (name:'tigeroad';description:'Tiger Road';rom:@tigeroad),
        (name:'f1dream';description:'F1 Dream';rom:@f1dream),
        (name:'snowbros';description:'Snowbros';rom:@snowbros),
        (name:'toki';description:'Toki';rom:@toki),
        (name:'contra';description:'Contra';rom:@contra),
        (name:'mappy';description:'Mappy';rom:@mappy),
        (name:'digdug2';description:'Dig Dug II';rom:@digdug2),
        (name:'superpac';description:'Super Pacman';rom:@spacman),
        (name:'todruaga';description:'The Tower of Druaga';rom:@todruaga),
        (name:'motos';description:'Motos';rom:@motos),
        (name:'rastan';description:'Rastan';rom:@rastan),
        (name:'lwings';description:'Legendary Wings';rom:@lwings),
        (name:'sectionz';description:'Section Z';rom:@sectionz),
        (name:'trojan';description:'Trojan';rom:@trojan),
        (name:'sf';description:'Street Fighter';rom:@sfighter),
        (name:'galaga';description:'Galaga';rom:@galaga),
        (name:'digdug';description:'Dig Dug';rom:@digdug),
        (name:'xsleena';description:'Xain''d Sleena';rom:@xsleena),
        (name:'hardhead';description:'Hard Head';rom:@hardhead),
        (name:'hardhea2';description:'Hard Head 2';rom:@hardhea2),
        (name:'sabotenb';description:'Saboten Bombers';rom:@sabotenb),
        (name:'bjtwin';description:'Bomb Jack Twin';rom:@bjtwin),
        (name:'kncljoe';description:'Knuckle Joe';rom:@kncljoe),
        (name:'wardner';description:'Wardner';rom:@wardner),
        (name:'bigkarnk';description:'Big Karnak';rom:@bigkarnk),
        (name:'thoop';description:'Thunder Hoop';rom:@thoop),
        (name:'squash';description:'Squash';rom:@squash),
        (name:'biomtoy';description:'Biomechanical Toy';rom:@biomtoy),
        (name:'exedexes';description:'Exed Exes';rom:@exedexes),
        (name:'actfancr';description:'Act-Fancer Cybernetick Hyper Weapon';rom:@actfancer));


procedure export_roms;
var
  fichero:textfile;
  f:word;
  rom_data:trom_data;
  rom_file:ptipo_roms;
begin
{$I-}
assignfile(fichero,'dsp_roms_dat.dat');
rewrite(fichero);
if ioresult<>0 then begin
  MessageDlg('Cannot write file: "dsp_roms_dat.dat"',mtError,[mbOk], 0);
  exit;
end;
writeln(fichero,'<?xml version="1.0"?>');
writeln(fichero,'<!DOCTYPE datafile PUBLIC "-//DSP Emulator ROM Datafile//" "http://www.github.com/leniad">');
writeln(fichero,'');
writeln(fichero,'<datafile>');
writeln(fichero,'  <header>');
writeln(fichero,'    <name>DSP Emulator</name>');
writeln(fichero,'    <description>DSP Emulator '+dsp_version+'</description>');
writeln(fichero,'    <category>EMULATION</category>');
writeln(fichero,'    <version>'+dsp_version+'</version>');
writeln(fichero,'    <date>-not specified-</date>');
writeln(fichero,'    <author>Leniad</author>');
writeln(fichero,'    <email>leniad2@hotmail.com</email>');
writeln(fichero,'    <homepage>http://www.github.com/leniad/</homepage>');
writeln(fichero,'    <url>-not specified-</url>');
writeln(fichero,'    <comment>-not specified-</comment>');
writeln(fichero,'    <clrmamepro/>');
writeln(fichero,'  </header>');
for f:=0 to TOTAL_ROMS do begin
  rom_data:=roms_data[f];
  writeln(fichero,'  <game name="'+rom_data.name+'">');
  writeln(fichero,'   <description>'+rom_data.description+'</description>');
  writeln(fichero,'   <year>'+rom_data.year+'</year>');
  writeln(fichero,'   <manufacturer>'+rom_data.manufacturer+'</manufacturer>');
  rom_file:=rom_data.rom;
  repeat
    writeln(fichero,'   <rom name="'+rom_file.n+'" size="'+inttostr(rom_file.l)+'" crc="'+inttohex(rom_file.crc,8)+'"/>');
    inc(rom_file);
  until rom_file.n='';
  writeln(fichero,'   </game>');
end;
writeln(fichero,'</datafile>');
close(fichero);
{$I+}

end;

end.
