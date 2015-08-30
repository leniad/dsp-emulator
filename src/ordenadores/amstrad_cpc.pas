unit amstrad_cpc;

interface
uses sdl2,{$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,controls_engine,ay_8910,sysutils,gfx_engine,upd765,cargar_dsk,forms,
     dialogs,rom_engine,misc_functions,main_engine,pal_engine,sound_engine,
     tape_window,file_engine,ppi8255,lenguaje,disk_file_format;

const
  ram_banks:array[0..7,0..3] of byte=(
        (0,1,2,3),(0,1,2,7),(4,5,6,7),(0,3,2,7),
        (0,4,2,3),(0,5,2,3),(0,6,2,3),(0,7,2,3));
  pantalla_alto=312;
  cpc6128_rom:tipo_roms=(n:'cpc6128.rom';l:$8000;p:0;crc:$9e827fe1);
  cpc464_rom:tipo_roms=(n:'cpc464.rom';l:$8000;p:0;crc:$40852f25);
  cpc646_rom:tipo_roms=(n:'cpc664.rom';l:$8000;p:0;crc:$9ab5a036);
  ams_rom:tipo_roms=(n:'amsdos.rom';l:$4000;p:0;crc:$1fe22ecd);

type
  tcpc_crt=packed record
              char_hsync,char_total:word;
              char_altura:byte;
              vsync_lines,vsync_cont:byte;
              vsync_activo:boolean;
              vsync_linea_ocurre:word;
              scr_line_dir:array[0..(pantalla_alto-1)] of dword;
              lineas_total,lineas_borde,lineas_visible,pixel_visible:word;
              regs:array[0..31] of byte;
              reg:byte;
           end;
  tcpc_ga=packed record
              pen,video_mode,video_mode_new:byte;
              video_change:boolean;
              pal:array[0..16] of byte;
              lines_count,lines_sync,rom_selected:byte;
              rom_low,rom_high:boolean;
              marco:array[0..3] of byte;
              marco_latch:byte;
           end;
  tcpc_ppi=packed record
              port_a_read_latch,port_a_write_latch:byte;
              port_c_write_latch:byte;
              tape_motor:boolean;
              ay_control,keyb_line:byte;
              keyb_val:array[0..9] of byte;
           end;

var
    cpc_mem:array[0..10,0..$3fff] of byte;
    cpc_crt:^tcpc_crt;
    cpc_ga:^tcpc_ga;
    cpc_ppi:^tcpc_ppi;

procedure Cargar_amstrad_CPC;
function iniciar_cpc:boolean;
procedure cpc_main;
procedure cpc_close;
procedure cpc_reset;
//Tape/Disk
function amstrad_tapes:boolean;
procedure amstrad_despues_instruccion(estados_t:word);
function amstrad_loaddisk:boolean;
procedure grabar_amstrad;
//Main CPU
function cpc_getbyte(direccion:word):byte;
procedure cpc_putbyte(direccion:word;valor:byte);
function cpc_inbyte(puerto:word):byte;
procedure cpc_outbyte(valor:byte;puerto:word);
function cpc_porta_read:byte;
function amstrad_raised_z80:byte;
procedure amstrad_sound_update;
//GA
procedure write_ga(val:byte);
//CRT
procedure write_crtc(port:word;val:byte);
procedure cpc_calcular_dir_scr;
procedure cpc_calc_crt;
//PPI 8255
function port_a_read:byte;
function port_b_read:byte;
procedure port_a_write(valor:byte);
procedure port_c_write(valor:byte);

implementation
uses principal,tap_tzx,snapshot;
const
  TO1=7; //8??
  z80_op:array[0..$ff] of byte=(
  //0   1   2   3   4   5   6   7   8   9   a   b   c   d   e   f
    4, 12,  8,  8,  4,  4,  8,  4,  4, 12,  8,  8,  4,  4,  8,  4,  //0*
   12, 12,  8,  8,  4,  4,  8,  4, 12, 12,  8,  8,  4,  4,  8,  4,  //10*
    8, 12, 20,  8,  4,  4,  8,  4,  8, 12, 20,  8,  4,  4,  8,  4,  //20*
    8, 12, 16,  8, 12, 12, 12,  4,  8, 12, 16,  8,  4,  4,  8,  4,  //30*
    4,  4,  4,  4,  4,  4,  8,  4,  4,  4,  4,  4,  4,  4,  8,  4,  //40*
    4,  4,  4,  4,  4,  4,  8,  4,  4,  4,  4,  4,  4,  4,  8,  4,  //50*
    4,  4,  4,  4,  4,  4,  8,  4,  4,  4,  4,  4,  4,  4,  8,  4,  //60*
    8,  8,  8,  8,  8,  8,  4,  8,  4,  4,  4,  4,  4,  4,  8,  4,  //70*
    4,  4,  4,  4,  4,  4,  8,  4,  4,  4,  4,  4,  4,  4,  8,  4,  //80*
    4,  4,  4,  4,  4,  4,  8,  4,  4,  4,  4,  4,  4,  4,  8,  4,  //90*
    4,  4,  4,  4,  4,  4,  8,  4,  4,  4,  4,  4,  4,  4,  8,  4,  //A0*
    4,  4,  4,  4,  4,  4,  8,  4,  4,  4,  4,  4,  4,  4,  8,  4,  //B0*
    8, 12, 12, 12, 12, 16,  8, 16,  8, 12, 12,  0, 12, 20,  8, 16,  //C0*
    8, 12, 12, 12, 12, 20,  8, 16,  8,  4, 12, 12, 12,  0,  8, 16,  //D0*
    8, 12, 12, 24, 12, 16,TO1, 20,  8,  4, 12,  4, 12,  0,  8, 16,  //E0
    8, 12, 12,  4, 12, 16,  8, 16,  8,  8, 12,  4, 12,  0,  8, 16); //F0

  z80_op_cb:array[0..$ff] of byte=(
		8,  8,  8,  8,  8,  8, 16,  8,  8,  8,  8,  8,  8,  8, 16,  8, //0
    8,  8,  8,  8,  8,  8, 16,  8,  8,  8,  8,  8,  8,  8, 16,  8, //10
    8,  8,  8,  8,  8,  8, 16,  8,  8,  8,  8,  8,  8,  8, 16,  8, //20
    8,  8,  8,  8,  8,  8, 16,  8,  8,  8,  8,  8,  8,  8, 16,  8, //30
    8,  8,  8,  8,  8,  8, 12,  8,  8,  8,  8,  8,  8,  8, 12,  8, //40
    8,  8,  8,  8,  8,  8, 12,  8,  8,  8,  8,  8,  8,  8, 12,  8, //50
    8,  8,  8,  8,  8,  8, 12,  8,  8,  8,  8,  8,  8,  8, 12,  8, //60
    8,  8,  8,  8,  8,  8, 12,  8,  8,  8,  8,  8,  8,  8, 12,  8, //70
    8,  8,  8,  8,  8,  8, 16,  8,  8,  8,  8,  8,  8,  8, 16,  8, //80
    8,  8,  8,  8,  8,  8, 16,  8,  8,  8,  8,  8,  8,  8, 16,  8,
    8,  8,  8,  8,  8,  8, 16,  8,  8,  8,  8,  8,  8,  8, 16,  8,
    8,  8,  8,  8,  8,  8, 16,  8,  8,  8,  8,  8,  8,  8, 16,  8,
    8,  8,  8,  8,  8,  8, 16,  8,  8,  8,  8,  8,  8,  8, 16,  8,
    8,  8,  8,  8,  8,  8, 16,  8,  8,  8,  8,  8,  8,  8, 16,  8,
    8,  8,  8,  8,  8,  8, 16,  8,  8,  8,  8,  8,  8,  8, 16,  8,
    8,  8,  8,  8,  8,  8, 16,  8,  8,  8,  8,  8,  8,  8, 16,  8);
  TE1=12; //16??

  z80_op_ed:array[0..$ff] of byte=(
  //0   1   2   3   4   5   6   7   8   9   a   b   c   d   e   f
		8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,
    8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,
    8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,
    8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8, //30
   16, 16, 16, 24,  8, 16,  8, 12, 16, 16, 16, 24,  8, 16,  8, 12, //40
   16, 16, 16, 24,  8, 16,  8, 12, 16, 16, 16, 24,  8, 16,  8, 12, //50
   16, 16, 16, 24,  8, 16,  8, 20, 16, 16, 16, 24,  8, 16,  8, 20, //60
   16, 16, 16, 24,  8, 16,  8,  8,TE1, 16, 16, 24,  8, 16,  8,  8, //70
    8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8, //80
    8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8, //90
   20, 20, 20, 20,  8,  8,  8,  8, 20, 20, 20, 20,  8,  8,  8,  8, //a0
   20, 20, 20, 20,  8,  8,  8,  8, 20, 20, 20, 20,  8,  8,  8,  8, //b0
    8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,
    8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,
    8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,
    8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8);

  z80_op_dd:array[0..$ff] of byte=(
  //0   1   2   3   4   5   6   7   8   9   a   b   c   d   e   f
		8, 16, 12, 12,  8,  8, 12,  8,  8, 16, 12, 12,  8,  8, 12,  8,  //0
   16, 16, 12, 12,  8,  8, 12,  8, 16, 16, 12, 12,  8,  8, 12,  8,  //1
   12, 16, 24, 12,  8,  8, 12,  8, 12, 16, 24, 12,  8,  8, 12,  8,  //2
   12, 16, 20, 12, 24, 24, 24,  8, 12, 16, 20, 12,  8,  8, 12,  8,  //3
    8,  8,  8,  8,  8,  8, 20,  8,  8,  8,  8,  8,  8,  8, 20,  8,  //4
    8,  8,  8,  8,  8,  8, 20,  8,  8,  8,  8,  8,  8,  8, 20,  8,  //5
    8,  8,  8,  8,  8,  8, 20,  8,  8,  8,  8,  8,  8,  8, 20,  8,  //6
   20, 20, 20, 20, 20, 20,  8, 20,  8,  8,  8,  8,  8,  8, 20,  8,  //7
    8,  8,  8,  8,  8,  8, 20,  8,  8,  8,  8,  8,  8,  8, 20,  8,  //8
    8,  8,  8,  8,  8,  8, 20,  8,  8,  8,  8,  8,  8,  8, 20,  8,  //9
    8,  8,  8,  8,  8,  8, 20,  8,  8,  8,  8,  8,  8,  8, 20,  8,  //a
    8,  8,  8,  8,  8,  8, 20,  8,  8,  8,  8,  8,  8,  8, 20,  8,  //b
   12, 16, 16, 16, 16, 20, 12, 20, 12, 16, 16,  0, 16, 24, 12, 20,  //c
   12, 16, 16, 12, 16, 20, 12, 20, 12,  8, 16, 16, 16,  8, 12, 20,  //d
   12, 20, 16, 28, 16, 20, 12, 20, 12,  8, 16,  8, 16,  8, 12, 20,  //e
   12, 16, 16,  8, 16, 20, 12, 20, 12, 12, 16,  8, 16,  8, 12, 20); //f
  z80_op_ddcb:array[0..$ff] of byte=(
	 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28,
   28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28,
   28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28,
   28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28,
   24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24,
   24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24,
   24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24,
   24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24,
   28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28,
   28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28,
   28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28,
   28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28,
   28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28,
   28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28,
   28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28,
   28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28);

   z80_op_ex:array[0..255] of byte=(
  //0   1   2   3   4   5   6   7   8   9   a   b   c   d   e   f
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
    4,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
    4,  0,  0,  0,  0,  0,  0,  0,  4,  0,  0,  0,  0,  0,  0,  0, //20
    4,  0,  0,  0,  0,  0,  0,  0,  4,  0,  0,  0,  0,  0,  0,  0, //30
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, //40
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, //50
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, //60
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, //70
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, //80
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, //90
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, //a0
    4,  4,  4,  4,  0,  0,  0,  0,  4,  4,  4,  4,  0,  0,  0,  0, //b0
    8,  0,  0,  0,  8,  0,  0,  0,  8,  0,  0,  0,  8,  0,  0,  0, //c0
    8,  0,  0,  0,  8,  0,  0,  0,  8,  0,  0,  0,  8,  0,  0,  0, //d0
    8,  0,  0,  0,  8,  0,  0,  0,  8,  0,  0,  0,  8,  0,  0,  0, //e0
    8,  0,  0,  0,  8,  0,  0,  0,  8,  0,  0,  0,  8,  0,  0,  0);//f0

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

procedure Cargar_amstrad_CPC;
begin
llamadas_maquina.iniciar:=iniciar_cpc;
llamadas_maquina.bucle_general:=cpc_main;
llamadas_maquina.reset:=cpc_reset;
llamadas_maquina.fps_max:=50.08;
llamadas_maquina.velocidad_cpu:=4000000;
llamadas_maquina.cerrar:=cpc_close;
llamadas_maquina.cintas:=amstrad_tapes;
llamadas_maquina.cartuchos:=amstrad_loaddisk;
llamadas_maquina.grabar_snapshot:=grabar_amstrad;
end;

function iniciar_cpc:boolean;
var
  f:byte;
  colores:tpaleta;
  memoria_temp:array[0..$7fff] of byte;
begin
//Lateral
principal1.Panel2.Visible:=true;
//Botones Lateral
principal1.BitBtn9.visible:=true;
principal1.BitBtn11.visible:=true;
principal1.BitBtn10.visible:=true;
principal1.BitBtn10.Glyph:=nil;
principal1.ImageList2.GetBitmap(3,principal1.BitBtn10.Glyph);
principal1.BitBtn9.enabled:=true;
principal1.BitBtn11.enabled:=true;
if main_vars.tipo_maquina<>7 then principal1.BitBtn10.enabled:=true;
iniciar_cpc:=false;
iniciar_audio(false);
screen_init(1,pantalla_largo,pantalla_alto);
iniciar_video(pantalla_largo,pantalla_alto);
//Inicializar dispositivos
getmem(cpc_crt,sizeof(tcpc_crt));
getmem(cpc_ga,sizeof(tcpc_ga));
getmem(cpc_ppi,sizeof(tcpc_ppi));
for f:=0 to 31 do begin
  colores[f].r:=cpc_paleta[f] shr 16;
  colores[f].g:=(cpc_paleta[f] shr 8) and $FF;
  colores[f].b:=cpc_paleta[f] and $FF;
end;
set_pal(colores,32);
main_z80:=cpu_z80.create(4000000,pantalla_alto);
main_z80.change_ram_calls(cpc_getbyte,cpc_putbyte);
main_z80.change_io_calls(cpc_inbyte,cpc_outbyte);
main_z80.change_misc_calls(amstrad_despues_instruccion,amstrad_raised_z80);
main_z80.change_timmings(@z80_op,@z80_op_cb,@z80_op_dd,@z80_op_ddcb,@z80_op_ed,@z80_op_ex);
main_z80.init_sound(amstrad_sound_update);
tape_sound_channel:=init_channel;
//El CPC lee el teclado el puerto A del AY, pero el puerto B esta unido al A
//por lo que hay programas que usan el B!!! (Bestial Warrior por ejemplo)
ay8910_0:=ay8910_chip.create(1000000,1);
ay8910_0.change_io_calls(cpc_porta_read,cpc_porta_read,nil,nil);
init_ppi8255(0,port_a_read,port_b_read,nil,port_a_write,nil,port_c_write);
case main_vars.tipo_maquina of
  7:begin
      if not(cargar_roms(@memoria_temp[0],@cpc464_rom,'cpc464.zip')) then exit;
      fillchar(cpc_mem[10,0],$4000,0);
    end;
  8:begin
      if not(cargar_roms(@cpc_mem[10,0],@ams_rom,'cpc664.zip')) then exit;
      if not(cargar_roms(@memoria_temp[0],@cpc646_rom,'cpc664.zip')) then exit;
  end;
  9:begin
      if not(cargar_roms(@cpc_mem[10,0],@ams_rom,'cpc6128.zip')) then exit;
      if not(cargar_roms(@memoria_temp[0],@cpc6128_rom,'cpc6128.zip')) then exit;
  end;
end;
copymemory(@cpc_mem[8,0],@memoria_temp[0],$4000);
copymemory(@cpc_mem[9,0],@memoria_temp[$4000],$4000);
cpc_reset;
iniciar_cpc:=true;
end;

procedure cpc_close;
begin
freemem(cpc_crt);
freemem(cpc_ga);
freemem(cpc_ppi);
main_z80.free;
close_ppi8255(0);
ay8910_0.free;
clear_disk(0);
clear_disk(1);
close_audio;
close_video;
end;

procedure cpc_reset;
begin
  main_z80.reset;
  ay8910_0.reset;
  reset_ppi8255(0);
  reset_audio;
  if cinta_tzx.cargada then cinta_tzx.play_once:=false;
  if not(dsk[0].abierto) then change_caption(llamadas_maquina.caption)
    else change_caption(llamadas_maquina.caption+' - DSK: '+dsk[0].imagename);
  cinta_tzx.value:=0;
  ResetFDC;
  //Init GA
  fillchar(cpc_ga^,sizeof(tcpc_ga),0);
  cpc_ga.rom_low:=true;
  copymemory(@cpc_ga.marco[0],@ram_banks[0,0],4);
  //CRT
  fillchar(cpc_crt^,sizeof(tcpc_crt),0);
  cpc_crt.char_altura:=1;
  cpc_crt.lineas_total:=1;
  //PPI
  fillchar(cpc_ppi^,sizeof(tcpc_ppi),0);
  fillchar(cpc_ppi.keyb_val[0],10,$FF);
end;

procedure eventos_cpc;
begin
if event.keyboard then begin
//Line 0
  if keyboard[SDL_SCANCODE_UP] then cpc_ppi.keyb_val[0]:=(cpc_ppi.keyb_val[0] and $fe) else cpc_ppi.keyb_val[0]:=(cpc_ppi.keyb_val[0] or $1);
  if keyboard[SDL_SCANCODE_RIGHT] then cpc_ppi.keyb_val[0]:=(cpc_ppi.keyb_val[0] and $fd) else cpc_ppi.keyb_val[0]:=(cpc_ppi.keyb_val[0] or $2);
  if keyboard[SDL_SCANCODE_DOWN] then cpc_ppi.keyb_val[0]:=(cpc_ppi.keyb_val[0] and $fb) else cpc_ppi.keyb_val[0]:=(cpc_ppi.keyb_val[0] or $4);
  if (keyboard[SDL_SCANCODE_f9] and keyboard[SDL_SCANCODE_RSHIFT])then cpc_ppi.keyb_val[0]:=(cpc_ppi.keyb_val[0] and $f7) else cpc_ppi.keyb_val[0]:=(cpc_ppi.keyb_val[0] or $8);
  if (keyboard[SDL_SCANCODE_f6] and keyboard[SDL_SCANCODE_RSHIFT])then cpc_ppi.keyb_val[0]:=(cpc_ppi.keyb_val[0] and $ef) else cpc_ppi.keyb_val[0]:=(cpc_ppi.keyb_val[0] or $10);
  if (keyboard[SDL_SCANCODE_f3] and keyboard[SDL_SCANCODE_RSHIFT])then cpc_ppi.keyb_val[0]:=(cpc_ppi.keyb_val[0] and $df) else cpc_ppi.keyb_val[0]:=(cpc_ppi.keyb_val[0] or $20);
  if keyboard[SDL_SCANCODE_HOME] then cpc_ppi.keyb_val[0]:=(cpc_ppi.keyb_val[0] and $bf) else cpc_ppi.keyb_val[0]:=(cpc_ppi.keyb_val[0] or $40);
{F Dot}
//Line 1
  if keyboard[SDL_SCANCODE_LEFT] then cpc_ppi.keyb_val[1]:=(cpc_ppi.keyb_val[1] and $fe) else cpc_ppi.keyb_val[1]:=(cpc_ppi.keyb_val[1] or 1);
  if keyboard[SDL_SCANCODE_INSERT] then cpc_ppi.keyb_val[1]:=(cpc_ppi.keyb_val[1] and $fd) else cpc_ppi.keyb_val[1]:=(cpc_ppi.keyb_val[1] or 2);
  if (keyboard[SDL_SCANCODE_f7] and keyboard[SDL_SCANCODE_RSHIFT])then cpc_ppi.keyb_val[1]:=(cpc_ppi.keyb_val[1] and $fb) else cpc_ppi.keyb_val[1]:=(cpc_ppi.keyb_val[1] or $4);
  if (keyboard[SDL_SCANCODE_f8] and keyboard[SDL_SCANCODE_RSHIFT])then cpc_ppi.keyb_val[1]:=(cpc_ppi.keyb_val[1] and $f7) else cpc_ppi.keyb_val[1]:=(cpc_ppi.keyb_val[1] or $8);
  if keyboard[SDL_SCANCODE_f5] then begin
    if (keyboard[SDL_SCANCODE_RSHIFT]) then begin
        cpc_ppi.keyb_val[1]:=(cpc_ppi.keyb_val[1] and $ef);
    end else begin
        clear_disk(0);
        change_caption(llamadas_maquina.caption);
      end;
  end else begin
        cpc_ppi.keyb_val[1]:=(cpc_ppi.keyb_val[1] or $10)
  end;
  if keyboard[SDL_SCANCODE_f1] then begin
    if keyboard[SDL_SCANCODE_RSHIFT] then begin
      cpc_ppi.keyb_val[1]:=(cpc_ppi.keyb_val[1] and $df);
    end else begin
      if cinta_tzx.cargada then begin
        if cinta_tzx.play_tape then tape_window1.fStopCinta(nil)
          else tape_window1.fPlayCinta(nil);
      end;
    end;
  end else begin
    cpc_ppi.keyb_val[1]:=(cpc_ppi.keyb_val[1] or $20);
  end;
  if (keyboard[SDL_SCANCODE_f2] and keyboard[SDL_SCANCODE_RSHIFT])then cpc_ppi.keyb_val[1]:=(cpc_ppi.keyb_val[1] and $bf) else cpc_ppi.keyb_val[1]:=(cpc_ppi.keyb_val[1] or $40);
  if (keyboard[SDL_SCANCODE_f10] and keyboard[SDL_SCANCODE_RSHIFT])then cpc_ppi.keyb_val[1]:=(cpc_ppi.keyb_val[1] and $7f) else cpc_ppi.keyb_val[1]:=(cpc_ppi.keyb_val[1] or $80);
//Line 2
  if keyboard[SDL_SCANCODE_DELETE] then cpc_ppi.keyb_val[2]:=(cpc_ppi.keyb_val[2] and $fe) else cpc_ppi.keyb_val[2]:=(cpc_ppi.keyb_val[2] or 1);
{[}
  if keyboard[SDL_SCANCODE_RETURN] then cpc_ppi.keyb_val[2]:=(cpc_ppi.keyb_val[2] and $fb) else cpc_ppi.keyb_val[2]:=(cpc_ppi.keyb_val[2] or 4);
{]}
  if (keyboard[SDL_SCANCODE_f4] and keyboard[SDL_SCANCODE_RSHIFT])then cpc_ppi.keyb_val[2]:=(cpc_ppi.keyb_val[2] and $ef) else cpc_ppi.keyb_val[2]:=(cpc_ppi.keyb_val[2] or $10);
  if keyboard[SDL_SCANCODE_LSHIFT] then cpc_ppi.keyb_val[2]:=(cpc_ppi.keyb_val[2] and $df) else cpc_ppi.keyb_val[2]:=(cpc_ppi.keyb_val[2] or $20);
{\} if keyboard[SDL_SCANCODE_EQUALS] then cpc_ppi.keyb_val[2]:=(cpc_ppi.keyb_val[2] and $bf) else cpc_ppi.keyb_val[2]:=(cpc_ppi.keyb_val[2] or $40);
  if keyboard[SDL_SCANCODE_LCTRL] then cpc_ppi.keyb_val[2]:=(cpc_ppi.keyb_val[2] and $7f) else cpc_ppi.keyb_val[2]:=(cpc_ppi.keyb_val[2] or $80);
//Line 3
{^}
{-} if keyboard[SDL_SCANCODE_SLASH] then cpc_ppi.keyb_val[3]:=(cpc_ppi.keyb_val[3] and $fd) else cpc_ppi.keyb_val[3]:=(cpc_ppi.keyb_val[3] or 2);
{|} if keyboard[SDL_SCANCODE_NONUSBACKSLASH] then cpc_ppi.keyb_val[3]:=(cpc_ppi.keyb_val[3] and $fb) else cpc_ppi.keyb_val[3]:=(cpc_ppi.keyb_val[3] or 4);
  if keyboard[SDL_SCANCODE_p] then cpc_ppi.keyb_val[3]:=(cpc_ppi.keyb_val[3] and $f7) else cpc_ppi.keyb_val[3]:=(cpc_ppi.keyb_val[3] or 8);
{;} if keyboard[SDL_SCANCODE_APOSTROPHE] then cpc_ppi.keyb_val[3]:=(cpc_ppi.keyb_val[3] and $ef) else cpc_ppi.keyb_val[3]:=(cpc_ppi.keyb_val[3] or $10);
{:} if keyboard[SDL_SCANCODE_BACKSLASH] then cpc_ppi.keyb_val[3]:=(cpc_ppi.keyb_val[3] and $df) else cpc_ppi.keyb_val[3]:=(cpc_ppi.keyb_val[3] or $20);
{/} if keyboard[SDL_SCANCODE_MINUS] then cpc_ppi.keyb_val[3]:=(cpc_ppi.keyb_val[3] and $bf) else cpc_ppi.keyb_val[3]:=(cpc_ppi.keyb_val[3] or $40);
{.} if keyboard[SDL_SCANCODE_PERIOD] then cpc_ppi.keyb_val[3]:=(cpc_ppi.keyb_val[3] and $7f) else cpc_ppi.keyb_val[3]:=(cpc_ppi.keyb_val[3] or $80);
//Line 4
  if keyboard[SDL_SCANCODE_0] then cpc_ppi.keyb_val[4]:=(cpc_ppi.keyb_val[4] and $fe) else cpc_ppi.keyb_val[4]:=(cpc_ppi.keyb_val[4] or 1);
  if keyboard[SDL_SCANCODE_9] then cpc_ppi.keyb_val[4]:=(cpc_ppi.keyb_val[4] and $fd) else cpc_ppi.keyb_val[4]:=(cpc_ppi.keyb_val[4] or 2);
  if keyboard[SDL_SCANCODE_o] then cpc_ppi.keyb_val[4]:=(cpc_ppi.keyb_val[4] and $fb) else cpc_ppi.keyb_val[4]:=(cpc_ppi.keyb_val[4] or 4);
  if keyboard[SDL_SCANCODE_i] then cpc_ppi.keyb_val[4]:=(cpc_ppi.keyb_val[4] and $f7) else cpc_ppi.keyb_val[4]:=(cpc_ppi.keyb_val[4] or 8);
  if keyboard[SDL_SCANCODE_l] then cpc_ppi.keyb_val[4]:=(cpc_ppi.keyb_val[4] and $ef) else cpc_ppi.keyb_val[4]:=(cpc_ppi.keyb_val[4] or $10);
  if keyboard[SDL_SCANCODE_k] then cpc_ppi.keyb_val[4]:=(cpc_ppi.keyb_val[4] and $df) else cpc_ppi.keyb_val[4]:=(cpc_ppi.keyb_val[4] or $20);
  if keyboard[SDL_SCANCODE_m] then cpc_ppi.keyb_val[4]:=(cpc_ppi.keyb_val[4] and $bf) else cpc_ppi.keyb_val[4]:=(cpc_ppi.keyb_val[4] or $40);
  if keyboard[SDL_SCANCODE_comma] then cpc_ppi.keyb_val[4]:=(cpc_ppi.keyb_val[4] and $7f) else cpc_ppi.keyb_val[4]:=(cpc_ppi.keyb_val[4] or $80);
//Line 5
  if keyboard[SDL_SCANCODE_8] then cpc_ppi.keyb_val[5]:=(cpc_ppi.keyb_val[5] and $fe) else cpc_ppi.keyb_val[5]:=(cpc_ppi.keyb_val[5] or 1);
  if keyboard[SDL_SCANCODE_7] then cpc_ppi.keyb_val[5]:=(cpc_ppi.keyb_val[5] and $fd) else cpc_ppi.keyb_val[5]:=(cpc_ppi.keyb_val[5] or 2);
  if keyboard[SDL_SCANCODE_u] then cpc_ppi.keyb_val[5]:=(cpc_ppi.keyb_val[5] and $fb) else cpc_ppi.keyb_val[5]:=(cpc_ppi.keyb_val[5] or 4);
  if keyboard[SDL_SCANCODE_y] then cpc_ppi.keyb_val[5]:=(cpc_ppi.keyb_val[5] and $f7) else cpc_ppi.keyb_val[5]:=(cpc_ppi.keyb_val[5] or 8);
  if keyboard[SDL_SCANCODE_h] then cpc_ppi.keyb_val[5]:=(cpc_ppi.keyb_val[5] and $ef) else cpc_ppi.keyb_val[5]:=(cpc_ppi.keyb_val[5] or $10);
  if keyboard[SDL_SCANCODE_j] then cpc_ppi.keyb_val[5]:=(cpc_ppi.keyb_val[5] and $df) else cpc_ppi.keyb_val[5]:=(cpc_ppi.keyb_val[5] or $20);
  if keyboard[SDL_SCANCODE_n] then cpc_ppi.keyb_val[5]:=(cpc_ppi.keyb_val[5] and $bf) else cpc_ppi.keyb_val[5]:=(cpc_ppi.keyb_val[5] or $40);
  if keyboard[SDL_SCANCODE_space] then cpc_ppi.keyb_val[5]:=(cpc_ppi.keyb_val[5] and $7f) else cpc_ppi.keyb_val[5]:=(cpc_ppi.keyb_val[5] or $80);
//Line 6
  if keyboard[SDL_SCANCODE_6] then cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] and $fe) else cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] or 1);
  if keyboard[SDL_SCANCODE_5] then cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] and $fd) else cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] or 2);
  if keyboard[SDL_SCANCODE_r] then cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] and $fb) else cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] or 4);
  if keyboard[SDL_SCANCODE_t] then cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] and $f7) else cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] or 8);
  if keyboard[SDL_SCANCODE_g] then cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] and $ef) else cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] or $10);
  if keyboard[SDL_SCANCODE_f] then cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] and $df) else cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] or $20);
  if keyboard[SDL_SCANCODE_b] then cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] and $bf) else cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] or $40);
  if keyboard[SDL_SCANCODE_v] then cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] and $7f) else cpc_ppi.keyb_val[6]:=(cpc_ppi.keyb_val[6] or $80);
