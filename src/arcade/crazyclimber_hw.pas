unit crazyclimber_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,ay_8910,gfx_engine,rom_engine,
     pal_engine,sound_engine,crazyclimber_hw_dac;

function iniciar_cclimber:boolean;

implementation
const
        cclimber_rom:array[0..4] of tipo_roms=(
        (n:'cc11';l:$1000;p:0;crc:$217ec4ff),(n:'cc10';l:$1000;p:$1000;crc:$b3c26cef),
        (n:'cc09';l:$1000;p:$2000;crc:$6db0879c),(n:'cc08';l:$1000;p:$3000;crc:$f48c5fe3),
        (n:'cc07';l:$1000;p:$4000;crc:$3e873baf));
        cclimber_pal:array[0..2] of tipo_roms=(
        (n:'cclimber.pr1';l:$20;p:0;crc:$751c3325),(n:'cclimber.pr2';l:$20;p:$20;crc:$ab1940fa),
        (n:'cclimber.pr3';l:$20;p:$40;crc:$71317756));
        cclimber_char:array[0..3] of tipo_roms=(
        (n:'cc06';l:$800;p:0;crc:$481b64cc),(n:'cc05';l:$800;p:$1000;crc:$2c33b760),
        (n:'cc04';l:$800;p:$2000;crc:$332347cb),(n:'cc03';l:$800;p:$3000;crc:$4e4b3658));
        cclimber_bigsprites:array[0..1] of tipo_roms=(
        (n:'cc02';l:$800;p:$0;crc:$14f3ecc9),(n:'cc01';l:$800;p:$800;crc:$21c0f9fb));
        cclimber_samples:array[0..1] of tipo_roms=(
        (n:'cc13';l:$1000;p:$0;crc:$e0042f75),(n:'cc12';l:$1000;p:$1000;crc:$5da13aaa));
        //DIP
        cclimber_dip_a:array [0..3] of def_dip=(
        (mask:$3;name:'Lives';number:4;dip:((dip_val:$0;dip_name:'3'),(dip_val:$1;dip_name:'4'),(dip_val:$2;dip_name:'5'),(dip_val:$3;dip_name:'6'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Coin A';number:4;dip:((dip_val:$30;dip_name:'4C 1C'),(dip_val:$20;dip_name:'3C 1C'),(dip_val:$10;dip_name:'2C 1C'),(dip_val:$0;dip_name:'1C 1C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Coin B';number:4;dip:((dip_val:$0;dip_name:'1C 1C'),(dip_val:$40;dip_name:'1C 2C'),(dip_val:$80;dip_name:'1C 3C'),(dip_val:$c0;dip_name:'Free Play'),(),(),(),(),(),(),(),(),(),(),(),())),());
        cclimber_dip_b:array [0..1] of def_dip=(
        (mask:$10;name:'Cabinet';number:2;dip:((dip_val:$10;dip_name:'Upright'),(dip_val:$0;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 nmi_mask:boolean;
 mem_decode:array[0..$5fff] of byte;
 scroll_y:array[0..$1f] of word;

procedure draw_sprites;inline;
var
  f,x,y,nchar,attr,attr2,color:byte;
  flipx,flipy:boolean;
begin
for f:=$7 downto 0 do begin
    x:=memoria[$9883+(f*4)]+1;
    y:=240-memoria[$9882+(f*4)];
    attr:=memoria[(f*4)+$9881];
    attr2:=memoria[(f*4)+$9880];
    nchar:=((attr and $10) shl 3) or ((attr and $20) shl 1) or (attr2 and $3f);
    color:=(attr and $0f) shl 2;
		flipx:=(attr2 and $40)<>0;
		flipy:=(attr2 and $80)<>0;
    put_gfx_sprite_mask(nchar,color,flipx,flipy,1,0,3);
    actualiza_gfx_sprite(x,y,3,1);
end;
end;

procedure update_video_cclimber;inline;
var
  f,tile_index,nchar:word;
  color,attr,x,y:byte;
  flipx,flipy,bs_changed:boolean;
begin
bs_changed:=false;
for f:=0 to $3ff do begin
  //Fondo
  attr:=memoria[f+$9c00];
  flipy:=(attr and $20)<>0;
  tile_index:=f;
  if flipy then tile_index:=tile_index xor $20;
  if gfx[0].buffer[tile_index] then begin
    flipx:=(attr and $40)<>0;
    attr:=memoria[tile_index+$9c00];
    x:=f mod 32;
    y:=f div 32;
    color:=(attr and $f) shl 2;
    nchar:=((attr and $10) shl 5) or ((attr and $20) shl 3) or memoria[$9000+tile_index];
    put_gfx_flip(x*8,y*8,nchar,color,1,0,flipx,flipy);
    gfx[0].buffer[tile_index]:=false;
  end;
  //Sprites grandes
  tile_index:=((f and $1e0) shr 1) or (f and $f);
  if gfx[2].buffer[tile_index] then begin
    x:=f mod 32;
    y:=f div 32;
    if (f and $210)=$210 then begin
      attr:=memoria[$98dd];
      color:=(attr and $7) shl 2;
      nchar:=((attr and $08) shl 5) or memoria[$8800+tile_index];
      put_gfx_mask(x*8,y*8,nchar,color+64,2,2,0,$3);
      gfx[2].buffer[tile_index]:=false;
      bs_changed:=true;
    end else put_gfx_block_trans(x*8,y*8,2,8,8);
  end;
end;
//La pantalla de los sprites grandes, puede invertir el eje x y/o el y
flipx:=(memoria[$98dd] and $10)<>0;
flipy:=(memoria[$98dd] and $20)<>0;
if bs_changed then flip_surface(2,flipx,flipy);
x:=memoria[$98df]-$8-(byte(flipx)*$80)-(byte(main_screen.flip_main_screen)*$27);
y:=memoria[$98de]-(byte(flipy)*$80);
//Poner todo en su sitio
scroll__y_part2(1,3,8,@scroll_y);
//for f:=0 to 31 do scroll__y_part(1,3,memoria[$9800+f],0,f*8,8);
if (memoria[$98dc] and 1)<>0 then begin
  scroll_x_y(2,3,x,y);
  draw_sprites;
end else begin
  draw_sprites;
  scroll_x_y(2,3,x,y);
end;
actualiza_trozo_final(0,16,256,224,3);
end;

procedure eventos_cclimber;inline;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 or $1) else marcade.in0:=(marcade.in0 and $fe);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 or $2) else marcade.in0:=(marcade.in0 and $fd);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 or $4) else marcade.in0:=(marcade.in0 and $fb);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 or $8) else marcade.in0:=(marcade.in0 and $f7);
  if arcade_input.up[1] then marcade.in0:=(marcade.in0 or $10) else marcade.in0:=(marcade.in0 and $ef);
  if arcade_input.down[1] then marcade.in0:=(marcade.in0 or $20) else marcade.in0:=(marcade.in0 and $df);
  if arcade_input.left[1] then marcade.in0:=(marcade.in0 or $40) else marcade.in0:=(marcade.in0 and $bf);
  if arcade_input.right[1] then marcade.in0:=(marcade.in0 or $80) else marcade.in0:=(marcade.in0 and $7f);
  //P2
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 or $1) else marcade.in1:=(marcade.in1 and $fe);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 or $2) else marcade.in1:=(marcade.in1 and $fd);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 or $4) else marcade.in1:=(marcade.in1 and $fb);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 or $8) else marcade.in1:=(marcade.in1 and $f7);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 or $10) else marcade.in1:=(marcade.in1 and $ef);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 or $20) else marcade.in1:=(marcade.in1 and $df);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 or $40) else marcade.in1:=(marcade.in1 and $bf);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 or $80) else marcade.in1:=(marcade.in1 and $7f);
  //SYSTEM
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 or $1) else marcade.in2:=(marcade.in2 and $fe);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 or $2) else marcade.in2:=(marcade.in2 and $fd);
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 or $4) else marcade.in2:=(marcade.in2 and $fb);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 or $8) else marcade.in2:=(marcade.in2 and $f7);
end;
end;

