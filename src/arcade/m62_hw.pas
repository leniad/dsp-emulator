unit m62_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,m680x,main_engine,controls_engine,ay_8910,gfx_engine,
     msm5205,rom_engine,pal_engine,sound_engine;

function iniciar_irem_m62:boolean;

implementation
const
        //Kung-Fu Master
        kungfum_rom:array[0..1] of tipo_roms=(
        (n:'a-4e-c.bin';l:$4000;p:0;crc:$b6e2d083),(n:'a-4d-c.bin';l:$4000;p:$4000;crc:$7532918e));
        kungfum_pal:array[0..6] of tipo_roms=(
        (n:'g-1j-.bin';l:$100;p:0;crc:$668e6bca),(n:'g-1f-.bin';l:$100;p:$100;crc:$964b6495),
        (n:'g-1h-.bin';l:$100;p:$200;crc:$550563e1),(n:'b-1m-.bin';l:$100;p:$300;crc:$76c05a9c),
        (n:'b-1n-.bin';l:$100;p:$400;crc:$23f06b99),(n:'b-1l-.bin';l:$100;p:$500;crc:$35e45021),
        (n:'b-5f-.bin';l:$20;p:$600;crc:$7a601c3d));
        kungfum_char:array[0..2] of tipo_roms=(
        (n:'g-4c-a.bin';l:$2000;p:0;crc:$6b2cc9c8),(n:'g-4d-a.bin';l:$2000;p:$2000;crc:$c648f558),
        (n:'g-4e-a.bin';l:$2000;p:$4000;crc:$fbe9276e));
        kungfum_sound:array[0..2] of tipo_roms=(
        (n:'a-3e-.bin';l:$2000;p:$a000;crc:$58e87ab0),(n:'a-3f-.bin';l:$2000;p:$c000;crc:$c81e31ea),
        (n:'a-3h-.bin';l:$2000;p:$e000;crc:$d99fb995));
        kungfum_sprites:array[0..11] of tipo_roms=(
        (n:'b-4k-.bin';l:$2000;p:0;crc:$16fb5150),(n:'b-4f-.bin';l:$2000;p:$2000;crc:$67745a33),
        (n:'b-4l-.bin';l:$2000;p:$4000;crc:$bd1c2261),(n:'b-4h-.bin';l:$2000;p:$6000;crc:$8ac5ed3a),
        (n:'b-3n-.bin';l:$2000;p:$8000;crc:$28a213aa),(n:'b-4n-.bin';l:$2000;p:$a000;crc:$d5228df3),
        (n:'b-4m-.bin';l:$2000;p:$c000;crc:$b16de4f2),(n:'b-3m-.bin';l:$2000;p:$e000;crc:$eba0d66b),
        (n:'b-4c-.bin';l:$2000;p:$10000;crc:$01298885),(n:'b-4e-.bin';l:$2000;p:$12000;crc:$c77b87d4),
        (n:'b-4d-.bin';l:$2000;p:$14000;crc:$6a70615f),(n:'b-4a-.bin';l:$2000;p:$16000;crc:$6189d626));
        //Dip
        kungfum_dip_a:array [0..3] of def_dip2=(
        (mask:1;name:'Difficulty';number:2;val2:(1,0);name2:('Easy','Hard')),
        (mask:2;name:'Energy Loss';number:2;val2:(2,0);name2:('Slow','Fast')),
        (mask:$c;name:'Lives';number:4;val4:(8,$c,4,0);name4:('2','3','4','5')),
        (mask:$f0;name:'Coinage';number:16;val16:($90,$a0,$b0,$c0,$d0,$e0,$f0,$70,$60,$50,$40,$30,$20,$10,0,0);name16:('7C 1C','6C 1C','5C 1C','4C 1C','3C 1C','2C 1C','1C 1C','1C 2C','1C 3C','1C 4C','1C 5C','1C 6C','1C 7C','1C 8C','Free Play','')));
        kungfum_dip_b:array [0..7] of def_dip2=(
        (mask:1;name:'Flip Screen';number:2;val2:(1,0);name2:('Off','On')),
        (mask:2;name:'Cabinet';number:2;val2:(0,2);name2:('Upright','Cocktail')),
        (mask:4;name:'Coin Mode';number:2;val2:(4,0);name2:('Mode 1','Mode 2')),
        (mask:8;name:'Slow Motion Mode';number:2;val2:(8,0);name2:('Off','On')),
        (mask:$10;name:'Freeze';number:2;val2:($10,0);name2:('Off','On')),
        (mask:$20;name:'Level Selection Mode';number:2;val2:($20,0);name2:('Off','On')),
        (mask:$40;name:'Invulnerability';number:2;val2:($40,0);name2:('Off','On')),
        (mask:$80;name:'Service';number:2;val2:($80,0);name2:('Off','On')));
        //Spelunker
        spl_rom:array[0..3] of tipo_roms=(
        (n:'spra.4e';l:$4000;p:0;crc:$cf811201),(n:'spra.4d';l:$4000;p:$4000;crc:$bb4faa4f),
        (n:'sprm.7c';l:$4000;p:$8000;crc:$fb6197e2),(n:'sprm.7b';l:$4000;p:$c000;crc:$26bb25a4));
        spl_pal:array[0..6] of tipo_roms=(
        (n:'sprm.2k';l:$100;p:0;crc:$fd8fa991),(n:'sprm.2j';l:$100;p:$100;crc:$0e3890b4),
        (n:'sprm.2h';l:$100;p:$200;crc:$0478082b),(n:'sprb.1m';l:$100;p:$300;crc:$8d8cccad),
        (n:'sprb.1n';l:$100;p:$400;crc:$c40e1cb2),(n:'sprb.1l';l:$100;p:$500;crc:$3ec46248),
        (n:'sprb.5p';l:$20;p:$600;crc:$746c6238));
        spl_char:array[0..2] of tipo_roms=(
        (n:'sprm.4p';l:$4000;p:0;crc:$4dfe2e63),(n:'sprm.4l';l:$4000;p:$4000;crc:$239f2cd4),
        (n:'sprm.4m';l:$4000;p:$8000;crc:$d6d07d70));
        spl_sound:array[0..1] of tipo_roms=(
        (n:'spra.3d';l:$4000;p:$8000;crc:$4110363c),(n:'spra.3f';l:$4000;p:$c000;crc:$67a9d2e6));
        spl_sprites:array[0..5] of tipo_roms=(
        (n:'sprb.4k';l:$4000;p:0;crc:$e7f0e861),(n:'sprb.4f';l:$4000;p:$4000;crc:$32663097),
        (n:'sprb.3p';l:$4000;p:$8000;crc:$8fbaf373),(n:'sprb.4p';l:$4000;p:$c000;crc:$37069b76),
        (n:'sprb.4c';l:$4000;p:$10000;crc:$cfe46a88),(n:'sprb.4e';l:$4000;p:$14000;crc:$11c48979));
        spl_tiles:array[0..5] of tipo_roms=(
        (n:'sprm.1d';l:$4000;p:0;crc:$4ef7ae89),(n:'sprm.1e';l:$4000;p:$4000;crc:$a3755180),
        (n:'sprm.3c';l:$4000;p:$8000;crc:$b4008e6a),(n:'sprm.3b';l:$4000;p:$c000;crc:$f61cf012),
        (n:'sprm.1c';l:$4000;p:$10000;crc:$58b21c76),(n:'sprm.1b';l:$4000;p:$14000;crc:$a95cb3e5));
        //Spelunker II
        spl2_rom:array[0..4] of tipo_roms=(
        (n:'sp2-a.4e';l:$4000;p:0;crc:$96c04bbb),(n:'sp2-a.4d';l:$4000;p:$4000;crc:$cb38c2ff),
        (n:'sp2-r.7d';l:$8000;p:$8000;crc:$558837ea),(n:'sp2-r.7c';l:$8000;p:$10000;crc:$4b380162),
        (n:'sp2-r.7b';l:$4000;p:$18000;crc:$7709a1fe));
        spl2_pal:array[0..6] of tipo_roms=(
        (n:'sp2-r.1k';l:$200;p:0;crc:$31c1bcdc),(n:'sp2-r.2k';l:$100;p:$200;crc:$1cf5987e),
        (n:'sp2-r.2j';l:$100;p:$300;crc:$1acbe2a5),(n:'sp2-b.1m';l:$100;p:$400;crc:$906104c7),
        (n:'sp2-b.1n';l:$100;p:$500;crc:$5a564c06),(n:'sp2-b.1l';l:$100;p:$600;crc:$8f4a2e3c),
        (n:'sp2-b.5p';l:$20;p:$700;crc:$cd126f6a));
        spl2_char:array[0..2] of tipo_roms=(
        (n:'sp2-r.4l';l:$4000;p:0;crc:$6a4b2d8b),(n:'sp2-r.4m';l:$4000;p:$4000;crc:$e1368b61),
        (n:'sp2-r.4p';l:$4000;p:$8000;crc:$fc138e13));
        spl2_sound:array[0..1] of tipo_roms=(
        (n:'sp2-a.3d';l:$4000;p:$8000;crc:$839ec7e2),(n:'sp2-a.3f';l:$4000;p:$c000;crc:$ad3ce898));
        spl2_sprites:array[0..5] of tipo_roms=(
        (n:'sp2-b.4k';l:$4000;p:0;crc:$6cb67a17),(n:'sp2-b.4f';l:$4000;p:$4000;crc:$e4a1166f),
        (n:'sp2-b.3n';l:$4000;p:$8000;crc:$f59e8b76),(n:'sp2-b.4n';l:$4000;p:$c000;crc:$fa65bac9),
        (n:'sp2-b.4c';l:$4000;p:$10000;crc:$1caf7013),(n:'sp2-b.4e';l:$4000;p:$14000;crc:$780a463b));
        spl2_tiles:array[0..2] of tipo_roms=(
        (n:'sp2-r.1d';l:$8000;p:0;crc:$c19fa4c9),(n:'sp2-r.3b';l:$8000;p:$8000;crc:$366604af),
        (n:'sp2-r.1b';l:$8000;p:$10000;crc:$3a0c4d47));
        //Lode Runner
        ldrun_rom:array[0..3] of tipo_roms=(
        (n:'lr-a-4e';l:$2000;p:0;crc:$5d7e2a4d),(n:'lr-a-4d';l:$2000;p:$2000;crc:$96f20473),
        (n:'lr-a-4b';l:$2000;p:$4000;crc:$b041c4a9),(n:'lr-a-4a';l:$2000;p:$6000;crc:$645e42aa));
        ldrun_pal:array[0..6] of tipo_roms=(
        (n:'lr-e-3m';l:$100;p:0;crc:$53040416),(n:'lr-e-3l';l:$100;p:$100;crc:$67786037),
        (n:'lr-e-3n';l:$100;p:$200;crc:$5b716837),(n:'lr-b-1m';l:$100;p:$300;crc:$4bae1c25),
        (n:'lr-b-1n';l:$100;p:$400;crc:$9cd3db94),(n:'lr-b-1l';l:$100;p:$500;crc:$08d8cf9a),
        (n:'lr-b-5p';l:$20;p:$600;crc:$e01f69e2));
        ldrun_char:array[0..2] of tipo_roms=(
        (n:'lr-e-2d';l:$2000;p:0;crc:$24f9b58d),(n:'lr-e-2j';l:$2000;p:$2000;crc:$43175e08),
        (n:'lr-e-2f';l:$2000;p:$4000;crc:$e0317124));
        ldrun_sound:array[0..1] of tipo_roms=(
        (n:'lr-a-3f';l:$2000;p:$c000;crc:$7a96accd),(n:'lr-a-3h';l:$2000;p:$e000;crc:$3f7f3939));
        ldrun_sprites:array[0..2] of tipo_roms=(
        (n:'lr-b-4k';l:$2000;p:0;crc:$8141403e),(n:'lr-b-3n';l:$2000;p:$2000;crc:$55154154),
        (n:'lr-b-4c';l:$2000;p:$4000;crc:$924e34d0));
        //Lode Runner II
        ldrun2_rom:array[0..5] of tipo_roms=(
        (n:'lr2-a-4e.a';l:$2000;p:0;crc:$22313327),(n:'lr2-a-4d';l:$2000;p:$2000;crc:$ef645179),
        (n:'lr2-a-4a.a';l:$2000;p:$4000;crc:$b11ddf59),(n:'lr2-a-4a';l:$2000;p:$6000;crc:$470cc8a1),
        (n:'lr2-h-1c.a';l:$2000;p:$8000;crc:$7ebcadbc),(n:'lr2-h-1d.a';l:$2000;p:$a000;crc:$64cbb7f9));
        ldrun2_pal:array[0..6] of tipo_roms=(
        (n:'lr2-h-3m';l:$100;p:0;crc:$2c5d834b),(n:'lr2-h-3l';l:$100;p:$100;crc:$3ae69aca),
        (n:'lr2-h-3n';l:$100;p:$200;crc:$2b28aec5),(n:'lr2-b-1m';l:$100;p:$300;crc:$4ec9bb3d),
        (n:'lr2-b-1n';l:$100;p:$400;crc:$1daf1fa4),(n:'lr2-b-1l';l:$100;p:$500;crc:$c8fb708a),
        (n:'lr2-b-5p';l:$20;p:$600;crc:$e01f69e2));
        ldrun2_char:array[0..2] of tipo_roms=(
        (n:'lr2-h-1e';l:$2000;p:0;crc:$9d63a8ff),(n:'lr2-h-1j';l:$2000;p:$2000;crc:$40332bbd),
        (n:'lr2-h-1h';l:$2000;p:$4000;crc:$9404727d));
        ldrun2_sound:array[0..2] of tipo_roms=(
        (n:'lr2-a-3e';l:$2000;p:$a000;crc:$853f3898),(n:'lr2-a-3f';l:$2000;p:$c000;crc:$7a96accd),
        (n:'lr2-a-3h';l:$2000;p:$e000;crc:$2a0e83ca));
        ldrun2_sprites:array[0..5] of tipo_roms=(
        (n:'lr2-b-4k';l:$2000;p:0;crc:$79909871),(n:'lr2-b-4f';l:$2000;p:$2000;crc:$06ba1ef4),
        (n:'lr2-b-3n';l:$2000;p:$4000;crc:$3cc5893f),(n:'lr2-b-4n';l:$2000;p:$6000;crc:$49c12f42),
        (n:'lr2-b-4c';l:$2000;p:$8000;crc:$fbe6d24c),(n:'lr2-b-4e';l:$2000;p:$a000;crc:$75172d1f));

