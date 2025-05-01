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
        (n:'c03_c27.bin';l:$20;p:0;crc:$bc8a5956),(n:'j12_c28.bin';l:$100;p:$20;crc:$2c891d59),
        (n:'a09_c29.bin';l:$100;p:$120;crc:$811a3f3f));
        hypersports_vlm:tipo_roms=(n:'c08';l:$2000;p:0;crc:$e8f8ea78);
        hypersports_snd:array[0..1] of tipo_roms=(
        (n:'c10';l:$2000;p:0;crc:$3dc1a6ff),(n:'c09';l:$2000;p:$2000;crc:$9b525c3e));
        hypersports_dip_a:array [0..1] of def_dip2=(
        (mask:$f;name:'Coin A';number:16;val16:(2,5,8,4,1,$f,3,7,$e,6,$d,$c,$b,$a,9,0);name16:('4C 1C','3C 1C','2C 1C','3C 2C','4C 3C','1C 1C','3C 4C','2C 3C','1C 2C','2C 5C','1C 3C','1C 4C','1C 5C','1C 6C','1C 7C','Free Play')),());
        hypersports_dip_b:array [0..5] of def_dip2=(
        (mask:1;name:'After Last Event';number:2;val2:(1,0);name2:('Game Over','Game Continues')),
        (mask:2;name:'Cabinet';number:2;val2:(0,2);name2:('Upright','Cocktail')),
        (mask:4;name:'Demo Sounds';number:2;val2:(4,0);name2:('Off','On')),
        (mask:8;name:'World Records';number:2;val2:(8,0);name2:('Don''t Erase','Erase on Reset')),
        (mask:$f0;name:'Difficulty';number:16;val16:($f0,$e0,$d0,$c0,$b0,$a0,$90,$80,$70,$60,$50,$40,$30,$20,$10,0);name16:('Easy 1','Easy 2','Easy 3','Easy 4','Normal 1','Normal 2','Normal 3','Normal 4','Normal 5','Normal 6','Normal 7','Normal 8','Difficult 1','Difficult 2','Difficult 3','Difficult 4')),());
        roadf_rom:array[0..5] of tipo_roms=(
        (n:'g05_g01.bin';l:$2000;p:$4000;crc:$e2492a06),(n:'g07_f02.bin';l:$2000;p:$6000;crc:$0bf75165),
        (n:'g09_g03.bin';l:$2000;p:$8000;crc:$dde401f8),(n:'g11_f04.bin';l:$2000;p:$a000;crc:$b1283c77),
        (n:'g13_f05.bin';l:$2000;p:$c000;crc:$0ad4d796),(n:'g15_f06.bin';l:$2000;p:$e000;crc:$fa42e0ed));
        roadf_char:array[0..3] of tipo_roms=(
        (n:'a14_e26.bin';l:$4000;p:0;crc:$f5c738e2),(n:'a12_d24.bin';l:$2000;p:$4000;crc:$2d82c930),
        (n:'c14_e22.bin';l:$4000;p:$6000;crc:$fbcfbeb9),(n:'c12_d20.bin';l:$2000;p:$a000;crc:$5e0cf994));
        roadf_sprites:array[0..1] of tipo_roms=(
        (n:'j19_e14.bin';l:$4000;p:0;crc:$16d2bcff),(n:'g19_e18.bin';l:$4000;p:$4000;crc:$490685ff));
        roadf_pal:array[0..2] of tipo_roms=(
        (n:'c03_c27.bin';l:$20;p:0;crc:$45d5e352),(n:'j12_c28.bin';l:$100;p:$20;crc:$2955e01f),
        (n:'a09_c29.bin';l:$100;p:$120;crc:$5b3b5f2a));
        roadf_snd:tipo_roms=(n:'a17_d10.bin';l:$2000;p:0;crc:$c33c927e);
        roadf_dip_b:array [0..6] of def_dip2=(
        (mask:1;name:'Allow Continue';number:2;val2:(1,0);name2:('No','Yes')),
        (mask:6;name:'Number of Opponents';number:4;val4:(6,4,2,0);name4:('Few','Normal','Many','Great Many')),
        (mask:8;name:'Speed of Opponents';number:2;val2:(8,0);name2:('Fast','Slow')),
        (mask:$30;name:'Fuel Consumption';number:4;val4:($30,$20,$10,0);name4:('Slow','Normal','Fast','Very Fast')),
        (mask:$40;name:'Cabinet';number:2;val2:(0,$40);name2:('Upright','Cocktail')),
        (mask:$80;name:'Demo Sounds';number:2;val2:($80,0);name2:('Off','On')),());

