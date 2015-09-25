unit mappy_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6809,main_engine,controls_engine,gfx_engine,namco_snd,namcoio_56xx_58xx,
     timer_engine,rom_engine,pal_engine,sound_engine;

type
  tipo_update_video=procedure;

//General
procedure Cargar_mappyhw;
function iniciar_mappyhw:boolean; 
procedure reset_mappyhw;
procedure cerrar_mappyhw; 
procedure mappy_principal; 
//Mappy & DigDug2
function mappy_getbyte(direccion:word):byte;  
procedure mappy_putbyte(direccion:word;valor:byte); 
function sound_getbyte(direccion:word):byte;  
procedure sound_putbyte(direccion:word;valor:byte); 
//Super Pacman
procedure spacman_putbyte(direccion:word;valor:byte); 
//IO Chips
function inport0_0:byte; 
function inport0_1:byte; 
function inport0_2:byte; 
function inport0_3:byte; 
function inport1_0:byte; 
function inport1_1:byte; 
function inport1_2:byte; 
function inport1_3:byte; 
procedure outport1_0(data:byte);
procedure mappy_io0;
procedure mappy_io1;

implementation
const
        //Mappy
        mappy_rom:array[0..3] of tipo_roms=(
        (n:'mpx_3.1d';l:$2000;p:$a000;crc:$52e6c708),(n:'mp1_2.1c';l:$2000;p:$c000;crc:$a958a61c),
        (n:'mpx_1.1b';l:$2000;p:$e000;crc:$203766d4),());
        mappy_proms:array[0..3] of tipo_roms=(
        (n:'mp1-5.5b';l:$20;p:0;crc:$56531268),(n:'mp1-6.4c';l:$100;p:$20;crc:$50765082),
        (n:'mp1-7.5k';l:$100;p:$120;crc:$5396bd78),());
        mappy_chars:tipo_roms=(n:'mp1_5.3b';l:$1000;p:0;crc:$16498b9f);
        mappy_sprites:array[0..2] of tipo_roms=(
        (n:'mp1_6.3m';l:$2000;p:0;crc:$f2d9647a),(n:'mp1_7.3n';l:$2000;p:$2000;crc:$757cf2b6),());
        mappy_sound:tipo_roms=(n:'mp1_4.1k';l:$2000;p:$e000;crc:$8182dd5b);
        mappy_sound_prom:tipo_roms=(n:'mp1-3.3m';l:$100;p:0;crc:$16a9166a);
        //Dig Dug 2
        dd2_rom:array[0..2] of tipo_roms=(
        (n:'d23_3.1d';l:$4000;p:$8000;crc:$cc155338),(n:'d23_1.1b';l:$4000;p:$c000;crc:$40e46af8),());
        dd2_proms:array[0..3] of tipo_roms=(
        (n:'d21-5.5b';l:$20;p:0;crc:$9b169db5),(n:'d21-6.4c';l:$100;p:$20;crc:$55a88695),
        (n:'d21-7.5k';l:$100;p:$120;crc:$9c55feda),());
        dd2_chars:tipo_roms=(n:'d21_5.3b';l:$1000;p:0;crc:$afcb4509);
        dd2_sprites:array[0..2] of tipo_roms=(
        (n:'d21_6.3m';l:$4000;p:0;crc:$df1f4ad8),(n:'d21_7.3n';l:$4000;p:$4000;crc:$ccadb3ea),());
        dd2_sound:tipo_roms=(n:'d21_4.1k';l:$2000;p:$e000;crc:$737443b1);
        dd2_sound_prom:tipo_roms=(n:'d21-3.3m';l:$100;p:0;crc:$e0074ee2);
        //Super Pacman
        spacman_rom:array[0..2] of tipo_roms=(
        (n:'sp1-2.1c';l:$2000;p:$c000;crc:$4bb33d9c),(n:'sp1-1.1b';l:$2000;p:$e000;crc:$846fbb4a),());
        spacman_proms:array[0..3] of tipo_roms=(
        (n:'superpac.4c';l:$20;p:0;crc:$9ce22c46),(n:'superpac.4e';l:$100;p:$20;crc:$1253c5c1),
        (n:'superpac.3l';l:$100;p:$120;crc:$d4d7026f),());
        spacman_chars:tipo_roms=(n:'sp1-6.3c';l:$1000;p:0;crc:$91c5935c);
        spacman_sprites:tipo_roms=(n:'spv-2.3f';l:$2000;p:0;crc:$670a42f2);
        spacman_sound:tipo_roms=(n:'spc-3.1k';l:$1000;p:$f000;crc:$04445ddb);
        spacman_sound_prom:tipo_roms=(n:'superpac.3m';l:$100;p:0;crc:$ad43688f);
        //The Tower of Druaga
        todruaga_rom:array[0..2] of tipo_roms=(
        (n:'td2_3.1d';l:$4000;p:$8000;crc:$fbf16299),(n:'td2_1.1b';l:$4000;p:$c000;crc:$b238d723),());
        todruaga_proms:array[0..3] of tipo_roms=(
        (n:'td1-5.5b';l:$20;p:0;crc:$122cc395),(n:'td1-6.4c';l:$100;p:$20;crc:$8c661d6a),
        (n:'td1-7.5k';l:$400;p:$120;crc:$a86c74dd),());
        todruaga_chars:tipo_roms=(n:'td1_5.3b';l:$1000;p:0;crc:$d32b249f);
        todruaga_sprites:array[0..2] of tipo_roms=(
        (n:'td1_6.3m';l:$2000;p:0;crc:$e827e787),(n:'td1_7.3n';l:$2000;p:$2000;crc:$962bd060),());
        todruaga_sound:tipo_roms=(n:'td1_4.1k';l:$2000;p:$e000;crc:$ae9d06d9);
        todruaga_sound_prom:tipo_roms=(n:'td1-3.3m';l:$100;p:0;crc:$07104c40);
        //Motos
        motos_rom:array[0..2] of tipo_roms=(
        (n:'mo1_3.1d';l:$4000;p:$8000;crc:$1104abb2),(n:'mo1_1.1b';l:$4000;p:$c000;crc:$57b157e2),());
        motos_proms:array[0..3] of tipo_roms=(
        (n:'mo1-5.5b';l:$20;p:0;crc:$71972383),(n:'mo1-6.4c';l:$100;p:$20;crc:$730ba7fb),
        (n:'mo1-7.5k';l:$100;p:$120;crc:$7721275d),());
        motos_chars:tipo_roms=(n:'mo1_5.3b';l:$1000;p:0;crc:$5d4a2a22);
        motos_sprites:array[0..2] of tipo_roms=(
        (n:'mo1_6.3m';l:$4000;p:0;crc:$2f0e396e),(n:'mo1_7.3n';l:$4000;p:$4000;crc:$cf8a3b86),());
        motos_sound:tipo_roms=(n:'mo1_4.1k';l:$2000;p:$e000;crc:$55e45d21);
        motos_sound_prom:tipo_roms=(n:'mo1-3.3m';l:$100;p:0;crc:$2accdfb4);