var
 sound_command,val_port1,val_port2,ldrun_color,sprites_sp:byte;
 scroll_x,scroll_y:word;
 memoria_sprites:array[0..$1f] of byte;
 mem_rom:array[0..3,0..$1fff] of byte;
 mem_rom2:array[0..15,0..$fff] of byte;
 rom_bank,rom_bank2,pal_bank,ldrun2_banksw,old_bank:byte;
 update_video_m62:procedure;
 calc_nchar_sp:function(color:byte):word;

procedure draw_sprites(pos,col,col_mask,pri_mask,pri:byte);
var
  f,atrib,atrib2:byte;
  a,b,c,d,nchar,x,y,color:word;
  flipx,flipy:boolean;
begin
for f:=0 to $1f do begin
  atrib2:=memoria[$c000+(f*8)];
  if ((atrib2 and pri_mask)=pri) then begin
    atrib:=memoria[$c005+(f*8)];
    nchar:=memoria[$c004+(f*8)]+((atrib and 7) shl 8);
    color:=((atrib2 and col_mask) shl 3)+(256*col);
    x:=((memoria[$c007+(f*8)] and 1) shl 8)+memoria[$c006+(f*8)];
    y:=256+(128*pos)-15-(256*(memoria[$c003+(f*8)] and 1)+memoria[$c002+(f*8)]);
    flipx:=(atrib and $40)<>0;
    flipy:=(atrib and $80)<>0;
    case (memoria_sprites[(nchar shr 5) and $1f] and 3) of
      0:begin
          put_gfx_sprite(nchar,color,flipx,flipy,1);
          actualiza_gfx_sprite(x,y,2,1);
        end;
      1:begin //doble
          nchar:=nchar and $fffe;
          if flipy then begin
            a:=nchar+1;
            b:=nchar;
          end else begin
            a:=nchar;
            b:=nchar+1;
          end;
          put_gfx_sprite_diff(a,color,flipx,flipy,1,0,0);
          put_gfx_sprite_diff(b,color,flipx,flipy,1,0,16);
          actualiza_gfx_sprite_size(x,y-16,2,16,32);
        end;
      2:begin //Cuadruple
  			  nchar:=nchar and $fffc;
          if flipy then begin
            a:=nchar+3;
            b:=nchar+2;
            c:=nchar+1;
            d:=nchar;
          end else begin
            a:=nchar;
            b:=nchar+1;
            c:=nchar+2;
            d:=nchar+3;
          end;
  			  put_gfx_sprite_diff(a,color,flipx,flipy,1,0,0);
          put_gfx_sprite_diff(b,color,flipx,flipy,1,0,16);
          put_gfx_sprite_diff(c,color,flipx,flipy,1,0,32);
          put_gfx_sprite_diff(d,color,flipx,flipy,1,0,48);
          actualiza_gfx_sprite_size(x,y-48,2,16,64);
        end;
    end;
  end;
