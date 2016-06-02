unit slapfight_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,gfx_engine,ay_8910,rom_engine,pal_engine,
     m6805,sound_engine,timer_engine;

procedure Cargar_sf_hw;
function iniciar_sf_hw:boolean;
procedure reset_sf_hw;
//Slap Fight
procedure sf_hw_principal;
function sf_getbyte(direccion:word):byte;
procedure sf_putbyte(direccion:word;valor:byte);
function sf_inbyte(puerto:word):byte;
procedure sf_outbyte(valor:byte;puerto:word);
//Sound
function snd_sf_hw_getbyte(direccion:word):byte;
procedure snd_sf_hw_putbyte(direccion:word;valor:byte);
function ay8910_porta_0:byte;
function ay8910_portb_0:byte;
function ay8910_porta_1:byte;
function ay8910_portb_1:byte;
procedure sf_hw_sound_update;
procedure sf_sound_nmi;
//MCU CPU
function mcu_sf_hw_getbyte(direccion:word):byte;
procedure mcu_sf_hw_putbyte(direccion:word;valor:byte);
function mcu_tigerh_hw_getbyte(direccion:word):byte;
procedure mcu_tigerh_hw_putbyte(direccion:word;valor:byte);

implementation
const
        //Tiger Heli
        tigerh_rom:array[0..3] of tipo_roms=(
        (n:'0.4';l:$4000;p:0;crc:$4be73246),(n:'1.4';l:$4000;p:$4000;crc:$aad04867),
        (n:'2.4';l:$4000;p:$8000;crc:$4843f15c),());
        tigerh_snd:tipo_roms=(n:'a47_03.12d';l:$2000;p:0;crc:$d105260f);
        tigerh_mcu:tipo_roms=(n:'a47_14.6a';l:$800;p:0;crc:$4042489f);
        tigerh_pal:array[0..3] of tipo_roms=(
        (n:'82s129.12q';l:$100;p:0;crc:$2c69350d),(n:'82s129.12m';l:$100;p:$100;crc:$7142e972),
        (n:'82s129.12n';l:$100;p:$200;crc:$25f273f2),());
        tigerh_char:array[0..2] of tipo_roms=(
        (n:'a47_05.6f';l:$2000;p:0;crc:$c5325b49),(n:'a47_04.6g';l:$2000;p:$2000;crc:$cd59628e),());
        tigerh_sprites:array[0..4] of tipo_roms=(
        (n:'a47_13.8j';l:$4000;p:0;crc:$739a7e7e),(n:'a47_12.6j';l:$4000;p:$4000;crc:$c064ecdb),
        (n:'a47_11.8h';l:$4000;p:$8000;crc:$744fae9b),(n:'a47_10.6h';l:$4000;p:$c000;crc:$e1cf844e),());
        tigerh_tiles:array[0..4] of tipo_roms=(
        (n:'a47_09.4m';l:$4000;p:0;crc:$31fae8a8),(n:'a47_08.6m';l:$4000;p:$4000;crc:$e539af2b),
        (n:'a47_07.6n';l:$4000;p:$8000;crc:$02fdd429),(n:'a47_06.6p';l:$4000;p:$c000;crc:$11fbcc8c),());
        //Slap Fight
        sf_rom:array[0..2] of tipo_roms=(
        (n:'a77_00.8p';l:$8000;p:0;crc:$674c0e0f),(n:'a77_01.8n';l:$8000;p:$8000;crc:$3c42e4a7),());
        sf_snd:tipo_roms=(n:'a77_02.12d';l:$2000;p:0;crc:$87f4705a);
        sf_mcu:tipo_roms=(n:'a77_13.6a';l:$800;p:0;crc:$a70c81d9);
        sf_pal:array[0..3] of tipo_roms=(
        (n:'21_82s129.12q';l:$100;p:0;crc:$a0efaf99),(n:'20_82s129.12m';l:$100;p:$100;crc:$a56d57e5),
        (n:'19_82s129.12n';l:$100;p:$200;crc:$5cbf9fbf),());
        sf_char:array[0..2] of tipo_roms=(
        (n:'a77_04.6f';l:$2000;p:0;crc:$2ac7b943),(n:'a77_03.6g';l:$2000;p:$2000;crc:$33cadc93),());
        sf_sprites:array[0..4] of tipo_roms=(
        (n:'a77_12.8j';l:$8000;p:0;crc:$8545d397),(n:'a77_11.7j';l:$8000;p:$8000;crc:$b1b7b925),
        (n:'a77_10.8h';l:$8000;p:$10000;crc:$422d946b),(n:'a77_09.7h';l:$8000;p:$18000;crc:$587113ae),());
        sf_tiles:array[0..4] of tipo_roms=(
        (n:'a77_08.6k';l:$8000;p:0;crc:$b6358305),(n:'a77_07.6m';l:$8000;p:$8000;crc:$e92d9d60),
        (n:'a77_06.6n';l:$8000;p:$10000;crc:$5faeeea3),(n:'a77_05.6p';l:$8000;p:$18000;crc:$974e2ea9),());