var
 snd_int,main_int:boolean;
 scroll_x,mux,io_timer0,io_timer1:byte;
 update_video_proc:tipo_update_video;

procedure Cargar_mappyhw;
begin
llamadas_maquina.bucle_general:=mappy_principal;
llamadas_maquina.iniciar:=iniciar_mappyhw;
llamadas_maquina.cerrar:=cerrar_mappyhw;
llamadas_maquina.reset:=reset_mappyhw;
llamadas_maquina.fps_max:=60.6060606060;
end;

procedure draw_sprites_mappy;inline;
var
  nchar,color,y:word;
  flipx,flipy:boolean;
  flipx_v,flipy_v,x,f,atrib,size,a,b,c,d,mix:byte;
begin
for f:=0 to $3f do begin
  if (memoria[$2781+(f*2)] and $2)=0 then begin
    atrib:=memoria[$2780+(f*2)];
    nchar:=memoria[$1780+(f*2)];
    color:=memoria[$1781+(f*2)] shl 4;
    x:=memoria[$1f80+(f*2)]+1;
    y:=memoria[$1f81+(f*2)]+$100*(memoria[$2781+(f*2)] and 1)-40;
    flipx_v:=atrib and $02;
    flipy_v:=atrib and $01;
    flipx:=flipx_v<>0;
    flipy:=flipy_v<>0;
    size:=((atrib and $c) shr 2);
    case size of
      0:begin  //16x16
            put_gfx_sprite_mask(nchar,color,flipx,flipy,1,$f,$f);
            actualiza_gfx_sprite(x-17,y,5,1);
        end;
      1:begin //16x32
            nchar:=nchar and $fe;
            a:=0 xor flipy_v;
            b:=1 xor flipy_v;
            put_gfx_sprite_mask_diff(nchar+a,color,flipx,false,1,$f,$f,0,0);
            put_gfx_sprite_mask_diff(nchar+b,color,flipx,false,1,$f,$f,0,16);
            actualiza_gfx_sprite_size(x-17,y,5,16,32);
        end;
      2:begin //32x16
            nchar:=nchar and $fd;
            a:=2 xor flipx_v;
            b:=0 xor flipx_v;
            put_gfx_sprite_mask_diff(nchar+a,color,flipx,flipy,1,15,$f,0,0);
            put_gfx_sprite_mask_diff(nchar+b,color,flipx,flipy,1,15,$f,16,0);
            actualiza_gfx_sprite_size(x-17,y,5,32,16);
        end;
      3:begin //32x32
            nchar:=nchar and $fc;
            if flipx then begin
              a:=0;b:=2;c:=1;d:=3
            end else begin
              a:=2;b:=0;c:=3;d:=1;
            end;
            if flipy then begin
              mix:=a;a:=c;c:=mix;
              mix:=b;b:=d;d:=mix;
            end;
            put_gfx_sprite_mask_diff(nchar+a,color,flipx,flipy,1,15,$f,0,0);
            put_gfx_sprite_mask_diff(nchar+b,color,flipx,flipy,1,15,$f,16,0);
            put_gfx_sprite_mask_diff(nchar+c,color,flipx,flipy,1,15,$f,0,16);
            put_gfx_sprite_mask_diff(nchar+d,color,flipx,flipy,1,15,$f,16,16);
            actualiza_gfx_sprite_size(x-17,y,5,32,32);
         end;
      end;
    end;
  end;
