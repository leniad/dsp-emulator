unit sms;
interface

uses nz80,{$IFDEF WINDOWS}windows,{$ENDIF}
     main_engine,controls_engine,sega_vdp,sn_76496,sysutils,rom_engine,
     misc_functions,sound_engine,forms;

function iniciar_sms:boolean;
procedure change_sms_model(model:byte;load_bios:boolean=true);

type
  tmapper_sms=record
      rom:array[0..63,0..$3fff] of byte;
      ram:array[0..$1fff] of byte;
      bios:array[0..$f,0..$3fff] of byte;
      rom_bank,bios_bank:array[0..3] of byte;
      ram_slot2:array[0..1,0..$3fff] of byte;
      slot2_bank:byte;
      slot2_ram:boolean;
      max,max_bios:byte;
  end;
  tmastersystem=record
      mapper:tmapper_sms;
      model,old_3f:byte;
      push_pause,cart_enabled,io_enabled,bios_enabled:boolean;
      io:array[0..6] of byte;
      keys:array[0..1] of byte;
  end;

var
  sms_0:tmastersystem;

const
  CLOCK_NTSC=3579545;
  CLOCK_PAL=3546895;
  FPS_NTSC=59.922743;
  FPS_PAL=49.701460;
  sms_bios:tipo_roms=(n:'mpr-12808.ic2';l:$2000;p:0;crc:$0072ed54);
  sms_bios_j:tipo_roms=(n:'mpr-11124.ic2';l:$2000;p:0;crc:$48d44a13);

implementation
uses principal,config_sms,snapshot;

procedure eventos_sms;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then sms_0.keys[0]:=(sms_0.keys[0] and $fe) else sms_0.keys[0]:=(sms_0.keys[0] or 1);
  if arcade_input.down[0] then sms_0.keys[0]:=(sms_0.keys[0] and $fd) else sms_0.keys[0]:=(sms_0.keys[0] or 2);
  if arcade_input.left[0] then sms_0.keys[0]:=(sms_0.keys[0] and $fb) else sms_0.keys[0]:=(sms_0.keys[0] or 4);
  if arcade_input.right[0] then sms_0.keys[0]:=(sms_0.keys[0] and $f7) else sms_0.keys[0]:=(sms_0.keys[0] or 8);
  if arcade_input.but0[0] then sms_0.keys[0]:=(sms_0.keys[0] and $ef) else sms_0.keys[0]:=(sms_0.keys[0] or $10);
  if arcade_input.but1[0] then sms_0.keys[0]:=(sms_0.keys[0] and $df) else sms_0.keys[0]:=(sms_0.keys[0] or $20);
  //P2
  if arcade_input.up[1] then sms_0.keys[0]:=(sms_0.keys[0] and $bf) else sms_0.keys[0]:=(sms_0.keys[0] or $40);
  if arcade_input.down[1] then sms_0.keys[0]:=(sms_0.keys[0] and $7f) else sms_0.keys[0]:=(sms_0.keys[0] or $80);
  if arcade_input.left[1] then sms_0.keys[1]:=(sms_0.keys[1] and $fe) else sms_0.keys[1]:=(sms_0.keys[1] or 1);
  if arcade_input.right[1] then sms_0.keys[1]:=(sms_0.keys[1] and $fd) else sms_0.keys[1]:=(sms_0.keys[1] or 2);
  if arcade_input.but0[1] then sms_0.keys[1]:=(sms_0.keys[1] and $fb) else sms_0.keys[1]:=(sms_0.keys[1] or 4);
  if arcade_input.but1[1] then sms_0.keys[1]:=(sms_0.keys[1] and $f7) else sms_0.keys[1]:=(sms_0.keys[1] or 8);
  if arcade_input.coin[0] then sms_0.push_pause:=true
    else begin
      if sms_0.push_pause then z80_0.change_nmi(PULSE_LINE);
      sms_0.push_pause:=false;
    end;
end;
end;

procedure sms_principal;
var
  frame:single;
  f:word;
