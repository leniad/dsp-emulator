unit shadow_warriors_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,m68000,main_engine,controls_engine,gfx_engine,ym_2203,oki6295,rom_engine,
     pal_engine,sound_engine;

function iniciar_shadoww:boolean;

implementation

const
        shadoww_rom:array[0..1] of tipo_roms=(
        (n:'shadowa_1.3s';l:$20000;p:0;crc:$8290d567),(n:'shadowa_2.4s';l:$20000;p:1;crc:$f3f08921));
        shadoww_sound:tipo_roms=(n:'gaiden_3.4b';l:$10000;p:0;crc:$75fd3e6a);
        shadoww_char:tipo_roms=(n:'gaiden_5.7a';l:$10000;p:0;crc:$8d4035f7);
        shadoww_bg:array[0..3] of tipo_roms=(
        (n:'14.3a';l:$20000;p:0;crc:$1ecfddaa),(n:'15.3b';l:$20000;p:$20000;crc:$1291a696),
        (n:'16.1a';l:$20000;p:$40000;crc:$140b47ca),(n:'17.1b';l:$20000;p:$60000;crc:$7638cccb));
        shadoww_fg:array[0..3] of tipo_roms=(
        (n:'18.6a';l:$20000;p:0;crc:$3fadafd6),(n:'19.6b';l:$20000;p:$20000;crc:$ddae9d5b),
        (n:'20.4b';l:$20000;p:$40000;crc:$08cf7a93),(n:'21.4b';l:$20000;p:$60000;crc:$1ac892f5));
        shadoww_sprites:array[0..7] of tipo_roms=(
        (n:'6.3m';l:$20000;p:0;crc:$e7ccdf9f),(n:'7.1m';l:$20000;p:1;crc:$016bec95),
        (n:'8.3n';l:$20000;p:$40000;crc:$7ef7f880),(n:'9.1n';l:$20000;p:$40001;crc:$6e9b7fd3),
        (n:'10.3r';l:$20000;p:$80000;crc:$a6451dec),(n:'11.1r';l:$20000;p:$80001;crc:$7fbfdf5e),
        (n:'12.3s';l:$20000;p:$c0000;crc:$94a836d8),(n:'13.1s';l:$20000;p:$c0001;crc:$e9caea3b));
        shadoww_oki:tipo_roms=(n:'4.4a';l:$20000;p:0;crc:$b0e0faf9);
        shadoww_dip:array [0..7] of def_dip2=(
        (mask:1;name:'Demo Sounds';number:2;val2:(0,1);name2:('Off','On')),
        (mask:2;name:'Flip Screen';number:2;val2:(2,0);name2:('Off','On')),
        (mask:$1c;name:'Coin B';number:8;val8:(0,$10,8,4,$1c,$c,$14,$18);name8:('5C 1C','4C 1C','3C 1C','2C 1C','1C 1C','1C 2C','1C 3C','1C 4C')),
        (mask:$e0;name:'Coin A';number:8;val8:(0,$80,$40,$20,$e0,$60,$a0,$c0);name8:('5C 1C','4C 1C','3C 1C','2C 1C','1C 1C','1C 2C','1C 3C','1C 4C')),
        (mask:$c00;name:'Difficulty';number:4;val4:($c00,$400,$800,0);name4:('Normal','TBL 1','TBL 2','TBL 3')),
        (mask:$3000;name:'Energy';number:4;val4:(0,$3000,$1000,$2000);name4:('2','3','4','5')),
        (mask:$c000;name:'Lives';number:4;val4:(0,$c000,$4000,$8000);name4:('1','2','3','4')),());
        wildfang_rom:array[0..1] of tipo_roms=(
        (n:'1.3st';l:$20000;p:0;crc:$ab876c9b),(n:'2.5st';l:$20000;p:1;crc:$1dc74b3b));
        wildfang_sound:tipo_roms=(n:'tkni3.bin';l:$10000;p:0;crc:$15623ec7);
        wildfang_char:tipo_roms=(n:'tkni5.bin';l:$10000;p:0;crc:$5ed15896);
        wildfang_bg:array[0..3] of tipo_roms=(
        (n:'14.3a';l:$20000;p:0;crc:$0d20c10c),(n:'15.3b';l:$20000;p:$20000;crc:$3f40a6b4),
        (n:'16.1a';l:$20000;p:$40000;crc:$0f31639e),(n:'17.1b';l:$20000;p:$60000;crc:$f32c158e));
        wildfang_fg:tipo_roms=(n:'tkni6.bin';l:$80000;p:0;crc:$f68fafb1);
        wildfang_sprites:array[0..1] of tipo_roms=(
        (n:'tkni9.bin';l:$80000;p:0;crc:$d22f4239),(n:'tkni8.bin';l:$80000;p:1;crc:$4931b184));
        wildfang_oki:tipo_roms=(n:'tkni4.bin';l:$20000;p:0;crc:$a7a1dbcf);
        wildfang_dip:array [0..8] of def_dip2=(
        (mask:1;name:'Demo Sounds';number:2;val2:(0,1);name2:('Off','On')),
        (mask:2;name:'Flip Screen';number:2;val2:(2,0);name2:('Off','On')),
        (mask:$1c;name:'Coin B';number:8;val8:(0,$10,8,4,$1c,$c,$14,$18);name8:('5C 1C','4C 1C','3C 1C','2C 1C','1C 1C','1C 2C','1C 3C','1C 4C')),
        (mask:$e0;name:'Coin A';number:8;val8:(0,$80,$40,$20,$e0,$60,$a0,$c0);name8:('5C 1C','4C 1C','3C 1C','2C 1C','1C 1C','1C 2C','1C 3C','1C 4C')),
        (mask:$100;name:'Title';number:2;val2:($100,0);name2:('Wild Fang','Tecmo Knight')),
        (mask:$c00;name:'Difficulty (Wild Fang)';number:4;val4:($c00,$400,$800,0);name4:('Easy','Normal','Hard','Hardest')),
        (mask:$3000;name:'Difficulty (Tecmo Knight)';number:4;val4:($3000,$1000,$2000,0);name4:('Easy','Normal','Hard','Hardest')),
        (mask:$c000;name:'Lives';number:4;val4:($8000,$c000,$4000,0);name4:('1','2','3','Invalid')),());

