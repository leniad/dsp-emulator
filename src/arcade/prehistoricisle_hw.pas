unit prehistoricisle_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m68000,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     ym_3812,nz80,upd7759,sound_engine;

function iniciar_prehisle:boolean;

implementation
const
        prehisle_rom:array[0..1] of tipo_roms=(
        (n:'gt-e2.2h';l:$20000;p:0;crc:$7083245a),(n:'gt-e3.3h';l:$20000;p:1;crc:$6d8cdf58));
        prehisle_char:tipo_roms=(n:'gt15.b15';l:$8000;p:0;crc:$ac652412);
        prehisle_fondo_rom:tipo_roms=(n:'gt.11';l:$10000;p:0;crc:$b4f0fcf0);
        prehisle_fondo1:tipo_roms=(n:'pi8914.b14';l:$40000;p:0;crc:$207d6187);
        prehisle_fondo2:tipo_roms=(n:'pi8916.h16';l:$40000;p:0;crc:$7cffe0f6);
        prehisle_sound:tipo_roms=(n:'gt1.1';l:$10000;p:0;crc:$80a4c093);
        prehisle_upd:tipo_roms=(n:'gt4.4';l:$20000;p:0;crc:$85dfb9ec);
        prehisle_sprites:array[0..1] of tipo_roms=(
        (n:'pi8910.k14';l:$80000;p:0;crc:$5a101b0b),(n:'gt.5';l:$20000;p:$80000;crc:$3d3ab273));
        //Dip
        prehisle_dip_a:array [0..4] of def_dip2=(
        (mask:1;name:'Flip Screen';number:2;val2:(1,0);name2:('Off','On')),
        (mask:2;name:'Level Select';number:2;val2:(2,0);name2:('Off','On')),
        (mask:4;name:'Bonus Life';number:2;val2:(4,0);name2:('Only Twice','Allways')),
        (mask:$30;name:'Coinage';number:4;val4:(0,$10,$20,$30);name4:('A 4C/1C B 1C/4C','A 3C/1C B 1C/3C','A 2C/1C B 1C/2C','1C 1C')),
        (mask:$c0;name:'Lives';number:4;val4:($80,$c0,$40,0);name4:('2','3','4','5')));
        prehisle_dip_b:array [0..3] of def_dip2=(
        (mask:3;name:'Difficulty';number:4;val4:(2,3,1,0);name4:('Easy','Standard','Middle','Difficult')),
        (mask:$c;name:'Game Mode';number:4;val4:(8,$c,0,4);name4:('Demo Sounds Off','Demo Sounds On','Freeze','Infinite Lives')),
        (mask:$30;name:'Bonus Life';number:4;val4:($30,$20,$10,0);name4:('100K 200K','150K 300K','300K 500K','None')),
        (mask:$40;name:'Allow Continue';number:2;val2:(0,$40);name2:('No','Yes')));

var
 rom:array[0..$1ffff] of word;
 ram,back_ram:array[0..$1fff] of word;
 fondo_rom:array[0..$7fff] of word;
 video_ram:array[0..$3ff] of word;
 invert_controls,sound_latch:byte;
 scroll_x1,scroll_y1,scroll_x2,scroll_y2:word;

procedure update_video_prehisle;

procedure poner_sprites(prioridad:boolean);
var
  atrib,nchar,color,x,y:word;
  f:byte;
begin
for f:=0 to $ff do begin
    color:=buffer_sprites_w[(f*4)+3] shr 12;
    if (color<4)<>prioridad then continue;
		atrib:=buffer_sprites_w[(f*4)+2];
		nchar:=(atrib and $1fff) mod $1400;
		x:=buffer_sprites_w[(f*4)+1];
		y:=buffer_sprites_w[f*4];
    put_gfx_sprite(nchar,256+(color shl 4),(atrib and $4000)<>0,(atrib and $8000)<>0,1);
    actualiza_gfx_sprite(x,y,1,1);
end;
end;

var
  f,color,pos,x,y,sx,sy,nchar,atrib:word;
