unit dec8_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6502,m6809,hd6309,main_engine,controls_engine,ym_2203,ym_3812,gfx_engine,
     rom_engine,pal_engine,sound_engine,misc_functions,mcs51,timer_engine,
     deco_bac06,msm5205;

function iniciar_dec8:boolean;

implementation

const
        //Super Real Darwin
        srd_rom:array[0..1] of tipo_roms=(
        (n:'dy01-e.b14';l:$10000;p:0;crc:$176e9299),(n:'dy00.b16';l:$10000;p:$10000;crc:$2bf6b461));
        srd_snd:tipo_roms=(n:'dy04.d7';l:$8000;p:$8000;crc:$2ae3591c);
        srd_mcu:tipo_roms=(n:'id8751h.mcu';l:$1000;p:0;crc:$11cd6ca4);
        srd_char:tipo_roms=(n:'dy05.b6';l:$4000;p:0;crc:$8780e8a3);
        srd_tiles:array[0..1] of tipo_roms=(
        (n:'dy03.b4';l:$10000;p:0;crc:$44f2a4f9),(n:'dy02.b5';l:$10000;p:$10000;crc:$522d9a9e));
        srd_sprites:array[0..5] of tipo_roms=(
        (n:'dy07.h16';l:$8000;p:0;crc:$97eaba60),(n:'dy06.h14';l:$8000;p:$8000;crc:$c279541b),
        (n:'dy09.k13';l:$8000;p:$10000;crc:$d30d1745),(n:'dy08.k11';l:$8000;p:$18000;crc:$71d645fd),
        (n:'dy11.k16';l:$8000;p:$20000;crc:$fd9ccc5b),(n:'dy10.k14';l:$8000;p:$28000;crc:$88770ab8));
        srd_dip_a:array [0..4] of def_dip2=(
        (mask:3;name:'Coin A';number:4;val4:(3,2,1,0);name4:('1C 2C','1C 3C','1C 4C','1C 6C')),
        (mask:$c;name:'Coin B';number:4;val4:(0,4,8,$c);name4:('4C 1C','3C 1C','2C 1C','1C 1C')),
        (mask:$20;name:'Demo Sounds';number:2;val2:(0,$20);name2:('Off','On')),
        (mask:$40;name:'Flip Screen';number:2;val2:($40,0);name2:('Off','On')),
        (mask:$80;name:'Cabinet';number:2;val2:(0,$80);name2:('Upright','Cocktail')));
        srd_dip_b:array [0..4] of def_dip2=(
        (mask:3;name:'Lives';number:4;val4:(1,3,2,0);name4:('1','3','5','28')),
        (mask:$c;name:'Difficulty';number:4;val4:(8,$c,4,0);name4:('Easy','Normal','Hard','Hardest')),
        (mask:$10;name:'Bonus Life';number:2;val2:($10,0);name2:('Every 50K','Every 100K')),
        (mask:$20;name:'After Stage 10';number:2;val2:($20,0);name2:('Back to Stager 1','Game Over')),
        (mask:$80;name:'Allow Continue';number:2;val2:($80,0);name2:('No','Yes')));
        //Last Mission
        lastmisn_rom:array[0..1] of tipo_roms=(
        (n:'last_mission_dl03-8.13h';l:$8000;p:0;crc:$a4f8d54b),(n:'last_mission_dl04-5.7h';l:$10000;p:$8000;crc:$7dea1552));
        lastmisn_sub:tipo_roms=(n:'last_mission_dl02-5.18h';l:$10000;p:0;crc:$ec9b5daf);
        lastmisn_snd:tipo_roms=(n:'last_mission_dl05-.5h';l:$8000;p:$8000;crc:$1a5df8c0);
        lastmisn_mcu:tipo_roms=(n:'last_mission_dl00-e.18a';l:$1000;p:0;crc:$e97481c6);
        lastmisn_char:tipo_roms=(n:'last_mission_dl01-.2a';l:$8000;p:$8000;crc:$f3787a5d);
        lastmisn_sprites:array[0..3] of tipo_roms=(
        (n:'last_mission_dl11-.13f';l:$8000;p:0;crc:$36579d3b),(n:'last_mission_dl12-.9f';l:$8000;p:$20000;crc:$2ba6737e),
        (n:'last_mission_dl13-.8f';l:$8000;p:$40000;crc:$39a7dc93),(n:'last_mission_dl10-.16f';l:$8000;p:$60000;crc:$fe275ea8));
        lastmisn_tiles:array[0..3] of tipo_roms=(
        (n:'last_mission_dl09-.12k';l:$10000;p:0;crc:$6a5a0c5d),(n:'last_mission_dl08-.14k';l:$10000;p:$20000;crc:$3b38cfce),
        (n:'last_mission_dl07-.15k';l:$10000;p:$40000;crc:$1b60604d),(n:'last_mission_dl06-.17k';l:$10000;p:$60000;crc:$c43c26a7));
        lastmisn_dip_a:array [0..5] of def_dip2=(
        (mask:3;name:'Coin A';number:4;val4:(0,3,2,1);name4:('1C 5C','1C 1C','1C 2C','1C 3C')),
        (mask:$c;name:'Coin B';number:4;val4:(0,$c,8,4);name4:('4C 1C','1C 1C','2C 1C','3C 1C')),
        (mask:$10;name:'Demo Sounds';number:2;val2:($10,0);name2:('Off','On')),
        (mask:$20;name:'Cabinet';number:2;val2:(0,$20);name2:('Upright','Cocktail')),
        (mask:$40;name:'Invulnerability';number:2;val2:($40,0);name2:('Off','On')),
        (mask:$80;name:'Infinite Lives';number:2;val2:($80,0);name2:('Off','On')));
        lastmisn_dip_b:array [0..3] of def_dip2=(
        (mask:$1;name:'Lives';number:2;val2:(1,0);name2:('3','5')),
        (mask:$6;name:'Bonus Life';number:4;val4:(6,4,2,0);name4:('30K 70K 70K+','40K 90K 90K+','40K 80K','50K')),
        (mask:$18;name:'Difficulty';number:4;val4:($18,$10,8,0);name4:('Easy','Normal','Hard','Hardest')),
        (mask:$80;name:'Allow Continue';number:2;val2:($80,0);name2:('No','Yes')));
        //Shackled
        shackled_rom:array[0..4] of tipo_roms=(
        (n:'dk-02.13h';l:$8000;p:0;crc:$87f8fa85),(n:'dk-06.7h';l:$10000;p:$8000;crc:$69ad62d1),
        (n:'dk-05.8h';l:$10000;p:$18000;crc:$598dd128),(n:'dk-04.10h';l:$10000;p:$28000;crc:$36d305d4),
        (n:'dk-03.11h';l:$8000;p:$38000;crc:$6fd90fd1));
        shackled_sub:tipo_roms=(n:'dk-01.18h';l:$10000;p:0;crc:$71fe3bda);
        shackled_snd:tipo_roms=(n:'dk-07.5h';l:$8000;p:$8000;crc:$887e4bcc);
        shackled_mcu:tipo_roms=(n:'dk-e.18a';l:$1000;p:0;crc:$1af06149);
        shackled_char:tipo_roms=(n:'dk-00.2a';l:$8000;p:0;crc:$69b975aa);
        shackled_sprites:array[0..7] of tipo_roms=(
        (n:'dk-12.15k';l:$10000;p:0;crc:$615c2371),(n:'dk-13.14k';l:$10000;p:$10000;crc:$479aa503),
        (n:'dk-14.13k';l:$10000;p:$20000;crc:$cdc24246),(n:'dk-15.11k';l:$10000;p:$30000;crc:$88db811b),
        (n:'dk-16.10k';l:$10000;p:$40000;crc:$061a76bd),(n:'dk-17.9k';l:$10000;p:$50000;crc:$a6c5d8af),
        (n:'dk-18.8k';l:$10000;p:$60000;crc:$4d466757),(n:'dk-19.6k';l:$10000;p:$70000;crc:$1911e83e));
        shackled_tiles:array[0..3] of tipo_roms=(
        (n:'dk-11.12k';l:$10000;p:0;crc:$5cf5719f),(n:'dk-10.14k';l:$10000;p:$20000;crc:$408e6d08),
        (n:'dk-09.15k';l:$10000;p:$40000;crc:$c1557fac),(n:'dk-08.17k';l:$10000;p:$60000;crc:$5e54e9f5));
        shackled_dip_a:array [0..1] of def_dip2=(
        (mask:$1;name:'Flip Screen';number:2;val2:(1,0);name2:('Off','On')),
        (mask:$80;name:'Freeze';number:2;val2:($80,0);name2:('Off','On')));
        shackled_dip_b:array [0..2] of def_dip2=(
        (mask:$6;name:'Coin/Heart/Help/6-Help';number:8;val8:(0,1,2,3,7,6,5,4);name8:('2/100/50/200','4/100/60/300','6/200/70/300','8/200/80/400','10/200/100/500','12/300/100/600','18/400/200/700','20/500/200/800')),
        (mask:$30;name:'Difficulty';number:4;val4:($30,$20,$10,0);name4:('Normal','Hard','very Hard','Hardest')),
        (mask:$80;name:'Demo Sounds';number:2;val2:($80,0);name2:('Off','On')));
        //Gondomania
        gondo_rom:array[0..3] of tipo_roms=(
        (n:'dt00-e.f3';l:$8000;p:0;crc:$912a7eee),(n:'dt01.f5';l:$10000;p:$8000;crc:$c39bb877),
        (n:'dt02.f6';l:$10000;p:$18000;crc:$925307a4),(n:'dt03-e.f7';l:$10000;p:$28000;crc:$ee7475eb));
        gondo_snd:tipo_roms=(n:'dt05-e.h5';l:$8000;p:$8000;crc:$ec08aa29);
        gondo_mcu:tipo_roms=(n:'dt-e.b1';l:$1000;p:0;crc:$0d0532ec);
        gondo_char:tipo_roms=(n:'dt14-e.b18';l:$8000;p:0;crc:$00cbe9c8);
        gondo_tiles:array[0..7] of tipo_roms=(
        (n:'dt08.h10';l:$10000;p:0;crc:$aec483f5),(n:'dt09.h12';l:$8000;p:$10000;crc:$446f0ce0),
        (n:'dt06.h7';l:$10000;p:$18000;crc:$3fe1527f),(n:'dt07.h9';l:$8000;p:$28000;crc:$61f9bce5),
        (n:'dt12.h16';l:$10000;p:$30000;crc:$1a72ca8d),(n:'dt13.h18';l:$8000;p:$40000;crc:$ccb81aec),
        (n:'dt10.h13';l:$10000;p:$48000;crc:$cfcfc9ed),(n:'dt11.h15';l:$8000;p:$58000;crc:$53e9cf17));
        gondo_sprites:array[0..7] of tipo_roms=(
        (n:'dt19.f13';l:$10000;p:0;crc:$da2abe4b),(n:'dt20-e.f15';l:$8000;p:$10000;crc:$0eef7f56),
        (n:'dt16.f9';l:$10000;p:$20000;crc:$e9955d8f),(n:'dt18-e.f12';l:$8000;p:$30000;crc:$2b2d1468),
        (n:'dt15.f8';l:$10000;p:$40000;crc:$a54b2eb6),(n:'dt17-e.f11';l:$8000;p:$50000;crc:$75ae349a),
        (n:'dt21.f16';l:$10000;p:$60000;crc:$1c5f682d),(n:'dt22-e.f18';l:$8000;p:$70000;crc:$c8ffb148));
        gondo_dip_a:array [0..4] of def_dip2=(
        (mask:3;name:'Coin A';number:4;val4:(0,2,3,1);name4:('2C 1C','1C 1C','1C 2C','1C 3C')),
        (mask:$c;name:'Coin B';number:4;val4:(0,$c,8,4);name4:('2C 1C','1C 1C','1C 2C','1C 3C')),
        (mask:$20;name:'Demo Sounds';number:2;val2:(0,$20);name2:('Off','On')),
        (mask:$40;name:'Flip Screen';number:2;val2:($40,0);name2:('Off','On')),
        (mask:$80;name:'Swap buttons';number:2;val2:($80,0);name2:('Off','On')));
        gondo_dip_b:array [0..2] of def_dip2=(
        (mask:3;name:'Lives';number:4;val4:(1,3,2,0);name4:('1','3','5','99')),
        (mask:$c;name:'Difficulty';number:4;val4:(8,$c,4,0);name4:('Easy','Normal','Hard','Hardest')),
        (mask:$10;name:'Allow Continue';number:2;val2:($10,0);name2:('No','Yes')));
        //Garyo Retsuden
        garyoret_rom:array[0..4] of tipo_roms=(
        (n:'dv00';l:$8000;p:0;crc:$cceaaf05),(n:'dv01';l:$10000;p:$8000;crc:$c33fc18a),
        (n:'dv02';l:$10000;p:$18000;crc:$f9e26ce7),(n:'dv03';l:$10000;p:$28000;crc:$55d8d699),
        (n:'dv04';l:$10000;p:$38000;crc:$ed3d00ee));
        garyoret_snd:tipo_roms=(n:'dv05';l:$8000;p:$8000;crc:$c97c347f);
        garyoret_mcu:tipo_roms=(n:'dv__.mcu';l:$1000;p:0;crc:$37cacec6);
        garyoret_char:tipo_roms=(n:'dv14';l:$8000;p:0;crc:$fb2bc581);
        garyoret_tiles:array[0..7] of tipo_roms=(
        (n:'dv08';l:$10000;p:0;crc:$89c13e15),(n:'dv09';l:$10000;p:$10000;crc:$6a345a23),
        (n:'dv06';l:$10000;p:$20000;crc:$1eb52a20),(n:'dv07';l:$10000;p:$30000;crc:$e7346ef8),
        (n:'dv12';l:$10000;p:$40000;crc:$46ba5af4),(n:'dv13';l:$10000;p:$50000;crc:$a7af6dfd),
        (n:'dv10';l:$10000;p:$60000;crc:$68b6d75c),(n:'dv11';l:$10000;p:$70000;crc:$b5948aee));
        garyoret_sprites:array[0..7] of tipo_roms=(
        (n:'dv22';l:$10000;p:0;crc:$cef0367e),(n:'dv21';l:$8000;p:$10000;crc:$90042fb7),
        (n:'dv20';l:$10000;p:$20000;crc:$451a2d8c),(n:'dv19';l:$8000;p:$30000;crc:$14e1475b),
        (n:'dv18';l:$10000;p:$40000;crc:$7043bead),(n:'dv17';l:$8000;p:$50000;crc:$28f449d7),
        (n:'dv16';l:$10000;p:$60000;crc:$37e4971e),(n:'dv15';l:$8000;p:$70000;crc:$ca41b6ac));
        garyoret_dip_a:array [0..3] of def_dip2=(
        (mask:3;name:'Coin A';number:4;val4:(0,2,3,1);name4:('2C 1C','1C 1C','1C 2C','1C 3C')),
        (mask:$c;name:'Coin B';number:4;val4:(0,$c,8,4);name4:('2C 1C','1C 1C','1C 2C','1C 3C')),
        (mask:$20;name:'Demo Sounds';number:2;val2:(0,$20);name2:('Off','On')),
        (mask:$40;name:'Flip Screen';number:2;val2:($40,0);name2:('Off','On')));
        garyoret_dip_b:array [0..1] of def_dip2=(
        (mask:1;name:'Lives';number:2;val2:(1,0);name2:('3','5')),
        (mask:$c;name:'Difficulty';number:4;val4:(8,$c,4,0);name4:('Easy','Normal','Hard','Hardest')));
        //Captain Silver
        csilver_rom:array[0..2] of tipo_roms=(
        (n:'dx03-12.18d';l:$8000;p:0;crc:$2d926e7c),(n:'dx01.12d';l:$10000;p:$8000;crc:$570fb50c),
        (n:'dx02.13d';l:$10000;p:$18000;crc:$58625890));
        csilver_sub:tipo_roms=(n:'dx04-1.19d';l:$10000;p:0;crc:$29432691);
        csilver_snd:tipo_roms=(n:'dx05.3f';l:$10000;p:0;crc:$eb32cf25);
        csilver_mcu:tipo_roms=(n:'dx-8.19a';l:$1000;p:0;crc:$c0266263);
        csilver_char:tipo_roms=(n:'dx00.3d';l:$8000;p:0;crc:$f01ef985);
        csilver_sprites:array[0..2] of tipo_roms=(
        (n:'dx14.15k';l:$10000;p:0;crc:$80f07915),(n:'dx13.13k';l:$10000;p:$20000;crc:$d32c02e7),
        (n:'dx12.10k';l:$10000;p:$40000;crc:$ac78b76b));
        csilver_tiles:array[0..5] of tipo_roms=(
        (n:'dx06.5f';l:$10000;p:0;crc:$b6fb208c),(n:'dx07.7f';l:$10000;p:$10000;crc:$ee3e1817),
        (n:'dx08.8f';l:$10000;p:$20000;crc:$705900fe),(n:'dx09.10f';l:$10000;p:$30000;crc:$3192571d),
        (n:'dx10.12f';l:$10000;p:$40000;crc:$3ef77a32),(n:'dx11.13f';l:$10000;p:$50000;crc:$9cf3d5b8));
        csilver_dip_a:array [0..4] of def_dip2=(
        (mask:3;name:'Coin A';number:4;val4:(3,2,1,0);name4:('1C 2C','1C 3C','1C 4C','1C 6C')),
        (mask:$c;name:'Coin B';number:4;val4:(0,4,8,$c);name4:('4C 1C','3C 1C','2C 1C','1C 1C')),
        (mask:$20;name:'Demo Sounds';number:2;val2:(0,$20);name2:('Off','On')),
        (mask:$40;name:'Flip Screen';number:2;val2:($40,0);name2:('Off','On')),
        (mask:$80;name:'Cabinet';number:2;val2:(0,$80);name2:('Upright','Cocktail')));
        csilver_dip_b:array [0..3] of def_dip2=(
        (mask:3;name:'Lives';number:4;val4:(1,3,2,0);name4:('1','3','5','255')),
        (mask:$c;name:'Difficulty';number:4;val4:(8,$c,4,0);name4:('Easy','Normal','Hard','Hardest')),
        (mask:$10;name:'Allow Continue';number:2;val2:(0,$10);name2:('No','Yes')),
        (mask:$40;name:'No key for door';number:2;val2:($40,0);name2:('Off','On')));
        //Cobra Command
        cobracom_rom:array[0..2] of tipo_roms=(
        (n:'el11-5.5j';l:$8000;p:0;crc:$af0a8b05),(n:'el12-4.7j';l:$10000;p:$8000;crc:$7a44ef38),
        (n:'el13.9j';l:$10000;p:$18000;crc:$04505acb));
        cobracom_snd:tipo_roms=(n:'el10-4.1f';l:$8000;p:$8000;crc:$edfad118);
        cobracom_char:tipo_roms=(n:'el14.14j';l:$8000;p:0;crc:$47246177);
        cobracom_sprites:array[0..3] of tipo_roms=(
        (n:'el00-4.2a';l:$10000;p:0;crc:$122da2a8),(n:'el01-4.3a';l:$10000;p:$20000;crc:$27bf705b),
        (n:'el02-4.5a';l:$10000;p:$40000;crc:$c86fede6),(n:'el03-4.6a';l:$10000;p:$60000;crc:$1d8a855b));
        cobracom_tiles1:array[0..3] of tipo_roms=(
        (n:'el05.15a';l:$10000;p:0;crc:$1c4f6033),(n:'el06.16a';l:$10000;p:$20000;crc:$d24ba794),
        (n:'el04.13a';l:$10000;p:$40000;crc:$d80a49ce),(n:'el07.18a';l:$10000;p:$60000;crc:$6d771fc3));
        cobracom_tiles2:array[0..1] of tipo_roms=(
        (n:'el08.7d';l:$10000;p:0;crc:$cb0dcf4c),(n:'el09.9d';l:$10000;p:$10000;crc:$1fae5be7));
        cobracom_dip_a:array [0..4] of def_dip2=(
        (mask:3;name:'Coin A';number:4;val4:(0,1,3,2);name4:('3C 1C','2C 1C','1C 1C','1C 2C')),
        (mask:$c;name:'Coin B';number:4;val4:(0,4,$c,8);name4:('3C 1C','2C 1C','1C 1C','1C 2C')),
        (mask:$20;name:'Demo Sounds';number:2;val2:(0,$20);name2:('Off','On')),
        (mask:$40;name:'Flip Screen';number:2;val2:($40,0);name2:('Off','On')),
        (mask:$80;name:'Cabinet';number:2;val2:(0,$80);name2:('Upright','Cocktail')));
        cobracom_dip_b:array [0..3] of def_dip2=(
        (mask:3;name:'Lives';number:4;val4:(3,2,1,0);name4:('3','4','5','99')),
        (mask:$c;name:'Difficulty';number:4;val4:(8,$c,4,0);name4:('Easy','Normal','Hard','Hardest')),
        (mask:$10;name:'Allow Continue';number:2;val2:(0,$10);name2:('No','Yes')),
        (mask:$20;name:'Bonus Life';number:2;val2:($20,0);name2:('50K 150K','100K 200K')));
        //The Real Ghostbusters
        ghostb_rom:array[0..4] of tipo_roms=(
        (n:'dz01-22.1d';l:$8000;p:0;crc:$fc65fdf2),(n:'dz02.3d';l:$10000;p:$8000;crc:$8e117541),
        (n:'dz03.4d';l:$10000;p:$18000;crc:$5606a8f4),(n:'dz04-21.6d';l:$10000;p:$28000;crc:$7d46582f),
        (n:'dz05-21.7d';l:$10000;p:$38000;crc:$23e1c758));
        ghostb_snd:tipo_roms=(n:'dz06.5f';l:$8000;p:$8000;crc:$798f56df);
        ghostb_mcu:tipo_roms=(n:'dz-1.1b';l:$1000;p:0;crc:$9f5f3cb5);
        ghostb_char:tipo_roms=(n:'dz00.16b';l:$8000;p:0;crc:$992b4f31);
        ghostb_sprites:array[0..7] of tipo_roms=(
        (n:'dz15.14f';l:$10000;p:0;crc:$a01a5fd9),(n:'dz16.15f';l:$10000;p:$10000;crc:$5a9a344a),
        (n:'dz12.9f';l:$10000;p:$20000;crc:$817fae99),(n:'dz14.12f';l:$10000;p:$30000;crc:$0abbf76d),
        (n:'dz11.8f';l:$10000;p:$40000;crc:$a5e19c24),(n:'dz13.1f';l:$10000;p:$50000;crc:$3e7c0405),
        (n:'dz17.17f';l:$10000;p:$60000;crc:$40361b8b),(n:'dz18.18f';l:$10000;p:$70000;crc:$8d219489));
        ghostb_tiles:array[0..3] of tipo_roms=(
        (n:'dz07.12f';l:$10000;p:0;crc:$e7455167),(n:'dz08.14f';l:$10000;p:$10000;crc:$32f9ddfe),
        (n:'dz09.15f';l:$10000;p:$20000;crc:$bb6efc02),(n:'dz10.17f';l:$10000;p:$30000;crc:$6ef9963b));
        ghostb_proms:array[0..1] of tipo_roms=(
        (n:'dz19a.10d';l:$400;p:0;crc:$47e1f83b),(n:'dz20a.11d';l:$400;p:$400;crc:$d8fe2d99));
        ghostb_dip_a:array [0..1] of def_dip2=(
        (mask:$20;name:'Demo Sounds';number:2;val2:(0,$20);name2:('Off','On')),
        (mask:$40;name:'Flip Screen';number:2;val2:($40,0);name2:('Off','On')));
        ghostb_dip_b:array [0..4] of def_dip2=(
        (mask:3;name:'Lives';number:4;val4:(1,3,2,0);name4:('1','3','5','Invulnerability')),
        (mask:$c;name:'Difficulty';number:4;val4:(8,$c,4,0);name4:('Easy','Normal','Hard','Hardest')),
        (mask:$30;name:'Max Scene Time';number:4;val4:(0,$10,$30,$20);name4:('4:00','4:30','5:00','6:00')),
        (mask:$40;name:'Allow Continue';number:2;val2:($40,0);name2:('No','Yes')),
        (mask:$80;name:'Energy Bonus';number:2;val2:($80,0);name2:('None','+25%')));
        //Psycho-Nicks Oscar
        oscar_rom:array[0..1] of tipo_roms=(
        (n:'du10';l:$8000;p:0;crc:$120040d8),(n:'ed09';l:$10000;p:$8000;crc:$e2d4bba9));
        oscar_sub:tipo_roms=(n:'du11';l:$10000;p:0;crc:$ff45c440);
        oscar_snd:tipo_roms=(n:'ed12';l:$8000;p:$8000;crc:$432031c5);
        oscar_char:tipo_roms=(n:'ed08';l:$4000;p:0;crc:$308ac264);
        oscar_sprites:array[0..3] of tipo_roms=(
        (n:'ed04';l:$10000;p:0;crc:$416a791b),(n:'ed05';l:$10000;p:$20000;crc:$fcdba431),
        (n:'ed06';l:$10000;p:$40000;crc:$7d50bebc),(n:'ed07';l:$10000;p:$60000;crc:$8fdf0fa5));
        oscar_tiles:array[0..3] of tipo_roms=(
        (n:'ed01';l:$10000;p:0;crc:$d3a58e9e),(n:'ed03';l:$10000;p:$20000;crc:$4fc4fb0f),
        (n:'ed00';l:$10000;p:$40000;crc:$ac201f2d),(n:'ed02';l:$10000;p:$60000;crc:$7ddc5651));
        oscar_dip_a:array [0..5] of def_dip2=(
        (mask:3;name:'Coin A';number:4;val4:(3,2,1,0);name4:('1C 2C','1C 3C','1C 4C','1C 6C')),
        (mask:$c;name:'Coin B';number:4;val4:(0,4,8,$c);name4:('4C 1C','3C 1C','2C 1C','1C 1C')),
        (mask:$10;name:'Freeze Mode';number:2;val2:($10,0);name2:('Off','On')),
        (mask:$20;name:'Demo Sounds';number:2;val2:(0,$20);name2:('Off','On')),
        (mask:$40;name:'Flip Screen';number:2;val2:($40,0);name2:('Off','On')),
        (mask:$80;name:'Cabinet';number:2;val2:(0,$80);name2:('Upright','Cocktail')));
        oscar_dip_b:array [0..4] of def_dip2=(
        (mask:3;name:'Lives';number:4;val4:(1,3,2,0);name4:('1','3','5','Infinite')),
        (mask:$c;name:'Difficulty';number:4;val4:(8,$c,4,0);name4:('Easy','Normal','Hard','Hardest')),
        (mask:$30;name:'Bonus Life';number:4;val4:($30,$20,$10,0);name4:('40K 100K 60K+','60K 160K 100K+','90K 240K 150K+','50K')),
        (mask:$40;name:'Invulnerability';number:2;val2:($40,0);name2:('Off','On')),
        (mask:$80;name:'Allow Continue';number:2;val2:(0,$80);name2:('No','Yes')));
        CPU_SYNC=10;

