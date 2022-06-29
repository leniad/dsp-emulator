unit amstrad_cpc;

interface

uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,controls_engine,ay_8910,sysutils,gfx_engine,upd765,cargar_dsk,forms,
     dialogs,rom_engine,misc_functions,main_engine,pal_engine,sound_engine,
     tape_window,file_engine,ppi8255,lenguaje,disk_file_format,config_cpc,
     timer_engine;

const
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
  cpc_paleta:array[0..31] of dword=(
        $808080,$808080,$00FF80,$FFFF80,
        $000080,$FF0080,$008080,$FF8080,
        $FF0080,$FFFF80,$FFFF00,$FFFFFF,
        $FF0000,$FF00FF,$FF8000,$FF80FF,
        $000080,$00FF80,$00FF00,$00FFFF,
        $000000,$0000FF,$008000,$0080FF,
        $800080,$80FF80,$80FF00,$80FFFF,
        $800000,$8000FF,$808000,$8080FF);
  cpc_green:array[0..31] of byte=(
        13,13,19,25,1,7,10,16,7,25,24,26,6,8,15,17,1,19,
        18,20,0,2,9,11,4,22,21,23,3,5,12,14);
  GREENFRAQ=(255 shl 16)/26;

type
  tcpc_crt=packed record
              char_total,pixel_visible:word;
              regs:array[0..31] of byte;
              reg:byte;
              //otro
              was_hsync,was_vsync,line_is_visible:boolean;
              character_counter,hsync_counter,vsync_counter:byte;
              state_hsync,is_in_adjustment_period,state_vsync:boolean;
              state_row_address,adj_count:byte;
              end_of_line_address,state_refresh_address,line_address,linea_crt:word;
              color_monitor:boolean;
           end;
  tcpc_ga=packed record
              pen,nvideo,video_mode:byte;
              pal:array[0..16] of byte;
              lines_count,lines_sync,rom_selected:byte;
              change_video,rom_low,rom_high:boolean;
              marco:array[0..3] of byte;
              marco_latch,cpc_model,ram_exp:byte;
           end;
  tcpc_ppi=packed record
              port_a_read_latch,port_a_write_latch:byte;
              port_c_write_latch:byte;
              tape_motor:boolean;
              ay_control,keyb_line:byte;
              keyb_val:array[0..9] of byte;
           end;
  tcpc_rom=packed record
              data:array[0..$3fff] of byte;
              enabled:boolean;
              name:string;
           end;
  tcpc_dandanator=packed record
              enabled:boolean;
              rom:array[0..31,0..$3fff] of byte;
              fd_count:byte;
              zone0_ena,zone1_ena,halted,wait_ret:boolean;
              zone0_seg,zone1_seg,zone0_rom,zone1_rom:byte;
              follow_rom:byte;
              follow_rom_ena:boolean;
              wait_data:byte;
           end;

var
    cpc_mem:array[0..31,0..$3fff] of byte;
    cpc_rom:array[0..16] of tcpc_rom;
    cpc_crt:tcpc_crt;
    cpc_ga:tcpc_ga;
    cpc_ppi:tcpc_ppi;
    cpc_dandanator:tcpc_dandanator;
    tape_timer:byte;
    cpc_line:word;

function iniciar_cpc:boolean;
procedure cpc_load_roms;
//GA
procedure write_ga(val:byte);
//PAL
procedure write_ram(puerto:word;val:byte);
//Main CPU
procedure cpc_outbyte(puerto:word;valor:byte);
//PPI 8255
procedure port_c_write(valor:byte);

implementation

uses principal,tap_tzx,snapshot;

const
  PANTALLA_LARGO=400;//384;
  PANTALLA_ALTO=312;//272;
  PANTALLA_VSYNC=16;

var
   tape_sound_channel:byte;

procedure eventos_cpc;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then cpc_ppi.keyb_val[9]:=(cpc_ppi.keyb_val[9] and $fe) else cpc_ppi.keyb_val[9]:=(cpc_ppi.keyb_val[9] or 1);
  if arcade_input.down[0] then cpc_ppi.keyb_val[9]:=(cpc_ppi.keyb_val[9] and $fd) else cpc_ppi.keyb_val[9]:=(cpc_ppi.keyb_val[9] or 2);
  if arcade_input.left[0] then cpc_ppi.keyb_val[9]:=(cpc_ppi.keyb_val[9] and $fb) else cpc_ppi.keyb_val[9]:=(cpc_ppi.keyb_val[9] or 4);
  if arcade_input.right[0] then cpc_ppi.keyb_val[9]:=(cpc_ppi.keyb_val[9] and $f7) else cpc_ppi.keyb_val[9]:=(cpc_ppi.keyb_val[9] or $8);
  if arcade_input.but0[0] then cpc_ppi.keyb_val[9]:=(cpc_ppi.keyb_val[9] and $ef) else cpc_ppi.keyb_val[9]:=(cpc_ppi.keyb_val[9] or $10);
  if arcade_input.but1[0] then cpc_ppi.keyb_val[9]:=(cpc_ppi.keyb_val[9] and $df) else cpc_ppi.keyb_val[9]:=(cpc_ppi.keyb_val[9] or $20);
  //P2
  if arcade_input.up[1] then cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] and $fe) else cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] or 1);
  if arcade_input.down[1] then cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] and $fd) else cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] or 2);
  if arcade_input.left[1] then cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] and $fb) else cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] or 4);
  if arcade_input.right[1] then cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] and $f7) else cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] or 8);
  if arcade_input.but0[1] then cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] and $ef) else cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] or $10);
  if arcade_input.but1[1] then cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] and $df) else cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] or $20);
