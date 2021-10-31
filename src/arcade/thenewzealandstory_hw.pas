unit thenewzealandstory_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,ym_2203,gfx_engine,rom_engine,pal_engine,
     sound_engine,seta_sprites;

procedure cargar_tnzs;

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
        tnzs_dip_a:array [0..5] of def_dip=(
        (mask:$1;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$1;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2;name:'Flip_Screen';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Invulnerability (Debug)';number:2;dip:((dip_val:$8;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Coin A';number:4;dip:((dip_val:$0;dip_name:'4 Coin 1 Credit'),(dip_val:$10;dip_name:'3 Coin 1 Credit'),(dip_val:$20;dip_name:'2 Coin 1 Credit'),(dip_val:$30;dip_name:'1 Coin 1 Credit'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Coin B';number:4;dip:((dip_val:$c0;dip_name:'1 Coin 2 Credit'),(dip_val:$80;dip_name:'1 Coin 3 Credit'),(dip_val:$40;dip_name:'1 Coin 4 Credit'),(dip_val:$0;dip_name:'1 Coin 6 Credit'),(),(),(),(),(),(),(),(),(),(),(),())),());
        tnzs_dip_b:array [0..4] of def_dip=(
        (mask:$3;name:'Difficulty';number:4;dip:((dip_val:$2;dip_name:'Easy'),(dip_val:$3;dip_name:'Medium'),(dip_val:$1;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Bonus Life';number:4;dip:((dip_val:$0;dip_name:'50k 150k 150k+'),(dip_val:$c;dip_name:'70k 200k 200k+'),(dip_val:$4;dip_name:'100k 250k 250k+'),(dip_val:$8;dip_name:'200k 300k 300k+'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Lives';number:4;dip:((dip_val:$20;dip_name:'2'),(dip_val:$30;dip_name:'3'),(dip_val:$0;dip_name:'4'),(dip_val:$10;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Allow Continue';number:2;dip:((dip_val:$0;dip_name:'No'),(dip_val:$40;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        //Insector X
        insectorx_rom:tipo_roms=(n:'b97-03.u32';l:$20000;p:0;crc:$18eef387);
        insectorx_sub:tipo_roms=(n:'b97-07.u38';l:$10000;p:0;crc:$324b28c9);
        insectorx_gfx:array[0..1] of tipo_roms=(
        (n:'b97-01.u1';l:$80000;p:0;crc:$d00294b1),(n:'b97-02.u2';l:$80000;p:$80000;crc:$db5a7434));
        //Dip
        insectorx_dip_a:array [0..5] of def_dip=(
        (mask:$1;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$1;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2;name:'Flip_Screen';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Demo_Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$8;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Coin A';number:4;dip:((dip_val:$0;dip_name:'4C 1C'),(dip_val:$10;dip_name:'3C 1C'),(dip_val:$20;dip_name:'2C 1C'),(dip_val:$30;dip_name:'1C 1C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Coin B';number:4;dip:((dip_val:$c0;dip_name:'1C 2C'),(dip_val:$80;dip_name:'1C 3C'),(dip_val:$40;dip_name:'1C 4C'),(dip_val:$0;dip_name:'1C 6C'),(),(),(),(),(),(),(),(),(),(),(),())),());
        insectorx_dip_b:array [0..3] of def_dip=(
        (mask:$3;name:'Difficulty';number:4;dip:((dip_val:$1;dip_name:'Easy'),(dip_val:$3;dip_name:'Medium'),(dip_val:$2;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Bonus Life';number:4;dip:((dip_val:$8;dip_name:'40k 240k 200k+'),(dip_val:$c;dip_name:'60k 360k 300k+'),(dip_val:$4;dip_name:'100k 500k 400k+'),(dip_val:$0;dip_name:'150k 650k 500k+'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Lives';number:4;dip:((dip_val:$0;dip_name:'1'),(dip_val:$10;dip_name:'2'),(dip_val:$30;dip_name:'3'),(dip_val:$20;dip_name:'4'),(),(),(),(),(),(),(),(),(),(),(),())),());
        CPU_SYNC=64;

var
 main_bank,misc_bank,sound_latch:byte;
 main_rom:array[0..7,0..$3fff] of byte;
 sub_rom:array[0..3,0..$1fff] of byte;

procedure update_video_tnzs;inline;
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
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  //marcade.in1
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
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
  frame_m,frame_s,frame_misc:single;
  f,h:byte;
begin
init_controls(false,false,false,true);
frame_m:=z80_0.tframes;
frame_s:=z80_1.tframes;
frame_misc:=z80_2.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
    for h:=1 to CPU_SYNC do begin
      //main
      z80_0.run(frame_m);
      frame_m:=frame_m+z80_0.tframes-z80_0.contador;
      //sub
      z80_1.run(frame_misc);
      frame_misc:=frame_misc+z80_1.tframes-z80_1.contador;
      //snd
      z80_2.run(frame_s);
      frame_s:=frame_s+z80_2.tframes-z80_2.contador;
    end;
    if f=239 then begin
      z80_0.change_irq(HOLD_LINE);
      z80_1.change_irq(HOLD_LINE);
      update_video_tnzs;
      seta_sprite0.tnzs_eof;
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
  $f300..$f3ff:tnzs_getbyte:=seta_sprite0.control[direccion and $3];
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
   $f300..$f3ff:seta_sprite0.control[direccion and $3]:=valor;
   $f400:seta_sprite0.bg_flag:=valor;
   $f600:begin
          if (valor and $10)<>0 then z80_1.change_reset(CLEAR_LINE)
            else z80_1.change_reset(ASSERT_LINE);
	        main_bank:=valor and $07;
        end;
   end;
end;

function tnzs_misc_getbyte(direccion:word):byte;
begin
  case direccion of
    $0000..$7fff,$d000..$dfff:tnzs_misc_getbyte:=mem_misc[direccion];
    $8000..$9fff:tnzs_misc_getbyte:=sub_rom[misc_bank,direccion and $1fff];
    $b002:tnzs_misc_getbyte:=marcade.dswa;
    $b003:tnzs_misc_getbyte:=marcade.dswb;
    $c000:tnzs_misc_getbyte:=marcade.in0;
    $c001:tnzs_misc_getbyte:=marcade.in1;
    $c002:tnzs_misc_getbyte:=marcade.in2;
    $e000..$efff:tnzs_misc_getbyte:=memoria[direccion];
    $f000..$f3ff:tnzs_misc_getbyte:=buffer_paleta[direccion and $3ff];
  end;
end;

procedure cambiar_color(dir:word);inline;
var
  tmp_color:word;
  color:tcolor;
begin
  tmp_color:=buffer_paleta[dir]+(buffer_paleta[dir+1] shl 8);
  color.r:=pal5bit(tmp_color shr 10);
  color.g:=pal5bit(tmp_color shr 5);
  color.b:=pal5bit(tmp_color);
  set_pal_color(color,(dir and $3ff) shr 1);
end;

procedure tnzs_misc_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$9fff:; //ROM
  $a000:misc_bank:=valor and $3;
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
  $0:tnzs_snd_inbyte:=ym2203_0.status;
  $1:tnzs_snd_inbyte:=ym2203_0.Read;
  $2:tnzs_snd_inbyte:=sound_latch;
end;
end;

procedure tnzs_snd_outbyte(puerto:word;valor:byte);
begin
case (puerto and $ff) of
  $0:ym2203_0.Control(valor);
  $1:ym2203_0.Write(valor);
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
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  //marcade.in1
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
  //marcade.in2
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or $8);
end;
end;

procedure insectorx_principal;
var
  frame_m,frame_misc:single;
  f,h:byte;
begin
init_controls(false,false,false,true);
frame_m:=z80_0.tframes;
frame_misc:=z80_1.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
    for h:=1 to CPU_SYNC do begin
      //main
      z80_0.run(frame_m);
      frame_m:=frame_m+z80_0.tframes-z80_0.contador;
      //sub
      z80_1.run(frame_misc);
      frame_misc:=frame_misc+z80_1.tframes-z80_1.contador;
    end;
    if f=239 then begin
      z80_0.change_irq(HOLD_LINE);
      z80_1.change_irq(HOLD_LINE);
      update_video_tnzs;
      seta_sprite0.tnzs_eof;
    end;
  end;
  eventos_insectorx;
  video_sync;
end;
end;

function insectorx_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff,$e000..$efff:insectorx_getbyte:=memoria[direccion];
  $8000..$bfff:insectorx_getbyte:=main_rom[main_bank,direccion and $3fff];
  $c000..$cfff:insectorx_getbyte:=seta_sprite0.spritelow[direccion and $fff];
  $d000..$dfff:insectorx_getbyte:=seta_sprite0.spritehigh[direccion and $fff];
  $f000..$f2ff:insectorx_getbyte:=seta_sprite0.spritey[direccion and $3ff];
  $f300..$f3ff:insectorx_getbyte:=seta_sprite0.control[direccion and $3];
  $f800..$fbff:insectorx_getbyte:=buffer_paleta[direccion and $3ff];
end;
end;

procedure insectorx_putbyte(direccion:word;valor:byte);
begin
case direccion of
   0..$7fff:; //ROM
   $8000..$bfff:if main_bank<2 then main_rom[main_bank,direccion and $3fff]:=valor;
   $c000..$cfff:seta_sprite0.spritelow[direccion and $fff]:=valor;
   $d000..$dfff:seta_sprite0.spritehigh[direccion and $fff]:=valor;
   $e000..$efff:memoria[direccion]:=valor;
   $f000..$f2ff:seta_sprite0.spritey[direccion and $3ff]:=valor;
   $f300..$f3ff:seta_sprite0.control[direccion and $3]:=valor;
   $f400:seta_sprite0.bg_flag:=valor;
   $f600:begin
          if (valor and $10)<>0 then z80_1.change_reset(CLEAR_LINE)
            else z80_1.change_reset(ASSERT_LINE);
	        main_bank:=valor and $07;
        end;
   $f800..$fbff:if buffer_paleta[direccion and $3ff]<>valor then begin
          buffer_paleta[direccion and $3ff]:=valor;
          cambiar_color(direccion and $3fe);
        end;
   end;
end;

function insectorx_misc_getbyte(direccion:word):byte;
begin
  case direccion of
    0..$7fff,$d000..$dfff:insectorx_misc_getbyte:=mem_misc[direccion];
    $8000..$9fff:insectorx_misc_getbyte:=sub_rom[misc_bank,direccion and $1fff];
    $b000:insectorx_misc_getbyte:=ym2203_0.status;
    $b001:insectorx_misc_getbyte:=ym2203_0.Read;
    $c000:insectorx_misc_getbyte:=marcade.in0;
    $c001:insectorx_misc_getbyte:=marcade.in1;
    $c002:insectorx_misc_getbyte:=marcade.in2;
    $e000..$efff:insectorx_misc_getbyte:=memoria[direccion];
    $f000..$f003:;
  end;
end;

procedure insectorx_misc_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$9fff:; //ROM
  $a000:misc_bank:=valor and $3;
  $b000:ym2203_0.Control(valor);
  $b001:ym2203_0.Write(valor);
  $d000..$dfff:mem_misc[direccion]:=valor;
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

procedure tnzs_sound_update;
begin
  ym2203_0.update;
end;

//Main
procedure reset_tnzs;
begin
 z80_0.reset;
 z80_1.reset;
 if main_vars.tipo_maquina=129 then z80_2.reset;
 YM2203_0.reset;
 reset_audio;
 seta_sprite0.reset;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 main_bank:=0;
 misc_bank:=0;
end;

function iniciar_tnzs:boolean;
var
  f:byte;
  memoria_temp:array[0..$1ffff] of byte;
  ptemp:pbyte;
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
iniciar_tnzs:=false;
iniciar_audio(false);
screen_init(1,512,256,false,true);
iniciar_video(256,224);
//Main CPU
z80_0:=cpu_z80.create(6000000,$100*CPU_SYNC);
//Misc CPU
z80_1:=cpu_z80.create(6000000,$100*CPU_SYNC);
//Video chips
seta_sprite0:=tseta_sprites.create(0,1,$800 div $40,$1fff);
//Sound Chips
ym2203_0:=ym2203_chip.create(3000000,2);
case main_vars.tipo_maquina of
  129:begin   //TNZS
        z80_0.change_ram_calls(tnzs_getbyte,tnzs_putbyte);
        //Misc CPU
        z80_1.change_ram_calls(tnzs_misc_getbyte,tnzs_misc_putbyte);
        //Sound CPU
        z80_2:=cpu_z80.create(6000000,$100*CPU_SYNC);
        z80_2.change_ram_calls(tnzs_snd_getbyte,tnzs_snd_putbyte);
        z80_2.change_io_calls(tnzs_snd_inbyte,tnzs_snd_outbyte);
        z80_2.init_sound(tnzs_sound_update);
        //Sound Chips
        ym2203_0.change_irq_calls(snd_irq);
        //cargar roms
        if not(roms_load(@memoria_temp,tnzs_rom)) then exit;
        copymemory(@memoria,@memoria_temp,$8000);
        for f:=0 to 5 do copymemory(@main_rom[f+2,0],@memoria_temp[$8000+(f*$4000)],$4000);
        //cargar ROMS misc
        if not(roms_load(@memoria_temp,tnzs_sub)) then exit;
        copymemory(@mem_misc,@memoria_temp,$8000);
        for f:=0 to 3 do copymemory(@sub_rom[f,0],@memoria_temp[$8000+(f*$2000)],$2000);
        //cargar ROMS sonido
        if not(roms_load(@mem_snd,tnzs_audio)) then exit;
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
        marcade.dswa_val:=@tnzs_dip_a;
        marcade.dswb_val:=@tnzs_dip_b;
  end;
  130:begin   //Insector X
        //Main CPU
        z80_0.change_ram_calls(insectorx_getbyte,insectorx_putbyte);
        //Misc CPU
        z80_1.init_sound(tnzs_sound_update);
        z80_1.change_ram_calls(insectorx_misc_getbyte,insectorx_misc_putbyte);
        //Sound chip
        ym2203_0.change_io_calls(insectorx_porta_r,insectorx_portb_r,nil,nil);
        //cargar roms
        if not(roms_load(@memoria_temp,insectorx_rom)) then exit;
        copymemory(@memoria,@memoria_temp,$8000);
        for f:=0 to 5 do copymemory(@main_rom[f+2,0],@memoria_temp[$8000+(f*$4000)],$4000);
        //cargar ROMS misc
        if not(roms_load(@memoria_temp,insectorx_sub)) then exit;
        copymemory(@mem_misc,@memoria_temp,$8000);
        for f:=0 to 3 do copymemory(@sub_rom[f,0],@memoria_temp[$8000+(f*$2000)],$2000);
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
        marcade.dswa_val:=@insectorx_dip_a;
        marcade.dswb_val:=@insectorx_dip_b;
  end;
end;
//final
reset_tnzs;
iniciar_tnzs:=true;
end;

procedure Cargar_tnzs;
begin
case main_vars.tipo_maquina of
  129:begin
        llamadas_maquina.fps_max:=59.15;
        llamadas_maquina.bucle_general:=tnzs_principal;
  end;
  130:llamadas_maquina.bucle_general:=insectorx_principal;
end;
llamadas_maquina.iniciar:=iniciar_tnzs;
llamadas_maquina.reset:=reset_tnzs;
end;

end.
