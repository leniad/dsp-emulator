unit sms;

interface
uses nz80,{$IFDEF WINDOWS}windows,{$ENDIF}
     main_engine,controls_engine,sega_vdp,sn_76496,sysutils,dialogs,
     rom_engine,misc_functions,sound_engine,file_engine,forms;

procedure Cargar_sms;
procedure sms_principal;
function iniciar_sms:boolean;
procedure reset_sms;
procedure cerrar_sms;
procedure sms_sound_update;
procedure sms_configurar;
//Snapshot
function abrir_sms:boolean;
procedure sms_grabar_snapshot;
//CPU
function sms_getbyte(direccion:word):byte;
procedure sms_putbyte(direccion:word;valor:byte);
function sms_inbyte(puerto:word):byte;
procedure sms_outbyte(valor:byte;puerto:word);
procedure sms_interrupt(int:boolean);
procedure sms_hlines(estados:word);

type
  tmapper_sms=record
      rom:array[0..63,0..$3fff] of byte;
      ram:array[0..$1fff] of byte;
      ram_slot2,bios:array[0..$3fff] of byte;
      slot0,slot1,slot2,max:byte;
      slot2_ram:boolean;
      bios_enabled,bios_loaded,bios_show:boolean;
  end;

var
  joy1,joy2:byte;
  is_sg:boolean;
  mapper_sms:^tmapper_sms;
const
  CLOCK_NTSC=3579545;
  CLOCK_PAL=3546895;
  FPS_NTSC=60;
  FPS_PAL=50;
  sms_bios:tipo_roms=(n:'mpr-12808.ic2';l:$2000;p:0;crc:$0072ed54);

implementation
uses principal,config_sms;

procedure Cargar_sms;
begin
principal1.Panel2.Visible:=true;
principal1.BitBtn1.Visible:=true;
principal1.BitBtn10.Enabled:=true;
principal1.BitBtn10.Glyph:=nil;
principal1.imagelist2.GetBitmap(4,principal1.BitBtn10.Glyph);
principal1.BitBtn10.visible:=true;
principal1.BitBtn10.OnClick:=principal1.fLoadCartucho;
principal1.BitBtn11.visible:=true;
principal1.BitBtn11.Enabled:=true;
principal1.BitBtn8.visible:=false;
llamadas_maquina.iniciar:=iniciar_sms;
llamadas_maquina.bucle_general:=sms_principal;
llamadas_maquina.cerrar:=cerrar_sms;
llamadas_maquina.reset:=reset_sms;
llamadas_maquina.cartuchos:=abrir_sms;
llamadas_maquina.grabar_snapshot:=sms_grabar_snapshot;
if file_data.sms_is_pal then llamadas_maquina.fps_max:=FPS_PAL
  else llamadas_maquina.fps_max:=FPS_NTSC;
llamadas_maquina.configurar:=sms_configurar;
end;

function iniciar_sms:boolean;
begin
iniciar_sms:=false;
iniciar_audio(false);
if file_data.sms_is_pal then begin
  screen_init(1,284,294);
  iniciar_video(284,294);
  main_z80:=cpu_z80.create(CLOCK_PAL,LINES_PAL);
end else begin
  screen_init(1,284,243);
  iniciar_video(284,243);
  main_z80:=cpu_z80.create(CLOCK_NTSC,LINES_NTSC);
end;
//Main CPU
main_z80.change_ram_calls(sms_getbyte,sms_putbyte);
main_z80.change_io_calls(sms_inbyte,sms_outbyte);
main_z80.init_sound(sms_sound_update);
//Mapper
getmem(mapper_sms,sizeof(tmapper_sms));
mapper_sms.bios_loaded:=carga_rom_zip(Directory.Arcade_roms+'sms.zip',sms_bios.n,@mapper_sms.bios[0],sms_bios.l,sms_bios.crc,false);
if mapper_sms.bios_loaded then mapper_sms.bios_enabled:=file_data.sms_bios_enabled
  else mapper_sms.bios_loaded:=false;
//VDP
vdp_0:=vdp_chip.create(1,sms_interrupt);
if file_data.sms_is_pal then begin
  vdp_0.set_pal_video;
  sn_76496_0:=sn76496_chip.Create(CLOCK_PAL);
