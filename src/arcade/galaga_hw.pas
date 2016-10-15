unit galaga_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,namco_snd,controls_engine,gfx_engine,namcoio_06xx_5xxx,
     rom_engine,pal_engine,sound_engine,galaga_stars_const,samples,misc_functions;

procedure cargar_Galagahw;

implementation
const
        //Galaga
        galaga_rom:array[0..4] of tipo_roms=(
        (n:'gg1_1b.3p';l:$1000;p:0;crc:$ab036c9f),(n:'gg1_2b.3m';l:$1000;p:$1000;crc:$d9232240),
        (n:'gg1_3.2m';l:$1000;p:$2000;crc:$753ce503),(n:'gg1_4b.2l';l:$1000;p:$3000;crc:$499fcc76),());
        galaga_sub:tipo_roms=(n:'gg1_5b.3f';l:$1000;p:0;crc:$bb5caae3);
        galaga_sub2:tipo_roms=(n:'gg1_7b.2c';l:$1000;p:0;crc:$d016686b);
        galaga_prom:array[0..3] of tipo_roms=(
        (n:'prom-5.5n';l:$20;p:0;crc:$54603c6b),(n:'prom-4.2n';l:$100;p:$20;crc:$59b6edab),
        (n:'prom-3.1c';l:$100;p:$120;crc:$4a04bb6b),());
        galaga_char:tipo_roms=(n:'gg1_9.4l';l:$1000;p:0;crc:$58b2f47c);
        galaga_sound:tipo_roms=(n:'prom-1.1d';l:$100;p:0;crc:$7a2815b4);
        galaga_sprites:array[0..2] of tipo_roms=(
        (n:'gg1_11.4d';l:$1000;p:0;crc:$ad447c80),(n:'gg1_10.4f';l:$1000;p:$1000;crc:$dd6f1afc),());
        num_samples_galaga=2;
        galaga_samples:array[0..(num_samples_galaga-1)] of tipo_nombre_samples=(
        (nombre:'bang.wav'),(nombre:'init.wav'));
        //Dig Dug
        digdug_rom:array[0..4] of tipo_roms=(
        (n:'dd1a.1';l:$1000;p:0;crc:$a80ec984),(n:'dd1a.2';l:$1000;p:$1000;crc:$559f00bd),
        (n:'dd1a.3';l:$1000;p:$2000;crc:$8cbc6fe1),(n:'dd1a.4';l:$1000;p:$3000;crc:$d066f830),());
        digdug_sub:array[0..2] of tipo_roms=(
        (n:'dd1a.5';l:$1000;p:0;crc:$6687933b),(n:'dd1a.6';l:$1000;p:$1000;crc:$843d857f),());
        digdug_sub2:tipo_roms=(n:'dd1.7';l:$1000;p:0;crc:$a41bce72);
        digdug_prom:array[0..3] of tipo_roms=(
        (n:'136007.113';l:$20;p:0;crc:$4cb9da99),(n:'136007.111';l:$100;p:$20;crc:$00c7c419),
        (n:'136007.112';l:$100;p:$120;crc:$e9b3e08e),());
        digdug_sound:tipo_roms=(n:'136007.110';l:$100;p:0;crc:$7a2815b4);
        digdug_chars:tipo_roms=(n:'dd1.9';l:$800;p:0;crc:$f14a6fe1);
        digdug_sprites:array[0..4] of tipo_roms=(
        (n:'dd1.15';l:$1000;p:0;crc:$e22957c8),(n:'dd1.14';l:$1000;p:$1000;crc:$2829ec99),
        (n:'dd1.13';l:$1000;p:$2000;crc:$458499e9),(n:'dd1.12';l:$1000;p:$3000;crc:$c58252a0),());
        digdug_chars2:tipo_roms=(n:'dd1.11';l:$1000;p:0;crc:$7b383983);
        digdug_background:tipo_roms=(n:'dd1.10b';l:$1000;p:0;crc:$2cf399c2);
        //Xevious
        xevious_rom:array[0..4] of tipo_roms=(
        (n:'xvi_1.3p';l:$1000;p:0;crc:$09964dda),(n:'xvi_2.3m';l:$1000;p:$1000;crc:$60ecce84),
        (n:'xvi_3.2m';l:$1000;p:$2000;crc:$79754b7d),(n:'xvi_4.2l';l:$1000;p:$3000;crc:$c7d4bbf0),());
        xevious_sub:array[0..2] of tipo_roms=(
        (n:'xvi_5.3f';l:$1000;p:$0;crc:$c85b703f),(n:'xvi_6.3j';l:$1000;p:$1000;crc:$e18cdaad),());
        xevious_sub2:tipo_roms=(n:'xvi_7.2c';l:$1000;p:0;crc:$dd35cf1c);
        xevious_prom:array[0..7] of tipo_roms=(
        (n:'xvi-8.6a';l:$100;p:0;crc:$5cc2727f),(n:'xvi-9.6d';l:$100;p:$100;crc:$5c8796cc),
        (n:'xvi-10.6e';l:$100;p:$200;crc:$3cb60975),(n:'xvi-7.4h';l:$200;p:$300;crc:$22d98032),
        (n:'xvi-6.4f';l:$200;p:$500;crc:$3a7599f0),(n:'xvi-4.3l';l:$200;p:$700;crc:$fd8b9d91),
        (n:'xvi-5.3m';l:$200;p:$900;crc:$bf906d82),());
        xevious_sound:tipo_roms=(n:'xvi-2.7n';l:$100;p:0;crc:$550f06bc);
        xevious_char:tipo_roms=(n:'xvi_12.3b';l:$1000;p:0;crc:$088c8b26);
        xevious_sprites:array[0..4] of tipo_roms=(
        (n:'xvi_15.4m';l:$2000;p:0;crc:$dc2c0ecb),(n:'xvi_17.4p';l:$2000;p:$2000;crc:$dfb587ce),
        (n:'xvi_16.4n';l:$1000;p:$4000;crc:$605ca889),(n:'xvi_18.4r';l:$2000;p:$5000;crc:$02417d19),());
        xevious_bg:array[0..2] of tipo_roms=(
        (n:'xvi_13.3c';l:$1000;p:$0;crc:$de60ba25),(n:'xvi_14.3d';l:$1000;p:$1000;crc:$535cdbbc),());
        xevious_bg_tiles:array[0..3] of tipo_roms=(
        (n:'xvi_9.2a';l:$1000;p:0;crc:$57ed9879),(n:'xvi_10.2b';l:$2000;p:$1000;crc:$ae3ba9e5),
        (n:'xvi_11.2c';l:$1000;p:$3000;crc:$31e244dd),());
        num_samples_xevious=2;
        xevious_samples:array[0..(num_samples_xevious-1)] of tipo_nombre_samples=(
        (nombre:'explo1.wav'),(nombre:'explo2.wav'));

