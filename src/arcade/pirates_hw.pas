unit pirates_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m68000,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     sound_engine,oki6295,misc_functions;

procedure Cargar_pirates;
procedure pirates_principal;
function iniciar_pirates:boolean;
procedure reset_pirates;
procedure cerrar_pirates;
//Pirates
function pirates_getword(direccion:dword):word;
procedure pirates_putword(direccion:dword;valor:word);
procedure pirates_sound_update;
//Genix
function genix_getword(direccion:dword):word;

const
        //Pirates
        pirates_rom:array[0..2] of tipo_roms=(
        (n:'r_449b.bin';l:$80000;p:0;crc:$224aeeda),(n:'l_5c1e.bin';l:$80000;p:$1;crc:$46740204),());
        pirates_gfx:array[0..4] of tipo_roms=(
        (n:'p4_4d48.bin';l:$80000;p:0;crc:$89fda216),(n:'p2_5d74.bin';l:$80000;p:$80000;crc:$40e069b4),
        (n:'p1_7b30.bin';l:$80000;p:$100000;crc:$26d78518),(n:'p8_9f4f.bin';l:$80000;p:$180000;crc:$f31696ea),());
        pirates_sprites:array[0..4] of tipo_roms=(
        (n:'s1_6e89.bin';l:$80000;p:0;crc:$c78a276f),(n:'s2_6df3.bin';l:$80000;p:$80000;crc:$9f0bad96),
        (n:'s4_fdcc.bin';l:$80000;p:$100000;crc:$8916ddb5),(n:'s8_4b7c.bin';l:$80000;p:$180000;crc:$1c41bd2c),());
        pirates_oki:tipo_roms=(n:'s89_49d4.bin';l:$80000;p:0;crc:$63a739ec);
        //Genix Family
        genix_rom:array[0..2] of tipo_roms=(
        (n:'1.15';l:$80000;p:0;crc:$d26abfb0),(n:'2.16';l:$80000;p:$1;crc:$a14a25b4),());
        genix_gfx:array[0..4] of tipo_roms=(
        (n:'7.34';l:$40000;p:0;crc:$58da8aac),(n:'9.35';l:$40000;p:$80000;crc:$96bad9a8),
        (n:'8.48';l:$40000;p:$100000;crc:$0ddc58b6),(n:'10.49';l:$40000;p:$180000;crc:$2be308c5),());
        genix_sprites:array[0..4] of tipo_roms=(
        (n:'6.69';l:$40000;p:0;crc:$b8422af7),(n:'5.70';l:$40000;p:$80000;crc:$e46125c5),
        (n:'4.71';l:$40000;p:$100000;crc:$7a8ed21b),(n:'3.72';l:$40000;p:$180000;crc:$f78bd6ca),());
        genix_oki:tipo_roms=(n:'0.31';l:$80000;p:0;crc:$80d087bc);

var
 rom:array[0..$7ffff] of word;
 sound_rom:array[0..1,0..$3ffff] of byte;
 ram1:array[0..$7ffff] of word;
 ram2:array[0..$3fff] of word;
 sprite_ram:array[0..$3ff] of word;
 scroll_x:word;

implementation

procedure Cargar_pirates;
begin
llamadas_maquina.iniciar:=iniciar_pirates;
llamadas_maquina.bucle_general:=pirates_principal;
llamadas_maquina.cerrar:=cerrar_pirates;
llamadas_maquina.reset:=reset_pirates;
end;

function iniciar_pirates:boolean;
var
  ptempw:pword;
  ptempb,ptempb2:pbyte;
procedure decr_and_load_oki;
var
  f,adrr:dword;
  ptempb3,ptempb4:pbyte;
