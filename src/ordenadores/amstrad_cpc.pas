unit amstrad_cpc;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,controls_engine,ay_8910,sysutils,gfx_engine,upd765,cargar_dsk,forms,
     dialogs,rom_engine,misc_functions,main_engine,pal_engine,sound_engine,
     tape_window,file_engine,ppi8255,lenguaje,disk_file_format,config_cpc;

const
  pantalla_alto=312;
  cpc464_rom:tipo_roms=(n:'cpc464.rom';l:$8000;p:0;crc:$40852f25);
  cpc464f_rom:tipo_roms=(n:'cpc464f.rom';l:$8000;p:0;crc:$17893d60);
  cpc464sp_rom:tipo_roms=(n:'cpc464sp.rom';l:$8000;p:0;crc:$338daf2d);
  cpc464d_rom:tipo_roms=(n:'cpc464d.rom';l:$8000;p:0;crc:$260e45c3);
  cpc664_rom:tipo_roms=(n:'cpc664.rom';l:$8000;p:0;crc:$9ab5a036);
  cpc6128_rom:tipo_roms=(n:'cpc6128.rom';l:$8000;p:0;crc:$9e827fe1);
  cpc6128f_rom:tipo_roms=(n:'cpc6128f.rom';l:$8000;p:0;crc:$1574923b);
  cpc6128sp_rom:tipo_roms=(n:'cpc6128sp.rom';l:$8000;p:0;crc:$2fa2e7d6);
  cpc6128d_rom:tipo_roms=(n:'cpc6128d.rom';l:$8000;p:0;crc:$4704685a);
  ams_rom:tipo_roms=(n:'amsdos.rom';l:$4000;p:0;crc:$1fe22ecd);

type
  tcpc_crt=packed record
              char_hsync,char_total,hsync_time_ocurre:word;
              char_altura:byte;
              vsync_lines,vsync_cont:byte;
              vsync_activo,hsync_activo:boolean;
              vsync_linea_ocurre:word;
              scr_line_dir:array[0..4095] of dword;
              lineas_total,lineas_borde,lineas_visible,pixel_visible:word;
              regs:array[0..31] of byte;
              reg:byte;

              h_ctr,r_ctr,v_ctr,h_syn,h_syn_ctr,v_syn,v_syn_ctr:word;
           end;
  tcpc_ga=packed record
              pen,video_mode:byte;
              pal:array[0..16] of byte;
              lines_count,lines_sync,rom_selected:byte;
              rom_low,rom_high:boolean;
              marco:array[0..3] of byte;
              marco_latch,cpc_model,ram_exp:byte;
           end;
  tcpc_ppi=packed record
              port_a_read_latch,port_a_write_latch:byte;
              port_c_write_latch:byte;
              tape_motor:boolean;
              ay_control,keyb_line:byte;
              keyb_val:array[0..9] of byte;
              use_motor:boolean;
           end;

var
    cpc_mem:array[0..31,0..$3fff] of byte;
    cpc_rom:array[0..15,0..$3fff] of byte;
    cpc_rom_slot:array[0..15] of string;
    cpc_low_rom:array[0..$3fff] of byte;
    cpc_crt:^tcpc_crt;
    cpc_ga:tcpc_ga;
    cpc_ppi:tcpc_ppi;

procedure cargar_amstrad_CPC;
procedure cpc_load_roms;
//GA
procedure write_ga(val:byte);
//PAL
procedure write_pal(puerto:word;val:byte);
//CRT
procedure cpc_calcular_dir_scr;
procedure cpc_calc_crt;
//Main CPU
procedure cpc_outbyte(puerto:word;valor:byte);
//PPI 8255
procedure port_c_write(valor:byte);

implementation
uses principal,tap_tzx,snapshot;

const
  cpc_paleta:array[0..31] of dword=(
        $808080,$808080,$00FF80,$FFFF80,
        $000080,$FF0080,$008080,$FF8080,
        $FF0080,$FFFF80,$FFFF00,$FFFFFF,
        $FF0000,$FF00FF,$FF8000,$FF80FF,
        $000080,$00FF80,$00FF00,$00FFFF,
        $000000,$0000FF,$008000,$0080FF,
        $800080,$80FF80,$80FF00,$80FFFF,
        $800000,$8000FF,$808000,$8080FF);
  pantalla_largo=400;

var
   tape_sound_channel:byte;
   linea_crt:word;

procedure eventos_cpc;
begin
if event.keyboard then begin
//Line 0
  if keyboard[KEYBOARD_UP] then cpc_ppi.keyb_val[0]:=(cpc_ppi.keyb_val[0] and $fe) else cpc_ppi.keyb_val[0]:=(cpc_ppi.keyb_val[0] or $1);
  if keyboard[KEYBOARD_RIGHT] then cpc_ppi.keyb_val[0]:=(cpc_ppi.keyb_val[0] and $fd) else cpc_ppi.keyb_val[0]:=(cpc_ppi.keyb_val[0] or $2);
  if keyboard[KEYBOARD_DOWN] then cpc_ppi.keyb_val[0]:=(cpc_ppi.keyb_val[0] and $fb) else cpc_ppi.keyb_val[0]:=(cpc_ppi.keyb_val[0] or $4);
  if keyboard[KEYBOARD_N9] then cpc_ppi.keyb_val[0]:=(cpc_ppi.keyb_val[0] and $f7) else cpc_ppi.keyb_val[0]:=(cpc_ppi.keyb_val[0] or $8);
  if keyboard[KEYBOARD_N6] then cpc_ppi.keyb_val[0]:=(cpc_ppi.keyb_val[0] and $ef) else cpc_ppi.keyb_val[0]:=(cpc_ppi.keyb_val[0] or $10);
  if keyboard[KEYBOARD_N3] then cpc_ppi.keyb_val[0]:=(cpc_ppi.keyb_val[0] and $df) else cpc_ppi.keyb_val[0]:=(cpc_ppi.keyb_val[0] or $20);
  if keyboard[KEYBOARD_HOME] then cpc_ppi.keyb_val[0]:=(cpc_ppi.keyb_val[0] and $bf) else cpc_ppi.keyb_val[0]:=(cpc_ppi.keyb_val[0] or $40);
  if keyboard[KEYBOARD_NDOT] then cpc_ppi.keyb_val[0]:=(cpc_ppi.keyb_val[0] and $7f) else cpc_ppi.keyb_val[0]:=(cpc_ppi.keyb_val[0] or $80);
//Line 1
  if keyboard[KEYBOARD_LEFT] then cpc_ppi.keyb_val[1]:=(cpc_ppi.keyb_val[1] and $fe) else cpc_ppi.keyb_val[1]:=(cpc_ppi.keyb_val[1] or 1);
  if keyboard[KEYBOARD_LALT] then cpc_ppi.keyb_val[1]:=(cpc_ppi.keyb_val[1] and $fd) else cpc_ppi.keyb_val[1]:=(cpc_ppi.keyb_val[1] or 2);
  if keyboard[KEYBOARD_N7] then cpc_ppi.keyb_val[1]:=(cpc_ppi.keyb_val[1] and $fb) else cpc_ppi.keyb_val[1]:=(cpc_ppi.keyb_val[1] or $4);
  if keyboard[KEYBOARD_N8] then cpc_ppi.keyb_val[1]:=(cpc_ppi.keyb_val[1] and $f7) else cpc_ppi.keyb_val[1]:=(cpc_ppi.keyb_val[1] or $8);
  if keyboard[KEYBOARD_F5] then begin
    clear_disk(0);
    llamadas_maquina.open_file:='';
    change_caption;
  end;
  if keyboard[KEYBOARD_N5] then cpc_ppi.keyb_val[1]:=(cpc_ppi.keyb_val[1] and $ef) else cpc_ppi.keyb_val[1]:=(cpc_ppi.keyb_val[1] or $10);
  if keyboard[KEYBOARD_F1] then begin
      if cinta_tzx.cargada then begin
        if cinta_tzx.play_tape then tape_window1.fStopCinta(nil)
          else tape_window1.fPlayCinta(nil);
      end;
  end;
  if keyboard[KEYBOARD_N1] then cpc_ppi.keyb_val[1]:=(cpc_ppi.keyb_val[1] and $df) else cpc_ppi.keyb_val[1]:=(cpc_ppi.keyb_val[1] or $20);
  if keyboard[KEYBOARD_N2] then cpc_ppi.keyb_val[1]:=(cpc_ppi.keyb_val[1] and $bf) else cpc_ppi.keyb_val[1]:=(cpc_ppi.keyb_val[1] or $40);
  if keyboard[KEYBOARD_N0] then cpc_ppi.keyb_val[1]:=(cpc_ppi.keyb_val[1] and $7f) else cpc_ppi.keyb_val[1]:=(cpc_ppi.keyb_val[1] or $80);
