unit skykid_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6809,m680x,namco_snd,main_engine,controls_engine,gfx_engine,rom_engine,
     pal_engine,misc_functions,sound_engine;

procedure cargar_skykid;

implementation
const
        //Sky Kid
        skykid_rom:array[0..2] of tipo_roms=(
        (n:'sk2_2.6c';l:$4000;p:$0;crc:$ea8a5822),(n:'sk1-1c.6b';l:$4000;p:$4000;crc:$7abe6c6c),
        (n:'sk1_3.6d';l:$4000;p:$8000;crc:$314b8765));
        skykid_char:tipo_roms=(n:'sk1_6.6l';l:$2000;p:0;crc:$58b731b9);
        skykid_tiles:tipo_roms=(n:'sk1_5.7e';l:$2000;p:0;crc:$c33a498e);
        skykid_sprites:array[0..1] of tipo_roms=(
        (n:'sk1_8.10n';l:$4000;p:0;crc:$44bb7375),(n:'sk1_7.10m';l:$4000;p:$4000;crc:$3454671d));
        skykid_mcu:array[0..1] of tipo_roms=(
        (n:'sk2_4.3c';l:$2000;p:$8000;crc:$a460d0e0),(n:'cus63-63a1.mcu';l:$1000;p:$f000;crc:$6ef08fb3));
        skykid_prom:array[0..4] of tipo_roms=(
        (n:'sk1-1.2n';l:$100;p:$0;crc:$0218e726),(n:'sk1-2.2p';l:$100;p:$100;crc:$fc0d5b85),
        (n:'sk1-3.2r';l:$100;p:$200;crc:$d06b620b),(n:'sk1-4.5n';l:$200;p:$300;crc:$c697ac72),
        (n:'sk1-5.6n';l:$200;p:$500;crc:$161514a4));
        //Dragon Buster
        drgnbstr_rom:array[0..2] of tipo_roms=(
        (n:'db1_2b.6c';l:$4000;p:$0;crc:$0f11cd17),(n:'db1_1.6b';l:$4000;p:$4000;crc:$1c7c1821),
        (n:'db1_3.6d';l:$4000;p:$8000;crc:$6da169ae));
        drgnbstr_char:tipo_roms=(n:'db1_6.6l';l:$2000;p:0;crc:$c080b66c);
        drgnbstr_tiles:tipo_roms=(n:'db1_5.7e';l:$2000;p:0;crc:$28129aed);
        drgnbstr_sprites:array[0..1] of tipo_roms=(
        (n:'db1_8.10n';l:$4000;p:0;crc:$11942c61),(n:'db1_7.10m';l:$4000;p:$4000;crc:$cc130fe2));
        drgnbstr_mcu:array[0..1] of tipo_roms=(
        (n:'db1_4.3c';l:$2000;p:$8000;crc:$8a0b1fc1),(n:'cus60-60a1.mcu';l:$1000;p:$f000;crc:$076ea82a));
        drgnbstr_prom:array[0..4] of tipo_roms=(
        (n:'db1-1.2n';l:$100;p:$0;crc:$3f8cce97),(n:'db1-2.2p';l:$100;p:$100;crc:$afe32436),
        (n:'db1-3.2r';l:$100;p:$200;crc:$c95ff576),(n:'db1-4.5n';l:$200;p:$300;crc:$b2180c21),
        (n:'db1-5.6n';l:$200;p:$500;crc:$5e2b3f74));

var
 rom_bank:array[0..1,0..$1fff] of byte;
 rom_nbank,scroll_y,inputport_selected,priority:byte;
 scroll_x:word;
 irq_enable,irq_enable_mcu,screen_flip:boolean;

procedure update_video_skykid;
procedure draw_sprites;
var
  nchar,color,x:word;
  f,flipx_v,flipy_v,atrib,y,size,a,b,c,d,mix:byte;
  flipx,flipy:boolean;
