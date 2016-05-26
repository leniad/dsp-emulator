unit dec0_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m68000,main_engine,controls_engine,gfx_engine,rom_engine,
     pal_engine,ym_2203,ym_3812,oki6295,m6502,sound_engine,hu6280,misc_functions,
     deco_bac06;

procedure Cargar_dec0;
function iniciar_dec0:boolean;
procedure reset_dec0;
procedure cerrar_dec0;
procedure dec0_h6280_principal;
procedure dec0_principal;
//Main CPU
function dec0_getword(direccion:dword):word;
procedure dec0_putword(direccion:dword;valor:word);
//Sound CPU
function dec0_snd_getbyte(direccion:word):byte;
procedure dec0_snd_putbyte(direccion:word;valor:byte);
procedure dec0_sound_update;
procedure snd_irq(irqstate:byte);
//Robocop
function robocop_mcu_getbyte(direccion:dword):byte;
procedure robocop_mcu_putbyte(direccion:dword;valor:byte);
//Hippodrome
function hippo_mcu_getbyte(direccion:dword):byte;
procedure hippo_mcu_putbyte(direccion:dword;valor:byte);

implementation
const
        //Robocop
        robocop_rom:array[0..4] of tipo_roms=(
        (n:'ep05-4.11c';l:$10000;p:0;crc:$29c35379),(n:'ep01-4.11b';l:$10000;p:$1;crc:$77507c69),
        (n:'ep04-3';l:$10000;p:$20000;crc:$39181778),(n:'ep00-3';l:$10000;p:$20001;crc:$e128541f),());
        robocop_mcu:tipo_roms=(n:'en_24_mb7124e.a2';l:$200;p:$0;crc:$b8e2ca98);
        robocop_char:array[0..2] of tipo_roms=(
        (n:'ep23';l:$10000;p:0;crc:$a77e4ab1),(n:'ep22';l:$10000;p:$10000;crc:$9fbd6903),());
        robocop_sound:tipo_roms=(n:'ep03-3';l:$8000;p:$8000;crc:$5b164b24);
        robocop_oki:tipo_roms=(n:'ep02';l:$10000;p:0;crc:$711ce46f);
        robocop_tiles1:array[0..4] of tipo_roms=(
        (n:'ep20';l:$10000;p:0;crc:$1d8d38b8),(n:'ep21';l:$10000;p:$10000;crc:$187929b2),
        (n:'ep18';l:$10000;p:$20000;crc:$b6580b5e),(n:'ep19';l:$10000;p:$30000;crc:$9bad01c7),());
        robocop_tiles2:array[0..4] of tipo_roms=(
        (n:'ep14';l:$8000;p:0;crc:$ca56ceda),(n:'ep15';l:$8000;p:$8000;crc:$a945269c),
        (n:'ep16';l:$8000;p:$10000;crc:$e7fa4d58),(n:'ep17';l:$8000;p:$18000;crc:$84aae89d),());
        robocop_sprites:array[0..8] of tipo_roms=(
        (n:'ep07';l:$10000;p:$00000;crc:$495d75cf),(n:'ep06';l:$8000;p:$10000;crc:$a2ae32e2),
        (n:'ep11';l:$10000;p:$20000;crc:$62fa425a),(n:'ep10';l:$8000;p:$30000;crc:$cce3bd95),
        (n:'ep09';l:$10000;p:$40000;crc:$11bed656),(n:'ep08';l:$8000;p:$50000;crc:$c45c7b4c),
        (n:'ep13';l:$10000;p:$60000;crc:$8fca9f28),(n:'ep12';l:$8000;p:$70000;crc:$3cd1d0c3),());
        //Baddudes
        baddudes_rom:array[0..4] of tipo_roms=(
        (n:'ei04-1.3c';l:$10000;p:0;crc:$4bf158a7),(n:'ei01-1.3a';l:$10000;p:$1;crc:$74f5110c),
        (n:'ei06.6c';l:$10000;p:$40000;crc:$3ff8da57),(n:'ei03.6a';l:$10000;p:$40001;crc:$f8f2bd94),());
        baddudes_char:array[0..2] of tipo_roms=(
        (n:'ei25.15j';l:$8000;p:0;crc:$bcf59a69),(n:'ei26.16j';l:$8000;p:$8000;crc:$9aff67b8),());
        baddudes_sound:tipo_roms=(n:'ei07.8a';l:$8000;p:$8000;crc:$9fb1ef4b);
        baddudes_oki:tipo_roms=(n:'ei08.2c';l:$10000;p:0;crc:$3c87463e);
        baddudes_tiles1:array[0..4] of tipo_roms=(
        (n:'ei18.14d';l:$10000;p:0;crc:$05cfc3e5),(n:'ei20.17d';l:$10000;p:$10000;crc:$e11e988f),
        (n:'ei22.14f';l:$10000;p:$20000;crc:$b893d880),(n:'ei24.17f';l:$10000;p:$30000;crc:$6f226dda),());
        baddudes_tiles2:array[0..2] of tipo_roms=(
        (n:'ei30.9j';l:$10000;p:$20000;crc:$982da0d1),(n:'ei28.9f';l:$10000;p:$30000;crc:$f01ebb3b),());
        baddudes_sprites:array[0..8] of tipo_roms=(
        (n:'ei15.16c';l:$10000;p:$00000;crc:$a38a7d30),(n:'ei16.17c';l:$8000;p:$10000;crc:$17e42633),
        (n:'ei11.16a';l:$10000;p:$20000;crc:$3a77326c),(n:'ei12.17a';l:$8000;p:$30000;crc:$fea2a134),
        (n:'ei13.13c';l:$10000;p:$40000;crc:$e5ae2751),(n:'ei14.14c';l:$8000;p:$50000;crc:$e83c760a),
        (n:'ei09.13a';l:$10000;p:$60000;crc:$6901e628),(n:'ei10.14a';l:$8000;p:$70000;crc:$eeee8a1a),());
        //Hippodrome
        hippo_rom:array[0..4] of tipo_roms=(
        (n:'ew02';l:$10000;p:0;crc:$df0d7dc6),(n:'ew01';l:$10000;p:$1;crc:$d5670aa7),
        (n:'ew05';l:$10000;p:$20000;crc:$c76d65ec),(n:'ew00';l:$10000;p:$20001;crc:$e9b427a6),());
        hippo_mcu:tipo_roms=(n:'ew08';l:$10000;p:$0;crc:$53010534);
        hippo_char:array[0..2] of tipo_roms=(
        (n:'ew14';l:$10000;p:0;crc:$71ca593d),(n:'ew13';l:$10000;p:$10000;crc:$86be5fa7),());
        hippo_sound:tipo_roms=(n:'ew04';l:$8000;p:$8000;crc:$9871b98d);
        hippo_oki:tipo_roms=(n:'ew03';l:$10000;p:0;crc:$b606924d);
        hippo_tiles1:array[0..4] of tipo_roms=(
        (n:'ew19';l:$8000;p:0;crc:$6b80d7a3),(n:'ew18';l:$8000;p:$8000;crc:$78d3d764),
        (n:'ew20';l:$8000;p:$10000;crc:$ce9f5de3),(n:'ew21';l:$8000;p:$18000;crc:$487a7ba2),());
        hippo_tiles2:array[0..4] of tipo_roms=(
        (n:'ew24';l:$8000;p:0;crc:$4e1bc2a4),(n:'ew25';l:$8000;p:$8000;crc:$9eb47dfb),
        (n:'ew23';l:$8000;p:$10000;crc:$9ecf479e),(n:'ew22';l:$8000;p:$18000;crc:$e55669aa),());
        hippo_sprites:array[0..8] of tipo_roms=(
        (n:'ew15';l:$10000;p:$00000;crc:$95423914),(n:'ew16';l:$10000;p:$10000;crc:$96233177),
        (n:'ew10';l:$10000;p:$20000;crc:$4c25dfe8),(n:'ew11';l:$10000;p:$30000;crc:$f2e007fc),
        (n:'ew06';l:$10000;p:$40000;crc:$e4bb8199),(n:'ew07';l:$10000;p:$50000;crc:$470b6989),
        (n:'ew17';l:$10000;p:$60000;crc:$8c97c757),(n:'ew12';l:$10000;p:$70000;crc:$a2d244bc),());

