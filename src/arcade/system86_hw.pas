unit system86_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6809,m680x,namco_snd,main_engine,controls_engine,gfx_engine,
     ym_2151,rom_engine,pal_engine,misc_functions,sound_engine;

procedure cargar_system86;

implementation
type
    tipo_update_video_system86=procedure;
const
        //Rolling Thunder
        rthunder_rom:tipo_roms=(n:'rt3_1b.9c';l:$8000;p:$8000;crc:$7d252a1b);
        rthunder_rom_bank:array[0..3] of tipo_roms=(
        (n:'rt1_17.f1';l:$10000;p:0;crc:$766af455),(n:'rt1_18.h1';l:$10000;p:$10000;crc:$3f9f2f5d),
        (n:'rt3_19.k1';l:$10000;p:$20000;crc:$c16675e9),(n:'rt3_20.m1';l:$10000;p:$30000;crc:$c470681b));
        rthunder_sub_rom:array[0..1] of tipo_roms=(
        (n:'rt3_2b.12c';l:$8000;p:$0;crc:$a7ea46ee),(n:'rt3_3.12d';l:$8000;p:$8000;crc:$a13f601c));
        rthunder_chars:array[0..1] of tipo_roms=(
        (n:'rt1_7.7r';l:$10000;p:0;crc:$a85efa39),(n:'rt1_8.7s';l:$8000;p:$10000;crc:$f7a95820));
        rthunder_tiles:array[0..1] of tipo_roms=(
        (n:'rt1_5.4r';l:$8000;p:0;crc:$d0fc470b),(n:'rt1_6.4s';l:$4000;p:$8000;crc:$6b57edb2));
        rthunder_sprites:array[0..7] of tipo_roms=(
        (n:'rt1_9.12h';l:$10000;p:0;crc:$8e070561),(n:'rt1_10.12k';l:$10000;p:$10000;crc:$cb8fb607),
        (n:'rt1_11.12l';l:$10000;p:$20000;crc:$2bdf5ed9),(n:'rt1_12.12m';l:$10000;p:$30000;crc:$e6c6c7dc),
        (n:'rt1_13.12p';l:$10000;p:$40000;crc:$489686d7),(n:'rt1_14.12r';l:$10000;p:$50000;crc:$689e56a8),
        (n:'rt1_15.12t';l:$10000;p:$60000;crc:$1d8bf2ca),(n:'rt1_16.12u';l:$10000;p:$70000;crc:$1bbcf37b));
        rthunder_mcu:array[0..1] of tipo_roms=(
        (n:'rt3_4.6b';l:$8000;p:$4000;crc:$00cf293f),(n:'cus60-60a1.mcu';l:$1000;p:$f000;crc:$076ea82a));
        rthunder_prom:array[0..4] of tipo_roms=(
        (n:'rt1-1.3r';l:$200;p:$0;crc:$8ef3bb9d),(n:'rt1-2.3s';l:$200;p:$200;crc:$6510a8f2),
        (n:'rt1-3.4v';l:$800;p:$400;crc:$95c7d944),(n:'rt1-4.5v';l:$800;p:$c00;crc:$1391fec9),
        (n:'rt1-5.6u';l:$20;p:$1400;crc:$e4130804));
        rthunder_adpcm:array[0..1] of tipo_roms=(
        (n:'rt1_21.f3';l:$10000;p:$0;crc:$454968f3),(n:'rt2_22.h3';l:$10000;p:$20000;crc:$fe963e72));
        //Hopping Mappy
        hopmappy_rom:tipo_roms=(n:'hm1_1.9c';l:$8000;p:$8000;crc:$1a83914e);
        hopmappy_sub_rom:tipo_roms=(n:'hm1_2.12c';l:$4000;p:$c000;crc:$c46cda65);
        hopmappy_chars:tipo_roms=(n:'hm1_6.7r';l:$4000;p:$0;crc:$fd0e8887);
        hopmappy_tiles:tipo_roms=(n:'hm1_5.4r';l:$4000;p:$0;crc:$9c4f31ae);
        hopmappy_sprites:tipo_roms=(n:'hm1_4.12h';l:$8000;p:$0;crc:$78719c52);
        hopmappy_mcu:array[0..1] of tipo_roms=(
        (n:'hm1_3.6b';l:$2000;p:$8000;crc:$6496e1db),(n:'cus60-60a1.mcu';l:$1000;p:$f000;crc:$076ea82a));
        hopmappy_prom:array[0..4] of tipo_roms=(
        (n:'hm1-1.3r';l:$200;p:$0;crc:$cc801088),(n:'hm1-2.3s';l:$200;p:$200;crc:$a1cb71c5),
        (n:'hm1-3.4v';l:$800;p:$400;crc:$e362d613),(n:'hm1-4.5v';l:$800;p:$c00;crc:$678252b4),
        (n:'hm1-5.6u';l:$20;p:$1400;crc:$475bf500));
        //Sky Kid Deluxe
        skykiddx_rom:array[0..1] of tipo_roms=(
        (n:'sk3_1b.9c';l:$8000;p:$0;crc:$767b3514),(n:'sk3_2.9d';l:$8000;p:$8000;crc:$74b8f8e2));
        skykiddx_sub_rom:tipo_roms=(n:'sk3_3.12c';l:$8000;p:$8000;crc:$6d1084c4);
        skykiddx_chars:array[0..1] of tipo_roms=(
        (n:'sk3_9.7r';l:$8000;p:$0;crc:$48675b17),(n:'sk3_10.7s';l:$4000;p:$8000;crc:$7418465a));
        skykiddx_tiles:array[0..1] of tipo_roms=(
        (n:'sk3_7.4r';l:$8000;p:$0;crc:$4036b735),(n:'sk3_8.4s';l:$4000;p:$8000;crc:$044bfd21));
        skykiddx_sprites:array[0..1] of tipo_roms=(
        (n:'sk3_5.12h';l:$8000;p:$0;crc:$5c7d4399),(n:'sk3_6.12k';l:$8000;p:$8000;crc:$c908a3b2));
        skykiddx_mcu:array[0..1] of tipo_roms=(
        (n:'sk3_4.6b';l:$4000;p:$8000;crc:$e6cae2d6),(n:'cus60-60a1.mcu';l:$1000;p:$f000;crc:$076ea82a));
        skykiddx_prom:array[0..4] of tipo_roms=(
        (n:'sk3-1.3r';l:$200;p:$0;crc:$9e81dedd),(n:'sk3-2.3s';l:$200;p:$200;crc:$cbfec4dd),
        (n:'sk3-3.4v';l:$800;p:$400;crc:$81714109),(n:'sk3-4.5v';l:$800;p:$c00;crc:$1bf25acc),
        (n:'sk3-5.6u';l:$20;p:$1400;crc:$e4130804));

