unit atari_system1;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6502,m68000,main_engine,controls_engine,gfx_engine,rom_engine,pokey,
     pal_engine,sound_engine,slapstic,ym_2151,atari_mo;

procedure cargar_atari_sys1;

implementation
const
        //System ROMS
        atari_sys1_bios:array[0..2] of tipo_roms=(
        (n:'136032.205.l13';l:$4000;p:$0;crc:$88d0be26),(n:'136032.206.l12';l:$4000;p:$1;crc:$3c79ef05),());
        atari_sys1_char:tipo_roms=(n:'136032.104.f5';l:$2000;p:0;crc:$7a29dc07);
        peterpak_rom:array[0..8] of tipo_roms=(
        (n:'136028.142';l:$4000;p:$0;crc:$4f9fc020),(n:'136028.143';l:$4000;p:$1;crc:$9fb257cc),
        (n:'136028.144';l:$4000;p:$8000;crc:$50267619),(n:'136028.145';l:$4000;p:$8001;crc:$7b6a5004),
        (n:'136028.146';l:$4000;p:$10000;crc:$4183a67a),(n:'136028.147';l:$4000;p:$10001;crc:$14e2d97b),
        (n:'136028.148';l:$4000;p:$20000;crc:$230e8ba9),(n:'136028.149';l:$4000;p:$20001;crc:$0ff0c13a),());
        peterpak_sound:array[0..1] of tipo_roms=(
        (n:'136028.101';l:$4000;p:$8000;crc:$ff712aa2),(n:'136028.102';l:$4000;p:$c000;crc:$89ea21a1));
        peterpak_back:array[0..11] of tipo_roms=(
        (n:'136028.138';l:$8000;p:0;crc:$53eaa018),(n:'136028.139';l:$8000;p:$10000;crc:$354a19cb),
        (n:'136028.140';l:$8000;p:$20000;crc:$8d2c4717),(n:'136028.141';l:$8000;p:$30000;crc:$bf59ea19),
        (n:'136028.150';l:$8000;p:$80000;crc:$83362483),(n:'136028.151';l:$8000;p:$90000;crc:$6e95094e),
        (n:'136028.152';l:$8000;p:$a0000;crc:$9553f084),(n:'136028.153';l:$8000;p:$b0000;crc:$c2a9b028),
        (n:'136028.105';l:$4000;p:$104000;crc:$ac9a5a44),(n:'136028.108';l:$4000;p:$114000;crc:$51941e64),
        (n:'136028.111';l:$4000;p:$124000;crc:$246599f3),(n:'136028.114';l:$4000;p:$134000;crc:$918a5082));
        peterpak_proms:array[0..1] of tipo_roms=(
        (n:'136028.136';l:$200;p:0;crc:$861cfa36),(n:'136028.137';l:$200;p:$200;crc:$8507e5ea));
        //DIP
        atari_sys1_dip:array [0..10] of def_dip=(
        (mask:$3;name:'Lives';number:4;dip:((dip_val:$3;dip_name:'3'),(dip_val:$2;dip_name:'4'),(dip_val:$1;dip_name:'5'),(dip_val:$0;dip_name:'6'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Bonus Life';number:4;dip:((dip_val:$c;dip_name:'20k then every 60k'),(dip_val:$8;dip_name:'30k then every 70k'),(dip_val:$4;dip_name:'40k then every 80k'),(dip_val:$0;dip_name:'50k then every 90k'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$10;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$20;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$300;name:'Coin A';number:4;dip:((dip_val:$100;dip_name:'2 Coin - 1 Credit '),(dip_val:$300;dip_name:'1 Coin - 1 Credit'),(dip_val:$200;dip_name:'1 Coin - 2 Credit'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c00;name:'Coin B';number:4;dip:((dip_val:$0;dip_name:'3 Coin - 1 Credit '),(dip_val:$400;dip_name:'2 Coin - 3 Credit'),(dip_val:$c00;dip_name:'1 Coin - 3 Credit'),(dip_val:$800;dip_name:'1 Coin - 6 Credit'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$1000;name:'Difficulty';number:2;dip:((dip_val:$1000;dip_name:'Easy'),(dip_val:$0;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2000;name:'Flip Screen';number:2;dip:((dip_val:$2000;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4000;name:'Complete Invulnerability';number:2;dip:((dip_val:$4000;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8000;name:'Base Ship Invulnerability';number:2;dip:((dip_val:$8000;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        atari_sys1_mo_config:atari_motion_objects_config=(
        	gfxindex:1;               // index to which gfx system */
	        bankcount:8;              // number of motion object banks */
	        linked:true;              // are the entries linked? */
	        split:true;               // are the entries split? */
	        reverse:false;            // render in reverse order? */
	        swapxy:false;             // render in swapped X/Y order? */
	        nextneighbor:false;       // does the neighbor bit affect the next object? */
	        slipheight:0;             // pixels per SLIP entry (0 for no-slip) */
	        slipoffset:0;             // pixel offset for SLIPs */
	        maxperline:$38;             // maximum number of links to visit/scanline (0=all) */
	        palettebase:$100;         // base palette entry */
	        maxcolors:$100;           // maximum number of colors */
	        transpen:0;               // transparent pen index */
	        link_entry:(0,0,0,$003f); // mask for the link */
	        code_entry:(data_lower:(0,$ffff,0,0);data_upper:(0,0,0,0)); // mask for the code index */
	        color_entry:(data_lower:(0,$ff00,0,0);data_upper:(0,0,0,0)); // mask for the color */
	        xpos_entry:(0,0,$3fe0,0); // mask for the X position */
          ypos_entry:($3fe0,0,0,0); // mask for the Y position */
	        width_entry:(0,0,0,0); // mask for the width, in tiles*/
	        height_entry:($000f,0,0,0); // mask for the height, in tiles */
	        hflip_entry:($8000,0,0,0); // mask for the horizontal flip */
	        vflip_entry:(0,0,0,0);     // mask for the vertical flip */
	        priority_entry:(0,0,$8000,0); // mask for the priority */
	        neighbor_entry:(0,0,0,0); // mask for the neighbor */
	        absolute_entry:(0,0,0,0);// mask for absolute coordinates */
	        special_entry:(0,$ffff,0,0);  // mask for the special value */
	        specialvalue:$ffff;           // resulting value to indicate "special" */
        );

var
 rom:array[0..$3ffff] of word;
 slapstic_rom:array[0..3,0..$fff] of word;
 ram:array[0..$fff] of word;
 ram2:array[0..$7ffff] of word;
 ram3:array[0..$1fff] of word;

 eeprom_ram:array[0..$7ff] of byte;

 rom_bank,vblank:byte;
 sound_to_main_ready,main_to_sound_ready:boolean;
 sound_to_main_data,main_to_sound_data:byte;
 scroll_x,scroll_y,sound_reset_val:word;

procedure update_video_atari_sys1;
var
  f,color,x,y,nchar,atrib,atrib2:word;
  tile_bank:byte;
begin
for f:=0 to $7ff do begin
  x:=f mod 64;
  y:=f div 64;
  atrib:=ram3[($3000+(f*2)) shr 1];
  nchar:=atrib and $1ff;
	color:=(atrib shr 10) and $07;
	if (atrib and $2000)<>0 then put_gfx(x*8,y*8,nchar,color shl 2,1,0)
	  else put_gfx_trans(x*8,y*8,nchar,color shl 2,1,0);
end;
{atrib2:=ram2[$5f6f shr 1];
tile_bank:=atrib2 and $3;
for f:=0 to $fff do begin
  x:=f div 64;
  y:=f mod 64;
  atrib:=ram2[f];
  nchar:=((tile_bank*$1000)+(atrib and $fff)) xor $800;
	color:=$10+((atrib shr 12) and 7);
  put_gfx(x*8,y*8,nchar,(color shl 4)+256,2,1)
	//SET_TILE_INFO_MEMBER(0, code, color, (data >> 15) & 1);
end;}
scroll_x_y(2,3,scroll_x,scroll_y);
actualiza_trozo(0,0,512,256,1,0,0,512,256,3);
actualiza_trozo_final(0,0,336,240,3);
end;

procedure eventos_atari_sys1;
begin
if event.arcade then begin
  //P1
{  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $Fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $F7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  //P2
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $Fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $F7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);}
  //SYSTEM
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  //if arcade_input.start[0] then marcade.in2:=(marcade.in2 and $feff) else marcade.in2:=(marcade.in0 or $100);
  //if arcade_input.start[1] then marcade.in2:=(marcade.in2 and $fdff) else marcade.in2:=(marcade.in0 or $200);
end;
end;

procedure atari_sys1_principal;
var
  frame_m,frame_s:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
frame_s:=m6502_0.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to 2619 do begin
  //main
  m68000_0.run(frame_m);
  frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
  //sound
  m6502_0.run(frame_s);
  frame_s:=frame_s+m6502_0.tframes-m6502_0.contador;
  case f of
    2399:begin  //VBLANK
          update_video_atari_sys1;
          vblank:=$0;
          m68000_0.irq[4]:=ASSERT_LINE;
        end;
    2619:vblank:=$10;
  end;
 end;
 eventos_atari_sys1;
 video_sync;
end;
end;

function atari_sys1_getword(direccion:dword):word;
begin
case direccion of
    0..$7ffff:atari_sys1_getword:=rom[direccion shr 1];
    $80000..$87fff:begin //Slaptic!!
                      atari_sys1_getword:=slapstic_rom[rom_bank,(direccion and $1fff) shr 1];
                      rom_bank:=slapstic_0.slapstic_tweak((direccion and $7fff) shr 1);
                   end;
    $2e0000:; //atarisy1_int3state_r
    $400000..$401fff:atari_sys1_getword:=ram[(direccion and $1fff) shr 1];
    $900000..$9fffff:atari_sys1_getword:=ram2[(direccion and $fffff) shr 1];
    $a00000..$a03fff:atari_sys1_getword:=ram3[(direccion and $3fff) shr 1];
    $b00000..$b007ff:atari_sys1_getword:=buffer_paleta[(direccion and $7ff) shr 1];
    $f00000..$f00fff:atari_sys1_getword:=eeprom_ram[(direccion and $fff) shr 1]; //atari_eeprom_device, read
    $f20000..$f20007:atari_sys1_getword:=$ff; //trakball_r
	  $f40000..$f4001f:atari_sys1_getword:=0; //joystick_r
	  $f60000..$f60003:atari_sys1_getword:=$ff6f+vblank+(byte(main_to_sound_ready) shl 7); //READ_PORT("F60000")
	  $fc0000:begin //main_response_r
                sound_to_main_ready:=false;
	              m68000_0.irq[6]:=CLEAR_LINE;
	              atari_sys1_getword:=sound_to_main_data;
            end;
end;
end;

procedure cambiar_color(tmp_color,numero:word);inline;
var
  color:tcolor;
begin
  color.r:=pal4bit_i(tmp_color shr 8,tmp_color shr 12);
  color.g:=pal4bit_i(tmp_color shr 4,tmp_color shr 12);
  color.b:=pal4bit_i(tmp_color,tmp_color shr 12);
  set_pal_color(color,numero);
  //buffer_color[(numero shr 4) and $7f]:=true;
end;

procedure atari_sys1_putword(direccion:dword;valor:word);
var
  old:word;
begin
if direccion<$80000 then exit;
case direccion of
    $80000..$87fff:rom_bank:=slapstic_0.slapstic_tweak((direccion and $7fff) shr 1); //Slaptic!!
    $400000..$401fff:ram[(direccion and $1fff) shr 1]:=valor;
    $800000:scroll_x:=valor;
	  $820000:scroll_y:=valor;
	  $840000:; //atarisy1_priority_w
	  $860000:; //atarisy1_bankselect_w
	  $880000:; //watchdog
	  $8a0000:m68000_0.irq[4]:=CLEAR_LINE; //video_int_ack_w
	  $8c0000:; //unlock_write
    $900000..$9fffff:ram2[(direccion and $fffff) shr 1]:=valor;
    $a00000..$a03fff:ram3[(direccion and $3fff) shr 1]:=valor;
    $b00000..$b007ff:if buffer_paleta[(direccion and $7ff) shr 1]<>valor then begin
                          buffer_paleta[(direccion and $7ff) shr 1]:=valor;
                          cambiar_color(valor,(direccion and $7ff) shr 1);
                        end;
    $f00000..$f00fff:eeprom_ram[(direccion and $fff) shr 1]:=valor and $ff; //atari_eeprom_device write
	  $f40000..$f4001f:; //joystick_w
	  $f80000,$fe0000:begin //main_command_w
                        main_to_sound_data:=valor;
	                      main_to_sound_ready:=true;
	                      m6502_0.change_nmi(ASSERT_LINE)
                    end;
end;
end;

function atari_sys1_snd_getbyte(direccion:word):byte;
begin
case direccion of
     0..$fff:atari_sys1_snd_getbyte:=mem_snd[direccion];
     $1000..$100f:; //via6522_device, read
     $1801:atari_sys1_snd_getbyte:=ym2151_0.status;
     $1810:begin //sound_command_r
              main_to_sound_ready:=false;
              m6502_0.change_nmi(CLEAR_LINE);
	            atari_sys1_snd_getbyte:=main_to_sound_data;
           end;
     $1820:atari_sys1_snd_getbyte:=marcade.in2 or ($8*byte(main_to_sound_ready)) or ($10*byte(sound_to_main_ready)); //switch_6502_r
     $1870..$187f:pokey_0.read(direccion and $f);
     $4000..$ffff:atari_sys1_snd_getbyte:=mem_snd[direccion];
end;
end;

procedure atari_sys1_snd_putbyte(direccion:word;valor:byte);
begin
if direccion>$3fff then exit;
case direccion of
     0..$fff:mem_snd[direccion]:=valor;
     $1000..$100f:; //via6522_device, write
     $1800:ym2151_0.reg(valor);
     $1801:ym2151_0.write(valor);
     $1810:begin //sound_response_w
              sound_to_main_data:=valor;
	            sound_to_main_ready:=true;
              m68000_0.irq[6]:=ASSERT_LINE;
           end;
     $1824..$1825:; //led_w
     $1870..$187f:pokey_0.write(direccion and $f,valor);
end;
end;

procedure atari_sys1_sound_update;
begin
ym2151_0.update;
pokey_0.update;
//tms5220_update
end;

procedure ym2151_snd_irq(irqstate:byte);
begin
  m6502_0.change_irq(irqstate);
end;

//Main
procedure reset_atari_sys1;
begin
 m68000_0.reset;
 m6502_0.reset;
 YM2151_0.reset;
 pokey_0.reset;
 slapstic_0.reset;
 reset_audio;
 marcade.in0:=$FF00;
 marcade.in1:=$FF;
 marcade.in2:=$87;
 scroll_x:=0;
 rom_bank:=slapstic_0.current_bank;
 sound_to_main_ready:=false;
 main_to_sound_ready:=false;
 sound_to_main_data:=0;
 main_to_sound_data:=0;
 sound_reset_val:=1;
 vblank:=$40;
end;

function iniciar_atari_sys1:boolean;
var
  memoria_temp:array[0..$7ffff] of byte;
  f:dword;
const
  pc_x:array[0..7] of dword=(0, 1, 2, 3, 8, 9, 10, 11);
  pc_y:array[0..7] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16);
  ps_x:array[0..7] of dword=(0, 1, 2, 3, 4, 5, 6, 7);
  ps_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
begin
iniciar_atari_sys1:=false;
//if MessageDlg('Warning. This is a WIP driver, it''s not finished yet and bad things could happen!. Do you want to continue?', mtWarning, [mbYes]+[mbNo],0)=7 then exit;
iniciar_audio(false);
screen_init(1,512,256,true);
screen_init(2,512,512,true);
screen_mod_scroll(2,512,256,511,512,256,511);
screen_init(3,512,512,false,true);
iniciar_video(336,240);
//cargar BIOS
if not(cargar_roms16w(@rom,@atari_sys1_bios,'atarisy1.zip',0)) then exit;
//Cargar ROMS
if not(cargar_roms16w(@memoria_temp,@peterpak_rom,'peterpak.zip',0)) then exit;
copymemory(@rom[$10000 shr 1],@memoria_temp[$0],$8000*3);
//Slapstic
slapstic_0:=slapstic_type.create(107,true);
copymemory(@slapstic_rom[0,0],@memoria_temp[$20000],$2000);
copymemory(@slapstic_rom[1,0],@memoria_temp[$22000],$2000);
copymemory(@slapstic_rom[2,0],@memoria_temp[$24000],$2000);
copymemory(@slapstic_rom[3,0],@memoria_temp[$26000],$2000);
//cargar sonido
if not(roms_load(@mem_snd,@peterpak_sound,'peterpak.zip',sizeof(peterpak_sound))) then exit;
//Main CPU
m68000_0:=cpu_m68000.create(14318180 div 2,2620);
m68000_0.change_ram16_calls(atari_sys1_getword,atari_sys1_putword);
//Sound CPU
m6502_0:=cpu_m6502.create(14318180 div 8,2620,TCPU_M6502);
m6502_0.change_ram_calls(atari_sys1_snd_getbyte,atari_sys1_snd_putbyte);
m6502_0.init_sound(atari_sys1_sound_update);
//Sound Chips
ym2151_0:=ym2151_chip.create(14318180 div 4);
ym2151_0.change_irq_func(ym2151_snd_irq);
pokey_0:=pokey_chip.create(0,14318180 div 8);
//convertir chars
if not(roms_load(@memoria_temp,@atari_sys1_char,'atarisy1.zip',sizeof(atari_sys1_char))) then exit;
init_gfx(0,8,8,$200);
gfx[0].trans[0]:=true;
gfx_set_desc_data(2,0,16*8,0,4);
convert_gfx(0,0,@memoria_temp,@pc_x,@pc_y,false,false);
//convertir fondo
{if not(roms_load(@memoria_temp,@peterpak_back,'peterpak.zip',sizeof(peterpak_back))) then exit;
for f:=0 to $3ffff do memoria_temp[f]:=not(memoria_temp[f]);
init_gfx(1,8,8,$2000);
gfx_set_desc_data(4,0,8*8,$2000*8*8*3,$2000*8*8*2,$2000*8*8*1,$2000*8*8*0);
convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,false);}
//DIP
marcade.dswa:=$ffdf;
marcade.dswa_val:=@atari_sys1_dip;
//atari mo
atari_mo_0:=tatari_mo.create(@ram2[$5f80 shr 1],@ram2[$2000 shr 1],atari_sys1_mo_config,3,336+8,240+8);
//final
reset_atari_sys1;
iniciar_atari_sys1:=true;
end;

procedure Cargar_atari_sys1;
begin
llamadas_maquina.iniciar:=iniciar_atari_sys1;
llamadas_maquina.bucle_general:=atari_sys1_principal;
llamadas_maquina.reset:=reset_atari_sys1;
llamadas_maquina.fps_max:=59.922743;
end;

end.
