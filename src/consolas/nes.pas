unit nes;

interface

uses {$IFDEF WINDOWS}windows,{$ENDIF}
     main_engine,nes_ppu,controls_engine,sysutils,dialogs,misc_functions,
     sound_engine,file_engine,n2a03,m6502,nes_mappers,lenguaje,ay_8910;

type
    tllamadas_nes=record
           read_expansion:function(direccion:word):byte;
           write_expansion:procedure(direccion:word;valor:byte);
           read_prg_ram:function(direccion:word):byte;
           write_prg_ram:procedure(direccion:word;valor:byte);
           write_rom:procedure(direccion:word;valor:byte);
           read_rom:function(direccion:word):byte;
           line_ack:procedure;
           end;

procedure cargar_nes;

var
  llamadas_nes:tllamadas_nes;

implementation
uses principal,snapshot;

const
  NTSC_CLOCK=1789773;
  PAL_CLOCK=1662607;
  NTSC_refresh=60.0988;
  PAL_refresh=50.0070;
  NTSC_lines=262;
  PAL_lines=312;

var
  joy1,joy2,joy1_read,joy2_read,val_4016:byte;
  sram_present:boolean=false;
  cart_name:string;
  cartucho_cargado:boolean;

procedure eventos_nes;
var
  temp_r:preg_m6502;
begin
  if event.arcade then begin
    //Player 1
    if arcade_input.up[0] then joy1_read:=(joy1_read or $10) else joy1_read:=(joy1_read and $ef);
    if arcade_input.down[0] then joy1_read:=(joy1_read or $20) else joy1_read:=(joy1_read and $df);
    if arcade_input.left[0] then joy1_read:=(joy1_read or $40) else joy1_read:=(joy1_read and $bf);
    if arcade_input.right[0] then joy1_read:=(joy1_read or $80) else joy1_read:=(joy1_read and $7f);
    if arcade_input.but1[0] then joy1_read:=(joy1_read or $1) else joy1_read:=(joy1_read and $fe);
    if arcade_input.but0[0] then joy1_read:=(joy1_read or $2) else joy1_read:=(joy1_read and $fd);
    if arcade_input.start[0] then joy1_read:=(joy1_read or $8) else joy1_read:=(joy1_read and $f7);
    if arcade_input.coin[0] then joy1_read:=(joy1_read or $4) else joy1_read:=(joy1_read and $fb);
    //Player 2
    if arcade_input.up[1] then joy2_read:=(joy2_read or $10) else joy2_read:=(joy2_read and $ef);
    if arcade_input.down[1] then joy2_read:=(joy2_read or $20) else joy2_read:=(joy2_read and $df);
    if arcade_input.left[1] then joy2_read:=(joy2_read or $40) else joy2_read:=(joy2_read and $bf);
    if arcade_input.right[1] then joy2_read:=(joy2_read or $80) else joy2_read:=(joy2_read and $7f);
    if arcade_input.but1[1] then joy2_read:=(joy2_read or $1) else joy2_read:=(joy2_read and $fe);
    if arcade_input.but0[1] then joy2_read:=(joy2_read or $2) else joy2_read:=(joy2_read and $fd);
    if arcade_input.start[1] then joy2_read:=(joy2_read or $8) else joy2_read:=(joy2_read and $f7);
    if arcade_input.coin[1] then joy2_read:=(joy2_read or $4) else joy2_read:=(joy2_read and $fb);
  end;
  if event.keyboard then begin
    //Soft Reset
    if keyboard[KEYBOARD_f5] then begin
      //Softreset
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
  if not(cartucho_cargado) then exit;
  init_controls(false,true,false,true);
  frame:=n2a03_0.m6502.tframes;
  even:=true;
  while EmuStatus=EsRuning do begin
    ppu_nes.linea:=0;
    while ppu_nes.linea<NTSC_lines do begin
      case ppu_nes.linea of
          0..239:begin  //render
              //En la linea 264 carga los valores de los sprites de la linea 0 PERO NO EVALUA NADA
              //En la linea 0 desde 1 PPUT hasta 256 PPUT pinta todo, la linea y con los valores
              //cargados antes, los sprites. Segun esta pintando evalua el sprite_hit_0, apartir del 257
              //La comprobacion de los sprites termina en PPUT 256 aqui pongo el sprite_over_flow
              n2a03_0.m6502.run((256*PPU_PIXEL_TIMING)-ppu_nes.sprite0_hit_pos);
              frame:=frame-n2a03_0.m6502.contador;
              //No es exacto, pero pongo el sprite_overflow...
              if ppu_nes.sprite_over_flow then begin
                ppu_nes.status:=ppu_nes.status or $20;
                ppu_nes.sprite_over_flow:=false;
              end;
              ppu_end_y_coarse;
              ppu_linea(ppu_nes.linea);
              //Donde pongo el sprite_hit_0?
              if ppu_nes.sprite0_hit then begin
                n2a03_0.m6502.run(ppu_nes.sprite0_hit_pos);
                frame:=frame-n2a03_0.m6502.contador;
                ppu_nes.status:=ppu_nes.status or $40;
                ppu_nes.sprite0_hit:=false;
              end;
              //Ahora avanzo hasta el 256 PPUT (descontando lo consumido hasta el sprite 0)
              if (@llamadas_nes.line_ack<>nil) then llamadas_nes.line_ack;
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
              ppu_nes.status:=ppu_nes.status or $80;
              if (ppu_nes.control1 and $80)<>0 then begin
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
              ppu_nes.status:=ppu_nes.status and $1f;
              ppu_nes.sprite_over_flow:=false;
              //Quitar un PPT
              if even then frame:=frame-PPU_PIXEL_TIMING;
              even:=not(even);
              n2a03_0.m6502.run(frame);
              frame:=frame+n2a03_0.m6502.tframes-n2a03_0.m6502.contador;
              if (ppu_nes.control2 and $18)<>0 then ppu_nes.address:=(ppu_nes.address and $41f) or (ppu_nes.address_temp and $7be0);
              if (@llamadas_nes.line_ack<>nil) then llamadas_nes.line_ack;
           end;
      end;
      ppu_nes.linea:=ppu_nes.linea+1;
    end;
    eventos_nes;
    actualiza_trozo_simple(0,0,256,240,2);
    video_sync;
  end;
