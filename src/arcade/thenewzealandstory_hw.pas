unit thenewzealandstory_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,ym_2203,gfx_engine,rom_engine,pal_engine,
     sound_engine,seta_sprites,mcs48;

function iniciar_tnzs:boolean;

implementation
const
        //The NewZealand Story
        tnzs_rom:tipo_roms=(n:'b53-24.1';l:$20000;p:0;crc:$d66824c6);
        tnzs_sub:tipo_roms=(n:'b53-25.3';l:$10000;p:0;crc:$d6ac4e71);
        tnzs_audio:tipo_roms=(n:'b53-26.34';l:$10000;p:0;crc:$cfd5649c);
        tnzs_gfx:array[0..7] of tipo_roms=(
        (n:'b53-16.8';l:$20000;p:0;crc:$c3519c2a),(n:'b53-17.7';l:$20000;p:$20000;crc:$2bf199e8),
        (n:'b53-18.6';l:$20000;p:$40000;crc:$92f35ed9),(n:'b53-19.5';l:$20000;p:$60000;crc:$edbb9581),
        (n:'b53-22.4';l:$20000;p:$80000;crc:$59d2aef6),(n:'b53-23.3';l:$20000;p:$a0000;crc:$74acfb9b),
        (n:'b53-20.2';l:$20000;p:$c0000;crc:$095d0dc0),(n:'b53-21.1';l:$20000;p:$e0000;crc:$9800c54d));
        //Dip
        tnzs_dip_a:array [0..5] of def_dip2=(
        (mask:1;name:'Cabinet';number:2;val2:(0,1);name2:('Upright','Cocktail')),
        (mask:2;name:'Flip_Screen';number:2;val2:(2,0);name2:('Off','On')),
        (mask:8;name:'Invulnerability';number:2;val2:(8,0);name2:('Off','On')),
        (mask:$30;name:'Coin A';number:4;val4:(0,$10,$20,$30);name4:('4C 1C','3C 1C','2C 1C','1C 1C')),
        (mask:$c0;name:'Coin B';number:4;val4:($c0,$80,$40,0);name4:('1C 2C','1C 3C','1C 4C','1C 6C')),());
        tnzs_dip_b:array [0..4] of def_dip2=(
        (mask:3;name:'Difficulty';number:4;val4:(2,3,1,0);name4:('Easy','Medium','Hard','Hardest')),
        (mask:$c;name:'Bonus Life';number:4;val4:(0,$c,4,8);name4:('50K 150K 150K+','70K 200K 200K+','100K 250K 250K+','200K 300K 300K+')),
        (mask:$30;name:'Lives';number:4;val4:($20,$30,0,$10);name4:('2','3','4','5')),
        (mask:$40;name:'Allow Continue';number:2;val2:(0,$40);name2:('No','Yes')),());
        //Insector X
        insectorx_rom:tipo_roms=(n:'b97-03.u32';l:$20000;p:0;crc:$18eef387);
        insectorx_sub:tipo_roms=(n:'b97-07.u38';l:$10000;p:0;crc:$324b28c9);
        insectorx_gfx:array[0..1] of tipo_roms=(
        (n:'b97-01.u1';l:$80000;p:0;crc:$d00294b1),(n:'b97-02.u2';l:$80000;p:$80000;crc:$db5a7434));
        //Dip
        insectorx_dip_a:array [0..5] of def_dip2=(
        (mask:1;name:'Cabinet';number:2;val2:(0,1);name2:('Upright','Cocktail')),
        (mask:2;name:'Flip_Screen';number:2;val2:(2,0);name2:('Off','On')),
        (mask:8;name:'Demo_Sounds';number:2;val2:(0,8);name2:('Off','On')),
        (mask:$30;name:'Coin A';number:4;val4:(0,$10,$20,$30);name4:('4C 1C','3C 1C','2C 1C','1C 1C')),
        (mask:$c0;name:'Coin B';number:4;val4:($c0,$80,$40,0);name4:('1C 2C','1C 3C','1C 4C','1C 6C')),());
        insectorx_dip_b:array [0..3] of def_dip2=(
        (mask:3;name:'Difficulty';number:4;val4:(1,3,2,0);name4:('Easy','Medium','Hard','Hardest')),
        (mask:$c;name:'Bonus Life';number:4;val4:(8,$c,4,0);name4:('40K 240K 200K+','60K 360K 300K+','100K 500K 400K+','150K 650K 500K+')),
        (mask:$30;name:'Lives';number:4;val4:(0,$10,$30,$20);name4:('1','2','3','4')),());
        //Extermination
        extrmatn_rom:array[0..1] of tipo_roms=(
        (n:'b06-05.11c';l:$10000;p:0;crc:$918e1fe3),(n:'b06-06.9c';l:$10000;p:$10000;crc:$8842e105));
        extrmatn_sub:tipo_roms=(n:'b06-19.4e';l:$10000;p:0;crc:$8de43ed9);
        extrmatn_mcu:tipo_roms=(n:'b06__14.1g';l:$800;p:0;crc:$28907072);
        extrmatn_gfx:array[0..3] of tipo_roms=(
        (n:'b06-01.13a';l:$20000;p:0;crc:$d2afbf7e),(n:'b06-02.10a';l:$20000;p:$20000;crc:$e0c2757a),
        (n:'b06-03.7a';l:$20000;p:$40000;crc:$ee80ab9d),(n:'b06-04.4a';l:$20000;p:$60000;crc:$3697ace4));
        extrmatn_pal:array[0..1] of tipo_roms=(
        (n:'b06-09.15f';l:$200;p:0;crc:$f388b361),(n:'b06-08.17f';l:$200;p:$200;crc:$10c9aac3));
        extrmatn_dip_a:array [0..3] of def_dip2=(
        (mask:2;name:'Flip_Screen';number:2;val2:(2,0);name2:('Off','On')),
        (mask:$30;name:'Coin A';number:4;val4:($10,$30,0,$20);name4:('2C 1C','1C 1C','2C 3C','1C 2C')),
        (mask:$c0;name:'Coin B';number:4;val4:($40,$c0,0,$80);name4:('2C 1C','1C 1C','2C 3C','1C 2C')),());
        extrmatn_dip_b:array [0..2] of def_dip2=(
        (mask:3;name:'Difficulty';number:4;val4:(2,3,1,0);name4:('Easy','Medium','Hard','Hardest')),
        (mask:$c0;name:'Damage Multiplier';number:4;val4:($c0,$80,$40,0);name4:('x1','x1.5','x2','x3')),());
        //Arkanoid II
        {arknoid2_rom:tipo_roms=(n:'b08__05.11c';l:$10000;p:0;crc:$136edf9d);
        arknoid2_sub:tipo_roms=(n:'b08__13.3e';l:$10000;p:0;crc:$e8035ef1);
        arknoid2_mcu:tipo_roms=(n:'b53-09.u46';l:$800;p:0;crc:$a4bfce19);
        arknoid2_gfx:array[0..3] of tipo_roms=(
        (n:'b08-01.13a';l:$20000;p:0;crc:$2ccc86b4),(n:'b08-02.10a';l:$20000;p:$20000;crc:$056a985f),
        (n:'b08-03.7a';l:$20000;p:$40000;crc:$274a795f),(n:'b08-04.4a';l:$20000;p:$60000;crc:$9754f703));
        arknoid2_pal:array[0..1] of tipo_roms=(
        (n:'b08-08.15f';l:$200;p:0;crc:$a4f7ebd9),(n:'b08-07.16f';l:$200;p:$200;crc:$ea34d9f7));}
        //Madre mia!!
        CPU_SYNC=16;

