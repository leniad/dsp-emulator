unit pcengine;
interface

function iniciar_pcengine:boolean;

implementation
uses SysUtils,Classes,Dialogs,main_engine,cpu_misc,timer_engine,sound_engine,
     controls_engine,hu6280,pcengine_video,huc6280_audio,misc_functions,principal;

const
  PCE_CPU_CLOCK=7159090;
  PCE_PSG_CLOCK=3579545;
  PCE_MAX_ROM=$280000;

var
 rom:array of byte;
 ram:array[0..$1fff] of byte;
 cart_ram:array[0..$7fff] of byte;
 cart_has_ram:boolean;
 rom_banks:array[0..127] of integer;
 joy_select,joy_clear:boolean;
 joy_port:byte;
 sf2_bank:byte;
 io_bus:byte;
 joy_region:byte=0;

//procedure pcengine_set_region(turbografx:boolean);
//begin
//  if turbografx then joy_region:=0
//    else joy_region:=$40;
//end;

procedure pce_irq(state:boolean);
begin
  if state then h6280_0.set_irq_line(0,ASSERT_LINE)
    else h6280_0.set_irq_line(0,CLEAR_LINE);
end;

procedure pce_vdc_write(port:dword;value:byte);
begin
  pcevideo_0.vdc_write(port and 3,value);
end;

function eventos_pce:byte;
var
  joy:byte;
begin
 joy:=$f;
 // TurboTap hasta 5 mandos
 if joy_port<(NUM_PLAYERS+1) then
    if joy_select then begin
      if arcade_input.up[joy_port] then joy:=joy and $e;
      if arcade_input.right[joy_port] then joy:=joy and $d;
      if arcade_input.down[joy_port] then joy:=joy and $b;
      if arcade_input.left[joy_port] then joy:=joy and 7;
    end else begin
      if arcade_input.but0[joy_port] then joy:=joy and $e; // I
      if arcade_input.but1[joy_port] then joy:=joy and $d; // II
      if arcade_input.coin[joy_port] then joy:=joy and $b; // Select
      if arcade_input.start[joy_port] then joy:=joy and 7; // Run
    end;
 result:=$b0 or joy;
end;

procedure pcengine_principal;
var
  line,lines,lead,lead_x:integer;
  newfps:single;
begin
 while EmuStatus=EsRunning do begin
   lines:=pcevideo_0.total_lines;
   if llamadas_maquina.scanlines<>lines then begin
     llamadas_maquina.scanlines:=lines;
     newfps:=PCE_MASTER_CLOCK/(PCE_LINE_CLOCKS*lines);
     llamadas_maquina.fps_max:=newfps;
     change_video_clock(newfps);
   end;
   for line:=0 to lines-1 do begin
     pcevideo_0.scanline(line);
     // Sample BYR at the VDC latch point, not at the end of the line.
     lead:=pcevideo_0.scroll_latch_clock;
     frame_main:=frame_main+lead;
     h6280_0.run(frame_main);
     frame_main:=frame_main-h6280_0.contador;
     pcevideo_0.latch_scroll;
     // BXR latches shortly after BYR; preserve both for this row.
     lead_x:=pcevideo_0.horizontal_latch_clock;
     frame_main:=frame_main+lead_x-lead;
     h6280_0.run(frame_main);
     frame_main:=frame_main-h6280_0.contador;
     pcevideo_0.latch_horizontal;
     frame_main:=frame_main+376-lead_x;
     h6280_0.run(frame_main);
     frame_main:=frame_main-h6280_0.contador;
     pcevideo_0.hblank;
     frame_main:=frame_main+79;
     h6280_0.run(frame_main);
     frame_main:=frame_main-h6280_0.contador;
   end;
   pcevideo_0.present;
   evalue_controls;
   video_sync;
 end;
end;

function pcengine_getbyte(address:dword):byte;
var
  index:integer;
