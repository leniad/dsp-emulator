unit tigerroad_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m68000,main_engine,controls_engine,gfx_engine,nz80,ym_2203,rom_engine,
     pal_engine,sound_engine,misc_functions;

procedure cargar_tigeroad;

implementation
const
        //Tiger Road
        tigeroad_rom:array[0..2] of tipo_roms=(
        (n:'tru02.bin';l:$20000;p:0;crc:$8d283a95),(n:'tru04.bin';l:$20000;p:$1;crc:$72e2ef20),());
        tigeroad_char:tipo_roms=(n:'tr01.bin';l:$8000;p:0;crc:$74a9f08c);
        tigeroad_fondo:array[0..8] of tipo_roms=(
        (n:'tr-01a.bin';l:$20000;p:0;crc:$a8aa2e59),(n:'tr-04a.bin';l:$20000;p:$20000;crc:$8863a63c),
        (n:'tr-02a.bin';l:$20000;p:$40000;crc:$1a2c5f89),(n:'tr05.bin';l:$20000;p:$60000;crc:$5bf453b3),
        (n:'tr-03a.bin';l:$20000;p:$80000;crc:$1e0537ea),(n:'tr-06a.bin';l:$20000;p:$a0000;crc:$b636c23a),
        (n:'tr-07a.bin';l:$20000;p:$c0000;crc:$5f907d4d),(n:'tr08.bin';l:$20000;p:$e0000;crc:$adee35e2),());
        tigeroad_fondo_rom:tipo_roms=(n:'tr13.bin';l:$8000;p:0;crc:$a79be1eb);
        tigeroad_sprites:array[0..4] of tipo_roms=(
        (n:'tr-09a.bin';l:$20000;p:0;crc:$3d98ad1e),(n:'tr-10a.bin';l:$20000;p:$20000;crc:$8f6f03d7),
        (n:'tr-11a.bin';l:$20000;p:$40000;crc:$cd9152e5),(n:'tr-12a.bin';l:$20000;p:$60000;crc:$7d8a99d0),());
        tigeroad_sound:tipo_roms=(n:'tru05.bin';l:$8000;p:0;crc:$f9a7c9bf);
        //F1 Dream
        f1dream_rom:array[0..4] of tipo_roms=(
        (n:'f1d_04.bin';l:$10000;p:0;crc:$903febad),(n:'f1d_05.bin';l:$10000;p:$1;crc:$666fa2a7),
        (n:'f1d_02.bin';l:$10000;p:$20000;crc:$98973c4c),(n:'f1d_03.bin';l:$10000;p:$20001;crc:$3d21c78a),());
        f1dream_char:tipo_roms=(n:'10d_01.bin';l:$8000;p:0;crc:$361caf00);
        f1dream_fondo:array[0..6] of tipo_roms=(
        (n:'03f_12.bin';l:$10000;p:0;crc:$bc13e43c),(n:'01f_10.bin';l:$10000;p:$10000;crc:$f7617ad9),
        (n:'03h_14.bin';l:$10000;p:$20000;crc:$e33cd438),(n:'02f_11.bin';l:$10000;p:$30000;crc:$4aa49cd7),
        (n:'17f_09.bin';l:$10000;p:$40000;crc:$ca622155),(n:'02h_13.bin';l:$10000;p:$50000;crc:$2a63961e),());
        f1dream_fondo_rom:tipo_roms=(n:'07l_15.bin';l:$8000;p:0;crc:$978758b7);
        f1dream_sprites:array[0..4] of tipo_roms=(
        (n:'03b_06.bin';l:$10000;p:0;crc:$5e54e391),(n:'02b_05.bin';l:$10000;p:$10000;crc:$cdd119fd),
        (n:'03d_08.bin';l:$10000;p:$20000;crc:$811f2e22),(n:'02d_07.bin';l:$10000;p:$30000;crc:$aa9a1233),());
        f1dream_sound:tipo_roms=(n:'12k_04.bin';l:$8000;p:0;crc:$4b9a7524);

var
 scroll_x,scroll_y,mask_sprite,mask_back:word;
 rom:array[0..$1ffff] of word;
 ram:array[0..$1fff] of word;
 sprite_ram:array[0..$808] of word;
 video_ram:array[0..$3ff] of word;
 fondo_rom:array[0..$7fff] of byte;
 pintar_fondo:boolean;
 fondo_bank,sound_latch:byte;

procedure draw_fondo;inline;
var
  nchar,color,pos:word;
  x,y,f,data,atrib,sx,sy:byte;