//Line 2
  if keyboard[KEYBOARD_FILA0_T0] then cpc_ppi.keyb_val[2]:=(cpc_ppi.keyb_val[2] and $fe) else cpc_ppi.keyb_val[2]:=(cpc_ppi.keyb_val[2] or 1);
  if keyboard[KEYBOARD_FILA1_T2] then cpc_ppi.keyb_val[2]:=(cpc_ppi.keyb_val[2] and $fd) else cpc_ppi.keyb_val[2]:=(cpc_ppi.keyb_val[2] or 2);
  if (keyboard[KEYBOARD_RETURN] or keyboard[KEYBOARD_NRETURN]) then cpc_ppi.keyb_val[2]:=(cpc_ppi.keyb_val[2] and $fb) else cpc_ppi.keyb_val[2]:=(cpc_ppi.keyb_val[2] or 4);
  if keyboard[KEYBOARD_FILA2_T3] then cpc_ppi.keyb_val[2]:=(cpc_ppi.keyb_val[2] and $f7) else cpc_ppi.keyb_val[2]:=(cpc_ppi.keyb_val[2] or 8);
  if keyboard[KEYBOARD_N4] then cpc_ppi.keyb_val[2]:=(cpc_ppi.keyb_val[2] and $ef) else cpc_ppi.keyb_val[2]:=(cpc_ppi.keyb_val[2] or $10);
  if (keyboard[KEYBOARD_LSHIFT] or keyboard[KEYBOARD_RSHIFT]) then cpc_ppi.keyb_val[2]:=(cpc_ppi.keyb_val[2] and $df) else cpc_ppi.keyb_val[2]:=(cpc_ppi.keyb_val[2] or $20);
  if keyboard[KEYBOARD_FILA3_T3] then cpc_ppi.keyb_val[2]:=(cpc_ppi.keyb_val[2] and $bf) else cpc_ppi.keyb_val[2]:=(cpc_ppi.keyb_val[2] or $40);
  if keyboard[KEYBOARD_LCTRL] then cpc_ppi.keyb_val[2]:=(cpc_ppi.keyb_val[2] and $7f) else cpc_ppi.keyb_val[2]:=(cpc_ppi.keyb_val[2] or $80);
//Line 3
  if keyboard[KEYBOARD_FILA0_T2] then cpc_ppi.keyb_val[3]:=(cpc_ppi.keyb_val[3] and $fe) else cpc_ppi.keyb_val[3]:=(cpc_ppi.keyb_val[3] or 1);
  if keyboard[KEYBOARD_FILA0_T1] then cpc_ppi.keyb_val[3]:=(cpc_ppi.keyb_val[3] and $fd) else cpc_ppi.keyb_val[3]:=(cpc_ppi.keyb_val[3] or 2);
  if keyboard[KEYBOARD_FILA1_T1] then cpc_ppi.keyb_val[3]:=(cpc_ppi.keyb_val[3] and $fb) else cpc_ppi.keyb_val[3]:=(cpc_ppi.keyb_val[3] or 4);
  if keyboard[KEYBOARD_p] then cpc_ppi.keyb_val[3]:=(cpc_ppi.keyb_val[3] and $f7) else cpc_ppi.keyb_val[3]:=(cpc_ppi.keyb_val[3] or 8);
  if keyboard[KEYBOARD_FILA2_T2] then cpc_ppi.keyb_val[3]:=(cpc_ppi.keyb_val[3] and $ef) else cpc_ppi.keyb_val[3]:=(cpc_ppi.keyb_val[3] or $10);
  if keyboard[KEYBOARD_FILA2_T1] then cpc_ppi.keyb_val[3]:=(cpc_ppi.keyb_val[3] and $df) else cpc_ppi.keyb_val[3]:=(cpc_ppi.keyb_val[3] or $20);
  if keyboard[KEYBOARD_FILA3_T2] then cpc_ppi.keyb_val[3]:=(cpc_ppi.keyb_val[3] and $bf) else cpc_ppi.keyb_val[3]:=(cpc_ppi.keyb_val[3] or $40);
  if keyboard[KEYBOARD_FILA3_T1] then cpc_ppi.keyb_val[3]:=(cpc_ppi.keyb_val[3] and $7f) else cpc_ppi.keyb_val[3]:=(cpc_ppi.keyb_val[3] or $80);
//Line 4
  if keyboard[KEYBOARD_0] then cpc_ppi.keyb_val[4]:=(cpc_ppi.keyb_val[4] and $fe) else cpc_ppi.keyb_val[4]:=(cpc_ppi.keyb_val[4] or 1);
  if keyboard[KEYBOARD_9] then cpc_ppi.keyb_val[4]:=(cpc_ppi.keyb_val[4] and $fd) else cpc_ppi.keyb_val[4]:=(cpc_ppi.keyb_val[4] or 2);
  if keyboard[KEYBOARD_o] then cpc_ppi.keyb_val[4]:=(cpc_ppi.keyb_val[4] and $fb) else cpc_ppi.keyb_val[4]:=(cpc_ppi.keyb_val[4] or 4);
  if keyboard[KEYBOARD_i] then cpc_ppi.keyb_val[4]:=(cpc_ppi.keyb_val[4] and $f7) else cpc_ppi.keyb_val[4]:=(cpc_ppi.keyb_val[4] or 8);
  if keyboard[KEYBOARD_l] then cpc_ppi.keyb_val[4]:=(cpc_ppi.keyb_val[4] and $ef) else cpc_ppi.keyb_val[4]:=(cpc_ppi.keyb_val[4] or $10);
  if keyboard[KEYBOARD_k] then cpc_ppi.keyb_val[4]:=(cpc_ppi.keyb_val[4] and $df) else cpc_ppi.keyb_val[4]:=(cpc_ppi.keyb_val[4] or $20);
  if keyboard[KEYBOARD_m] then cpc_ppi.keyb_val[4]:=(cpc_ppi.keyb_val[4] and $bf) else cpc_ppi.keyb_val[4]:=(cpc_ppi.keyb_val[4] or $40);
  if keyboard[KEYBOARD_FILA3_T0] then cpc_ppi.keyb_val[4]:=(cpc_ppi.keyb_val[4] and $7f) else cpc_ppi.keyb_val[4]:=(cpc_ppi.keyb_val[4] or $80);
