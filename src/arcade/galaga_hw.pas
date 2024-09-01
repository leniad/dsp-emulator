unit galaga_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,namco_snd,controls_engine,gfx_engine,namcoio_06xx_5xxx,
     rom_engine,pal_engine,sound_engine,galaga_stars_const,samples,misc_functions;

function iniciar_galagahw:boolean;

implementation
const
        //Galaga
        galaga_rom:array[0..3] of tipo_roms=(
        (n:'gg1_1b.3p';l:$1000;p:0;crc:$ab036c9f),(n:'gg1_2b.3m';l:$1000;p:$1000;crc:$d9232240),
        (n:'gg1_3.2m';l:$1000;p:$2000;crc:$753ce503),(n:'gg1_4b.2l';l:$1000;p:$3000;crc:$499fcc76));
        galaga_sub:tipo_roms=(n:'gg1_5b.3f';l:$1000;p:0;crc:$bb5caae3);
        galaga_sub2:tipo_roms=(n:'gg1_7b.2c';l:$1000;p:0;crc:$d016686b);
        galaga_prom:array[0..2] of tipo_roms=(
        (n:'prom-5.5n';l:$20;p:0;crc:$54603c6b),(n:'prom-4.2n';l:$100;p:$20;crc:$59b6edab),
        (n:'prom-3.1c';l:$100;p:$120;crc:$4a04bb6b));
        galaga_char:tipo_roms=(n:'gg1_9.4l';l:$1000;p:0;crc:$58b2f47c);
        galaga_sound:tipo_roms=(n:'prom-1.1d';l:$100;p:0;crc:$7a2815b4);
        galaga_sprites:array[0..1] of tipo_roms=(
        (n:'gg1_11.4d';l:$1000;p:0;crc:$ad447c80),(n:'gg1_10.4f';l:$1000;p:$1000;crc:$dd6f1afc));
        galaga_samples:array[0..1] of tipo_nombre_samples=(
        (nombre:'bang.wav'),(nombre:'init.wav'));
        galaga_dip_a:array [0..5] of def_dip2=(
        (mask:3;name:'Difficulty';number:4;val4:(3,0,1,2);name4:('Easy','Medium','Hard','Hardest')),
        (mask:8;name:'Demo Sounds';number:2;val2:(8,0);name2:('Off','On')),
        (mask:$10;name:'Freeze';number:2;val2:($10,0);name2:('Off','On')),
        (mask:$20;name:'Rack test';number:2;val2:($20,0);name2:('Off','On')),
        (mask:$80;name:'Cabinet';number:2;val2:($80,0);name2:('Upright','Cocktail')),());
        galaga_dip_b:array [0..3] of def_dip2=(
        (mask:7;name:'Coinage';number:8;val8:(4,2,6,7,1,3,5,0);name8:('4C 1C','3C 1C','2C 1C','1C 1C','2C 3C','1C 2C','1C 3C','Free Play')),
        (mask:$38;name:'Bonus Life';number:8;val8:($20,$18,$10,$30,$38,8,$28,0);name8:('20K 60K 60K+','20K 60K','20K 70K 70K+','20K 80K 80K+','20K 80K','30K 100K 100K+','30K 120K 120K+','None')),
        (mask:$c0;name:'Lives';number:4;val4:(0,$80,$40,$c0);name4:('2','3','4','5')),());
        //Dig Dug
        digdug_rom:array[0..3] of tipo_roms=(
        (n:'dd1a.1';l:$1000;p:0;crc:$a80ec984),(n:'dd1a.2';l:$1000;p:$1000;crc:$559f00bd),
        (n:'dd1a.3';l:$1000;p:$2000;crc:$8cbc6fe1),(n:'dd1a.4';l:$1000;p:$3000;crc:$d066f830));
        digdug_sub:array[0..1] of tipo_roms=(
        (n:'dd1a.5';l:$1000;p:0;crc:$6687933b),(n:'dd1a.6';l:$1000;p:$1000;crc:$843d857f));
        digdug_sub2:tipo_roms=(n:'dd1.7';l:$1000;p:0;crc:$a41bce72);
        digdug_prom:array[0..2] of tipo_roms=(
        (n:'136007.113';l:$20;p:0;crc:$4cb9da99),(n:'136007.111';l:$100;p:$20;crc:$00c7c419),
        (n:'136007.112';l:$100;p:$120;crc:$e9b3e08e));
        digdug_sound:tipo_roms=(n:'136007.110';l:$100;p:0;crc:$7a2815b4);
        digdug_chars:tipo_roms=(n:'dd1.9';l:$800;p:0;crc:$f14a6fe1);
        digdug_sprites:array[0..3] of tipo_roms=(
        (n:'dd1.15';l:$1000;p:0;crc:$e22957c8),(n:'dd1.14';l:$1000;p:$1000;crc:$2829ec99),
        (n:'dd1.13';l:$1000;p:$2000;crc:$458499e9),(n:'dd1.12';l:$1000;p:$3000;crc:$c58252a0));
        digdug_chars2:tipo_roms=(n:'dd1.11';l:$1000;p:0;crc:$7b383983);
        digdug_background:tipo_roms=(n:'dd1.10b';l:$1000;p:0;crc:$2cf399c2);
        digdug_dip_a:array [0..3] of def_dip2=(
        (mask:7;name:'Coin B';number:8;val8:(7,3,1,5,6,2,4,0);name8:('3C 1C','2C 1C','1C 1C','2C 3C','1C 2C','1C 3C','1C 6C','1C 7C')),
        (mask:$38;name:'Bonus Life';number:8;val8:($20,$10,$30,8,$28,$18,$38,0);name8:('10K 40K 40K+','10K 50K 50K+','20K 60K 60K+','20K 70K 70K+','10K 40K','20K 60K','10K','None')),
        (mask:$c0;name:'Lives';number:4;val4:(0,$40,$80,$c0);name4:('1','2','3','5')),());
        digdug_dip_b:array [0..6] of def_dip2=(
        (mask:3;name:'Difficulty';number:4;val4:(0,2,1,3);name4:('Easy','Medium','Hard','Hardest')),
        (mask:4;name:'Cabinet';number:2;val2:(4,0);name2:('Upright','Cocktail')),
        (mask:8;name:'Allow Continue';number:2;val2:(8,0);name2:('No','Yes')),
        (mask:$10;name:'Demo Sounds';number:2;val2:($10,0);name2:('Off','On')),
        (mask:$20;name:'Freeze';number:2;val2:($20,0);name2:('Off','On')),
        (mask:$c0;name:'Coin A';number:4;val4:($40,0,$c0,$80);name4:('2C 1C','1C 1C','2C 3C','1C 2C')),());
        //Xevious
        xevious_rom:array[0..3] of tipo_roms=(
        (n:'xvi_1.3p';l:$1000;p:0;crc:$09964dda),(n:'xvi_2.3m';l:$1000;p:$1000;crc:$60ecce84),
        (n:'xvi_3.2m';l:$1000;p:$2000;crc:$79754b7d),(n:'xvi_4.2l';l:$1000;p:$3000;crc:$c7d4bbf0));
        xevious_sub:array[0..1] of tipo_roms=(
        (n:'xvi_5.3f';l:$1000;p:$0;crc:$c85b703f),(n:'xvi_6.3j';l:$1000;p:$1000;crc:$e18cdaad));
        xevious_sub2:tipo_roms=(n:'xvi_7.2c';l:$1000;p:0;crc:$dd35cf1c);
        xevious_prom:array[0..6] of tipo_roms=(
        (n:'xvi-8.6a';l:$100;p:0;crc:$5cc2727f),(n:'xvi-9.6d';l:$100;p:$100;crc:$5c8796cc),
        (n:'xvi-10.6e';l:$100;p:$200;crc:$3cb60975),(n:'xvi-7.4h';l:$200;p:$300;crc:$22d98032),
        (n:'xvi-6.4f';l:$200;p:$500;crc:$3a7599f0),(n:'xvi-4.3l';l:$200;p:$700;crc:$fd8b9d91),
        (n:'xvi-5.3m';l:$200;p:$900;crc:$bf906d82));
        xevious_sound:tipo_roms=(n:'xvi-2.7n';l:$100;p:0;crc:$550f06bc);
        xevious_char:tipo_roms=(n:'xvi_12.3b';l:$1000;p:0;crc:$088c8b26);
        xevious_sprites:array[0..3] of tipo_roms=(
        (n:'xvi_15.4m';l:$2000;p:0;crc:$dc2c0ecb),(n:'xvi_17.4p';l:$2000;p:$2000;crc:$dfb587ce),
        (n:'xvi_16.4n';l:$1000;p:$4000;crc:$605ca889),(n:'xvi_18.4r';l:$2000;p:$5000;crc:$02417d19));
        xevious_bg:array[0..1] of tipo_roms=(
        (n:'xvi_13.3c';l:$1000;p:$0;crc:$de60ba25),(n:'xvi_14.3d';l:$1000;p:$1000;crc:$535cdbbc));
        xevious_bg_tiles:array[0..2] of tipo_roms=(
        (n:'xvi_9.2a';l:$1000;p:0;crc:$57ed9879),(n:'xvi_10.2b';l:$2000;p:$1000;crc:$ae3ba9e5),
        (n:'xvi_11.2c';l:$1000;p:$3000;crc:$31e244dd));
        xevious_samples:array[0..1] of tipo_nombre_samples=(
        (nombre:'explo2.wav'),(nombre:'explo1.wav'));
        xevious_dip_a:array [0..4] of def_dip2=(
        (mask:3;name:'Coin A';number:4;val4:(1,3,0,2);name4:('2C 1C','1C 1C','2C 3C','1C 2C')),
        (mask:$1c;name:'Bonus Life';number:8;val8:($18,$14,$10,$1c,$c,8,4,0);name8:('10K 40K 40K+','10K 50K 50K+','20K 50K 50K+','20K 60K 60K+','20K 70K 70+','20K 80K 80K+','20K 60K','None')),
        (mask:$60;name:'Lives';number:4;val4:($40,$20,$60,0);name4:('1','2','3','5')),
        (mask:$80;name:'Cabinet';number:2;val2:($80,0);name2:('Upright','Cocktail')),());
        xevious_dip_b:array [0..4] of def_dip2=(
        (mask:2;name:'Flags Award Bonus Life';number:2;val2:(0,1);name2:('No','Yes')),
        (mask:$c;name:'Coin B';number:4;val4:(4,$c,0,8);name4:('2C 1C','1C 1C','2C 3C','1C 2C')),
        (mask:$60;name:'Difficulty';number:4;val4:($40,$60,$20,0);name4:('Easy','Normal','Hard','Hardest')),
        (mask:$80;name:'Freeze';number:2;val2:($80,0);name2:('Off','On')),());
        //Bosconian
        bosco_rom:array[0..3] of tipo_roms=(
        (n:'bos3_1.3n';l:$1000;p:0;crc:$96021267),(n:'bos1_2.3m';l:$1000;p:$1000;crc:$2d8f3ebe),
        (n:'bos1_3.3l';l:$1000;p:$2000;crc:$c80ccfa5),(n:'bos1_4b.3k';l:$1000;p:$3000;crc:$a3f7f4ab));
        bosco_sub:array[0..1] of tipo_roms=(
        (n:'bos1_5c.3j';l:$1000;p:$0;crc:$a7c8e432),(n:'bos3_6.3h';l:$1000;p:$1000;crc:$4543cf82));
        bosco_sub2:tipo_roms=(n:'bos1_7.3e';l:$1000;p:0;crc:$d45a4911);
        bosco_char:tipo_roms=(n:'bos1_14.5d';l:$1000;p:0;crc:$a956d3c5);
        bosco_sprites:tipo_roms=(n:'bos1_13.5e';l:$1000;p:0;crc:$e869219c);
        bosco_dots:tipo_roms=(n:'bos1-4.2r';l:$100;p:0;crc:$9b69b543);
        bosco_prom:array[0..3] of tipo_roms=(
        (n:'bos1-6.6b';l:$20;p:0;crc:$d2b96fb0),(n:'bos1-5.4m';l:$100;p:$20;crc:$4e15d59c),
        (n:'bos1-3.2d';l:$20;p:$120;crc:$b88d5ba9),(n:'bos1-7.7h';l:$20;p:$140;crc:$87d61353));
        bosco_snd:tipo_roms=(n:'bos1-1.1d';l:$100;p:$0;crc:$de2316c6);
        bosco_52xx:array[0..2] of tipo_roms=(
        (n:'bos1_9.5n';l:$1000;p:$0;crc:$09acc978),(n:'bos1_10.5m';l:$1000;p:$1000;crc:$e571e959),
        (n:'bos1_11.5k';l:$1000;p:$2000;crc:$17ac9511));
        bosco_samples:array[0..2] of tipo_nombre_samples=(
        (nombre:'bigbang.wav'),(nombre:'midbang.wav'),(nombre:'shot.wav';restart:true;loop:false));
        bosco_dip_a:array [0..5] of def_dip2=(
        (mask:3;name:'Difficulty';number:4;val4:(1,3,2,0);name4:('Easy','Medium','Hardest','Auto')),
        (mask:4;name:'Allow Continue';number:2;val2:(0,4);name2:('No','Yes')),
        (mask:8;name:'Demo Sounds';number:2;val2:(8,0);name2:('Off','On')),
        (mask:$10;name:'Freeze';number:2;val2:($10,0);name2:('Off','On')),
        (mask:$80;name:'Cabinet';number:2;val2:($80,0);name2:('Upright','Cocktail')),());
        bosco_dip_b:array [0..3] of def_dip2=(
        (mask:7;name:'Coinage';number:8;val8:(1,2,3,7,4,6,5,0);name8:('4C 1C','3C 1C','2C 1C','1C 1C','2C 3C','1C 2C','1C 3C','Free Play')),
        (mask:$38;name:'Bonus Fighter';number:8;val8:($30,$38,8,$10,$18,$20,$28,0);name8:('15K 50K','20K 70K','10K 50K 50K+','15K 50K 50K+','15K 70K 70+','20K 70K 70K+','30K 100K 100K+','None')),
        (mask:$c0;name:'Lives';number:4;val4:(0,$80,$40,$c0);name4:('2','3','4','5')),());
        //Super Xevious
        sxevious_rom:array[0..3] of tipo_roms=(
        (n:'cpu_3p.rom';l:$1000;p:0;crc:$1c8d27d5),(n:'cpu_3m.rom';l:$1000;p:$1000;crc:$fd04e615),
        (n:'xv3_3.2m';l:$1000;p:$2000;crc:$294d5404),(n:'xv3_4.2l';l:$1000;p:$3000;crc:$6a44bf92));
        sxevious_sub:array[0..1] of tipo_roms=(
        (n:'xv3_5.3f';l:$1000;p:$0;crc:$d4bd3d81),(n:'xv3_6.3j';l:$1000;p:$1000;crc:$af06be5f));
        sxevious_dip_b:array [0..4] of def_dip2=(
        (mask:2;name:'Flags Award Bonus Life';number:2;val2:(0,1);name2:('No','Yes')),
        (mask:$c;name:'Coin B';number:4;val4:($c,8,4,0);name4:('1C 1C','1C 2C','1C 3C','1C 6C')),
        (mask:$60;name:'Difficulty';number:4;val4:($40,$60,$20,0);name4:('Easy','Normal','Hard','Hardest')),
        (mask:$80;name:'Freeze';number:2;val2:(0,$80);name2:('Off','On')),());
        MAX_STARS=252;

