unit williams_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6809,m680x,main_engine,controls_engine,gfx_engine,dac,rom_engine,
     pal_engine,sound_engine,pia6821,timer_engine,file_engine;

procedure cargar_williams;

implementation
const
        //Defender
        defender_rom:array[0..10] of tipo_roms=(
        (n:'defend.1';l:$800;p:$0;crc:$c3e52d7e),(n:'defend.4';l:$800;p:$800;crc:$9a72348b),
        (n:'defend.2';l:$1000;p:$1000;crc:$89b75984),(n:'defend.3';l:$1000;p:$2000;crc:$94f51e9b),
        (n:'defend.9';l:$800;p:$3000;crc:$6870e8a5),(n:'defend.12';l:$800;p:$3800;crc:$f1f88938),
        (n:'defend.8';l:$800;p:$4000;crc:$b649e306),(n:'defend.11';l:$800;p:$4800;crc:$9deaf6d9),
        (n:'defend.7';l:$800;p:$5000;crc:$339e092e),(n:'defend.10';l:$800;p:$5800;crc:$a543b167),
        (n:'defend.6';l:$800;p:$9000;crc:$65f4efd1));
        defender_snd:tipo_roms=(n:'defend.snd';l:$800;p:$f800;crc:$fefd5b48);
        defender_proms:array[0..1] of tipo_roms=(
        (n:'decoder.2';l:$200;p:0;crc:$8dd98da5),(n:'decoder.3';l:$200;p:$200;crc:$c3f45f70));
        //Mayday
        mayday_rom:array[0..6] of tipo_roms=(
        (n:'mayday.c';l:$1000;p:$0;crc:$a1ff6e62),(n:'mayday.b';l:$1000;p:$1000;crc:$62183aea),
        (n:'mayday.a';l:$1000;p:$2000;crc:$5dcb113f),(n:'mayday.d';l:$1000;p:$3000;crc:$ea6a4ec8),
        (n:'mayday.e';l:$1000;p:$4000;crc:$0d797a3e),(n:'mayday.f';l:$1000;p:$5000;crc:$ee8bfcd6),
        (n:'mayday.g';l:$1000;p:$9000;crc:$d9c065e7));
        mayday_snd:tipo_roms=(n:'ic28-8.bin';l:$800;p:$f800;crc:$fefd5b48);
        //Colony7
        colony7_rom:array[0..8] of tipo_roms=(
        (n:'cs03.bin';l:$1000;p:$0;crc:$7ee75ae5),(n:'cs02.bin';l:$1000;p:$1000;crc:$c60b08cb),
        (n:'cs01.bin';l:$1000;p:$2000;crc:$1bc97436),(n:'cs06.bin';l:$800;p:$3000;crc:$318b95af),
        (n:'cs04.bin';l:$800;p:$3800;crc:$d740faee),(n:'cs07.bin';l:$800;p:$4000;crc:$0b23638b),
        (n:'cs05.bin';l:$800;p:$4800;crc:$59e406a8),(n:'cs08.bin';l:$800;p:$5000;crc:$3bfde87a),
        (n:'cs08.bin';l:$800;p:$5800;crc:$3bfde87a));
        colony7_snd:tipo_roms=(n:'cs11.bin';l:$800;p:$f800;crc:$6032293c);
        colony7_proms:array[0..1] of tipo_roms=(
        (n:'cs10.bin';l:$200;p:0;crc:$25de5d85),(n:'decoder.3';l:$200;p:$200;crc:$c3f45f70));
        //Dip
        colony7_dip_a:array [0..2] of def_dip=(
        (mask:$1;name:'Lives';number:2;dip:((dip_val:$0;dip_name:'2'),(dip_val:$1;dip_name:'3'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2;name:'Bonus At';number:2;dip:((dip_val:$0;dip_name:'20K/40K or 30K/50K'),(dip_val:$2;dip_name:'30K/50K or 40K/70K'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 pia1_timer,pia2_timer,ram_bank,sound_latch:byte;
 rom_data:array[0..$f,0..$fff] of byte;
 nvram:array[0..$ff] of byte;
 linea:word;
 palette:array[0..$f] of word;
 pal_lookup:array[0..$ff] of word;
 events_call:procedure;

procedure update_video_williams;
var
  x,pix:word;
  puntos:array[0..303] of word;
begin
if linea>247 then exit;
for x:=0 to 151 do begin
  pix:=memoria[linea+(x*256)];
  puntos[x*2]:=pal_lookup[palette[pix shr 4]];
  puntos[(x*2)+1]:=pal_lookup[palette[pix and $f]];
end;
putpixel(0+ADD_SPRITE,linea+ADD_SPRITE,304,@puntos[0],1);
end;

procedure eventos_defender;
begin
if event.arcade then begin
  //p1
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 or $1) else marcade.in0:=(marcade.in0 and $fe);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 or $2) else marcade.in0:=(marcade.in0 and $fd);
  if arcade_input.but2[0] then marcade.in0:=(marcade.in0 or $4) else marcade.in0:=(marcade.in0 and $fb);
  if arcade_input.but3[0] then marcade.in0:=(marcade.in0 or $8) else marcade.in0:=(marcade.in0 and $f7);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 or $10) else marcade.in0:=(marcade.in0 and $ef);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 or $20) else marcade.in0:=(marcade.in0 and $df);
  if arcade_input.but4[0] then marcade.in0:=(marcade.in0 or $40) else marcade.in0:=(marcade.in0 and $bf);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 or $80) else marcade.in0:=(marcade.in0 and $7f);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 or $1) else marcade.in1:=(marcade.in1 and $fe);
  //misc
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 or $10) else marcade.in2:=(marcade.in2 and $ef);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 or $20) else marcade.in2:=(marcade.in2 and $df);
end;
end;