begin
for f:=0 to $120 do begin
  x:=f div 17;
  y:=f mod 17;
  //background
  sx:=x+((scroll_x1 and $3ff0) shr 4);
  sy:=y+((scroll_y1 and $1f0) shr 4);
  pos:=(sy and $1f)+((sx and $3ff) shl 5);
  atrib:=fondo_rom[pos];
  color:=atrib shr 12;
  if (gfx[2].buffer[pos] or buffer_color[color+$10]) then begin
    nchar:=atrib and $7ff;
    put_gfx_flip(x*16,y*16,nchar,(color shl 4)+768,4,2,(atrib and $800)<>0,false);
    gfx[2].buffer[pos]:=false;
  end;
  //background 2
  sx:=x+((scroll_x2 and $ff0) shr 4);
  sy:=y+((scroll_y2 and $1f0) shr 4);
  pos:=(sy and $1f)+((sx and $ff) shl 5);
  atrib:=back_ram[pos];
  color:=atrib shr 12;
  if (gfx[3].buffer[pos] or buffer_color[color+$20]) then begin
    nchar:=atrib and $7ff;
    put_gfx_trans_flip(x*16,y*16,nchar,(color shl 4)+512,5,3,false,(atrib and $800)<>0);
    gfx[3].buffer[pos]:=false;
  end;
end;
//foreground
for f:=0 to $3ff do begin
  atrib:=video_ram[f];
  color:=atrib shr 12;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
    x:=f mod 32;
    y:=f div 32;
    nchar:=atrib and $3ff;
    put_gfx_trans(x*8,y*8,nchar,color shl 4,2,0);
    gfx[0].buffer[f]:=false;
  end;
end;
//Mix
scroll_x_y(4,1,scroll_x1 and $f,scroll_y1 and $f);
poner_sprites(false);
scroll_x_y(5,1,scroll_x2 and $f,scroll_y2 and $f);
poner_sprites(true);
actualiza_trozo(0,0,256,256,2,0,0,256,256,1);
actualiza_trozo_final(0,16,256,224,1);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure eventos_prehisle;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.but2[0] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  //P2
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or 8);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.but2[1] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
  //COIN
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or 1);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or 2);
end;
end;

procedure prehisle_principal;
var
  f:word;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
 for f:=0 to 263 do begin
   case f of
    16:marcade.dswb:=marcade.dswb or $80;
    240:begin
          marcade.dswb:=marcade.dswb and $7f;
          m68000_0.irq[4]:=HOLD_LINE;
          update_video_prehisle;
        end;
   end;
   m68000_0.run(frame_main);
   frame_main:=frame_main+m68000_0.tframes-m68000_0.contador;
   z80_0.run(frame_snd);
   frame_snd:=frame_snd+z80_0.tframes-z80_0.contador;
 end;
 eventos_prehisle;
 video_sync;
end;
end;

function prehisle_getword(direccion:dword):word;
begin
case direccion of
  0..$3ffff:prehisle_getword:=rom[direccion shr 1];
  $70000..$73fff:prehisle_getword:=ram[(direccion and $3fff) shr 1];
  $90000..$907ff:prehisle_getword:=video_ram[(direccion and $7ff) shr 1];
  $a0000..$a07ff:prehisle_getword:=buffer_sprites_w[(direccion and $7ff) shr 1];
  $b0000..$b3fff:prehisle_getword:=back_ram[(direccion and $3fff) shr 1];
  $d0000..$d07ff:prehisle_getword:=buffer_paleta[(direccion and $7ff) shr 1];
  $e0010:prehisle_getword:=marcade.in1;
  $e0020:prehisle_getword:=marcade.in2;
  $e0040:prehisle_getword:=marcade.in0 xor invert_controls;
  $e0042:prehisle_getword:=marcade.dswa;
  $e0044:prehisle_getword:=marcade.dswb;
end;
end;

procedure prehisle_putword(direccion:dword;valor:word);

procedure cambiar_color(tmp_color,numero:word);
var
  color:tcolor;