end;
end;

procedure update_video_kungfum;
var
  f,nchar,y,x:word;
  atrib,color:byte;
  flipx:boolean;
begin
for f:=0 to $7ff do begin
  if gfx[0].buffer[f] then begin
    x:=f mod 64;
    y:=f div 64;
    atrib:=memoria[$d800+f];
    color:=atrib and $1f;
    nchar:=memoria[$d000+f]+((atrib and $c0) shl 2);
    flipx:=(atrib and $20)<>0;
    put_gfx_flip(x*8,y*8,nchar,color shl 3,1,0,flipx,false);
    if not((y<6) or ((color shr 1)>$c)) then put_gfx_block_trans(x*8,y*8,3,8,8)
      else put_gfx_flip(x*8,y*8,nchar,color shl 3,3,0,flipx,false);
    gfx[0].buffer[f]:=false;
  end;
end;
scroll_x_cut(1,2,scroll_x,48,208);
draw_sprites(1,1,$1f,0,0);
scroll_x_cut(3,2,scroll_x,48,208); //La parte de arriba tiene prioridad sobre los sprites?
actualiza_trozo(128,0,256,48,1,128,0,256,48,2);
actualiza_trozo_final(128,0,256,256,2);
end;

procedure update_video_ldrun;
var
  f,nchar,y,x:word;
  atrib,color:byte;
  flipx:boolean;
