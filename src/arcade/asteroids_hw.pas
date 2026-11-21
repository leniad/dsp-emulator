unit asteroids_hw;

interface
uses rom_engine,samples;

function iniciar_as:boolean;

const
        as_rom:array[0..3] of tipo_roms=(
        (n:'035145-04e.ef2';l:$800;p:$6800;crc:$b503eaf7),(n:'035144-04e.h2';l:$800;p:$7000;crc:$25233192),
        (n:'035143-02.j2';l:$800;p:$7800;crc:$312caa02),(n:'035127-02.np3';l:$800;p:$5000;crc:$8b71fd9e));
        as_prom:array[0..1] of tipo_roms=((n:'034602-01.c8';l:$100;p:0;crc:$97953db8),());
        asteroids_samples:array[0..3] of tipo_nombre_samples=(
        (nombre:'explode1.wav'),(nombre:'explode2.wav'),(nombre:'explode3.wav'),());
        llander_rom:array[0..6] of tipo_roms=(
        (n:'034572-02.f1';l:$800;p:$6000;crc:$b8763eea),(n:'034571-02.de1';l:$800;p:$6800;crc:$77da4b2f),
        (n:'034570-01.c1';l:$800;p:$7000;crc:$2724e591),(n:'034569-02.b1';l:$800;p:$7800;crc:$72837a4e),
        (n:'034599-01.r3';l:$800;p:$4800;crc:$355a9371),(n:'034598-01.np3';l:$800;p:$5000;crc:$9c4ffa68),
        (n:'034597-01.m3';l:$800;p:$5800;crc:$ebb744f2));
        llander_prom:array[0..1] of tipo_roms=((n:'034602-01.c8';l:$100;p:0;crc:$97953db8),());

implementation
uses asteroids_hw_audio,m6502,main_engine,controls_engine,pal_engine,timer_engine,
     sound_engine,avg_dvg;

const
        asteroids_dip_a:array [0..4] of def_dip2=(
        (mask:3;name:'Lenguaje';number:4;val4:(0,1,2,3);name4:('English','German','French','Spanish')),
        (mask:4;name:'Lives';number:2;val2:(4,0);name2:('3','4')),
        (mask:8;name:'Center Mech';number:2;val2:(0,8);name2:('X 1','X 2')),
        (mask:$30;name:'Right Mech';number:4;val4:(0,$10,$20,$30);name4:('X 1','X 4','X 5','X 6')),
        (mask:$c0;name:'Coinage';number:4;val4:($c0,$80,$40,0);name4:('2C 1C','1C 1C','1C 2C','Free Play')));

var
  hay_samples:boolean;
  ram:array[0..1,0..$ff] of byte;
  ram_bank:byte;
  eventos_asteroids:procedure;

procedure eventos_as;
begin
if event.arcade then begin
  marcade.in0:=0;
  marcade.in1:=0;
  if arcade_input.but2[0] then marcade.in0:=marcade.in0 or 8;
  if arcade_input.but0[0] then marcade.in0:=marcade.in0 or $10;
  if arcade_input.coin[0] then marcade.in1:=marcade.in1 or 1;
  if arcade_input.coin[1] then marcade.in1:=marcade.in1 or 2;
  if arcade_input.start[0] then marcade.in1:=marcade.in1 or 8;
  if arcade_input.start[1] then marcade.in1:=marcade.in1 or $10;
  if arcade_input.but1[0] then marcade.in1:=marcade.in1 or $20;
  if arcade_input.right[0] then marcade.in1:=marcade.in1 or $40;
  if arcade_input.left[0] then marcade.in1:=marcade.in1 or $80;
end;
end;

