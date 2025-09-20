unit wyvernf0_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,gfx_engine,ay_8910,rom_engine,timer_engine,
     pal_engine,sound_engine,taito_68705,dac,msm5232;

function iniciar_wyvernf0:boolean;

implementation
const
        wyvernf0_rom:array[0..5] of tipo_roms=(
        (n:'a39_01-1.ic37';l:$4000;p:0;crc:$a94887ec),(n:'a39_02-1.ic36';l:$4000;p:$4000;crc:$171cfdbe),
        (n:'a39_03.ic35';l:$4000;p:$8000;crc:$50314281),(n:'a39_04.ic34';l:$4000;p:$c000;crc:$7a225bf9),
        (n:'a39_05.ic33';l:$4000;p:$10000;crc:$41f21a67),(n:'a39_06.ic32';l:$4000;p:$14000;crc:$deb2d850));
        wyvernf0_snd:tipo_roms=(n:'a39_16.ic26';l:$4000;p:0;crc:$5a681fb4);
        wyvernf0_mcu:tipo_roms=(n:'a39_mc68705p5s.ic23';l:$800;p:0;crc:$14bff574);
        wyvernf0_chars:array[0..3] of tipo_roms=(
        (n:'a39_15.ic99';l:$2000;p:0;crc:$90a66147),(n:'a39_14.ic73';l:$2000;p:$2000;crc:$a31f3507),
        (n:'a39_13.ic100';l:$2000;p:$4000;crc:$be708238),(n:'a39_12.ic74';l:$2000;p:$6000;crc:$1cc389de));
        wyvernf0_sprites:array[0..3] of tipo_roms=(
        (n:'a39_11.ic99';l:$4000;p:0;crc:$af70e1dc),(n:'a39_10.ic78';l:$4000;p:$4000;crc:$a84380fb),
        (n:'a39_09.ic96';l:$4000;p:$8000;crc:$c0cee243),(n:'a39_08.ic75';l:$4000;p:$c000;crc:$0ad69501));
        //Dip
        wyvernf0_dip_a:array [0..4] of def_dip2=(
        (mask:3;name:'Bonus Life';number:4;val4:(0,1,2,3);name4:('0','1','2','3')),
        (mask:4;name:'Free Play';number:2;val2:(4,0);name2:('Off','On')),
        (mask:$18;name:'Lives';number:4;val4:(0,8,$10,$18);name4:('2','3','4','5')),
        (mask:$40;name:'Flip Screen';number:2;val2:($40,0);name2:('Off','On')),
        (mask:$80;name:'Cabinet';number:2;val2:(0,$80);name2:('Upright','Cocktail')));
        wyvernf0_dip_b:array [0..1] of def_dip2=(
        (mask:$f;name:'Coin A';number:16;val16:($f,$e,$d,$c,$b,$a,9,8,0,1,2,3,4,5,6,7);name16:('9C 1C','8C 1C','7C 1C','6C 1C','5C 1C','4C 1C','3C 1C','2C 1C','1C 1C','1C 2C','1C 3C','1C 4C','1C 5C','1C 6C','1C 7C','1C 8C')),
        (mask:$f0;name:'Coin B';number:16;val16:($f0,$e0,$d0,$c0,$b0,$a0,$90,$80,0,$10,$20,$30,$40,$50,$60,$70);name16:('9C 1C','8C 1C','7C 1C','6C 1C','5C 1C','4C 1C','3C 1C','2C 1C','1C 1C','1C 2C','1C 3C','1C 4C','1C 5C','1C 6C','1C 7C','1C 8C')));
        wyvernf0_dip_c:array [0..4] of def_dip2=(
        (mask:8;name:'Demo Sounds';number:2;val2:(8,0);name2:('Off','On')),
        (mask:$10;name:'Coinage Display';number:2;val2:(0,$10);name2:('No','Yes')),
        (mask:$20;name:'Copyright';number:2;val2:(0,$20);name2:('Taito Corporation','Taito Corp. 1985')),
        (mask:$40;name:'Invulnerability';number:2;val2:($40,0);name2:('Off','On')),
        (mask:$80;name:'Coin Slots';number:2;val2:(0,$80);name2:('1','2')));

var
 memoria_rom:array [0..7,0..$1fff] of byte;
 memoria_ram:array[0..1,0..$fff] of byte;
 banco_ram,banco_rom,sound_latch,scroll_fg_x,scroll_fg_y,scroll_bg_x,scroll_bg_y:byte;
 sound_nmi_ena,sound_nmi_pending:boolean;

procedure update_video_wyvernf0;
procedure draw_sprites(pri:boolean);
var
  f,desp,color,code,x,y,desp_x,desp_y:byte;
  flipx,flipy:boolean;
  sx,sy,nchar_addr,nchar:word;