begin
for f:=0 to $50 do begin
  x:=f div 9;
  y:=f mod 9;
  sx:=(x+((scroll_x and $fe0) shr 5)) and $7f;
  sy:=(y+((scroll_y and $fe0) shr 5)) and $7f;
  pos:=(((sx and 7) shl 1)+(((127-sy) and $7) shl 4)+((sx shr 3) shl 7)+(((127-sy) shr 3) shl 11)) and $7fff;
  data:=fondo_rom[pos];
  atrib:=fondo_rom[pos+1];
  nchar:=(data+((atrib and $c0) shl 2)+(fondo_bank shl 10)) and mask_back;
  color:=(atrib and $0f) shl 4;
  put_gfx_flip(x shl 5,y shl 5,nchar,color,2,1,(atrib and $20)<>0,false);
  if (atrib and $10)<>0 then put_gfx_trans_flip(x shl 5,y shl 5,nchar,color,4,1,(atrib and $20)<>0,false)
    else put_gfx_block_trans(x shl 5,y shl 5,4,32,32);
end;
pintar_fondo:=false;
end;

procedure update_video_tigeroad;inline;
var
  f,color,x,y,nchar,atrib:word;
begin
//background
if pintar_fondo then draw_fondo;
scroll_x_y(2,3,scroll_x and $1f,scroll_y and $1f);
//sprites
for f:=$9f downto 0 do begin
    nchar:=sprite_ram[f*4] and mask_sprite;
    atrib:=sprite_ram[(f*4)+1];
  	y:=240-sprite_ram[(f*4)+2];
		x:=sprite_ram[(f*4)+3];
		color:=(((atrib shr 2) and $f) shl 4)+$100;
    put_gfx_sprite(nchar,color,(atrib and 2)<>0,(atrib and 1)<>0,2);
    actualiza_gfx_sprite(x,y,3,2);
end;
scroll_x_y(4,3,scroll_x and $1f,scroll_y and $1f);
//foreground
for f:=$0 to $3ff do begin
  atrib:=video_ram[f];
  color:=(atrib shr 8) and $f;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
    x:=f mod 32;
    y:=f div 32;
    nchar:=BITSWAP16(atrib,9,8,10,12,11,13,15,14,7,6,5,4,3,2,1,0);
    put_gfx_trans_flip(x*8,y*8,nchar and $7ff,(color shl 2)+512,1,0,false,(atrib and $1000)<>0);
    gfx[0].buffer[f]:=false;
  end;
end;
actualiza_trozo(0,0,256,256,1,0,0,256,256,3);
actualiza_trozo_final(0,16,256,224,3);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure eventos_tigeroad;
begin
if event.arcade then begin
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $Fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $Fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.coin[0] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  if arcade_input.coin[1] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
end;
end;

procedure tigeroad_principal;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
frame_s:=z80_0.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
    //Main CPU
    m68000_0.run(frame_m);
    frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
    //Sound CPU
    z80_0.run(frame_s);
    frame_s:=frame_s+z80_0.tframes-z80_0.contador;
    if f=239 then begin
      update_video_tigeroad;
      m68000_0.irq[2]:=HOLD_LINE;
    end;
  end;
  eventos_tigeroad;
  video_sync;
end;
end;

procedure cambiar_color(tmp_color,numero:word);inline;
var
  color:tcolor;
begin
  color.r:=pal4bit(tmp_color shr 8);
  color.g:=pal4bit(tmp_color shr 4);
  color.b:=pal4bit(tmp_color);
  set_pal_color(color,numero);
  case numero of
    0..$ff:pintar_fondo:=true;
    512..575:buffer_color[(numero shr 2) and $f]:=true;
  end;
end;

function tigeroad_getword(direccion:dword):word;
var
  tempw:word;
begin
case direccion of
  0..$3ffff:tigeroad_getword:=rom[direccion shr 1];
  $fe4000:tigeroad_getword:=$ff00 or marcade.in0;
  $fe4002:tigeroad_getword:=(marcade.in1 shl 8) or $ff;
  $fe4004:tigeroad_getword:=(marcade.in2 shl 8) or $ff;
  $fe0800..$fe1807:begin
                      tempw:=direccion-$fe0800;
                      tigeroad_getword:=sprite_ram[tempw shr 1];
                   end;
  $fec000..$fec7ff:tigeroad_getword:=video_ram[(direccion and $7ff) shr 1];
  $ff8200..$ff867f:begin
                      tempw:=direccion-$ff8200;
                      tigeroad_getword:=buffer_paleta[tempw shr 1];
                   end;
  $ffc000..$ffffff:tigeroad_getword:=ram[(direccion and $3fff) shr 1];
end;
end;

procedure tigeroad_putword(direccion:dword;valor:word);
var
  tempw:word;
  bank:byte;
