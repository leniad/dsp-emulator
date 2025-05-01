unit mcr_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,ay_8910,gfx_engine,rom_engine,
     pal_engine,sound_engine,z80daisy,z80ctc,timer_engine,file_engine;

function iniciar_mcr:boolean;

implementation
const
        tapper_rom:array[0..3] of tipo_roms=(
        (n:'tapper_c.p.u._pg_0_1c_1-27-84.1c';l:$4000;p:0;crc:$bb060bb0),(n:'tapper_c.p.u._pg_1_2c_1-27-84.2c';l:$4000;p:$4000;crc:$fd9acc22),
        (n:'tapper_c.p.u._pg_2_3c_1-27-84.3c';l:$4000;p:$8000;crc:$b3755d41),(n:'tapper_c.p.u._pg_3_4c_1-27-84.4c';l:$2000;p:$c000;crc:$77273096));
        tapper_snd:array[0..3] of tipo_roms=(
        (n:'tapper_sound_snd_0_a7_12-7-83.a7';l:$1000;p:0;crc:$0e8bb9d5),(n:'tapper_sound_snd_1_a8_12-7-83.a8';l:$1000;p:$1000;crc:$0cf0e29b),
        (n:'tapper_sound_snd_2_a9_12-7-83.a9';l:$1000;p:$2000;crc:$31eb6dc6),(n:'tapper_sound_snd_3_a10_12-7-83.a10';l:$1000;p:$3000;crc:$01a9be6a));
        tapper_char:array[0..1] of tipo_roms=(
        (n:'tapper_c.p.u._bg_1_6f_12-7-83.6f';l:$4000;p:0;crc:$2a30238c),(n:'tapper_c.p.u._bg_0_5f_12-7-83.5f';l:$4000;p:$4000;crc:$394ab576));
        tapper_sprites:array[0..7] of tipo_roms=(
        (n:'tapper_video_fg_1_a7_12-7-83.a7';l:$4000;p:0;crc:$32509011),(n:'tapper_video_fg_0_a8_12-7-83.a8';l:$4000;p:$4000;crc:$8412c808),
        (n:'tapper_video_fg_3_a5_12-7-83.a5';l:$4000;p:$8000;crc:$818fffd4),(n:'tapper_video_fg_2_a6_12-7-83.a6';l:$4000;p:$c000;crc:$67e37690),
        (n:'tapper_video_fg_5_a3_12-7-83.a3';l:$4000;p:$10000;crc:$800f7c8a),(n:'tapper_video_fg_4_a4_12-7-83.a4';l:$4000;p:$14000;crc:$32674ee6),
        (n:'tapper_video_fg_7_a1_12-7-83.a1';l:$4000;p:$18000;crc:$070b4c81),(n:'tapper_video_fg_6_a2_12-7-83.a2';l:$4000;p:$1c000;crc:$a37aef36));
        dotron_rom:array[0..3] of tipo_roms=(
        (n:'disc_tron_uprt_pg0_10-4-83.1c';l:$4000;p:0;crc:$40d00195),(n:'disc_tron_uprt_pg1_10-4-83.2c';l:$4000;p:$4000;crc:$5a7d1300),
        (n:'disc_tron_uprt_pg2_10-4-83.3c';l:$4000;p:$8000;crc:$cb89c9be),(n:'disc_tron_uprt_pg3_10-4-83.4c';l:$2000;p:$c000;crc:$5098faf4));
        dotron_snd:array[0..3] of tipo_roms=(
        (n:'disc_tron_uprt_snd0_10-4-83.a7';l:$1000;p:0;crc:$7fb54293),(n:'disc_tron_uprt_snd1_10-4-83.a8';l:$1000;p:$1000;crc:$edef7326),
        (n:'disc_tron_uprt_snd2_9-22-83.a9';l:$1000;p:$2000;crc:$e8ef6519),(n:'disc_tron_uprt_snd3_9-22-83.a10';l:$1000;p:$3000;crc:$6b5aeb02));
        dotron_char:array[0..1] of tipo_roms=(
        (n:'loc-bg2.6f';l:$2000;p:0;crc:$40167124),(n:'loc-bg1.5f';l:$2000;p:$2000;crc:$bb2d7a5d));
        dotron_sprites:array[0..7] of tipo_roms=(
        (n:'loc-g.cp4';l:$2000;p:0;crc:$57a2b1ff),(n:'loc-h.cp3';l:$2000;p:$2000;crc:$3bb4d475),
        (n:'loc-e.cp6';l:$2000;p:$4000;crc:$ce957f1a),(n:'loc-f.cp5';l:$2000;p:$6000;crc:$d26053ce),
        (n:'loc-c.cp8';l:$2000;p:$8000;crc:$ef45d146),(n:'loc-d.cp7';l:$2000;p:$a000;crc:$5e8a3ef3),
        (n:'loc-a.cp0';l:$2000;p:$c000;crc:$b35f5374),(n:'loc-b.cp9';l:$2000;p:$e000;crc:$565a5c48));
        tron_rom:array[0..5] of tipo_roms=(
        (n:'scpu-pga_lctn-c2_tron_aug_9.c2';l:$2000;p:0;crc:$0de0471a),(n:'scpu-pgb_lctn-c3_tron_aug_9.c3';l:$2000;p:$2000;crc:$8ddf8717),
        (n:'scpu-pgc_lctn-c4_tron_aug_9.c4';l:$2000;p:$4000;crc:$4241e3a0),(n:'scpu-pgd_lctn-c5_tron_aug_9.c5';l:$2000;p:$6000;crc:$035d2fe7),
        (n:'scpu-pge_lctn-c6_tron_aug_9.c6';l:$2000;p:$8000;crc:$24c185d8),(n:'scpu-pgf_lctn-c7_tron_aug_9.c7';l:$2000;p:$a000;crc:$38c4bbaf));
        tron_snd:array[0..2] of tipo_roms=(
        (n:'ssi-0a_lctn-a7_tron.a7';l:$1000;p:0;crc:$765e6eba),(n:'ssi-0b_lctn-a8_tron.a8';l:$1000;p:$1000;crc:$1b90ccdd),
        (n:'ssi-0c_lctn-a9_tron.a9';l:$1000;p:$2000;crc:$3a4bc629));
        tron_char:array[0..1] of tipo_roms=(
        (n:'scpu-bgg_lctn-g3_tron.g3';l:$2000;p:0;crc:$1a9ed2f5),(n:'lscpu-bgh_lctn-g4_tron.g4';l:$2000;p:$2000;crc:$3220f974));
        tron_sprites:array[0..3] of tipo_roms=(
        (n:'vga_lctn-e1_tron.e1';l:$2000;p:0;crc:$bc036d1d),(n:'vgb_lctn-dc1_tron.dc1';l:$2000;p:$2000;crc:$58ee14d3),
        (n:'vgc_lctn-cb1_tron.cb1';l:$2000;p:$4000;crc:$3329f9d4),(n:'vgd_lctn-a1_tron.a1';l:$2000;p:$6000;crc:$9743f873));
        timber_rom:array[0..3] of tipo_roms=(
        (n:'timpg0.bin';l:$4000;p:0;crc:$377032ab),(n:'timpg1.bin';l:$4000;p:$4000;crc:$fd772836),
        (n:'timpg2.bin';l:$4000;p:$8000;crc:$632989f9),(n:'timpg3.bin';l:$2000;p:$c000;crc:$dae8a0dc));
        timber_snd:array[0..2] of tipo_roms=(
        (n:'tima7.bin';l:$1000;p:0;crc:$c615dc3e),(n:'tima8.bin';l:$1000;p:$1000;crc:$83841c87),
        (n:'tima9.bin';l:$1000;p:$2000;crc:$22bcdcd3));
        timber_char:array[0..1] of tipo_roms=(
        (n:'timbg1.bin';l:$4000;p:0;crc:$b1cb2651),(n:'timbg0.bin';l:$4000;p:$4000;crc:$2ae352c4));
        timber_sprites:array[0..7] of tipo_roms=(
        (n:'timfg1.bin';l:$4000;p:0;crc:$81de4a73),(n:'timfg0.bin';l:$4000;p:$4000;crc:$7f3a4f59),
        (n:'timfg3.bin';l:$4000;p:$8000;crc:$37c03272),(n:'timfg2.bin';l:$4000;p:$c000;crc:$e2c2885c),
        (n:'timfg5.bin';l:$4000;p:$10000;crc:$eb636216),(n:'timfg4.bin';l:$4000;p:$14000;crc:$b7105eb7),
        (n:'timfg7.bin';l:$4000;p:$18000;crc:$d9c27475),(n:'timfg6.bin';l:$4000;p:$1c000;crc:$244778e8));
        shollow_rom:array[0..5] of tipo_roms=(
        (n:'sh-pro.00';l:$2000;p:0;crc:$95e2b800),(n:'sh-pro.01';l:$2000;p:$2000;crc:$b99f6ff8),
        (n:'sh-pro.02';l:$2000;p:$4000;crc:$1202c7b2),(n:'sh-pro.03';l:$2000;p:$6000;crc:$0a64afb9),
        (n:'sh-pro.04';l:$2000;p:$8000;crc:$22fa9175),(n:'sh-pro.05';l:$2000;p:$a000;crc:$1716e2bb));
        shollow_snd:array[0..2] of tipo_roms=(
        (n:'sh-snd.01';l:$1000;p:0;crc:$55a297cc),(n:'sh-snd.02';l:$1000;p:$1000;crc:$46fc31f6),
        (n:'sh-snd.03';l:$1000;p:$2000;crc:$b1f4a6a8));
        shollow_char:array[0..1] of tipo_roms=(
        (n:'sh-bg.00';l:$2000;p:0;crc:$3e2b333c),(n:'sh-bg.01';l:$2000;p:$2000;crc:$d1d70cc4));
        shollow_sprites:array[0..3] of tipo_roms=(
        (n:'sh-fg.00';l:$2000;p:0;crc:$33f4554e),(n:'sh-fg.01';l:$2000;p:$2000;crc:$ba1a38b4),
        (n:'sh-fg.02';l:$2000;p:$4000;crc:$6b57f6da),(n:'sh-fg.03';l:$2000;p:$6000;crc:$37ea9d07));
        domino_rom:array[0..3] of tipo_roms=(
        (n:'dmanpg0.bin';l:$2000;p:0;crc:$3bf3bb1c),(n:'dmanpg1.bin';l:$2000;p:$2000;crc:$85cf1d69),
        (n:'dmanpg2.bin';l:$2000;p:$4000;crc:$7dd2177a),(n:'dmanpg3.bin';l:$2000;p:$6000;crc:$f2e0aa44));
        domino_snd:array[0..3] of tipo_roms=(
        (n:'dm-a7.snd';l:$1000;p:0;crc:$fa982dcc),(n:'dm-a8.snd';l:$1000;p:$1000;crc:$72839019),
        (n:'dm-a9.snd';l:$1000;p:$2000;crc:$ad760da7),(n:'dm-a10.snd';l:$1000;p:$3000;crc:$958c7287));
        domino_char:array[0..1] of tipo_roms=(
        (n:'dmanbg0.bin';l:$2000;p:0;crc:$9163007f),(n:'dmanbg1.bin';l:$2000;p:$2000;crc:$28615c56));
        domino_sprites:array[0..3] of tipo_roms=(
        (n:'dmanfg0.bin';l:$2000;p:0;crc:$0b1f9f9e),(n:'dmanfg1.bin';l:$2000;p:$2000;crc:$16aa4b9b),
        (n:'dmanfg2.bin';l:$2000;p:$4000;crc:$4a8e76b8),(n:'dmanfg3.bin';l:$2000;p:$6000;crc:$1f39257e));
        wacko_rom:array[0..3] of tipo_roms=(
        (n:'wackocpu.2d';l:$2000;p:0;crc:$c98e29b6),(n:'wackocpu.3d';l:$2000;p:$2000;crc:$90b89774),
        (n:'wackocpu.4d';l:$2000;p:$4000;crc:$515edff7),(n:'wackocpu.5d';l:$2000;p:$6000;crc:$9b01bf32));
        wacko_snd:array[0..2] of tipo_roms=(
        (n:'wackosnd.7a';l:$1000;p:0;crc:$1a58763f),(n:'wackosnd.8a';l:$1000;p:$1000;crc:$a4e3c771),
        (n:'wackosnd.9a';l:$1000;p:$2000;crc:$155ba3dd));
        wacko_char:array[0..1] of tipo_roms=(
        (n:'wackocpu.3g';l:$2000;p:0;crc:$33160eb1),(n:'wackocpu.4g';l:$2000;p:$2000;crc:$daf37d7c));
        wacko_sprites:array[0..3] of tipo_roms=(
        (n:'wackovid.1e';l:$2000;p:0;crc:$dca59be7),(n:'wackovid.1d';l:$2000;p:$2000;crc:$a02f1672),
        (n:'wackovid.1b';l:$2000;p:$4000;crc:$7d899790),(n:'wackovid.1a';l:$2000;p:$6000;crc:$080be3ad));
        //DIP
        tapper_dipa:array [0..3] of def_dip2=(
        (mask:4;name:'Demo Sounds';number:2;val2:(4,0);name2:('Off','On')),
        (mask:$40;name:'Cabinet';number:2;val2:($40,0);name2:('Upright','Cocktail')),
        (mask:$80;name:'Coin Meters';number:2;val2:($80,0);name2:('1','2')),());
        dotron_dipa:array [0..1] of def_dip2=(
        (mask:1;name:'Coin Meters';number:2;val2:(1,0);name2:('1','2')),());
        tron_dipa:array [0..3] of def_dip2=(
        (mask:1;name:'Coin Meters';number:2;val2:(1,0);name2:('1','2')),
        (mask:2;name:'Cabinet';number:2;val2:(0,2);name2:('Upright','Cocktail')),
        (mask:4;name:'Allow Continue';number:2;val2:(4,0);name2:('No','Yes')),());
        shollow_dipa:array [0..2] of def_dip2=(
        (mask:1;name:'Coin Meters';number:2;val2:(1,0);name2:('1','2')),
        (mask:2;name:'Cabinet';number:2;val2:(0,2);name2:('Upright','Cocktail')),());
        domino_dipa:array [0..4] of def_dip2=(
        (mask:1;name:'Music';number:2;val2:(1,0);name2:('Off','On')),
        (mask:2;name:'Skin Color';number:2;val2:(2,0);name2:('Light','Dark')),
        (mask:$40;name:'Cabinet';number:2;val2:(0,$40);name2:('Upright','Cocktail')),
        (mask:$80;name:'Coin Meters';number:2;val2:($80,0);name2:('1','2')),());
        CPU_SYNC=4;