begin
for f:=0 to $7ff do begin
  if gfx[0].buffer[f] then begin
    x:=f mod 64;
    y:=f div 64;
    atrib:=memoria[$d001+(f*2)];
    color:=atrib and $1f;
    nchar:=memoria[$d000+(f*2)]+((atrib and $c0) shl 2);
    flipx:=(atrib and $20)<>0;
    put_gfx_flip(x*8,y*8,nchar,color shl 3,1,0,flipx,false);
    if not((color shr 1)>=ldrun_color) then put_gfx_block_trans(x*8,y*8,3,8,8)
      else put_gfx_trans_flip(x*8,y*8,nchar,color shl 3,3,0,flipx,false);
    gfx[0].buffer[f]:=false;
  end;
end;
actualiza_trozo(64,0,384,256,1,64,0,384,256,2);
draw_sprites(1,1,$f,$10,0);
actualiza_trozo(64,0,384,256,3,64,0,384,256,2);
draw_sprites(1,1,$f,$10,$10);
actualiza_trozo_final(64,0,384,256,2);
end;

function calc_nchar_splunker(color:byte):word;
begin
  calc_nchar_splunker:=((color and $10) shl 4)+((color and $20) shl 6)+((color and $c0) shl 3);
end;

function calc_nchar_splunker2(color:byte):word;
begin
  calc_nchar_splunker2:=(color and $f0) shl 4;
end;

procedure update_video_spelunker;
var
  f,x,y:word;
  color,nchar:word;
begin
for f:=0 to $3ff do begin
  if gfx[0].buffer[f] then begin
    x:=f mod 32;
    y:=f div 32;
    color:=memoria[$c801+(f*2)];
    nchar:=memoria[$c800+(f*2)]+((color and $10) shl 4);
    put_gfx_trans(x*12,y*8,nchar,(pal_bank or (color and $f)) shl 3,3,0);
    gfx[0].buffer[f]:=false;
  end;
end;
for f:=0 to $fff do begin
  if gfx[2].buffer[f] then begin
    x:=f mod 64;
    y:=f div 64;
    color:=memoria[$a001+(f*2)];
    nchar:=memoria[$a000+(f*2)]+calc_nchar_sp(color);
    put_gfx(x*8,y*8,nchar,(pal_bank or (color and $f)) shl 3,1,2);
    gfx[2].buffer[f]:=false;
  end;
end;
scroll_x_y(1,2,scroll_x,scroll_y);
draw_sprites(2,sprites_sp,$1f,0,0);
actualiza_trozo(0,0,384,256,3,64,128,384,256,2);
actualiza_trozo_final(64,128,384,256,2);
end;

procedure eventos_irem_m62;
begin
if event.arcade then begin
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or 8);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
end;
end;

procedure irem_m62_principal;
var
  f:word;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
  for f:=0 to 283 do begin
    eventos_irem_m62;
    if f=256 then begin
      z80_0.change_irq(HOLD_LINE);
      update_video_m62;
    end;
    //main
    z80_0.run(frame_main);
    frame_main:=frame_main+z80_0.tframes-z80_0.contador;
    //snd
    m6800_0.run(frame_snd);
    frame_snd:=frame_snd+m6800_0.tframes-m6800_0.contador;
  end;
  video_sync;
end;
end;

