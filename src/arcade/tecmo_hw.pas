unit tecmo_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,gfx_engine,msm5205,ym_3812,rom_engine,
     pal_engine,sound_engine;

function iniciar_tecmo:boolean;

implementation
const
        //Rygar
        rygar_rom:array[0..2] of tipo_roms=(
        (n:'5.5p';l:$8000;p:0;crc:$062cd55d),(n:'cpu_5m.bin';l:$4000;p:$8000;crc:$7ac5191b),
        (n:'cpu_5j.bin';l:$8000;p:$10000;crc:$ed76d606));
        rygar_char:tipo_roms=(n:'cpu_8k.bin';l:$8000;p:0;crc:$4d482fb6);
        rygar_tiles1:array[0..3] of tipo_roms=(
        (n:'vid_6p.bin';l:$8000;p:0;crc:$9eae5f8e),(n:'vid_6o.bin';l:$8000;p:$8000;crc:$5a10a396),
        (n:'vid_6n.bin';l:$8000;p:$10000;crc:$7b12cf3f),(n:'vid_6l.bin';l:$8000;p:$18000;crc:$3cea7eaa));
        rygar_tiles2:array[0..3] of tipo_roms=(
        (n:'vid_6f.bin';l:$8000;p:0;crc:$9840edd8),(n:'vid_6e.bin';l:$8000;p:$8000;crc:$ff65e074),
        (n:'vid_6c.bin';l:$8000;p:$10000;crc:$89868c85),(n:'vid_6b.bin';l:$8000;p:$18000;crc:$35389a7b));
        rygar_adpcm:tipo_roms=(n:'cpu_1f.bin';l:$4000;p:0;crc:$3cc98c5a);
        rygar_sound:tipo_roms=(n:'cpu_4h.bin';l:$2000;p:0;crc:$e4a2fa87);
        rygar_sprites:array[0..3] of tipo_roms=(
        (n:'vid_6k.bin';l:$8000;p:0;crc:$aba6db9e),(n:'vid_6j.bin';l:$8000;p:$8000;crc:$ae1f2ed6),
        (n:'vid_6h.bin';l:$8000;p:$10000;crc:$46d9e7df),(n:'vid_6g.bin';l:$8000;p:$18000;crc:$45839c9a));
        //Silkworm
        sw_rom:array[0..1] of tipo_roms=(
        (n:'silkworm.4';l:$10000;p:0;crc:$a5277cce),(n:'silkworm.5';l:$10000;p:$10000;crc:$a6c7bb51));
        sw_char:tipo_roms=(n:'silkworm.2';l:$8000;p:0;crc:$e80a1cd9);
        sw_tiles1:array[0..3] of tipo_roms=(
        (n:'silkworm.10';l:$10000;p:0;crc:$8c7138bb),(n:'silkworm.11';l:$10000;p:$10000;crc:$6c03c476),
        (n:'silkworm.12';l:$10000;p:$20000;crc:$bb0f568f),(n:'silkworm.13';l:$10000;p:$30000;crc:$773ad0a4));
        sw_tiles2:array[0..3] of tipo_roms=(
        (n:'silkworm.14';l:$10000;p:0;crc:$409df64b),(n:'silkworm.15';l:$10000;p:$10000;crc:$6e4052c9),
        (n:'silkworm.16';l:$10000;p:$20000;crc:$9292ed63),(n:'silkworm.17';l:$10000;p:$30000;crc:$3fa4563d));
        sw_adpcm:tipo_roms=(n:'silkworm.1';l:$8000;p:0;crc:$5b553644);
        sw_sound:tipo_roms=(n:'silkworm.3';l:$8000;p:0;crc:$b589f587);
        sw_sprites:array[0..3] of tipo_roms=(
        (n:'silkworm.6';l:$10000;p:0;crc:$1138d159),(n:'silkworm.7';l:$10000;p:$10000;crc:$d96214f7),
        (n:'silkworm.8';l:$10000;p:$20000;crc:$0494b38e),(n:'silkworm.9';l:$10000;p:$30000;crc:$8ce3cdf5));
        //Dip
        rygar_dip_a:array [0..3] of def_dip2=(
        (mask:3;name:'Coin A';number:4;val4:(1,0,2,3);name4:('2C 1C','1C 1C','1C 2C','1C 3C')),
        (mask:$c;name:'Coin B';number:4;val4:(4,0,8,$c);name4:('2C 1C','1C 1C','1C 2C','1C 3C')),
        (mask:$30;name:'Lives';number:4;val4:($30,0,$10,$20);name4:('2','3','4','5')),
        (mask:$40;name:'Cabinet';number:2;val2:($40,0);name2:('Upright','Cocktail')));
        rygar_dip_b:array [0..3] of def_dip2=(
        (mask:3;name:'Bonus Life';number:4;val4:(0,1,2,3);name4:('50K 200K 500K','100K 300K 600K','200K 500K','100K')),
        (mask:$30;name:'Difficulty';number:4;val4:(0,$10,$20,$30);name4:('Easy','Normal','Hard','Hardest')),
        (mask:$40;name:'2P Can Start Anytime';number:2;val2:($40,0);name2:('Yes','No')),
        (mask:$80;name:'Allow Continue';number:2;val2:($80,0);name2:('Yes','No')));
        sw_dip_a:array [0..3] of def_dip2=(
        (mask:3;name:'Coin A';number:4;val4:(1,0,2,3);name4:('2C 1C','1C 1C','1C 2C','1C 3C')),
        (mask:$c;name:'Coin B';number:4;val4:(4,0,8,$c);name4:('2C 1C','1C 1C','1C 2C','1C 3C')),
        (mask:$30;name:'Lives';number:4;val4:($30,0,$10,$20);name4:('2','3','4','5')),
        (mask:$80;name:'Demo Sounds';number:2;val2:($80,0);name2:('On','Off')));
        sw_dip_b:array [0..2] of def_dip2=(
        (mask:7;name:'Bonus Life';number:8;val8:(0,1,2,3,4,5,6,7);name8:('50K 200K 500K','100K 300K 800K','50K 200K','100K 300K','50K','100K','200K','None')),
        (mask:$70;name:'Difficulty';number:8;val8:($10,$20,$30,$40,$50,$60,$70,0);name8:('1','2','3','4','5','Invalid','Invalid','Invalid')),
        (mask:$80;name:'Allow Continue';number:2;val2:($80,0);name2:('No','Yes')));

