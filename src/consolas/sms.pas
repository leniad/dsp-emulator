unit sms;

interface
uses nz80,{$IFDEF WINDOWS}windows,{$ENDIF}
     main_engine,controls_engine,sega_vdp,sn_76496,sysutils,dialogs,
     rom_engine,misc_functions,sound_engine,file_engine,forms;

procedure cargar_sms;

type
  tmapper_sms=record
      rom:array[0..63,0..$3fff] of byte;
      ram:array[0..$1fff] of byte;
      bios:array[0..$3fff] of byte;
      ram_slot2:array[0..1,0..$3fff] of byte;
      slot0,slot1,slot2,slot3,slot2_bank:byte;
      slot2_ram:boolean;
      max:word;
  end;

var
  mapper_sms:^tmapper_sms;
  sms_model:byte;
const
  CLOCK_NTSC=3579545;
  CLOCK_PAL=3546895;
  FPS_NTSC=59.922743;
  FPS_PAL=49.701460;
  sms_bios:tipo_roms=(n:'mpr-12808.ic2';l:$2000;p:0;crc:$0072ed54);
  sms_bios_j:tipo_roms=(n:'mpr-11124.ic2';l:$2000;p:0;crc:$48d44a13);

implementation
uses principal,config_sms;

var
  cart_enabled,io_enabled,bios_enabled:boolean;
  old_3f:byte;

procedure eventos_sms;
begin
if event.keyboard then begin
  if (keyboard[KEYBOARD_F1]) then z80_0.change_nmi(PULSE_LINE);
end;
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  //P2
  if arcade_input.up[1] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.down[1] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or 8);
end;
end;

procedure sms_principal;
var
  frame:single;
  f:word;
begin
init_controls(false,false,true,false);
frame:=z80_0.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to (vdp_0.VIDEO_Y_TOTAL-1) do begin
      z80_0.run(frame);
      frame:=frame+z80_0.tframes-z80_0.contador;
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
  0..$3fff:if bios_enabled then sms_getbyte:=mapper_sms.bios[direccion and $1fff]
              else if cart_enabled then begin
                      if direccion<$400 then sms_getbyte:=mapper_sms.rom[0,direccion]
                        else sms_getbyte:=mapper_sms.rom[mapper_sms.slot0,direccion];
                   end else sms_getbyte:=$ff;
  $4000..$7fff:sms_getbyte:=mapper_sms.rom[mapper_sms.slot1,direccion and $3fff];
  $8000..$bfff:if mapper_sms.slot2_ram then sms_getbyte:=mapper_sms.ram_slot2[mapper_sms.slot2_bank,direccion and $3fff]
                  else sms_getbyte:=mapper_sms.rom[mapper_sms.slot2,direccion and $3fff];
  $c000..$ffff:sms_getbyte:=mapper_sms.ram[direccion and $1fff];
end;
end;

procedure sms_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:;
  $8000..$bfff:if mapper_sms.slot2_ram then mapper_sms.ram_slot2[mapper_sms.slot2_bank,direccion and $3fff]:=valor;
  $c000..$fffb:mapper_sms.ram[direccion and $1fff]:=valor;
  $fffc..$ffff:begin
                  mapper_sms.ram[direccion and $1fff]:=valor;
                  case (direccion and $3) of
                    0:begin
                        mapper_sms.slot2_ram:=(valor and 8)<>0;
                        mapper_sms.slot2_bank:=(valor and 4) shr 2;
                        //if (valor and $3<>0) then MessageDlg('Escribe $fffc '+inttohex(valor,2), mtInformation,[mbOk], 0);
                      end;
                    1:mapper_sms.slot0:=valor mod mapper_sms.max;
                    2:mapper_sms.slot1:=valor mod mapper_sms.max;
                    3:mapper_sms.slot2:=valor mod mapper_sms.max;
                  end;
               end;
end;
end;

function sms_getbyte_no_sega(direccion:word):byte;
begin
case direccion of
  0..$3fff:sms_getbyte_no_sega:=mapper_sms.rom[mapper_sms.slot0,direccion];
  $4000..$7fff:sms_getbyte_no_sega:=mapper_sms.rom[mapper_sms.slot1,direccion and $3fff];
  $8000..$bfff:sms_getbyte_no_sega:=mapper_sms.rom[mapper_sms.slot2,direccion and $3fff];
  $c000..$ffff:sms_getbyte_no_sega:=mapper_sms.ram[direccion and $1fff];
