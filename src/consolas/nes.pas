unit nes;

interface

uses sdl2,{$IFDEF WINDOWS}windows,{$ENDIF}
     m6502,main_engine,nes_ppu,controls_engine,sysutils,dialogs,misc_functions,
     sound_engine,file_engine,n2a03_sound,nes_mappers;

Type
  TPalType=array [0..63,1..3] of byte;
  tllamadas_nes = record
           read_expansion:function(direccion:word):byte;
           write_expansion:procedure(direccion:word;valor:byte);
           write_extra_ram:procedure(direccion:word;valor:byte);
           write_rom:procedure(direccion:word;valor:byte);
           line_counter:procedure;
           end;

const
  NTSC_clock=1789773;
  PAL_clock=1773447;
  NTSC_refresh=60.0988;
  PAL_refresh=50.0070;
  NTSC_lines=262-1;
  PAL_lines=312-1;

var
  joy1,joy2,joy1_read,joy2_read,open_bus:byte;
  llamadas_nes:tllamadas_nes;
  sram_present:boolean=false;
  cart_name:string;
  cartucho_cargado:boolean;
  sram_enable:boolean;

procedure Cargar_NES;
function iniciar_nes:boolean;
procedure nes_principal;
procedure nes_cerrar;
procedure nes_reset;
function abrir_nes:boolean;
//Main CPU
function nes_getbyte(direccion:word):byte;
procedure nes_putbyte(direccion:word;valor:byte);
//Sound
procedure nes_sound_update;
procedure nes_irq(status:byte);

implementation
uses principal;

procedure Cargar_NES;
begin
  principal1.Panel2.Visible:=true;
  principal1.BitBtn9.Visible:=false;
  principal1.BitBtn10.Glyph:=nil;
  principal1.BitBtn10.Enabled:=true;
  principal1.imagelist2.GetBitmap(2,principal1.BitBtn10.Glyph);
  principal1.BitBtn10.Visible:=true;
  principal1.BitBtn10.OnClick:=principal1.fLoadCartucho;
  principal1.BitBtn11.Visible:=true;
  principal1.BitBtn12.Visible:=false;
  principal1.BitBtn14.Visible:=false;
  llamadas_maquina.iniciar:=iniciar_nes;
  llamadas_maquina.bucle_general:=nes_principal;
  llamadas_maquina.cerrar:=nes_cerrar;
  llamadas_maquina.reset:=nes_reset;
  llamadas_maquina.cartuchos:=abrir_nes;
  llamadas_maquina.fps_max:=NTSC_refresh;
  cartucho_cargado:=false;
end;

function iniciar_nes:boolean;
begin
  iniciar_audio(false);
  screen_init(1,512,1,true);
  screen_init(2,256,240);
  iniciar_video(256,240);
  main_m6502:=cpu_m6502.create(NTSC_clock,NTSC_lines+1,TCPU_NES);
  main_m6502.change_ram_calls(nes_getbyte,nes_putbyte);
  main_m6502.init_sound(nes_sound_update);
  init_n2a03_sound(0,nes_getbyte,nes_irq);
  nes_init_palette;
  iniciar_nes:=abrir_nes;
end;

procedure nes_reset;
begin
  fillchar(memoria[0],$800,0);
  fillchar(memoria[$6000],$2000,0);
  reset_audio;
  main_m6502.reset;
  reset_n2a03_sound(0);
  //main_6502.sp:=$fd;
  reset_ppu;
  joy1:=0;
  joy2:=0;
  mapper_nes.reg[0]:=0;
  mapper_nes.reg[1]:=0;
  mapper_nes.reg[2]:=0;
  mapper_nes.reg[3]:=0;
end;

procedure nes_cerrar;
begin
  if sram_present then write_file(cart_name,@memoria[$6000],$2000);
  main_m6502.free;
  close_n2a03_sound(0);
  close_audio;
  close_video;
end;

procedure eventos_nes;
var
  temp_r:preg_m6502;