end;

procedure prg_ram_write(direccion:word;valor:byte);
begin
  if not(mapper_nes.prg_ram_writeble) then exit;
  if not(mapper_nes.prg_ram_enable) then exit;
  memoria[direccion]:=valor;
end;
function prg_ram_read(direccion:word):byte;
begin
  if not(mapper_nes.prg_ram_enable) then prg_ram_read:=ppu_nes.open_bus
    else prg_ram_read:=memoria[direccion];
end;

function nes_getbyte(direccion:word):byte;
begin
  ppu_nes.open_bus:=direccion shr 8;
  case direccion of
    $0..$1fff:nes_getbyte:=memoria[direccion and $7ff];
    $2000..$3fff:case (direccion and 7) of
                  $2:begin
                        nes_getbyte:=ppu_nes.status;
                        // el bit de vblank se elimina cuando se lee el registro
                        ppu_nes.status:=ppu_nes.status and $60;
                        ppu_nes.dir_first:=true;
                        n2a03_0.m6502.change_nmi(CLEAR_LINE);
                    end;
                  $4:nes_getbyte:=ppu_nes.sprite_ram[ppu_nes.sprite_ram_pos];
                  $7:nes_getbyte:=ppu_read;
                  else nes_getbyte:=ppu_nes.open_bus;
                end;
    $4000..$4013,$4015:nes_getbyte:=n2a03_0.read(direccion);
    $4016:begin
            nes_getbyte:=(ppu_nes.open_bus and $e0) or ((joy1_read shr joy1) and 1);
            joy1:=joy1+1;
          end;
    $4017:begin
            nes_getbyte:=(ppu_nes.open_bus and $e0) or ((joy2_read shr joy2) and 1);
            joy2:=joy2+1;
          end;
    $4020..$5fff:if @llamadas_nes.read_expansion<>nil then nes_getbyte:=llamadas_nes.read_expansion(direccion) //Expansion Area
                    else nes_getbyte:=ppu_nes.open_bus;
    $6000..$7fff:nes_getbyte:=llamadas_nes.read_prg_ram(direccion); //PRG-RAM
    $8000..$ffff:if @llamadas_nes.read_rom<>nil then nes_getbyte:=llamadas_nes.read_rom(direccion)
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
                if (((ppu_nes.status and $80)<>0) and ((ppu_nes.control1 and $80)=0) and ((valor and $80)<>0)) then begin
                   n2a03_0.m6502.change_nmi(PULSE_LINE);
                   n2a03_0.m6502.after_ei:=true;
                end;
                ppu_nes.control1:=valor;
                ppu_nes.sprite_size:=8 shl ((valor shr 5) and 1);
                ppu_nes.pos_bg:=(valor shr 4) and 1;
                ppu_nes.pos_spt:=(valor shr 3) and 1;
                ppu_nes.address_temp:=(ppu_nes.address_temp and $73ff) or ((valor and $3) shl 10);
              end;
            1:ppu_nes.control2:=valor;
            3:ppu_nes.sprite_ram_pos:=valor;
            4:begin
                //Si esta renderizando escribe $ff!!
                if ppu_nes.linea<240 then valor:=$ff;
                ppu_nes.sprite_ram[ppu_nes.sprite_ram_pos]:=valor;
                ppu_nes.sprite_ram_pos:=ppu_nes.sprite_ram_pos+1;
              end;
            5:begin
                if ppu_nes.dir_first then begin
                  ppu_nes.address_temp:=ppu_nes.address_temp and $7fe0;
                  ppu_nes.address_temp:=ppu_nes.address_temp or ((valor and $F8) shr 3);
                  ppu_nes.tile_x_offset:=valor and $7;
                end else begin
                  ppu_nes.address_temp:=ppu_nes.address_temp and $c1f;
                  ppu_nes.address_temp:=ppu_nes.address_temp or ((valor and $f8) shl 2);
                  ppu_nes.address_temp:=ppu_nes.address_temp or ((valor and $7) shl 12);
                end;
                ppu_nes.dir_first:=not(ppu_nes.dir_first);
              end;
            6:begin
                if ppu_nes.dir_first then begin
                  ppu_nes.address_temp:=ppu_nes.address_temp and $ff;
                  ppu_nes.address_temp:=ppu_nes.address_temp or ((valor and $3F) shl 8);
                end else begin
                  ppu_nes.address_temp:=ppu_nes.address_temp and $7f00;
                  ppu_nes.address_temp:=ppu_nes.address_temp or valor;
                  ppu_nes.address:=ppu_nes.address_temp;
                  if (ppu_nes.address and $1000)<>0 then if (@llamadas_nes.line_ack<>nil) then llamadas_nes.line_ack;
                end;
                ppu_nes.dir_first:=not(ppu_nes.dir_first);
              end;
            7:ppu_write(valor);
          end;
          end;
        $4000..$4013,$4015,$4017:n2a03_0.write(direccion,valor);
        $4014:ppu_dma_spr(valor);
        $4016:begin
                if (((valor and 1)=0) and (val_4016=1)) then begin
                  joy1:=0;
                  joy2:=0;
                end;
                val_4016:=valor and 1;
              end;
        $4020..$5fff:if @llamadas_nes.write_expansion<>nil then llamadas_nes.write_expansion(direccion,valor); //Expansion Area
        $6000..$7fff:llamadas_nes.write_prg_ram(direccion,valor); //PRG-RAM
        $8000..$ffff:if @llamadas_nes.write_rom<>nil then llamadas_nes.write_rom(direccion,valor); //PRG-ROM Area
  end;