begin
  ptempb3:=ptempb;
  for f:=0 to $7ffff do begin
    adrr:=BITSWAP24(f,23,22,21,20,19,10,16,13,8,4,7,11,14,17,12,6,2,0,5,18,15,3,1,9);
    ptempb4:=ptempb2;
    inc(ptempb4,adrr);
    ptempb4^:=BITSWAP8(ptempb3^,2,3,4,0,7,5,1,6);
    inc(ptempb3);
  end;
  copymemory(@sound_rom[0,0],ptempb2,$40000);
  ptempb3:=ptempb2;
  inc(ptempb3,$40000);
  copymemory(@sound_rom[1,0],ptempb3,$40000);
end;
procedure decr_and_load_rom;
var
  ptempw2:pword;
  f,adrl,adrr:dword;
  vl,vr:byte;
begin
  for f:=0 to $7ffff do begin
    ptempw2:=ptempw;
		adrl:=BITSWAP24(f,23,22,21,20,19,18,4,8,3,14,2,15,17,0,9,13,10,5,16,7,12,6,1,11);
    inc(ptempw2,adrl);
		vl:=BITSWAP8(ptempw2^ and $ff,4,2,7,1,6,5,0,3);
    ptempw2:=ptempw;
		adrr:=BITSWAP24(f,23,22,21,20,19,18,4,10,1,11,12,5,9,17,14,0,13,6,15,8,3,16,7,2);
    inc(ptempw2,adrr);
		vr:=BITSWAP8(ptempw2^ shr 8,1,4,7,0,3,5,6,2);
		rom[f]:=(vr shl 8) or vl;
  end;
end;
procedure decr_and_load_gfx;
const
  pt_x:array[0..7] of dword=(7, 6, 5, 4, 3, 2, 1, 0);
  pt_y:array[0..7] of dword=(8*0, 8*1, 8*2, 8*3, 8*4, 8*5, 8*6, 8*7);
var
  f,adrr:dword;
  ptempb3,ptempb4:pbyte;
begin
  for f:=0 to $7ffff do begin
		adrr:=BITSWAP24(f,23,22,21,20,19,18,10,2,5,9,7,13,16,14,11,4,1,6,12,17,3,0,15,8);
    ptempb3:=ptempb2;inc(ptempb3,adrr);
    ptempb4:=ptempb;inc(ptempb4,f);
		ptempb3^:=BITSWAP8(ptempb4^,2,3,4,0,7,5,1,6);
    ptempb3:=ptempb2;inc(ptempb3,adrr+$80000);
    ptempb4:=ptempb;inc(ptempb4,f+$80000);
		ptempb3^:= BITSWAP8(ptempb4^,4,2,7,1,6,5,0,3);
    ptempb3:=ptempb2;inc(ptempb3,adrr+$100000);
    ptempb4:=ptempb;inc(ptempb4,f+$100000);
		ptempb3^:= BITSWAP8(ptempb4^,1,4,7,0,3,5,6,2);
    ptempb3:=ptempb2;inc(ptempb3,adrr+$180000);
    ptempb4:=ptempb;inc(ptempb4,f+$180000);
		ptempb3^:= BITSWAP8(ptempb4^,2,3,4,0,7,5,1,6);
end;
init_gfx(0,8,8,$10000);
gfx[0].trans[0]:=true;
gfx_set_desc_data(4,0,8*8,$180000*8,$100000*8,$80000*8,0);
convert_gfx(0,0,ptempb2,@pt_x[0],@pt_y[0],false,false);
end;
procedure decr_and_load_sprites;
const
  ps_x:array[0..15] of dword=(7, 6, 5, 4, 3, 2, 1, 0,
		                          15,14,13,12,11,10, 9, 8);
  ps_y:array[0..15] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16,
                          		8*16, 9*16,10*16,11*16,12*16,13*16,14*16,15*16);
var
  f,adrr:dword;
  ptempb3,ptempb4:pbyte;