end;

procedure scroll_mappy(porigen,pdestino:byte;scroll_x:word);inline;
var
  long_x:word;
begin
scroll_x:=scroll_x and $1ff;
if ((scroll_x+256)>=480) then long_x:=256-((scroll_x+256)-480)
  else long_x:=256;
actualiza_trozo(scroll_x,0,long_x,256,porigen,0,16,long_x,256,pdestino);
if long_x<480 then actualiza_trozo(0,0,480-long_x,256,porigen,long_x,16,480-long_x,256,pdestino);
end;

procedure update_video_mappy;
const
  linea_y:array[0..$1f] of byte=($11,$10,$1f,$1e,$1d,$1c,$1b,$1a,$19,$18,$17,$16,$15,$14,$13,$12,1,0,$f,$e,$d,$c,$b,$a,9,8,7,6,5,4,3,2);
var
  x,y,f,color:word;
  atrib,nchar:byte;
begin
for f:=$7ff downto 0 do begin
    if gfx[0].buffer[f] then begin
      nchar:=memoria[$0+f];
      atrib:=memoria[$800+f];
      color:=(atrib and $3f) shl 2;
      case f of
        0..$77f:begin
          				x:=59-(f div 32);
          				y:=f mod 32;
                  put_gfx(x*8,y*8,nchar,color,2,0);
                  if (atrib and $40)=0 then put_gfx_block_trans(x*8,y*8,3,8,8)
                    else put_gfx_mask(x*8,y*8,nchar,color,3,0,$1f,$3f);
                end;
        $780..$7bf:begin
                      //lineas de abajo
                			x:=f and $1f;
              				y:=(f and $3f) shr 5;
                      put_gfx(linea_y[x]*8,(y+2)*8,nchar,color,1,0);
                      if (atrib and $40)=0 then put_gfx_block_trans(linea_y[x]*8,(y+2)*8,4,8,8)
                        else put_gfx_mask(linea_y[x]*8,(y+2)*8,nchar,color,4,0,$1f,$3f);
                    end;
        $7c0..$7ff:begin
                      //lineas de arriba
                			x:=f and $1f;
              				y:=(f and $3f) shr 5;
                      put_gfx(linea_y[x]*8,y*8,nchar,color,1,0);
                      if (atrib and $40)=0 then put_gfx_block_trans(linea_y[x]*8,y*8,4,8,8)
                        else put_gfx_mask(linea_y[x]*8,y*8,nchar,color,4,0,$1f,$3f);
                    end;
      end;
      gfx[0].buffer[f]:=false;
    end;
