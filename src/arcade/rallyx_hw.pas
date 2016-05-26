unit rallyx_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,gfx_engine,namco_snd,samples,rom_engine,
     pal_engine,konami_snd,sound_engine;

//Driver genericas
procedure Cargar_rallyxh;
function iniciar_rallyxh:boolean; 
procedure reset_rallyxh; 
procedure cerrar_rallyxh; 
//especificas
procedure jungler_principal;
function jungler_getbyte(direccion:word):byte;
procedure jungler_putbyte(direccion:word;valor:byte);
function rallyx_getbyte(direccion:word):byte;
procedure rallyx_putbyte(direccion:word;valor:byte);
procedure rallyx_outbyte(valor:byte;puerto:word);
procedure rallyx_playsound;

implementation
const
        //Jungler
        jungler_rom:array[0..4] of tipo_roms=(
        (n:'jungr1';l:$1000;p:0;crc:$5bd6ad15),(n:'jungr2';l:$1000;p:$1000;crc:$dc99f1e3),
        (n:'jungr3';l:$1000;p:$2000;crc:$3dcc03da),(n:'jungr4';l:$1000;p:$3000;crc:$f92e9940),());
        jungler_pal:array[0..2] of tipo_roms=(
        (n:'18s030.8b';l:$20;p:0;crc:$55a7e6d1),(n:'tbp24s10.9d';l:$100;p:$20;crc:$d223f7b8),());
        jungler_char:array[0..2] of tipo_roms=(
        (n:'5k';l:$800;p:0;crc:$924262bf),(n:'5m';l:$800;p:$800;crc:$131a08ac),());
        jungler_sound:tipo_roms=(n:'1b';l:$1000;p:0;crc:$f86999c3);
        jungler_dots:tipo_roms=(n:'82s129.10g';l:$100;p:0;crc:$c59c51b7);
        //Rally X
        rallyx_rom:array[0..4] of tipo_roms=(
        (n:'1b';l:$1000;p:0;crc:$5882700d),(n:'rallyxn.1e';l:$1000;p:$1000;crc:$ed1eba2b),
        (n:'rallyxn.1h';l:$1000;p:$2000;crc:$4f98dd1c),(n:'rallyxn.1k';l:$1000;p:$3000;crc:$9aacccf0),());
        rallyx_pal:array[0..2] of tipo_roms=(
        (n:'rx-1.11n';l:$20;p:0;crc:$c7865434),(n:'rx-7.8p';l:$100;p:$20;crc:$834d4fda),());
        rallyx_char:tipo_roms=(n:'8e';l:$1000;p:0;crc:$277c1de5);
        rallyx_sound:tipo_roms=(n:'rx-5.3p';l:$100;p:0;crc:$4bad7017);
        rallyx_dots:tipo_roms=(n:'rx1-6.8m';l:$100;p:0;crc:$3c16f62c);
        rallyx_samples:tipo_nombre_samples=(nombre:'bang.wav');
        //New Rally X
        nrallyx_rom:array[0..4] of tipo_roms=(
        (n:'nrx_prg1.1d';l:$1000;p:0;crc:$ba7de9fc),(n:'nrx_prg2.1e';l:$1000;p:$1000;crc:$eedfccae),
        (n:'nrx_prg3.1k';l:$1000;p:$2000;crc:$b4d5d34a),(n:'nrx_prg4.1l';l:$1000;p:$3000;crc:$7da5496d),());
        nrallyx_pal:array[0..2] of tipo_roms=(
        (n:'nrx1-1.11n';l:$20;p:0;crc:$a0a49017),(n:'nrx1-7.8p';l:$100;p:$20;crc:$4e46f485),());
        nrallyx_char:array[0..2] of tipo_roms=(
        (n:'nrx_chg1.8e';l:$800;p:0;crc:$1fff38a4),(n:'nrx_chg2.8d';l:$800;p:$800;crc:$85d9fffd),());
        nrallyx_sound:tipo_roms=(n:'rx1-5.3p';l:$100;p:0;crc:$4bad7017);
        nrallyx_dots:tipo_roms=(n:'rx1-6.8m';l:$100;p:0;crc:$3c16f62c);