begin
init_controls(false,false,false,true);
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
  0..$3fff:if sms_0.bios_enabled then begin
              if direccion<$400 then sms_getbyte:=sms_0.mapper.bios[0,direccion]
               else sms_getbyte:=sms_0.mapper.bios[sms_0.mapper.bios_bank[0],direccion]
           end else if sms_0.cart_enabled then begin
                      if direccion<$400 then sms_getbyte:=sms_0.mapper.rom[0,direccion]
                        else sms_getbyte:=sms_0.mapper.rom[sms_0.mapper.rom_bank[0],direccion];
                   end;
  $4000..$7fff:if sms_0.bios_enabled then sms_getbyte:=sms_0.mapper.bios[sms_0.mapper.bios_bank[1],direccion and $3fff]
                 else sms_getbyte:=sms_0.mapper.rom[sms_0.mapper.rom_bank[1],direccion and $3fff];
  $8000..$bfff:if sms_0.bios_enabled then sms_getbyte:=sms_0.mapper.bios[sms_0.mapper.bios_bank[2],direccion and $3fff]
                  else if sms_0.mapper.slot2_ram then sms_getbyte:=sms_0.mapper.ram_slot2[sms_0.mapper.slot2_bank,direccion and $3fff]
                       else sms_getbyte:=sms_0.mapper.rom[sms_0.mapper.rom_bank[2],direccion and $3fff];
  $c000..$ffff:sms_getbyte:=sms_0.mapper.ram[direccion and $1fff];
end;
end;

procedure sms_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:;
  $8000..$bfff:if sms_0.mapper.slot2_ram then sms_0.mapper.ram_slot2[sms_0.mapper.slot2_bank,direccion and $3fff]:=valor;
  $c000..$fffb:sms_0.mapper.ram[direccion and $1fff]:=valor;
  $fffc..$ffff:begin
                  sms_0.mapper.ram[direccion and $1fff]:=valor;
                  case (direccion and $3) of
                    0:begin
                          if sms_0.cart_enabled then begin
                            sms_0.mapper.slot2_ram:=(valor and 8)<>0;
                            sms_0.mapper.slot2_bank:=(valor and 4) shr 2;
                          end;
                          //if (valor and $3<>0) then MessageDlg('Escribe $fffc '+inttohex(valor,2), mtInformation,[mbOk], 0);
                      end;
                    1:begin
                        if sms_0.cart_enabled then sms_0.mapper.rom_bank[0]:=valor mod sms_0.mapper.max;
                        if sms_0.bios_enabled then sms_0.mapper.bios_bank[0]:=valor mod sms_0.mapper.max_bios;
                      end;
                    2:begin
                        if sms_0.cart_enabled then sms_0.mapper.rom_bank[1]:=valor mod sms_0.mapper.max;
                        if sms_0.bios_enabled then sms_0.mapper.bios_bank[1]:=valor mod sms_0.mapper.max_bios;
                      end;
                    3:begin
                        if sms_0.cart_enabled then sms_0.mapper.rom_bank[2]:=valor mod sms_0.mapper.max;
                        if sms_0.bios_enabled then sms_0.mapper.bios_bank[2]:=valor mod sms_0.mapper.max_bios;
                      end;
                  end;
               end;
end;
end;

function sms_getbyte_no_sega(direccion:word):byte;
begin
case direccion of
  0..$3fff:sms_getbyte_no_sega:=sms_0.mapper.rom[sms_0.mapper.rom_bank[0],direccion];
  $4000..$7fff:sms_getbyte_no_sega:=sms_0.mapper.rom[sms_0.mapper.rom_bank[1],direccion and $3fff];
  $8000..$bfff:sms_getbyte_no_sega:=sms_0.mapper.rom[sms_0.mapper.rom_bank[2],direccion and $3fff];
  $c000..$ffff:sms_getbyte_no_sega:=sms_0.mapper.ram[direccion and $1fff];
end;
end;

