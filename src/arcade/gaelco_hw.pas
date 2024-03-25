unit gaelco_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m68000,main_engine,controls_engine,gfx_engine,ym_3812,m6809,
     oki6295,gaelco_hw_decrypt,rom_engine,pal_engine,sound_engine;

function iniciar_gaelco_hw:boolean;

implementation
const
        //Big Karnak
        bigkarnak_rom:array[0..1] of tipo_roms=(
        (n:'d16';l:$40000;p:0;crc:$44fb9c73),(n:'d19';l:$40000;p:$1;crc:$ff79dfdd));
        bigkarnak_sound:tipo_roms=(n:'d5';l:$10000;p:0;crc:$3b73b9c5);
        bigkarnak_gfx:array[0..7] of tipo_roms=(
        (n:'h5' ;l:$80000;p:$0;crc:$20e239ff),(n:'h5'; l:$80000;p:$80000;crc:$20e239ff),
        (n:'h10';l:$80000;p:$100000;crc:$ab442855),(n:'h10';l:$80000;p:$180000;crc:$ab442855),
        (n:'h8' ;l:$80000;p:$200000;crc:$83dce5a3),(n:'h8'; l:$80000;p:$280000;crc:$83dce5a3),
        (n:'h6' ;l:$80000;p:$300000;crc:$24e84b24),(n:'h6'; l:$80000;p:$380000;crc:$24e84b24));
        bigkarnak_adpcm:tipo_roms=(n:'d1';l:$40000;p:0;crc:$26444ad1);
        //Thunder Hoop
        thoop_rom:array[0..1] of tipo_roms=(
        (n:'th18dea1.040';l:$80000;p:0;crc:$59bad625),(n:'th161eb4.020';l:$40000;p:$1;crc:$6add61ed));
        thoop_gfx:array[0..3] of tipo_roms=(
        (n:'c09' ;l:$100000;p:$0;crc:$06f0edbf),(n:'c10'; l:$100000;p:$100000;crc:$2d227085),
        (n:'c11';l:$100000;p:$200000;crc:$7403ef7e),(n:'c12';l:$100000;p:$300000;crc:$29a5ca36));
        thoop_adpcm:tipo_roms=(n:'sound';l:$100000;p:0;crc:$99f80961);
        //Squash
        squash_rom:array[0..1] of tipo_roms=(
        (n:'squash.d18';l:$20000;p:0;crc:$ce7aae96),(n:'squash.d16';l:$20000;p:$1;crc:$8ffaedd7));
        squash_gfx:array[0..3] of tipo_roms=(
        (n:'squash.c09' ;l:$80000;p:$0;crc:$0bb91c69),(n:'squash.c10'; l:$80000;p:$80000;crc:$892a035c),
        (n:'squash.c11';l:$80000;p:$100000;crc:$9e19694d),(n:'squash.c12';l:$80000;p:$180000;crc:$5c440645));
        squash_adpcm:tipo_roms=(n:'squash.d01';l:$80000;p:0;crc:$a1b9651b);
        //Biomechanical Toy
        biomtoy_rom:array[0..1] of tipo_roms=(
        (n:'d18';l:$80000;p:0;crc:$4569ce64),(n:'d16';l:$80000;p:$1;crc:$739449bd));
        biomtoy_gfx:array[0..7] of tipo_roms=(
        (n:'h6' ;l:$80000;p:$0;crc:$9416a729),(n:'j6'; l:$80000;p:$80000;crc:$e923728b),
        (n:'h7';l:$80000;p:$100000;crc:$9c984d7b),(n:'j7';l:$80000;p:$180000;crc:$0e18fac2),
        (n:'h9' ;l:$80000;p:$200000;crc:$8c1f6718),(n:'j9'; l:$80000;p:$280000;crc:$1c93f050),
        (n:'h10';l:$80000;p:$300000;crc:$aca1702b),(n:'j10';l:$80000;p:$380000;crc:$8e3e96cc));
        biomtoy_adpcm:array[0..1] of tipo_roms=(
        (n:'c1';l:$80000;p:0;crc:$0f02de7e),(n:'c3';l:$80000;p:$80000;crc:$914e4bbc));
        //DIP
        gaelco_dip:array [0..2] of def_dip=(
        (mask:$0f;name:'Coin A';number:11;dip:((dip_val:$07;dip_name:'4C 1C'),(dip_val:$08;dip_name:'3C 1C'),(dip_val:$09;dip_name:'2C 1C'),(dip_val:$0f;dip_name:'1C 1C'),(dip_val:$06;dip_name:'2C 3C'),(dip_val:$0e;dip_name:'1C 2C'),(dip_val:$0d;dip_name:'1C 3C'),(dip_val:$0c;dip_name:'1C 4C'),(dip_val:$0b;dip_name:'1C 5C'),(dip_val:$0a;dip_name:'1C 6C'),(dip_val:$00;dip_name:'Free Play (If Coin B too)'),(),(),(),(),())),
        (mask:$f0;name:'Coin B';number:11;dip:((dip_val:$70;dip_name:'4C 1C'),(dip_val:$80;dip_name:'3C 1C'),(dip_val:$90;dip_name:'2C 1C'),(dip_val:$f0;dip_name:'1C 1C'),(dip_val:$60;dip_name:'2C 3C'),(dip_val:$e0;dip_name:'1C 2C'),(dip_val:$d0;dip_name:'1C 3C'),(dip_val:$c0;dip_name:'1C 4C'),(dip_val:$b0;dip_name:'1C 5C'),(dip_val:$a0;dip_name:'1C 6C'),(dip_val:$00;dip_name:'Free Play (If Coin A too)'),(),(),(),(),())),());
        bigkarnak_dsw_2:array [0..5] of def_dip=(
        (mask:$07;name:'Difficulty';number:8;dip:((dip_val:$07;dip_name:'0'),(dip_val:$06;dip_name:'1'),(dip_val:$05;dip_name:'2'),(dip_val:$04;dip_name:'3'),(dip_val:$03;dip_name:'4'),(dip_val:$02;dip_name:'5'),(dip_val:$01;dip_name:'6'),(dip_val:$00;dip_name:'7'),(),(),(),(),(),(),(),())),
        (mask:$18;name:'Lives';number:4;dip:((dip_val:$18;dip_name:'1'),(dip_val:$10;dip_name:'2'),(dip_val:$08;dip_name:'3'),(dip_val:$00;dip_name:'4'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Demo Sounds';number:2;dip:((dip_val:$20;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Impact';number:2;dip:((dip_val:$40;dip_name:'On'),(dip_val:$0;dip_name:'Off'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Service';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        bigkarnak_dsw_3:array [0..1] of def_dip=(
        (mask:$2;name:'Service';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        thoop_dsw_1:array [0..4] of def_dip=(
        (mask:$07;name:'Coin A';number:8;dip:((dip_val:$02;dip_name:'6C 1C'),(dip_val:$03;dip_name:'5C 1C'),(dip_val:$04;dip_name:'4C 1C'),(dip_val:$05;dip_name:'3C 1C'),(dip_val:$06;dip_name:'2C 1C'),(dip_val:$01;dip_name:'3C 2C'),(dip_val:$00;dip_name:'4C 3C'),(dip_val:$07;dip_name:'1C 1C'),(),(),(),(),(),(),(),())),
        (mask:$38;name:'Coin B';number:8;dip:((dip_val:$38;dip_name:'1C 1C'),(dip_val:$00;dip_name:'3C 4C'),(dip_val:$08;dip_name:'2C 3C'),(dip_val:$30;dip_name:'1C 2C'),(dip_val:$28;dip_name:'1C 3C'),(dip_val:$20;dip_name:'1C 4C'),(dip_val:$18;dip_name:'1C 5C'),(dip_val:$10;dip_name:'1C 6C'),(),(),(),(),(),(),(),())),
        (mask:$40;name:'2 Credits to Start, 1 to Continue';number:2;dip:((dip_val:$40;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Free Play';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        thoop_dsw_2:array [0..6] of def_dip=(
        (mask:$03;name:'Difficulty';number:4;dip:((dip_val:$03;dip_name:'Easy'),(dip_val:$02;dip_name:'Normal'),(dip_val:$01;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$04;name:'Player Controls';number:2;dip:((dip_val:$4;dip_name:'2 Joysticks'),(dip_val:$0;dip_name:'1 Joysticks'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$18;name:'Lives';number:4;dip:((dip_val:$0;dip_name:'4'),(dip_val:$8;dip_name:'3'),(dip_val:$10;dip_name:'2'),(dip_val:$18;dip_name:'1'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Demo Sounds';number:2;dip:((dip_val:$20;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Cabinet';number:2;dip:((dip_val:$40;dip_name:'Upright'),(dip_val:$0;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Service';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        squash_dsw_1:array [0..4] of def_dip=(
        (mask:$07;name:'Coin A';number:8;dip:((dip_val:$02;dip_name:'6C 1C'),(dip_val:$03;dip_name:'5C 1C'),(dip_val:$04;dip_name:'4C 1C'),(dip_val:$05;dip_name:'3C 1C'),(dip_val:$06;dip_name:'2C 1C'),(dip_val:$01;dip_name:'3C 2C'),(dip_val:$00;dip_name:'4C 3C'),(dip_val:$07;dip_name:'1C 1C'),(),(),(),(),(),(),(),())),
        (mask:$38;name:'Coin B';number:8;dip:((dip_val:$38;dip_name:'1C 1C'),(dip_val:$00;dip_name:'3C 4C'),(dip_val:$08;dip_name:'2C 3C'),(dip_val:$30;dip_name:'1C 2C'),(dip_val:$28;dip_name:'1C 3C'),(dip_val:$20;dip_name:'1C 4C'),(dip_val:$18;dip_name:'1C 5C'),(dip_val:$10;dip_name:'1C 6C'),(),(),(),(),(),(),(),())),
        (mask:$40;name:'2 Player Continue';number:2;dip:((dip_val:$40;dip_name:'2 Credits / 5 Games'),(dip_val:$0;dip_name:'1 Credit / 3 Games'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Free Play';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        squash_dsw_2:array [0..4] of def_dip=(
        (mask:$03;name:'Difficulty';number:4;dip:((dip_val:$02;dip_name:'Easy'),(dip_val:$03;dip_name:'Normal'),(dip_val:$01;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0c;name:'Number of Faults';number:4;dip:((dip_val:$8;dip_name:'4'),(dip_val:$c;dip_name:'5'),(dip_val:$4;dip_name:'6'),(dip_val:$0;dip_name:'7'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Demo Sounds';number:2;dip:((dip_val:$20;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Service';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        biomtoy_dsw_2:array [0..4] of def_dip=(
        (mask:$1;name:'Service';number:2;dip:((dip_val:$1;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$8;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Lives';number:4;dip:((dip_val:$20;dip_name:'1'),(dip_val:$10;dip_name:'2'),(dip_val:$30;dip_name:'3'),(dip_val:$0;dip_name:'4'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Difficulty';number:4;dip:((dip_val:$40;dip_name:'Easy'),(dip_val:$c0;dip_name:'Normal'),(dip_val:$80;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 scroll_x0,scroll_y0,scroll_x1,scroll_y1:word;
 rom:array[0..$7ffff] of word;
 video_ram:array[0..$1fff] of word;
 sprite_ram:array[0..$7ff] of word;
 main_ram:array[0..$7fff] of word;
 sound_latch,gaelco_dec_val:byte;
 oki_rom:array[0..$c,0..$ffff] of byte;

procedure draw_sprites_bk(pri:byte);
var
	x,i,color,attr,attr2,nchar:word;
  flipx,flipy:boolean;
  y,a,priority:byte;
begin
	for i:=$1 to $1ff do begin
    attr:=sprite_ram[(i*4)-1];
    if (attr and $ff)=$f0 then continue;  //el sprite no se va a ver...
    attr2:=sprite_ram[(i*4)+1];
    color:=(attr2 and $7e00) shr 9;
    if (color>=$38) then priority:=4
      else priority:=(attr and $3000) shr 12;
    if pri<>priority then continue;
    y:=240-(attr and $ff);
    color:=color shl 4;
    flipx:=(attr and $4000)<>0;
    flipy:=(attr and $8000)<>0;
    x:=(attr2 and $1ff)-15;
		nchar:=sprite_ram[(i*4)+2];
    if (attr and $800)<>0 then begin
      put_gfx_sprite(nchar,color,flipx,flipy,0);
      actualiza_gfx_sprite(x,y,17,0);
    end else begin
      nchar:=nchar and $fffc;
      a:=(byte(flipx) shl 1) or byte(flipy);
      put_gfx_sprite_diff((nchar+0) xor a,color,flipx,flipy,0,0,0);
      put_gfx_sprite_diff((nchar+2) xor a,color,flipx,flipy,0,8,0);
      put_gfx_sprite_diff((nchar+1) xor a,color,flipx,flipy,0,0,8);
      put_gfx_sprite_diff((nchar+3) xor a,color,flipx,flipy,0,8,8);
      actualiza_gfx_sprite_size(x,y,17,16,16);
    end;
	 end;
end;

procedure draw_all_bigk;
var
  f,color,sx,sy,pos,x,y,nchar,atrib1,atrib2:word;
  pant,h:byte;
begin
for f:=0 to $164 do begin
 y:=f div 21;
 x:=f mod 21;
 //Draw back
 //Calcular posicion
 sx:=x+((scroll_x0 and $1f0) shr 4);
 sy:=y+((scroll_y0 and $1f0) shr 4);
 pos:=(sx and $1f)+((sy and $1f)*32);
 //Calcular color
 atrib2:=video_ram[$1+(pos*2)];
 color:=atrib2 and $3f;
 if (gfx[1].buffer[pos] or buffer_color[color]) then begin
   pant:=((atrib2 shr 6) and $3)+1;
   atrib1:=video_ram[$0+(pos*2)];
   nchar:=$4000+((atrib1 and $fffc) shr 2);
   put_gfx_trans_flip(x*16,y*16,nchar,color shl 4,pant,1,(atrib1 and 1)<>0,(atrib1 and 2)<>0);
   if pant<>4 then put_gfx_trans_flip_alt(x*16,y*16,nchar,color shl 4,pant+4,1,(atrib1 and 1)<>0,(atrib1 and 2)<>0,pant);
   for h:=1 to 4 do
      if (h<>pant) then begin
        put_gfx_block_trans(x*16,y*16,h,16,16);
        if h<>4 then put_gfx_block_trans(x*16,y*16,h+4,16,16)
      end;
   gfx[1].buffer[pos]:=false;
 end;
 //Draw Front
 //Calcular posicion
 sx:=x+((scroll_x1 and $1f0) shr 4);
 sy:=y+((scroll_y1 and $1f0) shr 4);
 pos:=(sx and $1f)+((sy and $1f)*32);
 //Calcular color
 atrib2:=video_ram[$801+(pos*2)];
 color:=atrib2 and $3f;
 if (gfx[1].buffer[pos+$400] or buffer_color[color]) then begin
  pant:=((atrib2 shr 6) and $3)+9;
  atrib1:=video_ram[$800+(pos*2)];
  nchar:=$4000+((atrib1 and $fffc) shr 2);
  put_gfx_trans_flip(x*16,y*16,nchar,color shl 4,pant,1,(atrib1 and 1)<>0,(atrib1 and 2)<>0);
  if pant<>12 then put_gfx_trans_flip_alt(x*16,y*16,nchar,color shl 4,pant+4,1,(atrib1 and 1)<>0,(atrib1 and 2)<>0,pant-8);
  for h:=9 to 12 do
    if (h<>pant) then begin
      put_gfx_block_trans(x*16,y*16,h,16,16);
      if h<>12 then put_gfx_block_trans(x*16,y*16,h+4,16,16);
    end;
  gfx[1].buffer[pos+$400]:=false;
 end;
end;
end;

procedure update_video_bigk;
begin
fill_full_screen(17,0);
draw_all_bigk;
scroll_x_y(4,17,scroll_x0 and $f,scroll_y0 and $f);  //PRI0
scroll_x_y(12,17,scroll_x1 and $f,scroll_y1 and $f); //PRI0
draw_sprites_bk(3);
//scroll_x_y(8,17,scroll_x0 and $f,scroll_y0 and $f); //Totalmente transparente!
//scroll_x_y(16,17,scroll_x1 and $f,scroll_y1 and $f); //Totalmente transparente!
scroll_x_y(3,17,scroll_x0 and $f,scroll_y0 and $f);  //PRI1
scroll_x_y(11,17,scroll_x1 and $f,scroll_y1 and $f); //PRI1
draw_sprites_bk(2);
scroll_x_y(7,17,scroll_x0 and $f,scroll_y0 and $f); //PRI1 encima sprites
scroll_x_y(15,17,scroll_x1 and $f,scroll_y1 and $f); //PRI1 encima sprites
scroll_x_y(2,17,scroll_x0 and $f,scroll_y0 and $f); //PRI2
scroll_x_y(10,17,scroll_x1 and $f,scroll_y1 and $f); //PRI2
draw_sprites_bk(1);
scroll_x_y(6,17,scroll_x0 and $f,scroll_y0 and $f); //PRI2 encima sprites
scroll_x_y(14,17,scroll_x1 and $f,scroll_y1 and $f); //PRI2 encima sprites
scroll_x_y(1,17,scroll_x0 and $f,scroll_y0 and $f); //PRI3
scroll_x_y(9,17,scroll_x1 and $f,scroll_y1 and $f); //PRI3
draw_sprites_bk(0);
scroll_x_y(5,17,scroll_x0 and $f,scroll_y0 and $f); //PRI3 encima sprites
scroll_x_y(13,17,scroll_x1 and $f,scroll_y1 and $f); //PRI3 encima sprites
draw_sprites_bk(4);
actualiza_trozo_final(0,16,320,240,17);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure eventos_gaelco_hw;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $Fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $Fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  //P2
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $Fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $Fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
end;
end;

procedure cambiar_color(tmp_color,numero:word);
var
  color:tcolor;
begin
  color.b:=pal5bit(tmp_color shr 10);
  color.g:=pal5bit(tmp_color shr 5);
  color.r:=pal5bit(tmp_color);
  set_pal_color(color,numero);
  buffer_color[(numero shr 4) and $3f]:=true;
end;

//Big Karnak
procedure bigk_principal;
var
  frame_m,frame_s:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
frame_s:=m6809_0.tframes;
while EmuStatus=EsRunning do begin
  for f:=0 to 511 do begin
    //main
    m68000_0.run(frame_m);
    frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
    //sound
    m6809_0.run(frame_s);
    frame_s:=frame_s+m6809_0.tframes-m6809_0.contador;
    if f=255 then begin
      m68000_0.irq[6]:=HOLD_LINE;
      update_video_bigk;
    end;
  end;
  eventos_gaelco_hw;
  video_sync;
end;
end;

function bigk_getword(direccion:dword):word;
begin
case direccion of
    0..$7ffff:bigk_getword:=rom[direccion shr 1];
    $100000..$103fff:bigk_getword:=video_ram[(direccion and $3fff) shr 1];
    $440000..$440fff:bigk_getword:=sprite_ram[(direccion and $fff) shr 1];
    $200000..$2007ff:bigk_getword:=buffer_paleta[(direccion and $7ff) shr 1];
    $700000:bigk_getword:=marcade.dswa;
    $700002:bigk_getword:=marcade.dswb;
    $700004:bigk_getword:=marcade.in0;
    $700006:bigk_getword:=marcade.in1;
    $700008:bigk_getword:=marcade.dswc;
    $ff8000..$ffffff:bigk_getword:=main_ram[(direccion and $7fff) shr 1];
end;
end;

procedure bigk_putword(direccion:dword;valor:word);
begin
case direccion of
    0..$7ffff:; //ROM
    $100000..$100fff:if video_ram[(direccion and $fff) shr 1]<>valor then begin
                      video_ram[(direccion and $fff) shr 1]:=valor;
                      gfx[1].buffer[(direccion and $fff) div 4]:=true;
                   end;
    $101000..$101fff:if video_ram[(direccion and $1fff) shr 1]<>valor then begin
                      video_ram[(direccion and $1fff) shr 1]:=valor;
                      gfx[1].buffer[((direccion and $fff) shr 2)+$400]:=true;
                   end;
    $102000..$103fff:video_ram[(direccion and $3fff) shr 1]:=valor;
    $108000:if scroll_y0<>(valor and $1ff) then begin
              if abs((scroll_y0 and $1f0)-(valor and $1f0))>15 then fillchar(gfx[1].buffer[0],$400,1);
              scroll_y0:=valor and $1ff;
            end;
    $108002:if scroll_x0<>((valor+4) and $1ff) then begin
              if abs((scroll_x0 and $1f0)-((valor+4) and $1f0))>15 then fillchar(gfx[1].buffer[0],$400,1);
              scroll_x0:=(valor+4) and $1ff;
            end;
    $108004:if scroll_y1<>(valor and $1ff) then begin
              if abs((scroll_y1 and $1f0)-(valor and $1f0))>15 then fillchar(gfx[1].buffer[$400],$400,1);
              scroll_y1:=valor and $1ff;
            end;
    $108006:if scroll_x1<>(valor and $1ff) then begin
              if abs((scroll_x1 and $1f0)-(valor and $1f0))>15 then fillchar(gfx[1].buffer[$400],$400,1);
              scroll_x1:=valor and $1ff;
            end;
    $10800c:;
    $200000..$2007ff:if buffer_paleta[(direccion and $7ff) shr 1]<>valor then begin
                        cambiar_color(valor,(direccion and $7ff) shr 1);
                        buffer_paleta[(direccion and $7ff) shr 1]:=valor;
                     end;
    $440000..$440fff:sprite_ram[(direccion and $fff) shr 1]:=valor;
    //70000a..70003b:;
    $70000e:begin
            sound_latch:=valor and $ff;
            m6809_0.change_firq(HOLD_LINE);
          end;
    $ff8000..$ffffff:main_ram[(direccion and $7fff) shr 1]:=valor;
  end;
end;

function bigk_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7ff,$c00..$ffff:bigk_snd_getbyte:=mem_snd[direccion];
  $800,$801:bigk_snd_getbyte:=oki_6295_0.read;
  $a00:bigk_snd_getbyte:=ym3812_0.status;
  $b00:bigk_snd_getbyte:=sound_latch;
end;
end;

procedure bigk_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
    0..$7ff:mem_snd[direccion]:=valor;
    $800,$801:oki_6295_0.write(valor);
    $a00:ym3812_0.control(valor);
    $a01:ym3812_0.write(valor);
    $c00..$ffff:; //ROM
end;
end;

procedure bigk_sound_update;
begin
  ym3812_0.update;
  oki_6295_0.update;
end;

//Thunder Hoop
procedure draw_sprites_thoop(pri:byte);
var
	x,i,color,attr,attr2,nchar:word;
  flipx,flipy:boolean;
  y,a,priority:byte;
begin
	for i:=$1 to $1ff do begin
    attr:=sprite_ram[(i*4)-1];
    if (attr and $ff)=$f0 then continue;  //El sprite no se va a ver
    priority:=(attr shr 12) and $3;
    if pri<>priority then continue;
    attr2:=sprite_ram[(i*4)+1];
    color:=(attr2 and $7e00) shr 9;
    y:=240-(attr and $ff);
    color:=color shl 4;
    flipx:=(attr and $4000)<>0;
    flipy:=(attr and $8000)<>0;
    x:=(attr2 and $1ff)-15;
		nchar:=sprite_ram[(i*4)+2];
    if (attr and $800)<>0 then begin
      put_gfx_sprite(nchar,color,flipx,flipy,0);
      actualiza_gfx_sprite(x,y,17,0);
    end else begin
      nchar:=nchar and $fffc;
      a:=(byte(flipx) shl 1) or byte(flipy);
      put_gfx_sprite_diff((nchar+0) xor a,color,flipx,flipy,0,0,0);
      put_gfx_sprite_diff((nchar+2) xor a,color,flipx,flipy,0,8,0);
      put_gfx_sprite_diff((nchar+1) xor a,color,flipx,flipy,0,0,8);
      put_gfx_sprite_diff((nchar+3) xor a,color,flipx,flipy,0,8,8);
      actualiza_gfx_sprite_size(x,y,17,16,16);
    end;
	 end;
end;

procedure draw_all_thoop;
var
  f,color,sx,sy,x,y,nchar,atrib1,atrib2,pos:word;
  pant,h:byte;
begin
for f:=0 to $164 do begin
 y:=f div 21;
 x:=f mod 21;
 //Draw back
 //Calcular posicion
 sx:=x+((scroll_x0 and $1f0) shr 4);
 sy:=y+((scroll_y0 and $1f0) shr 4);
 pos:=(sx and $1f)+((sy and $1f)*32);
 //Calcular color
 atrib2:=video_ram[$1+(pos*2)];
 color:=atrib2 and $3f;
 if (gfx[1].buffer[pos] or buffer_color[color]) then begin
   pant:=((atrib2 shr 6) and $3)+1;
   atrib1:=video_ram[$0+(pos*2)];
   nchar:=$4000+((atrib1 and $fffc) shr 2);
   put_gfx_trans_flip(x*16,y*16,nchar,color shl 4,pant,1,(atrib1 and 1)<>0,(atrib1 and 2)<>0);
   for h:=1 to 4 do if (h<>pant) then put_gfx_block_trans(x*16,y*16,h,16,16);
   gfx[1].buffer[pos]:=false;
 end;
 //Draw Front
 //Calcular posicion
 sx:=x+((scroll_x1 and $1f0) shr 4);
 sy:=y+((scroll_y1 and $1f0) shr 4);
 pos:=(sx and $1f)+((sy and $1f)*32);
 //Calcular color
 atrib2:=video_ram[$801+(pos*2)];
 color:=atrib2 and $3f;
 if (gfx[1].buffer[pos+$400] or buffer_color[color]) then begin
  pant:=((atrib2 shr 6) and $3)+5;
  atrib1:=video_ram[$800+(pos*2)];
  nchar:=$4000+((atrib1 and $fffc) shr 2);
  put_gfx_trans_flip(x*16,y*16,nchar,color shl 4,pant,1,(atrib1 and 1)<>0,(atrib1 and 2)<>0);
  for h:=5 to 8 do if (h<>pant) then put_gfx_block_trans(x*16,y*16,h,16,16);
  gfx[1].buffer[pos+$400]:=false;
 end;
end;
end;

procedure update_video_thoop;
begin
fill_full_screen(17,0);
draw_all_thoop;
scroll_x_y(4,17,scroll_x0 and $f,scroll_y0 and $f);
scroll_x_y(8,17,scroll_x1 and $f,scroll_y1 and $f);
draw_sprites_thoop(3);
scroll_x_y(3,17,scroll_x0 and $f,scroll_y0 and $f);
scroll_x_y(7,17,scroll_x1 and $f,scroll_y1 and $f);
draw_sprites_thoop(2);
draw_sprites_thoop(1);
scroll_x_y(2,17,scroll_x0 and $f,scroll_y0 and $f);
scroll_x_y(6,17,scroll_x1 and $f,scroll_y1 and $f);
draw_sprites_thoop(0);
scroll_x_y(1,17,scroll_x0 and $f,scroll_y0 and $f);
scroll_x_y(5,17,scroll_x1 and $f,scroll_y1 and $f);
actualiza_trozo_final(0,16,320,240,17);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure thoop_principal;
var
  frame_m:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
while EmuStatus=EsRunning do begin
  for f:=0 to 511 do begin
     m68000_0.run(frame_m);
     frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
     if f=255 then begin
        m68000_0.irq[6]:=HOLD_LINE;
        update_video_thoop;
     end;
  end;
 eventos_gaelco_hw;
 video_sync;
end;
end;

function thoop_getword(direccion:dword):word;
begin
case direccion of
    0..$fffff:thoop_getword:=rom[direccion shr 1];
    $100000..$103fff:thoop_getword:=video_ram[(direccion and $3fff) shr 1];
    $440000..$440fff:thoop_getword:=sprite_ram[(direccion and $fff) shr 1];
    $200000..$2007ff:thoop_getword:=buffer_paleta[(direccion and $7ff) shr 1];
    $700000:thoop_getword:=marcade.dswb;
    $700002:thoop_getword:=marcade.dswa;
    $700004:thoop_getword:=marcade.in0;
    $700006:thoop_getword:=marcade.in1;
    $70000e:thoop_getword:=oki_6295_0.read;
    $ff0000..$ffffff:thoop_getword:=main_ram[(direccion and $ffff) shr 1];
end;
end;

procedure thoop_putword(direccion:dword;valor:word);
var
  dec:word;
  ptemp:pbyte;
begin
case direccion of
    0..$fffff:; //ROM
    $100000..$100fff:begin
                      dec:=gaelco_dec((direccion and $fff) shr 1,valor,gaelco_dec_val,$4228,m68000_0.r.pc.l);
                      if video_ram[(direccion and $fff) shr 1]<>dec then begin
                        video_ram[(direccion and $fff) shr 1]:=dec;
                        gfx[1].buffer[(direccion and $fff) shr 2]:=true;
                      end;
                   end;
    $101000..$101fff:begin
                      dec:=gaelco_dec((direccion and $1fff) shr 1,valor,gaelco_dec_val,$4228,m68000_0.r.pc.l);
                      if video_ram[(direccion and $1fff) shr 1]<>dec then begin
                        video_ram[(direccion and $1fff) shr 1]:=dec;
                        gfx[1].buffer[((direccion and $fff) shr 2)+$400]:=true;
                      end;
                   end;
    $102000..$103fff:begin
                        dec:=gaelco_dec((direccion and $1fff) shr 1,valor,gaelco_dec_val,$4228,m68000_0.r.pc.l);
                        video_ram[(direccion and $3fff) shr 1]:=dec;
                     end;
    $108000:if scroll_y0<>(valor and $1ff) then begin
              if abs((scroll_y0 and $1f0)-(valor and $1f0))>15 then fillchar(gfx[1].buffer[0],$400,1);
              scroll_y0:=valor and $1ff;
            end;
    $108002:if scroll_x0<>((valor+4) and $1ff) then begin
              if abs((scroll_x0 and $1f0)-((valor+4) and $1f0))>15 then fillchar(gfx[1].buffer[0],$400,1);
              scroll_x0:=(valor+4) and $1ff;
            end;
    $108004:if scroll_y1<>(valor and $1ff) then begin
              if abs((scroll_y1 and $1f0)-(valor and $1f0))>15 then fillchar(gfx[1].buffer[$400],$400,1);
              scroll_y1:=valor and $1ff;
            end;
    $108006:if scroll_x1<>(valor and $1ff) then begin
              if abs((scroll_x1 and $1f0)-(valor and $1f0))>15 then fillchar(gfx[1].buffer[$400],$400,1);
              scroll_x1:=valor and $1ff;
            end;
    $10800c:;
    $200000..$2007ff:if buffer_paleta[(direccion and $7ff) shr 1]<>valor then begin
                        cambiar_color(valor,(direccion and $7ff) shr 1);
                        buffer_paleta[(direccion and $7ff) shr 1]:=valor;
                     end;
    $440000..$440fff:sprite_ram[(direccion and $fff) shr 1]:=valor;
    $70000c:begin
             ptemp:=oki_6295_0.get_rom_addr;
             inc(ptemp,$30000);
             copymemory(ptemp,@oki_rom[(valor and $f),0],$10000);
          end;
    $70000e:oki_6295_0.write(valor);
    $ff0000..$ffffff:main_ram[(direccion and $ffff) shr 1]:=valor;
  end;
end;

//Biomechanical Toy
procedure biomtoy_putword(direccion:dword;valor:word);
var
  ptemp:pbyte;
begin
case direccion of
    0..$fffff:; //ROM
    $100000..$100fff:if video_ram[(direccion and $fff) shr 1]<>valor then begin
                      video_ram[(direccion and $fff) shr 1]:=valor;
                      gfx[1].buffer[(direccion and $fff) shr 2]:=true;
                   end;
    $101000..$101fff:if video_ram[(direccion and $1fff) shr 1]<>valor then begin
                      video_ram[(direccion and $1fff) shr 1]:=valor;
                      gfx[1].buffer[((direccion and $fff) shr 2)+$400]:=true;
                   end;
    $102000..$103fff:video_ram[(direccion and $3fff) shr 1]:=valor;
    $108000:if scroll_y0<>(valor and $1ff) then begin
              if abs((scroll_y0 and $1f0)-(valor and $1f0))>15 then fillchar(gfx[1].buffer[0],$400,1);
              scroll_y0:=valor and $1ff;
            end;
    $108002:if scroll_x0<>((valor+4) and $1ff) then begin
              if abs((scroll_x0 and $1f0)-((valor+4) and $1f0))>15 then fillchar(gfx[1].buffer[0],$400,1);
              scroll_x0:=(valor+4) and $1ff;
            end;
    $108004:if scroll_y1<>(valor and $1ff) then begin
              if abs((scroll_y1 and $1f0)-(valor and $1f0))>15 then fillchar(gfx[1].buffer[$400],$400,1);
              scroll_y1:=valor and $1ff;
            end;
    $108006:if scroll_x1<>(valor and $1ff) then begin
              if abs((scroll_x1 and $1f0)-(valor and $1f0))>15 then fillchar(gfx[1].buffer[$400],$400,1);
              scroll_x1:=valor and $1ff;
            end;
    $10800c:;
    $200000..$2007ff:if buffer_paleta[(direccion and $7ff) shr 1]<>valor then begin
                        cambiar_color(valor,(direccion and $7ff) shr 1);
                        buffer_paleta[(direccion and $7ff) shr 1]:=valor;
                     end;
    $440000..$440fff:sprite_ram[(direccion and $fff) shr 1]:=valor;
    $70000c:begin
             ptemp:=oki_6295_0.get_rom_addr;
             inc(ptemp,$30000);
             copymemory(ptemp,@oki_rom[(valor and $f),0],$10000);
          end;
    $70000e:oki_6295_0.write(valor); //OKI
    $ff0000..$ffffff:main_ram[(direccion and $ffff) shr 1]:=valor;
  end;
end;

procedure thoop_sound_update;
begin
  oki_6295_0.update;
end;

//Main
procedure reset_gaelco_hw;
begin
 m68000_0.reset;
 if main_vars.tipo_maquina=78 then begin
    m6809_0.reset;
    ym3812_0.reset;
 end;
 oki_6295_0.reset;
 reset_audio;
 marcade.in0:=$ffff;
 marcade.in1:=$ffff;
 scroll_x0:=1;
 scroll_y0:=1;
 scroll_x1:=1;
 scroll_y1:=1;
 sound_latch:=0;
end;

function iniciar_gaelco_hw:boolean;
var
  ptemp,ptemp2,ptemp3,memoria_temp:pbyte;
  f,pants:byte;
const
  pt_x:array[0..15] of dword=(0,1,2,3,4,5,6,7, 16*8+0,16*8+1,16*8+2,16*8+3,16*8+4,16*8+5,16*8+6,16*8+7);
  pt_y:array[0..15] of dword=(0*8,1*8,2*8,3*8,4*8,5*8,6*8,7*8, 8*8,9*8,10*8,11*8,12*8,13*8,14*8,15*8);
procedure convert_sprites;
begin
  init_gfx(0,8,8,$20000);
  gfx[0].trans[0]:=true;
  gfx_set_desc_data(4,0,8*8,0*$100000*8,1*$100000*8,2*$100000*8,3*$100000*8);
  convert_gfx(0,0,memoria_temp,@pt_x,@pt_y,false,false);
end;
procedure convert_tiles;
var
  f:byte;
begin
  init_gfx(1,16,16,$8000);
  gfx[1].trans[0]:=true;
  for f:=1 to 3 do gfx[1].trans_alt[f,0]:=true;
  for f:=8 to 15 do gfx[1].trans_alt[1,f]:=true;
  for f:=4 to 15 do gfx[1].trans_alt[2,f]:=true;
  for f:=2 to 15 do gfx[1].trans_alt[3,f]:=true;
  gfx_set_desc_data(4,0,32*8,0*$100000*8,1*$100000*8,2*$100000*8,3*$100000*8);
  convert_gfx(1,0,memoria_temp,@pt_x,@pt_y,false,false);
end;
begin
case main_vars.tipo_maquina of
  78:llamadas_maquina.bucle_general:=bigk_principal;
  101,173,174:begin
        llamadas_maquina.bucle_general:=thoop_principal;
        llamadas_maquina.fps_max:=57.42;
  end;
end;
llamadas_maquina.reset:=reset_gaelco_hw;
iniciar_gaelco_hw:=false;
iniciar_audio(false);
if main_vars.tipo_maquina=78 then pants:=15
  else pants:=8;
for f:=1 to pants do begin
  screen_init(f,336,272,true);
  screen_mod_scroll(f,336,336,511,272,272,511);
end;
//Final
screen_init(17,512,512,false,true);
iniciar_video(320,240);
marcade.dswa:=$00ff;
//Main CPU
m68000_0:=cpu_m68000.create(12000000,$200);
getmem(memoria_temp,$400000);
case main_vars.tipo_maquina of
  78:begin  //Big Karnak
      //Main CPU
      if not(roms_load16w(@rom,bigkarnak_rom)) then exit;
      m68000_0.change_ram16_calls(bigk_getword,bigk_putword);
      //Sound CPU
      if not(roms_load(@mem_snd,bigkarnak_sound)) then exit;
      m6809_0:=cpu_m6809.Create(2000000,$200,TCPU_M6809);
      m6809_0.change_ram_calls(bigk_snd_getbyte,bigk_snd_putbyte);
      m6809_0.init_sound(bigk_sound_update);
      //Sound Chips
      ym3812_0:=ym3812_chip.create(YM3812_FM,4000000);
      oki_6295_0:=snd_okim6295.Create(1056000,OKIM6295_PIN7_HIGH,1);
      //Cargar ADPCM ROMS
      if not(roms_load(oki_6295_0.get_rom_addr,bigkarnak_adpcm)) then exit;
      //Sprites
      if not(roms_load(memoria_temp,bigkarnak_gfx)) then exit;
      convert_sprites;
      //Tiles
      convert_tiles;
      marcade.dswb:=$00ce;
      marcade.dswc:=$00ff;
      marcade.dswa_val:=@gaelco_dip;
      marcade.dswb_val:=@bigkarnak_dsw_2;
      marcade.dswc_val:=@bigkarnak_dsw_3;
     end;
  101:begin  //Thunder Hoop
        //Main CPU
        if not(roms_load16w(@rom,thoop_rom)) then exit;
        m68000_0.change_ram16_calls(thoop_getword,thoop_putword);
        m68000_0.init_sound(thoop_sound_update);
        //Sound Chips
        oki_6295_0:=snd_okim6295.Create(1056000,OKIM6295_PIN7_HIGH,2);
        //Cargar ADPCM ROMS
        if not(roms_load(memoria_temp,thoop_adpcm)) then exit;
        copymemory(oki_6295_0.get_rom_addr,memoria_temp,$40000);
        ptemp2:=memoria_temp;
        for f:=0 to $f do begin
           copymemory(@oki_rom[f,0],ptemp2,$10000);
           inc(ptemp2,$10000);
        end;
        //Sprites
        getmem(ptemp,$400000);
        if not(roms_load(ptemp,thoop_gfx)) then exit;
        //Ordenar los GFX
        ptemp3:=ptemp;
        for f:=3 downto 0 do begin
          ptemp2:=memoria_temp;inc(ptemp2,$100000*f);copymemory(ptemp2,ptemp3,$40000);inc(ptemp3,$40000);
          ptemp2:=memoria_temp;inc(ptemp2,($100000*f)+$80000);copymemory(ptemp2,ptemp3,$40000);inc(ptemp3,$40000);
          ptemp2:=memoria_temp;inc(ptemp2,($100000*f)+$40000);copymemory(ptemp2,ptemp3,$40000);inc(ptemp3,$40000);
          ptemp2:=memoria_temp;inc(ptemp2,($100000*f)+$c0000);copymemory(ptemp2,ptemp3,$40000);inc(ptemp3,$40000);
        end;
        freemem(ptemp);
        convert_sprites;
        //Tiles
        convert_tiles;
        gaelco_dec_val:=$e;
        marcade.dswb:=$00cf;
        marcade.dswa_val:=@thoop_dsw_1;
        marcade.dswb_val:=@thoop_dsw_2;
      end;
  173:begin  //Squash
        //Main CPU
        if not(roms_load16w(@rom,squash_rom)) then exit;
        m68000_0.change_ram16_calls(thoop_getword,thoop_putword);
        m68000_0.init_sound(thoop_sound_update);
        //Sound Chips
        oki_6295_0:=snd_okim6295.Create(1056000,OKIM6295_PIN7_HIGH,2);
        //Cargar ADPCM ROMS
        if not(roms_load(memoria_temp,squash_adpcm)) then exit;
        copymemory(oki_6295_0.get_rom_addr,memoria_temp,$40000);
        ptemp2:=memoria_temp;
        for f:=0 to $7 do begin
           copymemory(@oki_rom[f,0],ptemp2,$10000);
           inc(ptemp2,$10000);
        end;
        //Sprites
        getmem(ptemp,$400000);
        if not(roms_load(ptemp,squash_gfx)) then exit;
        //Ordenar los GFX
        ptemp3:=ptemp;
        for f:=3 downto 0 do begin
          ptemp2:=memoria_temp;inc(ptemp2,$100000*f);copymemory(ptemp2,ptemp3,$80000);
          ptemp2:=memoria_temp;inc(ptemp2,($100000*f)+$80000);copymemory(ptemp2,ptemp3,$80000);inc(ptemp3,$80000);
        end;
        freemem(ptemp);
        convert_sprites;
        //Tiles
        convert_tiles;
        gaelco_dec_val:=$f;
        marcade.dswb:=$00df;
        marcade.dswa_val:=@squash_dsw_1;
        marcade.dswb_val:=@squash_dsw_2;
      end;
  174:begin  //Biomechanical Toy
        //Main CPU
        if not(roms_load16w(@rom,biomtoy_rom)) then exit;
        m68000_0.change_ram16_calls(thoop_getword,biomtoy_putword);
        m68000_0.init_sound(thoop_sound_update);
        //Sound Chips
        oki_6295_0:=snd_okim6295.Create(1056000,OKIM6295_PIN7_HIGH,2);
        //Cargar ADPCM ROMS
        if not(roms_load(memoria_temp,biomtoy_adpcm)) then exit;
        copymemory(oki_6295_0.get_rom_addr,memoria_temp,$40000);
        ptemp2:=memoria_temp;
        for f:=0 to $f do begin
           copymemory(@oki_rom[f,0],ptemp2,$10000);
           inc(ptemp2,$10000);
        end;
        //Sprites
        getmem(ptemp,$400000);
        if not(roms_load(ptemp,biomtoy_gfx)) then exit;
        //Ordenar los GFX
        ptemp3:=ptemp; //orig
        for f:=0 to 3 do begin
          ptemp2:=memoria_temp;inc(ptemp2,$040000+(f*$100000));copymemory(ptemp2,ptemp3,$40000);inc(ptemp3,$40000);
          ptemp2:=memoria_temp;inc(ptemp2,$0c0000+(f*$100000));copymemory(ptemp2,ptemp3,$40000);inc(ptemp3,$40000);
          ptemp2:=memoria_temp;inc(ptemp2,$000000+(f*$100000));copymemory(ptemp2,ptemp3,$40000);inc(ptemp3,$40000);
          ptemp2:=memoria_temp;inc(ptemp2,$080000+(f*$100000));copymemory(ptemp2,ptemp3,$40000);inc(ptemp3,$40000);
        end;
        freemem(ptemp);
        convert_sprites;
        //Tiles
        convert_tiles;
        marcade.dswb:=$00fb;
        marcade.dswa_val:=@gaelco_dip;
        marcade.dswb_val:=@biomtoy_dsw_2;
      end;
end;
freemem(memoria_temp);
//final
reset_gaelco_hw;
iniciar_gaelco_hw:=true;
end;

end.
