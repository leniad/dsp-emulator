unit kangaroo_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,gfx_engine,rom_engine,ay_8910,pal_engine,
     sound_engine,qsnapshot;

procedure cargar_kangaroo;

implementation
const
        kangaroo_rom:array[0..5] of tipo_roms=(
        (n:'tvg_75.0';l:$1000;p:0;crc:$0d18c581),(n:'tvg_76.1';l:$1000;p:$1000;crc:$5978d37a),
        (n:'tvg_77.2';l:$1000;p:$2000;crc:$522d1097),(n:'tvg_78.3';l:$1000;p:$3000;crc:$063da970),
        (n:'tvg_79.4';l:$1000;p:$4000;crc:$9e5cf8ca),(n:'tvg_80.5';l:$1000;p:$5000;crc:$2fc18049));
        kangaroo_gfx:array[0..3] of tipo_roms=(
        (n:'tvg_83.v0';l:$1000;p:0;crc:$c0446ca6),(n:'tvg_85.v2';l:$1000;p:$1000;crc:$72c52695),
        (n:'tvg_84.v1';l:$1000;p:$2000;crc:$e4cb26c2),(n:'tvg_86.v3';l:$1000;p:$3000;crc:$9e6a599f));
        kangaroo_sound:tipo_roms=(n:'tvg_81.8';l:$1000;p:0;crc:$fb449bfd);
        //DIP
        kangaroo_dipa:array [0..3] of def_dip=(
        (mask:$20;name:'Music';number:2;dip:((dip_val:$0;dip_name:'On'),(dip_val:$20;dip_name:'Off'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$40;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Flip Screen';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$80;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        kangaroo_dipb:array [0..4] of def_dip=(
        (mask:$1;name:'Lives';number:2;dip:((dip_val:$0;dip_name:'3'),(dip_val:$1;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2;name:'Difficulty';number:2;dip:((dip_val:$0;dip_name:'Easy'),(dip_val:$2;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Bonus Life';number:4;dip:((dip_val:$8;dip_name:'10000 30000'),(dip_val:$c;dip_name:'20000 40000'),(dip_val:$4;dip_name:'10000'),(dip_val:$0;dip_name:'None'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$f0;name:'Coinage';number:16;dip:((dip_val:$10;dip_name:'2C/1C'),(dip_val:$20;dip_name:'A 2C/1C B 1C/3C'),(dip_val:$0;dip_name:'1C/1C'),(dip_val:$30;dip_name:'A 1C/1C B 1C/2C'),(dip_val:$40;dip_name:'A 1C/1C B 1C/3C'),(dip_val:$50;dip_name:'A 1C/1C B 1C/4C'),(dip_val:$60;dip_name:'A 1C/1C B 1C/5C'),(dip_val:$70;dip_name:'A 1C/1C B 1C/6C'),(dip_val:$80;dip_name:'1C/2C'),(dip_val:$90;dip_name:'A 1C/2C B 1C/4C'),(dip_val:$a0;dip_name:'A 1C/2C B 1C/5C'),(dip_val:$e0;dip_name:'A 1C/2C B 1C/6C'),(dip_val:$b0;dip_name:'A 1C/2C B 1C/10C'),(dip_val:$c0;dip_name:'A 1C/2C B 1C/11C'),(dip_val:$d0;dip_name:'A 1C/2C B 1C/12C'),(dip_val:$f0;dip_name:'Free Play'))),());

var
 video_control:array[0..$f] of byte;
 sound_latch,mcu_clock,rom_bank:byte;
 video_ram:array[0..(256*64)-1] of dword;
 gfx_data:array[0..1,0..$1fff] of byte;

procedure update_video_kangaroo;inline;
var
  x,y,scrolly,scrollx,maska,maskb,xora,xorb:byte;
  effxb,effyb,pixa,pixb,finalpens:byte;
  effxa,effya,sy,tempa,tempb:word;
  enaa,enab,pria,prib:boolean;
  punt:array[0..$1ffff] of word;
begin
	scrolly:=video_control[6];
	scrollx:=video_control[7];
	maska:=(video_control[10] and $28) shr 3;
	maskb:=(video_control[10] and $07);
  xora:=$ff*((video_control[9] and $20) shr 5);
  xorb:=$ff*((video_control[9] and $10) shr 4);
	enaa:=(video_control[9] and $08)<>0;
	enab:=(video_control[9] and $04)<>0;
	pria:=(not(video_control[9]) and $02)<>0;
	prib:=(not(video_control[9]) and $01)<>0;
	// iterate over pixels */
	for y:=0 to 255 do begin
    sy:=0;
		for x:=0 to 255 do begin
			effxa:=scrollx+(x xor xora);
			effya:=scrolly+(y xor xora);
			effxb:=x xor xorb;
			effyb:=y xor xorb;
      tempa:=effya+256*(effxa shr 2);
      tempb:=effyb+256*(effxb shr 2);
      pixa:=(video_ram[tempa] shr (8*(effxa mod 4)+0)) and $f;
      pixb:=(video_ram[tempb] shr (8*(effxb mod 4)+4)) and $f;
      // for each layer, contribute bits if (a) enabled, and (b) either has priority or the opposite plane is 0 */
      finalpens:=0;
      if (enaa and (pria or (pixb=0))) then finalpens:=finalpens or pixa;
      if (enab and (prib or (pixa=0))) then finalpens:=finalpens or pixb;
      // store the first of two pixels, which is always full brightness */
      punt[sy*256+(255-y)]:=paleta[finalpens and 7];
      // KOS1 alternates at 5MHz, offset from the pixel clock by 1/2 clock */
      // when 0, it enables the color mask for pixels with Z = 0 */
      finalpens:=0;
      if (enaa and (pria or (pixb=0))) then begin
        if ((pixa and $08)=0) then pixa:=pixa and maska;
        finalpens:=finalpens or pixa;
      end;
      if (enab and (prib or (pixa=0))) then begin
        if ((pixb and $08)=0) then pixb:=pixb and maskb;
        finalpens:=finalpens or pixb;
      end;
      // store the second of two pixels, which is affected by KOS1 and the A/B masks */
      punt[(sy+1)*256+(255-y)]:=paleta[finalpens and 7];
      sy:=sy+2;
     end;
	end;
putpixel(0,0,$20000,@punt[0],1);
actualiza_trozo(8,0,240,512,1,0,0,240,512,PANT_TEMP);
end;

procedure eventos_kangaroo;
begin
if event.arcade then begin
  //P1
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 or $1) else marcade.in1:=(marcade.in1 and $fe);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 or $2) else marcade.in1:=(marcade.in1 and $fd);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 or $4) else marcade.in1:=(marcade.in1 and $fb);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 or $8) else marcade.in1:=(marcade.in1 and $f7);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 or $10) else marcade.in1:=(marcade.in1 and $ef);
  //P2
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 or $1) else marcade.in2:=(marcade.in2 and $fe);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 or $2) else marcade.in2:=(marcade.in2 and $fd);
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 or $4) else marcade.in2:=(marcade.in2 and $fb);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 or $8) else marcade.in2:=(marcade.in2 and $f7);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 or $10) else marcade.in2:=(marcade.in2 and $ef);
  //System
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 or $2) else marcade.in0:=(marcade.in0 and $fd);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 or $4) else marcade.in0:=(marcade.in0 and $fb);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 or $8) else marcade.in0:=(marcade.in0 and $f7);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 or $10) else marcade.in0:=(marcade.in0 and $ef);
end;
end;