var
 scroll_y:word;
 scroll_x,rom_bank,tiles_mask,sprite_mask,slapfight_status_state:byte;
 ena_irq:boolean;
 rom:array[0..1,0..$3fff] of byte;
 //mcu
 mcu_ram:array[0..$7ff] of byte;
 portc_in,portc_out,portb_out,portb_in,porta_in,porta_out,ddra,ddrb,ddrc:byte;
 mcu_sent,from_main,main_sent,from_mcu:byte;

procedure Cargar_sf_hw;
begin
llamadas_maquina.bucle_general:=sf_hw_principal;
llamadas_maquina.iniciar:=iniciar_sf_hw;
llamadas_maquina.reset:=reset_sf_hw;
end;

function iniciar_sf_hw:boolean;
var
      colores:tpaleta;
      f:word;
      bit0,bit1,bit2,bit3:byte;
      memoria_temp:array[0..$1ffff] of byte;
const
      pc_x:array[0..7] of dword=(0, 1, 2, 3, 4, 5, 6, 7);
      pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
      ps_x:array[0..15] of dword=(0, 1, 2, 3, 4, 5, 6, 7, 8,
			9, 10 ,11, 12, 13, 14, 15);
      ps_y:array[0..15] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16,
			8*16, 9*16, 10*16, 11*16, 12*16, 13*16, 14*16, 15*16);
procedure make_chars(num:word);
begin
init_gfx(0,8,8,num);
gfx[0].trans[0]:=true;
gfx_set_desc_data(2,0,8*8,0*8*8,num*8*8);
convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,true);
end;
procedure make_tiles(num:word);
begin
  init_gfx(1,8,8,num);
  gfx_set_desc_data(4,0,8*8,num*8*8*0,num*8*8*1,num*8*8*2,num*8*8*3);
  convert_gfx(1,0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,true);
end;
procedure make_sprites(num:word);
begin
  init_gfx(2,16,16,num);
  gfx[2].trans[0]:=true;
  gfx_set_desc_data(4,0,32*8,num*32*8*0,num*32*8*1,num*32*8*2,num*32*8*3);
  convert_gfx(2,0,@memoria_temp[0],@ps_x[0],@ps_y[0],false,true);
end;