var
 main_bank,misc_bank,sound_latch:byte;
 main_rom:array[0..7,0..$3fff] of byte;
 aux_rom:array[0..3,0..$1fff] of byte;
 //MCU
 input_select:byte;

procedure update_video_tnzs;
begin
if (seta_sprite0.bg_flag and $80)=0 then fill_full_screen(1,$1f0);
seta_sprite0.draw_sprites;
actualiza_trozo_final(0,16,256,224,1);
end;

//TNZS
procedure eventos_tnzs;
begin
if event.arcade then begin
  //marcade.in0
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  //marcade.in1
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or 8);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
  //marcade.in2
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
end;
end;

procedure tnzs_principal;
var
  f,h:byte;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
  for f:=0 to $ff do begin
    if f=240 then begin
      z80_0.change_irq(HOLD_LINE);
      z80_1.change_irq(HOLD_LINE);
      update_video_tnzs;
      seta_sprite0.tnzs_eof;
    end;
    for h:=1 to CPU_SYNC do begin
      //main
      z80_0.run(frame_main);
      frame_main:=frame_main+z80_0.tframes-z80_0.contador;
      //sub
      z80_1.run(frame_sub);
      frame_sub:=frame_sub+z80_1.tframes-z80_1.contador;
      //snd
      z80_2.run(frame_snd);
      frame_snd:=frame_snd+z80_2.tframes-z80_2.contador;
    end;
  end;
  eventos_tnzs;
  video_sync;
