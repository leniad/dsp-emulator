unit atari_system1;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6502,m68000,main_engine,controls_engine,gfx_engine,rom_engine,pokey,
     pal_engine,sound_engine,slapstic,ym_2151,atari_mo;

function iniciar_atari_sys1:boolean;

implementation
const
        //System ROMS
        atari_sys1_bios:array[0..1] of tipo_roms=(
        (n:'136032.205.l13';l:$4000;p:$0;crc:$88d0be26),(n:'136032.206.l12';l:$4000;p:$1;crc:$3c79ef05));
        atari_sys1_char:tipo_roms=(n:'136032.104.f5';l:$2000;p:0;crc:$7a29dc07);
        peterpak_rom:array[0..7] of tipo_roms=(
        (n:'136028.142';l:$4000;p:$0;crc:$4f9fc020),(n:'136028.143';l:$4000;p:$1;crc:$9fb257cc),
        (n:'136028.144';l:$4000;p:$8000;crc:$50267619),(n:'136028.145';l:$4000;p:$8001;crc:$7b6a5004),
        (n:'136028.146';l:$4000;p:$10000;crc:$4183a67a),(n:'136028.147';l:$4000;p:$10001;crc:$14e2d97b),
        (n:'136028.148';l:$4000;p:$20000;crc:$230e8ba9),(n:'136028.149';l:$4000;p:$20001;crc:$0ff0c13a));
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
        //Indiana
        indy_rom:array[0..7] of tipo_roms=(
        (n:'136036.432';l:$8000;p:$0;crc:$d888cdf1),(n:'136036.431';l:$8000;p:$1;crc:$b7ac7431),
        (n:'136036.434';l:$8000;p:$10000;crc:$802495fd),(n:'136036.433';l:$8000;p:$10001;crc:$3a914e5c),
        (n:'136036.456';l:$4000;p:$20000;crc:$ec146b09),(n:'136036.457';l:$4000;p:$20001;crc:$6628de01),
        (n:'136036.358';l:$4000;p:$28000;crc:$d9351106),(n:'136036.359';l:$4000;p:$28001;crc:$e731caea));
        indy_sound:array[0..2] of tipo_roms=(
        (n:'136036.153';l:$4000;p:$4000;crc:$95294641),(n:'136036.154';l:$4000;p:$8000;crc:$cbfc6adb),
        (n:'136036.155';l:$4000;p:$c000;crc:$4c8233ac));
        indy_back:array[0..15] of tipo_roms=(
        (n:'136036.135';l:$8000;p:0;crc:$ffa8749c),(n:'136036.139';l:$8000;p:$10000;crc:$b682bfca),
        (n:'136036.143';l:$8000;p:$20000;crc:$7697da26),(n:'136036.147';l:$8000;p:$30000;crc:$4e9d664c),
        (n:'136036.136';l:$8000;p:$80000;crc:$b2b403aa),(n:'136036.140';l:$8000;p:$90000;crc:$ec0c19ca),
        (n:'136036.144';l:$8000;p:$a0000;crc:$4407df98),(n:'136036.148';l:$8000;p:$b0000;crc:$70dce06d),
        (n:'136036.137';l:$8000;p:$100000;crc:$3f352547),(n:'136036.141';l:$8000;p:$110000;crc:$9cbdffd0),
        (n:'136036.145';l:$8000;p:$120000;crc:$e828e64b),(n:'136036.149';l:$8000;p:$130000;crc:$81503a23),
        (n:'136036.138';l:$8000;p:$180000;crc:$48c4d79d),(n:'136036.142';l:$8000;p:$190000;crc:$7faae75f),
        (n:'136036.146';l:$8000;p:$1a0000;crc:$8ae5a7b5),(n:'136036.150';l:$8000;p:$1b0000;crc:$a10c4bd9));
        indy_proms:array[0..1] of tipo_roms=(
        (n:'136036.152';l:$200;p:0;crc:$4f96e57c),(n:'136036.151';l:$200;p:$200;crc:$7daf351f));
        //Marble
        marble_rom:array[0..9] of tipo_roms=(
        (n:'136033.623';l:$4000;p:$0;crc:$284ed2e9),(n:'136033.624';l:$4000;p:$1;crc:$d541b021),
        (n:'136033.625';l:$4000;p:$8000;crc:$563755c7),(n:'136033.626';l:$4000;p:$8001;crc:$860feeb3),
        (n:'136033.627';l:$4000;p:$10000;crc:$d1dbd439),(n:'136033.628';l:$4000;p:$10001;crc:$957d6801),
        (n:'136033.229';l:$4000;p:$18000;crc:$c81d5c14),(n:'136033.630';l:$4000;p:$18001;crc:$687a09f7),
        (n:'136033.107';l:$4000;p:$20000;crc:$f3b8745b),(n:'136033.108';l:$4000;p:$20001;crc:$e51eecaa));
        marble_sound:array[0..1] of tipo_roms=(
        (n:'136033.421';l:$4000;p:$8000;crc:$78153dc3),(n:'136033.422';l:$4000;p:$c000;crc:$2e66300e));
        marble_back:array[0..12] of tipo_roms=(
        (n:'136033.137';l:$4000;p:0;crc:$7a45f5c1),(n:'136033.138';l:$4000;p:$4000;crc:$7e954a88),
        (n:'136033.139';l:$4000;p:$10000;crc:$1eb1bb5f),(n:'136033.140';l:$4000;p:$14000;crc:$8a82467b),
        (n:'136033.141';l:$4000;p:$20000;crc:$52448965),(n:'136033.142';l:$4000;p:$24000;crc:$b4a70e4f),
        (n:'136033.143';l:$4000;p:$30000;crc:$7156e449),(n:'136033.144';l:$4000;p:$34000;crc:$4c3e4c79),
        (n:'136033.145';l:$4000;p:$40000;crc:$9062be7f),(n:'136033.146';l:$4000;p:$44000;crc:$14566dca),
        (n:'136033.149';l:$4000;p:$84000;crc:$b6658f06),(n:'136033.151';l:$4000;p:$94000;crc:$84ee1c80),
        (n:'136033.153';l:$4000;p:$a4000;crc:$daa02926));
        marble_proms:array[0..1] of tipo_roms=(
        (n:'136033.118';l:$200;p:0;crc:$2101b0ed),(n:'136033.119';l:$200;p:$200;crc:$19f6e767));
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
        CPU_SYNC=1;