procedure cclimber_principal;
var
  f:byte;
  frame:single;
begin
init_controls(false,false,false,true);
frame:=z80_0.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
    //main
    z80_0.run(frame);
    frame:=frame+z80_0.tframes-z80_0.contador;
    if f=239 then begin
      if nmi_mask then z80_0.change_nmi(PULSE_LINE);
      update_video_cclimber;
    end;
  end;
  eventos_cclimber;
  video_sync;
end;
end;

function cclimber_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$5fff:if z80_0.opcode then cclimber_getbyte:=mem_decode[direccion]
              else cclimber_getbyte:=memoria[direccion];
  $6000..$6bff,$8000..$83ff,$8800..$8bff,$9820..$9fff:cclimber_getbyte:=memoria[direccion];
  $9000..$97ff:cclimber_getbyte:=memoria[$9000+(direccion and $3ff)];
  $9800..$981f:cclimber_getbyte:=scroll_y[direccion and $1f];
  $a000:cclimber_getbyte:=marcade.in0;
  $a800:cclimber_getbyte:=marcade.in1;
  $b000:cclimber_getbyte:=marcade.dswa;
  $b800:cclimber_getbyte:=marcade.dswb or marcade.in2;
end;
end;

procedure cclimber_putbyte(direccion:word;valor:byte);
begin
case direccion of
   0..$5fff:; //ROM
   $6000..$6bff,$8000..$83ff,$8900..$8bff,$9820..$98dc,$98de..$9bff:memoria[direccion]:=valor;
   $8800..$88ff:if memoria[direccion]<>valor then begin
                  memoria[direccion]:=valor;
                  gfx[2].buffer[direccion and $ff]:=true;
                end;
   $9000..$97ff:if memoria[$9000+(direccion and $3ff)]<>valor then begin
                  memoria[$9000+(direccion and $3ff)]:=valor;
                  gfx[0].buffer[direccion and $3ff]:=true;
                end;
   $9800..$981f:scroll_y[direccion and $1f]:=valor;
   $98dd:if memoria[$98dd]<>valor then begin
            fillchar(gfx[2].buffer,$400,1);
            memoria[$98dd]:=valor;
         end;
   $9c00..$9fff:begin
                  memoria[$9c00+((direccion and $3ff) and not($20))]:=valor;
                  gfx[0].buffer[(direccion and $3ff) and not($20)]:=true;
                  memoria[$9c00+((direccion and $3ff) or $20)]:=valor;
                  gfx[0].buffer[(direccion and $3ff) or $20]:=true;
                end;
   $a000,$a003:nmi_mask:=(valor and $1)<>0;
   $a001..$a002:main_screen.flip_main_screen:=(valor and 1)<>0;
   $a004:if valor<>0 then cclimber_audio.trigger_w;
   $a800:cclimber_audio.change_freq(valor);
   $b000:cclimber_audio.change_volume(valor);
