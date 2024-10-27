unit operationwolf_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m68000,main_engine,controls_engine,gfx_engine,ym_2151,msm5205,
     taitosnd,rom_engine,pal_engine,sound_engine,opwolf_cchip;

function iniciar_opwolf:boolean;

var
 rom:array[0..$2ffff] of word;

implementation
const
        opwolf_rom:array[0..3] of tipo_roms=(
        (n:'b20-05-02.40';l:$10000;p:0;crc:$3ffbfe3a),(n:'b20-03-02.30';l:$10000;p:$1;crc:$fdabd8a5),
        (n:'b20-04.39';l:$10000;p:$20000;crc:$216b4838),(n:'b20-20.29';l:$10000;p:$20001;crc:$d244431a));
        opwolf_sound:tipo_roms=(n:'b20-07.10';l:$10000;p:0;crc:$45c7ace3);
        opwolf_char:tipo_roms=(n:'b20-13.13';l:$80000;p:0;crc:$f6acdab1);
        opwolf_sprites:tipo_roms=(n:'b20-14.72';l:$80000;p:0;crc:$89f889e5);
        opwolf_adpcm:tipo_roms=(n:'b20-08.21';l:$80000;p:0;crc:$f3e19c64);

var
 scroll_x1,scroll_y1,scroll_x2,scroll_y2:word;
 bank_sound:array[0..3,$0..$3fff] of byte;
 ram1:array[0..$3fff] of word;
 ram3:array[0..$1fff] of word;
 spritebank,sound_bank:byte;
 ram2:array [0..$7fff] of word;
 adpcm_b,adpcm_c:array[0..5] of byte;

procedure update_video_opwolf;
var
  f,x,y,nchar,atrib,color:word;
  flipx,flipy:boolean;
begin
for f:=$fff downto $0 do begin
    //background
    atrib:=ram2[f*2];
    color:=atrib and $7f;
    if (gfx[0].buffer[f] or buffer_color[color]) then begin
      x:=f mod 64;
      y:=f div 64;
      nchar:=(ram2[$1+(f*2)]) and $3fff;
      flipx:=(atrib and $4000)<>0;
      flipy:=(atrib and $8000)<>0;
      put_gfx_flip(x*8,y*8,nchar,color shl 4,1,0,flipx,flipy);
      gfx[0].buffer[f]:=false;
    end;
    //foreground
    atrib:=ram2[$4000+(f*2)];
    color:=atrib and $7f;
    if (gfx[0].buffer[f+$1000] or buffer_color[color]) then begin
      x:=f mod 64;
      y:=f div 64;
      nchar:=(ram2[$4001+(f*2)]) and $3fff;
      flipx:=(atrib and $4000)<>0;
      flipy:=(atrib and $8000)<>0;
      put_gfx_trans_flip(x*8,y*8,nchar,color shl 4,2,0,flipx,flipy);
      gfx[0].buffer[f+$1000]:=false;
    end;
end;
scroll_x_y(1,3,scroll_x1,scroll_y1);
//Sprites
for f:=$ff downto 0 do begin
  nchar:=(ram3[$2+(f*4)]) and $fff;
  if nchar<>0 then begin
    atrib:=ram3[f*4];
    color:=((atrib and $f) or ((spritebank and $f) shl 4)) shl 4;
    put_gfx_sprite(nchar,color,(atrib and $4000)<>0,(atrib and $8000)<>0,1);
    x:=ram3[$3+(f*4)]+16;
    y:=ram3[$1+(f*4)];
    actualiza_gfx_sprite(x,y,3,1);
  end;
end;
scroll_x_y(2,3,scroll_x2,scroll_y2);
actualiza_trozo_final(16,8,320,240,3);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure eventos_opwolf;
begin
if event.mouse then begin
  if raton.button1 then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if raton.button2 then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
end;
if event.arcade then begin
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 or $1) else marcade.in0:=(marcade.in0 and $fe);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 or $2) else marcade.in0:=(marcade.in0 and $fd);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
end;
end;

procedure opwolf_principal;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(true,false,false,true);
frame_m:=m68000_0.tframes;
frame_s:=tc0140syt_0.z80.tframes;
while EmuStatus=EsRunning do begin
 for f:=0 to $ff do begin
  //Main CPU
  m68000_0.run(frame_m);
  frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
  //Sound CPU
  tc0140syt_0.z80.run(frame_s);
  frame_s:=frame_s+tc0140syt_0.z80.tframes-tc0140syt_0.z80.contador;
  if f=247 then begin
    update_video_opwolf;
    m68000_0.irq[5]:=HOLD_LINE;
  end;
 end;
 eventos_opwolf;
 video_sync;
end;
end;

