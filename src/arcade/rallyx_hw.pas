unit rallyx_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,gfx_engine,namco_snd,samples,rom_engine,
     pal_engine,konami_snd,sound_engine;

function iniciar_rallyxh:boolean;

implementation
const
        //Jungler
        jungler_rom:array[0..3] of tipo_roms=(
        (n:'jungr1';l:$1000;p:0;crc:$5bd6ad15),(n:'jungr2';l:$1000;p:$1000;crc:$dc99f1e3),
        (n:'jungr3';l:$1000;p:$2000;crc:$3dcc03da),(n:'jungr4';l:$1000;p:$3000;crc:$f92e9940));
        jungler_pal:array[0..1] of tipo_roms=(
        (n:'18s030.8b';l:$20;p:0;crc:$55a7e6d1),(n:'tbp24s10.9d';l:$100;p:$20;crc:$d223f7b8));
        jungler_char:array[0..1] of tipo_roms=(
        (n:'5k';l:$800;p:0;crc:$924262bf),(n:'5m';l:$800;p:$800;crc:$131a08ac));
        jungler_sound:tipo_roms=(n:'1b';l:$1000;p:0;crc:$f86999c3);
        jungler_dots:tipo_roms=(n:'82s129.10g';l:$100;p:0;crc:$c59c51b7);
        jungler_dip:array [0..4] of def_dip2=(
        (mask:7;name:'Coin A';number:8;val8:(1,2,3,0,7,6,5,4);name8:('4C 1C','3C 1C','2C 1C','4C 3C','1C 1C','1C 2C','1C 3C','1C 4C')),
        (mask:$38;name:'Coin B';number:8;val8:(8,$10,$18,0,$38,$30,$28,$20);name8:('4C 1C','3C 1C','2C 1C','4C 3C','1C 1C','1C 2C','1C 3C','1C 4C')),
        (mask:$40;name:'Cabinet';number:2;val2:(0,$40);name2:('Upright','Cocktail')),
        (mask:$80;name:'255 Lives';number:2;val2:($80,0);name2:('Off','On')),());
        //Rally X
        rallyx_rom:array[0..3] of tipo_roms=(
        (n:'1b';l:$1000;p:0;crc:$5882700d),(n:'rallyxn.1e';l:$1000;p:$1000;crc:$ed1eba2b),
        (n:'rallyxn.1h';l:$1000;p:$2000;crc:$4f98dd1c),(n:'rallyxn.1k';l:$1000;p:$3000;crc:$9aacccf0));
        rallyx_pal:array[0..1] of tipo_roms=(
        (n:'rx-1.11n';l:$20;p:0;crc:$c7865434),(n:'rx-7.8p';l:$100;p:$20;crc:$834d4fda));
        rallyx_char:tipo_roms=(n:'8e';l:$1000;p:0;crc:$277c1de5);
        rallyx_sound:tipo_roms=(n:'rx-5.3p';l:$100;p:0;crc:$4bad7017);
        rallyx_dots:tipo_roms=(n:'rx1-6.8m';l:$100;p:0;crc:$3c16f62c);
        rallyx_samples:tipo_nombre_samples=(nombre:'bang.wav');
        //New Rally X
        nrallyx_rom:array[0..3] of tipo_roms=(
        (n:'nrx_prg1.1d';l:$1000;p:0;crc:$ba7de9fc),(n:'nrx_prg2.1e';l:$1000;p:$1000;crc:$eedfccae),
        (n:'nrx_prg3.1k';l:$1000;p:$2000;crc:$b4d5d34a),(n:'nrx_prg4.1l';l:$1000;p:$3000;crc:$7da5496d));
        nrallyx_pal:array[0..1] of tipo_roms=(
        (n:'nrx1-1.11n';l:$20;p:0;crc:$a0a49017),(n:'nrx1-7.8p';l:$100;p:$20;crc:$4e46f485));
        nrallyx_char:array[0..1] of tipo_roms=(
        (n:'nrx_chg1.8e';l:$800;p:0;crc:$1fff38a4),(n:'nrx_chg2.8d';l:$800;p:$800;crc:$85d9fffd));
        nrallyx_sound:tipo_roms=(n:'rx1-5.3p';l:$100;p:0;crc:$4bad7017);
        nrallyx_dots:tipo_roms=(n:'rx1-6.8m';l:$100;p:0;crc:$3c16f62c);
        //Dip
        rallyx_dip_a:array [0..1] of def_dip2=(
        (mask:1;name:'Cabinet';number:2;val2:(1,0);name2:('Upright','Cocktail')),());
        rallyx_dip_b:array [0..3] of def_dip2=(
        (mask:6;name:'Bonus Life';number:4;val4:(2,4,6,0);name4:('15K-20K-10K-15K-20K-10K-15K-20K','30K-40K-20K-30K-40K-20K-30K-40K','40K-60K-30K-40K-60K-30K-50K-60K','Invalid')),
        (mask:$c0;name:'Coinage';number:4;val4:($40,$c0,$80,0);name4:('2C 1C','1C 1C','1C 2C','Free Play')),
        (mask:$38;name:'Difficulty';number:8;val8:($10,$28,0,$18,$30,8,$20,$38);name8:('1 Car, Medium','1 Car, Hard','2 Car, Easy','2 Car, Medium','2 Car, Hard','3 Car, Easy','3 Car, Medium','3 Car, Hard')),());
        nrallyx_dip_b:array [0..3] of def_dip2=(
        (mask:6;name:'Bonus Life';number:4;val4:(2,4,6,0);name4:('20K/80K-20K-20K/80K','20K/100K-40K-20K/100K','20K/120K-60K-20K/120K','Invalid')),
        (mask:$c0;name:'Coinage';number:4;val4:($40,$c0,$80,0);name4:('2C 1C','1C 1C','1C 2C','Free Play')),
        (mask:$38;name:'Difficulty';number:8;val8:($10,$28,$18,$30,0,$20,$38,8);name8:('1 Car, Medium','1 Car, Hard','2 Car, Medium','2 Car, Hard','3 Car, Easy','3 Car, Medium','3 Car, Hard','4 Car, Easy')),());

