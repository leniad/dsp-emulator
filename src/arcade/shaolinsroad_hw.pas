unit shaolinsroad_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6809,main_engine,controls_engine,sn_76496,gfx_engine,rom_engine,
     pal_engine,sound_engine,qsnapshot;

function iniciar_shaolin:boolean;

implementation
const
        shaolin_rom:array[0..2] of tipo_roms=(
        (n:'477-l03.d9';l:$2000;p:$6000;crc:$2598dfdd),(n:'477-l04.d10';l:$4000;p:$8000;crc:$0cf0351a),
        (n:'477-l05.d11';l:$4000;p:$c000;crc:$654037f8));
        shaolin_char:array[0..1] of tipo_roms=(
        (n:'shaolins.a10';l:$2000;p:0;crc:$ff18a7ed),(n:'shaolins.a11';l:$2000;p:$2000;crc:$5f53ae61));
        shaolin_sprites:array[0..1] of tipo_roms=(
        (n:'477-k02.h15';l:$4000;p:0;crc:$b94e645b),(n:'477-k01.h14';l:$4000;p:$4000;crc:$61bbf797));
        shaolin_pal:array[0..4] of tipo_roms=(
        (n:'477j10.a12';l:$100;p:0;crc:$b09db4b4),(n:'477j11.a13';l:$100;p:$100;crc:$270a2bf3),
        (n:'477j12.a14';l:$100;p:$200;crc:$83e95ea8),(n:'477j09.b8';l:$100;p:$300;crc:$aa900724),
        (n:'477j08.f16';l:$100;p:$400;crc:$80009cf5));
        //Dip
        shaolin_dip_a:array [0..5] of def_dip2=(
        (mask:3;name:'Lives';number:4;val4:(3,2,1,0);name4:('2','3','5','7')),
        (mask:4;name:'Cabinet';number:2;val2:(0,4);name2:('Upright','Cocktail')),
        (mask:$18;name:'Bonus Life';number:4;val4:($18,$10,8,0);name4:('30K 70K+','40K 80K+','40K','50K')),
        (mask:$60;name:'Difficulty';number:4;val4:($60,$40,$20,0);name4:('Easy','Medium','Hard','Hardest')),
        (mask:$80;name:'Demo Sounds';number:2;val2:($80,0);name2:('Off','On')),());
        shaolin_dip_b:array [0..2] of def_dip2=(
        (mask:1;name:'Flip Screen';number:2;val2:(1,0);name2:('Off','On')),
        (mask:2;name:'Upright Controls';number:2;val2:(2,0);name2:('Single','Dual')),());
        shaolin_dip_c:array [0..2] of def_dip2=(
        (mask:$f;name:'Coin A';number:16;val16:(2,5,8,4,1,$f,3,7,$e,6,$d,$c,$b,$a,9,0);name16:('4C 1C','3C 1C','2C 1C','3C 2C','4C 3C','1C 1C','3C 4C','2C 3C','1C 2C','2C 5C','1C 3C','1C 4C','1C 5C','1C 6C','1C 7C','Free Play')),
        (mask:$f0;name:'Coin B';number:16;val16:($20,$50,$80,$40,$10,$f0,$30,$70,$e0,$60,$d0,$c0,$b0,$a0,$90,0);name16:('4C 1C','3C 1C','2C 1C','3C 2C','4C 3C','1C 1C','3C 4C','2C 3C','1C 2C','2C 5C','1C 3C','1C 4C','1C 5C','1C 6C','1C 7C','Invalid')),());

var
 banco_pal,scroll:byte;
 pedir_nmi:boolean;

procedure update_video_shaolin;
var
  x,y,f,color,nchar:word;
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
for f:=$17 downto 0 do begin
  atrib:=memoria[$2800+(f*2)];
  color:=((atrib and $f)+($10*banco_pal)) shl 4;
  y:=memoria[$3000+(f*2)];
  x:=memoria[$2801+(f*2)];
  nchar:=memoria[$3001+(f*2)];
  put_gfx_sprite(nchar,color,(atrib and $80)<>0,(atrib and $40)=0,1);
  actualiza_gfx_sprite(x,y,2,1);