end;
end;

procedure sms_putbyte_4_pack(direccion:word;valor:byte);
begin
case direccion of
  $3ffe:begin //slot 0
			    mapper_sms.slot0:=valor mod mapper_sms.max;
			    mapper_sms.slot2:=((valor and $30)+mapper_sms.slot2) mod mapper_sms.max;
        end;
  $7fff:mapper_sms.slot1:=valor mod mapper_sms.max; //slot 1
  $bfff:mapper_sms.slot2:=((mapper_sms.slot0 and $30)+valor) mod mapper_sms.max; //slot 2
  $c000..$ffff:mapper_sms.ram[direccion and $1fff]:=valor;
  //else MessageDlg('Escribe ROM '+inttohex(direccion,4), mtInformation,[mbOk], 0);
end;
end;

procedure sms_putbyte_korean(direccion:word;valor:byte);
begin
case direccion of
  $4000:mapper_sms.slot1:=valor mod mapper_sms.max; //mapper slot 1
  $a000:mapper_sms.slot2:=valor mod mapper_sms.max; //mapper slot 2
  $c000..$ffff:mapper_sms.ram[direccion and $1fff]:=valor;
  //else MessageDlg('Escribe ROM '+inttohex(direccion), mtInformation,[mbOk], 0);
end;
end;

procedure sms_putbyte_codemasters(direccion:word;valor:byte);
begin
case direccion of
  0:mapper_sms.slot0:=valor mod mapper_sms.max; //mapper slot 0
  $4000:mapper_sms.slot1:=valor mod mapper_sms.max; //mapper slot 1
  $8000:mapper_sms.slot2:=valor mod mapper_sms.max; //mapper slot 2
  $c000..$ffff:mapper_sms.ram[direccion and $1fff]:=valor;
end;
end;

function sms_getbyte_cyborgz(direccion:word):byte;
begin
case direccion of
  0..$3fff:sms_getbyte_cyborgz:=mapper_sms.rom[0,direccion];
  $4000..$5fff:sms_getbyte_cyborgz:=mapper_sms.rom[mapper_sms.slot0 shr 1,(direccion and $1fff)+$2000*(mapper_sms.slot0 and 1)];
  $6000..$7fff:sms_getbyte_cyborgz:=mapper_sms.rom[mapper_sms.slot1 shr 1,(direccion and $1fff)+$2000*(mapper_sms.slot1 and 1)];
  $8000..$9fff:sms_getbyte_cyborgz:=mapper_sms.rom[mapper_sms.slot2 shr 1,(direccion and $1fff)+$2000*(mapper_sms.slot2 and 1)];
  $a000..$bfff:sms_getbyte_cyborgz:=mapper_sms.rom[mapper_sms.slot3 shr 1,(direccion and $1fff)+$2000*(mapper_sms.slot3 and 1)];
  $c000..$ffff:sms_getbyte_cyborgz:=mapper_sms.ram[direccion and $1fff];
end;
end;

procedure sms_putbyte_cyborgz(direccion:word;valor:byte);
begin
case direccion of
  0:mapper_sms.slot2:=valor mod (mapper_sms.max shl 1) ; //mapper slot 4
  1:mapper_sms.slot3:=valor mod (mapper_sms.max shl 1); //mapper slot 5
  2:mapper_sms.slot0:=valor mod (mapper_sms.max shl 1); //mapper slot 2
  3:mapper_sms.slot1:=valor mod (mapper_sms.max shl 1); //mapper slot 3
  $c000..$ffff:mapper_sms.ram[direccion and $1fff]:=valor;
end;
end;

function sms_getbyte_nemesis(direccion:word):byte;
begin
case direccion of
  0..$1fff:sms_getbyte_nemesis:=mapper_sms.rom[mapper_sms.max-1,direccion+$2000];
  $2000..$3fff:sms_getbyte_nemesis:=mapper_sms.rom[0,(direccion and $1fff)+$2000];
  $4000..$5fff:sms_getbyte_nemesis:=mapper_sms.rom[mapper_sms.slot0 shr 1,(direccion and $1fff)+$2000*(mapper_sms.slot0 and 1)];
  $6000..$7fff:sms_getbyte_nemesis:=mapper_sms.rom[mapper_sms.slot1 shr 1,(direccion and $1fff)+$2000*(mapper_sms.slot1 and 1)];
  $8000..$9fff:sms_getbyte_nemesis:=mapper_sms.rom[mapper_sms.slot2 shr 1,(direccion and $1fff)+$2000*(mapper_sms.slot2 and 1)];
  $a000..$bfff:sms_getbyte_nemesis:=mapper_sms.rom[mapper_sms.slot3 shr 1,(direccion and $1fff)+$2000*(mapper_sms.slot3 and 1)];
  $c000..$ffff:sms_getbyte_nemesis:=mapper_sms.ram[direccion and $1fff];