var
 last,scroll_x,scroll_y:byte;
 hacer_int:boolean;

procedure update_bg;
var
  f:word;
  nchar,color,x,y,atrib:byte;
  flipx,flipy:boolean;
begin
for f:=0 to $3ff do begin
  if gfx[0].buffer[f] then begin
    y:=f div 32;
    x:=f mod 32;
    atrib:=memoria[$8c00+f];
    color:=(atrib and $3f) shl 2;
    nchar:=memoria[$8400+f];
    flipx:=(atrib and $40)=0;
    flipy:=(atrib and $80)<>0;
    put_gfx_flip(x*8,y*8,nchar,color,1,0,flipx,flipy);
    if (atrib and $20)=0 then put_gfx_block_trans(x*8,y*8,3,8,8)
      else put_gfx_flip(x*8,y*8,nchar,color,3,0,flipx,flipy);
    gfx[0].buffer[f]:=false;
  end;
end;
end;

procedure update_fg;
var
  x,y,atrib,nchar,color:byte;
  pos:word;
begin
for x:=0 to 7 do begin
  for y:=0 to 31 do begin
	    pos:=x+(y shl 5);
      if gfx[2].buffer[pos] then begin
        atrib:=memoria[$8800+pos];
        nchar:=memoria[$8000+pos];
        color:=(atrib and $3f) shl 2;
        put_gfx_flip(x*8,y*8,nchar,color,2,0,(atrib and $40)=0,(atrib and $80)<>0);
        gfx[2].buffer[pos]:=false;
      end;
  end;
end;
end;

procedure draw_sprites;
var
  f,nchar,atrib,color,y:byte;
  x:word;
  flipx,flipy:boolean;
begin
for f:=$f downto $a do begin
    atrib:=memoria[$8000+(f*2)];
    nchar:=atrib shr 2;
    color:=(memoria[$8801+(f*2)] and $3f) shl 2;
    x:=memoria[$8001+(f*2)]+((memoria[$8801+(f*2)] and $80) shl 1);
    if main_screen.flip_main_screen then begin
      y:=memoria[$8800+(f*2)];
      if x>272 then x:=272 else x:=272-x;
      flipx:=(atrib and 1)=0;
      flipy:=(atrib and 2)=0;
    end else begin
      y:=241-memoria[$8800+(f*2)];
      flipx:=(atrib and 1)<>0;
      flipy:=(atrib and 2)<>0;
    end;
    put_gfx_sprite_mask(nchar,color,flipx,flipy,1,0,$f);
    actualiza_gfx_sprite(x,y-1,4,1);
end;
end;

procedure update_video_jungler;
var
  f,nchar,y:byte;
  x:word;
begin
update_bg;
actualiza_trozo(0,0,256,256,1,0,0,256,256,4);
//Sprites
draw_sprites;
//Disparos
for f:=$14 to $20 do begin
    nchar:=(memoria[$a000+f] and 7) xor 7;
    x:=284-(memoria[$8020+f]+((memoria[$a000+f] xor $ff) and 8) shl 5);
    if x>288 then x:=x and $ff;
    if main_screen.flip_main_screen then y:=memoria[$8820+f]
      else y:=241-memoria[$8820+f];
    put_gfx_sprite(nchar,16,false,false,2);
    actualiza_gfx_sprite(x,y-1,4,2);
