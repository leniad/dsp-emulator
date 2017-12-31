unit mariobros_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,gfx_engine,samples,rom_engine,
     pal_engine,sound_engine;

procedure cargar_mario;

implementation
const
        mario_rom:array[0..4] of tipo_roms=(
        (n:'tma1-c-7f_f.7f';l:$2000;p:0;crc:$c0c6e014),(n:'tma1-c-7e_f.7e';l:$2000;p:$2000;crc:$94fb60d6),
        (n:'tma1-c-7d_f.7d';l:$2000;p:$4000;crc:$dcceb6c1),(n:'tma1-c-7c_f.7c';l:$1000;p:$f000;crc:$4a63d96b),());
        mario_pal:tipo_roms=(n:'tma1-c-4p_1.4p';l:$200;p:0;crc:$8187d286);
        mario_char:array[0..2] of tipo_roms=(
        (n:'tma1-v-3f.3f';l:$1000;p:0;crc:$28b0c42c),(n:'tma1-v-3j.3j';l:$1000;p:$1000;crc:$0c8cc04d),());
        mario_sprites:array[0..6] of tipo_roms=(
        (n:'tma1-v-7m.7m';l:$1000;p:0;crc:$22b7372e),(n:'tma1-v-7n.7n';l:$1000;p:$1000;crc:$4f3a1f47),
        (n:'tma1-v-7p.7p';l:$1000;p:$2000;crc:$56be6ccd),(n:'tma1-v-7s.7s';l:$1000;p:$3000;crc:$56f1d613),
        (n:'tma1-v-7t.7t';l:$1000;p:$4000;crc:$641f0008),(n:'tma1-v-7u.7u';l:$1000;p:$5000;crc:$7baf5309),());
        num_samples=29;
        mario_samples:array[0..(num_samples-1)] of tipo_nombre_samples=(
        (nombre:'mario_run.wav';restart:true),(nombre:'luigi_run.wav';restart:true),(nombre:'skid.wav';restart:true),(nombre:'bite_death.wav'),(nombre:'death.wav'),
        (nombre:'tune1.wav';restart:true),(nombre:'tune2.wav';restart:true),(nombre:'tune3.wav';restart:true),(nombre:'tune4.wav';restart:true),(nombre:'tune5.wav';restart:true),(nombre:'tune6.wav';restart:true),
        (nombre:'tune7.wav'),(nombre:'tune8.wav';restart:true),(nombre:'tune9.wav';restart:true),(nombre:'tune10.wav';restart:true),(nombre:'tune11.wav';restart:true),(nombre:'tune12.wav';restart:true),
        (nombre:'tune13.wav';restart:true),(nombre:'tune14.wav';restart:true),(nombre:'tune15.wav';restart:true),(nombre:'tune16.wav';restart:true),(nombre:'tune17.wav'),(nombre:'tune18.wav'),(nombre:'tune19.wav'),
        (nombre:'coin.wav'),(nombre:'insert_coin.wav'),(nombre:'turtle.wav'),(nombre:'crab.wav'),(nombre:'fly.wav'));
        //Dip
        mario_dip_a:array [0..4] of def_dip=(
        (mask:$3;name:'Lives';number:4;dip:((dip_val:$0;dip_name:'3'),(dip_val:$1;dip_name:'4'),(dip_val:$2;dip_name:'5'),(dip_val:$3;dip_name:'6'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Coinage';number:4;dip:((dip_val:$4;dip_name:'2C 1C'),(dip_val:$0;dip_name:'1C 1C'),(dip_val:$8;dip_name:'1C 2C'),(dip_val:$c;dip_name:'1C 3C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Bonus Life';number:4;dip:((dip_val:$0;dip_name:'20k Only'),(dip_val:$10;dip_name:'30k Only'),(dip_val:$20;dip_name:'40k Only'),(dip_val:$30;dip_name:'None'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Difficulty';number:4;dip:((dip_val:$0;dip_name:'Easy'),(dip_val:$80;dip_name:'Medium'),(dip_val:$40;dip_name:'Hard'),(dip_val:$c0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),());
var
 haz_nmi:boolean;
 gfx_bank,palette_bank,scroll_y,death_val,skid_val:byte;

procedure update_video_mario;inline;
var
  f:word;
  atrib:byte;
  x,y,color,nchar:word;
begin
//Poner chars
for f:=$3ff downto 0 do begin
 if gfx[0].buffer[f] then begin
    x:=31-(f mod 32);
    y:=31-(f div 32);
    atrib:=memoria[$7400+f];
    nchar:=atrib+(gfx_bank shl 8);
    color:=((atrib shr 2) and $38) or $40 or (palette_bank shl 7);
    put_gfx(x*8,y*8,nchar,color,1,0);
    gfx[0].buffer[f]:=false;
 end;
end;
scroll__y(1,2,scroll_y);
for f:=0 to $7f do begin
  if memoria[$7000+(f*4)]=0 then continue;
  nchar:=memoria[$7002+(f*4)];
  atrib:=memoria[$7001+(f*4)];
  color:=((atrib and $0f)+16*palette_bank) shl 3;
  x:=240-(memoria[$7003+(f*4)]-8);
  y:=memoria[$7000+(f*4)]+$f9;
  put_gfx_sprite(nchar,color,(atrib and $80)=0,(atrib and $40)=0,1);
  actualiza_gfx_sprite(x,y,2,1);
end;
actualiza_trozo_final(0,16,256,224,2);
end;

procedure eventos_mario;
begin
if main_vars.service1 then marcade.in0:=(marcade.in0 or $80) else marcade.in0:=(marcade.in0 and $7f);
if event.arcade then begin
  //P1
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 or $1) else marcade.in0:=(marcade.in0 and $Fe);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 or $2) else marcade.in0:=(marcade.in0 and $fd);
  if arcade_input.but0[0] then marcade.in0:=marcade.in0 or $10 else marcade.in0:=(marcade.in0 and $ef);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 or $20) else marcade.in0:=(marcade.in0 and $df);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 or $40) else marcade.in0:=(marcade.in0 and $bf);
  //P2
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 or $1) else marcade.in1:=(marcade.in1 and $Fe);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 or $2) else marcade.in1:=(marcade.in1 and $fd);
  if arcade_input.but0[1] then marcade.in1:=marcade.in1 or $10 else marcade.in1:=(marcade.in1 and $ef);
  if arcade_input.coin[0] then marcade.in1:=(marcade.in1 or $20) else marcade.in1:=(marcade.in1 and $df);
  if arcade_input.coin[1] then marcade.in1:=(marcade.in1 or $40) else marcade.in1:=(marcade.in1 and $bf);
