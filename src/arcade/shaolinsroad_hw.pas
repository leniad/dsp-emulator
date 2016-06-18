unit shaolinsroad_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6809,main_engine,controls_engine,sn_76496,gfx_engine,rom_engine,
     pal_engine,sound_engine,qsnapshot;

procedure cargar_shaolin;

implementation
const
        shaolin_rom:array[0..3] of tipo_roms=(
        (n:'477-l03.d9';l:$2000;p:$6000;crc:$2598dfdd),(n:'477-l04.d10';l:$4000;p:$8000;crc:$0cf0351a),
        (n:'477-l05.d11';l:$4000;p:$c000;crc:$654037f8),());
        shaolin_char:array[0..2] of tipo_roms=(
        (n:'shaolins.a10';l:$2000;p:0;crc:$ff18a7ed),(n:'shaolins.a11';l:$2000;p:$2000;crc:$5f53ae61),());
        shaolin_sprites:array[0..2] of tipo_roms=(
        (n:'477-k02.h15';l:$4000;p:0;crc:$b94e645b),(n:'477-k01.h14';l:$4000;p:$4000;crc:$61bbf797),());
        shaolin_pal:array[0..5] of tipo_roms=(
        (n:'477j10.a12';l:$100;p:$0;crc:$b09db4b4),(n:'477j11.a13';l:$100;p:$100;crc:$270a2bf3),
        (n:'477j12.a14';l:$100;p:$200;crc:$83e95ea8),(n:'477j09.b8';l:$100;p:$300;crc:$aa900724),
        (n:'477j08.f16';l:$100;p:$400;crc:$80009cf5),());
        //Dip
        shaolin_dip_a:array [0..5] of def_dip=(
        (mask:$3;name:'Lives';number:4;dip:((dip_val:$3;dip_name:'2'),(dip_val:$2;dip_name:'3'),(dip_val:$1;dip_name:'5'),(dip_val:$0;dip_name:'7'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$4;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$18;name:'Bonus Life';number:4;dip:((dip_val:$18;dip_name:'30K 70K+'),(dip_val:$10;dip_name:'40K 80K+'),(dip_val:$8;dip_name:'40K'),(dip_val:$0;dip_name:'50K'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$60;name:'Difficulty';number:4;dip:((dip_val:$60;dip_name:'Easy'),(dip_val:$40;dip_name:'Medium'),(dip_val:$20;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Demo Sounds';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        shaolin_dip_b:array [0..2] of def_dip=(
        (mask:$1;name:'Flip Screen';number:2;dip:((dip_val:$1;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2;name:'Upright Controls';number:2;dip:((dip_val:$2;dip_name:'Single'),(dip_val:$0;dip_name:'Dual'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        shaolin_dip_c:array [0..2] of def_dip=(
        (mask:$0f;name:'Coin A';number:16;dip:((dip_val:$2;dip_name:'4C 1C'),(dip_val:$5;dip_name:'3C 1C'),(dip_val:$8;dip_name:'2C 1C'),(dip_val:$4;dip_name:'3C 2C'),(dip_val:$1;dip_name:'4C 3C'),(dip_val:$f;dip_name:'1C 1C'),(dip_val:$3;dip_name:'3C 4C'),(dip_val:$7;dip_name:'2C 3C'),(dip_val:$e;dip_name:'1C 2C'),(dip_val:$6;dip_name:'2C 5C'),(dip_val:$d;dip_name:'1C 3C'),(dip_val:$c;dip_name:'1C 4C'),(dip_val:$b;dip_name:'1C 5C'),(dip_val:$a;dip_name:'1C 6C'),(dip_val:$9;dip_name:'1C 7C'),(dip_val:$0;dip_name:'Free Play'))),
        (mask:$f0;name:'Coin B';number:15;dip:((dip_val:$20;dip_name:'4C 1C'),(dip_val:$50;dip_name:'3C 1C'),(dip_val:$80;dip_name:'2C 1C'),(dip_val:$40;dip_name:'3C 2C'),(dip_val:$10;dip_name:'4C 3C'),(dip_val:$f0;dip_name:'1C 1C'),(dip_val:$30;dip_name:'3C 4C'),(dip_val:$70;dip_name:'2C 3C'),(dip_val:$e0;dip_name:'1C 2C'),(dip_val:$60;dip_name:'2C 5C'),(dip_val:$d0;dip_name:'1C 3C'),(dip_val:$c0;dip_name:'1C 4C'),(dip_val:$b0;dip_name:'1C 5C'),(dip_val:$a0;dip_name:'1C 6C'),(dip_val:$90;dip_name:'1C 7C'),())),());

var
 banco_pal,scroll:byte;
 pedir_nmi:boolean;

procedure update_video_shaolin;inline;
var
  x,y,f:word;
  color,nchar:word;
  atrib:byte;
begin
for f:=0 to $3ff do begin
    if gfx[0].buffer[f] then begin
      y:=f mod 32;
      x:=31-(f div 32);
      atrib:=memoria[$3800+f];
      color:=((atrib and $f)+($10*banco_pal)) shl 4;
      nchar:=memoria[$3c00+f]+((atrib and $40) shl 2);
      put_gfx_flip(x*8,y*8,nchar,color,1,0,(atrib and $20)<>0,(atrib and $10)<>0);
      gfx[0].buffer[f]:=false;
    end;
end;
scroll__x(1,2,scroll);
actualiza_trozo(0,0,256,32,1,0,0,256,32,2);
for f:=$17 downto 0 do if ((memoria[$3100+(f*32)]<>0) and (memoria[$3106+(f*32)]<>0)) then begin
  atrib:=memoria[$3109+(f*32)];
  color:=((atrib and $f)+($10*banco_pal)) shl 4;
  x:=memoria[$3104+(f*32)];
  y:=240-memoria[$3106+(f*32)];
  nchar:=memoria[$3108+(f*32)];
  put_gfx_sprite(nchar,color,(atrib and $80)<>0,(atrib and $40)=0,1);
  actualiza_gfx_sprite(x-8,y,2,1);
end;
actualiza_trozo_final(16,0,224,256,2);
end;

procedure eventos_shaolin;
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

procedure shaolin_principal;
var
  f:byte;
  frame:single;
begin
init_controls(false,false,false,true);
frame:=main_m6809.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
    main_m6809.run(trunc(frame));
    frame:=frame+main_m6809.tframes-main_m6809.contador;
    if f=239 then begin
      main_m6809.change_irq(HOLD_LINE);
      update_video_shaolin;
    end else begin
      if (((f and $1f)=0) and pedir_nmi) then main_m6809.change_nmi(PULSE_LINE);
    end;
  end;
  eventos_shaolin;
  video_sync;
end;
end;

function shaolin_getbyte(direccion:word):byte;
begin
case direccion of
  $2800..$2bff,$3000..$33ff,$3800..$ffff:shaolin_getbyte:=memoria[direccion];
  $500:shaolin_getbyte:=marcade.dswa;
  $600:shaolin_getbyte:=marcade.dswb;
  $700:shaolin_getbyte:=marcade.in0;
  $701:shaolin_getbyte:=marcade.in1;
  $702:shaolin_getbyte:=marcade.in2;
  $703:shaolin_getbyte:=marcade.dswc;
end;
end;

procedure shaolin_putbyte(direccion:word;valor:byte);
begin
if direccion>$3fff then exit;
memoria[direccion]:=valor;
case direccion of
  $0:begin
        main_screen.flip_main_screen:=(valor and 1)<>0;
        pedir_nmi:=(valor and $2)<>0;
     end;
  $0300:sn_76496_0.Write(valor);
  $0400:sn_76496_1.Write(valor);
  $1800:banco_pal:=valor and $7;
  $2000:scroll:=not(valor);
  $3800..$3fff:gfx[0].buffer[direccion and $3ff]:=true;
end;
end;

procedure shaolin_sound;
begin
  sn_76496_0.Update;
  sn_76496_1.Update;
end;

procedure shaolin_qsave(nombre:string);
var
  data:pbyte;
  buffer:array[0..2] of byte;
  size:word;
begin
open_qsnapshot_save('shaolinsroad'+nombre);
getmem(data,180);
//CPU
size:=main_m6809.save_snapshot(data);
savedata_qsnapshot(data,size);
//SND
size:=sn_76496_0.save_snapshot(data);
savedata_qsnapshot(data,size);
size:=sn_76496_1.save_snapshot(data);
savedata_qsnapshot(data,size);
//MEM
savedata_com_qsnapshot(@memoria[$0],$4000);
//MISC
buffer[0]:=banco_pal;
buffer[1]:=scroll;
buffer[2]:=byte(pedir_nmi);
savedata_qsnapshot(@buffer[0],3);
freemem(data);
close_qsnapshot;
end;

procedure shaolin_qload(nombre:string);
var
  data:pbyte;
  buffer:array[0..2] of byte;
begin
if not(open_qsnapshot_load('shaolinsroad'+nombre)) then exit;
getmem(data,180);
//CPU
loaddata_qsnapshot(data);
main_m6809.load_snapshot(data);
//SND
loaddata_qsnapshot(data);
sn_76496_0.load_snapshot(data);
loaddata_qsnapshot(data);
sn_76496_1.load_snapshot(data);
//MEM
loaddata_qsnapshot(@memoria[0]);
//MISC
loaddata_qsnapshot(@buffer[0]);
banco_pal:=buffer[0];
scroll:=buffer[1];
byte(pedir_nmi):=buffer[2];
freemem(data);
close_qsnapshot;
//END
fillchar(gfx[0].buffer[0],$400,1);
end;

//Main
procedure reset_shaolin;
begin
 main_m6809.reset;
 sn_76496_0.reset;
 sn_76496_1.reset;
 reset_audio;
 banco_pal:=0;
 marcade.in0:=$FF;
 marcade.in1:=$FF;
 marcade.in2:=$FF;
 pedir_nmi:=false;
end;

function iniciar_shaolin:boolean;
var
      colores:tpaleta;
      f:word;
      ctemp1,ctemp2,ctemp3:byte;
      memoria_temp:array[0..$7fff] of byte;
const
    pc_x:array[0..7] of dword=(0, 1, 2, 3, 8*8+0, 8*8+1, 8*8+2, 8*8+3);
    pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
    ps_x:array[0..15] of dword=(0, 1, 2, 3, 8*8+0, 8*8+1, 8*8+2, 8*8+3,
			16*8+0, 16*8+1, 16*8+2, 16*8+3, 24*8+0, 24*8+1, 24*8+2, 24*8+3);
    ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			32*8, 33*8, 34*8, 35*8, 36*8, 37*8, 38*8, 39*8);
begin
iniciar_shaolin:=false;
iniciar_audio(false);
screen_init(1,256,256);
screen_mod_scroll(1,256,256,255,0,0,0);
screen_init(2,256,256,false,true);
iniciar_video(224,256);
//Main CPU
main_m6809:=cpu_m6809.Create(1536000,$100);
main_m6809.change_ram_calls(shaolin_getbyte,shaolin_putbyte);
main_m6809.init_sound(shaolin_sound);
//Sound Chip
sn_76496_0:=sn76496_chip.Create(1536000);
sn_76496_1:=sn76496_chip.Create(3072000);
//cargar roms
if not(cargar_roms(@memoria[0],@shaolin_rom[0],'shaolins.zip',0)) then exit;
//convertir chars
if not(cargar_roms(@memoria_temp[0],@shaolin_char[0],'shaolins.zip',0)) then exit;
init_gfx(0,8,8,512);
gfx_set_desc_data(4,0,16*8,512*16*8+4,512*16*8+0,4,0);
convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],true,false);
//sprites
if not(cargar_roms(@memoria_temp[0],@shaolin_sprites[0],'shaolins.zip',0)) then exit;
init_gfx(1,16,16,256);
gfx[1].trans[0]:=true;
gfx_set_desc_data(4,0,64*8,256*64*8+4,256*64*8+0,4,0);
convert_gfx(1,0,@memoria_temp[0],@ps_x[0],@ps_y[0],true,false);
//paleta
if not(cargar_roms(@memoria_temp[0],@shaolin_pal[0],'shaolins.zip',0)) then exit;
for f:=0 to 255 do begin
  colores[f].r:=((memoria_temp[f] and $f) shl 4) or (memoria_temp[f] and $f);
  colores[f].g:=((memoria_temp[f+$100] and $f) shl 4) or (memoria_temp[f+$100] and $f);
  colores[f].b:=((memoria_temp[f+$200] and $f) shl 4) or (memoria_temp[f+$200] and $f);
end;
set_pal(colores,256);
//tabla_colores char & sprites
ctemp1:=0;
for ctemp2:=0 to 255 do begin
	for ctemp3:=0 to 7 do begin
		gfx[0].colores[ctemp2+ctemp3*256]:=(memoria_temp[ctemp1+$300] and $f)+32*ctemp3+16;
    gfx[1].colores[ctemp2+ctemp3*256]:=(memoria_temp[ctemp1+$400] and $f)+32*ctemp3;
  end;
	ctemp1:=ctemp1+1;
end;
//DIP
marcade.dswa:=$5a;
marcade.dswb:=$0f;
marcade.dswc:=$ff;
marcade.dswa_val:=@shaolin_dip_a;
marcade.dswb_val:=@shaolin_dip_b;
marcade.dswc_val:=@shaolin_dip_c;
//final
reset_shaolin;
iniciar_shaolin:=true;
end;

procedure Cargar_shaolin;
begin
llamadas_maquina.iniciar:=iniciar_shaolin;
llamadas_maquina.bucle_general:=shaolin_principal;
llamadas_maquina.reset:=reset_shaolin;
llamadas_maquina.save_qsnap:=shaolin_qsave;
llamadas_maquina.load_qsnap:=shaolin_qload;
end;

end.
