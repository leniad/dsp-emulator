unit system1_hw_misc;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     main_engine,gfx_engine,nz80,sn_76496,controls_engine,sega_decrypt,
     z80pio,ppi8255,rom_engine,pal_engine,sound_engine;

function iniciar_system1:boolean;
procedure system1_principal;
procedure reset_system1;
//Main CPU
function system1_getbyte(direccion:word):byte;
procedure system1_putbyte(direccion:word;valor:byte);
function system1_inbyte_pio(puerto:word):byte;
procedure system1_outbyte_pio(valor:byte;puerto:word);
//Sound CPU
function system1_snd_getbyte_pio(direccion:word):byte;
//PIO
procedure system1_pio_porta_write(valor:byte);
procedure system1_pio_porta_nmi(state:boolean);
procedure system1_pio_portb_write(valor:byte);

implementation
  uses system1_hw;

const
    //Pitfall 2
    pitfall2_rom:array[0..3] of tipo_roms=(
        (n:'epr6456a.116';l:$4000;p:0;crc:$bcc8406b),(n:'epr6457a.109';l:$4000;p:$4000;crc:$a016fd2a),
        (n:'epr6458a.96';l:$4000;p:$8000;crc:$5c30b3e8),());
    pitfall2_char:array[0..6] of tipo_roms=(
        (n:'epr6474a.62';l:$2000;p:0;crc:$9f1711b9),(n:'epr6473a.61';l:$2000;p:$2000;crc:$8e53b8dd),
        (n:'epr6472a.64';l:$2000;p:$4000;crc:$e0f34a11),(n:'epr6471a.63';l:$2000;p:$6000;crc:$d5bc805c),
        (n:'epr6470a.66';l:$2000;p:$8000;crc:$1439729f),(n:'epr6469a.65';l:$2000;p:$a000;crc:$e4ac6921),());
    pitfall2_sound:tipo_roms=(n:'epr-6462.120';l:$2000;p:0;crc:$86bb9185);
    pitfall2_sprites:array[0..2] of tipo_roms=(
        (n:'epr6454a.117';l:$4000;p:0;crc:$a5d96780),(n:'epr-6455.05';l:$4000;p:$4000;crc:$32ee64a1),());
    pitfall2_video_prom:tipo_roms=(n:'pr-5317.76';l:$100;p:0;crc:$648350b8);
    //Teddy Boy Blues
    teddy_rom:array[0..3] of tipo_roms=(
        (n:'epr-6768.116';l:$4000;p:0;crc:$5939817e),(n:'epr-6769.109';l:$4000;p:$4000;crc:$14a98ddd),
        (n:'epr-6770.96';l:$4000;p:$8000;crc:$67b0c7c2),());
    teddy_char:array[0..6] of tipo_roms=(
        (n:'epr-6747.62';l:$2000;p:0;crc:$a0e5aca7),(n:'epr-6746.61';l:$2000;p:$2000;crc:$cdb77e51),
        (n:'epr-6745.64';l:$2000;p:$4000;crc:$0cab75c3),(n:'epr-6744.63';l:$2000;p:$6000;crc:$0ef8d2cd),
        (n:'epr-6743.66';l:$2000;p:$8000;crc:$c33062b5),(n:'epr-6742.65';l:$2000;p:$a000;crc:$c457e8c5),());
    teddy_sound:tipo_roms=(n:'epr6748x.120';l:$2000;p:0;crc:$c2a1b89d);
    teddy_sprites:array[0..4] of tipo_roms=(
        (n:'epr-6735.117';l:$4000;p:0;crc:$1be35a97),(n:'epr-6737.04';l:$4000;p:$4000;crc:$6b53aa7a),
        (n:'epr-6736.110';l:$4000;p:$8000;crc:$565c25d0),(n:'epr-6738.05';l:$4000;p:$c000;crc:$e116285f),());
    teddy_video_prom:tipo_roms=(n:'pr-5317.76';l:$100;p:0;crc:$648350b8);
    //Wonder Boy
    wboy_rom:array[0..3] of tipo_roms=(
        (n:'epr-7489.116';l:$4000;p:0;crc:$130f4b70),(n:'epr-7490.109';l:$4000;p:$4000;crc:$9e656733),
        (n:'epr-7491.96';l:$4000;p:$8000;crc:$1f7d0efe),());
    wboy_char:array[0..6] of tipo_roms=(
        (n:'epr-7497.62';l:$2000;p:0;crc:$08d609ca),(n:'epr-7496.61';l:$2000;p:$2000;crc:$6f61fdf1),
        (n:'epr-7495.64';l:$2000;p:$4000;crc:$6a0d2c2d),(n:'epr-7494.63';l:$2000;p:$6000;crc:$a8e281c7),
        (n:'epr-7493.66';l:$2000;p:$8000;crc:$89305df4),(n:'epr-7492.65';l:$2000;p:$a000;crc:$60f806b1),());
    wboy_sound:tipo_roms=(n:'epr-7498.120';l:$2000;p:0;crc:$78ae1e7b);
    wboy_sprites:array[0..4] of tipo_roms=(
        (n:'epr-7485.117';l:$4000;p:0;crc:$c2891722),(n:'epr-7487.04';l:$4000;p:$4000;crc:$2d3a421b),
        (n:'epr-7486.110';l:$4000;p:$8000;crc:$8d622c50),(n:'epr-7488.05';l:$4000;p:$c000;crc:$007c2f1b),());
    wboy_video_prom:tipo_roms=(n:'pr-5317.76';l:$100;p:0;crc:$648350b8);
    //Mr Viking
    mrviking_rom:array[0..6] of tipo_roms=(
        (n:'epr-5873.129';l:$2000;p:0;crc:$14d21624),(n:'epr-5874.130';l:$2000;p:$2000;crc:$6df7de87),
        (n:'epr-5875.131';l:$2000;p:$4000;crc:$ac226100),(n:'epr-5876.132';l:$2000;p:$6000;crc:$e77db1dc),
        (n:'epr-5755.133';l:$2000;p:$8000;crc:$edd62ae1),(n:'epr-5756.134';l:$2000;p:$a000;crc:$11974040),());
    mrviking_sprites:array[0..2] of tipo_roms=(
        (n:'epr-5749.86';l:$4000;p:$0;crc:$e24682cd),(n:'epr-5750.93';l:$4000;p:$4000;crc:$6564d1ad),());
    mrviking_sound:tipo_roms=(n:'epr-5763.3';l:$2000;p:0;crc:$d712280d);
    mrviking_char:array[0..6] of tipo_roms=(
        (n:'epr-5762.82';l:$2000;p:0;crc:$4a91d08a),(n:'epr-5761.65';l:$2000;p:$2000;crc:$f7d61b65),
        (n:'epr-5760.81';l:$2000;p:$4000;crc:$95045820),(n:'epr-5759.64';l:$2000;p:$6000;crc:$5f9bae4e),
        (n:'epr-5758.80';l:$2000;p:$8000;crc:$808ee706),(n:'epr-5757.63';l:$2000;p:$a000;crc:$480f7074),());
    mrviking_video_prom:tipo_roms=(n:'pr-5317.106';l:$100;p:0;crc:$648350b8);
    //Sega Ninja
    seganinj_rom:array[0..3] of tipo_roms=(
        (n:'epr-.116';l:$4000;p:0;crc:$a5d0c9d0),(n:'epr-.109';l:$4000;p:$4000;crc:$b9e6775c),
        (n:'epr-6552.96';l:$4000;p:$8000;crc:$f2eeb0d8),());
    seganinj_sprites:array[0..4] of tipo_roms=(
        (n:'epr-6546.117';l:$4000;p:$0;crc:$a4785692),(n:'epr-6548.04';l:$4000;p:$4000;crc:$bdf278c1),
        (n:'epr-6547.110';l:$4000;p:$8000;crc:$34451b08),(n:'epr-6549.05';l:$4000;p:$c000;crc:$d2057668),());
    seganinj_sound:tipo_roms=(n:'epr-6559.120';l:$2000;p:0;crc:$5a1570ee);
    seganinj_char:array[0..6] of tipo_roms=(
        (n:'epr-6558.62';l:$2000;p:0;crc:$2af9eaeb),(n:'epr-6592.61';l:$2000;p:$2000;crc:$7804db86),
        (n:'epr-6556.64';l:$2000;p:$4000;crc:$79fd26f7),(n:'epr-6590.63';l:$2000;p:$6000;crc:$bf858cad),
        (n:'epr-6554.66';l:$2000;p:$8000;crc:$5ac9d205),(n:'epr-6588.65';l:$2000;p:$a000;crc:$dc931dbb),());
    seganinj_video_prom:tipo_roms=(n:'pr-5317.76';l:$100;p:0;crc:$648350b8);
    //Up and Down
    upndown_rom:array[0..6] of tipo_roms=(
        (n:'epr5516a.129';l:$2000;p:0;crc:$038c82da),(n:'epr5517a.130';l:$2000;p:$2000;crc:$6930e1de),
        (n:'epr-5518.131';l:$2000;p:$4000;crc:$2a370c99),(n:'epr-5519.132';l:$2000;p:$6000;crc:$9d664a58),
        (n:'epr-5520.133';l:$2000;p:$8000;crc:$208dfbdf),(n:'epr-5521.134';l:$2000;p:$a000;crc:$e7b8d87a),());
    upndown_sprites:array[0..2] of tipo_roms=(
        (n:'epr-5514.86';l:$4000;p:$0;crc:$fcc0a88b),(n:'epr-5515.93';l:$4000;p:$4000;crc:$60908838),());
    upndown_sound:tipo_roms=(n:'epr-5535.3';l:$2000;p:0;crc:$cf4e4c45);
    upndown_char:array[0..6] of tipo_roms=(
        (n:'epr-5527.82';l:$2000;p:0;crc:$b2d616f1),(n:'epr-5526.65';l:$2000;p:$2000;crc:$8a8b33c2),
        (n:'epr-5525.81';l:$2000;p:$4000;crc:$e749c5ef),(n:'epr-5524.64';l:$2000;p:$6000;crc:$8b886952),
        (n:'epr-5523.80';l:$2000;p:$8000;crc:$dede35d9),(n:'epr-5522.63';l:$2000;p:$a000;crc:$5e6d9dff),());
    upndown_video_prom:tipo_roms=(n:'pr-5317.106';l:$100;p:0;crc:$648350b8);
    //Flicky
    flicky_rom:array[0..2] of tipo_roms=(
        (n:'epr5978a.116';l:$4000;p:0;crc:$296f1492),(n:'epr5979a.109';l:$4000;p:$4000;crc:$64b03ef9),());
    flicky_sprites:array[0..2] of tipo_roms=(
        (n:'epr-5855.117';l:$4000;p:$0;crc:$b5f894a1),(n:'epr-5856.110';l:$4000;p:$4000;crc:$266af78f),());
    flicky_sound:tipo_roms=(n:'epr-5869.120';l:$2000;p:0;crc:$6d220d4e);
    flicky_char:array[0..6] of tipo_roms=(
        (n:'epr-5868.62';l:$2000;p:0;crc:$7402256b),(n:'epr-5867.61';l:$2000;p:$2000;crc:$2f5ce930),
        (n:'epr-5866.64';l:$2000;p:$4000;crc:$967f1d9a),(n:'epr-5865.63';l:$2000;p:$6000;crc:$03d9a34c),
        (n:'epr-5864.66';l:$2000;p:$8000;crc:$e659f358),(n:'epr-5863.65';l:$2000;p:$a000;crc:$a496ca15),());
    flicky_video_prom:tipo_roms=(n:'pr-5317.76';l:$100;p:0;crc:$648350b8);

