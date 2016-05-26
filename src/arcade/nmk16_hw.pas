unit nmk16_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m68000,main_engine,controls_engine,gfx_engine,timer_engine,oki6295,
     rom_engine,pal_engine,sound_engine;

procedure Cargar_nmk16;
procedure nmk16_principal;
function iniciar_nmk16:boolean;
procedure reset_nmk16;
procedure cerrar_nmk16;
//Main CPU
function sbombers_getword(direccion:dword):word;
procedure sbombers_putword(direccion:dword;valor:word);
procedure sound_irq;
procedure nmk16_update_sound;

implementation
const
        //Saboten Bombers
        sbombers_rom:array[0..2] of tipo_roms=(
        (n:'ic76.sb1';l:$40000;p:0;crc:$b2b0b2cf),(n:'ic75.sb2';l:$40000;p:$1;crc:$367e87b7),());
        sbombers_char:tipo_roms=(n:'ic35.sb3';l:$10000;p:0;crc:$eb7bc99d);
        sbombers_char2:tipo_roms=(n:'ic32.sb4';l:$200000;p:0;crc:$24c62205);
        sbombers_sprites:tipo_roms=(n:'ic100.sb5';l:$200000;p:0;crc:$b20f166e);
        sbombers_adpcm1:tipo_roms=(n:'ic30.sb6';l:$100000;p:0;crc:$288407af);
        sbombers_adpcm2:tipo_roms=(n:'ic27.sb7';l:$100000;p:0;crc:$43e33a7e);
        //Bomb Jack Twin
        bjtwin_rom:array[0..2] of tipo_roms=(
        (n:'93087-1.bin';l:$20000;p:0;crc:$93c84e2d),(n:'93087-2.bin';l:$20000;p:$1;crc:$30ff678a),());
        bjtwin_char:tipo_roms=(n:'93087-3.bin';l:$10000;p:0;crc:$aa13df7c);
        bjtwin_char2:tipo_roms=(n:'93087-4.bin';l:$100000;p:0;crc:$8a4f26d0);
        bjtwin_sprites:tipo_roms=(n:'93087-5.bin';l:$100000;p:0;crc:$bb06245d);
        bjtwin_adpcm1:tipo_roms=(n:'93087-6.bin';l:$100000;p:0;crc:$372d46dd);
        bjtwin_adpcm2:tipo_roms=(n:'93087-7.bin';l:$100000;p:0;crc:$8da67808);

var
 rom:array[0..$3ffff] of word;
 ram:array[0..$ffff] of byte;
 bg_ram:array[0..$fff] of byte;
 bg_bank:byte;
 adpcm_rom:array[0..1] of pbyte;
 nmk112_bank:array[0..7] of byte;

procedure Cargar_nmk16;
begin
llamadas_maquina.iniciar:=iniciar_nmk16;
llamadas_maquina.bucle_general:=nmk16_principal;
llamadas_maquina.cerrar:=cerrar_nmk16;
llamadas_maquina.reset:=reset_nmk16;
llamadas_maquina.fps_max:=56;
end;

procedure bank_nmk112(offset,valor:byte);inline;
var
  chip,banknum:byte;
  bankaddr:dword;
  ptemp,ptemp2:pbyte;
begin
  chip:=(offset and 4) shr 2;
  banknum:=offset and 3;
  bankaddr:=((valor and $ff)*$10000) mod $100000;
  // copy the samples */
  ptemp:=adpcm_rom[chip];
  inc(ptemp,bankaddr+$400);
  if chip=0 then ptemp2:=oki_6295_0.get_rom_addr
    else ptemp2:=oki_6295_1.get_rom_addr;
  inc(ptemp2,$400+(banknum*$10000));
  copymemory(ptemp2,ptemp,$10000-$400);
  //copio la informacion de ADPCM
  ptemp:=adpcm_rom[chip];
  inc(ptemp,bankaddr+(banknum*$100));
  if chip=0 then ptemp2:=oki_6295_0.get_rom_addr
    else ptemp2:=oki_6295_1.get_rom_addr;
  inc(ptemp2,banknum*$100);
  copymemory(ptemp2,ptemp,$100);