var
  scroll_y,scroll_x,i8751_return,i8751_value:word;
  last_p2,i8751_port0,i8751_port1,rom_bank,sound_latch,vblank:byte;
  screen_prio,secclr,sub_nmi,main_nmi:boolean;
  rom:array[0..$f,0..$3fff] of byte;
  snd_dec:array[0..$7fff] of byte;
  eventos_gondo_call:procedure;
  video_update_gondo:procedure;
  call_io_mcu_read:function(direccion:word):byte;
  call_io_mcu_write:procedure(direccion:word;valor:byte);
  //Captain Silver
  msm5205_next,sound_rom_bank:byte;
	msm5205_toggle:boolean;
  sound_rom:array[0..1,0..$3fff] of byte;

procedure update_video_srd;
var
  f,nchar,color,atrib,x,y:word;
procedure draw_sprites_srd(pri:byte);
var
  x,y,f,nchar:word;
  color,atrib:byte;
  flipx:boolean;
begin
  for f:=0 to $7f do begin
    atrib:=buffer_sprites[(f*4)+1];
		color:=(atrib and 3)+((atrib and 8) shr 1);
		if ((pri=0) and (color<>0)) then continue;
		if ((pri=1) and (color=0)) then continue;
		nchar:=buffer_sprites[(f*4)+3]+((atrib and $e0) shl 3);
		if (nchar=0) then continue;
    y:=buffer_sprites[f*4];
    if y=248 then continue;
		x:=241-buffer_sprites[(f*4)+2];
		flipx:=(atrib and 4)<>0;
		if (atrib and $10)<>0 then begin
      put_gfx_sprite_diff(nchar,$40+(color shl 3),flipx,false,2,0,0);
      put_gfx_sprite_diff(nchar+1,$40+(color shl 3),flipx,false,2,0,16);
      actualiza_gfx_sprite_size(x,y,4,16,32);
    end else begin
      put_gfx_sprite(nchar,$40+(color shl 3),flipx,false,2);
      actualiza_gfx_sprite(x,y,4,2);
    end;
	end;
end;
begin
for f:=0 to $1ff do begin
    atrib:=memoria[$1400+(f*2)];
    color:=(atrib and $f0) shr 4;
    if (gfx[1].buffer[f] or buffer_color[color]) then begin
      x:=f mod 32;
      y:=f div 32;
      nchar:=memoria[$1401+(f*2)]+((atrib and 3) shl 8);
      put_gfx(x*16,y*16,nchar,color shl 4,2,1);
      if color=0 then put_gfx_block_trans(x*16,y*16,3,16,16)
        else put_gfx_trans(x*16,y*16,nchar,color shl 4,3,1);
      gfx[1].buffer[f]:=false;
    end;
end;
//Foreground
for f:=0 to $3ff do begin
  if gfx[0].buffer[f] then begin
    x:=f mod 32;
    y:=f div 32;
    nchar:=memoria[$800+f];
    put_gfx_trans(x*8,y*8,nchar,$80,1,0);
    gfx[0].buffer[f]:=false;
 end;
end;
scroll__x(2,4,scroll_x);
draw_sprites_srd(0);
scroll__x(3,4,scroll_x);
draw_sprites_srd(1);
actualiza_trozo(0,0,256,256,1,0,0,256,256,4);
actualiza_trozo_final(0,8,256,240,4);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure draw_sprites(npant:byte);
var
  extra,fx,fy:boolean;
  atrib,x,y,f,nchar,nchar2:word;
  color:byte;