var
 last,scroll_x,scroll_y:byte;
 hacer_int:boolean;

//jungler
procedure update_video_jungler;inline;
var
  f,nchar,y,x,color:word;
  h,atrib:byte;
begin
//Backgorund (256x256)
for f:=0 to $3ff do begin
  if gfx[0].buffer[f] then begin
    x:=f div 32;
    y:=31-(f mod 32);
    atrib:=memoria[$8c00+f];
    color:=(atrib and $3f) shl 2;
    nchar:=memoria[$8400+f];
    put_gfx_flip(x*8,y*8,nchar,color,1,0,(atrib and $80)=0,(atrib and $40)<>0);
    if (atrib and $20)=0 then put_gfx_block_trans(x*8,y*8,5,8,8)
      else put_gfx_trans_flip(x*8,y*8,nchar,color,5,0,(atrib and $80)=0,(atrib and $40)<>0);
    gfx[0].buffer[f]:=false;
  end;
end;
actualiza_trozo(0,0,256,256,1,0,32,256,256,4);
//Sprites
for f:=$f downto $a do begin
    atrib:=memoria[$8000+(f*2)];
    nchar:=(atrib and $fc) shr 2;
    color:=(memoria[$8801+(f*2)] and $3f) shl 2;
    x:=memoria[$8800+(f*2)]-1;
    y:=memoria[$8001+(f*2)]+((memoria[$8801+(f*2)] and $80) shl 1);
    put_gfx_sprite_mask(nchar,color,(atrib and 2)<>0,(atrib and 1)<>0,1,0,$f);
    actualiza_gfx_sprite(x,y,4,1);
end;
actualiza_trozo(0,0,256,256,5,0,32,256,256,4);
//Foreground  (solo 256x64)
f:=$20;
while f<$3ff do begin
for h:=0 to 7 do begin
  if gfx[2].buffer[f] then begin
    x:=f div 32;
    y:=7-(f mod 8);
    color:=(memoria[$8800+f] and $3f) shl 2;
    nchar:=memoria[$8000+f];
    put_gfx(x*8,y*8,nchar,color,2,0);
    gfx[2].buffer[f]:=false;
  end;
  f:=f+1;
 end;
 f:=f+24;
end;
actualiza_trozo(0,32,256,32,2,0,0,256,32,4);
actualiza_trozo(0,0,256,32,2,0,32,256,32,4);
//Disparos
for f:=$14 to $20 do begin
    x:=memoria[$8820+f];
    if x>=16 then begin
      nchar:=(memoria[$a030+f] and $7) xor 7;
      y:=memoria[$8020+f]+((memoria[$a030+f] xor $ff) and $8) shl 5;
      if y>288 then y:=y and $FF;
      put_gfx_trans(0,0,nchar,16,3,2);
      actualiza_trozo(0,0,4,4,3,x,y,4,4,4);
    end;
end;
end;

procedure eventos_jungler;
begin
if event.arcade then begin
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  if arcade_input.down[0] then marcade.in2:=(marcade.in2 and $7f) else marcade.in2:=(marcade.in2 or $80);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
end;
end;

procedure jungler_principal;
var
  frame_m:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=main_z80.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
      //Main CPU
      main_z80.run(frame_m);
      frame_m:=frame_m+main_z80.tframes-main_z80.contador;
      //Sound CPU
      konamisnd_0.run(f);
      if f=239 then begin
        if hacer_int then main_z80.pedir_nmi:=PULSE_LINE;
        update_video_jungler;
      end;
  end;
  actualiza_trozo(16+ADD_SPRITE,ADD_SPRITE,224,288,4,0,0,224,288,pant_temp);
  eventos_jungler;
  video_sync;
end;
end;

