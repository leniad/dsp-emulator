unit mappy_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6809,main_engine,controls_engine,gfx_engine,namco_snd,namcoio_56xx_58xx,
     rom_engine,pal_engine,sound_engine;

function iniciar_mappyhw:boolean;

implementation
const
        //Mappy
        mappy_rom:array[0..2] of tipo_roms=(
        (n:'mpx_3.1d';l:$2000;p:$a000;crc:$52e6c708),(n:'mp1_2.1c';l:$2000;p:$c000;crc:$a958a61c),
        (n:'mpx_1.1b';l:$2000;p:$e000;crc:$203766d4));
        mappy_proms:array[0..2] of tipo_roms=(
        (n:'mp1-5.5b';l:$20;p:0;crc:$56531268),(n:'mp1-6.4c';l:$100;p:$20;crc:$50765082),
        (n:'mp1-7.5k';l:$100;p:$120;crc:$5396bd78));
        mappy_chars:tipo_roms=(n:'mp1_5.3b';l:$1000;p:0;crc:$16498b9f);
        mappy_sprites:array[0..1] of tipo_roms=(
        (n:'mp1_6.3m';l:$2000;p:0;crc:$f2d9647a),(n:'mp1_7.3n';l:$2000;p:$2000;crc:$757cf2b6));
        mappy_sound:tipo_roms=(n:'mp1_4.1k';l:$2000;p:$e000;crc:$8182dd5b);
        mappy_sound_prom:tipo_roms=(n:'mp1-3.3m';l:$100;p:0;crc:$16a9166a);
        mappy_dip_a:array [0..5] of def_dip=(
        (mask:$7;name:'Difficulty';number:8;dip:((dip_val:$7;dip_name:'Rank A'),(dip_val:$6;dip_name:'Rank B'),(dip_val:$5;dip_name:'Rank C'),(dip_val:$4;dip_name:'Rank D'),(dip_val:$3;dip_name:'Rank E'),(dip_val:$2;dip_name:'Rank F'),(dip_val:$1;dip_name:'Rank G'),(dip_val:$0;dip_name:'Rank H'),(),(),(),(),(),(),(),())),
        (mask:$18;name:'Coin B';number:4;dip:((dip_val:$0;dip_name:'2C 1C'),(dip_val:$18;dip_name:'1C 1C'),(dip_val:$10;dip_name:'1C 5C'),(dip_val:$8;dip_name:'1C 7C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$20;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Rack test';number:2;dip:((dip_val:$40;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Freeze';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        mappy_dip_b:array [0..3] of def_dip=(
        (mask:$7;name:'Coin A';number:8;dip:((dip_val:$1;dip_name:'3C 1C'),(dip_val:$3;dip_name:'2C 1C'),(dip_val:$0;dip_name:'3C 2C'),(dip_val:$7;dip_name:'1C 1C'),(dip_val:$2;dip_name:'2C 3C'),(dip_val:$6;dip_name:'1C 2C'),(dip_val:$5;dip_name:'1C 3C'),(dip_val:$4;dip_name:'1C 6C'),(),(),(),(),(),(),(),())),
        (mask:$38;name:'Bonus Life';number:8;dip:((dip_val:$18;dip_name:'20K'),(dip_val:$30;dip_name:'20K 60K'),(dip_val:$38;dip_name:'20K 70K'),(dip_val:$10;dip_name:'20K 70K 70K+'),(dip_val:$28;dip_name:'20K 80K'),(dip_val:$8;dip_name:'20K 80K 80K+'),(dip_val:$20;dip_name:'30K 100K'),(dip_val:$0;dip_name:'None'),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Lives';number:4;dip:((dip_val:$40;dip_name:'1'),(dip_val:$0;dip_name:'2'),(dip_val:$c0;dip_name:'3'),(dip_val:$80;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),());
        mappy_dip_c:array [0..1] of def_dip=(
        (mask:$4;name:'Cabinet';number:2;dip:((dip_val:$4;dip_name:'Upright'),(dip_val:$0;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        //Dig Dug 2
        dd2_rom:array[0..1] of tipo_roms=(
        (n:'d23_3.1d';l:$4000;p:$8000;crc:$cc155338),(n:'d23_1.1b';l:$4000;p:$c000;crc:$40e46af8));
        dd2_proms:array[0..2] of tipo_roms=(
        (n:'d21-5.5b';l:$20;p:0;crc:$9b169db5),(n:'d21-6.4c';l:$100;p:$20;crc:$55a88695),
        (n:'d21-7.5k';l:$100;p:$120;crc:$9c55feda));
        dd2_chars:tipo_roms=(n:'d21_5.3b';l:$1000;p:0;crc:$afcb4509);
        dd2_sprites:array[0..1] of tipo_roms=(
        (n:'d21_6.3m';l:$4000;p:0;crc:$df1f4ad8),(n:'d21_7.3n';l:$4000;p:$4000;crc:$ccadb3ea));
        dd2_sound:tipo_roms=(n:'d21_4.1k';l:$2000;p:$e000;crc:$737443b1);
        dd2_sound_prom:tipo_roms=(n:'d21-3.3m';l:$100;p:0;crc:$e0074ee2);
        digdug2_dip:array [0..5] of def_dip=(
        (mask:$2;name:'Lives';number:2;dip:((dip_val:$2;dip_name:'3'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Coinage';number:4;dip:((dip_val:$c;dip_name:'1C 1C'),(dip_val:$8;dip_name:'2C 1C'),(dip_val:$4;dip_name:'1C 2C'),(dip_val:$0;dip_name:'1C 3C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Bonus Life';number:4;dip:((dip_val:$30;dip_name:'30K 80K and ...'),(dip_val:$20;dip_name:'30K 100K and ...'),(dip_val:$10;dip_name:'30K 100K and ...'),(dip_val:$30;dip_name:'30K 150K and ...'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Level Select';number:2;dip:((dip_val:$40;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Freeze';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        //Super Pacman
        spacman_rom:array[0..1] of tipo_roms=(
        (n:'sp1-2.1c';l:$2000;p:$c000;crc:$4bb33d9c),(n:'sp1-1.1b';l:$2000;p:$e000;crc:$846fbb4a));
        spacman_proms:array[0..2] of tipo_roms=(
        (n:'superpac.4c';l:$20;p:0;crc:$9ce22c46),(n:'superpac.4e';l:$100;p:$20;crc:$1253c5c1),
        (n:'superpac.3l';l:$100;p:$120;crc:$d4d7026f));
        spacman_chars:tipo_roms=(n:'sp1-6.3c';l:$1000;p:0;crc:$91c5935c);
        spacman_sprites:tipo_roms=(n:'spv-2.3f';l:$2000;p:0;crc:$670a42f2);
        spacman_sound:tipo_roms=(n:'spc-3.1k';l:$1000;p:$f000;crc:$04445ddb);
        spacman_sound_prom:tipo_roms=(n:'superpac.3m';l:$100;p:0;crc:$ad43688f);
        spacman_dip_a:array [0..4] of def_dip=(
        (mask:$f;name:'Difficulty';number:16;dip:((dip_val:$f;dip_name:'Rank 0 - Normal'),(dip_val:$e;dip_name:'Rank 1-Easyest'),(dip_val:$d;dip_name:'Rank 2'),(dip_val:$c;dip_name:'Rank 3'),(dip_val:$b;dip_name:'Rank 4'),(dip_val:$a;dip_name:'Rank 5'),(dip_val:$6;dip_name:'Rank 6 - Medium'),(dip_val:$8;dip_name:'Rank 7'),(dip_val:$7;dip_name:'Rank 8 - Default'),(dip_val:$6;dip_name:'Rank 9'),(dip_val:$5;dip_name:'Rank A'),(dip_val:$4;dip_name:'Rank B -Hardest'),(dip_val:$3;dip_name:'Rank C - Easy Auto'),(dip_val:$2;dip_name:'Rank D - Auto'),(dip_val:$1;dip_name:'Rank E - Auto'),(dip_val:$0;dip_name:'Rank F - Hard Auto'))),
        (mask:$30;name:'Coin B';number:4;dip:((dip_val:$10;dip_name:'2C 1C'),(dip_val:$30;dip_name:'1C 1C'),(dip_val:$0;dip_name:'2C 3C'),(dip_val:$20;dip_name:'1C 2C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$40;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Freeze / Rack Test';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        spacman_dip_b:array [0..3] of def_dip=(
        (mask:$7;name:'Coin A';number:8;dip:((dip_val:$0;dip_name:'3C 1C'),(dip_val:$2;dip_name:'2C 1C'),(dip_val:$7;dip_name:'1C 1C'),(dip_val:$1;dip_name:'2C 3C'),(dip_val:$6;dip_name:'1C 2C'),(dip_val:$5;dip_name:'1C 3C'),(dip_val:$4;dip_name:'1C 6C'),(dip_val:$3;dip_name:'1C 7C'),(),(),(),(),(),(),(),())),
        (mask:$38;name:'Bonus Life';number:8;dip:((dip_val:$8;dip_name:'30K'),(dip_val:$30;dip_name:'30K 80K'),(dip_val:$20;dip_name:'30K 80K 80K+'),(dip_val:$38;dip_name:'30K 100K'),(dip_val:$18;dip_name:'30K 100K 100K+'),(dip_val:$28;dip_name:'20K 120K'),(dip_val:$10;dip_name:'30K 120K 120K+'),(dip_val:$0;dip_name:'None'),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Lives';number:4;dip:((dip_val:$80;dip_name:'1'),(dip_val:$40;dip_name:'2'),(dip_val:$c0;dip_name:'3'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),());
        //The Tower of Druaga
        todruaga_rom:array[0..1] of tipo_roms=(
        (n:'td2_3.1d';l:$4000;p:$8000;crc:$fbf16299),(n:'td2_1.1b';l:$4000;p:$c000;crc:$b238d723));
        todruaga_proms:array[0..2] of tipo_roms=(
        (n:'td1-5.5b';l:$20;p:0;crc:$122cc395),(n:'td1-6.4c';l:$100;p:$20;crc:$8c661d6a),
        (n:'td1-7.5k';l:$400;p:$120;crc:$a86c74dd));
        todruaga_chars:tipo_roms=(n:'td1_5.3b';l:$1000;p:0;crc:$d32b249f);
        todruaga_sprites:array[0..1] of tipo_roms=(
        (n:'td1_6.3m';l:$2000;p:0;crc:$e827e787),(n:'td1_7.3n';l:$2000;p:$2000;crc:$962bd060));
        todruaga_sound:tipo_roms=(n:'td1_4.1k';l:$2000;p:$e000;crc:$ae9d06d9);
        todruaga_sound_prom:tipo_roms=(n:'td1-3.3m';l:$100;p:0;crc:$07104c40);
        todruaga_dip:array [0..4] of def_dip=(
        (mask:$3;name:'Lives';number:4;dip:((dip_val:$1;dip_name:'1'),(dip_val:$2;dip_name:'2'),(dip_val:$3;dip_name:'3'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Coin A';number:4;dip:((dip_val:$0;dip_name:'3C 1C'),(dip_val:$8;dip_name:'2C 1C'),(dip_val:$c;dip_name:'1C 1C'),(dip_val:$4;dip_name:'1C 2C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Freeze';number:2;dip:((dip_val:$10;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Coin B';number:4;dip:((dip_val:$0;dip_name:'3C 1C'),(dip_val:$80;dip_name:'2C 1C'),(dip_val:$c0;dip_name:'1C 1C'),(dip_val:$40;dip_name:'1C 2C'),(),(),(),(),(),(),(),(),(),(),(),())),());
        //Motos
        motos_rom:array[0..1] of tipo_roms=(
        (n:'mo1_3.1d';l:$4000;p:$8000;crc:$1104abb2),(n:'mo1_1.1b';l:$4000;p:$c000;crc:$57b157e2));
        motos_proms:array[0..2] of tipo_roms=(
        (n:'mo1-5.5b';l:$20;p:0;crc:$71972383),(n:'mo1-6.4c';l:$100;p:$20;crc:$730ba7fb),
        (n:'mo1-7.5k';l:$100;p:$120;crc:$7721275d));
        motos_chars:tipo_roms=(n:'mo1_5.3b';l:$1000;p:0;crc:$5d4a2a22);
        motos_sprites:array[0..1] of tipo_roms=(
        (n:'mo1_6.3m';l:$4000;p:0;crc:$2f0e396e),(n:'mo1_7.3n';l:$4000;p:$4000;crc:$cf8a3b86));
        motos_sound:tipo_roms=(n:'mo1_4.1k';l:$2000;p:$e000;crc:$55e45d21);
        motos_sound_prom:tipo_roms=(n:'mo1-3.3m';l:$100;p:0;crc:$2accdfb4);
        motos_dip:array [0..5] of def_dip=(
        (mask:$6;name:'Coinage';number:4;dip:((dip_val:$0;dip_name:'3C 1C'),(dip_val:$2;dip_name:'2C 1C'),(dip_val:$6;dip_name:'1C 1C'),(dip_val:$4;dip_name:'1C 2C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Lives';number:2;dip:((dip_val:$8;dip_name:'3'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Difficulty';number:2;dip:((dip_val:$10;dip_name:'Rank A'),(dip_val:$0;dip_name:'Rank B'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$60;name:'Bonus Life';number:4;dip:((dip_val:$60;dip_name:'10K 30K 50K+'),(dip_val:$40;dip_name:'20K 50K+'),(dip_val:$20;dip_name:'30K 70K+'),(dip_val:$0;dip_name:'20K 70K'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$80;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        //Grobda
        grobda_rom:array[0..2] of tipo_roms=(
        (n:'gr2-3.1d';l:$2000;p:$a000;crc:$8e3a23be),(n:'gr2-2.1c';l:$2000;p:$c000;crc:$19ffa83d),
        (n:'gr2-1.1b';l:$2000;p:$e000;crc:$0089b13a));
        grobda_proms:array[0..2] of tipo_roms=(
        (n:'gr1-6.4c';l:$20;p:0;crc:$c65efa77),(n:'gr1-5.4e';l:$100;p:$20;crc:$a0f66911),
        (n:'gr1-4.3l';l:$100;p:$120;crc:$f1f2c234));
        grobda_chars:tipo_roms=(n:'gr1-7.3c';l:$1000;p:0;crc:$4ebfabfd);
        grobda_sprites:array[0..1] of tipo_roms=(
        (n:'gr1-5.3f';l:$2000;p:0;crc:$eed43487),(n:'gr1-6.3e';l:$2000;p:$2000;crc:$cebb7362));
        grobda_sound:tipo_roms=(n:'gr1-4.1k';l:$2000;p:$e000;crc:$3fe78c08);
        grobda_sound_prom:tipo_roms=(n:'gr1-3.3m';l:$100;p:0;crc:$66eb1467);
        grobda_dip_a:array [0..3] of def_dip=(
        (mask:$e;name:'Coin A';number:8;dip:((dip_val:$0;dip_name:'4C 1C'),(dip_val:$2;dip_name:'3C 1C'),(dip_val:$6;dip_name:'2C 1C'),(dip_val:$8;dip_name:'1C 1C'),(dip_val:$4;dip_name:'2C 3C'),(dip_val:$a;dip_name:'1C 2C'),(dip_val:$e;dip_name:'1C 3C'),(dip_val:$c;dip_name:'1C 4C'),(),(),(),(),(),(),(),())),
        (mask:$70;name:'Coin B';number:8;dip:((dip_val:$0;dip_name:'4C 1C'),(dip_val:$10;dip_name:'3C 1C'),(dip_val:$30;dip_name:'2C 1C'),(dip_val:$40;dip_name:'1C 1C'),(dip_val:$20;dip_name:'2C 3C'),(dip_val:$50;dip_name:'1C 2C'),(dip_val:$70;dip_name:'1C 3C'),(dip_val:$60;dip_name:'1C 4C'),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Freeze / Rack Test';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        grobda_dip_b:array [0..5] of def_dip=(
        (mask:$3;name:'Lives';number:4;dip:((dip_val:$2;dip_name:'1'),(dip_val:$1;dip_name:'2'),(dip_val:$3;dip_name:'3'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Difficulty';number:4;dip:((dip_val:$c;dip_name:'Rank A'),(dip_val:$8;dip_name:'Rank B'),(dip_val:$4;dip_name:'Rank C'),(dip_val:$0;dip_name:'Rank D'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Demo_Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$10;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Level Select';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$20;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Bonus Life';number:4;dip:((dip_val:$0;dip_name:'10K 50K 50K+'),(dip_val:$40;dip_name:'10K 30K'),(dip_val:$c0;dip_name:'10K'),(dip_val:$80;dip_name:'None'),(),(),(),(),(),(),(),(),(),(),(),())),());
        //Pac'n'Pal
        pacnpal_rom:array[0..2] of tipo_roms=(
        (n:'pap1-3b.1d';l:$2000;p:$a000;crc:$ed64a565),(n:'pap1-2b.1c';l:$2000;p:$c000;crc:$15308bcf),
        (n:'pap3-1.1b';l:$2000;p:$e000;crc:$3cac401c));
        pacnpal_proms:array[0..2] of tipo_roms=(
        (n:'pap1-6.4c';l:$20;p:0;crc:$52634b41),(n:'pap1-5.4e';l:$100;p:$20;crc:$ac46203c),
        (n:'pap1-4.3l';l:$100;p:$120;crc:$686bde84));
        pacnpal_chars:tipo_roms=(n:'pap1-6.3c';l:$1000;p:0;crc:$a36b96cb);
        pacnpal_sprites:tipo_roms=(n:'pap1-5.3f';l:$2000;p:0;crc:$fb6f56e3);
        pacnpal_sound:tipo_roms=(n:'pap1-4.1k';l:$1000;p:$f000;crc:$330e20de);
        pacnpal_sound_prom:tipo_roms=(n:'pap1-3.3m';l:$100;p:0;crc:$94782db5);
        pacnpal_dip_a:array [0..3] of def_dip=(
        (mask:$7;name:'Coin A';number:8;dip:((dip_val:$0;dip_name:'3C 1C'),(dip_val:$2;dip_name:'2C 1C'),(dip_val:$7;dip_name:'1C 1C'),(dip_val:$1;dip_name:'2C 3C'),(dip_val:$6;dip_name:'1C 2C'),(dip_val:$5;dip_name:'1C 3C'),(dip_val:$4;dip_name:'1C 6C'),(dip_val:$3;dip_name:'1C 7C'),(),(),(),(),(),(),(),())),
        (mask:$38;name:'Bonus Life';number:8;dip:((dip_val:$20;dip_name:'20K 70K'),(dip_val:$30;dip_name:'20K 70K 70K+'),(dip_val:$0;dip_name:'30K'),(dip_val:$18;dip_name:'30K 70K'),(dip_val:$10;dip_name:'30K 80K'),(dip_val:$28;dip_name:'30K 100K 80K+'),(dip_val:$8;dip_name:'30K 100K'),(dip_val:$38;dip_name:'None'),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Lives';number:4;dip:((dip_val:$c0;dip_name:'1'),(dip_val:$80;dip_name:'2'),(dip_val:$40;dip_name:'3'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),());
        pacnpal_dip_b:array [0..2] of def_dip=(
        (mask:$3;name:'Coin B';number:4;dip:((dip_val:$1;dip_name:'2C 1C'),(dip_val:$3;dip_name:'1C 1C'),(dip_val:$0;dip_name:'2C 3C'),(dip_val:$2;dip_name:'1C 2C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Difficulty';number:4;dip:((dip_val:$c;dip_name:'Rank A'),(dip_val:$8;dip_name:'Rank B'),(dip_val:$4;dip_name:'Rank C'),(dip_val:$0;dip_name:'Rank D'),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 snd_int,main_int:boolean;
 mux,sprite_mask:byte;
 update_video_proc:procedure;
 scroll_x:word;

procedure update_video_mappy;
const
  linea_x:array[0..$1f] of byte=($11,$10,$1f,$1e,$1d,$1c,$1b,$1a,$19,$18,$17,$16,$15,$14,$13,$12,1,0,$f,$e,$d,$c,$b,$a,9,8,7,6,5,4,3,2);
var
  f,color:word;
  x,y,atrib,nchar:byte;
procedure draw_sprites_mappy;
var
  color,y:word;
  flipx,flipy:boolean;
  nchar,x,f,atrib,size,a,b,c,d,mix:byte;
begin
for f:=0 to $3f do begin
  if (memoria[$2781+(f*2)] and $2)=0 then begin
    atrib:=memoria[$2780+(f*2)];
    nchar:=memoria[$1780+(f*2)] and sprite_mask;
    color:=memoria[$1781+(f*2)] shl 4;
    x:=memoria[$1f80+(f*2)]-16;
    y:=memoria[$1f81+(f*2)]+$100*(memoria[$2781+(f*2)] and 1)-40;
    flipx:=(atrib and $02)<>0;
    flipy:=(atrib and $01)<>0;
    size:=((atrib and $c) shr 2);
    case size of
      0:begin  //16x16
            put_gfx_sprite_mask(nchar,color,flipx,flipy,1,$f,$f);
            actualiza_gfx_sprite(x,y,3,1);
        end;
      1:begin //16x32
            nchar:=nchar and $fe;
            a:=0 xor byte(flipy);
            b:=1 xor byte(flipy);
            put_gfx_sprite_mask_diff(nchar+a,color,flipx,false,1,$f,$f,0,0);
            put_gfx_sprite_mask_diff(nchar+b,color,flipx,false,1,$f,$f,0,16);
            actualiza_gfx_sprite_size(x,y,3,16,32);
        end;
      2:begin //32x16
            nchar:=nchar and $fd;
            a:=2 xor (byte(flipx) shl 1);
            b:=0 xor (byte(flipx) shl 1);
            put_gfx_sprite_mask_diff(nchar+a,color,flipx,flipy,1,$f,$f,0,0);
            put_gfx_sprite_mask_diff(nchar+b,color,flipx,flipy,1,$f,$f,16,0);
            actualiza_gfx_sprite_size(x,y,3,32,16);
        end;
      3:begin //32x32
            nchar:=nchar and $fc;
            if flipx then begin
              a:=0;b:=2;c:=1;d:=3
            end else begin
              a:=2;b:=0;c:=3;d:=1;
            end;
            if flipy then begin
              mix:=a;a:=c;c:=mix;
              mix:=b;b:=d;d:=mix;
            end;
            put_gfx_sprite_mask_diff(nchar+a,color,flipx,flipy,1,$f,$f,0,0);
            put_gfx_sprite_mask_diff(nchar+b,color,flipx,flipy,1,$f,$f,16,0);
            put_gfx_sprite_mask_diff(nchar+c,color,flipx,flipy,1,$f,$f,0,16);
            put_gfx_sprite_mask_diff(nchar+d,color,flipx,flipy,1,$f,$f,16,16);
            actualiza_gfx_sprite_size(x,y,3,32,32);
         end;
      end;
    end;
  end;
end;
begin
for f:=$7ff downto 0 do begin
    if gfx[0].buffer[f] then begin
      nchar:=memoria[$0+f];
      atrib:=memoria[$800+f];
      color:=(atrib and $3f) shl 2;
      case f of
        0..$77f:begin
                     x:=59-(f div 32);
                     y:=f mod 32;
                     put_gfx(x*8,(y*8)+16,nchar,color,1,0);
                     if (atrib and $40)=0 then put_gfx_block_trans(x*8,(y*8)+16,2,8,8)
                        else put_gfx_mask(x*8,(y*8)+16,nchar,color,2,0,$1f,$3f);
                end;
        $780..$7bf:begin
                      //lineas de abajo
                      x:=f and $1f;
                      y:=(f and $3f) shr 5;
                      put_gfx(linea_x[x]*8,(y*8)+256+16,nchar,color,1,0);
                      if (atrib and $40)=0 then put_gfx_block_trans(linea_x[x]*8,(y*8)+256+16,2,8,8)
                        else put_gfx_mask(linea_x[x]*8,(y*8)+256+16,nchar,color,2,0,$1f,$3f);
                    end;
        $7c0..$7ff:begin
                      //lineas de arriba
                      x:=f and $1f;
                      y:=(f and $3f) shr 5;
                      put_gfx(linea_x[x]*8,y*8,nchar,color,1,0);
                      if (atrib and $40)=0 then put_gfx_block_trans(linea_x[x]*8,y*8,2,8,8)
                        else put_gfx_mask(linea_x[x]*8,y*8,nchar,color,2,0,$1f,$3f);
                    end;
      end;
      gfx[0].buffer[f]:=false;
    end;
end;
//Las lineas de arriba y abajo fijas...
actualiza_trozo(32,0,224,16,1,0,0,224,16,3);
actualiza_trozo(32,272,224,16,1,0,272,224,16,3);
//Pantalla principal
scroll__x_part(1,3,scroll_x,0,16,256);
//Los sprites
draw_sprites_mappy;
//Las lineas de arriba y abajo fijas transparentes...
actualiza_trozo(32,0,224,16,2,0,0,224,16,3);
actualiza_trozo(32,272,224,16,2,0,272,224,16,3);
//Pantalla principal transparente
scroll__x_part(2,3,scroll_x,0,16,256);
//final, lo pego todooooo
actualiza_trozo_final(0,0,224,288,3);
end;

procedure update_video_spacman;
var
  f,color:word;
  x,y,atrib,nchar:byte;
procedure draw_sprites_spacman;
var
  color,y:word;
  flipx,flipy:boolean;
  nchar,x,f,size,a,b,c,d,mix,atrib:byte;
begin
for f:=0 to $3f do begin
  if (memoria[$1f81+(f*2)] and $2)=0 then begin
    atrib:=memoria[$1f80+(f*2)];
    y:=memoria[$1781+(f*2)]+$100*(memoria[$1f81+(f*2)] and 1)-40;
    nchar:=memoria[$f80+(f*2)] and sprite_mask;
    color:=memoria[$f81+(f*2)] shl 2;
    x:=memoria[$1780+(f*2)]-17;
    flipx:=(atrib and $02)<>0;
    flipy:=(atrib and $01)<>0;
    size:=(atrib and $c) shr 2;
    case size of
      0:begin  //16x16
            put_gfx_sprite_mask(nchar,color,flipx,flipy,1,$f,$f);
            actualiza_gfx_sprite(x,y,3,1);
        end;
      1:begin //16x32
            nchar:=nchar and $fe;
            a:=0 xor byte(flipy);
            b:=1 xor byte(flipy);
            put_gfx_sprite_mask_diff(nchar+a,color,flipx,flipy,1,15,$f,0,0);
            put_gfx_sprite_mask_diff(nchar+b,color,flipx,flipy,1,15,$f,0,16);
            actualiza_gfx_sprite_size(x,y,3,16,32);
        end;
      2:begin //32x16
            nchar:=nchar and $fd;
            a:=2 xor (byte(flipx) shl 1);
            b:=0 xor (byte(flipx) shl 1);
            put_gfx_sprite_mask_diff(nchar+a,color,flipx,flipy,1,15,$f,0,0);
            put_gfx_sprite_mask_diff(nchar+b,color,flipx,flipy,1,15,$f,16,0);
            actualiza_gfx_sprite_size(x,y,3,32,16);
        end;
      3:begin //32x32
            nchar:=nchar and $fc;
            if flipx then begin
              a:=0;b:=2;c:=1;d:=3
            end else begin
              a:=2;b:=0;c:=3;d:=1;
            end;
            if flipy then begin
              mix:=a;a:=c;c:=mix;
              mix:=b;b:=d;d:=mix;
            end;
            put_gfx_sprite_mask_diff(nchar+a,color,flipx,flipy,1,15,$f,0,0);
            put_gfx_sprite_mask_diff(nchar+b,color,flipx,flipy,1,15,$f,16,0);
            put_gfx_sprite_mask_diff(nchar+c,color,flipx,flipy,1,15,$f,0,16);
            put_gfx_sprite_mask_diff(nchar+d,color,flipx,flipy,1,15,$f,16,16);
            actualiza_gfx_sprite_size(x,y,3,32,32);
         end;
      end;
    end;
  end;
end;
begin
for f:=$3ff downto 0 do begin
    if gfx[0].buffer[f] then begin
      nchar:=memoria[$0+f];
      atrib:=memoria[$400+f];
      color:=(atrib and $3f) shl 2;
      case f of
        $40..$3bf:begin
                       x:=31-(f div 32);
                       y:=f mod 32;
                       put_gfx(x*8,(y*8)+16,nchar,color,1,0);
                       if (atrib and $40)=0 then put_gfx_block_trans(x*8,(y*8)+16,2,8,8)
                          else put_gfx_mask(x*8,(y*8)+16,nchar,color,2,0,$1f,$1f);
                end;
        $0..$3f:begin
                      //lineas de abajo
                      x:=31-(f and $1f);
                      y:=(f and $3f) shr 5;
                      put_gfx(x*8,(y*8)+256+16,nchar,color,1,0);
                      if (atrib and $40)=0 then put_gfx_block_trans(x*8,(y*8)+256+16,2,8,8)
                        else put_gfx_mask(x*8,(y*8)+256+16,nchar,color,2,0,$1f,$1f);
                    end;
        $3c0..$3ff:begin
                      //lineas de arriba
                      x:=31-(f and $1f);
                      y:=(f and $3f) shr 5;
                      put_gfx(x*8,y*8,nchar,color,1,0);
                      if (atrib and $40)=0 then put_gfx_block_trans(x*8,y*8,2,8,8)
                        else put_gfx_mask(x*8,y*8,nchar,color,2,0,$1f,$1f);
                    end;
      end;
     gfx[0].buffer[f]:=false;
    end;
end;
//Pantalla principal
actualiza_trozo(16,0,224,288,1,0,0,224,288,3);
//Los sprites
draw_sprites_spacman;
//Pantalla principal transparente
actualiza_trozo(16,0,224,288,2,0,0,224,288,3);
//final, lo pego todooooo
actualiza_trozo_final(0,0,224,288,3);
end;

procedure eventos_mappy;
begin
if event.arcade then begin
  //P1 & P2
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.up[1] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.right[1] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.down[1] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.left[1] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  //System
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.coin[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.coin[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  //P1 & P2 extra but (DigDug II/Grobda solo)
  if arcade_input.but1[0] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
end;
end;

procedure mappy_principal;
var
  f:word;
  frame_m,frame_s:single;
begin
init_controls(false,false,false,true);
frame_m:=m6809_0.tframes;
frame_s:=m6809_1.tframes;
while EmuStatus=EsRunning do begin
  for f:=0 to 263 do begin
    //Main CPU
    m6809_0.run(frame_m);
    frame_m:=frame_m+m6809_0.tframes-m6809_0.contador;
    //Sound CPU
    m6809_1.run(frame_s);
    frame_s:=frame_s+m6809_1.tframes-m6809_1.contador;
    if f=223 then begin
      if main_int then m6809_0.change_irq(ASSERT_LINE);
      if snd_int then m6809_1.change_irq(ASSERT_LINE);
      if not(namco_5x_0.reset_status) then namco_5x_0.run;
      if not(namco_5x_1.reset_status) then namco_5x_1.run;
      update_video_proc;
    end;
  end;
  eventos_mappy;
  video_sync;
end;
end;

function mappy_getbyte(direccion:word):byte;
begin
  case direccion of
    0..$27ff,$4000..$43ff,$8000..$ffff:mappy_getbyte:=memoria[direccion];
    $4800..$480f:mappy_getbyte:=namco_5x_0.read(direccion and $f);
    $4810..$481f:mappy_getbyte:=namco_5x_1.read(direccion and $f);
  end;
end;

procedure mappy_latch(direccion:byte);
begin
case (direccion and $e) of
  $0:begin
        snd_int:=(direccion and 1)<>0;
        if not(snd_int) then m6809_1.change_irq(CLEAR_LINE);
      end;
  $2:begin
        main_int:=(direccion and 1)<>0;
        if not(main_int) then m6809_0.change_irq(CLEAR_LINE);
      end;
  $4:main_screen.flip_main_screen:=(direccion and 1)<>0;
  $6:namco_snd_0.enabled:=(direccion and 1)<>0;
  $8:begin
        namco_5x_0.reset_internal((direccion and 1)=0);
        namco_5x_1.reset_internal((direccion and 1)=0);
      end;
  $a:if ((direccion and 1)<>0) then m6809_1.change_reset(CLEAR_LINE)
          else m6809_1.change_reset(ASSERT_LINE);
end;
end;

procedure mappy_putbyte(direccion:word;valor:byte);
begin
case direccion of
  $0..$fff:if memoria[direccion]<>valor then begin
              gfx[0].buffer[direccion and $7ff]:=true;
              memoria[direccion]:=valor;
           end;
  $1000..$27ff,$4040..$43ff:memoria[direccion]:=valor;
  $3800..$3fff:scroll_x:=256-((direccion and $7ff) shr 3);
  $4000..$403f:begin
                  namco_snd_0.regs[direccion and $3f]:=valor;
                  memoria[direccion]:=valor;
               end;
  $4800..$480f:namco_5x_0.write(direccion and $f,valor);
  $4810..$481f:namco_5x_1.write(direccion and $f,valor);
  $5000..$500f:mappy_latch(direccion and $f);
  $8000..$ffff:; //ROM
end;
end;

function sound_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$3ff:sound_getbyte:=memoria[$4000+direccion];
  $e000..$ffff:sound_getbyte:=mem_snd[direccion];
end;
end;

procedure sound_putbyte(direccion:word;valor:byte);
begin
case direccion of
   $0..$3f:begin
            memoria[$4000+direccion]:=valor;
            namco_snd_0.regs[direccion and $3f]:=valor;
           end;
   $40..$3ff:memoria[$4000+direccion]:=valor;
   $2000..$200f:mappy_latch(direccion and $f);
   $e000..$ffff:; //ROM
end;
end;

procedure mappy_sound_update;
begin
  namco_snd_0.update;
end;

//Super Pacman
procedure spacman_putbyte(direccion:word;valor:byte);
begin
case direccion of
  $0..$7ff:if memoria[direccion]<>valor then begin
              gfx[0].buffer[direccion and $3ff]:=true;
              memoria[direccion]:=valor;
           end;
  $800..$1fff,$4040..$43ff:memoria[direccion]:=valor;
  $4000..$403f:begin
                  namco_snd_0.regs[direccion and $3f]:=valor;
                  memoria[direccion]:=valor;
               end;
  $4800..$480f:namco_5x_0.write(direccion and $f,valor);
  $4810..$481f:namco_5x_1.write(direccion and $f,valor);
  $5000..$500f:mappy_latch(direccion and $f);
  $a000..$ffff:;  //ROM
end;
end;

//Funciones IO Chips
function inport0_0:byte;
begin
  inport0_0:=marcade.in1 shr 4;  //coins
end;

function inport0_1:byte;
begin
  inport0_1:=marcade.in0 and $f; //p1
end;

function inport0_2:byte;
begin
  inport0_2:=marcade.in0 shr 4; //p2
end;

function inport0_3:byte;
begin
inport0_3:=marcade.in1 and $f; //buttons
end;

function inport1_0:byte;
begin
inport1_0:=(marcade.dswb shr mux) and $f;  //dib_mux
end;

function inport1_1:byte;
begin
inport1_1:=marcade.dswa and $f; //dip a_l
end;

function inport1_2:byte;
begin
inport1_2:=marcade.dswa shr 4; //dip a_h
end;

function inport1_3:byte;
begin
inport1_3:=marcade.in2 or marcade.dswc; //dsw0 + extra but
end;

procedure outport1_0(data:byte);
begin
mux:=(data and $1)*4;
end;

//Main
procedure reset_mappyhw;
begin
 m6809_0.reset;
 m6809_1.reset;
 namco_snd_0.reset;
 namco_5x_0.reset;
 namco_5x_1.reset;
 reset_audio;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$3;
 mux:=0;
 main_int:=false;
 snd_int:=false;
 scroll_x:=0;
end;

function iniciar_mappyhw:boolean;
const
    pc_x:array[0..7] of dword=(8*8+0, 8*8+1, 8*8+2, 8*8+3, 0, 1, 2, 3);
    ps_x:array[0..15] of dword=(0, 1, 2, 3, 8*8, 8*8+1, 8*8+2, 8*8+3, 16*8+0, 16*8+1, 16*8+2, 16*8+3,
                          			24*8+0, 24*8+1, 24*8+2, 24*8+3);
    ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
                          			32*8, 33*8, 34*8, 35*8, 36*8, 37*8, 38*8, 39*8 );
var
  memoria_temp:array[0..$ffff] of byte;

procedure set_chars(inv:boolean);
var
  f:word;
begin
  if inv then for f:=0 to $fff do memoria_temp[f]:=not(memoria_temp[f]);
  init_gfx(0,8,8,$100);
  gfx_set_desc_data(2,0,16*8,0,4);
  convert_gfx(0,0,@memoria_temp,@pc_x,@ps_y,true,false);
end;

procedure set_sprites(num,tipo:byte);
begin
  init_gfx(1,16,16,$80*num);
  case tipo of
    0:gfx_set_desc_data(4,0,64*8,0,4,8192*8*num,(8192*8*num)+4);
    1:gfx_set_desc_data(2,0,64*8,0,4);
  end;
  convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,true,false);
end;

procedure set_color_lookup(tipo:byte;long_sprites:word);
var
  f:word;
  colores:tpaleta;
  ctemp1:byte;
begin
  for f:=0 to 31 do begin
    ctemp1:=memoria_temp[f];
    colores[f].r:= $21*(ctemp1 and 1)+$47*((ctemp1 shr 1) and 1)+$97*((ctemp1 shr 2) and 1);
    colores[f].g:= $21*((ctemp1 shr 3) and 1)+$47*((ctemp1 shr 4) and 1)+$97*((ctemp1 shr 5) and 1);
    colores[f].b:= 0+$47*((ctemp1 shr 6) and 1)+$97*((ctemp1 shr 7) and 1);
  end;
  set_pal(colores,32);
  case tipo of
    0:for f:=0 to 255 do gfx[0].colores[f]:=(memoria_temp[f+$20] and $0f)+$10;
    1:for f:=0 to 255 do gfx[0].colores[f]:=((memoria_temp[f+$20] and $0f) xor $f)+$10;
  end;
  for f:=0 to (long_sprites-1) do gfx[1].colores[f]:=(memoria_temp[f+$120] and $0f);
end;
begin
llamadas_maquina.bucle_general:=mappy_principal;
llamadas_maquina.reset:=reset_mappyhw;
llamadas_maquina.fps_max:=60.6060606060;
iniciar_mappyhw:=false;
iniciar_audio(false);
//Pantallas
screen_init(1,512,288);
screen_mod_scroll(1,512,256,511,256,256,255);
screen_init(2,512,288,true);
screen_mod_scroll(2,512,256,511,256,256,255);
screen_init(3,512,512,false,true);
screen_mod_sprites(3,256,512,255,511);
iniciar_video(224,288);
//Main CPU
m6809_0:=cpu_m6809.Create(1536000,264,TCPU_M6809);
//Sound CPU
m6809_1:=cpu_m6809.create(1536000,264,TCPU_M6809);
m6809_1.change_ram_calls(sound_getbyte,sound_putbyte);
m6809_1.init_sound(mappy_sound_update);
namco_snd_0:=namco_snd_chip.create(8);
case  main_vars.tipo_maquina of
  57:begin //Mappy
      m6809_0.change_ram_calls(mappy_getbyte,mappy_putbyte);
      update_video_proc:=update_video_mappy;
      //IO Chips
      namco_5x_0:=namco_5x_chip.create(m6809_0.numero_cpu,NAMCO_58XX);
      namco_5x_1:=namco_5x_chip.create(m6809_0.numero_cpu,NAMCO_58XX);
      //cargar roms
      if not(roms_load(@memoria,mappy_rom)) then exit;
      //Cargar Sound+samples
      if not(roms_load(@mem_snd,mappy_sound)) then exit;
      if not(roms_load(namco_snd_0.get_wave_dir,mappy_sound_prom)) then exit;
      //convertir chars
      if not(roms_load(@memoria_temp,mappy_chars)) then exit;
      set_chars(true);
      //Sprites
      if not(roms_load(@memoria_temp,mappy_sprites)) then exit;
      set_sprites(1,0);
      sprite_mask:=$7f;
      //Color lookup
      if not(roms_load(@memoria_temp,mappy_proms)) then exit;
      set_color_lookup(0,$100);
      //Dip
      marcade.dswa_val:=@mappy_dip_a;
      marcade.dswb_val:=@mappy_dip_b;
      marcade.dswa:=$ff;
      marcade.dswb:=$ff;
  end;
  63:begin //Dig-Dug 2
      m6809_0.change_ram_calls(mappy_getbyte,mappy_putbyte);
      update_video_proc:=update_video_mappy;
      //IO Chips
      namco_5x_0:=namco_5x_chip.create(m6809_0.numero_cpu,NAMCO_58XX);
      namco_5x_1:=namco_5x_chip.create(m6809_0.numero_cpu,NAMCO_56XX);
      //cargar roms
      if not(roms_load(@memoria,dd2_rom)) then exit;
      //Cargar Sound+samples
      if not(roms_load(@mem_snd,dd2_sound)) then exit;
      if not(roms_load(namco_snd_0.get_wave_dir,dd2_sound_prom)) then exit;
      //convertir chars
      if not(roms_load(@memoria_temp,dd2_chars)) then exit;
      set_chars(true);
      //Sprites
      if not(roms_load(@memoria_temp,dd2_sprites)) then exit;
      set_sprites(2,0);
      sprite_mask:=$ff;
      //Color lookup
      if not(roms_load(@memoria_temp,dd2_proms)) then exit;
      set_color_lookup(0,$100);
      //Dip
      marcade.dswa_val:=@digdug2_dip;
      marcade.dswa:=$ff;
      marcade.dswb:=$ff;
  end;
  64:begin //Super Pacman
      m6809_0.change_ram_calls(mappy_getbyte,spacman_putbyte);
      update_video_proc:=update_video_spacman;
      //IO Chips
      namco_5x_0:=namco_5x_chip.create(m6809_0.numero_cpu,NAMCO_56XX);
      namco_5x_1:=namco_5x_chip.create(m6809_0.numero_cpu,NAMCO_56XX);
      //cargar roms
      if not(roms_load(@memoria,spacman_rom)) then exit;
      //Cargar Sound+samples
      if not(roms_load(@mem_snd,spacman_sound)) then exit;
      if not(roms_load(namco_snd_0.get_wave_dir,spacman_sound_prom)) then exit;
      //convertir chars
      if not(roms_load(@memoria_temp,spacman_chars)) then exit;
      set_chars(false);
      //Sprites
      if not(roms_load(@memoria_temp,spacman_sprites)) then exit;
      set_sprites(1,1);
      sprite_mask:=$7f;
      //Color lookup
      if not(roms_load(@memoria_temp,spacman_proms)) then exit;
      set_color_lookup(1,$100);
      //Dip
      marcade.dswa_val:=@spacman_dip_a;
      marcade.dswb_val:=@spacman_dip_b;
      marcade.dswa:=$ff;
      marcade.dswb:=$ff;
  end;
  192:begin //The Tower of Druaga
      m6809_0.change_ram_calls(mappy_getbyte,mappy_putbyte);
      update_video_proc:=update_video_mappy;
      //IO Chips
      namco_5x_0:=namco_5x_chip.create(m6809_0.numero_cpu,NAMCO_58XX);
      namco_5x_1:=namco_5x_chip.create(m6809_0.numero_cpu,NAMCO_56XX);
      //cargar roms
      if not(roms_load(@memoria,todruaga_rom)) then exit;
      //Cargar Sound+samples
      if not(roms_load(@mem_snd,todruaga_sound)) then exit;
      if not(roms_load(namco_snd_0.get_wave_dir,todruaga_sound_prom)) then exit;
      //convertir chars
      if not(roms_load(@memoria_temp,todruaga_chars)) then exit;
      set_chars(true);
      //Sprites
      if not(roms_load(@memoria_temp,todruaga_sprites)) then exit;
      set_sprites(1,0);
      sprite_mask:=$7f;
      //Color lookup
      if not(roms_load(@memoria_temp,todruaga_proms)) then exit;
      set_color_lookup(0,$400);
      //Dip
      marcade.dswa_val:=@todruaga_dip;
      marcade.dswa:=$ff;
      marcade.dswb:=$ff;
  end;
  193:begin //Motos
      m6809_0.change_ram_calls(mappy_getbyte,mappy_putbyte);
      update_video_proc:=update_video_mappy;
      //IO Chips
      namco_5x_0:=namco_5x_chip.create(m6809_0.numero_cpu,NAMCO_56XX);
      namco_5x_1:=namco_5x_chip.create(m6809_0.numero_cpu,NAMCO_56XX);
      //cargar roms
      if not(roms_load(@memoria,motos_rom)) then exit;
      //Cargar Sound+samples
      if not(roms_load(@mem_snd,motos_sound)) then exit;
      if not(roms_load(namco_snd_0.get_wave_dir,motos_sound_prom)) then exit;
      //convertir chars
      if not(roms_load(@memoria_temp,motos_chars)) then exit;
      set_chars(true);
      //Sprites
      if not(roms_load(@memoria_temp,motos_sprites)) then exit;
      set_sprites(2,0);
      sprite_mask:=$ff;
      //Color lookup
      if not(roms_load(@memoria_temp,motos_proms)) then exit;
      set_color_lookup(0,$100);
      //Dip
      marcade.dswa_val:=@motos_dip;
      marcade.dswa:=$ff;
      marcade.dswb:=$ff;
  end;
  351:begin //Grobda
      m6809_0.change_ram_calls(mappy_getbyte,spacman_putbyte);
      update_video_proc:=update_video_spacman;
      //IO Chips
      namco_5x_0:=namco_5x_chip.create(m6809_0.numero_cpu,NAMCO_58XX);
      namco_5x_1:=namco_5x_chip.create(m6809_0.numero_cpu,NAMCO_56XX);
      //cargar roms
      if not(roms_load(@memoria,grobda_rom)) then exit;
      //Cargar Sound+samples
      if not(roms_load(@mem_snd,grobda_sound)) then exit;
      if not(roms_load(namco_snd_0.get_wave_dir,grobda_sound_prom)) then exit;
      //convertir chars
      if not(roms_load(@memoria_temp,grobda_chars)) then exit;
      set_chars(false);
      //Sprites
      if not(roms_load(@memoria_temp,grobda_sprites)) then exit;
      set_sprites(2,1);
      sprite_mask:=$ff;
      //Color lookup
      if not(roms_load(@memoria_temp,grobda_proms)) then exit;
      set_color_lookup(1,$100);
      //Dip
      marcade.dswa_val:=@grobda_dip_a;
      marcade.dswb_val:=@grobda_dip_b;
      marcade.dswa:=$c9;
      marcade.dswb:=$ff;
  end;
  352:begin //Pac & Pal
      m6809_0.change_ram_calls(mappy_getbyte,spacman_putbyte);
      update_video_proc:=update_video_spacman;
      //IO Chips
      namco_5x_0:=namco_5x_chip.create(m6809_0.numero_cpu,NAMCO_56XX);
      namco_5x_1:=namco_5x_chip.create(m6809_0.numero_cpu,NAMCO_59XX);
      //cargar roms
      if not(roms_load(@memoria,pacnpal_rom)) then exit;
      //Cargar Sound+samples
      if not(roms_load(@mem_snd,pacnpal_sound)) then exit;
      if not(roms_load(namco_snd_0.get_wave_dir,pacnpal_sound_prom)) then exit;
      //convertir chars
      if not(roms_load(@memoria_temp,pacnpal_chars)) then exit;
      set_chars(false);
      //Sprites
      if not(roms_load(@memoria_temp,pacnpal_sprites)) then exit;
      set_sprites(1,1);
      sprite_mask:=$7f;
      //Color lookup
      if not(roms_load(@memoria_temp,pacnpal_proms)) then exit;
      set_color_lookup(1,$100);
      //Dip
      marcade.dswa_val:=@pacnpal_dip_a;
      marcade.dswb_val:=@pacnpal_dip_b;
      marcade.dswa:=$77;
      marcade.dswb:=$ff;
  end;
end;
//Dip comun
marcade.dswc_val:=@mappy_dip_c;
marcade.dswc:=$c;
//IOs final
namco_5x_0.change_io(inport0_0,inport0_1,inport0_2,inport0_3,nil,nil);
namco_5x_1.change_io(inport1_0,inport1_1,inport1_2,inport1_3,outport1_0,nil);
reset_mappyhw;
iniciar_mappyhw:=true;
end;

end.
