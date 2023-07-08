unit oric_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6502,main_engine,controls_engine,ay_8910,gfx_engine,timer_engine,
     rom_engine,pal_engine,sound_engine,via6522,misc_functions,file_engine,
     dialogs,sysutils,tape_window,oric_disc,cargar_dsk,forms;

function iniciar_oric:boolean;

implementation
uses tap_tzx;

const
    atmos_rom:tipo_roms=(n:'basic11b.rom';l:$4000;p:$0;crc:$c3a92bef);
    oric1_rom:tipo_roms=(n:'basic10.rom';l:$4000;p:$0;crc:$f18710b4);
    microdisc_rom:tipo_roms=(n:'microdis.rom';l:$2000;p:$0;crc:$a9664a9c);
		PATTR_HIRES =$04;
		LATTR_ALT   =$01;
		LATTR_DSIZE =$02;
		LATTR_BLINK =$04;

var
  tape_sound_channel,blink_counter,pattr,via_a,via_b,psg_a,tape_timer:byte;
  bios_rom:array[0..$3fff] of byte;
  via_ca2,via_cb2,via_irq,ext_irq:boolean;
  key_row:array[0..7] of byte;

procedure update_video_oric;
var
  blink_state:boolean;
  tpattr,x,y,lattr,ch,pat,off:byte;
  base,fgcol,bgcol,c_fgcol,c_bgcol:word;
  ptemp:pword;
begin
  blink_state:=(blink_counter and $20)<>0;
	blink_counter:=(blink_counter+1) and $3f;
	tpattr:=pattr;
	for y:=0 to 223 do begin
    ptemp:=punbuf;
		// Line attributes and current colors
		lattr:=0;
		fgcol:=paleta[7];
		bgcol:=paleta[0];
		for x:=0 to 39 do begin
			// Lookup the byte and, if needed, the pattern data
			if (((tpattr and PATTR_HIRES)<>0) and (y<200)) then begin
				ch:=memoria[$a000+y*40+x];
        pat:=ch;
      end else begin
				ch:=memoria[$bb80+(y shr 3)*40+x];
        if (lattr and LATTR_DSIZE)<>0 then off:=(y shr 1) and 7
          else off:=y and 7;
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
				pat:=$00;
				case (ch and $18) of
				  $00:fgcol:=paleta[ch and 7];
				  $08:lattr:=ch and 7;
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
      if (pat and $08)<>0 then ptemp^:=c_fgcol
        else ptemp^:=c_bgcol;
      inc(ptemp);
      if (pat and $04)<>0 then ptemp^:=c_fgcol
        else ptemp^:=c_bgcol;
      inc(ptemp);
      if (pat and $02)<>0 then ptemp^:=c_fgcol
        else ptemp^:=c_bgcol;
      inc(ptemp);
      if (pat and $01)<>0 then ptemp^:=c_fgcol
        else ptemp^:=c_bgcol;
      inc(ptemp);
		end;
    putpixel(0,y,240,punbuf,1);
	end;
	pattr:=tpattr;
  actualiza_trozo(0,0,240,224,1,0,0,240,224,PANT_TEMP);
end;

procedure eventos_oric;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then key_row[4]:=(key_row[4] and $f7) else key_row[4]:=(key_row[4] or $8);
  if arcade_input.down[0] then key_row[4]:=(key_row[4] and $bf) else key_row[4]:=(key_row[4] or $40);
  if arcade_input.left[0] then key_row[4]:=(key_row[4] and $df) else key_row[4]:=(key_row[4] or $20);
  if arcade_input.right[0] then key_row[4]:=(key_row[4] and $7f) else key_row[4]:=(key_row[4] or $80);
  //P2