end else if event.keyboard then begin
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
      keyboard[KEYBOARD_F1]:=false;
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
end;

procedure amstrad_ga_exec;
begin
//Esto hay que revisarlo... No está bien!! JameBond007 y Saboteur II
//Compruebo si llevo 52 lineas
if (cpc_ga.lines_count>=52) then begin
  cpc_ga.lines_count:=0;
  z80_0.change_irq(ASSERT_LINE);
end;
//Estoy en un pre-VSYNC?
if (cpc_ga.lines_sync>0) then begin
  //SI --> Compruebo si llevo dos lineas desde la generacion del VSYNC
  cpc_ga.lines_sync:=cpc_ga.lines_sync-1;
  if (cpc_ga.lines_sync=0) then begin
    //Si el contador es mayor de 32 lineas, genero IRQ
    if (cpc_ga.lines_count>=32) then z80_0.change_irq(ASSERT_LINE);
    cpc_ga.lines_count:=0;
    //exit; //Si pongo esto Saboteur II funciona, pero el resto va peor (aparece un linea en DL2)
  end;
end;
cpc_ga.lines_count:=cpc_ga.lines_count+1;
end;

procedure actualiza_linea;
var
 addr,x,borde,temp1,temp2,temp3,pal1,pal2:word;
 val,p1,p2,p3,p4,p5,p6,p7,p8:byte;
 ptemp:pword;
begin
borde:=(PANTALLA_LARGO-cpc_crt.pixel_visible) shr 1;
addr:=((cpc_crt.line_address and $3ff) shl 1) or
							((cpc_crt.state_row_address and $7) shl 11) or
							((cpc_crt.line_address and $3000) shl 2);
x:=0;
ptemp:=punbuf;
while (x<cpc_crt.char_total) do begin
  if (x<cpc_crt.pixel_visible) then begin
    //IMPORTANTE: La memoria de video SIEMPRE esta en los 64K mapeados... Por ejemplo Thunder Cats
    val:=cpc_mem[addr shr 14,addr and $3fff];
    //Con esto se hace el scroll por hardware...
    if (addr and $7ff)=$7ff then addr:=addr and $f800
      else addr:=addr+1;
    case cpc_ga.video_mode of
      0:begin
          // 1 5 3 7    0 4 2 6
          p1:=((val and 2) shl 2) or ((val and $20) shr 3) or ((val and 8) shr 2) or ((val and $80) shr 7);
          p2:=((val and 1) shl 3) or ((val and $10) shr 2) or ((val and 4) shr 1) or ((val and $40) shr 6);
          ptemp^:=paleta[cpc_ga.pal[p1]];
          inc(ptemp);
          ptemp^:=paleta[cpc_ga.pal[p1]];
          inc(ptemp);
          ptemp^:=paleta[cpc_ga.pal[p2]];
          inc(ptemp);
          ptemp^:=paleta[cpc_ga.pal[p2]];
          inc(ptemp);
      end;
      1:begin
          // 3 7      2 6      1 5      0 4
          p1:=((val and $80) shr 7)+((val and $8) shr 2);
          p2:=((val and $40) shr 6)+((val and $4) shr 1);
          p3:=((val and $20) shr 5)+((val and $2) shr 0);
          p4:=((val and $10) shr 4)+((val and 1) shl 1);
          ptemp^:=paleta[cpc_ga.pal[p1]];
          inc(ptemp);
          ptemp^:=paleta[cpc_ga.pal[p2]];
          inc(ptemp);
          ptemp^:=paleta[cpc_ga.pal[p3]];
          inc(ptemp);
          ptemp^:=paleta[cpc_ga.pal[p4]];
          inc(ptemp);
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
          pal1:=paleta[cpc_ga.pal[p1]];
          pal2:=paleta[cpc_ga.pal[p2]];
          temp1:=(((pal1 and $f800)+(pal2 and $f800)) shr 1) and $f800;
          temp2:=(((pal1 and $7e0)+(pal2 and $7e0)) shr 1) and $7e0;
          temp3:=(((pal1 and $1f)+(pal2 and $1f)) shr 1) and $1f;
          ptemp^:=temp1 or temp2 or temp3;
          inc(ptemp);
          pal1:=paleta[cpc_ga.pal[p3]];
          pal2:=paleta[cpc_ga.pal[p4]];
          temp1:=(((pal1 and $f800)+(pal2 and $f800)) shr 1) and $f800;
          temp2:=(((pal1 and $7e0)+(pal2 and $7e0)) shr 1) and $7e0;
          temp3:=(((pal1 and $1f)+(pal2 and $1f)) shr 1) and $1f;
          ptemp^:=temp1 or temp2 or temp3;
          inc(ptemp);
          pal1:=paleta[cpc_ga.pal[p5]];
          pal2:=paleta[cpc_ga.pal[p6]];
          temp1:=(((pal1 and $f800)+(pal2 and $f800)) shr 1) and $f800;
          temp2:=(((pal1 and $7e0)+(pal2 and $7e0)) shr 1) and $7e0;
          temp3:=(((pal1 and $1f)+(pal2 and $1f)) shr 1) and $1f;
          ptemp^:=temp1 or temp2 or temp3;
          inc(ptemp);
          pal1:=paleta[cpc_ga.pal[p7]];
          pal2:=paleta[cpc_ga.pal[p8]];
          temp1:=(((pal1 and $f800)+(pal2 and $f800)) shr 1) and $f800;
          temp2:=(((pal1 and $7e0)+(pal2 and $7e0)) shr 1) and $7e0;
          temp3:=(((pal1 and $1f)+(pal2 and $1f)) shr 1) and $1f;
          ptemp^:=temp1 or temp2 or temp3;
          inc(ptemp);
      end;
    end;
  end;
  x:=x+4;
