unit bubblebobble_hw;
interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,gfx_engine,ym_2203,ym_3812,
     m680x,rom_engine,pal_engine,sound_engine;

function iniciar_bublbobl:boolean;

implementation
const
        bublbobl_rom:array[0..1] of tipo_roms=(
        (n:'a78-06-1.51';l:$8000;p:0;crc:$567934b6),(n:'a78-05-1.52';l:$10000;p:$8000;crc:$9f8ee242));
        bublbobl_rom2:tipo_roms=(n:'a78-08.37';l:$8000;p:0;crc:$ae11a07b);
        bublbobl_chars:array[0..11] of tipo_roms=(
        (n:'a78-09.12';l:$8000;p:0;crc:$20358c22),(n:'a78-10.13';l:$8000;p:$8000;crc:$930168a9),
        (n:'a78-11.14';l:$8000;p:$10000;crc:$9773e512),(n:'a78-12.15';l:$8000;p:$18000;crc:$d045549b),
        (n:'a78-13.16';l:$8000;p:$20000;crc:$d0af35c5),(n:'a78-14.17';l:$8000;p:$28000;crc:$7b5369a8),
        (n:'a78-15.30';l:$8000;p:$40000;crc:$6b61a413),(n:'a78-16.31';l:$8000;p:$48000;crc:$b5492d97),
        (n:'a78-17.32';l:$8000;p:$50000;crc:$d69762d5),(n:'a78-18.33';l:$8000;p:$58000;crc:$9f243b68),
        (n:'a78-19.34';l:$8000;p:$60000;crc:$66e9438c),(n:'a78-20.35';l:$8000;p:$68000;crc:$9ef863ad));
        bublbobl_snd:tipo_roms=(n:'a78-07.46';l:$8000;p:0;crc:$4f9a26e8);
        bublbobl_prom:tipo_roms=(n:'a71-25.41';l:$100;p:0;crc:$2d0f8545);
        bublbobl_mcu_rom:tipo_roms=(n:'a78-01.17';l:$1000;p:0;crc:$b1bfb53d);
        //Dip
        bublbobl_dip_a:array [0..5] of def_dip2=(
        (mask:2;name:'Flip Screen';number:2;val2:(2,0);name2:('Off','On')),
        (mask:5;name:'Mode';number:4;val4:(4,5,1,0);name4:('Game - English','Game - Japanese','Test (Grid and Inputs)','Test (RAM and Sound)/Pause')),
        (mask:8;name:'Demo Sounds';number:2;val2:(0,8);name2:('Off','On')),
        (mask:$30;name:'Coin A';number:4;val4:($10,$30,0,$20);name4:('2C 1C','1C 1C','2C 3C','1C 2C')),
        (mask:$c0;name:'Coin B';number:4;val4:($40,$c0,0,$80);name4:('2C 1C','1C 1C','2C 3C','1C 2C')),());
        bublbobl_dip_b:array [0..4] of def_dip2=(
        (mask:3;name:'Difficulty';number:4;val4:(2,3,1,0);name4:('Easy','Normal','Hard','Very Hard')),
        (mask:$c;name:'Bonus Life';number:4;val4:(8,$c,4,0);name4:('20K 80K 300K','30K 100K 400K','40K 200K 500K','50K 250K 500K')),
        (mask:$30;name:'Lives';number:4;val4:($10,0,$30,$20);name4:('1','2','3','5')),
        (mask:$80;name:'ROM Type';number:2;val2:($80,0);name2:('IC52=512kb, IC53=none','IC52=256kb, IC53=256kb')),());

var
 memoria_rom:array [0..3,0..$3fff] of byte;
 mem_prom:array[0..$ff] of byte;
 banco_rom,sound_stat,sound_latch:byte;
 sound_nmi,video_enable:boolean;
 mcu_port3_in,mcu_port1_out,mcu_port2_out,mcu_port3_out,mcu_port4_out:byte;

procedure update_video_bublbobl;
var
    nchar,color,sx,x,goffs,gfx_offs:word;
    flipx,flipy:boolean;
    prom_line,atrib,atrib2,offs,xc,yc,sy,y,gfx_attr,gfx_num:byte;
