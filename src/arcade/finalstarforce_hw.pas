unit finalstarforce_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,m68000,main_engine,controls_engine,gfx_engine,ym_2151,oki6295,rom_engine,
     pal_engine,sound_engine;

function iniciar_finalstarforce:boolean;

implementation

const
        finalstarforce_rom:array[0..1] of tipo_roms=(
        (n:'fstarf01.rom';l:$40000;p:0;crc:$94c71de6),(n:'fstarf02.rom';l:$40000;p:1;crc:$b1a07761));
        finalstarforce_sound:tipo_roms=(n:'fstarf07.rom';l:$10000;p:0;crc:$e0ad5de1);
        finalstarforce_char:tipo_roms=(n:'fstarf03.rom';l:$20000;p:0;crc:$54375335);
        finalstarforce_bg:array[0..1] of tipo_roms=(
        (n:'fstarf05.rom';l:$80000;p:0;crc:$77a281e7),(n:'fstarf04.rom';l:$80000;p:1;crc:$398a920d));
        finalstarforce_sprites:array[0..1] of tipo_roms=(
        (n:'fstarf09.rom';l:$80000;p:0;crc:$d51341d2),(n:'fstarf06.rom';l:$80000;p:1;crc:$07e40e87));
        finalstarforce_oki:tipo_roms=(n:'fstarf08.rom';l:$20000;p:0;crc:$f0ad5693);
        finalstarforce_dip_a:array [0..6] of def_dip2=(
        (mask:3;name:'Coin A';number:4;val4:(3,2,1,0);name4:('1C 1C','1C 2C','1C 3C','1C 4C')),
        (mask:$c;name:'Coin B';number:4;val4:(0,4,8,$c);name4:('4C 1C','3C 1C','2C 1C','1C 1C')),
        (mask:$10;name:'Flip Screen';number:2;val2:($10,0);name2:('Off','On')),
        (mask:$20;name:'Demo Sounds';number:2;val2:(0,$20);name2:('Off','On')),
        (mask:$40;name:'Allow Continue';number:2;val2:(0,$40);name2:('No','Yes')),
        (mask:$80;name:'Free Play';number:2;val2:($80,0);name2:('Off','On')),());
        finalstarforce_dip_b:array [0..4] of def_dip2=(
        (mask:3;name:'Lives';number:4;val4:(0,3,2,1);name4:('2','3','4','5')),
        (mask:$c;name:'Difficulty';number:4;val4:(8,$c,4,0);name4:('Easy','Medium','Hard','Hardest')),
        (mask:$30;name:'Level Up Speed';number:4;val4:($30,$20,$10,0);name4:('Fast','Fastest','Slow','Slowest')),
        (mask:$c0;name:'Bonus Life';number:4;val4:($c0,$80,$40,0);name4:('200K 1000K','220K 1200K','240K 1400K','500K+ once at highest score')),());

var
 scroll_x_txt,scroll_y_txt,scroll_x_bg,scroll_y_bg,scroll_x_fg,scroll_y_fg:word;
 rom:array[0..$3ffff] of word;
 ram:array[0..$1fff] of word;
 ram2:array[0..$2fff] of word;
 video_ram1,sprite_ram,video_ram2,video_ram3:array[0..$7ff] of word;
 sound_latch:byte;

