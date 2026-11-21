unit genesis;

interface
uses sysUtils,dialogs,genesis_cartridges;

function iniciar_genesis:boolean;

implementation
uses Classes,principal,nz80,m68000,main_engine,controls_engine,sega_315_5313,
     sound_engine,timer_engine,ym_2612,misc_functions,eepromser,file_engine;

var
 ram:array[0..$7fff] of word;
 zram:array[0..$1fff] of byte;
 io_control:array[0..$f] of byte;
 z80_is_reset,z80_has_bus,genesis_pal:boolean;
 genesis_region_bits:byte;
 z80_bank:dword;
 line_number,slice_number,dma_debt:integer;
 menacer_enabled:boolean;
 menacer_h_offset,menacer_v_offset:integer;

function pad_read(port:integer):byte;
var
  pins,mask:byte;
  th:boolean;
begin
 mask:=io_control[port+3];
 if menacer_enabled and (port=2) then begin
  pins:=0;
  if raton.button1 or arcade_input.but0[0] then pins:=pins or 2;
  if raton.button2 or arcade_input.but1[0] then pins:=pins or 1;
  if arcade_input.but2[0] then pins:=pins or 4;
  if arcade_input.start[1] then pins:=pins or 8;
  if vdp_5313_0.lightgun_th then pins:=pins or $40;
  result:=(pins and not mask) or (io_control[port] and mask);
  exit;
 end;
 th:=((io_control[port] or not mask)and $40)<>0;
 pins:=$7f;
 if port<=2 then begin
  if arcade_input.up[port-1] then pins:=pins and $fe;
  if arcade_input.down[port-1] then pins:=pins and $fd;
  if th then begin
   if arcade_input.left[port-1] then pins:=pins and $fb;
   if arcade_input.right[port-1] then pins:=pins and $f7;
   if arcade_input.but1[port-1] then pins:=pins and $ef;
   if arcade_input.but2[port-1] then pins:=pins and $df;
  end else begin
   pins:=pins and $b3;
   if arcade_input.but0[port-1] then pins:=pins and $ef;
   if arcade_input.start[port-1] then pins:=pins and $df;
  end;
 end;
 result:=(pins and not mask) or (io_control[port] and mask);
end;

procedure genesis_principal;
const
  slices=8;
var
  stall,clocks:integer;
begin
 while EmuStatus=EsRunning do begin
  if menacer_enabled then vdp_5313_0.lightgun_position(raton.x,raton.y,menacer_h_offset,menacer_v_offset);
  for line_number:=0 to llamadas_maquina.scanlines-1 do begin
      vdp_5313_0.handle_scanline(line_number);
      for slice_number:=0 to slices-1 do begin
          if menacer_enabled then vdp_5313_0.lightgun_step((slice_number+1)*3420 div slices,(io_control[5]and $c0)=$80);
          frame_main:=frame_main+3420/(7*slices);
          if Length(rom)>0 then begin
            inc(dma_debt,vdp_5313_0.take_dma_clocks);
            stall:=Trunc(frame_main);
            if stall>dma_debt then stall:=dma_debt;
            if stall>0 then begin
              timers.update(stall,m68000_0.numero_cpu);
              dec(dma_debt,stall);
              frame_main:=frame_main-stall;
            end;
            if frame_main>0 then begin
              m68000_0.run(frame_main);
              frame_main:=frame_main-m68000_0.contador;
            end;
          end else begin
            clocks:=Trunc(frame_main);
            timers.update(clocks,m68000_0.numero_cpu);
            frame_main:=frame_main-clocks;
          end;
          frame_snd:=frame_snd+3420/(15*slices);
          if(Length(rom)>0) and z80_has_bus and not z80_is_reset then begin
              z80_0.run(frame_snd);
              frame_snd:=frame_snd-z80_0.contador;
          end else frame_snd:=0;
      end;
  end;
  vdp_5313_0.handle_eof;
  video_sync;
  evalue_controls;
 end;
end;

function genesis_snd_getbyte(direccion:word):byte;
var
  address:dword;
  v:word;
