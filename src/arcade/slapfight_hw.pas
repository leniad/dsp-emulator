unit slapfight_hw;
interface

uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,gfx_engine,ay_8910,rom_engine,pal_engine,
     sound_engine,timer_engine,taito_68705;

function iniciar_sf_hw:boolean;

implementation
const
        //Tiger Heli
        tigerh_rom:array[0..2] of tipo_roms=(
        (n:'a47_00-1.8p';l:$4000;p:0;crc:$4be73246),(n:'a47_01-1.8n';l:$4000;p:$4000;crc:$aad04867),
        (n:'a47_02-1.8k';l:$4000;p:$8000;crc:$4843f15c));
        tigerh_snd:tipo_roms=(n:'a47_03.12d';l:$2000;p:0;crc:$d105260f);
        tigerh_mcu:tipo_roms=(n:'a47_14.6a';l:$800;p:0;crc:$4042489f);
        tigerh_pal:array[0..2] of tipo_roms=(
        (n:'82s129.12q';l:$100;p:0;crc:$2c69350d),(n:'82s129.12m';l:$100;p:$100;crc:$7142e972),
        (n:'82s129.12n';l:$100;p:$200;crc:$25f273f2));
        tigerh_char:array[0..1] of tipo_roms=(
        (n:'a47_05.6f';l:$2000;p:0;crc:$c5325b49),(n:'a47_04.6g';l:$2000;p:$2000;crc:$cd59628e));
        tigerh_sprites:array[0..3] of tipo_roms=(
        (n:'a47_13.8j';l:$4000;p:0;crc:$739a7e7e),(n:'a47_12.6j';l:$4000;p:$4000;crc:$c064ecdb),
        (n:'a47_11.8h';l:$4000;p:$8000;crc:$744fae9b),(n:'a47_10.6h';l:$4000;p:$c000;crc:$e1cf844e));
        tigerh_tiles:array[0..3] of tipo_roms=(
        (n:'a47_09.4m';l:$4000;p:0;crc:$31fae8a8),(n:'a47_08.6m';l:$4000;p:$4000;crc:$e539af2b),
        (n:'a47_07.6n';l:$4000;p:$8000;crc:$02fdd429),(n:'a47_06.6p';l:$4000;p:$c000;crc:$11fbcc8c));
        tigerh_dip_a:array [0..5] of def_dip2=(
        (mask:7;name:'Coinage';number:8;val8:(2,4,7,3,6,5,0,1);name8:('3C 1C','2C 1C','1C 1C','2C 3C','1C 2C','1C 3C','Free Play','Invalid')),
        (mask:8;name:'Demo Sounds';number:2;val2:(0,8);name2:('Off','On')),
        (mask:$10;name:'Cabinet';number:2;val2:(0,$10);name2:('Upright','Cocktail')),
        (mask:$20;name:'Flip Screen';number:2;val2:($20,0);name2:('Off','On')),
        (mask:$40;name:'Service';number:2;val2:($40,0);name2:('Off','On')),
        (mask:$80;name:'Player Speed';number:2;val2:($80,0);name2:('Normal','Fast')));
        tigerh_dip_b:array [0..2] of def_dip2=(
        (mask:3;name:'Lives';number:4;val4:(1,0,3,2);name4:('1','2','3','5')),
        (mask:$c;name:'Difficulty';number:4;val4:($c,8,4,0);name4:('Easy','Medium','Hard','Hardest')),
        (mask:$10;name:'Bonus Life';number:2;val2:($10,0);name2:('20K 80K+','50K 120K+')));
        //Slap Fight
        sf_rom:array[0..1] of tipo_roms=(
        (n:'a77_00.8p';l:$8000;p:0;crc:$674c0e0f),(n:'a77_01.8n';l:$8000;p:$8000;crc:$3c42e4a7));
        sf_snd:tipo_roms=(n:'a77_02.12d';l:$2000;p:0;crc:$87f4705a);
        sf_mcu:tipo_roms=(n:'a77_13.6a';l:$800;p:0;crc:$a70c81d9);
        sf_pal:array[0..2] of tipo_roms=(
        (n:'21_82s129.12q';l:$100;p:0;crc:$a0efaf99),(n:'20_82s129.12m';l:$100;p:$100;crc:$a56d57e5),
        (n:'19_82s129.12n';l:$100;p:$200;crc:$5cbf9fbf));
        sf_char:array[0..1] of tipo_roms=(
        (n:'a77_04.6f';l:$2000;p:0;crc:$2ac7b943),(n:'a77_03.6g';l:$2000;p:$2000;crc:$33cadc93));
        sf_sprites:array[0..3] of tipo_roms=(
        (n:'a77_12.8j';l:$8000;p:0;crc:$8545d397),(n:'a77_11.7j';l:$8000;p:$8000;crc:$b1b7b925),
        (n:'a77_10.8h';l:$8000;p:$10000;crc:$422d946b),(n:'a77_09.7h';l:$8000;p:$18000;crc:$587113ae));
        sf_tiles:array[0..3] of tipo_roms=(
        (n:'a77_08.6k';l:$8000;p:0;crc:$b6358305),(n:'a77_07.6m';l:$8000;p:$8000;crc:$e92d9d60),
        (n:'a77_06.6n';l:$8000;p:$10000;crc:$5faeeea3),(n:'a77_05.6p';l:$8000;p:$18000;crc:$974e2ea9));
        sf_dip_a:array [0..5] of def_dip2=(
        (mask:3;name:'Coin B';number:4;val4:(2,3,0,1);name4:('2C 1C','1C 1C','2C 3C','1C 2C')),
        (mask:$c;name:'Coin A';number:4;val4:(8,$c,0,4);name4:('2C 1C','1C 1C','2C 3C','1C 2C')),
        (mask:$10;name:'Demo Sounds';number:2;val2:(0,$10);name2:('Off','On')),
        (mask:$20;name:'Screen Test';number:2;val2:($20,0);name2:('Off','On')),
        (mask:$40;name:'Flip Screen';number:2;val2:($40,0);name2:('Off','On')),
        (mask:$80;name:'Cabinet';number:2;val2:(0,$80);name2:('Upright','Cocktail')));
        sf_dip_b:array [0..3] of def_dip2=(
        (mask:2;name:'Service';number:2;val2:(0,1);name2:('On','Off')),
        (mask:$c;name:'Lives';number:4;val4:(8,0,$c,4);name4:('1','2','3','5')),
        (mask:$30;name:'Bonus Life';number:4;val4:($30,$10,$20,0);name4:('30K 100K','50K 200K','50K','100K')),
        (mask:$c0;name:'Difficulty';number:4;val4:($40,$c0,$80,0);name4:('Easy','Medium','Hard','Hardest')));

