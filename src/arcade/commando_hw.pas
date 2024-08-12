unit commando_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,ym_2203,gfx_engine,misc_functions,
     rom_engine,pal_engine,sound_engine,timer_engine;

function iniciar_commando:boolean;

implementation
const
        commando_rom:array[0..1] of tipo_roms=(
        (n:'cm04.9m';l:$8000;p:0;crc:$8438b694),(n:'cm03.8m';l:$4000;p:$8000;crc:$35486542));
        commando_snd_rom:tipo_roms=(n:'cm02.9f';l:$4000;p:0;crc:$f9cc4a74);
        commando_pal:array[0..2] of tipo_roms=(
        (n:'vtb1.1d';l:$100;p:0;crc:$3aba15a1),(n:'vtb2.2d';l:$100;p:$100;crc:$88865754),
        (n:'vtb3.3d';l:$100;p:$200;crc:$4c14c3f6));
        commando_char:tipo_roms=(n:'vt01.5d';l:$4000;p:0;crc:$505726e0);
        commando_sprites:array[0..5] of tipo_roms=(
        (n:'vt05.7e';l:$4000;p:0;crc:$79f16e3d),(n:'vt06.8e';l:$4000;p:$4000;crc:$26fee521),
        (n:'vt07.9e';l:$4000;p:$8000;crc:$ca88bdfd),(n:'vt08.7h';l:$4000;p:$c000;crc:$2019c883),
        (n:'vt09.8h';l:$4000;p:$10000;crc:$98703982),(n:'vt10.9h';l:$4000;p:$14000;crc:$f069d2f8));
        commando_tiles:array[0..5] of tipo_roms=(
        (n:'vt11.5a';l:$4000;p:0;crc:$7b2e1b48),(n:'vt12.6a';l:$4000;p:$4000;crc:$81b417d3),
        (n:'vt13.7a';l:$4000;p:$8000;crc:$5612dbd2),(n:'vt14.8a';l:$4000;p:$c000;crc:$2b2dee36),
        (n:'vt15.9a';l:$4000;p:$10000;crc:$de70babf),(n:'vt16.10a';l:$4000;p:$14000;crc:$14178237));
        //DIP
        commando_dip_a:array [0..4] of def_dip=(
        (mask:$3;name:'Starting Area';number:4;dip:((dip_val:$3;dip_name:'0 (Forest 1)'),(dip_val:$1;dip_name:'2 (Desert 1)'),(dip_val:$2;dip_name:'4 (Forest 2)'),(dip_val:$0;dip_name:'6 (Desert 2)'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Lives';number:4;dip:((dip_val:$4;dip_name:'2'),(dip_val:$c;dip_name:'3'),(dip_val:$8;dip_name:'4'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Coin B';number:4;dip:((dip_val:$0;dip_name:'4C 1C'),(dip_val:$20;dip_name:'3C 1C'),(dip_val:$10;dip_name:'2C 1C'),(dip_val:$30;dip_name:'1C 1C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Coin A';number:4;dip:((dip_val:$0;dip_name:'2C 1C'),(dip_val:$c0;dip_name:'1C 1C'),(dip_val:$40;dip_name:'1C 2C'),(dip_val:$80;dip_name:'1C 3C'),(),(),(),(),(),(),(),(),(),(),(),())),());
        commando_dip_b:array [0..5] of def_dip=(
        (mask:$7;name:'Bonus Life';number:8;dip:((dip_val:$7;dip_name:'10k 50k+'),(dip_val:$3;dip_name:'10k 60k+'),(dip_val:$5;dip_name:'20k 60k+'),(dip_val:$1;dip_name:'20k 70k+'),(dip_val:$6;dip_name:'30k 70k+'),(dip_val:$2;dip_name:'30k 80k+'),(dip_val:$4;dip_name:'40k 100k+'),(dip_val:$0;dip_name:'None'),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$8;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Difficulty';number:2;dip:((dip_val:$10;dip_name:'Normal'),(dip_val:$0;dip_name:'Difficult'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Flip Screen';number:2;dip:((dip_val:$20;dip_name:'On'),(dip_val:$0;dip_name:'Off'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Cabinet';number:3;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$40;dip_name:'Upright Two Players'),(dip_val:$c0;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 memoria_dec:array[0..$bfff] of byte;
 scroll_x,scroll_y:word;
 sound_command:byte;

procedure update_video_commando;
var
  f,color,nchar,x,y:word;
  attr,bank:byte;
begin
for f:=$3ff downto 0 do begin
  //tiles
  if gfx[2].buffer[f] then begin
      x:=f mod 32;
      y:=31-(f div 32);
      attr:=memoria[$dc00+f];
      nchar:=memoria[$d800+f]+((attr and $c0) shl 2);
      color:=(attr and $f) shl 3;
      put_gfx_flip(x*16,y*16,nchar,color,2,2,(attr and $20)<>0,(attr and $10)<>0);
      gfx[2].buffer[f]:=false;
  end;
  //Chars
  if gfx[0].buffer[f] then begin
    x:=f div 32;
    y:=31-(f mod 32);
    attr:=memoria[f+$d400];
    color:=(attr and $f) shl 2;
    nchar:=memoria[f+$d000]+((attr and $c0) shl 2);
    put_gfx_trans_flip(x*8,y*8,nchar,color,3,0,(attr and $20)<>0,(attr and $10)<>0);
    gfx[0].buffer[f]:=false;
  end;
end;
scroll_x_y(2,1,scroll_x,256-scroll_y);
//sprites
for f:=$7f downto 0 do begin
    attr:=buffer_sprites[1+(f*4)];
    bank:=(attr and $c0) shr 6;
    if bank<3 then begin
      nchar:=buffer_sprites[f*4]+(bank shl 8);
      color:=attr and $30;
      x:=buffer_sprites[2+(f*4)];
      y:=240-(buffer_sprites[3+(f*4)]+((attr and $1) shl 8));
      put_gfx_sprite(nchar,color,(attr and $8)<>0,(attr and $4)<>0,1);
      actualiza_gfx_sprite(x,y,1,1);
    end;
end;
actualiza_trozo(0,0,256,256,3,0,0,256,256,1);
actualiza_trozo_final(16,0,224,256,1);
copymemory(@buffer_sprites[0],@memoria[$fe00],$200);
end;

procedure eventos_commando;
begin
if event.arcade then begin
  //P1
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  //BUT
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  //P2
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
end;
end;

procedure commando_principal;
var
  f:word;
  frame_m,frame_s:single;
begin
init_controls(false,false,false,true);
frame_m:=z80_0.tframes;
frame_s:=z80_1.tframes;
while EmuStatus=EsRunning do begin
  for f:=0 to 261 do begin
    //main
    z80_0.run(frame_m);
    frame_m:=frame_m+z80_0.tframes-z80_0.contador;
    //snd
    z80_1.run(frame_s);
    frame_s:=frame_s+z80_1.tframes-z80_1.contador;
    if f=245 then begin
      z80_0.change_irq(HOLD_LINE);
      update_video_commando;
    end;
  end;
  eventos_commando;
  video_sync;
end;
end;

function commando_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$bfff:if z80_0.opcode then commando_getbyte:=memoria_dec[direccion]
                 else commando_getbyte:=memoria[direccion];
  $c000:commando_getbyte:=marcade.in0;
  $c001:commando_getbyte:=marcade.in1;
  $c002:commando_getbyte:=marcade.in2;
  $c003:commando_getbyte:=marcade.dswa;
  $c004:commando_getbyte:=marcade.dswb;
  $d000..$ffff:commando_getbyte:=memoria[direccion];
end;
end;

procedure commando_putbyte(direccion:word;valor:byte);
begin
case direccion of
   0..$bfff:; //ROM
   $c800:sound_command:=valor;
   $c804:begin
            if (valor and $10)<>0 then z80_1.change_reset(ASSERT_LINE)
                    else z80_1.change_reset(CLEAR_LINE);
            main_screen.flip_main_screen:=(valor and $80)<>0;
         end;
   $c808:scroll_y:=(scroll_y and $100) or valor;
   $c809:scroll_y:=(scroll_y and $ff) or ((valor and $1) shl 8);
   $c80a:scroll_x:=(scroll_x and $100) or valor;
   $c80b:scroll_x:=(scroll_x and $ff) or ((valor and $1) shl 8);
   $d000..$d7ff:if memoria[direccion]<>valor then begin
                    gfx[0].buffer[direccion and $3ff]:=true;
                    memoria[direccion]:=valor;
                end;
   $d800..$dfff:if memoria[direccion]<>valor then begin
                    gfx[2].buffer[direccion and $3ff]:=true;
                    memoria[direccion]:=valor;
                end;
   $e000..$ffff:memoria[direccion]:=valor;
end;
end;

function commando_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$47ff:commando_snd_getbyte:=mem_snd[direccion];
  $6000:commando_snd_getbyte:=sound_command;
end;
end;

procedure commando_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$3fff:; //ROM
  $4000..$47ff:mem_snd[direccion]:=valor;
  $8000:ym2203_0.control(valor);
  $8001:ym2203_0.write(valor);
  $8002:ym2203_1.control(valor);
  $8003:ym2203_1.write(valor);
end;
end;

procedure commando_sound_update;
begin
  ym2203_0.update;
  ym2203_1.update;
end;

procedure commando_snd_irq;
begin
  z80_1.change_irq(HOLD_LINE);
end;

//Main
procedure reset_commando;
begin
 z80_0.reset;
 z80_0.im0:=$d7;  //rst 10
 z80_1.reset;
 ym2203_0.reset;
 ym2203_1.reset;
 reset_audio;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 scroll_x:=0;
 scroll_y:=0;
 sound_command:=0;
end;

function iniciar_commando:boolean;
var
  colores:tpaleta;
  f:word;
  memoria_temp:array[0..$17fff] of byte;
const
    ps_x:array[0..15] of dword=(0, 1, 2, 3, 8+0, 8+1, 8+2, 8+3,
			32*8+0, 32*8+1, 32*8+2, 32*8+3, 33*8+0, 33*8+1, 33*8+2, 33*8+3);
    ps_y:array[0..15] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16,
			8*16, 9*16, 10*16, 11*16, 12*16, 13*16, 14*16, 15*16);
    pt_x:array[0..15] of dword=(0, 1, 2, 3, 4, 5, 6, 7,
			16*8+0, 16*8+1, 16*8+2, 16*8+3, 16*8+4, 16*8+5, 16*8+6, 16*8+7);
    pt_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8);
begin
llamadas_maquina.bucle_general:=commando_principal;
llamadas_maquina.reset:=reset_commando;
llamadas_maquina.fps_max:=12000000/2/384/262;
iniciar_commando:=false;
iniciar_audio(false);
screen_init(1,512,512,false,true);
screen_init(2,512,512);
screen_mod_scroll(2,512,256,511,512,256,511);
screen_init(3,256,256,true);
iniciar_video(224,256);
//Main CPU
z80_0:=cpu_z80.create(3000000,262);
z80_0.change_ram_calls(commando_getbyte,commando_putbyte);
//Sound CPU
z80_1:=cpu_z80.create(3000000,262);
z80_1.change_ram_calls(commando_snd_getbyte,commando_snd_putbyte);
z80_1.init_sound(commando_sound_update);
//IRQ Sound CPU
timers.init(z80_1.numero_cpu,3000000/(4*60),commando_snd_irq,nil,true);
//Sound Chips
ym2203_0:=ym2203_chip.create(1500000,0.4);
ym2203_1:=ym2203_chip.create(1500000,0.4);
//cargar y desencriptar las ROMS
if not(roms_load(@memoria,commando_rom)) then exit;
memoria_dec[0]:=memoria[0];
for f:=1 to $bfff do memoria_dec[f]:=bitswap8(memoria[f],3,2,1,4,7,6,5,0);
//cargar ROMS sonido
if not(roms_load(@mem_snd,commando_snd_rom)) then exit;
//convertir chars
if not(roms_load(@memoria_temp,commando_char)) then exit;
init_gfx(0,8,8,1024);
gfx[0].trans[3]:=true;
gfx_set_desc_data(2,0,16*8,4,0);
convert_gfx(0,0,@memoria_temp,@ps_x,@ps_y,false,true);
//convertir sprites
if not(roms_load(@memoria_temp,commando_sprites)) then exit;
init_gfx(1,16,16,768);
gfx[1].trans[15]:=true;
gfx_set_desc_data(4,0,64*8,$c000*8+4,$c000*8+0,4,0);
convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,true);
//tiles
if not(roms_load(@memoria_temp,commando_tiles)) then exit;
init_gfx(2,16,16,1024);
gfx_set_desc_data(3,0,32*8,0,$8000*8,$8000*8*2);
convert_gfx(2,0,@memoria_temp,@pt_x,@pt_y,false,true);
//poner la paleta
if not(roms_load(@memoria_temp,commando_pal)) then exit;
for f:=0 to 255 do begin
  colores[f].r:=pal4bit(memoria_temp[f]);
  colores[f].g:=pal4bit(memoria_temp[f+$100]);
  colores[f].b:=pal4bit(memoria_temp[f+$200]);
end;
set_pal(colores,256);
//crear la tabla de colores
for f:=0 to 63 do begin
  gfx[1].colores[f]:=f+128;
  gfx[0].colores[f]:=f+192;
end;
//DIP
marcade.dswa:=$ff;
marcade.dswb:=$1f;
marcade.dswa_val:=@commando_dip_a;
marcade.dswb_val:=@commando_dip_b;
//final
reset_commando;
iniciar_commando:=true;
end;

end.
