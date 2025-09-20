unit bubblebobble_hw;
interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,gfx_engine,ym_2203,ym_3812,
     m680x,rom_engine,pal_engine,sound_engine,taito_68705;

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
        bublbobl_mcu:tipo_roms=(n:'a78-01.17';l:$1000;p:0;crc:$b1bfb53d);
        //Tokio
        tokio_rom:array[0..4] of tipo_roms=(
        (n:'a71-02-1.ic4';l:$8000;p:0;crc:$bb8dabd7),(n:'a71-03-1.ic5';l:$8000;p:$8000;crc:$ee49b383),
        (n:'a71-04.ic6';l:$8000;p:$10000;crc:$a0a4ce0e),(n:'a71-05.ic7';l:$8000;p:$18000;crc:$6da0b945),
        (n:'a71-06-1.ic8';l:$8000;p:$20000;crc:$56927b3f));
        tokio_rom2:tipo_roms=(n:'a71-01.ic1';l:$8000;p:0;crc:$0867c707);
        tokio_chars:array[0..15] of tipo_roms=(
        (n:'a71-08.ic12';l:$8000;p:0;crc:$0439ab13),(n:'a71-09.ic13';l:$8000;p:$8000;crc:$edb3d2ff),
        (n:'a71-10.ic14';l:$8000;p:$10000;crc:$69f0888c),(n:'a71-11.ic15';l:$8000;p:$18000;crc:$4ae07c31),
        (n:'a71-12.ic16';l:$8000;p:$20000;crc:$3f6bd706),(n:'a71-13.ic17';l:$8000;p:$28000;crc:$f2c92aaa),
        (n:'a71-14.ic18';l:$8000;p:$30000;crc:$c574b7b2),(n:'a71-15.ic19';l:$8000;p:$38000;crc:$12d87e7f),
        (n:'a71-16.ic30';l:$8000;p:$40000;crc:$0bce35b6),(n:'a71-17.ic31';l:$8000;p:$48000;crc:$deda6387),
        (n:'a71-18.ic32';l:$8000;p:$50000;crc:$330cd9d7),(n:'a71-19.ic33';l:$8000;p:$58000;crc:$fc4b29e0),
        (n:'a71-20.ic34';l:$8000;p:$60000;crc:$65acb265),(n:'a71-21.ic35';l:$8000;p:$68000;crc:$33cde9b2),
        (n:'a71-22.ic36';l:$8000;p:$70000;crc:$fb98eac0),(n:'a71-23.ic37';l:$8000;p:$78000;crc:$30bd46ad));
        tokio_snd:tipo_roms=(n:'a71-07.ic10';l:$8000;p:0;crc:$f298cc7b);
        tokio_prom:tipo_roms=(n:'a71-25.ic41';l:$100;p:0;crc:$2d0f8545);
        tokio_mcu:tipo_roms=(n:'a71__24.ic57';l:$800;p:0;crc:$0f4b25de);
        //Super Bobble Bobble
        sboblbobl_rom:array[0..2] of tipo_roms=(
        (n:'1c.bin';l:$8000;p:0;crc:$f304152a),(n:'1a.bin';l:$8000;p:$8000;crc:$0865209c),
        (n:'1b.bin';l:$8000;p:$10000;crc:$1f29b5c0));
        //Dip
        bublbobl_dip_a:array [0..4] of def_dip2=(
        (mask:2;name:'Flip Screen';number:2;val2:(2,0);name2:('Off','On')),
        (mask:5;name:'Mode';number:4;val4:(4,5,1,0);name4:('Game - English','Game - Japanese','Test (Grid and Inputs)','Test (RAM and Sound)/Pause')),
        (mask:8;name:'Demo Sounds';number:2;val2:(0,8);name2:('Off','On')),
        (mask:$30;name:'Coin A';number:4;val4:($10,$30,0,$20);name4:('2C 1C','1C 1C','2C 3C','1C 2C')),
        (mask:$c0;name:'Coin B';number:4;val4:($40,$c0,0,$80);name4:('2C 1C','1C 1C','2C 3C','1C 2C')));
        bublbobl_dip_b:array [0..3] of def_dip2=(
        (mask:3;name:'Difficulty';number:4;val4:(2,3,1,0);name4:('Easy','Normal','Hard','Very Hard')),
        (mask:$c;name:'Bonus Life';number:4;val4:(8,$c,4,0);name4:('20K 80K 300K','30K 100K 400K','40K 200K 500K','50K 250K 500K')),
        (mask:$30;name:'Lives';number:4;val4:($10,0,$30,$20);name4:('1','2','3','5')),
        (mask:$80;name:'ROM Type';number:2;val2:($80,0);name2:('IC52=512kb, IC53=none','IC52=256kb, IC53=256kb')));
        tokio_dip_a:array [0..4] of def_dip2=(
        (mask:1;name:'Cabinet';number:2;val2:(0,1);name2:('Upright','Cocktail')),
        (mask:2;name:'Flip Screen';number:2;val2:(2,0);name2:('Off','On')),
        (mask:8;name:'Demo Sounds';number:2;val2:(0,8);name2:('Off','On')),
        (mask:$30;name:'Coin A';number:4;val4:($10,$30,0,$20);name4:('2C 1C','1C 1C','2C 3C','1C 2C')),
        (mask:$c0;name:'Coin B';number:4;val4:($40,$c0,0,$80);name4:('2C 1C','1C 1C','2C 3C','1C 2C')));
        tokio_dip_b:array [0..4] of def_dip2=(
        (mask:1;name:'Enemies';number:2;val2:(1,0);name2:('Few (Easy)','Many (Hard)')),
        (mask:2;name:'Enemy Shots';number:2;val2:(2,0);name2:('Few (Easy)','Many (Hard)')),
        (mask:$c;name:'Bonus Life';number:4;val4:($c,8,$4,0);name4:('100K 400K','200K 400K','300K 400K','400K 400K')),
        (mask:$30;name:'Lives';number:4;val4:($30,$20,$10,0);name4:('3','4','5','99')),
        (mask:$80;name:'Language';number:2;val2:(0,$80);name2:('English','Japanese')));
        sboblbobl_dip_b:array [0..3] of def_dip2=(
        (mask:3;name:'Difficulty';number:4;val4:(2,3,1,0);name4:('Easy','Normal','Hard','Very Hard')),
        (mask:$c;name:'Bonus Life';number:4;val4:(8,$c,4,0);name4:('20K 80K 300K','30K 100K 400K','40K 200K 500K','50K 250K 500K')),
        (mask:$30;name:'Lives';number:4;val4:($10,0,$30,$20);name4:('1','2','3','5')),
        (mask:$c0;name:'Monster Speed';number:4;val4:(0,$40,$80,$c0);name4:('Normal','Medium','High','Very High')));

