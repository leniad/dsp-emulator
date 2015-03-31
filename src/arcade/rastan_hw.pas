unit rastan_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,m68000,main_engine,controls_engine,gfx_engine,ym_2151,
     msm5205,taitosnd,rom_engine,pal_engine,sound_engine;

procedure Cargar_rastan;
procedure rastan_principal;
function iniciar_rastan:boolean;
procedure reset_rastan;
procedure cerrar_rastan;
//Main CPU
function rastan_getword(direccion:dword;putbyte:boolean):word;
procedure rastan_putword(direccion:dword;valor:word);
//Sound CPU
function rastan_snd_getbyte(direccion:word):byte;
procedure rastan_snd_putbyte(direccion:word;valor:byte);
procedure sound_bank_rom(valor:byte);
procedure sound_instruccion;
procedure ym2151_snd_irq(irqstate:byte);
procedure snd_adpcm;

const
        rastan_rom:array[0..6] of tipo_roms=(
        (n:'b04-35.19';l:$10000;p:0;crc:$1c91dbb1),(n:'b04-37.07';l:$10000;p:$1;crc:$ecf20bdd),
        (n:'b04-40.20';l:$10000;p:$20000;crc:$0930d4b3),(n:'b04-39.08';l:$10000;p:$20001;crc:$d95ade5e),
        (n:'b04-42.21';l:$10000;p:$40000;crc:$1857a7cb),(n:'b04-43.09';l:$10000;p:$40001;crc:$c34b9152),());
        rastan_char:array[0..4] of tipo_roms=(
        (n:'b04-01.40';l:$20000;p:0;crc:$cd30de19),(n:'b04-03.39';l:$20000;p:$20000;crc:$ab67e064),
        (n:'b04-02.67';l:$20000;p:$40000;crc:$54040fec),(n:'b04-04.66';l:$20000;p:$60000;crc:$94737e93),());
        rastan_sound:tipo_roms=(n:'b04-19.49';l:$10000;p:0;crc:$ee81fdd8);
        rastan_sprites:array[0..4] of tipo_roms=(
        (n:'b04-05.15';l:$20000;p:0;crc:$c22d94ac),(n:'b04-07.14';l:$20000;p:$20000;crc:$b5632a51),
        (n:'b04-06.28';l:$20000;p:$40000;crc:$002ccf39),(n:'b04-08.27';l:$20000;p:$60000;crc:$feafca05),());
        rastan_adpcm:tipo_roms=(n:'b04-20.76';l:$10000;p:0;crc:$fd1a34cc);

var
 scroll_x1,scroll_y1,scroll_x2,scroll_y2:word;
 bank_sound:array[0..3,$0..$3fff] of byte;
 rom:array[0..$2ffff] of word;
 ram1,ram3:array[0..$1fff] of word;
 spritebank,sound_bank:byte;
 ram2:array [0..$7fff] of word;
 adpcm:array[0..$ffff] of byte;
 adpcm_pos,adpcm_data:word;

implementation

procedure Cargar_rastan;
begin
llamadas_maquina.iniciar:=iniciar_rastan;
llamadas_maquina.bucle_general:=rastan_principal;
llamadas_maquina.cerrar:=cerrar_rastan;
llamadas_maquina.reset:=reset_rastan;
end;

function iniciar_rastan:boolean;
const
  pc_x:array[0..7] of dword=(0, 4, $40000*8+0 ,$40000*8+4, 8+0, 8+4, $40000*8+8+0, $40000*8+8+4);
  pc_y:array[0..7] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16);
  ps_x:array[0..15] of dword=(0, 4, $40000*8+0 ,$40000*8+4,	8+0, 8+4, $40000*8+8+0, $40000*8+8+4,
              	16+0, 16+4, $40000*8+16+0, $40000*8+16+4,24+0, 24+4, $40000*8+24+0, $40000*8+24+4);
  ps_y:array[0..15] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32,
			8*32, 9*32, 10*32, 11*32, 12*32, 13*32, 14*32, 15*32 );
var
  memoria_temp:array[0..$7ffff] of byte;