begin
for f:=0 to $7ffff do begin
		adrr:=BITSWAP24(f,23,22,21,20,19,18,17,5,12,14,8,3,0,7,9,16,4,2,6,11,13,1,10,15);
    ptempb3:=ptempb2;inc(ptempb3,adrr);
    ptempb4:=ptempb;inc(ptempb4,f);
		ptempb3^:=BITSWAP8(ptempb4^,4,2,7,1,6,5,0,3);
    ptempb3:=ptempb2;inc(ptempb3,adrr+$80000);
    ptempb4:=ptempb;inc(ptempb4,f+$80000);
		ptempb3^:= BITSWAP8(ptempb4^,1,4,7,0,3,5,6,2);
    ptempb3:=ptempb2;inc(ptempb3,adrr+$100000);
    ptempb4:=ptempb;inc(ptempb4,f+$100000);
		ptempb3^:= BITSWAP8(ptempb4^,2,3,4,0,7,5,1,6);
    ptempb3:=ptempb2;inc(ptempb3,adrr+$180000);
    ptempb4:=ptempb;inc(ptempb4,f+$180000);
		ptempb3^:= BITSWAP8(ptempb4^,4,2,7,1,6,5,0,3);
end;
init_gfx(1,16,16,$4000);
gfx[1].trans[0]:=true;
gfx_set_desc_data(4,0,16*16,$180000*8,$100000*8,$80000*8,0);
convert_gfx(1,0,ptempb2,@ps_x[0],@ps_y[0],false,false);
end;
begin
iniciar_pirates:=false;
iniciar_audio(false);
//Pantallas
screen_init(1,288,256,true);
screen_init(2,512,256,true);
screen_mod_scroll(2,512,512,511,256,256,255);
screen_init(3,512,256,true);
screen_mod_scroll(3,512,512,511,256,256,255);
screen_init(4,512,256,false,true);
iniciar_video(288,224);
//Main CPU
main_m68000:=cpu_m68000.create(16000000,256);
main_m68000.init_sound(pirates_sound_update);
//sound
oki_6295_0:=snd_okim6295.Create(0,1333333,OKIM6295_PIN7_LOW);
getmem(ptempb,$200000);
getmem(ptempb2,$200000);
case main_vars.tipo_maquina of
  206:begin //Pirates
        main_m68000.change_ram16_calls(pirates_getword,pirates_putword);
        //OKI snd
        if not(cargar_roms(ptempb,@pirates_oki,'pirates.zip')) then exit;
        decr_and_load_oki;
        //cargar roms
        getmem(ptempw,$100000);
        if not(cargar_roms16w(ptempw,@pirates_rom[0],'pirates.zip',0)) then exit;
        decr_and_load_rom;
        freemem(ptempw);
        //Protection patch
        rom[$62c0 shr 1]:=$6006;
        //cargar gfx
        if not(cargar_roms(ptempb,@pirates_gfx[0],'pirates.zip',0)) then exit;
        decr_and_load_gfx;
        //sprites
        if not(cargar_roms(ptempb,@pirates_sprites[0],'pirates.zip',0)) then exit;
        decr_and_load_sprites;
      end;
  207:begin //Genix Family
        main_m68000.change_ram16_calls(genix_getword,pirates_putword);
        //OKI snd
        if not(cargar_roms(ptempb,@genix_oki,'genix.zip')) then exit;
        decr_and_load_oki;
        //cargar roms
        getmem(ptempw,$100000);
        if not(cargar_roms16w(ptempw,@genix_rom[0],'genix.zip',0)) then exit;
        decr_and_load_rom;
        freemem(ptempw);
        //cargar gfx
        if not(cargar_roms(ptempb,@genix_gfx[0],'genix.zip',0)) then exit;
        decr_and_load_gfx;
        //sprites
        if not(cargar_roms(ptempb,@genix_sprites[0],'genix.zip',0)) then exit;
        decr_and_load_sprites;
      end;
end;
freemem(ptempb);
freemem(ptempb2);
//final
reset_pirates;
iniciar_pirates:=true;
end;

procedure cerrar_pirates;
begin
main_m68000.free;
oki_6295_0.Free;
close_audio;
close_video;
end;

