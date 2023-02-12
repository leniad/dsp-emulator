unit gauntlet_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6502,m68000,main_engine,controls_engine,gfx_engine,rom_engine,pokey,
     pal_engine,sound_engine,slapstic,ym_2151,atari_mo,file_engine;

function iniciar_gauntlet:boolean;

implementation
const
        gauntlet_rom:array[0..5] of tipo_roms=(
        (n:'136041-507.9a';l:$8000;p:0;crc:$8784133f),(n:'136041-508.9b';l:$8000;p:$1;crc:$2843bde3),
        (n:'136037-205.10a';l:$4000;p:$38000;crc:$6d99ed51),(n:'136037-206.10b';l:$4000;p:$38001;crc:$545ead91),
        (n:'136041-609.7a';l:$8000;p:$40000;crc:$5b4ee415),(n:'136041-610.7b';l:$8000;p:$40001;crc:$41f5c9e2));
        gauntlet_sound:array[0..1] of tipo_roms=(
        (n:'136037-120.16r';l:$4000;p:$4000;crc:$6ee7f3cc),(n:'136037-119.16s';l:$8000;p:$8000;crc:$fa19861f));
        gauntlet_char:tipo_roms=(n:'136037-104.6p';l:$4000;p:0;crc:$6c276a1d);
        gauntlet_back:array[0..7] of tipo_roms=(
        (n:'136037-111.1a';l:$8000;p:0;crc:$91700f33),(n:'136037-112.1b';l:$8000;p:$8000;crc:$869330be),
        (n:'136037-113.1l';l:$8000;p:$10000;crc:$d497d0a8),(n:'136037-114.1mn';l:$8000;p:$18000;crc:$29ef9882),
        (n:'136037-115.2a';l:$8000;p:$20000;crc:$9510b898),(n:'136037-116.2b';l:$8000;p:$28000;crc:$11e0ac5b),
        (n:'136037-117.2l';l:$8000;p:$30000;crc:$29a5db41),(n:'136037-118.2mn';l:$8000;p:$38000;crc:$8bf3b263));
        gauntlet_proms:array[0..2] of tipo_roms=(
        (n:'74s472-136037-101.7u';l:$200;p:0;crc:$2964f76f),(n:'74s472-136037-102.5l';l:$200;p:$200;crc:$4d4fec6c),
        (n:'74s287-136037-103.4r';l:$100;p:$400;crc:$6c5ccf08));
        //Gauntlet II
        gauntlet2_rom:array[0..7] of tipo_roms=(
        (n:'136037-1307.9a';l:$8000;p:0;crc:$46fe8743),(n:'136037-1308.9b';l:$8000;p:$1;crc:$276e15c4),
        (n:'136043-1105.10a';l:$4000;p:$38000;crc:$45dfda47),(n:'136043-1106.10b';l:$4000;p:$38001;crc:$343c029c),
        (n:'136044-2109.7a';l:$8000;p:$40000;crc:$1102ab96),(n:'136044-2110.7b';l:$8000;p:$40001;crc:$d2203a2b),
        (n:'136044-2121.6a';l:$8000;p:$50000;crc:$753982d7),(n:'136044-2122.6b';l:$8000;p:$50001;crc:$879149ea));
        gauntlet2_sound:array[0..1] of tipo_roms=(
        (n:'136043-1120.16r';l:$4000;p:$4000;crc:$5c731006),(n:'136043-1119.16s';l:$8000;p:$8000;crc:$dc3591e7));
        gauntlet2_char:tipo_roms=(n:'136043-1104.6p';l:$4000;p:0;crc:$bddc3dfc);
        gauntlet2_back:array[0..15] of tipo_roms=(
        (n:'136043-1111.1a';l:$8000;p:0;crc:$09df6e23),(n:'136037-112.1b';l:$8000;p:$8000;crc:$869330be),
        (n:'136043-1123.1c';l:$4000;p:$10000;crc:$e4c98f01),(n:'136043-1123.1c';l:$4000;p:$14000;crc:$e4c98f01),
        (n:'136043-1113.1l';l:$8000;p:$18000;crc:$33cb476e),(n:'136037-114.1mn';l:$8000;p:$20000;crc:$29ef9882),
        (n:'136043-1124.1p';l:$4000;p:$28000;crc:$c4857879),(n:'136043-1124.1p';l:$4000;p:$2c000;crc:$c4857879),
        (n:'136043-1115.2a';l:$8000;p:$30000;crc:$f71e2503),(n:'136037-116.2b';l:$8000;p:$38000;crc:$11e0ac5b),
        (n:'136043-1125.2c';l:$4000;p:$40000;crc:$d9c2c2d1),(n:'136043-1125.2c';l:$4000;p:$44000;crc:$d9c2c2d1),
        (n:'136043-1117.2l';l:$8000;p:$48000;crc:$9e30b2e9),(n:'136037-118.2mn';l:$8000;p:$50000;crc:$8bf3b263),
        (n:'136043-1126.2p';l:$4000;p:$58000;crc:$a32c732a),(n:'136043-1126.2p';l:$4000;p:$5c000;crc:$a32c732a));
        gauntlet2_proms:array[0..2] of tipo_roms=(
        (n:'74s472-136037-101.7u';l:$200;p:0;crc:$2964f76f),(n:'74s472-136037-102.5l';l:$200;p:$200;crc:$4d4fec6c),
        (n:'82s129-136043-1103.4r';l:$100;p:$400;crc:$32ae1fa9));
        //DIP
        gauntlet_dip:array [0..1] of def_dip=(
        (mask:$8;name:'Service';number:2;dip:((dip_val:$8;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(dip_val:$1;dip_name:'5'),(dip_val:$0;dip_name:'6'),(),(),(),(),(),(),(),(),(),(),(),())),());
        gauntlet_mo_config:atari_motion_objects_config=(
        	gfxindex:1;               // index to which gfx system
	        bankcount:1;              // number of motion object banks
	        linked:true;              // are the entries linked?
	        split:true;               // are the entries split?
	        reverse:false;            // render in reverse order?
	        swapxy:false;             // render in swapped X/Y order?
	        nextneighbor:false;       // does the neighbor bit affect the next object?
	        slipheight:8;             // pixels per SLIP entry (0 for no-slip)
	        slipoffset:1;             // pixel offset for SLIPs
	        maxperline:0;             // maximum number of links to visit/scanline (0=all)
	        palettebase:$100;         // base palette entry
	        maxcolors:$100;           // maximum number of colors
	        transpen:0;               // transparent pen index
	        link_entry:(0,0,0,$03ff); // mask for the link
	        code_entry:(data_lower:($7fff,0,0,0);data_upper:(0,0,0,0)); // mask for the code index
	        color_entry:(data_lower:(0,$000f,0,0);data_upper:(0,0,0,0)); // mask for the color
	        xpos_entry:(0,$ff80,0,0); // mask for the X position
          ypos_entry:(0,0,$ff80,0); // mask for the Y position
	        width_entry:(0,0,$0038,0); // mask for the width, in tiles
	        height_entry:(0,0,$0007,0); // mask for the height, in tiles
	        hflip_entry:(0,0,$0040,0); // mask for the horizontal flip
	        vflip_entry:(0,0,0,0);     // mask for the vertical flip
	        priority_entry:(0,0,0,0); // mask for the priority
	        neighbor_entry:(0,0,0,0); // mask for the neighbor
	        absolute_entry:(0,0,0,0);// mask for absolute coordinates
	        special_entry:(0,0,0,0);  // mask for the special value
	        specialvalue:0;           // resulting value to indicate "special"
        );
        CPU_SYNC=2;

var
 rom:array[0..$3ffff] of word;
 slapstic_rom:array[0..3,0..$fff] of word;
 ram:array[0..$1fff] of word;
 ram2:array[0..$5fff] of word;
 eeprom_ram:array[0..$7ff] of byte;
 write_eeprom,sound_to_main_ready,main_to_sound_ready:boolean;
 rom_bank,vblank,sound_to_main_data,main_to_sound_data:byte;
 scroll_x,sound_reset_val:word;

procedure update_video_gauntlet;
var
  f,color,x,y,nchar,atrib,scroll_y:word;
  tile_bank:byte;
begin
for f:=0 to $7ff do begin
  x:=f mod 64;
  y:=f div 64;
  atrib:=ram2[($5000+(f*2)) shr 1];
	color:=((atrib shr 10) and $0f) or ((atrib shr 9) and $20);
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
    nchar:=atrib and $3ff;
	  if (atrib and $8000)<>0 then begin
      put_gfx(x*8,y*8,nchar,color shl 2,2,0);
      put_gfx_block_trans(x*8,y*8,1,8,8);
    end else begin
      put_gfx_trans(x*8,y*8,nchar,color shl 2,1,0);
      put_gfx_block_trans(x*8,y*8,2,8,8);
    end;
    gfx[0].buffer[f]:=false;
  end;
end;
atrib:=ram2[$5f6f shr 1];
scroll_y:=(atrib shr 7) and $1ff;
tile_bank:=atrib and $3;
for f:=0 to $fff do begin
  x:=f div 64;
  y:=f mod 64;
  atrib:=ram2[f];
	color:=(atrib shr 12) and 7;
  if (gfx[1].buffer[f] or buffer_color[$40+color]) then begin
    nchar:=((tile_bank*$1000)+(atrib and $fff)) xor $800;
    if (atrib and $8000)<>0 then begin
      put_gfx_trans(x*8,y*8,nchar,((color+$18) shl 4)+$100,4,1);
      put_gfx_block(x*8,y*8,3,8,8,0);
    end else begin
      put_gfx(x*8,y*8,nchar,((color+$18) shl 4)+$100,3,1);
      put_gfx_block_trans(x*8,y*8,4,8,8);
    end;
    gfx[1].buffer[f]:=false;
  end;
end;
scroll_x_y(3,5,scroll_x,scroll_y);
actualiza_trozo(0,0,512,256,1,0,0,512,256,5);
atari_mo_0.draw(scroll_x,scroll_y,-1);
scroll_x_y(4,5,scroll_x,scroll_y);
actualiza_trozo(0,0,512,256,2,0,0,512,256,5);
actualiza_trozo_final(0,0,336,240,5);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure eventos_gauntlet;
begin
if event.arcade then begin
  //P1
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $fffe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $fffd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $ffef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $ffdf) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $ffbf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $ff7f) else marcade.in0:=(marcade.in0 or $80);
  //P2
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $fffe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $fffd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $ffef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $ffdf) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $ffbf) else marcade.in1:=(marcade.in1 or $40);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $ff7f) else marcade.in1:=(marcade.in1 or $80);
  //Audio CPU
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or $8);
end;
end;