begin
case direccion of
  $0..$3ffff:exit;
  $fe0800..$fe1807:begin
                      tempw:=direccion-$fe0800;
                      sprite_ram[tempw shr 1]:=valor;
                   end;
  $fe4000:begin  //video control
             bank:=(valor shr 10) and $1;
          	 if (fondo_bank<>bank) then begin
			          fondo_bank:=bank;
          			pintar_fondo:=true;
             end;
             main_screen.flip_main_screen:=(valor and $200)<>0;
          end;
  $fe4002:sound_latch:=valor shr 8;
  $fe8000:if scroll_x<>(valor and $fff) then begin
             if abs((scroll_x and $fe0)-(valor and $fe0))>31 then pintar_fondo:=true;
             scroll_x:=valor and $fff;
          end;
  $fe8002:begin
             tempw:=(-valor-256) and $fff;
             if scroll_y<>tempw then begin
              if abs((scroll_y and $fe0)-(tempw and $fe0))>31 then
                pintar_fondo:=true;
                scroll_y:=tempw;
             end;
          end;
  $fec000..$fec7ff:begin
                      video_ram[(direccion and $7ff) shr 1]:=valor;
                      gfx[0].buffer[(direccion and $7ff) shr 1]:=true;
                   end;
  $ff8200..$ff867f:begin
                      tempw:=(direccion-$ff8200) shr 1;
                      if buffer_paleta[tempw]<>valor then begin
                        buffer_paleta[tempw]:=valor;
                        cambiar_color(valor,tempw);
                      end;
                   end;
  $ffc000..$ffffff:ram[(direccion and $3fff) shr 1]:=valor;
end;
end;

function tigeroad_snd_getbyte(direccion:word):byte;
begin
case direccion of
   0..$7fff,$c000..$c7ff:tigeroad_snd_getbyte:=mem_snd[direccion];
   $8000:tigeroad_snd_getbyte:=ym2203_0.status;
   $8001:tigeroad_snd_getbyte:=ym2203_0.read;
   $a000:tigeroad_snd_getbyte:=ym2203_1.status;
   $a001:tigeroad_snd_getbyte:=ym2203_1.read;
   $e000:tigeroad_snd_getbyte:=sound_latch;
end;
end;

procedure tigeroad_snd_putbyte(direccion:word;valor:byte);
begin
if direccion<$8000 then exit;
case direccion of
  $8000:ym2203_0.Control(valor);
  $8001:ym2203_0.Write(valor);
  $a000:ym2203_1.Control(valor);
  $a001:ym2203_1.Write(valor);
  $c000..$c7ff:mem_snd[direccion]:=valor;
end;
end;

procedure snd_irq(irqstate:byte);
begin
  z80_0.change_irq(irqstate);
end;

procedure tigeroad_sound_update;
begin
  ym2203_0.Update;
  ym2203_1.Update;
end;

//Main
procedure reset_tigeroad;
begin
 m68000_0.reset;
 z80_0.reset;
 ym2203_0.reset;
 ym2203_1.reset;
 reset_audio;
 marcade.in0:=$FF;
 marcade.in1:=$FF;
 if main_vars.tipo_maquina=52 then marcade.in2:=$fb
  else marcade.in2:=$bb;
 scroll_x:=0;
 scroll_y:=0;
 pintar_fondo:=true;
 fondo_bank:=0;
 sound_latch:=0;
end;

function iniciar_tigeroad:boolean;
var
  memoria_temp:pbyte;
const
  pb_x:array[0..31] of dword=(0, 1, 2, 3, 8+0, 8+1, 8+2, 8+3,
		64*8+0, 64*8+1, 64*8+2, 64*8+3, 64*8+8+0, 64*8+8+1, 64*8+8+2, 64*8+8+3,
		2*64*8+0, 2*64*8+1, 2*64*8+2, 2*64*8+3, 2*64*8+8+0, 2*64*8+8+1, 2*64*8+8+2, 2*64*8+8+3,
		3*64*8+0, 3*64*8+1, 3*64*8+2, 3*64*8+3, 3*64*8+8+0, 3*64*8+8+1, 3*64*8+8+2, 3*64*8+8+3);
  pb_y:array[0..31] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16,
		8*16, 9*16, 10*16, 11*16, 12*16, 13*16, 14*16, 15*16,
		16*16, 17*16, 18*16, 19*16, 20*16, 21*16, 22*16, 23*16,
		24*16, 25*16, 26*16, 27*16, 28*16, 29*16, 30*16, 31*16);
  pc_x:array[0..7] of dword=(0, 1, 2, 3, 8+0, 8+1, 8+2, 8+3);
  pc_y:array[0..7] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16 );
  ps_x:array[0..15] of dword=(0, 1, 2, 3, 4, 5, 6, 7,
			16*8+0, 16*8+1, 16*8+2, 16*8+3, 16*8+4, 16*8+5, 16*8+6, 16*8+7 );
  ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8 );