begin
iniciar_sf_hw:=false;
iniciar_audio(false);
//Pantallas:  principal+char y sprites
screen_init(1,256,512,true);
screen_init(2,256,512);
screen_mod_scroll(2,256,256,255,512,512,511);
screen_init(3,256,512,false,true);
iniciar_video(239,280);
//Main CPU
main_z80:=cpu_z80.create(6000000,256);
main_z80.change_ram_calls(sf_getbyte,sf_putbyte);
main_z80.change_io_calls(sf_inbyte,sf_outbyte);
//Sound CPU
snd_z80:=cpu_z80.create(3000000,256);
snd_z80.change_ram_calls(snd_sf_hw_getbyte,snd_sf_hw_putbyte);
snd_z80.init_sound(sf_hw_sound_update);
//MCU
main_m6805:=cpu_m6805.create(3000000,256,tipo_m68705);
//Sound Chips
ay8910_0:=ay8910_chip.create(1500000,1);
ay8910_0.change_io_calls(ay8910_porta_0,ay8910_portb_0,nil,nil);
ay8910_1:=ay8910_chip.create(1500000,1);
ay8910_1.change_io_calls(ay8910_porta_1,ay8910_portb_1,nil,nil);
case main_vars.tipo_maquina of
  98:begin
      //SND CPU
      init_timer(snd_z80.numero_cpu,3000000/360,sf_sound_nmi,true);
      //MCU CPU
      main_m6805.change_ram_calls(mcu_tigerh_hw_getbyte,mcu_tigerh_hw_putbyte);
      tiles_mask:=$7;
      sprite_mask:=$40;
      //cargar roms
      if not(cargar_roms(@memoria[0],@tigerh_rom[0],'tigerh.zip',0)) then exit;
      copymemory(@rom[0,0],@memoria[$8000],$4000);
      copymemory(@rom[1,0],@memoria[$8000],$4000);
      //cargar roms snd
      if not(cargar_roms(@mem_snd[0],@tigerh_snd,'tigerh.zip',1)) then exit;
      //cargar roms mcu
      if not(cargar_roms(@mcu_ram[0],@tigerh_mcu,'tigerh.zip',1)) then exit;
      //convertir chars
      if not(cargar_roms(@memoria_temp[0],@tigerh_char[0],'tigerh.zip',0)) then exit;
      make_chars($400);
      //convertir tiles
      if not(cargar_roms(@memoria_temp[0],@tigerh_tiles[0],'tigerh.zip',0)) then exit;
      make_tiles($800);
      //convertir sprites
      if not(cargar_roms(@memoria_temp[0],@tigerh_sprites[0],'tigerh.zip',0)) then exit;
      make_sprites($200);
      //Poner colores
      if not(cargar_roms(@memoria_temp[0],@tigerh_pal[0],'tigerh.zip',0)) then exit;
  end;
  99:begin
      //SND CPU
      init_timer(snd_z80.numero_cpu,3000000/180,sf_sound_nmi,true);
      //MCU CPU
      main_m6805.change_ram_calls(mcu_sf_hw_getbyte,mcu_sf_hw_putbyte);
      tiles_mask:=$f;
      sprite_mask:=$c0;
      //cargar roms
      if not(cargar_roms(@memoria_temp[0],@sf_rom[0],'slapfigh.zip',0)) then exit;
      copymemory(@memoria[0],@memoria_temp[0],$8000);
      copymemory(@rom[0,0],@memoria_temp[$8000],$4000);
      copymemory(@rom[1,0],@memoria_temp[$c000],$4000);
      //cargar roms snd
      if not(cargar_roms(@mem_snd[0],@sf_snd,'slapfigh.zip',1)) then exit;
      //cargar roms mcu
      if not(cargar_roms(@mcu_ram[0],@sf_mcu,'slapfigh.zip',1)) then exit;
      //convertir chars
      if not(cargar_roms(@memoria_temp[0],@sf_char[0],'slapfigh.zip',0)) then exit;
      make_chars($400);
      //convertir tiles
      if not(cargar_roms(@memoria_temp[0],@sf_tiles[0],'slapfigh.zip',0)) then exit;
      make_tiles($1000);
      //convertir sprites
      if not(cargar_roms(@memoria_temp[0],@sf_sprites[0],'slapfigh.zip',0)) then exit;
      make_sprites($400);
      //Poner colores
      if not(cargar_roms(@memoria_temp[0],@sf_pal[0],'slapfigh.zip',0)) then exit;
  end;
