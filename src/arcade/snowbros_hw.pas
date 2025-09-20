unit snowbros_hw;
interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,m68000,main_engine,controls_engine,gfx_engine,ym_3812,rom_engine,
     pal_engine,kaneco_pandora,sound_engine,misc_functions,mcs51,ym_2151,
     oki6295;

function iniciar_snowbros:boolean;

implementation
const
        snowbros_rom:array[0..1] of tipo_roms=(
        (n:'sn6.bin';l:$20000;p:0;crc:$4899ddcf),(n:'sn5.bin';l:$20000;p:$1;crc:$ad310d3f));
        snowbros_char:tipo_roms=(n:'sbros-1.41';l:$80000;p:0;crc:$16f06b3a);
        snowbros_sound:tipo_roms=(n:'sbros-4.29';l:$8000;p:0;crc:$e6eab4e4);
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
        toto_rom:array[0..1] of tipo_roms=(
        (n:'u60.5j';l:$20000;p:0;crc:$39203792),(n:'u51.4j';l:$20000;p:$1;crc:$7b846cd4));
        toto_char:array[0..3] of tipo_roms=(
        (n:'u107.8k';l:$20000;p:0;crc:$4486153b),(n:'u108.8l';l:$20000;p:$20000;crc:$3286cf5f),
        (n:'u109.8m';l:$20000;p:$40000;crc:$464d7251),(n:'u110.8n';l:$20000;p:$60000;crc:$7dea56df));
        toto_sound:tipo_roms=(n:'u46.4c';l:$8000;p:0;crc:$77b1ef42);
        hyperpac_rom:array[0..1] of tipo_roms=(
        (n:'hyperpac.h12';l:$20000;p:1;crc:$2cf0531a),(n:'hyperpac.i12';l:$20000;p:$0;crc:$9c7d85b8));
        hyperpac_char:array[0..2] of tipo_roms=(
        (n:'hyperpac.a4';l:$40000;p:0;crc:$bd8673da),(n:'hyperpac.a5';l:$40000;p:$40000;crc:$5d90cd82),
        (n:'hyperpac.a6';l:$40000;p:$80000;crc:$61d86e63));
        hyperpac_sound:tipo_roms=(n:'hyperpac.u1';l:$10000;p:0;crc:$03faf88e);
        hyperpac_mcu:tipo_roms=(n:'at89c52.bin';l:$2000;p:0;crc:$291f9326);
        hyperpac_oki:tipo_roms=(n:'hyperpac.j15';l:$40000;p:0;crc:$fb9f468d);

var
 rom:array[0..$1ffff] of word;
 ram:array[0..$7fff] of word;
 sound_latch:byte;
 //Hyper Pacman
 semicom_prot_base:word;
 semicom_prot_offset:byte;

procedure update_video_snowbros;
begin
  pandora_0.update_video(1,0);
  actualiza_trozo_final(0,16,256,224,1);
end;

procedure eventos_snowbros;
begin
if event.arcade then begin
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $feff) else marcade.in1:=(marcade.in1 or $0100);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $fdff) else marcade.in1:=(marcade.in1 or $0200);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fbff) else marcade.in1:=(marcade.in1 or $0400);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $f7ff) else marcade.in1:=(marcade.in1 or $0800);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $efff) else marcade.in1:=(marcade.in1 or $1000);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $dfff) else marcade.in1:=(marcade.in1 or $2000);
  if arcade_input.but2[0] then marcade.in1:=(marcade.in1 and $bfff) else marcade.in1:=(marcade.in1 or $4000);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fbff) else marcade.in0:=(marcade.in0 or $0400);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $f7ff) else marcade.in0:=(marcade.in0 or $0800);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $feff) else marcade.in0:=(marcade.in0 or $0100);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $fdff) else marcade.in0:=(marcade.in0 or $0200);
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $feff) else marcade.in2:=(marcade.in2 or $0100);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $fdff) else marcade.in2:=(marcade.in2 or $0200);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fbff) else marcade.in2:=(marcade.in2 or $400);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $f7ff) else marcade.in2:=(marcade.in2 or $0800);
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
while EmuStatus=EsRunning do begin
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
    0..$fffff:snowbros_getword:=rom[direccion shr 1];
    $100000..$10ffff:snowbros_getword:=ram[(direccion and $ffff) shr 1];
    $300000:snowbros_getword:=sound_latch;
    $500000:snowbros_getword:=marcade.in1+marcade.dswa;
    $500002:snowbros_getword:=marcade.in2+marcade.dswb;
    $500004:snowbros_getword:=marcade.in0;
    $500006:snowbros_getword:=$700;  //Proteccion Toto
    $600000..$6001ff:snowbros_getword:=buffer_paleta[(direccion and $1ff) shr 1];
    $700000..$701fff:snowbros_getword:=pandora_0.spriteram_r16(direccion and $1fff);
