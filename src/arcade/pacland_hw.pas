unit pacland_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6809,m680x,namco_snd,main_engine,controls_engine,gfx_engine,rom_engine,
     pal_engine,misc_functions,sound_engine;

procedure Cargar_pacland;
procedure pacland_principal;
function iniciar_pacland:boolean;
procedure reset_pacland;
//Main CPU
function pacland_getbyte(direccion:word):byte;
procedure pacland_putbyte(direccion:word;valor:byte);
//MCU CPU
function mcu_getbyte(direccion:word):byte;
procedure mcu_putbyte(direccion:word;valor:byte);
function in_port1:byte;
function in_port2:byte;

implementation
const
        pacland_rom:array[0..6] of tipo_roms=(
        (n:'pl5_01b.8b';l:$4000;p:$0;crc:$b0ea7631),(n:'pl5_02.8d';l:$4000;p:$4000;crc:$d903e84e),
        (n:'pl1_3.8e';l:$4000;p:$8000;crc:$aa9fa739),(n:'pl1_4.8f';l:$4000;p:$c000;crc:$2b895a90),
        (n:'pl1_5.8h';l:$4000;p:$10000;crc:$7af66200),(n:'pl3_6.8j';l:$4000;p:$14000;crc:$2ffe3319),());
        pacland_char:tipo_roms=(n:'pl2_12.6n';l:$2000;p:0;crc:$a63c8726);
        pacland_tiles:tipo_roms=(n:'pl4_13.6t';l:$2000;p:0;crc:$3ae582fd);
        pacland_sprites:array[0..4] of tipo_roms=(
        (n:'pl1-9.6f';l:$4000;p:0;crc:$f5d5962b),(n:'pl1-8.6e';l:$4000;p:$4000;crc:$a2ebfa4a),
        (n:'pl1-10.7e';l:$4000;p:$8000;crc:$c7cf1904),(n:'pl1-11.7f';l:$4000;p:$c000;crc:$6621361a),());
        pacland_mcu:array[0..2] of tipo_roms=(
        (n:'pl1_7.3e';l:$2000;p:$8000;crc:$8c5becae),(n:'cus60-60a1.mcu';l:$1000;p:$f000;crc:$076ea82a),());
        pacland_prom:array[0..5] of tipo_roms=(
        (n:'pl1-2.1t';l:$400;p:$0;crc:$472885de),(n:'pl1-1.1r';l:$400;p:$400;crc:$a78ebdaf),
        (n:'pl1-5.5t';l:$400;p:$800;crc:$4b7ee712),(n:'pl1-4.4n';l:$400;p:$c00;crc:$3a7be418),
        (n:'pl1-3.6l';l:$400;p:$1000;crc:$80558da8),());

var
 rom_bank:array[0..7,0..$1fff] of byte;
 pal_proms:array[0..$7ff] of byte;
 rom_nbank,palette_bank:byte;
 scroll_x1,scroll_x2:word;
 irq_enable,irq_enable_mcu:boolean;

procedure Cargar_pacland;
begin
llamadas_maquina.iniciar:=iniciar_pacland;
llamadas_maquina.bucle_general:=pacland_principal;
llamadas_maquina.reset:=reset_pacland;
llamadas_maquina.fps_max:=60.60606060606060;
end;

procedure cambiar_paleta;inline;
var
  colores:tpaleta;
  f:byte;
  bit0,bit1,bit2,bit3,tmp:byte;
begin
for f:=0 to $ff do begin
  tmp:=pal_proms[palette_bank*$100+f];
  bit0:=(tmp shr 0) and $1;
  bit1:=(tmp shr 1) and $1;
  bit2:=(tmp shr 2) and $1;
  bit3:=(tmp shr 3) and $1;
  colores[f].r:=$0e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
  bit0:=(tmp shr 4) and $1;
  bit1:=(tmp shr 5) and $1;
  bit2:=(tmp shr 6) and $1;
  bit3:=(tmp shr 7) and $1;
  colores[f].g:=$0e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
  tmp:=pal_proms[palette_bank*$100+$400+f];
  bit0:=(tmp shr 0) and $1;
  bit1:=(tmp shr 1) and $1;
  bit2:=(tmp shr 2) and $1;
  bit3:=(tmp shr 3) and $1;
  colores[f].b:=$0e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
end;
set_pal(colores,$100);
end;

function iniciar_pacland:boolean;
var
  f:word;
  memoria_temp:array[0..$17fff] of byte;
const
    pc_x:array[0..7] of dword=(8*8, 8*8+1, 8*8+2, 8*8+3, 0, 1, 2, 3 );
    pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8 );
    ps_x:array[0..15] of dword=(0, 1, 2, 3, 8*8, 8*8+1, 8*8+2, 8*8+3,
			16*8+0, 16*8+1, 16*8+2, 16*8+3, 24*8+0, 24*8+1, 24*8+2, 24*8+3);
    ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			32*8, 33*8, 34*8, 35*8, 36*8, 37*8, 38*8, 39*8);