var
 scroll_x_txt,scroll_y_txt,scroll_x_bg,scroll_y_bg,scroll_x_fg,scroll_y_fg:word;
 rom:array[0..$1ffff] of word;
 ram:array[0..$1fff] of word;
 video_ram1:array[0..$7ff] of word;
 video_ram2,video_ram3,sprite_ram:array[0..$fff] of word;
 sound_latch,scroll_y_txt_off,scroll_y_bg_off,scroll_y_fg_off:byte;
 //Proteccion
 wf_prot,wf_jumpcode:word;

procedure update_video_shadoww;
var
  f,x,y,nchar:word;
  color:byte;

procedure draw_sprites(pri:byte);
var
  posx,posy,sx,sy,atrib,nchar,color:word;
  f,sizex,sizey,row,col:byte;
  blend,flipx,flipy:boolean;
const
  layout:array[0..7,0..7] of byte=(
  ( 0, 1, 4, 5,16,17,20,21),
	( 2, 3, 6, 7,18,19,22,23),
	( 8, 9,12,13,24,25,28,29),
	(10,11,14,15,26,27,30,31),
	(32,33,36,37,48,49,52,53),
	(34,35,38,39,50,51,54,55),
	(40,41,44,45,56,57,60,61),
	(42,43,46,47,58,59,62,63));

procedure put_gfx_sprite_diff_sw(nchar:word;x_diff,y_diff:word);
var
  x,y,pos_x,pos_y:byte;
  ptemp,ptemp2:pword;
  pos:pbyte;
  dir_x,dir_y:integer;
  punt,punt2,temp1,temp2,temp3:word;
begin
pos:=gfx[3].datos;
inc(pos,nchar*8*8);
pos_y:=7*byte(flipy);
if flipy then dir_y:=-1
  else dir_y:=1;
ptemp2:=punbuf;
if flipx then begin
  inc(ptemp2,7);
  dir_x:=-1;
end else dir_x:=1;
for y:=0 to 7 do begin
  ptemp:=ptemp2;
  pos_x:=7*byte(flipx);
  for x:=0 to 7 do begin
    if not(gfx[3].trans[pos^]) then begin
      if blend then begin
          punt:=getpixel(((posx+pos_x+x_diff) and $1ff)+ADD_SPRITE,((posy+pos_y+y_diff) and $1ff)+ADD_SPRITE,4);
          punt2:=paleta[pos^+color+$400];
          temp1:=(((punt and $f800)+(punt2 and $f800)) shr 1) and $f800;
          temp2:=(((punt and $7e0)+(punt2 and $7e0)) shr 1) and $7e0;
          temp3:=(((punt and $1f)+(punt2 and $1f)) shr 1) and $1f;
          punt2:=temp1 or temp2 or temp3;
      end else punt2:=paleta[pos^+color];
      ptemp^:=punt2;
    end else ptemp^:=paleta[MAX_COLORES];
    inc(ptemp,dir_x);
    pos_x:=pos_x+dir_x;
    inc(pos);
  end;
  putpixel_gfx_int(0+x_diff,pos_y+y_diff,8,PANT_SPRITES);
  pos_y:=pos_y+dir_y;