var
 main_irq,sub_irq,sub2_nmi:boolean;
 scrollx_bg,scrolly_bg:word;
 //Galaga
 galaga_starcontrol:array[0..5] of byte;
 //Dig Dug
 digdug_bg:array[0..$fff] of byte;
 custom_mod,bg_select,bg_color_bank,tx_color_mode:byte;
 bg_disable,bg_repaint:boolean;
 //Xevious
 xevious_tiles:array[0..$3fff] of byte;
 xevious_bs:array[0..1] of byte;
 scrollx_fg,scrolly_fg:word;

procedure update_video_galaga;
procedure draw_sprites_galaga;
var
  nchar,f,atrib,a,b,c,d:byte;
  color,x,y:word;
  flipx,flipy:boolean;
begin
for f:=0 to $3f do begin
		nchar:=memoria[$8b80+(f*2)] and $7f;
		color:=(memoria[$8b81+(f*2)] and $3f) shl 2;
		y:=memoria[$9381+(f*2)]-40+$100*(memoria[$9b81+(f*2)] and 3);
    x:=memoria[$9380+(f*2)]-16-1;	// sprites are buffered and delayed by one scanline
    atrib:=memoria[$9b80+(f*2)];
    flipx:=(atrib and 2)<>0;
    flipy:=(atrib and 1)<>0;
		case (atrib and $c) of
        0:begin  //16x16
            put_gfx_sprite_mask(nchar,color,flipx,flipy,1,$f,$f);
            actualiza_gfx_sprite(x,y,2,1);
          end;
        4:begin  //16x32
            a:=0 xor byte(flipy);
            b:=1 xor byte(flipy);
            put_gfx_sprite_mask_diff(nchar+a,color,flipx,flipy,1,$f,$f,0,16);
            put_gfx_sprite_mask_diff(nchar+b,color,flipx,flipy,1,$f,$f,0,0);
            actualiza_gfx_sprite_size(x,y,2,16,32);
          end;
        8:begin  //32x16
            a:=0 xor (byte(flipx) shl 1);
            b:=2 xor (byte(flipx) shl 1);
            put_gfx_sprite_mask_diff(nchar+a,color,flipx,flipy,1,$f,$f,16,0);
            put_gfx_sprite_mask_diff(nchar+b,color,flipx,flipy,1,$f,$f,0,0);
            actualiza_gfx_sprite_size(x,y,2,32,16);
          end;
       $c:begin  //32x32
            a:=0 xor byte(flipy) xor (byte(flipx) shl 1);
            b:=1 xor byte(flipy) xor (byte(flipx) shl 1);
            c:=2 xor byte(flipy) xor (byte(flipx) shl 1);
            d:=3 xor byte(flipy) xor (byte(flipx) shl 1);
            put_gfx_sprite_mask_diff(nchar+a,color,flipx,flipy,1,$f,$f,16,0);
            put_gfx_sprite_mask_diff(nchar+b,color,flipx,flipy,1,$f,$f,16,16);
            put_gfx_sprite_mask_diff(nchar+c,color,flipx,flipy,1,$f,$f,0,0);
            put_gfx_sprite_mask_diff(nchar+d,color,flipx,flipy,1,$f,$f,0,16);
            actualiza_gfx_sprite_size(x,y,2,32,32);
          end;
    end;
