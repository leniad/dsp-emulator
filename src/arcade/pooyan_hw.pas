unit pooyan_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     konami_snd,sound_engine;

function iniciar_pooyan:boolean;

implementation
const
        pooyan_rom:array[0..3] of tipo_roms=(
        (n:'1.4a';l:$2000;p:0;crc:$bb319c63),(n:'2.5a';l:$2000;p:$2000;crc:$a1463d98),
        (n:'3.6a';l:$2000;p:$4000;crc:$fe1a9e08),(n:'4.7a';l:$2000;p:$6000;crc:$9e0f9bcc));
        pooyan_pal:array[0..2] of tipo_roms=(
        (n:'pooyan.pr1';l:$20;p:0;crc:$a06a6d0e),(n:'pooyan.pr2';l:$100;p:$20;crc:$82748c0b),
        (n:'pooyan.pr3';l:$100;p:$120;crc:$8cd4cd60));
        pooyan_char:array[0..1] of tipo_roms=(
        (n:'8.10g';l:$1000;p:0;crc:$931b29eb),(n:'7.9g';l:$1000;p:$1000;crc:$bbe6d6e4));
        pooyan_sound:array[0..1] of tipo_roms=(
        (n:'xx.7a';l:$1000;p:0;crc:$fbe2b368),(n:'xx.8a';l:$1000;p:$1000;crc:$e1795b3d));
        pooyan_sprites:array[0..1] of tipo_roms=(
        (n:'6.9a';l:$1000;p:0;crc:$b2d8c121),(n:'5.8a';l:$1000;p:$1000;crc:$1097c2b6));
        //Dip
        pooyan_dip_a:array [0..2] of def_dip2=(
        (mask:$f;name:'Coin A';number:16;val16:(2,5,8,4,1,$f,3,7,$e,6,$d,$c,$b,$a,9,0);name16:('4C 1C','3C 1C','2C 1C','3C 2C','4C 3C','1C 1C','3C 4C','2C 3C','1C 2C','2C 5C','1C 3C','1C 4C','1C 5C','1C 6C','1C 7C','Free Play')),
        (mask:$f0;name:'Coin B';number:16;val16:($20,$50,$80,$40,$10,$f0,$30,$70,$e0,$60,$d0,$c0,$b0,$a0,$90,0);name16:('4C 1C','3C 1C','2C 1C','3C 2C','4C 3C','1C 1C','3C 4C','2C 3C','1C 2C','2C 5C','1C 3C','1C 4C','1C 5C','1C 6C','1C 7C','Invalid')),());
        pooyan_dip_b:array [0..5] of def_dip2=(
        (mask:3;name:'Lives';number:4;val4:(3,2,1,0);name4:('3','4','5','255')),
        (mask:4;name:'Cabinet';number:2;val2:(0,4);name2:('Upright','Cocktail')),
        (mask:8;name:'Bonus Life';number:2;val2:(8,0);name2:('50K 80K+','30K 70K+')),
        (mask:$70;name:'Difficulty';number:8;val8:($70,$60,$50,$40,$30,$20,$10,0);name8:('1 (Easy)','2','3','4','5','6','7','8 (Hard)')),
        (mask:$80;name:'Demo Sounds';number:2;val2:($80,0);name2:('Off','On')),());

var
 nmi_vblank:boolean;
 last:byte;

procedure update_video_pooyan;
var
  f:word;
  x,y,color,nchar,atrib:byte;
  flipx,flipy:boolean;
begin
for f:=0 to $3ff do begin
  if gfx[0].buffer[f] then begin
    x:=31-(f div 32);
    y:=f mod 32;
    atrib:=memoria[$8000+f];
    color:=(atrib and $f) shl 4;
    nchar:=memoria[$8400+f]+8*(atrib and $20);
    put_gfx_flip(x*8,y*8,nchar,color,1,0,(atrib and $80)<>0,(atrib and $40)<>0);
    gfx[0].buffer[f]:=false;
  end;
