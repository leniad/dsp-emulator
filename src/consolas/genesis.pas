unit genesis;
interface

uses nz80,m68000,{$IFDEF WINDOWS}windows,{$ENDIF}
     main_engine,controls_engine,sega_315_5313,sysutils,rom_engine,
     misc_functions,sound_engine,file_engine,dialogs;

procedure cargar_genesis;

implementation
uses principal;

var
  ram:array[0..$7fff] of word;
  rom:array[0..$1fffff] of word;
  io_control:array[0..$f] of byte;
  z80_is_reset,z80_has_bus:boolean;

procedure genesis_principal;
var
  frame_m,frame_s:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
frame_s:=z80_0.tframes;
while EmuStatus=EsRunning do begin
 for f:=0 to 261 do begin
    vdp_5313_0.handle_scanline(f);
    //main
    m68000_0.run(frame_m);
    frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
    //sound
    z80_0.run(frame_s);
    frame_s:=frame_s+z80_0.tframes-z80_0.contador;
 end;
 vdp_5313_0.handle_eof;
 //eventos_genesis;
 video_sync;
end;
end;

function genesis_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$3fff:genesis_snd_getbyte:=memoria[direccion and $1fff];
  $4000..$5fff:halt(0); //YM
  $6000..$7eff:genesis_snd_getbyte:=$ff;
  $7f00..$7f1f:halt(0);
  $7f20..$7fff:halt(0);
  $8000..$ffff:halt(0);
end;
end;

procedure genesis_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$3fff:memoria[direccion and $1fff]:=valor;
  $4000..$5fff:halt(0); //YM
  $6000..$60ff:halt(0); //bank RAM
  $6100..$7eff:;
  $7f00..$7f1f:halt(0);
  $7f20..$7fff:halt(0);
  $8000..$ffff:halt(0);
end;
end;

procedure check_z80_bus_reset;
begin
  // Is the z80 RESET line pulled?
	if z80_is_reset then begin
    z80_0.reset;
		z80_0.change_halt(ASSERT_LINE);
		//m_ymsnd->reset();
	end	else begin
		// Check if z80 has the bus
		if z80_has_bus then z80_0.change_halt(CLEAR_LINE)
		else z80_0.change_halt(ASSERT_LINE);
	end;
end;

function genesis_getword(direccion:dword):word;
begin
case direccion of
  0..$3fffff:genesis_getword:=rom[direccion shr 1];
  $a00000..$a0ffff:if (not(z80_has_bus) and not(z80_is_reset)) then genesis_getword:=memoria[((direccion and $7fff) shl 1) or 1] or memoria[(direccion and $7fff) shl 1]
                    else genesis_getword:=random($10000);
  $a10000..$a1001f:genesis_getword:=io_control[(direccion and $1f) shr 1];
  $a11100:if m68000_0.read_8bits_hi_dir then
  halt(0)
            else begin
              if (z80_has_bus or z80_is_reset) then genesis_getword:=random($10000) or $100
		            else genesis_getword:=random($10000) and $feff;
            end;  //megadriv_68k_check_z80_bus
  $c00000..$c0001f:genesis_getword:=vdp_5313_0.read(direccion and $1f);
  $e00000..$ffffff:genesis_getword:=ram[(direccion and $ffff) shr 1];
  else halt(direccion);
end;
end;