//Line 5
  if keyboard[KEYBOARD_8] then cpc_ppi.keyb_val[5]:=(cpc_ppi.keyb_val[5] and $fe) else cpc_ppi.keyb_val[5]:=(cpc_ppi.keyb_val[5] or 1);
  if keyboard[KEYBOARD_7] then cpc_ppi.keyb_val[5]:=(cpc_ppi.keyb_val[5] and $fd) else cpc_ppi.keyb_val[5]:=(cpc_ppi.keyb_val[5] or 2);
  if keyboard[KEYBOARD_u] then cpc_ppi.keyb_val[5]:=(cpc_ppi.keyb_val[5] and $fb) else cpc_ppi.keyb_val[5]:=(cpc_ppi.keyb_val[5] or 4);
  if keyboard[KEYBOARD_y] then cpc_ppi.keyb_val[5]:=(cpc_ppi.keyb_val[5] and $f7) else cpc_ppi.keyb_val[5]:=(cpc_ppi.keyb_val[5] or 8);
  if keyboard[KEYBOARD_h] then cpc_ppi.keyb_val[5]:=(cpc_ppi.keyb_val[5] and $ef) else cpc_ppi.keyb_val[5]:=(cpc_ppi.keyb_val[5] or $10);
  if keyboard[KEYBOARD_j] then cpc_ppi.keyb_val[5]:=(cpc_ppi.keyb_val[5] and $df) else cpc_ppi.keyb_val[5]:=(cpc_ppi.keyb_val[5] or $20);
  if keyboard[KEYBOARD_n] then cpc_ppi.keyb_val[5]:=(cpc_ppi.keyb_val[5] and $bf) else cpc_ppi.keyb_val[5]:=(cpc_ppi.keyb_val[5] or $40);
  if keyboard[KEYBOARD_space] then cpc_ppi.keyb_val[5]:=(cpc_ppi.keyb_val[5] and $7f) else cpc_ppi.keyb_val[5]:=(cpc_ppi.keyb_val[5] or $80);
//Line 6
  if keyboard[KEYBOARD_6] then cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] and $fe) else cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] or 1);
  if keyboard[KEYBOARD_5] then cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] and $fd) else cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] or 2);
  if keyboard[KEYBOARD_r] then cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] and $fb) else cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] or 4);
  if keyboard[KEYBOARD_t] then cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] and $f7) else cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] or 8);
  if keyboard[KEYBOARD_g] then cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] and $ef) else cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] or $10);
  if keyboard[KEYBOARD_f] then cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] and $df) else cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] or $20);
  if keyboard[KEYBOARD_b] then cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] and $bf) else cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] or $40);
  if keyboard[KEYBOARD_v] then cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] and $7f) else cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] or $80);
//Line 7
  if keyboard[KEYBOARD_4] then cpc_ppi.keyb_val[7]:=(cpc_ppi.keyb_val[7] and $fe) else cpc_ppi.keyb_val[7]:=(cpc_ppi.keyb_val[7] or 1);
  if keyboard[KEYBOARD_3] then cpc_ppi.keyb_val[7]:=(cpc_ppi.keyb_val[7] and $fd) else cpc_ppi.keyb_val[7]:=(cpc_ppi.keyb_val[7] or 2);
  if keyboard[KEYBOARD_e] then cpc_ppi.keyb_val[7]:=(cpc_ppi.keyb_val[7] and $fb) else cpc_ppi.keyb_val[7]:=(cpc_ppi.keyb_val[7] or 4);
  if keyboard[KEYBOARD_w] then cpc_ppi.keyb_val[7]:=(cpc_ppi.keyb_val[7] and $f7) else cpc_ppi.keyb_val[7]:=(cpc_ppi.keyb_val[7] or 8);
  if keyboard[KEYBOARD_s] then cpc_ppi.keyb_val[7]:=(cpc_ppi.keyb_val[7] and $ef) else cpc_ppi.keyb_val[7]:=(cpc_ppi.keyb_val[7] or $10);
  if keyboard[KEYBOARD_d] then cpc_ppi.keyb_val[7]:=(cpc_ppi.keyb_val[7] and $df) else cpc_ppi.keyb_val[7]:=(cpc_ppi.keyb_val[7] or $20);
  if keyboard[KEYBOARD_c] then cpc_ppi.keyb_val[7]:=(cpc_ppi.keyb_val[7] and $bf) else cpc_ppi.keyb_val[7]:=(cpc_ppi.keyb_val[7] or $40);
  if keyboard[KEYBOARD_x] then cpc_ppi.keyb_val[7]:=(cpc_ppi.keyb_val[7] and $7f) else cpc_ppi.keyb_val[7]:=(cpc_ppi.keyb_val[7] or $80);
//Line 8
  if keyboard[KEYBOARD_1] then cpc_ppi.keyb_val[8]:=(cpc_ppi.keyb_val[8] and $fe) else cpc_ppi.keyb_val[8]:=(cpc_ppi.keyb_val[8] or 1);
  if keyboard[KEYBOARD_2] then cpc_ppi.keyb_val[8]:=(cpc_ppi.keyb_val[8] and $fd) else cpc_ppi.keyb_val[8]:=(cpc_ppi.keyb_val[8] or 2);
  if keyboard[KEYBOARD_escape] then cpc_ppi.keyb_val[8]:=(cpc_ppi.keyb_val[8] and $fb) else cpc_ppi.keyb_val[8]:=(cpc_ppi.keyb_val[8] or 4);
  if keyboard[KEYBOARD_q] then cpc_ppi.keyb_val[8]:=(cpc_ppi.keyb_val[8] and $f7) else cpc_ppi.keyb_val[8]:=(cpc_ppi.keyb_val[8] or 8);
  if keyboard[KEYBOARD_tab] then cpc_ppi.keyb_val[8]:=(cpc_ppi.keyb_val[8] and $ef) else cpc_ppi.keyb_val[8]:=(cpc_ppi.keyb_val[8] or $10);
  if keyboard[KEYBOARD_a] then cpc_ppi.keyb_val[8]:=(cpc_ppi.keyb_val[8] and $df) else cpc_ppi.keyb_val[8]:=(cpc_ppi.keyb_val[8] or $20);
  if keyboard[KEYBOARD_CAPSLOCK] then cpc_ppi.keyb_val[8]:=(cpc_ppi.keyb_val[8] and $bf) else cpc_ppi.keyb_val[8]:=(cpc_ppi.keyb_val[8] or $40);
  if keyboard[KEYBOARD_z] then cpc_ppi.keyb_val[8]:=(cpc_ppi.keyb_val[8] and $7f) else cpc_ppi.keyb_val[8]:=(cpc_ppi.keyb_val[8] or $80);
//Line 9
  //JOY UP,JOY DOWN,JOY LEFT,JOY RIGHT,FIRE1,FIRE2 --> Arcade
  if keyboard[KEYBOARD_BACKSPACE] then cpc_ppi.keyb_val[9]:=(cpc_ppi.keyb_val[9] and $7f) else cpc_ppi.keyb_val[9]:=(cpc_ppi.keyb_val[9] or $80);

end;
if event.arcade then begin
  //P1
  if arcade_input.up[0] then cpc_ppi.keyb_val[9]:=(cpc_ppi.keyb_val[9] and $fe) else cpc_ppi.keyb_val[9]:=(cpc_ppi.keyb_val[9] or 1);
  if arcade_input.down[0] then cpc_ppi.keyb_val[9]:=(cpc_ppi.keyb_val[9] and $fd) else cpc_ppi.keyb_val[9]:=(cpc_ppi.keyb_val[9] or 2);
  if arcade_input.left[0] then cpc_ppi.keyb_val[9]:=(cpc_ppi.keyb_val[9] and $fb) else cpc_ppi.keyb_val[9]:=(cpc_ppi.keyb_val[9] or 4);
  if arcade_input.right[0] then cpc_ppi.keyb_val[9]:=(cpc_ppi.keyb_val[9] and $f7) else cpc_ppi.keyb_val[9]:=(cpc_ppi.keyb_val[9] or $8);
  if arcade_input.but0[0] then cpc_ppi.keyb_val[9]:=(cpc_ppi.keyb_val[9] and $ef) else cpc_ppi.keyb_val[9]:=(cpc_ppi.keyb_val[9] or $10);
  //P2
  if arcade_input.up[1] then cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] and $fe) else cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] or 1);
  if arcade_input.down[1] then cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] and $fd) else cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] or 2);
  if arcade_input.left[1] then cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] and $fb) else cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] or 4);
  if arcade_input.right[1] then cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] and $f7) else cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] or 8);
  if arcade_input.but0[1] then cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] and $ef) else cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] or $10);
