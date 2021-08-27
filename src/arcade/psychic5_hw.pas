unit psychic5_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,ym_2203,gfx_engine,rom_engine,pal_engine,
     sound_engine,qsnapshot;

procedure cargar_psychic5;

implementation
const
        psychic5_rom:array[0..1] of tipo_roms=(
        (n:'myp5d';l:$8000;p:0;crc:$1d40a8c7),(n:'myp5e';l:$10000;p:$8000;crc:$2fa7e8c0));
        psychic5_snd_rom:tipo_roms=(n:'myp5a';l:$10000;p:0;crc:$6efee094);
        psychic5_char:tipo_roms=(n:'p5f';l:$8000;p:0;crc:$04d7e21c);
        psychic5_sprites:array[0..1] of tipo_roms=(
        (n:'p5b';l:$10000;p:0;crc:$7e3f87d4),(n:'p5c';l:$10000;p:$10000;crc:$8710fedb));
        psychic5_tiles:array[0..1] of tipo_roms=(
        (n:'myp5g';l:$10000;p:0;crc:$617b074b),(n:'myp5h';l:$10000;p:$10000;crc:$a9dfbe67));
        //Dip
        psychic5_dip_a:array [0..5] of def_dip=(
        (mask:$1;name:'Flip Screen';number:2;dip:((dip_val:$1;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Difficulty';number:2;dip:((dip_val:$8;dip_name:'Normal'),(dip_val:$0;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$10;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$20;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Lives';number:4;dip:((dip_val:$80;dip_name:'2'),(dip_val:$c0;dip_name:'3'),(dip_val:$40;dip_name:'4'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),());
        psychic5_dip_b:array [0..3] of def_dip=(
        (mask:$1;name:'Invulnerability';number:2;dip:((dip_val:$1;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$e0;name:'Coin A';number:8;dip:((dip_val:$0;dip_name:'5C 1C'),(dip_val:$20;dip_name:'4C 1C'),(dip_val:$40;dip_name:'3C 1C'),(dip_val:$60;dip_name:'2C 1C'),(dip_val:$e0;dip_name:'1C 1C'),(dip_val:$c0;dip_name:'1C 2C'),(dip_val:$a0;dip_name:'1C 3C'),(dip_val:$80;dip_name:'1C 4C'),(),(),(),(),(),(),(),())),
        (mask:$1c;name:'Coin B';number:8;dip:((dip_val:$0;dip_name:'5C 1C'),(dip_val:$4;dip_name:'4C 1C'),(dip_val:$8;dip_name:'3C 1C'),(dip_val:$c;dip_name:'2C 1C'),(dip_val:$1c;dip_name:'1C 1C'),(dip_val:$18;dip_name:'1C 2C'),(dip_val:$14;dip_name:'1C 3C'),(dip_val:$10;dip_name:'1C 4C'),(),(),(),(),(),(),(),())),());

var
 mem_rom:array[0..3,0..$3fff] of byte;
 mem_ram:array[0..2,0..$fff] of byte;
 bg_clip_mode,banco_rom,banco_vram,sound_latch,bg_control:byte;
 title_screen:boolean;
 scroll_x,scroll_y,sy1,sy2,sx1:word;

procedure update_video_psychic5;
var
  f,color,nchar,x,y,clip_x,clip_y,clip_w,clip_h:word;
  attr,flip_x,spr1,spr2,spr3,spr4,sy1_old,sx1_old,sy2_old:byte;
begin
//fondo
if (bg_control and 1)<>0 then begin  //fondo activo?
  for f:=0 to $7ff do begin
   attr:=mem_ram[0,1+(f shl 1)];
   color:=attr and $f;
   if (gfx[2].buffer[f] or buffer_color[color+$10]) then begin
      x:=(f and $1f) shl 4;
      y:=(63-(f shr 5)) shl 4;
      color:=(color shl 4)+$100+((bg_control and 2) shl 8);
      nchar:=mem_ram[0,(f shl 1)]+((attr and $c0) shl 2);
      put_gfx_flip(x,y,nchar,color,3,2,(attr and $20)<>0,(attr and $10)<>0);
      gfx[2].buffer[f]:=false;
   end;
  end;
  if not(title_screen) then begin
      scroll_x_y(3,4,scroll_x,768-scroll_y);
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
      case bg_clip_mode of
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
      actualiza_trozo((scroll_x+clip_y) and $1ff,((768-scroll_y)+clip_x) and $3ff,clip_h,clip_w,3,clip_y,clip_x,clip_h,clip_w,4);
  end;
end else fill_full_screen(4,0);
//sprites
if not(title_screen) then begin
 for f:=0 to $5f do begin
    attr:=memoria[$f20d+(f*16)];
    flip_x:=(attr and $20) shr 5;
    nchar:=memoria[$f20e+(f*16)]+((attr and $c0) shl 2);
    color:=(memoria[$f20f+(f*16)] and $f) shl 4;
    x:=memoria[$f20b+(f*16)]+((attr and 4) shl 6);
    y:=(256-(memoria[$f20c+(f*16)]+16))+((attr and 1) shl 8);
    if (attr and 8)<>0 then begin //Sprites grandes
      spr1:=0 xor flip_x;
      spr2:=1 xor flip_x;
      spr3:=2 xor flip_x;
      spr4:=3 xor flip_x;
      put_gfx_sprite_diff(nchar+spr1,color,(attr and $20)<>0,(attr and $10)<>0,1,0,16);
      put_gfx_sprite_diff(nchar+spr2,color,(attr and $20)<>0,(attr and $10)<>0,1,16,16);
      put_gfx_sprite_diff(nchar+spr3,color,(attr and $20)<>0,(attr and $10)<>0,1,0,0);
      put_gfx_sprite_diff(nchar+spr4,color,(attr and $20)<>0,(attr and $10)<>0,1,16,0);
      actualiza_gfx_sprite_size(x,y-16,4,32,32);
    end else begin
      put_gfx_sprite(nchar,color,(attr and $20)<>0,(attr and $10)<>0,1);
      actualiza_gfx_sprite(x,y,4,1);
    end;
 end;
end;
//chars
for f:=0 to $3ff do begin
  attr:=mem_ram[1,1+(f shl 1)];
  color:=attr and $f;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
    x:=(f and $1f) shl 3;
    y:=(31-(f shr 5)) shl 3;
    nchar:=mem_ram[1,f shl 1]+((attr and $c0) shl 2);
    put_gfx_trans_flip(x,y,nchar,(color shl 4)+$200,1,0,(attr and $20)<>0,(attr and $10)<>0);
    gfx[0].buffer[f]:=false;
  end;
end;
actualiza_trozo(0,0,256,256,1,0,0,256,256,4);
actualiza_trozo_final(16,0,224,256,4);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
end;

procedure eventos_psychic5;
begin
if event.arcade then begin
  //P1
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  //P2
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  //SYSTEM
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
frame_m:=z80_0.tframes;
frame_s:=z80_1.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
    //Main CPU
    z80_0.run(frame_m);
    frame_m:=frame_m+z80_0.tframes-z80_0.contador;
    //Sound CPU
    z80_1.run(frame_s);
    frame_s:=frame_s+z80_1.tframes-z80_1.contador;
    case f of
      $0:begin //rst 8
         z80_0.im0:=$cf;
         z80_0.change_irq(HOLD_LINE);
        end;
      239:begin //rst 10
          z80_0.im0:=$d7 ;
          z80_0.change_irq(HOLD_LINE);
          update_video_psychic5;
        end;
    end;
  end;
  eventos_psychic5;
  video_sync;
end;
end;

function ram_paginada_r(direccion:word):byte;inline;
begin
  case (direccion+((banco_vram and 1) shl 13)) of
      0..$fff:ram_paginada_r:=mem_ram[0,direccion];
      $1000..$1fff:ram_paginada_r:=mem_ram[2,direccion and $fff];
      $2000:ram_paginada_r:=marcade.in0;
      $2001:ram_paginada_r:=marcade.in1;
      $2002:ram_paginada_r:=marcade.in2;
      $2003:ram_paginada_r:=marcade.dswa;
      $2004:ram_paginada_r:=marcade.dswb;
      $230c:ram_paginada_r:=bg_control;
      $2400..$25ff:ram_paginada_r:=buffer_paleta[direccion and $1ff];
      $2800..$29ff:ram_paginada_r:=buffer_paleta[(direccion and $1ff)+$200];
      $2a00..$2bff:ram_paginada_r:=buffer_paleta[(direccion and $1ff)+$400];
      $3000..$3fff:ram_paginada_r:=mem_ram[1,direccion and $fff];
  end;
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
case (direccion+((banco_vram and 1) shl 13)) of
    0..$fff:if mem_ram[0,direccion]<>valor then begin
                mem_ram[0,direccion]:=valor;
                gfx[2].buffer[direccion shr 1]:=true;
              end;
		$1000..$1fff:mem_ram[2,direccion and $fff]:=valor;
    $2308:scroll_y:=valor or (scroll_y and $300);
    $2309:scroll_y:=(scroll_y and $ff) or ((valor and $3) shl 8);
    $230a:scroll_x:=valor or (scroll_x and $100);
    $230b:scroll_x:=(scroll_x and $ff) or ((valor and 1) shl 8);
    $230c:begin
            if (bg_control and 2)<>(valor and 2) then fillchar(gfx[2].buffer[0],$800,1);
            bg_control:=valor;
          end;
    $2400..$25ff:if buffer_paleta[direccion and $1ff]<>valor then begin
                    buffer_paleta[direccion and $1ff]:=valor;
                    cambiar_color(direccion and $1fe);
                 end;
    $2800..$29ff:if buffer_paleta[(direccion and $1ff)+$200]<>valor then begin
                    buffer_paleta[(direccion and $1ff)+$200]:=valor;
                    cambiar_color((direccion and $1fe)+$200);
                 end;
    $2a00..$2bff:if buffer_paleta[(direccion and $1ff)+$400]<>valor then begin
                    buffer_paleta[(direccion and $1ff)+$400]:=valor;
                    cambiar_color((direccion and $1fe)+$400);
                 end;
    $3000..$3fff:if mem_ram[1,direccion and $fff]<>valor then begin
                  mem_ram[1,direccion and $fff]:=valor;
                  gfx[0].buffer[(direccion and $fff) shr 1]:=true;
              end;
  end;
end;

function psychic5_getbyte(direccion:word):byte;
begin
case direccion of
 0..$7fff,$e000..$efff,$f200..$ffff:psychic5_getbyte:=memoria[direccion];
 $8000..$bfff:psychic5_getbyte:=mem_rom[banco_rom and 3,direccion and $3fff];
 $c000..$dfff:psychic5_getbyte:=ram_paginada_r(direccion and $1fff);
 $f002:psychic5_getbyte:=banco_rom;
 $f003:psychic5_getbyte:=banco_vram;
end;
end;

procedure psychic5_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$bfff:;
  $c000..$dfff:ram_paginada_w(direccion and $1fff,valor);
  $e000..$efff,$f200..$ffff:memoria[direccion]:=valor;
  $f000:sound_latch:=valor;
  $f001:main_screen.flip_main_screen:=(valor and $80)<>0;
  $f002:banco_rom:=valor;
  $f003:banco_vram:=valor;
  $f005:title_screen:=(valor<>0);
end;
end;

function psychic5_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff,$c000..$c7ff:psychic5_snd_getbyte:=mem_snd[direccion];
  $e000:psychic5_snd_getbyte:=sound_latch;
end;
end;

procedure psychic5_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:;
  $c000..$c7ff:mem_snd[direccion]:=valor;
end;
end;

procedure psychic5_outbyte(puerto:word;valor:byte);
begin
case (puerto and $ff) of
  0:ym2203_0.control(valor);
  1:ym2203_0.write(valor);
  $80:ym2203_1.control(valor);
  $81:ym2203_1.write(valor);
end;
end;

procedure psychic5_sound_update;
begin
  ym2203_0.Update;
  ym2203_1.Update;
end;

procedure snd_irq(irqstate:byte);
begin
  z80_1.change_irq(irqstate);
end;

procedure psychic5_qsave(nombre:string);
var
  data:pbyte;
  buffer:array[0..4] of byte;
  size:word;
begin
open_qsnapshot_save('psychic5'+nombre);
getmem(data,20000);
//CPU
size:=z80_0.save_snapshot(data);
savedata_qsnapshot(data,size);
size:=z80_1.save_snapshot(data);
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
savedata_com_qsnapshot(@mem_ram[0,0],$1000);
savedata_com_qsnapshot(@mem_ram[1,0],$1000);
savedata_com_qsnapshot(@mem_ram[2,0],$1000);
buffer[0]:=banco_rom;
buffer[1]:=banco_vram;
buffer[2]:=byte(title_screen);
buffer[3]:=sound_latch;
buffer[4]:=bg_control;
savedata_qsnapshot(@buffer,5);
savedata_com_qsnapshot(@buffer_paleta,$600*2);
freemem(data);
close_qsnapshot;
end;

procedure psychic5_qload(nombre:string);
var
  data:pbyte;
  buffer:array[0..4] of byte;
  f:word;
begin
if not(open_qsnapshot_load('psychic5'+nombre)) then exit;
getmem(data,20000);
//CPU
loaddata_qsnapshot(data);
z80_0.load_snapshot(data);
loaddata_qsnapshot(data);
z80_1.load_snapshot(data);
//SND
loaddata_qsnapshot(data);
ym2203_0.load_snapshot(data);
loaddata_qsnapshot(data);
ym2203_1.load_snapshot(data);
//MEM
loaddata_qsnapshot(@memoria[$8000]);
loaddata_qsnapshot(@mem_snd[$8000]);
//MISC
loaddata_qsnapshot(@mem_ram[0,0]);
loaddata_qsnapshot(@mem_ram[1,0]);
loaddata_qsnapshot(@mem_ram[2,0]);
loaddata_qsnapshot(@buffer[0]);
banco_rom:=buffer[0];
banco_vram:=buffer[1];
title_screen:=buffer[2]<>0;
sound_latch:=buffer[3];
bg_control:=buffer[4];
loaddata_qsnapshot(@buffer_paleta);
freemem(data);
close_qsnapshot;
//END
for f:=0 to $2ff do cambiar_color(f*2);
end;

//Main
procedure reset_psychic5;
begin
 z80_0.reset;
 z80_1.reset;
 YM2203_0.reset;
 YM2203_1.reset;
 reset_audio;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 banco_rom:=0;
 banco_vram:=0;
 sound_latch:=0;
 title_screen:=false;
 bg_control:=0;
 bg_clip_mode:=0;
end;

function iniciar_psychic5:boolean;
var
    f:word;
    memoria_temp:array[0..$1ffff] of byte;
const
    ps_x:array[0..15] of dword=(0, 4, 8, 12, 16, 20, 24, 28,
        64*8, 64*8+4, 64*8+8, 64*8+12, 64*8+16, 64*8+20, 64*8+24, 64*8+28);
    ps_y:array[0..15] of dword=(0*8, 4*8, 8*8, 12*8, 16*8, 20*8, 24*8, 28*8,
        32*8, 36*8, 40*8, 44*8, 48*8, 52*8, 56*8, 60*8);
begin
iniciar_psychic5:=false;
iniciar_audio(false);
screen_init(1,256,256,true);
screen_init(2,512,512,true);
screen_init(3,512,1024);
screen_mod_scroll(3,512,256,511,1024,256,1023);
screen_init(4,512,512,false,true);
iniciar_video(224,256);
//Main CPU
z80_0:=cpu_z80.create(6000000,256);
z80_0.change_ram_calls(psychic5_getbyte,psychic5_putbyte);
//Sound CPU
z80_1:=cpu_z80.create(5000000,256);
z80_1.change_ram_calls(psychic5_snd_getbyte,psychic5_snd_putbyte);
z80_1.change_io_calls(nil,psychic5_outbyte);
z80_1.init_sound(psychic5_sound_update);
//Sound Chips
YM2203_0:=ym2203_chip.create(1500000,1,0.75);
ym2203_0.change_irq_calls(snd_irq);
YM2203_1:=ym2203_chip.create(1500000,1,0.75);
//cargar roms
if not(roms_load(@memoria_temp,psychic5_rom)) then exit;
//Poner las ROMS en sus bancos
copymemory(@memoria,@memoria_temp,$8000);
for f:=0 to 3 do copymemory(@mem_rom[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
//cargar ROMS sonido
if not(roms_load(@mem_snd,psychic5_snd_rom)) then exit;
//convertir chars
if not(roms_load(@memoria_temp,psychic5_char)) then exit;
init_gfx(0,8,8,1024);
gfx[0].trans[15]:=true;
gfx_set_desc_data(4,0,32*8,0,1,2,3);
convert_gfx(0,0,@memoria_temp,@ps_x,@ps_y,false,true);
//convertir sprites
if not(roms_load(@memoria_temp,psychic5_sprites)) then exit;
init_gfx(1,16,16,1024);
gfx[1].trans[15]:=true;
gfx_set_desc_data(4,0,128*8,0,1,2,3);
convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,true);
//convertir tiles
if not(roms_load(@memoria_temp,psychic5_tiles)) then exit;
init_gfx(2,16,16,1024);
convert_gfx(2,0,@memoria_temp,@ps_x,@ps_y,false,true);
//DIP
marcade.dswa:=$ef;
marcade.dswb:=$ff;
marcade.dswa_val:=@psychic5_dip_a;
marcade.dswb_val:=@psychic5_dip_b;
//final
reset_psychic5;
iniciar_psychic5:=true;
end;

procedure Cargar_psychic5;
begin
llamadas_maquina.iniciar:=iniciar_psychic5;
llamadas_maquina.bucle_general:=psychic5_principal;
llamadas_maquina.reset:=reset_psychic5;
llamadas_maquina.fps_max:=54.001512;
llamadas_maquina.save_qsnap:=psychic5_qsave;
llamadas_maquina.load_qsnap:=psychic5_qload;
end;

end.