begin
iniciar_pacland:=false;
iniciar_audio(false);
//Pantallas:  principal+char y sprites
screen_init(1,512,256,true);
screen_mod_scroll(1,512,512,511,0,0,0);
screen_init(2,512,256,true);
screen_mod_scroll(2,512,512,511,0,0,0);
screen_init(3,512,256,false,true);
screen_init(4,512,256,true);
screen_mod_scroll(4,512,512,511,0,0,0);
iniciar_video(288,224);
//Main CPU
main_m6809:=cpu_m6809.Create(1536000,256);
main_m6809.change_ram_calls(pacland_getbyte,pacland_putbyte);
//MCU CPU
main_m6800:=cpu_m6800.create(6144000,$100,cpu_hd63701);
main_m6800.change_ram_calls(mcu_getbyte,mcu_putbyte);
main_m6800.change_io_calls(in_port1,in_port2,nil,nil,nil,nil,nil,nil);
//cargar roms
if not(cargar_roms(@memoria_temp[0],@pacland_rom[0],'pacland.zip',0)) then exit;
//Pongo las ROMs en su banco
copymemory(@memoria[$8000],@memoria_temp[$0],$8000);
for f:=0 to 7 do copymemory(@rom_bank[f,0],@memoria_temp[$8000+(f*$2000)],$2000);
//Cargar MCU
if not(cargar_roms(@mem_snd[0],@pacland_mcu[0],'pacland.zip',0)) then exit;
namco_sound_init(8,true);
//convertir chars
if not(cargar_roms(@memoria_temp[0],@pacland_char,'pacland.zip',1)) then exit;
init_gfx(0,8,8,$200);
gfx[0].trans[0]:=true;
gfx_set_desc_data(2,0,16*8,0,4);
convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,false);
//tiles
if not(cargar_roms(@memoria_temp[0],@pacland_tiles,'pacland.zip',1)) then exit;
init_gfx(1,8,8,$200);
gfx_set_desc_data(2,0,16*8,0,4);
convert_gfx(1,0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,false);
//sprites
if not(cargar_roms(@memoria_temp[0],@pacland_sprites[0],'pacland.zip',0)) then exit;
init_gfx(2,16,16,$200);
gfx_set_desc_data(4,0,64*8,0,4,$200*64*8+0,$200*64*8+4);
convert_gfx(2,0,@memoria_temp[0],@ps_x[0],@ps_y[0],false,false);
//Paleta
if not(cargar_roms(@memoria_temp[0],@pacland_prom[0],'pacland.zip',0)) then exit;
copymemory(@pal_proms[0],@memoria_temp[0],$800);
// tiles/sprites color table
for f:=$0 to $3ff do begin
  gfx[0].colores[f]:=memoria_temp[$800+f];
  gfx[1].colores[f]:=memoria_temp[$c00+f];
  gfx[2].colores[f]:=memoria_temp[$1000+f];
end;
//final
reset_pacland;
iniciar_pacland:=true;
end;

procedure reset_pacland;
begin
 main_m6809.reset;
 main_m6800.reset;
 namco_sound_reset;
 reset_audio;
 marcade.in0:=$FF;
 marcade.in1:=$FF;
 rom_nbank:=0;
 irq_enable:=false;
 irq_enable_mcu:=false;
 scroll_x1:=0;
 scroll_x2:=0;
 palette_bank:=0;
 cambiar_paleta;
end;

procedure put_sprite_pacland(nchar,color:word;flipx,flipy:boolean;pri:byte);inline;
var
  x,y,punto:byte;
  temp:pword;
  pos,post:pbyte;
begin
pos:=gfx[2].datos;
inc(pos,nchar*16*16);
if flipx then begin
  for y:=0 to 15 do begin
    post:=pos;
    inc(post,(y*16)+15);
    temp:=punbuf;
    for x:=15 downto 0 do begin
      punto:=gfx[2].colores[post^+color];
      case pri of
        0:if punto<$80 then temp^:=paleta[punto]
            else temp^:=paleta[max_colores];
        1:if (punto and $7f)<>$7f then temp^:=paleta[punto]
            else temp^:=paleta[max_colores];
        2:if ((punto>$ef) and (punto<>$ff)) then temp^:=paleta[punto]
            else temp^:=paleta[max_colores];
      end;
      inc(temp);
      dec(post);
    end;
    if flipy then putpixel(0,(15-y),16,punbuf,pant_sprites)
      else putpixel(0,y,16,punbuf,pant_sprites);
  end;