var
 bank_rom:array[0..$1f,0..$7ff] of byte;
 scroll_x1,scroll_x2:word;
 nbank_rom,scroll_y1,scroll_y2,soundlatch,tipo_video:byte;
 bg_ram,fg_ram:array[0..$3ff] of byte;
 txt_ram:array[0..$7ff] of byte;

procedure update_video_tecmo;
var
  f,color,nchar,x,y:word;
  atrib:byte;
procedure draw_sprites(prioridad:byte);
const
  layout:array[0..7,0..7] of byte = (
		(0,1,4,5,16,17,20,21),
		(2,3,6,7,18,19,22,23),
		(8,9,12,13,24,25,28,29),
		(10,11,14,15,26,27,30,31),
		(32,33,36,37,48,49,52,53),
		(34,35,38,39,50,51,54,55),
		(40,41,44,45,56,57,60,61),
		(42,43,46,47,58,59,62,63));
var
  nchar,dx,dy,sx,sy,x,y,f,color,size:word;
  flags,bank:byte;
  flipx,flipy:boolean;
begin
for f:=0 to $ff do begin
 flags:=memoria[$e003+(f*8)];
 if prioridad=(flags shr 6) then begin
  bank:=memoria[$e000+(f*8)];
  if (bank and 4)<>0 then begin //sprite visible
    if tipo_video=1 then nchar:=memoria[$e001+(f*8)]+((bank and $f8) shl 5)
      else nchar:=memoria[$e001+(f*8)]+((bank and $f0) shl 4);
    size:=memoria[$e002+(f*8)] and 3;
    nchar:=nchar and (not((1 shl (size*2))-1));
    size:=1 shl size;
    dx:=memoria[$e005+(f*8)]-((flags and $10) shl 4);
    dy:=memoria[$e004+(f*8)]-((flags and $20) shl 3);
    color:=(flags and $f) shl 4;
    flipx:=(bank and 1)<>0;
    flipy:=(bank and 2)<>0;
    for y:=0 to (size-1) do begin
				for x:=0 to (size-1) do begin
          if flipx then sx:=dx+8*(size-1-x)
              else sx:=dx+8*x;
          if flipy then sy:=dy+8*(size-1-y)
              else sy:=dy+8*y;
          put_gfx_sprite(nchar+layout[y,x],color,flipx,flipy,2);
          actualiza_gfx_sprite(sx+48,sy,1,2);
        end;
    end;
  end;
 end;
