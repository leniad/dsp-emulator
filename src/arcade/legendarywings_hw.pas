unit legendarywings_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,ym_2203,gfx_engine,msm5205,rom_engine,
     pal_engine,sound_engine,timer_engine,mcs51,oki6295;

function iniciar_lwings:boolean;

implementation
const
        //legendary wings
        lwings_rom:array[0..2] of tipo_roms=(
        (n:'6c_lw01.bin';l:$8000;p:0;crc:$b55a7f60),(n:'7c_lw02.bin';l:$8000;p:$8000;crc:$a5efbb1b),
        (n:'9c_lw03.bin';l:$8000;p:$10000;crc:$ec5cc201));
        lwings_snd_rom:tipo_roms=(n:'11e_lw04.bin';l:$8000;p:0;crc:$a20337a2);
        lwings_char:tipo_roms=(n:'9h_lw05.bin';l:$4000;p:0;crc:$091d923c);
        lwings_sprites:array[0..3] of tipo_roms=(
        (n:'3j_lw17.bin';l:$8000;p:0;crc:$5ed1bc9b),(n:'1j_lw11.bin';l:$8000;p:$8000;crc:$2a0790d6),
        (n:'3h_lw16.bin';l:$8000;p:$10000;crc:$e8834006),(n:'1h_lw10.bin';l:$8000;p:$18000;crc:$b693f5a5));
        lwings_tiles:array[0..7] of tipo_roms=(
        (n:'3e_lw14.bin';l:$8000;p:0;crc:$5436392c),(n:'1e_lw08.bin';l:$8000;p:$8000;crc:$b491bbbb),
        (n:'3d_lw13.bin';l:$8000;p:$10000;crc:$fdd1908a),(n:'1d_lw07.bin';l:$8000;p:$18000;crc:$5c73d406),
        (n:'3b_lw12.bin';l:$8000;p:$20000;crc:$32e17b3c),(n:'1b_lw06.bin';l:$8000;p:$28000;crc:$52e533c1),
        (n:'3f_lw15.bin';l:$8000;p:$30000;crc:$99e134ba),(n:'1f_lw09.bin';l:$8000;p:$38000;crc:$c8f28777));
        //section Z
        sectionz_rom:array[0..2] of tipo_roms=(
        (n:'6c_sz01.bin';l:$8000;p:0;crc:$69585125),(n:'7c_sz02.bin';l:$8000;p:$8000;crc:$22f161b8),
        (n:'9c_sz03.bin';l:$8000;p:$10000;crc:$4c7111ed));
        sectionz_snd_rom:tipo_roms=(n:'11e_sz04.bin';l:$8000;p:0;crc:$a6073566);
        sectionz_char:tipo_roms=(n:'9h_sz05.bin';l:$4000;p:0;crc:$3173ba2e);
        sectionz_sprites:array[0..3] of tipo_roms=(
        (n:'3j_sz17.bin';l:$8000;p:0;crc:$8df7b24a),(n:'1j_sz11.bin';l:$8000;p:$8000;crc:$685d4c54),
        (n:'3h_sz16.bin';l:$8000;p:$10000;crc:$500ff2bb),(n:'1h_sz10.bin';l:$8000;p:$18000;crc:$00b3d244));
        sectionz_tiles:array[0..7] of tipo_roms=(
        (n:'3e_sz14.bin';l:$8000;p:0;crc:$63782e30),(n:'1e_sz08.bin';l:$8000;p:$8000;crc:$d57d9f13),
        (n:'3d_sz13.bin';l:$8000;p:$10000;crc:$1b3d4d7f),(n:'1d_sz07.bin';l:$8000;p:$18000;crc:$f5b3a29f),
        (n:'3b_sz12.bin';l:$8000;p:$20000;crc:$11d47dfd),(n:'1b_sz06.bin';l:$8000;p:$28000;crc:$df703b68),
        (n:'3f_sz15.bin';l:$8000;p:$30000;crc:$36bb9bf7),(n:'1f_sz09.bin';l:$8000;p:$38000;crc:$da8f06c9));
        //y mi favorito... TROJAN!!!, pues no me he dajao pasta ni na...
        trojan_rom:array[0..2] of tipo_roms=(
        (n:'t4.10n';l:$8000;p:0;crc:$c1bbeb4e),(n:'t6.13n';l:$8000;p:$8000;crc:$d49592ef),
        (n:'tb_05.12n';l:$8000;p:$10000;crc:$9273b264));
        trojan_snd_rom:tipo_roms=(n:'tb_02.15h';l:$8000;p:0;crc:$21154797);
        trojan_adpcm:tipo_roms=(n:'tb_01.6d';l:$4000;p:0;crc:$1c0f91b2);
        trojan_char:tipo_roms=(n:'tb_03.8k';l:$4000;p:0;crc:$581a2b4c);
        trojan_sprites:array[0..7] of tipo_roms=(
        (n:'tb_18.7l';l:$8000;p:0;crc:$862c4713),(n:'tb_16.3l';l:$8000;p:$8000;crc:$d86f8cbd),
        (n:'tb_17.5l';l:$8000;p:$10000;crc:$12a73b3f),(n:'tb_15.2l';l:$8000;p:$18000;crc:$bb1a2769),
        (n:'tb_22.7n';l:$8000;p:$20000;crc:$39daafd4),(n:'tb_20.3n';l:$8000;p:$28000;crc:$94615d2a),
        (n:'tb_21.5n';l:$8000;p:$30000;crc:$66c642bd),(n:'tb_19.2n';l:$8000;p:$38000;crc:$81d5ab36));
        trojan_tiles:array[0..7] of tipo_roms=(
        (n:'tb_13.6b';l:$8000;p:0;crc:$285a052b),(n:'tb_09.6a';l:$8000;p:$8000;crc:$aeb693f7),
        (n:'tb_12.4b';l:$8000;p:$10000;crc:$dfb0fe5c),(n:'tb_08.4a';l:$8000;p:$18000;crc:$d3a4c9d1),
        (n:'tb_11.3b';l:$8000;p:$20000;crc:$00f0f4fd),(n:'tb_07.3a';l:$8000;p:$28000;crc:$dff2ee02),
        (n:'tb_14.8b';l:$8000;p:$30000;crc:$14bfac18),(n:'tb_10.8a';l:$8000;p:$38000;crc:$71ba8a6d));
        trojan_tiles2:array[0..1] of tipo_roms=(
        (n:'tb_25.15n';l:$8000;p:0;crc:$6e38c6fa),(n:'tb_24.13n';l:$8000;p:$8000;crc:$14fc6cf2));
        trojan_tile_map:tipo_roms=(n:'tb_23.9n';l:$8000;p:0;crc:$eda13c0e);
        //Avengers
        avengers_rom:array[0..2] of tipo_roms=(
        (n:'avu_04d.10n';l:$8000;p:0;crc:$a94aadcc),(n:'avu_06d.13n';l:$8000;p:$8000;crc:$39cd80bd),
        (n:'avu_05d.12n';l:$8000;p:$10000;crc:$06b1cec9));
        avengers_snd_rom:tipo_roms=(n:'av_02.15h';l:$8000;p:0;crc:$107a2e17);
        avengers_mcu:tipo_roms=(n:'av.13k';l:$1000;p:0;crc:$505a0987);
        avengers_adpcm:tipo_roms=(n:'av_01.6d';l:$8000;p:0;crc:$c1e5d258);
        avengers_char:tipo_roms=(n:'av_03.8k';l:$8000;p:0;crc:$efb5883e);
        avengers_sprites:array[0..7] of tipo_roms=(
        (n:'av_18.7l';l:$8000;p:0;crc:$3c876a17),(n:'av_16.3l';l:$8000;p:$8000;crc:$4b1ff3ac),
        (n:'av_17.5l';l:$8000;p:$10000;crc:$4eb543ef),(n:'av_15.2l';l:$8000;p:$18000;crc:$8041de7f),
        (n:'av_22.7n';l:$8000;p:$20000;crc:$bdaa8b22),(n:'av_20.3n';l:$8000;p:$28000;crc:$566e3059),
        (n:'av_21.5n';l:$8000;p:$30000;crc:$301059aa),(n:'av_19.2n';l:$8000;p:$38000;crc:$a00485ec));
        avengers_tiles:array[0..7] of tipo_roms=(
        (n:'av_13.6b';l:$8000;p:0;crc:$9b5ff305),(n:'av_09.6a';l:$8000;p:$8000;crc:$08323355),
        (n:'av_12.4b';l:$8000;p:$10000;crc:$6d5261ba),(n:'av_08.4a';l:$8000;p:$18000;crc:$a13d9f54),
        (n:'av_11.3b';l:$8000;p:$20000;crc:$a2911d8b),(n:'av_07.3a';l:$8000;p:$28000;crc:$cde78d32),
        (n:'av_14.8b';l:$8000;p:$30000;crc:$44ac2671),(n:'av_10.8a';l:$8000;p:$38000;crc:$b1a717cb));
        avengers_tiles2:array[0..1] of tipo_roms=(
        (n:'avu_25.15n';l:$8000;p:0;crc:$230d9e30),(n:'avu_24.13n';l:$8000;p:$8000;crc:$a6354024));
        avengers_tile_map:tipo_roms=(n:'av_23.9n';l:$8000;p:0;crc:$c0a93ef6);
        //Fire Ball
        fball_rom:tipo_roms=(n:'d4.bin';l:$20000;p:0;crc:$6122b3dc);
        fball_snd_rom:tipo_roms=(n:'a05.bin';l:$10000;p:0;crc:$474dd19e);
        fball_char:tipo_roms=(n:'j03.bin';l:$10000;p:0;crc:$be11627f);
        fball_tiles:array[0..3] of tipo_roms=(
        (n:'e15.bin';l:$20000;p:0;crc:$89a761d2),(n:'c15.bin';l:$20000;p:$10000;crc:$0f77b03e),
        (n:'b15.bin';l:$20000;p:$20000;crc:$2169ad3e),(n:'f15.bin';l:$20000;p:$30000;crc:$34b3f9a2));
        fball_sprites:array[0..1] of tipo_roms=(
        (n:'j15.bin';l:$20000;p:0;crc:$ed7be8e7),(n:'h15.bin';l:$20000;p:$20000;crc:$6ffb5433));
        fball_oki:array[0..2] of tipo_roms=(
        (n:'a03.bin';l:$40000;p:0;crc:$22b0d089),(n:'a02.bin';l:$40000;p:$40000;crc:$951d6579),
        (n:'a01.bin';l:$40000;p:$80000;crc:$020b5261));
        //DIPs
        lwings_dip_a:array [0..4] of def_dip2=(
        (mask:2;name:'Flip Screen';number:2;val2:(2,0);name2:('Off','On')),
        (mask:$c;name:'Lives';number:4;val4:($c,4,8,0);name4:('3','4','5','6')),
        (mask:$30;name:'Coin A';number:4;val4:(0,$20,$10,$30);name4:('4C 1C','3C 1C','2C 1C','1C 1C')),
        (mask:$c0;name:'Coin B';number:4;val4:(0,$c0,$40,$80);name4:('2C 4C','1C 1C','1C 2C','1C 3C')),());
        lwings_dip_b:array [0..4] of def_dip2=(
        (mask:6;name:'Difficulty';number:4;val4:(2,6,4,0);name4:('Easy','Medium','Hard','Hardest')),
        (mask:8;name:'Demo Sounds';number:2;val2:(0,8);name2:('Off','On')),
        (mask:$10;name:'Allow Continue';number:2;val2:(0,$10);name2:('No','Yes')),
        (mask:$e0;name:'Bonus Life';number:8;val8:($e0,$60,$a0,$20,$c0,$40,$80,0);name8:('20K 50K+','20K 60K+','20K 70K+','30K 60K+','30k 70k+','30k 80k+','40k 100k+','None')),());
        sectionz_dip_a:array [0..4] of def_dip2=(
        (mask:2;name:'Flip Screen';number:2;val2:(2,0);name2:('Off','On')),
        (mask:$c;name:'Lives';number:4;val4:(4,$c,8,0);name4:('2','3','4','5')),
        (mask:$30;name:'Coin A';number:4;val4:(0,$20,$10,$30);name4:('4C 1C','3C 1C','2C 1C','1C 1C')),
        (mask:$c0;name:'Coin B';number:4;val4:(0,$c0,$40,$80);name4:('2C 4C','1C 1C','1C 2C','1C 3C')),());
        sectionz_dip_b:array [0..4] of def_dip2=(
        (mask:1;name:'Allow Continue';number:2;val2:(0,1);name2:('No','Yes')),
        (mask:6;name:'Difficulty';number:4;val4:(2,6,4,0);name4:('Easy','Normal','Hard','Very Hard')),
        (mask:$38;name:'Bonus Life';number:8;val8:($38,$18,$28,8,$30,$10,$20,0);name8:('20K 50K','20K 60K','20K 70K','30K 60K','30K 70K','30K 80K','40K 100K','None')),
        (mask:$c0;name:'Cabinet';number:4;val4:(0,$40,$c0,$80);name4:('Upright One Player','Upright Two Player','Cocktail','Invalid')),());
        trojan_dip_a:array [0..2] of def_dip2=(
        (mask:3;name:'Cabinet';number:4;val4:(0,2,3,1);name4:('Upright One Player','Upright Two Player','Cocktail','Invalid')),
        (mask:$1c;name:'Bonus Life';number:8;val8:($10,$c,8,$1c,$18,$14,4,0);name8:('20K 60K','20K 70K','20K 80K','30K 60K','30K 70K','30K 80K','40K 80K','None')),());
        trojan_dip_b:array [0..5] of def_dip2=(
        (mask:3;name:'Coin A';number:4;val4:(0,3,2,1);name4:('2C 1C','1C 1C','1C 2C','1C 3C')),
        (mask:$c;name:'Coin B';number:4;val4:(0,4,8,$c);name4:('4C 1C','3C 1C','2C 1C','1C 1C')),
        (mask:$30;name:'Lives';number:4;val4:($20,$30,$10,0);name4:('2','3','4','5')),
        (mask:$40;name:'Flip Screen';number:2;val2:($40,0);name2:('Off','On')),
        (mask:$80;name:'Allow Continue';number:2;val2:(0,$80);name2:('No','Yes')),());
        avengers_dip_a:array [0..3] of def_dip2=(
        (mask:2;name:'Flip Screen';number:2;val2:(2,0);name2:('Off','On')),
        (mask:$1c;name:'Coin A';number:8;val8:(0,$10,8,$1c,$c,$14,4,$18);name8:('4C 1C','3C 1C','2C 1C','1C 1C','1C 2C','1C 3C','1C 4C','1C 6C')),
        (mask:$e0;name:'Coin B';number:8;val8:(0,$80,$40,$e0,$60,$a0,$20,$c0);name8:('4C 1C','3C 1C','2C 1C','1C 1C','1C 2C','1C 3C','1C 4C','1C 6C')),());
        avengers_dip_b:array [0..5] of def_dip2=(
        (mask:1;name:'Allow Continue';number:2;val2:(0,1);name2:('No','Yes')),
        (mask:2;name:'Demo Sounds';number:2;val2:(0,2);name2:('Off','On')),
        (mask:$c;name:'Difficulty';number:4;val4:(4,$c,8,0);name4:('Easy','Normal','Hard','Very Hard')),
        (mask:$30;name:'Bonus Life';number:4;val4:($30,$10,$20,0);name4:('20K 60K','20K 70K','20K 80K','30K 80K')),
        (mask:$c0;name:'Lives';number:4;val4:($c0,$40,$80,0);name4:('3','4','5','6')),());
        fball_dip_a:array [0..4] of def_dip2=(
        (mask:1;name:'Difficulty';number:2;val2:(1,0);name2:('Easy','Hard')),
        (mask:6;name:'Lives';number:4;val4:(0,2,4,6);name4:('1','2','3','4')),
        (mask:$18;name:'Coinage';number:4;val4:(0,8,$10,$18);name4:('1C 1C','1C 1C','1C 2C','1C 4C')),
        (mask:$20;name:'Flip Screen';number:2;val2:($20,0);name2:('Off','On')),());
        CPU_SYNC=4;