end;
putpixel(borde,cpc_line,cpc_crt.pixel_visible,punbuf,1);
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
  actualiza_trozo(0,0,PANTALLA_LARGO,PANTALLA_ALTO-PANTALLA_VSYNC,1,0,0,PANTALLA_LARGO,PANTALLA_ALTO-PANTALLA_VSYNC,PANT_TEMP);
  video_sync;
end;
end;

//Main CPU
function cpc_getbyte(direccion:word):byte;
begin
case direccion of
  0..$3fff:if (not(cpc_dandanator.follow_rom_ena) and  cpc_dandanator.enabled and cpc_dandanator.zone0_ena and (cpc_dandanator.zone0_seg=0)) then cpc_getbyte:=cpc_dandanator.rom[cpc_dandanator.zone0_rom,direccion]
            else if cpc_ga.rom_low then begin
                  if not(cpc_dandanator.follow_rom_ena) then cpc_getbyte:=cpc_rom[16].data[direccion]
                    else cpc_getbyte:=cpc_dandanator.rom[cpc_dandanator.follow_rom,direccion];
                 end else cpc_getbyte:=cpc_mem[cpc_ga.marco[0],direccion];
  $4000..$7fff:if (cpc_dandanator.enabled and cpc_dandanator.zone1_ena and (cpc_dandanator.zone1_seg=0)) then cpc_getbyte:=cpc_dandanator.rom[cpc_dandanator.zone1_rom,direccion and $3fff]
                  else cpc_getbyte:=cpc_mem[cpc_ga.marco[1],direccion and $3fff];
  $8000..$bfff:if (cpc_dandanator.enabled and cpc_dandanator.zone0_ena and (cpc_dandanator.zone0_seg=1)) then cpc_getbyte:=cpc_dandanator.rom[cpc_dandanator.zone0_rom,direccion and $3fff]
                else cpc_getbyte:=cpc_mem[cpc_ga.marco[2],direccion and $3fff];
  $c000..$ffff:if (cpc_dandanator.enabled and cpc_dandanator.zone1_ena and (cpc_dandanator.zone1_seg=1)) then cpc_getbyte:=cpc_dandanator.rom[cpc_dandanator.zone1_rom,direccion and $3fff]
                  else if cpc_ga.rom_high then cpc_getbyte:=cpc_rom[cpc_ga.rom_selected].data[direccion and $3fff]
                          else cpc_getbyte:=cpc_mem[cpc_ga.marco[3],direccion and $3fff];
end;
end;

procedure cpc_putbyte(direccion:word;valor:byte);
begin
cpc_mem[cpc_ga.marco[direccion shr 14],direccion and $3fff]:=valor;
end;

procedure write_ram(puerto:word;val:byte);
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
   //bits 5,4 y 3 --> indican el banco de 64K
   //bits 2, 1 y 0 --> funcion
   cpc_ga.marco[0]:=0;
   cpc_ga.marco[1]:=1;
   cpc_ga.marco[2]:=2;
   cpc_ga.marco[3]:=3;
   if main_vars.tipo_maquina<>9 then exit;
   if cpc_ga.ram_exp=1 then pagina:=(((val shr 3) and 7)+1)*4
    else pagina:=4;
   case (val and 7) of
        1:cpc_ga.marco[3]:=3+pagina;
        2:begin
               cpc_ga.marco[0]:=0+pagina;
               cpc_ga.marco[1]:=1+pagina;
               cpc_ga.marco[2]:=2+pagina;
               cpc_ga.marco[3]:=3+pagina;
          end;
        3:begin
               cpc_ga.marco[1]:=3;
               cpc_ga.marco[3]:=3+pagina;
          end;
        4:cpc_ga.marco[1]:=0+pagina;
        5:cpc_ga.marco[1]:=1+pagina;
        6:cpc_ga.marco[1]:=2+pagina;
        7:cpc_ga.marco[1]:=3+pagina;
   end;
   cpc_ga.marco_latch:=val and 7;