procedure sms_putbyte_4_pack(direccion:word;valor:byte);
begin
case direccion of
  $3ffe:begin //slot 0
			    sms_0.mapper.rom_bank[0]:=valor mod sms_0.mapper.max;
			    sms_0.mapper.rom_bank[2]:=((valor and $30)+sms_0.mapper.rom_bank[2]) mod sms_0.mapper.max;
        end;
  $7fff:sms_0.mapper.rom_bank[1]:=valor mod sms_0.mapper.max; //slot 1
  $bfff:sms_0.mapper.rom_bank[2]:=((sms_0.mapper.rom_bank[0] and $30)+valor) mod sms_0.mapper.max; //slot 2
  $c000..$ffff:sms_0.mapper.ram[direccion and $1fff]:=valor;
  //else MessageDlg('Escribe ROM '+inttohex(direccion,4), mtInformation,[mbOk], 0);
end;
end;

procedure sms_putbyte_korean(direccion:word;valor:byte);
begin
case direccion of
  $4000:sms_0.mapper.rom_bank[1]:=valor mod sms_0.mapper.max; //mapper slot 1
  $a000:sms_0.mapper.rom_bank[2]:=valor mod sms_0.mapper.max; //mapper slot 2
  $c000..$ffff:sms_0.mapper.ram[direccion and $1fff]:=valor;
  //else MessageDlg('Escribe ROM '+inttohex(direccion), mtInformation,[mbOk], 0);
end;
end;

procedure sms_putbyte_codemasters(direccion:word;valor:byte);
begin
case direccion of
  0:sms_0.mapper.rom_bank[0]:=valor mod sms_0.mapper.max; //mapper slot 0
  $4000:sms_0.mapper.rom_bank[1]:=valor mod sms_0.mapper.max; //mapper slot 1
  $8000:sms_0.mapper.rom_bank[2]:=valor mod sms_0.mapper.max; //mapper slot 2
  $c000..$ffff:sms_0.mapper.ram[direccion and $1fff]:=valor;
end;
end;

function sms_getbyte_cyborgz(direccion:word):byte;
begin
case direccion of
  0..$3fff:sms_getbyte_cyborgz:=sms_0.mapper.rom[0,direccion];
  $4000..$5fff:sms_getbyte_cyborgz:=sms_0.mapper.rom[sms_0.mapper.rom_bank[0] shr 1,(direccion and $1fff)+$2000*(sms_0.mapper.rom_bank[0] and 1)];
  $6000..$7fff:sms_getbyte_cyborgz:=sms_0.mapper.rom[sms_0.mapper.rom_bank[1] shr 1,(direccion and $1fff)+$2000*(sms_0.mapper.rom_bank[1] and 1)];
  $8000..$9fff:sms_getbyte_cyborgz:=sms_0.mapper.rom[sms_0.mapper.rom_bank[2] shr 1,(direccion and $1fff)+$2000*(sms_0.mapper.rom_bank[2] and 1)];
  $a000..$bfff:sms_getbyte_cyborgz:=sms_0.mapper.rom[sms_0.mapper.rom_bank[3] shr 1,(direccion and $1fff)+$2000*(sms_0.mapper.rom_bank[3] and 1)];
  $c000..$ffff:sms_getbyte_cyborgz:=sms_0.mapper.ram[direccion and $1fff];
end;
end;

procedure sms_putbyte_cyborgz(direccion:word;valor:byte);
begin
case direccion of
  0:sms_0.mapper.rom_bank[2]:=valor mod (sms_0.mapper.max shl 1) ; //mapper slot 4
  1:sms_0.mapper.rom_bank[3]:=valor mod (sms_0.mapper.max shl 1); //mapper slot 5
  2:sms_0.mapper.rom_bank[0]:=valor mod (sms_0.mapper.max shl 1); //mapper slot 2
  3:sms_0.mapper.rom_bank[1]:=valor mod (sms_0.mapper.max shl 1); //mapper slot 3
  $c000..$ffff:sms_0.mapper.ram[direccion and $1fff]:=valor;
end;
end;