end;
//Las lineas de arriba y abajo fijas...
actualiza_trozo(32,0,224,16,1,0,0,224,16,5);
actualiza_trozo(32,16,223,16,1,1,272,223,16,5);
//Pantalla principal
scroll_mappy(2,5,scroll_x);
//Los sprites
draw_sprites_mappy;
//Las lineas de arriba y abajo fijas transparentes...
actualiza_trozo(32,0,224,16,4,0,0,224,16,5);
actualiza_trozo(32,16,223,16,4,1,272,223,16,5);
//Pantalla principal transparente
scroll_mappy(3,5,scroll_x);
//final, lo pego todooooo
actualiza_trozo_final(0,0,224,288,5);
end;

procedure draw_sprites_spacman;inline;
var
  nchar,color,y:word;
  flipx,flipy:boolean;
  flipx_v,flipy_v,x,f,size,a,b,c,d,mix,atrib:byte;
begin
for f:=0 to $3f do begin
  if (memoria[$1f81+(f*2)] and $2)=0 then begin
    atrib:=memoria[$1f80+(f*2)];
    y:=memoria[$1781+(f*2)]+$100*(memoria[$1f81+(f*2)] and 1)-40;
    nchar:=memoria[$f80+(f*2)] and $7f;
    color:=memoria[$f81+(f*2)] shl 2;
    x:=memoria[$1780+(f*2)]-17;
    flipx_v:=atrib and $02;
    flipy_v:=atrib and $01;
    flipx:=flipx_v<>0;
    flipy:=flipy_v<>0;
    size:=(atrib and $c) shr 2;
    case size of
      0:begin  //16x16
            put_gfx_sprite_mask(nchar,color,flipx,flipy,1,$f,$f);
            actualiza_gfx_sprite(x,y,5,1);
        end;
      1:begin //16x32
            nchar:=nchar and $fe;
            a:=0 xor flipy_v;
            b:=1 xor flipy_v;
            put_gfx_sprite_mask_diff(nchar+a,color,flipx,flipy,1,15,$f,0,0);
            put_gfx_sprite_mask_diff(nchar+b,color,flipx,flipy,1,15,$f,0,16);
            actualiza_gfx_sprite_size(x,y,5,16,32);
        end;
      2:begin //32x16
            nchar:=nchar and $fd;
            a:=2 xor flipx_v;
            b:=0 xor flipx_v;
            put_gfx_sprite_mask_diff(nchar+a,color,flipx,flipy,1,15,$f,0,0);
            put_gfx_sprite_mask_diff(nchar+b,color,flipx,flipy,1,15,$f,16,0);
            actualiza_gfx_sprite_size(x,y,5,32,16);
        end;
      3:begin //32x32
            nchar:=nchar and $fc;
            if flipx then begin
              a:=0;b:=2;c:=1;d:=3
            end else begin
              a:=2;b:=0;c:=3;d:=1;
            end;
            if flipy then begin
              mix:=a;a:=c;c:=mix;
              mix:=b;b:=d;d:=mix;
            end;
            put_gfx_sprite_mask_diff(nchar+a,color,flipx,flipy,1,15,$f,0,0);
            put_gfx_sprite_mask_diff(nchar+b,color,flipx,flipy,1,15,$f,16,0);
            put_gfx_sprite_mask_diff(nchar+c,color,flipx,flipy,1,15,$f,0,16);
            put_gfx_sprite_mask_diff(nchar+d,color,flipx,flipy,1,15,$f,16,16);
            actualiza_gfx_sprite_size(x,y,5,32,32);
         end;
      end;
    end;
  end;
end;

procedure update_video_spacman;
var
  x,y,f,color:word;
  atrib,nchar:byte;
begin
for f:=$3ff downto 0 do begin
    if gfx[0].buffer[f] then begin
      nchar:=memoria[$0+f];
      atrib:=memoria[$400+f];
      color:=(atrib and $3f) shl 2;
      case f of
        $40..$3bf:begin
          				x:=31-(f div 32);
          				y:=f mod 32;
                  put_gfx(x*8,y*8,nchar,color,2,0);
                  if (atrib and $40)=0 then put_gfx_block_trans(x*8,y*8,3,8,8)
                    else put_gfx_mask(x*8,y*8,nchar,color,3,0,$1f,$1f);
                end;
        $0..$3f:begin
                      //lineas de abajo
                			x:=31-(f and $1f);
              				y:=(f and $3f) shr 5;
                      put_gfx(x*8,(y+2)*8,nchar,color,1,0);
                      if (atrib and $40)=0 then put_gfx_block_trans(x*8,(y+2)*8,4,8,8)
                        else put_gfx_mask(x*8,(y+2)*8,nchar,color,4,0,$1f,$1f);
                    end;
        $3c0..$3ff:begin
                      //lineas de arriba
                			x:=31-(f and $1f);
              				y:=(f and $3f) shr 5;
                      put_gfx(x*8,y*8,nchar,color,1,0);
                      if (atrib and $40)=0 then put_gfx_block_trans(x*8,y*8,4,8,8)
                        else put_gfx_mask(x*8,y*8,nchar,color,4,0,$1f,$1f);
                    end;
      end;
     gfx[0].buffer[f]:=false;
    end;