procedure tiger_road_chars;
begin
init_gfx(0,8,8,$800);
gfx[0].trans[3]:=true;
gfx_set_desc_data(2,0,16*8,4,0);
convert_gfx(0,0,memoria_temp,@pc_x[0],@pc_y[0],false,false);
end;

procedure tiger_road_tiles(nchars:word);
var
  f:byte;
begin
init_gfx(1,32,32,nchars);
for f:=0 to 8 do gfx[1].trans[f]:=true;
gfx_set_desc_data(4,0,256*8,nchars*256*8+4,nchars*256*8+0,4,0);
convert_gfx(1,0,memoria_temp,@pb_x[0],@pb_y[0],false,false);
end;

procedure tiger_road_sprites(nchars:word);
begin
init_gfx(2,16,16,nchars);
gfx[2].trans[15]:=true;
gfx_set_desc_data(4,0,32*8,nchars*32*8*3,nchars*32*8*2,nchars*32*8*1,nchars*32*8*0);
convert_gfx(2,0,memoria_temp,@ps_x[0],@ps_y[0],false,false);
end;

begin
iniciar_tigeroad:=false;
iniciar_audio(false);
screen_init(1,256,256,true);
screen_init(2,288,288);
screen_mod_scroll(2,288,256,255,288,256,255);
screen_init(3,512,512,false,true);
screen_init(4,288,288,true);
screen_mod_scroll(4,288,256,255,288,256,255);
iniciar_video(256,224);
//Main CPU
m68000_0:=cpu_m68000.create(10000000,$100);
m68000_0.change_ram16_calls(tigeroad_getword,tigeroad_putword);
//Sound CPU
z80_0:=cpu_z80.create(3579545,$100);
z80_0.change_ram_calls(tigeroad_snd_getbyte,tigeroad_snd_putbyte);
z80_0.init_sound(tigeroad_sound_update);
//sound chips
ym2203_0:=ym2203_chip.create(3579545);
ym2203_0.change_irq_calls(snd_irq);
ym2203_1:=ym2203_chip.create(3579545);
getmem(memoria_temp,$100000);
case main_vars.tipo_maquina of
  52:begin
        if not(cargar_roms16w(@rom[0],@tigeroad_rom[0],'tigeroad.zip',0)) then exit;
        if not(cargar_roms(@mem_snd[0],@tigeroad_sound,'tigeroad.zip')) then exit;
        //convertir chars
        if not(cargar_roms(memoria_temp,@tigeroad_char,'tigeroad.zip')) then exit;
        tiger_road_chars;
        //background
        mask_sprite:=$fff;
        mask_back:=$7ff;
        if not(cargar_roms(@fondo_rom[0],@tigeroad_fondo_rom,'tigeroad.zip')) then exit;
        if not(cargar_roms(memoria_temp,@tigeroad_fondo,'tigeroad.zip',0)) then exit;
        tiger_road_tiles($800);
        //sprites
        if not(cargar_roms(memoria_temp,@tigeroad_sprites,'tigeroad.zip',0)) then exit;
        tiger_road_sprites($1000);
     end;
  53:begin
        if not(cargar_roms16w(@rom[0],@f1dream_rom[0],'f1dream.zip',0)) then exit;
        if not(cargar_roms(@mem_snd[0],@f1dream_sound,'f1dream.zip')) then exit;
        //convertir chars
        if not(cargar_roms(memoria_temp,@f1dream_char,'f1dream.zip')) then exit;
        tiger_road_chars;
        //background
        mask_sprite:=$7ff;
        mask_back:=$3ff;
        if not(cargar_roms(@fondo_rom[0],@f1dream_fondo_rom,'f1dream.zip')) then exit;
        if not(cargar_roms(memoria_temp,@f1dream_fondo,'f1dream.zip',0)) then exit;
        tiger_road_tiles($300);
        //sprites
        if not(cargar_roms(memoria_temp,@f1dream_sprites,'f1dream.zip',0)) then exit;
        tiger_road_sprites($800);
     end;
end;
//final
freemem(memoria_temp);
reset_tigeroad;
iniciar_tigeroad:=true;
end;

procedure Cargar_tigeroad;
begin
llamadas_maquina.iniciar:=iniciar_tigeroad;
llamadas_maquina.bucle_general:=tigeroad_principal;
llamadas_maquina.reset:=reset_tigeroad;
llamadas_maquina.fps_max:=60.08;
end;

end.