end;
end;

function tnzs_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff,$e000..$efff:tnzs_getbyte:=memoria[direccion];
  $8000..$bfff:tnzs_getbyte:=main_rom[main_bank,direccion and $3fff];
  $c000..$cfff:tnzs_getbyte:=seta_sprite0.spritelow[direccion and $fff];
  $d000..$dfff:tnzs_getbyte:=seta_sprite0.spritehigh[direccion and $fff];
  $f000..$f2ff:tnzs_getbyte:=seta_sprite0.spritey[direccion and $3ff];
  $f300..$f3ff:tnzs_getbyte:=seta_sprite0.control[direccion and 3];
  $f400:tnzs_getbyte:=seta_sprite0.bg_flag;
end;
end;

procedure tnzs_putbyte(direccion:word;valor:byte);
begin
case direccion of
   0..$7fff:; //ROM
   $8000..$bfff:if main_bank<2 then main_rom[main_bank,direccion and $3fff]:=valor;
   $c000..$cfff:seta_sprite0.spritelow[direccion and $fff]:=valor;
   $d000..$dfff:seta_sprite0.spritehigh[direccion and $fff]:=valor;
   $e000..$efff:memoria[direccion]:=valor;
   $f000..$f2ff:seta_sprite0.spritey[direccion and $3ff]:=valor;
   $f300..$f3ff:seta_sprite0.control[direccion and 3]:=valor;
   $f400:seta_sprite0.bg_flag:=valor;
   $f600:begin
          if (valor and $10)<>0 then z80_1.change_reset(CLEAR_LINE)
            else z80_1.change_reset(ASSERT_LINE);
	        main_bank:=valor and 7;
        end;
   end;
end;

function tnzs_misc_getbyte(direccion:word):byte;
begin
  case direccion of
    0..$7fff,$d000..$dfff:tnzs_misc_getbyte:=mem_misc[direccion];
    $8000..$9fff:tnzs_misc_getbyte:=aux_rom[misc_bank,direccion and $1fff];
    $b002:tnzs_misc_getbyte:=marcade.dswa;
    $b003:tnzs_misc_getbyte:=marcade.dswb;
    $c000:tnzs_misc_getbyte:=marcade.in0;
    $c001:tnzs_misc_getbyte:=marcade.in1;
    $c002:tnzs_misc_getbyte:=marcade.in2;
    $e000..$efff:tnzs_misc_getbyte:=memoria[direccion];
    $f000..$f3ff:tnzs_misc_getbyte:=buffer_paleta[direccion and $3ff];
  end;
end;

procedure cambiar_color(dir:word);
var
  tmp_color:word;
  color:tcolor;
begin
  tmp_color:=buffer_paleta[dir]+(buffer_paleta[dir+1] shl 8);
  color.r:=pal5bit(tmp_color shr 10);
  color.g:=pal5bit(tmp_color shr 5);
  color.b:=pal5bit(tmp_color);
  set_pal_color(color,dir shr 1);
end;

