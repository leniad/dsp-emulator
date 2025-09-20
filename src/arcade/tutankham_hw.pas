unit tutankham_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6809,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     konami_snd,sound_engine,galaxian_stars;

function iniciar_tutankham:boolean;

implementation
const
        tutan_rom:array[0..14] of tipo_roms=(
        (n:'m1.1h';l:$1000;p:0;crc:$da18679f),(n:'m2.2h';l:$1000;p:$1000;crc:$a0f02c85),
        (n:'3j.3h';l:$1000;p:$2000;crc:$ea03a1ab),(n:'m4.4h';l:$1000;p:$3000;crc:$bd06fad0),
        (n:'m5.5h';l:$1000;p:$4000;crc:$bf9fd9b0),(n:'j6.6h';l:$1000;p:$5000;crc:$fe079c5b),
        (n:'c1.1i';l:$1000;p:$6000;crc:$7eb59b21),(n:'c2.2i';l:$1000;p:$7000;crc:$6615eff3),
        (n:'c3.3i';l:$1000;p:$8000;crc:$a10d4444),(n:'c4.4i';l:$1000;p:$9000;crc:$58cd143c),
        (n:'c5.5i';l:$1000;p:$a000;crc:$d7e7ae95),(n:'c6.6i';l:$1000;p:$b000;crc:$91f62b82),
        (n:'c7.7i';l:$1000;p:$c000;crc:$afd0a81f),(n:'c8.8i';l:$1000;p:$d000;crc:$dabb609b),
        (n:'c9.9i';l:$1000;p:$e000;crc:$8ea9c6a6));
        tutan_sound:array[0..1] of tipo_roms=(
        (n:'s1.7a';l:$1000;p:0;crc:$b52d01fa),(n:'s2.8a';l:$1000;p:$1000;crc:$9db5c0ce));
        //Dip
        tutan_dip_a:array [0..1] of def_dip2=(
        (mask:$f;name:'Coin A';number:16;val16:(2,5,8,4,1,$f,3,7,$e,6,$d,$c,$b,$a,9,0);name16:('4C 1C','3C 1C','2C 1C','3C 2C','4C 3C','1C 1C','3C 4C','2C 3C','1C 2C','2C 5C','1C 3C','1C 4C','1C 5C','1C 6C','1C 7C','Free Play')),
        (mask:$f0;name:'Coin B';number:16;val16:($20,$50,$80,$40,$10,$f0,$30,$70,$e0,$60,$d0,$c0,$b0,$a0,$90,0);name16:('4C 1C','3C 1C','2C 1C','3C 2C','4C 3C','1C 1C','3C 4C','2C 3C','1C 2C','2C 5C','1C 3C','1C 4C','1C 5C','1C 6C','1C 7C','Invalid')));
        tutan_dip_b:array [0..5] of def_dip2=(
        (mask:3;name:'Lives';number:4;val4:(3,1,2,0);name4:('3','4','5','255')),
        (mask:4;name:'Cabinet';number:2;val2:(0,4);name2:('Upright','Cocktail')),
        (mask:8;name:'Bonus Life';number:2;val2:(8,0);name2:('30K','40K')),
        (mask:$30;name:'Difficulty';number:4;val4:($30,$20,$10,0);name4:('Easy','Normal','Hard','Hardest')),
        (mask:$40;name:'Flash Bomb';number:2;val2:($40,0);name2:('1 per Life','1 per Game')),
        (mask:$80;name:'Demo Sounds';number:2;val2:($80,0);name2:('Off','On')));

var
 irq_enable:boolean;
 xorx,xory,rom_nbank,scroll_y:byte;
 rom_bank:array[0..$f,0..$fff] of byte;

procedure update_video_tutankham;
var
  x,y,effx,effy,vrambyte,shifted:byte;
  punt:array[0..$ffff] of word;
begin
fill_full_screen(1,$100);
stars_scramble(1);
for y:=0 to 255 do begin
		for x:=0 to 255 do begin
			effy:=y xor xory;
      //La parte de arriba es fija!
      if effy<192 then effx:=(x xor xorx)+scroll_y
        else effx:=(x xor xorx);
			vrambyte:=memoria[effx*128+effy shr 1];
			shifted:=vrambyte shr (4*(effy and 1));
      if (shifted and $f)<>0 then punt[y*256+x]:=paleta[shifted and $f]
        else punt[y*256+x]:=getpixel(x,y,1);
		end;
end;
putpixel(0,0,$10000,@punt,1);
actualiza_trozo(16,0,224,256,1,0,0,224,256,PANT_TEMP);
end;