var
 rom_bank:array[0..$1f,0..$1fff] of byte;
 rom_sub_bank:array[0..$3,0..$1fff] of byte;
 nchar_prom:array[0..$1f] of byte;
 rom_nbank,rom_sub_nbank,tile_bank,back_color,bank_sprites:byte;
 scroll_y,prior:array[0..3] of byte;
 scroll_x:array[0..3] of word;
 copy_sprites,irq_enable,irq_sub_enable:boolean;
 mask_chars,mask_tiles:word;
 dip_2:byte;
 update_video_system86:tipo_update_video_system86;

procedure draw_sprites(prior:byte;despx,despy:word);inline;
var
  source,finish:word;
  sprite_xoffs,color,nchar:word;
  sprite_yoffs,attr1,attr2:byte;
  priority,sizex,sizey:byte;
  flipx,flipy:boolean;
  tx,ty,x,y:word;
const
  sprite_size:array[0..3] of byte=(16,8,32,4);
begin
	source:=$6000-$20;	// the last is NOT a sprite */
	finish:=$5800;
	sprite_xoffs:=memoria[$5800+$07f5]+((memoria[$5800+$07f4] and $1) shl 8);
	sprite_yoffs:=memoria[$5800+$07f7];
	while (source>=finish) do begin
    priority:=(memoria[finish+14] and $e0) shr 5;
    if priority<>prior then begin
      finish:=finish+$10;
      continue;
    end;
		attr1:=memoria[finish+10];
		attr2:=memoria[finish+14];
		color:=memoria[finish+12];
		flipx:=(attr1 and $20)<>0;
		flipy:=(attr2 and $01)<>0;
		sizex:=sprite_size[(attr1 and $c0) shr 6];
		sizey:=sprite_size[(attr2 and $06) shr 1];
		tx:=attr1 and $18;
		ty:=attr2 and $18;
    if flipx then tx:=(tx-sizex) and $1f;
    if flipy then ty:=(ty-sizey) and $1f;
		x:=(memoria[finish+13]+((color and $01) shl 8))+sprite_xoffs-despx;
		y:=(256-(memoria[finish+15])-sizey)-((sprite_yoffs-despy)+1);
		nchar:=memoria[finish+11] and (bank_sprites-1);
		nchar:=nchar+((attr1 and $7)*bank_sprites);
		color:=(color and $fe) shl 3;
    put_gfx_sprite(nchar,color,flipx,flipy,2);
    actualiza_gfx_sprite_size_pos(x-70,y+8,5,sizex,sizey,tx,ty);
		finish:=finish+$10;
	end;