end;
for f:=0 to $ff do begin
    bit0:=(memoria_temp[f] shr 0) and $01;
		bit1:=(memoria_temp[f] shr 1) and $01;
		bit2:=(memoria_temp[f] shr 2) and $01;
    bit3:=(memoria_temp[f] shr 3) and $01;
		colores[f].r:=$0e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
		bit0:=(memoria_temp[f+$100] shr 0) and $01;
		bit1:=(memoria_temp[f+$100] shr 1) and $01;
		bit2:=(memoria_temp[f+$100] shr 2) and $01;
    bit3:=(memoria_temp[f+$100] shr 3) and $01;
		colores[f].g:=$0e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
		bit0:=(memoria_temp[f+$200] shr 0) and $01;
		bit1:=(memoria_temp[f+$200] shr 1) and $01;
		bit2:=(memoria_temp[f+$200] shr 2) and $01;
    bit3:=(memoria_temp[f+$200] shr 3) and $01;
		colores[f].b:=$0e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
end;
set_pal(colores,$100);
reset_sf_hw;
iniciar_sf_hw:=true;
end;

procedure reset_sf_hw;
begin
 main_z80.reset;
 snd_z80.reset;
 main_m6805.reset;
 AY8910_0.reset;
 AY8910_1.reset;
 reset_audio;
 ena_irq:=false;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 rom_bank:=0;
 slapfight_status_state:=$c7;
 scroll_y:=0;
 scroll_x:=0;
 //mcu
 porta_in:=0;
 porta_out:=0;
 ddra:=0;
 portb_in:=0;
 portb_out:=0;
 ddrb:=0;
 portc_in:=0;
 portc_out:=0;
 ddrc:=0;
 mcu_sent:=0;
 main_sent:=0;
 from_main:=0;
 from_mcu:=0;
end;

procedure update_video_sf_hw;inline;
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
    nchar:=(memoria[$f000+f]+(atrib and $3) shl 8);
    put_gfx_trans(x*8,y*8,nchar,color,1,0);
    gfx[0].buffer[f]:=false;
  end;
  //Background
  if gfx[1].buffer[f] then begin
    x:=f div 64;
    y:=63-(f mod 64);
    atrib:=memoria[$d800+f];
    color:=atrib and $f0;
    nchar:=(memoria[$d000+f]+(atrib and tiles_mask) shl 8);
    put_gfx(x*8,y*8,nchar,color,2,1);
    gfx[1].buffer[f]:=false;
  end;
end;
scroll_x_y(2,3,scroll_x+15,736-scroll_y);
for f:=0 to $1ff do begin
  atrib:=buffer_sprites[(f*4)+$2];
  nchar:=buffer_sprites[$0+(f*4)] + ((atrib and sprite_mask) shl 2);
  color:=(atrib and $1e) shl 3;
  x:=buffer_sprites[(f*4)+$3]-16;
  y:=797-(buffer_sprites[(f*4)+$1]+((atrib and $01) shl 8));
  put_gfx_sprite(nchar,color,false,false,2);
  actualiza_gfx_sprite(x,y,3,2);
end;
actualiza_trozo(16,224,239,280,1,0,0,240,239,3);
actualiza_trozo_final(0,0,239,280,3);
end;

procedure eventos_sf_hw;
begin
if event.arcade then begin
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $Fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $F7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.coin[0] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  if arcade_input.coin[1] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
end;
end;

procedure sf_hw_principal;
var
  f:byte;
  frame_m,frame_s,frame_mcu:single;