begin
 result:=$ff;
 case direccion of
  0..$3fff:result:=zram[direccion and $1fff];
  $4000..$5fff:result:=ym2612_0.status;
  $7f00..$7f1f:begin
                  v:=vdp_5313_0.read(direccion and $1e);
                  if (direccion and 1)=0 then result:=v shr 8
                    else result:=v and $ff;
               end;
  $8000..$ffff:begin
                  // Banked accesses acquire the shared 68000 bus.
                  // Typical arbitration: 3 extra Z80 T-states and ~8 68000 clocks.
                  inc(z80_0.contador,3);
                  inc(dma_debt,8); // consumed by the existing 68000 bus-stall budget
                  address:=z80_bank or (direccion and $7fff);
                  if address<$400000 then result:=cart_byte(address)
                      else if address>=$e00000 then begin
                              v:=ram[(address and $ffff) shr 1];
                              if (address and 1)=0 then result:=v shr 8
                                else result:=v and $ff;
                           end;
               end;
 end;
end;

procedure genesis_snd_putbyte(direccion:word;valor:byte);
var
  address:dword;
  v:word;
begin
 case direccion of
  0..$3fff:zram[direccion and $1fff]:=valor;
  $4000..$5fff:ym2612_0.write_port(direccion and 3,valor);
  $6000..$60ff:z80_bank:=((z80_bank shr 1) or (dword(valor and 1) shl 23)) and $ff8000;
  $7f00..$7f1f:if (direccion and $1f)>=$10 then vdp_5313_0.write(direccion and $1e,valor)
                  else vdp_5313_0.write(direccion and $1e,word(valor)*$101);
  $8000..$ffff:begin
                  // Banked accesses acquire the shared 68000 bus.
                  // Typical arbitration: 3 extra Z80 T-states and ~8 68000 clocks.
                  inc(z80_0.contador,3);
                  inc(dma_debt,8); // consumed by the existing 68000 bus-stall budget
                  address:=z80_bank or (direccion and $7fff);
                  if address<$400000 then cart_write(address,valor)
                    else if address>=$e00000 then begin
                            v:=ram[(address and $ffff) shr 1];
                            if (address and 1)=0 then v:=(v and $ff) or (word(valor) shl 8)
                              else v:=(v and $ff00) or valor;
                            ram[(address and $ffff) shr 1]:=v;
                          end;
               end;
 end;
end;

function genesis_open_bus:word;
var
  address:dword;
begin
 // Approximate the 68000 prefetch bus with the next instruction word.
 // Read only ROM/RAM here: never recurse through the I/O handlers.
 address:=m68000_0.r.pc.l and $fffffe;
 if address<$400000 then result:=(word(cart_byte(address)) shl 8) or cart_byte(address+1)
    else if address>=$e00000 then result:=ram[(address and $ffff) shr 1]
            else result:=$ffff;
end;

function genesis_getword(direccion:dword):word;
var
  a:dword;b:byte;
begin
 result:=$ffff;
 a:=direccion and $fffffe;
 case a of
  0..$3fffff:begin
    result:=(word(cart_byte(a)) shl 8) or cart_byte(a+1);
    // The dump lock observes byte cycles in the second 64 KiB region.
    // Return this read from the boot mirror, then expose the full ROM.
    if cart_pier_solar and (pier_unlock_reads<>0) and (a>=$10000) and (a<$20000) and (m68000_0.read_8bits_hi_dir or m68000_0.read_8bits_lo_dir) then dec(pier_unlock_reads);
  end;
  $400000:if cart_sbb_protection then result:=(genesis_open_bus and $ff) or $5500;
  $400002:if cart_sbb_protection then result:=(genesis_open_bus and $ff) or $0f00;
  $a00000..$a0ffff:if not z80_has_bus then result:=(word(genesis_snd_getbyte(a and $7fff)) shl 8) or genesis_snd_getbyte((a+1) and $7fff);
  $a10000..$a1001f:begin
                    b:=(a and $1f) shr 1;
                    if b in[1,2,3] then b:=pad_read(b)
                      else b:=io_control[b];
                    result:=word(b)*$101;
                   end;
  $a13000..$a130fe:if cart_pier_solar then begin
                      result:=0;
                      if (a and $0e)=$0a then result:=pier_spi.outbit;
                   end;
  $a11100..$a11101:begin
    // BUSACK drives D8 only. Other data pins retain the 68000 bus value.
    result:=genesis_open_bus and $feff;
    if z80_has_bus or z80_is_reset then result:=result or $100;
  end;
  $a11200..$a11201:result:=byte(not z80_is_reset) shl 8;
  $c00000..$c0001f:begin
                      vdp_5313_0.set_hpos(slice_number*428+(m68000_0.contador mod 61)*7);
                      result:=vdp_5313_0.read(a and $1e);
                   end;
  $e00000..$ffffff:result:=ram[(a and $ffff)shr 1];
 end;