var
 rom:array[0..$3ffff] of word;
 slapstic_rom:array[0..3,0..$fff] of word;
 ram:array[0..$fff] of word;
 ram2:array[0..$7ffff] of word;
 ram3:array[0..$1fff] of word;
 sound_latch,main_latch:byte;
 write_eeprom,main_pending,sound_pending:boolean;
 //Video
 playfield_lookup:array[0..$ff] of word;
 bank_color_shift:array[0..7] of byte;
 linea,scroll_x,scroll_y,scroll_y_latch,bankselect:word;
 rom_bank,vblank,playfield_tile_bank:byte;
 eeprom_ram:array[0..$7ff] of byte;

procedure update_video_atari_sys1;
var
  f,color,x,y,nchar,atrib,atrib2:word;
  gfx_index:byte;
begin
fill_full_screen(3,$2000);
for f:=0 to $7ff do begin
  x:=f mod 64;
  y:=f div 64;
  atrib:=ram3[($3000+(f*2)) shr 1];
	color:=(atrib shr 10) and 7;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
    nchar:=atrib and $3ff;
	  if (atrib and $2000)=0 then put_gfx_trans(x*8,y*8,nchar,color shl 2,1,0)
      else put_gfx(x*8,y*8,nchar,color shl 2,1,0);
    gfx[0].buffer[f]:=false;
  end;
