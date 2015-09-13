unit galaga_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,namco_snd,controls_engine,gfx_engine,namcoio_06xx_51xx_53xx,
     rom_engine,pal_engine,sound_engine,galaga_stars_const;

procedure Cargar_Galagahw;
function iniciar_galagahw:boolean;
procedure reset_galagahw;
procedure cerrar_galagahw;
//Galaga
procedure galaga_principal;
function galaga_getbyte(direccion:word):byte;
procedure galaga_putbyte(direccion:word;valor:byte);
function galaga_sub_getbyte(direccion:word):byte;
function galaga_sub2_getbyte(direccion:word):byte;
//DigDug
procedure digdug_principal;
function digdug_getbyte(direccion:word):byte;
procedure digdug_putbyte(direccion:word;valor:byte);
function digdug_sub_getbyte(direccion:word):byte;
function digdug_sub2_getbyte(direccion:word):byte;
//Namco IO's
procedure namco_06xx_nmi;
function namco_51xx_io0:byte;
function namco_51xx_io1:byte;
function namco_51xx_io2:byte;
function namco_51xx_io3:byte;
function namco_53xx_r_r(port:byte):byte;
function namco_53xx_k_r:byte;

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

var
 main_irq,sub_irq,sub2_nmi:boolean;
 //Galaga
 galaga_starcontrol:array[0..5] of byte;
 stars_scrollx,stars_scrolly:dword;
 //Dig Dug
 digdug_bg:array[0..$fff] of byte;
 custom_mod,bg_select,bg_color_bank,bg_disable,tx_color_mode:byte;
 bg_repaint:boolean;
 in0,in1,in2:byte;

procedure Cargar_galagahw;
begin
llamadas_maquina.iniciar:=iniciar_galagahw;
case main_vars.tipo_maquina of
  65:llamadas_maquina.bucle_general:=galaga_principal;
  167:llamadas_maquina.bucle_general:=digdug_principal;
end;
llamadas_maquina.cerrar:=cerrar_galagahw;
llamadas_maquina.reset:=reset_galagahw;
llamadas_maquina.fps_max:=60.6060606060;
end;

function iniciar_galagahw:boolean;
var
      colores:tpaleta;
      f:word;
      ctemp1:byte;
      memoria_temp:array[0..$3fff] of byte;
const
  map:array[0..3] of byte=($00,$47,$97,$de);
  pc_x_digdug:array[0..7] of dword=(7, 6, 5, 4, 3, 2, 1, 0);
  pc_y_digdug:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);

procedure galaga_chr(ngfx:byte;num:word);
const
  pc_x:array[0..7] of dword=(8*8+0, 8*8+1, 8*8+2, 8*8+3,  0, 1, 2, 3);
  pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
begin
init_gfx(ngfx,8,8,num);
gfx_set_desc_data(2,0,16*8,0,4);
convert_gfx(ngfx,0,@memoria_temp[0],@pc_x[0],@pc_y[0],true,false);
end;

procedure galaga_spr(num:word);
const
  ps_x:array[0..15] of dword=(0, 1, 2, 3, 8*8, 8*8+1, 8*8+2, 8*8+3, 16*8+0, 16*8+1, 16*8+2, 16*8+3,
			24*8+0, 24*8+1, 24*8+2, 24*8+3);
  ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			32*8, 33*8, 34*8, 35*8, 36*8, 37*8, 38*8, 39*8);
begin
init_gfx(1,16,16,num);
gfx_set_desc_data(2,0,64*8,0,4);
convert_gfx(1,0,@memoria_temp[0],@ps_x[0],@ps_y[0],true,false);
end;

begin
iniciar_galagahw:=false;
iniciar_audio(false);
//Pantallas:  principal+char y sprites
screen_init(1,224,288,true);
screen_init(2,256,512,false,true);
screen_init(3,224,288); //Digdug background
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
namco_51xx.read_port[0]:=namco_51xx_io0;
namco_51xx.read_port[1]:=namco_51xx_io1;
namco_51xx.read_port[2]:=namco_51xx_io2;
namco_51xx.read_port[3]:=namco_51xx_io3;
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
          namco_06xx_init(0,IO51XX,NONE,NONE,NONE,namco_06xx_nmi);
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
          namcoio_53xx_init(namco_53xx_k_r,namco_53xx_r_r,'digdug.zip');
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
          convert_gfx(0,0,@memoria_temp[$0],@pc_x_digdug[0],@pc_y_digdug[0],true,false);
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
end;
//final
reset_galagahw;
iniciar_galagahw:=true;
end;