function sms_getbyte_nemesis(direccion:word):byte;
begin
case direccion of
  0..$1fff:sms_getbyte_nemesis:=sms_0.mapper.rom[sms_0.mapper.max-1,direccion+$2000];
  $2000..$3fff:sms_getbyte_nemesis:=sms_0.mapper.rom[0,(direccion and $1fff)+$2000];
  $4000..$5fff:sms_getbyte_nemesis:=sms_0.mapper.rom[sms_0.mapper.rom_bank[0] shr 1,(direccion and $1fff)+$2000*(sms_0.mapper.rom_bank[0] and 1)];
  $6000..$7fff:sms_getbyte_nemesis:=sms_0.mapper.rom[sms_0.mapper.rom_bank[1] shr 1,(direccion and $1fff)+$2000*(sms_0.mapper.rom_bank[1] and 1)];
  $8000..$9fff:sms_getbyte_nemesis:=sms_0.mapper.rom[sms_0.mapper.rom_bank[2] shr 1,(direccion and $1fff)+$2000*(sms_0.mapper.rom_bank[2] and 1)];
  $a000..$bfff:sms_getbyte_nemesis:=sms_0.mapper.rom[sms_0.mapper.rom_bank[3] shr 1,(direccion and $1fff)+$2000*(sms_0.mapper.rom_bank[3] and 1)];
  $c000..$ffff:sms_getbyte_nemesis:=sms_0.mapper.ram[direccion and $1fff];
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
    $c0..$ff:if sms_0.io_enabled then begin
                if (puerto and 1)<>0 then sms_inbyte:=sms_0.keys[1]
                  else sms_inbyte:=sms_0.keys[0];
             end;{ else begin  //Descomentar esto para el YM2413
                if (puerto and $ff)=$f2 then sms_inbyte:=old_3e;
             end; }
  end;
end;

procedure config_io(valor:byte);
begin
//Bit 2 y 0 son para ver si la consola es internacional.
//Si es JAP, devuelve lo contrario de los bits 7 y 5 (no tiene TH)
if (valor and $5)=$5 then begin //bit 2 internacional
  sms_0.keys[1]:=sms_0.keys[1] and $7f;
  //Si es JAP, devuelve lo contrario (no tiene TH)
  if sms_0.model=1 then sms_0.keys[1]:=sms_0.keys[1] or (not(valor) and $80)
    else sms_0.keys[1]:=sms_0.keys[1] or (valor and $80);
end;
if (valor and $5)=$5 then begin //bit 1 internacional
  sms_0.keys[1]:=sms_0.keys[1] and $bf;
  if sms_0.model=1 then sms_0.keys[1]:=sms_0.keys[1] or ((not(valor) and $20) shl 1)
    else sms_0.keys[1]:=sms_0.keys[1] or ((valor and $20) shl 1)
end;
if (((sms_0.old_3f and 2)=0) and ((valor and 2)<>0)) then vdp_0.hpos:=vdp_0.hpos_temp;
if (((sms_0.old_3f and 8)=0) and ((valor and 8)<>0)) then vdp_0.hpos:=vdp_0.hpos_temp;
sms_0.old_3f:=valor;
end;

procedure sms_outbyte(puerto:word;valor:byte);
begin
  case (puerto and $ff) of
    0..$3f:if (puerto and $1)<>0 then config_io(valor)
              else begin
                      sms_0.bios_enabled:=(valor and 8)=0;
                      sms_0.io_enabled:=(valor and 4)=0;
                      sms_0.cart_enabled:=(valor and $e0)<>$e0;
                   end;
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

function read_memory(direccion:word):byte;
begin
  read_memory:=vdp_0.tms.mem[direccion];
end;

procedure write_memory(direccion:word;valor:byte);
begin
  vdp_0.tms.mem[direccion]:=valor;
end;

//Main
procedure reset_sms;
begin
 z80_0.reset;
 sn_76496_0.reset;
 vdp_0.reset;
 //ym2413_0.reset;
 reset_audio;
 sms_0.keys[0]:=$ff;
 sms_0.keys[1]:=$ff;
 sms_0.mapper.slot2_ram:=false;
 sms_0.bios_enabled:=true;
 sms_0.io_enabled:=true;
 sms_0.cart_enabled:=false;
 sms_0.mapper.rom_bank[0]:=0;
 if sms_0.mapper.max>1 then begin
  //Importante! Muchos mappers confian en esto...
  sms_0.mapper.rom_bank[1]:=1;
  sms_0.mapper.rom_bank[2]:=2;
 end else begin
  sms_0.mapper.rom_bank[1]:=0;
  sms_0.mapper.rom_bank[2]:=0;
 end;
 sms_0.mapper.rom_bank[3]:=0;
 sms_0.mapper.bios_bank[0]:=0;
 if sms_0.mapper.max_bios>1 then begin
   //Alex Kid confia en esto!
   sms_0.mapper.bios_bank[1]:=1;
   sms_0.mapper.bios_bank[2]:=2;
 end else begin
   sms_0.mapper.bios_bank[1]:=0;
   sms_0.mapper.bios_bank[2]:=0;
 end;
 sms_0.mapper.bios_bank[3]:=0;
 sms_0.mapper.slot2_bank:=0;
 sms_0.push_pause:=true;
 //Alibaba confia en este inicio de la RAM!!!
 fillchar(sms_0.mapper.ram[0],$2000,$f0);