procedure genesis_putword(direccion:dword;valor:word);
begin
case direccion of
  0..$3fffff:;
  $a00000..$a0ffff:if (not(z80_has_bus) and not(z80_is_reset)) then begin
                      if m68000_0.write_8bits_hi_dir then memoria[((direccion and $7fff) shl 1) or 1]:=valor and $ff
                        else memoria[(direccion and $7fff) shl 1]:=valor shr 8;
                   end;
  $a10000..$a1001f:halt(0);
  $a11100:begin
            if (not(m68000_0.write_8bits_hi_dir) and not(m68000_0.write_8bits_lo_dir)) then begin
              if (valor and $0100)<>0 then z80_has_bus:=false
                else z80_has_bus:=true;
            end else
            halt(0);  //megadriv_68k_req_z80_bus
            check_z80_bus_reset;
          end;
  $a11200:begin
            if (not(m68000_0.write_8bits_hi_dir) and not(m68000_0.write_8bits_lo_dir)) then begin
              if (valor and $0100)<>0 then z80_is_reset:=false
                else z80_is_reset:=true;
            end else halt(0);  //megadriv_68k_req_z80_reset
            check_z80_bus_reset;
           end;
  $a14000..$a14fff:;
  $c00000..$c0001f:vdp_5313_0.write(direccion and $1f,valor);
  $e00000..$ffffff:ram[(direccion and $ffff) shr 1]:=valor;
  else halt(direccion);
end;
end;

procedure genesis_irq4(state:boolean);
begin
  if state then m68000_0.irq[4]:=HOLD_LINE
	  else m68000_0.irq[4]:=CLEAR_LINE;
end;

procedure genesis_irq6(state:boolean);
begin
  if state then m68000_0.irq[6]:=HOLD_LINE
	  else m68000_0.irq[6]:=CLEAR_LINE;
end;

procedure reset_genesis;
begin
 m68000_0.reset;
 vdp_5313_0.reset;
 io_control[0]:=$a1;
 io_control[1]:=$7f;
 io_control[2]:=$7f;
 io_control[3]:=$40;
 io_control[4]:=$0;
 io_control[5]:=$0;
 io_control[6]:=$0;
 io_control[7]:=$ff;
 io_control[8]:=$0;
 io_control[9]:=$0;
 io_control[$a]:=$ff;
 io_control[$b]:=$0;
 io_control[$c]:=$0;
 io_control[$d]:=$ff;
 io_control[$e]:=$0;
 io_control[$f]:=$0;
 //z80
 z80_has_bus:=true;
 z80_is_reset:=true;
 check_z80_bus_reset;
end;

procedure abrir_genesis;
begin
end;

function iniciar_genesis:boolean;
var
  f,longitud:integer;
  tword:word;
begin
iniciar_genesis:=false;
if MessageDlg('Warning. This is a WIP driver, it''s not finished yet and bad things could happen!. Do you want to continue?', mtWarning, [mbYes]+[mbNo],0)=7 then exit;
iniciar_audio(true);
screen_init(1,284,243);
iniciar_video(284,243);
//Main CPU
m68000_0:=cpu_m68000.create(53693175 div 7,262,TCPU_68000);
m68000_0.change_ram16_calls(genesis_getword,genesis_putword);
//sound cpu
z80_0:=cpu_z80.create(53693175 div 15,262);
z80_0.change_ram_calls(genesis_snd_getbyte,genesis_snd_putbyte);
//Video
vdp_5313_0:=vdp_5313_chip.create(false);
vdp_5313_0.change_irqs(nil,genesis_irq4,genesis_irq6);
read_file('D:\Datos\dsp\genesis\Flicky (UE) [!].bin',pbyte(@rom),longitud);
for f:=0 to ((longitud-1) shr 1) do begin
  rom[f]:=(rom[f] shr 8) or ((rom[f] and $ff) shl 8);
end;
end;

procedure cerrar_genesis;
begin
end;

procedure cargar_genesis;
begin
principal1.BitBtn10.Glyph:=nil;
principal1.imagelist2.GetBitmap(4,principal1.BitBtn10.Glyph);
principal1.BitBtn10.OnClick:=principal1.fLoadCartucho;
llamadas_maquina.iniciar:=iniciar_genesis;
llamadas_maquina.bucle_general:=genesis_principal;
llamadas_maquina.close:=cerrar_genesis;
llamadas_maquina.reset:=reset_genesis;
llamadas_maquina.cartuchos:=abrir_genesis;
end;

end.