var
 main_irq,sub_irq,sub2_nmi:boolean;
 scrollx_bg,scrolly_bg:word;
 //Galaga
 galaga_starcontrol:array[0..5] of byte;
 //Dig Dug
 digdug_bg:array[0..$fff] of byte;
 custom_mod,bg_select,bg_color_bank,bg_disable,tx_color_mode:byte;
 bg_repaint:boolean;
 //Xevious
 xevious_tiles:array[0..$3fff] of byte;
 xevious_bs:array[0..1] of byte;
 scrollx_fg,scrolly_fg:word;

procedure draw_sprites_galaga;
var
  nchar,f,atrib,a,b,c,d,flipx_v,flipy_v:byte;
  color,x,y:word;
  flipx,flipy:boolean;
begin
for f:=0 to $3f do begin
		nchar:=memoria[$8b80+(f*2)] and $7f;
		color:=(memoria[$8b81+(f*2)] and $3f) shl 2;
		y:=memoria[$9381+(f*2)]-40+$100*(memoria[$9b81+(f*2)] and 3);
    x:=memoria[$9380+(f*2)]-16-1;	// sprites are buffered and delayed by one scanline
    atrib:=memoria[$9b80+(f*2)];
    flipx:=(atrib and $02)<>0;
    flipy:=(atrib and $01)<>0;
    flipx_v:=atrib and $02;
    flipy_v:=atrib and $01;
		case (atrib and $0c) of
        0:begin  //16x16
            put_gfx_sprite_mask(nchar,color,flipx,flipy,1,$f,$f);
            actualiza_gfx_sprite(x,y,2,1);
          end;
        4:begin  //16x32
            a:=0 xor flipy_v;
            b:=1 xor flipy_v;
            put_gfx_sprite_mask_diff(nchar+a,color,flipx,flipy,1,$f,$f,0,16);
            put_gfx_sprite_mask_diff(nchar+b,color,flipx,flipy,1,$f,$f,0,0);
            actualiza_gfx_sprite_size(x,y,2,16,32);
          end;
        8:begin  //32x16
            a:=0 xor flipx_v;
            b:=2 xor flipx_v;
            put_gfx_sprite_mask_diff(nchar+a,color,flipx,flipy,1,$f,$f,16,0);
            put_gfx_sprite_mask_diff(nchar+b,color,flipx,flipy,1,$f,$f,0,0);
            actualiza_gfx_sprite_size(x,y,2,32,16);
          end;
       $c:begin  //32x32
            a:=0 xor flipy_v xor flipx_v;
            b:=1 xor flipy_v xor flipx_v;
            c:=2 xor flipy_v xor flipx_v;
            d:=3 xor flipy_v xor flipx_v;
            put_gfx_sprite_mask_diff(nchar+a,color,flipx,flipy,1,$f,$f,16,0);
            put_gfx_sprite_mask_diff(nchar+b,color,flipx,flipy,1,$f,$f,16,16);
            put_gfx_sprite_mask_diff(nchar+c,color,flipx,flipy,1,$f,$f,0,0);
            put_gfx_sprite_mask_diff(nchar+d,color,flipx,flipy,1,$f,$f,0,16);
            actualiza_gfx_sprite_size(x,y,2,32,32);
          end;
    end;
end;
end;

procedure update_stars;inline;
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

procedure draw_stars;inline;
const
  MAX_STARS=252;
var
  star_cntr,set_a,set_b:byte;
  x,y,color:word;
begin
if (galaga_starcontrol[5] and 1)=1 then begin
		// two sets of stars controlled by these bits */
		set_a:=galaga_starcontrol[3] and 1;
		set_b:=(galaga_starcontrol[4] and 1) or $2;
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

procedure update_video_galaga;inline;
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
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $Fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.but1[0] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
end;
end;

procedure galaga_sound_update;
begin
  samples_update;
end;

procedure galaga_principal;
var
  frame_m,frame_s1,frame_s2:single;
  f,scanline:word;
begin
init_controls(false,false,false,true);
frame_m:=main_z80.tframes;
frame_s1:=snd_z80.tframes;
frame_s2:=sub_z80.tframes;
scanline:=63;
while EmuStatus=EsRuning do begin
  for f:=0 to 263 do begin
    //Main CPU
    main_z80.run(frame_m);
    frame_m:=frame_m+main_z80.tframes-main_z80.contador;
    //Sub CPU
    snd_z80.run(frame_s1);
    frame_s1:=frame_s1+snd_z80.tframes-snd_z80.contador;
    //Sub 2 CPU
    sub_z80.run(frame_s2);
    frame_s2:=frame_s2+sub_z80.tframes-sub_z80.contador;
    run_namco_54xx;
    if (f=scanline) then begin
        if sub2_nmi then sub_z80.change_nmi(PULSE_LINE);
        scanline:=scanline+128;
	      if (scanline>=272) then scanline:=63;
    end;
    if f=223 then begin
        if main_irq then main_z80.change_irq(ASSERT_LINE);
        if sub_irq then snd_z80.change_irq(ASSERT_LINE);
        update_video_galaga;
        copymemory(@buffer_sprites[0],@memoria[$fe00],$200);
    end;
  end;
  if sound_status.hay_sonido then namco_playsound;
  eventos_galaga;
  video_sync;