var
 memoria_rom:array [0..7,0..$3fff] of byte;
 mem_prom:array[0..$ff] of byte;
 banco_rom,sound_stat,sound_latch:byte;
 sound_nmi,video_enable:boolean;
 mcu_port3_in,mcu_port1_out,mcu_port2_out,mcu_port3_out,mcu_port4_out:byte;
 m_ic43_a,m_ic43_b:byte;

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
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or 8);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  //P2
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or 1);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or 2);
  if arcade_input.down[0] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or 4);
  if arcade_input.up[0] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or 8);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 and $bf) else marcade.in2:=(marcade.in2 or $40);
  //SYS
  if arcade_input.coin[0] then  marcade.in0:=(marcade.in0 or 4) else marcade.in0:=(marcade.in0 and $fb);
  if arcade_input.coin[1] then  marcade.in0:=(marcade.in0 or 8) else marcade.in0:=(marcade.in0 and $f7);
end;
end;

procedure eventos_sboblbobl;
begin
if event.arcade then begin
  //P1
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.coin[0] then  marcade.in0:=(marcade.in0 or 4) else marcade.in0:=(marcade.in0 and $fb);
  if arcade_input.coin[1] then  marcade.in0:=(marcade.in0 or 8) else marcade.in0:=(marcade.in0 and $f7);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  //P2
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
end;
end;

procedure bublbobl_principal;
var
  f:word;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
 for f:=0 to 263 do begin
  eventos_bublbobl;
  if f=240 then begin
    z80_1.change_irq(HOLD_LINE);
    m6800_0.change_irq(HOLD_LINE);
    update_video_bublbobl;
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
 video_sync;
