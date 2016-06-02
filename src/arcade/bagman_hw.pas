unit bagman_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     sound_engine,ay_8910,bagman_pal;

procedure cargar_bagman;

implementation
const
        //bagman
        bagman_rom:array[0..6] of tipo_roms=(
        (n:'e9_b05.bin';l:$1000;p:0;crc:$e0156191),(n:'f9_b06.bin';l:$1000;p:$1000;crc:$7b758982),
        (n:'f9_b07.bin';l:$1000;p:$2000;crc:$302a077b),(n:'k9_b08.bin';l:$1000;p:$3000;crc:$f04293cb),
        (n:'m9_b09s.bin';l:$1000;p:$4000;crc:$68e83e4f),(n:'n9_b10.bin';l:$1000;p:$5000;crc:$1d6579f7),());
        bagman_pal:array[0..2] of tipo_roms=(
        (n:'p3.bin';l:$20;p:0;crc:$2a855523),(n:'r3.bin';l:$20;p:$20;crc:$ae6f1019),());
        bagman_char:array[0..2] of tipo_roms=(
        (n:'e1_b02.bin';l:$1000;p:0;crc:$4a0a6b55),(n:'j1_b04.bin';l:$1000;p:$1000;crc:$c680ef04),());
        bagman_sprites:array[0..2] of tipo_roms=(
        (n:'c1_b01.bin';l:$1000;p:0;crc:$705193b2),(n:'f1_b03s.bin';l:$1000;p:$1000;crc:$dba1eda7),());
        //Super Bagman
        sbagman_rom:array[0..10] of tipo_roms=(
        (n:'5.9e';l:$1000;p:0;crc:$1b1d6b0a),(n:'6.9f';l:$1000;p:$1000;crc:$ac49cb82),
        (n:'7.9j';l:$1000;p:$2000;crc:$9a1c778d),(n:'8.9k';l:$1000;p:$3000;crc:$b94fbb73),
        (n:'9.9m';l:$1000;p:$4000;crc:$601f34ba),(n:'10.9n';l:$1000;p:$5000;crc:$5f750918),
        (n:'13.8d';l:$1000;p:$6000;crc:$944a4453),(n:'14.8f';l:$1000;p:$7000;crc:$83b10139),
        (n:'15.8j';l:$1000;p:$8000;crc:$fe924879),(n:'16.8k';l:$1000;p:$9000;crc:$b77eb1f5),());
        sbagman_pal:array[0..2] of tipo_roms=(
        (n:'p3.bin';l:$20;p:0;crc:$2a855523),(n:'r3.bin';l:$20;p:$20;crc:$ae6f1019),());
        sbagman_char:array[0..2] of tipo_roms=(
        (n:'2.1e';l:$1000;p:0;crc:$f4d3d4e6),(n:'4.1j';l:$1000;p:$1000;crc:$2c6a510d),());
        sbagman_sprites:array[0..2] of tipo_roms=(
        (n:'1.1c';l:$1000;p:0;crc:$a046ff44),(n:'3.1f';l:$1000;p:$1000;crc:$a4422da4),());
        //DIP
        bagman_dip:array [0..6] of def_dip=(
        (mask:$3;name:'Lives';number:4;dip:((dip_val:$3;dip_name:'2'),(dip_val:$2;dip_name:'3'),(dip_val:$1;dip_name:'4'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Coinage';number:2;dip:((dip_val:$0;dip_name:'2C/1C 1C/1C 1C/3C 1C/7C'),(dip_val:$4;dip_name:'1C/1C 1C/2C 1C/6C 1C/14C'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$18;name:'Difficulty';number:4;dip:((dip_val:$18;dip_name:'Easy'),(dip_val:$10;dip_name:'Medium'),(dip_val:$8;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Language';number:2;dip:((dip_val:$20;dip_name:'English'),(dip_val:$0;dip_name:'French'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Bonus Life';number:2;dip:((dip_val:$40;dip_name:'30k'),(dip_val:$0;dip_name:'40k'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Cabinet';number:2;dip:((dip_val:$80;dip_name:'Upright'),(dip_val:$0;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 irq_enable,video_enable:boolean;

procedure update_video_bagman;inline;
var
  f,color,nchar:word;
  atrib,gfx_num,x,y:byte;
begin
for f:=0 to $3ff do begin
    if gfx[0].buffer[f] then begin
      x:=31-(f div 32);
      y:=f mod 32;
      atrib:=memoria[$9800+f];
      nchar:=memoria[$9000+f]+((atrib and $20) shl 3);
      gfx_num:=(atrib and $10) shr 3;
      color:=(atrib and $f) shl 2;
      put_gfx(x*8,y*8,nchar,color,1,gfx_num);
      gfx[0].buffer[f]:=false;
    end;
end;
actualiza_trozo(0,0,256,256,1,0,0,256,256,2);
for f:=7 downto 0 do begin
    atrib:=memoria[$9800+(f*4)];
    color:=(memoria[$9801+(f*4)] and $1f) shl 2;
    nchar:=(atrib and $3f)+((memoria[$9801+(f*4)] and $20) shl 1);
    y:=memoria[$9803+(f*4)];
    x:=memoria[$9802+(f*4)];
    if ((x<>0) and (y<>0)) then begin
      put_gfx_sprite(nchar,color,(atrib and $80)<>0,(atrib and $40)<>0,1);
      actualiza_gfx_sprite((x+1) and $ff,(y-1) and $ff,2,1);
    end;
end;
actualiza_trozo_final(16,0,224,256,2);
end;

procedure eventos_bagman;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  //P2
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
end;
end;

procedure bagman_principal;
var
  frame:single;
  f:word;
begin
init_controls(false,false,false,true);
frame:=main_z80.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to 263 do begin
    main_z80.run(frame);
    frame:=frame+main_z80.tframes-main_z80.contador;
    if f=239 then begin
      if irq_enable then main_z80.pedir_irq:=HOLD_LINE;
      if video_enable then update_video_bagman;
    end;
  end;
  eventos_bagman;
  video_sync;
end;
end;

function bagman_getbyte(direccion:word):byte;
begin
case direccion of
  0..$67ff,$9000..$93ff,$9800..$9bff,$c000..$ffff:bagman_getbyte:=memoria[direccion];
  $a000:bagman_getbyte:=bagman_pal16r6_r;
  $b000:bagman_getbyte:=marcade.dswa;
end;
end;

procedure bagman_putbyte(direccion:word;valor:byte);
begin
if ((direccion<$6000) or (direccion>$bfff)) then exit;
memoria[direccion]:=valor;
case direccion of
  $9000..$93ff,$9800..$9bff:gfx[0].buffer[direccion and $3ff]:=true;
  $a000:irq_enable:=(valor and 1)<>0;
  $a001..$a002:main_screen.flip_main_screen:=(valor and 1)<>1;
  $a003:video_enable:=(valor and 1)<>0;
  $a800..$a805:bagman_pal16r6_w(direccion and $7,valor);
end;
end;

function bagman_inbyte(puerto:word):byte;
begin
if (puerto and $ff)=$c then bagman_inbyte:=ay8910_0.Read;
end;

procedure bagman_outbyte(valor:byte;puerto:word);
begin
case (puerto and $ff) of
  $08:AY8910_0.Control(valor);
  $09:AY8910_0.Write(valor);
end;
end;

function bagman_portar:byte;
begin
  bagman_portar:=marcade.in0;
end;

function bagman_portbr:byte;
begin
  bagman_portbr:=marcade.in1;
end;

procedure bagman_sound;
begin
  ay8910_0.update;
end;

//Main
procedure reset_bagman;
begin
 main_z80.reset;
 ay8910_0.reset;
 reset_audio;
 irq_enable:=true;
 video_enable:=true;
 marcade.in0:=$FF;
 marcade.in1:=$FF;
 //Reset PAL
 bagman_pal16r6_w(0,1);	// pin 2
 bagman_pal16r6_w(1,1);	// pin 3
 bagman_pal16r6_w(2,1);	// pin 4
 bagman_pal16r6_w(3,1);	// pin 5
 bagman_pal16r6_w(4,1);	// pin 6
 bagman_pal16r6_w(5,1);	// pin 7
 bagman_pal16r6_w(6,1);	// pin 8
 bagman_pal16r6_w(7,1);	// pin 9
 bagman_update_pal;
end;

function iniciar_bagman:boolean;
var
  colores:tpaleta;
  f:word;
  bit0,bit1,bit2:byte;
  memoria_temp:array[0..$9fff] of byte;
  rweights,gweights:array[0..3] of single;
  bweights:array[0..2] of single;
const
  ps_x:array[0..15] of dword=(0, 1, 2, 3, 4, 5, 6, 7,
			8*8+0, 8*8+1, 8*8+2, 8*8+3, 8*8+4, 8*8+5, 8*8+6, 8*8+7);
  ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			16*8, 17*8, 18*8, 19*8, 20*8, 21*8, 22*8, 23*8);
  pc_x:array[0..7] of dword=(0, 1, 2, 3, 4, 5, 6, 7);
  pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
  resistances_rg:array[0..2] of integer=(1000,470,220);
  resistances_b:array[0..1] of integer=(470,220);
procedure conv_chars(num_gfx:byte);
begin
  init_gfx(num_gfx,8,8,$200);
  gfx_set_desc_data(2,0,8*8,0,512*8*8);
  convert_gfx(num_gfx,0,@memoria_temp[0],@pc_x[0],@pc_y[0],true,false);
end;
procedure conv_sprites;
begin
  init_gfx(1,16,16,$80);
  gfx[1].trans[0]:=true;
  gfx_set_desc_data(2,0,32*8,0,128*16*16);
  convert_gfx(1,0,@memoria_temp[0],@ps_x[0],@ps_y[0],true,false);
end;
begin
iniciar_bagman:=false;
iniciar_audio(false);
//Pantallas:  principal+char y sprites
screen_init(1,256,256);
screen_init(2,256,256,false,true);
screen_mod_sprites(2,0,512,0,$1ff);
iniciar_video(224,256);
//Main CPU
main_z80:=cpu_z80.create(3072000,264);
main_z80.change_ram_calls(bagman_getbyte,bagman_putbyte);
main_z80.change_io_calls(bagman_inbyte,bagman_outbyte);
main_z80.init_sound(bagman_sound);
ay8910_0:=ay8910_chip.create(1536000,1);
ay8910_0.change_io_calls(bagman_portar,bagman_portbr,nil,nil);
case main_vars.tipo_maquina of
  171:begin  //bagman
        //cargar roms
        if not(cargar_roms(@memoria[0],@bagman_rom[0],'bagman.zip',0)) then exit;
        //convertir chars
        if not(cargar_roms(@memoria_temp[0],@bagman_char,'bagman.zip',0)) then exit;
        conv_chars(0);
        conv_sprites;
        //convertir sprites
        if not(cargar_roms(@memoria_temp[0],@bagman_sprites,'bagman.zip',0)) then exit;
        conv_chars(2);
        //poner la paleta
        if not(cargar_roms(@memoria_temp[0],@bagman_pal[0],'bagman.zip',0)) then exit;
     end;
  172:begin  //Super Bagman
        //cargar roms
        if not(cargar_roms(@memoria_temp[0],@sbagman_rom[0],'sbagman.zip',0)) then exit;
        copymemory(@memoria[0],@memoria_temp[0],$6000);
        copymemory(@memoria[$c000],@memoria_temp[$6000],$e00);
        copymemory(@memoria[$fe00],@memoria_temp[$6e00],$200);
        copymemory(@memoria[$d000],@memoria_temp[$7000],$400);
        copymemory(@memoria[$e400],@memoria_temp[$7400],$200);
        copymemory(@memoria[$d600],@memoria_temp[$7600],$a00);
        copymemory(@memoria[$e000],@memoria_temp[$8000],$400);
        copymemory(@memoria[$d400],@memoria_temp[$8400],$200);
        copymemory(@memoria[$e600],@memoria_temp[$8600],$a00);
        copymemory(@memoria[$f000],@memoria_temp[$9000],$e00);
        copymemory(@memoria[$ce00],@memoria_temp[$9e00],$200);
        //convertir chars
        if not(cargar_roms(@memoria_temp[0],@sbagman_char,'sbagman.zip',0)) then exit;
        conv_chars(0);
        conv_sprites;
        //convertir sprites
        if not(cargar_roms(@memoria_temp[0],@sbagman_sprites,'sbagman.zip',0)) then exit;
        conv_chars(2);
        //poner la paleta
        if not(cargar_roms(@memoria_temp[0],@sbagman_pal[0],'sbagman.zip',0)) then exit;
     end;
end;
compute_resistor_weights(0,	255, -1.0,
			3,@resistances_rg[0],@rweights[0],470,0,
			3,@resistances_rg[0],@gweights[0],470,0,
			2,@resistances_b[0],@bweights[0],470,0);
for f:=0 to $3f do begin
		// red component */
		bit0:=(memoria_temp[f] shr 0) and $01;
		bit1:=(memoria_temp[f] shr 1) and $01;
		bit2:=(memoria_temp[f] shr 2) and $01;
		colores[f].r:=combine_3_weights(@rweights[0], bit0, bit1, bit2);
		// green component */
		bit0:=(memoria_temp[f] shr 3) and $01;
		bit1:=(memoria_temp[f] shr 4) and $01;
		bit2:=(memoria_temp[f] shr 5) and $01;
		colores[f].g:=combine_3_weights(@gweights[0], bit0, bit1, bit2);
		// blue component */
		bit0:=(memoria_temp[f] shr 6) and $01;
		bit1:=(memoria_temp[f] shr 7) and $01;
		colores[f].b:=combine_2_weights(@bweights[0], bit0, bit1);
end;
set_pal(colores,$40);
//DIP
marcade.dswa:=$fe;
marcade.dswa_val:=@bagman_dip;
//final
reset_bagman;
iniciar_bagman:=true;
end;

procedure Cargar_bagman;
begin
llamadas_maquina.iniciar:=iniciar_bagman;
llamadas_maquina.bucle_general:=bagman_principal;
llamadas_maquina.reset:=reset_bagman;
llamadas_maquina.fps_max:=60.6060606060;
end;

end.
