unit ninjakid2_hw;

interface
uses sdl2,{$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,ym_2203,gfx_engine,rom_engine,
     pal_engine,mc8123,sound_engine;

procedure Cargar_ninjakid2;
procedure ninjakid2_principal;
function iniciar_ninjakid2:boolean;
procedure reset_ninjakid2;
procedure cerrar_ninjakid2;
//Main CPU
function ninjakid2_getbyte(direccion:word):byte;
procedure ninjakid2_putbyte(direccion:word;valor:byte);
function aarea_getbyte(direccion:word):byte;
procedure aarea_putbyte(direccion:word;valor:byte);
//Sound CPU
function ninjakid2_snd_getbyte(direccion:word):byte;
procedure ninjakid2_snd_putbyte(direccion:word;valor:byte);
function ninjakid2_snd_inbyte(puerto:word):byte;
procedure ninjakid2_snd_outbyte(valor:byte;puerto:word);
procedure ninjakid2_sound_update;
procedure snd_irq(irqstate:byte);

const
        //Ninja Kid II
        ninjakid2_rom:array[0..5] of tipo_roms=(
        (n:'nk2_01.rom';l:$8000;p:0;crc:$3cdbb906),(n:'nk2_02.rom';l:$8000;p:$8000;crc:$b5ce9a1a),
        (n:'nk2_03.rom';l:$8000;p:$10000;crc:$ad275654),(n:'nk2_04.rom';l:$8000;p:$18000;crc:$e7692a77),
        (n:'nk2_05.rom';l:$8000;p:$20000;crc:$5dac9426),());
        ninjakid2_snd_rom:tipo_roms=(n:'nk2_06.rom';l:$10000;p:0;crc:$d3a18a79);
        ninjakid2_fgtiles:tipo_roms=(n:'nk2_12.rom';l:$8000;p:0;crc:$db5657a9);
        ninjakid2_sprites:array[0..2] of tipo_roms=(
        (n:'nk2_08.rom';l:$10000;p:0;crc:$1b79c50a),(n:'nk2_07.rom';l:$10000;p:$10000;crc:$0be5cd13),());
        ninjakid2_bgtiles:array[0..2] of tipo_roms=(
        (n:'nk2_11.rom';l:$10000;p:0;crc:$41a714b3),(n:'nk2_10.rom';l:$10000;p:$10000;crc:$c913c4ab),());
        ninjakid2_snd_key:tipo_roms=(n:'ninjakd2.key';l:$2000;p:0;crc:$ec25318f);
        //Ark Area
        aarea_rom:array[0..5] of tipo_roms=(
        (n:'arkarea.008';l:$8000;p:0;crc:$1ce1b5b9),(n:'arkarea.009';l:$8000;p:$8000;crc:$db1c81d1),
        (n:'arkarea.010';l:$8000;p:$10000;crc:$5a460dae),(n:'arkarea.011';l:$8000;p:$18000;crc:$63f022c9),
        (n:'arkarea.012';l:$8000;p:$20000;crc:$3c4c65d5),());
        aarea_snd_rom:tipo_roms=(n:'arkarea.013';l:$8000;p:0;crc:$2d409d58);
        aarea_fgtiles:tipo_roms=(n:'arkarea.004';l:$8000;p:0;crc:$69e36af2);
        aarea_sprites:array[0..3] of tipo_roms=(
        (n:'arkarea.007';l:$10000;p:0;crc:$d5684a27),(n:'arkarea.006';l:$10000;p:$10000;crc:$2c0567d6),
        (n:'arkarea.005';l:$10000;p:$20000;crc:$9886004d),());
        aarea_bgtiles:array[0..3] of tipo_roms=(
        (n:'arkarea.003';l:$10000;p:0;crc:$6f45a308),(n:'arkarea.002';l:$10000;p:$10000;crc:$051d3482),
        (n:'arkarea.001';l:$10000;p:$20000;crc:$09d11ab7),());
        //Mutant Night
        mnight_rom:array[0..5] of tipo_roms=(
        (n:'mn6-j19.bin';l:$8000;p:0;crc:$56678d14),(n:'mn5-j17.bin';l:$8000;p:$8000;crc:$2a73f88e),
        (n:'mn4-j16.bin';l:$8000;p:$10000;crc:$c5e42bb4),(n:'mn3-j14.bin';l:$8000;p:$18000;crc:$df6a4f7a),
        (n:'mn2-j12.bin';l:$8000;p:$20000;crc:$9c391d1b),());
        mnight_snd_rom:tipo_roms=(n:'mn1-j7.bin';l:$10000;p:0;crc:$a0782a31);
        mnight_fgtiles:tipo_roms=(n:'mn10-b10.bin';l:$8000;p:0;crc:$37b8221f);
        mnight_sprites:array[0..3] of tipo_roms=(
        (n:'mn7-e11.bin';l:$10000;p:0;crc:$4883059c),(n:'mn8-e12.bin';l:$10000;p:$10000;crc:$02b91445),
        (n:'mn9-e14.bin';l:$10000;p:$20000;crc:$9f08d160),());
        mnight_bgtiles:array[0..3] of tipo_roms=(
        (n:'mn11-b20.bin';l:$10000;p:0;crc:$4d37e0f4),(n:'mn12-b22.bin';l:$10000;p:$10000;crc:$b22cbbd3),
        (n:'mn13-b23.bin';l:$10000;p:$20000;crc:$65714070),());

type
  tipo_update_background=procedure;

var
  rom_bank:array[0..7,0..$3fff] of byte;
  mem_snd_opc:array[0..$7fff] of byte;
  fg_data,bg_data:array[0..$7ff] of byte;
  sprite_data:array[0..$5ff] of byte;
  rom_nbank,sound_latch:byte;
  scroll_x,scroll_y:word;
  bg_enable,sprite_overdraw:boolean;
  pant_sprites_tmp:array[0..$3ffff] of byte;
  update_background:tipo_update_background;

implementation

procedure Cargar_ninjakid2;
begin
llamadas_maquina.iniciar:=iniciar_ninjakid2;
llamadas_maquina.bucle_general:=ninjakid2_principal;
llamadas_maquina.cerrar:=cerrar_ninjakid2;
llamadas_maquina.reset:=reset_ninjakid2;
llamadas_maquina.fps_max:=59.61;
end;

procedure bg_ninjakid2;
var
  f,color,nchar:word;
  x,y,atrib:byte;
begin
for f:=0 to $3ff do begin
  atrib:=bg_data[$1+(f*2)];
  color:=atrib and $f;
  if (gfx[1].buffer[f] or buffer_color[color]) then begin
      x:=f mod 32;
      y:=f div 32;
      nchar:=(bg_data[f*2]+((atrib and $c0) shl 2)) and $3ff;
      put_gfx_flip(x*16,y*16,nchar,color shl 4,2,1,(atrib and $10)<>0,(atrib and $20)<>0);
      gfx[1].buffer[f]:=false;
    end;
end;
end;

procedure bg_arkarea;
var
  f,color,nchar:word;
  x,y,atrib:byte;
begin
for f:=0 to $3ff do begin
  atrib:=bg_data[$1+(f*2)];
  color:=atrib and $f;
  if (gfx[1].buffer[f] or buffer_color[color]) then begin
      x:=f mod 32;
      y:=f div 32;
      nchar:=bg_data[f*2]+((atrib and $10) shl 6)+((atrib and $c0) shl 2);
      if nchar>$600 then continue;
      put_gfx_flip(x*16,y*16,nchar,color shl 4,2,1,false,(atrib and $20)<>0);
      gfx[1].buffer[f]:=false;
    end;
end;
end;

function iniciar_ninjakid2:boolean;
var
  f:byte;
  memoria_temp:array[0..$2ffff] of byte;
  mem_key:array[0..$1fff] of byte;
const
    pc_x:array[0..7] of dword=(0*4, 1*4, 2*4, 3*4, 4*4, 5*4, 6*4, 7*4);
    pc_y:array[0..7] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32);
    pt_x:array[0..15] of dword=(0*4, 1*4, 2*4, 3*4, 4*4, 5*4, 6*4, 7*4,
			32*8+0*4, 32*8+1*4, 32*8+2*4, 32*8+3*4, 32*8+4*4, 32*8+5*4, 32*8+6*4, 32*8+7*4);
    pt_y:array[0..15] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32,
			64*8+0*32, 64*8+1*32, 64*8+2*32, 64*8+3*32, 64*8+4*32, 64*8+5*32, 64*8+6*32, 64*8+7*32);