procedure decodifica_wonder_boy;
const
  //Wonder Boy
    opcode_xor:array[0..63] of byte=(
		$04,$51,$40,$01,$55,$44,$05,$50,$41,$00,$54,$45,
		$04,$51,$40,$01,$55,$44,$05,$50,$41,$00,$54,$45,
		$04,$51,$40,$01,$55,$44,$05,$50,
		$04,$51,$40,$01,$55,$44,$05,$50,$41,$00,$54,$45,
		$04,$51,$40,$01,$55,$44,$05,$50,$41,$00,$54,$45,
		$04,$51,$40,$01,$55,$44,$05,$50);
	  data_xor:array[0..63] of byte=(
		$54,$15,$44,$51,$10,$41,$55,$14,$45,$50,$11,$40,
		$54,$15,$44,$51,$10,$41,$55,$14,$45,$50,$11,$40,
		$54,$15,$44,$51,$10,$41,$55,$14,
		$54,$15,$44,$51,$10,$41,$55,$14,$45,$50,$11,$40,
		$54,$15,$44,$51,$10,$41,$55,$14,$45,$50,$11,$40,
		$54,$15,$44,$51,$10,$41,$55,$14);
	  opcode_swap_select:array[0..63] of byte=(
		0,0,1,1,1,2,2,3,3,4,4,4,5,5,6,6,
		6,7,7,8,8,9,9,9,10,10,11,11,11,12,12,13,
		8,8,9,9,9,10,10,11,11,12,12,12,13,13,14,14,
		14,15,15,16,16,17,17,17,18,18,19,19,19,20,20,21);
	  data_swap_select:array[0..63] of byte=(
		0,0,1,1,2,2,2,3,3,4,4,5,5,5,6,6,
		7,7,7,8,8,9,9,10,10,10,11,11,12,12,12,13,
		8,8,9,9,10,10,10,11,11,12,12,13,13,13,14,14,
		15,15,15,16,16,17,17,18,18,18,19,19,20,20,20,21);
    swaptable:array[0..23,0..3] of byte=(
		  ( 6,4,2,0 ), ( 4,6,2,0 ), ( 2,4,6,0 ), ( 0,4,2,6 ),
		  ( 6,2,4,0 ), ( 6,0,2,4 ), ( 6,4,0,2 ), ( 2,6,4,0 ),
		  ( 4,2,6,0 ), ( 4,6,0,2 ), ( 6,0,4,2 ), ( 0,6,4,2 ),
		  ( 4,0,6,2 ), ( 0,4,6,2 ), ( 6,2,0,4 ), ( 2,6,0,4 ),
		  ( 0,6,2,4 ), ( 2,0,6,4 ), ( 0,2,6,4 ), ( 4,2,0,6 ),
		  ( 2,4,0,6 ), ( 4,0,2,6 ), ( 2,0,4,6 ), ( 0,2,4,6 ));