procedure eventos_mayday;
begin
if event.arcade then begin
  //p1
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 or $1) else marcade.in0:=(marcade.in0 and $fe);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 or $2) else marcade.in0:=(marcade.in0 and $fd);
  if arcade_input.but2[0] then marcade.in0:=(marcade.in0 or $4) else marcade.in0:=(marcade.in0 and $fb);
  if arcade_input.but3[0] then marcade.in0:=(marcade.in0 or $8) else marcade.in0:=(marcade.in0 and $f7);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 or $10) else marcade.in0:=(marcade.in0 and $ef);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 or $20) else marcade.in0:=(marcade.in0 and $df);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 or $80) else marcade.in0:=(marcade.in0 and $7f);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 or $1) else marcade.in1:=(marcade.in1 and $fe);
  //misc
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 or $10) else marcade.in2:=(marcade.in2 and $ef);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 or $20) else marcade.in2:=(marcade.in2 and $df);
end;
end;

procedure eventos_colony7;
begin
if event.arcade then begin
  //p1
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 or $1) else marcade.in0:=(marcade.in0 and $fe);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 or $2) else marcade.in0:=(marcade.in0 and $fd);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 or $4) else marcade.in0:=(marcade.in0 and $fb);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 or $8) else marcade.in0:=(marcade.in0 and $f7);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 or $10) else marcade.in0:=(marcade.in0 and $ef);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 or $20) else marcade.in0:=(marcade.in0 and $df);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 or $80) else marcade.in0:=(marcade.in0 and $7f);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 or $40) else marcade.in0:=(marcade.in0 and $bf);
  if arcade_input.but2[0] then marcade.in1:=(marcade.in1 or $1) else marcade.in1:=(marcade.in1 and $fe);
  //misc
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 or $10) else marcade.in2:=(marcade.in2 and $ef);
end;
end;

procedure pia1_timer_off;
begin
pia6821_1.ca1_w(false);
timers.enabled(pia1_timer,false);
end;

procedure williams_principal;
var
  frame_m,frame_s:single;
begin
init_controls(false,false,false,true);
frame_m:=m6809_0.tframes;
frame_s:=m6800_0.tframes;
while EmuStatus=EsRuning do begin
  for linea:=0 to 259 do begin
    //main
    m6809_0.run(frame_m);
    frame_m:=frame_m+m6809_0.tframes-m6809_0.contador;
    //snd
    m6800_0.run(frame_s);
    frame_s:=frame_s+m6800_0.tframes-m6800_0.contador;
    update_video_williams;
    case linea of
         0,32,64,96,128,160,192,244:pia6821_1.cb1_w((linea and $20)<>0);
         239:begin
                  actualiza_trozo_final(12,7,292,240,1);
                  pia6821_1.ca1_w(true);
                  timers.enabled(pia1_timer,true);
             end;
    end;
  end;
  events_call;
  video_sync;
end;
end;

function williams_getbyte(direccion:word):byte;
begin
case direccion of
    0..$bfff,$d000..$ffff:williams_getbyte:=memoria[direccion];
    $c000..$cfff:case ram_bank of
                    0:case (direccion and $fff) of
                        $400..$7ff:williams_getbyte:=nvram[direccion and $ff];
                        $800..$bff:if (linea<$100) then williams_getbyte:=linea and $fc
	                                  else williams_getbyte:=$fc;
                        $c00..$fff:case (direccion and $1f) of
                                      0..3:williams_getbyte:=pia6821_1.read(direccion and $3);
                                      4..7:williams_getbyte:=pia6821_0.read(direccion and $3);
                                   end;
                      end;
                    1..$f:williams_getbyte:=rom_data[ram_bank-1,direccion and $fff];
                 end;
end;
end;

