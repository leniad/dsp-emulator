unit superbasketball_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6809,nz80,main_engine,controls_engine,sn_76496,vlm_5030,gfx_engine,
     dac,rom_engine,pal_engine,konami_decrypt,sound_engine,qsnapshot;

procedure cargar_sbasketb;

implementation
const
        sbasketb_rom:array[0..2] of tipo_roms=(
        (n:'405g05.14j';l:$2000;p:$6000;crc:$336dc0ab),(n:'405i03.11j';l:$4000;p:$8000;crc:$d33b82dd),
        (n:'405i01.9j';l:$4000;p:$c000;crc:$1c09cc3f));
        sbasketb_char:tipo_roms=(n:'405e12.22f';l:$4000;p:0;crc:$e02c54da);
        sbasketb_sprites:array[0..2] of tipo_roms=(
        (n:'405h06.14g';l:$4000;p:0;crc:$cfbbff07),(n:'405h08.17g';l:$4000;p:$4000;crc:$c75901b6),
        (n:'405h10.20g';l:$4000;p:$8000;crc:$95bc5942));
        sbasketb_pal:array[0..4] of tipo_roms=(
        (n:'405e17.5a';l:$100;p:$0;crc:$b4c36d57),(n:'405e16.4a';l:$100;p:$100;crc:$0b7b03b8),
        (n:'405e18.6a';l:$100;p:$200;crc:$9e533bad),(n:'405e20.19d';l:$100;p:$300;crc:$8ca6de2f),
        (n:'405e19.16d';l:$100;p:$400;crc:$e0bc782f));
        sbasketb_vlm:tipo_roms=(n:'405e15.11f';l:$2000;p:$0;crc:$01bb5ce9);
        sbasketb_snd:tipo_roms=(n:'405e13.7a';l:$2000;p:$0;crc:$1ec7458b);
        sbasketb_dip_a:array [0..2] of def_dip=(
        (mask:$0f;name:'Coin A';number:16;dip:((dip_val:$2;dip_name:'4C 1C'),(dip_val:$5;dip_name:'3C 1C'),(dip_val:$8;dip_name:'2C 1C'),(dip_val:$4;dip_name:'3C 2C'),(dip_val:$1;dip_name:'4C 3C'),(dip_val:$f;dip_name:'1C 1C'),(dip_val:$3;dip_name:'3C 4C'),(dip_val:$7;dip_name:'2C 3C'),(dip_val:$e;dip_name:'1C 2C'),(dip_val:$6;dip_name:'2C 5C'),(dip_val:$d;dip_name:'1C 3C'),(dip_val:$c;dip_name:'1C 4C'),(dip_val:$b;dip_name:'1C 5C'),(dip_val:$a;dip_name:'1C 6C'),(dip_val:$9;dip_name:'1C 7C'),(dip_val:$0;dip_name:'Free Play'))),
        (mask:$f0;name:'Coin B';number:15;dip:((dip_val:$20;dip_name:'4C 1C'),(dip_val:$50;dip_name:'3C 1C'),(dip_val:$80;dip_name:'2C 1C'),(dip_val:$40;dip_name:'3C 2C'),(dip_val:$10;dip_name:'4C 3C'),(dip_val:$f0;dip_name:'1C 1C'),(dip_val:$30;dip_name:'3C 4C'),(dip_val:$70;dip_name:'2C 3C'),(dip_val:$e0;dip_name:'1C 2C'),(dip_val:$60;dip_name:'2C 5C'),(dip_val:$d0;dip_name:'1C 3C'),(dip_val:$c0;dip_name:'1C 4C'),(dip_val:$b0;dip_name:'1C 5C'),(dip_val:$a0;dip_name:'1C 6C'),(dip_val:$90;dip_name:'1C 7C'),(dip_val:$0;dip_name:'Free Play'))),());
        sbasketb_dip_b:array [0..6] of def_dip=(
        (mask:$3;name:'Game Time';number:4;dip:((dip_val:$3;dip_name:'30'),(dip_val:$1;dip_name:'40'),(dip_val:$2;dip_name:'50'),(dip_val:$0;dip_name:'60'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$4;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Starting Score';number:2;dip:((dip_val:$8;dip_name:'70-78'),(dip_val:$0;dip_name:'100-115'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Ranking';number:2;dip:((dip_val:$0;dip_name:'Data Remaining'),(dip_val:$10;dip_name:'Data Initialized'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$60;name:'Difficulty';number:4;dip:((dip_val:$60;dip_name:'Easy'),(dip_val:$40;dip_name:'Medium'),(dip_val:$20;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Demo Sounds';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 pedir_snd_irq,irq_ena:boolean;
 frame,sound_latch,chip_latch,scroll_x,sbasketb_palettebank,sprite_select:byte;
 mem_opcodes:array[0..$9fff] of byte;
 last_addr:word;

procedure update_video_sbasketb;inline;
var
  f,nchar,color,offset:word;
  x,y,atrib:byte;
begin
for f:=0 to $3ff do begin
   if gfx[0].buffer[f] then begin
      x:=31-(f div 32);
      y:=f mod 32;
      atrib:=memoria[$3000+f];
      nchar:=memoria[$3400+f]+((atrib and $20) shl 3);
      color:=(atrib and $f) shl 4;
      put_gfx_flip(x*8,y*8,nchar,color,1,0,(atrib and $80)<>0,(atrib and $40)<>0);
      gfx[0].buffer[f]:=false;
   end;
end;
//La parte de arriba es fija...
actualiza_trozo(0,0,256,48,1,0,0,256,48,2);
scroll__x_part2(1,2,208,@scroll_x,0,0,48);
offset:=sprite_select*$100;
for f:=0 to $3f do begin
  atrib:=memoria[$3801+offset+(f*4)];
  nchar:=memoria[$3800+offset+(f*4)]+((atrib and $20) shl 3);
  y:=memoria[$3802+offset+(f*4)];
  x:=240-(memoria[$3803+offset+(f*4)]);
  color:=((atrib and $0f)+16*sbasketb_palettebank) shl 4;
  put_gfx_sprite(nchar,color,(atrib and $80)<>0,(atrib and $40)<>0,1);
  actualiza_gfx_sprite(x,y,2,1);
end;
actualiza_trozo_final(16,0,224,256,2);
end;

procedure eventos_sbasketb;
begin
if event.arcade then begin
  //P1
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but2[0] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  //P2
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.but2[1] then marcade.in2:=(marcade.in2 and $bf) else marcade.in2:=(marcade.in2 or $40);
  //System
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
end;
end;

procedure sbasketb_principal;
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
          update_video_sbasketb;
      end;
  end;
  //General
  eventos_sbasketb;
  video_sync;
end;
end;

function sbasketb_getbyte(direccion:word):byte;
begin
case direccion of
  $2000..$3bff:sbasketb_getbyte:=memoria[direccion];
  $3e00:sbasketb_getbyte:=marcade.in0;
  $3e01:sbasketb_getbyte:=marcade.in1;
  $3e02:sbasketb_getbyte:=marcade.in2;
  $3e80:sbasketb_getbyte:=marcade.dswb;
  $3f00:sbasketb_getbyte:=marcade.dswa;
  $6000..$ffff:if m6809_0.opcode then sbasketb_getbyte:=mem_opcodes[direccion-$6000]
                  else sbasketb_getbyte:=memoria[direccion];
 end;
end;

procedure sbasketb_putbyte(direccion:word;valor:byte);
begin
if direccion>$5fff then exit;
case direccion of
  $2000..$2fff,$3800..$3bff:memoria[direccion]:=valor;
  $3000..$37ff:if memoria[direccion]<>valor then begin
                  gfx[0].buffer[direccion and $3ff]:=true;
                  memoria[direccion]:=valor;
               end;
  $3c20:sbasketb_palettebank:=valor;
  $3c80:main_screen.flip_main_screen:=(valor and $1)<>0;
  $3c81:irq_ena:=(valor<>0);
  $3c85:sprite_select:=valor and 1;
  $3d00:sound_latch:=valor;
  $3d80:z80_0.change_irq(HOLD_LINE);
  $3f80:scroll_x:=not(valor);
end;
end;

function sbasketb_snd_getbyte(direccion:word):byte;
var
  clock:byte;
begin
case direccion of
  0..$1fff,$4000..$43ff:sbasketb_snd_getbyte:=mem_snd[direccion];
  $6000:sbasketb_snd_getbyte:=sound_latch;
  $8000:begin
          clock:=(z80_0.contador+trunc(z80_0.tframes*frame)) shr 10;
          sbasketb_snd_getbyte:=(clock and $3) or ((vlm5030_0.get_bsy and 1) shl 2);
        end;
end;
end;

procedure sbasketb_snd_putbyte(direccion:word;valor:byte);
var
  changes,offset:word;
begin
if direccion<$2000 then exit;
case direccion of
    $4000..$43ff:mem_snd[direccion]:=valor;
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

procedure sbasketb_sound_update;
begin
  sn_76496_0.Update;
  dac_0.update;
  vlm5030_0.update;
end;

procedure sbasketb_qsave(nombre:string);
var
  data:pbyte;
  buffer:array[0..8] of byte;
  size:word;
begin
open_qsnapshot_save('sbasketb'+nombre);
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
savedata_com_qsnapshot(@memoria,$6000);
savedata_com_qsnapshot(@mem_snd[$2000],$e000);
//MISC
buffer[0]:=byte(pedir_snd_irq);
buffer[1]:=byte(irq_ena);
buffer[2]:=sound_latch;
buffer[3]:=chip_latch;
buffer[4]:=scroll_x;
buffer[5]:=sbasketb_palettebank;
buffer[6]:=sprite_select;
buffer[7]:=last_addr and $ff;
buffer[8]:=last_addr shr 8;
savedata_qsnapshot(@buffer[0],9);
freemem(data);
close_qsnapshot;
end;

procedure sbasketb_qload(nombre:string);
var
  data:pbyte;
  buffer:array[0..8] of byte;
begin
if not(open_qsnapshot_load('sbasketb'+nombre)) then exit;
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
loaddata_qsnapshot(@mem_snd[$2000]);
//MISC
loaddata_qsnapshot(@buffer);
pedir_snd_irq:=buffer[0]<>0;
irq_ena:=buffer[1]<>0;
sound_latch:=buffer[2];
chip_latch:=buffer[3];
scroll_x:=buffer[4];
sbasketb_palettebank:=buffer[5];
sprite_select:=buffer[6];
last_addr:=buffer[7] or (buffer[8] shl 8);
freemem(data);
close_qsnapshot;
//END
fillchar(gfx[0].buffer,$400,1);
end;

//Main
procedure reset_sbasketb;
begin
 m6809_0.reset;
 z80_0.reset;
 vlm5030_0.reset;
 dac_0.reset;
 reset_audio;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 pedir_snd_irq:=false;
 irq_ena:=false;
 sound_latch:=0;
 chip_latch:=0;
 scroll_x:=0;
 sbasketb_palettebank:=0;
 sprite_select:=0;
 last_addr:=0;
end;

function iniciar_sbasketb:boolean;
var
    colores:tpaleta;
    f,j:byte;
    memoria_temp:array[0..$bfff] of byte;
const
    pc_y:array[0..7] of dword=(0*4*8, 1*4*8, 2*4*8, 3*4*8, 4*4*8, 5*4*8, 6*4*8, 7*4*8);
    ps_x:array[0..15] of dword=(0*4, 1*4,  2*4,  3*4,  4*4,  5*4,  6*4,  7*4,
			8*4, 9*4, 10*4, 11*4, 12*4, 13*4, 14*4, 15*4);
    ps_y:array[0..15] of dword=(0*4*16, 1*4*16,  2*4*16,  3*4*16,  4*4*16,  5*4*16,  6*4*16,  7*4*16,
			8*4*16, 9*4*16, 10*4*16, 11*4*16, 12*4*16, 13*4*16, 14*4*16, 15*4*16);
begin
iniciar_sbasketb:=false;
iniciar_audio(false);
screen_init(1,256,256);
screen_mod_scroll(1,256,256,255,256,256,255);
screen_init(2,256,256,false,true);
iniciar_video(224,256);
//Main CPU
m6809_0:=cpu_m6809.Create(1400000,$100,TCPU_MC6809E);
m6809_0.change_ram_calls(sbasketb_getbyte,sbasketb_putbyte);
//Sound CPU
z80_0:=cpu_z80.create(3579545,$100);
z80_0.change_ram_calls(sbasketb_snd_getbyte,sbasketb_snd_putbyte);
z80_0.init_sound(sbasketb_sound_update);
//Sound Chip
sn_76496_0:=sn76496_chip.Create(1789772);
vlm5030_0:=vlm5030_chip.Create(3579545,$2000,4);
if not(roms_load(vlm5030_0.get_rom_addr,@sbasketb_vlm,'sbasketb.zip',sizeof(sbasketb_vlm))) then exit;
dac_0:=dac_chip.Create(0.80);
//cargar roms
if not(roms_load(@memoria,@sbasketb_rom,'sbasketb.zip',sizeof(sbasketb_rom))) then exit;
konami1_decode(@memoria[$6000],@mem_opcodes,$a000);
//cargar snd roms
if not(roms_load(@mem_snd,@sbasketb_snd,'sbasketb.zip',sizeof(sbasketb_snd))) then exit;
//convertir chars
if not(roms_load(@memoria_temp,@sbasketb_char,'sbasketb.zip',sizeof(sbasketb_char))) then exit;
init_gfx(0,8,8,512);
gfx_set_desc_data(4,0,8*4*8,0,1,2,3);
convert_gfx(0,0,@memoria_temp,@ps_x,@pc_y,true,false);
//sprites
if not(roms_load(@memoria_temp,@sbasketb_sprites,'sbasketb.zip',sizeof(sbasketb_sprites))) then exit;
init_gfx(1,16,16,384);
gfx[1].trans[0]:=true;
gfx_set_desc_data(4,0,32*4*8,0,1,2,3);
convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,true,false);
//paleta
if not(roms_load(@memoria_temp,@sbasketb_pal,'sbasketb.zip',sizeof(sbasketb_pal))) then exit;
for f:=0 to $ff do begin
  colores[f].r:=((memoria_temp[f] and $f) shl 4) or (memoria_temp[f] and $f);
  colores[f].g:=((memoria_temp[f+$100] and $f) shl 4) or (memoria_temp[f+$100] shr 4);
  colores[f].b:=((memoria_temp[f+$200] and $f) shl 4) or (memoria_temp[f+$200] and $f);
end;
set_pal(colores,256);
for f:=0 to $ff do begin
    gfx[0].colores[f]:=(memoria_temp[$300+f] and $f) or $f0;
		for j:=0 to $f do gfx[1].colores[(j shl 8) or f]:=((j shl 4) or (memoria_temp[f + $400] and $0f));
end;
//DIP
marcade.dswa:=$ff;
marcade.dswb:=$68;
marcade.dswa_val:=@sbasketb_dip_a;
marcade.dswb_val:=@sbasketb_dip_b;
//final
reset_sbasketb;
iniciar_sbasketb:=true;
end;

procedure Cargar_sbasketb;
begin
llamadas_maquina.iniciar:=iniciar_sbasketb;
llamadas_maquina.bucle_general:=sbasketb_principal;
llamadas_maquina.reset:=reset_sbasketb;
llamadas_maquina.save_qsnap:=sbasketb_qsave;
llamadas_maquina.load_qsnap:=sbasketb_qload;
end;

end.