var
 scroll_y:word;
 scroll_x,rom_bank,slapfight_status_state:byte;
 ena_irq,sound_nmi:boolean;
 rom:array[0..1,0..$3fff] of byte;

procedure update_video_sf_hw;
var
  f,x,y,color,nchar:word;
  atrib:byte;
begin
for f:=0 to $7ff do begin
  //Foreground
  if gfx[0].buffer[f] then begin
    x:=f div 64;
    y:=63-(f mod 64);
    atrib:=memoria[$f800+f];
    color:=atrib and $fc;
    nchar:=(memoria[$f000+f]+(atrib and 3) shl 8);
    put_gfx_trans(x*8,y*8,nchar,color,1,0);
    gfx[0].buffer[f]:=false;
  end;
  //Background
  if gfx[1].buffer[f] then begin
    x:=f div 64;
    y:=63-(f mod 64);
    atrib:=memoria[$d800+f];
    color:=atrib and $f0;
    nchar:=(memoria[$d000+f]+(atrib and $f) shl 8);
    put_gfx(x*8,y*8,nchar,color,2,1);
    gfx[1].buffer[f]:=false;
  end;
end;
scroll_x_y(2,3,scroll_x+17,736-scroll_y);
for f:=0 to $1ff do begin
  atrib:=memoria[$e002+(f*4)];
  nchar:=memoria[$e000+(f*4)]+((atrib and $c0) shl 2);
  color:=(atrib and $1e) shl 3;
  x:=memoria[$e003+(f*4)]-16;
  y:=797-(memoria[$e001+(f*4)]+((atrib and 1) shl 8));
  put_gfx_sprite(nchar,color,false,false,2);
  actualiza_gfx_sprite(x,y,3,2);