procedure gauntlet_principal;
var
  frame_m,frame_s:single;
  f:word;
  h:byte;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
frame_s:=m6502_0.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to 261 do begin
    for h:=1 to CPU_SYNC do begin
      //main
      m68000_0.run(frame_m);
      frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
      //sound
      m6502_0.run(frame_s);
      frame_s:=frame_s+m6502_0.tframes-m6502_0.contador;
    end;
    case f of
      0,64,128,192,256:m6502_0.change_irq(CLEAR_LINE);
      32,96,160,224:m6502_0.change_irq(ASSERT_LINE);
      239:begin  //VBLANK
          update_video_gauntlet;
          vblank:=$0;
          m68000_0.irq[4]:=ASSERT_LINE;
        end;
      261:vblank:=$40;
    end;
 end;
 eventos_gauntlet;
 video_sync;
end;
end;

function gauntlet_getword(direccion:dword):word;
begin
case direccion of
    0..$37fff,$40000..$7ffff:gauntlet_getword:=rom[direccion shr 1];
    //Funciona asi... Creo...
    //De 38K a 3fK esta la proteccion
    //Cuando lee en este espacio, solo lee 2k del slapstic y recalcula el banco
    $38000..$3ffff:begin //Slaptic!!
                      gauntlet_getword:=slapstic_rom[rom_bank,(direccion and $1fff) shr 1];
                      rom_bank:=slapstic_0.slapstic_tweak((direccion and $7fff) shr 1);
                   end;
    $800000..$801fff:gauntlet_getword:=ram[(direccion and $1fff) shr 1];
    $802000..$802fff:gauntlet_getword:=$ff00 or eeprom_ram[(direccion and $fff) shr 1];
    $803000:gauntlet_getword:=marcade.in0;
    $803002:gauntlet_getword:=marcade.in1;
    $803004:gauntlet_getword:=$ffff;
    $803006:gauntlet_getword:=$ffff;
    $803008:gauntlet_getword:=$ff87 or marcade.dswa or vblank or (byte(sound_to_main_ready) shl 4) or (byte(main_to_sound_ready) shl 5);
    $80300e:begin //main_response_r
              sound_to_main_ready:=false;
              m68000_0.irq[6]:=CLEAR_LINE;
              gauntlet_getword:=$ff00 or sound_to_main_data;
            end;
    $900000..$905fff:gauntlet_getword:=ram2[(direccion and $7fff) shr 1];
    $910000..$9107ff:gauntlet_getword:=buffer_paleta[(direccion and $7ff) shr 1];