end;

//Main
procedure nes_reset;
begin
  //IMPORTANTE: Primero reset al mapper para que coloque correctamente las ROMS!!!!!
  mapper_reset;
  reset_audio;
  n2a03_0.reset;
  reset_ppu;
  joy1:=0;
  joy2:=0;
  joy1_read:=0;
  joy2_read:=0;
  val_4016:=0;
end;

function llamadas_mapper(mapper:word):boolean;
begin
  llamadas_mapper:=true;
  n2a03_0.m6502.change_despues_instruccion(nil);
  llamadas_nes.read_prg_ram:=prg_ram_read;
  llamadas_nes.write_prg_ram:=prg_ram_write;
  case mapper of
      0:;
      1:begin
          llamadas_nes.write_rom:=mapper_1_write_rom;
          n2a03_0.m6502.change_despues_instruccion(mapper_1_delay);
        end;
      2:llamadas_nes.write_rom:=mapper_2_write_rom;
      3:llamadas_nes.write_rom:=mapper_3_write_rom;
      4:begin
          llamadas_nes.write_rom:=mapper_4_write_rom;
          llamadas_nes.line_ack:=mapper_4_line;
        end;
      5:begin
          llamadas_nes.read_expansion:=mapper_5_read_extended;
          llamadas_nes.write_expansion:=mapper_5_write_extended;
          llamadas_nes.write_rom:=mapper_5_write_rom;
          llamadas_nes.read_rom:=mapper_5_read_rom;
        end;
      7:llamadas_nes.write_rom:=mapper_7_write_rom;
      9:begin
          llamadas_nes.write_rom:=mapper_9_write_rom;
          mapper_nes.ppu_read:=mapper_9_ppu_read;
        end;
      11:llamadas_nes.write_rom:=mapper_11_write_rom;
      12:begin
          llamadas_nes.line_ack:=mapper_4_line;
          llamadas_nes.write_rom:=mapper_12_write_rom;
          llamadas_nes.write_expansion:=mapper_12_write_rom;
        end;
      13:begin
          //Tiene 4 paginas de chr en RAM!! uso los registros del mapper para el mapeo
          llamadas_nes.write_rom:=mapper_13_write_rom;
          ppu_nes.write_chr:=true;
         end;
      15:llamadas_nes.write_rom:=mapper_15_write_rom;
      18:begin
          llamadas_nes.write_rom:=mapper_18_write_rom;
          n2a03_0.m6502.change_despues_instruccion(mapper_18_irq);
      end;
      21,25:begin
            llamadas_nes.write_rom:=mapper_21_write_rom;
            n2a03_0.m6502.change_despues_instruccion(mapper_vrc_irq);
         end;
      22:llamadas_nes.write_rom:=mapper_22_write_rom;
      23:llamadas_nes.write_rom:=mapper_23_write_rom;
      32:llamadas_nes.write_rom:=mapper_32_write_rom;
      33:llamadas_nes.write_rom:=mapper_33_write_rom;
      34:begin
          llamadas_nes.write_rom:=mapper_34_write_rom;
          llamadas_nes.write_prg_ram:=mapper_34_write_rom;
      end;
      41:begin
          llamadas_nes.write_rom:=mapper_41_write_rom;
          llamadas_nes.write_prg_ram:=mapper_41_write_rom;
      end;
      42:begin
          llamadas_nes.write_rom:=mapper_42_write_rom;
          n2a03_0.m6502.change_despues_instruccion(mapper_42_irq);
      end;
      48:begin
          llamadas_nes.write_rom:=mapper_48_write_rom;
          llamadas_nes.line_ack:=mapper_4_line;
        end;
      57:llamadas_nes.write_rom:=mapper_57_write_rom;
      58,213:llamadas_nes.write_rom:=mapper_58_write_rom;
      64:begin
          llamadas_nes.write_rom:=mapper_64_write_rom;
          n2a03_0.m6502.change_despues_instruccion(mapper_64_irq);
          llamadas_nes.line_ack:=mapper_64_line;
         end;
      65:begin
          llamadas_nes.write_rom:=mapper_65_write_rom;
          n2a03_0.m6502.change_despues_instruccion(mapper_65_irq);
         end;
      66:llamadas_nes.write_rom:=mapper_66_write_rom;
      67:begin
          llamadas_nes.write_rom:=mapper_67_write_rom;
          n2a03_0.m6502.change_despues_instruccion(mapper_67_irq);
         end;
      68:llamadas_nes.write_rom:=mapper_68_write_rom;
      69:begin
          llamadas_nes.write_rom:=mapper_69_write_rom;
          n2a03_0.m6502.change_despues_instruccion(mapper_69_irq);
          llamadas_nes.read_prg_ram:=mapper_69_read_prg_ram;
          llamadas_nes.write_prg_ram:=mapper_69_write_prg_ram;
          if AY8910_0=nil then AY8910_0:=ay8910_chip.create(NTSC_CLOCK,AY8910,2);
          n2a03_0.add_more_sound(mapper_69_update_sound);
      end;
      70:llamadas_nes.write_rom:=mapper_70_write_rom;
      71:llamadas_nes.write_rom:=mapper_71_write_rom;
      73:begin
          llamadas_nes.write_rom:=mapper_73_write_rom;
          n2a03_0.m6502.change_despues_instruccion(mapper_73_irq);
         end;
      75:llamadas_nes.write_rom:=mapper_75_write_rom;
      76:llamadas_nes.write_rom:=mapper_76_write_rom;
      79,146:llamadas_nes.write_expansion:=mapper_79_write_rom;
      85:begin
            llamadas_nes.write_rom:=mapper_85_write_rom;
            n2a03_0.m6502.change_despues_instruccion(mapper_vrc_irq);
         end;
      87:llamadas_nes.write_prg_ram:=mapper_87_write_rom;
      88:llamadas_nes.write_rom:=mapper_88_write_rom;
      89:llamadas_nes.write_rom:=mapper_89_write_rom;
      93:llamadas_nes.write_rom:=mapper_93_write_rom;
      94:llamadas_nes.write_rom:=mapper_94_write_rom;
      95:llamadas_nes.write_rom:=mapper_95_write_rom;
     105:begin
          llamadas_nes.write_rom:=mapper_105_write_rom;
          n2a03_0.m6502.change_despues_instruccion(mapper_105_irq);
         end;
     113:llamadas_nes.write_expansion:=mapper_113_write_rom;
     116:llamadas_nes.write_expansion:=mapper_116_write_rom;
     132:begin
          llamadas_nes.read_expansion:=mapper_132_read_exp;
          llamadas_nes.write_expansion:=mapper_132_write_exp;
          llamadas_nes.write_rom:=mapper_132_write_rom;
         end;
     133:llamadas_nes.write_expansion:=mapper_133_write_rom;
     137:llamadas_nes.write_expansion:=mapper_137_write_rom;
     139,138,141:llamadas_nes.write_expansion:=mapper_139_write_rom;
     142:begin
          llamadas_nes.write_rom:=mapper_142_write_rom;
          n2a03_0.m6502.change_despues_instruccion(mapper_142_irq);
         end;
     143:llamadas_nes.read_expansion:=mapper_143_read_rom;
     145:llamadas_nes.write_expansion:=mapper_145_write_rom;
     147:begin
            llamadas_nes.write_expansion:=mapper_147_write_rom;
            llamadas_nes.write_rom:=mapper_147_write_rom;
         end;
     148:llamadas_nes.write_rom:=mapper_148_write_rom;
     149:llamadas_nes.write_rom:=mapper_149_write_rom;
     150:begin
            llamadas_nes.write_expansion:=mapper_150_write_rom;
            llamadas_nes.read_expansion:=mapper_150_read_rom;
         end;
     152:llamadas_nes.write_rom:=mapper_152_write_rom;
     154:llamadas_nes.write_rom:=mapper_154_write_rom;
     172:begin
            llamadas_nes.write_rom:=mapper_172_write_rom;
            llamadas_nes.write_expansion:=mapper_172_write_rom;
            llamadas_nes.read_expansion:=mapper_172_read;
         end;
     173:begin
          llamadas_nes.read_expansion:=mapper_132_read_exp;
          llamadas_nes.write_expansion:=mapper_132_write_exp;
          llamadas_nes.write_rom:=mapper_173_write_rom;
         end;
     180:llamadas_nes.write_rom:=mapper_180_write_rom;
     184:llamadas_nes.write_prg_ram:=mapper_184_write_rom;
     185:llamadas_nes.write_rom:=mapper_185_write_rom;
     206:llamadas_nes.write_rom:=mapper_206_write_rom;
     212:begin
          llamadas_nes.read_expansion:=mapper_212_read_exp;
          llamadas_nes.write_rom:=mapper_212_write_rom;
         end;
     221:llamadas_nes.write_rom:=mapper_221_write_rom;
     243:llamadas_nes.write_expansion:=mapper_243_write_rom;
      else llamadas_mapper:=false;
  end;