end;
end;

procedure galaga_latch(dir,val:byte);inline;
var
  bit:byte;
begin
bit:=val and 1;
case dir of
		$0:begin	// IRQ1 */
        main_irq:=bit<>0;
			  if not(main_irq) then main_z80.change_irq(CLEAR_LINE);
			 end;
		$1:begin	// IRQ2 */
			    sub_irq:=bit<>0;
  			  if not(sub_irq) then snd_z80.change_irq(CLEAR_LINE);
			 end;
		$2:sub2_nmi:=(bit=0);	// NMION */
		$3:if (bit<>0) then begin  // RESET */
          snd_z80.change_reset(CLEAR_LINE);
          sub_z80.change_reset(CLEAR_LINE);
       end else begin
          snd_z80.change_reset(ASSERT_LINE);
          sub_z80.change_reset(ASSERT_LINE);
       end;
		$4:; //n.c.
    $05:custom_mod:=(custom_mod and $fe) or (bit shl 0);	// MOD 0
		$06:custom_mod:=(custom_mod and $fd) or (bit shl 1);	// MOD 1
    $07:custom_mod:=(custom_mod and $fb) or (bit shl 2);	// MOD 2
end;
end;

procedure galaga_putbyte(direccion:word;valor:byte);
begin
if (direccion<$4000) then exit;
case direccion of
    $6800..$681f:namco_sound.registros_namco[direccion and $1f]:=valor;
    $6820..$6827:galaga_latch(direccion and $7,valor);
    $7000..$70ff:namco_06xx_data_w(direccion and $ff,0,valor);
    $7100..$7100:namco_06xx_ctrl_w(0,valor);
    $8000..$87ff:begin
                    gfx[0].buffer[direccion and $3ff]:=true;
                    memoria[direccion]:=valor;
                 end;
    $8800..$8bff,$9000..$93ff,$9800..$9bff:memoria[direccion]:=valor;
    $a000..$a005:galaga_starcontrol[direccion and $7]:=valor;
    $a007:main_screen.flip_main_screen:=(valor and 1)<>0;
end;
end;

function galaga_getbyte(direccion:word):byte;
begin
case direccion of
  0..$3fff,$8000..$8bff,$9000..$93ff,$9800..$9bff:galaga_getbyte:=memoria[direccion];
  $6800..$6802,$6804,$6807:galaga_getbyte:=$3; //Leer DSW A y B
  $6803:galaga_getbyte:=$0;
  $6805,$6806:galaga_getbyte:=$2;
  $7000..$70ff:galaga_getbyte:=namco_06xx_data_r(direccion and $ff,0);
  $7100..$7100:galaga_getbyte:=namco_06xx_ctrl_r(0);
end;
end;

function galaga_sub_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$3fff:galaga_sub_getbyte:=mem_snd[direccion];
  $6800..$6802,$6804,$6807:galaga_sub_getbyte:=$3; //Leer DSW A y B
  $6803:galaga_sub_getbyte:=$0;
  $6805,$6806:galaga_sub_getbyte:=$2;
  $7000..$70ff:galaga_sub_getbyte:=namco_06xx_data_r(direccion and $ff,0);
  $7100..$7100:galaga_sub_getbyte:=namco_06xx_ctrl_r(0);
  $8800..$8bff,$9000..$93ff,$9800..$9bff:galaga_sub_getbyte:=memoria[direccion];
end;
end;

function galaga_sub2_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$3fff:galaga_sub2_getbyte:=mem_misc[direccion];
  $6800..$6802,$6804,$6807:galaga_sub2_getbyte:=$3; //Leer DSW A y B
  $6803:galaga_sub2_getbyte:=$0;
  $6805,$6806:galaga_sub2_getbyte:=$2;
  $7000..$70ff:galaga_sub2_getbyte:=namco_06xx_data_r(direccion and $ff,0);
  $7100..$7100:galaga_sub2_getbyte:=namco_06xx_ctrl_r(0);
  $8800..$8bff,$9000..$93ff,$9800..$9bff:galaga_sub2_getbyte:=memoria[direccion];
end;
end;

//DigDug
function namco_53xx_r_r(port:byte):byte;
begin
case port of //DSW A+B
  0:namco_53xx_r_r:=$9; // DIP A low
  1:namco_53xx_r_r:=$9; // DIP A high
  2:namco_53xx_r_r:=$4; // DIP B low
  3:namco_53xx_r_r:=$2; // DIP B high
end;
end;

function namco_53xx_k_r:byte;
begin
  namco_53xx_k_r:=custom_mod shl 1;
end;

procedure draw_sprites_digdug;inline;
var
  nchar,f,atrib,a,b,c,d,flipx_v,flipy_v:byte;
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
    flipx:=(atrib and $02)<>0;
    flipy:=(atrib and $01)<>0;
	  if (nchar and $80)=0 then begin //16x16
            put_gfx_sprite_mask(nchar,color,flipx,flipy,1,$1f,$1f);
            actualiza_gfx_sprite(x,y,2,1);
      end else begin  //32x32
            flipx_v:=atrib and $02;
            flipy_v:=atrib and $01;
            a:=0 xor flipy_v xor flipx_v;
            b:=1 xor flipy_v xor flipx_v;
            c:=2 xor flipy_v xor flipx_v;
            d:=3 xor flipy_v xor flipx_v;
            nchar:=(nchar and $c0) or ((nchar and $3f) shl 2);
            put_gfx_sprite_mask_diff(nchar+a,color,flipx,flipy,1,$1f,$1f,16,0);
            put_gfx_sprite_mask_diff(nchar+b,color,flipx,flipy,1,$1f,$1f,16,16);
            put_gfx_sprite_mask_diff(nchar+c,color,flipx,flipy,1,$1f,$1f,0,0);
            put_gfx_sprite_mask_diff(nchar+d,color,flipx,flipy,1,$1f,$1f,0,16);
            actualiza_gfx_sprite_size(x,y,2,32,32);
      end;