end;
end;

procedure gauntlet_putword(direccion:dword;valor:word);

procedure cambiar_color(tmp_color,numero:word);
var
  color:tcolor;
begin
  color.r:=pal4bit_i(tmp_color shr 8,tmp_color shr 12);
  color.g:=pal4bit_i(tmp_color shr 4,tmp_color shr 12);
  color.b:=pal4bit_i(tmp_color,tmp_color shr 12);
  set_pal_color(color,numero);
  case numero of
    $0..$ff:buffer_color[(numero shr 2) and $3f]:=true;
    $100..$3ff:buffer_color[$40+(numero shr 4) and $7]:=true;
  end;
end;

var
  old:word;
begin
case direccion of
    0..$37fff,$40000..$7ffff:; //ROM
    $38000..$3ffff:rom_bank:=slapstic_0.slapstic_tweak((direccion and $7fff) shr 1); //Slaptic!!
    $800000..$801fff:ram[(direccion and $1fff) shr 1]:=valor;
    $802000..$802fff:if write_eeprom then begin  //eeprom
                        eeprom_ram[(direccion and $fff) shr 1]:=valor and $ff;
                        write_eeprom:=false;
                     end;
    $803100:; //watch dog
    $803120..$80312e:begin //sound_reset_w
              old:=sound_reset_val;
              sound_reset_val:=valor;
              if ((old xor sound_reset_val) and 1)<>0 then begin
                if (sound_reset_val and 1)<>0 then m6502_0.change_reset(CLEAR_LINE)
                  else m6502_0.change_reset(ASSERT_LINE);
                sound_to_main_ready:=false;
                m68000_0.irq[6]:=CLEAR_LINE;
                if (sound_reset_val and 1)<>0 then begin
                  ym2151_0.reset;
                  //m_tms5220->reset();
                  //m_tms5220->set_frequency(ATARI_CLOCK_14MHz/2 / 11);
                  //m_ym2151->set_output_gain(ALL_OUTPUTS, 0.0f);
                  //m_pokey->set_output_gain(ALL_OUTPUTS, 0.0f);
                  //m_tms5220->set_output_gain(ALL_OUTPUTS, 0.0f);
                end;
              end;
            end;
    $803140:m68000_0.irq[4]:=CLEAR_LINE; //video_int_ack_w
    $803150:write_eeprom:=true; //eeprom_unlock
    $803170:begin //main_command_w
              main_to_sound_data:=valor;
              main_to_sound_ready:=true;
              m6502_0.change_nmi(ASSERT_LINE);
            end;
    $900000..$901fff,$b00000..$b01fff:begin
                                        ram2[(direccion and $7fff) shr 1]:=valor;
                                        gfx[1].buffer[(direccion and $1fff) shr 1]:=true;
                                      end;
    $902000..$904fff,$b02000..$b04fff:ram2[(direccion and $7fff) shr 1]:=valor;
    $905000..$905fff,$b05000..$b05fff:begin
                                        ram2[(direccion and $7fff) shr 1]:=valor;
                                        gfx[0].buffer[(direccion and $fff) shr 1]:=true;
                                      end;
    $910000..$9107ff:if buffer_paleta[(direccion and $7ff) shr 1]<>valor then begin
                          buffer_paleta[(direccion and $7ff) shr 1]:=valor;
                          cambiar_color(valor,(direccion and $7ff) shr 1);
                        end;
    $930000,$b30000:scroll_x:=valor;