end;

function abrir_cartucho(datos:pbyte;longitud:integer):boolean;
type
  tnes_header=packed record
    magic:array[0..2] of ansichar;
    magic2,prg_rom,chr_rom,flags6,flags7,flags8,flags9,flags10:byte;
    unused1:array[0..4] of byte;
  end;
var
  nes_header:^tnes_header;
  ptemp:pbyte;
  f:byte;
  mapper:word;
  crc32,rom_crc32:dword;
begin
  abrir_cartucho:=false;
  ptemp:=datos;
  getmem(nes_header,sizeof(tnes_header));
  copymemory(nes_header,ptemp,$10);
  crc32:=calc_crc(ptemp,longitud);
  inc(ptemp,$10);
  if ((nes_header.magic<>'NES') and (nes_header.magic2<>$1a)) then exit;
  llamadas_nes.read_expansion:=nil;
  llamadas_nes.write_expansion:=nil;
  llamadas_nes.line_ack:=nil;
  llamadas_nes.write_rom:=nil;
  mapper_nes.ppu_read:=nil;
  mapper_nes.submapper:=0;
  //Hay trainer, lo copio a la direccion $7000
  if (nes_header.flags6 and 4)<>0 then begin
    copymemory(@memoria[$7000],ptemp,$200);
    mapper_nes.prg_ram_enable:=true;
    inc(ptemp,$200);
  end;
  //Pos 4 Numero de paginas de ROM de 16k 1-255
  mapper_nes.last_prg:=nes_header.prg_rom;
  for f:=0 to (mapper_nes.last_prg-1) do begin
    copymemory(@mapper_nes.prg[f,0],ptemp,$4000);
    inc(ptemp,$4000);
  end;
  copymemory(@memoria[$8000],@mapper_nes.prg[0,0],$4000);
  if mapper_nes.last_prg=1 then copymemory(@memoria[$c000],@mapper_nes.prg[0,0],$4000)
    else copymemory(@memoria[$c000],@mapper_nes.prg[1,0],$4000);
  //Pos 5 Numero de paginas de CHR de 8k 0-255
  mapper_nes.last_chr:=nes_header.chr_rom;
  //chr ram es un caso diferente... tiene paginacion y dos paginas que se pueden intercambiar
  //Lo activo solo si el mapper lo necesita... Uso igual la memoria chr del MAPPER!!!
  if mapper_nes.last_chr=0 then begin
    ppu_nes.write_chr:=true;
    fillchar(mapper_nes.chr[0,0],$2000,0);
  end else begin
    ppu_nes.write_chr:=false;
    for f:=0 to (mapper_nes.last_chr-1) do begin
      copymemory(@mapper_nes.chr[f,0],ptemp,$2000);
      inc(ptemp,$2000);
    end;
    copymemory(@ppu_nes.chr[0,0],@mapper_nes.chr[0,0],$1000);
    copymemory(@ppu_nes.chr[1,0],@mapper_nes.chr[0,$1000],$1000);
  end;
  //Pos 6 bit7-4 mapper low - bit3 4 screen - bit2 trainer - bit1 battery - bit0 mirror
  //Pos 7 bit7-4 mapper high
  //Si la pos 7 tiene la marca 'XXXX10XX'--> iNes 2.0
  if (nes_header.flags7 and $c)=8 then begin
    MessageDlg('NES: Cabecera iNes 2.0',mtInformation,[mbOk], 0);
    //Falta por implementar el resto... http://wiki.nesdev.com/w/index.php/NES_2.0
    mapper_nes.submapper:=(nes_header.flags8 and $f0) shr 4;
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
  if (nes_header.flags6 and 2)<>0 then begin
    if read_file_size(cart_name,longitud) then read_file(cart_name,@memoria[$6000],longitud);
    sram_present:=true;
  end else sram_present:=false;
  if (nes_header.flags6 and 8)<>0 then ppu_nes.mirror:=MIRROR_FOUR_SCREEN
    else if (nes_header.flags6 and 1)=0 then ppu_nes.mirror:=MIRROR_HORIZONTAL
      else ppu_nes.mirror:=MIRROR_VERTICAL;
  //Parches!!!
  case crc32 of
    $50f66538:memoria[$fffd]:=$ca; //Urban chan e-games
    $7a5cc019:begin
                memoria[$fb14]:=$04;
                memoria[$fb15]:=$04;
              end;
    $3fc29044,$2ed79b73,$76124d08:begin //MMC6
            llamadas_nes.read_prg_ram:=mapper_mmc6_wram_read;
            llamadas_nes.write_prg_ram:=mapper_mmc6_wram_write;
            llamadas_nes.write_rom:=mapper_mmc6_write_rom;
              end;
    $42edbce2,$acc2b74a,$d8dfd3d1:mapper_nes.submapper:=1;
    $51ce0655,$761e1fc9,$57d8330a,$e1539190:begin
                mapper:=206;
                ppu_nes.mirror:=MIRROR_FOUR_SCREEN;
              end;
    $d327f0a:mapper:=154;
    $4433ba0a:mapper:=87;
    $3c7b0120,$ad893bf7,$2fb7d5b9,$977f982,$d994d5ff,$f07d31b2,$e476313e,$103f0755,$63d71cda,$a8a1c2eb,$c8e5e815,$6fdf50d0,$154a31b6:mapper:=206;
    $d122ba8d,$62e7aec5,$6ee61da3:mapper:=152;
  end;
  rom_crc32:=calc_crc(@mapper_nes.chr[0,0],$2000);
  if ((mapper=243) and (rom_crc32<>$282dcb3a) and (rom_crc32<>$331802e2)) then mapper:=150;
  case rom_crc32 of
    $19c5c4aa:if mapper=25 then begin //VRC2-c
                mapper_nes.submapper:=1;
                mapper:=23;
              end;
    $824324fa,$87c17609,$3b31f998:if mapper=25 then mapper_nes.submapper:=3; //VRC4-b
    $f82b8e59:if mapper=21 then mapper_nes.submapper:=1; //VRC4-c
    $ae17c652,$23f896a7:if mapper=25 then mapper_nes.submapper:=4; //VRC4-d
    $a30927de,$7b790220,$c2cf279a,$88b512d6,$eb9fd289:if mapper=23 then begin //VRC4-e
                mapper_nes.submapper:=2;
                mapper:=21;
              end;
    $bd493548:mapper_nes.submapper:=1; //VRC7-b
    $7ff2dc2b,$6add6cd6,$1557191a,$8f03a735,$e8d170d8,$cc06cf3e:if mapper=33 then mapper:=48;
    $f47f0bca:if mapper=173 then mapper:=132;
    $1a145504,$19c33692:if mapper=79 then mapper:=173;
    $479fb8e6:mapper:=133;
  end;
  mapper_nes.mapper:=mapper;
  if llamadas_mapper(mapper) then begin
    abrir_cartucho:=true;
  end else begin
    abrir_cartucho:=false;
    MessageDlg('NES: Mapper unknown!!! - Type: '+inttostr(mapper), mtError,[mbOk], 0);
    EmuStatus:=EsStoped;
  end;