var
 scroll_x,scroll_y:word;
 bank,sound_command,sound2_command:byte;
 mem_rom:array[0..3,0..$3fff] of byte;
 irq_ena:boolean;
 //trojan
 trojan_map:array[0..$7fff] of byte;
 scroll_x2,image:byte;
 pintar_image:boolean;
 //avengers mcu
 mcu_data:array[0..1] of byte;
 mcu_latch:array[0..2] of byte;
 soundstate,avengers_linea,mcu_control,adpcm_command:byte;
 sprt_avenger:boolean;
 //Fire ball
 sprite_bank,oki_bank:byte;
 oki_roms:array[0..7,0..$1ffff] of byte;

procedure eventos_lwings;
begin
if event.arcade then begin
  //P1
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or 8);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  //P2
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or 1);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or 2);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or 4);
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or 8);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  //System
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
end;
end;

procedure update_video_lw;
var
  f,color,nchar,x,y:word;
  attr:byte;
begin
for f:=$3ff downto 0 do begin
  //tiles
  attr:=memoria[$ec00+f];
  color:=attr and 7;
  if (gfx[2].buffer[f] or buffer_color[color+$10]) then begin
      x:=f div 32;
      y:=f mod 32;
      nchar:=memoria[$e800+f]+((attr and $e0) shl 3);
      put_gfx_flip(x*16,y*16,nchar,color shl 4,2,2,(attr and 8)<>0,(attr and $10)<>0);
      gfx[2].buffer[f]:=false;
  end;
  //Chars
  attr:=memoria[f+$e400];
  color:=attr and $f;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
    x:=f mod 32;
    y:=f div 32;
    nchar:=memoria[f+$e000]+((attr and $c0) shl 2);
    put_gfx_trans_flip(x*8,y*8,nchar,(color shl 2)+512,3,0,(attr and $20)<>0,(attr and $10)<>0);
    gfx[0].buffer[f]:=false;
  end;
