unit pang_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,kabuki_decript,main_engine,controls_engine,gfx_engine,rom_engine,
     pal_engine,oki6295,sound_engine,eeprom;

function iniciar_pang:boolean;

implementation
const
        //Pang
        pang_rom:array[0..1] of tipo_roms=(
        (n:'pang6.bin';l:$8000;p:0;crc:$68be52cd),(n:'pang7.bin';l:$20000;p:$10000;crc:$4a2e70f6));
        pang_oki:tipo_roms=(n:'bb1.bin';l:$20000;p:0;crc:$c52e5b8e);
        pang_sprites:array[0..1] of tipo_roms=(
        (n:'bb10.bin';l:$20000;p:0;crc:$fdba4f6e),(n:'bb9.bin';l:$20000;p:$20000;crc:$39f47a63));
        pang_char:array[0..3] of tipo_roms=(
        (n:'pang_09.bin';l:$20000;p:0;crc:$3a5883f5),(n:'bb3.bin';l:$20000;p:$20000;crc:$79a8ed08),
        (n:'pang_11.bin';l:$20000;p:$80000;crc:$166a16ae),(n:'bb5.bin';l:$20000;p:$a0000;crc:$2fb3db6c));
        //Super Pang
        spang_rom:array[0..2] of tipo_roms=(
        (n:'spe_06.rom';l:$8000;p:0;crc:$1af106fb),(n:'spe_07.rom';l:$20000;p:$10000;crc:$208b5f54),
        (n:'spe_08.rom';l:$20000;p:$30000;crc:$2bc03ade));
        spang_oki:tipo_roms=(n:'spe_01.rom';l:$20000;p:0;crc:$2d19c133);
        spang_sprites:array[0..1] of tipo_roms=(
        (n:'spj10_2k.bin';l:$20000;p:0;crc:$eedd0ade),(n:'spj09_1k.bin';l:$20000;p:$20000;crc:$04b41b75));
        spang_char:array[0..3] of tipo_roms=(
        (n:'spe_02.rom';l:$20000;p:0;crc:$63c9dfd2),(n:'03.f2';l:$20000;p:$20000;crc:$3ae28bc1),
        (n:'spe_04.rom';l:$20000;p:$80000;crc:$9d7b225b),(n:'05.g2';l:$20000;p:$a0000;crc:$4a060884));
        spang_eeprom:tipo_roms=(n:'eeprom-spang.bin';l:$80;p:0;crc:$deae1291);

var
 mem_rom_op,mem_rom_dat:array[0..$f,0..$3fff] of byte;
 mem_dat:array[0..$7fff] of byte;
 rom_nbank,video_bank:byte;
 obj_ram:array[0..$fff] of byte;
 vblank,irq_source:byte;
 pal_bank:word;

procedure update_video_pang;
var
  x,y,f,color,nchar:word;
  atrib:byte;
begin
fill_full_screen(2,0);
for f:=$0 to $7ff do begin
  atrib:=memoria[$c800+f];
  color:=atrib and $7f;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
    x:=f and $3f;
    y:=f shr 6;
    nchar:=(memoria[$d000+(f*2)]+(memoria[$d001+(f*2)] shl 8)) and $7fff;
    put_gfx_trans_flip(x*8,y*8,nchar,color shl 4,1,0,(atrib and $80)<>0,false);
    gfx[0].buffer[f]:=false;
  end;
end;
actualiza_trozo(0,0,512,256,1,0,0,512,256,2);
for f:=$7d downto 0 do begin
  atrib:=obj_ram[(f*$20)+1];
  nchar:=obj_ram[f*$20]+((atrib and $e0) shl 3);
  color:=(atrib and $f) shl 4;
  x:=obj_ram[(f*$20)+3]+((atrib and $10) shl 4);
  y:=((obj_ram[(f*$20)+2]+8) and $ff)-8;
  put_gfx_sprite(nchar,color,false,false,1);
  actualiza_gfx_sprite(x,y,2,1);
end;
actualiza_trozo_final(64,8,384,240,2);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure eventos_pang;
begin
if event.arcade then begin
  //IN1
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
  //IN2
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $bf) else marcade.in2:=(marcade.in2 or $40);
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $7f) else marcade.in2:=(marcade.in2 or $80);
  //IN0
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
end;
end;