end;
end;

procedure tokio_principal;
var
  f:word;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
 for f:=0 to 263 do begin
  eventos_bublbobl;
  if f=240 then begin
    z80_0.change_irq(HOLD_LINE);
    z80_1.change_irq(HOLD_LINE);
    update_video_bublbobl;
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
  taito_68705_0.run;
 end;
 video_sync;
end;
end;

procedure sbublbobl_principal;
var
  f:word;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
 for f:=0 to 263 do begin
  eventos_sboblbobl;
  if f=240 then begin
    z80_0.change_irq(HOLD_LINE);
    z80_1.change_irq(HOLD_LINE);
    update_video_bublbobl;
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
 end;
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

procedure bublbobl_putbyte(direccion:word;valor:byte);
begin
case direccion of
        0..$bfff:; //ROM
        $c000..$f7ff,$fc00..$ffff:memoria[direccion]:=valor;
        $f800..$f9ff:if buffer_paleta[direccion and $1ff]<>valor then begin
                        buffer_paleta[direccion and $1ff]:=valor;
                        cambiar_color(direccion and $1fe);
                     end;
        $fa00..$fa7f:case (direccion and 3) of
                      0:if not(sound_nmi) then begin
                          z80_2.change_nmi(ASSERT_LINE);
                          sound_latch:=valor;
                          sound_nmi:=true;
                        end;
                      1:; //Semaforos
                      3:if valor<>0 then z80_2.change_reset(ASSERT_LINE)
                          else z80_2.change_reset(CLEAR_LINE);
                     end;
        $fb00..$fb3f:z80_1.change_nmi(PULSE_LINE);
        $fb40..$fb7f:begin
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

//Tokio
function tokio_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff,$c000..$f7ff:tokio_getbyte:=memoria[direccion];
  $8000..$bfff:tokio_getbyte:=memoria_rom[banco_rom,(direccion and $3fff)];
  $f800..$f9ff:tokio_getbyte:=buffer_paleta[direccion and $1ff];
  $fa03:tokio_getbyte:=marcade.dswa;
  $fa04:tokio_getbyte:=marcade.dswb;
  $fa05:tokio_getbyte:=marcade.in0+($10*byte(not(taito_68705_0.main_sent)))+($20*byte(not(taito_68705_0.mcu_sent)));
  $fa06:tokio_getbyte:=marcade.in1;
  $fa07:tokio_getbyte:=marcade.in2;
  $fc00:tokio_getbyte:=sound_stat;
  $fe00:tokio_getbyte:=taito_68705_0.read;
end;
end;

procedure tokio_putbyte(direccion:word;valor:byte);
begin
case direccion of
        0..$bfff:; //ROM
        $c000..$f7ff:memoria[direccion]:=valor;
        $f800..$f9ff:if buffer_paleta[direccion and $1ff]<>valor then begin
                        buffer_paleta[direccion and $1ff]:=valor;
                        cambiar_color(direccion and $1fe);
                     end;
        $fa00:; //wd
        $fa80:begin
                banco_rom:=valor and 7;
                video_enable:=(valor and $40)<>0;
              end;
        $fb00:main_screen.flip_main_screen:=(valor and $80)<>0;
        $fb80:z80_1.change_nmi(PULSE_LINE);
        $fc00:if not(sound_nmi) then begin
                z80_2.change_nmi(ASSERT_LINE);
                sound_latch:=valor;
                sound_nmi:=true;
              end;
        $fe00:taito_68705_0.write(valor);
end;
end;

function tokio_misc_getbyte(direccion:word):byte;
begin
  case direccion of
    0..$7fff:tokio_misc_getbyte:=mem_misc[direccion];
    $8000..$97ff:tokio_misc_getbyte:=memoria[direccion+$6000];
  end;
end;

procedure tokio_misc_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:; //ROM
  $8000..$97ff:memoria[direccion+$6000]:=valor;
end;
end;

function tokio_snd_getbyte(direccion:word):byte;
begin
  case direccion of
    0..$8fff:tokio_snd_getbyte:=mem_snd[direccion];
    $9000:tokio_snd_getbyte:=sound_latch;
    $9800:; //semaforos
    $b000:tokio_snd_getbyte:=ym2203_0.status;
    $b001:tokio_snd_getbyte:=ym2203_0.read;
  end;