var
 nvram:array[0..$7ff] of byte;
 update_video_mcr,eventos_mcr:procedure;
 //Sonido
 ssio_status:byte;
 ssio_data:array[0..3] of byte;
 ssio_14024_count:byte;

procedure update_video_tapper;
procedure put_sprite;
var
  f,color,atrib,x,y,pos_x,pos_y,pos_x_def:byte;
  pos:pbyte;
  dir_x,dir_y:integer;
  nchar,sx,sy:word;
  prio:array[0..$1ff,0..$1ff] of boolean;
begin
fillchar(prio,512*512,1);
for f:=$7f downto 0 do begin
  sx:=((memoria[$e803+(f*4)]-3)*2) and $1ff;
  sy:=((241-memoria[$e800+(f*4)])*2) and $1ff;
  atrib:=memoria[$e801+(f*4)];
  nchar:=(memoria[$e802+(f*4)]+((atrib and 8) shl 5)) mod gfx[1].elements;
  color:=(not(atrib) and 3) shl 4;
  pos:=gfx[1].datos;
  inc(pos,nchar*32*32);
  if (atrib and $20)<>0 then begin
    dir_y:=-1;
    pos_y:=31;
  end else begin
    dir_y:=1;
    pos_y:=0;
  end;
  if (atrib and $10)<>0 then begin
    dir_x:=-1;
    pos_x_def:=31;
  end else begin
    dir_x:=1;
    pos_x_def:=0;
  end;
  for y:=0 to 31 do begin
    pos_x:=pos_x_def;
    for x:=0 to 31 do begin
      if prio[(sx+pos_x) and $1ff,(sy+pos_y) and $1ff] then begin
        if (pos^ and $f)<>0 then begin
          prio[(sx+pos_x) and $1ff,(sy+pos_y) and $1ff]:=false;
          if (pos^ and 7)<>0 then begin
            punbuf^:=paleta[pos^ or color];
            putpixel_gfx_int(((sx+pos_x) and $1ff)+ADD_SPRITE,((sy+pos_y) and $1ff)+ADD_SPRITE,1,2);
          end;
        end;
      end;
      inc(pos);
      inc(pos_x,dir_x);
    end;
    inc(pos_y,dir_y);
  end;