begin
for f:=0 to $1ff do begin
    y:=buffer_sprites_w[f*4];
    if ((y and $8000)=0) then continue;
    atrib:=buffer_sprites_w[(f*4)+1];
    if ((atrib and 1)=0) then continue;
    y:=y and $1ff;
    nchar:=buffer_sprites_w[(f*4)+3];
    color:=nchar shr 12;
    nchar:=nchar and $fff;
    x:=buffer_sprites_w[(f*4)+2] and $1ff;
    extra:=(atrib and $10)<>0;
    fy:=(atrib and 2)<>0;
    fx:=(atrib and 4)<>0;
    if extra then begin
       y:=y+16;
       nchar:=nchar and $ffe;
    end;
    x:=(x+16) and $1ff;
    y:=(y+16) and $1ff;
    x:=(256-x) and $1ff;
    y:=(256-y) and $1ff;
    if (extra and fy) then begin
       nchar2:=nchar;
       nchar:=nchar+1;
    end else nchar2:=nchar+1;
    put_gfx_sprite(nchar,(color shl 4)+256,fx,fy,2);
    actualiza_gfx_sprite(x,y,npant,2);
    if extra then begin
       put_gfx_sprite(nchar2,(color shl 4)+256,fx,fy,2);
       actualiza_gfx_sprite(x,y+16,npant,2);
    end;
end;
end;

procedure update_video_lastmissn;
var
  pos,f,nchar,x,y:word;
  color,atrib:byte;
begin
for f:=0 to $3ff do begin
    x:=f mod 32;
    y:=f div 32;
    //Foreground
    atrib:=memoria[$2000+(f*2)];
    color:=(atrib and $c0) shr 6;
    if ((gfx[0].buffer[f]) or buffer_color[color+$10]) then begin
      nchar:=memoria[$2001+(f*2)]+((atrib and 3) shl 8);
      put_gfx_trans(x*8,y*8,nchar,color shl 3,1,0);
      gfx[0].buffer[f]:=false;
    end;
    //Background
    pos:=((x and $f)+((y and $f) shl 4))+((x and $10) shl 4)+((y and $10) shl 5);
    atrib:=memoria[$3800+(pos*2)];
    color:=(atrib and $f0) shr 4;
    if (gfx[1].buffer[pos] or buffer_color[color]) then begin
      nchar:=memoria[$3801+(pos*2)]+((atrib and $f) shl 8);
      put_gfx(x*16,y*16,nchar,(color shl 4)+$300,2,1);
      if screen_prio then begin
        if (color and 8)=0 then put_gfx_block_trans(x*16,y*16,3,16,16)
          else put_gfx_trans(x*16,y*16,nchar,(color shl 4)+$300,3,1);
      end;
      gfx[1].buffer[pos]:=false;
    end;
end;
scroll_x_y(2,4,scroll_x,scroll_y);
draw_sprites(4);
if screen_prio then scroll_x_y(3,4,scroll_x,scroll_y);
actualiza_trozo(0,0,256,256,1,0,0,256,256,4);
actualiza_trozo_final(0,8,256,240,4);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure update_video_gondo;
var
  f,nchar,x,y:word;
  color,atrib:byte;
begin
for f:=0 to $3ff do begin
    x:=f mod 32;
    y:=f div 32;
    //Foreground
    atrib:=memoria[$1800+(f*2)];
    color:=(atrib and $70) shr 4;
    if ((gfx[0].buffer[f]) or buffer_color[color+$10]) then begin
      nchar:=memoria[$1801+(f*2)]+((atrib and 3) shl 8);
      put_gfx_trans(x*8,y*8,nchar,color shl 3,1,0);
      gfx[0].buffer[f]:=false;
    end;
    //Background
    atrib:=memoria[$2000+(f*2)];
    color:=(atrib and $f0) shr 4;
    if (gfx[1].buffer[f] or buffer_color[color]) then begin
      nchar:=memoria[$2001+(f*2)]+((atrib and $f) shl 8);
      put_gfx(x*16,y*16,nchar,(color shl 4)+$300,2,1);
      if screen_prio then begin
        if (color and 8)=0 then put_gfx_block_trans(x*16,y*16,3,16,16)
          else put_gfx_trans(x*16,y*16,nchar,(color shl 4)+$300,3,1);
      end;
      gfx[1].buffer[f]:=false;
    end;
end;
scroll_x_y(2,4,scroll_x,scroll_y);
draw_sprites(4);
if screen_prio then scroll_x_y(3,4,scroll_x,scroll_y);
actualiza_trozo(0,0,256,256,1,0,0,256,256,4);
actualiza_trozo_final(0,8,256,240,4);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure update_video_cobracom;
var
  f,nchar,x,y:word;
  color,atrib:byte;
begin
for f:=0 to $3ff do begin
    //Foreground
    atrib:=memoria[$2000+(f*2)];
    color:=(atrib and $e0) shr 5;
    if ((gfx[0].buffer[f]) or buffer_color[color]) then begin
      x:=f mod 32;
      y:=f div 32;
      nchar:=memoria[$2001+(f*2)]+((atrib and 3) shl 8);
      put_gfx_trans(x*8,y*8,nchar,color shl 2,8,0);
      gfx[0].buffer[f]:=false;
    end;
end;
bac06_0.tile_1.update_pf(1,false,false);
bac06_0.tile_2.update_pf(2,true,false);
bac06_0.tile_1.show_pf;
bac06_0.draw_sprites(4,0,3);
bac06_0.tile_2.show_pf;
bac06_0.draw_sprites(4,4,3);
actualiza_trozo(0,0,256,256,8,0,0,256,256,7);
actualiza_trozo_final(0,8,256,240,7);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure update_video_ghostb;
var
  f,nchar,x,y:word;
  color,atrib:byte;
begin
for f:=0 to $3ff do begin
    if gfx[0].buffer[f] then begin
      x:=f mod 32;
      y:=f div 32;
      atrib:=memoria[$1800+(f*2)];
      color:=(atrib and $c) shr 2;
      nchar:=memoria[$1801+(f*2)]+((atrib and 3) shl 8);
      put_gfx_trans(x*8,y*8,nchar,color shl 3,8,0);
      gfx[0].buffer[f]:=false;
    end;
end;
bac06_0.tile_1.update_pf(1,false,false);
bac06_0.tile_1.show_pf;
draw_sprites(7);
actualiza_trozo(0,0,256,256,8,0,0,256,256,7);
actualiza_trozo_final(0,8,256,240,7);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure update_video_oscar;
var
  f,nchar,x,y:word;
  color,atrib:byte;
begin
for f:=0 to $3ff do begin
    //Foreground
    atrib:=memoria[$2000+(f*2)];
    color:=(atrib and $f0) shr 6;
    if ((gfx[0].buffer[f]) or buffer_color[color]) then begin
      x:=f mod 32;
      y:=f div 32;
      nchar:=memoria[$2001+(f*2)]+((atrib and 3) shl 8);
      put_gfx_trans(x*8,y*8,nchar,(color shl 3)+$100,8,0);
      gfx[0].buffer[f]:=false;
    end;
end;
bac06_0.tile_1.update_pf(1,false,true);
bac06_0.tile_1.show_pf;
bac06_0.draw_sprites(0,0,2);
bac06_0.tile_1.show_pf_pri;
actualiza_trozo(0,0,256,256,8,0,0,256,256,7);
actualiza_trozo_final(0,8,256,240,7);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure eventos_srd;
begin
if event.arcade then begin
  //P1
  if arcade_input.right[0] then marcade.in0:=marcade.in0 and $fe else marcade.in0:=marcade.in0 or 1;
  if arcade_input.left[0] then marcade.in0:=marcade.in0 and $fd else marcade.in0:=marcade.in0 or 2;
  if arcade_input.up[0] then marcade.in0:=marcade.in0 and $fb else marcade.in0:=marcade.in0 or 4;
  if arcade_input.down[0] then marcade.in0:=marcade.in0 and $f7 else marcade.in0:=marcade.in0 or 8;
  if arcade_input.but0[0] then marcade.in0:=marcade.in0 and $ef else marcade.in0:=marcade.in0 or $10;
  if arcade_input.but1[0] then marcade.in0:=marcade.in0 and $df else marcade.in0:=marcade.in0 or $20;
  if arcade_input.start[0] then marcade.in0:=marcade.in0 and $bf else marcade.in0:=marcade.in0 or $40;
  if arcade_input.start[1] then marcade.in0:=marcade.in0 and $7f else marcade.in0:=marcade.in0 or $80;
  //P2
  if arcade_input.right[1] then marcade.in1:=marcade.in1 and $fe else marcade.in1:=marcade.in1 or 1;
  if arcade_input.left[1] then marcade.in1:=marcade.in1 and $fd else marcade.in1:=marcade.in1 or 2;
  if arcade_input.up[1] then marcade.in1:=marcade.in1 and $fb else marcade.in1:=marcade.in1 or 4;
  if arcade_input.down[1] then marcade.in1:=marcade.in1 and $f7 else marcade.in1:=marcade.in1 or 8;
  if arcade_input.but0[1] then marcade.in1:=marcade.in1 and $ef else marcade.in1:=marcade.in1 or $10;
  if arcade_input.but1[1] then marcade.in1:=marcade.in1 and $df else marcade.in1:=marcade.in1 or $20;
  //i8751
  if arcade_input.coin[1] then marcade.in2:=marcade.in2 and $df else marcade.in2:=marcade.in2 or $20;
  if arcade_input.coin[0] then marcade.in2:=marcade.in2 and $bf else marcade.in2:=marcade.in2 or $40;
end;
end;

procedure eventos_lastmisn;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in0:=marcade.in0 and $fe else marcade.in0:=marcade.in0 or 1;
  if arcade_input.down[0] then marcade.in0:=marcade.in0 and $fd else marcade.in0:=marcade.in0 or 2;
  if arcade_input.left[0] then marcade.in0:=marcade.in0 and $fb else marcade.in0:=marcade.in0 or 4;
  if arcade_input.right[0] then marcade.in0:=marcade.in0 and $f7 else marcade.in0:=marcade.in0 or 8;
  if arcade_input.but0[0] then marcade.in0:=marcade.in0 and $ef else marcade.in0:=marcade.in0 or $10;
  if arcade_input.but1[0] then marcade.in0:=marcade.in0 and $df else marcade.in0:=marcade.in0 or $20;
  if arcade_input.but2[0] then marcade.in0:=marcade.in0 and $bf else marcade.in0:=marcade.in0 or $40;
  //P2
  if arcade_input.up[1] then marcade.in1:=marcade.in1 and $fe else marcade.in1:=marcade.in1 or 1;
  if arcade_input.down[1] then marcade.in1:=marcade.in1 and $fd else marcade.in1:=marcade.in1 or 2;
  if arcade_input.left[1] then marcade.in1:=marcade.in1 and $fb else marcade.in1:=marcade.in1 or 4;
  if arcade_input.right[1] then marcade.in1:=marcade.in1 and $f7 else marcade.in1:=marcade.in1 or 8;
  if arcade_input.but0[1] then marcade.in1:=marcade.in1 and $ef else marcade.in1:=marcade.in1 or $10;
  if arcade_input.but1[1] then marcade.in1:=marcade.in1 and $df else marcade.in1:=marcade.in1 or $20;
  if arcade_input.but2[1] then marcade.in1:=marcade.in1 and $bf else marcade.in1:=marcade.in1 or $40;
  //i8751
  if arcade_input.coin[0] then begin
    marcade.in2:=marcade.in2 and $df;
  end else begin
    marcade.in2:=marcade.in2 or $20;
    mcs51_0.change_irq0(ASSERT_LINE);
  end;
  if arcade_input.coin[1] then begin
    marcade.in2:=marcade.in2 and $bf;
  end else begin
    marcade.in2:=marcade.in2 or $40;
    mcs51_0.change_irq0(ASSERT_LINE);
  end;
  //System
  if arcade_input.start[0] then marcade.in3:=marcade.in3 and $fb else marcade.in3:=marcade.in3 or 4;
  if arcade_input.start[1] then marcade.in3:=marcade.in3 and $f7 else marcade.in3:=marcade.in3 or 8;
end;
end;

procedure eventos_gondo;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in0:=marcade.in0 and $fe else marcade.in0:=marcade.in0 or 1;
  if arcade_input.down[0] then marcade.in0:=marcade.in0 and $fd else marcade.in0:=marcade.in0 or 2;
  if arcade_input.left[0] then marcade.in0:=marcade.in0 and $fb else marcade.in0:=marcade.in0 or 4;
  if arcade_input.right[0] then marcade.in0:=marcade.in0 and $f7 else marcade.in0:=marcade.in0 or 8;
  //P2
  if arcade_input.up[1] then marcade.in1:=marcade.in1 and $fe else marcade.in1:=marcade.in1 or 1;
  if arcade_input.down[1] then marcade.in1:=marcade.in1 and $fd else marcade.in1:=marcade.in1 or 2;
  if arcade_input.left[1] then marcade.in1:=marcade.in1 and $fb else marcade.in1:=marcade.in1 or 4;
  if arcade_input.right[1] then marcade.in1:=marcade.in1 and $f7 else marcade.in1:=marcade.in1 or 8;
  //i8751
  if arcade_input.coin[0] then begin
    marcade.in2:=marcade.in2 and $df;
  end else begin
    marcade.in2:=marcade.in2 or $20;
    mcs51_0.change_irq0(ASSERT_LINE);
  end;
  if arcade_input.coin[1] then begin
    marcade.in2:=marcade.in2 and $bf;
  end else begin
    marcade.in2:=marcade.in2 or $40;
    mcs51_0.change_irq0(ASSERT_LINE);
  end;
  //System
  if arcade_input.start[0] then marcade.in3:=marcade.in3 and $fe else marcade.in3:=marcade.in3 or 1;
  if arcade_input.start[1] then marcade.in3:=marcade.in3 and $fd else marcade.in3:=marcade.in3 or 2;
  //But
  if arcade_input.but0[0] then marcade.in4:=marcade.in4 and $fe else marcade.in4:=marcade.in4 or 1;
  if arcade_input.but1[0] then marcade.in4:=marcade.in4 and $fd else marcade.in4:=marcade.in4 or 2;
  if arcade_input.but0[1] then marcade.in4:=marcade.in4 and $fb else marcade.in4:=marcade.in4 or 4;
  if arcade_input.but1[1] then marcade.in4:=marcade.in4 and $f7 else marcade.in4:=marcade.in4 or 8;
end;
end;

procedure eventos_garyoret;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in0:=marcade.in0 and $fe else marcade.in0:=marcade.in0 or 1;
  if arcade_input.down[0] then marcade.in0:=marcade.in0 and $fd else marcade.in0:=marcade.in0 or 2;
  if arcade_input.left[0] then marcade.in0:=marcade.in0 and $fb else marcade.in0:=marcade.in0 or 4;
  if arcade_input.right[0] then marcade.in0:=marcade.in0 and $f7 else marcade.in0:=marcade.in0 or 8;
  if arcade_input.but0[0] then marcade.in0:=marcade.in0 and $ef else marcade.in0:=marcade.in0 or $10;
  if arcade_input.but1[0] then marcade.in0:=marcade.in0 and $df else marcade.in0:=marcade.in0 or $20;
  if arcade_input.start[0] then marcade.in0:=marcade.in0 and $bf else marcade.in0:=marcade.in0 or $40;
  if arcade_input.start[1] then marcade.in0:=marcade.in0 and $7f else marcade.in0:=marcade.in0 or $80;
  //P2
  if arcade_input.up[1] then marcade.in1:=marcade.in1 and $fe else marcade.in1:=marcade.in1 or 1;
  if arcade_input.down[1] then marcade.in1:=marcade.in1 and $fd else marcade.in1:=marcade.in1 or 2;
  if arcade_input.left[1] then marcade.in1:=marcade.in1 and $fb else marcade.in1:=marcade.in1 or 4;
  if arcade_input.right[1] then marcade.in1:=marcade.in1 and $f7 else marcade.in1:=marcade.in1 or 8;
  if arcade_input.but0[1] then marcade.in1:=marcade.in1 and $ef else marcade.in1:=marcade.in1 or $10;
  if arcade_input.but1[1] then marcade.in1:=marcade.in1 and $df else marcade.in1:=marcade.in1 or $20;
  //i8751
  if arcade_input.coin[0] then begin
    marcade.in2:=marcade.in2 and $df;
  end else begin
    marcade.in2:=marcade.in2 or $20;
    mcs51_0.change_irq0(ASSERT_LINE);
  end;
  if arcade_input.coin[1] then begin
    marcade.in2:=marcade.in2 and $bf;
  end else begin
    marcade.in2:=marcade.in2 or $40;
    mcs51_0.change_irq0(ASSERT_LINE);
  end;