end;

procedure write_ga(val:byte);
begin
case (val shr 6) of
     $0:if (val and $10)=0 then cpc_ga.pen:=val and $f //Select pen
                else cpc_ga.pen:=$10; //Border
     $1:cpc_ga.pal[cpc_ga.pen]:=val and $1f;    //Change pen colour
     $2:begin   //ROM banking and mode switch
            //if (cpc_ga.video_mode<>(val and 3)) then begin
              cpc_ga.nvideo:=val and 3;
              cpc_ga.change_video:=true;
            //end;
            cpc_ga.rom_low:=(val and 4)=0;
            cpc_ga.rom_high:=(val and 8)=0;
            if (val and $10)<>0 then begin
               cpc_ga.lines_count:=0;
               z80_0.change_irq(CLEAR_LINE);
            end;
        end;
     3:write_ram(0,val);
end;
end;

procedure write_crtc(port:byte;val:byte);
const
  masks:array[0..$f] of byte=($ff,$ff,$ff,$ff,$7f,$1f,$7f,$7f,$ff,$1f,$7f,$1f,$3f,$ff,$3f,$ff);
begin
  case (port and $3) of
    $0:cpc_crt.reg:=val and $1f;
    $1:if (cpc_crt.regs[cpc_crt.reg]<>val) then begin
          cpc_crt.regs[cpc_crt.reg]:=val and masks[cpc_crt.reg];
          case cpc_crt.reg of
            0:cpc_crt.char_total:=(cpc_crt.regs[0]+1)*8;
            1:if cpc_crt.regs[1]<50 then cpc_crt.pixel_visible:=cpc_crt.regs[1]*8
                else cpc_crt.pixel_visible:=49*8;
            5:if cpc_crt.adj_count<>0 then begin
                cpc_crt.is_in_adjustment_period:=false;
                cpc_crt.line_address:=(cpc_crt.regs[12] shl 8) or cpc_crt.regs[13];
                cpc_crt.state_refresh_address:=cpc_crt.line_address;
                cpc_crt.linea_crt:=0;
                cpc_crt.adj_count:=0;
              end;
          end;
    end;
    $2,$3:; //Sin uso
  end;
end;

procedure cpc_outbyte(puerto:word;valor:byte);
begin
//Se pueden seleccionar multiples dispositivos EXCEPTO GA y CRTC
if (puerto and $c000)=$4000 then write_ga(valor)
  else if (puerto and $4000)=0 then write_crtc(puerto shr 8,valor);
//if (puerto and $c000)=$4000 then write_ga(valor);
//if (puerto and $4000)=0 then write_crtc(puerto shr 8,valor);
if (puerto and $2000)=0 then begin
  if cpc_rom[valor and $f].enabled then cpc_ga.rom_selected:=valor and $f
    else cpc_ga.rom_selected:=0;
end;
if (puerto and $1000)=0 then exit; //printer
if (puerto and $0800)=0 then pia8255_0.write((puerto and $300) shr 8,valor);
if (puerto and $0400)=0 then begin //Expansion
  //puerto and $20=0 Serial
  //puerto and $40=0 Reserved
  if (puerto and $80)=0 then begin //FDC
    case (puerto and $101) of
      $0,1:WriteFDCMotor(valor); //FDC Motor
      $100,$101:WriteFDCData(valor); //FDC Data
    end;
  end
end;
end;

function read_crtc(port:byte):byte;
var
  res:byte;
begin
res:=0;
case (port and 3) of
  0,1:; //Write only
  2:res:=$80;
  3:case cpc_crt.reg of
        //10:res:=cpc_crt.regs[cpc_crt.reg] and $1f;
        //12,13:res:=0;
        //11,14..17:res:=cpc_crt.regs[cpc_crt.reg];
        12..17:res:=cpc_crt.regs[cpc_crt.reg];
      end;
end;
read_crtc:=res;
end;

function cpc_inbyte(puerto:word):byte;
var
  res:byte;
begin
res:=$ff;
if (puerto and $4000)=0 then res:=read_crtc(puerto shr 8);
if (puerto and $0800)=0 then res:=pia8255_0.read((puerto and $300) shr 8);
if (puerto and $0400)=0 then begin //Expansion
  //puerto and $20=0 Serial
  //puerto and $40=0 Reserved
  if (puerto and $80)=0 then begin //FDC
    case (puerto and $101) of
      $0,1:; //Not used
      $100:res:=ReadFDCStatus; //FDC Main status
      $101:res:=ReadFDCData //FDC Read data
    end;
  end;
end;
cpc_inbyte:=res;
end;

function amstrad_raised_z80:byte;
begin
  cpc_ga.lines_count:=cpc_ga.lines_count and $1f;
  z80_0.change_irq(CLEAR_LINE);
  amstrad_raised_z80:=0;
end;

//PPI 8255
procedure update_ay;inline;
begin
case cpc_ppi.ay_control of
  0:cpc_ppi.port_a_read_latch:=$ff;
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
  port_b_read:=$7e or (cinta_tzx.value shl 1) or byte(cpc_crt.state_vsync);
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
if cinta_tzx.cargada then begin
  if (valor and $10)<>0 then begin
    cpc_ppi.tape_motor:=true;
    timers.enabled(tape_timer,true);
  end else cpc_ppi.tape_motor:=false;
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