procedure pang_principal;
var
  frame_m:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=z80_0.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
    z80_0.run(frame_m);
    frame_m:=frame_m+z80_0.tframes-z80_0.contador;
    case f of
      $ef:begin
            z80_0.change_irq(HOLD_LINE);
            irq_source:=1;
          end;
      $f7:vblank:=8;
      $ff:begin
          z80_0.change_irq(HOLD_LINE);
          vblank:=0;
          irq_source:=0;
      end;
    end;
  end;
  update_video_pang;
  eventos_pang;
  video_sync;
end;
end;

function pang_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$7fff:if z80_0.opcode then pang_getbyte:=memoria[direccion]
                 else pang_getbyte:=mem_dat[direccion];
  $8000..$bfff:if z80_0.opcode then pang_getbyte:=mem_rom_op[rom_nbank,direccion and $3fff]
                 else pang_getbyte:=mem_rom_dat[rom_nbank,direccion and $3fff];
  $c000..$c7ff:pang_getbyte:=buffer_paleta[(direccion and $7ff)+pal_bank];
  $d000..$dfff:if (video_bank<>0) then pang_getbyte:=obj_ram[direccion and $fff]
                  else pang_getbyte:=memoria[direccion];
  $c800..$cfff,$e000..$ffff:pang_getbyte:=memoria[direccion];
end;
end;

procedure pang_putbyte(direccion:word;valor:byte);

procedure cambiar_color(pos:word);
var
  tmp_color:byte;
  color:tcolor;
begin
  tmp_color:=buffer_paleta[$1+pos];
  color.r:=pal4bit(tmp_color);
  tmp_color:=buffer_paleta[pos];
  color.g:=pal4bit(tmp_color shr 4);
  color.b:=pal4bit(tmp_color);
  set_pal_color(color,pos shr 1);
  buffer_color[(pos shr 5) and $7f]:=true;
end;

begin
case direccion of
  0..$bfff:;
  $c000..$c7ff:if buffer_paleta[(direccion and $7ff)+pal_bank]<>valor then begin
                  buffer_paleta[(direccion and $7ff)+pal_bank]:=valor;
                  cambiar_color((direccion and $7fe)+pal_bank);
               end;
  $c800..$cfff:begin
                  gfx[0].buffer[direccion and $7ff]:=true;
                  memoria[direccion]:=valor;
               end;
  $d000..$dfff:if (video_bank<>0) then obj_ram[direccion and $fff]:=valor
                else begin
                        memoria[direccion]:=valor;
                        gfx[0].buffer[(direccion and $fff) shr 1]:=true;
                     end;
  $e000..$ffff:memoria[direccion]:=valor;
end;
end;

function pang_inbyte(puerto:word):byte;
begin
case (puerto and $ff) of
  0:pang_inbyte:=marcade.in0;
  1:pang_inbyte:=marcade.in1;
  2:pang_inbyte:=marcade.in2;
  5:pang_inbyte:=(eeprom_0.readbit shl 7) or vblank or 2 or irq_source;
end;
end;

procedure pang_outbyte(puerto:word;valor:byte);
begin
case (puerto and $ff) of
  $0:begin
      main_screen.flip_main_screen:=(valor and $4)<>0;
      pal_bank:=(valor and $20) shl 6;
     end;
  $2:rom_nbank:=valor and $f;
  $5:oki_6295_0.write(valor);
  $7:video_bank:=valor;
  $8:if valor<>0 then eeprom_0.set_cs_line(CLEAR_LINE)
      else eeprom_0.set_cs_line(ASSERT_LINE);   //eeprom_cs_w
  $10:if (valor<>0) then eeprom_0.set_clock_line(CLEAR_LINE)
      else eeprom_0.set_clock_line(ASSERT_LINE);  //eeprom_clock_w
  $18:eeprom_0.write_bit(valor);  //eeprom_serial_w
end;
end;

procedure pang_sound_update;
begin
  oki_6295_0.update;
end;

//Main
procedure reset_pang;
begin
 z80_0.reset;
 reset_audio;
 oki_6295_0.reset;
 eeprom_0.reset;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 rom_nbank:=0;
 video_bank:=0;
 pal_bank:=0;
 vblank:=0;
 irq_source:=0;
end;

function iniciar_pang:boolean;
var
  f:byte;
  memoria_temp:array[0..$4ffff] of byte;
  ptemp,mem_temp2,mem_temp3,mem_temp4:pbyte;
const
    ps_x:array[0..15] of dword=(0, 1, 2, 3, 8+0, 8+1, 8+2, 8+3,
			32*8+0, 32*8+1, 32*8+2, 32*8+3, 33*8+0, 33*8+1, 33*8+2, 33*8+3);
    ps_y:array[0..15] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16,
			8*16, 9*16, 10*16, 11*16, 12*16, 13*16, 14*16, 15*16);

