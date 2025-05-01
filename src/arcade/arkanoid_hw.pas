unit arkanoid_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     sound_engine,ay_8910,taito_68705;

function iniciar_arkanoid:boolean;

implementation
const
        arkanoid_rom:array[0..1] of tipo_roms=(
        (n:'a75-01-1.ic17';l:$8000;p:0;crc:$5bcda3b0),(n:'a75-11.ic16';l:$8000;p:$8000;crc:$eafd7191));
        arkanoid_mcu:tipo_roms=(n:'a75__06.ic14';l:$800;p:0;crc:$0be83647);
        arkanoid_tiles:array[0..2] of tipo_roms=(
        (n:'a75-03.ic64';l:$8000;p:0;crc:$038b74ba),(n:'a75-04.ic63';l:$8000;p:$8000;crc:$71fae199),
        (n:'a75-05.ic62';l:$8000;p:$10000;crc:$c76374e2));
        arkanoid_proms:array[0..2] of tipo_roms=(
        (n:'a75-07.ic24';l:$200;p:0;crc:$0af8b289),(n:'a75-08.ic23';l:$200;p:$200;crc:$abb002fb),
        (n:'a75-09.ic22';l:$200;p:$400;crc:$a7c6c277));
        //Dip
        arkanoid_dip_a:array [0..6] of def_dip2=(
        (mask:1;name:'Allow Continue';number:2;val2:(1,0);name2:('No','Yes')),
        (mask:2;name:'Flip Screen';number:2;val2:(2,0);name2:('Off','On')),
        (mask:8;name:'Difficulty';number:2;val2:(8,0);name2:('Easy','Hard')),
        (mask:$10;name:'Bonus Life';number:2;val2:($10,0);name2:('20K 60K 60K+','20K')),
        (mask:$20;name:'Lives';number:2;val2:($20,0);name2:('3','5')),
        (mask:$c0;name:'Coinage';number:4;val4:($40,$c0,$80,0);name4:('2C 1C','1C 1C','1C 2C','1C 6C')),());

var
  paddle_select,palettebank,gfxbank:byte;

procedure update_video_arkanoid;
var
  f,nchar:word;
  color,x,y,atrib:byte;
begin
for f:=0 to $3ff do begin
  if gfx[0].buffer[f] then begin
    x:=31-(f shr 5);
    y:=f and $1f;
    atrib:=memoria[$e000+(f*2)];
    color:=((atrib and $f8) shr 3)+palettebank;
    nchar:=memoria[$e001+(f*2)]+((atrib and 7) shl 8)+2048*gfxbank;
    put_gfx(x*8,y*8,nchar,color shl 3,1,0);
    gfx[0].buffer[f]:=false;
  end;
end;
actualiza_trozo(0,0,256,256,1,0,0,256,256,2);
//Sprites
for f:=0 to $f do begin
  atrib:=memoria[$e802+(f*4)];
  nchar:=memoria[$e803+(f*4)]+((atrib and 3) shl 8)+1024*gfxbank;
  color:=((atrib and $f8) shr 3)+palettebank;
  x:=memoria[$e801+(f*4)];
  y:=memoria[$e800+(f*4)];
  put_gfx_sprite_diff(2*nchar,color shl 3,false,false,0,8,0);
  put_gfx_sprite_diff(2*nchar+1,color shl 3,false,false,0,0,0);
  actualiza_gfx_sprite_size(x,y,2,16,8);
end;
actualiza_trozo_final(16,0,224,256,2);
end;

procedure eventos_arkanoid;
begin
if event.arcade then begin
  //P1
  if arcade_input.start[0] then marcade.in0:=marcade.in0 and $fe else marcade.in0:=marcade.in0 or 1;
  if arcade_input.start[1] then marcade.in0:=marcade.in0 and $fd else marcade.in0:=marcade.in0 or 2;
  if arcade_input.coin[0] then marcade.in0:=marcade.in0 or $10 else marcade.in0:=marcade.in0 and $ef;
  if arcade_input.coin[1] then marcade.in0:=marcade.in0 or $20 else marcade.in0:=marcade.in0 and $df;
  //p2
  if arcade_input.but0[0] then marcade.in1:=marcade.in1 and $fe else marcade.in1:=marcade.in1 or 1;
  if arcade_input.but0[1] then marcade.in1:=marcade.in1 and $fd else marcade.in1:=marcade.in1 or 2;
end;
end;

procedure principal_arkanoid;
var
  f:word;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
    for f:=0 to 263 do begin
        eventos_arkanoid;
        if f=240 then begin
          z80_0.change_irq(HOLD_LINE);
          update_video_arkanoid;
        end;
        z80_0.run(frame_main);
        frame_main:=frame_main+z80_0.tframes-z80_0.contador;
        //mcu
        taito_68705_0.run;
    end;
    video_sync;
end;
end;