//Line 7
  if keyboard[SDL_SCANCODE_4] then cpc_ppi.keyb_val[7]:=(cpc_ppi.keyb_val[7] and $fe) else cpc_ppi.keyb_val[7]:=(cpc_ppi.keyb_val[7] or 1);
  if keyboard[SDL_SCANCODE_3] then cpc_ppi.keyb_val[7]:=(cpc_ppi.keyb_val[7] and $fd) else cpc_ppi.keyb_val[7]:=(cpc_ppi.keyb_val[7] or 2);
  if keyboard[SDL_SCANCODE_e] then cpc_ppi.keyb_val[7]:=(cpc_ppi.keyb_val[7] and $fb) else cpc_ppi.keyb_val[7]:=(cpc_ppi.keyb_val[7] or 4);
  if keyboard[SDL_SCANCODE_w] then cpc_ppi.keyb_val[7]:=(cpc_ppi.keyb_val[7] and $f7) else cpc_ppi.keyb_val[7]:=(cpc_ppi.keyb_val[7] or 8);
  if keyboard[SDL_SCANCODE_s] then cpc_ppi.keyb_val[7]:=(cpc_ppi.keyb_val[7] and $ef) else cpc_ppi.keyb_val[7]:=(cpc_ppi.keyb_val[7] or $10);
  if keyboard[SDL_SCANCODE_d] then cpc_ppi.keyb_val[7]:=(cpc_ppi.keyb_val[7] and $df) else cpc_ppi.keyb_val[7]:=(cpc_ppi.keyb_val[7] or $20);
  if keyboard[SDL_SCANCODE_c] then cpc_ppi.keyb_val[7]:=(cpc_ppi.keyb_val[7] and $bf) else cpc_ppi.keyb_val[7]:=(cpc_ppi.keyb_val[7] or $40);
  if keyboard[SDL_SCANCODE_x] then cpc_ppi.keyb_val[7]:=(cpc_ppi.keyb_val[7] and $7f) else cpc_ppi.keyb_val[7]:=(cpc_ppi.keyb_val[7] or $80);
