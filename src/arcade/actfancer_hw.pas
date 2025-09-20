unit actfancer_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     ym_3812,ym_2203,oki6295,m6502,sound_engine,hu6280,deco_bac06;

function iniciar_actfancer:boolean;

implementation
const
        //Act Fancer
        actfancer_rom:array[0..2] of tipo_roms=(
        (n:'fe08-3.bin';l:$10000;p:0;crc:$35f1999d),(n:'fe09-3.bin';l:$10000;p:$10000;crc:$d21416ca),
        (n:'fe10-3.bin';l:$10000;p:$20000;crc:$85535fcc));
        actfancer_char:array[0..1] of tipo_roms=(
        (n:'15';l:$10000;p:0;crc:$a1baf21e),(n:'16';l:$10000;p:$10000;crc:$22e64730));
        actfancer_sound:tipo_roms=(n:'17-1';l:$8000;p:$8000;crc:$289ad106);
        actfancer_oki:tipo_roms=(n:'18';l:$10000;p:0;crc:$5c55b242);
        actfancer_tiles:array[0..3] of tipo_roms=(
        (n:'14';l:$10000;p:0;crc:$d6457420),(n:'12';l:$10000;p:$10000;crc:$08787b7a),
        (n:'13';l:$10000;p:$20000;crc:$c30c37dc),(n:'11';l:$10000;p:$30000;crc:$1f006d9f));
        actfancer_sprites:array[0..7] of tipo_roms=(
        (n:'02';l:$10000;p:0;crc:$b1db0efc),(n:'03';l:$8000;p:$10000;crc:$f313e04f),
        (n:'06';l:$10000;p:$18000;crc:$8cb6dd87),(n:'07';l:$8000;p:$28000;crc:$dd345def),
        (n:'00';l:$10000;p:$30000;crc:$d50a9550),(n:'01';l:$8000;p:$40000;crc:$34935e93),
        (n:'04';l:$10000;p:$48000;crc:$bcf41795),(n:'05';l:$8000;p:$58000;crc:$d38b94aa));
        actfancer_dip_a:array [0..4] of def_dip2=(
        (mask:3;name:'Coin A';number:4;val4:(0,1,3,2);name4:('3C 1C','2C 1C','1C 1C','1C 2C')),
        (mask:$c;name:'Coin B';number:4;val4:(0,4,$c,8);name4:('3C 1C','2C 1C','1C 1C','1C 2C')),
        (mask:$20;name:'Demo Sounds';number:2;val2:(0,$20);name2:('Off','On')),
        (mask:$40;name:'Flip Screen';number:2;val2:($40,0);name2:('Off','On')),
        (mask:$80;name:'Cabinet';number:2;val2:(0,$80);name2:('Upright','Cocktail')));
        actfancer_dip_b:array [0..2] of def_dip2=(
        (mask:3;name:'Lives';number:4;val4:(3,2,1,0);name4:('3','4','5','100')),
        (mask:$c;name:'Difficulty';number:4;val4:(4,$c,8,0);name4:('Easy','Normal','Hard','Hardest')),
        (mask:$20;name:'Bonus_Life';number:2;val2:($20,0);name2:('80K','None')));

var
 rom:array[0..$2ffff] of byte;
 ram:array[0..$3fff] of byte;
 sound_latch:byte;

procedure update_video_actfancer;
begin
  bac06_0.tile_1.update_pf(1,false,false);
  bac06_0.tile_2.update_pf(0,true,false);
  bac06_0.tile_1.show_pf;
  bac06_0.draw_sprites(0,0,2);
  bac06_0.tile_2.show_pf;
  actualiza_trozo_final(0,8,256,240,7);
end;