procedure lineswap_gfx_roms(length:dword;src:pbyte;bit:byte);
var
  ptemp,ptemp2,ptemp3:pbyte;
  f,pos,mask:dword;
begin
  getmem(ptemp,length);
	mask:=(1 shl (bit+1))-1;
	for f:=0 to (length-1) do begin
		pos:=(f and not(mask)) or ((f shl 1) and mask) or ((f shr bit) and 1);
    ptemp2:=ptemp;
    inc(ptemp2,pos);
    ptemp3:=src;
    inc(ptemp3,f);
    ptemp2^:=ptemp3^;
	end;
  copymemory(src,ptemp,length);
	freemem(ptemp);
end;
procedure extract_char;
begin
  lineswap_gfx_roms($8000,@memoria_temp[0],13);
  init_gfx(0,8,8,$400);
  gfx_set_desc_data(4,0,32*8,0,1,2,3);
  convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,false);
end;
procedure extract_gr2(size:dword;num:byte;size_gr:word);
begin
  lineswap_gfx_roms(size,@memoria_temp[0],14);
  init_gfx(num,16,16,size_gr);
  gfx_set_desc_data(4,0,128*8,0,1,2,3);
  convert_gfx(num,0,@memoria_temp[0],@pt_x[0],@pt_y[0],false,false);
