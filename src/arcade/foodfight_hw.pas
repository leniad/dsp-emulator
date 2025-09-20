unit foodfight_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m68000,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     sound_engine,file_engine,pokey;

function iniciar_foodf:boolean;

implementation

const
        foodf_rom:array[0..7] of tipo_roms=(
        (n:'136020-301.8c';l:$2000;p:1;crc:$dfc3d5a8),(n:'136020-302.9c';l:$2000;p:0;crc:$ef92dc5c),
        (n:'136020-303.8d';l:$2000;p:$4001;crc:$64b93076),(n:'136020-204.9d';l:$2000;p:$4000;crc:$ea596480),
        (n:'136020-305.8e';l:$2000;p:$8001;crc:$e6cff1b1),(n:'136020-306.9e';l:$2000;p:$8000;crc:$95159a3e),
        (n:'136020-307.8f';l:$2000;p:$c001;crc:$17828dbb),(n:'136020-208.9f';l:$2000;p:$c000;crc:$608690c9));
        foodf_char:tipo_roms=(n:'136020-109.6lm';l:$2000;p:0;crc:$c13c90eb);
        foodf_sprites:array[0..1] of tipo_roms=(
        (n:'136020-110.4e';l:$2000;p:0;crc:$8870e3d6),(n:'136020-111.4d';l:$2000;p:$2000;crc:$84372edf));
        foodf_nvram:tipo_roms=(n:'foodf.nv';l:$100;p:0;crc:$a4186b13);
        //DIP
        foodf_dip:array [0..3] of def_dip2=(
        (mask:7;name:'Bonus Coins';number:8;val8:(0,5,2,1,6,3,4,7);name8:('None','1 for every 2','1 for every 4','1 for every 5','2 for every 4','Invalid','Invalid','Invalid')),
        (mask:8;name:'Coin A';number:2;val2:(0,8);name2:('1C 1C','1C 2C')),
        (mask:$30;name:'Coin B';number:4;val4:(0,$20,$10,$30);name4:('1C 1C','1C 4C','1C 5C','1C 6C')),
        (mask:$c0;name:'Coinage';number:4;val4:($80,0,$c0,$40);name4:('2C 1C','1C 1C','1C 2C','FreePlay')));

var
 rom:array[0..$ffff] of word;
 ram,ram2:array[0..$7ff] of word;
 sprite_ram:array[0..$7f] of word;
 bg_ram:array[0..$3ff] of word;
 nvram:array[0..$ff] of byte;
 rweights,gweights,bweights:array[0..2] of single;
 analog_data:array[0..7] of byte;
 analog_select:byte;

procedure update_video_foodf;
procedure draw_sprites(prio:byte);
var
  color,atrib,atrib2:word;
  nchar,x,y,f,pri:byte;
begin
for f:=$10 to $3f do begin
		atrib:=sprite_ram[f*2];
    pri:=(atrib shr 13) and 1;
    if pri<>prio then continue;
		atrib2:=sprite_ram[(f*2)+1];
		nchar:=atrib and $ff;
		color:=((atrib shr 8) and $1f) shl 2;
		x:=(atrib2 shr 8) and $ff;
		y:=($ff-atrib2-16) and $ff;
    put_gfx_sprite(nchar,color,((atrib shr 15) and 1)<>0,((atrib shr 14) and 1)<>0,1);
    actualiza_gfx_sprite(x,y,2,1);
end;
end;
var
  f,nchar,atrib:word;
  x,y,color:byte;
begin
for f:=0 to $3ff do begin
   atrib:=bg_ram[f];
   color:=(atrib shr 8) and $3f;
   if ((gfx[0].buffer[f]) or (buffer_color[color])) then begin
      x:=(f shr 5)+1;
      y:=f and $1f;
      nchar:=(atrib and $ff) or ((atrib shr 7) and $100);
      put_gfx((x*8) and $ff,y*8,nchar,color shl 2,1,0);
      gfx[0].buffer[f]:=false;
   end;
end;
actualiza_trozo(0,0,256,256,1,0,0,256,256,2);
draw_sprites(0);
draw_sprites(1);
actualiza_trozo_final(0,0,256,224,2);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
end;