end;
end;

procedure eventos_cobracom;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in0:=marcade.in0 and $fe else marcade.in0:=marcade.in0 or 1;
  if arcade_input.down[0] then marcade.in0:=marcade.in0 and $fd else marcade.in0:=marcade.in0 or 2;
  if arcade_input.left[0] then marcade.in0:=marcade.in0 and $fb else marcade.in0:=marcade.in0 or 4;
  if arcade_input.right[0] then marcade.in0:=marcade.in0 and $f7 else marcade.in0:=marcade.in0 or 8;
  if arcade_input.but0[0] then marcade.in0:=marcade.in0 and $ef else marcade.in0:=marcade.in0 or $10;
  if arcade_input.but1[0] then marcade.in0:=marcade.in0 and $df else marcade.in0:=marcade.in0 or $20;
  if arcade_input.but2[0] then marcade.in0:=marcade.in0 and $bf else marcade.in0:=marcade.in0 or $40;
  if arcade_input.start[0] then marcade.in0:=marcade.in0 and $7f else marcade.in0:=marcade.in0 or $80;
  //P2
  if arcade_input.up[1] then marcade.in1:=marcade.in1 and $fe else marcade.in1:=marcade.in1 or 1;
  if arcade_input.down[1] then marcade.in1:=marcade.in1 and $fd else marcade.in1:=marcade.in1 or 2;
  if arcade_input.left[1] then marcade.in1:=marcade.in1 and $fb else marcade.in1:=marcade.in1 or 4;
  if arcade_input.right[1] then marcade.in1:=marcade.in1 and $f7 else marcade.in1:=marcade.in1 or 8;
  if arcade_input.but0[1] then marcade.in1:=marcade.in1 and $ef else marcade.in1:=marcade.in1 or $10;
  if arcade_input.but1[1] then marcade.in1:=marcade.in1 and $df else marcade.in1:=marcade.in1 or $20;
  if arcade_input.but2[1] then marcade.in1:=marcade.in1 and $bf else marcade.in1:=marcade.in1 or $40;
  if arcade_input.start[1] then marcade.in1:=marcade.in1 and $7f else marcade.in1:=marcade.in1 or $80;
  //System
  if arcade_input.coin[0] then marcade.in3:=marcade.in3 and $fe else marcade.in3:=marcade.in3 or 1;
  if arcade_input.coin[1] then marcade.in3:=marcade.in3 and $fd else marcade.in3:=marcade.in3 or 2;
end;
end;

procedure eventos_ghostb;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in0:=marcade.in0 and $fe else marcade.in0:=marcade.in0 or 1;
  if arcade_input.down[0] then marcade.in0:=marcade.in0 and $fd else marcade.in0:=marcade.in0 or 2;
  if arcade_input.left[0] then marcade.in0:=marcade.in0 and $fb else marcade.in0:=marcade.in0 or 4;
  if arcade_input.right[0] then marcade.in0:=marcade.in0 and $f7 else marcade.in0:=marcade.in0 or 8;
  if arcade_input.but0[0] then marcade.in0:=marcade.in0 and $ef else marcade.in0:=marcade.in0 or $10;
  if arcade_input.but1[0] then marcade.in0:=marcade.in0 and $df else marcade.in0:=marcade.in0 or $20;
  //P2
  if arcade_input.up[1] then marcade.in1:=marcade.in1 and $fe else marcade.in1:=marcade.in1 or 1;
  if arcade_input.down[1] then marcade.in1:=marcade.in1 and $fd else marcade.in1:=marcade.in1 or 2;
  if arcade_input.left[1] then marcade.in1:=marcade.in1 and $fb else marcade.in1:=marcade.in1 or 4;
  if arcade_input.right[1] then marcade.in1:=marcade.in1 and $f7 else marcade.in1:=marcade.in1 or 8;
  if arcade_input.but0[1] then marcade.in1:=marcade.in1 and $ef else marcade.in1:=marcade.in1 or $10;
  if arcade_input.but1[1] then marcade.in1:=marcade.in1 and $df else marcade.in1:=marcade.in1 or $20;
  //i8751
  if arcade_input.coin[0] then begin
    marcade.in2:=marcade.in2 and $df;
  end else begin
    marcade.in2:=marcade.in2 or $20;
    mcs51_0.change_irq0(ASSERT_LINE);
  end;
  if arcade_input.coin[1] then begin
    marcade.in2:=marcade.in2 and $bf;
  end else begin
    marcade.in2:=marcade.in2 or $40;
    mcs51_0.change_irq0(ASSERT_LINE);
  end;
  //System
  if arcade_input.start[0] then marcade.in3:=marcade.in3 and $fe else marcade.in3:=marcade.in3 or 1;
  if arcade_input.start[1] then marcade.in3:=marcade.in3 and $fd else marcade.in3:=marcade.in3 or 2;
end;
end;

procedure eventos_oscar;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in0:=marcade.in0 and $fe else marcade.in0:=marcade.in0 or 1;
  if arcade_input.down[0] then marcade.in0:=marcade.in0 and $fd else marcade.in0:=marcade.in0 or 2;
  if arcade_input.left[0] then marcade.in0:=marcade.in0 and $fb else marcade.in0:=marcade.in0 or 4;
  if arcade_input.right[0] then marcade.in0:=marcade.in0 and $f7 else marcade.in0:=marcade.in0 or 8;
  if arcade_input.but0[0] then marcade.in0:=marcade.in0 and $ef else marcade.in0:=marcade.in0 or $10;
  if arcade_input.but1[0] then marcade.in0:=marcade.in0 and $df else marcade.in0:=marcade.in0 or $20;
  if arcade_input.but2[0] then marcade.in0:=marcade.in0 and $bf else marcade.in0:=marcade.in0 or $40;
  if arcade_input.start[0] then marcade.in0:=marcade.in0 and $7f else marcade.in0:=marcade.in0 or $80;
  //P2
  if arcade_input.up[1] then marcade.in1:=marcade.in1 and $fe else marcade.in1:=marcade.in1 or 1;
  if arcade_input.down[1] then marcade.in1:=marcade.in1 and $fd else marcade.in1:=marcade.in1 or 2;
  if arcade_input.left[1] then marcade.in1:=marcade.in1 and $fb else marcade.in1:=marcade.in1 or 4;
  if arcade_input.right[1] then marcade.in1:=marcade.in1 and $f7 else marcade.in1:=marcade.in1 or 8;
  if arcade_input.but0[1] then marcade.in1:=marcade.in1 and $ef else marcade.in1:=marcade.in1 or $10;
  if arcade_input.but1[1] then marcade.in1:=marcade.in1 and $df else marcade.in1:=marcade.in1 or $20;
  if arcade_input.but2[1] then marcade.in1:=marcade.in1 and $bf else marcade.in1:=marcade.in1 or $40;
  if arcade_input.start[1] then marcade.in1:=marcade.in1 and $7f else marcade.in1:=marcade.in1 or $80;
  //System
  if arcade_input.coin[0] then begin
    marcade.in3:=marcade.in3 and $fe
  end else begin
    marcade.in3:=marcade.in3 or 1;
    hd6309_0.change_nmi(ASSERT_LINE);
  end;
  if arcade_input.coin[1] then begin
    marcade.in3:=marcade.in3 and $fd;
   end else begin
    marcade.in3:=marcade.in3 or 2;
    hd6309_0.change_nmi(ASSERT_LINE);
   end;
end;
end;

procedure principal_srd;
var
  frame_m,frame_s,frame_mcu:single;
  f:word;
  h:byte;
begin
init_controls(false,false,false,true);
frame_m:=m6809_0.tframes;
frame_s:=m6502_0.tframes;
frame_mcu:=mcs51_0.tframes;
while EmuStatus=EsRunning do begin
 for f:=0 to 271 do begin
   case f of
      8:vblank:=0;
      248:begin
            m6809_0.change_nmi(PULSE_LINE);
            update_video_srd;
            vblank:=$40;
      end;
   end;
   for h:=1 to CPU_SYNC do begin
     //Main
     m6809_0.run(frame_m);
     frame_m:=frame_m+m6809_0.tframes-m6809_0.contador;
     //Sound
     m6502_0.run(frame_s);
     frame_s:=frame_s+m6502_0.tframes-m6502_0.contador;
     //MCU
     mcs51_0.run(frame_mcu);
     frame_mcu:=frame_mcu+mcs51_0.tframes-mcs51_0.contador;
   end;
 end;
 eventos_srd;
 video_sync;
end;
end;

procedure principal_lastmisn;
var
  frame_m,frame_sub,frame_s,frame_mcu:single;
  f:word;
  h:byte;
begin
init_controls(false,false,false,true);
frame_m:=m6809_0.tframes;
frame_sub:=m6809_1.tframes;
frame_s:=m6502_0.tframes;
frame_mcu:=mcs51_0.tframes;
while EmuStatus=EsRunning do begin
 for f:=0 to 271 do begin
   case f of
      8:vblank:=0;
      248:begin
            update_video_lastmissn;
            vblank:=$80;
            if sub_nmi then m6809_1.change_nmi(PULSE_LINE);
      end;
   end;
   for h:=1 to CPU_SYNC do begin
     //Main
     m6809_0.run(frame_m);
     frame_m:=frame_m+m6809_0.tframes-m6809_0.contador;
     //SUB
     m6809_1.run(frame_sub);
     frame_sub:=frame_sub+m6809_1.tframes-m6809_1.contador;
     //Sound
     m6502_0.run(frame_s);
     frame_s:=frame_s+m6502_0.tframes-m6502_0.contador;
     //MCU
     mcs51_0.run(frame_mcu);
     frame_mcu:=frame_mcu+mcs51_0.tframes-mcs51_0.contador;
   end;
 end;
 eventos_lastmisn;
 video_sync;
end;
end;

procedure principal_gondo;
var
  frame_m,frame_s,frame_mcu:single;
  s,f:word;
  h:byte;
begin
init_controls(false,false,false,true);
frame_m:=hd6309_0.tframes;
frame_s:=m6502_0.tframes;
frame_mcu:=mcs51_0.tframes;
while EmuStatus=EsRunning do begin
 for f:=0 to 271 do begin
   case f of
      8:vblank:=0;
      248:begin
            video_update_gondo;
            for s:=0 to $3ff do buffer_sprites_w[s]:=memoria[$3001+(s*2)]+(memoria[$3000+(s*2)] shl 8);
            vblank:=$80;
            if main_nmi then hd6309_0.change_nmi(PULSE_LINE);
      end;
   end;
   for h:=1 to CPU_SYNC do begin
     //Main
     hd6309_0.run(frame_m);
     frame_m:=frame_m+hd6309_0.tframes-hd6309_0.contador;
     //Sound
     m6502_0.run(frame_s);
     frame_s:=frame_s+m6502_0.tframes-m6502_0.contador;
     //MCU
     mcs51_0.run(frame_mcu);
     frame_mcu:=frame_mcu+mcs51_0.tframes-mcs51_0.contador;
   end;
 end;
 eventos_gondo_call;
 video_sync;
end;
end;

procedure principal_cobracom;
var
  frame_m,frame_s:single;
  f:word;
  h:byte;
begin
init_controls(false,false,false,true);
frame_m:=m6809_0.tframes;
frame_s:=m6502_0.tframes;
while EmuStatus=EsRunning do begin
 for f:=0 to 271 do begin
   case f of
      8:vblank:=$80;
      248:begin
            update_video_cobracom;
            vblank:=0;
            m6809_0.change_nmi(PULSE_LINE);
      end;
   end;
   for h:=1 to CPU_SYNC do begin
     //Main
     m6809_0.run(frame_m);
     frame_m:=frame_m+m6809_0.tframes-m6809_0.contador;
     //Sound
     m6502_0.run(frame_s);
     frame_s:=frame_s+m6502_0.tframes-m6502_0.contador;
   end;
 end;
 eventos_cobracom;
 video_sync;
end;
end;

procedure principal_oscar;
var
  frame_m,frame_sub,frame_s:single;
  f:word;
  h:byte;
begin
init_controls(false,false,false,true);
frame_m:=hd6309_0.tframes;
frame_sub:=hd6309_1.tframes;
frame_s:=m6502_0.tframes;
while EmuStatus=EsRunning do begin
 for f:=0 to 271 do begin
   case f of
      8:vblank:=0;
      248:begin
            update_video_oscar;
            vblank:=$80;
      end;
   end;
   for h:=1 to CPU_SYNC do begin
     //Main
     hd6309_0.run(frame_m);
     frame_m:=frame_m+hd6309_0.tframes-hd6309_0.contador;
     //Sub
     hd6309_1.run(frame_sub);
     frame_sub:=frame_sub+hd6309_1.tframes-hd6309_1.contador;
     //Sound
     m6502_0.run(frame_s);
     frame_s:=frame_s+m6502_0.tframes-m6502_0.contador;
   end;
 end;
 eventos_oscar;
 video_sync;
end;
end;

//Super Real Darwin
function getbyte_srd(direccion:word):byte;
begin
case direccion of
   0..$17ff,$8000..$ffff:getbyte_srd:=memoria[direccion];
   $2000:getbyte_srd:=i8751_return shr 8;
   $2001:getbyte_srd:=i8751_return and $ff;
   $2800..$288f:getbyte_srd:=buffer_paleta[direccion and $ff];
   $3000..$308f:getbyte_srd:=buffer_paleta[(direccion and $ff)+$400];
   $3800:getbyte_srd:=marcade.dswa;
   $3801:getbyte_srd:=marcade.in0;
   $3802:getbyte_srd:=marcade.in1 or vblank;
   $3803:getbyte_srd:=marcade.dswb;
   $4000..$7fff:getbyte_srd:=rom[rom_bank,direccion and $3fff];
end;
end;

procedure cambiar_color(dir:word);
var
  tmp_color:byte;
  color:tcolor;
  bit0,bit1,bit2,bit3:byte;
begin
  tmp_color:=buffer_paleta[dir];
  bit0:=(tmp_color and 1) shr 0;
  bit1:=(tmp_color and 2) shr 1;
  bit2:=(tmp_color and 4) shr 2;
  bit3:=(tmp_color and 8) shr 3;
  color.r:=$e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
  bit0:=(tmp_color and $10) shr 4;
  bit1:=(tmp_color and $20) shr 5;
  bit2:=(tmp_color and $40) shr 6;
  bit3:=(tmp_color and $80) shr 7;
  color.g:=$e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
  tmp_color:=buffer_paleta[dir+$400];
  bit0:=tmp_color and 1;
  bit1:=(tmp_color and 2) shr 1;
  bit2:=(tmp_color and 4) shr 2;
  bit3:=(tmp_color and 8) shr 3;
  color.b:=$e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
  set_pal_color(color,dir);
