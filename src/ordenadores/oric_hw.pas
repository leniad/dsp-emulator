unit oric_hw;

interface
uses sysutils,rom_engine;

function iniciar_oric:boolean;

const
    atmos_rom:array [0..1] of tipo_roms=((n:'basic11b.rom';l:$4000;p:0;crc:$c3a92bef),());
    oric1_rom:array [0..1] of tipo_roms=((n:'basic10.rom';l:$4000;p:0;crc:$f18710b4),());
    microdisc_rom:tipo_roms=(n:'microdis.rom';l:$2000;p:0;crc:$a9664a9c);

implementation
uses tap_tzx,m6502,main_engine,controls_engine,ay_8910,gfx_engine,timer_engine,
     pal_engine,sound_engine,via6522,misc_functions,file_engine,tape_window,
     oric_disc,cargar_dsk;

const
		PATTR_HIRES =4;
		LATTR_ALT   =1;
		LATTR_DSIZE =2;
		LATTR_BLINK =4;

var
  tape_sound_channel,blink_counter,pattr,via_a,via_b,psg_a,tape_timer:byte;
  bios_rom:array[0..$3fff] of byte;
  via_ca2,via_cb2,via_irq,ext_irq:boolean;
  key_row:array[0..7] of byte;
  key_timer,key_pos:byte;
  key_physical,key_auto:array[0..7] of byte;
  tape_motor,resetting_oric:boolean;

procedure update_video_oric(linea:word);
var
  blink_state:boolean;
  tpattr,x,lattr,ch,pat,off:byte;
  base,fgcol,bgcol,c_fgcol,c_bgcol:word;
  ptemp:pword;
begin
  if ((linea<44) or (linea>267)) then exit;
  linea:=linea-44;
  blink_state:=(blink_counter and $20)<>0;
	tpattr:=pattr;
	ptemp:=punbuf;
	// Line attributes and current colors
	lattr:=0;
	fgcol:=paleta[7];
	bgcol:=paleta[0];
	for x:=0 to 39 do begin
			// Lookup the byte and, if needed, the pattern data
			if (((tpattr and PATTR_HIRES)<>0) and (linea<200)) then begin
				ch:=memoria[$a000+linea*40+x];
        pat:=ch;
      end else begin
				ch:=memoria[$bb80+(linea shr 3)*40+x];
        if (lattr and LATTR_DSIZE)<>0 then off:=(linea shr 1) and 7
          else off:=linea and 7;
				if (tpattr and PATTR_HIRES)<>0 then begin
					if (lattr and LATTR_ALT)<>0 then base:=$9c00
					  else base:=$9800;
				end else begin
					if (lattr and LATTR_ALT)<>0 then base:=$b800
					  else base:=$b400;
        end;
				pat:=memoria[base+((ch and $7f) shl 3) or off];
			end;
			// Handle state-chaging attributes
			if ((ch and $60)=0) then begin
				pat:=0;
				case (ch and $18) of
				  0:fgcol:=paleta[ch and 7];
				  8:lattr:=ch and 7;
          $10:bgcol:=paleta[ch and 7];
				  $18:tpattr:=ch and 7;
				end;
			end;
			// Pick up the colors for the pattern
			c_fgcol:=fgcol;
			c_bgcol:=bgcol;
			// inverse video
			if (ch and $80)<>0 then begin
				c_bgcol:=c_bgcol xor $ffff;
				c_fgcol:=c_fgcol xor $ffff;
			end;
			// blink
			if (((lattr and LATTR_BLINK)<>0) and blink_state) then c_fgcol:=c_bgcol;
			// Draw the pattern
      if (pat and $20)<>0 then ptemp^:=c_fgcol
        else ptemp^:=c_bgcol;
      inc(ptemp);
      if (pat and $10)<>0 then ptemp^:=c_fgcol
        else ptemp^:=c_bgcol;
      inc(ptemp);
      if (pat and 8)<>0 then ptemp^:=c_fgcol
        else ptemp^:=c_bgcol;
      inc(ptemp);
      if (pat and 4)<>0 then ptemp^:=c_fgcol
        else ptemp^:=c_bgcol;
      inc(ptemp);
      if (pat and 2)<>0 then ptemp^:=c_fgcol
        else ptemp^:=c_bgcol;
      inc(ptemp);
      if (pat and 1)<>0 then ptemp^:=c_fgcol
        else ptemp^:=c_bgcol;
      inc(ptemp);
	end;
  putpixel(0,linea,240,punbuf,1);
	pattr:=tpattr;
end;

procedure update_keyboard; forward;