end;
actualiza_trozo(16,224,239,280,1,0,0,240,239,3);
actualiza_trozo_final(0,0,239,280,3);
end;

procedure eventos_sf_hw;
begin
if event.arcade then begin
  //P1 & P2
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.up[1] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.down[1] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.right[1] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.left[1] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  //System
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or 8);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.coin[0] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  if arcade_input.coin[1] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
end;
end;

procedure sf_hw_principal;
var
  f:word;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
  for f:=0 to 269 do begin
    eventos_sf_hw;
    if f=240 then begin
      if ena_irq then z80_0.change_irq(ASSERT_LINE);
      update_video_sf_hw;
    end;
    z80_0.run(frame_main);
    frame_main:=frame_main+z80_0.tframes-z80_0.contador;
    //Sound CPU
    z80_1.run(frame_snd);
    frame_snd:=frame_snd+z80_1.tframes-z80_1.contador;
    //MCU CPU
    taito_68705_0.run;
  end;
  video_sync;
end;
end;

//Slap Fight
function sf_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff,$c000..$e7ff,$f000..$ffff:sf_getbyte:=memoria[direccion];
  $8000..$bfff:sf_getbyte:=rom[rom_bank,direccion and $3fff];
  $e803:sf_getbyte:=taito_68705_0.read;
end;
end;

procedure sf_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$bfff:;
  $c000..$cfff,$e000..$e7ff:memoria[direccion]:=valor;
  $d000..$dfff:if memoria[direccion]<>valor then begin
                  gfx[1].buffer[direccion and $7ff]:=true;
                  memoria[direccion]:=valor;
               end;
  $e800:scroll_y:=(scroll_y and $ff00) or valor;
  $e801:scroll_y:=(scroll_y and $ff) or (valor shl 8);
  $e802:scroll_x:=valor;
  $e803:taito_68705_0.write(valor);
  $f000..$ffff:if memoria[direccion]<>valor then begin
                  gfx[0].buffer[direccion and $7ff]:=true;
                  memoria[direccion]:=valor;
               end;
end;
end;

function sf_inbyte(puerto:word):byte;
const
	states:array[0..2] of byte=($c7,$55,0);
begin
  if (puerto and $ff)=0 then begin
    sf_inbyte:=(states[slapfight_status_state] and $f9) or (byte(not(taito_68705_0.main_sent)) shl 1) or (byte(not(taito_68705_0.mcu_sent)) shl 2);
    slapfight_status_state:=(slapfight_status_state+1) and 3;
  end;
end;

procedure sf_outbyte(puerto:word;valor:byte);
begin
case (puerto and $ff) of
     0:z80_1.change_reset(ASSERT_LINE);
     1:begin
          z80_1.change_reset(CLEAR_LINE);
          sound_nmi:=false;
       end;
     2,3:; //flip screen
     6:begin
          ena_irq:=false;
          z80_0.change_irq(CLEAR_LINE);
       end;
     7:ena_irq:=true;
     8:rom_bank:=0;
     9:rom_bank:=1;
end;
end;

procedure sf_scroll_y(pos,valor:byte);
begin
  case pos of
    0:scroll_y:=(scroll_y and $ff00) or valor;
    1:scroll_y:=(scroll_y and $ff) or (valor shl 8);
  end;
end;

//Sound
function snd_sf_hw_getbyte(direccion:word):byte;
begin
case direccion of
  0..$1fff,$d000..$ffff:snd_sf_hw_getbyte:=mem_snd[direccion];
  $a081:snd_sf_hw_getbyte:=ay8910_0.read;
  $a091:snd_sf_hw_getbyte:=ay8910_1.read;
  $c800..$cfff:snd_sf_hw_getbyte:=memoria[direccion];
end;
end;

