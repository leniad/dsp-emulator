unit psychic5_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,ym_2203,gfx_engine,rom_engine,pal_engine,
     sound_engine,qsnapshot;

procedure Cargar_psychic5;
procedure psychic5_principal;
function iniciar_psychic5:boolean;
procedure reset_psychic5;
procedure cerrar_psychic5;
//Main CPU
function psychic5_getbyte(direccion:word):byte;
procedure psychic5_putbyte(direccion:word;valor:byte);
//Snd CPU
function psychic5_snd_getbyte(direccion:word):byte;
procedure psychic5_snd_putbyte(direccion:word;valor:byte);
procedure psychic5_outbyte(valor:byte;puerto:word);
procedure psychic5_sound_update;
procedure snd_irq(irqstate:byte);
//Save/load
procedure psychic5_qsave(nombre:string);
procedure psychic5_qload(nombre:string);

implementation
const
        psychic5_rom:array[0..2] of tipo_roms=(
        (n:'p5d';l:$8000;p:0;crc:$90259249),(n:'p5e';l:$10000;p:$8000;crc:$72298f34),());
        psychic5_snd_rom:tipo_roms=(n:'p5a';l:$8000;p:0;crc:$50060ecd);
        psychic5_char:tipo_roms=(n:'p5f';l:$8000;p:0;crc:$04d7e21c);
        psychic5_sprites:array[0..2] of tipo_roms=(
        (n:'p5b';l:$10000;p:0;crc:$7e3f87d4),(n:'p5c';l:$10000;p:$10000;crc:$8710fedb),());
        psychic5_tiles:array[0..2] of tipo_roms=(
        (n:'p5g';l:$10000;p:0;crc:$f9262f32),(n:'p5h';l:$10000;p:$10000;crc:$c411171a),());

var
 mem_rom:array[0..3,0..$3fff] of byte;
 banco_rom,banco_vram,sound_latch,bg_clip_mode,sy1,sy2,sx1:byte;
 bg_ram,char_ram,dummy_ram:array[0..$fff] of byte;
 io_ram:array[0..$fff] of byte;
 title_screen,paleta_gris:boolean;

procedure Cargar_psychic5;
begin
llamadas_maquina.iniciar:=iniciar_psychic5;
llamadas_maquina.bucle_general:=psychic5_principal;
llamadas_maquina.cerrar:=cerrar_psychic5;
llamadas_maquina.reset:=reset_psychic5;
llamadas_maquina.fps_max:=53.8;
llamadas_maquina.save_qsnap:=psychic5_qsave;
llamadas_maquina.load_qsnap:=psychic5_qload;
end;

function iniciar_psychic5:boolean;
var
      f:word;
      memoria_temp:array[0..$1ffff] of byte;
const
    pc_x:array[0..7] of dword=(0, 4, 8, 12, 16, 20, 24, 28);
    pc_y:array[0..7] of dword=(0*8, 4*8, 8*8, 12*8, 16*8, 20*8, 24*8, 28*8);
    ps_x:array[0..15] of dword=(0, 4, 8, 12, 16, 20, 24, 28,
        64*8, 64*8+4, 64*8+8, 64*8+12, 64*8+16, 64*8+20, 64*8+24, 64*8+28);
    ps_y:array[0..15] of dword=(0*8, 4*8, 8*8, 12*8, 16*8, 20*8, 24*8, 28*8, 32*8,
        36*8, 40*8, 44*8, 48*8, 52*8, 56*8, 60*8);