end;
end;
begin
//chars
for f:=0 to $3ff do begin
  atrib:=txt_ram[$400+f];
  color:=atrib shr 4;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
      x:=f mod 32;
      y:=f div 32;
      nchar:=txt_ram[f]+((atrib and 3) shl 8);
      put_gfx_trans(x*8,y*8,nchar,(color shl 4)+$100,6,0);
      gfx[0].buffer[f]:=false;
  end;
end;
for f:=0 to $1ff do begin
    //Background
    atrib:=bg_ram[$200+f];
    color:=atrib shr 4;
    if (gfx[3].buffer[f] or buffer_color[color+$20]) then begin
        x:=f mod 32;
        y:=f div 32;
        nchar:=bg_ram[f]+((atrib and 7) shl 8);
        put_gfx_trans(x*16,y*16,nchar,(color shl 4)+$300,2,3);
        gfx[3].buffer[f]:=false;
    end;
    //Delante
    atrib:=fg_ram[$200+f];
    color:=atrib shr 4;
    if (gfx[1].buffer[f] or buffer_color[color+$10]) then begin
        x:=f mod 32;
        y:=f div 32;
        nchar:=fg_ram[f]+((atrib and 7) shl 8);
        put_gfx_trans(x*16,y*16,nchar,(color shl 4)+$200,7,1);
        gfx[1].buffer[f]:=false;
    end;
end;
fill_full_screen(1,$100);
draw_sprites(3);
scroll_x_y(2,1,scroll_x2,scroll_y2);
draw_sprites(2);
scroll_x_y(7,1,scroll_x1,scroll_y1);
draw_sprites(1);
actualiza_trozo(0,0,256,256,6,48,0,256,256,1);
draw_sprites(0);
actualiza_trozo_final(48,16,256,224,1);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
end;

procedure eventos_tecmo;
begin
if event.arcade then begin
  //P1
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 or 1) else marcade.in0:=(marcade.in0 and $fe);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 or 2) else marcade.in0:=(marcade.in0 and $fd);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 or 4) else marcade.in0:=(marcade.in0 and $fb);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 or 8) else marcade.in0:=(marcade.in0 and $f7);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 or 1) else marcade.in1:=(marcade.in1 and $fe);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 or 2) else marcade.in1:=(marcade.in1 and $fd);
  //P2
  if arcade_input.left[1] then marcade.in3:=(marcade.in3 or 1) else marcade.in3:=(marcade.in3 and $fe);
  if arcade_input.right[1] then marcade.in3:=(marcade.in3 or 2) else marcade.in3:=(marcade.in3 and $fd);
  if arcade_input.down[1] then marcade.in3:=(marcade.in3 or 4) else marcade.in3:=(marcade.in3 and $fb);
  if arcade_input.up[1] then marcade.in3:=(marcade.in3 or 8) else marcade.in3:=(marcade.in3 and $f7);
  if arcade_input.but0[1] then marcade.in4:=(marcade.in4 or 1) else marcade.in4:=(marcade.in4 and $fe);
  if arcade_input.but1[1] then marcade.in4:=(marcade.in4 or 2) else marcade.in4:=(marcade.in4 and $fd);
  //SYSTEM
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 or 1) else marcade.in2:=(marcade.in2 and $fe);
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 or 2) else marcade.in2:=(marcade.in2 and $fd);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 or 4) else marcade.in2:=(marcade.in2 and $fb);
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 or 8) else marcade.in2:=(marcade.in2 and $f7);
end;
end;