end;
end;

procedure update_stars;
const
  speeds:array[0..7] of integer=(-1,-2,-3,0,3,2,1,0);
var
  s0,s1,s2:byte;
begin
	s0:=galaga_starcontrol[0] and 1;
	s1:=galaga_starcontrol[1] and 1;
	s2:=galaga_starcontrol[2] and 1;
	scrolly_bg:=scrolly_bg+speeds[s0+s1*2+s2*4];
end;

procedure draw_stars;
var
  star_cntr,set_a,set_b:byte;
  x,y,color:word;
begin
if (galaga_starcontrol[5] and 1)=1 then begin
		// two sets of stars controlled by these bits
		set_a:=galaga_starcontrol[3] and 1;
		set_b:=(galaga_starcontrol[4] and 1) or 2;
		for star_cntr:=0 to (MAX_STARS-1) do begin
			if ((set_a=star_seed_tab[star_cntr].set_) or (set_b=star_seed_tab[star_cntr].set_)) then begin
				y:=(star_seed_tab[star_cntr].y+scrolly_bg) mod 256+16;
				x:=(112+star_seed_tab[star_cntr].x+scrollx_bg) mod 256;
        color:=paleta[32+star_seed_tab[star_cntr].col];
        putpixel(x+ADD_SPRITE,y+ADD_SPRITE,1,@color,2);
			end;
		end;
end;
end;

var
  color,nchar,pos:word;
  sx,sy,x,y:byte;
begin
fill_full_screen(2,100);
draw_stars;
draw_sprites_galaga;
for x:=0 to 27 do begin
  for y:=0 to 35 do begin
      sx:=29-x;
      sy:=y-2;
	    if (sy and $20)<>0 then pos:=sx+((sy and $1f) shl 5)
  	    else pos:=sy+(sx shl 5);
      if gfx[0].buffer[pos] then begin
        color:=(memoria[$8400+pos] and $3f) shl 2;
        nchar:=memoria[$8000+pos];
        put_gfx_mask(x*8,y*8,nchar,color,1,0,$f,$f);
        gfx[0].buffer[pos]:=false;
      end;
  end;
end;
actualiza_trozo(0,0,224,288,1,0,0,224,288,2);
actualiza_trozo_final(0,0,224,288,2);
update_stars;
end;

procedure eventos_galaga;
begin
if event.arcade then begin
  //P1 & P2
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or 8);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
  //System
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.but0[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  //Extra P1 & P2 (Xevious solo)
  if arcade_input.but1[0] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or 1);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
end;
end;

procedure galaga_principal;
var
  frame_m,frame_s1,frame_s2:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=z80_0.tframes;
frame_s1:=z80_2.tframes;
frame_s2:=z80_1.tframes;
while EmuStatus=EsRunning do begin
  for f:=0 to 263 do begin
    //Main CPU
    z80_0.run(frame_m);
    frame_m:=frame_m+z80_0.tframes-z80_0.contador;
    //Sub CPU
    z80_2.run(frame_s1);
    frame_s1:=frame_s1+z80_2.tframes-z80_2.contador;
    //Sub 2 CPU
    z80_1.run(frame_s2);
    frame_s2:=frame_s2+z80_1.tframes-z80_1.contador;
    run_namco_54xx;
    case f of
      63,191:if sub2_nmi then z80_1.change_nmi(PULSE_LINE);
      223:begin
            if main_irq then z80_0.change_irq(ASSERT_LINE);
            if sub_irq then z80_2.change_irq(ASSERT_LINE);
            update_video_galaga;
            copymemory(@buffer_sprites,@memoria[$fe00],$200);
          end;
    end;
  end;
  eventos_galaga;
  video_sync;
end;
end;

procedure galaga_latch(dir,val:byte);
var
  bit:byte;
begin
bit:=val and 1;
case dir of
		0:begin	// IRQ1
        main_irq:=bit<>0;
			  if not(main_irq) then z80_0.change_irq(CLEAR_LINE);
			 end;
		1:begin	// IRQ2
			    sub_irq:=bit<>0;
  			  if not(sub_irq) then z80_2.change_irq(CLEAR_LINE);
			 end;
		2:sub2_nmi:=(bit=0);	// NMION
		3:if (bit<>0) then begin  // RESET
          z80_1.change_reset(CLEAR_LINE);
          z80_2.change_reset(CLEAR_LINE);
       end else begin
          z80_1.change_reset(ASSERT_LINE);
          z80_2.change_reset(ASSERT_LINE);
       end;
		4:; //n.c.
    5:custom_mod:=(custom_mod and $fe) or (bit shl 0);	// MOD 0
		6:custom_mod:=(custom_mod and $fd) or (bit shl 1);	// MOD 1
    7:custom_mod:=(custom_mod and $fb) or (bit shl 2);	// MOD 2
end;
end;

function galaxian_dip(direccion:byte):byte;
var
  bit0,bit1:byte;
begin
bit0:=(marcade.dswb shr direccion) and 1;
bit1:=(marcade.dswa shr direccion) and 1;
galaxian_dip:=bit0 or (bit1 shl 1);
end;

function galaga_getbyte(direccion:word):byte;
begin
case direccion of
  0..$3fff,$8000..$8bff,$9000..$93ff,$9800..$9bff:galaga_getbyte:=memoria[direccion];
  $6800..$6807:galaga_getbyte:=galaxian_dip(direccion and 7);
  $7000..$70ff:galaga_getbyte:=namco_06xx_data_r(direccion and $ff,0);
  $7100:galaga_getbyte:=namco_06xx_ctrl_r(0);
end;
end;

procedure galaga_putbyte(direccion:word;valor:byte);
begin
case direccion of
    0..$3fff:; //ROM
    $6800..$681f:namco_snd_0.regs[direccion and $1f]:=valor;
    $6820..$6827:galaga_latch(direccion and 7,valor);
    $7000..$70ff:namco_06xx_data_w(direccion and $ff,0,valor);
    $7100:namco_06xx_ctrl_w(0,valor);
    $8000..$87ff:if memoria[direccion]<>valor then begin
                    gfx[0].buffer[direccion and $3ff]:=true;
                    memoria[direccion]:=valor;
                 end;
    $8800..$8bff,$9000..$93ff,$9800..$9bff:memoria[direccion]:=valor;
    $a000..$a005:galaga_starcontrol[direccion and 7]:=valor;
    $a007:main_screen.flip_main_screen:=(valor and 1)<>0;
end;
end;

function galaga_sub_getbyte(direccion:word):byte;
begin
case direccion of
  0..$3fff:galaga_sub_getbyte:=mem_snd[direccion];
  $4000..$ffff:galaga_sub_getbyte:=galaga_getbyte(direccion);
end;
end;

function galaga_sub2_getbyte(direccion:word):byte;
begin
case direccion of
  0..$3fff:galaga_sub2_getbyte:=mem_misc[direccion];
  $4000..$ffff:galaga_sub2_getbyte:=galaga_getbyte(direccion);
end;
end;

procedure galaga_sound_update;
begin
  samples_update;
  namco_snd_0.update;
end;

//DigDug
function namco_53xx_r_r(port:byte):byte;
begin
case port of
  0:namco_53xx_r_r:=marcade.dswa and $f;
  1:namco_53xx_r_r:=marcade.dswa shr 4;
  2:namco_53xx_r_r:=marcade.dswb and $f;
  3:namco_53xx_r_r:=marcade.dswb shr 4;
end;
end;

function namco_53xx_k_r:byte;
begin
  namco_53xx_k_r:=custom_mod shl 1;
end;

procedure update_video_digdug;

procedure draw_sprites_digdug;
var
  nchar,f,atrib,a,b,c,d:byte;
  color,x:word;
  y:integer;
  flipx,flipy:boolean;
