unit asteroids_hw;

interface
uses asteroids_hw_audio,m6502,main_engine,controls_engine,gfx_engine,
     timer_engine,samples,rom_engine,pal_engine,sound_engine;

function iniciar_as:boolean;

implementation
const
        as_rom:array[0..3] of tipo_roms=(
        (n:'035145-04e.ef2';l:$800;p:$6800;crc:$b503eaf7),(n:'035144-04e.h2';l:$800;p:$7000;crc:$25233192),
        (n:'035143-02.j2';l:$800;p:$7800;crc:$312caa02),(n:'035127-02.np3';l:$800;p:$5000;crc:$8b71fd9e));
        as_samples:array[0..2] of tipo_nombre_samples=((nombre:'explode1.wav'),
        (nombre:'explode2.wav'),(nombre:'explode3.wav'));
        asteroids_dip_a:array [0..5] of def_dip=(
        (mask:$3;name:'Lenguaje';number:4;dip:((dip_val:$0;dip_name:'English'),(dip_val:$1;dip_name:'German'),(dip_val:$2;dip_name:'French'),(dip_val:$3;dip_name:'Spanish'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Lives';number:2;dip:((dip_val:$4;dip_name:'3'),(dip_val:$0;dip_name:'4'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Center Mech';number:2;dip:((dip_val:$0;dip_name:'X 1'),(dip_val:$8;dip_name:'X 2'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Right Mech';number:4;dip:((dip_val:$0;dip_name:'X 1'),(dip_val:$10;dip_name:'X 4'),(dip_val:$20;dip_name:'X 5'),(dip_val:$30;dip_name:'X 6'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Coinage';number:4;dip:((dip_val:$c0;dip_name:'2C 1C'),(dip_val:$80;dip_name:'1C 1C'),(dip_val:$40;dip_name:'1C 2C'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),(),(),(),(),(),(),(),())),());
        llander_rom:array[0..6] of tipo_roms=(
        (n:'034572-02.f1';l:$800;p:$6000;crc:$b8763eea),(n:'034571-02.de1';l:$800;p:$6800;crc:$77da4b2f),
        (n:'034570-01.c1';l:$800;p:$7000;crc:$2724e591),(n:'034569-02.b1';l:$800;p:$7800;crc:$72837a4e),
        (n:'034599-01.r3';l:$800;p:$4800;crc:$355a9371),(n:'034598-01.np3';l:$800;p:$5000;crc:$9c4ffa68),
        (n:'034597-01.m3';l:$800;p:$5800;crc:$503f992e));

var
  hay_samples,dibujar:boolean;
  ram:array[0..1,0..$ff] of byte;
  x_actual,y_actual:integer;
  ram_bank:byte;
  linea:word;

procedure update_video_as;
var
  color,posicion,opcode:word;
  istack:array[0..3] of word;
  i,iscale,x,y,dx,dy,xa_d,ya_d:integer;
  pila:byte;
  salir,draw:boolean;
begin
fill_full_screen(1,0);
pila:=0;
posicion:=$4000;
salir:=false;
iscale:=0;
while not(salir) do begin
  opcode:=(memoria[posicion+1] shl 8) or memoria[posicion];
  posicion:=posicion+2;
  draw:=false;
  case (opcode and $f000) of
    0,$b000:salir:=true; //halt
    $1000,$2000,$3000,$4000,$5000,$6000,$7000,$8000,$9000:begin //vectores largos
            i:=((opcode shr 12)+iscale) and $f; // Scale factor */
            if i>9 then i:=-1;
            y:=opcode and $3ff;
            dy:=y shr (9-i);
            if (opcode and $400)<>0 then dy:=-dy; // Y sign bit */
            opcode:=(memoria[posicion+1] shl 8) or memoria[posicion];
            posicion:=posicion+2; // get second half of instruction */
            x:=opcode and $3ff;
            dx:=x shr (9-i); // Adjust for both scale factors *
            if (opcode and $400)<>0 then dx:=-dx; // X sign bit */
            color:=(opcode shr 12) and $ff;
            x:=x_actual;
            y:=y_actual;
            x_actual:=x_actual+dx;
            y_actual:=y_actual+dy;
            draw:=color<>0;
    end;
    $a000:begin //Posicion del haz y factor de escalado
            y_actual:=opcode and $fff; // Lower 12 bits are Y position */
            opcode:=(memoria[posicion+1] shl 8) or memoria[posicion];
            posicion:=posicion+2; // get second half of instruction */
            x_actual:=opcode and $fff; // Lower 12 bits are X position */
            iScale:=(opcode and $f000) shr 12;
            if (opcode and $8000)<>0 then iScale:=iScale-16; // divisor = negative shift
          end;
    $c000:begin  //Llamada subrutina
            if ((opcode and $1fff)=0) then salir:=true// Address of 0 same as HALT */
              else begin
                    pila:=(pila+1) and $f;
                    iStack[pila and 3]:=posicion; // push current position */
                    posicion:=$4000+(opcode and $1fff)*2;
              end;
          end;
    $d000:begin //Vuelta de subrutina
            posicion:=iStack[pila and 3];
            pila:=(pila-1) and $f;
          end;
    $e000:begin //Saltar a posicion
            if ((opcode and $1fff)=0) then salir:=true // Address of 0 same as HALT */
              else posicion:=$4000+(opcode and $1fff)*2;
          end;
    $f000:begin //vector corto
            i:=((opcode shr 2) and $2)+((opcode shr 11) and $1);
            i:=((iScale+i) and $f);
            if i>7 then i:=-1;
            color:=((opcode shr 4) and $F);
            x:=(opcode and 3) shl 8;
            dx:=x shr (7-i);
            if (opcode and 4)<>0 then dx:=-dx;
            y:=opcode and $300;
            dy:=y shr (7-i);
            if (opcode and $400)<>0 then dy:=-dy;
            x:=x_actual;
            y:=y_actual;
            x_actual:=x_actual+dx;
            y_actual:=y_actual+dy;
            draw:=color<>0;
          end;
  end;
  //Resolucion pantalla 400x320, resolucion real max 1024x1024
  if draw then begin
    if x>1024 then x:=400
      else if x<0 then x:=0
        else x:=trunc(x/2.56);
    if x_actual>1024 then xa_d:=400
      else if x_actual<0 then xa_d:=0
        else xa_d:=trunc(x_actual/2.56);
    if y>1024 then y:=400
      else if y<0 then y:=0
        else y:=trunc((1024-y)/2.56);
    if y_actual>1024 then ya_d:=0
      else if y_actual<0 then ya_d:=400
        else ya_d:=trunc((1024-y_actual)/2.56);
    draw_line(x+ADD_SPRITE,y+ADD_SPRITE,xa_d+ADD_SPRITE,ya_d+ADD_SPRITE,color,1);
  end;
end;
dibujar:=false;
actualiza_trozo_final(0,40,400,320,1);
end;

procedure eventos_as;
begin
if event.arcade then begin
  if arcade_input.but2[0] then marcade.in0:=marcade.in0 or $8 else marcade.in0:=marcade.in0 and $f7;
  if arcade_input.but0[0] then marcade.in0:=marcade.in0 or $10 else marcade.in0:=marcade.in0 and $ef;
  if arcade_input.coin[0] then marcade.in1:=marcade.in1 or 1 else marcade.in1:=marcade.in1 and $fe;
  if arcade_input.coin[1] then marcade.in1:=marcade.in1 or 2 else marcade.in1:=marcade.in1 and $fd;
  if arcade_input.start[0] then marcade.in1:=marcade.in1 or 8 else marcade.in1:=marcade.in1 and $f7;
  if arcade_input.start[1] then marcade.in1:=marcade.in1 or $10 else marcade.in1:=marcade.in1 and $ef;
  if arcade_input.but1[0] then marcade.in1:=marcade.in1 or $20 else marcade.in1:=marcade.in1 and $df;
  if arcade_input.right[0] then marcade.in1:=marcade.in1 or $40 else marcade.in1:=marcade.in1 and $bf;
  if arcade_input.left[0] then marcade.in1:=marcade.in1 or $80 else marcade.in1:=marcade.in1 and $7F;
end;
end;

procedure principal_as;
var
  frame:single;
begin
init_controls(false,false,false,true);
frame:=m6502_0.tframes;
while EmuStatus=EsRuning do begin
 for linea:=0 to 299 do begin
    m6502_0.run(frame);
    frame:=frame+m6502_0.tframes-m6502_0.contador;
    if ((linea=282) and dibujar) then update_video_as;
 end;
 eventos_as;
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
  $2001:getbyte_as:=((trunc(linea*m6502_0.tframes)+m6502_0.contador) and $100) shr 8;
  $2000,$2002..$2007:begin
                        mascara:=1 shl (direccion and $7);
                        if (marcade.in0 and mascara)<>0 then getbyte_as:=$80
                          else getbyte_as:=$7f;
                     end;
  $2400..$2407:begin
                  mascara:=1 shl (direccion and $7);
                  if (marcade.in1 and mascara)<>0 then getbyte_as:=$80
                    else getbyte_as:=$7f;
               end;
  $2800:getbyte_as:=$fc or ((marcade.dswa shr 6) and $3); //Coinage
  $2801:getbyte_as:=$fc or ((marcade.dswa shr 4) and $3); //Right Mech
  $2802:getbyte_as:=$fc or ((marcade.dswa shr 2) and $3); //Lives+Center Mech
  $2803:getbyte_as:=$fc or ((marcade.dswa shr 0) and $3); //Lenguaje
end;
end;

procedure putbyte_as(direccion:word;valor:byte);
begin
direccion:=direccion and $7fff;
if direccion>$4fff then exit;
case direccion of
  0..$1ff:memoria[direccion]:=valor;
  $200..$2ff:ram[ram_bank,direccion and $ff]:=valor;
  $300..$3ff:ram[1-ram_bank,direccion and $ff]:=valor;
  $3200:ram_bank:=(valor and 4) shr 2;
  $3600:asteroid_explode_w(valor,hay_samples);
  $3a00:asteroid_thump_w(valor);
  $3c00..$3c05:asteroid_sounds_w(direccion and $7,valor);
  $4000..$47ff:begin
                  memoria[direccion]:=valor;
                  dibujar:=true;
               end;
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
  $2000:getbyte_llander:=$bf or (((trunc(linea*m6502_0.tframes)+m6502_0.contador) and $100) shr 2);
  $2400..$2407:begin
                  mascara:=1 shl (direccion and $7);
                  if ($50 and mascara)<>0 then getbyte_llander:=$80
                    else getbyte_llander:=$7f;
               end;
  $2800:getbyte_llander:=$fe;//c or ((marcade.dswa shr 6) and $3); //Coinage
  $2801:getbyte_llander:=$fc;// or ((marcade.dswa shr 4) and $3); //Right Mech
  $2802:getbyte_llander:=$fc;// or ((marcade.dswa shr 2) and $3); //Lives+Center Mech
  $2803:getbyte_llander:=$fc;// or ((marcade.dswa shr 0) and $3); //Lenguaje
  $2c00:getbyte_llander:=0;
  $4000..$7fff:getbyte_llander:=memoria[direccion];
end;
end;

procedure putbyte_llander(direccion:word;valor:byte);
begin
direccion:=direccion and $7fff;
if direccion>$4fff then exit;
case direccion of
  0..$1fff:memoria[direccion and $ff]:=valor;
  $3c00:;
  $3e00:;
  $4000..$47ff:begin
                  memoria[direccion]:=valor;
                  dibujar:=true;
               end;
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
reset_samples;
marcade.in0:=0;
marcade.in1:=0;
x_actual:=0;
y_actual:=0;
ram_bank:=0;
dibujar:=true;
end;

function iniciar_as:boolean;
var
  colores:tpaleta;
  f:byte;
begin
llamadas_maquina.bucle_general:=principal_as;
llamadas_maquina.reset:=reset_as;
llamadas_maquina.fps_max:=12096000/4096/12/4;
iniciar_as:=false;
iniciar_audio(false);
screen_init(1,400,400,false,true);
iniciar_video(400,320);
//Main CPU
m6502_0:=cpu_m6502.create(1512000,300,TCPU_M6502);
case main_vars.tipo_maquina of
  23:begin //Asteroids
        m6502_0.change_ram_calls(getbyte_as,putbyte_as);
        m6502_0.init_sound(as_sound);
        asteroid_sound_init;
        //Timers
        timers.init(0,1512000/(12096000/4096/12),as_snd_nmi,nil,true);
        //cargar roms
        if not(roms_load(@memoria,as_rom)) then exit;
        //samples
        hay_samples:=load_samples(as_samples);
        //dip
        marcade.dswa:=$84;
        marcade.dswa_val:=@asteroids_dip_a;
      end;
  233:begin //Lunar Lander
        m6502_0.change_ram_calls(getbyte_llander,putbyte_llander);
        //m6502_0.init_sound(as_sound);
        //Timers
        timers.init(0,1512000/(12096000/4096/12),as_snd_nmi,nil,true);
        //cargar roms
        if not(roms_load(@memoria,llander_rom)) then exit;
        //samples
        //hay_samples:=load_samples('asteroid.zip',@as_samples,3);
        //dip
        marcade.dswa:=$84;
        marcade.dswa_val:=@asteroids_dip_a;
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