end;
end;

begin
  for f:=0 to $ff do begin
    atrib:=sprite_ram[f*8];
    if ((atrib and $c0) shr 6)<>pri then continue;
    if (atrib and 4)=0 then continue;
    flipx:=(atrib and 1)<>0;
    flipy:=(atrib and 2)<>0;
    blend:=(atrib and $20)<>0;
    color:=sprite_ram[2+(f*8)];
    sizex:=1 shl (color and 3);
    sizey:=sizex;
    nchar:=sprite_ram[1+(f*8)];
    if (sizex>=2) then nchar:=nchar and $7ffe;
		if (sizey>=2) then nchar:=nchar and $7ffd;
		if (sizex>=4) then nchar:=nchar and $7ffb;
		if (sizey>=4) then nchar:=nchar and $7ff7;
		if (sizex>=8) then nchar:=nchar and $7fef;
		if (sizey>=8) then nchar:=nchar and $7fdf;
    color:=color and $f0;
    posx:=sprite_ram[4+(f*8)] and $1ff;
    posy:=sprite_ram[3+(f*8)] and $1ff;
    for row:=0 to (sizey-1) do begin
      for col:=0 to (sizex-1) do begin
        if flipx then sx:=8*(sizex-1-col)
          else sx:=8*col;
        if flipy then sy:=8*(sizey-1-row)
          else sy:=8*row;
        put_gfx_sprite_diff_sw(nchar+layout[row][col],sx,sy);
      end;
    end;
    actualiza_gfx_sprite_size(posx,posy,4,8*sizex,8*sizey);
  end;
end;

begin
for f:=0 to $7ff do begin
  x:=f mod 64;
  y:=f div 64;
  color:=(video_ram3[f] and $f0) shr 4;
  if (gfx[1].buffer[f]or buffer_color[color+$30]) then begin
      nchar:=video_ram3[f+$800] and $fff;
      put_gfx_trans(x*16,y*16,nchar,(color shl 4)+$300,2,1);
      gfx[1].buffer[f]:=false;
  end;
  color:=(video_ram2[f] and $f0) shr 4;
  if (gfx[2].buffer[f] or buffer_color[color+$20]) then begin
      nchar:=video_ram2[f+$800] and $fff;
      put_gfx_trans(x*16,y*16,nchar,(color shl 4)+$200,3,2);
      gfx[2].buffer[f]:=false;
  end;
end;
for f:=0 to $3ff do begin
  color:=(video_ram1[f] and $f0) shr 4;
  if (gfx[0].buffer[f] or buffer_color[color+$10])  then begin
      x:=f mod 32;
      y:=f div 32;
      nchar:=video_ram1[f+$400] and $7ff;
      put_gfx_trans(x*8,y*8,nchar,(color shl 4)+$100,1,0);
      gfx[0].buffer[f]:=false;
  end;
end;
fill_full_screen(4,$200);
draw_sprites(3);
scroll_x_y(2,4,scroll_x_bg,scroll_y_bg-scroll_y_bg_off+16);
draw_sprites(2);
scroll_x_y(3,4,scroll_x_fg,scroll_y_fg-scroll_y_fg_off+16);
draw_sprites(1);
scroll_x_y(1,4,scroll_x_txt,scroll_y_txt-scroll_y_txt_off+16);
draw_sprites(0);
actualiza_trozo_final(0,16,256,224,4);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
end;