end;

function iniciar_nmk16:boolean;
var
      mem_char:pbyte;
      memoria_temp:array[0..$ffff] of byte;
const
  pc_x:array[0..7] of dword=(0*4, 1*4, 2*4, 3*4, 4*4, 5*4, 6*4, 7*4);
  pc_y:array[0..7] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32);
  ps_x:array[0..15] of dword=(0*4, 1*4, 2*4, 3*4, 4*4, 5*4, 6*4, 7*4,
                        			16*32+0*4, 16*32+1*4, 16*32+2*4, 16*32+3*4, 16*32+4*4, 16*32+5*4, 16*32+6*4, 16*32+7*4);
  ps_y:array[0..15] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32,
                        			8*32, 9*32, 10*32, 11*32, 12*32, 13*32, 14*32, 15*32);
procedure decode_gfx(rom:pbyte;len:dword);
const
  decode_data_bg:array[0..7,0..7] of byte=(
		($3,$0,$7,$2,$5,$1,$4,$6),
		($1,$2,$6,$5,$4,$0,$3,$7),
		($7,$6,$5,$4,$3,$2,$1,$0),
		($7,$6,$5,$0,$1,$4,$3,$2),
		($2,$0,$1,$4,$3,$5,$7,$6),
		($5,$3,$7,$0,$4,$6,$2,$1),
		($2,$7,$0,$6,$5,$3,$1,$4),
		($3,$4,$7,$6,$2,$0,$5,$1));
var
  a,addr:dword;
  ptemp:pbyte;
function decode_byte(src:byte;bitp:pbyte):byte;
var
  ret,i:byte;
  ptemp3:pbyte;
begin
  ret:=0;
  ptemp3:=bitp;
	for i:=0 to 7 do begin
    ret:=ret or (((src shr ptemp3^) and 1) shl (7-i));
    inc(ptemp3);
  end;
	decode_byte:=ret;
end;
begin
	// GFX are scrambled.  We decode them here.  (BIG Thanks to Antiriad for descrambling info)
	// background */
  ptemp:=rom;
	for a:=0 to len-1 do begin
    addr:=((a and $00004) shr  2) or ((a and $00800) shr  10) or ((a and $40000) shr 16);
		ptemp^:=decode_byte(ptemp^,@decode_data_bg[addr]);
    inc(ptemp);
  end;
end;
procedure decode_sprites(const rom:pbyte;len:dword);
const decode_data_sprite:array[0..7,0..15] of byte=(
		($9,$3,$4,$5,$7,$1,$b,$8,$0,$d,$2,$c,$e,$6,$f,$a),
		($1,$3,$c,$4,$0,$f,$b,$a,$8,$5,$e,$6,$d,$2,$7,$9),
		($f,$e,$d,$c,$b,$a,$9,$8,$7,$6,$5,$4,$3,$2,$1,$0),
		($f,$e,$c,$6,$a,$b,$7,$8,$9,$2,$3,$4,$5,$d,$1,$0),
		($1,$6,$2,$5,$f,$7,$b,$9,$a,$3,$d,$e,$c,$4,$0,$8), // Haze 20/07/00 */
		($7,$5,$d,$e,$b,$a,$0,$1,$9,$6,$c,$2,$3,$4,$8,$f), // Haze 20/07/00 */
		($0,$5,$6,$3,$9,$b,$a,$7,$1,$d,$2,$e,$4,$c,$8,$f), // Antiriad, Corrected by Haze 20/07/00 */
		($9,$c,$4,$2,$f,$0,$b,$8,$a,$d,$3,$6,$5,$e,$1,$7)); // Antiriad, Corrected by Haze 20/07/00 */