end;
//Lineas de arriba
actualiza_trozo(16,0,224,16,1,0,0,224,16,5);
actualiza_trozo(16,16,224,16,1,0,272,224,16,5);
//Pantalla principal
actualiza_trozo(16,0,224,256,2,0,16,224,256,5);
//Los sprites
draw_sprites_spacman;
//Las lineas de arriba y abajo fijas transparentes...
actualiza_trozo(16,0,224,16,4,0,0,224,16,5);
actualiza_trozo(16,16,224,16,4,0,272,224,16,5);
//Pantalla principal transparente
actualiza_trozo(16,0,224,256,3,0,16,224,256,5);
//final, lo pego todooooo
actualiza_trozo_final(0,0,224,288,5);
end;

function iniciar_mappyhw:boolean;
const
    pc_x:array[0..7] of dword=(8*8+0, 8*8+1, 8*8+2, 8*8+3, 0, 1, 2, 3);
    pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
    ps_x:array[0..15] of dword=(0, 1, 2, 3, 8*8, 8*8+1, 8*8+2, 8*8+3, 16*8+0, 16*8+1, 16*8+2, 16*8+3,
                          			24*8+0, 24*8+1, 24*8+2, 24*8+3);
    ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
                          			32*8, 33*8, 34*8, 35*8, 36*8, 37*8, 38*8, 39*8 );
var
  memoria_temp:array[0..$ffff] of byte;
procedure set_chars(inv:boolean);
var
  f:word;
begin
  if inv then for f:=0 to $fff do memoria_temp[f]:=not(memoria_temp[f]);
  init_gfx(0,8,8,$100);
  gfx_set_desc_data(2,0,16*8,0,4);
  convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],true,false);
end;

procedure set_sprites(num,tipo:byte);
begin
  init_gfx(1,16,16,$80*num);
  case tipo of
    0:gfx_set_desc_data(4,0,64*8,0,4,8192*8*num,(8192*8*num)+4);
    1:gfx_set_desc_data(2,0,64*8,0,4);
  end;
  convert_gfx(1,0,@memoria_temp[0],@ps_x[0],@ps_y[0],true,false);
end;

procedure set_color_lookup(tipo:byte;long_sprites:word);
var
  f:word;
  colores:tpaleta;
  ctemp1:byte;
begin
  for f:=0 to 31 do begin
    ctemp1:=memoria_temp[f];
    colores[f].r:= $21*(ctemp1 and 1)+$47*((ctemp1 shr 1) and 1)+$97*((ctemp1 shr 2) and 1);
    colores[f].g:= $21*((ctemp1 shr 3) and 1)+$47*((ctemp1 shr 4) and 1)+$97*((ctemp1 shr 5) and 1);
    colores[f].b:= 0+$47*((ctemp1 shr 6) and 1)+$97*((ctemp1 shr 7) and 1);
  end;
  set_pal(colores,32);
  case tipo of
    0:for f:=0 to 255 do gfx[0].colores[f]:=(memoria_temp[f+$20] and $0f)+$10;
    1:for f:=0 to 255 do gfx[0].colores[f]:=((memoria_temp[f+$20] and $0f) xor $f)+$10;
  end;
  for f:=0 to (long_sprites-1) do gfx[1].colores[f]:=(memoria_temp[f+$120] and $0f);