end;

procedure update_video_screen;inline;
var
        f,color,nchar,offs:word;
        x,y:byte;
begin
fill_full_screen(5,gfx[0].colores[8*back_color+7]);
for f:=0 to $7ff do begin
    x:=f mod 64;
    y:=f div 64;
    //Screen 0
    if gfx[0].buffer[f] then begin
      color:=memoria[$1+(f*2)];
      offs:=((nchar_prom[((0 and 1) shl 4)+((color and $03) shl 2)] and $0e) shr 1)*$100+tile_bank*$800;
      nchar:=memoria[$0+(f*2)]+offs;
      put_gfx_trans(x*8,y*8,(nchar and mask_chars),color shl 3,1,0);
      gfx[0].buffer[f]:=false;
    end;
    //Screen 1
    if gfx[0].buffer[$800+f] then begin
      color:=memoria[$1001+(f*2)];
      offs:=((nchar_prom[((1 and 1) shl 4)+((color and $03) shl 2)] and $0e) shr 1)*$100+tile_bank*$800;
      nchar:=memoria[$1000+(f*2)]+offs;
      put_gfx_trans(x*8,y*8,(nchar and mask_chars),color shl 3,2,0);
      gfx[0].buffer[$800+f]:=false;
    end;
    //Screen 2
    if gfx[1].buffer[f] then begin
      color:=memoria[$2001+(f*2)];
      offs:=((nchar_prom[((2 and 1) shl 4)+(color and $03)] and $e0) shr 5)*$100;
      nchar:=memoria[$2000+(f*2)]+offs;
      put_gfx_trans(x*8,y*8,(nchar and mask_tiles),color shl 3,3,1);
      gfx[1].buffer[f]:=false;
    end;
    //Screen 3
    if gfx[1].buffer[$800+f] then begin
      color:=memoria[$3001+(f*2)];
      offs:=((nchar_prom[((3 and 1) shl 4)+(color and $03)] and $e0) shr 5)*$100;
      nchar:=memoria[$3000+(f*2)]+offs;
      put_gfx_trans(x*8,y*8,(nchar and mask_tiles),color shl 3,4,1);
      gfx[1].buffer[$800+f]:=false;
    end;
end;
end;

procedure skykiddx_video;
const
  diff_x2:array[0..3] of byte=(19,18,21,20);
  diff_y2:array[0..3] of byte=(1,16,0,0);
var
  layer,f:byte;
begin
update_video_screen;
for layer:=0 to 7 do begin
  for f:=3 downto 0 do begin
    if (prior[f]=layer) then begin
      scroll_x_y(f+1,5,224-(scroll_x[f]+diff_x2[f]),scroll_y[f]-diff_y2[f]);
    end;
  end;
  draw_sprites(layer,88,2);
end;
actualiza_trozo_final(0,25,288,224,5);
end;

procedure rthunder_video;
var
  layer,f:byte;
const
  diff_x:array[0..3] of byte=(20,18,21,19);
begin
update_video_screen;
for layer:=0 to 7 do begin
  for f:=3 downto 0 do begin
    if (prior[f]=layer) then begin
      scroll_x_y(f+1,5,scroll_x[f]+diff_x[f],scroll_y[f]);
    end;
  end;
  draw_sprites(layer,0,3);
end;
actualiza_trozo_final(0,25,288,224,5);
end;


procedure eventos_system86;
begin
if event.arcade then begin
  //marcade.in0
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.down[1] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.right[1] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  //marcade.in1
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.coin[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  //marcade.in2
  if arcade_input.but0[0] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.left[0] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.right[0] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $bf) else marcade.in2:=(marcade.in2 or $40);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $7f) else marcade.in2:=(marcade.in2 or $80);
