unit boogiewings_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m68000,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     oki6295,sound_engine,hu6280,deco_16ic,deco_decr,deco_common,deco_104,
     misc_functions;

function iniciar_boogwing:boolean;

implementation
const
        boogwing_rom:array[0..3] of tipo_roms=(
        (n:'kn_00-2.2b';l:$40000;p:0;crc:$e38892b9),(n:'kn_02-2.2e';l:$40000;p:1;crc:$8426efef),
        (n:'kn_01-2.4b';l:$40000;p:$80000;crc:$3ad4b54c),(n:'kn_03-2.4e';l:$40000;p:$80001;crc:$10b61f4a));
        boogwing_sound:tipo_roms=(n:'km06.18p';l:$10000;p:0;crc:$3e8bc4e1);
        boogwing_char:array[0..1] of tipo_roms=(
        (n:'km05.9e';l:$10000;p:0;crc:$d10aef95),(n:'km04.8e';l:$10000;p:1;crc:$329323a8));
        boogwing_tiles1:array[0..1] of tipo_roms=(
        (n:'mbd-01.9b';l:$100000;p:0;crc:$d7de4f4b),(n:'mbd-00.8b';l:$100000;p:$100000;crc:$adb20ba9));
        boogwing_tiles2:array[0..1] of tipo_roms=(
        (n:'mbd-03.13b';l:$100000;p:0;crc:$cf798f2c),(n:'mbd-04.14b';l:$100000;p:$100000;crc:$d9764d0b));
        boogwing_tiles1_1:tipo_roms=(n:'mbd-02.10e';l:$80000;p:0;crc:$b25aa721);
        boogwing_sprites1:array[0..1] of tipo_roms=(
        (n:'mbd-05.16b';l:$200000;p:$200000;crc:$1768c66a),(n:'mbd-06.17b';l:$200000;p:0;crc:$7750847a));
        boogwing_sprites2:array[0..1] of tipo_roms=(
        (n:'mbd-07.18b';l:$200000;p:$200000;crc:$241faac1),(n:'mbd-08.19b';l:$200000;p:0;crc:$f13b1e56));
        boogwing_oki1:tipo_roms=(n:'mbd-10.17p';l:$80000;p:0;crc:$f159f76a);
        boogwing_oki2:tipo_roms=(n:'mbd-09.16p';l:$80000;p:0;crc:$f44f2f87);
        boogwing_dip_a:array [0..6] of def_dip2=(
        (mask:7;name:'Coin A';number:8;val8:(0,1,7,6,5,4,3,2);name8:('3C 1C','2C 1C','1C 1C','1C 2C','1C 3C','1C 4C','1C 5C','1C 6C')),
        (mask:$38;name:'Coin B';number:8;val8:(0,8,$38,$30,$28,$20,$18,$10);name8:('3C 1C','2C 1C','1C 1C','1C 2C','1C 3C','1C 4C','1C 5C','1C 6C')),
        (mask:$40;name:'Flip Screen';number:2;val2:($40,0);name2:('Off','On')),
        (mask:$80;name:'Continue Coin';number:2;val2:($80,0);name2:('1 Start/1 Continue','2 Start/1 Continue')),
        (mask:$300;name:'Lives';number:4;val4:($100,0,$300,$200);name4:('1','2','3','4')),
        (mask:$c00;name:'Difficulty';number:4;val4:($800,$c00,$400,0);name4:('Easy','Normal','Hard','Very Hard')),
        (mask:$1000;name:'Free Play';number:2;val2:($1000,0);name2:('Off','On')));

var
 rom_opcode,rom_data:array[0..$7ffff] of word;
 ram:array[0..$7fff] of word;
 oki1_mem,oki2_mem:pbyte;
 priority:word;
 //Deco ACE
 palette_ram,palette_ram_buf:array[0..$7ff] of dword;
 ace_ram:array[0..$27] of word;

procedure update_video_boogwing;
begin
//deco_sprites_0.draw_sprites($c0);
//deco_sprites_1.draw_sprites($c0);
if (priority and 7)=5 then begin
  deco16ic_0.update_pf_2(5,false);
  deco_sprites_0.draw_sprites($80);
  deco_sprites_1.draw_sprites($80);
  deco16ic_1.update_pf_1(5,true);
  deco_sprites_0.draw_sprites($40);
  deco_sprites_1.draw_sprites($40);
  deco16ic_1.update_pf_2(5,true);