end;

function abrir_nes:boolean;
var
  extension,nombre_file,RomFile:string;
  datos:pbyte;
  longitud,crc:integer;
  resultado:boolean;
begin
  if not(OpenRom(StNes,RomFile)) then begin
    abrir_nes:=true;
    exit;
  end;
  //Primero, si tengo que guardar la SRAM por que ya he abierto un cartucho
  if sram_present then write_file(cart_name,@memoria[$6000],$2000);
  if @n2a03_0.additional_sound<>nil then n2a03_0.add_more_sound(nil);
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
  //Abrirlo
  extension:=extension_fichero(nombre_file);
  //if extension='DSP' then resultado:=abrir_coleco_snapshot(datos,longitud)
  //  else
  resultado:=abrir_cartucho(datos,longitud);
  freemem(datos);
  if resultado then begin
    cart_name:=Directory.Arcade_nvram+ChangeFileExt(nombre_file,'.nv');
    llamadas_maquina.open_file:=nombre_file;
    nes_reset;
    abrir_nes:=true;
    cartucho_cargado:=true;
  end else begin
    MessageDlg('Error cargando snapshot/ROM.'+chr(10)+chr(13)+'Error loading the snapshot/ROM.', mtInformation,[mbOk], 0);
    llamadas_maquina.open_file:='';
  end;
  change_caption;
  Directory.Nes:=ExtractFilePath(romfile);