end;
end;
var
  x,y:byte;
  atrib,f,nchar,color:word;
begin
for f:=0 to $3bf do begin
  atrib:=memoria[$f000+(f*2)] or (memoria[$f001+(f*2)] shl 8);
  color:=(atrib shr 12) and 3;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
    x:=f and $1f;
    y:=f shr 5;
    nchar:=atrib and $3ff;
    put_gfx_flip(x*16,y*16,nchar,color shl 4,1,0,(atrib and $400)<>0,(atrib and $800)<>0);
    gfx[0].buffer[f]:=false;
  end;
end;
actualiza_trozo(0,0,512,480,1,0,0,512,480,2);
put_sprite;
actualiza_trozo_final(0,0,512,480,2);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
end;

procedure update_video_tron;
var
  prio:array[0..$1f,0..$1f] of byte;
procedure put_sprite;
var
  f,atrib,x,y,pos_x,pos_y,pos_x_def:byte;
  pos:pbyte;
  dir_x,dir_y:integer;
  nchar,sx,sy:word;
  punt_def:byte;
begin
for f:=0 to $7f do begin
  sx:=((memoria[$e002+(f*4)]-4)*2) and $1ff;
  sy:=((240-memoria[$e000+(f*4)])*2) and $1ff;
  atrib:=memoria[$e001+(f*4)];
  nchar:=memoria[$e001+(f*4)] mod gfx[1].elements;
  pos:=gfx[1].datos;
  inc(pos,nchar*32*32);
  if (atrib and $80)<>0 then begin
    dir_y:=-1;
    pos_y:=31;
  end else begin
    dir_y:=1;
    pos_y:=0;
  end;
  if (atrib and $40)<>0 then begin
    dir_x:=-1;
    pos_x_def:=31;
  end else begin
    dir_x:=1;
    pos_x_def:=0;
  end;
  for y:=0 to 31 do begin
    pos_x:=pos_x_def;
    for x:=0 to 31 do begin
      punt_def:=(prio[((sx+pos_x) and $1ff) div 16,((sy+pos_y) and $1ff) div 16] shl 4) or pos^;
      if (punt_def and 7)<>0 then begin
        punbuf^:=paleta[punt_def];
        putpixel_gfx_int(((sx+pos_x) and $1ff)+ADD_SPRITE,((sy+pos_y) and $1ff)+ADD_SPRITE,1,2);
      end;
      inc(pos);
      inc(pos_x,dir_x);
    end;
    inc(pos_y,dir_y);
  end;