//Line 8
  if keyboard[SDL_SCANCODE_1] then cpc_ppi.keyb_val[8]:=(cpc_ppi.keyb_val[8] and $fe) else cpc_ppi.keyb_val[8]:=(cpc_ppi.keyb_val[8] or 1);
  if keyboard[SDL_SCANCODE_2] then cpc_ppi.keyb_val[8]:=(cpc_ppi.keyb_val[8] and $fd) else cpc_ppi.keyb_val[8]:=(cpc_ppi.keyb_val[8] or 2);
  if keyboard[SDL_SCANCODE_escape] then cpc_ppi.keyb_val[8]:=(cpc_ppi.keyb_val[8] and $fb) else cpc_ppi.keyb_val[8]:=(cpc_ppi.keyb_val[8] or 4);
  if keyboard[SDL_SCANCODE_q] then cpc_ppi.keyb_val[8]:=(cpc_ppi.keyb_val[8] and $f7) else cpc_ppi.keyb_val[8]:=(cpc_ppi.keyb_val[8] or 8);
  if keyboard[SDL_SCANCODE_tab] then cpc_ppi.keyb_val[8]:=(cpc_ppi.keyb_val[8] and $ef) else cpc_ppi.keyb_val[8]:=(cpc_ppi.keyb_val[8] or $10);
  if keyboard[SDL_SCANCODE_a] then cpc_ppi.keyb_val[8]:=(cpc_ppi.keyb_val[8] and $df) else cpc_ppi.keyb_val[8]:=(cpc_ppi.keyb_val[8] or $20);
  if keyboard[SDL_SCANCODE_CAPSLOCK] then cpc_ppi.keyb_val[8]:=(cpc_ppi.keyb_val[8] and $bf) else cpc_ppi.keyb_val[8]:=(cpc_ppi.keyb_val[8] or $40);
  if keyboard[SDL_SCANCODE_z] then cpc_ppi.keyb_val[8]:=(cpc_ppi.keyb_val[8] and $7f) else cpc_ppi.keyb_val[8]:=(cpc_ppi.keyb_val[8] or $80);
