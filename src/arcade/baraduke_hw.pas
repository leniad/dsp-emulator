unit baraduke_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6809,m680x,namco_snd,main_engine,controls_engine,gfx_engine,
     rom_engine,pal_engine,misc_functions,sound_engine;

function iniciar_baraduke:boolean;

implementation
const
        //Baraduke
        baraduke_rom:array[0..2] of tipo_roms=(
        (n:'bd1_3.9c';l:$2000;p:$6000;crc:$ea2ea790),(n:'bd1_1.9a';l:$4000;p:$8000;crc:$4e9f2bdc),
        (n:'bd1_2.9b';l:$4000;p:$c000;crc:$40617fcd));
        baraduke_mcu:array[0..1] of tipo_roms=(
        (n:'bd1_4b.3b';l:$4000;p:$8000;crc:$a47ecd32),(n:'cus60-60a1.mcu';l:$1000;p:$f000;crc:$076ea82a));
        baraduke_chars:tipo_roms=(n:'bd1_5.3j';l:$2000;p:0;crc:$706b7fee);
        baraduke_tiles:array[0..2] of tipo_roms=(
        (n:'bd1_8.4p';l:$4000;p:0;crc:$b0bb0710),(n:'bd1_7.4n';l:$4000;p:$4000;crc:$0d7ebec9),
        (n:'bd1_6.4m';l:$4000;p:$8000;crc:$e5da0896));
        baraduke_sprites:array[0..3] of tipo_roms=(
        (n:'bd1_9.8k';l:$4000;p:0;crc:$87a29acc),(n:'bd1_10.8l';l:$4000;p:$4000;crc:$72b6d20c),
        (n:'bd1_11.8m';l:$4000;p:$8000;crc:$3076af9c),(n:'bd1_12.8n';l:$4000;p:$c000;crc:$8b4c09a3));
        baraduke_prom:array[0..1] of tipo_roms=(
        (n:'bd1-1.1n';l:$800;p:$0;crc:$0d78ebc6),(n:'bd1-2.2m';l:$800;p:$800;crc:$03f7241f));
        baraduke_dip_a:array [0..4] of def_dip=(
        (mask:$3;name:'Coin B';number:4;dip:((dip_val:$0;dip_name:'3C 1C'),(dip_val:$1;dip_name:'2C 1C'),(dip_val:$3;dip_name:'1C 1C'),(dip_val:$2;dip_name:'2C 1C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$4;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$18;name:'Coin A';number:4;dip:((dip_val:$0;dip_name:'3C 1C'),(dip_val:$8;dip_name:'2C 1C'),(dip_val:$18;dip_name:'1C 1C'),(dip_val:$10;dip_name:'2C 1C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$60;name:'Lives';number:4;dip:((dip_val:$40;dip_name:'2'),(dip_val:$60;dip_name:'3'),(dip_val:$20;dip_name:'4'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),());
        baraduke_dip_b:array [0..5] of def_dip=(
        (mask:$2;name:'Allow Continue From Last Level';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Freeze';number:2;dip:((dip_val:$4;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Round Select';number:2;dip:((dip_val:$8;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Difficulty';number:4;dip:((dip_val:$20;dip_name:'Easy'),(dip_val:$30;dip_name:'Normal'),(dip_val:$10;dip_name:'Hard'),(dip_val:$0;dip_name:'Very Hard'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Bonus Life';number:4;dip:((dip_val:$80;dip_name:'10K+'),(dip_val:$c0;dip_name:'10K 20K+'),(dip_val:$40;dip_name:'20K+'),(dip_val:$0;dip_name:'None'),(),(),(),(),(),(),(),(),(),(),(),())),());
        baraduke_dip_c:array [0..1] of def_dip=(
        (mask:$2;name:'Cabinet';number:2;dip:((dip_val:$2;dip_name:'Upright'),(dip_val:$0;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        //Metro-cross
        metrocross_rom:array[0..2] of tipo_roms=(
        (n:'mc1-3.9c';l:$2000;p:$6000;crc:$3390b33c),(n:'mc1-1.9a';l:$4000;p:$8000;crc:$10b0977e),
        (n:'mc1-2.9b';l:$4000;p:$c000;crc:$5c846f35));
        metrocross_mcu:array[0..1] of tipo_roms=(
        (n:'mc1-4.3b';l:$2000;p:$8000;crc:$9c88f898),(n:'cus60-60a1.mcu';l:$1000;p:$f000;crc:$076ea82a));
        metrocross_chars:tipo_roms=(n:'mc1-5.3j';l:$2000;p:0;crc:$9b5ea33a);
        metrocross_tiles:array[0..1] of tipo_roms=(
        (n:'mc1-7.4p';l:$4000;p:0;crc:$c9dfa003),(n:'mc1-6.4n';l:$4000;p:$4000;crc:$9686dc3c));
        metrocross_sprites:array[0..1] of tipo_roms=(
        (n:'mc1-8.8k';l:$4000;p:0;crc:$265b31fa),(n:'mc1-9.8l';l:$4000;p:$4000;crc:$541ec029));
        metrocross_prom:array[0..1] of tipo_roms=(
        (n:'mc1-1.1n';l:$800;p:$0;crc:$32a78a8b),(n:'mc1-2.2m';l:$800;p:$800;crc:$6f4dca7b));
        metrocross_dip_a:array [0..4] of def_dip=(
        (mask:$3;name:'Coin B';number:4;dip:((dip_val:$0;dip_name:'3C 1C'),(dip_val:$1;dip_name:'2C 1C'),(dip_val:$3;dip_name:'1C 1C'),(dip_val:$2;dip_name:'2C 1C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Allow Continue';number:2;dip:((dip_val:$0;dip_name:'No'),(dip_val:$4;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$18;name:'Difficulty';number:4;dip:((dip_val:$10;dip_name:'Easy'),(dip_val:$18;dip_name:'Normal'),(dip_val:$8;dip_name:'Hard'),(dip_val:$0;dip_name:'Very Hard'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$60;name:'Coin A';number:4;dip:((dip_val:$0;dip_name:'3C 1C'),(dip_val:$20;dip_name:'2C 1C'),(dip_val:$60;dip_name:'1C 1C'),(dip_val:$40;dip_name:'2C 1C'),(),(),(),(),(),(),(),(),(),(),(),())),());
        metrocross_dip_b:array [0..3] of def_dip=(
        (mask:$20;name:'Freeze';number:2;dip:((dip_val:$20;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Round Select';number:2;dip:((dip_val:$40;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$80;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 inputport_selected,scroll_y0,scroll_y1:byte;
 sprite_mask,counter,scroll_x0,scroll_x1:word;
 prio,copy_sprites:boolean;
 spritex_add,spritey_add:integer;

procedure update_video_baraduke;
procedure draw_sprites(prior:byte);
var
  x,y,sizex,sizey,sy,f,atrib1,atrib2:byte;
  nchar,sx,sprite_xoffs,sprite_yoffs,color:word;
  flipx,flipy:boolean;
const
  gfx_offs:array[0..1,0..1] of byte=((0,1),(2,3));
begin
  sprite_xoffs:=memoria[$07f5]-256*(memoria[$07f4] and 1);
	sprite_yoffs:=memoria[$07f7];
	for f:=0 to $7e do begin
    atrib1:=memoria[$180a+(f*$10)];
    if prior<>(atrib1 and 1) then continue;
    atrib2:=memoria[$180e+(f*$10)];
    color:=memoria[$180c+(f*$10)];
    flipx:=(atrib1 and $20)<>0;
    flipy:=(atrib2 and $01)<>0;
    sizex:=(atrib1 and $80) shr 7;
    sizey:=(atrib2 and $04) shr 2;
		sx:=((memoria[$180d+(f*$10)]+((color and $01) shl 8))+sprite_xoffs+spritex_add) and $1ff;
    sy:=(240-memoria[$180f+(f*$10)])-sprite_yoffs-(16*sizey)+spritey_add;
    nchar:=memoria[$180b+(f*$10)]*4;
    if (((atrib1 and $10)<>0) and (sizex=0)) then nchar:=nchar+1;
    if (((atrib2 and $10)<>0) and (sizey=0)) then nchar:=nchar+2;
    color:=(color and $fe) shl 3;
    for y:=0 to sizey do
      for x:=0 to sizex do
        put_gfx_sprite_diff((nchar+gfx_offs[y xor (sizey*byte(flipy))][x xor (sizex*byte(flipx))]) and sprite_mask,color,flipx,flipy,3,16*x,16*y);
    actualiza_gfx_sprite_size(sx,sy,4,16*(sizex+1),16*(sizey+1));
	end;
end;
var
  f,color,nchar,pos:word;
  sx,sy,x,y,atrib:byte;
begin
for x:=0 to 35 do begin
  for y:=0 to 27 do begin
     sx:=x-2;
     sy:=y+2;
     if (sx and $20)<>0 then pos:=sy+((sx and $1f) shl 5)
        else pos:=sx+(sy shl 5);
     if gfx[0].buffer[pos] then begin
        color:=memoria[$4c00+pos];
        nchar:=memoria[$4800+pos];
        put_gfx_trans(x*8,y*8,nchar,color shl 4,1,0);
        gfx[0].buffer[pos]:=false;
     end;
  end;
end;
for f:=0 to $7ff do begin
  x:=f mod 64;
  y:=f div 64;
  if gfx[1].buffer[f] then begin
    atrib:=memoria[$2001+(f*2)];
    nchar:=memoria[$2000+(f*2)]+(atrib and $3) shl 8;
    if prio then put_gfx_trans(x*8,y*8,nchar,atrib shl 3,2,1)
      else put_gfx(x*8,y*8,nchar,atrib shl 3,2,1);
    gfx[1].buffer[f]:=false;
  end;
  if gfx[2].buffer[f] then begin
    atrib:=memoria[$3001+(f*2)];
    nchar:=memoria[$3000+(f*2)]+(atrib and $3) shl 8;
    if prio then put_gfx(x*8,y*8,nchar,atrib shl 3,3,2)
      else put_gfx_trans(x*8,y*8,nchar,atrib shl 3,3,2);
    gfx[2].buffer[f]:=false;
  end;
end;
if prio then begin
  scroll_x_y(3,4,scroll_x1+24,scroll_y1+25);
  draw_sprites(0);
  scroll_x_y(2,4,scroll_x0+26,scroll_y0+25);
end else begin
  scroll_x_y(2,4,scroll_x0+26,scroll_y0+25);
  draw_sprites(0);
  scroll_x_y(3,4,scroll_x1+24,scroll_y1+25);
end;
draw_sprites(1);
actualiza_trozo(0,0,288,224,1,0,0,288,224,4);
actualiza_trozo_final(0,0,288,224,4);
end;

procedure eventos_baraduke;
begin
if event.arcade then begin
  //marcade.in0
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  //marcade.in1
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  //marcade.in2
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
end;
end;

procedure copy_sprites_hw;
var
  i,j:byte;
begin
for i:=0 to $7f do begin
  for j:=10 to 15 do memoria[$1800+(i*$10)+j]:=memoria[$1800+(i*$10)+j-6];
end;
copy_sprites:=false;
end;

procedure baraduke_principal;
var
  f:word;
  frame_m,frame_mcu:single;
begin
init_controls(false,false,false,true);
frame_m:=m6809_0.tframes;
frame_mcu:=m6800_0.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to 263 do begin
    //Main CPU
    m6809_0.run(frame_m);
    frame_m:=frame_m+m6809_0.tframes-m6809_0.contador;
    //Sound CPU
    m6800_0.run(frame_mcu);
    frame_mcu:=frame_mcu+m6800_0.tframes-m6800_0.contador;
    if f=239 then begin
        update_video_baraduke;
        m6809_0.change_irq(ASSERT_LINE);
        m6800_0.change_irq(HOLD_LINE);
        if copy_sprites then copy_sprites_hw;
    end;
  end;
  eventos_baraduke;
  video_sync;
end;
end;

function baraduke_getbyte(direccion:word):byte;
begin
case direccion of
  0..$3fff,$4800..$4fff,$6000..$ffff:baraduke_getbyte:=memoria[direccion];
  $4000..$43ff:baraduke_getbyte:=namco_snd_0.namcos1_cus30_r(direccion and $3ff);
end;
end;

procedure baraduke_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$1ff1,$1ff3..$1fff:memoria[direccion]:=valor;
  $1ff2:begin
             memoria[direccion]:=valor;
             copy_sprites:=true;
        end;
  $2000..$2fff:if memoria[direccion]<>valor then begin
              gfx[1].buffer[(direccion and $fff) shr 1]:=true;
              memoria[direccion]:=valor;
           end;
  $3000..$3fff:if memoria[direccion]<>valor then begin
              gfx[2].buffer[(direccion and $fff) shr 1]:=true;
              memoria[direccion]:=valor;
           end;
  $4000..$43ff:namco_snd_0.namcos1_cus30_w(direccion and $3ff,valor);
  $4800..$4fff:if memoria[direccion]<>valor then begin
                  gfx[0].buffer[direccion and $3ff]:=true;
                  memoria[direccion]:=valor;
           end;
  $8000:; //WD
  $8800:m6809_0.change_irq(CLEAR_LINE);       // irq acknowledge
	$b000:begin
          scroll_x0:=(scroll_x0 and $ff) or (valor shl 8);
          prio:=((scroll_x0 and $e00) shr 9)=6;
        end;
  $b001:scroll_x0:=(scroll_x0 and $ff00) or valor;
  $b002:scroll_y0:=valor;
  $b004:scroll_x1:=(scroll_x1 and $ff) or (valor shl 8);
  $b005:scroll_x1:=(scroll_x1 and $ff00) or valor;
  $b006:scroll_y1:=valor;
  $6000..$7fff,$8001..$87ff,$8801..$afff,$b003,$b007..$ffff:; //ROM
end;
end;

function baraduke_mcu_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$ff:baraduke_mcu_getbyte:=m6800_0.m6803_internal_reg_r(direccion);
  $1000..$1104,$1106..$13ff:baraduke_mcu_getbyte:=namco_snd_0.namcos1_cus30_r(direccion and $3ff);
  $1105:begin
          counter:=counter+1;
          baraduke_mcu_getbyte:=(counter shr 4) and $ff;
        end;
  $8000..$c7ff,$f000..$ffff:baraduke_mcu_getbyte:=mem_snd[direccion];
end;
end;

procedure baraduke_mcu_putbyte(direccion:word;valor:byte);
begin
case direccion of
  $0..$ff:m6800_0.m6803_internal_reg_w(direccion,valor);
  $1000..$13ff:namco_snd_0.namcos1_cus30_w(direccion and $3ff,valor);
  $8000..$bfff,$f000..$ffff:exit;
  $c000..$c7ff:mem_snd[direccion]:=valor;
end;
end;

function in_port1:byte;
var
  ret:byte;
begin
ret:=$ff;
case inputport_selected of
    0:ret:=(marcade.dswa and $f8) shr 3;  //DSWA 0-4
    1:ret:=((marcade.dswa and 7) shl 2) or ((marcade.dswb and $c0) shr 6);  //DSWA 5-7 DSWB 0-1
    2:ret:=(marcade.dswb and $3e) shr 1;  //DSWB 2-6
    3:ret:=((marcade.dswb and 1) shl 4) or (marcade.dswc and $f);  //DSWB 7 DSWC 0-4
    4:ret:=marcade.in0;
    5:ret:=marcade.in2;
    6:ret:=marcade.in1;
  end;
in_port1:=ret;
end;

procedure out_port1(valor:byte);
begin
  if (valor and $e0)=$60 then inputport_selected:=valor and $7;
end;

procedure sound_update_baraduke;
begin
  namco_snd_0.update;
end;

procedure reset_baraduke;
begin
 m6809_0.reset;
 m6800_0.reset;
 namco_snd_0.reset;
 reset_audio;
 marcade.in0:=$1f;
 marcade.in1:=$1f;
 marcade.in2:=$1f;
 scroll_x0:=0;
 scroll_y0:=0;
 scroll_x1:=0;
 scroll_y1:=0;
 copy_sprites:=false;
end;

function iniciar_baraduke:boolean;
var
  colores:tpaleta;
  f:word;
  memoria_temp:array[0..$7ffff] of byte;
const
    pc_x:array[0..7] of dword=(8*8, 8*8+1, 8*8+2, 8*8+3, 0, 1, 2, 3);
    pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
    pt_x:array[0..7] of dword=(0, 1, 2, 3, 8+0, 8+1, 8+2, 8+3);
    pt_y:array[0..7] of dword=(0*8, 2*8, 4*8, 6*8, 8*8, 10*8, 12*8, 14*8);
    ps_x:array[0..15] of dword=(0*4, 1*4, 2*4, 3*4, 4*4, 5*4, 6*4, 7*4,
		8*4, 9*4, 10*4, 11*4, 12*4, 13*4, 14*4, 15*4);
    ps_y:array[0..15] of dword=(8*8*0, 8*8*1, 8*8*2, 8*8*3, 8*8*4, 8*8*5, 8*8*6, 8*8*7,
	8*8*8, 8*8*9, 8*8*10, 8*8*11, 8*8*12, 8*8*13, 8*8*14, 8*8*15);
procedure convert_chars;
begin
  init_gfx(0,8,8,$200);
  gfx[0].trans[3]:=true;
  gfx_set_desc_data(2,0,16*8,0,4);
  convert_gfx(0,0,@memoria_temp,@pc_x,@pc_y,false,false);
end;
procedure convert_tiles;
var
  f:word;
begin
  for f:=$2000 to $3fff do begin
    memoria_temp[$8000+f+$2000]:=memoria_temp[$8000+f];
    memoria_temp[$8000+f+$4000]:=memoria_temp[$8000+f] shl 4;
  end;
  for f:=0 to $1fff do memoria_temp[$8000+f+$2000]:=memoria_temp[$8000+f] shl 4;
  gfx_set_desc_data(3,0,16*8,$8000*8,0,4);
  init_gfx(1,8,8,$400);
  gfx[1].trans[7]:=true;
  convert_gfx(1,0,@memoria_temp[0],@pt_x,@pt_y,false,false);
  init_gfx(2,8,8,$400);
  gfx[2].trans[7]:=true;
  convert_gfx(2,0,@memoria_temp[$4000],@pt_x,@pt_y,false,false);
end;
procedure convert_sprites(num:word);
begin
  init_gfx(3,16,16,num);
  gfx[3].trans[15]:=true;
  gfx_set_desc_data(4,0,128*8,0,1,2,3);
  convert_gfx(3,0,@memoria_temp,@ps_x,@ps_y,false,false);
end;
begin
llamadas_maquina.bucle_general:=baraduke_principal;
llamadas_maquina.reset:=reset_baraduke;
llamadas_maquina.fps_max:=60.606060;
iniciar_baraduke:=false;
iniciar_audio(false);
screen_init(1,288,224,true);
screen_init(2,512,256,true);
screen_mod_scroll(2,512,512,511,256,256,255);
screen_init(3,512,256,true);
screen_mod_scroll(3,512,512,511,256,256,255);
screen_init(4,512,256,false,true);
iniciar_video(288,224);
//Main CPU
m6809_0:=cpu_m6809.Create(49152000 div 32,264,TCPU_M6809);
m6809_0.change_ram_calls(baraduke_getbyte,baraduke_putbyte);
//MCU CPU
m6800_0:=cpu_m6800.create(49152000 div 8,264,TCPU_HD63701);
m6800_0.change_ram_calls(baraduke_mcu_getbyte,baraduke_mcu_putbyte);
m6800_0.change_io_calls(in_port1,nil,nil,nil,out_port1,nil,nil,nil);
m6800_0.init_sound(sound_update_baraduke);
//Sound
namco_snd_0:=namco_snd_chip.create(8,true);
case main_vars.tipo_maquina of
    287:begin
            //cargar roms main CPU
            if not(roms_load(@memoria,baraduke_rom)) then exit;
            //Cargar MCU
            if not(roms_load(@mem_snd,baraduke_mcu)) then exit;
            //convertir chars
            if not(roms_load(@memoria_temp,baraduke_chars)) then exit;
            convert_chars;
            //tiles
            if not(roms_load(@memoria_temp,baraduke_tiles)) then exit;
            convert_tiles;
            //sprites
            if not(roms_load(@memoria_temp,baraduke_sprites)) then exit;
            convert_sprites($200);
            sprite_mask:=$1ff;
            spritex_add:=184;
            spritey_add:=-14;
            //Paleta
            if not(roms_load(@memoria_temp,baraduke_prom)) then exit;
            marcade.dswa:=$ff;
            marcade.dswb:=$ff;
            marcade.dswc:=$ff;
            marcade.dswa_val:=@baraduke_dip_a;
            marcade.dswb_val:=@baraduke_dip_b;
            marcade.dswc_val:=@baraduke_dip_c;
    end;
    288:begin
            //cargar roms main CPU
            if not(roms_load(@memoria,metrocross_rom)) then exit;
            //Cargar MCU
            if not(roms_load(@mem_snd,metrocross_mcu)) then exit;
            //convertir chars
            if not(roms_load(@memoria_temp,metrocross_chars)) then exit;
            convert_chars;
            //tiles
            if not(roms_load(@memoria_temp,metrocross_tiles)) then exit;
            for f:=$8000 to $bfff do memoria_temp[f]:=$ff;
            convert_tiles;
            //sprites
            if not(roms_load(@memoria_temp,metrocross_sprites)) then exit;
            convert_sprites($100);
            sprite_mask:=$ff;
            spritex_add:=-1;
            spritey_add:=-32;
            //Paleta
            if not(roms_load(@memoria_temp,metrocross_prom)) then exit;
            marcade.dswa:=$ff;
            marcade.dswb:=$ff;
            marcade.dswc:=$ff;
            marcade.dswa_val:=@metrocross_dip_a;
            marcade.dswb_val:=@metrocross_dip_b;
            marcade.dswc_val:=@baraduke_dip_c;
    end;
end;
for f:=0 to $7ff do begin
  colores[f].r:=((memoria_temp[f+$800] shr 0) and $01)*$0e+((memoria_temp[f+$800] shr 1) and $01)*$1f+((memoria_temp[f+$800] shr 2) and $01)*$43+((memoria_temp[f+$800] shr 3) and $01)*$8f;
  colores[f].g:=((memoria_temp[f] shr 0) and $01)*$0e+((memoria_temp[f] shr 1) and $01)*$1f+((memoria_temp[f] shr 2) and $01)*$43+((memoria_temp[f] shr 3) and $01)*$8f;
  colores[f].b:=((memoria_temp[f] shr 4) and $01)*$0e+((memoria_temp[f] shr 5) and $01)*$1f+((memoria_temp[f] shr 6) and $01)*$43+((memoria_temp[f] shr 7) and $01)*$8f;
end;
set_pal(colores,$800);
//final
reset_baraduke;
iniciar_baraduke:=true;
end;

end.