end;
end;

procedure cambiar_color(tmp_color,numero:word);
var
  color:tcolor;
begin
  color.b:=pal5bit(tmp_color shr 10);
  color.g:=pal5bit(tmp_color shr 5);
  color.r:=pal5bit(tmp_color);
  set_pal_color(color,numero);
end;

procedure snowbros_putword(direccion:dword;valor:word);
begin
case direccion of
    0..$fffff:; //ROM
    $100000..$10ffff:ram[(direccion and $ffff) shr 1]:=valor;
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

//Hyper Pacman
procedure eventos_hyperpac;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 or $0100) else marcade.in1:=(marcade.in1 and $feff);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 or $0200) else marcade.in1:=(marcade.in1 and $fdff);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 or $0400) else marcade.in1:=(marcade.in1 and $fbff);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 or $0800) else marcade.in1:=(marcade.in1 and $f7ff);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 or $1000) else marcade.in1:=(marcade.in1 and $efff);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 or $2000) else marcade.in1:=(marcade.in1 and $dfff);
  if arcade_input.but2[0] then marcade.in1:=(marcade.in1 or $4000) else marcade.in1:=(marcade.in1 and $bfff);
  //System
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 or $0400) else marcade.in0:=(marcade.in0 and $fbff);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 or $0800) else marcade.in0:=(marcade.in0 and $f7ff);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 or $0100) else marcade.in0:=(marcade.in0 and $feff);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 or $0200) else marcade.in0:=(marcade.in0 and $fdff);
  //P2
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 or $0100) else marcade.in2:=(marcade.in2 and $feff);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 or $0200) else marcade.in2:=(marcade.in2 and $fdff);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 or $400) else marcade.in2:=(marcade.in2 and $fbff);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 or $0800) else marcade.in2:=(marcade.in2 and $f7ff);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 or $1000) else marcade.in2:=(marcade.in2 and $efff);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 or $2000) else marcade.in2:=(marcade.in2 and $dfff);
  if arcade_input.but2[1] then marcade.in2:=(marcade.in2 or $4000) else marcade.in2:=(marcade.in2 and $bfff);
end;
end;

procedure hyperpac_principal;
var
  frame_m,frame_s,frame_mcu:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
frame_s:=z80_0.tframes;
frame_mcu:=mcs51_0.tframes;
while EmuStatus=EsRunning do begin
 for f:=0 to 261 do begin
  //Main CPU
  m68000_0.run(frame_m);
  frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
  //Sound CPU
  z80_0.run(frame_s);
  frame_s:=frame_s+z80_0.tframes-z80_0.contador;
  //MCU
  mcs51_0.run(frame_mcu);
  frame_mcu:=frame_mcu+mcs51_0.tframes-mcs51_0.contador;
  case f of
    31:m68000_0.irq[4]:=ASSERT_LINE;
    127:m68000_0.irq[3]:=ASSERT_LINE;
    239:begin
          m68000_0.irq[2]:=ASSERT_LINE;
          update_video_snowbros;
        end;
  end;
 end;
 eventos_hyperpac;
 video_sync;
end;
end;

procedure hyperpac_putword(direccion:dword;valor:word);
begin
case direccion of
    0..$fffff:; //ROM
    $100000..$10ffff:ram[(direccion and $ffff) shr 1]:=valor;
    $300000:sound_latch:=valor and $ff;
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

