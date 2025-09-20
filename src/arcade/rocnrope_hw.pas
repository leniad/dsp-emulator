unit rocnrope_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6809,main_engine,controls_engine,gfx_engine,rom_engine,
     pal_engine,konami_decrypt,konami_snd,sound_engine;

function iniciar_rocnrope:boolean;

implementation
const
        rocnrope_rom:array[0..4] of tipo_roms=(
        (n:'rr1.1h';l:$2000;p:$6000;crc:$83093134),(n:'rr2.2h';l:$2000;p:$8000;crc:$75af8697),
        (n:'rr3.3h';l:$2000;p:$a000;crc:$b21372b1),(n:'rr4.4h';l:$2000;p:$c000;crc:$7acb2a05),
        (n:'rnr_h5.vid';l:$2000;p:$e000;crc:$150a6264));
        rocnrope_snd:array[0..1] of tipo_roms=(
        (n:'rnr_7a.snd';l:$1000;p:0;crc:$75d2c4e2),(n:'rnr_8a.snd';l:$1000;p:$1000;crc:$ca4325ae));
        rocnrope_sprites:array[0..3] of tipo_roms=(
        (n:'rnr_a11.vid';l:$2000;p:0;crc:$afdaba5e),(n:'rnr_a12.vid';l:$2000;p:$2000;crc:$054cafeb),
        (n:'rnr_a9.vid';l:$2000;p:$4000;crc:$9d2166b2),(n:'rnr_a10.vid';l:$2000;p:$6000;crc:$aff6e22f));
        rocnrope_chars:array[0..1] of tipo_roms=(
        (n:'rnr_h12.vid';l:$2000;p:0;crc:$e2114539),(n:'rnr_h11.vid';l:$2000;p:$2000;crc:$169a8f3f));
        rocnrope_pal:array[0..2] of tipo_roms=(
        (n:'a17_prom.bin';l:$20;p:0;crc:$22ad2c3e),(n:'b16_prom.bin';l:$100;p:$20;crc:$750a9677),
        (n:'rocnrope.pr3';l:$100;p:$120;crc:$b5c75a27));
        //Dip
        rocnrope_dip_a:array [0..2] of def_dip=(
        (mask:$0f;name:'Coin A';number:16;dip:((dip_val:$2;dip_name:'4C 1C'),(dip_val:$5;dip_name:'3C 1C'),(dip_val:$8;dip_name:'2C 1C'),(dip_val:$4;dip_name:'3C 2C'),(dip_val:$1;dip_name:'4C 3C'),(dip_val:$f;dip_name:'1C 1C'),(dip_val:$3;dip_name:'3C 4C'),(dip_val:$7;dip_name:'2C 3C'),(dip_val:$e;dip_name:'1C 2C'),(dip_val:$6;dip_name:'2C 5C'),(dip_val:$d;dip_name:'1C 3C'),(dip_val:$c;dip_name:'1C 4C'),(dip_val:$b;dip_name:'1C 5C'),(dip_val:$a;dip_name:'1C 6C'),(dip_val:$9;dip_name:'1C 7C'),(dip_val:$0;dip_name:'Free Play'))),
        (mask:$f0;name:'Coin B';number:15;dip:((dip_val:$20;dip_name:'4C 1C'),(dip_val:$50;dip_name:'3C 1C'),(dip_val:$80;dip_name:'2C 1C'),(dip_val:$40;dip_name:'3C 2C'),(dip_val:$10;dip_name:'4C 3C'),(dip_val:$f0;dip_name:'1C 1C'),(dip_val:$30;dip_name:'3C 4C'),(dip_val:$70;dip_name:'2C 3C'),(dip_val:$e0;dip_name:'1C 2C'),(dip_val:$60;dip_name:'2C 5C'),(dip_val:$d0;dip_name:'1C 3C'),(dip_val:$c0;dip_name:'1C 4C'),(dip_val:$b0;dip_name:'1C 5C'),(dip_val:$a0;dip_name:'1C 6C'),(dip_val:$90;dip_name:'1C 7C'),())),());
        rocnrope_dip_b:array [0..4] of def_dip=(
        (mask:$3;name:'Lives';number:4;dip:((dip_val:$3;dip_name:'3'),(dip_val:$2;dip_name:'4'),(dip_val:$1;dip_name:'5'),(dip_val:$0;dip_name:'255'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$4;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$78;name:'Difficulty';number:16;dip:((dip_val:$78;dip_name:'1 Easy'),(dip_val:$70;dip_name:'2'),(dip_val:$68;dip_name:'3'),(dip_val:$60;dip_name:'4'),(dip_val:$58;dip_name:'5'),(dip_val:$50;dip_name:'6'),(dip_val:$48;dip_name:'7'),(dip_val:$40;dip_name:'8'),(dip_val:$38;dip_name:'9'),(dip_val:$30;dip_name:'10'),(dip_val:$28;dip_name:'11'),(dip_val:$20;dip_name:'12'),(dip_val:$18;dip_name:'13'),(dip_val:$10;dip_name:'14'),(dip_val:$8;dip_name:'15'),(dip_val:$0;dip_name:'16 Difficult'))),
        (mask:$80;name:'Demo Sounds';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        rocnrope_dip_c:array [0..3] of def_dip=(
        (mask:$7;name:'First Bonus';number:6;dip:((dip_val:$6;dip_name:'20K'),(dip_val:$5;dip_name:'30K'),(dip_val:$4;dip_name:'40K'),(dip_val:$3;dip_name:'50K'),(dip_val:$2;dip_name:'60K'),(dip_val:$1;dip_name:'70K'),(dip_val:$0;dip_name:'80K'),(),(),(),(),(),(),(),(),())),
        (mask:$38;name:'Repeated Bonus';number:5;dip:((dip_val:$20;dip_name:'40K'),(dip_val:$18;dip_name:'50K'),(dip_val:$10;dip_name:'60K'),(dip_val:$8;dip_name:'70K'),(dip_val:$0;dip_name:'80K'),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Grant Repeated Bonus';number:2;dip:((dip_val:$40;dip_name:'No'),(dip_val:$0;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 irq_ena:boolean;
 mem_opcodes:array[0..$9fff] of byte;

procedure update_video_rocnrope;
var
  x,y,atrib:byte;
  f:word;
  nchar,color:word;
  flip_x,flip_y:boolean;
begin
for f:=0 to $3ff do begin
    if gfx[0].buffer[f] then begin
      x:=f div 32;
      y:=31-(f mod 32);
      atrib:=memoria[$4800+f];
      nchar:=memoria[$4c00+f]+((atrib and $80) shl 1);
      color:=(atrib and $f) shl 4;
      put_gfx_flip(x*8,y*8,nchar,color+256,1,0,(atrib and $20)<>0,(atrib and $40)<>0);
      gfx[0].buffer[f]:=false;
    end;
end;
actualiza_trozo(0,0,256,256,1,0,0,256,256,2);
for f:=$17 downto 0 do begin
		atrib:=memoria[$4000+(f*2)];
    nchar:=memoria[$4401+(f*2)];
    color:=(atrib and $f) shl 4;
    if not(main_screen.flip_main_screen) then begin
      x:=memoria[$4001+(f*2)];
      y:=memoria[$4400+(f*2)];
      flip_x:=(atrib and $80)=0;
      flip_y:=(atrib and $40)<>0;
    end else begin
      x:=241-memoria[$4001+(f*2)];
      y:=240-memoria[$4400+(f*2)];
      flip_x:=(atrib and $80)<>0;
      flip_y:=(atrib and $40)=0;
    end;
    put_gfx_sprite_mask(nchar,color,flip_x,flip_y,1,0,$f);
    actualiza_gfx_sprite(x,y,2,1);
end;
actualiza_trozo_final(16,0,224,256,2);
end;

procedure eventos_rocnrope;
begin
if event.arcade then begin
  //p1
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  //p2
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  //misc
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
end;
end;

procedure rocnrope_principal;
var
  frame_m:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=m6809_0.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
    //main
    m6809_0.run(frame_m);
    frame_m:=frame_m+m6809_0.tframes-m6809_0.contador;
    //snd
    konamisnd_0.run(f);
    if f=239 then begin
      update_video_rocnrope;
      if irq_ena then m6809_0.change_irq(ASSERT_LINE);
    end;
  end;
  eventos_rocnrope;
  video_sync;
end;
end;

function rocnrope_getbyte(direccion:word):byte;
begin
case direccion of
    $3000:rocnrope_getbyte:=marcade.dswb; //dsw2
    $3080:rocnrope_getbyte:=marcade.in2;
    $3081:rocnrope_getbyte:=marcade.in0;
    $3082:rocnrope_getbyte:=marcade.in1;
    $3083:rocnrope_getbyte:=marcade.dswa; //dsw1
    $3100:rocnrope_getbyte:=marcade.dswc; //dsw3
    $4000..$5fff:rocnrope_getbyte:=memoria[direccion];
    $6000..$ffff:if m6809_0.opcode then rocnrope_getbyte:=mem_opcodes[direccion-$6000]
                    else rocnrope_getbyte:=memoria[direccion];
end;
end;

procedure rocnrope_putbyte(direccion:word;valor:byte);
begin
case direccion of
  $4000..$47ff,$5000..$5fff:memoria[direccion]:=valor;
  $4800..$4fff:if memoria[direccion]<>valor then begin
                  gfx[0].buffer[direccion and $3ff]:=true;
                  memoria[direccion]:=valor;
               end;
  $6000..$807f,$8190..$ffff:; //ROM
  $8080:main_screen.flip_main_screen:=(valor and 1)=0;
  $8081:if valor<>0 then konamisnd_0.pedir_irq:=HOLD_LINE;
  $8087:begin
          irq_ena:=(valor and $1)<>0;
          if not(irq_ena) then m6809_0.change_irq(CLEAR_LINE);
        end;
  $8100:konamisnd_0.sound_latch:=valor;
  $8182..$818d:memoria[$fff2+(direccion-$8182)]:=valor;
end;
end;

//Main
procedure reset_rocnrope;
begin
 m6809_0.reset;
 konamisnd_0.reset;
 reset_audio;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 irq_ena:=false;
end;

function iniciar_rocnrope:boolean;
var
  colores:tpaleta;
  bit0,bit1,bit2:byte;
  f:word;
  memoria_temp:array[0..$ffff] of byte;
  rweights,gweights,bweights:array[0..3] of single;
const
  ps_x:array[0..15] of dword=(0, 1, 2, 3, 8*8+0, 8*8+1, 8*8+2, 8*8+3,
			16*8+0, 16*8+1, 16*8+2, 16*8+3, 24*8+0, 24*8+1, 24*8+2, 24*8+3);
  ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			32*8, 33*8, 34*8, 35*8, 36*8, 37*8, 38*8, 39*8);
  resistances_rg:array[0..2] of integer=(1000,470,220);
  resistances_b:array [0..1] of integer=(470,220);
begin
llamadas_maquina.bucle_general:=rocnrope_principal;
llamadas_maquina.reset:=reset_rocnrope;
iniciar_rocnrope:=false;
iniciar_audio(false);
screen_init(1,256,256);
screen_init(2,256,256,false,true);
iniciar_video(224,256);
//Main CPU
m6809_0:=cpu_m6809.Create(18432000 div 3 div 4,$100,TCPU_M6809);
m6809_0.change_ram_calls(rocnrope_getbyte,rocnrope_putbyte);
//Sound Chip
konamisnd_0:=konamisnd_chip.create(4,TIPO_TIMEPLT,1789772,$100);
if not(roms_load(@konamisnd_0.memoria,rocnrope_snd)) then exit;
//cargar roms y desencriptarlas
if not(roms_load(@memoria,rocnrope_rom)) then exit;
konami1_decode(@memoria[$6000],@mem_opcodes[0],$a000);
mem_opcodes[$703d-$6000]:=$98;  //Patch
//convertir chars
if not(roms_load(@memoria_temp,rocnrope_chars)) then exit;
init_gfx(0,8,8,512);
gfx_set_desc_data(4,0,16*8,$2000*8+4,$2000*8+0,4,0);
convert_gfx(0,0,@memoria_temp,@ps_x,@ps_y,false,true);
//sprites
if not(roms_load(@memoria_temp,rocnrope_sprites)) then exit;
init_gfx(1,16,16,256);
gfx_set_desc_data(4,0,64*8,$4000*8+4,$4000*8+0,4,0);
convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,true);
//paleta
if not(roms_load(@memoria_temp,rocnrope_pal)) then exit;
compute_resistor_weights(0,	255, -1.0,
			3,@resistances_rg,@rweights,1000,0,
			3,@resistances_rg,@gweights,1000,0,
			2,@resistances_b,@bweights,1000,0);
for f:=0 to $1f do begin
		// red component
		bit0:=(memoria_temp[f] shr 0) and $01;
		bit1:=(memoria_temp[f] shr 1) and $01;
		bit2:=(memoria_temp[f] shr 2) and $01;
		colores[f].r:=combine_3_weights(@rweights, bit0, bit1, bit2);
		// green component
		bit0:=(memoria_temp[f] shr 3) and $01;
		bit1:=(memoria_temp[f] shr 4) and $01;
		bit2:=(memoria_temp[f] shr 5) and $01;
		colores[f].g:=combine_3_weights(@gweights, bit0, bit1, bit2);
		// blue component
		bit0:=(memoria_temp[f] shr 6) and $01;
		bit1:=(memoria_temp[f] shr 7) and $01;
		colores[f].b:=combine_2_weights(@bweights, bit0, bit1);
end;
set_pal(colores,$20);
for f:=0 to $1ff do begin
  gfx[0].colores[f]:=memoria_temp[$20+f] and $f;  //chars
  gfx[1].colores[f]:=memoria_temp[$20+f] and $f;  //sprites
end;
//DIP
marcade.dswa:=$ff;
marcade.dswb:=$5b;
marcade.dswc:=$96;
marcade.dswa_val:=@rocnrope_dip_a;
marcade.dswb_val:=@rocnrope_dip_b;
marcade.dswc_val:=@rocnrope_dip_c;
//final
reset_rocnrope;
iniciar_rocnrope:=true;
end;

end.