end;

procedure genesis_putword(direccion:dword;valor:word);
var
  a:dword;b:byte;state:boolean;
begin
 a:=direccion and $fffffe;
 case a of
  0..$3ffffe:begin
                if not m68000_0.write_8bits_hi_dir then cart_write(a,valor shr 8);
                if not m68000_0.write_8bits_lo_dir then cart_write(a+1,valor and $ff);
             end;
  $a00000..$a0fffe:if not z80_has_bus then begin
                      if not m68000_0.write_8bits_hi_dir then genesis_snd_putbyte(a and $7fff,valor shr 8);
                      if not m68000_0.write_8bits_lo_dir then genesis_snd_putbyte((a+1)and $7fff,valor and $ff);
                   end;
  $a10000..$a1001e:if not m68000_0.write_8bits_lo_dir then begin
                      b:=(a and $1f) shr 1;
                      if b<>0 then io_control[b]:=valor and $ff;
                   end;
  $a11100:if not m68000_0.write_8bits_hi_dir then z80_has_bus:=(valor and $100)=0;
  $a11200:if not m68000_0.write_8bits_hi_dir then begin
   state:=(valor and $100)=0;
   if state and not z80_is_reset then begin
      z80_0.reset;
      ym2612_0.reset;
   end;
   z80_is_reset:=state;
  end;
  $a13000..$a130ee:if cart_pier_solar and not m68000_0.write_8bits_lo_dir then pier_register_write(a+1,valor and $ff);
  $a130f0:if cart_pier_solar then begin
            if not m68000_0.write_8bits_lo_dir then pier_register_write(a+1,valor and $ff);
          end else if not m68000_0.write_8bits_lo_dir then begin
            save_enabled:=(valor and 1)<>0;
            save_readonly:=(valor and 2)<>0;
          end;
  $a130f2..$a130fe:if cart_pier_solar then begin
                      if not m68000_0.write_8bits_lo_dir then pier_register_write(a+1,valor and $ff);
                   end else if cart_ssf2_mapper and not m68000_0.write_8bits_lo_dir then cart_banks[(a-$a130f0) shr 1]:=valor and $0f;
  $a14000..$a14002:; // TMSS signature; no BIOS lockout is emulated.
  $c00000..$c0001e:begin
   // VDP byte writes replicate the active byte. PSG only sees the low lane.
   if (a and $1f)>=$10 then begin
    if not m68000_0.write_8bits_lo_dir then vdp_5313_0.write(a and $1e,valor and $ff);
   end else begin
    if m68000_0.write_8bits_lo_dir then valor:=word(valor shr 8)*$101
     else if m68000_0.write_8bits_hi_dir then valor:=word(valor and $ff)*$101;
    vdp_5313_0.write(a and $1e,valor);
   end;
  end;
  $e00000..$fffffe:ram[(a and $ffff)shr 1]:=valor;
 end;
end;

function dma_read(address:dword):word;
begin
 // DMA never invokes the CPU's byte-access flags or VDP port side effects.
 address:=address and $fffffe;
 if address<$400000 then result:=(word(cart_byte(address))shl 8) or cart_byte(address+1)
    else if address>=$e00000 then result:=ram[(address and $ffff) shr 1]
            else result:=$ffff;
end;

procedure genesis_irq_ack(level:byte);
begin
 vdp_5313_0.irq_ack(level);
