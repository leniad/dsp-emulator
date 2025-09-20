unit ninjakid2_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,ym_2203,gfx_engine,rom_engine,
     pal_engine,mc8123,sound_engine,timer_engine,dac;

function iniciar_upl:boolean;

implementation

const
        //Ninja Kid II
        ninjakid2_rom:array[0..4] of tipo_roms=(
        (n:'1.3s';l:$8000;p:0;crc:$3cdbb906),(n:'2.3q';l:$8000;p:$8000;crc:$b5ce9a1a),
        (n:'3.3r';l:$8000;p:$10000;crc:$ad275654),(n:'4.3p';l:$8000;p:$18000;crc:$e7692a77),
        (n:'5.3m';l:$8000;p:$20000;crc:$5dac9426));
        ninjakid2_snd_rom:tipo_roms=(n:'6.3h';l:$10000;p:0;crc:$d3a18a79);
        ninjakid2_fgtiles:tipo_roms=(n:'12.5n';l:$8000;p:0;crc:$db5657a9);
        ninjakid2_sprites:array[0..1] of tipo_roms=(
        (n:'8.6l';l:$10000;p:0;crc:$1b79c50a),(n:'7.6n';l:$10000;p:$10000;crc:$0be5cd13));
        ninjakid2_bgtiles:array[0..1] of tipo_roms=(
        (n:'11.2n';l:$10000;p:0;crc:$41a714b3),(n:'10.2r';l:$10000;p:$10000;crc:$c913c4ab));
        ninjakid2_snd_key:tipo_roms=(n:'ninjakd2.key';l:$2000;p:0;crc:$ec25318f);
        ninjakid2_pcm_rom:tipo_roms=(n:'9.6c';l:$10000;p:0;crc:$c1d2d170);
        //DIP
        ninjakid2_dip_a:array [0..7] of def_dip=(
        (mask:$1;name:'Flip Screen';number:2;dip:((dip_val:$1;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$6;name:'Bonus Life';number:4;dip:((dip_val:$4;dip_name:'20K 50K+'),(dip_val:$6;dip_name:'30K 50K+'),(dip_val:$2;dip_name:'50K 50K+'),(dip_val:$0;dip_name:'None'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Allow Continue';number:2;dip:((dip_val:$0;dip_name:'No'),(dip_val:$8;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Demo Sounds';number:2;dip:((dip_val:$10;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Difficulty';number:2;dip:((dip_val:$20;dip_name:'Normal'),(dip_val:$0;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Lives';number:2;dip:((dip_val:$40;dip_name:'3'),(dip_val:$0;dip_name:'4'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Language';number:2;dip:((dip_val:$0;dip_name:'English'),(dip_val:$80;dip_name:'Japanese'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        ninjakid2_dip_b:array [0..4] of def_dip=(
        (mask:$2;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$2;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Credit Service';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$4;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$18;name:'Coin A';number:4;dip:((dip_val:$0;dip_name:'2C 1C/6C 4C'),(dip_val:$18;dip_name:'1C 1C/3C 4C'),(dip_val:$10;dip_name:'1C 2C/2C 6C'),(dip_val:$8;dip_name:'1C 3C/3C 12C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$e0;name:'Coin B';number:8;dip:((dip_val:$80;dip_name:'1C 4C'),(dip_val:$0;dip_name:'5C 1C/15C 4C'),(dip_val:$20;dip_name:'4C 1C/12C 4C'),(dip_val:$40;dip_name:'3C 1C/9C 4C'),(dip_val:$60;dip_name:'2C 1C/6C 4C'),(dip_val:$e0;dip_name:'1C 1C/3C 4C'),(dip_val:$c0;dip_name:'1C 2C/2C 6C'),(dip_val:$a0;dip_name:'1C 3C/3C 12C'),(),(),(),(),(),(),(),())),());
        //Ark Area
        aarea_rom:array[0..4] of tipo_roms=(
        (n:'arkarea.008';l:$8000;p:0;crc:$1ce1b5b9),(n:'arkarea.009';l:$8000;p:$8000;crc:$db1c81d1),
        (n:'arkarea.010';l:$8000;p:$10000;crc:$5a460dae),(n:'arkarea.011';l:$8000;p:$18000;crc:$63f022c9),
        (n:'arkarea.012';l:$8000;p:$20000;crc:$3c4c65d5));
        aarea_snd_rom:tipo_roms=(n:'arkarea.013';l:$8000;p:0;crc:$2d409d58);
        aarea_fgtiles:tipo_roms=(n:'arkarea.004';l:$8000;p:0;crc:$69e36af2);
        aarea_sprites:array[0..2] of tipo_roms=(
        (n:'arkarea.007';l:$10000;p:0;crc:$d5684a27),(n:'arkarea.006';l:$10000;p:$10000;crc:$2c0567d6),
        (n:'arkarea.005';l:$10000;p:$20000;crc:$9886004d));
        aarea_bgtiles:array[0..2] of tipo_roms=(
        (n:'arkarea.003';l:$10000;p:0;crc:$6f45a308),(n:'arkarea.002';l:$10000;p:$10000;crc:$051d3482),
        (n:'arkarea.001';l:$10000;p:$20000;crc:$09d11ab7));
        //DIP
        aarea_dip_a:array [0..6] of def_dip=(
        (mask:$3;name:'Coinage';number:4;dip:((dip_val:$0;dip_name:'3C 1C'),(dip_val:$1;dip_name:'2C 1C'),(dip_val:$3;dip_name:'1C 1C'),(dip_val:$2;dip_name:'1C 2C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Flip Screen';number:2;dip:((dip_val:$4;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Demo Sounds';number:2;dip:((dip_val:$10;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Difficulty';number:2;dip:((dip_val:$20;dip_name:'Normal'),(dip_val:$0;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Bonus Life';number:2;dip:((dip_val:$40;dip_name:'50K 50K+'),(dip_val:$0;dip_name:'100K 100K+'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Lives';number:2;dip:((dip_val:$80;dip_name:'3'),(dip_val:$0;dip_name:'4'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        //Mutant Night
        mnight_rom:array[0..4] of tipo_roms=(
        (n:'1.j19';l:$8000;p:0;crc:$56678d14),(n:'2.j17';l:$8000;p:$8000;crc:$2a73f88e),
        (n:'3.j16';l:$8000;p:$10000;crc:$c5e42bb4),(n:'4.j14';l:$8000;p:$18000;crc:$df6a4f7a),
        (n:'5.j12';l:$8000;p:$20000;crc:$9c391d1b));
        mnight_snd_rom:tipo_roms=(n:'6.j7';l:$10000;p:0;crc:$a0782a31);
        mnight_fgtiles:tipo_roms=(n:'13.b10';l:$8000;p:0;crc:$37b8221f);
        mnight_sprites:array[0..2] of tipo_roms=(
        (n:'9.e11';l:$10000;p:0;crc:$4883059c),(n:'8.e12';l:$10000;p:$10000;crc:$02b91445),
        (n:'7.e14';l:$10000;p:$20000;crc:$9f08d160));
        mnight_bgtiles:array[0..2] of tipo_roms=(
        (n:'12.b20';l:$10000;p:0;crc:$4d37e0f4),(n:'11.b22';l:$10000;p:$10000;crc:$b22cbbd3),
        (n:'10.b23';l:$10000;p:$20000;crc:$65714070));
        //DIP
        mnight_dip_a:array [0..7] of def_dip=(
        (mask:$1;name:'Flip Screen';number:2;dip:((dip_val:$1;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2;name:'Bonus Life';number:2;dip:((dip_val:$2;dip_name:'30K 50K+'),(dip_val:$0;dip_name:'50K 80K+'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Difficulty';number:2;dip:((dip_val:$4;dip_name:'Normal'),(dip_val:$0;dip_name:'Difficult'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Infinite Lives';number:2;dip:((dip_val:$8;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$10;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Demo Sounds';number:2;dip:((dip_val:$20;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Lives';number:4;dip:((dip_val:$80;dip_name:'2'),(dip_val:$c0;dip_name:'3'),(dip_val:$40;dip_name:'4'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),());
        mnight_dip_b:array [0..1] of def_dip=(
        (mask:$e0;name:'Coinage';number:8;dip:((dip_val:$80;dip_name:'1C 4C'),(dip_val:$0;dip_name:'5C 1C'),(dip_val:$20;dip_name:'4C 1C'),(dip_val:$40;dip_name:'3C 1C'),(dip_val:$60;dip_name:'2C 1C'),(dip_val:$e0;dip_name:'1C 1C'),(dip_val:$c0;dip_name:'1C 2C'),(dip_val:$a0;dip_name:'1C 3C'),(),(),(),(),(),(),(),())),());
        //Atomic Robo-Kid
        robokid_rom:array[0..3] of tipo_roms=(
        (n:'robokid1.18j';l:$10000;p:0;crc:$378c21fc),(n:'robokid2.18k';l:$10000;p:$10000;crc:$ddef8c5a),
        (n:'robokid3.15k';l:$10000;p:$20000;crc:$05295ec3),(n:'robokid4.12k';l:$10000;p:$30000;crc:$3bc3977f));
        robokid_snd_rom:tipo_roms=(n:'robokid.k7';l:$10000;p:0;crc:$f490a2e9);
        robokid_fgtiles:tipo_roms=(n:'robokid.b9';l:$8000;p:0;crc:$fac59c3f);
        robokid_sprites:array[0..3] of tipo_roms=(
        (n:'robokid.15f';l:$10000;p:0;crc:$ba61f5ab),(n:'robokid.16f';l:$10000;p:$10000;crc:$d9b399ce),
        (n:'robokid.17f';l:$10000;p:$20000;crc:$afe432b9),(n:'robokid.18f';l:$10000;p:$30000;crc:$a0aa2a84));
        robokid_bgtiles0:array[0..6] of tipo_roms=(
        (n:'robokid.19c';l:$10000;p:0;crc:$02220421),(n:'robokid.20c';l:$10000;p:$10000;crc:$02d59bc2),
        (n:'robokid.17d';l:$10000;p:$20000;crc:$2fa29b99),(n:'robokid.18d';l:$10000;p:$30000;crc:$ae15ce02),
        (n:'robokid.19d';l:$10000;p:$40000;crc:$784b089e),(n:'robokid.20d';l:$10000;p:$50000;crc:$b0b395ed),
        (n:'robokid.19f';l:$10000;p:$60000;crc:$0f9071c6));
        robokid_bgtiles1:array[0..7] of tipo_roms=(
        (n:'robokid.12c';l:$10000;p:0;crc:$0ab45f94),(n:'robokid.14c';l:$10000;p:$10000;crc:$029bbd4a),
        (n:'robokid.15c';l:$10000;p:$20000;crc:$7de67ebb),(n:'robokid.16c';l:$10000;p:$30000;crc:$53c0e582),
        (n:'robokid.17c';l:$10000;p:$40000;crc:$0cae5a1e),(n:'robokid.18c';l:$10000;p:$50000;crc:$56ac7c8a),
        (n:'robokid.15d';l:$10000;p:$60000;crc:$cd632a4d),(n:'robokid.16d';l:$10000;p:$70000;crc:$18d92b2b));
        robokid_bgtiles2:array[0..5] of tipo_roms=(
        (n:'robokid.12a';l:$10000;p:0;crc:$e64d1c10),(n:'robokid.14a';l:$10000;p:$10000;crc:$8f9371e4),
        (n:'robokid.15a';l:$10000;p:$20000;crc:$469204e7),(n:'robokid.16a';l:$10000;p:$30000;crc:$4e340815),
        (n:'robokid.17a';l:$10000;p:$40000;crc:$f0863106),(n:'robokid.18a';l:$10000;p:$50000;crc:$fdff7441));
        robokid_dip_a:array [0..7] of def_dip=(
        (mask:$1;name:'Flip Screen';number:2;dip:((dip_val:$1;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2;name:'Bonus Life';number:2;dip:((dip_val:$2;dip_name:'50K 100K+'),(dip_val:$0;dip_name:'None'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Difficulty';number:2;dip:((dip_val:$4;dip_name:'Normal'),(dip_val:$0;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Free Play';number:2;dip:((dip_val:$8;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$10;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Demo Sounds';number:2;dip:((dip_val:$20;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Lives';number:4;dip:((dip_val:$80;dip_name:'2'),(dip_val:$c0;dip_name:'3'),(dip_val:$40;dip_name:'4'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),());

var
  rom_bank:array[0..$f,0..$3fff] of byte;
  mem_snd_opc:array[0..$7fff] of byte;
  fg_data:array[0..$7ff] of byte;
  xshift,yshift,rom_nbank,sound_latch:byte;
  fg_color,sprite_color:word;
  sprite_overdraw:boolean;
  scroll_x,scroll_y:array[0..2] of word;
  bg_enable:array[0..2] of boolean;
  bg_bank:array[0..2] of byte;
  pant_sprites_tmp:array[0..$3ffff] of byte;
  bg_ram:array[0..2,0..$1fff] of byte;
  update_background:procedure;
  update_video_upl:procedure;
  sprite_comp:function(pos:word):boolean;
  //Ninjakid2 PCM
  ninjakid2_pcm:array[0..$ffff] of byte;
  ninjakid2_pcm_pos:dword;
  ninjakid2_timer:byte;

procedure bg_ninjakid2;
var
  f,color,nchar:word;
  x,y,atrib:byte;
begin
for f:=0 to $3ff do begin
  atrib:=memoria[$d801+(f*2)];
  color:=atrib and $f;
  if (gfx[1].buffer[f] or buffer_color[color]) then begin
      x:=f mod 32;
      y:=f div 32;
      nchar:=(memoria[$d800+(f*2)]+((atrib and $c0) shl 2)) and $3ff;
      put_gfx_flip(x*16,y*16,nchar,color shl 4,2,1,(atrib and $10)<>0,(atrib and $20)<>0);
      gfx[1].buffer[f]:=false;
    end;
end;
scroll_x_y(2,3,scroll_x[0],scroll_y[0]);
end;

procedure bg_upl;
var
  f,color,nchar:word;
  x,y,atrib:byte;
begin
for f:=0 to $3ff do begin
  atrib:=bg_ram[0,$1+(f*2)];
  color:=atrib and $f;
  if (gfx[1].buffer[f] or buffer_color[color]) then begin
      x:=f mod 32;
      y:=f div 32;
      nchar:=(bg_ram[0,f*2]+((atrib and $10) shl 6)+((atrib and $c0) shl 2)) mod $600;
      put_gfx_flip(x*16,y*16,nchar,color shl 4,2,1,false,(atrib and $20)<>0);
      gfx[1].buffer[f]:=false;
    end;
end;
scroll_x_y(2,3,scroll_x[0],scroll_y[0]);
end;

procedure put_gfx_sprite_upl(nchar:dword;color:word;flipx,flipy:boolean;pos_x,pos_y:word);inline;
var
  x,y:byte;
  pos_temp:dword;
  temp:pword;
  pos,post:pbyte;
begin
if flipx then begin
  pos:=gfx[2].datos;
  inc(pos,nchar*16*16+15);
  for y:=0 to 15 do begin
    post:=pos;
    inc(post,(y*16));
    temp:=punbuf;
    if flipy then pos_temp:=(pos_y+(15-y))*512+pos_x+15
      else pos_temp:=(pos_y+y)*512+pos_x+15;
    for x:=15 downto 0 do begin
      if post^<>15 then temp^:=paleta[gfx[2].colores[post^+color+sprite_color]]
        else temp^:=paleta[MAX_COLORES];
      pant_sprites_tmp[pos_temp]:=color and $ff;
      pos_temp:=pos_temp-1;
      dec(post);
      inc(temp);
    end;
    if flipy then putpixel(0,(15-y),16,punbuf,PANT_SPRITES)
      else putpixel(0,y,16,punbuf,PANT_SPRITES);
  end;
end else begin
  pos:=gfx[2].datos;
  inc(pos,nchar*16*16);
  for y:=0 to 15 do begin
    temp:=punbuf;
    if flipy then pos_temp:=(pos_y+(15-y))*512+pos_x
        else pos_temp:=(pos_y+y)*512+pos_x;
    for x:=0 to 15 do begin
      if pos^<>15 then temp^:=paleta[gfx[2].colores[pos^+color+sprite_color]]
        else temp^:=paleta[MAX_COLORES];
      pant_sprites_tmp[pos_temp]:=color and $ff;
      pos_temp:=pos_temp+1;
      inc(temp);
      inc(pos);
    end;
    if flipy then putpixel(0,(15-y),16,punbuf,PANT_SPRITES)
      else putpixel(0,y,16,punbuf,PANT_SPRITES);
  end;
end;
end;

function sprite_comp_upl(pos:word):boolean;
begin
sprite_comp_upl:=((pant_sprites_tmp[pos] and $f0)=$f0);
end;

function sprite_comp_robokid(pos:word):boolean;
begin
sprite_comp_robokid:=((pant_sprites_tmp[pos] and $f0)<$e0);
end;

procedure draw_sprites;
var
  f,color,nchar,sx,tile:word;
  x,y,sy,atrib,num_sprites,big:byte;
  flipx,flipy:boolean;
  tf:dword;
  pos_pixels:pword;
begin
if not(sprite_overdraw) then begin
  fill_full_screen(4,MAX_COLORES);
  fillchar(pant_sprites_tmp[0],512*256,0);
end else begin
  for sy:=0 to 255 do begin
      pos_pixels:=pantalla[4].pixels;
      inc(pos_pixels,(sy*pantalla[4].pitch) shr 1);
      tf:=sy*512;
			for sx:=0 to 255 do begin
				if sprite_comp(tf) then begin
          pant_sprites_tmp[tf]:=0;
          pos_pixels^:=paleta[MAX_COLORES];
        end;
        tf:=tf+1;
        inc(pos_pixels);
			end;
  end;
end;
num_sprites:=0;
f:=0;
repeat
  atrib:=buffer_sprites[$d+f];
  if (atrib and $2)<>0 then begin
    sx:=buffer_sprites[$c+f]-((atrib and $01) shl 8);
		sy:=buffer_sprites[$b+f];
    // Ninja Kid II doesn't use the topmost bit (it has smaller ROMs) so it might not be connected on the board
		nchar:=buffer_sprites[$e+f]+((atrib and $c0) shl 2)+((atrib and $08) shl 7);
    flipx:=(atrib and $10)<>0;
    flipy:=(atrib and $20)<>0;
		color:=(buffer_sprites[$f+f] and $f) shl 4;
    // Ninja Kid II doesn't use the 'big' feature so it might not be available on the board
		big:=(atrib and $04) shr 2;
    if big<>0 then begin
				nchar:=nchar and $fffc;
        nchar:=nchar xor (byte(flipx) shl xshift);
        nchar:=nchar xor (byte(flipy) shl yshift);
    end;
    for y:=0 to big do begin
					for x:=0 to big do begin
						tile:=nchar xor (x shl xshift) xor (y shl yshift);
            put_gfx_sprite_upl(tile,color,flipx,flipy,sx+16*x,sy+16*y);
            actualiza_trozo(0,0,16,16,PANT_SPRITES,sx+16*x,sy+16*y,16,16,4);
            num_sprites:=num_sprites+1;
					end;
    end;
  end else num_sprites:=num_sprites+1;
  f:=f+$10;
until num_sprites=96;
end;

procedure update_foreground;inline;
var
  f,nchar:word;
  x,y,atrib,color:byte;
begin
for f:=$0 to $3ff do begin
  atrib:=fg_data[1+(f*2)];
  color:=atrib and $f;
  if (gfx[0].buffer[f] or buffer_color[color+$10]) then begin
    x:=f mod 32;
    y:=f div 32;
    nchar:=(fg_data[f*2]+((atrib and $c0) shl 2)) and $3ff;
    put_gfx_trans_flip(x*8,y*8,nchar,(color shl 4)+fg_color,1,0,(atrib and $10)<>0,(atrib and $20)<>0);
    gfx[0].buffer[f]:=false;
  end;
end;
end;

procedure update_video_ninjakid2;
begin
//background
if bg_enable[0] then update_background
  else fill_full_screen(3,$400);
//Sprites
draw_sprites;
actualiza_trozo(0,0,256,256,4,0,0,256,256,3);
//Chars
update_foreground;
actualiza_trozo(0,0,256,256,1,0,0,256,256,3);
//Final
actualiza_trozo_final(0,32,256,192,3);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure update_video_robokid;
procedure robokid_bg(nbg,npant,ngfx:byte;trans:boolean);
var
  f,pos,nchar:word;
  x,y,atrib,color:byte;
begin
for f:=0 to $3ff do begin
    x:=f mod 32;
    y:=f div 32;
    pos:=(x and $0f) or ((y and $1f) shl 4) or ((x and $10) shl 5);
    atrib:=bg_ram[nbg,(pos shl 1) or 1];
    color:=atrib and $f;
    if (gfx[ngfx].buffer[pos] or buffer_color[color]) then begin
      nchar:=(((atrib and $10) shl 7) or ((atrib and $20) shl 5) or ((atrib and $c0) shl 2) or bg_ram[nbg,pos shl 1]) and $fff;
      if trans then put_gfx_trans(x*16,y*16,nchar,color shl 4,npant,ngfx)
        else put_gfx(x*16,y*16,nchar,color shl 4,npant,ngfx);
      gfx[ngfx].buffer[pos]:=false;
    end;
  end;
scroll_x_y(npant,3,scroll_x[nbg],scroll_y[nbg]);
end;
begin
//background 0-1
if bg_enable[0] then robokid_bg(0,2,1,false)
  else fill_full_screen(3,$400);
if bg_enable[1] then robokid_bg(1,5,3,true);
//Sprites
draw_sprites;
actualiza_trozo(0,0,256,256,4,0,0,256,256,3);
//background 2
if bg_enable[2] then robokid_bg(2,6,4,true);
//Chars
update_foreground;
actualiza_trozo(0,0,256,256,1,0,0,256,256,3);
//Final
actualiza_trozo_final(0,32,256,192,3);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure eventos_upl;
begin
if event.arcade then begin
  //P1
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $F7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  //P2
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $F7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  //COIN
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
end;
end;

procedure upl_principal;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=z80_0.tframes;
frame_s:=z80_1.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
    //main
    z80_0.run(frame_m);
    frame_m:=frame_m+z80_0.tframes-z80_0.contador;
    //snd
    z80_1.run(frame_s);
    frame_s:=frame_s+z80_1.tframes-z80_1.contador;
    if f=223 then begin
      z80_0.change_irq(HOLD_LINE);
      update_video_upl;
    end;
  end;
  eventos_upl;
  video_sync;
end;
end;

procedure cambiar_color(pos:word);inline;
var
  tmp_color:byte;
  color:tcolor;
begin
  tmp_color:=buffer_paleta[pos];
  color.r:=pal4bit(tmp_color shr 4);
  color.g:=pal4bit(tmp_color);
  tmp_color:=buffer_paleta[pos+1];
  color.b:=pal4bit(tmp_color shr 4);
  pos:=pos shr 1;
  set_pal_color(color,pos);
  case pos of
    $0..$ff:buffer_color[pos shr 4]:=true;
    $200..$2ff:buffer_color[((pos shr 4) and $f)+$10]:=true;
  end;
end;

//Generic
function upl_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff,$c000..$d9ff:upl_getbyte:=memoria[direccion];
  $8000..$bfff:upl_getbyte:=rom_bank[rom_nbank,direccion and $3fff];
  $da00..$dfff:upl_getbyte:=buffer_sprites[direccion-$da00];
  $e000..$e7ff:upl_getbyte:=bg_ram[0,direccion and $7ff];
  $e800..$efff:upl_getbyte:=fg_data[direccion and $7ff];
  $f000..$f5ff:upl_getbyte:=buffer_paleta[direccion and $7ff];
  $f800:upl_getbyte:=marcade.in0;
  $f801:upl_getbyte:=marcade.in1;
  $f802:upl_getbyte:=marcade.in2;
  $f803:upl_getbyte:=marcade.dswa;
  $f804:upl_getbyte:=marcade.dswb;
end;
end;

procedure upl_putbyte(direccion:word;valor:byte);
begin
case direccion of
   0..$bfff:;
   $c000..$d9ff:memoria[direccion]:=valor;
   $da00..$dfff:buffer_sprites[direccion-$da00]:=valor;
   $e000..$e7ff:if bg_ram[0,direccion and $7ff]<>valor then begin
                  gfx[1].buffer[(direccion and $7ff) shr 1]:=true;
                  bg_ram[0,direccion and $7ff]:=valor;
                end;
   $e800..$efff:if fg_data[direccion and $7ff]<>valor then begin
                  fg_data[direccion and $7ff]:=valor;
                  gfx[0].buffer[(direccion and $7ff) shr 1]:=true;
                end;
   $f000..$f5ff:if buffer_paleta[direccion and $7ff]<>valor then begin
                  buffer_paleta[direccion and $7ff]:=valor;
                  cambiar_color(direccion and $7fe);
                end;
   $fa00:sound_latch:=valor;
   $fa01:begin
            if (valor and $10)<>0 then z80_1.reset;
            main_screen.flip_main_screen:=(valor and $80)<>0;
         end;
   $fa02:rom_nbank:=valor and $7;
   $fa03:sprite_overdraw:=(valor and $1)<>0;
   $fa08:scroll_x[0]:=(scroll_x[0] and $ff00) or valor;
   $fa09:scroll_x[0]:=(scroll_x[0] and $00ff) or ((valor and $1) shl 8);
   $fa0a:scroll_y[0]:=(scroll_y[0] and $ff00) or valor;
   $fa0b:scroll_y[0]:=(scroll_y[0] and $00ff) or ((valor and $1) shl 8);
   $fa0c:bg_enable[0]:=(valor and $1)<>0;
end;
end;

//Ninja Kid II
function ninjakid2_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff,$d800..$f9ff:ninjakid2_getbyte:=memoria[direccion];
  $8000..$bfff:ninjakid2_getbyte:=rom_bank[rom_nbank,direccion and $3fff];
  $c000:ninjakid2_getbyte:=marcade.in0;
  $c001:ninjakid2_getbyte:=marcade.in1;
  $c002:ninjakid2_getbyte:=marcade.in2;
  $c003:ninjakid2_getbyte:=marcade.dswa;
  $c004:ninjakid2_getbyte:=marcade.dswb;
  $c800:ninjakid2_getbyte:=buffer_paleta[direccion and $7ff];
  $d000..$d7ff:ninjakid2_getbyte:=fg_data[direccion and $7ff];
  $fa00..$ffff:ninjakid2_getbyte:=buffer_sprites[direccion-$fa00];
end;
end;

procedure ninjakid2_putbyte(direccion:word;valor:byte);
begin
case direccion of
   0..$bfff:;
   $c200:sound_latch:=valor;
   $c201:begin
            if (valor and $10)<>0 then z80_1.reset;
            main_screen.flip_main_screen:=(valor and $80)<>0;
         end;
   $c202:rom_nbank:=valor and $7;
   $c203:sprite_overdraw:=(valor and $1)<>0;
   $c208:scroll_x[0]:=(scroll_x[0] and $ff00) or valor;
   $c209:scroll_x[0]:=(scroll_x[0] and $00ff) or ((valor and $1) shl 8);
   $c20a:scroll_y[0]:=(scroll_y[0] and $ff00) or valor;
   $c20b:scroll_y[0]:=(scroll_y[0] and $00ff) or ((valor and $1) shl 8);
   $c20c:bg_enable[0]:=(valor and $1)<>0;
   $c800..$cdff:if buffer_paleta[direccion and $7ff]<>valor then begin
                    buffer_paleta[direccion and $7ff]:=valor;
                    cambiar_color(direccion and $7fe);
                end;
   $d000..$d7ff:if fg_data[direccion and $7ff]<>valor then begin
                    fg_data[direccion and $7ff]:=valor;
                    gfx[0].buffer[(direccion and $7ff) shr 1]:=true;
                end;
   $d800..$dfff:if memoria[direccion]<>valor then begin
                    gfx[1].buffer[(direccion and $7ff) shr 1]:=true;
                    memoria[direccion]:=valor;
                end;
   $e000..$f9ff:memoria[direccion]:=valor;
   $fa00..$ffff:buffer_sprites[direccion-$fa00]:=valor;
end;
end;

function ninjakid2_snd_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$7fff:if z80_1.opcode then ninjakid2_snd_getbyte:=mem_snd_opc[direccion]
              else ninjakid2_snd_getbyte:=mem_snd[direccion];
  $8000..$c7ff:ninjakid2_snd_getbyte:=mem_snd[direccion];
  $e000:ninjakid2_snd_getbyte:=sound_latch;
end;
end;

procedure ninjakid2_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$bfff:;
  $c000..$c7ff:mem_snd[direccion]:=valor;
  $f000:begin //PCM
          ninjakid2_pcm_pos:=valor shl 8;
          if ninjakid2_pcm[ninjakid2_pcm_pos]<>0 then begin
            dac_0.data8_w(ninjakid2_pcm[ninjakid2_pcm_pos]);
            timers.enabled(ninjakid2_timer,true);
          end else begin
            timers.enabled(ninjakid2_timer,false);
            dac_0.data8_w(0);
          end;
        end;
end;
end;

procedure ninjakid2_snd_timer;
begin
  ninjakid2_pcm_pos:=ninjakid2_pcm_pos+1;
  if ((ninjakid2_pcm_pos=$10000) or (ninjakid2_pcm[ninjakid2_pcm_pos]=0)) then begin
    timers.enabled(ninjakid2_timer,false);
    dac_0.data8_w(0);
  end else dac_0.data8_w(ninjakid2_pcm[ninjakid2_pcm_pos]);
end;

procedure ninjakid2_sound_update;
begin
  ym2203_0.Update;
  ym2203_1.Update;
  dac_0.update;
end;

//Atomic Robo-kid
function robokid_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff,$e000..$f9ff:robokid_getbyte:=memoria[direccion];
  $8000..$bfff:robokid_getbyte:=rom_bank[rom_nbank,direccion and $3fff];
  $c000..$c7ff:robokid_getbyte:=buffer_paleta[direccion and $7ff];
  $c800..$cfff:robokid_getbyte:=fg_data[direccion and $7ff];
  $d000..$d3ff:robokid_getbyte:=bg_ram[2,(direccion and $3ff)+(bg_bank[2]*$400)];
  $d400..$d7ff:robokid_getbyte:=bg_ram[1,(direccion and $3ff)+(bg_bank[1]*$400)];
  $d800..$dbff:robokid_getbyte:=bg_ram[0,(direccion and $3ff)+(bg_bank[0]*$400)];
  $dc00:robokid_getbyte:=marcade.in0;
  $dc01:robokid_getbyte:=marcade.in1;
  $dc02:robokid_getbyte:=marcade.in2;
  $dc03:robokid_getbyte:=marcade.dswa;
  $dc04:robokid_getbyte:=marcade.dswb;
  $fa00..$ffff:robokid_getbyte:=buffer_sprites[direccion-$fa00];
end;
end;

procedure cambiar_color_robokid(pos:word);inline;
var
  tmp_color:byte;
  color:tcolor;
begin
  tmp_color:=buffer_paleta[pos];
  color.r:=pal4bit(tmp_color shr 4);
  color.g:=pal4bit(tmp_color);
  tmp_color:=buffer_paleta[pos+1];
  color.b:=pal4bit(tmp_color shr 4);
  pos:=pos shr 1;
  set_pal_color(color,pos);
  case pos of
    $0..$ff:buffer_color[pos shr 4]:=true;
    $300..$3ff:buffer_color[((pos shr 4) and $f)+$10]:=true;
  end;
end;

procedure robokid_putbyte(direccion:word;valor:byte);
begin
case direccion of
   0..$bfff:;
   $c000..$c7ff:if buffer_paleta[direccion and $7ff]<>valor then begin
                    buffer_paleta[direccion and $7ff]:=valor;
                    cambiar_color_robokid(direccion and $7fe);
                end;
   $c800..$cfff:if fg_data[direccion and $7ff]<>valor then begin
                    fg_data[direccion and $7ff]:=valor;
                    gfx[0].buffer[(direccion and $7ff) shr 1]:=true;
                end;
   $d000..$d3ff:if bg_ram[2,(direccion and $3ff)+(bg_bank[2]*$400)]<>valor then begin
                    bg_ram[2,(direccion and $3ff)+(bg_bank[2]*$400)]:=valor;
                    gfx[4].buffer[((direccion and $3ff)+(bg_bank[2]*$400)) shr 1]:=true;
                end;
   $d400..$d7ff:if bg_ram[1,(direccion and $3ff)+(bg_bank[1]*$400)]<>valor then begin
                    bg_ram[1,(direccion and $3ff)+(bg_bank[1]*$400)]:=valor;
                    gfx[3].buffer[((direccion and $3ff)+(bg_bank[1]*$400)) shr 1]:=true;
                end;
   $d800..$dbff:if bg_ram[0,(direccion and $3ff)+(bg_bank[0]*$400)]<>valor then begin
                    bg_ram[0,(direccion and $3ff)+(bg_bank[0]*$400)]:=valor;
                    gfx[1].buffer[((direccion and $3ff)+(bg_bank[0]*$400)) shr 1]:=true;
                end;
   $dc00:sound_latch:=valor;
   $dc01:begin
            if (valor and $10)<>0 then z80_1.reset;
            main_screen.flip_main_screen:=(valor and $80)<>0;
         end;
   $dc02:rom_nbank:=valor and $f;
   $dc03:sprite_overdraw:=(valor and $1)<>0;
   $dd00:scroll_x[0]:=(scroll_x[0] and $ff00) or valor;
   $dd01:scroll_x[0]:=(scroll_x[0] and $00ff) or ((valor and $1) shl 8);
   $dd02:scroll_y[0]:=(scroll_y[0] and $ff00) or valor;
   $dd03:scroll_y[0]:=(scroll_y[0] and $00ff) or ((valor and $1) shl 8);
   $dd04:bg_enable[0]:=(valor and $1)<>0;
   $dd05:bg_bank[0]:=valor and $1;
   $de00:scroll_x[1]:=(scroll_x[1] and $ff00) or valor;
   $de01:scroll_x[1]:=(scroll_x[1] and $00ff) or ((valor and $1) shl 8);
   $de02:scroll_y[1]:=(scroll_y[1] and $ff00) or valor;
   $de03:scroll_y[1]:=(scroll_y[1] and $00ff) or ((valor and $1) shl 8);
   $de04:bg_enable[1]:=(valor and $1)<>0;
   $de05:bg_bank[1]:=valor and $1;
   $df00:scroll_x[2]:=(scroll_x[2] and $ff00) or valor;
   $df01:scroll_x[2]:=(scroll_x[2] and $00ff) or ((valor and $1) shl 8);
   $df02:scroll_y[2]:=(scroll_y[2] and $ff00) or valor;
   $df03:scroll_y[2]:=(scroll_y[2] and $00ff) or ((valor and $1) shl 8);
   $df04:bg_enable[2]:=(valor and $1)<>0;
   $df05:bg_bank[2]:=valor and $1;
   $e000..$f9ff:memoria[direccion]:=valor;
   $fa00..$ffff:buffer_sprites[direccion-$fa00]:=valor;
end;
end;

//Sound
function upl_snd_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$c7ff:upl_snd_getbyte:=mem_snd[direccion];
  $e000:upl_snd_getbyte:=sound_latch;
end;
end;

procedure upl_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$bfff:;
  $c000..$c7ff:mem_snd[direccion]:=valor;
  $f000:;
end;
end;

function upl_snd_inbyte(puerto:word):byte;
begin
case (puerto and $ff) of
  $00:upl_snd_inbyte:=ym2203_0.status;
  $01:upl_snd_inbyte:=ym2203_0.Read;
  $80:upl_snd_inbyte:=ym2203_1.status;
  $81:upl_snd_inbyte:=ym2203_1.Read;
end;
end;

procedure upl_snd_outbyte(puerto:word;valor:byte);
begin
case (puerto and $ff) of
  $00:ym2203_0.Control(valor);
  $01:ym2203_0.Write(valor);
  $80:ym2203_1.Control(valor);
  $81:ym2203_1.Write(valor);
end;
end;

procedure upl_snd_irq(irqstate:byte);
begin
  z80_1.change_irq(irqstate);
end;

procedure upl_sound_update;
begin
  ym2203_0.Update;
  ym2203_1.Update;
end;

procedure reset_upl;
var
  f:byte;
begin
 z80_0.reset;
 z80_0.im0:=$d7;  //rst 10
 z80_1.reset;
 YM2203_0.reset;
 YM2203_1.reset;
 if main_vars.tipo_maquina=120 then dac_0.reset;
 reset_audio;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 rom_nbank:=0;
 sprite_overdraw:=false;
 sound_latch:=0;
 ninjakid2_pcm_pos:=0;
 for f:=0 to 2 do begin
    bg_bank[f]:=0;
    bg_enable[f]:=false;
    scroll_x[f]:=0;
    scroll_y[f]:=0;
 end;
end;

function iniciar_upl:boolean;
var
  f:byte;
  memoria_temp:array[0..$7ffff] of byte;
  mem_key:array[0..$1fff] of byte;
const
    pt_x:array[0..15] of dword=(0*4, 1*4, 2*4, 3*4, 4*4, 5*4, 6*4, 7*4,
			32*8+0*4, 32*8+1*4, 32*8+2*4, 32*8+3*4, 32*8+4*4, 32*8+5*4, 32*8+6*4, 32*8+7*4);
    pt_y:array[0..15] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32,
			64*8+0*32, 64*8+1*32, 64*8+2*32, 64*8+3*32, 64*8+4*32, 64*8+5*32, 64*8+6*32, 64*8+7*32);
    pt_x_r:array[0..15] of dword=(0*4, 1*4, 2*4, 3*4, 4*4, 5*4, 6*4, 7*4,
		4*8*16+0*4, 4*8*16+1*4, 4*8*16+2*4, 4*8*16+3*4, 4*8*16+4*4, 4*8*16+5*4, 4*8*16+6*4, 4*8*16+7*4);
    pt_y_r:array[0..15] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32,
			8*32, 9*32, 10*32, 11*32, 12*32, 13*32, 14*32, 15*32);
procedure lineswap_gfx_roms(length:dword;src:pbyte;bit:byte);
var
  ptemp,ptemp2,ptemp3:pbyte;
  f,pos,mask:dword;
begin
  getmem(ptemp,length);
	mask:=(1 shl (bit+1))-1;
	for f:=0 to (length-1) do begin
		pos:=(f and not(mask)) or ((f shl 1) and mask) or ((f shr bit) and 1);
    ptemp2:=ptemp;
    inc(ptemp2,pos);
    ptemp3:=src;
    inc(ptemp3,f);
    ptemp2^:=ptemp3^;
	end;
  copymemory(src,ptemp,length);
	freemem(ptemp);
end;
procedure extract_char(swap:boolean);
begin
  if swap then lineswap_gfx_roms($8000,@memoria_temp,13);
  init_gfx(0,8,8,$400);
  gfx_set_desc_data(4,0,32*8,0,1,2,3);
  convert_gfx(0,0,@memoria_temp,@pt_x,@pt_y,false,false);
end;
procedure extract_gr2(size:dword;num:byte;size_gr:word;swap:boolean);
begin
  init_gfx(num,16,16,size_gr);
  if swap then begin
    lineswap_gfx_roms(size,@memoria_temp,14);
    gfx_set_desc_data(4,0,128*8,0,1,2,3);
    convert_gfx(num,0,@memoria_temp,@pt_x,@pt_y,false,false);
  end else begin
    gfx_set_desc_data(4,0,16*16*4,0,1,2,3);
    convert_gfx(num,0,@memoria_temp,@pt_x_r,@pt_y_r,false,false);
  end;
end;
begin
llamadas_maquina.bucle_general:=upl_principal;
llamadas_maquina.reset:=reset_upl;
llamadas_maquina.fps_max:=59.61;
iniciar_upl:=false;
iniciar_audio(false);
screen_init(1,256,256,true);  //FG
screen_init(2,512,512);  //BG0
screen_mod_scroll(2,512,256,511,512,256,511);
if main_vars.tipo_maquina=307 then begin
  screen_init(5,512,512,true); //BG1
  screen_mod_scroll(5,512,256,511,512,256,511);
  screen_init(6,512,512,true); //BG2
  screen_mod_scroll(6,512,256,511,512,256,511);
end;
screen_init(3,512,256,false,true);
screen_init(4,512,256,true); //Sprites
iniciar_video(256,192);
//Main CPU
z80_0:=cpu_z80.create(6000000,256);
z80_0.change_ram_calls(upl_getbyte,upl_putbyte);
//Sound CPU
z80_1:=cpu_z80.create(5000000,256);
z80_1.change_ram_calls(upl_snd_getbyte,upl_snd_putbyte);
z80_1.change_io_calls(upl_snd_inbyte,upl_snd_outbyte);
//Que no se me olvide!!! Primero la CPU de sonido y luego el chip de audio!!!!
if main_vars.tipo_maquina=120 then z80_1.init_sound(ninjakid2_sound_update)
  else z80_1.init_sound(upl_sound_update);
//Sound Chips
ym2203_0:=ym2203_chip.create(1500000,0.5,0.1);
ym2203_0.change_irq_calls(upl_snd_irq);
ym2203_1:=ym2203_chip.create(1500000,0.5,0.1);
//Video
update_video_upl:=update_video_ninjakid2;
update_background:=bg_upl;
sprite_color:=$100;
fg_color:=$200;
xshift:=0;
yshift:=1;
sprite_comp:=sprite_comp_upl;
case main_vars.tipo_maquina of
  120:begin
        z80_0.change_ram_calls(ninjakid2_getbyte,ninjakid2_putbyte);
        z80_1.change_ram_calls(ninjakid2_snd_getbyte,ninjakid2_snd_putbyte);
        update_background:=bg_ninjakid2;
        //cargar roms y ponerlas en sus bancos
        if not(roms_load(@memoria_temp,ninjakid2_rom)) then exit;
        copymemory(@memoria[0],@memoria_temp[0],$8000);
        for f:=0 to 7 do copymemory(@rom_bank[f,0],@memoria_temp[(f*$4000)+$8000],$4000);
        //cargar ROMS sonido y desencriptar
        if not(roms_load(@mem_snd,ninjakid2_snd_rom)) then exit;
        if not(roms_load(@mem_key,ninjakid2_snd_key)) then exit;
        mc8123_decrypt_rom(@mem_key,@mem_snd,@mem_snd_opc,$8000);
        if not(roms_load(@ninjakid2_pcm,ninjakid2_pcm_rom)) then exit;
        dac_0:=dac_chip.Create(1);
        ninjakid2_timer:=timers.init(z80_1.numero_cpu,5000000/16300,ninjakid2_snd_timer,nil,false);
        //convertir fg
        if not(roms_load(@memoria_temp,ninjakid2_fgtiles)) then exit;
        extract_char(true);
        //convertir bg
        if not(roms_load(@memoria_temp,ninjakid2_bgtiles)) then exit;
        extract_gr2($20000,1,$400,true);
        //convertir sprites
        if not(roms_load(@memoria_temp,ninjakid2_sprites)) then exit;
        extract_gr2($20000,2,$400,true);
        //DIP
        marcade.dswa:=$6f;
        marcade.dswb:=$fd;
        marcade.dswa_val:=@ninjakid2_dip_a;
        marcade.dswb_val:=@ninjakid2_dip_b;
  end;
  121:begin
        //cargar roms y ponerlas en sus bancos
        if not(roms_load(@memoria_temp,aarea_rom)) then exit;
        copymemory(@memoria[0],@memoria_temp[0],$8000);
        for f:=0 to 7 do copymemory(@rom_bank[f,0],@memoria_temp[(f*$4000)+$8000],$4000);
        //cargar ROMS sonido
        if not(roms_load(@mem_snd,aarea_snd_rom)) then exit;
        //convertir fg
        if not(roms_load(@memoria_temp,aarea_fgtiles)) then exit;
        extract_char(true);
        //convertir bg
        if not(roms_load(@memoria_temp,aarea_bgtiles)) then exit;
        extract_gr2($30000,1,$600,true);
        //convertir sprites
        if not(roms_load(@memoria_temp,aarea_sprites)) then exit;
        extract_gr2($30000,2,$600,true);
        //DIP
        marcade.dswa:=$ef;
        marcade.dswb:=$ff;
        marcade.dswa_val:=@aarea_dip_a;
      end;
  122:begin
        //cargar roms y ponerlas en sus bancos
        if not(roms_load(@memoria_temp,mnight_rom)) then exit;
        copymemory(@memoria[0],@memoria_temp[0],$8000);
        for f:=0 to 7 do copymemory(@rom_bank[f,0],@memoria_temp[(f*$4000)+$8000],$4000);
        //cargar ROMS sonido
        if not(roms_load(@mem_snd,mnight_snd_rom)) then exit;
        //convertir fg
        if not(roms_load(@memoria_temp,mnight_fgtiles)) then exit;
        extract_char(true);
        //convertir bg
        if not(roms_load(@memoria_temp,mnight_bgtiles)) then exit;
        extract_gr2($30000,1,$600,true);
        //convertir sprites
        if not(roms_load(@memoria_temp,mnight_sprites)) then exit;
        extract_gr2($30000,2,$600,true);
        //DIP
        marcade.dswa:=$cf;
        marcade.dswb:=$ff;
        marcade.dswa_val:=@mnight_dip_a;
        marcade.dswb_val:=@mnight_dip_b;
      end;
  307:begin  //Atomic Robo-kid
        sprite_color:=$200;
        fg_color:=$300;
        xshift:=1;
        yshift:=0;
        update_video_upl:=update_video_robokid;
        sprite_comp:=sprite_comp_robokid;
        z80_0.change_ram_calls(robokid_getbyte,robokid_putbyte);
        if not(roms_load(@memoria_temp,robokid_rom)) then exit;
        copymemory(@memoria,@memoria_temp,$8000);
        for f:=0 to $f do copymemory(@rom_bank[f,0],@memoria_temp[f*$4000],$4000);
        //Parches!
        memoria[$5247]:=$e6;
        memoria[$5248]:=$03;
        memoria[$5249]:=$18;
        memoria[$524a]:=$f6;
        //cargar ROMS sonido
        if not(roms_load(@mem_snd,robokid_snd_rom)) then exit;
        //convertir fg
        if not(roms_load(@memoria_temp,robokid_fgtiles)) then exit;
        extract_char(false);
        //convertir bg0
        if not(roms_load(@memoria_temp,robokid_bgtiles0)) then exit;
        extract_gr2($80000,1,$1000,false);
        //convertir sprites
        if not(roms_load(@memoria_temp,robokid_sprites)) then exit;
        extract_gr2($40000,2,$800,false);
        //convertir bg1
        if not(roms_load(@memoria_temp,robokid_bgtiles1)) then exit;
        extract_gr2($80000,3,$1000,false);
        gfx[3].trans[15]:=true;
        //convertir bg2
        if not(roms_load(@memoria_temp,robokid_bgtiles2)) then exit;
        extract_gr2($80000,4,$1000,false);
        gfx[4].trans[15]:=true;
        //DIP
        marcade.dswa:=$cf;
        marcade.dswb:=$ff;
        marcade.dswa_val:=@robokid_dip_a;
        marcade.dswb_val:=@mnight_dip_b;
      end;
end;
gfx[0].trans[15]:=true;
gfx[2].trans[15]:=true;
//final
reset_upl;
iniciar_upl:=true;
end;

end.
