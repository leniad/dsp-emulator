unit wardner_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,gfx_engine,tms32010,ym_3812,
     rom_engine,pal_engine,sound_engine;

procedure Cargar_wardnerhw;
procedure wardnerhw_principal;
procedure reset_wardnerhw;
function iniciar_wardnerhw:boolean;
//CPU
function wardner_getbyte(direccion:word):byte;
procedure wardner_putbyte(direccion:word;valor:byte);
function wardner_inbyte(puerto:word):byte;
procedure wardner_outbyte(valor:byte;puerto:word);
//SND
function wardner_snd_getbyte(direccion:word):byte;
procedure wardner_snd_putbyte(direccion:word;valor:byte);
function wardner_snd_inbyte(puerto:word):byte;
procedure wardner_snd_outbyte(valor:byte;puerto:word);
procedure snd_irq(irqstate:byte);
procedure wardner_sound_update;
//MCU
procedure wardner_dsp_bio_w(valor:word);
function wardner_dsp_r:word;
procedure wardner_dsp_addrsel_w(valor:word);
procedure wardner_dsp_w(valor:word);
function wardner_BIO_r:boolean;

implementation
const
        wardner_rom:array[0..4] of tipo_roms=(
        (n:'wardner.17';l:$8000;p:0;crc:$c5dd56fd),(n:'b25-18.rom';l:$10000;p:$8000;crc:$9aab8ee2),
        (n:'b25-19.rom';l:$10000;p:$18000;crc:$95b68813),(n:'wardner.20';l:$8000;p:$28000;crc:$347f411b),());
        wardner_snd_rom:tipo_roms=(n:'b25-16.rom';l:$8000;p:0;crc:$e5202ff8);
        wardner_char:array[0..3] of tipo_roms=(
        (n:'wardner.07';l:$4000;p:0;crc:$1392b60d),(n:'wardner.06';l:$4000;p:$4000;crc:$0ed848da),
        (n:'wardner.05';l:$4000;p:$8000;crc:$79792c86),());
        wardner_sprites:array[0..4] of tipo_roms=(
        (n:'b25-01.rom';l:$10000;p:0;crc:$42ec01fb),(n:'b25-02.rom';l:$10000;p:$10000;crc:$6c0130b7),
        (n:'b25-03.rom';l:$10000;p:$20000;crc:$b923db99),(n:'b25-04.rom';l:$10000;p:$30000;crc:$8059573c),());
        wardner_fg_tiles:array[0..4] of tipo_roms=(
        (n:'b25-12.rom';l:$8000;p:0;crc:$15d08848),(n:'b25-15.rom';l:$8000;p:$8000;crc:$cdd2d408),
        (n:'b25-14.rom';l:$8000;p:$10000;crc:$5a2aef4f),(n:'b25-13.rom';l:$8000;p:$18000;crc:$be21db2b),());
        wardner_bg_tiles:array[0..4] of tipo_roms=(
        (n:'b25-08.rom';l:$8000;p:0;crc:$883ccaa3),(n:'b25-11.rom';l:$8000;p:$8000;crc:$d6ebd510),
        (n:'b25-10.rom';l:$8000;p:$10000;crc:$b9a61e81),(n:'b25-09.rom';l:$8000;p:$18000;crc:$585411b7),());
        wardner_mcu_rom:array[0..8] of tipo_roms=(
        (n:'82s137.1d';l:$400;p:0;crc:$cc5b3f53),(n:'82s137.1e';l:$400;p:$400;crc:$47351d55),
        (n:'82s137.3d';l:$400;p:$800;crc:$70b537b9),(n:'82s137.3e';l:$400;p:$c00;crc:$6edb2de8),
        (n:'82s131.3b';l:$200;p:$1000;crc:$9dfffaff),(n:'82s131.3a';l:$200;p:$1200;crc:$712bad47),
        (n:'82s131.2a';l:$200;p:$1400;crc:$ac843ca6),(n:'82s131.1a';l:$200;p:$1600;crc:$50452ff8),());