end;
begin
iniciar_ninjakid2:=false;
iniciar_audio(false);
//Pantallas:  principal+char y sprites
screen_init(1,256,256,true);
screen_init(2,512,512);
screen_mod_scroll(2,512,256,511,512,256,511);
screen_init(3,512,256,false,true);
//Sprites
screen_init(4,512,256,true);
iniciar_video(256,192);
//Main CPU
main_z80:=cpu_z80.create(6000000,256);
//Sound CPU
snd_z80:=cpu_z80.create(5000000,256);
snd_z80.change_ram_calls(ninjakid2_snd_getbyte,ninjakid2_snd_putbyte);
snd_z80.change_io_calls(ninjakid2_snd_inbyte,ninjakid2_snd_outbyte);
snd_z80.init_sound(ninjakid2_sound_update);
//Sound Chips
ym2203_0:=ym2203_chip.create(0,1500000,2);
ym2203_0.change_irq_calls(snd_irq);
ym2203_1:=ym2203_chip.create(1,1500000,2);
case main_vars.tipo_maquina of
  120:begin
        update_background:=bg_ninjakid2;
        main_z80.change_ram_calls(ninjakid2_getbyte,ninjakid2_putbyte);
        //cargar roms y ponerlas en sus bancos
        if not(cargar_roms(@memoria_temp[0],@ninjakid2_rom[0],'ninjakd2.zip',0)) then exit;
        copymemory(@memoria[0],@memoria_temp[0],$8000);
        for f:=0 to 7 do copymemory(@rom_bank[f,0],@memoria_temp[(f*$4000)+$8000],$4000);
        //cargar ROMS sonido y desencriptar
        if not(cargar_roms(@mem_snd[0],@ninjakid2_snd_rom,'ninjakd2.zip',1)) then exit;
        if not(cargar_roms(@mem_key[0],@ninjakid2_snd_key,'ninjakd2.zip',1)) then exit;
        mc8123_decrypt_rom(@mem_key[0],@mem_snd[0],@mem_snd_opc[0],0);
        //convertir fg
        if not(cargar_roms(@memoria_temp[0],@ninjakid2_fgtiles,'ninjakd2.zip',1)) then exit;
        extract_char;
        //convertir bg
        if not(cargar_roms(@memoria_temp[0],@ninjakid2_bgtiles[0],'ninjakd2.zip',0)) then exit;
        extract_gr2($20000,1,$400);
        //convertir sprites
        if not(cargar_roms(@memoria_temp[0],@ninjakid2_sprites[0],'ninjakd2.zip',0)) then exit;
        extract_gr2($20000,2,$400);
  end;
  121:begin
        update_background:=bg_arkarea;
        marcade.in3:=$ef;
        main_z80.change_ram_calls(aarea_getbyte,aarea_putbyte);
        //cargar roms y ponerlas en sus bancos
        if not(cargar_roms(@memoria_temp[0],@aarea_rom[0],'arkarea.zip',0)) then exit;
        copymemory(@memoria[0],@memoria_temp[0],$8000);
        for f:=0 to 7 do copymemory(@rom_bank[f,0],@memoria_temp[(f*$4000)+$8000],$4000);
        //cargar ROMS sonido
        if not(cargar_roms(@mem_snd[0],@aarea_snd_rom,'arkarea.zip',1)) then exit;
        copymemory(@mem_snd_opc[0],@mem_snd[0],$8000);
        //convertir fg
        if not(cargar_roms(@memoria_temp[0],@aarea_fgtiles,'arkarea.zip',1)) then exit;
        extract_char;
        //convertir bg
        if not(cargar_roms(@memoria_temp[0],@aarea_bgtiles[0],'arkarea.zip',0)) then exit;
        extract_gr2($30000,1,$600);
        //convertir sprites
        if not(cargar_roms(@memoria_temp[0],@aarea_sprites[0],'arkarea.zip',0)) then exit;
        extract_gr2($30000,2,$600);
      end;
  122:begin
        update_background:=bg_arkarea;
        marcade.in3:=$cf;
        main_z80.change_ram_calls(aarea_getbyte,aarea_putbyte);
        //cargar roms y ponerlas en sus bancos
        if not(cargar_roms(@memoria_temp[0],@mnight_rom[0],'mnight.zip',0)) then exit;
        copymemory(@memoria[0],@memoria_temp[0],$8000);
        for f:=0 to 7 do copymemory(@rom_bank[f,0],@memoria_temp[(f*$4000)+$8000],$4000);
        //cargar ROMS sonido
        if not(cargar_roms(@mem_snd[0],@mnight_snd_rom,'mnight.zip',1)) then exit;
        copymemory(@mem_snd_opc[0],@mem_snd[0],$8000);
        //convertir fg
        if not(cargar_roms(@memoria_temp[0],@mnight_fgtiles,'mnight.zip',1)) then exit;
        extract_char;
        //convertir bg
        if not(cargar_roms(@memoria_temp[0],@mnight_bgtiles[0],'mnight.zip',0)) then exit;
        extract_gr2($30000,1,$600);
        //convertir sprites
        if not(cargar_roms(@memoria_temp[0],@mnight_sprites[0],'mnight.zip',0)) then exit;
        extract_gr2($30000,2,$600);
      end;
