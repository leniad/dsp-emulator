unit sega_gg;

interface
uses nz80,{$IFDEF WINDOWS}windows,{$ENDIF}
     main_engine,controls_engine,sega_vdp,sn_76496,sysutils,misc_functions,
     sound_engine,sms;

function iniciar_gg:boolean;

var
  gg_0:tmastersystem;

implementation
uses principal,snapshot;

procedure eventos_gg;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then gg_0.keys[0]:=(gg_0.keys[0] and $fe) else gg_0.keys[0]:=(gg_0.keys[0] or 1);
  if arcade_input.down[0] then gg_0.keys[0]:=(gg_0.keys[0] and $fd) else gg_0.keys[0]:=(gg_0.keys[0] or 2);
  if arcade_input.left[0] then gg_0.keys[0]:=(gg_0.keys[0] and $fb) else gg_0.keys[0]:=(gg_0.keys[0] or 4);
  if arcade_input.right[0] then gg_0.keys[0]:=(gg_0.keys[0] and $f7) else gg_0.keys[0]:=(gg_0.keys[0] or 8);
  if arcade_input.but0[0] then gg_0.keys[0]:=(gg_0.keys[0] and $ef) else gg_0.keys[0]:=(gg_0.keys[0] or $10);
  if arcade_input.but1[0] then gg_0.keys[0]:=(gg_0.keys[0] and $df) else gg_0.keys[0]:=(gg_0.keys[0] or $20);
  if arcade_input.start[0] then gg_0.keys[1]:=(gg_0.keys[1] and $7f) else gg_0.keys[1]:=(gg_0.keys[1] or $80);
end;
end;

procedure gg_principal;
var
  frame:single;
  f:word;
begin
init_controls(false,false,true,true);
frame:=z80_0.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to (vdp_0.VIDEO_Y_TOTAL-1) do begin
      z80_0.run(frame);
      frame:=frame+z80_0.tframes-z80_0.contador;
      vdp_0.refresh(f);
  end;
  if vdp_0.gg_set then actualiza_trozo(61,51,160,144,1,0,0,160,144,PANT_TEMP)
    else actualiza_trozo(0,0,284,243,1,0,0,284,243,PANT_TEMP);
  eventos_gg;
  video_sync;
end;
end;

function gg_getbyte(direccion:word):byte;
begin
case direccion of
  0..$3fff:gg_getbyte:=gg_0.mapper.rom[gg_0.mapper.rom_bank[0],direccion];
  $4000..$7fff:gg_getbyte:=gg_0.mapper.rom[gg_0.mapper.rom_bank[1],direccion and $3fff];
  $8000..$bfff:if gg_0.mapper.slot2_ram then gg_getbyte:=gg_0.mapper.ram_slot2[gg_0.mapper.slot2_bank,direccion and $3fff]
                  else gg_getbyte:=gg_0.mapper.rom[gg_0.mapper.rom_bank[2],direccion and $3fff];
  $c000..$ffff:gg_getbyte:=gg_0.mapper.ram[direccion and $1fff];
end;
end;

procedure gg_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:;
  $8000..$bfff:if gg_0.mapper.slot2_ram then gg_0.mapper.ram_slot2[gg_0.mapper.slot2_bank,direccion and $3fff]:=valor;
  $c000..$fffb:gg_0.mapper.ram[direccion and $1fff]:=valor;
  $fffc..$ffff:begin
                  gg_0.mapper.ram[direccion and $1fff]:=valor;
                  case (direccion and $3) of
                    0:begin
                        gg_0.mapper.slot2_ram:=(valor and 8)<>0;
                        gg_0.mapper.slot2_bank:=(valor and 4) shr 2;
                        //if (valor and $3<>0) then MessageDlg('Escribe $fffc '+inttohex(valor,2), mtInformation,[mbOk], 0);
                      end;
                    1:gg_0.mapper.rom_bank[0]:=valor mod gg_0.mapper.max;
                    2:gg_0.mapper.rom_bank[1]:=valor mod gg_0.mapper.max;
                    3:gg_0.mapper.rom_bank[2]:=valor mod gg_0.mapper.max;
                  end;
               end;
end;
end;

function gg_inbyte(puerto:word):byte;
begin
  puerto:=puerto and $ff;
  case puerto of
    0:gg_inbyte:=gg_0.keys[1] or $40;
    1..6:gg_inbyte:=gg_0.io[puerto];
    7..$3f,$c2..$db,$de..$ff:gg_inbyte:=$ff;
    $40..$7f:if (puerto and 1)<>0 then gg_inbyte:=vdp_0.hpos
                else gg_inbyte:=vdp_0.linea_back;
    $80..$bf:if (puerto and $01)<>0 then gg_inbyte:=vdp_0.register_r
          else gg_inbyte:=vdp_0.vram_r;
    $c0,$dc:gg_inbyte:=gg_0.keys[0];
    $c1,$dd:gg_inbyte:=$ff;
  end;