end;
scroll_x_y(2,1,scroll_y,scroll_x);
for f:=$7f downto 0 do begin
    x:=(buffer_sprites[3+(f*4)]+((buffer_sprites[1+(f*4)] and 1) shl 8));
    y:=buffer_sprites[2+(f*4)];
    if ((x or y)<>0) then begin
      attr:=buffer_sprites[1+(f*4)];
      nchar:=buffer_sprites[(f*4)]+((attr and $c0) shl 2)+(sprite_bank*$400);
      color:=(attr and $38) shl 1;
      put_gfx_sprite(nchar,color+384,(attr and 2)<>0,(attr and 4)<>0,1);
      actualiza_gfx_sprite(x,y,1,1);
    end;
end;
actualiza_trozo(0,0,256,256,3,0,0,256,256,1);
actualiza_trozo_final(0,8,256,240,1);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure lwings_principal;
var
  f:byte;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
  for f:=0 to 255 do begin
    if f=248 then begin
      if irq_ena then z80_0.change_irq_vector(HOLD_LINE,$d7);
      update_video_lw;
      copymemory(@buffer_sprites[0],@memoria[$de00],$200);
    end;
    //Main CPU
    z80_0.run(frame_main);
    frame_main:=frame_main+z80_0.tframes-z80_0.contador;
    //Sound CPU
    z80_1.run(frame_snd);
    frame_snd:=frame_snd+z80_1.tframes-z80_1.contador;
  end;
  eventos_lwings;
  video_sync;