end else if event.keyboard then begin
  //Row 0
  if keyboard[KEYBOARD_7] then key_row[0]:=(key_row[0] and $fe) else key_row[0]:=(key_row[0] or $1);
  if keyboard[KEYBOARD_n] then key_row[0]:=(key_row[0] and $fd) else key_row[0]:=(key_row[0] or $2);
  if keyboard[KEYBOARD_5] then key_row[0]:=(key_row[0] and $fb) else key_row[0]:=(key_row[0] or $4);
  if keyboard[KEYBOARD_v] then key_row[0]:=(key_row[0] and $f7) else key_row[0]:=(key_row[0] or $8);
  if keyboard[KEYBOARD_1] then key_row[0]:=(key_row[0] and $df) else key_row[0]:=(key_row[0] or $20);
  if keyboard[KEYBOARD_x] then key_row[0]:=(key_row[0] and $bf) else key_row[0]:=(key_row[0] or $40);
  if keyboard[KEYBOARD_3] then key_row[0]:=(key_row[0] and $7f) else key_row[0]:=(key_row[0] or $80);
  //Row 1
  if keyboard[KEYBOARD_j] then key_row[1]:=(key_row[1] and $fe) else key_row[1]:=(key_row[1] or $1);
  if keyboard[KEYBOARD_t] then key_row[1]:=(key_row[1] and $fd) else key_row[1]:=(key_row[1] or $2);
  if keyboard[KEYBOARD_r] then key_row[1]:=(key_row[1] and $fb) else key_row[1]:=(key_row[1] or $4);
  if keyboard[KEYBOARD_f] then key_row[1]:=(key_row[1] and $f7) else key_row[1]:=(key_row[1] or $8);
  if keyboard[KEYBOARD_tab] then key_row[1]:=(key_row[1] and $df) else key_row[1]:=(key_row[1] or $20);
  if keyboard[KEYBOARD_q] then key_row[1]:=(key_row[1] and $bf) else key_row[1]:=(key_row[1] or $40);
  if keyboard[KEYBOARD_d] then key_row[1]:=(key_row[1] and $7f) else key_row[1]:=(key_row[1] or $80);
  //Row 2
  if keyboard[KEYBOARD_m] then key_row[2]:=(key_row[2] and $fe) else key_row[2]:=(key_row[2] or $1);
  if keyboard[KEYBOARD_6] then key_row[2]:=(key_row[2] and $fd) else key_row[2]:=(key_row[2] or $2);
  if keyboard[KEYBOARD_b] then key_row[2]:=(key_row[2] and $fb) else key_row[2]:=(key_row[2] or $4);
  if keyboard[KEYBOARD_4] then key_row[2]:=(key_row[2] and $f7) else key_row[2]:=(key_row[2] or $8);
  if keyboard[KEYBOARD_LCTRL] then key_row[2]:=(key_row[2] and $ef) else key_row[2]:=(key_row[2] or $10);
  if keyboard[KEYBOARD_z] then key_row[2]:=(key_row[2] and $df) else key_row[2]:=(key_row[2] or $20);
  if keyboard[KEYBOARD_2] then key_row[2]:=(key_row[2] and $bf) else key_row[2]:=(key_row[2] or $40);
  if keyboard[KEYBOARD_c] then key_row[2]:=(key_row[2] and $7f) else key_row[2]:=(key_row[2] or $80);
  //Row 3
  if keyboard[KEYBOARD_k] then key_row[3]:=(key_row[3] and $fe) else key_row[3]:=(key_row[3] or $1);
  if keyboard[KEYBOARD_9] then key_row[3]:=(key_row[3] and $fd) else key_row[3]:=(key_row[3] or $2);
  if keyboard[KEYBOARD_FILA1_T2] then key_row[3]:=(key_row[3] and $fb) else key_row[3]:=(key_row[3] or $4);
  if keyboard[KEYBOARD_FILA3_T3] then key_row[3]:=(key_row[3] and $f7) else key_row[3]:=(key_row[3] or $8);
  //if keyboard[KEYBOARD_LCTRL] then key_row[3]:=(key_row[3] and $ef) else key_row[3]:=(key_row[3] or $10);
  //if keyboard[KEYBOARD_z] then key_row[3]:=(key_row[3] and $df) else key_row[3]:=(key_row[3] or $20);
  if keyboard[KEYBOARD_FILA3_T0] then key_row[3]:=(key_row[3] and $bf) else key_row[3]:=(key_row[3] or $40);
  if keyboard[KEYBOARD_FILA1_T1] then key_row[3]:=(key_row[3] and $7f) else key_row[3]:=(key_row[3] or $80);
  //Row 4
  if keyboard[KEYBOARD_space] then key_row[4]:=(key_row[4] and $fe) else key_row[4]:=(key_row[4] or $1);
  if keyboard[KEYBOARD_FILA3_T1] then key_row[4]:=(key_row[4] and $fd) else key_row[4]:=(key_row[4] or $2);
  if keyboard[KEYBOARD_FILA3_T2] then key_row[4]:=(key_row[4] and $fb) else key_row[4]:=(key_row[4] or $4);
  //Up --> arcade
  if keyboard[KEYBOARD_LSHIFT] then key_row[4]:=(key_row[4] and $ef) else key_row[4]:=(key_row[4] or $10);
  //Left --> Arcade
  //Down --> Arcade
  //Right --> Arcade
  //Row 5
  if keyboard[KEYBOARD_u] then key_row[5]:=(key_row[5] and $fe) else key_row[5]:=(key_row[5] or $1);
  if keyboard[KEYBOARD_i] then key_row[5]:=(key_row[5] and $fd) else key_row[5]:=(key_row[5] or $2);
  if keyboard[KEYBOARD_o] then key_row[5]:=(key_row[5] and $fb) else key_row[5]:=(key_row[5] or $4);
  if keyboard[KEYBOARD_p] then key_row[5]:=(key_row[5] and $f7) else key_row[5]:=(key_row[5] or $8);
  if keyboard[KEYBOARD_backspace] then key_row[5]:=(key_row[5] and $df) else key_row[5]:=(key_row[5] or $20);
  if keyboard[KEYBOARD_FILA2_T1] then key_row[5]:=(key_row[5] and $bf) else key_row[5]:=(key_row[5] or $40);
  if keyboard[KEYBOARD_FILA2_T2] then key_row[5]:=(key_row[5] and $7f) else key_row[5]:=(key_row[5] or $80);
  //Row 6
  if keyboard[KEYBOARD_y] then key_row[6]:=(key_row[6] and $fe) else key_row[6]:=(key_row[6] or $1);
  if keyboard[KEYBOARD_h] then key_row[6]:=(key_row[6] and $fd) else key_row[6]:=(key_row[6] or $2);
  if keyboard[KEYBOARD_g] then key_row[6]:=(key_row[6] and $fb) else key_row[6]:=(key_row[6] or $4);
  if keyboard[KEYBOARD_e] then key_row[6]:=(key_row[6] and $f7) else key_row[6]:=(key_row[6] or $8);
  if keyboard[KEYBOARD_a] then key_row[6]:=(key_row[6] and $df) else key_row[6]:=(key_row[6] or $20);
  if keyboard[KEYBOARD_s] then key_row[6]:=(key_row[6] and $bf) else key_row[6]:=(key_row[6] or $40);
  if keyboard[KEYBOARD_w] then key_row[6]:=(key_row[6] and $7f) else key_row[6]:=(key_row[6] or $80);
  //Row 7
  if keyboard[KEYBOARD_8] then key_row[7]:=(key_row[7] and $fe) else key_row[7]:=(key_row[7] or $1);
  if keyboard[KEYBOARD_l] then key_row[7]:=(key_row[7] and $fd) else key_row[7]:=(key_row[7] or $2);
  if keyboard[KEYBOARD_0] then key_row[7]:=(key_row[7] and $fb) else key_row[7]:=(key_row[7] or $4);
  if keyboard[KEYBOARD_FILA0_T2] then key_row[7]:=(key_row[7] and $f7) else key_row[7]:=(key_row[7] or $8);
  if keyboard[KEYBOARD_RSHIFT] then key_row[7]:=(key_row[7] and $ef) else key_row[7]:=(key_row[7] or $10);
  if keyboard[KEYBOARD_return] then key_row[7]:=(key_row[7] and $df) else key_row[7]:=(key_row[7] or $20);
  if keyboard[KEYBOARD_FILA0_T1] then key_row[7]:=(key_row[7] and $7f) else key_row[7]:=(key_row[7] or $80);