end;
update_fg;
actualiza_trozo(32,0,32,256,2,224,0,32,256,4);
actualiza_trozo(0,0,32,256,2,256,0,32,256,4);
actualiza_trozo_final(0,16,288,224,4);
end;

procedure update_video_rallyx;
var
  f,nchar,y,atrib:byte;
  x:word;
begin
update_bg;
scroll_x_y(1,4,scroll_x-3,scroll_y);
//Sprites
draw_sprites;
scroll_x_y(3,4,scroll_x-3,scroll_y);
update_fg;
actualiza_trozo(32,0,32,256,2,224,0,32,256,4);
actualiza_trozo(0,0,32,256,2,256,0,32,256,4);
//Radar
for f:=0 to $b do begin
    y:=237-memoria[$8834+f];
    atrib:=memoria[$a004+f];
    nchar:=((atrib and $e) shr 1) xor 7;
    x:=memoria[$8034+f]+((not(atrib) and 8) shl 5);
    if x<32 then x:=x+256;
    put_gfx_sprite(nchar,16,false,false,2);
    actualiza_gfx_sprite(x,y+15,4,2);
end;
actualiza_trozo_final(0,16,288,224,4);
end;

procedure eventos_jungler;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[1] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  //P2
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
  //DSW
  if arcade_input.down[0] then marcade.in2:=(marcade.in2 and $7f) else marcade.in2:=(marcade.in2 or $80);
end;
end;

procedure eventos_rallyx;
begin
if event.arcade then begin
  //P1
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  //P2
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or 8);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  if arcade_input.coin[1] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
end;
end;

procedure jungler_principal;
var
  f:byte;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
  for f:=0 to $ff do begin
      if f=240 then begin
        if hacer_int then z80_0.change_nmi(PULSE_LINE);
        update_video_jungler;
      end;
      //Main CPU
      z80_0.run(frame_main);
      frame_main:=frame_main+z80_0.tframes-z80_0.contador;
      //Sound
      konamisnd_0.run;
  end;
  eventos_jungler;
  video_sync;
end;
end;

procedure rallyx_principal;
var
  f:byte;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
  for f:=0 to $ff do begin
      if f=240 then begin
        if hacer_int then z80_0.change_irq(ASSERT_LINE);
        update_video_rallyx;
      end;
      z80_0.run(frame_main);
      frame_main:=frame_main+z80_0.tframes-z80_0.contador;
  end;
  eventos_rallyx;
  video_sync;
end;
end;

function jungler_getbyte(direccion:word):byte;
begin
case direccion of
  0..$8fff,$9800..$9fff:jungler_getbyte:=memoria[direccion];
  $a000:jungler_getbyte:=marcade.in0;
  $a080:jungler_getbyte:=marcade.in1;
  $a100:jungler_getbyte:=marcade.in2;
  $a180:jungler_getbyte:=marcade.dswa;
end;
end;

procedure jungler_putbyte(direccion:word;valor:byte);
begin
case direccion of
    0..$7fff:; //ROM
    $8000..$83ff,$8800..$8bff:if memoria[direccion]<>valor then begin
                  gfx[2].buffer[direccion and $3ff]:=true;
                  memoria[direccion]:=valor;
               end;
    $8400..$87ff,$8c00..$8fff:if memoria[direccion]<>valor then begin
                  gfx[0].buffer[direccion and $3ff]:=true;
                  memoria[direccion]:=valor;
               end;
    $9800..$9fff:memoria[direccion]:=valor;
    $a000..$a07f:memoria[$a000+(direccion and $f)]:=valor;
    $a100:konamisnd_0.sound_latch:=valor;
    $a130:scroll_x:=valor;
    $a140:scroll_y:=valor;
    $a180..$a187:begin
                    valor:=valor and 1;
                    case (direccion and 7) of
                       0:begin
                            if ((last=0) and (valor<>0)) then konamisnd_0.pedir_irq:=HOLD_LINE;
                            last:=valor;
                         end;
                       1:hacer_int:=(valor<>0);
                       2:konamisnd_0.enabled:=(valor=0);
                       3:main_screen.flip_main_screen:=(valor<>0);
                       7:;//stars_ena:=(valor<>0);
                    end;
                 end;
end;
end;