//Line 9
  //JOY UP,JOY DOWN,JOY LEFT,JOY RIGHT,FIRE1,FIRE2 --> Arcade
  if keyboard[SDL_SCANCODE_BACKSPACE] then cpc_ppi.keyb_val[9]:=(cpc_ppi.keyb_val[9] and $7f) else cpc_ppi.keyb_val[9]:=(cpc_ppi.keyb_val[9] or $80);
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
if cpc_ga.video_change then begin
  cpc_ga.video_mode:=cpc_ga.video_mode_new;
  cpc_ga.video_change:=false;
end;
cpc_ga.lines_count:=cpc_ga.lines_count+1;
if (cpc_ga.lines_sync<>0) then begin
  cpc_ga.lines_sync:=cpc_ga.lines_sync-1;
  if (cpc_ga.lines_sync=0) then begin
    if (cpc_ga.lines_count>=32) then main_z80.pedir_irq:=PULSE_LINE
      else main_z80.pedir_irq:=CLEAR_LINE;
    cpc_ga.lines_count:=0;
  end;
end;
if (cpc_ga.lines_count>=52) then begin
    cpc_ga.lines_count:=0;
    main_z80.pedir_irq:=PULSE_LINE;
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
  ma,addr:dword;
  x,y:word;
begin
if ((cpc_crt.regs[4]*cpc_crt.char_altura)+cpc_crt.regs[9])>pantalla_alto then exit;
ma:=cpc_crt.regs[13] or ((cpc_crt.regs[12] and $3f) shl 8);
          //  altura total en chars