procedure adjust;
begin
  if (cpc_crt.adj_count=cpc_crt.regs[5]) then begin
			cpc_crt.is_in_adjustment_period:=false;
      cpc_crt.line_address:=(cpc_crt.regs[12] shl 8) or cpc_crt.regs[13];
      cpc_crt.state_refresh_address:=cpc_crt.line_address;
      cpc_crt.linea_crt:=0;
      cpc_crt.adj_count:=0; //IMPORTANTE: lo debo poner a 0, por si modifican el reg5!!!
      cpc_crt.line_is_visible:=true;
  end else cpc_crt.adj_count:=cpc_crt.adj_count+1;
end;

procedure do_end_of_line;
var
  tempb:byte;
begin
  //draw_line
  single_line(0,cpc_line,paleta[cpc_ga.pal[$10]],PANTALLA_LARGO,1);
  if cpc_crt.line_is_visible then actualiza_linea;
  cpc_line:=(cpc_line+1) mod 312;
  //Importante este orden!! O 'titus de fox' no va...
  if cpc_crt.state_vsync then begin
      tempb:=cpc_crt.regs[3] shr 4;
      if tempb=0 then tempb:=16;
      cpc_crt.vsync_counter:=cpc_crt.vsync_counter+1;
      if cpc_crt.vsync_counter=tempb then cpc_crt.state_vsync:=false;
  end;
  if (cpc_crt.regs[4]>=cpc_crt.regs[7]) then begin
    if (cpc_crt.linea_crt=cpc_crt.regs[7]) then begin
      cpc_crt.state_vsync:=true;
      cpc_crt.vsync_counter:=0;
    end;
  end;
  if cpc_crt.is_in_adjustment_period then adjust
    else begin
      if (cpc_crt.state_row_address=cpc_crt.regs[9]) then begin
          cpc_crt.state_row_address:=0;
					cpc_crt.line_address:=cpc_crt.end_of_line_address;
					if (cpc_crt.linea_crt=cpc_crt.regs[4]) then begin
              cpc_crt.is_in_adjustment_period:=true;
              cpc_crt.adj_count:=0;
              adjust;
					end else begin
            cpc_crt.linea_crt:=(cpc_crt.linea_crt+1) and $7f;
          end;
      end else cpc_crt.state_row_address:=(cpc_crt.state_row_address+1) and $1f;
      if cpc_crt.linea_crt=cpc_crt.regs[6] then cpc_crt.line_is_visible:=false;
  end;
  if (not(cpc_crt.was_vsync) and cpc_crt.state_vsync) then cpc_ga.lines_sync:=2;
  if (cpc_crt.was_vsync and not(cpc_crt.state_vsync)) then cpc_line:=0;
end;

procedure clock_alt;
begin
  if cpc_crt.state_hsync then begin
    cpc_crt.hsync_counter:=cpc_crt.hsync_counter+1;
    if cpc_crt.hsync_counter=(cpc_crt.regs[3] and $f) then cpc_crt.state_hsync:=false;
  end;
  if (cpc_crt.regs[0]>=cpc_crt.regs[2]) then begin
    if (cpc_crt.character_counter=cpc_crt.regs[2]) then begin
      cpc_crt.hsync_counter:=0;
      cpc_crt.state_hsync:=true;
    end;
  end;
  if (cpc_crt.character_counter=cpc_crt.regs[1]) then cpc_crt.end_of_line_address:=cpc_crt.state_refresh_address
    else cpc_crt.state_refresh_address:=(cpc_crt.state_refresh_address+1) and $3fff;
  if (cpc_crt.character_counter=cpc_crt.regs[0]) then begin
      do_end_of_line;
      cpc_crt.character_counter:=0;
      cpc_crt.state_refresh_address:=cpc_crt.line_address;
  end else cpc_crt.character_counter:=cpc_crt.character_counter+1;
  if (cpc_crt.was_hsync and not(cpc_crt.state_hsync)) then amstrad_ga_exec;
  if (not(cpc_crt.was_hsync) and cpc_crt.state_hsync) then begin
    if cpc_ga.change_video then begin
        cpc_ga.video_mode:=cpc_ga.nvideo;
        cpc_ga.change_video:=false;
    end;
  end;
  cpc_crt.was_vsync:=cpc_crt.state_vsync;
  cpc_crt.was_hsync:=cpc_crt.state_hsync;
end;

procedure amstrad_despues_instruccion(estados_t:word);
var
   f,est_final:byte;
begin
//Añadir tiempos de espera...
est_final:=(estados_t+3) and $fc;
if (cinta_tzx.cargada and cinta_tzx.play_tape) then play_cinta_tzx(estados_t);
z80_0.contador:=z80_0.contador+(est_final-estados_t);
//Clock a el video...
for f:=1 to (est_final div 4) do clock_alt;
end;

procedure amstrad_m1_detect(opcode:byte);
var
  z80:npreg_z80;