procedure eventos_shadoww;
begin
if event.arcade then begin
  //P1/P2
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fffe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fffd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $fffb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $fff7) else marcade.in1:=(marcade.in1 or 8);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $ffef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $ffdf) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.but2[0] then marcade.in1:=(marcade.in1 and $ffbf) else marcade.in1:=(marcade.in1 or $40);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $feff) else marcade.in1:=(marcade.in1 or $100);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $fdff) else marcade.in1:=(marcade.in1 or $200);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $fbff) else marcade.in1:=(marcade.in1 or $400);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $f7ff) else marcade.in1:=(marcade.in1 or $800);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $efff) else marcade.in1:=(marcade.in1 or $1000);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $dfff) else marcade.in1:=(marcade.in1 or $2000);
  if arcade_input.but2[1] then marcade.in1:=(marcade.in1 and $bfff) else marcade.in1:=(marcade.in1 or $4000);
  //SYSTEM
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $fffe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $fffd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $ffbf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $ff7f) else marcade.in0:=(marcade.in0 or $80);
end;
end;

procedure shadoww_principal;
var
  f:byte;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
 for f:=0 to $ff do begin
  if f=240 then begin
    update_video_shadoww;
    m68000_0.irq[5]:=ASSERT_LINE;
  end;
  //main
  m68000_0.run(frame_main);
  frame_main:=frame_main+m68000_0.tframes-m68000_0.contador;
  //sound
  z80_0.run(frame_snd);
  frame_snd:=frame_snd+z80_0.tframes-z80_0.contador;
 end;
 eventos_shadoww;
 video_sync;
end;
end;

function shadoww_getword(direccion:dword):word;
begin
case direccion of
    0..$3ffff:shadoww_getword:=rom[direccion shr 1];
    $60000..$63fff:shadoww_getword:=ram[(direccion and $3fff) shr 1];
    $70000..$70fff:shadoww_getword:=video_ram1[(direccion and $fff) shr 1];
    $72000..$73fff:shadoww_getword:=video_ram2[(direccion and $1fff) shr 1];
    $74000..$75fff:shadoww_getword:=video_ram3[(direccion and $1fff) shr 1];
    $76000..$77fff:shadoww_getword:=sprite_ram[(direccion and $1fff) shr 1];
    $78000..$79fff:shadoww_getword:=buffer_paleta[(direccion and $1fff) shr 1];
    $7a000:shadoww_getword:=marcade.in0;
    $7a002:shadoww_getword:=marcade.in1;
    $7a004:shadoww_getword:=marcade.dswa;
end;
end;

procedure shadoww_putword(direccion:dword;valor:word);
procedure cambiar_color(tmp_color,numero:word);
var
  color:tcolor;
begin
  color.b:=pal4bit(tmp_color shr 8);
  color.g:=pal4bit(tmp_color shr 4);
  color.r:=pal4bit(tmp_color);
  set_pal_color(color,numero);
  case numero of
    $100..$1ff:buffer_color[((numero shr 4) and $f)+$10]:=true;
    $200..$2ff:buffer_color[((numero shr 4) and $f)+$20]:=true;
    $300..$3ff:buffer_color[((numero shr 4) and $f)+$30]:=true;
  end;
end;
begin
case direccion of
    0..$3ffff:;
    $60000..$63fff:ram[(direccion and $3fff) shr 1]:=valor;
    $70000..$70fff:if video_ram1[(direccion and $fff) shr 1]<>valor then begin
                    gfx[0].buffer[((direccion and $fff) shr 1) and $3ff]:=true;
                    video_ram1[(direccion and $fff) shr 1]:=valor;
                   end;
    $72000..$73fff:if video_ram2[(direccion and $1fff) shr 1]<>valor then begin
                    gfx[2].buffer[((direccion and $1fff) shr 1) and $7ff]:=true;
                    video_ram2[(direccion and $1fff) shr 1]:=valor;
                   end;
    $74000..$75fff:if video_ram3[(direccion and $1fff) shr 1]<>valor then begin
                    gfx[1].buffer[((direccion and $1fff) shr 1) and $7ff]:=true;
                    video_ram3[(direccion and $1fff) shr 1]:=valor;
                   end;
    $76000..$77fff:sprite_ram[(direccion and $1fff) shr 1]:=valor;
    $78000..$79fff:if buffer_paleta[(direccion and $1fff) shr 1]<>valor then begin
                      buffer_paleta[(direccion and $1fff) shr 1]:=valor;
                      cambiar_color(valor,((direccion and $1fff) shr 1));
                   end;
    $7a104:scroll_y_txt:=valor;
 	  $7a108:scroll_y_txt_off:=valor and $ff;
	  $7a10c:scroll_x_txt:=valor;
	  $7a204:scroll_y_fg:=valor;
	  $7a208:scroll_y_fg_off:=valor and $ff;
	  $7a20c:scroll_x_fg:=valor;
	  $7a304:scroll_y_bg:=valor;
    $7a308:scroll_y_bg_off:=valor and $ff;
	  $7a30c:scroll_x_bg:=valor;
	  $7a800:; //watchdog
	  $7a802:begin
              sound_latch:=valor;
              z80_0.change_nmi(ASSERT_LINE);
           end;
	  $7a806:m68000_0.irq[5]:=CLEAR_LINE;
	  $7a808:main_screen.flip_main_screen:=(valor and 1)<>0;
  end;