begin
  if pri then desp:=$80
    else desp:=0;
  for f:=0 to $1f do begin
    sx:=memoria[(f*4)+$d503+desp]-((memoria[(f*4)+$d502+desp] and $80) shl 1);
		sy:=256-8-memoria[(f*4)+$d500+desp]-23;
    flipx:=false;
		flipy:=(memoria[(f*4)+$d501+desp] and $80)<>0;
    code:=memoria[(f*4)+$d501+desp] and $7f;
		color:=memoria[(f*4)+$d502+desp] and $f;
    if pri then begin
			code:=code+$80;
			color:=color+$10;
		end;
    for y:=0 to 3 do begin
			for x:=0 to 3 do begin
				nchar_addr:=code*$20+(x+y*4)*2;
        nchar:=(memoria_ram[0,nchar_addr+1] shl 8)+memoria_ram[0,nchar_addr];
        put_gfx_sprite(nchar,color shl 4,flipx,flipy,1);
        if flipx then desp_x:=3-x
          else desp_x:=x;
        if flipy then desp_y:=3-y
          else desp_y:=y;
        actualiza_gfx_sprite(sx+desp_x*8,sy+desp_y*8,3,1);
			end;
		end;
  end;
end;
var
  f,nchar,atrib:word;
  x,y,color:byte;
begin
for f:=0 to $3ff do begin
  x:=f mod 32;
  y:=f div 32;
  //bg
  atrib:=memoria[$c800+(f*2)]+(memoria[$c801+(f*2)] shl 8);
  color:=(atrib and $3000) shr 12;
  if (gfx[0].buffer[f+$400] or buffer_color[color]) then begin
    nchar:=atrib and $3ff;
    put_gfx_flip(x*8,y*8,nchar,color shl 4,1,0,(atrib and $4000)<>0,(atrib and $8000)<>0);
    gfx[0].buffer[f+$400]:=false;
  end;
  //fg
  atrib:=memoria[$c000+(f*2)]+(memoria[$c001+(f*2)] shl 8);
  color:=(atrib and $3000) shr 12;
  if (gfx[0].buffer[f] or buffer_color[color+$10]) then begin
    nchar:=atrib and $3ff;
    put_gfx_trans_flip(x*8,y*8,nchar,(color shl 4)+$80,2,0,(atrib and $4000)<>0,(atrib and $8000)<>0);
    gfx[0].buffer[f]:=false;
  end;
end;
scroll_x_y(1,3,scroll_bg_x-19,scroll_bg_y);
draw_sprites(false);
draw_sprites(true);
scroll_x_y(2,3,scroll_fg_x-16,scroll_fg_y);
actualiza_trozo_final(0,16,256,224,3);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
end;

procedure eventos_wyvernf0;
begin
if event.arcade then begin
  //P1
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 or 4) else marcade.in1:=(marcade.in1 and $fb);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 or 8) else marcade.in1:=(marcade.in1 and $f7);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 or $10) else marcade.in1:=(marcade.in1 and $ef);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 or $20) else marcade.in1:=(marcade.in1 and $df);
  if arcade_input.but2[0] then marcade.in3:=(marcade.in3 or 8) else marcade.in3:=(marcade.in3 and $f7);
  if arcade_input.but1[0] then marcade.in3:=(marcade.in3 or $10) else marcade.in3:=(marcade.in3 and $ef);
  if arcade_input.but0[0] then marcade.in3:=(marcade.in3 or $20) else marcade.in3:=(marcade.in3 and $df);
  //P2
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 or 4) else marcade.in2:=(marcade.in2 and $fb);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 or 8) else marcade.in2:=(marcade.in2 and $f7);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 or $10) else marcade.in2:=(marcade.in2 and $ef);
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 or $20) else marcade.in2:=(marcade.in2 and $df);
  if arcade_input.but2[1] then marcade.in4:=(marcade.in4 or 8) else marcade.in4:=(marcade.in4 and $f7);
  if arcade_input.but1[1] then marcade.in4:=(marcade.in4 or $10) else marcade.in4:=(marcade.in4 and $ef);
  if arcade_input.but0[1] then marcade.in4:=(marcade.in4 or $20) else marcade.in4:=(marcade.in4 and $df);
  //SYS
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 or 1) else marcade.in0:=(marcade.in0 and $fe);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 or 2) else marcade.in0:=(marcade.in0 and $fd);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 or $10) else marcade.in0:=(marcade.in0 and $ef);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 or $20) else marcade.in0:=(marcade.in0 and $df);
end;
end;

