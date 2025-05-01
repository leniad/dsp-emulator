unit dooyong_hw;
interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,ym_2151,gfx_engine,
     rom_engine,file_engine,pal_engine,sound_engine,oki6295,ym_2203;

function iniciar_dooyong:boolean;

implementation
const
        bluehawk_rom:tipo_roms=(n:'rom19';l:$20000;p:0;crc:$24149246);
        bluehawk_snd:tipo_roms=(n:'rom1';l:$10000;p:0;crc:$eef22920);
        bluehawk_char:tipo_roms=(n:'rom3';l:$10000;p:0;crc:$c192683f);
        bluehawk_sprites:tipo_roms=(n:'dy-bh-m3';l:$80000;p:0;crc:$8809d157);
        bluehawk_bg0:tipo_roms=(n:'dy-bh-m1';l:$80000;p:0;crc:$51816b2c);
        bluehawk_fg0:tipo_roms=(n:'dy-bh-m2';l:$80000;p:0;crc:$f9daace6);
        bluehawk_fg1:array[0..1] of tipo_roms=(
        (n:'rom6';l:$20000;p:0;crc:$e6bd9daa),(n:'rom5';l:$20000;p:$1;crc:$5c654dc6));
        bluehawk_oki:tipo_roms=(n:'rom4';l:$20000;p:0;crc:$f7318919);
        lastday_rom:array[0..1] of tipo_roms=(
        (n:'lday3.s5';l:$10000;p:0;crc:$a06dfb1e),(n:'4.u5';l:$10000;p:$10000;crc:$70961ea6));
        lastday_snd:tipo_roms=(n:'1.d3';l:$10000;p:0;crc:$dd4316fd);
        lastday_char:tipo_roms=(n:'2.j4';l:$10000;p:0;crc:$83eb572c);
        lastday_sprites:array[0..1] of tipo_roms=(
        (n:'16.d14';l:$20000;p:0;crc:$df503504),(n:'15.a14';l:$20000;p:1;crc:$cd990442));
        lastday_bg0:array[0..3] of tipo_roms=(
        (n:'6.s9';l:$20000;p:0;crc:$1054361d),(n:'9.s11';l:$20000;p:1;crc:$6952ef4d),
        (n:'7.u9';l:$20000;p:$40000;crc:$6e57a888),(n:'10.u11';l:$20000;p:$40001;crc:$a5548dca));
        lastday_fg0:array[0..1] of tipo_roms=(
        (n:'12.s13';l:$20000;p:0;crc:$992bc4af),(n:'14.s14';l:$20000;p:$1;crc:$a79abc85));
        lastday_bg0_map:array[0..1] of tipo_roms=(
        (n:'5.r9';l:$10000;p:0;crc:$4789bae8),(n:'8.r11';l:$10000;p:$1;crc:$92402b9a));
        lastday_fg0_map:array[0..1] of tipo_roms=(
        (n:'11.r13';l:$10000;p:0;crc:$04b961de),(n:'13.r14';l:$10000;p:$1;crc:$6bdbd887));
        gulfstorm_rom:tipo_roms=(n:'1.l4';l:$20000;p:0;crc:$59e0478b);
        gulfstorm_snd:tipo_roms=(n:'3.c5';l:$10000;p:0;crc:$c029b015);
        gulfstorm_char:tipo_roms=(n:'2.s4';l:$10000;p:0;crc:$c2d65a25);
        gulfstorm_sprites:array[0..3] of tipo_roms=(
        (n:'14.b1';l:$20000;p:0;crc:$67bdf73d),(n:'16.c1';l:$20000;p:1;crc:$7770a76f),
        (n:'15.b1';l:$20000;p:$40000;crc:$84803f7e),(n:'17.e1';l:$20000;p:$40001;crc:$94706500));
        gulfstorm_bg0:array[0..3] of tipo_roms=(
        (n:'4.d8';l:$20000;p:0;crc:$858fdbb6),(n:'5.b9';l:$20000;p:1;crc:$c0a552e8),
        (n:'6.d8';l:$20000;p:$40000;crc:$20eedda3),(n:'7.d9';l:$20000;p:$40001;crc:$294f8c40));
        gulfstorm_fg0:array[0..1] of tipo_roms=(
        (n:'12.r8';l:$20000;p:0;crc:$ec3ad3e7),(n:'13.r9';l:$20000;p:$1;crc:$c64090cb));
        gulfstorm_bg0_map:array[0..1] of tipo_roms=(
        (n:'8.e8';l:$10000;p:0;crc:$8d7f4693),(n:'9.e9';l:$10000;p:$1;crc:$34d440c4));
        gulfstorm_fg0_map:array[0..1] of tipo_roms=(
        (n:'10.n8';l:$10000;p:0;crc:$b4f15bf4),(n:'11.n9';l:$10000;p:$1;crc:$7dfe4a9c));
        pollux_rom:tipo_roms=(n:'pollux2.bin';l:$10000;p:0;crc:$45e10d4e);
        pollux_snd:tipo_roms=(n:'pollux3.bin';l:$10000;p:0;crc:$85a9dc98);
        pollux_char:tipo_roms=(n:'pollux1.bin';l:$10000;p:0;crc:$7f7135da);
        pollux_sprites:tipo_roms=(n:'dy-pl-m2_be023.bin';l:$80000;p:0;crc:$bdea6f7d);
        pollux_bg0:tipo_roms=(n:'dy-pl-m1_be015.bin';l:$80000;p:0;crc:$1d2dedd2);
        pollux_fg0:array[0..1] of tipo_roms=(
        (n:'pollux6.bin';l:$20000;p:0;crc:$b0391db5),(n:'pollux7.bin';l:$20000;p:$1;crc:$632f6e10));
        pollux_bg0_map:array[0..1] of tipo_roms=(
        (n:'pollux9.bin';l:$10000;p:0;crc:$378d8914),(n:'pollux8.bin';l:$10000;p:$1;crc:$8859fa70));
        pollux_fg0_map:array[0..1] of tipo_roms=(
        (n:'pollux5.bin';l:$10000;p:0;crc:$ac090d34),(n:'pollux4.bin';l:$10000;p:$1;crc:$2c6bd3be));
        flytiger_rom:tipo_roms=(n:'1.3c';l:$20000;p:0;crc:$2d634c8e);
        flytiger_snd:tipo_roms=(n:'3.6p';l:$10000;p:0;crc:$d238df5e);
        flytiger_char:tipo_roms=(n:'2.4h';l:$10000;p:0;crc:$2fb72912);
        flytiger_sprites:array[0..3] of tipo_roms=(
        (n:'16.4h';l:$20000;p:0;crc:$8a158b95),(n:'15.2h';l:$20000;p:$1;crc:$399f6043),
        (n:'14.4k';l:$20000;p:$40000;crc:$df66b6f3),(n:'13.2k';l:$20000;p:$40001;crc:$f24a5099));
        flytiger_bg0:tipo_roms=(n:'dy-ft-m1.11n';l:$80000;p:0;crc:$f06589c2);
        flytiger_fg0:tipo_roms=(n:'dy-ft-m2.11g';l:$80000;p:0;crc:$7545f9c9);
        flytiger_oki:tipo_roms=(n:'4.9n';l:$20000;p:0;crc:$cd95cf9a);
        //Dip
        bluehawk_dip_a:array [0..5] of def_dip=(
        (mask:$2;name:'Coinage Type';number:2;dip:((dip_val:$2;dip_name:'Type A'),(dip_val:$0;dip_name:'Type B'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$4;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Flip Screen';number:2;dip:((dip_val:$8;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Coin A';number:4;dip:((dip_val:$10;dip_name:'2C 1C/3C 1C'),(dip_val:$30;dip_name:'1C 1C/1C 1C'),(dip_val:$0;dip_name:'2C 3C/4C 1C'),(dip_val:$20;dip_name:'1C 2C/2C 1C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Coin B';number:4;dip:((dip_val:$40;dip_name:'2C 1C/1C 4C'),(dip_val:$c0;dip_name:'1C 1C/1C 2C'),(dip_val:$0;dip_name:'2C 3C/1C 6C'),(dip_val:$80;dip_name:'1C 2C/1C 3C'),(),(),(),(),(),(),(),(),(),(),(),())),());
        bluehawk_dip_b:array [0..3] of def_dip=(
        (mask:$3;name:'Lives';number:4;dip:((dip_val:$0;dip_name:'1'),(dip_val:$2;dip_name:'2'),(dip_val:$3;dip_name:'3'),(dip_val:$1;dip_name:'4'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Difficulty';number:4;dip:((dip_val:$8;dip_name:'Easy'),(dip_val:$c;dip_name:'Normal'),(dip_val:$4;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Allow Continue';number:2;dip:((dip_val:$0;dip_name:'No'),(dip_val:$80;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        lastday_dip_b:array [0..5] of def_dip=(
        (mask:$3;name:'Lives';number:4;dip:((dip_val:$0;dip_name:'1'),(dip_val:$2;dip_name:'2'),(dip_val:$3;dip_name:'3'),(dip_val:$1;dip_name:'4'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Difficulty';number:4;dip:((dip_val:$8;dip_name:'Easy'),(dip_val:$c;dip_name:'Normal'),(dip_val:$4;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Bonus Life';number:4;dip:((dip_val:$30;dip_name:'200K+'),(dip_val:$20;dip_name:'240K+'),(dip_val:$10;dip_name:'280K'),(dip_val:$0;dip_name:'None'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Speed';number:2;dip:((dip_val:$0;dip_name:'Low'),(dip_val:$40;dip_name:'High'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Allow Continue';number:2;dip:((dip_val:$0;dip_name:'No'),(dip_val:$80;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        gulfstorm_dip_b:array [0..5] of def_dip=(
        (mask:$3;name:'Lives';number:4;dip:((dip_val:$0;dip_name:'1'),(dip_val:$2;dip_name:'2'),(dip_val:$3;dip_name:'3'),(dip_val:$1;dip_name:'4'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Difficulty';number:4;dip:((dip_val:$8;dip_name:'Easy'),(dip_val:$c;dip_name:'Normal'),(dip_val:$4;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Bonus Life';number:4;dip:((dip_val:$30;dip_name:'300K+'),(dip_val:$20;dip_name:'400K+'),(dip_val:$10;dip_name:'500K+'),(dip_val:$0;dip_name:'None'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Power Rise';number:2;dip:((dip_val:$40;dip_name:'1'),(dip_val:$0;dip_name:'2'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Allow Continue';number:2;dip:((dip_val:$0;dip_name:'No'),(dip_val:$80;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

type
  tile_info=record
    rom:array[0..$ffff] of word;
    enabled,redraw:boolean;
    reg:array[0..7] of byte;
    pant,gfx:byte;
    mask_rom:dword;
    mask_tile,color:word;
  end;

var
 memoria_rom:array[0..7,$0..$3fff] of byte;
 banco_rom,sound_latch:byte;
 sprite_ram,txt_ram:array[0..$fff] of byte;
 tile_rom:array[0..2] of tile_info;
 update_video:procedure;
 update_eventos:procedure;
 screen_pri,vblank,sprites_disabled,ym_2203_irq_state,ym_2203_irq_state2:boolean;
 palette_bank:byte;
 //Sprites
 sprite_12bit,sprite_height,sprite_yshift_bw,sprite_yshift_ft:boolean;

procedure draw_tile(tile_num:byte);
var
  f:byte;
  x,y,atrib,nchar,color,pos:word;
begin
if not(tile_rom[tile_num].redraw) then exit;
pos:=tile_rom[tile_num].reg[1]*8*8;
if (tile_rom[tile_num].reg[6] and $20)<>0 then begin
  for f:=$0 to $ff do begin
	  atrib:=tile_rom[tile_num].rom[(f+pos) and tile_rom[tile_num].mask_rom];
    nchar:=((atrib and $1ff) or ((atrib and $8000) shr 6)) and tile_rom[tile_num].mask_tile;
    color:=(((atrib and $7800) shr 11) or palette_bank) shl 4;
    x:=f div 8;
    y:=f mod 8;
    put_gfx_trans_flip(x*32,y*32,nchar,color+tile_rom[tile_num].color,tile_rom[tile_num].pant,tile_rom[tile_num].gfx,(atrib and $200)<>0,(atrib and $400)<>0);
  end;
end else begin
  for f:=$0 to $ff do begin
	  atrib:=tile_rom[tile_num].rom[(f+pos) and tile_rom[tile_num].mask_rom];
    nchar:=atrib and tile_rom[tile_num].mask_tile;
    color:=(palette_bank or ((atrib and $3c00) shr 10)) shl 4;
    x:=f div 8;
    y:=f mod 8;
    put_gfx_trans_flip(x*32,y*32,nchar,color+tile_rom[tile_num].color,tile_rom[tile_num].pant,tile_rom[tile_num].gfx,(atrib and $4000)<>0,(atrib and $8000)<>0);
  end;
end;
tile_rom[tile_num].redraw:=false;
end;

procedure draw_sprites(pri:byte);
var
  f,h,atrib2,prio:byte;
  x,y,atrib,color,nchar,sy,height:word;
  flip_x,flip_y:boolean;
begin
for f:=$7f downto 0 do begin
    atrib:=buffer_sprites[(f*32)+1];
    color:=atrib and $f;
    if ((color=0) or (color=$f)) then prio:=0
      else prio:=1;
    if prio<>pri then continue;
    x:=buffer_sprites[(f*32)+3] or ((atrib and $10) shl 4);
		y:=buffer_sprites[(f*32)+2];
		nchar:=buffer_sprites[f*32] or ((atrib and $e0) shl 3);
    atrib2:=buffer_sprites[(f*32)+$1c];
    //SPRITE_12BIT
    if sprite_12bit then nchar:=nchar or ((atrib2 and $1) shl 11);
    //SPRITE_HEIGHT
    height:=0;
    flip_x:=false;
    flip_y:=false;
    if sprite_height then begin
      height:=(atrib2 and $70) shr 4;
      nchar:=nchar and not(height);
		  flip_x:=(atrib2 and $8)<>0;
      flip_y:=(atrib2 and $4)<>0;
    end;
    //SPRITE_YSHIFT_BLUEHAWK
    if sprite_yshift_bw then y:=y+6-((not(atrib2) and $2) shl 7);
    //SPRITE_YSHIFT_FLYTIGER
    if sprite_yshift_ft then y:=y-((atrib2 and $02) shl 7);
    for h:=0 to height do begin
      if flip_y then sy:=y+(16*(height-h))
        else sy:=y+(16*h);
      put_gfx_sprite(nchar+h,((color or palette_bank) shl 4)+$100,flip_x,flip_y,1);
      actualiza_gfx_sprite(x,sy,5,1);
    end;
end;
end;

procedure dooyong_principal;
var
  f:byte;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
  for f:=0 to 255 do begin
    update_eventos;
    case f of
      31:vblank:=false;
      248:begin
            z80_0.change_irq(HOLD_LINE);
            copymemory(@buffer_sprites,@sprite_ram,$1000);
            update_video;
            vblank:=true;
          end;
    end;
    //Main CPU
    z80_0.run(frame_main);
    frame_main:=frame_main+z80_0.tframes-z80_0.contador;
    //Sound CPU
    z80_1.run(frame_snd);
    frame_snd:=frame_snd+z80_1.tframes-z80_1.contador;
  end;
  video_sync;
end;
end;

procedure cambiar_color(dir:word);
var
  tmp_color:word;
  color:tcolor;
begin
  tmp_color:=(buffer_paleta[dir+1] shl 8)+buffer_paleta[dir+0];
  color.r:=pal5bit(tmp_color shr 10);
  color.g:=pal5bit(tmp_color shr 5);
  color.b:=pal5bit(tmp_color);
  dir:=dir shr 1;
  set_pal_color(color,dir);
  case dir of
    0..$ff,$400..$4ff:buffer_color[dir shr 4]:=true;
    $200..$2ff,$600..$6ff:tile_rom[1].redraw:=true;
    $300..$3ff,$700..$7ff:tile_rom[0].redraw:=true;
  end;
end;

procedure examine_tile(valor,direccion,num:byte);
begin
case direccion of
  1:if (valor<>tile_rom[num].reg[1]) then tile_rom[num].redraw:=true;
  6:begin
      tile_rom[num].enabled:=(valor and $10)=0;
      if ((valor and $20)<>(tile_rom[num].reg[direccion] and $20)) then tile_rom[num].redraw:=true;
    end;
end;
tile_rom[num].reg[direccion]:=valor;
end;

//Blue Hawk
procedure eventos_bluehawk;
begin
if event.arcade then begin
  //P1
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  //P2
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or 8);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  //SYS
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or $8);
end;
end;

procedure update_video_bluehawk;
var
    atrib,f,x,y,nchar,color:word;
begin
fill_full_screen(5,$400);
if tile_rom[0].enabled then begin
  draw_tile(0);
  scroll_x_y(tile_rom[0].pant,5,tile_rom[0].reg[0],tile_rom[0].reg[3] or (tile_rom[0].reg[4] shl 8));
end;
draw_sprites(0);
if tile_rom[1].enabled then begin
  draw_tile(1);
  scroll_x_y(tile_rom[1].pant,5,tile_rom[1].reg[0],tile_rom[1].reg[3] or (tile_rom[1].reg[4] shl 8));
end;
draw_sprites(1);
if tile_rom[2].enabled then begin
  draw_tile(2);
  scroll_x_y(tile_rom[2].pant,5,tile_rom[2].reg[0],tile_rom[2].reg[3] or (tile_rom[2].reg[4] shl 8));
end;
for f:=$0 to $7ff do begin
   atrib:=txt_ram[(f*2)+1];
   color:=atrib shr 4;
   if (gfx[0].buffer[f] or buffer_color[color]) then begin
      x:=f div 32;
      y:=f mod 32;
      nchar:=(txt_ram[f*2]+((atrib and $f) shl 8)) and $7ff;
      put_gfx_trans(x*8,y*8,nchar,color shl 4,4,0);
      gfx[0].buffer[f]:=false;
   end;
end;
actualiza_trozo(0,0,512,256,4,0,0,512,256,5);
actualiza_trozo_final(64,8,384,240,5);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
end;

function bluehawk_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff,$f000..$ffff:bluehawk_getbyte:=memoria[direccion];
  $8000..$bfff:bluehawk_getbyte:=memoria_rom[banco_rom,(direccion and $3fff)];
  $c000:bluehawk_getbyte:=marcade.dswa;
  $c001:bluehawk_getbyte:=marcade.dswb;
  $c002:bluehawk_getbyte:=marcade.in0;
  $c003:bluehawk_getbyte:=marcade.in1;
  $c004:bluehawk_getbyte:=marcade.in2;
  $c800..$cfff:bluehawk_getbyte:=buffer_paleta[direccion and $7ff];
  $d000..$dfff:bluehawk_getbyte:=txt_ram[direccion and $fff];
  $e000..$efff:bluehawk_getbyte:=sprite_ram[direccion and $fff];
end;
end;

procedure bluehawk_putbyte(direccion:word;valor:byte);
begin
case direccion of
        0..$bfff:; //ROM
        $c000:main_screen.flip_main_screen:=(valor and 1)<>0;
        $c008:banco_rom:=valor and $7;
        $c010:sound_latch:=valor;
        $c018..$c01f:examine_tile(valor,direccion and 7,2); //fg1
	      $c040..$c047:examine_tile(valor,direccion and 7,0); //bg0
	      $c048..$c04f:examine_tile(valor,direccion and 7,1); //fg0
	      $c800..$cfff:if buffer_paleta[direccion and $7ff]<>valor then begin
                        buffer_paleta[direccion and $7ff]:=valor;
                        cambiar_color(direccion and $7fe);
                     end;
	      $d000..$dfff:if txt_ram[direccion and $fff]<>valor then begin
                        txt_ram[direccion and $fff]:=valor;
                        gfx[0].buffer[(direccion and $fff) shr 1]:=true;
                     end;
        $e000..$efff:sprite_ram[direccion and $fff]:=valor;
        $f000..$ffff:memoria[direccion]:=valor;
end;
end;

function bluehawk_snd_getbyte(direccion:word):byte;
begin
  case direccion of
    0..$f7ff:bluehawk_snd_getbyte:=mem_snd[direccion];
    $f800:bluehawk_snd_getbyte:=sound_latch;
    $f808:bluehawk_snd_getbyte:=ym2151_0.status;
    $f80a:bluehawk_snd_getbyte:=oki_6295_0.read;
  end;
end;

procedure bluehawk_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$efff:; //ROM
  $f000..$f7ff:mem_snd[direccion]:=valor;
  $f808:ym2151_0.reg(valor);
  $f809:ym2151_0.write(valor);
  $f80a:oki_6295_0.write(valor);
end;
end;

//The Last Day
procedure eventos_lastday;
begin
if event.arcade then begin
  //P1
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  //P2
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or 8);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  //SYS
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 and $bf) else marcade.in2:=(marcade.in2 or $40);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $7f) else marcade.in2:=(marcade.in2 or $80);
end;
end;

procedure update_video_lastday;
var
    atrib,f,x,y,nchar,color:word;
begin
fill_full_screen(5,$400);
if tile_rom[0].enabled then begin
  draw_tile(0);
  scroll_x_y(tile_rom[0].pant,5,tile_rom[0].reg[0],tile_rom[0].reg[3] or (tile_rom[0].reg[4] shl 8));
end;
if not(sprites_disabled) then draw_sprites(0);
if tile_rom[1].enabled then begin
  draw_tile(1);
  scroll_x_y(tile_rom[1].pant,5,tile_rom[1].reg[0],tile_rom[1].reg[3] or (tile_rom[1].reg[4] shl 8));
end;
if not(sprites_disabled) then draw_sprites(1);
for f:=$0 to $7ff do begin
   atrib:=txt_ram[f+$800];
   color:=atrib shr 4;
   if (gfx[0].buffer[f] or buffer_color[color]) then begin
      x:=f div 32;
      y:=f mod 32;
      nchar:=txt_ram[f]+((atrib and $3) shl 8);
      put_gfx_trans(x*8,y*8,nchar,color shl 4,4,0);
      gfx[0].buffer[f]:=false;
   end;
end;
actualiza_trozo(0,8,512,248,4,0,0,512,248,5);
actualiza_trozo_final(64,8,384,240,5);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
end;

function lastday_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff,$e000..$efff:lastday_getbyte:=memoria[direccion];
  $8000..$bfff:lastday_getbyte:=memoria_rom[banco_rom,(direccion and $3fff)];
  $c010:lastday_getbyte:=marcade.in2;
  $c011:lastday_getbyte:=marcade.in0;
  $c012:lastday_getbyte:=marcade.in1;
  $c013:lastday_getbyte:=marcade.dswa;
  $c014:lastday_getbyte:=marcade.dswb;
  $c800..$cfff:lastday_getbyte:=buffer_paleta[direccion and $7ff];
  $d000..$dfff:lastday_getbyte:=txt_ram[direccion and $fff];
  $f000..$ffff:lastday_getbyte:=sprite_ram[direccion and $fff];
end;
end;

procedure lastday_putbyte(direccion:word;valor:byte);
procedure cambiar_color4(dir:word);
var
  tmp_color:word;
  color:tcolor;
begin
  tmp_color:=(buffer_paleta[dir+1] shl 8)+buffer_paleta[dir+0];
  color.b:=pal4bit(tmp_color shr 8);
  color.g:=pal4bit(tmp_color shr 4);
  color.r:=pal4bit(tmp_color);
  dir:=dir shr 1;
  set_pal_color(color,dir);
  case dir of
    0..$ff:buffer_color[dir shr 4]:=true;
    $200..$2ff:tile_rom[1].redraw:=true;
    $300..$3ff:tile_rom[0].redraw:=true;
  end;
end;
begin
case direccion of
        0..$bfff:; //ROM
	      $c000..$c007:examine_tile(valor,direccion and 7,0); //bg0
	      $c008..$c00f:examine_tile(valor,direccion and 7,1); //fg0
        $c010:begin
                  sprites_disabled:=(valor and $10)<>0;
                  main_screen.flip_main_screen:=(valor and $40)<>0;
              end;
        $c011:banco_rom:=valor and $7;
        $c012:sound_latch:=valor;
	      $c800..$cfff:if buffer_paleta[direccion and $7ff]<>valor then begin
                        buffer_paleta[direccion and $7ff]:=valor;
                        cambiar_color4(direccion and $7fe);
                     end;
	      $d000..$dfff:if txt_ram[direccion and $fff]<>valor then begin
                        txt_ram[direccion and $fff]:=valor;
                        gfx[0].buffer[direccion and $7ff]:=true;
                     end;
        $e000..$efff:memoria[direccion]:=valor;
        $f000..$ffff:sprite_ram[direccion and $fff]:=valor;
end;
end;

function lastday_snd_getbyte(direccion:word):byte;
begin
  case direccion of
    0..$7fff,$c000..$c7ff:lastday_snd_getbyte:=mem_snd[direccion];
    $c800:lastday_snd_getbyte:=sound_latch;
    $f000:lastday_snd_getbyte:=ym2203_0.status;
    $f002:lastday_snd_getbyte:=ym2203_1.status;
  end;
end;

procedure lastday_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:; //ROM
  $c000..$c7ff:mem_snd[direccion]:=valor;
  $f000:ym2203_0.control(valor);
  $f001:ym2203_0.write(valor);
  $f002:ym2203_1.control(valor);
  $f003:ym2203_1.write(valor);
end;
end;

//Gulf Storm
procedure eventos_gulfstorm;
begin
if event.arcade then begin
  //P1
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  //P2
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or 8);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  //SYS
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 and $bf) else marcade.in2:=(marcade.in2 or $40);
end;
end;

function gulfstorm_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff,$c000..$cfff:gulfstorm_getbyte:=memoria[direccion];
  $8000..$bfff:gulfstorm_getbyte:=memoria_rom[banco_rom,(direccion and $3fff)];
  $d000..$dfff:gulfstorm_getbyte:=sprite_ram[direccion and $fff];
  $e000..$efff:gulfstorm_getbyte:=txt_ram[direccion and $fff];
  $f000:gulfstorm_getbyte:=marcade.dswa;
  $f001:gulfstorm_getbyte:=marcade.dswb;
  $f002:gulfstorm_getbyte:=marcade.in1;
  $f003:gulfstorm_getbyte:=marcade.in0;
  $f004:gulfstorm_getbyte:=marcade.in2 or byte(not(vblank))*$10;
  $f800..$ffff:gulfstorm_getbyte:=buffer_paleta[direccion and $7ff];
end;
end;

procedure gulfstorm_putbyte(direccion:word;valor:byte);
begin
case direccion of
        0..$bfff:; //ROM
        $c000..$cfff:memoria[direccion]:=valor;
        $d000..$dfff:sprite_ram[direccion and $fff]:=valor;
	      $e000..$efff:if txt_ram[direccion and $fff]<>valor then begin
                        txt_ram[direccion and $fff]:=valor;
                        gfx[0].buffer[direccion and $7ff]:=true;
                     end;
        $f000:banco_rom:=valor and $7;
        $f008:begin
                  main_screen.flip_main_screen:=(valor and 1)<>0;
                  if palette_bank<>((valor and 2) shl 5) then begin
                    palette_bank:=(valor and 2) shl 5;
                    tile_rom[0].redraw:=true;
                    tile_rom[1].redraw:=true;
                  end;
              end;
        $f010:sound_latch:=valor;
	      $f018..$f01f:examine_tile(valor,direccion and 7,0); //bg0
	      $f020..$f027:examine_tile(valor,direccion and 7,1); //fg0
	      $f800..$ffff:if buffer_paleta[direccion and $7ff]<>valor then begin
                        buffer_paleta[direccion and $7ff]:=valor;
                        cambiar_color(direccion and $7fe);
                     end;
end;
end;

//Pollux
procedure update_video_pollux;
var
    atrib,f,x,y,nchar,color:word;
begin
fill_full_screen(5,$800);
if tile_rom[0].enabled then begin
  draw_tile(0);
  scroll_x_y(tile_rom[0].pant,5,tile_rom[0].reg[0],tile_rom[0].reg[3] or (tile_rom[0].reg[4] shl 8));
end;
draw_sprites(0);
if tile_rom[1].enabled then begin
  draw_tile(1);
  scroll_x_y(tile_rom[1].pant,5,tile_rom[1].reg[0],tile_rom[1].reg[3] or (tile_rom[1].reg[4] shl 8));
end;
draw_sprites(1);
for f:=$0 to $7ff do begin
   atrib:=txt_ram[f+$800];
   color:=atrib shr 4;
   if (gfx[0].buffer[f] or buffer_color[color]) then begin
      x:=f div 32;
      y:=f mod 32;
      nchar:=txt_ram[f]+((atrib and $7) shl 8);
      put_gfx_trans(x*8,y*8,nchar,(color or palette_bank) shl 4,4,0);
      gfx[0].buffer[f]:=false;
   end;
end;
actualiza_trozo(0,0,512,256,4,0,0,512,256,5);
actualiza_trozo_final(64,8,384,240,5);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
end;

function pollux_getbyte(direccion:word):byte;
begin
case direccion of
  0..$f001,$f004..$f7ff:pollux_getbyte:=gulfstorm_getbyte(direccion);
  $f002:pollux_getbyte:=marcade.in0;
  $f003:pollux_getbyte:=marcade.in1;
  $f800..$ffff:if palette_bank<>0 then pollux_getbyte:=buffer_paleta[(direccion and $7ff) or $800]
                  else pollux_getbyte:=buffer_paleta[direccion and $7ff];
end;
end;

procedure pollux_putbyte(direccion:word;valor:byte);
begin
case direccion of
        0..$bfff:; //ROM
        $c000..$f7ff:gulfstorm_putbyte(direccion,valor);
	      $f800..$ffff:begin
                        if palette_bank<>0 then direccion:=(direccion and $7ff) or $800
                          else direccion:=direccion and $7ff;
                        if buffer_paleta[direccion]<>valor then begin
                          buffer_paleta[direccion]:=valor;
                          cambiar_color(direccion and $ffe);
                        end;
                     end;
end;
end;

function pollux_snd_getbyte(direccion:word):byte;
begin
  case direccion of
    0..$efff,$f000..$f7ff:pollux_snd_getbyte:=mem_snd[direccion];
    $f800:pollux_snd_getbyte:=sound_latch;
    $f802:pollux_snd_getbyte:=ym2203_0.status;
    $f804:pollux_snd_getbyte:=ym2203_1.status;
  end;
end;

procedure pollux_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$efff:; //ROM
  $f000..$f7ff:mem_snd[direccion]:=valor;
  $f802:ym2203_0.control(valor);
  $f803:ym2203_0.write(valor);
  $f804:ym2203_1.control(valor);
  $f805:ym2203_1.write(valor);
end;
end;

//Flying Tiger
procedure update_video_flytiger;
var
    atrib,f,x,y,nchar,color:word;
begin
fill_full_screen(5,$800);
if screen_pri then begin
  if tile_rom[1].enabled then begin
    draw_tile(1);
    scroll_x_y(tile_rom[1].pant,5,tile_rom[1].reg[0],tile_rom[1].reg[3] or (tile_rom[1].reg[4] shl 8));
  end;
  draw_sprites(0);
  if tile_rom[0].enabled then begin
    draw_tile(0);
    scroll_x_y(tile_rom[0].pant,5,tile_rom[0].reg[0],tile_rom[0].reg[3] or (tile_rom[0].reg[4] shl 8));
  end;
  draw_sprites(1);
end else begin
  if tile_rom[0].enabled then begin
    draw_tile(0);
    scroll_x_y(tile_rom[0].pant,5,tile_rom[0].reg[0],tile_rom[0].reg[3] or (tile_rom[0].reg[4] shl 8));
  end;
  draw_sprites(0);
  if tile_rom[1].enabled then begin
    draw_tile(1);
    scroll_x_y(tile_rom[1].pant,5,tile_rom[1].reg[0],tile_rom[1].reg[3] or (tile_rom[1].reg[4] shl 8));
  end;
  draw_sprites(1);
end;
for f:=$0 to $7ff do begin
   atrib:=txt_ram[f+$800];
   color:=atrib shr 4;
   if (gfx[0].buffer[f] or buffer_color[color]) then begin
      x:=f div 32;
      y:=f mod 32;
      nchar:=txt_ram[f]+((atrib and $7) shl 8);
      put_gfx_trans(x*8,y*8,nchar,(color or palette_bank) shl 4,4,0);
      gfx[0].buffer[f]:=false;
   end;
end;
actualiza_trozo(0,0,512,256,4,0,0,512,256,5);
actualiza_trozo_final(64,8,384,240,5);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
end;

function flytiger_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff,$d000..$dfff:flytiger_getbyte:=memoria[direccion];
  $8000..$bfff:flytiger_getbyte:=memoria_rom[banco_rom,(direccion and $3fff)];
  $c000..$cfff:flytiger_getbyte:=sprite_ram[direccion and $fff];
  $e000:flytiger_getbyte:=marcade.in0;
  $e002:flytiger_getbyte:=marcade.in1;
  $e004:flytiger_getbyte:=marcade.in2;
  $e006:flytiger_getbyte:=marcade.dswa;
  $e008:flytiger_getbyte:=marcade.dswb;
  $e800..$efff:if palette_bank<>0 then flytiger_getbyte:=buffer_paleta[(direccion and $7ff) or $800]
                  else flytiger_getbyte:=buffer_paleta[direccion and $7ff];
  $f000..$ffff:flytiger_getbyte:=txt_ram[direccion and $fff];
end;
end;

procedure flytiger_putbyte(direccion:word;valor:byte);
begin
case direccion of
        0..$bfff:; //ROM
        $c000..$cfff:sprite_ram[direccion and $fff]:=valor;
        $d000..$dfff:memoria[direccion]:=valor;
        $e000:banco_rom:=valor and $7;
        $e010:begin
                  main_screen.flip_main_screen:=(valor and 1)<>0;
                  if palette_bank<>((valor and 8) shl 3) then begin
                    palette_bank:=(valor and 8) shl 3;
                    tile_rom[0].redraw:=true;
                    tile_rom[1].redraw:=true;
                  end;
                  screen_pri:=(valor and $10)<>0;
              end;
        $e020:sound_latch:=valor;
	      $e030..$e037:examine_tile(valor,direccion and 7,0); //bg0
	      $e040..$e047:examine_tile(valor,direccion and 7,1); //fg0
        $e800..$efff:begin
                        if palette_bank<>0 then direccion:=(direccion and $7ff) or $800
                          else direccion:=direccion and $7ff;
                        if buffer_paleta[direccion]<>valor then begin
                          buffer_paleta[direccion]:=valor;
                          cambiar_color(direccion and $ffe);
                        end;
                     end;
	      $f000..$ffff:if txt_ram[direccion and $fff]<>valor then begin
                        txt_ram[direccion and $fff]:=valor;
                        gfx[0].buffer[direccion and $7ff]:=true;
                     end;
end;
end;

//Sound
procedure ym2151_sound_update;
begin
  ym2151_0.update;
  oki_6295_0.update;
end;

procedure ym2203_sound_update;
begin
  ym2203_0.update;
  ym2203_1.update;
end;

procedure sound_irq(irqstate:byte);
begin
  z80_1.change_irq(irqstate);
end;

procedure ym2203_sound_irq(irqstate:byte);
begin
  ym_2203_irq_state:=(irqstate=ASSERT_LINE);
  if not(ym_2203_irq_state) then z80_1.change_irq(CLEAR_LINE);
  if (ym_2203_irq_state or ym_2203_irq_state2) then z80_1.change_irq(ASSERT_LINE);
end;

procedure ym2203_sound_irq2(irqstate:byte);
begin
  ym_2203_irq_state2:=(irqstate=ASSERT_LINE);
  if not(ym_2203_irq_state2) then z80_1.change_irq(CLEAR_LINE);
  if (ym_2203_irq_state or ym_2203_irq_state2) then z80_1.change_irq(ASSERT_LINE);
end;

//Main
procedure reset_dooyong;
begin
 z80_0.reset;
 z80_1.reset;
 frame_main:=z80_0.tframes;
 frame_snd:=z80_1.tframes;
 case main_vars.tipo_maquina of
  371,375:begin
        ym2151_0.reset;
        oki_6295_0.reset;
        marcade.in2:=$ff;
      end;
  372,373,374:begin
        ym2203_0.reset;
        ym2203_1.reset;
        if main_vars.tipo_maquina=372 then marcade.in2:=$f7
          else marcade.in2:=$ef;
      end;
 end;
 banco_rom:=0;
 sound_latch:=0;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 sprites_disabled:=false;
 screen_pri:=false;
 vblank:=false;
 ym_2203_irq_state:=false;
 ym_2203_irq_state2:=false;
 palette_bank:=0;
 //Blue Hawk no lo inicializa bien y espera que este habilitado y los regs reseteados
 fillchar(tile_rom[0].reg,8,0);
 fillchar(tile_rom[1].reg,8,0);
 fillchar(tile_rom[2].reg,8,0);
 tile_rom[0].enabled:=true;
 tile_rom[1].enabled:=true;
 tile_rom[2].enabled:=true;
end;

function iniciar_dooyong:boolean;
var
  f:word;
  memoria_temp:array[0..$7ffff] of byte;
  snd_clock:byte;
const
    pc_x:array[0..7] of dword=(0*4, 1*4, 2*4, 3*4, 4*4, 5*4, 6*4, 7*4);
    pc_y:array[0..7] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32);
    tl_pc_x:array[0..7] of dword=(0, 1, 2, 3, 8, 9, 10, 11);
    tl_pc_y:array[0..7] of dword=(0*2*8, 1*2*8, 2*2*8, 3*2*8, 4*2*8, 5*2*8, 6*2*8, 7*2*8);
    ps_x:array[0..15] of dword=( 0, 1, 2, 3, 16+0, 16+1, 16+2, 16+3,
      4*8*16+0,4*8*16+1,4*8*16+2,4*8*16+3,4*8*16+16+0,4*8*16+16+1,4*8*16+16+2,4*8*16+16+3);
    pt_y:array[0..31] of dword=(0*4*8, 1*4*8, 2*4*8, 3*4*8, 4*4*8, 5*4*8, 6*4*8, 7*4*8,
      8*4*8, 9*4*8, 10*4*8, 11*4*8, 12*4*8, 13*4*8, 14*4*8, 15*4*8,
      16*4*8, 17*4*8, 18*4*8, 19*4*8, 20*4*8, 21*4*8, 22*4*8, 23*4*8,
      24*4*8, 25*4*8, 26*4*8, 27*4*8, 28*4*8, 29*4*8, 30*4*8, 31*4*8);
    pt_x:array[0..31] of dword=( 0, 1, 2, 3, 16+0, 16+1, 16+2, 16+3,
      4*8*32+0,4*8*32+1,4*8*32+2,4*8*32+3,4*8*32+16+0,4*8*32+16+1,4*8*32+16+2,4*8*32+16+3,
      2*4*8*32+0,2*4*8*32+1,2*4*8*32+2,2*4*8*32+3,2*4*8*32+16+0,2*4*8*32+16+1,2*4*8*32+16+2,2*4*8*32+16+3,
      3*4*8*32+0,3*4*8*32+1,3*4*8*32+2,3*4*8*32+3,3*4*8*32+16+0,3*4*8*32+16+1,3*4*8*32+16+2,3*4*8*32+16+3);
procedure convert_chars(num:word);
begin
  init_gfx(0,8,8,num);
  gfx[0].trans[15]:=true;
  gfx_set_desc_data(4,0,32*8,0,1,2,3);
  convert_gfx(0,0,@memoria_temp,@pc_x,@pc_y,false,false);
end;
procedure convert_chars_tl(num:word);
begin
  init_gfx(0,8,8,num);
  gfx[0].trans[15]:=true;
  gfx_set_desc_data(4,0,8*8*2,0,4,(num*$10*2)*4,((num*$10*2)+1)*4);
  convert_gfx(0,0,@memoria_temp[0],@tl_pc_x,@tl_pc_y,false,false);
end;
procedure convert_sprites(num:word);
begin
  init_gfx(1,16,16,num);
  gfx[1].trans[15]:=true;
  gfx_set_desc_data(4,0,128*8,0,4,8,12);
  convert_gfx(1,0,@memoria_temp,@ps_x,@pt_y,false,false);
end;
procedure convert_tiles(num:word;ngfx:byte);
begin
  init_gfx(ngfx,32,32,num);
  gfx[ngfx].trans[15]:=true;
  gfx_set_desc_data(4,0,32*32*4,0,4,8,12);
  convert_gfx(ngfx,0,@memoria_temp,@pt_x,@pt_y,false,false);
end;
begin
llamadas_maquina.bucle_general:=dooyong_principal;
llamadas_maquina.reset:=reset_dooyong;
llamadas_maquina.fps_max:=60;
iniciar_dooyong:=false;
iniciar_audio(false);
//Pantallas
screen_init(1,1024,256,true);
screen_mod_scroll(1,1024,512,1023,256,256,255);
screen_init(2,1024,256,true);
screen_mod_scroll(2,1024,512,1023,256,256,255);
screen_init(3,1024,256,true);
screen_mod_scroll(3,1024,512,1023,256,256,255);
screen_init(4,512,256,true);
screen_init(5,512,512,false,true);
main_screen.rot270_screen:=true;
iniciar_video(384,240);
//Main CPU
z80_0:=cpu_z80.create(8000000,256);
//Sound CPU
if main_vars.tipo_maquina=373 then z80_1:=cpu_z80.create(8000000,256)
  else z80_1:=cpu_z80.create(4000000,256);
sprite_12bit:=false;
sprite_height:=false;
sprite_yshift_bw:=false;
sprite_yshift_ft:=false;
case main_vars.tipo_maquina of
  371:begin  //BlueHawk
          update_video:=update_video_bluehawk;
          update_eventos:=eventos_bluehawk;
          z80_0.change_ram_calls(bluehawk_getbyte,bluehawk_putbyte);
          if not(roms_load(@memoria_temp,bluehawk_rom)) then exit;
          copymemory(@memoria,@memoria_temp,$8000);
          for f:=0 to 7 do copymemory(@memoria_rom[f,0],@memoria_temp[f*$4000],$4000);
          z80_1.change_ram_calls(bluehawk_snd_getbyte,bluehawk_snd_putbyte);
          z80_1.init_sound(ym2151_sound_update);
          if not(roms_load(@mem_snd,bluehawk_snd)) then exit;
          ym2151_0:=ym2151_chip.create(3579545);
          ym2151_0.change_irq_func(sound_irq);
          oki_6295_0:=snd_okim6295.Create(1000000,OKIM6295_PIN7_HIGH);
          if not(roms_load(oki_6295_0.get_rom_addr,bluehawk_oki)) then exit;
          //Graphics
          if not(roms_load(@memoria_temp,bluehawk_char)) then exit;
          convert_chars($800);
          if not(roms_load_swap_word(@memoria_temp,bluehawk_sprites)) then exit;
          convert_sprites($1000);
          sprite_12bit:=true;
          sprite_height:=true;
          sprite_yshift_bw:=true;
          //bg0
          if not(roms_load_swap_word(@memoria_temp,bluehawk_bg0)) then exit;
          convert_tiles($400,2);
          copymemory(@tile_rom[0].rom,@memoria_temp[$3c000*2],$8000);
          for f:=0 to $3fff do tile_rom[0].rom[f]:=((tile_rom[0].rom[f] and $ff) shl 8) or (tile_rom[0].rom[f] shr 8);
          tile_rom[0].pant:=1;
          tile_rom[0].gfx:=2;
          tile_rom[0].mask_rom:=$3fff;
          tile_rom[0].mask_tile:=$3ff;
          tile_rom[0].color:=$300;
          //fg0
          if not(roms_load_swap_word(@memoria_temp,bluehawk_fg0)) then exit;
          convert_tiles($400,3);
          copymemory(@tile_rom[1].rom,@memoria_temp[$3c000*2],$8000);
          for f:=0 to $3fff do tile_rom[1].rom[f]:=((tile_rom[1].rom[f] and $ff) shl 8) or (tile_rom[1].rom[f] shr 8);
          tile_rom[1].pant:=2;
          tile_rom[1].gfx:=3;
          tile_rom[1].mask_rom:=$3fff;
          tile_rom[1].mask_tile:=$3ff;
          tile_rom[1].color:=$200;
          //fg1
          if not(roms_load16b(@memoria_temp,bluehawk_fg1)) then exit;
          convert_tiles($200,4);
          copymemory(@tile_rom[2].rom,@memoria_temp[$1c000*2],$4000);
          for f:=0 to $1fff do tile_rom[2].rom[f]:=((tile_rom[2].rom[f] and $ff) shl 8) or (tile_rom[2].rom[f] shr 8);
          tile_rom[2].pant:=3;
          tile_rom[2].gfx:=4;
          tile_rom[2].mask_rom:=$1fff;
          tile_rom[2].mask_tile:=$1ff;
          tile_rom[2].color:=0;
          //DIP
          marcade.dswa:=$ff;
          marcade.dswb:=$ff;
          marcade.dswa_val:=@bluehawk_dip_a;
          marcade.dswb_val:=@bluehawk_dip_b;
      end;
  372:begin //The Last Day
          update_video:=update_video_lastday;
          update_eventos:=eventos_lastday;
          z80_0.change_ram_calls(lastday_getbyte,lastday_putbyte);
          if not(roms_load(@memoria_temp,lastday_rom)) then exit;
          copymemory(@memoria,@memoria_temp,$8000);
          for f:=0 to 7 do copymemory(@memoria_rom[f,0],@memoria_temp[f*$4000],$4000);
          z80_1.change_ram_calls(lastday_snd_getbyte,lastday_snd_putbyte);
          z80_1.init_sound(ym2203_sound_update);
          if not(roms_load(@memoria_temp,lastday_snd)) then exit;
          copymemory(@mem_snd,@memoria_temp[$8000],$8000);
          ym2203_0:=ym2203_chip.create(4000000,0.25,1);
          ym2203_0.change_irq_calls(ym2203_sound_irq);
          ym2203_1:=ym2203_chip.create(4000000,0.5,1);
          ym2203_1.change_irq_calls(ym2203_sound_irq2);
          //Graphics
          if not(roms_load(@memoria_temp,lastday_char)) then exit;
          copymemory(@memoria_temp[0],@memoria_temp[$8000],$8000);
          convert_chars_tl($400);
          if not(roms_load16b(@memoria_temp,lastday_sprites)) then exit;
          convert_sprites($800);
          //bg0
          if not(roms_load16b(@memoria_temp,lastday_bg0)) then exit;
          convert_tiles($400,2);
          if not(roms_load16w(@tile_rom[0].rom,lastday_bg0_map)) then exit;
          tile_rom[0].pant:=1;
          tile_rom[0].gfx:=2;
          tile_rom[0].mask_rom:=$ffff;
          tile_rom[0].mask_tile:=$3ff;
          tile_rom[0].color:=$300;
          //fg0
          if not(roms_load16b(@memoria_temp,lastday_fg0)) then exit;
          convert_tiles($200,3);
          if not(roms_load16w(@tile_rom[1].rom,lastday_fg0_map)) then exit;
          tile_rom[1].pant:=2;
          tile_rom[1].gfx:=3;
          tile_rom[1].mask_rom:=$ffff;
          tile_rom[1].mask_tile:=$1ff;
          tile_rom[1].color:=$200;
          //DIP
          marcade.dswa:=$ff;
          marcade.dswb:=$ff;
          marcade.dswa_val:=@bluehawk_dip_a;
          marcade.dswb_val:=@lastday_dip_b;
      end;
  373:begin //Gulf Storm
          update_video:=update_video_lastday;
          update_eventos:=eventos_gulfstorm;
          z80_0.change_ram_calls(gulfstorm_getbyte,gulfstorm_putbyte);
          if not(roms_load(@memoria_temp,gulfstorm_rom)) then exit;
          copymemory(@memoria,@memoria_temp,$8000);
          for f:=0 to 7 do copymemory(@memoria_rom[f,0],@memoria_temp[f*$4000],$4000);
          z80_1.change_ram_calls(lastday_snd_getbyte,lastday_snd_putbyte);
          z80_1.init_sound(ym2203_sound_update);
          if not(roms_load(@mem_snd,gulfstorm_snd)) then exit;
          ym2203_0:=ym2203_chip.create(1500000,0.25,1);
          ym2203_0.change_irq_calls(ym2203_sound_irq);
          ym2203_1:=ym2203_chip.create(1500000,0.5,1);
          ym2203_1.change_irq_calls(ym2203_sound_irq2);
          //Graphics
          if not(roms_load(@memoria_temp,gulfstorm_char)) then exit;
          copymemory(@memoria_temp[0],@memoria_temp[$8000],$8000);
          convert_chars_tl($400);
          if not(roms_load16b(@memoria_temp,gulfstorm_sprites)) then exit;
          convert_sprites($1000);
          sprite_12bit:=true;
          //bg0
          if not(roms_load16b(@memoria_temp,gulfstorm_bg0)) then exit;
          convert_tiles($400,2);
          if not(roms_load16w(@tile_rom[0].rom,gulfstorm_bg0_map)) then exit;
          tile_rom[0].pant:=1;
          tile_rom[0].gfx:=2;
          tile_rom[0].mask_rom:=$ffff;
          tile_rom[0].mask_tile:=$3ff;
          tile_rom[0].color:=$300;
          //fg0
          if not(roms_load16b(@memoria_temp,gulfstorm_fg0)) then exit;
          convert_tiles($200,3);
          if not(roms_load16w(@tile_rom[1].rom,gulfstorm_fg0_map)) then exit;
          tile_rom[1].pant:=2;
          tile_rom[1].gfx:=3;
          tile_rom[1].mask_rom:=$ffff;
          tile_rom[1].mask_tile:=$1ff;
          tile_rom[1].color:=$200;
          //DIP
          marcade.dswa:=$ff;
          marcade.dswb:=$ff;
          marcade.dswa_val:=@bluehawk_dip_a;
          marcade.dswb_val:=@gulfstorm_dip_b;
      end;
      374:begin //Pollux
          update_video:=update_video_pollux;
          update_eventos:=eventos_gulfstorm;
          z80_0.change_ram_calls(pollux_getbyte,pollux_putbyte);
          if not(roms_load(@memoria_temp,pollux_rom)) then exit;
          copymemory(@memoria,@memoria_temp,$8000);
          for f:=0 to 7 do copymemory(@memoria_rom[f,0],@memoria_temp[f*$4000],$4000);
          z80_1.change_ram_calls(pollux_snd_getbyte,pollux_snd_putbyte);
          z80_1.init_sound(ym2203_sound_update);
          if not(roms_load(@mem_snd,pollux_snd)) then exit;
          ym2203_0:=ym2203_chip.create(1500000,0.25,1);
          ym2203_0.change_irq_calls(ym2203_sound_irq);
          ym2203_1:=ym2203_chip.create(1500000,0.5,1);
          ym2203_1.change_irq_calls(ym2203_sound_irq2);
          //Graphics
          if not(roms_load(@memoria_temp,pollux_char)) then exit;
          copymemory(@memoria_temp[$10000],@memoria_temp[0],$8000);
          copymemory(@memoria_temp[0],@memoria_temp[$8000],$8000);
          copymemory(@memoria_temp[$8000],@memoria_temp[$10000],$8000);
          convert_chars_tl($800);
          if not(roms_load_swap_word(@memoria_temp,pollux_sprites)) then exit;
          convert_sprites($1000);
          sprite_12bit:=true;
          sprite_height:=true;
          //bg0
          if not(roms_load_swap_word(@memoria_temp,pollux_bg0)) then exit;
          convert_tiles($400,2);
          if not(roms_load16w(@tile_rom[0].rom,pollux_bg0_map)) then exit;
          tile_rom[0].pant:=1;
          tile_rom[0].gfx:=2;
          tile_rom[0].mask_rom:=$ffff;
          tile_rom[0].mask_tile:=$3ff;
          tile_rom[0].color:=$300;
          //fg0
          if not(roms_load16b(@memoria_temp,pollux_fg0)) then exit;
          fillchar(memoria_temp[$40000],$40000,$ff);
          convert_tiles($400,3);
          if not(roms_load16w(@tile_rom[1].rom,pollux_fg0_map)) then exit;
          tile_rom[1].pant:=2;
          tile_rom[1].gfx:=3;
          tile_rom[1].mask_rom:=$ffff;
          tile_rom[1].mask_tile:=$3ff;
          tile_rom[1].color:=$200;
          //DIP
          marcade.dswa:=$ff;
          marcade.dswb:=$ff;
          marcade.dswa_val:=@bluehawk_dip_a;
          marcade.dswb_val:=@bluehawk_dip_b;
      end;
      375:begin //Flying Tiger
          update_video:=update_video_flytiger;
          update_eventos:=eventos_bluehawk;
          z80_0.change_ram_calls(flytiger_getbyte,flytiger_putbyte);
          if not(roms_load(@memoria_temp,flytiger_rom)) then exit;
          copymemory(@memoria,@memoria_temp,$8000);
          for f:=0 to 7 do copymemory(@memoria_rom[f,0],@memoria_temp[f*$4000],$4000);
          z80_1.change_ram_calls(bluehawk_snd_getbyte,bluehawk_snd_putbyte);
          z80_1.init_sound(ym2151_sound_update);
          if not(roms_load(@mem_snd,flytiger_snd)) then exit;
          ym2151_0:=ym2151_chip.create(3579545);
          ym2151_0.change_irq_func(sound_irq);
          oki_6295_0:=snd_okim6295.Create(1000000,OKIM6295_PIN7_HIGH);
          if not(roms_load(oki_6295_0.get_rom_addr,flytiger_oki)) then exit;
          //Graphics
          if not(roms_load(@memoria_temp,flytiger_char)) then exit;
          copymemory(@memoria_temp[$10000],@memoria_temp[0],$8000);
          copymemory(@memoria_temp[0],@memoria_temp[$8000],$8000);
          copymemory(@memoria_temp[$8000],@memoria_temp[$10000],$8000);
          convert_chars_tl($800);
          if not(roms_load16b(@memoria_temp,flytiger_sprites)) then exit;
          convert_sprites($1000);
          sprite_12bit:=true;
          sprite_height:=true;
          sprite_yshift_ft:=true;
          //bg0
          if not(roms_load_swap_word(@memoria_temp,flytiger_bg0)) then exit;
          convert_tiles($400,2);
          copymemory(@tile_rom[0].rom,@memoria_temp[$3c000*2],$8000);
          for f:=0 to $3fff do tile_rom[0].rom[f]:=((tile_rom[0].rom[f] and $ff) shl 8) or (tile_rom[0].rom[f] shr 8);
          tile_rom[0].pant:=1;
          tile_rom[0].gfx:=2;
          tile_rom[0].mask_rom:=$3fff;
          tile_rom[0].mask_tile:=$3ff;
          tile_rom[0].color:=$300;
          //fg0
          if not(roms_load_swap_word(@memoria_temp,flytiger_fg0)) then exit;
          convert_tiles($400,3);
          copymemory(@tile_rom[1].rom,@memoria_temp[$3c000*2],$8000);
          for f:=0 to $3fff do tile_rom[1].rom[f]:=((tile_rom[1].rom[f] and $ff) shl 8) or (tile_rom[1].rom[f] shr 8);
          tile_rom[1].pant:=2;
          tile_rom[1].gfx:=3;
          tile_rom[1].mask_rom:=$3fff;
          tile_rom[1].mask_tile:=$3ff;
          tile_rom[1].color:=$200;
          //DIP
          marcade.dswa:=$ff;
          marcade.dswb:=$ff;
          marcade.dswa_val:=@bluehawk_dip_a;
          marcade.dswb_val:=@bluehawk_dip_b;
      end;
end;
//final
iniciar_dooyong:=true;
end;

end.