end;
end;

function gauntlet_snd_getbyte(direccion:word):byte;
var
  temp:byte;
begin
case direccion of
     0..$fff,$4000..$ffff:gauntlet_snd_getbyte:=mem_snd[direccion];
     $1010..$101f:begin //sound_command_r
                      main_to_sound_ready:=false;
                      m6502_0.change_nmi(CLEAR_LINE);
                      gauntlet_snd_getbyte:=main_to_sound_data;
                  end;
     $1020..$102f:gauntlet_snd_getbyte:=marcade.in2;//COIN
     $1030..$103f:begin //switch_6502_r
                  temp:=$30;
                  if main_to_sound_ready then temp:=temp xor $80;
                  if sound_to_main_ready then temp:=temp xor $40;
                  //if (!m_tms5220->readyq_r()) temp:=temp xor $20;
                  if marcade.dswa=8 then temp:=temp xor $10;
                  gauntlet_snd_getbyte:=temp;
              end;
     $1800..$180f:gauntlet_snd_getbyte:=pokey_0.read(direccion and $f);
     $1811:gauntlet_snd_getbyte:=ym2151_0.status;
     $1830..$183f:begin //sound_irq_ack_r
                      m6502_0.change_irq(CLEAR_LINE);
                      gauntlet_snd_getbyte:=0;
                  end;