end;
actualiza_trozo(0,0,256,256,1,0,0,256,256,2);
for f:=0 to $17 do begin
    atrib:=memoria[$9410+(f*2)];
    nchar:=memoria[$9011+(f*2)] and $3f;
    color:=(atrib and $f) shl 4;
    x:=memoria[$9411+(f*2)];
    y:=memoria[$9010+(f*2)];
    flipx:=(atrib and $80)<>0;
    flipy:=(atrib and $40)=0;
    if main_screen.flip_main_screen then begin
      x:=240-x;
      y:=240-y;
      flipx:=not(flipx);
      flipy:=not(flipy);
    end;
    put_gfx_sprite(nchar,color,flipx,flipy,1);
    actualiza_gfx_sprite(x,y,2,1);
end;
actualiza_trozo_final(16,0,224,256,2);
end;

procedure eventos_pooyan;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or 8);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  //P2
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or 4);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or 8);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  //system
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
end;
end;

procedure pooyan_principal;
var
  f:byte;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
  for f:=0 to $ff do begin
    if f=240 then begin
      if nmi_vblank then z80_0.change_nmi(ASSERT_LINE);
      update_video_pooyan;
    end;
    //Main CPU
    z80_0.run(frame_main);
    frame_main:=frame_main+z80_0.tframes-z80_0.contador;
    //SND CPU
    konamisnd_0.run;
  end;
  eventos_pooyan;
  video_sync;
end;
end;

function pooyan_getbyte(direccion:word):byte;
begin
case direccion of
  0..$8fff:pooyan_getbyte:=memoria[direccion];
  $9000..$9fff:case (direccion and $7ff) of
                  0..$3ff:pooyan_getbyte:=memoria[$9000+(direccion and $ff)];
                  $400..$7ff:pooyan_getbyte:=memoria[$9400+(direccion and $ff)];
               end;
  $a000..$bfff:case (direccion and $3ff) of
                    0..$7f,$200..$27f:pooyan_getbyte:=marcade.dswb;
                    $80..$9f,$280..$29f:pooyan_getbyte:=marcade.in0;
                    $a0..$bf,$2a0..$2bf:pooyan_getbyte:=marcade.in1;
                    $c0..$df,$2c0..$2df:pooyan_getbyte:=marcade.in2;
                    $e0..$ff,$2e0..$2ff:pooyan_getbyte:=marcade.dswa;
               end;
end;
end;

procedure pooyan_putbyte(direccion:word;valor:byte);
begin
case direccion of
    0..$7fff:;
    $8000..$87ff:begin
                    gfx[0].buffer[direccion and $3ff]:=true;
                    memoria[direccion]:=valor;
                 end;
    $8800..$8fff:memoria[direccion]:=valor;
    $9000..$9fff:case (direccion and $7ff) of
                  0..$3ff:memoria[$9000+(direccion and $ff)]:=valor;
                  $400..$7ff:memoria[$9400+(direccion and $ff)]:=valor;
               end;
    $a000..$bfff:case (direccion and $3ff) of
                  0..$7f,$200..$27f:; //WatchDog
                  $100..$17f,$300..$37f:konamisnd_0.sound_latch:=valor;
                  $180,$380:begin
                              nmi_vblank:=valor<>0;
                              if not(nmi_vblank) then z80_0.change_nmi(CLEAR_LINE);
                            end;
                  $181,$381:begin
                              if ((last=0) and (valor<>0)) then konamisnd_0.pedir_irq:=HOLD_LINE;
                              last:=valor;
                            end;
                  $182,$382:konamisnd_0.enabled:=(valor=0);
                  $187,$387:main_screen.flip_main_screen:=(valor and 1)=0;
               end;
end;
end;

