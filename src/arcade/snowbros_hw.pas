unit snowbros_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,m68000,main_engine,controls_engine,gfx_engine,ym_3812,
     rom_engine,pal_engine,kaneco_pandora,sound_engine;

function iniciar_snowbros:boolean;

implementation
const
        snowbros_rom:array[0..1] of tipo_roms=(
        (n:'sn6.bin';l:$20000;p:0;crc:$4899ddcf),(n:'sn5.bin';l:$20000;p:$1;crc:$ad310d3f));
        snowbros_char:tipo_roms=(n:'sbros-1.41';l:$80000;p:0;crc:$16f06b3a);
        snowbros_sound:tipo_roms=(n:'sbros-4.29';l:$8000;p:0;crc:$e6eab4e4);
        //Dip
        snowbros_dip_a:array [0..6] of def_dip=(
        (mask:$1;name:'Region';number:2;dip:((dip_val:$0;dip_name:'Europe'),(dip_val:$1;dip_name:'America (Romstar license)'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2;name:'Flip Screen';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Service Mode';number:2;dip:((dip_val:$4;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$8;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Coin A';number:7;dip:((dip_val:$0;dip_name:'4C 1C EUR'),(dip_val:$10;dip_name:'3C 1C EUR'),(dip_val:$20;dip_name:'2C 1C EUR'),(dip_val:$10;dip_name:'2C 1C AME'),(dip_val:$30;dip_name:'1C 1C'),(dip_val:$0;dip_name:'2C 3C AME'),(dip_val:$20;dip_name:'2C 1C AME'),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Coin B';number:8;dip:((dip_val:$40;dip_name:'2C 1C AME'),(dip_val:$c0;dip_name:'1C 1C AME'),(dip_val:$0;dip_name:'2C 3C AME'),(dip_val:$80;dip_name:'1C 2C AME'),(dip_val:$c0;dip_name:'1C 2C EUR'),(dip_val:$80;dip_name:'1C 3C EUR'),(dip_val:$40;dip_name:'1C 4C EUR'),(dip_val:$0;dip_name:'1C 6C EUR'),(),(),(),(),(),(),(),())),());
        snowbros_dip_b:array [0..5] of def_dip=(
        (mask:$3;name:'Difficulty';number:4;dip:((dip_val:$2;dip_name:'Easy'),(dip_val:$3;dip_name:'Normal'),(dip_val:$1;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Bonus Life';number:4;dip:((dip_val:$4;dip_name:'100k 200k+'),(dip_val:$c;dip_name:'100k'),(dip_val:$8;dip_name:'200k'),(dip_val:$0;dip_name:'None'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Lives';number:4;dip:((dip_val:$20;dip_name:'1'),(dip_val:$0;dip_name:'2'),(dip_val:$30;dip_name:'3'),(dip_val:$10;dip_name:'4'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Invulnerability';number:2;dip:((dip_val:$40;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Allow Continue';number:2;dip:((dip_val:$0;dip_name:'No'),(dip_val:$80;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 rom:array[0..$1ffff] of word;
 ram:array[0..$1fff] of word;
 sound_latch:byte;

procedure update_video_snowbros;
begin
  pandora_0.update_video(1,0);
  actualiza_trozo_final(0,16,256,224,1);
end;

procedure eventos_snowbros;
begin
if event.arcade then begin
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $feff) else marcade.in1:=(marcade.in1 or $0100);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $Fdff) else marcade.in1:=(marcade.in1 or $0200);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fbff) else marcade.in1:=(marcade.in1 or $0400);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $F7ff) else marcade.in1:=(marcade.in1 or $0800);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $efff) else marcade.in1:=(marcade.in1 or $1000);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $dfff) else marcade.in1:=(marcade.in1 or $2000);
  if arcade_input.but2[0] then marcade.in1:=(marcade.in1 and $bfff) else marcade.in1:=(marcade.in1 or $4000);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fbff) else marcade.in0:=(marcade.in0 or $0400);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $f7ff) else marcade.in0:=(marcade.in0 or $0800);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $feff) else marcade.in0:=(marcade.in0 or $0100);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $fdff) else marcade.in0:=(marcade.in0 or $0200);
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $feff) else marcade.in2:=(marcade.in2 or $0100);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $Fdff) else marcade.in2:=(marcade.in2 or $0200);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fbff) else marcade.in2:=(marcade.in2 or $400);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $F7ff) else marcade.in2:=(marcade.in2 or $0800);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $efff) else marcade.in2:=(marcade.in2 or $1000);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $dfff) else marcade.in2:=(marcade.in2 or $2000);
  if arcade_input.but2[1] then marcade.in2:=(marcade.in2 and $bfff) else marcade.in2:=(marcade.in2 or $4000);
end;
end;

procedure snowbros_principal;
var
  frame_m,frame_s:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
frame_s:=z80_0.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to 261 do begin
  //Main CPU
  m68000_0.run(frame_m);
  frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
  //Sound CPU
  z80_0.run(frame_s);
  frame_s:=frame_s+z80_0.tframes-z80_0.contador;
  case f of
    31:m68000_0.irq[4]:=ASSERT_LINE;
    127:m68000_0.irq[3]:=ASSERT_LINE;
    239:begin
          m68000_0.irq[2]:=ASSERT_LINE;
          update_video_snowbros;
        end;
  end;
 end;
 eventos_snowbros;
 video_sync;
end;
end;