end;
end;

procedure amstrad_ga_exec;
begin
cpc_ga.lines_count:=(cpc_ga.lines_count+1) mod 53;
//Estoy en un VSYNC?
if (cpc_ga.lines_sync>0) then begin
  //SI --> Compruebo si llevo dos lineas desde la generacion del VSYNC
  cpc_ga.lines_sync:=cpc_ga.lines_sync-1;
  if (cpc_ga.lines_sync=0) then begin
    //Si el contador es mayor de 32 lineas, genero IRQ
    if (cpc_ga.lines_count>=32) then z80_0.change_irq(ASSERT_LINE);
    //Borro el contador...
    cpc_ga.lines_count:=0;
  end;
end else begin
  //Compruebo si llevo 52 lineas
  if (cpc_ga.lines_count=52) then begin
    cpc_ga.lines_count:=0;
    z80_0.change_irq(ASSERT_LINE);
  end;
end;
end;

{Registros 6845
0 --> Numero de caracteres largo TOTAL (MENOS UNO)
      En el CPC 63
1 --> El ancho en caracteres VISIBLES de una fila.
2 --> Caracter en el que se produce el HSYNC
3 --> 4bits lo: Numero de caracteres que tarda el HSYNC
      4bits hi: Numero de caracteres que tarda el VSYNC
4 --> La altura en caracteres TOTAL de la pantalla +1
      En el CPC 38+1
5 --> Numero de lineas que faltan para completar la pantalla cuando termina un frame
      en el CPC 0
6 --> La altura en caracteres VISIBLES de la pantalla.
7 --> Numero de caracter en el que tiene que ocurrir el VSYNC
9 --> Numero de lineas por caracter (menos una), cuantas lineas necesito para dibujar un caracter
      Fijo a 7+1

Altura TOTAL= R4*(R9+1) = 39*8 = 312 lineas
Ancho TOTAL = (R0+1)*8 = 64*8 = 512 pixels}

procedure cpc_calcular_dir_scr;
var
  ma,addr,x,y:word;
begin
ma:=cpc_crt.regs[13] or ((cpc_crt.regs[12] and $3f) shl 8);
for x:=0 to (cpc_crt.regs[4] and $7f) do begin //  altura total en chars
  for y:=0 to (cpc_crt.regs[9] and $1f) do begin //altura char en lineas
    addr:=(((ma and $3ff) shl 1)+((ma and $3000) shl 2)+(y*$800)) and $ffff;
    cpc_crt.scr_line_dir[y+(x*cpc_crt.char_altura)]:=addr;
  end;
  ma:=ma+cpc_crt.regs[1];
end;
end;

procedure actualiza_linea(linea:word);
var
 x,borde,addr:word;
 marco,val,p1,p2,p3,p4,p5,p6,p7,p8:byte;
 temp1,temp2,temp3,temp4,temp5,temp6:byte;
 ptemp:pword;
begin
borde:=(pantalla_largo-cpc_crt.pixel_visible) shr 1;
addr:=cpc_crt.scr_line_dir[linea];
x:=0;
while (x<cpc_crt.char_total) do begin
  if (x<cpc_crt.pixel_visible) then begin
    marco:=addr shr 14;
    val:=cpc_mem[cpc_ga.marco[marco and $3],addr and $3fff];
    addr:=(addr+1) and $ffff;
    case cpc_ga.video_mode of
      0:begin
          // 1 5 3 7    0 4 2 6
          p1:=((val and 2) shl 2) or ((val and $20) shr 3) or ((val and 8) shr 2) or ((val and $80) shr 7);
          p2:=((val and 1) shl 3) or ((val and $10) shr 2) or ((val and 4) shr 1) or ((val and $40) shr 6);
          ptemp:=punbuf;
          ptemp^:=paleta[cpc_ga.pal[p1]];
          inc(ptemp);
          ptemp^:=paleta[cpc_ga.pal[p1]];
          inc(ptemp);
          ptemp^:=paleta[cpc_ga.pal[p2]];
          inc(ptemp);
          ptemp^:=paleta[cpc_ga.pal[p2]];
      end;
      1:begin
          // 3 7      2 6      1 5      0 4
          p1:=((val and $80) shr 7)+((val and $8) shr 2);
          p2:=((val and $40) shr 6)+((val and $4) shr 1);
          p3:=((val and $20) shr 5)+((val and $2) shr 0);
          p4:=((val and $10) shr 4)+((val and 1) shl 1);
          ptemp:=punbuf;
          ptemp^:=paleta[cpc_ga.pal[p1]];
          inc(ptemp);
          ptemp^:=paleta[cpc_ga.pal[p2]];
          inc(ptemp);
          ptemp^:=paleta[cpc_ga.pal[p3]];
          inc(ptemp);
          ptemp^:=paleta[cpc_ga.pal[p4]];
        end;
      2:begin
          // 7 6 5 4 3 2 1 0
          p1:=((val and $80) shr 7);
          p2:=((val and $40) shr 6);
          p3:=((val and $20) shr 5);
          p4:=((val and $10) shr 4);
          p5:=((val and $8) shr 3);
          p6:=((val and $4) shr 2);
          p7:=((val and $2) shr 1);
          p8:=((val and $1) shr 0);
          ptemp:=punbuf;
          temp1:=(paleta[cpc_ga.pal[p1]] and $f800) shr 11;
          temp2:=(paleta[cpc_ga.pal[p1]] and $7e0) shr 5;
          temp3:=paleta[cpc_ga.pal[p1]] and $1f;
          temp4:=(paleta[cpc_ga.pal[p2]] and $f800) shr 11;
          temp5:=(paleta[cpc_ga.pal[p2]] and $7e0) shr 5;
          temp6:=paleta[cpc_ga.pal[p2]] and $1f;
          ptemp^:=(((temp1+temp4) shr 1) shl 11) or (((temp2+temp5) shr 1) shl 5) or ((temp3+temp6) shr 1);
          inc(ptemp);
          temp1:=(paleta[cpc_ga.pal[p3]] and $f800) shr 11;
          temp2:=(paleta[cpc_ga.pal[p3]] and $7e0) shr 5;
          temp3:=paleta[cpc_ga.pal[p3]] and $1f;
          temp4:=(paleta[cpc_ga.pal[p4]] and $f800) shr 11;
          temp5:=(paleta[cpc_ga.pal[p4]] and $7e0) shr 5;
          temp6:=paleta[cpc_ga.pal[p4]] and $1f;
          ptemp^:=(((temp1+temp4) shr 1) shl 11) or (((temp2+temp5) shr 1) shl 5) or ((temp3+temp6) shr 1);
          inc(ptemp);
          temp1:=(paleta[cpc_ga.pal[p5]] and $f800) shr 11;
          temp2:=(paleta[cpc_ga.pal[p5]] and $7e0) shr 5;
          temp3:=paleta[cpc_ga.pal[p5]] and $1f;
          temp4:=(paleta[cpc_ga.pal[p6]] and $f800) shr 11;
          temp5:=(paleta[cpc_ga.pal[p6]] and $7e0) shr 5;
          temp6:=paleta[cpc_ga.pal[p6]] and $1f;
          ptemp^:=(((temp1+temp4) shr 1) shl 11) or (((temp2+temp5) shr 1) shl 5) or ((temp3+temp6) shr 1);
          inc(ptemp);
          temp1:=(paleta[cpc_ga.pal[p7]] and $f800) shr 11;
          temp2:=(paleta[cpc_ga.pal[p7]] and $7e0) shr 5;
          temp3:=paleta[cpc_ga.pal[p7]] and $1f;
          temp4:=(paleta[cpc_ga.pal[p8]] and $f800) shr 11;
          temp5:=(paleta[cpc_ga.pal[p8]] and $7e0) shr 5;
          temp6:=paleta[cpc_ga.pal[p8]] and $1f;
          ptemp^:=(((temp1+temp4) shr 1) shl 11) or (((temp2+temp5) shr 1) shl 5) or ((temp3+temp6) shr 1);
      end;
    end;
    putpixel(x+borde,linea+cpc_crt.lineas_borde,4,punbuf,1);
  end;
  x:=x+4;