procedure update_video_finalstarforce;
var
  f,x,y,nchar,atrib:word;
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
          punt2:=paleta[pos^+color+$800];
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
    atrib:=buffer_sprites_w[f*8];
    if (atrib and 4)=0 then continue;
    if ((atrib and $c0) shr 6)<>pri then continue;
    flipx:=(atrib and 1)<>0;
    flipy:=(atrib and 2)<>0;
    blend:=(atrib and $20)<>0;
    color:=buffer_sprites_w[2+(f*8)];
    sizex:=1 shl (color and 3);
    sizey:=1 shl ((color shr 2) and 3);
    nchar:=buffer_sprites_w[1+(f*8)];
    if (sizex>=2) then nchar:=nchar and $7ffe;
		if (sizey>=2) then nchar:=nchar and $7ffd;
		if (sizex>=4) then nchar:=nchar and $7ffb;
		if (sizey>=4) then nchar:=nchar and $7ff7;
		if (sizex>=8) then nchar:=nchar and $7fef;
		if (sizey>=8) then nchar:=nchar and $7fdf;
    color:=color and $f0;
    posx:=buffer_sprites_w[4+(f*8)] and $1ff;
    posy:=buffer_sprites_w[3+(f*8)] and $1ff;
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
for f:=0 to $3ff do begin
  x:=f mod 32;
  y:=f div 32;
  color:=video_ram3[f+$400] and $f;
  if (gfx[1].buffer[f+$400] or buffer_color[color+$30]) then begin
      nchar:=video_ram3[f] and $1fff;
      put_gfx_trans(x*16,y*16,nchar,(color shl 4)+$300,2,1);
      gfx[1].buffer[f+$400]:=false;
  end;
  color:=video_ram2[f+$400] and $f;
  if (gfx[1].buffer[f] or buffer_color[color+$20]) then begin
      nchar:=video_ram2[f] and $1fff;
      put_gfx_trans(x*16,y*16,nchar,(color shl 4)+$200,3,1);
      gfx[1].buffer[f]:=false;
  end;
end;
for f:=0 to $7ff do begin
  atrib:=video_ram1[f];
  color:=atrib shr 12;
  if (gfx[0].buffer[f] or buffer_color[color+$10])  then begin
      x:=f mod 64;
      y:=f div 64;
      nchar:=atrib and $fff;
      put_gfx_trans(x*8,y*8,nchar,(color shl 4)+$100,1,0);
      gfx[0].buffer[f]:=false;
  end;
end;
fill_full_screen(4,$300);
draw_sprites(3);
scroll_x_y(2,4,scroll_x_bg,scroll_y_bg);
draw_sprites(2);
scroll_x_y(3,4,scroll_x_fg,scroll_y_fg);
draw_sprites(1);
scroll_x_y(1,4,scroll_x_txt,scroll_y_txt-16);
draw_sprites(0);
actualiza_trozo_final(0,16,256,224,4);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
end;

procedure eventos_finalstarforce;
begin
if event.arcade then begin
  //P1/P2
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fffe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fffd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fffb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fff7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ffef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $ffdf) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $ffbf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $ff7f) else marcade.in0:=(marcade.in0 or $80);
  if arcade_input.right[1] then marcade.in0:=(marcade.in0 and $feff) else marcade.in0:=(marcade.in0 or $100);
  if arcade_input.left[1] then marcade.in0:=(marcade.in0 and $fdff) else marcade.in0:=(marcade.in0 or $200);
  if arcade_input.down[1] then marcade.in0:=(marcade.in0 and $fbff) else marcade.in0:=(marcade.in0 or $400);
  if arcade_input.up[1] then marcade.in0:=(marcade.in0 and $f7ff) else marcade.in0:=(marcade.in0 or $800);
  if arcade_input.but0[1] then marcade.in0:=(marcade.in0 and $efff) else marcade.in0:=(marcade.in0 or $1000);
  if arcade_input.but1[1] then marcade.in0:=(marcade.in0 and $dfff) else marcade.in0:=(marcade.in0 or $2000);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 or $4000) else marcade.in0:=(marcade.in0 and $bfff);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 or $8000) else marcade.in0:=(marcade.in0 and $7fff);
end;
end;