end;
end;

procedure copy_sprites_hw;inline;
var
  i,j:byte;
begin
for i:=0 to $7f do begin
  for j:=10 to 15 do memoria[$5800+(i*$10)+j]:=memoria[$5800+(i*$10)+j-6];
end;
copy_sprites:=false;
end;

procedure system86_principal;
var
  f:byte;
  frame_m,frame_s,frame_mcu:single;
begin
init_controls(false,false,false,true);
frame_m:=m6809_0.tframes;
frame_s:=m6809_1.tframes;
frame_mcu:=m6800_0.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
    //Main CPU
    m6809_0.run(frame_m);
    frame_m:=frame_m+m6809_0.tframes-m6809_0.contador;
    //Sub CPU
    m6809_1.run(frame_s);
    frame_s:=frame_s+m6809_1.tframes-m6809_1.contador;
    //Sound CPU
    m6800_0.run(frame_mcu);
    frame_mcu:=frame_mcu+m6800_0.tframes-m6800_0.contador;
    if f=239 then begin
        update_video_system86;
        if irq_enable then m6809_0.change_irq(ASSERT_LINE);
        if irq_sub_enable then m6809_1.change_irq(ASSERT_LINE);
        m6800_0.change_irq(HOLD_LINE);
        if copy_sprites then copy_sprites_hw;
    end;
  end;
  eventos_system86;
  video_sync;
end;
end;

function system86_getbyte(direccion:word):byte;
begin
case direccion of
  0..$3fff,$4400..$5fff,$8000..$ffff:system86_getbyte:=memoria[direccion];
  $4000..$43ff:system86_getbyte:=namco_snd_0.namcos1_cus30_r(direccion and $3ff);
  $6000..$7fff:system86_getbyte:=rom_bank[rom_nbank,direccion and $1fff];
end;
end;

procedure system86_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$1fff:if memoria[direccion]<>valor then begin
              gfx[0].buffer[direccion shr 1]:=true;
              memoria[direccion]:=valor;
           end;
  $2000..$3fff:if memoria[direccion]<>valor then begin
              gfx[1].buffer[(direccion and $1fff) shr 1]:=true;
              memoria[direccion]:=valor;
           end;
  $4000..$43ff:namco_snd_0.namcos1_cus30_w(direccion and $3ff,valor);
  $4400..$5ff1,$5ff3..$5fff:memoria[direccion]:=valor;
  $5ff2:begin
            copy_sprites:=true;
            memoria[direccion]:=valor;
        end;
  $8400:m6809_0.change_irq(CLEAR_LINE);
  $8800..$8fff:tile_bank:=bit_n(direccion,10);
  $9000:begin
          prior[0]:=(valor and $e) shr 1;
          scroll_x[0]:=(scroll_x[0] and $ff) or ((valor and 1) shl 8);
        end;
  $9001:scroll_x[0]:=(scroll_x[0] and $ff00) or valor;
  $9002:scroll_y[0]:=valor;
  $9003:rom_nbank:=valor and $3;
  $9004:begin
          prior[1]:=(valor and $e) shr 1;
          scroll_x[1]:=(scroll_x[1] and $ff) or ((valor and 1) shl 8);
        end;
  $9005:scroll_x[1]:=(scroll_x[1] and $ff00) or valor;
  $9006:scroll_y[1]:=valor;
  $9400:begin
          prior[2]:=(valor and $e) shr 1;
          scroll_x[2]:=(scroll_x[2] and $ff) or ((valor and 1) shl 8);
        end;
  $9401:scroll_x[2]:=(scroll_x[2] and $ff00) or valor;
  $9402:scroll_y[2]:=valor;
  $9404:begin
          prior[3]:=(valor and $e) shr 1;
          scroll_x[3]:=(scroll_x[3] and $ff) or ((valor and 1) shl 8);
        end;
  $9405:scroll_x[3]:=(scroll_x[3] and $ff00) or valor;
  $9406:scroll_y[3]:=valor;
  $a000:back_color:=valor;
  //TODO LO DEMAS ROM
end;
end;