var
 mem_rom:array[0..7,0..$7fff] of byte;
 rom_bank,vsync:byte;
 rom_ena,int_enable,wardner_dsp_BIO,dsp_execute:boolean;
 txt_ram:array[0..$7ff] of word;
 bg_ram:array[0..$1fff] of word;
 fg_ram:array[0..$fff] of word;
 txt_offs,bg_offs,fg_offs,bg_bank,fg_bank,main_ram_seg,dsp_addr_w:word;
 txt_scroll_x,txt_scroll_y,bg_scroll_x,bg_scroll_y,fg_scroll_x,fg_scroll_y:word;

procedure Cargar_wardnerhw;
begin
llamadas_maquina.iniciar:=iniciar_wardnerhw;
llamadas_maquina.bucle_general:=wardnerhw_principal;
llamadas_maquina.reset:=reset_wardnerhw;
llamadas_maquina.fps_max:=(14000000/2)/(446*286);
end;

function iniciar_wardnerhw:boolean;
var
      f:word;
      memoria_temp:array[0..$3ffff] of byte;
      rom:array[0..$fff] of word;
const
    pc_x:array[0..7] of dword=(0, 1, 2, 3, 4, 5, 6, 7);
    pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
    ps_x:array[0..15] of dword=(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15);
    ps_y:array[0..15] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16,
			8*16, 9*16, 10*16, 11*16, 12*16, 13*16, 14*16, 15*16);
begin
iniciar_wardnerhw:=false;
iniciar_audio(false);
//Pantallas:  principal+char y sprites
screen_init(1,512,256,true);
screen_mod_scroll(1,512,512,511,256,256,255);
screen_init(2,512,512,true);
screen_mod_scroll(2,512,512,511,512,256,511);
screen_init(3,512,512);
screen_mod_scroll(3,512,512,511,512,256,511);
screen_init(4,512,512,false,true);
iniciar_video(320,240);
//Main CPU
main_z80:=cpu_z80.create(24000000 div 4,286);
main_z80.change_ram_calls(wardner_getbyte,wardner_putbyte);
main_z80.change_io_calls(wardner_inbyte,wardner_outbyte);
//Sound CPU
snd_z80:=cpu_z80.create(3500000,286);
snd_z80.change_ram_calls(wardner_snd_getbyte,wardner_snd_putbyte);
snd_z80.change_io_calls(wardner_snd_inbyte,wardner_snd_outbyte);
snd_z80.init_sound(wardner_sound_update);
//TMS MCU
main_tms32010:=cpu_tms32010.create(14000000,286);
main_tms32010.change_io_calls(wardner_BIO_r,nil,wardner_dsp_r,nil,nil,nil,nil,nil,nil,wardner_dsp_addrsel_w,wardner_dsp_w,nil,wardner_dsp_bio_w,nil,nil,nil,nil);
//Sound Chips
ym3812_0:=ym3812_chip.create(YM3812_FM,3500000);
ym3812_0.change_irq_calls(snd_irq);
//cargar roms
if not(cargar_roms(@memoria_temp[0],@wardner_rom[0],'wardner.zip',0)) then exit;
//Mover las ROMS a su sitio
copymemory(@memoria,@memoria_temp[$0],$8000);
for f:=0 to 3 do copymemory(@mem_rom[f+2,0],@memoria_temp[$8000+(f*$8000)],$8000);
copymemory(@mem_rom[7,0],@memoria_temp[$28000],$8000);
//cargar ROMS sonido
if not(cargar_roms(@mem_snd[0],@wardner_snd_rom,'wardner.zip',1)) then exit;
//cargar ROMS MCU y organizarlas
if not(cargar_roms(@memoria_temp[0],@wardner_mcu_rom[0],'wardner.zip',0)) then exit;
for f:=0 to $3ff do begin
   rom[f]:=(((memoria_temp[f] and $f) shl 4+(memoria_temp[f+$400] and $f)) shl 8) or
                    (memoria_temp[f+$800] and $f) shl 4+(memoria_temp[f+$c00] and $f);
end;
for f:=0 to $1ff do begin
   //1024-2047
   rom[f+$400]:=(((memoria_temp[f+$1000] and $f) shl 4+(memoria_temp[f+$1200] and $f)) shl 8) or
                        (memoria_temp[f+$1400] and $f) shl 4+(memoria_temp[f+$1600] and $f);