procedure eventos_foodf;
begin
if main_vars.service1 then marcade.in0:=(marcade.in0 and $ff7f) else marcade.in0:=(marcade.in0 or $80);
if event.arcade then begin
  //system
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fffe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fffd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $fffb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $fff7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ffdf) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.but0[1] then marcade.in0:=(marcade.in0 and $ffbf) else marcade.in0:=(marcade.in0 or $40);
end;
end;

procedure foodf_principal;
var
  f:word;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
 for f:=0 to 258 do begin
    eventos_foodf;
    case f of
    0,64,128,192:m68000_0.irq[1]:=ASSERT_LINE;
    224:begin
          m68000_0.irq[2]:=ASSERT_LINE;
          update_video_foodf;
        end;
    end;
    //main
    m68000_0.run(frame_main);
    frame_main:=frame_main+m68000_0.tframes-m68000_0.contador;
 end;
 analog_data[1]:=analog.c[0].y[0];
 analog_data[5]:=analog.c[0].x[0];
 video_sync;
end;
end;

function foodf_getword(direccion:dword):word;
begin
case direccion of
    0..$3fffff:case (direccion and $1ffff) of
                  0..$ffff:foodf_getword:=rom[direccion shr 1];
                  $14000..$17fff:foodf_getword:=ram[(direccion and $fff) shr 1];
                  $18000..$1bfff:foodf_getword:=ram2[(direccion and $fff) shr 1];
                  $1c000..$1ffff:foodf_getword:=sprite_ram[(direccion and $ff) shr 1];
               end;
    $800000..$83ffff:foodf_getword:=bg_ram[(direccion and $7ff) shr 1];
    $900000..$93ffff:foodf_getword:=nvram[(direccion and $1ff) shr 1] and $ff;
    $940000..$97ffff:case (direccion and $1ffff) of
                  0..$3fff:foodf_getword:=$ff00+analog_data[analog_select and 7];
                  $8000..$bfff:foodf_getword:=marcade.in0;
                  $18000..$1bfff:foodf_getword:=$ffff;
               end;
    $a40000..$a7ffff:foodf_getword:=pokey_1.read((direccion and $1f) shr 1);
    $a80000..$abffff:foodf_getword:=pokey_0.read((direccion and $1f) shr 1);
    $ac0000..$afffff:foodf_getword:=pokey_2.read((direccion and $1f) shr 1);
end;
end;

procedure foodf_putword(direccion:dword;valor:word);

procedure cambiar_color(pos,data:word);
var
  color:tcolor;
  bit0,bit1,bit2:byte;
begin
		bit0:=(data shr 0) and 1;
		bit1:=(data shr 1) and 1;
		bit2:=(data shr 2) and 1;
		color.r:=combine_3_weights(@rweights[0], bit0, bit1, bit2);
		bit0:=(data shr 3) and 1;
		bit1:=(data shr 4) and 1;
		bit2:=(data shr 5) and 1;
		color.g:=combine_3_weights(@gweights[0], bit0, bit1, bit2);
		bit0:=(data shr 6) and 1;
		bit1:=(data shr 7) and 1;
		color.b:=combine_2_weights(@bweights[0], bit0, bit1);
    set_pal_color(color,pos);
    if pos<64 then buffer_color[pos]:=true;
end;

begin
case direccion of
    0..$3fffff:case (direccion and $1ffff) of
                  0..$ffff:; //ROM
                  $14000..$17fff:ram[(direccion and $fff) shr 1]:=valor;
                  $18000..$1bfff:ram2[(direccion and $fff) shr 1]:=valor;
                  $1c000..$1ffff:sprite_ram[(direccion and $ff) shr 1]:=valor;
               end;
    $800000..$83ffff:if bg_ram[(direccion and $7ff) shr 1]<>valor then begin
                        bg_ram[(direccion and $7ff) shr 1]:=valor;
                        gfx[0].buffer[(direccion and $7ff) shr 1]:=true;
                     end;
    $900000..$93ffff:nvram[(direccion and $1ff) shr 1]:=valor and $ff;
    $940000..$97ffff:case (direccion and $1ffff) of
                  $4000..$7fff:analog_select:=(direccion and 7) xor 3;
                  $8000..$bfff:begin
                                 if (valor and 4)=0 then m68000_0.irq[1]:=CLEAR_LINE;
                                 if (valor and 8)=0 then m68000_0.irq[2]:=CLEAR_LINE;
                               end;
                  $10000..$13fff:cambiar_color((direccion and $1ff) shr 1,valor);
                  $14000:; //read nvram recall
               end;
    $a40000..$a7ffff:pokey_1.write((direccion and $1f) shr 1,valor and $ff);
    $a80000..$abffff:pokey_0.write((direccion and $1f) shr 1,valor and $ff);
    $ac0000..$afffff:pokey_2.write((direccion and $1f) shr 1,valor and $ff);
