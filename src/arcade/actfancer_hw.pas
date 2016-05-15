unit actfancer_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     ym_3812,ym_2203,oki6295,m6502,sound_engine,hu6280,deco_bac06;

procedure Cargar_actfancer;
function iniciar_actfancer:boolean;
procedure reset_actfancer;
procedure cerrar_actfancer;
procedure actfancer_principal;
//Main CPU
function actfancer_getbyte(direccion:dword):byte;
procedure actfancer_putbyte(direccion:dword;valor:byte);
//Sound CPU
function actfancer_snd_getbyte(direccion:word):byte;
procedure actfancer_snd_putbyte(direccion:word;valor:byte);
procedure actfancer_sound_update;
procedure snd_irq(irqstate:byte);

implementation
const
        //Act Fancer
        actfancer_rom:array[0..3] of tipo_roms=(
        (n:'fe08-2.bin';l:$10000;p:0;crc:$0d36fbfa),(n:'fe09-2.bin';l:$10000;p:$10000;crc:$27ce2bb1),
        (n:'10';l:$10000;p:$20000;crc:$cabad137),());
        actfancer_char:array[0..2] of tipo_roms=(
        (n:'15';l:$10000;p:0;crc:$a1baf21e),(n:'16';l:$10000;p:$10000;crc:$22e64730),());
        actfancer_sound:tipo_roms=(n:'17-1';l:$8000;p:$8000;crc:$289ad106);
        actfancer_oki:tipo_roms=(n:'18';l:$10000;p:0;crc:$5c55b242);
        actfancer_tiles:array[0..4] of tipo_roms=(
        (n:'14';l:$10000;p:0;crc:$d6457420),(n:'12';l:$10000;p:$10000;crc:$08787b7a),
        (n:'13';l:$10000;p:$20000;crc:$c30c37dc),(n:'11';l:$10000;p:$30000;crc:$1f006d9f),());
        actfancer_sprites:array[0..8] of tipo_roms=(
        (n:'02';l:$10000;p:$00000;crc:$b1db0efc),(n:'03';l:$8000;p:$10000;crc:$f313e04f),
        (n:'06';l:$10000;p:$18000;crc:$8cb6dd87),(n:'07';l:$8000;p:$28000;crc:$dd345def),
        (n:'00';l:$10000;p:$30000;crc:$d50a9550),(n:'01';l:$8000;p:$40000;crc:$34935e93),
        (n:'04';l:$10000;p:$48000;crc:$bcf41795),(n:'05';l:$8000;p:$58000;crc:$d38b94aa),());

var
 rom:array[0..$2ffff] of byte;
 ram:array[0..$3fff] of byte;
 sound_latch,vblank_val:byte;

procedure Cargar_actfancer;
begin
llamadas_maquina.bucle_general:=actfancer_principal;
llamadas_maquina.iniciar:=iniciar_actfancer;
llamadas_maquina.cerrar:=cerrar_actfancer;
llamadas_maquina.reset:=reset_actfancer;
llamadas_maquina.fps_max:=60;
end;

function iniciar_actfancer:boolean;
const
  pc_x:array[0..7] of dword=(0, 1, 2, 3, 4, 5, 6, 7);
  pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
  pt_x:array[0..15] of dword=(16*8+0, 16*8+1, 16*8+2, 16*8+3, 16*8+4, 16*8+5, 16*8+6, 16*8+7,
			0, 1, 2, 3, 4, 5, 6, 7);
  pt_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8);
var
  memoria_temp:array[0..$7ffff] of byte;
