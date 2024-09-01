unit nes;

interface

uses {$IFDEF WINDOWS}windows,{$ENDIF}
     main_engine,nes_ppu,controls_engine,sysutils,dialogs,misc_functions,
     sound_engine,file_engine,n2a03,m6502,nes_mappers;

type
    tnes_machine=record
            joy1,joy2,joy1_read,joy2_read:byte;
            sram_present,val_4016:boolean;
           end;

function iniciar_nes:boolean;

const
  NTSC_CLOCK=1789773;
  PAL_CLOCK=1662607;
  NTSC_REFRESH=60.0988;
  PAL_REFRESH=50.0070;
  NTSC_LINES=262;
  PAL_LINES=312;

var
  nes_0:tnes_machine;
  nv_ram_name:string;

implementation
uses principal,snapshot;

procedure eventos_nes;
var
  temp_r:preg_m6502;
begin
  if event.arcade then begin
    //Player 1
    if arcade_input.up[0] then nes_0.joy1_read:=(nes_0.joy1_read or $10) else nes_0.joy1_read:=(nes_0.joy1_read and $ef);
    if arcade_input.down[0] then nes_0.joy1_read:=(nes_0.joy1_read or $20) else nes_0.joy1_read:=(nes_0.joy1_read and $df);
    if arcade_input.left[0] then nes_0.joy1_read:=(nes_0.joy1_read or $40) else nes_0.joy1_read:=(nes_0.joy1_read and $bf);
    if arcade_input.right[0] then nes_0.joy1_read:=(nes_0.joy1_read or $80) else nes_0.joy1_read:=(nes_0.joy1_read and $7f);
    if arcade_input.but1[0] then nes_0.joy1_read:=(nes_0.joy1_read or $1) else nes_0.joy1_read:=(nes_0.joy1_read and $fe);
    if arcade_input.but0[0] then nes_0.joy1_read:=(nes_0.joy1_read or $2) else nes_0.joy1_read:=(nes_0.joy1_read and $fd);
    if arcade_input.start[0] then nes_0.joy1_read:=(nes_0.joy1_read or $8) else nes_0.joy1_read:=(nes_0.joy1_read and $f7);
    if arcade_input.coin[0] then nes_0.joy1_read:=(nes_0.joy1_read or $4) else nes_0.joy1_read:=(nes_0.joy1_read and $fb);
    //Player 2
    if arcade_input.up[1] then nes_0.joy2_read:=(nes_0.joy2_read or $10) else nes_0.joy2_read:=(nes_0.joy2_read and $ef);
    if arcade_input.down[1] then nes_0.joy2_read:=(nes_0.joy2_read or $20) else nes_0.joy2_read:=(nes_0.joy2_read and $df);
    if arcade_input.left[1] then nes_0.joy2_read:=(nes_0.joy2_read or $40) else nes_0.joy2_read:=(nes_0.joy2_read and $bf);
    if arcade_input.right[1] then nes_0.joy2_read:=(nes_0.joy2_read or $80) else nes_0.joy2_read:=(nes_0.joy2_read and $7f);
    if arcade_input.but1[1] then nes_0.joy2_read:=(nes_0.joy2_read or $1) else nes_0.joy2_read:=(nes_0.joy2_read and $fe);
    if arcade_input.but0[1] then nes_0.joy2_read:=(nes_0.joy2_read or $2) else nes_0.joy2_read:=(nes_0.joy2_read and $fd);
    if arcade_input.start[1] then nes_0.joy2_read:=(nes_0.joy2_read or $8) else nes_0.joy2_read:=(nes_0.joy2_read and $f7);
    if arcade_input.coin[1] then nes_0.joy2_read:=(nes_0.joy2_read or $4) else nes_0.joy2_read:=(nes_0.joy2_read and $fb);
  end;
  if event.keyboard then begin
    //Soft Reset
    if keyboard[KEYBOARD_f5] then begin
        temp_r:=n2a03_0.m6502.get_internal_r;
        temp_r.p.int:=true;
        temp_r.sp:=temp_r.sp-3;
        temp_r.pc:=memoria[$fffc]+(memoria[$fffd] shl 8);
    end;
  end;
end;