begin
init_controls(false,false,false,true);
frame_m:=main_z80.tframes;
frame_s:=snd_z80.tframes;
frame_mcu:=main_m6805.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
    main_z80.run(frame_m);
    frame_m:=frame_m+main_z80.tframes-main_z80.contador;
    //Sound CPU
    snd_z80.run(frame_s);
    frame_s:=frame_s+snd_z80.tframes-snd_z80.contador;
    //MCU CPU
    main_m6805.run(frame_mcu);
    frame_mcu:=frame_mcu+main_m6805.tframes-main_m6805.contador;
  end;
  if ena_irq then main_z80.pedir_irq:=HOLD_LINE;
  update_video_sf_hw;
  copymemory(@buffer_sprites[0],@memoria[$e000],$800);
  eventos_sf_hw;
  video_sync;
end;
end;

//Tiger Heli
function tigerh_port_00_r:byte;
const
	states:array[0..2] of byte=($c7,$55,$00);
begin
	tigerh_port_00_r:=states[slapfight_status_state];
	slapfight_status_state:=slapfight_status_state+1;
	if (slapfight_status_state>2) then slapfight_status_state:=0;
end;

function mcu_tigerh_hw_getbyte(direccion:word):byte;
begin
direccion:=direccion and $7ff;
case direccion of
  0:mcu_tigerh_hw_getbyte:=(portA_out and ddrA) or (portA_in and not(ddrA));
	1:mcu_tigerh_hw_getbyte:=(portB_out and ddrB) or (portB_in and not(ddrB));
	2:begin
      portC_in:=0;
	    if (main_sent=0) then portC_in:=portC_in or $01;
	    if (mcu_sent<>0) then portC_in:=portC_in or $02;
      mcu_tigerh_hw_getbyte:=(portC_out and ddrC) or (portC_in and not(ddrC));
    end;
  else mcu_tigerh_hw_getbyte:=mcu_ram[direccion];
end;
end;

procedure mcu_tigerh_hw_putbyte(direccion:word;valor:byte);
begin
direccion:=direccion and $7ff;
if direccion>$7f then exit;
mcu_ram[direccion]:=valor;
case direccion of
  0:begin
      portA_out:=valor;
      from_mcu:=portA_out;
	    mcu_sent:=1;
    end;
	1:begin
      if (((ddrB and $02)<>0) and ((not(valor) and  $02)<>0) and ((portB_out and $02)<>0)) then begin
		    portA_in:=from_main;
		    if (main_sent<>0) then main_m6805.irq_request(0,CLEAR_LINE);
    		main_sent:=0;
      end;
    	if (((ddrB and $04)<>0) and ((valor and $04)<>0) and ((not(portB_out) and $04)<>0)) then begin
    		from_mcu:=portA_out;
    		mcu_sent:=1;
    	end;
    	portB_out:=valor;
  end;
	2:portc_out:=valor;
	4:ddra:=valor;
	5:ddrb:=valor;
	6:ddrc:=valor;
end;
end;

//Slap Fight
function sf_getbyte(direccion:word):byte;
begin
case direccion of
  $8000..$bfff:sf_getbyte:=rom[rom_bank,direccion and $3fff];
  $e803:begin
          mcu_sent:=0;
          sf_getbyte:=from_mcu;
        end;
  else sf_getbyte:=memoria[direccion];
end;
end;

procedure sf_putbyte(direccion:word;valor:byte);
begin
if direccion<$c000 then exit;
memoria[direccion]:=valor;
case direccion of
  $d000..$dfff:gfx[1].buffer[direccion and $7ff]:=true;
  $e800:scroll_y:=(scroll_y and $ff00)+valor;
  $e801:scroll_y:=(scroll_y and $ff)+(valor shl 8);
  $e802:scroll_x:=valor;
  $e803:begin
          from_main:=valor;
         	main_sent:=1;
          mcu_sent:=0;
          main_m6805.irq_request(0,ASSERT_LINE);
        end;
  $f000..$ffff:gfx[0].buffer[direccion and $7ff]:=true;
end;
end;

function sf_inbyte(puerto:word):byte;
var
  res:byte;