procedure tecmo_principal;
var
  f:byte;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
  for f:=0 to $ff do begin
    eventos_tecmo;
    if f=240 then begin
      z80_0.change_irq(HOLD_LINE);
      update_video_tecmo;
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

function rygar_getbyte(direccion:word):byte;
begin
case direccion of
  0..$cfff,$e000..$e7ff:rygar_getbyte:=memoria[direccion];
  $d000..$d7ff:rygar_getbyte:=txt_ram[direccion and $7ff];
  $d800..$dbff:rygar_getbyte:=fg_ram[direccion and $3ff];
  $dc00..$dfff:rygar_getbyte:=bg_ram[direccion and $3ff];
  $e800..$efff:rygar_getbyte:=buffer_paleta[direccion and $7ff];
  $f000..$f7ff:rygar_getbyte:=bank_rom[nbank_rom,direccion and $7ff];
  $f800:rygar_getbyte:=marcade.in0;
  $f801:rygar_getbyte:=marcade.in1;
  $f802:rygar_getbyte:=marcade.in3;
  $f803:rygar_getbyte:=marcade.in4;
  $f804:rygar_getbyte:=marcade.in2;
  $f805,$f80f:rygar_getbyte:=0;
  $f806:rygar_getbyte:=marcade.dswa and $f;
  $f807:rygar_getbyte:=(marcade.dswa shr 4) and $f;
  $f808:rygar_getbyte:=marcade.dswb and $f;
  $f809:rygar_getbyte:=(marcade.dswb shr 4) and $f;
end;
end;

procedure cambiar_color(numero:word);
var
  color:tcolor;
  valor:byte;
begin
  valor:=buffer_paleta[numero];
  color.b:=pal4bit(valor);
  valor:=buffer_paleta[1+numero];
  color.g:=pal4bit(valor);
  color.r:=pal4bit(valor shr 4);
  numero:=numero shr 1;
  set_pal_color(color,numero);
  case numero of
    256..511:buffer_color[(numero shr 4) and $f]:=true;
    512..767:buffer_color[((numero shr 4) and $f)+$10]:=true;
    768..1023:buffer_color[((numero shr 4) and $f)+$20]:=true;
  end;
end;

procedure rygar_putbyte(direccion:word;valor:byte);
begin
case direccion of
    0..$bfff,$f000..$f7ff:; //ROM
    $c000..$cfff,$e000..$e7ff:memoria[direccion]:=valor;
    $d000..$d7ff:if txt_ram[direccion and $7ff]<>valor then begin
                    gfx[0].buffer[direccion and $3ff]:=true;
                    txt_ram[direccion and $7ff]:=valor;
                 end;
    $d800..$dbff:if fg_ram[direccion and $3ff]<>valor then begin
                    gfx[1].buffer[direccion and $1ff]:=true;
                    fg_ram[direccion and $3ff]:=valor;
                 end;
    $dc00..$dfff:if bg_ram[direccion and $3ff]<>valor then begin
                    gfx[3].buffer[direccion and $1ff]:=true;
                    bg_ram[direccion and $3ff]:=valor;
                 end;
    $e800..$efff:if buffer_paleta[direccion and $7ff]<>valor then begin
                    buffer_paleta[direccion and $7ff]:=valor;
                    cambiar_color(direccion and $7fe);
                 end;
    $f800:scroll_x1:=(scroll_x1 and $100) or valor;
    $f801:scroll_x1:=(scroll_x1 and $ff) or ((valor and 1) shl 8);
    $f802:scroll_y1:=valor;
    $f803:scroll_x2:=(scroll_x2 and $100) or valor;
    $f804:scroll_x2:=(scroll_x2 and $ff) or ((valor and 1) shl 8);
    $f805:scroll_y2:=valor;
    $f806:begin
            soundlatch:=valor;
            z80_1.change_nmi(ASSERT_LINE);
          end;
    $f807:main_screen.flip_main_screen:=(valor and 1)<>0;
    $f808:nbank_rom:=(valor and $f8) shr 3;