end else begin
  vdp_0.set_ntsc_video;
  sn_76496_0:=sn76496_chip.Create(CLOCK_NTSC);
end;
main_z80.change_misc_calls(sms_hlines,nil);
//final
abrir_sms;
iniciar_sms:=true;
end;

procedure cerrar_sms;
begin
file_data.sms_is_pal:=vdp_0.is_pal;
file_data.sms_bios_enabled:=mapper_sms.bios_enabled;
main_z80.free;
sn_76496_0.Free;
vdp_0.Free;
freemem(mapper_sms);
close_audio;
close_video;
end;

procedure reset_sms;
begin
 main_z80.reset;
 sn_76496_0.reset;
 vdp_0.reset;
 reset_audio;
 mapper_sms.slot2_ram:=false;
 mapper_sms.bios_show:=mapper_sms.bios_enabled;
 joy1:=$ff;
 joy2:=$ff;
 mapper_sms.slot0:=0;
 mapper_sms.slot1:=1 mod mapper_sms.max;
 mapper_sms.slot2:=2 mod mapper_sms.max;
end;

procedure eventos_sms;inline;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then joy1:=(joy1 and $fe) else joy1:=(joy1 or $1);
  if arcade_input.down[0] then joy1:=(joy1 and $fd) else joy1:=(joy1 or $2);
  if arcade_input.left[0] then joy1:=(joy1 and $fb) else joy1:=(joy1 or $4);
  if arcade_input.right[0] then joy1:=(joy1 and $f7) else joy1:=(joy1 or $8);
  if arcade_input.but0[0] then joy1:=(joy1 and $ef) else joy1:=(joy1 or $10);
  if arcade_input.but1[0] then joy1:=(joy1 and $df) else joy1:=(joy1 or $20);
  //P2
  if arcade_input.up[1] then joy1:=(joy1 and $bf) else joy1:=(joy1 or $40);
  if arcade_input.down[1] then joy1:=(joy1 and $7f) else joy1:=(joy1 or $80);
  if arcade_input.left[1] then joy2:=(joy2 and $fe) else joy2:=(joy2 or $1);
  if arcade_input.right[1] then joy2:=(joy2 and $fd) else joy2:=(joy2 or $2);
  if arcade_input.but0[1] then joy2:=(joy2 and $fb) else joy2:=(joy2 or $4);
  if arcade_input.but1[1] then joy2:=(joy2 and $f7) else joy2:=(joy2 or $8);
end;
end;

procedure sms_principal;
var
  frame:single;
  f:word;
begin
init_controls(false,false,true,false);
frame:=main_z80.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to (vdp_0.VIDEO_Y_TOTAL-1) do begin
      main_z80.run(frame);
      frame:=frame+main_z80.tframes-main_z80.contador;
      vdp_0.refresh(f);
  end;
  actualiza_trozo_simple(0,0,284,vdp_0.VIDEO_VISIBLE_Y_TOTAL,1);
  eventos_sms;
  video_sync;
end;
end;

function sms_getbyte(direccion:word):byte;
begin
case direccion of
  0..$3fff:if mapper_sms.bios_show then sms_getbyte:=mapper_sms.bios[direccion]
              else sms_getbyte:=mapper_sms.rom[mapper_sms.slot0,direccion];
  $4000..$7fff:sms_getbyte:=mapper_sms.rom[mapper_sms.slot1,direccion and $3fff];
  $8000..$bfff:if mapper_sms.slot2_ram then sms_getbyte:=mapper_sms.ram_slot2[direccion and $3fff]
                  else sms_getbyte:=mapper_sms.rom[mapper_sms.slot2,direccion and $3fff];
  $c000..$ffff:if is_sg then sms_getbyte:=mapper_sms.ram[direccion and $7ff]
                  else sms_getbyte:=mapper_sms.ram[direccion and $1fff];
end;
end;