end;

procedure i8751_irq;
begin
  mcs51_0.change_irq1(CLEAR_LINE);
end;

procedure snd_clear_nmi;
begin
  m6502_0.change_nmi(CLEAR_LINE);
end;

procedure putbyte_srd(direccion:word;valor:byte);
begin
case direccion of
  0..$7ff,$1000..$13ff:memoria[direccion]:=valor;
  $800..$fff:if memoria[direccion]<>valor then begin
                gfx[0].buffer[direccion and $3ff]:=true;
                memoria[direccion]:=valor;
             end;
  $1400..$17ff:if memoria[direccion]<>valor then begin
                  gfx[1].buffer[(direccion and $3ff) shr 1]:=true;
                  memoria[direccion]:=valor;
               end;
  $1800:begin
          i8751_value:=(i8751_value and $ff) or (valor shl 8);
          mcs51_0.change_irq1(ASSERT_LINE);
          one_shot_timer_0(mcs51_0.numero_cpu,64,i8751_irq);
        end;
  $1801:i8751_value:=(i8751_value and $ff00) or valor;
  $1802:;//i8751_return:=0;
  $1804:copymemory(@buffer_sprites,@memoria[$600],$200);
  $1805:begin
          rom_bank:=valor shr 5;
          scroll_x:=(scroll_x and $ff) or ((valor and $f) shl 8);
        end;
  $1806:scroll_x:=(scroll_x and $f00) or valor;
  $2000:begin
          sound_latch:=valor;
          m6502_0.change_nmi(ASSERT_LINE);
          one_shot_timer_1(m6502_0.numero_cpu,3,snd_clear_nmi);
        end;
  $2001:main_screen.flip_main_screen:=valor<>0;
  $2800..$288f:if buffer_paleta[direccion and $ff]<>valor then begin
                  direccion:=direccion and $ff;
                  buffer_paleta[direccion]:=valor;
                  cambiar_color(direccion);
                  case direccion of
                    $80..$83:fillchar(gfx[0].buffer,$400,1);
                    $f0..$ff:buffer_color[(direccion shr 4) and $f]:=true;
                  end;
               end;
  $3000..$308f:if buffer_paleta[(direccion and $ff)+$400]<>valor then begin
                  direccion:=direccion and $ff;
                  buffer_paleta[direccion+$400]:=valor;
                  cambiar_color(direccion);
                  case direccion of
                    $80..$83:fillchar(gfx[0].buffer,$400,1);
                    $f0..$ff:buffer_color[(direccion shr 4) and $f]:=true;
                  end;
               end;
  $4000..$ffff:; //ROM
end;
end;

//MCU
function in_port0:byte;
begin
  in_port0:=i8751_port0;
end;

function in_port1:byte;
begin
  in_port1:=i8751_port1;
end;

function in_port3:byte;
begin
  in_port3:=marcade.in2;
end;

procedure out_port0(valor:byte);
begin
  i8751_port0:=valor;
end;

procedure out_port1(valor:byte);
begin
  i8751_port1:=valor;
end;

procedure out_port2(valor:byte);
begin
  if (valor and $10)=0 then i8751_port0:=i8751_value shr 8;
  if (valor and $20)=0 then i8751_port0:=i8751_value;
  if (valor and $40)=0 then i8751_return:=(i8751_return and $ff) or (i8751_port0 shl 8);
  if (valor and $80)=0 then i8751_return:=(i8751_return and $ff00) or i8751_port0;
  if (valor and 4)=0 then m6809_0.change_irq(ASSERT_LINE);
  if (valor and 2)=0 then mcs51_0.change_irq1(CLEAR_LINE);
end;

//Last Mission
function lastmisn_io_mcu_read(direccion:word):byte;
begin
case direccion of
   $1800:lastmisn_io_mcu_read:=marcade.in0;
   $1801:lastmisn_io_mcu_read:=marcade.in1;
   $1802:lastmisn_io_mcu_read:=marcade.in3 or vblank;
   $1803:lastmisn_io_mcu_read:=marcade.dswa;
   $1804:lastmisn_io_mcu_read:=marcade.dswb;
   $1806:lastmisn_io_mcu_read:=i8751_return shr 8;
   $1807:lastmisn_io_mcu_read:=i8751_return and $ff;
end;
end;

function getbyte_lastmisn(direccion:word):byte;
begin
case direccion of
   0..$fff,$2000..$3fff,$8000..$ffff:getbyte_lastmisn:=memoria[direccion];
   $1000..$17ff:getbyte_lastmisn:=buffer_paleta[direccion and $7ff];
   $1800..$1fff:getbyte_lastmisn:=call_io_mcu_read(direccion);
   $4000..$7fff:getbyte_lastmisn:=rom[rom_bank,direccion and $3fff];
end;
end;

procedure lastmisn_io_mcu_write(direccion:word;valor:byte);
var
  f:word;
begin
case direccion of
  $1800:m6809_1.change_irq(CLEAR_LINE);
  $1801:m6809_0.change_irq(CLEAR_LINE);
  $1802:m6809_0.change_firq(CLEAR_LINE);
  $1803:m6809_0.change_irq(ASSERT_LINE);
  $1804:m6809_1.change_irq(ASSERT_LINE);
  $1805:for f:=0 to $3ff do buffer_sprites_w[f]:=memoria[$2801+(f*2)]+(memoria[$2800+(f*2)] shl 8);
  $1807:main_screen.flip_main_screen:=valor<>0;
  $1809:scroll_x:=(scroll_x and $100) or valor;
  $180b:scroll_y:=(scroll_y and $100) or valor;
  $180c:begin
          sound_latch:=valor;
          m6502_0.change_nmi(ASSERT_LINE);
          one_shot_timer_1(m6502_0.numero_cpu,3,snd_clear_nmi);
        end;
  $180d:begin
          rom_bank:=valor and $f;
          scroll_x:=(scroll_x and $ff) or ((valor and $20) shl 3);
          scroll_y:=(scroll_y and $ff) or ((valor and $40) shl 2);
          if (valor and $80)<>0 then m6809_1.change_reset(CLEAR_LINE)
            else m6809_1.change_reset(ASSERT_LINE);
        end;
  $180e:begin
          i8751_value:=(i8751_value and $ff) or (valor shl 8);
          mcs51_0.change_irq1(ASSERT_LINE);
          one_shot_timer_0(mcs51_0.numero_cpu,64,i8751_irq);
        end;
  $180f:i8751_value:=(i8751_value and $ff00) or valor;
end;
end;

procedure putbyte_lastmisn(direccion:word;valor:byte);
begin
case direccion of
  0..$fff,$2800..$37ff:memoria[direccion]:=valor;
  $1000..$17ff:if buffer_paleta[direccion and $7ff]<>valor then begin
                  buffer_paleta[direccion and $7ff]:=valor;
                  direccion:=direccion and $3ff;
                  cambiar_color(direccion);
                  case direccion of
                    0..$1f:buffer_color[(direccion shr 3)+$10]:=true;
                    $300..$3ff:buffer_color[(direccion shr 4) and $f]:=true;
                  end;
               end;
  $1800..$1fff:call_io_mcu_write(direccion,valor);
  $2000..$27ff:if memoria[direccion]<>valor then begin
                gfx[0].buffer[(direccion and $7ff) shr 1]:=true;
                memoria[direccion]:=valor;
             end;
  $3800..$3fff:if memoria[direccion]<>valor then begin
                  gfx[1].buffer[(direccion and $7ff) shr 1]:=true;
                  memoria[direccion]:=valor;
               end;
  $4000..$ffff:; //ROM
end;
end;

function getbyte_sublastmisn(direccion:word):byte;
begin
case direccion of
   0..$3fff:getbyte_sublastmisn:=getbyte_lastmisn(direccion);
   $4000..$ffff:getbyte_sublastmisn:=mem_misc[direccion];
end;
end;

procedure lastmisn_out_port2(valor:byte);
begin
  if (valor and $10)=0 then begin
    i8751_port0:=i8751_value shr 8;
    mcs51_0.set_port_forced_input(0,i8751_port0);
  end;
  if (valor and $20)=0 then i8751_port1:=i8751_value;
  if (valor and $40)=0 then i8751_return:=(i8751_return and $ff) or (i8751_port0 shl 8);
  if (valor and $80)=0 then i8751_return:=(i8751_return and $ff00) or i8751_port1;
  if (((valor and 4)<>0) and ((last_p2 and 4)=0)) then m6809_1.change_firq(ASSERT_LINE);
  if (valor and 2)=0 then mcs51_0.change_irq1(CLEAR_LINE);
  if (valor and 1)=0 then mcs51_0.change_irq0(CLEAR_LINE);
  last_p2:=valor;
end;

//Shackled
procedure shackled_io_mcu_write(direccion:word;valor:byte);
var
  f:word;
begin
case direccion of
  $1800:m6809_1.change_irq(CLEAR_LINE);
  $1801:m6809_0.change_irq(CLEAR_LINE);
  $1802:m6809_1.change_firq(CLEAR_LINE);
  $1803:m6809_0.change_irq(ASSERT_LINE);
  $1804:m6809_1.change_irq(ASSERT_LINE);
  $1805:for f:=0 to $3ff do buffer_sprites_w[f]:=memoria[$2801+(f*2)]+(memoria[$2800+(f*2)] shl 8);
  $1807:main_screen.flip_main_screen:=valor<>0;
  $1809:scroll_x:=(scroll_x and $100) or valor;
  $180b:scroll_y:=(scroll_y and $100) or valor;
  $180c:begin
          sound_latch:=valor;
          m6502_0.change_nmi(ASSERT_LINE);
          one_shot_timer_1(m6502_0.numero_cpu,3,snd_clear_nmi);
        end;
  $180d:begin
          rom_bank:=valor and $f;
          scroll_x:=(scroll_x and $ff) or ((valor and $20) shl 3);
          scroll_y:=(scroll_y and $ff) or ((valor and $40) shl 2);
        end;
  $180e:begin
          i8751_value:=(i8751_value and $ff) or (valor shl 8);
          mcs51_0.change_irq1(ASSERT_LINE);
          one_shot_timer_0(mcs51_0.numero_cpu,64,i8751_irq);
        end;
  $180f:i8751_value:=(i8751_value and $ff00) or valor;
end;
end;

//Gondomania
function gondo_io_mcu_read(direccion:word):byte;
begin
case direccion of
   $3800:gondo_io_mcu_read:=marcade.dswa;
   $3801:gondo_io_mcu_read:=marcade.dswb;
   $380a:gondo_io_mcu_read:=$ff;
   $380b:gondo_io_mcu_read:=$70 or marcade.in0;
   $380c:gondo_io_mcu_read:=$ff;
   $380d:gondo_io_mcu_read:=$70 or marcade.in1;
   $380e:gondo_io_mcu_read:=marcade.in3 or vblank;
   $380f:gondo_io_mcu_read:=marcade.in4;
   $3838:gondo_io_mcu_read:=i8751_return shr 8;
   $3839:gondo_io_mcu_read:=i8751_return and $ff;
end;
end;

function getbyte_gondo(direccion:word):byte;
begin
case direccion of
   0..$27ff,$3000..$37ff,$8000..$ffff:getbyte_gondo:=memoria[direccion];
   $2800..$2fff:getbyte_gondo:=buffer_paleta[direccion and $7ff];
   $3800..$38ff:getbyte_gondo:=call_io_mcu_read(direccion);
   $4000..$7fff:getbyte_gondo:=rom[rom_bank,direccion and $3fff];
end;
end;

procedure gondo_io_mcu_write(direccion:word;valor:byte);
begin
case direccion of
  $3810:begin
          sound_latch:=valor;
          m6502_0.change_nmi(ASSERT_LINE);
          one_shot_timer_1(m6502_0.numero_cpu,3,snd_clear_nmi);
        end;
  $3818:scroll_x:=(scroll_x and $100) or valor;
  $3820:scroll_y:=(scroll_y and $100) or valor;
  $3828:begin
          scroll_x:=(scroll_x and $ff) or ((valor and 1) shl 8);
          scroll_y:=(scroll_y and $ff) or ((valor and 2) shl 7);
        end;
  $3830:begin
          rom_bank:=valor shr 4;
          main_screen.flip_main_screen:=(valor and 8)<>0;
          secclr:=(valor and 1)<>0;
          if not(secclr) then hd6309_0.change_irq(CLEAR_LINE);
          main_nmi:=(valor and 2)<>0;
        end;
  $383a:begin
          i8751_value:=(i8751_value and $ff) or (valor shl 8);
          mcs51_0.change_irq1(ASSERT_LINE);
          one_shot_timer_0(mcs51_0.numero_cpu,64,i8751_irq);
        end;
  $383b:i8751_value:=(i8751_value and $ff00) or valor;
end;
end;

procedure putbyte_gondo(direccion:word;valor:byte);
begin
case direccion of
  0..$17ff,$3000..$37ff:memoria[direccion]:=valor;
  $1800..$1fff:if memoria[direccion]<>valor then begin
                gfx[0].buffer[(direccion and $7ff) shr 1]:=true;
                memoria[direccion]:=valor;
             end;
  $2000..$27ff:if memoria[direccion]<>valor then begin
                  gfx[1].buffer[(direccion and $7ff) shr 1]:=true;
                  memoria[direccion]:=valor;
               end;
  $2800..$2fff:if buffer_paleta[direccion and $7ff]<>valor then begin
                  buffer_paleta[direccion and $7ff]:=valor;
                  direccion:=direccion and $3ff;
                  cambiar_color(direccion);
                  case direccion of
                    0..$3f:buffer_color[(direccion shr 3)+$10]:=true;
                    $300..$3ff:buffer_color[(direccion shr 4) and $f]:=true;
                  end;
               end;
  $3800..$38ff:call_io_mcu_write(direccion,valor);
  $4000..$ffff:; //ROM
end;
end;

procedure gondo_out_port2(valor:byte);
begin
  if (valor and $10)=0 then i8751_port0:=i8751_value shr 8;
  if (valor and $20)=0 then i8751_port1:=i8751_value;
  if (valor and $40)=0 then i8751_return:=(i8751_return and $ff) or (i8751_port0 shl 8);
  if (valor and $80)=0 then i8751_return:=(i8751_return and $ff00) or i8751_port1;
  if (((valor and 4)<>0) and ((last_p2 and 4)=0) and secclr) then hd6309_0.change_irq(ASSERT_LINE);
  last_p2:=valor;
end;

//Garyo Ret
function garyoret_io_mcu_read(direccion:word):byte;
begin
case direccion of
   $3800:garyoret_io_mcu_read:=marcade.dswa;
   $3801:garyoret_io_mcu_read:=marcade.dswb;
   $380a:garyoret_io_mcu_read:=marcade.in1 or vblank;
   $380b:garyoret_io_mcu_read:=marcade.in0;
   $383a:garyoret_io_mcu_read:=i8751_return shr 8;
   $383b:garyoret_io_mcu_read:=i8751_return and $ff;
end;
end;