end;
end;

procedure update_video_digdug;inline;
var
  color,nchar,pos:word;
  sx,sy,x,y:byte;
begin
for x:=0 to 27 do begin
  for y:=0 to 35 do begin
      sx:=29-x;
      sy:=y-2;
	    if (sy and $20)<>0 then pos:=sx+((sy and $1f) shl 5)
  	    else pos:=sy+(sx shl 5);
      //Background
      if bg_repaint then begin
        nchar:=digdug_bg[pos or (bg_select shl 10)];
        if bg_disable<>0 then color:=$f
          else color:=(nchar shr 4);
        put_gfx(x*8,y*8,nchar,(color or bg_color_bank) shl 2,3,2);
      end;
      //Chars
      if gfx[0].buffer[pos] then begin
        nchar:=memoria[$8000+pos];
        color:=((nchar shr 4) and $0e) or ((nchar shr 3) and 2);
        put_gfx_trans(x*8,y*8,nchar and $7f,color shl 1,1,0);
        gfx[0].buffer[pos]:=false;
      end;
  end;
end;
actualiza_trozo(0,0,224,288,3,0,0,224,288,2);
actualiza_trozo(0,0,224,288,1,0,0,224,288,2);
draw_sprites_digdug;
actualiza_trozo_final(0,0,224,288,2);
end;

procedure digdug_principal;
var
  frame_m,frame_s1,frame_s2:single;
  f,scanline:word;
begin
init_controls(false,false,false,true);
frame_m:=main_z80.tframes;
frame_s1:=snd_z80.tframes;
frame_s2:=sub_z80.tframes;
scanline:=63;
while EmuStatus=EsRuning do begin
 for f:=0 to 263 do begin
  //Main CPU
  main_z80.run(frame_m);
  frame_m:=frame_m+main_z80.tframes-main_z80.contador;
  //Sub CPU
  snd_z80.run(frame_s1);
  frame_s1:=frame_s1+snd_z80.tframes-snd_z80.contador;
  //Sub 2 CPU
  sub_z80.run(frame_s2);
  frame_s2:=frame_s2+sub_z80.tframes-sub_z80.contador;
  //IO's
  run_namco_53xx;
  if (f=scanline) then begin
    if sub2_nmi then sub_z80.change_nmi(PULSE_LINE);
    scanline:=scanline+128;
	  if (scanline>=272) then scanline:=63;
  end;
  if f=223 then begin
    if main_irq then main_z80.change_irq(ASSERT_LINE);
    if sub_irq then snd_z80.change_irq(ASSERT_LINE);
    update_video_digdug;
  end;
 end;
 if sound_status.hay_sonido then begin
      namco_playsound;
      play_sonido;
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
if (direccion<$4000) then exit;
case direccion of
    $6800..$681f:namco_sound.registros_namco[direccion and $1f]:=valor;
    $6820..$6827:galaga_latch(direccion and $7,valor);
    $7000..$70ff:namco_06xx_data_w(direccion and $ff,0,valor);
    $7100..$7100:namco_06xx_ctrl_w(0,valor);
    $8000..$83ff:begin
                    gfx[0].buffer[direccion and $3ff]:=true;
                    memoria[direccion]:=valor;
                 end;
    $8400..$8bff,$9000..$93ff,$9800..$9bff:memoria[direccion]:=valor;
    $a000..$a007:case (direccion and $7) of //port_w
		                0,1:begin	// select background picture
                          shift:=direccion and $7;
				                  mask:=1 shl shift;
				                  if ((bg_select and mask)<>((valor and 1) shl shift)) then begin
                  					bg_select:=(bg_select and not(mask)) or ((valor and 1) shl shift);
                            bg_repaint:=true;
                          end;
                        end;
		                2:if (tx_color_mode<>(valor and 1)) then tx_color_mode:=valor and 1;	// select alpha layer color mode
		                3:if (bg_disable<>(valor and 1)) then begin // "disable" background
				                    bg_disable:=valor and 1;
                            bg_repaint:=true;
                        end;
		                4,5:begin //background color bank
				                  shift:=direccion and $7;
				                  mask:=1 shl shift;
				                  if ((bg_color_bank and mask)<>((valor and 1) shl shift)) then begin
					                  bg_color_bank:=(bg_color_bank and not(mask)) or ((valor and 1) shl shift);
                            bg_repaint:=true;
                          end;
                        end;
		              6:;	// n.c. */
		              7:main_screen.flip_main_screen:=(valor and 1)<>0;	// FLIP */
                 end;
    $b800..$b840:memoria[direccion]:=valor; //eeprom
end;
end;

function digdug_getbyte(direccion:word):byte;
begin
case direccion of
  0..$3fff,$8000..$8bff,$9000..$93ff,$9800..$9bff:digdug_getbyte:=memoria[direccion];
  $7000..$70ff:digdug_getbyte:=namco_06xx_data_r(direccion and $ff,0);
  $7100..$7100:digdug_getbyte:=namco_06xx_ctrl_r(0);
  $b800..$b83f:digdug_getbyte:=memoria[direccion]; //eeprom
end;
end;