end;
end;

function rygar_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$47ff:rygar_snd_getbyte:=mem_snd[direccion];
  $c000:rygar_snd_getbyte:=soundlatch
end;
end;

procedure rygar_snd_putbyte(direccion:word;valor:byte);
begin
  case direccion of
     0..$3fff:; //ROM
     $4000..$47ff:mem_snd[direccion]:=valor;
     $8000:ym3812_0.control(valor);
     $8001:ym3812_0.write(valor);
     $c000:begin
              msm5205_0.pos:=(valor shl 8);
              msm5205_0.reset_w(false);
           end;
     $d000:msm5205_0.end_:=((valor+1) shl 8);
     //$e000:volumen
     $f000:z80_1.change_nmi(CLEAR_LINE);
  end;
end;

//Silkworm
function sw_getbyte(direccion:word):byte;
begin
case direccion of
  0..$bfff,$d000..$e7ff:sw_getbyte:=memoria[direccion];
  $c000..$c3ff:sw_getbyte:=bg_ram[direccion and $3ff];
  $c400..$c7ff:sw_getbyte:=fg_ram[direccion and $3ff];
  $c800..$cfff:sw_getbyte:=txt_ram[direccion and $7ff];
  $e800..$efff:sw_getbyte:=buffer_paleta[direccion and $7ff];
  $f000..$f7ff:sw_getbyte:=bank_rom[nbank_rom,direccion and $7ff];
  $f800:sw_getbyte:=marcade.in0;
  $f801:sw_getbyte:=marcade.in1;
  $f802:sw_getbyte:=marcade.in3;
  $f803:sw_getbyte:=marcade.in4;
  $f804:sw_getbyte:=0;
  $f806:sw_getbyte:=marcade.dswa and $f;
  $f807:sw_getbyte:=(marcade.dswa shr 4) and $f;
  $f808:sw_getbyte:=marcade.dswb and $f;
  $f809:sw_getbyte:=(marcade.dswb shr 4) and $f;
  $f80f:sw_getbyte:=marcade.in2;
end;
end;

procedure sw_putbyte(direccion:word;valor:byte);
begin
case direccion of
    0..$bfff,$f000..$f7ff:; //ROM
    $c000..$c3ff:if bg_ram[direccion and $3ff]<>valor then begin
                    gfx[3].buffer[direccion and $1ff]:=true;
                    bg_ram[direccion and $3ff]:=valor;
                 end;
    $c400..$c7ff:if fg_ram[direccion and $3ff]<>valor then begin
                    gfx[1].buffer[direccion and $1ff]:=true;
                    fg_ram[direccion and $3ff]:=valor;
                 end;
    $c800..$cfff:if txt_ram[direccion and $7ff]<>valor then begin
                    gfx[0].buffer[direccion and $3ff]:=true;
                    txt_ram[direccion and $7ff]:=valor;
                 end;
    $d000..$e7ff:memoria[direccion]:=valor;
    $e800..$efff:if buffer_paleta[direccion and $7ff]<>valor then begin
                    buffer_paleta[direccion and $7ff]:=valor;
                    cambiar_color(direccion and $7fe);
                 end;
    $f800:scroll_x1:=(scroll_x1 and $100) or valor;
    $f801:scroll_x1:=(scroll_x1 and $ff) or ((valor and 1) shl 8);
    $f802:scroll_y1:=valor;
    $f803:scroll_x2:=(scroll_x2 and $100) or valor;
    $f804:scroll_x2:=(scroll_x2 and $ff) or ((valor and 1) shl 8);
    $f805:scroll_y2:=valor;
    $f806:begin
            soundlatch:=valor;
            z80_1.change_nmi(ASSERT_LINE);
          end;
    $f807:main_screen.flip_main_screen:=(valor and 1)<>0;
    $f808:nbank_rom:=(valor and $f8) shr 3;