procedure combine_keyboard;
var f:integer;
begin
  for f:=0 to 7 do key_row[f]:=key_physical[f] and key_auto[f];
  update_keyboard;
end;

// Motor control must not change the user's transport selection.
procedure sync_tape_timer;
begin
  timers.enabled(tape_timer,tape_motor and cinta_tzx.cargada and
                 cinta_tzx.play_tape and not resetting_oric);
end;

procedure eventos_oric;
begin
if event.arcade then begin
  fillchar(key_physical,8,$ff);
  if arcade_input.up[0] then key_physical[4]:=key_physical[4] and $f7;
  if arcade_input.down[0] then key_physical[4]:=key_physical[4] and $bf;
  if arcade_input.left[0] then key_physical[4]:=key_physical[4] and $df;
  if arcade_input.right[0] then key_physical[4]:=key_physical[4] and $7f;
  //Row 0
  if keyboard[KEYBOARD_7] then key_physical[0]:=key_physical[0] and $fe;
  if keyboard[KEYBOARD_n] then key_physical[0]:=key_physical[0] and $fd;
  if keyboard[KEYBOARD_5] then key_physical[0]:=key_physical[0] and $fb;
  if keyboard[KEYBOARD_v] then key_physical[0]:=key_physical[0] and $f7;
  if keyboard[KEYBOARD_1] then key_physical[0]:=key_physical[0] and $df;
  if keyboard[KEYBOARD_x] then key_physical[0]:=key_physical[0] and $bf;
  if keyboard[KEYBOARD_3] then key_physical[0]:=key_physical[0] and $7f;
  //Row 1
  if keyboard[KEYBOARD_j] then key_physical[1]:=key_physical[1] and $fe;
  if keyboard[KEYBOARD_t] then key_physical[1]:=key_physical[1] and $fd;
  if keyboard[KEYBOARD_r] then key_physical[1]:=key_physical[1] and $fb;
  if keyboard[KEYBOARD_f] then key_physical[1]:=key_physical[1] and $f7;
  if keyboard[KEYBOARD_tab] then key_physical[1]:=key_physical[1] and $df;
  if keyboard[KEYBOARD_q] then key_physical[1]:=key_physical[1] and $bf;
  if keyboard[KEYBOARD_d] then key_physical[1]:=key_physical[1] and $7f;
  //Row 2
  if keyboard[KEYBOARD_m] then key_physical[2]:=key_physical[2] and $fe;
  if keyboard[KEYBOARD_6] then key_physical[2]:=key_physical[2] and $fd;
  if keyboard[KEYBOARD_b] then key_physical[2]:=key_physical[2] and $fb;
  if keyboard[KEYBOARD_4] then key_physical[2]:=key_physical[2] and $f7;
  if keyboard[KEYBOARD_LCTRL] then key_physical[2]:=key_physical[2] and $ef;
  if keyboard[KEYBOARD_z] then key_physical[2]:=key_physical[2] and $df;
  if keyboard[KEYBOARD_2] then key_physical[2]:=key_physical[2] and $bf;
  if keyboard[KEYBOARD_c] then key_physical[2]:=key_physical[2] and $7f;
  //Row 3
  if keyboard[KEYBOARD_k] then key_physical[3]:=key_physical[3] and $fe;
  if keyboard[KEYBOARD_9] then key_physical[3]:=key_physical[3] and $fd;
  if keyboard[KEYBOARD_FILA1_T2] then key_physical[3]:=key_physical[3] and $fb;
  if keyboard[KEYBOARD_FILA3_T3] then key_physical[3]:=key_physical[3] and $f7;
  //if keyboard[KEYBOARD_LCTRL] then key_physical[3]:=key_physical[3] and $ef;
  //if keyboard[KEYBOARD_z] then key_physical[3]:=key_physical[3] and $df;
  if keyboard[KEYBOARD_FILA3_T0] then key_physical[3]:=key_physical[3] and $bf;
  if keyboard[KEYBOARD_FILA1_T1] then key_physical[3]:=key_physical[3] and $7f;
  //Row 4
  if keyboard[KEYBOARD_space] then key_physical[4]:=key_physical[4] and $fe;
  if keyboard[KEYBOARD_FILA3_T1] then key_physical[4]:=key_physical[4] and $fd;
  if keyboard[KEYBOARD_FILA3_T2] then key_physical[4]:=key_physical[4] and $fb;
  //Up --> arcade
  if keyboard[KEYBOARD_LSHIFT] then key_physical[4]:=key_physical[4] and $ef;
  //Left --> Arcade
  //Down --> Arcade
  //Right --> Arcade
  //Row 5
  if keyboard[KEYBOARD_u] then key_physical[5]:=key_physical[5] and $fe;
  if keyboard[KEYBOARD_i] then key_physical[5]:=key_physical[5] and $fd;
  if keyboard[KEYBOARD_o] then key_physical[5]:=key_physical[5] and $fb;
  if keyboard[KEYBOARD_p] then key_physical[5]:=key_physical[5] and $f7;
  if keyboard[KEYBOARD_backspace] then key_physical[5]:=key_physical[5] and $df;
  if keyboard[KEYBOARD_FILA2_T1] then key_physical[5]:=key_physical[5] and $bf;
  if keyboard[KEYBOARD_FILA2_T2] then key_physical[5]:=key_physical[5] and $7f;
  //Row 6
  if keyboard[KEYBOARD_y] then key_physical[6]:=key_physical[6] and $fe;
  if keyboard[KEYBOARD_h] then key_physical[6]:=key_physical[6] and $fd;
  if keyboard[KEYBOARD_g] then key_physical[6]:=key_physical[6] and $fb;
  if keyboard[KEYBOARD_e] then key_physical[6]:=key_physical[6] and $f7;
  if keyboard[KEYBOARD_a] then key_physical[6]:=key_physical[6] and $df;
  if keyboard[KEYBOARD_s] then key_physical[6]:=key_physical[6] and $bf;
  if keyboard[KEYBOARD_w] then key_physical[6]:=key_physical[6] and $7f;
  //Row 7
  if keyboard[KEYBOARD_8] then key_physical[7]:=key_physical[7] and $fe;
  if keyboard[KEYBOARD_l] then key_physical[7]:=key_physical[7] and $fd;
  if keyboard[KEYBOARD_0] then key_physical[7]:=key_physical[7] and $fb;
  if keyboard[KEYBOARD_FILA0_T2] then key_physical[7]:=key_physical[7] and $f7;
  if keyboard[KEYBOARD_RSHIFT] then key_physical[7]:=key_physical[7] and $ef;
  if keyboard[KEYBOARD_return] then key_physical[7]:=key_physical[7] and $df;
  if keyboard[KEYBOARD_FILA0_T1] then key_physical[7]:=key_physical[7] and $7f;