procedure nes_principal;
var
  frame:single;
  even:boolean;
begin
  init_controls(false,true,false,true);
  frame:=n2a03_0.m6502.tframes;
  even:=true;
  while EmuStatus=EsRunning do begin
    while ppu_nes_0.linea<NTSC_lines do begin
      case ppu_nes_0.linea of
          0..239:begin  //render
              //Dibujo
              //En la linea 261 carga los valores de los sprites de la linea 0 PERO NO EVALUA NADA
              //En la linea 0 desde 1 PPUT hasta 256 PPUT pinta todo, la linea y con los valores
              //cargados antes, los sprites. Segun esta pintando evalua el sprite_hit_0, apartir del 257
              //La comprobacion de los sprites termina en PPUT 256 aqui pongo el sprite_over_flow
              n2a03_0.m6502.run(128*PPU_PIXEL_TIMING);
              frame:=frame-n2a03_0.m6502.contador;
              ppu_nes_0.end_y_coarse;
              ppu_nes_0.draw_linea(ppu_nes_0.linea);
              //Consumo el resto...
              n2a03_0.m6502.run(frame);
              frame:=frame+n2a03_0.m6502.tframes-n2a03_0.m6502.contador;
            end;
          240:begin //Post-render
                n2a03_0.m6502.run(frame);
                frame:=frame+n2a03_0.m6502.tframes-n2a03_0.m6502.contador;
              end;
          241:begin //241
              //Pasar 1 PPUT
              n2a03_0.m6502.run(PPU_PIXEL_TIMING);
              frame:=frame-n2a03_0.m6502.contador;
              //Poner VBL
              ppu_nes_0.status:=ppu_nes_0.status or $80;
              if (ppu_nes_0.control1 and $80)<>0 then begin
                 n2a03_0.m6502.change_nmi(PULSE_LINE);
                 n2a03_0.m6502.after_ei:=true;
              end;
              n2a03_0.m6502.run(frame);
              frame:=frame+n2a03_0.m6502.tframes-n2a03_0.m6502.contador;
            end;
           242..260:begin //242..260
                n2a03_0.m6502.run(frame);
                frame:=frame+n2a03_0.m6502.tframes-n2a03_0.m6502.contador;
              end;
           261:begin  //Pre-render
                //Pasar 1 PPUT
                n2a03_0.m6502.run(PPU_PIXEL_TIMING);
                frame:=frame-n2a03_0.m6502.contador;
                //Limpiar VBL, sprite 0 hit y sprite overflow
                ppu_nes_0.status:=ppu_nes_0.status and $1f;
                ppu_nes_0.sprite_over_flow:=false;
                //Quitar un PPT
                if even then frame:=frame-PPU_PIXEL_TIMING;
                even:=not(even);
                n2a03_0.m6502.run(frame);
                frame:=frame+n2a03_0.m6502.tframes-n2a03_0.m6502.contador;
                if (ppu_nes_0.control2 and $18)<>0 then ppu_nes_0.address:=(ppu_nes_0.address and $41f) or (ppu_nes_0.address_temp and $7be0);
                if (@nes_mapper_0.calls.line_ack<>nil) then nes_mapper_0.calls.line_ack(false);
              end;
      end;
      ppu_nes_0.linea:=ppu_nes_0.linea+1;
    end;
    ppu_nes_0.linea:=0;
    eventos_nes;
    actualiza_trozo(0,0,256,240,2,0,0,256,240,PANT_TEMP);
    video_sync;
  end;
end;

