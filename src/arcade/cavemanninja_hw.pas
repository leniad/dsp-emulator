unit cavemanninja_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m68000,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     oki6295,sound_engine,hu6280,deco16ic,deco_common,deco_104,deco_146,
     misc_functions;

procedure Cargar_cninja;
function iniciar_cninja:boolean;
procedure reset_cninja;
procedure cerrar_cninja;
procedure cninja_principal;
//Caveman Ninja
function cninja_getword(direccion:dword):word;
procedure cninja_putword(direccion:dword;valor:word);
function cninja_video_bank(bank:word):word;
//Robocop 2
function robocop2_getword(direccion:dword):word;
procedure robocop2_putword(direccion:dword;valor:word);
function robocop2_video_bank(bank:word):word;
//sound
procedure sound_bank_rom(valor:byte);

const
        //Caveman Ninja
        cninja_rom:array[0..6] of tipo_roms=(
        (n:'gn-02-3.1k';l:$20000;p:0;crc:$39aea12a),(n:'gn-05-2.3k';l:$20000;p:$1;crc:$0f4360ef),
        (n:'gn-01-2.1j';l:$20000;p:$40000;crc:$f740ef7e),(n:'gn-04-2.3j';l:$20000;p:$40001;crc:$c98fcb62),
        (n:'gn-00.rom';l:$20000;p:$80000;crc:$0b110b16),(n:'gn-03.rom';l:$20000;p:$80001;crc:$1e28e697),());
        cninja_sound:tipo_roms=(n:'gl-07.rom';l:$10000;p:$0;crc:$ca8bef96);
        cninja_chars:array[0..2] of tipo_roms=(
        (n:'gl-09.rom';l:$10000;p:$0;crc:$5a2d4752),(n:'gl-08.rom';l:$10000;p:1;crc:$33a2b400),());
        cninja_tiles1:tipo_roms=(n:'mag-02.rom';l:$80000;p:$0;crc:$de89c69a);
        cninja_tiles2:array[0..2] of tipo_roms=(
        (n:'mag-00.rom';l:$80000;p:$0;crc:$a8f05d33),(n:'mag-01.rom';l:$80000;p:$80000;crc:$5b399eed),());
        cninja_oki2:tipo_roms=(n:'mag-07.rom';l:$80000;p:0;crc:$08eb5264);
        cninja_oki1:tipo_roms=(n:'gl-06.rom';l:$20000;p:0;crc:$d92e519d);
        cninja_sprites:array[0..4] of tipo_roms=(
        (n:'mag-03.rom';l:$80000;p:0;crc:$2220eb9f),(n:'mag-05.rom';l:$80000;p:$1;crc:$56a53254),
        (n:'mag-04.rom';l:$80000;p:$100000;crc:$144b94cc),(n:'mag-06.rom';l:$80000;p:$100001;crc:$82d44749),());
        cninja_dip_a:array [0..7] of def_dip=(
        (mask:$0007;name:'Coin A';number:8;dip:((dip_val:$0;dip_name:'3C 1C'),(dip_val:$1;dip_name:'2C 1C'),(dip_val:$7;dip_name:'1C 1C'),(dip_val:$6;dip_name:'1C 2C'),(dip_val:$5;dip_name:'1C 3C'),(dip_val:$4;dip_name:'1C 4C'),(dip_val:$3;dip_name:'1C 5C'),(dip_val:$2;dip_name:'1C 6C'),(),(),(),(),(),(),(),())),
        (mask:$0038;name:'Coin B';number:8;dip:((dip_val:$0;dip_name:'3C 1C'),(dip_val:$8;dip_name:'2C 1C'),(dip_val:$38;dip_name:'1C 1C'),(dip_val:$30;dip_name:'1C 2C'),(dip_val:$28;dip_name:'1C 3C'),(dip_val:$20;dip_name:'1C 4C'),(dip_val:$18;dip_name:'1C 5C'),(dip_val:$10;dip_name:'1C 6C'),(),(),(),(),(),(),(),())),
        (mask:$0040;name:'Flip Screen';number:2;dip:((dip_val:$40;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0300;name:'Lives';number:4;dip:((dip_val:$100;dip_name:'1'),(dip_val:$0;dip_name:'2'),(dip_val:$300;dip_name:'3'),(dip_val:$200;dip_name:'4'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0c00;name:'Difficulty';number:4;dip:((dip_val:$800;dip_name:'Easy'),(dip_val:$c00;dip_name:'Normal'),(dip_val:$400;dip_name:'Hard'),(dip_val:$000;dip_name:'Very Hard'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$1000;name:'Restore Live Meter';number:2;dip:((dip_val:$1000;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8000;name:'Demo Sounds';number:2;dip:((dip_val:$8000;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        //Robocop 2
        robocop2_rom:array[0..8] of tipo_roms=(
        (n:'gq-03.k1';l:$20000;p:0;crc:$a7e90c28),(n:'gq-07.k3';l:$20000;p:$1;crc:$d2287ec1),
        (n:'gq-02.j1';l:$20000;p:$40000;crc:$6777b8a0),(n:'gq-06.j3';l:$20000;p:$40001;crc:$e11e27b5),
        (n:'go-01-1.h1';l:$20000;p:$80000;crc:$ab5356c0),(n:'go-05-1.h3';l:$20000;p:$80001;crc:$ce21bda5),
        (n:'go-00.f1';l:$20000;p:$c0000;crc:$a93369ea),(n:'go-04.f3';l:$20000;p:$c0001;crc:$ee2f6ad9),());
        robocop2_char:array[0..2] of tipo_roms=(
        (n:'gp10-1.y6';l:$10000;p:1;crc:$d25d719c),(n:'gp11-1.z6';l:$10000;p:0;crc:$030ded47),());
        robocop2_sound:tipo_roms=(n:'gp-09.k13';l:$10000;p:$0;crc:$4a4e0f8d);
        robocop2_oki1:tipo_roms=(n:'gp-08.j13';l:$20000;p:0;crc:$365183b1);
        robocop2_oki2:tipo_roms=(n:'mah-11.f13';l:$80000;p:0;crc:$642bc692);
        robocop2_tiles1:array[0..2] of tipo_roms=(
        (n:'mah-04.z4';l:$80000;p:$0;crc:$9b6ca18c),(n:'mah-03.y4';l:$80000;p:$80000;crc:$37894ddc),());
        robocop2_tiles2:array[0..3] of tipo_roms=(
        (n:'mah-01.z1';l:$80000;p:0;crc:$26e0dfff),(n:'mah-00.y1';l:$80000;p:$80000;crc:$7bd69e41),
        (n:'mah-02.a1';l:$80000;p:$100000;crc:$328a247d),());
        robocop2_sprites:array[0..6] of tipo_roms=(
        (n:'mah-05.y9';l:$80000;p:$000000;crc:$6773e613),(n:'mah-08.y12';l:$80000;p:$000001;crc:$88d310a5),
        (n:'mah-06.z9';l:$80000;p:$100000;crc:$27a8808a),(n:'mah-09.z12';l:$80000;p:$100001;crc:$a58c43a7),
        (n:'mah-07.a9';l:$80000;p:$200000;crc:$526f4190),(n:'mah-10.a12';l:$80000;p:$200001;crc:$14b770da),());
        robocop2_dip_a:array [0..8] of def_dip=(
        (mask:$0007;name:'Coin A';number:8;dip:((dip_val:$0;dip_name:'3C 1C'),(dip_val:$1;dip_name:'2C 1C'),(dip_val:$7;dip_name:'1C 1C'),(dip_val:$6;dip_name:'1C 2C'),(dip_val:$5;dip_name:'1C 3C'),(dip_val:$4;dip_name:'1C 4C'),(dip_val:$3;dip_name:'1C 5C'),(dip_val:$2;dip_name:'1C 6C'),(),(),(),(),(),(),(),())),
        (mask:$0038;name:'Coin B';number:8;dip:((dip_val:$0;dip_name:'3C 1C'),(dip_val:$8;dip_name:'2C 1C'),(dip_val:$38;dip_name:'1C 1C'),(dip_val:$30;dip_name:'1C 2C'),(dip_val:$28;dip_name:'1C 3C'),(dip_val:$20;dip_name:'1C 4C'),(dip_val:$18;dip_name:'1C 5C'),(dip_val:$10;dip_name:'1C 6C'),(),(),(),(),(),(),(),())),
        (mask:$0040;name:'Flip Screen';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$40;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0300;name:'Lives';number:4;dip:((dip_val:$100;dip_name:'1'),(dip_val:$0;dip_name:'2'),(dip_val:$300;dip_name:'3'),(dip_val:$200;dip_name:'4'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0c00;name:'Time';number:4;dip:((dip_val:$800;dip_name:'400 Seconds'),(dip_val:$c00;dip_name:'300 Seconds'),(dip_val:$400;dip_name:'200 Seconds'),(dip_val:$000;dip_name:'100 Seconds'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$3000;name:'Health';number:4;dip:((dip_val:$000;dip_name:'17'),(dip_val:$1000;dip_name:'24'),(dip_val:$3000;dip_name:'33'),(dip_val:$2000;dip_name:'40'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4000;name:'Continues';number:2;dip:((dip_val:$000;dip_name:'Off'),(dip_val:$4000;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8000;name:'Demo Sounds';number:2;dip:((dip_val:$8000;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        robocop2_dip_b:array [0..5] of def_dip=(
        (mask:$3;name:'Bullets';number:4;dip:((dip_val:$0;dip_name:'Least'),(dip_val:$1;dip_name:'Less'),(dip_val:$3;dip_name:'Normal'),(dip_val:$2;dip_name:'More'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Enemy Movement';number:4;dip:((dip_val:$8;dip_name:'Slow'),(dip_val:$c;dip_name:'Normal'),(dip_val:$4;dip_name:'Fast'),(dip_val:$0;dip_name:'Fastest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Enemy Strength';number:4;dip:((dip_val:$20;dip_name:'Less'),(dip_val:$30;dip_name:'Normal'),(dip_val:$10;dip_name:'More'),(dip_val:$0;dip_name:'Most'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Enemy Weapon Speed';number:2;dip:((dip_val:$40;dip_name:'Normal'),(dip_val:$0;dip_name:'Fast'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Game Over Message';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

type
    tipo_update_video=procedure;
var
 rom:array[0..$7ffff] of word;
 ram:array[0..$1fff] of word;
 screen_line,irq_mask,irq_line:byte;
 oki2_mem:pbyte;
 prioridad:word;
 proc_update_video:tipo_update_video;

implementation

procedure Cargar_cninja;
begin
llamadas_maquina.bucle_general:=cninja_principal;
llamadas_maquina.iniciar:=iniciar_cninja;
llamadas_maquina.cerrar:=cerrar_cninja;
llamadas_maquina.reset:=reset_cninja;
llamadas_maquina.fps_max:=58;
end;

procedure update_video_cninja;
begin
//fill_full_screen(5,$300);
//poner_sprites($c0);
update_pf_2(1,5,false);
deco16_sprites_pri($80);
update_pf_1(1,5,true);
deco16_sprites_pri($40);
update_pf_2(0,5,true);
deco16_sprites_pri($00);
update_pf_1(0,5,true);
actualiza_trozo_final(0,8,256,240,5);
end;

procedure update_video_robocop2;
begin
if (prioridad and 4)=0 then update_pf_2(1,5,false)
  else begin
    deco16_sprites_pri($c0);
    fill_full_screen(5,$200);
  end;
deco16_sprites_pri($80);
if (prioridad and $8)<>0 then begin
      update_pf_2(0,5,true);
      deco16_sprites_pri($40);
      update_pf_1(1,5,true);
end else begin
      update_pf_1(1,5,true);
      deco16_sprites_pri($40);
      update_pf_2(0,5,true);
end;
deco16_sprites_pri($00);
update_pf_1(0,5,true);
actualiza_trozo_final(0,8,320,240,5);
end;

//Inicio Normal
function iniciar_cninja:boolean;
const
  pc_x:array[0..7] of dword=(0, 1, 2, 3, 4, 5, 6, 7);
  pc_y:array[0..7] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16);
  pt_x:array[0..15] of dword=(32*8+0, 32*8+1, 32*8+2, 32*8+3, 32*8+4, 32*8+5, 32*8+6, 32*8+7,
		0, 1, 2, 3, 4, 5, 6, 7);
  pt_y:array[0..15] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16,
			8*16, 9*16, 10*16, 11*16, 12*16, 13*16, 14*16, 15*16);
  ps_x:array[0..15] of dword=(64*8+0, 64*8+1, 64*8+2, 64*8+3, 64*8+4, 64*8+5, 64*8+6, 64*8+7,
		0, 1, 2, 3, 4, 5, 6, 7);
  ps_y:array[0..15] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32,
			8*32, 9*32, 10*32, 11*32, 12*32, 13*32, 14*32, 15*32);
var
  memoria_temp,memoria_temp2,ptemp,ptemp2:pbyte;
  tempw:word;
procedure cninja_convert_chars(num:word);
begin
  init_gfx(0,8,8,num);
  gfx[0].trans[0]:=true;
  gfx_set_desc_data(4,0,16*8,num*16*8+8,num*16*8+0,8,0);
  convert_gfx(0,0,memoria_temp,@pc_x[0],@pc_y[0],false,false);
end;
procedure cninja_convert_tiles(ngfx:byte;num:word);
begin
  init_gfx(ngfx,16,16,num);
  gfx[ngfx].trans[0]:=true;
  gfx_set_desc_data(4,0,64*8,num*64*8+8,num*64*8+0,8,0);
  convert_gfx(ngfx,0,memoria_temp2,@pt_x[0],@pt_y[0],false,false);
end;
procedure cninja_convert_sprites(num:dword);
begin
  init_gfx(3,16,16,num);
  gfx[3].trans[0]:=true;
  gfx_set_desc_data(4,0,128*8,16,0,24,8);
  convert_gfx(3,0,memoria_temp,@ps_x[0],@ps_y[0],false,false);
end;
begin
iniciar_cninja:=false;
iniciar_audio(false);
//Pantallas:  principal+char y sprites
case main_vars.tipo_maquina of
  162:begin
        tempw:=256;
        init_dec16ic(0,1,2,$000,$000,$f,$f,0,1,0,16,nil,nil);
        init_dec16ic(1,3,4,$000,$200,$f,$f,0,2,0,48,cninja_video_bank,cninja_video_bank);
        deco16_global_x_size:=240;
      end;
  163:begin
        tempw:=320;
        init_dec16ic(0,1,2,$000,$000,$f,$f,0,1,0,16,nil,robocop2_video_bank);
        init_dec16ic(1,3,4,$000,$200,$f,$f,0,2,0,48,robocop2_video_bank,robocop2_video_bank);
        deco16_global_x_size:=304;
      end;
end;
screen_init(5,512,512,false,true);
iniciar_video(tempw,240);
//Sound CPU
deco16_sprite_color_add:=$300;
deco16_snd_double_init(32220000 div 8,32220000,sound_bank_rom);
getmem(memoria_temp,$300000);
getmem(oki2_mem,$80000);
case main_vars.tipo_maquina of
  162:begin //Caveman Ninja
        deco16_sprite_mask:=$3fff;
        //Main CPU
        main_m68000:=cpu_m68000.create(12000000,$100);
        main_m68000.change_ram16_calls(cninja_getword,cninja_putword);
        proc_update_video:=update_video_cninja;
        //cargar roms
        if not(cargar_roms16w(@rom[0],@cninja_rom[0],'cninja.zip',0)) then exit;
        //cargar sonido
        if not(cargar_roms(@mem_snd[0],@cninja_sound,'cninja.zip')) then exit;
        //OKIs rom
        if not(cargar_roms(oki_6295_0.get_rom_addr,@cninja_oki1,'cninja.zip')) then exit;
        if not(cargar_roms(oki2_mem,@cninja_oki2,'cninja.zip')) then exit;
        //convertir chars
        if not(cargar_roms16b(memoria_temp,@cninja_chars[0],'cninja.zip',0)) then exit;
        cninja_convert_chars($1000);
        //Tiles
        getmem(memoria_temp2,$100000);
        if not(cargar_roms(memoria_temp2,@cninja_tiles1,'cninja.zip')) then exit;
        cninja_convert_tiles(1,$1000);
        if not(cargar_roms(memoria_temp,@cninja_tiles2[0],'cninja.zip',0)) then exit;
        //ordenar
        ptemp:=memoria_temp2;
        ptemp2:=memoria_temp;
        copymemory(ptemp,ptemp2,$40000);
        inc(ptemp2,$40000);
        inc(ptemp,$80000);
        copymemory(ptemp,ptemp2,$40000);
        inc(ptemp2,$40000);
        ptemp:=memoria_temp2;
        inc(ptemp,$40000);
        copymemory(ptemp,ptemp2,$40000);
        inc(ptemp2,$40000);
        inc(ptemp,$80000);
        copymemory(ptemp,ptemp2,$40000);
        cninja_convert_tiles(2,$2000);
        freemem(memoria_temp2);
        //Sprites
        if not(cargar_roms16b(memoria_temp,@cninja_sprites[0],'cninja.zip',0)) then exit;
        cninja_convert_sprites($4000);
        //Proteccion deco104
        main_deco104:=cpu_deco_104.create;
        main_deco104.SET_USE_MAGIC_ADDRESS_XOR;
        //Dip
        marcade.dswa:=$7fff;
        marcade.dswa_val:=@cninja_dip_a;
  end;
  163:begin //Robocop 2
        deco16_sprite_mask:=$7fff;
        //Main CPU
        main_m68000:=cpu_m68000.create(14000000,$100);
        main_m68000.change_ram16_calls(robocop2_getword,robocop2_putword);
        proc_update_video:=update_video_robocop2;
        //cargar roms
        if not(cargar_roms16w(@rom[0],@robocop2_rom[0],'robocop2.zip',0)) then exit;
        //cargar sonido
        if not(cargar_roms(@mem_snd[0],@robocop2_sound,'robocop2.zip')) then exit;
        //OKIs rom
        if not(cargar_roms(oki_6295_0.get_rom_addr,@robocop2_oki1,'robocop2.zip')) then exit;
        if not(cargar_roms(oki2_mem,@robocop2_oki2,'robocop2.zip')) then exit;
        //convertir chars
        if not(cargar_roms16b(memoria_temp,@robocop2_char[0],'robocop2.zip',0)) then exit;
        cninja_convert_chars($1000);
        //Tiles
        if not(cargar_roms(memoria_temp,@robocop2_tiles1[0],'robocop2.zip',0)) then exit;
        getmem(memoria_temp2,$180000);
        ptemp:=memoria_temp2;
        ptemp2:=memoria_temp;
        copymemory(ptemp,ptemp2,$40000);
        inc(ptemp2,$40000);
        inc(ptemp,$80000);
        copymemory(ptemp,ptemp2,$40000);
        inc(ptemp2,$40000);
        ptemp:=memoria_temp2;
        inc(ptemp,$40000);
        copymemory(ptemp,ptemp2,$40000);
        inc(ptemp2,$40000);
        inc(ptemp,$80000);
        copymemory(ptemp,ptemp2,$40000);
        cninja_convert_tiles(1,$2000);
        //Tiles 2
        if not(cargar_roms(memoria_temp,@robocop2_tiles2[0],'robocop2.zip',0)) then exit;
        ptemp:=memoria_temp2;
        ptemp2:=memoria_temp;
        copymemory(ptemp,ptemp2,$40000);
        inc(ptemp,$c0000);
        inc(ptemp2,$40000);
        copymemory(ptemp,ptemp2,$40000);
        inc(ptemp2,$40000);
        ptemp:=memoria_temp2;
        inc(ptemp,$40000);
        copymemory(ptemp,ptemp2,$40000);
        inc(ptemp2,$40000);
        inc(ptemp,$c0000);
        copymemory(ptemp,ptemp2,$40000);
        inc(ptemp2,$40000);
        ptemp:=memoria_temp2;
        inc(ptemp,$80000);
        copymemory(ptemp,ptemp2,$40000);
        inc(ptemp2,$40000);
        inc(ptemp,$c0000);
        copymemory(ptemp,ptemp2,$40000);
        cninja_convert_tiles(2,$3000);
        //Tiles 8bbp
        init_gfx(4,16,16,$1000);
        gfx[4].trans[0]:=true;
        gfx_set_desc_data(8,0,64*8,$100000*8+8,$100000*8,$40000*8+8,$40000*8,$c0000*8+8,$c0000*8,8,0);
        convert_gfx(4,0,memoria_temp2,@pt_x[0],@pt_y[0],false,false);
        freemem(memoria_temp2);
        //Sprites
        if not(cargar_roms16b(memoria_temp,@robocop2_sprites[0],'robocop2.zip',0)) then exit;
        cninja_convert_sprites($6000);
        //Proteccion deco146
        main_deco146:=cpu_deco_146.create;
        main_deco146.SET_USE_MAGIC_ADDRESS_XOR;
        //Dip
        marcade.dswa:=$7fbf;
        marcade.dswa_val:=@robocop2_dip_a;
        marcade.dswb:=$ff;
        marcade.dswb_val:=@robocop2_dip_b;
  end;
end;
//final
freemem(memoria_temp);
reset_cninja;
iniciar_cninja:=true;
end;

procedure cerrar_cninja;
begin
main_m68000.free;
case main_vars.tipo_maquina of
  162:main_deco104.free;
  163:main_deco146.free;
 end;
close_dec16ic(0);
close_dec16ic(1);
deco16_snd_double_close;
close_audio;
close_video;
freemem(oki2_mem);
end;

procedure reset_cninja;
begin
 main_m68000.reset;
 reset_dec16ic(0);
 reset_dec16ic(1);
 case main_vars.tipo_maquina of
  162:main_deco104.reset;
  163:main_deco146.reset;
 end;
 deco16_snd_double_reset;
 copymemory(oki_6295_1.get_rom_addr,oki2_mem,$40000);
 reset_audio;
 marcade.in0:=$FFFF;
 marcade.in1:=$F7;
 irq_mask:=0;
 irq_line:=0;
end;

procedure eventos_cninja;inline;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fffe) else marcade.in0:=(marcade.in0 or $0001);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $ffFd) else marcade.in0:=(marcade.in0 or $0002);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fffb) else marcade.in0:=(marcade.in0 or $0004);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $ffF7) else marcade.in0:=(marcade.in0 or $0008);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ffef) else marcade.in0:=(marcade.in0 or $0010);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $ffdf) else marcade.in0:=(marcade.in0 or $0020);
  if arcade_input.but2[0] then marcade.in0:=(marcade.in0 and $ffbf) else marcade.in0:=(marcade.in0 or $0040);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $ff7f) else marcade.in0:=(marcade.in0 or $0080);
  //P2
  if arcade_input.up[1] then marcade.in0:=(marcade.in0 and $feff) else marcade.in0:=(marcade.in0 or $0100);
  if arcade_input.down[1] then marcade.in0:=(marcade.in0 and $Fdff) else marcade.in0:=(marcade.in0 or $0200);
  if arcade_input.left[1] then marcade.in0:=(marcade.in0 and $fbff) else marcade.in0:=(marcade.in0 or $0400);
  if arcade_input.right[1] then marcade.in0:=(marcade.in0 and $F7ff) else marcade.in0:=(marcade.in0 or $0800);
  if arcade_input.but0[1] then marcade.in0:=(marcade.in0 and $efff) else marcade.in0:=(marcade.in0 or $1000);
  if arcade_input.but1[1] then marcade.in0:=(marcade.in0 and $dfff) else marcade.in0:=(marcade.in0 or $2000);
  if arcade_input.but1[1] then marcade.in0:=(marcade.in0 and $bfff) else marcade.in0:=(marcade.in0 or $4000);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $7fff) else marcade.in0:=(marcade.in0 or $8000);
  //SYSTEM
  if arcade_input.coin[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.coin[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
end;
end;

procedure cninja_principal;
var
  frame_m,frame_s:single;
begin
init_controls(false,false,false,true);
frame_m:=main_m68000.tframes;
frame_s:=main_h6280.tframes;
while EmuStatus=EsRuning do begin
 for screen_line:=0 to $ff do begin
   main_m68000.run(frame_m);
   frame_m:=frame_m+main_m68000.tframes-main_m68000.contador;
   main_h6280.run(trunc(frame_s));
   frame_s:=frame_s+main_h6280.tframes-main_h6280.contador;
   case screen_line of
      0..239:if (((irq_mask and $2)<>0) and (irq_line=(screen_line+1))) then begin
              if (irq_mask and $10)<>0 then main_m68000.irq[3]:=ASSERT_LINE
                else main_m68000.irq[4]:=ASSERT_LINE;
             end;
      247:begin
            main_m68000.irq[5]:=HOLD_LINE;
            proc_update_video;
            marcade.in1:=marcade.in1 and $f7;
          end;
      255:marcade.in1:=marcade.in1 or $8;
   end;
 end;
 eventos_cninja;
 video_sync;
end;
end;

function cninja_protection_deco_104_r(real_address:word):word;inline;
var
  data,deco104_addr:word;
  cs:byte;
begin
	//int real_address = 0 + (offset *2);
	deco104_addr:=BITSWAP32(real_address,31,30,29,28,27,26,25,24,23,22,21,20,19,18, 13,12,11,17,16,15,14,    10,9,8, 7,6,5,4, 3,2,1,0) and $7fff;
	cs:=0;
	data:=main_deco104.read_data(deco104_addr,cs);
	cninja_protection_deco_104_r:=data;
end;

function cninja_getword(direccion:dword):word;
begin
case direccion of
  $0..$bffff:cninja_getword:=rom[direccion shr 1];
  $144000..$144fff:cninja_getword:=deco16ic_chip[0].dec16ic_pf_data[1,(direccion and $fff)+1] or (deco16ic_chip[0].dec16ic_pf_data[1,direccion and $fff] shl 8);
  $146000..$146fff:cninja_getword:=deco16ic_chip[0].dec16ic_pf_data[2,(direccion and $fff)+1] or (deco16ic_chip[0].dec16ic_pf_data[2,direccion and $fff] shl 8);
  $14c000..$14c7ff:cninja_getword:=deco16ic_chip[0].dec16ic_pf_rowscroll[1,(direccion and $7ff) shr 1];
  $14e000..$14e7ff:cninja_getword:=deco16ic_chip[0].dec16ic_pf_rowscroll[2,(direccion and $7ff) shr 1];
  $154000..$154fff:cninja_getword:=deco16ic_chip[1].dec16ic_pf_data[1,(direccion and $fff)+1] or (deco16ic_chip[1].dec16ic_pf_data[1,direccion and $fff] shl 8);
  $156000..$156fff:cninja_getword:=deco16ic_chip[1].dec16ic_pf_data[2,(direccion and $fff)+1] or (deco16ic_chip[1].dec16ic_pf_data[2,direccion and $fff] shl 8);
  $15c000..$15c7ff:cninja_getword:=deco16ic_chip[1].dec16ic_pf_rowscroll[1,(direccion and $7ff) shr 1];
  $15e000..$15e7ff:cninja_getword:=deco16ic_chip[1].dec16ic_pf_rowscroll[2,(direccion and $7ff) shr 1];
  $184000..$187fff:cninja_getword:=ram[(direccion and $3fff) shr 1];
  $190000..$190007:case (direccion and $7) of
                      1:cninja_getword:=screen_line; // Raster IRQ scanline position
	                    2:begin // Raster IRQ ACK
                          main_m68000.irq[3]:=CLEAR_LINE;
                          main_m68000.irq[4]:=CLEAR_LINE;
                          cninja_getword:=0;
                      end;
                        else cninja_getword:=0;
                   end;
  $19c000..$19dfff:cninja_getword:=buffer_paleta[(direccion and $1fff) shr 1];
  $1a4000..$1a47ff:cninja_getword:=buffer_sprites_w[(direccion and $7ff) shr 1];
	$1bc000..$1bffff:cninja_getword:=cninja_protection_deco_104_r(direccion-$1bc000);
end;
end;

procedure cambiar_color(numero:word);inline;
var
  color:tcolor;
begin
  color.b:=buffer_paleta[numero shl 1] and $ff;
  color.g:=buffer_paleta[(numero shl 1)+1] shr 8;
  color.r:=buffer_paleta[(numero shl 1)+1] and $ff;
  set_pal_color(color,@paleta[numero]);
  case numero of
    $000..$0ff:deco16ic_chip[0].dec16ic_buffer_color[1,(numero shr 4) and $f]:=true;
    $100..$1ff:deco16ic_chip[0].dec16ic_buffer_color[2,(numero shr 4) and $f]:=true;
    $200..$2ff:deco16ic_chip[1].dec16ic_buffer_color[1,(numero shr 4) and $f]:=true;
    $500..$5ff:deco16ic_chip[1].dec16ic_buffer_color[2,(numero shr 4) and deco16ic_chip[1].dec16ic_color_mask[2]]:=true;
  end;
end;

procedure cninja_protection_deco_104_w(real_address,data:word);inline;
var
  deco104_addr:word;
  cs:byte;
begin
	//int real_address = 0 + (offset *2);
	deco104_addr:=BITSWAP32(real_address,31,30,29,28,27,26,25,24,23,22,21,20,19,18, 13,12,11,17,16,15,14,    10,9,8, 7,6,5,4, 3,2,1,0) and $7fff;
	cs:=0;
	main_deco104.write_data(deco104_addr, data,cs);
end;

procedure cninja_putword(direccion:dword;valor:word);
begin
if direccion<$c0000 then exit;
case direccion of
  $140000..$14000f:dec16ic_pf_control_w(0,(direccion and $f) shr 1,valor);
  $144000..$144fff:begin
                      deco16ic_chip[0].dec16ic_pf_data[1,(direccion and $fff)+1]:=valor and $ff;
                      deco16ic_chip[0].dec16ic_pf_data[1,direccion and $fff]:=valor shr 8;
                      deco16ic_chip[0].dec16ic_buffer[1,(direccion and $fff) shr 1]:=true
                   end;
  $146000..$146fff:begin
                      deco16ic_chip[0].dec16ic_pf_data[2,(direccion and $fff)+1]:=valor and $ff;
                      deco16ic_chip[0].dec16ic_pf_data[2,direccion and $fff]:=valor shr 8;
                      deco16ic_chip[0].dec16ic_buffer[2,(direccion and $fff) shr 1]:=true
                   end;
  $14c000..$14c7ff:deco16ic_chip[0].dec16ic_pf_rowscroll[1,(direccion and $7ff) shr 1]:=valor;
  $14e000..$14e7ff:deco16ic_chip[0].dec16ic_pf_rowscroll[2,(direccion and $7ff) shr 1]:=valor;
  $150000..$15000f:begin
                      dec16ic_pf_control_w(1,(direccion and $f) shr 1,valor);
                      if ((direccion and $f)=0) then main_screen.flip_main_screen:=(valor and $0080)<>0
                   end;
	$154000..$154fff:begin
                      deco16ic_chip[1].dec16ic_pf_data[1,(direccion and $fff)+1]:=valor and $ff;
                      deco16ic_chip[1].dec16ic_pf_data[1,direccion and $fff]:=valor shr 8;
                      deco16ic_chip[1].dec16ic_buffer[1,(direccion and $fff) shr 1]:=true
                   end;
  $156000..$156fff:begin
                      deco16ic_chip[1].dec16ic_pf_data[2,(direccion and $fff)+1]:=valor and $ff;
                      deco16ic_chip[1].dec16ic_pf_data[2,direccion and $fff]:=valor shr 8;
                      deco16ic_chip[1].dec16ic_buffer[2,(direccion and $fff) shr 1]:=true
                   end;
  $15c000..$15c7ff:deco16ic_chip[1].dec16ic_pf_rowscroll[1,(direccion and $7ff) shr 1]:=valor;
  $15e000..$15e7ff:deco16ic_chip[1].dec16ic_pf_rowscroll[2,(direccion and $7ff) shr 1]:=valor;
  $184000..$187fff:ram[(direccion and $3fff) shr 1]:=valor;
	$190000..$190007:case (direccion and $7) of
	                    0:irq_mask:=valor and $ff; // IRQ enable:
	                    1:irq_line:=valor and $ff; // Raster IRQ scanline position, only valid for values between 1 & 239 (0 and 240-256 do NOT generate IRQ's) */
                   end;
  $19c000..$19dfff:if (buffer_paleta[(direccion and $1fff) shr 1]<>valor) then begin
                      buffer_paleta[(direccion and $1fff) shr 1]:=valor;
                      cambiar_color((direccion and $1fff) shr 2);
                   end;
  $1a4000..$1a47ff:buffer_sprites_w[(direccion and $7ff) shr 1]:=valor;
  $1b4000..$1b4001:copymemory(@deco_sprite_ram[0],@buffer_sprites_w[0],$400*2);
  $1b0002..$1b000f:;
	$1bc000..$1bffff:cninja_protection_deco_104_w(direccion-$1bc000,valor);
end;
end;

//Roboop 2
function robocop2_protection_deco_146_r(real_address:word):word;inline;
var
  deco146_addr,data:word;
  cs:byte;
begin
	//int real_address = 0 + (offset *2);
	deco146_addr:=BITSWAP32(real_address,31,30,29,28,27,26,25,24,23,22,21,20,19,18, 13,12,11,   17,16,15,14,    10,9,8, 7,6,5,4, 3,2,1,0) and $7fff;
	cs:=0;
	data:=main_deco146.read_data(deco146_addr,cs);
  robocop2_protection_deco_146_r:=data;
end;

function robocop2_getword(direccion:dword):word;
begin
case direccion of
  $0..$fffff:robocop2_getword:=rom[direccion shr 1];
  $144000..$144fff:robocop2_getword:=deco16ic_chip[0].dec16ic_pf_data[1,(direccion and $fff)+1] or (deco16ic_chip[0].dec16ic_pf_data[1,direccion and $fff] shl 8);
  $146000..$146fff:robocop2_getword:=deco16ic_chip[0].dec16ic_pf_data[2,(direccion and $fff)+1] or (deco16ic_chip[0].dec16ic_pf_data[2,direccion and $fff] shl 8);
  $14c000..$14c7ff:robocop2_getword:=deco16ic_chip[0].dec16ic_pf_rowscroll[1,(direccion and $7ff) shr 1];
  $14e000..$14e7ff:robocop2_getword:=deco16ic_chip[0].dec16ic_pf_rowscroll[2,(direccion and $7ff) shr 1];
  $154000..$154fff:robocop2_getword:=deco16ic_chip[1].dec16ic_pf_data[1,(direccion and $fff)+1] or (deco16ic_chip[1].dec16ic_pf_data[1,direccion and $fff] shl 8);
  $156000..$156fff:robocop2_getword:=deco16ic_chip[1].dec16ic_pf_data[2,(direccion and $fff)+1] or (deco16ic_chip[1].dec16ic_pf_data[2,direccion and $fff] shl 8);
  $15c000..$15c7ff:robocop2_getword:=deco16ic_chip[1].dec16ic_pf_rowscroll[1,(direccion and $7ff) shr 1];
  $15e000..$15e7ff:robocop2_getword:=deco16ic_chip[1].dec16ic_pf_rowscroll[2,(direccion and $7ff) shr 1];
  $180000..$1807ff:robocop2_getword:=buffer_sprites_w[(direccion and $7ff) shr 1];
  $18c000..$18ffff:robocop2_getword:=robocop2_protection_deco_146_r(direccion-$18c000);
  $1a8000..$1a9fff:robocop2_getword:=buffer_paleta[(direccion and $1fff) shr 1];
  $1b0000..$1b0007:case (direccion and $7) of
                      1:robocop2_getword:=screen_line; // Raster IRQ scanline position
	                    2:begin // Raster IRQ ACK
                          main_m68000.irq[3]:=CLEAR_LINE;
                          main_m68000.irq[4]:=CLEAR_LINE;
                          robocop2_getword:=0;
                      end;
                        else robocop2_getword:=0;
                   end;
  $1b8000..$1bbfff:robocop2_getword:=ram[(direccion and $3fff) shr 1];
	$1f8000..$1f8001:robocop2_getword:=marcade.dswb;
end;
end;

procedure robocop2_protection_deco_146_w(real_address,data:word);inline;
var
  deco146_addr:word;
  cs:byte;
begin
	//int real_address = 0 + (offset *2);
	deco146_addr:=BITSWAP32(real_address, 31,30,29,28,27,26,25,24,23,22,21,20,19,18, 13,12,11,    17,16,15,14,    10,9,8, 7,6,5,4, 3,2,1,0) and $7fff;
	cs:=0;
	main_deco146.write_data(deco146_addr,data,cs);
end;

procedure robocop2_putword(direccion:dword;valor:word);
begin
if direccion<$100000 then exit;
case direccion of
  $140000..$14000f:dec16ic_pf_control_w(0,(direccion and $f) shr 1,valor);
  $144000..$144fff:begin
                      deco16ic_chip[0].dec16ic_pf_data[1,(direccion and $fff)+1]:=valor and $ff;
                      deco16ic_chip[0].dec16ic_pf_data[1,direccion and $fff]:=valor shr 8;
                      deco16ic_chip[0].dec16ic_buffer[1,(direccion and $fff) shr 1]:=true
                   end;
  $146000..$146fff:begin
                      deco16ic_chip[0].dec16ic_pf_data[2,(direccion and $fff)+1]:=valor and $ff;
                      deco16ic_chip[0].dec16ic_pf_data[2,direccion and $fff]:=valor shr 8;
                      deco16ic_chip[0].dec16ic_buffer[2,(direccion and $fff) shr 1]:=true
                   end;
  $14c000..$14c7ff:deco16ic_chip[0].dec16ic_pf_rowscroll[1,(direccion and $7ff) shr 1]:=valor;
  $14e000..$14e7ff:deco16ic_chip[0].dec16ic_pf_rowscroll[2,(direccion and $7ff) shr 1]:=valor;
  $150000..$15000f:begin
                      dec16ic_pf_control_w(1,(direccion and $f) shr 1,valor);
                      if ((direccion and $f)=0) then main_screen.flip_main_screen:=(valor and $0080)<>0
                   end;
	$154000..$154fff:begin
                      deco16ic_chip[1].dec16ic_pf_data[1,(direccion and $fff)+1]:=valor and $ff;
                      deco16ic_chip[1].dec16ic_pf_data[1,direccion and $fff]:=valor shr 8;
                      deco16ic_chip[1].dec16ic_buffer[1,(direccion and $fff) shr 1]:=true
                   end;
  $156000..$156fff:begin
                      deco16ic_chip[1].dec16ic_pf_data[2,(direccion and $fff)+1]:=valor and $ff;
                      deco16ic_chip[1].dec16ic_pf_data[2,direccion and $fff]:=valor shr 8;
                      deco16ic_chip[1].dec16ic_buffer[2,(direccion and $fff) shr 1]:=true
                   end;
  $15c000..$15c7ff:deco16ic_chip[1].dec16ic_pf_rowscroll[1,(direccion and $7ff) shr 1]:=valor;
  $15e000..$15e7ff:deco16ic_chip[1].dec16ic_pf_rowscroll[2,(direccion and $7ff) shr 1]:=valor;
  $180000..$1807ff:buffer_sprites_w[(direccion and $7ff) shr 1]:=valor;
  $18c000..$18ffff:robocop2_protection_deco_146_w(direccion-$18c000,valor);
  $198000..$198001:copymemory(@deco_sprite_ram[0],@buffer_sprites_w[0],$400*2);
  $1a0002..$1a00ff:;
  $1a8000..$1a9fff:if buffer_paleta[(direccion and $1fff) shr 1]<>valor then begin
                      buffer_paleta[(direccion and $1fff) shr 1]:=valor;
                      cambiar_color((direccion and $1fff) shr 2);
                   end;
  $1b0000..$1b0007:case (direccion and $7) of
	                    0:irq_mask:=valor and $ff; // IRQ enable:
	                    1:irq_line:=valor and $ff; // Raster IRQ scanline position, only valid for values between 1 & 239 (0 and 240-256 do NOT generate IRQ's) */
                   end;
  $1b8000..$1bbfff:ram[(direccion and $3fff) shr 1]:=valor;
  $1f0000..$1f0001:if prioridad<>valor then begin
                     prioridad:=valor;
                     if (prioridad and 4)<>0 then begin
                        deco16ic_chip[1].dec16ic_gfx_plane[2]:=4;
                        deco16ic_chip[1].dec16ic_color_mask[2]:=0;
                     end else begin
                        deco16ic_chip[1].dec16ic_gfx_plane[2]:=2;
                        deco16ic_chip[1].dec16ic_color_mask[2]:=$f;
                     end;
                     fillchar(deco16ic_chip[1].dec16ic_buffer[1,0],$800,1);
                     fillchar(deco16ic_chip[1].dec16ic_buffer[2,0],$800,1);
                   end;
end;
end;

procedure sound_bank_rom(valor:byte);
var
  temp:pbyte;
begin
  temp:=oki2_mem;
  inc(temp,(valor and 1)*$40000);
  copymemory(oki_6295_1.get_rom_addr,temp,$40000);
end;

function cninja_video_bank(bank:word):word;
begin
  	if ((bank shr 4) and $f)<>0 then cninja_video_bank:=$0 // Only 2 banks */
	    else cninja_video_bank:=$1000;
end;

function robocop2_video_bank(bank:word):word;
begin
  	robocop2_video_bank:=(bank and $30) shl 8;
end;

end.