procedure eventos_llander;
begin
if event.arcade then begin
  marcade.in0:=0;
  marcade.in1:=0;
  if arcade_input.start[0] then marcade.in1:=marcade.in1 or 1;
  if arcade_input.coin[0] then marcade.in1:=marcade.in1 or 2;
  if arcade_input.coin[1] then marcade.in1:=marcade.in1 or 4;
  //if arcade_input.coin[2] then marcade.in1:=marcade.in1 or 8;
  if arcade_input.but2[1] then marcade.in1:=marcade.in1 or $10;
  if arcade_input.but1[0] then marcade.in1:=marcade.in1 or $20;
  if arcade_input.right[0] then marcade.in1:=marcade.in1 or $40;
  if arcade_input.left[0] then marcade.in1:=marcade.in1 or $80;
end;
end;

procedure principal_as;
var
  frame:single;
  f:word;
begin
frame:=m6502_0.tframes;
while EmuStatus=EsRunning do begin
 for f:=0 to 299 do begin
    m6502_0.run(frame);
    frame:=frame+m6502_0.tframes-m6502_0.contador;
 end;
 eventos_asteroids;
 video_sync;
end;
end;

//Asteroids
function getbyte_as(direccion:word):byte;
var
  mascara:byte;
begin
direccion:=direccion and $7fff;
case direccion of
  0..$1ff,$4000..$47ff,$5000..$57ff,$6800..$7fff:getbyte_as:=memoria[direccion];
  $200..$2ff:getbyte_as:=ram[ram_bank,direccion and $ff];
  $300..$3ff:getbyte_as:=ram[1-ram_bank,direccion and $ff];
  $2001:getbyte_as:=(m6502_0.totalt and $100) shr 8;
  $2000,$2003..$2007:begin
                        mascara:=1 shl (direccion and 7);
                        if (marcade.in0 and mascara)<>0 then getbyte_as:=$80
                          else getbyte_as:=$7f;
                     end;
  $2002:if avgdvg_0.done_r<>0 then getbyte_as:=$7f
          else getbyte_as:=$80;
  $2400..$2407:begin
                  mascara:=1 shl (direccion and 7);
                  if (marcade.in1 and mascara)<>0 then getbyte_as:=$80
                    else getbyte_as:=$7f;
               end;
  $2800:getbyte_as:=$fc or ((marcade.dswa shr 6) and 3); //Coinage
  $2801:getbyte_as:=$fc or ((marcade.dswa shr 4) and 3); //Right Mech
  $2802:getbyte_as:=$fc or ((marcade.dswa shr 2) and 3); //Lives+Center Mech
  $2803:getbyte_as:=$fc or ((marcade.dswa shr 0) and 3); //Lenguaje
end;
end;

procedure putbyte_as(direccion:word;valor:byte);
begin
direccion:=direccion and $7fff;
case direccion of
  0..$1ff,$4000..$47ff:memoria[direccion]:=valor;
  $200..$2ff:ram[ram_bank,direccion and $ff]:=valor;
  $300..$3ff:ram[1-ram_bank,direccion and $ff]:=valor;
  $3000:avgdvg_0.go_w;
  $3200:ram_bank:=(valor and 4) shr 2;
  $3600:asteroid_explode_w(valor,hay_samples);
  $3a00:asteroid_thump_w(valor);
  $3c00..$3c05:asteroid_sounds_w(direccion and 7,valor);
  $5000..$57ff,$6800..$7fff:;
end;
end;

//Lunar Lander
function getbyte_llander(direccion:word):byte;
var
  mascara:byte;