begin
iniciar_actfancer:=false;
iniciar_audio(false);
//Pantallas:  principal+char y sprites
screen_init(1,2048,1024,true);
screen_mod_scroll(1,2048,256,2047,1024,256,1023);
screen_init(2,1024,1024,true);
screen_mod_scroll(1,1024,256,1023,1024,256,1023);
screen_init(3,512,512,false,true);
iniciar_video(256,240);
sprite_bac06_color:=$200;
deco_bac06_init(0,1,2,0,1,2,0,$100,$000,$000,$fff,$fff,$000,2,1,1);
//Main CPU
main_h6280:=cpu_h6280.create(21477200 div 3,$100);
main_h6280.change_ram_calls(actfancer_getbyte,actfancer_putbyte);
//Sound CPU
snd_m6502:=cpu_m6502.create(1500000,256,TCPU_M6502);
snd_m6502.change_ram_calls(actfancer_snd_getbyte,actfancer_snd_putbyte);
snd_m6502.init_sound(actfancer_sound_update);
//Sound Chips
ym3812_0:=ym3812_chip.create(YM3812_FM,3000000,0.9);
ym3812_0.change_irq_calls(snd_irq);
ym2203_0:=ym2203_chip.create(15000000,0.5,0.9);
oki_6295_0:=snd_okim6295.Create(1000000,OKIM6295_PIN7_HIGH,0.85);
case main_vars.tipo_maquina of
  165:begin  //Act Fancer
        //cargar roms
        if not(cargar_roms(@rom[0],@actfancer_rom[0],'actfancr.zip',0)) then exit;
        //cargar sonido
        if not(cargar_roms(@mem_snd[0],@actfancer_sound,'actfancr.zip',1)) then exit;
        //OKI rom
        if not(cargar_roms(oki_6295_0.get_rom_addr,@actfancer_oki,'actfancr.zip',1)) then exit;
        //convertir chars
        if not(cargar_roms(@memoria_temp[0],@actfancer_char,'actfancr.zip',0)) then exit;
        init_gfx(0,8,8,$1000);
        gfx[0].trans[0]:=true;
        gfx_set_desc_data(4,0,8*8,$08000*8,$18000*8,0,$10000*8);
        convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,false);
        //tiles 1
        if not(cargar_roms(@memoria_temp[0],@actfancer_tiles,'actfancr.zip',0)) then exit;
        init_gfx(1,16,16,$c00);
        gfx[1].trans[0]:=true;
        gfx_set_desc_data(4,0,32*8,0,$10000*8,$20000*8,$30000*8);
        convert_gfx(1,0,@memoria_temp[0],@pt_x[0],@pt_y[0],false,false);
        //sprites
        if not(cargar_roms(@memoria_temp[0],@actfancer_sprites,'actfancr.zip',0)) then exit;
        init_gfx(2,16,16,$c00);
        gfx[2].trans[0]:=true;
        gfx_set_desc_data(4,0,32*8,0,$18000*8,$30000*8,$48000*8);
        convert_gfx(2,0,@memoria_temp[0],@pt_x[0],@pt_y[0],false,false);
      end;
end;
//final
reset_actfancer;
iniciar_actfancer:=true;
end;

procedure cerrar_actfancer;
begin
main_h6280.Free;
snd_m6502.free;
ym3812_0.free;
YM2203_0.Free;
oki_6295_0.Free;
deco_bac06_close(0);
close_audio;
close_video;
end;

procedure reset_actfancer;
begin
 main_h6280.reset;
 snd_m6502.reset;
 ym3812_0.reset;
 ym2203_0.reset;
 oki_6295_0.reset;
 deco_bac06_reset(0);
 reset_audio;
 marcade.in0:=$FF;
 marcade.in1:=$7F;
 marcade.in2:=$FF;
 sound_latch:=0;
 vblank_val:=0;
end;

procedure update_video_actfancer;inline;
begin
update_pf(1,1,false,false);
update_pf(2,0,true,false);
show_pf(1,3);
sprites_deco_bac06(0,0,2,3);
show_pf(2,3);
actualiza_trozo_final(0,8,256,240,3);
end;

