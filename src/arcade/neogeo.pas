unit neogeo;

interface
uses rom_engine;

const
 //BIOS
 bios_program:tipo_roms=(n:'sp-s2.sp1';l:$20000;p:0;crc:$9036d879);
 bios_fixed:tipo_roms=(n:'sfix.sfix';l:$20000;p:0;crc:$c2ea0cfd);
 bios_sound:tipo_roms=(n:'sm1.sm1';l:$20000;p:0;crc:$94416d67);
 bios_zoom:array[0..1] of tipo_roms=((n:'000-lo.lo';l:$20000;p:0;crc:$5a86cff2),());
 //Metal Slug
 mslug_rom:tipo_roms=(n:'201-p1.bin';l:$200000;p:0;crc:$08d8daa5);
 mslug_sound:tipo_roms=(n:'201-m1.bin';l:$20000;p:0;crc:$c28b3253);
 mslug_fixed:tipo_roms=(n:'201-s1.bin';l:$20000;p:0;crc:$2f55958d);
 mslug_samples:array[0..1] of tipo_roms=(
 (n:'201-v1.bin';l:$400000;p:0;crc:$23d22ed1),(n:'201-v2.bin';l:$400000;p:$400000;crc:$472cf9db));
 mslug_graphics:array[0..4] of tipo_roms=(
 (n:'201-c1.bin';l:$400000;p:0;crc:$72813676),(n:'201-c2.bin';l:$400000;p:1;crc:$96f62574),
 (n:'201-c3.bin';l:$400000;p:$800000;crc:$5121456a),(n:'201-c4.bin';l:$400000;p:$800001;crc:$f4ad59a3),());
 //Metal Slug 2
 mslug2_rom:array[0..1] of tipo_roms=(
 (n:'241-p1.p1';l:$100000;p:0;crc:$2a53c5da),(n:'241-p2.sp2';l:$200000;p:$100000;crc:$38883f44));
 mslug2_sound:tipo_roms=(n:'241-m1.m1';l:$20000;p:0;crc:$94520ebd);
 mslug2_fixed:tipo_roms=(n:'241-s1.s1';l:$20000;p:0;crc:$f3d32f0f);
 mslug2_samples:array[0..1] of tipo_roms=(
 (n:'241-v1.v1';l:$400000;p:0;crc:$99ec20e8),(n:'241-v2.v2';l:$400000;p:$400000;crc:$ecb16799));
 mslug2_graphics:array[0..4] of tipo_roms=(
 (n:'241-c1.c1';l:$800000;p:0;crc:$394b5e0d),(n:'241-c2.c2';l:$800000;p:1;crc:$e5806221),
 (n:'241-c3.c3';l:$800000;p:$1000000;crc:$9f6bfa6f),(n:'241-c4.c4';l:$800000;p:$1000001;crc:$7d3e306f),());
 //KOF94
 kof94_rom:tipo_roms=(n:'055-p1.p1';l:$200000;p:0;crc:$f10a2042);
 kof94_sound:tipo_roms=(n:'055-m1.m1';l:$20000;p:0;crc:$f6e77cf5);
 kof94_fixed:tipo_roms=(n:'055-s1.s1';l:$20000;p:0;crc:$825976c1);
 kof94_samples:array[0..2] of tipo_roms=(
 (n:'055-v1.v1';l:$200000;p:0;crc:$8889596d),(n:'055-v2.v2';l:$200000;p:$200000;crc:$25022b27),
 (n:'055-v3.v3';l:$200000;p:$400000;crc:$83cf32c0));
 kof94_graphics:array[0..8] of tipo_roms=(
 (n:'055-c1.c1';l:$200000;p:0;crc:$b96ef460),(n:'055-c2.c2';l:$200000;p:1;crc:$15e096a7),
 (n:'055-c3.c3';l:$200000;p:$400000;crc:$54f66254),(n:'055-c4.c4';l:$200000;p:$400001;crc:$0b01765f),
 (n:'055-c5.c5';l:$200000;p:$800000;crc:$ee759363),(n:'055-c6.c6';l:$200000;p:$800001;crc:$498da52c),
 (n:'055-c7.c7';l:$200000;p:$c00000;crc:$62f66888),(n:'055-c8.c8';l:$200000;p:$c00001;crc:$fe0a235d),());
 //Viewpoint
 viewpoint_rom:tipo_roms=(n:'051-p1.p1';l:$100000;p:0;crc:$17aa899d);
 viewpoint_sound:tipo_roms=(n:'051-m1.m1';l:$20000;p:0;crc:$8e69f29a);
 viewpoint_fixed:tipo_roms=(n:'051-s1.s1';l:$20000;p:0;crc:$9fea5758);
 viewpoint_samples:array[0..1] of tipo_roms=(
 (n:'051-v2.v1';l:$200000;p:0;crc:$019978b6),(n:'051-v4.v2';l:$200000;p:$200000;crc:$5758f38c));
 viewpoint_graphics:array[0..2] of tipo_roms=(
 (n:'051-c1.c1';l:$200000;p:0;crc:$d624c132),(n:'051-c2.c2';l:$200000;p:1;crc:$40d69f1e),());
 //Metal Slug X
 mslugx_rom:array[0..1] of tipo_roms=(
 (n:'250-p1.p1';l:$100000;p:0;crc:$81f1f60b),(n:'250-p2.ep1';l:$400000;p:$100000;crc:$1fda2e12));
 mslugx_sound:tipo_roms=(n:'250-m1.m1';l:$20000;p:0;crc:$fd42a842);
 mslugx_fixed:tipo_roms=(n:'250-s1.s1';l:$20000;p:0;crc:$fb6f441d);
 mslugx_samples:array[0..2] of tipo_roms=(
 (n:'250-v1.v1';l:$400000;p:0;crc:$c79ede73),(n:'250-v2.v2';l:$400000;p:$400000;crc:$ea9aabe1),
 (n:'250-v3.v3';l:$200000;p:$800000;crc:$2ca65102));
 mslugx_graphics:array[0..6] of tipo_roms=(
 (n:'250-c1.c1';l:$800000;p:0;crc:$09a52c6f),(n:'250-c2.c2';l:$800000;p:1;crc:$31679821),
 (n:'250-c3.c3';l:$800000;p:$1000000;crc:$fd602019),(n:'250-c4.c4';l:$800000;p:$1000001;crc:$31354513),
 (n:'250-c5.c5';l:$800000;p:$2000000;crc:$a4b56124),(n:'250-c6.c6';l:$800000;p:$2000001;crc:$83e3e69d),());

