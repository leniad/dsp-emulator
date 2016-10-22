unit trackandfield_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6809,nz80,main_engine,controls_engine,sn_76496,vlm_5030,gfx_engine,
     dac,rom_engine,pal_engine,konami_decrypt,sound_engine,qsnapshot,file_engine;

procedure cargar_trackfield;

implementation
const
        trackfield_rom:array[0..5] of tipo_roms=(
        (n:'a01_e01.bin';l:$2000;p:$6000;crc:$2882f6d4),(n:'a02_e02.bin';l:$2000;p:$8000;crc:$1743b5ee),
        (n:'a03_k03.bin';l:$2000;p:$a000;crc:$6c0d1ee9),(n:'a04_e04.bin';l:$2000;p:$c000;crc:$21d6c448),
        (n:'a05_e05.bin';l:$2000;p:$e000;crc:$f08c7b7e),());
        trackfield_char:array[0..3] of tipo_roms=(
        (n:'h16_e12.bin';l:$2000;p:0;crc:$50075768),(n:'h15_e11.bin';l:$2000;p:$2000;crc:$dda9e29f),
        (n:'h14_e10.bin';l:$2000;p:$4000;crc:$c2166a5c),());
        trackfield_sprites:array[0..4] of tipo_roms=(
        (n:'c11_d06.bin';l:$2000;p:0;crc:$82e2185a),(n:'c12_d07.bin';l:$2000;p:$2000;crc:$800ff1f1),
        (n:'c13_d08.bin';l:$2000;p:$4000;crc:$d9faf183),(n:'c14_d09.bin';l:$2000;p:$6000;crc:$5886c802),());
        trackfield_pal:array[0..3] of tipo_roms=(
        (n:'361b16.f1';l:$20;p:$0;crc:$d55f30b5),(n:'361b17.b16';l:$100;p:$20;crc:$d2ba4d32),
        (n:'361b18.e15';l:$100;p:$120;crc:$053e5861),());
        trackfield_vlm:tipo_roms=(n:'c9_d15.bin';l:$2000;p:$0;crc:$f546a56b);
        trackfield_snd:tipo_roms=(n:'c2_d13.bin';l:$2000;p:$0;crc:$95bf79b6);
        trackfield_dip_a:array [0..1] of def_dip=(
        (mask:$0f;name:'Coin A';number:16;dip:((dip_val:$2;dip_name:'4C 1C'),(dip_val:$5;dip_name:'3C 1C'),(dip_val:$8;dip_name:'2C 1C'),(dip_val:$4;dip_name:'3C 2C'),(dip_val:$1;dip_name:'4C 3C'),(dip_val:$f;dip_name:'1C 1C'),(dip_val:$3;dip_name:'3C 4C'),(dip_val:$7;dip_name:'2C 3C'),(dip_val:$e;dip_name:'1C 2C'),(dip_val:$6;dip_name:'2C 5C'),(dip_val:$d;dip_name:'1C 3C'),(dip_val:$c;dip_name:'1C 4C'),(dip_val:$b;dip_name:'1C 5C'),(dip_val:$a;dip_name:'1C 6C'),(dip_val:$9;dip_name:'1C 7C'),(dip_val:$0;dip_name:'Free Play'))),());
        trackfield_dip_b:array [0..7] of def_dip=(
        (mask:$1;name:'Lives';number:2;dip:((dip_val:$1;dip_name:'1'),(dip_val:$0;dip_name:'2'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2;name:'After Last Event';number:2;dip:((dip_val:$2;dip_name:'Game Over'),(dip_val:$0;dip_name:'Game Continues'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$4;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Bonus Life';number:2;dip:((dip_val:$8;dip_name:'None'),(dip_val:$0;dip_name:'100000'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'World Records';number:2;dip:((dip_val:$10;dip_name:'Don''t Erase'),(dip_val:$0;dip_name:'Erase on Reset'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$60;name:'Difficulty';number:4;dip:((dip_val:$60;dip_name:'Easy'),(dip_val:$40;dip_name:'Normal'),(dip_val:$20;dip_name:'Hard'),(dip_val:$0;dip_name:'Difficult'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Demo Sounds';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 irq_ena:boolean;
 frame,sound_latch,chip_latch:byte;
 mem_opcodes:array[0..$9fff] of byte;
 last_addr:word;

procedure update_video_trackfield;inline;
var
  x,y,atrib:byte;
  f,nchar,color,scroll:word;
begin
for f:=0 to $7ff do begin
   if gfx[0].buffer[f] then begin
      x:=f mod 64;
      y:=f div 64;
      atrib:=memoria[$3800+f];
      nchar:=memoria[$3000+f]+((atrib and $c0) shl 2);
      color:=(atrib and $f) shl 4;
      put_gfx_flip(x*8,y*8,nchar,color,1,0,(atrib and $10)<>0,(atrib and $20)<>0);
      gfx[0].buffer[f]:=false;
   end;
end;
for f:=0 to $1f do begin
   scroll:=memoria[$1840+f]+((memoria[$1c40+f] and 1) shl 8);
   scroll__x_part(1,2,scroll,0,f*8,8);
end;
for f:=$1f downto 0 do begin
  atrib:=memoria[$1800+(f*2)];
  nchar:=memoria[$1c01+(f*2)]+((atrib and $20) shl 3);
  y:=241-memoria[$1801+(f*2)];
  x:=memoria[$1c00+(f*2)]-1;
  color:=(atrib and $0f) shl 4;
  put_gfx_sprite(nchar,color,(atrib and $40)=0,(atrib and $80)<>0,1);
  actualiza_gfx_sprite(x,y,2,1);
end;
actualiza_trozo_final(0,16,256,224,2);
end;

procedure eventos_trackfield;
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

procedure trackfield_principal;
var
  frame_m,frame_s:single;
begin
init_controls(false,false,false,true);
frame_m:=m6809_0.tframes;
frame_s:=z80_0.tframes;
while EmuStatus=EsRuning do begin
  for frame:=0 to $ff do begin
      //main
      m6809_0.run(frame_m);
      frame_m:=frame_m+m6809_0.tframes-m6809_0.contador;
      //sound
      z80_0.run(frame_s);
      frame_s:=frame_s+z80_0.tframes-z80_0.contador;
      if frame=239 then begin
          if irq_ena then m6809_0.change_irq(HOLD_LINE);
          update_video_trackfield;
      end;
  end;
  //General
  eventos_trackfield;
  video_sync;
end;
end;

function trackfield_getbyte(direccion:word):byte;
begin
case direccion of
  $1200..$127f:trackfield_getbyte:=marcade.dswb; //DSW2
  $1280..$128f:case (direccion and 3) of
                    0:trackfield_getbyte:=marcade.in2; //SYSTEM
                    1:trackfield_getbyte:=marcade.in0;
                    2:trackfield_getbyte:=marcade.in1;
                    3:trackfield_getbyte:=marcade.dswa; //DSW1
               end;
  $1800..$1fff,$2800..$3fff:trackfield_getbyte:=memoria[direccion];
  $6000..$ffff:if m6809_0.opcode then trackfield_getbyte:=mem_opcodes[direccion-$6000]
                  else trackfield_getbyte:=memoria[direccion];
 end;
end;

procedure trackfield_putbyte(direccion:word;valor:byte);
begin
if direccion>$5FFF then exit;
case direccion of
  $1080..$10ff:case (direccion and 7) of
                  0:main_screen.flip_main_screen:=(valor and $1)<>0;
                  1:z80_0.change_irq(HOLD_LINE);
                  7:irq_ena:=(valor<>0);
               end;
  $1100..$117f:sound_latch:=valor;
  $1800..$1fff,$2800..$2fff:memoria[direccion]:=valor;
  $3000..$3fff:begin
                   gfx[0].buffer[direccion and $7ff]:=true;
                   memoria[direccion]:=valor;
               end;
end;
end;

function trackfield_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$1fff:trackfield_snd_getbyte:=mem_snd[direccion];
  $4000..$5fff:trackfield_snd_getbyte:=mem_snd[(direccion and $3ff)+$4000];
  $6000..$7fff:trackfield_snd_getbyte:=sound_latch;
  $8000..$9fff:trackfield_snd_getbyte:=((z80_0.contador+trunc(z80_0.tframes*frame)) shr 10) and $f;
  $e000..$ffff:if ((direccion and 7)=2) then trackfield_snd_getbyte:=vlm5030_0.get_bsy shl 4;
end;
end;

procedure trackfield_snd_putbyte(direccion:word;valor:byte);
var
  changes,offset:integer;
begin
if direccion<$2000 then exit;
case direccion of
    $4000..$4fff:mem_snd[$4000+(direccion and $3ff)]:=valor;
    $a000..$bfff:chip_latch:=valor;
    $c000..$dfff:sn_76496_0.Write(chip_latch);
    $e000..$ffff:case (direccion and $7) of
                    0:dac_0.data8_w(valor);
                    1,2:;
                    3:begin
                        offset:=direccion and $3ff;
                        changes:=offset xor last_addr;
                        // A4 VLM5030 ST pin */
                        if (changes and $100)<>0 then vlm5030_0.set_st((offset and $100) shr 8);
                        // A5 VLM5030 RST pin */
                        if (changes and $200)<>0 then vlm5030_0.set_rst((offset and $200) shr 9);
                        last_addr:=offset;
                      end;
                    4:vlm5030_0.data_w(valor);
                 end;
end;
end;

procedure trackfield_sound_update;
begin
  sn_76496_0.Update;
  dac_0.update;
  vlm5030_0.update;
end;

procedure trackfield_qsave(nombre:string);
var
  data:pbyte;
  buffer:array[0..4] of byte;
  size:word;
begin
open_qsnapshot_save('trackfield'+nombre);
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
savedata_com_qsnapshot(@memoria[0],$6000);
savedata_com_qsnapshot(@mem_snd[$2000],$e000);
//MISC
buffer[0]:=byte(irq_ena);
buffer[1]:=sound_latch;
buffer[2]:=chip_latch;
buffer[3]:=last_addr and $ff;
buffer[4]:=last_addr shr 8;
savedata_qsnapshot(@buffer[0],5);
freemem(data);
close_qsnapshot;
end;

procedure trackfield_qload(nombre:string);
var
  data:pbyte;
  buffer:array[0..4] of byte;
begin
if not(open_qsnapshot_load('trackfield'+nombre)) then exit;
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
loaddata_qsnapshot(@memoria[0]);
loaddata_qsnapshot(@mem_snd[$2000]);
//MISC
loaddata_qsnapshot(@buffer[0]);
irq_ena:=buffer[0]<>0;
sound_latch:=buffer[1];
chip_latch:=buffer[2];
last_addr:=buffer[3] or (buffer[4] shl 8);
freemem(data);
close_qsnapshot;
//end
fillchar(gfx[0].buffer[0],$800,1);
end;

//Main
procedure close_trackfield;
begin
  write_file(Directory.Arcade_nvram+'trackfield.nv',@memoria[$2800],$800);
end;

procedure reset_trackfield;
begin
 m6809_0.reset;
 z80_0.reset;
 vlm5030_0.reset;
 dac_0.reset;
 reset_audio;
 marcade.in0:=$FF;
 marcade.in1:=$FF;
 marcade.in2:=$FF;
 irq_ena:=false;
 sound_latch:=0;
 chip_latch:=0;
 last_addr:=0;
end;

function iniciar_trackfield:boolean;
var
  colores:tpaleta;
  f:word;
  longitud:integer;
  bit0,bit1,bit2:byte;
  memoria_temp:array[0..$bfff] of byte;
  rweights,gweights:array[0..3] of single;
  bweights:array[0..2] of single;
const
    pc_x:array[0..7] of dword=(0*4, 1*4, 2*4, 3*4, 4*4, 5*4, 6*4, 7*4);
    pc_y:array[0..7] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32);
    ps_x:array[0..15] of dword=(0, 1, 2, 3, 8*8+0, 8*8+1, 8*8+2, 8*8+3,
			16*8+0, 16*8+1, 16*8+2, 16*8+3, 24*8+0, 24*8+1, 24*8+2, 24*8+3);
    ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			32*8, 33*8, 34*8, 35*8, 36*8, 37*8, 38*8, 39*8);
    resistances_rg:array[0..2] of integer=(1000,470,220);
    resistances_b:array[0..1] of integer=(470,220);
begin
iniciar_trackfield:=false;
iniciar_audio(false);
screen_init(1,512,256);
screen_mod_scroll(1,512,256,511,0,0,0);
screen_init(2,256,256,false,true);
iniciar_video(256,224);
//Main CPU
m6809_0:=cpu_m6809.Create(18432000 div 12,$100);
m6809_0.change_ram_calls(trackfield_getbyte,trackfield_putbyte);
//Sound CPU
z80_0:=cpu_z80.create(14318180 div 4,$100);
z80_0.change_ram_calls(trackfield_snd_getbyte,trackfield_snd_putbyte);
z80_0.init_sound(trackfield_sound_update);
//Sound Chip
sn_76496_0:=sn76496_chip.Create(14318180 div 8);
vlm5030_0:=vlm5030_chip.Create(3579545,$2000,4);
if not(cargar_roms(vlm5030_0.get_rom_addr,@trackfield_vlm,'trackfld.zip',1)) then exit;
dac_0:=dac_chip.Create(0.80);
if not(cargar_roms(@memoria[0],@trackfield_rom[0],'trackfld.zip',0)) then exit;
konami1_decode(@memoria[$6000],@mem_opcodes[0],$a000);
//NV ram
if read_file_size(Directory.Arcade_nvram+'trackfield.nv',longitud) then read_file(Directory.Arcade_nvram+'trackfield.nv',@memoria[$2800],longitud);
if not(cargar_roms(@mem_snd[0],@trackfield_snd,'trackfld.zip',1)) then exit;
//convertir chars
if not(cargar_roms(@memoria_temp[0],@trackfield_char,'trackfld.zip',0)) then exit;
init_gfx(0,8,8,$300);
gfx_set_desc_data(4,0,32*8,0,1,2,3);
convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,false);
//sprites
if not(cargar_roms(@memoria_temp[0],@trackfield_sprites[0],'trackfld.zip',0)) then exit;
init_gfx(1,16,16,$100);
gfx[1].trans[0]:=true;
gfx_set_desc_data(4,0,64*8,($100*64*8)+4,$100*64*8,4,0);
convert_gfx(1,0,@memoria_temp[0],@ps_x[0],@ps_y[0],false,false);
//paleta
if not(cargar_roms(@memoria_temp[0],@trackfield_pal[0],'trackfld.zip',0)) then exit;
compute_resistor_weights(0,	255, -1.0,
			3,@resistances_rg[0],@rweights[0],1000,0,
			3,@resistances_rg[0],@gweights[0],1000,0,
			2,@resistances_b[0],@bweights[0],1000,0);
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
//DIP
marcade.dswa:=$ff;
marcade.dswb:=$59;
marcade.dswa_val:=@trackfield_dip_a;
marcade.dswb_val:=@trackfield_dip_b;
//final
reset_trackfield;
iniciar_trackfield:=true;
end;

procedure Cargar_trackfield;
begin
llamadas_maquina.iniciar:=iniciar_trackfield;
llamadas_maquina.bucle_general:=trackfield_principal;
llamadas_maquina.reset:=reset_trackfield;
llamadas_maquina.close:=close_trackfield;
llamadas_maquina.save_qsnap:=trackfield_qsave;
llamadas_maquina.load_qsnap:=trackfield_qload;
end;

end.