procedure tnzs_misc_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$9fff:; //ROM
  $a000:misc_bank:=valor and 3;
  $b004:begin
          sound_latch:=valor;
          z80_2.change_irq(HOLD_LINE);
        end;
  $d000..$dfff:mem_misc[direccion]:=valor;
  $e000..$efff:memoria[direccion]:=valor;
  $f000..$f3ff:if buffer_paleta[direccion and $3ff]<>valor then begin
          buffer_paleta[direccion and $3ff]:=valor;
          cambiar_color(direccion and $3fe);
        end;
end;
end;

function tnzs_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff,$c000..$dfff:tnzs_snd_getbyte:=mem_snd[direccion];
end;
end;

procedure tnzs_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:; //ROM
  $c000..$dfff:mem_snd[direccion]:=valor;
end;
end;

function tnzs_snd_inbyte(puerto:word):byte;
begin
case (puerto and $ff) of
  0:tnzs_snd_inbyte:=ym2203_0.status;
  1:tnzs_snd_inbyte:=ym2203_0.read;
  2:tnzs_snd_inbyte:=sound_latch;
end;
end;

procedure tnzs_snd_outbyte(puerto:word;valor:byte);
begin
case (puerto and $ff) of
  0:ym2203_0.control(valor);
  1:ym2203_0.write(valor);
end;
end;

procedure snd_irq(irqstate:byte);
begin
  z80_2.change_nmi(irqstate);
end;

//Insector X
procedure eventos_insectorx;
begin
if event.arcade then begin
  //marcade.in0
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  //marcade.in1
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or 8);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
  //marcade.in2
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or 4);
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or 8);
end;
end;

procedure insectorx_principal;
var
  f,h:byte;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
  for f:=0 to $ff do begin
    if f=240 then begin
      z80_0.change_irq(HOLD_LINE);
      z80_1.change_irq(HOLD_LINE);
      update_video_tnzs;
      seta_sprite0.tnzs_eof;
    end;
    for h:=1 to CPU_SYNC do begin
      //main
      z80_0.run(frame_main);
      frame_main:=frame_main+z80_0.tframes-z80_0.contador;
      //snd
      z80_1.run(frame_snd);
      frame_snd:=frame_snd+z80_1.tframes-z80_1.contador;
    end;
  end;
  eventos_insectorx;
  video_sync;
end;
end;

function insectorx_getbyte(direccion:word):byte;
begin
case direccion of
  $f800..$fbff:insectorx_getbyte:=buffer_paleta[direccion and $3ff];
  else insectorx_getbyte:=tnzs_getbyte(direccion);
end;
end;

procedure insectorx_putbyte(direccion:word;valor:byte);
begin
case direccion of
   $f800..$fbff:if buffer_paleta[direccion and $3ff]<>valor then begin
          buffer_paleta[direccion and $3ff]:=valor;
          cambiar_color(direccion and $3fe);
        end;
   else tnzs_putbyte(direccion,valor);
end;
end;

function insectorx_snd_getbyte(direccion:word):byte;
begin
  case direccion of
    0..$7fff,$d000..$dfff:insectorx_snd_getbyte:=mem_snd[direccion];
    $8000..$9fff:insectorx_snd_getbyte:=aux_rom[misc_bank,direccion and $1fff];
    $b000:insectorx_snd_getbyte:=ym2203_0.status;
    $b001:insectorx_snd_getbyte:=ym2203_0.read;
    $c000:insectorx_snd_getbyte:=marcade.in0;
    $c001:insectorx_snd_getbyte:=marcade.in1;
    $c002:insectorx_snd_getbyte:=marcade.in2;
    $e000..$efff:insectorx_snd_getbyte:=memoria[direccion];
    $f000..$f003:;
  end;
end;

procedure insectorx_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$9fff:; //ROM
  $a000:misc_bank:=valor and 3;
  $b000:ym2203_0.control(valor);
  $b001:ym2203_0.write(valor);
  $d000..$dfff:mem_snd[direccion]:=valor;
  $e000..$efff:memoria[direccion]:=valor;
end;
end;

function insectorx_porta_r:byte;
begin
  insectorx_porta_r:=marcade.dswa;
end;

function insectorx_portb_r:byte;
begin
  insectorx_portb_r:=marcade.dswb;
end;