end;
end;

function sms_inbyte(puerto:word):byte;
begin
  sms_inbyte:=$ff;
  case (puerto and $ff) of
    0..$3f:; //return the last byte of the instruction
    $40..$7f:if (puerto and 1)<>0 then sms_inbyte:=vdp_0.hpos
                else sms_inbyte:=vdp_0.linea_back;
    $80..$bf:if (puerto and $01)<>0 then sms_inbyte:=vdp_0.register_r
          else sms_inbyte:=vdp_0.vram_r;
    $c0..$ff:if io_enabled then begin
                if (puerto and 1)<>0 then sms_inbyte:=marcade.in1
                  else sms_inbyte:=marcade.in0;
             end;{ else begin  //Descomentar esto para el YM2413
                if (puerto and $ff)=$f2 then sms_inbyte:=old_3e;
             end; }
  end;
end;

procedure config_io(valor:byte);
begin
if (((valor and $80)<>0) and ((valor and $f)=$5)) then begin //bit 2 internacional
  marcade.in1:=marcade.in1 and $7f;
  if sms_model=1 then marcade.in1:=marcade.in1 or (not(valor) and $80);
end;
if (((valor and $20)<>0) and ((valor and $f)=$5)) then begin //bit 1 internacional
  marcade.in1:=marcade.in1 and $bf;
  if sms_model=1 then marcade.in1:=marcade.in1 or ((not(valor) and $20) shl 1);
end;
if (((old_3f and 2)=0) and ((valor and 2)<>0)) then vdp_0.hpos:=vdp_0.hpos_temp;
if (((old_3f and 8)=0) and ((valor and 8)<>0)) then vdp_0.hpos:=vdp_0.hpos_temp;
old_3f:=valor;
end;

procedure memory_control(valor:byte);
begin
  bios_enabled:=(valor and 8)=0;
  io_enabled:=(valor and 4)=0;
  cart_enabled:=(valor and $e0)<>$e0;
end;

procedure sms_outbyte(puerto:word;valor:byte);
begin
  case (puerto and $ff) of
    0..$3f:if (puerto and $1)<>0 then config_io(valor)
              else memory_control(valor);
    $40..$7f:sn_76496_0.Write(valor);
    $80..$bf:if (puerto and $1)<>0 then vdp_0.register_w(valor)
                else vdp_0.vram_w(valor);
    $c0..$ff:;{case (puerto and $ff) of //Descomentar esto para el YM2413
                $f0:ym2413_0.Control(valor);
                $f1:ym2413_0.Write(valor);
                $f2:old_3e:=valor and 3;
             end; }
  end;
end;

procedure sms_interrupt(int:boolean);
begin
  if int then z80_0.change_irq(ASSERT_LINE)
     else z80_0.change_irq(CLEAR_LINE);
end;

procedure sms_sound_update;
begin
  sn_76496_0.update;
  //ym2413_0.update;
end;

procedure sms_set_hpos(estados:word);
begin
  vdp_0.set_hpos(z80_0.contador);
end;

//Main
procedure sms_configurar;
begin
  SMSConfig.Show;
  while SMSConfig.Showing do application.ProcessMessages;
end;

function abrir_cartucho_sms(data:pbyte;long:dword):boolean;
var
  ptemp:pbyte;
  long_temp:dword;
begin
//cargar roms
ptemp:=data;
mapper_sms.max:=0;
if (long mod $4000)=512 then begin
  inc(ptemp,512);
  long_temp:=long-512;
end else long_temp:=long;
while long_temp>0 do begin
  if long_temp<$4000 then begin
    copymemory(@mapper_sms.rom[mapper_sms.max,0],ptemp,long_temp);
    long_temp:=0;
  end else begin
    copymemory(@mapper_sms.rom[mapper_sms.max,0],ptemp,$4000);
    inc(ptemp,$4000);
    long_temp:=long_temp-$4000;
  end;
  mapper_sms.max:=mapper_sms.max+1;