end;
begin
iniciar_mappyhw:=false;
iniciar_audio(false);
//Pantallas
screen_init(1,256,32);
screen_init(2,480,288);
screen_init(3,480,288,true);
screen_init(4,256,32,true);
screen_init(5,512,512,false,true);
iniciar_video(224,288);
//Main CPU
main_m6809:=cpu_m6809.Create(1536000,264);
//Sound CPU
snd_m6809:=cpu_m6809.Create(1536000,264);
snd_m6809.change_ram_calls(sound_getbyte,sound_putbyte);
namco_sound_init(8,false);
//IO Chips
io_timer0:=init_timer(main_m6809.numero_cpu,77,mappy_io0,false);
io_timer1:=init_timer(main_m6809.numero_cpu,77,mappy_io1,false);
namco_chip[0].in_f[0]:=inport0_0;
namco_chip[0].in_f[1]:=inport0_1;
namco_chip[0].in_f[2]:=inport0_2;
namco_chip[0].in_f[3]:=inport0_3;
namco_chip[0].out_f[0]:=nil;
namco_chip[0].out_f[1]:=nil;
namco_chip[1].in_f[0]:=inport1_0;
namco_chip[1].in_f[1]:=inport1_1;
namco_chip[1].in_f[2]:=inport1_2;
namco_chip[1].in_f[3]:=inport1_3;
namco_chip[1].out_f[0]:=outport1_0;
namco_chip[1].out_f[1]:=nil;
case  main_vars.tipo_maquina of
  57:begin //Mappy
      main_m6809.change_ram_calls(mappy_getbyte,mappy_putbyte);
      update_video_proc:=update_video_mappy;
      //IO Chips
      namco_chip[0].tipo:=namco_58xx;
      namco_chip[1].tipo:=namco_58xx;
      //cargar roms
      if not(cargar_roms(@memoria[0],@mappy_rom[0],'mappy.zip',0)) then exit;
      //Cargar Sound+samples
      if not(cargar_roms(@mem_snd[0],@mappy_sound,'mappy.zip')) then exit;
      if not(cargar_roms(@namco_sound.onda_namco[0],@mappy_sound_prom,'mappy.zip')) then exit;
      //convertir chars
      if not(cargar_roms(@memoria_temp[0],@mappy_chars,'mappy.zip')) then exit;
      set_chars(true);
      //Sprites
      if not(cargar_roms(@memoria_temp[0],@mappy_sprites[0],'mappy.zip',0)) then exit;
      set_sprites(1,0);
      //Color lookup
      if not(cargar_roms(@memoria_temp[0],@mappy_proms[0],'mappy.zip',0)) then exit;
      set_color_lookup(0,$100);
  end;
  63:begin //Dig-Dug 2
      main_m6809.change_ram_calls(mappy_getbyte,mappy_putbyte);
      update_video_proc:=update_video_mappy;
      //IO Chips
      namco_chip[0].tipo:=namco_58xx;
      namco_chip[1].tipo:=namco_56xx;
      //cargar roms
      if not(cargar_roms(@memoria[0],@dd2_rom[0],'digdug2.zip',0)) then exit;
      //Cargar Sound+samples
      if not(cargar_roms(@mem_snd[0],@dd2_sound,'digdug2.zip',1)) then exit;
      if not(cargar_roms(@namco_sound.onda_namco[0],@dd2_sound_prom,'digdug2.zip',1)) then exit;
      //convertir chars
      if not(cargar_roms(@memoria_temp[0],@dd2_chars,'digdug2.zip',1)) then exit;
      set_chars(true);
      //Sprites
      if not(cargar_roms(@memoria_temp[0],@dd2_sprites[0],'digdug2.zip',0)) then exit;
      set_sprites(2,0);
      //Color lookup
      if not(cargar_roms(@memoria_temp[0],@dd2_proms[0],'digdug2.zip',0)) then exit;
      set_color_lookup(0,$100);
  end;
  64:begin //Super Pacman
      main_m6809.change_ram_calls(mappy_getbyte,spacman_putbyte);
      update_video_proc:=update_video_spacman;
      //IO Chips
      namco_chip[0].tipo:=namco_56xx;
      namco_chip[1].tipo:=namco_56xx;
      //cargar roms
      if not(cargar_roms(@memoria[0],@spacman_rom[0],'superpac.zip',0)) then exit;
      //Cargar Sound+samples
      if not(cargar_roms(@mem_snd[0],@spacman_sound,'superpac.zip')) then exit;
      if not(cargar_roms(@namco_sound.onda_namco[0],@spacman_sound_prom,'superpac.zip')) then exit;
      //convertir chars
      if not(cargar_roms(@memoria_temp[0],@spacman_chars,'superpac.zip')) then exit;
      set_chars(false);
      //Sprites
      if not(cargar_roms(@memoria_temp[0],@spacman_sprites,'superpac.zip')) then exit;
      set_sprites(1,1);
      //Color lookup
      if not(cargar_roms(@memoria_temp[0],@spacman_proms[0],'superpac.zip',0)) then exit;
      set_color_lookup(1,$100);
  end;
  192:begin //The Tower of Druaga
      main_m6809.change_ram_calls(mappy_getbyte,mappy_putbyte);
      update_video_proc:=update_video_mappy;
      //IO Chips
      namco_chip[0].tipo:=namco_58xx;
      namco_chip[1].tipo:=namco_56xx;
      //cargar roms
      if not(cargar_roms(@memoria[0],@todruaga_rom[0],'todruaga.zip',0)) then exit;
      //Cargar Sound+samples
      if not(cargar_roms(@mem_snd[0],@todruaga_sound,'todruaga.zip')) then exit;
      if not(cargar_roms(@namco_sound.onda_namco[0],@todruaga_sound_prom,'todruaga.zip')) then exit;
      //convertir chars
      if not(cargar_roms(@memoria_temp[0],@todruaga_chars,'todruaga.zip')) then exit;
      set_chars(true);
      //Sprites
      if not(cargar_roms(@memoria_temp[0],@todruaga_sprites[0],'todruaga.zip',0)) then exit;
      set_sprites(1,0);
      //Color lookup
      if not(cargar_roms(@memoria_temp[0],@todruaga_proms[0],'todruaga.zip',0)) then exit;
      set_color_lookup(0,$400);
  end;
  193:begin //Motos
      main_m6809.change_ram_calls(mappy_getbyte,mappy_putbyte);
      update_video_proc:=update_video_mappy;
      //IO Chips
      namco_chip[0].tipo:=namco_56xx;
      namco_chip[1].tipo:=namco_56xx;
      //cargar roms
      if not(cargar_roms(@memoria[0],@motos_rom[0],'motos.zip',0)) then exit;
      //Cargar Sound+samples
      if not(cargar_roms(@mem_snd[0],@motos_sound,'motos.zip')) then exit;
      if not(cargar_roms(@namco_sound.onda_namco[0],@motos_sound_prom,'motos.zip')) then exit;
      //convertir chars
      if not(cargar_roms(@memoria_temp[0],@motos_chars,'motos.zip')) then exit;
      set_chars(true);
      //Sprites
      if not(cargar_roms(@memoria_temp[0],@motos_sprites[0],'motos.zip',0)) then exit;
      set_sprites(2,0);
      //Color lookup
      if not(cargar_roms(@memoria_temp[0],@motos_proms[0],'motos.zip',0)) then exit;
      set_color_lookup(0,$100);
  end;