procedure kangaroo_principal;
var
  frame_m,frame_s:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=z80_0.tframes;
frame_s:=z80_1.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to 259 do begin
    //Main
    z80_0.run(frame_m);
    frame_m:=frame_m+z80_0.tframes-z80_0.contador;
    //Sound
    z80_1.run(frame_s);
    frame_s:=frame_s+z80_1.tframes-z80_1.contador;
    if f=247 then begin
      z80_0.change_irq(HOLD_LINE);
      z80_1.change_irq(HOLD_LINE);
      update_video_kangaroo;
    end;
  end;
  eventos_kangaroo;
  video_sync;
end;
end;

procedure videoram_write(offset:word;data,mask:byte);inline;
var
  expdata,layermask:dword;
begin
	// data contains 4 2-bit values packed as DCBADCBA; expand these into 4 8-bit values */
	expdata:=0;
	if (data and $01)<>0 then expdata:=expdata or $00000055;
	if (data and $10)<>0 then expdata:=expdata or $000000aa;
	if (data and $02)<>0 then expdata:=expdata or $00005500;
	if (data and $20)<>0 then expdata:=expdata or $0000aa00;
	if (data and $04)<>0 then expdata:=expdata or $00550000;
	if (data and $40)<>0 then expdata:=expdata or $00aa0000;
	if (data and $08)<>0 then expdata:=expdata or $55000000;
	if (data and $80)<>0 then expdata:=expdata or $aa000000;
	// determine which layers are enabled */
	layermask:=0;
	if (mask and $08)<>0 then layermask:=layermask or $30303030;
	if (mask and $04)<>0 then layermask:=layermask or $c0c0c0c0;
	if (mask and $02)<>0 then layermask:=layermask or $03030303;
	if (mask and $01)<>0 then layermask:=layermask or $0c0c0c0c;
	// update layers */
	video_ram[offset]:=(video_ram[offset] and not(layermask)) or (expdata and layermask);