begin
  color.r:=pal4bit(tmp_color shr 12);
  color.g:=pal4bit(tmp_color shr 8);
  color.b:=pal4bit(tmp_color shr 4);
  set_pal_color(color,numero);
  case numero of
    0..255:buffer_color[numero shr 4]:=true;
    512..767:buffer_color[((numero shr 4) and $f)+$20]:=true;
    768..1023:buffer_color[((numero shr 4) and $f)+$10]:=true;
  end;
end;

begin
case direccion of
    0..$3ffff:; //ROM
    $70000..$73fff:ram[(direccion and $3fff) shr 1]:=valor;
    $90000..$907ff:if video_ram[(direccion and $7ff) shr 1]<>valor then begin
                      video_ram[(direccion and $7ff) shr 1]:=valor;
                      gfx[0].buffer[(direccion and $7ff) shr 1]:=true;
                   end;
    $a0000..$a07ff:buffer_sprites_w[(direccion and $7ff) shr 1]:=valor;
    $b0000..$b3fff:if back_ram[(direccion and $3fff) shr 1]<>valor then begin
                      back_ram[(direccion and $3fff) shr 1]:=valor;
                      gfx[3].buffer[(direccion and $3fff) shr 1]:=true;
                   end;
    $d0000..$d07ff:if buffer_paleta[(direccion and $7ff) shr 1]<>valor then begin
                        buffer_paleta[(direccion and $7ff) shr 1]:=valor;
                        cambiar_color(valor,(direccion and $7ff) shr 1);
                   end;
    $f0000:if scroll_y2<>(valor and $1ff) then begin
              if abs((scroll_y2 and $1f0)-(valor and $1f0))>15 then fillchar(gfx[3].buffer[0],$2000,1);
              scroll_y2:=(valor and $1ff);
           end;
    $f0010:if scroll_x2<>(valor and $fff) then begin
              if abs((scroll_x2 and $ff0)-(valor and $ff0))>15 then fillchar(gfx[3].buffer[0],$2000,1);
              scroll_x2:=(valor and $fff);
           end;
    $f0020:if scroll_y1<>(valor and $1ff) then begin
              if abs((scroll_y1 and $1f0)-(valor and $1f0))>15 then fillchar(gfx[2].buffer[0],$8000,1);
              scroll_y1:=(valor and $1ff);
           end;
    $f0030:if scroll_x1<>(valor and $3fff) then begin
              if abs((scroll_x1 and $3ff0)-(valor and $3ff0))>15 then fillchar(gfx[2].buffer[0],$8000,1);
              scroll_x1:=(valor and $3fff);
           end;
    $f0046:if valor<>0 then invert_controls:=$ff
              else invert_controls:=0;
    $f0060:main_screen.flip_main_screen:=(valor and 1)<>0;
    $f0031..$f0045,$f0047..$f005f,$f0061..$f0069:;
    $f0070:begin
              sound_latch:=valor and $ff;
              z80_0.change_nmi(PULSE_LINE);
           end;
end;
end;

function prehisle_snd_getbyte(direccion:word):byte;
begin
if direccion=$f800 then prehisle_snd_getbyte:=sound_latch
  else prehisle_snd_getbyte:=mem_snd[direccion];
end;

procedure prehisle_snd_putbyte(direccion:word;valor:byte);
begin
if direccion>$efff then mem_snd[direccion]:=valor;
end;

function prehisle_snd_inbyte(puerto:word):byte;
begin
if (puerto and $ff)=0 then prehisle_snd_inbyte:=ym3812_0.status;
end;

procedure prehisle_snd_outbyte(puerto:word;valor:byte);
begin
case (puerto and $ff) of
  0:ym3812_0.control(valor);
  $20:ym3812_0.write(valor);
  $40:begin
        upd7759_0.port_w(valor);
      	upd7759_0.start_w(0);
      	upd7759_0.start_w(1);
      end;
  $80:upd7759_0.reset_w(valor and $80);
end;
end;

procedure prehisle_sound_update;
begin
  ym3812_0.update;
  upd7759_0.update;
end;

procedure snd_irq(irqstate:byte);
begin
  z80_0.change_irq(irqstate);
end;