end;
abrir_cartucho_sms:=true;
end;

function abrir_cartucho_sms_bios(data:pbyte;long:dword):boolean;
var
  ptemp:pbyte;
  f:integer;
begin
//cargar roms
ptemp:=data;
if (long mod $4000)=512 then inc(ptemp,512);
mapper_sms.max:=long div $4000;
copymemory(@mapper_sms.bios[0],ptemp,$4000);
for f:=0 to (mapper_sms.max-1) do begin
      copymemory(@mapper_sms.rom[f,0],ptemp,$4000);
      inc(ptemp,$4000);
end;
if mapper_sms.max<=0 then mapper_sms.max:=1;
abrir_cartucho_sms_bios:=true;
end;

procedure reset_sms;
var
  z80_r:npreg_z80;
begin
 z80_0.reset;
 sn_76496_0.reset;
 vdp_0.reset;
 //ym2413_0.reset;
 reset_audio;
 z80_r:=z80_0.get_internal_r;
 z80_r.sp:=$dfeb;
 z80_r.bc.w:=$ff3c;
 z80_r.bc2.w:=$300;
 z80_r.de2.w:=$c73c;
 z80_r.hl.w:=$2;
 z80_r.hl2.w:=$c739;
 z80_r.a:=$14;
 mapper_sms.slot2_ram:=false;
 bios_enabled:=true;
 io_enabled:=true;
 cart_enabled:=true;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 mapper_sms.slot0:=0;
 mapper_sms.slot1:=1 mod mapper_sms.max;
 mapper_sms.slot2:=2 mod mapper_sms.max;
 mapper_sms.slot3:=0;
 mapper_sms.slot2_bank:=0;
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
    EmuStatusTemp:=EsRuning;
    principal1.timer1.Enabled:=true;
    exit;
  end;
  abrir_sms:=false;
  extension:=extension_fichero(RomFile);
  if extension='ZIP' then begin
    if not(search_file_from_zip(RomFile,'*.sms',nombre_file,longitud,crc,true)) then
      if not(search_file_from_zip(RomFile,'*.rom',nombre_file,longitud,crc,true)) then
    getmem(datos,longitud);
    if not(load_file_from_zip(RomFile,nombre_file,datos,longitud,crc,true)) then begin
      freemem(datos);
      exit;
    end;
  end else begin
    if ((extension<>'SMS') and (extension<>'ROM')) then exit;
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
  z80_0.change_ram_calls(sms_getbyte,sms_putbyte);
  if (extension='SMS') then resultado:=abrir_cartucho_sms(datos,longitud)
     else if extension='ROM' then resultado:=abrir_cartucho_sms_bios(datos,longitud);
  if resultado then begin
    llamadas_maquina.open_file:=nombre_file;
    abrir_sms:=true;
    crc_val:=calc_crc(datos,longitud);
    case crc_val of
      $58fa27c6,$a577ce46,$29822980,$ea5c3a6f,$8813514b,$b9664ae1:begin //Codemasters
          z80_0.change_ram_calls(sms_getbyte_no_sega,sms_putbyte_codemasters);
      end;
      $565c799f,$dbbf4dd1,$18fb98a3,$97d03541,$89b79e77,$60d6a7c:begin //Korean $8bf3de3
          z80_0.change_ram_calls(sms_getbyte_no_sega,sms_putbyte_korean);
      end;
      $a67f2a5c:begin //4pack
          z80_0.change_ram_calls(sms_getbyte_no_sega,sms_putbyte_4_pack);
      end;
      $a05258f5,$9195c34c,$83f0eede,$5ac99fc4,$445525e2,$f89af3cc,$77efe84a:begin //Cyborg-Z, Knightmare II, Penguin, Street Master
        z80_0.change_ram_calls(sms_getbyte_cyborgz,sms_putbyte_cyborgz);
      end;
      $e316c06d:begin //Nemesis
        z80_0.change_ram_calls(sms_getbyte_nemesis,sms_putbyte_cyborgz);
      end;
    end;
    reset_sms;
    EmuStatusTemp:=EsRuning;
    principal1.timer1.Enabled:=true;
  end else begin
    MessageDlg('Error cargando snapshot/ROM.'+chr(10)+chr(13)+'Error loading the snapshot/ROM.', mtInformation,[mbOk], 0);
    llamadas_maquina.open_file:='';
  end;
  change_caption;
  Directory.sms:=ExtractFilePath(romfile);
  freemem(datos);