end;

function gg_getbyte_codemasters(direccion:word):byte;
begin
case direccion of
  0..$3fff:gg_getbyte_codemasters:=gg_0.mapper.rom[gg_0.mapper.rom_bank[0],direccion];
  $4000..$7fff:gg_getbyte_codemasters:=gg_0.mapper.rom[gg_0.mapper.rom_bank[1],direccion and $3fff];
  $8000..$9fff:gg_getbyte_codemasters:=gg_0.mapper.rom[gg_0.mapper.rom_bank[2],direccion and $3fff];
  $a000..$bfff:if gg_0.mapper.slot2_ram then gg_getbyte_codemasters:=gg_0.mapper.ram_slot2[0,direccion and $1fff]
                  else gg_getbyte_codemasters:=gg_0.mapper.rom[gg_0.mapper.rom_bank[2],direccion and $3fff];
  $c000..$ffff:gg_getbyte_codemasters:=gg_0.mapper.ram[direccion and $1fff];
end;
end;

procedure gg_putbyte_codemasters(direccion:word;valor:byte);
begin
case direccion of
  0:gg_0.mapper.rom_bank[0]:=valor mod gg_0.mapper.max; //mapper slot 0
  $4000:begin //mapper slot 1
          gg_0.mapper.rom_bank[1]:=(valor and $7f) mod gg_0.mapper.max;
          gg_0.mapper.slot2_ram:=(valor and $80)<>0;
        end;
  $8000:gg_0.mapper.rom_bank[2]:=valor mod gg_0.mapper.max; //mapper slot 2
  $a000..$bfff:if gg_0.mapper.slot2_ram then gg_0.mapper.ram_slot2[0,direccion and $1fff]:=valor;
  $c000..$ffff:gg_0.mapper.ram[direccion and $1fff]:=valor;
end;
end;

procedure gg_outbyte(puerto:word;valor:byte);
procedure memory_control(valor:byte);
begin
  //gg_0.bios_enabled:=(valor and 8)=0;
end;

begin
  case (puerto and $ff) of
    0..6:gg_0.io[puerto and $ff]:=valor;
    7..$3f:if (puerto and $1)=0 then memory_control(valor);
    $40..$7f:sn_76496_0.write(valor);
    $80..$bf:if (puerto and $1)<>0 then vdp_0.register_w(valor)
                else vdp_0.vram_w(valor);
    $c0..$ff:;
  end;
end;

procedure gg_interrupt(int:boolean);
begin
  if int then z80_0.change_irq(ASSERT_LINE)
     else z80_0.change_irq(CLEAR_LINE);
end;

procedure gg_sound_update;
begin
  sn_76496_0.update;
end;

procedure gg_set_hpos(estados:word);
begin
  vdp_0.set_hpos(z80_0.contador);
end;

function read_memory(direccion:word):byte;
begin
  read_memory:=vdp_0.tms.mem[direccion];
end;

procedure write_memory(direccion:word;valor:byte);
begin
  vdp_0.tms.mem[direccion]:=valor;
end;

//Main
procedure reset_gg;
var
    z80_r:npreg_z80;
begin
 z80_0.reset;
 z80_r:=z80_0.get_internal_r;
 z80_r.sp:=$dfeb;
 z80_r.bc.w:=$ff3c;
 z80_r.bc2.w:=$300;
 z80_r.de2.w:=$c73c;
 z80_r.hl.w:=$2;
 z80_r.hl2.w:=$c739;
 z80_r.a:=$14;
 sn_76496_0.reset;
 vdp_0.reset;
 reset_audio;
 gg_0.mapper.slot2_ram:=false;
 gg_0.keys[0]:=$ff;
 gg_0.keys[1]:=$80;
 gg_0.mapper.rom_bank[0]:=0;
 gg_0.mapper.rom_bank[1]:=1 mod gg_0.mapper.max;
 gg_0.mapper.rom_bank[2]:=2 mod gg_0.mapper.max;
 gg_0.mapper.rom_bank[3]:=0;
 gg_0.mapper.slot2_bank:=0;
 gg_0.io[0]:=$c0;
 gg_0.io[1]:=$7f;
 gg_0.io[2]:=$ff;
 gg_0.io[3]:=0;
 gg_0.io[4]:=$ff;
 gg_0.io[5]:=0;
 gg_0.io[6]:=$ff;
end;

procedure abrir_gg;
function abrir_cartucho_gg(data:pbyte;long:dword):boolean;
var
  ptemp:pbyte;
  f:byte;
begin
fillchar(gg_0.mapper.rom[0],sizeof(gg_0.mapper.rom),0);
if long<$4000 then begin
  copymemory(@gg_0.mapper.rom[0,0],data,long);
  gg_0.mapper.max:=1;