begin
	for f:=0 to $3f do begin
    atrib:=memoria[$5f80+(f*2)];
		nchar:=memoria[$4f80+(f*2)]+((atrib and $80) shl 1);
		color:=((memoria[$4f81+(f*2)] and $3f) shl 3)+$200;
    flipx_v:=not(atrib) and $01;
		flipy_v:=not(atrib) and $02;
    flipx:=(flipx_v=0);
    flipy:=(flipy_v=0);
    if screen_flip then begin
  		x:=((memoria[$5781+(f*2)]+(memoria[$5f81+(f*2)] and 1) shl 8)-71) and $1ff;
	  	y:=((256-memoria[$5780+(f*2)]-7) and $ff)-32;
      if (atrib and $8)<>0 then y:=y-16;
    end else begin
      x:=(327-(memoria[$5781+(f*2)]+(memoria[$5f81+(f*2)] and 1) shl 8)) and $1ff;
		  y:=(memoria[$5780+(f*2)])-9;
      if (atrib and $4)=0 then x:=x+16;
    end;
    size:=(atrib and $c) shr 2;
    case size of
      0:begin //16x16
          put_gfx_sprite_mask(nchar,color,flipx,flipy,1,$f,$f);
          actualiza_gfx_sprite(x,y,3,1);
        end;
      1:begin //32x16
          a:=1 xor flipx_v;
          b:=0 xor flipx_v;
          put_gfx_sprite_mask_diff(nchar+a,color,flipx,flipy,1,15,$f,0,0);
          put_gfx_sprite_mask_diff(nchar+b,color,flipx,flipy,1,15,$f,16,0);
          actualiza_gfx_sprite_size(x,y,3,32,16);
        end;
      2:begin //16x32
            a:=2 xor flipy_v;
            b:=0 xor flipy_v;
            put_gfx_sprite_mask_diff(nchar+a,color,flipx,flipy,1,15,$f,0,0);
            put_gfx_sprite_mask_diff(nchar+b,color,flipx,flipy,1,15,$f,0,16);
            actualiza_gfx_sprite_size(x,y,3,16,32);
        end;
      3:begin //32x32
            if flipx then begin
              a:=1;b:=0;c:=3;d:=2
            end else begin
              a:=0;b:=1;c:=2;d:=3;
            end;
            if flipy then begin
              mix:=a;a:=c;c:=mix;
              mix:=b;b:=d;d:=mix;
            end;
            put_gfx_sprite_mask_diff(nchar+a,color,flipx,flipy,1,15,$f,0,0);
            put_gfx_sprite_mask_diff(nchar+b,color,flipx,flipy,1,15,$f,16,0);
            put_gfx_sprite_mask_diff(nchar+c,color,flipx,flipy,1,15,$f,0,16);
            put_gfx_sprite_mask_diff(nchar+d,color,flipx,flipy,1,15,$f,16,16);
            actualiza_gfx_sprite_size(x,y,3,32,32);
         end;
    end;
	end;
end;

var
  f,color,nchar,offs:word;
  x,y,sx,sy,atrib:byte;
begin
for x:=0 to 27 do begin
  for y:=0 to 35 do begin
     sx:=x+2;
     sy:=y-2;
	   if (sy and $20)<>0 then offs:=sx+((sy and $1f) shl 5)
	    else offs:=sy+(sx shl 5);
     if gfx[0].buffer[offs] then begin
       color:=((memoria[$4400+offs]) and $3f) shl 2;
       put_gfx_trans(y*8,x*8,memoria[$4000+offs],color,1,0);
       gfx[0].buffer[offs]:=false;
     end;
  end;
end;
for f:=0 to $7ff do begin
  if gfx[2].buffer[f] then begin
    x:=f mod 64;
    y:=f div 64;
    atrib:=memoria[$2800+f];
    color:=(((atrib and $7e) shr 1)+((atrib and $01) shl 6)) shl 2;
    nchar:=memoria[$2000+f]+(atrib and $1) shl 8;
    put_gfx(x*8,y*8,nchar,color,2,2);
    gfx[2].buffer[f]:=false;
  end;
end;
scroll_x_y(2,3,scroll_x,scroll_y);
if (priority and $f0)<>$50 then begin
  draw_sprites;
  actualiza_trozo(0,0,288,224,1,0,0,288,224,3);
end else begin
  actualiza_trozo(0,0,288,224,1,0,0,288,224,3);
  draw_sprites;
end;
actualiza_trozo_final(0,0,288,224,3);
end;