begin
fill_full_screen(1,$100);
if video_enable then begin
 sx:=0;
 for offs:=0 to $bf do begin
		if ((memoria[$dd00+(offs*4)]=0) and (memoria[$dd01+(offs*4)]=0) and (memoria[$dd02+(offs*4)]=0) and (memoria[$dd03+(offs*4)]=0)) then continue;
		gfx_num:=memoria[$dd01+(offs*4)];
		gfx_attr:=memoria[$dd03+(offs*4)];
		prom_line:=$80+((gfx_num and $e0) shr 1);
		gfx_offs:=(gfx_num and $1f) shl 7;
		if ((gfx_num and $a0)=$a0) then gfx_offs:=gfx_offs or $1000;
		sy:=256-memoria[$dd00+(offs*4)];
		for yc:=0 to $1f do begin
      atrib2:=mem_prom[prom_line+(yc shr 1)];
			if (atrib2 and 8)<>0 then	continue;
			if (atrib2 and 4)=0 then sx:=memoria[$dd02+(offs*4)]+((gfx_attr and $40) shl 2); // next column
			for xc:=0 to 1 do begin
				goffs:=gfx_offs+(xc shl 6)+((yc and 7) shl 1)+((atrib2 and 3) shl 4);
        atrib:=memoria[$c001+goffs];
				nchar:=memoria[$c000+goffs]+((atrib and 3) shl 8)+((gfx_attr and $f) shl 10);
				color:=(atrib and $3c) shl 2;
				flipx:=(atrib and $40)<>0;
				flipy:=(atrib and $80)<>0;
				x:=sx+xc*8;
				y:=sy+yc*8;
        put_gfx_sprite(nchar,color,flipx,flipy,0);
        actualiza_gfx_sprite(x,y,1,0);
			end;
		end;
		sx:=sx+16;
   end;
end;
actualiza_trozo_final(0,16,256,224,1);
end;

procedure eventos_bublbobl;
begin
if event.arcade then begin
  //P1
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  //P2
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or 1);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or 2);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 and $bf) else marcade.in2:=(marcade.in2 or $40);
  //SYS
  if arcade_input.coin[0] then  marcade.in0:=(marcade.in0 or 4) else marcade.in0:=(marcade.in0 and $fb);
  if arcade_input.coin[1] then  marcade.in0:=(marcade.in0 or 8) else marcade.in0:=(marcade.in0 and $f7);
end;
end;

procedure bublbobl_principal;
var
  f:word;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
 for f:=0 to 263 do begin
  case f of
    16:update_video_bublbobl;
    240:begin
          z80_1.change_irq(HOLD_LINE);
          m6800_0.change_irq(HOLD_LINE);
        end;
  end;
  //main
  z80_0.run(frame_main);
  frame_main:=frame_main+z80_0.tframes-z80_0.contador;
  //segunda cpu
  z80_1.run(frame_sub);
  frame_sub:=frame_sub+z80_1.tframes-z80_1.contador;
  //sonido
  z80_2.run(frame_snd);
  frame_snd:=frame_snd+z80_2.tframes-z80_2.contador;
  //mcu
  m6800_0.run(frame_mcu);
  frame_mcu:=frame_mcu+m6800_0.tframes-m6800_0.contador;
 end;
 eventos_bublbobl;
 video_sync;
end;
end;

function bublbobl_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff,$c000..$f7ff,$fc00..$ffff:bublbobl_getbyte:=memoria[direccion];
  $8000..$bfff:bublbobl_getbyte:=memoria_rom[banco_rom,(direccion and $3fff)];
  $f800..$f9ff:bublbobl_getbyte:=buffer_paleta[direccion and $1ff];
  $fa00:bublbobl_getbyte:=sound_stat;
end;
end;

procedure bublbobl_putbyte(direccion:word;valor:byte);
procedure cambiar_color(dir:word);
var
  tmp_color:byte;
  color:tcolor;
begin
  tmp_color:=buffer_paleta[dir];
  color.r:=pal4bit(tmp_color shr 4);
  color.g:=pal4bit(tmp_color);
  tmp_color:=buffer_paleta[1+dir];
  color.b:=pal4bit(tmp_color shr 4);
  set_pal_color(color,dir shr 1);