//Rally X
function rallyx_getbyte(direccion:word):byte;
begin
case direccion of
  0..$3fff,$8000..$8fff,$9800..$9fff:rallyx_getbyte:=memoria[direccion];
  $a000:rallyx_getbyte:=marcade.in0;
  $a080:rallyx_getbyte:=marcade.in1 or marcade.dswa;
  $a100:rallyx_getbyte:=marcade.dswb;
end;
end;

procedure rallyx_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$3fff:; //ROM
  $8000..$83ff,$8800..$8bff:if memoria[direccion]<>valor then begin
                  gfx[2].buffer[direccion and $3ff]:=true;
                  memoria[direccion]:=valor;
               end;
    $8400..$87ff,$8c00..$8fff:if memoria[direccion]<>valor then begin
                  gfx[0].buffer[direccion and $3ff]:=true;
                  memoria[direccion]:=valor;
               end;
  $9800..$9fff,$a000..$a00f:memoria[direccion]:=valor;
  $a100..$a11f:namco_snd_0.regs[direccion and $1f]:=valor;
  $a130:scroll_x:=valor;
  $a140:scroll_y:=valor;
  $a180..$a187:begin
                  valor:=valor and 1;
                  case (direccion and 7) of
                    0:begin //Explosion
                         if ((valor=0) and (last<>0)) then start_sample(0);
                         last:=valor;
                      end;
                    1:begin
                          hacer_int:=(valor<>0);
                          if not(hacer_int) then z80_0.change_irq(CLEAR_LINE);
                      end;
                    2:namco_snd_0.enabled:=(valor<>0);
                    3:main_screen.flip_main_screen:=(valor<>0);
                  end;
               end;
  end;
end;

procedure rallyx_outbyte(puerto:word;valor:byte);
begin
if (puerto and $ff)=0 then begin
  z80_0.im0:=valor;
  z80_0.change_irq(CLEAR_LINE);
end;
end;

procedure rallyx_playsound;
begin
  samples_update;
  namco_snd_0.update;
end;

//Main
procedure reset_rallyxh;
begin
 z80_0.reset;
 frame_main:=z80_0.tframes;
 marcade.in0:=$ff;
 case main_vars.tipo_maquina of
  29:begin
        marcade.in1:=$ff;
        marcade.in2:=$ff;
        konamisnd_0.reset;
  end;
  50,70:begin
        marcade.in1:=$fe;
        namco_snd_0.reset;
        reset_samples;
  end;
 end;
 reset_audio;
 last:=0;
 hacer_int:=false;
 scroll_x:=0;
 scroll_y:=0;
end;

function iniciar_rallyxh:boolean;
var
   colores:tpaleta;
   f:word;
   ctemp1:byte;
   memoria_temp:array[0..$3fff] of byte;
const
   ps_rx:array[0..15] of dword=(8*8+0, 8*8+1, 8*8+2, 8*8+3, 16*8+0, 16*8+1, 16*8+2, 16*8+3,
 			 24*8+0, 24*8+1, 24*8+2, 24*8+3, 0, 1, 2, 3);
   ps_x:array[0..15] of dword=(8*8, 8*8+1, 8*8+2, 8*8+3, 0, 1, 2, 3,
 			24*8+0, 24*8+1, 24*8+2, 24*8+3, 16*8+0, 16*8+1, 16*8+2, 16*8+3);
   ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
 			32*8, 33*8, 34*8, 35*8, 36*8, 37*8, 38*8, 39*8);
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
 convert_gfx(0,0,@memoria_temp,@ps_x,@ps_y,false,false);
end;

procedure cargar_sprites(tipo:byte);
begin
 init_gfx(1,16,16,64);
 gfx[1].trans[0]:=true;
 if tipo=1 then begin
   gfx_set_desc_data(2,0,64*8,4,0);
   convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,false);
 end else begin
   gfx_set_desc_data(2,0,64*8,0,4);
   convert_gfx(1,0,@memoria_temp,@ps_rx,@ps_y,false,false);
 end;
end;

procedure cargar_disparo;
begin
 init_gfx(2,4,4,8);
 gfx[2].trans[3]:=true;
 gfx_set_desc_data(2,0,16*8,6,7);
 convert_gfx(2,0,@memoria_temp,@ps_y,@pd_y,false,false)
end;