var
 flip_screen,irq_ena:boolean;
 sound_latch,chip_latch,lst_snd_irq:byte;
 mem_opcodes:array[0..$bfff] of byte;
 update_video_call,eventos_call:procedure;
 scroll_x:array[0..$1f] of word;
 //Hypersports
 last_addr:word;

procedure draw_sprites;
var
  x,y,atrib:byte;
  f,nchar,color:word;
  flip_x:boolean;
begin
for f:=$1f downto 0 do begin
  atrib:=memoria[$1000+(f*4)];
  nchar:=memoria[$1002+(f*4)]+((atrib and $20) shl 3);
  y:=240-memoria[$1001+(f*4)];
  if flip_screen then begin
    x:=240-memoria[$1003+(f*4)];
    flip_x:=(atrib and $40)<>0;
  end else begin
    x:=memoria[$1003+(f*4)];
    flip_x:=(atrib and $40)=0;
  end;
  color:=(atrib and $f) shl 4;
  put_gfx_sprite(nchar,color,flip_x,(atrib and $80)<>0,1);
  actualiza_gfx_sprite(x,y,2,1);
end;
end;

procedure update_video_hypersports;
var
  x,y,atrib:byte;
  f,nchar,color:word;
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
scroll__x_part2(1,2,8,@scroll_x);
draw_sprites;
actualiza_trozo_final(0,16,256,224,2);
end;

procedure update_video_roadf;
var
  x,y,atrib:byte;
  f,nchar,color:word;
begin
for f:=0 to $7ff do begin
   if gfx[0].buffer[f] then begin
      x:=f mod 64;
      y:=f div 64;
      atrib:=memoria[$2800+f];
      nchar:=memoria[$2000+f]+((atrib and $80) shl 1)+((atrib and $60) shl 4);
      color:=(atrib and $f) shl 4;
      put_gfx_flip(x*8,y*8,nchar,color,1,0,(atrib and $10)<>0,false);
      gfx[0].buffer[f]:=false;
   end;
end;
scroll__x_part2(1,2,8,@scroll_x);
draw_sprites;
actualiza_trozo_final(0,16,256,224,2);
end;

procedure eventos_hypersports;
begin
if event.arcade then begin
  //P1+P2
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.but2[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.but0[1] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[1] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.but2[1] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  //System
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or 1);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or 2);
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or 8);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
end;
end;