end;

procedure change_sms_model(model:byte;load_bios:boolean=true);
begin
case model of
  0:begin
      if load_bios then roms_load(@sms_0.mapper.bios[0],sms_bios);
      llamadas_maquina.fps_max:=FPS_PAL;
      z80_0.clock:=CLOCK_PAL;
      z80_0.tframes:=(CLOCK_PAL/LINES_PAL)/FPS_PAL;
      change_video_clock(FPS_PAL);
      change_video_size(284,294);
      vdp_0.video_pal(vdp_0.video_mode);
      sound_engine_change_clock(CLOCK_PAL);
      sn_76496_0.change_clock(CLOCK_PAL);
      //ym2413_0.change_clock(CLOCK_PAL);
    end;
  1,2:begin
      if load_bios then begin
        if model=1 then roms_load(@sms_0.mapper.bios[0],sms_bios_j)
          else roms_load(@sms_0.mapper.bios[0],sms_bios);
      end;
      llamadas_maquina.fps_max:=FPS_NTSC;
      z80_0.clock:=CLOCK_NTSC;
      z80_0.tframes:=(CLOCK_NTSC/LINES_NTSC)/FPS_NTSC;
      change_video_clock(FPS_NTSC);
      change_video_size(284,243);
      vdp_0.video_ntsc(vdp_0.video_mode);
      sound_engine_change_clock(CLOCK_NTSC);
      sn_76496_0.change_clock(CLOCK_NTSC);
      //ym2413.change_clock(CLOCK_NTSC);
  end;
end;
end;

procedure sms_configurar;
begin
  SMSConfig.Show;
  while SMSConfig.Showing do application.ProcessMessages;
end;

function abrir_cartucho_sms(data:pbyte;long:dword):boolean;
var
  ptemp:pbyte;
  f:byte;
begin
fillchar(sms_0.mapper.rom[0],sizeof(sms_0.mapper.rom),0);
if long<$4000 then begin
  copymemory(@sms_0.mapper.rom[0,0],data,long);
  sms_0.mapper.max:=1;
end else begin
  ptemp:=data;
  if (long mod $4000)<>0 then inc(ptemp,long mod $4000);
  sms_0.mapper.max:=long div $4000;
  if (long div $4000)>64 then begin
    sms_0.mapper.max:=1;
    abrir_cartucho_sms:=false;
    exit;
  end else sms_0.mapper.max:=long div $4000;
  for f:=0 to (sms_0.mapper.max-1) do begin
    copymemory(@sms_0.mapper.rom[f,0],ptemp,$4000);
    inc(ptemp,$4000);
  end;
end;
abrir_cartucho_sms:=true;
reset_sms;
end;

function abrir_cartucho_sms_bios(data:pbyte;long:dword):boolean;
var
  ptemp:pbyte;
  f:byte;
begin
fillchar(sms_0.mapper.bios[0],sizeof(sms_0.mapper.bios),0);
ptemp:=data;
sms_0.mapper.max_bios:=long div $4000;
if sms_0.mapper.max_bios>16 then begin
  sms_0.mapper.max_bios:=1;
  abrir_cartucho_sms_bios:=false;
  exit;
end;
for f:=0 to (sms_0.mapper.max_bios-1) do begin
      copymemory(@sms_0.mapper.bios[f,0],ptemp,$4000);
      inc(ptemp,$4000);
end;
abrir_cartucho_sms_bios:=true;
reset_sms;
end;

