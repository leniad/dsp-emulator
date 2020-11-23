unit armedf_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,m68000,main_engine,controls_engine,gfx_engine,rom_engine,ym_3812,
     pal_engine,sound_engine,dac,timer_engine;

procedure cargar_armedf;

implementation
const
        armedf_rom:array[0..5] of tipo_roms=(
        (n:'06.3d';l:$10000;p:0;crc:$0f9015e2),(n:'01.3f';l:$10000;p:$1;crc:$816ff7c5),
        (n:'07.5d';l:$10000;p:$20000;crc:$5b3144a5),(n:'02.4f';l:$10000;p:$20001;crc:$fa10c29d),
        (n:'af_08.rom';l:$10000;p:$40000;crc:$d1d43600),(n:'af_03.rom';l:$10000;p:$40001;crc:$bbe1fe2d));
        armedf_sound:tipo_roms=(n:'af_10.rom';l:$10000;p:0;crc:$c5eacb87);
        armedf_char:tipo_roms=(n:'09.11c';l:$8000;p:0;crc:$5c6993d5);
        armedf_bg:array[0..1] of tipo_roms=(
        (n:'af_14.rom';l:$10000;p:0;crc:$8c5dc5a7),(n:'af_13.rom';l:$10000;p:$10000;crc:$136a58a3));
        armedf_fg:array[0..1] of tipo_roms=(
        (n:'af_04.rom';l:$10000;p:0;crc:$44d3af4f),(n:'af_05.rom';l:$10000;p:$10000;crc:$92076cab));
        armedf_sprites:array[0..1] of tipo_roms=(
        (n:'af_11.rom';l:$20000;p:0;crc:$b46c473c),(n:'af_12.rom';l:$20000;p:$20000;crc:$23cb6bfe));

var
 video_reg,scroll_fg_x,scroll_fg_y,scroll_bg_x,scroll_bg_y:word;
 rom:array[0..$2ffff] of word;
 ram:array[0..$63ff] of word;
 sound_latch:byte;

procedure armedf_put_gfx_sprite(nchar:dword;color:word;flipx,flipy:boolean;ngfx,clut:byte);
var
  x,y,pos_y:byte;
  temp,temp2:pword;
  pos:pbyte;
  punto:word;
  dir_x,dir_y:integer;
begin
pos:=gfx[ngfx].datos;
inc(pos,nchar*16*16);
if flipy then begin
  pos_y:=15;
  dir_y:=-1;
end else begin
  pos_y:=0;
  dir_y:=1;
end;
if flipx then begin
  temp2:=punbuf;
  inc(temp2,15);
  dir_x:=-1;
end else begin
  temp2:=punbuf;
  dir_x:=1;
end;
for y:=0 to 15 do begin
  temp:=temp2;
  for x:=0 to 15 do begin
    punto:=ram[$5800+clut*$10+pos^] and $f;
    if (punto<>15) then temp^:=paleta[punto+color]
      else temp^:=paleta[MAX_COLORES];
    inc(temp,dir_x);
    inc(pos);
  end;
  putpixel_gfx_int(0,pos_y,16,PANT_SPRITES);
  pos_y:=pos_y+dir_y;
end;
end;

procedure draw_sprites(prio:byte);
var
  atrib,f,nchar,sx,sy:word;
  flip_x,flip_y:boolean;
  color,clut,pri:byte;
begin
  for f:=0 to $1ff do begin
    pri:=(buffer_sprites_w[(f*4)+0] and $3000) shr 12;
    if pri<>prio then continue;
		nchar:=buffer_sprites_w[(f*4)+1];
		flip_x:=(nchar and $2000)<>0;
		flip_y:=(nchar and $1000)<>0;
    atrib:=buffer_sprites_w[(f*4)+2];
		color:=(atrib shr 8) and $1f;
		clut:=atrib and $7f;
		sx:=buffer_sprites_w[(f*4)+3];
		sy:=128+240-(buffer_sprites_w[(f*4)+0] and $1ff);
    armedf_put_gfx_sprite(nchar and $7ff,(color shl 4)+$200,flip_x,flip_y,3,clut);
    actualiza_gfx_sprite(sx,sy,5,3);
  end;