//Sub1 CPU
function digdug_sub_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$3fff:digdug_sub_getbyte:=mem_snd[direccion];
  $7000..$70ff:digdug_sub_getbyte:=namco_06xx_data_r(direccion and $ff,0);
  $7100..$7100:digdug_sub_getbyte:=namco_06xx_ctrl_r(0);
  $8000..$8bff,$9000..$93ff,$9800..$9bff:digdug_sub_getbyte:=memoria[direccion];
  $b800..$b83f:digdug_sub_getbyte:=memoria[direccion]; //eeprom
end;
end;
//Sub2 CPU
function digdug_sub2_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$3fff:digdug_sub2_getbyte:=mem_misc[direccion];
  $7000..$70ff:digdug_sub2_getbyte:=namco_06xx_data_r(direccion and $ff,0);
  $7100..$7100:digdug_sub2_getbyte:=namco_06xx_ctrl_r(0);
  $8000..$8bff,$9000..$93ff,$9800..$9bff:digdug_sub2_getbyte:=memoria[direccion];
  $b800..$b83f:digdug_sub2_getbyte:=memoria[direccion]; //eeprom
end;
end;

//Xevious
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
            code:=code and not(1);
            sx1:=16*byte(flipx);
            sx2:=16*byte(not(flipx));
            put_gfx_sprite_mask_diff(code,color,flipx,flipy,2,0,$f,sx1,0);
            put_gfx_sprite_mask_diff(code+1,color,flipx,flipy,2,0,$f,sx2,0);
            actualiza_gfx_sprite_size(x,y,3,32,16);
          end;
        2:begin //double height
            code:=code and not(2);
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
            code:=code and not(3);
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

procedure update_video_xevious;
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
        color:=((atrib and $3c) shr 2) or ((nchar and $80) shr 3) or ((atrib and $03) shl 5);
        put_gfx_flip(x*8,y*8,nchar+((atrib and 1) shl 8),color shl 2,2,1,(atrib and $80)<>0,(atrib and $40)<>0);
        gfx[1].buffer[f]:=false;
    end;
end;
scroll_x_y(2,3,scrolly_bg+20,scrollx_bg+20);
draw_sprites_xevious;
scroll_x_y(1,3,scrolly_fg+18,scrollx_fg+32);
actualiza_trozo_final(0,0,224,288,3);
end;

procedure xevious_principal;
var
  frame_m,frame_s1,frame_s2:single;
  f,scanline:word;
begin
init_controls(false,false,false,true);
frame_m:=main_z80.tframes;
frame_s1:=snd_z80.tframes;
frame_s2:=sub_z80.tframes;
scanline:=63;
while EmuStatus=EsRuning do begin
 for f:=0 to 263 do begin
  //Main CPU
  main_z80.run(frame_m);
  frame_m:=frame_m+main_z80.tframes-main_z80.contador;
  //Sub CPU
  snd_z80.run(frame_s1);
  frame_s1:=frame_s1+snd_z80.tframes-snd_z80.contador;
  //Sub 2 CPU
  sub_z80.run(frame_s2);
  frame_s2:=frame_s2+sub_z80.tframes-sub_z80.contador;
  //IO's
  run_namco_50xx;
  run_namco_54xx;
  if (f=scanline) then begin
    if sub2_nmi then sub_z80.change_nmi(PULSE_LINE);
    scanline:=scanline+128;
	  if (scanline>=272) then scanline:=63;
  end;
  if f=223 then begin
    if main_irq then main_z80.change_irq(ASSERT_LINE);
    if sub_irq then snd_z80.change_irq(ASSERT_LINE);
    update_video_xevious;
  end;
 end;
 if sound_status.hay_sonido then begin
      namco_playsound;
      play_sonido;
 end;
 eventos_galaga;
 video_sync;
end;
end;

//Main CPU
procedure xevious_putbyte(direccion:word;valor:byte);
var
  scroll:word;
begin
if (direccion<$4000) then exit;
case direccion of
    $6800..$681f:namco_sound.registros_namco[direccion and $1f]:=valor;
    $6820..$6827:galaga_latch(direccion and $7,valor);
    $6830:;
    $7000..$70ff:namco_06xx_data_w(direccion and $ff,0,valor);
    $7100..$7100:namco_06xx_ctrl_w(0,valor);
    $7800..$87ff,$9000..$97ff,$a000..$a7ff:memoria[direccion]:=valor;
    $b000..$b7ff,$c000..$c7ff:begin
                    gfx[0].buffer[direccion and $7ff]:=true;
                    memoria[direccion]:=valor;
                 end;
    $b800..$bfff,$c800..$cfff:begin
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

function xevious_dip(direccion:word):byte;
var
  bit0,bit1:byte;
begin
bit0:=($fe+(marcade.in2 and 1)) shr (direccion and 7) and 1;
bit1:=$ff shr (direccion and 7) and 1;
xevious_dip:=bit0 or (bit1 shl 1);
end;

function xevious_bb_r(direccion:word):byte;
var
  dat1,adr_2b,adr_2c:word;
  dat2:byte;
begin
// get BS to 12 bit data from 2A,2B */
adr_2b:=((xevious_bs[1] and $7e) shl 6) or ((xevious_bs[0] and $fe) shr 1);
if (adr_2b and 1)<>0 then // high bits select
  dat1:=((xevious_tiles[0+(adr_2b shr 1)] and $f0) shl 4) or xevious_tiles[$1000+adr_2b]
else	// low bits select */
  dat1:=((xevious_tiles[0+(adr_2b shr 1)] and $0f) shl 8) or xevious_tiles[$1000+adr_2b];
adr_2c:=((dat1 and $1ff) shl 2) or ((xevious_bs[1] and 1) shl 1) or (xevious_bs[0] and 1);
if (dat1 and $400)<>0 then adr_2c:=adr_2c xor 1;
if (dat1 and $200)<>0 then adr_2c:=adr_2c xor 2;
if (direccion and 1)<>0 then // return BB1
  dat2:=xevious_tiles[$3000+(adr_2c or $800)]
