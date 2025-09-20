unit galivan_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,gfx_engine,dac,rom_engine,pal_engine,
     sound_engine,timer_engine,ym_3812;

function iniciar_galivan:boolean;

implementation
const
        galivan_rom:array[0..2] of tipo_roms=(
        (n:'1.1b';l:$8000;p:0;crc:$1e66b3f8),(n:'2.3b';l:$4000;p:$8000;crc:$a45964f1),
        (n:'gv3.4b';l:$4000;p:$c000;crc:$82f0c5e6));
        galivan_sound:array[0..1] of tipo_roms=(
        (n:'gv11.14b';l:$4000;p:0;crc:$05f1a0e3),(n:'gv12.15b';l:$8000;p:$4000;crc:$5b7a0d6d));
        galivan_char:tipo_roms=(n:'gv4.13d';l:$4000;p:0;crc:$162490b4);
        galivan_fondo:array[0..3] of tipo_roms=(
        (n:'gv7.14f';l:$8000;p:0;crc:$eaa1a0db),(n:'gv8.15f';l:$8000;p:$8000;crc:$f174a41e),
        (n:'gv9.17f';l:$8000;p:$10000;crc:$edc60f5d),(n:'gv10.19f';l:$8000;p:$18000;crc:$41f27fca));
        galivan_sprites:array[0..1] of tipo_roms=(
        (n:'gv14.4f';l:$8000;p:0;crc:$03e2229f),(n:'gv13.1f';l:$8000;p:$8000;crc:$bca9e66b));
        galivan_bg_tiles:array[0..1] of tipo_roms=(
        (n:'gv6.19d';l:$4000;p:0;crc:$da38168b),(n:'gv5.17d';l:$4000;p:$4000;crc:$22492d2a));
        galivan_pal:array[0..4] of tipo_roms=(
        (n:'mb7114e.9f';l:$100;p:0;crc:$de782b3e),(n:'mb7114e.10f';l:$100;p:$100;crc:$0ae2a857),
        (n:'mb7114e.11f';l:$100;p:$200;crc:$7ba8b9d1),(n:'mb7114e.2d';l:$100;p:$300;crc:$75466109),
        (n:'mb7114e.7f';l:$100;p:$400;crc:$06538736));
        galivan_dip_a:array [0..6] of def_dip=(
        (mask:$3;name:'Lives';number:4;dip:((dip_val:$3;dip_name:'3'),(dip_val:$2;dip_name:'4'),(dip_val:$1;dip_name:'5'),(dip_val:$0;dip_name:'6'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Bonus Life';number:4;dip:((dip_val:$c;dip_name:'20K 60K+'),(dip_val:$8;dip_name:'50K 60K+'),(dip_val:$4;dip_name:'20K 90K+'),(dip_val:$0;dip_name:'50K 90K+'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$10;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$20;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Power Invulnerability';number:2;dip:((dip_val:$40;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Life Invulnerability';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        galivan_dip_b:array [0..4] of def_dip=(
        (mask:$3;name:'Coin A';number:4;dip:((dip_val:$1;dip_name:'2C 1C'),(dip_val:$3;dip_name:'1C 1C'),(dip_val:$2;dip_name:'1C 2C'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Coin B';number:4;dip:((dip_val:$0;dip_name:'3C 1C'),(dip_val:$4;dip_name:'2C 3C'),(dip_val:$c;dip_name:'1C 3C'),(dip_val:$8;dip_name:'1C 6C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Difficulty';number:2;dip:((dip_val:$10;dip_name:'Easy'),(dip_val:$0;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Flip Screen';number:2;dip:((dip_val:$20;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        dangar_rom:array[0..2] of tipo_roms=(
        (n:'8.1b';l:$8000;p:0;crc:$fe4a3fd6),(n:'9.3b';l:$4000;p:$8000;crc:$809d280f),
        (n:'10.4b';l:$4000;p:$c000;crc:$99a3591b));
        dangar_sound:array[0..1] of tipo_roms=(
        (n:'13.b14';l:$4000;p:0;crc:$3e041873),(n:'14.b15';l:$8000;p:$4000;crc:$488e3463));
        dangar_char:tipo_roms=(n:'5.13d';l:$4000;p:0;crc:$40cb378a);
        dangar_fondo:array[0..3] of tipo_roms=(
        (n:'1.14f';l:$8000;p:0;crc:$d59ed1f1),(n:'2.15f';l:$8000;p:$8000;crc:$dfdb931c),
        (n:'3.17f';l:$8000;p:$10000;crc:$6954e8c3),(n:'4.19f';l:$8000;p:$18000;crc:$4af6a8bf));
        dangar_sprites:array[0..1] of tipo_roms=(
        (n:'12.f4';l:$8000;p:0;crc:$55711884),(n:'11.f1';l:$8000;p:$8000;crc:$8cf11419));
        dangar_bg_tiles:array[0..1] of tipo_roms=(
        (n:'7.19d';l:$4000;p:0;crc:$6dba32cf),(n:'6.17d';l:$4000;p:$4000;crc:$6c899071));
        dangar_pal:array[0..4] of tipo_roms=(
        (n:'82s129.9f';l:$100;p:0;crc:$b29f6a07),(n:'82s129.10f';l:$100;p:$100;crc:$c6de5ecb),
        (n:'82s129.11f';l:$100;p:$200;crc:$a5bbd6dc),(n:'82s129.2d';l:$100;p:$300;crc:$a4ac95a5),
        (n:'82s129.7f';l:$100;p:$400;crc:$29bc6216));
        dangar_dip_a:array [0..5] of def_dip=(
        (mask:$3;name:'Lives';number:4;dip:((dip_val:$3;dip_name:'3'),(dip_val:$2;dip_name:'4'),(dip_val:$1;dip_name:'5'),(dip_val:$0;dip_name:'6'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Bonus Life';number:4;dip:((dip_val:$c;dip_name:'20K 60K+'),(dip_val:$8;dip_name:'50K 60K+'),(dip_val:$4;dip_name:'20K 90K+'),(dip_val:$0;dip_name:'50K 90K+'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$10;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$20;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Alternate Enemies';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        dangar_dip_b:array [0..5] of def_dip=(
        (mask:$3;name:'Coin A';number:4;dip:((dip_val:$1;dip_name:'2C 1C'),(dip_val:$3;dip_name:'1C 1C'),(dip_val:$2;dip_name:'1C 2C'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Coin B';number:4;dip:((dip_val:$4;dip_name:'2C 1C'),(dip_val:$c;dip_name:'1C 1C'),(dip_val:$0;dip_name:'2C 3C'),(dip_val:$8;dip_name:'1C 2C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Difficulty';number:2;dip:((dip_val:$10;dip_name:'Easy'),(dip_val:$0;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Flip Screen';number:2;dip:((dip_val:$20;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Allow Continue';number:4;dip:((dip_val:$c0;dip_name:'No'),(dip_val:$80;dip_name:'3 Times'),(dip_val:$40;dip_name:'5 Times'),(dip_val:$0;dip_name:'99 Times'),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 scroll_x,scroll_y:word;
 rom_mem:array[0..1,0..$1fff] of byte;
 spritebank:array[0..$ff] of byte;
 layers,rom_bank,sound_latch:byte;

procedure draw_sprites;
var
  atrib,color,f:byte;
  x,y,nchar:word;
begin
for f:=0 to $3f do begin
  atrib:=buffer_sprites[(f*4)+2];
  nchar:=buffer_sprites[(f*4)+1]+((atrib and $6) shl 7);
  y:=240-(buffer_sprites[(f*4)+3]-$80+((atrib and 1) shl 8));
  x:=240-(buffer_sprites[f*4] and $ff);
  color:=((atrib and $3c) shr 2)+16*(spritebank[nchar shr 2] and $f);
  put_gfx_sprite(nchar and $1ff,color shl 4,(atrib and $80)<>0,(atrib and $40)<>0,2);
  actualiza_gfx_sprite(x,y,4,2);
end;
end;

procedure update_video_galivan;
var
  f,color,x,y,nchar:word;
  atrib:byte;
begin
//background
if (layers and $40)<>0 then fill_full_screen(4,$100)
  else scroll_x_y(1,4,scroll_x,(1792-scroll_y) and $7ff);
//Text
if (layers and $80)=0 then begin
  for f:=$0 to $3ff do begin
    if gfx[0].buffer[f] then begin
        x:=f mod 32;
        y:=31-(f div 32);
        atrib:=memoria[$dc00+f];
        nchar:=memoria[$d800+f] or ((atrib and 1) shl 8);
        color:=(atrib and $78) shl 1;
        put_gfx_trans(x*8,y*8,nchar,color,2,0);
        if (atrib and 8)<>0 then put_gfx_block_trans(x*8,y*8,3,8,8)
          else put_gfx_trans(x*8,y*8,nchar,color,3,0);
        gfx[0].buffer[f]:=false;
    end;
  end;
end;
if (layers and $20)<>0 then begin
  if (layers and $80)=0 then actualiza_trozo(0,0,256,256,2,0,0,256,256,4);
  draw_sprites;
  if (layers and $80)=0 then actualiza_trozo(0,0,256,256,3,0,0,256,256,4);
end else begin
  if (layers and $80)=0 then actualiza_trozo(0,0,256,256,3,0,0,256,256,4);
  draw_sprites;
  if (layers and $80)=0 then actualiza_trozo(0,0,256,256,2,0,0,256,256,4);
end;
actualiza_trozo_final(16,0,224,256,4);
end;

procedure eventos_galivan;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or 8);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.but2[0] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
  //P2
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or 1);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or 2);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or 4);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or 8);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.but2[1] then marcade.in2:=(marcade.in2 and $7f) else marcade.in2:=(marcade.in2 or $80);
  //SYSTEM
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
end;
end;

procedure galivan_principal;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=z80_0.tframes;
frame_s:=z80_1.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to $ff do begin
  //main
  z80_0.run(frame_m);
  frame_m:=frame_m+z80_0.tframes-z80_0.contador;
  //sound
  z80_1.run(frame_s);
  frame_s:=frame_s+z80_1.tframes-z80_1.contador;
  if f=239 then begin
    update_video_galivan;
    copymemory(@buffer_sprites,@memoria[$e000],$100);
    z80_0.change_irq(ASSERT_LINE);
  end;
 end;
 eventos_galivan;
 video_sync;
end;
end;

function galivan_getbyte(direccion:word):byte;
begin
case direccion of
  0..$bfff,$e000..$ffff:galivan_getbyte:=memoria[direccion];
  $c000..$dfff:galivan_getbyte:=rom_mem[rom_bank,direccion and $1fff];
end;
end;

procedure galivan_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$d7ff:;
  $d800..$dfff:if memoria[direccion]<>valor then begin
      memoria[direccion]:=valor;
      gfx[0].buffer[direccion and $3ff]:=true;
    end;
  $e000..$ffff:memoria[direccion]:=valor;
end;
end;

function galivan_inbyte(puerto:word):byte;
begin
  case (puerto and $ff) of
    0:galivan_inbyte:=marcade.in1; //p1
    1:galivan_inbyte:=marcade.in2; //p2
    2:galivan_inbyte:=marcade.in0; //system
    3:galivan_inbyte:=marcade.dswa; //dsw1
    4:galivan_inbyte:=marcade.dswb; //dsw2
    $c0:galivan_inbyte:=$58;
  end;
end;

procedure galivan_outbyte(puerto:word;valor:byte);
begin
case (puerto and $ff) of
  $40:begin
        rom_bank:=(valor and $80) shr 7;
        main_screen.flip_main_screen:=(valor and $4)<>0;
      end;
  $41:scroll_y:=(scroll_y and $700) or valor;
  $42:begin
        scroll_y:=(scroll_y and $ff) or ((valor and $7) shl 8);
        layers:=valor and $e0;
      end;
  $43:scroll_x:=(scroll_x and $700) or valor;
  $44:scroll_x:=(scroll_x and $ff) or ((valor and $7) shl 8);
  $45:sound_latch:=((valor and $7f) shl 1) or 1;
  $47:z80_0.change_irq(CLEAR_LINE);
end;
end;

function galivan_snd_getbyte(direccion:word):byte;
begin
  galivan_snd_getbyte:=mem_snd[direccion];
end;

procedure galivan_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$bfff:;
  $c000..$c7ff:mem_snd[direccion]:=valor;
end;
end;

procedure galivan_snd_timer;
begin
  z80_1.change_irq(HOLD_LINE);
end;

function galivan_snd_inbyte(puerto:word):byte;
begin
case (puerto and $ff) of
  4:sound_latch:=0;
  6:galivan_snd_inbyte:=sound_latch;
end;
end;

procedure galivan_snd_outbyte(puerto:word;valor:byte);
begin
case (puerto and $ff) of
  $0:ym3812_0.control(valor);
  $1:ym3812_0.write(valor);
  $2:dac_0.signed_data8_w(valor);
  $3:dac_1.signed_data8_w(valor);
end;
end;

procedure galivan_sound_update;
begin
  ym3812_0.update;
  dac_0.update;
  dac_1.update;
end;

//Main
procedure reset_galivan;
begin
 z80_0.reset;
 z80_1.reset;
 ym3812_0.reset;
 dac_0.reset;
 dac_1.reset;
 reset_audio;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 scroll_x:=0;
 scroll_y:=0;
 sound_latch:=0;
 layers:=0;
 rom_bank:=0;
end;

function iniciar_galivan:boolean;
var
  colores:tpaleta;
  f:word;
  tempb:byte;
  memoria_temp:array[0..$1ffff] of byte;
  bg_temp:array[0..$7fff] of byte;
const
  pc_x:array[0..7] of dword=(1*4, 0*4, 3*4, 2*4, 5*4, 4*4, 7*4, 6*4);
  ps_x:array[0..15] of dword=(4, 0, 4+$8000*8, 0+$8000*8, 12, 8, 12+$8000*8, 8+$8000*8,
		20, 16, 20+$8000*8, 16+$8000*8, 28, 24, 28+$8000*8, 24+$8000*8);
  ps_y:array[0..15] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32,
          8*32, 9*32, 10*32, 11*32, 12*32, 13*32, 14*32, 15*32);
  pf_x:array[0..15] of dword=(4, 0, 12, 8, 20, 16, 28, 24,
		32+4, 32+0, 32+12, 32+8, 32+20, 32+16, 32+28, 32+24);
  pf_y:array[0..15] of dword=(0*64, 1*64, 2*64, 3*64, 4*64, 5*64, 6*64, 7*64,
		8*64, 9*64, 10*64, 11*64, 12*64, 13*64, 14*64, 15*64);
procedure convert_chars;
begin
  init_gfx(0,8,8,$200);
  gfx[0].trans[15]:=true;
  gfx_set_desc_data(4,0,32*8,0,1,2,3);
  convert_gfx(0,0,@memoria_temp,@pc_x,@ps_y,false,true);
end;
procedure convert_fg;
begin
  init_gfx(1,16,16,$400);
  gfx_set_desc_data(4,0,64*16,0,1,2,3);
  convert_gfx(1,0,@memoria_temp,@pf_x,@pf_y,false,true);
end;
procedure convert_sprites;
begin
  init_gfx(2,16,16,$200);
  gfx[2].trans[15]:=true;
  gfx_set_desc_data(4,0,32*16,0,1,2,3);
  convert_gfx(2,0,@memoria_temp,@ps_x,@ps_y,false,true);
end;
procedure put_bg;
var
  f,nchar:word;
  x,y,atrib,color:byte;
begin
  for f:=$0 to $3fff do begin
    x:=f div 128;
    y:=127-(f mod 128);
    atrib:=bg_temp[f+$4000];
    nchar:=bg_temp[f] or ((atrib and $3) shl 8);
    color:=(atrib and $78) shl 1;
    put_gfx(x*16,y*16,nchar,color,1,1);
  end;
end;
begin
llamadas_maquina.bucle_general:=galivan_principal;
llamadas_maquina.reset:=reset_galivan;
iniciar_galivan:=false;
iniciar_audio(false);
screen_init(1,2048,2048);
screen_mod_scroll(1,2048,2048,2047,2048,2048,2047);
screen_init(2,256,256,true);
screen_init(3,256,256,true);
screen_init(4,256,512,false,true);
iniciar_video(224,256);
//Main CPU
z80_0:=cpu_z80.create(6000000,256);
z80_0.change_io_calls(galivan_inbyte,galivan_outbyte);
z80_0.change_ram_calls(galivan_getbyte,galivan_putbyte);
//Sound CPU
z80_1:=cpu_z80.create(4000000,256);
z80_1.change_ram_calls(galivan_snd_getbyte,galivan_snd_putbyte);
z80_1.change_io_calls(galivan_snd_inbyte,galivan_snd_outbyte);
z80_1.init_sound(galivan_sound_update);
case main_vars.tipo_maquina of
  266:begin //Galivan
      //cargar roms
      if not(roms_load(@memoria_temp,galivan_rom)) then exit;
      copymemory(@memoria[0],@memoria_temp[0],$c000);
      copymemory(@rom_mem[0,0],@memoria_temp[$c000],$2000);
      copymemory(@rom_mem[1,0],@memoria_temp[$e000],$2000);
      //cargar sonido
      if not(roms_load(@mem_snd,galivan_sound)) then exit;
      //Sound Chips
      ym3812_0:=ym3812_chip.create(YM3526_FM,4000000,0.3);
      //convertir chars
      if not(roms_load(@memoria_temp,galivan_char)) then exit;
      convert_chars;
      //convertir fondo
      if not(roms_load(@memoria_temp,galivan_fondo)) then exit;
      convert_fg;
      //convertir sprites
      if not(roms_load(@memoria_temp,galivan_sprites)) then exit;
      convert_sprites;
      //tiles de bg y lo pongo en la pantalla 1
      if not(roms_load(@bg_temp,galivan_bg_tiles)) then exit;
      //DIP
      marcade.dswa:=$df;
      marcade.dswa_val:=@galivan_dip_a;
      marcade.dswb:=$ff;
      marcade.dswb_val:=@galivan_dip_b;
      //poner la paleta
      if not(roms_load(@memoria_temp,galivan_pal)) then exit;
      copymemory(@spritebank,@memoria_temp[$400],$100);
      end;
  267:begin //Dangar
      //cargar roms
      if not(roms_load(@memoria_temp,dangar_rom)) then exit;
      copymemory(@memoria[0],@memoria_temp[0],$c000);
      copymemory(@rom_mem[0,0],@memoria_temp[$c000],$2000);
      copymemory(@rom_mem[1,0],@memoria_temp[$e000],$2000);
      //cargar sonido
      if not(roms_load(@mem_snd,dangar_sound)) then exit;
      //Sound Chips
      ym3812_0:=ym3812_chip.create(YM3526_FM,4000000,0.3);
      //convertir chars
      if not(roms_load(@memoria_temp,dangar_char)) then exit;
      convert_chars;
      //convertir fondo
      if not(roms_load(@memoria_temp,dangar_fondo)) then exit;
      convert_fg;
      //convertir sprites
      if not(roms_load(@memoria_temp,dangar_sprites)) then exit;
      convert_sprites;
      //tiles de bg y lo pongo en la pantalla 1
      if not(roms_load(@bg_temp,dangar_bg_tiles)) then exit;
      //DIP
      marcade.dswa:=$df;
      marcade.dswa_val:=@dangar_dip_a;
      marcade.dswb:=$7f;
      marcade.dswb_val:=@dangar_dip_b;
      //poner la paleta
      if not(roms_load(@memoria_temp,dangar_pal)) then exit;
      copymemory(@spritebank,@memoria_temp[$400],$100);
      end;
end;
dac_0:=dac_chip.Create(0.5);
dac_1:=dac_chip.Create(0.5);
timers.init(z80_1.numero_cpu,4000000/(4000000/512),galivan_snd_timer,nil,true);
for f:=0 to $ff do begin
  colores[f].r:=pal4bit(memoria_temp[f]);
  colores[f].g:=pal4bit(memoria_temp[f+$100]);
  colores[f].b:=pal4bit(memoria_temp[f+$200]);
  //lookup de chars
  if (f and 8)<>0 then gfx[0].colores[f]:=(f and $0f) or ((f shr 2) and $30)
		  else gfx[0].colores[f]:=(f and $0f)or ((f shr 0) and $30);
  //color lookup de fondo
  if (f and 8)<>0 then gfx[1].colores[f]:=$c0 or (f and $0f) or ((f shr 2) and $30)
		  else gfx[1].colores[f]:=$c0 or (f and $0f) or ((f shr 0) and $30);
end;
//color lookup de sprites
for f:=0 to $fff do begin
  if (f and $8)<>0 then tempb:=$80 or ((f shl 2) and $30) or (memoria_temp[$300+(f shr 4)] and $f)
    else tempb:=$80 or ((f shl 4) and $30) or (memoria_temp[$300+(f shr 4)] and $f);
  gfx[2].colores[((f and $f) shl 8) or ((f and $ff0) shr 4)]:=tempb;
end;
set_pal(colores,$100);
//Despues de poner la paleta, pongo el fondo...
put_bg;
//final
reset_galivan;
iniciar_galivan:=true;
end;

end.