begin
for f:=0 to $3f do begin
		nchar:=memoria[$8b80+(f*2)];
		color:=(memoria[$8b81+(f*2)] and $3f) shl 2;
		y:=memoria[$9381+(f*2)]-40+1;
    if y<=0 then y:=256+y;
    x:=memoria[$9380+(f*2)]-16-1;	// sprites are buffered and delayed by one scanline
    atrib:=memoria[$9b80+(f*2)];
    flipx:=(atrib and 2)<>0;
    flipy:=(atrib and 1)<>0;
	  if (nchar and $80)=0 then begin //16x16
            put_gfx_sprite_mask(nchar,color,flipx,flipy,1,$1f,$1f);
            actualiza_gfx_sprite(x,y,2,1);
      end else begin  //32x32
            a:=0 xor byte(flipy) xor (byte(flipx) shl 1);
            b:=1 xor byte(flipy) xor (byte(flipx) shl 1);
            c:=2 xor byte(flipy) xor (byte(flipx) shl 1);
            d:=3 xor byte(flipy) xor (byte(flipx) shl 1);
            nchar:=(nchar and $c0) or ((nchar and $3f) shl 2);
            put_gfx_sprite_mask_diff(nchar+a,color,flipx,flipy,1,$1f,$1f,16,0);
            put_gfx_sprite_mask_diff(nchar+b,color,flipx,flipy,1,$1f,$1f,16,16);
            put_gfx_sprite_mask_diff(nchar+c,color,flipx,flipy,1,$1f,$1f,0,0);
            put_gfx_sprite_mask_diff(nchar+d,color,flipx,flipy,1,$1f,$1f,0,16);
            actualiza_gfx_sprite_size(x,y,2,32,32);
      end;
end;
end;

var
  color,nchar,pos:word;
  sx,sy,x,y:byte;
begin
if bg_disable then fill_full_screen(3,$100);
for x:=0 to 27 do begin
  for y:=0 to 35 do begin
      sx:=29-x;
      sy:=y-2;
	    if (sy and $20)<>0 then pos:=sx+((sy and $1f) shl 5)
  	    else pos:=sy+(sx shl 5);
      //Background
      if not(bg_disable) and bg_repaint then begin
        nchar:=digdug_bg[pos or (bg_select shl 10)];
        color:=(nchar shr 4);
        put_gfx(x*8,y*8,nchar,(color or bg_color_bank) shl 2,3,2);
      end;
      //Chars
      if gfx[0].buffer[pos] then begin
        nchar:=memoria[$8000+pos];
        color:=((nchar shr 4) and $e) or ((nchar shr 3) and 2);
        put_gfx_trans(x*8,y*8,nchar and $7f,color shl 1,1,0);
        gfx[0].buffer[pos]:=false;
      end;
  end;
end;
actualiza_trozo(0,0,224,288,3,0,0,224,288,2);
actualiza_trozo(0,0,224,288,1,0,0,224,288,2);
draw_sprites_digdug;
actualiza_trozo_final(0,0,224,288,2);
bg_repaint:=false;
end;

procedure digdug_principal;
var
  frame_m,frame_s1,frame_s2:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=z80_0.tframes;
frame_s1:=z80_2.tframes;
frame_s2:=z80_1.tframes;
while EmuStatus=EsRunning do begin
 for f:=0 to 263 do begin
  //Main CPU
  z80_0.run(frame_m);
  frame_m:=frame_m+z80_0.tframes-z80_0.contador;
  //Sub CPU
  z80_2.run(frame_s1);
  frame_s1:=frame_s1+z80_2.tframes-z80_2.contador;
  //Sub 2 CPU
  z80_1.run(frame_s2);
  frame_s2:=frame_s2+z80_1.tframes-z80_1.contador;
  //IO's
  run_namco_53xx;
  case f of
    63,191:if sub2_nmi then z80_1.change_nmi(PULSE_LINE);
    223:begin
          if main_irq then z80_0.change_irq(ASSERT_LINE);
          if sub_irq then z80_2.change_irq(ASSERT_LINE);
          update_video_digdug;
    end;
  end;
 end;
 eventos_galaga;
 video_sync;
end;
end;

//Main CPU
procedure digdug_putbyte(direccion:word;valor:byte);
var
  mask,shift:byte;
begin
case direccion of
    0..$3fff:; //ROM
    $6800..$681f:namco_snd_0.regs[direccion and $1f]:=valor;
    $6820..$6827:galaga_latch(direccion and 7,valor);
    $7000..$70ff:namco_06xx_data_w(direccion and $ff,0,valor);
    $7100:namco_06xx_ctrl_w(0,valor);
    $8000..$83ff:if memoria[direccion]<>valor then begin
                    gfx[0].buffer[direccion and $3ff]:=true;
                    memoria[direccion]:=valor;
                 end;
    $8400..$8bff,$9000..$93ff,$9800..$9bff:memoria[direccion]:=valor;
    $a000..$a007:case (direccion and 7) of //port_w
		                0,1:begin	// select background picture
                          shift:=direccion and 7;
				                  mask:=1 shl shift;
				                  if ((bg_select and mask)<>((valor and 1) shl shift)) then begin
                  					bg_select:=(bg_select and not(mask)) or ((valor and 1) shl shift);
                            bg_repaint:=true;
                          end;
                        end;
		                2:if (tx_color_mode<>(valor and 1)) then tx_color_mode:=valor and 1;	// select alpha layer color mode
		                3:if bg_disable<>((valor and 1)<>0) then begin // disable background
				                 bg_disable:=(valor and 1)<>0;
                         if not(bg_disable) then bg_repaint:=true;
                        end;
		                4,5:begin //background color bank
				                  shift:=direccion and 7;
				                  mask:=1 shl shift;
				                  if ((bg_color_bank and mask)<>((valor and 1) shl shift)) then begin
					                  bg_color_bank:=(bg_color_bank and not(mask)) or ((valor and 1) shl shift);
                            bg_repaint:=true;
                          end;
                        end;
		              6:;	// n.c.
		              7:main_screen.flip_main_screen:=(valor and 1)<>0;	// FLIP
                 end;
    $b800..$b840:memoria[direccion]:=valor; //eeprom
end;
end;

function digdug_getbyte(direccion:word):byte;
begin
case direccion of
  0..$3fff,$8000..$8bff,$9000..$93ff,$9800..$9bff:digdug_getbyte:=memoria[direccion];
  $7000..$70ff:digdug_getbyte:=namco_06xx_data_r(direccion and $ff,0);
  $7100:digdug_getbyte:=namco_06xx_ctrl_r(0);
  $b800..$b83f:digdug_getbyte:=memoria[direccion]; //eeprom
end;
end;

//Sub1 CPU
function digdug_sub_getbyte(direccion:word):byte;
begin
case direccion of
  0..$3fff:digdug_sub_getbyte:=mem_snd[direccion];
  $4000..$ffff:digdug_sub_getbyte:=digdug_getbyte(direccion);
end;
end;

//Sub2 CPU
function digdug_sub2_getbyte(direccion:word):byte;
begin
case direccion of
  0..$3fff:digdug_sub2_getbyte:=mem_misc[direccion];
  $4000..$ffff:digdug_sub2_getbyte:=digdug_getbyte(direccion);
end;
end;

procedure digdug_sound_update;
begin
  namco_snd_0.update;
end;

//Xevious
procedure update_video_xevious;
procedure draw_sprites_xevious;
var
  f:byte;
  code,color,x,y,sx1,sx2,sy1,sy2:word;
  flipx,flipy:boolean;
begin
for f:=0 to $3f do begin
		if ((memoria[$a781+(f*2)] and $40)=0) then begin
			if (memoria[$9780+(f*2)] and $80)<>0 then code:=(memoria[$a780+(f*2)] and $3f)+$100
			  else code:=memoria[$a780+(f*2)];
			color:=(memoria[$a781+(f*2)] and $7f) shl 3;
			flipy:=(memoria[$9780+(f*2)] and 4)<>0;
			flipx:=(memoria[$9780+(f*2)] and 8)<>0;
			y:=memoria[$8781+(f*2)]-39+$100*(memoria[$9781+(f*2)] and 1);
			x:=memoria[$8780+(f*2)]-19;
      case memoria[$9780+(f*2)] and 3 of
        0:begin //normal
            put_gfx_sprite_mask(code,color,flipx,flipy,2,0,$f);
            actualiza_gfx_sprite(x,y,3,2);
          end;
        1:begin // double width
            code:=code and $1fe;
            sx1:=16*byte(flipx);
            sx2:=16*byte(not(flipx));
            put_gfx_sprite_mask_diff(code,color,flipx,flipy,2,0,$f,sx1,0);
            put_gfx_sprite_mask_diff(code+1,color,flipx,flipy,2,0,$f,sx2,0);
            actualiza_gfx_sprite_size(x,y,3,32,16);
          end;
        2:begin //double height
            code:=code and $1fd;
            sy1:=16*byte(flipy);
            sy2:=16*byte(not(flipy));
            put_gfx_sprite_mask_diff(code+2,color,flipx,flipy,2,0,$f,0,sy1);
            put_gfx_sprite_mask_diff(code,color,flipx,flipy,2,0,$f,0,sy2);
            actualiza_gfx_sprite_size(x,y,3,16,32);
          end;
        3:begin //double width, double height
            sx1:=16*byte(flipx);
            sx2:=16*byte(not(flipx));
            sy1:=16*byte(flipy);
            sy2:=16*byte(not(flipy));
            code:=code and $1fc;
            put_gfx_sprite_mask_diff(code+3,color,flipx,flipy,2,0,$f,sx1,sy2);
            put_gfx_sprite_mask_diff(code+1,color,flipx,flipy,2,0,$f,sx2,sy2);
            put_gfx_sprite_mask_diff(code+2,color,flipx,flipy,2,0,$f,sx1,sy1);
            put_gfx_sprite_mask_diff(code,color,flipx,flipy,2,0,$f,sx2,sy1);
            actualiza_gfx_sprite_size(x,y,3,32,32);
          end;
      end;
  end;