else begin // return BB0
  dat2:=xevious_tiles[$3000+adr_2c];
  // swap bit 6 & 7
  dat2:= BITSWAP8(dat2,6,7,5,4,3,2,1,0);
  // flip x & y
  if (dat1 and $400)<>0 then dat2:=dat2 xor $40;
  if (dat1 and $200)<>0 then dat2:=dat2 xor $80;
end;
xevious_bb_r:=dat2;
end;

function xevious_getbyte(direccion:word):byte;
begin
case direccion of
  0..$3fff,$7800..$87ff,$9000..$97ff,$a000..$a7ff,$b000..$cfff:xevious_getbyte:=memoria[direccion];
  $6800..$6807:xevious_getbyte:=xevious_dip(direccion);
  $7000..$70ff:xevious_getbyte:=namco_06xx_data_r(direccion and $ff,0);
  $7100..$7100:xevious_getbyte:=namco_06xx_ctrl_r(0);
  $f000..$ffff:xevious_getbyte:=xevious_bb_r(direccion);
end;
end;

//Sub1 CPU
function xevious_sub_getbyte(direccion:word):byte;
begin
case direccion of
  0..$3fff:xevious_sub_getbyte:=mem_snd[direccion];
  $7800..$87ff,$9000..$97ff,$a000..$a7ff,$b000..$cfff:xevious_sub_getbyte:=memoria[direccion];
  $6800..$6807:xevious_sub_getbyte:=xevious_dip(direccion);
  $7000..$70ff:xevious_sub_getbyte:=namco_06xx_data_r(direccion and $ff,0);
  $7100..$7100:xevious_sub_getbyte:=namco_06xx_ctrl_r(0);
  $f000..$ffff:xevious_sub_getbyte:=xevious_bb_r(direccion);
end;
end;

//Sub2 CPU
function xevious_sub2_getbyte(direccion:word):byte;
begin
case direccion of
  0..$3fff:xevious_sub2_getbyte:=mem_misc[direccion];
  $7800..$87ff,$9000..$97ff,$a000..$a7ff,$b000..$cfff:xevious_sub2_getbyte:=memoria[direccion];
  $6800..$6807:xevious_sub2_getbyte:=xevious_dip(direccion);
  $7000..$70ff:xevious_sub2_getbyte:=namco_06xx_data_r(direccion and $ff,0);
  $7100..$7100:xevious_sub2_getbyte:=namco_06xx_ctrl_r(0);
  $f000..$ffff:xevious_sub2_getbyte:=xevious_bb_r(direccion);
end;
end;

//Namco IO
procedure namco_06xx_nmi;
begin
  main_z80.change_nmi(PULSE_LINE);
end;

//Main
procedure reset_galagahw;
var
  f:byte;
begin
 main_z80.reset;
 snd_z80.reset;
 sub_z80.reset;
 case main_vars.tipo_maquina of
    65:begin
          namcoio_51xx_reset(false);
          namcoio_54xx_reset;
          reset_samples;
          for f:=0 to 5 do galaga_starcontrol[f]:=0;
          scrollx_bg:=0;
          scrolly_bg:=0;
       end;
   167:begin
          namcoio_51xx_reset(false);
          namcoio_53xx_reset;
          custom_mod:=0;
          bg_select:=0;
          bg_color_bank:=0;
          bg_disable:=0;
          tx_color_mode:=0;
          bg_repaint:=true;
       end;
   231:begin
          namcoio_50xx_reset;
          namcoio_51xx_reset(true);
          namcoio_54xx_reset;
          scrollx_bg:=0;
          scrolly_bg:=0;
          scrollx_fg:=0;
          scrolly_fg:=0;
          xevious_bs[0]:=0;
          xevious_bs[1]:=0;
       end;
 end;
 namco_sound_reset;
 reset_audio;
 namcoio_06xx_reset(0);
 main_irq:=false;
 sub_irq:=false;
 sub2_nmi:=false;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 for f:=0 to 7 do galaga_latch(f,0);
end;

function iniciar_galagahw:boolean;
var
      colores:tpaleta;
      f:word;
      ctemp0,ctemp1,ctemp2,ctemp3:byte;
      memoria_temp:array[0..$9fff] of byte;
const
  map:array[0..3] of byte=($00,$47,$97,$de);
  ps_x:array[0..15] of dword=(0, 1, 2, 3, 8*8, 8*8+1, 8*8+2, 8*8+3, 16*8+0, 16*8+1, 16*8+2, 16*8+3,
			24*8+0, 24*8+1, 24*8+2, 24*8+3);
  ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			32*8, 33*8, 34*8, 35*8, 36*8, 37*8, 38*8, 39*8);
  pc_x_digdug:array[0..7] of dword=(7, 6, 5, 4, 3, 2, 1, 0);
  pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
  pc_x_xevious:array[0..7] of dword=(0,1,2,3,4,5,6,7);

procedure galaga_chr(ngfx:byte;num:word);
const
  pc_x:array[0..7] of dword=(8*8+0, 8*8+1, 8*8+2, 8*8+3,  0, 1, 2, 3);
begin
init_gfx(ngfx,8,8,num);
gfx_set_desc_data(2,0,16*8,0,4);
convert_gfx(ngfx,0,@memoria_temp[0],@pc_x[0],@pc_y[0],true,false);
end;

procedure galaga_spr(num:word);
begin
init_gfx(1,16,16,num);
gfx_set_desc_data(2,0,64*8,0,4);
convert_gfx(1,0,@memoria_temp[0],@ps_x[0],@ps_y[0],true,false);
end;

begin
iniciar_galagahw:=false;
iniciar_audio(false);
if main_vars.tipo_maquina<>231 then begin
  screen_init(1,224,288,true);
  screen_init(2,256,512,false,true);
  screen_init(3,224,288);