begin
 address:=address and $1fffff;
 result:=$ff;
 // Populous HuCard RAM occupies banks $40..$43, ahead of ROM mapping.
 if cart_has_ram and (address>=$80000) and (address<$88000) then result:=cart_ram[address-$80000]
 else if address<$100000 then begin
   index:=rom_banks[address shr 13]+integer(address and $1fff);
   if (Length(rom)>$100000) and (address>=$80000) then index:=$80000+integer(sf2_bank)*$80000+integer(address and $7ffff);
   if (index>=0) and (index<Length(rom)) then result:=rom[index];
 end else if(address>=$1f0000) and (address<$1f8000) then result:=ram[address and $1fff]
 else if address>=$1fe000 then begin
   case address and $1c00 of
     0:result:=pcevideo_0.vdc_read(address and 3);
     $400:result:=pcevideo_0.vce_read(address and 7);
     $800:result:=io_bus;
     $c00:result:=h6280_0.timer_r;
     $1000:result:=eventos_pce or joy_region;
     $1400:result:=h6280_0.irq_status_r(address and 3);
     $1800,$1c00:result:=$ff;
   end;
   io_bus:=result;
 end;
end;

procedure pcengine_putbyte(address:dword;value:byte);
begin
 address:=address and $1fffff;
 if cart_has_ram and (address>=$80000) and (address<$88000) then cart_ram[address-$80000]:=value
 else if (address<$100000) and (Length(rom)>$100000) and (address>=$1ff0) and (address<=$1ff3) then sf2_bank:=address and 3
    else if(address>=$1f0000) and (address<$1f8000) then ram[address and $1fff]:=value
            else if address>=$1fe000 then begin
                    io_bus:=value;
                    case address and $1c00 of
                        0:pcevideo_0.vdc_write(address and 3,value);
                        $400:pcevideo_0.vce_write(address and 7,value);
                        $800:huc6280_psg_0.write(address and 15,value);
                        $c00:h6280_0.timer_w(address and 1,value);
                        $1000:begin
                                // CLR rising with SEL high restarts the scan at player 1.
                                // Otherwise each SEL rising edge selects the next port.
                                if ((value and 3)=3) and not joy_clear then joy_port:=0
                                  else if ((value and 1)<>0) and not joy_select then
                                          if joy_port<255 then inc(joy_port);
                                joy_select:=(value and 1)<>0;
                                joy_clear:=(value and 2)<>0;
                              end;
                        $1400:h6280_0.irq_status_w(address and 3,value);
                    end;
                 end;
end;

procedure sound_update;
begin
  huc6280_psg_0.update;
end;

procedure reset_pcengine;
begin
 joy_port:=0;
 joy_select:=false;
 joy_clear:=false;
 io_bus:=$ff;
 sf2_bank:=0;
 frame_main:=0;
 pcevideo_0.reset;
 huc6280_psg_0.reset;
 h6280_0.reset;
 reset_audio;
end;

function abrir_cartucho(data:pbyte;size:integer):boolean;
const
  PCE_POPULOUS_ID:array[0..7]of AnsiChar=('P','O','P','U','L','O','U','S');
var
    offset,i,pages,bank,base:integer;
    bit_reverse:array[0..255] of byte;
    b:byte;
    reset_plain,reset_reversed:word;
    reverse_rom:boolean;