begin
  if event.arcade then begin
    //Player 1
    if arcade_input.up[0] then joy1_read:=(joy1_read or $10) else joy1_read:=(joy1_read and $EF);
    if arcade_input.down[0] then joy1_read:=(joy1_read or $20) else joy1_read:=(joy1_read and $DF);
    if arcade_input.left[0] then joy1_read:=(joy1_read or $40) else joy1_read:=(joy1_read and $BF);
    if arcade_input.right[0] then joy1_read:=(joy1_read or $80) else joy1_read:=(joy1_read and $7F);
    if arcade_input.but1[0] then joy1_read:=(joy1_read or $1) else joy1_read:=(joy1_read and $FE);
    if arcade_input.but0[0] then joy1_read:=(joy1_read or $2) else joy1_read:=(joy1_read and $FD);
    if arcade_input.start[0] then joy1_read:=(joy1_read or $8) else joy1_read:=(joy1_read and $F7);
    if arcade_input.coin[0] then joy1_read:=(joy1_read or $4) else joy1_read:=(joy1_read and $FB);
    //Player 2
    if arcade_input.up[1] then joy2_read:=(joy2_read or $10) else joy2_read:=(joy2_read and $EF);
    if arcade_input.down[1] then joy2_read:=(joy2_read or $20) else joy2_read:=(joy2_read and $DF);
    if arcade_input.left[1] then joy2_read:=(joy2_read or $40) else joy2_read:=(joy2_read and $BF);
    if arcade_input.right[1] then joy2_read:=(joy2_read or $80) else joy2_read:=(joy2_read and $7F);
    if arcade_input.but1[1] then joy2_read:=(joy2_read or $1) else joy2_read:=(joy2_read and $FE);
    if arcade_input.but0[1] then joy2_read:=(joy2_read or $2) else joy2_read:=(joy2_read and $FD);
    if arcade_input.start[1] then joy2_read:=(joy2_read or $8) else joy2_read:=(joy2_read and $F7);
    if arcade_input.coin[1] then joy2_read:=(joy2_read or $4) else joy2_read:=(joy2_read and $FB);
  end;
  if event.keyboard then begin
    //Soft Reset
    if keyboard[SDL_SCANCODE_f5] then begin
      //Softreset
        temp_r:=main_m6502.get_internal_r;
        temp_r.p.int:=true;
        temp_r.sp:=temp_r.sp-3;
        temp_r.pc:=memoria[$FFFC]+(memoria[$FFFD] shl 8);
    end;
  end;
end;

procedure nes_principal;
var
  frame:single;
  nes_linea:word;
begin
  if not(cartucho_cargado) then exit;
  init_controls(false,true,false,true);
  frame:=main_m6502.tframes;
  while EmuStatus=EsRuning do begin
    for nes_linea:=0 to NTSC_lines do begin
      case nes_linea of
        0..239:begin//0..239 - 21..260
              ppu_linea(nes_linea);
              if sprite0_hit then begin
                main_m6502.run(sprite0_hit_pos);
                frame:=frame-main_m6502.contador;
                ppu_status:=ppu_status or $40;
                main_m6502.run(85-sprite0_hit_pos);
                frame:=frame-main_m6502.contador;
              end else begin
                main_m6502.run(85);
                frame:=frame-main_m6502.contador;
              end;
              if (ppu_control2 and $8)<>0 then begin
                ppu_address:=(ppu_address and $FBE0) or (ppu_address_temp and $41F);
                ppu_end_linea;
              end;
              main_m6502.run(frame);
              frame:=frame+main_M6502.tframes-main_M6502.contador;
            end;
          240,242..260:begin //240,242..260 - 261,1..19
                main_m6502.run(frame);
                frame:=frame+main_m6502.tframes-main_m6502.contador;
              end;
          241:begin //241 - 0
              ppu_status:=ppu_status or $80;
              main_m6502.run(1);
              frame:=frame-main_M6502.contador;
              if (ppu_control1 and $80)=$80 then main_m6502.pedir_nmi:=PULSE_LINE;
              main_m6502.run(frame);
              frame:=frame+main_m6502.tframes-main_m6502.contador;
            end;
          261:begin //261 - 20
              main_m6502.run(1);
              frame:=frame-main_m6502.contador;
              ppu_status:=ppu_status and $1F;
              sprite0_hit:=false;
              main_m6502.run(frame);
              frame:=frame+main_m6502.tframes-main_m6502.contador;
              if (ppu_control2 and $8)<>0 then ppu_address:=ppu_address_temp;
           end;
      end;
    end;
    //open_bus:=0;
    eventos_nes;
    actualiza_trozo_simple(0,0,256,240,2);
    video_sync;
  end;
