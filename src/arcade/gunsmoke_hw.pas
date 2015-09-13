unit gunsmoke_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,ym_2203,gfx_engine,timer_engine,rom_engine,
     pal_engine,sound_engine;

procedure Cargar_gunsmokehw;
procedure gunsmokehw_principal;
function iniciar_gunsmokehw:boolean;
procedure reset_gunsmokehw;
procedure cerrar_gunsmokehw;
//gun smoke
function gunsmoke_getbyte(direccion:word):byte;
procedure gunsmoke_putbyte(direccion:word;valor:byte);
//1943
function hw1943_getbyte(direccion:word):byte;
procedure hw1943_putbyte(direccion:word;valor:byte);
//sonido (general)
function gunsmoke_snd_getbyte(direccion:word):byte;
procedure gunsmoke_snd_putbyte(direccion:word;valor:byte);
procedure gunsmoke_sound_update;
procedure gunsmoke_snd_irq;

implementation
const
        //Gun Smoke
        gunsmoke_rom:array[0..3] of tipo_roms=(
        (n:'09n_gs03.bin';l:$8000;p:0;crc:$40a06cef),(n:'10n_gs04.bin';l:$8000;p:$8000;crc:$8d4b423f),
        (n:'12n_gs05.bin';l:$8000;p:$10000;crc:$2b5667fb),());
        gunsmoke_snd_rom:tipo_roms=(n:'14h_gs02.bin';l:$8000;p:0;crc:$cd7a2c38);
        gunsmoke_pal:array[0..8] of tipo_roms=(
        (n:'03b_g-01.bin';l:$100;p:0;crc:$02f55589),(n:'04b_g-02.bin';l:$100;p:$100;crc:$e1e36dd9),
        (n:'05b_g-03.bin';l:$100;p:$200;crc:$989399c0),(n:'09d_g-04.bin';l:$100;p:$300;crc:$906612b5),
        (n:'14a_g-06.bin';l:$100;p:$400;crc:$4a9da18b),(n:'15a_g-07.bin';l:$100;p:$500;crc:$cb9394fc),
        (n:'09f_g-09.bin';l:$100;p:$600;crc:$3cee181e),(n:'08f_g-08.bin';l:$100;p:$700;crc:$ef91cdd2),());
        gunsmoke_char:tipo_roms=(n:'11f_gs01.bin';l:$4000;p:0;crc:$b61ece9b);
        gunsmoke_sprites:array[0..8] of tipo_roms=(
        (n:'06n_gs22.bin';l:$8000;p:0;crc:$dc9c508c),(n:'04n_gs21.bin';l:$8000;p:$8000;crc:$68883749),
        (n:'03n_gs20.bin';l:$8000;p:$10000;crc:$0be932ed),(n:'01n_gs19.bin';l:$8000;p:$18000;crc:$63072f93),
        (n:'06l_gs18.bin';l:$8000;p:$20000;crc:$f69a3c7c),(n:'04l_gs17.bin';l:$8000;p:$28000;crc:$4e98562a),
        (n:'03l_gs16.bin';l:$8000;p:$30000;crc:$0d99c3b3),(n:'01l_gs15.bin';l:$8000;p:$38000;crc:$7f14270e),());
        gunsmoke_tiles:array[0..8] of tipo_roms=(
        (n:'06c_gs13.bin';l:$8000;p:0;crc:$f6769fc5),(n:'05c_gs12.bin';l:$8000;p:$8000;crc:$d997b78c),
        (n:'04c_gs11.bin';l:$8000;p:$10000;crc:$125ba58e),(n:'02c_gs10.bin';l:$8000;p:$18000;crc:$f469c13c),
        (n:'06a_gs09.bin';l:$8000;p:$20000;crc:$539f182d),(n:'05a_gs08.bin';l:$8000;p:$28000;crc:$e87e526d),
        (n:'04a_gs07.bin';l:$8000;p:$30000;crc:$4382c0d2),(n:'02a_gs06.bin';l:$8000;p:$38000;crc:$4cafe7a6),());
        gunsmoke_tiles_pos:tipo_roms=(n:'11c_gs14.bin';l:$8000;p:0;crc:$0af4f7eb);
        //1943
        hw1943_rom:array[0..3] of tipo_roms=(
        (n:'bmu01c.12d';l:$8000;p:0;crc:$c686cc5c),(n:'bmu02c.13d';l:$10000;p:$8000;crc:$d8880a41),
        (n:'bmu03c.14d';l:$10000;p:$18000;crc:$3f0ee26c),());
        hw1943_snd_rom:tipo_roms=(n:'bm04.5h';l:$8000;p:0;crc:$ee2bd2d7);
        hw1943_pal:array[0..10] of tipo_roms=(
        (n:'bm1.12a';l:$100;p:0;crc:$74421f18),(n:'bm2.13a';l:$100;p:$100;crc:$ac27541f),
        (n:'bm3.14a';l:$100;p:$200;crc:$251fb6ff),(n:'bm5.7f';l:$100;p:$300;crc:$206713d0),
        (n:'bm10.7l';l:$100;p:$400;crc:$33c2491c),(n:'bm9.6l';l:$100;p:$500;crc:$aeea4af7),
        (n:'bm12.12m';l:$100;p:$600;crc:$c18aa136),(n:'bm11.12l';l:$100;p:$700;crc:$405aae37),
        (n:'bm8.8c';l:$100;p:$800;crc:$c2010a9e),(n:'bm7.7c';l:$100;p:$900;crc:$b56f30c3),());
        hw1943_char:tipo_roms=(n:'bm05.4k';l:$8000;p:0;crc:$46cb9d3d);
        hw1943_sprites:array[0..8] of tipo_roms=(
        (n:'bm06.10a';l:$8000;p:0;crc:$97acc8af),(n:'bm07.11a';l:$8000;p:$8000;crc:$d78f7197),
        (n:'bm08.12a';l:$8000;p:$10000;crc:$1a626608),(n:'bm09.14a';l:$8000;p:$18000;crc:$92408400),
        (n:'bm10.10c';l:$8000;p:$20000;crc:$8438a44a),(n:'bm11.11c';l:$8000;p:$28000;crc:$6c69351d),
        (n:'bm12.12c';l:$8000;p:$30000;crc:$5e7efdb7),(n:'bm13.14c';l:$8000;p:$38000;crc:$1143829a),());
        hw1943_tiles1:array[0..8] of tipo_roms=(
        (n:'bm15.10f';l:$8000;p:0;crc:$6b1a0443),(n:'bm16.11f';l:$8000;p:$8000;crc:$23c908c2),
        (n:'bm17.12f';l:$8000;p:$10000;crc:$46bcdd07),(n:'bm18.14f';l:$8000;p:$18000;crc:$e6ae7ba0),
        (n:'bm19.10j';l:$8000;p:$20000;crc:$868ababc),(n:'bm20.11j';l:$8000;p:$28000;crc:$0917e5d4),
        (n:'bm21.12j';l:$8000;p:$30000;crc:$9bfb0d89),(n:'bm22.14j';l:$8000;p:$38000;crc:$04f3c274),());
        hw1943_tiles2:array[0..2] of tipo_roms=(
        (n:'bm24.14k';l:$8000;p:0;crc:$11134036),(n:'bm25.14l';l:$8000;p:$8000;crc:$092cf9c1),());
        hw1943_tilesbg_pos:array[0..2] of tipo_roms=(
        (n:'bm14.5f';l:$8000;p:0;crc:$4d3c6401),(n:'bm23.8k';l:$8000;p:$8000;crc:$a52aecbd),());
        //1943 kai
        hw1943kai_rom:array[0..3] of tipo_roms=(
        (n:'bmk01.12d';l:$8000;p:0;crc:$7d2211db),(n:'bmk02.13d';l:$10000;p:$8000;crc:$2ebbc8c5),
        (n:'bmk03.14d';l:$10000;p:$18000;crc:$475a6ac5),());
        hw1943kai_snd_rom:tipo_roms=(n:'bmk04.5h';l:$8000;p:0;crc:$25f37957);
        hw1943kai_pal:array[0..10] of tipo_roms=(
        (n:'bmk1.12a';l:$100;p:0;crc:$e001ea33),(n:'bmk2.13a';l:$100;p:$100;crc:$af34d91a),
        (n:'bmk3.14a';l:$100;p:$200;crc:$43e9f6ef),(n:'bmk5.7f';l:$100;p:$300;crc:$41878934),
        (n:'bmk10.7l';l:$100;p:$400;crc:$de44b748),(n:'bmk9.6l';l:$100;p:$500;crc:$59ea57c0),
        (n:'bmk12.12m';l:$100;p:$600;crc:$8765f8b0),(n:'bmk11.12l';l:$100;p:$700;crc:$87a8854e),
        (n:'bmk8.8c';l:$100;p:$800;crc:$dad17e2d),(n:'bmk7.7c';l:$100;p:$900;crc:$76307f8d),());
        hw1943kai_char:tipo_roms=(n:'bmk05.4k';l:$8000;p:0;crc:$884a8692);
        hw1943kai_sprites:array[0..8] of tipo_roms=(
        (n:'bmk06.10a';l:$8000;p:0;crc:$5f7e38b3),(n:'bmk07.11a';l:$8000;p:$8000;crc:$ff3751fd),
        (n:'bmk08.12a';l:$8000;p:$10000;crc:$159d51bd),(n:'bmk09.14a';l:$8000;p:$18000;crc:$8683e3d2),
        (n:'bmk10.10c';l:$8000;p:$20000;crc:$1e0d9571),(n:'bmk11.11c';l:$8000;p:$28000;crc:$f1fc5ee1),
        (n:'bmk12.12c';l:$8000;p:$30000;crc:$0f50c001),(n:'bmk13.14c';l:$8000;p:$38000;crc:$fd1acf8e),());
        hw1943kai_tiles1:array[0..8] of tipo_roms=(
        (n:'bmk15.10f';l:$8000;p:0;crc:$6b1a0443),(n:'bmk16.11f';l:$8000;p:$8000;crc:$9416fe0d),
        (n:'bmk17.12f';l:$8000;p:$10000;crc:$3d5acab9),(n:'bmk18.14f';l:$8000;p:$18000;crc:$7b62da1d),
        (n:'bmk19.10j';l:$8000;p:$20000;crc:$868ababc),(n:'bmk20.11j';l:$8000;p:$28000;crc:$b90364c1),
        (n:'bmk21.12j';l:$8000;p:$30000;crc:$8c7fe74a),(n:'bmk22.14j';l:$8000;p:$38000;crc:$d5ef8a0e),());
        hw1943kai_tiles2:array[0..2] of tipo_roms=(
        (n:'bmk24.14k';l:$8000;p:0;crc:$bf186ef2),(n:'bmk25.14l';l:$8000;p:$8000;crc:$a755faf1),());
        hw1943kai_tilesbg_pos:array[0..2] of tipo_roms=(
        (n:'bmk14.5f';l:$8000;p:0;crc:$cf0f5a53),(n:'bmk23.8k';l:$8000;p:$8000;crc:$17f77ef9),());