procedure eventos_skykid;
begin
if event.arcade then begin
  //P1
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in3:=(marcade.in3 and $f7) else marcade.in3:=(marcade.in3 or $8);
  //P2
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[1] then marcade.in3:=(marcade.in3 and $fb) else marcade.in3:=(marcade.in3 or $4);
  //COIN
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
end;
end;

procedure skykid_principal;
var
  f:byte;
  frame_m,frame_mcu:single;
begin
init_controls(false,false,false,true);
frame_m:=m6809_0.tframes;
frame_mcu:=m6800_0.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to 223 do begin
    //Main CPU
    m6809_0.run(frame_m);
    frame_m:=frame_m+m6809_0.tframes-m6809_0.contador;
    //Sound CPU
    m6800_0.run(frame_mcu);
    frame_mcu:=frame_mcu+m6800_0.tframes-m6800_0.contador;
  end;
  if irq_enable then m6809_0.change_irq(ASSERT_LINE);
  if irq_enable_mcu then m6800_0.change_irq(ASSERT_LINE);
  update_video_skykid;
  eventos_skykid;
  video_sync;
end;
end;

function skykid_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$1fff:skykid_getbyte:=rom_bank[rom_nbank,direccion];
  $2000..$2fff,$4000..$5fff,$8000..$ffff:skykid_getbyte:=memoria[direccion];
  $6800..$6bff:skykid_getbyte:=namco_snd_0.namcos1_cus30_r(direccion and $3ff);
end;
end;

procedure skykid_putbyte(direccion:word;valor:byte);
begin
case direccion of
  $0..$1fff,$a002..$ffff:; //ROM
  $2000..$2fff:if memoria[direccion]<>valor then begin
                  gfx[2].buffer[direccion and $7ff]:=true;
                  memoria[direccion]:=valor;
               end;
  $4000..$47ff:if memoria[direccion]<>valor then begin
                  gfx[0].buffer[direccion and $3ff]:=true;
                  memoria[direccion]:=valor;
               end;
  $4800..$5fff:memoria[direccion]:=valor;
  $6000..$60ff:begin
                  scroll_y:=direccion and $ff;
                  if screen_flip then scroll_y:=(scroll_y+25) and $ff
                    else scroll_y:=(7-scroll_y) and $ff;
               end;
  $6200..$63ff:begin
                  scroll_x:=direccion and $1ff;
                  if screen_flip then scroll_x:=(scroll_x+35) and $1ff
                    else scroll_x:=(189-(scroll_x xor 1)) and $1ff;
               end;
  $6800..$6bff:namco_snd_0.namcos1_cus30_w(direccion and $3ff,valor);
  $7000..$7fff:begin
                   irq_enable:=not(BIT((direccion and $fff),11));
                   if not(irq_enable) then m6809_0.change_irq(CLEAR_LINE);
               end;
  $8000..$8fff:if not(BIT((direccion and $fff),11)) then m6800_0.reset;
  $9000..$9fff:rom_nbank:=(not(BIT_n((direccion and $fff),11))) and 1;
  $a000..$a001:priority:=valor;
end;
end;

function mcu_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$ff:mcu_getbyte:=m6800_0.m6803_internal_reg_r(direccion);
  $1000..$13ff:mcu_getbyte:=namco_snd_0.namcos1_cus30_r(direccion and $3ff);
  $8000..$c7ff,$f000..$ffff:mcu_getbyte:=mem_snd[direccion];
end;
end;

procedure mcu_putbyte(direccion:word;valor:byte);
begin
case direccion of
  $0..$ff:m6800_0.m6803_internal_reg_w(direccion,valor);
  $1000..$13ff:namco_snd_0.namcos1_cus30_w(direccion and $3ff,valor);
  $4000..$7fff:begin
                  irq_enable_mcu:=not(BIT(direccion and $3fff,13));
                  if not(irq_enable_mcu) then m6800_0.change_irq(CLEAR_LINE);
               end;
  $8000..$bfff,$f000..$ffff:; //ROM
  $c000..$cfff:mem_snd[direccion]:=valor;
end;
end;

procedure skykid_sound_update;
begin
  namco_snd_0.update;
end;