//KungFu Master
function kungfum_getbyte(direccion:word):byte;
begin
  case direccion of
    0..$7fff,$d000..$efff:kungfum_getbyte:=memoria[direccion];
  end;
end;

procedure kungfum_putbyte(direccion:word;valor:byte);
begin
case direccion of
    0..$7fff:;
    $a000:scroll_x:=(scroll_x and $100) or valor;
    $b000:scroll_x:=(scroll_x and $ff) or ((valor and 1) shl 8);
    $c000..$c0ff,$e000..$efff:memoria[direccion]:=valor;
    $d000..$dfff:if memoria[direccion]<>valor then begin
                    gfx[0].buffer[direccion and $7ff]:=true;
                    memoria[direccion]:=valor;
                 end;
end;
end;

function kungfum_inbyte(puerto:word):byte;
begin
case (puerto and $ff) of
  0:kungfum_inbyte:=marcade.in0;
  1:kungfum_inbyte:=marcade.in1;
  2:kungfum_inbyte:=marcade.in2;
  3:kungfum_inbyte:=marcade.dswa;
  4:kungfum_inbyte:=marcade.dswb;
end;
end;

procedure kungfum_outbyte(puerto:word;valor:byte);
begin
case (puerto and $ff) of
  0:if ((valor and $80)=0) then sound_command:=valor and $7f
    	else m6800_0.change_irq(ASSERT_LINE);
end;
end;

//Spelunker
function spl_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff,$a000..$bfff,$c800..$cfff,$e000..$efff:spl_getbyte:=memoria[direccion];
  $8000..$9fff:spl_getbyte:=mem_rom[rom_bank,direccion and $1fff];
end;
end;

procedure spl_putbyte(direccion:word;valor:byte);
begin
case direccion of
    0..$9fff:;
    $a000..$bfff:if memoria[direccion]<>valor then begin
                    gfx[2].buffer[(direccion and $1fff) shr 1]:=true;
                    memoria[direccion]:=valor;
                 end;
    $c000..$c0ff,$e000..$efff:memoria[direccion]:=valor;
    $c800..$cfff:if memoria[direccion]<>valor then begin
                    gfx[0].buffer[(direccion and $7ff) shr 1]:=true;
                    memoria[direccion]:=valor;
                 end;
    $d000:scroll_y:=(scroll_y and $100) or valor;
    $d001:scroll_y:=(scroll_y and $ff) or ((valor and 1) shl 8);
    $d002:scroll_x:=(scroll_x and $100) or valor;
    $d003:scroll_x:=(scroll_x and $ff) or ((valor and 1) shl 8);
    $d004:rom_bank:=(valor and 3);
    $d005:if pal_bank<>((valor and 1) shl 4) then begin
            pal_bank:=(valor and 1) shl 4;
            fillchar(gfx[0].buffer[0],$400,1);
            fillchar(gfx[2].buffer[0],$1000,1);
          end;
end;
end;

//Spelunker II
function spl2_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff,$a000..$bfff,$c800..$cfff,$e000..$efff:spl2_getbyte:=memoria[direccion];
  $8000..$8fff:spl2_getbyte:=mem_rom[rom_bank,direccion and $fff];
  $9000..$9fff:spl2_getbyte:=mem_rom2[rom_bank2,direccion and $fff];
end;
end;

procedure spl2_putbyte(direccion:word;valor:byte);
begin
case direccion of
    0..$9fff:;
    $a000..$bfff:if memoria[direccion]<>valor then begin
                    gfx[2].buffer[(direccion and $1fff) shr 1]:=true;
                    memoria[direccion]:=valor;
                 end;
    $c000..$c0ff,$e000..$efff:memoria[direccion]:=valor;
    $c800..$cfff:if memoria[direccion]<>valor then begin
                    gfx[0].buffer[(direccion and $7ff) shr 1]:=true;
                    memoria[direccion]:=valor;
                 end;
    $d000:scroll_y:=(scroll_y and $100) or valor;
    $d001:scroll_x:=(scroll_x and $100) or valor;
    $d002:begin
            scroll_x:=(scroll_x and $ff) or ((valor and 2) shl 7);
	          scroll_y:=(scroll_y and $ff) or ((valor and 1) shl 8);
          	if (pal_bank<>((valor and $c) shl 2)) then begin
                		pal_bank:=(valor and $c) shl 2;
		                fillchar(gfx[0].buffer[0],$400,1);
                    fillchar(gfx[2].buffer[0],$1000,1);
            end;
          end;
    $d003:begin
            rom_bank:=(valor and $c0) shr 6;
            rom_bank2:=(valor and $3c) shr 2;
          end;
end;
end;

//Lode Runner
procedure ldrun_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:;
  $c000..$c0ff,$e000..$efff:memoria[direccion]:=valor;
  $d000..$dfff:if memoria[direccion]<>valor then begin
                  gfx[0].buffer[(direccion and $fff) shr 1]:=true;
                  memoria[direccion]:=valor;
               end;
end;
end;

//Lode Runner II
function ldrun2_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff,$d000..$dfff,$e000..$efff:ldrun2_getbyte:=memoria[direccion];
  $8000..$9fff:ldrun2_getbyte:=mem_rom[rom_bank,direccion and $1fff];
end;
end;

function ldrun2_inbyte(puerto:word):byte;
begin
case (puerto and $ff) of
  0:ldrun2_inbyte:=marcade.in0;
  1:ldrun2_inbyte:=marcade.in1;
  2:ldrun2_inbyte:=marcade.in2;
  3:ldrun2_inbyte:=marcade.dswa;
  4:ldrun2_inbyte:=marcade.dswb;
  $80:begin
        if (ldrun2_banksw<>0) then begin
      		ldrun2_banksw:=ldrun2_banksw-1;
      		// swap to bank #1 on second read
      		if (ldrun2_banksw=0) then rom_bank:=1;
        end;
        ldrun2_inbyte:=0;
      end;