procedure garyoret_io_mcu_write(direccion:word;valor:byte);
begin
case direccion of
  $3810:begin
          sound_latch:=valor;
          m6502_0.change_nmi(ASSERT_LINE);
          one_shot_timer_1(m6502_0.numero_cpu,3,snd_clear_nmi);
        end;
  $3818:scroll_x:=(scroll_x and $100) or valor;
  $3820:scroll_y:=(scroll_y and $100) or valor;
  $3828:begin
          scroll_x:=(scroll_x and $ff) or ((valor and 1) shl 8);
          scroll_y:=(scroll_y and $ff) or ((valor and 2) shl 7);
        end;
  $3830:begin
          rom_bank:=valor shr 4;
          main_screen.flip_main_screen:=(valor and 8)<>0;
          secclr:=(valor and 1)<>0;
          if not(secclr) then hd6309_0.change_irq(CLEAR_LINE);
          main_nmi:=(valor and 2)<>0;
        end;
  $3838:begin
          i8751_value:=(i8751_value and $ff) or (valor shl 8);
          mcs51_0.change_irq1(ASSERT_LINE);
          one_shot_timer_0(mcs51_0.numero_cpu,64,i8751_irq);
        end;
  $3839:i8751_value:=(i8751_value and $ff00) or valor;
end;
end;

//Captain Silver
procedure csilver_out_port2(valor:byte);
begin
  if (valor and $10)=0 then i8751_port0:=i8751_value shr 8;
  if (valor and $20)=0 then i8751_port1:=i8751_value;
  if (valor and $40)=0 then begin
    i8751_return:=(i8751_return and $ff) or (i8751_port0 shl 8);
    m6809_0.change_firq(ASSERT_LINE);
  end;
  if (valor and $80)=0 then i8751_return:=(i8751_return and $ff00) or i8751_port1;
end;

function csilver_io_mcu_read(direccion:word):byte;
begin
case direccion of
   $1800:csilver_io_mcu_read:=marcade.in1;
   $1801:csilver_io_mcu_read:=marcade.in0;
   $1803:csilver_io_mcu_read:=marcade.in3 or vblank;
   $1804:csilver_io_mcu_read:=marcade.dswb;
   $1805:csilver_io_mcu_read:=marcade.dswa;
   $1c00:csilver_io_mcu_read:=i8751_return shr 8;
   $1e00:csilver_io_mcu_read:=i8751_return and $ff;
end;
end;

procedure csilver_io_mcu_write(direccion:word;valor:byte);
var
  f:word;
begin
case direccion of
  $1800:m6809_1.change_irq(CLEAR_LINE);
  $1801:m6809_0.change_irq(CLEAR_LINE);
  $1802:m6809_0.change_firq(CLEAR_LINE);
  $1803:m6809_0.change_irq(ASSERT_LINE);
  $1804:m6809_1.change_irq(ASSERT_LINE);
  $1805:for f:=0 to $3ff do buffer_sprites_w[f]:=memoria[$2801+(f*2)]+(memoria[$2800+(f*2)] shl 8);
  $1807:main_screen.flip_main_screen:=valor<>0;
  $1808:scroll_x:=(scroll_x and $ff) or ((valor and 1) shl 8);
  $1809:scroll_x:=(scroll_x and $100) or valor;
  $180a:scroll_y:=(scroll_y and $ff) or ((valor and 1) shl 8);
  $180b:scroll_y:=(scroll_y and $100) or valor;
  $180c:begin
          sound_latch:=valor;
          m6502_0.change_nmi(ASSERT_LINE);
          one_shot_timer_1(m6502_0.numero_cpu,3,snd_clear_nmi);
        end;
  $180d:rom_bank:=valor and $f;
  $180e:begin
          i8751_value:=(i8751_value and $ff) or (valor shl 8);
          mcs51_0.change_irq1(ASSERT_LINE);
          one_shot_timer_0(mcs51_0.numero_cpu,64,i8751_irq);
        end;
  $180f:i8751_value:=(i8751_value and $ff00) or valor;
end;
end;

//Cobra Command
function getbyte_cobracom(direccion:word):byte;
begin
case direccion of
   0..$2fff,$8000..$ffff:getbyte_cobracom:=memoria[direccion];
   $3000..$31ff:getbyte_cobracom:=buffer_paleta[direccion and $1ff];
   $3800:getbyte_cobracom:=marcade.in0;
   $3801:getbyte_cobracom:=marcade.in1;
   $3802:getbyte_cobracom:=marcade.dswa;
   $3803:getbyte_cobracom:=marcade.dswb;
   $3a00:getbyte_cobracom:=marcade.in3 or vblank;
   $4000..$7fff:getbyte_cobracom:=rom[rom_bank,direccion and $3fff];
end;
end;

procedure cambiar_color_cobra(dir:word);
var
  tmp_color:byte;
  color:tcolor;
  bit0,bit1,bit2,bit3:byte;
begin
  tmp_color:=buffer_paleta[dir+1];
  bit0:=(tmp_color and 1) shr 0;
  bit1:=(tmp_color and 2) shr 1;
  bit2:=(tmp_color and 4) shr 2;
  bit3:=(tmp_color and 8) shr 3;
  color.r:=$e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
  bit0:=(tmp_color and $10) shr 4;
  bit1:=(tmp_color and $20) shr 5;
  bit2:=(tmp_color and $40) shr 6;
  bit3:=(tmp_color and $80) shr 7;
  color.g:=$e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
  tmp_color:=buffer_paleta[dir];
  bit0:=tmp_color and 1;
  bit1:=(tmp_color and 2) shr 1;
  bit2:=(tmp_color and 4) shr 2;
  bit3:=(tmp_color and 8) shr 3;
  color.b:=$e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
  dir:=dir shr 1;
  set_pal_color(color,dir);
end;

procedure putbyte_cobracom(direccion:word;valor:byte);
var
  f:word;
begin
case direccion of
  0..$7ff,$1800..$1fff,$2800..$2fff:memoria[direccion]:=valor;
  $800..$fff:begin
                bac06_0.tile_1.write_tile_data_8b(direccion,valor,$7ff);
                memoria[direccion]:=valor;
             end;
  $1000..$17ff:begin
                bac06_0.tile_2.write_tile_data_8b(direccion,valor,$7ff);
                memoria[direccion]:=valor;
               end;
  $2000..$27ff:if memoria[direccion]<>valor then begin
                gfx[0].buffer[(direccion and $7ff) shr 1]:=true;
                memoria[direccion]:=valor;
             end;
  $3000..$31ff:if buffer_paleta[direccion and $1ff]<>valor then begin
                  buffer_paleta[direccion and $1ff]:=valor;
                  cambiar_color_cobra(direccion and $1fe);
                  direccion:=(direccion and $1fe) shr 1;
                  case direccion of
                    0..$1f:buffer_color[direccion shr 2]:=true;
                    $80..$bf:bac06_0.tile_1.buffer_color[(direccion shr 4) and 3]:=true;
                    $c0..$ff:begin
                                bac06_0.tile_1.buffer_color[(direccion shr 4) and 3]:=true;
                                bac06_0.tile_2.buffer_color[(direccion shr 4) and 3]:=true;
                             end;
                  end;
               end;
  $3800..$3807:bac06_0.tile_1.change_control0_8b(direccion,valor);
  $3810..$381f:bac06_0.tile_1.change_control1_8b(direccion,valor);
  $3a00..$3a07:bac06_0.tile_2.change_control0_8b(direccion,valor);
  $3a10..$3a1f:bac06_0.tile_2.change_control1_8b(direccion,valor);
  $3c00:rom_bank:=valor and $f;
  $3c02:for f:=0 to $3ff do bac06_0.sprite_ram[f]:=memoria[$2801+(f*2)]+(memoria[$2800+(f*2)] shl 8);
  $3e00:begin
          sound_latch:=valor;
          m6502_0.change_nmi(ASSERT_LINE);
          one_shot_timer_1(m6502_0.numero_cpu,3,snd_clear_nmi);
        end;
  $4000..$ffff:; //ROM
end;
end;

//The Real Ghostbusters
function getbyte_ghostb(direccion:word):byte;
begin
case direccion of
   0..$37ff,$8000..$ffff:getbyte_ghostb:=memoria[direccion];
   $3800:getbyte_ghostb:=marcade.in0;
   $3801:getbyte_ghostb:=marcade.in1;
   $3802:getbyte_ghostb:=$ff;
   $3803:getbyte_ghostb:=marcade.dswa or marcade.in3 or (vblank shr 4);
   $3820:getbyte_ghostb:=marcade.dswb;
   $3840:getbyte_ghostb:=i8751_return shr 8;
   $3860:getbyte_ghostb:=i8751_return and $ff;
   $4000..$7fff:getbyte_ghostb:=rom[rom_bank,direccion and $3fff];
end;
end;

procedure putbyte_ghostb(direccion:word;valor:byte);
begin
case direccion of
  0..$17ff,$2800..$2bff,$3000..$37ff:memoria[direccion]:=valor;
  $1800..$1fff:if memoria[direccion]<>valor then begin
                gfx[0].buffer[(direccion and $7ff) shr 1]:=true;
                memoria[direccion]:=valor;
             end;
  $2000..$27ff:begin
                bac06_0.tile_1.write_tile_data_8b(direccion,valor,$7ff);
                memoria[direccion]:=valor;
               end;
  $2c00..$2fff:begin
                  bac06_0.tile_1.write_rowscroll_8b(direccion,valor);
                  memoria[direccion]:=valor;
               end;
  $3800:begin
          sound_latch:=valor;
          m6502_0.change_nmi(ASSERT_LINE);
          one_shot_timer_1(m6502_0.numero_cpu,3,snd_clear_nmi);
        end;
  $3820..$3827:bac06_0.tile_1.change_control0_8b(direccion,valor);
  $3830..$383f:bac06_0.tile_1.change_control1_8b(direccion,valor);
  $3840:begin
          rom_bank:=valor shr 4;
          main_screen.flip_main_screen:=(valor and 8)<>0;
          secclr:=(valor and 1)<>0;
          if not(secclr) then hd6309_0.change_irq(CLEAR_LINE);
          main_nmi:=(valor and 2)<>0;
        end;
  $3860:begin
          i8751_value:=(i8751_value and $ff) or (valor shl 8);
          mcs51_0.change_irq1(ASSERT_LINE);
          one_shot_timer_0(mcs51_0.numero_cpu,64,i8751_irq);
        end;
  $3861:i8751_value:=(i8751_value and $ff00) or valor;
  $4000..$ffff:; //ROM
end;
end;

//Psycho-Nics Oscar
function getbyte_oscar(direccion:word):byte;
begin
case direccion of
   0..$37ff,$8000..$ffff:getbyte_oscar:=memoria[direccion];
   $3800..$3bff:getbyte_oscar:=buffer_paleta[direccion and $3ff];
   $3c00:getbyte_oscar:=marcade.in0;
   $3c01:getbyte_oscar:=marcade.in1;
   $3c02:getbyte_oscar:=marcade.in3 or vblank;
   $3c03:getbyte_oscar:=$7f;
   $3c04:getbyte_oscar:=$ff;
   $4000..$7fff:getbyte_oscar:=rom[rom_bank,direccion and $3fff];
end;
end;

procedure putbyte_oscar(direccion:word;valor:byte);
var
  f:word;
begin
case direccion of
  0..$1fff,$3000..$37ff:memoria[direccion]:=valor;
  $2000..$27ff:if memoria[direccion]<>valor then begin
                gfx[0].buffer[(direccion and $7ff) shr 1]:=true;
                memoria[direccion]:=valor;
             end;
  $2800..$2fff:begin
                bac06_0.tile_1.write_tile_data_8b(direccion,valor,$7ff);
                memoria[direccion]:=valor;
               end;
  $3800..$3bff:begin
                  buffer_paleta[direccion and $3ff]:=valor;
                  cambiar_color_cobra(direccion and $3fe);
                  direccion:=(direccion and $3ff) shr 1;
                  case direccion of
                      $100..$11f:buffer_color[(direccion shr 3) and 3]:=true;
                      $180..$1ff:bac06_0.tile_1.buffer_color[(direccion shr 4) and 3]:=true;
                  end;
               end;
  $3c00..$3c07:bac06_0.tile_1.change_control0_8b(direccion,valor);
  $3c10..$3c1f:bac06_0.tile_1.change_control1_8b(direccion,valor);
  $3c80:for f:=0 to $3ff do bac06_0.sprite_ram[f]:=memoria[$3001+(f*2)]+(memoria[$3000+(f*2)] shl 8);
  $3d00:rom_bank:=valor and $f;
  $3d80:begin
          sound_latch:=valor;
          m6502_0.change_nmi(PULSE_LINE);
        end;
  $3e00:hd6309_0.change_nmi(CLEAR_LINE);
  $3e80:hd6309_1.change_irq(ASSERT_LINE);
  $3e81:hd6309_0.change_irq(CLEAR_LINE);
  $3e82:hd6309_0.change_irq(ASSERT_LINE);
  $3e83:hd6309_1.change_irq(CLEAR_LINE);
  $4000..$ffff:; //ROM
end;
end;

function getbyte_suboscar(direccion:word):byte;
begin
case direccion of
   0..$eff,$1000..$3fff:getbyte_suboscar:=getbyte_oscar(direccion);
   $f00..$fff,$4000..$ffff:getbyte_suboscar:=mem_misc[direccion];
end;
end;

procedure putbyte_suboscar(direccion:word;valor:byte);
begin
case direccion of
   0..$eff,$1000..$3fff:putbyte_oscar(direccion,valor);
   $f00..$fff:mem_misc[direccion]:=valor;
   $4000..$ffff:;
end;
end;

//Sound
function getbyte_snd_deco222(direccion:word):byte;
begin
  case direccion of
    0..$5ff:getbyte_snd_deco222:=mem_snd[direccion];
    $2000:getbyte_snd_deco222:=ym2203_0.status;
    $2001:getbyte_snd_deco222:=ym2203_0.read;
    $4000:getbyte_snd_deco222:=ym3812_0.status;
    $6000:getbyte_snd_deco222:=sound_latch;
    $8000..$ffff:if m6502_0.opcode then getbyte_snd_deco222:=snd_dec[direccion and $7fff]
                    else getbyte_snd_deco222:=mem_snd[direccion];
  end;
end;

procedure putbyte_snd_deco222(direccion:word;valor:byte);
begin
case direccion of
  0..$5ff:mem_snd[direccion]:=valor;
  $2000:ym2203_0.control(valor);
  $2001:ym2203_0.write(valor);
  $4000:ym3812_0.control(valor);
  $4001:ym3812_0.write(valor);
  $8000..$ffff:; //ROM
end;
end;

function getbyte_snd_lastmisn(direccion:word):byte;
begin
  case direccion of
    0..$5ff:getbyte_snd_lastmisn:=mem_snd[direccion];
    $800:getbyte_snd_lastmisn:=ym2203_0.status;
    $801:getbyte_snd_lastmisn:=ym2203_0.read;
    $1000:getbyte_snd_lastmisn:=ym3812_0.status;
    $3000:getbyte_snd_lastmisn:=sound_latch;
    $8000..$ffff:getbyte_snd_lastmisn:=mem_snd[direccion];
  end;
end;

procedure putbyte_snd_lastmisn(direccion:word;valor:byte);
begin
case direccion of
  0..$5ff:mem_snd[direccion]:=valor;
  $800:ym2203_0.control(valor);
  $801:ym2203_0.write(valor);
  $1000:ym3812_0.control(valor);
  $1001:ym3812_0.write(valor);
  $8000..$ffff:; //ROM
end;
end;