function jungler_getbyte(direccion:word):byte;
begin
case direccion of
  $a000:jungler_getbyte:=marcade.in0;
  $a080:jungler_getbyte:=marcade.in1;
  $a100:jungler_getbyte:=marcade.in2;
  $a180:jungler_getbyte:=$b7;
    else jungler_getbyte:=memoria[direccion];
end;
end;

procedure jungler_putbyte(direccion:word;valor:byte);
begin
if direccion<$4000 then exit;
memoria[direccion]:=valor;
case direccion of
    $8000..$83ff:gfx[2].buffer[direccion and $3ff]:=true;
    $8400..$87ff:gfx[0].buffer[direccion and $3ff]:=true;
    $8800..$8bff:gfx[2].buffer[direccion and $3ff]:=true;
    $8c00..$8fff:gfx[0].buffer[direccion and $3ff]:=true;
    $a100:konamisnd_0.sound_latch:=valor;
    $a180:begin
              if ((last=0) and (valor<>0)) then konamisnd_0.pedir_irq:=HOLD_LINE;
              last:=valor;
          end;
    $a181:hacer_int:=valor<>0;
end;
end;

//Rally X
procedure update_video_rallyx;inline;
var
  f,nchar,y,x,color:word;
  h,atrib:byte;
begin
//Backgorund (256x256)
for f:=0 to $3ff do begin
  if gfx[0].buffer[f] then begin
    y:=f div 32;
    x:=f mod 32;
    atrib:=memoria[$8c00+f];
    color:=(atrib and $3f) shl 2;
    nchar:=memoria[$8400+f];
    put_gfx_flip(x*8,y*8,nchar,color,1,0,(atrib and $40)=0,(atrib and $80)<>0);
    if (atrib and $20)=0 then put_gfx_block_trans(x*8,y*8,5,8,8)
      else put_gfx_flip(x*8,y*8,nchar,color,5,0,(atrib and $40)=0,(atrib and $80)<>0);
    gfx[0].buffer[f]:=false;
  end;
end;
scroll_x_y(1,4,scroll_x-3,scroll_y);
//Sprites
for f:=$f downto $a do begin
    atrib:=memoria[$8000+(f*2)];
    nchar:=(atrib and $fc) shr 2;
    color:=(memoria[$8801+(f*2)] and $3f) shl 2;
    y:=241-memoria[$8800+(f*2)];
    x:=memoria[$8001+(f*2)]+((memoria[$8801+(f*2)] and $80) shl 1);
    put_gfx_sprite_mask(nchar,color,(atrib and 1)<>0,(atrib and 2)<>0,1,0,$f);
    actualiza_gfx_sprite(x,y,4,1);
end;
scroll_x_y(5,4,scroll_x-3,scroll_y);
//Foreground  (solo 256x64)
f:=$20;
while f<$3ff do begin
for h:=0 to 7 do begin
  if gfx[2].buffer[f] then begin
    y:=f div 32;
    x:=f mod 8;
    atrib:=memoria[$8800+f];
    color:=(atrib and $3f) shl 2;
    nchar:=memoria[$8000+f];
    put_gfx_flip(x*8,y*8,nchar,color,2,0,(atrib and $40)=0,(atrib and $80)<>0);
    gfx[2].buffer[f]:=false;
  end;
  f:=f+1;
 end;
 f:=f+24;
end;
actualiza_trozo(32,0,32,256,2,224,0,32,256,4);
actualiza_trozo(0,0,32,256,2,256,0,32,256,4);
//Radar
for f:=0 to $b do begin
    y:=237-memoria[$8834+f];
    atrib:=memoria[$a004+f];
    nchar:=((atrib and $e) shr 1) xor 7;
    x:=memoria[$8034+f]+((not(atrib) and $8) shl 5);
    if x<32 then x:=x+256;
    put_gfx_trans(0,0,nchar,16,3,2);
    actualiza_trozo(0,0,4,4,3,x,y+15,4,4,4);