end;

function read_memory(direccion:word):byte;
begin
  read_memory:=vdp_0.tms.mem[direccion];
end;

procedure write_memory(direccion:word;valor:byte);
begin
  vdp_0.tms.mem[direccion]:=valor;
end;

procedure sms_grabar_snapshot;
begin
end;

function iniciar_sms:boolean;
var
  dir:string;
  load_rom_res:boolean;
begin
iniciar_sms:=false;
//Mapper
getmem(mapper_sms,sizeof(tmapper_sms));
dir:=directory.arcade_list_roms[find_rom_multiple_dirs('sms.zip')];
if sms_model=0 then begin
  llamadas_maquina.fps_max:=FPS_PAL;
  valor_sync:=(1/FPS_PAL)*cont_micro;
  iniciar_audio(false);
  screen_init(1,284,294);
  iniciar_video(284,294);
  z80_0:=cpu_z80.create(CLOCK_PAL,LINES_PAL);
  load_rom_res:=carga_rom_zip(dir+'sms.zip',sms_bios.n,@mapper_sms.bios[0],sms_bios.l,sms_bios.crc,false);
  //VDP
  vdp_0:=vdp_chip.create(1,sms_interrupt,z80_0.numero_cpu,read_memory,write_memory);
  vdp_0.video_pal(0);
  sn_76496_0:=sn76496_chip.Create(CLOCK_PAL);
  //ym2413_0:=ym2413_chip.create(YM3812_FM,CLOCK_PAL);
end else begin
  llamadas_maquina.fps_max:=FPS_NTSC;
  valor_sync:=(1/FPS_NTSC)*cont_micro;
  iniciar_audio(false);
  screen_init(1,284,243);
  iniciar_video(284,243);
  z80_0:=cpu_z80.create(CLOCK_NTSC,LINES_NTSC);
  if sms_model=1 then load_rom_res:=carga_rom_zip(dir+'sms.zip',sms_bios_j.n,@mapper_sms.bios[0],sms_bios_j.l,sms_bios_j.crc,false)
    else load_rom_res:=carga_rom_zip(dir+'sms.zip',sms_bios.n,@mapper_sms.bios[0],sms_bios.l,sms_bios.crc,false);
  //VDP
  vdp_0:=vdp_chip.create(1,sms_interrupt,z80_0.numero_cpu,read_memory,write_memory);
  vdp_0.video_ntsc(0);
  sn_76496_0:=sn76496_chip.Create(CLOCK_NTSC);
  //ym2413_0:=ym2413_chip.create(YM3812_FM,CLOCK_NTSC);
end;
vdp_0.set_gg(false);
if not(load_rom_res) then begin
   MessageDlg('Error: BIOS ROM no encontrada.'+chr(10)+chr(13)+'Error: BIOS ROM not found.', mtInformation,[mbOk], 0);
   exit;
end;
//Main CPU
z80_0.change_ram_calls(sms_getbyte,sms_putbyte);
z80_0.change_io_calls(sms_inbyte,sms_outbyte);
z80_0.init_sound(sms_sound_update);
z80_0.change_misc_calls(sms_set_hpos,nil);
//final
mapper_sms.max:=1;
abrir_sms;
iniciar_sms:=true;
end;

procedure cerrar_sms;
begin
if mapper_sms<>nil then freemem(mapper_sms);
mapper_sms:=nil;
end;

procedure cargar_sms;
begin
principal1.BitBtn10.Glyph:=nil;
principal1.imagelist2.GetBitmap(4,principal1.BitBtn10.Glyph);
principal1.BitBtn10.OnClick:=principal1.fLoadCartucho;
llamadas_maquina.iniciar:=iniciar_sms;
llamadas_maquina.bucle_general:=sms_principal;
llamadas_maquina.close:=cerrar_sms;
llamadas_maquina.reset:=reset_sms;
llamadas_maquina.cartuchos:=abrir_sms;
llamadas_maquina.grabar_snapshot:=sms_grabar_snapshot;
llamadas_maquina.configurar:=sms_configurar;
end;

end.