end;
begin
case direccion of
        0..$bfff:; //ROM
        $c000..$f7ff,$fc00..$ffff:memoria[direccion]:=valor;
        $f800..$f9ff:if buffer_paleta[direccion and $1ff]<>valor then begin
                        buffer_paleta[direccion and $1ff]:=valor;
                        cambiar_color(direccion and $1fe);
                     end;
        $fa00:if not(sound_nmi) then begin
                z80_2.change_nmi(ASSERT_LINE);
                sound_latch:=valor;
                sound_nmi:=true;
              end;
        $fa03:if valor<>0 then z80_2.change_reset(ASSERT_LINE)
                else z80_2.change_reset(CLEAR_LINE);
        $fb40:begin
                banco_rom:=(valor xor 4) and 7;
                if (valor and $10)<>0 then z80_1.change_reset(CLEAR_LINE)
                    else z80_1.change_reset(ASSERT_LINE);
                if (valor and $20)<>0 then m6800_0.change_reset(CLEAR_LINE)
                    else m6800_0.change_reset(ASSERT_LINE);
                video_enable:=(valor and $40)<>0;
                main_screen.flip_main_screen:=(valor and $80)<>0;
              end;
end;
end;

function bb_misc_getbyte(direccion:word):byte;
begin
  case direccion of
    0..$7fff:bb_misc_getbyte:=mem_misc[direccion];
    $e000..$f7ff:bb_misc_getbyte:=memoria[direccion];
  end;
end;

procedure bb_misc_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:; //ROM
  $e000..$f7ff:memoria[direccion]:=valor;
end;
end;

function bbsnd_getbyte(direccion:word):byte;
begin
  case direccion of
    0..$8fff:bbsnd_getbyte:=mem_snd[direccion];
    $9000:bbsnd_getbyte:=ym2203_0.status;
    $9001:bbsnd_getbyte:=ym2203_0.read;
    $a000:bbsnd_getbyte:=ym3812_0.status;
    $a001:bbsnd_getbyte:=ym3812_0.read;
    $b000:bbsnd_getbyte:=sound_latch;
  end;
end;

procedure bbsnd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:; //ROM
  $8000..$8fff:mem_snd[direccion]:=valor;
  $9000:ym2203_0.control(valor);
  $9001:ym2203_0.write(valor);
  $a000:ym3812_0.control(valor);
  $a001:ym3812_0.write(valor);
  $b000:sound_stat:=valor;
  $b002:begin
          sound_nmi:=false;
          z80_2.change_nmi(CLEAR_LINE);
        end;
end;
end;

procedure bb_sound_update;
begin
  ym2203_0.update;
  ym3812_0.update;
end;

procedure snd_irq(irqstate:byte);
begin
  z80_2.change_irq(irqstate);
end;

function bublbobl_irq_vector:byte;
begin
  z80_0.change_irq(CLEAR_LINE);
  bublbobl_irq_vector:=memoria[$fc00];
end;

function mcu_port1_r:byte;
begin
  mcu_port1_r:=marcade.in0;
end;

function mcu_port3_r:byte;
begin
  mcu_port3_r:=mcu_port3_in;
end;

procedure mcu_port1_w(valor:byte);
begin
if (((mcu_port1_out and $40)<>0) and ((not(valor) and $40)<>0)) then z80_0.change_irq(ASSERT_LINE);
mcu_port1_out:=valor;
end;

procedure mcu_port2_w(valor:byte);
var
  address:word;
begin
if (((not(mcu_port2_out) and $10)<>0) and ((valor and $10)<>0)) then begin
  address:=mcu_port4_out or ((valor and $f) shl 8);
  if (mcu_port1_out and $80)<>0 then begin //read
    if ((address and $800)=0) then begin
      case (address and 3) of
        0:mcu_port3_in:=marcade.dswa;
        1:mcu_port3_in:=marcade.dswb;
        2:mcu_port3_in:=marcade.in1;
        3:mcu_port3_in:=marcade.in2;
      end;
    end else begin
      if ((address and $c00)=$c00) then mcu_port3_in:=memoria[$fc00+(address and $3ff)];
    end;
  end	else begin //write
    if ((address and $c00)=$c00) then memoria[$fc00+(address and $3ff)]:=mcu_port3_out;
  end;