end;
end;

procedure mario_principal;
var
  frame:single;
  f:word;
begin
init_controls(false,false,false,true);
frame:=z80_0.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to 263 do begin
    z80_0.run(frame);
    frame:=frame+z80_0.tframes-z80_0.contador;
    if f=239 then begin
      if haz_nmi then z80_0.change_nmi(PULSE_LINE);
      update_video_mario;
    end;
  end;
  eventos_mario;
  video_sync;
end;
end;

function mario_getbyte(direccion:word):byte;
begin
case direccion of
     $0..$77ff,$f000..$ffff:mario_getbyte:=memoria[direccion];
     $7c00:mario_getbyte:=marcade.in0;
     $7c80:mario_getbyte:=marcade.in1;
     $7f80:mario_getbyte:=marcade.dswa;
end;
end;

procedure mario_putbyte(direccion:word;valor:byte);
begin
if ((direccion<$6000) or (direccion>$efff)) then exit;
case direccion of
    $6000..$73ff:memoria[direccion]:=valor;
    $7400..$77ff:if memoria[direccion]<>valor then begin
                    gfx[0].buffer[direccion and $3ff]:=true;
                    memoria[direccion]:=valor;
                 end;
    $7c00:start_sample(0);
    $7c80:start_sample(1);
    $7d00:scroll_y:=valor+17;
    $7d80,$7e87:; //??
    $7e00:begin
            case (valor and $f) of
              1:start_sample(5); //pow
              2:start_sample(6); //tune sale vida
              3:start_sample(7); //salto mario
              4:start_sample(8); //tirar al agua un bicho
              5:start_sample(9); //tortuga boca abajo
              6:start_sample(10); //sonido agua del bicho
              7:start_sample(11); //vida extra
              8:start_sample(12); //tune presentacion cangrejos
              9:start_sample(13); //tune comenzar la partida
              10:start_sample(14); //tune presentacion tortugas
              11:start_sample(15); //tune game over
              12:start_sample(16); //tune bonus perfecto
              13:start_sample(17); //lanzar el ultimo bicho
              14:start_sample(18); //tune en bonus
              15:start_sample(19); //tune coin cojido en bonus
            end;
            case (valor shr 4) of
              1:start_sample(20);
              2,3:start_sample(21);
              4..7:start_sample(22);
              8..$f:start_sample(23);
            end;
          end;
    $7e80:if gfx_bank<>(valor and 1) then begin
            gfx_bank:=valor and 1;
            fillchar(gfx[0].buffer[0],$400,1);
          end;
    $7e82:main_screen.flip_main_screen:=(valor and 1)=0;
    $7e83:if palette_bank<>(valor and 1) then begin
            palette_bank:=valor and 1;
            fillchar(gfx[0].buffer[0],$400,1);
          end;
    $7e84:haz_nmi:=(valor and 1)<>0;
    $7e85:if (valor and 1)<>0 then copymemory(@memoria[$7000],@memoria[$6900],$400);
    $7f00..$7f07:case (direccion and 7) of
                      0:begin  //death cuando pasa de 0 a 1 mordisco, cuando pasa de 1 a 0 muerte
                          if ((death_val=0) and ((valor and 1)=1)) then start_sample(3);
                          if ((death_val=1) and ((valor and 1)=0)) then start_sample(4);
                          death_val:=valor and 1;
                        end;
                      1:if valor<>0 then start_sample(25); //get coin
                      2:; //NADA
                      3:if valor<>0 then start_sample(27);//crab sale
                      4:if valor<>0 then start_sample(26);//turtle sale
                      5:if valor<>0 then start_sample(28);//fly sale
                      6:if valor<>0 then start_sample(24); //coin sale
                      7:begin //skid cuando pasa de 1 a 0
                          if ((skid_val=1) and ((valor and 1)=0)) then start_sample(2);
                          skid_val:=valor and 1;
                        end;
                 end;