end;
copymemory(main_tms32010.get_rom_addr,@rom[0],$1000);
//convertir chars
if not(cargar_roms(@memoria_temp[0],@wardner_char[0],'wardner.zip',0)) then exit;
init_gfx(0,8,8,2048);
gfx[0].trans[0]:=true;
gfx_set_desc_data(3,0,8*8,0*2048*8*8,1*2048*8*8,2*2048*8*8);
convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,false);
//convertir tiles fg
if not(cargar_roms(@memoria_temp[0],@wardner_fg_tiles[0],'wardner.zip',0)) then exit;
init_gfx(1,8,8,4096);
gfx[1].trans[0]:=true;
gfx_set_desc_data(4,0,8*8,0*4096*8*8,1*4096*8*8,2*4096*8*8,3*4096*8*8);
convert_gfx(1,0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,false);
//convertir tiles bg
if not(cargar_roms(@memoria_temp[0],@wardner_bg_tiles[0],'wardner.zip',0)) then exit;
init_gfx(2,8,8,4096);
convert_gfx(2,0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,false);
//convertir tiles sprites
if not(cargar_roms(@memoria_temp[0],@wardner_sprites[0],'wardner.zip',0)) then exit;
init_gfx(3,16,16,2048);
gfx[3].trans[0]:=true;
gfx_set_desc_data(4,0,32*8,0*2048*32*8,1*2048*32*8,2*2048*32*8,3*2048*32*8);
convert_gfx(3,0,@memoria_temp[0],@ps_x[0],@ps_y[0],false,false);
//final
reset_wardnerhw;
iniciar_wardnerhw:=true;
end;

procedure reset_wardnerhw;
begin
 main_z80.reset;
 snd_z80.reset;
 main_tms32010.reset;
 ym3812_0.reset;
 reset_audio;
 txt_scroll_x:=457;
 txt_scroll_y:=226;
 bg_scroll_x:=0;
 bg_scroll_y:=0;
 fg_scroll_x:=0;
 fg_scroll_y:=0;
 marcade.in0:=0;
 marcade.in1:=0;
 rom_bank:=0;
 rom_ena:=true;
 txt_offs:=0;
 bg_offs:=0;
 fg_offs:=0;
 bg_bank:=0;
 fg_bank:=0;
 int_enable:=false;
 vsync:=0;
 wardner_dsp_BIO:=false;
 dsp_execute:=false;
 main_ram_seg:=0;
 dsp_addr_w:=0;
end;

procedure draw_sprites(priority:word);inline;
var
  f:word;
  atrib,x,y:word;
  flipx,flipy:boolean;
  nchar,color:word;
begin
for f:=0 to $1ff do begin
  atrib:=memoria[$8002+(f shl 3)]+(memoria[$8003+(f shl 3)] shl 8);
  if ((atrib and $0c00)=priority) then begin
    y:=(memoria[$8006+(f shl 3)]+(memoria[$8007+(f shl 3)] shl 8)) shr 7;
    if (y and $1ff)>$100 then continue;
    nchar:=(memoria[$8000+(f shl 3)]+(memoria[$8001+(f shl 3)] shl 8)) and $7ff;
    color:=atrib and $3f;
    x:=(memoria[$8004+(f shl 3)]+(memoria[$8005+(f shl 3)] shl 8)) shr 7;
    flipx:=(atrib and $100)<>0;
    if flipx then x:=x-14;		// should really be 15 */
    flipy:=(atrib and $200)<>0;
    put_gfx_sprite(nchar,color shl 4,flipx,flipy,3);
    actualiza_gfx_sprite(x-32,y-16,4,3);
  end;
end;
end;

procedure update_video_wardner;inline;
var
        f,color,nchar:word;
        x,y:word;
        atrib:word;
begin
for f:=$7ff downto 0 do begin
  //Chars
  atrib:=txt_ram[f];
  color:=(atrib and $F800) shr 11;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
    x:=(f and $3f) shl 3;
    y:=(f shr 6) shl 3;
    nchar:=atrib and $7ff;
    put_gfx_trans(x,y,nchar,(color shl 3)+$600,1,0);
    gfx[0].buffer[f]:=false;
  end;