procedure out_port1(valor:byte);
begin
if ((valor and $e0)=$60) then inputport_selected:=valor and $07;
end;

function in_port1:byte;
begin
  case inputport_selected of
		$00:in_port1:=(($ff) and $f8) shr 3;	// DSW B (bits 0-4) */
		$01:in_port1:=((($ff) and $7) shl 2) or ((($ff) and $c0) shr 6);// DSW B (bits 5-7), DSW A (bits 0-1) */
		$02:in_port1:=(($ff) and $3e) shr 1;	// DSW A (bits 2-6) */
		$03:in_port1:=((($ff) and $1) shl 4) or (marcade.in3 and $f);	// DSW A (bit 7), DSW C (bits 0-3) */
		$04:in_port1:=marcade.in2;	// coins, start */
		$05:in_port1:=marcade.in1;	// 2P controls */
		$06:in_port1:=marcade.in0;	// 1P controls */
    else in_port1:=$ff;
	end;
end;

function in_port2:byte;
begin
  in_port2:=$ff;
end;

//Main
procedure reset_skykid;
begin
 m6809_0.reset;
 m6800_0.reset;
 namco_snd_0.reset;
 reset_audio;
 marcade.in0:=$FF;
 marcade.in1:=$FF;
 marcade.in2:=$FF;
 marcade.in3:=$ff;
 rom_nbank:=0;
 irq_enable:=false;
 irq_enable_mcu:=false;
 scroll_y:=0;
 inputport_selected:=0;
 scroll_x:=0;
end;

function iniciar_skykid:boolean;
var
  colores:tpaleta;
  f:word;
  memoria_temp:array[0..$ffff] of byte;
const
    pc_x:array[0..7] of dword=(8*8, 8*8+1, 8*8+2, 8*8+3, 0, 1, 2, 3 );
    ps_x:array[0..15] of dword=(0, 1, 2, 3, 8*8, 8*8+1, 8*8+2, 8*8+3,
			16*8+0, 16*8+1, 16*8+2, 16*8+3, 24*8+0, 24*8+1, 24*8+2, 24*8+3);
    ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			32*8, 33*8, 34*8, 35*8, 36*8, 37*8, 38*8, 39*8);
    pt_x:array[0..7] of dword=(0, 1, 2, 3, 8+0, 8+1, 8+2, 8+3 );
    pt_y:array[0..7] of dword=(0*8, 2*8, 4*8, 6*8, 8*8, 10*8, 12*8, 14*8);