end;
reset_mappyhw;
iniciar_mappyhw:=true;
end;

procedure cerrar_mappyhw;
begin
main_m6809.Free;
snd_m6809.Free;
close_audio;
close_video;
end;

procedure reset_mappyhw; 
begin
 main_m6809.reset;
 snd_m6809.reset;
 namco_sound_reset;
 reset_audio;
 namco_io_init(0);
 namco_io_init(1);
 marcade.in0:=$f;
 marcade.in1:=$f;
 marcade.in2:=$f;
 marcade.in3:=$f;
end;

procedure eventos_mappy;
begin
if event.arcade then begin
  if arcade_input.up[0] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.right[0] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.down[0] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.left[0] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.but1[0] then marcade.in3:=(marcade.in3 and $fe) else marcade.in3:=(marcade.in3 or $1);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
end;
end;

procedure mappy_principal;
var
  f:word;
  frame_m,frame_s:single;
begin
init_controls(false,false,false,true);
frame_m:=main_m6809.tframes;
frame_s:=snd_m6809.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to 263 do begin
    //Main CPU
    main_m6809.run(frame_m);
    frame_m:=frame_m+main_m6809.tframes-main_m6809.contador;
    //Sound CPU
    snd_m6809.run(frame_s);
    frame_s:=frame_s+snd_m6809.tframes-snd_m6809.contador;
    if f=223 then begin
      if main_int then main_m6809.pedir_irq:=ASSERT_LINE;
      if snd_int then snd_m6809.pedir_irq:=ASSERT_LINE;
      update_video_proc;
    end;
  end;
  //Dar un poco de tiempo a las CPU's para hacer su trabajo con los IO's
  if namco_chip[0].reset then timer[io_timer0].enabled:=true;
  if namco_chip[1].reset then timer[io_timer1].enabled:=true;
  if sound_status.hay_sonido then begin
      namco_playsound;
      play_sonido;
  end;
  eventos_mappy;
  video_sync;
