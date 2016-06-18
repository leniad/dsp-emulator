unit ironhorse_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6809,nz80,main_engine,controls_engine,gfx_engine,ym_2203,
     rom_engine,pal_engine,sound_engine;

//main
procedure cargar_ironhorse;

implementation
const
        ironhorse_rom:array[0..2] of tipo_roms=(
        (n:'13c_h03.bin';l:$8000;p:$4000;crc:$24539af1),(n:'12c_h02.bin';l:$4000;p:$c000;crc:$fab07f86),());
        ironhorse_snd:tipo_roms=(n:'10c_h01.bin';l:$4000;p:0;crc:$2b17930f);
        ironhorse_gfx:array[0..4] of tipo_roms=(
        (n:'08f_h06.bin';l:$8000;p:0;crc:$f21d8c93),(n:'07f_h05.bin';l:$8000;p:$1;crc:$60107859),
        (n:'09f_h07.bin';l:$8000;p:$10000;crc:$c761ec73),(n:'06f_h04.bin';l:$8000;p:$10001;crc:$c1486f61),());
        ironhorse_pal:array[0..5] of tipo_roms=(
        (n:'03f_h08.bin';l:$100;p:0;crc:$9f6ddf83),(n:'04f_h09.bin';l:$100;p:$100;crc:$e6773825),
        (n:'05f_h10.bin';l:$100;p:$200;crc:$30a57860),(n:'10f_h12.bin';l:$100;p:$300;crc:$5eb33e73),
        (n:'10f_h11.bin';l:$100;p:$400;crc:$a63e37d8),());

var
 pedir_nmi,pedir_firq:boolean;
 sound_latch,charbank,palettebank:byte;
 spritebank:word;
 scroll_lineas:array[0..$1f] of byte;

procedure update_video_ironhorse;inline;
var
  x,y,atrib:byte;
  f:word;
  nchar,color:word;
  flipx,flipy:byte;
  a,b,c,d:byte;
begin
for f:=0 to $3ff do begin
    if gfx[0].buffer[f] then begin
      x:=f mod 32;
      y:=f div 32;
      atrib:=memoria[$2000+f];
      nchar:=memoria[$2400+f]+((atrib and $40) shl 2)+((atrib and $20) shl 4)+(charbank shl 10);
      color:=((atrib and $f)+16*palettebank) shl 4;
      put_gfx_flip(x*8,y*8,nchar,color,1,0,(atrib and $10)<>0,(atrib and $20)<>0);
      gfx[0].buffer[f]:=false;
    end;
end;
//Scroll linea a linea
for f:=0 to 31 do scroll__x_part(1,2,scroll_lineas[f],0,f*8,8);
for f:=0 to $33 do begin
		x:=memoria[spritebank+3+(f*5)];
		y:=memoria[spritebank+2+(f*5)];
    atrib:=memoria[spritebank+1+(f*5)];
    nchar:=(memoria[spritebank+(f*5)] shl 2)+((atrib and $03) shl 10) + ((atrib and $0c) shr 2);
		color:=((((atrib and $f0) shr 4) + 16*palettebank) shl 4)+$800;
    atrib:=memoria[spritebank+4+(f*5)];
    flipx:=(atrib and $20) shr 5;
    flipy:=(atrib and $40) shr 5;
    case (atrib and $c) of
      $0:begin  //16x16
          a:=(0 xor flipx) xor flipy;
          b:=(1 xor flipx) xor flipy;
          c:=(2 xor flipx) xor flipy;
          d:=(3 xor flipx) xor flipy;
          put_gfx_sprite_diff(nchar+a,color,flipx<>0,flipy<>0,0,0,0);
          put_gfx_sprite_diff(nchar+b,color,flipx<>0,flipy<>0,0,8,0);
          put_gfx_sprite_diff(nchar+c,color,flipx<>0,flipy<>0,0,0,8);
          put_gfx_sprite_diff(nchar+d,color,flipx<>0,flipy<>0,0,8,8);
          actualiza_gfx_sprite_size(x,y,2,16,16);
        end;
      $4:begin  //16x8
          a:=0 xor flipx;
          b:=1 xor flipx;
          put_gfx_sprite_diff(nchar+a,color,flipx<>0,flipy<>0,0,0,0);
          put_gfx_sprite_diff(nchar+b,color,flipx<>0,flipy<>0,0,8,0);
          actualiza_gfx_sprite_size(x,y,2,16,8);
         end;
      $8:begin  //8x16
          a:=0 xor flipy;
          b:=2 xor flipy;
          put_gfx_sprite_diff(nchar+a,color,flipx<>0,flipy<>0,0,0,0);
          put_gfx_sprite_diff(nchar+b,color,flipx<>0,flipy<>0,0,0,8);
          actualiza_gfx_sprite_size(x,y,2,8,16);
         end;
      $c:begin //8x8
          put_gfx_sprite_mask(nchar,color,flipx<>0,flipy<>0,0,0,$f);
          actualiza_gfx_sprite(x,y,2,0);
         end;
    end;