//Rolling Thunder
procedure rthunder_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$1fff:if memoria[direccion]<>valor then begin
              gfx[0].buffer[direccion shr 1]:=true;
              memoria[direccion]:=valor;
           end;
  $2000..$3fff:if memoria[direccion]<>valor then begin
              gfx[1].buffer[(direccion and $1fff) shr 1]:=true;
              memoria[direccion]:=valor;
           end;
  $4000..$43ff:namco_snd_0.namcos1_cus30_w(direccion and $3ff,valor);
  $4400..$5fff:begin
                  memoria[direccion]:=valor;
                  if direccion=$5ff2 then copy_sprites:=true;
               end;
  $6000..$7fff:case ((direccion and $1e00) shr 9) of
    		            0,1,2,3:namco_63701x_w((direccion and $1e00) shr 9,valor);
		                4:rom_nbank:=valor and $1f;
               end;
  $8400:m6809_0.change_irq(CLEAR_LINE);
  $8800..$8fff:tile_bank:=bit_n(direccion,10);
  $9000:begin
          prior[0]:=(valor and $e) shr 1;
          scroll_x[0]:=(scroll_x[0] and $ff) or ((valor and 1) shl 8);
        end;
  $9001:scroll_x[0]:=(scroll_x[0] and $ff00) or valor;
  $9002:scroll_y[0]:=valor;
  $9004:begin
          prior[1]:=(valor and $e) shr 1;
          scroll_x[1]:=(scroll_x[1] and $ff) or ((valor and 1) shl 8);
        end;
  $9005:scroll_x[1]:=(scroll_x[1] and $ff00) or valor;
  $9006:scroll_y[1]:=valor;
  $9400:begin
          prior[2]:=(valor and $e) shr 1;
          scroll_x[2]:=(scroll_x[2] and $ff) or ((valor and 1) shl 8);
        end;
  $9401:scroll_x[2]:=(scroll_x[2] and $ff00) or valor;
  $9402:scroll_y[2]:=valor;
  $9404:begin
          prior[3]:=(valor and $e) shr 1;
          scroll_x[3]:=(scroll_x[3] and $ff) or ((valor and 1) shl 8);
        end;
  $9405:scroll_x[3]:=(scroll_x[3] and $ff00) or valor;
  $9406:scroll_y[3]:=valor;
  $a000:back_color:=valor;
end;
end;

function rthunder_sub_getbyte(direccion:word):byte;
begin
case direccion of
  0..$1fff:rthunder_sub_getbyte:=memoria[$4000+direccion]; //sprite ram
  $2000..$3fff:rthunder_sub_getbyte:=memoria[$0+(direccion and $1fff)];  //video 1 ram
  $4000..$5fff:rthunder_sub_getbyte:=memoria[$2000+(direccion and $1fff)]; //video 2 ram
  $6000..$7fff:rthunder_sub_getbyte:=rom_sub_bank[rom_sub_nbank,direccion and $1fff];
  $8000..$ffff:rthunder_sub_getbyte:=mem_misc[direccion];
end;
end;

procedure rthunder_sub_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$1fff:begin  //sprite ram
              memoria[$4000+direccion]:=valor;
              if direccion=$1ff2 then copy_sprites:=true;
           end;
  $2000..$3fff:if memoria[$0+(direccion and $1fff)]<>valor then begin  //video 1 ram
                  memoria[$0+(direccion and $1fff)]:=valor;
                  gfx[0].buffer[(direccion and $1fff) shr 1]:=true;
               end;
  $4000..$5fff:if memoria[$2000+(direccion and $1fff)]<>valor then begin //video 2 ram
                  memoria[$2000+(direccion and $1fff)]:=valor;
                  gfx[1].buffer[(direccion and $1fff) shr 1]:=true;
               end;
  $8800:m6809_1.change_irq(CLEAR_LINE);
  $d803:rom_sub_nbank:=valor and $3;
end;
end;

function rthunder_mcu_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$ff:rthunder_mcu_getbyte:=m6800_0.m6803_internal_reg_r(direccion);
  $1000..$13ff:rthunder_mcu_getbyte:=namco_snd_0.namcos1_cus30_r(direccion and $3ff);
  $1400..$1fff,$4000..$bfff,$f000..$ffff:rthunder_mcu_getbyte:=mem_snd[direccion];
  $2001:rthunder_mcu_getbyte:=ym2151_0.status;
  $2020:rthunder_mcu_getbyte:=marcade.in0;
  $2021:rthunder_mcu_getbyte:=marcade.in1;
  $2030:rthunder_mcu_getbyte:=$ff;
  $2031:rthunder_mcu_getbyte:=dip_2;
end;
end;