function getbyte_snd_csilver(direccion:word):byte;
begin
  case direccion of
    0..$7ff:getbyte_snd_csilver:=mem_snd[direccion];
    $800:getbyte_snd_csilver:=ym2203_0.status;
    $801:getbyte_snd_csilver:=ym2203_0.read;
    $1000:getbyte_snd_csilver:=ym3812_0.status;
    $3000:getbyte_snd_csilver:=sound_latch;
    $3400:begin
            getbyte_snd_csilver:=0;
            msm5205_0.reset_w(false);
          end;
    $4000..$7fff:getbyte_snd_csilver:=sound_rom[sound_rom_bank,direccion and $3fff];
    $8000..$ffff:getbyte_snd_csilver:=mem_snd[direccion];
  end;
end;

procedure putbyte_snd_csilver(direccion:word;valor:byte);
begin
case direccion of
  0..$7ff:mem_snd[direccion]:=valor;
  $800:ym2203_0.control(valor);
  $801:ym2203_0.write(valor);
  $1000:ym3812_0.control(valor);
  $1001:ym3812_0.write(valor);
  $1800:msm5205_next:=valor;
  $2000:sound_rom_bank:=(valor and 8) shr 3;
  $4000..$ffff:; //ROM
end;
end;

procedure snd_adpcm;
begin
  msm5205_toggle:=not(msm5205_toggle);
	if msm5205_toggle then m6502_0.change_irq(HOLD_LINE);
	msm5205_0.data_w(msm5205_next shr 4);
	msm5205_next:=msm5205_next shl 4;
end;

procedure dec8_sound_update;
begin
  ym2203_0.update;
  ym3812_0.update;
end;

procedure csilver_sound_update;
begin
  ym2203_0.update;
  ym3812_0.update;
  msm5205_0.update;
end;

procedure snd_irq(irqstate:byte);
begin
  m6502_0.change_irq(irqstate);
end;

//Main
procedure reset_dec8;
begin
marcade.in0:=$ff;
marcade.in1:=$ff;
marcade.in2:=$ff;
marcade.in3:=$7f;
case main_vars.tipo_maquina of
  91:begin
      m6809_0.reset;
      mcs51_0.reset;
      marcade.in1:=$bf;
    end;
  392,393:begin
            m6809_0.reset;
            m6809_1.reset;
            mcs51_0.reset;
          end;
  394:begin
        hd6309_0.reset;
        mcs51_0.reset;
        marcade.in4:=$ff;
      end;
  395:begin
        hd6309_0.reset;
        mcs51_0.reset;
        marcade.in1:=$7f;
      end;
  396:begin
        m6809_0.reset;
        m6809_1.reset;
        mcs51_0.reset;
        msm5205_0.reset;
      end;
  397:begin
        m6809_0.reset;
        bac06_0.reset;
      end;
  398:begin
        hd6309_0.reset;
        mcs51_0.reset;
        bac06_0.reset;
        marcade.in3:=3;
      end;
  399:begin
        hd6309_0.reset;
        hd6309_1.reset;
        bac06_0.reset;
        //No inicializa bien el chip de video!! Y confia que los valores esten asi de inicio
        bac06_0.tile_1.control_0[0]:=2;
        bac06_0.tile_1.change_control0(3,1);
      end;
end;
m6502_0.reset;
ym2203_0.reset;
ym3812_0.reset;
sound_latch:=0;
rom_bank:=0;
i8751_return:=0;
i8751_value:=0;
i8751_port0:=0;
i8751_port1:=0;
last_p2:=$ff;
scroll_x:=0;
scroll_y:=0;
secclr:=false;
main_nmi:=false;
vblank:=0;
sound_rom_bank:=0;
msm5205_next:=0;
msm5205_toggle:=false;
end;

function iniciar_dec8:boolean;
const
    pc_x:array[0..7] of dword=($2000*8+0, $2000*8+1, $2000*8+2, $2000*8+3, 0, 1, 2, 3);
    ps_x:array[0..15] of dword=(16*8, 1+(16*8), 2+(16*8), 3+(16*8), 4+(16*8), 5+(16*8), 6+(16*8), 7+(16*8),
		    0,1,2,3,4,5,6,7);
    ps_y:array[0..15] of dword=(0*8,1*8,2*8,3*8,4*8,5*8,6*8,7*8,
        8*8,9*8,10*8,11*8,12*8,13*8,14*8,15*8);
    pt_x:array[0..15] of dword=(0, 1, 2, 3, 1024*8*8+0, 1024*8*8+1, 1024*8*8+2, 1024*8*8+3,
			  16*8+0, 16*8+1, 16*8+2, 16*8+3, 16*8+1024*8*8+0, 16*8+1024*8*8+1, 16*8+1024*8*8+2, 16*8+1024*8*8+3);
    gb_pt_x:array[0..15] of dword=(7,6,5,4,3,2,1,0,
		    7+(16*8), 6+(16*8), 5+(16*8), 4+(16*8), 3+(16*8), 2+(16*8), 1+(16*8), 0+(16*8));
var
  f:word;
  memoria_temp:array[0..$47fff] of byte;
  ptemp,ptemp2:pbyte;
  colores:tpaleta;
procedure lastmissn_convert_chars;
begin
  init_gfx(0,8,8,$400);
  gfx[0].trans[0]:=true;
  gfx_set_desc_data(3,0,8*8,$6000*8,$4000*8,$2000*8);
  convert_gfx(0,0,@memoria_temp,@ps_x[8],@ps_y,false,false);
end;
procedure lastmissn_convert_tiles_sprites(gfx_num:byte);
begin
  init_gfx(gfx_num,16,16,$1000);
  gfx_set_desc_data(4,0,16*16,$60000*8,$40000*8,$20000*8,0*8);
  convert_gfx(gfx_num,0,ptemp,@ps_x,@ps_y,false,false);
end;
begin
iniciar_dec8:=false;
llamadas_maquina.reset:=reset_dec8;
llamadas_maquina.fps_max:=57.444853;
llamadas_maquina.scanlines:=272*CPU_SYNC;
iniciar_audio(false);
case main_vars.tipo_maquina of
  91,392,393,394,395,396:begin
        screen_init(1,256,256,true);
        screen_init(2,512,512);
        screen_init(3,512,512,true);
        if ((main_vars.tipo_maquina<>393) and (main_vars.tipo_maquina<>395) and (main_vars.tipo_maquina<>396)) then main_screen.rot270_screen:=true;
        screen_init(4,512,512,false,true);
        iniciar_video(256,240);
      end;
  397:begin
        screen_init(8,256,256,true);
        bac06_0:=bac06_chip.create(false,false,false,$80,$c0,0,1,1,1,$40,3);
      end;
  398:begin
        screen_init(8,256,256,true);
        bac06_0:=bac06_chip.create(false,false,false,$200,0,0,1,1,1,0);
      end;
  399:begin
        screen_init(8,256,256,true);
        bac06_0:=bac06_chip.create(true,false,false,$180,0,0,1,1,1,0,7);
      end;
end;
//Main CPU
case main_vars.tipo_maquina of
  91,392,393,397:m6809_0:=cpu_m6809.create(2000000,TCPU_MC6809E);
  394,395,398:hd6309_0:=cpu_hd6309.create(3000000,TCPU_HD6309E);
  396:m6809_0:=cpu_m6809.create(1500000,TCPU_MC6809E);
  399:hd6309_0:=cpu_hd6309.create(6000000,TCPU_HD6309E);
end;
//Sound CPU
m6502_0:=cpu_m6502.create(1500000,TCPU_M6502);
if (main_vars.tipo_maquina=396) then m6502_0.init_sound(csilver_sound_update)
  else m6502_0.init_sound(dec8_sound_update);
//Sound Chip
ym2203_0:=ym2203_chip.create(1500000);
case main_vars.tipo_maquina of
  91,397,398:ym3812_0:=ym3812_chip.create(YM3812_FM,3000000,0.7);
  392,393,394,395,396,399:ym3812_0:=ym3812_chip.create(YM3526_FM,3000000,0.7);