end;
combine_keyboard;
end;

procedure oric_principal;
var
  f:word;
begin
while EmuStatus=EsRunning do begin
  eventos_oric;
  for f:=0 to 311 do begin
    m6502_0.run(frame_main);
    frame_main:=frame_main+m6502_0.tframes-m6502_0.contador;
    update_video_oric(f);
  end;
  blink_counter:=(blink_counter+1) and $3f;
  video_sync;
  actualiza_trozo(0,0,240,224,1,0,0,240,224,PANT_TEMP);
end;
end;

function oric_getbyte(direccion:word):byte;
begin
case direccion of
  0..$2ff,$400..$bfff:oric_getbyte:=memoria[direccion];
  $300..$3ff:oric_getbyte:=via6522_0.read(direccion and $f);
  $c000..$ffff:oric_getbyte:=bios_rom[direccion and $3fff];
end;
end;

procedure oric_putbyte(direccion:word;valor:byte);
begin
  case direccion of
    0..$2ff,$400..$bfff:memoria[direccion]:=valor;
    $300..$3ff:via6522_0.write(direccion and $f,valor);
    $c000..$ffff:;
  end;
end;

//Microdisc
function oric_getbyte_microdisc(direccion:word):byte;
begin
case direccion of
  0..$2ff,$400..$bfff:oric_getbyte_microdisc:=memoria[direccion];
  $300..$3ff:case direccion of
                $310..$314,$318:oric_getbyte_microdisc:=microdisc_0.read(direccion and $f);
                else oric_getbyte_microdisc:=via6522_0.read(direccion and $f);
             end;
  $c000..$dfff:if (microdisc_0.port_314 and P_ROMDIS)<>0 then oric_getbyte_microdisc:=bios_rom[direccion and $3fff]
                  else oric_getbyte_microdisc:=memoria[direccion];
  $e000..$ffff:if (microdisc_0.port_314 and P_ROMDIS)<>0 then oric_getbyte_microdisc:=bios_rom[direccion and $3fff]
                  else if (microdisc_0.port_314 and P_EPROM)<>0 then oric_getbyte_microdisc:=memoria[direccion]
                    else oric_getbyte_microdisc:=microdisc_0.rom[direccion and $1fff];
end;
end;