function nes_getbyte(direccion:word):byte;
begin
  ppu_nes_0.open_bus:=direccion shr 8;
  case direccion of
    $0..$1fff:nes_getbyte:=memoria[direccion and $7ff];
    $2000..$3fff:case (direccion and 7) of
                  $2:begin
                        nes_getbyte:=ppu_nes_0.status;
                        // el bit de vblank se elimina cuando se lee el registro
                        ppu_nes_0.status:=ppu_nes_0.status and $60;
                        ppu_nes_0.dir_first:=true;
                        n2a03_0.m6502.change_nmi(CLEAR_LINE);
                    end;
                  $4:nes_getbyte:=ppu_nes_0.sprite_ram[ppu_nes_0.sprite_ram_pos];
                  $7:nes_getbyte:=ppu_nes_0.read;
                  else nes_getbyte:=ppu_nes_0.open_bus;
                end;
    $4000..$4013,$4015:nes_getbyte:=n2a03_0.read(direccion);
    $4016:begin
            nes_getbyte:=(ppu_nes_0.open_bus and $e0) or ((nes_0.joy1_read shr nes_0.joy1) and 1);
            nes_0.joy1:=nes_0.joy1+1;
          end;
    $4017:begin
            nes_getbyte:=(ppu_nes_0.open_bus and $e0) or ((nes_0.joy2_read shr nes_0.joy2) and 1);
            nes_0.joy2:=nes_0.joy2+1;
          end;
    $4020..$5fff:if @nes_mapper_0.calls.read_expansion<>nil then nes_getbyte:=nes_mapper_0.calls.read_expansion(direccion) //Expansion Area
                    else nes_getbyte:=ppu_nes_0.open_bus;
    $6000..$7fff:nes_getbyte:=nes_mapper_0.calls.read_prg_ram(direccion); //PRG-RAM
    $8000..$ffff:if @nes_mapper_0.calls.read_rom<>nil then nes_getbyte:=nes_mapper_0.calls.read_rom(direccion)
                    else nes_getbyte:=memoria[direccion]; // PRG-ROM
  end;
end;

procedure nes_putbyte(direccion:word;valor:byte);
begin
  case direccion of
    0..$1fff:memoria[direccion and $7ff]:=valor;
    $2000..$3fff:begin
        case (direccion and 7) of
            0:begin
                if (((ppu_nes_0.status and $80)<>0) and ((ppu_nes_0.control1 and $80)=0) and ((valor and $80)<>0)) then begin
                   n2a03_0.m6502.change_nmi(PULSE_LINE);
                   n2a03_0.m6502.after_ei:=true;
                end;
                ppu_nes_0.control1:=valor;
                ppu_nes_0.sprite_size:=8 shl ((valor shr 5) and 1);
                ppu_nes_0.pos_bg:=(valor shr 4) and 1;
                ppu_nes_0.pos_spt:=(valor shr 3) and 1;
                ppu_nes_0.address_temp:=(ppu_nes_0.address_temp and $73ff) or ((valor and $3) shl 10);
              end;
            1:begin
                ppu_nes_0.control2:=valor;
                //Salida de video en grises!  Noah's Ark lo usa!
                if (valor and 1)<>0 then ppu_nes_0.pal_mask:=$30
                  else ppu_nes_0.pal_mask:=$3f;
              end;
            3:ppu_nes_0.sprite_ram_pos:=valor;
            4:begin
                //Si esta renderizando escribe $ff!!
                if ppu_nes_0.linea<240 then valor:=$ff;
                ppu_nes_0.sprite_ram[ppu_nes_0.sprite_ram_pos]:=valor;
                ppu_nes_0.sprite_ram_pos:=ppu_nes_0.sprite_ram_pos+1;
              end;
            5:begin
                if ppu_nes_0.dir_first then begin
                  ppu_nes_0.address_temp:=ppu_nes_0.address_temp and $7fe0;
                  ppu_nes_0.address_temp:=ppu_nes_0.address_temp or ((valor and $f8) shr 3);
                  ppu_nes_0.tile_x_offset:=valor and $7;
                end else begin
                  ppu_nes_0.address_temp:=ppu_nes_0.address_temp and $c1f;
                  ppu_nes_0.address_temp:=ppu_nes_0.address_temp or ((valor and $f8) shl 2);
                  ppu_nes_0.address_temp:=ppu_nes_0.address_temp or ((valor and $7) shl 12);
                end;
                ppu_nes_0.dir_first:=not(ppu_nes_0.dir_first);
              end;
            6:begin
                if ppu_nes_0.dir_first then begin
                  ppu_nes_0.address_temp:=ppu_nes_0.address_temp and $ff;
                  ppu_nes_0.address_temp:=ppu_nes_0.address_temp or ((valor and $3f) shl 8);
                end else begin
                  ppu_nes_0.address_temp:=ppu_nes_0.address_temp and $7f00;
                  ppu_nes_0.address_temp:=ppu_nes_0.address_temp or valor;
                  ppu_nes_0.address:=ppu_nes_0.address_temp;
                  if (((ppu_nes_0.address and $1000)<>0) and (@nes_mapper_0.calls.line_ack<>nil)) then nes_mapper_0.calls.line_ack(true);
                end;
                ppu_nes_0.dir_first:=not(ppu_nes_0.dir_first);
              end;
            7:begin
                ppu_nes_0.write(valor);
                if (((ppu_nes_0.address and $1000)<>0) and (@nes_mapper_0.calls.line_ack<>nil)) then nes_mapper_0.calls.line_ack(true);
              end;
          end;
          end;
        $4000..$4013,$4015,$4017:n2a03_0.write(direccion,valor);
        $4014:ppu_nes_0.dma_spr(valor);
        $4016:begin
                if (((valor and 1)=0) and nes_0.val_4016) then begin
                  nes_0.joy1:=0;
                  nes_0.joy2:=0;
                end;
                nes_0.val_4016:=(valor and 1)<>0;
              end;
        $4020..$5fff:if @nes_mapper_0.calls.write_expansion<>nil then nes_mapper_0.calls.write_expansion(direccion,valor); //Expansion Area
        $6000..$7fff:nes_mapper_0.calls.write_prg_ram(direccion,valor); //PRG-RAM
        $8000..$ffff:if @nes_mapper_0.calls.write_rom<>nil then nes_mapper_0.calls.write_rom(direccion,valor); //PRG-ROM Area
  end;
