unit jackal_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6809,main_engine,controls_engine,gfx_engine,ym_2151,rom_engine,
     pal_engine,sound_engine;

procedure Cargar_jackal;
procedure jackal_principal;
function iniciar_jackal:boolean;
procedure reset_jackal;
//Main CPU
function jackal_getbyte(direccion:word):byte;
procedure jackal_putbyte(direccion:word;valor:byte);
//Sound CPU
function sound_getbyte(direccion:word):byte;
procedure sound_putbyte(direccion:word;valor:byte);
procedure sound_instruccion;

implementation
const
        jackal_rom:array[0..2] of tipo_roms=(
        (n:'j-v02.rom';l:$10000;p:$0;crc:$0b7e0584),(n:'j-v03.rom';l:$4000;p:$10000;crc:$3e0dfb83),());
        jackal_proms:array[0..2] of tipo_roms=(
        (n:'631r08.bpr';l:$100;p:0;crc:$7553a172),(n:'631r09.bpr';l:$100;p:$100;crc:$a74dd86c),());
        jackal_chars:array[0..4] of tipo_roms=(
        (n:'631t04.bin';l:$20000;p:0;crc:$457f42f0),(n:'631t05.bin';l:$20000;p:$1;crc:$732b3fc1),
        (n:'631t06.bin';l:$20000;p:$40000;crc:$2d10e56e),(n:'631t07.bin';l:$20000;p:$40001;crc:$4961c397),());
        jackal_sound:tipo_roms=(n:'631t01.bin';l:$8000;p:$8000;crc:$b189af6a);

var
 memoria_rom:array[0..1,0..$7FFF] of byte;
 memoria_zram:array[0..1,0..$3f] of byte;
 memoria_sprite:array[0..1,0..$fff] of byte;
 memoria_voram:array[0..1,0..$7ff] of byte;
 banco:byte;
 scroll_x,scroll_y,scroll_crt,sprite_crt:byte;
 irq_enable:boolean;
 ram_bank,sprite_bank:byte;

procedure Cargar_jackal;
begin
llamadas_maquina.iniciar:=iniciar_jackal;
llamadas_maquina.bucle_general:=jackal_principal;
llamadas_maquina.reset:=reset_jackal;
end;

function iniciar_jackal:boolean;
var
  f:word;
  memoria_temp:array[0..$7ffff] of byte;
const
    pc_x:array[0..7] of dword=(0*4, 1*4, 2*4, 3*4, 4*4, 5*4, 6*4, 7*4);
    pc_y:array[0..7] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32);
    ps_x:array[0..15] of dword=(0*4, 1*4, 2*4, 3*4, 4*4, 5*4, 6*4, 7*4,
			32*8+0*4, 32*8+1*4, 32*8+2*4, 32*8+3*4, 32*8+4*4, 32*8+5*4, 32*8+6*4, 32*8+7*4);
    ps_y:array[0..15] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32,
			16*32, 17*32, 18*32, 19*32, 20*32, 21*32, 22*32, 23*32);
begin
iniciar_jackal:=false;
iniciar_audio(true);
//Pantallas
screen_init(1,256,256);
screen_mod_scroll(1,256,256,255,256,256,255);
screen_init(2,256,512,false,true);
iniciar_video(224,240);
//Main CPU
main_m6809:=cpu_m6809.Create(1536000,256);
main_m6809.change_ram_calls(jackal_getbyte,jackal_putbyte);
//Sound CPU
snd_m6809:=cpu_m6809.Create(1536000,256);
snd_m6809.change_ram_calls(sound_getbyte,sound_putbyte);
snd_m6809.init_sound(sound_instruccion);
//Audio chips
ym2151_0:=ym2151_Chip.create(3579545);
//cargar roms
if not(cargar_roms(@memoria_temp[0],@jackal_rom[0],'jackal.zip',0)) then exit;
//Pongo las ROMs en su banco
copymemory(@memoria[$c000],@memoria_temp[$10000],$4000);
copymemory(@memoria_rom[0,0],@memoria_temp[0],$8000);
copymemory(@memoria_rom[1,0],@memoria_temp[$8000],$8000);
//Cargar Sound
if not(cargar_roms(@mem_snd[0],@jackal_sound,'jackal.zip',1)) then exit;
//convertir chars
if not(cargar_roms16b(@memoria_temp[0],@jackal_chars,'jackal.zip',0)) then exit;
init_gfx(0,8,8,4096);
gfx_set_desc_data(8,0,32*8,0,1,2,3,$40000*8+0,$40000*8+1,$40000*8+2,$40000*8+3);
convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],true,false);
//sprites 8
init_gfx(1,8,8,4096*2);
gfx[1].trans[0]:=true;
gfx_set_desc_data(4,2,32*8,0,1,2,3);
convert_gfx(1,0,@memoria_temp[$20000],@pc_x[0],@pc_y[0],true,false);
convert_gfx(1,4096*8*8,@memoria_temp[$60000],@pc_x[0],@pc_y[0],true,false);
//tiles
init_gfx(2,16,16,1024*2);
gfx[2].trans[0]:=true;
gfx_set_desc_data(4,2,32*32,0,1,2,3);
convert_gfx(2,0,@memoria_temp[$20000],@ps_x[0],@ps_y[0],true,false);
convert_gfx(2,1024*16*16,@memoria_temp[$60000],@ps_x[0],@ps_y[0],true,false);
//Color lookup
if not(cargar_roms(@memoria_temp[0],@jackal_proms,'jackal.zip',0)) then exit;
for f:=0 to $ff do gfx[0].colores[f]:=f or $100;
for f:=$100 to $1ff do gfx[1].colores[f]:=memoria_temp[f-$100] and $0f;
for f:=$200 to $2ff do gfx[1].colores[f]:=(memoria_temp[f-$100] and $0f) or $10;
copymemory(@gfx[2].colores,@gfx[1].colores,2048*2);
//final
reset_jackal;
iniciar_jackal:=true;
end;