end;

function nes_getbyte(direccion:word):byte;
begin
  case direccion of
    $0..$1FFF:nes_getbyte:=memoria[direccion and $7FF];
    $2000..$3fff:begin
                case (direccion and 7) of
                  $2:begin
                        nes_getbyte:=ppu_status;
                        // el bit de vblank se elimina cuando se lee el registro
                        ppu_status:=ppu_status and $7F;
                        ppu_dir_first:=true;
                    end;
                  $4:nes_getbyte:=sprite_ram[sprite_ram_pos];
                  $7:begin
                        open_bus:=ppu_read;
                        nes_getbyte:=open_bus;
                     end;
                  else begin
                          nes_getbyte:=open_bus;
                          open_bus:=direccion shr 8;
                       end;
                end;
              end;
    $4000..$4013,$4015:nes_getbyte:=n2a03_read(0,direccion);
    $4016:begin
            nes_getbyte:=(joy1_read shr joy1) and 1;
            joy1:=(joy1+1) and $7;
          end;
    $4017:begin
            nes_getbyte:=(joy2_read shr joy2) and 1;
            joy2:=(joy2+1) and $7;
          end;
    $4018..$5fff:if @llamadas_nes.read_expansion<>nil then nes_getbyte:=llamadas_nes.read_expansion(direccion) //Expansion Area
                    else nes_getbyte:=direccion shr 8;
    $6000..$7fff:if sram_enable then nes_getbyte:=memoria[direccion]; //SRAM Area
    $8000..$ffff:nes_getbyte:=memoria[direccion]; // PRG-ROM Area
  end;
end;

procedure nes_putbyte(direccion:word;valor:byte);
begin
  case direccion of
    0..$1FFF:memoria[direccion and $7FF]:=valor;
    $2000..$3FFF:begin
        open_bus:=valor;
        case (direccion and 7) of
            0:begin
                ppu_control1:=valor;
                pos_bg:=(valor shr 4) and 1;
                pos_spt:=(valor shr 3) and 1;
                ppu_address_temp:=(ppu_address_temp and $F3FF) or ((valor And $3) shl 10);
              end;
            1:ppu_control2:=valor;
            3:sprite_ram_pos:=valor;
            4:begin
                sprite_ram[sprite_ram_pos]:=valor;
                sprite_ram_pos:=sprite_ram_pos+1;
              end;
            5:if ppu_dir_first then begin
                ppu_address_temp:=(ppu_address_temp and $ffe0) or ((valor and $F8) shr 3);
                ppu_tile_x_offset:=valor and $7;
                ppu_dir_first:=false;
              end else begin
                ppu_address_temp:=(ppu_address_temp And $FC1F) or ((valor and $F8) shl 2);
                ppu_address_temp:=(ppu_address_temp And $8FFF) or ((valor and $7) shl 12);
                ppu_dir_first:=true;
              end;
            6:if ppu_dir_first then begin
                ppu_address_temp:=(ppu_address_temp and $ff) or ((valor and $3F) shl 8);
                ppu_dir_first:=false;
              end else begin
                ppu_address_temp:=(ppu_address_temp and $FF00) or valor;
                ppu_address:=ppu_address_temp;
                ppu_dir_first:=true;
              end;
            7:ppu_write(valor);
          end;
          end;
        $4000..$4013,$4015,$4017:n2a03_write(0,direccion,valor);
        $4014:ppu_dma_spr(valor);
        $4016:if (valor and 1)=0 then begin
                joy1:=0;
                joy2:=0;
              end;
        $4018..$5fff:if @llamadas_nes.write_expansion<>nil then llamadas_nes.write_expansion(direccion,valor); //Expansion Area
        $6000..$7fff:if @llamadas_nes.write_extra_ram=nil then begin
                        if sram_enable then memoria[direccion]:=valor; //SRAM Area
                     end else begin
                          llamadas_nes.write_extra_ram(direccion,valor);
                     end;
        $8000..$ffff:if @llamadas_nes.write_rom<>nil then llamadas_nes.write_rom(direccion,valor); //PRG-ROM Area
  end;