function snowbros_getword(direccion:dword):word;
begin
case direccion of
    0..$3ffff:snowbros_getword:=rom[direccion shr 1];
    $100000..$103fff:snowbros_getword:=ram[(direccion and $3fff) shr 1];
    $300000:snowbros_getword:=sound_latch;
    $500000:snowbros_getword:=marcade.in1+marcade.dswa;
    $500002:snowbros_getword:=marcade.in2+marcade.dswb;
    $500004:snowbros_getword:=marcade.in0;
    $600000..$6001ff:snowbros_getword:=buffer_paleta[(direccion and $1ff) shr 1];
    $700000..$701fff:snowbros_getword:=pandora_0.spriteram_r16(direccion and $1fff);
end;
end;

procedure snowbros_putword(direccion:dword;valor:word);

procedure cambiar_color(tmp_color,numero:word);
var
  color:tcolor;
begin
  color.b:=pal5bit(tmp_color shr 10);
  color.g:=pal5bit(tmp_color shr 5);
  color.r:=pal5bit(tmp_color);
  set_pal_color(color,numero);
end;

begin
case direccion of
    0..$3ffff:; //ROM
    $100000..$103fff:ram[(direccion and $3fff) shr 1]:=valor;
    $200000,$702000..$7022ff:exit;
    $400000:main_screen.flip_main_screen:=(valor and $8000)=0;
    $300000:begin
            sound_latch:=valor and $ff;
            z80_0.change_nmi(PULSE_LINE);
          end;
    $600000..$6001ff:if buffer_paleta[(direccion and $1ff) shr 1]<>valor then begin
                      buffer_paleta[(direccion and $1ff) shr 1]:=valor;
                      cambiar_color(valor,(direccion and $1ff) shr 1);
                   end;
    $700000..$701fff:pandora_0.spriteram_w16((direccion and $1fff),valor and $ff);
    $800000:m68000_0.irq[4]:=CLEAR_LINE;
    $900000:m68000_0.irq[3]:=CLEAR_LINE;
    $a00000:m68000_0.irq[2]:=CLEAR_LINE;
  end;
end;

function snowbros_snd_getbyte(direccion:word):byte;
begin
snowbros_snd_getbyte:=mem_snd[direccion];
end;

procedure snowbros_snd_putbyte(direccion:word;valor:byte);
begin
if direccion>$7fff then mem_snd[direccion]:=valor;
end;

function snowbros_snd_inbyte(puerto:word):byte;
begin
  case (puerto and $ff) of
    $2:snowbros_snd_inbyte:=ym3812_0.status;
    $4:snowbros_snd_inbyte:=sound_latch;
  end;
end;

procedure snowbros_snd_outbyte(puerto:word;valor:byte);
begin
case (puerto and $ff) of
  $2:ym3812_0.control(valor);
  $3:ym3812_0.write(valor);
  $4:sound_latch:=valor;
end;
end;

procedure snowbros_sound_act;
begin
  ym3812_0.update;
end;

procedure snd_irq(irqstate:byte);
begin
  z80_0.change_irq(irqstate);
end;

//Main
procedure reset_snowbros;
begin
 m68000_0.reset;
 z80_0.reset;
 pandora_0.reset;
 ym3812_0.reset;
 reset_audio;
 marcade.in0:=$ff00;
 marcade.in1:=$7f00;
 marcade.in2:=$7f00;
 sound_latch:=0;
end;

function iniciar_snowbros:boolean;
const
  pc_x:array[0..15] of dword=(0, 4, 8, 12, 16, 20, 24, 28,
		8*32+0, 8*32+4, 8*32+8, 8*32+12, 8*32+16, 8*32+20, 8*32+24, 8*32+28);
  pc_y:array[0..15] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32,
		16*32, 17*32, 18*32, 19*32, 20*32, 21*32, 22*32, 23*32);
var
  memoria_temp:array[0..$7ffff] of byte;
begin
llamadas_maquina.bucle_general:=snowbros_principal;
llamadas_maquina.reset:=reset_snowbros;
llamadas_maquina.fps_max:=57.5;
iniciar_snowbros:=false;
iniciar_audio(false);
screen_init(1,512,512,true,true);
iniciar_video(256,224);
//Main CPU
m68000_0:=cpu_m68000.create(8000000,262);
m68000_0.change_ram16_calls(snowbros_getword,snowbros_putword);
//Sound CPU
z80_0:=cpu_z80.create(6000000,262);
z80_0.change_ram_calls(snowbros_snd_getbyte,snowbros_snd_putbyte);
z80_0.change_io_calls(snowbros_snd_inbyte,snowbros_snd_outbyte);
z80_0.init_sound(snowbros_sound_act);
//pandora
pandora_0:=pandora_gfx.create($fff,0,true);
//Sound Chips
ym3812_0:=ym3812_chip.create(YM3812_FM,3000000);
ym3812_0.change_irq_calls(snd_irq);
//cargar roms
if not(roms_load16w(@rom,snowbros_rom)) then exit;
//cargar sonido
if not(roms_load(@mem_snd,snowbros_sound)) then exit;
//convertir chars
if not(roms_load(@memoria_temp,snowbros_char)) then exit;
init_gfx(0,16,16,$1000);
gfx[0].trans[0]:=true;
gfx_set_desc_data(4,0,32*32,0,1,2,3);
convert_gfx(0,0,@memoria_temp,@pc_x,@pc_y,false,false);
//DIP
marcade.dswa:=$fe;
marcade.dswb:=$ff;
marcade.dswa_val:=@snowbros_dip_a;
marcade.dswb_val:=@snowbros_dip_b;
//final
reset_snowbros;
iniciar_snowbros:=true;
end;

end.