end;
end;

function foodf_pot_r(pot:byte):byte;
begin
  foodf_pot_r:=(marcade.dswa shr pot) shl 7;
end;

procedure foodf_sound_update;
begin
pokey_0.update;
pokey_1.update;
pokey_2.update;
end;

//Main
procedure reset_foodf;
begin
 m68000_0.reset;
 frame_main:=m68000_0.tframes;
 pokey_0.reset;
 pokey_1.reset;
 pokey_2.reset;
 marcade.in0:=$ffff;
 analog_select:=0;
 fillchar(analog_data[0],8,$ff);
end;

procedure cerrar_foodf;
begin
write_file(Directory.Arcade_nvram+'foodf.nv',@nvram,$100);
end;

function iniciar_foodf:boolean;
var
  memoria_temp:array[0..$3ffff] of byte;
  longitud:integer;
const
  pc_x:array[0..7] of dword=(8*8+0, 8*8+1, 8*8+2, 8*8+3, 0, 1, 2, 3);
  ps_x:array[0..15] of dword=(8*16+0, 8*16+1, 8*16+2, 8*16+3, 8*16+4, 8*16+5, 8*16+6, 8*16+7,
                              0, 1, 2, 3, 4, 5, 6, 7);
  ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
                              8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8);
  resistances:array[0..2] of integer=(1000,470,220);
begin
llamadas_maquina.bucle_general:=foodf_principal;
llamadas_maquina.close:=cerrar_foodf;
llamadas_maquina.reset:=reset_foodf;
llamadas_maquina.scanlines:=259;
iniciar_foodf:=false;
iniciar_audio(false);
//Pantallas
screen_init(1,256,256,true);
screen_init(2,256,256,false,true);
iniciar_video(256,224);
//Main CPU
m68000_0:=cpu_m68000.create(12096000 div 2);
m68000_0.change_ram16_calls(foodf_getword,foodf_putword);
m68000_0.init_sound(foodf_sound_update);
if not(roms_load16w(@rom,foodf_rom)) then exit;
//Init Analog
init_analog(m68000_0.numero_cpu,m68000_0.clock);
analog_0(100,10,$7f,$ff,0,true);
//Sound Chips
pokey_0:=pokey_chip.create(trunc(12096000/2/10));
pokey_0.change_all_pot(foodf_pot_r);
pokey_1:=pokey_chip.create(trunc(12096000/2/10));
pokey_2:=pokey_chip.create(trunc(12096000/2/10));
//convertir chars
if not(roms_load(@memoria_temp,foodf_char)) then exit;
init_gfx(0,8,8,$200);
gfx_set_desc_data(2,0,8*16,0,4);
convert_gfx(0,0,@memoria_temp,@pc_x,@ps_y,false,false);
//convertir sprites
if not(roms_load(@memoria_temp,foodf_sprites)) then exit;
init_gfx(1,16,16,$100);
gfx[1].trans[0]:=true;
gfx_set_desc_data(2,0,8*32,$100*8*32,0);
convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,false);
//paleta
compute_resistor_weights(0,	255, -1.0,
			3,@resistances[0],@rweights,0,0,
			3,@resistances[0],@gweights,0,0,
			2,@resistances[1],@bweights,0,0);
//DIP
init_dips(1,foodf_dip,0);
//NVRAM
if read_file_size(Directory.Arcade_nvram+'foodf.nv',longitud) then read_file(Directory.Arcade_nvram+'foodf.nv',@nvram,longitud)
  else if not(roms_load(@nvram,foodf_nvram)) then exit;
//final
iniciar_foodf:=true;
end;

end.