end else begin
  for y:=0 to 15 do begin
    temp:=punbuf;
    for x:=0 to 15 do begin
      punto:=gfx[2].colores[pos^+color];
      case pri of
        0:if punto<$80 then temp^:=paleta[punto]
            else temp^:=paleta[max_colores];
        1:if (punto and $7f)<>$7f then temp^:=paleta[punto]
            else temp^:=paleta[max_colores];
        2:if ((punto>$ef) and (punto<>$ff)) then temp^:=paleta[punto]
            else temp^:=paleta[max_colores];
      end;
      inc(temp);
      inc(pos);
    end;
    if flipy then putpixel(0,(15-y),16,punbuf,pant_sprites)
      else putpixel(0,y,16,punbuf,pant_sprites);
  end;
end;
end;

procedure draw_sprites(pri:byte);inline;
const
  gfx_offs:array[0..1,0..1] of byte=((0,1),(2,3));
var
  f:byte;
  nchar,color,sx,sy,tile:word;
  flipx,flipy,atrib:byte;
  sizex,sizey,x,y:word;
begin
	for f:=0 to $3f do begin
    atrib:=memoria[$3780+(f*2)];
		nchar:=memoria[$2780+(f*2)]+((atrib and $80) shl 1);
		color:=(memoria[$2781+(f*2)] and $3f) shl 4;
		sx:=memoria[$2f81+(f*2)]+((memoria[$3781+(f*2)] and 1) shl 8)-47;
		sy:=256-memoria[$2f80+(f*2)]+9;
		flipx:=atrib and $01;
		flipy:=(atrib shr 1) and $01;
		sizex:=(atrib shr 2) and $01;
		sizey:=(atrib shr 3) and $01;
		nchar:=nchar and not(sizex) and (not(sizey shl 1));
		sy:=((sy-16*sizey) and $ff)-32;
		for y:=0 to sizey do begin
			for x:=0 to sizex do begin
        tile:=nchar+gfx_offs[y xor (sizey*flipy),x xor (sizex*flipx)];
        put_sprite_pacland(tile,color,flipx<>0,flipy<>0,pri);
        actualiza_gfx_sprite(sx+16*x,sy+16*y,3,2);
			end;
		end;
	end;
end;

procedure put_gfx_pacland(pos_x,pos_y,nchar:dword;color:word;screen,ngfx:byte;flipx,flipy:boolean);inline;
var
  x,y,punto:byte;
  temp:pword;
  pos,post:pbyte;
begin
pos:=gfx[ngfx].datos;
inc(pos,nchar*8*8);
if flipx then begin
  for y:=0 to 7 do begin
    post:=pos;
    inc(post,(y*8)+7);
    temp:=punbuf;
    for x:=7 downto 0 do begin
      punto:=gfx[ngfx].colores[post^+color];
      if (punto and $7f)<$7f then temp^:=paleta[punto]
        else temp^:=paleta[max_colores];
      dec(post);
      inc(temp);
    end;
    if flipy then putpixel(pos_x,pos_y+(7-y),8,punbuf,screen)
      else putpixel(pos_x,pos_y+y,8,punbuf,screen);
  end;
end else begin
  for y:=0 to 7 do begin
    temp:=punbuf;
    for x:=0 to 7 do begin
      punto:=gfx[ngfx].colores[pos^+color];
      if (punto and $7f)<$7f then temp^:=paleta[punto]
        else temp^:=paleta[max_colores];
      inc(pos);
      inc(temp);
    end;
    if flipy then putpixel(pos_x,pos_y+(7-y),8,punbuf,screen)
      else putpixel(pos_x,pos_y+y,8,punbuf,screen);
  end;
end;
end;

procedure update_video_pacland;inline;
var
  f,color,nchar:word;
  x,y,atrib:byte;
begin
for f:=0 to $7ff do begin
    x:=f mod 64;
    y:=f div 64;
    //Background
    if gfx[1].buffer[f] then begin
      atrib:=memoria[$1001+(f*2)];
      nchar:=memoria[$1000+(f*2)]+(atrib and $1) shl 8;
      color:=(((atrib and $3e) shr 1)+((nchar and $1c0) shr 1)) shl 2;
      put_gfx_pacland(x*8,y*8,nchar,color,1,1,(atrib and $40)<>0,(atrib and $80)<>0);
      gfx[1].buffer[f]:=false;
    end;
    //Foreground
    if gfx[0].buffer[f] then begin
      atrib:=memoria[$1+(f*2)];
      nchar:=memoria[$0+(f*2)]+(atrib and $1) shl 8;
      color:=(((atrib and $1e) shr 1)+((nchar and $1e0) shr 1)) shl 2;
      put_gfx_pacland(x*8,y*8,nchar,color,2,0,(atrib and $40)<>0,(atrib and $80)<>0);
      if (atrib and $20)<>0 then put_gfx_pacland(x*8,y*8,nchar,color,4,0,(atrib and $40)<>0,(atrib and $80)<>0)
        else put_gfx_block_trans(x*8,y*8,4,8,8);
      gfx[0].buffer[f]:=false;
    end;