function hyperpac_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$d7ff:hyperpac_snd_getbyte:=mem_snd[direccion];
  $f001:hyperpac_snd_getbyte:=ym2151_0.status;
  $f002:hyperpac_snd_getbyte:=oki_6295_0.read;
  $f008:hyperpac_snd_getbyte:=sound_latch;
end;
end;

procedure hyperpac_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$cfff:;
  $d000..$d7ff:mem_snd[direccion]:=valor;
  $f000:ym2151_0.reg(valor);
  $f001:ym2151_0.write(valor);
  $f002:oki_6295_0.write(valor);
end;
end;

procedure hyperpac_sound_act;
begin
  ym2151_0.update;
  oki_6295_0.update;
end;

procedure ym2151_snd_irq(irqstate:byte);
begin
  z80_0.change_irq(irqstate);
end;

procedure hyperpac_out_port0(valor:byte);
var
  tempw:word;
begin
  tempw:=ram[semicom_prot_base+semicom_prot_offset];
	tempw:=(tempw and $ff00) or (valor shl 0);
	ram[semicom_prot_base+semicom_prot_offset]:=tempw;
end;

procedure hyperpac_out_port1(valor:byte);
var
  tempw:word;
begin
  tempw:=ram[semicom_prot_base+semicom_prot_offset];
	tempw:=(tempw and $ff) or (valor shl 8);
	ram[semicom_prot_base+semicom_prot_offset]:=tempw;
end;

procedure hyperpac_out_port2(valor:byte);
begin
  semicom_prot_offset:=valor;
end;

//Main
procedure reset_snowbros;
begin
 m68000_0.reset;
 z80_0.reset;
 pandora_0.reset;
 if main_vars.tipo_maquina=387 then begin
     ym2151_0.reset;
     oki_6295_0.reset;
     marcade.in0:=0;
     marcade.in1:=0;
     marcade.in2:=0;
 end else begin
    ym3812_0.reset;
    marcade.in0:=$ff00;
    marcade.in1:=$7f00;
    marcade.in2:=$7f00;
 end;
 sound_latch:=0;
end;

function iniciar_snowbros:boolean;
const
  pc_x:array[0..15] of dword=(0, 4, 8, 12, 16, 20, 24, 28,
		8*32+0, 8*32+4, 8*32+8, 8*32+12, 8*32+16, 8*32+20, 8*32+24, 8*32+28);
  pc_y:array[0..15] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32,
		16*32, 17*32, 18*32, 19*32, 20*32, 21*32, 22*32, 23*32);
  pc_x_hp:array[0..15] of dword=(4, 0, 8*32+4, 8*32+0, 20,16, 8*32+20, 8*32+16,
		12, 8, 8*32+12, 8*32+8, 28, 24, 8*32+28, 8*32+24);
  pc_y_hp:array[0..15] of dword=(0*32, 2*32, 1*32, 3*32, 16*32+0*32, 16*32+2*32, 16*32+1*32, 16*32+3*32,
		4*32, 6*32, 5*32, 7*32, 16*32+4*32, 16*32+6*32, 16*32+5*32, 16*32+7*32);
var
  memoria_temp:array[0..$bffff] of byte;
  ptemp:pbyte;
  f:dword;
procedure convert_chars(num:word;tipo:byte);
begin
  init_gfx(0,16,16,num);
  gfx[0].trans[0]:=true;
  gfx_set_desc_data(4,0,32*32,0,1,2,3);
  if tipo=0 then convert_gfx(0,0,@memoria_temp,@pc_x,@pc_y,false,false)
    else convert_gfx(0,0,@memoria_temp,@pc_x_hp,@pc_y_hp,false,false);