//Extermination
procedure eventos_extrmatn;
begin
if event.arcade then begin
  //marcade.in0
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  //marcade.in1
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or 8);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
  //marcade.in2
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 or 1) else marcade.in2:=(marcade.in2 and $fe);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 or 2) else marcade.in2:=(marcade.in2 and $fd);
end;
end;

procedure extrmatn_principal_mcu;
var
  f,h:byte;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
  for f:=0 to $ff do begin
    if f=240 then begin
      z80_0.change_irq(HOLD_LINE);
      z80_1.change_irq(HOLD_LINE);
      update_video_tnzs;
      seta_sprite0.tnzs_eof;
    end;
    for h:=1 to CPU_SYNC do begin
      //main
      z80_0.run(frame_main);
      frame_main:=frame_main+z80_0.tframes-z80_0.contador;
      //sub
      z80_1.run(frame_snd);
      frame_snd:=frame_snd+z80_1.tframes-z80_1.contador;
      //sound sub cpu
      mcs48_0.run(frame_mcu);
      frame_mcu:=frame_mcu+mcs48_0.tframes-mcs48_0.contador;
    end;
  end;
  eventos_extrmatn;
  video_sync;
end;
end;

function extrmatn_snd_getbyte(direccion:word):byte;
begin
  case direccion of
    0..$7fff,$d000..$dfff:extrmatn_snd_getbyte:=mem_snd[direccion];
    $8000..$9fff:extrmatn_snd_getbyte:=aux_rom[misc_bank,direccion and $1fff];
    $b000:extrmatn_snd_getbyte:=ym2203_0.status;
    $b001:extrmatn_snd_getbyte:=ym2203_0.read;
    $c000:extrmatn_snd_getbyte:=mcs48_0.upi41_master_r(0);
    $c001:extrmatn_snd_getbyte:=mcs48_0.upi41_master_r(1);
    $e000..$efff:extrmatn_snd_getbyte:=memoria[direccion];
    $f000..$f003:;
  end;
end;

procedure extrmatn_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$9fff:; //ROM
  $a000:begin
          misc_bank:=valor and 3;
          if (valor and 4)<>0 then mcs48_0.change_reset(PULSE_LINE);
        end;
  $b000:ym2203_0.control(valor);
  $b001:ym2203_0.write(valor);
  $c000:mcs48_0.upi41_master_w(0,valor);
  $c001:mcs48_0.upi41_master_w(1,valor);
  $d000..$dfff:mem_snd[direccion]:=valor;
  $e000..$efff:memoria[direccion]:=valor;
end;
end;

function extrmatn_mcu_inport(puerto:word):byte;
begin
case puerto of
  MCS48_PORT_P1:case input_select of
                    $a:extrmatn_mcu_inport:=$ff;
                    $c:extrmatn_mcu_inport:=marcade.in0;
                    $d:extrmatn_mcu_inport:=marcade.in1;
                end;
  MCS48_PORT_P2:extrmatn_mcu_inport:=$ff;
  MCS48_PORT_T0:extrmatn_mcu_inport:=marcade.in2 and 1;
  MCS48_PORT_T1:extrmatn_mcu_inport:=(marcade.in2 shr 1) and 1;
end;
end;

procedure extrmatn_mcu_outport(puerto:word;valor:byte);
begin
case puerto of
  MCS48_PORT_P2:input_select:=valor and $f;
end;
end;

procedure tnzs_sound_update;
begin
  ym2203_0.update;
end;

//Main
procedure reset_tnzs;
begin
 z80_0.reset;
 z80_1.reset;
 frame_main:=z80_0.tframes;
 frame_snd:=z80_1.tframes;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 case main_vars.tipo_maquina of
  129:begin
        frame_sub:=z80_1.tframes;
        z80_2.reset;
        frame_snd:=z80_2.tframes;
      end;
  306:begin
        frame_mcu:=mcs48_0.tframes;
        mcs48_0.reset;
        marcade.in2:=0;
      end;
 end;
 ym2203_0.reset;
 reset_audio;
 seta_sprite0.reset;
 main_bank:=0;
 misc_bank:=0;
 input_select:=0;
end;