end;

function iniciar_nes:boolean;
begin
  iniciar_audio(false);
  screen_init(1,512,1,true);
  screen_init(2,256,240);
  iniciar_video(256,240);
  n2a03_0:=cpu_n2a03.create(NTSC_clock,NTSC_lines);
  n2a03_0.m6502.change_ram_calls(nes_getbyte,nes_putbyte);
  n2a03_0.change_internals(nes_getbyte);
  getmem(mapper_nes,sizeof(tnes_mapper));
  getmem(ppu_nes,sizeof(tnes_ppu));
  nes_init_palette;
  if main_vars.console_init then abrir_nes;
  iniciar_nes:=true;
end;

procedure grabar_nes;
var
  nombre:string;
  correcto:boolean;
  indice:byte;
begin
if SaveRom(StNES,nombre,indice) then begin
  if FileExists(nombre) then begin
    if MessageDlg(leng[main_vars.idioma].mensajes[3], mtWarning, [mbYes]+[mbNo],0)=7 then exit;
  end;
  correcto:=grabar_nes_snapshot(nombre);
  if not(correcto) then MessageDlg('No se ha podido guardar el snapshot!',mtError,[mbOk],0)
    else Directory.Nes:=extractfiledir(nombre)+main_vars.cadena_dir;
end;
end;

procedure nes_cerrar;
begin
  if sram_present then write_file(cart_name,@memoria[$6000],$2000);
  if mapper_nes<>nil then freemem(mapper_nes);
  if ppu_nes<>nil then freemem(ppu_nes);
  mapper_nes:=nil;
  ppu_nes:=nil;
end;

procedure cargar_nes;
begin
  principal1.BitBtn10.Glyph:=nil;
  principal1.imagelist2.GetBitmap(2,principal1.BitBtn10.Glyph);
  principal1.BitBtn10.OnClick:=principal1.fLoadCartucho;
  llamadas_maquina.iniciar:=iniciar_nes;
  llamadas_maquina.bucle_general:=nes_principal;
  llamadas_maquina.close:=nes_cerrar;
  llamadas_maquina.reset:=nes_reset;
  llamadas_maquina.cartuchos:=abrir_nes;
  llamadas_maquina.fps_max:=NTSC_refresh;
  cartucho_cargado:=false;
end;

end.