var
 scroll_y,scroll_bg:word;
 scroll_x,sound_command,rom_bank,sprite3bank:byte;
 bg2on,bg1on,objon,chon,bgpaint,bgpaint2:boolean;
 rom_mem:array[0..7,0..$3fff] of byte;
 tiles_pos:array[0..$ffff] of byte;
 drawvideo_gs_hw:procedure;

procedure Cargar_gunsmokehw;
begin
llamadas_maquina.iniciar:=iniciar_gunsmokehw;
llamadas_maquina.bucle_general:=gunsmokehw_principal;
llamadas_maquina.cerrar:=cerrar_gunsmokehw;
llamadas_maquina.reset:=reset_gunsmokehw;
end;

procedure draw_sprites(pri:boolean);inline;
var
  f,color,nchar,x,y,pos:word;
  atrib:byte;
begin
  for f:=$7f downto 0 do begin
      pos:=f*$20;
  		atrib:=memoria[$f001+pos];
  		nchar:=memoria[$f000+pos]+((atrib and $e0) shl 3);
  		color:=atrib and $f;
  		y:=240-(memoria[$f003+pos]-((atrib and $10) shl 4));
  		x:=memoria[$f002+pos];
  		// the priority is actually selected by bit 3 of BMPROM.07
  		if pri then begin
  			if ((color<>$0a) and (color<>$0b)) then begin
          put_gfx_sprite(nchar,color shl 4,false,false,3);
          actualiza_gfx_sprite(x,y,4,3);
        end;
  		end else begin
  			if ((color=$0a) or (color=$0b)) then begin
  				put_gfx_sprite(nchar,color shl 4,false,false,3);
          actualiza_gfx_sprite(x,y,4,3);
        end;
  		end;
  end; //for