procedure finalstarforce_principal;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
frame_s:=z80_0.tframes;
while EmuStatus=EsRunning do begin
 for f:=0 to $ff do begin
  case f of
    0:m68000_0.irq[5]:=CLEAR_LINE;
    240:begin
          update_video_finalstarforce;
          copymemory(@buffer_sprites_w,@sprite_ram,$800*2);
          m68000_0.irq[5]:=ASSERT_LINE;
        end;
  end;
  //main
  m68000_0.run(frame_m);
  frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
  //sound
  z80_0.run(frame_s);
  frame_s:=frame_s+z80_0.tframes-z80_0.contador;
 end;
 eventos_finalstarforce;
 video_sync;
end;
end;

function finalstarforce_getword(direccion:dword):word;
begin
case direccion of
    0..$7ffff:finalstarforce_getword:=rom[direccion shr 1];
    $100000..$103fff:finalstarforce_getword:=ram[(direccion and $3fff) shr 1];
    $110000..$110fff:finalstarforce_getword:=video_ram1[(direccion and $fff) shr 1];
    $120000..$120fff:finalstarforce_getword:=video_ram2[(direccion and $fff) shr 1];
    $121000..$121fff:finalstarforce_getword:=video_ram3[(direccion and $fff) shr 1];
    $122000..$127fff:finalstarforce_getword:=ram2[(direccion-$122000) shr 1];
    $130000..$130fff:finalstarforce_getword:=sprite_ram[(direccion and $fff) shr 1];
    $140000..$141fff:finalstarforce_getword:=buffer_paleta[(direccion and $1fff) shr 1];
    $150020:finalstarforce_getword:=0;
    $150030:finalstarforce_getword:=marcade.dswb;
    $150040:finalstarforce_getword:=marcade.dswa;
    $150050:finalstarforce_getword:=marcade.in0;
end;
end;

procedure finalstarforce_putword(direccion:dword;valor:word);
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
    0..$7ffff:;
    $100000..$103fff:ram[(direccion and $3fff) shr 1]:=valor;
    $110000..$110fff:if video_ram1[(direccion and $fff) shr 1]<>valor then begin
                        gfx[0].buffer[((direccion and $fff) shr 1) and $7ff]:=true;
                        video_ram1[(direccion and $fff) shr 1]:=valor;
                     end;
    $120000..$120fff:if video_ram2[(direccion and $fff) shr 1]<>valor then begin
                        gfx[1].buffer[((direccion and $fff) shr 1) and $3ff]:=true;
                        video_ram2[(direccion and $fff) shr 1]:=valor;
                     end;
    $121000..$121fff:if video_ram3[(direccion and $fff) shr 1]<>valor then begin
                        gfx[1].buffer[(((direccion and $fff) shr 1) and $3ff)+$400]:=true;
                        video_ram3[(direccion and $fff) shr 1]:=valor;
                     end;
    $122000..$127fff:ram2[(direccion-$122000) shr 1]:=valor;
    $130000..$130fff:sprite_ram[(direccion and $fff) shr 1]:=valor;
    $140000..$141fff:if buffer_paleta[(direccion and $1fff) shr 1]<>valor then begin
                          buffer_paleta[(direccion and $1fff) shr 1]:=valor;
                          cambiar_color(valor,((direccion and $1fff) shr 1));
                     end;
    $150000:main_screen.flip_main_screen:=(valor and 1)<>0;
	  $150010:begin
              sound_latch:=valor;
              z80_0.change_nmi(ASSERT_LINE);
           end;
    $150020:m68000_0.irq[5]:=CLEAR_LINE;
    $150030:;
    $160000:scroll_x_txt:=valor;
	  $160006:scroll_y_txt:=valor;
	  $16000c:scroll_x_fg:=valor;
	  $160012:scroll_y_fg:=valor;
	  $160018:scroll_x_bg:=valor;
	  $16001e:scroll_y_bg:=valor;
  end;
end;