begin
direccion:=direccion and $7fff;
case direccion of
  0..$1fff:getbyte_llander:=memoria[direccion and $ff];
  $2000:getbyte_llander:=(avgdvg_0.done_r and 1) or ((m6502_0.totalt and $100) shr 2) or $be;
  $2400..$2407:begin
                  mascara:=1 shl (direccion and 7);
                  if (marcade.in1 and mascara)<>0 then getbyte_llander:=$80
                    else getbyte_llander:=$7f;
               end;
  $2800:getbyte_llander:=$fe;//c or ((marcade.dswa shr 6) and $3); //Coinage
  $2801:getbyte_llander:=$fc;// or ((marcade.dswa shr 4) and $3); //Right Mech
  $2802:getbyte_llander:=$fc;// or ((marcade.dswa shr 2) and $3); //Lives+Center Mech
  $2803:getbyte_llander:=$fc;// or ((marcade.dswa shr 0) and $3); //Lenguaje
  $2c00:getbyte_llander:=analog.c[1].val[0];
  $4000..$7fff:getbyte_llander:=memoria[direccion];
end;
end;

procedure putbyte_llander(direccion:word;valor:byte);
begin
direccion:=direccion and $7fff;
case direccion of
  0..$1fff:memoria[direccion and $ff]:=valor;
  $3000:avgdvg_0.go_w;
  $3c00:;
  $3e00:;
  $4000..$47ff:memoria[direccion]:=valor;
  $4800..$7fff:;
end;
end;

procedure as_snd_nmi;
begin
  m6502_0.change_nmi(PULSE_LINE);
end;

procedure as_sound;
begin
  asteroid_sound_update(hay_samples);
end;

//Main
procedure reset_as;
begin
m6502_0.reset;
avgdvg_0.reset;
marcade.in0:=0;
marcade.in1:=0;
ram_bank:=0;
end;

function iniciar_as:boolean;
var
  colores:tpaleta;
  f:byte;
begin
llamadas_maquina.bucle_general:=principal_as;
llamadas_maquina.reset:=reset_as;
llamadas_maquina.fps_max:=12096000/4096/12/4;
llamadas_maquina.scanlines:=300;
iniciar_as:=false;
iniciar_audio(false);
screen_init(1,400,400,false,true);
iniciar_video(400,320);
//Main CPU
m6502_0:=cpu_m6502.create(1512000,TCPU_M6502);
case main_vars.tipo_maquina of
  23:begin //Asteroids
        m6502_0.change_ram_calls(getbyte_as,putbyte_as);
        m6502_0.init_sound(as_sound);
        asteroid_sound_init;
        //Timers
        timers.init(0,1512000/(12096000/4096/12),as_snd_nmi,nil,true);
        //cargar roms
        if not(roms_load(@memoria,as_rom)) then exit;
        //Vectors
        avgdvg_0:=avgdvg_chip.create(m6502_0.numero_cpu,1,$4000,40);
        if not(roms_load(avgdvg_0.get_prom_data,as_prom)) then exit;
        //samples
        hay_samples:=load_samples(asteroids_samples);
        //dip
        init_dips(1,asteroids_dip_a,$84);
        eventos_asteroids:=eventos_as;
      end;
  233:begin //Lunar Lander
        m6502_0.change_ram_calls(getbyte_llander,putbyte_llander);
        //m6502_0.init_sound(as_sound);
        //Timers
        timers.init(0,1512000/(12096000/4096/12),as_snd_nmi,nil,true);
        //cargar roms
        if not(roms_load(@memoria,llander_rom)) then exit;
        //Vectors
        avgdvg_0:=avgdvg_chip.create(m6502_0.numero_cpu,1,$4000,80);
        if not(roms_load(avgdvg_0.get_prom_data,llander_prom)) then exit;
        //samples
        //hay_samples:=load_samples('asteroid.zip',@as_samples,3);
        hay_samples:=false;
        //dip
        init_dips(1,asteroids_dip_a,$84);
        eventos_asteroids:=eventos_llander;
        init_analog(m6502_0.numero_cpu,m6502_0.clock);
        analog_1(100,10,$ff,0,true);
      end;
end;
//poner la paleta
for f:=0 to 15 do begin
  colores[f].r:=17*f;
  colores[f].g:=17*f;
  colores[f].b:=17*f;
end;
set_pal(colores,16);
//final
reset_as;
iniciar_as:=true;
end;

end.