end;
actualiza_trozo_final(8,16,240,224,2);
end;

procedure eventos_ironhorse;
begin
if event.arcade then begin
  //p1
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $Fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $F7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.but2[1] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  //p2
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $Fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $F7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.but2[0] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  //misc
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
end;
end;

procedure ironhorse_principal; 
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=main_m6809.tframes;
frame_s:=snd_z80.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
    //main
    main_m6809.run(frame_m);
    frame_m:=frame_m+main_m6809.tframes-main_m6809.contador;
    //snd
    snd_z80.run(frame_s);
    frame_s:=frame_s+snd_z80.tframes-snd_z80.contador;
    if f=240 then begin
      update_video_ironhorse;
      if pedir_firq then main_m6809.change_firq(HOLD_LINE);
    end;
    if ((((f+16) mod 64)=0) and pedir_nmi) then main_m6809.change_nmi(PULSE_LINE);
  end;
  eventos_ironhorse;
  video_sync;
end;
end;

function ironhorse_getbyte(direccion:word):byte;
begin
case direccion of
    $900:ironhorse_getbyte:=$fe;  //dsw3
    $a00:ironhorse_getbyte:=$5a;  //dsw2
    $b00:ironhorse_getbyte:=$ff;  //dsw1
    $b01:ironhorse_getbyte:=marcade.in1; //p2
    $b02:ironhorse_getbyte:=marcade.in0;  //p1
    $b03:ironhorse_getbyte:=marcade.in2;  //system
      else ironhorse_getbyte:=memoria[direccion];
end;
end;

procedure ironhorse_putbyte(direccion:word;valor:byte);
begin
if direccion>$3FFF then exit;
memoria[direccion]:=valor;
case direccion of
  $3:begin
       if charbank<>(valor and $3) then begin
          charbank:=valor and $3;
          fillchar(gfx[0].buffer[0],$400,1);
       end;
       if (valor and $8)<>0 then spritebank:=$3800
        else spritebank:=$3000;
     end;
  $4:begin
       pedir_nmi:=(valor and $1)<>0;
       pedir_firq:=(valor and $4)<>0;
     end;
  $20..$3f:scroll_lineas[direccion and $1f]:=valor;
  $800:sound_latch:=valor;
  $900:snd_z80.change_irq(HOLD_LINE);
  $a00:if palettebank<>(valor and $7) then begin
            palettebank:=valor and $7;
            fillchar(gfx[0].buffer[0],$400,1);
       end;
  $2000..$27ff:gfx[0].buffer[direccion and $3ff]:=true;
end;
end;

function ironhorse_snd_getbyte(direccion:word):byte;
begin
if direccion=$8000 then ironhorse_snd_getbyte:=sound_latch
  else ironhorse_snd_getbyte:=mem_snd[direccion];
end;

procedure ironhorse_snd_outbyte(valor:byte;puerto:word);
begin
case (puerto and $ff) of
  0:ym2203_0.Control(valor);
  1:ym2203_0.Write(valor);