end;
end;

function mappy_getbyte(direccion:word):byte;
begin
  case direccion of
    $4800..$480f:mappy_getbyte:=namcoio_r(0,direccion and $f);
    $4810..$481f:mappy_getbyte:=namcoio_r(1,direccion and $f);
    else mappy_getbyte:=memoria[direccion];
  end;
end;

procedure mappy_latch(direccion:word);inline;
begin
case (direccion and $0e) of
  $00:begin
        snd_int:=(direccion and 1)<>0;
        if not(snd_int) then snd_m6809.pedir_irq:=CLEAR_LINE;
      end;
  $02:begin
        main_int:=(direccion and 1)<>0;
        if not(main_int) then main_m6809.pedir_irq:=CLEAR_LINE;
      end;
  $04:main_screen.flip_main_screen:=(direccion and 1)<>0;
  $06:namco_sound.enabled:=(direccion and 1)<>0;
  $08:begin
        namco_io_reset(0,(direccion and 1)<>0);
        namco_io_reset(1,(direccion and 1)<>0);
      end;
  $0a:if ((direccion and 1)<>0) then snd_m6809.pedir_reset:=CLEAR_LINE
          else snd_m6809.pedir_reset:=ASSERT_LINE;
end;
end;

procedure mappy_putbyte(direccion:word;valor:byte); 
begin
if (direccion>$7fff) then exit;
memoria[direccion]:=valor;
case direccion of
  $0..$fff:gfx[0].buffer[direccion and $7ff]:=true;
  $3800..$3fff:scroll_x:=255-((direccion and $7ff) shr 3);
  $4000..$403f:namco_sound.registros_namco[direccion and $3f]:=valor;
  $4800..$480f:namcoio_w(0,direccion and $f,valor);
  $4810..$481f:namcoio_w(1,direccion and $f,valor);
  $5000..$500f:mappy_latch(direccion and $0f);
end;
end;

function sound_getbyte(direccion:word):byte;
begin
case direccion of
  $40..$3ff:sound_getbyte:=memoria[$4000+direccion];
  else sound_getbyte:=mem_snd[direccion];
end;
end;

procedure sound_putbyte(direccion:word;valor:byte); 
begin
if direccion>$dfff then exit;
mem_snd[direccion]:=valor;
case direccion of
   $0..$3f:begin
            memoria[$4000+direccion]:=valor;
            namco_sound.registros_namco[direccion and $3f]:=valor;
           end;
   $40..$3ff:memoria[$4000+direccion]:=valor;
   $2000..$200f:mappy_latch(direccion and $0f);
end;
end;

//Super Pacman
procedure spacman_putbyte(direccion:word;valor:byte); 
begin
if (direccion>$7fff) then exit;
memoria[direccion]:=valor;
case direccion of
  $0..$7ff:gfx[0].buffer[direccion and $3ff]:=true;
  $4000..$403f:namco_sound.registros_namco[direccion and $3f]:=valor;
  $4800..$480f:namcoio_w(0,direccion and $f,valor);
  $4810..$481f:namcoio_w(1,direccion and $f,valor);
  $5000..$500f:mappy_latch(direccion and $0f);
end;
end;

//Funciones IO Chips
function inport0_0:byte;
begin
  inport0_0:=marcade.in0;  //coins
end;

function inport0_1:byte;
begin
inport0_1:=marcade.in2; //p1
end;

function inport0_2:byte;
begin
inport0_2:=$0f; //p2
end;

function inport0_3:byte;
begin
inport0_3:=marcade.in1; //buttons
end;

function inport1_0:byte;
begin
inport1_0:=$ff shr (mux*4);  //dib_mux
end;

function inport1_1:byte;
begin
inport1_1:=$f; //dip a_l
end;

function inport1_2:byte;
begin
inport1_2:=$f; //dip a_h
end;

function inport1_3:byte;
begin
inport1_3:=marcade.in3; //dsw 0
end;

procedure outport1_0(data:byte);
begin
mux:=data and $1;
end;

procedure mappy_io0;
begin
namco_io_run(0);
timer[io_timer0].enabled:=false;
end;

procedure mappy_io1;
begin
namco_io_run(1);
timer[io_timer1].enabled:=false;
end;

end.