end;

procedure nes_sound_update;
begin
  n2a03_sound_update(0);
end;

procedure nes_irq(status:byte);
begin
  main_m6502.pedir_irq:=status;
end;

function abrir_nes:boolean;
var
  cabecera_nes:array [0..$F] of byte;
  mal:boolean;
  extension,nombre_file,RomFile:string;
  datos,temp:pbyte;
  longitud,crc:integer;
  f,mapper:byte;
begin
  if sram_present then write_file(cart_name,@memoria[$6000],$2000);
  if not(OpenRom(StNes,RomFile)) then begin
    abrir_nes:=true;
    exit;
  end;
  abrir_nes:=false;
  extension:=extension_fichero(RomFile);
  if extension='ZIP' then begin
    if not(search_file_from_zip(RomFile,'*.nes',nombre_file,longitud,crc,true)) then exit;
    getmem(datos,longitud);
    if not(load_file_from_zip(RomFile,nombre_file,datos,longitud,crc,true)) then begin
      freemem(datos);
      exit;
    end;
  end else begin
    if extension<>'NES' then exit;
    if not(read_file_size(RomFile,longitud)) then exit;
    getmem(datos,longitud);
    if not(read_file(RomFile,datos,longitud)) then begin
      freemem(datos);
      exit;
    end;
    nombre_file:=extractfilename(RomFile);
  end;
  temp:=datos;
  copymemory(@cabecera_nes[0],temp,$10);
  inc(temp,$10);
  if ((cabecera_nes[0]<>ord('N')) and ((cabecera_nes[1]<>ord('E'))) and ((cabecera_nes[2]<>ord('S')))) then exit;
  mal:=true;
  llamadas_nes.read_expansion:=nil;
  llamadas_nes.write_expansion:=nil;
  llamadas_nes.write_extra_ram:=nil;
  llamadas_nes.line_counter:=nil;
  llamadas_nes.write_rom:=nil;
  cart_name:=Directory.Arcade_nvram+ChangeFileExt(nombre_file,'.nv');
  sram_enable:=false;
  //Pos 4 Numero de paginas de ROM de 16k 1-255
  mapper_nes.last_prg:=cabecera_nes[4];
  for f:=0 to (mapper_nes.last_prg-1) do begin
    copymemory(@mapper_nes.prg[f,0],temp,$4000);
    inc(temp,$4000);
  end;
  copymemory(@memoria[$8000],@mapper_nes.prg[0,0],$4000);
  if mapper_nes.last_prg=1 then copymemory(@memoria[$C000],@mapper_nes.prg[0,0],$4000)
    else copymemory(@memoria[$C000],@mapper_nes.prg[1,0],$4000);
  //Pos 5 Numero de paginas de CHR de 8k 0-255
  mapper_nes.last_chr:=cabecera_nes[5];
  if mapper_nes.last_chr=0 then begin
    ppu_chr_rom:=false;
  end else begin
    ppu_chr_rom:=true;
    for f:=0 to (mapper_nes.last_chr-1) do begin
      copymemory(@mapper_nes.chr[f,0],temp,$2000);
      inc(temp,$2000);
    end;
    copymemory(@ppu_mem[0],@mapper_nes.chr[0,0],$2000);
  end;
  //Hay trainer, de momento lo ignoro...
  if (cabecera_nes[6] and 4)<>0 then inc(temp,$200);
  //Pos 6 bit7-4 mapper low - bit3 4 screen - bit2 trainer - bit1 battery - bit0 mirror
  //Pos 7 bit7-4 mapper high
  //Si la pos 7 tiene la marca --> iNes 2.0
  if (cabecera_nes[7] and 8)=8 then begin
    //cabecera_nes[$f]<>0 then cabecera_nes[7]:=0;
    MessageDlg('NES: Cabecera iNes 2.0', mtError,[mbOk], 0);
  end else begin
    //Si las pos 12,13,14 y 15 <>0 --> Archaic
    if ((cabecera_nes[12]<>0) and (cabecera_nes[13]<>0) and (cabecera_nes[14]<>0) and (cabecera_nes[15]<>0)) then begin
      mapper:=cabecera_nes[6] shr 4;
    end else begin //iNes
      mapper:=(cabecera_nes[6] shr 4) or (cabecera_nes[7] and $f0);
      if (cabecera_nes[9] and 1)<>0 then MessageDlg('NES: PAL', mtError,[mbOk], 0);
    end;
  end;
  if (cabecera_nes[6] and 2)<>0 then begin
    if read_file_size(cart_name,longitud) then read_file(cart_name,@memoria[$6000],longitud);
    sram_present:=true;
  end else sram_present:=false;
  if (cabecera_nes[6] and 8)<>0 then ppu_mirror:=MIRROR_FOUR_SCREEN
    else if (cabecera_nes[6] and 1)=0 then ppu_mirror:=MIRROR_HORIZONTAL  //Horizontal
      else ppu_mirror:=MIRROR_VERTICAL;  //Vertical
  case mapper of
      0:mal:=false; //Nada que hacer...
      1,2,67,68,93,94,180:begin
          copymemory(@memoria[$c000],@mapper_nes.prg[(mapper_nes.last_prg-1),0],$4000);
          case mapper of
             1:begin
                llamadas_nes.write_rom:=mapper_1_write_rom;
                mapper_nes.reg[0]:=$1f;
                mapper_nes.reg[1]:=0;
                mapper_nes.reg[2]:=0;
                mapper_nes.reg[3]:=0;
                sram_enable:=true;
              end;
             2:llamadas_nes.write_rom:=mapper_2_write_rom;
            67:llamadas_nes.write_rom:=mapper_67_write_rom;
            68:llamadas_nes.write_rom:=mapper_68_write_rom;
            93:llamadas_nes.write_rom:=mapper_93_write_rom;
            94:llamadas_nes.write_rom:=mapper_94_write_rom;
           180:llamadas_nes.write_rom:=mapper_180_write_rom;
          end;
          mal:=false;
        end;
      3,87,185:begin
          case mapper of
            3:llamadas_nes.write_rom:=mapper_3_write_rom;
           87:llamadas_nes.write_extra_ram:=mapper_87_write_rom;
          185:llamadas_nes.write_rom:=mapper_185_write_rom;
          end;
          mal:=false;
        end;
      4:begin
          copymemory(@memoria[$8000],@mapper_nes.prg[mapper_nes.last_prg-1,0],$4000);
          copymemory(@memoria[$c000],@mapper_nes.prg[mapper_nes.last_prg-1,0],$4000);
          mal:=false;
          llamadas_nes.write_rom:=mapper_4_write_rom;
          llamadas_nes.line_counter:=mapper_4_line;
          mapper_nes.reg[0]:=0;
          mapper_nes.reg[1]:=0;
          mapper_nes.reg[2]:=0;
          mapper_nes.irq_ena:=false;
          mapper_nes.dreg[0]:=0;
          mapper_nes.dreg[1]:=2;
          mapper_nes.dreg[2]:=4;
          mapper_nes.dreg[3]:=5;
          mapper_nes.dreg[4]:=6;
          mapper_nes.dreg[5]:=7;
          mapper_nes.dreg[6]:=0;
          mapper_nes.dreg[7]:=1;
        end;
      7,66:begin
          case mapper of
            7:llamadas_nes.write_rom:=mapper_7_write_rom;
            66:begin
                  mapper_nes.reg[0]:=0;
                  mapper_nes.reg[1]:=0;
                  llamadas_nes.write_rom:=mapper_66_write_rom;
               end;
          end;
          mal:=false;
        end;
      else MessageDlg('NES: Mapper unknown!!! - Type: '+inttostr(mapper), mtError,[mbOk], 0);
  end;
  freemem(datos);
  if not(mal) then begin
    directory.Nes:=ExtractFilePath(romfile);
    change_caption('NES - '+nombre_file);
    nes_reset;
    abrir_nes:=true;
  end;
  cartucho_cargado:=true;
end;

end.