end;
end;

function ironhorse_snd_inbyte(puerto:word):byte;
begin
  if (puerto and $ff)=0 then ironhorse_snd_inbyte:=ym2203_0.status;
end;

procedure ironhorse_snd_putbyte(direccion:word;valor:byte);
begin
  if direccion<$4000 then exit;
  mem_snd[direccion]:=valor;
end;

procedure ironhorse_sound_update;
begin
  ym2203_0.Update;
end;

//Main
procedure reset_ironhorse;
begin
 main_m6809.reset;
 snd_z80.reset;
 ym2203_0.reset;
 reset_audio;
 marcade.in0:=$FF;
 marcade.in1:=$FF;
 marcade.in2:=$FF;
 pedir_nmi:=false;
 charbank:=0;
 sound_latch:=0;
 spritebank:=$3800;
end;

function iniciar_ironhorse:boolean;
var
      colores:tpaleta;
      valor,j:byte;
      f,valor2:word;
      memoria_temp:array[0..$1ffff] of byte;
const
    pc_x:array[0..7] of dword=(0*4, 1*4, 2*4, 3*4, 4*4, 5*4, 6*4, 7*4);
    pc_y:array[0..7] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32);
begin
iniciar_ironhorse:=false;
iniciar_audio(false);
screen_init(1,256,256);
screen_mod_scroll(1,256,256,255,0,0,0);
screen_init(2,256,256,false,true);
iniciar_video(240,224);
//Main CPU
main_m6809:=cpu_m6809.Create(3072000,$100);
main_m6809.change_ram_calls(ironhorse_getbyte,ironhorse_putbyte);
//Sound CPU
snd_z80:=cpu_z80.create(3072000,$100);
snd_z80.change_ram_calls(ironhorse_snd_getbyte,ironhorse_snd_putbyte);
snd_z80.change_io_calls(ironhorse_snd_inbyte,ironhorse_snd_outbyte);
snd_z80.init_sound(ironhorse_sound_update);
//Sound Chip
ym2203_0:=ym2203_chip.create(3072000);
//cargar roms
if not(cargar_roms(@memoria[0],@ironhorse_rom[0],'ironhors.zip',0)) then exit;
//roms sonido
if not(cargar_roms(@mem_snd[0],@ironhorse_snd,'ironhors.zip',1)) then exit;
//convertir chars
if not(cargar_roms16b(@memoria_temp[0],@ironhorse_gfx[0],'ironhors.zip',0)) then exit;
init_gfx(0,8,8,$1000);
gfx[0].trans[0]:=true;
gfx_set_desc_data(4,0,32*8,0,1,2,3);
convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,false);
//paleta
if not(cargar_roms(@memoria_temp[0],@ironhorse_pal[0],'ironhors.zip',0)) then exit;
for f:=0 to $ff do begin
  colores[f].r:=((memoria_temp[f] and $f) shl 4) or (memoria_temp[f] and $f);
  colores[f].g:=((memoria_temp[f+$100] and $f) shl 4) or (memoria_temp[f+$100] shr 4);
  colores[f].b:=((memoria_temp[f+$200] and $f) shl 4) or (memoria_temp[f+$200] and $f);
end;
set_pal(colores,256);
for f:=0 to $1ff do begin
  for j:=0 to 7 do begin
			valor:=(j shl 5) or ((not(f) and $100) shr 4) or (memoria_temp[f+$300] and $0f);
      valor2:=((f and $100) shl 3) or (j shl 8) or (f and $ff);
      gfx[0].colores[valor2]:=valor;  //chars
      gfx[1].colores[valor2]:=valor;  //sprites
  end;
end;
//final
reset_ironhorse;
iniciar_ironhorse:=true;
end;

procedure Cargar_ironhorse;
begin
llamadas_maquina.iniciar:=iniciar_ironhorse;
llamadas_maquina.bucle_general:=ironhorse_principal;
llamadas_maquina.reset:=reset_ironhorse;
llamadas_maquina.fps_max:=30;
end;

end.