end;
end;

//Main CPU
function lwings_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff,$c000..$efff:lwings_getbyte:=memoria[direccion];
  $8000..$bfff:lwings_getbyte:=mem_rom[bank,direccion and $3fff];
  $f000..$f7ff:lwings_getbyte:=buffer_paleta[direccion and $7ff];
  $f808:lwings_getbyte:=marcade.in0;
  $f809:lwings_getbyte:=marcade.in1;
  $f80a:lwings_getbyte:=marcade.in2;
  $f80b:lwings_getbyte:=marcade.dswa;
  $f80c:lwings_getbyte:=marcade.dswb;
  $f80d,$f80e:lwings_getbyte:=$ff; //P3 y P4
end;
end;

procedure lwings_putbyte(direccion:word;valor:byte);
procedure cambiar_color(dir:word);
var
  tmp_color:byte;
  color:tcolor;
begin
  tmp_color:=buffer_paleta[dir];
  color.r:=pal4bit(tmp_color shr 4);
  color.g:=pal4bit(tmp_color);
  tmp_color:=buffer_paleta[dir+$400];
  color.b:=pal4bit(tmp_color shr 4);
  set_pal_color(color,dir);
  case dir of
    0..$7f:buffer_color[((dir shr 4) and 7)+$10]:=true;
    $200..$23f:buffer_color[(dir shr 2) and $f]:=true;
  end;
end;
begin
case direccion of
    0..$bfff:;
    $c000..$dfff:memoria[direccion]:=valor;
    $e000..$e7ff:if memoria[direccion]<>valor then begin
                    gfx[0].buffer[direccion and $3ff]:=true;
                    memoria[direccion]:=valor;
                 end;
    $e800..$efff:if memoria[direccion]<>valor then begin
                    gfx[2].buffer[direccion and $3ff]:=true;
                    memoria[direccion]:=valor;
                 end;
    $f000..$f7ff:if buffer_paleta[direccion and $7ff]<>valor then begin
                    buffer_paleta[direccion and $7ff]:=valor;
                    cambiar_color(direccion and $3ff);
                 end;
    $f808:scroll_y:=(scroll_y and $100) or valor;
    $f809:scroll_y:=(scroll_y and $ff) or ((valor and 1) shl 8);
    $f80a:scroll_x:=(scroll_x and $100) or valor;
    $f80b:scroll_x:=(scroll_x and $ff) or ((valor and 1) shl 8);
    $f80c:sound_command:=valor;
    $f80e:begin
            bank:=(valor and 6) shr 1;
            irq_ena:=(valor and 8)<>0;
            main_screen.flip_main_screen:=(valor and 1)=0;
            if (valor and $20)<>0 then z80_1.change_reset(ASSERT_LINE)
              else z80_1.change_reset(CLEAR_LINE);
            sprite_bank:=(valor and $10) shr 4;
          end;
end;
end;

//Sound CPU
function lwings_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff,$c000..$c7ff:lwings_snd_getbyte:=mem_snd[direccion];
  $c800:lwings_snd_getbyte:=sound_command;
  $e006:begin
          lwings_snd_getbyte:=sound2_command or soundstate;
          soundstate:=0;
        end;
end;
end;

procedure lwings_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:;
  $c000..$c7ff:mem_snd[direccion]:=valor;
  $e000:ym2203_0.control(valor);
  $e001:ym2203_0.write(valor);
  $e002:ym2203_1.control(valor);
  $e003:ym2203_1.write(valor);
  $e006:sound2_command:=valor;
end;
end;

procedure lwings_snd_irq;
begin
  z80_1.change_irq(HOLD_LINE);
end;

procedure lwings_sound_update;
begin
  ym2203_0.update;
  ym2203_1.update;
end;

//trojan
procedure update_video_trojan;
var
  f,color,nchar,x,y,tile_index,offsy:word;
  attr:byte;
  flipx,flipy:boolean;
begin
//final 1  512x512 (por sprites)
//tiles 2  512x512 pri 0
//chars 3
//tiles 4  pri 1
//back 5
if pintar_image then begin
  offsy:=image*$20;
  for y:=0 to $f do begin
    offsy:=offsy and $7fff;
    for x:=0 to $1f do begin
      tile_index:=offsy+(2*x);
      attr:=trojan_map[tile_index+1];
      color:=(attr and 7) shl 4;
      nchar:=trojan_map[tile_index]+((attr and $80) shl 1);
      put_gfx_flip(x*16,y*16,nchar,color,5,3,(attr and $30)<>0,false);
    end;
    offsy:=offsy+$800;
  end;
  pintar_image:=false;
end;
scroll__x(5,1,scroll_x2);
for f:=$3ff downto 0 do begin
  //tiles
  attr:=memoria[$ec00+f];
  color:=attr and 7;
  if (gfx[2].buffer[f] or buffer_color[color+$10]) then begin
      x:=f div 32;
      y:=f mod 32;
      nchar:=memoria[$e800+f]+((attr and $e0) shl 3);
      put_gfx_trans_flip(x*16,y*16,nchar,(color shl 4)+256,2,2,(attr and $10)<>0,false);
      if (attr and 8)<>0 then put_gfx_trans_flip_alt(x*16,y*16,nchar,(color shl 4)+256,4,2,(attr and $10)<>0,false,0)
        else put_gfx_block_trans(x*16,y*16,4,16,16);
      gfx[2].buffer[f]:=false;
  end;
  //Chars
  attr:=memoria[f+$e400];
  color:=attr and $f;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
    x:=f mod 32;
    y:=f div 32;
    nchar:=memoria[f+$e000]+((attr and $c0) shl 2);
    put_gfx_trans_flip(x*8,y*8,nchar,(color shl 2)+768,3,0,(attr and $20)<>0,(attr and $10)<>0);
    gfx[0].buffer[f]:=false;
  end;
end;
//Fondo con prioridad 0
scroll_x_y(2,1,scroll_x,scroll_y);
//sprites
for f:=$5f downto 0 do begin
    x:=(buffer_sprites[3+(f*4)]+((buffer_sprites[1+(f*4)] and 1) shl 8));
    y:=buffer_sprites[2+(f*4)];
    if (x or y)<>0 then begin
      attr:=buffer_sprites[1+(f*4)];
      nchar:=buffer_sprites[(f*4)]+((attr and $20) shl 4)+((attr and $40) shl 2)+((attr and $80) shl 3);
      color:=(attr and $e) shl 3;
      if sprt_avenger then begin
        flipx:=false;
        flipy:=(attr and $10)=0;
      end else begin
        flipx:=(attr and $10)<>0;
        flipy:=true;
      end;
      put_gfx_sprite(nchar,color+640,flipx,flipy,1);
      actualiza_gfx_sprite(x,y,1,1);
    end;