var
  a,addr:dword;
  ptemp,ptemp2:pbyte;
  tmp:word;
function decode_word(src:word;bitp:pbyte):word;
var
	ret:word;
  i:byte;
  ptemp3:pbyte;
begin
	ret:=0;
  ptemp3:=bitp;
	for i:=0 to 15 do begin
    ret:=ret or (((src shr ptemp3^) and 1) shl (15-i));
    inc(ptemp3);
  end;
	decode_word:=ret;
end;
begin
	// sprites
  ptemp:=rom;
  ptemp2:=rom;
  inc(ptemp2);
	for a:=0 to ((len div 2)-1) do begin
    addr:=(((a*2) and $00010) shr 4) or (((a*2) and $20000) shr 16) or (((a*2) and $100000) shr 18);
		tmp:=decode_word(ptemp2^*256 +ptemp^,@decode_data_sprite[addr]);
    ptemp^:=tmp and $ff;
    inc(ptemp,2);
		ptemp2^:=tmp shr 8;
    inc(ptemp2,2);
	end;
end;
procedure convert_chars;
begin
  init_gfx(0,8,8,$800);
  gfx_set_desc_data(4,0,32*8,0,1,2,3);
  convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,false);
end;
procedure convert_sprites(num:word);
begin
  init_gfx(2,16,16,num);
  gfx[2].trans[15]:=true;
  gfx_set_desc_data(4,0,32*32,0,1,2,3);
  convert_gfx(2,0,mem_char,@ps_x[0],@ps_y[0],false,false);
end;
begin
iniciar_nmk16:=false;
iniciar_audio(false);
//Pantallas:  principal+char y sprites
if main_vars.tipo_maquina=71 then main_screen.rol90_screen:=true;
screen_init(1,512,512);
screen_init(2,512,512,false,true);
iniciar_video(384,224);
//Main CPU
main_m68000:=cpu_m68000.create(10000000,$100);
main_m68000.change_ram16_calls(sbombers_getword,sbombers_putword);
main_m68000.init_sound(nmk16_update_sound);
//Sound Chips
oki_6295_0:=snd_okim6295.Create(16000000 div 4,OKIM6295_PIN7_LOW);
oki_6295_1:=snd_okim6295.Create(16000000 div 4,OKIM6295_PIN7_LOW);
//Cargar ADPCM ROMS
getmem(adpcm_rom[0],$100000);
getmem(adpcm_rom[1],$100000);
//Sound timer
init_timer(0,10000000/112,sound_irq,true);
//Iniciar Maquinas
case main_vars.tipo_maquina of
  69:begin
      //cargar roms
      if not(cargar_roms16w(@rom[0],@sbombers_rom[0],'sabotenb.zip',0)) then exit;
      //convertir chars
      if not(cargar_roms(@memoria_temp[0],@sbombers_char,'sabotenb.zip',1)) then exit;
      //Cargar sound roms
      if not(cargar_roms(adpcm_rom[0],@sbombers_adpcm1,'sabotenb.zip',1)) then exit;
      if not(cargar_roms(adpcm_rom[1],@sbombers_adpcm2,'sabotenb.zip',1)) then exit;
      convert_chars;
      getmem(mem_char,$200000);
      if not(cargar_roms(mem_char,@sbombers_char2,'sabotenb.zip',1)) then exit;
      decode_gfx(mem_char,$200000);
      init_gfx(1,8,8,$10000);
      convert_gfx(1,0,mem_char,@pc_x[0],@pc_y[0],false,false);
      //convertir sprites
      if not(cargar_roms_swap_word(mem_char,@sbombers_sprites,'sabotenb.zip',1)) then exit;
      decode_sprites(mem_char,$200000);
      convert_sprites($4000);
      freemem(mem_char);
  end;
  71:begin
      //cargar roms
      if not(cargar_roms16w(@rom[0],@bjtwin_rom[0],'bjtwin.zip',0)) then exit;
      //convertir chars
      if not(cargar_roms(@memoria_temp[0],@bjtwin_char,'bjtwin.zip',1)) then exit;
      //Cargar sound roms
      if not(cargar_roms(adpcm_rom[0],@bjtwin_adpcm1,'bjtwin.zip',1)) then exit;
      if not(cargar_roms(adpcm_rom[1],@bjtwin_adpcm2,'bjtwin.zip',1)) then exit;
      convert_chars;
      getmem(mem_char,$100000);
      if not(cargar_roms(mem_char,@bjtwin_char2,'bjtwin.zip',1)) then exit;
      decode_gfx(mem_char,$100000);
      init_gfx(1,8,8,$8000);
      convert_gfx(1,0,mem_char,@pc_x[0],@pc_y[0],false,false);
      //convertir sprites
      if not(cargar_roms_swap_word(mem_char,@bjtwin_sprites,'bjtwin.zip',1)) then exit;
      decode_sprites(mem_char,$100000);
      convert_sprites($2000);
      freemem(mem_char);
  end;