end;
end;

procedure mario_sound_update;
begin
  samples_update;
end;

//Main
procedure reset_mario;
begin
 z80_0.reset;
 reset_samples;
 reset_audio;
 marcade.in0:=0;
 marcade.in1:=0;
 haz_nmi:=false;
 gfx_bank:=0;
 palette_bank:=0;
 scroll_y:=0;
 death_val:=0;
 skid_val:=0;
end;

function iniciar_mario:boolean;
var
      colores:tpaleta;
      f:word;
      bit0,bit1,bit2:byte;
      memoria_temp:array[0..$5fff] of byte;
const
      pc_x:array[0..7] of dword=(7, 6, 5, 4, 3, 2, 1, 0);
      pc_y:array[0..7] of dword=(7*8, 6*8, 5*8, 4*8, 3*8, 2*8, 1*8, 0*8);
      ps_x:array[0..15] of dword=(0, 1, 2, 3, 4, 5, 6, 7,
			256*16*8+0, 256*16*8+1, 256*16*8+2, 256*16*8+3, 256*16*8+4, 256*16*8+5, 256*16*8+6, 256*16*8+7);
      ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8);
begin
iniciar_mario:=false;
iniciar_audio(false);
screen_init(1,256,256);
screen_mod_scroll(1,256,256,255,256,256,255);
screen_init(2,256,256,false,true);
iniciar_video(256,224);
//Main CPU
z80_0:=cpu_z80.create(4000000,264);
z80_0.change_ram_calls(mario_getbyte,mario_putbyte);
//cargar roms
if not(cargar_roms(@memoria[0],@mario_rom[0],'mario.zip',0)) then exit;
//samples
if load_samples('mario.zip',@mario_samples[0],num_samples) then z80_0.init_sound(mario_sound_update);
//convertir chars
if not(cargar_roms(@memoria_temp[0],@mario_char[0],'mario.zip',0)) then exit;
init_gfx(0,8,8,512);
gfx_set_desc_data(2,0,8*8,512*8*8,0);
convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,false);
//convertir sprites
if not(cargar_roms(@memoria_temp[0],@mario_sprites[0],'mario.zip',0)) then exit;
init_gfx(1,16,16,256);
gfx[1].trans[0]:=true;
gfx_set_desc_data(3,0,16*8,2*256*16*16,256*16*16,0);
convert_gfx(1,0,@memoria_temp[0],@ps_x[0],@ps_y[0],false,false);
//poner la paleta
if not(cargar_roms(@memoria_temp[0],@mario_pal,'mario.zip')) then exit;
for f:=0 to 511 do begin
    bit0:=(memoria_temp[f] shr 5) and 1;
    bit1:=(memoria_temp[f] shr 6) and 1;
    bit2:=(memoria_temp[f] shr 7) and 1;
    colores[f].r:=not($21*bit0+$47*bit1+$97*bit2);
    bit0:=(memoria_temp[f] shr 2) and 1;
    bit1:=(memoria_temp[f] shr 3) and 1;
    bit2:=(memoria_temp[f] shr 4) and 1;
    colores[f].g:=not($21*bit0+$47*bit1+$97*bit2);
    bit0:=(memoria_temp[f] shr 0) and 1;
    bit1:=(memoria_temp[f] shr 1) and 1;
    colores[f].b:=not($55*bit0+$aa*bit1);
end;
set_pal(colores,512);
//DIP
marcade.dswa:=0;
marcade.dswa_val:=@mario_dip_a;
//final
reset_mario;
iniciar_mario:=true;
end;

procedure Cargar_mario;
begin
llamadas_maquina.iniciar:=iniciar_mario;
llamadas_maquina.bucle_general:=mario_principal;
llamadas_maquina.reset:=reset_mario;
llamadas_maquina.fps_max:=59.185606;
end;

end.
