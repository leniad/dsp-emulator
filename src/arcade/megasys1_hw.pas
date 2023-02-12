unit megasys1_hw;

interface

uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m68000,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     ym_2151,sound_engine,oki6295,misc_functions;

function iniciar_megasys1:boolean;

implementation
const
        pant_0_16:array[0..1,0..15] of byte=(
        (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15),
        (16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31));
        pant_1_16:array[0..3,0..7] of byte=(
        (0,1,2,3,4,5,6,7),(8,9,10,11,12,13,14,15),
        (16,17,18,19,20,21,22,23),(24,25,26,27,28,29,30,31));
        pant_2_16:array[0..7,0..3] of byte=(
        (0,1,2,3),(4,5,6,7),(8,9,10,11),(12,13,14,15),
        (16,17,18,19),(20,21,22,23),(24,25,26,27),(28,29,30,31));
        pant_3_16:array[0..15,0..1] of byte=(
        (0,1),(2,3),(4,5),(6,7),(8,9),(10,11),(12,13),(14,15),
        (16,17),(18,19),(20,21),(22,23),(24,25),(26,27),(28,29),(30,31));
        //P47
        p47_rom:array[0..1] of tipo_roms=(
        (n:'p47us3.bin';l:$20000;p:0;crc:$022e58b8),(n:'p47us1.bin';l:$20000;p:$1;crc:$ed926bd8));
        p47_sound:array[0..1] of tipo_roms=(
        (n:'p47j_9.bin';l:$10000;p:0;crc:$ffcf318e),(n:'p47j_19.bin';l:$10000;p:$1;crc:$adb8c12e));
        p47_scr0:array[0..2] of tipo_roms=(
        (n:'p47j_5.bin';l:$20000;p:0;crc:$fe65b65c),(n:'p47j_6.bin';l:$20000;p:$20000;crc:$e191d2d2),
        (n:'p47j_7.bin';l:$20000;p:$40000;crc:$f77723b7));
        p47_scr1:array[0..2] of tipo_roms=(
        (n:'p47j_23.bin';l:$20000;p:0;crc:$6e9bc864),(n:'p47j_23.bin';l:$20000;p:$20000;crc:$6e9bc864),
        (n:'p47j_12.bin';l:$20000;p:$40000;crc:$5268395f));
        p47_scr2:tipo_roms=(n:'p47us16.bin';l:$10000;p:0;crc:$5a682c8f);
        p47_sprites:array[0..3] of tipo_roms=(
        (n:'p47j_27.bin';l:$20000;p:0;crc:$9e2bde8e),(n:'p47j_18.bin';l:$20000;p:$20000;crc:$29d8f676),
        (n:'p47j_26.bin';l:$20000;p:$40000;crc:$4d07581a),(n:'p47j_26.bin';l:$20000;p:$60000;crc:$4d07581a));
        p47_oki1:array[0..1] of tipo_roms=(
        (n:'p47j_20.bin';l:$20000;p:0;crc:$2ed53624),(n:'p47j_21.bin';l:$20000;p:$20000;crc:$6f56b56d));
        p47_oki2:array[0..1] of tipo_roms=(
        (n:'p47j_10.bin';l:$20000;p:0;crc:$b9d79c1e),(n:'p47j_11.bin';l:$20000;p:$20000;crc:$fa0d1887));
        p47_pri:tipo_roms=(n:'p-47.14m';l:$200;p:0;crc:$1d877538);
        p47_dip:array [0..7] of def_dip=(
        (mask:$0003;name:'Lives';number:4;dip:((dip_val:$2;dip_name:'2'),(dip_val:$3;dip_name:'3'),(dip_val:$1;dip_name:'4'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0030;name:'Difficulty';number:4;dip:((dip_val:$0;dip_name:'Easy'),(dip_val:$30;dip_name:'Normal'),(dip_val:$20;dip_name:'Hard'),(dip_val:$10;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0080;name:'Flip Screen';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0700;name:'Coin A';number:8;dip:((dip_val:$100;dip_name:'4C 1C'),(dip_val:$200;dip_name:'3C 1C'),(dip_val:$300;dip_name:'2C 1C'),(dip_val:$700;dip_name:'1C 1C'),(dip_val:$600;dip_name:'1C 2C'),(dip_val:$500;dip_name:'1C 3C'),(dip_val:$400;dip_name:'1C 4C'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),(),(),(),())),
        (mask:$3800;name:'Coin B';number:8;dip:((dip_val:$800;dip_name:'4C 1C'),(dip_val:$1000;dip_name:'3C 1C'),(dip_val:$1800;dip_name:'2C 1C'),(dip_val:$3800;dip_name:'1C 1C'),(dip_val:$3000;dip_name:'1C 2C'),(dip_val:$2800;dip_name:'1C 3C'),(dip_val:$2000;dip_name:'1C 4C'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),(),(),(),())),
        (mask:$4000;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$4000;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8000;name:'Invulnerability';number:2;dip:((dip_val:$8000;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        //Rod-Land
        rodland_rom:array[0..3] of tipo_roms=(
        (n:'jaleco_rod_land_2.rom2';l:$20000;p:0;crc:$c7e00593),(n:'jaleco_rod_land_1.rom1';l:$20000;p:$1;crc:$2e748ca1),
        (n:'jaleco_rod_land_3.rom3';l:$10000;p:$40000;crc:$62fdf6d7),(n:'jaleco_rod_land_4.rom4';l:$10000;p:$40001;crc:$44163c86));
        rodland_sound:array[0..1] of tipo_roms=(
        (n:'jaleco_rod_land_5.rom5';l:$10000;p:0;crc:$c1617c28),(n:'jaleco_rod_land_6.rom6';l:$10000;p:$1;crc:$663392b2));
        rodland_scr0:tipo_roms=(n:'lh534h31.rom14';l:$80000;p:0;crc:$8201e1bb);
        rodland_scr1:tipo_roms=(n:'lh534h32.rom18';l:$80000;p:0;crc:$f3b30ca6);
        rodland_scr2:tipo_roms=(n:'lh2311j0.rom19';l:$20000;p:0;crc:$124d7e8f);
        rodland_sprites:tipo_roms=(n:'lh534h33.rom23';l:$80000;p:0;crc:$936db174);
        rodland_oki1:tipo_roms=(n:'lh5321t5.rom10';l:$40000;p:0;crc:$e1d1cd99);
        rodland_oki2:tipo_roms=(n:'s202000dr.rom8';l:$40000;p:0;crc:$8a49d3a7);
        rodland_pri:tipo_roms=(n:'ps89013a.14m';l:$200;p:0;crc:$8914e72d);
        rodland_dip:array [0..7] of def_dip=(
        (mask:$000c;name:'Lives';number:4;dip:((dip_val:$4;dip_name:'2'),(dip_val:$c;dip_name:'3'),(dip_val:$8;dip_name:'4'),(dip_val:$0;dip_name:'Infinite'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0010;name:'Default Episode';number:2;dip:((dip_val:$10;dip_name:'1'),(dip_val:$0;dip_name:'2'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0060;name:'Difficulty';number:4;dip:((dip_val:$0;dip_name:'Easy'),(dip_val:$60;dip_name:'Normal'),(dip_val:$20;dip_name:'Hard'),(dip_val:$40;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0080;name:'Flip Screen';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0700;name:'Coin A';number:8;dip:((dip_val:$300;dip_name:'3C 1C'),(dip_val:$200;dip_name:'2C 1C'),(dip_val:$700;dip_name:'1C 1C'),(dip_val:$300;dip_name:'1C 2C'),(dip_val:$500;dip_name:'1C 3C'),(dip_val:$100;dip_name:'1C 4C'),(dip_val:$600;dip_name:'1C 5C'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),(),(),(),())),
        (mask:$3800;name:'Coin B';number:8;dip:((dip_val:$0;dip_name:'4C 1C'),(dip_val:$2000;dip_name:'3C 1C'),(dip_val:$1000;dip_name:'2C 1C'),(dip_val:$3800;dip_name:'1C 1C'),(dip_val:$1800;dip_name:'1C 2C'),(dip_val:$2800;dip_name:'1C 3C'),(dip_val:$800;dip_name:'1C 4C'),(dip_val:$3000;dip_name:'1C 5C'),(),(),(),(),(),(),(),())),
        (mask:$4000;name:'Demo Sounds';number:2;dip:((dip_val:$4000;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        //saint dragon
        stdragon_rom:array[0..1] of tipo_roms=(
        (n:'jsd-02.bin';l:$20000;p:0;crc:$cc29ab19),(n:'jsd-01.bin';l:$20000;p:$1;crc:$67429a57));
        stdragon_sound:array[0..1] of tipo_roms=(
        (n:'jsd-05.bin';l:$10000;p:0;crc:$8c04feaa),(n:'jsd-06.bin';l:$10000;p:$1;crc:$0bb62f3a));
        stdragon_scr0:array[0..3] of tipo_roms=(
        (n:'jsd-11.bin';l:$20000;p:0;crc:$2783b7b1),(n:'jsd-12.bin';l:$20000;p:$20000;crc:$89466ab7),
        (n:'jsd-13.bin';l:$20000;p:$40000;crc:$9896ae82),(n:'jsd-14.bin';l:$20000;p:$60000;crc:$7e8da371));
        stdragon_scr1:array[0..3] of tipo_roms=(
        (n:'jsd-15.bin';l:$20000;p:0;crc:$e296bf59),(n:'jsd-16.bin';l:$20000;p:$20000;crc:$d8919c06),
        (n:'jsd-17.bin';l:$20000;p:$40000;crc:$4f7ad563),(n:'jsd-18.bin';l:$20000;p:$60000;crc:$1f4da822));
        stdragon_scr2:tipo_roms=(n:'jsd-19.bin';l:$10000;p:0;crc:$25ce807d);
        stdragon_sprites:array[0..3] of tipo_roms=(
        (n:'jsd-20.bin';l:$20000;p:0;crc:$2c6e93bb),(n:'jsd-21.bin';l:$20000;p:$20000;crc:$864bcc61),
        (n:'jsd-22.bin';l:$20000;p:$40000;crc:$44fe2547),(n:'jsd-23.bin';l:$20000;p:$60000;crc:$6b010e1a));
        stdragon_oki1:array[0..1] of tipo_roms=(
        (n:'jsd-09.bin';l:$20000;p:0;crc:$e366bc5a),(n:'jsd-10.bin';l:$20000;p:$20000;crc:$4a8f4fe6));
        stdragon_oki2:array[0..1] of tipo_roms=(
        (n:'jsd-07.bin';l:$20000;p:0;crc:$6a48e979),(n:'jsd-08.bin';l:$20000;p:$20000;crc:$40704962));
        stdragon_pri:tipo_roms=(n:'prom.14m';l:$200;p:0;crc:$1d877538);
        stdragon_dip:array [0..7] of def_dip=(
        (mask:$0003;name:'Lives';number:4;dip:((dip_val:$2;dip_name:'2'),(dip_val:$3;dip_name:'3'),(dip_val:$1;dip_name:'4'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0030;name:'Difficulty';number:4;dip:((dip_val:$0;dip_name:'Easy'),(dip_val:$30;dip_name:'Normal'),(dip_val:$20;dip_name:'Hard'),(dip_val:$10;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0040;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$40;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0080;name:'Flip Screen';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0700;name:'Coin A';number:8;dip:((dip_val:$100;dip_name:'4C 1C'),(dip_val:$200;dip_name:'3C 1C'),(dip_val:$300;dip_name:'2C 1C'),(dip_val:$700;dip_name:'1C 1C'),(dip_val:$600;dip_name:'1C 2C'),(dip_val:$500;dip_name:'1C 3C'),(dip_val:$400;dip_name:'1C 4C'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),(),(),(),())),
        (mask:$3800;name:'Coin B';number:8;dip:((dip_val:$800;dip_name:'4C 1C'),(dip_val:$1000;dip_name:'3C 1C'),(dip_val:$1800;dip_name:'2C 1C'),(dip_val:$3800;dip_name:'1C 1C'),(dip_val:$3000;dip_name:'1C 2C'),(dip_val:$2800;dip_name:'1C 3C'),(dip_val:$2000;dip_name:'1C 4C'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),(),(),(),())),
        (mask:$4000;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$4000;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        //64th street
        th64_rom:array[0..1] of tipo_roms=(
        (n:'64th_03.rom';l:$40000;p:0;crc:$ed6c6942),(n:'64th_02.rom';l:$40000;p:$1;crc:$0621ed1d));
        th64_sound:array[0..1] of tipo_roms=(
        (n:'64th_08.rom';l:$10000;p:0;crc:$632be0c1),(n:'64th_07.rom';l:$10000;p:$1;crc:$13595d01));
        th64_scr0:tipo_roms=(n:'64th_01.rom';l:$80000;p:0;crc:$06222f90);
        th64_scr1:tipo_roms=(n:'64th_06.rom';l:$80000;p:0;crc:$2bfcdc75);
        th64_scr2:tipo_roms=(n:'64th_09.rom';l:$20000;p:0;crc:$a4a97db4);
        th64_sprites:array[0..1] of tipo_roms=(
        (n:'64th_05.rom';l:$80000;p:$0;crc:$a89a7020),(n:'64th_04.rom';l:$80000;p:$80000;crc:$98f83ef6));
        th64_oki1:tipo_roms=(n:'64th_11.rom';l:$20000;p:0;crc:$b0b8a65c);
        th64_oki2:tipo_roms=(n:'64th_10.rom';l:$40000;p:0;crc:$a3390561);
        th64_pri:tipo_roms=(n:'pr91009.12';l:$200;p:0;crc:$c69423d6);
        th64_dip_a:array [0..2] of def_dip=(
        (mask:$0f;name:'Coin A';number:11;dip:((dip_val:$07;dip_name:'4C 1C'),(dip_val:$08;dip_name:'3C 1C'),(dip_val:$09;dip_name:'2C 1C'),(dip_val:$0f;dip_name:'1C 1C'),(dip_val:$06;dip_name:'2C 3C'),(dip_val:$0e;dip_name:'1C 2C'),(dip_val:$0d;dip_name:'1C 3C'),(dip_val:$0c;dip_name:'1C 4C'),(dip_val:$0b;dip_name:'1C 5C'),(dip_val:$0a;dip_name:'1C 6C'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),())),
        (mask:$f0;name:'Coin B';number:11;dip:((dip_val:$70;dip_name:'4C 1C'),(dip_val:$80;dip_name:'3C 1C'),(dip_val:$90;dip_name:'2C 1C'),(dip_val:$f0;dip_name:'1C 1C'),(dip_val:$60;dip_name:'2C 3C'),(dip_val:$e0;dip_name:'1C 2C'),(dip_val:$d0;dip_name:'1C 3C'),(dip_val:$c0;dip_name:'1C 4C'),(dip_val:$b0;dip_name:'1C 5C'),(dip_val:$a0;dip_name:'1C 6C'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),())),());
        th64_dip_b:array [0..5] of def_dip=(
        (mask:$1;name:'Flip Screen';number:2;dip:((dip_val:$1;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2;name:'Demo Sounds';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Allow Continue';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$4;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$18;name:'Difficulty';number:4;dip:((dip_val:$10;dip_name:'Easy'),(dip_val:$18;dip_name:'Normal'),(dip_val:$8;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$60;name:'Lives';number:4;dip:((dip_val:$40;dip_name:'1'),(dip_val:$60;dip_name:'2'),(dip_val:$20;dip_name:'3'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),());

type
  tlayer_info=record
    scr_ram:array[0..$1fff] of word;
    scroll_x,scroll_y:word;
    es_8x8:boolean;
    filas,info,char_mask:word;
  end;

var
 rom:array[0..$3ffff] of word;
 ram,ram_snd:array[0..$7fff] of word;
 rom_snd:array[0..$ffff] of word;
 vregs_ram:array[0..$1ff] of word;
 obj_ram:array[0..$fff] of word;
 layer_scr:array[0..2] of tlayer_info;
 sound_latch,sound_latch2,active_layer:word;
 prioridad:array[0..$f] of dword;
 sprite_bank:byte;
 sprites_split:boolean;
 //Protecciones
 mcu_hs:boolean;
 mcu_hs_ram:array[0..9] of word;
 ip_select:word;
 ip_select_values:array[0..7] of byte;

procedure update_video_megasys1;
var
  f,layer:byte;
  trans:boolean;

procedure poner_sprites(pri:byte);
var
  f,sprite,nchar,atrib,color,x,pos_obj,pos_sprite,y:word;
  flipx,flipy:boolean;
begin
for f:=0 to $ff do begin
  for sprite:=0 to 3 do begin
      pos_obj:=(f*4)+$400*sprite;
      pos_sprite:=$4000+((obj_ram[pos_obj] and $7f)*8);
      atrib:=ram[pos_sprite+4];
      //Si la prioridad es 2, los tengo que poner todos!!
      if ((((atrib shr 3) and 1)<>pri) and (pri<>2)) then continue;
      if (((atrib and $c0) shr 6)<>sprite) then	continue;	//flipping
      // apply the position displacements
			x:=(ram[pos_sprite+5]+obj_ram[pos_obj+1]) and $1ff;
			y:=(ram[pos_sprite+6]+obj_ram[pos_obj+2]) and $1ff;
			flipx:=(atrib and $40)<>0;
			flipy:=(atrib and $80)<>0;
			// sprite code is displaced as well
			nchar:=((ram[pos_sprite+7]+obj_ram[pos_obj+$3]) and $fff)+((sprite_bank and 1) shl 12);
			color:=(atrib and $f) shl 4;
      put_gfx_sprite(nchar and $fff,768+color,flipx,flipy,3);
      actualiza_gfx_sprite(x,y,4,3);
  end;
end;
end;

procedure poner_pant_16(layer:byte;trans:boolean);
var
  x,y,f,nchar,color,pos:word;
begin
for f:=0 to $1fff do begin
  case layer_scr[layer].filas of
    16:begin
        x:=f and $ff;
        y:=f shr 8;
      end;
    8:begin
        x:=f and $7f;
        y:=f shr 7;
      end;
    4:begin
        x:=f and $3f;
        y:=f shr 6;
      end;
    2:begin
        x:=f and $1f;
        y:=f shr 5;
      end;
  end;
  pos:=(x shl 4)+(y shr 4)*$100*layer_scr[layer].filas+(y and $f);
  nchar:=layer_scr[layer].scr_ram[pos];
  color:=nchar shr 12;
  if (gfx[layer].buffer[pos] or buffer_color[color+(layer*$10)]) then begin
    color:=(color shl 4)+($100*layer);
    nchar:=((nchar and $fff)*4) and layer_scr[layer].char_mask;
    if trans then begin
      put_gfx_trans(x*16,y*16,nchar,color,layer+1,layer);
      put_gfx_trans(x*16,y*16+8,nchar+1,color,layer+1,layer);
      put_gfx_trans(x*16+8,y*16,nchar+2,color,layer+1,layer);
      put_gfx_trans(x*16+8,y*16+8,nchar+3,color,layer+1,layer);
    end else begin
      put_gfx(x*16,y*16,nchar,color,layer+1,layer);
      put_gfx(x*16,y*16+8,nchar+1,color,layer+1,layer);
      put_gfx(x*16+8,y*16,nchar+2,color,layer+1,layer);
      put_gfx(x*16+8,y*16+8,nchar+3,color,layer+1,layer);
    end;
    gfx[layer].buffer[pos]:=false;
  end;
  end;
end;

procedure poner_pant_8(layer:byte;trans:boolean);
var
  x,y,f,nchar,color,pos:word;
begin
for f:=0 to $1fff do begin
  case layer_scr[layer].filas of
    8:begin
        x:=f and $ff;
        y:=f shr 8;
      end;
    4:begin
        x:=f and $7f;
        y:=f shr 7;
      end;
    2:begin
        x:=f and $3f;
        y:=f shr 6;
      end;
  end;
  pos:=(x shl 5)+(y shr 5)*$400*layer_scr[layer].filas+(y and $1f);
  nchar:=layer_scr[layer].scr_ram[pos];
  color:=nchar shr 12;
  if (gfx[layer].buffer[pos] or buffer_color[color+(layer*$10)]) then begin
    if trans then put_gfx_trans(x*8,y*8,nchar and $fff,(color shl 4)+($100*layer),layer+1,layer)
      else put_gfx(x*8,y*8,nchar and $fff,(color shl 4)+($100*layer),layer+1,layer);
    gfx[layer].buffer[pos]:=false;
  end;
end;
end;

begin
trans:=false;
for f:=4 downto 0 do begin
  layer:=(prioridad[(active_layer shr 8) and $f] shr (f*4)) and $f;
  case layer of
    0,1,2:if (((active_layer and (1 shl layer))<>0) or (not(trans))) then begin
            if layer_scr[layer].es_8x8 then begin //layer 8x8
              poner_pant_8(layer,trans);
              scroll_x_y(layer+1,4,layer_scr[layer].scroll_x,layer_scr[layer].scroll_y);
            end else begin //layer 16x16
              poner_pant_16(layer,trans);
              scroll_x_y(layer+1,4,layer_scr[layer].scroll_x,layer_scr[layer].scroll_y);
            end;
            trans:=true;
          end;
        3:if (active_layer and 8)<>0 then begin  //Sprites
            if sprites_split then poner_sprites(0)
              else poner_sprites(2);
          end;
        4:if (((active_layer and 8)<>0) and sprites_split) then poner_sprites(1);  //Sprites
  end;
end;
actualiza_trozo_final(0,16,256,224,4);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure eventos_megasys1;
begin
if event.arcade then begin
  //P1
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fffe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fffd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fffb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fff7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ffef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $ffdf) else marcade.in0:=(marcade.in0 or $20);
  //P2
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $fffe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fffd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $fffb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $fff7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $ffef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $ffdf) else marcade.in1:=(marcade.in1 or $20);
  //COIN
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 and $fffe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 and $fffd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 and $ffbf) else marcade.in2:=(marcade.in2 or $40);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $ff7f) else marcade.in2:=(marcade.in2 or $80);
end;
end;

procedure megasys1_a_principal;
var
  frame_m,frame_s:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
frame_s:=m68000_1.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to 261 do begin
   //Main CPU
   m68000_0.run(frame_m);
   frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
   //Sound CPU
   m68000_1.run(frame_s);
   frame_s:=frame_s+m68000_1.tframes-m68000_1.contador;
   case f of
    127:m68000_0.irq[3]:=HOLD_LINE;
    239:begin
          update_video_megasys1;
          m68000_0.irq[2]:=HOLD_LINE;
        end;
    15:m68000_0.irq[1]:=HOLD_LINE;
   end;
 end;
 eventos_megasys1;
 video_sync;
end;
end;

function megasys1_a_getword(direccion:dword):word;
begin
direccion:=direccion and $fffff;
case direccion of
  $0..$7ffff:if (mcu_hs and (((mcu_hs_ram[4] shl 6) and $3ffc0)=(direccion and $3ffc0))) then megasys1_a_getword:=$835d
                else megasys1_a_getword:=rom[direccion shr 1];
  $80000:megasys1_a_getword:=marcade.in2;
  $80002:megasys1_a_getword:=marcade.in0;
  $80004:megasys1_a_getword:=marcade.in1;
  $80006:megasys1_a_getword:=marcade.dswa;
  $80008:megasys1_a_getword:=sound_latch2;
  $84000..$843ff:megasys1_a_getword:=vregs_ram[(direccion and $3ff) shr 1];
  $88000..$887ff:megasys1_a_getword:=buffer_paleta[(direccion and $7ff) shr 1];
  $8e000..$8ffff:megasys1_a_getword:=obj_ram[(direccion and $1fff) shr 1];
  $90000..$93fff:megasys1_a_getword:=layer_scr[0].scr_ram[(direccion and $3fff) shr 1];
  $94000..$97fff:megasys1_a_getword:=layer_scr[1].scr_ram[(direccion and $3fff) shr 1];
  $98000..$9bfff:megasys1_a_getword:=layer_scr[2].scr_ram[(direccion and $3fff) shr 1];
  $f0000..$fffff:megasys1_a_getword:=ram[(direccion and $ffff) shr 1];
end;
end;

procedure cambiar_color(tmp_color,numero:word);
var
  color:tcolor;
  r,g,b:byte;
begin
  r:=((tmp_color and $f000) shr 11) or ((tmp_color and 8) shr 3);
	g:=((tmp_color and $0f00) shr 7) or ((tmp_color and 4) shr 2);
	b:=((tmp_color and $00f0) shr 3) or ((tmp_color and 2) shr 1);
  color.r:=pal5bit(r);
  color.g:=pal5bit(g);
  color.b:=pal5bit(b);
  set_pal_color(color,numero);
  case numero of
    0..$ff:buffer_color[numero shr 4]:=true;
    $100..$1ff:buffer_color[((numero shr 4) and $f)+$10]:=true;
    $200..$2ff:buffer_color[((numero shr 4) and $f)+$20]:=true;
  end;
end;

procedure cambiar_layer(layer:byte;valor:word);
const
  scan_val_16:array[0..3] of word=(16,8,4,2);
  scan_val_8:array[0..3] of word=(8,4,4,2);
  scan_val_8_col:array[0..3] of word=(1,2,2,4);
var
  mask_x,mask_y,cols:word;
begin
layer_scr[layer].info:=valor;
layer_scr[layer].es_8x8:=(((valor shr 4) and 1)<>0);
if not(layer_scr[layer].es_8x8) then begin //16x16
  layer_scr[layer].filas:=scan_val_16[valor and $3];
  cols:=scan_val_16[3-(valor and $3)];
end else begin
  layer_scr[layer].filas:=scan_val_8[valor and $3];
  cols:=scan_val_8_col[valor and $3];
end;
mask_x:=(layer_scr[layer].filas*256)-1;
mask_y:=(cols*256)-1;
screen_mod_scroll(layer+1,layer_scr[layer].filas*256,256,mask_x,cols*256,256,mask_y);
fillchar(gfx[layer].buffer,$2000,1);
end;

procedure megasys1_a_putword(direccion:dword;valor:word);
begin
direccion:=direccion and $fffff;
case direccion of
    0..$23fef,$23ffa..$7ffff:;
    $23ff0..$23ff9:begin
                      mcu_hs_ram[(direccion and $f) shr 1]:=valor;
                      mcu_hs:=(((mcu_hs_ram[0]=0) and (mcu_hs_ram[1]=$0055) and (mcu_hs_ram[2]=$00aa) and (mcu_hs_ram[3]=$00ff)) and (((direccion and $f) shr 1)=4));
                   end;
    $84000..$843ff:begin
                      vregs_ram[(direccion and $3ff) shr 1]:=valor;
                      case (direccion and $3ff) of
                        $000:if active_layer<>valor then begin
                               active_layer:=valor;
                               if (active_layer and 1)<>0 then fillchar(gfx[0].buffer,$2000,1);
                               if (active_layer and 2)<>0 then fillchar(gfx[1].buffer,$2000,1);
                               if (active_layer and 4)<>0 then fillchar(gfx[2].buffer,$2000,1);
                             end;
                        $008:layer_scr[2].scroll_x:=valor;
                        $00a:layer_scr[2].scroll_y:=valor;
                        $00c:if layer_scr[2].info<>valor then cambiar_layer(2,valor);
                        $100:sprites_split:=(valor and $100)<>0;
                        $200:layer_scr[0].scroll_x:=valor;
                        $202:layer_scr[0].scroll_y:=valor;
                        $204:if layer_scr[0].info<>valor then cambiar_layer(0,valor);
                        $208:layer_scr[1].scroll_x:=valor;
                        $20a:layer_scr[1].scroll_y:=valor;
                        $20c:if layer_scr[1].info<>valor then cambiar_layer(1,valor);
                        $300:if (valor and $10)<>0 then m68000_1.change_reset(ASSERT_LINE)
                                else m68000_1.change_reset(CLEAR_LINE);
                        $308:begin
                                sound_latch:=valor;
                                m68000_1.irq[4]:=HOLD_LINE;
                             end;
                      end;
                   end;
    $88000..$887ff:if buffer_paleta[(direccion and $7ff) shr 1]<>valor then begin
                      buffer_paleta[(direccion and $7ff) shr 1]:=valor;
                      cambiar_color(valor,(direccion and $7ff) shr 1);
                   end;
    $8e000..$8ffff:obj_ram[(direccion and $1fff) shr 1]:=valor;
    $90000..$93fff:if (layer_scr[0].scr_ram[(direccion and $3fff) shr 1]<>valor) then begin
                      layer_scr[0].scr_ram[(direccion and $3fff) shr 1]:=valor;
                      gfx[0].buffer[(direccion and $3fff) shr 1]:=true;
                   end;
    $94000..$97fff:if (layer_scr[1].scr_ram[(direccion and $3fff) shr 1]<>valor) then begin
                      layer_scr[1].scr_ram[(direccion and $3fff) shr 1]:=valor;
                      gfx[1].buffer[(direccion and $3fff) shr 1]:=true;
                   end;
    $98000..$9bfff:if (layer_scr[2].scr_ram[(direccion and $3fff) shr 1]<>valor) then begin
                      layer_scr[2].scr_ram[(direccion and $3fff) shr 1]:=valor;
                      gfx[2].buffer[(direccion and $3fff) shr 1]:=true;
                   end;
    $f0000..$fffff:ram[(direccion and $ffff) shr 1]:=valor;
  end;
end;

function megasys1_snd_a_getword(direccion:dword):word;
begin
case direccion of
  0..$1ffff:megasys1_snd_a_getword:=rom_snd[direccion shr 1];
  $40000,$60000:megasys1_snd_a_getword:=sound_latch;
  $80002:megasys1_snd_a_getword:=ym2151_0.status;
  $a0000:megasys1_snd_a_getword:=0;//oki_6295_0.read;
  $c0000:megasys1_snd_a_getword:=0;//oki_6295_1.read;
  $e0000..$fffff:megasys1_snd_a_getword:=ram_snd[(direccion and $ffff) shr 1];
end;
end;

procedure megasys1_snd_a_putword(direccion:dword;valor:word);
begin
case direccion of
  0..$1ffff:;
  $40000,$60000:sound_latch2:=valor;
  $80000:ym2151_0.reg(valor);
  $80002:ym2151_0.write(valor);
  $a0000,$a0002:oki_6295_0.write(valor);
  $c0000,$c0002:oki_6295_1.write(valor);
  $e0000..$fffff:ram_snd[(direccion and $ffff) shr 1]:=valor;
end;
end;

procedure megasys1_sound_update;
begin
  ym2151_0.update;
  oki_6295_0.update;
  oki_6295_1.update;
end;

procedure snd_irq(irqstate:byte);
begin
  if irqstate=1 then m68000_1.irq[4]:=HOLD_LINE;
end;

//Megasys C
procedure megasys1_c_principal;
var
  frame_m,frame_s:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
frame_s:=m68000_1.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to 261 do begin
   //Main CPU
   m68000_0.run(frame_m);
   frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
   //Sound CPU
   m68000_1.run(frame_s);
   frame_s:=frame_s+m68000_1.tframes-m68000_1.contador;
   case f of
    127:m68000_0.irq[1]:=HOLD_LINE;
    239:begin
          update_video_megasys1;
          m68000_0.irq[4]:=HOLD_LINE;
        end;
    261:m68000_0.irq[2]:=HOLD_LINE;
   end;
 end;
 eventos_megasys1;
 video_sync;
end;
end;

function megasys1_c_getword(direccion:dword):word;
begin
direccion:=direccion and $1fffff;
case direccion of
  $0..$7ffff:megasys1_c_getword:=rom[direccion shr 1];
  $c2000..$c23ff:megasys1_c_getword:=vregs_ram[(direccion and $3ff) shr 1];
  $c8000:megasys1_c_getword:=sound_latch2;
  $d2000..$d3fff:megasys1_c_getword:=obj_ram[(direccion and $1fff) shr 1];
  $d8000:megasys1_c_getword:=ip_select;
  $e0000..$e7fff:megasys1_c_getword:=layer_scr[0].scr_ram[(direccion and $3fff) shr 1];
  $e8000..$effff:megasys1_c_getword:=layer_scr[1].scr_ram[(direccion and $3fff) shr 1];
  $f0000..$f7fff:megasys1_c_getword:=layer_scr[2].scr_ram[(direccion and $3fff) shr 1];
  $f8000..$f87ff:megasys1_c_getword:=buffer_paleta[(direccion and $7ff) shr 1];
  $1c0000..$1fffff:megasys1_c_getword:=ram[(direccion and $ffff) shr 1];
end;
end;

procedure megasys1_c_putword(direccion:dword;valor:word);

procedure ip_select_prot(valor:word);
var
  f:byte;
begin
  for f:=0 to 7 do if ((valor and $ff)=ip_select_values[f]) then break;
	case f of
			0:ip_select:=marcade.in2;
			1:ip_select:=marcade.in0;
			2:ip_select:=marcade.in1;
			3:ip_select:=marcade.dswa;
			4:ip_select:=marcade.dswb;
			5:ip_select:=$0d; // startup check?
			6:ip_select:=$06; // sent before each other command
			else exit; // get out if it wasn't a valid request
	end;
	// if the command is valid, generate an IRQ from the MCU
  m68000_0.irq[2]:=HOLD_LINE;
end;

begin
direccion:=direccion and $1fffff;
case direccion of
    0..$7ffff:;
    $c2000..$c23ff:begin
                      vregs_ram[(direccion and $3ff) shr 1]:=valor;
                      case (direccion and $3ff) of
                        $000:layer_scr[0].scroll_x:=valor;
                        $002:layer_scr[0].scroll_y:=valor;
                        $004:if layer_scr[0].info<>valor then cambiar_layer(0,valor);
                        $008:layer_scr[1].scroll_x:=valor;
                        $00a:layer_scr[1].scroll_y:=valor;
                        $00c:if layer_scr[1].info<>valor then cambiar_layer(1,valor);
                        $100:layer_scr[2].scroll_x:=valor;
                        $102:layer_scr[2].scroll_y:=valor;
                        $104:if layer_scr[2].info<>valor then cambiar_layer(2,valor);
                        $108:sprite_bank:=valor and 1;
                        $200:sprites_split:=(valor and $100)<>0;
                        $208:if active_layer<>valor then begin
                               active_layer:=valor;
                               if (active_layer and 1)<>0 then fillchar(gfx[0].buffer,$2000,1);
                               if (active_layer and 2)<>0 then fillchar(gfx[1].buffer,$2000,1);
                               if (active_layer and 4)<>0 then fillchar(gfx[2].buffer,$2000,1);
                             end;
                        $308:if (valor and $10)<>0 then begin
                                m68000_1.change_reset(ASSERT_LINE);
                                ym2151_0.reset;
                                oki_6295_0.reset;
                                oki_6295_1.reset;
                             end else m68000_1.change_reset(CLEAR_LINE);
                      end;
                    end;
    $c8000:begin
              sound_latch:=valor;
              m68000_1.irq[2]:=HOLD_LINE;
            end;
    $d2000..$d3fff:obj_ram[(direccion and $1fff) shr 1]:=valor;
    $d8000:ip_select_prot(valor);
    $e0000..$e7fff:if (layer_scr[0].scr_ram[(direccion and $3fff) shr 1]<>valor) then begin
                      layer_scr[0].scr_ram[(direccion and $3fff) shr 1]:=valor;
                      gfx[0].buffer[(direccion and $3fff) shr 1]:=true;
                   end;
    $e8000..$effff:if (layer_scr[1].scr_ram[(direccion and $3fff) shr 1]<>valor) then begin
                      layer_scr[1].scr_ram[(direccion and $3fff) shr 1]:=valor;
                      gfx[1].buffer[(direccion and $3fff) shr 1]:=true;
                   end;
    $f0000..$f7fff:if (layer_scr[2].scr_ram[(direccion and $3fff) shr 1]<>valor) then begin
                      layer_scr[2].scr_ram[(direccion and $3fff) shr 1]:=valor;
                      gfx[2].buffer[(direccion and $3fff) shr 1]:=true;
                   end;
    $f8000..$f87ff:if buffer_paleta[(direccion and $7ff) shr 1]<>valor then begin
                      buffer_paleta[(direccion and $7ff) shr 1]:=valor;
                      cambiar_color(valor,(direccion and $7ff) shr 1);
                   end;
    $1c0000..$1fffff:ram[(direccion and $ffff) shr 1]:=valor;
  end;
end;

//Main
procedure reset_megasys1;
var
  f:byte;
begin
 m68000_0.reset;
 m68000_1.reset;
 ym2151_0.reset;
 oki_6295_0.reset;
 oki_6295_1.reset;
 reset_audio;
 marcade.in0:=$ffff;
 marcade.in1:=$ffff;
 marcade.in2:=$ffff;
 sound_latch:=0;
 sound_latch2:=0;
 sprite_bank:=0;
 active_layer:=$ff;
 sprites_split:=false;
 for f:=0 to 2 do begin
  layer_scr[f].scroll_x:=0;
  layer_scr[f].scroll_y:=0;
  layer_scr[f].es_8x8:=true;
  layer_scr[f].filas:=4;
  layer_scr[f].info:=$ffff;
 end;
 ip_select:=6;
 mcu_hs:=false;
end;

function iniciar_megasys1:boolean;
procedure decript_phantasm(dest,source:pword);
var
  f:dword;
  x,y:word;
begin
	for f:=0 to $1ffff do begin
		x:=source^;
    inc(source);
		if (f<($8000 div 2)) then begin
      if ((f or ($248 div 2))<>f) then y:=BITSWAP16(x,$d,$e,$f,$0,$1,$8,$9,$a,$b,$c,$5,$6,$7,$2,$3,$4)
        else y:=BITSWAP16(x,$f,$d,$b,$9,$7,$5,$3,$1,$e,$c,$a,$8,$6,$4,$2,$0);
    end else if	(f<($10000 div 2)) then begin
          y:=BITSWAP16(x,$0,$1,$2,$3,$4,$5,$6,$7,$b,$a,$9,$8,$f,$e,$d,$c);
        end else if	(f<($18000 div 2)) then begin
            if ((f or ($248 div 2))<>f) then y:=BITSWAP16(x,$d,$e,$f,$0,$1,$8,$9,$a,$b,$c,$5,$6,$7,$2,$3,$4)
              else y:=BITSWAP16(x,$f,$d,$b,$9,$7,$5,$3,$1,$e,$c,$a,$8,$6,$4,$2,$0);
          end	else if	(f<($20000 div 2)) then y:=BITSWAP16(x,$f,$d,$b,$9,$7,$5,$3,$1,$e,$c,$a,$8,$6,$4,$2,$0)
            else y:=BITSWAP16(x,$0,$1,$2,$3,$4,$5,$6,$7,$b,$a,$9,$8,$f,$e,$d,$c);
    dest^:=y;
    inc(dest);
  end;  //del for
end;
procedure decript_rodland(dest,source:pword);
var
  f:dword;
  x,y:word;
begin
	for f:=0 to $1ffff do begin
		x:=source^;
    inc(source);
		if (f<$4000) then begin
      if ((f or $124)<>f) then y:=BITSWAP16(x,$d,$0,$a,$9,$6,$e,$b,$f,$5,$c,$7,$2,$3,$8,$1,$4)
        else y:=BITSWAP16(x,$4,$5,$6,$7,$0,$1,$2,$3,$b,$a,$9,$8,$f,$e,$d,$c);
    end else if	(f<$8000) then begin
      if ((f or $124)<>f) then y:=BITSWAP16(x,$f,$d,$b,$9,$c,$e,$0,$7,$5,$3,$1,$8,$a,$2,$4,$6)
        else y:=BITSWAP16(x,$4,$5,$1,$2,$e,$d,$3,$b,$a,$9,$6,$7,$0,$8,$f,$c);
    end else if	(f<$c000) then begin
      if ((f or $124)<>f) then y:=BITSWAP16(x,$d,$0,$a,$9,$6,$e,$b,$f,$5,$c,$7,$2,$3,$8,$1,$4)
        else y:=BITSWAP16(x,$4,$5,$6,$7,$0,$1,$2,$3,$b,$a,$9,$8,$f,$e,$d,$c);
    end	else if	(f<$10000) then y:=BITSWAP16(x,$4,$5,$6,$7,$0,$1,$2,$3,$b,$a,$9,$8,$f,$e,$d,$c)
      else y:=BITSWAP16(x,$4,$5,$1,$2,$e,$d,$3,$b,$a,$9,$6,$7,$0,$8,$f,$c);
    dest^:=y;
    inc(dest);
  end;  //del for
end;
procedure decode_gfx_rodland(rom:pbyte);
var
  f,i:dword;
  buffer:pbyte;
begin
  // data lines swap: 76543210 -> 64537210
	for f:=0 to $7ffff do rom[f]:=BITSWAP8(rom[f],6,4,5,3,7,2,1,0);
  getmem(buffer,$80000);
	copymemory(buffer,rom,$80000);
	// address lines swap: ..dcba9876543210 -> ..acb8937654d210
	for f:=0 to $7ffff do begin
    i:=BITSWAP24(f,$17,$16,$15,$14,$13,$12,$11,$10,$f,$e,$a,$c,$b,8,9,3,7,6,5,4,$d,2,1,0);
		rom[f]:=buffer[i];
	end;
  freemem(buffer);
end;
const
  ps_x:array[0..15] of dword=(0*4,1*4,2*4,3*4,4*4,5*4,6*4,7*4,
		4*8*16+0*4,4*8*16+1*4,4*8*16+2*4,4*8*16+3*4,4*8*16+4*4,4*8*16+5*4,4*8*16+6*4,4*8*16+7*4);
  ps_y:array[0..15] of dword=(0*4*8, 1*4*8, 2*4*8, 3*4*8, 4*4*8, 5*4*8, 6*4*8, 7*4*8,
		8*4*8, 9*4*8, 10*4*8, 11*4*8, 12*4*8, 13*4*8, 14*4*8, 15*4*8);
var
  memoria_temp:pbyte;
  mem_prom:array[0..$1ff] of byte;
  memoria_w,ptemp:pword;

procedure convert_chars(ngfx:byte;num:dword);
begin
  init_gfx(ngfx,8,8,num);
  gfx[ngfx].trans[15]:=true;
  gfx_set_desc_data(4,0,8*8*4,0,1,2,3);
  convert_gfx(ngfx,0,memoria_temp,@ps_x[0],@ps_y[0],false,false);
end;

procedure convert_sprites(ngfx:byte;num:dword);
begin
  init_gfx(ngfx,16,16,num);
  gfx[ngfx].trans[15]:=true;
  gfx_set_desc_data(4,0,16*16*4,0,1,2,3);
  convert_gfx(ngfx,0,memoria_temp,@ps_x[0],@ps_y[0],false,false);
end;

procedure convert_pri;
var
  pri_code,offset,enable_mask:byte;
  layers_order:array[0..1] of integer; // 2 layers orders (split sprites on/off)
  i,top,top_mask,result,opacity,layer,order,layer0,layer1:integer;
begin
for pri_code:=0 to $f do begin	// 16 priority codes
		for offset:=0 to 1 do begin
			enable_mask:=$f;	// start with every layer enabled
			layers_order[offset]:=$fffff;
			repeat
				top:=mem_prom[pri_code*$20+offset+enable_mask*2] and 3;	// this must be the top layer
				top_mask:=1 shl top;
				result:=0;		// result of the feasibility check for this layer
				for i:=0 to $f do begin	// every combination of opaque and transparent pens
					opacity:=i and enable_mask;	// only consider active layers
					layer:=mem_prom[pri_code*$20+offset+opacity*2];
					if (opacity<>0) then begin
						if (opacity and top_mask)<>0 then begin
							if (layer<>top)	then result:=result or 1;	// error: opaque pens aren't always opaque!
						end else begin
							if (layer=top) then	result:=result or 2	// transparent pen is opaque
							  else result:=result or 4;	// transparent pen is transparent
						end;
					end; //opacity
				end; //del for i
				//  note: 3210 means that layer 0 is the bottom layer
        //  (the order is reversed in the hand-crafted data)
				layers_order[offset]:=((layers_order[offset] shl 4) or top ) and $fffff;
				enable_mask:=enable_mask and not(top_mask);
				if (result and 1)<>0 then begin
					layers_order[offset]:=$fffff;
					break;
				end;
				if  ((result and 6)=6) then begin
					layers_order[offset]:=$fffff;
					break;
				end;
				if (result=2)	then enable_mask:=0; // totally opaque top layer
			until (enable_mask=0);
    end; //for  offset
		// merge the two layers orders
		order:=$fffff;
    i:=5;
		while i>0 do begin // 5 layers to write
			layer0:=layers_order[0] and $0f;
			layer1:=layers_order[1] and $0f;
			if (layer0<>3) then begin	// 0,1,2 or f
				if (layer1=3) then begin
					layer:=4;
					layers_order[0]:=layers_order[0] shl 4;	// layer1 won't change next loop
				end	else begin
					layer:=layer0;
					if (layer0<>layer1) then begin
						order:=$fffff;
						break;
					end;
				end;
			end else begin // layer0 = 3;
				if (layer1=3) then begin
					layer:=$43;			// 4 must always be present
					order:=order shl 4;
					i:=i-1;					// 2 layers written at once
				end else begin
					layer:=3;
					layers_order[1]:=layers_order[1] shl 4;	// layer1 won't change next loop
				end;
			end;
			// reverse the order now
			order:=(order shl 4) or layer;
			i:=i-1;		// layer written
			layers_order[0]:=layers_order[0] shr 4;
			layers_order[1]:=layers_order[1] shr 4;
		end; // for i merging
		prioridad[pri_code]:=order and $fffff;	// at last!
end;	//del for pri_code
end;

begin
iniciar_megasys1:=false;
llamadas_maquina.bucle_general:=megasys1_a_principal;
llamadas_maquina.reset:=reset_megasys1;
llamadas_maquina.fps_max:=56.191350;
iniciar_audio(true);
screen_init(1,4096,4096,true);
screen_mod_scroll(1,512,256,511,512,256,511);
screen_init(2,4096,4096,true);
screen_mod_scroll(2,512,256,511,512,256,511);
screen_init(3,4096,4096,true);
screen_mod_scroll(3,512,256,511,512,256,511);
screen_init(4,512,512,false,true);
iniciar_video(256,224);
getmem(memoria_temp,$100000);
getmem(memoria_w,$60000);
//Sound CPU
m68000_1:=cpu_m68000.create(7000000,262);
m68000_1.change_ram16_calls(megasys1_snd_a_getword,megasys1_snd_a_putword);
m68000_1.init_sound(megasys1_sound_update);
//Sound Chips
oki_6295_0:=snd_okim6295.Create(4000000,OKIM6295_PIN7_HIGH);
oki_6295_1:=snd_okim6295.Create(4000000,OKIM6295_PIN7_HIGH);
ym2151_0:=ym2151_chip.create(3500000);
ym2151_0.change_irq_func(snd_irq);
layer_scr[0].char_mask:=$3fff;
layer_scr[1].char_mask:=$3fff;
layer_scr[2].char_mask:=$1fff;
case main_vars.tipo_maquina of
  138:begin //P-47
        //Main CPU
        m68000_0:=cpu_m68000.create(6000000,262);
        m68000_0.change_ram16_calls(megasys1_a_getword,megasys1_a_putword);
        //cargar roms
        if not(roms_load16w(@rom,p47_rom)) then exit;
        //cargar sonido
        if not(roms_load16w(@rom_snd,p47_sound)) then exit;
        //OKI Sounds
        if not(roms_load(oki_6295_0.get_rom_addr,p47_oki1)) then exit;
        if not(roms_load(oki_6295_1.get_rom_addr,p47_oki2)) then exit;
        //scroll 0
        if not(roms_load(memoria_temp,p47_scr0)) then exit;
        convert_chars(0,$4000);
        //scroll 1
        if not(roms_load(memoria_temp,p47_scr1)) then exit;
        convert_chars(1,$4000);
        //scroll 2
        if not(roms_load(memoria_temp,p47_scr2)) then exit;
        convert_chars(2,$1000);
        //Sprites
        if not(roms_load(memoria_temp,p47_sprites)) then exit;
        convert_sprites(3,$1000);
        //Prioridades
        if not(roms_load(@mem_prom,p47_pri)) then exit;
        convert_pri;
        //DIP
        marcade.dswa:=$ffff;
        marcade.dswa_val:=@p47_dip;
      end;
  139:begin  //Rodland
        //Main CPU
        m68000_0:=cpu_m68000.create(6000000,262);
        m68000_0.change_ram16_calls(megasys1_a_getword,megasys1_a_putword);
        //cargar roms
        if not(roms_load16w(memoria_w,rodland_rom)) then exit;
        decript_rodland(@rom,memoria_w);
        ptemp:=memoria_w;
        inc(ptemp,$20000);
        copymemory(@rom[$20000],ptemp,$20000);
        //cargar sonido
        if not(roms_load16w(@rom_snd,rodland_sound)) then exit;
        //OKI Sounds
        if not(roms_load(oki_6295_0.get_rom_addr,rodland_oki1)) then exit;
        if not(roms_load(oki_6295_1.get_rom_addr,rodland_oki2)) then exit;
        //scroll 0 y ordenar
        if not(roms_load(memoria_temp,rodland_scr0)) then exit;
        decode_gfx_rodland(memoria_temp);
        convert_chars(0,$4000);
        //scroll 1
        if not(roms_load(memoria_temp,rodland_scr1)) then exit;
        convert_chars(1,$4000);
        //scroll 2
        if not(roms_load(memoria_temp,rodland_scr2)) then exit;
        convert_chars(2,$1000);
        //Sprites y ordenar
        if not(roms_load(memoria_temp,rodland_sprites)) then exit;
        decode_gfx_rodland(memoria_temp);
        convert_sprites(3,$1000);
        //Prioridades
        if not(roms_load(@mem_prom,rodland_pri)) then exit;
        convert_pri;
        //DIP
        marcade.dswa:=$bfff;
        marcade.dswa_val:=@rodland_dip;
      end;
  140:begin //Saint Dragon
        //Main CPU
        m68000_0:=cpu_m68000.create(6000000,262);
        m68000_0.change_ram16_calls(megasys1_a_getword,megasys1_a_putword);
        //cargar roms
        if not(roms_load16w(memoria_w,stdragon_rom)) then exit;
        decript_phantasm(@rom,memoria_w);
        //cargar sonido
        if not(roms_load16w(@rom_snd,stdragon_sound)) then exit;
        //OKI Sounds
        if not(roms_load(oki_6295_0.get_rom_addr,stdragon_oki1)) then exit;
        if not(roms_load(oki_6295_1.get_rom_addr,stdragon_oki2)) then exit;
        //scroll 0
        if not(roms_load(memoria_temp,stdragon_scr0)) then exit;
        convert_chars(0,$4000);
        //scroll 1
        if not(roms_load(memoria_temp,stdragon_scr1)) then exit;
        convert_chars(1,$4000);
        //scroll 2
        if not(roms_load(memoria_temp,stdragon_scr2)) then exit;
        convert_chars(2,$1000);
        //Sprites
        if not(roms_load(memoria_temp,stdragon_sprites)) then exit;
        convert_sprites(3,$1000);
        //Prioridades
        if not(roms_load(@mem_prom,stdragon_pri)) then exit;
        convert_pri;
        marcade.dswa:=$ffbf;
        marcade.dswa_val:=@stdragon_dip;
      end;
  337:begin //64th street
        llamadas_maquina.bucle_general:=megasys1_c_principal;
        //Main CPU
        m68000_0:=cpu_m68000.create(12000000,262);
        m68000_0.change_ram16_calls(megasys1_c_getword,megasys1_c_putword);
        //cargar roms
        if not(roms_load16w(@rom,th64_rom)) then exit;
        //cargar sonido
        if not(roms_load16w(@rom_snd,th64_sound)) then exit;
        //OKI Sounds
        if not(roms_load(oki_6295_0.get_rom_addr,th64_oki1)) then exit;
        if not(roms_load(oki_6295_1.get_rom_addr,th64_oki2)) then exit;
        //scroll 0
        if not(roms_load(memoria_temp,th64_scr0)) then exit;
        convert_chars(0,$4000);
        //scroll 1
        if not(roms_load(memoria_temp,th64_scr1)) then exit;
        convert_chars(1,$4000);
        //scroll 2
        if not(roms_load(memoria_temp,th64_scr2)) then exit;
        convert_chars(2,$1000);
        //Sprites
        if not(roms_load(memoria_temp,th64_sprites)) then exit;
        convert_sprites(3,$2000);
        //Prioridades
        if not(roms_load(@mem_prom,th64_pri)) then exit;
        convert_pri;
        //Proteccion
        ip_select_values[0]:=$57;
        ip_select_values[1]:=$53;
        ip_select_values[2]:=$54;
        ip_select_values[3]:=$55;
        ip_select_values[4]:=$56;
        ip_select_values[5]:=$fa;
        ip_select_values[6]:=$06;
        //DIP
        marcade.dswa:=$ff;
        marcade.dswa_val:=@th64_dip_a;
        marcade.dswb:=$bd;
        marcade.dswb_val:=@th64_dip_b;
      end;
end;
//final
freemem(memoria_temp);
freemem(memoria_w);
reset_megasys1;
iniciar_megasys1:=true;
end;

end.
