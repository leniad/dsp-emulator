unit yiearkungfu_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6809,main_engine,controls_engine,sn_76496,vlm_5030,gfx_engine,
     timer_engine,rom_engine,pal_engine,sound_engine,qsnapshot;

function iniciar_yiear:boolean;

implementation
const
        yiear_rom:array[0..1] of tipo_roms=(
        (n:'i08.10d';l:$4000;p:$8000;crc:$e2d7458b),(n:'i07.8d';l:$4000;p:$c000;crc:$7db7442e));
        yiear_char:array[0..1] of tipo_roms=((n:'g16_1.bin';l:$2000;p:0;crc:$b68fd91d),
        (n:'g15_2.bin';l:$2000;p:$2000;crc:$d9b167c6));
        yiear_sprites:array[0..3] of tipo_roms=(
        (n:'g04_5.bin';l:$4000;p:0;crc:$45109b29),(n:'g03_6.bin';l:$4000;p:$4000;crc:$1d650790),
        (n:'g06_3.bin';l:$4000;p:$8000;crc:$e6aa945b),(n:'g05_4.bin';l:$4000;p:$c000;crc:$cc187c22));
        yiear_pal:tipo_roms=(n:'yiear.clr';l:$20;p:0;crc:$c283d71f);
        yiear_vlm:tipo_roms=(n:'a12_9.bin';l:$2000;p:0;crc:$f75a1539);
        //Dip
        yiear_dip_a:array [0..2] of def_dip2=(
        (mask:$f;name:'Coin A';number:16;val16:(2,5,8,4,1,$f,3,7,$e,6,$d,$c,$b,$a,9,0);name16:('4C 1C','3C 1C','2C 1C','3C 2C','4C 3C','1C 1C','3C 4C','2C 3C','1C 2C','2C 5C','1C 3C','1C 4C','1C 5C','1C 6C','1C 7C','Free Play')),
        (mask:$f0;name:'Coin B';number:16;val16:($20,$50,$80,$40,$10,$f0,$30,$70,$e0,$60,$d0,$c0,$b0,$a0,$90,0);name16:('4C 1C','3C 1C','2C 1C','3C 2C','4C 3C','1C 1C','3C 4C','2C 3C','1C 2C','2C 5C','1C 3C','1C 4C','1C 5C','1C 6C','1C 7C','Invalid')),());
        yiear_dip_b:array [0..5] of def_dip2=(
        (mask:3;name:'Lives';number:4;val4:(3,2,1,0);name4:('1','2','3','5')),
        (mask:4;name:'Cabinet';number:2;val2:(0,4);name2:('Upright','Cocktail')),
        (mask:8;name:'Bonus Life';number:2;val2:(8,0);name2:('30K 80K','40K 90K')),
        (mask:$30;name:'Difficulty';number:4;val4:($30,$10,$20,0);name4:('Easy','Normal','Difficult','Very Difficult')),
        (mask:$80;name:'Demo Sounds';number:2;val2:($80,0);name2:('Off','On')),());
        yiear_dip_c:array [0..2] of def_dip2=(
        (mask:1;name:'Flip Screen';number:2;val2:(1,0);name2:('Off','On')),
        (mask:2;name:'Upright Controls';number:2;val2:(2,0);name2:('Single','Dual')),());

var
 irq_ena,nmi_ena:boolean;
 sound_latch:byte;

procedure update_video_yiear;
var
  x,y:byte;
  f,nchar,atrib:word;
begin
for f:=0 to $3ff do begin
    if gfx[0].buffer[f] then begin
      x:=f and $1f;
      y:=f shr 5;
      atrib:=memoria[$5800+(f*2)];
      nchar:=memoria[$5801+(f*2)]+((atrib and $10) shl 4);
      put_gfx_flip(x*8,y*8,nchar,16,1,0,(atrib and $80)<>0,(atrib and $40)<>0);
      gfx[0].buffer[f]:=false;
    end;
end;
actualiza_trozo(0,0,256,256,1,0,0,256,256,2);
for f:=$17 downto 0 do begin
  atrib:=memoria[$5000+(f*2)];
  nchar:=memoria[$5401+(f*2)]+((atrib and 1) shl 8);
  x:=memoria[$5400+(f*2)];
  y:=240-memoria[$5001+(f*2)];
  if f<$13 then y:=y+1;
  put_gfx_sprite(nchar,0,(atrib and $40)=0,(atrib and $80)<>0,1);
  actualiza_gfx_sprite(x,y,2,1);