end;
actualiza_trozo_final(16,0,224,256,2);
end;

procedure eventos_shaolin;
begin
if event.arcade then begin
  //P1
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or 8);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  //P2
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or 1);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or 2);
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or 4);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or 8);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  //SYS
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
end;
end;

procedure shaolin_principal;
var
  f:byte;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
  for f:=0 to $ff do begin
    if f=240 then begin
      m6809_0.change_irq(HOLD_LINE);
      update_video_shaolin;
    end else begin
      if (((f and $1f)=0) and pedir_nmi) then m6809_0.change_nmi(PULSE_LINE);
    end;
    m6809_0.run(frame_main);
    frame_main:=frame_main+m6809_0.tframes-m6809_0.contador;
  end;
  eventos_shaolin;
  video_sync;
end;
end;

function shaolin_getbyte(direccion:word):byte;
begin
case direccion of
  $500:shaolin_getbyte:=marcade.dswa;
  $600:shaolin_getbyte:=marcade.dswb;
  $700:shaolin_getbyte:=marcade.in0;
  $701:shaolin_getbyte:=marcade.in1;
  $702:shaolin_getbyte:=marcade.in2;
  $703:shaolin_getbyte:=marcade.dswc;
  $2800..$2bff,$3000..$33ff,$3800..$ffff:shaolin_getbyte:=memoria[direccion];
end;
end;

procedure shaolin_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0:begin
        main_screen.flip_main_screen:=(valor and 1)<>0;
        pedir_nmi:=(valor and 2)<>0;
     end;
  $300:sn_76496_0.write(valor);
  $400:sn_76496_1.write(valor);
  $1800:banco_pal:=valor and 7;
  $2000:scroll:=not(valor);
  $2800..$2bff,$3000..$33ff:memoria[direccion]:=valor;
  $3800..$3fff:if memoria[direccion]<>valor then begin
                  gfx[0].buffer[direccion and $3ff]:=true;
                  memoria[direccion]:=valor;
               end;
  $4000..$ffff:; //ROM
end;
end;

procedure shaolin_sound;
begin
  sn_76496_0.update;
  sn_76496_1.update;
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
size:=m6809_0.save_snapshot(data);
savedata_qsnapshot(data,size);
//SND
size:=sn_76496_0.save_snapshot(data);
savedata_qsnapshot(data,size);
size:=sn_76496_1.save_snapshot(data);
savedata_qsnapshot(data,size);
//MEM
savedata_qsnapshot(@memoria,$4000);
//MISC
buffer[0]:=banco_pal;
buffer[1]:=scroll;
buffer[2]:=byte(pedir_nmi);
savedata_qsnapshot(@buffer,3);
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
m6809_0.load_snapshot(data);
//SND
loaddata_qsnapshot(data);
sn_76496_0.load_snapshot(data);
loaddata_qsnapshot(data);
sn_76496_1.load_snapshot(data);
//MEM
loaddata_qsnapshot(@memoria);
//MISC
loaddata_qsnapshot(@buffer);
banco_pal:=buffer[0];
scroll:=buffer[1];
byte(pedir_nmi):=buffer[2];
freemem(data);
close_qsnapshot;
//END
fillchar(gfx[0].buffer,$400,1);
end;

//Main
procedure reset_shaolin;
begin
 m6809_0.reset;
 frame_main:=m6809_0.tframes;
 sn_76496_0.reset;
 sn_76496_1.reset;
 reset_video;
 reset_audio;
 banco_pal:=0;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 pedir_nmi:=false;
end;

function iniciar_shaolin:boolean;
var
  colores:tpaleta;
  f:word;
  bit0,bit1,bit2,bit3:byte;
  memoria_temp:array[0..$7fff] of byte;
  rweights,gweights,bweights:array[0..3] of single;
const
    ps_x:array[0..15] of dword=(0, 1, 2, 3, 8*8+0, 8*8+1, 8*8+2, 8*8+3,
			16*8+0, 16*8+1, 16*8+2, 16*8+3, 24*8+0, 24*8+1, 24*8+2, 24*8+3);
    ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			32*8, 33*8, 34*8, 35*8, 36*8, 37*8, 38*8, 39*8);
    resistances:array[0..3] of integer=(2200,1000,470,220);