end;

//Main
procedure nes_reset;
begin
  //IMPORTANTE: Primero reset al mapper para que coloque correctamente las ROMS!!!!!
  nes_mapper_0.reset;
  reset_audio;
  n2a03_0.reset;
  ppu_nes_0.reset;
  nes_0.joy1:=0;
  nes_0.joy2:=0;
  nes_0.joy1_read:=0;
  nes_0.joy2_read:=0;
  nes_0.val_4016:=false;
end;

function abrir_cartucho(datos:pbyte;longitud:integer):boolean;
type
  tnes_header=packed record
    magic:array[0..2] of ansichar;
    magic2,prg_rom,chr_rom,flags6,flags7,flags8,flags9,flags10:byte;
    unused1:array[0..4] of byte;
  end;
var
  nes_header:tnes_header;
  ptemp:pbyte;
  f,submapper:byte;
  mapper:word;
  crc32,rom_crc32:dword;
begin
  abrir_cartucho:=false;
  ptemp:=datos;
  copymemory(@nes_header,ptemp,sizeof(tnes_header));
  crc32:=calc_crc(ptemp,longitud);
  inc(ptemp,sizeof(tnes_header));
  if ((nes_header.magic<>'NES') and (nes_header.magic2<>$1a)) then exit;
  //Hay trainer, lo copio a la direccion $7000
  if (nes_header.flags6 and 4)<>0 then begin
    copymemory(@memoria[$7000],ptemp,$200);
    nes_mapper_0.prg_ram_enable:=true;
    inc(ptemp,$200);
  end;
  //Vacio las ROMs/RAM/CHR
  fillchar(nes_mapper_0.prg,sizeof(nes_mapper_0.prg),0);
  fillchar(nes_mapper_0.chr,sizeof(nes_mapper_0.chr),0);
  fillchar(nes_mapper_0.prg_ram,sizeof(nes_mapper_0.prg_ram),0);
  //Pos 4 Numero de paginas de ROM de 16k 1-255
  nes_mapper_0.last_prg:=nes_header.prg_rom;
  if nes_mapper_0.last_prg>32 then exit;
  for f:=0 to (nes_mapper_0.last_prg-1) do begin
    copymemory(@nes_mapper_0.prg[f,0],ptemp,$4000);
    inc(ptemp,$4000);
  end;
  copymemory(@memoria[$8000],@nes_mapper_0.prg[0,0],$4000);
  if nes_mapper_0.last_prg=1 then copymemory(@memoria[$c000],@nes_mapper_0.prg[0,0],$4000)
    else copymemory(@memoria[$c000],@nes_mapper_0.prg[1,0],$4000);
  //Pos 5 Numero de paginas de CHR de 8k 0-255
  nes_mapper_0.last_chr:=nes_header.chr_rom;
  if nes_mapper_0.last_chr>63 then exit;
  //chr ram es un caso diferente... tiene paginacion y dos paginas que se pueden intercambiar
  //Lo activo solo si el mapper lo necesita... Uso igual la memoria chr del MAPPER!!!
  if nes_mapper_0.last_chr=0 then begin
    ppu_nes_0.write_chr:=true;
    fillchar(nes_mapper_0.chr[0,0],$2000,0);
  end else begin
    ppu_nes_0.write_chr:=false;
    if nes_mapper_0.last_chr>64 then exit;
    for f:=0 to (nes_mapper_0.last_chr-1) do begin
      copymemory(@nes_mapper_0.chr[f,0],ptemp,$2000);
      inc(ptemp,$2000);
    end;
    copymemory(@ppu_nes_0.chr[0,0],@nes_mapper_0.chr[0,0],$1000);
    copymemory(@ppu_nes_0.chr[1,0],@nes_mapper_0.chr[0,$1000],$1000);
  end;
  //Pos 6 bit7-4 mapper low - bit3 4 screen - bit2 trainer - bit1 battery - bit0 mirror
  //Pos 7 bit7-4 mapper high
  //Si la pos 7 tiene la marca 'XXXX10XX'--> iNes 2.0
  if (nes_header.flags7 and $c)=8 then begin
    //MessageDlg('NES: Cabecera iNes 2.0',mtInformation,[mbOk], 0);
    //Falta por implementar el resto... http://wiki.nesdev.com/w/index.php/NES_2.0
    submapper:=(nes_header.flags8 and $f0) shr 4;
    mapper:=(nes_header.flags6 shr 4) or (nes_header.flags7 and $f0) or ((nes_header.flags8 and $f) shl 8);
  end else begin
    //Si las pos 12,13,14 y 15 <>0 --> Archaic
    if ((nes_header.unused1[1]<>0) and (nes_header.unused1[2]<>0) and (nes_header.unused1[3]<>0) and (nes_header.unused1[4]<>0)) then begin
      mapper:=nes_header.flags6 shr 4;
    end else begin //iNes
      mapper:=(nes_header.flags6 shr 4) or (nes_header.flags7 and $f0);
      if (nes_header.flags9 and 1)<>0 then MessageDlg('NES: PAL ROM Found', mtError,[mbOk], 0);
    end;
  end;
  nes_0.sram_present:=false;
  if (nes_header.flags6 and 2)<>0 then begin
    if read_file_size(nv_ram_name,longitud) then read_file(nv_ram_name,@memoria[$6000],longitud);
    nes_0.sram_present:=true;
  end;
  ppu_nes_0.mirror:=MIRROR_VERTICAL;
  if (nes_header.flags6 and 8)<>0 then ppu_nes_0.mirror:=MIRROR_FOUR_SCREEN
    else if (nes_header.flags6 and 1)=0 then ppu_nes_0.mirror:=MIRROR_HORIZONTAL;
  //Parches!!!
  case crc32 of
    $3fc29044,$2ed79b73,$76124d08:submapper:=1; //MMC6
    $50f66538:memoria[$fffd]:=$ca; //Urban chan e-games
    $7a5cc019:begin
                memoria[$fb14]:=$04;
                memoria[$fb15]:=$04;
              end;
    $42edbce2,$acc2b74a,$d8dfd3d1:submapper:=1;
    $51ce0655,$761e1fc9,$57d8330a,$e1539190:begin
                mapper:=206;
                ppu_nes_0.mirror:=MIRROR_FOUR_SCREEN;
              end;
    $d327f0a:mapper:=154;
    $4433ba0a:mapper:=87;
    $3c7b0120,$ad893bf7,$2fb7d5b9,$977f982,$d994d5ff,$f07d31b2,$e476313e,$103f0755,$63d71cda,$a8a1c2eb,$c8e5e815,$6fdf50d0,$154a31b6:mapper:=206;
    $d122ba8d,$62e7aec5,$6ee61da3:mapper:=152;
  end;
  rom_crc32:=calc_crc(@nes_mapper_0.chr[0,0],$2000);
  if ((mapper=243) and (rom_crc32<>$282dcb3a) and (rom_crc32<>$331802e2)) then mapper:=150;
  case rom_crc32 of
    $19c5c4aa:if mapper=25 then begin //VRC2-c
                submapper:=1;
                mapper:=23;
              end;
    $824324fa,$87c17609,$3b31f998:if mapper=25 then submapper:=3; //VRC4-b
    $f82b8e59:if mapper=21 then submapper:=1; //VRC4-c
    $ae17c652,$23f896a7:if mapper=25 then submapper:=4; //VRC4-d
    $a30927de,$7b790220,$c2cf279a,$88b512d6,$eb9fd289:if mapper=23 then begin //VRC4-e
                submapper:=2;
                mapper:=21;
              end;
    $bd493548:submapper:=1; //VRC7-b
    $7ff2dc2b,$6add6cd6,$1557191a,$8f03a735,$e8d170d8,$cc06cf3e:if mapper=33 then mapper:=48;
    $f47f0bca:if mapper=173 then mapper:=132;
    $1a145504,$19c33692:if mapper=79 then mapper:=173;
    $479fb8e6:mapper:=133;
  end;
  abrir_cartucho:=nes_mapper_0.set_mapper(mapper,submapper);