end;
actualiza_trozo_final(0,16,256,224,2);
end;

procedure eventos_yiear;
begin
if event.arcade then begin
  //P1
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or 8);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  //P2
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or 1);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or 2);
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or 4);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or 8);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  //SYS
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
end;
end;

procedure yiear_principal;
var
  f:byte;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
  for f:=0 to 255 do begin
    if f=240 then begin
      if irq_ena then m6809_0.change_irq(HOLD_LINE);
      update_video_yiear;
    end;
    m6809_0.run(frame_main);
    frame_main:=frame_main+m6809_0.tframes-m6809_0.contador;
  end;
  eventos_yiear;
  video_sync;
end;
end;

function yiear_getbyte(direccion:word):byte;
begin
case direccion of
  0:yiear_getbyte:=vlm5030_0.get_bsy;
  $4c00:yiear_getbyte:=marcade.dswb;
  $4d00:yiear_getbyte:=marcade.dswc;
  $4e00:yiear_getbyte:=marcade.in0;
  $4e01:yiear_getbyte:=marcade.in1;
  $4e02:yiear_getbyte:=marcade.in2;
  $4e03:yiear_getbyte:=marcade.dswa;
  $5000..$5fff,$8000..$ffff:yiear_getbyte:=memoria[direccion];
end;
end;

procedure yiear_putbyte(direccion:word;valor:byte);
begin
case direccion of
  $4000:begin
          irq_ena:=(valor and 4)<>0;
          nmi_ena:=(valor and 2)<>0;
          main_screen.flip_main_screen:=(valor and 1)<>0;
        end;
  $4800:sound_latch:=valor;
  $4900:sn_76496_0.Write(sound_latch);
  $4a00:begin
           vlm5030_0.set_st((valor shr 1) and 1);
	         vlm5030_0.set_rst((valor shr 2) and 1);
        end;
  $4b00:vlm5030_0.data_w(valor);
  $5000..$57ff:memoria[direccion]:=valor;
  $5800..$5fff:if memoria[direccion]<>valor then begin
                  gfx[0].buffer[(direccion and $7ff) shr 1]:=true;
                  memoria[direccion]:=valor;
               end;
  $8000..$ffff:; //ROM
end;
end;

procedure yiear_snd_nmi;
begin
  if nmi_ena then m6809_0.change_nmi(PULSE_LINE);
end;

procedure yiear_sound_update;
begin
  sn_76496_0.update;
  vlm5030_0.update;
end;

procedure yiear_qsave(nombre:string);
var
  data:pbyte;
  buffer:array[0..2] of byte;
  size:word;
begin
open_qsnapshot_save('yiear'+nombre);
getmem(data,250);
//CPU
size:=m6809_0.save_snapshot(data);
savedata_qsnapshot(data,size);
//SND
size:=sn_76496_0.save_snapshot(data);
savedata_qsnapshot(data,size);
size:=vlm5030_0.save_snapshot(data);
savedata_qsnapshot(data,size);
//MEM
savedata_qsnapshot(@memoria[0],$8000);
//MISC
buffer[0]:=byte(irq_ena);
buffer[1]:=byte(nmi_ena);
buffer[2]:=sound_latch;
savedata_qsnapshot(@buffer,3);
freemem(data);
close_qsnapshot;
end;

procedure yiear_qload(nombre:string);
var
  data:pbyte;
  buffer:array[0..2] of byte;
begin
if not(open_qsnapshot_load('yiear'+nombre)) then exit;
getmem(data,250);
//CPU
loaddata_qsnapshot(data);
m6809_0.load_snapshot(data);
//SND
loaddata_qsnapshot(data);
sn_76496_0.load_snapshot(data);
loaddata_qsnapshot(data);
vlm5030_0.load_snapshot(data);
//MEM
loaddata_qsnapshot(@memoria[0]);
//MISC
loaddata_qsnapshot(@buffer);
irq_ena:=buffer[0]<>0;
nmi_ena:=buffer[1]<>0;
sound_latch:=buffer[2];
freemem(data);
close_qsnapshot;
//END
fillchar(gfx[0].buffer,$400,1);
end;

