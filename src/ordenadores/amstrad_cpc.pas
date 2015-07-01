unit amstrad_cpc;

interface
uses sdl2,{$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,controls_engine,ay_8910,sysutils,gfx_engine,upd765,cargar_dsk,forms,
     dialogs,rom_engine,misc_functions,main_engine,pal_engine,sound_engine,
     tape_window,file_engine,ppi8255,lenguaje,disk_file_format;

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
  ram_banks:array[0..7,0..3] of byte=(
        (0,1,2,3),(0,1,2,7),(4,5,6,7),(0,3,2,7),
        (0,4,2,3),(0,5,2,3),(0,6,2,3),(0,7,2,3));

  cpc6128_rom:tipo_roms=(n:'cpc6128.rom';l:$8000;p:0;crc:$9e827fe1);
  cpc464_rom:tipo_roms=(n:'cpc464.rom';l:$8000;p:0;crc:$40852f25);
  cpc646_rom:tipo_roms=(n:'cpc664.rom';l:$8000;p:0;crc:$9ab5a036);
  ams_rom:tipo_roms=(n:'amsdos.rom';l:$4000;p:0;crc:$1fe22ecd);
  pantalla_largo=400;
  pantalla_alto=312;

var
    cpc_mem:array[0..10,0..$3fff] of byte;
    mem_marco:array[0..3] of byte;
    current_pen,cpc_video_mode,new_video_mode:byte;
    motor_on,lowrom,highrom,crtc_vsync,change_video:boolean;
    cpcpal:array[0..16] of byte;
    latch_ppi_read_a,latch_ppi_write_a,ay_control:byte;
    crtcreg:array[0..31] of byte;
    current_crtc_reg,keyline,timer_video:byte;
    keyl_val:array[0..9] of byte;
    rom_selected,galines,galc,sample_beeper,cont_vsync:byte;
    old_marco,old_port_c_w:byte;
    char_hsync,char_count,char_total:word;
    altura_char,vsync_lines,linea_ocurre_vsync:word;
    lineas_total,pixel_visible,altura_borde,lineas_visible:word;
    scr_line_dir:array[0..(pantalla_alto-1)] of dword;

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
//PPI 8255
function port_a_read:byte;
function port_b_read:byte;
procedure port_a_write(valor:byte);
procedure port_c_write(valor:byte);

implementation
uses principal,tap_tzx,snapshot;

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
sample_beeper:=init_channel;
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
  current_pen:=0;
  cpc_video_mode:=1;
  change_video:=false;
  copymemory(@mem_marco[0],@ram_banks[0,0],4);
  lowrom:=true;
  highrom:=true;
  rom_selected:=9;
  //CRT
  char_count:=0;
  char_hsync:=0;
  cont_vsync:=0;
  altura_char:=1;
  vsync_lines:=0;
  pixel_visible:=0;
  altura_borde:=0;
  lineas_visible:=0;
  current_crtc_reg:=0;
  linea_ocurre_vsync:=0;
  fillchar(crtcreg,32,0);
  fillchar(keyl_val[0],10,$FF);
  current_crtc_reg:=0;
  keyline:=0;
  latch_ppi_read_a:=0;
  latch_ppi_write_a:=0;
  ay_control:=0;
  fillchar(scr_line_dir,pantalla_alto*4,0);
  galines:=0;
  galc:=0;
  sample_beeper:=0;
  crtc_vsync:=false;
  char_total:=0;
  lineas_total:=1;
end;

procedure eventos_cpc;
begin
if event.keyboard then begin
//Line 0
  if keyboard[SDL_SCANCODE_UP] then keyl_val[0]:=(keyl_val[0] and $fe) else keyl_val[0]:=(keyl_val[0] or $1);
  if keyboard[SDL_SCANCODE_RIGHT] then keyl_val[0]:=(keyl_val[0] and $fd) else keyl_val[0]:=(keyl_val[0] or $2);
  if keyboard[SDL_SCANCODE_DOWN] then keyl_val[0]:=(keyl_val[0] and $fb) else keyl_val[0]:=(keyl_val[0] or $4);
  if (keyboard[SDL_SCANCODE_f9] and keyboard[SDL_SCANCODE_RSHIFT])then keyl_val[0]:=(keyl_val[0] and $f7) else keyl_val[0]:=(keyl_val[0] or $8);
  if (keyboard[SDL_SCANCODE_f6] and keyboard[SDL_SCANCODE_RSHIFT])then keyl_val[0]:=(keyl_val[0] and $ef) else keyl_val[0]:=(keyl_val[0] or $10);
  if (keyboard[SDL_SCANCODE_f3] and keyboard[SDL_SCANCODE_RSHIFT])then keyl_val[0]:=(keyl_val[0] and $df) else keyl_val[0]:=(keyl_val[0] or $20);
  if keyboard[SDL_SCANCODE_HOME] then keyl_val[0]:=(keyl_val[0] and $bf) else keyl_val[0]:=(keyl_val[0] or $40);
{F Dot}
//Line 1
  if keyboard[SDL_SCANCODE_LEFT] then keyl_val[1]:=(keyl_val[1] and $fe) else keyl_val[1]:=(keyl_val[1] or 1);
  if keyboard[SDL_SCANCODE_INSERT] then keyl_val[1]:=(keyl_val[1] and $fd) else keyl_val[1]:=(keyl_val[1] or 2);
  if (keyboard[SDL_SCANCODE_f7] and keyboard[SDL_SCANCODE_RSHIFT])then keyl_val[1]:=(keyl_val[1] and $fb) else keyl_val[1]:=(keyl_val[1] or $4);
  if (keyboard[SDL_SCANCODE_f8] and keyboard[SDL_SCANCODE_RSHIFT])then keyl_val[1]:=(keyl_val[1] and $f7) else keyl_val[1]:=(keyl_val[1] or $8);
  if keyboard[SDL_SCANCODE_f5] then begin
    if (keyboard[SDL_SCANCODE_RSHIFT]) then begin
        keyl_val[1]:=(keyl_val[1] and $ef);
    end else begin
        clear_disk(0);
        change_caption(llamadas_maquina.caption);
      end;
  end else begin
        keyl_val[1]:=(keyl_val[1] or $10)
  end;
  if keyboard[SDL_SCANCODE_f1] then begin
    if keyboard[SDL_SCANCODE_RSHIFT] then begin
      keyl_val[1]:=(keyl_val[1] and $df);
    end else begin
      if cinta_tzx.cargada then begin
        if cinta_tzx.play_tape then tape_window1.fStopCinta(nil)
          else tape_window1.fPlayCinta(nil);
      end;
    end;
  end else begin
    keyl_val[1]:=(keyl_val[1] or $20);
  end;
  if (keyboard[SDL_SCANCODE_f2] and keyboard[SDL_SCANCODE_RSHIFT])then keyl_val[1]:=(keyl_val[1] and $bf) else keyl_val[1]:=(keyl_val[1] or $40);
  if (keyboard[SDL_SCANCODE_f10] and keyboard[SDL_SCANCODE_RSHIFT])then keyl_val[1]:=(keyl_val[1] and $7f) else keyl_val[1]:=(keyl_val[1] or $80);
//Line 2
  if keyboard[SDL_SCANCODE_DELETE] then keyl_val[2]:=(keyl_val[2] and $fe) else keyl_val[2]:=(keyl_val[2] or 1);
{[}
  if keyboard[SDL_SCANCODE_RETURN] then keyl_val[2]:=(keyl_val[2] and $fb) else keyl_val[2]:=(keyl_val[2] or 4);
{]}
  if (keyboard[SDL_SCANCODE_f4] and keyboard[SDL_SCANCODE_RSHIFT])then keyl_val[2]:=(keyl_val[2] and $ef) else keyl_val[2]:=(keyl_val[2] or $10);
  if keyboard[SDL_SCANCODE_LSHIFT] then keyl_val[2]:=(keyl_val[2] and $df) else keyl_val[2]:=(keyl_val[2] or $20);
{\} if keyboard[SDL_SCANCODE_EQUALS] then keyl_val[2]:=(keyl_val[2] and $bf) else keyl_val[2]:=(keyl_val[2] or $40);
  if keyboard[SDL_SCANCODE_LCTRL] then keyl_val[2]:=(keyl_val[2] and $7f) else keyl_val[2]:=(keyl_val[2] or $80);
//Line 3
{^}
{-} if keyboard[SDL_SCANCODE_SLASH] then keyl_val[3]:=(keyl_val[3] and $fd) else keyl_val[3]:=(keyl_val[3] or 2);
{|} if keyboard[SDL_SCANCODE_NONUSBACKSLASH] then keyl_val[3]:=(keyl_val[3] and $fb) else keyl_val[3]:=(keyl_val[3] or 4);
  if keyboard[SDL_SCANCODE_p] then keyl_val[3]:=(keyl_val[3] and $f7) else keyl_val[3]:=(keyl_val[3] or 8);
{;} if keyboard[SDL_SCANCODE_APOSTROPHE] then keyl_val[3]:=(keyl_val[3] and $ef) else keyl_val[3]:=(keyl_val[3] or $10);
{:} if keyboard[SDL_SCANCODE_BACKSLASH] then keyl_val[3]:=(keyl_val[3] and $df) else keyl_val[3]:=(keyl_val[3] or $20);
{/} if keyboard[SDL_SCANCODE_MINUS] then keyl_val[3]:=(keyl_val[3] and $bf) else keyl_val[3]:=(keyl_val[3] or $40);
{.} if keyboard[SDL_SCANCODE_PERIOD] then keyl_val[3]:=(keyl_val[3] and $7f) else keyl_val[3]:=(keyl_val[3] or $80);
//Line 4
  if keyboard[SDL_SCANCODE_0] then keyl_val[4]:=(keyl_val[4] and $fe) else keyl_val[4]:=(keyl_val[4] or 1);
  if keyboard[SDL_SCANCODE_9] then keyl_val[4]:=(keyl_val[4] and $fd) else keyl_val[4]:=(keyl_val[4] or 2);
  if keyboard[SDL_SCANCODE_o] then keyl_val[4]:=(keyl_val[4] and $fb) else keyl_val[4]:=(keyl_val[4] or 4);
  if keyboard[SDL_SCANCODE_i] then keyl_val[4]:=(keyl_val[4] and $f7) else keyl_val[4]:=(keyl_val[4] or 8);
  if keyboard[SDL_SCANCODE_l] then keyl_val[4]:=(keyl_val[4] and $ef) else keyl_val[4]:=(keyl_val[4] or $10);
  if keyboard[SDL_SCANCODE_k] then keyl_val[4]:=(keyl_val[4] and $df) else keyl_val[4]:=(keyl_val[4] or $20);
  if keyboard[SDL_SCANCODE_m] then keyl_val[4]:=(keyl_val[4] and $bf) else keyl_val[4]:=(keyl_val[4] or $40);
  if keyboard[SDL_SCANCODE_comma] then keyl_val[4]:=(keyl_val[4] and $7f) else keyl_val[4]:=(keyl_val[4] or $80);
//Line 5
  if keyboard[SDL_SCANCODE_8] then keyl_val[5]:=(keyl_val[5] and $fe) else keyl_val[5]:=(keyl_val[5] or 1);
  if keyboard[SDL_SCANCODE_7] then keyl_val[5]:=(keyl_val[5] and $fd) else keyl_val[5]:=(keyl_val[5] or 2);
  if keyboard[SDL_SCANCODE_u] then keyl_val[5]:=(keyl_val[5] and $fb) else keyl_val[5]:=(keyl_val[5] or 4);
  if keyboard[SDL_SCANCODE_y] then keyl_val[5]:=(keyl_val[5] and $f7) else keyl_val[5]:=(keyl_val[5] or 8);
  if keyboard[SDL_SCANCODE_h] then keyl_val[5]:=(keyl_val[5] and $ef) else keyl_val[5]:=(keyl_val[5] or $10);
  if keyboard[SDL_SCANCODE_j] then keyl_val[5]:=(keyl_val[5] and $df) else keyl_val[5]:=(keyl_val[5] or $20);
  if keyboard[SDL_SCANCODE_n] then keyl_val[5]:=(keyl_val[5] and $bf) else keyl_val[5]:=(keyl_val[5] or $40);
  if keyboard[SDL_SCANCODE_space] then keyl_val[5]:=(keyl_val[5] and $7f) else keyl_val[5]:=(keyl_val[5] or $80);
//Line 6
  if keyboard[SDL_SCANCODE_6] then keyl_val[6]:=(keyl_val[6] and $fe) else keyl_val[6]:=(keyl_val[6] or 1);
  if keyboard[SDL_SCANCODE_5] then keyl_val[6]:=(keyl_val[6] and $fd) else keyl_val[6]:=(keyl_val[6] or 2);
  if keyboard[SDL_SCANCODE_r] then keyl_val[6]:=(keyl_val[6] and $fb) else keyl_val[6]:=(keyl_val[6] or 4);
  if keyboard[SDL_SCANCODE_t] then keyl_val[6]:=(keyl_val[6] and $f7) else keyl_val[6]:=(keyl_val[6] or 8);
  if keyboard[SDL_SCANCODE_g] then keyl_val[6]:=(keyl_val[6] and $ef) else keyl_val[6]:=(keyl_val[6] or $10);
  if keyboard[SDL_SCANCODE_f] then keyl_val[6]:=(keyl_val[6] and $df) else keyl_val[6]:=(keyl_val[6] or $20);
  if keyboard[SDL_SCANCODE_b] then keyl_val[6]:=(keyl_val[6] and $bf) else keyl_val[6]:=(keyl_val[6] or $40);
  if keyboard[SDL_SCANCODE_v] then keyl_val[6]:=(keyl_val[6] and $7f) else keyl_val[6]:=(keyl_val[6] or $80);
//Line 7
  if keyboard[SDL_SCANCODE_4] then keyl_val[7]:=(keyl_val[7] and $fe) else keyl_val[7]:=(keyl_val[7] or 1);
  if keyboard[SDL_SCANCODE_3] then keyl_val[7]:=(keyl_val[7] and $fd) else keyl_val[7]:=(keyl_val[7] or 2);
  if keyboard[SDL_SCANCODE_e] then keyl_val[7]:=(keyl_val[7] and $fb) else keyl_val[7]:=(keyl_val[7] or 4);
  if keyboard[SDL_SCANCODE_w] then keyl_val[7]:=(keyl_val[7] and $f7) else keyl_val[7]:=(keyl_val[7] or 8);
  if keyboard[SDL_SCANCODE_s] then keyl_val[7]:=(keyl_val[7] and $ef) else keyl_val[7]:=(keyl_val[7] or $10);
  if keyboard[SDL_SCANCODE_d] then keyl_val[7]:=(keyl_val[7] and $df) else keyl_val[7]:=(keyl_val[7] or $20);
  if keyboard[SDL_SCANCODE_c] then keyl_val[7]:=(keyl_val[7] and $bf) else keyl_val[7]:=(keyl_val[7] or $40);
  if keyboard[SDL_SCANCODE_x] then keyl_val[7]:=(keyl_val[7] and $7f) else keyl_val[7]:=(keyl_val[7] or $80);
//Line 8
  if keyboard[SDL_SCANCODE_1] then keyl_val[8]:=(keyl_val[8] and $fe) else keyl_val[8]:=(keyl_val[8] or 1);
  if keyboard[SDL_SCANCODE_2] then keyl_val[8]:=(keyl_val[8] and $fd) else keyl_val[8]:=(keyl_val[8] or 2);
  if keyboard[SDL_SCANCODE_escape] then keyl_val[8]:=(keyl_val[8] and $fb) else keyl_val[8]:=(keyl_val[8] or 4);
  if keyboard[SDL_SCANCODE_q] then keyl_val[8]:=(keyl_val[8] and $f7) else keyl_val[8]:=(keyl_val[8] or 8);
  if keyboard[SDL_SCANCODE_tab] then keyl_val[8]:=(keyl_val[8] and $ef) else keyl_val[8]:=(keyl_val[8] or $10);
  if keyboard[SDL_SCANCODE_a] then keyl_val[8]:=(keyl_val[8] and $df) else keyl_val[8]:=(keyl_val[8] or $20);
  if keyboard[SDL_SCANCODE_CAPSLOCK] then keyl_val[8]:=(keyl_val[8] and $bf) else keyl_val[8]:=(keyl_val[8] or $40);
  if keyboard[SDL_SCANCODE_z] then keyl_val[8]:=(keyl_val[8] and $7f) else keyl_val[8]:=(keyl_val[8] or $80);
//Line 9
  //JOY UP,JOY DOWN,JOY LEFT,JOY RIGHT,FIRE1,FIRE2 --> Arcade
  if keyboard[SDL_SCANCODE_BACKSPACE] then keyl_val[9]:=(keyl_val[9] and $7f) else keyl_val[9]:=(keyl_val[9] or $80);
end;
if event.arcade then begin
  //P1
  if arcade_input.up[0] then keyl_val[9]:=(keyl_val[9] and $fe) else keyl_val[9]:=(keyl_val[9] or 1);
  if arcade_input.down[0] then keyl_val[9]:=(keyl_val[9] and $fd) else keyl_val[9]:=(keyl_val[9] or 2);
  if arcade_input.left[0] then keyl_val[9]:=(keyl_val[9] and $fb) else keyl_val[9]:=(keyl_val[9] or 4);
  if arcade_input.right[0] then keyl_val[9]:=(keyl_val[9] and $f7) else keyl_val[9]:=(keyl_val[9] or $8);
  if arcade_input.but0[0] then keyl_val[9]:=(keyl_val[9] and $ef) else keyl_val[9]:=(keyl_val[9] or $10);
  //P2
  if arcade_input.up[1] then keyl_val[6]:=(keyl_val[6] and $fe) else keyl_val[6]:=(keyl_val[6] or 1);
  if arcade_input.down[1] then keyl_val[6]:=(keyl_val[6] and $fd) else keyl_val[6]:=(keyl_val[6] or 2);
  if arcade_input.left[1] then keyl_val[6]:=(keyl_val[6] and $fb) else keyl_val[6]:=(keyl_val[6] or 4);
  if arcade_input.right[1] then keyl_val[6]:=(keyl_val[6] and $f7) else keyl_val[6]:=(keyl_val[6] or 8);
  if arcade_input.but0[1] then keyl_val[6]:=(keyl_val[6] and $ef) else keyl_val[6]:=(keyl_val[6] or $10);
end;
end;

procedure amstrad_ga_exec;
begin
if change_video then begin
  cpc_video_mode:=new_video_mode;
  change_video:=false;
end;
galines:=galines+1;
if (galc<>0) then begin
  galc:=galc-1;
  if (galc=0) then begin
    if (galines>=32) then main_z80.pedir_irq:=PULSE_LINE
      else main_z80.pedir_irq:=CLEAR_LINE;
    galines:=0;
  end;
end;
if (galines>=52) then begin
    galines:=0;
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

procedure calcular_dir_scr;
var
  ma,addr:dword;
  x,y:word;
begin
if ((crtcreg[4]*altura_char)+crtcreg[9])>pantalla_alto then exit;
ma:=crtcreg[13] or ((crtcreg[12] and $3f) shl 8);
          //  altura total en chars
for y:=0 to crtcreg[4] do begin
            //altura char
  for x:=0 to crtcreg[9] do begin
    addr:=((ma and $3ff) shl 1)+((ma and $3000) shl 2)+(x*$800);
    if addr>$ffff then addr:=addr-$4000;
    scr_line_dir[x+(y*altura_char)]:=addr;
  end;
  ma:=ma+crtcreg[1];
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
borde:=(pantalla_largo-pixel_visible) shr 1;
single_line(0,linea+altura_borde,cpcpal[$10],borde,1);
addr:=scr_line_dir[linea];
x:=0;
while (x<char_total) do begin
  if x=(char_hsync*8) then amstrad_ga_exec;
  if x<pixel_visible then begin
    marco:=addr shr 14;
    val:=cpc_mem[mem_marco[marco and $3],addr and $3fff];
    addr:=addr+1;
    if addr>$ffff then addr:=addr-$4000;
    case cpc_video_mode of
      0:begin
          // 1 5 3 7    0 4 2 6
          p1:=((val and 2) shl 2) or ((val and $20) shr 3) or ((val and 8) shr 2) or ((val and $80) shr 7);
          p2:=((val and 1) shl 3) or ((val and $10) shr 2) or ((val and 4) shr 1) or ((val and $40) shr 6);
          ptemp:=punbuf;
          ptemp^:=paleta[cpcpal[p1]];
          inc(ptemp);
          ptemp^:=paleta[cpcpal[p1]];
          inc(ptemp);
          ptemp^:=paleta[cpcpal[p2]];
          inc(ptemp);
          ptemp^:=paleta[cpcpal[p2]];
      end;
      1:begin
          // 3 7      2 6      1 5      0 4
          p1:=((val and $80) shr 7)+((val and $8) shr 2);
          p2:=((val and $40) shr 6)+((val and $4) shr 1);
          p3:=((val and $20) shr 5)+((val and $2) shr 0);
          p4:=((val and $10) shr 4)+((val and 1) shl 1);
          ptemp:=punbuf;
          ptemp^:=paleta[cpcpal[p1]];
          inc(ptemp);
          ptemp^:=paleta[cpcpal[p2]];
          inc(ptemp);
          ptemp^:=paleta[cpcpal[p3]];
          inc(ptemp);
          ptemp^:=paleta[cpcpal[p4]];
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
          SDL_GetRGB(paleta[cpcpal[p1]],pantalla[pant_sprites].format,@temp1,@temp2,@temp3);
          SDL_GetRGB(paleta[cpcpal[p2]],pantalla[pant_sprites].format,@temp4,@temp5,@temp6);
          ptemp^:=SDL_MapRGB(pantalla[pant_sprites].format,(temp1+temp4) div 2,(temp2+temp5) div 2,(temp3+temp6) div 2);
          inc(ptemp);
          SDL_GetRGB(paleta[cpcpal[p3]],pantalla[pant_sprites].format,@temp1,@temp2,@temp3);
          SDL_GetRGB(paleta[cpcpal[p4]],pantalla[pant_sprites].format,@temp4,@temp5,@temp6);
          ptemp^:=SDL_MapRGB(pantalla[pant_sprites].format,(temp1+temp4) div 2,(temp2+temp5) div 2,(temp3+temp6) div 2);
          inc(ptemp);
          SDL_GetRGB(paleta[cpcpal[p5]],pantalla[pant_sprites].format,@temp1,@temp2,@temp3);
          SDL_GetRGB(paleta[cpcpal[p6]],pantalla[pant_sprites].format,@temp4,@temp5,@temp6);
          ptemp^:=SDL_MapRGB(pantalla[pant_sprites].format,(temp1+temp4) div 2,(temp2+temp5) div 2,(temp3+temp6) div 2);
          inc(ptemp);
          SDL_GetRGB(paleta[cpcpal[p7]],pantalla[pant_sprites].format,@temp1,@temp2,@temp3);
          SDL_GetRGB(paleta[cpcpal[p8]],pantalla[pant_sprites].format,@temp4,@temp5,@temp6);
          ptemp^:=SDL_MapRGB(pantalla[pant_sprites].format,(temp1+temp4) div 2,(temp2+temp5) div 2,(temp3+temp6) div 2);
      end;
    end;
    putpixel(x+borde,linea+altura_borde,4,punbuf,1);
  end;
  x:=x+4;
end;
single_line(pixel_visible+borde,linea+altura_borde,cpcpal[$10],borde,1);
end;

procedure draw_line(linea_crt:word);
begin
if ((linea_crt<lineas_visible) and not(crtc_vsync)) then actualiza_linea(linea_crt)
else begin
  single_line(0,(linea_crt+altura_borde) mod pantalla_alto,cpcpal[$10],pantalla_largo,1);
  amstrad_ga_exec;
end;
//Vsync
if crtc_vsync then begin
  if cont_vsync=0 then crtc_vsync:=false
    else cont_vsync:=cont_vsync-1;
end;
if (linea_crt=linea_ocurre_vsync) then begin
  cont_vsync:=vsync_lines-1;
  galc:=2;
  crtc_vsync:=true;
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
  0..$3fff:if lowrom then cpc_getbyte:=cpc_mem[8,direccion]
            else cpc_getbyte:=cpc_mem[mem_marco[0],direccion];
  $4000..$7fff:cpc_getbyte:=cpc_mem[mem_marco[1],direccion and $3fff];
  $8000..$bfff:cpc_getbyte:=cpc_mem[mem_marco[2],direccion and $3fff];
  $c000..$ffff:if highrom then cpc_getbyte:=cpc_mem[rom_selected,direccion and $3fff]
                else cpc_getbyte:=cpc_mem[mem_marco[3],direccion and $3fff];
end;
end;

procedure cpc_putbyte(direccion:word;valor:byte);
begin
cpc_mem[mem_marco[direccion shr 14],direccion and $3fff]:=valor;
end;

procedure write_ga(val:byte);
begin
  case (val shr 6) of
          $0:if (val and $10)=0 then current_pen:=val and 15 //Select pen
                else current_pen:=$10; //Border
          $1:cpcpal[current_pen]:=val and 31;    //Change pen colour
          $2:begin   //ROM banking and mode switch
                new_video_mode:=val and 3;
                if (cpc_video_mode<>new_video_mode) then change_video:=true;
                lowrom:=(val and 4)=0;
                highrom:=(val and 8)=0;
                if (val and $10)<>0 then begin
                   galines:=0;
                   main_z80.pedir_irq:=CLEAR_LINE;
                end;
            end;
          //C6128 RAM Bank only
          $3:begin
                if main_vars.tipo_maquina=9 then copymemory(@mem_marco[0],@ram_banks[(val and 7),0],4);
                old_marco:=val and 7;
             end;
        end;
end;

procedure write_crtc(port:word;val:byte);
begin
  case ((port and $300) shr 8) of
    $00:current_crtc_reg:=val and 31;
    $01:if crtcreg[current_crtc_reg]<>val then begin
          crtcreg[current_crtc_reg]:=val;
          //altura char por linea
          altura_char:=(crtcreg[9] and $1f)+1;
          //chars totales
          char_total:=(crtcreg[0]+1)*8;
          //char en el que ocurre el hsync
          char_hsync:=crtcreg[2];
          if char_hsync>crtcreg[0] then char_hsync:=crtcreg[0];
          //Total pixels por linea
          pixel_visible:=crtcreg[1]*8;
          if pixel_visible>char_total then pixel_visible:=char_total;
          //Lineas de vsync+completar frame
          if (crtcreg[3] shr 4)=0 then vsync_lines:=16
            else vsync_lines:=crtcreg[3] shr 4;
          //lineas visibles
          lineas_visible:=(crtcreg[6] and $7f)*altura_char;
          //lineas totales del video incluyendo las visibles
          lineas_total:=((crtcreg[4] and $7f)+1)*altura_char+(crtcreg[5] and $1f);
          if lineas_total>pantalla_alto then lineas_total:=pantalla_alto;
          if lineas_visible>lineas_total then lineas_visible:=lineas_total;
          altura_borde:=(lineas_total-lineas_visible) shr 1;
          //Linea donde ocurre el vsync
          linea_ocurre_vsync:=(crtcreg[7] and $7f)*altura_char;
          if linea_ocurre_vsync>lineas_total then linea_ocurre_vsync:=lineas_total;
          calcular_dir_scr;
        end;
  end;
end;

procedure cpc_outbyte(valor:byte;puerto:word);
begin
if (puerto and $8000)=0 then write_ga(valor);
if (puerto and $4000)=0 then write_crtc(puerto,valor);
if (puerto and $2000)=0 then begin
    case valor of
      7:rom_selected:=10;
      else rom_selected:=9;
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
  if ((current_crtc_reg>11) and (current_crtc_reg<18)) then res:=crtcreg[current_crtc_reg];
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
  galines:=galines and $1f;
  amstrad_raised_z80:=2;
  main_z80.pedir_irq:=CLEAR_LINE;
end;

//PPI 8255
procedure update_ay;inline;
begin
case ay_control of
  1:latch_ppi_read_a:=ay8910_0.read;
  2:ay8910_0.write(latch_ppi_write_a);
  3:ay8910_0.control(latch_ppi_write_a);
end;
end;

function port_a_read:byte;
begin
  update_ay;
  port_a_read:=latch_ppi_read_a;
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
port_b_read:=$7e or (cinta_tzx.value shl 1) or byte(crtc_vsync);
end;

procedure port_a_write(valor:byte);
begin
  latch_ppi_write_a:=valor;
  update_ay;
end;

procedure port_c_write(valor:byte);
begin
ay_control:=((valor and $c0) shr 6);
update_ay;
motor_on:=(valor and $10)<>0;
keyline:=valor and $f;
old_port_c_w:=valor;
end;

//AY-8910
function cpc_porta_read:byte;
begin
  cpc_porta_read:=keyl_val[keyline];
end;


//Sound
procedure amstrad_sound_update;
begin
tsample[sample_beeper,sound_status.posicion_sonido]:=cinta_tzx.value*$20;
ay8910_0.update;
end;

//Tape
procedure amstrad_despues_instruccion(estados_t:word);
var
  amst_z80_reg:npreg_z80;
begin
if cinta_tzx.cargada then begin
  if (not(motor_on) and cinta_tzx.play_once) then begin
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
  if (motor_on and cinta_tzx.play_tape) then begin
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
  if ((extension='CDT') or (extension='TZX')) then resultado:=abrir_tzx(datos,file_size);
  if extension='CSW' then resultado:=abrir_csw(datos,file_size);
  if extension='WAV' then resultado:=abrir_wav(datos,file_size);
  if extension='SNA' then begin
      resultado:=abrir_sna_cpc(datos,file_size);
      es_cinta:=false;
      amstrad_tapes:=true;
      change_caption(llamadas_maquina.caption+' - Snap: '+nombre_file);
  end;
  if (resultado and es_cinta) then begin
        tape_window1.edit1.Text:=nombre_file;
        tape_window1.show;
        tape_window1.BitBtn1.Enabled:=true;
        tape_window1.BitBtn2.Enabled:=false;
        cinta_tzx.play_tape:=false;
        amstrad_tapes:=true;
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