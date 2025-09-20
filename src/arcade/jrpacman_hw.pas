unit jrpacman_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,namco_snd,controls_engine,gfx_engine,rom_engine,
     pal_engine,sound_engine;

function iniciar_jrpacman:boolean;

implementation

const
        //JR. Pac-man
        jrpacman_rom:array[0..4] of tipo_roms=(
        (n:'jrp8d.bin';l:$2000;p:0;crc:$e3fa972e),(n:'jrp8e.bin';l:$2000;p:$2000;crc:$ec889e94),
        (n:'jrp8h.bin';l:$2000;p:$8000;crc:$35f1fc6e),(n:'jrp8j.bin';l:$2000;p:$a000;crc:$9737099e),
        (n:'jrp8k.bin';l:$2000;p:$c000;crc:$5252dd97));
        jrpacman_pal:array[0..2] of tipo_roms=(
        (n:'jrprom.9e';l:$100;p:$0;crc:$029d35c4),(n:'jrprom.9f';l:$100;p:$100;crc:$eee34a79),
        (n:'jrprom.9p';l:$100;p:$200;crc:$9f6ea9d8));
        jrpacman_char:array[0..1] of tipo_roms=(
        (n:'jrp2c.bin';l:$2000;p:0;crc:$0527ff9b),(n:'jrp2e.bin';l:$2000;p:$2000;crc:$73477193));
        jrpacman_sound:tipo_roms=(n:'jrprom.7p';l:$100;p:0;crc:$a9cc86bf);
        //DIP
        jrpacman_dip_a:array [0..1] of def_dip=(
        (mask:$10;name:'Rack Test (Cheat)';number:2;dip:((dip_val:$10;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        jrpacman_dip_b:array [0..1] of def_dip=(
        (mask:$80;name:'Cabinet';number:2;dip:((dip_val:$80;dip_name:'Upright'),(dip_val:$0;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        jrpacman_dip_c:array [0..4] of def_dip=(
        (mask:$3;name:'Coinage';number:4;dip:((dip_val:$3;dip_name:'2C 1C'),(dip_val:$1;dip_name:'1C 1C'),(dip_val:$2;dip_name:'1C 2C'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Lives';number:4;dip:((dip_val:$0;dip_name:'1'),(dip_val:$4;dip_name:'2'),(dip_val:$8;dip_name:'3'),(dip_val:$c;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Bonus Life';number:4;dip:((dip_val:$0;dip_name:'10K'),(dip_val:$10;dip_name:'15K'),(dip_val:$20;dip_name:'20K'),(dip_val:$30;dip_name:'30K'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Difficulty';number:2;dip:((dip_val:$40;dip_name:'Normal'),(dip_val:$0;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 irq_vblank,bg_prio:boolean;
 gfx_bank,colortable_bank,pal_bank,scroll_x,sprite_bank:byte;

procedure update_video_jrpacman;
var
  color,nchar,offs,color_index:word;
  sx,sy,x,y:byte;
procedure draw_sprites;
var
  f,atrib:byte;
  nchar,color,x,y:word;
begin
//sprites pacman posicion $5060
//byte 0 --> x
//byte 1 --> y
//sprites pacman atributos $4FF0
//byte 0
//      bit 0 --> flipy
//      bit 1 --> flipx
//      bits 2..7 --> numero char
for f:=7 downto 0 do begin
  atrib:=memoria[$4ff0+(f*2)];
  nchar:=(atrib shr 2)+(sprite_bank shl 6);
  color:=((memoria[$4ff1+(f*2)] and $1f) or (colortable_bank shl 5) or (pal_bank shl 6)) shl 2;
  if main_screen.flip_main_screen then begin
    atrib:=atrib xor 3;
    x:=memoria[$5060+(f*2)]-32;
    y:=memoria[$5061+(f*2)];
  end else begin
    x:=240-memoria[$5060+(f*2)]-1;
    y:=272-memoria[$5061+(f*2)];
  end;
  put_gfx_sprite_mask(nchar,color,(atrib and 2)<>0,(atrib and 1)<>0,1,0,$f);
  if ((f=0) or (f=1)) then actualiza_gfx_sprite((x-1) and $ff,y,2,1)
     else actualiza_gfx_sprite(x and $ff,y,2,1);
end;
end;
begin
for x:=0 to 53 do begin
  for y:=0 to 35 do begin
     sx:=55-x;
     sy:=y-2;
	   if (((sy and $20)<>0) and ((sx and $20)<>0)) then offs:=0
	    else if (sy and $20)<>0 then offs:=sx+(((sy and $3) or $38) shl 5)
	      else offs:=sy+(sx shl 5);
     if gfx[0].buffer[offs] then begin
        if offs<$700 then color_index:=offs and $1f
          else color_index:=offs+$80;
        color:=(((memoria[$4000+color_index]) and $1f) or (colortable_bank shl 5) or (pal_bank shl 6)) shl 2;
        nchar:=memoria[$4000+offs]+(gfx_bank shl 8);
        if bg_prio then put_gfx(x*8,y*8,nchar,color,1,0)
          else put_gfx_trans(x*8,y*8,nchar,color,1,0);
        gfx[0].buffer[offs]:=false;
     end;
  end;
end;
if bg_prio then begin
  scroll__x_part(1,2,scroll_x,0,16,256);
  actualiza_trozo(208,0,224,16,1,0,0,224,16,2);
  actualiza_trozo(208,272,224,16,1,0,272,224,16,2);
  draw_sprites;
end else begin
  fill_full_screen(2,$3ff);
  draw_sprites;
  scroll__x_part(1,2,scroll_x,0,16,256);
  actualiza_trozo(208,0,224,16,1,0,0,224,16,2);
  actualiza_trozo(208,272,224,16,1,0,272,224,16,2);
end;
actualiza_trozo_final(0,0,224,288,2);
end;

procedure eventos_jrpacman;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $F7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $Fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  //P2
  if arcade_input.up[1] then marcade.in0:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.down[1] then marcade.in0:=(marcade.in1 and $F7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.left[1] then marcade.in0:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.right[1] then marcade.in0:=(marcade.in1 and $Fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
end;
end;

procedure jrpacman_principal;
var
  frame:single;
  f:word;
begin
init_controls(false,false,false,true);
frame:=z80_0.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to 223 do begin
    z80_0.run(frame);
    frame:=frame+z80_0.tframes-z80_0.contador;
    if f=223 then begin
      update_video_jrpacman;
      if irq_vblank then z80_0.change_irq(HOLD_LINE);
    end;
  end;
  eventos_jrpacman;
  video_sync;
end;
end;

function jrpacman_getbyte(direccion:word):byte;
begin
case direccion of
  0..$4fff,$8000..$dfff:jrpacman_getbyte:=memoria[direccion];
  $5000..$503f:jrpacman_getbyte:=marcade.in0 or marcade.dswa;
  $5040..$507f:jrpacman_getbyte:=marcade.in1 or marcade.dswb;
  $5080..$50bf:jrpacman_getbyte:=marcade.dswc;
end;
end;

procedure jrpacman_putbyte(direccion:word;valor:byte);
procedure clean_tiles(offset:word);
var
  f:byte;
begin
if (offset<$20) then for f:=2 to 55 do gfx[0].buffer[offset+(f*$20)]:=true
  else if (offset<$700) then gfx[0].buffer[offset]:=true
          else gfx[0].buffer[offset and not($80)]:=true;
end;
begin
case direccion of
        $0..$3fff,$8000..$dfff:;
        $4000..$47ff:if memoria[direccion]<>valor then begin
                        clean_tiles(direccion and $7ff);
                        memoria[direccion]:=valor;
                     end;
        $4800..$4fff,$5060..$506f:memoria[direccion]:=valor;
        $5000:irq_vblank:=valor<>0;
        $5001:namco_snd_0.enabled:=(valor and 1)<>0;
        $5003:main_screen.flip_main_screen:=(valor and $1)<>0;
        $5040..$505f:namco_snd_0.regs[direccion and $1f]:=valor;
        $5070:if pal_bank<>valor then begin
                pal_bank:=valor;
                fillchar(gfx[0].buffer,$800,1);
              end;
        $5071:if colortable_bank<>valor then begin
                colortable_bank:=valor;
                fillchar(gfx[0].buffer,$800,1);
              end;
        $5073:if bg_prio<>((valor and 1)=0) then begin
                bg_prio:=(valor and 1)=0;
                fillchar(gfx[0].buffer,$800,1);
              end;
        $5074:if (gfx_bank<>(valor and $1)) then begin
                gfx_bank:=valor and $1;
                fillchar(gfx[0].buffer,$800,1);
              end;
        $5075:sprite_bank:=valor and 1;
        $5080:scroll_x:=208-valor;
end;
end;

procedure jrpacman_sound_update;
begin
  namco_snd_0.update;
end;

procedure jrpacman_outbyte(puerto:word;valor:byte);
begin
if (puerto and $ff)=0 then z80_0.im2_lo:=valor;
end;

//Main
procedure reset_jrpacman;
begin
 z80_0.reset;
 namco_snd_0.reset;
 reset_audio;
 irq_vblank:=false;
 marcade.in0:=$ef;
 marcade.in1:=$7f;
 gfx_bank:=0;
 colortable_bank:=0;
 pal_bank:=0;
 scroll_x:=0;
 sprite_bank:=0;
 bg_prio:=true;
end;

function iniciar_jrpacman:boolean;
type
  tipo_table_dec=record
                    count:word;
                    val:byte;
                 end;
var
  colores:tpaleta;
  h,a:word;
  f,bit0,bit1,bit2:byte;
  memoria_temp:array[0..$ffff] of byte;
  rweights,gweights,bweights:array[0..3] of single;
const
  ps_x:array[0..15] of dword=(8*8, 8*8+1, 8*8+2, 8*8+3, 16*8+0, 16*8+1, 16*8+2, 16*8+3,
			24*8+0, 24*8+1, 24*8+2, 24*8+3, 0, 1, 2, 3);
  ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			32*8, 33*8, 34*8, 35*8, 36*8, 37*8, 38*8, 39*8);
  pc_x:array[0..7] of dword=(8*8+0, 8*8+1, 8*8+2, 8*8+3, 0, 1, 2, 3);
  resistances:array[0..2] of integer=(1000,470,220);
  //Proteccion
  table:array[0..79] of tipo_table_dec=(
  (count:$00C1;val:$00),(count:$0002;val:$80),(count:$0004;val:$00),(count:$0006;val:$80),
  (count:$0003;val:$00),(count:$0002;val:$80),(count:$0009;val:$00),(count:$0004;val:$80),
  (count:$9968;val:$00),(count:$0001;val:$80),(count:$0002;val:$00),(count:$0001;val:$80),
  (count:$0009;val:$00),(count:$0002;val:$80),(count:$0009;val:$00),(count:$0001;val:$80),
  (count:$00AF;val:$00),(count:$000E;val:$04),(count:$0002;val:$00),(count:$0004;val:$04),
  (count:$001E;val:$00),(count:$0001;val:$80),(count:$0002;val:$00),(count:$0001;val:$80),
  (count:$0002;val:$00),(count:$0002;val:$80),(count:$0009;val:$00),(count:$0002;val:$80),
  (count:$0009;val:$00),(count:$0002;val:$80),(count:$0083;val:$00),(count:$0001;val:$04),
  (count:$0001;val:$01),(count:$0001;val:$00),(count:$0002;val:$05),(count:$0001;val:$00),
  (count:$0003;val:$04),(count:$0003;val:$01),(count:$0002;val:$00),(count:$0001;val:$04),
  (count:$0003;val:$01),(count:$0003;val:$00),(count:$0003;val:$04),(count:$0001;val:$01),
  (count:$002E;val:$00),(count:$0078;val:$01),(count:$0001;val:$04),(count:$0001;val:$05),
  (count:$0001;val:$00),(count:$0001;val:$01),(count:$0001;val:$04),(count:$0002;val:$00),
  (count:$0001;val:$01),(count:$0001;val:$04),(count:$0002;val:$00),(count:$0001;val:$01),
  (count:$0001;val:$04),(count:$0002;val:$00),(count:$0001;val:$01),(count:$0001;val:$04),
  (count:$0001;val:$05),(count:$0001;val:$00),(count:$0001;val:$01),(count:$0001;val:$04),
  (count:$0002;val:$00),(count:$0001;val:$01),(count:$0001;val:$04),(count:$0002;val:$00),
  (count:$0001;val:$01),(count:$0001;val:$04),(count:$0001;val:$05),(count:$0001;val:$00),
  (count:$01B0;val:$01),(count:$0001;val:$00),(count:$0002;val:$01),(count:$00AD;val:$00),
  (count:$0031;val:$01),(count:$005C;val:$00),(count:$0005;val:$01),(count:$604E;val:$00));
begin
llamadas_maquina.bucle_general:=jrpacman_principal;
llamadas_maquina.reset:=reset_jrpacman;
llamadas_maquina.fps_max:=60.6060606060;
iniciar_jrpacman:=false;
iniciar_audio(false);
screen_init(1,432,288,true);
screen_mod_scroll(1,512,256,511,256,256,255);
screen_init(2,224,288,false,true);
screen_mod_sprites(2,256,512,$ff,$1ff);
iniciar_video(224,288);
//Main CPU
z80_0:=cpu_z80.create(3072000,224);
z80_0.change_ram_calls(jrpacman_getbyte,jrpacman_putbyte);
z80_0.change_io_calls(nil,jrpacman_outbyte);
z80_0.init_sound(jrpacman_sound_update);
namco_snd_0:=namco_snd_chip.create(3);
//cargar roms
if not(roms_load(@memoria_temp,jrpacman_rom)) then exit;
a:=0;
for f:=0 to 79 do begin
    for h:=0 to table[f].count-1 do begin
        memoria[a]:=memoria_temp[a] xor table[f].val;
        a:=a+1;
    end;
end;
//cargar & iniciar sonido
if not(roms_load(namco_snd_0.get_wave_dir,jrpacman_sound)) then exit;
//convertir chars
if not(roms_load(@memoria_temp,jrpacman_char)) then exit;
init_gfx(0,8,8,$200);
gfx[0].trans[0]:=true;
gfx_set_desc_data(2,0,16*8,0,4);
convert_gfx(0,0,@memoria_temp,@pc_x,@ps_y,true,false);
//convertir sprites
init_gfx(1,16,16,$80);
gfx_set_desc_data(2,0,64*8,0,4);
convert_gfx(1,0,@memoria_temp[$2000],@ps_x,@ps_y,true,false);
//poner la paleta
if not(roms_load(@memoria_temp,jrpacman_pal)) then exit;
compute_resistor_weights(0,	255, -1.0,
			3,@resistances,@rweights,0,0,
			3,@resistances,@gweights,0,0,
	    2,@resistances[1],@bweights,0,0);
for f:=0 to $ff do begin
  h:=(memoria_temp[f] and $f)+((memoria_temp[f+$100] and $f) shl 4);
	// red component */
	bit0:=(h shr 0) and $01;
	bit1:=(h shr 1) and $01;
	bit2:=(h shr 2) and $01;
	colores[f].r:=combine_3_weights(@rweights[0], bit0, bit1, bit2);
	// green component */
	bit0:=(h shr 3) and $01;
	bit1:=(h shr 4) and $01;
	bit2:=(h shr 5) and $01;
	colores[f].g:=combine_3_weights(@gweights[0], bit0, bit1, bit2);
	// blue component */
	bit0:=(h shr 6) and $01;
	bit1:=(h shr 7) and $01;
	colores[f].b:=combine_2_weights(@bweights[0], bit0, bit1);
  //Indirect tables
  gfx[0].colores[f]:=memoria_temp[$200+f] and $f;
  gfx[1].colores[f]:=memoria_temp[$200+f] and $f;
  gfx[0].colores[f+$100]:=(memoria_temp[$200+f] and $f)+$10;
  gfx[1].colores[f+$100]:=(memoria_temp[$200+f] and $f)+$10;
end;
set_pal(colores,$100);
//DIP
marcade.dswa:=$10;
marcade.dswb:=$80;
marcade.dswc:=$c9;
marcade.dswa_val:=@jrpacman_dip_a;
marcade.dswb_val:=@jrpacman_dip_b;
marcade.dswc_val:=@jrpacman_dip_c;
//final
reset_jrpacman;
iniciar_jrpacman:=true;
end;

end.