function iniciar_tnzs:boolean;
var
  f,tempw:word;
  memoria_temp:array[0..$1ffff] of byte;
  ptemp:pbyte;
  colores:tpaleta;
const
    pt_x:array[0..15] of dword=(0, 1, 2, 3, 4, 5, 6, 7,
			8*8+0, 8*8+1, 8*8+2, 8*8+3, 8*8+4, 8*8+5, 8*8+6, 8*8+7);
    pt_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			16*8, 17*8, 18*8, 19*8, 20*8, 21*8, 22*8, 23*8);
    pt2_x:array[0..15] of dword=(0, 1, 2, 3, 4, 5, 6, 7,
      8*16+0, 8*16+1, 8*16+2, 8*16+3, 8*16+4, 8*16+5, 8*16+6, 8*16+7);
    pt2_y:array[0..15] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16,
      16*16, 17*16, 18*16, 19*16, 20*16, 21*16, 22*16, 23*16);
begin
llamadas_maquina.reset:=reset_tnzs;
iniciar_tnzs:=false;
iniciar_audio(false);
screen_init(1,512,256,false,true);
if main_vars.tipo_maquina=306 then main_screen.rot270_screen:=true;
iniciar_video(256,224);
//Main CPU
z80_0:=cpu_z80.create(6000000,$100*CPU_SYNC);
//Sound CPU
z80_1:=cpu_z80.create(6000000,$100*CPU_SYNC);
//Video chips
if main_vars.tipo_maquina=306 then seta_sprite0:=tseta_sprites.create(0,1,$800 div $40)
  else seta_sprite0:=tseta_sprites.create(0,1,$800 div $40);