for y:=0 to cpc_crt.regs[4] do begin
            //altura char
  for x:=0 to cpc_crt.regs[9] do begin
    addr:=((ma and $3ff) shl 1)+((ma and $3000) shl 2)+(x*$800);
    if addr>$ffff then addr:=addr-$4000;
    cpc_crt.scr_line_dir[x+(y*cpc_crt.char_altura)]:=addr;
  end;
  ma:=ma+cpc_crt.regs[1];
end;
end;

procedure actualiza_linea(linea:word);
var
 x:integer;
 addr:dword;
 marco:byte;
 val,p1,p2,p3,p4,p5,p6,p7,p8:byte;
 ptemp:pword;
 borde:dword;
 temp1,temp2,temp3,temp4,temp5,temp6:byte;
begin
borde:=(pantalla_largo-cpc_crt.pixel_visible) shr 1;
single_line(0,linea+cpc_crt.lineas_borde,cpc_ga.pal[$10],borde,1);
addr:=cpc_crt.scr_line_dir[linea];
x:=0;
while (x<cpc_crt.char_total) do begin
  if x=cpc_crt.char_hsync then amstrad_ga_exec;
  if x<cpc_crt.pixel_visible then begin
    marco:=addr shr 14;
    val:=cpc_mem[cpc_ga.marco[marco and $3],addr and $3fff];
    addr:=addr+1;
    if addr>$ffff then addr:=addr-$4000;
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
          SDL_GetRGB(paleta[cpc_ga.pal[p1]],pantalla[pant_sprites].format,@temp1,@temp2,@temp3);
          SDL_GetRGB(paleta[cpc_ga.pal[p2]],pantalla[pant_sprites].format,@temp4,@temp5,@temp6);
          ptemp^:=SDL_MapRGB(pantalla[pant_sprites].format,(temp1+temp4) div 2,(temp2+temp5) div 2,(temp3+temp6) div 2);
          inc(ptemp);
          SDL_GetRGB(paleta[cpc_ga.pal[p3]],pantalla[pant_sprites].format,@temp1,@temp2,@temp3);
          SDL_GetRGB(paleta[cpc_ga.pal[p4]],pantalla[pant_sprites].format,@temp4,@temp5,@temp6);
          ptemp^:=SDL_MapRGB(pantalla[pant_sprites].format,(temp1+temp4) div 2,(temp2+temp5) div 2,(temp3+temp6) div 2);
          inc(ptemp);
          SDL_GetRGB(paleta[cpc_ga.pal[p5]],pantalla[pant_sprites].format,@temp1,@temp2,@temp3);
          SDL_GetRGB(paleta[cpc_ga.pal[p6]],pantalla[pant_sprites].format,@temp4,@temp5,@temp6);
          ptemp^:=SDL_MapRGB(pantalla[pant_sprites].format,(temp1+temp4) div 2,(temp2+temp5) div 2,(temp3+temp6) div 2);
          inc(ptemp);
          SDL_GetRGB(paleta[cpc_ga.pal[p7]],pantalla[pant_sprites].format,@temp1,@temp2,@temp3);
          SDL_GetRGB(paleta[cpc_ga.pal[p8]],pantalla[pant_sprites].format,@temp4,@temp5,@temp6);
          ptemp^:=SDL_MapRGB(pantalla[pant_sprites].format,(temp1+temp4) div 2,(temp2+temp5) div 2,(temp3+temp6) div 2);
      end;
    end;
    putpixel(x+borde,linea+cpc_crt.lineas_borde,4,punbuf,1);
  end;
  x:=x+4;