end;
end;
var
  x,y:byte;
  atrib,f,nchar,color:word;
begin
fillchar(prio,$20*$20,0);
for f:=0 to $3bf do begin
  atrib:=memoria[$e800+(f*2)] or (memoria[$e801+(f*2)] shl 8);
  color:=(atrib shr 11) and 3;
  x:=f and $1f;
  y:=f shr 5;
  prio[x,y]:=atrib shr 14;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
    nchar:=atrib and $3ff;
    put_gfx_flip(x*16,y*16,nchar,color shl 4,1,0,(atrib and $200)<>0,(atrib and $400)<>0);
    gfx[0].buffer[f]:=false;
  end;
end;
actualiza_trozo(0,0,512,480,1,0,0,512,480,2);
put_sprite;
actualiza_trozo_final(0,0,512,480,2);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
end;

procedure eventos_tapper;
begin
if event.arcade then begin
  //ip0
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  //ip1
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or 8);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  //ip2
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or 1);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or 2);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or 4);
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or 8);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
end;
end;

procedure eventos_dotron;
begin
marcade.in1:=analog.c[0].x[0] or $80;
if event.arcade then begin
  //ip0
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  //ip2
  if arcade_input.left[0] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or 1);
  if arcade_input.right[0] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or 2);
  if arcade_input.up[0] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or 4);
  if arcade_input.down[0] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or 8);
  if arcade_input.but2[0] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.but3[0] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.but1[0] then marcade.in2:=(marcade.in2 and $bf) else marcade.in2:=(marcade.in2 or $40);
end;
end;

procedure eventos_tron;
begin
marcade.in1:=analog.c[0].x[1];
if event.arcade then begin
  //ip0
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  //ip2
  if arcade_input.left[0] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or 1);
  if arcade_input.right[0] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or 2);
  if arcade_input.up[0] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or 4);
  if arcade_input.down[0] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or 8);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $bf) else marcade.in2:=(marcade.in2 or $40);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $7f) else marcade.in2:=(marcade.in2 or $80);
