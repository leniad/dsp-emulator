unit vigilante_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,gfx_engine,dac,ym_2151,rom_engine,
     pal_engine,sound_engine,timer_engine;

procedure Cargar_vigilante;
procedure vigilante_principal; 
function iniciar_vigilante:boolean; 
procedure reset_vigilante; 
procedure cerrar_vigilante;
//Main CPU
function vigilante_getbyte(direccion:word):byte;
procedure vigilante_putbyte(direccion:word;valor:byte);
function vigilante_inbyte(puerto:word):byte;
procedure vigilante_outbyte(valor:byte;puerto:word);
//Sound CPU
function snd_getbyte(direccion:word):byte;
procedure snd_putbyte(direccion:word;valor:byte);
function snd_inbyte(puerto:word):byte;
procedure snd_outbyte(valor:byte;puerto:word);
procedure vigilante_snd_irq;
//Sound
procedure snd_despues_instruccion;
procedure ym2151_snd_irq(irqstate:byte);

const
        vigilante_rom:array[0..2] of tipo_roms=(
        (n:'g07_c03.bin';l:$8000;p:0;crc:$9dcca081),(n:'j07_c04.bin';l:$10000;p:$8000;crc:$e0159105),());
        vigilante_chars:array[0..2] of tipo_roms=(
        (n:'f05_c08.bin';l:$10000;p:0;crc:$01579d20),(n:'h05_c09.bin';l:$10000;p:$10000;crc:$4f5872f0),());
        vigilante_sprites:array[0..8] of tipo_roms=(
        (n:'n07_c12.bin';l:$10000;p:$00000;crc:$10af8eb2),(n:'k07_c10.bin';l:$10000;p:$10000;crc:$9576f304),
        (n:'o07_c13.bin';l:$10000;p:$20000;crc:$b1d9d4dc),(n:'l07_c11.bin';l:$10000;p:$30000;crc:$4598be4a),
        (n:'t07_c16.bin';l:$10000;p:$40000;crc:$f5425e42),(n:'p07_c14.bin';l:$10000;p:$50000;crc:$cb50a17c),
        (n:'v07_c17.bin';l:$10000;p:$60000;crc:$959ba3c7),(n:'s07_c15.bin';l:$10000;p:$70000;crc:$7f2e91c5),());
        vigilante_dac:tipo_roms=(n:'d04_c01.bin';l:$10000;p:0;crc:$9b85101d);
        vigilante_sound:tipo_roms=(n:'g05_c02.bin';l:$10000;p:0;crc:$10582b2d);
        vigilante_tiles:array[0..3] of tipo_roms=(
        (n:'d01_c05.bin';l:$10000;p:$00000;crc:$81b1ee5c),(n:'e01_c06.bin';l:$10000;p:$10000;crc:$d0d33673),
        (n:'f01_c07.bin';l:$10000;p:$20000;crc:$aae81695),());
var
 rom_bank:array[0..3,0..$3FFF] of byte;
 banco_rom:word;
 sound_latch,rear_color:byte;
 rear_scroll,scroll_x:word;
 rear_disable,rear_ch_color:boolean;
 sample_addr:word;
 mem_dac:array[0..$ffff] of byte;

implementation

procedure Cargar_vigilante;
begin
llamadas_maquina.iniciar:=iniciar_vigilante;
llamadas_maquina.bucle_general:=vigilante_principal;
llamadas_maquina.cerrar:=cerrar_vigilante;
llamadas_maquina.reset:=reset_vigilante;
llamadas_maquina.fps_max:=55;
end;

function iniciar_vigilante:boolean;
const
  ps_x:array[0..15] of dword=($00*8+0,$00*8+1,$00*8+2,$00*8+3,
		                          $10*8+0,$10*8+1,$10*8+2,$10*8+3,
		                          $20*8+0,$20*8+1,$20*8+2,$20*8+3,
		                          $30*8+0,$30*8+1,$30*8+2,$30*8+3);
  ps_y:array[0..15] of dword=($00*8,$01*8,$02*8,$03*8,
                          		$04*8,$05*8,$06*8,$07*8,
                          		$08*8,$09*8,$0A*8,$0B*8,
                           		$0C*8,$0D*8,$0E*8,$0F*8);
  pt_x:array[0..31] of dword=(0*8+1, 0*8,  1*8+1, 1*8, 2*8+1, 2*8, 3*8+1, 3*8, 4*8+1, 4*8, 5*8+1, 5*8,
	6*8+1, 6*8, 7*8+1, 7*8, 8*8+1, 8*8, 9*8+1, 9*8, 10*8+1, 10*8, 11*8+1, 11*8,
	12*8+1, 12*8, 13*8+1, 13*8, 14*8+1, 14*8, 15*8+1, 15*8);
  pt_y:array[0..0] of dword=(0);
  pc_x:array[0..7] of dword=(0,1,2,3, 64+0,64+1,64+2,64+3);
  pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