end else if (priority and 7)=4 then begin
            deco16ic_1.update_pf_1(5,false);
            deco_sprites_0.draw_sprites($80);
            deco_sprites_1.draw_sprites($80);
            deco16ic_1.update_pf_2(5,true);
            deco_sprites_0.draw_sprites($40);
            deco_sprites_1.draw_sprites($40);
            deco16ic_0.update_pf_2(5,true);
         end else if (((priority and 7)=1) or ((priority and 7)=2)) then begin
            deco16ic_1.update_pf_2(5,false);
            deco_sprites_0.draw_sprites($80);
            deco_sprites_1.draw_sprites($80);
            deco16ic_0.update_pf_2(5,true);
            deco_sprites_0.draw_sprites($40);
            deco_sprites_1.draw_sprites($40);
            deco16ic_1.update_pf_1(5,true);
         end else if (priority and 7)=3 then begin
            deco16ic_1.update_pf_2(5,false);
            deco_sprites_0.draw_sprites($80);
            deco_sprites_1.draw_sprites($80);
            deco16ic_0.update_pf_2(5,true);
            deco_sprites_0.draw_sprites($40);
            deco_sprites_1.draw_sprites($40);
            deco16ic_1.update_pf_1(5,true);
         end else begin
            deco16ic_1.update_pf_2(5,false);
            deco_sprites_0.draw_sprites($80);
            deco_sprites_1.draw_sprites($80);
            deco16ic_1.update_pf_1(5,true);
            deco_sprites_0.draw_sprites($40);
            deco_sprites_1.draw_sprites($40);
            deco16ic_0.update_pf_2(5,true);
         end;
deco_sprites_0.draw_sprites(0);
deco_sprites_1.draw_sprites(0);
deco16ic_0.update_pf_1(5,true);
actualiza_trozo_final(0,8,320,240,5);
end;