end;
for f:=0 to $fff do begin
  x:=f mod 64;
  y:=f div 64;
  atrib:=ram3[f];
  atrib2:=playfield_lookup[((atrib shr 8) and $7f) or (playfield_tile_bank shl 7)];
  gfx_index:=(atrib2 shr 8) and $f;
  color:=$20+(((atrib2 shr 12) and $f) shl bank_color_shift[gfx_index]);
  if (gfx[1].buffer[f] or buffer_color[color]) then begin
    nchar:=((atrib2 and $ff) shl 8) or (atrib and $ff);
    put_gfx_flip(x*8,y*8,nchar,color shl 4,2,gfx_index,((atrib shr 15) and 1)<>0,false);
    gfx[1].buffer[f]:=false;
  end;
end;
scroll_x_y(2,3,scroll_x,scroll_y);
atari_mo_0.draw(0,256,-1);
actualiza_trozo(0,0,512,256,1,0,0,512,256,3);
actualiza_trozo_final(0,0,336,240,3);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
end;

procedure eventos_atari_sys1;
begin
if event.arcade then begin
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $fffe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $fffd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $fffb) else marcade.in0:=(marcade.in0 or 4);
  //SYSTEM
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or 1);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or 2);
end;
end;

procedure atari_sys1_principal;
var
  frame_m,frame_s:single;
  h:byte;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
frame_s:=m6502_0.tframes;
while EmuStatus=EsRunning do begin
 for linea:=0 to 261 do begin
  //main
  for h:=1 to CPU_SYNC do begin
    m68000_0.run(frame_m);
    frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
    //sound
    m6502_0.run(frame_s);
    frame_s:=frame_s+m6502_0.tframes-m6502_0.contador;
  end;
  case linea of
    239:begin
          update_video_atari_sys1;
          vblank:=$0;
          m68000_0.irq[4]:=ASSERT_LINE;
        end;
    261:vblank:=$10;
  end;
 end;
 scroll_y:=scroll_y_latch;
 eventos_atari_sys1;
 video_sync;
end;
end;

function atari_sys1_getword(direccion:dword):word;
begin
case direccion of
    0..$7ffff:atari_sys1_getword:=rom[direccion shr 1];
    $80000..$87fff:begin
                      atari_sys1_getword:=slapstic_rom[rom_bank,(direccion and $1fff) shr 1];
                      rom_bank:=slapstic_0.slapstic_tweak((direccion and $7fff) shr 1);
                   end;
    $2e0000:if m68000_0.irq[3]<>CLEAR_LINE then atari_sys1_getword:=$80
              else atari_sys1_getword:=0;
    $400000..$401fff:atari_sys1_getword:=ram[(direccion and $1fff) shr 1];
    $900000..$9fffff:atari_sys1_getword:=ram2[(direccion and $fffff) shr 1];
    $a00000..$a03fff:atari_sys1_getword:=ram3[(direccion and $3fff) shr 1];
    $b00000..$b007ff:atari_sys1_getword:=buffer_paleta[(direccion and $7ff) shr 1];
    $f00000..$f00fff:atari_sys1_getword:=eeprom_ram[(direccion and $fff) shr 1];
    $f20000..$f20007:atari_sys1_getword:=$ff; //trakball_r
	  $f40000..$f4001f:atari_sys1_getword:=0; //Controles
	  $f60000..$f60003:atari_sys1_getword:=marcade.in0 or vblank or ($80*(byte(sound_pending)));
	  $fc0000:begin
                main_pending:=false;
	              m68000_0.irq[6]:=CLEAR_LINE;
	              atari_sys1_getword:=main_latch;
            end;
end;
end;

procedure cambiar_color(tmp_color,numero:word);
var
  color:tcolor;
begin
  color.r:=pal4bit_i(tmp_color shr 8,tmp_color shr 12);
  color.g:=pal4bit_i(tmp_color shr 4,tmp_color shr 12);
  color.b:=pal4bit_i(tmp_color,tmp_color shr 12);
  set_pal_color(color,numero);
  if numero<$20 then buffer_color[(numero shr 2) and 7]:=true
    else buffer_color[$20+((numero shr 4) and $f)]:=true