end;
end;

procedure ldrun2_outbyte(puerto:word;valor:byte);
const
  banks:array[1..30] of byte=(
		0,0,0,0,0,1,0,1,0,0,
		0,1,1,1,1,1,0,0,0,0,
		1,0,1,1,1,1,1,1,1,1);
begin
case (puerto and $ff) of
  0:if ((valor and $80)=0) then sound_command:=valor and $7f
    	else m6800_0.change_irq(ASSERT_LINE);
  $80:begin
        rom_bank:=banks[valor];
        old_bank:=valor;
      end;
  $81:if ((old_bank=1) and (valor=$d)) then	ldrun2_banksw:=2
        else ldrun2_banksw:=0;
end;
end;

//sonido
function snd_getbyte(direccion:word):byte;
begin
case direccion of
  $4000..$ffff:snd_getbyte:=mem_snd[direccion];
end;
end;

procedure snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  $800..$8ff:case direccion and 3 of
                  0:m6800_0.change_irq(CLEAR_LINE);
                  1:msm5205_0.data_w(valor);
                  2:msm5205_1.data_w(valor);
               end;
  $4000..$ffff:;
end;
end;

procedure out_port1(valor:byte);
begin
  val_port1:=valor;
end;

procedure out_port2(valor:byte);
begin
  if (((val_port2 and 1)<>0) and ((not(valor and 1))<>0)) then begin
		if (val_port2 and 4)<>0 then begin
			if (val_port2 and 8)<>0 then ay8910_0.control(val_port1);
			if (val_port2 and $10)<>0 then ay8910_1.control(val_port1);
		end else begin
			if (val_port2 and 8)<>0 then ay8910_0.write(val_port1);
			if (val_port2 and $10)<>0 then ay8910_1.write(val_port1);
		end;
	end;
  val_port2:=valor;
end;

function in_port1:byte;
begin
	if (val_port2 and 8)<>0 then in_port1:=ay8910_0.read
    else if (val_port2 and $10)<>0 then in_port1:=ay8910_1.read;
end;

function in_port2:byte;
begin
  in_port2:=0;
end;

function ay0_porta_r:byte;
begin
  ay0_porta_r:=sound_command;
end;

procedure ay0_portb_w(valor:byte);
begin
	msm5205_0.reset_w((valor and 1)<>0);
  msm5205_1.reset_w((valor and 2)<>0);
end;

procedure adpcm_int;
begin
  m6800_0.change_nmi(PULSE_LINE);
end;

procedure irem_m62_play_sound;
begin
  ay8910_0.update;
  ay8910_1.update;
  msm5205_0.update;
  msm5205_1.update;
end;

//Main
procedure reset_irem_m62;
begin
 z80_0.reset;
 m6800_0.reset;
 ay8910_0.reset;
 ay8910_1.reset;
 msm5205_0.reset;
 msm5205_1.reset;
 frame_main:=z80_0.tframes;
 frame_snd:=m6800_0.tframes;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 rom_bank:=0;
 rom_bank2:=0;
 pal_bank:=0;
 sound_command:=0;
 val_port1:=0;
 val_port2:=0;
 scroll_x:=0;
 scroll_y:=0;
 ldrun2_banksw:=0;
 old_bank:=0;
end;

function iniciar_irem_m62:boolean;
var
  f,x:word;
  memoria_temp:array[0..$1ffff] of byte;
const
  ps_x:array[0..15] of dword=(0, 1, 2, 3, 4, 5, 6, 7,
			16*8+0, 16*8+1, 16*8+2, 16*8+3, 16*8+4, 16*8+5, 16*8+6, 16*8+7);
  ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8);
procedure cargar_paleta;
var
  colores:tpaleta;
  f:byte;
begin
for f:=0 to $ff do begin
    //Chars
    colores[f].r:=((memoria_temp[f] and $f) shl 4) or (memoria_temp[f] and $f);
    colores[f].g:=((memoria_temp[f+$100] and $f) shl 4) or (memoria_temp[f+$100] and $f);
    colores[f].b:=((memoria_temp[f+$200] and $f) shl 4) or (memoria_temp[f+$200] and $f);
    //Sprites
    colores[f+$100].r:=((memoria_temp[f+$300] and $f) shl 4) or (memoria_temp[f] and $f);
    colores[f+$100].g:=((memoria_temp[f+$400] and $f) shl 4) or (memoria_temp[f+$100] and $f);
    colores[f+$100].b:=((memoria_temp[f+$500] and $f) shl 4) or (memoria_temp[f+$200] and $f);
end;
set_pal(colores,512);
end;
procedure cargar_paleta_spl2;
var
  colores:tpaleta;
  f:word;
begin
for f:=0 to $1ff do begin
    //Chars
    colores[f].r:=((memoria_temp[f] and $f) shl 4) or (memoria_temp[f] and $f);
    colores[f].g:=((memoria_temp[f] and $f0) shr 4) or (memoria_temp[f] and $f0);
    colores[f].b:=((memoria_temp[f+$200] and $f) shl 4) or (memoria_temp[f+$200] and $f);
end;
for f:=0 to $ff do begin
    colores[f+$200].r:=((memoria_temp[f+$400] and $f) shl 4) or (memoria_temp[f+$400] and $f);
    colores[f+$200].g:=((memoria_temp[f+$500] and $f) shl 4) or (memoria_temp[f+$500] and $f);
    colores[f+$200].b:=((memoria_temp[f+$600] and $f) shl 4) or (memoria_temp[f+$600] and $f);