begin
iniciar_psychic5:=false;
iniciar_audio(false);
//Pantallas:  principal+char y sprites
screen_init(1,256,256,true);
screen_init(2,512,512,true);
screen_init(3,512,1024);
screen_mod_scroll(3,512,256,511,1024,256,1023);
screen_init(4,256,256,false,true);
screen_mod_sprites(4,512,0,$1ff,0);
iniciar_video(224,256);
//Main CPU
main_z80:=cpu_z80.create(6000000,256);
main_z80.change_ram_calls(psychic5_getbyte,psychic5_putbyte);
//Sound CPU
snd_z80:=cpu_z80.create(6000000,256);
snd_z80.change_ram_calls(psychic5_snd_getbyte,psychic5_snd_putbyte);
snd_z80.change_io_calls(nil,psychic5_outbyte);
snd_z80.init_sound(psychic5_sound_update);
//Sound Chips
YM2203_0:=ym2203_chip.create(0,1500000,2);
ym2203_0.change_irq_calls(snd_irq);
YM2203_1:=ym2203_chip.create(1,1500000,2);
//cargar roms
if not(cargar_roms(@memoria_temp[0],@psychic5_rom[0],'psychic5.zip',0)) then exit;
//Poner las ROMS en sus bancos
copymemory(@memoria[0],@memoria_temp[0],$8000);
for f:=0 to 3 do copymemory(@mem_rom[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
//cargar ROMS sonido
if not(cargar_roms(@mem_snd[0],@psychic5_snd_rom,'psychic5.zip',1)) then exit;
//convertir chars
if not(cargar_roms(@memoria_temp[0],@psychic5_char,'psychic5.zip',1)) then exit;
init_gfx(0,8,8,1024);
gfx[0].trans[15]:=true;
gfx_set_desc_data(4,0,32*8,0,1,2,3);
convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,true);
//convertir sprites
if not(cargar_roms(@memoria_temp[0],@psychic5_sprites[0],'psychic5.zip',0)) then exit;
init_gfx(1,16,16,1024);
gfx[1].trans[15]:=true;
gfx_set_desc_data(4,0,128*8,0,1,2,3);
convert_gfx(1,0,@memoria_temp[0],@ps_x[0],@ps_y[0],false,true);
//convertir tiles
if not(cargar_roms(@memoria_temp[0],@psychic5_tiles[0],'psychic5.zip',0)) then exit;
init_gfx(2,16,16,1024);
convert_gfx(2,0,@memoria_temp[0],@ps_x[0],@ps_y[0],false,true);
//final
reset_psychic5;
iniciar_psychic5:=true;
end;

procedure cerrar_psychic5;
begin
main_z80.free;
snd_z80.free;
YM2203_0.Free;
YM2203_1.Free;
close_audio;
close_video;
end;

procedure reset_psychic5;
begin
 main_z80.reset;
 snd_z80.reset;
 YM2203_0.reset;
 YM2203_1.reset;
 reset_audio;
 marcade.in0:=$FF;
 marcade.in1:=$FF;
 banco_rom:=0;
 banco_vram:=0;
 paleta_gris:=false;
 sound_latch:=0;
 title_screen:=false;
 bg_clip_mode:=0;
 sy1:=0;
 sy2:=0;
 sx1:=0;
end;

procedure update_video_psychic5;inline;
var
  f,color,nchar,x,y,clip_x,clip_y,clip_w,clip_h:word;
  attr,flip_x,spr1,spr2,spr3,spr4,sy1_old,sx1_old,sy2_old:byte;
  scroll_x,scroll_y:word;
begin
//fondo
if (io_ram[$30c] and 1)<>0 then begin  //fondo activo?
  scroll_y:=768-(io_ram[$308] or ((io_ram[$309] and $3) shl 8));
  scroll_x:=io_ram[$30a] or ((io_ram[$30b] and 1) shl 8);
  for f:=0 to $7ff do begin
   attr:=bg_ram[1+(f shl 1)];
   color:=attr and $f;
   if (gfx[2].buffer[f] or buffer_color[color+$10]) then begin
    x:=(f and $1f) shl 4;
    y:=(63-(f shr 5)) shl 4;
    if paleta_gris then color:=(color shl 4)+$300
      else color:=(color shl 4)+$100;
    nchar:=bg_ram[(f shl 1)]+((attr and $c0) shl 2);
    put_gfx_flip(x,y,nchar,color,3,2,(attr and $20)<>0,(attr and $10)<>0);
    gfx[2].buffer[f]:=false;
   end;
  end;
  if not(title_screen) then begin
      scroll_x_y(3,4,scroll_x,scroll_y);
      bg_clip_mode:=0;
		  sx1:=0;
      sy1:=0;
      sy2:=0;
  end else begin
      clip_x:=0;
      clip_y:=0;
      clip_w:=256;
      clip_h:=256;
      sy1_old:=sy1;
		  sx1_old:=sx1;
		  sy2_old:=sy2;
  		sy1:=memoria[$f200+11];		// sprite 0
  		sx1:=memoria[$f200+12];
  		sy2:=memoria[$f200+11+128];	// sprite 8
  		case bg_clip_mode of
        0,4:if (sy1_old<>sy1) then bg_clip_mode:=bg_clip_mode+1;
        2,6:if (sy2_old<>sy2) then bg_clip_mode:=bg_clip_mode+1;
		    8,10,12,14:if (sx1_old<>sx1) then bg_clip_mode:=bg_clip_mode+1;
		    1,5:if (sy1=$f0) then bg_clip_mode:=bg_clip_mode+1;
		    3,7:if (sy2=$f0) then bg_clip_mode:=bg_clip_mode+1;
		    9,11:if (sx1=$f0) then bg_clip_mode:=bg_clip_mode+1;
		    13,15:if (sx1_old=$f0) then bg_clip_mode:=bg_clip_mode+1;
		    16:if (sy1<>$00) then bg_clip_mode:=0;
		  end;
      case (bg_clip_mode) of
        0,4,8,12,16:begin
        		clip_x:=0;
            clip_y:=0;
            clip_w:=0;
            clip_h:=0;
			  end;
		    1:clip_y:=sy1;
        3:clip_h:=sy2;
		    5:clip_h:=sy1;
		    7:clip_y:=sy2;
		    9,15:clip_x:=sx1;
		    11,13:clip_w:=sx1;
		  end;
      fill_full_screen(4,0);
      actualiza_trozo(scroll_x+clip_y,scroll_y+clip_x,clip_h,clip_w,3,clip_y,clip_x,clip_h,clip_w,4);
  end;
end else fill_full_screen(4,0);
//sprites
if not(title_screen) then begin
 for f:=0 to $44 do begin
    attr:=memoria[$f20d+(f shl 4)];
    flip_x:=(attr and $20) shr 5;
    spr1:=0 xor flip_x;
    spr2:=1 xor flip_x;
    spr3:=2 xor flip_x;
    spr4:=3 xor flip_x;
    nchar:=memoria[$f20e+(f shl 4)]+((attr and $c0) shl 2);
    color:=(memoria[$f20f+(f shl 4)] and $f) shl 4;
    x:=memoria[$f20b+(f shl 4)]+((attr and 4) shl 6);
    y:=(256-(memoria[$f20c+(f shl 4)]+16))+((attr and 1) shl 8);
    if (attr and 8)<>0 then begin //Sprites grandes
      put_gfx_sprite(nchar+spr1,color,(attr and $20)<>0,(attr and $10)<>0,1);
      actualiza_gfx_sprite(x,y,4,1);
      put_gfx_sprite(nchar+spr2,color,(attr and $20)<>0,(attr and $10)<>0,1);
      actualiza_gfx_sprite(x+16,y,4,1);
      put_gfx_sprite(nchar+spr3,color,(attr and $20)<>0,(attr and $10)<>0,1);
      actualiza_gfx_sprite(x,y-16,4,1);
      put_gfx_sprite(nchar+spr4,color,(attr and $20)<>0,(attr and $10)<>0,1);
      actualiza_gfx_sprite(x+16,y-16,4,1);
    end else begin
      put_gfx_sprite(nchar,color,(attr and $20)<>0,(attr and $10)<>0,1);
      actualiza_gfx_sprite(x,y,4,1);
    end;
 end;
end;
//chars
for f:=0 to $3ff do begin
  attr:=char_ram[1+(f shl 1)];
  color:=attr and $f;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
    x:=(f and $1f) shl 3;
    y:=(31-(f shr 5)) shl 3;
    nchar:=char_ram[f shl 1]+((attr and $c0) shl 2);
    put_gfx_trans_flip(x,y,nchar,(color shl 4)+$200,1,0,(attr and $20)<>0,(attr and $10)<>0);
    gfx[0].buffer[f]:=false;
  end;
end;
actualiza_trozo(0,0,256,256,1,0,0,256,256,4);
actualiza_trozo_final(16,0,224,256,4);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure eventos_psychic5;
begin
if event.arcade then begin
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $F7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
end;
end;

procedure psychic5_principal;
var
  f:byte;
  frame_m,frame_s:single;
begin
init_controls(false,false,false,true);
frame_m:=main_z80.tframes;
frame_s:=snd_z80.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
    //Main CPU
    main_z80.run(frame_m);
    frame_m:=frame_m+main_z80.tframes-main_z80.contador;
    //Sound CPU
    snd_z80.run(frame_s);
    frame_s:=frame_s+snd_z80.tframes-snd_z80.contador;
    case f of
      0:begin //rst 10
          main_z80.im0:=$d7 ;
          main_z80.pedir_irq:=HOLD_LINE;
        end;
      $40:begin //rst 8
         main_z80.im0:=$cf;
         main_z80.pedir_irq:=HOLD_LINE;
        end;
    end;
  end;
  update_video_psychic5;
  eventos_psychic5;
  video_sync;
end;
end;

function ram_paginada_r(direccion:word):byte;inline;
var
  val:byte;
begin
	if (banco_vram=0) then begin
    case direccion of
      0..$fff:val:=bg_ram[direccion];
      $1000..$1fff:val:=dummy_ram[direccion and $fff];
    end;
	end else begin
			case direccion of
				$0:val:=marcade.in0;
				$1:val:=marcade.in1;
				$2:val:=marcade.in2;
				$3:val:=$1+$8+$20+$c0;
				$4:val:=$1+$e0+$18;
				$5..$fff:val:=io_ram[direccion];
        $1000..$1fff:val:=char_ram[direccion and $fff];
			end;
	end;
ram_paginada_r:=val;
end;

procedure cambiar_color(pos:word);inline;
var
	valor:byte;
  color,color_g:tcolor;
begin
valor:=buffer_paleta[pos];
color.r:=pal4bit(valor shr 4);
color.g:=pal4bit(valor);
valor:=buffer_paleta[pos+1];
color.b:=pal4bit(valor shr 4);
//val:=(palette_ram[offset or 1] and $0f) and $0f ;
//a:=(val shl 4) or val;
//jal_blend_table[pos]:=a;
pos:=pos shr 1;
set_pal_color(color,pos);
case pos of
  $200..$2ff:buffer_color[(pos shr 4) and $f]:=true;
  $100..$1ff:begin
    //Paleta gris
    valor:=(color.r+color.g+color.b) div 3;
    color_g.r:=valor;
    color_g.g:=valor;
    color_g.b:=valor;
    //con intensidad?
    {if (ix<>0) then begin
      ir:=palette_ram[$1fe] shr 4;
      ir:=(ir shl 4) or ir;
      ig:=palette_ram[$1fe] and 15;
      ig:=(ig shl 4) or ig;
      ib:=palette_ram[$1ff] shr 4;
      ib:=(ib shl 4) or ib;
      //UINT32 result = jal_blend_func(MAKE_RGB(val,val,val), MAKE_RGB(ir, ig, ib), jal_blend_table[0xff]) ;
    end;}
    set_pal_color(color_g,pos+512);
    buffer_color[((pos shr 4) and $f)+$10]:=true;
    end
end;
end;

procedure ram_paginada_w(direccion:word;valor:byte);inline;
begin
if (banco_vram=0) then begin
		case direccion of
      0..$fff:if bg_ram[direccion]<>valor then begin
                bg_ram[direccion]:=valor;
                gfx[2].buffer[direccion shr 1]:=true;
              end;
		  $1000..$1fff:dummy_ram[direccion and $fff]:=valor;
    end;
end else begin
  case direccion of
		$0..$fff:begin
                io_ram[direccion]:=valor;
                if paleta_gris<>((io_ram[$30c] and 2)<>0) then begin
                  paleta_gris:=(io_ram[$30c] and 2)<>0;
                  fillchar(gfx[2].buffer[0],$800,1);
                end;
                case direccion of
                  $400..$5ff:if buffer_paleta[direccion and $1ff]<>valor then begin
                                buffer_paleta[direccion and $1ff]:=valor;
                                cambiar_color(direccion and $1fe);
                             end;
                  $800..$9ff:if buffer_paleta[(direccion and $1ff)+$200]<>valor then begin
                                buffer_paleta[(direccion and $1ff)+$200]:=valor;
                                cambiar_color((direccion and $1fe)+$200);
                             end;
                  $a00..$bff:if buffer_paleta[(direccion and $1ff)+$400]<>valor then begin
                                buffer_paleta[(direccion and $1ff)+$400]:=valor;
                                cambiar_color((direccion and $1fe)+$400);
                             end;
                end;
            end;
    $1000..$1fff:if char_ram[direccion and $fff]<>valor then begin
                  char_ram[direccion and $fff]:=valor;
                  gfx[0].buffer[(direccion and $fff) shr 1]:=true;
              end;
  end;
end;
end;

function psychic5_getbyte(direccion:word):byte;
begin
case direccion of
 $8000..$bfff:psychic5_getbyte:=mem_rom[banco_rom,direccion and $3fff];
 $c000..$dfff:psychic5_getbyte:=ram_paginada_r(direccion and $1fff);
 $f002:psychic5_getbyte:=banco_rom;
 $f003:psychic5_getbyte:=banco_vram;
 else psychic5_getbyte:=memoria[direccion];
end;
end;

procedure psychic5_putbyte(direccion:word;valor:byte);
begin
if direccion<$c000 then exit;
memoria[direccion]:=valor;
case direccion of
        $c000..$dfff:ram_paginada_w(direccion and $1fff,valor);
        $f000:sound_latch:=valor;
        $f002:banco_rom:=valor and $3;
        $f003:banco_vram:=valor;
        $f005:title_screen:=(valor<>0);
end;
end;

function psychic5_snd_getbyte(direccion:word):byte;
begin
case direccion of
  $e000:psychic5_snd_getbyte:=sound_latch;
  else psychic5_snd_getbyte:=mem_snd[direccion];
end;
end;

procedure psychic5_snd_putbyte(direccion:word;valor:byte);
begin
if direccion<$8000 then exit;
mem_snd[direccion]:=valor;
end;

procedure psychic5_outbyte(valor:byte;puerto:word);
begin
case (puerto and $FF) of
  0:ym2203_0.control(valor);
  1:ym2203_0.write_reg(valor);
  $80:ym2203_1.control(valor);
  $81:ym2203_1.write_reg(valor);
end;
end;

procedure psychic5_sound_update;
begin
  ym2203_0.Update;
  ym2203_1.Update;
end;

procedure snd_irq(irqstate:byte);
begin
  if (irqstate=1) then snd_z80.pedir_irq:=ASSERT_LINE
    else snd_z80.pedir_irq:=CLEAR_LINE;
end;

procedure psychic5_qsave(nombre:string);
var
  data:pbyte;
  buffer:array[0..8] of byte;
  size:word;
begin
open_qsnapshot_save('psychic5'+nombre);
getmem(data,20000);
//CPU
size:=main_z80.save_snapshot(data);
savedata_qsnapshot(data,size);
size:=snd_z80.save_snapshot(data);
savedata_qsnapshot(data,size);
//SND
size:=ym2203_0.save_snapshot(data);
savedata_com_qsnapshot(data,size);
size:=ym2203_1.save_snapshot(data);
savedata_com_qsnapshot(data,size);
//MEM
savedata_com_qsnapshot(@memoria[$8000],$8000);
savedata_com_qsnapshot(@mem_snd[$8000],$8000);
//MISC
savedata_com_qsnapshot(@bg_ram[0],$1000);
savedata_com_qsnapshot(@char_ram[0],$1000);
savedata_com_qsnapshot(@dummy_ram[0],$1000);
savedata_com_qsnapshot(@io_ram[0],$1000);
buffer[0]:=banco_rom;
buffer[1]:=banco_vram;
buffer[2]:=byte(title_screen);
buffer[3]:=byte(paleta_gris);
buffer[4]:=sound_latch;
buffer[5]:=bg_clip_mode;
buffer[6]:=sy1;
buffer[7]:=sy2;
buffer[8]:=sx1;
savedata_qsnapshot(@buffer[0],9);
savedata_com_qsnapshot(@buffer_paleta[0],$600*2);
freemem(data);
close_qsnapshot;
end;

procedure psychic5_qload(nombre:string);
var
  data:pbyte;
  buffer:array[0..8] of byte;
  f:word;
begin
if not(open_qsnapshot_load('psychic5'+nombre)) then exit;
getmem(data,20000);
//CPU
loaddata_qsnapshot(data);
main_z80.load_snapshot(data);
loaddata_qsnapshot(data);
snd_z80.load_snapshot(data);
//SND
loaddata_qsnapshot(data);
ym2203_0.load_snapshot(data);
loaddata_qsnapshot(data);
ym2203_1.load_snapshot(data);
//MEM
loaddata_qsnapshot(@memoria[$8000]);
loaddata_qsnapshot(@mem_snd[$8000]);
//MISC
loaddata_qsnapshot(@bg_ram[0]);
loaddata_qsnapshot(@char_ram[0]);
loaddata_qsnapshot(@dummy_ram[0]);
loaddata_qsnapshot(@io_ram[0]);
loaddata_qsnapshot(@buffer[0]);
banco_rom:=buffer[0];
banco_vram:=buffer[1];
title_screen:=buffer[2]<>0;
paleta_gris:=buffer[3]<>0;
sound_latch:=buffer[4];
bg_clip_mode:=buffer[5];
sy1:=buffer[6];
sy2:=buffer[7];
sx1:=buffer[8];
loaddata_qsnapshot(@buffer_paleta[0]);
freemem(data);
close_qsnapshot;
//END
for f:=0 to $2ff do cambiar_color(f*2);
end;

end.