end;
end;

procedure gauntlet_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
     0..$fff:mem_snd[direccion]:=valor;
     $1000..$100f:begin //sound_response_w
                      sound_to_main_data:=valor;
                      sound_to_main_ready:=true;
                      m68000_0.irq[6]:=ASSERT_LINE;
                  end;
     $1020..$102f:; //mixer_w
     $1030..$103f:case (direccion and 7) of //sound_ctl_w
                    0:if ((valor and $80)=0) then ym2151_0.reset; // music reset, bit D7, low reset
                    1:;//m_tms5220->wsq_w(data >> 7); // speech write, bit D7, active low */
                    2:; //m_tms5220->rsq_w(data >> 7); // speech reset, bit D7, active low */
                    3:; { begin //* speech squeak, bit D7 */
                          data = 5 | ((data >> 6) & 2);
                          m_tms5220->set_frequency(ATARI_CLOCK_14MHz/2 / (16 - data));
                          end;}
                  end;
     $1800..$180f:pokey_0.write(direccion and $f,valor);
     $1810:ym2151_0.reg(valor);
     $1811:ym2151_0.write(valor);
     $1820..$182f:; //tms5220_device, data_w
     $1830..$183f:m6502_0.change_irq(CLEAR_LINE); //sound_irq_ack_w
     $4000..$ffff:; //ROM