procedure snd_sf_hw_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$1fff:;
  $a080:ay8910_0.control(valor);
  $a082:ay8910_0.write(valor);
  $a090:ay8910_1.control(valor);
  $a092:ay8910_1.write(valor);
  $a0e0..$a0ef:sound_nmi:=(direccion and 1)=0;
  $c800..$cfff:memoria[direccion]:=valor;
  $d000..$ffff:mem_snd[direccion]:=valor;
end;
end;

function ay8910_porta_0:byte;
begin
  ay8910_porta_0:=marcade.in0;
end;

function ay8910_portb_0:byte;
begin
  ay8910_portb_0:=marcade.in1;
end;

function ay8910_porta_1:byte;
begin
  ay8910_porta_1:=marcade.dswa;
end;

function ay8910_portb_1:byte;
begin
  ay8910_portb_1:=marcade.dswb;
end;

procedure sf_hw_sound_update;
begin
  ay8910_0.update;
  ay8910_1.update;
end;

procedure sf_sound_nmi;
begin
  if sound_nmi then z80_1.change_nmi(PULSE_LINE);
end;

//Main
procedure reset_sf_hw;
begin
 z80_0.reset;
 z80_1.reset;
 z80_1.change_reset(ASSERT_LINE);
 frame_main:=z80_0.tframes;
 frame_snd:=z80_1.tframes;
 taito_68705_0.reset;
 ay8910_0.reset;
 ay8910_1.reset;
 ena_irq:=false;
 sound_nmi:=false;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 rom_bank:=0;
 slapfight_status_state:=0;
 scroll_y:=0;
 scroll_x:=0;
end;

function iniciar_sf_hw:boolean;
var
  colores:tpaleta;
  f:word;
  bit0,bit1,bit2,bit3:byte;
  memoria_temp:array[0..$1ffff] of byte;
const
  pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
  ps_x:array[0..15] of dword=(0, 1, 2, 3, 4, 5, 6, 7,
                              8, 9, 10 ,11, 12, 13, 14, 15);
  ps_y:array[0..15] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16,
		                        	8*16, 9*16, 10*16, 11*16, 12*16, 13*16, 14*16, 15*16);
procedure make_chars(num:word);
begin
  init_gfx(0,8,8,num);
  gfx[0].trans[0]:=true;
  gfx_set_desc_data(2,0,8*8,0*8*8,num*8*8);
  convert_gfx(0,0,@memoria_temp,@ps_x,@pc_y,false,true);
end;
procedure make_tiles(num:word);
begin
  init_gfx(1,8,8,num);
  gfx_set_desc_data(4,0,8*8,num*8*8*0,num*8*8*1,num*8*8*2,num*8*8*3);
  convert_gfx(1,0,@memoria_temp,@ps_x,@pc_y,false,true);
end;
procedure make_sprites(num:word);
begin
  init_gfx(2,16,16,num);
  gfx[2].trans[0]:=true;
  gfx_set_desc_data(4,0,32*8,num*32*8*0,num*32*8*1,num*32*8*2,num*32*8*3);
  convert_gfx(2,0,@memoria_temp,@ps_x,@ps_y,false,true);