begin
iniciar_rastan:=false;
iniciar_audio(false);
//Pantallas:  principal+char y sprites
screen_init(1,512,512);
screen_mod_scroll(1,512,512,511,512,256,511);
screen_init(2,512,512,true);
screen_mod_scroll(2,512,512,511,512,256,511);
screen_init(3,512,512,false,true);
iniciar_video(320,240);
//Main CPU
main_m68000:=cpu_m68000.create(8000000,256);
main_m68000.change_ram16_calls(rastan_getword,rastan_putword);
//Sound CPU
snd_z80:=cpu_z80.create(4000000,256);
snd_z80.change_ram_calls(rastan_snd_getbyte,rastan_snd_putbyte);
snd_z80.init_sound(sound_instruccion);
//Sound Chips
msm_5205_0:=MSM5205_chip.create(0,384000,MSM5205_S48_4B,1,snd_adpcm);
YM2151_Init(0,4000000,sound_bank_rom,ym2151_snd_irq);
//cargar roms
if not(cargar_roms16w(@rom[0],@rastan_rom[0],'rastan.zip',0)) then exit;
//rom[$05FF9F]:=$fa;  //Cheeeeeeeeat
//cargar sonido+ponerlas en su banco+adpcm
if not(cargar_roms(@memoria_temp[0],@rastan_sound,'rastan.zip')) then exit;
copymemory(@mem_snd[0],@memoria_temp[0],$4000);
copymemory(@bank_sound[0,0],@memoria_temp[$0],$4000);
copymemory(@bank_sound[1,0],@memoria_temp[$4000],$4000);
copymemory(@bank_sound[2,0],@memoria_temp[$8000],$4000);
copymemory(@bank_sound[3,0],@memoria_temp[$c000],$4000);
if not(cargar_roms(@adpcm[0],@rastan_adpcm,'rastan.zip')) then exit;
//convertir chars
if not(cargar_roms(@memoria_temp[0],@rastan_char[0],'rastan.zip',0)) then exit;
init_gfx(0,8,8,$4000);
gfx[0].trans[0]:=true;
gfx_set_desc_data(4,0,16*8,0,1,2,3);
convert_gfx(@gfx[0],0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,false);
//convertir sprites
if not(cargar_roms(@memoria_temp[0],@rastan_sprites[0],'rastan.zip',0)) then exit;
init_gfx(1,16,16,$1000);
gfx[1].trans[0]:=true;
gfx_set_desc_data(4,0,64*8,0,1,2,3);
convert_gfx(@gfx[1],0,@memoria_temp[0],@ps_x[0],@ps_y[0],false,false);
//final
reset_rastan;
iniciar_rastan:=true;
end;

procedure cerrar_rastan;
begin
main_m68000.free;
snd_z80.free;
YM2151_close(0);
msm_5205_0.Free;
close_audio;
close_video;
end;

procedure reset_rastan;
begin
 main_m68000.reset;
 snd_z80.reset;
 YM2151_reset(0);
 msm_5205_0.reset;
 taitosound_reset;
 reset_audio;
 marcade.in0:=$1F;
 marcade.in1:=$fF;
 sound_bank:=0;
 scroll_x1:=0;
 scroll_y1:=0;
 scroll_x2:=0;
 scroll_y2:=0;
 adpcm_data:=$100;
 adpcm_pos:=0;
end;

procedure update_video_rastan;inline;
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
      nchar:=ram2[$1+(f*2)] and $3fff;
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
      nchar:=ram2[$4001+(f*2)] and $3fff;
      flipx:=(atrib and $4000)<>0;
      flipy:=(atrib and $8000)<>0;
      put_gfx_trans_flip(x*8,y*8,nchar,color shl 4,2,0,flipx,flipy);
      gfx[0].buffer[f+$1000]:=false;
    end;
end;
scroll_x_y(1,3,scroll_x1,scroll_y1);
scroll_x_y(2,3,scroll_x2,scroll_y2);
//Sprites
for f:=$ff downto 0 do begin
  nchar:=(ram3[$2+(f*4)]) and $fff;
  if nchar<>0 then begin
    atrib:=ram3[f*4];
    color:=((atrib and $f) or ((spritebank and $f) shl 4)) shl 4;
    put_gfx_sprite(nchar,color,(atrib and $4000)<>0,(atrib and $8000)<>0,1);
    x:=(ram3[$3+(f*4)]+16) and $1ff;
    y:=(ram3[$1+(f*4)]) and $1ff;
    actualiza_gfx_sprite(x,y,3,1);
  end;
end;
actualiza_trozo_final(16,8,320,240,3);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure eventos_rastan;
begin
if event.arcade then begin
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $Fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $F7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 or $20) else marcade.in0:=(marcade.in0 and $df);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 or $40) else marcade.in0:=(marcade.in0 and $bf);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
end;
end;