function iniciar_neogeo:boolean;

implementation
uses SysUtils,main_engine,controls_engine,m68000,nz80,cpu_misc,sound_engine,
     ym_2610,neogeo_video,file_engine;

const
    neogeo_dip:array[0..4] of def_dip2=(
    (mask:1;name:'Setting Mode';number:2;val2:(1,0);name2:('Off','On')),
    (mask:2;name:'Cabinet';number:2;val2:(2,0);name2:('Normal','VS Mode')),
    (mask:4;name:'Controller';number:2;val2:(4,0);name2:('Joystick','Mahjong Panel')),
    (mask:$40;name:'Free_Play';number:2;val2:($40,0);name2:('Off','On')),
    (mask:$80;name:'Freeze';number:2;val2:($80,0);name2:('Off','On')));

var
 program_rom:array[0..$4fffff] of word;
 bios_rom:array[0..$ffff] of word;
 work_ram,backup_ram:array[0..$7fff] of word;
 audio_rom,audio_bios:array[0..$1ffff] of byte;
 audio_ram:array[0..$7ff] of byte;
 audio_banks:array[0..3] of byte;
 use_vectors,use_audio,backup_unlock,nmi_enabled,sound_pending:boolean;
 sound_command,sound_result:byte;
 program_bank,rom_size,watchdog:integer;
 scanline,subline,frame_number:integer;
 video_control:word;display_counter:cardinal;raster_remaining:int64;
 irq1,irq2,irq3:byte;
 //Proteccion
 command,counter:word;

procedure update_irq;
begin
 m68000_0.change_irq_level(1,irq1);
 m68000_0.change_irq_level(2,irq2);
 m68000_0.change_irq_level(3,irq3);
end;

procedure update_nmi;
begin
  if (nmi_enabled and sound_pending) then z80_0.change_nmi(ASSERT_LINE)
    else z80_0.change_nmi(CLEAR_LINE);