end;
single_line(cpc_crt.pixel_visible+borde,linea+cpc_crt.lineas_borde,cpc_ga.pal[$10],borde,1);
end;

procedure draw_line(linea_crt:word);
begin
if ((linea_crt<cpc_crt.lineas_visible) and not(cpc_crt.vsync_activo)) then actualiza_linea(linea_crt)
else begin
  single_line(0,(linea_crt+cpc_crt.lineas_borde) mod pantalla_alto,cpc_ga.pal[$10],pantalla_largo,1);
  amstrad_ga_exec;
end;
//Vsync
if cpc_crt.vsync_activo then begin
  if cpc_crt.vsync_cont=0 then cpc_crt.vsync_activo:=false
    else cpc_crt.vsync_cont:=cpc_crt.vsync_cont-1;
end;
if (linea_crt=cpc_crt.vsync_linea_ocurre) then begin
  cpc_crt.vsync_cont:=cpc_crt.vsync_lines-1;
  cpc_ga.lines_sync:=2;
  cpc_crt.vsync_activo:=true;
end;
end;

procedure cpc_main;
var
  frame:single;
  f:word;
begin
init_controls(false,true,true,false);
frame:=main_z80.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to (pantalla_alto-1) do begin
    main_z80.run(frame);
    frame:=frame+main_z80.tframes-main_z80.contador;
    draw_line(f);
  end;
  eventos_cpc;
  actualiza_trozo_simple(0,0,pantalla_largo,pantalla_alto,1);
  video_sync;