end;

procedure update_video_armedf;
var
  f,nchar,atrib:word;
  x,y,color:byte;
begin
if (video_reg and $d00)=0 then fill_full_screen(5,$800);
for f:=0 to $7ff do begin
 x:=f div 32;
 y:=f mod 32;
 atrib:=ram[$4800+f] and $ff;
 color:=atrib shr 4;
 if (gfx[0].buffer[f] or buffer_color[color]) then begin
    nchar:=(ram[$4000+f] and $ff)+((atrib and $3) shl 8);
    color:=color shl 4;
    put_gfx(x*8,y*8,nchar,color,1,0);
    if (atrib and $8)=0 then put_gfx_trans(x*8,y*8,nchar,color,2,0)
      else put_gfx_block_trans(x*8,y*8,2,8,8);
    gfx[0].buffer[f]:=false;
 end;
 atrib:=ram[$3000+f];
 color:=atrib shr 11;
 if (gfx[1].buffer[f] or buffer_color[color+$40]) then begin
    nchar:=atrib and $3ff;
    put_gfx_trans(x*16,y*16,nchar,(color shl 4)+$600,3,1);
    gfx[1].buffer[f]:=false;
 end;
 atrib:=ram[$3800+f];
 color:=atrib shr 11;
 if (gfx[2].buffer[f] or buffer_color[color+$20]) then begin
    nchar:=atrib and $3ff;
    put_gfx_trans(x*16,y*16,nchar,(color shl 4)+$400,4,2);
    gfx[2].buffer[f]:=false;
 end;
end;
if (video_reg and $100)<>0 then actualiza_trozo(0,0,512,256,1,0,0,512,256,5);
if (video_reg and $800)<>0 then scroll_x_y(3,5,scroll_bg_x,scroll_bg_y);
if (video_reg and $200)<>0 then begin
  draw_sprites(0);
  draw_sprites(1);
  draw_sprites(2);
end;
if (video_reg and $400)<>0 then scroll_x_y(4,5,scroll_fg_x,scroll_fg_y);
if (video_reg and $100)<>0 then actualiza_trozo(0,0,512,256,2,0,0,512,256,5);
actualiza_trozo_final(96,8,320,240,5);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
copymemory(@buffer_sprites_w[0],@ram[0],$1000*2);
end;

procedure eventos_armedf;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fffe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fffd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fffb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fff7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ffef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $ffdf) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.but2[0] then marcade.in0:=(marcade.in0 and $ffbf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $feff) else marcade.in0:=(marcade.in0 or $100);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $fdff) else marcade.in0:=(marcade.in0 or $200);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fbff) else marcade.in0:=(marcade.in0 or $400);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $f7ff) else marcade.in0:=(marcade.in0 or $800);
  //P2
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $fffe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $fffd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fffb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $fff7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $ffef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $ffdf) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.but2[1] then marcade.in1:=(marcade.in1 and $ffbf) else marcade.in1:=(marcade.in1 or $40);
end;
end;

procedure armedf_principal;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
frame_s:=z80_0.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to $ff do begin
    //main
    m68000_0.run(frame_m);
    frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
    //sound
    z80_0.run(frame_s);
    frame_s:=frame_s+z80_0.tframes-z80_0.contador;
    case f of
    247:begin
          m68000_0.irq[1]:=ASSERT_LINE;
          update_video_armedf;
        end;
    end;
 end;
 eventos_armedf;
 video_sync;
end;
end;

function armedf_getword(direccion:dword):word;
begin
case direccion of
    0..$5ffff:armedf_getword:=rom[direccion shr 1];
    $60000..$6bfff,$6c008..$6c7ff:armedf_getword:=ram[(direccion-$60000) shr 1];
    $6c000:armedf_getword:=marcade.in0;
    $6c002:armedf_getword:=marcade.in1;
    $6c004:armedf_getword:=marcade.dswa;
    $6c006:armedf_getword:=marcade.dswb;