end;

procedure genesis_irq2(state:boolean);
begin
 if state then m68000_0.change_irq_level(2,ASSERT_LINE)
    else m68000_0.change_irq_level(2,CLEAR_LINE);
end;

procedure genesis_irq4(state:boolean);
begin
  if state then m68000_0.change_irq_level(4,ASSERT_LINE)
    else m68000_0.change_irq_level(4,CLEAR_LINE);
end;

procedure genesis_irq6(state:boolean);
begin
  if state then m68000_0.change_irq_level(6,ASSERT_LINE)
    else m68000_0.change_irq_level(6,CLEAR_LINE);
end;

procedure genesis_sound_irq(state:boolean);
begin
  if state then z80_0.change_irq(ASSERT_LINE)
      else z80_0.change_irq(CLEAR_LINE);
end;

procedure sound_update;
begin
 ym2612_0.update;
 vdp_5313_0.sound_update;
end;

procedure reset_genesis;
var
  f:byte;
begin
 reset_cartridge;
 save_enabled:=(Length(save_ram)>0) and (dword(Length(rom))<=save_start);
 fillchar(ram,SizeOf(ram),0);
 fillchar(zram,SizeOf(zram),0);
 fillchar(io_control,SizeOf(io_control),0);
 io_control[0]:=$20 or genesis_region_bits; // no Mega CD; hardware revision 0
 for f:=1 to 3 do io_control[f]:=$7f;
 io_control[7]:=$ff;
 io_control[10]:=$ff;
 io_control[13]:=$ff;
 z80_bank:=0;
 z80_is_reset:=true;
 z80_has_bus:=true;
 frame_main:=0;
 frame_snd:=0;
 dma_debt:=0;
 line_number:=0;
 slice_number:=0;
 m68000_0.reset;
 z80_0.reset;
 ym2612_0.reset;
 vdp_5313_0.reset;
 reset_audio;
end;

function abrir_cartucho(datos:pbyte;longitud:integer):boolean;
function cartridge_region(datos:pbyte):byte;
var
  region:string;
  i,mask,n:integer;
  c:char;
begin
 region:='';
 for i:=$1f0 to $1ff do if datos[i]<>0 then region:=region+UpCase(Char(datos[i]));
 region:=Trim(region);
 if(region='JAPAN')or(region='JPN')then region:='J'
    else if(region='USA')or(region='US')then region:='U'
          else if(region='EUROPE')or(region='EUR')then region:='E';
 mask:=0;
 // Old headers list J/U/E; newer headers can use a hexadecimal region mask.
 for i:=1 to Length(region)do begin
  c:=region[i];n:=0;
  case c of
   'J':n:=1; // domestic NTSC
   'U':n:=4; // overseas NTSC
   'E':n:=8; // overseas PAL (legacy letter takes precedence over hex E)
   '0'..'9':n:=Ord(c)-Ord('0');
   'A'..'D','F':n:=Ord(c)-Ord('A')+10;
  end;
  mask:=mask or n;
 end;
 // Preserve USA preference for world/USA-compatible releases.
 if (mask and 4)<>0 then result:=$80
  else if(mask and 1)<>0 then result:=0
        else if(mask and 8)<>0 then result:=$c0
              else if(mask and 2)<>0 then result:=$40
                    else result:=$80; // unknown header: historical USA default
end;
procedure genesis_set_menacer(enabled:boolean;h_offset,v_offset:integer);
begin
  menacer_enabled:=enabled;
  menacer_h_offset:=h_offset;
  menacer_v_offset:=v_offset;
  init_mouse(enabled);
  vdp_5313_0.lightgun_disable;
end;
procedure detect_menacer(datos:pbyte);
var
  title:ansistring;
  compact:string;
  i:integer;