end;
end;

function cclimber_inbyte(port:word):byte;
begin
if (port and $ff)=$c then cclimber_inbyte:=ay8910_0.Read;
end;

procedure cclimber_outbyte(port:word;valor:byte);
begin
case (port and $ff) of
     $8:ay8910_0.control(valor);
     $9:ay8910_0.write(valor);
end;
end;

procedure cclimber_porta_write(valor:byte);
begin
  cclimber_audio.change_sample(valor);
end;

procedure cclimber_sound_update;
begin
  ay8910_0.update;
  cclimber_audio.update;
end;

//Main
procedure reset_cclimber;
begin
 z80_0.reset;
 ay8910_0.reset;
 cclimber_audio.reset;
 reset_audio;
 marcade.in0:=0;
 marcade.in1:=0;
 marcade.in2:=0;
 nmi_mask:=false;
end;

procedure cclimber_decode;
var
  f:word;
  i,j,src:byte;
const
  convtable:array[0..7,0..15] of byte=(
		// 0xff marks spots which are unused and therefore unknown */
		( $44,$14,$54,$10,$11,$41,$05,$50,$51,$00,$40,$55,$45,$04,$01,$15 ),
		( $44,$10,$15,$55,$00,$41,$40,$51,$14,$45,$11,$50,$01,$54,$04,$05 ),
		( $45,$10,$11,$44,$05,$50,$51,$04,$41,$14,$15,$40,$01,$54,$55,$00 ),
		( $04,$51,$45,$00,$44,$10,$ff,$55,$11,$54,$50,$40,$05,$ff,$14,$01 ),
		( $54,$51,$15,$45,$44,$01,$11,$41,$04,$55,$50,$ff,$00,$10,$40,$ff ),
		( $ff,$54,$14,$50,$51,$01,$ff,$40,$41,$10,$00,$55,$05,$44,$11,$45 ),
		( $51,$04,$10,$ff,$50,$40,$00,$ff,$41,$01,$05,$15,$11,$14,$44,$54 ),
		( $ff,$ff,$54,$01,$15,$40,$45,$41,$51,$04,$50,$05,$11,$44,$10,$14 ));
begin
	for f:=0 to $5fff do begin
		src:=memoria[f];
		// pick the translation table from bit 0 of the address */
		// and from bits 1 7 of the source data */
		i:=(f and 1) or (src and $2) or ((src and $80) shr 5);
		// pick the offset in the table from bits 0 2 4 6 of the source data */
		j:=(src and $01) or ((src and $04) shr 1) or ((src and $10) shr 2) or ((src and $40) shr 3);
		// decode the opcodes */
 		mem_decode[f]:=(src and $aa) or convtable[i,j];
  end;