end;

procedure eventos_neogeo;
begin
if event.arcade then begin
  marcade.in0:=$ff00;
  marcade.in1:=$ffff;
  marcade.in2:=$ffff;
  marcade.in3:=$3f;
  //P1
  if arcade_input.up[0] then marcade.in0:=marcade.in0 and $feff;
  if arcade_input.down[0] then marcade.in0:=marcade.in0 and $fdff;
  if arcade_input.left[0] then marcade.in0:=marcade.in0 and $fbff;
  if arcade_input.right[0] then marcade.in0:=marcade.in0 and $f7ff;
  if arcade_input.but0[0] then marcade.in0:=marcade.in0 and $efff;
  if arcade_input.but1[0] then marcade.in0:=marcade.in0 and $dfff;
  if arcade_input.but2[0] then marcade.in0:=marcade.in0 and $bfff;
  if arcade_input.but3[0] then marcade.in0:=marcade.in0 and $7fff;
  //P2
  if arcade_input.up[1] then marcade.in1:=marcade.in1 and $feff;
  if arcade_input.down[1] then marcade.in1:=marcade.in1 and $fdff;
  if arcade_input.left[1] then marcade.in1:=marcade.in1 and $fbff;
  if arcade_input.right[1] then marcade.in1:=marcade.in1 and $f7ff;
  if arcade_input.but0[1] then marcade.in1:=marcade.in1 and $efff;
  if arcade_input.but1[1] then marcade.in1:=marcade.in1 and $dfff;
  if arcade_input.but2[1] then marcade.in1:=marcade.in1 and $bfff;
  if arcade_input.but3[1] then marcade.in1:=marcade.in1 and $7fff;
  //Start
  if arcade_input.start[0] then marcade.in2:=marcade.in2 and $feff;
  if arcade_input.start[1]then marcade.in2:=marcade.in2 and $fbff;
  //Coins
  if arcade_input.coin[0] then marcade.in3:=marcade.in3 and $fe;
  if arcade_input.coin[1] then marcade.in3:=marcade.in3 and $fd;
end;
end;

{$INCLUDE misc/neogeo_rtc.inc}

function neogeo_getword(direccion:dword):word;
var
  v:integer;
begin
 case direccion of
  0..$fffff:if ((direccion<$80) and not(use_vectors)) then result:=bios_rom[direccion shr 1]
              else result:=program_rom[direccion shr 1];
  $100000..$1fffff:result:=work_ram[(direccion and $ffff) shr 1];
  $200000..$2fffff:result:=program_rom[(program_bank+(direccion and $fffff)) shr 1];
  $300000..$31ffff:if (direccion and $80)=0 then result:=marcade.in0 or marcade.dswa;
  $320000..$33ffff:begin
                      rtc_sync;
                      result:=((sound_result) shl 8) or marcade.in3 or byte(rtc_tp)*$40 or byte(rtc_data)*$80;
                   end;
  $340000..$35ffff:result:=marcade.in1;
  $380000..$39ffff:result:=marcade.in2;
  $3c0000..$3dffff:if not m68000_0.read_8bits_hi_dir and not(m68000_0.write_8bits_hi_dir or m68000_0.write_8bits_lo_dir) then
                      case (direccion and 6) of
                        0,2:result:=nvideo_0.read_buffer;
                        4:result:=nvideo_0.modulo;
                        6:begin
                            v:=scanline+$100;
                            if v>=$200 then dec(v,264);
                            result:=word((v shl 7) or (nvideo_0.ng_animation and 7));
                          end;
                      end;
  $400000..$7fffff:result:=nvideo_0.ng_palette[nvideo_0.ng_palette_bank+((direccion and $1fff) shr 1)];
  $c00000..$cfffff:result:=bios_rom[(direccion and $1ffff) shr 1];
  $d00000..$dfffff:result:=backup_ram[(direccion and $ffff) shr 1];
 end;
end;

procedure neogeo_putword(direccion:dword;valor:word);
var
  state:boolean;