var
  f:word;
  memoria_temp:array[0..$7ffff] of byte;
begin
iniciar_vigilante:=false;
iniciar_audio(true);
//Pantallas:  principal+char y sprites
screen_init(1,512,256,true);
screen_mod_scroll(1,512,256+128,511,0,0,0);
screen_init(2,512,256,true);
screen_mod_scroll(2,512,256+128,511,0,0,0);
screen_init(3,512,256,false,true);
screen_mod_sprites(3,0,$200,0,$1ff);
screen_init(4,512*4,256);
iniciar_video(256,256);
//Main CPU
main_z80:=cpu_z80.create(3579645,256);
main_z80.change_ram_calls(vigilante_getbyte,vigilante_putbyte);
main_z80.change_io_calls(vigilante_inbyte,vigilante_outbyte);
//Sound CPU
snd_z80:=cpu_z80.create(3579645,256);
snd_z80.change_ram_calls(snd_getbyte,snd_putbyte);
snd_z80.change_io_calls(snd_inbyte,snd_outbyte);
snd_z80.init_sound(snd_despues_instruccion);
init_timer(snd_z80.numero_cpu,3579645/(128*55),vigilante_snd_irq,true);
//sound chips
dac_0:=dac_chip.Create;
ym2151_init(0,3579645,nil,ym2151_snd_irq);
//cargar roms y rom en bancos
if not(cargar_roms(@memoria_temp[0],@vigilante_rom[0],'vigilant.zip',0)) then exit;
copymemory(@memoria[0],@memoria_temp[0],$8000);
for f:=0 to 3 do copymemory(@rom_bank[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
//cargar sonido
if not(cargar_roms(@mem_snd[0],@vigilante_sound,'vigilant.zip',1)) then exit;
if not(cargar_roms(@mem_dac[0],@vigilante_dac,'vigilant.zip',1)) then exit;
//convertir chars
if not(cargar_roms(@memoria_temp[0],@vigilante_chars[0],'vigilant.zip',0)) then exit;
init_gfx(0,8,8,4096);
gfx[0].trans[0]:=true;
for f:=0 to 7 do gfx[0].trans_alt[1,f]:=true;
gfx_set_desc_data(4,0,128,64*1024*8,(64*1024*8)+4,0,4);
convert_gfx(@gfx[0],0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,false);
//sprites
if not(cargar_roms(@memoria_temp[0],@vigilante_sprites[0],'vigilant.zip',0)) then exit;
init_gfx(1,16,16,4096);
gfx[1].trans[0]:=true;
gfx_set_desc_data(4,0,$40*8,$40000*8,$40000*8+4,0,4);
convert_gfx(@gfx[1],0,@memoria_temp[0],@ps_x[0],@ps_y[0],false,false);
//sprites
if not(cargar_roms(@memoria_temp[0],@vigilante_tiles[0],'vigilant.zip',0)) then exit;
init_gfx(2,32,1,3*512*8);
gfx_set_desc_data(4,0,16*8,0,2,4,6);
convert_gfx(@gfx[2],0,@memoria_temp[0],@pt_x[0],@pt_y[0],false,false);
//final
reset_vigilante;
iniciar_vigilante:=true;
end;

procedure cerrar_vigilante;
begin
main_z80.free;
snd_z80.free;
ym2151_close(0);
dac_0.Free;
close_audio;
close_video;
end;

procedure reset_vigilante;
begin
 main_z80.reset;
 snd_z80.reset;
 ym2151_reset(0);
 reset_audio;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 banco_rom:=0;
 rear_ch_color:=true;
 sample_addr:=0;
end;

procedure update_video_vigilante;inline;
var
  f,color,nchar,x,y,h,c,i:word;
  atrib:byte;
  flip_y:boolean;
  ccolor:tcolor;
begin
//fondo
if not(rear_disable) then begin
 if rear_ch_color then begin
  for i:=0 to 15 do begin
		ccolor.r:=(memoria[$cc00+16*rear_color+i] shl 3) and $FF;
		ccolor.g:=(memoria[$cd00+16*rear_color+i] shl 3) and $FF;
		ccolor.b:=(memoria[$ce00+16*rear_color+i] shl 3) and $FF;
    set_pal_color(ccolor,@paleta[512+i]);
		ccolor.r:=(memoria[$cc00+16*rear_color+32+i] shl 3) and $FF;
		ccolor.g:=(memoria[$cd00+16*rear_color+32+i] shl 3) and $FF;
		ccolor.b:=(memoria[$ce00+16*rear_color+32+i] shl 3) and $FF;
    set_pal_color(ccolor,@paleta[512+i+16]);
	end;
  nchar:=0;
  for c:=0 to 2 do begin
		for y:=0 to 255 do begin
      x:=0;
      while x<512 do begin
        if y<128 then put_gfx(512*c+x,y,nchar,512+0,4,2)
          else put_gfx(512*c+x,y,nchar,512+16,4,2);
				nchar:=nchar+1;
			  x:=x+32;
      end;
		end;
  end;
  rear_ch_color:=false;
 end;
 actualiza_trozo(rear_scroll-(378+16*8)+64,0,256+128,256,4,0,0,256+128,256,3);
end;
//chars
for f:=0 to $7ff do begin
  color:=memoria[$d001+(f*2)] and $f;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
      x:=f mod 64;
      y:=f div 64;
      nchar:=memoria[$d000+(f*2)]+((memoria[$d001+(f*2)] and $f0) shl 4);
      if ((color>=4) or rear_disable) then put_gfx(x*8,y*8,nchar,(color shl 4)+256,1,0)
        else put_gfx_trans(x*8,y*8,nchar,(color shl 4)+256,1,0);
      if (color and $c)=$c then put_gfx_trans_alt(x*8,y*8,nchar,(color shl 4)+256,2,0,1)
        else put_gfx_block_trans(x*8,y*8,2,8,8);
      gfx[0].buffer[f]:=false;
  end;
end;
scroll__x(1,3,scroll_x);
//sprites
for f:=0 to $17 do begin
      atrib:=memoria[$c025+(f*8)];
      nchar:=memoria[$c024+(f*8)]+ ((atrib and $0f) shl 8);
		  color:=(memoria[$c020+(f*8)] and $0f) shl 4;
		  h:=1 shl ((atrib and $30) shr 4);
      nchar:=nchar and not(h-1);
      x:=(memoria[$c026+(f*8)]+((memoria[$c027+(f*8)] and $01) shl 8));
		  y:=(256+128-(memoria[$c022+(f*8)]+((memoria[$c023+(f*8)] and $01) shl 8)))-(16*h);
      flip_y:=(atrib and $80)<>0;
      for i:=0 to (h-1) do begin
        if flip_y then c:=nchar+(h-1-i)
			    else c:=nchar+i;
        put_gfx_sprite(c,color,(atrib and $40)<>0,flip_y,1);
        actualiza_gfx_sprite_over(x,y+(16*i),3,1,2,scroll_x,0);
      end;
end;
actualiza_trozo(128,0,256,48,1,128,0,256,48,3);
actualiza_trozo_final(128,0,256,256,3);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure eventos_vigilante;
begin
if event.arcade then begin
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or 8);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or 10);
end;
end;