type
    tipo_update_video=procedure;

var
 rom:array[0..$2ffff] of word;
 ram1:array[0..$17ff] of byte;
 ram2:array[0..$3fff] of byte;
 //pal_rg,pal_b:array[0..$7ff] of byte;
 sound_latch,prioridad,hippodrm_lsb:byte;
 proc_update_video:tipo_update_video;
 vblank_val,dip_b:byte;
 //HU 6280
 robocop_mcu_rom:array[0..$1ff] of byte;
 mcu_ram:array[0..$1fff] of byte;
 mcu_shared_ram:array[0..$1fff] of byte;
 hippo_mcu_rom:array[0..$ffff] of byte;
 //8751
 i8751_return:word;


procedure Cargar_dec0;
begin
case main_vars.tipo_maquina of
  156,158:llamadas_maquina.bucle_general:=dec0_h6280_principal;
  157:llamadas_maquina.bucle_general:=dec0_principal;
end;
llamadas_maquina.iniciar:=iniciar_dec0;
llamadas_maquina.cerrar:=cerrar_dec0;
llamadas_maquina.reset:=reset_dec0;
llamadas_maquina.fps_max:=57.392103;
end;

//Video Part
procedure update_video_robocop;
var
  trans:byte;
begin
trans:=(prioridad and $4) shl 1;
if (prioridad and 1)<>0 then begin
  update_pf(2,1,false,false);
  update_pf(3,2,true,false);
  //Pri pant
  show_pf(2,4);
  if (prioridad and $02)<>0 then sprites_deco_bac06($08,trans,3,4);
  show_pf(3,4);