end;
for f:=0 to $fff do begin
    atrib:=bg_ram[f+bg_bank];
    color:=(atrib and $F000) shr 12;
    if (gfx[2].buffer[f+bg_bank] or buffer_color[color+$30]) then begin
      //background
      x:=(f and $3f) shl 3;
      y:=(f shr 6) shl 3;
      nchar:=atrib and $fff;
      put_gfx(x,y,nchar,(color shl 4)+$400,3,2);
      gfx[2].buffer[f+bg_bank]:=false;
    end;
    atrib:=fg_ram[f];
    color:=(atrib and $F000) shr 12;
    if (gfx[1].buffer[f] or buffer_color[color+$20]) then begin
      //foreground
      x:=(f and $3f) shl 3;
      y:=(f shr 6) shl 3;
      nchar:=(atrib and $fff)+fg_bank;
      put_gfx_trans(x,y,nchar and $fff,(color shl 4)+$500,2,1);
      gfx[1].buffer[f]:=false;
    end;
end;
scroll_x_y(3,4,bg_scroll_x+55,bg_scroll_y+30);
draw_sprites($400);
scroll_x_y(2,4,fg_scroll_x+55,fg_scroll_y+30);
draw_sprites($800);
scroll_x_y(1,4,512-txt_scroll_x-55,256-txt_scroll_y-30);
draw_sprites($c00);
actualiza_trozo_final(0,0,320,240,4);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure eventos_wardner;
begin
if event.arcade then begin
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 or $4) else marcade.in1:=(marcade.in1 and $fb);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 or $8) else marcade.in1:=(marcade.in1 and $F7);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 or $1) else marcade.in1:=(marcade.in1 and $fe);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 or $2) else marcade.in1:=(marcade.in1 and $fd);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 or $20) else marcade.in1:=(marcade.in1 and $df);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 or $10) else marcade.in1:=(marcade.in1 and $ef);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 or $8) else marcade.in0:=(marcade.in0 and $f7);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 or $10) else marcade.in0:=(marcade.in0 and $ef);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 or $20) else marcade.in0:=(marcade.in0 and $df);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 or $40) else marcade.in0:=(marcade.in0 and $bf);
end;
end;

procedure wardnerhw_principal;
var
  f:word;
  frame_m,frame_s,frame_mcu:single;
begin
init_controls(false,false,false,true);
frame_m:=main_z80.tframes;
frame_s:=snd_z80.tframes;
frame_mcu:=main_tms32010.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to 285 do begin
    //MAIN CPU
    main_z80.run(frame_m);
    frame_m:=frame_m+main_z80.tframes-main_z80.contador;
    //SND CPU
    snd_z80.run(frame_s);
    frame_s:=frame_s+snd_z80.tframes-snd_z80.contador;
    //MCU
    main_tms32010.run(frame_mcu);
    frame_mcu:=frame_mcu+main_tms32010.tframes-main_tms32010.contador;
    case f of
      0:vsync:=0;
      239:begin
            vsync:=$80;
            if int_enable then begin
                main_z80.pedir_irq:=HOLD_LINE;
                int_enable:=false;
            end;
            update_video_wardner;
          end;
    end;
  end;
  eventos_wardner;
  video_sync;
end;
end;

function wardner_dsp_r:word;
begin
	// DSP can read data from main CPU RAM via DSP IO port 1 */
	case main_ram_seg of
		$7000,$8000,$a000:wardner_dsp_r:=memoria[main_ram_seg+(dsp_addr_w+0)] or
        								   (memoria[main_ram_seg+(dsp_addr_w+1)] shl 8);
      else wardner_dsp_r:=0;
	end;
end;

procedure wardner_dsp_w(valor:word);
begin
  // Data written to main CPU RAM via DSP IO port 1 */
	dsp_execute:=false;
	case main_ram_seg of
		$7000:begin
            if ((dsp_addr_w<3) and (valor=0)) then dsp_execute:=true;
            memoria[main_ram_seg+dsp_addr_w]:=valor and $ff;
						memoria[main_ram_seg+(dsp_addr_w+1)]:=(valor shr 8) and $ff;
          end;
		$8000,$a000:begin
						memoria[main_ram_seg+dsp_addr_w]:=valor and $ff;
						memoria[main_ram_seg+(dsp_addr_w+1)]:=(valor shr 8) and $ff;
						end;
	end;
end;

procedure wardner_dsp_addrsel_w(valor:word);
begin
  main_ram_seg:=valor and $e000;
	dsp_addr_w:=(valor and $7ff) shl 1;
	if (main_ram_seg=$6000) then main_ram_seg:=$7000;