begin
  if (puerto and $ff)=0 then begin
    res:=0;
	  if (main_sent=0) then res:=res or $02;
  	if (mcu_sent=0) then res:=res or $04;
    sf_inbyte:=(tigerh_port_00_r and $f9) or res;
  end;
end;

procedure sf_outbyte(valor:byte;puerto:word);
begin
case (puerto and $ff) of
     0:snd_z80.pedir_irq:=ASSERT_LINE;
     1:snd_z80.pedir_irq:=CLEAR_LINE;
     6,7:ena_irq:=(puerto and 1)<>0;
     8,9:rom_bank:=puerto and 1;
end;
end;

function mcu_sf_hw_getbyte(direccion:word):byte;
begin
direccion:=direccion and $7ff;
case direccion of
  0:mcu_sf_hw_getbyte:=(portA_out and ddrA) or (portA_in and not(ddrA));
	1:mcu_sf_hw_getbyte:=(portB_out and ddrB) or (portB_in and not(ddrB));
	2:begin
      portC_in:=0;
      if (main_sent<>0) then portC_in:=portC_in or $01;
      if (mcu_sent=0) then portC_in:=portC_in or $02;
      mcu_sf_hw_getbyte:=(portC_out and ddrC) or (portC_in and not(ddrC));
    end;
  else mcu_sf_hw_getbyte:=mcu_ram[direccion];
end;
end;

procedure mcu_sf_hw_putbyte(direccion:word;valor:byte);
begin
direccion:=direccion and $7ff;
if direccion>$7f then exit;
mcu_ram[direccion]:=valor;
case direccion of
  0:portA_out:=valor;
	1:begin
      if (((ddrB and $02)<>0) and ((not(valor) and  $02)<>0) and ((portB_out and $02)<>0)) then begin
		    portA_in:=from_main;
		    if (main_sent<>0) then main_m6805.irq_request(0,CLEAR_LINE);
		    main_sent:=0;
      end;
	    if (((ddrB and $04)<>0) and ((valor and $04)<>0) and ((not(portB_out) and $04)<>0)) then begin
		    from_mcu:=portA_out;
		    mcu_sent:=1;
	    end;
	    if (((ddrB and $08)<>0) and ((not(valor) and $08)<>0) and ((portB_out and $08)<>0)) then scroll_y:=(scroll_y and $ff00)+portA_out;
	    if (((ddrB and $10)<>0) and ((not(valor) and $10)<>0) and ((portB_out and $10)<>0)) then scroll_y:=(scroll_y and $ff)+(portA_out shl 8);
	    portB_out:=valor;
    end;
	2:portc_out:=valor;
	4:ddra:=valor;
	5:ddrb:=valor;
	6:ddrc:=valor;
end;
end;

//Sound
function snd_sf_hw_getbyte(direccion:word):byte;
begin
case direccion of
  $a081:snd_sf_hw_getbyte:=ay8910_0.Read;
  $a091:snd_sf_hw_getbyte:=ay8910_1.Read;
  $c800..$c80f:snd_sf_hw_getbyte:=memoria[direccion];
  else snd_sf_hw_getbyte:=mem_snd[direccion];
end;
end;

procedure snd_sf_hw_putbyte(direccion:word;valor:byte);
begin
if (direccion<$2000) then exit;
mem_snd[direccion]:=valor;
case direccion of
  $a080:ay8910_0.Control(valor);
  $a082:ay8910_0.Write(valor);
  $a090:ay8910_1.Control(valor);
  $a092:ay8910_1.Write(valor);
  $c800..$c80f:memoria[direccion]:=valor;
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
  ay8910_porta_1:=$ff;
end;

function ay8910_portb_1:byte;
begin
  ay8910_portb_1:=$ff;
end;

procedure sf_hw_sound_update;
begin
  ay8910_0.update;
  ay8910_1.update;
end;

procedure sf_sound_nmi;
begin
  snd_z80.change_nmi(PULSE_LINE);
end;

end.