end;

procedure update_video_1943;
var
  f,color,nchar,x,y,pos:word;
  attr:byte;
begin
if bg2on then begin
 if bgpaint2 then begin
  for f:=0 to $47 do begin
     x:=f mod 8;
     y:=f div 8;
     pos:=(x+(y*8)+((scroll_bg and $ffe0) shr 2)) shl 1;
     attr:=tiles_pos[pos+$8001];
     color:=(attr and $3c) shl 2;
     nchar:=tiles_pos[pos+$8000];
     put_gfx_flip(x*32,(15-y)*32,nchar,color,1,2,(attr and $80)<>0,(attr and $40)<>0);
  end;
 end;
 scroll_x_y(1,4,scroll_x,224+(31-(scroll_bg and $1f)));
 bgpaint2:=false;
end else fill_full_screen(4,0);
if objon then draw_sprites(false);
if bg1on then begin
  if bgpaint then begin
    for f:=0 to $47 do begin
     x:=f mod 8;
     y:=f div 8;
     pos:=(x+(y*8)+((scroll_y and $ffe0) div 4))*2;
     attr:=tiles_pos[pos+$1];
     color:=(attr and $3c) shl 2;
     nchar:=tiles_pos[pos]+((attr and $1) shl 8);
     put_gfx_mask_flip(x*32,(15-y)*32,nchar,color,2,1,$f,$ff,(attr and $80)<>0,(attr and $40)<>0);
   end;
  end;
  scroll_x_y(2,4,scroll_x,224+(31-(scroll_y and $1f)));
  bgpaint:=false;