function opwolf_getword(direccion:dword):word;
begin
case direccion of
  0..$3ffff:opwolf_getword:=rom[direccion shr 1];
  $0f0000..$0fffff:case (direccion and $fff) of
                      $0..$7ff:opwolf_getword:=opwolf_cchip_data_r(direccion and $7ff);
                      $802:opwolf_getword:=opwolf_cchip_status_r;
                   end;
  $100000..$107fff:opwolf_getword:=ram1[(direccion and $7fff) shr 1];
  $200000..$200fff:opwolf_getword:=buffer_paleta[(direccion and $fff) shr 1];
  $380000:opwolf_getword:=1+0+4+8+$30+$c0;
  $380002:opwolf_getword:=$7f;
  $3a0000:opwolf_getword:=raton.x+15;  //mouse x
  $3a0002:opwolf_getword:=raton.y;  //mouse y
  $3e0002:if m68000_0.read_8bits_hi_dir then opwolf_getword:=tc0140syt_0.comm_r;
  $c00000..$c0ffff:opwolf_getword:=ram2[(direccion and $ffff) shr 1];
  $d00000..$d03fff:opwolf_getword:=ram3[(direccion and $3fff) shr 1];
end;
end;

procedure opwolf_putword(direccion:dword;valor:word);

procedure cambiar_color(tmp_color,numero:word);
var
  color:tcolor;
begin
  color.r:=pal4bit(tmp_color shr 8);
  color.g:=pal4bit(tmp_color shr 4);
  color.b:=pal4bit(tmp_color);
  set_pal_color(color,numero);
  buffer_color[(numero shr 4) and $7f]:=true;
end;

begin
case direccion of
      0..$3ffff:;
      $0ff000..$0ff7ff:opwolf_cchip_data_w(direccion and $7ff,valor);
	    $0ff802:opwolf_cchip_status_w(valor);
	    $0ffc00:opwolf_cchip_bank_w(valor);
      $100000..$107fff:ram1[(direccion and $7fff) shr 1]:=valor;
      $200000..$200fff:if buffer_paleta[(direccion and $fff) shr 1]<>valor then begin
                            buffer_paleta[(direccion and $fff) shr 1]:=valor;
                            cambiar_color(valor,(direccion and $fff) shr 1);
                       end;
      $350008,$3c0000:;
      $380000:spritebank:=(valor and $e0) shr 5;
      $3e0000:tc0140syt_0.port_w(valor shr 8);
      $3e0002:tc0140syt_0.comm_w(valor shr 8);
      $c00000..$c03fff:begin
                      ram2[(direccion and $ffff) shr 1]:=valor;
                      gfx[0].buffer[(direccion and $3fff) shr 2]:=true;
                   end;
      $c04000..$c07fff,$c0c000..$c0ffff:ram2[(direccion and $ffff) shr 1]:=valor;
      $c08000..$c0bfff:begin
                      ram2[(direccion and $ffff) shr 1]:=valor;
                      gfx[0].buffer[((direccion and $3fff) shr 2)+$1000]:=true;
                   end;
      $c20000:scroll_y1:=(512-valor) and $1ff;
      $c20002:scroll_y2:=(512-valor) and $1ff;
      $c40000:scroll_x1:=(512-valor) and $1ff;
      $c40002:scroll_x2:=(512-valor) and $1ff;
      $c50000..$c50003:;
      $d00000..$d03fff:ram3[(direccion and $3fff) shr 1]:=valor;
end;
end;

function opwolf_snd_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$3fff,$8000..$8fff:opwolf_snd_getbyte:=mem_snd[direccion];
  $4000..$7fff:opwolf_snd_getbyte:=bank_sound[sound_bank,direccion and $3fff];
  $9001:opwolf_snd_getbyte:=ym2151_0.status;
  $a001:opwolf_snd_getbyte:=tc0140syt_0.slave_comm_r;
end;
end;

procedure opwolf_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:exit;
  $8000..$8fff:mem_snd[direccion]:=valor;
  $9000:ym2151_0.reg(valor);
  $9001:ym2151_0.write(valor);
  $a000:tc0140syt_0.slave_port_w(valor);
  $a001:tc0140syt_0.slave_comm_w(valor);
  $b000..$b006:begin
                  adpcm_b[direccion and $7]:=valor;
                	if ((direccion and $7)=$04) then begin //trigger ?
                		msm5205_0.pos:=(adpcm_b[0]+(adpcm_b[1] shl 8))*16;
                		msm5205_0.end_:=(adpcm_b[2]+(adpcm_b[3] shl 8))*16;
                		msm5205_0.reset_w(false);
                  end;
	             end;
  $c000..$c006:begin
                  adpcm_c[direccion and $7]:=valor;
                	if ((direccion and $7)=$04) then begin //trigger ?
                		msm5205_1.pos:=(adpcm_c[0]+(adpcm_c[1] shl 8))*16;
                		msm5205_1.end_:=(adpcm_c[2]+(adpcm_c[3] shl 8))*16;
                		msm5205_1.reset_w(false);
	                end;
               end;
  end;