procedure sms_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0:mapper_sms.slot0:=valor mod mapper_sms.max; //Code Masters mapper slot 0
  $3ffe:begin // 4 pack mapper slot 0
			    mapper_sms.slot0:=valor mod mapper_sms.max;
			    mapper_sms.slot2:=((valor and $30)+mapper_sms.slot2) mod mapper_sms.max;
        end;
  $4000:mapper_sms.slot1:=valor mod mapper_sms.max; //Code Masters mapper slot 1
  1..$3ffd,$3fff,$4001..$7ffe:exit; //slot 0+1
  $7fff:mapper_sms.slot1:=valor mod mapper_sms.max; //4 pack slot 1
  $8000:if mapper_sms.slot2_ram then mapper_sms.ram_slot2[direccion and $3fff]:=valor //slot 2
          else mapper_sms.slot2:=valor mod mapper_sms.max; //Code Masters mapper slor 2
  $8001..$9fff:if mapper_sms.slot2_ram then mapper_sms.ram_slot2[direccion and $3fff]:=valor; //slot 2
  $a000:if mapper_sms.slot2_ram then mapper_sms.ram_slot2[direccion and $3fff]:=valor //slot 2
          else mapper_sms.slot2:=valor mod mapper_sms.max; //Korean mapper slor 2
  $a001..$bffe:if mapper_sms.slot2_ram then mapper_sms.ram_slot2[direccion and $3fff]:=valor; //slot 2
  $bfff:if mapper_sms.slot2_ram then mapper_sms.ram_slot2[direccion and $3fff]:=valor //slot 2
                   else mapper_sms.slot2:=((mapper_sms.slot0 and $30)+valor) mod mapper_sms.max; //4 pack slot 2
  $c000..$fffb:if is_sg then mapper_sms.ram[direccion and $7ff]:=valor
                  else mapper_sms.ram[direccion and $1fff]:=valor;
  $fffc..$ffff:begin //Mapper registers
                  mapper_sms.ram[direccion and $1fff]:=valor;
                  case (direccion and $3) of
                    0:begin //RAM register
                        mapper_sms.slot2_ram:=(valor and 8)<>0;
                        //if (valor and 4)<>0  then halt(0);
                        //if (valor and $10)<>0  then halt(0);
                      end;
                    1:mapper_sms.slot0:=valor mod mapper_sms.max;
                    2:mapper_sms.slot1:=valor mod mapper_sms.max;
                    3:mapper_sms.slot2:=valor mod mapper_sms.max;
                  end;
               end;
end;
end;

function sms_inbyte(puerto:word):byte;
begin
  sms_inbyte:=$ff;
  case (puerto and $ff) of
    $40..$7f:if (puerto and 1)<>0 then sms_inbyte:=vdp_0.hpos
                else sms_inbyte:=vdp_0.linea_back and $ff;
    $80..$bf:if (puerto and $01)<>0 then sms_inbyte:=vdp_0.register_r
          else sms_inbyte:=vdp_0.vram_r;
    $dc:sms_inbyte:=joy1; //Joystick 1
    $dd:sms_inbyte:=joy2; //Joystick 2
  end;
end;

procedure config_io(valor:byte);
var
  haz_xor:byte;
begin
if (valor and 1)=0 then joy1:=(joy1 and $df) or ((valor and $10) shl 1) //TR port A
  else joy1:=joy1 or $20;
if (valor and 2)=0 then joy2:=(joy2 and $bf) or ((valor and $20) shl 1) //TH port A
  else joy2:=joy2 or $40;
if (valor and 4)=0 then joy2:=(joy2 and $f7) or ((valor and $40) shr 3) //TR port B
  else joy2:=joy2 or $8;
haz_xor:=byte(vdp_0.is_pal) shl 7;
if (valor and 8)=0 then joy2:=(joy2 and $7f) or ((valor and $80) xor haz_xor) //TH port B
  else joy2:=joy2 or $80;
if (((vdp_0.port_3f and 2)=0) and ((valor and 2)<>0)) then
  vdp_0.hpos:=vdp_0.hpos_temp;
if (((vdp_0.port_3f and 8)=0) and ((valor and 8)<>0)) then
  vdp_0.hpos:=vdp_0.hpos_temp;
vdp_0.port_3f:=valor;
end;

