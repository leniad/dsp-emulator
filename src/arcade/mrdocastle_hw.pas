unit mrdocastle_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,sn_76496,gfx_engine,rom_engine,
     pal_engine,sound_engine,msm5205;

function iniciar_mrdocastle:boolean;

implementation
const
        //Mr Do Castle
        mrdocastle_rom:array[0..3] of tipo_roms=(
        (n:'01p_a1.bin';l:$2000;p:0;crc:$17c6fc24),(n:'01n_a2.bin';l:$2000;p:$2000;crc:$1d2fc7f4),
        (n:'01l_a3.bin';l:$2000;p:$4000;crc:$71a70ba9),(n:'01k_a4.bin';l:$2000;p:$6000;crc:$479a745e));
        mrdocastle_slave:tipo_roms=(n:'07n_a0.bin';l:$4000;p:0;crc:$f23b5cdb);
        mrdocastle_misc:tipo_roms=(n:'01d.bin';l:$200;p:0;crc:$2747ca77);
        mrdocastle_char:tipo_roms=(n:'03a_a5.bin';l:$4000;p:0;crc:$0636b8f4);
        mrdocastle_sprites:array[0..3] of tipo_roms=(
        (n:'04m_a6.bin';l:$2000;p:0;crc:$3bbc9b26),(n:'04l_a7.bin';l:$2000;p:$2000;crc:$3dfaa9d1),
        (n:'04j_a8.bin';l:$2000;p:$4000;crc:$9afb16e9),(n:'04h_a9.bin';l:$2000;p:$6000;crc:$af24bce0));
        mrdocastle_pal:tipo_roms=(n:'09c.bin';l:$200;p:0;crc:$066f52bc);
        //Do Run Run
        dorunrun_rom:array[0..3] of tipo_roms=(
        (n:'2764.p1';l:$2000;p:0;crc:$95c86f8e),(n:'2764.l1';l:$2000;p:$4000;crc:$e9a65ba7),
        (n:'2764.k1';l:$2000;p:$6000;crc:$b1195d3d),(n:'2764.n1';l:$2000;p:$8000;crc:$6a8160d1));
        dorunrun_slave:tipo_roms=(n:'27128.p7';l:$4000;p:0;crc:$8b06d461);
        dorunrun_misc:tipo_roms=(n:'bprom2.bin';l:$200;p:0;crc:$2747ca77);
        dorunrun_char:tipo_roms=(n:'27128.a3';l:$4000;p:0;crc:$4be96dcf);
        dorunrun_sprites:array[0..3] of tipo_roms=(
        (n:'2764.m4';l:$2000;p:0;crc:$4bb231a0),(n:'2764.l4';l:$2000;p:$2000;crc:$0c08508a),
        (n:'2764.j4';l:$2000;p:$4000;crc:$79287039),(n:'2764.h4';l:$2000;p:$6000;crc:$523aa999));
        dorunrun_pal:tipo_roms=(n:'dorunrun.clr';l:$100;p:0;crc:$d5bab5d5);
        //Do Wild Ride
        dowild_rom:array[0..3] of tipo_roms=(
        (n:'w1';l:$2000;p:0;crc:$097de78b),(n:'w3';l:$2000;p:$4000;crc:$fc6a1cbb),
        (n:'w4';l:$2000;p:$6000;crc:$8aac1d30),(n:'w2';l:$2000;p:$8000;crc:$0914ab69));
        dowild_slave:tipo_roms=(n:'w10';l:$4000;p:0;crc:$d1f37fba);
        dowild_misc:tipo_roms=(n:'8300b-2';l:$200;p:0;crc:$2747ca77);
        dowild_char:tipo_roms=(n:'w5';l:$4000;p:0;crc:$b294b151);
        dowild_sprites:array[0..3] of tipo_roms=(
        (n:'w6';l:$2000;p:0;crc:$57e0208b),(n:'w7';l:$2000;p:$2000;crc:$5001a6f7),
        (n:'w8';l:$2000;p:$4000;crc:$ec503251),(n:'w9';l:$2000;p:$6000;crc:$af7bd7eb));
        dowild_pal:tipo_roms=(n:'dowild.clr';l:$100;p:0;crc:$a703dea5);
        //Jumping Jack
        jjack_rom:array[0..3] of tipo_roms=(
        (n:'j1.bin';l:$2000;p:0;crc:$87f29bd2),(n:'j3.bin';l:$2000;p:$4000;crc:$35b0517e),
        (n:'j4.bin';l:$2000;p:$6000;crc:$35bb316a),(n:'j2.bin';l:$2000;p:$8000;crc:$dec52e80));
        jjack_slave:tipo_roms=(n:'j0.bin';l:$4000;p:0;crc:$ab042f04);
        jjack_misc:tipo_roms=(n:'bprom2.bin';l:$200;p:0;crc:$2747ca77);
        jjack_char:tipo_roms=(n:'j5.bin';l:$4000;p:0;crc:$75038ff9);
        jjack_sprites:array[0..3] of tipo_roms=(
        (n:'j6.bin';l:$2000;p:0;crc:$5937bd7b),(n:'j7.bin';l:$2000;p:$2000;crc:$cf8ae8e7),
        (n:'j8.bin';l:$2000;p:$4000;crc:$84f6fc8c),(n:'j9.bin';l:$2000;p:$6000;crc:$3f9bb09f));
        jjack_pal:tipo_roms=(n:'bprom1.bin';l:$200;p:0;crc:$2f0955f2);
        //Kick Rider
        kickridr_rom:array[0..3] of tipo_roms=(
        (n:'k1';l:$2000;p:0;crc:$dfdd1ab4),(n:'k3';l:$2000;p:$4000;crc:$412244da),
        (n:'k4';l:$2000;p:$6000;crc:$a67dd2ec),(n:'k2';l:$2000;p:$8000;crc:$e193fb5c));
        kickridr_slave:tipo_roms=(n:'k10';l:$4000;p:0;crc:$6843dbc0);
        kickridr_misc:tipo_roms=(n:'8300b-2';l:$200;p:0;crc:$2747ca77);
        kickridr_char:tipo_roms=(n:'k5';l:$4000;p:0;crc:$3f7d7e49);
        kickridr_sprites:array[0..3] of tipo_roms=(
        (n:'k6';l:$2000;p:0;crc:$94252ed3),(n:'k7';l:$2000;p:$2000;crc:$7ef2420e),
        (n:'k8';l:$2000;p:$4000;crc:$29bed201),(n:'k9';l:$2000;p:$6000;crc:$847584d3));
        kickridr_pal:tipo_roms=(n:'kickridr.clr';l:$100;p:0;crc:$73ec281c);
        //Indoor Soccer
        idsoccer_rom:array[0..3] of tipo_roms=(
        (n:'id01';l:$2000;p:0;crc:$f1c3bf09),(n:'id02';l:$2000;p:$2000;crc:$184e6af0),
        (n:'id03';l:$2000;p:$6000;crc:$22524661),(n:'id04';l:$2000;p:$8000;crc:$e8cd95fd));
        idsoccer_slave:tipo_roms=(n:'id10';l:$4000;p:0;crc:$6c8b2037);
        idsoccer_misc:tipo_roms=(n:'id_8p';l:$200;p:0;crc:$2747ca77);
        idsoccer_char:tipo_roms=(n:'id05';l:$4000;p:0;crc:$a57c7a11);
        idsoccer_sprites:array[0..3] of tipo_roms=(
        (n:'id06';l:$8000;p:0;crc:$b42a6f4a),(n:'id07';l:$8000;p:$8000;crc:$fa2b1c77),
        (n:'id08';l:$8000;p:$10000;crc:$5e97eab9),(n:'id09';l:$8000;p:$18000;crc:$a2a69223));
        idsoccer_pal:tipo_roms=(n:'id_3d.clr';l:$200;p:0;crc:$a433ff62);
        idsoccer_adpcm:array[0..2] of tipo_roms=(
        (n:'is1';l:$4000;p:0;crc:$9eb76196),(n:'is3';l:$4000;p:$8000;crc:$27bebba3),
        (n:'is4';l:$4000;p:$c000;crc:$dd5ffaa2));
        //Dip
        mrdocastle_dip_a:array [0..6] of def_dip=(
        (mask:$3;name:'Difficulty';number:4;dip:((dip_val:$3;dip_name:'1 (Beginner)'),(dip_val:$2;dip_name:'2'),(dip_val:$1;dip_name:'3'),(dip_val:$0;dip_name:'4 (Advanced)'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Rack Test';number:2;dip:((dip_val:$4;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Advance Level on Getting Diamond';number:2;dip:((dip_val:$8;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Difficulty of EXTRA';number:2;dip:((dip_val:$10;dip_name:'Easy'),(dip_val:$0;dip_name:'Difficult'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$20;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Lives';number:4;dip:((dip_val:$0;dip_name:'2'),(dip_val:$c0;dip_name:'3'),(dip_val:$80;dip_name:'4'),(dip_val:$40;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),());
        mrdocastle_dip_b:array [0..2] of def_dip=(
        (mask:$f0;name:'Coin A';number:11;dip:((dip_val:$60;dip_name:'4C 1C'),(dip_val:$80;dip_name:'3C 1C'),(dip_val:$a0;dip_name:'2C 1C'),(dip_val:$70;dip_name:'3C 2C'),(dip_val:$f0;dip_name:'1C 1C'),(dip_val:$90;dip_name:'2C 3C'),(dip_val:$e0;dip_name:'1C 2C'),(dip_val:$d0;dip_name:'1C 3C'),(dip_val:$c0;dip_name:'1C 4C'),(dip_val:$b0;dip_name:'1C 5C'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),())),
        (mask:$0f;name:'Coin B';number:11;dip:((dip_val:$06;dip_name:'4C 1C'),(dip_val:$08;dip_name:'3C 1C'),(dip_val:$0a;dip_name:'2C 1C'),(dip_val:$07;dip_name:'3C 2C'),(dip_val:$0f;dip_name:'1C 1C'),(dip_val:$09;dip_name:'2C 3C'),(dip_val:$0e;dip_name:'1C 2C'),(dip_val:$0d;dip_name:'1C 3C'),(dip_val:$0c;dip_name:'1C 4C'),(dip_val:$0b;dip_name:'1C 5C'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),())),());
        dorunrun_dip_a:array [0..7] of def_dip=(
        (mask:$3;name:'Difficulty';number:4;dip:((dip_val:$3;dip_name:'1 (Beginner)'),(dip_val:$2;dip_name:'2'),(dip_val:$1;dip_name:'3'),(dip_val:$0;dip_name:'4 (Advanced)'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Demo Sounds';number:2;dip:((dip_val:0;dip_name:'Off'),(dip_val:$4;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Flip Screen';number:2;dip:((dip_val:$8;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Difficulty of EXTRA';number:2;dip:((dip_val:$10;dip_name:'Easy'),(dip_val:$0;dip_name:'Difficult'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$20;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Special';number:2;dip:((dip_val:$40;dip_name:'Given'),(dip_val:$0;dip_name:'Not Given'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Lives';number:2;dip:((dip_val:$80;dip_name:'3'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        dowild_dip_a:array [0..7] of def_dip=(
        (mask:$3;name:'Difficulty';number:4;dip:((dip_val:$3;dip_name:'1 (Beginner)'),(dip_val:$2;dip_name:'2'),(dip_val:$1;dip_name:'3'),(dip_val:$0;dip_name:'4 (Advanced)'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Rack Test';number:2;dip:((dip_val:$4;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Flip Screen';number:2;dip:((dip_val:$8;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Difficulty of EXTRA';number:2;dip:((dip_val:$10;dip_name:'Easy'),(dip_val:$0;dip_name:'Difficult'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$20;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Special';number:2;dip:((dip_val:$40;dip_name:'Given'),(dip_val:$0;dip_name:'Not Given'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Lives';number:2;dip:((dip_val:$80;dip_name:'3'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        jjack_dip_a:array [0..6] of def_dip=(
        (mask:$3;name:'Difficulty';number:4;dip:((dip_val:$3;dip_name:'Easy'),(dip_val:$2;dip_name:'Medium'),(dip_val:$1;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Rack Test ';number:2;dip:((dip_val:$4;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Flip Screen';number:2;dip:((dip_val:$8;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Extra';number:2;dip:((dip_val:$10;dip_name:'Easy'),(dip_val:$0;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$20;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Lives';number:4;dip:((dip_val:$0;dip_name:'2'),(dip_val:$c0;dip_name:'3'),(dip_val:$80;dip_name:'4'),(dip_val:$40;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),());
        kickridr_dip_a:array [0..4] of def_dip=(
        (mask:$3;name:'Difficulty';number:4;dip:((dip_val:$3;dip_name:'Easy'),(dip_val:$2;dip_name:'Medium'),(dip_val:$1;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Rack Test';number:2;dip:((dip_val:$4;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Flip Screen';number:2;dip:((dip_val:$8;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$20;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        idsoccer_dip_a:array [0..6] of def_dip=(
        (mask:$3;name:'Difficulty';number:4;dip:((dip_val:$3;dip_name:'Easy'),(dip_val:$2;dip_name:'Medium'),(dip_val:$1;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'One Player vs. Computer';number:2;dip:((dip_val:$4;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Flip Screen';number:2;dip:((dip_val:$8;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Player 2 Time Extension';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$10;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Player 1 Time Extension';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$20;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Real Game Time';number:4;dip:((dip_val:$c0;dip_name:'3:00'),(dip_val:$80;dip_name:'2:30'),(dip_val:$40;dip_name:'2:00'),(dip_val:$0;dip_name:'1:00'),(),(),(),(),(),(),(),(),(),(),(),())),());
        CPU_SYNC=4;

var
  buffer0,buffer1:array[0..8] of byte;
  buf_input,adpcm_status:byte;
  sprite_ram:array[0..$1ff] of byte;
  draw_sprites:procedure;

procedure docastle_draw_sprites;
var
  color:word;
  nchar,f,x,y,atrib:byte;
begin
for f:=0 to $7f do begin
    nchar:=sprite_ram[(f*4)+3];
    atrib:=sprite_ram[(f*4)+2];
    color:=(atrib and $1f) shl 4;
    x:=((sprite_ram[(f*4)+1]+8) and $ff)-8;
    y:=sprite_ram[(f*4)+0];
    put_gfx_sprite(nchar,color,(atrib and $40)<>0,(atrib and $80)<>0,1);
    actualiza_gfx_sprite(x,y,3,1);
end;
end;

procedure idsoccer_draw_sprites;
var
  nchar:word;
  color,f,x,y,atrib:byte;
begin
for f:=0 to $7f do begin
    atrib:=sprite_ram[(f*4)+2];
    nchar:=sprite_ram[(f*4)+3]+((atrib and $10) shl 4)+((atrib and $80) shl 2);
    color:=(atrib and $f) shl 4;
    x:=((sprite_ram[(f*4)+1]+8) and $ff)-8;
    y:=sprite_ram[(f*4)+0];
    put_gfx_sprite(nchar,color,(atrib and $40)<>0,false,1);
    actualiza_gfx_sprite(x,y,3,1);
end;
end;

procedure update_video_mrdocastle;
var
  f,color,nchar:word;
  x,y,atrib:byte;
begin
for f:=$0 to $3ff do begin
  x:=f mod 32;
  y:=f div 32;
  if gfx[0].buffer[f] then begin
    atrib:=memoria[$b400+f];
    nchar:=memoria[$b000+f]+((atrib and $20) shl 3);
    color:=(atrib and $1f) shl 4;
    put_gfx(x*8,y*8,nchar,color,1,0);
    put_gfx_trans(x*8,y*8,nchar,color,2,0);
    gfx[0].buffer[f]:=false;
  end;
end;
actualiza_trozo(0,0,256,256,1,0,0,256,256,3);
draw_sprites;
actualiza_trozo(0,0,256,256,2,0,0,256,256,3);
actualiza_trozo_final(8,32,240,192,3);
end;

procedure eventos_mrdocastle;
begin
if event.arcade then begin
  //joy
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.right[1] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.up[1] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.left[1] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.down[1] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  //but
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
  //system
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  //joy2
  if arcade_input.right[1] then marcade.in3:=(marcade.in3 and $fe) else marcade.in3:=(marcade.in3 or $1);
  if arcade_input.up[1] then marcade.in3:=(marcade.in3 and $fd) else marcade.in3:=(marcade.in3 or $2);
  if arcade_input.left[1] then marcade.in3:=(marcade.in3 and $fb) else marcade.in3:=(marcade.in3 or $4);
  if arcade_input.down[1] then marcade.in3:=(marcade.in3 and $f7) else marcade.in3:=(marcade.in3 or $8);
  if arcade_input.right[0] then marcade.in3:=(marcade.in3 and $ef) else marcade.in3:=(marcade.in3 or $10);
  if arcade_input.up[0] then marcade.in3:=(marcade.in3 and $df) else marcade.in3:=(marcade.in3 or $20);
  if arcade_input.left[0] then marcade.in3:=(marcade.in3 and $bf) else marcade.in3:=(marcade.in3 or $40);
  if arcade_input.down[0] then marcade.in3:=(marcade.in3 and $7f) else marcade.in3:=(marcade.in3 or $80);
end;
end;

procedure mrdocastle_principal;
var
  f:word;
  h:byte;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
  for f:=0 to 263 do begin
    eventos_mrdocastle;
    case f of
        14,40,72,104,136,168,200,232:z80_1.change_irq(HOLD_LINE);
        224:begin
              z80_0.change_irq(HOLD_LINE);
              z80_2.change_nmi(PULSE_LINE);
              update_video_mrdocastle;
            end;
    end;
    for h:=1 to CPU_SYNC do begin
      z80_0.run(frame_main);
      frame_main:=frame_main+z80_0.tframes-z80_0.contador;
      z80_1.run(frame_snd);
      frame_snd:=frame_snd+z80_1.tframes-z80_1.contador;
      z80_2.run(frame_sub);
      frame_sub:=frame_sub+z80_2.tframes-z80_2.contador;
    end;
  end;
  video_sync;
end;
end;

//Mr Do Castler
function mrdocastle_getbyte(direccion:word):byte;
begin
case direccion of
  0..$97ff:mrdocastle_getbyte:=memoria[direccion];
  $9800..$99ff:mrdocastle_getbyte:=sprite_ram[direccion-$9800];
  $a000..$a008:mrdocastle_getbyte:=buffer0[direccion-$a000];
  $b000..$b3ff,$b800..$bbff:mrdocastle_getbyte:=memoria[$b000+(direccion and $3ff)];
  $b400..$b7ff,$bc00..$bfff:mrdocastle_getbyte:=memoria[$b400+(direccion and $3ff)];
end;
end;

procedure mrdocastle_putbyte(direccion:word;valor:byte);
begin
case direccion of
   0..$7fff:;
   $8000..$97ff:memoria[direccion]:=valor;
   $9800..$99ff:sprite_ram[direccion-$9800]:=valor;
   $a000..$a007:buffer1[direccion and 7]:=valor;
   $a008:begin
            buffer1[8]:=valor;
            z80_0.change_halt(ASSERT_LINE);
          end;
   $b000..$b3ff,$b800..$bbff:if memoria[$b000+(direccion and $3ff)]<>valor then begin
                                memoria[$b000+(direccion and $3ff)]:=valor;
                                gfx[0].buffer[direccion and $3ff]:=true;
                             end;
   $b400..$b7ff,$bc00..$bfff:if memoria[$b400+(direccion and $3ff)]<>valor then begin
                                memoria[$b400+(direccion and $3ff)]:=valor;
                                gfx[0].buffer[direccion and $3ff]:=true;
                             end;
   $e000:z80_1.change_nmi(PULSE_LINE);
end;
end;

function mrdocastle_getbyte_slave(direccion:word):byte;
begin
case direccion of
  0..$3fff,$8000..$87ff:mrdocastle_getbyte_slave:=mem_snd[direccion];
  $a000..$a008:mrdocastle_getbyte_slave:=buffer1[direccion-$a000];
  $c000..$c007,$c080..$c087:begin
      case buf_input of
        0:mrdocastle_getbyte_slave:=marcade.dswb; //dsw2
        1:mrdocastle_getbyte_slave:=marcade.dswa; //dsw1
        2:mrdocastle_getbyte_slave:=marcade.in0; //joy
        3:mrdocastle_getbyte_slave:=marcade.in3; //joy2
        5,7:mrdocastle_getbyte_slave:=$ff;
        4:mrdocastle_getbyte_slave:=marcade.in1; //but
        6:mrdocastle_getbyte_slave:=marcade.in2; //system
      end;
      main_screen.flip_main_screen:=(direccion and $80)<>0;
      buf_input:=(direccion-1) and $7;
  end;
end;
end;

procedure mrdocastle_putbyte_slave(direccion:word;valor:byte);
begin
case direccion of
   0..$3fff:;
   $8000..$87ff:mem_snd[direccion]:=valor;
   $a000..$a007:buffer0[direccion and 7]:=valor;
   $a008:begin
            buffer0[8]:=valor;
            z80_0.change_halt(CLEAR_LINE);
          end;
   $e000:sn_76496_0.Write(valor);
   $e400:sn_76496_1.Write(valor);
   $e800:sn_76496_2.Write(valor);
   $ec00:sn_76496_3.Write(valor);
end;
end;

function mrdocastle_getbyte_misc(direccion:word):byte;
begin
case direccion of
  0..$ff,$4000..$47ff:mrdocastle_getbyte_misc:=mem_misc[direccion];
  $8000..$8008:mrdocastle_getbyte_misc:=buffer1[direccion-$8000];
end;
end;

procedure mrdocastle_putbyte_misc(direccion:word;valor:byte);
begin
case direccion of
   0..$ff:;
   $4000..$47ff:mem_misc[direccion]:=valor;
end;
end;

procedure mrdocastle_update_sound;
begin
  sn_76496_0.Update;
  sn_76496_1.Update;
  sn_76496_2.Update;
  sn_76496_3.Update;
end;

//Do Run Run
function dorunrun_getbyte(direccion:word):byte;
begin
case direccion of
  0..$37ff,$4000..$9fff:dorunrun_getbyte:=memoria[direccion];
  $3800..$39ff:dorunrun_getbyte:=sprite_ram[direccion-$3800];
  $a000..$a008:dorunrun_getbyte:=buffer0[direccion-$a000];
  $b000..$b3ff:dorunrun_getbyte:=memoria[direccion and $3ff];
  $b400..$b7ff:dorunrun_getbyte:=memoria[direccion and $3ff];
end;
end;

procedure dorunrun_putbyte(direccion:word;valor:byte);
begin
case direccion of
   0..$1fff,$4000..$9fff:;
   $2000..$37ff:memoria[direccion]:=valor;
   $3800..$39ff:sprite_ram[direccion-$3800]:=valor;
   $a000..$a007:buffer1[direccion and 7]:=valor;
   $a008:begin
            buffer1[8]:=valor;
            z80_0.change_halt(ASSERT_LINE);
          end;
   $b000..$b7ff:if memoria[direccion]<>valor then begin
                  memoria[direccion]:=valor;
                  gfx[0].buffer[direccion and $3ff]:=true;
                end;
   $b800:z80_1.change_nmi(PULSE_LINE);
end;
end;

function dorunrun_getbyte_slave(direccion:word):byte;
begin
case direccion of
  0..$3fff,$8000..$87ff:dorunrun_getbyte_slave:=mem_snd[direccion];
  $c000..$c007,$c080..$c087:begin
      case buf_input of
        0:dorunrun_getbyte_slave:=marcade.dswb; //dsw2
        1:dorunrun_getbyte_slave:=marcade.dswa; //dsw1
        2:dorunrun_getbyte_slave:=marcade.in0; //joy
        3,5,7:dorunrun_getbyte_slave:=$ff;
        4:dorunrun_getbyte_slave:=marcade.in1; //but
        6:dorunrun_getbyte_slave:=marcade.in2; //system
      end;
      main_screen.flip_main_screen:=(direccion and $80)<>0;
      buf_input:=(direccion-1) and $7;
  end;
  $e000..$e008:dorunrun_getbyte_slave:=buffer1[direccion-$e000];
end;
end;

procedure dorunrun_putbyte_slave(direccion:word;valor:byte);
begin
case direccion of
   0..$3fff:;
   $8000..$87ff:mem_snd[direccion]:=valor;
   $a000:sn_76496_0.Write(valor);
   $a400:sn_76496_1.Write(valor);
   $a800:sn_76496_2.Write(valor);
   $ac00:sn_76496_3.Write(valor);
   $e000..$e007:buffer0[direccion and 7]:=valor;
   $e008:begin
            buffer0[8]:=valor;
            z80_0.change_halt(CLEAR_LINE);
         end;
end;
end;

//Indoor soccer
function idsoccer_getbyte(direccion:word):byte;
begin
case direccion of
  0..$57ff,$6000..$9fff:idsoccer_getbyte:=memoria[direccion];
  $5800..$59ff:idsoccer_getbyte:=sprite_ram[direccion-$5800];
  $a000..$a008:idsoccer_getbyte:=buffer0[direccion-$a000];
  $b000..$b3ff,$b800..$bbff:idsoccer_getbyte:=memoria[$b000+(direccion and $3ff)];
  $b400..$b7ff,$bc00..$bfff:idsoccer_getbyte:=memoria[$b400+(direccion and $3ff)];
  $c000:begin
          adpcm_status:=adpcm_status xor $80;
          idsoccer_getbyte:=adpcm_status;
        end;
end;
end;

procedure idsoccer_putbyte(direccion:word;valor:byte);
begin
case direccion of
   0..$3fff,$6000..$9fff:;
   $4000..$57ff:memoria[direccion]:=valor;
   $5800..$59ff:sprite_ram[direccion-$5800]:=valor;
   $a000..$a007:buffer1[direccion and 7]:=valor;
   $a008:begin
            buffer1[8]:=valor;
            z80_0.change_halt(ASSERT_LINE);
          end;
   $b000..$b3ff,$b800..$bbff:if memoria[$b000+(direccion and $3ff)]<>valor then begin
                                memoria[$b000+(direccion and $3ff)]:=valor;
                                gfx[0].buffer[direccion and $3ff]:=true;
                             end;
   $b400..$b7ff,$bc00..$bfff:if memoria[$b400+(direccion and $3ff)]<>valor then begin
                                memoria[$b400+(direccion and $3ff)]:=valor;
                                gfx[0].buffer[direccion and $3ff]:=true;
                             end;
   $c000:if (valor and $80)<>0 then begin
           msm5205_0.reset_w(true);
         end else begin
           msm5205_0.pos:=(valor and $7f)*$200;
           msm5205_0.reset_w(false);
         end;
   $e000:z80_1.change_nmi(PULSE_LINE);
end;
end;

procedure snd_adpcm;
begin
if (msm5205_0.data_val<>-1) then begin
		msm5205_0.data_w(msm5205_0.data_val and $f);
		msm5205_0.data_val:=-1;
    msm5205_0.pos:=msm5205_0.pos+1;
    if (msm5205_0.pos+1)=$10000 then msm5205_0.reset_w(true)
end else begin
		msm5205_0.data_val:=msm5205_0.rom_data[msm5205_0.pos];
		msm5205_0.data_w(msm5205_0.data_val shr 4);
end;
end;

procedure idoor_update_sound;
begin
  sn_76496_0.Update;
  sn_76496_1.Update;
  sn_76496_2.Update;
  sn_76496_3.Update;
  msm5205_0.update;
end;

//Main
procedure reset_mrdocastle;
begin
 z80_0.reset;
 z80_1.reset;
 z80_2.reset;
 sn_76496_0.reset;
 sn_76496_1.reset;
 sn_76496_2.reset;
 sn_76496_3.reset;
 if (main_vars.tipo_maquina=313) then msm5205_0.reset;
 frame_main:=z80_0.tframes;
 frame_snd:=z80_1.tframes;
 frame_sub:=z80_2.tframes;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 marcade.in3:=$ff;
 fillchar(buffer0,9,0);
 fillchar(buffer1,9,0);
 buf_input:=0;
 adpcm_status:=0;
end;

function iniciar_mrdocastle:boolean;
var
  colores:tpaleta;
  memoria_temp:array[0..$1ffff] of byte;
  f,ctemp1,ctemp2,ctemp3:byte;
  pos:word;
const
  pc_y:array[0..7] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32);
  ps_x:array[0..15] of dword=(0*4, 1*4, 2*4, 3*4, 4*4, 5*4, 6*4, 7*4,
      8*4, 9*4, 10*4, 11*4, 12*4, 13*4, 14*4, 15*4);
  ps_y:array[0..15] of dword=(0*64, 1*64, 2*64, 3*64, 4*64, 5*64, 6*64, 7*64,
			8*64, 9*64, 10*64, 11*64, 12*64, 13*64, 14*64, 15*64);
procedure conv_chars;
begin
  init_gfx(0,8,8,$200);
  gfx_set_desc_data(4,0,32*8,0,1,2,3);
  convert_gfx(0,0,@memoria_temp,@ps_x,@pc_y,false,false);
end;
procedure conv_sprites(size:word);
begin
  init_gfx(1,16,16,size);
  gfx_set_desc_data(4,0,128*8,0,1,2,3);
  convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,false);
end;
begin
llamadas_maquina.bucle_general:=mrdocastle_principal;
llamadas_maquina.reset:=reset_mrdocastle;
llamadas_maquina.fps_max:=59.659092;
llamadas_maquina.scanlines:=264*CPU_SYNC;
iniciar_mrdocastle:=false;
iniciar_audio(false);
screen_init(1,256,256);
screen_init(2,256,256,true);
screen_init(3,256,256,false,true);
if ((main_vars.tipo_maquina=308) or (main_vars.tipo_maquina=311)) then main_screen.rot270_screen:=true;
iniciar_video(240,192);
//Main CPU
z80_0:=cpu_z80.create(4000000);
//Slave CPU
z80_1:=cpu_z80.create(4000000);
if (main_vars.tipo_maquina=313) then z80_1.init_sound(idoor_update_sound)
  else z80_1.init_sound(mrdocastle_update_sound);
//Tercera CPU
z80_2:=cpu_z80.create(4000000);
z80_2.change_ram_calls(mrdocastle_getbyte_misc,mrdocastle_putbyte_misc);
//Sound Chips
sn_76496_0:=sn76496_chip.Create(4000000);
sn_76496_1:=sn76496_chip.Create(4000000);
sn_76496_2:=sn76496_chip.Create(4000000);
sn_76496_3:=sn76496_chip.Create(4000000);
draw_sprites:=docastle_draw_sprites;
case main_vars.tipo_maquina of
  308:begin //Mr Do Castle
          z80_0.change_ram_calls(mrdocastle_getbyte,mrdocastle_putbyte);
          if not(roms_load(@memoria,mrdocastle_rom)) then exit;
          z80_1.change_ram_calls(mrdocastle_getbyte_slave,mrdocastle_putbyte_slave);
          if not(roms_load(@mem_snd,mrdocastle_slave)) then exit;
          if not(roms_load(@mem_misc,mrdocastle_misc)) then exit;
          //convertir chars
          if not(roms_load(@memoria_temp,mrdocastle_char)) then exit;
          conv_chars;
          for f:=0 to 7 do gfx[0].trans[f]:=true;
          //convertir sprites
          if not(roms_load(@memoria_temp,mrdocastle_sprites)) then exit;
          conv_sprites($100);
          gfx[1].trans[0]:=true;
          //dip
          marcade.dswa:=$df;
          marcade.dswb:=$ff;
          marcade.dswa_val:=@mrdocastle_dip_a;
          marcade.dswb_val:=@mrdocastle_dip_b;
          if not(roms_load(@memoria_temp,mrdocastle_pal)) then exit;
      end;
  309:begin //Do! Run Run
          z80_0.change_ram_calls(dorunrun_getbyte,dorunrun_putbyte);
          if not(roms_load(@memoria,dorunrun_rom)) then exit;
          z80_1.change_ram_calls(dorunrun_getbyte_slave,dorunrun_putbyte_slave);
          if not(roms_load(@mem_snd,dorunrun_slave)) then exit;
          if not(roms_load(@mem_misc,dorunrun_misc)) then exit;
          //convertir chars
          if not(roms_load(@memoria_temp,dorunrun_char)) then exit;
          conv_chars;
          for f:=8 to $f do gfx[0].trans[f]:=true;
          //convertir sprites
          if not(roms_load(@memoria_temp,dorunrun_sprites)) then exit;
          conv_sprites($100);
          gfx[1].trans[7]:=true;
          //dip
          marcade.dswa:=$df;
          marcade.dswb:=$ff;
          marcade.dswa_val:=@dorunrun_dip_a;
          marcade.dswb_val:=@mrdocastle_dip_b;
          if not(roms_load(@memoria_temp,dorunrun_pal)) then exit;
      end;
  310:begin //Mr Do wild ride
          z80_0.change_ram_calls(dorunrun_getbyte,dorunrun_putbyte);
          if not(roms_load(@memoria,dowild_rom)) then exit;
          z80_1.change_ram_calls(dorunrun_getbyte_slave,dorunrun_putbyte_slave);
          if not(roms_load(@mem_snd,dowild_slave)) then exit;
          if not(roms_load(@mem_misc,dowild_misc)) then exit;
          //convertir chars
          if not(roms_load(@memoria_temp,dowild_char)) then exit;
          conv_chars;
          for f:=8 to $f do gfx[0].trans[f]:=true;
          //convertir sprites
          if not(roms_load(@memoria_temp,dowild_sprites)) then exit;
          conv_sprites($100);
          gfx[1].trans[0]:=true;
          gfx[1].trans[7]:=true;
          //dip
          marcade.dswa:=$df;
          marcade.dswb:=$ff;
          marcade.dswa_val:=@dowild_dip_a;
          marcade.dswb_val:=@mrdocastle_dip_b;
          if not(roms_load(@memoria_temp,dowild_pal)) then exit;
      end;
  311:begin //Jumping Jack
          z80_0.change_ram_calls(dorunrun_getbyte,dorunrun_putbyte);
          if not(roms_load(@memoria,jjack_rom)) then exit;
          z80_1.change_ram_calls(dorunrun_getbyte_slave,dorunrun_putbyte_slave);
          if not(roms_load(@mem_snd,jjack_slave)) then exit;
          if not(roms_load(@mem_misc,jjack_misc)) then exit;
          //convertir chars
          if not(roms_load(@memoria_temp,jjack_char)) then exit;
          conv_chars;
          for f:=8 to $f do gfx[0].trans[f]:=true;
          //convertir sprites
          if not(roms_load(@memoria_temp,jjack_sprites)) then exit;
          conv_sprites($100);
          gfx[1].trans[0]:=true;
          gfx[1].trans[$f]:=true;
          //dip
          marcade.dswa:=$df;
          marcade.dswb:=$ff;
          marcade.dswa_val:=@jjack_dip_a;
          marcade.dswb_val:=@mrdocastle_dip_b;
          if not(roms_load(@memoria_temp,jjack_pal)) then exit;
      end;
  312:begin //Kick Rider
          z80_0.change_ram_calls(dorunrun_getbyte,dorunrun_putbyte);
          if not(roms_load(@memoria,kickridr_rom)) then exit;
          z80_1.change_ram_calls(dorunrun_getbyte_slave,dorunrun_putbyte_slave);
          if not(roms_load(@mem_snd,kickridr_slave)) then exit;
          if not(roms_load(@mem_misc,kickridr_misc)) then exit;
          //convertir chars
          if not(roms_load(@memoria_temp,kickridr_char)) then exit;
          conv_chars;
          for f:=8 to $f do gfx[0].trans[f]:=true;
          //convertir sprites
          if not(roms_load(@memoria_temp,kickridr_sprites)) then exit;
          conv_sprites($100);
          gfx[1].trans[7]:=true;
          //dip
          marcade.dswa:=$df;
          marcade.dswb:=$ff;
          marcade.dswa_val:=@kickridr_dip_a;
          marcade.dswb_val:=@mrdocastle_dip_b;
          if not(roms_load(@memoria_temp,kickridr_pal)) then exit;
      end;
      313:begin //Indoor Soccer
          draw_sprites:=idsoccer_draw_sprites;
          z80_0.change_ram_calls(idsoccer_getbyte,idsoccer_putbyte);
          if not(roms_load(@memoria,idsoccer_rom)) then exit;
          z80_1.change_ram_calls(mrdocastle_getbyte_slave,mrdocastle_putbyte_slave);
          if not(roms_load(@mem_snd,idsoccer_slave)) then exit;
          if not(roms_load(@mem_misc,idsoccer_misc)) then exit;
          msm5205_0:=MSM5205_chip.create(384000,MSM5205_S64_4B,0.4,$10000);
          msm5205_0.change_advance(snd_adpcm);
          if not(roms_load(msm5205_0.rom_data,idsoccer_adpcm)) then exit;
          //convertir chars
          if not(roms_load(@memoria_temp,idsoccer_char)) then exit;
          conv_chars;
          for f:=8 to $f do gfx[0].trans[f]:=true;
          //convertir sprites
          if not(roms_load(@memoria_temp,idsoccer_sprites)) then exit;
          conv_sprites($400);
          gfx[1].trans[7]:=true;
          //dip
          marcade.dswa:=$ff;
          marcade.dswb:=$ff;
          marcade.dswa_val:=@idsoccer_dip_a;
          marcade.dswb_val:=@mrdocastle_dip_b;
          if not(roms_load(@memoria_temp,idsoccer_pal)) then exit;
      end;
end;
//pal
for f:=0 to 255 do begin
  pos:=((f and $f8) shl 1) or (f and $07);
  ctemp1:=(memoria_temp[f] shr 5) and 1;
  ctemp2:=(memoria_temp[f] shr 6) and 1;
  ctemp3:=(memoria_temp[f] shr 7) and 1;
  colores[pos].r:=$23*ctemp1+$4b*ctemp2+$91*ctemp3;
  colores[pos or 8].r:=$23*ctemp1+$4b*ctemp2+$91*ctemp3;
  ctemp1:=(memoria_temp[f] shr 2) and 1;
  ctemp2:=(memoria_temp[f] shr 3) and 1;
  ctemp3:=(memoria_temp[f] shr 4) and 1;
  colores[pos].g:=$23*ctemp1+$4b*ctemp2+$91*ctemp3;
  colores[pos or 8].g:=$23*ctemp1+$4b*ctemp2+$91*ctemp3;
  ctemp1:=0;
  ctemp2:=(memoria_temp[f] shr 0) and 1;
  ctemp3:=(memoria_temp[f] shr 1) and 1;
  colores[pos].b:=$23*ctemp1+$4b*ctemp2+$91*ctemp3;
  colores[pos or 8].b:=$23*ctemp1+$4b*ctemp2+$91*ctemp3;
end;
set_pal(colores,512);
//final
iniciar_mrdocastle:=true;
end;

end.