function getbyte_arkanoid(direccion:word):byte;
begin
case direccion of
   0..$bfff,$e000..$efff:getbyte_arkanoid:=memoria[direccion];
   $c000..$cfff:getbyte_arkanoid:=memoria[$c000+(direccion and $7ff)];
   $d000..$dfff:case (direccion and $1f) of
                  1,3,5,7:getbyte_arkanoid:=ay8910_0.read;
                  8..$b:getbyte_arkanoid:=$ff;
                  $c..$f:getbyte_arkanoid:=byte(not(taito_68705_0.mcu_sent))*$80 or byte(not(taito_68705_0.main_sent))*$40 or marcade.in0;
                  $10..$17:getbyte_arkanoid:=marcade.in1;
                  $18..$1f:getbyte_arkanoid:=taito_68705_0.read;
                end;
   $f000..$ffff:getbyte_arkanoid:=0;
end;
end;

procedure putbyte_arkanoid(direccion:word;valor:byte);
begin
case direccion of
  0..$bfff:; //ROM
  $c000..$cfff:memoria[$c000+(direccion and $7ff)]:=valor;
  $d000..$dfff:case (direccion and $1f) of
                  0,2,4,6:ay8910_0.control(valor);
                  1,3,5,7:ay8910_0.write(valor);
                  8..$f:begin
                            paddle_select:=(valor and 4) shr 2;
                            if gfxbank<>((valor and $20) shr 5) then begin
                                fillchar(gfx[0].buffer,$400,1);
                                gfxbank:=(valor and $20) shr 5;
                            end;
                            if palettebank<>((valor and $40) shr 1) then begin
                                fillchar(gfx[0].buffer,$400,1);
                                palettebank:=(valor and $40) shr 1;
                            end;
                            if (valor and $80)=0 then taito_68705_0.change_reset(ASSERT_LINE)
                              else taito_68705_0.change_reset(CLEAR_LINE);
                         end;
                  $18..$1f:taito_68705_0.write(valor);
                end;
  $e000..$e7ff:if memoria[direccion]<>valor then begin
                    gfx[0].buffer[(direccion and $7ff) shr 1]:=true;
                    memoria[direccion]:=valor;
               end;
  $e800..$ffff:memoria[direccion]:=valor;
end;
end;

function arkanoid_read_prot:byte;
begin
  arkanoid_read_prot:=analog.c[0].x[paddle_select];
end;

procedure arkanoid_sound_update;
begin
  ay8910_0.update;
end;

function arkanoid_porta_r:byte;
begin
  arkanoid_porta_r:=$ff;
end;

function arkanoid_portb_r:byte;
begin
  arkanoid_portb_r:=marcade.dswa;
end;

//Main
procedure reset_arkanoid;
begin
z80_0.reset;
frame_main:=z80_0.tframes;
taito_68705_0.reset;
ay8910_0.reset;
marcade.in0:=$f;
marcade.in1:=$ff;
palettebank:=0;
gfxbank:=0;
paddle_select:=0;
end;

function iniciar_arkanoid:boolean;
const
    pc_x:array[0..7] of dword=(0, 1, 2, 3, 4, 5, 6, 7);
    pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
var
  colores:tpaleta;
  f:word;
  memoria_temp:array[0..$17fff] of byte;
begin
llamadas_maquina.bucle_general:=principal_arkanoid;
llamadas_maquina.reset:=reset_arkanoid;
llamadas_maquina.fps_max:=59.185608;
iniciar_arkanoid:=false;
iniciar_audio(false);
screen_init(1,256,256);
screen_init(2,256,256,false,true);
iniciar_video(224,256);
//Main CPU
z80_0:=cpu_z80.create(12000000 div 2,264);
z80_0.change_ram_calls(getbyte_arkanoid,putbyte_arkanoid);
z80_0.init_sound(arkanoid_sound_update);
if not(roms_load(@memoria,arkanoid_rom)) then exit;
//MCU CPU
taito_68705_0:=taito_68705p.create(3000000,264,ARKANOID);
taito_68705_0.arkanoid_call:=arkanoid_read_prot;
if not(roms_load(taito_68705_0.get_rom_addr,arkanoid_mcu)) then exit;
//Sound Chip
ay8910_0:=ay8910_chip.create(3000000,AY8910);
ay8910_0.change_io_calls(arkanoid_porta_r,arkanoid_portb_r,nil,nil);
//analog
init_analog(z80_0.numero_cpu,z80_0.clock);
analog_0(30,15,$7f,$ff,0,false,true,true);
//Cargar tiles
if not(roms_load(@memoria_temp,arkanoid_tiles)) then exit;
init_gfx(0,8,8,$1000);
gfx[0].trans[0]:=true;
gfx_set_desc_data(3,0,8*8,2*4096*8*8,4096*8*8,0);
convert_gfx(0,0,@memoria_temp,@pc_x,@pc_y,true,false);
//pal
if not(roms_load(@memoria_temp,arkanoid_proms)) then exit;
for f:=0 to $1ff do begin
    colores[f].r:=pal4bit(memoria_temp[f+0]);
    colores[f].g:=pal4bit(memoria_temp[f+$200]);
    colores[f].b:=pal4bit(memoria_temp[f+$400]);
end;
set_pal(colores,$200);
//Dip
marcade.dswa:=$fe;
marcade.dswa_val2:=@arkanoid_dip_a;
//final
iniciar_arkanoid:=true;
end;

end.