end;

procedure blitter_execute;inline;
var
	src,dst,effdst,effsrc:word;
	height,width,mask,x,y:byte;
begin
	src:=video_control[0]+(video_control[1] shl 8);
	dst:=video_control[2]+(video_control[3] shl 8);
	height:=video_control[5];
	width:=video_control[4];
	mask:=video_control[8];
	// during DMA operations, the top 2 bits are ORed together, as well as the bottom 2 bits */
	// adjust the mask to account for this */
	if (mask and $0c)<>0 then mask:=mask or $0c;
	if (mask and $03)<>0 then mask:=mask or $03;
	// loop over height, then width */
	for y:=0 to height do begin
		for x:=0 to width do begin
			effdst:=(dst+x) and $3fff;
			effsrc:=src and $1fff;
      src:=src+1;
			videoram_write(effdst,gfx_data[0,effsrc],mask and $05);
			videoram_write(effdst,gfx_data[1,effsrc],mask and $0a);
		end;
    dst:=dst+256;
  end;
end;

function kangaroo_getbyte(direccion:word):byte;
begin
case direccion of
  0..$5fff,$e000..$e3ff:kangaroo_getbyte:=memoria[direccion];
  $c000..$dfff:kangaroo_getbyte:=gfx_data[rom_bank,direccion and $1fff];
  $e400..$e7ff:kangaroo_getbyte:=marcade.dswb;
  $ec00..$ecff:kangaroo_getbyte:=marcade.in0+marcade.dswa;
  $ed00..$edff:kangaroo_getbyte:=marcade.in1;
  $ee00..$eeff:kangaroo_getbyte:=marcade.in2;
  $ef00..$efff:begin
                  mcu_clock:=mcu_clock+1;
                  kangaroo_getbyte:=mcu_clock and $f;
               end;
end;
end;

procedure kangaroo_putbyte(direccion:word;valor:byte);
begin
if direccion<$6000 then exit;
case direccion of
  $8000..$bfff:videoram_write((direccion and $3fff),valor,video_control[8]);
  $e000..$e3ff:memoria[direccion]:=valor;
  $e800..$ebff:begin
                  video_control[direccion and $f]:=valor;
                  case (direccion and $f) of
                    5:blitter_execute;
                    8:rom_bank:=byte((valor and $5)=0);
                  end;
               end;
  $ec00..$ecff:sound_latch:=valor;
end;
end;

function kangaroo_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$fff:kangaroo_snd_getbyte:=mem_snd[direccion];
  $4000..$4fff:kangaroo_snd_getbyte:=mem_snd[$4000+(direccion and $3ff)];
  $6000..$6fff:kangaroo_snd_getbyte:=sound_latch;
end;
end;

procedure kangaroo_snd_putbyte(direccion:word;valor:byte);
begin
if direccion<$1000 then exit;
case direccion of
  $4000..$4fff:mem_snd[$4000+(direccion and $3ff)]:=valor;
  $7000..$7fff:ay8910_0.write(valor);
  $8000..$8fff:ay8910_0.control(valor);
end;
end;

procedure kangaroo_sound_update;
begin
  ay8910_0.update;
end;

procedure kangaroo_qsave(nombre:string);
var
  data:pbyte;
  size:word;
  buffer:array[0..2] of byte;
