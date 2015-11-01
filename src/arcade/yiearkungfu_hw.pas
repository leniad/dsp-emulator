unit yiearkungfu_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6809,main_engine,controls_engine,sn_76496,vlm_5030,gfx_engine,
     timer_engine,rom_engine,pal_engine,sound_engine,qsnapshot;

procedure Cargar_yiear;
procedure yiear_principal;
function iniciar_yiear:boolean;
procedure reset_yiear;
procedure cerrar_yiear;
//Main CPU
function yiear_getbyte(direccion:word):byte;
procedure yiear_putbyte(direccion:word;valor:byte);
procedure yiear_sound_update;
procedure yiear_snd_nmi;
//Save/load
procedure yiear_qsave(nombre:string);
procedure yiear_qload(nombre:string);

implementation
const
        yiear_rom:array[0..2] of tipo_roms=(
        (n:'i08.10d';l:$4000;p:$8000;crc:$e2d7458b),(n:'i07.8d';l:$4000;p:$c000;crc:$7db7442e),());
        yiear_char:array[0..2] of tipo_roms=((n:'g16_1.bin';l:$2000;p:0;crc:$b68fd91d),
        (n:'g15_2.bin';l:$2000;p:$2000;crc:$d9b167c6),());
        yiear_sprites:array[0..4] of tipo_roms=(
        (n:'g04_5.bin';l:$4000;p:0;crc:$45109b29),(n:'g03_6.bin';l:$4000;p:$4000;crc:$1d650790),
        (n:'g06_3.bin';l:$4000;p:$8000;crc:$e6aa945b),(n:'g05_4.bin';l:$4000;p:$c000;crc:$cc187c22),());
        yiear_pal:tipo_roms=(n:'yiear.clr';l:$20;p:$0;crc:$c283d71f);
        yiear_vlm:tipo_roms=(n:'a12_9.bin';l:$2000;p:$0;crc:$f75a1539);
        //Dip
        yiear_dip_a:array [0..2] of def_dip=(
        (mask:$0f;name:'Coin A';number:16;dip:((dip_val:$2;dip_name:'4C 1C'),(dip_val:$5;dip_name:'3C 1C'),(dip_val:$8;dip_name:'2C 1C'),(dip_val:$4;dip_name:'3C 2C'),(dip_val:$1;dip_name:'4C 3C'),(dip_val:$f;dip_name:'1C 1C'),(dip_val:$3;dip_name:'3C 4C'),(dip_val:$7;dip_name:'2C 3C'),(dip_val:$e;dip_name:'1C 2C'),(dip_val:$6;dip_name:'2C 5C'),(dip_val:$d;dip_name:'1C 3C'),(dip_val:$c;dip_name:'1C 4C'),(dip_val:$b;dip_name:'1C 5C'),(dip_val:$a;dip_name:'1C 6C'),(dip_val:$9;dip_name:'1C 7C'),(dip_val:$0;dip_name:'Free Play'))),
        (mask:$f0;name:'Coin B';number:15;dip:((dip_val:$20;dip_name:'4C 1C'),(dip_val:$50;dip_name:'3C 1C'),(dip_val:$80;dip_name:'2C 1C'),(dip_val:$40;dip_name:'3C 2C'),(dip_val:$10;dip_name:'4C 3C'),(dip_val:$f0;dip_name:'1C 1C'),(dip_val:$30;dip_name:'3C 4C'),(dip_val:$70;dip_name:'2C 3C'),(dip_val:$e0;dip_name:'1C 2C'),(dip_val:$60;dip_name:'2C 5C'),(dip_val:$d0;dip_name:'1C 3C'),(dip_val:$c0;dip_name:'1C 4C'),(dip_val:$b0;dip_name:'1C 5C'),(dip_val:$a0;dip_name:'1C 6C'),(dip_val:$90;dip_name:'1C 7C'),())),());
        yiear_dip_b:array [0..5] of def_dip=(
        (mask:$3;name:'Lives';number:4;dip:((dip_val:$3;dip_name:'1'),(dip_val:$2;dip_name:'2'),(dip_val:$1;dip_name:'3'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$4;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Bonus Life';number:2;dip:((dip_val:$8;dip_name:'30K 80K'),(dip_val:$0;dip_name:'40K 90K'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Difficulty';number:4;dip:((dip_val:$30;dip_name:'Easy'),(dip_val:$10;dip_name:'Normal'),(dip_val:$20;dip_name:'Difficult'),(dip_val:$0;dip_name:'Very Difficult'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Demo Sounds';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        yiear_dip_c:array [0..2] of def_dip=(
        (mask:$1;name:'Flip Screen';number:2;dip:((dip_val:$1;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2;name:'Upright Controls';number:2;dip:((dip_val:$2;dip_name:'Single'),(dip_val:$0;dip_name:'Dual'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 pedir_irq,pedir_nmi:boolean;
 sound_latch:byte;

procedure Cargar_yiear;
begin
llamadas_maquina.iniciar:=iniciar_yiear;
llamadas_maquina.bucle_general:=yiear_principal;
llamadas_maquina.cerrar:=cerrar_yiear;
llamadas_maquina.reset:=reset_yiear;
llamadas_maquina.fps_max:=60.58;
llamadas_maquina.save_qsnap:=yiear_qsave;
llamadas_maquina.load_qsnap:=yiear_qload;
end;

function iniciar_yiear:boolean;
var
      colores:tpaleta;
      f,ctemp1,ctemp2,ctemp3:byte;
      memoria_temp:array[0..$ffff] of byte;
const
    pc_x:array[0..7] of dword=(0, 1, 2, 3, 8*8+0, 8*8+1, 8*8+2, 8*8+3);
    pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
    ps_x:array[0..15] of dword=(0*8*8+0, 0*8*8+1, 0*8*8+2, 0*8*8+3, 1*8*8+0, 1*8*8+1, 1*8*8+2, 1*8*8+3,
	  2*8*8+0, 2*8*8+1, 2*8*8+2, 2*8*8+3, 3*8*8+0, 3*8*8+1, 3*8*8+2, 3*8*8+3);
    ps_y:array[0..15] of dword=(0*8,  1*8,  2*8,  3*8,  4*8,  5*8,  6*8,  7*8,
	  32*8, 33*8, 34*8, 35*8, 36*8, 37*8, 38*8, 39*8);
begin
iniciar_yiear:=false;
iniciar_audio(false);
//Pantallas:  principal+char y sprites
screen_init(1,256,256);
screen_init(2,256,256,false,true);
screen_mod_sprites(2,256,256,$ff,$ff);
iniciar_video(256,224);
//Main CPU
main_m6809:=cpu_m6809.Create(1536000,$100);
main_m6809.change_ram_calls(yiear_getbyte,yiear_putbyte);
main_m6809.init_sound(yiear_sound_update);
//Sound Chip
sn_76496_0:=sn76496_chip.Create(1536000);
//cargar rom sonido
vlm5030_0:=vlm5030_chip.Create(3579545,$2000,2);
if not(cargar_roms(vlm5030_0.get_rom_addr,@yiear_vlm,'yiear.zip')) then exit;
//NMI sonido
init_timer(main_m6809.numero_cpu,1536000/480,yiear_snd_nmi,true);
//cargar roms
if not(cargar_roms(@memoria[0],@yiear_rom[0],'yiear.zip',0)) then exit;
//convertir chars
if not(cargar_roms(@memoria_temp[0],@yiear_char[0],'yiear.zip',0)) then exit;
init_gfx(0,8,8,512);
gfx_set_desc_data(4,0,16*8,4,0,$2000*8+4,$2000*8+0);
convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,false);
//sprites
if not(cargar_roms(@memoria_temp[0],@yiear_sprites[0],'yiear.zip',0)) then exit;
init_gfx(1,16,16,512);
gfx[1].trans[0]:=true;
gfx_set_desc_data(4,0,64*8,4,0,$8000*8+4,$8000*8+0);
convert_gfx(1,0,@memoria_temp[0],@ps_x[0],@ps_y[0],false,false);
//paleta
if not(cargar_roms(@memoria_temp[0],@yiear_pal,'yiear.zip')) then exit;
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
marcade.dswa_val:=@yiear_dip_a;
marcade.dswb_val:=@yiear_dip_b;
marcade.dswc_val:=@yiear_dip_c;
//final
reset_yiear;
iniciar_yiear:=true;
end;

procedure cerrar_yiear;
begin
main_m6809.Free;
sn_76496_0.Free;
vlm5030_0.Free;
close_audio;
close_video;
end;

procedure reset_yiear;
begin
 main_m6809.reset;
 sn_76496_0.reset;
 vlm5030_0.reset;
 reset_audio;
 marcade.in0:=$FF;
 marcade.in1:=$FF;
 marcade.in2:=$FF;
 pedir_irq:=false;
 pedir_nmi:=false;
 sound_latch:=0;
end;

procedure update_video_yiear;inline;
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
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  //P2
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  //SYS
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
end;
end;

procedure yiear_principal;
var
  frame:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame:=main_m6809.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
    main_m6809.run(frame);
    frame:=frame+main_m6809.tframes-main_m6809.contador;
    if f=239 then begin
      if pedir_irq then main_m6809.pedir_irq:=HOLD_LINE;
      update_video_yiear;
    end;
  end;
  eventos_yiear;
  video_sync;
end;
end;

function yiear_getbyte(direccion:word):byte;
begin
case direccion of
  $0:yiear_getbyte:=vlm5030_0.get_bsy;
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
if direccion>$7fff then exit;
memoria[direccion]:=valor;
case direccion of
  $4000:begin
          pedir_irq:=(valor and $4)<>0;
          pedir_nmi:=(valor and $2)<>0;
          main_screen.flip_main_screen:=(valor and $1)<>0;
        end;
  $4800:sound_latch:=valor;
  $4900:sn_76496_0.Write(sound_latch);
  $4a00:begin
           vlm5030_0.set_st((valor shr 1) and 1);
	         vlm5030_0.set_rst((valor shr 2) and 1);
        end;
  $4b00:vlm5030_0.data_w(valor);
  $5800..$5fff:gfx[0].buffer[(direccion and $7ff) shr 1]:=true;
end;
end;

procedure yiear_snd_nmi;
begin
  if pedir_nmi then main_m6809.pedir_nmi:=PULSE_LINE;
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
size:=main_m6809.save_snapshot(data);
savedata_qsnapshot(data,size);
//SND
size:=sn_76496_0.save_snapshot(data);
savedata_qsnapshot(data,size);
size:=vlm5030_0.save_snapshot(data);
savedata_qsnapshot(data,size);
//MEM
savedata_com_qsnapshot(@memoria[$0],$8000);
//MISC
buffer[0]:=byte(pedir_irq);
buffer[1]:=byte(pedir_nmi);
buffer[2]:=sound_latch;
savedata_qsnapshot(@buffer[0],3);
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
main_m6809.load_snapshot(data);
//SND
loaddata_qsnapshot(data);
sn_76496_0.load_snapshot(data);
loaddata_qsnapshot(data);
vlm5030_0.save_snapshot(data);
//MEM
loaddata_qsnapshot(@memoria[0]);
//MISC
loaddata_qsnapshot(@buffer[0]);
pedir_irq:=buffer[0]<>0;
pedir_nmi:=buffer[1]<>0;
sound_latch:=buffer[2];
freemem(data);
close_qsnapshot;
//END
fillchar(gfx[0].buffer[0],$400,1);
end;

end.