procedure wyvernf0_principal;
var
  f:byte;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
 for f:=0 to 255 do begin
  eventos_wyvernf0;
  if f=240 then begin
    z80_0.change_irq(HOLD_LINE);
    update_video_wyvernf0;
  end;
  //main
  z80_0.run(frame_main);
  frame_main:=frame_main+z80_0.tframes-z80_0.contador;
  //snd
  z80_1.run(frame_snd);
  frame_snd:=frame_snd+z80_1.tframes-z80_1.contador;
  //mcu
  taito_68705_0.run;
 end;
 video_sync;
end;
end;

function wyvernf0_getbyte(direccion:word):byte;
begin
case direccion of
  0..$8fff,$c000..$cfff,$d500..$d5ff:wyvernf0_getbyte:=memoria[direccion];
  $9000..$9fff:wyvernf0_getbyte:=memoria_ram[banco_ram,direccion and $fff];
  $a000..$bfff:wyvernf0_getbyte:=memoria_rom[banco_rom,(direccion and $1fff)];
  $d400:wyvernf0_getbyte:=taito_68705_0.read;
  $d401:wyvernf0_getbyte:=byte(not(taito_68705_0.main_sent)) or (byte(taito_68705_0.mcu_sent) shl 1);
  $d600:wyvernf0_getbyte:=marcade.dswa;
  $d601:wyvernf0_getbyte:=marcade.dswb;
  $d602:wyvernf0_getbyte:=marcade.dswc;
  $d603:wyvernf0_getbyte:=marcade.in0;
  $d604:wyvernf0_getbyte:=marcade.in1;
  $d605:wyvernf0_getbyte:=marcade.in3;
  $d606:wyvernf0_getbyte:=marcade.in2;
  $d607:wyvernf0_getbyte:=marcade.in4;
  $d610:wyvernf0_getbyte:=sound_latch;
  $d800..$dbff:wyvernf0_getbyte:=buffer_paleta[direccion and $3ff];
end;
end;

procedure wyvernf0_putbyte(direccion:word;valor:byte);
procedure cambiar_color(dir:word);
var
  tmp_color:byte;
  color:tcolor;
begin
  tmp_color:=buffer_paleta[dir];
  color.r:=pal4bit(tmp_color);
  tmp_color:=buffer_paleta[1+dir];
  color.g:=pal4bit(tmp_color shr 4);
  color.b:=pal4bit(tmp_color);
  dir:=dir shr 1;
  set_pal_color(color,dir);
  case dir of
    0..$3f:buffer_color[dir shr 4]:=true;
    $80..$bf:buffer_color[((dir shr 4) and 3)+$10]:=true;
  end;
end;
begin
case direccion of
  0..$7fff,$a000..$bfff:;
  $8000..$8fff,$d500..$d5ff:memoria[direccion]:=valor;
  $9000..$9fff:memoria_ram[banco_ram,direccion and $fff]:=valor;
  $c000..$c7ff:if memoria[direccion]<>valor then begin
                  gfx[0].buffer[(direccion and $7ff) shr 1]:=true;
                  memoria[direccion]:=valor;
               end;
  $c800..$cfff:if memoria[direccion]<>valor then begin
                  gfx[0].buffer[((direccion and $7ff) shr 1)+$400]:=true;
                  memoria[direccion]:=valor;
               end;
  $d100:begin
          main_screen.flip_main_x:=(valor and 1)<>0;
          main_screen.flip_main_y:=(valor and 2)<>0;
          banco_ram:=valor shr 7;
        end;
  $d200:banco_rom:=valor and 7;
  $d300:scroll_fg_x:=valor;
  $d301:scroll_fg_y:=valor;
  $d302:scroll_bg_x:=valor;
  $d303:scroll_bg_y:=valor;
  $d400:taito_68705_0.write(valor);
  $d610:begin
          sound_latch:=valor;
          if sound_nmi_ena then z80_1.change_nmi(PULSE_LINE)
            else sound_nmi_pending:=true;
        end;
  $d800..$dbff:if buffer_paleta[direccion and $3ff]<>valor then begin
                  buffer_paleta[direccion and $3ff]:=valor;
                  cambiar_color(direccion and $3fe);
               end;
end;
end;

function wyvernf0_snd_getbyte(direccion:word):byte;
begin
  case direccion of
    0..$3fff,$c000..$c7ff:wyvernf0_snd_getbyte:=mem_snd[direccion];
    $d000:wyvernf0_snd_getbyte:=sound_latch;
  end;
end;