begin
if (cpc_dandanator.halted or not(cpc_dandanator.enabled)) then exit;
if (cpc_dandanator.wait_ret and (opcode=$c9)) then begin
  cpc_dandanator.zone0_seg:=(cpc_dandanator.wait_data and $4) shr 2;
  cpc_dandanator.zone1_seg:=(cpc_dandanator.wait_data and $8) shr 3;
  cpc_dandanator.zone0_ena:=(cpc_dandanator.wait_data and $1)=0;
  cpc_dandanator.zone1_ena:=(cpc_dandanator.wait_data and $2)=0;
  cpc_dandanator.halted:=(cpc_dandanator.wait_data and $20)<>0;
  if (cpc_dandanator.wait_data and $10)<>0 then cpc_dandanator.follow_rom_ena:=true;
  cpc_dandanator.wait_ret:=false;
end;
if (cpc_dandanator.wait_ret or cpc_dandanator.halted) then exit;
if opcode=$fd then cpc_dandanator.fd_count:=cpc_dandanator.fd_count+1;
if ((cpc_dandanator.fd_count=2) and (opcode<>$fd)) then begin
      z80:=z80_0.get_internal_r;
      case opcode of
        $70:begin //reg B Zone0
              cpc_dandanator.zone0_rom:=z80.bc.h and $1f;
              cpc_dandanator.zone0_ena:=(z80.bc.h and $20)=0;
            end;
        $71:begin //reg C Zone1
              cpc_dandanator.zone1_rom:=z80.bc.l and $1f;
              cpc_dandanator.zone1_ena:=(z80.bc.l and $20)=0;
            end;
        $77:begin //reg A config
              if (z80.a and $80)<>0 then begin
                if (z80.a and $40)=0 then begin
                    cpc_dandanator.zone0_seg:=(z80.a and $4) shr 2;
                    cpc_dandanator.zone1_seg:=(z80.a and $8) shr 3;
                    cpc_dandanator.zone0_ena:=(z80.a and $1)=0;
                    cpc_dandanator.zone1_ena:=(z80.a and $2)=0;
                    cpc_dandanator.halted:=(z80.a and $20)<>0;
                end else begin
                    cpc_dandanator.wait_ret:=true;
                    cpc_dandanator.wait_data:=z80.a;
                end;
              end else begin
                cpc_dandanator.follow_rom:=28+((z80.a and $18) shr 3)
              end;
            end
      end;
end;
if opcode<>$fd then cpc_dandanator.fd_count:=0;
end;

procedure cpc_reset;
begin
  z80_0.reset;
  ay8910_0.reset;
  pia8255_0.reset;
  reset_audio;
  if cinta_tzx.cargada then cinta_tzx.play_once:=false;
  cinta_tzx.value:=0;
  ResetFDC;
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
  cpc_ga.change_video:=false;
  cpc_ga.nvideo:=0;
  //cpc_ga.cpc_model; no lo toco
  //PPI
  fillchar(cpc_ppi,sizeof(tcpc_ppi),0);
  fillchar(cpc_ppi.keyb_val[0],10,$ff);
  //Dandanator
  cpc_dandanator.halted:=false;
  cpc_dandanator.wait_ret:=false;
  cpc_dandanator.zone0_ena:=true;
  cpc_dandanator.zone1_ena:=false;
  cpc_dandanator.zone0_seg:=0;
  cpc_dandanator.zone1_seg:=0;
  cpc_dandanator.zone0_rom:=0;
  cpc_dandanator.zone1_rom:=0;
  cpc_dandanator.follow_rom_ena:=false;
  //CRT
  fillchar(cpc_crt.regs,$20,0);
  cpc_crt.linea_crt:=0;
  cpc_crt.was_hsync:=false;
  cpc_crt.was_vsync:=false;
  cpc_crt.character_counter:=0;
  cpc_crt.hsync_counter:=0;
  cpc_crt.vsync_counter:=0;
  cpc_crt.state_hsync:=false;
  cpc_crt.state_vsync:=false;
  cpc_crt.is_in_adjustment_period:=false;
  cpc_crt.state_row_address:=0;
  cpc_crt.line_is_visible:=false;
  cpc_crt.end_of_line_address:=0;
  cpc_crt.state_refresh_address:=0;
  cpc_crt.line_address:=0;
end;

function abrir_dandanator(datos:pbyte;file_size:integer):boolean;
var
  f:byte;
  ptemp:pbyte;