end;
end;

procedure draw_line;
begin
single_line(0,(linea_crt+cpc_crt.lineas_borde) mod pantalla_alto,cpc_ga.pal[$10],pantalla_largo,1);
if (linea_crt<cpc_crt.lineas_visible) then actualiza_linea(linea_crt);
//Vsync
{if cpc_crt.vsync_activo then begin
  cpc_crt.vsync_activo:=not(cpc_crt.vsync_cont=0);
  cpc_crt.vsync_cont:=cpc_crt.vsync_cont-1;
end;
if (linea_crt=cpc_crt.vsync_linea_ocurre) then begin
  cpc_crt.vsync_cont:=cpc_crt.vsync_lines-1;
  cpc_ga.lines_sync:=3;
  cpc_crt.vsync_activo:=true;
end;}
end;

procedure cpc_main;
var
  frame:single;
begin
init_controls(false,true,true,false);
frame:=z80_0.tframes;
while EmuStatus=EsRuning do begin
  z80_0.run(frame);
  frame:=frame+z80_0.tframes-z80_0.contador;
  eventos_cpc;
  actualiza_trozo_simple(0,0,pantalla_largo,pantalla_alto,1);
  video_sync;
end;
end;

//Main CPU
function cpc_getbyte(direccion:word):byte;
begin
case direccion of
  0..$3fff:if cpc_ga.rom_low then cpc_getbyte:=cpc_low_rom[direccion]
            else cpc_getbyte:=cpc_mem[cpc_ga.marco[0],direccion];
  $4000..$7fff:cpc_getbyte:=cpc_mem[cpc_ga.marco[1],direccion and $3fff];
  $8000..$bfff:cpc_getbyte:=cpc_mem[cpc_ga.marco[2],direccion and $3fff];
  $c000..$ffff:if cpc_ga.rom_high then cpc_getbyte:=cpc_rom[cpc_ga.rom_selected,direccion and $3fff]
                else cpc_getbyte:=cpc_mem[cpc_ga.marco[3],direccion and $3fff];
end;
end;

procedure cpc_putbyte(direccion:word;valor:byte);
begin
cpc_mem[cpc_ga.marco[direccion shr 14],direccion and $3fff]:=valor;
end;

procedure write_ga(val:byte);
var
  pagina:byte;
begin
case (val shr 6) of
     $0:if (val and $10)=0 then cpc_ga.pen:=val and 15 //Select pen
                else cpc_ga.pen:=$10; //Border
     $1:cpc_ga.pal[cpc_ga.pen]:=val and 31;    //Change pen colour
     $2:begin   //ROM banking and mode switch
            cpc_ga.video_mode:=val and 3;
            cpc_ga.rom_low:=(val and 4)=0;
            cpc_ga.rom_high:=(val and 8)=0;
            if (val and $10)<>0 then begin
               cpc_ga.lines_count:=0;
               z80_0.change_irq(CLEAR_LINE);
            end;
        end;
end;
end;

procedure write_pal(puerto:word;val:byte);
var
  pagina:byte;
begin
{if cpc_ga.ram_exp=2 then begin
  if (puerto and $7800)=$7800 then begin
    copymemory(@cpc_ga.marco[0],@ram_banks[(val and 7),0],4);
    for f:=0 to 3 do begin
      if cpc_ga.marco[f]>3 then cpc_ga.marco[f]:=(4-cpc_ga.marco[f])+(((val shr 3) and 7)*4)+(((7-((puerto shr 8) and 7)) and CANTIDAD_MEMORIA_MASK)*32)+8;
    end;
    cpc_ga.marco_latch:=val and 7;
    exit;
  end;
end;}
if (val shr 6)=3 then begin
   //bits 5,4 y 3 --> indican el banco de 64K
   //bits 2, 1 y 0 --> funcion
   cpc_ga.marco[0]:=0;
   cpc_ga.marco[1]:=1;
   cpc_ga.marco[2]:=2;
   cpc_ga.marco[3]:=3;
   pagina:=((val shr 3) and 7)*4;
   case (val and 7) of
        1:cpc_ga.marco[3]:=7+pagina;
        2:begin
               cpc_ga.marco[0]:=4+pagina;
               cpc_ga.marco[1]:=5+pagina;
               cpc_ga.marco[2]:=6+pagina;
               cpc_ga.marco[3]:=7+pagina;
          end;
        3:begin
               cpc_ga.marco[1]:=3;
               cpc_ga.marco[3]:=7+pagina;
          end;
        4..7:cpc_ga.marco[1]:=pagina+(val and 3)+4;
   end;
   cpc_ga.marco_latch:=val and 7;
end;
end;

procedure cpc_calc_crt;
var
  char_hsync:word;
begin
//altura char por linea
cpc_crt.char_altura:=(cpc_crt.regs[9] and $1f)+1;
//IMPORTANTE: El ancho de los chars SIEMPRE es 8 para calcular el resto de valores
//chars totales
cpc_crt.char_total:=(cpc_crt.regs[0]+1)*8;
//char en el que ocurre el hsync (ocurre en el paso a '0' de la señal)
char_hsync:=cpc_crt.regs[2]*8;
//Total pixels por linea
if cpc_crt.regs[1]<48 then cpc_crt.pixel_visible:=cpc_crt.regs[1]*8
  else cpc_crt.pixel_visible:=48*8;
if cpc_crt.pixel_visible>pantalla_largo then cpc_crt.pixel_visible:=pantalla_largo;
if cpc_crt.pixel_visible>char_hsync then cpc_crt.pixel_visible:=char_hsync;
//Linea donde ocurre el vsync
cpc_crt.vsync_linea_ocurre:=(cpc_crt.regs[7] and $7f)*cpc_crt.char_altura;
//lineas visibles
if (cpc_crt.regs[6] and $7f)<39 then cpc_crt.lineas_visible:=(cpc_crt.regs[6] and $7f)*cpc_crt.char_altura
  else cpc_crt.lineas_visible:=39*cpc_crt.char_altura;
if cpc_crt.lineas_visible>pantalla_alto then cpc_crt.lineas_visible:=pantalla_alto;
if cpc_crt.lineas_visible>cpc_crt.vsync_linea_ocurre then cpc_crt.lineas_visible:=cpc_crt.vsync_linea_ocurre;
//lineas totales del video incluyendo las visibles
cpc_crt.lineas_total:=((cpc_crt.regs[4] and $7f)+1)*cpc_crt.char_altura;
if cpc_crt.lineas_visible<cpc_crt.lineas_total then cpc_crt.lineas_borde:=(pantalla_alto-cpc_crt.lineas_visible) shr 1
   else cpc_crt.lineas_borde:=0;
end;

