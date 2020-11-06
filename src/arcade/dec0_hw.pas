unit dec0_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m68000,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     ym_2203,ym_3812,oki6295,m6502,sound_engine,hu6280,misc_functions,
     deco_bac06,mcs51;

procedure cargar_dec0;

implementation
const
        //Robocop
        robocop_rom:array[0..3] of tipo_roms=(
        (n:'ep05-4.11c';l:$10000;p:0;crc:$29c35379),(n:'ep01-4.11b';l:$10000;p:$1;crc:$77507c69),
        (n:'ep04-3';l:$10000;p:$20000;crc:$39181778),(n:'ep00-3';l:$10000;p:$20001;crc:$e128541f));
        robocop_mcu:tipo_roms=(n:'en_24_mb7124e.a2';l:$200;p:$0;crc:$b8e2ca98);
        robocop_char:array[0..1] of tipo_roms=(
        (n:'ep23';l:$10000;p:0;crc:$a77e4ab1),(n:'ep22';l:$10000;p:$10000;crc:$9fbd6903));
        robocop_sound:tipo_roms=(n:'ep03-3';l:$8000;p:$8000;crc:$5b164b24);
        robocop_oki:tipo_roms=(n:'ep02';l:$10000;p:0;crc:$711ce46f);
        robocop_tiles1:array[0..3] of tipo_roms=(
        (n:'ep20';l:$10000;p:0;crc:$1d8d38b8),(n:'ep21';l:$10000;p:$10000;crc:$187929b2),
        (n:'ep18';l:$10000;p:$20000;crc:$b6580b5e),(n:'ep19';l:$10000;p:$30000;crc:$9bad01c7));
        robocop_tiles2:array[0..3] of tipo_roms=(
        (n:'ep14';l:$8000;p:0;crc:$ca56ceda),(n:'ep15';l:$8000;p:$8000;crc:$a945269c),
        (n:'ep16';l:$8000;p:$10000;crc:$e7fa4d58),(n:'ep17';l:$8000;p:$18000;crc:$84aae89d));
        robocop_sprites:array[0..7] of tipo_roms=(
        (n:'ep07';l:$10000;p:$00000;crc:$495d75cf),(n:'ep06';l:$8000;p:$10000;crc:$a2ae32e2),
        (n:'ep11';l:$10000;p:$20000;crc:$62fa425a),(n:'ep10';l:$8000;p:$30000;crc:$cce3bd95),
        (n:'ep09';l:$10000;p:$40000;crc:$11bed656),(n:'ep08';l:$8000;p:$50000;crc:$c45c7b4c),
        (n:'ep13';l:$10000;p:$60000;crc:$8fca9f28),(n:'ep12';l:$8000;p:$70000;crc:$3cd1d0c3));
        robocop_dip:array [0..10] of def_dip=(
        (mask:$0003;name:'Coin A';number:4;dip:((dip_val:$0;dip_name:'3C 1C'),(dip_val:$1;dip_name:'2C 1C'),(dip_val:$3;dip_name:'1C 1C'),(dip_val:$2;dip_name:'1C 2C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$000c;name:'Coin B';number:4;dip:((dip_val:$0;dip_name:'3C 1C'),(dip_val:$4;dip_name:'2C 1C'),(dip_val:$c;dip_name:'1C 1C'),(dip_val:$8;dip_name:'1C 2C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0020;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$20;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0040;name:'Flip Screen';number:2;dip:((dip_val:$40;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0080;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$80;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0300;name:'Player Energy';number:4;dip:((dip_val:$100;dip_name:'Low'),(dip_val:$300;dip_name:'Medium'),(dip_val:$200;dip_name:'High'),(dip_val:$0;dip_name:'Very High'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0c00;name:'Difficulty';number:4;dip:((dip_val:$800;dip_name:'Easy'),(dip_val:$c00;dip_name:'Normal'),(dip_val:$400;dip_name:'Hard'),(dip_val:$000;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$1000;name:'Allow Continue';number:2;dip:((dip_val:$1000;dip_name:'Yes'),(dip_val:$0;dip_name:'No'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2000;name:'Bonus Stage Energy';number:2;dip:((dip_val:$0;dip_name:'Low'),(dip_val:$2000;dip_name:'High'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4000;name:'Brink Time';number:2;dip:((dip_val:$4000;dip_name:'Normal'),(dip_val:$0;dip_name:'Less'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        //Baddudes
        baddudes_rom:array[0..3] of tipo_roms=(
        (n:'ei04-1.3c';l:$10000;p:0;crc:$4bf158a7),(n:'ei01-1.3a';l:$10000;p:$1;crc:$74f5110c),
        (n:'ei06.6c';l:$10000;p:$40000;crc:$3ff8da57),(n:'ei03.6a';l:$10000;p:$40001;crc:$f8f2bd94));
        baddudes_char:array[0..1] of tipo_roms=(
        (n:'ei25.15j';l:$8000;p:0;crc:$bcf59a69),(n:'ei26.16j';l:$8000;p:$8000;crc:$9aff67b8));
        baddudes_mcu:tipo_roms=(n:'ei31.9a';l:$1000;p:$0;crc:$2a8745d2);
        baddudes_sound:tipo_roms=(n:'ei07.8a';l:$8000;p:$8000;crc:$9fb1ef4b);
        baddudes_oki:tipo_roms=(n:'ei08.2c';l:$10000;p:0;crc:$3c87463e);
        baddudes_tiles1:array[0..3] of tipo_roms=(
        (n:'ei18.14d';l:$10000;p:0;crc:$05cfc3e5),(n:'ei20.17d';l:$10000;p:$10000;crc:$e11e988f),
        (n:'ei22.14f';l:$10000;p:$20000;crc:$b893d880),(n:'ei24.17f';l:$10000;p:$30000;crc:$6f226dda));
        baddudes_tiles2:array[0..1] of tipo_roms=(
        (n:'ei30.9j';l:$10000;p:$20000;crc:$982da0d1),(n:'ei28.9f';l:$10000;p:$30000;crc:$f01ebb3b));
        baddudes_sprites:array[0..7] of tipo_roms=(
        (n:'ei15.16c';l:$10000;p:$00000;crc:$a38a7d30),(n:'ei16.17c';l:$8000;p:$10000;crc:$17e42633),
        (n:'ei11.16a';l:$10000;p:$20000;crc:$3a77326c),(n:'ei12.17a';l:$8000;p:$30000;crc:$fea2a134),
        (n:'ei13.13c';l:$10000;p:$40000;crc:$e5ae2751),(n:'ei14.14c';l:$8000;p:$50000;crc:$e83c760a),
        (n:'ei09.13a';l:$10000;p:$60000;crc:$6901e628),(n:'ei10.14a';l:$8000;p:$70000;crc:$eeee8a1a));
        baddudes_dip:array [0..7] of def_dip=(
        (mask:$0003;name:'Coin A';number:4;dip:((dip_val:$0;dip_name:'3C 1C'),(dip_val:$1;dip_name:'2C 1C'),(dip_val:$3;dip_name:'1C 1C'),(dip_val:$2;dip_name:'1C 2C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$000c;name:'Coin B';number:4;dip:((dip_val:$0;dip_name:'3C 1C'),(dip_val:$4;dip_name:'2C 1C'),(dip_val:$c;dip_name:'1C 1C'),(dip_val:$8;dip_name:'1C 2C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0020;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$20;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0040;name:'Flip Screen';number:2;dip:((dip_val:$40;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0300;name:'Lives';number:4;dip:((dip_val:$100;dip_name:'1'),(dip_val:$300;dip_name:'3'),(dip_val:$200;dip_name:'5'),(dip_val:$0;dip_name:'Infinite'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0c00;name:'Difficulty';number:4;dip:((dip_val:$800;dip_name:'Easy'),(dip_val:$c00;dip_name:'Normal'),(dip_val:$400;dip_name:'Hard'),(dip_val:$000;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$1000;name:'Allow Continue';number:2;dip:((dip_val:$1000;dip_name:'Yes'),(dip_val:$0;dip_name:'No'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        //Hippodrome
        hippo_rom:array[0..3] of tipo_roms=(
        (n:'ew02';l:$10000;p:0;crc:$df0d7dc6),(n:'ew01';l:$10000;p:$1;crc:$d5670aa7),
        (n:'ew05';l:$10000;p:$20000;crc:$c76d65ec),(n:'ew00';l:$10000;p:$20001;crc:$e9b427a6));
        hippo_mcu:tipo_roms=(n:'ew08';l:$10000;p:$0;crc:$53010534);
        hippo_char:array[0..1] of tipo_roms=(
        (n:'ew14';l:$10000;p:0;crc:$71ca593d),(n:'ew13';l:$10000;p:$10000;crc:$86be5fa7));
        hippo_sound:tipo_roms=(n:'ew04';l:$8000;p:$8000;crc:$9871b98d);
        hippo_oki:tipo_roms=(n:'ew03';l:$10000;p:0;crc:$b606924d);
        hippo_tiles1:array[0..3] of tipo_roms=(
        (n:'ew19';l:$8000;p:0;crc:$6b80d7a3),(n:'ew18';l:$8000;p:$8000;crc:$78d3d764),
        (n:'ew20';l:$8000;p:$10000;crc:$ce9f5de3),(n:'ew21';l:$8000;p:$18000;crc:$487a7ba2));
        hippo_tiles2:array[0..3] of tipo_roms=(
        (n:'ew24';l:$8000;p:0;crc:$4e1bc2a4),(n:'ew25';l:$8000;p:$8000;crc:$9eb47dfb),
        (n:'ew23';l:$8000;p:$10000;crc:$9ecf479e),(n:'ew22';l:$8000;p:$18000;crc:$e55669aa));
        hippo_sprites:array[0..7] of tipo_roms=(
        (n:'ew15';l:$10000;p:$00000;crc:$95423914),(n:'ew16';l:$10000;p:$10000;crc:$96233177),
        (n:'ew10';l:$10000;p:$20000;crc:$4c25dfe8),(n:'ew11';l:$10000;p:$30000;crc:$f2e007fc),
        (n:'ew06';l:$10000;p:$40000;crc:$e4bb8199),(n:'ew07';l:$10000;p:$50000;crc:$470b6989),
        (n:'ew17';l:$10000;p:$60000;crc:$8c97c757),(n:'ew12';l:$10000;p:$70000;crc:$a2d244bc));
        hippo_dip:array [0..8] of def_dip=(
        (mask:$0003;name:'Coin A';number:4;dip:((dip_val:$0;dip_name:'3C 1C'),(dip_val:$1;dip_name:'2C 1C'),(dip_val:$3;dip_name:'1C 1C'),(dip_val:$2;dip_name:'1C 2C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$000c;name:'Coin B';number:4;dip:((dip_val:$0;dip_name:'3C 1C'),(dip_val:$4;dip_name:'2C 1C'),(dip_val:$c;dip_name:'1C 1C'),(dip_val:$8;dip_name:'1C 2C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0020;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$20;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0040;name:'Flip Screen';number:2;dip:((dip_val:$40;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0300;name:'Lives';number:4;dip:((dip_val:$100;dip_name:'1'),(dip_val:$300;dip_name:'3'),(dip_val:$200;dip_name:'3'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0c00;name:'Difficulty';number:4;dip:((dip_val:$800;dip_name:'Easy'),(dip_val:$c00;dip_name:'Normal'),(dip_val:$400;dip_name:'Hard'),(dip_val:$000;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$3000;name:'Player & Enemy Energy';number:4;dip:((dip_val:$1000;dip_name:'Very Low'),(dip_val:$2000;dip_name:'Low'),(dip_val:$3000;dip_name:'Medium'),(dip_val:$0;dip_name:'High'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4000;name:'Enemy Power Decrease on Continue';number:2;dip:((dip_val:$4000;dip_name:'2 Dots'),(dip_val:$0;dip_name:'3 Dots'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 rom:array[0..$2ffff] of word;
 ram1:array[0..$fff] of word;
 ram2:array[0..$1fff] of word;
 sound_latch,prioridad,hippodrm_lsb:byte;
 proc_update_video:procedure;
 //HU 6280
 robocop_mcu_rom:array[0..$1ff] of byte;
 mcu_ram,mcu_shared_ram:array[0..$1fff] of byte;
 hippo_mcu_rom:array[0..$ffff] of byte;
 //8751
 i8751_return,i8751_command:word;
 i8751_ports:array[0..3] of byte;

procedure update_video_robocop;
var
  trans:byte;
begin
trans:=(prioridad and $4) shl 1;
if (prioridad and 1)<>0 then begin
  bac06_0.tile_2.update_pf(1,false,false);
  bac06_0.tile_3.update_pf(2,true,false);
  //Pri pant
  bac06_0.tile_2.show_pf;
  if (prioridad and $02)<>0 then bac06_0.draw_sprites($8,trans,3);
  bac06_0.tile_3.show_pf;
end else begin  //invertidas
  bac06_0.tile_3.update_pf(2,false,false);
  bac06_0.tile_2.update_pf(1,true,false);
  //Pri pant
  bac06_0.tile_3.show_pf;
  if (prioridad and $02)<>0 then bac06_0.draw_sprites($8,trans,3);
  bac06_0.tile_2.show_pf;
end;
if (prioridad and $02)<>0 then bac06_0.draw_sprites($8,trans xor $08,3)
	else bac06_0.draw_sprites(0,0,3);
//chars
bac06_0.tile_1.update_pf(0,true,false);
bac06_0.tile_1.show_pf;
actualiza_trozo_final(0,8,256,240,7);
end;

procedure update_video_baddudes;
begin
if (prioridad and 1)=0 then begin
  bac06_0.tile_2.update_pf(1,false,true);
  bac06_0.tile_3.update_pf(2,true,true);
  //Pri pant
  bac06_0.tile_2.show_pf;
  bac06_0.tile_3.show_pf;
  //prioridades
  if (prioridad and $2)<>0 then bac06_0.tile_2.show_pf_pri;
  bac06_0.draw_sprites(0,0,3);
  if (prioridad and $4)<>0 then bac06_0.tile_3.show_pf_pri;
end else begin  //invertidas
  bac06_0.tile_3.update_pf(2,false,true);
  bac06_0.tile_2.update_pf(1,true,true);
  //Pri pant
  bac06_0.tile_3.show_pf;
  bac06_0.tile_2.show_pf;
  //prioridades
  if (prioridad and $2)<>0 then bac06_0.tile_3.show_pf_pri;
  bac06_0.draw_sprites(0,0,3);
  if (prioridad and $4)<>0 then bac06_0.tile_2.show_pf_pri;
end;
//chars
bac06_0.tile_1.update_pf(0,true,false);
bac06_0.tile_1.show_pf;
actualiza_trozo_final(0,8,256,240,7);
end;

procedure update_video_hippo;
begin
if (prioridad and 1)<>0 then begin
  bac06_0.tile_2.update_pf(1,false,false);
  bac06_0.tile_3.update_pf(2,true,false);
  //Pri pant
  bac06_0.tile_2.show_pf;
  bac06_0.tile_3.show_pf;
end else begin  //invertidas
  bac06_0.tile_3.update_pf(2,false,false);
  bac06_0.tile_2.update_pf(1,true,false);
  //Pri pant
  bac06_0.tile_3.show_pf;
  bac06_0.tile_2.show_pf;
end;
bac06_0.draw_sprites(0,0,3);
//chars
bac06_0.tile_1.update_pf(0,true,false);
bac06_0.tile_1.show_pf;
actualiza_trozo_final(0,8,256,240,7);
end;

procedure eventos_dec0;
begin
if event.arcade then begin
  //P1+P2
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fffe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fffd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fffb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fff7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ffef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $ffdf) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.but2[0] then marcade.in0:=(marcade.in0 and $ffbf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.but3[0] then marcade.in0:=(marcade.in0 and $fffe) else marcade.in0:=(marcade.in0 or $80);
  if arcade_input.up[1] then marcade.in0:=(marcade.in0 and $feff) else marcade.in0:=(marcade.in0 or $100);
  if arcade_input.down[1] then marcade.in0:=(marcade.in0 and $fdff) else marcade.in0:=(marcade.in0 or $200);
  if arcade_input.left[1] then marcade.in0:=(marcade.in0 and $fbff) else marcade.in0:=(marcade.in0 or $400);
  if arcade_input.right[1] then marcade.in0:=(marcade.in0 and $f7ff) else marcade.in0:=(marcade.in0 or $800);
  if arcade_input.but0[1] then marcade.in0:=(marcade.in0 and $efff) else marcade.in0:=(marcade.in0 or $1000);
  if arcade_input.but1[1] then marcade.in0:=(marcade.in0 and $dfff) else marcade.in0:=(marcade.in0 or $2000);
  if arcade_input.but2[1] then marcade.in0:=(marcade.in0 and $bfff) else marcade.in0:=(marcade.in0 or $4000);
  if arcade_input.but3[1] then marcade.in0:=(marcade.in0 and $feff) else marcade.in0:=(marcade.in0 or $8000);
  //SYSTEM
  if arcade_input.but4[0] then marcade.in1:=(marcade.in1 and $fffe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.but4[1] then marcade.in1:=(marcade.in1 and $fffd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $fffb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $fff7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.coin[0] then marcade.in1:=(marcade.in1 and $ffef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.coin[1] then marcade.in1:=(marcade.in1 and $ffdf) else marcade.in1:=(marcade.in1 or $20);
end;
end;

procedure baddudes_principal;
var
  frame_m,frame_s,frame_mcu:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
frame_s:=m6502_0.tframes;
frame_mcu:=mcs51_0.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to 263 do begin
   m68000_0.run(frame_m);
   frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
   m6502_0.run(frame_s);
   frame_s:=frame_s+m6502_0.tframes-m6502_0.contador;
   mcs51_0.run(frame_mcu);
   frame_mcu:=frame_mcu+mcs51_0.tframes-mcs51_0.contador;
   case f of
      255:begin
            m68000_0.irq[6]:=HOLD_LINE;
            proc_update_video;
            marcade.in1:=marcade.in1 or $80;
          end;
      263:marcade.in1:=marcade.in1 and $7f;
   end;
 end;
 eventos_dec0;
 video_sync;
end;
end;

procedure hippodrome_principal;
var
  frame_m,frame_s,frame_mcu:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
frame_s:=m6502_0.tframes;
frame_mcu:=h6280_0.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to 263 do begin
   m68000_0.run(frame_m);
   frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
   m6502_0.run(frame_s);
   frame_s:=frame_s+m6502_0.tframes-m6502_0.contador;
   h6280_0.run(frame_mcu);
   frame_mcu:=frame_mcu+h6280_0.tframes-h6280_0.contador;
   case f of
      255:begin
            m68000_0.irq[6]:=HOLD_LINE;
            h6280_0.set_irq_line(0,HOLD_LINE);
            proc_update_video;
            marcade.in1:=marcade.in1 or $80;
          end;
      263:marcade.in1:=marcade.in1 and $7f;
   end;
 end;
 eventos_dec0;
 video_sync;
end;
end;

procedure robocop_principal;
var
  frame_m,frame_s,frame_mcu:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
frame_s:=m6502_0.tframes;
frame_mcu:=h6280_0.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to 263 do begin
   m68000_0.run(frame_m);
   frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
   m6502_0.run(frame_s);
   frame_s:=frame_s+m6502_0.tframes-m6502_0.contador;
   h6280_0.run(frame_mcu);
   frame_mcu:=frame_mcu+h6280_0.tframes-h6280_0.contador;
   case f of
      255:begin
            m68000_0.irq[6]:=HOLD_LINE;
            proc_update_video;
            marcade.in1:=marcade.in1 or $80;
          end;
      263:marcade.in1:=marcade.in1 and $7f;
   end;
 end;
 eventos_dec0;
 video_sync;
end;
end;

procedure cambiar_color(numero:word);
var
  color:tcolor;
begin
  color.r:=buffer_paleta[numero] and $ff;
  color.g:=buffer_paleta[numero] shr 8;
  color.b:=buffer_paleta[$400+numero] and $ff;
  set_pal_color(color,numero);
  case numero of
    $000..$0ff:bac06_0.tile_1.buffer_color[numero shr 4]:=true;
    $200..$2ff:bac06_0.tile_2.buffer_color[(numero shr 4) and $f]:=true;
    $300..$3ff:bac06_0.tile_3.buffer_color[(numero shr 4) and $f]:=true;
  end;
end;

function dec0_getword(direccion:dword):word;
begin
case direccion of
  $0..$5ffff:dec0_getword:=rom[direccion shr 1];
  $180000..$180fff:dec0_getword:=mcu_shared_ram[(direccion and $fff) shr 1];
  $242800..$243fff:dec0_getword:=ram1[(direccion-$242800) shr 1];
  $244000..$245fff:dec0_getword:=bac06_0.tile_1.data[(direccion and $1fff) shr 1];
  $24a000..$24a7ff:dec0_getword:=bac06_0.tile_2.data[(direccion and $7ff) shr 1];
  $24d000..$24d7ff:dec0_getword:=bac06_0.tile_3.data[(direccion and $7ff) shr 1];
  $30c000:dec0_getword:=marcade.in0;
  $30c002:dec0_getword:=marcade.in1;
  $30c004:dec0_getword:=marcade.dswa;
  $30c006:dec0_getword:=$ffff;
  $30c008:dec0_getword:=i8751_return;
  $310000..$3107ff:dec0_getword:=buffer_paleta[(direccion and $7ff) shr 1];
  $314000..$3147ff:dec0_getword:=buffer_paleta[((direccion and $7ff) shr 1)+$400];
  $ff8000..$ffbfff:dec0_getword:=ram2[(direccion and $3fff) shr 1];
  $ffc000..$ffcfff:dec0_getword:=buffer_sprites_w[(direccion and $7ff) shr 1];
end;
end;

procedure dec0_putword(direccion:dword;valor:word);
begin
case direccion of
    0..$5ffff:; //ROM
    $180000..$180fff:begin
                        mcu_shared_ram[(direccion and $fff) shr 1]:=valor and $ff;
                        if ((direccion and $fff)=$ffe) then h6280_0.set_irq_line(0,HOLD_LINE);
                     end;
    $240000..$240007:bac06_0.tile_1.change_control0((direccion and 7) shr 1,valor);
    $240010..$240017:bac06_0.tile_1.change_control1((direccion and 7) shr 1,valor);
    $242000..$24207f:bac06_0.tile_1.colscroll[(direccion and $7f) shr 1]:=valor;
    $242400..$2427ff:bac06_0.tile_1.rowscroll[(direccion and $3ff) shr 1]:=valor;
    $242800..$243fff:ram1[(direccion-$242800) shr 1]:=valor;
    $244000..$245fff:if bac06_0.tile_1.data[(direccion and $1fff) shr 1]<>valor then begin
                      bac06_0.tile_1.data[(direccion and $1fff) shr 1]:=valor;
                      gfx[0].buffer[(direccion and $1fff) shr 1]:=true;
                   end;
    $246000..$246007:bac06_0.tile_2.change_control0((direccion and 7) shr 1,valor);
    $246010..$246017:bac06_0.tile_2.change_control1((direccion and 7) shr 1,valor);
    $248000..$24807f:bac06_0.tile_2.colscroll[(direccion and $7f) shr 1]:=valor;
    $248400..$2487ff:bac06_0.tile_2.rowscroll[(direccion and $3ff) shr 1]:=valor;
    $24a000..$24a7ff:if bac06_0.tile_2.data[(direccion and $7ff) shr 1]<>valor then begin
                      bac06_0.tile_2.data[(direccion and $7ff) shr 1]:=valor;
                      gfx[1].buffer[(direccion and $7ff) shr 1]:=true;
                   end;
    $24c000..$24c007:bac06_0.tile_3.change_control0((direccion and 7) shr 1,valor);
    $24c010..$24c017:bac06_0.tile_3.change_control1((direccion and 7) shr 1,valor);
    $24c800..$24c87f:bac06_0.tile_3.colscroll[(direccion and $7f) shr 1]:=valor;
    $24cc00..$24cfff:bac06_0.tile_3.rowscroll[(direccion and $3ff) shr 1]:=valor;
    $24d000..$24d7ff:if bac06_0.tile_3.data[(direccion and $7ff) shr 1]<>valor then begin
                      bac06_0.tile_3.data[(direccion and $7ff) shr 1]:=valor;
                      gfx[2].buffer[(direccion and $7ff) shr 1]:=true;
                   end;
    $30c010..$30c01f:case (direccion and $f) of
                        0:prioridad:=valor and $ff;
                        2:bac06_0.update_sprite_data(@buffer_sprites_w);
                        4:begin
                            sound_latch:=valor and $ff;
                            m6502_0.change_nmi(PULSE_LINE);
                          end;
                        6:begin
                            i8751_command:=valor;
                            if (i8751_ports[2] and 8)<>0 then mcs51_0.change_irq1(ASSERT_LINE);
                          end;
                       $e:begin
                            i8751_command:=0;
                            i8751_return:=0;
                          end;
                   end;
    $310000..$3107ff:if buffer_paleta[(direccion and $7ff) shr 1]<>valor then begin
                      buffer_paleta[(direccion and $7ff) shr 1]:=valor;
                      cambiar_color((direccion and $7ff) shr 1);
                   end;
    $314000..$3147ff:if buffer_paleta[((direccion and $7ff) shr 1)+$400]<>valor then begin
                      buffer_paleta[((direccion and $7ff) shr 1)+$400]:=valor;
                      cambiar_color((direccion and $7ff) shr 1);
                   end;
    $ff8000..$ffbfff:ram2[(direccion and $3fff) shr 1]:=valor;
    $ffc000..$ffcfff:buffer_sprites_w[(direccion and $7ff) shr 1]:=valor;
end;
end;

function dec0_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$5ff,$8000..$ffff:dec0_snd_getbyte:=mem_snd[direccion];
  $3000:dec0_snd_getbyte:=sound_latch;
  $3800:dec0_snd_getbyte:=oki_6295_0.read;
end;
end;

procedure dec0_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$5ff:mem_snd[direccion]:=valor;
  $800:ym2203_0.Control(valor);
  $801:ym2203_0.Write(valor);
  $1000:ym3812_0.control(valor);
  $1001:ym3812_0.write(valor);
  $3800:oki_6295_0.write(valor);
  $8000..$ffff:; //ROM
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
  m6502_0.change_irq(irqstate);
end;

function in_port1:byte;
begin
  in_port1:=$ff;
end;

function in_port0:byte;
var
  res:byte;
begin
	res:=$ff;
	// P0 connected to latches
	if (i8751_ports[2] and $10)=0 then res:=res and (i8751_command shr 8);
	if (i8751_ports[2] and $20)=0 then res:=res and (i8751_command and $ff);
	in_port0:=res;
end;

procedure out_port0(valor:byte);
begin
  i8751_ports[0]:=valor;
end;

procedure out_port1(valor:byte);
begin
  i8751_ports[1]:=valor;
end;

procedure out_port3(valor:byte);
begin
  i8751_ports[3]:=valor;
end;

procedure out_port2(valor:byte);
begin
	if (((valor and 4)=0) and ((i8751_ports[2] and 4)<>0)) then m68000_0.irq[5]:=HOLD_LINE;
	if (valor and 8)=0 then mcs51_0.change_irq1(CLEAR_LINE);
	if (((valor and $40)<>0) and ((i8751_ports[2] and $40)=0)) then
    i8751_return:=(i8751_return and $ff00) or i8751_ports[0];
	if (((valor and $80)<>0) and ((i8751_ports[2] and $80)=0)) then
    i8751_return:=(i8751_return and $00ff) or (i8751_ports[0] shl 8);
	i8751_ports[2]:=valor;
end;

//Robocop
function robocop_mcu_getbyte(direccion:dword):byte;
begin
case direccion of
  $1e00..$1fff:robocop_mcu_getbyte:=robocop_mcu_rom[direccion and $1ff];
  $1f0000..$1f1fff:robocop_mcu_getbyte:=mcu_ram[direccion and $1fff];
  $1f2000..$1f3fff:robocop_mcu_getbyte:=mcu_shared_ram[direccion and $1fff];
end;
end;

procedure robocop_mcu_putbyte(direccion:dword;valor:byte);
begin
case direccion of
  0..$ffff:; //ROM
  $1f0000..$1f1fff:mcu_ram[direccion and $1fff]:=valor;
  $1f2000..$1f3fff:mcu_shared_ram[direccion and $1fff]:=valor;
  $1ff400..$1ff403:h6280_0.irq_status_w(direccion and $3,valor);
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
                      tempw:=bac06_0.tile_3.data[(direccion and $7ff) shr 1];
                      if (direccion and 1)<>0 then hippo_mcu_getbyte:=tempw shr 8
                        else hippo_mcu_getbyte:=tempw;
                   end;
  $1f0000..$1f1fff:hippo_mcu_getbyte:=mcu_ram[direccion and $1fff];
  $1ff402..$1ff403:hippo_mcu_getbyte:=marcade.in1 shr 7;
end;
end;

procedure hippo_mcu_putbyte(direccion:dword;valor:byte);
var
  tempw:word;
begin
case direccion of
  0..$ffff:; //ROM
  $180000..$1800ff:mcu_shared_ram[direccion and $ff]:=valor;
  $1a0000..$1a0007:begin
                      if (direccion and 1)<>0 then tempw:=(bac06_0.tile_3.control_0[(direccion and 7) shr 1] and $00ff) or (valor shl 8)
                        else tempw:=(bac06_0.tile_3.control_0[(direccion and 7) shr 1] and $ff00) or valor;
                      bac06_0.tile_3.change_control0((direccion and 7) shr 1,tempw);
                   end;
  $1a0010..$1a001f:begin
                      if (direccion and 1)<>0 then tempw:=(bac06_0.tile_3.control_1[(direccion and 7) shr 1] and $00ff) or (valor shl 8)
                        else tempw:=(bac06_0.tile_3.control_1[(direccion and 7) shr 1] and $ff00) or valor;
                      bac06_0.tile_3.change_control1((direccion and 7) shr 1,tempw);
                   end;
  $1a1000..$1a17ff:begin
                      if (direccion and 1)<>0 then tempw:=(bac06_0.tile_3.data[(direccion and $7ff) shr 1] and $00ff) or (valor shl 8)
                        else tempw:=(bac06_0.tile_3.data[(direccion and $7ff) shr 1] and $ff00) or valor;
                      bac06_0.tile_3.data[(direccion and $7ff) shr 1]:=tempw;
                      gfx[2].buffer[(direccion and $7ff) shr 1]:=true;
                   end;
  $1d0000..$1d00ff:hippodrm_lsb:=valor;
  $1f0000..$1f1fff:mcu_ram[direccion and $1fff]:=valor;
  $1ff400..$1ff403:h6280_0.irq_status_w(direccion and $3,valor);
end;
end;

//Main
procedure reset_dec0;
begin
 m68000_0.reset;
 m6502_0.reset;
 case main_vars.tipo_maquina of
  157:begin
        mcs51_0.reset;
        i8751_return:=0;
        i8751_command:=0;
        i8751_ports[0]:=0;
        i8751_ports[1]:=0;
        i8751_ports[2]:=0;
        i8751_ports[3]:=0;
      end;
  156,158:h6280_0.reset;
 end;
 ym3812_0.reset;
 ym2203_0.reset;
 oki_6295_0.reset;
 bac06_0.reset;
 reset_audio;
 marcade.in0:=$ffff;
 marcade.in1:=$ff7f;
 sound_latch:=0;
end;

function iniciar_dec0:boolean;
const
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
convert_gfx(0,0,@memoria_temp,@ps_x[8],@ps_y,false,false);
end;

procedure convert_tiles(num_gfx:byte;tl_num:word);
begin
init_gfx(num_gfx,16,16,tl_num);
gfx[num_gfx].trans[0]:=true;
gfx_set_desc_data(4,0,16*16,tl_num*16*16*1,tl_num*16*16*3,tl_num*16*16*0,tl_num*16*16*2);
convert_gfx(num_gfx,0,@memoria_temp,@ps_x,@ps_y,false,false);
end;

begin
iniciar_dec0:=false;
iniciar_audio(false);
//El video se inicia en el chip bac06!!!
//Main CPU
m68000_0:=cpu_m68000.create(10000000,264);
m68000_0.change_ram16_calls(dec0_getword,dec0_putword);
//Sound CPU
m6502_0:=cpu_m6502.create(1500000,264,TCPU_M6502);
m6502_0.change_ram_calls(dec0_snd_getbyte,dec0_snd_putbyte);
m6502_0.init_sound(dec0_sound_update);
//Sound Chips
ym3812_0:=ym3812_chip.create(YM3812_FM,3000000);
ym3812_0.change_irq_calls(snd_irq);
ym2203_0:=ym2203_chip.create(1500000);
oki_6295_0:=snd_okim6295.Create(1000000,OKIM6295_PIN7_HIGH);
case main_vars.tipo_maquina of
  156:begin  //Robocop
        bac06_0:=bac06_chip.create(false,true,true,$000,$200,$300,$fff,$7ff,$3ff,1,1,1,$100);
        //cargar roms
        if not(roms_load16w(@rom,robocop_rom)) then exit;
        //cargar sonido
        if not(roms_load(@mem_snd,robocop_sound)) then exit;
        //MCU
        h6280_0:=cpu_h6280.create(21477200 div 16,264);
        h6280_0.change_ram_calls(robocop_mcu_getbyte,robocop_mcu_putbyte);
        if not(roms_load(@robocop_mcu_rom,robocop_mcu)) then exit;
        //OKI rom
        if not(roms_load(oki_6295_0.get_rom_addr,robocop_oki)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,robocop_char)) then exit;
        convert_chars($1000);
        //tiles 1
        if not(roms_load(@memoria_temp,robocop_tiles1)) then exit;
        convert_tiles(1,$800);
        //tiles 2
        if not(roms_load(@memoria_temp,robocop_tiles2)) then exit;
        convert_tiles(2,$400);
        //sprites
        if not(roms_load(@memoria_temp,robocop_sprites)) then exit;
        convert_tiles(3,$1000);
        proc_update_video:=update_video_robocop;
        //Dip
        marcade.dswa:=$ff7f;
        marcade.dswa_val:=@robocop_dip;
      end;
  157:begin //Baddudes
        bac06_0:=bac06_chip.create(false,true,true,$000,$200,$300,$7ff,$7ff,$3ff,1,1,1,$100);
        //cargar roms
        if not(roms_load16w(@rom,baddudes_rom)) then exit;
        //cargar sonido
        if not(roms_load(@mem_snd,baddudes_sound)) then exit;
        //MCU
        mcs51_0:=cpu_mcs51.create(8000000,264);
        mcs51_0.change_io_calls(in_port0,in_port1,in_port1,in_port1,out_port0,out_port1,out_port2,out_port3);
        if not(roms_load(mcs51_0.get_rom_addr,baddudes_mcu)) then exit;
        //OKI rom
        if not(roms_load(oki_6295_0.get_rom_addr,baddudes_oki)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,baddudes_char)) then exit;
        convert_chars($800);
        //tiles 1
        if not(roms_load(@memoria_temp,baddudes_tiles1)) then exit;
        convert_tiles(1,$800);
        //tiles 2, ordenar
        if not(roms_load(@memoria_temp,baddudes_tiles2)) then exit;
        copymemory(@memoria_temp[$8000],@memoria_temp[$20000],$8000);
        copymemory(@memoria_temp[$0],@memoria_temp[$28000],$8000);
        copymemory(@memoria_temp[$18000],@memoria_temp[$30000],$8000);
        copymemory(@memoria_temp[$10000],@memoria_temp[$38000],$8000);
        convert_tiles(2,$400);
        //sprites
        if not(roms_load(@memoria_temp,baddudes_sprites)) then exit;
        convert_tiles(3,$1000);
        proc_update_video:=update_video_baddudes;
        //Dip
        marcade.dswa:=$ffff;
        marcade.dswa_val:=@baddudes_dip;
      end;
  158:begin  //Hippodrome
        bac06_0:=bac06_chip.create(false,true,true,$000,$200,$300,$fff,$3ff,$3ff,1,1,1,$100);
        //cargar roms
        if not(roms_load16w(@rom,hippo_rom)) then exit;
        //cargar sonido
        if not(roms_load(@mem_snd,hippo_sound)) then exit;
        //MCU+decrypt
        h6280_0:=cpu_h6280.create(21477200 div 16,264);
        h6280_0.change_ram_calls(hippo_mcu_getbyte,hippo_mcu_putbyte);
        if not(roms_load(@hippo_mcu_rom,hippo_mcu)) then exit;
        for f:=0 to $ffff do hippo_mcu_rom[f]:=bitswap8(hippo_mcu_rom[f],0,6,5,4,3,2,1,7);
        hippo_mcu_rom[$189]:=$60; // RTS prot area
	      hippo_mcu_rom[$1af]:=$60; // RTS prot area
	      hippo_mcu_rom[$1db]:=$60; // RTS prot area
	      hippo_mcu_rom[$21a]:=$60; // RTS prot area
        //OKI rom
        if not(roms_load(oki_6295_0.get_rom_addr,hippo_oki)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,hippo_char)) then exit;
        convert_chars($1000);
        //tiles 1
        if not(roms_load(@memoria_temp,hippo_tiles1)) then exit;
        convert_tiles(1,$400);
        //tiles 2
        if not(roms_load(@memoria_temp,hippo_tiles2)) then exit;
        convert_tiles(2,$400);
        //sprites
        if not(roms_load(@memoria_temp,hippo_sprites)) then exit;
        convert_tiles(3,$1000);
        proc_update_video:=update_video_hippo;
        //Dip
        marcade.dswa:=$ffff;
        marcade.dswa_val:=@hippo_dip;
      end;
end;
//final
reset_dec0;
iniciar_dec0:=true;
end;

procedure cargar_dec0;
begin
case main_vars.tipo_maquina of
  156:llamadas_maquina.bucle_general:=robocop_principal;
  157:llamadas_maquina.bucle_general:=baddudes_principal;
  158:llamadas_maquina.bucle_general:=hippodrome_principal;
end;
llamadas_maquina.iniciar:=iniciar_dec0;
llamadas_maquina.reset:=reset_dec0;
llamadas_maquina.fps_max:=57.392103;
end;

end.