procedure wyvernf0_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$3fff,$e000..$efff:;
  $c000..$c7ff:mem_snd[direccion]:=valor;
  $c800:ay8910_0.control(valor);
  $c801:ay8910_0.write(valor);
  $c802:ay8910_0.control(valor);
  $c803:ay8910_0.write(valor);
  $c900..$c90d:msm5232_0.write(direccion and $f,valor);
  $d000:sound_latch:=valor;
  $d200:begin
          sound_nmi_ena:=true;
          if sound_nmi_pending then begin
            z80_1.change_nmi(PULSE_LINE);
            sound_nmi_pending:=false;
          end;
        end;
  $d400:sound_nmi_ena:=false;
  $d600:dac_0.signed_data8_w(valor);
end;
end;

procedure wyvernf0_sound_update;
begin
  msm5232_0.update;
  ay8910_0.update;
  ay8910_1.update;
  dac_0.update;
end;

procedure snd_irq;
begin
  z80_1.change_irq(HOLD_LINE);
end;

//Main
procedure reset_wyvernf0;
begin
 z80_0.reset;
 z80_1.reset;
 frame_main:=z80_0.tframes;
 frame_snd:=z80_1.tframes;
 taito_68705_0.reset;
 msm5232_0.reset;
 ay8910_0.reset;
 ay8910_1.reset;
 dac_0.reset;
 banco_rom:=0;
 banco_ram:=0;
 sound_nmi_ena:=false;
 sound_nmi_pending:=false;
 marcade.in0:=$c0;
 marcade.in1:=0;
 marcade.in2:=0;
 marcade.in3:=0;
 marcade.in4:=0;
 sound_latch:=0;
 scroll_fg_x:=0;
 scroll_fg_y:=0;
 scroll_bg_x:=0;
 scroll_bg_y:=0;
end;

function iniciar_wyvernf0:boolean;
var
  f:byte;
  memoria_temp:array[0..$1ffff] of byte;
const
  pc_x:array[0..7] of dword=(7, 6, 5, 4, 3, 2, 1, 0);
  pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
begin
llamadas_maquina.bucle_general:=wyvernf0_principal;
llamadas_maquina.reset:=reset_wyvernf0;
llamadas_maquina.scanlines:=255;
iniciar_wyvernf0:=false;
iniciar_audio(false);
screen_init(1,256,256,true,false);
screen_init(2,256,256,true,false);
screen_init(3,512,512,false,true);
main_screen.rot270_screen:=true;
iniciar_video(256,224);
//Main CPU
z80_0:=cpu_z80.create(48000000 div 8);
z80_0.change_ram_calls(wyvernf0_getbyte,wyvernf0_putbyte);
if not(roms_load(@memoria_temp,wyvernf0_rom)) then exit;
copymemory(@memoria,@memoria_temp,$8000);
for f:=0 to 7 do copymemory(@memoria_rom[f,0],@memoria_temp[$8000+(f*$2000)],$2000);
//Sound CPU
z80_1:=cpu_z80.create(4000000);
z80_1.change_ram_calls(wyvernf0_snd_getbyte,wyvernf0_snd_putbyte);
z80_1.init_sound(wyvernf0_sound_update);
if not(roms_load(@mem_snd,wyvernf0_snd)) then exit;
fillchar(mem_snd[$e000],$2000,$ff);
timers.init(z80_1.numero_cpu,4000000/180,snd_irq,nil,true);
//MCU
taito_68705_0:=taito_68705p.create(3000000);
if not(roms_load(taito_68705_0.get_rom_addr,wyvernf0_mcu)) then exit;
//Sound chips
msm5232_0:=msm5232_chip.create(2000000,4);
msm5232_0.set_capacitors(1e-6,1e-6,1e-6,1e-6,1e-6,1e-6,1e-6,1e-6);
ay8910_0:=ay8910_chip.create(2000000,AY8910);
ay8910_1:=ay8910_chip.create(2000000,AY8910);
dac_0:=dac_chip.create;
//chars
if not(roms_load(@memoria_temp,wyvernf0_chars)) then exit;
init_gfx(0,8,8,$400);
gfx[0].trans[0]:=true;
gfx_set_desc_data(4,0,8*8,$400*8*8*0,$400*8*8*1,$400*8*8*2,$400*8*8*3);
convert_gfx(0,0,@memoria_temp,@pc_x,@pc_y,false,false);
//sprites
if not(roms_load(@memoria_temp,wyvernf0_sprites)) then exit;
init_gfx(1,8,8,$800);
gfx[1].trans[0]:=true;
gfx_set_desc_data(4,0,8*8,$800*8*8*0,$800*8*8*1,$800*8*8*2,$800*8*8*3);
convert_gfx(1,0,@memoria_temp,@pc_x,@pc_y,false,false);
//DIP
init_dips(1,wyvernf0_dip_a,$6f);
init_dips(2,wyvernf0_dip_b,0);
init_dips(3,wyvernf0_dip_c,$d4);
//final
iniciar_wyvernf0:=true;
end;

end.
