unit foodfight_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m68000,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     sound_engine,file_engine,pokey;

procedure cargar_foodf;

implementation
const
        foodf_rom:array[0..8] of tipo_roms=(
        (n:'136020-301.8c';l:$2000;p:1;crc:$dfc3d5a8),(n:'136020-302.9c';l:$2000;p:$0;crc:$ef92dc5c),
        (n:'136020-303.8d';l:$2000;p:$4001;crc:$64b93076),(n:'136020-204.9d';l:$2000;p:$4000;crc:$ea596480),
        (n:'136020-305.8e';l:$2000;p:$8001;crc:$e6cff1b1),(n:'136020-306.9e';l:$2000;p:$8000;crc:$95159a3e),
        (n:'136020-307.8f';l:$2000;p:$c001;crc:$17828dbb),(n:'136020-208.9f';l:$2000;p:$c000;crc:$608690c9),());
        foodf_char:tipo_roms=(n:'136020-109.6lm';l:$2000;p:0;crc:$c13c90eb);
        foodf_sprites:array[0..2] of tipo_roms=(
        (n:'136020-110.4e';l:$2000;p:0;crc:$8870e3d6),(n:'136020-111.4d';l:$2000;p:$2000;crc:$84372edf),());
        //foodf_prom:tipo_roms=(n:'136020-112.2p';l:$100;p:0;crc:$0aa962d6);
        //DIP
        foodf_dip:array [0..4] of def_dip=(
        (mask:$7;name:'Bonus Coins';number:5;dip:((dip_val:$0;dip_name:'None'),(dip_val:$5;dip_name:'1 for every 2'),(dip_val:$2;dip_name:'1 for every 4'),(dip_val:$1;dip_name:'1 for every 5'),(dip_val:$6;dip_name:'2 for every 4'),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Coin A';number:2;dip:((dip_val:$0;dip_name:'1C 1C'),(dip_val:$8;dip_name:'1C 2C'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Coin B';number:4;dip:((dip_val:$0;dip_name:'1C 1C'),(dip_val:$20;dip_name:'1C 4C'),(dip_val:$10;dip_name:'1C 5C'),(dip_val:$30;dip_name:'1C 6C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Coinage';number:4;dip:((dip_val:$80;dip_name:'2C 1C'),(dip_val:$0;dip_name:'1C 1C'),(dip_val:$c0;dip_name:'1C 2C'),(dip_val:$40;dip_name:'FreePlay'),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 rom:array[0..$ffff] of word;
 ram,ram2:array[0..$7ff] of word;
 sprite_ram:array[0..$7f] of word;
 bg_ram:array[0..$3ff] of word;
 nvram:array[0..$ff] of word;
 rweights,gweights,bweights:array[0..2] of single;
 analog_data:array[0..7] of byte;
 analog_select:byte;

procedure draw_sprites(prio:byte);
var
  color,atrib,atrib2:word;
  nchar,x,y,f,pri:byte;
begin
// draw the motion objects front-to-back
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

procedure update_video_foodf;
var
  f,color,x,y,nchar,atrib:word;
begin
for f:=$0 to $3ff do begin
   atrib:=bg_ram[f];
   color:=(atrib shr 8) and $3f;
   if ((gfx[0].buffer[f]) or (buffer_color[color])) then begin
      x:=f shr 5;
      y:=f and $1f;
      nchar:=(atrib and $ff) or ((atrib shr 7) and $100);;
      put_gfx(x*8,y*8,nchar,color shl 2,1,0);
      gfx[0].buffer[f]:=false;
   end;
end;
scroll__x(1,2,248);
draw_sprites(0);
draw_sprites(1);
actualiza_trozo_final(0,0,256,224,2);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure eventos_foodf;inline;
begin
if event.arcade then begin
  //system
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $Fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.but0[1] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
end;
end;

procedure foodf_principal;
var
  frame_m:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to 258 do begin
    //main
    m68000_0.run(frame_m);
    frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
    case f of
    31,95,159,224:m68000_0.irq[1]:=ASSERT_LINE;
    223:begin
          m68000_0.irq[2]:=ASSERT_LINE;
          update_video_foodf;
        end;
    end;
 end;
 analog_data[1]:=analog.y[0];
 analog_data[5]:=analog.x[0];
 eventos_foodf;
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
                  0..$3fff:foodf_getword:=$ff00+analog_data[analog_select and $7]; //(direccion and $7) - read analog
                  $8000..$bfff:foodf_getword:=marcade.in0; //read system
                  $18000..$1bfff:foodf_getword:=$ffff; //read write watch dog
               end;
    $a40000..$a7ffff:foodf_getword:=pokey_1.read((direccion and $1f) shr 1);
    $a80000..$abffff:foodf_getword:=pokey_0.read((direccion and $1f) shr 1);
    $ac0000..$afffff:foodf_getword:=pokey_2.read((direccion and $1f) shr 1);
end;
end;

procedure cambiar_color(pos,data:word);inline;
var
  color:tcolor;
  bit0,bit1,bit2:byte;
begin
  // red component */
		bit0:=(data shr 0) and $01;
		bit1:=(data shr 1) and $01;
		bit2:=(data shr 2) and $01;
		color.r:=combine_3_weights(@rweights[0], bit0, bit1, bit2);
		// green component */
		bit0:=(data shr 3) and $01;
		bit1:=(data shr 4) and $01;
		bit2:=(data shr 5) and $01;
		color.g:=combine_3_weights(@gweights[0], bit0, bit1, bit2);
		// blue component */
		bit0:=(data shr 6) and $01;
		bit1:=(data shr 7) and $01;
		color.b:=combine_2_weights(@bweights[0], bit0, bit1);
    set_pal_color(color,pos);
    if pos<64 then buffer_color[pos]:=true;
end;

procedure foodf_putword(direccion:dword;valor:word);
begin
case direccion of
    0..$3fffff:case (direccion and $1ffff) of
                  0..$ffff:exit;
                  $14000..$17fff:ram[(direccion and $fff) shr 1]:=valor;
                  $18000..$1bfff:ram2[(direccion and $fff) shr 1]:=valor;
                  $1c000..$1ffff:sprite_ram[(direccion and $ff) shr 1]:=valor;
               end;
    $800000..$83ffff:if bg_ram[(direccion and $7ff) shr 1]<>valor then begin
                        bg_ram[(direccion and $7ff) shr 1]:=valor;
                        gfx[0].buffer[(direccion and $7ff) shr 1]:=true;
                     end;
    $900000..$93ffff:nvram[(direccion and $1ff) shr 1]:=valor;
    $940000..$97ffff:case (direccion and $1ffff) of
                  $4000..$7fff:analog_select:=(direccion and $7) xor 3; //write analog
                  $8000..$bfff:begin
                                 if (valor and $4)=0 then m68000_0.irq[1]:=CLEAR_LINE;
                                 if (valor and $8)=0 then m68000_0.irq[2]:=CLEAR_LINE;
                               end;
                  $10000..$13fff:cambiar_color((direccion and $1ff) shr 1,valor); //palette write
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
 pokey_0.reset;
 pokey_1.reset;
 pokey_2.reset;
 reset_audio;
 marcade.in0:=$FF;
 analog_select:=0;
end;

function iniciar_foodf:boolean;
var
  memoria_temp:array[0..$3ffff] of byte;
  longitud:integer;
const
  pc_x:array[0..7] of dword=(8*8+0, 8*8+1, 8*8+2, 8*8+3, 0, 1, 2, 3);
  pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8 );
  ps_x:array[0..15] of dword=(8*16+0, 8*16+1, 8*16+2, 8*16+3, 8*16+4, 8*16+5, 8*16+6, 8*16+7, 0, 1, 2, 3, 4, 5, 6, 7);
  ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8, 8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8);
  resistances:array[0..2] of integer=(1000,470,220);
begin
iniciar_foodf:=false;
iniciar_audio(false);
//Pantallas
screen_init(1,256,256,true);
screen_mod_scroll(1,256,256,255,256,256,255);
screen_init(2,256,256,false,true);
iniciar_video(256,224);
//Main CPU
m68000_0:=cpu_m68000.create(trunc(12096000/2),259);
m68000_0.change_ram16_calls(foodf_getword,foodf_putword);
m68000_0.init_sound(foodf_sound_update);
//Init Analog
init_analog(m68000_0.numero_cpu,m68000_0.clock,100,10,$7f,$ff,0,true);
//Sound Chips
pokey_0:=pokey_chip.create(0,trunc(12096000/2/10));
pokey_0.change_pot(foodf_pot_r,foodf_pot_r,foodf_pot_r,foodf_pot_r,foodf_pot_r,foodf_pot_r,foodf_pot_r,foodf_pot_r);
pokey_1:=pokey_chip.create(1,trunc(12096000/2/10));
pokey_2:=pokey_chip.create(2,trunc(12096000/2/10));
//cargar roms
if not(cargar_roms16w(@rom[0],@foodf_rom[0],'foodf.zip',0)) then exit;
//convertir chars
if not(cargar_roms(@memoria_temp[0],@foodf_char,'foodf.zip')) then exit;
init_gfx(0,8,8,$200);
gfx_set_desc_data(2,0,8*16,0,4);
convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,false);
//convertir sprites
if not(cargar_roms(@memoria_temp[0],@foodf_sprites[0],'foodf.zip',0)) then exit;
init_gfx(1,16,16,$100);
gfx[1].trans[0]:=true;
gfx_set_desc_data(2,0,8*32,$100*8*32,0);
convert_gfx(1,0,@memoria_temp[0],@ps_x[0],@ps_y[0],false,false);
//paleta
compute_resistor_weights(0,	255, -1.0,
			3,@resistances[0],@rweights[0],0,0,
			3,@resistances[0],@gweights[0],0,0,
			2,@resistances[1],@bweights[0],0,0);
//DIP
marcade.dswa:=$0;
marcade.dswa_val:=@foodf_dip;
//NVRAM
if read_file_size(Directory.Arcade_nvram+'foodf.nv',longitud) then read_file(Directory.Arcade_nvram+'foodf.nv',@nvram[0],longitud);
//final
reset_foodf;
iniciar_foodf:=true;
end;

procedure cerrar_foodf;
begin
write_file(Directory.Arcade_nvram+'foodf.nv',@nvram[0],$200);
end;

procedure Cargar_foodf;
begin
llamadas_maquina.iniciar:=iniciar_foodf;
llamadas_maquina.bucle_general:=foodf_principal;
llamadas_maquina.close:=cerrar_foodf;
llamadas_maquina.reset:=reset_foodf;
end;

end.
