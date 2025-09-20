unit system1_hw_misc;

interface
uses main_engine,gfx_engine,nz80,sn_76496,controls_engine,sega_decrypt,
     z80pio,ppi8255,rom_engine,pal_engine,sound_engine,timer_engine;

function iniciar_system1:boolean;
procedure system1_principal;
procedure cambiar_color_system1(valor:byte;pos:word);

implementation
uses system1_hw;

const
    //Pitfall 2
    pitfall2_rom:array[0..2] of tipo_roms=(
    (n:'epr6456a.116';l:$4000;p:0;crc:$bcc8406b),(n:'epr6457a.109';l:$4000;p:$4000;crc:$a016fd2a),
    (n:'epr6458a.96';l:$4000;p:$8000;crc:$5c30b3e8));
    pitfall2_char:array[0..5] of tipo_roms=(
    (n:'epr6474a.62';l:$2000;p:0;crc:$9f1711b9),(n:'epr6473a.61';l:$2000;p:$2000;crc:$8e53b8dd),
    (n:'epr6472a.64';l:$2000;p:$4000;crc:$e0f34a11),(n:'epr6471a.63';l:$2000;p:$6000;crc:$d5bc805c),
    (n:'epr6470a.66';l:$2000;p:$8000;crc:$1439729f),(n:'epr6469a.65';l:$2000;p:$a000;crc:$e4ac6921));
    pitfall2_sound:tipo_roms=(n:'epr-6462.120';l:$2000;p:0;crc:$86bb9185);
    pitfall2_sprites:array[0..1] of tipo_roms=(
    (n:'epr6454a.117';l:$4000;p:0;crc:$a5d96780),(n:'epr-6455.05';l:$4000;p:$4000;crc:$32ee64a1));
    pitfall2_video_prom:tipo_roms=(n:'pr-5317.76';l:$100;p:0;crc:$648350b8);
    pitfall2_dip_b:array [0..6] of def_dip=(
    (mask:$1;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$1;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$2;name:'Demo Sounds';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$c;name:'Lives';number:4;dip:((dip_val:$c;dip_name:'3'),(dip_val:$8;dip_name:'4'),(dip_val:$4;dip_name:'5'),(dip_val:$0;dip_name:'Infinite'),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$10;name:'Bonus Life';number:2;dip:((dip_val:$10;dip_name:'20K 50K'),(dip_val:$0;dip_name:'30K 70K'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$20;name:'Allow Continue';number:2;dip:((dip_val:$20;dip_name:'No'),(dip_val:$0;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$40;name:'Time';number:2;dip:((dip_val:$0;dip_name:'2 Minutes'),(dip_val:$40;dip_name:'3 Minutes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
    //Teddy Boy Blues
    teddy_rom:array[0..2] of tipo_roms=(
    (n:'epr-6768.116';l:$4000;p:0;crc:$5939817e),(n:'epr-6769.109';l:$4000;p:$4000;crc:$14a98ddd),
    (n:'epr-6770.96';l:$4000;p:$8000;crc:$67b0c7c2));
    teddy_char:array[0..5] of tipo_roms=(
    (n:'epr-6747.62';l:$2000;p:0;crc:$a0e5aca7),(n:'epr-6746.61';l:$2000;p:$2000;crc:$cdb77e51),
    (n:'epr-6745.64';l:$2000;p:$4000;crc:$0cab75c3),(n:'epr-6744.63';l:$2000;p:$6000;crc:$0ef8d2cd),
    (n:'epr-6743.66';l:$2000;p:$8000;crc:$c33062b5),(n:'epr-6742.65';l:$2000;p:$a000;crc:$c457e8c5));
    teddy_sound:tipo_roms=(n:'epr6748x.120';l:$2000;p:0;crc:$c2a1b89d);
    teddy_sprites:array[0..3] of tipo_roms=(
    (n:'epr-6735.117';l:$4000;p:0;crc:$1be35a97),(n:'epr-6737.04';l:$4000;p:$4000;crc:$6b53aa7a),
    (n:'epr-6736.110';l:$4000;p:$8000;crc:$565c25d0),(n:'epr-6738.05';l:$4000;p:$c000;crc:$e116285f));
    teddy_video_prom:tipo_roms=(n:'pr-5317.76';l:$100;p:0;crc:$648350b8);
    teddy_dip_b:array [0..5] of def_dip=(
    (mask:$1;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$1;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$2;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$2;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$c;name:'Lives';number:4;dip:((dip_val:$8;dip_name:'2'),(dip_val:$c;dip_name:'3'),(dip_val:$4;dip_name:'4'),(dip_val:$0;dip_name:'252'),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$30;name:'Bonus Life';number:4;dip:((dip_val:$30;dip_name:'100K 400K'),(dip_val:$20;dip_name:'200K 600K'),(dip_val:$10;dip_name:'400K 800K'),(dip_val:$0;dip_name:'600K'),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$40;name:'Difficulty';number:2;dip:((dip_val:$40;dip_name:'Easy'),(dip_val:$0;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
    //Wonder Boy
    wboy_rom:array[0..2] of tipo_roms=(
    (n:'epr-7489.116';l:$4000;p:0;crc:$130f4b70),(n:'epr-7490.109';l:$4000;p:$4000;crc:$9e656733),
    (n:'epr-7491.96';l:$4000;p:$8000;crc:$1f7d0efe));
    wboy_char:array[0..5] of tipo_roms=(
    (n:'epr-7497.62';l:$2000;p:0;crc:$08d609ca),(n:'epr-7496.61';l:$2000;p:$2000;crc:$6f61fdf1),
    (n:'epr-7495.64';l:$2000;p:$4000;crc:$6a0d2c2d),(n:'epr-7494.63';l:$2000;p:$6000;crc:$a8e281c7),
    (n:'epr-7493.66';l:$2000;p:$8000;crc:$89305df4),(n:'epr-7492.65';l:$2000;p:$a000;crc:$60f806b1));
    wboy_sound:tipo_roms=(n:'epr-7498.120';l:$2000;p:0;crc:$78ae1e7b);
    wboy_sprites:array[0..3] of tipo_roms=(
    (n:'epr-7485.117';l:$4000;p:0;crc:$c2891722),(n:'epr-7487.04';l:$4000;p:$4000;crc:$2d3a421b),
    (n:'epr-7486.110';l:$4000;p:$8000;crc:$8d622c50),(n:'epr-7488.05';l:$4000;p:$c000;crc:$007c2f1b));
    wboy_video_prom:tipo_roms=(n:'pr-5317.76';l:$100;p:0;crc:$648350b8);
    wboy_dip_b:array [0..6] of def_dip=(
    (mask:$1;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$1;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$2;name:'Demo Sounds';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$c;name:'Lives';number:4;dip:((dip_val:$c;dip_name:'3'),(dip_val:$8;dip_name:'4'),(dip_val:$4;dip_name:'5'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$10;name:'Bonus Life';number:2;dip:((dip_val:$10;dip_name:'30K 100K 170K 240K'),(dip_val:$0;dip_name:'30K 120K 210K 300K'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$20;name:'Allow Continue';number:2;dip:((dip_val:$0;dip_name:'No'),(dip_val:$20;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$40;name:'Difficulty';number:2;dip:((dip_val:$40;dip_name:'Easy'),(dip_val:$0;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
    //Mr Viking
    mrviking_rom:array[0..5] of tipo_roms=(
    (n:'epr-5873.129';l:$2000;p:0;crc:$14d21624),(n:'epr-5874.130';l:$2000;p:$2000;crc:$6df7de87),
    (n:'epr-5875.131';l:$2000;p:$4000;crc:$ac226100),(n:'epr-5876.132';l:$2000;p:$6000;crc:$e77db1dc),
    (n:'epr-5755.133';l:$2000;p:$8000;crc:$edd62ae1),(n:'epr-5756.134';l:$2000;p:$a000;crc:$11974040));
    mrviking_sprites:array[0..1] of tipo_roms=(
    (n:'epr-5749.86';l:$4000;p:$0;crc:$e24682cd),(n:'epr-5750.93';l:$4000;p:$4000;crc:$6564d1ad));
    mrviking_sound:tipo_roms=(n:'epr-5763.3';l:$2000;p:0;crc:$d712280d);
    mrviking_char:array[0..5] of tipo_roms=(
    (n:'epr-5762.82';l:$2000;p:0;crc:$4a91d08a),(n:'epr-5761.65';l:$2000;p:$2000;crc:$f7d61b65),
    (n:'epr-5760.81';l:$2000;p:$4000;crc:$95045820),(n:'epr-5759.64';l:$2000;p:$6000;crc:$5f9bae4e),
    (n:'epr-5758.80';l:$2000;p:$8000;crc:$808ee706),(n:'epr-5757.63';l:$2000;p:$a000;crc:$480f7074));
    mrviking_video_prom:tipo_roms=(n:'pr-5317.106';l:$100;p:0;crc:$648350b8);
    mrviking_dip_b:array [0..5] of def_dip=(
    (mask:$1;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$1;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$2;name:'Maximum Credits';number:2;dip:((dip_val:$2;dip_name:'9'),(dip_val:$0;dip_name:'99'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$c;name:'Lives';number:4;dip:((dip_val:$c;dip_name:'3'),(dip_val:$8;dip_name:'4'),(dip_val:$4;dip_name:'5'),(dip_val:$0;dip_name:'Infinite'),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$30;name:'Bonus Life';number:4;dip:((dip_val:$30;dip_name:'10K 30K 30K+'),(dip_val:$20;dip_name:'20K 40K 30K+'),(dip_val:$10;dip_name:'30K 30K+'),(dip_val:$0;dip_name:'40K 30K+'),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$40;name:'Difficulty';number:2;dip:((dip_val:$40;dip_name:'Easy'),(dip_val:$0;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
    //Sega Ninja
    seganinj_rom:array[0..2] of tipo_roms=(
    (n:'epr-.116';l:$4000;p:0;crc:$a5d0c9d0),(n:'epr-.109';l:$4000;p:$4000;crc:$b9e6775c),
    (n:'epr-6552.96';l:$4000;p:$8000;crc:$f2eeb0d8));
    seganinj_sprites:array[0..3] of tipo_roms=(
    (n:'epr-6546.117';l:$4000;p:$0;crc:$a4785692),(n:'epr-6548.04';l:$4000;p:$4000;crc:$bdf278c1),
    (n:'epr-6547.110';l:$4000;p:$8000;crc:$34451b08),(n:'epr-6549.05';l:$4000;p:$c000;crc:$d2057668));
    seganinj_sound:tipo_roms=(n:'epr-6559.120';l:$2000;p:0;crc:$5a1570ee);
    seganinj_char:array[0..5] of tipo_roms=(
    (n:'epr-6558.62';l:$2000;p:0;crc:$2af9eaeb),(n:'epr-6592.61';l:$2000;p:$2000;crc:$7804db86),
    (n:'epr-6556.64';l:$2000;p:$4000;crc:$79fd26f7),(n:'epr-6590.63';l:$2000;p:$6000;crc:$bf858cad),
    (n:'epr-6554.66';l:$2000;p:$8000;crc:$5ac9d205),(n:'epr-6588.65';l:$2000;p:$a000;crc:$dc931dbb));
    seganinj_video_prom:tipo_roms=(n:'pr-5317.76';l:$100;p:0;crc:$648350b8);
    seganinj_dip_b:array [0..6] of def_dip=(
    (mask:$1;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$1;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$2;name:'Demo Sounds';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$c;name:'Lives';number:4;dip:((dip_val:$8;dip_name:'2'),(dip_val:$c;dip_name:'3'),(dip_val:$4;dip_name:'4'),(dip_val:$0;dip_name:'240'),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$10;name:'Bonus Life';number:2;dip:((dip_val:$10;dip_name:'20K 70K 120K 170K'),(dip_val:$0;dip_name:'50K 100K 150K 200K'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$20;name:'Allow Continue';number:2;dip:((dip_val:$20;dip_name:'No'),(dip_val:$0;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$40;name:'Difficulty';number:2;dip:((dip_val:$40;dip_name:'Easy'),(dip_val:$0;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
    //Up and Down
    upndown_rom:array[0..5] of tipo_roms=(
    (n:'epr5516a.129';l:$2000;p:0;crc:$038c82da),(n:'epr5517a.130';l:$2000;p:$2000;crc:$6930e1de),
    (n:'epr-5518.131';l:$2000;p:$4000;crc:$2a370c99),(n:'epr-5519.132';l:$2000;p:$6000;crc:$9d664a58),
    (n:'epr-5520.133';l:$2000;p:$8000;crc:$208dfbdf),(n:'epr-5521.134';l:$2000;p:$a000;crc:$e7b8d87a));
    upndown_sprites:array[0..1] of tipo_roms=(
    (n:'epr-5514.86';l:$4000;p:$0;crc:$fcc0a88b),(n:'epr-5515.93';l:$4000;p:$4000;crc:$60908838));
    upndown_sound:tipo_roms=(n:'epr-5535.3';l:$2000;p:0;crc:$cf4e4c45);
    upndown_char:array[0..5] of tipo_roms=(
    (n:'epr-5527.82';l:$2000;p:0;crc:$b2d616f1),(n:'epr-5526.65';l:$2000;p:$2000;crc:$8a8b33c2),
    (n:'epr-5525.81';l:$2000;p:$4000;crc:$e749c5ef),(n:'epr-5524.64';l:$2000;p:$6000;crc:$8b886952),
    (n:'epr-5523.80';l:$2000;p:$8000;crc:$dede35d9),(n:'epr-5522.63';l:$2000;p:$a000;crc:$5e6d9dff));
    upndown_video_prom:tipo_roms=(n:'pr-5317.106';l:$100;p:0;crc:$648350b8);
    upndown_dip_b:array [0..4] of def_dip=(
    (mask:$1;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$1;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$6;name:'Lives';number:4;dip:((dip_val:$6;dip_name:'3'),(dip_val:$4;dip_name:'4'),(dip_val:$2;dip_name:'5'),(dip_val:$0;dip_name:'Infinite'),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$38;name:'Bonus Life';number:8;dip:((dip_val:$38;dip_name:'10K'),(dip_val:$30;dip_name:'20K'),(dip_val:$28;dip_name:'30K'),(dip_val:$20;dip_name:'40K'),(dip_val:$18;dip_name:'50K'),(dip_val:$10;dip_name:'60K'),(dip_val:$8;dip_name:'70K'),(dip_val:$0;dip_name:'None'),(),(),(),(),(),(),(),())),
    (mask:$c0;name:'Difficulty';number:4;dip:((dip_val:$c0;dip_name:'Easy'),(dip_val:$80;dip_name:'Medium'),(dip_val:$40;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),());
    //Flicky
    flicky_rom:array[0..1] of tipo_roms=(
    (n:'epr5978a.116';l:$4000;p:0;crc:$296f1492),(n:'epr5979a.109';l:$4000;p:$4000;crc:$64b03ef9));
    flicky_sprites:array[0..1] of tipo_roms=(
    (n:'epr-5855.117';l:$4000;p:$0;crc:$b5f894a1),(n:'epr-5856.110';l:$4000;p:$4000;crc:$266af78f));
    flicky_sound:tipo_roms=(n:'epr-5869.120';l:$2000;p:0;crc:$6d220d4e);
    flicky_char:array[0..5] of tipo_roms=(
    (n:'epr-5868.62';l:$2000;p:0;crc:$7402256b),(n:'epr-5867.61';l:$2000;p:$2000;crc:$2f5ce930),
    (n:'epr-5866.64';l:$2000;p:$4000;crc:$967f1d9a),(n:'epr-5865.63';l:$2000;p:$6000;crc:$03d9a34c),
    (n:'epr-5864.66';l:$2000;p:$8000;crc:$e659f358),(n:'epr-5863.65';l:$2000;p:$a000;crc:$a496ca15));
    flicky_video_prom:tipo_roms=(n:'pr-5317.76';l:$100;p:0;crc:$648350b8);
    flicky_dip_b:array [0..4] of def_dip=(
    (mask:$1;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$1;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$c;name:'Lives';number:4;dip:((dip_val:$c;dip_name:'3'),(dip_val:$8;dip_name:'4'),(dip_val:$4;dip_name:'5'),(dip_val:$0;dip_name:'Infinite'),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$30;name:'Bonus Life';number:4;dip:((dip_val:$30;dip_name:'30K 80K 160K'),(dip_val:$20;dip_name:'30K 100K 200K'),(dip_val:$10;dip_name:'40K 120K 240K'),(dip_val:$0;dip_name:'40K 140K 280K'),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$40;name:'Difficulty';number:2;dip:((dip_val:$40;dip_name:'Easy'),(dip_val:$0;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

procedure decodifica_wonder_boy;
const
  //Wonder Boy
    opcode_xor:array[0..63] of byte=(
		$04,$51,$40,$01,$55,$44,$05,$50,$41,$00,$54,$45,
		$04,$51,$40,$01,$55,$44,$05,$50,$41,$00,$54,$45,
		$04,$51,$40,$01,$55,$44,$05,$50,
		$04,$51,$40,$01,$55,$44,$05,$50,$41,$00,$54,$45,
		$04,$51,$40,$01,$55,$44,$05,$50,$41,$00,$54,$45,
		$04,$51,$40,$01,$55,$44,$05,$50);
	  data_xor:array[0..63] of byte=(
		$54,$15,$44,$51,$10,$41,$55,$14,$45,$50,$11,$40,
		$54,$15,$44,$51,$10,$41,$55,$14,$45,$50,$11,$40,
		$54,$15,$44,$51,$10,$41,$55,$14,
		$54,$15,$44,$51,$10,$41,$55,$14,$45,$50,$11,$40,
		$54,$15,$44,$51,$10,$41,$55,$14,$45,$50,$11,$40,
		$54,$15,$44,$51,$10,$41,$55,$14);
	  opcode_swap_select:array[0..63] of byte=(
		0,0,1,1,1,2,2,3,3,4,4,4,5,5,6,6,
		6,7,7,8,8,9,9,9,10,10,11,11,11,12,12,13,
		8,8,9,9,9,10,10,11,11,12,12,12,13,13,14,14,
		14,15,15,16,16,17,17,17,18,18,19,19,19,20,20,21);
	  data_swap_select:array[0..63] of byte=(
		0,0,1,1,2,2,2,3,3,4,4,5,5,5,6,6,
		7,7,7,8,8,9,9,10,10,10,11,11,12,12,12,13,
		8,8,9,9,10,10,10,11,11,12,12,13,13,13,14,14,
		15,15,15,16,16,17,17,18,18,18,19,19,20,20,20,21);
    swaptable:array[0..23,0..3] of byte=(
		  ( 6,4,2,0 ), ( 4,6,2,0 ), ( 2,4,6,0 ), ( 0,4,2,6 ),
		  ( 6,2,4,0 ), ( 6,0,2,4 ), ( 6,4,0,2 ), ( 2,6,4,0 ),
		  ( 4,2,6,0 ), ( 4,6,0,2 ), ( 6,0,4,2 ), ( 0,6,4,2 ),
		  ( 4,0,6,2 ), ( 0,4,6,2 ), ( 6,2,0,4 ), ( 2,6,0,4 ),
		  ( 0,6,2,4 ), ( 2,0,6,4 ), ( 0,2,6,4 ), ( 4,2,0,6 ),
		  ( 2,4,0,6 ), ( 4,0,2,6 ), ( 2,0,4,6 ), ( 0,2,4,6 ));
var
  a:word;
  row,src,tbl0,tbl1,tbl2,tbl3:byte;
begin
    for a:=0 to $7fff do begin
		  src:=memoria[a];
		  // pick the translation table from bits 0, 3, 6, 9, 12 and 14 of the address */
		  row:= (a and 1) + (((a shr 3) and 1) shl 1) + (((a shr 6) and 1) shl 2)
				+ (((a shr 9) and 1) shl 3) + (((a shr 12) and 1) shl 4) + (((a shr 14) and 1) shl 5);
		  // decode the opcodes */
      tbl0:=swaptable[opcode_swap_select[row]][0];
      tbl1:=swaptable[opcode_swap_select[row]][1];
      tbl2:=swaptable[opcode_swap_select[row]][2];
      tbl3:=swaptable[opcode_swap_select[row]][3];
		  mem_dec[a]:=((src and $aa) or (((src shr tbl0) and 1) shl 6) or (((src shr tbl1) and 1) shl 4) or (((src shr tbl2) and 1) shl 2) or (((src shr tbl3) and 1) shl 0)) xor opcode_xor[row];
		  // decode the data */
      tbl0:=swaptable[data_swap_select[row]][0];
      tbl1:=swaptable[data_swap_select[row]][1];
      tbl2:=swaptable[data_swap_select[row]][2];
      tbl3:=swaptable[data_swap_select[row]][3];
		  memoria[a]:=((src and $aa) or (((src shr tbl0) and 1) shl 6) or (((src shr tbl1) and 1) shl 4) or (((src shr tbl2) and 1) shl 2) or (((src shr tbl3) and 1) shl 0)) xor data_xor[row];
    end;
end;

procedure update_video;
var
  x_temp:word;
begin
update_backgroud(0);
update_backgroud(1);
x_temp:=(bg_ram[$ffc]+(bg_ram[$ffd] shl 8)) div 2+14;
fillword(@xscroll[0],32,x_temp);
yscroll:=bg_ram[$fbd];
update_video_system1;
end;

procedure system1_principal;
var
  f:word;
  frame_m,frame_s:single;
begin
init_controls(false,false,false,true);
frame_m:=z80_0.tframes;
frame_s:=z80_1.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to 259 do begin
    //Main CPU
    z80_0.run(frame_m);
    frame_m:=frame_m+z80_0.tframes-z80_0.contador;
    //Sound CPU
    z80_1.run(frame_s);
    frame_s:=frame_s+z80_1.tframes-z80_1.contador;
    if f=223 then begin
      z80_0.change_irq(HOLD_LINE);
      update_video;
      eventos_system1;
    end;
  end;
  video_sync;
end;
end;

function system1_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$7fff:if z80_0.opcode then system1_getbyte:=mem_dec[direccion]
              else system1_getbyte:=memoria[direccion];
  $8000..$d7ff,$de00..$dfff:system1_getbyte:=memoria[direccion];
  $d800..$ddff:system1_getbyte:=buffer_paleta[direccion and $7ff];
  $e000..$efff:system1_getbyte:=bg_ram[direccion and $fff];
  $f000..$f3ff:system1_getbyte:=mix_collide[direccion and $3f] or $7e or (mix_collide_summary shl 7);
  $f800..$fbff:system1_getbyte:=sprite_collide[direccion and $3ff] or $7e or (sprite_collide_summary shl 7);
end;
end;

procedure cambiar_color_system1(valor:byte;pos:word);
var
  color:tcolor;
begin
  color.r:=pal3bit(valor shr 0);
  color.g:=pal3bit(valor shr 3);
	color.b:=pal2bit(valor shr 6);
  set_pal_color(color,pos);
end;

procedure system1_putbyte(direccion:word;valor:byte);
var
  pos_bg:word;
begin
case direccion of
        0..$bfff:;
        $c000..$d7ff,$de00..$dfff:memoria[direccion]:=valor;
        $d800..$ddff:if buffer_paleta[direccion and $7ff]<>valor then begin
                        cambiar_color_system1(valor,direccion and $7ff);
                        buffer_paleta[direccion and $7ff]:=valor;
                     end;
        $e000..$efff:begin
                        pos_bg:=direccion and $fff;
                        if bg_ram[pos_bg]<>valor then begin
                          bg_ram[pos_bg]:=valor;
                          bg_ram_w[pos_bg shr 1]:=true;
                        end;
                     end;
        $f000..$f3ff:mix_collide[direccion and $3f]:=0;
        $f400..$f7ff:mix_collide_summary:=0;
        $f800..$fbff:sprite_collide[direccion and $3ff]:=0;
        $fc00..$ffff:sprite_collide_summary:=0;
end;
end;

function system1_snd_getbyte_pio(direccion:word):byte;
begin
case direccion of
  $0000..$7fff:system1_snd_getbyte_pio:=mem_snd[direccion];
  $8000..$9fff:system1_snd_getbyte_pio:=mem_snd[(direccion and $7ff)+$8000];
  $e000..$efff:begin
                  system1_snd_getbyte_pio:=z80pio_port_read(0,PORT_A);
                  z80pio_astb_w(0,false);
                  z80pio_astb_w(0,true);
               end;
end;
end;

function system1_inbyte_pio(puerto:word):byte;
begin
case (puerto and $1f) of
  $0..$3:system1_inbyte_pio:=marcade.in1;
  $4..$7:system1_inbyte_pio:=marcade.in2;
  $8..$b:system1_inbyte_pio:=marcade.in0;
  $c,$e:system1_inbyte_pio:=marcade.dswa;
  $d,$f,$10..$13:system1_inbyte_pio:=marcade.dswb;
  $18..$1b:system1_inbyte_pio:=z80pio_cd_ba_r(0,puerto and $1f);
end;
end;

procedure system1_outbyte_pio(puerto:word;valor:byte);
begin
case (puerto and $1f) of
  $18..$1b:z80pio_cd_ba_w(0,puerto and $1f,valor);
end;
end;

//PIO
procedure system1_pio_porta_write(valor:byte);
begin
  sound_latch:=valor;
end;

procedure system1_pio_porta_nmi(state:boolean);
begin
  z80_1.change_nmi(PULSE_LINE);
end;

procedure system1_pio_portb_write(valor:byte);
begin
  system1_videomode:=valor;
end;

//Main
function iniciar_system1:boolean;
var
  memoria_temp:array[0..$ffff] of byte;
procedure convert_gfx_system1;
begin
  init_gfx(0,8,8,2048);
  gfx_set_desc_data(3,0,8*8,0,$4000*8,$8000*8);
  convert_gfx(0,0,@memoria_temp,@pc_x,@pc_y,false,false);
end;

begin
iniciar_system1:=false;
iniciar_audio(false);
//Pantallas
screen_init(1,256,256,false,true);
case main_vars.tipo_maquina of
  152,154:begin
             main_screen.rot270_screen:=true;
             iniciar_video(240,224);
          end;
  else iniciar_video(256,224);
end;
//Main CPU
//Deberia ser 20Mhz, pero si lo pongo falla PFII
z80_0:=cpu_z80.create(19300000,260);
z80_0.change_ram_calls(system1_getbyte,system1_putbyte);
z80_0.change_timmings(@z80t_a,@z80t_cb_a,@z80t_dd_a,@z80t_ddcb_a,@z80t_ed_a,@z80t_ex_a);
//Sound CPU
z80_1:=cpu_z80.create(4000000,260);
z80_1.init_sound(system1_sound_update);
timers.init(z80_1.numero_cpu,4000000/llamadas_maquina.fps_max/(260/64),system1_sound_irq,nil,true);
//Sound Chip
sn_76496_0:=sn76496_chip.Create(2000000,0.5);
sn_76496_1:=sn76496_chip.Create(4000000);
sprite_num_banks:=1;
case main_vars.tipo_maquina of
  27:begin //Pitfall II
      //cargar roms
      if not(roms_load(@memoria,pitfall2_rom)) then exit;
      decrypt_sega(@memoria,@mem_dec,0); //Sega Decypt
      //cargar sonido
      if not(roms_load(@mem_snd,pitfall2_sound)) then exit;
      //convertir chars
      if not(roms_load(@memoria_temp,pitfall2_char)) then exit;
      convert_gfx_system1;
      //Meter los sprites en memoria
      if not(roms_load(@memoria_sprites,pitfall2_sprites)) then exit;
      //Cargar PROM
      if not(roms_load(@lookup_memory,pitfall2_video_prom)) then exit;
      //dip
      marcade.dswa:=$ff;
      marcade.dswa_val:=@system1_dip_credit;
      marcade.dswb:=$dc;
      marcade.dswb_val:=@pitfall2_dip_b;
     end;
  35:begin  //Teddy Boy Blues
      sprite_num_banks:=2;
      //cargar roms
      if not(roms_load(@memoria,teddy_rom)) then exit;
      decrypt_sega(@memoria,@mem_dec,1); //Sega Decypt
      //cargar sonido
      if not(roms_load(@mem_snd,teddy_sound)) then exit;
      //convertir chars
      if not(roms_load(@memoria_temp,teddy_char)) then exit;
      convert_gfx_system1;
      //Meter los sprites en memoria
      if not(roms_load(@memoria_sprites,teddy_sprites)) then exit;
      //Cargar PROM
      if not(roms_load(@lookup_memory,teddy_video_prom)) then exit;
      //dip
      marcade.dswa:=$ff;
      marcade.dswa_val:=@system1_dip_credit;
      marcade.dswb:=$fe;
      marcade.dswb_val:=@teddy_dip_b;
     end;
  36:begin  //Wonder boy
      sprite_num_banks:=2;
      //cargar roms
      if not(roms_load(@memoria,wboy_rom)) then exit;
      decodifica_wonder_boy;
      //cargar sonido
      if not(roms_load(@mem_snd,wboy_sound)) then exit;
      //convertir chars
      if not(roms_load(@memoria_temp,wboy_char)) then exit;
      convert_gfx_system1;
      //Meter los sprites en memoria
      if not(roms_load(@memoria_sprites,wboy_sprites)) then exit;
      //Cargar PROM
      if not(roms_load(@lookup_memory,wboy_video_prom)) then exit;
      //dip
      marcade.dswa:=$ff;
      marcade.dswa_val:=@system1_dip_credit;
      marcade.dswb:=$ec;
      marcade.dswb_val:=@wboy_dip_b;
     end;
  152:begin  //Mr Viking
      //cargar roms
      if not(roms_load(@memoria,mrviking_rom)) then exit;
      decrypt_sega(@memoria,@mem_dec,3); //Sega Decypt
      //cargar sonido
      if not(roms_load(@mem_snd,mrviking_sound)) then exit;
      //convertir chars
      if not(roms_load(@memoria_temp,mrviking_char)) then exit;
      convert_gfx_system1;
      //Meter los sprites en memoria
      if not(roms_load(@memoria_sprites,mrviking_sprites)) then exit;
      //Cargar PROM
      if not(roms_load(@lookup_memory,mrviking_video_prom)) then exit;
      //dip
      marcade.dswa:=$ff;
      marcade.dswa_val:=@system1_dip_credit;
      marcade.dswb:=$fc;
      marcade.dswb_val:=@mrviking_dip_b;
     end;
  153:begin  //Sega Ninja
      sprite_num_banks:=2;
      //cargar roms
      if not(roms_load(@memoria,seganinj_rom)) then exit;
      decrypt_sega(@memoria,@mem_dec,4); //Sega Decypt
      //cargar sonido
      if not(roms_load(@mem_snd,seganinj_sound)) then exit;
      //convertir chars
      if not(roms_load(@memoria_temp,seganinj_char)) then exit;
      convert_gfx_system1;
      //Meter los sprites en memoria
      if not(roms_load(@memoria_sprites,seganinj_sprites)) then exit;
      //Cargar PROM
      if not(roms_load(@lookup_memory,seganinj_video_prom)) then exit;
      //dip
      marcade.dswa:=$ff;
      marcade.dswa_val:=@system1_dip_credit;
      marcade.dswb:=$dc;
      marcade.dswb_val:=@seganinj_dip_b;
     end;
  154:begin  //Up and Down
      //cargar roms
      if not(roms_load(@memoria,upndown_rom)) then exit;
      decrypt_sega(@memoria,@mem_dec,5); //Sega Decypt
      //cargar sonido
      if not(roms_load(@mem_snd,upndown_sound)) then exit;
      //convertir chars
      if not(roms_load(@memoria_temp,upndown_char)) then exit;
      convert_gfx_system1;
      //Meter los sprites en memoria
      if not(roms_load(@memoria_sprites,upndown_sprites)) then exit;
      //Cargar PROM
      if not(roms_load(@lookup_memory,upndown_video_prom)) then exit;
      //dip
      marcade.dswa:=$ff;
      marcade.dswb_val:=@system1_dip_credit;
      marcade.dswb:=$fe;
      marcade.dswb_val:=@upndown_dip_b;
     end;
  155:begin  //Flicky
      //cargar roms
      if not(roms_load(@memoria,flicky_rom)) then exit;
      decrypt_sega(@memoria,@mem_dec,6); //Sega Decypt
      //cargar sonido
      if not(roms_load(@mem_snd,flicky_sound)) then exit;
      //convertir chars
      if not(roms_load(@memoria_temp,flicky_char)) then exit;
      convert_gfx_system1;
      //Meter los sprites en memoria
      if not(roms_load(@memoria_sprites,flicky_sprites)) then exit;
      //Cargar PROM
      if not(roms_load(@lookup_memory,flicky_video_prom)) then exit;
      //dip
      marcade.dswa:=$ff;
      marcade.dswa_val:=@system1_dip_credit;
      marcade.dswb:=$fe;
      marcade.dswb_val:=@flicky_dip_b;
     end;
end;
case main_vars.tipo_maquina of
  152,154:begin
             //Main CPU
             z80_0.change_io_calls(system1_inbyte_ppi,system1_outbyte_ppi);
             //Sound CPU
             z80_1.change_ram_calls(system1_snd_getbyte_ppi,system1_snd_putbyte);
             //PPI 8255
             pia8255_0:=pia8255_chip.create;
             pia8255_0.change_ports(nil,nil,nil,system1_port_a_write,system1_port_b_write,system1_port_c_write);
          end;
  else begin
    //Main CPU
    z80_0.change_io_calls(system1_inbyte_pio,system1_outbyte_pio);
    //Sound CPU
    z80_1.change_ram_calls(system1_snd_getbyte_pio,system1_snd_putbyte);
    //Z80 PIO
    z80pio_init(0,nil,nil,system1_pio_porta_write,system1_pio_porta_nmi,nil,system1_pio_portb_write,nil);
  end;
end;
char_screen:=1;
sprite_offset:=0;
mask_char:=$7ff;
llamadas_maquina.reset;
iniciar_system1:=true;
end;

end.