begin
llamadas_maquina.bucle_general:=shaolin_principal;
llamadas_maquina.reset:=reset_shaolin;
llamadas_maquina.save_qsnap:=shaolin_qsave;
llamadas_maquina.load_qsnap:=shaolin_qload;
iniciar_shaolin:=false;
iniciar_audio(false);
screen_init(1,256,256);
screen_mod_scroll(1,256,256,255,256,256,255);
screen_init(2,256,256,false,true);
iniciar_video(224,256);
//Main CPU
m6809_0:=cpu_m6809.Create(18432000 div 12,$100,TCPU_MC6809E);
m6809_0.change_ram_calls(shaolin_getbyte,shaolin_putbyte);
m6809_0.init_sound(shaolin_sound);
if not(roms_load(@memoria,shaolin_rom)) then exit;
//Sound Chip
sn_76496_0:=sn76496_chip.Create(18432000 div 12);
sn_76496_1:=sn76496_chip.Create(18432000 div 6);
//convertir chars
if not(roms_load(@memoria_temp,shaolin_char)) then exit;
init_gfx(0,8,8,512);
gfx_set_desc_data(4,0,16*8,512*16*8+4,512*16*8+0,4,0);
convert_gfx(0,0,@memoria_temp,@ps_x,@ps_y,true,false);
//sprites
if not(roms_load(@memoria_temp,shaolin_sprites)) then exit;
init_gfx(1,16,16,256);
gfx[1].trans[0]:=true;
gfx_set_desc_data(4,0,64*8,256*64*8+4,256*64*8+0,4,0);
convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,true,false);
//paleta
if not(roms_load(@memoria_temp,shaolin_pal)) then exit;
compute_resistor_weights(0,	255, -1.0,
			4,@resistances[0],@rweights[0],470,0,
			4,@resistances[0],@gweights[0],470,0,
			4,@resistances[0],@bweights[0],470,0);
for f:=0 to $ff do begin
		// red component
		bit0:=(memoria_temp[f] shr 0) and 1;
		bit1:=(memoria_temp[f] shr 1) and 1;
		bit2:=(memoria_temp[f] shr 2) and 1;
    bit3:=(memoria_temp[f] shr 3) and 1;
		colores[f].r:=combine_4_weights(@rweights[0],bit0,bit1,bit2,bit3);
		// green component
		bit0:=(memoria_temp[f+$100] shr 0) and 1;
		bit1:=(memoria_temp[f+$100] shr 1) and 1;
		bit2:=(memoria_temp[f+$100] shr 2) and 1;
    bit3:=(memoria_temp[f+$100] shr 3) and 1;
		colores[f].g:=combine_4_weights(@gweights[0],bit0,bit1,bit2,bit3);
		// blue component
		bit0:=(memoria_temp[f+$200] shr 0) and 1;
		bit1:=(memoria_temp[f+$200] shr 1) and 1;
		bit2:=(memoria_temp[f+$200] shr 2) and 1;
    bit3:=(memoria_temp[f+$200] shr 3) and 1;
		colores[f].b:=combine_4_weights(@gweights[0],bit0,bit1,bit2,bit3);
end;
set_pal(colores,$100);
//tabla_colores char & sprites
bit0:=0;
for bit1:=0 to 255 do begin
	for bit2:=0 to 7 do begin
		gfx[0].colores[bit1+bit2*256]:=(memoria_temp[bit0+$300] and $f)+32*bit2+16;
    gfx[1].colores[bit1+bit2*256]:=(memoria_temp[bit0+$400] and $f)+32*bit2;
  end;
	bit0:=bit0+1;
end;
//DIP
marcade.dswa:=$5a;
marcade.dswb:=$f;
marcade.dswc:=$ff;
marcade.dswa_val2:=@shaolin_dip_a;
marcade.dswb_val2:=@shaolin_dip_b;
marcade.dswc_val2:=@shaolin_dip_c;
//final
reset_shaolin;
iniciar_shaolin:=true;
end;

end.
