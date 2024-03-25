unit caloriekun_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,ay_8910,gfx_engine,rom_engine,
     pal_engine,sound_engine,sega_decrypt_2,timer_engine;

function iniciar_caloriekun:boolean;

implementation
const
        caloriekun_rom:array[0..2] of tipo_roms=(
        (n:'epr10072.1j';l:$4000;p:0;crc:$ade792c1),(n:'epr10073.1k';l:$4000;p:$4000;crc:$b53e109f),
        (n:'epr10074.1m';l:$4000;p:$8000;crc:$a08da685));
        caloriekun_sonido:tipo_roms=(n:'epr10075.4d';l:$4000;p:0;crc:$ca547036);
        caloriekun_char:array[0..2] of tipo_roms=(
        (n:'epr10082.5r';l:$2000;p:0;crc:$5984ea44),(n:'epr10081.4r';l:$2000;p:$2000;crc:$e2d45dd8),
        (n:'epr10080.3r';l:$2000;p:$4000;crc:$42edfcfe));
        caloriekun_tiles:array[0..2] of tipo_roms=(
        (n:'epr10078.7d';l:$4000;p:0;crc:$5b8eecce),(n:'epr10077.6d';l:$4000;p:$4000;crc:$01bcb609),
        (n:'epr10076.5d';l:$4000;p:$8000;crc:$b1529782));
        caloriekun_sprites:array[0..2] of tipo_roms=(
        (n:'epr10071.7m';l:$4000;p:0;crc:$5f55527a),(n:'epr10070.7k';l:$4000;p:$4000;crc:$97f35a23),
        (n:'epr10069.7j';l:$4000;p:$8000;crc:$c0c3deaf));
        caloriekun_tiles_map:tipo_roms=(n:'epr10079.8d';l:$2000;p:0;crc:$3c61a42c);
        //DIP
        caloriekun_dipa:array [0..5] of def_dip=(
        (mask:$3;name:'Coin A';number:4;dip:((dip_val:$0;dip_name:'1C 1C'),(dip_val:$1;dip_name:'1C 2C'),(dip_val:$2;dip_name:'1C 3C'),(dip_val:$3;dip_name:'1C 6C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Coin B';number:4;dip:((dip_val:$c;dip_name:'2C 1C'),(dip_val:$0;dip_name:'1C 1C'),(dip_val:$4;dip_name:'1C 2C'),(dip_val:$8;dip_name:'1C 3C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Cabinet';number:2;dip:((dip_val:$10;dip_name:'Upright'),(dip_val:$0;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$20;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Lives';number:4;dip:((dip_val:$c0;dip_name:'2'),(dip_val:$0;dip_name:'3'),(dip_val:$40;dip_name:'4'),(dip_val:$80;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),());
        caloriekun_dipb:array [0..5] of def_dip=(
        (mask:$3;name:'Bonus Life';number:3;dip:((dip_val:$;dip_name:'None'),(dip_val:$1;dip_name:'20K'),(dip_val:$3;dip_name:'20K 60K'),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Number of Bombs';number:2;dip:((dip_val:$0;dip_name:'3'),(dip_val:$4;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Difficulty - Mogura Nian';number:2;dip:((dip_val:$0;dip_name:'Normal'),(dip_val:$8;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Difficulty - Select of Mogura';number:4;dip:((dip_val:$0;dip_name:'Easy'),(dip_val:$20;dip_name:'Normal'),(dip_val:$10;dip_name:'Hard'),(dip_val:$30;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Infinite Lives';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$80;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 memoria_fondo:array[0..$1fff] of byte;
 numero_fondo,sound_latch:byte;
 mem_dec:array[0..$7fff] of byte;
 fondo_changed:boolean;

procedure update_video_caloriekun;
var
  x,y,atrib:byte;
  pos,f,nchar,color:word;
begin
if ((numero_fondo and $10)=0) then fill_full_screen(3,$400)
else begin
  if fondo_changed then begin
    for f:=0 to $ff do begin
      x:=f mod 16;
      y:=f div 16;
      pos:=(numero_fondo and $f)*$200;
      atrib:=memoria_fondo[$100+pos+f];
      color:=atrib and $f;
      nchar:=memoria_fondo[pos+f]+((atrib and $10) shl 4);
      put_gfx_flip(x*16,y*16,nchar,color shl 3,1,1,(atrib and $40)<>0,false);
    end;
  end;
  actualiza_trozo(0,0,256,256,1,0,0,256,256,3);
end;
for f:=0 to $3ff do begin
  atrib:=memoria[$d400+f];
  color:=atrib and $f;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
    x:=f mod 32;
    y:=f div 32;
    nchar:=memoria[$d000+f]+(atrib and $30) shl 4;
    put_gfx_trans_flip(x*8,y*8,nchar,color shl 3,2,0,(atrib and $40)<>0,(atrib and $80)<>0);
    gfx[0].buffer[f]:=false;
  end;
end;
actualiza_trozo(0,0,256,256,2,0,0,256,256,3);
for f:=$ff downto 0 do begin
   x:=memoria[$d803+(f*4)];
   y:=$ff-memoria[$d802+(f*4)];
   nchar:=memoria[$d800+(f*4)];
   atrib:=memoria[$d801+(f*4)];
   color:=(atrib and $f) shl 3;
   if (atrib and $10)<>0 then begin
      put_gfx_sprite(nchar or $40,color,(atrib and $40)<>0,false,3);
      actualiza_gfx_sprite(x,y-31,3,3);
   end else begin
      put_gfx_sprite(nchar,color,(atrib and $40)<>0,false,2);
      actualiza_gfx_sprite(x,(y-15) and $ff,3,2);
   end;
end;
actualiza_trozo_final(0,16,256,224,3);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
end;

procedure eventos_caloriekun;
begin
if event.arcade then begin
  //p1
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 or 1) else marcade.in0:=(marcade.in0 and $fe);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 or 2) else marcade.in0:=(marcade.in0 and $fd);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 or 4) else marcade.in0:=(marcade.in0 and $fb);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 or 8) else marcade.in0:=(marcade.in0 and $f7);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 or $10) else marcade.in0:=(marcade.in0 and $ef);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 or $20) else marcade.in0:=(marcade.in0 and $df);
  //p2
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 or 1) else marcade.in1:=(marcade.in1 and $fe);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 or 2) else marcade.in1:=(marcade.in1 and $fd);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 or 4) else marcade.in1:=(marcade.in1 and $fb);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 or 8) else marcade.in1:=(marcade.in1 and $f7);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 or $10) else marcade.in1:=(marcade.in1 and $ef);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 or $20) else marcade.in1:=(marcade.in1 and $df);
  //System
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 or 1) else marcade.in2:=(marcade.in2 and $fe);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 or 2) else marcade.in2:=(marcade.in2 and $fd);
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 or 4) else marcade.in2:=(marcade.in2 and $fb);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 or 8) else marcade.in2:=(marcade.in2 and $f7);
end;
end;