var
  a:word;
  row:byte;
  src,tbl0,tbl1,tbl2,tbl3:byte;
begin
    for a:=0 to $7fff do begin
		  src:=memoria[a];
		  // pick the translation table from bits 0, 3, 6, 9, 12 and 14 of the address */
		  row:= (a and 1) + (((a shr 3) and 1) shl 1) + (((a shr 6) and 1) shl 2)
				+ (((a shr 9) and 1) shl 3) + (((a shr 12) and 1) shl 4) + (((a shr 14) and 1) shl 5);
		  // decode the opcodes */
      tbl0:=swaptable[opcode_swap_select[row]][0];
      tbl1:=swaptable[opcode_swap_select[row]][1];
      tbl2:=swaptable[opcode_swap_select[row]][2];
      tbl3:=swaptable[opcode_swap_select[row]][3];
		  mem_dec[a]:=((src and $aa) or (((src shr tbl0) and 1) shl 6) or (((src shr tbl1) and 1) shl 4) or (((src shr tbl2) and 1) shl 2) or (((src shr tbl3) and 1) shl 0)) xor opcode_xor[row];
		  // decode the data */
      tbl0:=swaptable[data_swap_select[row]][0];
      tbl1:=swaptable[data_swap_select[row]][1];
      tbl2:=swaptable[data_swap_select[row]][2];
      tbl3:=swaptable[data_swap_select[row]][3];
		  memoria[a]:=((src and $aa) or (((src shr tbl0) and 1) shl 6) or (((src shr tbl1) and 1) shl 4) or (((src shr tbl2) and 1) shl 2) or (((src shr tbl3) and 1) shl 0)) xor data_xor[row];
    end;