end;
//Fondo con prioridad 1
scroll_x_y(4,1,scroll_x,scroll_y);
actualiza_trozo(0,0,256,256,3,0,0,256,256,1);
actualiza_trozo_final(0,8,256,240,1);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
end;

procedure trojan_principal;
var
  f:byte;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
  for f:=0 to 255 do begin
    if f=248 then begin
      if irq_ena then z80_0.change_irq_vector(HOLD_LINE,$d7);
      update_video_trojan;
      copymemory(@buffer_sprites[0],@memoria[$de00],$200);
    end;
    //Main Z80
    z80_0.run(frame_main);
    frame_main:=frame_main+z80_0.tframes-z80_0.contador;
    //Sound Z80
    z80_1.run(frame_snd);
    frame_snd:=frame_snd+z80_1.tframes-z80_1.contador;
    //ADPCM Z80
    z80_2.run(frame_snd2);
    frame_snd2:=frame_snd2+z80_2.tframes-z80_2.contador;
  end;
  eventos_lwings;
  video_sync;
end;
end;

procedure cambiar_color_trojan(dir:word);
var
  tmp_color:byte;
  color:tcolor;
begin
  tmp_color:=buffer_paleta[dir];
  color.r:=pal4bit(tmp_color shr 4);
  color.g:=pal4bit(tmp_color);
  tmp_color:=buffer_paleta[dir+$400];
  color.b:=pal4bit(tmp_color shr 4);
  set_pal_color(color,dir);
  case dir of
    0..$7f:pintar_image:=true;
    $100..$17f:buffer_color[((dir shr 4) and 7)+$10]:=true;
    $300..$33f:buffer_color[(dir shr 2) and $f]:=true;
  end;
end;

procedure trojan_putbyte(direccion:word;valor:byte);
begin
case direccion of
    0..$bfff:;
    $c000..$dfff:memoria[direccion]:=valor;
    $e000..$e7ff:if memoria[direccion]<>valor then begin
                    gfx[0].buffer[direccion and $3ff]:=true;
                    memoria[direccion]:=valor;
                 end;
    $e800..$efff:if memoria[direccion]<>valor then begin
                    gfx[2].buffer[direccion and $3ff]:=true;
                    memoria[direccion]:=valor;
                 end;
    $f000..$f7ff:if buffer_paleta[direccion and $7ff]<>valor then begin
                    buffer_paleta[direccion and $7ff]:=valor;
                    cambiar_color_trojan(direccion and $3ff);
                 end;
    $f800:scroll_x:=(scroll_x and $100) or valor;
    $f801:scroll_x:=(scroll_x and $ff) or ((valor and 1) shl 8);
    $f802:scroll_y:=(scroll_y and $100) or valor;
    $f803:scroll_y:=(scroll_y and $ff) or ((valor and 1) shl 8);
    $f804:scroll_x2:=valor;
    $f805:if image<>valor then begin
            image:=valor;
            pintar_image:=true;
          end;
    $f80c:sound_command:=valor;
    $f80d:sound2_command:=valor;
    $f80e:begin
            bank:=(valor and 6) shr 1;
            irq_ena:=(valor and 8)<>0;
            main_screen.flip_main_screen:=(valor and 1)=0;
            if (valor and $20)<>0 then z80_1.change_reset(ASSERT_LINE)
              else z80_1.change_reset(CLEAR_LINE);
          end;
end;
end;

function trojan_inbyte(puerto:word):byte;
begin
if (puerto and $ff)=0 then trojan_inbyte:=sound2_command;
end;

procedure trojan_outbyte(puerto:word;valor:byte);
begin
if (puerto and $ff)=1 then begin
    msm5205_0.reset_w((valor and $80)<>0);
    msm5205_0.data_w(valor);
    msm5205_0.vclk_w(true);
    msm5205_0.vclk_w(false);
end;
end;

function trojan_misc_getbyte(direccion:word):byte;
begin
trojan_misc_getbyte:=msm5205_0.rom_data[direccion];
end;

procedure trojan_misc_putbyte(direccion:word;valor:byte);
begin
//Nada que hacer!!!
end;

procedure trojan_adpcm_instruccion;
begin
  z80_2.change_irq(HOLD_LINE);
end;

procedure trojan_sound_update;
begin
  ym2203_0.update;
  ym2203_1.update;
  msm5205_0.update;
end;

//Avengers
procedure avengers_principal;
var
  h:byte;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
  for avengers_linea:=0 to 255 do begin
    if avengers_linea=248 then begin
      if irq_ena then z80_0.change_nmi(PULSE_LINE);
      update_video_trojan;
      copymemory(@buffer_sprites[0],@memoria[$de00],$200);
    end;
    for h:=1 to CPU_SYNC do begin
      //Main Z80
      z80_0.run(frame_main);
      frame_main:=frame_main+z80_0.tframes-z80_0.contador;
      //Sound Z80
      z80_1.run(frame_snd);
      frame_snd:=frame_snd+z80_1.tframes-z80_1.contador;
      //ADPCM Z80
      z80_2.run(frame_snd2);
      frame_snd2:=frame_snd2+z80_2.tframes-z80_2.contador;
      //MCU
      mcs51_0.run(frame_mcu);
      frame_mcu:=frame_mcu+mcs51_0.tframes-mcs51_0.contador;
    end;
  end;
  eventos_lwings;
  video_sync;
end;
end;

function avengers_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff,$c000..$efff:avengers_getbyte:=memoria[direccion];
  $8000..$bfff:avengers_getbyte:=mem_rom[bank,direccion and $3fff];
  $f000..$f7ff:avengers_getbyte:=buffer_paleta[direccion and $7ff];
  $f808:avengers_getbyte:=marcade.in0;
  $f809:avengers_getbyte:=marcade.in1;
  $f80a:avengers_getbyte:=marcade.in2;
  $f80b:avengers_getbyte:=marcade.dswa;
  $f80c:avengers_getbyte:=marcade.dswb;
  $f80d:avengers_getbyte:=mcu_latch[2];
end;
end;