end;

procedure atari_sys1_putword(direccion:dword;valor:word);
var
  diff:word;
begin
case direccion of
    0..$7ffff:;
    $80000..$87fff:rom_bank:=slapstic_0.slapstic_tweak((direccion and $7fff) shr 1);
    $400000..$401fff:ram[(direccion and $1fff) shr 1]:=valor;
    $800000:scroll_x:=valor;
	  $820000:begin
              scroll_y_latch:=valor;
              if linea<240 then scroll_y:=valor-(linea+1)
                else scroll_y:=valor;
            end;
	  $840000:; //atarisy1_priority_w
	  $860000:begin //atarisy1_bankselect_w
              diff:=bankselect xor valor;
              // playfield bank select
	            if (diff and $4)<>0 then begin
		              playfield_tile_bank:=(valor shr 2) and 1;
                  fillchar(gfx[1].buffer[0],$1000,1);
              end;
              if (diff and $80)<>0 then begin
                  if (valor and $80)<>0 then m6502_0.change_reset(CLEAR_LINE)
                    else m6502_0.change_reset(ASSERT_LINE);
                  //if (valor and $80)<>0 then tcm5220.reset;
              end;
              atari_mo_0.set_bank((valor shr 3) and 7);
              //Revisar para Road runners!!!!!
	            //update_timers(scanline);
              bankselect:=valor;
            end;
	  $880000:; //watchdog
	  $8a0000:m68000_0.irq[4]:=CLEAR_LINE;
	  $8c0000:write_eeprom:=true;
    $900000..$9fffff:ram2[(direccion and $fffff) shr 1]:=valor;
    $a00000..$a01fff:if ram3[(direccion and $3fff) shr 1]<>valor then begin
                        ram3[(direccion and $3fff) shr 1]:=valor;
                        gfx[1].buffer[(direccion and $1fff) shr 1]:=true;
                     end;
    $a02000..$a02fff:ram3[(direccion and $3fff) shr 1]:=valor;
    $a03000..$a03fff:if ram3[(direccion and $3fff) shr 1]<>valor then begin
                        ram3[(direccion and $3fff) shr 1]:=valor;
                        gfx[0].buffer[(direccion and $fff) shr 1]:=true;
                     end;
    $b00000..$b007ff:if buffer_paleta[(direccion and $7ff) shr 1]<>valor then begin
                          buffer_paleta[(direccion and $7ff) shr 1]:=valor;
                          cambiar_color(valor,(direccion and $7ff) shr 1);
                        end;
    $f00000..$f00fff:if write_eeprom then begin
                        eeprom_ram[(direccion and $fff) shr 1]:=valor and $ff;
                        write_eeprom:=false;
                     end;
	  $f40000..$f4001f:; //joystick_w
	  $f80000,$fe0000:begin
                        sound_latch:=valor;
	                      sound_pending:=true;
	                      m6502_0.change_nmi(ASSERT_LINE)
                    end;
end;
end;

function atari_sys1_snd_getbyte(direccion:word):byte;
begin
case direccion of
     0..$fff,$4000..$ffff:atari_sys1_snd_getbyte:=mem_snd[direccion];
     $1000..$100f:; //via6522_device, read
     $1801:atari_sys1_snd_getbyte:=ym2151_0.status;
     $1810:begin
              sound_pending:=false;
              m6502_0.change_nmi(CLEAR_LINE);
	            atari_sys1_snd_getbyte:=sound_latch;
           end;
     $1820:atari_sys1_snd_getbyte:=marcade.in2 or ($8*byte(sound_pending)) or ($10*byte(main_pending));
     $1870..$187f:pokey_0.read(direccion and $f);
end;
end;

