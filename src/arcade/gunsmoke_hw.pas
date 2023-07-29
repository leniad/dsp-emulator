unit gunsmoke_hw;

interface

uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,ym_2203,gfx_engine,timer_engine,rom_engine,
     pal_engine,sound_engine,mcs51;

function iniciar_gunsmokehw:boolean;

implementation
const
        //Gun Smoke
        gunsmoke_rom:array[0..2] of tipo_roms=(
        (n:'09n_gs03.bin';l:$8000;p:0;crc:$40a06cef),(n:'10n_gs04.bin';l:$8000;p:$8000;crc:$8d4b423f),
        (n:'12n_gs05.bin';l:$8000;p:$10000;crc:$2b5667fb));
        gunsmoke_rom_snd:tipo_roms=(n:'14h_gs02.bin';l:$8000;p:0;crc:$cd7a2c38);
        gunsmoke_pal:array[0..7] of tipo_roms=(
        (n:'03b_g-01.bin';l:$100;p:0;crc:$02f55589),(n:'04b_g-02.bin';l:$100;p:$100;crc:$e1e36dd9),
        (n:'05b_g-03.bin';l:$100;p:$200;crc:$989399c0),(n:'09d_g-04.bin';l:$100;p:$300;crc:$906612b5),
        (n:'14a_g-06.bin';l:$100;p:$400;crc:$4a9da18b),(n:'15a_g-07.bin';l:$100;p:$500;crc:$cb9394fc),
        (n:'09f_g-09.bin';l:$100;p:$600;crc:$3cee181e),(n:'08f_g-08.bin';l:$100;p:$700;crc:$ef91cdd2));
        gunsmoke_char:tipo_roms=(n:'11f_gs01.bin';l:$4000;p:0;crc:$b61ece9b);
        gunsmoke_sprites:array[0..7] of tipo_roms=(
        (n:'06n_gs22.bin';l:$8000;p:0;crc:$dc9c508c),(n:'04n_gs21.bin';l:$8000;p:$8000;crc:$68883749),
        (n:'03n_gs20.bin';l:$8000;p:$10000;crc:$0be932ed),(n:'01n_gs19.bin';l:$8000;p:$18000;crc:$63072f93),
        (n:'06l_gs18.bin';l:$8000;p:$20000;crc:$f69a3c7c),(n:'04l_gs17.bin';l:$8000;p:$28000;crc:$4e98562a),
        (n:'03l_gs16.bin';l:$8000;p:$30000;crc:$0d99c3b3),(n:'01l_gs15.bin';l:$8000;p:$38000;crc:$7f14270e));
        gunsmoke_tiles:array[0..7] of tipo_roms=(
        (n:'06c_gs13.bin';l:$8000;p:0;crc:$f6769fc5),(n:'05c_gs12.bin';l:$8000;p:$8000;crc:$d997b78c),
        (n:'04c_gs11.bin';l:$8000;p:$10000;crc:$125ba58e),(n:'02c_gs10.bin';l:$8000;p:$18000;crc:$f469c13c),
        (n:'06a_gs09.bin';l:$8000;p:$20000;crc:$539f182d),(n:'05a_gs08.bin';l:$8000;p:$28000;crc:$e87e526d),
        (n:'04a_gs07.bin';l:$8000;p:$30000;crc:$4382c0d2),(n:'02a_gs06.bin';l:$8000;p:$38000;crc:$4cafe7a6));
        gunsmoke_tiles_pos:tipo_roms=(n:'11c_gs14.bin';l:$8000;p:0;crc:$0af4f7eb);
        //Dip
        gunsmoke_dip_a:array [0..5] of def_dip=(
        (mask:$3;name:'Bonus Life';number:4;dip:((dip_val:$1;dip_name:'30K 80K 80K+'),(dip_val:$3;dip_name:'30K 100K 100K+'),(dip_val:$0;dip_name:'30K 100K 150K+'),(dip_val:$2;dip_name:'30K 100K'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Demo';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$4;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$8;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Difficult';number:4;dip:((dip_val:$20;dip_name:'Easy'),(dip_val:$30;dip_name:'Normal'),(dip_val:$10;dip_name:'Difficult'),(dip_val:$0;dip_name:'Very Difficult'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Freeze';number:2;dip:((dip_val:$40;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        gunsmoke_dip_b:array [0..4] of def_dip=(
        (mask:$7;name:'Coin A';number:8;dip:((dip_val:$0;dip_name:'4C 1C'),(dip_val:$1;dip_name:'3C 1C'),(dip_val:$2;dip_name:'2C 1C'),(dip_val:$7;dip_name:'1C 1C'),(dip_val:$6;dip_name:'1C 2C'),(dip_val:$5;dip_name:'1C 3C'),(dip_val:$4;dip_name:'1C 4C'),(dip_val:$3;dip_name:'1C 5C'),(),(),(),(),(),(),(),())),
        (mask:$38;name:'Coin B';number:8;dip:((dip_val:$0;dip_name:'4C 1C'),(dip_val:$8;dip_name:'3C 1C'),(dip_val:$10;dip_name:'2C 1C'),(dip_val:$38;dip_name:'1C 1C'),(dip_val:$30;dip_name:'1C 2C'),(dip_val:$28;dip_name:'1C 3C'),(dip_val:$20;dip_name:'1C 4C'),(dip_val:$18;dip_name:'1C 5C'),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Allow Continue';number:2;dip:((dip_val:$0;dip_name:'No'),(dip_val:$40;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$80;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        //1943
        hw1943_rom:array[0..2] of tipo_roms=(
        (n:'bmu01c.12d';l:$8000;p:0;crc:$c686cc5c),(n:'bmu02c.13d';l:$10000;p:$8000;crc:$d8880a41),
        (n:'bmu03c.14d';l:$10000;p:$18000;crc:$3f0ee26c));
        hw1943_snd_rom:tipo_roms=(n:'bm04.5h';l:$8000;p:0;crc:$ee2bd2d7);
        hw1943_mcu:tipo_roms=(n:'bm.7k';l:$1000;p:0;crc:$cf4781bf);
        hw1943_pal:array[0..9] of tipo_roms=(
        (n:'bm1.12a';l:$100;p:0;crc:$74421f18),(n:'bm2.13a';l:$100;p:$100;crc:$ac27541f),
        (n:'bm3.14a';l:$100;p:$200;crc:$251fb6ff),(n:'bm5.7f';l:$100;p:$300;crc:$206713d0),
        (n:'bm10.7l';l:$100;p:$400;crc:$33c2491c),(n:'bm9.6l';l:$100;p:$500;crc:$aeea4af7),
        (n:'bm12.12m';l:$100;p:$600;crc:$c18aa136),(n:'bm11.12l';l:$100;p:$700;crc:$405aae37),
        (n:'bm8.8c';l:$100;p:$800;crc:$c2010a9e),(n:'bm7.7c';l:$100;p:$900;crc:$b56f30c3));
        hw1943_char:tipo_roms=(n:'bm05.4k';l:$8000;p:0;crc:$46cb9d3d);
        hw1943_sprites:array[0..7] of tipo_roms=(
        (n:'bm06.10a';l:$8000;p:0;crc:$97acc8af),(n:'bm07.11a';l:$8000;p:$8000;crc:$d78f7197),
        (n:'bm08.12a';l:$8000;p:$10000;crc:$1a626608),(n:'bm09.14a';l:$8000;p:$18000;crc:$92408400),
        (n:'bm10.10c';l:$8000;p:$20000;crc:$8438a44a),(n:'bm11.11c';l:$8000;p:$28000;crc:$6c69351d),
        (n:'bm12.12c';l:$8000;p:$30000;crc:$5e7efdb7),(n:'bm13.14c';l:$8000;p:$38000;crc:$1143829a));
        hw1943_tiles1:array[0..7] of tipo_roms=(
        (n:'bm15.10f';l:$8000;p:0;crc:$6b1a0443),(n:'bm16.11f';l:$8000;p:$8000;crc:$23c908c2),
        (n:'bm17.12f';l:$8000;p:$10000;crc:$46bcdd07),(n:'bm18.14f';l:$8000;p:$18000;crc:$e6ae7ba0),
        (n:'bm19.10j';l:$8000;p:$20000;crc:$868ababc),(n:'bm20.11j';l:$8000;p:$28000;crc:$0917e5d4),
        (n:'bm21.12j';l:$8000;p:$30000;crc:$9bfb0d89),(n:'bm22.14j';l:$8000;p:$38000;crc:$04f3c274));
        hw1943_tiles2:array[0..1] of tipo_roms=(
        (n:'bm24.14k';l:$8000;p:0;crc:$11134036),(n:'bm25.14l';l:$8000;p:$8000;crc:$092cf9c1));
        hw1943_tilesbg_pos:array[0..1] of tipo_roms=(
        (n:'bm14.5f';l:$8000;p:0;crc:$4d3c6401),(n:'bm23.8k';l:$8000;p:$8000;crc:$a52aecbd));
        //1943 kai
        hw1943kai_rom:array[0..2] of tipo_roms=(
        (n:'bmk01.12d';l:$8000;p:0;crc:$7d2211db),(n:'bmk02.13d';l:$10000;p:$8000;crc:$2ebbc8c5),
        (n:'bmk03.14d';l:$10000;p:$18000;crc:$475a6ac5));
        hw1943kai_snd_rom:tipo_roms=(n:'bmk04.5h';l:$8000;p:0;crc:$25f37957);
        hw1943kai_pal:array[0..9] of tipo_roms=(
        (n:'bmk1.12a';l:$100;p:0;crc:$e001ea33),(n:'bmk2.13a';l:$100;p:$100;crc:$af34d91a),
        (n:'bmk3.14a';l:$100;p:$200;crc:$43e9f6ef),(n:'bmk5.7f';l:$100;p:$300;crc:$41878934),
        (n:'bmk10.7l';l:$100;p:$400;crc:$de44b748),(n:'bmk9.6l';l:$100;p:$500;crc:$59ea57c0),
        (n:'bmk12.12m';l:$100;p:$600;crc:$8765f8b0),(n:'bmk11.12l';l:$100;p:$700;crc:$87a8854e),
        (n:'bmk8.8c';l:$100;p:$800;crc:$dad17e2d),(n:'bmk7.7c';l:$100;p:$900;crc:$76307f8d));
        hw1943kai_char:tipo_roms=(n:'bmk05.4k';l:$8000;p:0;crc:$884a8692);
        hw1943kai_sprites:array[0..7] of tipo_roms=(
        (n:'bmk06.10a';l:$8000;p:0;crc:$5f7e38b3),(n:'bmk07.11a';l:$8000;p:$8000;crc:$ff3751fd),
        (n:'bmk08.12a';l:$8000;p:$10000;crc:$159d51bd),(n:'bmk09.14a';l:$8000;p:$18000;crc:$8683e3d2),
        (n:'bmk10.10c';l:$8000;p:$20000;crc:$1e0d9571),(n:'bmk11.11c';l:$8000;p:$28000;crc:$f1fc5ee1),
        (n:'bmk12.12c';l:$8000;p:$30000;crc:$0f50c001),(n:'bmk13.14c';l:$8000;p:$38000;crc:$fd1acf8e));
        hw1943kai_tiles1:array[0..7] of tipo_roms=(
        (n:'bmk15.10f';l:$8000;p:0;crc:$6b1a0443),(n:'bmk16.11f';l:$8000;p:$8000;crc:$9416fe0d),
        (n:'bmk17.12f';l:$8000;p:$10000;crc:$3d5acab9),(n:'bmk18.14f';l:$8000;p:$18000;crc:$7b62da1d),
        (n:'bmk19.10j';l:$8000;p:$20000;crc:$868ababc),(n:'bmk20.11j';l:$8000;p:$28000;crc:$b90364c1),
        (n:'bmk21.12j';l:$8000;p:$30000;crc:$8c7fe74a),(n:'bmk22.14j';l:$8000;p:$38000;crc:$d5ef8a0e));
        hw1943kai_tiles2:array[0..1] of tipo_roms=(
        (n:'bmk24.14k';l:$8000;p:0;crc:$bf186ef2),(n:'bmk25.14l';l:$8000;p:$8000;crc:$a755faf1));
        hw1943kai_tilesbg_pos:array[0..1] of tipo_roms=(
        (n:'bmk14.5f';l:$8000;p:0;crc:$cf0f5a53),(n:'bmk23.8k';l:$8000;p:$8000;crc:$17f77ef9));
        //Dip
        hw1943_dip_a:array [0..4] of def_dip=(
        (mask:$f;name:'Difficulty';number:16;dip:((dip_val:$f;dip_name:'1 (Easy)'),(dip_val:$e;dip_name:'2'),(dip_val:$d;dip_name:'3'),(dip_val:$c;dip_name:'4'),(dip_val:$b;dip_name:'5'),(dip_val:$a;dip_name:'6'),(dip_val:$9;dip_name:'7'),(dip_val:$8;dip_name:'8 (Normal)'),(dip_val:$7;dip_name:'9'),(dip_val:$6;dip_name:'10'),(dip_val:$5;dip_name:'11'),(dip_val:$4;dip_name:'12'),(dip_val:$3;dip_name:'13'),(dip_val:$2;dip_name:'14'),(dip_val:$1;dip_name:'15'),(dip_val:$0;dip_name:'16 (Difficult)'))),
        (mask:$10;name:'2 Player Game';number:2;dip:((dip_val:$0;dip_name:'1 Credit/2 Players'),(dip_val:$10;dip_name:'2 Credits/2 Players'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Cabinet';number:2;dip:((dip_val:$20;dip_name:'Upright'),(dip_val:$0;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Screen Stop';number:2;dip:((dip_val:$40;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 linea,scroll_y,scroll_bg:word;
 scroll_x,sound_command,rom_bank,sprite3bank:byte;
 bg2on,bg1on,objon,chon,bgpaint,bgpaint2:boolean;
 rom_mem:array[0..7,0..$3fff] of byte;
 tiles_pos:array[0..$ffff] of byte;
 //MCU
 cpu_to_mcu,mcu_p0,audiocpu_to_mcu,mcu_p2,mcu_p3,mcu_to_cpu,mcu_to_audiocpu:byte;

procedure draw_sprites(pri:boolean);
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
  bgpaint2:=false;
 end;
 scroll_x_y(1,4,scroll_x,224+(31-(scroll_bg and $1f)));
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
   bgpaint:=false;
  end;
  scroll_x_y(2,4,scroll_x,224+(31-(scroll_y and $1f)));
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
  f,color,nchar,x,y,pos:word;
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
		attr:=buffer_sprites[$1+(f*32)];
		bank:=(attr and $c0) shr 6;
		nchar:=buffer_sprites[$0+(f*32)];
		color:=(attr and $0f) shl 4;
		y:=240-(buffer_sprites[$3+(f*32)]-((attr and $20) shl 3));
		x:=buffer_sprites[$2+(f*32)];
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

procedure eventos_gunsmokehw;
begin
if event.arcade then begin
  //P1
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.but2[0] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  //P2
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.but2[1] then marcade.in2:=(marcade.in2 and $bf) else marcade.in2:=(marcade.in2 or $40);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
  //System
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
end;
end;

procedure gunsmokehw_principal;
var
  f:word;
  frame_m,frame_s:single;
begin
init_controls(false,false,false,true);
frame_m:=z80_0.tframes;
frame_s:=z80_1.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to 261 do begin
    //Main CPU
    z80_0.run(frame_m);
    frame_m:=frame_m+z80_0.tframes-z80_0.contador;
    //Sound CPU
    z80_1.run(frame_s);
    frame_s:=frame_s+z80_1.tframes-z80_1.contador;
    if f=239 then begin
      z80_0.change_irq(HOLD_LINE);
      update_video_gunsmoke;
    end;
  end;
  eventos_gunsmokehw;
  video_sync;
end;
end;

//Gun.Smoke
function gunsmoke_getbyte(direccion:word):byte;
const
  prot:array[1..3] of byte=($ff,0,0);
begin
case direccion of
  0..$7fff,$d000..$d7ff,$e000..$ffff:gunsmoke_getbyte:=memoria[direccion];
  $8000..$bfff:gunsmoke_getbyte:=rom_mem[rom_bank,direccion and $3fff];
  $c000:gunsmoke_getbyte:=marcade.in0;
  $c001:gunsmoke_getbyte:=marcade.in1;
  $c002:gunsmoke_getbyte:=marcade.in2;
  $c003:gunsmoke_getbyte:=marcade.dswa;
  $c004:gunsmoke_getbyte:=marcade.dswb;
  $c4c9..$c4cb:gunsmoke_getbyte:=prot[direccion and $3]; //Proteccion
end;
end;

procedure gunsmoke_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$bfff:;
  $c800:sound_command:=valor;
  $c804:begin
          rom_bank:=(valor and $0c) shr 2;
          z80_1.change_reset((valor and $20) shr 5);
          main_screen.flip_main_screen:=(valor and $40)<>0;
          chon:=(valor and $80)<>0;
        end;
  $c806:if (valor and $40)<>0 then begin
          copymemory(@buffer_sprites,@memoria[$f000],$1000);
          z80_0.contador:=z80_0.contador+393; //131us
        end;
  $d000..$d7ff:if memoria[direccion]<>valor then begin
                  gfx[0].buffer[direccion and $3ff]:=true;
                  memoria[direccion]:=valor;
               end;
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
  $d806:begin
            sprite3bank:=valor and $07;
            bg1on:=(valor and $10)<>0;
            objon:=(valor and $20)<>0;
        end;
  $e000..$ffff:memoria[direccion]:=valor;
end;
end;

function gunsmoke_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff,$c000..$c7ff:gunsmoke_snd_getbyte:=mem_snd[direccion];
  $c800:gunsmoke_snd_getbyte:=sound_command
end;
end;

procedure gunsmoke_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:;
  $c000..$c7ff:mem_snd[direccion]:=valor;
  $e000:ym2203_0.Control(valor);
  $e001:ym2203_0.Write(valor);
  $e002:ym2203_1.Control(valor);
  $e003:ym2203_1.Write(valor);
end;
end;

//1943HW
procedure hw1943_principal;
var
  frame_m,frame_s,frame_mcu:single;
begin
init_controls(false,false,false,true);
frame_m:=z80_0.tframes;
frame_s:=z80_1.tframes;
frame_mcu:=mcs51_0.tframes;
while EmuStatus=EsRuning do begin
  for linea:=0 to 261 do begin
    //Main CPU
    z80_0.run(frame_m);
    frame_m:=frame_m+z80_0.tframes-z80_0.contador;
    //Sound CPU
    z80_1.run(frame_s);
    frame_s:=frame_s+z80_1.tframes-z80_1.contador;
    //mcu
    mcs51_0.run(frame_mcu);
    frame_mcu:=frame_mcu+mcs51_0.tframes-mcs51_0.contador;
    if linea=239 then begin
      z80_0.change_irq(HOLD_LINE);
      mcs51_0.change_irq1(HOLD_LINE);
      update_video_1943;
    end;
  end;
  eventos_gunsmokehw;
  video_sync;
end;
end;

function hw1943_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff,$d000..$d7ff,$e000..$ffff:hw1943_getbyte:=memoria[direccion];
  $8000..$bfff:hw1943_getbyte:=rom_mem[rom_bank,direccion and $3fff];
  $c000:hw1943_getbyte:=marcade.in0;
  $c001:hw1943_getbyte:=marcade.in1;
  $c002:hw1943_getbyte:=marcade.in2;
  $c003:hw1943_getbyte:=marcade.dswa;
  $c004:hw1943_getbyte:=marcade.dswb;
  $c007:hw1943_getbyte:=mcu_to_cpu;
end;
end;

procedure hw1943_putbyte(direccion:word;valor:byte);
begin
case direccion of
        0..$bfff:;
        $c800:sound_command:=valor;
        $c804:begin
                rom_bank:=(valor shr 2) and $7;
                z80_1.change_reset((valor and $20) shr 5);
                main_screen.flip_main_screen:=(valor and $40)<>0;
                chon:=(valor and $80)<>0;
              end;
        $c807:cpu_to_mcu:=valor;
        $d000..$d7ff:if memoria[direccion]<>valor then begin
                        gfx[0].buffer[direccion and $3ff]:=true;
                        memoria[direccion]:=valor;
                     end;
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
        $d803:if (scroll_bg and $ff)<>valor then begin
                if abs((scroll_bg and $e0)-(valor and $e0))>31 then bgpaint2:=true;
                scroll_bg:=(scroll_bg and $ff00) or valor;
              end;
        $d804:if (scroll_bg shr 8)<>valor then begin
                scroll_bg:=(scroll_bg and $ff) or (valor shl 8);
                bgpaint2:=true;
              end;
        $d806:begin
                bg1on:=(valor and $10)<>0;
                bg2on:=(valor and $20)<>0;
                objon:=(valor and $40)<>0;
              end;
        $e000..$ffff:memoria[direccion]:=valor;
end;
end;

function hw1943_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff,$c000..$c7ff:hw1943_snd_getbyte:=mem_snd[direccion];
  $c800:hw1943_snd_getbyte:=sound_command;
  $d800:hw1943_snd_getbyte:=mcu_to_audiocpu;
end;
end;

procedure hw1943_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:;
  $c000..$c7ff:mem_snd[direccion]:=valor;
  $d800:audiocpu_to_mcu:=valor;
  $e000:ym2203_0.Control(valor);
  $e001:ym2203_0.Write(valor);
  $e002:ym2203_1.Control(valor);
  $e003:ym2203_1.Write(valor);
end;
end;

function in_port0:byte;
begin
  in_port0:=cpu_to_mcu;
end;

function in_port1:byte;
begin
  in_port1:=linea;
end;

function in_port2:byte;
begin
  in_port2:=audiocpu_to_mcu;
end;

procedure out_port0(valor:byte);
begin
  mcu_p0:=valor;
end;

procedure out_port2(valor:byte);
begin
  mcu_p2:=valor;
end;

procedure out_port3(valor:byte);
begin
  if (((mcu_p3 and $40)<>0) and ((valor and $40)=0)) then begin
		mcu_to_cpu:=mcu_p0;
		mcu_to_audiocpu:=mcu_p2;
  end;
	mcu_p3:=valor;
end;

procedure gunsmoke_snd_irq;
begin
  z80_1.change_irq(HOLD_LINE);
end;

procedure gunsmoke_sound_update;
begin
  ym2203_0.Update;
  ym2203_1.Update;
end;

//Main
procedure reset_gunsmokehw;
begin
 z80_0.reset;
 z80_1.reset;
 if main_vars.tipo_maquina<>80 then begin
    mcs51_0.reset;
    cpu_to_mcu:=0;
    mcu_p0:=0;
    audiocpu_to_mcu:=0;
    mcu_p2:=0;
    mcu_p3:=0;
    mcu_to_cpu:=0;
    mcu_to_audiocpu:=0;
 end;
 YM2203_0.reset;
 YM2203_1.reset;
 reset_audio;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
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

function iniciar_gunsmokehw:boolean;
var
  f:byte;
  memoria_temp:array[0..$3ffff] of byte;
  colores:tpaleta;
const
    pc_x:array[0..7] of dword=(8+3, 8+2, 8+1, 8+0, 3, 2, 1, 0);
    pc_y:array[0..7] of dword=(7*16, 6*16, 5*16, 4*16, 3*16, 2*16, 1*16, 0*16);
    ps_x:array[0..15] of dword=(0, 1, 2, 3, 8+0, 8+1, 8+2, 8+3,
			32*8+0, 32*8+1, 32*8+2, 32*8+3, 33*8+0, 33*8+1, 33*8+2, 33*8+3);
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
convert_gfx(ngfx,0,@memoria_temp,@ps_x,@pt_y,false,true);
end;
procedure convertir_tiles(ngfx:byte);
begin
init_gfx(ngfx,32,32,512);
gfx_set_desc_data(4,0,256*8,512*256*8+4,512*256*8+0,4,0);
convert_gfx(ngfx,0,@memoria_temp,@pt_x,@pt_y,false,true);
end;
begin
iniciar_gunsmokehw:=false;
llamadas_maquina.fps_max:=12000000/2/384/262;
iniciar_audio(false);
screen_init(3,256,256,true);
llamadas_maquina.reset:=reset_gunsmokehw;
case main_vars.tipo_maquina of
  80:begin
      screen_init(1,256,512,false,true);
      screen_init(2,256,512);
      screen_mod_scroll(2,256,256,255,512,256,511);
      llamadas_maquina.bucle_general:=gunsmokehw_principal;
      llamadas_maquina.fps_max:=59.63;
     end;
  82,83:begin
      screen_init(1,256,512);
      screen_mod_scroll(1,256,256,255,512,256,511);
      screen_init(2,256,512,true);
      screen_mod_scroll(2,256,256,255,512,256,511);
      screen_init(4,256,512,false,true);
      llamadas_maquina.bucle_general:=hw1943_principal;
  end;
end;
iniciar_video(224,256);
//Sound CPU
z80_1:=cpu_z80.create(3000000,262);
//El ultimo divisor de 2 lo pongo para ajustarlo al reloj de la CPU de sonido
timers.init(z80_1.numero_cpu,384*262/4/2,gunsmoke_snd_irq,nil,true);
z80_1.init_sound(gunsmoke_sound_update);
//Sound Chips
ym2203_0:=ym2203_chip.create(1500000,0.14,0.22);
ym2203_1:=ym2203_chip.create(1500000,0.14,0.22);
case main_vars.tipo_maquina of
  80:begin
       //Main CPU
       z80_0:=cpu_z80.create(3000000,262);
       z80_0.change_ram_calls(gunsmoke_getbyte,gunsmoke_putbyte);
       //cargar roms y ponerlas en su sitio
       if not(roms_load(@memoria_temp,gunsmoke_rom)) then exit;
       copymemory(@memoria,@memoria_temp,$8000);
       for f:=0 to 3 do copymemory(@rom_mem[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
       //cargar ROMS sonido
       z80_1.change_ram_calls(gunsmoke_snd_getbyte,gunsmoke_snd_putbyte);
       if not(roms_load(@mem_snd,gunsmoke_rom_snd)) then exit;
       //convertir chars
       if not(roms_load(@memoria_temp,gunsmoke_char)) then exit;
       init_gfx(0,8,8,1024);
       gfx_set_desc_data(2,0,16*8,4,0);
       convert_gfx(0,0,@memoria_temp,@pc_x,@pc_y,false,true);
       //convertir sprites
       if not(roms_load(@memoria_temp,gunsmoke_sprites)) then exit;
       convertir_sprites(1);
       //tiles
       if not(roms_load(@memoria_temp,gunsmoke_tiles)) then exit;
       if not(roms_load(@tiles_pos,gunsmoke_tiles_pos)) then exit;
       convertir_tiles(2);
       //DIP
       marcade.dswa:=$f7;
       marcade.dswb:=$ff;
       marcade.dswa_val:=@gunsmoke_dip_a;
       marcade.dswb_val:=@gunsmoke_dip_b;
       //clut
       if not(roms_load(@memoria_temp,gunsmoke_pal)) then exit;
       for f:=0 to $ff do begin
          gfx[0].colores[f]:=memoria_temp[$300+f]+$40;  //chars
          gfx[1].colores[f]:=memoria_temp[$600+f]+((memoria_temp[$700+f] and $7) shl 4)+$80;  //sprites
          gfx[2].colores[f]:=memoria_temp[$400+f]+((memoria_temp[$500+f] and $3) shl 4);  //tiles
       end;
  end;
  82:begin
       //Main CPU
       z80_0:=cpu_z80.create(6000000,262);
       z80_0.change_ram_calls(hw1943_getbyte,hw1943_putbyte);
       //cargar roms y ponerlas en su sitio
       if not(roms_load(@memoria_temp,hw1943_rom)) then exit;
       copymemory(@memoria,@memoria_temp,$8000);
       for f:=0 to 7 do copymemory(@rom_mem[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
       //cargar ROMS sonido
       z80_1.change_ram_calls(hw1943_snd_getbyte,hw1943_snd_putbyte);
       if not(roms_load(@mem_snd,hw1943_snd_rom)) then exit;
       //cargar MCU
       mcs51_0:=cpu_mcs51.create(3000000,262);
       mcs51_0.change_io_calls(in_port0,in_port1,in_port2,nil,out_port0,nil,out_port2,out_port3);
       if not(roms_load(mcs51_0.get_rom_addr,hw1943_mcu)) then exit;
       //convertir chars
       if not(roms_load(@memoria_temp,hw1943_char)) then exit;
       init_gfx(0,8,8,2048);
       gfx[0].trans[0]:=true;
       gfx_set_desc_data(2,0,16*8,4,0);
       convert_gfx(0,0,@memoria_temp,@ps_x,@pt_y,false,true);
       //convertir tiles 1
       if not(roms_load(@tiles_pos,hw1943_tilesbg_pos)) then exit;
       if not(roms_load(@memoria_temp,hw1943_tiles1)) then exit;
       convertir_tiles(1);
       //cargar y convertir tiles 2
       if not(roms_load(@memoria_temp,hw1943_tiles2)) then exit;
       init_gfx(2,32,32,$80);
       gfx_set_desc_data(4,0,256*8,128*256*8+4,128*256*8+0,4,0);
       convert_gfx(2,0,@memoria_temp,@pt_x,@pt_y,false,true);
       //convertir_sprites
       if not(roms_load(@memoria_temp,hw1943_sprites)) then exit;
       convertir_sprites(3);
       //DIP
       marcade.dswa:=$f8;
       marcade.dswb:=$ff;
       marcade.dswa_val:=@hw1943_dip_a;
       marcade.dswb_val:=@gunsmoke_dip_b;
       //CLUT
       if not(roms_load(@memoria_temp,hw1943_pal)) then exit;
       for f:=0 to $ff do begin
          gfx[0].colores[f]:=(memoria_temp[$300+f] and $f)+$40;
          gfx[1].colores[f]:=((memoria_temp[$500+f] and $03) shl 4)+((memoria_temp[$400+f] and $0f) shl 0);
          gfx[2].colores[f]:=((memoria_temp[$700+f] and $03) shl 4)+((memoria_temp[$600+f] and $0f) shl 0);
          gfx[3].colores[f]:=((memoria_temp[$900+f] and $07) shl 4) or ((memoria_temp[$800+f] and $0f) shl 0) or $80;
       end;
     end;
     83:begin
       //Main CPU
       z80_0:=cpu_z80.create(6000000,262);
       z80_0.change_ram_calls(hw1943_getbyte,hw1943_putbyte);
       //cargar roms y ponerlas en su sitio
       if not(roms_load(@memoria_temp,hw1943kai_rom)) then exit;
       copymemory(@memoria,@memoria_temp,$8000);
       for f:=0 to 7 do copymemory(@rom_mem[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
       //cargar ROMS sonido
       z80_1.change_ram_calls(hw1943_snd_getbyte,hw1943_snd_putbyte);
       if not(roms_load(@mem_snd,hw1943kai_snd_rom)) then exit;
       //cargar MCU
       mcs51_0:=cpu_mcs51.create(3000000,262);
       mcs51_0.change_io_calls(in_port0,in_port1,in_port2,nil,out_port0,nil,out_port2,out_port3);
       if not(roms_load(mcs51_0.get_rom_addr,hw1943_mcu)) then exit;
       //convertir chars
       if not(roms_load(@memoria_temp,hw1943kai_char)) then exit;
       init_gfx(0,8,8,2048);
       gfx[0].trans[0]:=true;
       gfx_set_desc_data(2,0,16*8,4,0);
       convert_gfx(0,0,@memoria_temp,@ps_x,@pt_y,false,true);
       //convertir tiles 1
       if not(roms_load(@tiles_pos,hw1943kai_tilesbg_pos)) then exit;
       if not(roms_load(@memoria_temp,hw1943kai_tiles1)) then exit;
       convertir_tiles(1);
       //cargar y convertir tiles 2
       if not(roms_load(@memoria_temp,hw1943kai_tiles2)) then exit;
       init_gfx(2,32,32,$80);
       gfx_set_desc_data(4,0,256*8,128*256*8+4,128*256*8+0,4,0);
       convert_gfx(2,0,@memoria_temp,@pt_x,@pt_y,false,true);
       //convertir_sprites
       if not(roms_load(@memoria_temp,hw1943kai_sprites)) then exit;
       convertir_sprites(3);
       //DIP
       marcade.dswa:=$f8;
       marcade.dswb:=$ff;
       marcade.dswa_val:=@hw1943_dip_a;
       marcade.dswb_val:=@gunsmoke_dip_b;
       //CLUT
       if not(roms_load(@memoria_temp,hw1943kai_pal)) then exit;
       for f:=0 to $ff do begin
          gfx[0].colores[f]:=(memoria_temp[$300+f] and $f)+$40;
          gfx[1].colores[f]:=((memoria_temp[$500+f] and $03) shl 4)+((memoria_temp[$400+f] and $0f) shl 0);
          gfx[2].colores[f]:=((memoria_temp[$700+f] and $03) shl 4)+((memoria_temp[$600+f] and $0f) shl 0);
          gfx[3].colores[f]:=((memoria_temp[$900+f] and $07) shl 4) or ((memoria_temp[$800+f] and $0f) shl 0) or $80;
       end;
     end;
end;
//Paleta
for f:=0 to $ff do begin
  colores[f].r:=pal4bit(memoria_temp[f]);
  colores[f].g:=pal4bit(memoria_temp[f+$100]);
  colores[f].b:=pal4bit(memoria_temp[f+$200]);
end;
set_pal(colores,256);
//final
reset_gunsmokehw;
iniciar_gunsmokehw:=true;
end;

end.