procedure caloriekun_principal;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=z80_0.tframes;
frame_s:=z80_1.tframes;
while EmuStatus=EsRunning do begin
  for f:=0 to $ff do begin
    //Main CPU
    z80_0.run(frame_m);
    frame_m:=frame_m+z80_0.tframes-z80_0.contador;
    //Sound
    z80_1.run(frame_s);
    frame_s:=frame_s+z80_1.tframes-z80_1.contador;
    if f=239 then begin
      update_video_caloriekun;
      z80_0.change_irq(HOLD_LINE);
    end;
  end;
  eventos_caloriekun;
  video_sync;
end;
end;

function caloriekun_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff:if z80_0.opcode then caloriekun_getbyte:=mem_dec[direccion]
                 else caloriekun_getbyte:=memoria[direccion];
  $8000..$dbff:caloriekun_getbyte:=memoria[direccion];
  $dc00..$dcff:caloriekun_getbyte:=buffer_paleta[direccion and $ff];
  $f000:caloriekun_getbyte:=marcade.in0;
  $f001:caloriekun_getbyte:=marcade.in1;
  $f002:caloriekun_getbyte:=marcade.in2;
  $f004:caloriekun_getbyte:=marcade.dswa;
  $f005:caloriekun_getbyte:=marcade.dswb;
end;
end;

procedure caloriekun_putbyte(direccion:word;valor:byte);
procedure cambiar_color(dir:word);
var
  tmp_color:byte;
  color:tcolor;
begin
  tmp_color:=buffer_paleta[dir];
  color.r:=pal4bit(tmp_color);
  color.g:=pal4bit(tmp_color shr 4);
  tmp_color:=buffer_paleta[dir+1];
  color.b:=pal4bit(tmp_color);
  dir:=dir shr 1;
  set_pal_color(color,dir);
  buffer_color[(dir shr 3) and $f]:=true;
end;
begin
case direccion of
        0..$bfff:; //ROM
        $c000..$cfff,$d800..$dbff:memoria[direccion]:=valor;
        $d000..$d7ff:if memoria[direccion]<>valor then begin
                        gfx[0].buffer[direccion and $3ff]:=true;
                        memoria[direccion]:=valor;
                     end;
        $dc00..$dcff:if buffer_paleta[direccion and $ff]<>valor then begin
                        buffer_paleta[direccion and $ff]:=valor;
                        cambiar_color(direccion and $fe);
                     end;
        $de00:if (numero_fondo<>valor) then begin
                fondo_changed:=true;
                numero_fondo:=valor;
              end;
        $f800:sound_latch:=valor;
end;
end;

function snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$3fff,$8000..$87ff:snd_getbyte:=mem_snd[direccion];
  $c000:begin
          snd_getbyte:=sound_latch;
          sound_latch:=0;
        end;
end;
end;

procedure snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$3fff:; //ROM
  $8000..$87ff:mem_snd[direccion]:=valor;
end;
end;

function snd_inbyte(puerto:word):byte;
begin
case (puerto and $ff) of
  $1:snd_inbyte:=ay8910_0.Read;
  $11:snd_inbyte:=ay8910_1.Read;
  //$81:snd_inbyte:=ay8910_2.Read;