end;
//final
reset_nmk16;
iniciar_nmk16:=true;
end;

procedure cerrar_nmk16;
begin
if adpcm_rom[0]<>nil then freemem(adpcm_rom[0]);
if adpcm_rom[1]<>nil then freemem(adpcm_rom[1]);
adpcm_rom[0]:=nil;
adpcm_rom[1]:=nil;
end;

procedure reset_nmk16;
var
  f:byte;
begin
 main_m68000.reset;
 oki_6295_0.reset;
 oki_6295_1.reset;
 reset_audio;
 marcade.in0:=$FF;
 marcade.in1:=$FF;
 marcade.in2:=$FF;
 bg_bank:=0;
 for f:=0 to 7 do begin
  nmk112_bank[f]:=0;
  bank_nmk112(f,0);
 end;
end;

procedure draw_sprites(priority:byte);inline;
var
	f:word;
  sx,sy,code,color,w,h,pri,x:word;
  xx,yy:integer;
  atrib:byte;
begin
	for f:=0 to $ff do begin
    atrib:=ram[$8001+(f*8)];
		if (atrib and $01)<>0 then begin
      pri:=(atrib and $c0) shr 6;
			if (pri<>priority) then continue;
			sx:=((ram[$8008+(f*8)] shl 8)+ram[$8009+(f*8)])+128;// 4
			sy:=(ram[$800c+(f*8)] shl 8)+ram[$800d+(f*8)];  //6
			code:=((ram[$8006+(f*8)] shl 8)+(ram[$8007+(f*8)])) and $3fff;  // 3
			color:=((ram[$800e+(f*8)] shl 8)+ram[$800f+(f*8)]) shl 4;  //7
			w:=ram[$8003+(f*8)] and $0f;  //1
			h:=(ram[$8003+(f*8)] and $f0) shr 4;  //1
			yy:=h;
      while (yy>=0) do begin
				x:=sx;
				xx:=w;
				while (xx>=0) do begin
          put_gfx_sprite(code,color+$100,false,false,2);
          actualiza_gfx_sprite(x,sy,2,2);
					code:=code+1;
					x:=x+16;//delta;
          xx:=xx-1;
				end;;
				sy:=sy+16;//delta;
        yy:=yy-1;
			end;
		end;
	end;
end;

procedure update_video_sbombers;inline;
var
  f,color,x,y,nchar,atrib:word;
  bank:byte;
begin
//foreground
for f:=$0 to $7ff do begin
  atrib:=(bg_ram[f*2] shl 8) or bg_ram[(f*2)+1];
  color:=(atrib and $f000) shr 12;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
    x:=f div 32;
    y:=f mod 32;
    bank:=(atrib and $800) shr 11;
    nchar:=atrib and $7ff+((bg_bank*bank) shl 11);
    put_gfx(((x*8)+128) and $1ff,y*8,nchar,color shl 4,1,bank);
    gfx[0].buffer[f]:=false;
  end;