end else begin  //invertidas
  update_pf(3,2,false,false);
  update_pf(2,1,true,false);
  //Pri pant
  show_pf(3,4);
  if (prioridad and $02)<>0 then sprites_deco_bac06($08,trans,3,4);
  show_pf(2,4);
end;
if (prioridad and $02)<>0 then sprites_deco_bac06($08,trans xor $08,3,4)
	else sprites_deco_bac06($00,$00,3,4);
//chars
update_pf(1,0,true,false);
show_pf(1,4);
actualiza_trozo_final(0,8,256,240,4);
end;

procedure update_video_baddudes;
begin
if (prioridad and 1)=0 then begin
  update_pf(2,1,false,true);
  update_pf(3,2,true,true);
  //Pri pant
  show_pf(2,4);
  show_pf(3,4);
  //prioridades
  if (prioridad and $2)<>0 then show_pf_pri(2,4);
  sprites_deco_bac06(0,0,3,4);
  if (prioridad and $4)<>0 then show_pf_pri(3,4);
end else begin  //invertidas
  update_pf(3,2,false,true);
  update_pf(2,1,true,true);
  //Pri pant
  show_pf(3,4);
  show_pf(2,4);
  //prioridades
  if (prioridad and $2)<>0 then show_pf_pri(3,4);
  sprites_deco_bac06(0,0,3,4);
  if (prioridad and $4)<>0 then show_pf_pri(2,4);
end;
//chars
update_pf(1,0,true,false);
show_pf(1,4);
actualiza_trozo_final(0,8,256,240,4);
end;

procedure update_video_hippo;
begin
if (prioridad and 1)<>0 then begin
  update_pf(2,1,false,false);
  update_pf(3,2,true,false);
  //Pri pant
  show_pf(2,4);
  show_pf(3,4);
end else begin  //invertidas
  update_pf(3,2,false,false);
  update_pf(2,1,true,false);
  //Pri pant
  show_pf(3,4);
  show_pf(2,4);
end;
sprites_deco_bac06($00,$00,3,4);
//chars
update_pf(1,0,true,false);
show_pf(1,4);
actualiza_trozo_final(0,8,256,240,4);
end;

//Inicio Normal
function iniciar_dec0:boolean;
const
  pc_x:array[0..7] of dword=(0, 1, 2, 3, 4, 5, 6, 7);
  pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
  ps_x:array[0..15] of dword=(16*8+0, 16*8+1, 16*8+2, 16*8+3, 16*8+4, 16*8+5, 16*8+6, 16*8+7,
			0, 1, 2, 3, 4, 5, 6, 7);
  ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8 );
var
  memoria_temp:array[0..$7ffff] of byte;
  f:word;

procedure convert_chars(ch_num:word);
begin
init_gfx(0,8,8,ch_num);
gfx[0].trans[0]:=true;
gfx_set_desc_data(4,0,8*8,0,ch_num*8*8*2,ch_num*8*8*1,ch_num*8*8*3);
convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,false);
end;