end;
end;

var
  f,color,nchar:word;
  x,y,atrib:byte;
begin
for f:=0 to $7ff do begin
    x:=63-(f div 64);
    y:=f mod 64;
    if gfx[0].buffer[f] then begin
        atrib:=memoria[$b000+f];
        color:=(((atrib and $3) shl 4) or ((atrib and $3c) shr 2)) shl 1;
        nchar:=memoria[$c000+f];
        put_gfx_trans_flip(x*8,y*8,nchar,color,1,0,(atrib and $80)<>0,(atrib and $40)<>0);
        gfx[0].buffer[f]:=false;
    end;
    if gfx[1].buffer[f] then begin
        nchar:=memoria[$c800+f];
        atrib:=memoria[$b800+f];
        color:=((atrib and $3c) shr 2) or ((nchar and $80) shr 3) or ((atrib and 3) shl 5);
        put_gfx_flip(x*8,y*8,nchar+((atrib and 1) shl 8),color shl 2,2,1,(atrib and $80)<>0,(atrib and $40)<>0);
        gfx[1].buffer[f]:=false;
    end;
end;
scroll_x_y(2,3,scrolly_bg+20,scrollx_bg+20,0,0,0,1);
draw_sprites_xevious;
scroll_x_y(1,3,scrolly_fg+18,scrollx_fg+32,0,0,0,1);
actualiza_trozo_final(0,0,224,288,3);
end;

procedure xevious_principal;
var
  frame_m,frame_s1,frame_s2:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=z80_0.tframes;
frame_s1:=z80_2.tframes;
frame_s2:=z80_1.tframes;
while EmuStatus=EsRunning do begin
 for f:=0 to 263 do begin
    //Main CPU
    z80_0.run(frame_m);
    frame_m:=frame_m+z80_0.tframes-z80_0.contador;
    //Sub CPU
    z80_2.run(frame_s1);
    frame_s1:=frame_s1+z80_2.tframes-z80_2.contador;
    //Sub 2 CPU
    z80_1.run(frame_s2);
    frame_s2:=frame_s2+z80_1.tframes-z80_1.contador;
    //IO's
    run_namco_50xx(0);
    run_namco_54xx;
    case f of
      63,191:if sub2_nmi then z80_1.change_nmi(PULSE_LINE);
      223:begin
          if main_irq then z80_0.change_irq(ASSERT_LINE);
          if sub_irq then z80_2.change_irq(ASSERT_LINE);
          update_video_xevious;
      end;
    end;
 end;
 eventos_galaga;
 video_sync;
end;
end;

function xevious_getbyte(direccion:word):byte;
function xevious_dip(direccion:byte):byte;
var
  bit0,bit1:byte;
begin
bit0:=((marcade.dswb or marcade.in2) shr direccion) and 1;
bit1:=(marcade.dswa shr direccion) and 1;
xevious_dip:=bit0 or (bit1 shl 1);
end;

function xevious_bb_r(direccion:byte):byte;
var
  dat1,adr_2b,adr_2c:word;
  dat2:byte;
begin
// get BS to 12 bit data from 2A,2B
adr_2b:=((xevious_bs[1] and $7e) shl 6) or ((xevious_bs[0] and $fe) shr 1);
if (adr_2b and 1)<>0 then dat1:=((xevious_tiles[0+(adr_2b shr 1)] and $f0) shl 4) or xevious_tiles[$1000+adr_2b] // high bits select
  else dat1:=((xevious_tiles[0+(adr_2b shr 1)] and $f) shl 8) or xevious_tiles[$1000+adr_2b]; // low bits select
adr_2c:=((dat1 and $1ff) shl 2) or ((xevious_bs[1] and 1) shl 1) or (xevious_bs[0] and 1);
if (dat1 and $400)<>0 then adr_2c:=adr_2c xor 1;
if (dat1 and $200)<>0 then adr_2c:=adr_2c xor 2;
if (direccion<>0) then dat2:=xevious_tiles[$3000+(adr_2c or $800)] // return BB1
else begin // return BB0
  dat2:=xevious_tiles[$3000+adr_2c];
  // swap bit 6 & 7
  dat2:=BITSWAP8(dat2,6,7,5,4,3,2,1,0);
  // flip x & y
  if (dat1 and $400)<>0 then dat2:=dat2 xor $40;
  if (dat1 and $200)<>0 then dat2:=dat2 xor $80;
end;
xevious_bb_r:=dat2;
end;

begin
case direccion of
  0..$3fff,$7800..$87ff,$9000..$97ff,$a000..$a7ff,$b000..$cfff:xevious_getbyte:=memoria[direccion];
  $6800..$6807:xevious_getbyte:=xevious_dip(direccion and 7);
  $7000..$70ff:xevious_getbyte:=namco_06xx_data_r(direccion and $ff,0);
  $7100:xevious_getbyte:=namco_06xx_ctrl_r(0);
  $f000..$ffff:xevious_getbyte:=xevious_bb_r(direccion and 1);
end;
end;

procedure xevious_putbyte(direccion:word;valor:byte);
var
  scroll:word;
begin
case direccion of
    0..$3fff:; //ROM
    $6800..$681f:namco_snd_0.regs[direccion and $1f]:=valor;
    $6820..$6827:galaga_latch(direccion and 7,valor);
    $6830:;
    $7000..$70ff:namco_06xx_data_w(direccion and $ff,0,valor);
    $7100:namco_06xx_ctrl_w(0,valor);
    $7800..$87ff,$9000..$97ff,$a000..$a7ff:memoria[direccion]:=valor;
    $b000..$b7ff,$c000..$c7ff:if memoria[direccion]<>valor then begin
                                gfx[0].buffer[direccion and $7ff]:=true;
                                memoria[direccion]:=valor;
                              end;
    $b800..$bfff,$c800..$cfff:if memoria[direccion]<>valor then begin
                                gfx[1].buffer[direccion and $7ff]:=true;
                                memoria[direccion]:=valor;
                              end;
    $d000..$d07f:begin
                  scroll:=valor+((direccion and 1) shl 8);   // A0 -> D8
                  case ((direccion and $f0) shr 4) of
                    0:scrollx_bg:=scroll;
                    1:scrollx_fg:=scroll;
                    2:scrolly_bg:=scroll;
                    3:scrolly_fg:=scroll;
                    7:main_screen.flip_main_screen:=(scroll and 1)<>0;
                  end;
                 end;
    $f000..$ffff:xevious_bs[direccion and 1]:=valor;
end;
end;

//Sub1 CPU
function xevious_sub_getbyte(direccion:word):byte;
begin
case direccion of
  0..$3fff:xevious_sub_getbyte:=mem_snd[direccion];
  $4000..$ffff:xevious_sub_getbyte:=xevious_getbyte(direccion);
end;
end;

//Sub2 CPU
function xevious_sub2_getbyte(direccion:word):byte;
begin
case direccion of
  0..$3fff:xevious_sub2_getbyte:=mem_misc[direccion];
  $4000..$ffff:xevious_sub2_getbyte:=xevious_getbyte(direccion);
end;
end;

//Bosconian
procedure update_video_bosco;
procedure update_stars_bosco;
const
  speedsx:array[0..7] of integer=(-1, -2, -3, 0, 3, 2, 1, 0 );
  speedsy:array[0..7] of integer=( 0, -1, -2, -3, 0, 3, 2, 1 );
begin
	scrollx_bg:=scrollx_bg+(speedsx[galaga_starcontrol[0] and 7]);
  scrolly_bg:=scrolly_bg+(speedsy[(galaga_starcontrol[0] and $38) shr 3]);
end;

procedure draw_stars_bosco;
var
  x,y,star_cntr,set_a,set_b:byte;
  color:word;
begin
set_a:=galaga_starcontrol[1] and 1;
set_b:=(galaga_starcontrol[2] and 1) or 2;
for star_cntr:=0 to (MAX_STARS-1) do begin
  if ((set_a=star_seed_tab[star_cntr].set_) or (set_b=star_seed_tab[star_cntr].set_)) then begin
    y:=(star_seed_tab[star_cntr].y+scrolly_bg) and $ff;
    x:=(star_seed_tab[star_cntr].x+scrollx_bg) and $ff;
    color:=paleta[32+star_seed_tab[star_cntr].col];
    putpixel(x,y,1,@color,4);
  end;
end;
end;

var
  f,pos,x,y:word;
  color,nchar,atrib:byte;
  flipx,flipy:boolean;