procedure avengers_putbyte(direccion:word;valor:byte);
begin
case direccion of
    0..$bfff:;
    $c000..$dfff:memoria[direccion]:=valor;
    $e000..$e7ff:if memoria[direccion]<>valor then begin
                    gfx[0].buffer[direccion and $3ff]:=true;
                    memoria[direccion]:=valor;
                 end;
    $e800..$efff:if memoria[direccion]<>valor then begin
                    gfx[2].buffer[direccion and $3ff]:=true;
                    memoria[direccion]:=valor;
                 end;
    $f000..$f7ff:if buffer_paleta[direccion and $7ff]<>valor then begin
                    buffer_paleta[direccion and $7ff]:=valor;
                    cambiar_color_trojan(direccion and $3ff);
                 end;
    $f800:scroll_x:=(scroll_x and $100) or valor;
    $f801:scroll_x:=(scroll_x and $ff) or ((valor and 1) shl 8);
    $f802:scroll_y:=(scroll_y and $100) or valor;
    $f803:scroll_y:=(scroll_y and $ff) or ((valor and 1) shl 8);
    $f804:scroll_x2:=valor;
    $f805:if image<>valor then begin
            image:=valor;
            pintar_image:=true;
          end;
    $f809:begin
            mcu_latch[0]:=valor;
            mcs51_0.change_irq0(ASSERT_LINE);
          end;
    $f80c:mcu_latch[1]:=valor;
    $f80d:adpcm_command:=valor;
    $f80e:begin
            bank:=(valor and 6) shr 1;
            irq_ena:=(valor and 8)<>0;
            main_screen.flip_main_screen:=(valor and 1)=0;
            if (valor and $20)<>0 then z80_1.change_reset(ASSERT_LINE)
              else z80_1.change_reset(CLEAR_LINE);
          end;
end;
end;

function avengers_inbyte(puerto:word):byte;
begin
if (puerto and $ff)=0 then avengers_inbyte:=adpcm_command;
end;

function avengers_in_port0:byte;
begin
  if (mcu_control and $80)=0 then avengers_in_port0:=mcu_latch[0]
    else avengers_in_port0:=$ff;
end;

procedure avengers_out_port0(valor:byte);
begin
  mcu_data[0]:=valor;
end;

function avengers_in_port1:byte;
begin
  avengers_in_port1:=avengers_linea;
end;

function avengers_in_port2:byte;
begin
  if (mcu_control and $80)=0 then avengers_in_port2:=mcu_latch[1]
    else avengers_in_port2:=$ff;
end;

procedure avengers_out_port2(valor:byte);
begin
  mcu_data[1]:=valor;
end;

procedure avengers_out_port3(valor:byte);
begin
  if (((mcu_control and $40)=0) and ((valor and $40)<>0)) then begin
		mcu_latch[2]:=mcu_data[0];
		sound_command:=mcu_data[1];
		soundstate:=$80;
  end;
	if ((mcu_control and $80)<>(valor and $80)) then mcs51_0.change_irq0(CLEAR_LINE);
	mcu_control:=valor;
end;

procedure avenger_m1(opcode:byte);
begin
  //Esto es importante para sincronizar el Z80 con la MCU... Si no, la paleta no va bien
  z80_0.contador:=z80_0.contador+2;
end;

//Fire Ball
procedure fball_principal;
var
  f:byte;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
  for f:=0 to $ff do begin
    if f=248 then begin
      if irq_ena then z80_0.change_nmi(PULSE_LINE);
      update_video_lw;
      copymemory(@buffer_sprites[0],@memoria[$de00],$200);
    end;
    //Main CPU
    z80_0.run(frame_main);
    frame_main:=frame_main+z80_0.tframes-z80_0.contador;
    //Sound CPU
    z80_1.run(frame_snd);
    frame_snd:=frame_snd+z80_1.tframes-z80_1.contador;
  end;
  eventos_lwings;
  video_sync;
end;
end;

function fball_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$fff,$c000..$c7ff:fball_snd_getbyte:=mem_snd[direccion];
  $8000:fball_snd_getbyte:=sound_command;
  $e000:fball_snd_getbyte:=oki_6295_0.read;
end;
end;

procedure fball_snd_putbyte(direccion:word;valor:byte);
var
  ptemp:pbyte;
begin
case direccion of
  0..$fff:;
  $a000:begin
          oki_bank:=(valor shr 1) and 7;
          ptemp:=oki_6295_0.get_rom_addr;
          copymemory(@ptemp[$20000],@oki_roms[oki_bank,0],$20000);
        end;
  $c000..$c7ff:mem_snd[direccion]:=valor;
  $e000:oki_6295_0.write(valor);
end;
end;

procedure fball_sound_update;
begin
  oki_6295_0.update;
end;

//Main
procedure reset_lwings;
begin
 z80_0.reset;
 z80_1.reset;
 frame_main:=z80_0.tframes;
 frame_snd:=z80_1.tframes;
 if main_vars.tipo_maquina<>247 then begin
    ym2203_0.reset;
    ym2203_1.reset;
 end else begin
    oki_6295_0.reset;
 end;
 if ((main_vars.tipo_maquina=61) or (main_vars.tipo_maquina=368)) then begin
    z80_2.reset;
    msm5205_0.reset;
    frame_snd2:=z80_2.tframes;
 end;
 if main_vars.tipo_maquina=368 then begin
    mcs51_0.reset;
    frame_mcu:=mcs51_0.tframes;
 end;
 reset_video;
 reset_audio;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 scroll_x:=0;
 scroll_y:=0;
 irq_ena:=false;
 //trojan
 image:=$ff;
 pintar_image:=true;
 scroll_x2:=0;
 adpcm_command:=0;
 //Avengers
 mcu_data[0]:=0;
 mcu_data[1]:=0;
 mcu_latch[0]:=0;
 mcu_latch[1]:=0;
 mcu_latch[2]:=0;
 soundstate:=0;
 mcu_control:=0;
 //Fire Ball
 oki_bank:=0;
 sprite_bank:=0;
end;

function iniciar_lwings:boolean;
var
    f:word;
    memoria_temp:array[0..$bffff] of byte;
    ptemp:pbyte;
const
    ps_x:array[0..15] of dword=(0, 1, 2, 3, 8+0, 8+1, 8+2, 8+3,
			32*8+0, 32*8+1, 32*8+2, 32*8+3, 33*8+0, 33*8+1, 33*8+2, 33*8+3);
    ps_y:array[0..15] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16,
			8*16, 9*16, 10*16, 11*16, 12*16, 13*16, 14*16, 15*16);
    pt_x:array[0..15] of dword=(0, 1, 2, 3, 4, 5, 6, 7,
			16*8+0, 16*8+1, 16*8+2, 16*8+3, 16*8+4, 16*8+5, 16*8+6, 16*8+7);
    pt_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8);