end;
begin
llamadas_maquina.reset:=reset_snowbros;
llamadas_maquina.fps_max:=57.5;
llamadas_maquina.scanlines:=262;
iniciar_snowbros:=false;
iniciar_audio(false);
screen_init(1,512,512,true,true);
iniciar_video(256,224);
case main_vars.tipo_maquina of
  54,386:begin
            llamadas_maquina.bucle_general:=snowbros_principal;
            //Main CPU
            m68000_0:=cpu_m68000.create(8000000);
            m68000_0.change_ram16_calls(snowbros_getword,snowbros_putword);
            //Sound CPU
            z80_0:=cpu_z80.create(6000000);
            z80_0.change_ram_calls(snowbros_snd_getbyte,snowbros_snd_putbyte);
            z80_0.change_io_calls(snowbros_snd_inbyte,snowbros_snd_outbyte);
            z80_0.init_sound(snowbros_sound_act);
            //Sound Chips
            ym3812_0:=ym3812_chip.create(YM3812_FM,3000000);
            ym3812_0.change_irq_calls(snd_irq);
  end;
  387:begin
        llamadas_maquina.bucle_general:=hyperpac_principal;
        //Main CPU
        m68000_0:=cpu_m68000.create(12000000);
        m68000_0.change_ram16_calls(snowbros_getword,hyperpac_putword);
        //Sound CPU
        z80_0:=cpu_z80.create(4000000);
        z80_0.change_ram_calls(hyperpac_snd_getbyte,hyperpac_snd_putbyte);
        z80_0.init_sound(hyperpac_sound_act);
        //Sound Chips
        ym2151_0:=ym2151_chip.create(16000000 div 4,1);
        ym2151_0.change_irq_func(ym2151_snd_irq);
        oki_6295_0:=snd_okim6295.Create(16000000 div 16,OKIM6295_PIN7_HIGH,1);
      end;
end;
pandora_0:=pandora_gfx.create(0,true);
case main_vars.tipo_maquina of
    54:begin //Snowbros
        //pandora
        //cargar roms
        if not(roms_load16w(@rom,snowbros_rom)) then exit;
        //cargar sonido
        if not(roms_load(@mem_snd,snowbros_sound)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,snowbros_char)) then exit;
        convert_chars($1000,0);
        //DIP
        marcade.dswa:=$fe;
        marcade.dswb:=$ff;
        marcade.dswa_val:=@snowbros_dip_a;
        marcade.dswb_val:=@snowbros_dip_b;
    end;
    386:begin //Come Back Toto
        //cargar roms
        if not(roms_load16w(@rom,toto_rom)) then exit;
        ptemp:=@rom;
        for f:=0 to $3ffff do ptemp[f]:=bitswap8(ptemp[f],7,6,5,3,4,2,1,0);
        //cargar sonido
        if not(roms_load(@mem_snd,toto_sound)) then exit;
        ptemp:=@mem_snd;
        for f:=0 to $7fff do ptemp[f]:=bitswap8(ptemp[f],7,6,5,3,4,2,1,0);
        //convertir chars
        if not(roms_load(@memoria_temp,toto_char)) then exit;
        for f:=0 to $7ffff do memoria_temp[f]:=bitswap8(memoria_temp[f],7,6,5,3,4,2,1,0);
        convert_chars($1000,0);
        //DIP
        marcade.dswa:=$fe;
        marcade.dswb:=$ff;
        marcade.dswa_val:=@snowbros_dip_a;
        marcade.dswb_val:=@snowbros_dip_b;
    end;
    387:begin //Hyper Pacman
        //MCU
        mcs51_0:=cpu_mcs51.create(I8XC52,16000000);
        mcs51_0.change_io_calls(nil,nil,nil,nil,hyperpac_out_port0,hyperpac_out_port1,hyperpac_out_port2,nil);
        if not(roms_load(mcs51_0.get_rom_addr,hyperpac_mcu)) then exit;
        //cargar roms
        if not(roms_load16w(@rom,hyperpac_rom)) then exit;
        //cargar sonido
        if not(roms_load(@mem_snd,hyperpac_sound)) then exit;
        if not(roms_load(oki_6295_0.get_rom_addr,hyperpac_oki)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,hyperpac_char)) then exit;
        convert_chars($1800,1);
        //DIP
        marcade.dswa:=$fe;
        marcade.dswb:=$ff;
        marcade.dswa_val:=@snowbros_dip_a;
        marcade.dswb_val:=@snowbros_dip_b;
        semicom_prot_base:=$e000 shr 1;
    end;
end;
//final
reset_snowbros;
iniciar_snowbros:=true;
end;

end.