begin
 SetString(title,PAnsiChar(@datos[$150]),48);
 compact:='';
 for i:=1 to Length(title) do
    if UpCase(title[i]) in ['A'..'Z','0'..'9'] then compact:=compact+UpCase(title[i]);
 if Pos('MENACER',compact)>0 then genesis_set_menacer(true,$52,0)
    else if Pos('BODYCOUNT',compact)>0 then genesis_set_menacer(true,$44,-16)
            else if (Pos('T2ARCADEGAME',compact)>0) or (Pos('T2THEARCADEGAME',compact)>0) then genesis_set_menacer(true,$84,-8)
                    else genesis_set_menacer(false,0,0);
end;
function header_long(datos:pbyte;offset:integer):dword;
begin
  result:=(dword(datos[offset]) shl 24) or (dword(datos[offset+1]) shl 16) or (dword(datos[offset+2]) shl 8) or datos[offset+3];
end;
var
    new_region:byte;
    temps:ansistring;
    long:integer;
    master_clock:cardinal;
    pier_save_path:string;
begin
  result:=false;
  //Grabo los datos de NVRAM o eeprom
  close_cartridge;
  //Dejo por defecto NTSC, si luego es PAL, lo cambio
  master_clock:=53693175;
  llamadas_maquina.scanlines:=262;
  llamadas_maquina.fps_max:=master_clock/(3420*llamadas_maquina.scanlines);
  change_video_clock(llamadas_maquina.fps_max);
  m68000_0.clock:=master_clock div 7;
  z80_0.clock:=master_clock div 15;
  sound_engine_change_clock(m68000_0.clock);
  ym2612_0.change_clock(m68000_0.clock);
  vdp_5313_0.set_region(false);
  m68000_0.tframes:=3420/7;
  z80_0.tframes:=3420/15;
  //Empiezo a leer el cartucho
  if (longitud<$200) or (longitud>MAX_CARTRIDGE) then raise Exception.Create('Se admiten cartuchos BIN/MD sin cabecera, de 512 bytes a 8 MiB.');
  if (datos[$100]<>byte('S')) or (datos[$101]<>byte('E')) or (datos[$102]<>byte('G')) or (datos[$103]<>byte('A')) then begin
    //Sin cabecera, lo dejo como NTSC y lo cargo directo
    SetLength(rom,longitud);
    copymemory(@rom[0],datos,longitud);
    reset_genesis;
    result:=true;
    exit;
  end;
  if (header_long(datos,4)>=longitud) or ((header_long(datos,4) and 1)<>0) then
    raise Exception.Create('Vector de arranque fuera del cartucho o desalineado.');
  new_region:=cartridge_region(datos);
  case calc_crc(datos,longitud) of
      //eeprom x24c01
    $85C956EF,$dcf6e8b2,$1592F5B0,$45A50F96,$41FCC497:begin
      x24c01_0:=x24c01_chip.create;
      x24c01_0.load_data(ChangeFileExt(cart_name,'.nv'));
      eeprom:=true;
    end else begin
      //NVram
      if (datos[$1b0]=byte('R')) and (datos[$1b1]=byte('A')) then begin
          save_start:=header_long(datos,$1b4) and $ffffff;
          save_end:=header_long(datos,$1b8) and $ffffff;
          if (save_end>=save_start) and (save_end<MAX_CARTRIDGE) and (save_end-save_start<$20000) then begin
              if (save_start and 1)=(save_end and 1) then save_step:=2;
              setlength(save_ram,(save_end-save_start) div save_step+1);
              if read_file_size(Directory.Arcade_nvram+ChangeFileExt(cart_name,'.nv'),long) then begin
                  read_file(Directory.Arcade_nvram+ChangeFileExt(cart_name,'.nv'),@save_ram[0],long);
              end else fillchar(save_ram[0],Length(save_ram),$ff);
          end;
      end;
    end;
  end;
  detect_menacer(datos);
  //Copio el cartucho
  SetLength(rom,longitud);
  copymemory(@rom[0],datos,longitud);
  //Proteccion SSF2
  SetString(temps,PAnsiChar(@datos[$120]),48);
  cart_ssf2_mapper:=(Pos('SUPER STREET FIGHTER2',string(temps))>0) or (Pos('OVERDRIVE 2',string(temps))>0);
  //Proteccion Pier Solar
  cart_pier_solar:=Pos('PIER SOLAR',string(temps))>0;
  if cart_pier_solar then begin
    pier_unlock_reads:=3;
    pier_save_path:=Directory.Arcade_nvram+ChangeFileExt(cart_name,'.nv');
    SetLength(save_ram,$10000);
    save_enabled:=false;
    if read_file_size(pier_save_path,long) then begin
      if long>Length(save_ram) then long:=Length(save_ram);
      if long>0 then read_file(pier_save_path,@save_ram[0],long);
    end else fillchar(save_ram[0],Length(save_ram),$ff);
  end;
  //Super Bubble Bobble
  cart_sbb_protection:=calc_crc(datos,longitud)=$4820a161;
  //Region
  genesis_region_bits:=new_region;
  genesis_pal:=(genesis_region_bits and $40)<>0;
  if genesis_pal then begin
    master_clock:=53203424;
    llamadas_maquina.scanlines:=313;
    llamadas_maquina.fps_max:=master_clock/(3420*llamadas_maquina.scanlines);
    change_video_clock(llamadas_maquina.fps_max);
    m68000_0.clock:=master_clock div 7;
    z80_0.clock:=master_clock div 15;
    sound_engine_change_clock(m68000_0.clock);
    ym2612_0.change_clock(m68000_0.clock);
    vdp_5313_0.set_region(true);
  end;
  result:=true;