end;
gfx[0].trans[15]:=true;
gfx[2].trans[15]:=true;
//final
reset_ninjakid2;
iniciar_ninjakid2:=true;
end;

procedure cerrar_ninjakid2;
begin
main_z80.free;
snd_z80.free;
YM2203_0.Free;
YM2203_1.Free;
close_audio;
close_video;
end;

procedure reset_ninjakid2;
begin
 main_z80.reset;
 main_z80.im0:=$d7;  //rst 10
 snd_z80.reset;
 YM2203_0.reset;
 YM2203_1.reset;
 reset_audio;
 marcade.in0:=$FF;
 marcade.in1:=$FF;
 marcade.in2:=$FF;
 rom_nbank:=0;
 bg_enable:=false;
 sprite_overdraw:=false;
 sound_latch:=0;
 scroll_x:=0;
 scroll_y:=0;
end;

procedure put_gfx_sprite_nkid2(nchar:dword;color:word;flipx,flipy:boolean;pos_x,pos_y:word);inline;
var
  x,y:byte;
  pos_temp:dword;
  temp:pword;
  pos,post:pbyte;
begin
if flipx then begin
  pos:=gfx[2].datos;
  inc(pos,nchar*16*16+15);
  for y:=0 to 15 do begin
    post:=pos;
    inc(post,(y*16));
    temp:=punbuf;
    if flipy then pos_temp:=(pos_y+(15-y))*512+pos_x+15
      else pos_temp:=(pos_y+y)*512+pos_x+15;
    for x:=15 downto 0 do begin
      if post^<>15 then temp^:=paleta[gfx[2].colores[post^+color+$100]]
        else temp^:=paleta[max_colores];
      pant_sprites_tmp[pos_temp]:=color;
      pos_temp:=pos_temp-1;
      dec(post);
      inc(temp);
    end;
    if flipy then putpixel(0,(15-y),16,punbuf,pant_sprites)
      else putpixel(0,y,16,punbuf,pant_sprites);
  end;