begin
 case direccion of
  $100000..$1fffff:work_ram[(direccion and $ffff) shr 1]:=valor;
  $2ffff0..$2fffff:begin
                      program_bank:=((valor and 7)+1)*$100000;
                      if program_bank>=rom_size then program_bank:=$100000;
                   end;
  $300000..$31ffff:if not(m68000_0.write_8bits_lo_dir) then watchdog:=0;
  $320000..$33ffff:if not(m68000_0.write_8bits_hi_dir) then begin
                      sound_command:=valor shr 8;
                      sound_pending:=true;
                      update_nmi;
                   end;
  $380000..$39ffff:if not(m68000_0.write_8bits_lo_dir) and ((direccion and $f0)=$50) then rtc_write(valor);
  $3a0000..$3bffff:if not(m68000_0.write_8bits_lo_dir) then begin
                      state:=((direccion shr 4) and 1)<>0;
                      case ((direccion and $e) shr 1) of
                        0:nvideo_0.ng_shadow:=state;
                        1:use_vectors:=state;
                        5:begin
                            use_audio:=state;
                            nvideo_0.ng_fix_source:=use_audio;
                          end;
                        6:backup_unlock:=state;
                        7:nvideo_0.ng_palette_bank:=byte(state)*$1000;
                      end;
                   end;
  $3c0000..$3dffff:if not(m68000_0.write_8bits_hi_dir) then begin
                      if m68000_0.write_8bits_lo_dir then valor:=(valor and $ff00) or (valor shr 8);
                      case(direccion and $e) of
                          0:nvideo_0.vram_address(valor);
                          2:nvideo_0.vram_write(valor);
                          4:nvideo_0.modulo:=valor;
                          6:begin
                              video_control:=valor;
                              nvideo_0.ng_animation_speed:=valor shr 8;
                              nvideo_0.ng_animation_disabled:=(valor and 8)<>0;
                            end;
                          8:display_counter:=(display_counter and $ffff) or (valor shl 16);
                          10:begin
                              display_counter:=(display_counter and $ffff0000) or valor;
                              if (video_control and $20)<>0 then raster_remaining:=int64(display_counter)+1;
                             end;
                          12:begin
                                if (valor and 1)<>0 then irq3:=CLEAR_LINE;
                                if (valor and 2)<>0 then irq2:=CLEAR_LINE;
                                if (valor and 4)<>0 then irq1:=CLEAR_LINE;
                                update_irq;
                             end;
                      end;
                   end;
  $400000..$7fffff:nvideo_0.palette_write(nvideo_0.ng_palette_bank+((direccion and $1fff) shr 1),valor);
  $d00000..$dfffff:if backup_unlock then backup_ram[(direccion and $ffff) shr 1]:=valor;
 end;
end;

function sound_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff:if use_audio then result:=audio_rom[direccion]
              else result:=audio_bios[direccion];
  $8000..$bfff:result:=audio_rom[((integer(audio_banks[3]) shl 14)+(direccion-$8000)) and $1ffff];
  $c000..$dfff:result:=audio_rom[((integer(audio_banks[2]) shl 13)+(direccion-$c000)) and $1ffff];
  $e000..$efff:result:=audio_rom[((integer(audio_banks[1]) shl 12)+(direccion-$e000)) and $1ffff];
  $f000..$f7ff:result:=audio_rom[((integer(audio_banks[0]) shl 11)+(direccion-$f000)) and $1ffff];
  $f800..$ffff:result:=audio_ram[direccion and $7ff];
end;
end;

procedure sound_putbyte(direccion:word;valor:byte);
begin
  if direccion>=$f800 then audio_ram[direccion and $7ff]:=valor;
end;

function sound_inbyte(puerto:word):byte;
begin
 result:=$ff;
 case (puerto and $ff)of
  0:begin
      result:=sound_command;
      sound_pending:=false;
      update_nmi;
    end;
  4..7:result:=ym2610_0.read_port(puerto and 3);
  else if (puerto and $f) in [8..11] then begin
          audio_banks[puerto and 3]:=puerto shr 8;
          result:=0;
       end;
 end;
end;

procedure sound_outbyte(puerto:word;valor:byte);
begin
case (puerto and $ff) of
 0:begin
      sound_pending:=false;
      update_nmi;
   end;
 4..7:ym2610_0.write_port(puerto and 3,valor);
 8,$18:begin
          nmi_enabled:=(puerto and $10)=0;
          update_nmi;
       end;
 $c:sound_result:=valor;