end;

function iniciar_system1:boolean;
const
  pc_x:array[0..7] of dword=(0, 1, 2, 3, 4, 5, 6, 7);
  pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
var
  memoria_temp:array[0..$ffff] of byte;
procedure convert_gfx_system1;
begin
  init_gfx(0,8,8,2048);
  gfx_set_desc_data(3,0,8*8,0,$4000*8,$8000*8);
  convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,false);
end;

begin
iniciar_system1:=false;
iniciar_audio(false);
//Pantallas
screen_init(1,256,256,false,true);
case main_vars.tipo_maquina of
  152,154:begin
             main_screen.rol90_screen:=true;
             iniciar_video(240,224);
          end;
  else iniciar_video(256,224);
end;
//Main CPU
main_z80:=cpu_z80.create(19300000,260);
main_z80.change_ram_calls(system1_getbyte,system1_putbyte);
main_z80.change_timmings(@z80_op,@z80_cb,@z80_dd,@z80_ddcb,@z80_ed,@z80_ex);
//Sound CPU
snd_z80:=cpu_z80.create(4000000,260);
snd_z80.init_sound(system1_sound_update);
//Sound Chip
sn_76496_0:=sn76496_chip.Create(2000000);
sn_76496_1:=sn76496_chip.Create(4000000);
case main_vars.tipo_maquina of
  27:begin //Pitfall II
      sprite_num_banks:=1;
      char_screen:=1;
      //Main CPU
      main_z80.change_io_calls(system1_inbyte_pio,system1_outbyte_pio);
      //Sound CPU
      snd_z80.change_ram_calls(system1_snd_getbyte_pio,system1_snd_putbyte);
      //cargar roms
      if not(cargar_roms(@memoria[0],@pitfall2_rom[0],'pitfall2.zip',0)) then exit;
      decrypt_sega(@memoria[0],@mem_dec[0],0); //Sega Decypt
      //cargar sonido
      if not(cargar_roms(@mem_snd[0],@pitfall2_sound,'pitfall2.zip',1)) then exit;
      //convertir chars
      if not(cargar_roms(@memoria_temp[0],@pitfall2_char[0],'pitfall2.zip',0)) then exit;
      convert_gfx_system1;
      //Meter los sprites en memoria
      if not(cargar_roms(@memoria_sprites[0],@pitfall2_sprites[0],'pitfall2.zip',0)) then exit;
      //Cargar PROM
      if not(cargar_roms(@lookup_memory[0],@pitfall2_video_prom,'pitfall2.zip',1)) then exit;
      dip_b:=$dc;
      //Z80 PIO
      z80pio_init(0,nil,nil,system1_pio_porta_write,system1_pio_porta_nmi,nil,system1_pio_portb_write,nil);
     end;
  35:begin  //teddy Boy Blues
      sprite_num_banks:=2;
      char_screen:=1;
      //Main CPU
      main_z80.change_io_calls(system1_inbyte_pio,system1_outbyte_pio);
      //Sound CPU
      snd_z80.change_ram_calls(system1_snd_getbyte_pio,system1_snd_putbyte);
      //cargar roms
      if not(cargar_roms(@memoria[0],@teddy_rom[0],'teddybb.zip',0)) then exit;
      decrypt_sega(@memoria[0],@mem_dec[0],1); //Sega Decypt
      //cargar sonido
      if not(cargar_roms(@mem_snd[0],@teddy_sound,'teddybb.zip',1)) then exit;
      //convertir chars
      if not(cargar_roms(@memoria_temp[0],@teddy_char[0],'teddybb.zip',0)) then exit;
      convert_gfx_system1;
      //Meter los sprites en memoria
      if not(cargar_roms(@memoria_sprites[0],@teddy_sprites[0],'teddybb.zip',0)) then exit;
      //Cargar PROM
      if not(cargar_roms(@lookup_memory[0],@teddy_video_prom,'teddybb.zip',1)) then exit;
      dip_b:=$fe;
      //Z80 PIO
      z80pio_init(0,nil,nil,system1_pio_porta_write,system1_pio_porta_nmi,nil,system1_pio_portb_write,nil);
     end;
  36:begin  //Wonder boy
      sprite_num_banks:=2;
      char_screen:=1;
      //Main CPU
      main_z80.change_io_calls(system1_inbyte_pio,system1_outbyte_pio);
      //Sound CPU
      snd_z80.change_ram_calls(system1_snd_getbyte_pio,system1_snd_putbyte);
      //cargar roms
      if not(cargar_roms(@memoria[0],@wboy_rom[0],'wboy.zip',0)) then exit;
      decodifica_wonder_boy;
      //cargar sonido
      if not(cargar_roms(@mem_snd[0],@wboy_sound,'wboy.zip',1)) then exit;
      //convertir chars
      if not(cargar_roms(@memoria_temp[0],@wboy_char[0],'wboy.zip',0)) then exit;
      convert_gfx_system1;
      //Meter los sprites en memoria
      if not(cargar_roms(@memoria_sprites[0],@wboy_sprites[0],'wboy.zip',0)) then exit;
      //Cargar PROM
      if not(cargar_roms(@lookup_memory[0],@wboy_video_prom,'wboy.zip',1)) then exit;
      dip_b:=$ec;
      //Z80 PIO
      z80pio_init(0,nil,nil,system1_pio_porta_write,system1_pio_porta_nmi,nil,system1_pio_portb_write,nil);
     end;
  152:begin  //Mr Viking
      sprite_num_banks:=1;
      char_screen:=1;
      //Main CPU
      main_z80.change_io_calls(system1_inbyte_ppi,system1_outbyte_ppi);
      //Sound CPU
      snd_z80.change_ram_calls(system1_snd_getbyte_ppi,system1_snd_putbyte);
      //cargar roms
      if not(cargar_roms(@memoria[0],@mrviking_rom[0],'mrviking.zip',0)) then exit;
      decrypt_sega(@memoria[0],@mem_dec[0],3); //Sega Decypt
      //cargar sonido
      if not(cargar_roms(@mem_snd[0],@mrviking_sound,'mrviking.zip',1)) then exit;
      //convertir chars
      if not(cargar_roms(@memoria_temp[0],@mrviking_char[0],'mrviking.zip',0)) then exit;
      convert_gfx_system1;
      //Meter los sprites en memoria
      if not(cargar_roms(@memoria_sprites[0],@mrviking_sprites[0],'mrviking.zip',0)) then exit;
      //Cargar PROM
      if not(cargar_roms(@lookup_memory[0],@mrviking_video_prom,'mrviking.zip',1)) then exit;
      dip_b:=$fc;
      //PPI 8255
      pia8255_0:=pia8255_chip.create;
      pia8255_0.change_ports(nil,nil,nil,system1_port_a_write,system1_port_b_write,system1_port_c_write);
     end;
  153:begin  //Sega Ninja
      sprite_num_banks:=2;
      char_screen:=1;
      //Main CPU
      main_z80.change_io_calls(system1_inbyte_pio,system1_outbyte_pio);
      //Sound CPU
      snd_z80.change_ram_calls(system1_snd_getbyte_pio,system1_snd_putbyte);
      //cargar roms
      if not(cargar_roms(@memoria[0],@seganinj_rom[0],'seganinj.zip',0)) then exit;
      decrypt_sega(@memoria[0],@mem_dec[0],4); //Sega Decypt
      //cargar sonido
      if not(cargar_roms(@mem_snd[0],@seganinj_sound,'seganinj.zip',1)) then exit;
      //convertir chars
      if not(cargar_roms(@memoria_temp[0],@seganinj_char[0],'seganinj.zip',0)) then exit;
      convert_gfx_system1;
      //Meter los sprites en memoria
      if not(cargar_roms(@memoria_sprites[0],@seganinj_sprites[0],'seganinj.zip',0)) then exit;
      //Cargar PROM
      if not(cargar_roms(@lookup_memory[0],@seganinj_video_prom,'seganinj.zip',1)) then exit;
      dip_b:=$dc;
      //Z80 PIO
      z80pio_init(0,nil,nil,system1_pio_porta_write,system1_pio_porta_nmi,nil,system1_pio_portb_write,nil);
     end;
  154:begin  //Up and Down
      sprite_num_banks:=1;
      char_screen:=1;
      //Main CPU
      main_z80.change_io_calls(system1_inbyte_ppi,system1_outbyte_ppi);
      //Sound CPU
      snd_z80.change_ram_calls(system1_snd_getbyte_ppi,system1_snd_putbyte);
      //cargar roms
      if not(cargar_roms(@memoria[0],@upndown_rom[0],'upndown.zip',0)) then exit;
      decrypt_sega(@memoria[0],@mem_dec[0],5); //Sega Decypt
      //cargar sonido
      if not(cargar_roms(@mem_snd[0],@upndown_sound,'upndown.zip',1)) then exit;
      //convertir chars
      if not(cargar_roms(@memoria_temp[0],@upndown_char[0],'upndown.zip',0)) then exit;
      convert_gfx_system1;
      //Meter los sprites en memoria
      if not(cargar_roms(@memoria_sprites[0],@upndown_sprites[0],'upndown.zip',0)) then exit;
      //Cargar PROM
      if not(cargar_roms(@lookup_memory[0],@upndown_video_prom,'upndown.zip',1)) then exit;
      dip_b:=$fe;
      //PPI 8255
      pia8255_0:=pia8255_chip.create;
      pia8255_0.change_ports(nil,nil,nil,system1_port_a_write,system1_port_b_write,system1_port_c_write);
     end;
  155:begin  //Flicky
      sprite_num_banks:=1;
      char_screen:=1;
      //Main CPU
      main_z80.change_io_calls(system1_inbyte_pio,system1_outbyte_pio);
      //Sound CPU
      snd_z80.change_ram_calls(system1_snd_getbyte_pio,system1_snd_putbyte);
      //cargar roms
      if not(cargar_roms(@memoria[0],@flicky_rom[0],'flicky.zip',0)) then exit;
      decrypt_sega(@memoria[0],@mem_dec[0],6); //Sega Decypt
      //cargar sonido
      if not(cargar_roms(@mem_snd[0],@flicky_sound,'flicky.zip',1)) then exit;
      //convertir chars
      if not(cargar_roms(@memoria_temp[0],@flicky_char[0],'flicky.zip',0)) then exit;
      convert_gfx_system1;
      //Meter los sprites en memoria
      if not(cargar_roms(@memoria_sprites[0],@flicky_sprites[0],'flicky.zip',0)) then exit;
      //Cargar PROM
      if not(cargar_roms(@lookup_memory[0],@flicky_video_prom,'flicky.zip',1)) then exit;
      dip_b:=$fe;
      //Z80 PIO
      z80pio_init(0,nil,nil,system1_pio_porta_write,system1_pio_porta_nmi,nil,system1_pio_portb_write,nil);
     end;