end;
end;

function sw_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$87ff:sw_snd_getbyte:=mem_snd[direccion];
  $c000:sw_snd_getbyte:=soundlatch
end;
end;

procedure sw_snd_putbyte(direccion:word;valor:byte);
begin
  case direccion of
     0..$7fff:; //ROM
     $8000..$87ff:mem_snd[direccion]:=valor;
     $a000:ym3812_0.control(valor);
     $a001:ym3812_0.write(valor);
     $c000:begin
              msm5205_0.pos:=(valor shl 8);
              msm5205_0.reset_w(false);
           end;
     $c400:msm5205_0.end_:=((valor+1) shl 8);
     //$c800:volumen
     $cc00:z80_1.change_nmi(CLEAR_LINE);
  end;
end;

procedure snd_irq(irqstate:byte);
begin
  z80_1.change_irq(irqstate);
end;

procedure snd_sound_play;
begin
  ym3812_0.update;
  msm5205_0.update;
end;

//Main
procedure reset_tecmo;
begin
 z80_0.reset;
 z80_1.reset;
 frame_main:=z80_0.tframes;
 frame_snd:=z80_1.tframes;
 ym3812_0.reset;
 msm5205_0.reset;
 marcade.in0:=0;
 marcade.in1:=0;
 marcade.in2:=0;
 marcade.in3:=0;
 marcade.in4:=0;
 nbank_rom:=0;
 scroll_x1:=0;
 scroll_x2:=0;
 scroll_y1:=0;
 scroll_y2:=0;
 soundlatch:=0;
end;

function iniciar_tecmo:boolean;
const
  ps_x:array[0..15] of dword=(0*4, 1*4, 2*4, 3*4, 4*4, 5*4, 6*4, 7*4,
			32*8+0*4, 32*8+1*4, 32*8+2*4, 32*8+3*4, 32*8+4*4, 32*8+5*4, 32*8+6*4, 32*8+7*4);
  ps_y:array[0..15] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32,
			16*32, 17*32, 18*32, 19*32, 20*32, 21*32, 22*32, 23*32);
var
  memoria_temp:array[0..$7ffff] of byte;
  f:byte;

procedure char_convert(num:word);
begin
  init_gfx(0,8,8,num);
  gfx[0].trans[0]:=true;
  gfx_set_desc_data(4,0,32*8,0,1,2,3);
  convert_gfx(0,0,@memoria_temp,@ps_x,@ps_y,false,false);
end;

procedure sprite_convert(num:word);
begin
  init_gfx(2,8,8,num);
  gfx[2].trans[0]:=true;
  gfx_set_desc_data(4,0,32*8,0,1,2,3);
  convert_gfx(2,0,@memoria_temp,@ps_x,@ps_y,false,false);
end;

procedure tile_convert(ngfx:byte;num:word);
begin
  init_gfx(ngfx,16,16,num);
  gfx[ngfx].trans[0]:=true;
  gfx_set_desc_data(4,0,128*8,0,1,2,3);
  convert_gfx(ngfx,0,@memoria_temp,@ps_x,@ps_y,false,false);