end;
mcu_port2_out:=valor;
end;

procedure mcu_port3_w(valor:byte);
begin
  mcu_port3_out:=valor;
end;

procedure mcu_port4_w(valor:byte);
begin
  mcu_port4_out:=valor;
end;

//Main
procedure reset_bublbobl;
begin
 z80_0.reset;
 z80_1.reset;
 z80_2.reset;
 m6800_0.reset;
 frame_main:=z80_0.tframes;
 frame_sub:=z80_1.tframes;
 frame_snd:=z80_2.tframes;
 frame_mcu:=m6800_0.tframes;
 ym2203_0.reset;
 ym3812_0.reset;
 reset_video;
 reset_audio;
 banco_rom:=0;
 sound_nmi:=false;
 sound_stat:=0;
 marcade.in0:=$b3;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 sound_latch:=0;
 mcu_port3_in:=0;
 mcu_port1_out:=0;
 mcu_port2_out:=0;
 mcu_port3_out:=0;
 mcu_port4_out:=0;
end;

function iniciar_bublbobl:boolean;
var
  f:byte;
  memoria_temp:array[0..$7ffff] of byte;
const
  pc_x:array[0..7] of dword=(3, 2, 1, 0, 8+3, 8+2, 8+1, 8+0);
  pc_y:array[0..7] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16);
begin
llamadas_maquina.bucle_general:=bublbobl_principal;
llamadas_maquina.reset:=reset_bublbobl;
llamadas_maquina.fps_max:=59.185606;
iniciar_bublbobl:=false;
iniciar_audio(false);
screen_init(1,512,256,false,true);
iniciar_video(256,224);
//Main CPU
z80_0:=cpu_z80.create(6000000,264);
z80_0.change_ram_calls(bublbobl_getbyte,bublbobl_putbyte);
z80_0.change_misc_calls(nil,nil,nil,bublbobl_irq_vector);
if not(roms_load(@memoria_temp,bublbobl_rom)) then exit;
copymemory(@memoria,@memoria_temp,$8000);
for f:=0 to 3 do copymemory(@memoria_rom[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
//Second CPU
z80_1:=cpu_z80.create(6000000,264);
z80_1.change_ram_calls(bb_misc_getbyte,bb_misc_putbyte);
if not(roms_load(@mem_misc,bublbobl_rom2)) then exit;
//Sound CPU
z80_2:=cpu_z80.create(3000000,264);
z80_2.change_ram_calls(bbsnd_getbyte,bbsnd_putbyte);
z80_2.init_sound(bb_sound_update);
if not(roms_load(@mem_snd,bublbobl_snd)) then exit;
//MCU
m6800_0:=cpu_m6800.create(4000000,264,TCPU_M6801);
m6800_0.change_io_calls(mcu_port1_r,nil,mcu_port3_r,nil,mcu_port1_w,mcu_port2_w,mcu_port3_w,mcu_port4_w);
if not(roms_load(m6800_0.get_rom_addr,bublbobl_mcu_rom)) then exit;
//Sound Chip
ym2203_0:=ym2203_chip.create(3000000,0.5,0.5);
ym2203_0.change_irq_calls(snd_irq);
ym3812_0:=ym3812_chip.create(YM3526_FM,3000000,1);
ym3812_0.change_irq_calls(snd_irq);
//proms video
if not(roms_load(@mem_prom,bublbobl_prom)) then exit;
//convertir chars
if not(roms_load(@memoria_temp,bublbobl_chars)) then exit;
init_gfx(0,8,8,$4000);
gfx[0].trans[15]:=true;
gfx_set_desc_data(4,0,16*8,0,4,$4000*16*8+0,$4000*16*8+4);
convert_gfx(0,0,@memoria_temp,@pc_x,@pc_y,false,false,true);
//DIP
marcade.dswa:=$fe;
marcade.dswb:=$ff;
marcade.dswa_val2:=@bublbobl_dip_a;
marcade.dswb_val2:=@bublbobl_dip_b;
//final
reset_bublbobl;
iniciar_bublbobl:=true;
end;

end.