procedure eventos_actfancer;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  //P2
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or 1);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or 2);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or 4);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or 8);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 and $7f) else marcade.in2:=(marcade.in2 or $80);
  //SYSTEM
  if arcade_input.coin[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.coin[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
end;
end;

procedure actfancer_principal;
var
  f:byte;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
 for f:=0 to $ff do begin
   case f of
      8:marcade.in1:=marcade.in1 and $7f;
      248:begin
            h6280_0.set_irq_line(0,HOLD_LINE);
            update_video_actfancer;
            marcade.in1:=marcade.in1 or $80;
          end;
   end;
   //Main
   h6280_0.run(frame_main);
   frame_main:=frame_main+h6280_0.tframes-h6280_0.contador;
   //Sound
   m6502_0.run(frame_snd);
   frame_snd:=frame_snd+m6502_0.tframes-m6502_0.contador;
 end;
 eventos_actfancer;
 video_sync;
end;
end;

function actfancer_getbyte(direccion:dword):byte;
var
  tempw:word;
begin
case direccion of
  0..$2ffff:actfancer_getbyte:=rom[direccion];
  $62000..$63fff:begin
                      tempw:=bac06_0.tile_1.data[(direccion and $1fff) shr 1];
                      actfancer_getbyte:=tempw shr (8*(direccion and 1));
                   end;
  $72000..$727ff:begin
                      tempw:=bac06_0.tile_2.data[(direccion and $7ff) shr 1];
                      actfancer_getbyte:=tempw shr (8*(direccion and 1));
                   end;
  $100000..$1007ff:actfancer_getbyte:=buffer_sprites[direccion and $7ff];
  $120000..$1205ff:actfancer_getbyte:=buffer_paleta[direccion and $7ff];
  $130000:actfancer_getbyte:=marcade.in0;
  $130001:actfancer_getbyte:=marcade.in2;
  $130002:actfancer_getbyte:=marcade.dswa;
  $130003:actfancer_getbyte:=marcade.dswb;
  $140000:actfancer_getbyte:=marcade.in1;
  $1f0000..$1f3fff:actfancer_getbyte:=ram[direccion and $3fff];
end;
end;

procedure actfancer_putbyte(direccion:dword;valor:byte);
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
  case dir of
    0..$ff:bac06_0.tile_2.buffer_color[dir shr 4]:=true;
    $100..$1ff:bac06_0.tile_1.buffer_color[(dir shr 4) and $f]:=true;
  end;
end;
begin
case direccion of
  0..$2ffff:;
  $60000..$60007:bac06_0.tile_1.change_control0_8b(direccion,valor);
  $60010..$6001f:bac06_0.tile_1.change_control1_8b_swap(direccion,valor);
  $62000..$63fff:bac06_0.tile_1.write_tile_data_8b_swap(direccion,valor,$1fff);
  $70000..$70007:bac06_0.tile_2.change_control0_8b(direccion,valor);
  $70010..$7001f:bac06_0.tile_2.change_control1_8b_swap(direccion,valor);
  $72000..$727ff:bac06_0.tile_2.write_tile_data_8b_swap(direccion,valor,$7ff);
  $100000..$1007ff:buffer_sprites[direccion and $7ff]:=valor;
  $110000:bac06_0.update_sprite_data(@buffer_sprites);
  $120000..$1205ff:if buffer_paleta[direccion and $7ff]<>valor then begin
                      buffer_paleta[direccion and $7ff]:=valor;
                      cambiar_color((direccion and $7fe));
                   end;
  $150000:begin
              sound_latch:=valor;
              m6502_0.change_nmi(PULSE_LINE);
          end;
  $160000:;
  $1f0000..$1f3fff:ram[direccion and $3fff]:=valor;
end;
end;

function actfancer_snd_getbyte(direccion:word):byte;
begin
case direccion of
  $3000:actfancer_snd_getbyte:=sound_latch;
  $3800:actfancer_snd_getbyte:=oki_6295_0.read;
  0..$7ff,$4000..$ffff:actfancer_snd_getbyte:=mem_snd[direccion];
end;
end;

procedure actfancer_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7ff:mem_snd[direccion]:=valor;
  $800:ym2203_0.control(valor);
  $801:ym2203_0.write(valor);
  $1000:ym3812_0.control(valor);
  $1001:ym3812_0.write(valor);
  $3800:oki_6295_0.write(valor);
  $4000..$ffff:;
end;
end;

procedure actfancer_sound_update;
begin
  ym3812_0.update;
  ym2203_0.update;
  oki_6295_0.update;
end;

procedure snd_irq(irqstate:byte);
begin
  m6502_0.change_irq(irqstate);
end;

//Main
procedure reset_actfancer;
begin
 h6280_0.reset;
 m6502_0.reset;
 frame_main:=h6280_0.tframes;
 frame_snd:=m6502_0.tframes;
 ym3812_0.reset;
 ym2203_0.reset;
 oki_6295_0.reset;
 bac06_0.reset;
 marcade.in0:=$ff;
 marcade.in1:=$7f;
 marcade.in2:=$ff;
 sound_latch:=0;
end;

function iniciar_actfancer:boolean;
const
  pt_x:array[0..15] of dword=(16*8+0, 16*8+1, 16*8+2, 16*8+3, 16*8+4, 16*8+5, 16*8+6, 16*8+7,
			                        0, 1, 2, 3, 4, 5, 6, 7);
  pt_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			                        8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8);
var
  memoria_temp:array[0..$7ffff] of byte;
begin
llamadas_maquina.bucle_general:=actfancer_principal;
llamadas_maquina.reset:=reset_actfancer;
llamadas_maquina.scanlines:=256;
iniciar_actfancer:=false;
iniciar_audio(false);
//El video se inicia en el chip bac06!!!
bac06_0:=bac06_chip.create(false,false,false,$100,0,0,2,1,1,$200);
//Main CPU
h6280_0:=cpu_h6280.create(21477200 div 3);
h6280_0.change_ram_calls(actfancer_getbyte,actfancer_putbyte);
//Sound CPU
m6502_0:=cpu_m6502.create(1500000,TCPU_M6502);
m6502_0.change_ram_calls(actfancer_snd_getbyte,actfancer_snd_putbyte);
m6502_0.init_sound(actfancer_sound_update);
//Sound Chips
ym3812_0:=ym3812_chip.create(YM3812_FM,3000000);
ym3812_0.change_irq_calls(snd_irq);
ym2203_0:=ym2203_chip.create(15000000,0.5);
oki_6295_0:=snd_okim6295.Create(1024188,OKIM6295_PIN7_HIGH,0.85);
case main_vars.tipo_maquina of
  165:begin  //Act Fancer
        //cargar roms
        if not(roms_load(@rom,actfancer_rom)) then exit;
        //cargar sonido
        if not(roms_load(@mem_snd,actfancer_sound)) then exit;
        //OKI rom
        if not(roms_load(oki_6295_0.get_rom_addr,actfancer_oki)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,actfancer_char)) then exit;
        init_gfx(0,8,8,$1000);
        gfx[0].trans[0]:=true;
        gfx_set_desc_data(4,0,8*8,$8000*8,$18000*8,0,$10000*8);
        convert_gfx(0,0,@memoria_temp,@pt_x[8],@pt_y,false,false);
        //tiles 1
        if not(roms_load(@memoria_temp,actfancer_tiles)) then exit;
        init_gfx(1,16,16,$c00);
        gfx[1].trans[0]:=true;
        gfx_set_desc_data(4,0,32*8,0,$10000*8,$20000*8,$30000*8);
        convert_gfx(1,0,@memoria_temp,@pt_x,@pt_y,false,false);
        //sprites
        if not(roms_load(@memoria_temp,actfancer_sprites)) then exit;
        init_gfx(2,16,16,$c00);
        gfx[2].trans[0]:=true;
        gfx_set_desc_data(4,0,32*8,0,$18000*8,$30000*8,$48000*8);
        convert_gfx(2,0,@memoria_temp,@pt_x,@pt_y,false,false);
        //Dip
        init_dips(1,actfancer_dip_a,$7f);
        init_dips(2,actfancer_dip_b,$ff);
      end;
end;
//final
iniciar_actfancer:=true;
end;

end.
