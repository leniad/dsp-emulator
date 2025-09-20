unit system16b_hw;

interface

uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,m68000,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     sound_engine,ym_2151,dialogs,upd7759,mcs51,sega_315_5195;

function iniciar_system16b:boolean;

implementation

const
        //Altered Beast
        altbeast_rom:array[0..1] of tipo_roms=(
        (n:'epr-11907.a7';l:$20000;p:0;crc:$29e0c3ad),(n:'epr-11906.a5';l:$20000;p:$1;crc:$4c9e9cd8));
        altbeast_sound:array[0..2] of tipo_roms=(
        (n:'epr-11671.a10';l:$8000;p:0;crc:$2b71343b),(n:'opr-11672.a11';l:$20000;p:$8000;crc:$bbd7f460),
        (n:'opr-11673.a12';l:$20000;p:$28000;crc:$400c4a36));
        altbeast_mcu:tipo_roms=(n:'317-0078.c2';l:$1000;p:0;crc:$8101925f);
        altbeast_tiles:array[0..2] of tipo_roms=(
        (n:'opr-11674.a14';l:$20000;p:0;crc:$a57a66d5),(n:'opr-11675.a15';l:$20000;p:$20000;crc:$2ef2f144),
        (n:'opr-11676.a16';l:$20000;p:$40000;crc:$0c04acac));
        altbeast_sprites:array[0..7] of tipo_roms=(
        (n:'epr-11677.b1';l:$20000;p:1;crc:$a01425cd),(n:'epr-11681.b5';l:$20000;p:$0;crc:$d9e03363),
        (n:'epr-11678.b2';l:$20000;p:$40001;crc:$17a9fc53),(n:'epr-11682.b6';l:$20000;p:$40000;crc:$e3f77c5e),
        (n:'epr-11679.b3';l:$20000;p:$80001;crc:$14dcc245),(n:'epr-11683.b7';l:$20000;p:$80000;crc:$f9a60f06),
        (n:'epr-11680.b4';l:$20000;p:$c0001;crc:$f43dcdec),(n:'epr-11684.b8';l:$20000;p:$c0000;crc:$b20c0edb));
        //Golden Axe
        goldnaxe_rom:array[0..1] of tipo_roms=(
        (n:'epr-12545.ic2';l:$40000;p:0;crc:$a97c4e4d),(n:'epr-12544.ic1';l:$40000;p:$1;crc:$5e38f668));
        goldnaxe_sound:array[0..1] of tipo_roms=(
        (n:'epr-12390.ic8';l:$8000;p:0;crc:$399fc5f5),(n:'mpr-12384.ic6';l:$20000;p:$8000;crc:$6218d8e7));
        goldnaxe_mcu:tipo_roms=(n:'317-0123a.c2';l:$1000;p:0;crc:$cf19e7d4);
        goldnaxe_tiles:array[0..2] of tipo_roms=(
        (n:'epr-12385.ic19';l:$20000;p:0;crc:$b8a4e7e0),(n:'epr-12386.ic20';l:$20000;p:$20000;crc:$25d7d779),
        (n:'epr-12387.ic21';l:$20000;p:$40000;crc:$c7fcadf3));
        goldnaxe_sprites:array[0..5] of tipo_roms=(
        (n:'mpr-12378.ic9';l:$40000;p:1;crc:$119e5a82),(n:'mpr-12379.ic12';l:$40000;p:$0;crc:$1a0e8c57),
        (n:'mpr-12380.ic10';l:$40000;p:$80001;crc:$bb2c0853),(n:'mpr-12381.ic13';l:$40000;p:$80000;crc:$81ba6ecc),
        (n:'mpr-12382.ic11';l:$40000;p:$100001;crc:$81601c6f),(n:'mpr-12383.ic14';l:$40000;p:$100000;crc:$5dbacf7a));
        //Dinamite Dux
        ddux_rom:array[0..3] of tipo_roms=(
        (n:'epr-12189.a7';l:$20000;p:0;crc:$558e9b5d),(n:'epr-12188.a5';l:$20000;p:$1;crc:$802a240f),
        (n:'epr-11915.a8';l:$20000;p:$40000;crc:$d8ed3132),(n:'epr-11913.a6';l:$20000;p:$40001;crc:$30c6cb92));
        ddux_sound:tipo_roms=(n:'epr-11916.a10';l:$8000;p:0;crc:$7ab541cf);
        ddux_mcu:tipo_roms=(n:'317-0095.c2';l:$1000;p:0;crc:$b06b4ca7);
        ddux_tiles:array[0..2] of tipo_roms=(
        (n:'mpr-11917.a14';l:$10000;p:0;crc:$6f772190),(n:'mpr-11918.a15';l:$10000;p:$10000;crc:$c731db95),
        (n:'mpr-11919.a16';l:$10000;p:$20000;crc:$64d5a491));
        ddux_sprites:array[0..3] of tipo_roms=(
        (n:'mpr-11920.b1';l:$20000;p:$1;crc:$e5d1e3cd),(n:'mpr-11922.b5';l:$20000;p:$0;crc:$70b0c4dd),
        (n:'mpr-11921.b2';l:$20000;p:$40001;crc:$61d2358c),(n:'mpr-11923.b6';l:$20000;p:$40000;crc:$c9ffe47d));
        //E-Swat
        eswat_rom:array[0..1] of tipo_roms=(
        (n:'bootleg_epr-12659.a2';l:$40000;p:0;crc:$3157f69d),(n:'bootleg_epr-12658.a1';l:$40000;p:$1;crc:$0feb544b));
        eswat_sound:array[0..1] of tipo_roms=(
        (n:'epr-12617.a13';l:$8000;p:0;crc:$7efecf23),(n:'mpr-12616.a11';l:$40000;p:$8000;crc:$254347c2));
        eswat_tiles:array[0..2] of tipo_roms=(
        (n:'mpr-12624.b11';l:$40000;p:0;crc:$375a5ec4),(n:'mpr-12625.b12';l:$40000;p:$40000;crc:$3b8c757e),
        (n:'mpr-12626.b13';l:$40000;p:$80000;crc:$3efca25c));
        eswat_sprites:array[0..5] of tipo_roms=(
        (n:'mpr-12618.b1';l:$40000;p:1;crc:$0d1530bf),(n:'mpr-12621.b4';l:$40000;p:$0;crc:$18ff0799),
        (n:'mpr-12619.b2';l:$40000;p:$80001;crc:$32069246),(n:'mpr-12622.b5';l:$40000;p:$80000;crc:$a3dfe436),
        (n:'mpr-12620.b3';l:$40000;p:$100001;crc:$f6b096e0),(n:'mpr-12623.b6';l:$40000;p:$100000;crc:$6773fef6));
        //Passing Shot
        passsht_rom:array[0..1] of tipo_roms=(
        (n:'bootleg_epr-11871.a4';l:$10000;p:0;crc:$f009c017),(n:'bootleg_epr-11870.a1';l:$10000;p:$1;crc:$9cd5f12f));
        passsht_sound:array[0..4] of tipo_roms=(
        (n:'epr-11857.a7';l:$8000;p:0;crc:$789edc06),(n:'epr-11858.a8';l:$8000;p:$8000;crc:$08ab0018),
        (n:'epr-11859.a9';l:$8000;p:$18000;crc:$8673e01b),(n:'epr-11860.a10';l:$8000;p:$28000;crc:$10263746),
        (n:'epr-11861.a11';l:$8000;p:$38000;crc:$38b54a71));
        passsht_tiles:array[0..2] of tipo_roms=(
        (n:'opr-11854.b9';l:$10000;p:0;crc:$d31c0b6c),(n:'opr-11855.b10';l:$10000;p:$10000;crc:$b78762b4),
        (n:'opr-11856.b11';l:$10000;p:$20000;crc:$ea49f666));
        passsht_sprites:array[0..5] of tipo_roms=(
        (n:'opr-11862.b1';l:$10000;p:1;crc:$b6e94727),(n:'opr-11865.b5';l:$10000;p:$0;crc:$17e8d5d5),
        (n:'opr-11863.b2';l:$10000;p:$20001;crc:$3e670098),(n:'opr-11866.b6';l:$10000;p:$20000;crc:$50eb71cc),
        (n:'opr-11864.b3';l:$10000;p:$40001;crc:$05733ca8),(n:'opr-11867.b7';l:$10000;p:$40000;crc:$81e49697));
        //Aurail
        aurail_rom:array[0..3] of tipo_roms=(
        (n:'epr-13577.a7';l:$20000;p:0;crc:$6701b686),(n:'epr-13576.a5';l:$20000;p:$1;crc:$1e428d94),
        (n:'epr-13447.a8';l:$20000;p:$40000;crc:$70a52167),(n:'epr-13445.a6';l:$20000;p:$40001;crc:$28dfc3dd));
        aurail_sound:array[0..1] of tipo_roms=(
        (n:'epr-13448.a10';l:$8000;p:0;crc:$b5183fb9),(n:'mpr-13449.a11';l:$20000;p:$8000;crc:$d3d9aaf9));
        aurail_tiles:array[0..5] of tipo_roms=(
        (n:'mpr-13450.a14';l:$20000;p:0;crc:$0fc4a7a8),(n:'mpr-13465.b14';l:$20000;p:$20000;crc:$e08135e0),
        (n:'mpr-13451.a15';l:$20000;p:$40000;crc:$1c49852f),(n:'mpr-13466.b15';l:$20000;p:$60000;crc:$e14c6684),
        (n:'mpr-13452.a16';l:$20000;p:$80000;crc:$047bde5e),(n:'mpr-13467.b16';l:$20000;p:$a0000;crc:$6309fec4));
        aurail_sprites:array[0..15] of tipo_roms=(
        (n:'mpr-13453.b1';l:$20000;p:1;crc:$5fa0a9f8),(n:'mpr-13457.b5';l:$20000;p:$0;crc:$0d1b54da),
        (n:'mpr-13454.b2';l:$20000;p:$40001;crc:$5f6b33b1),(n:'mpr-13458.b6';l:$20000;p:$40000;crc:$bad340c3),
        (n:'mpr-13455.b3';l:$20000;p:$80001;crc:$4e80520b),(n:'mpr-13459.b7';l:$20000;p:$80000;crc:$7e9165ac),
        (n:'mpr-13456.b4';l:$20000;p:$c0001;crc:$5733c428),(n:'mpr-13460.b8';l:$20000;p:$c0000;crc:$66b8f9b3),
        (n:'mpr-13440.a1';l:$20000;p:$100001;crc:$4f370b2b),(n:'mpr-13461.b10';l:$20000;p:$100000;crc:$f76014bf),
        (n:'mpr-13441.a2';l:$20000;p:$140001;crc:$37cf9cb4),(n:'mpr-13462.b11';l:$20000;p:$140000;crc:$1061e7da),
        (n:'mpr-13442.a3';l:$20000;p:$180001;crc:$049698ef),(n:'mpr-13463.b12';l:$20000;p:$180000;crc:$7dbcfbf1),
        (n:'mpr-13443.a4';l:$20000;p:$1c0001;crc:$77a8989e),(n:'mpr-13464.b13';l:$20000;p:$1c0000;crc:$551df422));
        //Dip
        system16b_dip_a:array [0..2] of def_dip=(
        (mask:$0f;name:'Coin A';number:16;dip:((dip_val:$7;dip_name:'4C/1C'),(dip_val:$8;dip_name:'3C/1C'),(dip_val:$9;dip_name:'2C/1C'),(dip_val:$5;dip_name:'2C/1C 5C/3C 6C/4C'),(dip_val:$4;dip_name:'2C/1C 4C/3C'),(dip_val:$f;dip_name:'1C/1C'),(dip_val:$3;dip_name:'1C/1C 5C/6C'),(dip_val:$2;dip_name:'1C/1C 4C/5C'),(dip_val:$1;dip_name:'1C/1C 2C/3C'),(dip_val:$6;dip_name:'2C/3C'),(dip_val:$e;dip_name:'1C/2C'),(dip_val:$d;dip_name:'1C/3C'),(dip_val:$c;dip_name:'1C/4C'),(dip_val:$b;dip_name:'1C/5C'),(dip_val:$a;dip_name:'1C/6C'),(dip_val:$0;dip_name:'Free Play (if Coin B too) or 1C/1C'))),
        (mask:$f0;name:'Coin B';number:16;dip:((dip_val:$70;dip_name:'4C/1C'),(dip_val:$80;dip_name:'3C/1C'),(dip_val:$90;dip_name:'2C/1C'),(dip_val:$50;dip_name:'2C/1C 5C/3C 6C/4C'),(dip_val:$40;dip_name:'2C/1C 4C/3C'),(dip_val:$f0;dip_name:'1C/1C'),(dip_val:$30;dip_name:'1C/1C 5C/6C'),(dip_val:$20;dip_name:'1C/1C 4C/5C'),(dip_val:$10;dip_name:'1C/1C 2C/3C'),(dip_val:$60;dip_name:'2C/3C'),(dip_val:$e0;dip_name:'1C/2C'),(dip_val:$d0;dip_name:'1C/3C'),(dip_val:$c0;dip_name:'1C/4C'),(dip_val:$b0;dip_name:'1C/5C'),(dip_val:$a0;dip_name:'1C/6C'),(dip_val:$00;dip_name:'Free Play (if Coin A too) or 1C/1C'))),());
        altbeast_dip_b:array [0..5] of def_dip=(
        (mask:$1;name:'Credits Needed';number:2;dip:((dip_val:$1;dip_name:'1 Credit To Start'),(dip_val:$0;dip_name:'2 Credit To Start'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2;name:'Demo Sounds';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Lives';number:4;dip:((dip_val:$8;dip_name:'2'),(dip_val:$c;dip_name:'3'),(dip_val:$4;dip_name:'4'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Player Meter';number:4;dip:((dip_val:$20;dip_name:'2'),(dip_val:$30;dip_name:'3'),(dip_val:$10;dip_name:'4'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Difficulty';number:4;dip:((dip_val:$80;dip_name:'Easy'),(dip_val:$c0;dip_name:'Normal'),(dip_val:$40;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),());
        goldnaxe_dip_b:array [0..3] of def_dip=(
        (mask:$1;name:'Credits Needed';number:2;dip:((dip_val:$1;dip_name:'1 Credit To Start'),(dip_val:$0;dip_name:'2 Credit To Start'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2;name:'Demo Sounds';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$3c;name:'Difficulty';number:8;dip:((dip_val:$0;dip_name:'Special'),(dip_val:$14;dip_name:'Easiest'),(dip_val:$1c;dip_name:'Easier'),(dip_val:$34;dip_name:'Easy'),(dip_val:$3c;dip_name:'Normal'),(dip_val:$38;dip_name:'Hard'),(dip_val:$2c;dip_name:'Harder'),(dip_val:$28;dip_name:'Hardest'),(),(),(),(),(),(),(),())),());
        ddux_dip_b:array [0..4] of def_dip=(
        (mask:$1;name:'Demo Sounds';number:2;dip:((dip_val:$1;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$6;name:'Difficulty';number:4;dip:((dip_val:$4;dip_name:'Easy'),(dip_val:$6;dip_name:'Normal'),(dip_val:$2;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$18;name:'Lives';number:4;dip:((dip_val:$10;dip_name:'2'),(dip_val:$18;dip_name:'3'),(dip_val:$8;dip_name:'4'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$60;name:'Bonus Life';number:4;dip:((dip_val:$40;dip_name:'150K'),(dip_val:$60;dip_name:'200K'),(dip_val:$20;dip_name:'300K'),(dip_val:$0;dip_name:'400K'),(),(),(),(),(),(),(),(),(),(),(),())),());
        eswat_dip_b:array [0..6] of def_dip=(
        (mask:$1;name:'Credits Needed';number:2;dip:((dip_val:$1;dip_name:'1 Credit To Start'),(dip_val:$0;dip_name:'2 Credit To Start'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2;name:'Demo Sounds';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Flip Screen';number:2;dip:((dip_val:$4;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Timer';number:2;dip:((dip_val:$8;dip_name:'Normal'),(dip_val:$0;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Difficulty';number:4;dip:((dip_val:$20;dip_name:'Easy'),(dip_val:$30;dip_name:'Normal'),(dip_val:$10;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Lives';number:4;dip:((dip_val:$0;dip_name:'1'),(dip_val:$40;dip_name:'2'),(dip_val:$c0;dip_name:'3'),(dip_val:$80;dip_name:'4'),(),(),(),(),(),(),(),(),(),(),(),())),());
        passsht_dip_b:array [0..4] of def_dip=(
        (mask:$1;name:'Demo Sounds';number:2;dip:((dip_val:$1;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$e;name:'Initial Point';number:4;dip:((dip_val:$6;dip_name:'2000'),(dip_val:$a;dip_name:'3000'),(dip_val:$c;dip_name:'4000'),(dip_val:$e;dip_name:'5000'),(dip_val:$8;dip_name:'6000'),(dip_val:$4;dip_name:'7000'),(dip_val:$2;dip_name:'8000'),(dip_val:$0;dip_name:'9000'),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Point Table';number:4;dip:((dip_val:$20;dip_name:'Easy'),(dip_val:$30;dip_name:'Normal'),(dip_val:$10;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Difficulty';number:4;dip:((dip_val:$80;dip_name:'Easy'),(dip_val:$c0;dip_name:'Normal'),(dip_val:$40;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),());
        aurail_dip_b:array [0..7] of def_dip=(
        (mask:$1;name:'Cabinet';number:2;dip:((dip_val:$1;dip_name:'Upright'),(dip_val:$0;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2;name:'Demo Sounds';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Lives';number:4;dip:((dip_val:$0;dip_name:'2'),(dip_val:$c;dip_name:'3'),(dip_val:$8;dip_name:'4'),(dip_val:$4;dip_name:'5'),(dip_val:$8;dip_name:'6000'),(dip_val:$4;dip_name:'7000'),(dip_val:$2;dip_name:'8000'),(dip_val:$0;dip_name:'9000'),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Bonus Life';number:2;dip:((dip_val:$10;dip_name:'80K/200K/500K/1000K'),(dip_val:$0;dip_name:'100K/300K/700K/1000K'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Difficulty';number:2;dip:((dip_val:$20;dip_name:'Normal'),(dip_val:$0;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Controller';number:2;dip:((dip_val:$40;dip_name:'1 Player Side'),(dip_val:$0;dip_name:'2 Players Side'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Special Function Mode';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

type
  tsystem16_info=record
    	normal,shadow,hilight:array[0..31] of byte;
      s_banks,t_banks:byte;
      mb_type:byte;
      screen:array[0..7] of byte;
      screen_enabled:boolean;
      tile_bank:array[0..1] of byte;
      tile_buffer:array[0..7,0..$7ff] of boolean;
   end;

var
 rom:array[0..$3ffff] of word;
 rom2:array[0..$1ffff] of word;
 ram:array[0..$ffff] of word;
 tile_ram:array[0..$7fff] of word;
 char_ram:array[0..$7ff] of word;
 sprite_ram:array[0..$3ff] of word;
 sprite_rom:array[0..$fffff] of word;
 sprite_bank:array[0..$f] of byte;
 s16_info:tsystem16_info;
 sound_bank:array[0..$f,0..$3fff] of byte;
 sound_bank_num:byte;
 sound_latch:byte;
 s315_5248_regs:array[0..1] of word;
 s315_5250_regs:array[0..$f] of word;
 s315_5250_bit:byte;
 region0_read:function(direccion:dword):word;
 region1_read:function(direccion:dword):word;
 region2_read:function(direccion:dword):word;
 region1_write:procedure(direccion:dword;valor:word);
 region2_write:procedure(direccion:dword;valor:word);
 sound_bank_calc:function(valor:byte):byte;

procedure update_video_system16b;
procedure draw_sprites(pri:byte);
var
  g,f,sprpri,vzoom,hzoom:byte;
  bottom,top,xacc,addr,bank,y,pix,data_7,pixels,color:word;
  x,xpos,pitch:integer;
  spritedata:dword;
  hide,flip:boolean;
procedure system16b_draw_pixel(x:integer;y,pix:word);
var
  punt,punt2,temp1,temp2,temp3:word;
begin
  //only draw if onscreen, not 0 or 15
	if ((x>=0) and (x<320) and ((pix and $f)<>0) and ((pix and $f)<>15)) then begin
      if (pix and $3f0)=$3f0 then begin //Shadow
          punt:=getpixel(x+ADD_SPRITE,y+ADD_SPRITE,7);
          punt2:=paleta[$800];
          temp1:=(((punt and $f800)+(punt2 and $f800)) shr 1) and $f800;
          temp2:=(((punt and $7e0)+(punt2 and $7e0)) shr 1) and $7e0;
          temp3:=(((punt and $1f)+(punt2 and $1f)) shr 1) and $1f;
          punt:=temp1 or temp2 or temp3;
      end else punt:=paleta[pix+$400]; //Normal
      putpixel(x+ADD_SPRITE,y+ADD_SPRITE,1,@punt,7);
	end;
end;
begin
  for f:=0 to $7f do begin
    sprpri:=(sprite_ram[(f*8)+4] and $ff) shr 6;
    if sprpri<>pri then continue;
    addr:=sprite_ram[(f*8)+3];
    sprite_ram[(f*8)+7]:=addr;
    if (sprite_ram[(f*8)+2] and $8000)<>0 then exit;
    bottom:=(sprite_ram[f*8] shr 8);
    top:=sprite_ram[f*8] and $ff;
    hide:=(sprite_ram[(f*8)+2] and $4000)<>0;
    bank:=sprite_bank[(sprite_ram[(f*8)+4] shr 8) and $f];
    // if hidden, or top greater than/equal to bottom, or invalid bank, punt
		if (hide or (top>=bottom) or (bank=255)) then continue;
		xpos:=(sprite_ram[(f*8)+1] and $1ff)-$b7; //-$bd+6
		pitch:=shortint(sprite_ram[(f*8)+2] and $ff);
		color:=(sprite_ram[(f*8)+4] and $3f) shl 4;
    flip:=(sprite_ram[(f*8)+2] and $100)<>0;
    vzoom:=(sprite_ram[(f*8)+5] shr 5) and $1f;
    hzoom:=sprite_ram[(f*8)+5] and $1f;
		// clamp to within the memory region size
		spritedata:=$10000*(bank mod s16_info.s_banks);
    // reset the yzoom counter
    sprite_ram[(f*8)+5]:=sprite_ram[(f*8)+5] and $3ff;
		// loop from top to bottom
		for y:=top to (bottom-1) do begin
			// advance a row
			addr:=addr+pitch;
      // accumulate zoom factors; if we carry into the high bit, skip an extra row
      sprite_ram[(f*8)+5]:=sprite_ram[(f*8)+5]+(vzoom shl 10);
      if (sprite_ram[(f*8)+5] and $8000)<>0 then begin
        addr:=addr+pitch;
        sprite_ram[(f*8)+5]:=sprite_ram[(f*8)+5] and $7fff;
      end;
			// skip drawing if not within the cliprect
			if (y<256) then begin
        xacc:=4*hzoom;
				if not(flip) then begin
					data_7:=addr;
					x:=xpos;
          while (x<512) do begin
						pixels:=sprite_rom[spritedata+data_7];
						// draw four pixels
            for g:=3 downto 0 do begin
              xacc:=(xacc and $3f)+hzoom;
              if xacc<$40 then begin
                pix:=(pixels shr (g*4)) and $f;
                system16b_draw_pixel(x,y,pix or color);
                x:=x+1;
              end;
            end;
						// stop if the last pixel in the group was 0xf
						if (((pixels shr 0) and $f)=15) then begin
              sprite_ram[(f*8)+7]:=data_7;
              break;
            end else data_7:=data_7+1;
					end;
				end else begin
				  // flipped case
          data_7:=addr;
					x:=xpos;
          while (x<512) do begin
						pixels:=sprite_rom[spritedata+data_7];
						// draw four pixels
            for g:=0 to 3 do begin
              xacc:=(xacc and $3f)+hzoom;
              if xacc<$40 then begin
                pix:=(pixels shr (g*4)) and $f;
                system16b_draw_pixel(x,y,pix or color);
                x:=x+1;
              end;
            end;
						// stop if the last pixel in the group was 0xf
						if (((pixels shr 12) and $f)=15) then begin
              sprite_ram[(f*8)+7]:=data_7;
              break;
            end else data_7:=data_7-1;
					end;
				end;
			end;
		end;
	end;
end;

procedure draw_tiles(num:byte;px,py:word;scr:byte;trans:boolean);
var
  pos,f,nchar,color,data,x,y:word;
begin
  pos:=s16_info.screen[num]*$800;
  for f:=$0 to $7ff do begin
    data:=tile_ram[pos+f];
    color:=(data shr 6) and $7f;
    if (s16_info.tile_buffer[num,f] or buffer_color[color]) then begin
      x:=((f and $3f) shl 3)+px;
      y:=((f shr 6) shl 3)+py;
      nchar:=data and $1fff;
      nchar:=s16_info.tile_bank[nchar div $1000]*$1000+(nchar mod $1000);
      if trans then put_gfx_trans(x,y,nchar,color shl 3,scr,0)
        else put_gfx(x,y,nchar,color shl 3,scr,0);
      if (data and $8000)<>0 then put_gfx_trans(x,y,nchar,color shl 3,scr+1,0)
        else put_gfx_block_trans(x,y,scr+1,8,8);
      s16_info.tile_buffer[num,f]:=false;
    end;
  end;
end;

var
  f,nchar,color,scroll_x1,scroll_x2,x,y,atrib,scroll_y1,scroll_y2:word;
begin
if not(s16_info.screen_enabled) then begin
  fill_full_screen(7,$1000);
  actualiza_trozo_final(0,0,320,224,7);
  exit;
end;
//Background
draw_tiles(0,0,256,3,false);
draw_tiles(1,512,256,3,false);
draw_tiles(2,0,0,3,false);
draw_tiles(3,512,0,3,false);
scroll_x1:=char_ram[$74d] and $3ff;
scroll_x1:=(704-scroll_x1) and $3ff;
scroll_y1:=char_ram[$749] and $1ff;
//Foreground
draw_tiles(4,0,256,5,true);
draw_tiles(5,512,256,5,true);
draw_tiles(6,0,0,5,true);
draw_tiles(7,512,0,5,true);
scroll_x2:=char_ram[$74c] and $3ff;
scroll_x2:=(704-scroll_x2) and $3ff;
scroll_y2:=char_ram[$748] and $1ff;
//text
for f:=$0 to $6ff do begin
  atrib:=char_ram[f];
  color:=(atrib shr 9) and $7;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
    x:=(f and $3f) shl 3;
    y:=(f shr 6) shl 3;
    nchar:=s16_info.tile_bank[0]*$1000+(atrib and $1ff);
    put_gfx_trans(x,y,nchar,color shl 3,1,0);
    if (atrib and $8000)<>0 then put_gfx_trans(x,y,nchar,color shl 3,2,0)
      else put_gfx_block_trans(x,y,2,8,8);
    gfx[0].buffer[f]:=false;
  end;
end;
//Lo pongo todo con prioridades, falta scrollrow y scrollcol!!
scroll_x_y(3,7,scroll_x1,scroll_y1); //B0
draw_sprites(0);
scroll_x_y(4,7,scroll_x1,scroll_y1); //B1
draw_sprites(1);
scroll_x_y(5,7,scroll_x2,scroll_y2);  //F0
draw_sprites(2);
scroll_x_y(6,7,scroll_x2,scroll_y2); //F1
actualiza_trozo(192,0,320,224,1,0,0,320,224,7); //T0
draw_sprites(3);
actualiza_trozo(192,0,320,224,2,0,0,320,224,7); //T1
//Y lo pinto a la pantalla principal
actualiza_trozo_final(0,0,320,224,7);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
end;

procedure eventos_system16b;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $ffdf) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $ffef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $ff7f) else marcade.in1:=(marcade.in1 or $80);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $ffbf) else marcade.in1:=(marcade.in1 or $40);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $fffb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $fffd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.but2[0] then marcade.in1:=(marcade.in1 and $fffe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.but3[0] then marcade.in1:=(marcade.in1 and $fff7) else marcade.in1:=(marcade.in1 or $8);
  //P2
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $ffdf) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $ffef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $ff7f) else marcade.in2:=(marcade.in2 or $80);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $ffbf) else marcade.in2:=(marcade.in2 or $40);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $fffb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $fffd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.but2[1] then marcade.in2:=(marcade.in2 and $fffe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.but3[1] then marcade.in2:=(marcade.in2 and $fff7) else marcade.in2:=(marcade.in2 or $8);
  //Service
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $ffef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $ffdf) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fffe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fffd) else marcade.in0:=(marcade.in0 or $2);
end;
end;

procedure system16b_principal_mcu;
var
  frame_m,frame_s,frame_mcu:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
frame_s:=z80_0.tframes;
frame_mcu:=mcs51_0.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to 261 do begin
     //main
     m68000_0.run(frame_m);
     frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
     //sound
     z80_0.run(frame_s);
     frame_s:=frame_s+z80_0.tframes-z80_0.contador;
     //MCU
     mcs51_0.run(frame_mcu);
     frame_mcu:=frame_mcu+mcs51_0.tframes-mcs51_0.contador;
     if f=223 then begin
       mcs51_0.change_irq0(HOLD_LINE);
       update_video_system16b;
     end;
  end;
  eventos_system16b;
  video_sync;
end;
end;

procedure system16b_principal;
var
  frame_m,frame_s:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
frame_s:=z80_0.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to 261 do begin
     //main
     m68000_0.run(frame_m);
     frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
     //sound
     z80_0.run(frame_s);
     frame_s:=frame_s+z80_0.tframes-z80_0.contador;
     if f=223 then begin
       m68000_0.irq[4]:=HOLD_LINE;
       update_video_system16b;
     end;
  end;
  eventos_system16b;
  video_sync;
end;
end;

function standar_s16_io_r(direccion:word):word;
var
  res:word;
begin
res:=$ff;
case (direccion and $1800) of
	$800:case (direccion and 3) of
          0:res:=marcade.in0; //SERVICE
          1:res:=marcade.in1; //P1
          2:; //UNUSED
          3:res:=marcade.in2; //P2
       end;
  $1000:case (direccion and $1) of
                  0:res:=marcade.dswb; //DSW2
                  1:res:=marcade.dswa; //DSW1
               end;
end;
standar_s16_io_r:=res;
end;

procedure change_pal(direccion,valor:word);
var
	r,g,b:byte;
  color:tcolor;
begin
	//     byte 0    byte 1
	//  sBGR BBBB GGGG RRRR
	//  x000 4321 4321 4321
	r:=((valor shr 12) and $01) or ((valor shl 1) and $1e);
	g:=((valor shr 13) and $01) or ((valor shr 3) and $1e);
	b:=((valor shr 14) and $01) or ((valor shr 7) and $1e);
  //normal
  color.r:=s16_info.normal[r];
  color.g:=s16_info.normal[g];
  color.b:=s16_info.normal[b];
  set_pal_color(color,direccion);
  //shadow
  if (valor and $8000)<>0 then begin
    color.r:=s16_info.shadow[r];
    color.g:=s16_info.shadow[g];
    color.b:=s16_info.shadow[b];
  end else begin
    //hilight
    color.r:=s16_info.hilight[r];
    color.g:=s16_info.hilight[g];
    color.b:=s16_info.hilight[b];
  end;
  set_pal_color(color,direccion+$800);
  buffer_color[(direccion shr 3) and $7f]:=true;
end;

procedure test_screen_change(direccion:word);
var
  tmp:byte;
begin
if direccion=$740 then begin
          //Foreground
          tmp:=(char_ram[$740] shr 12) and $f;
          if tmp<>s16_info.screen[4] then begin
            s16_info.screen[4]:=tmp;
            fillchar(s16_info.tile_buffer[4,0],$800,1);
          end;
          tmp:=(char_ram[$740] shr 8) and $f;
          if tmp<>s16_info.screen[5] then begin
            s16_info.screen[5]:=tmp;
            fillchar(s16_info.tile_buffer[5,0],$800,1);
          end;
          tmp:=(char_ram[$740] shr 4) and $f;
          if tmp<>s16_info.screen[6] then begin
            s16_info.screen[6]:=tmp;
            fillchar(s16_info.tile_buffer[6,0],$800,1);
          end;
          tmp:=char_ram[$740] and $f;
          if tmp<>s16_info.screen[7] then begin
            s16_info.screen[7]:=tmp;
            fillchar(s16_info.tile_buffer[7,0],$800,1);
          end;
end;
if direccion=$741 then begin
          //Background
          tmp:=(char_ram[$741] shr 12) and $f;
          if tmp<>s16_info.screen[0] then begin
            s16_info.screen[0]:=tmp;
            fillchar(s16_info.tile_buffer[0,0],$800,1);
          end;
          tmp:=(char_ram[$741] shr 8) and $f;
          if tmp<>s16_info.screen[1] then begin
            s16_info.screen[1]:=tmp;
            fillchar(s16_info.tile_buffer[1,0],$800,1);
          end;
          tmp:=(char_ram[$741] shr 4) and $f;
          if tmp<>s16_info.screen[2] then begin
            s16_info.screen[2]:=tmp;
            fillchar(s16_info.tile_buffer[2,0],$800,1);
          end;
          tmp:=char_ram[$741] and $f;
          if tmp<>s16_info.screen[3] then begin
            s16_info.screen[3]:=tmp;
            fillchar(s16_info.tile_buffer[3,0],$800,1);
          end;
end;
end;

function region0_5704_read(direccion:dword):word;
begin
direccion:=(direccion and $3ffff) shr 1;
region0_5704_read:=rom[direccion];
end;

function region0_5797_read(direccion:dword):word;
begin
direccion:=(direccion and $7ffff) shr 1;
region0_5797_read:=rom[direccion];
end;

function region0_5358_read(direccion:dword):word;
begin
direccion:=(direccion and $1ffff) shr 1;
region0_5358_read:=rom[direccion];
end;

function region1_5704_read(direccion:dword):word;
begin
direccion:=(direccion and $3ffff) shr 1;
region1_5704_read:=rom2[direccion];
end;

function region1_5797_read(direccion:dword):word;
begin
direccion:=(direccion shr 1) and $1fff;
case (direccion and $1800) of
  0:case (direccion and 3) of
      0:region1_5797_read:=s315_5248_regs[0];
      1:region1_5797_read:=s315_5248_regs[1];
      2:region1_5797_read:=(smallint(s315_5248_regs[0])*smallint(s315_5248_regs[1])) shr 16;
      3:region1_5797_read:=(smallint(s315_5248_regs[0])*smallint(s315_5248_regs[1])) and $ffff;
    end;
  $800:case (direccion and $f) of
        0..7:region1_5797_read:=s315_5250_regs[direccion and $f];
          else region1_5797_read:=$ffff;
      end;
end;
end;

procedure region1_5797_write(direccion:dword;valor:word);
procedure exec(history:boolean=false);
var
  min,max,bound1,bound2,value:smallint;
begin
	bound1:= smallint(s315_5250_regs[0]);
	bound2:= smallint(s315_5250_regs[1]);
	value:= smallint(s315_5250_regs[2]);
  if (bound1<bound2) then min:=bound1
    else min:=bound2;
  if (bound1>bound2) then max:=bound1
    else max:=bound2;
	if (value<min) then begin
		s315_5250_regs[7]:=min;
    s315_5250_regs[3]:=$8000;
	end else if (value>max) then begin
		    s315_5250_regs[7]:=max;
		    s315_5250_regs[3]:=$4000;
	    end else begin
		      s315_5250_regs[7]:=value;
		      s315_5250_regs[3]:=0;
      end;
	if (history) then begin
    s315_5250_regs[4]:=s315_5250_regs[4] or (byte(s315_5250_regs[3]=0) shl s315_5250_bit);
    s315_5250_bit:=s315_5250_bit+1;
  end;
end;
begin
direccion:=(direccion shr 1) and $1fff;
case (direccion and $1800) of
  0:s315_5248_regs[direccion and 1]:=valor;
  $800:case direccion and 15 of
        0..1:begin
          s315_5250_regs[direccion and $f]:=valor;
          exec;
        end;
        2:begin
          s315_5250_regs[2]:=valor;
          exec(true);
        end;
        4:begin
          s315_5250_regs[4]:=0;
          s315_5250_bit:=0;
        end;
        6:begin
          s315_5250_regs[2]:=valor;
          exec;
        end;
        8,$c:s315_5250_regs[8]:=valor;
        9,$d:; //irq ack
        $a,$e:s315_5250_regs[10]:=valor;
        $b,$f:s315_5250_regs[11]:=valor; //write to sound
  end;
  $1000:begin
          s16_info.tile_bank[direccion and 1]:=(valor and 7) and s16_info.t_banks; //Tile bank!
          fillchar(s16_info.tile_buffer,$4000,1);
        end;
end;
end;

procedure region2_5704_write(direccion:dword;valor:word);
begin
  if s16_info.tile_bank[(direccion and 3) shr 1]<>(valor and 7) then begin//Tile bank!
    s16_info.tile_bank[(direccion and 3) shr 1]:=(valor and 7) and s16_info.t_banks;
    fillchar(s16_info.tile_buffer,$4000,1);
  end;
end;

function system16b_getword(direccion:dword):word;
var
  zona:boolean;
begin
zona:=false;
if ((direccion>=s315_5195_0.dirs_start[0]) and (direccion<s315_5195_0.dirs_end[0])) then begin
  //Esta zona no se puede solapar!!!!
  system16b_getword:=region0_read(direccion);
  exit;
end;
if ((direccion>=s315_5195_0.dirs_start[1]) and (direccion<s315_5195_0.dirs_end[1])) then begin
  if @region1_read<>nil then system16b_getword:=region1_read(direccion);
  zona:=true;
end;
if ((direccion>=s315_5195_0.dirs_start[2]) and (direccion<s315_5195_0.dirs_end[2])) then begin
  if @region2_read<>nil then system16b_getword:=region2_read(direccion);
  zona:=true;
end;
if ((direccion>=s315_5195_0.dirs_start[3]) and (direccion<s315_5195_0.dirs_end[3])) then begin
  system16b_getword:=ram[(direccion and $ffff) shr 1]; //RAM
  zona:=true;
end;
if ((direccion>=s315_5195_0.dirs_start[4]) and (direccion<s315_5195_0.dirs_end[4])) then begin
  system16b_getword:=sprite_ram[(direccion and $7ff) shr 1]; //Object RAM
  zona:=true;
end;
if ((direccion>=s315_5195_0.dirs_start[5]) and (direccion<s315_5195_0.dirs_end[5])) then begin
  case direccion and $1ffff of //Text/Tile RAM
    0..$ffff:system16b_getword:=tile_ram[(direccion and $ffff) shr 1];
    $10000..$1ffff:system16b_getword:=char_ram[(direccion and $fff) shr 1];
  end;
  zona:=true;
end;
if ((direccion>=s315_5195_0.dirs_start[6]) and (direccion<s315_5195_0.dirs_end[6])) then begin
  system16b_getword:=buffer_paleta[(direccion and $fff) shr 1]; //Color RAM
  zona:=true;
end;
if ((direccion>=s315_5195_0.dirs_start[7]) and (direccion<s315_5195_0.dirs_end[7])) then begin
  system16b_getword:=standar_s16_io_r((direccion shr 1) and $1fff); //IO Read
  zona:=true;
end;
if not(zona) then system16b_getword:=s315_5195_0.read_reg((direccion shr 1) and $1f);
end;

procedure test_tile_buffer(direccion:word);
var
  num_scr,f:byte;
  pos:word;
begin
  num_scr:=direccion shr 11;
  pos:=direccion and $7ff;
  for f:=0 to 7 do
    if s16_info.screen[f]=num_scr then s16_info.tile_buffer[f,pos]:=true;
end;

procedure system16b_putword(direccion:dword;valor:word);
var
  zona:boolean;
  tempd:dword;
begin
{Region 0 - Program ROM
 Region 3 - 68000 work RAM
 Region 4 - Object RAM
 Region 5 - Text/tile RAM
 Region 6 - Color RAM
 Region 7 - I/O area
 Si tiene una region mapeada hace lo que toca, pero si no tiene nada mapeado
 rellena los registros del 315-5195 y mapea
 Se pueden solapar las zonas (excepto la 0), tiene prioridad la mas alta (por ejemplo ESwat)
 }
zona:=false;
if ((direccion>=s315_5195_0.dirs_start[0]) and (direccion<s315_5195_0.dirs_end[0])) then begin
  zona:=true;
end;
if ((direccion>=s315_5195_0.dirs_start[1]) and (direccion<s315_5195_0.dirs_end[1])) then begin
  if @region1_write<>nil then region1_write(direccion,valor);
  zona:=true;
end;
if ((direccion>=s315_5195_0.dirs_start[2]) and (direccion<s315_5195_0.dirs_end[2])) then begin
  if @region2_write<>nil then region2_write(direccion,valor);
  zona:=true;
end;
if ((direccion>=s315_5195_0.dirs_start[3]) and (direccion<s315_5195_0.dirs_end[3])) then begin
  ram[(direccion and $ffff) shr 1]:=valor; //RAM
  zona:=true;
end;
if ((direccion>=s315_5195_0.dirs_start[4]) and (direccion<s315_5195_0.dirs_end[4])) then begin
  sprite_ram[(direccion and $7ff) shr 1]:=valor; //Object RAM
  zona:=true;
end;
if ((direccion>=s315_5195_0.dirs_start[5]) and (direccion<s315_5195_0.dirs_end[5])) then begin
  case direccion and $1ffff of
      0..$ffff:begin
                  direccion:=(direccion and $ffff) shr 1;
                  if tile_ram[direccion]<>valor then begin
                    tile_ram[direccion]:=valor;
                    test_tile_buffer(direccion);
                  end;
               end;
      $10000..$1ffff:begin
                  direccion:=(direccion and $fff) shr 1;
                  if char_ram[direccion]<>valor then begin
                    char_ram[direccion]:=valor;
                    gfx[0].buffer[direccion]:=true;
                  end;
                  test_screen_change(direccion);
               end;
  end;
  zona:=true;
end;
if ((direccion>=s315_5195_0.dirs_start[6]) and (direccion<s315_5195_0.dirs_end[6])) then begin
  direccion:=(direccion and $fff) shr 1;
  if buffer_paleta[direccion]<>valor then begin
    buffer_paleta[direccion]:=valor;
    change_pal(direccion,valor);
  end;
  zona:=true;
end;
if ((direccion>=s315_5195_0.dirs_start[7]) and (direccion<s315_5195_0.dirs_end[7])) then begin
  case ((direccion and $1fff) shr 1) of //IO
    0:s16_info.screen_enabled:=(valor and $20)<>0;
  end;
  zona:=true;
end;
if not(zona) then begin
  tempd:=s315_5195_0.dirs_start[5];
  s315_5195_0.write_reg((direccion shr 1) and $1f,valor and $ff);
  if tempd<>s315_5195_0.dirs_start[5] then fillchar(s16_info.tile_buffer,$4000,0);
end;
end;

procedure system16b_putword_mcu(direccion:dword;valor:word);
begin
//Cuando hay un i8751 el M68000 no tiene acceso directo al 315-5195!!
//Por ejemplo GoldenAxe solo espera que el i8751 toque el direccionamiento o se vuelve loco!
if ((direccion>=s315_5195_0.dirs_start[0]) and (direccion<s315_5195_0.dirs_end[0])) then begin
end;
if ((direccion>=s315_5195_0.dirs_start[1]) and (direccion<s315_5195_0.dirs_end[1])) then begin
  if @region1_write<>nil then region1_write(direccion,valor);
end;
if ((direccion>=s315_5195_0.dirs_start[2]) and (direccion<s315_5195_0.dirs_end[2])) then begin
  if @region2_write<>nil then region2_write(direccion,valor);
end;
if ((direccion>=s315_5195_0.dirs_start[3]) and (direccion<s315_5195_0.dirs_end[3])) then begin
  ram[(direccion and $ffff) shr 1]:=valor; //RAM
end;
if ((direccion>=s315_5195_0.dirs_start[4]) and (direccion<s315_5195_0.dirs_end[4])) then begin
  sprite_ram[(direccion and $7ff) shr 1]:=valor; //Object RAM
end;
if ((direccion>=s315_5195_0.dirs_start[5]) and (direccion<s315_5195_0.dirs_end[5])) then begin
  case direccion and $1ffff of
      0..$ffff:begin
                  direccion:=(direccion and $ffff) shr 1;
                  if tile_ram[direccion]<>valor then begin
                    tile_ram[direccion]:=valor;
                    test_tile_buffer(direccion);
                  end;
               end;
      $10000..$1ffff:begin
                  direccion:=(direccion and $fff) shr 1;
                  if char_ram[direccion]<>valor then begin
                    char_ram[direccion]:=valor;
                    gfx[0].buffer[direccion]:=true;
                  end;
                  test_screen_change(direccion);
               end;
  end;
end;
if ((direccion>=s315_5195_0.dirs_start[6]) and (direccion<s315_5195_0.dirs_end[6])) then begin
  direccion:=(direccion and $fff) shr 1;
  if buffer_paleta[direccion]<>valor then begin
    buffer_paleta[direccion]:=valor;
    change_pal(direccion,valor);
  end;
end;
if ((direccion>=s315_5195_0.dirs_start[7]) and (direccion<s315_5195_0.dirs_end[7])) then begin
  case ((direccion and $1fff) shr 1) of //IO
    0:s16_info.screen_enabled:=(valor and $20)<>0;
  end;
end;
end;

function system16b_snd_getbyte(direccion:word):byte;
var
  res:byte;
begin
res:=$ff;
case direccion of
  0..$7fff:res:=mem_snd[direccion];
  $8000..$dfff:res:=sound_bank[sound_bank_num,direccion and $3fff];
  $e800:begin
           res:=sound_latch;
           z80_0.change_irq(CLEAR_LINE);
        end;
  $f800..$ffff:res:=mem_snd[direccion];
end;
system16b_snd_getbyte:=res;
end;

procedure system16b_snd_putbyte(direccion:word;valor:byte);
begin
if direccion>$f7ff then mem_snd[direccion]:=valor;
end;

function system16b_snd_inbyte(puerto:word):byte;
var
  res:byte;
begin
res:=$ff;
case (puerto and $ff) of
  $00..$3f:if (puerto and 1)<>0 then res:=ym2151_0.status;
  $80..$bf:res:=upd7759_0.busy_r shl 7;
  $c0..$ff:begin
              res:=sound_latch;
              z80_0.change_irq(CLEAR_LINE);
           end;
end;
system16b_snd_inbyte:=res;
end;

procedure system16b_snd_irq(valor:byte);
begin
  sound_latch:=valor;
  z80_0.change_irq(ASSERT_LINE);
end;

function system16b_sound_5704(valor:byte):byte;
begin
  system16b_sound_5704:=valor and $f;
end;

function system16b_sound_5797(valor:byte):byte;
begin
  //De momento el maximo de bancos es de 16!
  system16b_sound_5797:=(valor and $7) or ((valor and $10) shr 1);// or ((valor and 8) shl 1);
end;

function system16b_sound_5358(valor:byte):byte;
begin
  system16b_sound_5358:=(valor and $3)+((not(valor) and $38) shr 1);
end;

procedure system16b_snd_outbyte(puerto:word;valor:byte);
begin
case (puerto and $ff) of
  $00..$3f:case (puerto and 1) of
              0:ym2151_0.reg(valor);
              1:ym2151_0.write(valor);
           end;
  $40..$7f:begin
              upd7759_0.start_w((valor shr 7) and 1);
      	      upd7759_0.reset_w((valor shr 6) and 1);
              sound_bank_num:=sound_bank_calc(valor);
           end;
  $80..$bf:upd7759_0.port_w(valor);
end;
end;

function system16b_mcu_getbyte(direccion:word):byte;
begin
  system16b_mcu_getbyte:=s315_5195_0.read_reg(direccion and $1f);
end;

procedure system16b_mcu_putbyte(direccion:word;valor:byte);
var
  tempd:dword;
begin
  tempd:=s315_5195_0.dirs_start[5];
  s315_5195_0.write_reg(direccion and $1f,valor);
  if tempd<>s315_5195_0.dirs_start[5] then fillchar(s16_info.tile_buffer,$4000,0);
end;

function in_port1:byte;
begin
  in_port1:=marcade.in0;
end;

procedure system16b_sound_act;
begin
  ym2151_0.update;
  upd7759_0.update;
end;

procedure upd7759_drq(valor:byte);
begin
  if (valor and 1)<>0 then z80_0.change_nmi(PULSE_LINE);
end;

//Main
procedure reset_system16b;
var
  f:byte;
begin
 //Debo poner el direccionamiento antes del reset de la CPU!!!
 s315_5195_0.reset;
 m68000_0.reset;
 z80_0.reset;
 mcs51_0.reset;
 upd7759_0.reset;
 ym2151_0.reset;
 reset_audio;
 marcade.in0:=$ffff;
 marcade.in1:=$ffff;
 marcade.in2:=$ffff;
 if s16_info.mb_type=1 then begin
  for f:=0 to $f do sprite_bank[f]:=$ff;
  sprite_bank[0]:=0;
  sprite_bank[7]:=3;
  sprite_bank[11]:=2;
  sprite_bank[13]:=1;
  sprite_bank[14]:=0;
 end else for f:=0 to $f do sprite_bank[f]:=f;
 s16_info.screen_enabled:=false;
 fillchar(s16_info.tile_buffer,$4000,1);
 s16_info.tile_bank[0]:=0;
 s16_info.tile_bank[1]:=1;
 sound_bank_num:=0;
 sound_latch:=0;
 s315_5250_bit:=0;
end;

function iniciar_system16b:boolean;
var
  f:word;
  memoria_temp:pbyte;
  memoria_temp2,ptemp:pword;
  weights:array[0..1,0..5] of single;
  i0,i1,i2,i3,i4:integer;
const
  resistances_normal:array[0..5] of integer=(3900, 2000, 1000, 1000 div 2,1000 div 4, 0);
	resistances_sh:array[0..5] of integer=(3900, 2000, 1000, 1000 div 2, 1000 div 4, 470);
procedure convert_chars(n:byte);
const
  pt_x:array[0..7] of dword=(0, 1, 2, 3, 4, 5, 6, 7 );
  pt_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
begin
init_gfx(0,8,8,n*$1000);
gfx[0].trans[0]:=true;
gfx_set_desc_data(3,0,8*8,n*$10000*8,n*$8000*8,0);
convert_gfx(0,0,memoria_temp,@pt_x,@pt_y,false,false);
end;
begin
case main_vars.tipo_maquina of
  292,293,294:llamadas_maquina.bucle_general:=system16b_principal_mcu;
  295,296,297:llamadas_maquina.bucle_general:=system16b_principal;
end;
llamadas_maquina.reset:=reset_system16b;
llamadas_maquina.fps_max:=60.05439;
iniciar_system16b:=false;
iniciar_audio(false);
//text
screen_init(1,512,256,true);
screen_init(2,512,256,true);
//Background
screen_init(3,1024,512);
screen_mod_scroll(3,1024,512,1023,512,256,511);
screen_init(4,1024,512,true);
screen_mod_scroll(4,1024,512,1023,512,256,511);
//Foreground
screen_init(5,1024,512,true);
screen_mod_scroll(5,1024,512,1023,512,256,511);
screen_init(6,1024,512,true);
screen_mod_scroll(6,1024,512,1023,512,256,511);
//Final
screen_init(7,512,256,false,true);
if main_vars.tipo_maquina=296 then main_screen.rol90_screen:=true;
iniciar_video(320,224);
//Main CPU
m68000_0:=cpu_m68000.create(10000000,262);
//Sound CPU
z80_0:=cpu_z80.create(5000000,262);
z80_0.change_ram_calls(system16b_snd_getbyte,system16b_snd_putbyte);
z80_0.change_io_calls(system16b_snd_inbyte,system16b_snd_outbyte);
z80_0.init_sound(system16b_sound_act);
//Memory Mapper
s315_5195_0:=t315_5195.create(m68000_0,z80_0,system16b_snd_irq);
//MCU
mcs51_0:=cpu_mcs51.create(8000000,262);
mcs51_0.change_ram_calls(system16b_mcu_getbyte,system16b_mcu_putbyte);
mcs51_0.change_io_calls(nil,in_port1,nil,nil,nil,nil{out_port1},nil,nil);
//Sound
ym2151_0:=ym2151_chip.create(4000000);
upd7759_0:=upd7759_chip.create(0.9,0,upd7759_drq);
//DIP
marcade.dswa:=$ff;
marcade.dswa_val:=@system16b_dip_a;
region1_read:=nil;
region1_write:=nil;
region2_read:=nil;
region2_write:=nil;
getmem(memoria_temp,$100000);
s16_info.mb_type:=0;
case main_vars.tipo_maquina of
  292:begin  //Altered Beast
        //Main CPU
        m68000_0.change_ram16_calls(system16b_getword,system16b_putword_mcu);
        if not(roms_load16w(@rom,altbeast_rom)) then exit;
        region0_read:=region0_5704_read;
        region2_write:=region2_5704_write;
        //Sound CPU
        if not(roms_load(memoria_temp,altbeast_sound)) then exit;
        copymemory(@mem_snd,@memoria_temp[0],$8000);
        for f:=0 to $f do copymemory(@sound_bank[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
        sound_bank_calc:=system16b_sound_5704;
        //MCU
        if not(roms_load(mcs51_0.get_rom_addr,altbeast_mcu)) then exit;
        //tiles
        if not(roms_load(memoria_temp,altbeast_tiles)) then exit;
        convert_chars(4);
        s16_info.t_banks:=3;
        //Sprite ROM
        if not(roms_load16w(@sprite_rom,altbeast_sprites)) then exit;
        s16_info.s_banks:=8;
        marcade.dswb:=$fd;
        marcade.dswb_val:=@altbeast_dip_b;
  end;
  293:begin  //Golden Axe
        //Main CPU
        m68000_0.change_ram16_calls(system16b_getword,system16b_putword_mcu);
        if not(roms_load16w(@rom,goldnaxe_rom)) then exit;
        region0_read:=region0_5797_read;
        region1_read:=region1_5797_read;
        region1_write:=region1_5797_write;
        //Sound CPU
        if not(roms_load(memoria_temp,goldnaxe_sound)) then exit;
        copymemory(@mem_snd,@memoria_temp[0],$8000);
        for f:=0 to 7 do copymemory(@sound_bank[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
        sound_bank_calc:=system16b_sound_5797;
        //MCU
        if not(roms_load(mcs51_0.get_rom_addr,goldnaxe_mcu)) then exit;
        //tiles
        if not(roms_load(memoria_temp,goldnaxe_tiles)) then exit;
        convert_chars(4);
        s16_info.t_banks:=3;
        //Sprite ROM
        getmem(memoria_temp2,$200000);
        ptemp:=memoria_temp2;
        if not(roms_load16w(memoria_temp2,goldnaxe_sprites)) then exit;
        copymemory(@sprite_rom,ptemp,$40000);
        inc(ptemp,$20000);
        copymemory(@sprite_rom[$100000  shr 1],ptemp,$40000);
        inc(ptemp,$20000);
        copymemory(@sprite_rom[$40000 shr 1],ptemp,$40000);
        inc(ptemp,$20000);
        copymemory(@sprite_rom[$140000 shr 1],ptemp,$40000);
        inc(ptemp,$20000);
        copymemory(@sprite_rom[$80000 shr 1],ptemp,$40000);
        inc(ptemp,$20000);
        copymemory(@sprite_rom[$180000 shr 1],ptemp,$40000);
        freemem(memoria_temp2);
        s16_info.s_banks:=16;
        marcade.dswb:=$fd;
        marcade.dswb_val:=@goldnaxe_dip_b;
  end;
  294:begin  //Dynamite Dux
        //Main CPU
        m68000_0.change_ram16_calls(system16b_getword,system16b_putword_mcu);
        if not(roms_load16w(@rom,ddux_rom)) then exit;
        region0_read:=region0_5704_read;
        region1_read:=region1_5704_read;
        region2_write:=region2_5704_write;
        copymemory(@rom2,@rom[$40000 shr 1],$40000);
        //Sound CPU
        if not(roms_load(@mem_snd,ddux_sound)) then exit;
        sound_bank_calc:=system16b_sound_5704;
        //MCU
        if not(roms_load(mcs51_0.get_rom_addr,ddux_mcu)) then exit;
        //tiles
        if not(roms_load(memoria_temp,ddux_tiles)) then exit;
        convert_chars(2);
        s16_info.t_banks:=1;
        //Sprite ROM
        if not(roms_load16w(@sprite_rom,ddux_sprites)) then exit;
        s16_info.s_banks:=4;
        marcade.dswb:=$fe;
        marcade.dswb_val:=@ddux_dip_b;
  end;
  295:begin  //Eswat
        //Main CPU
        m68000_0.change_ram16_calls(system16b_getword,system16b_putword);
        if not(roms_load16w(@rom,eswat_rom)) then exit;
        region0_read:=region0_5797_read;
        region1_read:=region1_5797_read;
        region1_write:=region1_5797_write;
        //Sound CPU
        if not(roms_load(memoria_temp,eswat_sound)) then exit;
        copymemory(@mem_snd,@memoria_temp[0],$8000);
        for f:=0 to $f do copymemory(@sound_bank[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
        sound_bank_calc:=system16b_sound_5797;
        //tiles
        if not(roms_load(memoria_temp,eswat_tiles)) then exit;
        convert_chars(8);
        s16_info.t_banks:=7;
        //Sprite ROM
        getmem(memoria_temp2,$200000);
        ptemp:=memoria_temp2;
        if not(roms_load16w(memoria_temp2,eswat_sprites)) then exit;
        copymemory(@sprite_rom,ptemp,$40000);
        inc(ptemp,$20000);
        copymemory(@sprite_rom[$100000 shr 1],ptemp,$40000);
        inc(ptemp,$20000);
        copymemory(@sprite_rom[$40000 shr 1],ptemp,$40000);
        inc(ptemp,$20000);
        copymemory(@sprite_rom[$140000 shr 1],ptemp,$40000);
        inc(ptemp,$20000);
        copymemory(@sprite_rom[$80000 shr 1],ptemp,$40000);
        inc(ptemp,$20000);
        copymemory(@sprite_rom[$180000 shr 1],ptemp,$40000);
        freemem(memoria_temp2);
        s16_info.s_banks:=16;
        marcade.dswb:=$fd;
        marcade.dswb_val:=@eswat_dip_b;
  end;
  296:begin  //Passing Shot
        //Main CPU
        m68000_0.change_ram16_calls(system16b_getword,system16b_putword);
        if not(roms_load16w(@rom,passsht_rom)) then exit;
        region0_read:=region0_5358_read;
        //Sound CPU
        fillchar(memoria_temp^,$30000,0);
        if not(roms_load(memoria_temp,passsht_sound)) then exit;
        copymemory(@mem_snd,@memoria_temp[0],$8000);
        for f:=0 to 7 do copymemory(@sound_bank[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
        sound_bank_calc:=system16b_sound_5358;
        //tiles
        if not(roms_load(memoria_temp,passsht_tiles)) then exit;
        convert_chars(2);
        s16_info.t_banks:=1;
        //Sprite ROM
        if not(roms_load16w(@sprite_rom,passsht_sprites)) then exit;
        s16_info.s_banks:=3;
        marcade.dswb:=$fe;
        marcade.dswb_val:=@passsht_dip_b;
        //La placa 5358 usa un tipo diferente de banco de sprites!!
        s16_info.mb_type:=1;
  end;
  297:begin  //Aurail
        //Main CPU
        m68000_0.change_ram16_calls(system16b_getword,system16b_putword);
        if not(roms_load16w(@rom,aurail_rom)) then exit;
        region0_read:=region0_5704_read;
        region1_read:=region1_5704_read;
        region2_write:=region2_5704_write;
        copymemory(@rom2,@rom[$40000 shr 1],$40000);
        //Sound CPU
        if not(roms_load(memoria_temp,aurail_sound)) then exit;
        copymemory(@mem_snd,@memoria_temp[0],$8000);
        for f:=0 to 7 do copymemory(@sound_bank[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
        sound_bank_calc:=system16b_sound_5704;
        //tiles
        if not(roms_load(memoria_temp,aurail_tiles)) then exit;
        convert_chars(8);
        s16_info.t_banks:=7;
        //Sprite ROM
        if not(roms_load16w(@sprite_rom,aurail_sprites)) then exit;
        s16_info.s_banks:=16;
        marcade.dswb:=$fd;
        marcade.dswb_val:=@aurail_dip_b;
  end;
end;
freemem(memoria_temp);
//poner la paleta
compute_resistor_weights(0,255,-1.0,
  6,@resistances_normal[0],@weights[0],0,0,
  0,nil,nil,0,0,
  0,nil,nil,0,0);
compute_resistor_weights(0,255,-1.0,
  6,@resistances_sh[0],@weights[1],0,0,
  0,nil,nil,0,0,
  0,nil,nil,0,0);
for f:=0 to 31 do begin
  i4:=(f shr 4) and 1;
  i3:=(f shr 3) and 1;
  i2:=(f shr 2) and 1;
  i1:=(f shr 1) and 1;
  i0:=(f shr 0) and 1;
  s16_info.normal[f]:=combine_6_weights(@weights[0],i0,i1,i2,i3,i4,0);
  s16_info.shadow[f]:=combine_6_weights(@weights[1],i0,i1,i2,i3,i4,0);
  s16_info.hilight[f]:=combine_6_weights(@weights[1],i0,i1,i2,i3,i4,1);
end;
//final
reset_system16b;
iniciar_system16b:=true;
end;

end.