procedure rthunder_mcu_putbyte(direccion:word;valor:byte);
begin
case direccion of
  $0..$ff:m6800_0.m6803_internal_reg_w(direccion,valor);
  $1000..$13ff:namco_snd_0.namcos1_cus30_w(direccion and $3ff,valor);
  $1400..$1fff:mem_snd[direccion]:=valor;
  $2000:ym2151_0.reg(valor);
  $2001:ym2151_0.write(valor);
  $4000..$bfff,$f000..$ffff:exit;
end;
end;

//Hopping Mappy
function hopmappy_sub_getbyte(direccion:word):byte;
begin
case direccion of
  $4000..$5fff:hopmappy_sub_getbyte:=memoria[direccion];
    else hopmappy_sub_getbyte:=mem_misc[direccion];
end;
end;

procedure hopmappy_sub_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$3fff:mem_misc[direccion]:=valor;
  $4000..$5fff:begin
                  memoria[direccion]:=valor;
                  if direccion=$5ff2 then copy_sprites:=true;
               end;
  $9400:m6809_1.change_irq(CLEAR_LINE);
end;
end;

//Misc Funcitions
function in_port1:byte;
begin
  in_port1:=marcade.in2;
end;

function in_port2:byte;
begin
  in_port2:=$ff;
end;

procedure sound_update_rthunder;
begin
  ym2151_0.update;
  namco_snd_0.update;
end;

procedure sound_update_adpcm;
begin
  ym2151_0.update;
  namco_63701x_update;
  namco_snd_0.update;
end;

//Main
procedure reset_system86;
var
  f:byte;
begin
 m6809_0.reset;
 m6809_1.reset;
 m6800_0.reset;
 namco_snd_0.reset;
 ym2151_0.reset;
 if main_vars.tipo_maquina=124 then namco_63701x_reset;
 reset_audio;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$f;
 rom_nbank:=0;
 rom_sub_nbank:=0;
 for f:=0 to 3 do scroll_y[f]:=0;
 for f:=0 to 3 do scroll_x[0]:=0;
 for f:=0 to 3 do prior[f]:=0;
 tile_bank:=0;
 copy_sprites:=false;
 irq_enable:=true;
 irq_sub_enable:=true;
end;

function iniciar_system86:boolean;
var
  colores:tpaleta;
  f:word;
  memoria_temp:array[0..$7ffff] of byte;
const
    pc_x:array[0..7] of dword=(0, 1, 2, 3, 4, 5, 6, 7);
    pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
    ps_x:array[0..31] of dword=(0*4, 1*4, 2*4, 3*4, 4*4, 5*4, 6*4, 7*4,
 			8*4, 9*4, 10*4, 11*4, 12*4, 13*4, 14*4, 15*4,
			16*64+0*4, 16*64+1*4, 16*64+2*4, 16*64+3*4, 16*64+4*4, 16*64+5*4, 16*64+6*4, 16*64+7*4,
			16*64+8*4, 16*64+9*4, 16*64+10*4, 16*64+11*4, 16*64+12*4, 16*64+13*4, 16*64+14*4, 16*64+15*4);
    ps_y:array[0..31] of dword=(0*64, 1*64, 2*64, 3*64, 4*64, 5*64, 6*64, 7*64,
			8*64, 9*64, 10*64, 11*64, 12*64, 13*64, 14*64, 15*64,
			32*64, 33*64, 34*64, 35*64, 36*64, 37*64, 38*64, 39*64,
			40*64, 41*64, 42*64, 43*64, 44*64, 45*64, 46*64, 47*64);
procedure convert_data(long:dword);
var
  size,i:dword;
  dest1,dest2,mono:dword;
  buffer:array[0..$1ffff] of byte;
  data1,data2:byte;
begin
  size:=(long*2) div 3;
	dest1:=0;
	dest2:=0+(size div 2);
  mono:=0+size;
  copymemory(@buffer[0],@memoria_temp[0],size);
  for i:=0 to ((size div 2)-1) do begin
			data1:=buffer[i*2];
			data2:=buffer[(i*2)+1];
			memoria_temp[dest1]:=(data1 shl 4) or (data2 and $f);
      dest1:=dest1+1;
			memoria_temp[dest2]:=(data1 and $f0) or (data2 shr 4);
      dest2:=dest2+1;
      memoria_temp[mono]:=memoria_temp[mono] xor $ff;
      mono:=mono+1;
  end;