end;
actualiza_trozo(0,0,512,512,1,0,0,512,256,2);
draw_sprites(3);
draw_sprites(2);
draw_sprites(1);
draw_sprites(0);
actualiza_trozo_final(64,16,384,224,2);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure eventos_sbombers;
begin
if event.arcade then begin
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $Fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $Fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $Fb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $Fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
end;
end;

procedure nmk16_principal;
var
  frame_m:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=main_m68000.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
      main_m68000.run(frame_m);
      frame_m:=frame_m+main_m68000.tframes-main_m68000.contador;
      if f=239 then begin
        main_m68000.irq[4]:=HOLD_LINE;
        update_video_sbombers;
      end;
  end;
  eventos_sbombers;
  video_sync;
end;
end;

function sbombers_getword(direccion:dword):word;
begin
case direccion of
    0..$7ffff:sbombers_getword:=rom[direccion shr 1];
    $80000:sbombers_getword:=marcade.in0;
    $80002:sbombers_getword:=(marcade.in2 shl 8) or marcade.in1;
    $80008:sbombers_getword:=$ffff;
    $8000a:sbombers_getword:=$ffff;
    $84000:sbombers_getword:=oki_6295_0.read;
    $84010:sbombers_getword:=oki_6295_1.read;
    $88000..$887ff:sbombers_getword:=buffer_paleta[(direccion and $7ff) shr 1];
    $9c000..$9dfff:sbombers_getword:=(bg_ram[direccion and $fff] shl 8) or bg_ram[(direccion+1) and $fff];
    $f0000..$fffff:sbombers_getword:=(ram[direccion and $ffff] shl 8) or ram[(direccion+1) and $ffff];
end;
end;

procedure cambiar_color(tmp_color,numero:word);inline;
var
  color:tcolor;
begin
  color.r:=pal5bit(tmp_color shr 11) or ((tmp_color shr 3) and $01);
  color.g:=pal5bit(tmp_color shr 7) or ((tmp_color shr 2) and $01);
  color.b:=pal5bit(tmp_color shr 3) or ((tmp_color shr 1) and $01);
  set_pal_color(color,numero);
  if (numero<$100) then buffer_color[(numero shr 4) and $f]:=true;
end;

procedure sbombers_putword(direccion:dword;valor:word);
var
  offset:byte;
begin
case direccion of
    $0..$7ffff,$80014,$94002:exit;
    $84000:oki_6295_0.write(valor and $ff);
    $84010:oki_6295_1.write(valor and $ff);
    $84020..$8402f:begin //NMK 112, controla el banco de la ROM del OKI
                     offset:=(direccion and $f) shr 1;
                     if nmk112_bank[offset]<>(valor and $ff) then begin
                       nmk112_bank[offset]:=(valor and $ff);
                       bank_nmk112(offset,valor);
                     end;
                   end;
    $88000..$887ff:if buffer_paleta[(direccion and $7ff) shr 1]<>valor then begin
                      buffer_paleta[(direccion and $7ff) shr 1]:=valor;
                      cambiar_color(valor,(direccion and $7ff) shr 1);
                   end;
    $94000:bg_bank:=valor and $ff;
    $9c000..$9dfff:begin
                      bg_ram[direccion and $fff]:=valor shr 8;
                      bg_ram[(direccion+1) and $fff]:=valor and $ff;
                      gfx[0].buffer[(direccion and $fff) shr 1]:=true;
                   end;
    $f0000..$fffff:begin
                      ram[direccion and $ffff]:=valor shr 8;
                      ram[(direccion+1) and $ffff]:=valor and $ff;
                    end;
  end;
end;

procedure sound_irq;
begin
  main_m68000.irq[1]:=HOLD_LINE;
end;

procedure nmk16_update_sound;
begin
  oki_6295_0.update;
  oki_6295_1.update;
end;

end.