end;

procedure abrir_nes;
var
  extension,nombre_file,romfile:string;
  datos:pbyte;
  longitud:integer;
begin
  if not(openrom(romfile,SNES)) then exit;
  getmem(datos,$400000);
  if not(extract_data(romfile,datos,longitud,nombre_file,SNES)) then begin
    freemem(datos);
    exit;
  end;
  extension:=extension_fichero(nombre_file);
  //Guardar la SRAM
  if (nes_0.sram_present and (nv_ram_name<>'')) then write_file(nv_ram_name,@memoria[$6000],$2000);
  if @n2a03_0.additional_sound<>nil then n2a03_0.add_more_sound(nil);
  if extension='DSP' then snapshot_r(datos,longitud,SNES);
  if extension='NES' then begin
    if abrir_cartucho(datos,longitud) then begin
      if nes_0.sram_present then nv_ram_name:=Directory.Arcade_nvram+ChangeFileExt(nombre_file,'.nv');
      nes_reset;
    end;
  end;
  freemem(datos);
  change_caption(nombre_file);
  Directory.Nes:=ExtractFilePath(romfile);
end;

procedure grabar_nes;
var
  nombre:string;
begin
nombre:=snapshot_main_write(SNES);
Directory.nes:=ExtractFilePath(nombre);
end;