end;
end;

procedure eventos_shollow;
begin
if event.arcade then begin
  //ip0
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  //ip1
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or 8);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
end;
end;

procedure eventos_domino;
begin
if event.arcade then begin
  //ip0
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  //ip1
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or 8);
  //ip2
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or 1);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or 2);
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or 4);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or 8);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
end;
end;

procedure eventos_wacko;
begin
marcade.in1:=analog.c[0].x[0];
marcade.in2:=analog.c[0].y[0];
if event.arcade then begin
  //ip0
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  //ip2
  if arcade_input.right[0] then marcade.in3:=(marcade.in3 and $fe) else marcade.in3:=(marcade.in3 or 1);
  if arcade_input.left[0] then marcade.in3:=(marcade.in3 and $fd) else marcade.in3:=(marcade.in3 or 2);
  if arcade_input.down[0] then marcade.in3:=(marcade.in3 and $fb) else marcade.in3:=(marcade.in3 or 4);
  if arcade_input.up[0] then marcade.in3:=(marcade.in3 and $f7) else marcade.in3:=(marcade.in3 or 8);
  if arcade_input.right[1] then marcade.in3:=(marcade.in3 and $ef) else marcade.in3:=(marcade.in3 or $10);
  if arcade_input.left[1] then marcade.in3:=(marcade.in3 and $df) else marcade.in3:=(marcade.in3 or $20);
  if arcade_input.down[1] then marcade.in3:=(marcade.in3 and $bf) else marcade.in3:=(marcade.in3 or $40);
  if arcade_input.up[1] then marcade.in3:=(marcade.in3 and $7f) else marcade.in3:=(marcade.in3 or $80);
end;
end;

procedure mcr_principal;
var
  f:word;
  h:byte;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
  for f:=0 to 479 do begin
    eventos_mcr;
    case f of
      0:begin
          ctc_0.trigger(2,true);
          ctc_0.trigger(2,false);
          update_video_mcr;
          ctc_0.trigger(3,true);
          ctc_0.trigger(3,false);
        end;
      240:begin
            ctc_0.trigger(2,true);
            ctc_0.trigger(2,false);
          end;
    end;
    for h:=1 to CPU_SYNC do begin
      //Main CPU
      z80_0.run(frame_main);
      frame_main:=frame_main+z80_0.tframes-z80_0.contador;
      //Sound
      z80_1.run(frame_sub);
      frame_sub:=frame_sub+z80_1.tframes-z80_1.contador;
    end;
  end;
  video_sync;
end;
end;

function tapper_getbyte(direccion:word):byte;
begin
case direccion of
  0..$dfff,$f000..$f7ff:tapper_getbyte:=memoria[direccion];
  $e000..$e7ff:tapper_getbyte:=nvram[direccion and $7ff];
  $e800..$ebff:tapper_getbyte:=memoria[$e800+(direccion and $1ff)];
  $ec00..$efff,$f800..$ffff:tapper_getbyte:=$ff;
end;
end;

procedure cambiar_color(pos:byte;tmp_color:word);
var
  color:tcolor;
begin
  color.r:=pal3bit(tmp_color shr 6);
  color.g:=pal3bit(tmp_color shr 0);
  color.b:=pal3bit(tmp_color shr 3);
  set_pal_color(color,pos);
  buffer_color[(pos shr 4) and 3]:=true;
end;

procedure tapper_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$dfff:; //ROM
  $e000..$e7ff:nvram[direccion and $7ff]:=valor;
  $e800..$ebff:memoria[$e800+(direccion and $1ff)]:=valor;
  $f000..$f7ff:begin
                  memoria[direccion]:=valor;
                  gfx[0].buffer[(direccion and $7ff) shr 1]:=true;
               end;
  $f800..$ffff:cambiar_color((direccion and $7f) shr 1,valor or ((direccion and 1) shl 8));
end;
end;

function tapper_inbyte(puerto:word):byte;
begin
case (puerto and $ff) of
  0..$1f:case (puerto and 7) of
            0:tapper_inbyte:=marcade.in0;
            1:tapper_inbyte:=marcade.in1;
            2:tapper_inbyte:=marcade.in2;
            3:tapper_inbyte:=marcade.dswa;
            4:tapper_inbyte:=marcade.in3;
	          7:tapper_inbyte:=ssio_status;
          end;
  $f0..$f3:tapper_inbyte:=ctc_0.read(puerto and 3);
end;
end;

procedure tapper_outbyte(puerto:word;valor:byte);
begin
case (puerto and $ff) of
  0..7:;
	$1c..$1f:ssio_data[puerto and 3]:=valor;
  $e0:; //wathcdog
  $e8:;
  $f0..$f3:ctc_0.write(puerto and 3,valor);
end;
end;

//Tron
function tron_getbyte(direccion:word):byte;
begin
case direccion of
  0..$bfff:tron_getbyte:=memoria[direccion];
  $c000..$dfff:tron_getbyte:=nvram[direccion and $7ff];
  $e000..$ffff:case (direccion and $fff) of
                  0..$7ff:tron_getbyte:=memoria[$e000+(direccion and $1ff)];
                  $800..$fff:tron_getbyte:=memoria[$e800+(direccion and $7ff)];
               end;
end;
end;

