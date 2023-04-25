unit sg1000;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,tms99xx,sn_76496,sysutils,dialogs,
     misc_functions,sound_engine,file_engine;

procedure cargar_sg;

implementation
uses principal;

var
  ram_8k,mid_8k_ram,push_pause:boolean;

procedure eventos_sg;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  //P2
  if arcade_input.up[1] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.down[1] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.coin[0] then push_pause:=true
    else begin
      if push_pause then
        z80_0.change_nmi(PULSE_LINE);
      push_pause:=false;
    end;
end;
end;

procedure sg_principal;
var
  frame:single;
  f:word;
begin
init_controls(false,false,false,true);
frame:=z80_0.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to 261 do begin
      z80_0.run(frame);
      frame:=frame+z80_0.tframes-z80_0.contador;
      tms_0.refresh(f);
  end;
  actualiza_trozo_simple(0,0,284,243,1);
  eventos_sg;
  video_sync;
end;
end;

function sg_getbyte(direccion:word):byte;
begin
case direccion of
  0..$bfff:sg_getbyte:=memoria[direccion];
  $c000..$ffff:sg_getbyte:=memoria[$c000+direccion and $1fff];
end;
end;
procedure sg_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$1fff,$4000..$7fff,$a000..$bfff:; //ROM
  $2000..$3fff:if ram_8k then memoria[direccion]:=valor;
  $8000..$9fff:if mid_8k_ram then memoria[direccion]:=valor;
  $c000..$ffff:memoria[$c000+(direccion and $1fff)]:=valor;
end;
end;

function sg_inbyte(puerto:word):byte;
begin
  sg_inbyte:=$ff;
  case (puerto and $ff) of
    $80..$bf:if (puerto and $01)<>0 then sg_inbyte:=tms_0.register_r
          else sg_inbyte:=tms_0.vram_r;
    $c0..$ff:if (puerto and 1)<>0 then sg_inbyte:=marcade.in1
                  else sg_inbyte:=marcade.in0;
  end;
end;
procedure sg_outbyte(puerto:word;valor:byte);
begin
  case (puerto and $ff) of
    $40..$7f:sn_76496_0.Write(valor);
    $80..$bf:if (puerto and $1)<>0 then tms_0.register_w(valor)
                else tms_0.vram_w(valor);
    $c0..$ff:; //mandos
  end;
end;

procedure sg_interrupt(int:boolean);
begin
  if int then z80_0.change_irq(ASSERT_LINE)
     else z80_0.change_irq(CLEAR_LINE);
end;

procedure sg_sound_update;
begin
  sn_76496_0.update;
end;

//Main
procedure reset_sg;
begin
 z80_0.reset;
 sn_76496_0.reset;
 tms_0.reset;
 reset_audio;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 push_pause:=false;
end;

procedure abrir_sg;
var
  extension,nombre_file,RomFile:string;
  datos:pbyte;
  longitud:integer;
  resultado:boolean;
  crc_val:dword;
begin
  if not(OpenRom(StSG1000,RomFile)) then exit;
  extension:=extension_fichero(RomFile);
  resultado:=false;
  if extension='ZIP' then begin
    if search_file_from_zip(RomFile,'*.sg',nombre_file,longitud,crc_val,true) then begin
      getmem(datos,longitud);
      if not(load_file_from_zip(RomFile,nombre_file,datos,longitud,crc_val,true)) then freemem(datos)
        else resultado:=true;
    end;
  end else begin
    if extension='SG' then begin
      if read_file_size(RomFile,longitud) then begin
        getmem(datos,longitud);
        if not(read_file(RomFile,datos,longitud)) then freemem(datos)
          else resultado:=true;
        nombre_file:=extractfilename(RomFile);
      end;
    end;
  end;
  if not(resultado) then begin
    MessageDlg('Error cargando snapshot/ROM.'+chr(10)+chr(13)+'Error loading the snapshot/ROM.', mtInformation,[mbOk], 0);
    exit;
  end;
  //Abrirlo
  extension:=extension_fichero(nombre_file);
  if longitud>49152 then longitud:=49152;
  if extension='SG' then copymemory(@memoria,datos,longitud);
  ram_8k:=false;
  mid_8k_ram:=false;
  crc_val:=calc_crc(datos,longitud);
  freemem(datos);
  case dword(crc_val) of
    //BomberMan Super (2), King's Valley, Knightmare, Legend of Kage, Rally X, Road Fighter, Tank Battalion, Twinbee, YieAr KungFu II
    $69fc1494,$ce5648c3,$223397a1,$281d2888,$2e7166d5,$306d5f78,$29e047cc,$5cbd1163,$c550b4f0,$fc87463c:ram_8k:=true;
    //Castle, Othello (2)
    $92f29d6,$af4f14bc,$1d1a0ca3:mid_8k_ram:=true;
  end;
  reset_sg;
  change_caption(nombre_file);
  Directory.sg1000:=ExtractFilePath(romfile);
end;

function iniciar_sg:boolean;
begin
iniciar_sg:=false;
iniciar_audio(false);
screen_init(1,284,243);
iniciar_video(284,243);
//Main CPU
z80_0:=cpu_z80.create(3579545,262);
z80_0.change_ram_calls(sg_getbyte,sg_putbyte);
z80_0.change_io_calls(sg_inbyte,sg_outbyte);
z80_0.init_sound(sg_sound_update);
//TMS
tms_0:=tms99xx_chip.create(1,sg_interrupt);
//Chip Sonido
sn_76496_0:=sn76496_chip.Create(3579545);
//final
reset_sg;
if main_vars.console_init then abrir_sg;
iniciar_sg:=true;
end;

procedure cargar_sg;
begin
principal1.BitBtn10.Glyph:=nil;
principal1.imagelist2.GetBitmap(4,principal1.BitBtn10.Glyph);
principal1.BitBtn10.OnClick:=principal1.fLoadCartucho;
llamadas_maquina.iniciar:=iniciar_sg;
llamadas_maquina.bucle_general:=sg_principal;
llamadas_maquina.reset:=reset_sg;
llamadas_maquina.cartuchos:=abrir_sg;
llamadas_maquina.fps_max:=59.922743;
end;

end.