procedure convert_chars;
begin
  init_gfx(0,8,8,$8000);
  gfx[0].trans[15]:=true;
  gfx_set_desc_data(4,0,16*8,$8000*16*8+4,$8000*16*8+0,4,0);
  convert_gfx(0,0,ptemp,@ps_x[0],@ps_y[0],false,false);
end;

procedure convert_sprites;
begin
  init_gfx(1,16,16,$800);
  gfx[1].trans[15]:=true;
  gfx_set_desc_data(4,0,64*8,$800*64*8+4,$800*64*8+0,4,0);
  convert_gfx(1,0,ptemp,@ps_x[0],@ps_y[0],false,false);
end;

begin
iniciar_pang:=false;
llamadas_maquina.bucle_general:=pang_principal;
llamadas_maquina.reset:=reset_pang;
llamadas_maquina.fps_max:=57.42;
iniciar_audio(false);
//Pantallas
screen_init(1,512,256,true);
screen_init(2,512,256,false,true);
iniciar_video(384,240);
//Main CPU
z80_0:=cpu_z80.create(8000000,256);
z80_0.change_ram_calls(pang_getbyte,pang_putbyte);
z80_0.change_io_calls(pang_inbyte,pang_outbyte);
z80_0.init_sound(pang_sound_update);
//eeprom
eeprom_0:=eeprom_class.create(6,16,'0110','0101','0111');
//Sound Chips
//YM2413  --> Falta!
oki_6295_0:=snd_okim6295.Create(1000000,OKIM6295_PIN7_HIGH,2);
getmem(ptemp,$100000);
getmem(mem_temp2,$50000);
getmem(mem_temp3,$50000);
case main_vars.tipo_maquina of
  119:begin  //Pang
        if not(roms_load(oki_6295_0.get_rom_addr,pang_oki)) then exit;
        //Cargar roms, desencriptar y poner en su sitio las ROMS
        if not(roms_load(@memoria_temp,pang_rom)) then exit;
        kabuki_mitchell_decode(@memoria_temp[0],mem_temp2,mem_temp3,8,$01234567,$76543210,$6548,$24);
        copymemory(@memoria[0],mem_temp2,$8000);
        copymemory(@mem_dat[0],mem_temp3,$8000);
        for f:=0 to 7 do copymemory(@mem_rom_op[f,0],@mem_temp2[$10000+(f*$4000)],$4000);
        for f:=0 to 7 do copymemory(@mem_rom_dat[f,0],@mem_temp3[$10000+(f*$4000)],$4000);
        //convertir chars
        fillchar(ptemp^,$100000,$ff);
        if not(roms_load(ptemp,pang_char)) then exit;
        convert_chars;
        //convertir sprites
        if not(roms_load(ptemp,pang_sprites)) then exit;
        convert_sprites;
      end;
  183:begin  //Super Pang
        if not(roms_load(oki_6295_0.get_rom_addr,spang_oki)) then exit;
        //Cargar roms, desencriptar y poner en su sitio las ROMS
        if not(roms_load(@memoria_temp,spang_rom)) then exit;
        kabuki_mitchell_decode(@memoria_temp[0],mem_temp2,mem_temp3,$10,$45670123,$45670123,$5852,$43);
        copymemory(@memoria[0],mem_temp2,$8000);
        copymemory(@mem_dat[0],mem_temp3,$8000);
        for f:=0 to $f do copymemory(@mem_rom_op[f,0],@mem_temp2[$10000+(f*$4000)],$4000);
        for f:=0 to $f do copymemory(@mem_rom_dat[f,0],@mem_temp3[$10000+(f*$4000)],$4000);
        //convertir chars
        fillchar(ptemp^,$100000,$ff);
        if not(roms_load(ptemp,spang_char)) then exit;
        convert_chars;
        //convertir sprites
        if not(roms_load(ptemp,spang_sprites)) then exit;
        convert_sprites;
        //load eeprom si no lo esta ya...
        mem_temp4:=eeprom_0.get_rom_addr;
        inc(mem_temp4);
        if mem_temp4^<>0 then if not(roms_load(eeprom_0.get_rom_addr,spang_eeprom)) then exit;
      end;
end;
freemem(mem_temp3);
freemem(mem_temp2);
freemem(ptemp);
//final
reset_pang;
iniciar_pang:=true;
end;

end.