procedure eventos_roadf;
begin
if event.arcade then begin
  //P1
  if arcade_input.left[0] then marcade.in0:=marcade.in0 and $fe else marcade.in0:=marcade.in0 or 1;
  if arcade_input.right[0] then marcade.in0:=marcade.in0 and $fd else marcade.in0:=marcade.in0 or 2;
  if arcade_input.up[0] then marcade.in0:=marcade.in0 and $fb else marcade.in0:=marcade.in0 or 4;
  if arcade_input.down[0] then marcade.in0:=marcade.in0 and $f7 else marcade.in0:=marcade.in0 or 8;
  if arcade_input.but0[0] then marcade.in0:=marcade.in0 and $ef else marcade.in0:=marcade.in0 or $10;
  if arcade_input.but1[0] then marcade.in0:=marcade.in0 and $df else marcade.in0:=marcade.in0 or $20;
  //P2
  if arcade_input.left[1] then marcade.in1:=marcade.in1 and $fe else marcade.in1:=marcade.in1 or 1;
  if arcade_input.right[1] then marcade.in1:=marcade.in1 and $fd else marcade.in1:=marcade.in1 or 2;
  if arcade_input.up[1] then marcade.in1:=marcade.in1 and $fb else marcade.in1:=marcade.in1 or 4;
  if arcade_input.down[1] then marcade.in1:=marcade.in1 and $f7 else marcade.in1:=marcade.in1 or 8;
  if arcade_input.but0[1] then marcade.in1:=marcade.in1 and $ef else marcade.in1:=marcade.in1 or $10;
  if arcade_input.but1[1] then marcade.in1:=marcade.in1 and $df else marcade.in1:=marcade.in1 or $20;
  //System
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or 1);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or 2);
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or 8);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
end;
end;

procedure hypersports_principal;
var
  f:byte;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
  for f:=0 to $ff do begin
      eventos_call;
      if f=240 then begin
          if irq_ena then m6809_0.change_irq(ASSERT_LINE);
          update_video_call;
      end;
      //main
      m6809_0.run(frame_main);
      frame_main:=frame_main+m6809_0.tframes-m6809_0.contador;
      //sound
      z80_0.run(frame_snd);
      frame_snd:=frame_snd+z80_0.tframes-z80_0.contador;
  end;
  video_sync;
end;
end;

function hypersports_getbyte(direccion:word):byte;
begin
case direccion of
  $1000..$10ff,$2000..$3fff:hypersports_getbyte:=memoria[direccion];
  $1600:hypersports_getbyte:=marcade.dswb;
  $1680:hypersports_getbyte:=marcade.in2;
  $1681:hypersports_getbyte:=marcade.in0;
  $1682:hypersports_getbyte:=marcade.in1;
  $1683:hypersports_getbyte:=marcade.dswa;
  $4000..$ffff:if m6809_0.opcode then hypersports_getbyte:=mem_opcodes[direccion-$4000]
                  else hypersports_getbyte:=memoria[direccion];
 end;
end;

procedure hypersports_putbyte(direccion:word;valor:byte);
begin
case direccion of
  $1000..$10bf,$3000..$3fff:memoria[direccion]:=valor;
  $10c0..$10ff:if memoria[direccion]<>valor then begin
                memoria[direccion]:=valor;
                direccion:=(direccion and $3f) shr 1;
                if flip_screen then scroll_x[direccion]:=512-(memoria[$10c0+(direccion*2)]+((memoria[$10c1+(direccion*2)] and 1) shl 8))
                  else scroll_x[direccion]:=memoria[$10c0+(direccion*2)]+((memoria[$10c1+(direccion*2)] and 1) shl 8);
               end;
  $1480:begin
          flip_screen:=(valor and 1)<>0;
          main_screen.flip_main_screen:=flip_screen;
        end;
  $1481:begin
          if ((lst_snd_irq=0) and (valor<>0)) then z80_0.change_irq(HOLD_LINE);
          lst_snd_irq:=valor;
        end;
  $1487:begin
          irq_ena:=(valor<>0);
          if not(irq_ena) then m6809_0.change_irq(CLEAR_LINE);
        end;
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
  $8000:hypersports_snd_getbyte:=(vlm5030_0.get_bsy shl 2) or ((z80_0.totalt shr 10) and 3);
end;
end;

procedure hypersports_snd_putbyte(direccion:word;valor:byte);
var
  changes,offset:word;