end else begin
  pos:=gfx[2].datos;
  inc(pos,nchar*16*16);
  for y:=0 to 15 do begin
    temp:=punbuf;
    if flipy then pos_temp:=(pos_y+(15-y))*512+pos_x
        else pos_temp:=(pos_y+y)*512+pos_x;
    for x:=0 to 15 do begin
      if pos^<>15 then temp^:=paleta[gfx[2].colores[pos^+color+$100]]
        else temp^:=paleta[max_colores];
      pant_sprites_tmp[pos_temp]:=color;
      pos_temp:=pos_temp+1;
      inc(temp);
      inc(pos);
    end;
    if flipy then putpixel(0,(15-y),16,punbuf,pant_sprites)
      else putpixel(0,y,16,punbuf,pant_sprites);
  end;
end;
end;

procedure draw_sprites;inline;
var
  f,color,nchar,sx,tile:word;
  x,y,sy,atrib,num_sprites,big:byte;
  flipx,flipy:boolean;
  tf:dword;
  pos_pixels:pword;
begin
if not(sprite_overdraw) then begin
  fill_full_screen(4,max_colores);
  fillchar(pant_sprites_tmp[0],512*256,0);
end else begin
  for sy:=0 to 255 do begin
      pos_pixels:=pantalla[4].pixels;
      inc(pos_pixels,(sy*pantalla[4].pitch) shr 1);
      tf:=sy*512;
			for sx:=0 to 255 do begin
				if (pant_sprites_tmp[tf]=$f0) then begin
          pant_sprites_tmp[tf]:=0;
          pos_pixels^:=paleta[max_colores];
        end;
        tf:=tf+1;
        inc(pos_pixels);
			end;
  end;
end;
num_sprites:=0;
f:=0;
repeat
  atrib:=sprite_data[$d+f];
  if (atrib and $2)<>0 then begin
    sx:=sprite_data[$c+f]-((atrib and $01) shl 8);
		sy:=sprite_data[$b+f];
    // Ninja Kid II doesn't use the topmost bit (it has smaller ROMs) so it might not be connected on the board
		nchar:=sprite_data[$e+f]+((atrib and $c0) shl 2)+((atrib and $08) shl 7);
    flipx:=(atrib and $10)<>0;
    flipy:=(atrib and $20)<>0;
		color:=(sprite_data[$f+f] and $f) shl 4;
    // Ninja Kid II doesn't use the 'big' feature so it might not be available on the board
		big:=(atrib and $04) shr 2;
    if big<>0 then begin
				nchar:=nchar and $fffc;
        nchar:=nchar xor ((atrib and $10) shr 4);
        nchar:=nchar xor (((atrib and $20) shr 5) shl 1);
    end;
    for y:=0 to big do begin
					for x:=0 to big do begin
						tile:=nchar xor (x shl 0) xor (y shl 1);
            put_gfx_sprite_nkid2(tile,color,flipx,flipy,sx+16*x,sy+16*y);
            actualiza_trozo(0,0,gfx[2].x,gfx[2].y,pant_sprites,sx+16*x,sy+16*y,gfx[2].x,gfx[2].y,4);
            num_sprites:=num_sprites+1;
					end;
    end;
  end else num_sprites:=num_sprites+1;
  f:=f+$10;
until num_sprites=96;
end;

procedure update_video_ninjakid2;inline;
var
  f,color,nchar:word;
  x,y,atrib:byte;