procedure eventos_actfancer;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $Fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $F7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  //P2
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $Fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $F7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 and $7f) else marcade.in2:=(marcade.in2 or $80);
  //SYSTEM
  if arcade_input.coin[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.coin[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
end;
end;

procedure actfancer_principal;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=main_h6280.tframes;
frame_s:=snd_m6502.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to $ff do begin
   //Main
   main_h6280.run(trunc(frame_m));
   frame_m:=frame_m+main_h6280.tframes-main_h6280.contador;
   //Sound
   snd_m6502.run(frame_s);
   frame_s:=frame_s+snd_m6502.tframes-snd_m6502.contador;
   case f of
      247:begin
            main_h6280.set_irq_line(0,HOLD_LINE);
            update_video_actfancer;
            vblank_val:=$80;
          end;
      255:vblank_val:=0;
   end;
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
  $000000..$02ffff:actfancer_getbyte:=rom[direccion];
  $062000..$063fff:begin
                      tempw:=bac06_pf.data[1,(direccion and $1fff) shr 1];
                      if (direccion and 1)<>0 then actfancer_getbyte:=tempw shr 8
                        else actfancer_getbyte:=tempw;
                   end;
  $072000..$0727ff:begin
                      tempw:=bac06_pf.data[2,(direccion and $7ff) shr 1];
                      if (direccion and 1)<>0 then actfancer_getbyte:=tempw shr 8
                        else actfancer_getbyte:=tempw;
                   end;
  $100000..$1007ff:actfancer_getbyte:=sprite_ram_bac06[(direccion xor 1) and $7ff];
  $120000..$1205ff:actfancer_getbyte:=buffer_paleta[direccion and $7ff];
  $130000:actfancer_getbyte:=marcade.in0;
  $130001:actfancer_getbyte:=marcade.in2;
  $130002:actfancer_getbyte:=$ff;
  $130003:actfancer_getbyte:=$ff;
  $140000:actfancer_getbyte:=marcade.in1+vblank_val;
  $1f0000..$1f3fff:actfancer_getbyte:=ram[direccion and $3fff];
end;
end;

procedure cambiar_color(dir:word);inline;
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
    $000..$0ff:bac06_pf.buffer_color[2,dir shr 4]:=true;
    $100..$1ff:bac06_pf.buffer_color[1,(dir shr 4) and $f]:=true;
  end;
end;

procedure actfancer_putbyte(direccion:dword;valor:byte);
var
  tempw:word;
begin
if direccion<$30000 then exit;
case direccion of
  $060000..$060007:begin
                      if (direccion and 1)<>0 then tempw:=(bac06_pf.control_0[1,(direccion and 7) shr 1] and $00ff) or (valor shl 8)
                        else tempw:=(bac06_pf.control_0[1,(direccion and 7) shr 1] and $ff00) or valor;
                      change_control0(1,(direccion and 7) shr 1,tempw);
                   end;
  $060010..$06001f:begin
                      if (direccion and 1)<>0 then tempw:=(bac06_pf.control_1[1,(direccion and 7) shr 1] and $00ff) or (valor shl 8)
                        else tempw:=(bac06_pf.control_1[1,(direccion and 7) shr 1] and $ff00) or valor;
                      change_control1(1,(direccion and 7) shr 1,tempw);
                   end;
  $062000..$063fff:begin
                      if (direccion and 1)<>0 then tempw:=(bac06_pf.data[1,(direccion and $1fff) shr 1] and $00ff) or (valor shl 8)
                        else tempw:=(bac06_pf.data[1,(direccion and $1fff) shr 1] and $ff00) or valor;
                      bac06_pf.data[1,(direccion and $1fff) shr 1]:=tempw;
                      gfx[1].buffer[(direccion and $1fff) shr 1]:=true;
                   end;
  $070000..$070007:begin
                      if (direccion and 1)<>0 then tempw:=(bac06_pf.control_0[2,(direccion and 7) shr 1] and $00ff) or (valor shl 8)
                        else tempw:=(bac06_pf.control_0[2,(direccion and 7) shr 1] and $ff00) or valor;
                      change_control0(2,(direccion and 7) shr 1,tempw);
                   end;
  $070010..$07001f:begin
                      if (direccion and 1)<>0 then tempw:=(bac06_pf.control_1[2,(direccion and 7) shr 1] and $00ff) or (valor shl 8)
                        else tempw:=(bac06_pf.control_1[2,(direccion and 7) shr 1] and $ff00) or valor;
                      change_control1(2,(direccion and 7) shr 1,tempw);
                   end;
  $072000..$0727ff:begin
                      if (direccion and 1)<>0 then tempw:=(bac06_pf.data[2,(direccion and $7ff) shr 1] and $00ff) or (valor shl 8)
                        else tempw:=(bac06_pf.data[2,(direccion and $7ff) shr 1] and $ff00) or valor;
                      bac06_pf.data[2,(direccion and $7ff) shr 1]:=tempw;
                      gfx[0].buffer[(direccion and $7ff) shr 1]:=true;
                   end;
  $100000..$1007ff:sprite_ram_bac06[(direccion xor 1) and $7ff]:=valor;
  $110000:copymemory(@buffer_sprites[0],@sprite_ram_bac06[0],$800);
  $120000..$1205ff:if buffer_paleta[direccion and $7ff]<>valor then begin
                      buffer_paleta[direccion and $7ff]:=valor;
                      cambiar_color((direccion and $7fe));
                   end;
  $150000:begin
              sound_latch:=valor;
              snd_m6502.pedir_nmi:=PULSE_LINE;
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
if direccion>$3fff then exit;
case direccion of
  0..$7ff:mem_snd[direccion]:=valor;
  $800:ym2203_0.Control(valor);
  $801:ym2203_0.Write_Reg(valor);
  $1000:ym3812_0.control(valor);
  $1001:ym3812_0.write(valor);
  $3800:oki_6295_0.write(valor);
end;
end;

procedure actfancer_sound_update;
begin
  ym3812_0.update;
  ym2203_0.Update;
  oki_6295_0.update;
end;

procedure snd_irq(irqstate:byte);
begin
  if irqstate<>0 then snd_m6502.pedir_irq:=ASSERT_LINE
    else snd_m6502.pedir_irq:=CLEAR_LINE;
end;

end.