end;
if objon then draw_sprites(true);
if chon then begin //chars activos
  for f:=$3ff downto 0 do begin
    //Chars
    if gfx[0].buffer[f] then begin
      x:=f div 32;
      y:=31-(f mod 32);
      attr:=memoria[f+$d400];
      color:=(attr and $1F) shl 2;
      nchar:=memoria[f+$d000]+((attr and $e0) shl 3);
      put_gfx_trans(x*8,y*8,nchar,color,3,0);
      gfx[0].buffer[f]:=false;
    end;
  end;
  actualiza_trozo(0,0,256,256,3,0,0,256,256,4);
end;
actualiza_trozo_final(16,0,224,256,4);
end;

procedure update_video_gunsmoke;
var
        f,color,nchar:word;
        x,y,pos:word;
        attr,bank:byte;
begin
//Background
if bg1on then begin
 if bgpaint then begin
  for f:=0 to $47 do begin
     x:=f mod 8;
     y:=f div 8;
     pos:=(x+(y*8)+((scroll_y and $ffe0) shr 2)) shl 1;
     attr:=tiles_pos[pos+1];
     color:=(attr and $3c) shl 2;
     nchar:=tiles_pos[pos]+((attr and $1) shl 8);
     put_gfx_flip(x*32,(15-y)*32,nchar,color,2,2,(attr and $80)<>0,(attr and $40)<>0);
  end;
 end;
 bgpaint:=false;
 scroll_x_y(2,1,scroll_x,224+(31-(scroll_y and $1f)));
end else fill_full_screen(2,0);
//Sprites
if objon then begin
  for f:=$7f downto 0 do begin
		attr:=memoria[$f001+(f*32)];
		bank:=(attr and $c0) shr 6;
		nchar:=memoria[$f000+(f*32)];
		color:=(attr and $0f) shl 4;
		y:=240-(memoria[$f003+(f*32)]-((attr and $20) shl 3));
		x:=memoria[$f002+(f*32)];
		if (bank=3) then bank:=bank+sprite3bank;
		nchar:=nchar+(256*bank);
    put_gfx_sprite(nchar,color,(attr and $10)<>0,false,1);
    actualiza_gfx_sprite(x,y,1,1);
  end;
end;
//Chars
if chon then begin
  for f:=$3ff downto 0 do begin
    if gfx[0].buffer[f] then begin
      x:=(f shr 5) shl 3;
      y:=(31-(f and $1f)) shl 3;
      attr:=memoria[f+$d400];
      color:=(attr and $1f) shl 2;
      nchar:=memoria[f+$d000]+((attr and $e0) shl 2);
      put_gfx_mask(x,y,nchar,color,3,0,$4f,$ff);
      gfx[0].buffer[f]:=false;
    end;
  end;
  actualiza_trozo(0,0,256,256,3,0,0,256,256,1);
end;
actualiza_trozo_final(16,0,224,256,1);
end;

function iniciar_gunsmokehw:boolean;
var
      f:word;
      memoria_temp:array[0..$3ffff] of byte;