procedure nes_cerrar;
begin
  if (nes_0.sram_present and (nv_ram_name<>'')) then write_file(nv_ram_name,@memoria[$6000],$2000);
  nes_mapper_0.free;
  ppu_nes_0.free;
end;

function iniciar_nes:boolean;
begin
  principal1.BitBtn10.Glyph:=nil;
  principal1.imagelist2.GetBitmap(2,principal1.BitBtn10.Glyph);
  principal1.BitBtn10.OnClick:=principal1.fLoadCartucho;
  llamadas_maquina.bucle_general:=nes_principal;
  llamadas_maquina.close:=nes_cerrar;
  llamadas_maquina.reset:=nes_reset;
  llamadas_maquina.cartuchos:=abrir_nes;
  llamadas_maquina.grabar_snapshot:=grabar_nes;
  llamadas_maquina.fps_max:=NTSC_REFRESH;
  iniciar_audio(false);
  screen_init(1,512,1,true);
  screen_init(2,256,240);
  iniciar_video(256,240);
  //Main CPU
  n2a03_0:=cpu_n2a03.create(NTSC_clock,NTSC_lines);
  n2a03_0.m6502.change_ram_calls(nes_getbyte,nes_putbyte);
  n2a03_0.change_internals(nes_getbyte);
  ppu_nes_0:=nesppu_chip.create;
  nes_mapper_0:=tnes_mapper.create;
  if main_vars.console_init then abrir_nes;
  iniciar_nes:=true;
end;

end.