end;
dip_a:=$ff;
mask_char:=$7ff;
reset_system1;
iniciar_system1:=true;
end;

procedure reset_system1;
begin
case main_vars.tipo_maquina of
  27,35,36,153,155:z80pio_reset(0);
  152,154:pia8255_0.reset;
end;
sn_76496_0.reset;
sn_76496_1.reset;
main_z80.reset;
snd_z80.reset;
reset_audio;
marcade.in0:=$ff;
marcade.in1:=$ff;
marcade.in2:=$ff;
sound_latch:=0;
mix_collide_summary:=0;
sprite_collide_summary:=0;
scroll_x:=0;
scroll_y:=0;
system1_videomode:=0;
//Clear all
fillchar(bg_ram[0],$4000,0);
fillchar(bg_ram_w[0],$2000,0);
fillchar(sprites_final_screen[0],$20000,0);
fillchar(final_screen[0,0],8*$10000*2,0);
fillchar(bgpixmaps[0],4,0);
sprite_offset:=0;
yscroll:=0;
fillchar(xscroll,$20*2,0);
fillchar(sprite_collide[0],$400,0);
fillchar(mix_collide[0],$40,0);
end;

procedure update_video;inline;
var
  x_temp:word;
begin
update_backgroud(0);
update_backgroud(1);
x_temp:=(bg_ram[$ffc]+(bg_ram[$ffd] shl 8)) div 2+14;
fillword(@xscroll[0],32,x_temp);
yscroll:=bg_ram[$fbd];
update_video_system1;
end;