procedure oric_putbyte_microdisc(direccion:word;valor:byte);
begin
  case direccion of
    0..$2ff,$400..$bfff:memoria[direccion]:=valor;
    $300..$3ff:case direccion of
                $310..$314:microdisc_0.write(direccion and $f,valor);
                else via6522_0.write(direccion and $f,valor);
             end;
    $c000..$dfff:if (microdisc_0.port_314 and P_ROMDIS)=0 then memoria[direccion]:=valor;
    $e000..$ffff:if (microdisc_0.port_314 and P_ROMDIS)=0 then
                    if (microdisc_0.port_314 and P_EPROM)<>0 then memoria[direccion]:=valor;
  end;
end;

procedure update_psg;
begin
	if via_ca2 then begin
		if via_cb2 then ay8910_0.control(via_a)
		  else via6522_0.write_pa(ay8910_0.read);
	end else if via_cb2 then ay8910_0.write(via_a);
end;

procedure via_a_w(valor:byte);
begin
  via_a:=valor;
	//m_cent_data_out->write(m_via_a);
	update_psg;
end;

procedure update_keyboard;
begin
  via6522_0.set_pb_line(3,(key_row[via_b and 7] or psg_a)<>$ff);
end;

procedure via_b_w(valor:byte);
begin
  via_b:=valor;
	update_keyboard;
	//m_centronics->write_strobe(data & 0x10 ? 1 : 0);
  // PB6 gates the motor; Play/Stop remains a transport/UI decision.
  if resetting_oric then tape_motor:=false
    else tape_motor:=(valor and $40)<>0;
  sync_tape_timer;
end;

procedure via_ca2_w(valor:byte);
begin
	via_ca2:=valor<>0;
	update_psg;
end;

procedure via_cb2_w(valor:byte);
begin
	via_cb2:=valor<>0;
	update_psg;
end;

procedure update_irq;
begin
  if (via_irq or ext_irq) then m6502_0.change_irq(ASSERT_LINE)
    else m6502_0.change_irq(CLEAR_LINE);
end;

procedure psg_a_w(valor:byte);
begin
  psg_a:=valor;
	update_keyboard;
end;

procedure oric_irq(valor:byte);
begin
	via_irq:=valor<>CLEAR_LINE;
	update_irq;
end;

procedure oric_ext_irq(valor:byte);
begin
  ext_irq:=valor<>CLEAR_LINE;
  update_irq;
end;

procedure oric_update_timers(estados_t:word);
begin
  via6522_0.update_timers(estados_t);
  if microdisc_0<>nil then microdisc_0.wd.run(estados_t);
  sync_tape_timer;
  if cinta_tzx.cargada then begin
    if cinta_tzx.play_tape and tape_motor then begin
      play_cinta_tzx(estados_t);
    end;
  end;
end;

procedure oric_sound_update;
begin
  tsample[tape_sound_channel,sound_status.posicion_sonido]:=(cinta_tzx.value*$20)*byte(cinta_tzx.play_tape);
  ay8910_0.update;
end;

procedure oric_tape_play;
begin
  if tape_motor and cinta_tzx.cargada and cinta_tzx.play_tape then
    via6522_0.write_cb1(cinta_tzx.value<>0);
end;

//Main
procedure oric_loaddisk;
begin
load_dsk.showmodal;
end;

procedure reset_oric;
begin
 resetting_oric:=true;
 timers.enabled(key_timer,false);
 timers.enabled(tape_timer,false);
 key_pos:=0;
 fillchar(key_physical,SizeOf(key_physical),$ff);
 fillchar(key_auto,SizeOf(key_auto),$ff);
 fillchar(key_row,SizeOf(key_row),$ff);
 tape_motor:=false;
 via_a:=$ff; via_b:=$ff; psg_a:=$ff;
 via_ca2:=false; via_cb2:=false;
 via_irq:=false; ext_irq:=false;
 if microdisc_0<>nil then microdisc_0.reset;
 m6502_0.reset;
 frame_main:=m6502_0.tframes;
 ay8910_0.reset;
 via6522_0.reset;
 // Keep cached pins consistent with the VIA reset callbacks.
 combine_keyboard;
 update_irq;
 blink_counter:=0;
 pattr:=0;
 resetting_oric:=false;
end;

procedure key_press;
const
  run_key:array[0..16] of word=($027f,$02ff,$07fd,$07ff,$05fb,$05ff,$06df,$06ff,$017f,$01ff,$04ef,$037f,$03ff,$04ff,$07df,$07ff,$ffff);
begin
if (key_pos>High(run_key)) then begin
  timers.enabled(key_timer,false);
  key_pos:=0;
  fillchar(key_auto,SizeOf(key_auto),$ff);
  combine_keyboard;
  exit;