end;

function shadoww_snd_getbyte(direccion:word):byte;
begin
  case direccion of
    0..$f7ff:shadoww_snd_getbyte:=mem_snd[direccion];
    $f800:shadoww_snd_getbyte:=oki_6295_0.read;
    $fc20:begin
            shadoww_snd_getbyte:=sound_latch;
            z80_0.change_nmi(CLEAR_LINE);
          end;
  end;
end;

procedure shadoww_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$efff:;
  $f000..$f7ff:mem_snd[direccion]:=valor;
  $f800:oki_6295_0.write(valor);
  $f810:ym2203_0.Control(valor);
  $f811:ym2203_0.Write(valor);
  $f820:ym2203_1.Control(valor);
  $f821:ym2203_1.Write(valor);
end;
end;

procedure shadoww_sound_update;
begin
  ym2203_0.Update;
  ym2203_1.Update;
  oki_6295_0.update;
end;

procedure shadoww_snd_irq(irqstate:byte);
begin
  z80_0.change_irq(irqstate);
end;

//Wild Fang/Tecmo Knight
function wildfang_getword(direccion:dword):word;
begin
case direccion of
  $7a006:wildfang_getword:=wf_prot;
  else wildfang_getword:=shadoww_getword(direccion);
end;
end;

procedure wildfang_putword(direccion:dword;valor:word);
const
  jumppoints:array[0..16] of word=(
	$0c0c,$0cac,$0d42,$0da2,$0eea,$112e,$1300,$13fa,
	$159a,$1630,$109a,$1700,$1750,$1806,$18d6,$1a44,
	$1b52);
begin
  case direccion of
    $7a802:begin
              sound_latch:=valor shr 8;
              z80_0.change_nmi(ASSERT_LINE);
           end;
    $7a804:begin
        valor:=valor shr 8;
		    case (valor and $f0) of
			    0:wf_prot:=0;  // init
			    $10:begin  // high 4 bits of jump code
				        wf_jumpcode:=(valor and $f) shl 4;
				        wf_prot:=$10;
              end;
			    $20:begin   // low 4 bits of jump code
				        wf_jumpcode:=wf_jumpcode or (valor and $f);
				        wf_prot:=$20;
              end;
			    $30:wf_prot:=$40 or ((jumppoints[wf_jumpcode] shr 12) and $f);  // ask for bits 12-15 of function address
			    $40:wf_prot:=$50 or ((jumppoints[wf_jumpcode] shr 8) and $f);  // ask for bits 8-11 of function address
			    $50:wf_prot:=$60 or ((jumppoints[wf_jumpcode] shr 4) and $f);  // ask for bits 4-7 of function address
			    $60:wf_prot:=$70 or ((jumppoints[wf_jumpcode] shr 0) and $f);  // ask for bits 0-3 of function address
        end;
     end;
    else shadoww_putword(direccion,valor);
  end;
end;

//Main
procedure reset_shadoww;
begin
 m68000_0.reset;
 z80_0.reset;
 frame_main:=m68000_0.tframes;
 frame_snd:=z80_0.tframes;
 ym2203_0.reset;
 ym2203_1.reset;
 oki_6295_0.reset;
 reset_video;
 reset_audio;
 marcade.in0:=$ff;
 marcade.in1:=$ffff;
 scroll_x_bg:=0;
 scroll_y_bg:=0;
 scroll_x_fg:=0;
 scroll_y_fg:=0;
 scroll_y_txt_off:=0;
 scroll_y_bg_off:=0;
 scroll_y_fg_off:=0;
 sound_latch:=0;
 wf_prot:=0;
 wf_jumpcode:=0;
end;

function iniciar_shadoww:boolean;
var
  ptemp:pbyte;