procedure reset_pirates;
begin
 main_m68000.reset;
 oki_6295_0.reset;
 reset_audio;
 marcade.in0:=$9f;
 marcade.in1:=$FFFF;
end;

procedure draw_sprites;
var
  f,nchar,color,atrib,sx,sy:word;
  flip_x,flip_y:boolean;
begin
for f:=0 to $1fd do begin
    sx:=sprite_ram[5+(f*4)]-32;
		sy:=sprite_ram[3+(f*4)];  // indeed...
		if (sy and $8000)<>0 then exit;   // end-of-list marker */
    atrib:=sprite_ram[6+(f*4)];
		nchar:=atrib shr 2;
		color:=sprite_ram[4+(f*4)] and $ff;
		flip_x:=(atrib and 2)<>0;
		flip_y:=(atrib and 1)<>0;
		sy:=$f2-sy;
    put_gfx_sprite(nchar,(color shl 4)+$1800,flip_x,flip_y,1);
    actualiza_gfx_sprite(sx,sy,4,1);
end;
end;

procedure update_video_pirates;
var
  f,x,y,nchar,color:word;
begin
for f:=$0 to $47f do begin
  x:=f div 32;
  y:=f mod 32;
  //txt
  color:=ram2[$c1+(f*2)] and $1ff;
  if ((gfx[0].buffer[f]) or (buffer_color[color])) then begin
    nchar:=ram2[$c0+(f*2)];
    put_gfx_trans(x*8,y*8,nchar,color shl 4,1,0);
    gfx[0].buffer[f]:=false;
  end;
end;
for f:=$0 to $7ff do begin
  x:=f div 32;
  y:=f mod 32;
  //bg
  color:=ram2[$1541+(f*2)] and $1ff;
  if ((gfx[0].buffer[f+$480]) or (buffer_color[color+$100])) then begin
    nchar:=ram2[$1540+(f*2)];
    put_gfx(x*8,y*8,nchar,(color+$100) shl 4,2,0);
    gfx[0].buffer[f+$480]:=false;
  end;
  //fg
  color:=ram2[$9c1+(f*2)] and $1ff;
  if ((gfx[0].buffer[f+$c80]) or (buffer_color[color+$80])) then begin
    nchar:=ram2[$9c0+(f*2)];
    put_gfx_trans(x*8,y*8,nchar,(color+$80) shl 4,3,0);
    gfx[0].buffer[f+$c80]:=false;
  end;
end;
scroll__x(2,4,scroll_x);
scroll__x(3,4,scroll_x);
draw_sprites;
actualiza_trozo(0,0,288,256,1,0,0,288,256,4);
actualiza_trozo_final(0,16,288,224,4);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure eventos_pirates;inline;
begin
if event.arcade then begin
  //input
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $fffe) else marcade.in1:=(marcade.in1 or $0001);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $fffd) else marcade.in1:=(marcade.in1 or $0002);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fffb) else marcade.in1:=(marcade.in1 or $0004);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fff7) else marcade.in1:=(marcade.in1 or $0008);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $ffef) else marcade.in1:=(marcade.in1 or $0010);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $ffdf) else marcade.in1:=(marcade.in1 or $0020);
  if arcade_input.but2[0] then marcade.in1:=(marcade.in1 and $ffbf) else marcade.in1:=(marcade.in1 or $0040);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $ff7f) else marcade.in1:=(marcade.in1 or $0080);

  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $feff) else marcade.in1:=(marcade.in1 or $0100);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fdff) else marcade.in1:=(marcade.in1 or $0200);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $fbff) else marcade.in1:=(marcade.in1 or $0400);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $f7ff) else marcade.in1:=(marcade.in1 or $0800);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $efff) else marcade.in1:=(marcade.in1 or $1000);
  if arcade_input.but2[1] then marcade.in1:=(marcade.in1 and $dfff) else marcade.in1:=(marcade.in1 or $2000);
  if arcade_input.but3[1] then marcade.in1:=(marcade.in1 and $bfff) else marcade.in1:=(marcade.in1 or $4000);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $7fff) else marcade.in1:=(marcade.in1 or $8000);
  //system
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
end;
end;