end;
end;

procedure gauntlet_sound_update;
begin
ym2151_0.update;
pokey_0.update;
//tms5220_update
end;

//Main
procedure reset_gauntlet;
begin
 m68000_0.reset;
 m6502_0.reset;
 YM2151_0.reset;
 pokey_0.reset;
 slapstic_0.reset;
 reset_audio;
 marcade.in0:=$ffff;
 marcade.in1:=$ffff;
 marcade.in2:=$ff;
 scroll_x:=0;
 rom_bank:=slapstic_0.current_bank;
 main_to_sound_ready:=false;
 sound_to_main_ready:=false;
 sound_to_main_data:=0;
 main_to_sound_data:=0;
 sound_reset_val:=1;
 vblank:=$40;
 write_eeprom:=false;
end;

procedure cerrar_gauntlet;
var
  nombre:string;
begin
case main_vars.tipo_maquina of
  236:nombre:='gauntlet.nv';
  245:nombre:='gaunt2.nv';
end;
write_file(Directory.Arcade_nvram+nombre,@eeprom_ram,$800);
end;

function iniciar_gauntlet:boolean;
var
  memoria_temp:array[0..$7ffff] of byte;
  f:dword;
  temp:pword;
  longitud:integer;
const
  pc_x:array[0..7] of dword=(0, 1, 2, 3, 8, 9, 10, 11);
  pc_y:array[0..7] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16);
  ps_x:array[0..7] of dword=(0, 1, 2, 3, 4, 5, 6, 7);
  ps_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
procedure load_and_change_roms;
begin
  copymemory(@rom[0],@memoria_temp[$8000],$8000);
  copymemory(@rom[$8000 shr 1],@memoria_temp[$0],$8000);
  copymemory(@rom[$40000 shr 1],@memoria_temp[$48000],$8000);
  copymemory(@rom[$48000 shr 1],@memoria_temp[$40000],$8000);
  copymemory(@rom[$50000 shr 1],@memoria_temp[$58000],$8000);
  copymemory(@rom[$58000 shr 1],@memoria_temp[$50000],$8000);
  copymemory(@rom[$60000 shr 1],@memoria_temp[$68000],$8000);
  copymemory(@rom[$68000 shr 1],@memoria_temp[$60000],$8000);
  copymemory(@rom[$70000 shr 1],@memoria_temp[$78000],$8000);
  copymemory(@rom[$78000 shr 1],@memoria_temp[$70000],$8000);
  copymemory(@slapstic_rom[0,0],@memoria_temp[$38000],$2000);
  copymemory(@slapstic_rom[1,0],@memoria_temp[$3a000],$2000);
  copymemory(@slapstic_rom[2,0],@memoria_temp[$3c000],$2000);
  copymemory(@slapstic_rom[3,0],@memoria_temp[$3e000],$2000);