procedure cerrar_galagahw;
begin
main_z80.free;
snd_z80.free;
sub_z80.free;
if main_vars.tipo_maquina=167 then namco_53xx_close;
close_audio;
close_video;
end;

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
	stars_scrolly:=stars_scrolly+speeds[s0+s1*2+s2*4];
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
				y:=(star_seed_tab[star_cntr].y+stars_scrolly) mod 256+16;
				x:=(112+star_seed_tab[star_cntr].x+stars_scrollx) mod 256;
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
  if arcade_input.up[0] then in1:=(in1 and $fe) else in1:=(in1 or $1);
  if arcade_input.right[0] then in1:=(in1 and $Fd) else in1:=(in1 or $2);
  if arcade_input.down[0] then in1:=(in1 and $fb) else in1:=(in1 or $4);
  if arcade_input.left[0] then in1:=(in1 and $f7) else in1:=(in1 or $8);
  if arcade_input.but0[0] then in0:=(in0 and $fe) else in0:=(in0 or $1);
  if arcade_input.start[0] then in0:=(in0 and $fb) else in0:=(in0 or $4);
  if arcade_input.start[1] then in0:=(in0 and $f7) else in0:=(in0 or $8);
  if arcade_input.coin[0] then in0:=(in0 and $ef) else in0:=(in0 or $10);
  if arcade_input.coin[1] then in0:=(in0 and $df) else in0:=(in0 or $20);
end;
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
    if (f=scanline) then begin
        if sub2_nmi then sub_z80.pedir_nmi:=PULSE_LINE;
        scanline:=scanline+128;
	      if (scanline>=272) then scanline:=63;
    end;
    if f=223 then begin
        if main_irq then main_z80.pedir_irq:=ASSERT_LINE;
        if sub_irq then snd_z80.pedir_irq:=ASSERT_LINE;
        update_video_galaga;
        copymemory(@buffer_sprites[0],@memoria[$fe00],$200);
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

procedure galaga_latch(dir,val:byte);inline;
var
  bit:byte;
begin
bit:=val and 1;
case dir of
		$0:begin	// IRQ1 */
        main_irq:=bit<>0;
			  if not(main_irq) then main_z80.pedir_irq:=CLEAR_LINE;
			 end;
		$1:begin	// IRQ2 */
			    sub_irq:=bit<>0;
  			  if not(sub_irq) then snd_z80.pedir_irq:=CLEAR_LINE;
			 end;
		$2:sub2_nmi:=(bit=0);	// NMION */
		$3:if (bit<>0) then begin  // RESET */
          snd_z80.pedir_reset:=CLEAR_LINE;
          sub_z80.pedir_reset:=CLEAR_LINE;
       end else begin
          snd_z80.pedir_reset:=ASSERT_LINE;
          sub_z80.pedir_reset:=ASSERT_LINE;
       end;
		$4:; //n.c.
    $05:custom_mod:=(custom_mod and $fe) or (bit shl 0);	// MOD 0
		$06:custom_mod:=(custom_mod and $fd) or (bit shl 1);	// MOD 1
    $07:custom_mod:=(custom_mod and $fb) or (bit shl 2);	// MOD 2
end;
end;

procedure reset_galagahw;
var
  f:byte;
begin
 main_z80.reset;
 snd_z80.reset;
 sub_z80.reset;
 case main_vars.tipo_maquina of
    65:begin
          for f:=0 to 5 do galaga_starcontrol[f]:=0;
          stars_scrollx:=0;
          stars_scrolly:=0;
       end;
   167:begin
          namcoio_53xx_reset;
          custom_mod:=0;
          bg_select:=0;
          bg_color_bank:=0;
          bg_disable:=0;
          tx_color_mode:=0;
          bg_repaint:=true;
       end;
 end;
 namco_sound_reset;
 reset_audio;
 namcoio_51xx_reset;
 namcoio_06xx_reset(0);
 main_irq:=false;
 sub_irq:=false;
 sub2_nmi:=false;
 in0:=$ff;
 in1:=$ff;
 for f:=0 to 7 do galaga_latch(f,0);
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
    if sub2_nmi then sub_z80.pedir_nmi:=PULSE_LINE;
    scanline:=scanline+128;
	  if (scanline>=272) then scanline:=63;
  end;
  if f=223 then begin
    if main_irq then main_z80.pedir_irq:=ASSERT_LINE;
    if sub_irq then snd_z80.pedir_irq:=ASSERT_LINE;
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

//Namco IO
procedure namco_06xx_nmi;
begin
  main_z80.pedir_nmi:=PULSE_LINE;
end;

function namco_51xx_io0:byte;
begin
  namco_51xx_io0:=in0 and $f;
end;

function namco_51xx_io1:byte;
begin
  namco_51xx_io1:=in0 shr 4;
end;

function namco_51xx_io2:byte;
begin
  namco_51xx_io2:=in1 and $f;
end;

function namco_51xx_io3:byte;
begin
  namco_51xx_io3:=in1 shr 4;
end;

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

end.