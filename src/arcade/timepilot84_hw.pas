unit timepilot84_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6809,nz80,sn_76496,main_engine,controls_engine,gfx_engine,
     rom_engine,pal_engine,sound_engine;

function iniciar_tp84:boolean;

implementation
const
        tp84_rom:array[0..3] of tipo_roms=(
        (n:'388_f04.7j';l:$2000;p:$8000;crc:$605f61c7),(n:'388_05.8j';l:$2000;p:$a000;crc:$4b4629a4),
        (n:'388_f06.9j';l:$2000;p:$c000;crc:$dbd5333b),(n:'388_07.10j';l:$2000;p:$e000;crc:$a45237c4));
        tp84_rom2:tipo_roms=(n:'388_f08.10d';l:$2000;p:$e000;crc:$36462ff1);
        tp84_proms:array[0..4] of tipo_roms=(
        (n:'388d14.2c';l:$100;p:0;crc:$d737eaba),(n:'388d15.2d';l:$100;p:$100;crc:$2f6a9a2a),
        (n:'388d16.1e';l:$100;p:$200;crc:$2e21329b),(n:'388d18.1f';l:$100;p:$300;crc:$61d2d398),
        (n:'388j17.16c';l:$100;p:$400;crc:$13c4e198));
        tp84_chars:array[0..1] of tipo_roms=(
        (n:'388_h02.2j';l:$2000;p:0;crc:$05c7508f),(n:'388_d01.1j';l:$2000;p:$2000;crc:$498d90b7));
        tp84_sprites:array[0..3] of tipo_roms=(
        (n:'388_e09.12a';l:$2000;p:$0;crc:$cd682f30),(n:'388_e10.13a';l:$2000;p:$2000;crc:$888d4bd6),
        (n:'388_e11.14a';l:$2000;p:$4000;crc:$9a220b39),(n:'388_e12.15a';l:$2000;p:$6000;crc:$fac98397));
        tp84_sound:tipo_roms=(n:'388j13.6a';l:$2000;p:$0;crc:$c44414da);
        //Dip
        tp84_dip_a:array [0..2] of def_dip=(
        (mask:$0f;name:'Coin A';number:16;dip:((dip_val:$2;dip_name:'4C 1C'),(dip_val:$5;dip_name:'3C 1C'),(dip_val:$8;dip_name:'2C 1C'),(dip_val:$4;dip_name:'3C 2C'),(dip_val:$1;dip_name:'4C 3C'),(dip_val:$f;dip_name:'1C 1C'),(dip_val:$3;dip_name:'3C 4C'),(dip_val:$7;dip_name:'2C 3C'),(dip_val:$e;dip_name:'1C 2C'),(dip_val:$6;dip_name:'2C 5C'),(dip_val:$d;dip_name:'1C 3C'),(dip_val:$c;dip_name:'1C 4C'),(dip_val:$b;dip_name:'1C 5C'),(dip_val:$a;dip_name:'1C 6C'),(dip_val:$9;dip_name:'1C 7C'),(dip_val:$0;dip_name:'Free Play'))),
        (mask:$f0;name:'Coin B';number:15;dip:((dip_val:$20;dip_name:'4C 1C'),(dip_val:$50;dip_name:'3C 1C'),(dip_val:$80;dip_name:'2C 1C'),(dip_val:$40;dip_name:'3C 2C'),(dip_val:$10;dip_name:'4C 3C'),(dip_val:$f0;dip_name:'1C 1C'),(dip_val:$30;dip_name:'3C 4C'),(dip_val:$70;dip_name:'2C 3C'),(dip_val:$e0;dip_name:'1C 2C'),(dip_val:$60;dip_name:'2C 5C'),(dip_val:$d0;dip_name:'1C 3C'),(dip_val:$c0;dip_name:'1C 4C'),(dip_val:$b0;dip_name:'1C 5C'),(dip_val:$a0;dip_name:'1C 6C'),(dip_val:$90;dip_name:'1C 7C'),())),());
        tp84_dip_b:array [0..5] of def_dip=(
        (mask:$3;name:'Lives';number:4;dip:((dip_val:$3;dip_name:'2'),(dip_val:$2;dip_name:'3'),(dip_val:$1;dip_name:'5'),(dip_val:$0;dip_name:'7'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$4;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$18;name:'Bonus Life';number:4;dip:((dip_val:$18;dip_name:'10K 50K+'),(dip_val:$10;dip_name:'20K 60K+'),(dip_val:$8;dip_name:'30K 70K+'),(dip_val:$0;dip_name:'40K 80K+'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$60;name:'Difficulty';number:4;dip:((dip_val:$60;dip_name:'Easy'),(dip_val:$40;dip_name:'Normal'),(dip_val:$20;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Demo Sounds';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 irq_enable:boolean;
 tp84_pal_bank,sound_latch,scroll_x,scroll_y,linea:byte;

procedure draw_sprites;inline;
var
  f:byte;
  palette_base,color:word;
  x,y,nchar,atrib:byte;
  flip_x,flip_y:boolean;
begin
  palette_base:=(tp84_pal_bank and $07) shl 4;
	for f:=$17 downto 0 do begin
		y:=mem_misc[$67a0+(f*4)];
		x:=mem_misc[$67a3+(f*4)];
		nchar:=mem_misc[$67a1+(f*4)];
    atrib:=mem_misc[$67a2+(f*4)];
		color:=(palette_base or (atrib and $0f)) shl 4;
		flip_y:=(atrib and $40)=0;
		flip_x:=(atrib and $80)<>0;
    put_gfx_sprite_mask(nchar,color,flip_x,flip_y,1,0,$f);
    actualiza_gfx_sprite(x,y,3,1);
  end;
end;

procedure update_video_tp84;inline;
var
  x,y,f,nchar,color:word;
  atrib:byte;
begin
for f:=$0 to $3ff do begin
      x:=31-(f div 32);
      y:=f mod 32;
      //Background
      if gfx[0].buffer[f] then begin
        atrib:=memoria[$4800+f];  //colorram
        nchar:=((atrib and $30) shl 4) or memoria[$4000+f];
        color:=((tp84_pal_bank and $07) shl 6) or
  				     ((tp84_pal_bank and $18) shl 1) or
  				     (atrib and $0f);
        put_gfx_flip(x*8,y*8,nchar,color shl 2,1,0,(atrib and $80)<>0,(atrib and $40)<>0);
        gfx[0].buffer[f]:=false;
      end;
      //Foreground
      if gfx[0].buffer[$400+f] then begin
        atrib:=memoria[$4c00+f];  //colorram
        color:=((tp84_pal_bank and $07) shl 6) or
		  		     ((tp84_pal_bank and $18) shl 1) or
			  	     (atrib and $0f);
        nchar:=((atrib and $30) shl 4) or memoria[$4400+f];
        if (atrib and $f)<>0 then put_gfx_flip(x*8,y*8,nchar,color shl 2,2,0,(atrib and $80)<>0,(atrib and $40)<>0)
          else put_gfx_block_trans(x*8,y*8,2,8,8);
        gfx[0].buffer[$400+f]:=false;
      end;
end;
scroll_x_y(1,3,scroll_x,scroll_y);
draw_sprites;
actualiza_trozo(0,0,256,256,2,0,0,256,256,3);
actualiza_trozo_final(16,0,224,256,3);
end;

procedure eventos_tp84;
begin
if event.arcade then begin
  //System
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  //P1
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  //P2
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
end;
end;

procedure tp84_principal;
var
  frame_m,frame_2,frame_s:single;
begin
init_controls(false,false,false,true);
frame_m:=m6809_0.tframes;
frame_2:=m6809_1.tframes;
frame_s:=z80_0.tframes;
while EmuStatus=EsRuning do begin
  for linea:=0 to $ff do begin
    //Main CPU
    m6809_0.run(frame_m);
    frame_m:=frame_m+m6809_0.tframes-m6809_0.contador;
    //SubCPU
    m6809_1.run(frame_2);
    frame_2:=frame_2+m6809_1.tframes-m6809_1.contador;
    //Sound CPU
    z80_0.run(frame_s);
    frame_s:=frame_s+z80_0.tframes-z80_0.contador;
    if linea=239 then begin
        if irq_enable then begin
          m6809_0.change_irq(HOLD_LINE);
          m6809_1.change_irq(HOLD_LINE);
        end;
        update_video_tp84;
    end;
  end;
  eventos_tp84;
  video_sync;
end;
end;

function tp84_getbyte(direccion:word):byte;
begin
case direccion of
  $2800:tp84_getbyte:=marcade.in0; //System
  $2820:tp84_getbyte:=marcade.in1; //p1
  $2840:tp84_getbyte:=marcade.in2; //p2
  $2860:tp84_getbyte:=marcade.dswa;
  $3000:tp84_getbyte:=marcade.dswb;
  $4000..$57ff,$8000..$ffff:tp84_getbyte:=memoria[direccion];
end;
end;

procedure tp84_putbyte(direccion:word;valor:byte);
begin
case direccion of
  $2000:; //wd
  $2800:if tp84_pal_bank<>valor then begin
          tp84_pal_bank:=valor;
          fillchar(gfx[0].buffer[0],$800,1);
        end;
  $3004,$3005:; //Flip X y flip Y
  $3800:z80_0.change_irq(HOLD_LINE);
  $3a00:sound_latch:=valor;
  $3c00:scroll_y:=valor;
  $3e00:scroll_x:=not(valor);
  $4000..$43ff,$4800..$4bff:if memoria[direccion]<>valor then begin
                              gfx[0].buffer[direccion and $3ff]:=true;
                              memoria[direccion]:=valor;
                            end;
  $4400..$47ff,$4c00..$4fff:if memoria[direccion]<>valor then begin
                              gfx[0].buffer[$400+(direccion and $3ff)]:=true;
                              memoria[direccion]:=valor;
                            end;
  $5000..$57ff:memoria[direccion]:=valor;
  $8000..$ffff:; //ROM
end;
end;

function cpu2_tp84_getbyte(direccion:word):byte;
begin
case direccion of
  $2000:cpu2_tp84_getbyte:=linea;
  $6000..$67ff,$e000..$ffff:cpu2_tp84_getbyte:=mem_misc[direccion];
  $8000..$87ff:cpu2_tp84_getbyte:=memoria[$5000+(direccion and $7ff)];
end;
end;

procedure cpu2_tp84_putbyte(direccion:word;valor:byte);
begin
case direccion of
  $4000:irq_enable:=(valor and 1)<>0;
  $6000..$67ff:mem_misc[direccion]:=valor;
  $8000..$87ff:memoria[$5000+(direccion and $7ff)]:=valor;
  $e000..$ffff:; //ROM
end;
end;

function sound_getbyte(direccion:word):byte;
begin
case direccion of
  0..$43ff:sound_getbyte:=mem_snd[direccion];
  $6000:sound_getbyte:=sound_latch;
  $8000:sound_getbyte:=((z80_0.contador+round(z80_0.tframes*linea)) shr 10) and $f;
end;
end;

procedure sound_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$3fff:; //ROM
  $4000..$43ff:mem_snd[direccion]:=valor;
  $a000..$a1ff:; //filtros
  $c001:sn_76496_0.Write(valor);
  $c003:sn_76496_1.Write(valor);
  $c004:sn_76496_2.Write(valor);
end;
end;

procedure sound_instruccion;
begin
  sn_76496_0.Update;
  sn_76496_1.Update;
  sn_76496_2.Update;
end;

//Main
procedure reset_tp84;
begin
 m6809_0.reset;
 m6809_1.reset;
 z80_0.reset;
 sn_76496_0.reset;
 sn_76496_1.reset;
 sn_76496_2.reset;
 reset_audio;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 irq_enable:=false;
 tp84_pal_bank:=0;
 sound_latch:=0;
 scroll_x:=0;
 scroll_y:=0;
end;

function iniciar_tp84:boolean;
var
  f,i,pos:word;
  colores:tpaleta;
  memoria_temp:array[0..$7fff] of byte;
  weights:array[0..3] of single;
  bit0,bit1,bit2,bit3:integer;
const
    ps_x:array[0..15] of dword=(0, 1, 2, 3, 8*8+0, 8*8+1, 8*8+2, 8*8+3,
			16*8+0, 16*8+1, 16*8+2, 16*8+3, 24*8+0, 24*8+1, 24*8+2, 24*8+3);
    ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			32*8, 33*8, 34*8, 35*8, 36*8, 37*8, 38*8, 39*8);
    resistances:array[0..3] of integer=(1000,470,220,100);
begin
llamadas_maquina.bucle_general:=tp84_principal;
llamadas_maquina.reset:=reset_tp84;
iniciar_tp84:=false;
iniciar_audio(false);
//Pantallas
screen_init(1,256,256);
screen_mod_scroll(1,256,256,255,256,256,255);
screen_init(2,256,256,true);
screen_init(3,256,256,false,true);
iniciar_video(224,256);
//Main CPU
m6809_0:=cpu_m6809.Create(1536000,256,TCPU_M6809);
m6809_0.change_ram_calls(tp84_getbyte,tp84_putbyte);
//Second CPU
m6809_1:=cpu_m6809.Create(1536000,256,TCPU_M6809);
m6809_1.change_ram_calls(cpu2_tp84_getbyte,cpu2_tp84_putbyte);
//Sound CPU
z80_0:=cpu_z80.create(3579545,$100);
z80_0.change_ram_calls(sound_getbyte,sound_putbyte);
z80_0.init_sound(sound_instruccion);
//Audio chips
sn_76496_0:=sn76496_chip.Create(1789772);
sn_76496_1:=sn76496_chip.Create(1789772);
sn_76496_2:=sn76496_chip.Create(1789772);
//cargar roms
if not(roms_load(@memoria,tp84_rom)) then exit;
//Cargar roms CPU2
if not(roms_load(@mem_misc,tp84_rom2)) then exit;
//Cargar roms sound
if not(roms_load(@mem_snd,tp84_sound)) then exit;
//convertir chars
if not(roms_load(@memoria_temp,tp84_chars)) then exit;
init_gfx(0,8,8,$400);
gfx_set_desc_data(2,0,16*8,4,0);
convert_gfx(0,0,@memoria_temp,@ps_x,@ps_y,true,false);
//sprites
if not(roms_load(@memoria_temp,tp84_sprites)) then exit;
init_gfx(1,16,16,$100);
gfx_set_desc_data(4,0,64*8,4+$4000*8,0+$4000*8,4,0);
convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,true,false);
//Colores y lookup
if not(roms_load(@memoria_temp,tp84_proms)) then exit;
compute_resistor_weights(0,	255, -1.0,
			4,@resistances,@weights, 470, 0,
			0,nil,nil,0,0,
			0,nil,nil,0,0);
for f:=0 to $ff do begin
		// red component */
		bit0:=(memoria_temp[f] shr 0) and $01;
		bit1:=(memoria_temp[f] shr 1) and $01;
		bit2:=(memoria_temp[f] shr 2) and $01;
		bit3:=(memoria_temp[f] shr 3) and $01;
		colores[f].r:=combine_4_weights(@weights, bit0, bit1, bit2, bit3);
		// green component */
		bit0:=(memoria_temp[f+$100] shr 0) and $01;
		bit1:=(memoria_temp[f+$100] shr 1) and $01;
		bit2:=(memoria_temp[f+$100] shr 2) and $01;
		bit3:=(memoria_temp[f+$100] shr 3) and $01;
		colores[f].g:=combine_4_weights(@weights, bit0, bit1, bit2, bit3);
		// blue component */
		bit0:=(memoria_temp[f+$200] shr 0) and $01;
		bit1:=(memoria_temp[f+$200] shr 1) and $01;
		bit2:=(memoria_temp[f+$200] shr 2) and $01;
		bit3:=(memoria_temp[f+$200] shr 3) and $01;
		colores[f].b:=combine_4_weights(@weights, bit0, bit1, bit2, bit3);
end;
set_pal(colores,$100);
for i:=0 to $1ff do begin
		for f:=0 to 7 do begin
			bit0:=((not(i) and $100) shr 1) or (f shl 4) or (memoria_temp[i+$300] and $0f);
      pos:=((i and $100) shl 3) or (f shl 8) or (i and $ff);
      if pos>2047 then gfx[1].colores[pos-2048]:=bit0
        else gfx[0].colores[pos]:=bit0;
		end;
end;
//DIP
marcade.dswa:=$ff;
marcade.dswb:=$32;
marcade.dswa_val:=@tp84_dip_a;
marcade.dswb_val:=@tp84_dip_b;
//final
reset_tp84;
iniciar_tp84:=true;
end;

end.