end;

procedure tokio_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:; //ROM
  $8000..$8fff:mem_snd[direccion]:=valor;
  $9000:sound_stat:=valor;
  $a000:begin
          sound_nmi:=false;
          z80_2.change_nmi(CLEAR_LINE);
        end;
  $a800:; //sound NMI set?
  $b000:ym2203_0.control(valor);
  $b001:ym2203_0.write(valor);
end;
end;

procedure tokio_sound_update;
begin
  ym2203_0.update;
end;

//Super Bobble Bobble
function sboblbobl_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff,$c000..$f7ff,$fc00..$fdff:sboblbobl_getbyte:=memoria[direccion];
  $8000..$bfff:sboblbobl_getbyte:=memoria_rom[banco_rom,(direccion and $3fff)];
  $f800..$f9ff:sboblbobl_getbyte:=buffer_paleta[direccion and $1ff];
  $fa00:sboblbobl_getbyte:=sound_stat;
  $fe00:sboblbobl_getbyte:=m_ic43_a shl 4;
  $fe01..$fe03:sboblbobl_getbyte:=random(256);
  $fe80:sboblbobl_getbyte:=m_ic43_b shl 4;
  $fe81..$fe83:sboblbobl_getbyte:=$ff;
  $ff00:sboblbobl_getbyte:=marcade.dswa;
  $ff01:sboblbobl_getbyte:=marcade.dswb;
  $ff02:sboblbobl_getbyte:=marcade.in0;
  $ff03:sboblbobl_getbyte:=marcade.in1;
end;
end;

procedure sboblbobl_putbyte(direccion:word;valor:byte);
var
  res:byte;
begin
case direccion of
        0..$bfff:; //ROM
        $c000..$f7ff,$fc00..$fdff:memoria[direccion]:=valor;
        $f800..$f9ff:if buffer_paleta[direccion and $1ff]<>valor then begin
                        buffer_paleta[direccion and $1ff]:=valor;
                        cambiar_color(direccion and $1fe);
                     end;
        $fa00..$fa7f:case (direccion and 3) of
                      0:if not(sound_nmi) then begin
                          z80_2.change_nmi(ASSERT_LINE);
                          sound_latch:=valor;
                          sound_nmi:=true;
                        end;
                      1:; //Semaforos
                      3:if valor<>0 then z80_2.change_reset(ASSERT_LINE)
                          else z80_2.change_reset(CLEAR_LINE);
                     end;
        $fb00..$fb3f:z80_1.change_nmi(PULSE_LINE);
        $fb40..$fb7f:begin
                        banco_rom:=(valor xor 4) and 7;
                        if (valor and $10)<>0 then z80_1.change_reset(CLEAR_LINE)
                          else z80_1.change_reset(ASSERT_LINE);
                        video_enable:=(valor and $40)<>0;
                        main_screen.flip_main_screen:=(valor and $80)<>0;
                     end;
	      $fe00:begin
                res:=0;
                if (not(m_ic43_a) and 8)<>0 then res:=res xor 1;
			          if (not(m_ic43_a) and 1)<>0 then res:=res xor 2;
			          if (not(m_ic43_a) and 1)<>0 then res:=res xor 4;
			          if (not(m_ic43_a) and 2)<>0 then res:=res xor 4;
			          if (not(m_ic43_a) and 4)<>0 then res:=res xor 8;
                m_ic43_a:=res;
              end;
        $fe01:begin
                res:=0;
                if (not(m_ic43_a) and 8)<>0 then res:=res xor 1;
			          if (not(m_ic43_a) and 2)<>0 then res:=res xor 1;
			          if (not(m_ic43_a) and 8)<>0 then res:=res xor 2;
			          if (not(m_ic43_a) and 1)<>0 then res:=res xor 4;
			          if (not(m_ic43_a) and 4)<>0 then res:=res xor 8;
                m_ic43_a:=res;
              end;
        $fe02:begin
                res:=0;
                if (not(m_ic43_a) and 4)<>0 then res:=res xor 1;
			          if (not(m_ic43_a) and 8)<>0 then res:=res xor 2;
			          if (not(m_ic43_a) and 2)<>0 then res:=res xor 4;
			          if (not(m_ic43_a) and 1)<>0 then res:=res xor 8;
			          if (not(m_ic43_a) and 4)<>0 then res:=res xor 8;
                m_ic43_a:=res;
              end;
        $fe03:begin
                res:=0;
                if (not(m_ic43_a) and 2)<>0 then res:=res xor 1;
			          if (not(m_ic43_a) and 4)<>0 then res:=res xor 2;
			          if (not(m_ic43_a) and 8)<>0 then res:=res xor 2;
			          if (not(m_ic43_a) and 8)<>0 then res:=res xor 4;
			          if (not(m_ic43_a) and 1)<>0 then res:=res xor 8;
                m_ic43_a:=res;
              end;
	      $fe80:m_ic43_b:=(valor shr 4) xor 4;
        $fe81:m_ic43_b:=(valor shr 4) xor 1;
        $fe82:m_ic43_b:=(valor shr 4) xor 8;
        $fe83:m_ic43_b:=(valor shr 4) xor 2;