procedure rastan_principal;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=main_m68000.tframes;
frame_s:=snd_z80.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to $ff do begin
  //Main CPU
  main_m68000.run(frame_m);
  frame_m:=frame_m+main_m68000.tframes-main_m68000.contador;
  //Sound CPU
  snd_z80.run(frame_s);
  frame_s:=frame_s+snd_z80.tframes-snd_z80.contador;
  if f=247 then begin
    update_video_rastan;
    main_m68000.irq[5]:=HOLD_LINE;
  end;
 end;
 eventos_rastan;
 video_sync;
end;
end;

function rastan_getword(direccion:dword;putbyte:boolean):word;
begin
direccion:=direccion and $ffffff;
case direccion of
  $3e0003:rastan_getword:=taitosound_comm_r;
end;
direccion:=direccion and $fffffe;
case direccion of
  0..$5ffff:rastan_getword:=rom[direccion shr 1];
  $10c000..$10ffff:rastan_getword:=ram1[(direccion and $3fff) shr 1];
  $200000..$200fff:rastan_getword:=buffer_paleta[(direccion and $fff) shr 1];
  $390000:rastan_getword:=marcade.in1;
  $390002,$39000a:rastan_getword:=$ff;
  $390004:rastan_getword:=$8f;
  $390006:rastan_getword:=marcade.in0;
  $390008:rastan_getword:=$fe;
  $39000c..$39000f:rastan_getword:=$00;
  $c00000..$c0ffff:rastan_getword:=ram2[(direccion and $ffff) shr 1];
  $d00000..$d03fff:rastan_getword:=ram3[(direccion and $3fff) shr 1];
end;
end;

procedure cambiar_color(tmp_color,numero:word);inline;
var
  color:tcolor;
begin
  color.b:=pal5bit(tmp_color shr 10);
  color.g:=pal5bit(tmp_color shr 5);
  color.r:=pal5bit(tmp_color);
  set_pal_color(color,@paleta[numero]);
  buffer_color[(numero shr 4) and $7f]:=true;
end;

procedure rastan_putword(direccion:dword;valor:word);
begin
direccion:=direccion and $fffffe;
if direccion<$60000 then exit;
case direccion of
      $10c000..$10ffff:ram1[(direccion and $3fff) shr 1]:=valor;
      $200000..$200fff:if buffer_paleta[(direccion and $fff) shr 1]<>valor then begin
                            buffer_paleta[(direccion and $fff) shr 1]:=valor;
                            cambiar_color(valor,(direccion and $fff) shr 1);
                       end;
      $350008,$3c0000:;
      $380000:spritebank:=(valor and $e0) shr 5;
      $3e0000:taitosound_port_w(valor and $ff);
      $3e0002:taitosound_comm_w(valor and $ff);
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

function rastan_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$3fff,$8000..$8fff:rastan_snd_getbyte:=mem_snd[direccion];
  $4000..$7fff:rastan_snd_getbyte:=bank_sound[sound_bank,direccion and $3fff];
  $9001:rastan_snd_getbyte:=YM2151_status_port_read(0);
  $a001:rastan_snd_getbyte:=taitosound_slave_comm_r;
end;
end;

procedure rastan_snd_putbyte(direccion:word;valor:byte);
begin
if direccion<$8000 then exit;
case direccion of
  $8000..$8fff:mem_snd[direccion]:=valor;
  $9000:YM2151_register_port_write(0,valor);
  $9001:YM2151_data_port_write(0,valor);
  $a000:taitosound_slave_port_w(valor);
  $a001:taitosound_slave_comm_w(valor);
  $b000:adpcm_pos:=(adpcm_pos and $00ff) or (valor shl 8);
  $c000:msm_5205_0.reset_w(0);
  $d000:begin
           msm_5205_0.reset_w(1);
           adpcm_pos:=adpcm_pos and $ff00;
        end;
end;
end;

procedure sound_bank_rom(valor:byte);
begin
  sound_bank:=valor and 3;
end;

procedure sound_instruccion;
begin
  ym2151_Update(0);
end;

procedure ym2151_snd_irq(irqstate:byte);
begin
  if (irqstate=1) then snd_z80.pedir_irq:=ASSERT_LINE
    else snd_z80.pedir_irq:=CLEAR_LINE;
end;

procedure snd_adpcm;
begin
if (adpcm_data and $100)=0 then begin
		msm_5205_0.data_w(adpcm_data and $0f);
		adpcm_data:=$100;
    adpcm_pos:=(adpcm_pos+1) and $ffff;
end else begin
		adpcm_data:=adpcm[adpcm_pos];
		msm_5205_0.data_w(adpcm_data shr 4);
end;
end;

end.