end;
end;

procedure sound_irq(valor:byte);
begin
  z80_0.change_irq(valor);
end;

procedure sound_update;
begin
  ym2610_0.update;
end;

//MslugX
function mslugx_getword(direccion:dword):word;
var
  res,select:word;
begin
case direccion of
  $2fffe0..$2fffef:begin
                       res:=0;
                       case command of
                          1:begin
                              res:=(m68000_0.getbyte($dedd2+((counter shr 3) and $fff)) shr (not(counter) and 7)) and 1;
                              counter:=counter+1;
                            end;
                          $fff:begin
                                  select:=neogeo_getword($10f00a)-1; // How should this be calculated?
			                            res:=(m68000_0.getbyte($dedd2+((select shr 3) and $fff)) shr (not(select) and 7)) and 1;
                               end;
                       end;
                       mslugx_getword:=res;
                   end;
  else mslugx_getword:=neogeo_getword(direccion);
end;
end;

procedure mslugx_putword(direccion:dword;valor:word);
begin
case direccion of
  $2fffe0..$2fffef:begin
                      case (direccion and $f) shr 1 of
                          0:command:=0;
                          1,2:command:=command or valor;
                          3:;
                          5:begin
                              counter:=0;
                              command:=0;
                            end;
                      end;
                   end;
  else neogeo_putword(direccion,valor);
end;
end;

procedure reset_neogeo;
begin
 use_vectors:=false;
 use_audio:=false;
 backup_unlock:=false;
 program_bank:=$100000;
 nmi_enabled:=false;
 sound_pending:=false;
 sound_command:=0;
 sound_result:=0;
 audio_banks[0]:=$1e;
 audio_banks[1]:=$e;
 audio_banks[2]:=6;
 audio_banks[3]:=2;
 scanline:=0;
 subline:=0;
 frame_number:=0;
 frame_main:=0;
 frame_snd:=0;
 irq1:=CLEAR_LINE;
 irq2:=CLEAR_LINE;
 irq3:=CLEAR_LINE;
 video_control:=0;
 display_counter:=0;
 raster_remaining:=-1;
 reset_rtc;
 nvideo_0.reset;
 reset_audio;
 marcade.in0:=$ff00;
 marcade.in1:=$ffff;
 marcade.in2:=$ffff;
 marcade.in3:=$3f;
 //El metal slug 2 usa el WD como proteccion!
 watchdog:=0;
 //El orden es importante!
 m68000_0.reset;
 z80_0.reset;
 ym2610_0.reset;
 update_irq;
 //Proteccion
 counter:=0;
 command:=0;
end;

procedure neogeo_principal;
procedure neogeo_run_frame;
var
  chunk:byte;
begin
 for scanline:=0 to 263 do begin
  // Eight 48-pixel slices keep command/NMI latency bounded to 8 us.
  for chunk:=0 to 7 do begin
   subline:=chunk*48;
   if raster_remaining>=0 then begin
      dec(raster_remaining,48);
      if raster_remaining<=0 then begin
        if(video_control and $10)<>0 then begin
          irq2:=ASSERT_LINE;
          update_irq;
        end;
        if(video_control and $80)<>0 then inc(raster_remaining,int64(display_counter)+1)
          else raster_remaining:=-1;
      end;
   end;
   frame_main:=frame_main+96;
   m68000_0.run(frame_main);
   frame_main:=frame_main-m68000_0.contador;
   inc(rtc_elapsed,m68000_0.contador);
   frame_snd:=frame_snd+32;
   z80_0.run(frame_snd);
   frame_snd:=frame_snd-z80_0.contador;
  end;
  nvideo_0.video_line(scanline);
  if scanline=240 then begin
      irq1:=ASSERT_LINE;
      update_irq;
      if(video_control and $40)<>0 then raster_remaining:=int64(display_counter)+1;
  end;
 end;
 inc(frame_number);
 nvideo_0.video_frame;
 //El WD debe actual a los 135ms, o 2138 lineas o 8 frames
 inc(watchdog);
 if watchdog>8 then reset_neogeo;
end;
begin
  while EmuStatus=EsRunning do begin
    neogeo_run_frame;
    nvideo_0.video_present;
    eventos_neogeo;
    video_sync;
  end;