end;
procedure convert_chars(num:word);
begin
  mask_chars:=num-1;
  init_gfx(0,8,8,num);
  gfx[0].trans[7]:=true;
  gfx_set_desc_data(3,0,8*8,2*num*8*8,num*8*8,0);
  convert_gfx(0,0,@memoria_temp,@pc_x,@pc_y,false,false);
end;
procedure convert_tiles(num:word);
begin
  mask_tiles:=num-1;
  init_gfx(1,8,8,num);
  gfx[1].trans[7]:=true;
  gfx_set_desc_data(3,0,8*8,2*num*8*8,num*8*8,0);
  convert_gfx(1,0,@memoria_temp,@pc_x,@pc_y,false,false);
end;
procedure convert_sprites(num:word);
begin
  init_gfx(2,32,32,num);
  gfx[2].trans[15]:=true;
  gfx_set_desc_data(4,0,64*64,0,1,2,3);
  convert_gfx(2,0,@memoria_temp,@ps_x,@ps_y,false,false);
  bank_sprites:=num div 8;
end;
begin
iniciar_system86:=false;
iniciar_audio(false);
screen_init(1,512,256,true);
screen_mod_scroll(1,512,512,511,256,256,255);
screen_init(2,512,256,true);
screen_mod_scroll(2,512,512,511,256,256,255);
screen_init(3,512,256,true);
screen_mod_scroll(3,512,512,511,256,256,255);
screen_init(4,512,256,true);
screen_mod_scroll(4,512,512,511,256,256,255);
screen_init(5,512,256,false,true);
iniciar_video(288,224);
//Main CPU
m6809_0:=cpu_m6809.Create(1536000,256,TCPU_M6809);
//Sub CPU
m6809_1:=cpu_m6809.Create(1536000,256,TCPU_M6809);
//MCU CPU
m6800_0:=cpu_m6800.create(6144000,$100,TCPU_HD63701);
m6800_0.change_ram_calls(rthunder_mcu_getbyte,rthunder_mcu_putbyte);
m6800_0.change_io_calls(in_port1,in_port2,nil,nil,nil,nil,nil,nil);
if main_vars.tipo_maquina<>124 then m6800_0.init_sound(sound_update_rthunder)
  else m6800_0.init_sound(sound_update_adpcm);