procedure atari_sys1_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
     0..$fff:mem_snd[direccion]:=valor;
     $1000..$100f:; //via6522_device, write
     $1800:ym2151_0.reg(valor);
     $1801:ym2151_0.write(valor);
     $1810:begin
              main_latch:=valor;
	            main_pending:=true;
              m68000_0.irq[6]:=ASSERT_LINE;
           end;
     $1824..$1825:; //led_w
     $1870..$187f:pokey_0.write(direccion and $f,valor);
     $4000..$ffff:;
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
 marcade.in0:=$ff6f;
 marcade.in1:=$ff;
 marcade.in2:=$87;
 scroll_x:=0;
 scroll_y:=0;
 rom_bank:=slapstic_0.current_bank;
 vblank:=$10;
 bankselect:=0;
 playfield_tile_bank:=0;
 write_eeprom:=false;
 sound_pending:=false;
 main_pending:=false;
 main_latch:=0;
 sound_latch:=0;
end;

function iniciar_atari_sys1:boolean;
var
  memoria_temp:array[0..$3ffff] of byte;
  proms_temp:array[0..$3ff] of byte;
  f:dword;
  mem_temp,ptemp:pbyte;
  ptempw:pword;
  motable:array[0..$ff] of word;
  bank_gfx:array[0..2,0..7] of byte;
const
  pc_x:array[0..7] of dword=(0, 1, 2, 3, 8, 9, 10, 11);
  pc_y:array[0..7] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16);
//Convertir los GFX del fondo y MO
procedure convert_back(size_back:dword);
var
  gfx_index,bank,color,offset,obj,i,bpp:byte;
  f:dword;
const
  ps_x:array[0..7] of dword=(0, 1, 2, 3, 4, 5, 6, 7);
  ps_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
  PROM2_PLANE_4_ENABLE=$10;
  PROM2_PLANE_5_ENABLE=$20;
  PROM1_OFFSET_MASK=$0f;
  PROM2_PF_COLOR_MASK=$0f;
  PROM2_MO_COLOR_MASK=$07;
  PROM1_BANK_1=$10;
  PROM1_BANK_2=$20;
  PROM1_BANK_3=$40;
  PROM1_BANK_4=$80;
  PROM2_BANK_5=$40;
  PROM2_BANK_6_OR_7=$80;
  PROM2_BANK_7=$08;
function get_bank(prom1,prom2,bpp:byte;size_back:dword):byte;
var
  bank_index:byte;
  srcdata:pbyte;
begin
  // determine the bank index
	if ((prom1 and PROM1_BANK_1)=0) then
		bank_index:=1
	  else if ((prom1 and PROM1_BANK_2)=0) then bank_index:=2
	    else if ((prom1 and PROM1_BANK_3)=0) then bank_index:=3
	      else if ((prom1 and PROM1_BANK_4)=0) then bank_index:=4
	        else if ((prom2 and PROM2_BANK_5)=0) then bank_index:=5
	          else if ((prom2 and PROM2_BANK_6_OR_7)=0) then begin
		          if ((prom2 and PROM2_BANK_7)=0) then bank_index:=7
		            else bank_index:=6;
            end else begin
              get_bank:=0;
              exit;
            end;
  // find the bank, si ya lo tengo, no hago nada me salgo
	if (bank_gfx[bpp-4][bank_index]<>0) then begin
    get_bank:=bank_gfx[bpp-4][bank_index];
    exit;
  end;
	// if the bank is out of range, call it 0
	if ($80000*(bank_index-1)>=size_back) then begin
    get_bank:=0;
    exit;
  end;
	// decode the graphics */
	srcdata:=mem_temp;
  inc(srcdata,$80000*(bank_index-1));
  init_gfx(gfx_index,8,8,$1000);
  gfx[gfx_index].trans[0]:=true;
  case bpp of
	  4:begin
        gfx_set_desc_data(4,0,8*8,3*8*$10000,2*8*$10000,1*8*$10000,0*8*$10000);
        convert_gfx(gfx_index,0,srcdata,@ps_x,@ps_y,false,false);
      end;
	  5:begin
        gfx_set_desc_data(5,0,8*8,4*8*$10000,3*8*$10000,2*8*$10000,1*8*$10000,0*8*$10000);
        convert_gfx(gfx_index,0,srcdata,@ps_x,@ps_y,false,false);
      end;
    6:begin
        gfx_set_desc_data(6,0,8*8,5*8*$10000,4*8*$10000,3*8*$10000,2*8*$10000,1*8*$10000,0*8*$10000);
        convert_gfx(gfx_index,0,srcdata,@ps_x,@ps_y,false,false);
      end;
  end;
	// set the entry and return it
	bank_gfx[bpp-4][bank_index]:=gfx_index;
  bank_color_shift[gfx_index]:=bpp-3;
  get_bank:=gfx_index;
  gfx_index:=gfx_index+1;