end;

procedure wardner_dsp_bio_w(valor:word);
begin
  if (valor and $8000)<>0 then begin
		wardner_dsp_BIO:=false;
	end;
	if (valor=0) then begin
		if dsp_execute then begin
      main_z80.pedir_halt:=CLEAR_LINE;
			dsp_execute:=false;
		end;
		wardner_dsp_BIO:=true;
	end;
end;

function wardner_BIO_r:boolean;
begin
  wardner_BIO_r:=wardner_dsp_BIO;
end;

function wardner_snd_getbyte(direccion:word):byte;
begin
case direccion of
  $c000..$c7ff:wardner_snd_getbyte:=memoria[direccion];
    else wardner_snd_getbyte:=mem_snd[direccion];
end;
end;

procedure wardner_snd_putbyte(direccion:word;valor:byte);
begin
if direccion<$8000 then exit;
mem_snd[direccion]:=valor;
case direccion of
  $c000..$c7ff:memoria[direccion]:=valor;
end;
end;

function wardner_snd_inbyte(puerto:word):byte;
begin
case (puerto and $ff) of
  0:wardner_snd_inbyte:=ym3812_0.status;
end;
end;

procedure wardner_snd_outbyte(valor:byte;puerto:word);
begin
case (puerto and $ff) of
  $0:ym3812_0.control(valor);
  $1:ym3812_0.write(valor);
end;
end;

procedure snd_irq(irqstate:byte);
begin
  if (irqstate<>0) then snd_z80.pedir_irq:=ASSERT_LINE
    else snd_z80.pedir_irq:=CLEAR_LINE;
end;

function wardner_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff:wardner_getbyte:=memoria[direccion];
  $8000..$ffff:if rom_ena then wardner_getbyte:=mem_rom[rom_bank,direccion and $7fff]
                  else wardner_getbyte:=memoria[direccion];
end;
end;

procedure cambiar_color(numero:word);inline;
var
  tmp_color:word;
  color:tcolor;
begin
  tmp_color:=(buffer_paleta[numero+1] shl 8)+buffer_paleta[numero];
  color.b:=pal5bit(tmp_color shr 10);
  color.g:=pal5bit(tmp_color shr 5);
  color.r:=pal5bit(tmp_color);
  numero:=numero shr 1;
  set_pal_color(color,numero);
  case numero of
    1024..1279:buffer_color[((numero shr 4) and $f)+$30]:=true;
    1280..1535:buffer_color[((numero shr 4) and $f)+$20]:=true;
    1536..1791:buffer_color[(numero shr 3) and $1f]:=true;
  end;
end;

procedure wardner_putbyte(direccion:word;valor:byte);
begin
if direccion<$7000 then exit;
memoria[direccion]:=valor;
case direccion of
  $8000..$ffff:if rom_ena then exit
                  else case direccion of
                          $a000..$adff:if buffer_paleta[direccion and $fff]<>valor then begin
                                          buffer_paleta[direccion and $fff]:=valor;
                                          cambiar_color(direccion and $ffe);
                                       end;
                        end;
end;
end;

function wardner_inbyte(puerto:word):byte;
begin
case (puerto and $ff) of
  $50:wardner_inbyte:=1;
  $52,$56:wardner_inbyte:=0;
  $54:wardner_inbyte:=marcade.in1;
  $58:wardner_inbyte:=marcade.in0 or vsync;
  $60:wardner_inbyte:=txt_ram[txt_offs] and $ff;
  $61:wardner_inbyte:=txt_ram[txt_offs] shr 8;
  $62:wardner_inbyte:=bg_ram[bg_offs+bg_bank] and $ff;
  $63:wardner_inbyte:=bg_ram[bg_offs+bg_bank] shr 8;
  $64:wardner_inbyte:=fg_ram[fg_offs] and $ff;
  $65:wardner_inbyte:=fg_ram[fg_offs] shr 8;
end;
end;