end;

begin
llamadas_maquina.bucle_general:=tecmo_principal;
llamadas_maquina.reset:=reset_tecmo;
llamadas_maquina.fps_max:=59.185608;
llamadas_maquina.scanlines:=256;
iniciar_tecmo:=false;
iniciar_audio(false);
screen_init(1,512,512,false,true);
screen_init(2,512,256,true);
screen_init(6,256,256,true); //chars
//foreground
screen_init(7,512,256,true);
iniciar_video(256,224);
//Sound CPU
z80_1:=cpu_z80.create(4000000);
z80_1.init_sound(snd_sound_play);
//Sound Chip
if main_vars.tipo_maquina=26 then ym3812_0:=ym3812_chip.create(YM3526_FM,4000000)
  else ym3812_0:=ym3812_chip.create(YM3812_FM,4000000);
ym3812_0.change_irq_calls(snd_irq);
msm5205_0:=MSM5205_chip.create(400000,MSM5205_S48_4B,0.5,$8000);
//cargar roms
case main_vars.tipo_maquina of
  26:begin
      //Main
      z80_0:=cpu_z80.create(6000000);
      z80_0.change_ram_calls(rygar_getbyte,rygar_putbyte);
      if not(roms_load(@memoria_temp,rygar_rom)) then exit;
      copymemory(@memoria,@memoria_temp,$c000);
      for f:=0 to $1f do copymemory(@bank_rom[f,0],@memoria_temp[$10000+(f*$800)],$800);
      //Sound
      z80_1.change_ram_calls(rygar_snd_getbyte,rygar_snd_putbyte);
      if not(roms_load(@mem_snd,rygar_sound)) then exit;
      if not(roms_load(msm5205_0.rom_data,rygar_adpcm)) then exit;
      //Video
      tipo_video:=0;
      //convertir chars
      if not(roms_load(@memoria_temp,rygar_char)) then exit;
      char_convert(1024);
      //Sprites
      if not(roms_load(@memoria_temp,rygar_sprites)) then exit;
      sprite_convert(4096);
      //foreground
      if not(roms_load(@memoria_temp,rygar_tiles1)) then exit;
      tile_convert(1,$400);
      //background
      if not(roms_load(@memoria_temp,rygar_tiles2)) then exit;
      tile_convert(3,$400);
      //DIP
      init_dips(1,rygar_dip_a,$40);
      init_dips(2,rygar_dip_b,$80);
  end;
  97:begin  //Silk Worm
      //Main
      z80_0:=cpu_z80.create(8000000);
      z80_0.change_ram_calls(sw_getbyte,sw_putbyte);
      if not(roms_load(@memoria_temp,sw_rom)) then exit;
      copymemory(@memoria,@memoria_temp,$10000);
      for f:=0 to $1f do copymemory(@bank_rom[f,0],@memoria_temp[$10000+(f*$800)],$800);
      //Sound
      z80_1.change_ram_calls(sw_snd_getbyte,sw_snd_putbyte);
      if not(roms_load(@mem_snd,sw_sound)) then exit;
      if not(roms_load(msm5205_0.rom_data,sw_adpcm)) then exit;
      //Video
      tipo_video:=1;
      //cargar sonido
      if not(roms_load(@memoria_temp,sw_char)) then exit;
      char_convert($400);
      //Sprites
      if not(roms_load(@memoria_temp,sw_sprites)) then exit;
      sprite_convert($2000);
      //background
      if not(roms_load(@memoria_temp,sw_tiles1)) then exit;
      tile_convert(1,$800);
      //foreground
      if not(roms_load(@memoria_temp,sw_tiles2)) then exit;
      tile_convert(3,$800);
      //DIP
      init_dips(1,sw_dip_a,$80);
      init_dips(2,sw_dip_b,$30);
     end;
end;
iniciar_tecmo:=true;
end;

end.