end;

procedure sound_bank_rom(valor:byte);
begin
  sound_bank:=valor and 3;
end;

procedure opwolf_sound_update;
begin
  ym2151_0.update;
  msm5205_0.update;
  msm5205_1.update;
end;

procedure ym2151_snd_irq(irqstate:byte);
begin
  tc0140syt_0.z80.change_irq(irqstate);
end;

//Main
procedure reset_opwolf;
begin
 m68000_0.reset;
 tc0140syt_0.reset;
 ym2151_0.reset;
 msm5205_0.reset;
 msm5205_1.reset;
 opwolf_cchip_reset;
 reset_video;
 reset_audio;
 marcade.in0:=$fc;
 marcade.in1:=$ff;
 sound_bank:=0;
 scroll_x1:=0;
 scroll_y1:=0;
 scroll_x2:=0;
 scroll_y2:=0;
 adpcm_b[0]:=0;
 adpcm_c[0]:=0;
 adpcm_b[1]:=0;
 adpcm_c[1]:=0;
end;

function iniciar_opwolf:boolean;
const
  pc_y:array[0..7] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32);
  ps_x:array[0..15] of dword=(2*4, 3*4, 0*4, 1*4, 6*4, 7*4, 4*4, 5*4, 10*4, 11*4, 8*4, 9*4, 14*4, 15*4, 12*4, 13*4);
  ps_y:array[0..15] of dword=(0*64, 1*64, 2*64, 3*64, 4*64, 5*64, 6*64, 7*64, 8*64, 9*64, 10*64, 11*64, 12*64, 13*64, 14*64, 15*64);
var
  memoria_temp:array[0..$7ffff] of byte;
begin
iniciar_opwolf:=false;
llamadas_maquina.bucle_general:=opwolf_principal;
llamadas_maquina.reset:=reset_opwolf;
iniciar_audio(true);
screen_init(1,512,512);
screen_mod_scroll(1,512,512,511,512,256,511);
screen_init(2,512,512,true);
screen_mod_scroll(2,512,512,511,512,256,511);
screen_init(3,512,512,false,true);
iniciar_video(320,240);
//Main CPU
m68000_0:=cpu_m68000.create(8000000,256);
m68000_0.change_ram16_calls(opwolf_getword,opwolf_putword);
//Sound CPU
tc0140syt_0:=tc0140syt_chip.create(4000000,256);
tc0140syt_0.z80.change_ram_calls(opwolf_snd_getbyte,opwolf_snd_putbyte);
tc0140syt_0.z80.init_sound(opwolf_sound_update);
//MCU
opwolf_init_cchip(m68000_0.numero_cpu);
//Sound Chips
ym2151_0:=ym2151_chip.create(4000000);
ym2151_0.change_port_func(sound_bank_rom);
ym2151_0.change_irq_func(ym2151_snd_irq);
msm5205_0:=MSM5205_chip.create(384000,MSM5205_S48_4B,1,$80000);
msm5205_1:=MSM5205_chip.create(384000,MSM5205_S48_4B,1,$80000);
if not(roms_load(msm5205_0.rom_data,opwolf_adpcm)) then exit;
if not(roms_load(msm5205_1.rom_data,opwolf_adpcm)) then exit;
//cargar roms
if not(roms_load16w(@rom,opwolf_rom)) then exit;
//cargar sonido+ponerlas en su banco+adpcm
if not(roms_load(@memoria_temp,opwolf_sound)) then exit;
copymemory(@mem_snd[0],@memoria_temp[0],$4000);
copymemory(@bank_sound[0,0],@memoria_temp[$0],$4000);
copymemory(@bank_sound[1,0],@memoria_temp[$4000],$4000);
copymemory(@bank_sound[2,0],@memoria_temp[$8000],$4000);
copymemory(@bank_sound[3,0],@memoria_temp[$c000],$4000);
//convertir chars
if not(roms_load(@memoria_temp,opwolf_char)) then exit;
init_gfx(0,8,8,$4000);
gfx[0].trans[0]:=true;
gfx_set_desc_data(4,0,32*8,0,1,2,3);
convert_gfx(0,0,@memoria_temp,@ps_x,@pc_y,false,false);
//convertir sprites
if not(roms_load(@memoria_temp,opwolf_sprites)) then exit;
init_gfx(1,16,16,$1000);
gfx[1].trans[0]:=true;
gfx_set_desc_data(4,0,128*8,0,1,2,3);
convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,false);
//final
show_mouse_cursor;
reset_opwolf;
iniciar_opwolf:=true;
end;

end.