procedure eventos_tutankham;
begin
if event.arcade then begin
  //P1
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or 8);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but2[0] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  //P2
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or 1);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or 2);
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or 4);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or 8);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.but2[1] then marcade.in2:=(marcade.in2 and $bf) else marcade.in2:=(marcade.in2 or $40);
  //service
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
end;
end;

procedure tutankham_principal;
var
  f:byte;
  irq_req:boolean;
begin
init_controls(false,false,false,true);
irq_req:=false;
while EmuStatus=EsRunning do begin
  for f:=0 to 255 do begin
    eventos_tutankham;
    if f=240 then begin
      if (irq_req and irq_enable) then m6809_0.change_irq(ASSERT_LINE);
      update_video_tutankham;
    end;
    //Main CPU
    m6809_0.run(frame_main);
    frame_main:=frame_main+m6809_0.tframes-m6809_0.contador;
    //Sound CPU
    konamisnd_0.run;
  end;
  irq_req:=not(irq_req);
  video_sync;
end;
end;

function tutankham_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff,$8100,$8800..$8fff,$a000..$ffff:tutankham_getbyte:=memoria[direccion];
  $8000..$80ff:tutankham_getbyte:=buffer_paleta[direccion and $f];
  $8160..$816f:tutankham_getbyte:=marcade.dswb;
  $8180..$818f:tutankham_getbyte:=marcade.in0;
  $81a0..$81af:tutankham_getbyte:=marcade.in1;
  $81c0..$81cf:tutankham_getbyte:=marcade.in2;
  $81e0..$81ef:tutankham_getbyte:=marcade.dswa;
  $9000..$9fff:tutankham_getbyte:=rom_bank[rom_nbank,direccion and $fff];
end;
end;

procedure tutankham_putbyte(direccion:word;valor:byte);
var
  color:tcolor;
begin
case direccion of
  0..$7fff,$8800..$8fff:memoria[direccion]:=valor;
  $8000..$80ff:begin
                color.r:=pal3bit(valor shr 0);
                color.g:=pal3bit(valor shr 3);
                color.b:=pal2bit(valor shr 6);
                set_pal_color(color,direccion and $f);
                buffer_paleta[direccion and $f]:=valor;
               end;
  $8100..$810f:scroll_y:=valor;
  $8200..$82ff:begin
                  valor:=valor and 1;
                  case (direccion and 7) of
                    0:begin
                        irq_enable:=(valor<>0);
                        if not(irq_enable) then m6809_0.change_irq(CLEAR_LINE);
                      end;
                    4:galaxian_stars_0.enable_w(valor<>0);
                    5:konamisnd_0.enabled:=(valor=0);
                    6:xory:=255*valor;
                    7:xorx:=255*(not(valor) and 1); //La x esta invertida...
                  end;
               end;
  $8300..$83ff:rom_nbank:=valor and $f;
  $8600..$86ff:konamisnd_0.pedir_irq:=HOLD_LINE;
  $8700..$87ff:konamisnd_0.sound_latch:=valor;
  $9000..$ffff:; //ROM
end;
end;

//Main
procedure reset_tutankham;
begin
 m6809_0.reset;
 frame_main:=m6809_0.tframes;
 konamisnd_0.reset;
 galaxian_stars_0.reset;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 irq_enable:=false;
end;

function iniciar_tutankham:boolean;
var
  f:byte;
  memoria_temp:array[0..$efff] of byte;
begin
llamadas_maquina.bucle_general:=tutankham_principal;
llamadas_maquina.reset:=reset_tutankham;
llamadas_maquina.scanlines:=256;
iniciar_tutankham:=false;
iniciar_audio(false);
//Pantallas
screen_init(1,256,256,true);
iniciar_video(224,256);
//Main CPU
m6809_0:=cpu_m6809.Create(1536000,TCPU_M6809);
m6809_0.change_ram_calls(tutankham_getbyte,tutankham_putbyte);
if not(roms_load(@memoria_temp,tutan_rom)) then exit;
copymemory(@memoria[$a000],@memoria_temp[0],$6000);
for f:=0 to 8 do copymemory(@rom_bank[f,0],@memoria_temp[$6000+(f*$1000)],$1000);
//Sound Chip
konamisnd_0:=konamisnd_chip.create(2,TIPO_TIMEPLT,1789772);
if not(roms_load(@konamisnd_0.memoria,tutan_sound)) then exit;
//Stars
galaxian_stars_0:=gal_stars.create(m6809_0.numero_cpu,m6809_0.clock,SCRAMBLE);
galaxian_stars_0.create_pal($10);
//DIP
init_dips(1,tutan_dip_a,$ff);
init_dips(2,tutan_dip_b,$7b);
//final
iniciar_tutankham:=true;
end;

end.