end;
end;

procedure snd_outbyte(puerto:word;valor:byte);
begin
case (puerto and $ff) of
  $00:ay8910_0.Control(valor);
  $01:ay8910_0.Write(valor);
  $10:ay8910_1.Control(valor);
  $11:ay8910_1.Write(valor);
  //$80:ay8910_2.Control(valor);
  //$81:ay8910_2.Write(valor);
end
end;

procedure caloriekun_update_sound;
begin
  ay8910_0.update;
  ay8910_1.update;
  //ay8910_2.update;
end;

procedure caloriekun_snd_irq;
begin
  z80_1.change_irq(HOLD_LINE);
end;

//Main
procedure caloriekun_reset;
begin
z80_0.reset;
z80_1.reset;
ay8910_0.reset;
ay8910_1.reset;
//ay8910_2.reset;
reset_audio;
sound_latch:=0;
numero_fondo:=$ff;
fondo_changed:=true;
marcade.in0:=0;
marcade.in1:=0;
marcade.in2:=0;
end;

function iniciar_caloriekun:boolean;
const
      pt_x:array[0..31] of dword=(0, 1, 2, 3, 4, 5, 6, 7,
			8*8+0, 8*8+1, 8*8+2, 8*8+3, 8*8+4, 8*8+5, 8*8+6, 8*8+7,
			32*8+0, 32*8+1, 32*8+2, 32*8+3, 32*8+4, 32*8+5, 32*8+6, 32*8+7,
			40*8+0, 40*8+1, 40*8+2, 40*8+3, 40*8+4, 40*8+5, 40*8+6, 40*8+7);
      pt_y:array[0..31] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			16*8, 17*8, 18*8, 19*8, 20*8, 21*8, 22*8, 23*8,
			64*8, 65*8, 66*8, 67*8, 68*8, 69*8, 70*8, 71*8,
			80*8, 81*8, 82*8, 83*8, 84*8, 85*8, 86*8, 87*8);
var
  memoria_temp:array[0..$ffff] of byte;
begin
llamadas_maquina.bucle_general:=caloriekun_principal;
llamadas_maquina.reset:=caloriekun_reset;
iniciar_caloriekun:=false;
iniciar_audio(false);
screen_init(1,256,256);
screen_init(2,256,256,true);
screen_init(3,256,256,false,true);
iniciar_video(256,224);
//Main CPU
z80_0:=cpu_z80.create(4000000,256);
z80_0.change_ram_calls(caloriekun_getbyte,caloriekun_putbyte);
if not(roms_load(@memoria,caloriekun_rom)) then exit;
decode_sega_type2(@memoria,@mem_dec,S317_000X,0);
//Sound CPU
z80_1:=cpu_z80.create(3000000,256);
z80_1.change_ram_calls(snd_getbyte,snd_putbyte);
z80_1.change_io_calls(snd_inbyte,snd_outbyte);
z80_1.init_sound(caloriekun_update_sound);
timers.init(z80_1.numero_cpu,3000000/64,caloriekun_snd_irq,nil,true);
if not(roms_load(@mem_snd,caloriekun_sonido)) then exit;
//Sound Chip
ay8910_0:=ay8910_chip.create(1500000,AY8910,1);
ay8910_1:=ay8910_chip.create(1500000,AY8910,1);
//ay8910_2:=ay8910_chip.create(1500000,AY8910,1);
//convertir chars
if not(roms_load(@memoria_temp,caloriekun_char)) then exit;
init_gfx(0,8,8,$400);
gfx[0].trans[0]:=true;
gfx_set_desc_data(3,0,8*8,0,$2000*8,$2000*8*2);
convert_gfx(0,0,@memoria_temp,@pt_x,@pt_y,false,false);
//convertir tiles
if not(roms_load(@memoria_temp,caloriekun_tiles)) then exit;
init_gfx(1,16,16,$200);
gfx_set_desc_data(3,0,32*8,0,$4000*8,$4000*2*8);
convert_gfx(1,0,@memoria_temp,@pt_x,@pt_y,false,false);
if not(roms_load(@memoria_fondo,caloriekun_tiles_map)) then exit;
//sprites 16x16
if not(roms_load(@memoria_temp,caloriekun_sprites)) then exit;
init_gfx(2,16,16,$200);
gfx[2].trans[0]:=true;
gfx_set_desc_data(3,0,32*8,0,$4000*8,$4000*2*8);
convert_gfx(2,0,@memoria_temp,@pt_x,@pt_y,false,false);
//Sprites 32x32
init_gfx(3,32,32,$80);
gfx[3].trans[0]:=true;
gfx_set_desc_data(3,0,128*8,0,$4000*8,$4000*2*8);
convert_gfx(3,0,@memoria_temp,@pt_x,@pt_y,false,false);
//DIP
marcade.dswa:=$30;
marcade.dswa_val:=@caloriekun_dipa;
marcade.dswb:=0;
marcade.dswb_val:=@caloriekun_dipb;
//final
caloriekun_reset;
iniciar_caloriekun:=true;
end;

end.
