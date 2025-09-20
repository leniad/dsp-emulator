unit system16a_hw;
interface

uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,m68000,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     ppi8255,sound_engine,ym_2151,fd1089,dialogs,mcs48,dac;

function iniciar_system16a:boolean;

implementation
const
        //Shinobi
        shinobi_rom:array[0..3] of tipo_roms=(
        (n:'epr-12010.43';l:$10000;p:0;crc:$7df7f4a2),(n:'epr-12008.26';l:$10000;p:$1;crc:$f5ae64cd),
        (n:'epr-12011.42';l:$10000;p:$20000;crc:$9d46e707),(n:'epr-12009.25';l:$10000;p:$20001;crc:$7961d07e));
        shinobi_sound:tipo_roms=(n:'epr-11267.12';l:$8000;p:0;crc:$dd50b745);
        shinobi_n7751:tipo_roms=(n:'7751.bin';l:$400;p:0;crc:$6a9534fc);
        shinobi_n7751_data:tipo_roms=(n:'epr-11268.1';l:$8000;p:0;crc:$6d7966da);
        shinobi_tiles:array[0..2] of tipo_roms=(
        (n:'epr-11264.95';l:$10000;p:0;crc:$46627e7d),(n:'epr-11265.94';l:$10000;p:$10000;crc:$87d0f321),
        (n:'epr-11266.93';l:$10000;p:$20000;crc:$efb4af87));
        shinobi_sprites:array[0..7] of tipo_roms=(
        (n:'epr-11290.10';l:$10000;p:0;crc:$611f413a),(n:'epr-11294.11';l:$10000;p:$1;crc:$5eb00fc1),
        (n:'epr-11291.17';l:$10000;p:$20000;crc:$3c0797c0),(n:'epr-11295.18';l:$10000;p:$20001;crc:$25307ef8),
        (n:'epr-11292.23';l:$10000;p:$40000;crc:$c29ac34e),(n:'epr-11296.24';l:$10000;p:$40001;crc:$04a437f8),
        (n:'epr-11293.29';l:$10000;p:$60000;crc:$41f41063),(n:'epr-11297.30';l:$10000;p:$60001;crc:$b6e1fd72));
        //Alex Kidd
        alexkid_rom:array[0..3] of tipo_roms=(
        (n:'epr-10447.43';l:$10000;p:0;crc:$29e87f71),(n:'epr-10445.26';l:$10000;p:$1;crc:$25ce5b6f),
        (n:'epr-10448.42';l:$10000;p:$20000;crc:$05baedb5),(n:'epr-10446.25';l:$10000;p:$20001;crc:$cd61d23c));
        alexkid_sound:tipo_roms=(n:'epr-10434.12';l:$8000;p:0;crc:$77141cce);
        alexkid_tiles:array[0..2] of tipo_roms=(
        (n:'epr-10431.95';l:$8000;p:0;crc:$a7962c39),(n:'epr-10432.94';l:$8000;p:$8000;crc:$db8cd24e),
        (n:'epr-10433.93';l:$8000;p:$10000;crc:$e163c8c2));
        alexkid_sprites:array[0..7] of tipo_roms=(
        (n:'epr-10437.10';l:$8000;p:0;crc:$522f7618),(n:'epr-10441.11';l:$8000;p:$1;crc:$74e3a35c),
        (n:'epr-10438.17';l:$8000;p:$10000;crc:$738a6362),(n:'epr-10442.18';l:$8000;p:$10001;crc:$86cb9c14),
        (n:'epr-10439.23';l:$8000;p:$20000;crc:$b391aca7),(n:'epr-10443.24';l:$8000;p:$20001;crc:$95d32635),
        (n:'epr-10440.29';l:$8000;p:$30000;crc:$23939508),(n:'epr-10444.30';l:$8000;p:$30001;crc:$82115823));
        alexkid_n7751_data:array[0..1] of tipo_roms=(
        (n:'epr-10435.1';l:$8000;p:0;crc:$ad89f6e3),(n:'epr-10436.2';l:$8000;p:$8000;crc:$96c76613));
        //Fantasy Zone
        fantzone_rom:array[0..5] of tipo_roms=(
        (n:'epr-7385a.43';l:$8000;p:0;crc:$4091af42),(n:'epr-7382a.26';l:$8000;p:$1;crc:$77d67bfd),
        (n:'epr-7386a.42';l:$8000;p:$10000;crc:$b0a67cd0),(n:'epr-7383a.25';l:$8000;p:$10001;crc:$5f79b2a9),
        (n:'epr-7387.41';l:$8000;p:$20000;crc:$0acd335d),(n:'epr-7384.24';l:$8000;p:$20001;crc:$fd909341));
        fantzone_sound:tipo_roms=(n:'epr-7535a.12';l:$8000;p:0;crc:$bc1374fa);
        fantzone_tiles:array[0..2] of tipo_roms=(
        (n:'epr-7388.95';l:$8000;p:0;crc:$8eb02f6b),(n:'epr-7389.94';l:$8000;p:$8000;crc:$2f4f71b8),
        (n:'epr-7390.93';l:$8000;p:$10000;crc:$d90609c6));
        fantzone_sprites:array[0..5] of tipo_roms=(
        (n:'epr-7392.10';l:$8000;p:0;crc:$5bb7c8b6),(n:'epr-7396.11';l:$8000;p:$1;crc:$74ae4b57),
        (n:'epr-7393.17';l:$8000;p:$10000;crc:$14fc7e82),(n:'epr-7397.18';l:$8000;p:$10001;crc:$e05a1e25),
        (n:'epr-7394.23';l:$8000;p:$20000;crc:$531ca13f),(n:'epr-7398.24';l:$8000;p:$20001;crc:$68807b49));
        //Alien Syndrome
        alien_rom:array[0..5] of tipo_roms=(
        (n:'epr-10804.43';l:$8000;p:0;crc:$23f78b83),(n:'epr-10802.26';l:$8000;p:$1;crc:$996768bd),
        (n:'epr-10805.42';l:$8000;p:$10000;crc:$53d7fe50),(n:'epr-10803.25';l:$8000;p:$10001;crc:$0536dd33),
        (n:'epr-10732.41';l:$8000;p:$20000;crc:$c5712bfc),(n:'epr-10729.24';l:$8000;p:$20001;crc:$3e520e30));
        alien_key:tipo_roms=(n:'317-0037.key';l:$2000;p:0;crc:$68bb7745);
        alien_sound:tipo_roms=(n:'epr-10705.12';l:$8000;p:0;crc:$777b749e);
        alien_tiles:array[0..2] of tipo_roms=(
        (n:'epr-10739.95';l:$10000;p:0;crc:$a29ec207),(n:'epr-10740.94';l:$10000;p:$10000;crc:$47f93015),
        (n:'epr-10741.93';l:$10000;p:$20000;crc:$4970739c));
        alien_sprites:array[0..7] of tipo_roms=(
        (n:'epr-10709.10';l:$10000;p:0;crc:$addf0a90),(n:'epr-10713.11';l:$10000;p:$1;crc:$ececde3a),
        (n:'epr-10710.17';l:$10000;p:$20000;crc:$992369eb),(n:'epr-10714.18';l:$10000;p:$20001;crc:$91bf42fb),
        (n:'epr-10711.23';l:$10000;p:$40000;crc:$29166ef6),(n:'epr-10715.24';l:$10000;p:$40001;crc:$a7c57384),
        (n:'epr-10712.29';l:$10000;p:$60000;crc:$876ad019),(n:'epr-10716.30';l:$10000;p:$60001;crc:$40ba1d48));
        alien_n7751_data:array[0..2] of tipo_roms=(
        (n:'epr-10706.1';l:$8000;p:0;crc:$aa114acc),(n:'epr-10707.2';l:$8000;p:$8000;crc:$800c1d82),
        (n:'epr-10708.4';l:$8000;p:$10000;crc:$5921ef52));
        //WB3
        wb3_rom:array[0..3] of tipo_roms=(
        (n:'epr-12120.43';l:$10000;p:0;crc:$cbd8c99b),(n:'epr-12118.26';l:$10000;p:$1;crc:$e9a3280c),
        (n:'epr-12121.42';l:$10000;p:$20000;crc:$5e44c0a9),(n:'epr-12119.25';l:$10000;p:$20001;crc:$01ed3ef9));
        wb3_key:tipo_roms=(n:'317-0086.key';l:$2000;p:0;crc:$5b8e7076);
        wb3_sound:tipo_roms=(n:'epr-12089.12';l:$8000;p:0;crc:$8321eb0b);
        wb3_tiles:array[0..2] of tipo_roms=(
        (n:'epr-12086.95';l:$10000;p:0;crc:$45b949df),(n:'epr-12087.94';l:$10000;p:$10000;crc:$6f0396b7),
        (n:'epr-12088.83';l:$10000;p:$20000;crc:$ba8c0749));
        wb3_sprites:array[0..7] of tipo_roms=(
        (n:'epr-12090.10';l:$10000;p:0;crc:$aeeecfca),(n:'epr-12094.11';l:$10000;p:$1;crc:$615e4927),
        (n:'epr-12091.17';l:$10000;p:$20000;crc:$8409a243),(n:'epr-12095.18';l:$10000;p:$20001;crc:$e774ec2c),
        (n:'epr-12092.23';l:$10000;p:$40000;crc:$5c2f0d90),(n:'epr-12096.24';l:$10000;p:$40001;crc:$0cd59d6e),
        (n:'epr-12093.29';l:$10000;p:$60000;crc:$4891e7bb),(n:'epr-12097.30';l:$10000;p:$60001;crc:$e645902c));
        //Tetris
        tetris_rom:array[0..1] of tipo_roms=(
        (n:'xepr12201.rom';l:$8000;p:1;crc:$343c0670),(n:'xepr12200.rom';l:$8000;p:$0;crc:$0b694740));
        tetris_key:tipo_roms=(n:'317-0093.key';l:$2000;p:0;crc:$e0064442);
        tetris_sound:tipo_roms=(n:'epr-12205.rom';l:$8000;p:0;crc:$6695dc99);
        tetris_tiles:array[0..2] of tipo_roms=(
        (n:'epr-12202.rom';l:$10000;p:0;crc:$2f7da741),(n:'epr-12203.rom';l:$10000;p:$10000;crc:$a6e58ec5),
        (n:'epr-12204.rom';l:$10000;p:$20000;crc:$0ae98e23));
        tetris_sprites:array[0..1] of tipo_roms=(
        (n:'epr-12169.b1';l:$8000;p:0;crc:$dacc6165),(n:'epr-12170.b5';l:$8000;p:$1;crc:$87354e42));
        //Dip
        system16a_dip_a:array [0..2] of def_dip=(
        (mask:$0f;name:'Coin A';number:16;dip:((dip_val:$7;dip_name:'4C/1C'),(dip_val:$8;dip_name:'3C/1C'),(dip_val:$9;dip_name:'2C/1C'),(dip_val:$5;dip_name:'2C/1C 5C/3C 6C/4C'),(dip_val:$4;dip_name:'2C/1C 4C/3C'),(dip_val:$f;dip_name:'1C/1C'),(dip_val:$3;dip_name:'1C/1C 5C/6C'),(dip_val:$2;dip_name:'1C/1C 4C/5C'),(dip_val:$1;dip_name:'1C/1C 2C/3C'),(dip_val:$6;dip_name:'2C/3C'),(dip_val:$e;dip_name:'1C/2C'),(dip_val:$d;dip_name:'1C/3C'),(dip_val:$c;dip_name:'1C/4C'),(dip_val:$b;dip_name:'1C/5C'),(dip_val:$a;dip_name:'1C/6C'),(dip_val:$0;dip_name:'Free Play (if Coin B too) or 1C/1C'))),
        (mask:$f0;name:'Coin B';number:16;dip:((dip_val:$70;dip_name:'4C/1C'),(dip_val:$80;dip_name:'3C/1C'),(dip_val:$90;dip_name:'2C/1C'),(dip_val:$50;dip_name:'2C/1C 5C/3C 6C/4C'),(dip_val:$40;dip_name:'2C/1C 4C/3C'),(dip_val:$f0;dip_name:'1C/1C'),(dip_val:$30;dip_name:'1C/1C 5C/6C'),(dip_val:$20;dip_name:'1C/1C 4C/5C'),(dip_val:$10;dip_name:'1C/1C 2C/3C'),(dip_val:$60;dip_name:'2C/3C'),(dip_val:$e0;dip_name:'1C/2C'),(dip_val:$d0;dip_name:'1C/3C'),(dip_val:$c0;dip_name:'1C/4C'),(dip_val:$b0;dip_name:'1C/5C'),(dip_val:$a0;dip_name:'1C/6C'),(dip_val:$00;dip_name:'Free Play (if Coin A too) or 1C/1C'))),());
        shinobi_dip_b:array [0..6] of def_dip=(
        (mask:$1;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$1;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2;name:'Demo Sounds';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Lives';number:4;dip:((dip_val:$8;dip_name:'2 Lives'),(dip_val:$c;dip_name:'3 Lives'),(dip_val:$4;dip_name:'5 Lives'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Difficulty';number:4;dip:((dip_val:$20;dip_name:'Easy'),(dip_val:$30;dip_name:'Normal'),(dip_val:$10;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Enemy''s Bullet Speed';number:2;dip:((dip_val:$40;dip_name:'Slow'),(dip_val:$0;dip_name:'Fast'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Lenguage';number:2;dip:((dip_val:$80;dip_name:'Japanese'),(dip_val:$0;dip_name:'English'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        alexkidd_dip_b:array [0..5] of def_dip=(
        (mask:$1;name:'Continue';number:2;dip:((dip_val:$1;dip_name:'Only before level 5'),(dip_val:$0;dip_name:'Unlimited'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2;name:'Demo Sounds';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Lives';number:4;dip:((dip_val:$c;dip_name:'3 Lives'),(dip_val:$8;dip_name:'4 Lives'),(dip_val:$4;dip_name:'5 Lives'),(dip_val:$0;dip_name:'240'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Bonus Life';number:4;dip:((dip_val:$20;dip_name:'10000'),(dip_val:$30;dip_name:'20000'),(dip_val:$10;dip_name:'40000'),(dip_val:$0;dip_name:'None'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Time Adjust';number:4;dip:((dip_val:$80;dip_name:'70'),(dip_val:$c0;dip_name:'60'),(dip_val:$40;dip_name:'50'),(dip_val:$0;dip_name:'40'),(),(),(),(),(),(),(),(),(),(),(),())),());
        fantzone_dip_b:array [0..5] of def_dip=(
        (mask:$1;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$1;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2;name:'Demo Sounds';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Lives';number:4;dip:((dip_val:$8;dip_name:'2 Lives'),(dip_val:$c;dip_name:'3 Lives'),(dip_val:$4;dip_name:'4 Lives'),(dip_val:$0;dip_name:'240'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Extra Ship Cost';number:4;dip:((dip_val:$30;dip_name:'5000'),(dip_val:$20;dip_name:'10000'),(dip_val:$10;dip_name:'15000'),(dip_val:$0;dip_name:'20000'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Difficulty';number:4;dip:((dip_val:$80;dip_name:'Easy'),(dip_val:$c0;dip_name:'Normal'),(dip_val:$40;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),());
        aliensynd_dip_b:array [0..4] of def_dip=(
        (mask:$2;name:'Demo Sounds';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Lives';number:4;dip:((dip_val:$8;dip_name:'2 Lives'),(dip_val:$c;dip_name:'3 Lives'),(dip_val:$4;dip_name:'4 Lives'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Timer';number:4;dip:((dip_val:$0;dip_name:'120'),(dip_val:$10;dip_name:'130'),(dip_val:$20;dip_name:'140'),(dip_val:$30;dip_name:'150'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Difficulty';number:4;dip:((dip_val:$80;dip_name:'Easy'),(dip_val:$c0;dip_name:'Normal'),(dip_val:$40;dip_name:'Hard'),(dip_val:$0;dip_name:'Very Hard'),(),(),(),(),(),(),(),(),(),(),(),())),());
        wb3_dip_b:array [0..5] of def_dip=(
        (mask:$2;name:'Demo Sounds';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Lives';number:4;dip:((dip_val:$0;dip_name:'2 Lives'),(dip_val:$c;dip_name:'3 Lives'),(dip_val:$8;dip_name:'4 Lives'),(dip_val:$8;dip_name:'5 Lives'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Bonus Life';number:2;dip:((dip_val:$10;dip_name:'50k/100k/180k/300k'),(dip_val:$0;dip_name:'50k/150k/300k'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Difficulty';number:2;dip:((dip_val:$20;dip_name:'Normal'),(dip_val:$0;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Test Mode';number:2;dip:((dip_val:$40;dip_name:'No'),(dip_val:$0;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        tetris_dip_b:array [0..2] of def_dip=(
        (mask:$2;name:'Demo Sounds';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Difficulty';number:4;dip:((dip_val:$20;dip_name:'Easy'),(dip_val:$30;dip_name:'Normal'),(dip_val:$10;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),());
        CPU_SYNC=4;
type
  tsystem16_info=record
    	normal,shadow,hilight:array[0..31] of byte;
      banks:byte;
      screen:array[0..7] of byte;
      screen_enabled:boolean;
      tile_buffer:array[0..7,0..$7ff] of boolean;
   end;
var
 rom,rom_data:array[0..$1ffff] of word;
 ram:array[0..$1fff] of word;
 tile_ram:array[0..$3fff] of word;
 char_ram:array[0..$7ff] of word;
 sprite_ram:array[0..$3ff] of word;
 sprite_rom:array[0..$3ffff] of word;
 sprite_bank:array[0..$f] of byte;
 n7751_data:array[0..$17fff]of byte;
 s16_info:tsystem16_info;
 n7751_numroms,sound_latch,n7751_command:byte;
 n7751_rom_address:dword;

procedure draw_sprites(pri:byte);
var
  sprpri:byte;
  f:integer;
  bottom,top:word;
  addr,bank,y,pix,data_7,pixels,color:word;
  x,xpos,pitch:integer;
  spritedata:dword;
procedure system16a_draw_pixel(x,y,pix:word);
var
  punt,punt2,temp1,temp2,temp3:word;
begin
  //only draw if onscreen, not 0 or 15
	if ((x<320) and ((pix and $f)<>0) and ((pix and $f)<>15)) then begin
      if (pix and $3f0)=$3f0 then begin //Shadow
          punt:=getpixel(x+ADD_SPRITE,y+ADD_SPRITE,7);
          punt2:=paleta[$1000];
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
    sprpri:=(sprite_ram[(f*8)+4] and $ff) and $3;
    if sprpri<>pri then continue;
    addr:=sprite_ram[(f*8)+3];
    sprite_ram[(f*8)+7]:=addr;
    bottom:=(sprite_ram[f*8] shr 8)+1;
    if bottom>$f0 then break;
    bank:=sprite_bank[(sprite_ram[(f*8)+4] shr 4) and $7];
    top:=(sprite_ram[f*8] and $ff)+1;
    // if hidden, or top greater than/equal to bottom, or invalid bank
		if ((top>=bottom) or (bank=255)) then continue;
		xpos:=(sprite_ram[(f*8)+1] and $1ff)-$bd;
		pitch:=smallint(sprite_ram[(f*$8)+2]);
		color:=((sprite_ram[(f*8)+4] shr 8) and $3f) shl 4;
		// clamp to within the memory region size
		spritedata:=$8000*(bank mod s16_info.banks);
		// loop from top to bottom
		for y:=top to (bottom-1) do begin
			// advance a row
			addr:=addr+pitch;
			// skip drawing if not within the cliprect
			if (y<256) then begin
				// note that the System 16A sprites have a design flaw that allows the address
				// to carry into the flip flag, which is the topmost bit -- it is very important
				// to emulate this as the games compensate for it
				// non-flipped case
				if (addr and $8000)=0 then begin
          data_7:=addr;
					x:=xpos;
          while (x<512) do begin
						pixels:=sprite_rom[spritedata+(data_7 and $7fff)];
						// draw four pixels
						pix:=(pixels shr 12) and $f;
            system16a_draw_pixel(x,y,pix or color);
						pix:=(pixels shr 8) and $f;
            system16a_draw_pixel(x+1,y,pix or color);
						pix:=(pixels shr 4) and $f;
            system16a_draw_pixel(x+2,y,pix or color);
						pix:=(pixels shr 0) and $f;
            system16a_draw_pixel(x+3,y,pix or color);
            x:=x+4;
						// stop if the last pixel in the group was 0xf
						if (pix=15) then begin
              sprite_ram[(f*8)+7]:=data_7;
              break;
            end else data_7:=data_7+1;
					end;
				end else begin
				// flipped case
          data_7:=addr;
					x:=xpos;
          while (x<512) do begin
						pixels:=sprite_rom[spritedata+(data_7 and $7fff)];
						// draw four pixels
						pix:=(pixels shr 0) and $f;
            system16a_draw_pixel(x,y,pix or color);
						pix:=(pixels shr 4) and $f;
            system16a_draw_pixel(x+1,y,pix or color);
						pix:=(pixels shr 8) and $f;
            system16a_draw_pixel(x+2,y,pix or color);
						pix:=(pixels shr 12) and $f;
            system16a_draw_pixel(x+3,y,pix or color);
            x:=x+4;
						// stop if the last pixel in the group was 0xf
						if (pix=15) then begin
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
  pos,f,nchar,color,data:word;
  x,y:word;
begin
  pos:=s16_info.screen[num]*$800;
  for f:=$0 to $7ff do begin
    data:=tile_ram[pos+f];
    color:=(data shr 5) and $7f;
    if (s16_info.tile_buffer[num,f] or buffer_color[color]) then begin
      x:=((f and $3f) shl 3)+px;
      y:=((f shr 6) shl 3)+py;
      nchar:=((data shr 1) and $1000) or (data and $fff);
      if trans then put_gfx_trans(x,y,nchar,color shl 3,scr,0)
        else put_gfx(x,y,nchar,color shl 3,scr,0);
      if (data and $1000)<>0 then put_gfx_trans(x,y,nchar,color shl 3,scr+1,0)
          else put_gfx_block_trans(x,y,scr+1,8,8);
      s16_info.tile_buffer[num,f]:=false;
    end;
  end;
end;

procedure update_video_system16a;
var
  f,nchar,color,scroll_x1,scroll_x2,x,y,atrib:word;
  scroll_y1,scroll_y2:byte;
begin
if not(s16_info.screen_enabled) then begin
  fill_full_screen(7,$1fff);
  actualiza_trozo_final(0,0,320,224,7);
  exit;
end;
//Background
draw_tiles(0,0,256,3,false);
draw_tiles(1,512,256,3,false);
draw_tiles(2,0,0,3,false);
draw_tiles(3,512,0,3,false);
scroll_x1:=char_ram[$7fd] and $1ff;
scroll_x1:=($c8-scroll_x1) and $3ff;
scroll_y1:=char_ram[$793] and $ff;
//Foreground
draw_tiles(4,0,256,5,true);
draw_tiles(5,512,256,5,true);
draw_tiles(6,0,0,5,true);
draw_tiles(7,512,0,5,true);
scroll_x2:=char_ram[$7fc] and $1ff;
scroll_x2:=($c8-scroll_x2) and $3ff;
scroll_y2:=char_ram[$792] and $ff;
//text
for f:=$0 to $6ff do begin
  atrib:=char_ram[f];
  color:=(atrib shr 8) and $7;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
    x:=(f and $3f) shl 3;
    y:=(f shr 6) shl 3;
    nchar:=atrib and $ff;
    put_gfx_trans(x,y,nchar,color shl 3,1,0);
    if (atrib and $800)<>0 then put_gfx_trans(x,y,nchar,color shl 3,2,0)
      else put_gfx_block_trans(x,y,2,8,8);
    gfx[0].buffer[f]:=false;

  end;
end;
//Lo pongo todo con prioridades, falta scrollrow y scrollcol!!
scroll_x_y(3,7,scroll_x1,scroll_y1); //0
draw_sprites(0);
scroll_x_y(4,7,scroll_x1,scroll_y1); //1
draw_sprites(1);
scroll_x_y(5,7,scroll_x2,scroll_y2); //2
draw_sprites(2);
scroll_x_y(6,7,scroll_x2,scroll_y2);  //2
actualiza_trozo(192,0,320,224,1,0,0,320,224,7); //4
draw_sprites(3);
actualiza_trozo(192,0,320,224,2,0,0,320,224,7); //8
//Y lo pinto a la pantalla principal
actualiza_trozo_final(0,0,320,224,7);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
end;

procedure eventos_system16a;
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
  //P2
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $ffdf) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $ffef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $ff7f) else marcade.in2:=(marcade.in2 or $80);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $ffbf) else marcade.in2:=(marcade.in2 or $40);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $fffb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $fffd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.but2[1] then marcade.in2:=(marcade.in2 and $fffe) else marcade.in2:=(marcade.in2 or $1);
  //Service
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $ffef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $ffdf) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fffe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fffd) else marcade.in0:=(marcade.in0 or $2);
end;
end;

procedure system16a_principal_adpcm;
var
  frame_m,frame_s,frame_s_sub:single;
  f:word;
  h:byte;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
frame_s:=z80_0.tframes;
frame_s_sub:=mcs48_0.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to 261 do begin
     for h:=1 to CPU_SYNC do begin
        //main
        m68000_0.run(frame_m);
        frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
        //sound
        z80_0.run(frame_s);
        frame_s:=frame_s+z80_0.tframes-z80_0.contador;
        //sound sub cpu
        mcs48_0.run(frame_s_sub);
        frame_s_sub:=frame_s_sub+mcs48_0.tframes-mcs48_0.contador;
     end;
     if f=223 then begin
       m68000_0.irq[4]:=HOLD_LINE;
       update_video_system16a;
     end;
  end;
  eventos_system16a;
  video_sync;
end;
end;

procedure system16a_principal;
var
  frame_m,frame_s:single;
  f:word;
  h:byte;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
frame_s:=z80_0.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to 261 do begin
    for h:=1 to CPU_SYNC do begin
     //main
     m68000_0.run(frame_m);
     frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
     //sound
     z80_0.run(frame_s);
     frame_s:=frame_s+z80_0.tframes-z80_0.contador;
    end;
    if f=223 then begin
       m68000_0.irq[4]:=HOLD_LINE;
       update_video_system16a;
    end;
  end;
  eventos_system16a;
  video_sync;
end;
end;

function standar_s16_io_r(direccion:word):word;
var
  res:word;
begin
case (direccion and $3000) of
	$0000:res:=pia8255_0.read((direccion shr 1) and 3);
	$1000:case (direccion and 7) of
          0,1:res:=marcade.in0; //SERVICE
          2,3:res:=marcade.in1; //P1
          4,5:res:=$ff; //UNUSED
          6,7:res:=marcade.in2; //P2
       end;
  $2000:case (direccion and $3) of
          0,1:res:=marcade.dswa; //DSW1
          2,3:res:=marcade.dswb; //DSW2
        end;
  else res:=$ffff;
end;
standar_s16_io_r:=res;
end;

function system16a_getword(direccion:dword):word;
begin
case direccion of
    0..$3fffff:system16a_getword:=rom[(direccion and $3ffff) shr 1];
    $400000..$7fffff:case (direccion and $7ffff) of
                        $00000..$0ffff:system16a_getword:=tile_ram[(direccion and $7fff) shr 1];
                        $10000..$1ffff:system16a_getword:=char_ram[(direccion and $fff) shr 1];
                        $40000..$7ffff:system16a_getword:=sprite_ram[(direccion and $7ff) shr 1];
                          else system16a_getword:=$ffff;
                     end;
    $800000..$bfffff:case (direccion and $fffff) of
                        $40000..$7ffff:system16a_getword:=buffer_paleta[(direccion and $fff) shr 1];
                          else system16a_getword:=$ffff;
                     end;
    $c00000..$ffffff:case (direccion and $7ffff) of
                        $00000..$0ffff:system16a_getword:=tile_ram[(direccion and $7fff) shr 1];
                        $10000..$1ffff:system16a_getword:=char_ram[(direccion and $fff) shr 1];
                        $40000..$5ffff:system16a_getword:=standar_s16_io_r(direccion and $3fff);  //misc_io
                        $60000..$6ffff:system16a_getword:=$ffff;  //watch dog
                        $70000..$7ffff:system16a_getword:=ram[(direccion and $3fff) shr 1];
    end;
end;
end;

function system16a_getword_fd1089(direccion:dword):word;
begin
case direccion of
    0..$3fffff:if m68000_0.opcode then system16a_getword_fd1089:=rom[(direccion and $3ffff) shr 1]
                  else system16a_getword_fd1089:=rom_data[(direccion and $3ffff) shr 1];
    else system16a_getword_fd1089:=system16a_getword(direccion);
end;
end;

procedure test_screen_change(direccion:word);
var
  tmp:byte;
begin
if direccion=$74e then begin
          //Background abajo 1-2
          tmp:=(char_ram[$74e] shr 12) and $7;
          if tmp<>s16_info.screen[0] then begin
            s16_info.screen[0]:=tmp;
            fillchar(s16_info.tile_buffer[0,0],$800,1);
          end;
          tmp:=(char_ram[$74e] shr 8) and $7;
          if tmp<>s16_info.screen[1] then begin
            s16_info.screen[1]:=tmp;
            fillchar(s16_info.tile_buffer[1,0],$800,1);
          end;
            //Background arriba 1-2
          tmp:=(char_ram[$74e] shr 4) and $7;
          if tmp<>s16_info.screen[2] then begin
            s16_info.screen[2]:=tmp;
            fillchar(s16_info.tile_buffer[2,0],$800,1);
          end;
          tmp:=char_ram[$74e] and $7;
          if tmp<>s16_info.screen[3] then begin
            s16_info.screen[3]:=tmp;
            fillchar(s16_info.tile_buffer[3,0],$800,1);
          end;
end;
if direccion=$74f then begin
            //Foreground abajo
          tmp:=(char_ram[$74f] shr 12) and $7;
          if tmp<>s16_info.screen[4] then begin
            s16_info.screen[4]:=tmp;
            fillchar(s16_info.tile_buffer[4,0],$800,1);
          end;
          tmp:=(char_ram[$74f] shr 8) and $7;
          if tmp<>s16_info.screen[5] then begin
            s16_info.screen[5]:=tmp;
            fillchar(s16_info.tile_buffer[5,0],$800,1);
          end;
            //Foreground arriba
          tmp:=(char_ram[$74f] shr 4) and $7;
          if tmp<>s16_info.screen[6] then begin
            s16_info.screen[6]:=tmp;
            fillchar(s16_info.tile_buffer[6,0],$800,1);
          end;
          tmp:=char_ram[$74f] and $7;
          if tmp<>s16_info.screen[7] then begin
            s16_info.screen[7]:=tmp;
            fillchar(s16_info.tile_buffer[7,0],$800,1);
          end;
end;
end;

procedure change_pal(direccion:word);
var
	val:word;
  color:tcolor;
  r,g,b:integer;
begin
	// get the new value
  val:=buffer_paleta[direccion];
	//     byte 0    byte 1
	//  sBGR BBBB GGGG RRRR
	//  x000 4321 4321 4321
	r:=((val shr 12) and $01) or ((val shl 1) and $1e);
	g:=((val shr 13) and $01) or ((val shr 3) and $1e);
	b:=((val shr 14) and $01) or ((val shr 7) and $1e);
  //normal
  color.r:=s16_info.normal[r];
  color.g:=s16_info.normal[g];
  color.b:=s16_info.normal[b];
  set_pal_color(color,direccion);
  //shadow
  color.r:=s16_info.shadow[r];
  color.g:=s16_info.shadow[g];
  color.b:=s16_info.shadow[b];
  set_pal_color(color,direccion+$800);
  //hilight
  color.r:=s16_info.hilight[r];
  color.g:=s16_info.hilight[g];
  color.b:=s16_info.hilight[b];
  set_pal_color(color,direccion+$1000);
  //Buffer
  buffer_color[(direccion shr 3) and $7f]:=true;
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

procedure system16a_putword(direccion:dword;valor:word);
begin
case direccion of
    0..$3ffff:;
    $400000..$7fffff:case (direccion and $7ffff) of
                        $00000..$0ffff:if tile_ram[(direccion and $7fff) shr 1]<>valor then begin
                                        tile_ram[(direccion and $7fff) shr 1]:=valor;
                                        test_tile_buffer((direccion and $7fff) shr 1);
                                       end;
                        $10000..$1ffff:if char_ram[(direccion and $fff) shr 1]<>valor then begin
                                          char_ram[(direccion and $fff) shr 1]:=valor;
                                          gfx[0].buffer[(direccion and $fff) shr 1]:=true;
                                          test_screen_change((direccion and $fff) shr 1);
                                       end;
                        $40000..$7ffff:sprite_ram[(direccion and $7ff) shr 1]:=valor;
                     end;
    $800000..$bfffff:case (direccion and $fffff) of
                        $40000..$7ffff:if (buffer_paleta[(direccion and $fff) shr 1]<>valor) then begin
                                          buffer_paleta[(direccion and $fff) shr 1]:=valor;
                                          change_pal((direccion and $fff) shr 1);
                                       end;
                   end;
    $c00000..$ffffff:case (direccion and $7ffff) of
                        $00000..$0ffff:if tile_ram[(direccion and $7fff) shr 1]<>valor then begin
                                        tile_ram[(direccion and $7fff) shr 1]:=valor;
                                        test_tile_buffer((direccion and $7fff) shr 1);
                                       end;
                        $10000..$1ffff:begin
                                          if char_ram[(direccion and $fff) shr 1]<>valor then begin
                                            char_ram[(direccion and $fff) shr 1]:=valor;
                                            gfx[0].buffer[(direccion and $fff) shr 1]:=true;
                                          end;
                                          test_screen_change((direccion and $fff) shr 1);
                                       end;
                        $40000..$5ffff:if (direccion and $3000)=0 then pia8255_0.write((direccion shr 1) and $3,valor and $ff);
                        $70000..$7ffff:begin
                                          ram[(direccion and $3fff) shr 1]:=valor;
                                          if ((direccion and $3fff) shr 1)=$38 then sound_latch:=valor;
                                       end;
                     end;
  end;
end;

function system16a_snd_getbyte(direccion:word):byte;
var
  res:byte;
begin
res:=$ff;
case direccion of
  $0..$7fff,$f800..$ffff:res:=mem_snd[direccion];
  $e800:begin
          pia8255_0.set_port(2,0);
          res:=sound_latch;
        end;
end;
system16a_snd_getbyte:=res;
end;

procedure system16a_snd_putbyte(direccion:word;valor:byte);
begin
if direccion>$f7ff then mem_snd[direccion]:=valor;
end;

function system16a_snd_inbyte(puerto:word):byte;
var
  res:byte;
begin
res:=$ff;
case (puerto and $ff) of
  $00..$3f:if (puerto and 1)<>0 then res:=ym2151_0.status;
  $c0..$ff:begin
              pia8255_0.set_port(2,0);
              res:=sound_latch;
           end;
end;
system16a_snd_inbyte:=res;
end;

procedure system16a_snd_outbyte(puerto:word;valor:byte);
begin
case (puerto and $ff) of
  $00..$3f:case (puerto and 1) of
              0:ym2151_0.reg(valor);
              1:ym2151_0.write(valor);
           end;
  $80..$bf:;
end;
end;

procedure system16a_snd_outbyte_adpcm(puerto:word;valor:byte);
begin
case (puerto and $ff) of
  $00..$3f:case (puerto and 1) of
              0:ym2151_0.reg(valor);
              1:ym2151_0.write(valor);
           end;
  $80..$bf:begin
              n7751_rom_address:=n7751_rom_address and $3fff;
	            n7751_rom_address:=n7751_rom_address or ((valor and 1) shl 14);
              if (((valor and $4)=0) and (n7751_numroms>=2)) then n7751_rom_address:=n7751_rom_address or $08000;
              if (((valor and $8)=0) and (n7751_numroms>=3)) then n7751_rom_address:=n7751_rom_address or $10000;
              if (((valor and $10)=0) and (n7751_numroms>=4)) then n7751_rom_address:=n7751_rom_address or $18000;
              n7751_command:=valor shr 5;
           end;
end;
end;

procedure ppi8255_wporta(valor:byte);
begin
  sound_latch:=valor;
end;

procedure ppi8255_wportb(valor:byte);
begin
  s16_info.screen_enabled:=(valor and $10)<>0;
end;

procedure ppi8255_wportc(valor:byte);
begin
if (valor and $80)<>0 then z80_0.change_nmi(CLEAR_LINE)
  else z80_0.change_nmi(ASSERT_LINE);
end;

procedure system16a_sound_adpcm;
begin
  ym2151_0.update;
  dac_0.update;
end;

procedure system16a_sound_update;
begin
  ym2151_0.update;
end;

procedure ym2151_snd_port(valor:byte);
begin
if (valor and $1)<>0 then mcs48_0.change_reset(CLEAR_LINE)
  else mcs48_0.change_reset(ASSERT_LINE);
if (valor and $2)<>0 then mcs48_0.change_irq(CLEAR_LINE)
  else mcs48_0.change_irq(ASSERT_LINE);
end;

//Sub sound cpu
function system16a_sound_inport(puerto:word):byte;
begin
case puerto of
  MCS48_PORT_BUS:system16a_sound_inport:=n7751_data[n7751_rom_address];
  MCS48_PORT_T1:system16a_sound_inport:=0;
  MCS48_PORT_P2:system16a_sound_inport:=$80 or ((n7751_command and $07) shl 4) or (mcs48_0.i8243.p2_r and $f);
end;
end;

procedure system16a_sound_outport(puerto:word;valor:byte);
begin
case puerto of
  MCS48_PORT_P1:dac_0.data8_w(valor);
  MCS48_PORT_P2:mcs48_0.i8243.p2_w(valor and $f);
  MCS48_PORT_PROG:mcs48_0.i8243.prog_w(valor);
end;
end;

procedure n7751_rom_offset_w(puerto:word;valor:byte);
var
  mask,newdata:dword;
begin
	// P4 - address lines 0-3
	// P5 - address lines 4-7
	// P6 - address lines 8-11
	// P7 - address lines 12-13
	mask:=($f shl (4*puerto)) and $3fff;
	newdata:=(valor shl (4*puerto)) and mask;
	n7751_rom_address:=(n7751_rom_address and not(mask)) or newdata;
end;

//Main
procedure reset_system16a;
var
  f:byte;
begin
 m68000_0.reset;
 z80_0.reset;
 ym2151_0.reset;
 pia8255_0.reset;
 if ((main_vars.tipo_maquina=114) or (main_vars.tipo_maquina=115) or (main_vars.tipo_maquina=186)) then mcs48_0.reset;
 reset_audio;
 marcade.in0:=$ffff;
 marcade.in1:=$ffff;
 marcade.in2:=$ffff;
 for f:=0 to $f do sprite_bank[f]:=f;
 s16_info.screen_enabled:=true;
 fillchar(s16_info.tile_buffer,$4000,1);
 sound_latch:=0;
 n7751_rom_address:=0;
end;

function iniciar_system16a:boolean;
var
  f:word;
  memoria_temp:array[0..$7ffff] of byte;
  fd1089_key:array[0..$1fff] of byte;
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
convert_gfx(0,0,@memoria_temp[0],@pt_x[0],@pt_y[0],false,false);
end;
begin
llamadas_maquina.reset:=reset_system16a;
iniciar_system16a:=false;
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
iniciar_video(320,224);
//Main CPU
m68000_0:=cpu_m68000.create(10000000,262*CPU_SYNC);
//Sound CPU
z80_0:=cpu_z80.create(4000000,262*CPU_SYNC);
z80_0.change_ram_calls(system16a_snd_getbyte,system16a_snd_putbyte);
//PPI 825
pia8255_0:=pia8255_chip.create;
pia8255_0.change_ports(nil,nil,nil,ppi8255_wporta,ppi8255_wportb,ppi8255_wportc);
if ((main_vars.tipo_maquina=114) or (main_vars.tipo_maquina=115) or (main_vars.tipo_maquina=186)) then begin
  z80_0.change_io_calls(system16a_snd_inbyte,system16a_snd_outbyte_adpcm);
  z80_0.init_sound(system16a_sound_adpcm);
  ym2151_0:=ym2151_chip.create(4000000);
  ym2151_0.change_port_func(ym2151_snd_port);
  //Creo el segundo chip de sonido
  mcs48_0:=cpu_mcs48.create(6000000,262*CPU_SYNC,N7751);
  mcs48_0.change_io_calls(system16a_sound_inport,system16a_sound_outport);
  mcs48_0.i8243.change_calls(nil,n7751_rom_offset_w);
  dac_0:=dac_chip.Create(1);
end else begin
  z80_0.change_io_calls(system16a_snd_inbyte,system16a_snd_outbyte);
  z80_0.init_sound(system16a_sound_update);
  ym2151_0:=ym2151_chip.create(4000000);
end;
//DIP
marcade.dswa:=$ff;
marcade.dswa_val:=@system16a_dip_a;
case main_vars.tipo_maquina of
  114:begin  //Shinobi
        llamadas_maquina.bucle_general:=system16a_principal_adpcm;
        n7751_numroms:=1;
        if not(roms_load(mcs48_0.get_rom_addr,shinobi_n7751)) then exit;
        if not(roms_load(@n7751_data,shinobi_n7751_data)) then exit;
        //Main CPU
        m68000_0.change_ram16_calls(system16a_getword,system16a_putword);
        //cargar roms
        if not(roms_load16w(@rom,shinobi_rom)) then exit;
        //cargar sonido
        if not(roms_load(@mem_snd,shinobi_sound)) then exit;
        //convertir tiles
        if not(roms_load(@memoria_temp,shinobi_tiles)) then exit;
        convert_chars(2);
        //Cargar ROM de los sprites y recolocarlos
        if not(roms_load16b(@memoria_temp,shinobi_sprites)) then exit;
        for f:=0 to 7 do begin
          copymemory(@sprite_rom[0],@memoria_temp[0],$10000);
          copymemory(@sprite_rom[$20000],@memoria_temp[$10000],$10000);
          copymemory(@sprite_rom[$8000],@memoria_temp[$20000],$10000);
          copymemory(@sprite_rom[$28000],@memoria_temp[$30000],$10000);
          copymemory(@sprite_rom[$10000],@memoria_temp[$40000],$10000);
          copymemory(@sprite_rom[$30000],@memoria_temp[$50000],$10000);
          copymemory(@sprite_rom[$18000],@memoria_temp[$60000],$10000);
          copymemory(@sprite_rom[$38000],@memoria_temp[$70000],$10000);
        end;
        s16_info.banks:=8;
        marcade.dswb:=$fc;
        marcade.dswb_val:=@shinobi_dip_b;
  end;
  115:begin //Alex Kid
        llamadas_maquina.bucle_general:=system16a_principal_adpcm;
        n7751_numroms:=2;
        if not(roms_load(mcs48_0.get_rom_addr,shinobi_n7751)) then exit;
        if not(roms_load(@n7751_data,alexkid_n7751_data)) then exit;
        m68000_0.change_ram16_calls(system16a_getword,system16a_putword);
        //cargar roms
        if not(roms_load16w(@rom,alexkid_rom)) then exit;
        //cargar sonido
        if not(roms_load(@mem_snd,alexkid_sound)) then exit;
        //convertir tiles
        if not(roms_load(@memoria_temp,alexkid_tiles)) then exit;
        convert_chars(1);
        //Cargar ROM de los sprites
        if not(roms_load16b(@sprite_rom,alexkid_sprites)) then exit;
        s16_info.banks:=4;
        marcade.dswb:=$fc;
        marcade.dswb_val:=@alexkidd_dip_b;
  end;
  116:begin //Fantasy Zone
        llamadas_maquina.bucle_general:=system16a_principal;
        m68000_0.change_ram16_calls(system16a_getword,system16a_putword);
        //cargar roms
        if not(roms_load16w(@rom,fantzone_rom)) then exit;
        //cargar sonido
        if not(roms_load(@mem_snd,fantzone_sound)) then exit;
        //convertir tiles
        if not(roms_load(@memoria_temp,fantzone_tiles)) then exit;
        convert_chars(1);
        //Cargar ROM de los sprites
        if not(roms_load16b(@sprite_rom,fantzone_sprites)) then exit;
        s16_info.banks:=4;
        marcade.dswb:=$fc;
        marcade.dswb_val:=@fantzone_dip_b;
  end;
  186:begin //Alien Syndrome
        llamadas_maquina.bucle_general:=system16a_principal_adpcm;
        n7751_numroms:=3;
        if not(roms_load(mcs48_0.get_rom_addr,shinobi_n7751)) then exit;
        if not(roms_load(@n7751_data,alien_n7751_data)) then exit;
        m68000_0.change_ram16_calls(system16a_getword_fd1089,system16a_putword);
        //cargar roms
        if not(roms_load16w(@memoria_temp,alien_rom)) then exit;
        //Decode fd1089
        if not(roms_load(@fd1089_key,alien_key)) then exit;
        fd1089_decrypt($40000,@memoria_temp,@rom,@rom_data,@fd1089_key,fd_typeB);
        //cargar sonido
        if not(roms_load(@mem_snd,alien_sound)) then exit;
        //convertir tiles
        if not(roms_load(@memoria_temp,alien_tiles)) then exit;
        convert_chars(2);
        //Cargar ROM de los sprites y recolocarlos
        if not(roms_load16b(@memoria_temp,alien_sprites)) then exit;
        for f:=0 to 7 do begin
          copymemory(@sprite_rom[0],@memoria_temp[0],$10000);
          copymemory(@sprite_rom[$20000],@memoria_temp[$10000],$10000);
          copymemory(@sprite_rom[$8000],@memoria_temp[$20000],$10000);
          copymemory(@sprite_rom[$28000],@memoria_temp[$30000],$10000);
          copymemory(@sprite_rom[$10000],@memoria_temp[$40000],$10000);
          copymemory(@sprite_rom[$30000],@memoria_temp[$50000],$10000);
          copymemory(@sprite_rom[$18000],@memoria_temp[$60000],$10000);
          copymemory(@sprite_rom[$38000],@memoria_temp[$70000],$10000);
        end;
        s16_info.banks:=8;
        marcade.dswb:=$fd;
        marcade.dswb_val:=@aliensynd_dip_b;
  end;
  187:begin //WB3
        llamadas_maquina.bucle_general:=system16a_principal;
        m68000_0.change_ram16_calls(system16a_getword_fd1089,system16a_putword);
        //cargar roms
        if not(roms_load16w(@memoria_temp,wb3_rom)) then exit;
        //Decode fd1089
        if not(roms_load(@fd1089_key,wb3_key)) then exit;
        fd1089_decrypt($40000,@memoria_temp,@rom,@rom_data,@fd1089_key,fd_typeA);
        //cargar sonido
        if not(roms_load(@mem_snd,wb3_sound)) then exit;
        //convertir tiles
        if not(roms_load(@memoria_temp,wb3_tiles)) then exit;
        convert_chars(2);
        //Cargar ROM de los sprites y recolocarlos
        if not(roms_load16b(@memoria_temp,wb3_sprites)) then exit;
        for f:=0 to 7 do begin
          copymemory(@sprite_rom[0],@memoria_temp[0],$10000);
          copymemory(@sprite_rom[$20000],@memoria_temp[$10000],$10000);
          copymemory(@sprite_rom[$8000],@memoria_temp[$20000],$10000);
          copymemory(@sprite_rom[$28000],@memoria_temp[$30000],$10000);
          copymemory(@sprite_rom[$10000],@memoria_temp[$40000],$10000);
          copymemory(@sprite_rom[$30000],@memoria_temp[$50000],$10000);
          copymemory(@sprite_rom[$18000],@memoria_temp[$60000],$10000);
          copymemory(@sprite_rom[$38000],@memoria_temp[$70000],$10000);
        end;
        s16_info.banks:=8;
        marcade.dswb:=$7c;
        marcade.dswb_val:=@wb3_dip_b;
  end;
  198:begin //Tetris
        llamadas_maquina.bucle_general:=system16a_principal;
        m68000_0.change_ram16_calls(system16a_getword,system16a_putword);
        //cargar roms
        if not(roms_load16w(@rom,tetris_rom)) then exit;
        //cargar sonido
        if not(roms_load(@mem_snd,tetris_sound)) then exit;
        //convertir tiles
        if not(roms_load(@memoria_temp,tetris_tiles)) then exit;
        convert_chars(2);
        //Cargar ROM de los sprites
        if not(roms_load16b(@sprite_rom,tetris_sprites)) then exit;
        s16_info.banks:=1;
        marcade.dswb:=$30;
        marcade.dswb_val:=@tetris_dip_b;
  end;
end;
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
reset_system16a;
iniciar_system16a:=true;
end;

end.