end;
end;

procedure eventos_rallyx;
begin
if event.arcade then begin
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.coin[1] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
end;
end;

procedure rallyx_principal;
var
  frame:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame:=main_z80.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
      main_z80.run(frame);
      frame:=frame+main_z80.tframes-main_z80.contador;
      if f=239 then begin
        if hacer_int then main_z80.pedir_irq:=ASSERT_LINE;
        update_video_rallyx;
      end;
  end;
  actualiza_trozo(ADD_SPRITE,16+ADD_SPRITE,288,224,4,0,0,288,224,pant_temp);
  if sound_status.hay_sonido then namco_playsound;
  eventos_rallyx;
  video_sync;
end;
end;

function rallyx_getbyte(direccion:word):byte;
begin
case direccion of
  $a000:rallyx_getbyte:=marcade.in0;
  $a080:rallyx_getbyte:=marcade.in1;
  $a100:rallyx_getbyte:=marcade.in2;
  else rallyx_getbyte:=memoria[direccion];
end;
end;

procedure rallyx_putbyte(direccion:word;valor:byte);
begin
if direccion<$4000 then exit;
memoria[direccion]:=valor;
case direccion of
  $8000..$83ff:gfx[2].buffer[direccion and $3ff]:=true;
  $8400..$87ff:gfx[0].buffer[direccion and $3ff]:=true;
  $8800..$8bff:gfx[2].buffer[direccion and $3ff]:=true;
  $8c00..$8fff:gfx[0].buffer[direccion and $3ff]:=true;
  $a100..$a11f:namco_sound.registros_namco[direccion and $1f]:=valor;
  $a130:scroll_x:=valor;
  $a140:scroll_y:=valor;
  $a180:begin
          if ((valor=0) and (last<>0)) then start_sample(0);
          last:=valor;
        end;
  $a181:begin
          hacer_int:=(valor<>0);
          if not(hacer_int) then main_z80.pedir_irq:=CLEAR_LINE;
        end;
  $a183:main_screen.flip_main_screen:=(valor and 1)<>0;
end;
end;
procedure rallyx_outbyte(valor:byte;puerto:word);
begin
if (puerto and $ff)=0 then begin
  main_z80.im0:=valor;
  main_z80.pedir_irq:=CLEAR_LINE;
end;
end;

procedure rallyx_playsound;
begin
  samples_update;
end;

//Funciones genericas
procedure Cargar_rallyxh;
begin
case main_vars.tipo_maquina of
  29:llamadas_maquina.bucle_general:=jungler_principal;
  50:llamadas_maquina.bucle_general:=rallyx_principal;
  70:llamadas_maquina.bucle_general:=rallyx_principal;
end;
llamadas_maquina.iniciar:=iniciar_rallyxh;
llamadas_maquina.cerrar:=cerrar_rallyxh;
llamadas_maquina.reset:=reset_rallyxh;
llamadas_maquina.fps_max:=60.606060606060;
end;

procedure cerrar_rallyxh;
begin
if main_vars.tipo_maquina<>29 then close_samples;
end;

procedure reset_rallyxh;
begin
 main_z80.reset;
 case main_vars.tipo_maquina of
  29:begin
        marcade.in2:=$FF;
        konamisnd_0.reset;
  end;
  50,70:begin
        marcade.in2:=$cb;
        namco_sound_reset;
        reset_samples;
  end;
 end;
 reset_audio;
 last:=0;
 marcade.in0:=$FF;
 marcade.in1:=$FF;
end;

function iniciar_rallyxh:boolean;
var
      colores:tpaleta;
      f,x,y:word;
      ctemp1:byte;
      memoria_temp:array[0..$3fff] of byte;