begin
 case main_vars.tipo_maquina of
   29:llamadas_maquina.bucle_general:=jungler_principal;
   50,70:begin
           llamadas_maquina.bucle_general:=rallyx_principal;
           llamadas_maquina.fps_max:=60.606060606060;
         end;
 end;
 llamadas_maquina.reset:=reset_rallyxh;
 iniciar_rallyxh:=false;
 iniciar_audio(false);
 if main_vars.tipo_maquina=29 then main_screen.rot90_screen:=true;
 screen_init(1,256,256);
 screen_mod_scroll(1,256,256,255,256,256,255);
 screen_init(2,64,256);
 screen_init(3,256,256,true);
 screen_mod_scroll(3,256,256,255,256,256,255);
 screen_init(4,512,512,false,true);
 iniciar_video(288,224);
 //Main CPU
 z80_0:=cpu_z80.create(3072000,$100);
 case main_vars.tipo_maquina of
   29:begin //jungler
         z80_0.change_ram_calls(jungler_getbyte,jungler_putbyte);
         //Sound Chip
         konamisnd_0:=konamisnd_chip.create(1,TIPO_JUNGLER,1789772,$100);
         if not(roms_load(@konamisnd_0.memoria,jungler_sound)) then exit;
         //cargar roms
         if not(roms_load(@memoria,jungler_rom)) then exit;
         //convertir chars
         if not(roms_load(@memoria_temp,jungler_char)) then exit;
         cargar_chars(1);
         //convertir sprites
         cargar_sprites(1);
         //Y ahora el'disparo'
         if not(roms_load(@memoria_temp,jungler_dots)) then exit;
         cargar_disparo;
         //poner la paleta
         if not(roms_load(@memoria_temp,jungler_pal)) then exit;
         //DIP
         marcade.dswa:=$bf;
         marcade.dswa_val2:=@jungler_dip;
   end;
   50:begin //rallyx
         z80_0.change_ram_calls(rallyx_getbyte,rallyx_putbyte);
         z80_0.change_io_calls(nil,rallyx_outbyte);
         z80_0.init_sound(rallyx_playsound);
         //cargar roms
         if not(roms_load(@memoria,rallyx_rom)) then exit;
         //cargar sonido y samples
         namco_snd_0:=namco_snd_chip.create(3);
         if not(roms_load(namco_snd_0.get_wave_dir,rallyx_sound)) then exit;
         load_samples(rallyx_samples);
         //convertir chars
         if not(roms_load(@memoria_temp,rallyx_char)) then exit;
         cargar_chars(0);
         //convertir sprites
         cargar_sprites(0);
         //Y ahora el'disparo'
         if not(roms_load(@memoria_temp,rallyx_dots)) then exit;
         cargar_disparo;
         //poner la paleta
         if not(roms_load(@memoria_temp,rallyx_pal)) then exit;
         marcade.dswa:=1;
         marcade.dswb:=$cb;
         marcade.dswa_val2:=@rallyx_dip_a;
         marcade.dswb_val2:=@rallyx_dip_b;
      end;
   70:begin  //new rally x
         z80_0.change_ram_calls(rallyx_getbyte,rallyx_putbyte);
         z80_0.change_io_calls(nil,rallyx_outbyte);
         z80_0.init_sound(rallyx_playsound);
         //cargar roms y ordenarlas
         if not(roms_load(@memoria_temp,nrallyx_rom)) then exit;
         copymemory(@memoria[0],@memoria_temp[0],$800);
         copymemory(@memoria[$1000],@memoria_temp[$800],$800);
         copymemory(@memoria[$800],@memoria_temp[$1000],$800);
         copymemory(@memoria[$1800],@memoria_temp[$1800],$800);
         copymemory(@memoria[$2000],@memoria_temp[$2000],$800);
         copymemory(@memoria[$3000],@memoria_temp[$2800],$800);
         copymemory(@memoria[$2800],@memoria_temp[$3000],$800);
         copymemory(@memoria[$3800],@memoria_temp[$3800],$800);
         //cargar sonido y samples
         namco_snd_0:=namco_snd_chip.create(3);
         if not(roms_load(namco_snd_0.get_wave_dir,nrallyx_sound)) then exit;
         load_samples(rallyx_samples,1,'rallyx.zip');
         //convertir chars
         if not(roms_load(@memoria_temp,nrallyx_char)) then exit;
         cargar_chars(0);
         //convertir sprites
         cargar_sprites(0);
         //Y ahora el'disparo'
         if not(roms_load(@memoria_temp,nrallyx_dots)) then exit;
         cargar_disparo;
         //poner la paleta
         if not(roms_load(@memoria_temp,nrallyx_pal)) then exit;
         marcade.dswa:=1;
         marcade.dswb:=$c3;
         marcade.dswa_val2:=@rallyx_dip_a;
         marcade.dswb_val2:=@nrallyx_dip_b;
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