end;
fill_full_screen(3,0);
draw_sprites(0);
scroll__x(1,3,scroll_x2-3);
scroll__x_part(2,3,0,0,0,40);
scroll__x_part(2,3,scroll_x1,0,40,192);
scroll__x_part(2,3,0,0,232,16);
draw_sprites(1);
scroll__x_part(4,3,0,0,0,40);
scroll__x_part(4,3,scroll_x1,0,40,192);
scroll__x_part(4,3,0,0,232,16);
draw_sprites(2);
actualiza_trozo_final(24,16,288,224,3);
end;

procedure eventos_pacland;
begin
if event.arcade then begin
  //IN2
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  //marcade.in1
  if arcade_input.coin[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.coin[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
end;
end;

procedure pacland_principal;
var
  f:word;
  frame_m,frame_mcu:single;
begin
init_controls(false,false,false,true);
frame_m:=main_m6809.tframes;
frame_mcu:=main_m6800.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
    //Main CPU
    main_m6809.run(frame_m);
    frame_m:=frame_m+main_m6809.tframes-main_m6809.contador;
    //Sound CPU
    main_m6800.run(frame_mcu);
    frame_mcu:=frame_mcu+main_m6800.tframes-main_m6800.contador;
    if f=239 then begin
      if irq_enable then main_m6809.change_irq(ASSERT_LINE);
      if irq_enable_mcu then main_m6800.change_irq(ASSERT_LINE);
      update_video_pacland;
    end;
  end;
  if sound_status.hay_sonido then begin
      namco_playsound;
      play_sonido;
  end;
  eventos_pacland;
  video_sync;
end;
end;

function pacland_getbyte(direccion:word):byte;
begin
case direccion of
  $4000..$5fff:pacland_getbyte:=rom_bank[rom_nbank,direccion and $1fff];
  $6800..$6bff:pacland_getbyte:=namcos1_cus30_r(direccion and $3ff);
  else pacland_getbyte:=memoria[direccion];
end;
end;

procedure pacland_putbyte(direccion:word;valor:byte);
begin
case direccion of
  $0..$fff:gfx[0].buffer[direccion shr 1]:=true;
  $1000..$1fff:gfx[1].buffer[(direccion and $fff) shr 1]:=true;
  $3800:scroll_x1:=valor;
  $3801:scroll_x1:=valor+256;
  $3a00:scroll_x2:=valor;
  $3a01:scroll_x2:=valor+256;
  $3c00:begin
          rom_nbank:=valor and $7;
          if palette_bank<>((valor and $18) shr 3) then
            cambiar_paleta;
            palette_bank:=(valor and $18) shr 3;
            fillchar(gfx[0].buffer[0],$800,1);
            fillchar(gfx[1].buffer[0],$800,1);
        end;
  $4000..$5fff:exit;
  $6800..$6bff:namcos1_cus30_w(direccion and $3ff,valor);
  $7000..$7fff:begin
                   irq_enable:=not(BIT((direccion and $fff),11));
                   if not(irq_enable) then main_m6809.change_irq(CLEAR_LINE);
               end;
  $8000..$8fff:if not(BIT((direccion and $fff),11)) then main_m6800.reset;
end;
if direccion<$8000 then memoria[direccion]:=valor;
end;

function mcu_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$1f:mcu_getbyte:=main_m6800.m6803_internal_reg_r(direccion);
  $1000..$13ff:mcu_getbyte:=namcos1_cus30_r(direccion and $3ff);
  $d000,$d001:mcu_getbyte:=$ff;  //dswa dswb
  $d002:mcu_getbyte:=(marcade.in1 and $f0)+$f;
  $d003:mcu_getbyte:=((marcade.in1 and $f) shl 4)+$f;
    else mcu_getbyte:=mem_snd[direccion];
  end;
end;

procedure mcu_putbyte(direccion:word;valor:byte);
begin
case direccion of
  $0..$1f:main_m6800.m6803_internal_reg_w(direccion,valor);
  $1000..$13ff:namcos1_cus30_w(direccion and $3ff,valor);
  $4000..$7fff:begin
                  irq_enable_mcu:=not(BIT(direccion and $3fff,13));
                  if not(irq_enable_mcu) then main_m6800.change_irq(CLEAR_LINE);
               end;
  $8000..$bfff,$f000..$ffff:exit;
end;
mem_snd[direccion]:=valor;
end;

function in_port1:byte;
begin
  in_port1:=marcade.in0;
end;

function in_port2:byte;
begin
  in_port2:=$ff;
end;

end.