const
  pg_x:array[0..15] of dword=(0*4,1*4,2*4,3*4,4*4,5*4,6*4,7*4,
		8*32+0*4,8*32+1*4,8*32+2*4,8*32+3*4,8*32+4*4,8*32+5*4,8*32+6*4,8*32+7*4);
  pg_y:array[0..15] of dword=(0*32,1*32,2*32,3*32,4*32,5*32,6*32,7*32,
   16*32+0*32,16*32+1*32,16*32+2*32,16*32+3*32,16*32+4*32,16*32+5*32,16*32+6*32,16*32+7*32);
procedure convert_8(num:word;chr:byte);
begin
  init_gfx(chr,8,8,num);
  gfx[chr].trans[0]:=true;
  gfx_set_desc_data(4,0,8*8*4,0,1,2,3);
  convert_gfx(chr,0,ptemp,@pg_x,@pg_y,false,false);
end;
procedure convert_16(num:word;chr:byte);
begin
  init_gfx(chr,16,16,num);
  gfx[chr].trans[0]:=true;
  gfx_set_desc_data(4,0,4*8*32,0,1,2,3);
  convert_gfx(chr,0,ptemp,@pg_x,@pg_y,false,false);
end;
begin
llamadas_maquina.bucle_general:=shadoww_principal;
llamadas_maquina.reset:=reset_shadoww;
llamadas_maquina.fps_max:=59.169998;
iniciar_shadoww:=false;
iniciar_audio(false);
screen_init(1,256,256,true);
screen_mod_scroll(1,256,256,255,256,256,255);
screen_init(2,1024,512,true);
screen_mod_scroll(2,1024,512,1023,512,512,511);
screen_init(3,1024,512,true);
screen_mod_scroll(3,1024,512,1023,512,512,511);
screen_init(4,512,512,false,true);
iniciar_video(256,224);
//Main CPU
m68000_0:=cpu_m68000.create(18432000 div 2,256);
//Sound CPU
z80_0:=cpu_z80.create(4000000,256);
z80_0.change_ram_calls(shadoww_snd_getbyte,shadoww_snd_putbyte);
z80_0.init_sound(shadoww_sound_update);
//Sound Chips
YM2203_0:=ym2203_chip.create(4000000,1,0.5);
ym2203_0.change_irq_calls(shadoww_snd_irq);
YM2203_1:=ym2203_chip.create(4000000,1,0.5);
oki_6295_0:=snd_okim6295.create(1000000,OKIM6295_PIN7_HIGH,0.5);
getmem(ptemp,$100000);
case main_vars.tipo_maquina of
  338:begin //Shadow Warriors
      //cargar roms
      if not(roms_load16w(@rom,shadoww_rom)) then exit;
      m68000_0.change_ram16_calls(shadoww_getword,shadoww_putword);
      //cargar sonido
      if not(roms_load(@mem_snd,shadoww_sound)) then exit;
      if not(roms_load(oki_6295_0.get_rom_addr,shadoww_oki)) then exit;
      //convertir chars
      if not(roms_load(ptemp,shadoww_char)) then exit;
      convert_8($800,0);
      //convertir fondo
      if not(roms_load(ptemp,shadoww_bg)) then exit;
      convert_16($1000,1);
      if not(roms_load(ptemp,shadoww_fg)) then exit;
      convert_16($1000,2);
      //convertir sprites
      if not(roms_load16b(ptemp,shadoww_sprites)) then exit;
      convert_8($8000,3);
      //DIP
      marcade.dswa:=$ffff;
      marcade.dswa_val2:=@shadoww_dip;
  end;
  339:begin //Wild Fang/Tecmo Knight
      //cargar roms
      if not(roms_load16w(@rom,wildfang_rom)) then exit;
      m68000_0.change_ram16_calls(wildfang_getword,wildfang_putword);
      //cargar sonido
      if not(roms_load(@mem_snd,wildfang_sound)) then exit;
      if not(roms_load(oki_6295_0.get_rom_addr,wildfang_oki)) then exit;
      //convertir chars
      if not(roms_load(ptemp,wildfang_char)) then exit;
      convert_8($800,0);
      //convertir fondo
      if not(roms_load(ptemp,wildfang_bg)) then exit;
      convert_16($1000,1);
      if not(roms_load(ptemp,wildfang_fg)) then exit;
      convert_16($1000,2);
      //convertir sprites
      if not(roms_load16b(ptemp,wildfang_sprites)) then exit;
      convert_8($8000,3);
      //DIP
      marcade.dswa:=$ffff;
      marcade.dswa_val2:=@wildfang_dip;
  end;
end;
freemem(ptemp);
//final
reset_shadoww;
iniciar_shadoww:=true;
end;

end.