end;
end;

procedure oric_principal;
var
  frame:single;
  f:word;
begin
init_controls(false,true,true,false);
frame:=m6502_0.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to 311 do begin
    //main
    m6502_0.run(frame);
    frame:=frame+m6502_0.tframes-m6502_0.contador;
  end;
  update_video_oric;
  eventos_oric;
  video_sync;
end;
end;

function oric_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$2ff,$400..$bfff:oric_getbyte:=memoria[direccion];
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
  $0..$2ff,$400..$bfff:oric_getbyte_microdisc:=memoria[direccion];
  $300..$3ff:case direccion of
                $310..$31f:oric_getbyte_microdisc:=microdisc_0.read(direccion and $f);
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
                $310..$31f:microdisc_0.write(direccion and $f,valor);
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
  //Tape Motor
  if (valor and $40)<>0 then begin
    if not(cinta_tzx.play_tape) then begin
      tape_window1.fPlayCinta(nil);
      timers.enabled(tape_timer,true);
    end;
  end else begin
    if cinta_tzx.play_tape then tape_window1.fStopCinta(nil);
    timers.enabled(tape_timer,false);
  end;
	//m_cassette->output(data & 0x80 ? -1.0 : +1.0);
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
  //microdisc_0.wd.run(estados_t);
  if cinta_tzx.cargada then begin
    if cinta_tzx.play_tape then begin
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
  via6522_0.write_cb1(cinta_tzx.value<>0);
end;

//Main
procedure oric_loaddisk;
begin
load_dsk.show;
while load_dsk.Showing do application.ProcessMessages;
end;