procedure wardner_outbyte(valor:byte;puerto:word);
begin
case (puerto and $ff) of
  $10:txt_scroll_x:=(txt_scroll_x and $ff00) or valor;
  $11:txt_scroll_x:=(txt_scroll_x and $00ff) or ((valor and $1) shl 8);
  $12:txt_scroll_y:=(txt_scroll_y and $ff00) or valor;
  $13:txt_scroll_y:=(txt_scroll_y and $00ff) or ((valor and $1) shl 8);
  $14:txt_offs:=(txt_offs and $ff00) or valor;
  $15:txt_offs:=(txt_offs and $00ff) or ((valor and $7) shl 8);
  $20:bg_scroll_x:=(bg_scroll_x and $ff00) or valor;
  $21:bg_scroll_x:=(bg_scroll_x and $00ff) or ((valor and $1) shl 8);
  $22:bg_scroll_y:=(bg_scroll_y and $ff00) or valor;
  $23:bg_scroll_y:=(bg_scroll_y and $00ff) or ((valor and $1) shl 8);
  $24:bg_offs:=(bg_offs and $ff00) or valor;
  $25:bg_offs:=(bg_offs and $00ff) or ((valor and $f) shl 8);
  $30:fg_scroll_x:=(fg_scroll_x and $ff00) or valor;
  $31:fg_scroll_x:=(fg_scroll_x and $00ff) or ((valor and $1) shl 8);
  $32:fg_scroll_y:=(fg_scroll_y and $ff00) or valor;
  $33:fg_scroll_y:=(fg_scroll_y and $00ff) or ((valor and $1) shl 8);
  $34:fg_offs:=(fg_offs and $ff00) or valor;
  $35:fg_offs:=(fg_offs and $00ff) or ((valor and $f) shl 8);
  $5a:case valor of
        $00:begin	// This means assert the INT line to the DSP */
					    main_tms32010.pedir_halt:=CLEAR_LINE;
              main_z80.pedir_halt:=ASSERT_LINE;
              main_tms32010.pedir_int:=ASSERT_LINE;
					 end;
		    $01:begin	// This means inhibit the INT line to the DSP */
              main_tms32010.pedir_int:=CLEAR_LINE;
					    main_tms32010.pedir_halt:=ASSERT_LINE;
            end;
      end;
  $5c:case valor of
		    $4:int_enable:=false;
		    $5:int_enable:=true;
		    $6,$7:;
		    $8:bg_bank:=$0000;
        $9:bg_bank:=$1000;
		    $a:fg_bank:=$0000;
        $b:fg_bank:=$1000;
//		    $c,$d:;//MessageDlg('Mierda DSP!!', mtInformation,[mbOk], 0);
        // twincobr_dsp(machine, 1); break;	 /* Enable the INT line to the DSP */
    //		case 0x000d: twincobr_dsp(machine, 0); break;	 /* Inhibit the INT line to the DSP */
//		    $e,$f:halt(0);//MessageDlg('Mierda Pantalla on/off', mtInformation,[mbOk], 0);// twincobr_display(0); break; /* Turn display off */
	    end;
  $60:begin
          txt_ram[txt_offs]:=(txt_ram[txt_offs] and $ff00) or valor;
          gfx[0].buffer[txt_offs]:=true;
      end;
  $61:begin
        txt_ram[txt_offs]:=(txt_ram[txt_offs] and $ff) or (valor shl 8);
        gfx[0].buffer[txt_offs]:=true;
      end;
  $62:begin
        bg_ram[bg_offs+bg_bank]:=(bg_ram[bg_offs+bg_bank] and $ff00) or valor;
        gfx[2].buffer[bg_offs+bg_bank]:=true;
      end;
  $63:begin
        bg_ram[bg_offs+bg_bank]:=(bg_ram[bg_offs+bg_bank] and $ff) or (valor shl 8);
        gfx[2].buffer[bg_offs+bg_bank]:=true;
      end;
  $64:begin
        fg_ram[fg_offs]:=(fg_ram[fg_offs] and $ff00) or valor;
        gfx[1].buffer[fg_offs]:=true;
      end;
  $65:begin
        fg_ram[fg_offs]:=(fg_ram[fg_offs] and $ff) or (valor shl 8);
        gfx[1].buffer[fg_offs]:=true;
      end;
  $70:begin
        rom_ena:=(valor<>0);
        rom_bank:=valor;
      end;
end;
end;

procedure wardner_sound_update;
begin
  ym3812_0.update;
end;

end.