begin
fill_full_screen(4,100);
draw_stars_bosco;
for f:=0 to $3ff do begin
    if gfx[0].buffer[f+$400] then begin
      y:=f div 32;
      x:=f mod 32;
      atrib:=memoria[$8c00+f];
      nchar:=memoria[$8400+f];
      color:=(atrib and $3f) shl 2;
      flipx:=(atrib and $40)=0;
      flipy:=(atrib and $80)<>0;
      put_gfx_mask_flip(x*8,y*8,nchar,color,1,0,$f,$f,flipx,flipy);
      gfx[0].buffer[f+$400]:=false;
    end;
end;
//radar
for x:=0 to 7 do begin
  for y:=0 to 31 do begin
	    pos:=x+(y shl 5);
      if gfx[0].buffer[pos] then begin
        atrib:=memoria[$8800+pos];
        nchar:=memoria[$8000+pos];
        color:=(atrib and $3f) shl 2;
        put_gfx_flip(x*8,y*8,nchar,color,2,0,(atrib and $40)=0,(atrib and $80)<>0);
        gfx[0].buffer[pos]:=false;
      end;
  end;
end;
scroll_x_y(4,3,scrollx_bg,scrolly_bg);
scroll_x_y(1,3,scrollx_bg,scrolly_bg);
//sprites
for f:=0 to 5 do begin
  x:=memoria[$83d5+(f*2)]-1;
  y:=240-memoria[$8bd4+(f*2)];
  flipx:=(memoria[$83d4+(f*2)] and 1)<>0;
	flipy:=(memoria[$83d4+(f*2)] and 2)<>0;
	color:=(memoria[$8bd5+(f*2)] and $3f) shl 2;
  nchar:=(memoria[$83d4+(f*2)] and $fc) shr 2;
  put_gfx_sprite_mask(nchar,color,flipx,flipy,1,$f,$f);
  actualiza_gfx_sprite(x,y,3,1);
end;
actualiza_trozo(32,0,32,256,2,221,0,32,256,3);
actualiza_trozo(0,0,32,256,2,253,0,32,256,3);
//dots
for f:=4 to $f do begin
		x:=memoria[$83f0+f]+((not(memoria[$9800+f]) and 1) shl 8)-2;
		y:=251-memoria[$8bf0+f];
    nchar:=((memoria[$9800+f] and $e) shr 1) xor 7;
    put_gfx_sprite(nchar,0,false,false,2);
    actualiza_gfx_sprite(x,y,3,2);
end;
actualiza_trozo_final(0,16,285,224,3);
update_stars_bosco;
end;

procedure bosco_principal;
var
  frame_m,frame_s1,frame_s2:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=z80_0.tframes;
frame_s1:=z80_2.tframes;
frame_s2:=z80_1.tframes;
while EmuStatus=EsRunning do begin
  for f:=0 to 263 do begin
    //Main CPU
    z80_0.run(frame_m);
    frame_m:=frame_m+z80_0.tframes-z80_0.contador;
    //Sub CPU
    z80_2.run(frame_s1);
    frame_s1:=frame_s1+z80_2.tframes-z80_2.contador;
    //Sub 2 CPU
    z80_1.run(frame_s2);
    frame_s2:=frame_s2+z80_1.tframes-z80_1.contador;
    run_namco_50xx(0);
    run_namco_50xx(1);
    run_namco_54xx;
    case f of
      63,191:if sub2_nmi then z80_1.change_nmi(PULSE_LINE);
      223:begin
            if main_irq then z80_0.change_irq(ASSERT_LINE);
            if sub_irq then z80_2.change_irq(ASSERT_LINE);
            update_video_bosco;
          end;
    end;
  end;
  eventos_galaga;
  video_sync;
end;
end;

function bosco_getbyte(direccion:word):byte;
begin
  case direccion of
      0..$3fff,$7800..$8fff:bosco_getbyte:=memoria[direccion];
      $6800..$6807:bosco_getbyte:=galaxian_dip(direccion and 7);
      $7000..$70ff:bosco_getbyte:=namco_06xx_data_r(direccion and $ff,0);
      $7100:bosco_getbyte:=namco_06xx_ctrl_r(0);
      $9000..$90ff:bosco_getbyte:=namco_06xx_data_r(direccion and $ff,1);
      $9100:bosco_getbyte:=namco_06xx_ctrl_r(1);
  end;
end;

procedure bosco_putbyte(direccion:word;valor:byte);
begin
case direccion of
    0..$3fff:; //ROM
    $6800..$681f:namco_snd_0.regs[direccion and $1f]:=valor;
    $6820..$6827:galaga_latch(direccion and 7,valor);
    $7000..$70ff:namco_06xx_data_w(direccion and $ff,0,valor);
    $7100:namco_06xx_ctrl_w(0,valor);
    $8000..$8fff:if memoria[direccion]<>valor then begin
                  gfx[0].buffer[direccion and $7ff]:=true;
                  memoria[direccion]:=valor;
               end;
    $7800..$7fff,$9800..$980f:memoria[direccion]:=valor;
    $9000..$90ff:namco_06xx_data_w(direccion and $ff,1,valor);
    $9100:namco_06xx_ctrl_w(1,valor);
    $9810:scrollx_bg:=valor;
    $9820:scrolly_bg:=valor;
    $9830:galaga_starcontrol[0]:=valor;
    $9870:main_screen.flip_main_screen:=(valor and 1)=0;
    $9874:galaga_starcontrol[1]:=valor;
    $9875:galaga_starcontrol[2]:=valor;
end;
end;

function bosco_sub_getbyte(direccion:word):byte;
begin
case direccion of
  0..$3fff:bosco_sub_getbyte:=mem_snd[direccion];
  $4000..$ffff:bosco_sub_getbyte:=bosco_getbyte(direccion);
end;
end;

function bosco_sub2_getbyte(direccion:word):byte;
begin
case direccion of
  0..$3fff:bosco_sub2_getbyte:=mem_misc[direccion];
  $4000..$ffff:bosco_sub2_getbyte:=bosco_getbyte(direccion);
end;
end;

//Namco IO
procedure namco_06xx_nmi;
begin
  z80_0.change_nmi(PULSE_LINE);
end;

procedure namco_06xx_sub_nmi;
begin
  z80_2.change_nmi(PULSE_LINE);
end;

//Main
procedure reset_galagahw;
var
  f:byte;
begin
 z80_0.reset;
 z80_2.reset;
 z80_1.reset;
 namco_snd_0.reset;
 reset_audio;
 namcoio_06xx_reset(0);
 case main_vars.tipo_maquina of
    65:begin
          namcoio_51xx_reset(false);
          namcoio_54xx_reset;
          reset_samples;
          fillchar(galaga_starcontrol,6,0);
          scrollx_bg:=0;
          scrolly_bg:=0;
       end;
   167:begin
          namcoio_51xx_reset(false);
          namcoio_53xx_reset;
          custom_mod:=0;
          bg_select:=0;
          bg_color_bank:=0;
          bg_disable:=false;
          tx_color_mode:=0;
          bg_repaint:=true;
       end;
   231,350:begin
          namcoio_50xx_reset(0);
          namcoio_51xx_reset(true);
          namcoio_54xx_reset;
          scrollx_bg:=0;
          scrolly_bg:=0;
          scrollx_fg:=0;
          scrolly_fg:=0;
          xevious_bs[0]:=0;
          xevious_bs[1]:=0;
       end;
   250:begin
          namcoio_50xx_reset(0);
          namcoio_50xx_reset(1);
          namcoio_51xx_reset(false);
          namcoio_54xx_reset;
          reset_samples;
          fillchar(galaga_starcontrol,6,0);
          scrollx_bg:=0;
          scrolly_bg:=0;
          namcoio_06xx_reset(1);
       end;
 end;
 main_irq:=false;
 sub_irq:=false;
 sub2_nmi:=false;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$11;
 for f:=0 to 7 do galaga_latch(f,0);
end;

procedure cerrar_galagahw;
begin
case main_vars.tipo_maquina of
  65:namco_54xx_close;
  167:namco_53xx_close;
  231,350:begin
        namco_50xx_close(0);
        namco_54xx_close;
      end;
  250:begin
        namco_50xx_close(0);
        namco_50xx_close(1);
        namco_54xx_close;
      end;
end;
end;

function iniciar_galagahw:boolean;
var
  colores:tpaleta;
  f:word;
  ctemp0,ctemp1,ctemp2,ctemp3:byte;
  memoria_temp:array[0..$9fff] of byte;
const
  map:array[0..3] of byte=(0,$47,$97,$de);
  ps_x:array[0..15] of dword=(0, 1, 2, 3, 8*8, 8*8+1, 8*8+2, 8*8+3, 16*8+0, 16*8+1, 16*8+2, 16*8+3,
			24*8+0, 24*8+1, 24*8+2, 24*8+3);
  ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			32*8, 33*8, 34*8, 35*8, 36*8, 37*8, 38*8, 39*8);
  ps_x_bosco:array[0..15] of dword=(8*8, 8*8+1, 8*8+2, 8*8+3, 16*8+0, 16*8+1, 16*8+2, 16*8+3,
			24*8+0, 24*8+1, 24*8+2, 24*8+3, 0, 1, 2, 3);
  pc_x_digdug:array[0..7] of dword=(7, 6, 5, 4, 3, 2, 1, 0);
  pc_x_xevious:array[0..7] of dword=(0,1,2,3,4,5,6,7);
  pc_x_galaga:array[0..7] of dword=(8*8+0, 8*8+1, 8*8+2, 8*8+3,  0, 1, 2, 3);
  pc_x_dot:array[0..3] of dword=(3*8, 2*8, 1*8, 0*8);
  pc_y_dot:array[0..3] of dword=(3*32, 2*32, 1*32, 0*32);