end;
end;

//Main
procedure reset_bublbobl;
begin
 z80_0.reset;
 z80_1.reset;
 z80_2.reset;
 frame_main:=z80_0.tframes;
 frame_sub:=z80_1.tframes;
 frame_snd:=z80_2.tframes;
 case main_vars.tipo_maquina of
  46:begin
      m6800_0.reset;
      frame_mcu:=m6800_0.tframes;
      marcade.in0:=$b3;
      ym2203_0.reset;
      ym3812_0.reset;
      mcu_port3_in:=0;
      mcu_port1_out:=0;
      mcu_port2_out:=0;
      mcu_port3_out:=0;
      mcu_port4_out:=0;
  end;
 425:begin
      marcade.in0:=$c3;
      taito_68705_0.reset;
      ym2203_0.reset;
     end;
 426:begin
      marcade.in0:=$f3;
      ym2203_0.reset;
      ym3812_0.reset;
      m_ic43_a:=0;
      m_ic43_b:=0;
     end;
 end;
 banco_rom:=0;
 sound_nmi:=false;
 sound_stat:=0;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 sound_latch:=0;
end;

function iniciar_bublbobl:boolean;
var
  f:byte;
  memoria_temp:array[0..$7ffff] of byte;
procedure convert_chars;
const
  pc_x:array[0..7] of dword=(3, 2, 1, 0, 8+3, 8+2, 8+1, 8+0);
  pc_y:array[0..7] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16);
begin
  init_gfx(0,8,8,$4000);
  gfx[0].trans[15]:=true;
  gfx_set_desc_data(4,0,16*8,0,4,$4000*16*8+0,$4000*16*8+4);
  convert_gfx(0,0,@memoria_temp,@pc_x,@pc_y,false,false,true);