end;

function iniciar_cclimber:boolean;
var
  colores:tpaleta;
  f:word;
  memoria_temp:array[0..$3fff] of byte;
  bit0,bit1,bit2:byte;
  rg_weights:array[0..2] of single;
  b_weights:array[0..1] of single;
const
    ps_x:array[0..15] of dword=(0, 1, 2, 3, 4, 5, 6, 7,
			8*8+0, 8*8+1, 8*8+2, 8*8+3, 8*8+4, 8*8+5, 8*8+6, 8*8+7);
    ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			16*8, 17*8, 18*8, 19*8, 20*8, 21*8, 22*8, 23*8);
    resistances_rg:array[0..2] of integer=(1000,470,220);
    resistances_b:array[0..1] of integer=(470,220);
begin
llamadas_maquina.bucle_general:=cclimber_principal;
llamadas_maquina.reset:=reset_cclimber;
iniciar_cclimber:=false;
iniciar_audio(false);
screen_init(1,256,256);
screen_mod_scroll(1,256,256,255,256,256,255);
screen_init(2,256,256,true);
screen_mod_scroll(2,256,256,255,256,256,255);
screen_init(3,256,256,false,true);
iniciar_video(256,224);
//Main CPU
z80_0:=cpu_z80.create(18432000 div 3 div 2,256);
z80_0.change_ram_calls(cclimber_getbyte,cclimber_putbyte);
z80_0.change_io_calls(cclimber_inbyte,cclimber_outbyte);
z80_0.init_sound(cclimber_sound_update);
//Sound Chips
ay8910_0:=ay8910_chip.create(3072000 div 2,AY8910,1);
ay8910_0.change_io_calls(nil,nil,cclimber_porta_write,nil);
cclimber_audio:=tcclimber_audio.create;
//cargar y desencriptar las ROMS
if not(roms_load(@memoria,cclimber_rom)) then exit;
cclimber_decode;
//samples
if not(roms_load(cclimber_audio.get_rom_addr,cclimber_samples)) then exit;
//convertir chars
if not(roms_load(@memoria_temp,cclimber_char)) then exit;
init_gfx(0,8,8,$400);
gfx_set_desc_data(2,0,8*8,0,$400*8*8);
convert_gfx(0,0,@memoria_temp,@ps_x,@ps_y,false,false);
//convertir sprites
init_gfx(1,16,16,$100);
gfx_set_desc_data(2,0,32*8,0,$100*8*32);
convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,false);
//big sprites
if not(roms_load(@memoria_temp,cclimber_bigsprites)) then exit;
init_gfx(2,8,8,$100);
gfx_set_desc_data(2,0,8*8,0,$100*8*8);
convert_gfx(2,0,@memoria_temp,@ps_x,@ps_y,false,false);
//poner la paleta
if not(roms_load(@memoria_temp,cclimber_pal)) then exit;
compute_resistor_weights(0,	255, -1.0,
			3,@resistances_rg,@rg_weights,0,0,
			3,@resistances_b,@b_weights,0,0,
			0,nil,nil,0,0);
for f:=0 to $5f do begin
		// red component */
		bit0:=(memoria_temp[f] shr 0) and $01;
		bit1:=(memoria_temp[f] shr 1) and $01;
		bit2:=(memoria_temp[f] shr 2) and $01;
		colores[f].r:=combine_3_weights(@rg_weights, bit0, bit1, bit2);
		// green component */
		bit0:=(memoria_temp[f] shr 3) and $01;
		bit1:=(memoria_temp[f] shr 4) and $01;
		bit2:=(memoria_temp[f] shr 5) and $01;
		colores[f].g:=combine_3_weights(@rg_weights, bit0, bit1, bit2);
		// blue component */
		bit0:=(memoria_temp[f] shr 6) and $01;
		bit1:=(memoria_temp[f] shr 7) and $01;
		colores[f].b:=combine_2_weights(@b_weights, bit0, bit1);
end;
set_pal(colores,$60);
//DIP
marcade.dswa:=0;
marcade.dswb:=$10;
marcade.dswa_val:=@cclimber_dip_a;
marcade.dswb_val:=@cclimber_dip_b;
//final
reset_cclimber;
iniciar_cclimber:=true;
end;

end.