procedure galaga_chr(ngfx:byte;num:word);
begin
init_gfx(ngfx,8,8,num);
gfx_set_desc_data(2,0,16*8,0,4);
convert_gfx(ngfx,0,@memoria_temp,@pc_x_galaga,@ps_y,true,false);
end;

procedure galaga_spr(num:word);
begin
init_gfx(1,16,16,num);
gfx_set_desc_data(2,0,64*8,0,4);
convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,true,false);
end;

begin
iniciar_galagahw:=false;
iniciar_audio(false);
llamadas_maquina.close:=cerrar_galagahw;
llamadas_maquina.reset:=reset_galagahw;
llamadas_maquina.fps_max:=60.6060606060;
case main_vars.tipo_maquina of
  65,167:begin
          screen_init(1,224,288,true);
          screen_init(2,256,512,false,true);
          screen_init(3,224,288);
          if main_vars.tipo_maquina=65 then llamadas_maquina.bucle_general:=galaga_principal
            else llamadas_maquina.bucle_general:=digdug_principal;
        end;
  231,350:begin
            screen_init(1,256,512,true);
            screen_mod_scroll(1,256,256,255,512,512,511);
            screen_init(2,256,512,true);
            screen_mod_scroll(2,256,256,255,512,512,511);
            screen_init(3,256,512,false,true);
            llamadas_maquina.bucle_general:=xevious_principal;
          end;
  250:begin
            screen_init(1,256,256,true);
            screen_mod_scroll(1,256,256,255,256,256,255);
            screen_init(2,64,256,true);
            screen_init(3,512,512,false,true);
            screen_init(4,256,256);
            screen_mod_scroll(4,256,256,255,256,256,255);
            llamadas_maquina.bucle_general:=bosco_principal;
          end;
end;
if main_vars.tipo_maquina<>250 then iniciar_video(224,288)
  else iniciar_video(285,224);