end;
ym3812_0.change_irq_calls(snd_irq);
//MCU
if ((main_vars.tipo_maquina<>397) and (main_vars.tipo_maquina<>399)) then mcs51_0:=cpu_mcs51.create(I8X51,8000000);
case main_vars.tipo_maquina of
  91:begin
      llamadas_maquina.bucle_general:=principal_srd;
      //Main CPU
      m6809_0.change_ram_calls(getbyte_srd,putbyte_srd);
      if not(roms_load(@memoria_temp,srd_rom)) then exit;
      copymemory(@rom[4,0],@memoria_temp[0],$4000);
      copymemory(@rom[5,0],@memoria_temp[$4000],$4000);
      copymemory(@memoria[$8000],@memoria_temp[$8000],$8000);
      //memoria[$96e4]:=$39; //Cheat!
      for f:=0 to 3 do copymemory(@rom[f,0],@memoria_temp[$10000+(f*$4000)],$4000);
      //Sound CPU
      m6502_0.change_ram_calls(getbyte_snd_deco222,putbyte_snd_deco222);
      if not(roms_load(@mem_snd,srd_snd)) then exit;
      for f:=$8000 to $ffff do snd_dec[f-$8000]:=bitswap8(mem_snd[f],7,5,6,4,3,2,1,0);
      //MCU
      mcs51_0.change_io_calls(in_port0,nil,nil,in_port3,out_port0,nil,out_port2,nil);
      if not(roms_load(mcs51_0.get_rom_addr,srd_mcu)) then exit;
      //Cargar chars
      if not(roms_load(@memoria_temp,srd_char)) then exit;
      init_gfx(0,8,8,$400);
      gfx[0].trans[0]:=true;
      gfx_set_desc_data(2,0,8*8,0,4);
      convert_gfx(0,0,@memoria_temp,@pc_x,@ps_y,false,false);
      //Cargar tiles y ponerlas en su sitio
      getmem(ptemp,$100000);
      if not(roms_load(ptemp,srd_tiles)) then exit;
      for f:=0 to 3 do begin
        copymemory(@memoria_temp[$10000*f],@ptemp[$4000*f],$4000);
        copymemory(@memoria_temp[$8000+($10000*f)],@ptemp[$10000+($4000*f)],$4000);
      end;
      init_gfx(1,16,16,$400);
      for f:=0 to 7 do gfx[1].trans[f]:=true;
      gfx_set_desc_data(4,4,32*8,$8000*8,$8000*8+4,0,4);
      for f:=0 to 3 do convert_gfx(1,$100*f*16*16,@memoria_temp[$10000*f],@pt_x,@ps_y,false,false);
      freemem(ptemp);
      //Cargar sprites
      if not(roms_load(@memoria_temp,srd_sprites)) then exit;
      init_gfx(2,16,16,$800);
      gfx[2].trans[0]:=true;
      gfx_set_desc_data(3,0,16*16,$10000*8,$20000*8,0*8);
      convert_gfx(2,0,@memoria_temp,@ps_x,@ps_y,false,false);
      //DIP
      init_dips(1,srd_dip_a,$7f);
      init_dips(2,srd_dip_b,$ff);
  end;
  392:begin
      llamadas_maquina.bucle_general:=principal_lastmisn;
      call_io_mcu_read:=lastmisn_io_mcu_read;
      call_io_mcu_write:=lastmisn_io_mcu_write;
      //Main CPU
      m6809_0.change_ram_calls(getbyte_lastmisn,putbyte_lastmisn);
      if not(roms_load(@memoria_temp,lastmisn_rom)) then exit;
      copymemory(@memoria[$8000],@memoria_temp[0],$8000);
      copymemory(@rom[0,0],@memoria_temp[$8000],$4000);
      copymemory(@rom[1,0],@memoria_temp[$c000],$4000);
      copymemory(@rom[2,0],@memoria_temp[$10000],$4000);
      copymemory(@rom[3,0],@memoria_temp[$14000],$4000);
      //Sub CPU
      m6809_1:=cpu_m6809.create(2000000,TCPU_MC6809E);
      m6809_1.change_ram_calls(getbyte_sublastmisn,putbyte_lastmisn);
      if not(roms_load(@mem_misc,lastmisn_sub)) then exit;
      sub_nmi:=false;
      //Sound CPU
      m6502_0.change_ram_calls(getbyte_snd_lastmisn,putbyte_snd_lastmisn);
      if not(roms_load(@mem_snd,lastmisn_snd)) then exit;
      //MCU
      mcs51_0.change_io_calls(in_port0,in_port1,nil,in_port3,out_port0,out_port1,lastmisn_out_port2,nil);
      if not(roms_load(mcs51_0.get_rom_addr,lastmisn_mcu)) then exit;
      screen_prio:=false;
      //Cargar chars
      if not(roms_load(@memoria_temp,lastmisn_char)) then exit;
      copymemory(@memoria_temp[0],@memoria_temp[$8000],$2000);
      copymemory(@memoria_temp[$6000],@memoria_temp[$a000],$2000);
      copymemory(@memoria_temp[$4000],@memoria_temp[$c000],$2000);
      copymemory(@memoria_temp[$2000],@memoria_temp[$e000],$2000);
      lastmissn_convert_chars;
      //Cargar tiles
      getmem(ptemp,$100000);
      if not(roms_load(ptemp,lastmisn_tiles)) then exit;
      lastmissn_convert_tiles_sprites(1);
      //Cargar sprites
      if not(roms_load(ptemp,lastmisn_sprites)) then exit;
      lastmissn_convert_tiles_sprites(2);
      gfx[2].trans[0]:=true;
      freemem(ptemp);
      //DIP
      init_dips(1,lastmisn_dip_a,$cf);
      init_dips(2,lastmisn_dip_b,$7f);
  end;
  393:begin
      llamadas_maquina.bucle_general:=principal_lastmisn;
      call_io_mcu_read:=lastmisn_io_mcu_read;
      call_io_mcu_write:=shackled_io_mcu_write;
      //Main CPU
      m6809_0.change_ram_calls(getbyte_lastmisn,putbyte_lastmisn);
      if not(roms_load(@memoria_temp,shackled_rom)) then exit;
      copymemory(@memoria[$8000],@memoria_temp[0],$8000);
      for f:=0 to $d do copymemory(@rom[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
      copymemory(@rom[$e,0],@memoria_temp[$38000],$4000);
      copymemory(@rom[$f,0],@memoria_temp[$3c000],$4000);
      //Sub CPU
      m6809_1:=cpu_m6809.Create(2000000,TCPU_MC6809E);
      m6809_1.change_ram_calls(getbyte_sublastmisn,putbyte_lastmisn);
      if not(roms_load(@mem_misc,shackled_sub)) then exit;
      sub_nmi:=false;
      //Sound CPU
      m6502_0.change_ram_calls(getbyte_snd_lastmisn,putbyte_snd_lastmisn);
      if not(roms_load(@mem_snd,shackled_snd)) then exit;
      //MCU
      mcs51_0.change_io_calls(in_port0,in_port1,nil,in_port3,out_port0,out_port1,lastmisn_out_port2,nil);
      if not(roms_load(mcs51_0.get_rom_addr,shackled_mcu)) then exit;
      screen_prio:=true;
      //Cargar chars
      if not(roms_load(@memoria_temp,shackled_char)) then exit;
      lastmissn_convert_chars;
      //Cargar tiles
      getmem(ptemp,$100000);
      if not(roms_load(ptemp,shackled_tiles)) then exit;
      lastmissn_convert_tiles_sprites(1);
      for f:=0 to 3 do gfx[1].trans[f]:=true;
      //Cargar sprites
      if not(roms_load(ptemp,shackled_sprites)) then exit;
      lastmissn_convert_tiles_sprites(2);
      gfx[2].trans[0]:=true;
      freemem(ptemp);
      //DIP
      init_dips(1,shackled_dip_a,$ff);
      init_dips(2,shackled_dip_b,$7f);
  end;
  394:begin
      llamadas_maquina.bucle_general:=principal_gondo;
      eventos_gondo_call:=eventos_gondo;
      call_io_mcu_read:=gondo_io_mcu_read;
      call_io_mcu_write:=gondo_io_mcu_write;
      video_update_gondo:=update_video_gondo;
      //Main CPU
      hd6309_0.change_ram_calls(getbyte_gondo,putbyte_gondo);
      if not(roms_load(@memoria_temp,gondo_rom)) then exit;
      copymemory(@memoria[$8000],@memoria_temp[0],$8000);
      for f:=0 to $b do copymemory(@rom[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
      //Sound CPU
      m6502_0.change_ram_calls(getbyte_snd_deco222,putbyte_snd_deco222);
      if not(roms_load(@mem_snd,gondo_snd)) then exit;
      copymemory(@snd_dec,@mem_snd[$8000],$8000);
      //MCU
      mcs51_0.change_io_calls(in_port0,in_port1,nil,in_port3,out_port0,out_port1,gondo_out_port2,nil);
      if not(roms_load(mcs51_0.get_rom_addr,gondo_mcu)) then exit;
      screen_prio:=false;
      //Cargar chars
      if not(roms_load(@memoria_temp,gondo_char)) then exit;
      lastmissn_convert_chars;
      //Cargar tiles
      getmem(ptemp,$100000);
      getmem(ptemp2,$100000);
      if not(roms_load(ptemp2,gondo_tiles)) then exit;
      copymemory(@ptemp[0],@ptemp2[0],$8000);
      copymemory(@ptemp[$10000],@ptemp2[$8000],$8000);
      copymemory(@ptemp[$8000],@ptemp2[$10000],$8000);
      copymemory(@ptemp[$20000],@ptemp2[$18000],$8000);
      copymemory(@ptemp[$30000],@ptemp2[$20000],$8000);
      copymemory(@ptemp[$28000],@ptemp2[$28000],$8000);
      copymemory(@ptemp[$40000],@ptemp2[$30000],$8000);
      copymemory(@ptemp[$50000],@ptemp2[$38000],$8000);
      copymemory(@ptemp[$48000],@ptemp2[$40000],$8000);
      copymemory(@ptemp[$60000],@ptemp2[$48000],$8000);
      copymemory(@ptemp[$70000],@ptemp2[$50000],$8000);
      copymemory(@ptemp[$68000],@ptemp2[$58000],$8000);
      lastmissn_convert_tiles_sprites(1);
      freemem(ptemp2);
      //Cargar sprites
      if not(roms_load(ptemp,gondo_sprites)) then exit;
      lastmissn_convert_tiles_sprites(2);
      gfx[2].trans[0]:=true;
      freemem(ptemp);
      //DIP
      init_dips(1,gondo_dip_a,$ff);
      init_dips(2,gondo_dip_b,$ef);
  end;
  395:begin
      llamadas_maquina.bucle_general:=principal_gondo;
      eventos_gondo_call:=eventos_garyoret;
      call_io_mcu_read:=garyoret_io_mcu_read;
      call_io_mcu_write:=garyoret_io_mcu_write;
      video_update_gondo:=update_video_gondo;
      //Main CPU
      hd6309_0.change_ram_calls(getbyte_gondo,putbyte_gondo);
      if not(roms_load(@memoria_temp,garyoret_rom)) then exit;
      copymemory(@memoria[$8000],@memoria_temp[0],$8000);
      for f:=0 to $f do copymemory(@rom[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
      //Sound CPU
      m6502_0.change_ram_calls(getbyte_snd_deco222,putbyte_snd_deco222);
      if not(roms_load(@mem_snd,garyoret_snd)) then exit;
      copymemory(@snd_dec,@mem_snd[$8000],$8000);
      //MCU
      mcs51_0.change_io_calls(in_port0,in_port1,nil,in_port3,out_port0,out_port1,gondo_out_port2,nil);
      if not(roms_load(mcs51_0.get_rom_addr,garyoret_mcu)) then exit;
      screen_prio:=true;
      //Cargar chars
      if not(roms_load(@memoria_temp,garyoret_char)) then exit;
      lastmissn_convert_chars;
      //Cargar tiles
      getmem(ptemp,$100000);
      getmem(ptemp2,$100000);
      if not(roms_load(ptemp2,garyoret_tiles)) then exit;
      copymemory(@ptemp[0],@ptemp2[0],$8000);
      copymemory(@ptemp[$10000],@ptemp2[$8000],$8000);
      copymemory(@ptemp[$8000],@ptemp2[$10000],$8000);
      copymemory(@ptemp[$18000],@ptemp2[$18000],$8000);
      copymemory(@ptemp[$20000],@ptemp2[$20000],$8000);
      copymemory(@ptemp[$30000],@ptemp2[$28000],$8000);
      copymemory(@ptemp[$28000],@ptemp2[$30000],$8000);
      copymemory(@ptemp[$38000],@ptemp2[$38000],$8000);
      copymemory(@ptemp[$40000],@ptemp2[$40000],$8000);
      copymemory(@ptemp[$50000],@ptemp2[$48000],$8000);
      copymemory(@ptemp[$48000],@ptemp2[$50000],$8000);
      copymemory(@ptemp[$58000],@ptemp2[$58000],$8000);
      copymemory(@ptemp[$60000],@ptemp2[$60000],$8000);
      copymemory(@ptemp[$70000],@ptemp2[$68000],$8000);
      copymemory(@ptemp[$68000],@ptemp2[$70000],$8000);
      copymemory(@ptemp[$78000],@ptemp2[$78000],$8000);
      lastmissn_convert_tiles_sprites(1);
      for f:=0 to 3 do gfx[1].trans[f]:=true;
      freemem(ptemp2);
      //Cargar sprites
      if not(roms_load(ptemp,garyoret_sprites)) then exit;
      lastmissn_convert_tiles_sprites(2);
      gfx[2].trans[0]:=true;
      freemem(ptemp);
      //DIP
      init_dips(1,garyoret_dip_a,$ff);
      init_dips(2,garyoret_dip_b,$ff);
  end;
  396:begin
      llamadas_maquina.bucle_general:=principal_lastmisn;
      call_io_mcu_read:=csilver_io_mcu_read;
      call_io_mcu_write:=csilver_io_mcu_write;
      //Main CPU
      m6809_0.change_ram_calls(getbyte_lastmisn,putbyte_lastmisn);
      if not(roms_load(@memoria_temp,csilver_rom)) then exit;
      copymemory(@memoria[$8000],@memoria_temp[0],$8000);
      for f:=0 to 7 do copymemory(@rom[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
      //Sub CPU
      m6809_1:=cpu_m6809.create(1500000,TCPU_MC6809E);
      m6809_1.change_ram_calls(getbyte_sublastmisn,putbyte_lastmisn);
      if not(roms_load(@mem_misc,csilver_sub)) then exit;
      sub_nmi:=true;
      //Sound CPU
      m6502_0.change_ram_calls(getbyte_snd_csilver,putbyte_snd_csilver);
      if not(roms_load(@memoria_temp,csilver_snd)) then exit;
      copymemory(@mem_snd[$8000],@memoria_temp[$8000],$8000);
      copymemory(@sound_rom[0,0],@memoria_temp[0],$4000);
      copymemory(@sound_rom[1,0],@memoria_temp[$4000],$4000);
      msm5205_0:=MSM5205_chip.create(384000,MSM5205_S48_4B,1,0);
      msm5205_0.change_advance(snd_adpcm);
      //MCU
      mcs51_0.change_io_calls(in_port0,in_port1,nil,in_port3,out_port0,out_port1,csilver_out_port2,nil);
      if not(roms_load(mcs51_0.get_rom_addr,csilver_mcu)) then exit;
      screen_prio:=false;
      //Cargar chars
      if not(roms_load(@memoria_temp,csilver_char)) then exit;
      lastmissn_convert_chars;
      //Cargar tiles
      getmem(ptemp,$100000);
      if not(roms_load(ptemp,csilver_tiles)) then exit;
      lastmissn_convert_tiles_sprites(1);
      //Cargar sprites
      if not(roms_load(ptemp,csilver_sprites)) then exit;
      lastmissn_convert_tiles_sprites(2);
      gfx[2].trans[0]:=true;
      freemem(ptemp);
      //DIP
      init_dips(1,csilver_dip_a,$7f);
      init_dips(2,csilver_dip_b,$ff);
  end;
  397:begin
      llamadas_maquina.bucle_general:=principal_cobracom;
      //Main CPU
      m6809_0.change_ram_calls(getbyte_cobracom,putbyte_cobracom);
      if not(roms_load(@memoria_temp,cobracom_rom)) then exit;
      copymemory(@memoria[$8000],@memoria_temp[0],$8000);
      for f:=0 to 7 do copymemory(@rom[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
      //Sound CPU
      m6502_0.change_ram_calls(getbyte_snd_deco222,putbyte_snd_deco222);
      if not(roms_load(@mem_snd,cobracom_snd)) then exit;
      copymemory(@snd_dec,@mem_snd[$8000],$8000);
      //Cargar chars
      if not(roms_load(@memoria_temp,cobracom_char)) then exit;
      init_gfx(0,8,8,$400);
      gfx[0].trans[0]:=true;
      gfx_set_desc_data(2,0,8*8,$4000*8,0*8);
      convert_gfx(0,0,@memoria_temp,@ps_x[8],@ps_y,false,false);
      //Cargar tiles
      getmem(ptemp,$100000);
      getmem(ptemp2,$100000);
      if not(roms_load(ptemp2,cobracom_tiles2)) then exit;
      copymemory(@ptemp[0],@ptemp2[0],$8000);
      copymemory(@ptemp[$40000],@ptemp2[$8000],$8000);
      copymemory(@ptemp[$20000],@ptemp2[$10000],$8000);
      copymemory(@ptemp[$60000],@ptemp2[$18000],$8000);
      lastmissn_convert_tiles_sprites(1);
      gfx[1].trans[0]:=true;
      if not(roms_load(ptemp,cobracom_tiles1)) then exit;
      lastmissn_convert_tiles_sprites(2);
      gfx[2].trans[0]:=true;
      //Cargar sprites
      if not(roms_load(ptemp,cobracom_sprites)) then exit;
      lastmissn_convert_tiles_sprites(3);
      gfx[3].trans[0]:=true;
      freemem(ptemp);
      freemem(ptemp2);
      //DIP
      init_dips(1,cobracom_dip_a,$7f);
      init_dips(2,cobracom_dip_b,$ff);
  end;
  398:begin
      llamadas_maquina.bucle_general:=principal_gondo;
      eventos_gondo_call:=eventos_ghostb;
      video_update_gondo:=update_video_ghostb;
      //Main CPU
      hd6309_0.change_ram_calls(getbyte_ghostb,putbyte_ghostb);
      if not(roms_load(@memoria_temp,ghostb_rom)) then exit;
      copymemory(@memoria[$8000],@memoria_temp[0],$8000);
      for f:=0 to $f do copymemory(@rom[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
      //Sound CPU
      m6502_0.change_ram_calls(getbyte_snd_deco222,putbyte_snd_deco222);
      if not(roms_load(@mem_snd,ghostb_snd)) then exit;
      for f:=$8000 to $ffff do snd_dec[f-$8000]:=bitswap8(mem_snd[f],7,5,6,4,3,2,1,0);
      //MCU
      mcs51_0.change_io_calls(in_port0,in_port1,nil,in_port3,out_port0,out_port1,gondo_out_port2,nil);
      if not(roms_load(mcs51_0.get_rom_addr,ghostb_mcu)) then exit;
      screen_prio:=false;
      //Cargar chars
      if not(roms_load(@memoria_temp,ghostb_char)) then exit;
      lastmissn_convert_chars;
      //Cargar tiles
      getmem(ptemp,$100000);
      if not(roms_load(ptemp,ghostb_tiles)) then exit;
      init_gfx(1,16,16,$1000);
      gfx_set_desc_data(4,0,16*16,$20000*8,0*8,$30000*8,$10000*8);
      convert_gfx(1,0,ptemp,@gb_pt_x,@ps_y,false,false);
      //Cargar sprites
      if not(roms_load(ptemp,ghostb_sprites)) then exit;
      lastmissn_convert_tiles_sprites(2);
      gfx[2].trans[0]:=true;
      freemem(ptemp);
      if not(roms_load(@memoria_temp,ghostb_proms)) then exit;
      for f:=0 to $3ff do begin
        colores[f].r:=(memoria_temp[f] and 1)*$e+((memoria_temp[f] and 2) shr 1)*$1f+((memoria_temp[f] and 4) shr 2)*$43+((memoria_temp[f] and 8) shr 3)*$8f;
        colores[f].g:=((memoria_temp[f] and $10) shr 4)*$e+((memoria_temp[f] and $20) shr 5)*$1f+((memoria_temp[f] and $40) shr 6)*$43+((memoria_temp[f] and $80) shr 7)*$8f;
        colores[f].b:=(memoria_temp[f+$400] and 1)*$e+((memoria_temp[f+$400] and 2) shr 1)*$1f+((memoria_temp[f+$400] and 4) shr 2)*$43+((memoria_temp[f+$400] and 8) shr 3)*$8f;
      end;
      set_pal(colores,$400);
      //DIP
      init_dips(1,ghostb_dip_a,$f0);
      init_dips(2,ghostb_dip_b,$bf);
  end;
  399:begin
      llamadas_maquina.bucle_general:=principal_oscar;
      //Main CPU
      hd6309_0.change_ram_calls(getbyte_oscar,putbyte_oscar);
      if not(roms_load(@memoria_temp,oscar_rom)) then exit;
      copymemory(@memoria[$8000],@memoria_temp[0],$8000);
      for f:=0 to 3 do copymemory(@rom[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
      //Sub CPU
      hd6309_1:=cpu_hd6309.create(6000000,TCPU_HD6309E);
      hd6309_1.change_ram_calls(getbyte_suboscar,putbyte_suboscar);
      if not(roms_load(@mem_misc,oscar_sub)) then exit;
      //Sound CPU
      m6502_0.change_ram_calls(getbyte_snd_deco222,putbyte_snd_deco222);
      if not(roms_load(@mem_snd,oscar_snd)) then exit;
      for f:=$8000 to $ffff do snd_dec[f-$8000]:=bitswap8(mem_snd[f],7,5,6,4,3,2,1,0);
      //Cargar chars
      if not(roms_load(@memoria_temp,oscar_char)) then exit;
      init_gfx(0,8,8,$400);
      gfx[0].trans[0]:=true;
      gfx_set_desc_data(3,0,8*8,$3000*8,$2000*8,$1000*8);
      convert_gfx(0,0,@memoria_temp,@ps_x[8],@ps_y,false,false);
      //Cargar tiles
      getmem(ptemp,$100000);
      if not(roms_load(ptemp,oscar_tiles)) then exit;
      lastmissn_convert_tiles_sprites(1);
      //Cargar sprites
      if not(roms_load(ptemp,oscar_sprites)) then exit;
      lastmissn_convert_tiles_sprites(2);
      gfx[2].trans[0]:=true;
      freemem(ptemp);
      //DIP
      init_dips(1,oscar_dip_a,$7f);
      init_dips(2,oscar_dip_b,$ff);
  end;
end;
//final
reset_dec8;
iniciar_dec8:=true;
end;

end.