procedure reset_jackal;
begin
 main_m6809.reset;
 snd_m6809.reset;
 ym2151_0.reset;
 reset_audio;
 marcade.in0:=$3F;
 marcade.in1:=$FF;
 marcade.in2:=$FF;
 irq_enable:=false;
 ram_bank:=0;
 sprite_bank:=0;
 scroll_x:=0;
 scroll_y:=0;
 scroll_crt:=0;
 sprite_crt:=0;
end;

procedure draw_sprites(bank:byte;pos:word);inline;
var
  sn1,sn2,attr,a,b,c,d:byte;
	flipx,flipy:boolean;
  nchar,color,x,y:word;
  flipx_v,flipy_v:byte;
begin
  sn1:=memoria_sprite[bank,pos];
  sn2:=memoria_sprite[bank,pos+1];
  attr:=memoria_sprite[bank,pos+4];
  x:=240-(memoria_sprite[bank,pos+2]);
  y:=memoria_sprite[bank,pos+3]+((attr and 1) shl 8);
  flipy:=(attr and $20)<>0;
  flipx:=(attr and $40)<>0;
  flipy_v:=(attr and $20) shr 1;
  flipx_v:=(attr and $40) shr 2;
  color:=(sn2 and $f0)+((bank+1)*$100);
  if (attr and $C)<>0 then begin    // half-size sprite
			nchar:=(sn1*4+((sn2 and (8+4)) shr 2)+((sn2 and (2+1)) shl 10))+(bank*4096);
			case (attr and $0C) of
        $04:begin
              put_gfx_sprite_diff(nchar,color,flipx,flipy,1,8,0);
              put_gfx_sprite_diff(nchar+1,color,flipx,flipy,1,8,8);
              actualiza_gfx_sprite_size(x,y,2,16,16);
            end;
        $08:begin
              put_gfx_sprite_diff(nchar,color,flipx,flipy,1,0,0);
              put_gfx_sprite_diff(nchar-2,color,flipx,flipy,1,8,0);
              actualiza_gfx_sprite_size(x,y,2,16,8);
			      end;
        $0c:begin
              put_gfx_sprite(nchar,color,flipx,flipy,1);
              actualiza_gfx_sprite(x+8,y,2,1);
			      end;
      end;
  end else begin
      nchar:=(sn1+((sn2 and $03) shl 8))+(bank*1024);
			if (attr and $10)<>0 then begin
        a:=16 xor flipx_v;
        b:=0 xor flipx_v;
        c:=0 xor flipy_v;
        d:=16 xor flipy_v;
        put_gfx_sprite_diff(nchar,color,flipx,flipy,2,a,c);
        put_gfx_sprite_diff(nchar+1,color,flipx,flipy,2,a,d);
        put_gfx_sprite_diff(nchar+2,color,flipx,flipy,2,b,c);
        put_gfx_sprite_diff(nchar+3,color,flipx,flipy,2,b,d);
        actualiza_gfx_sprite_size(x-16,y,2,32,32);
			end	else begin
        put_gfx_sprite(nchar,color,flipx,flipy,2);
        actualiza_gfx_sprite(x,y,2,2);
			end;
  end;
end;

procedure update_video_jackal;
var
  x,y,f,nchar:word;
  atrib:byte;
begin
//background
for f:=$0 to $3ff do begin
    if gfx[0].buffer[f] then begin
      x:=31-(f div 32);
      y:=f mod 32;
      atrib:=memoria_voram[ram_bank,f];
      nchar:=memoria_voram[ram_bank,$400+f]+((atrib and $c0) shl 2) + ((atrib and $30) shl 6);
      put_gfx_flip(x*8,y*8,nchar,0,1,0,(atrib and $20)<>0,(atrib and $10)<>0);
      gfx[0].buffer[f]:=false;
    end;