procedure vigilante_principal;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=main_z80.tframes;
frame_s:=snd_z80.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
    //Main CPU
    main_z80.run(frame_m);
    frame_m:=frame_m+main_z80.tframes-main_z80.contador;
    //Sound CPU
    snd_z80.run(frame_s);
    frame_s:=frame_s+snd_z80.tframes-snd_z80.contador;
  end;
  main_z80.pedir_irq:=HOLD_LINE;
  update_video_vigilante;
  eventos_vigilante;
  video_sync;
end;
end;

procedure cambiar_color(dir:word);inline;
var
  color:tcolor;
  pos2:byte;
  bank,pos:word;
begin
  bank:=dir and $400;
  pos2:=(dir and $ff);
  pos:=bank+pos2;
	color.r:=(buffer_paleta[pos+$000]) shl 3;
	color.g:=(buffer_paleta[pos+$100]) shl 3;
	color.b:=(buffer_paleta[pos+$200]) shl 3;
  set_pal_color(color,@paleta[(bank shr 2)+pos2]);
  case (bank shr 2)+pos2 of
    $100..$1ff:buffer_color[(((bank shr 2)+pos2) shr 4) and $f]:=true;
  end;
  if bank>$3ff then rear_ch_color:=true;
end;

function vigilante_getbyte(direccion:word):byte;
begin
case direccion of
  $8000..$bfff:vigilante_getbyte:=rom_bank[banco_rom,(direccion and $3fff)];
  else vigilante_getbyte:=memoria[direccion];
