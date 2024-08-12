unit pacland_hw;
interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6809,m680x,namco_snd,main_engine,controls_engine,gfx_engine,rom_engine,
     pal_engine,sound_engine;
function iniciar_pacland:boolean;
implementation
const
        pacland_rom:array[0..5] of tipo_roms=(
        (n:'pl5_01b.8b';l:$4000;p:$0;crc:$b0ea7631),(n:'pl5_02.8d';l:$4000;p:$4000;crc:$d903e84e),
        (n:'pl1_3.8e';l:$4000;p:$8000;crc:$aa9fa739),(n:'pl1_4.8f';l:$4000;p:$c000;crc:$2b895a90),
        (n:'pl1_5.8h';l:$4000;p:$10000;crc:$7af66200),(n:'pl3_6.8j';l:$4000;p:$14000;crc:$2ffe3319));
        pacland_char:tipo_roms=(n:'pl2_12.6n';l:$2000;p:0;crc:$a63c8726);
        pacland_tiles:tipo_roms=(n:'pl4_13.6t';l:$2000;p:0;crc:$3ae582fd);
        pacland_sprites:array[0..3] of tipo_roms=(
        (n:'pl1-9.6f';l:$4000;p:0;crc:$f5d5962b),(n:'pl1-8.6e';l:$4000;p:$4000;crc:$a2ebfa4a),
        (n:'pl1-10.7e';l:$4000;p:$8000;crc:$c7cf1904),(n:'pl1-11.7f';l:$4000;p:$c000;crc:$6621361a));
        pacland_mcu:array[0..1] of tipo_roms=(
        (n:'pl1_7.3e';l:$2000;p:$1000;crc:$8c5becae),(n:'cus60-60a1.mcu';l:$1000;p:0;crc:$076ea82a));
        pacland_prom:array[0..4] of tipo_roms=(
        (n:'pl1-2.1t';l:$400;p:$0;crc:$472885de),(n:'pl1-1.1r';l:$400;p:$400;crc:$a78ebdaf),
        (n:'pl1-5.5t';l:$400;p:$800;crc:$4b7ee712),(n:'pl1-4.4n';l:$400;p:$c00;crc:$3a7be418),
        (n:'pl1-3.6l';l:$400;p:$1000;crc:$80558da8));
        pacland_dip_a:array [0..4] of def_dip=(
        (mask:$3;name:'Coin B';number:4;dip:((dip_val:$0;dip_name:'3C 1C'),(dip_val:$1;dip_name:'2C 1C'),(dip_val:$3;dip_name:'1C 1C'),(dip_val:$2;dip_name:'1C 2C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$4;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$18;name:'Coin A';number:4;dip:((dip_val:$0;dip_name:'3C 1C'),(dip_val:$8;dip_name:'2C 1C'),(dip_val:$18;dip_name:'1C 1C'),(dip_val:$10;dip_name:'1C 2C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$60;name:'Lives';number:4;dip:((dip_val:$40;dip_name:'2'),(dip_val:$60;dip_name:'3'),(dip_val:$20;dip_name:'4'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),());
        pacland_dip_b:array [0..5] of def_dip=(
        (mask:$1;name:'Trip Select';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$1;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2;name:'Freeze';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Round Select';number:2;dip:((dip_val:$4;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$18;name:'Difficulty';number:4;dip:((dip_val:$10;dip_name:'B (Easy)'),(dip_val:$18;dip_name:'A (Average)'),(dip_val:$8;dip_name:'C (Hard)'),(dip_val:$0;dip_name:'D (Very Hard)'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$e0;name:'Bonus Life';number:8;dip:((dip_val:$e0;dip_name:'30K 80K 150K 300K 500K 1M'),(dip_val:$80;dip_name:'30K 80K 100K+'),(dip_val:$40;dip_name:'30K 80K 150K'),(dip_val:$c0;dip_name:'30K 100K 200K 400K 600K 1M'),(dip_val:$a0;dip_name:'40K 100K 180K 300K 500K 1M'),(dip_val:$20;dip_name:'40K 100K 200K'),(dip_val:$0;dip_name:'40K'),(dip_val:$60;dip_name:'50K 150K 200K+'),(),(),(),(),(),(),(),())),());
        pacland_dip_c:array [0..1] of def_dip=(
        (mask:$80;name:'Cabinet';number:2;dip:((dip_val:$80;dip_name:'Upright'),(dip_val:$0;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 rom_bank:array[0..7,0..$1fff] of byte;
 pal_proms:array[0..$7ff] of byte;
 rom_nbank,palette_bank:byte;
 scroll_x1,scroll_x2:word;
 irq_enable,irq_enable_mcu:boolean;
procedure update_video_pacland;
procedure put_sprite_pacland(nchar,color:word;flipx,flipy:boolean;pri:byte);
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
            else temp^:=paleta[MAX_COLORES];
        1:if (punto and $7f)<>$7f then temp^:=paleta[punto]
            else temp^:=paleta[MAX_COLORES];
        2:if ((punto>$ef) and (punto<>$ff)) then temp^:=paleta[punto]
            else temp^:=paleta[MAX_COLORES];
      end;
      inc(temp);
      dec(post);
    end;
    if flipy then putpixel(0,(15-y),16,punbuf,PANT_SPRITES)
      else putpixel(0,y,16,punbuf,PANT_SPRITES);
  end;
end else begin
  for y:=0 to 15 do begin
    temp:=punbuf;
    for x:=0 to 15 do begin
      punto:=gfx[2].colores[pos^+color];
      case pri of
        0:if punto<$80 then temp^:=paleta[punto]
            else temp^:=paleta[MAX_COLORES];
        1:if (punto and $7f)<>$7f then temp^:=paleta[punto]
            else temp^:=paleta[MAX_COLORES];
        2:if ((punto>$ef) and (punto<>$ff)) then temp^:=paleta[punto]
            else temp^:=paleta[MAX_COLORES];
      end;
      inc(temp);
      inc(pos);
    end;
    if flipy then putpixel(0,(15-y),16,punbuf,PANT_SPRITES)
      else putpixel(0,y,16,punbuf,PANT_SPRITES);
  end;
end;
end;
procedure draw_sprites(pri:byte);
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
procedure put_gfx_pacland(pos_x,pos_y,nchar:dword;color:word;screen,ngfx:byte;flipx,flipy:boolean);
var
  x,y,py,cant_x,cant_y,punto:byte;
  temp,temp2:pword;
  pos:pbyte;
  dir_x,dir_y:integer;
begin
pos:=gfx[ngfx].datos;
cant_y:=gfx[ngfx].y;
cant_x:=gfx[ngfx].x;
inc(pos,nchar*cant_x*gfx[ngfx].y);
if flipy then begin
  py:=cant_y-1;
  dir_y:=-1;
end else begin
  py:=0;
  dir_y:=1;
end;
if flipx then begin
  temp2:=punbuf;
  inc(temp2,cant_x-1);
  dir_x:=-1;
end else begin
  temp2:=punbuf;
  dir_x:=1;
end;
for y:=0 to (cant_y-1) do begin
  temp:=temp2;
  for x:=0 to (cant_x-1) do begin
    punto:=gfx[ngfx].colores[pos^+color];
    if (punto and $7f)<$7f then temp^:=paleta[punto]
      else temp^:=paleta[MAX_COLORES];
    inc(pos);
    inc(temp,dir_x);
  end;
  putpixel_gfx_int(pos_x,pos_y+py,cant_x,screen);
  py:=py+dir_y;
end;
end;
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
  //P1 & P2
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.but0[1] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.left[1] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  //System
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
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
frame_m:=m6809_0.tframes;
frame_mcu:=m6800_0.tframes;
while EmuStatus=EsRunning do begin
  for f:=0 to 263 do begin
    //Main CPU
    m6809_0.run(frame_m);
    frame_m:=frame_m+m6809_0.tframes-m6809_0.contador;
    //Sound CPU
    m6800_0.run(frame_mcu);
    frame_mcu:=frame_mcu+m6800_0.tframes-m6800_0.contador;
    if f=239 then begin
      if irq_enable then m6809_0.change_irq(ASSERT_LINE);
      if irq_enable_mcu then m6800_0.change_irq(ASSERT_LINE);
      update_video_pacland;
    end;
  end;
  eventos_pacland;
  video_sync;
end;
end;
function pacland_getbyte(direccion:word):byte;
begin
case direccion of
  0..$37ff,$8000..$ffff:pacland_getbyte:=memoria[direccion];
  $4000..$5fff:pacland_getbyte:=rom_bank[rom_nbank,direccion and $1fff];
  $6800..$6bff:pacland_getbyte:=namco_snd_0.namcos1_cus30_r(direccion and $3ff);
end;
end;
procedure pacland_putbyte(direccion:word;valor:byte);
procedure cambiar_paleta;
var
  colores:tpaleta;
  f,bit0,bit1,bit2,bit3,tmp:byte;
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
begin
case direccion of
  $0..$fff:if memoria[direccion]<>valor then begin
              gfx[0].buffer[direccion shr 1]:=true;
              memoria[direccion]:=valor;
           end;
  $1000..$1fff:if memoria[direccion]<>valor then begin
                  gfx[1].buffer[(direccion and $fff) shr 1]:=true;
                  memoria[direccion]:=valor;
               end;
  $2000..$37ff:memoria[direccion]:=valor;
  $3800:scroll_x1:=valor;
  $3801:scroll_x1:=valor+256;
  $3a00:scroll_x2:=valor;
  $3a01:scroll_x2:=valor+256;
  $3c00:begin
          rom_nbank:=valor and $7;
          if palette_bank<>((valor and $18) shr 3) then
            palette_bank:=(valor and $18) shr 3;
            fillchar(gfx[0].buffer[0],$800,1);
            fillchar(gfx[1].buffer[0],$800,1);
            cambiar_paleta;
        end;
  $4000..$5fff,$a000..$ffff:;
  $6800..$6bff:namco_snd_0.namcos1_cus30_w(direccion and $3ff,valor);
  $7000..$7fff:begin
                   irq_enable:=(direccion and $800)=0;
                   if not(irq_enable) then m6809_0.change_irq(CLEAR_LINE);
               end;
  $8000..$8fff:if ((direccion and $800)=0) then m6800_0.reset;
  $9000..$9fff:main_screen.flip_main_screen:=(direccion and $800)=0;
end;
end;
function mcu_getbyte(direccion:word):byte;
begin
case direccion of
  $1000..$13ff:mcu_getbyte:=namco_snd_0.namcos1_cus30_r(direccion and $3ff);
  $8000..$c7ff,$f000..$ffff:mcu_getbyte:=mem_snd[direccion];
  $d000:mcu_getbyte:=(marcade.dswa and $f0) or (marcade.dswb shr 4);
  $d001:mcu_getbyte:=((marcade.dswa and $f) shl 4) or (marcade.dswb and $f);
  $d002:mcu_getbyte:=(marcade.in1 and $f0) or marcade.dswc or $f;
  $d003:mcu_getbyte:=((marcade.in1 and $f) shl 4) or $f;
  end;
end;
procedure mcu_putbyte(direccion:word;valor:byte);
begin
case direccion of
  $1000..$13ff:namco_snd_0.namcos1_cus30_w(direccion and $3ff,valor);
  $4000..$7fff:begin
                  irq_enable_mcu:=((direccion and $2000)=0);
                  if not(irq_enable_mcu) then m6800_0.change_irq(CLEAR_LINE);
               end;
  $8000..$bfff,$f000..$ffff:;
  $c000..$c7ff:mem_snd[direccion]:=valor;
end;
end;
function in_port1:byte;
begin
  in_port1:=marcade.in0;
end;
function in_port2:byte;
begin
  in_port2:=$ff; //Sin uso
end;
procedure pacland_sound_update;
begin
  namco_snd_0.update;
end;
//Main
procedure reset_pacland;
begin
 m6809_0.reset;
 m6800_0.reset;
 namco_snd_0.reset;
 reset_audio;
 marcade.in0:=$ff;
 marcade.in1:=$7f;
 rom_nbank:=0;
 irq_enable:=false;
 irq_enable_mcu:=false;
 scroll_x1:=0;
 scroll_x2:=0;
 palette_bank:=$ff;
end;
function iniciar_pacland:boolean;
var
  f:word;
  memoria_temp:array[0..$17fff] of byte;
  ptemp:pbyte;
const
    pc_x:array[0..7] of dword=(8*8, 8*8+1, 8*8+2, 8*8+3, 0, 1, 2, 3 );
    ps_x:array[0..15] of dword=(0, 1, 2, 3, 8*8, 8*8+1, 8*8+2, 8*8+3,
			16*8+0, 16*8+1, 16*8+2, 16*8+3, 24*8+0, 24*8+1, 24*8+2, 24*8+3);
    ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			32*8, 33*8, 34*8, 35*8, 36*8, 37*8, 38*8, 39*8);
begin
iniciar_pacland:=false;
llamadas_maquina.bucle_general:=pacland_principal;
llamadas_maquina.reset:=reset_pacland;
llamadas_maquina.fps_max:=60.60606060606060;
iniciar_audio(false);
screen_init(1,512,256,true);
screen_mod_scroll(1,512,512,511,256,256,255);
screen_init(2,512,256,true);
screen_mod_scroll(2,512,512,511,256,256,255);
screen_init(3,512,256,false,true);
screen_init(4,512,256,true);
screen_mod_scroll(4,512,512,511,256,256,255);
iniciar_video(288,224);
//Main CPU
m6809_0:=cpu_m6809.Create(1536000,264,TCPU_M6809);
m6809_0.change_ram_calls(pacland_getbyte,pacland_putbyte);
//MCU CPU
m6800_0:=cpu_m6800.create(6144000,264,TCPU_HD63701V);
m6800_0.change_ram_calls(mcu_getbyte,mcu_putbyte);
m6800_0.change_io_calls(in_port1,in_port2,nil,nil,nil,nil,nil,nil);
m6800_0.init_sound(pacland_sound_update);
//cargar roms
if not(roms_load(@memoria_temp,pacland_rom)) then exit;
//Pongo las ROMs en su banco
copymemory(@memoria[$8000],@memoria_temp,$8000);
for f:=0 to 7 do copymemory(@rom_bank[f,0],@memoria_temp[$8000+(f*$2000)],$2000);
//Cargar MCU
if not(roms_load(@memoria_temp,pacland_mcu)) then exit;
ptemp:=m6800_0.get_rom_addr;
copymemory(@ptemp[$1000],@memoria_temp[0],$1000);
copymemory(@mem_snd[$8000],@memoria_temp[$1000],$2000);
namco_snd_0:=namco_snd_chip.create(8,true);
//convertir chars
if not(roms_load(@memoria_temp,pacland_char)) then exit;
init_gfx(0,8,8,$200);
gfx[0].trans[0]:=true;
gfx_set_desc_data(2,0,16*8,0,4);
convert_gfx(0,0,@memoria_temp,@pc_x,@ps_y,false,false);
//tiles
if not(roms_load(@memoria_temp,pacland_tiles)) then exit;
init_gfx(1,8,8,$200);
gfx_set_desc_data(2,0,16*8,0,4);
convert_gfx(1,0,@memoria_temp,@pc_x,@ps_y,false,false);
//sprites
if not(roms_load(@memoria_temp,pacland_sprites)) then exit;
init_gfx(2,16,16,$200);
gfx_set_desc_data(4,0,64*8,0,4,$200*64*8+0,$200*64*8+4);
convert_gfx(2,0,@memoria_temp,@ps_x,@ps_y,false,false);
//Paleta
if not(roms_load(@memoria_temp,pacland_prom)) then exit;
copymemory(@pal_proms,@memoria_temp,$800);
// tiles/sprites color table
for f:=$0 to $3ff do begin
  gfx[0].colores[f]:=memoria_temp[$800+f];
  gfx[1].colores[f]:=memoria_temp[$c00+f];
  gfx[2].colores[f]:=memoria_temp[$1000+f];
end;
//Dip
marcade.dswa:=$ff;
marcade.dswa_val:=@pacland_dip_a;
marcade.dswb:=$ff;
marcade.dswb_val:=@pacland_dip_b;
marcade.dswc:=$80;
marcade.dswc_val:=@pacland_dip_c;
//final
reset_pacland;
iniciar_pacland:=true;
end;
end.