const
  ps_rx:array[0..15] of dword=(8*8+0, 8*8+1, 8*8+2, 8*8+3, 16*8+0, 16*8+1, 16*8+2, 16*8+3,
			 24*8+0, 24*8+1, 24*8+2, 24*8+3, 0, 1, 2, 3);
  ps_x:array[0..15] of dword=(8*8, 8*8+1, 8*8+2, 8*8+3, 0, 1, 2, 3,
			24*8+0, 24*8+1, 24*8+2, 24*8+3, 16*8+0, 16*8+1, 16*8+2, 16*8+3);
  ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			32*8, 33*8, 34*8, 35*8, 36*8, 37*8, 38*8, 39*8);
  pc_x:array[0..7] of dword=(8*8+0, 8*8+1, 8*8+2, 8*8+3, 0, 1, 2, 3);
  pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
  pd_x:array[0..3] of dword=(0*8, 1*8, 2*8, 3*8);
  pd_y:array[0..3] of dword=(0*32, 1*32, 2*32, 3*32);
procedure cargar_chars(tipo:byte);
begin
init_gfx(0,8,8,256);
if tipo=1 then begin
  gfx[0].trans[0]:=true;
  gfx_set_desc_data(2,0,16*8,4,0);
end else begin
  gfx[0].trans[3]:=true;
  gfx_set_desc_data(2,0,16*8,0,4);
end;
convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],(tipo=1),false);
end;
procedure cargar_sprites(tipo:byte);
begin
init_gfx(1,16,16,64);
gfx[1].trans[0]:=true;
if tipo=1 then begin
  gfx_set_desc_data(2,0,64*8,4,0);
  convert_gfx(1,0,@memoria_temp[0],@ps_x[0],@ps_y[0],true,false);
end else begin
  gfx_set_desc_data(2,0,64*8,0,4);
  convert_gfx(1,0,@memoria_temp[0],@ps_rx[0],@ps_y[0],false,false);
end;
end;
procedure cargar_disparo;
begin
init_gfx(2,4,4,8);
gfx[2].trans[3]:=true;
gfx_set_desc_data(2,0,16*8,6,7);
convert_gfx(2,0,@memoria_temp[0],@pd_x[0],@pd_y[0],false,false)
end;
begin
iniciar_rallyxh:=false;
iniciar_audio(false);
//Pantallas:  principal+char y sprites
case main_vars.tipo_maquina of
  29:begin
        x:=224;
        y:=288;
        screen_init(2,256,64);
  end;
  50,70:begin
        x:=288;
        y:=224;
        screen_init(2,64,256);
  end;