begin
  abrir_dandanator:=false;
  if file_size>524288 then exit;
  ptemp:=datos;
  for f:=0 to (file_size div 16384) do begin
    copymemory(@cpc_dandanator.rom[f,0],ptemp,$4000);
    inc(ptemp,$4000);
  end;
  cpc_dandanator.enabled:=true;
  abrir_dandanator:=true;
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
  cpc_dandanator.enabled:=false;
  amstrad_tapes:=false;
  extension:=extension_fichero(nombre_zip);
  if extension='ZIP' then begin
         if not(search_file_from_zip(nombre_zip,'*.cdt',nombre_file,file_size,crc,false)) then
            if not(search_file_from_zip(nombre_zip,'*.tzx',nombre_file,file_size,crc,false)) then
              if not(search_file_from_zip(nombre_zip,'*.csw',nombre_file,file_size,crc,false)) then
                if not(search_file_from_zip(nombre_zip,'*.rom',nombre_file,file_size,crc,false)) then
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
  if extension='ROM' then begin
    resultado:=abrir_dandanator(datos,file_size);
    es_cinta:=false;
    if resultado then begin
        llamadas_maquina.open_file:='ROM: '+nombre_file;
        cpc_reset;
      end else begin
        MessageDlg('Error cargando ROM.'+chr(10)+chr(13)+'Error loading the ROM.', mtInformation,[mbOk], 0);
        llamadas_maquina.open_file:='';
      end;
  end;
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
        cpc_ppi.tape_motor:=false;
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
  indice:byte;
begin
if SaveRom(StAmstrad,nombre,indice) then begin
        case indice of
          1:nombre:=changefileext(nombre,'.sna');
        end;
        if FileExists(nombre) then begin
            if MessageDlg(leng[main_vars.idioma].mensajes[3], mtWarning, [mbYes]+[mbNo],0)=7 then exit;
        end;
        case indice of
          1:correcto:=grabar_amstrad_sna(nombre);
        end;
        if not(correcto) then MessageDlg('No se ha podido guardar el snapshot!',mtError,[mbOk],0);
end;
Directory.amstrad_snap:=extractfiledir(nombre)+main_vars.cadena_dir;
end;

procedure cpc_config_call;
begin
  configcpc.show;
  while configcpc.Showing do application.ProcessMessages;
end;

procedure tape_timer_exec;
begin
if cpc_ppi.tape_motor then begin //Poner en marcha la cinta
  if not(cinta_tzx.play_tape) then begin
    main_screen.rapido:=true;
    tape_window1.fPlayCinta(nil);
    if not(cinta_tzx.play_once) then cinta_tzx.play_once:=true;
  end;
end else begin //Pararla
  main_screen.rapido:=false;
  timers.enabled(tape_timer,false);
  if cinta_tzx.play_tape then tape_window1.fStopCinta(nil);
end;
end;

//Main
procedure cpc_load_roms;
var
  f:byte;
  memoria_temp:array[0..$7fff] of byte;
  tempb:boolean;
  long:integer;
  cadena:string;
begin
for f:=0 to 15 do cpc_rom[f].enabled:=false;
if cpc_ga.cpc_model=4 then begin
  cadena:=file_name_only(changefileext(extractfilename(cpc_rom[0].name),''));
  if extension_fichero(cpc_rom[0].name)='ZIP' then tempb:=carga_rom_zip(cpc_rom[0].name,cadena+'.ROM',@memoria_temp[0],$4000,0,false)
    else begin
      tempb:=read_file(cpc_rom[0].name,@memoria_temp[0],long);
      if long<>$4000 then tempb:=false;
    end;
  if not(tempb) then begin
    MessageDlg('ROM not found. Loading UK ROM...', mtInformation,[mbOk], 0);
    cpc_ga.cpc_model:=0;
    if not(roms_load(@memoria_temp,cpc6128_rom)) then exit;
  end;
  if main_vars.tipo_maquina<>7 then begin
    if not(roms_load(@cpc_rom[7].data,ams_rom)) then exit;
    cpc_rom[7].enabled:=true;
  end;
  cpc_rom[0].enabled:=true;
end else begin
  case main_vars.tipo_maquina of
    7:begin
      tempb:=false;
      case cpc_ga.cpc_model of
        0:tempb:=true;
        1:if not(roms_load(@memoria_temp,cpc464f_rom)) then begin
            MessageDlg('French ROM not found. Loading UK ROM...', mtInformation,[mbOk], 0);
            cpc_ga.cpc_model:=0;
            tempb:=true;
        end;
        2:if not(roms_load(@memoria_temp,cpc464sp_rom)) then begin
            MessageDlg('Spanish ROM not found. Loading UK ROM...', mtInformation,[mbOk], 0);
            cpc_ga.cpc_model:=0;
            tempb:=true;
        end;
        3:if not(roms_load(@memoria_temp,cpc464d_rom)) then begin
            MessageDlg('Danish ROM not found. Loading UK ROM...', mtInformation,[mbOk], 0);
            cpc_ga.cpc_model:=0;
            tempb:=true;
        end;
      end;
      if tempb then if not(roms_load(@memoria_temp,cpc464_rom)) then exit;
      cpc_rom[0].enabled:=true;
    end;
    8:begin
      if not(roms_load(@cpc_rom[7].data,ams_rom)) then exit;
      cpc_rom[7].enabled:=true;
      if not(roms_load(@memoria_temp,cpc664_rom)) then exit;
      cpc_ga.cpc_model:=0;
      cpc_rom[0].enabled:=true;
    end;
    9:begin
      if not(roms_load(@cpc_rom[7].data[0],ams_rom)) then exit;
      cpc_rom[7].enabled:=true;
      tempb:=false;
      case cpc_ga.cpc_model of
        0:tempb:=true;
        1:if not(roms_load(@memoria_temp,cpc6128f_rom)) then begin
            MessageDlg('French ROM not found. Loading UK ROM...', mtInformation,[mbOk], 0);
            cpc_ga.cpc_model:=0;
            tempb:=true;
          end;
        2:if not(roms_load(@memoria_temp,cpc6128sp_rom)) then begin
            MessageDlg('Spanish ROM not found. Loading UK ROM...', mtInformation,[mbOk], 0);
            cpc_ga.cpc_model:=0;
            tempb:=true;
          end;
        3:if not(roms_load(@memoria_temp,cpc6128d_rom)) then begin
            MessageDlg('Danish ROM not found. Loading UK ROM...', mtInformation,[mbOk], 0);
            cpc_ga.cpc_model:=0;
            tempb:=true;
          end;
      end;
      if tempb then if not(roms_load(@memoria_temp,cpc6128_rom)) then exit;
      cpc_rom[0].enabled:=true;
    end;
  end;