begin
iniciar_skykid:=false;
iniciar_audio(false);
screen_init(1,288,224,true);
screen_init(2,512,256);
screen_mod_scroll(2,512,512,511,256,256,255);
screen_init(3,512,256,false,true);
iniciar_video(288,224);
//Main CPU
m6809_0:=cpu_m6809.Create(1536000,224,TCPU_M6809);
m6809_0.change_ram_calls(skykid_getbyte,skykid_putbyte);
//MCU CPU
m6800_0:=cpu_m6800.create(6144000,224,TCPU_HD63701);
m6800_0.change_ram_calls(mcu_getbyte,mcu_putbyte);
m6800_0.change_io_calls(in_port1,in_port2,nil,nil,out_port1,nil,nil,nil);
m6800_0.init_sound(skykid_sound_update);
namco_snd_0:=namco_snd_chip.create(8,true);
case  main_vars.tipo_maquina of
    123:begin
          //cargar roms
          if not(roms_load(@memoria_temp,skykid_rom)) then exit;
          //Pongo las ROMs en su banco
          copymemory(@memoria[$8000],@memoria_temp[$0],$8000);
          for f:=0 to 1 do copymemory(@rom_bank[f,0],@memoria_temp[$8000+(f*$2000)],$2000);
          //Cargar MCU
          if not(roms_load(@mem_snd,skykid_mcu)) then exit;
          //convertir chars
          if not(roms_load(@memoria_temp,skykid_char)) then exit;
          init_gfx(0,8,8,$200);
          gfx[0].trans[0]:=true;
          gfx_set_desc_data(2,0,16*8,0,4);
          convert_gfx(0,0,@memoria_temp,@pc_x,@ps_y,false,false);
          //sprites
          fillchar(memoria_temp[0],$10000,0);
          if not(roms_load(@memoria_temp,skykid_sprites)) then exit;
          // unpack the third sprite ROM
          for f:=0 to $1fff do begin
          		memoria_temp[f+$4000+$4000]:=memoria_temp[f+$4000];		// sprite set #1, plane 3
          		memoria_temp[f+$6000+$4000]:=memoria_temp[f+$4000] shr 4;	// sprite set #2, plane 3
          		memoria_temp[f+$4000]:=memoria_temp[f+$2000+$4000];		// sprite set #3, planes 1&2 (plane 3 is empty)
          end;
          init_gfx(1,16,16,$200);
          gfx_set_desc_data(3,0,64*8,$200*64*8+4,0,4);
          convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,false);
          //tiles
          if not(roms_load(@memoria_temp,skykid_tiles)) then exit;
          init_gfx(2,8,8,$200);
          gfx_set_desc_data(2,0,16*8,0,4);
          convert_gfx(2,0,@memoria_temp,@pt_x,@pt_y,false,false);
          //Paleta
          if not(roms_load(@memoria_temp,skykid_prom)) then exit;
          screen_flip:=false;
    end;
    194:begin
          //cargar roms
          if not(roms_load(@memoria_temp,drgnbstr_rom)) then exit;
          //Pongo las ROMs en su banco
          copymemory(@memoria[$8000],@memoria_temp[$0],$8000);
          for f:=0 to 1 do copymemory(@rom_bank[f,0],@memoria_temp[$8000+(f*$2000)],$2000);
          //Cargar MCU
          if not(roms_load(@mem_snd,drgnbstr_mcu)) then exit;
          //convertir chars
          if not(roms_load(@memoria_temp,drgnbstr_char)) then exit;
          init_gfx(0,8,8,$200);
          gfx[0].trans[0]:=true;
          gfx_set_desc_data(2,0,16*8,0,4);
          convert_gfx(0,0,@memoria_temp,@pc_x,@ps_y,false,false);
          //sprites
          fillchar(memoria_temp[0],$10000,0);
          if not(roms_load(@memoria_temp,drgnbstr_sprites)) then exit;
          // unpack the third sprite ROM
          for f:=0 to $1fff do begin
          		memoria_temp[f+$4000+$4000]:=memoria_temp[f+$4000];		// sprite set #1, plane 3
          		memoria_temp[f+$6000+$4000]:=memoria_temp[f+$4000] shr 4;	// sprite set #2, plane 3
          		memoria_temp[f+$4000]:=memoria_temp[f+$2000+$4000];		// sprite set #3, planes 1&2 (plane 3 is empty)
          end;
          init_gfx(1,16,16,$200);
          gfx_set_desc_data(3,0,64*8,$200*64*8+4,0,4);
          convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,false);
          //tiles
          if not(roms_load(@memoria_temp,drgnbstr_tiles)) then exit;
          init_gfx(2,8,8,$200);
          gfx_set_desc_data(2,0,16*8,0,4);
          convert_gfx(2,0,@memoria_temp,@pt_x,@pt_y,false,false);
          //Paleta
          if not(roms_load(@memoria_temp,drgnbstr_prom)) then exit;
          screen_flip:=true;
    end;
end;
for f:=0 to $ff do begin
  colores[f].r:=(memoria_temp[f] and $f)+((memoria_temp[f] and $f) shl 4);
  colores[f].g:=(memoria_temp[f+$100] and $f)+((memoria_temp[f+$100] and $f) shl 4);
  colores[f].b:=(memoria_temp[f+$200] and $f)+((memoria_temp[f+$200] and $f) shl 4);
end;
set_pal(colores,$100);
// tiles/sprites color table
for f:=$0 to $3ff do begin
  gfx[1].colores[f]:=memoria_temp[$300+f];
  gfx[2].colores[f]:=memoria_temp[$300+f];
end;
//final
reset_skykid;
iniciar_skykid:=true;
end;

procedure Cargar_skykid;
begin
llamadas_maquina.iniciar:=iniciar_skykid;
llamadas_maquina.bucle_general:=skykid_principal;
llamadas_maquina.reset:=reset_skykid;
llamadas_maquina.fps_max:=60.60606060606060;
end;

end.