case main_vars.tipo_maquina of
  129:begin   //TNZS
        llamadas_maquina.fps_max:=59.15;
        llamadas_maquina.bucle_general:=tnzs_principal;
        //Main CPU
        z80_0.change_ram_calls(tnzs_getbyte,tnzs_putbyte);
        if not(roms_load(@memoria_temp,tnzs_rom)) then exit;
        copymemory(@memoria,@memoria_temp,$8000);
        for f:=0 to 5 do copymemory(@main_rom[f+2,0],@memoria_temp[$8000+(f*$4000)],$4000);
        //Secound CPU
        z80_1.change_ram_calls(tnzs_misc_getbyte,tnzs_misc_putbyte);
        if not(roms_load(@memoria_temp,tnzs_sub)) then exit;
        copymemory(@mem_misc,@memoria_temp,$8000);
        for f:=0 to 3 do copymemory(@aux_rom[f,0],@memoria_temp[$8000+(f*$2000)],$2000);
        //Sound CPU
        z80_2:=cpu_z80.create(6000000,$100*CPU_SYNC);
        z80_2.change_ram_calls(tnzs_snd_getbyte,tnzs_snd_putbyte);
        z80_2.change_io_calls(tnzs_snd_inbyte,tnzs_snd_outbyte);
        z80_2.init_sound(tnzs_sound_update);
        if not(roms_load(@mem_snd,tnzs_audio)) then exit;
        //Sound Chips
        ym2203_0:=ym2203_chip.create(3000000);
        ym2203_0.change_irq_calls(snd_irq);
        //convertir chars
        getmem(ptemp,$100000);
        if not(roms_load(ptemp,tnzs_gfx)) then exit;
        init_gfx(0,16,16,$2000);
        gfx[0].trans[0]:=true;
        gfx_set_desc_data(4,0,32*8,$2000*32*8*3,$2000*32*8*2,$2000*32*8,0);
        convert_gfx(0,0,ptemp,@pt_x,@pt_y,false,false);
        freemem(ptemp);
        marcade.dswa:=$fe;
        marcade.dswb:=$ff;
        marcade.dswa_val2:=@tnzs_dip_a;
        marcade.dswb_val2:=@tnzs_dip_b;
  end;
  130:begin   //Insector X
        llamadas_maquina.bucle_general:=insectorx_principal;
        //Main CPU
        z80_0.change_ram_calls(insectorx_getbyte,insectorx_putbyte);
        if not(roms_load(@memoria_temp,insectorx_rom)) then exit;
        copymemory(@memoria,@memoria_temp,$8000);
        for f:=0 to 5 do copymemory(@main_rom[f+2,0],@memoria_temp[$8000+(f*$4000)],$4000);
        //Sound CPU
        z80_1.init_sound(tnzs_sound_update);
        z80_1.change_ram_calls(insectorx_snd_getbyte,insectorx_snd_putbyte);
        if not(roms_load(@memoria_temp,insectorx_sub)) then exit;
        copymemory(@mem_snd,@memoria_temp,$8000);
        for f:=0 to 3 do copymemory(@aux_rom[f,0],@memoria_temp[$8000+(f*$2000)],$2000);
        //Sound chip
        ym2203_0:=ym2203_chip.create(3000000);
        ym2203_0.change_io_calls(insectorx_porta_r,insectorx_portb_r,nil,nil);
        //convertir chars
        getmem(ptemp,$100000);
        if not(roms_load(ptemp,insectorx_gfx)) then exit;
        init_gfx(0,16,16,$2000);
        gfx[0].trans[0]:=true;
        gfx_set_desc_data(4,0,64*8,8,0,$2000*64*8+8,$2000*64*8+0);
        convert_gfx(0,0,ptemp,@pt2_x,@pt2_y,false,false);
        freemem(ptemp);
        marcade.dswa:=$fe;
        marcade.dswb:=$ff;
        marcade.dswa_val2:=@insectorx_dip_a;
        marcade.dswb_val2:=@insectorx_dip_b;
  end;
  306:begin   //Extermination
        llamadas_maquina.bucle_general:=extrmatn_principal_mcu;
        //Main CPU
        z80_0.change_ram_calls(tnzs_getbyte,tnzs_putbyte);
        if not(roms_load(@memoria_temp,extrmatn_rom)) then exit;
        copymemory(@memoria,@memoria_temp,$8000);
        for f:=0 to 5 do copymemory(@main_rom[f+2,0],@memoria_temp[$8000+(f*$4000)],$4000);
        //Misc CPU
        z80_1.init_sound(tnzs_sound_update);
        z80_1.change_ram_calls(extrmatn_snd_getbyte,extrmatn_snd_putbyte);
        if not(roms_load(@memoria_temp,extrmatn_sub)) then exit;
        copymemory(@mem_snd,@memoria_temp,$8000);
        for f:=0 to 3 do copymemory(@aux_rom[f,0],@memoria_temp[$8000+(f*$2000)],$2000);
        //MCU
        mcs48_0:=cpu_mcs48.create(6000000,$100*CPU_SYNC,I8042);
        mcs48_0.change_io_calls(extrmatn_mcu_inport,extrmatn_mcu_outport,nil,nil);
        if not(roms_load(mcs48_0.get_rom_addr,extrmatn_mcu)) then exit;
        //Sound chip
        ym2203_0:=ym2203_chip.create(3000000);
        ym2203_0.change_io_calls(insectorx_porta_r,insectorx_portb_r,nil,nil);
        //convertir chars
        getmem(ptemp,$100000);
        if not(roms_load(ptemp,extrmatn_gfx)) then exit;
        init_gfx(0,16,16,$1000);
        gfx[0].trans[0]:=true;
        gfx_set_desc_data(4,0,32*8,$1000*32*8*3,$1000*32*8*2,$1000*32*8,0);
        convert_gfx(0,0,ptemp,@pt_x,@pt_y,false,false);
        freemem(ptemp);
        marcade.dswa:=$ff;
        marcade.dswb:=$ff;
        marcade.dswa_val2:=@extrmatn_dip_a;
        marcade.dswb_val2:=@extrmatn_dip_b;
        if not(roms_load(@memoria_temp,extrmatn_pal)) then exit;
        for f:=0 to $1ff do begin
          tempw:=(memoria_temp[f] shl 8) or memoria_temp[f+512];
		      colores[f].r:=pal5bit(tempw shr 10);
		      colores[f].g:=pal5bit(tempw shr 5);
		      colores[f].b:=pal5bit(tempw shr 0);
        end;
        set_pal(colores,$200);
  end;
end;
//final
reset_tnzs;
iniciar_tnzs:=true;
end;

end.