end;
set_pal(colores,768);
end;
procedure make_chars_spl;
const
    pc_spl_x:array[0..11] of dword=(0,1,2,3,
		    $2000*8+0,$2000*8+1,$2000*8+2,$2000*8+3,
    		$2000*8+4,$2000*8+5,$2000*8+6,$2000*8+7);
var
  mem_char:array[0..$bfff] of byte;
begin
  copymemory(@mem_char[$0000],@memoria_temp[$0000],$800);
  copymemory(@mem_char[$2000],@memoria_temp[$0800],$800);
  copymemory(@mem_char[$0800],@memoria_temp[$1000],$800);
  copymemory(@mem_char[$2800],@memoria_temp[$1800],$800);
  copymemory(@mem_char[$1000],@memoria_temp[$2000],$800);
  copymemory(@mem_char[$3000],@memoria_temp[$2800],$800);
  copymemory(@mem_char[$1800],@memoria_temp[$3000],$800);
  copymemory(@mem_char[$3800],@memoria_temp[$3800],$800);
  copymemory(@mem_char[$4000],@memoria_temp[$4000],$800);
  copymemory(@mem_char[$6000],@memoria_temp[$4800],$800);
  copymemory(@mem_char[$4800],@memoria_temp[$5000],$800);
  copymemory(@mem_char[$6800],@memoria_temp[$5800],$800);
  copymemory(@mem_char[$5000],@memoria_temp[$6000],$800);
  copymemory(@mem_char[$7000],@memoria_temp[$6800],$800);
  copymemory(@mem_char[$5800],@memoria_temp[$7000],$800);
  copymemory(@mem_char[$7800],@memoria_temp[$7800],$800);
  copymemory(@mem_char[$8000],@memoria_temp[$8000],$800);
  copymemory(@mem_char[$a000],@memoria_temp[$8800],$800);
  copymemory(@mem_char[$8800],@memoria_temp[$9000],$800);
  copymemory(@mem_char[$a800],@memoria_temp[$9800],$800);
  copymemory(@mem_char[$9000],@memoria_temp[$a000],$800);
  copymemory(@mem_char[$b000],@memoria_temp[$a800],$800);
  copymemory(@mem_char[$9800],@memoria_temp[$b000],$800);
  copymemory(@mem_char[$b800],@memoria_temp[$b800],$800);
  init_gfx(0,12,8,$200);
  gfx[0].trans[0]:=true;
  gfx_set_desc_data(3,0,8*8,0,$4000*8,2*$4000*8);
  convert_gfx(0,0,@mem_char[0],@pc_spl_x[0],@ps_y[0],false,false);
end;
procedure make_chars(num:word;ngfx:byte);
begin
init_gfx(ngfx,8,8,num);
gfx_set_desc_data(3,0,8*8,2*num*8*8,num*8*8,0);
convert_gfx(ngfx,0,@memoria_temp[0],@ps_x[0],@ps_y[0],false,false);
end;
procedure make_sprites(num:word);
begin
  init_gfx(1,16,16,num);
  gfx[1].trans[0]:=true;
  gfx_set_desc_data(3,0,32*8,2*num*32*8,num*32*8,0);
  convert_gfx(1,0,@memoria_temp[0],@ps_x[0],@ps_y[0],false,false);
end;

begin
llamadas_maquina.bucle_general:=irem_m62_principal;
llamadas_maquina.reset:=reset_irem_m62;
llamadas_maquina.fps_max:=56.338028;
llamadas_maquina.scanlines:=284;
iniciar_irem_m62:=false;
fillchar(memoria_temp[0],$20000,0);
iniciar_audio(false);
screen_init(1,512,512);
screen_init(2,512,512,false,true);
screen_init(3,512,512,true);
case main_vars.tipo_maquina of
  42:x:=256;
  72..75:x:=384;