procedure abrir_sms;
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
  z80_0.change_ram_calls(sms_getbyte,sms_putbyte);
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
      $0a77fa5e,$a05258f5,$9195c34c,$83f0eede,$5ac99fc4,$445525e2,$f89af3cc,$77efe84a,$6965ed9:begin //Cyborg-Z, Knightmare II, Penguin, Street Master
        z80_0.change_ram_calls(sms_getbyte_cyborgz,sms_putbyte_cyborgz);
      end;
      $e316c06d:begin //Nemesis
        z80_0.change_ram_calls(sms_getbyte_nemesis,sms_putbyte_cyborgz);
      end;
  end;
  if ((extension='ROM') or (extension='SMS')) then begin
    case crc_val of
      $81c3476b,$cf4a09ea,$9c5bad91,$8edf7ac6,$91e93385,$e79bb689:abrir_cartucho_sms_bios(datos,longitud);
      else abrir_cartucho_sms(datos,longitud);
    end;
  end;
  if extension='DSP' then snapshot_r(datos,longitud);
  freemem(datos);
  change_caption(nombre_file);
  Directory.sms:=ExtractFilePath(romfile);
end;

procedure sms_grabar_snapshot;
var
  nombre:string;
begin
nombre:=snapshot_main_write;
Directory.sms:=ExtractFilePath(nombre);
end;

function iniciar_sms:boolean;
begin
iniciar_sms:=false;
principal1.BitBtn10.Glyph:=nil;
principal1.imagelist2.GetBitmap(4,principal1.BitBtn10.Glyph);
principal1.BitBtn10.OnClick:=principal1.fLoadCartucho;
llamadas_maquina.bucle_general:=sms_principal;
llamadas_maquina.reset:=reset_sms;
llamadas_maquina.cartuchos:=abrir_sms;
llamadas_maquina.grabar_snapshot:=sms_grabar_snapshot;
llamadas_maquina.configurar:=sms_configurar;
if sms_0.model=0 then llamadas_maquina.fps_max:=FPS_PAL
  else llamadas_maquina.fps_max:=FPS_NTSC;
iniciar_audio(false);
screen_init(1,284,294);
if sms_0.model=0 then begin
  iniciar_video(284,294);
  z80_0:=cpu_z80.create(CLOCK_PAL,LINES_PAL);
end else begin
  iniciar_video(284,243);
  z80_0:=cpu_z80.create(CLOCK_NTSC,LINES_NTSC);
end;
//Main CPU
z80_0.change_ram_calls(sms_getbyte,sms_putbyte);
z80_0.change_io_calls(sms_inbyte,sms_outbyte);
z80_0.init_sound(sms_sound_update);
z80_0.change_misc_calls(sms_set_hpos);
//VDP
vdp_0:=vdp_chip.create(1,sms_interrupt,z80_0.numero_cpu,read_memory,write_memory);
vdp_0.set_gg(false);
//Bios
if sms_0.model=0 then begin
  if not(roms_load(@sms_0.mapper.bios[0,0],sms_bios)) then exit;
  vdp_0.video_pal(0);
  sn_76496_0:=sn76496_chip.Create(CLOCK_PAL);
  //ym2413_0:=ym2413_chip.create(YM3812_FM,CLOCK_PAL);
end else begin
  if sms_0.model=1 then begin
    if not(roms_load(@sms_0.mapper.bios[0,0],sms_bios_j)) then exit;
  end else begin
    if not(roms_load(@sms_0.mapper.bios[0,0],sms_bios)) then exit;
  end;
  vdp_0.video_ntsc(0);
  sn_76496_0:=sn76496_chip.Create(CLOCK_NTSC);
  //ym2413_0:=ym2413_chip.create(YM3812_FM,CLOCK_NTSC);
end;
//Importante!!!
fillchar(sms_0.mapper.bios[0],sizeof(sms_0.mapper.bios),0);
fillchar(sms_0.mapper.rom[0],sizeof(sms_0.mapper.rom),0);
sms_0.mapper.max:=1;
sms_0.mapper.max_bios:=1;
reset_sms;
if main_vars.console_init then abrir_sms;
iniciar_sms:=true;
end;

end.