end;
end;

procedure cambiar_color(pos,data:word);
var
  color:tcolor;
begin
  color.r:=pal4bit(data shr 8);
  color.g:=pal4bit(data shr 4);
  color.b:=pal4bit(data);
  set_pal_color(color,pos);
  case pos of
    0..$1ff:buffer_color[pos shr 4]:=true;//chars
    $400..$5ff:buffer_color[((pos and $1ff) shr 4)+$20]:=true; //fg
    $600..$7ff:buffer_color[((pos and $1ff) shr 4)+$40]:=true; //bg
  end;
end;

procedure armedf_putword(direccion:dword;valor:word);
begin
case direccion of
    0..$5ffff:;
    $60000..$65fff,$6b000..$6c7ff:ram[(direccion-$60000) shr 1]:=valor;
    $66000..$66fff:if ram[(direccion-$60000) shr 1]<>valor then begin
                      ram[(direccion-$60000) shr 1]:=valor;
                      gfx[1].buffer[((direccion-$66000) shr 1) and $7ff]:=true;
                   end;
    $67000..$67fff:if ram[(direccion-$60000) shr 1]<>valor then begin
                      ram[(direccion-$60000) shr 1]:=valor;
                      gfx[2].buffer[((direccion-$67000) shr 1) and $7ff]:=true;
                   end;
    $68000..$69fff:if ram[(direccion-$60000) shr 1]<>valor then begin
                      ram[(direccion-$60000) shr 1]:=valor;
                      gfx[0].buffer[((direccion-$68000) shr 1) and $7ff]:=true;
                   end;
    $6a000..$6afff:begin
                      ram[(direccion-$60000) shr 1]:=valor;
                      cambiar_color((direccion-$6a000) shr 1,valor);
                   end;
    $6d000:video_reg:=valor;
    $6d002:scroll_bg_x:=valor;
    $6d004:scroll_bg_y:=valor;
    $6d006:scroll_fg_x:=valor;
    $6d008:scroll_fg_y:=valor;
    $6d00a:sound_latch:=((valor and $7f) shl 1) or 1;
    $6d00e:m68000_0.irq[1]:=CLEAR_LINE;
end;
end;

function armedf_snd_getbyte(direccion:word):byte;
begin
   armedf_snd_getbyte:=mem_snd[direccion];
end;

procedure armedf_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$f7ff:;
  $f800..$ffff:mem_snd[direccion]:=valor;
end;
end;

function armedf_snd_in(puerto:word):byte;
begin
case (puerto and $ff) of
  4:sound_latch:=0;
  6:armedf_snd_in:=sound_latch;
end;
end;

procedure armedf_snd_out(puerto:word;valor:byte);
begin
case (puerto and $ff) of
  0:ym3812_0.control(valor);
  1:ym3812_0.write(valor);
  2:dac_0.signed_data8_w(valor);
  3:dac_1.signed_data8_w(valor);
end;
end;

procedure armedf_snd_irq;
begin
  z80_0.change_irq(HOLD_LINE);
end;

procedure armedf_sound_update;
begin
  ym3812_0.update;
  dac_0.update;
  dac_1.update;
end;

//Main
procedure reset_armedf;
begin
 m68000_0.reset;
 z80_0.reset;
 YM3812_0.reset;
 dac_0.reset;
 dac_1.reset;
 reset_audio;
 marcade.in0:=$ffff;
 marcade.in1:=$ffff;
 scroll_fg_x:=0;
 scroll_fg_y:=0;
 scroll_bg_x:=0;
 scroll_bg_y:=0;
 sound_latch:=0;
 video_reg:=0;
end;

function iniciar_armedf:boolean;
var
  memoria_temp:array[0..$5ffff] of byte;