procedure eventos_boogwing;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fffe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fffd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fffb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fff7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ffef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $ffdf) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.but2[0] then marcade.in0:=(marcade.in0 and $ffbf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $ff7f) else marcade.in0:=(marcade.in0 or $80);
  //P2
  if arcade_input.up[1] then marcade.in0:=(marcade.in0 and $feff) else marcade.in0:=(marcade.in0 or $100);
  if arcade_input.down[1] then marcade.in0:=(marcade.in0 and $fdff) else marcade.in0:=(marcade.in0 or $200);
  if arcade_input.left[1] then marcade.in0:=(marcade.in0 and $fbff) else marcade.in0:=(marcade.in0 or $400);
  if arcade_input.right[1] then marcade.in0:=(marcade.in0 and $f7ff) else marcade.in0:=(marcade.in0 or $800);
  if arcade_input.but0[1] then marcade.in0:=(marcade.in0 and $efff) else marcade.in0:=(marcade.in0 or $1000);
  if arcade_input.but1[1] then marcade.in0:=(marcade.in0 and $dfff) else marcade.in0:=(marcade.in0 or $2000);
  if arcade_input.but2[1] then marcade.in0:=(marcade.in0 and $bfff) else marcade.in0:=(marcade.in0 or $4000);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $7fff) else marcade.in0:=(marcade.in0 or $8000);
  //SYSTEM
  if arcade_input.coin[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.coin[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
end;
end;

procedure boogwing_principal;
var
  f:word;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
 for f:=0 to 273 do begin
   eventos_boogwing;
   case f of
      8:marcade.in1:=marcade.in1 and 7;
      248:begin
            m68000_0.irq[6]:=HOLD_LINE;
            update_video_boogwing;
            marcade.in1:=marcade.in1 or 8;
          end;
   end;
   //Main
   m68000_0.run(frame_main);
   frame_main:=frame_main+m68000_0.tframes-m68000_0.contador;
   //Sound
   h6280_0.run(frame_snd);
   frame_snd:=frame_snd+h6280_0.tframes-h6280_0.contador;
 end;
 video_sync;
end;
end;

function boogwing_getword(direccion:dword):word;
function boogwing_protection_region_0_104_r(real_address:word):word;
var
  deco146_addr,data:word;
  cs:byte;
begin
	//int real_address = 0 + (offset *2);
	deco146_addr:=BITSWAP32(real_address,31,30,29,28,27,26,25,24,23,22,21,20,19,18, 13,12,11,17,16,15,14,    10,9,8, 7,6,5,4, 3,2,1,0) and $7fff;
	cs:=0;
	data:=deco104_0.read_data(deco146_addr,cs);
	boogwing_protection_region_0_104_r:=data;
end;
begin
case direccion of
  0..$fffff:if m68000_0.opcode then boogwing_getword:=rom_opcode[direccion shr 1]
                  else boogwing_getword:=rom_data[direccion shr 1];
  $200000..$20ffff:boogwing_getword:=ram[(direccion and $ffff) shr 1];
  $242000..$2427ff:boogwing_getword:=deco_sprites_0.ram[(direccion and $7ff) shr 1];
  $246000..$2467ff:boogwing_getword:=deco_sprites_1.ram[(direccion and $7ff) shr 1];
  $24e000..$24efff:boogwing_getword:=boogwing_protection_region_0_104_r(direccion and $fff);
  $264000..$265fff:boogwing_getword:=deco16ic_0.pf1.data[(direccion and $1fff) shr 1];
  $266000..$267fff:boogwing_getword:=deco16ic_0.pf2.data[(direccion and $1fff) shr 1];
  $268000..$268fff:boogwing_getword:=deco16ic_0.pf1.rowscroll[(direccion and $fff) shr 1];
  $26a000..$26afff:boogwing_getword:=deco16ic_0.pf2.rowscroll[(direccion and $fff) shr 1];
  $274000..$275fff:boogwing_getword:=deco16ic_1.pf1.data[(direccion and $1fff) shr 1];
  $276000..$277fff:boogwing_getword:=deco16ic_1.pf2.data[(direccion and $1fff) shr 1];
  $278000..$278fff:boogwing_getword:=deco16ic_1.pf1.rowscroll[(direccion and $fff) shr 1];
  $27a000..$27afff:boogwing_getword:=deco16ic_1.pf2.rowscroll[(direccion and $fff) shr 1];
  $284000..$285fff:if (((direccion shr 1) and 1)=0) then boogwing_getword:=(palette_ram[(direccion shr 2) and $7ff] shr 16)
	                  else boogwing_getword:=palette_ram[(direccion shr 2) and $7ff];
  $3c0000..$3c004f:boogwing_getword:=ace_ram[(direccion and $ff) shr 1]; //deco ace
end;
end;

procedure update_palette;
var
  f,mode:word;
  fadepsb,fadepsg,fadepsr,fadeptb,fadeptr,fadeptg:byte;
  color:tcolor;
  r,g,b:integer;
begin
fadeptr:=ace_ram[$20];
fadeptg:=ace_ram[$21];
fadeptb:=ace_ram[$22];
fadepsr:=ace_ram[$23];
fadepsg:=ace_ram[$24];
fadepsb:=ace_ram[$25];
mode:=ace_ram[$26];
for f:=0 to 2047 do begin
		// Lerp palette entry to 'fadept' according to 'fadeps'
		color.b:=(palette_ram_buf[f] shr 16) and $ff;
		color.g:=(palette_ram_buf[f] shr 8) and $ff;
		color.r:=(palette_ram_buf[f] shr 0) and $ff;
    set_pal_color(color,2048+f);
    if mode=$1000 then begin
      b:=color.b+fadepsb;
      if b>$ff then color.b:=$ff
        else color.b:=b;
      g:=color.g+fadepsg;
      if g>$ff then color.g:=$ff
        else color.g:=g;
      r:=color.r+fadepsr;
      if r>$ff then color.r:=$ff
        else color.r:=r;
    end else begin
      b:=color.b+(((fadeptb-color.b)*fadepsb) div 255);
      if b>$ff then b:=$ff
        else if b<0 then b:=0;
      //color.b:=b;
      g:=color.g+(((fadeptg-color.g)*fadepsg) div 255);
      if g>$ff then g:=$ff
        else if g<0 then g:=0;
      //color.g:=g;
      r:=color.r+(((fadeptr-color.r)*fadepsr) div 255);
      if r>$ff then r:=$ff
        else if r<0 then r:=0;
      //color.r:=r;
    end;
    set_pal_color(color,f);
end;
end;

procedure boogwing_putword(direccion:dword;valor:word);
procedure boogwing_protection_region_0_104_w(real_address,data:word);
var
  deco146_addr:word;
  cs:byte;
begin
	//int real_address = 0 + (offset *2);
	deco146_addr:=BITSWAP32(real_address,31,30,29,28,27,26,25,24,23,22,21,20,19,18,13,12,11,17,16,15,14,10,9,8,7,6,5,4,3,2,1,0) and $7fff;
	cs:=0;
	deco104_0.write_data(deco146_addr, data,cs);
end;
var
  tempw:word;
begin
case direccion of
  0..$fffff:;
  $200000..$20ffff:ram[(direccion and $ffff) shr 1]:=valor;
  $220000:priority:=valor;
  $242000..$2427ff:deco_sprites_0.ram[(direccion and $7ff) shr 1]:=valor;
  $246000..$2467ff:deco_sprites_1.ram[(direccion and $7ff) shr 1]:=valor;
  $24e000..$24efff:boogwing_protection_region_0_104_w(direccion and $fff,valor);
  $260000..$26000f:deco16ic_0.control_w((direccion and $f) shr 1,valor);
  $264000..$265fff:begin
                      deco16ic_0.pf1.data[(direccion and $1fff) shr 1]:=valor;
                      deco16ic_0.pf1.buffer[(direccion and $1fff) shr 1]:=true
                   end;
  $266000..$267fff:begin
                      deco16ic_0.pf2.data[(direccion and $1fff) shr 1]:=valor;
                      deco16ic_0.pf2.buffer[(direccion and $1fff) shr 1]:=true
                   end;
  $268000..$268fff:deco16ic_0.pf1.rowscroll[(direccion and $fff) shr 1]:=valor;
  $26a000..$26afff:deco16ic_0.pf2.rowscroll[(direccion and $fff) shr 1]:=valor;
  $270000..$27000f:deco16ic_1.control_w((direccion and $f) shr 1,valor);
  $274000..$275fff:begin
                      deco16ic_1.pf1.data[(direccion and $1fff) shr 1]:=valor;
                      deco16ic_1.pf1.buffer[(direccion and $1fff) shr 1]:=true
                   end;
  $276000..$277fff:begin
                      deco16ic_1.pf2.data[(direccion and $1fff) shr 1]:=valor;
                      deco16ic_1.pf2.buffer[(direccion and $1fff) shr 1]:=true
                   end;
  $278000..$278fff:deco16ic_1.pf1.rowscroll[(direccion and $fff) shr 1]:=valor;
  $27a000..$27afff:deco16ic_1.pf2.rowscroll[(direccion and $fff) shr 1]:=valor;
  $282008:begin
            copymemory(@palette_ram_buf[0],@palette_ram[0],$2000);
            update_palette;
          end;
  $284000..$285fff:if (((direccion shr 1) and 1)=0) then palette_ram[(direccion shr 2) and $7ff]:=(palette_ram[(direccion shr 2) and $7ff] and $ffff) or (valor shl 16)
	                  else palette_ram[(direccion shr 2) and $7ff]:=(palette_ram[(direccion shr 2) and $7ff] and $ffff0000) or valor;
  $3c0000..$3c004f:begin //deco ace
                      tempw:=(direccion and $ff) shr 1;
                      ace_ram[tempw]:=valor;
                      if ((tempw>=$20) and (tempw<=$26)) then
                        update_palette;
                   end;
end;
end;

function boogwing_bank_callback(bank:word):word;
begin
  	boogwing_bank_callback:=((bank shr 4) and 7)*$1000;
end;

function boogwing_bank_callback2(bank:word):word;
var
  offset:word;
begin
  offset:=((bank shr 4) and 7)*$1000;
	if ((bank and $f)=$a) then offset:=offset+$800; // strange - transporter level
	boogwing_bank_callback2:=offset;
end;

procedure sound_bank_rom(valor:byte);
var
  temp:pbyte;
begin
  temp:=oki1_mem;
  inc(temp,(valor and 1)*$40000);
  copymemory(oki_6295_0.get_rom_addr,temp,$40000);
end;

//Main
procedure reset_boogwing;
begin
 m68000_0.reset;
 frame_main:=m68000_0.tframes;
 deco16ic_0.reset;
 deco104_0.reset;
 copymemory(oki_6295_0.get_rom_addr,oki1_mem,$40000);
 deco16_snd_simple_reset;
 deco_sprites_0.reset;
 deco_sprites_1.reset;
 marcade.in0:=$ffff;
 marcade.in1:=7;
 priority:=0;
end;

procedure cerrar_boogwing;
begin
if oki1_mem<>nil then freemem(oki1_mem);
if oki2_mem<>nil then freemem(oki2_mem);
oki1_mem:=nil;
oki2_mem:=nil;
end;

function iniciar_boogwing:boolean;
const
  pt_x:array[0..15] of dword=(256,257,258,259,260,261,262,263,
  0, 1, 2, 3, 4, 5, 6, 7);
  pt_y:array[0..15] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16,
  8*16,9*16,10*16,11*16,12*16,13*16,14*16,15*16);
  ps_x:array[0..15] of dword=(512,513,514,515,516,517,518,519,
   0, 1, 2, 3, 4, 5, 6, 7);
  ps_y:array[0..15] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32,
	  8*32, 9*32,10*32,11*32,12*32,13*32,14*32,15*32 );