procedure tron_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$bfff:; //ROM
  $c000..$dfff:nvram[direccion and $7ff]:=valor;
  $e000..$ffff:case (direccion and $fff) of
                  0..$7ff:memoria[$e000+(direccion and $1ff)]:=valor;
                  $800..$fff:begin
                                memoria[$e800+(direccion and $7ff)]:=valor;
                                gfx[0].buffer[(direccion and $7ff) shr 1]:=true;
                                if (direccion and $780)=$780 then cambiar_color((direccion and $7f) shr 1,valor or ((direccion and 1) shl 8));
                             end;
               end;
end;
end;

function snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$3fff:snd_getbyte:=mem_snd[direccion];
  $8000..$8fff:snd_getbyte:=mem_snd[$8000 or (direccion and $3ff)];
  $9000..$9fff:snd_getbyte:=ssio_data[direccion and $3];
  $a000..$afff:if (direccion and 3)=1 then snd_getbyte:=ay8910_0.read;
  $b000..$bfff:if (direccion and 3)=1 then snd_getbyte:=ay8910_1.read;
  $e000..$efff:begin
                ssio_14024_count:=0;
                z80_1.change_irq(CLEAR_LINE);
               end;
  $f000..$ffff:snd_getbyte:=$ff; //DIP
end;
end;

procedure snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$3fff:; //ROM
  $8000..$8fff:mem_snd[$8000 or (direccion and $3ff)]:=valor;
  $a000..$afff:case (direccion and 3) of
                 0:ay8910_0.control(valor);
                 2:ay8910_0.write(valor);
               end;
  $b000..$bfff:case (direccion and 3) of
                 0:ay8910_1.control(valor);
                 2:ay8910_1.write(valor);
               end;
  $c000..$cfff:ssio_status:=valor;
end;
end;

procedure z80ctc_int(state:byte);
begin
  z80_0.change_irq(state);
end;

procedure mcr_snd_irq;
begin
  //
	//  /SINT is generated as follows:
	//
	//  Starts with a 16MHz oscillator
	//      /2 via 7474 flip-flop @ F11
	//      /16 via 74161 binary counter @ E11
	//      /10 via 74190 decade counter @ D11
	//
	//  Bit 3 of the decade counter clocks a 14024 7-bit async counter @ C12.
	//  This routine is called to clock this 7-bit counter.
	//  Bit 6 of the output is inverted and connected to /SINT.
	//
	ssio_14024_count:=(ssio_14024_count+1) and $7f;
	// if the low 5 bits clocked to 0, bit 6 has changed state
	if ((ssio_14024_count and $3f)=0) then
    if (ssio_14024_count and $40)<>0 then z80_1.change_irq(ASSERT_LINE)
      else z80_1.change_irq(CLEAR_LINE);
end;

procedure mcr_update_sound;
begin
  tsample[ay8910_0.get_sample_num,sound_status.posicion_sonido]:=ay8910_0.update_internal^;
  tsample[ay8910_0.get_sample_num,sound_status.posicion_sonido+1]:=ay8910_1.update_internal^;
end;

//Main
procedure mcr_reset;
begin
z80_0.reset;
z80_1.reset;
frame_main:=z80_0.tframes;
frame_sub:=z80_1.tframes;
ctc_0.reset;
ay8910_0.reset;
ay8910_1.reset;
marcade.in0:=$ff;
marcade.in1:=$ff;
marcade.in2:=$ff;
marcade.in3:=$ff;
//Sonido
ssio_status:=0;
fillchar(ssio_data[0],4,0);
ssio_14024_count:=0;
end;

procedure close_mcr;
begin
case main_vars.tipo_maquina of
  324:write_file(Directory.Arcade_nvram+'tapper.nv',@nvram,$800);
  411:write_file(Directory.Arcade_nvram+'dotron.nv',@nvram,$800);
  412:write_file(Directory.Arcade_nvram+'tron.nv',@nvram,$800);
  413:write_file(Directory.Arcade_nvram+'timber.nv',@nvram,$800);
  414:write_file(Directory.Arcade_nvram+'shollow.nv',@nvram,$800);
  415:write_file(Directory.Arcade_nvram+'domino.nv',@nvram,$800);
  416:write_file(Directory.Arcade_nvram+'wacko.nv',@nvram,$800);
end;
end;

function iniciar_mcr:boolean;
var
  memoria_temp:array[0..$1ffff] of byte;
  longitud:integer;
procedure convert_chars(num:word);
const
  pc_x:array[0..15] of dword=(0*2, 0*2, 1*2, 1*2, 2*2, 2*2, 3*2, 3*2,
    4*2, 4*2, 5*2, 5*2, 6*2, 6*2, 7*2, 7*2);
  pc_y:array[0..15] of dword=(0*16, 0*16, 1*16, 1*16, 2*16, 2*16, 3*16, 3*16,
    4*16, 4*16, 5*16, 5*16, 6*16, 6*16, 7*16, 7*16);