end else begin
  ptemp:=data;
  if (long mod $4000)<>0 then inc(ptemp,long mod $4000);
  gg_0.mapper.max:=long div $4000;
  if (long div $4000)>64 then begin
    gg_0.mapper.max:=1;
    abrir_cartucho_gg:=false;
    exit;
  end else gg_0.mapper.max:=long div $4000;
  for f:=0 to (gg_0.mapper.max-1) do begin
    copymemory(@gg_0.mapper.rom[f,0],ptemp,$4000);
    inc(ptemp,$4000);
  end;
end;
abrir_cartucho_gg:=true;
reset_gg;
end;

var
  extension,nombre_file,romfile:string;
  datos:pbyte;
  longitud:integer;
  crc_val:dword;
begin
  if not(openrom(romfile)) then exit;
  getmem(datos,$400000);
  if not(extract_data(romfile,datos,longitud,nombre_file)) then begin
    freemem(datos);
    exit;
  end;
  extension:=extension_fichero(nombre_file);
  if not(vdp_0.gg_set) then begin
    vdp_0.set_gg(true);
    change_video_size(160,144);
  end;
  z80_0.change_ram_calls(gg_getbyte,gg_putbyte);
  crc_val:=calc_crc(datos,longitud);
  case crc_val of
      $5e53c7f7,$dbe8895c,$f7c524f6,$c888222b,$aa140c9c,$8813514b,$9fa727a0,$fb481971,$d9a7f170,
      $76c5bdfb,$c1756bee,$6caa625b,$152f0dcc,$72981057:begin //Codemasters
          z80_0.change_ram_calls(gg_getbyte_codemasters,gg_putbyte_codemasters);
      end;
  end;
  case crc_val of  //Video especial... Tamaño SMS
      $e5f789b9,$9942b69b,$5877b10d,$59840fd6,$aa140c9c,$c8381def,$c888222b,$76c5bdfb,$1d93246e,
      $ce97efe8,$a2f9c7af,$3382d73f,$1eab89d,$f037ec00,$2aa12d7e,$189931e,$86e5b455,$45f058d6,
      $311d2863,$ba6344fc,$1c6c149c,$9c76fb3a,$56201996,$4902b7a2,$fb481971,$9fa727a0,$10dbbef4,
      $bd1cc7df,$8230384e,$da8e95a9,$6f8e46cf,$7bb81e3d,$44fbe8f6,$3b627808,$18086b70,$8813514b:if vdp_0.gg_set then begin
                  vdp_0.set_gg(false);
                  change_video_size(284,243);
                end;
  end;
  if extension='DSP' then snapshot_r(datos,longitud)
    else abrir_cartucho_gg(datos,longitud);
  change_caption(nombre_file);
  Directory.gg:=ExtractFilePath(romfile);
  freemem(datos);
end;

procedure gg_grabar_snapshot;
var
  nombre:string;
begin
nombre:=snapshot_main_write;
Directory.gg:=ExtractFilePath(nombre);
end;

function iniciar_gg:boolean;
begin
iniciar_gg:=false;
principal1.BitBtn10.Glyph:=nil;
principal1.imagelist2.GetBitmap(4,principal1.BitBtn10.Glyph);
principal1.BitBtn10.OnClick:=principal1.fLoadCartucho;
llamadas_maquina.bucle_general:=gg_principal;
llamadas_maquina.reset:=reset_gg;
llamadas_maquina.cartuchos:=abrir_gg;
llamadas_maquina.grabar_snapshot:=gg_grabar_snapshot;
llamadas_maquina.fps_max:=FPS_NTSC;
iniciar_audio(false);
screen_init(1,284,243);
iniciar_video(160,144);
//Main CPU
z80_0:=cpu_z80.create(CLOCK_NTSC,LINES_NTSC);
z80_0.change_ram_calls(gg_getbyte,gg_putbyte);
z80_0.change_io_calls(gg_inbyte,gg_outbyte);
z80_0.init_sound(gg_sound_update);
z80_0.change_misc_calls(gg_set_hpos);
//VDP
vdp_0:=vdp_chip.create(1,gg_interrupt,z80_0.numero_cpu,read_memory,write_memory);
vdp_0.video_ntsc(0);
vdp_0.set_gg(true); //Lo pongo temporalmente, hasta que compruebe que no está en modo SMS
//Sound
sn_76496_0:=sn76496_chip.Create(CLOCK_NTSC);
//Importante!!!
fillchar(sms_0.mapper.bios[0],sizeof(sms_0.mapper.bios),0);
fillchar(sms_0.mapper.rom[0],sizeof(sms_0.mapper.rom),0);
gg_0.mapper.max:=1;
reset_gg;
if main_vars.console_init then abrir_gg;
iniciar_gg:=true;
end;

end.

