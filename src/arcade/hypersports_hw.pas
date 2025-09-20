unit hypersports_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6809,nz80,main_engine,controls_engine,sn_76496,vlm_5030,gfx_engine,
     dac,rom_engine,pal_engine,konami_decrypt,sound_engine,qsnapshot,file_engine;

function iniciar_hypersports:boolean;

implementation
const
        hypersports_rom:array[0..5] of tipo_roms=(
        (n:'c01';l:$2000;p:$4000;crc:$0c720eeb),(n:'c02';l:$2000;p:$6000;crc:$560258e0),
        (n:'c03';l:$2000;p:$8000;crc:$9b01c7e6),(n:'c04';l:$2000;p:$a000;crc:$10d7e9a2),
        (n:'c05';l:$2000;p:$c000;crc:$b105a8cd),(n:'c06';l:$2000;p:$e000;crc:$1a34a849));
        hypersports_char:array[0..3] of tipo_roms=(
        (n:'c26';l:$2000;p:0;crc:$a6897eac),(n:'c24';l:$2000;p:$2000;crc:$5fb230c0),
        (n:'c22';l:$2000;p:$4000;crc:$ed9271a0),(n:'c20';l:$2000;p:$6000;crc:$183f4324));
        hypersports_sprites:array[0..7] of tipo_roms=(
        (n:'c14';l:$2000;p:0;crc:$c72d63be),(n:'c13';l:$2000;p:$2000;crc:$76565608),
        (n:'c12';l:$2000;p:$4000;crc:$74d2cc69),(n:'c11';l:$2000;p:$6000;crc:$66cbcb4d),
        (n:'c18';l:$2000;p:$8000;crc:$ed25e669),(n:'c17';l:$2000;p:$a000;crc:$b145b39f),
        (n:'c16';l:$2000;p:$c000;crc:$d7ff9f2b),(n:'c15';l:$2000;p:$e000;crc:$f3d454e6));
        hypersports_pal:array[0..2] of tipo_roms=(
        (n:'c03_c27.bin';l:$20;p:$0;crc:$bc8a5956),(n:'j12_c28.bin';l:$100;p:$20;crc:$2c891d59),
        (n:'a09_c29.bin';l:$100;p:$120;crc:$811a3f3f));
        hypersports_vlm:tipo_roms=(n:'c08';l:$2000;p:$0;crc:$e8f8ea78);
        hypersports_snd:array[0..1] of tipo_roms=(
        (n:'c10';l:$2000;p:$0;crc:$3dc1a6ff),(n:'c09';l:$2000;p:$2000;crc:$9b525c3e));
        hypersports_dip_a:array [0..1] of def_dip=(
        (mask:$0f;name:'Coin A';number:16;dip:((dip_val:$2;dip_name:'4C 1C'),(dip_val:$5;dip_name:'3C 1C'),(dip_val:$8;dip_name:'2C 1C'),(dip_val:$4;dip_name:'3C 2C'),(dip_val:$1;dip_name:'4C 3C'),(dip_val:$f;dip_name:'1C 1C'),(dip_val:$3;dip_name:'3C 4C'),(dip_val:$7;dip_name:'2C 3C'),(dip_val:$e;dip_name:'1C 2C'),(dip_val:$6;dip_name:'2C 5C'),(dip_val:$d;dip_name:'1C 3C'),(dip_val:$c;dip_name:'1C 4C'),(dip_val:$b;dip_name:'1C 5C'),(dip_val:$a;dip_name:'1C 6C'),(dip_val:$9;dip_name:'1C 7C'),(dip_val:$0;dip_name:'Free Play'))),());
        hypersports_dip_b:array [0..5] of def_dip=(
        (mask:$1;name:'After Last Event';number:2;dip:((dip_val:$1;dip_name:'Game Over'),(dip_val:$0;dip_name:'Game Continues'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$2;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Demo Sounds';number:2;dip:((dip_val:$4;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'World Records';number:2;dip:((dip_val:$8;dip_name:'Don''t Erase'),(dip_val:$0;dip_name:'Erase on Reset'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$f0;name:'Difficulty';number:16;dip:((dip_val:$f0;dip_name:'Easy 1'),(dip_val:$e0;dip_name:'Easy 2'),(dip_val:$d0;dip_name:'Easy 3'),(dip_val:$c0;dip_name:'Easy 4'),(dip_val:$b0;dip_name:'Normal 1'),(dip_val:$a0;dip_name:'Normal 2'),(dip_val:$90;dip_name:'Normal 3'),(dip_val:$80;dip_name:'Normal 4'),(dip_val:$70;dip_name:'Normal 5'),(dip_val:$60;dip_name:'Normal 6'),(dip_val:$50;dip_name:'Normal 7'),(dip_val:$40;dip_name:'Normal 8'),(dip_val:$30;dip_name:'Difficult 1'),(dip_val:$20;dip_name:'Difficult 2'),(dip_val:$10;dip_name:'Difficult 3'),(dip_val:$0;dip_name:'Difficult 4'))),());

var
 irq_ena:boolean;
 sound_latch,chip_latch:byte;
 mem_opcodes:array[0..$bfff] of byte;
 last_addr:word;

procedure update_video_hypersports;
var
  x,y,atrib:byte;
  f,nchar,color:word;
  scroll_x:array[0..$1f] of word;
begin
for f:=0 to $7ff do begin
   if gfx[0].buffer[f] then begin
      x:=f mod 64;
      y:=f div 64;
      atrib:=memoria[$2800+f];
      nchar:=memoria[$2000+f]+((atrib and $80) shl 1)+((atrib and $40) shl 3);
      color:=(atrib and $f) shl 4;
      put_gfx_flip(x*8,y*8,nchar,color,1,0,(atrib and $10)<>0,(atrib and $20)<>0);
      gfx[0].buffer[f]:=false;
   end;
end;
for f:=0 to $1f do scroll_x[f]:=memoria[$10c0+(f*2)]+((memoria[$10c1+(f*2)] and 1) shl 8);
scroll__x_part2(1,2,8,@scroll_x);
for f:=$1f downto 0 do begin
  atrib:=memoria[$1000+(f*4)];
  nchar:=memoria[$1002+(f*4)]+((atrib and $20) shl 3);
  y:=241-memoria[$1001+(f*4)];
  x:=memoria[$1003+(f*4)];
  color:=(atrib and $f) shl 4;
  put_gfx_sprite(nchar,color,(atrib and $40)=0,(atrib and $80)<>0,1);
  actualiza_gfx_sprite(x,y,2,1);
end;
actualiza_trozo_final(0,16,256,224,2);
end;

procedure eventos_hypersports;
begin
if event.arcade then begin
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.but2[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.but0[1] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.but1[1] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.but2[1] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  //System
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
end;
end;

procedure hypersports_principal;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=m6809_0.tframes;
frame_s:=z80_0.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
      //main
      m6809_0.run(frame_m);
      frame_m:=frame_m+m6809_0.tframes-m6809_0.contador;
      //sound
      z80_0.run(frame_s);
      frame_s:=frame_s+z80_0.tframes-z80_0.contador;
      if f=239 then begin
          if irq_ena then m6809_0.change_irq(HOLD_LINE);
          update_video_hypersports;
      end;
  end;
  //General
  eventos_hypersports;
  video_sync;
end;
end;

function hypersports_getbyte(direccion:word):byte;
begin
case direccion of
  $1000..$10ff,$2000..$3fff:hypersports_getbyte:=memoria[direccion];
  $1600:hypersports_getbyte:=marcade.dswb; //DSW2
  $1680:hypersports_getbyte:=marcade.in2; //SYSTEM
  $1681:hypersports_getbyte:=marcade.in0;
  $1682:hypersports_getbyte:=marcade.in1; //P3 y P4
  $1683:hypersports_getbyte:=marcade.dswa; //DSW1
  $4000..$ffff:if m6809_0.opcode then hypersports_getbyte:=mem_opcodes[direccion-$4000]
                  else hypersports_getbyte:=memoria[direccion];
 end;
end;

procedure hypersports_putbyte(direccion:word;valor:byte);
begin
case direccion of
  $1000..$10ff,$3000..$3fff:memoria[direccion]:=valor;
  $1480:main_screen.flip_main_screen:=(valor and $1)<>0;
  $1481:z80_0.change_irq(HOLD_LINE);
  $1487:irq_ena:=(valor<>0);
  $1500:sound_latch:=valor;
  $2000..$2fff:if memoria[direccion]<>valor then begin
                   gfx[0].buffer[direccion and $7ff]:=true;
                   memoria[direccion]:=valor;
               end;
  $4000..$ffff:; //ROM
end;
end;

function hypersports_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$4fff:hypersports_snd_getbyte:=mem_snd[direccion];
  $6000:hypersports_snd_getbyte:=sound_latch;
  $8000:hypersports_snd_getbyte:=(z80_0.totalt shr 10) and $f;
end;
end;

procedure hypersports_snd_putbyte(direccion:word;valor:byte);
var
  changes,offset:integer;
begin
case direccion of
    0..$3fff:; //ROM
    $4000..$4fff:mem_snd[direccion]:=valor;
    $a000:vlm5030_0.data_w(valor);
    $c000..$dfff:begin
                        offset:=direccion and $1fff;
                        changes:=offset xor last_addr;
                        // A4 VLM5030 ST pin */
                        if (changes and $10)<>0 then vlm5030_0.set_st((offset and $10) shr 4);
                        // A5 VLM5030 RST pin */
                        if (changes and $20)<>0 then vlm5030_0.set_rst((offset and $20) shr 5);
                        last_addr:=offset;
                      end;
    $e000:dac_0.data8_w(valor);
    $e001:chip_latch:=valor;
    $e002:sn_76496_0.Write(chip_latch);
end;
end;

procedure hypersports_sound_update;
begin
  sn_76496_0.Update;
  dac_0.update;
  vlm5030_0.update;
end;

procedure hypersports_qsave(nombre:string);
var
  data:pbyte;
  buffer:array[0..4] of byte;
  size:word;
begin
open_qsnapshot_save('hypersports'+nombre);
getmem(data,250);
//CPU
size:=m6809_0.save_snapshot(data);
savedata_qsnapshot(data,size);
size:=z80_0.save_snapshot(data);
savedata_qsnapshot(data,size);
//SND
size:=sn_76496_0.save_snapshot(data);
savedata_qsnapshot(data,size);
size:=vlm5030_0.save_snapshot(data);
savedata_qsnapshot(data,size);
size:=dac_0.save_snapshot(data);
savedata_qsnapshot(data,size);
//MEM
savedata_com_qsnapshot(@memoria,$4000);
savedata_com_qsnapshot(@mem_snd[$4000],$c000);
//MISC
buffer[0]:=byte(irq_ena);
buffer[1]:=sound_latch;
buffer[2]:=chip_latch;
buffer[3]:=last_addr and $ff;
buffer[4]:=last_addr shr 8;
savedata_qsnapshot(@buffer,5);
freemem(data);
close_qsnapshot;
end;

procedure hypersports_qload(nombre:string);
var
  data:pbyte;
  buffer:array[0..4] of byte;
begin
if not(open_qsnapshot_load('hypersports'+nombre)) then exit;
getmem(data,250);
//CPU
loaddata_qsnapshot(data);
m6809_0.load_snapshot(data);
loaddata_qsnapshot(data);
z80_0.load_snapshot(data);
//SND
loaddata_qsnapshot(data);
sn_76496_0.load_snapshot(data);
loaddata_qsnapshot(data);
vlm5030_0.load_snapshot(data);
loaddata_qsnapshot(data);
dac_0.load_snapshot(data);
//MEM
loaddata_qsnapshot(@memoria);
loaddata_qsnapshot(@mem_snd[$4000]);
//MISC
loaddata_qsnapshot(@buffer);
irq_ena:=buffer[0]<>0;
sound_latch:=buffer[1];
chip_latch:=buffer[2];
last_addr:=buffer[3] or (buffer[4] shl 8);
freemem(data);
close_qsnapshot;
//end
fillchar(gfx[0].buffer,$800,1);
end;

//Main
procedure close_hypersports;
begin
  write_file(Directory.Arcade_nvram+'hypersports.nv',@memoria[$3800],$800);
end;

procedure reset_hypersports;
begin
 m6809_0.reset;
 z80_0.reset;
 vlm5030_0.reset;
 dac_0.reset;
 reset_audio;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 irq_ena:=false;
 sound_latch:=0;
 chip_latch:=0;
 last_addr:=0;
end;

function iniciar_hypersports:boolean;
var
  colores:tpaleta;
  f:word;
  longitud:integer;
  bit0,bit1,bit2:byte;
  memoria_temp:array[0..$ffff] of byte;
  rweights,gweights:array[0..3] of single;
  bweights:array[0..2] of single;
const
    ps_x:array[0..15] of dword=(0, 1, 2, 3, 8*8+0, 8*8+1, 8*8+2, 8*8+3,
			16*8+0, 16*8+1, 16*8+2, 16*8+3, 24*8+0, 24*8+1, 24*8+2, 24*8+3);
    ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8 ,
		32*8, 33*8, 34*8, 35*8, 36*8, 37*8, 38*8, 39*8);
    resistances_rg:array[0..2] of integer=(1000,470,220);
    resistances_b:array[0..1] of integer=(470,220);
begin
llamadas_maquina.bucle_general:=hypersports_principal;
llamadas_maquina.reset:=reset_hypersports;
llamadas_maquina.close:=close_hypersports;
llamadas_maquina.save_qsnap:=hypersports_qsave;
llamadas_maquina.load_qsnap:=hypersports_qload;
iniciar_hypersports:=false;
iniciar_audio(false);
screen_init(1,512,256);
screen_mod_scroll(1,512,256,511,256,256,255);
screen_init(2,256,256,false,true);
iniciar_video(256,224);
//Main CPU
m6809_0:=cpu_m6809.Create(18432000 div 12,$100,TCPU_M6809);
m6809_0.change_ram_calls(hypersports_getbyte,hypersports_putbyte);
//Sound CPU
z80_0:=cpu_z80.create(14318180 div 4,$100);
z80_0.change_ram_calls(hypersports_snd_getbyte,hypersports_snd_putbyte);
z80_0.init_sound(hypersports_sound_update);
//Sound Chip
sn_76496_0:=sn76496_chip.Create(14318180 div 8);
vlm5030_0:=vlm5030_chip.Create(3579545,$2000,4);
if not(roms_load(vlm5030_0.get_rom_addr,hypersports_vlm)) then exit;
dac_0:=dac_chip.Create(0.80);
if not(roms_load(@memoria,hypersports_rom)) then exit;
konami1_decode(@memoria[$4000],@mem_opcodes[0],$c000);
//NV ram
if read_file_size(Directory.Arcade_nvram+'hypersports.nv',longitud) then read_file(Directory.Arcade_nvram+'hypersports.nv',@memoria[$3800],longitud);
if not(roms_load(@mem_snd,hypersports_snd)) then exit;
//convertir chars
if not(roms_load(@memoria_temp,hypersports_char)) then exit;
init_gfx(0,8,8,$400);
gfx_set_desc_data(4,0,16*8,$4000*8+4,$4000*8+0,4,0);
convert_gfx(0,0,@memoria_temp,@ps_x,@ps_y,false,false);
//sprites
if not(roms_load(@memoria_temp,hypersports_sprites)) then exit;
init_gfx(1,16,16,$200);
gfx[1].trans[0]:=true;
gfx_set_desc_data(4,0,64*8,$8000*8+4,$8000*8+0,4,0);
convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,false);
//paleta
if not(roms_load(@memoria_temp,hypersports_pal)) then exit;
compute_resistor_weights(0,	255, -1.0,
			3,@resistances_rg,@rweights,1000,0,
			3,@resistances_rg,@gweights,1000,0,
			2,@resistances_b,@bweights,1000,0);
for f:=0 to $1f do begin
		// red component */
		bit0:=(memoria_temp[f] shr 0) and $01;
		bit1:=(memoria_temp[f] shr 1) and $01;
		bit2:=(memoria_temp[f] shr 2) and $01;
		colores[f].r:=combine_3_weights(@rweights[0], bit0, bit1, bit2);
		// green component */
		bit0:=(memoria_temp[f] shr 3) and $01;
		bit1:=(memoria_temp[f] shr 4) and $01;
		bit2:=(memoria_temp[f] shr 5) and $01;
		colores[f].g:=combine_3_weights(@gweights[0], bit0, bit1, bit2);
		// blue component */
		bit0:=(memoria_temp[f] shr 6) and $01;
		bit1:=(memoria_temp[f] shr 7) and $01;
		colores[f].b:=combine_2_weights(@bweights[0], bit0, bit1);
end;
set_pal(colores,$20);
for f:=0 to $ff do begin
    gfx[0].colores[f]:=(memoria_temp[$120+f] and $f) or $10;
    gfx[1].colores[f]:=memoria_temp[$20+f] and $f;
end;
//DIP
marcade.dswa:=$ff;
marcade.dswb:=$49;
marcade.dswa_val:=@hypersports_dip_a;
marcade.dswb_val:=@hypersports_dip_b;
//final
reset_hypersports;
iniciar_hypersports:=true;
end;

end.