begin
open_qsnapshot_save('kangaroo'+nombre);
getmem(data,200);
//CPU
size:=z80_0.save_snapshot(data);
savedata_qsnapshot(data,size);
size:=z80_1.save_snapshot(data);
savedata_qsnapshot(data,size);
//SND
size:=ay8910_0.save_snapshot(data);
savedata_qsnapshot(data,size);
//MEM
savedata_com_qsnapshot(@memoria[$6000],$a000);
savedata_com_qsnapshot(@mem_snd[$1000],$f000);
//MISC
buffer[0]:=sound_latch;
buffer[1]:=mcu_clock;
buffer[2]:=rom_bank;
savedata_qsnapshot(@buffer,3);
savedata_com_qsnapshot(@video_control,$10);
savedata_com_qsnapshot(@video_ram,$4000*4);
freemem(data);
close_qsnapshot;
end;

procedure kangaroo_qload(nombre:string);
var
  data:pbyte;
  buffer:array[0..2] of byte;
begin
if not(open_qsnapshot_load('kangaroo'+nombre)) then exit;
getmem(data,200);
//CPU
loaddata_qsnapshot(data);
z80_0.load_snapshot(data);
loaddata_qsnapshot(data);
z80_1.load_snapshot(data);
//SND
loaddata_qsnapshot(data);
ay8910_0.load_snapshot(data);
//MEM
loaddata_qsnapshot(@memoria[$6000]);
loaddata_qsnapshot(@mem_snd[$1000]);
//MISC
loaddata_qsnapshot(@buffer);
sound_latch:=buffer[0];
mcu_clock:=buffer[1];
rom_bank:=buffer[2];
loaddata_qsnapshot(@video_control);
loaddata_qsnapshot(@video_ram);
freemem(data);
close_qsnapshot;
end;

//Main
procedure reset_kangaroo;
begin
 z80_0.reset;
 z80_0.change_nmi(PULSE_LINE);
 z80_1.reset;
 ay8910_0.reset;
 reset_audio;
 marcade.in0:=0;
 marcade.in1:=0;
 marcade.in2:=0;
 sound_latch:=0;
 fillchar(video_control,$10,0);
 fillchar(video_ram,256*64*4,0);
 mcu_clock:=0;
 rom_bank:=0;
end;

function iniciar_kangaroo:boolean;
var
  colores:tpaleta;
  f:word;
  mem_temp:array[0..$3fff] of byte;
begin
iniciar_kangaroo:=false;
iniciar_audio(false);
screen_init(1,256,512);
iniciar_video(240,512);
//Main CPU
z80_0:=cpu_z80.create(10000000 div 4,260);
z80_0.change_ram_calls(kangaroo_getbyte,kangaroo_putbyte);
//Sound CPU
z80_1:=cpu_z80.create(10000000 div 8,260);
z80_1.change_ram_calls(kangaroo_snd_getbyte,kangaroo_snd_putbyte);
z80_1.change_io_calls(kangaroo_snd_getbyte,kangaroo_snd_putbyte);
z80_1.init_sound(kangaroo_sound_update);
//Sound chip
ay8910_0:=ay8910_chip.create(10000000 div 8,AY8910,0.5);
//cargar roms
if not(roms_load(@memoria,@kangaroo_rom,'kangaroo.zip',sizeof(kangaroo_rom))) then exit;
//cargar roms snd
if not(roms_load(@mem_snd,@kangaroo_sound,'kangaroo.zip',sizeof(kangaroo_sound))) then exit;
//cargar gfx
if not(roms_load(@mem_temp,@kangaroo_gfx,'kangaroo.zip',sizeof(kangaroo_gfx))) then exit;
copymemory(@gfx_data[0,0],@mem_temp[0],$2000);
copymemory(@gfx_data[1,0],@mem_temp[$2000],$2000);
for f:=0 to 7 do begin
  colores[f].r:=pal1bit(f shr 2);
  colores[f].g:=pal1bit(f shr 1);
  colores[f].b:=pal1bit(f shr 0);
end;
set_pal(colores,8);
marcade.dswa:=$0;
marcade.dswa_val:=@kangaroo_dipa;
marcade.dswb:=$0;
marcade.dswb_val:=@kangaroo_dipb;
//final
reset_kangaroo;
iniciar_kangaroo:=true;
end;

procedure Cargar_Kangaroo;
begin
llamadas_maquina.iniciar:=iniciar_kangaroo;
llamadas_maquina.bucle_general:=kangaroo_principal;
llamadas_maquina.reset:=reset_kangaroo;
llamadas_maquina.fps_max:=60.096154;
llamadas_maquina.save_qsnap:=kangaroo_qsave;
llamadas_maquina.load_qsnap:=kangaroo_qload;
end;

end.