procedure convert_chars_lw(num:word);
begin
  init_gfx(0,8,8,num);
  gfx[0].trans[3]:=true;
  gfx_set_desc_data(2,0,16*8,0,4);
  convert_gfx(0,0,@memoria_temp,@ps_x,@ps_y,false,false);
end;
procedure convert_sprites_lw(num:word);
begin
  init_gfx(1,16,16,num);
  gfx[1].trans[15]:=true;
  gfx_set_desc_data(4,0,64*8,num*64*8+4,num*64*8+0,4,0);
  convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,false);
end;
procedure convert_tiles_lw;
begin
  init_gfx(2,16,16,$800);
  gfx_set_desc_data(4,0,32*8,$30000*8,$20000*8,$10000*8,0*8);
  convert_gfx(2,0,@memoria_temp,@pt_x,@pt_y,false,false);
end;
procedure convert_tiles2_lw;
begin
  init_gfx(3,16,16,$200);
  gfx_set_desc_data(4,0,64*8,$8000*8+0,$8000*8+4,0,4);
  convert_gfx(3,0,@memoria_temp,@ps_x,@ps_y,false,false);
end;
begin
llamadas_maquina.reset:=reset_lwings;
iniciar_lwings:=false;
iniciar_audio(false);
//final 1  512x512 (por sprites)
//tiles 2  512x512 pri 0
//chars 3
//tiles 4  pri 1
screen_init(1,512,512,false,true);
screen_init(2,512,512);
screen_mod_scroll(2,512,256,511,512,256,511);
screen_init(3,256,256,true);
case main_vars.tipo_maquina of
  59:main_screen.rot90_screen:=true;
  60:llamadas_maquina.fps_max:=55.37;
  61,368:begin
      //La pantallas 2 (la cambio) y 4 son transparentes
      screen_init(2,512,512,true);
      screen_init(4,512,512,true);
      screen_mod_scroll(4,512,256,511,512,256,511);
      //La pantalla 5 es el fondo
      screen_init(5,512,256);
      screen_mod_scroll(5,512,256,511,256,256,255);
      if main_vars.tipo_maquina=368 then main_screen.rot90_screen:=true;
     end;
end;
iniciar_video(256,240);
//Sound CPU
case main_vars.tipo_maquina of
  59,60:begin
          z80_1:=cpu_z80.create(3000000,256);
          z80_1.init_sound(lwings_sound_update);
        end;
  61:begin
        z80_1:=cpu_z80.create(3000000,256);
        z80_1.init_sound(trojan_sound_update);
     end;
  247:begin
        z80_1:=cpu_z80.create(3000000,256);
        z80_1.init_sound(fball_sound_update);
      end;
  368:begin
        z80_1:=cpu_z80.create(3000000,256*CPU_SYNC);
        z80_1.init_sound(trojan_sound_update);
      end;
end;
if main_vars.tipo_maquina<>247 then begin
  z80_1.change_ram_calls(lwings_snd_getbyte,lwings_snd_putbyte);
  timers.init(z80_1.numero_cpu,3000000/222,lwings_snd_irq,nil,true);
  //Sound Chips
  ym2203_0:=ym2203_chip.create(1500000,0.50,1);
  ym2203_1:=ym2203_chip.create(1500000,0.50,1);
end else begin
  z80_1.change_ram_calls(fball_snd_getbyte,fball_snd_putbyte);
  oki_6295_0:=snd_okim6295.create(1000000,OKIM6295_PIN7_HIGH);
