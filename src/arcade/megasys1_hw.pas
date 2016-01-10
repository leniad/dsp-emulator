unit megasys1_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m68000,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     ym_2151,sound_engine,oki6295,misc_functions;

procedure Cargar_megasys1;
procedure megasys1_principal;
function iniciar_megasys1:boolean;
procedure reset_megasys1;
procedure cerrar_megasys1;
//Main CPU
function megasys1_a_getword(direccion:dword):word;
procedure megasys1_a_putword(direccion:dword;valor:word);
//Sound CPU
function megasys1_snd_a_getword(direccion:dword):word;
procedure megasys1_snd_a_putword(direccion:dword;valor:word);
procedure megasys1_sound_update;
procedure snd_irq(irqstate:byte);

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
        p47_rom:array[0..2] of tipo_roms=(
        (n:'p47us3.bin';l:$20000;p:0;crc:$022e58b8),(n:'p47us1.bin';l:$20000;p:$1;crc:$ed926bd8),());
        p47_sound:array[0..2] of tipo_roms=(
        (n:'p47j_9.bin';l:$10000;p:0;crc:$ffcf318e),(n:'p47j_19.bin';l:$10000;p:$1;crc:$adb8c12e),());
        p47_scr0:array[0..3] of tipo_roms=(
        (n:'p47j_5.bin';l:$20000;p:0;crc:$fe65b65c),(n:'p47j_6.bin';l:$20000;p:$20000;crc:$e191d2d2),
        (n:'p47j_7.bin';l:$20000;p:$40000;crc:$f77723b7),());
        p47_scr1:array[0..3] of tipo_roms=(
        (n:'p47j_23.bin';l:$20000;p:0;crc:$6e9bc864),(n:'p47j_23.bin';l:$20000;p:$20000;crc:$6e9bc864),
        (n:'p47j_12.bin';l:$20000;p:$40000;crc:$5268395f),());
        p47_scr2:tipo_roms=(n:'p47us16.bin';l:$10000;p:0;crc:$5a682c8f);
        p47_sprites:array[0..4] of tipo_roms=(
        (n:'p47j_27.bin';l:$20000;p:0;crc:$9e2bde8e),(n:'p47j_18.bin';l:$20000;p:$20000;crc:$29d8f676),
        (n:'p47j_26.bin';l:$20000;p:$40000;crc:$4d07581a),(n:'p47j_26.bin';l:$20000;p:$60000;crc:$4d07581a),());
        p47_oki1:array[0..2] of tipo_roms=(
        (n:'p47j_20.bin';l:$20000;p:0;crc:$2ed53624),(n:'p47j_21.bin';l:$20000;p:$20000;crc:$6f56b56d),());
        p47_oki2:array[0..2] of tipo_roms=(
        (n:'p47j_10.bin';l:$20000;p:0;crc:$b9d79c1e),(n:'p47j_11.bin';l:$20000;p:$20000;crc:$fa0d1887),());
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
        rodland_rom:array[0..4] of tipo_roms=(
        (n:'rl_02.rom';l:$20000;p:0;crc:$c7e00593),(n:'rl_01.rom';l:$20000;p:$1;crc:$2e748ca1),
        (n:'rl_03.rom';l:$10000;p:$40000;crc:$62fdf6d7),(n:'rl_04.rom';l:$10000;p:$40001;crc:$44163c86),());
        rodland_sound:array[0..2] of tipo_roms=(
        (n:'rl_05.rom';l:$10000;p:0;crc:$c1617c28),(n:'rl_06.rom';l:$10000;p:$1;crc:$663392b2),());
        rodland_scr0:tipo_roms=(n:'rl_23.rom';l:$80000;p:0;crc:$ac60e771);
        rodland_scr1:tipo_roms=(n:'rl_18.rom';l:$80000;p:0;crc:$f3b30ca6);
        rodland_scr2:tipo_roms=(n:'rl_19.bin';l:$20000;p:0;crc:$124d7e8f);
        rodland_sprites:tipo_roms=(n:'rl_14.rom';l:$80000;p:0;crc:$08d01bf4);
        rodland_oki1:tipo_roms=(n:'rl_10.rom';l:$40000;p:0;crc:$e1d1cd99);
        rodland_oki2:tipo_roms=(n:'rl_08.rom';l:$40000;p:0;crc:$8a49d3a7);
        rodland_pri:tipo_roms=(n:'rl.bin';l:$200;p:0;crc:$8914e72d);
        rodland_dip:array [0..7] of def_dip=(
        (mask:$000c;name:'Lives';number:4;dip:((dip_val:$4;dip_name:'2'),(dip_val:$c;dip_name:'3'),(dip_val:$8;dip_name:'4'),(dip_val:$0;dip_name:'Infinite'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0010;name:'Default Episode';number:2;dip:((dip_val:$10;dip_name:'1'),(dip_val:$0;dip_name:'2'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0060;name:'Difficulty';number:4;dip:((dip_val:$0;dip_name:'Easy'),(dip_val:$60;dip_name:'Normal'),(dip_val:$20;dip_name:'Hard'),(dip_val:$40;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0080;name:'Flip Screen';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0700;name:'Coin A';number:8;dip:((dip_val:$300;dip_name:'3C 1C'),(dip_val:$200;dip_name:'2C 1C'),(dip_val:$700;dip_name:'1C 1C'),(dip_val:$300;dip_name:'1C 2C'),(dip_val:$500;dip_name:'1C 3C'),(dip_val:$100;dip_name:'1C 4C'),(dip_val:$600;dip_name:'1C 5C'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),(),(),(),())),
        (mask:$3800;name:'Coin B';number:8;dip:((dip_val:$0;dip_name:'4C 1C'),(dip_val:$2000;dip_name:'3C 1C'),(dip_val:$1000;dip_name:'2C 1C'),(dip_val:$3800;dip_name:'1C 1C'),(dip_val:$1800;dip_name:'1C 2C'),(dip_val:$2800;dip_name:'1C 3C'),(dip_val:$800;dip_name:'1C 4C'),(dip_val:$3000;dip_name:'1C 5C'),(),(),(),(),(),(),(),())),
        (mask:$4000;name:'Demo Sounds';number:2;dip:((dip_val:$4000;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        //saint dragon
        stdragon_rom:array[0..2] of tipo_roms=(
        (n:'jsd-02.bin';l:$20000;p:0;crc:$cc29ab19),(n:'jsd-01.bin';l:$20000;p:$1;crc:$67429a57),());
        stdragon_sound:array[0..2] of tipo_roms=(
        (n:'jsd-05.bin';l:$10000;p:0;crc:$8c04feaa),(n:'jsd-06.bin';l:$10000;p:$1;crc:$0bb62f3a),());
        stdragon_scr0:array[0..4] of tipo_roms=(
        (n:'jsd-11.bin';l:$20000;p:0;crc:$2783b7b1),(n:'jsd-12.bin';l:$20000;p:$20000;crc:$89466ab7),
        (n:'jsd-13.bin';l:$20000;p:$40000;crc:$9896ae82),(n:'jsd-14.bin';l:$20000;p:$60000;crc:$7e8da371),());
        stdragon_scr1:array[0..4] of tipo_roms=(
        (n:'jsd-15.bin';l:$20000;p:0;crc:$e296bf59),(n:'jsd-16.bin';l:$20000;p:$20000;crc:$d8919c06),
        (n:'jsd-17.bin';l:$20000;p:$40000;crc:$4f7ad563),(n:'jsd-18.bin';l:$20000;p:$60000;crc:$1f4da822),());
        stdragon_scr2:tipo_roms=(n:'jsd-19.bin';l:$10000;p:0;crc:$25ce807d);
        stdragon_sprites:array[0..4] of tipo_roms=(
        (n:'jsd-20.bin';l:$20000;p:0;crc:$2c6e93bb),(n:'jsd-21.bin';l:$20000;p:$20000;crc:$864bcc61),
        (n:'jsd-22.bin';l:$20000;p:$40000;crc:$44fe2547),(n:'jsd-23.bin';l:$20000;p:$60000;crc:$6b010e1a),());
        stdragon_oki1:array[0..2] of tipo_roms=(
        (n:'jsd-09.bin';l:$20000;p:0;crc:$e366bc5a),(n:'jsd-10.bin';l:$20000;p:$20000;crc:$4a8f4fe6),());
        stdragon_oki2:array[0..2] of tipo_roms=(
        (n:'jsd-07.bin';l:$20000;p:0;crc:$6a48e979),(n:'jsd-08.bin';l:$20000;p:$20000;crc:$40704962),());
        stdragon_pri:tipo_roms=(n:'prom.14m';l:$200;p:0;crc:$1d877538);
        stdragon_dip:array [0..7] of def_dip=(
        (mask:$0003;name:'Lives';number:4;dip:((dip_val:$2;dip_name:'2'),(dip_val:$3;dip_name:'3'),(dip_val:$1;dip_name:'4'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0030;name:'Difficulty';number:4;dip:((dip_val:$0;dip_name:'Easy'),(dip_val:$30;dip_name:'Normal'),(dip_val:$20;dip_name:'Hard'),(dip_val:$10;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0040;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$40;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0080;name:'Flip Screen';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0700;name:'Coin A';number:8;dip:((dip_val:$100;dip_name:'4C 1C'),(dip_val:$200;dip_name:'3C 1C'),(dip_val:$300;dip_name:'2C 1C'),(dip_val:$700;dip_name:'1C 1C'),(dip_val:$600;dip_name:'1C 2C'),(dip_val:$500;dip_name:'1C 3C'),(dip_val:$400;dip_name:'1C 4C'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),(),(),(),())),
        (mask:$3800;name:'Coin B';number:8;dip:((dip_val:$800;dip_name:'4C 1C'),(dip_val:$1000;dip_name:'3C 1C'),(dip_val:$1800;dip_name:'2C 1C'),(dip_val:$3800;dip_name:'1C 1C'),(dip_val:$3000;dip_name:'1C 2C'),(dip_val:$2800;dip_name:'1C 3C'),(dip_val:$2000;dip_name:'1C 4C'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),(),(),(),())),
        (mask:$4000;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$4000;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

type
  tlayer_info=record
    scr_ram:array[0..$1fff] of word;
    scroll_x,scroll_y:word;
    es_8x8:boolean;
    filas,cols,info:word;
    mask_x,mask_y:word;
  end;

var
 rom:array[0..$2ffff] of word;
 ram:array[0..$7fff] of word;
 rom_snd,ram_snd:array[0..$ffff] of word;
 vregs_ram:array[0..$1ff] of word;
 obj_ram:array[0..$fff] of word;
 layer_scr:array[0..2] of tlayer_info;
 sound_latch,sound_latch2,active_layer:word;
 prioridad:array[0..$f] of dword;
 sprite_bank:byte;
 sprites_split,mcu_hs:boolean;
 mcu_hs_ram:array[0..9] of word;

procedure Cargar_megasys1;
begin
llamadas_maquina.iniciar:=iniciar_megasys1;
llamadas_maquina.bucle_general:=megasys1_principal;
llamadas_maquina.cerrar:=cerrar_megasys1;
llamadas_maquina.reset:=reset_megasys1;
llamadas_maquina.fps_max:=56.18;
end;

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
		if (f<($8000 div 2)) then begin
      if ((f or ($248 div 2))<>f) then y:=BITSWAP16(x,$d,$0,$a,$9,$6,$e,$b,$f,$5,$c,$7,$2,$3,$8,$1,$4)
        else y:=BITSWAP16(x,$4,$5,$6,$7,$0,$1,$2,$3,$b,$a,$9,$8,$f,$e,$d,$c);
    end else if	(f<($10000 div 2)) then begin
      if ((f or ($248 div 2))<>f) then y:=BITSWAP16(x,$f,$d,$b,$9,$c,$e,$0,$7,$5,$3,$1,$8,$a,$2,$4,$6)
        else y:=BITSWAP16(x,$4,$5,$1,$2,$e,$d,$3,$b,$a,$9,$6,$7,$0,$8,$f,$c);
    end else if	(f<($18000 div 2)) then begin
      if ((f or ($248 div 2))<>f) then y:=BITSWAP16(x,$d,$0,$a,$9,$6,$e,$b,$f,$5,$c,$7,$2,$3,$8,$1,$4)
        else y:=BITSWAP16(x,$4,$5,$6,$7,$0,$1,$2,$3,$b,$a,$9,$8,$f,$e,$d,$c);
    end	else if	(f<($20000 div 2)) then y:=BITSWAP16(x,$4,$5,$6,$7,$0,$1,$2,$3,$b,$a,$9,$8,$f,$e,$d,$c)
      else y:=BITSWAP16(x,$4,$5,$1,$2,$e,$d,$3,$b,$a,$9,$6,$7,$0,$8,$f,$c);
    dest^:=y;
    inc(dest);
  end;  //del for
end;

function iniciar_megasys1:boolean;
const
  pc_x:array[0..7] of dword=(0*4, 1*4, 2*4, 3*4, 4*4, 5*4, 6*4, 7*4);
  pc_y:array[0..7] of dword=(0*4*8, 1*4*8, 2*4*8, 3*4*8, 4*4*8, 5*4*8, 6*4*8, 7*4*8);
  ps_x:array[0..15] of dword=(8*8*4*0+0,8*8*4*0+4,8*8*4*0+8,8*8*4*0+12,8*8*4*0+16,8*8*4*0+20,8*8*4*0+24,8*8*4*0+28,
		8*8*4*2+0,8*8*4*2+4,8*8*4*2+8,8*8*4*2+12,8*8*4*2+16,8*8*4*2+20,8*8*4*2+24,8*8*4*2+28);
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
  convert_gfx(ngfx,0,memoria_temp,@pc_x[0],@pc_y[0],false,false);
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
		// merge the two layers orders */
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
			// reverse the order now */
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
iniciar_audio(true);
//Pantallas:  principal+char y sprites
screen_init(1,512,512);
screen_mod_scroll(1,512,256,511,512,256,511);
screen_init(2,512,512,true);
screen_mod_scroll(2,512,256,511,512,256,511);
screen_init(3,512,512,true);
screen_mod_scroll(3,512,256,511,512,256,511);
screen_init(4,512,512,false,true);
iniciar_video(256,224);
//iniciar_video(512,512);
//Main CPU
getmem(memoria_temp,$100000);
getmem(memoria_w,$60000);
main_m68000:=cpu_m68000.create(6000000,$100);
main_m68000.change_ram16_calls(megasys1_a_getword,megasys1_a_putword);
//Sound CPU
snd_m68000:=cpu_m68000.create(7000000,$100);
snd_m68000.change_ram16_calls(megasys1_snd_a_getword,megasys1_snd_a_putword);
snd_m68000.init_sound(megasys1_sound_update);
//Sound Chips
oki_6295_0:=snd_okim6295.Create(0,4000000,OKIM6295_PIN7_HIGH);
oki_6295_1:=snd_okim6295.Create(1,4000000,OKIM6295_PIN7_HIGH);
YM2151_Init(0,3500000,nil,snd_irq);
case main_vars.tipo_maquina of
  138:begin //P-47
        //cargar roms
        if not(cargar_roms16w(@rom[0],@p47_rom,'p47.zip',0)) then exit;
        //cargar sonido
        if not(cargar_roms16w(@rom_snd[0],@p47_sound,'p47.zip',0)) then exit;
        //OKI Sounds
        if not(cargar_roms(oki_6295_0.get_rom_addr,@p47_oki1,'p47.zip',0)) then exit;
        if not(cargar_roms(oki_6295_1.get_rom_addr,@p47_oki2,'p47.zip',0)) then exit;
        //scroll 0
        if not(cargar_roms(memoria_temp,@p47_scr0,'p47.zip',0)) then exit;
        convert_chars(0,$4000);
        //scroll 1
        if not(cargar_roms(memoria_temp,@p47_scr1,'p47.zip',0)) then exit;
        convert_chars(1,$4000);
        //scroll 2
        if not(cargar_roms(memoria_temp,@p47_scr2,'p47.zip',1)) then exit;
        convert_chars(2,$1000);
        //Sprites
        if not(cargar_roms(memoria_temp,@p47_sprites,'p47.zip',0)) then exit;
        convert_sprites(3,$1000);
        //Prioridades
        if not(cargar_roms(@mem_prom[0],@p47_pri,'p47.zip',1)) then exit;
        convert_pri;
        //DIP
        marcade.dswa:=$ffff;
        marcade.dswa_val:=@p47_dip;
      end;
  139:begin  //Rodland
        //cargar roms
        if not(cargar_roms16w(memoria_w,@rodland_rom,'rodland.zip',0)) then exit;
        decript_rodland(@rom[0],memoria_w);
        ptemp:=memoria_w;
        inc(ptemp,$20000);
        copymemory(@rom[$20000],ptemp,$20000);
        //cargar sonido
        if not(cargar_roms16w(@rom_snd[0],@rodland_sound,'rodland.zip',0)) then exit;
        //OKI Sounds
        if not(cargar_roms(oki_6295_0.get_rom_addr,@rodland_oki1,'rodland.zip')) then exit;
        if not(cargar_roms(oki_6295_1.get_rom_addr,@rodland_oki2,'rodland.zip')) then exit;
        //scroll 0 y ordenar
        if not(cargar_roms(memoria_temp,@rodland_scr0,'rodland.zip')) then exit;
        convert_chars(0,$4000);
        //scroll 1
        if not(cargar_roms(memoria_temp,@rodland_scr1,'rodland.zip')) then exit;
        convert_chars(1,$4000);
        //scroll 2
        if not(cargar_roms(memoria_temp,@rodland_scr2,'rodland.zip')) then exit;
        convert_chars(2,$1000);
        //Sprites
        if not(cargar_roms(memoria_temp,@rodland_sprites,'rodland.zip')) then exit;
        convert_sprites(3,$1000);
        //Prioridades
        if not(cargar_roms(@mem_prom[0],@rodland_pri,'rodland.zip')) then exit;
        convert_pri;
        //DIP
        marcade.dswa:=$bfff;
        marcade.dswa_val:=@rodland_dip;
      end;
  140:begin //Saint Dragon
        //cargar roms
        if not(cargar_roms16w(memoria_w,@stdragon_rom[0],'stdragon.zip',0)) then exit;
        decript_phantasm(@rom[0],memoria_w);
        //rom[$00045e div 2]:=$0098;	// protection
        //cargar sonido
        if not(cargar_roms16w(@rom_snd[0],@stdragon_sound,'stdragon.zip',0)) then exit;
        //OKI Sounds
        if not(cargar_roms(oki_6295_0.get_rom_addr,@stdragon_oki1,'stdragon.zip',0)) then exit;
        if not(cargar_roms(oki_6295_1.get_rom_addr,@stdragon_oki2,'stdragon.zip',0)) then exit;
        //scroll 0
        if not(cargar_roms(memoria_temp,@stdragon_scr0,'stdragon.zip',0)) then exit;
        convert_chars(0,$4000);
        //scroll 1
        if not(cargar_roms(memoria_temp,@stdragon_scr1,'stdragon.zip',0)) then exit;
        convert_chars(1,$4000);
        //scroll 2
        if not(cargar_roms(memoria_temp,@stdragon_scr2,'stdragon.zip')) then exit;
        convert_chars(2,$1000);
        //Sprites
        if not(cargar_roms(memoria_temp,@stdragon_sprites,'stdragon.zip',0)) then exit;
        convert_sprites(3,$1000);
        //Prioridades
        if not(cargar_roms(@mem_prom[0],@stdragon_pri,'stdragon.zip')) then exit;
        convert_pri;
        marcade.dswa:=$ffbf;
        marcade.dswa_val:=@stdragon_dip;
      end;
end;
//final
freemem(memoria_temp);
freemem(memoria_w);
reset_megasys1;
iniciar_megasys1:=true;
end;

procedure cerrar_megasys1;
begin
main_m68000.free;
snd_m68000.free;
ym2151_close(0);
oki_6295_0.Free;
oki_6295_1.Free;
close_audio;
close_video;
end;

procedure reset_megasys1;
var
  f:byte;
begin
 main_m68000.reset;
 snd_m68000.reset;
 ym2151_reset(0);
 oki_6295_0.reset;
 oki_6295_1.reset;
 reset_audio;
 marcade.in0:=$FF;
 marcade.in1:=$FF;
 marcade.in2:=$ff;
 sound_latch:=0;
 sound_latch2:=0;
 sprite_bank:=0;
 active_layer:=$ff;
 sprites_split:=false;
 for f:=0 to 2 do begin
  layer_scr[f].scroll_x:=0;
  layer_scr[f].scroll_y:=0;
  layer_scr[f].es_8x8:=true;
  layer_scr[f].filas:=16;
  layer_scr[f].cols:=2;
  layer_scr[f].info:=$ffff;
  layer_scr[f].mask_x:=0;
  layer_scr[f].mask_y:=0;
  fillchar(layer_scr[f].scr_ram[0],$4000,0);
 end;
 mcu_hs:=false;
end;

procedure poner_sprites(pri:byte);inline;
var
  f,sprite,nchar,atrib,color,x,pos_obj,pos_sprite,y:word;
  flipx,flipy:boolean;
begin
for f:=0 to $ff do begin
  for sprite:=0 to 3 do begin
      pos_obj:=((f*8)+$800*sprite) shr 1;
      pos_sprite:=$4000+((obj_ram[pos_obj] and $7f)*8);
      atrib:=ram[pos_sprite+4];
      if ((atrib shr 3) and 1)<>pri then continue;
      if (((atrib and $c0) shr 6)<>sprite) then	continue;	//flipping
      // apply the position displacements */
			x:=(ram[pos_sprite+5]+obj_ram[pos_obj+$1]) and $1ff;
			y:=(ram[pos_sprite+6]+obj_ram[pos_obj+$2]) and $1ff;
			flipx:=(atrib and $40)<>0;
			flipy:=(atrib and $80)<>0;
			// sprite code is displaced as well */
			nchar:=((ram[pos_sprite+7]+obj_ram[pos_obj+$3]) and $fff)+((sprite_bank and 1) shl 12);
			color:=(atrib and $f) shl 4;
      put_gfx_sprite(nchar and $fff,768+color,flipx,flipy,3);
      actualiza_gfx_sprite(x,y,4,3);
  end;	//del sprite
end; //del for
end;

procedure poner_pant_16(layer,pant_x:byte;trans:boolean;pos_x,pos_y:word);inline;
var
  f,x,y:byte;
  nchar,color,pos,sx,sy:word;
begin
x:=0;
y:=0;
for f:=0 to $ff do begin
  pos:=(y+x*$10)+(pant_x*$100);
  nchar:=layer_scr[layer].scr_ram[pos and $1fff];
  color:=nchar shr 12;
  if (gfx[layer].buffer[pos] or buffer_color[color+(layer*$10)]) then begin
    color:=(color shl 4)+($100*layer);
    nchar:=(nchar and $fff)*4;
    sx:=(x*16)+pos_x;
    sy:=(y*16)+pos_y;
    if trans then put_gfx_trans(sx,sy,nchar,color,layer+1,layer)
      else put_gfx(sx,sy,nchar,color,layer+1,layer);
    sy:=sy+8;
    if trans then put_gfx_trans(sx,sy,nchar+1,color,layer+1,layer)
      else put_gfx(sx,sy,nchar+1,color,layer+1,layer);
    sx:=sx+8;
    sy:=(y*16)+pos_y;
    if trans then put_gfx_trans(sx,sy,nchar+2,color,layer+1,layer)
      else put_gfx(sx,sy,nchar+2,color,layer+1,layer);
    sy:=sy+8;
    if trans then put_gfx_trans(sx,sy,nchar+3,color,layer+1,layer)
      else put_gfx(sx,sy,nchar+3,color,layer+1,layer);
    gfx[layer].buffer[pos]:=false;
  end;
  if (y and $f)=$f then begin
    x:=x+1;
    y:=0;
  end else y:=y+1;
end;
end;

procedure poner_pant_8(layer,pant_x:byte;trans:boolean;pos_x,pos_y:word);inline;
var
  x,y:byte;
  f,nchar,color,pos:word;
begin
x:=0;
y:=0;
for f:=0 to $3ff do begin
  pos:=(y+x*$20)+(pant_x*400);
  nchar:=layer_scr[layer].scr_ram[pos and $1fff];
  color:=nchar shr 12;
  if (gfx[layer].buffer[pos] or buffer_color[color+(layer*$10)]) then begin
    if trans then put_gfx_trans((x*8)+pos_x,(y*8)+pos_y,nchar and $fff,(color shl 4)+($100*layer),layer+1,layer)
      else put_gfx((x*8)+pos_x,(y*8)+pos_y,nchar and $fff,(color shl 4)+($100*layer),layer+1,layer);
    gfx[layer].buffer[pos]:=false;
  end;
  if (y and $1f)=$1f then begin
    x:=x+1;
    y:=0;
  end else y:=y+1;
end;
end;

procedure update_video_megasys1;inline;
var
  g,f,pant_x,h,layer:byte;
  trans:boolean;
begin
trans:=false;
for g:=4 downto 0 do begin
  layer:=(prioridad[(active_layer shr 8) and $f] shr (g*4)) and $f;
  case layer of
    0,1,2:if (active_layer and (1 shl layer))<>0 then begin
            if layer_scr[layer].es_8x8 then begin //layer 8x8
              for h:=0 to 1 do begin
                for f:=0 to 1 do begin
                  case layer_scr[layer].filas of
                    8:pant_x:=pant_1_16[0,((layer_scr[layer].scroll_x shr 8)+f) mod layer_scr[layer].filas];
                    4:pant_x:=pant_2_16[((layer_scr[layer].scroll_y shr 8)+h) mod layer_scr[layer].cols,((layer_scr[layer].scroll_x shr 8)+f) mod layer_scr[layer].filas];
                    2:pant_x:=pant_3_16[((layer_scr[layer].scroll_y shr 8)+h) mod layer_scr[layer].cols,((layer_scr[layer].scroll_x shr 8)+f) mod layer_scr[layer].filas];
                  end;
                  poner_pant_8(layer,pant_x,trans,f*256,h*256);
                end;
              end;
              scroll_x_y(layer+1,4,layer_scr[layer].scroll_x and $ff,layer_scr[layer].scroll_y and $ff);
              //actualiza_trozo(0,0,512,512,3,0,0,512,512,4);
            end else begin //layer 16x16
              for h:=0 to 1 do begin
                for f:=0 to 1 do begin
                  case layer_scr[layer].filas of
                    16:pant_x:=pant_0_16[((layer_scr[layer].scroll_y shr 8)+h) mod layer_scr[layer].cols,((layer_scr[layer].scroll_x shr 8)+f) mod layer_scr[layer].filas];
                    8:pant_x:=pant_1_16[((layer_scr[layer].scroll_y shr 8)+h) mod layer_scr[layer].cols,((layer_scr[layer].scroll_x shr 8)+f) mod layer_scr[layer].filas];
                    4:pant_x:=pant_2_16[((layer_scr[layer].scroll_y shr 8)+h) mod layer_scr[layer].cols,((layer_scr[layer].scroll_x shr 8)+f) mod layer_scr[layer].filas];
                    2:pant_x:=pant_3_16[((layer_scr[layer].scroll_y shr 8)+h) mod layer_scr[layer].cols,((layer_scr[layer].scroll_x shr 8)+f) mod layer_scr[layer].filas];
                  end;
                  poner_pant_16(layer,pant_x,trans,f*256,h*256);
                end;
              end;
              scroll_x_y(layer+1,4,layer_scr[layer].scroll_x and $ff,layer_scr[layer].scroll_y and $ff);
            end;
            trans:=true;
        end; //del layer_active
        3:if (active_layer and 8)<>0 then begin  //Sprites
            poner_sprites(0);
            if not(sprites_split) then poner_sprites(1);
          end;
        4:if (((active_layer and 8)<>0) and sprites_split) then poner_sprites(1);  //Sprites
  end;  //del case
  if not(trans) then begin
    fill_full_screen(4,$400);
    trans:=true;
  end;
end;  //del for
actualiza_trozo_final(0,16,256,224,4);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure eventos_megasys1;
begin
if event.arcade then begin
  //P1
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $Fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $F7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  //P2
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $Fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $F7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  //COIN
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 and $bf) else marcade.in2:=(marcade.in2 or $40);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $7f) else marcade.in2:=(marcade.in2 or $80);
end;
end;

procedure megasys1_principal;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=main_m68000.tframes;
frame_s:=snd_m68000.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to $ff do begin
   //Main CPU
   main_m68000.run(frame_m);
   frame_m:=frame_m+main_m68000.tframes-main_m68000.contador;
   //Sound CPU
   snd_m68000.run(frame_s);
   frame_s:=frame_s+snd_m68000.tframes-snd_m68000.contador;
   case f of
    127:main_m68000.irq[3]:=HOLD_LINE;
    239:begin
          update_video_megasys1;
          main_m68000.irq[2]:=HOLD_LINE;
        end;
    15:main_m68000.irq[1]:=HOLD_LINE;
   end;
 end;
 eventos_megasys1;
 video_sync;
end;
end;

function megasys1_a_getword(direccion:dword):word;
begin
case direccion of
  $0..$5ffff:if (mcu_hs and (((mcu_hs_ram[4] shl 6) and $3ffc0)=(direccion and $3ffc0))) then megasys1_a_getword:=$835d
                else megasys1_a_getword:=rom[direccion shr 1];
  $80000:megasys1_a_getword:=$ff00 or marcade.in2;
  $80002:megasys1_a_getword:=$0000 or marcade.in0;
  $80004:megasys1_a_getword:=$ff00 or marcade.in1;
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

procedure cambiar_color(tmp_color,numero:word);inline;
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
var
  mask_x,mask_y:word;
begin
layer_scr[layer].info:=valor;
layer_scr[layer].es_8x8:=(((valor shr 4) and 1)<>0);
if not(layer_scr[layer].es_8x8) then begin //16x16
  layer_scr[layer].filas:=scan_val_16[valor and $3];
  layer_scr[layer].cols:=scan_val_16[3-(valor and $3)];
end else begin
  layer_scr[layer].filas:=scan_val_8[valor and $3];
  layer_scr[layer].cols:=scan_val_8[3-(valor and $3)] shr 1;
end;
mask_x:=(layer_scr[layer].filas*256)-1;
mask_y:=(layer_scr[layer].cols*256)-1;
screen_mod_scroll(layer+1,layer_scr[layer].filas*256,256,mask_x,layer_scr[layer].cols*256,256,mask_y);
layer_scr[layer].mask_x:=mask_x;
layer_scr[layer].mask_y:=mask_y;
fillchar(gfx[layer].buffer[0],$2000,1);
end;

procedure megasys1_a_putword(direccion:dword;valor:word);
begin
case direccion of
    0..$23fef,$23ffa..$5ffff:exit;
    $23ff0..$23ff9:begin
                      mcu_hs_ram[(direccion and $f) shr 1]:=valor;
                      if (((mcu_hs_ram[0]=0) and (mcu_hs_ram[1]=$0055) and (mcu_hs_ram[2]=$00aa) and (mcu_hs_ram[3]=$00ff)) and (((direccion and $f) shr 1)=4)) then mcu_hs:=true
	                      else mcu_hs:=false;
                   end;
    $84000..$843ff:begin
                      vregs_ram[(direccion and $3ff) shr 1]:=valor;
                      case (direccion and $3ff) of
                        $000:if active_layer<>valor then begin
                               active_layer:=valor;
                               if (active_layer and 1)<>0 then fillchar(gfx[0].buffer[0],$2000,1);
                               if (active_layer and 2)<>0 then fillchar(gfx[1].buffer[0],$2000,1);
                               if (active_layer and 4)<>0 then fillchar(gfx[2].buffer[0],$2000,1);
                             end;
                        $008:begin
                                if (layer_scr[2].scroll_x shr 8)<>((valor and layer_scr[2].mask_x) shr 8) then fillchar(gfx[2].buffer[0],$2000,1);
                                layer_scr[2].scroll_x:=valor and layer_scr[2].mask_x;
                             end;
                        $00a:begin
                                if (layer_scr[2].scroll_y shr 8)<>((valor and layer_scr[2].mask_y) shr 8) then fillchar(gfx[2].buffer[0],$2000,1);
                                layer_scr[2].scroll_y:=valor and layer_scr[2].mask_y;
                             end;
                        $00c:if layer_scr[2].info<>valor then cambiar_layer(2,valor);
                        $100:sprites_split:=(valor and $100)<>0;
                        $200:begin
                                if (layer_scr[0].scroll_x shr 8)<>((valor and layer_scr[0].mask_x) shr 8) then fillchar(gfx[0].buffer[0],$2000,1);
                                layer_scr[0].scroll_x:=valor and layer_scr[0].mask_x;
                             end;
                        $202:begin
                                if (layer_scr[0].scroll_y shr 8)<>((valor and layer_scr[0].mask_y) shr 8) then fillchar(gfx[0].buffer[0],$2000,1);
                                layer_scr[0].scroll_y:=valor and layer_scr[0].mask_y;
                             end;
                        $204:if layer_scr[0].info<>valor then cambiar_layer(0,valor);
                        $208:begin
                                if (layer_scr[1].scroll_x shr 8)<>((valor and layer_scr[1].mask_x) shr 8) then fillchar(gfx[1].buffer[0],$2000,1);
                                layer_scr[1].scroll_x:=valor and layer_scr[1].mask_x;
                             end;
                        $20a:begin
                                if (layer_scr[1].scroll_y shr 8)<>((valor and layer_scr[1].mask_y) shr 8) then fillchar(gfx[1].buffer[0],$2000,1);
                                layer_scr[1].scroll_y:=valor and layer_scr[1].mask_y;
                             end;
                        $20c:if layer_scr[1].info<>valor then cambiar_layer(1,valor);
                        $300:if (valor and $10)<>0 then snd_m68000.pedir_reset:=ASSERT_LINE
                                else snd_m68000.pedir_reset:=CLEAR_LINE;
                        $308:begin
                                sound_latch:=valor;
                                snd_m68000.irq[4]:=HOLD_LINE;
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
  $40000:megasys1_snd_a_getword:=sound_latch;
  $80002:megasys1_snd_a_getword:=YM2151_status_port_read(0);
  $a0000:megasys1_snd_a_getword:=0;//oki_6295_0.read;
  $c0000:megasys1_snd_a_getword:=0;//oki_6295_1.read;
  $e0000..$fffff:megasys1_snd_a_getword:=ram_snd[(direccion and $1ffff) shr 1];
  $ff21de,$ff21b0,$ff22be:megasys1_snd_a_getword:=$ffff;
end;
end;

procedure megasys1_snd_a_putword(direccion:dword;valor:word);
begin
case direccion of
  0..$1ffff:exit;
  $60000:sound_latch2:=valor;
  $80000:YM2151_register_port_write(0,valor);
  $80002:YM2151_data_port_write(0,valor);
  $a0000,$a0002:oki_6295_0.write(valor);
  $c0000,$c0002:oki_6295_1.write(valor);
  $e0000..$fffff:ram_snd[(direccion and $1ffff) shr 1]:=valor;
end;
end;

procedure megasys1_sound_update;
begin
  ym2151_Update(0);
  oki_6295_0.update;
  oki_6295_1.update;
end;

procedure snd_irq(irqstate:byte);
begin
  if irqstate=1 then snd_m68000.irq[4]:=HOLD_LINE;
end;

end.
