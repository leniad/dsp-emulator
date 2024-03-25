unit mrdo_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,sn_76496,gfx_engine,rom_engine,
     pal_engine,sound_engine;

function iniciar_mrdo:boolean;

implementation
const
        mrdo_rom:array[0..3] of tipo_roms=(
        (n:'a4-01.bin';l:$2000;p:0;crc:$03dcfba2),(n:'c4-02.bin';l:$2000;p:$2000;crc:$0ecdd39c),
        (n:'e4-03.bin';l:$2000;p:$4000;crc:$358f5dc2),(n:'f4-04.bin';l:$2000;p:$6000;crc:$f4190cfc));
        mrdo_pal:array[0..2] of tipo_roms=(
        (n:'u02--2.bin';l:$20;p:0;crc:$238a65d7),(n:'t02--3.bin';l:$20;p:$20;crc:$ae263dc0),
        (n:'f10--1.bin';l:$20;p:$40;crc:$16ee4ca2));
        mrdo_char1:array[0..1] of tipo_roms=(
        (n:'s8-09.bin';l:$1000;p:0;crc:$aa80c5b6),(n:'u8-10.bin';l:$1000;p:$1000;crc:$d20ec85b));
        mrdo_char2:array[0..1] of tipo_roms=(
        (n:'r8-08.bin';l:$1000;p:0;crc:$dbdc9ffa),(n:'n8-07.bin';l:$1000;p:$1000;crc:$4b9973db));
        mrdo_sprites:array[0..1] of tipo_roms=(
        (n:'h5-05.bin';l:$1000;p:0;crc:$e1218cc5),(n:'k5-06.bin';l:$1000;p:$1000;crc:$b1f68b04));
        //Dip
        mrdo_dip_a:array [0..6] of def_dip=(
        (mask:$3;name:'Difficulty';number:4;dip:((dip_val:$3;dip_name:'Easy'),(dip_val:$2;dip_name:'Medium'),(dip_val:$1;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Rack Test (Cheat)';number:2;dip:((dip_val:$4;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Special';number:2;dip:((dip_val:$8;dip_name:'Easy'),(dip_val:$0;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Extra';number:2;dip:((dip_val:$10;dip_name:'Easy'),(dip_val:$0;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$20;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Lives';number:4;dip:((dip_val:$0;dip_name:'2'),(dip_val:$c0;dip_name:'3'),(dip_val:$80;dip_name:'4'),(dip_val:$40;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),());
        mrdo_dip_b:array [0..2] of def_dip=(
        (mask:$f0;name:'Coin A';number:11;dip:((dip_val:$60;dip_name:'4C 1C'),(dip_val:$80;dip_name:'3C 1C'),(dip_val:$a0;dip_name:'2C 1C'),(dip_val:$70;dip_name:'3C 2C'),(dip_val:$f0;dip_name:'1C 1C'),(dip_val:$90;dip_name:'2C 3C'),(dip_val:$e0;dip_name:'1C 2C'),(dip_val:$d0;dip_name:'1C 3C'),(dip_val:$c0;dip_name:'1C 4C'),(dip_val:$b0;dip_name:'1C 5C'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),())),
        (mask:$0f;name:'Coin B';number:11;dip:((dip_val:$06;dip_name:'4C 1C'),(dip_val:$08;dip_name:'3C 1C'),(dip_val:$0a;dip_name:'2C 1C'),(dip_val:$07;dip_name:'3C 2C'),(dip_val:$0f;dip_name:'1C 1C'),(dip_val:$09;dip_name:'2C 3C'),(dip_val:$0e;dip_name:'1C 2C'),(dip_val:$0d;dip_name:'1C 3C'),(dip_val:$0c;dip_name:'1C 4C'),(dip_val:$0b;dip_name:'1C 5C'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),())),());

var
  scroll_x,scroll_y,prot:byte;

procedure update_video_mrdo;
var
  f,color,nchar:word;
  x,y,atrib:byte;
begin
for f:=$0 to $3ff do begin
  x:=f div 32;
  y:=31-(f mod 32);
  if gfx[1].buffer[f] then begin
    atrib:=memoria[$8000+f];
    nchar:=memoria[$8400+f]+(atrib and $80) shl 1;
    color:=(atrib and $3f) shl 2;
    if (atrib and $40)<>0 then begin
      put_gfx(x*8,y*8,nchar,color,1,1);
      put_gfx_block_trans(x*8,y*8,4,8,8);
    end else begin
      put_gfx_block(x*8,y*8,1,8,8,0);
      put_gfx_trans(x*8,y*8,nchar,color,4,1);
    end;
    gfx[1].buffer[f]:=false;
    end;
 atrib:=memoria[$8800+f];
 if ((gfx[0].buffer[f]) or ((atrib and $40)<>0)) then begin
    nchar:=memoria[$8c00+f]+(atrib and $80) shl 1;
    color:=(atrib and $3f) shl 2;
    if (atrib and $40)<>0 then begin
      put_gfx(x*8,y*8,nchar,color,2,0);
      put_gfx_block_trans(x*8,y*8,5,8,8);
    end else begin
      put_gfx_block_trans(x*8,y*8,2,8,8);
      put_gfx_trans(x*8,y*8,nchar,color,5,0);
    end;
    gfx[0].buffer[f]:=false;
 end;
end;
//Es MUY IMPORTANTE este orden para poder pintar correctamente la pantalla!!!
scroll_x_y(1,3,scroll_x,scroll_y);
actualiza_trozo(0,0,256,256,2,0,0,256,256,3);
scroll_x_y(4,3,scroll_x,scroll_y);
actualiza_trozo(0,0,256,256,5,0,0,256,256,3);
for f:=$3f downto 0 do begin
  x:=memoria[(f*4)+$9001];
  if (x<>0) then begin
    nchar:=memoria[(f*4)+$9000] and $7f;
    atrib:=memoria[(f*4)+$9002];
    color:=(atrib and $0f) shl 2;
    y:=240-memoria[(f*4)+$9003];
    put_gfx_sprite(nchar,color,(atrib and $20)<>0,(atrib and $10)<>0,2);
    actualiza_gfx_sprite(256-x,y,3,2);
  end;
end;
actualiza_trozo_final(32,8,192,240,3);
end;

procedure eventos_mrdo;
begin
if event.arcade then begin
  //p1
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  //p2
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.coin[0] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  if arcade_input.coin[1] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
end;
end;

procedure mrdo_principal;
var
  frame_m:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=z80_0.tframes;
while EmuStatus=EsRunning do begin
  for f:=0 to 261 do begin
      z80_0.run(frame_m);
      frame_m:=frame_m+z80_0.tframes-z80_0.contador;
      if f=223 then begin
          z80_0.change_irq(HOLD_LINE);
          update_video_mrdo;
      end;
  end;
  eventos_mrdo;
  video_sync;
end;
end;

function mrdo_getbyte(direccion:word):byte;
var
  z80_0_reg:npreg_z80;
begin
case direccion of
  0..$8fff,$e000..$efff:mrdo_getbyte:=memoria[direccion];
  $9803:begin
          z80_0_reg:=z80_0.get_internal_r;
          mrdo_getbyte:=memoria[z80_0_reg.hl.w];
        end;
  $a000:mrdo_getbyte:=marcade.in0;
  $a001:mrdo_getbyte:=marcade.in1;
  $a002:mrdo_getbyte:=marcade.dswa;
  $a003:mrdo_getbyte:=marcade.dswb;
end;
end;

procedure mrdo_putbyte(direccion:word;valor:byte);
begin
case direccion of
   0..$7fff:;
   $8000..$87ff:if memoria[direccion]<>valor then begin
                     gfx[1].buffer[direccion and $3ff]:=true;
                     memoria[direccion]:=valor;
                end;
   $8800..$8fff:if memoria[direccion]<>valor then begin
                     gfx[0].buffer[direccion and $3ff]:=true;
                     memoria[direccion]:=valor;
                end;
   $9000..$90ff,$e000..$efff:memoria[direccion]:=valor;
   $9800:main_screen.flip_main_screen:=(valor and 1)<>0;
   $9801:sn_76496_0.Write(valor);
   $9802:sn_76496_1.Write(valor);
   $f000..$f7ff:scroll_y:=valor;
   $f800..$ffff:scroll_x:=valor;
end;
end;

procedure mrdo_update_sound;
begin
  sn_76496_0.Update;
  sn_76496_1.Update;
end;

//Main
procedure reset_mrdo;
begin
 z80_0.reset;
 sn_76496_0.reset;
 sn_76496_1.reset;
 reset_audio;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 scroll_x:=0;
 scroll_y:=0;
 prot:=$ff;
end;

function iniciar_mrdo:boolean;
var
  memoria_temp:array[0..$1fff] of byte;
const
  pc_x:array[0..7] of dword=(7, 6, 5, 4, 3, 2, 1, 0);
  pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
  ps_x:array[0..15] of dword=(3, 2, 1, 0, 8+3, 8+2, 8+1, 8+0,
      16+3, 16+2, 16+1, 16+0, 24+3, 24+2, 24+1, 24+0);
  ps_y:array[0..15] of dword=(0*16, 2*16, 4*16, 6*16, 8*16, 10*16, 12*16, 14*16,
			16*16, 18*16, 20*16, 22*16, 24*16, 26*16, 28*16, 30*16);
procedure calc_paleta;
var
  weight,pot:array[0..15] of single;
  par:single;
  f,a1,a2,bits0,bits1:byte;
  colores:tpaleta;
const
  R1=150;
	R2=120;
	R3=100;
	R4=75;
	PULL=220;
	POTADJUST=0.7;	// diode voltage drop
begin
	for f:=$f downto 0 do begin
		par:=0;
		if (f and 1)<>0 then par:=par+(1.0/R1);
		if (f and 2)<>0 then par:=par+(1.0/R2);
		if (f and 4)<>0 then par:=par+(1.0/R3);
		if (f and 8)<>0 then par:=par+(1.0/R4);
		if (par<>0) then begin
			par:=1/par;
			pot[f]:=PULL/(PULL+par)-POTADJUST;
		end	else pot[f]:=0;
		weight[f]:=$ff*pot[f]/pot[$f];
    if weight[f]<0 then weight[f]:=0;
	end;
  for f:=0 to $ff do begin
		a1:=((f shr 3) and $1c)+(f and $03)+$20;
		a2:=((f shr 0) and $1c)+(f and $03);
		bits0:=(memoria_temp[a1] shr 0) and $03;
		bits1:=(memoria_temp[a2] shr 0) and $03;
		colores[f].r:=trunc(weight[bits0+(bits1 shl 2)]);
    bits0:=(memoria_temp[a1] shr 2) and $03;
		bits1:=(memoria_temp[a2] shr 2) and $03;
		colores[f].g:=trunc(weight[bits0 + (bits1 shl 2)]);
    bits0:=(memoria_temp[a1] shr 4) and $03;
		bits1:=(memoria_temp[a2] shr 4) and $03;
		colores[f].b:=trunc(weight[bits0+(bits1 shl 2)]);
  end;
  set_pal(colores,$100);
  //CLUT sprites
  for f:=0 to $3f do begin
		bits0:=memoria_temp[($40+(f and $1f))];
		if (f and $20)<>0 then bits0:=bits0 shr 4		// high 4 bits are for sprite color n + 8
  		else bits0:=bits0 and $0f;	// low 4 bits are for sprite color n
    gfx[2].colores[f]:=bits0+((bits0 and $0c) shl 3);
	end;
end;
begin
llamadas_maquina.bucle_general:=mrdo_principal;
llamadas_maquina.reset:=reset_mrdo;
llamadas_maquina.fps_max:=59.94323742;
iniciar_mrdo:=false;
iniciar_audio(false);
screen_init(1,256,256,true);
screen_mod_scroll(1,256,256,255,256,256,255);
screen_init(2,256,256,true);
screen_init(3,256,256,false,true);
screen_init(4,256,256,true);
screen_mod_scroll(4,256,256,255,256,256,255);
screen_init(5,256,256,true);
iniciar_video(192,240);
//Main CPU
z80_0:=cpu_z80.create(4100000,262);
z80_0.change_ram_calls(mrdo_getbyte,mrdo_putbyte);
z80_0.init_sound(mrdo_update_sound);
//Sound Chips
sn_76496_0:=sn76496_chip.Create(4100000);
sn_76496_1:=sn76496_chip.Create(4100000);
//cargar roms
if not(roms_load(@memoria,mrdo_rom)) then exit;
//convertir chars fg
if not(roms_load(@memoria_temp,mrdo_char1)) then exit;
init_gfx(0,8,8,512);
gfx[0].trans[0]:=true;
gfx_set_desc_data(2,0,8*8,0,512*8*8);
convert_gfx(0,0,@memoria_temp,@pc_x,@pc_y,false,true);
//convertir chars bg
if not(roms_load(@memoria_temp,mrdo_char2)) then exit;
init_gfx(1,8,8,512);
gfx[1].trans[0]:=true;
gfx_set_desc_data(2,0,8*8,0,512*8*8);
convert_gfx(1,0,@memoria_temp,@pc_x,@pc_y,false,true);
//convertir sprites
if not(roms_load(@memoria_temp,mrdo_sprites)) then exit;
init_gfx(2,16,16,128);
gfx[2].trans[0]:=true;
gfx_set_desc_data(2,0,64*8,4,0);
convert_gfx(2,0,@memoria_temp,@ps_x,@ps_y,false,true);
//poner la paleta
if not(roms_load(@memoria_temp,mrdo_pal)) then exit;
calc_paleta;
//dip
marcade.dswa:=$df;
marcade.dswb:=$ff;
marcade.dswa_val:=@mrdo_dip_a;
marcade.dswb_val:=@mrdo_dip_b;
//final
reset_mrdo;
iniciar_mrdo:=true;
end;

end.