end;
screen_init(1,256,288);
screen_mod_scroll(1,256,256,255,256,256,255);
screen_init(3,4,4,true);
screen_init(4,512,512,false,true);
screen_mod_sprites(4,512,512,$1ff,$1ff);
screen_init(5,256,288,true);
screen_mod_scroll(5,256,256,255,256,256,255);
iniciar_video(x,y);
//Main CPU
main_z80:=cpu_z80.create(3072000,$100);
case main_vars.tipo_maquina of
  29:begin //jungler
        main_z80.change_ram_calls(jungler_getbyte,jungler_putbyte);
        //Sound Chip
        konamisnd_0:=konamisnd_chip.create(1,TIPO_JUNGLER,1789772,$100);
        //cargar roms
        if not(cargar_roms(@memoria[0],@jungler_rom[0],'jungler.zip',0)) then exit;
        //cargar sonido
        if not(cargar_roms(@mem_snd[0],@jungler_sound,'jungler.zip',1)) then exit;
        //convertir chars
        if not(cargar_roms(@memoria_temp[0],@jungler_char[0],'jungler.zip',0)) then exit;
        cargar_chars(1);
        //convertir sprites
        cargar_sprites(1);
        //Y ahora el'disparo'
        if not(cargar_roms(@memoria_temp[0],@jungler_dots,'jungler.zip',1)) then exit;
        cargar_disparo;
        //poner la paleta
        if not(cargar_roms(@memoria_temp[0],@jungler_pal[0],'jungler.zip',0)) then exit;
  end;
  50:begin //rallyx
        main_z80.change_ram_calls(rallyx_getbyte,rallyx_putbyte);
        main_z80.change_io_calls(nil,rallyx_outbyte);
        //cargar roms
        if not(cargar_roms(@memoria[0],@rallyx_rom[0],'rallyx.zip',0)) then exit;
        //cargar sonido y samples
        if not(cargar_roms(@namco_sound.onda_namco[0],@rallyx_sound,'rallyx.zip',1)) then exit;
        namco_sound_init(3,false);
        if load_samples('rallyx.zip',@rallyx_samples,1) then begin
         main_z80.init_sound(rallyx_playsound);
        end;
        //convertir chars
        if not(cargar_roms(@memoria_temp[0],@rallyx_char,'rallyx.zip',1)) then exit;
        cargar_chars(0);
        //convertir sprites
        cargar_sprites(0);
        //Y ahora el'disparo'
        if not(cargar_roms(@memoria_temp[0],@rallyx_dots,'rallyx.zip',1)) then exit;
        cargar_disparo;
        //poner la paleta
        if not(cargar_roms(@memoria_temp[0],@rallyx_pal[0],'rallyx.zip',0)) then exit;
     end;
  70:begin  //new rally x
        main_z80.change_ram_calls(rallyx_getbyte,rallyx_putbyte);
        main_z80.change_io_calls(nil,rallyx_outbyte);
        //cargar roms y ordenarlas
        if not(cargar_roms(@memoria_temp[0],@nrallyx_rom[0],'nrallyx.zip',0)) then exit;
        copymemory(@memoria[$0],@memoria_temp[$0],$800);
        copymemory(@memoria[$1000],@memoria_temp[$800],$800);
        copymemory(@memoria[$800],@memoria_temp[$1000],$800);
        copymemory(@memoria[$1800],@memoria_temp[$1800],$800);
        copymemory(@memoria[$2000],@memoria_temp[$2000],$800);
        copymemory(@memoria[$3000],@memoria_temp[$2800],$800);
        copymemory(@memoria[$2800],@memoria_temp[$3000],$800);
        copymemory(@memoria[$3800],@memoria_temp[$3800],$800);
        //cargar sonido y samples
        if not(cargar_roms(@namco_sound.onda_namco[0],@nrallyx_sound,'nrallyx.zip',1)) then exit;
        namco_sound_init(3,false);
        if load_samples('rallyx.zip',@rallyx_samples,1) then begin
          main_z80.init_sound(rallyx_playsound);
        end;
        //convertir chars
        if not(cargar_roms(@memoria_temp[0],@nrallyx_char[0],'nrallyx.zip',0)) then exit;
        cargar_chars(0);
        //convertir sprites
        cargar_sprites(0);
        //Y ahora el'disparo'
        if not(cargar_roms(@memoria_temp[0],@nrallyx_dots,'nrallyx.zip',1)) then exit;
        cargar_disparo;
        //poner la paleta
        if not(cargar_roms(@memoria_temp[0],@nrallyx_pal[0],'nrallyx.zip',0)) then exit;
     end;
end;
for f:=0 to 31 do begin
    ctemp1:=memoria_temp[f];
    colores[f].r:=$21*(ctemp1 and 1)+$47*((ctemp1 shr 1) and 1)+$97*((ctemp1 shr 2) and 1);
    colores[f].g:=$21*((ctemp1 shr 3) and 1)+$47*((ctemp1 shr 4) and 1)+$97*((ctemp1 shr 5) and 1);
    colores[f].b:=0+$50*((ctemp1 shr 6) and 1)+$ab*((ctemp1 shr 7) and 1);
end;
set_pal(colores,32);
//color lookup
for f:=0 to 255 do begin
  gfx[1].colores[f]:=memoria_temp[$20+f] and $f;
  gfx[0].colores[f]:=memoria_temp[$20+f] and $f;
end;
//final
reset_rallyxh;
iniciar_rallyxh:=true;
end;

end.