end;
sprt_avenger:=false;
case main_vars.tipo_maquina of
  59:begin //Legendary Wings
        llamadas_maquina.bucle_general:=lwings_principal;
        //Main CPU
        z80_0:=cpu_z80.create(6000000,256);
        z80_0.change_ram_calls(lwings_getbyte,lwings_putbyte);
        if not(roms_load(@memoria_temp,lwings_rom)) then exit;
        copymemory(@memoria,@memoria_temp,$8000);
        for f:=0 to 3 do copymemory(@mem_rom[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
        //cargar ROMS sonido
        if not(roms_load(@mem_snd,lwings_snd_rom)) then exit;

        //convertir chars
        if not(roms_load(@memoria_temp,lwings_char)) then exit;
        convert_chars_lw($400);
        //convertir sprites
        if not(roms_load(@memoria_temp,lwings_sprites)) then exit;
        convert_sprites_lw($400);
        //tiles
        if not(roms_load(@memoria_temp,lwings_tiles)) then exit;
        convert_tiles_lw;  //$800
        //DIP
        marcade.dswa:=$ff;
        marcade.dswb:=$ff;
        marcade.dswa_val2:=@lwings_dip_a;
        marcade.dswb_val2:=@lwings_dip_b;
     end;
  60:begin //Section Z
        llamadas_maquina.bucle_general:=lwings_principal;
        //Main CPU
        z80_0:=cpu_z80.create(3000000,256);
        z80_0.change_ram_calls(lwings_getbyte,lwings_putbyte);
        if not(roms_load(@memoria_temp,sectionz_rom)) then exit;
        copymemory(@memoria,@memoria_temp,$8000);
        for f:=0 to 3 do copymemory(@mem_rom[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
        //cargar ROMS sonido
        if not(roms_load(@mem_snd,sectionz_snd_rom)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,sectionz_char)) then exit;
        convert_chars_lw($400);
        //convertir sprites
        if not(roms_load(@memoria_temp,sectionz_sprites)) then exit;
        convert_sprites_lw($400);
        //tiles
        if not(roms_load(@memoria_temp,sectionz_tiles)) then exit;
        convert_tiles_lw; //$800
        //DIP
        marcade.dswa:=$ff;
        marcade.dswb:=$3f;
        marcade.dswa_val2:=@sectionz_dip_a;
        marcade.dswb_val2:=@sectionz_dip_b;
      end;
  61:begin //Trojan
        llamadas_maquina.bucle_general:=trojan_principal;
        //Main CPU
        z80_0:=cpu_z80.create(3000000,256);
        z80_0.change_ram_calls(lwings_getbyte,trojan_putbyte);
        //ADPCM Z80
        z80_2:=cpu_z80.create(3000000,256);
        z80_2.change_ram_calls(trojan_misc_getbyte,trojan_misc_putbyte);
        z80_2.change_io_calls(trojan_inbyte,trojan_outbyte);
        msm5205_0:=MSM5205_chip.create(384000,MSM5205_SEX_4B,0.50,$4000);
        if not(roms_load(msm5205_0.rom_data,trojan_adpcm)) then exit;
        msm5205_0.change_advance(nil);
        timers.init(z80_2.numero_cpu,3000000/4000,trojan_adpcm_instruccion,nil,true);
        //Graficos
        if not(roms_load(@memoria_temp,trojan_rom)) then exit;
        copymemory(@memoria,@memoria_temp,$8000);
        for f:=0 to 3 do copymemory(@mem_rom[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
        //cargar ROMS sonido
        if not(roms_load(@mem_snd,trojan_snd_rom)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,trojan_char)) then exit;
        convert_chars_lw($400);
        //convertir sprites
        if not(roms_load(@memoria_temp,trojan_sprites)) then exit;
        convert_sprites_lw($800);
        //tiles
        if not(roms_load(@memoria_temp,trojan_tiles)) then exit;
        convert_tiles_lw; //$800
        for f:=0 to 6 do gfx[2].trans_alt[0,f]:=true;
        for f:=12 to 15 do gfx[2].trans_alt[0,f]:=true;
        gfx[2].trans[0]:=true;
        //tiles 2
        if not(roms_load(@memoria_temp,trojan_tiles2)) then exit;
        convert_tiles2_lw;
        //Map
        if not(roms_load(@trojan_map,trojan_tile_map)) then exit;
        //DIP
        marcade.dswa:=$fc;
        marcade.dswb:=$ff;
        marcade.dswa_val2:=@trojan_dip_a;
        marcade.dswb_val2:=@trojan_dip_b;
      end;
  247:begin //Fire ball
        llamadas_maquina.bucle_general:=fball_principal;
        //Main CPU
        z80_0:=cpu_z80.create(6000000,256);
        z80_0.change_ram_calls(lwings_getbyte,lwings_putbyte);
        if not(roms_load(@memoria_temp,fball_rom)) then exit;
        copymemory(@memoria,@memoria_temp,$8000);
        for f:=0 to 3 do copymemory(@mem_rom[f,0],@memoria_temp[$10000+(f*$4000)],$4000);
        //cargar ROMS sonido
        if not(roms_load(@memoria_temp,fball_snd_rom)) then exit;
        copymemory(@mem_snd,@memoria_temp,$1000);
        if not(roms_load(@memoria_temp,fball_oki)) then exit;
        ptemp:=oki_6295_0.get_rom_addr;
        copymemory(ptemp,@memoria_temp[0],$40000);
        copymemory(@oki_roms[0,0],@memoria_temp[0],$20000);
        copymemory(@oki_roms[1,0],@memoria_temp[$20000],$20000);
        copymemory(@oki_roms[2,0],@memoria_temp[0],$20000);
        copymemory(@oki_roms[3,0],@memoria_temp[$20000],$20000);
        for f:=4 to 7 do copymemory(@oki_roms[f,0],@memoria_temp[$40000+((f-4)*$20000)],$20000);
        //convertir chars
        if not(roms_load(@memoria_temp,fball_char)) then exit;
        fillchar(memoria_temp[$4000],$c000,$ff);
        convert_chars_lw($400);
        //convertir sprites
        if not(roms_load(@memoria_temp,fball_sprites)) then exit;
        convert_sprites_lw($800);
        //tiles
        if not(roms_load(@memoria_temp,fball_tiles)) then exit;
        convert_tiles_lw;  //$800
        //DIP
        marcade.dswa:=$6d;
        marcade.dswb:=0;
        marcade.dswa_val2:=@fball_dip_a;
      end;
  368:begin
        llamadas_maquina.bucle_general:=avengers_principal;
        //Main CPU
        z80_0:=cpu_z80.create(6000000,256*CPU_SYNC);
        z80_0.change_ram_calls(avengers_getbyte,avengers_putbyte);
        z80_0.change_misc_calls(nil,nil,avenger_m1);
        if not(roms_load(@memoria_temp,avengers_rom)) then exit;
        copymemory(@memoria,@memoria_temp,$8000);
        for f:=0 to 3 do copymemory(@mem_rom[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
        //MCU
        mcs51_0:=cpu_mcs51.create(I8X51,6000000,256*CPU_SYNC);
        mcs51_0.change_io_calls(avengers_in_port0,avengers_in_port1,avengers_in_port2,nil,avengers_out_port0,nil,avengers_out_port2,avengers_out_port3);
        if not(roms_load(@memoria_temp,avengers_mcu)) then exit;
        memoria_temp[$b84]:=2;
        copymemory(mcs51_0.get_rom_addr,@memoria_temp,$1000);
        //ADPCM Z80
        z80_2:=cpu_z80.create(3000000,256*CPU_SYNC);
        z80_2.change_ram_calls(trojan_misc_getbyte,trojan_misc_putbyte);
        z80_2.change_io_calls(avengers_inbyte,trojan_outbyte);
        msm5205_0:=MSM5205_chip.create(384000,MSM5205_SEX_4B,0.50,$8000);
        if not(roms_load(msm5205_0.rom_data,avengers_adpcm)) then exit;
        msm5205_0.change_advance(nil);
        timers.init(z80_2.numero_cpu,3000000/4000,trojan_adpcm_instruccion,nil,true);
        //cargar ROMS sonido
        if not(roms_load(@mem_snd,avengers_snd_rom)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,avengers_char)) then exit;
        convert_chars_lw($800);
        //convertir sprites
        if not(roms_load(@memoria_temp,avengers_sprites)) then exit;
        convert_sprites_lw($800);
        sprt_avenger:=true;
        //tiles
        if not(roms_load(@memoria_temp,avengers_tiles)) then exit;
        convert_tiles_lw;
        for f:=0 to 6 do gfx[2].trans_alt[0,f]:=true;
        for f:=12 to 15 do gfx[2].trans_alt[0,f]:=true;
        gfx[2].trans[0]:=true;
        //tiles 2
        if not(roms_load(@memoria_temp,avengers_tiles2)) then exit;
        convert_tiles2_lw;
        //Map
        if not(roms_load(@trojan_map,avengers_tile_map)) then exit;
        //DIP
        marcade.dswa:=$ff;
        marcade.dswb:=$ff;
        marcade.dswa_val2:=@avengers_dip_a;
        marcade.dswb_val2:=@avengers_dip_b;
      end;
end;
//final
reset_lwings;
iniciar_lwings:=true;
end;

end.