const
    pc_1943_x:array[0..7] of dword=(0, 1, 2, 3, 8+0, 8+1, 8+2, 8+3);
    pc_1943_y:array[0..7] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16);
    pc_x:array[0..7] of dword=(8+3, 8+2, 8+1, 8+0, 3, 2, 1, 0);
    pc_y:array[0..7] of dword=(7*16, 6*16, 5*16, 4*16, 3*16, 2*16, 1*16, 0*16);
    ps_x:array[0..15] of dword=(0, 1, 2, 3, 8+0, 8+1, 8+2, 8+3,
			32*8+0, 32*8+1, 32*8+2, 32*8+3, 33*8+0, 33*8+1, 33*8+2, 33*8+3);
    ps_y:array[0..15] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16,
			8*16, 9*16, 10*16, 11*16, 12*16, 13*16, 14*16, 15*16);
    pt_x:array[0..31] of dword=(0, 1, 2, 3, 8+0, 8+1, 8+2, 8+3,
			64*8+0, 64*8+1, 64*8+2, 64*8+3, 65*8+0, 65*8+1, 65*8+2, 65*8+3,
			128*8+0, 128*8+1, 128*8+2, 128*8+3, 129*8+0, 129*8+1, 129*8+2, 129*8+3,
			192*8+0, 192*8+1, 192*8+2, 192*8+3, 193*8+0, 193*8+1, 193*8+2, 193*8+3);
    pt_y:array[0..31] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16,
			8*16, 9*16, 10*16, 11*16, 12*16, 13*16, 14*16, 15*16,
			16*16, 17*16, 18*16, 19*16, 20*16, 21*16, 22*16, 23*16,
			24*16, 25*16, 26*16, 27*16, 28*16, 29*16, 30*16, 31*16);
procedure convertir_sprites(ngfx:byte);
begin
init_gfx(ngfx,16,16,2048);
gfx[ngfx].trans[0]:=true;
gfx_set_desc_data(4,0,64*8,2048*64*8+4,2048*64*8+0,4,0);
convert_gfx(ngfx,0,@memoria_temp[0],@ps_x[0],@ps_y[0],false,true);
end;
procedure convertir_tiles(ngfx:byte);
begin
init_gfx(ngfx,32,32,512);
gfx_set_desc_data(4,0,256*8,512*256*8+4,512*256*8+0,4,0);
convert_gfx(ngfx,0,@memoria_temp[0],@pt_x[0],@pt_y[0],false,true);
end;
procedure convert_paleta;
var
  f:byte;
  colores:tpaleta;
begin
for f:=0 to $ff do begin
  colores[f].r:=((memoria_temp[f] and $f) shl 4) or (memoria_temp[f] and $f);
  colores[f].g:=((memoria_temp[f+$100] and $f) shl 4) or (memoria_temp[f+$100] and $f);
  colores[f].b:=((memoria_temp[f+$200] and $f) shl 4) or (memoria_temp[f+$200] and $f);
end;
set_pal(colores,256);
end;
begin
iniciar_gunsmokehw:=false;
iniciar_audio(false);
//Pantallas:  principal+char y sprites
screen_init(3,256,256,true);
case main_vars.tipo_maquina of
  80:begin
      screen_init(1,256,256,false,true);
      screen_init(2,256,512);
      screen_mod_scroll(2,256,256,255,512,256,511);
     end;
  82,83:begin
      screen_init(1,256,512);
      screen_mod_scroll(1,256,256,255,512,256,511);
      screen_init(2,256,512,true);
      screen_mod_scroll(2,256,256,255,512,256,511);
      screen_init(4,256,256,false,true);
      screen_mod_sprites(4,0,512,0,$1ff);
  end;
