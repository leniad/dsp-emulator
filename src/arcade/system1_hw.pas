unit system1_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     system1_hw_misc,system2_hw_misc,nz80,main_engine,gfx_engine,sn_76496,
     controls_engine,pal_engine,sound_engine,ppi8255,z80pio;

procedure Cargar_system1;
procedure cerrar_system1;
procedure eventos_system1;
procedure update_video_system1;
procedure update_backgroud(screen:byte);
//Main CPU
function system1_inbyte_ppi(puerto:word):byte;
procedure system1_outbyte_ppi(valor:byte;puerto:word);
//Sound CPU
procedure system1_snd_putbyte(direccion:word;valor:byte);
function system1_snd_getbyte_ppi(direccion:word):byte;
procedure system1_sound_update;
//PPI 8255
procedure system1_port_a_write(valor:byte);
procedure system1_port_b_write(valor:byte);
procedure system1_port_c_write(valor:byte);

const
  z80_op:array[0..$ff] of byte=(
	4*5+1*2,10*5+3*2, 7*5+1*2, 6*5+1*2, 4*5+1*2, 4*5+1*2, 7*5+2*2, 4*5+1*2, 4*5+1*2,11*5+1*2, 7*5+1*2, 6*5+1*2, 4*5+1*2, 4*5+1*2, 7*5+2*2, 4*5+1*2,
	8*5+2*2,10*5+3*2, 7*5+1*2, 6*5+1*2, 4*5+1*2, 4*5+1*2, 7*5+2*2, 4*5+1*2,12*5+2*2,11*5+1*2, 7*5+1*2, 6*5+1*2, 4*5+1*2, 4*5+1*2, 7*5+2*2, 4*5+1*2,
	7*5+2*2,10*5+3*2,16*5+3*2, 6*5+1*2, 4*5+1*2, 4*5+1*2, 7*5+2*2, 4*5+1*2, 7*5+2*2,11*5+1*2,16*5+3*2, 6*5+1*2, 4*5+1*2, 4*5+1*2, 7*5+2*2, 4*5+1*2,
	7*5+2*2,10*5+3*2,13*5+3*2, 6*5+1*2,11*5+1*2,11*5+1*2,10*5+2*2, 4*5+1*2, 7*5+2*2,11*5+1*2,13*5+3*2, 6*5+1*2, 4*5+1*2, 4*5+1*2, 7*5+2*2, 4*5+1*2,
	4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 7*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 7*5+1*2, 4*5+1*2,
	4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 7*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 7*5+1*2, 4*5+1*2,
	4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 7*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 7*5+1*2, 4*5+1*2,
	7*5+1*2, 7*5+1*2, 7*5+1*2, 7*5+1*2, 7*5+1*2, 7*5+1*2, 4*5+1*2, 7*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 7*5+1*2, 4*5+1*2,
	4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 7*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 7*5+1*2, 4*5+1*2,
	4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 7*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 7*5+1*2, 4*5+1*2,
	4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 7*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 7*5+1*2, 4*5+1*2,
	4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 7*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 4*5+1*2, 7*5+1*2, 4*5+1*2,
	5*5+1*2,10*5+1*2,10*5+3*2,10*5+3*2,10*5+3*2,11*5+1*2, 7*5+2*2,11*5+1*2, 5*5+1*2,10*5+1*2,10*5+3*2, 0*5    ,10*5+3*2,17*5+3*2, 7*5+2*2,11*5+1*2,
	5*5+1*2,10*5+1*2,10*5+3*2,11*5+2*2,10*5+3*2,11*5+1*2, 7*5+2*2,11*5+1*2, 5*5+1*2, 4*5+1*2,10*5+3*2,11*5+2*2,10*5+3*2, 0*5    , 7*5+2*2,11*5+1*2,
	5*5+1*2,10*5+1*2,10*5+3*2,19*5+1*2,10*5+3*2,11*5+1*2, 7*5+2*2,11*5+1*2, 5*5+1*2, 4*5+1*2,10*5+3*2, 4*5+1*2,10*5+3*2, 0*5    , 7*5+2*2,11*5+1*2,
	5*5+1*2,10*5+1*2,10*5+3*2, 4*5+1*2,10*5+3*2,11*5+1*2, 7*5+2*2,11*5+1*2, 5*5+1*2, 6*5+1*2,10*5+3*2, 4*5+1*2,10*5+3*2, 0*5    , 7*5+2*2,11*5+1*2);
  z80_cb:array[0..$ff] of byte =(
	8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,15*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,15*5+2*2, 8*5+2*2,
	8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,15*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,15*5+2*2, 8*5+2*2,
	8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,15*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,15*5+2*2, 8*5+2*2,
	8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,15*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,15*5+2*2, 8*5+2*2,
	8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,12*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,12*5+2*2, 8*5+2*2,
	8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,12*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,12*5+2*2, 8*5+2*2,
	8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,12*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,12*5+2*2, 8*5+2*2,
	8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,12*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,12*5+2*2, 8*5+2*2,
	8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,15*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,15*5+2*2, 8*5+2*2,
	8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,15*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,15*5+2*2, 8*5+2*2,
	8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,15*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,15*5+2*2, 8*5+2*2,
	8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,15*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,15*5+2*2, 8*5+2*2,
	8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,15*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,15*5+2*2, 8*5+2*2,
	8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,15*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,15*5+2*2, 8*5+2*2,
	8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,15*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,15*5+2*2, 8*5+2*2,
	8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,15*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,15*5+2*2, 8*5+2*2);
  z80_dd:array[0..$ff] of byte= (
( 4+4)*5+2*2,(10+4)*5+4*2,( 7+4)*5+2*2,( 6+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 7+4)*5+3*2,( 4+4)*5+2*2,( 4+4)*5+2*2,(11+4)*5+2*2,( 7+4)*5+2*2,( 6+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 7+4)*5+3*2,( 4+4)*5+2*2,
( 8+4)*5+3*2,(10+4)*5+4*2,( 7+4)*5+2*2,( 6+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 7+4)*5+3*2,( 4+4)*5+2*2,(12+4)*5+3*2,(11+4)*5+2*2,( 7+4)*5+2*2,( 6+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 7+4)*5+3*2,( 4+4)*5+2*2,
( 7+4)*5+3*2,(10+4)*5+4*2,(16+4)*5+4*2,( 6+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 7+4)*5+3*2,( 4+4)*5+2*2,( 7+4)*5+3*2,(11+4)*5+2*2,(16+4)*5+4*2,( 6+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 7+4)*5+3*2,( 4+4)*5+2*2,
( 7+4)*5+3*2,(10+4)*5+4*2,(13+4)*5+4*2,( 6+4)*5+2*2,(23  )*5+3*2,(23  )*5+3*2,(19  )*5+4*2,( 4+4)*5+2*2,( 7+4)*5+3*2,(11+4)*5+2*2,(13+4)*5+4*2,( 6+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 7+4)*5+3*2,( 4+4)*5+2*2,
( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,(19  )*5+3*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,(19  )*5+3*2,( 4+4)*5+2*2,
( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,(19  )*5+3*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,(19  )*5+3*2,( 4+4)*5+2*2,
( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,(19  )*5+3*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,(19  )*5+3*2,( 4+4)*5+2*2,
(19  )*5+3*2,(19  )*5+3*2,(19  )*5+3*2,(19  )*5+3*2,(19  )*5+3*2,(19  )*5+3*2,( 4+4)*5+2*2,(19  )*5+3*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,(19  )*5+3*2,( 4+4)*5+2*2,
( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,(19  )*5+3*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,(19  )*5+3*2,( 4+4)*5+2*2,
( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,(19  )*5+3*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,(19  )*5+3*2,( 4+4)*5+2*2,
( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,(19  )*5+3*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,(19  )*5+3*2,( 4+4)*5+2*2,
( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,(19  )*5+3*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,( 4+4)*5+2*2,(19  )*5+3*2,( 4+4)*5+2*2,
( 5+4)*5+2*2,(10+4)*5+2*2,(10+4)*5+4*2,(10+4)*5+4*2,(10+4)*5+4*2,(11+4)*5+2*2,( 7+4)*5+3*2,(11+4)*5+2*2,( 5+4)*5+2*2,(10+4)*5+2*2,(10+4)*5+4*2,( 0  )*5    ,(10+4)*5+4*2,(17+4)*5+4*2,( 7+4)*5+3*2,(11+4)*5+2*2,
( 5+4)*5+2*2,(10+4)*5+2*2,(10+4)*5+4*2,(11+4)*5+3*2,(10+4)*5+4*2,(11+4)*5+2*2,( 7+4)*5+3*2,(11+4)*5+2*2,( 5+4)*5+2*2,( 4+4)*5+2*2,(10+4)*5+4*2,(11+4)*5+3*2,(10+4)*5+4*2,( 4  )*5+2*2,( 7+4)*5+3*2,(11+4)*5+2*2,
( 5+4)*5+2*2,(10+4)*5+2*2,(10+4)*5+4*2,(19+4)*5+2*2,(10+4)*5+4*2,(11+4)*5+2*2,( 7+4)*5+3*2,(11+4)*5+2*2,( 5+4)*5+2*2,( 4+4)*5+2*2,(10+4)*5+4*2,( 4+4)*5+2*2,(10+4)*5+4*2,( 4  )*5+2*2,( 7+4)*5+3*2,(11+4)*5+2*2,
( 5+4)*5+2*2,(10+4)*5+2*2,(10+4)*5+4*2,( 4+4)*5+2*2,(10+4)*5+4*2,(11+4)*5+2*2,( 7+4)*5+3*2,(11+4)*5+2*2,( 5+4)*5+2*2,( 6+4)*5+2*2,(10+4)*5+4*2,( 4+4)*5+2*2,(10+4)*5+4*2,( 4  )*5+2*2,( 7+4)*5+3*2,(11+4)*5+2*2);
  z80_ddcb:array[0..$ff] of byte = (
23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,
23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,
23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,
23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,
20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,
20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,
20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,
20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,20*5+4*2,
23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,
23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,
23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,
23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,
23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,
23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,
23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,
23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2,23*5+4*2);
  z80_ed:array[0..$ff] of byte = (
	8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,
	8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,
	8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,
	8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,
12*5+2*2,12*5+2*2,15*5+2*2,20*5+4*2, 8*5+2*2,14*5+2*2, 8*5+2*2, 9*5+2*2,12*5+2*2,12*5+2*2,15*5+2*2,20*5+4*2, 8*5+2*2,14*5+2*2, 8*5+2*2, 9*5+2*2,
12*5+2*2,12*5+2*2,15*5+2*2,20*5+4*2, 8*5+2*2,14*5+2*2, 8*5+2*2, 9*5+2*2,12*5+2*2,12*5+2*2,15*5+2*2,20*5+4*2, 8*5+2*2,14*5+2*2, 8*5+2*2, 9*5+2*2,
12*5+2*2,12*5+2*2,15*5+2*2,20*5+4*2, 8*5+2*2,14*5+2*2, 8*5+2*2,18*5+2*2,12*5+2*2,12*5+2*2,15*5+2*2,20*5+4*2, 8*5+2*2,14*5+2*2, 8*5+2*2,18*5+2*2,
12*5+2*2,12*5+2*2,15*5+2*2,20*5+4*2, 8*5+2*2,14*5+2*2, 8*5+2*2, 8*5+2*2,12*5+2*2,12*5+2*2,15*5+2*2,20*5+4*2, 8*5+2*2,14*5+2*2, 8*5+2*2, 8*5+2*2,
	8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,
	8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,
16*5+2*2,16*5+2*2,16*5+2*2,16*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,16*5+2*2,16*5+2*2,16*5+2*2,16*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,
16*5+2*2,16*5+2*2,16*5+2*2,16*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,16*5+2*2,16*5+2*2,16*5+2*2,16*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,
	8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,
	8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,
	8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2,
	8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2, 8*5+2*2);
  z80_ex:array[0..$ff] of byte = (
	0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5,
	5*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, // DJNZ */
	5*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 5*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, // JR NZ/JR Z */
	5*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 5*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, // JR NC/JR C */
	0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5,
	0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5,
	0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5,
	0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5,
	0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5,
	0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5,
	0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5, 0*5,
	5*5, 5*5, 5*5, 5*5, 0*5, 0*5, 0*5, 0*5, 5*5, 5*5, 5*5, 5*5, 0*5, 0*5, 0*5, 0*5, // LDIR/CPIR/INIR/OTIR LDDR/CPDR/INDR/OTDR */
	6*5, 0*5, 0*5, 0*5, 7*5, 0*5, 0*5, 2*5, 6*5, 0*5, 0*5, 0*5, 7*5, 0*5, 0*5, 2*5,
	6*5, 0*5, 0*5, 0*5, 7*5, 0*5, 0*5, 2*5, 6*5, 0*5, 0*5, 0*5, 7*5, 0*5, 0*5, 2*5,
	6*5, 0*5, 0*5, 0*5, 7*5, 0*5, 0*5, 2*5, 6*5, 0*5, 0*5, 0*5, 7*5, 0*5, 0*5, 2*5,
	6*5, 0*5, 0*5, 0*5, 7*5, 0*5, 0*5, 2*5, 6*5, 0*5, 0*5, 0*5, 7*5, 0*5, 0*5, 2*5);

var
 //Screens
 bg_ram:array[0..$3fff] of byte;
 bg_ram_w:array[0..$1fff] of boolean;
 sprites_final_screen:array[0..$ffff] of word;
 final_screen:array[0..7,0..$ffff] of word;
 bgpixmaps:array[0..3] of byte;
 sprite_num_banks,sprite_offset:byte;
 yscroll,mask_char:word;
 xscroll:array[0..$1f] of word;
 //Roms
 memoria_proms:array[0..$2ff] of byte;
 lookup_memory:array[0..$ff] of byte;
 mem_dec:array[0..$7fff] of byte;
 //Colisiones
 sprite_collide:array[0..$3ff] of byte;
 mix_collide:array[0..$3f] of byte;
 memoria_sprites:array[0..$1ffff] of byte;
 mix_collide_summary,sprite_collide_summary:byte;
 //Misc
 sound_latch,scroll_x,scroll_y,system1_videomode:byte;
 char_screen:byte;
 //dips
 dip_a,dip_b:byte;

implementation

procedure Cargar_system1;
begin
case main_vars.tipo_maquina of
  27,35,36,152,153,154,155:begin
        llamadas_maquina.iniciar:=iniciar_system1;
        llamadas_maquina.bucle_general:=system1_principal;
        llamadas_maquina.reset:=reset_system1;
     end;
  37,151:begin
        llamadas_maquina.iniciar:=iniciar_system2;
        llamadas_maquina.bucle_general:=system2_principal;
        llamadas_maquina.reset:=reset_system2;
     end;
end;
llamadas_maquina.cerrar:=cerrar_system1;
llamadas_maquina.fps_max:=60.096154;
end;

procedure cerrar_system1;
begin
case main_vars.tipo_maquina of
  27,35,36,153,155:z80pio_close(0);
end;
end;

procedure draw_sprites;inline;
var
  spritedata,srcaddr,stride:word;
  bank,xstart,bottom,top,palettebase:word;
  x,y,addrdelta:integer;
  color1,color2,data:byte;
  f:byte;
  gfxbankbase:dword;
  curaddr,destbase,prevpix:word;
begin
for f:=0 to 31 do begin
  spritedata:=$d000+f*$10;
  srcaddr:=memoria[spritedata+6]+(memoria[spritedata+7] shl 8);
  stride:=memoria[spritedata+4]+(memoria[spritedata+5] shl 8);
	bank:=((memoria[spritedata+3] and $80) shr 7) or ((memoria[spritedata+3] and $40) shr 5) or ((memoria[spritedata+3] and $20) shr 3);
	xstart:=(((memoria[spritedata+2]+(memoria[spritedata+3] shl 8)) and $1ff) div 2)+sprite_offset;
	bottom:=memoria[spritedata+1]+1;
	top:=memoria[spritedata+0]+1;
	palettebase:=f*$10;
  bank:=bank mod sprite_num_banks;
  gfxbankbase:=bank*$8000;
  for y:=top to bottom-1 do begin
			destbase:=y*256;
			// advance by the row counter */
			srcaddr:=srcaddr+stride;
			// skip if outside of our clipping area
			if (y<0) or (y>256) then continue;
			// iterate over X */
      if (srcaddr and $8000)<>0 then addrdelta:=-1
        else addrdelta:=1;
      curaddr:=srcaddr;
      x:=xstart;
      while True do begin
				data:=memoria_sprites[gfxbankbase+(curaddr and $7fff)];
				// non-flipped case */
				if (curaddr and $8000)=0 then begin
					color1:=data shr 4;
					color2:=data and $f;
				end else begin
					color1:=data and $0f;
					color2:=data shr 4;
				end;
				// stop when we see color 0x0f */
				if (color1=$f) then break;
				// draw if non-transparent */
				if (color1<>0) then begin
					if ((x>=0) and (x<=255)) then begin
						prevpix:=sprites_final_screen[destbase+x];
						if ((prevpix and $0f)<>0) then begin
              sprite_collide[((prevpix shr 4) and $1f)+32*f]:=1;
              sprite_collide_summary:=1;
            end;
						sprites_final_screen[destbase+x]:=color1 or palettebase;
					end;
				end;
        // stop when we see color 0x0f */
				if (color2=$f) then break;
				// draw if non-transparent */
				if (color2<>0) then begin
					if (((x+1)>=0) and ((x+1)<=255)) then begin
						prevpix:=sprites_final_screen[destbase+x+1];
						if ((prevpix and $0f)<>0) then begin
              sprite_collide[((prevpix shr 4) and $1f)+32*f]:=1;
              sprite_collide_summary:=1;
            end;
						sprites_final_screen[destbase+x+1]:=color2 or palettebase;
					end;
        end;
        curaddr:=curaddr+addrdelta;
        x:=x+2;
				end;
      end;
  end; //del for f
end;

procedure put_gfx_system1(pos_x,pos_y,nchar,color:word;screen:byte);inline;
var
  x,y:byte;
  temp:pword;
  pos:pbyte;
begin
pos:=gfx[0].datos;
inc(pos,nchar*8*8);
for y:=0 to 7 do begin
  temp:=punbuf;
  for x:=0 to 7 do begin
    temp^:=pos^ or color;
    inc(pos);
    inc(temp);
  end;
  copymemory(@final_screen[screen,pos_x+((pos_y+y)*256)],punbuf,8*2);
end;
end;

procedure update_backgroud(screen:byte);
var
  source,f,color,nchar,atrib:word;
  x,y:word;
begin
source:=screen shl 11;
for f:=0 to $3ff do begin
   if (bg_ram_w[f+(source shr 1)]) then begin
      x:=f mod 32;
      y:=f div 32;
      atrib:=bg_ram[f*2+source]+(bg_ram[$1+(f*2)+source] shl 8);
      nchar:=(((atrib shr 4) and $800) or (atrib and $7ff)) and mask_char;
      color:=((atrib shr 5) and $ff) shl 3;
      put_gfx_system1(x*8,y*8,nchar,color,screen);
      bg_ram_w[f+(source shr 1)]:=false;
   end;
end;
end;

procedure update_video_system1;
var
  x,y:integer;
  temp:pword;
  fgbase,sprbase,bgy,bgxscroll:word;
  lookup_value,lookup_index:byte;
  bgx,fgpix,bgpix,sprpix:word;
  bgbase:array[0..1] of byte;
  bit0,bit1,bit2,bit3,bit4:byte;
begin
if (system1_videomode and $10)<>0 then begin
  fill_full_screen(0,$800);
  exit;
end;
//Actualizar sprites
fillword(@sprites_final_screen[0],$10000,0);
if memoria[$d000]<>$ff then draw_sprites;
//Pintarlo todo
for y:=0 to 255 do begin
    temp:=punbuf;
		fgbase:=(y and $ff)*256;
		sprbase:=(y and $ff)*256;
    bgy:=(y+yscroll) and $1ff;
    bgxscroll:=xscroll[y div 8];
		// get the base of the left and right pixmaps for the effective background Y */
		bgbase[0]:=bgpixmaps[(bgy shr 8)*2+0];
		bgbase[1]:=bgpixmaps[(bgy shr 8)*2+1];
		// iterate over pixels */
		for x:=0 to 255 do begin
			bgx:=(x-bgxscroll) and $1ff;
			fgpix:=final_screen[char_screen,fgbase+x];
			bgpix:=final_screen[bgbase[bgx shr 8],(bgx and $ff)+(bgy and $ff)*256];
			sprpix:=sprites_final_screen[sprbase+x];
			//using the sprite, background, and foreground pixels, look up the color behavior */
      if (sprpix and $f)=0 then bit0:=1
        else bit0:=0;
      if (fgpix and 7)=0 then bit1:=2
        else bit1:=0;
      bit2:=((fgpix shr 9) and 3) shl 2;
      if (bgpix and 7)=0 then bit3:=16
        else bit3:=0;
      bit4:=((bgpix shr 9) and 3) shl 5;
			lookup_index:=bit0 or bit1 or bit2 or	bit3 or	bit4;
			lookup_value:=lookup_memory[lookup_index];
			// compute collisions based on two of the PROM bits */
			if (lookup_value and 4)=0 then begin
				mix_collide[((lookup_value and 8) shl 2) or ((sprpix shr 4) and $1f)]:=1;
        mix_collide_summary:=1;
      end;
			// the lower 2 PROM bits select the palette and which pixels */
			lookup_value:=lookup_value and 3;
      if (lookup_value=0) then temp^:=paleta[$000 or (sprpix and $1ff)]
			    else if (lookup_value=1) then temp^:=paleta[$200 or (fgpix and $1ff)]
			      else temp^:=paleta[$400 or (bgpix and $1ff)];
      inc(temp);
		end;
    putpixel(ADD_SPRITE,y+ADD_SPRITE,256,punbuf,1);
end;
//Pantalla final
if main_screen.rol90_screen then actualiza_trozo_final(8,0,240,224,1)
  else actualiza_trozo_final(0,0,256,224,1);
end;

//Main CPU PPI
function system1_inbyte_ppi(puerto:word):byte;
begin
case (puerto and $1f) of
  $0..$3:system1_inbyte_ppi:=marcade.in1;
  $4..$7:system1_inbyte_ppi:=marcade.in2;
  $8..$b:system1_inbyte_ppi:=marcade.in0;
  $c,$e:system1_inbyte_ppi:=dip_a;
  $d,$f,$10..$13:system1_inbyte_ppi:=dip_b;
  $14..$17:system1_inbyte_ppi:=pia8255_0.read(puerto and $3);
end;
end;

procedure system1_outbyte_ppi(valor:byte;puerto:word);
begin
case (puerto and $1f) of
  $14..$17:pia8255_0.write(puerto and $3,valor);
end;
end;

//Sound CPU
procedure system1_snd_putbyte(direccion:word;valor:byte);
begin
if direccion<$8000 then exit;
case direccion of
  $8000..$9fff:mem_snd[(direccion and $7ff)+$8000]:=valor;
  $a000..$bfff:sn_76496_0.Write(valor);
  $c000..$dfff:sn_76496_1.Write(valor);
end;
end;

function system1_snd_getbyte_ppi(direccion:word):byte;
var
  port_c_val:byte;
begin
case direccion of
  $0000..$7fff:system1_snd_getbyte_ppi:=mem_snd[direccion];
  $8000..$9fff:system1_snd_getbyte_ppi:=mem_snd[(direccion and $7ff)+$8000];
  $e000..$ffff:begin
                  system1_snd_getbyte_ppi:=sound_latch;
                  port_c_val:=pia8255_0.get_port(2);
                  pia8255_0.set_port(2,port_c_val and $bf);
                  pia8255_0.set_port(2,port_c_val or $40);
               end;
end;
end;

procedure system1_sound_update;
begin
  sn_76496_0.Update;
  sn_76496_1.Update;
end;

procedure eventos_system1;
begin
if event.arcade then begin
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
end;
end;

//PPI 8255
procedure system1_port_a_write(valor:byte);
begin //soundport_w
  sound_latch:=valor;
end;

procedure system1_port_b_write(valor:byte);
begin //videoport_w
  rom_bank:=(valor and $c) shr 2;
  system1_videomode:=valor;
end;

procedure system1_port_c_write(valor:byte);
begin //sound_controlw
  if (valor and $80)<>0 then snd_z80.clear_nmi
    else snd_z80.pedir_nmi:=ASSERT_LINE;
  bg_ram_bank:=(valor shr 1) and $3;
end;


end.