begin
for f:=$0 to $3ff do begin
  //foreground
  atrib:=fg_data[1+(f*2)];
  color:=atrib and $f;
  if (gfx[0].buffer[f] or buffer_color[color+$10]) then begin
    x:=f mod 32;
    y:=f div 32;
    nchar:=(fg_data[f*2]+((atrib and $c0) shl 2)) and $3ff;
    put_gfx_trans_flip(x*8,y*8,nchar,(color shl 4)+$200,1,0,(atrib and $10)<>0,(atrib and $20)<>0);
    gfx[0].buffer[f]:=false;
  end;
end;
//background
if bg_enable then begin
  update_background;
  scroll_x_y(2,3,scroll_x,scroll_y);
end else fill_full_screen(3,$300);
//Sprites
draw_sprites;
actualiza_trozo(0,0,256,256,4,0,0,256,256,3);
//Chars
actualiza_trozo(0,0,256,256,1,0,0,256,256,3);
actualiza_trozo_final(0,32,256,192,3);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure eventos_ninjakid2;
begin
if event.arcade then begin
  //P1
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $F7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  //P2
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $F7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  //KEYCOIN
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
end;
end;

procedure ninjakid2_principal;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=main_z80.tframes;
frame_s:=snd_z80.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
    //main
    main_z80.run(frame_m);
    frame_m:=frame_m+main_z80.tframes-main_z80.contador;
    //snd
    snd_z80.run(frame_s);
    frame_s:=frame_s+snd_z80.tframes-snd_z80.contador;
    if f=223 then begin
      main_z80.pedir_irq:=HOLD_LINE;
      update_video_ninjakid2;
    end;
  end;
  eventos_ninjakid2;
  video_sync;
end;
end;

//Ninja Kid II
function ninjakid2_getbyte(direccion:word):byte;
begin
case direccion of
  $8000..$bfff:ninjakid2_getbyte:=rom_bank[rom_nbank,direccion and $3fff];
  $c000:ninjakid2_getbyte:=marcade.in0;
  $c001:ninjakid2_getbyte:=marcade.in1;
  $c002:ninjakid2_getbyte:=marcade.in2;
  $c003:ninjakid2_getbyte:=$6f;
  $c004:ninjakid2_getbyte:=$f9;
  else ninjakid2_getbyte:=memoria[direccion];
end;
end;

procedure cambiar_color(pos:word);inline;
var
  tmp_color:byte;
  color:tcolor;
begin
  tmp_color:=buffer_paleta[pos];
  color.r:=pal4bit(tmp_color shr 4);
  color.g:=pal4bit(tmp_color);
  tmp_color:=buffer_paleta[pos+1];
  color.b:=pal4bit(tmp_color shr 4);
  pos:=pos shr 1;
  set_pal_color(color,@paleta[pos]);
  case pos of
    $0..$ff:buffer_color[pos shr 4]:=true;
    $200..$2ff:buffer_color[((pos shr 4) and $f)+$10]:=true;
  end;
end;

procedure ninjakid2_putbyte(direccion:word;valor:byte);
begin
if direccion<$c000 then exit;
memoria[direccion]:=valor;
case direccion of
   $c200:sound_latch:=valor;
   $c201:if (valor and $10)<>0 then snd_z80.reset;
   $c202:rom_nbank:=valor and $7;
   $c203:sprite_overdraw:=(valor and $1)<>0;
   $c208:scroll_x:=(scroll_x and $ff00) or valor;
   $c209:scroll_x:=(scroll_x and $00ff) or ((valor and $1) shl 8);
   $c20a:scroll_y:=(scroll_y and $ff00) or valor;
   $c20b:scroll_y:=(scroll_y and $00ff) or ((valor and $1) shl 8);
   $c20c:bg_enable:=(valor and $1)<>0;
   $c800..$cdff:if buffer_paleta[direccion and $7ff]<>valor then begin
                    buffer_paleta[direccion and $7ff]:=valor;
                    cambiar_color(direccion and $7fe);
                end;
   $d000..$d7ff:begin
                    fg_data[direccion and $7ff]:=valor;
                    gfx[0].buffer[(direccion and $7ff) shr 1]:=true;
                end;
   $d800..$dfff:begin
                    bg_data[direccion and $7ff]:=valor;
                    gfx[1].buffer[(direccion and $7ff) shr 1]:=true;
                end;
   $fa00..$ffff:sprite_data[direccion-$fa00]:=valor;