end;
begin
ptemp:=mem_temp;
for f:=0 to (size_back-1) do begin
  ptemp^:=not(ptemp^);
  inc(ptemp);
end;
fillchar(bank_gfx,3*8,0);
gfx_index:=1;
for obj:=0 to 1 do begin
  for i:=0 to 255 do begin
    bpp:=4;
    if (proms_temp[$200+i+($100*obj)] and PROM2_PLANE_4_ENABLE)<>0 then bpp:=5
				else if (proms_temp[$200+i+($100*obj)] and PROM2_PLANE_5_ENABLE)<>0 then bpp:=6;
    // determine the offset
    offset:=proms_temp[i+$100*obj] and PROM1_OFFSET_MASK;
    // determine the bank
    bank:=get_bank(proms_temp[i+($100*obj)],proms_temp[$200+i+($100*obj)],bpp,size_back);
    // set the value */
    if (obj=0) then begin
				// playfield case
				color:=(not(proms_temp[$200+i+($100*obj)]) and PROM2_PF_COLOR_MASK) shr (bpp-4);
				if (bank=0) then begin
					bank:=1;
					offset:=0;
          color:=0;
				end;
				playfield_lookup[i]:=offset or (bank shl 8) or (color shl 12);
    end else begin
				// motion objects (high bit ignored)
				color:=(not(proms_temp[$200+i+($100*obj)]) and PROM2_MO_COLOR_MASK) shr (bpp-4);
				motable[i]:=offset or (bank shl 8) or (color shl 12);
    end;
  end;