end;
iniciar_video(224,256);
//Sound CPU
snd_z80:=cpu_z80.create(3000000,256);
snd_z80.change_ram_calls(gunsmoke_snd_getbyte,gunsmoke_snd_putbyte);
init_timer(snd_z80.numero_cpu,3000000/(60*4),gunsmoke_snd_irq,true);
snd_z80.init_sound(gunsmoke_sound_update);
//Sound Chips
ym2203_0:=ym2203_chip.create(0,1500000,2);
ym2203_1:=ym2203_chip.create(1,1500000,2);
case main_vars.tipo_maquina of
  80:begin
       //video
       drawvideo_gs_hw:=update_video_gunsmoke;
       //Main CPU
       main_z80:=cpu_z80.create(4000000,256);
       main_z80.change_ram_calls(gunsmoke_getbyte,gunsmoke_putbyte);
       //cargar roms y ponerlas en su sitio
       if not(cargar_roms(@memoria_temp[0],@gunsmoke_rom[0],'gunsmoke.zip',0)) then exit;
       copymemory(@memoria[0],@memoria_temp[0],$8000);
       for f:=0 to 3 do copymemory(@rom_mem[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
       //cargar ROMS sonido
       if not(cargar_roms(@mem_snd[0],@gunsmoke_snd_rom,'gunsmoke.zip',1)) then exit;
       //convertir chars
       if not(cargar_roms(@memoria_temp[0],@gunsmoke_char,'gunsmoke.zip',1)) then exit;
       init_gfx(0,8,8,1024);
       gfx_set_desc_data(2,0,16*8,4,0);
       convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,true);
       //convertir sprites
       if not(cargar_roms(@memoria_temp[0],@gunsmoke_sprites[0],'gunsmoke.zip',0)) then exit;
       convertir_sprites(1);
       //tiles
       if not(cargar_roms(@memoria_temp[0],@gunsmoke_tiles[0],'gunsmoke.zip',0)) then exit;
       if not(cargar_roms(@tiles_pos[0],@gunsmoke_tiles_pos,'gunsmoke.zip',1)) then exit;
       convertir_tiles(2);
       //poner la paleta y clut
       if not(cargar_roms(@memoria_temp[0],@gunsmoke_pal[0],'gunsmoke.zip',0)) then exit;
       convert_paleta;
       for f:=0 to $ff do begin
          gfx[0].colores[f]:=memoria_temp[$300+f]+$40;  //chars
          gfx[1].colores[f]:=memoria_temp[$600+f]+((memoria_temp[$700+f] and $7) shl 4)+$80;  //sprites
          gfx[2].colores[f]:=memoria_temp[$400+f]+((memoria_temp[$500+f] and $3) shl 4);  //tiles
       end;
  end;
  82:begin
       //video
       drawvideo_gs_hw:=update_video_1943;
       //Main CPU
       main_z80:=cpu_z80.create(6000000,256);
       main_z80.change_ram_calls(hw1943_getbyte,hw1943_putbyte);
       //cargar roms y ponerlas en su sitio
       if not(cargar_roms(@memoria_temp[0],@hw1943_rom[0],'1943.zip',0)) then exit;
       copymemory(@memoria[0],@memoria_temp[0],$8000);
       for f:=0 to 7 do copymemory(@rom_mem[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
       //cargar ROMS sonido
       if not(cargar_roms(@mem_snd[0],@hw1943_snd_rom,'1943.zip',1)) then exit;
       //convertir chars
       if not(cargar_roms(@memoria_temp[0],@hw1943_char,'1943.zip',1)) then exit;
       init_gfx(0,8,8,2048);
       gfx[0].trans[0]:=true;
       gfx_set_desc_data(2,0,16*8,4,0);
       convert_gfx(0,0,@memoria_temp[0],@pc_1943_x[0],@pc_1943_y[0],false,true);
       //convertir tiles 1
       if not(cargar_roms(@tiles_pos[0],@hw1943_tilesbg_pos[0],'1943.zip',0)) then exit;
       if not(cargar_roms(@memoria_temp[0],@hw1943_tiles1,'1943.zip',0)) then exit;
       convertir_tiles(1);
       //cargar y convertir tiles 2
       if not(cargar_roms(@memoria_temp[0],@hw1943_tiles2,'1943.zip',0)) then exit;
       init_gfx(2,32,32,$80);
       gfx_set_desc_data(4,0,256*8,128*256*8+4,128*256*8+0,4,0);
       convert_gfx(2,0,@memoria_temp[0],@pt_x[0],@pt_y[0],false,true);
       //convertir_sprites
       if not(cargar_roms(@memoria_temp[0],@hw1943_sprites[0],'1943.zip',0)) then exit;
       convertir_sprites(3);
       //poner paleta y CLUT
       if not(cargar_roms(@memoria_temp[0],@hw1943_pal[0],'1943.zip',0)) then exit;
       convert_paleta;
       for f:=0 to $ff do begin
          gfx[0].colores[f]:=(memoria_temp[$300+f] and $f)+$40;
          gfx[1].colores[f]:=((memoria_temp[$500+f] and $03) shl 4)+((memoria_temp[$400+f] and $0f) shl 0);
          gfx[2].colores[f]:=((memoria_temp[$700+f] and $03) shl 4)+((memoria_temp[$600+f] and $0f) shl 0);
          gfx[3].colores[f]:=((memoria_temp[$900+f] and $07) shl 4) or ((memoria_temp[$800+f] and $0f) shl 0) or $80;
       end;
     end;
     83:begin
       //video
       drawvideo_gs_hw:=update_video_1943;
       //Main CPU
       main_z80:=cpu_z80.create(6000000,256);
       main_z80.change_ram_calls(hw1943_getbyte,hw1943_putbyte);
       //cargar roms y ponerlas en su sitio
       if not(cargar_roms(@memoria_temp[0],@hw1943kai_rom[0],'1943kai.zip',0)) then exit;
       copymemory(@memoria[0],@memoria_temp[0],$8000);
       for f:=0 to 7 do copymemory(@rom_mem[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
       //cargar ROMS sonido
       if not(cargar_roms(@mem_snd[0],@hw1943kai_snd_rom,'1943kai.zip',1)) then exit;
       //convertir chars
       if not(cargar_roms(@memoria_temp[0],@hw1943kai_char,'1943kai.zip',1)) then exit;
       init_gfx(0,8,8,2048);
       gfx[0].trans[0]:=true;
       gfx_set_desc_data(2,0,16*8,4,0);
       convert_gfx(0,0,@memoria_temp[0],@pc_1943_x[0],@pc_1943_y[0],false,true);
       //convertir tiles 1
       if not(cargar_roms(@tiles_pos[0],@hw1943kai_tilesbg_pos[0],'1943kai.zip',0)) then exit;
       if not(cargar_roms(@memoria_temp[0],@hw1943kai_tiles1,'1943kai.zip',0)) then exit;
       convertir_tiles(1);
       //cargar y convertir tiles 2
       if not(cargar_roms(@memoria_temp[0],@hw1943kai_tiles2,'1943kai.zip',0)) then exit;
       init_gfx(2,32,32,$80);
       gfx_set_desc_data(4,0,256*8,128*256*8+4,128*256*8+0,4,0);
       convert_gfx(2,0,@memoria_temp[0],@pt_x[0],@pt_y[0],false,true);
       //convertir_sprites
       if not(cargar_roms(@memoria_temp[0],@hw1943kai_sprites[0],'1943kai.zip',0)) then exit;
       convertir_sprites(3);
       //poner paleta y CLUT
       if not(cargar_roms(@memoria_temp[0],@hw1943kai_pal[0],'1943kai.zip',0)) then exit;
       convert_paleta;
       for f:=0 to $ff do begin
          gfx[0].colores[f]:=(memoria_temp[$300+f] and $f)+$40;
          gfx[1].colores[f]:=((memoria_temp[$500+f] and $03) shl 4)+((memoria_temp[$400+f] and $0f) shl 0);
          gfx[2].colores[f]:=((memoria_temp[$700+f] and $03) shl 4)+((memoria_temp[$600+f] and $0f) shl 0);
          gfx[3].colores[f]:=((memoria_temp[$900+f] and $07) shl 4) or ((memoria_temp[$800+f] and $0f) shl 0) or $80;
       end;
     end;
end;
//final
reset_gunsmokehw;
iniciar_gunsmokehw:=true;
end;

procedure cerrar_gunsmokehw;
begin
main_z80.free;
snd_z80.free;
YM2203_0.Free;
YM2203_1.Free;
close_audio;
close_video;
end;

procedure reset_gunsmokehw;
begin
 main_z80.reset;
 snd_z80.reset;
 YM2203_0.reset;
 YM2203_1.reset;
 reset_audio;
 marcade.in0:=$FF;
 marcade.in1:=$FF;
 marcade.in2:=$ff;
 scroll_x:=1;
 scroll_y:=0;
 scroll_bg:=0;
 bg2on:=true;
 bg1on:=true;
 objon:=true;
 bgpaint:=true;
 bgpaint2:=true;
 rom_bank:=0;
 sprite3bank:=0;
 sound_command:=0;
end;

procedure eventos_gunsmokehw;inline;
begin
if event.arcade then begin
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $F7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.but2[0] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $F7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
end;
end;

procedure gunsmokehw_principal;
var
  f:byte;
  frame_m,frame_s:single;
begin
init_controls(false,false,false,true);
frame_m:=main_z80.tframes;
frame_s:=snd_z80.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
    //Main CPU
    main_z80.run(frame_m);
    frame_m:=frame_m+main_z80.tframes-main_z80.contador;
    //Sound CPU
    snd_z80.run(frame_s);
    frame_s:=frame_s+snd_z80.tframes-snd_z80.contador;
    if f=239 then begin
      main_z80.pedir_irq:=HOLD_LINE;
      drawvideo_gs_hw;
    end;
  end;
  eventos_gunsmokehw;
  video_sync;
end;
end;

function gunsmoke_snd_getbyte(direccion:word):byte;
begin
if direccion=$c800 then gunsmoke_snd_getbyte:=sound_command
 else gunsmoke_snd_getbyte:=mem_snd[direccion];
end;

procedure gunsmoke_snd_putbyte(direccion:word;valor:byte);
begin
if direccion<$8000 then exit;
mem_snd[direccion]:=valor;
case direccion of
  $e000:ym2203_0.Control(valor);
  $e001:ym2203_0.Write_Reg(valor);
  $e002:ym2203_1.Control(valor);
  $e003:ym2203_1.Write_Reg(valor);
end;
end;

function gunsmoke_getbyte(direccion:word):byte;
begin
case direccion of
  $8000..$bfff:gunsmoke_getbyte:=rom_mem[rom_bank,direccion and $3fff];
  $c000:gunsmoke_getbyte:=marcade.in0;
  $c001:gunsmoke_getbyte:=marcade.in1;
  $c002:gunsmoke_getbyte:=$ff;
  $c003:gunsmoke_getbyte:=$f7;
  $c004:gunsmoke_getbyte:=$ff;
  $c4c9:gunsmoke_getbyte:=$ff; //Proteccion 1???
  $c4ca:gunsmoke_getbyte:=$00; //Proteccion 2???
  $c4cb:gunsmoke_getbyte:=$00; //Proteccion 3???
    else gunsmoke_getbyte:=memoria[direccion];
end;
end;

procedure gunsmoke_putbyte(direccion:word;valor:byte);
begin
if direccion<$c000 then exit;
memoria[direccion]:=valor;
case direccion of
  $c800:sound_command:=valor;
  $c804:begin
          rom_bank:=(valor and $0c) shr 2;
          chon:=(valor and $80)<>0;
        end;
  $d000..$d7ff:gfx[0].buffer[direccion and $3ff]:=true;
  $d800:if (scroll_y and $ff)<>valor then begin
            if abs((scroll_y and $e0)-(valor and $e0))>31 then bgpaint:=true;
            scroll_y:=(scroll_y and $ff00) or valor;
        end;
  $d801:if (scroll_y shr 8)<>valor then begin
            scroll_y:=(scroll_y and $00ff) or (valor shl 8);
            bgpaint:=true;
        end;
  $d802:if scroll_x<>valor then begin
          scroll_x:=valor;
          bgpaint:=true;
        end;
  $d803:;
  $d806:begin
            sprite3bank:=valor and $07;
            bg1on:=(valor and $10)<>0;
            objon:=(valor and $20)<>0;
        end;
end;
end;

function hw1943_getbyte(direccion:word):byte;
var
  main_z80_reg:npreg_z80;
begin
case direccion of
  $8000..$bfff:hw1943_getbyte:=rom_mem[rom_bank,direccion and $3fff];
  $c000:hw1943_getbyte:=marcade.in0;
  $c001:hw1943_getbyte:=marcade.in1;
  $c002:hw1943_getbyte:=marcade.in2;
  $c003:hw1943_getbyte:=$f8;
  $c004:hw1943_getbyte:=$ff;
  $c007:begin
          main_z80_reg:=main_z80.get_internal_r;
          hw1943_getbyte:=main_z80_reg.bc.h;
        end;
    else hw1943_getbyte:=memoria[direccion];
end;
end;

procedure hw1943_putbyte(direccion:word;valor:byte);
begin
if direccion<$c000 then exit;
memoria[direccion]:=valor;
case direccion of
        $c800:sound_command:=valor;
        $c804:begin
                chon:=(valor and $80)<>0;
                rom_bank:=(valor shr 2) and $7;
              end;
        $d000..$d7ff:gfx[0].buffer[direccion and $3ff]:=true;
        $d800:if (scroll_y and $ff)<>valor then begin
                if abs((scroll_y and $e0)-(valor and $e0))>31 then bgpaint:=true;
                scroll_y:=(scroll_y and $ff00) or valor;
              end;
        $d801:if (scroll_y shr 8)<>valor then begin
                scroll_y:=(scroll_y and $ff) or (valor shl 8);
                bgpaint:=true;
              end;
        $d802:if scroll_x<>valor then begin
                scroll_x:=valor;
                bgpaint:=true;
              end;
        $d803:;
        $d804:if (scroll_bg and $ff)<>valor then begin
                if abs((scroll_bg and $e0)-(valor and $e0))>31 then bgpaint2:=true;
                scroll_bg:=(scroll_bg and $ff00) or valor;
              end;
        $d805:if (scroll_bg shr 8)<>valor then begin
                scroll_bg:=(scroll_bg and $ff) or (valor shl 8);
                bgpaint2:=true;
              end;
        $d806:begin
                bg1on:=(valor and $10)<>0;
                bg2on:=(valor and $20)<>0;
                objon:=(valor and $40)<>0;
              end;
end;
end;

procedure gunsmoke_snd_irq;
begin
  snd_z80.pedir_irq:=HOLD_LINE;
end;

procedure gunsmoke_sound_update;
begin
  ym2203_0.Update;
  ym2203_1.Update;
end;

end.