end;
begin
llamadas_maquina.reset:=reset_bublbobl;
llamadas_maquina.fps_max:=59.185606;
llamadas_maquina.scanlines:=264;
iniciar_bublbobl:=false;
iniciar_audio(false);
screen_init(1,512,256,false,true);
if (main_vars.tipo_maquina=425) then main_screen.rot90_screen:=true;
iniciar_video(256,224);
//Main CPU
z80_0:=cpu_z80.create(6000000);
//Second CPU
z80_1:=cpu_z80.create(6000000);
//Sound CPU
z80_2:=cpu_z80.create(3000000);
case main_vars.tipo_maquina of
  46:begin //Bubble Bobble
        llamadas_maquina.bucle_general:=bublbobl_principal;
        //Main CPU
        z80_0.change_ram_calls(bublbobl_getbyte,bublbobl_putbyte);
        z80_0.change_misc_calls(nil,nil,nil,bublbobl_irq_vector);
        if not(roms_load(@memoria_temp,bublbobl_rom)) then exit;
        copymemory(@memoria,@memoria_temp,$8000);
        for f:=0 to 3 do copymemory(@memoria_rom[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
        //Second CPU
        z80_1.change_ram_calls(bb_misc_getbyte,bb_misc_putbyte);
        if not(roms_load(@mem_misc,bublbobl_rom2)) then exit;
        //Sound CPU
        z80_2.change_ram_calls(bbsnd_getbyte,bbsnd_putbyte);
        if not(roms_load(@mem_snd,bublbobl_snd)) then exit;
        z80_2.init_sound(bb_sound_update);
        //Sound
        ym2203_0:=ym2203_chip.create(3000000);
        ym2203_0.change_irq_calls(snd_irq);
        ym3812_0:=ym3812_chip.create(YM3526_FM,3000000);
        ym3812_0.change_irq_calls(snd_irq);
        //MCU
        m6800_0:=cpu_m6800.create(4000000,TCPU_M6801);
        m6800_0.change_io_calls(mcu_port1_r,nil,mcu_port3_r,nil,mcu_port1_w,mcu_port2_w,mcu_port3_w,mcu_port4_w);
        if not(roms_load(m6800_0.get_rom_addr,bublbobl_mcu)) then exit;
        //proms video
        if not(roms_load(@mem_prom,bublbobl_prom)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,bublbobl_chars)) then exit;
        convert_chars;
        //DIP
        init_dips(1,bublbobl_dip_a,$fe);
        init_dips(2,bublbobl_dip_b,$ff);
     end;
  425:begin //Tokio
        llamadas_maquina.bucle_general:=tokio_principal;
        //Main CPU
        z80_0.change_ram_calls(tokio_getbyte,tokio_putbyte);
        if not(roms_load(@memoria_temp,tokio_rom)) then exit;
        copymemory(@memoria,@memoria_temp,$8000);
        for f:=0 to 7 do copymemory(@memoria_rom[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
        //Second CPU
        z80_1.change_ram_calls(tokio_misc_getbyte,tokio_misc_putbyte);
        if not(roms_load(@mem_misc,tokio_rom2)) then exit;
        //Sound CPU
        z80_2.change_ram_calls(tokio_snd_getbyte,tokio_snd_putbyte);
        if not(roms_load(@mem_snd,tokio_snd)) then exit;
        z80_2.init_sound(tokio_sound_update);
        ym2203_0:=ym2203_chip.create(3000000);
        ym2203_0.change_irq_calls(snd_irq);
        //MCU
        taito_68705_0:=taito_68705p.create(3000000);
        if not(roms_load(taito_68705_0.get_rom_addr,tokio_mcu)) then exit;
        //proms video
        if not(roms_load(@mem_prom,tokio_prom)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,tokio_chars)) then exit;
        convert_chars;
        //DIP
        init_dips(1,tokio_dip_a,$fe);
        init_dips(2,tokio_dip_b,$7e);
     end;
  426:begin //Super Bubble Bobble
        llamadas_maquina.bucle_general:=sbublbobl_principal;
        //Main CPU
        z80_0.change_ram_calls(sboblbobl_getbyte,sboblbobl_putbyte);
        if not(roms_load(@memoria_temp,sboblbobl_rom)) then exit;
        copymemory(@memoria,@memoria_temp,$8000);
        for f:=0 to 3 do copymemory(@memoria_rom[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
        //Second CPU
        z80_1.change_ram_calls(bb_misc_getbyte,bb_misc_putbyte);
        if not(roms_load(@mem_misc,bublbobl_rom2,true,true,'bublbobl.zip')) then exit;
        //Sound CPU
        z80_2.change_ram_calls(bbsnd_getbyte,bbsnd_putbyte);
        if not(roms_load(@mem_snd,bublbobl_snd,true,true,'bublbobl.zip')) then exit;
        z80_2.init_sound(bb_sound_update);
        //Sound
        ym2203_0:=ym2203_chip.create(3000000);
        ym2203_0.change_irq_calls(snd_irq);
        ym3812_0:=ym3812_chip.create(YM3526_FM,3000000);
        ym3812_0.change_irq_calls(snd_irq);
        //proms video
        if not(roms_load(@mem_prom,bublbobl_prom,true,true,'bublbobl.zip')) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,bublbobl_chars,true,true,'bublbobl.zip')) then exit;
        convert_chars;
        //DIP
        init_dips(1,bublbobl_dip_a,$fe);
        init_dips(2,sboblbobl_dip_b,$3f);
     end;
end;
//final
iniciar_bublbobl:=true;
end;

end.