procedure williams_putbyte(direccion:word;valor:byte);
begin
case direccion of
  $0..$bfff:memoria[direccion]:=valor;
  $c000..$cfff:case ram_bank of
                  0:case (direccion and $fff) of
                        0..$3fe:case (direccion and $1f) of
                                  0..$f:palette[direccion and $f]:=valor;
                                  $10..$1f:; //m_cocktail
                                end;
                        $3ff:; //Watch dog
                        $400..$7ff:nvram[direccion and $ff]:=$f0 or valor;
                        $c00..$fff:case (direccion and $1f) of
                                      0..3:pia6821_1.write(direccion and $3,valor);
                                      4..7:pia6821_0.write(direccion and $3,valor);
                                   end;
                      end;
                  $1..$f:;
               end;
  $d000..$dfff:ram_bank:=valor and $f;
  $e000..$ffff:;
end;
end;

function williams_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7f:williams_snd_getbyte:=m6800_0.internal_ram[direccion];
  $400..$403,$8400..$8403:williams_snd_getbyte:=pia6821_2.read(direccion and $3);
  $b000..$ffff:williams_snd_getbyte:=mem_snd[direccion];
end;
end;

procedure williams_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7f:m6800_0.internal_ram[direccion]:=valor;
  $400..$403,$8400..$8403:pia6821_2.write(direccion and $3,valor);
  $b000..$ffff:;
end;
end;

procedure main_irq(state:boolean);
begin
  if (pia6821_1.irq_a_state or pia6821_1.irq_b_state) then m6809_0.change_irq(ASSERT_LINE)
      else m6809_0.change_irq(CLEAR_LINE);
end;

procedure snd_irq(state:boolean);
begin
  if (pia6821_2.irq_a_state or pia6821_2.irq_b_state) then m6800_0.change_irq(ASSERT_LINE)
      else m6800_0.change_irq(CLEAR_LINE);
end;

procedure snd_write_dac(valor:byte);
begin
  dac_0.data8_w(valor);
end;

procedure williams_sound;
begin
  dac_0.update;
end;

procedure pia2_sound_command;
begin
  pia6821_2.portb_w(sound_latch);
  if (sound_latch=$ff) then pia6821_2.cb1_w(false)
    else pia6821_2.cb1_w(true);
  timers.enabled(pia2_timer,false);
end;

procedure sound_write(valor:byte);
begin
  sound_latch:=valor or $c0;
  timers.enabled(pia2_timer,true);
end;

function get_in0:byte;
begin
  get_in0:=marcade.in0;
end;

function get_in1:byte;
begin
  get_in1:=marcade.in1;
end;

function get_in2:byte;
begin
  get_in2:=marcade.in2+marcade.dswa;
end;

//Mayday
function mayday_getbyte(direccion:word):byte;
begin
case direccion of
    0..$a192,$a195..$bfff,$d000..$ffff:mayday_getbyte:=memoria[direccion];
    $a193:mayday_getbyte:=memoria[$a190]; //Proteccion 1
    $a194:mayday_getbyte:=memoria[$a191]; //Proteccion 2
    $c000..$cfff:case ram_bank of
                    0:case (direccion and $fff) of
                        $400..$7ff:mayday_getbyte:=nvram[direccion and $ff];
                        $800..$bff:if (linea<$100) then mayday_getbyte:=linea and $fc
	                                  else mayday_getbyte:=$fc;
                        $c00..$fff:case (direccion and $1f) of
                                      0..3:mayday_getbyte:=pia6821_1.read(direccion and $3);
                                      4..7:mayday_getbyte:=pia6821_0.read(direccion and $3);
                                   end;
                      end;
                    1..$f:mayday_getbyte:=rom_data[ram_bank-1,direccion and $fff];
                 end;
end;
end;

//Main
procedure reset_williams;
begin
 m6809_0.reset;
 m6800_0.reset;
 pia6821_0.reset;
 pia6821_1.reset;
 pia6821_2.reset;
 dac_0.reset;
 reset_audio;
 marcade.in0:=0;
 marcade.in1:=0;
 marcade.in2:=0;
 ram_bank:=0;
 sound_latch:=0;
end;

function iniciar_williams:boolean;
const
  resistances:array[0..2] of integer=(1200,560,330);
var
  color:tcolor;
  f:word;
  memoria_temp:array[0..$ffff] of byte;
  rweights,gweights,bweights:array[0..2] of single;
  longitud:integer;