end;
end;
begin
iniciar_atari_sys1:=false;
llamadas_maquina.bucle_general:=atari_sys1_principal;
llamadas_maquina.reset:=reset_atari_sys1;
llamadas_maquina.fps_max:=59.922743;
iniciar_audio(true);
screen_init(1,512,256,true);
screen_init(2,512,512);
screen_mod_scroll(2,512,512,511,512,512,511);
screen_init(3,512,512,false,true);
iniciar_video(336,240);
//cargar BIOS
if not(roms_load16w(@rom,atari_sys1_bios)) then exit;
//Main CPU
m68000_0:=cpu_m68000.create(14318180 div 2,262*CPU_SYNC);
m68000_0.change_ram16_calls(atari_sys1_getword,atari_sys1_putword);
//Sound CPU
m6502_0:=cpu_m6502.create(14318180 div 8,262*CPU_SYNC,TCPU_M6502);
m6502_0.change_ram_calls(atari_sys1_snd_getbyte,atari_sys1_snd_putbyte);
m6502_0.init_sound(atari_sys1_sound_update);
//Sound Chips
ym2151_0:=ym2151_chip.create(14318180 div 4);
ym2151_0.change_irq_func(ym2151_snd_irq);
pokey_0:=pokey_chip.create(14318180 div 8);
//convertir chars
if not(roms_load(@memoria_temp,atari_sys1_char)) then exit;
init_gfx(0,8,8,$200);
gfx[0].trans[0]:=true;
gfx_set_desc_data(2,0,16*8,0,4);
convert_gfx(0,0,@memoria_temp,@pc_x,@pc_y,false,false);
//TMS5520
case main_vars.tipo_maquina of
  244:begin //Peter Pack Rat
        if not(roms_load16w(@memoria_temp,peterpak_rom)) then exit;
        copymemory(@rom[$10000 shr 1],@memoria_temp[$0],$8000*3);
        //Slapstic
        slapstic_0:=slapstic_type.create(107,true);
        copymemory(@slapstic_rom[0,0],@memoria_temp[$20000],$2000);
        copymemory(@slapstic_rom[1,0],@memoria_temp[$22000],$2000);
        copymemory(@slapstic_rom[2,0],@memoria_temp[$24000],$2000);
        copymemory(@slapstic_rom[3,0],@memoria_temp[$26000],$2000);
        //cargar sonido
        if not(roms_load(@mem_snd,peterpak_sound)) then exit;
        //convertir fondo y mo
        getmem(mem_temp,$180000);
        fillchar(mem_temp^,$180000,$ff);
        if not(roms_load(@proms_temp,peterpak_proms)) then exit;
        if not(roms_load(mem_temp,peterpak_back)) then exit;
        convert_back($180000);
        freemem(mem_temp);
  end;
  263:begin //Indiana Jones
        if not(roms_load16w(@memoria_temp,indy_rom)) then exit;
        copymemory(@rom[$10000 shr 1],@memoria_temp[$0],$8000*5);
        //Slapstic
        slapstic_0:=slapstic_type.create(105,true);
        copymemory(@slapstic_rom[0,0],@memoria_temp[$28000],$2000);
        copymemory(@slapstic_rom[1,0],@memoria_temp[$2a000],$2000);
        copymemory(@slapstic_rom[2,0],@memoria_temp[$2c000],$2000);
        copymemory(@slapstic_rom[3,0],@memoria_temp[$2e000],$2000);
        //cargar sonido
        if not(roms_load(@mem_snd,indy_sound)) then exit;
        //convertir fondo y mo
        getmem(mem_temp,$200000);
        fillchar(mem_temp^,$200000,$ff);
        if not(roms_load(@proms_temp,indy_proms)) then exit;
        if not(roms_load(mem_temp,indy_back)) then exit;
        convert_back($200000);
        freemem(mem_temp);
  end;
  264:begin //Marble Madness
        if not(roms_load16w(@memoria_temp,marble_rom)) then exit;
        copymemory(@rom[$10000 shr 1],@memoria_temp[$0],$8000*4);
        //Slapstic
        slapstic_0:=slapstic_type.create(103,true);
        copymemory(@slapstic_rom[0,0],@memoria_temp[$20000],$2000);
        copymemory(@slapstic_rom[1,0],@memoria_temp[$22000],$2000);
        copymemory(@slapstic_rom[2,0],@memoria_temp[$24000],$2000);
        copymemory(@slapstic_rom[3,0],@memoria_temp[$26000],$2000);
        //cargar sonido
        if not(roms_load(@mem_snd,marble_sound)) then exit;
        //convertir fondo y mo
        getmem(mem_temp,$100000);
        fillchar(mem_temp^,$100000,$ff);
        if not(roms_load(@proms_temp,marble_proms)) then exit;
        if not(roms_load(mem_temp,marble_back)) then exit;
        convert_back($100000);
        freemem(mem_temp);
  end;
end;
//atari mo
atari_mo_0:=tatari_mo.create(nil,@ram3[$2000 shr 1],atari_sys1_mo_config,3,336+8,240+8);
ptempw:=atari_mo_0.get_codelookup;
for f:=0 to $ffff do begin
  ptempw^:=(f and $ff) or ((motable[f shr 8] and $ff) shl 8);
  inc(ptempw);
end;
ptempw:=atari_mo_0.get_colorlookup;
ptemp:=atari_mo_0.get_gfxlookup;
for f:=0 to $ff do begin
  ptempw^:=((motable[f] shr 12) and $f) shl 1;
  inc(ptempw);
	ptemp^:=(motable[f] shr 8) and $f;
  inc(ptemp);
end;
//final
reset_atari_sys1;
iniciar_atari_sys1:=true;
end;

end.