end;
if run_key[key_pos]=$ffff then begin
  timers.enabled(key_timer,false);
  key_pos:=0;
  fillchar(key_auto,SizeOf(key_auto),$ff);
end else begin
  // Preserve other rows: Shift must stay held while the quote key is pressed.
  key_auto[run_key[key_pos] shr 8]:=run_key[key_pos] and $ff;
  inc(key_pos);
end;
combine_keyboard;
end;

procedure oric_tapes;
var
  datos:pbyte;
  longitud:integer;
  romfile,nombre_file,extension,cadena:string;
  es_cinta:boolean;
begin
  if not(openrom(romfile,SORIC)) then exit;
  getmem(datos,$200000);
  if not(extract_data(romfile,datos,longitud,nombre_file,SORIC)) then begin
    freemem(datos);
    exit;
  end;
  extension:=extension_fichero(nombre_file);
  timers.enabled(key_timer,false);
  key_pos:=0;
  fillchar(key_auto,SizeOf(key_auto),$ff);
  combine_keyboard;
  es_cinta:=false;
  if extension='TAP' then es_cinta:=abrir_oric_tap(datos,longitud);
  if extension='WAV' then es_cinta:=abrir_wav(datos,longitud,1000000);
  cadena:='';
  if es_cinta then begin
     tape_window1.edit1.Text:=nombre_file;
     tape_window1.show;
     tape_window1.BitBtn1.Enabled:=false;
     tape_window1.BitBtn2.Enabled:=true;
     // Arm transport; PB6 still decides when the signal advances.
     cinta_tzx.play_tape:=true;
     sync_tape_timer;
     cadena:=extension+': '+nombre_file;
     if main_vars.auto_type then begin
       timers.reset(key_timer);
       timers.enabled(key_timer,true);
     end;
  end;
  freemem(datos);
  directory.oric_tap:=ExtractFilePath(romfile);
  main_vars.nombre_caption:=cadena;
  change_caption;
end;

function iniciar_oric:boolean;
var
  f:byte;
  colores:tpaleta;
begin
llamadas_maquina.bucle_general:=oric_principal;
llamadas_maquina.reset:=reset_oric;
llamadas_maquina.cintas:=oric_tapes;
llamadas_maquina.cartuchos:=oric_loaddisk;
llamadas_maquina.fps_max:=50.080128;
llamadas_maquina.scanlines:=312;
iniciar_oric:=false;
if microdisc_0<>nil then begin
  microdisc_0.free;
  microdisc_0:=nil;
end;
iniciar_audio(false);
screen_init(1,240,224);
iniciar_video(240,224);
//Main CPU
m6502_0:=cpu_m6502.create(1000000,TCPU_M6502);
m6502_0.change_ram_calls(oric_getbyte,oric_putbyte);
m6502_0.init_sound(oric_sound_update);
m6502_0.change_despues_instruccion(oric_update_timers);
//Cinta 22microsegs
tape_timer:=timers.init(m6502_0.numero_cpu,1000000/45454.5454545454,oric_tape_play,nil,false);
//VIA
via6522_0:=via6522_chip.create(m6502_0.numero_cpu,1000000);
via6522_0.change_calls(nil,nil,via_a_w,via_b_w,oric_irq,via_ca2_w,via_cb2_w);
//sound chips
ay8910_0:=ay8910_chip.create(1000000,AY8912);
ay8910_0.change_io_calls(nil,nil,psg_a_w,nil);
tape_sound_channel:=init_channel;
//cargar roms
case main_vars.tipo_maquina of
  3001:begin
          if not(roms_load(@bios_rom,atmos_rom)) then exit;
          microdisc_0:=tmicrodisc.create(1000000,oric_ext_irq);
          if not(roms_load(@microdisc_0.rom,microdisc_rom)) then begin
            microdisc_0.free;
            microdisc_0:=nil;
            exit;
          end;
          // Set the overlay before the CPU fetches its reset vector.
          microdisc_0.reset;
          m6502_0.change_ram_calls(oric_getbyte_microdisc,oric_putbyte_microdisc);
       end;
  3002:if not(roms_load(@bios_rom,oric1_rom)) then exit;
end;

//paleta
for f:=0 to 7 do begin
  colores[f].r:=pal1bit(f);
  colores[f].g:=pal1bit(f shr 1);
  colores[f].b:=pal1bit(f shr 2);
end;
set_pal(colores,8);
key_timer:=timers.init(m6502_0.numero_cpu,100000,key_press,nil,false);
//final
reset_oric;
iniciar_oric:=true;
end;

end.