procedure convert_tiles(num_gfx:byte;tl_num:word);
begin
init_gfx(num_gfx,16,16,tl_num);
gfx[num_gfx].trans[0]:=true;
gfx_set_desc_data(4,0,16*16,tl_num*16*16*1,tl_num*16*16*3,tl_num*16*16*0,tl_num*16*16*2);
convert_gfx(num_gfx,0,@memoria_temp[0],@ps_x[0],@ps_y[0],false,false);
end;

begin
iniciar_dec0:=false;
iniciar_audio(false);
//Pantallas:  principal+char y sprites
screen_init(1,1024,1024,true);
screen_mod_scroll(1,1024,256,1023,1024,256,1023);
screen_init(2,1024,1024,true);
screen_mod_scroll(2,1024,256,1023,1024,256,1023);
screen_init(3,1024,1024,true);
screen_mod_scroll(3,1024,256,1023,1024,256,1023);
screen_init(4,512,512,false,true);
//Pantallas de prioridades
screen_init(5,1024,1024,true);
screen_init(6,1024,1024,true);
iniciar_video(256,240);
sprite_bac06_color:=$100;
//Main CPU
main_m68000:=cpu_m68000.create(10000000,264);
main_m68000.change_ram16_calls(dec0_getword,dec0_putword);
//Sound CPU
snd_m6502:=cpu_m6502.create(1500000,264,TCPU_M6502);
snd_m6502.change_ram_calls(dec0_snd_getbyte,dec0_snd_putbyte);
snd_m6502.init_sound(dec0_sound_update);
//Sound Chips
ym3812_0:=ym3812_chip.create(YM3812_FM,3000000);
ym3812_0.change_irq_calls(snd_irq);
ym2203_0:=ym2203_chip.create(1500000);
oki_6295_0:=snd_okim6295.Create(1000000,OKIM6295_PIN7_HIGH);
case main_vars.tipo_maquina of
  156:begin  //Robocop
        deco_bac06_init(0,1,2,3,1,5,6,$000,$200,$300,$fff,$7ff,$3ff,1,1,1);
        //cargar roms
        if not(cargar_roms16w(@rom[0],@robocop_rom[0],'robocop.zip',0)) then exit;
        //cargar sonido
        if not(cargar_roms(@mem_snd[0],@robocop_sound,'robocop.zip',1)) then exit;
        //MCU
        main_h6280:=cpu_h6280.create(21477200 div 16,264);
        main_h6280.change_ram_calls(robocop_mcu_getbyte,robocop_mcu_putbyte);
        if not(cargar_roms(@robocop_mcu_rom[0],@robocop_mcu,'robocop.zip',1)) then exit;
        //OKI rom
        if not(cargar_roms(oki_6295_0.get_rom_addr,@robocop_oki,'robocop.zip',1)) then exit;
        //convertir chars
        if not(cargar_roms(@memoria_temp[0],@robocop_char,'robocop.zip',0)) then exit;
        convert_chars($1000);
        //tiles 1
        if not(cargar_roms(@memoria_temp[0],@robocop_tiles1,'robocop.zip',0)) then exit;
        convert_tiles(1,$800);
        //tiles 2
        if not(cargar_roms(@memoria_temp[0],@robocop_tiles2,'robocop.zip',0)) then exit;
        convert_tiles(2,$400);
        //sprites
        if not(cargar_roms(@memoria_temp[0],@robocop_sprites,'robocop.zip',0)) then exit;
        convert_tiles(3,$1000);
        proc_update_video:=update_video_robocop;
        dip_b:=$7f;
      end;
  157:begin //Baddudes
        deco_bac06_init(0,1,2,3,1,5,6,$000,$200,$300,$7ff,$7ff,$3ff,1,1,1);
        //cargar roms
        if not(cargar_roms16w(@rom[0],@baddudes_rom[0],'baddudes.zip',0)) then exit;
        //cargar sonido
        if not(cargar_roms(@mem_snd[0],@baddudes_sound,'baddudes.zip',1)) then exit;
        //OKI rom
        if not(cargar_roms(oki_6295_0.get_rom_addr,@baddudes_oki,'baddudes.zip',1)) then exit;
        //convertir chars
        if not(cargar_roms(@memoria_temp[0],@baddudes_char,'baddudes.zip',0)) then exit;
        convert_chars($800);
        //tiles 1
        if not(cargar_roms(@memoria_temp[0],@baddudes_tiles1,'baddudes.zip',0)) then exit;
        convert_tiles(1,$800);
        //tiles 2, ordenar
        if not(cargar_roms(@memoria_temp[0],@baddudes_tiles2,'baddudes.zip',0)) then exit;
        copymemory(@memoria_temp[$8000],@memoria_temp[$20000],$8000);
        copymemory(@memoria_temp[$0],@memoria_temp[$28000],$8000);
        copymemory(@memoria_temp[$18000],@memoria_temp[$30000],$8000);
        copymemory(@memoria_temp[$10000],@memoria_temp[$38000],$8000);
        convert_tiles(2,$400);
        //sprites
        if not(cargar_roms(@memoria_temp[0],@baddudes_sprites,'baddudes.zip',0)) then exit;
        convert_tiles(3,$1000);
        proc_update_video:=update_video_baddudes;
        dip_b:=$ff;
      end;
  158:begin  //Hippodrome
        deco_bac06_init(0,1,2,3,1,5,6,$000,$200,$300,$fff,$3ff,$3ff,1,1,1);
        //cargar roms
        if not(cargar_roms16w(@rom[0],@hippo_rom[0],'hippodrm.zip',0)) then exit;
        //cargar sonido
        if not(cargar_roms(@mem_snd[0],@hippo_sound,'hippodrm.zip',1)) then exit;
        //MCU+decrypt
        main_h6280:=cpu_h6280.create(21477200 div 16,264);
        main_h6280.change_ram_calls(hippo_mcu_getbyte,hippo_mcu_putbyte);
        if not(cargar_roms(@hippo_mcu_rom[0],@hippo_mcu,'hippodrm.zip',1)) then exit;
        for f:=0 to $ffff do hippo_mcu_rom[f]:=bitswap8(hippo_mcu_rom[f],0,6,5,4,3,2,1,7);
        hippo_mcu_rom[$189]:=$60; // RTS prot area
	      hippo_mcu_rom[$1af]:=$60; // RTS prot area
	      hippo_mcu_rom[$1db]:=$60; // RTS prot area
	      hippo_mcu_rom[$21a]:=$60; // RTS prot area
        //OKI rom
        if not(cargar_roms(oki_6295_0.get_rom_addr,@hippo_oki,'hippodrm.zip',1)) then exit;
        //convertir chars
        if not(cargar_roms(@memoria_temp[0],@hippo_char,'hippodrm.zip',0)) then exit;
        convert_chars($1000);
        //tiles 1
        if not(cargar_roms(@memoria_temp[0],@hippo_tiles1,'hippodrm.zip',0)) then exit;
        convert_tiles(1,$400);
        //tiles 2
        if not(cargar_roms(@memoria_temp[0],@hippo_tiles2,'hippodrm.zip',0)) then exit;
        convert_tiles(2,$400);
        //sprites
        if not(cargar_roms(@memoria_temp[0],@hippo_sprites,'hippodrm.zip',0)) then exit;
        convert_tiles(3,$1000);
        proc_update_video:=update_video_hippo;
        dip_b:=$ff;
      end;