end;
//copymemory(@cpc_low_rom,@memoria_temp,$4000);
copymemory(@cpc_rom[16].data,@memoria_temp,$4000);
copymemory(@cpc_rom[0].data,@memoria_temp[$4000],$4000);
//Cargar las roms de los slots, comprimidas o no...
for f:=1 to 6 do begin
  if cpc_rom[f].name<>'' then begin
    cadena:=file_name_only(changefileext(extractfilename(cpc_rom[f].name),''));
    if extension_fichero(cpc_rom[f].name)='ZIP' then tempb:=carga_rom_zip(cpc_rom[f].name,cadena+'.ROM',@cpc_rom[f].data,$4000,0,false)
      else begin
        tempb:=read_file(cpc_rom[f].name,@cpc_rom[f].data,long);
        if long<>$4000 then tempb:=false
          else cpc_rom[f].enabled:=true;
      end;
    if not(tempb) then MessageDlg('Error loading ROM on slot '+inttostr(f)+'...', mtInformation,[mbOk],0);
  end;
end;
end;

procedure cpc_stop_tape;
begin
cpc_ppi.tape_motor:=false;
end;

procedure cpc_close;
begin
clear_disk(0);
clear_disk(1);
end;

function iniciar_cpc:boolean;
var
  f:byte;
  colores:tpaleta;
begin
llamadas_maquina.bucle_general:=cpc_main;
llamadas_maquina.reset:=cpc_reset;
llamadas_maquina.fps_max:=50.080128205;
llamadas_maquina.close:=cpc_close;
llamadas_maquina.cintas:=amstrad_tapes;
llamadas_maquina.cartuchos:=amstrad_loaddisk;
llamadas_maquina.grabar_snapshot:=grabar_amstrad;
llamadas_maquina.configurar:=cpc_config_call;
principal1.BitBtn10.Glyph:=nil;
principal1.ImageList2.GetBitmap(3,principal1.BitBtn10.Glyph);
iniciar_cpc:=false;
iniciar_audio(false);
screen_init(1,PANTALLA_LARGO,PANTALLA_ALTO);
iniciar_video(PANTALLA_LARGO,PANTALLA_ALTO-PANTALLA_VSYNC);
//Inicializar dispositivos
if cpc_crt.color_monitor then begin
  for f:=0 to 31 do begin
    colores[f].r:=cpc_paleta[f] shr 16;
    colores[f].g:=(cpc_paleta[f] shr 8) and $ff;
    colores[f].b:=cpc_paleta[f] and $ff;
  end;
end else begin
  for f:=0 to 31 do begin
    colores[f].r:=0;
    colores[f].b:=0;
    colores[f].g:=(trunc(cpc_green[f]*GREENFRAQ) shr 16) and $ff;
  end;
end;
set_pal(colores,32);
z80_0:=cpu_z80.create(4000000,1);
z80_0.change_ram_calls(cpc_getbyte,cpc_putbyte);
z80_0.change_io_calls(cpc_inbyte,cpc_outbyte);
z80_0.change_misc_calls(amstrad_despues_instruccion,amstrad_raised_z80,amstrad_m1_detect);
z80_0.init_sound(amstrad_sound_update);
tape_sound_channel:=init_channel;
tape_timer:=timers.init(z80_0.numero_cpu,100,tape_timer_exec,nil,false);
//El CPC lee el teclado el puerto A del AY, pero el puerto B esta unido al A
//por lo que hay programas que usan el B!!! (Bestial Warrior por ejemplo)
//Esto tengo que revisarlo
ay8910_0:=ay8910_chip.create(1000000,AY8910,1);
ay8910_0.change_io_calls(cpc_porta_read,cpc_porta_read,nil,nil);
pia8255_0:=pia8255_chip.create;
pia8255_0.change_ports(port_a_read,port_b_read,nil,port_a_write,nil,port_c_write);
//m6845_0:=chip_m6845.create(HD6845S,cpc_bus_cycle1,cpc_bus_cycle2);
cpc_load_roms;
cpc_reset;
TZX_CLOCK:=4000;
cinta_tzx.tape_stop:=cpc_stop_tape;
iniciar_cpc:=true;
end;

end.