end;
end;

//Ark Area
function aarea_getbyte(direccion:word):byte;
begin
case direccion of
  $8000..$bfff:aarea_getbyte:=rom_bank[rom_nbank,direccion and $3fff];
  $f800:aarea_getbyte:=marcade.in0;
  $f801:aarea_getbyte:=marcade.in1;
  $f802:aarea_getbyte:=marcade.in2;
  $f803:aarea_getbyte:=marcade.in3;
  $f804:aarea_getbyte:=$ff;
  else aarea_getbyte:=memoria[direccion];
end;
end;

procedure aarea_putbyte(direccion:word;valor:byte);
begin
if direccion<$c000 then exit;
memoria[direccion]:=valor;
case direccion of
   $da00..$dfff:sprite_data[direccion-$da00]:=valor;
   $e000..$e7ff:begin
                  bg_data[direccion and $7ff]:=valor;
                  gfx[1].buffer[(direccion and $7ff) shr 1]:=true;
                end;
   $e800..$efff:begin
                  fg_data[direccion and $7ff]:=valor;
                  gfx[0].buffer[(direccion and $7ff) shr 1]:=true;
                end;
   $f000..$f5ff:if buffer_paleta[direccion and $7ff]<>valor then begin
                    buffer_paleta[direccion and $7ff]:=valor;
                    cambiar_color(direccion and $7fe);
                end;
   $fa00:sound_latch:=valor;
   $fa01:if (valor and $10)<>0 then snd_z80.reset;
   $fa02:rom_nbank:=valor and $7;
   $fa03:sprite_overdraw:=(valor and $1)<>0;
   $fa08:scroll_x:=(scroll_x and $ff00) or valor;
   $fa09:scroll_x:=(scroll_x and $00ff) or ((valor and $1) shl 8);
   $fa0a:scroll_y:=(scroll_y and $ff00) or valor;
   $fa0b:scroll_y:=(scroll_y and $00ff) or ((valor and $1) shl 8);
   $fa0c:bg_enable:=(valor and $1)<>0;
end;
end;

//Sound
function ninjakid2_snd_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$7fff:if snd_z80.opcode then ninjakid2_snd_getbyte:=mem_snd_opc[direccion]
              else ninjakid2_snd_getbyte:=mem_snd[direccion];
  $e000:ninjakid2_snd_getbyte:=sound_latch;
    else ninjakid2_snd_getbyte:=mem_snd[direccion];
end;
end;

procedure ninjakid2_snd_putbyte(direccion:word;valor:byte);
begin
if direccion<$c000 then exit;
mem_snd[direccion]:=valor;
end;

function ninjakid2_snd_inbyte(puerto:word):byte;
begin
case (puerto and $ff) of
  $00:ninjakid2_snd_inbyte:=ym2203_0.Read_Status;
  $01:ninjakid2_snd_inbyte:=ym2203_0.Read_Reg;
  $80:ninjakid2_snd_inbyte:=ym2203_1.Read_Status;
  $81:ninjakid2_snd_inbyte:=ym2203_1.Read_Reg;
end;
end;

procedure ninjakid2_snd_outbyte(valor:byte;puerto:word);
begin
case (puerto and $ff) of
  $00:ym2203_0.Control(valor);
  $01:ym2203_0.Write_Reg(valor);
  $80:ym2203_1.Control(valor);
  $81:ym2203_1.Write_Reg(valor);
end;
end;

procedure snd_irq(irqstate:byte);
begin
  if (irqstate=1) then snd_z80.pedir_irq:=ASSERT_LINE
    else snd_z80.pedir_irq:=CLEAR_LINE;
end;

procedure ninjakid2_sound_update;
begin
  ym2203_0.Update;
  ym2203_1.Update;
end;

end.