//Main
procedure reset_prehisle;
begin
 m68000_0.reset;
 z80_0.reset;
 frame_main:=m68000_0.tframes;
 frame_snd:=z80_0.tframes;
 ym3812_0.reset;
 upd7759_0.reset;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$7f;
 invert_controls:=0;
 scroll_x1:=0;
 scroll_y1:=0;
 scroll_x2:=0;
 scroll_y2:=0;
 sound_latch:=0;
end;

function iniciar_prehisle:boolean;
const
  ps_x:array[0..15] of dword=(0,4,8,12,16,20,24,28,
		0+64*8,4+64*8,8+64*8,12+64*8,16+64*8,20+64*8,24+64*8,28+64*8);
  ps_y:array[0..15] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32,
		8*32, 9*32, 10*32, 11*32, 12*32, 13*32, 14*32, 15*32 );
var
  memoria_temp:pbyte;
  f:word;
begin
llamadas_maquina.bucle_general:=prehisle_principal;
llamadas_maquina.reset:=reset_prehisle;
llamadas_maquina.fps_max:=59.185606;
llamadas_maquina.scanlines:=264;
iniciar_prehisle:=false;
iniciar_audio(false);
screen_init(1,512,512,false,true);
screen_init(2,256,256,true);
screen_init(4,272,272); //BG2
screen_init(5,272,272,true); //BG0
iniciar_video(256,224);
//Main CPU
getmem(memoria_temp,$100000);
m68000_0:=cpu_m68000.create(9000000);
m68000_0.change_ram16_calls(prehisle_getword,prehisle_putword);
if not(roms_load16w(@rom,prehisle_rom)) then exit;
//Sound CPU
z80_0:=cpu_z80.create(4000000);
z80_0.change_ram_calls(prehisle_snd_getbyte,prehisle_snd_putbyte);
z80_0.change_io_calls(prehisle_snd_inbyte,prehisle_snd_outbyte);
z80_0.init_sound(prehisle_sound_update);
if not(roms_load(@mem_snd,prehisle_sound)) then exit;
//Sound Chips
ym3812_0:=ym3812_chip.create(YM3812_FM,4000000);
ym3812_0.change_irq_calls(snd_irq);
upd7759_0:=upd7759_chip.create(0.9);
if not(roms_load(upd7759_0.get_rom_addr,prehisle_upd)) then exit;
//convertir chars
if not(roms_load(memoria_temp,prehisle_char)) then exit;
init_gfx(0,8,8,1024);
gfx_set_desc_data(4,0,32*8,0,1,2,3);
convert_gfx(0,0,memoria_temp,@ps_x,@ps_y,false,false);
gfx[0].trans[15]:=true;
//sprites
if not(roms_load(memoria_temp,prehisle_sprites)) then exit;
init_gfx(1,16,16,$1400);
gfx[1].trans[15]:=true;
gfx_set_desc_data(4,0,128*8,0,1,2,3);
convert_gfx(1,0,memoria_temp,@ps_x,@ps_y,false,false);
//fondo 1
if not(roms_load(memoria_temp,prehisle_fondo_rom)) then exit;
//Lo transformo en word...
for f:=0 to $7fff do fondo_rom[f]:=(memoria_temp[f*2] shl 8)+memoria_temp[(f*2)+1];
if not(roms_load(memoria_temp,prehisle_fondo1)) then exit;
init_gfx(2,16,16,$800);
gfx_set_desc_data(4,0,128*8,0,1,2,3);
convert_gfx(2,0,memoria_temp,@ps_x,@ps_y,false,false);
//fondo2
if not(roms_load(memoria_temp,prehisle_fondo2)) then exit;
init_gfx(3,16,16,$800);
gfx[3].trans[15]:=true;
gfx_set_desc_data(4,0,128*8,0,1,2,3);
convert_gfx(3,0,memoria_temp,@ps_x,@ps_y,false,false);
//DIP
init_dips(1,prehisle_dip_a,$ff);
init_dips(2,prehisle_dip_b,$7f);
//final
freemem(memoria_temp);
reset_prehisle;
iniciar_prehisle:=true;
end;

end.