//Main
procedure reset_pooyan;
begin
 z80_0.reset;
 frame_main:=z80_0.tframes;
 reset_audio;
 konamisnd_0.reset;
 nmi_vblank:=false;
 last:=0;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
end;

function iniciar_pooyan:boolean;
var
  colores:tpaleta;
  f:word;
  bit0,bit1,bit2:byte;
  memoria_temp:array[0..$1fff] of byte;
  rweights,gweights,bweights:array[0..2] of single;
const
  ps_x:array[0..15] of dword=(0, 1, 2, 3,  8*8+0, 8*8+1, 8*8+2, 8*8+3,
			16*8+0, 16*8+1, 16*8+2, 16*8+3,  24*8+0, 24*8+1, 24*8+2, 24*8+3);
  ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			32*8, 33*8, 34*8, 35*8, 36*8, 37*8, 38*8, 39*8);
  resistances:array[0..2] of integer=(1000,470,220);
begin
llamadas_maquina.bucle_general:=pooyan_principal;
llamadas_maquina.reset:=reset_pooyan;
iniciar_pooyan:=false;
iniciar_audio(false);
screen_init(1,256,256);
screen_init(2,256,256,false,true);
iniciar_video(224,256);
//Main CPU
z80_0:=cpu_z80.create(3072000,256);
z80_0.change_ram_calls(pooyan_getbyte,pooyan_putbyte);
//Sound Chip
konamisnd_0:=konamisnd_chip.create(4,TIPO_TIMEPLT,1789772,256);
if not(roms_load(@konamisnd_0.memoria,pooyan_sound)) then exit;
//cargar roms
if not(roms_load(@memoria,pooyan_rom)) then exit;
//convertir chars
if not(roms_load(@memoria_temp,pooyan_char)) then exit;
init_gfx(0,8,8,256);
gfx_set_desc_data(4,0,16*8,$1000*8+4,$1000*8+0,4,0);
convert_gfx(0,0,@memoria_temp,@ps_x,@ps_y,true,false);
//convertir sprites
if not(roms_load(@memoria_temp,pooyan_sprites)) then exit;
init_gfx(1,16,16,64);
gfx[1].trans[0]:=true;
gfx_set_desc_data(4,0,64*8,$1000*8+4,$1000*8+0,4,0);
convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,true,false);
//poner la paleta
if not(roms_load(@memoria_temp,pooyan_pal)) then exit;
compute_resistor_weights(0,	255, -1.0,
			3,@resistances,@rweights,0,0,
			3,@resistances,@gweights,0,0,
			2,@resistances[1],@bweights,0,0);
for f:=0 to $1f do begin
		// red component
		bit0:=(memoria_temp[f] shr 0) and 1;
		bit1:=(memoria_temp[f] shr 1) and 1;
		bit2:=(memoria_temp[f] shr 2) and 1;
		colores[f].r:=combine_3_weights(@rweights,bit0,bit1,bit2);
		// green component
		bit0:=(memoria_temp[f] shr 3) and 1;
		bit1:=(memoria_temp[f] shr 4) and 1;
		bit2:=(memoria_temp[f] shr 5) and 1;
		colores[f].g:=combine_3_weights(@gweights,bit0,bit1,bit2);
		// blue component
		bit0:=(memoria_temp[f] shr 6) and 1;
		bit1:=(memoria_temp[f] shr 7) and 1;
		colores[f].b:=combine_2_weights(@bweights,bit0,bit1);
end;
set_pal(colores,$20);
for f:=0 to $ff do begin
  gfx[1].colores[f]:=memoria_temp[$20+f] and $f;
  gfx[0].colores[f]:=(memoria_temp[$120+f] and $f)+$10;
end;
//DIP
marcade.dswa:=$ff;
marcade.dswb:=$7b;
marcade.dswa_val2:=@pooyan_dip_a;
marcade.dswb_val2:=@pooyan_dip_b;
//final
reset_pooyan;
iniciar_pooyan:=true;
end;

end.