end;
end;

//Main CPU
function cpc_getbyte(direccion:word):byte;
begin
case direccion of
  0..$3fff:if cpc_ga.rom_low then cpc_getbyte:=cpc_mem[8,direccion]
            else cpc_getbyte:=cpc_mem[cpc_ga.marco[0],direccion];
  $4000..$7fff:cpc_getbyte:=cpc_mem[cpc_ga.marco[1],direccion and $3fff];
  $8000..$bfff:cpc_getbyte:=cpc_mem[cpc_ga.marco[2],direccion and $3fff];
  $c000..$ffff:if cpc_ga.rom_high then cpc_getbyte:=cpc_mem[cpc_ga.rom_selected,direccion and $3fff]
                else cpc_getbyte:=cpc_mem[cpc_ga.marco[3],direccion and $3fff];
end;
end;

procedure cpc_putbyte(direccion:word;valor:byte);
begin
cpc_mem[cpc_ga.marco[direccion shr 14],direccion and $3fff]:=valor;
end;

procedure write_ga(val:byte);
begin
  case (val shr 6) of
          $0:if (val and $10)=0 then cpc_ga.pen:=val and 15 //Select pen
                else cpc_ga.pen:=$10; //Border
          $1:cpc_ga.pal[cpc_ga.pen]:=val and 31;    //Change pen colour
          $2:begin   //ROM banking and mode switch
                cpc_ga.video_mode_new:=val and 3;
                if (cpc_ga.video_mode<>cpc_ga.video_mode_new) then cpc_ga.video_change:=true;
                cpc_ga.rom_low:=(val and 4)=0;
                cpc_ga.rom_high:=(val and 8)=0;
                if (val and $10)<>0 then begin
                   cpc_ga.lines_count:=0;
                   main_z80.pedir_irq:=CLEAR_LINE;
                end;
            end;
          //C6128 RAM Bank only
          $3:begin
                if main_vars.tipo_maquina=9 then copymemory(@cpc_ga.marco[0],@ram_banks[(val and 7),0],4);
                cpc_ga.marco_latch:=val and 7;
             end;
        end;
end;