end;
begin
llamadas_maquina.bucle_general:=sf_hw_principal;
llamadas_maquina.reset:=reset_sf_hw;
llamadas_maquina.fps_max:=36000000/6/388/270;
llamadas_maquina.scanlines:=270;
iniciar_sf_hw:=false;
iniciar_audio(false);
screen_init(1,256,512,true);
screen_init(2,256,512);
screen_init(3,256,512,false,true);
iniciar_video(239,280);
//Main CPU
z80_0:=cpu_z80.create(6000000);
z80_0.change_ram_calls(sf_getbyte,sf_putbyte);
z80_0.change_io_calls(sf_inbyte,sf_outbyte);
//Sound CPU
z80_1:=cpu_z80.create(3000000);
z80_1.change_ram_calls(snd_sf_hw_getbyte,snd_sf_hw_putbyte);
z80_1.init_sound(sf_hw_sound_update);
//Sound Chips
ay8910_0:=ay8910_chip.create(1500000,AY8910);
ay8910_0.change_io_calls(ay8910_porta_0,ay8910_portb_0,nil,nil);
ay8910_1:=ay8910_chip.create(1500000,AY8910);
ay8910_1.change_io_calls(ay8910_porta_1,ay8910_portb_1,nil,nil);
case main_vars.tipo_maquina of
  98:begin
      //SND CPU
      timers.init(z80_1.numero_cpu,3000000/360,sf_sound_nmi,nil,true);
      if not(roms_load(@mem_snd,tigerh_snd)) then exit;
      //MCU CPU
      taito_68705_0:=taito_68705p.create(3000000,TIGER_HELI);
      if not(roms_load(taito_68705_0.get_rom_addr,tigerh_mcu)) then exit;
      //cargar roms
      if not(roms_load(@memoria,tigerh_rom)) then exit;
      copymemory(@rom[0,0],@memoria[$8000],$4000);
      copymemory(@rom[1,0],@memoria[$8000],$4000);
      //convertir chars
      if not(roms_load(@memoria_temp,tigerh_char)) then exit;
      make_chars($400);
      //convertir tiles
      if not(roms_load(@memoria_temp,tigerh_tiles)) then exit;
      make_tiles($800);
      //convertir sprites
      if not(roms_load(@memoria_temp,tigerh_sprites)) then exit;
      make_sprites($200);
      //Dip
      init_dips(1,tigerh_dip_a,$6f);
      init_dips(2,tigerh_dip_b,$eb);
      //Poner colores
      if not(roms_load(@memoria_temp,tigerh_pal)) then exit;
  end;
  99:begin //Slap Fight
      //SND CPU
      timers.init(z80_1.numero_cpu,3000000/180,sf_sound_nmi,nil,true);
      if not(roms_load(@mem_snd,sf_snd)) then exit;
      //MCU CPU
      taito_68705_0:=taito_68705p.create(3000000);
      taito_68705_0.misc_call:=sf_scroll_y;
      if not(roms_load(taito_68705_0.get_rom_addr,sf_mcu)) then exit;
      //cargar roms
      if not(roms_load(@memoria_temp,sf_rom)) then exit;
      copymemory(@memoria[0],@memoria_temp[0],$8000);
      copymemory(@rom[0,0],@memoria_temp[$8000],$4000);
      copymemory(@rom[1,0],@memoria_temp[$c000],$4000);
      //convertir chars
      if not(roms_load(@memoria_temp,sf_char)) then exit;
      make_chars($400);
      //convertir tiles
      if not(roms_load(@memoria_temp,sf_tiles)) then exit;
      make_tiles($1000);
      //convertir sprites
      if not(roms_load(@memoria_temp,sf_sprites)) then exit;
      make_sprites($400);
      //Dip
      init_dips(1,sf_dip_a,$7f);
      init_dips(2,sf_dip_b,$ff);
      //Poner colores
      if not(roms_load(@memoria_temp,sf_pal)) then exit;
  end;
end;
for f:=0 to $ff do begin
    bit0:=(memoria_temp[f] shr 0) and 1;
		bit1:=(memoria_temp[f] shr 1) and 1;
		bit2:=(memoria_temp[f] shr 2) and 1;
    bit3:=(memoria_temp[f] shr 3) and 1;
		colores[f].r:=$e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
		bit0:=(memoria_temp[f+$100] shr 0) and 1;
		bit1:=(memoria_temp[f+$100] shr 1) and 1;
		bit2:=(memoria_temp[f+$100] shr 2) and 1;
    bit3:=(memoria_temp[f+$100] shr 3) and 1;
		colores[f].g:=$e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
		bit0:=(memoria_temp[f+$200] shr 0) and 1;
		bit1:=(memoria_temp[f+$200] shr 1) and 1;
		bit2:=(memoria_temp[f+$200] shr 2) and 1;
    bit3:=(memoria_temp[f+$200] shr 3) and 1;
		colores[f].b:=$e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
end;
set_pal(colores,$100);
iniciar_sf_hw:=true;
end;

end.