end;
end;

procedure vigilante_putbyte(direccion:word;valor:byte);
begin
if (direccion<$c000) then exit;
memoria[direccion]:=valor;
case direccion of
    $c800..$cfff:if buffer_paleta[direccion and $7ff]<>valor then begin
                    buffer_paleta[direccion and $7ff]:=valor;
                    cambiar_color(direccion and $7ff);
                 end;
    $d000..$dfff:gfx[0].buffer[(direccion and $fff) shr 1]:=true;
end;
end;

procedure snd_irq_set(tipo:byte);
begin
  case tipo of
    0:snd_z80.im0:=snd_z80.im0 or $20; //Clear Z80
    1:snd_z80.im0:=snd_z80.im0 and $df; //Set Z80
    2:snd_z80.im0:=snd_z80.im0 or $10; //Clear YM2151
    3:snd_z80.im0:=snd_z80.im0 and $ef; //Set YM2151
  end;
  if (snd_z80.im0<>$ff) then snd_z80.pedir_irq:=ASSERT_LINE
    else snd_z80.pedir_irq:=CLEAR_LINE;
end;

function vigilante_inbyte(puerto:word):byte;
begin
case (puerto and $ff) of
  0:vigilante_inbyte:=marcade.in0;
  1:vigilante_inbyte:=marcade.in1;
  2:vigilante_inbyte:=marcade.in2;
  3:vigilante_inbyte:=$ff;
  4:vigilante_inbyte:=$fd;
end;
end;

procedure vigilante_outbyte(valor:byte;puerto:word);
begin
case (puerto and $ff) of
  0:begin
      sound_latch:=valor;
      snd_irq_set(1);
    end;
  4:banco_rom:=valor and $7;
  $80:scroll_x:=(scroll_x and $100) or valor;
  $81:scroll_x:=(scroll_x and $ff) or ((valor and 1) shl 8);
  $82:rear_scroll:=(rear_scroll and $700) or valor;
  $83:rear_scroll:=(rear_scroll and $ff) or ((valor and 7) shl 8);
  $84:begin
        rear_disable:=(valor and $40)<>0;
        rear_color:=valor and $d;
      end;
end;
end;

function snd_getbyte(direccion:word):byte;
begin
snd_getbyte:=mem_snd[direccion];
end;

procedure snd_putbyte(direccion:word;valor:byte);
begin
if direccion<$c000 then exit;
mem_snd[direccion]:=valor;
end;

function snd_inbyte(puerto:word):byte;
begin
case (puerto and $ff) of
  $1:snd_inbyte:=YM2151_status_port_read(0);
  $80:snd_inbyte:=sound_latch;
  $84:snd_inbyte:=mem_dac[sample_addr];
end;
end;

procedure snd_outbyte(valor:byte;puerto:word);
begin
case (puerto and $ff) of
  0:YM2151_register_port_write(0,valor);
  1:YM2151_data_port_write(0,valor);
  $80:sample_addr:=(sample_addr and $ff00) or valor;
  $81:sample_addr:=(sample_addr and $ff) or (valor shl 8);
  $82:begin
        dac_0.signed_data8_w(valor);
        sample_addr:=sample_addr+1;
      end;
  $83:snd_irq_set(0);
end;
end;

procedure ym2151_snd_irq(irqstate:byte);
begin
  snd_irq_set(2+irqstate);
end;

procedure vigilante_snd_irq;
begin
  snd_z80.pedir_nmi:=PULSE_LINE;
end;

procedure snd_despues_instruccion;
begin
  ym2151_Update(0);
  dac_0.update;
end;

end.