procedure system1_principal;
var
  f,snd_irq:word;
  frame_m,frame_s:single;
begin
init_controls(false,false,false,true);
frame_m:=main_z80.tframes;
frame_s:=snd_z80.tframes;
snd_irq:=32;
while EmuStatus=EsRuning do begin
  for f:=0 to 259 do begin
    //Main CPU
    main_z80.run(frame_m);
    frame_m:=frame_m+main_z80.tframes-main_z80.contador;
    //Sound CPU
    snd_z80.run(frame_s);
    frame_s:=frame_s+snd_z80.tframes-snd_z80.contador;
    if f=223 then begin
      main_z80.pedir_irq:=HOLD_LINE;
      update_video;
    end;
    if snd_irq=64 then begin
      snd_irq:=0;
      snd_z80.pedir_irq:=HOLD_LINE;
    end;
    snd_irq:=snd_irq+1;
  end;
  eventos_system1;
  video_sync;
end;
end;

function system1_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$7fff:if main_z80.opcode then system1_getbyte:=mem_dec[direccion]
              else system1_getbyte:=memoria[direccion];
  $d800..$ddff:system1_getbyte:=buffer_paleta[direccion and $7ff];
  $e000..$efff:system1_getbyte:=bg_ram[direccion and $fff];
  $f000..$f3ff:system1_getbyte:=mix_collide[direccion and $3f] or $7e or (mix_collide_summary shl 7);
  $f800..$fbff:system1_getbyte:=sprite_collide[direccion and $3ff] or $7e or (sprite_collide_summary shl 7);
  else system1_getbyte:=memoria[direccion];