end;

procedure cerrar_neogeo;
var
  nombre:string;
begin
 case main_vars.tipo_maquina of
    430:nombre:='metalslug.nv';
    431:nombre:='metalslug2.nv';
    432:nombre:='kof94.nv';
    433:nombre:='viewpoint.nv';
    434:nombre:='metalslugx.nv';
 end;
 write_file(Directory.Arcade_nvram+nombre,@backup_ram[0],$8000*2);
 SetLength(nvideo_0.ng_sprites,0);
 setlength(ym2610_0.rom_a,0);
 setlength(ym2610_0.rom_b,0);
end;

function iniciar_neogeo:boolean;
var
  tempb:pbyte;
  longitud:integer;
  f:cardinal;
begin
 result:=false;
 llamadas_maquina.fps_max:=6000000/(384*264);
 llamadas_maquina.scanlines:=264;
 llamadas_maquina.bucle_general:=neogeo_principal;
 llamadas_maquina.reset:=reset_neogeo;
 llamadas_maquina.close:=cerrar_neogeo;
 iniciar_audio(true);
 //CPU
 m68000_0:=cpu_m68000.create(12000000);
 m68000_0.change_ram16_calls(neogeo_getword,neogeo_putword);
// Sound
 z80_0:=cpu_z80.create(4000000);
 z80_0.change_ram_calls(sound_getbyte,sound_putbyte);
 z80_0.change_io_calls(sound_inbyte,sound_outbyte);
 z80_0.init_sound(sound_update);
 ym2610_0:=ym2610_chip.create(8000000);
 ym2610_0.change_irq_calls(sound_irq);
 //Video
 nvideo_0:=tneogeo_video.create;
 //Bios de Neogeo
 if not roms_load(@audio_bios,bios_sound,true,true,'neogeo.zip')then exit;
 if not roms_load(@nvideo_0.ng_fix_bios[0],bios_fixed,true,true,'neogeo.zip')then exit;
 if not roms_load(@nvideo_0.ng_zoom[0],bios_zoom,true,true,'neogeo.zip')then exit;
 if not roms_load(@bios_rom,bios_program,true,true,'neogeo.zip') then exit;
 getmem(tempb,$4000000);
 case main_vars.tipo_maquina of
    430:begin //Metal Slug
          if not roms_load(tempb,mslug_rom) then begin
            freemem(tempb);
            exit;
          end;
          rom_size:=$200000;
          for f:=0 to $fffff do
            program_rom[f]:=tempb[((f*2) xor $100000)] or (word(tempb[((f*2) xor $100000)+1]) shl 8);
          if not roms_load(@audio_rom,mslug_sound) then exit;
          if not roms_load16b(tempb,mslug_graphics) then begin
            freemem(tempb);
            exit;
          end;
          nvideo_0.video_decode(tempb,$1000000);
          freemem(tempb);
          if not roms_load(@nvideo_0.ng_fix_cart[0],mslug_fixed)then exit;
          setlength(ym2610_0.rom_a,$800000);
          setlength(ym2610_0.rom_b,$800000);
          if not(roms_load(@ym2610_0.rom_a[0],mslug_samples)) then exit;
          copymemory(ym2610_0.rom_b,ym2610_0.rom_a,$800000);
          if read_file_size(Directory.Arcade_nvram+'metalslug.nv',longitud) then read_file(Directory.Arcade_nvram+'metalslug.nv',@backup_ram[0],longitud)
            else fillchar(backup_ram,$8000*2,0);
    end;
    431:begin //Metal Slug 2
          if not roms_load(@program_rom,mslug2_rom) then begin
            freemem(tempb);
            exit;
          end;
          rom_size:=$300000;
          if not roms_load(@audio_rom,mslug2_sound) then exit;
          if not roms_load16b(tempb,mslug2_graphics) then begin
            freemem(tempb);
            exit;
          end;
          nvideo_0.video_decode(tempb,$2000000);
          freemem(tempb);
          if not roms_load(@nvideo_0.ng_fix_cart[0],mslug2_fixed)then exit;
          setlength(ym2610_0.rom_a,$800000);
          setlength(ym2610_0.rom_b,$800000);
          if not(roms_load(@ym2610_0.rom_a[0],mslug2_samples)) then exit;
          copymemory(ym2610_0.rom_b,ym2610_0.rom_a,$800000);
          if read_file_size(Directory.Arcade_nvram+'metalslug2.nv',longitud) then read_file(Directory.Arcade_nvram+'metalslug2.nv',@backup_ram[0],longitud)
            else fillchar(backup_ram,$8000*2,0);
    end;
    432:begin //KOF94
          if not roms_load(tempb,kof94_rom) then begin
            freemem(tempb);
            exit;
          end;
          rom_size:=$200000;
          for f:=0 to $fffff do
            program_rom[f]:=tempb[((f*2) xor $100000)] or (word(tempb[((f*2) xor $100000)+1]) shl 8);
          if not roms_load(@audio_rom,kof94_sound) then exit;
          if not roms_load16b(tempb,kof94_graphics) then begin
            freemem(tempb);
            exit;
          end;
          nvideo_0.video_decode(tempb,$1000000);
          freemem(tempb);
          if not roms_load(@nvideo_0.ng_fix_cart[0],kof94_fixed)then exit;
          setlength(ym2610_0.rom_a,$800000);
          setlength(ym2610_0.rom_b,$800000);
          if not(roms_load(@ym2610_0.rom_a[0],kof94_samples)) then exit;
          copymemory(ym2610_0.rom_b,ym2610_0.rom_a,$800000);
          if read_file_size(Directory.Arcade_nvram+'kof94.nv',longitud) then read_file(Directory.Arcade_nvram+'kof94.nv',@backup_ram[0],longitud)
            else fillchar(backup_ram,$8000*2,0);
    end;
    433:begin //Viewpoint
          if not roms_load(@program_rom,viewpoint_rom) then begin
            freemem(tempb);
            exit;
          end;
          rom_size:=$100000;
          if not roms_load(@audio_rom,viewpoint_sound) then exit;
          if not roms_load16b(tempb,viewpoint_graphics) then begin
            freemem(tempb);
            exit;
          end;
          copymemory(@tempb[$400000],@tempb[$200000],$200000);
          nvideo_0.video_decode(tempb,$600000);
          freemem(tempb);
          if not roms_load(@nvideo_0.ng_fix_cart[0],viewpoint_fixed)then exit;
          setlength(ym2610_0.rom_a,$800000);
          setlength(ym2610_0.rom_b,$800000);
          if not(roms_load(@ym2610_0.rom_a[0],viewpoint_samples)) then exit;
          copymemory(ym2610_0.rom_b,ym2610_0.rom_a,$800000);
          if read_file_size(Directory.Arcade_nvram+'viewpoint.nv',longitud) then read_file(Directory.Arcade_nvram+'viewpoint.nv',@backup_ram[0],longitud)
            else fillchar(backup_ram,$8000*2,0);
    end;
    434:begin //Metal Slug X
          m68000_0.change_ram16_calls(mslugx_getword,mslugx_putword);
          if not roms_load(@program_rom,mslugx_rom) then begin
            freemem(tempb);
            exit;
          end;
          rom_size:=$500000;
          if not roms_load(@audio_rom,mslugx_sound) then exit;
          if not roms_load16b(tempb,mslugx_graphics) then begin
            freemem(tempb);
            exit;
          end;
          //Es importante la cantidad por la mascara!!!!
          nvideo_0.video_decode(tempb,$4000000);
          freemem(tempb);
          if not roms_load(@nvideo_0.ng_fix_cart[0],mslugx_fixed)then exit;
          setlength(ym2610_0.rom_a,$1000000);
          setlength(ym2610_0.rom_b,$1000000);
          if not(roms_load(@ym2610_0.rom_a[0],mslugx_samples)) then exit;
          copymemory(ym2610_0.rom_b,ym2610_0.rom_a,$1000000);
          if read_file_size(Directory.Arcade_nvram+'metalslugx.nv',longitud) then read_file(Directory.Arcade_nvram+'metalslugx.nv',@backup_ram[0],longitud)
            else fillchar(backup_ram,$8000*2,0);
    end;
 end;
 //Dips
 init_dips(1,neogeo_dip,$ff);
 result:=true;
end;

end.