begin
init_gfx(0,16,16,num);
gfx_set_desc_data(4,0,16*8,num*16*8,(num*16*8)+1,0,1);
convert_gfx(0,0,@memoria_temp,@pc_x,@pc_y,false,false);
end;
procedure convert_sprites(num:word);
const
  ps_x:array[0..31] of dword=(0, 4, $100*32*32, $100*32*32+4, $200*32*32, $200*32*32+4, $300*32*32, $300*32*32+4,
			8, 12, $100*32*32+8, $100*32*32+12, $200*32*32+8, $200*32*32+12, $300*32*32+8, $300*32*32+12,
			16, 20, $100*32*32+16, $100*32*32+20, $200*32*32+16, $200*32*32+20, $300*32*32+16, $300*32*32+20,
			24, 28, $100*32*32+24, $100*32*32+28, $200*32*32+24, $200*32*32+28, $300*32*32+24, $300*32*32+28);
  ps_x_dt:array[0..31] of dword=(0, 4, $80*32*32, $80*32*32+4, $100*32*32, $100*32*32+4, $180*32*32, $180*32*32+4,
			8, 12, $80*32*32+8, $80*32*32+12, $100*32*32+8, $100*32*32+12, $180*32*32+8, $180*32*32+12,
			16, 20, $80*32*32+16, $80*32*32+20, $100*32*32+16, $100*32*32+20, $180*32*32+16, $180*32*32+20,
			24, 28, $80*32*32+24, $80*32*32+28, $100*32*32+24, $100*32*32+28, $180*32*32+24, $180*32*32+28);
  ps_x_t:array[0..31] of dword=(0, 4, $40*32*32, $40*32*32+4, $80*32*32, $80*32*32+4, $c0*32*32, $c0*32*32+4,
			8, 12, $40*32*32+8, $40*32*32+12, $80*32*32+8, $80*32*32+12, $c0*32*32+8, $c0*32*32+12,
			16, 20, $40*32*32+16, $40*32*32+20, $80*32*32+16, $80*32*32+20, $c0*32*32+16, $c0*32*32+20,
			24, 28, $40*32*32+24, $40*32*32+28, $80*32*32+24, $80*32*32+28, $c0*32*32+24, $c0*32*32+28);
  ps_y:array[0..31] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32,
			8*32, 9*32, 10*32, 11*32, 12*32, 13*32, 14*32, 15*32,
			16*32, 17*32, 18*32, 19*32, 20*32, 21*32, 22*32, 23*32,
      24*32, 25*32, 26*32, 27*32, 28*32, 29*32, 30*32, 31*32);
begin
init_gfx(1,32,32,num);
gfx_set_desc_data(4,0,32*32,0,1,2,3);
case num of
  $40:convert_gfx(1,0,@memoria_temp,@ps_x_t,@ps_y,false,false);
  $80:convert_gfx(1,0,@memoria_temp,@ps_x_dt,@ps_y,false,false);
  $100:convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,false);