end;
begin
llamadas_maquina.bucle_general:=gauntlet_principal;
llamadas_maquina.reset:=reset_gauntlet;
llamadas_maquina.close:=cerrar_gauntlet;
llamadas_maquina.fps_max:=59.922743;
iniciar_gauntlet:=false;
iniciar_audio(true);
//Chars
screen_init(1,512,256,true);
screen_init(2,512,256,true);
//Back
screen_init(3,512,512,true);
screen_mod_scroll(3,512,512,511,512,256,511);
screen_init(4,512,512,true);
screen_mod_scroll(4,512,512,511,512,256,511);
//Final
screen_init(5,512,512,false,true);
iniciar_video(336,240);
//Main CPU
m68000_0:=cpu_m68000.create(14318180 div 2,262*CPU_SYNC,TCPU_68010);
m68000_0.change_ram16_calls(gauntlet_getword,gauntlet_putword);
//Sound CPU
m6502_0:=cpu_m6502.create(14318180 div 8,262*CPU_SYNC,TCPU_M6502);
m6502_0.change_ram_calls(gauntlet_snd_getbyte,gauntlet_snd_putbyte);
m6502_0.init_sound(gauntlet_sound_update);
//Sound Chips
ym2151_0:=ym2151_chip.create(14318180 div 4);
pokey_0:=pokey_chip.create(14318180 div 8);
//TMS5220
case main_vars.tipo_maquina of
  236:begin //Gauntlet
        //Slapstic
        slapstic_0:=slapstic_type.create(107,true);
        //cargar roms
        if not(roms_load16w(@memoria_temp,gauntlet_rom)) then exit;
        load_and_change_roms;
        //cargar sonido
        if not(roms_load(@mem_snd,gauntlet_sound)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,gauntlet_char)) then exit;
        init_gfx(0,8,8,$400);
        gfx[0].trans[0]:=true;
        gfx_set_desc_data(2,0,16*8,0,4);
        convert_gfx(0,0,@memoria_temp,@pc_x,@pc_y,false,false);
        //convertir fondo
        if not(roms_load(@memoria_temp,gauntlet_back)) then exit;
        for f:=0 to $3ffff do memoria_temp[f]:=not(memoria_temp[f]);
        init_gfx(1,8,8,$2000);
        gfx[1].trans[0]:=true;
        gfx_set_desc_data(4,0,8*8,$2000*8*8*3,$2000*8*8*2,$2000*8*8*1,$2000*8*8*0);
        convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,false);
        //eeprom
        if read_file_size(Directory.Arcade_nvram+'gauntlet.nv',longitud) then read_file(Directory.Arcade_nvram+'gauntlet.nv',@eeprom_ram,longitud)
          else fillchar(eeprom_ram[0],$800,$ff);
        //DIP
        marcade.dswa:=$8;
        marcade.dswa_val:=@gauntlet_dip;
      end;
  245:begin //Gauntlet II
        //Slapstic
        slapstic_0:=slapstic_type.create(106,true);
        //cargar roms
        if not(roms_load16w(@memoria_temp,gauntlet2_rom)) then exit;
        load_and_change_roms;
        //cargar sonido
        if not(roms_load(@mem_snd,gauntlet2_sound)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,gauntlet2_char)) then exit;
        init_gfx(0,8,8,$400);
        gfx[0].trans[0]:=true;
        gfx_set_desc_data(2,0,16*8,0,4);
        convert_gfx(0,0,@memoria_temp,@pc_x,@pc_y,false,false);
        //convertir fondo
        if not(roms_load(@memoria_temp,gauntlet2_back)) then exit;
        for f:=0 to $7ffff do memoria_temp[f]:=not(memoria_temp[f]);
        init_gfx(1,8,8,$3000);
        gfx[1].trans[0]:=true;
        gfx_set_desc_data(4,0,8*8,$3000*8*8*3,$3000*8*8*2,$3000*8*8*1,$3000*8*8*0);
        convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,false);
        //eeprom
        if read_file_size(Directory.Arcade_nvram+'gaunt2.nv',longitud) then read_file(Directory.Arcade_nvram+'gaunt2.nv',@eeprom_ram,longitud)
          else fillchar(eeprom_ram[0],$800,$ff);
        //DIP
        marcade.dswa:=$8;
        marcade.dswa_val:=@gauntlet_dip;
      end;
end;
//atari mo
atari_mo_0:=tatari_mo.create(@ram2[$5f80 shr 1],@ram2[$2000 shr 1],gauntlet_mo_config,5,336+8,240+8);
// modify the motion object code lookup table to account for the code XOR
temp:=atari_mo_0.get_codelookup;
for f:=0 to $7fff do begin
  temp^:=temp^ xor $800;
  inc(temp);
end;
//final
reset_gauntlet;
iniciar_gauntlet:=true;
end;

end.