procedure write_crtc(port:word;val:byte);
begin
  case ((port and $100) shr 8) of
    $0:cpc_crt.reg:=val and 31;
    $1:if cpc_crt.regs[cpc_crt.reg]<>val then begin
          cpc_crt.regs[cpc_crt.reg]:=val;
          cpc_calc_crt;
          cpc_calcular_dir_scr;
        end;
  end;
end;

procedure cpc_outbyte(puerto:word;valor:byte);
begin
if (puerto and $8000)=0 then write_pal(puerto,valor);
if (puerto and $c000)=$4000 then write_ga(valor)
  else if (puerto and $4200)=0 then write_crtc(puerto,valor)
    else if (puerto and $2000)=0 then cpc_ga.rom_selected:=valor and $f
      else if (puerto and $1000)=0 then exit //printer
        else if (puerto and $0800)=0 then pia8255_0.write((puerto and $300) shr 8,valor)
          else if (puerto and $0581)=$101 then WriteFDCData(valor);
end;

function read_crtc(port:word):byte;
var
  res:byte;
begin
res:=$ff;
if ((port and $100) shr 8)=0 then
  case cpc_crt.reg of
    10:res:=cpc_crt.regs[cpc_crt.reg] and $1f;
    12,13:res:=0;
    11,14..17:res:=cpc_crt.regs[cpc_crt.reg];
  end;
read_crtc:=res;
end;

function cpc_inbyte(puerto:word):byte;
var
  res:byte;
begin
res:=$FF;
if (puerto and $4200)=$200 then res:=read_crtc(puerto)
  else if (puerto and $0800)=0 then res:=pia8255_0.read((puerto and $300) shr 8)
    else if (puerto and $0581)=$100 then res:=ReadFDCStatus
      else if (puerto and $0581)=$101 then res:=ReadFDCData;
cpc_inbyte:=res;
end;

function amstrad_raised_z80:byte;
begin
  cpc_ga.lines_count:=cpc_ga.lines_count and $1f;
  amstrad_raised_z80:=0;
  z80_0.change_irq(CLEAR_LINE);
end;

//PPI 8255
procedure update_ay;inline;
begin
case cpc_ppi.ay_control of
  1:cpc_ppi.port_a_read_latch:=ay8910_0.read;
  2:ay8910_0.write(cpc_ppi.port_a_write_latch);
  3:ay8910_0.control(cpc_ppi.port_a_write_latch);
end;
end;

function port_a_read:byte;
begin
  update_ay;
  port_a_read:=cpc_ppi.port_a_read_latch;
end;

//El valor $7e es fijo para indicar:
// bit 0 vsync
// bits 1-3 el fabricante
// bit 4 refresco pantalla (1-50hz 0-60hz)
// bit 5 expansion port
// bit 6 print ready (1-not ready 0-ready)
// bit 7 cassete data
function port_b_read:byte;
begin
port_b_read:=$7e or (cinta_tzx.value shl 1) or cpc_crt.v_syn;//}byte(cpc_crt.vsync_activo);
end;

procedure port_a_write(valor:byte);
begin
  cpc_ppi.port_a_write_latch:=valor;
  update_ay;
end;

procedure port_c_write(valor:byte);
begin
cpc_ppi.ay_control:=((valor and $c0) shr 6);
update_ay;
if cpc_ppi.tape_motor<>((valor and $10)<>0) then begin
  cpc_ppi.tape_motor:=(valor and $10)<>0;
  if (cinta_tzx.cargada and cpc_ppi.use_motor) then begin
    if not(cpc_ppi.tape_motor) then begin
      main_screen.rapido:=false;
      tape_window1.fStopCinta(nil);
    end else begin
      main_screen.rapido:=true;
      tape_window1.fPlayCinta(nil);
      if not(cinta_tzx.play_once) then cinta_tzx.play_once:=true;
    end;
  end;
end;
cpc_ppi.keyb_line:=valor and $f;
cpc_ppi.port_c_write_latch:=valor;
end;

//AY-8910
function cpc_porta_read:byte;
begin
  cpc_porta_read:=cpc_ppi.keyb_val[cpc_ppi.keyb_line];
end;

//Sound
procedure amstrad_sound_update;
begin
tsample[tape_sound_channel,sound_status.posicion_sonido]:=(cinta_tzx.value*$20)*byte(cinta_tzx.play_tape);
ay8910_0.update;
end;

procedure clock_crt;
var
   old_h_syn,old_v_syn:word;
begin
   old_h_syn:=cpc_crt.h_syn;
   old_v_syn:=cpc_crt.v_syn;
  //h_syn_ctr --> Cuantos CHARS son necesarios para el HBLANK, durante este periodo el HBLANK esta activo
  //              Se decrementa cada vez hasta 0 y entonces se desactiva el HBLANK
  //              El valor se coje del REG[3] (los cuatro bits de abajo), y si es 0 se coje 16
  //v_syn_ctr --> Cuantas LINEAS necesita el VBLANK, durante este periodo el VBLANK esta activo
  //              Se decrementa hasta 0 y entonces VBLANK 0
  //              El valor se coje del REG[3] (los cuatro bits de arriba), y si es 0 se coje 16
  //h_sync --> HBLANK activo
  //v_sync --> VBLANK activo
  //h_ctr --> Cantidad de chars que llevo, si son iguales al REG[0]+1 !! lo pongo a 0.
  //          Miro el control vertical (v_syn_ctr), si es mayor que 0, le resto 1 y miro si es cero, de serlo desactivo VBLANK
  //          Le sumo uno al raster control (r_ctr). Compruebo si es igual al REG[9]+1 !!, de serlo pongo a 0 el r_ctr y sumo uno al control vertical, comparo v_ctr al REG[4]+1 !! y de ser igual pongo a 0 el v_ctr
  //v_ctr --> Control vertical
  //r_ctr --> Control raster
  //Al terminar todo miro si ha cambiado el estado del v_sync o del h_sync (guardandome antes de las operaciones el valor) y de ser asi, llamo a la funcion correspondiente
  if (cpc_crt.h_syn_ctr>0) then begin
    cpc_crt.h_syn_ctr:=cpc_crt.h_syn_ctr-1;
    if (cpc_crt.h_syn_ctr=0) then cpc_crt.h_syn:=0;
  end;
  cpc_crt.h_ctr:=(cpc_crt.h_ctr+1) and $ff;
  if (cpc_crt.h_ctr=(cpc_crt.regs[0]+1)) then begin // Horiz. Total
    cpc_crt.h_ctr:=0;
    if (cpc_crt.v_syn_ctr>0) then begin
      cpc_crt.v_syn_ctr:=cpc_crt.v_syn_ctr-1;
      if (cpc_crt.v_syn_ctr=0) then cpc_crt.v_syn:=0;
    end;
    cpc_crt.r_ctr:=(cpc_crt.r_ctr+1) and $1f;
    if (cpc_crt.r_ctr=((cpc_crt.regs[9] and $1f)+1)) then begin // Raster Total
      cpc_crt.r_ctr:=0;
      cpc_crt.v_ctr:=(cpc_crt.v_ctr+1) and $7f;
      if (cpc_crt.v_ctr=((cpc_crt.regs[4]and $7f)+1)) then cpc_crt.v_ctr:=0; // Verti. Total
    end;
  end;
  if ((cpc_crt.h_syn=0) and (cpc_crt.h_ctr=cpc_crt.regs[2])) then begin //Horiz. Sync Pos.
    cpc_crt.h_syn:=1;
    cpc_crt.h_syn_ctr:=cpc_crt.regs[3] and $f;
    if cpc_crt.h_syn_ctr=0 then cpc_crt.h_syn_ctr:=16;
  end;
  if ((cpc_crt.v_syn=0) and (cpc_crt.v_ctr=(cpc_crt.regs[7] and $7f))) then begin // Verti. Sync Pos.
    cpc_crt.v_syn:=1;
    cpc_crt.v_syn_ctr:=cpc_crt.regs[3] shr 4;
    if cpc_crt.v_syn_ctr=0 then cpc_crt.v_syn_ctr:=16;
  end;
  //Vsync
  if (cpc_crt.v_syn<>old_v_syn) then begin
    if cpc_crt.v_syn<>0 then cpc_ga.lines_sync:=3;
  end;
  //Hsync
  if (cpc_crt.h_syn<>old_h_syn) then begin
     if cpc_crt.h_syn<>0 then begin
      amstrad_ga_exec;
      draw_line;
      linea_crt:=(linea_crt+1) mod 312;
     end;
  end;