end;
end;
begin
llamadas_maquina.bucle_general:=mcr_principal;
llamadas_maquina.reset:=mcr_reset;
llamadas_maquina.fps_max:=30;
llamadas_maquina.close:=close_mcr;
iniciar_mcr:=false;
iniciar_audio(true);
if ((main_vars.tipo_maquina=412) or (main_vars.tipo_maquina=414)) then main_screen.rot90_screen:=true;
screen_init(1,512,480);
screen_init(2,512,512,false,true);
iniciar_video(512,480);
//Main CPU
z80_0:=cpu_z80.create(5000000,480*CPU_SYNC);
z80_0.change_io_calls(tapper_inbyte,tapper_outbyte);
z80_0.enable_daisy;
ctc_0:=tz80ctc.create(z80_0.numero_cpu,5000000,z80_0.clock,0,CTC0_TRG01);
ctc_0.change_calls(z80ctc_int);
z80daisy_init(Z80_CTC0_TYPE);
//Sound CPU
z80_1:=cpu_z80.create(2000000,480*CPU_SYNC);
z80_1.change_ram_calls(snd_getbyte,snd_putbyte);
z80_1.init_sound(mcr_update_sound);
timers.init(z80_1.numero_cpu,2000000/(160*2*16*10),mcr_snd_irq,nil,true);
//Sound Chip
ay8910_0:=ay8910_chip.create(2000000,AY8910);
ay8910_1:=ay8910_chip.create(2000000,AY8910,1,true);
case main_vars.tipo_maquina of
  324:begin
        z80_0.change_ram_calls(tapper_getbyte,tapper_putbyte);
        eventos_mcr:=eventos_tapper;
        update_video_mcr:=update_video_tapper;
        //cargar roms
        if not(roms_load(@memoria,tapper_rom)) then exit;
        //cargar roms sonido
        if not(roms_load(@mem_snd,tapper_snd)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,tapper_char)) then exit;
        convert_chars($400);
        //sprites
        if not(roms_load(@memoria_temp,tapper_sprites)) then exit;
        convert_sprites($100);
        //Cargar NVRam
        if read_file_size(Directory.Arcade_nvram+'tapper.nv',longitud) then read_file(Directory.Arcade_nvram+'tapper.nv',@nvram,longitud)
          else fillchar(nvram,$800,0);
        //DIP
        marcade.dswa:=$c0;
        marcade.dswa_val2:=@tapper_dipa;
      end;
  411:begin
        z80_0.change_ram_calls(tapper_getbyte,tapper_putbyte);
        eventos_mcr:=eventos_dotron;
        update_video_mcr:=update_video_tapper;
        init_analog(z80_0.numero_cpu,z80_0.clock);
        analog_0(50,2,0,$7f,0,false,true,false,true);
        main_screen.flip_main_x:=true;
        //cargar roms
        if not(roms_load(@memoria,dotron_rom)) then exit;
        //cargar roms sonido
        if not(roms_load(@mem_snd,dotron_snd)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,dotron_char)) then exit;
        convert_chars($200);
        //sprites
        if not(roms_load(@memoria_temp,dotron_sprites)) then exit;
        convert_sprites($80);
        //Cargar NVRam
        if read_file_size(Directory.Arcade_nvram+'dotron.nv',longitud) then read_file(Directory.Arcade_nvram+'dotron.nv',@nvram,longitud)
          else fillchar(nvram,$800,0);
        //DIP
        marcade.dswa:=$ff;
        marcade.dswa_val2:=@dotron_dipa;
      end;
  412:begin
        z80_0.change_ram_calls(tron_getbyte,tron_putbyte);
        eventos_mcr:=eventos_tron;
        update_video_mcr:=update_video_tron;
        init_analog(z80_0.numero_cpu,z80_0.clock);
        analog_0(50,2,0,$ff,0,false,true,false,true);
        //cargar roms
        if not(roms_load(@memoria,tron_rom)) then exit;
        //cargar roms sonido
        if not(roms_load(@mem_snd,tron_snd)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,tron_char)) then exit;
        convert_chars($200);
        //sprites
        if not(roms_load(@memoria_temp,tron_sprites)) then exit;
        convert_sprites($40);
        //Cargar NVRam
        if read_file_size(Directory.Arcade_nvram+'tron.nv',longitud) then read_file(Directory.Arcade_nvram+'tron.nv',@nvram,longitud)
          else fillchar(nvram,$800,0);
        //DIP
        marcade.dswa:=0;
        marcade.dswa_val2:=@tron_dipa;
      end;
  413:begin
        z80_0.change_ram_calls(tapper_getbyte,tapper_putbyte);
        eventos_mcr:=eventos_tapper;
        update_video_mcr:=update_video_tapper;
        //cargar roms
        if not(roms_load(@memoria,timber_rom)) then exit;
        //cargar roms sonido
        if not(roms_load(@mem_snd,timber_snd)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,timber_char)) then exit;
        convert_chars($400);
        //sprites
        if not(roms_load(@memoria_temp,timber_sprites)) then exit;
        convert_sprites($100);
        //Cargar NVRam
        if read_file_size(Directory.Arcade_nvram+'timber.nv',longitud) then read_file(Directory.Arcade_nvram+'timber.nv',@nvram,longitud)
          else fillchar(nvram,$800,0);
        //DIP
        marcade.dswa:=$c0;
        marcade.dswa_val2:=@tapper_dipa;
      end;
      414:begin
        z80_0.change_ram_calls(tron_getbyte,tron_putbyte);
        eventos_mcr:=eventos_shollow;
        update_video_mcr:=update_video_tron;
        //cargar roms
        if not(roms_load(@memoria,shollow_rom)) then exit;
        //cargar roms sonido
        if not(roms_load(@mem_snd,shollow_snd)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,shollow_char)) then exit;
        convert_chars($200);
        //sprites
        if not(roms_load(@memoria_temp,shollow_sprites)) then exit;
        convert_sprites($40);
        //Cargar NVRam
        if read_file_size(Directory.Arcade_nvram+'shollow.nv',longitud) then read_file(Directory.Arcade_nvram+'shollow.nv',@nvram,longitud)
          else fillchar(nvram,$800,0);
        //DIP
        marcade.dswa:=$fd;
        marcade.dswa_val2:=@shollow_dipa;
      end;
      415:begin
        z80_0.change_ram_calls(tron_getbyte,tron_putbyte);
        eventos_mcr:=eventos_domino;
        update_video_mcr:=update_video_tron;
        //cargar roms
        if not(roms_load(@memoria,domino_rom)) then exit;
        //cargar roms sonido
        if not(roms_load(@mem_snd,domino_snd)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,domino_char)) then exit;
        convert_chars($200);
        //sprites
        if not(roms_load(@memoria_temp,domino_sprites)) then exit;
        convert_sprites($40);
        //Cargar NVRam
        if read_file_size(Directory.Arcade_nvram+'domino.nv',longitud) then read_file(Directory.Arcade_nvram+'domino.nv',@nvram,longitud)
          else fillchar(nvram,$800,0);
        //DIP
        marcade.dswa:=$3e;
        marcade.dswa_val2:=@domino_dipa;
      end;
      416:begin
        z80_0.change_ram_calls(tron_getbyte,tron_putbyte);
        eventos_mcr:=eventos_wacko;
        update_video_mcr:=update_video_tron;
        init_analog(z80_0.numero_cpu,z80_0.clock);
        analog_0(50,2,0,$7f,0,false,true,true,false);
        //cargar roms
        if not(roms_load(@memoria,wacko_rom)) then exit;
        //cargar roms sonido
        if not(roms_load(@mem_snd,wacko_snd)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,wacko_char)) then exit;
        convert_chars($200);
        //sprites
        if not(roms_load(@memoria_temp,wacko_sprites)) then exit;
        convert_sprites($40);
        //Cargar NVRam
        if read_file_size(Directory.Arcade_nvram+'wacko.nv',longitud) then read_file(Directory.Arcade_nvram+'wacko.nv',@nvram,longitud)
          else fillchar(nvram,$800,0);
        //DIP
        marcade.dswa:=$3e;
        marcade.dswa_val2:=@domino_dipa;
      end;
end;
iniciar_mcr:=true;
end;

end.