var
  memoria_temp,memoria_temp2:pbyte;
  memoria_temp_rom:pword;
begin
iniciar_boogwing:=false;
llamadas_maquina.bucle_general:=boogwing_principal;
llamadas_maquina.close:=cerrar_boogwing;
llamadas_maquina.reset:=reset_boogwing;
llamadas_maquina.fps_max:=57.79965;
llamadas_maquina.scanlines:=274;
iniciar_audio(true);
//Pantallas
deco16ic_0:=chip_16ic.create(1,2,$800,$100,$f,$f,0,1,0,0,nil,boogwing_bank_callback);
deco16ic_1:=chip_16ic.create(3,4,$800,$300,$f,$f,0,2,0,16,boogwing_bank_callback2,boogwing_bank_callback2);
deco_sprites_0:=tdeco16_sprite.create(3,5,304,$500,true);
deco_sprites_1:=tdeco16_sprite.create(4,5,304,$700,true);
screen_init(5,512,512,false,true);
iniciar_video(320,240);
getmem(memoria_temp,$400000);
getmem(memoria_temp2,$100000);
getmem(memoria_temp_rom,$100000);
//Main CPU
m68000_0:=cpu_m68000.create(14000000);
m68000_0.change_ram16_calls(boogwing_getword,boogwing_putword);
if not(roms_load16w(memoria_temp_rom,boogwing_rom)) then exit;
deco102_decrypt_cpu(memoria_temp_rom,@rom_opcode,@rom_data,$42ba,0,$18,$100000);
//Sound CPU
deco16_snd_simple_init(32220000 div 12,32220000,sound_bank_rom);
if not(roms_load(@mem_snd,boogwing_sound)) then exit;
//OKI rom
getmem(oki1_mem,$80000);
if not(roms_load(oki1_mem,boogwing_oki1)) then exit;
getmem(oki2_mem,$80000);
if not(roms_load(oki2_mem,boogwing_oki2)) then exit;
//tiles1
if not(roms_load16b(memoria_temp,boogwing_char)) then exit;
deco56_decrypt_gfx(memoria_temp,$20000);
init_gfx(0,8,8,$1000);
gfx[0].trans[0]:=true;
gfx_set_desc_data(4,0,16*8,$10000*8+8,$10000*8+0,8,0);
convert_gfx(0,0,memoria_temp,@pt_x[8],@pt_y,false,false);
//tiles2
if not(roms_load(memoria_temp,boogwing_tiles1)) then exit;
if not(roms_load16b(memoria_temp2,boogwing_tiles1_1)) then exit;
deco56_decrypt_gfx(memoria_temp,$200000);
deco56_remap_gfx(memoria_temp2,$100000);
copymemory(@memoria_temp[$200000],memoria_temp2,$100000);
init_gfx(1,16,16,$4000);
gfx[1].trans[0]:=true;
gfx_set_desc_data(5,0,32*16,$200000*8,$100000*8+8,$100000*8+0,8,0);
convert_gfx(1,0,memoria_temp,@pt_x,@pt_y,false,false);
//tiles3
if not(roms_load(memoria_temp,boogwing_tiles2)) then exit;
deco56_decrypt_gfx(memoria_temp,$200000);
init_gfx(2,16,16,$4000);
gfx[2].trans[0]:=true;
gfx_set_desc_data(4,0,32*16,$100000*8+8,$100000*8+0,8,0);
convert_gfx(2,0,memoria_temp,@pt_x,@pt_y,false,false);
//Sprites
if not(roms_load(memoria_temp,boogwing_sprites1)) then exit;
init_gfx(3,16,16,$8000);
gfx[3].trans[0]:=true;
gfx_set_desc_data(4,0,32*16,$200000*8+8,$200000*8+0,8,0);
convert_gfx(3,0,memoria_temp,@pt_x,@pt_y,false,false);
if not(roms_load(memoria_temp,boogwing_sprites2)) then exit;
init_gfx(4,16,16,$8000);
gfx[4].trans[0]:=true;
gfx_set_desc_data(4,0,32*16,$200000*8+8,$200000*8+0,8,0);
convert_gfx(4,0,memoria_temp,@pt_x,@pt_y,false,false);
deco104_0:=cpu_deco_104.create(INTERFACE_SCRAMBLE_REVERSE or USE_MAGIC_ADDRESS_XOR);
//Dip
init_dips(1,boogwing_dip_a,$ffff);
//final
freemem(memoria_temp);
freemem(memoria_temp2);
freemem(memoria_temp_rom);
iniciar_boogwing:=true;
end;

end.