begin
case direccion of
    0..$3fff:; //ROM
    $4000..$4fff:mem_snd[direccion]:=valor;
    $a000:vlm5030_0.data_w(valor);
    $c000..$dfff:begin
                        offset:=direccion and $1fff;
                        changes:=offset xor last_addr;
                        // A4 VLM5030 ST pin
                        if (changes and $10)<>0 then vlm5030_0.set_st((offset and $10) shr 4);
                        // A5 VLM5030 RST pin
                        if (changes and $20)<>0 then vlm5030_0.set_rst((offset and $20) shr 5);
                        last_addr:=offset;
                      end;
    $e000:dac_0.data8_w(valor);
    $e001:chip_latch:=valor;
    $e002:sn_76496_0.write(chip_latch);
end;
end;

procedure hypersports_sound_update;
begin
  sn_76496_0.update;
  dac_0.update;
  vlm5030_0.update;
end;

//Road Fighter
function roadf_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$4fff:roadf_snd_getbyte:=mem_snd[direccion];
  $6000:roadf_snd_getbyte:=sound_latch;
  $8000:roadf_snd_getbyte:=(z80_0.totalt shr 10) and 3;
end;
end;

procedure roadf_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
    0..$3fff:; //ROM
    $4000..$4fff:mem_snd[direccion]:=valor;
    $e000:dac_0.data8_w(valor);
    $e001:chip_latch:=valor;
    $e002:sn_76496_0.write(chip_latch);
end;
end;

procedure roadf_sound_update;
begin
  sn_76496_0.update;
  dac_0.update;
end;

//Snapshot
procedure hypersports_qsave(nombre:string);
var
  data:pbyte;
  buffer:array[0..4] of byte;
  size:word;
begin
case main_vars.tipo_maquina of
  227:open_qsnapshot_save('hypersports'+nombre);
  400:open_qsnapshot_save('roadf'+nombre);
end;
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
savedata_qsnapshot(@memoria,$4000);
savedata_qsnapshot(@mem_snd[$4000],$c000);
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
case main_vars.tipo_maquina of
  227:if not(open_qsnapshot_load('hypersports'+nombre)) then exit;
  400:if not(open_qsnapshot_load('roadf'+nombre)) then exit;
end;
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
var
  save_name:string;
begin
case main_vars.tipo_maquina of
  227:save_name:='hypersports.nv';
  400:save_name:='roadf.nv';
end;
write_file(Directory.Arcade_nvram+save_name,@memoria[$3800],$800);
end;

procedure reset_hypersports;
begin
 m6809_0.reset;
 z80_0.reset;
 frame_main:=m6809_0.tframes;
 frame_snd:=z80_0.tframes;
 dac_0.reset;
 marcade.in0:=$ff;
 if (main_vars.tipo_maquina=400) then marcade.in1:=$bf
  else begin
    vlm5030_0.reset;
    marcade.in1:=$ff;
  end;
 marcade.in2:=$ff;
 irq_ena:=false;
 sound_latch:=0;
 chip_latch:=0;
 last_addr:=0;
 flip_screen:=false;
 lst_snd_irq:=0;
 fillchar(scroll_x,$40,0);
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
if (main_vars.tipo_maquina=400) then main_screen.rot90_screen:=true;
screen_init(2,256,256,false,true);
iniciar_video(256,224);
//Main CPU
m6809_0:=cpu_m6809.create(18432000 div 12,$100,TCPU_M6809);
m6809_0.change_ram_calls(hypersports_getbyte,hypersports_putbyte);
//Sound CPU
z80_0:=cpu_z80.create(14318180 div 4,$100);
if (main_vars.tipo_maquina=400) then z80_0.init_sound(roadf_sound_update)
  else z80_0.init_sound(hypersports_sound_update);