procedure sms_outbyte(valor:byte;puerto:word);
begin
  case (puerto and $ff) of
    0..$3f:if (puerto and $01)<>0 then config_io(valor)
              else begin
                   mapper_sms.bios_show:=(valor and 8)=0;
              end;
    $40..$7f:sn_76496_0.Write(valor);
    $80..$bf:if (puerto and $01)<>0 then vdp_0.register_w(valor)
          else vdp_0.vram_w(valor);
  end;
end;

procedure sms_interrupt(int:boolean);
begin
  if int then main_z80.pedir_irq:=ASSERT_LINE
     else main_z80.pedir_irq:=CLEAR_LINE;
end;

procedure sms_sound_update;
begin
  sn_76496_0.update;
end;

procedure sms_hlines(estados:word);
begin
  vdp_0.hlines(round(main_z80.contador));
end;

procedure sms_configurar;
begin
  SMSConfig.Show;
  while SMSConfig.Showing do application.ProcessMessages;
end;

function abrir_cartucho_sms(data:pbyte;long:dword):boolean;
var
  ptemp:pbyte;
  f:integer;
begin
//cargar roms
ptemp:=data;
if (long mod $4000)=512 then inc(ptemp,512);
mapper_sms.max:=long div $4000;
for f:=0 to (mapper_sms.max-1) do begin
      copymemory(@mapper_sms.rom[f,0],ptemp,$4000);
      inc(ptemp,$4000);
end;
abrir_cartucho_sms:=true;
end;

function abrir_sms:boolean;
var
  extension,nombre_file,RomFile:string;
  datos:pbyte;
  longitud,crc:integer;
  resultado:boolean;
  crc_val:dword;
begin
  if not(OpenRom(StSMS,RomFile)) then begin
    abrir_sms:=true;
    if mapper_sms.max=0 then mapper_sms.max:=1;
    EmuStatusTemp:=EsRuning;
    principal1.timer1.Enabled:=true;
    principal1.BitBtn3.Enabled:=false;
    principal1.BitBtn4.Enabled:=true;
    exit;
  end;
  abrir_sms:=false;
  extension:=extension_fichero(RomFile);
  if extension='ZIP' then begin
    if not(search_file_from_zip(RomFile,'*.sms',nombre_file,longitud,crc,true)) then
      if not(search_file_from_zip(RomFile,'*.sg',nombre_file,longitud,crc,true)) then exit;
    getmem(datos,longitud);
    if not(load_file_from_zip(RomFile,nombre_file,datos,longitud,crc,true)) then begin
      freemem(datos);
      exit;
    end;
  end else begin
    if ((extension<>'SMS') and (extension<>'SG')) then exit;
    if not(read_file_size(RomFile,longitud)) then exit;
    getmem(datos,longitud);
    if not(read_file(RomFile,datos,longitud)) then begin
      freemem(datos);
      exit;
    end;
    nombre_file:=extractfilename(RomFile);
  end;
  //Abrirlo
  extension:=extension_fichero(nombre_file);
  if extension='SG' then begin
    is_sg:=true;
    mapper_sms.bios_enabled:=false;
  end else is_sg:=false;
  //if extension='DSP' then resultado:=abrir_coleco_snapshot(datos,longitud)
  //  else
  resultado:=abrir_cartucho_sms(datos,longitud);
  if resultado then begin
    directory.sms:=ExtractFilePath(romfile);
    if is_sg then change_caption('SG - '+nombre_file)
      else change_caption('SMS - '+nombre_file);
    abrir_sms:=true;
    if mapper_sms.max=0 then mapper_sms.max:=1;
    reset_sms;
    crc_val:=calc_crc(datos,longitud);
    case crc_val of
      $91E93385,$81C3476B:mapper_sms.bios_show:=false;
    end;
    EmuStatusTemp:=EsRuning;
    principal1.timer1.Enabled:=true;
    principal1.BitBtn3.Enabled:=false;
    principal1.BitBtn4.Enabled:=true;
  end else MessageDlg('Error cargando snapshot/ROM.'+chr(10)+chr(13)+'Error loading the snapshot/ROM.', mtInformation,[mbOk], 0);
  Directory.sms:=ExtractFilePath(romfile);
  freemem(datos);
end;

procedure sms_grabar_snapshot;
begin
end;

end.