procedure reset_oric;
begin
 //IMPORTANTE!! Hay que resetear primero esto para que ponga los valores pordefecto!
 //microdisc_0.reset;
 m6502_0.reset;
 ay8910_0.reset;
 via6522_0.reset;
 reset_audio;
 via_a:=$ff;
 via_b:=$ff;
 psg_a:=$00;
 via_ca2:=false;
 via_cb2:=false;
 via_irq:=false;
 ext_irq:=false;
 fillchar(key_row,8,$ff);
 blink_counter:=0;
 pattr:=0;
end;

procedure oric_tapes;
var
  datos:pbyte;
  file_size:integer;
  nombre_zip,nombre_file,extension,cadena:string;
  resultado,es_cinta:boolean;
  crc:dword;
begin
  if not(OpenRom(StOric,nombre_zip)) then exit;
  extension:=extension_fichero(nombre_zip);
  resultado:=false;
  if extension='ZIP' then begin
      if not(search_file_from_zip(nombre_zip,'*.tap',nombre_file,file_size,crc,false)) then
         if not(search_file_from_zip(nombre_zip,'*.wav',nombre_file,file_size,crc,false)) then begin
            MessageDlg('Error cargando cinta/WAV.'+chr(10)+chr(13)+'Error loading tape/WAV.', mtInformation,[mbOk], 0);
            exit;
      end;
      getmem(datos,file_size);
      if not(load_file_from_zip(nombre_zip,nombre_file,datos,file_size,crc,true)) then freemem(datos)
        else resultado:=true;
  end else begin
      if read_file_size(nombre_zip,file_size) then begin
        getmem(datos,file_size);
        if not(read_file(nombre_zip,datos,file_size)) then freemem(datos)
          else resultado:=true;
        nombre_file:=extractfilename(nombre_zip);
      end;
  end;
  if not(resultado) then begin
    MessageDlg('Error cargando cinta/WAV.'+chr(10)+chr(13)+'Error loading the tape/WAV.', mtInformation,[mbOk], 0);
    exit;
  end;
  extension:=extension_fichero(nombre_file);
  resultado:=false;
  es_cinta:=true;
  if extension='TAP' then resultado:=abrir_oric_tap(datos,file_size);
  if extension='WAV' then resultado:=abrir_wav(datos,file_size,1000000);
  if es_cinta then begin
     if resultado then begin
        tape_window1.edit1.Text:=nombre_file;
        tape_window1.show;
        tape_window1.BitBtn1.Enabled:=true;
        tape_window1.BitBtn2.Enabled:=false;
        cinta_tzx.play_tape:=false;
        cadena:=extension+': '+nombre_file;
     end else begin
        MessageDlg('Error cargando cinta/WAV.'+chr(10)+chr(13)+'Error loading tape/WAV.', mtInformation,[mbOk], 0);
        cadena:='';
     end;
  end;
  freemem(datos);
  directory.oric_tap:=ExtractFilePath(nombre_zip);
  change_caption(cadena);
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
iniciar_oric:=false;
iniciar_audio(false);
screen_init(1,240,224);
iniciar_video(240,224);
//Main CPU
m6502_0:=cpu_m6502.create(1000000,312,TCPU_M6502);
m6502_0.change_ram_calls(oric_getbyte,oric_putbyte);
m6502_0.init_sound(oric_sound_update);
m6502_0.change_despues_instruccion(oric_update_timers);
//Cinta 22microsegs
tape_timer:=timers.init(m6502_0.numero_cpu,1000000/45454.5454545454,oric_tape_play,nil,false);
//VIA
via6522_0:=via6522_chip.create(1000000);
via6522_0.change_calls(nil,nil,via_a_w,via_b_w,oric_irq,via_ca2_w,via_cb2_w);
//sound chips
ay8910_0:=ay8910_chip.create(1000000,AY8910,1);
ay8910_0.change_io_calls(nil,nil,psg_a_w,nil);
tape_sound_channel:=init_channel;
//cargar roms
case main_vars.tipo_maquina of
  3001:begin
          if not(roms_load(@bios_rom,atmos_rom)) then exit;
          //microdisc_0:=tmicrodisc.create(1000000,oric_ext_irq);
          //if not(roms_load(@microdisc_0.rom,microdisc_rom)) then exit;
          //m6502_0.change_ram_calls(oric_getbyte_microdisc,oric_putbyte_microdisc);
       end;
  3002:if not(roms_load(@bios_rom,oric1_rom)) then exit;
end;
//bios_rom[$2000]:=$42;
//paleta
for f:=0 to 7 do begin
  colores[f].r:=pal1bit(f);
  colores[f].g:=pal1bit(f shr 1);
  colores[f].b:=pal1bit(f shr 2);
end;
set_pal(colores,8);
//final
reset_oric;
iniciar_oric:=true;
end;

end.
