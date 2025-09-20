unit freekick_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,sn_76496,gfx_engine,rom_engine,
     timer_engine,pal_engine,sound_engine,ppi8255,mc8123;

procedure cargar_freekick;

implementation
const
        //Freekick
        freekick_rom:tipo_roms=(n:'ns6201-a_1987.10_free_kick.cpu';l:$d000;p:0;crc:$6d172850);
        freekick_sound_data:tipo_roms=(n:'11.1e';l:$8000;p:0;crc:$a6030ba9);
        freekick_pal:array[0..5] of tipo_roms=(
        (n:'24s10n.8j';l:$100;p:0;crc:$53a6bc21),(n:'24s10n.7j';l:$100;p:$100;crc:$38dd97d8),
        (n:'24s10n.8k';l:$100;p:$200;crc:$18e66087),(n:'24s10n.7k';l:$100;p:$300;crc:$bc21797a),
        (n:'24s10n.8h';l:$100;p:$400;crc:$8aac5fd0),(n:'24s10n.7h';l:$100;p:$500;crc:$a507f941));
        freekick_chars:array[0..2] of tipo_roms=(
        (n:'12.1h';l:$4000;p:0;crc:$fb82e486),(n:'13.1j';l:$4000;p:$4000;crc:$3ad78ee2),
        (n:'14.1l';l:$4000;p:$8000;crc:$0185695f));
        freekick_sprites:array[0..2] of tipo_roms=(
        (n:'15.1m';l:$4000;p:0;crc:$0fa7c13c),(n:'16.1p';l:$4000;p:$4000;crc:$2b996e89),
        (n:'17.1r';l:$4000;p:$8000;crc:$e7894def));
        //Gigas
        gigas_rom:array[0..1] of tipo_roms=(
        (n:'8.8n';l:$4000;p:0;crc:$34ea8262),(n:'7.8r';l:$8000;p:$4000;crc:$43653909));
        gigas_key:tipo_roms=(n:'317-5002.key';l:$2000;p:0;crc:$86a7e5f6);
        gigas_pal:array[0..5] of tipo_roms=(
        (n:'tbp24s10n.3a';l:$100;p:0;crc:$a784e71f),(n:'tbp24s10n.4d';l:$100;p:$100;crc:$376df30c),
        (n:'tbp24s10n.4a';l:$100;p:$200;crc:$4edff5bd),(n:'tbp24s10n.3d';l:$100;p:$300;crc:$fe201a4e),
        (n:'tbp24s10n.3b';l:$100;p:$400;crc:$5796cc4a),(n:'tbp24s10n.3c';l:$100;p:$500;crc:$28b5ee4c));
        gigas_chars:array[0..2] of tipo_roms=(
        (n:'4.3k';l:$4000;p:0;crc:$8ed78981),(n:'5.3h';l:$4000;p:$4000;crc:$0645ec2d),
        (n:'6.3g';l:$4000;p:$8000;crc:$99e9cb27));
        gigas_sprites:array[0..2] of tipo_roms=(
        (n:'1.3p';l:$4000;p:0;crc:$d78fae6e),(n:'3.3l';l:$4000;p:$4000;crc:$37df4a4c),
        (n:'2.3n';l:$4000;p:$8000;crc:$3a46e354));
        //Gigas Mark II
        gigasm2_rom:array[0..1] of tipo_roms=(
        (n:'18.8n';l:$4000;p:0;crc:$32e83d80),(n:'17.8r';l:$8000;p:$4000;crc:$460dadd2));
        gigasm2_chars:array[0..2] of tipo_roms=(
        (n:'14.3k';l:$4000;p:0;crc:$20b3405f),(n:'15.3h';l:$4000;p:$4000;crc:$d04ecfa8),
        (n:'16.3g';l:$4000;p:$8000;crc:$33776801));
        gigasm2_sprites:array[0..2] of tipo_roms=(
        (n:'11.3p';l:$4000;p:0;crc:$f64cbd1e),(n:'13.3l';l:$4000;p:$4000;crc:$c228df19),
        (n:'12.3n';l:$4000;p:$8000;crc:$a6ad9ce2));
        //Omega
        omega_rom:array[0..1] of tipo_roms=(
        (n:'17.m10';l:$4000;p:0;crc:$c7de0993),(n:'8.n10';l:$8000;p:$4000;crc:$9bb61910));
        omega_key:tipo_roms=(n:'omega.key';l:$2000;p:0;crc:$0a63943f);
        omega_pal:array[0..5] of tipo_roms=(
        (n:'tbp24s10n.3f';l:$100;p:0;crc:$75ec7472),(n:'tbp24s10n.4f';l:$100;p:$100;crc:$5113a114),
        (n:'tbp24s10n.3g';l:$100;p:$200;crc:$b6b5d4a0),(n:'tbp24s10n.4g';l:$100;p:$300;crc:$931bc299),
        (n:'tbp24s10n.3e';l:$100;p:$400;crc:$899e089d),(n:'tbp24s10n.4e';l:$100;p:$500;crc:$28321dd8));
        omega_chars:array[0..2] of tipo_roms=(
        (n:'4.f10';l:$4000;p:0;crc:$bf780a8e),(n:'5.h10';l:$4000;p:$4000;crc:$b491647f),
        (n:'6.j10';l:$4000;p:$8000;crc:$65beba5b));
        omega_sprites:array[0..2] of tipo_roms=(
        (n:'3.d10';l:$4000;p:0;crc:$c678b202),(n:'1.a10';l:$4000;p:$4000;crc:$e0aeada9),
        (n:'2.c10';l:$4000;p:$8000;crc:$dbc0a47f));
        //Perfect Billiard
        pbillrd_rom:array[0..2] of tipo_roms=(
        (n:'pb.18';l:$4000;p:0;crc:$9e6275ac),(n:'pb.7';l:$8000;p:$4000;crc:$dd438431),
        (n:'pb.9';l:$4000;p:$c000;crc:$089ce80a));
        pbillrd_pal:array[0..5] of tipo_roms=(
        (n:'82s129.3a';l:$100;p:0;crc:$44802169),(n:'82s129.4d';l:$100;p:$100;crc:$69ca07cc),
        (n:'82s129.4a';l:$100;p:$200;crc:$145f950a),(n:'82s129.3d';l:$100;p:$300;crc:$43d24e17),
        (n:'82s129.3b';l:$100;p:$400;crc:$7fdc872c),(n:'82s129.3c';l:$100;p:$500;crc:$cc1657e5));
        pbillrd_chars:array[0..2] of tipo_roms=(
        (n:'pb.4';l:$4000;p:0;crc:$2f4d4dd3),(n:'pb.5';l:$4000;p:$4000;crc:$9dfccbd3),
        (n:'pb.6';l:$4000;p:$8000;crc:$b5c3f6f6));
        pbillrd_sprites:array[0..2] of tipo_roms=(
        (n:'10619.3r';l:$2000;p:0;crc:$3296b9d9),(n:'10621.3m';l:$2000;p:$2000;crc:$3dca8e4b),
        (n:'10620.3n';l:$2000;p:$4000;crc:$ee76b079));
        //Dip
        freekick_dip_a:array [0..6] of def_dip=(
        (mask:$1;name:'Lives';number:2;dip:((dip_val:$1;dip_name:'3'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$6;name:'Bonus Life';number:4;dip:((dip_val:$6;dip_name:'20K 30K 40K 50K 60K'),(dip_val:$2;dip_name:'30K 40K 50K 60K 70K 80K'),(dip_val:$4;dip_name:'20K 60K'),(dip_val:$0;dip_name:'20K Only'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$18;name:'Difficulty';number:4;dip:((dip_val:$18;dip_name:'Easy'),(dip_val:$10;dip_name:'Normal'),(dip_val:$8;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Allow Continue';number:2;dip:((dip_val:$0;dip_name:'No'),(dip_val:$20;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$40;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Flip Screen';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        freekick_dip_b:array [0..2] of def_dip=(
        (mask:$0f;name:'Coin A';number:16;dip:((dip_val:$0;dip_name:'5C 1C'),(dip_val:$c;dip_name:'4C 1C'),(dip_val:$e;dip_name:'3C 1C'),(dip_val:$5;dip_name:'2C 1C'),(dip_val:$6;dip_name:'3C 2C'),(dip_val:$4;dip_name:'4C 3C'),(dip_val:$f;dip_name:'1C 1C'),(dip_val:$8;dip_name:'4C 5C'),(dip_val:$a;dip_name:'3C 4C'),(dip_val:$9;dip_name:'2C 3C'),(dip_val:$2;dip_name:'3C 5C'),(dip_val:$7;dip_name:'1C 2C'),(dip_val:$1;dip_name:'2C 5C'),(dip_val:$b;dip_name:'1C 3C'),(dip_val:$3;dip_name:'1C 4C'),(dip_val:$d;dip_name:'1C 5C'))),
        (mask:$f0;name:'Coin B';number:16;dip:((dip_val:$0;dip_name:'5C 1C'),(dip_val:$e0;dip_name:'3C 1C'),(dip_val:$50;dip_name:'2C 1C'),(dip_val:$60;dip_name:'3C 2C'),(dip_val:$f0;dip_name:'1C 1C'),(dip_val:$a0;dip_name:'3C 4C'),(dip_val:$90;dip_name:'2C 3C'),(dip_val:$20;dip_name:'3C 5C'),(dip_val:$70;dip_name:'1C 2C'),(dip_val:$10;dip_name:'2C 5C'),(dip_val:$b0;dip_name:'1C 3C'),(dip_val:$30;dip_name:'1C 4C'),(dip_val:$d0;dip_name:'1C 5C'),(dip_val:$c0;dip_name:'1C 10C'),(dip_val:$40;dip_name:'1C 25C'),(dip_val:$80;dip_name:'1C 50C'))),());
        freekick_dip_c:array [0..2] of def_dip=(
        (mask:$1;name:'Manufacturer';number:2;dip:((dip_val:$0;dip_name:'Nihon System'),(dip_val:$1;dip_name:'Sega/Nihon System'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Coin Slots';number:2;dip:((dip_val:$0;dip_name:'1'),(dip_val:$80;dip_name:'2'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        gigas_dip_a:array [0..6] of def_dip=(
        (mask:$1;name:'Lives';number:2;dip:((dip_val:$1;dip_name:'3'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$6;name:'Bonus Life';number:4;dip:((dip_val:$6;dip_name:'20K 60K Every 60K'),(dip_val:$2;dip_name:'20K 60K'),(dip_val:$4;dip_name:'30K 80K Every 80K'),(dip_val:$0;dip_name:'20K Only'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$18;name:'Difficulty';number:4;dip:((dip_val:$18;dip_name:'Easy'),(dip_val:$10;dip_name:'Normal'),(dip_val:$8;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Allow Continue';number:2;dip:((dip_val:$0;dip_name:'No'),(dip_val:$20;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$40;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Flip Screen';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$80;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        gigas_dip_b:array [0..2] of def_dip=(
        (mask:$0f;name:'Coin A';number:16;dip:((dip_val:$0;dip_name:'5C 1C'),(dip_val:$c;dip_name:'4C 1C'),(dip_val:$e;dip_name:'3C 1C'),(dip_val:$5;dip_name:'2C 1C'),(dip_val:$6;dip_name:'3C 2C'),(dip_val:$4;dip_name:'4C 3C'),(dip_val:$f;dip_name:'1C 1C'),(dip_val:$8;dip_name:'4C 5C'),(dip_val:$a;dip_name:'3C 4C'),(dip_val:$9;dip_name:'2C 3C'),(dip_val:$2;dip_name:'3C 5C'),(dip_val:$7;dip_name:'1C 2C'),(dip_val:$1;dip_name:'2C 5C'),(dip_val:$b;dip_name:'1C 3C'),(dip_val:$3;dip_name:'1C 4C'),(dip_val:$d;dip_name:'1C 5C'))),
        (mask:$f0;name:'Coin B';number:16;dip:((dip_val:$0;dip_name:'5C 1C'),(dip_val:$c0;dip_name:'4C 1C'),(dip_val:$e0;dip_name:'3C 1C'),(dip_val:$50;dip_name:'2C 1C'),(dip_val:$60;dip_name:'3C 2C'),(dip_val:$40;dip_name:'4C 3C'),(dip_val:$f0;dip_name:'1C 1C'),(dip_val:$80;dip_name:'4C 5C'),(dip_val:$a0;dip_name:'3C 4C'),(dip_val:$90;dip_name:'2C 3C'),(dip_val:$20;dip_name:'3C 5C'),(dip_val:$70;dip_name:'1C 2C'),(dip_val:$10;dip_name:'2C 5C'),(dip_val:$b0;dip_name:'1C 3C'),(dip_val:$30;dip_name:'1C 4C'),(dip_val:$d0;dip_name:'1C 5C'))),());
        omega_dip_a:array [0..6] of def_dip=(
        (mask:$1;name:'Lives';number:2;dip:((dip_val:$1;dip_name:'3'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$6;name:'Bonus Life';number:4;dip:((dip_val:$6;dip_name:'20K 60K Every 60K'),(dip_val:$2;dip_name:'30K 80K Every 80K'),(dip_val:$4;dip_name:'20K 60K'),(dip_val:$0;dip_name:'20K Only'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$18;name:'Difficulty';number:4;dip:((dip_val:$18;dip_name:'Easy'),(dip_val:$10;dip_name:'Normal'),(dip_val:$8;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Allow Continue';number:2;dip:((dip_val:$0;dip_name:'No'),(dip_val:$20;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$40;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Flip Screen';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$80;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        omega_dip_b:array [0..2] of def_dip=(
        (mask:$0f;name:'Coin A';number:16;dip:((dip_val:$0;dip_name:'5C 1C'),(dip_val:$e;dip_name:'3C 1C'),(dip_val:$5;dip_name:'2C 1C'),(dip_val:$6;dip_name:'3C 2C'),(dip_val:$f;dip_name:'1C 1C'),(dip_val:$a;dip_name:'3C 4C'),(dip_val:$9;dip_name:'2C 3C'),(dip_val:$2;dip_name:'3C 5C'),(dip_val:$7;dip_name:'1C 2C'),(dip_val:$1;dip_name:'2C 5C'),(dip_val:$b;dip_name:'1C 3C'),(dip_val:$3;dip_name:'1C 4C'),(dip_val:$d;dip_name:'1C 5C'),(dip_val:$c;dip_name:'1C 10C'),(dip_val:$4;dip_name:'1C 25C'),(dip_val:$8;dip_name:'1C 50C'))),
        (mask:$f0;name:'Coin B';number:16;dip:((dip_val:$0;dip_name:'5C 1C'),(dip_val:$e0;dip_name:'3C 1C'),(dip_val:$50;dip_name:'2C 1C'),(dip_val:$60;dip_name:'3C 2C'),(dip_val:$f0;dip_name:'1C 1C'),(dip_val:$a0;dip_name:'3C 4C'),(dip_val:$90;dip_name:'2C 3C'),(dip_val:$20;dip_name:'3C 5C'),(dip_val:$70;dip_name:'1C 2C'),(dip_val:$10;dip_name:'2C 5C'),(dip_val:$b0;dip_name:'1C 3C'),(dip_val:$30;dip_name:'1C 4C'),(dip_val:$d0;dip_name:'1C 5C'),(dip_val:$c0;dip_name:'1C 10C'),(dip_val:$40;dip_name:'1C 25C'),(dip_val:$80;dip_name:'1C 50C'))),());
        omega_dip_c:array [0..3] of def_dip=(
        (mask:$1;name:'Hopper Status?';number:2;dip:((dip_val:$1;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2;name:'Invulnerability';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Prize Version';number:4;dip:((dip_val:$c0;dip_name:'Off'),(dip_val:$80;dip_name:'On Setting 1'),(dip_val:$40;dip_name:'On Setting 2'),(dip_val:$0;dip_name:'On Setting 3'),(),(),(),(),(),(),(),(),(),(),(),())),());
        pbillrd_dip_a:array [0..6] of def_dip=(
        (mask:$1;name:'Balls';number:2;dip:((dip_val:$1;dip_name:'3'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$6;name:'Bonus Ball';number:4;dip:((dip_val:$6;dip_name:'10K 30K 50K'),(dip_val:$2;dip_name:'20K 60K'),(dip_val:$4;dip_name:'30K 80K'),(dip_val:$0;dip_name:'20K Only'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Allow Continue';number:2;dip:((dip_val:$0;dip_name:'No'),(dip_val:$10;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Shot';number:2;dip:((dip_val:$0;dip_name:'2'),(dip_val:$20;dip_name:'3'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$40;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Flip Screen';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$80;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
  spinner,nmi_enable:boolean;
  snd_rom_addr:word;
  rom_index,freekick_ff:byte;
  video_mem:array[0..$7ff] of byte;
  sprite_mem:array[0..$ff] of byte;
  rom:array[0..1,0..$3fff] of byte;
  draw_sprites:procedure;

procedure sprites_freekick;
var
  f,atrib,color,x,y:byte;
  nchar:word;
begin
  for f:=0 to $3f do begin
    atrib:=sprite_mem[$2+(f*4)];
    nchar:=sprite_mem[$1+(f*4)]+((atrib and $20) shl 3);
    color:=(atrib and $1f) shl 3;
    y:=240-sprite_mem[$3+(f*4)];
    x:=248-sprite_mem[$0+(f*4)];
    put_gfx_sprite(nchar,color+$100,(atrib and $40)<>0,(atrib and $80)<>0,1);
    actualiza_gfx_sprite(x,y,2,1);
end;
end;

procedure sprites_gigas;
var
  f,atrib,color,x,y:byte;
  nchar:word;
begin
  for f:=0 to $3f do begin
    atrib:=sprite_mem[$1+(f*4)];
    nchar:=sprite_mem[$0+(f*4)]+((atrib and $20) shl 3);
    color:=(atrib and $1f) shl 3;
    y:=240-sprite_mem[$3+(f*4)];
    x:=240-sprite_mem[$2+(f*4)];
    put_gfx_sprite(nchar,color+$100,false,false,1);
    actualiza_gfx_sprite(x,y,2,1);
end;
end;

procedure sprites_pbillrd;
var
  f,atrib,color,x,y,nchar:byte;
begin
  for f:=0 to $3f do begin
    atrib:=sprite_mem[$1+(f*4)];
    nchar:=sprite_mem[$0+(f*4)];
    color:=(atrib and $f) shl 3;
    y:=240-sprite_mem[$3+(f*4)];
    x:=240-sprite_mem[$2+(f*4)];
    put_gfx_sprite(nchar,color+$100,false,false,1);
    actualiza_gfx_sprite(x,y,2,1);
end;
end;

procedure update_video_freekick;inline;
var
  f,nchar:word;
  x,y,color,atrib:byte;
begin
for f:=$3ff downto 0 do begin
  if gfx[0].buffer[f] then begin
    x:=f div 32;
    y:=31-(f mod 32);
    atrib:=video_mem[f+$400];
    color:=(atrib and $1f) shl 3;
    nchar:=video_mem[f]+((atrib and $e0) shl 3);
    put_gfx(x*8,y*8,nchar,color,1,0);
    gfx[0].buffer[f]:=false;
  end;
end;
actualiza_trozo(0,0,256,256,1,0,0,256,256,2);
//sprites
draw_sprites;
actualiza_trozo_final(16,0,224,256,2);
end;

procedure eventos_freekick;
begin
if event.arcade then begin
  //IN0
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  //IN1
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  if arcade_input.coin[1] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
end;
end;

procedure freekick_principal;
var
  f:word;
  frame_m:single;
begin
init_controls(false,false,false,true);
frame_m:=z80_0.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to 262 do begin
    z80_0.run(frame_m);
    frame_m:=frame_m+z80_0.tframes-z80_0.contador;
    if f=239 then begin
      update_video_freekick;
      if nmi_enable then z80_0.change_nmi(ASSERT_LINE);
    end;
  end;
  eventos_freekick;
  video_sync;
end;
end;

//Free Kick
function freekick_getbyte(direccion:word):byte;
begin
case direccion of
  0..$dfff:freekick_getbyte:=memoria[direccion];
  $e000..$e7ff:freekick_getbyte:=video_mem[direccion and $7ff];
  $e800..$e8ff:freekick_getbyte:=sprite_mem[direccion and $ff];
  $ec00..$ec03:freekick_getbyte:=pia8255_0.read(direccion and $3);
  $f000..$f003:freekick_getbyte:=pia8255_1.read(direccion and $3);
  $f800:freekick_getbyte:=marcade.in0;
  $f801:freekick_getbyte:=marcade.in1;
  $f802:freekick_getbyte:=0;
  $f803:if spinner then freekick_getbyte:=analog.c[0].x[0]
          else freekick_getbyte:=analog.c[0].x[1];
end;
end;

procedure freekick_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$cfff:; //ROM
  $d000..$dfff:memoria[direccion]:=valor;
  $e000..$e7ff:if video_mem[direccion and $7ff]<>valor then begin
                    gfx[0].buffer[direccion and $3ff]:=true;
                    video_mem[direccion and $7ff]:=valor;
               end;
  $e800..$e8ff:sprite_mem[direccion and $ff]:=valor;
  $ec00..$ec03:pia8255_0.write(direccion and $3,valor);
  $f000..$f003:pia8255_1.write(direccion and $3,valor);
  $f804:begin
          nmi_enable:=(valor and 1)<>0;
          if not(nmi_enable) then z80_0.change_nmi(CLEAR_LINE);
        end;
  $f806:spinner:=(valor and 1)=0;
  $fc00:sn_76496_0.Write(valor);
  $fc01:sn_76496_1.Write(valor);
  $fc02:sn_76496_2.Write(valor);
  $fc03:sn_76496_3.Write(valor);
end;
end;

function freekick_inbyte(puerto:word):byte;
begin
  if (puerto and $ff)=$ff then freekick_inbyte:=freekick_ff;
end;

procedure freekick_outbyte(puerto:word;valor:byte);
begin
  if (puerto and $ff)=$ff then freekick_ff:=valor;
end;

function ppi0_c_read:byte;
begin
  ppi0_c_read:=mem_misc[snd_rom_addr];
end;

procedure ppi0_a_write(valor:byte);
begin
  snd_rom_addr:=(snd_rom_addr and $ff00) or valor;
end;

procedure ppi0_b_write(valor:byte);
begin
  snd_rom_addr:=(snd_rom_addr and $ff) or (valor shl 8);
end;

function ppi1_a_read:byte;
begin
  ppi1_a_read:=marcade.dswa;
end;

function ppi1_b_read:byte;
begin
  ppi1_b_read:=marcade.dswb;
end;

function ppi1_c_read:byte;
begin
  ppi1_c_read:=marcade.dswc;
end;

//Gigas
function gigas_getbyte(direccion:word):byte;
begin
case direccion of
  0..$bfff:if z80_0.opcode then gigas_getbyte:=mem_misc[direccion]
              else gigas_getbyte:=memoria[direccion];
  $c000..$cfff,$d900..$dfff:gigas_getbyte:=memoria[direccion];
  $d000..$d7ff:gigas_getbyte:=video_mem[direccion and $7ff];
  $d800..$d8ff:gigas_getbyte:=sprite_mem[direccion and $ff];
  $e000:gigas_getbyte:=marcade.in0;
  $e800:gigas_getbyte:=marcade.in1;
  $f000:gigas_getbyte:=marcade.dswa;
  $f800:gigas_getbyte:=marcade.dswb;
end;
end;

procedure gigas_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$bfff:; //ROM
  $c000..$cfff,$d900..$dfff:memoria[direccion]:=valor;
  $d000..$d7ff:if video_mem[direccion and $7ff]<>valor then begin
                    gfx[0].buffer[direccion and $3ff]:=true;
                    video_mem[direccion and $7ff]:=valor;
               end;
  $d800..$d8ff:sprite_mem[direccion and $ff]:=valor;
  $e004:begin
          nmi_enable:=(valor and 1)<>0;
          if not(nmi_enable) then z80_0.change_nmi(CLEAR_LINE);
        end;
  $fc00:sn_76496_0.Write(valor);
  $fc01:sn_76496_1.Write(valor);
  $fc02:sn_76496_2.Write(valor);
  $fc03:sn_76496_3.Write(valor);
end;
end;

function gigas_inbyte(puerto:word):byte;
begin
  case (puerto and $ff) of
    0:if spinner then gigas_inbyte:=analog.c[0].x[0]
        else gigas_inbyte:=analog.c[0].x[1];
    1:gigas_inbyte:=marcade.dswc;
  end;
end;

procedure gigas_outbyte(puerto:word;valor:byte);
begin
  if (puerto and $ff)=0 then spinner:=(valor and 1)=0;
end;

//Perfect Billard
function pbillrd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff:pbillrd_getbyte:=memoria[direccion];
  $8000..$bfff:pbillrd_getbyte:=rom[rom_index,direccion and $3fff];
  $c000..$cfff,$d900..$dfff:pbillrd_getbyte:=memoria[direccion];
  $d000..$d7ff:pbillrd_getbyte:=video_mem[direccion and $7ff];
  $d800..$d8ff:pbillrd_getbyte:=sprite_mem[direccion and $ff];
  $e000:pbillrd_getbyte:=marcade.in0;
  $e800:pbillrd_getbyte:=marcade.in1;
  $f000:pbillrd_getbyte:=marcade.dswa;
  $f800:pbillrd_getbyte:=marcade.dswb;
end;
end;

procedure pbillrd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$bfff:; //ROM
  $c000..$cfff,$d900..$dfff:memoria[direccion]:=valor;
  $d000..$d7ff:if video_mem[direccion and $7ff]<>valor then begin
                    gfx[0].buffer[direccion and $3ff]:=true;
                    video_mem[direccion and $7ff]:=valor;
               end;
  $d800..$d8ff:sprite_mem[direccion and $ff]:=valor;
  $e004:begin
          nmi_enable:=(valor and 1)<>0;
          if not(nmi_enable) then z80_0.change_nmi(CLEAR_LINE);
        end;
  $f000:rom_index:=valor and 1;
  $fc00:sn_76496_0.Write(valor);
  $fc01:sn_76496_1.Write(valor);
  $fc02:sn_76496_2.Write(valor);
  $fc03:sn_76496_3.Write(valor);
end;
end;

//Sound
procedure freeckick_snd_irq;
begin
  z80_0.change_irq(HOLD_LINE);
end;

procedure freekick_sound_update;
begin
  sn_76496_0.update;
  sn_76496_1.update;
  sn_76496_2.update;
  sn_76496_3.update;
end;

//Main
procedure reset_freekick;
begin
 z80_0.reset;
 sn_76496_0.reset;
 sn_76496_1.reset;
 sn_76496_2.reset;
 sn_76496_3.reset;
 if main_vars.tipo_maquina=211 then begin
    pia8255_0.reset;
    pia8255_1.reset;
 end;
 reset_audio;
 snd_rom_addr:=0;
 spinner:=false;
 nmi_enable:=false;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 rom_index:=0;
end;

function iniciar_freekick:boolean;
var
  colores:tpaleta;
  f:word;
  clock:dword;
  bit0,bit1,bit2,bit3:byte;
  memoria_temp:array[0..$ffff] of byte;
  mem_key:array[0..$1fff] of byte;
const
  ps_x:array[0..15] of dword=(0, 1, 2, 3, 4, 5, 6, 7,
	  128+0,128+1,128+2,128+3,128+4,128+5,128+6,128+7);
  ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
		8*8, 9*8, 10*8, 11*8,12*8,13*8,14*8,15*8);
procedure convert_chars(n:word);
begin
  init_gfx(0,8,8,n);
  gfx_set_desc_data(3,0,8*8,n*2*8*8,n*1*8*8,n*0*8*8);
  convert_gfx(0,0,@memoria_temp,@ps_x,@ps_y,false,true);
end;
procedure convert_sprites(n:word);
begin
  init_gfx(1,16,16,n);
  gfx[1].trans[0]:=true;
  gfx_set_desc_data(3,0,16*16,n*0*16*16,n*2*16*16,n*1*16*16);
  convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,true);
end;
begin
iniciar_freekick:=false;
iniciar_audio(false);
screen_init(1,256,256);
screen_init(2,256,256,false,true);
if main_vars.tipo_maquina=274 then begin
  iniciar_video(256,224);
  main_screen.rot90_screen:=true;
end else iniciar_video(224,256);
if main_vars.tipo_maquina=273 then clock:=3072000
  else clock:=3000000;
//Main CPU
z80_0:=cpu_z80.create(clock,263);
z80_0.init_sound(freekick_sound_update);
//Sound Chips
sn_76496_0:=sn76496_chip.create(clock);
sn_76496_1:=sn76496_chip.create(clock);
sn_76496_2:=sn76496_chip.create(clock);
sn_76496_3:=sn76496_chip.create(clock);
//IRQ Sound CPU
timers.init(z80_0.numero_cpu,clock/120,freeckick_snd_irq,nil,true);
case main_vars.tipo_maquina of
  211:begin //Free Kick
        z80_0.change_ram_calls(freekick_getbyte,freekick_putbyte);
        z80_0.change_io_calls(freekick_inbyte,freekick_outbyte);
        //analog
        init_analog(z80_0.numero_cpu,z80_0.clock);
        analog_0(20,10,$7f,$ff,0,false);
        //PPI
        pia8255_0:=pia8255_chip.create;
        pia8255_0.change_ports(nil,nil,ppi0_c_read,ppi0_a_write,ppi0_b_write,nil);
        pia8255_1:=pia8255_chip.create;
        pia8255_1.change_ports(ppi1_a_read,ppi1_b_read,ppi1_c_read,nil,nil,nil);
        //cargar roms
        if not(roms_load(@memoria,freekick_rom)) then exit;
        //snd rom
        if not(roms_load(@mem_misc,freekick_sound_data)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,freekick_chars)) then exit;
        convert_chars($800);
        //convertir sprites
        if not(roms_load(@memoria_temp,freekick_sprites)) then exit;
        convert_sprites($200);
        draw_sprites:=sprites_freekick;
        //poner la paleta
        if not(roms_load(@memoria_temp,freekick_pal)) then exit;
        //DIP
        marcade.dswa:=$bf;
        marcade.dswb:=$ff;
        marcade.dswc:=$80;
        marcade.dswa_val:=@freekick_dip_a;
        marcade.dswb_val:=@freekick_dip_b;
        marcade.dswc_val:=@freekick_dip_c;
  end;
  271:begin //Gigas
        z80_0.change_ram_calls(gigas_getbyte,gigas_putbyte);
        z80_0.change_io_calls(gigas_inbyte,gigas_outbyte);
        //analog
        init_analog(z80_0.numero_cpu,z80_0.clock);
        analog_0(20,10,$7f,$ff,0,false);
        //cargar y desencriptar ROMS
        if not(roms_load(@memoria_temp,gigas_rom)) then exit;
        if not(roms_load(@mem_key,gigas_key)) then exit;
        copymemory(@memoria,@memoria_temp,$c000);
        mc8123_decrypt_rom(@mem_key,@memoria,@mem_misc,$c000);
        //convertir chars
        if not(roms_load(@memoria_temp,gigas_chars)) then exit;
        convert_chars($800);
        //convertir sprites
        if not(roms_load(@memoria_temp,gigas_sprites)) then exit;
        convert_sprites($200);
        draw_sprites:=sprites_gigas;
        //poner la paleta
        if not(roms_load(@memoria_temp,gigas_pal)) then exit;
        //DIP
        marcade.dswa:=$3f;
        marcade.dswb:=$ff;
        marcade.dswa_val:=@gigas_dip_a;
        marcade.dswb_val:=@gigas_dip_b;
  end;
  272:begin //Gigas Mark II
        z80_0.change_ram_calls(gigas_getbyte,gigas_putbyte);
        z80_0.change_io_calls(gigas_inbyte,gigas_outbyte);
        //analog
        init_analog(z80_0.numero_cpu,z80_0.clock);
        analog_0(20,10,$7f,$ff,0,false);
        //cargar y desencriptar ROMS
        if not(roms_load(@memoria_temp,gigasm2_rom)) then exit;
        if not(roms_load(@mem_key,gigas_key)) then exit;
        copymemory(@memoria,@memoria_temp,$c000);
        mc8123_decrypt_rom(@mem_key,@memoria,@mem_misc,$c000);
        //convertir chars
        if not(roms_load(@memoria_temp,gigasm2_chars)) then exit;
        convert_chars($800);
        //convertir sprites
        if not(roms_load(@memoria_temp,gigasm2_sprites)) then exit;
        convert_sprites($200);
        draw_sprites:=sprites_gigas;
        //poner la paleta
        if not(roms_load(@memoria_temp,gigas_pal)) then exit;
        //DIP
        marcade.dswa:=$3f;
        marcade.dswb:=$ff;
        marcade.dswa_val:=@gigas_dip_a;
        marcade.dswb_val:=@gigas_dip_b;
  end;
  273:begin //Omega
        z80_0.change_ram_calls(gigas_getbyte,gigas_putbyte);
        z80_0.change_io_calls(gigas_inbyte,gigas_outbyte);
        //analog
        init_analog(z80_0.numero_cpu,z80_0.clock);
        analog_0(20,10,$7f,$ff,0,false);
        //cargar y desencriptar ROMS
        if not(roms_load(@memoria_temp,omega_rom)) then exit;
        if not(roms_load(@mem_key,omega_key)) then exit;
        copymemory(@memoria,@memoria_temp,$c000);
        mc8123_decrypt_rom(@mem_key,@memoria,@mem_misc,$c000);
        //convertir chars
        if not(roms_load(@memoria_temp,omega_chars)) then exit;
        convert_chars($800);
        //convertir sprites
        if not(roms_load(@memoria_temp,omega_sprites)) then exit;
        convert_sprites($200);
        draw_sprites:=sprites_gigas;
        //poner la paleta
        if not(roms_load(@memoria_temp,omega_pal)) then exit;
        //DIP
        marcade.dswa:=$3f;
        marcade.dswb:=$ff;
        marcade.dswc:=$ff;
        marcade.dswa_val:=@omega_dip_a;
        marcade.dswb_val:=@omega_dip_b;
        marcade.dswc_val:=@omega_dip_c;
  end;
  274:begin //Perfect Billiard
        z80_0.change_ram_calls(pbillrd_getbyte,pbillrd_putbyte);
        //cargar y desencriptar ROMS
        if not(roms_load(@memoria_temp,pbillrd_rom)) then exit;
        copymemory(@memoria,@memoria_temp,$8000);
        copymemory(@rom[0,0],@memoria_temp[$8000],$4000);
        copymemory(@rom[1,0],@memoria_temp[$c000],$4000);
        //convertir chars
        if not(roms_load(@memoria_temp,pbillrd_chars)) then exit;
        convert_chars($800);
        //convertir sprites
        if not(roms_load(@memoria_temp,pbillrd_sprites)) then exit;
        convert_sprites($100);
        draw_sprites:=sprites_pbillrd;
        //poner la paleta
        if not(roms_load(@memoria_temp,pbillrd_pal)) then exit;
        //DIP
        marcade.dswa:=$1f;
        marcade.dswb:=$ff;
        marcade.dswa_val:=@pbillrd_dip_a;
        marcade.dswb_val:=@gigas_dip_b;
  end;
end;
//Pal
for f:=0 to $1ff do begin
		//red
		bit0:=(memoria_temp[f] shr 0) and 1;
		bit1:=(memoria_temp[f] shr 1) and 1;
		bit2:=(memoria_temp[f] shr 2) and 1;
		bit3:=(memoria_temp[f] shr 3) and 1;
		colores[f].r:=$0e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
		//green
		bit0:=(memoria_temp[f+$200] shr 0) and 1;
		bit1:=(memoria_temp[f+$200] shr 1) and 1;
		bit2:=(memoria_temp[f+$200] shr 2) and 1;
		bit3:=(memoria_temp[f+$200] shr 3) and 1;
		colores[f].g:=$0e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
		// blue
		bit0:=(memoria_temp[f+$400] shr 0) and 1;
		bit1:=(memoria_temp[f+$400] shr 1) and 1;
		bit2:=(memoria_temp[f+$400] shr 2) and 1;
		bit3:=(memoria_temp[f+$400] shr 3) and 1;
		colores[f].b:=$0e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
end;
set_pal(colores,$200);
//final
reset_freekick;
iniciar_freekick:=true;
end;

procedure cargar_freekick;
begin
  llamadas_maquina.iniciar:=iniciar_freekick;
  llamadas_maquina.bucle_general:=freekick_principal;
  llamadas_maquina.reset:=reset_freekick;
  if main_vars.tipo_maquina=273 then llamadas_maquina.fps_max:=60.836502
    else llamadas_maquina.fps_max:=59.410646;
end;

end.