end;
//final
reset_dec0;
iniciar_dec0:=true;
end;

procedure cerrar_dec0;
begin
deco_bac06_close(0);
end;

procedure reset_dec0;
begin
 main_m68000.reset;
 snd_m6502.reset;
 case main_vars.tipo_maquina of
  156,158:main_h6280.reset;
 end;
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

procedure eventos_dec0;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $Fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $F7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.but2[0] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  //P2
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $Fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $F7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.but2[1] then marcade.in2:=(marcade.in2 and $bf) else marcade.in2:=(marcade.in2 or $40);
  //SYSTEM
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $F7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.coin[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.coin[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
end;
end;

procedure dec0_principal;
var
  frame_m,frame_s:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=main_m68000.tframes;
frame_s:=snd_m6502.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to 263 do begin
   main_m68000.run(frame_m);
   frame_m:=frame_m+main_m68000.tframes-main_m68000.contador;
   snd_m6502.run(frame_s);
   frame_s:=frame_s+snd_m6502.tframes-snd_m6502.contador;
   case f of
      255:begin
            main_m68000.irq[6]:=HOLD_LINE;
            proc_update_video;
            vblank_val:=$80;
          end;
      263:vblank_val:=0;
   end;
 end;
 eventos_dec0;
 video_sync;
end;
end;

procedure dec0_h6280_principal;
var
  frame_m,frame_s,frame_mcu:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=main_m68000.tframes;
frame_s:=snd_m6502.tframes;
frame_mcu:=main_h6280.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to 263 do begin
   main_m68000.run(frame_m);
   frame_m:=frame_m+main_m68000.tframes-main_m68000.contador;
   snd_m6502.run(frame_s);
   frame_s:=frame_s+snd_m6502.tframes-snd_m6502.contador;
   main_h6280.run(frame_mcu);
   frame_mcu:=frame_mcu+main_h6280.tframes-main_h6280.contador;
   case f of
      255:begin
            main_m68000.irq[6]:=HOLD_LINE;
            proc_update_video;
            vblank_val:=$80;
          end;
      263:vblank_val:=0;
   end;
 end;
 eventos_dec0;
 video_sync;
end;
end;

procedure cambiar_color(numero:word);inline;
var
  color:tcolor;
begin
  color.r:=buffer_paleta[numero] and $ff;
  color.g:=buffer_paleta[numero] shr 8;
  color.b:=buffer_paleta[$400+numero] and $ff;
  set_pal_color(color,numero);
  case numero of
    $000..$0ff:bac06_pf.buffer_color[1,numero shr 4]:=true;
    $200..$2ff:bac06_pf.buffer_color[2,(numero shr 4) and $f]:=true;
    $300..$3ff:bac06_pf.buffer_color[3,(numero shr 4) and $f]:=true;
  end;
end;

function dec0_getword(direccion:dword):word;
begin
case direccion of
  $0..$5ffff:dec0_getword:=rom[direccion shr 1];
  $180000..$180fff:dec0_getword:=mcu_shared_ram[(direccion and $fff) shr 1];
  $242800..$243fff:dec0_getword:=ram1[(direccion-$242800)+1] or (ram1[direccion-$242800] shl 8);
  $244000..$245fff:dec0_getword:=bac06_pf.data[1,(direccion and $1fff) shr 1];
  $24a000..$24a7ff:dec0_getword:=bac06_pf.data[2,(direccion and $7ff) shr 1];
  $24d000..$24d7ff:dec0_getword:=bac06_pf.data[3,(direccion and $7ff) shr 1];
  $30c000:dec0_getword:=(marcade.in2 shl 8)+marcade.in0;
  $30c006,$30c00a:dec0_getword:=$ffff;
  $30c002:dec0_getword:=marcade.in1+vblank_val;
  $30c004:dec0_getword:=$ff00+dip_b;
  $30c008:dec0_getword:=i8751_return;
  $310000..$3107ff:dec0_getword:=buffer_paleta[(direccion and $7ff) shr 1];
  $314000..$3147ff:dec0_getword:=buffer_paleta[((direccion and $7ff) shr 1)+$400];
  $ff8000..$ffbfff:dec0_getword:=ram2[(direccion and $3fff)+1] or (ram2[direccion and $3fff] shl 8);
  $ffc000..$ffcfff:dec0_getword:=sprite_ram_bac06[(direccion and $7ff)+1] or (sprite_ram_bac06[direccion and $7ff] shl 8);
end;
end;

procedure dec0_i8751_write(valor:word);inline;
begin
	i8751_return:=0;
	case valor of
		$714:i8751_return:=$700;
		$73b:i8751_return:=$701;
		$72c:i8751_return:=$702;
		$73f:i8751_return:=$703;
		$755:i8751_return:=$704;
		$722:i8751_return:=$705;
		$72b:i8751_return:=$706;
		$724:i8751_return:=$707;
		$728:i8751_return:=$708;
		$735:i8751_return:=$709;
		$71d:i8751_return:=$70a;
		$721:i8751_return:=$70b;
		$73e:i8751_return:=$70c;
		$761:i8751_return:=$70d;
		$753:i8751_return:=$70e;
		$75b:i8751_return:=$70f;
	end;
	main_m68000.irq[5]:=HOLD_LINE;
end;

procedure dec0_putword(direccion:dword;valor:word);
begin
if direccion<$60000 then exit;
case direccion of
    $180000..$180fff:begin
                        mcu_shared_ram[(direccion and $fff) shr 1]:=valor and $ff;
                        if ((direccion and $fff)=$ffe) then main_h6280.set_irq_line(0,HOLD_LINE);
                     end;
    $240000..$240007:change_control0(1,(direccion and 7) shr 1,valor);
    $240010..$240017:change_control1(1,(direccion and 7) shr 1,valor);
    $242000..$24207f:bac06_pf.colscroll[1,(direccion and $7f) shr 1]:=valor;
    $242400..$2427ff:bac06_pf.rowscroll[1,(direccion and $3ff) shr 1]:=valor;
    $242800..$243fff:begin
                      ram1[(direccion-$242800)+1]:=valor and $ff;
                      ram1[direccion-$242800]:=valor shr 8;
                   end;
    $244000..$245fff:begin
                      bac06_pf.data[1,(direccion and $1fff) shr 1]:=valor;
                      gfx[0].buffer[(direccion and $1fff) shr 1]:=true;
                   end;
    $246000..$246007:change_control0(2,(direccion and 7) shr 1,valor);
    $246010..$246017:change_control1(2,(direccion and 7) shr 1,valor);
    $248000..$24807f:bac06_pf.colscroll[2,(direccion and $7f) shr 1]:=valor;
    $248400..$2487ff:bac06_pf.rowscroll[2,(direccion and $3ff) shr 1]:=valor;
    $24a000..$24a7ff:begin
                      bac06_pf.data[2,(direccion and $7ff) shr 1]:=valor;
                      gfx[1].buffer[(direccion and $7ff) shr 1]:=true;
                   end;
    $24c000..$24c007:change_control0(3,(direccion and 7) shr 1,valor);
    $24c010..$24c017:change_control1(3,(direccion and 7) shr 1,valor);
    $24c800..$24c87f:bac06_pf.colscroll[3,(direccion and $7f) shr 1]:=valor;
    $24cc00..$24cfff:bac06_pf.rowscroll[3,(direccion and $3ff) shr 1]:=valor;
    $24d000..$24d7ff:begin
                      bac06_pf.data[3,(direccion and $7ff) shr 1]:=valor;
                      gfx[2].buffer[(direccion and $7ff) shr 1]:=true;
                   end;
    $30c010..$30c01f:case (direccion and $f) of
                        0:prioridad:=valor and $ff;
                        2:copymemory(@buffer_sprites[0],@sprite_ram_bac06[0],$800);
                        4:begin
                            sound_latch:=valor and $ff;
                            snd_m6502.pedir_nmi:=PULSE_LINE;
                          end;
                        6:dec0_i8751_write(valor);
                        $e:i8751_return:=0;
                   end;
    $310000..$3107ff:if buffer_paleta[(direccion and $7ff) shr 1]<>valor then begin
                      buffer_paleta[(direccion and $7ff) shr 1]:=valor;
                      cambiar_color((direccion and $7ff) shr 1);
                   end;
    $314000..$3147ff:if buffer_paleta[((direccion and $7ff) shr 1)+$400]<>valor then begin
                      buffer_paleta[((direccion and $7ff) shr 1)+$400]:=valor;
                      cambiar_color((direccion and $7ff) shr 1);
                   end;
    $ff8000..$ffbfff:begin
                      ram2[(direccion and $3fff)+1]:=valor and $ff;
                      ram2[direccion and $3fff]:=valor shr 8;
                   end;
    $ffc000..$ffcfff:begin
                      sprite_ram_bac06[(direccion and $7ff)+1]:=valor and $ff;
                      sprite_ram_bac06[direccion and $7ff]:=valor shr 8;
                   end;
end;
end;

function dec0_snd_getbyte(direccion:word):byte;
begin
case direccion of
  $3000:dec0_snd_getbyte:=sound_latch;
  $3800:dec0_snd_getbyte:=oki_6295_0.read;
  $0000..$05ff,$8000..$ffff:dec0_snd_getbyte:=mem_snd[direccion];
end;
end;

procedure dec0_snd_putbyte(direccion:word;valor:byte);
begin
if direccion>$7fff then exit;
case direccion of
  $0000..$05ff:mem_snd[direccion]:=valor;
  $0800:ym2203_0.Control(valor);
  $0801:ym2203_0.Write_Reg(valor);
  $1000:ym3812_0.control(valor);
  $1001:ym3812_0.write(valor);
  $3800:oki_6295_0.write(valor);
end;
end;

procedure dec0_sound_update;
begin
  ym3812_0.update;
  ym2203_0.Update;
  oki_6295_0.update;
end;

procedure snd_irq(irqstate:byte);
begin
  if (irqstate<>0) then snd_m6502.pedir_irq:=ASSERT_LINE
    else snd_m6502.pedir_irq:=CLEAR_LINE;
end;

//Robocop
function robocop_mcu_getbyte(direccion:dword):byte;
begin
case direccion of
  $001e00..$001fff:robocop_mcu_getbyte:=robocop_mcu_rom[direccion and $1ff];
  $1f0000..$1f1fff:robocop_mcu_getbyte:=mcu_ram[direccion and $1fff];
  $1f2000..$1f3fff:robocop_mcu_getbyte:=mcu_shared_ram[direccion and $1fff];
end;
end;

procedure robocop_mcu_putbyte(direccion:dword;valor:byte);
begin
if direccion<$10000 then exit;
case direccion of
  $1f0000..$1f1fff:mcu_ram[direccion and $1fff]:=valor;
  $1f2000..$1f3fff:mcu_shared_ram[direccion and $1fff]:=valor;
  $1ff400..$1ff403:main_h6280.irq_status_w(direccion and $3,valor);
end;
end;

//Hippodrome
function hippo_mcu_getbyte(direccion:dword):byte;
var
  tempw:word;
begin
case direccion of
  0..$ffff:hippo_mcu_getbyte:=hippo_mcu_rom[direccion];
  $180000..$1800ff:hippo_mcu_getbyte:=mcu_shared_ram[direccion and $ff];
  $1807ff:hippo_mcu_getbyte:=$ff;
  $1d0000..$1d00ff:case hippodrm_lsb of //protecction
                      $45:hippo_mcu_getbyte:=$4e;
	                    $92:hippo_mcu_getbyte:=$15;
                   end;
  $1a1000..$1a17ff:begin
                      tempw:=bac06_pf.data[3,(direccion and $7ff) shr 1];
                      if (direccion and 1)<>0 then hippo_mcu_getbyte:=tempw shr 8
                        else hippo_mcu_getbyte:=tempw;
                   end;
  $1f0000..$1f1fff:hippo_mcu_getbyte:=mcu_ram[direccion and $1fff];
  $1ff402..$1ff403:hippo_mcu_getbyte:=vblank_val shr 7;
end;
end;

procedure hippo_mcu_putbyte(direccion:dword;valor:byte);
var
  tempw:word;
begin
if direccion<$10000 then exit;
case direccion of
  $180000..$1800ff:mcu_shared_ram[direccion and $ff]:=valor;
  $1a0000..$1a0007:begin
                      if (direccion and 1)<>0 then tempw:=(bac06_pf.control_0[3,(direccion and 7) shr 1] and $00ff) or (valor shl 8)
                        else tempw:=(bac06_pf.control_0[3,(direccion and 7) shr 1] and $ff00) or valor;
                      change_control0(3,(direccion and 7) shr 1,tempw);
                   end;
  $1a0010..$1a001f:begin
                      if (direccion and 1)<>0 then tempw:=(bac06_pf.control_1[3,(direccion and 7) shr 1] and $00ff) or (valor shl 8)
                        else tempw:=(bac06_pf.control_1[3,(direccion and 7) shr 1] and $ff00) or valor;
                      change_control1(3,(direccion and 7) shr 1,tempw);
                   end;
  $1a1000..$1a17ff:begin
                      if (direccion and 1)<>0 then tempw:=(bac06_pf.data[3,(direccion and $7ff) shr 1] and $00ff) or (valor shl 8)
                        else tempw:=(bac06_pf.data[3,(direccion and $7ff) shr 1] and $ff00) or valor;
                      bac06_pf.data[3,(direccion and $7ff) shr 1]:=tempw;
                      gfx[2].buffer[(direccion and $7ff) shr 1]:=true;
                   end;
  $1d0000..$1d00ff:hippodrm_lsb:=valor;
  $1f0000..$1f1fff:mcu_ram[direccion and $1fff]:=valor;
  $1ff400..$1ff403:main_h6280.irq_status_w(direccion and $3,valor);
end;
end;

end.