end;
//scroll de varios tipos...
if (scroll_crt and $2)<>0 then begin
  //horizontal 8 lineas independientes
  //eje X
  if (scroll_crt and $4)<>0 then for f:=0 to 31 do scroll__x_part(1,2,255-memoria_zram[ram_bank,f],0,f*8,8);
  //Eje Y
  if (scroll_crt and $8)<>0 then for f:=0 to 31 do scroll__y_part(1,2,255-memoria_zram[ram_bank,f],0,f*8,8);
end else begin
  //Scroll total
  scroll_x_y(1,2,scroll_x,scroll_y);
end;
//sprites
if (sprite_crt and $8)<>0 then begin
  for f:=0 to 48 do draw_sprites(1,$800+f*5);
  for f:=0 to $ff do draw_sprites(0,$800+f*5);
end else begin
  for f:=0 to 48 do draw_sprites(1,f*5);
  for f:=0 to $ff do draw_sprites(0,f*5);
end;
actualiza_trozo_final(16,8,224,240,2);
end;

procedure eventos_jackal;
begin
if event.arcade then begin
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
end;
end;

procedure jackal_principal;
var
  f:byte;
  frame_m,frame_s:single;
begin
init_controls(false,false,false,true);
frame_m:=main_m6809.tframes;
frame_s:=snd_m6809.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to 255 do begin
    main_m6809.run(frame_m);
    frame_m:=frame_m+main_m6809.tframes-main_m6809.contador;
    snd_m6809.run(frame_s);
    frame_s:=frame_s+snd_m6809.tframes-snd_m6809.contador;
    if f=239 then begin
      if irq_enable then begin
        main_m6809.change_irq(HOLD_LINE);
        snd_m6809.change_nmi(PULSE_LINE);
      end;
      update_video_jackal;
    end;
  end;
  eventos_jackal;
  video_sync;
end;
end;

function jackal_getbyte(direccion:word):byte;
begin
    case direccion of
        $10:jackal_getbyte:=$ff;
        $11:jackal_getbyte:=marcade.in1;
        $12:jackal_getbyte:=marcade.in2;
        $13:jackal_getbyte:=marcade.in0;
        $18:jackal_getbyte:=$5f;
        $20..$5f:jackal_getbyte:=memoria_zram[ram_bank,direccion-$20];
        $2000..$27ff:jackal_getbyte:=memoria_voram[ram_bank,direccion and $7ff];
        $3000..$3fff:jackal_getbyte:=memoria_sprite[sprite_bank,direccion and $fff];
        $4000..$bfff:jackal_getbyte:=memoria_rom[banco,direccion-$4000];
    else jackal_getbyte:=memoria[direccion];
    end;
end;

procedure jackal_putbyte(direccion:word;valor:byte);
begin
if direccion>$3FFF then exit;
memoria[direccion]:=valor;
case direccion of
  $0:scroll_x:=255-valor;
  $1:scroll_y:=valor;
  $2:scroll_crt:=valor;
  $3:sprite_crt:=valor;
  $4:irq_enable:=(valor and $2)<>0;
  $1c:begin
          banco:=(valor and $20) shr 5;
          ram_bank:=(valor and $10) shr 4;
          sprite_bank:=(valor and $8) shr 3;
        end;
  $20..$5f:memoria_zram[ram_bank,direccion-$20]:=valor;
  $2000..$27ff:begin
                  memoria_voram[ram_bank,direccion and $7ff]:=valor;
                  gfx[0].buffer[direccion and $3ff]:=true;
               end;
  $3000..$3fff:memoria_sprite[sprite_bank,direccion and $fff]:=valor;
end;
end;

function sound_getbyte(direccion:word):byte;
begin
case direccion of
  $2001:sound_getbyte:=ym2151_0.status;
  $6060..$7fff:sound_getbyte:=memoria[direccion and $1fff];
  else sound_getbyte:=mem_snd[direccion];
end;
end;

procedure cambiar_color(dir:word);
var
        data:word;
        color:tcolor;
begin
  data:=buffer_paleta[dir]+(buffer_paleta[dir+1] shl 8);
  color.r:=pal5bit(data);
  color.g:=pal5bit(data shr 5);
  color.b:=pal5bit(data shr 10);
  dir:=dir shr 1;
  set_pal_color(color,dir);
  case dir of
    256..511:fillchar(gfx[0].buffer[0],$400,1);
  end;
end;

procedure sound_putbyte(direccion:word;valor:byte);
begin
if direccion>$7fff then exit;
mem_snd[direccion]:=valor;
case direccion of
  $2000:ym2151_0.reg(valor);
  $2001:ym2151_0.write(valor);
  $4000..$43ff:if buffer_paleta[direccion and $3ff]<>valor then begin
                  buffer_paleta[direccion and $3ff]:=valor;
                  cambiar_color(direccion and $3fe);
               end;
  $6060..$7fff:memoria[direccion and $1fff]:=valor;
end;
end;

procedure sound_instruccion;
begin
  ym2151_0.update;
end;

end.