begin
iniciar_williams:=false;
iniciar_audio(false);
if main_vars.tipo_maquina=249 then main_screen.rol90_screen:=true;
screen_init(1,304,247,false,true);
iniciar_video(292,240);
//Main CPU
m6809_0:=cpu_m6809.Create(12000000 div 3 div 4,260,TCPU_MC6809E);
//Sound CPU
m6800_0:=cpu_m6800.create(3579545,260,TCPU_M6808);
m6800_0.change_ram_calls(williams_snd_getbyte,williams_snd_putbyte);
m6800_0.init_sound(williams_sound);
//Misc
pia6821_0:=pia6821_chip.Create;
pia6821_0.change_in_out(get_in0,get_in1,nil,nil);
pia6821_1:=pia6821_chip.Create;
pia6821_1.change_in_out(get_in2,nil,nil,sound_write);
pia6821_1.change_irq(main_irq,main_irq);
pia1_timer:=timers.init(m6809_0.numero_cpu,100,pia1_timer_off,nil,false);
pia6821_2:=pia6821_chip.Create;
pia6821_2.change_in_out(nil,nil,snd_write_dac,nil);
pia6821_2.change_irq(snd_irq,snd_irq);
pia2_timer:=timers.init(m6800_0.numero_cpu,100,pia2_sound_command,nil,false);
//Sound Chip
dac_0:=dac_chip.Create;
marcade.dswa:=0;
case main_vars.tipo_maquina of
  246:begin //defender
        m6809_0.change_ram_calls(williams_getbyte,williams_putbyte);
        //cargar roms
        if not(roms_load(@memoria_temp,defender_rom)) then exit;
        copymemory(@memoria[$d000],@memoria_temp[0],$3000);
        for f:=0 to 7 do copymemory(@rom_data[f,0],@memoria_temp[$3000+(f*$1000)],$1000);
        //roms sonido
        if not(roms_load(@mem_snd,defender_snd)) then exit;
        events_call:=eventos_defender;
        //Cargar NVRam
        if read_file_size(Directory.Arcade_nvram+'defender.nv',longitud) then read_file(Directory.Arcade_nvram+'defender.nv',@nvram,longitud);
  end;
  248:begin //mayday
        m6809_0.change_ram_calls(mayday_getbyte,williams_putbyte);
        //cargar roms
        if not(roms_load(@memoria_temp,mayday_rom)) then exit;
        copymemory(@memoria[$d000],@memoria_temp[0],$3000);
        for f:=0 to 7 do copymemory(@rom_data[f,0],@memoria_temp[$3000+(f*$1000)],$1000);
        //roms sonido
        if not(roms_load(@mem_snd,mayday_snd)) then exit;
        events_call:=eventos_mayday;
        //Cargar NVRam
        if read_file_size(Directory.Arcade_nvram+'mayday.nv',longitud) then read_file(Directory.Arcade_nvram+'mayday.nv',@nvram,longitud);
  end;
  249:begin //colony 7
        m6809_0.change_ram_calls(williams_getbyte,williams_putbyte);
        //cargar roms
        if not(roms_load(@memoria_temp,colony7_rom)) then exit;
        copymemory(@memoria[$d000],@memoria_temp[0],$3000);
        for f:=0 to 7 do copymemory(@rom_data[f,0],@memoria_temp[$3000+(f*$1000)],$1000);
        //roms sonido
        if not(roms_load(@mem_snd,colony7_snd)) then exit;
        events_call:=eventos_colony7;
        marcade.dswa:=$1;
        marcade.dswa_val:=@colony7_dip_a;
        //Cargar NVRam
        if read_file_size(Directory.Arcade_nvram+'colony7.nv',longitud) then read_file(Directory.Arcade_nvram+'colony7.nv',@nvram,longitud);
  end;
end;
//Palette
compute_resistor_weights(0,	255, -1.0,
			3,@resistances[0],@rweights[0],0,0,
			3,@resistances[0],@gweights[0],0,0,
			2,@resistances[1],@bweights[0],0,0);
for f:=0 to $ff do begin
    color.r:=combine_3_weights(@rweights[0],(f shr 0) and 1,(f shr 1) and 1,(f shr 2) and 1);
    color.g:=combine_3_weights(@gweights[0],(f shr 3) and 1,(f shr 4) and 1,(f shr 5) and 1);
    color.b:=combine_2_weights(@bweights[0],(f shr 6) and 1,(f shr 7) and 1);
    pal_lookup[f]:=convert_pal_color(color);
end;
//final
reset_williams;
iniciar_williams:=true;
end;

procedure close_williams;
begin
case main_vars.tipo_maquina of
  246:write_file(Directory.Arcade_nvram+'defender.nv',@nvram,$100);
  248:write_file(Directory.Arcade_nvram+'mayday.nv',@nvram,$100);
  249:write_file(Directory.Arcade_nvram+'colony7.nv',@nvram,$100);
end;
end;

procedure Cargar_williams;
begin
llamadas_maquina.iniciar:=iniciar_williams;
llamadas_maquina.bucle_general:=williams_principal;
llamadas_maquina.reset:=reset_williams;
llamadas_maquina.close:=close_williams;
llamadas_maquina.fps_max:=60.096154;
end;

end.