procedure pirates_principal;
var
  frame_m:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=main_m68000.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to $ff do begin
    //main
    main_m68000.run(frame_m);
    frame_m:=frame_m+main_m68000.tframes-main_m68000.contador;
    if (f=239) then begin
      main_m68000.irq[1]:=HOLD_LINE;
      update_video_pirates;
    end;
 end;
 eventos_pirates;
 video_sync;
end;
end;

function pirates_getword(direccion:dword):word;
begin
case direccion of
    0..$fffff:pirates_getword:=rom[direccion shr 1];
    $100000..$10ffff:pirates_getword:=ram1[(direccion and $ffff) shr 1];
    $300000:pirates_getword:=marcade.in1;
    $400000:pirates_getword:=marcade.in0;
    $800000..$803fff:pirates_getword:=buffer_paleta[(direccion and $3fff) shr 1];
    $900000..$907fff:pirates_getword:=ram2[(direccion and $7fff) shr 1];
    $a00000:pirates_getword:=oki_6295_0.read;
end;
end;

procedure cambiar_color(pos,data:word);
var
  color:tcolor;
begin
  // red component */
	color.r:=pal5bit(data shr 10);
	// green component */
	color.g:=pal5bit((data shr 5) and $1f);
	// blue component */
	color.b:=pal5bit(data);
  set_pal_color(color,@paleta[pos]);
  buffer_color[pos shr 4]:=true;
end;

procedure pirates_putword(direccion:dword;valor:word);
begin
if direccion<$100000 then exit;
case direccion of
    $100000..$10ffff:ram1[(direccion and $ffff) shr 1]:=valor;
    $500000..$5007ff:sprite_ram[(direccion and $7ff) shr 1]:=valor;
    $600000:begin
              //eeprom
              copymemory(oki_6295_0.get_rom_addr,@sound_rom[(valor and $40) shr 6,0],$40000);
            end;
    $700000:scroll_x:=valor and $1ff;
    $800000..$803fff:if buffer_paleta[(direccion and $3fff) shr 1]<>valor then begin
                    buffer_paleta[(direccion and $3fff) shr 1]:=valor;
                    cambiar_color((direccion and $3fff) shr 1,valor);
                  end;
    $900000..$907fff:begin
                        ram2[(direccion and $7fff) shr 1]:=valor;
                        case (direccion and $7fff) of
                          $180..$137f:gfx[0].buffer[((direccion and $7fff)-$180) shr 2]:=true;
                          $1380..$2a7f:gfx[0].buffer[$c80+(((direccion and $7fff)-$1380) shr 2)]:=true;
                          $2a80..$4187:gfx[0].buffer[$480+(((direccion and $7fff)-$2a80) shr 2)]:=true;
                        end;
                     end;
    $a00000:oki_6295_0.write(valor and $ff)
end;
end;


procedure pirates_sound_update;
begin
  oki_6295_0.update;
end;

function genix_getword(direccion:dword):word;
begin
case direccion of
    0..$fffff:genix_getword:=rom[direccion shr 1];
    $100000..$10ffff:case (direccion and $ffff) of
                        $9e98:genix_getword:=4;
                        $9e96:genix_getword:=0;
                        else genix_getword:=ram1[(direccion and $ffff) shr 1];
                     end;
    $300000:genix_getword:=marcade.in1;
    $400000:genix_getword:=marcade.in0;
    $800000..$803fff:genix_getword:=buffer_paleta[(direccion and $3fff) shr 1];
    $900000..$907fff:genix_getword:=ram2[(direccion and $7fff) shr 1];
    $a00000:genix_getword:=oki_6295_0.read;
end;
end;


end.