end;

procedure amstrad_despues_instruccion(estados_t:word);
var
   f,est_final:byte;
begin
//z80_0.get_safe_pc=$bc77
if cinta_tzx.cargada and cinta_tzx.play_tape then begin
   cinta_tzx.estados:=cinta_tzx.estados+estados_t;
   play_cinta_tzx;
end;
//Añadir tiempos de espera...
est_final:=(estados_t+3) and $fc;
z80_0.contador:=z80_0.contador+(est_final-estados_t);
//Clock a el video...
for f:=1 to (est_final div 4) do clock_crt;
end;

function amstrad_tapes:boolean;
var
  datos:pbyte;
  file_size,crc:integer;
  nombre_zip,nombre_file,extension:string;
  resultado,es_cinta:boolean;
begin
  if not(OpenRom(StAmstrad,nombre_zip)) then begin
    amstrad_tapes:=true;
    exit;
  end;
  amstrad_tapes:=false;
  extension:=extension_fichero(nombre_zip);
  if extension='ZIP' then begin
         if not(search_file_from_zip(nombre_zip,'*.cdt',nombre_file,file_size,crc,false)) then
            if not(search_file_from_zip(nombre_zip,'*.tzx',nombre_file,file_size,crc,false)) then
              if not(search_file_from_zip(nombre_zip,'*.csw',nombre_file,file_size,crc,false)) then
                if not(search_file_from_zip(nombre_zip,'*.wav',nombre_file,file_size,crc,false)) then exit;
         getmem(datos,file_size);
         if not(load_file_from_zip(nombre_zip,nombre_file,datos,file_size,crc,true)) then begin
            freemem(datos);
            exit;
         end;
  end else begin
      if not(read_file_size(nombre_zip,file_size)) then exit;
      getmem(datos,file_size);
      if not(read_file(nombre_zip,datos,file_size)) then exit;
      nombre_file:=extractfilename(nombre_zip);
  end;
  extension:=extension_fichero(nombre_file);
  resultado:=false;
  es_cinta:=true;
  amstrad_tapes:=true;
  if ((extension='CDT') or (extension='TZX')) then resultado:=abrir_tzx(datos,file_size);
  if extension='CSW' then resultado:=abrir_csw(datos,file_size);
  if extension='WAV' then resultado:=abrir_wav(datos,file_size);
  if extension='SNA' then begin
      resultado:=abrir_sna_cpc(datos,file_size);
      es_cinta:=false;
      if resultado then begin
        llamadas_maquina.open_file:='Snap: '+nombre_file;
      end else begin
        MessageDlg('Error cargando snapshot.'+chr(10)+chr(13)+'Error loading the snapshot.', mtInformation,[mbOk], 0);
        llamadas_maquina.open_file:='';
      end;
  end;
  if es_cinta then begin
     if resultado then begin
        tape_window1.edit1.Text:=nombre_file;
        tape_window1.show;
        tape_window1.BitBtn1.Enabled:=true;
        tape_window1.BitBtn2.Enabled:=false;
        cinta_tzx.play_tape:=false;
        llamadas_maquina.open_file:=extension+': '+nombre_file;
     end else begin
        MessageDlg('Error cargando cinta/CSW/WAV.'+chr(10)+chr(13)+'Error loading tape/CSW/WAV.', mtInformation,[mbOk], 0);
        llamadas_maquina.open_file:='';
     end;
  end;
  freemem(datos);
  directory.amstrad_tap:=extractfiledir(nombre_zip)+main_vars.cadena_dir;
  change_caption;
end;

function amstrad_loaddisk:boolean;
begin
load_dsk.show;
while load_dsk.Showing do application.ProcessMessages;
amstrad_loaddisk:=true;
end;

procedure grabar_amstrad;
var
  nombre:string;
  correcto:boolean;
begin
principal1.savedialog1.InitialDir:=Directory.amstrad_snap;
principal1.saveDialog1.Filter := 'SNA Format (*.SNA)|*.SNA';
if principal1.savedialog1.execute then begin
        nombre:=principal1.savedialog1.FileName;
        case principal1.SaveDialog1.FilterIndex of
          1:nombre:=changefileext(nombre,'.sna');
        end;
        if FileExists(nombre) then begin
            if MessageDlg(leng[main_vars.idioma].mensajes[3], mtWarning, [mbYes]+[mbNo],0)=7 then exit;
        end;
        case principal1.SaveDialog1.FilterIndex of
          1:correcto:=grabar_amstrad_sna(nombre);
        end;
        if not(correcto) then MessageDlg('No se ha podido guardar el snapshot!',mtError,[mbOk],0);
end;
Directory.amstrad_snap:=extractfiledir(principal1.savedialog1.FileName)+main_vars.cadena_dir;
end;

procedure cpc_config_call;
begin
  configcpc.show;
  while configcpc.Showing do application.ProcessMessages;
end;

//Main
procedure cpc_reset;
begin
  z80_0.reset;
  ay8910_0.reset;
  pia8255_0.reset;
  reset_audio;
  if cinta_tzx.cargada then cinta_tzx.play_once:=false;
  cinta_tzx.value:=0;
  ResetFDC;
  linea_crt:=0;
  //Init GA
  cpc_ga.pen:=0;
  cpc_ga.video_mode:=0;
  fillchar(cpc_ga.pal[0],16,0);
  cpc_ga.lines_count:=0;
  cpc_ga.lines_sync:=0;
  cpc_ga.rom_selected:=0;
  cpc_ga.rom_low:=true;
  cpc_ga.rom_high:=true;
  cpc_ga.marco[0]:=0;
  cpc_ga.marco[1]:=1;
  cpc_ga.marco[2]:=2;
  cpc_ga.marco[3]:=3;
  cpc_ga.marco_latch:=0;
  //cpc_ga.cpc_model; no lo toco
  //CRT
  fillchar(cpc_crt^,sizeof(tcpc_crt),0);
  cpc_crt.char_altura:=1;
  cpc_crt.lineas_total:=1;
  cpc_crt.regs[0]:=63;
  cpc_crt.regs[1]:=40;
  cpc_crt.regs[2]:=46;
  cpc_crt.regs[3]:=142;
  cpc_crt.regs[4]:=38;
  cpc_crt.regs[5]:=0;
  cpc_crt.regs[6]:=25;
  cpc_crt.regs[7]:=30;
  cpc_crt.regs[8]:=0;
  cpc_crt.regs[9]:=7;
  cpc_crt.regs[10]:=0;
  cpc_crt.regs[11]:=0;
  cpc_crt.regs[12]:=48;
  cpc_crt.regs[13]:=0;
  cpc_crt.regs[14]:=192;
  cpc_calc_crt;
  cpc_calcular_dir_scr;
  //PPI
  fillchar(cpc_ppi,sizeof(tcpc_ppi),0);
  fillchar(cpc_ppi.keyb_val[0],10,$FF);
end;

procedure cpc_load_roms;
var
  f:byte;
  memoria_temp:array[0..$7fff] of byte;
  tempb:boolean;
  long:integer;
  cadena:string;