end;

procedure abrir_genesis;
var
  extension,RomFile:string;
  datos:pbyte;
  longitud:integer;
begin
  if not(openrom(romfile,SGENESIS)) then exit;
  getmem(datos,MAX_CARTRIDGE);
  if not(extract_data(romfile,datos,longitud,cart_name,SGENESIS)) then begin
    freemem(datos);
    exit;
  end;
  extension:=extension_fichero(cart_name);
  if ((extension='BIN') or (extension='MD') or (extension='GEN')) then begin
    if abrir_cartucho(datos,longitud) then reset_genesis;
  end;
  freemem(datos);
  main_vars.nombre_caption:=cart_name;
  change_caption;
  directory.genesis:=ExtractFilePath(romfile);
end;

procedure cerrar_genesis;
begin
 save_cartridge;
 SetLength(rom,0);
 SetLength(save_ram,0);
end;

function iniciar_genesis:boolean;
var
  master_clock:cardinal;
begin
 result:=false;
 menacer_enabled:=false;
 eeprom:=false;
 principal1.BitBtn10.Glyph:=nil;
 principal1.imagelist2.GetBitmap(4,principal1.BitBtn10.Glyph);
 llamadas_maquina.bucle_general:=genesis_principal;
 llamadas_maquina.close:=cerrar_genesis;
 llamadas_maquina.reset:=reset_genesis;
 llamadas_maquina.cartuchos:=abrir_genesis;
 cart_sbb_protection:=false;
 cart_ssf2_mapper:=false;
 cart_pier_solar:=false;
 pier_unlock_reads:=0;
 genesis_pal:=false;
 genesis_region_bits:=$80;
 master_clock:=53693175;
 llamadas_maquina.scanlines:=262;
 llamadas_maquina.fps_max:=master_clock/(3420*262);
 iniciar_audio(true);
 m68000_0:=cpu_m68000.create(master_clock div 7);
 m68000_0.change_ram16_calls(genesis_getword,genesis_putword);
 m68000_0.change_irq_ack_call(genesis_irq_ack);
 z80_0:=cpu_z80.create(master_clock div 15);
 z80_0.change_ram_calls(genesis_snd_getbyte,genesis_snd_putbyte);
 // Audio clocks must continue while the Z80 is reset or its bus is requested.
 m68000_0.init_sound(sound_update);
 ym2612_0:=ym2612_chip.create(master_clock div 7);
 vdp_5313_0:=vdp_5313_chip.create(false);
 vdp_5313_0.change_irqs(genesis_sound_irq,genesis_irq4,genesis_irq6);
 vdp_5313_0.change_dma_reader(dma_read);
 vdp_5313_0.change_lightgun_irq(genesis_irq2);
 if main_vars.console_init then abrir_genesis;
 result:=true;
end;

end.
