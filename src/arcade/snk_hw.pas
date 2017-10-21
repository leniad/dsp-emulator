unit snk_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,gfx_engine,rom_engine,
     pal_engine,sound_engine,ym_3812,timer_engine;

procedure cargar_snk;

implementation
const
        //ikari
        ikari_main:tipo_roms=(n:'1.rom';l:$10000;p:0;crc:$52a8b2dd);
        ikari_sub:tipo_roms=(n:'2.rom';l:$10000;p:0;crc:$45364d55);
        ikari_snd:tipo_roms=(n:'3.rom';l:$10000;p:0;crc:$56a26699);
        ikari_gfx1:tipo_roms=(n:'7.rom';l:$4000;p:0;crc:$a7eb4917);
        ikari_gfx2:array[0..3] of tipo_roms=(
        (n:'17.rom';l:$8000;p:0;crc:$e0dba976),(n:'18.rom';l:$8000;p:$8000;crc:$24947d5f),
        (n:'19.rom';l:$8000;p:$10000;crc:$9ee59e91),(n:'20.rom';l:$8000;p:$18000;crc:$5da7ec1a));
        ikari_sprite16:array[0..2] of tipo_roms=(
        (n:'8.rom';l:$8000;p:0;crc:$9827c14a),(n:'9.rom';l:$8000;p:$8000;crc:$545c790c),
        (n:'10.rom';l:$8000;p:$10000;crc:$ec9ba07e));
        ikari_sprite32:array[0..5] of tipo_roms=(
        (n:'11.rom';l:$8000;p:0;crc:$5c75ea8f),(n:'14.rom';l:$8000;p:$8000;crc:$3293fde4),
        (n:'12.rom';l:$8000;p:$10000;crc:$95138498),(n:'15.rom';l:$8000;p:$18000;crc:$65a61c99),
        (n:'13.rom';l:$8000;p:$20000;crc:$315383d7),(n:'16.rom';l:$8000;p:$28000;crc:$e9b03e07));
        ikari_proms:array[0..2] of tipo_roms=(
        (n:'7122er.prm';l:$400;p:0;crc:$b9bf2c2c),(n:'7122eg.prm';l:$400;p:$400;crc:$0703a770),
        (n:'7122eb.prm';l:$400;p:$800;crc:$0a11cdde));
        ikari_dip_a:array [0..5] of def_dip=(
        (mask:$1;name:'Allow killing each other';number:2;dip:((dip_val:$1;dip_name:'No'),(dip_val:$0;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2;name:'P1 && P2 Fire Buttons';number:2;dip:((dip_val:$2;dip_name:'Separate'),(dip_val:$0;dip_name:'Common'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Lives';number:2;dip:((dip_val:$8;dip_name:'3'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Coin A';number:4;dip:((dip_val:$0;dip_name:'4C 1C'),(dip_val:$10;dip_name:'3C 1C'),(dip_val:$20;dip_name:'2C 1C'),(dip_val:$30;dip_name:'1C 1C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Coin B';number:4;dip:((dip_val:$0;dip_name:'1C 2C'),(dip_val:$40;dip_name:'1C 3C'),(dip_val:$80;dip_name:'1C 4C'),(dip_val:$c0;dip_name:'1C 6C'),(),(),(),(),(),(),(),(),(),(),(),())),());
        ikari_dip_b:array [0..3] of def_dip=(
        (mask:$3;name:'Difficulty';number:4;dip:((dip_val:$3;dip_name:'Easy'),(dip_val:$2;dip_name:'Normal'),(dip_val:$1;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Game Mode';number:4;dip:((dip_val:$c;dip_name:'Demo Sounds Off'),(dip_val:$8;dip_name:'Demo Sounds On'),(dip_val:$4;dip_name:'Freeze'),(dip_val:$0;dip_name:'Infinite Lives (Cheat)'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Allow Continue';number:2;dip:((dip_val:$0;dip_name:'Yes'),(dip_val:$80;dip_name:'No'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        ikari_dip_c:array [0..1] of def_dip=(
        (mask:$34;name:'Bonus Life';number:7;dip:((dip_val:$34;dip_name:'50K 100K 100K+'),(dip_val:$24;dip_name:'60K 120K 120K+'),(dip_val:$14;dip_name:'100K 200K 200K+'),(dip_val:$30;dip_name:'50K 100K'),(dip_val:$20;dip_name:'60K 120K'),(dip_val:$10;dip_name:'100K 200K'),(dip_val:$0;dip_name:'None'),(),(),(),(),(),(),(),(),())),());
        //athena
        athena_main:array[0..1] of tipo_roms=(
        (n:'up02_p4.rom';l:$4000;p:0;crc:$900a113c),(n:'up02_m4.rom';l:$8000;p:$4000;crc:$61c69474));
        athena_sub:array[0..1] of tipo_roms=(
        (n:'up02_p8.rom';l:$4000;p:0;crc:$df50af7e),(n:'up02_m8.rom';l:$8000;p:$4000;crc:$f3c933df));
        athena_snd:array[0..1] of tipo_roms=(
        (n:'up02_g6.rom';l:$4000;p:0;crc:$42dbe029),(n:'up02_k6.rom';l:$8000;p:$4000;crc:$596f1c8a));
        athena_gfx1:tipo_roms=(n:'up01_d2.rom';l:$4000;p:0;crc:$18b4bcca);
        athena_gfx2:tipo_roms=(n:'up01_b2.rom';l:$8000;p:0;crc:$f269c0eb);
        athena_sprite16:array[0..2] of tipo_roms=(
        (n:'up01_p2.rom';l:$8000;p:0;crc:$c63a871f),(n:'up01_s2.rom';l:$8000;p:$8000;crc:$760568d8),
        (n:'up01_t2.rom';l:$8000;p:$10000;crc:$57b35c73));
        athena_proms:array[0..2] of tipo_roms=(
        (n:'up02_c2.rom';l:$400;p:0;crc:$294279ae),(n:'up02_b1.rom';l:$400;p:$400;crc:$d25c9099),
        (n:'up02_c1.rom';l:$400;p:$800;crc:$a4a4e7dc));
        athena_dip_a:array [0..4] of def_dip=(
        (mask:$2;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$2;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Lives';number:2;dip:((dip_val:$8;dip_name:'3'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Coin A';number:4;dip:((dip_val:$0;dip_name:'4C 1C'),(dip_val:$10;dip_name:'3C 1C'),(dip_val:$20;dip_name:'2C 1C'),(dip_val:$30;dip_name:'1C 1C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Coin B';number:4;dip:((dip_val:$0;dip_name:'1C 2C'),(dip_val:$40;dip_name:'1C 3C'),(dip_val:$80;dip_name:'1C 4C'),(dip_val:$c0;dip_name:'1C 6C'),(),(),(),(),(),(),(),(),(),(),(),())),());
        athena_dip_b:array [0..4] of def_dip=(
        (mask:$3;name:'Difficulty';number:4;dip:((dip_val:$3;dip_name:'Easy'),(dip_val:$2;dip_name:'Normal'),(dip_val:$1;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Demo Sounds';number:2;dip:((dip_val:$4;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Freeze';number:2;dip:((dip_val:$8;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Energy';number:2;dip:((dip_val:$80;dip_name:'12'),(dip_val:$0;dip_name:'14'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        athena_dip_c:array [0..1] of def_dip=(
        (mask:$34;name:'Bonus Life';number:7;dip:((dip_val:$34;dip_name:'50K 100K 100K+'),(dip_val:$24;dip_name:'60K 120K 120K+'),(dip_val:$14;dip_name:'100K 200K 200K+'),(dip_val:$30;dip_name:'50K 100K'),(dip_val:$20;dip_name:'60K 120K'),(dip_val:$10;dip_name:'100K 200K'),(dip_val:$0;dip_name:'None'),(),(),(),(),(),(),(),(),())),());
        //tnk3
        tnk3_main:array[0..2] of tipo_roms=(
        (n:'tnk3-p1.bin';l:$4000;p:0;crc:$0d2a8ca9),(n:'tnk3-p2.bin';l:$4000;p:$4000;crc:$0ae0a483),
        (n:'tnk3-p3.bin';l:$4000;p:$8000;crc:$d16dd4db));
        tnk3_sub:array[0..2] of tipo_roms=(
        (n:'tnk3-p4.bin';l:$4000;p:0;crc:$01b45a90),(n:'tnk3-p5.bin';l:$4000;p:$4000;crc:$60db6667),
        (n:'tnk3-p6.bin';l:$4000;p:$8000;crc:$4761fde7));
        tnk3_snd:array[0..1] of tipo_roms=(
        (n:'tnk3-p10.bin';l:$4000;p:0;crc:$7bf0a517),(n:'tnk3-p11.bin';l:$4000;p:$4000;crc:$0569ce27));
        tnk3_gfx1:tipo_roms=(n:'tnk3-p14.bin';l:$2000;p:0;crc:$1fd18c43);
        tnk3_gfx2:array[0..1] of tipo_roms=(
        (n:'tnk3-p12.bin';l:$4000;p:0;crc:$ff495a16),(n:'tnk3-p13.bin';l:$4000;p:$4000;crc:$f8344843));
        tnk3_sprite16:array[0..2] of tipo_roms=(
        (n:'tnk3-p7.bin';l:$4000;p:0;crc:$06b92c88),(n:'tnk3-p8.bin';l:$4000;p:$4000;crc:$63d0e2eb),
        (n:'tnk3-p9.bin';l:$4000;p:$8000;crc:$872e3fac));
        tnk3_proms:array[0..2] of tipo_roms=(
        (n:'7122.2';l:$400;p:0;crc:$34c06bc6),(n:'7122.1';l:$400;p:$400;crc:$6d0ac66a),
        (n:'7122.0';l:$400;p:$800;crc:$4662b4c8));
        tnk3_dip_a:array [0..4] of def_dip=(
        (mask:$1;name:'No BG Collision';number:2;dip:((dip_val:$1;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$2;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Lives';number:2;dip:((dip_val:$4;dip_name:'3'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$38;name:'Coinage';number:6;dip:((dip_val:$20;dip_name:'3C 1C'),(dip_val:$18;dip_name:'2C 1C'),(dip_val:$38;dip_name:'1C 1C'),(dip_val:$30;dip_name:'1C 2C'),(dip_val:$28;dip_name:'1C 3C'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),(),(),(),(),(),())),());
        tnk3_dip_b:array [0..4] of def_dip=(
        (mask:$6;name:'Difficulty';number:4;dip:((dip_val:$6;dip_name:'Easy'),(dip_val:$4;dip_name:'Normal'),(dip_val:$2;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$18;name:'Game Mode';number:4;dip:((dip_val:$18;dip_name:'Demo Sounds Off'),(dip_val:$10;dip_name:'Demo Sounds On'),(dip_val:$0;dip_name:'Freeze'),(dip_val:$8;dip_name:'Infinite Lives'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Flip Screen';number:2;dip:((dip_val:$20;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Allow Continue';number:2;dip:((dip_val:$80;dip_name:'No'),(dip_val:$0;dip_name:'5 Times'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        tnk3_dip_c:array [0..1] of def_dip=(
        (mask:$c1;name:'Bonus Life';number:7;dip:((dip_val:$c1;dip_name:'20K 60K 60K+'),(dip_val:$81;dip_name:'40K 90K 90K+'),(dip_val:$41;dip_name:'50K 120K 120K+'),(dip_val:$c0;dip_name:'20K 60K'),(dip_val:$80;dip_name:'40K 90K'),(dip_val:$40;dip_name:'50K 120K'),(dip_val:$0;dip_name:'None'),(),(),(),(),(),(),(),(),())),());

type
  snk_proc_generico=procedure;

var
  sp16_scroll_x,sp16_scroll_y,sp32_scroll_x,sp32_scroll_y,scroll_x,scroll_y,hf_posx,hf_posy,txt_offset:word;
  sound_status,sound_latch,timer_sound:byte;
  update_video_snk,update_events_snk,tnk3_draw_sprites:snk_proc_generico;

procedure draw_sprites16(pos:byte);
var
  f,color,atrib:byte;
  nchar:word;
  sx,sy:integer;
begin
	for f:=0 to 24 do begin
		atrib:=memoria[$e803+(f*4)+(pos*25*4)];
    nchar:=memoria[$e801+(f*4)+(pos*25*4)] or ((atrib and $60) shl 3);
		color:=atrib and $f;
		sx:=sp16_scroll_x+300-16-memoria[$e802+(f*4)+(pos*25*4)];
		sy:=-sp16_scroll_y+7-16-8+memoria[$e800+(f*4)+(pos*25*4)];
		sx:=sx+((atrib and $80) shl 1);
		sy:=sy+((atrib and $10) shl 4);
		sx:=sx and $1ff;
		sy:=sy and $1ff;
    put_gfx_sprite_shadow(nchar,color shl 3,false,false,2,$401);
    actualiza_gfx_sprite(sy,(272-sx) and $1ff,3,2);
	end;
end;

procedure draw_sprites32;
var
  f,color,atrib:byte;
  nchar:word;
  sx,sy:integer;
begin
	for f:=0 to 24 do begin
		atrib:=memoria[$e003+(f*4)];
    nchar:=memoria[$e001+(f*4)] or ((atrib and $40) shl 2);
		color:=atrib and $f;
		sx:=sp32_scroll_x+300-32-memoria[$e002+(f*4)];
		sy:=-sp32_scroll_y+7-32-8+memoria[$e000+(f*4)];
		sx:=sx+((atrib and $80) shl 1);
		sy:=sy+((atrib and $10) shl 4);
		sx:=sx and $1ff;
		sy:=sy and $1ff;
    put_gfx_sprite_shadow(nchar,(color shl 3)+$80,false,false,3,$401);
    actualiza_gfx_sprite(sy,(256-sx) and $1ff,3,3);
	end;
end;

procedure update_video_ikari;
var
  g,atrib,color:byte;
  x,y,f,nchar,pos:word;
  col:integer;
begin
for f:=0 to 27 do begin
  for g:=0 to 35 do begin
    col:=g-2;
	  if (col and $20)<>0 then pos:=$400+f+((col and $1f) shl 5)
	    else pos:=f+(col shl 5);
    if gfx[0].buffer[pos] then begin
      nchar:=memoria[$f800+pos];
      if (pos and $400)<>0 then put_gfx(f*8,(35-g)*8,txt_offset+nchar,$180,1,0)
        else put_gfx_trans(f*8,(35-g)*8,txt_offset+nchar,$180,1,0);
      gfx[0].buffer[pos]:=false;
    end;
  end;
end;
//Brackgound
for f:=$0 to $3ff do begin
    atrib:=memoria[$d001+(f*2)];
    color:=atrib and $70;
    if gfx[1].buffer[f] then begin
      x:=f mod 32;
      y:=f div 32;
      nchar:=memoria[$d000+(f*2)]+((atrib and $3) shl 8);
      put_gfx(x*16,(31-y)*16,nchar,color+$100,2,1);
      gfx[1].buffer[f]:=false;
    end;
end;
scroll_x_y(2,3,scroll_y,239-scroll_x);
draw_sprites16(0);
draw_sprites32;
draw_sprites16(1);
actualiza_trozo(0,0,224,288,1,0,0,224,288,3);
actualiza_trozo_final(0,0,216,288,3);
end;

procedure tnk3_sprites;
var
  atrib,color:byte;
  sx,sy,f,nchar:word;
begin
//Sprites
for f:=0 to 49 do begin
		atrib:=memoria[$d003+(f*4)];
    nchar:=memoria[$d001+(f*4)] or ((atrib and $40) shl 2);
		color:=atrib and $f;
		sx:=sp16_scroll_x+301-16-memoria[$d002+(f*4)];
		sy:=-sp16_scroll_y+7-24+memoria[$d000+(f*4)];
		sx:=sx+((atrib and $80) shl 1);
		sy:=sy+((atrib and $10) shl 4);
		sx:=sx and $1ff;
		sy:=sy and $1ff;
    put_gfx_sprite_shadow(nchar,color shl 3,false,(atrib and $20)<>0,2,$401);
    actualiza_gfx_sprite(sx,sy,3,2);
end;
end;

procedure athena_sprites;
var
  atrib,color:byte;
  sx,sy,f,nchar:word;
begin
//Sprites
for f:=0 to 49 do begin
		atrib:=memoria[$d003+(f*4)];
    nchar:=memoria[$d001+(f*4)] or ((atrib and $40) shl 2) or ((atrib and $20) shl 4);
		color:=atrib and $f;
		sx:=sp16_scroll_x+301-16-memoria[$d002+(f*4)];
		sy:=-sp16_scroll_y+7-24+memoria[$d000+(f*4)];
		sx:=sx+((atrib and $80) shl 1);
		sy:=sy+((atrib and $10) shl 4);
		sx:=sx and $1ff;
		sy:=sy and $1ff;
    put_gfx_sprite_shadow(nchar,color shl 3,false,false,2,$401);
    actualiza_gfx_sprite(sx,sy,3,2);
end;
end;

procedure update_video_tnk3;
var
  g,atrib,color:byte;
  x,y,f,nchar,pos:word;
  col:integer;
begin
for f:=0 to 27 do begin
  for g:=0 to 35 do begin
    col:=g-2;
	  if (col and $20)<>0 then pos:=$400+f+((col and $1f) shl 5)
	    else pos:=f+(col shl 5);
    if gfx[0].buffer[pos] then begin
      nchar:=memoria[$f800+pos];
      color:=(nchar and $e0) shr 1;
      if (pos and $400)<>0 then put_gfx(g*8,f*8,txt_offset+nchar,$180,1,0)
        else put_gfx_trans(g*8,f*8,txt_offset+nchar,$180+color,1,0);
      gfx[0].buffer[pos]:=false;
    end;
  end;
end;
//Brackgound
for f:=$0 to $fff do begin
    atrib:=memoria[$d801+(f*2)];
    color:=((atrib and $f) xor 8) shl 4;
    if gfx[1].buffer[f] then begin
      x:=f div 64;
      y:=f mod 64;
      nchar:=memoria[$d800+(f*2)]+((atrib and $30) shl 4);
      put_gfx(x*8,y*8,nchar,color+$80,2,1);
      gfx[1].buffer[f]:=false;
    end;
end;
scroll_x_y(2,3,scroll_x-16,scroll_y);
tnk3_draw_sprites;
actualiza_trozo(0,0,288,224,1,0,0,288,224,3);
actualiza_trozo_final(0,0,288,216,3);
end;

procedure eventos_ikari;
begin
if event.arcade then begin
  //in0
  if arcade_input.coin[1] then marcade.in0:=marcade.in0 and $ef else marcade.in0:=marcade.in0 or $10;
  if arcade_input.coin[0] then marcade.in0:=marcade.in0 and $df else marcade.in0:=marcade.in0 or $20;
  if arcade_input.start[1] then marcade.in0:=marcade.in0 and $bf else marcade.in0:=marcade.in0 or $40;
  if arcade_input.start[0] then marcade.in0:=marcade.in0 and $7f else marcade.in0:=marcade.in0 or $80;
  //in1
  if arcade_input.up[0] then marcade.in1:=marcade.in1 and $fe else marcade.in1:=marcade.in1 or 1;
  if arcade_input.down[0] then marcade.in1:=marcade.in1 and $fd else marcade.in1:=marcade.in1 or 2;
  if arcade_input.left[0] then marcade.in1:=marcade.in1 and $fb else marcade.in1:=marcade.in1 or 4;
  if arcade_input.right[0] then marcade.in1:=marcade.in1 and $f7 else marcade.in1:=marcade.in1 or 8;
  if arcade_input.but2[0] then begin
     case (marcade.in1 shr 4) of
        0..9:marcade.in1:=marcade.in1+$10;
        $a:marcade.in1:=$f0 or marcade.in1 and $f;
        else marcade.in1:=marcade.in1 and $f;
      end;
  end;
  if arcade_input.but3[0] then begin
      case (marcade.in1 shr 4) of
        0..$a:marcade.in1:=(marcade.in1-$10) and $ff;
        else marcade.in1:=$a0+(marcade.in1 and $f);
      end;
  end;
  //in2
  if arcade_input.up[1] then marcade.in2:=marcade.in2 and $fe else marcade.in2:=marcade.in2 or 1;
  if arcade_input.down[1] then marcade.in2:=marcade.in2 and $fd else marcade.in2:=marcade.in2 or 2;
  if arcade_input.left[1] then marcade.in2:=marcade.in2 and $fb else marcade.in2:=marcade.in2 or 4;
  if arcade_input.right[1] then marcade.in2:=marcade.in2 and $f7 else marcade.in2:=marcade.in2 or 8;
  if arcade_input.but2[1] then begin
      case (marcade.in2 shr 8) of
        0..9:marcade.in2:=marcade.in2+$10;
        $a:marcade.in2:=$f0 or marcade.in2 and $f;
        $f:marcade.in2:=marcade.in2 and $f;
      end;
  end;
  if arcade_input.but3[1] then begin
      case (marcade.in2 shr 4) of
        0..$a:marcade.in2:=(marcade.in2-$10) and $ff;
        else marcade.in2:=$a0+(marcade.in2 and $f);
      end;
  end;
  //in3
  if arcade_input.but0[0] then marcade.in3:=marcade.in3 and $fe else marcade.in3:=marcade.in3 or 1;
  if arcade_input.but1[0] then marcade.in3:=marcade.in3 and $fd else marcade.in3:=marcade.in3 or 2;
  if arcade_input.but0[1] then marcade.in3:=marcade.in3 and $f7 else marcade.in3:=marcade.in3 or 8;
  if arcade_input.but1[1] then marcade.in3:=marcade.in3 and $ef else marcade.in3:=marcade.in3 or $10;
end;
end;

procedure eventos_athena;
begin
if event.arcade then begin
  //in0
  if arcade_input.coin[1] then marcade.in0:=marcade.in0 and $ef else marcade.in0:=marcade.in0 or $10;
  if arcade_input.coin[0] then marcade.in0:=marcade.in0 and $df else marcade.in0:=marcade.in0 or $20;
  if arcade_input.start[1] then marcade.in0:=marcade.in0 and $bf else marcade.in0:=marcade.in0 or $40;
  if arcade_input.start[0] then marcade.in0:=marcade.in0 and $7f else marcade.in0:=marcade.in0 or $80;
  //in1
  if arcade_input.up[0] then marcade.in1:=marcade.in1 and $fe else marcade.in1:=marcade.in1 or 1;
  if arcade_input.down[0] then marcade.in1:=marcade.in1 and $fd else marcade.in1:=marcade.in1 or 2;
  if arcade_input.left[0] then marcade.in1:=marcade.in1 and $fb else marcade.in1:=marcade.in1 or 4;
  if arcade_input.right[0] then marcade.in1:=marcade.in1 and $f7 else marcade.in1:=marcade.in1 or 8;
  if arcade_input.but0[0] then marcade.in1:=marcade.in1 and $ef else marcade.in1:=marcade.in1 or $10;
  if arcade_input.but1[0] then marcade.in1:=marcade.in1 and $df else marcade.in1:=marcade.in1 or $20;
  //in2
  if arcade_input.up[1] then marcade.in2:=marcade.in2 and $fe else marcade.in2:=marcade.in2 or 1;
  if arcade_input.down[1] then marcade.in2:=marcade.in2 and $fd else marcade.in2:=marcade.in2 or 2;
  if arcade_input.left[1] then marcade.in2:=marcade.in2 and $fb else marcade.in2:=marcade.in2 or 4;
  if arcade_input.right[1] then marcade.in2:=marcade.in2 and $f7 else marcade.in2:=marcade.in2 or 8;
  if arcade_input.but0[1] then marcade.in2:=marcade.in2 and $ef else marcade.in2:=marcade.in2 or $10;
  if arcade_input.but1[1] then marcade.in2:=marcade.in2 and $df else marcade.in2:=marcade.in2 or $20;
end;
end;

procedure eventos_tnk3;
begin
if event.arcade then begin
  //in0
  if arcade_input.coin[0] then marcade.in0:=marcade.in0 and $fe else marcade.in0:=marcade.in0 or $1;
  if arcade_input.start[0] then marcade.in0:=marcade.in0 and $f7 else marcade.in0:=marcade.in0 or $8;
  if arcade_input.start[1] then marcade.in0:=marcade.in0 and $ef else marcade.in0:=marcade.in0 or $10;
  //in1
  if arcade_input.up[0] then marcade.in1:=marcade.in1 and $fe else marcade.in1:=marcade.in1 or 1;
  if arcade_input.down[0] then marcade.in1:=marcade.in1 and $fd else marcade.in1:=marcade.in1 or 2;
  if arcade_input.left[0] then marcade.in1:=marcade.in1 and $fb else marcade.in1:=marcade.in1 or 4;
  if arcade_input.right[0] then marcade.in1:=marcade.in1 and $f7 else marcade.in1:=marcade.in1 or 8;
  if arcade_input.but2[0] then begin
      case (marcade.in1 shr 4) of
        0..9:marcade.in1:=marcade.in1+$10;
        $a:marcade.in1:=$f0 or marcade.in1 and $f;
        else marcade.in1:=marcade.in1 and $f;
      end;
  end;
  if arcade_input.but3[0] then begin
      case (marcade.in1 shr 4) of
        0..$a:marcade.in1:=(marcade.in1-$10) and $ff;
        else marcade.in1:=$a0+(marcade.in1 and $f);
      end;
  end;
  //in2
  if arcade_input.up[1] then marcade.in2:=marcade.in2 and $fe else marcade.in2:=marcade.in2 or 1;
  if arcade_input.down[1] then marcade.in2:=marcade.in2 and $fd else marcade.in2:=marcade.in2 or 2;
  if arcade_input.left[1] then marcade.in2:=marcade.in2 and $fb else marcade.in2:=marcade.in2 or 4;
  if arcade_input.right[1] then marcade.in2:=marcade.in2 and $f7 else marcade.in2:=marcade.in2 or 8;
  if arcade_input.but2[1] then begin
      case (marcade.in2 shr 8) of
        0..9:marcade.in2:=marcade.in2+$10;
        $a:marcade.in2:=$f0 or marcade.in2 and $f;
        $f:marcade.in2:=marcade.in2 and $f;
      end;
  end;
  if arcade_input.but3[1] then begin
      case (marcade.in2 shr 4) of
        0..$a:marcade.in2:=(marcade.in2-$10) and $ff;
        else marcade.in2:=$a0+(marcade.in2 and $f);
      end;
  end;
  //in3
  if arcade_input.but0[0] then marcade.in3:=marcade.in3 and $fe else marcade.in3:=marcade.in3 or 1;
  if arcade_input.but1[0] then marcade.in3:=marcade.in3 and $fd else marcade.in3:=marcade.in3 or 2;
  if arcade_input.but0[1] then marcade.in3:=marcade.in3 and $f7 else marcade.in3:=marcade.in3 or 8;
  if arcade_input.but1[1] then marcade.in3:=marcade.in3 and $ef else marcade.in3:=marcade.in3 or $10;
end;
end;

procedure snk_principal;
var
  frame_m,frame_sub,frame_snd:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=z80_0.tframes;
frame_sub:=z80_1.tframes;
frame_snd:=z80_2.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to 4479 do begin
    //Main
    z80_0.run(frame_m);
    frame_m:=frame_m+z80_0.tframes-z80_0.contador;
    //Sub
    z80_1.run(frame_sub);
    frame_sub:=frame_sub+z80_1.tframes-z80_1.contador;
    //snd
    z80_2.run(frame_snd);
    frame_snd:=frame_snd+z80_2.tframes-z80_2.contador;
    if f=0 then begin
      z80_0.change_irq(HOLD_LINE);
      z80_1.change_irq(HOLD_LINE);
      update_video_snk;
    end;
  end;
  update_events_snk;
  video_sync;
end;
end;

function hardflags_check(num:byte):byte;
var
  x,y,dx,dy:word;
  ret:byte;
  sr:array[0..3] of byte;
begin
	copymemory(@sr,@memoria[$e800+4*num],4);
	x:=sr[2]+((sr[3] and $80) shl 1);
	y:=sr[0]+((sr[3] and $10) shl 4);
	dx:=(x-hf_posx) and $1ff;
	dy:=(y-hf_posy) and $1ff;
	if ((dx>$20) and (dx<=$1e0) and (dy>$20) and (dy<=$1e0)) then ret:=0
    else ret:=1;
  hardflags_check:=ret;
end;

function hardflags_check8(num:byte):byte;
begin
	hardflags_check8:=
		(hardflags_check(num+0) shl 0) or (hardflags_check(num+1) shl 1) or
		(hardflags_check(num+2) shl 2) or (hardflags_check(num+3) shl 3) or
		(hardflags_check(num+4) shl 4) or (hardflags_check(num+5) shl 5) or
		(hardflags_check(num+6) shl 6) or (hardflags_check(num+7) shl 7);
end;

function ikari_main_getbyte(direccion:word):byte;
begin
case direccion of
  0..$bfff,$e000..$ffff:ikari_main_getbyte:=memoria[direccion];
  $c000:ikari_main_getbyte:=marcade.in0 or ((sound_status and 4) shr 2);
  $c100:ikari_main_getbyte:=marcade.in1;
  $c200:ikari_main_getbyte:=marcade.in2;
  $c300:ikari_main_getbyte:=marcade.in3;
  $c500:ikari_main_getbyte:=marcade.dswa+(marcade.dswc and $4);
  $c600:ikari_main_getbyte:=marcade.dswb+(marcade.dswc and $30);
  $c700:begin //snk_cpuB_nmi_trigger_r
          z80_1.change_nmi(ASSERT_LINE);
          ikari_main_getbyte:=$ff;
        end;
  $ce00:ikari_main_getbyte:=hardflags_check8(0*8);  //hardflags1_r
	$ce20:ikari_main_getbyte:=hardflags_check8(1*8);  //hardflags2_r
	$ce40:ikari_main_getbyte:=hardflags_check8(2*8);  //hardflags3_r
	$ce60:ikari_main_getbyte:=hardflags_check8(3*8);  //hardflags4_r
	$ce80:ikari_main_getbyte:=hardflags_check8(4*8);  //hardflags5_r
	$cea0:ikari_main_getbyte:=hardflags_check8(5*8);  //hardflags6_r
	$cee0:ikari_main_getbyte:=(hardflags_check(6*8+0) shl 0) or (hardflags_check(6*8+1) shl 1) or
		                        (hardflags_check(6*8+0) shl 4) or (hardflags_check(6*8+1) shl 5);  //hardflags7_r
  $d000..$dfff:ikari_main_getbyte:=memoria[$d000+(direccion and $7ff)];
end;
end;

procedure ikari_main_putbyte(direccion:word;valor:byte);
begin
if direccion<$c000 then exit;
case direccion of
  $c400:begin  //soundlatch_w
          sound_latch:=valor;
          sound_status:=sound_status or 8 or 4;
          timer[timer_sound].enabled:=true;
        end;
  $c700:z80_0.change_nmi(CLEAR_LINE); //cpa_nmi_ack
  $c800:scroll_y:=(scroll_y and $100) or valor;  //snk_bg_scrolly_w
	$c880:scroll_x:=(scroll_x and $100) or valor;  //snk_bg_scrollx_w
	$c900:begin   //ikari_bg_scroll_msb_w
           scroll_x:=(scroll_x and $ff) or ((valor and $02) shl 7);
	         scroll_y:=(scroll_y and $ff) or ((valor and $01) shl 8);
        end;
	$c980:begin  //ikari_unknown_video_w
          txt_offset:=(valor and $10) shl 4;
          fillchar(gfx[0].buffer,$400,1);
        end;
	$ca00:sp16_scroll_y:=(sp16_scroll_y and $100) or valor;  //snk_sp16_scrolly_w
	$ca80:sp16_scroll_x:=(sp16_scroll_x and $100) or valor;  //snk_sp16_scrollx_w
	$cb00:sp32_scroll_y:=(sp32_scroll_y and $100) or valor;  //snk_sp32_scrolly_w
	$cb80:sp32_scroll_x:=(sp32_scroll_x and $100) or valor;  //snk_sp32_scrollx_w
	$cc00:hf_posy:=(hf_posy and $100) or valor;  //hardflags_scrolly_w
	$cc80:hf_posx:=(hf_posx and $100) or valor;  //hardflags_scrollx_w
	$cd00:begin  //ikari_sp_scroll_msb_w
            sp32_scroll_x:=(sp32_scroll_x and $ff) or ((valor and $20) shl 3);
	          sp16_scroll_x:=(sp16_scroll_x and $ff) or ((valor and $10) shl 4);
	          sp32_scroll_y:=(sp32_scroll_y and $ff) or ((valor and $08) shl 5);
	          sp16_scroll_y:=(sp16_scroll_y and $ff) or ((valor and $04) shl 6);
        end;
	$cd80:begin //hardflags_scroll_msb_w
          hf_posx:=(hf_posx and $ff) or ((valor and $80) shl 1);
	        hf_posy:=(hf_posy and $ff) or ((valor and $40) shl 2);
        end;
  $d000..$dfff:begin  //bg
                  memoria[$d000+(direccion and $7ff)]:=valor;
                  gfx[1].buffer[(direccion and $7ff) shr 1]:=true;
               end;
  $e000..$f7ff:memoria[direccion]:=valor;
  $f800..$ffff:begin
                  memoria[direccion]:=valor;
                  gfx[0].buffer[direccion and $7ff]:=true;
               end;
end;
end;

function ikari_sub_getbyte(direccion:word):byte;
begin
case direccion of
  0..$bfff:ikari_sub_getbyte:=mem_misc[direccion];
  $c000:begin //snk_cpuA_nmi_trigger_r
          z80_0.change_nmi(ASSERT_LINE);
          ikari_sub_getbyte:=$ff;
        end;
  $ce00:ikari_sub_getbyte:=hardflags_check8(0*8);  //hardflags1_r
	$ce20:ikari_sub_getbyte:=hardflags_check8(1*8);  //hardflags2_r
	$ce40:ikari_sub_getbyte:=hardflags_check8(2*8);  //hardflags3_r
	$ce60:ikari_sub_getbyte:=hardflags_check8(3*8);  //hardflags4_r
	$ce80:ikari_sub_getbyte:=hardflags_check8(4*8);  //hardflags5_r
	$cea0:ikari_sub_getbyte:=hardflags_check8(5*8);  //hardflags6_r
	$cee0:ikari_sub_getbyte:=(hardflags_check(6*8+0) shl 0) or (hardflags_check(6*8+1) shl 1) or
		                       (hardflags_check(6*8+0) shl 4) or (hardflags_check(6*8+1) shl 5);  //hardflags7_r
  $d000..$dfff:ikari_sub_getbyte:=memoria[$d000+(direccion and $7ff)];
  $e000..$ffff:ikari_sub_getbyte:=memoria[direccion];
end;
end;

procedure ikari_sub_putbyte(direccion:word;valor:byte);
begin
if direccion<$c000 then exit;
case direccion of
  $c000:z80_1.change_nmi(CLEAR_LINE); //snk_cpuB_nmi_ack_w
	$c980:begin //ikari_unknown_video_w
          txt_offset:=(valor and $10) shl 4;
          fillchar(gfx[0].buffer,$400,1);
        end;
	$cc00:hf_posy:=(hf_posy and $100) or valor;  //hardflags_scrolly_w
	$cc80:hf_posx:=(hf_posx and $100) or valor;  //hardflags_scrollx_w
	$cd80:begin //hardflags_scroll_msb_w
          hf_posx:=(hf_posx and $ff) or ((valor and $80) shl 1);
	        hf_posy:=(hf_posy and $ff) or ((valor and $40) shl 2);
        end;
  $d000..$dfff:begin //bg
                  memoria[$d000+(direccion and $7ff)]:=valor;
                  gfx[1].buffer[(direccion and $7ff) shr 1]:=true;
               end;
  $e000..$f7ff:memoria[direccion]:=valor;
  $f800..$ffff:begin  //tx
                  memoria[direccion]:=valor;
                  gfx[0].buffer[direccion and $7ff]:=true;
               end;
end;
end;

//TNK III
function tnk3_main_getbyte(direccion:word):byte;
begin
case direccion of
  0..$bfff,$d000..$ffff:tnk3_main_getbyte:=memoria[direccion];
  $c000:tnk3_main_getbyte:=marcade.in0 or ((sound_status and 4) shl 3);
  $c100:tnk3_main_getbyte:=marcade.in1;
  $c200:tnk3_main_getbyte:=marcade.in2;
  $c300:tnk3_main_getbyte:=marcade.in3;
  $c500:tnk3_main_getbyte:=marcade.dswa+(marcade.dswc and $c0);
  $c600:tnk3_main_getbyte:=marcade.dswb+(marcade.dswc and $1);
  $c700:begin //snk_cpuB_nmi_trigger_r
          z80_1.change_nmi(ASSERT_LINE);
          tnk3_main_getbyte:=$ff;
        end;
end;
end;

//Athena
function athena_main_getbyte(direccion:word):byte;
begin
case direccion of
  0..$bfff,$d000..$ffff:athena_main_getbyte:=memoria[direccion];
  $c000:athena_main_getbyte:=marcade.in0 or ((sound_status and 4) shr 2);
  $c100:athena_main_getbyte:=marcade.in1;
  $c200:athena_main_getbyte:=marcade.in2;
  $c500:athena_main_getbyte:=marcade.dswa+(marcade.dswc and $4);
  $c600:athena_main_getbyte:=marcade.dswb+(marcade.dswc and $30);
  $c700:begin //snk_cpuB_nmi_trigger_r
          z80_1.change_nmi(ASSERT_LINE);
          athena_main_getbyte:=$ff;
        end;
end;
end;

procedure athena_main_putbyte(direccion:word;valor:byte);
begin
if direccion<$c000 then exit;
case direccion of
  $c400:begin  //soundlatch_w
          sound_latch:=valor;
          sound_status:=sound_status or 8 or 4;
          timer[timer_sound].enabled:=true;
        end;
  $c700:z80_0.change_nmi(CLEAR_LINE); //cpua_nmi_ack
  $c800:begin   //tnk3_videoattrs_w
            main_screen.flip_main_screen:=(valor and $80)<>0;
            if txt_offset<>((valor and $40) shl 2) then begin
		          txt_offset:=(valor and $40) shl 2;
              fillchar(gfx[0].buffer,$400,1);
            end;
	          scroll_y:=(scroll_y and $ff) or ((valor and $10) shl 4);
	          sp16_scroll_y:=(sp16_scroll_y and $ff) or ((valor and $08) shl 5);
	          scroll_x:=(scroll_x and $ff) or ((valor and $02) shl 7);
	          sp16_scroll_x:=(sp16_scroll_x and $ff) or ((valor and $01) shl 8);
        end;
	$c900:sp16_scroll_y:=(sp16_scroll_y and $100) or valor;  //snk_sp16_scrolly_w
	$ca00:sp16_scroll_x:=(sp16_scroll_x and $100) or valor;  //snk_sp16_scrollx_w
	$cb00:scroll_y:=(scroll_y and $100) or valor;  //snk_bg_scrolly_w
	$cc00:scroll_x:=(scroll_x and $100) or valor;  //snk_bg_scrollx_w
  $d000..$d7ff:memoria[direccion]:=valor; //sprites
  $d800..$f7ff:begin //bg_ram
                  memoria[direccion]:=valor;
                  gfx[1].buffer[(direccion-$d800) shr 1]:=true;
               end;
  $f800..$ffff:begin //txt_ram
                  memoria[direccion]:=valor;
                  gfx[0].buffer[direccion and $7ff]:=true;
               end;
end;
end;

function athena_sub_getbyte(direccion:word):byte;
begin
case direccion of
  0..$bfff:athena_sub_getbyte:=mem_misc[direccion];
  $c000,$c700:begin //snk_cpuA_nmi_trigger_r
                z80_0.change_nmi(ASSERT_LINE);
                athena_sub_getbyte:=$ff;
              end;
  $c800..$cfff:athena_sub_getbyte:=memoria[$d000+(direccion and $7ff)]; //sprites
  $d000..$efff:athena_sub_getbyte:=memoria[$d800+(direccion-$d000)]; //bg_ram
  $f000..$f7ff:athena_sub_getbyte:=mem_misc[direccion];
	$f800..$ffff:athena_sub_getbyte:=memoria[direccion]; //tx_ram
end;
end;

procedure athena_sub_putbyte(direccion:word;valor:byte);
begin
if direccion<$c000 then exit;
case direccion of
  $c000,$c700:z80_1.change_nmi(CLEAR_LINE); //snk_cpuB_nmi_ack_w
  $c800..$cfff:memoria[$d000+(direccion and $7ff)]:=valor; //sprites
  $d000..$efff:begin //bg_ram
                  memoria[$d800+(direccion-$d000)]:=valor;
                  gfx[1].buffer[(direccion-$d000) shr 1]:=true;
               end;
  $f000..$f7ff:mem_misc[direccion]:=valor;
  $f800..$ffff:begin //tx_ram
                  memoria[direccion]:=valor;
                  gfx[0].buffer[direccion and $7ff]:=true;
               end;
end;
end;

//Sound
function ikari_snd_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$cfff:ikari_snd_getbyte:=mem_snd[direccion];
  $e000:ikari_snd_getbyte:=sound_latch;
	$e800:ikari_snd_getbyte:=ym3812_0.status;
  $f000:ikari_snd_getbyte:=ym3812_1.status;
  $f800:ikari_snd_getbyte:=sound_status;
end;
end;

procedure ikari_snd_putbyte(direccion:word;valor:byte);
begin
if direccion<$c000 then exit;
case direccion of
  $c000..$cfff:mem_snd[direccion]:=valor;
	$e800:ym3812_0.control(valor);
	$ec00:ym3812_0.write(valor);
  $f000:ym3812_1.control(valor);
	$f400:ym3812_1.write(valor);
  $f800:begin //snk_sound_status_w
          if (valor and $10)=0 then begin
            sound_status:=sound_status and $fe;
            timer[timer_sound].enabled:=true;
          end;
          if (valor and $20)=0 then begin
            sound_status:=sound_status and $fd;
            timer[timer_sound].enabled:=true;
          end;
          if (valor and $40)=0 then begin
            sound_status:=sound_status and $fb;
            timer[timer_sound].enabled:=true;
          end;
          if (valor and $80)=0 then begin
            sound_status:=sound_status and $f7;
            timer[timer_sound].enabled:=true;
          end;
        end;
end;
end;

procedure snd_irq1(irqstate:byte);
begin
if irqstate<>0 then begin
  sound_status:=sound_status or 1;
  timer[timer_sound].enabled:=true;
end;
end;

procedure snd_irq2(irqstate:byte);
begin
if irqstate<>0 then begin
  sound_status:=sound_status or 2;
  timer[timer_sound].enabled:=true;
end;
end;

procedure ikari_sound_update;
begin
  YM3812_0.update;
  YM3812_1.update;
end;

procedure snk_snd_irq;
begin
timer[timer_sound].enabled:=false;
if (sound_status and $b)<>0 then z80_2.change_irq(ASSERT_LINE)
  else z80_2.change_irq(CLEAR_LINE);
end;

function tnk3_snd_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$87ff:tnk3_snd_getbyte:=mem_snd[direccion];
  $a000:tnk3_snd_getbyte:=sound_latch;
  $c000:begin //tnk3_busy_clear_r
           sound_latch:=0;
           sound_status:=sound_status and $fb;
           timer[timer_sound].enabled:=true;
           tnk3_snd_getbyte:=$ff;
        end;
	$e000:tnk3_snd_getbyte:=ym3812_0.status;
  $e004:begin //tnk3_cmdirq_ack_r
           sound_status:=sound_status and $f7;
           timer[timer_sound].enabled:=true;
           tnk3_snd_getbyte:=$ff;
        end;
  $e006:begin //tnk3_ymirq_ack_r
           sound_status:=sound_status and $fe;
           timer[timer_sound].enabled:=true;
           tnk3_snd_getbyte:=$ff;
        end;
end;
end;

procedure tnk3_snd_putbyte(direccion:word;valor:byte);
begin
if direccion<$8000 then exit;
case direccion of
  $8000..$87ff:mem_snd[direccion]:=valor;
	$e000:ym3812_0.control(valor);
	$e001:ym3812_0.write(valor);
end;
end;

procedure tnk3_sound_update;
begin
  YM3812_0.update;
end;

//Main
procedure reset_snk;
begin
 z80_0.reset;
 z80_1.reset;
 z80_2.reset;
 reset_audio;
 YM3812_0.reset;
 if main_vars.tipo_maquina<>243 then YM3812_1.reset;
 txt_offset:=0;
 sound_latch:=0;
 sound_status:=0;
 hf_posx:=0;
 hf_posy:=0;
 sp16_scroll_x:=0;
 sp16_scroll_y:=0;
 sp32_scroll_x:=0;
 sp32_scroll_y:=0;
 scroll_x:=0;
 scroll_y:=0;
 if main_vars.tipo_maquina<>243 then begin
    marcade.in0:=$fe;
    marcade.in1:=$bf;
    marcade.in2:=$bf;
 end else begin
    marcade.in0:=$df;
    marcade.in1:=$f;
    marcade.in2:=$f;
 end;
 marcade.in3:=$ff;
end;

function iniciar_snk:boolean;
const
  pc_y:array[0..31] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32,
		                         8*32, 9*32, 10*32, 11*32, 12*32, 13*32, 14*32, 15*32,
		                         16*32+0*32, 16*32+1*32, 16*32+2*32, 16*32+3*32,
		                         16*32+4*32, 16*32+5*32, 16*32+6*32, 16*32+7*32,
		                         16*32+8*32, 16*32+9*32, 16*32+10*32, 16*32+11*32,
		                         16*32+12*32, 16*32+13*32, 16*32+14*32, 16*32+15*32);
  pb_x:array[0..15] of dword=(4*1, 4*0, 4*3, 4*2, 4*5, 4*4, 4*7, 4*6,
		32+4*1, 32+4*0, 32+4*3, 32+4*2, 32+4*5, 32+4*4, 32+4*7, 32+4*6);
  pb_y:array[0..15] of dword=(0*64, 1*64, 2*64, 3*64, 4*64, 5*64, 6*64, 7*64,
		8*64, 9*64, 10*64, 11*64, 12*64, 13*64, 14*64, 15*64);
  ps_x:array[0..31] of dword=(7,6,5,4,3,2,1,0,
		                          15,14,13,12,11,10,9,8,
		                          23,22,21,20,19,18,17,16,
		                          31,30,29,28,27,26,25,24);
  ps_y:array[0..15] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16,
		8*16, 9*16, 10*16, 11*16, 12*16, 13*16, 14*16, 15*16);

var
  memoria_temp:array[0..$2ffff] of byte;
  colores:tpaleta;
  f:word;
procedure tank3_pal;
var
  bit0,bit1,bit2,bit3:byte;
  f:word;
begin
for f:=0 to $3ff do begin
  bit0:=(memoria_temp[f+$800] shr 3) and $01;
  bit1:=(memoria_temp[f] shr 1) and $01;
  bit2:=(memoria_temp[f] shr 2) and $01;
  bit3:=(memoria_temp[f] shr 3) and $01;
  colores[f].r:=$0e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
  bit0:=(memoria_temp[f+$800] shr 2) and $01;
  bit1:=(memoria_temp[f+$400] shr 2) and $01;
  bit2:=(memoria_temp[f+$400] shr 3) and $01;
  bit3:=(memoria_temp[f] shr 0) and $01;
  colores[f].g:=$0e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
  bit0:=(memoria_temp[f+$800] shr 0) and $01;
  bit1:=(memoria_temp[f+$800] shr 1) and $01;
  bit2:=(memoria_temp[f+$400] shr 0) and $01;
  bit3:=(memoria_temp[f+$400] shr 1) and $01;
  colores[f].b:=$0e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
end;
set_pal(colores,$400);
end;

begin
iniciar_snk:=false;
iniciar_audio(false);
screen_init(1,288,288,true);
screen_init(2,512,512);
screen_mod_scroll(2,512,512,511,512,512,511);
screen_init(3,512,512,false,true);
case main_vars.tipo_maquina of
  241:iniciar_video(216,288);
  242:iniciar_video(288,216);
  243:begin
        main_screen.rol90_screen:=true;
        iniciar_video(288,216);
      end;
end;
//Main CPU
//IMPORTANTE!!! Para que las 3 CPUs funcionen correctamente, es necesario que se ejecuten pocas instrucciones
//cada vez para que se sincronicen mejor, si no, por ejemplo nada mas arrancar la CPU 2 no carga la pila y la CPU 1
//genera una NMI...
z80_0:=cpu_z80.create(3350000,4480);
z80_1:=cpu_z80.create(3350000,4480);
z80_2:=cpu_z80.create(4000000,4480);
timer_sound:=init_timer(z80_2.numero_cpu,120,snk_snd_irq,false);
case main_vars.tipo_maquina of
  241:begin //Ikari Warriors
        update_video_snk:=update_video_ikari;
        update_events_snk:=eventos_ikari;
        z80_0.change_ram_calls(ikari_main_getbyte,ikari_main_putbyte);
        //Sub CPU
        z80_1.change_ram_calls(ikari_sub_getbyte,ikari_sub_putbyte);
        //Sound Z80
        z80_2.change_ram_calls(ikari_snd_getbyte,ikari_snd_putbyte);
        z80_2.init_sound(ikari_sound_update);
        ym3812_0:=ym3812_chip.create(YM3526_FM,4000000,2);
        ym3812_0.change_irq_calls(snd_irq1);
        ym3812_1:=ym3812_chip.create(YM3526_FM,4000000,2);
        ym3812_1.change_irq_calls(snd_irq2);
        //cargar roms
        if not(roms_load(@memoria,@ikari_main,'ikari.zip',sizeof(ikari_main))) then exit;
        if not(roms_load(@mem_misc,@ikari_sub,'ikari.zip',sizeof(ikari_sub))) then exit;
        if not(roms_load(@mem_snd,@ikari_snd,'ikari.zip',sizeof(ikari_snd))) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,@ikari_gfx1,'ikari.zip',sizeof(ikari_gfx1))) then exit;
        init_gfx(0,8,8,$200);
        gfx[0].trans[15]:=true;
        gfx_set_desc_data(4,0,32*8,0,1,2,3);
        convert_gfx(0,0,@memoria_temp,@pb_x,@pc_y,false,true);
        //convertir bg
        if not(roms_load(@memoria_temp,@ikari_gfx2,'ikari.zip',sizeof(ikari_gfx2))) then exit;
        init_gfx(1,16,16,$400);
        gfx_set_desc_data(4,0,64*16,0,1,2,3);
        convert_gfx(1,0,@memoria_temp,@pb_x,@pb_y,false,true);
        //sprite 16
        if not(roms_load(@memoria_temp,@ikari_sprite16,'ikari.zip',sizeof(ikari_sprite16))) then exit;
        init_gfx(2,16,16,$400);
        gfx[2].trans[7]:=true;
        gfx[2].shadow[6]:=true;
        gfx_set_desc_data(3,0,16*16,2*1024*256,1*1024*256,0*1024*256);
        convert_gfx(2,0,@memoria_temp,@ps_x,@ps_y,false,true);
        //sprite 32
        if not(roms_load(@memoria_temp,@ikari_sprite32,'ikari.zip',sizeof(ikari_sprite32))) then exit;
        init_gfx(3,32,32,$200);
        gfx[3].trans[7]:=true;
        gfx[3].shadow[6]:=true;
        gfx_set_desc_data(3,0,16*32*2,2*2048*256,1*2048*256,0*2048*256);
        convert_gfx(3,0,@memoria_temp,@ps_x,@pc_y,false,true);
        //pal
        if not(roms_load(@memoria_temp,@ikari_proms,'ikari.zip',sizeof(ikari_proms))) then exit;
        for f:=0 to $3ff do begin
		      colores[f].r:=pal4bit(memoria_temp[f]);
		      colores[f].g:=pal4bit(memoria_temp[f+$400]);
          colores[f].b:=pal4bit(memoria_temp[f+$800]);
        end;
        set_pal(colores,$400);
        marcade.dswa:=$3b;
        marcade.dswb:=$4b;
        marcade.dswc:=$34;
        marcade.dswa_val:=@ikari_dip_a;
        marcade.dswb_val:=@ikari_dip_b;
        marcade.dswc_val:=@ikari_dip_c;
  end;
  242:begin //Athena
        update_video_snk:=update_video_tnk3;
        tnk3_draw_sprites:=athena_sprites;
        update_events_snk:=eventos_athena;
        z80_0.change_ram_calls(athena_main_getbyte,athena_main_putbyte);
        //Sub CPU
        z80_1.change_ram_calls(athena_sub_getbyte,athena_sub_putbyte);
        //Sound Z80
        z80_2.change_ram_calls(ikari_snd_getbyte,ikari_snd_putbyte);
        z80_2.init_sound(ikari_sound_update);
        ym3812_0:=ym3812_chip.create(YM3526_FM,4000000,2);
        ym3812_0.change_irq_calls(snd_irq1);
        ym3812_1:=ym3812_chip.create(YM3526_FM,4000000,2);
        ym3812_1.change_irq_calls(snd_irq2);
        //cargar roms
        if not(roms_load(@memoria,@athena_main,'athena.zip',sizeof(athena_main))) then exit;
        if not(roms_load(@mem_misc,@athena_sub,'athena.zip',sizeof(athena_sub))) then exit;
        if not(roms_load(@mem_snd,@athena_snd,'athena.zip',sizeof(athena_snd))) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,@athena_gfx1,'athena.zip',sizeof(athena_gfx1))) then exit;
        init_gfx(0,8,8,$200);
        gfx[0].trans[15]:=true;
        gfx_set_desc_data(4,0,32*8,0,1,2,3);
        convert_gfx(0,0,@memoria_temp,@pb_x,@pc_y,false,false);
        //convertir bg
        if not(roms_load(@memoria_temp,@athena_gfx2,'athena.zip',sizeof(athena_gfx2))) then exit;
        init_gfx(1,8,8,$400);
        gfx_set_desc_data(4,0,32*8,0,1,2,3);
        convert_gfx(1,0,@memoria_temp,@pb_x,@pc_y,false,false);
        //sprite 16
        if not(roms_load(@memoria_temp,@athena_sprite16,'athena.zip',sizeof(athena_sprite16))) then exit;
        init_gfx(2,16,16,$400);
        gfx[2].trans[7]:=true;
        gfx[2].shadow[6]:=true;
        gfx_set_desc_data(3,0,16*16,2*1024*256,1*1024*256,0*1024*256);
        convert_gfx(2,0,@memoria_temp,@ps_x,@ps_y,false,false);
        //pal
        if not(roms_load(@memoria_temp,@athena_proms,'athena.zip',sizeof(athena_proms))) then exit;
        tank3_pal;
        marcade.dswa:=$39;
        marcade.dswb:=$cb;
        marcade.dswc:=$34;
        marcade.dswa_val:=@athena_dip_a;
        marcade.dswb_val:=@athena_dip_b;
        marcade.dswc_val:=@athena_dip_c;
      end;
  243:begin //TNK III
        update_video_snk:=update_video_tnk3;
        tnk3_draw_sprites:=tnk3_sprites;
        update_events_snk:=eventos_tnk3;
        z80_0.change_ram_calls(tnk3_main_getbyte,athena_main_putbyte);
        //Sub CPU
        z80_1.change_ram_calls(athena_sub_getbyte,athena_sub_putbyte);
        //Sound Z80
        z80_2.change_ram_calls(tnk3_snd_getbyte,tnk3_snd_putbyte);
        z80_2.init_sound(tnk3_sound_update);
        ym3812_0:=ym3812_chip.create(YM3526_FM,4000000,2);
        ym3812_0.change_irq_calls(snd_irq1);
        //cargar roms
        if not(roms_load(@memoria,@tnk3_main,'tnk3.zip',sizeof(tnk3_main))) then exit;
        if not(roms_load(@mem_misc,@tnk3_sub,'tnk3.zip',sizeof(tnk3_sub))) then exit;
        if not(roms_load(@mem_snd,@tnk3_snd,'tnk3.zip',sizeof(tnk3_snd))) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,@tnk3_gfx1,'tnk3.zip',sizeof(tnk3_gfx1))) then exit;
        copymemory(@memoria_temp[$2000],@memoria_temp,$2000);
        init_gfx(0,8,8,$200);
        gfx[0].trans[15]:=true;
        gfx_set_desc_data(4,0,32*8,0,1,2,3);
        convert_gfx(0,0,@memoria_temp,@pb_x,@pc_y,false,false);
        //convertir bg
        if not(roms_load(@memoria_temp,@tnk3_gfx2,'tnk3.zip',sizeof(tnk3_gfx2))) then exit;
        init_gfx(1,8,8,$400);
        gfx_set_desc_data(4,0,32*8,0,1,2,3);
        convert_gfx(1,0,@memoria_temp,@pb_x,@pc_y,false,false);
        //sprite 16
        if not(roms_load(@memoria_temp,@tnk3_sprite16,'tnk3.zip',sizeof(tnk3_sprite16))) then exit;
        init_gfx(2,16,16,$200);
        gfx[2].trans[7]:=true;
        gfx[2].shadow[6]:=true;
        gfx_set_desc_data(3,0,16*16,2*512*256,1*512*256,0*512*256);
        convert_gfx(2,0,@memoria_temp,@ps_x,@ps_y,false,false);
        //pal
        if not(roms_load(@memoria_temp,@tnk3_proms,'tnk3.zip',sizeof(tnk3_proms))) then exit;
        tank3_pal;
        marcade.dswa:=$3d;
        marcade.dswb:=$76;
        marcade.dswc:=$c1;
        marcade.dswa_val:=@tnk3_dip_a;
        marcade.dswb_val:=@tnk3_dip_b;
        marcade.dswc_val:=@tnk3_dip_c;
      end;
end;
//final
reset_snk;
iniciar_snk:=true;
end;

procedure Cargar_snk;
begin
llamadas_maquina.iniciar:=iniciar_snk;
llamadas_maquina.bucle_general:=snk_principal;
llamadas_maquina.reset:=reset_snk;
end;

end.