//Sound Chip
sn_76496_0:=sn76496_chip.create(14318180 div 8);
dac_0:=dac_chip.create(0.80);
case main_vars.tipo_maquina of
  227:begin
        update_video_call:=update_video_hypersports;
        eventos_call:=eventos_hypersports;
        if not(roms_load(@memoria,hypersports_rom)) then exit;
        konami1_decode(@memoria[$4000],@mem_opcodes[0],$c000);
        //Sound CPU
        z80_0.change_ram_calls(hypersports_snd_getbyte,hypersports_snd_putbyte);
        if not(roms_load(@mem_snd,hypersports_snd)) then exit;
        //Extra Sound Chip
        vlm5030_0:=vlm5030_chip.create(3579545,$2000,1);
        if not(roms_load(vlm5030_0.get_rom_addr,hypersports_vlm)) then exit;
        //NV ram
        if read_file_size(Directory.Arcade_nvram+'hypersports.nv',longitud) then read_file(Directory.Arcade_nvram+'hypersports.nv',@memoria[$3800],longitud);
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
        //DIP
        marcade.dswa:=$ff;
        marcade.dswb:=$49;
        marcade.dswa_val2:=@hypersports_dip_a;
        marcade.dswb_val2:=@hypersports_dip_b;
        //paleta
        if not(roms_load(@memoria_temp,hypersports_pal)) then exit;
  end;
  400:begin
        update_video_call:=update_video_roadf;
        eventos_call:=eventos_roadf;
        if not(roms_load(@memoria,roadf_rom)) then exit;
        konami1_decode(@memoria[$4000],@mem_opcodes[0],$c000);
        //Sound CPU
        z80_0.change_ram_calls(roadf_snd_getbyte,roadf_snd_putbyte);
        if not(roms_load(@mem_snd,roadf_snd)) then exit;
        //NV ram
        if read_file_size(Directory.Arcade_nvram+'roadf.nv',longitud) then read_file(Directory.Arcade_nvram+'roadf.nv',@memoria[$3800],longitud);
        //convertir chars
        if not(roms_load(@memoria_temp,roadf_char)) then exit;
        init_gfx(0,8,8,$600);
        gfx_set_desc_data(4,0,16*8,$6000*8+4,$6000*8+0,4,0);
        convert_gfx(0,0,@memoria_temp,@ps_x,@ps_y,false,false);
        //sprites
        if not(roms_load(@memoria_temp,roadf_sprites)) then exit;
        init_gfx(1,16,16,$100);
        gfx[1].trans[0]:=true;
        gfx_set_desc_data(4,0,64*8,$4000*8+4,$4000*8+0,4,0);
        convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,false);
        //DIP
        marcade.dswa:=$ff;
        marcade.dswb:=$2d;
        marcade.dswa_val2:=@hypersports_dip_a;
        marcade.dswb_val2:=@roadf_dip_b;
        //paleta
        if not(roms_load(@memoria_temp,roadf_pal)) then exit;
  end;
end;
compute_resistor_weights(0,	255, -1.0,
			3,@resistances_rg,@rweights,1000,0,
			3,@resistances_rg,@gweights,1000,0,
			2,@resistances_b,@bweights,1000,0);
for f:=0 to $1f do begin
		bit0:=(memoria_temp[f] shr 0) and 1;
		bit1:=(memoria_temp[f] shr 1) and 1;
		bit2:=(memoria_temp[f] shr 2) and 1;
		colores[f].r:=combine_3_weights(@rweights[0], bit0, bit1, bit2);
		bit0:=(memoria_temp[f] shr 3) and 1;
		bit1:=(memoria_temp[f] shr 4) and 1;
		bit2:=(memoria_temp[f] shr 5) and 1;
		colores[f].g:=combine_3_weights(@gweights[0], bit0, bit1, bit2);
		bit0:=(memoria_temp[f] shr 6) and 1;
		bit1:=(memoria_temp[f] shr 7) and 1;
		colores[f].b:=combine_2_weights(@bweights[0], bit0, bit1);
end;
set_pal(colores,$20);
for f:=0 to $ff do begin
    gfx[0].colores[f]:=(memoria_temp[$120+f] and $f) or $10;
    gfx[1].colores[f]:=memoria_temp[$20+f] and $f;
end;
//final
iniciar_hypersports:=true;
end;

end.