begin
 result:=false;
 if (size and $1fff)=512 then offset:=512
  else offset:=0;
 size:=size-offset;
 if (size and $1fff)<>0 then raise Exception.Create('PC Engine: tamaño de cartucho incorrecto.');
 SetLength(rom,size);
 copymemory(@rom[0],@data[offset],size);
 // Some US dumps store D0..D7 reversed. Test the reset vector after
 // removing the copier header, before CPU reset and ROM bank setup.
 for i:=0 to 255 do begin
   b:=byte(((i and $55) shl 1) or ((i shr 1) and $55));
   b:=byte(((b and $33) shl 2) or ((b shr 2) and $33));
   bit_reverse[i]:=byte((b shl 4) or (b shr 4));
 end;
 reverse_rom:=(rom[$1fff]<$e0) and (bit_reverse[rom[$1fff]]>=$e0);
 // Some reversed dumps have a plausible reset vector in both formats.
 // In that ambiguous case, prefer the format whose reset entry is SEI.
 // TaleSpin's high vector byte is $e7 in both formats.
 if (rom[$1fff]>=$e0) and (bit_reverse[rom[$1fff]]>=$e0) then begin
   reset_plain:=word(rom[$1ffe]) or (word(rom[$1fff]) shl 8);
   reset_reversed:=word(bit_reverse[rom[$1ffe]]) or (word(bit_reverse[rom[$1fff]]) shl 8);
   reverse_rom:=(rom[reset_plain and $1fff]<>$78) and (bit_reverse[rom[reset_reversed and $1fff]]=$78);
 end;
 if reverse_rom then
   for i:=0 to size-1 do rom[i]:=bit_reverse[rom[i]];
 // Populous tiene 32Kb de RAM
 cart_has_ram:=CompareMem(@rom[$1f26],@PCE_POPULOUS_ID[0],8);
 fillchar(cart_ram,$8000,$ff);
 pages:=size div $2000;
 for i:=0 to $7f do begin
   bank:=i;
   // 384/768 KiB cards use an unpopulated ROM address line.
   if size=$60000 then begin
     if i<$40 then bank:=i and $1f
        else bank:=$20+(i and $f);
   end else if size=$c0000 then begin
     if i<$40 then bank:=i
        else bank:=$40+(i and $1f);
   end else begin
     base:=1;
     while base<pages do base:=base*2;
     bank:=i and(base-1);
     while bank>=pages do bank:=bank-(base div 2);
   end;
   rom_banks[i]:=bank*$2000;
 end;
 result:=true;
end;

procedure abrir_pcengine;
var
  extension,nombre_file,RomFile:string;
  datos:pbyte;
  longitud:integer;
begin
  if not(openrom(romfile,SPCENGINE)) then exit;
  getmem(datos,PCE_MAX_ROM);
  if not(extract_data(romfile,datos,longitud,nombre_file,SPCENGINE,PCE_MAX_ROM)) then begin
    freemem(datos);
    exit;
  end;
  if (longitud<8192) or (longitud>PCE_MAX_ROM+512) then begin
    raise Exception.Create('PC Engine: tamano de cartucho no admitido.');
    freemem(datos);
    exit;
  end;
  extension:=extension_fichero(nombre_file);
  if ((extension='PCE') or (extension='BIN')) then begin
    if abrir_cartucho(datos,longitud) then reset_pcengine;
  end;
  freemem(datos);
  main_vars.nombre_caption:=nombre_file;
  change_caption;
  directory.pcengine:=ExtractFilePath(romfile);
end;

procedure cerrar_pcengine;
begin
 SetLength(rom,0);
end;

function iniciar_pcengine:boolean;
begin
 result:=false;
 principal1.BitBtn10.Glyph:=nil;
 principal1.imagelist2.GetBitmap(4,principal1.BitBtn10.Glyph);
 llamadas_maquina.bucle_general:=pcengine_principal;
 llamadas_maquina.reset:=reset_pcengine;
 llamadas_maquina.close:=cerrar_pcengine;
 llamadas_maquina.cartuchos:=abrir_pcengine;
 llamadas_maquina.scanlines:=263;
 llamadas_maquina.fps_max:=PCE_MASTER_CLOCK/(PCE_LINE_CLOCKS*263);
 iniciar_audio(true);
 screen_init(1,PCE_MAX_WIDTH,240);
 iniciar_video(256,240);
 h6280_0:=cpu_h6280.create(PCE_CPU_CLOCK);
 h6280_0.change_ram_calls(pcengine_getbyte,pcengine_putbyte);
 h6280_0.change_io_calls(pce_vdc_write);
 h6280_0.init_sound(sound_update);
 huc6280_psg_0:=thuc6280_psg.create(PCE_PSG_CLOCK);
 pcevideo_0:=tpcengine_video.create(pce_irq);
 if main_vars.console_init then abrir_pcengine;
 result:=true;
end;

end.