end;
iniciar_video(x,256);
//Sound CPU
m6800_0:=cpu_m6800.create(3579545,TCPU_M6803);
m6800_0.change_ram_calls(snd_getbyte,snd_putbyte);
m6800_0.change_io_calls(in_port1,in_port2,nil,nil,out_port1,out_port2,nil,nil);
m6800_0.init_sound(irem_m62_play_sound);
//sound chips
msm5205_0:=MSM5205_chip.create(384000,MSM5205_S96_4B,1,0);
msm5205_1:=MSM5205_chip.create(384000,MSM5205_SEX_4B,1,0);
msm5205_0.change_advance(adpcm_int);
msm5205_1.change_advance(nil);
ay8910_0:=ay8910_chip.create(3579545 div 4,AY8910);
ay8910_0.change_io_calls(ay0_porta_r,nil,nil,ay0_portb_w);
ay8910_1:=ay8910_chip.create(3579545 div 4,AY8910);
case main_vars.tipo_maquina of
  42:begin  //KungFu Master
        //Main CPU
        z80_0:=cpu_z80.create(3072000);
        z80_0.change_ram_calls(kungfum_getbyte,kungfum_putbyte);
        z80_0.change_io_calls(kungfum_inbyte,kungfum_outbyte);
        //video
        update_video_m62:=update_video_kungfum;
        //cargar roms
        if not(roms_load(@memoria,kungfum_rom)) then exit;
        //cargar sonido
        if not(roms_load(@mem_snd,kungfum_sound)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,kungfum_char)) then exit;
        make_chars(1024,0);
        gfx[0].trans[0]:=true;
        //convertir sprites
        if not(roms_load(@memoria_temp,kungfum_sprites)) then exit;
        make_sprites(1024);
        //poner la paleta
        if not(roms_load(@memoria_temp,kungfum_pal)) then exit;
        cargar_paleta;
        copymemory(@memoria_sprites[0],@memoria_temp[$600],$20);
        init_dips(1,kungfum_dip_a,0);
        init_dips(2,kungfum_dip_b,0);
     end;
     72:begin  //Spelunker
        //Main CPU
        z80_0:=cpu_z80.create(4000000);
        z80_0.change_ram_calls(spl_getbyte,spl_putbyte);
        z80_0.change_io_calls(kungfum_inbyte,kungfum_outbyte);
        //video
        update_video_m62:=update_video_spelunker;
        calc_nchar_sp:=calc_nchar_splunker;
        sprites_sp:=1;
        //cargar roms y ponerlas en sus bancos
        if not(roms_load(@memoria_temp,spl_rom)) then exit;
        copymemory(@memoria[0],@memoria_temp[0],$8000);
        for f:=0 to 3 do copymemory(@mem_rom[f,0],@memoria_temp[$8000+(f*$2000)],$2000);
        //cargar sonido
        if not(roms_load(@mem_snd,spl_sound)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,spl_char)) then exit;
        make_chars_spl;
        //convertir sprites
        if not(roms_load(@memoria_temp,spl_sprites)) then exit;
        make_sprites($400);
        //convertir tiles
        if not(roms_load(@memoria_temp,spl_tiles)) then exit;
        make_chars(4096,2);
        //poner la paleta
        if not(roms_load(@memoria_temp,spl_pal)) then exit;
        cargar_paleta;
        copymemory(@memoria_sprites[0],@memoria_temp[$600],$20);
     end;
     73:begin  //Spelunker II
        //Main CPU
        z80_0:=cpu_z80.create(4000000);
        z80_0.change_ram_calls(spl2_getbyte,spl2_putbyte);
        z80_0.change_io_calls(kungfum_inbyte,kungfum_outbyte);
        //video
        update_video_m62:=update_video_spelunker;
        calc_nchar_sp:=calc_nchar_splunker2;
        sprites_sp:=2;
        //cargar roms y ponerlas en sus bancos (2)
        if not(roms_load(@memoria_temp,spl2_rom)) then exit;
        copymemory(@memoria[0],@memoria_temp[0],$8000);
        for f:=0 to 15 do copymemory(@mem_rom2[f,0],@memoria_temp[$8000+(f*$1000)],$1000);
        for f:=0 to 3 do copymemory(@mem_rom[f,0],@memoria_temp[$18000+(f*$1000)],$1000);
        //cargar sonido
        if not(roms_load(@mem_snd,spl2_sound)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,spl2_char)) then exit;
        make_chars_spl;
        //convertir sprites
        if not(roms_load(@memoria_temp,spl2_sprites)) then exit;
        make_sprites($400);
        //convertir tiles
        if not(roms_load(@memoria_temp,spl2_tiles)) then exit;
        make_chars(4096,2);
        //poner la paleta
        if not(roms_load(@memoria_temp,spl2_pal)) then exit;
        cargar_paleta_spl2;
        copymemory(@memoria_sprites[0],@memoria_temp[$700],$20);
     end;
     74:begin  //Lode Runner
        //Main CPU
        z80_0:=cpu_z80.create(4000000);
        z80_0.change_ram_calls(kungfum_getbyte,ldrun_putbyte);
        z80_0.change_io_calls(kungfum_inbyte,kungfum_outbyte);
        //video
        update_video_m62:=update_video_ldrun;
        ldrun_color:=$c;
        //cargar roms
        if not(roms_load(@memoria,ldrun_rom)) then exit;
        //cargar sonido
        if not(roms_load(@mem_snd,ldrun_sound)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,ldrun_char)) then exit;
        make_chars($400,0);
        gfx[0].trans[0]:=true;
        //convertir sprites
        if not(roms_load(@memoria_temp,ldrun_sprites)) then exit;
        make_sprites($100);
        //poner la paleta
        if not(roms_load(@memoria_temp,ldrun_pal)) then exit;
        cargar_paleta;
        copymemory(@memoria_sprites[0],@memoria_temp[$600],$20);
     end;
     75:begin  //Lode Runner II
        //Main CPU
        z80_0:=cpu_z80.create(4000000);
        z80_0.change_ram_calls(ldrun2_getbyte,ldrun_putbyte);
        z80_0.change_io_calls(ldrun2_inbyte,ldrun2_outbyte);
        //video
        update_video_m62:=update_video_ldrun;
        ldrun_color:=4;
        //cargar roms y ponerlas en sus bancos
        if not(roms_load(@memoria_temp,ldrun2_rom)) then exit;
        copymemory(@memoria[0],@memoria_temp[0],$8000);
        for f:=0 to 1 do copymemory(@mem_rom[f,0],@memoria_temp[$8000+(f*$2000)],$2000);
        //cargar sonido
        if not(roms_load(@mem_snd,ldrun2_sound)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,ldrun2_char)) then exit;
        make_chars($400,0);
        gfx[0].trans[0]:=true;
        //convertir sprites
        if not(roms_load(@memoria_temp,ldrun2_sprites)) then exit;
        make_sprites($200);
        //poner la paleta
        if not(roms_load(@memoria_temp,ldrun2_pal)) then exit;
        cargar_paleta;
        copymemory(@memoria_sprites[0],@memoria_temp[$600],$20);
     end;
end;
marcade.dswa:=$ff;
marcade.dswb:=$fd;
//final
iniciar_irem_m62:=true;
end;

end.