procedure cpc_calc_crt;
begin
//altura char por linea
cpc_crt.char_altura:=(cpc_crt.regs[9] and $1f)+1;
//chars totales
cpc_crt.char_total:=(cpc_crt.regs[0]+1)*8;
//char en el que ocurre el hsync
cpc_crt.char_hsync:=cpc_crt.regs[2]*8;
if cpc_crt.char_hsync>(cpc_crt.regs[0]*8) then cpc_crt.char_hsync:=cpc_crt.regs[0]*8;
//Total pixels por linea
cpc_crt.pixel_visible:=cpc_crt.regs[1]*8;
if cpc_crt.pixel_visible>cpc_crt.char_total then cpc_crt.pixel_visible:=cpc_crt.char_total;
//Lineas de vsync+completar frame
if (cpc_crt.regs[3] shr 4)=0 then cpc_crt.vsync_lines:=16
   else cpc_crt.vsync_lines:=cpc_crt.regs[3] shr 4;
//lineas visibles
cpc_crt.lineas_visible:=(cpc_crt.regs[6] and $7f)*cpc_crt.char_altura;
//lineas totales del video incluyendo las visibles
cpc_crt.lineas_total:=((cpc_crt.regs[4] and $7f)+1)*cpc_crt.char_altura+(cpc_crt.regs[5] and $1f);
if cpc_crt.lineas_total>pantalla_alto then cpc_crt.lineas_total:=pantalla_alto;
if cpc_crt.lineas_visible>cpc_crt.lineas_total then cpc_crt.lineas_visible:=cpc_crt.lineas_total;
cpc_crt.lineas_borde:=(cpc_crt.lineas_total-cpc_crt.lineas_visible) shr 1;
//Linea donde ocurre el vsync
cpc_crt.vsync_linea_ocurre:=(cpc_crt.regs[7] and $7f)*cpc_crt.char_altura;
if cpc_crt.vsync_linea_ocurre>cpc_crt.lineas_total then cpc_crt.vsync_linea_ocurre:=cpc_crt.lineas_total;
end;

procedure write_crtc(port:word;val:byte);
begin
  case ((port and $300) shr 8) of
    $00:cpc_crt.reg:=val and 31;
    $01:if cpc_crt.regs[cpc_crt.reg]<>val then begin
          cpc_crt.regs[cpc_crt.reg]:=val;
          cpc_calc_crt;
          cpc_calcular_dir_scr;
        end;
  end;
end;

procedure cpc_outbyte(valor:byte;puerto:word);
begin
if (puerto and $8000)=0 then write_ga(valor);
if (puerto and $4000)=0 then write_crtc(puerto,valor);
if (puerto and $2000)=0 then begin
    case valor of
      7:cpc_ga.rom_selected:=10;
      else cpc_ga.rom_selected:=9;
    end;
end;
if (puerto and $1000)=0 then exit; //printer
if (puerto and $0800)=0 then ppi8255_w(0,(puerto and $300) shr 8,valor);
if (puerto and $0581)=$101 then WriteFDCData(valor);
end;

function read_crtc(port:word):byte;inline;
var
  res:byte;
begin
res:=$ff;
if ((port and $300) shr 8)=0 then
  if ((cpc_crt.reg>11) and (cpc_crt.reg<18)) then res:=cpc_crt.regs[cpc_crt.reg];
read_crtc:=res;
end;

function cpc_inbyte(puerto:word):byte;
var
  res:byte;
begin
res:=$FF;
if (puerto and $4000)=0 then res:=read_crtc(puerto);
if (puerto and $0800)=0 then res:=ppi8255_r(0,(puerto and $300) shr 8);
if (puerto and $0480)=$0 then begin
  case (puerto and $101) of
    $100:res:=ReadFDCStatus;
    $101:res:=ReadFDCData;
  end;
end;
cpc_inbyte:=res;
end;

function amstrad_raised_z80:byte;
begin
  cpc_ga.lines_count:=cpc_ga.lines_count and $1f;
  amstrad_raised_z80:=2;
  main_z80.pedir_irq:=CLEAR_LINE;
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
port_b_read:=$7e or (cinta_tzx.value shl 1) or byte(cpc_crt.vsync_activo);
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
cpc_ppi.tape_motor:=(valor and $10)<>0;
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
tsample[tape_sound_channel,sound_status.posicion_sonido]:=cinta_tzx.value*$20;
ay8910_0.update;
end;

//Tape
procedure amstrad_despues_instruccion(estados_t:word);
var
  amst_z80_reg:npreg_z80;
begin
if cinta_tzx.cargada then begin
  if (not(cpc_ppi.tape_motor) and cinta_tzx.play_once) then begin
    case cinta_tzx.datos_tzx[cinta_tzx.indice_cinta+1].tipo_bloque of
      $22:begin
            cinta_tzx.indice_cinta:=cinta_tzx.indice_cinta+1;
            siguiente_bloque_tzx;
          end;
      $fe:begin
            cinta_tzx.indice_cinta:=0;
            tape_window1.StringGrid1.TopRow:=0;
            siguiente_bloque_tzx;
            cinta_tzx.play_once:=true;
            tape_window1.fStopCinta(nil);
      end;
    end;
  end;
  if (cpc_ppi.tape_motor and cinta_tzx.play_tape) then begin
      cinta_tzx.estados:=cinta_tzx.estados+estados_t;
      play_cinta_tzx;
  end else begin
    amst_z80_reg:=main_z80.get_internal_r;
    if ((amst_z80_reg.pc=$bc77) and not(cinta_tzx.play_once)) then begin
       cinta_tzx.play_once:=true;
       main_screen.rapido:=true;
       tape_window1.fPlayCinta(nil);
    end;
  end;
end;
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
      if resultado then change_caption(llamadas_maquina.caption+' - Snap: '+nombre_file)
         else MessageDlg('Error cargando snapshot.'+chr(10)+chr(13)+'Error loading the snapshot.', mtInformation,[mbOk], 0);
  end;
  if es_cinta then begin
     if resultado then begin
        tape_window1.edit1.Text:=nombre_file;
        tape_window1.show;
        tape_window1.BitBtn1.Enabled:=true;
        tape_window1.BitBtn2.Enabled:=false;
        cinta_tzx.play_tape:=false;
     end else begin
        MessageDlg('Error cargando cinta/CSW/WAV.'+chr(10)+chr(13)+'Error loading tape/CSW/WAV.', mtInformation,[mbOk], 0);
     end;
  end;
  freemem(datos);
  directory.amstrad_tap:=extractfiledir(nombre_zip)+main_vars.cadena_dir;
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

end.