//Main CPU
z80_0:=cpu_z80.create(3072000,264);
//Sub CPU
z80_2:=cpu_z80.create(3072000,264);
//Sub2 CPU
z80_1:=cpu_z80.create(3072000,264);
//IO's
namcoio_51xx_init(@marcade.in0,@marcade.in1);
case main_vars.tipo_maquina of
    65:begin  //Galaga
          //Main
          z80_0.change_ram_calls(galaga_getbyte,galaga_putbyte);
          z80_0.init_sound(galaga_sound_update);
          //Sub1
          z80_2.change_ram_calls(galaga_sub_getbyte,galaga_putbyte);
          //Sub2
          z80_1.change_ram_calls(galaga_sub2_getbyte,galaga_putbyte);
          //Sound
          namco_snd_0:=namco_snd_chip.create(3);
          //Init IO's
          namco_06xx_init(0,IO51XX,NONE,NONE,IO54XX,namco_06xx_nmi);
          //Namco 54xx
          if not(namcoio_54xx_init('galaga.zip')) then exit;
          load_samples(galaga_samples);
          //cargar roms
          if not(roms_load(@memoria,galaga_rom)) then exit;
          if not(roms_load(@mem_snd,galaga_sub)) then exit;
          if not(roms_load(@mem_misc,galaga_sub2)) then exit;
          //cargar sonido & iniciar_sonido
          if not(roms_load(namco_snd_0.get_wave_dir,galaga_sound)) then exit;
          //convertir chars
          if not(roms_load(@memoria_temp,galaga_char)) then exit;
          galaga_chr(0,$100);
          //convertir sprites
          if not(roms_load(@memoria_temp,galaga_sprites)) then exit;
          galaga_spr($80);
          //poner la paleta
          if not(roms_load(@memoria_temp,galaga_prom)) then exit;
          for f:=0 to $1f do begin
              ctemp1:=memoria_temp[f];
              colores[f].r:=$21*(ctemp1 and 1)+$47*((ctemp1 shr 1) and 1)+$97*((ctemp1 shr 2) and 1);
              colores[f].g:=$21*((ctemp1 shr 3) and 1)+$47*((ctemp1 shr 4) and 1)+$97*((ctemp1 shr 5) and 1);
              colores[f].b:=0+$47*((ctemp1 shr 6) and 1)+$97*((ctemp1 shr 7) and 1);
          end;
          //paleta de las estrellas
          for f:=0 to $3f do begin
          		ctemp1:=(f shr 0) and 3;
          		colores[$20+f].r:=map[ctemp1];
          		ctemp1:=(f shr 2) and 3;
          		colores[$20+f].g:=map[ctemp1];
          		ctemp1:=(f shr 4) and 3;
          		colores[$20+f].b:=map[ctemp1];
          end;
          set_pal(colores,32+64);
          //CLUT
          for f:=0 to $ff do begin
            gfx[0].colores[f]:=memoria_temp[$20+f]+$10;
            gfx[1].colores[f]:=memoria_temp[$120+f];
          end;
          //Dip
          marcade.dswa:=$f7;
          marcade.dswa_val2:=@galaga_dip_a;
          marcade.dswb:=$97;
          marcade.dswb_val2:=@galaga_dip_b;
       end;
    167:begin //DigDug
          //Main
          z80_0.change_ram_calls(digdug_getbyte,digdug_putbyte);
          z80_0.init_sound(digdug_sound_update);
          //Sub1
          z80_2.change_ram_calls(digdug_sub_getbyte,digdug_putbyte);
          //Sub2
          z80_1.change_ram_calls(digdug_sub2_getbyte,digdug_putbyte);
          //Sound
          namco_snd_0:=namco_snd_chip.create(3);
          //Init IO's
          namco_06xx_init(0,IO51XX,IO53XX,NONE,NONE,namco_06xx_nmi);
          //Namco 53XX
          if not(namcoio_53xx_init(namco_53xx_k_r,namco_53xx_r_r,'digdug.zip')) then exit;
          //cargar roms
          if not(roms_load(@memoria,digdug_rom)) then exit;
          if not(roms_load(@mem_snd,digdug_sub)) then exit;
          if not(roms_load(@mem_misc,digdug_sub2)) then exit;
          //cargar sonido & iniciar_sonido
          if not(roms_load(namco_snd_0.get_wave_dir,digdug_sound)) then exit;
          //convertir chars
          if not(roms_load(@memoria_temp,digdug_chars)) then exit;
          init_gfx(0,8,8,$200);
          gfx[0].trans[0]:=true;
          gfx_set_desc_data(1,0,8*8,0);
          convert_gfx(0,0,@memoria_temp,@pc_x_digdug,@ps_y,true,false);
          //sprites
          if not(roms_load(@memoria_temp,digdug_sprites)) then exit;
          galaga_spr($100);
          //Background
          if not(roms_load(@digdug_bg,digdug_background)) then exit;
          if not(roms_load(@memoria_temp,digdug_chars2)) then exit;
          galaga_chr(2,$100);
          //poner la paleta
          if not(roms_load(@memoria_temp,digdug_prom)) then exit;
          for f:=0 to $1f do begin
              ctemp1:=memoria_temp[f];
              colores[f].r:=$21*(ctemp1 and 1)+$47*((ctemp1 shr 1) and 1)+$97*((ctemp1 shr 2) and 1);
              colores[f].g:=$21*((ctemp1 shr 3) and 1)+$47*((ctemp1 shr 4) and 1)+$97*((ctemp1 shr 5) and 1);
              colores[f].b:=0+$47*((ctemp1 shr 6) and 1)+$97*((ctemp1 shr 7) and 1);
          end;
          set_pal(colores,32);
          //CLUT
          for f:=0 to 15 do begin //chars
        		gfx[0].colores[f*2+0]:=0;
		        gfx[0].colores[f*2+1]:=f;
          end;
          for f:=0 to $ff do begin
            gfx[1].colores[f]:=memoria_temp[$20+f]+$10; //sprites
            gfx[2].colores[f]:=memoria_temp[$120+f];    //background
          end;
          //Dip
          marcade.dswa:=$99;
          marcade.dswa_val2:=@digdug_dip_a;
          marcade.dswb:=$24;
          marcade.dswb_val2:=@digdug_dip_b;
        end;
    231,350:begin  //Xevious
          //Main
          z80_0.change_ram_calls(xevious_getbyte,xevious_putbyte);
          //Sub1
          z80_2.change_ram_calls(xevious_sub_getbyte,xevious_putbyte);
          //Sub2
          z80_1.change_ram_calls(xevious_sub2_getbyte,xevious_putbyte);
          //Init IO's
          namco_06xx_init(0,IO51XX,NONE,IO50XX_0,IO54XX,namco_06xx_nmi);
          //Namco 54xx
          if not(namcoio_50xx_init(0,'xevious.zip')) then exit;
          if not(namcoio_54xx_init('xevious.zip')) then exit;
          z80_0.init_sound(galaga_sound_update);
          load_samples(xevious_samples,1,true,'xevious.zip');
          //Sound
          namco_snd_0:=namco_snd_chip.create(3);
          //cargar roms
          if not(roms_load(@mem_misc,xevious_sub2,true,true,'xevious.zip')) then exit;
          if main_vars.tipo_maquina=231 then begin
            if not(roms_load(@memoria,xevious_rom)) then exit;
            if not(roms_load(@mem_snd,xevious_sub)) then exit;
          end else begin
            if not(roms_load(@memoria,sxevious_rom)) then exit;
            if not(roms_load(@mem_snd,sxevious_sub)) then exit;
          end;
          //cargar sonido & iniciar_sonido
          if not(roms_load(namco_snd_0.get_wave_dir,xevious_sound,true,true,'xevious.zip')) then exit;
          //chars
          if not(roms_load(@memoria_temp,xevious_char,true,true,'xevious.zip')) then exit;
          init_gfx(0,8,8,$200);
          gfx[0].trans[0]:=true;
          gfx_set_desc_data(1,0,8*8,0);
          convert_gfx(0,0,@memoria_temp,@pc_x_xevious,@ps_y,true,false);
          //convertir sprites
          fillchar(memoria_temp,$a000,0);
          if not(roms_load(@memoria_temp,xevious_sprites,true,true,'xevious.zip')) then exit;
          for f:=$5000 to $6fff do memoria_temp[f+$2000]:=memoria_temp[f] shr 4;
          init_gfx(2,16,16,$140);
          gfx_set_desc_data(3,0,64*8,($140*64*8)+4,0,4);
          convert_gfx(2,0,@memoria_temp,@ps_x,@ps_y,true,false);
          //tiles
          if not(roms_load(@xevious_tiles,xevious_bg_tiles,true,true,'xevious.zip')) then exit;
          if not(roms_load(@memoria_temp,xevious_bg,true,true,'xevious.zip')) then exit;
          init_gfx(1,8,8,$200);
          gfx_set_desc_data(2,0,8*8,0,$200*8*8);
          convert_gfx(1,0,@memoria_temp,@pc_x_xevious,@ps_y,true,false);
          //poner la paleta
          if not(roms_load(@memoria_temp,xevious_prom,true,true,'xevious.zip')) then exit;
          for f:=0 to $ff do begin
              ctemp0:=(memoria_temp[f] shr 0) and 1;
              ctemp1:=(memoria_temp[f] shr 1) and 1;
              ctemp2:=(memoria_temp[f] shr 2) and 1;
              ctemp3:=(memoria_temp[f] shr 3) and 1;
              colores[f].r:=$e*ctemp0+$1f*ctemp1+$43*ctemp2+$8f*ctemp3;
              ctemp0:=(memoria_temp[f+256] shr 0) and 1;
              ctemp1:=(memoria_temp[f+256] shr 1) and 1;
              ctemp2:=(memoria_temp[f+256] shr 2) and 1;
              ctemp3:=(memoria_temp[f+256] shr 3) and 1;
              colores[f].g:=$e*ctemp0+$1f*ctemp1+$43*ctemp2+$8f*ctemp3;
              ctemp0:=(memoria_temp[f+512] shr 0) and 1;
              ctemp1:=(memoria_temp[f+512] shr 1) and 1;
              ctemp2:=(memoria_temp[f+512] shr 2) and 1;
              ctemp3:=(memoria_temp[f+512] shr 3) and 1;
              colores[f].b:=$e*ctemp0+$1f*ctemp1+$43*ctemp2+$8f*ctemp3;
          end;
          set_pal(colores,256);
          //CLUT
          for f:=0 to $ff do if (f mod 2)<>0 then gfx[0].colores[f]:=f shr 1
            else gfx[0].colores[f]:=$80;
          for f:=0 to $1ff do begin
            gfx[1].colores[f]:=(memoria_temp[$300+f] and $f) or ((memoria_temp[$500+f] and $f) shl 4);
            ctemp0:=(memoria_temp[$700+f] and $f) or ((memoria_temp[$900+f] and $f) shl 4);
            if (ctemp0 and $80)<>0 then gfx[2].colores[f]:=ctemp0 and $7f
              else gfx[2].colores[f]:=$80;
          end;
          //Dip
          marcade.dswa:=$ff;
          if main_vars.tipo_maquina=231 then begin
            marcade.dswa_val2:=@xevious_dip_a;
            marcade.dswb:=$ee;
            marcade.dswb_val2:=@xevious_dip_b;
          end else begin
            //Dip
            marcade.dswa_val2:=@xevious_dip_a;
            marcade.dswb:=$62;
            marcade.dswb_val2:=@xevious_dip_b;
          end;
       end;
    250:begin  //Bosconian
          //Main
          z80_0.change_ram_calls(bosco_getbyte,bosco_putbyte);
          //Sub1
          z80_2.change_ram_calls(bosco_sub_getbyte,bosco_putbyte);
          //Sub2
          z80_1.change_ram_calls(bosco_sub2_getbyte,bosco_putbyte);
          //Init IO's
          namco_06xx_init(0,IO51XX,NONE,IO50XX_0,IO54XX,namco_06xx_nmi);
          namco_06xx_init(1,IO50XX_1,NONE{IO52XX},NONE,NONE,namco_06xx_sub_nmi);
          //Namco 54xx
          if not(namcoio_50xx_init(0,'bosco.zip')) then exit;
          if not(namcoio_50xx_init(1,'bosco.zip')) then exit;
          if not(namcoio_54xx_init('bosco.zip')) then exit;
          z80_0.init_sound(galaga_sound_update);
          load_samples(bosco_samples,0.25);
          //Sound
          namco_snd_0:=namco_snd_chip.create(3);
          //cargar roms
          if not(roms_load(@memoria,bosco_rom)) then exit;
          if not(roms_load(@mem_snd,bosco_sub)) then exit;
          if not(roms_load(@mem_misc,bosco_sub2)) then exit;
          //cargar sonido & iniciar_sonido
          if not(roms_load(namco_snd_0.get_wave_dir,bosco_snd)) then exit;
          //chars
          if not(roms_load(@memoria_temp,bosco_char)) then exit;
          init_gfx(0,8,8,$100);
          gfx_set_desc_data(2,0,16*8,0,4);
          convert_gfx(0,0,@memoria_temp,@pc_x_galaga,@ps_y,false,false);
          //convertir sprites
          if not(roms_load(@memoria_temp,bosco_sprites)) then exit;
          init_gfx(1,16,16,$40);
          gfx_set_desc_data(2,0,64*8,0,4);
          convert_gfx(1,0,@memoria_temp,@ps_x_bosco,@ps_y,false,false);
          //convertir disparos
          if not(roms_load(@memoria_temp,bosco_dots)) then exit;
          init_gfx(2,4,4,8);
          gfx[2].trans[3]:=true;
          gfx_set_desc_data(2,0,16*8,6,7);
          convert_gfx(2,0,@memoria_temp,@pc_x_dot,@pc_y_dot,false,false);
          //poner la paleta
          if not(roms_load(@memoria_temp,bosco_prom)) then exit;
          for f:=0 to $1f do begin
              ctemp0:=(memoria_temp[f] shr 0) and 1;
              ctemp1:=(memoria_temp[f] shr 1) and 1;
              ctemp2:=(memoria_temp[f] shr 2) and 1;
              colores[f].r:=$21*ctemp0+$47*ctemp1+$97*ctemp2;
              ctemp0:=(memoria_temp[f] shr 3) and 1;
              ctemp1:=(memoria_temp[f] shr 4) and 1;
              ctemp2:=(memoria_temp[f] shr 5) and 1;
              colores[f].g:=$21*ctemp0+$47*ctemp1+$97*ctemp2;
              ctemp1:=(memoria_temp[f] shr 6) and 1;
              ctemp2:=(memoria_temp[f] shr 7) and 1;
              colores[f].b:=0+$47*ctemp1+$97*ctemp2;
          end;
          for f:=0 to 63 do begin
		        ctemp0:=(f shr 0) and 3;
		        colores[f+32].r:=map[ctemp0];
		        ctemp0:=(f shr 2) and 3;
		        colores[f+32].g:=map[ctemp0];
		        ctemp0:=(f shr 4) and 3;
		        colores[f+32].b:=map[ctemp0];
          end;
          set_pal(colores,32+64);
          //CLUT
          for f:=0 to $ff do begin
            gfx[0].colores[f]:=(memoria_temp[f+$20] and $f)+$10;
            gfx[1].colores[f]:=memoria_temp[f+$20] and $f;
          end;
          for f:=0 to 3 do gfx[2].colores[f]:=31-f;
          //Dip
          marcade.dswa:=$f7;
          marcade.dswa_val2:=@bosco_dip_a;
          marcade.dswb:=$a7;
          marcade.dswb_val2:=@bosco_dip_b;
       end;
end;
//final
reset_galagahw;
iniciar_galagahw:=true;
end;

end.