const
  pf_x:array[0..15] of dword=(4, 0, 12, 8, 20, 16, 28, 24,
			32+4, 32+0, 32+12, 32+8, 32+20, 32+16, 32+28, 32+24);
  pf_y:array[0..15] of dword=(0*64, 1*64, 2*64, 3*64, 4*64, 5*64, 6*64, 7*64,
			8*64, 9*64, 10*64, 11*64, 12*64, 13*64, 14*64, 15*64);
  ps_x:array[0..15] of dword=(4, 0, $800*64*8+4, $800*64*8+0, 12, 8, $800*64*8+12, $800*64*8+8,
			20, 16, $800*64*8+20, $800*64*8+16, 28, 24, $800*64*8+28, $800*64*8+24);
  ps_y:array[0..15] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32,
			8*32, 9*32, 10*32, 11*32, 12*32, 13*32, 14*32, 15*32);
begin
iniciar_armedf:=false;
iniciar_audio(false);
//Pantallas
screen_init(1,512,256,false);
screen_init(2,512,256,true);
screen_init(3,1024,512,true);
screen_mod_scroll(3,1024,512,1023,512,256,511);
screen_init(4,1024,512,true);
screen_mod_scroll(4,1024,512,1023,512,256,511);
screen_init(5,512,256,false,true);
if main_vars.tipo_maquina=275 then main_screen.rol90_screen:=true;
iniciar_video(320,240);
//Main CPU
m68000_0:=cpu_m68000.create(8000000,256);
m68000_0.change_ram16_calls(armedf_getword,armedf_putword);
//Sound CPU
z80_0:=cpu_z80.create(4000000,256);
z80_0.change_ram_calls(armedf_snd_getbyte,armedf_snd_putbyte);
z80_0.change_io_calls(armedf_snd_in,armedf_snd_out);
z80_0.init_sound(armedf_sound_update);
timers.init(z80_0.numero_cpu,4000000/(4000000/512),armedf_snd_irq,nil,true);
//Sound Chips
ym3812_0:=ym3812_chip.create(YM3812_FM,4000000,0.6);
dac_0:=dac_chip.create(1);
dac_1:=dac_chip.create(1);
//cargar roms
if not(roms_load16w(@rom,armedf_rom)) then exit;
//cargar sonido
if not(roms_load(@mem_snd,armedf_sound)) then exit;
//convertir chars
if not(roms_load(@memoria_temp,armedf_char)) then exit;
init_gfx(0,8,8,$400);
gfx[0].trans[15]:=true;
gfx_set_desc_data(4,0,32*8,0,1,2,3);
convert_gfx(0,0,@memoria_temp,@pf_x,@ps_y,false,false);
//convertir bg
if not(roms_load(@memoria_temp,armedf_bg)) then exit;
init_gfx(1,16,16,$400);
gfx[1].trans[15]:=true;
gfx_set_desc_data(4,0,128*8,0,1,2,3);
convert_gfx(1,0,@memoria_temp,@pf_x,@pf_y,false,false);
//convertir fg
if not(roms_load(@memoria_temp,armedf_fg)) then exit;
init_gfx(2,16,16,$400);
gfx[2].trans[15]:=true;
gfx_set_desc_data(4,0,128*8,0,1,2,3);
convert_gfx(2,0,@memoria_temp,@pf_x,@pf_y,false,false);
//convertir sprites
if not(roms_load(@memoria_temp,armedf_sprites)) then exit;
init_gfx(3,16,16,$800);
gfx_set_desc_data(4,0,64*8,0,1,2,3);
convert_gfx(3,0,@memoria_temp,@ps_x,@ps_y,false,false);
//DIP
marcade.dswa:=$ffdf;
marcade.dswb:=$ffcf;
//final
reset_armedf;
iniciar_armedf:=true;
end;

procedure Cargar_armedf;
begin
llamadas_maquina.iniciar:=iniciar_armedf;
llamadas_maquina.bucle_general:=armedf_principal;
llamadas_maquina.reset:=reset_armedf;
llamadas_maquina.fps_max:=59.082012;
end;

end.