begin
if cpc_ga.cpc_model=4 then begin
  cadena:=file_name_only(changefileext(extractfilename(cpc_rom_slot[0]),''));
  if extension_fichero(cpc_rom_slot[0])='ZIP' then tempb:=carga_rom_zip(cpc_rom_slot[0],cadena+'.ROM',@memoria_temp[0],$4000,0,false)
    else begin
      tempb:=read_file(cpc_rom_slot[0],@memoria_temp[0],long);
      if long<>$4000 then tempb:=false;
    end;
  if not(tempb) then begin
    MessageDlg('ROM not found. Loading UK ROM...', mtInformation,[mbOk], 0);
    cpc_ga.cpc_model:=0;
    if not(roms_load(@memoria_temp,@cpc6128_rom,'cpc6128.zip',sizeof(cpc6128_rom))) then exit;
  end;
  if main_vars.tipo_maquina<>7 then if not(roms_load(@cpc_rom[7,0],@ams_rom,'cpc6128.zip',sizeof(ams_rom))) then exit;
end else begin
  case main_vars.tipo_maquina of
    7:begin
      tempb:=false;
      case cpc_ga.cpc_model of
        0:tempb:=true;
        1:if not(roms_load(@memoria_temp,@cpc464f_rom,'cpc464.zip',sizeof(cpc464f_rom))) then begin
            MessageDlg('French ROM not found. Loading UK ROM...', mtInformation,[mbOk], 0);
            cpc_ga.cpc_model:=0;
            tempb:=true;
        end;
        2:if not(roms_load(@memoria_temp,@cpc464sp_rom,'cpc464.zip',sizeof(cpc464sp_rom))) then begin
            MessageDlg('Spanish ROM not found. Loading UK ROM...', mtInformation,[mbOk], 0);
            cpc_ga.cpc_model:=0;
            tempb:=true;
        end;
        3:if not(roms_load(@memoria_temp,@cpc464d_rom,'cpc464.zip',sizeof(cpc464d_rom))) then begin
            MessageDlg('Danish ROM not found. Loading UK ROM...', mtInformation,[mbOk], 0);
            cpc_ga.cpc_model:=0;
            tempb:=true;
        end;
      end;
      if tempb then if not(roms_load(@memoria_temp,@cpc464_rom,'cpc464.zip',sizeof(cpc464_rom))) then exit;
      fillchar(cpc_rom[7,0],$4000,0);
    end;
    8:begin
      if not(roms_load(@cpc_rom[7,0],@ams_rom,'cpc664.zip',sizeof(ams_rom))) then exit;
      if not(roms_load(@memoria_temp,@cpc664_rom,'cpc664.zip',sizeof(cpc664_rom))) then exit;
      cpc_ga.cpc_model:=0;
    end;
    9:begin
      if not(roms_load(@cpc_rom[7,0],@ams_rom,'cpc6128.zip',sizeof(ams_rom))) then exit;
      tempb:=false;
      case cpc_ga.cpc_model of
        0:tempb:=true;
        1:if not(roms_load(@memoria_temp,@cpc6128f_rom,'cpc6128.zip',sizeof(cpc6128f_rom))) then begin
            MessageDlg('French ROM not found. Loading UK ROM...', mtInformation,[mbOk], 0);
            cpc_ga.cpc_model:=0;
            tempb:=true;
          end;
        2:if not(roms_load(@memoria_temp,@cpc6128sp_rom,'cpc6128.zip',sizeof(cpc6128sp_rom))) then begin
            MessageDlg('Spanish ROM not found. Loading UK ROM...', mtInformation,[mbOk], 0);
            cpc_ga.cpc_model:=0;
            tempb:=true;
          end;
        3:if not(roms_load(@memoria_temp,@cpc6128d_rom,'cpc6128.zip',sizeof(cpc6128d_rom))) then begin
            MessageDlg('Danish ROM not found. Loading UK ROM...', mtInformation,[mbOk], 0);
            cpc_ga.cpc_model:=0;
            tempb:=true;
          end;
      end;
      if tempb then if not(roms_load(@memoria_temp,@cpc6128_rom,'cpc6128.zip',sizeof(cpc6128_rom))) then exit;
    end;
  end;
end;
copymemory(@cpc_low_rom[0],@memoria_temp[0],$4000);
copymemory(@cpc_rom[0,0],@memoria_temp[$4000],$4000);
//Cargar las roms de los slots, comprimidas o no...
for f:=1 to 6 do begin
  if cpc_rom_slot[f]<>'' then begin
    cadena:=file_name_only(changefileext(extractfilename(cpc_rom_slot[f]),''));
    if extension_fichero(cpc_rom_slot[f])='ZIP' then tempb:=carga_rom_zip(cpc_rom_slot[f],cadena+'.ROM',@cpc_rom[f,0],$4000,0,false)
      else begin
        tempb:=read_file(cpc_rom_slot[f],@cpc_rom[f,0],long);
        if long<>$4000 then tempb:=false;
      end;
    if not(tempb) then begin
      MessageDlg('Error loading ROM on slot '+inttostr(f)+'...', mtInformation,[mbOk], 0);
      fillchar(cpc_rom[f,0],$4000,0);
    end;
  end else fillchar(cpc_rom[f,0],$4000,0);
end;
end;

function iniciar_cpc:boolean;
var
  f:byte;
  colores:tpaleta;
begin
principal1.BitBtn10.Glyph:=nil;
principal1.ImageList2.GetBitmap(3,principal1.BitBtn10.Glyph);
iniciar_cpc:=false;
iniciar_audio(false);
screen_init(1,pantalla_largo,pantalla_alto);
iniciar_video(pantalla_largo,pantalla_alto);
//Inicializar dispositivos
getmem(cpc_crt,sizeof(tcpc_crt));
for f:=0 to 31 do begin
  colores[f].r:=cpc_paleta[f] shr 16;
  colores[f].g:=(cpc_paleta[f] shr 8) and $FF;
  colores[f].b:=cpc_paleta[f] and $FF;
end;
set_pal(colores,32);
z80_0:=cpu_z80.create(4000000,1);
z80_0.change_ram_calls(cpc_getbyte,cpc_putbyte);
z80_0.change_io_calls(cpc_inbyte,cpc_outbyte);
z80_0.change_misc_calls(amstrad_despues_instruccion,amstrad_raised_z80);
z80_0.init_sound(amstrad_sound_update);
tape_sound_channel:=init_channel;
//El CPC lee el teclado el puerto A del AY, pero el puerto B esta unido al A
//por lo que hay programas que usan el B!!! (Bestial Warrior por ejemplo)
//Esto tengo que revisarlo
ay8910_0:=ay8910_chip.create(1000000,AY8910,1);
ay8910_0.change_io_calls(cpc_porta_read,cpc_porta_read,nil,nil);
pia8255_0:=pia8255_chip.create;
pia8255_0.change_ports(port_a_read,port_b_read,nil,port_a_write,nil,port_c_write);
cpc_load_roms;
cpc_reset;
iniciar_cpc:=true;
end;

procedure cpc_close;
begin
if cpc_crt<>nil then freemem(cpc_crt);
clear_disk(0);
clear_disk(1);
cpc_crt:=nil;
end;

procedure Cargar_amstrad_CPC;
begin
llamadas_maquina.iniciar:=iniciar_cpc;
llamadas_maquina.bucle_general:=cpc_main;
llamadas_maquina.reset:=cpc_reset;
llamadas_maquina.fps_max:=50.080128205;
llamadas_maquina.close:=cpc_close;
llamadas_maquina.cintas:=amstrad_tapes;
llamadas_maquina.cartuchos:=amstrad_loaddisk;
llamadas_maquina.grabar_snapshot:=grabar_amstrad;
llamadas_maquina.configurar:=cpc_config_call;
end;

end.