//Sound
namco_snd_0:=namco_snd_chip.create(8,true);
ym2151_0:=ym2151_chip.create(3579580,0.4);
case main_vars.tipo_maquina of
    124:begin
            //cargar roms main CPU
            if not(roms_load(@memoria,rthunder_rom)) then exit;
            m6809_0.change_ram_calls(system86_getbyte,rthunder_putbyte);
            //Pongo las ROMs en su banco
            if not(roms_load(@memoria_temp,rthunder_rom_bank)) then exit;
            for f:=0 to $1f do copymemory(@rom_bank[f,0],@memoria_temp[f*$2000],$2000);
            //cargar roms sub CPU
            if not(roms_load(@memoria_temp,rthunder_sub_rom)) then exit;
            m6809_1.change_ram_calls(rthunder_sub_getbyte,rthunder_sub_putbyte);
            //Pongo las ROMs en su banco
            copymemory(@mem_misc[$8000],@memoria_temp[$0],$8000);
            for f:=0 to $3 do copymemory(@rom_sub_bank[f,0],@memoria_temp[(f*$2000)+$8000],$2000);
            //Cargar MCU
            if not(roms_load(@mem_snd,rthunder_mcu)) then exit;
            //Cargar ADPCM
            namco_63701x_start(6000000);
            if not(roms_load(namco_63701_rom,rthunder_adpcm)) then exit;
            //convertir chars
            if not(roms_load(@memoria_temp,rthunder_chars)) then exit;
            convert_data($18000);
            convert_chars($1000);
            //tiles
            if not(roms_load(@memoria_temp,rthunder_tiles)) then exit;
            convert_data($c000);
            convert_tiles($800);
            //sprites
            if not(roms_load(@memoria_temp,rthunder_sprites)) then exit;
            convert_sprites($400);
            //Paleta
            if not(roms_load(@memoria_temp,rthunder_prom)) then exit;
            dip_2:=$f9;
            update_video_system86:=rthunder_video;
    end;
    125:begin
            //cargar roms main CPU
            if not(roms_load(@memoria,hopmappy_rom)) then exit;
            m6809_0.change_ram_calls(system86_getbyte,system86_putbyte);
            //cargar roms sub CPU
            if not(roms_load(@mem_misc,hopmappy_sub_rom)) then exit;
            m6809_1.change_ram_calls(hopmappy_sub_getbyte,hopmappy_sub_putbyte);
            //Cargar MCU
            if not(roms_load(@mem_snd,hopmappy_mcu)) then exit;
            //convertir chars
            fillchar(memoria_temp[0],$6000,0);
            if not(roms_load(@memoria_temp,hopmappy_chars)) then exit;
            convert_data($6000);
            init_gfx(0,8,8,$400);
            convert_chars($400);
            //tiles
            fillchar(memoria_temp[0],$6000,0);
            if not(roms_load(@memoria_temp,hopmappy_tiles)) then exit;
            convert_data($6000);
            convert_tiles($400);
            //sprites
            if not(roms_load(@memoria_temp,hopmappy_sprites)) then exit;
            convert_sprites($200);
            //Paleta
            if not(roms_load(@memoria_temp,hopmappy_prom)) then exit;
            dip_2:=$ff;
            update_video_system86:=rthunder_video;
    end;
    126:begin
            //cargar roms main CPU
            if not(roms_load(@memoria_temp,skykiddx_rom)) then exit;
            copymemory(@memoria[$8000],@memoria_temp[0],$8000);
            for f:=0 to 3 do copymemory(@rom_bank[f,0],@memoria_temp[$8000+(f*$2000)],$2000);
            m6809_0.change_ram_calls(system86_getbyte,system86_putbyte);
            //cargar roms sub CPU
            if not(roms_load(@mem_misc,skykiddx_sub_rom)) then exit;
            m6809_1.change_ram_calls(hopmappy_sub_getbyte,hopmappy_sub_putbyte);
            //Cargar MCU
            if not(roms_load(@mem_snd,skykiddx_mcu)) then exit;
            //convertir chars
            if not(roms_load(@memoria_temp,skykiddx_chars)) then exit;
            convert_data($c000);
            convert_chars($800);
            //tiles
            if not(roms_load(@memoria_temp,skykiddx_tiles)) then exit;
            convert_data($c000);
            convert_tiles($800);
            //sprites
            if not(roms_load(@memoria_temp,skykiddx_sprites)) then exit;
            convert_sprites($200);
            //Paleta
            if not(roms_load(@memoria_temp,skykiddx_prom)) then exit;
            dip_2:=$ff;
            update_video_system86:=skykiddx_video;
    end;
end;
for f:=0 to $1ff do begin
  colores[f].r:=((memoria_temp[f] shr 0) and $01)*$0e+((memoria_temp[f] shr 1) and $01)*$1f+((memoria_temp[f] shr 2) and $01)*$43+((memoria_temp[f] shr 3) and $01)*$8f;
  colores[f].g:=((memoria_temp[f] shr 4) and $01)*$0e+((memoria_temp[f] shr 5) and $01)*$1f+((memoria_temp[f] shr 6) and $01)*$43+((memoria_temp[f] shr 7) and $01)*$8f;
  colores[f].b:=((memoria_temp[f+$200] shr 0) and $01)*$0e+((memoria_temp[f+$200] shr 1) and $01)*$1f+((memoria_temp[f+$200] shr 2) and $01)*$43+((memoria_temp[f+$200] shr 3) and $01)*$8f;
end;
set_pal(colores,$200);
// tiles/sprites color table
for f:=$0 to $7ff do begin
  gfx[0].colores[f]:=memoria_temp[$400+f];
  gfx[1].colores[f]:=memoria_temp[$400+f];
  gfx[2].colores[f]:=memoria_temp[$400+$800+f];
end;
//color prom used at run time
copymemory(@nchar_prom[0],@memoria_temp[$1400],$20);
//final
reset_system86;
iniciar_system86:=true;
end;

procedure cerrar_system86;
begin
if main_vars.tipo_maquina=124 then namco_63701x_close;
end;

procedure Cargar_system86;
begin
llamadas_maquina.iniciar:=iniciar_system86;
llamadas_maquina.bucle_general:=system86_principal;
llamadas_maquina.close:=cerrar_system86;
llamadas_maquina.reset:=reset_system86;
llamadas_maquina.fps_max:=60.606060;
end;

end.