function finalstarforce_snd_getbyte(direccion:word):byte;
begin
  case direccion of
    0..$fbff:finalstarforce_snd_getbyte:=mem_snd[direccion];
    $fc00:finalstarforce_snd_getbyte:=oki_6295_0.read;
    $fc05:finalstarforce_snd_getbyte:=ym2151_0.status;
    $fc08:begin
            finalstarforce_snd_getbyte:=sound_latch;
            z80_0.change_nmi(CLEAR_LINE);
          end;
  end;
end;

procedure finalstarforce_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$efff:;
  $f000..$fbff:mem_snd[direccion]:=valor;
  $fc00:oki_6295_0.write(valor);
  $fc04:ym2151_0.reg(valor);
  $fc05:ym2151_0.write(valor);
end;
end;

procedure finalstarforce_sound_update;
begin
  ym2151_0.update;
  oki_6295_0.update;
end;

procedure finalstarforce_snd_irq(irqstate:byte);
begin
  z80_0.change_irq(irqstate);
end;

//Main
procedure reset_finalstarforce;
begin
 m68000_0.reset;
 z80_0.reset;
 ym2151_0.reset;
 oki_6295_0.reset;
 reset_video;
 reset_audio;
 marcade.in0:=$3fff;
 scroll_x_txt:=0;
 scroll_y_txt:=0;
 scroll_x_bg:=0;
 scroll_y_bg:=0;
 scroll_x_fg:=0;
 scroll_y_fg:=0;
 sound_latch:=0;
end;

function iniciar_finalstarforce:boolean;
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
llamadas_maquina.bucle_general:=finalstarforce_principal;
llamadas_maquina.reset:=reset_finalstarforce;
llamadas_maquina.fps_max:=59.17;
iniciar_finalstarforce:=false;
iniciar_audio(true);
screen_init(1,512,256,true);
screen_mod_scroll(1,512,256,511,256,256,255);
screen_init(2,512,512,true);
screen_mod_scroll(2,512,256,511,512,256,511);
screen_init(3,512,512,true);
screen_mod_scroll(3,512,256,511,512,256,511);
main_screen.rot90_screen:=true;
screen_init(4,512,512,false,true);
iniciar_video(256,224);
//Main CPU
m68000_0:=cpu_m68000.create(24000000 div 2,256);
//Sound CPU
z80_0:=cpu_z80.create(24000000 div 6,256);
z80_0.change_ram_calls(finalstarforce_snd_getbyte,finalstarforce_snd_putbyte);
z80_0.init_sound(finalstarforce_sound_update);
//Sound Chips
ym2151_0:=ym2151_chip.create(4000000);
ym2151_0.change_irq_func(finalstarforce_snd_irq);
oki_6295_0:=snd_okim6295.create(1000000,OKIM6295_PIN7_HIGH,0.7);
getmem(ptemp,$100000);
case main_vars.tipo_maquina of
  406:begin //Final Star Force
      //cargar roms
      if not(roms_load16w(@rom,finalstarforce_rom)) then exit;
      m68000_0.change_ram16_calls(finalstarforce_getword,finalstarforce_putword);
      //cargar sonido
      if not(roms_load(@mem_snd,finalstarforce_sound)) then exit;
      if not(roms_load(oki_6295_0.get_rom_addr,finalstarforce_oki)) then exit;
      //convertir chars
      if not(roms_load(ptemp,finalstarforce_char)) then exit;
      convert_8($1000,0);
      //convertir fondo
      if not(roms_load16b(ptemp,finalstarforce_bg)) then exit;
      convert_16($2000,1);
      //convertir sprites
      if not(roms_load16b(ptemp,finalstarforce_sprites)) then exit;
      convert_8($8000,3);
      //DIP
      marcade.dswa:=$ff;
      marcade.dswa_val2:=@finalstarforce_dip_a;
      marcade.dswb:=$ff;
      marcade.dswb_val2:=@finalstarforce_dip_b;
  end;
end;
freemem(ptemp);
//final
reset_finalstarforce;
iniciar_finalstarforce:=true;
end;

end.