end;
end;

procedure cambiar_color(valor:byte;pos:word);inline;
var
  color:tcolor;
begin
  color.r:=pal3bit(valor shr 0);
  color.g:=pal3bit(valor shr 3);
	color.b:=pal2bit(valor shr 6);
  set_pal_color(color,pos);
end;

procedure system1_putbyte(direccion:word;valor:byte);
var
  pos_bg:word;
begin
if direccion<$c000 then exit;
memoria[direccion]:=valor;
case direccion of
        $d800..$ddff:if buffer_paleta[direccion and $7ff]<>valor then begin
                        cambiar_color(valor,direccion and $7ff);
                        buffer_paleta[direccion and $7ff]:=valor;
                     end;
        $e000..$efff:begin
                        pos_bg:=direccion and $fff;
                        bg_ram[pos_bg]:=valor;
                        bg_ram_w[pos_bg shr 1]:=true;
                     end;
        $f000..$f3ff:mix_collide[direccion and $3f]:=0;
        $f400..$f7ff:mix_collide_summary:=0;
        $f800..$fbff:sprite_collide[direccion and $3ff]:=0;
        $fc00..$ffff:sprite_collide_summary:=0;
end;
end;

function system1_snd_getbyte_pio(direccion:word):byte;
begin
case direccion of
  $0000..$7fff:system1_snd_getbyte_pio:=mem_snd[direccion];
  $8000..$9fff:system1_snd_getbyte_pio:=mem_snd[(direccion and $7ff)+$8000];
  $e000..$efff:begin
                  system1_snd_getbyte_pio:=z80pio_port_read(0,PORT_A);
                  z80pio_astb_w(0,false);
                  z80pio_astb_w(0,true);
               end;
end;
end;

function system1_inbyte_pio(puerto:word):byte;
begin
case (puerto and $1f) of
  $0..$3:system1_inbyte_pio:=marcade.in1;
  $4..$7:system1_inbyte_pio:=marcade.in2;
  $8..$b:system1_inbyte_pio:=marcade.in0;
  $c,$e:system1_inbyte_pio:=dip_a;
  $d,$f,$10..$13:system1_inbyte_pio:=dip_b;
  $18..$1b:system1_inbyte_pio:=z80pio_cd_ba_r(0,puerto and $1f);
end;
end;

procedure system1_outbyte_pio(valor:byte;puerto:word);
begin
case (puerto and $1f) of
  $18..$1b:z80pio_cd_ba_w(0,puerto and $1f,valor);
end;
end;

//PIO
procedure system1_pio_porta_write(valor:byte);
begin
  sound_latch:=valor;
end;

procedure system1_pio_porta_nmi(state:boolean);
begin
  snd_z80.change_nmi(PULSE_LINE);
end;

procedure system1_pio_portb_write(valor:byte);
begin
  system1_videomode:=valor;
end;

end.