end else begin
  screen_init(1,256,512,true);
  screen_mod_scroll(1,256,256,255,512,512,511);
  screen_init(2,256,512,true);
  screen_mod_scroll(2,256,256,255,512,512,511);
  screen_init(3,256,512,false,true);
end;
iniciar_video(224,288);
//Main CPU
main_z80:=cpu_z80.create(3072000,264);
//Sub CPU
snd_z80:=cpu_z80.create(3072000,264);
//Sub2 CPU
sub_z80:=cpu_z80.create(3072000,264);
//Sound
namco_sound_init(3,false);
//IO's
namcoio_51xx_init(@marcade.in0,@marcade.in1);
case main_vars.tipo_maquina of
    65:begin  //Galaga
          //CPU's
          //Main
          main_z80.change_ram_calls(galaga_getbyte,galaga_putbyte);
          //Sub1
          snd_z80.change_ram_calls(galaga_sub_getbyte,galaga_putbyte);
          //Sub2
          sub_z80.change_ram_calls(galaga_sub2_getbyte,galaga_putbyte);
          //Init IO's
          namco_06xx_init(0,IO51XX,NONE,NONE,IO54XX,namco_06xx_nmi);
          //Namco 54xx
          if not(namcoio_54xx_init('galaga.zip')) then exit;
          if load_samples('galaga.zip',@galaga_samples[0],num_samples_galaga) then main_z80.init_sound(galaga_sound_update);
          //cargar roms
          if not(cargar_roms(@memoria[0],@galaga_rom[0],'galaga.zip',0)) then exit;
          if not(cargar_roms(@mem_snd[0],@galaga_sub,'galaga.zip',1)) then exit;
          if not(cargar_roms(@mem_misc[0],@galaga_sub2,'galaga.zip',1)) then exit;
          //cargar sonido & iniciar_sonido
          if not(cargar_roms(@namco_sound.onda_namco[0],@galaga_sound,'galaga.zip',1)) then exit;
          //convertir chars
          if not(cargar_roms(@memoria_temp[0],@galaga_char,'galaga.zip',1)) then exit;
          galaga_chr(0,$100);
          //convertir sprites
          if not(cargar_roms(@memoria_temp[0],@galaga_sprites[0],'galaga.zip',0)) then exit;
          galaga_spr($80);
          //poner la paleta
          if not(cargar_roms(@memoria_temp[0],@galaga_prom[0],'galaga.zip',0)) then exit;
          for f:=0 to $1f do begin
              ctemp1:=memoria_temp[f];
              colores[f].r:=$21*(ctemp1 and 1)+$47*((ctemp1 shr 1) and 1)+$97*((ctemp1 shr 2) and 1);
              colores[f].g:=$21*((ctemp1 shr 3) and 1)+$47*((ctemp1 shr 4) and 1)+$97*((ctemp1 shr 5) and 1);
              colores[f].b:=0+$47*((ctemp1 shr 6) and 1)+$97*((ctemp1 shr 7) and 1);
          end;
          //paleta de las estrellas
          for f:=0 to $3f do begin
          		ctemp1:=(f shr 0) and $03;
          		colores[$20+f].r:=map[ctemp1];
          		ctemp1:=(f shr 2) and $03;
          		colores[$20+f].g:=map[ctemp1];
          		ctemp1:=(f shr 4) and $03;
          		colores[$20+f].b:=map[ctemp1];
          end;
          set_pal(colores,32+64);
          //CLUT
          for f:=0 to $ff do begin
            gfx[0].colores[f]:=memoria_temp[$20+f]+$10;
            gfx[1].colores[f]:=memoria_temp[$120+f];
          end;
       end;
    167:begin //DigDug
          //Main
          main_z80.change_ram_calls(digdug_getbyte,digdug_putbyte);
          //Sub1
          snd_z80.change_ram_calls(digdug_sub_getbyte,digdug_putbyte);
          //Sub2
          sub_z80.change_ram_calls(digdug_sub2_getbyte,digdug_putbyte);
          //Init IO's
          namco_06xx_init(0,IO51XX,IO53XX,NONE,NONE,namco_06xx_nmi);
          //Namco 53XX
          if not(namcoio_53xx_init(namco_53xx_k_r,namco_53xx_r_r,'digdug.zip')) then exit;
          //cargar roms
          if not(cargar_roms(@memoria[0],@digdug_rom[0],'digdug.zip',0)) then exit;
          if not(cargar_roms(@mem_snd[0],@digdug_sub,'digdug.zip',0)) then exit;
          if not(cargar_roms(@mem_misc[0],@digdug_sub2,'digdug.zip',1)) then exit;
          //cargar sonido & iniciar_sonido
          if not(cargar_roms(@namco_sound.onda_namco[0],@digdug_sound,'digdug.zip',1)) then exit;
          //convertir chars
          if not(cargar_roms(@memoria_temp[0],@digdug_chars,'digdug.zip',1)) then exit;
          init_gfx(0,8,8,$200);
          gfx[0].trans[0]:=true;
          gfx_set_desc_data(1,0,8*8,0);
          convert_gfx(0,0,@memoria_temp[$0],@pc_x_digdug[0],@pc_y[0],true,false);
          //sprites
          if not(cargar_roms(@memoria_temp[0],@digdug_sprites,'digdug.zip',0)) then exit;
          galaga_spr($100);
          //Background
          if not(cargar_roms(@digdug_bg[0],@digdug_background,'digdug.zip',1)) then exit;
          if not(cargar_roms(@memoria_temp[0],@digdug_chars2,'digdug.zip',1)) then exit;
          galaga_chr(2,$100);
          //poner la paleta
          if not(cargar_roms(@memoria_temp[0],@digdug_prom[0],'digdug.zip',0)) then exit;
          for f:=0 to $1f do begin
              ctemp1:=memoria_temp[f];
              colores[f].r:=$21*(ctemp1 and 1)+$47*((ctemp1 shr 1) and 1)+$97*((ctemp1 shr 2) and 1);
              colores[f].g:=$21*((ctemp1 shr 3) and 1)+$47*((ctemp1 shr 4) and 1)+$97*((ctemp1 shr 5) and 1);
              colores[f].b:=0+$47*((ctemp1 shr 6) and 1)+$97*((ctemp1 shr 7) and 1);
          end;
          set_pal(colores,32);
          //CLUT
          for f:=0 to 15 do begin //chars
        		gfx[0].colores[f*2+0]:=$0;
		        gfx[0].colores[f*2+1]:=f;
          end;
          for f:=0 to $ff do begin
            gfx[1].colores[f]:=memoria_temp[$20+f]+$10; //sprites
            gfx[2].colores[f]:=memoria_temp[$120+f];    //background
          end;
        end;
    231:begin  //Xevious
          //CPU's
          //Main
          main_z80.change_ram_calls(xevious_getbyte,xevious_putbyte);
          //Sub1
          snd_z80.change_ram_calls(xevious_sub_getbyte,xevious_putbyte);
          //Sub2
          sub_z80.change_ram_calls(xevious_sub2_getbyte,xevious_putbyte);
          //Init IO's
          namco_06xx_init(0,IO51XX,NONE,IO50XX,IO54XX,namco_06xx_nmi);
          //Namco 54xx
          if not(namcoio_50xx_init('xevious.zip')) then exit;
          if not(namcoio_54xx_init('xevious.zip')) then exit;
          if load_samples('xevious.zip',@xevious_samples[0],num_samples_xevious) then main_z80.init_sound(galaga_sound_update);
          //cargar roms
          if not(cargar_roms(@memoria[0],@xevious_rom[0],'xevious.zip',0)) then exit;
          if not(cargar_roms(@mem_snd[0],@xevious_sub,'xevious.zip',0)) then exit;
          if not(cargar_roms(@mem_misc[0],@xevious_sub2,'xevious.zip',1)) then exit;
          //cargar sonido & iniciar_sonido
          if not(cargar_roms(@namco_sound.onda_namco[0],@xevious_sound,'xevious.zip',1)) then exit;
          //chars
          if not(cargar_roms(@memoria_temp[0],@xevious_char,'xevious.zip',1)) then exit;
          init_gfx(0,8,8,$200);
          gfx[0].trans[0]:=true;
          gfx_set_desc_data(1,0,8*8,0);
          convert_gfx(0,0,@memoria_temp[$0],@pc_x_xevious[0],@pc_y[0],true,false);
          //convertir sprites
          fillchar(memoria_temp[0],$a000,0);
          if not(cargar_roms(@memoria_temp[0],@xevious_sprites[0],'xevious.zip',0)) then exit;
          for f:=0 to $1fff do memoria_temp[f+$7000]:=memoria_temp[f+$5000] shr 4;
          init_gfx(2,16,16,$140);
          gfx_set_desc_data(3,0,64*8,($140*64*8)+4,0,4);
          convert_gfx(2,0,@memoria_temp[0],@ps_x[0],@ps_y[0],true,false);
          //tiles
          if not(cargar_roms(@xevious_tiles[0],@xevious_bg_tiles[0],'xevious.zip',0)) then exit;
          if not(cargar_roms(@memoria_temp[0],@xevious_bg[0],'xevious.zip',0)) then exit;
          init_gfx(1,8,8,$200);
          gfx_set_desc_data(2,0,8*8,0,$200*8*8);
          convert_gfx(1,0,@memoria_temp[$0],@pc_x_xevious[0],@pc_y[0],true,false);
          //poner la paleta
          if not(cargar_roms(@memoria_temp[0],@xevious_prom[0],'xevious.zip',0)) then exit;
          for f:=0 to $ff do begin
              ctemp0:=(memoria_temp[f] shr 0) and 1;
              ctemp1:=(memoria_temp[f] shr 1) and 1;
              ctemp2:=(memoria_temp[f] shr 2) and 1;
              ctemp3:=(memoria_temp[f] shr 3) and 1;
              colores[f].r:=$0e*ctemp0+$1f*ctemp1+$43*ctemp2+$8f*ctemp3;
              ctemp0:=(memoria_temp[f+256] shr 0) and 1;
              ctemp1:=(memoria_temp[f+256] shr 1) and 1;
              ctemp2:=(memoria_temp[f+256] shr 2) and 1;
              ctemp3:=(memoria_temp[f+256] shr 3) and 1;
              colores[f].g:=$0e*ctemp0+$1f*ctemp1+$43*ctemp2+$8f*ctemp3;
              ctemp0:=(memoria_temp[f+512] shr 0) and 1;
              ctemp1:=(memoria_temp[f+512] shr 1) and 1;
              ctemp2:=(memoria_temp[f+512] shr 2) and 1;
              ctemp3:=(memoria_temp[f+512] shr 3) and 1;
              colores[f].b:=$0e*ctemp0+$1f*ctemp1+$43*ctemp2+$8f*ctemp3;
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
       end;
end;
//final
reset_galagahw;
iniciar_galagahw:=true;
end;

procedure cerrar_galagahw;
begin
case main_vars.tipo_maquina of
  65:namco_54xx_close;
  167:namco_53xx_close;
  231:begin
        namco_50xx_close;
        namco_54xx_close;
      end;
end;
end;

procedure Cargar_galagahw;
begin
llamadas_maquina.iniciar:=iniciar_galagahw;
case main_vars.tipo_maquina of
  65:llamadas_maquina.bucle_general:=galaga_principal;
  167:llamadas_maquina.bucle_general:=digdug_principal;
  231:llamadas_maquina.bucle_general:=xevious_principal;
end;
llamadas_maquina.close:=cerrar_galagahw;
llamadas_maquina.reset:=reset_galagahw;
llamadas_maquina.fps_max:=60.6060606060;
end;

end.