//Main
procedure reset_yiear;
begin
 m6809_0.reset;
 frame_main:=m6809_0.tframes;
 sn_76496_0.reset;
 vlm5030_0.reset;
 reset_audio;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 irq_ena:=false;
 nmi_ena:=false;
 sound_latch:=0;
end;

function iniciar_yiear:boolean;
var
    colores:tpaleta;
    f,ctemp1,ctemp2,ctemp3:byte;
    memoria_temp:array[0..$ffff] of byte;
const
    pc_x:array[0..7] of dword=(0, 1, 2, 3, 8*8+0, 8*8+1, 8*8+2, 8*8+3);
    ps_x:array[0..15] of dword=(0*8*8+0, 0*8*8+1, 0*8*8+2, 0*8*8+3, 1*8*8+0, 1*8*8+1, 1*8*8+2, 1*8*8+3,
	  2*8*8+0, 2*8*8+1, 2*8*8+2, 2*8*8+3, 3*8*8+0, 3*8*8+1, 3*8*8+2, 3*8*8+3);
    ps_y:array[0..15] of dword=(0*8,  1*8,  2*8,  3*8,  4*8,  5*8,  6*8,  7*8,
	  32*8, 33*8, 34*8, 35*8, 36*8, 37*8, 38*8, 39*8);
begin
llamadas_maquina.bucle_general:=yiear_principal;
llamadas_maquina.reset:=reset_yiear;
llamadas_maquina.fps_max:=60.58;
llamadas_maquina.save_qsnap:=yiear_qsave;
llamadas_maquina.load_qsnap:=yiear_qload;
iniciar_yiear:=false;
iniciar_audio(false);
screen_init(1,256,256);
screen_init(2,256,256,false,true);
iniciar_video(256,224);
//Main CPU
m6809_0:=cpu_m6809.Create(18432000 div 12,$100,TCPU_M6809);
m6809_0.change_ram_calls(yiear_getbyte,yiear_putbyte);
m6809_0.init_sound(yiear_sound_update);
timers.init(m6809_0.numero_cpu,1536000/480,yiear_snd_nmi,nil,true);
if not(roms_load(@memoria,yiear_rom)) then exit;
//Sound Chip
sn_76496_0:=sn76496_chip.Create(18432000 div 12);
vlm5030_0:=vlm5030_chip.Create(3579545,$2000,2);
if not(roms_load(vlm5030_0.get_rom_addr,yiear_vlm)) then exit;
//convertir chars
if not(roms_load(@memoria_temp,yiear_char)) then exit;
init_gfx(0,8,8,512);
gfx_set_desc_data(4,0,16*8,4,0,$2000*8+4,$2000*8+0);
convert_gfx(0,0,@memoria_temp,@pc_x,@ps_y,false,false);
//sprites
if not(roms_load(@memoria_temp,yiear_sprites)) then exit;
init_gfx(1,16,16,512);
gfx[1].trans[0]:=true;
gfx_set_desc_data(4,0,64*8,4,0,$8000*8+4,$8000*8+0);
convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,false);
//paleta
if not(roms_load(@memoria_temp,yiear_pal)) then exit;
for f:=0 to 31 do begin
  ctemp1:=memoria_temp[f] and 1;
  ctemp2:=(memoria_temp[f] shr 1) and 1;
  ctemp3:=(memoria_temp[f] shr 2) and 1;
  colores[f].r:=$21*ctemp1+$47*ctemp2+$97*ctemp3;
  ctemp1:=(memoria_temp[f] shr 3) and 1;
  ctemp2:=(memoria_temp[f] shr 4) and 1;
  ctemp3:=(memoria_temp[f] shr 5) and 1;
  colores[f].g:=$21*ctemp1+$47*ctemp2+$97*ctemp3;
  ctemp1:=0;
  ctemp2:=(memoria_temp[f] shr 6) and 1;
  ctemp3:=(memoria_temp[f] shr 7) and 1;
  colores[f].b:=$21*ctemp1+$47*ctemp2+$97*ctemp3;
end;
set_pal(colores,32);
//DIP
marcade.dswa:=$ff;
marcade.dswb:=$5b;
marcade.dswc:=$ff;
marcade.dswa_val2:=@yiear_dip_a;
marcade.dswb_val2:=@yiear_dip_b;
marcade.dswc_val2:=@yiear_dip_c;
//final
reset_yiear;
iniciar_yiear:=true;
end;

end.
