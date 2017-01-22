unit bioniccommando_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,m68000,main_engine,controls_engine,gfx_engine,ym_2151,rom_engine,
     pal_engine,sound_engine,timer_engine;

procedure cargar_bionicc;

implementation
const
        bionicc_rom:array[0..4] of tipo_roms=(
        (n:'tse_02.1a';l:$10000;p:0;crc:$e4aeefaa),(n:'tse_04.1b';l:$10000;p:$1;crc:$d0c8ec75),
        (n:'tse_03.2a';l:$10000;p:$20000;crc:$b2ac0a45),(n:'tse_05.2b';l:$10000;p:$20001;crc:$a79cb406),());
        bionicc_char:tipo_roms=(n:'tsu_08.8l';l:$8000;p:0;crc:$9bf0b7a2);
        bionicc_sound:tipo_roms=(n:'ts_01b.4e';l:$8000;p:0;crc:$a9a6cafa);
        bionicc_bg:array[0..1] of tipo_roms=(
        (n:'tsu_07.5l';l:$8000;p:0;crc:$9469efa4),(n:'tsu_06.4l';l:$8000;p:$8000;crc:$40bf0eb4));
        bionicc_fg:array[0..7] of tipo_roms=(
        (n:'ts_12.17f';l:$8000;p:0;crc:$e4b4619e),(n:'ts_11.15f';l:$8000;p:$8000;crc:$ab30237a),
        (n:'ts_17.17g';l:$8000;p:$10000;crc:$deb657e4),(n:'ts_16.15g';l:$8000;p:$18000;crc:$d363b5f9),
        (n:'ts_13.18f';l:$8000;p:$20000;crc:$a8f5a004),(n:'ts_18.18g';l:$8000;p:$28000;crc:$3b36948c),
        (n:'ts_23.18j';l:$8000;p:$30000;crc:$bbfbe58a),(n:'ts_24.18k';l:$8000;p:$38000;crc:$f156e564));
        bionicc_sprites:array[0..7] of tipo_roms=(
        (n:'tse_10.13f';l:$8000;p:0;crc:$d28eeacc),(n:'tsu_09.11f';l:$8000;p:$8000;crc:$6a049292),
        (n:'tse_15.13g';l:$8000;p:$10000;crc:$9b5593c0),(n:'tsu_14.11g';l:$8000;p:$18000;crc:$46b2ad83),
        (n:'tse_20.13j';l:$8000;p:$20000;crc:$b03db778),(n:'tsu_19.11j';l:$8000;p:$28000;crc:$b5c82722),
        (n:'tse_22.17j';l:$8000;p:$30000;crc:$d4dedeb3),(n:'tsu_21.15j';l:$8000;p:$38000;crc:$98777006));
        //DIP
        bionicc_dip:array [0..8] of def_dip=(
        (mask:$7;name:'Coin A';number:8;dip:((dip_val:$0;dip_name:'4C 1C'),(dip_val:$1;dip_name:'3C 1C'),(dip_val:$2;dip_name:'2C 1C'),(dip_val:$7;dip_name:'1C 1C'),(dip_val:$6;dip_name:'1C 2C'),(dip_val:$5;dip_name:'1C 3C'),(dip_val:$4;dip_name:'1C 4C'),(dip_val:$3;dip_name:'1C 6C'),(),(),(),(),(),(),(),())),
        (mask:$38;name:'Coin B';number:8;dip:((dip_val:$0;dip_name:'4C 1C'),(dip_val:$8;dip_name:'3C 1C'),(dip_val:$10;dip_name:'2C 1C'),(dip_val:$38;dip_name:'1C 1C'),(dip_val:$30;dip_name:'1C 2C'),(dip_val:$28;dip_name:'1C 3C'),(dip_val:$20;dip_name:'1C 4C'),(dip_val:$18;dip_name:'1C 6C'),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Flip Screen';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$300;name:'Lives';number:4;dip:((dip_val:$300;dip_name:'3'),(dip_val:$200;dip_name:'4'),(dip_val:$100;dip_name:'5'),(dip_val:$0;dip_name:'7'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$400;name:'Cabinet';number:2;dip:((dip_val:$400;dip_name:'Upright'),(dip_val:$0;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$1800;name:'Bonus Life';number:4;dip:((dip_val:$1800;dip_name:'20k 40k 100k 60k+'),(dip_val:$1000;dip_name:'30k 50k 120k 70k+'),(dip_val:$800;dip_name:'20k 60k'),(dip_val:$0;dip_name:'30k 70k'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$6000;name:'Difficulty';number:4;dip:((dip_val:$4000;dip_name:'Easy'),(dip_val:$6000;dip_name:'Medium'),(dip_val:$2000;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8000;name:'Freeze';number:2;dip:((dip_val:$8000;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 scroll_fg_x,scroll_fg_y,scroll_bg_x,scroll_bg_y,sound_latch:word;
 rom:array[0..$1ffff] of word;
 ram,ram2,fg_ram,bg_ram:array[0..$1fff] of word;
 txt_ram:array[0..$7ff] of word;
 input:array[0..2] of word;

procedure update_video_bionicc;inline;
var
  f,color,x,y,nchar,atrib:word;
  sx,sy,pos:word;
begin
fill_full_screen(3,1024);
for f:=$0 to $440 do begin
  //BG
  x:=f mod 33;
  y:=f div 33;
  sx:=x+((scroll_bg_x and $1F8) shr 3);
  sy:=y+((scroll_bg_y and $1f8) shr 3);
  pos:=(sx and $3f)+((sy and $3f)*64);
  atrib:=bg_ram[(pos shl 1)+1] and $ff;
  color:=(atrib and $18) shr 3;
  if (gfx[1].buffer[pos] or buffer_color[color+$40]) then begin
    nchar:=(bg_ram[pos shl 1] and $ff) or ((atrib and $7) shl 8);
    put_gfx_trans_flip(x*8,y*8,nchar,color shl 4,4,1,(atrib and $80)<>0,(atrib and $40)<>0);
    gfx[1].buffer[f]:=false;
  end;
end;
  //FG
for f:=$0 to $120 do begin // $121=17*17
  x:=f mod 17; //17 --> numero de filas (numero de x) que queremos
  y:=f div 17;
  //scroll and [numero_maximo_scroll-long_gfx_x] shr [numero bits long_gfx_x] (por ejemplo 16 bits --> shr 4)
  sx:=x+((scroll_fg_x and $3F0) shr 4);
  sy:=y+((scroll_fg_y and $3f0) shr 4);
  //sx and [numero_maximo_scroll-long_gfx_x] shr [numero bits long_gfx_x] por ejemplo antes $3f0 shr 4=$3f
  //(sy and [igual que antes])*[numero de filas de la pantalla total] (este caso 1024/16=64)
  pos:=(sx and $3f)+((sy and $3f)*64);
  atrib:=fg_ram[(pos shl 1)+1] and $ff;
  if (atrib and $c0)<>$c0 then begin
    color:=(atrib and $18) shr 3;
    if (gfx[2].buffer[pos] or buffer_color[color+$44]) then begin
      nchar:=(fg_ram[pos shl 1] and $ff) or ((atrib and $7) shl 8);
      if (atrib and $20)=0 then begin
        put_gfx_trans_flip_alt(x*16,y*16,nchar,(color shl 4)+256,5,2,(atrib and $80)<>0,(atrib and $40)<>0,0);
        put_gfx_block_trans(x*16,y*16,6,16,16)
      end else begin
        put_gfx_trans_flip_alt(x*16,y*16,nchar,(color shl 4)+256,6,2,(atrib and $80)<>0,(atrib and $40)<>0,1);
        put_gfx_block_trans(x*16,y*16,5,16,16)
      end;
      gfx[2].buffer[pos]:=false;
    end;
  end;
end;
//text
for f:=$0 to $3ff do begin
  atrib:=txt_ram[$400+f] and $ff;
  color:=atrib and $3f;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
    x:=f and $1f;
    y:=f shr 5;
    nchar:=(txt_ram[f] and $ff) or ((atrib and $c0) shl 2);
    put_gfx_trans(x*8,y*8,nchar,(color shl 2)+768,1,0);
    gfx[0].buffer[f]:=false;
  end;
end;
// back
scroll_x_y(4,3,scroll_bg_x and $7,scroll_bg_y and $7);
scroll_x_y(5,3,scroll_fg_x and $f,scroll_fg_y and $f);
//sprites
for f:=$9f downto 0 do begin
  nchar:=buffer_sprites_w[f*4] and $7ff;
  if nchar<>$7ff then begin
    atrib:=buffer_sprites_w[(f*4)+1];
    color:=((atrib and $3c) shl 2)+512;
    y:=buffer_sprites_w[(f*4)+2];
    x:=buffer_sprites_w[(f*4)+3];
    put_gfx_sprite(nchar,color,(atrib and 2)<>0,false,3);
    actualiza_gfx_sprite_over(x,y,3,3,6,scroll_fg_x,scroll_fg_y);
  end;
end;
//front
scroll_x_y(6,3,scroll_fg_x and $f,scroll_fg_y and $f);
actualiza_trozo(0,0,256,256,1,0,0,256,256,3);
actualiza_trozo_final(0,16,256,224,3);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure eventos_bionicc;inline;
begin
if event.arcade then begin
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $Fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  //system
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $b) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $d) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $e) else marcade.in0:=(marcade.in0 or $1);
end;
end;

procedure bionicc_principal;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
frame_s:=z80_0.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to $ff do begin
    //main
    m68000_0.run(frame_m);
    frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
    //sound
    z80_0.run(frame_s);
    frame_s:=frame_s+z80_0.tframes-z80_0.contador;
    case f of
    239:begin
          m68000_0.irq[2]:=HOLD_LINE;
          update_video_bionicc;
          copymemory(@buffer_sprites_w,@ram[$400],$280*2);
        end;
    255:m68000_0.irq[4]:=HOLD_LINE;
    end;
 end;
 eventos_bionicc;
 video_sync;
end;
end;

function bionicc_getword(direccion:dword):word;
begin
case direccion of
    0..$3ffff:bionicc_getword:=rom[direccion shr 1];
    $fe0000..$fe3fff:bionicc_getword:=ram[(direccion and $3fff) shr 1];
    $fe4000:bionicc_getword:=(marcade.in0 shl 12)+$fff;
    $fe4002:bionicc_getword:=marcade.dswa;
    $fec000..$fecfff:bionicc_getword:=txt_ram[(direccion and $fff) shr 1];
    $ff0000..$ff3fff:bionicc_getword:=fg_ram[(direccion and $3fff) shr 1];
    $ff4000..$ff7fff:bionicc_getword:=bg_ram[(direccion and $3fff) shr 1];
    $ff8000..$ff87ff:bionicc_getword:=buffer_paleta[(direccion and $7ff) shr 1];
    $ffc000..$fffff7:bionicc_getword:=ram2[(direccion and $3fff) shr 1];
    $fffff8..$fffff9:bionicc_getword:=sound_latch;
    $fffffa..$ffffff:bionicc_getword:=input[(direccion-$fffffa) shr 1];
end;
end;

procedure cambiar_color(pos,data:word);inline;
var
  bright:byte;
  color:tcolor;
begin
  bright:=data and $0f;
  color.r:=((data shr 12) and $0f)*$11;
  color.g:=((data shr 8) and $0f)*$11;
  color.b:=((data shr 4) and $0f)*$11;
  if ((bright and $08)=0) then begin
    color.r:=color.r*($07+bright) div $0e;
    color.g:=color.g*($07+bright) div $0e;
    color.b:=color.b*($07+bright) div $0e;
  end;
  set_pal_color(color,pos);
  case pos of
    0..63:buffer_color[(pos shr 4)+$40]:=true;
    256..319:buffer_color[((pos shr 4) and $3)+$44]:=true;
    768..1023:buffer_color[(pos shr 2) and $3f]:=true;
  end;
end;

procedure bionicc_mpu_trigger_w;inline;
begin
  input[0]:=marcade.in0 xor $f;
  input[1]:=0;
  input[2]:=marcade.in1 xor $ff;
end;

procedure bionicc_putword(direccion:dword;valor:word);
begin
if direccion<$40000 then exit;
case direccion of
    $fe0000..$fe3fff:ram[(direccion and $3fff) shr 1]:=valor;
    $fe8010:if scroll_fg_x<>valor then begin
              if abs((scroll_fg_x and $3f0)-(valor and $3f0))>15 then fillchar(gfx[2].buffer[0],$1000,1);
              scroll_fg_x:=valor and $3ff;
            end;
    $fe8012:if scroll_fg_y<>valor then begin
              if abs((scroll_fg_y and $3f0)-(valor and $3f0))>15 then fillchar(gfx[2].buffer[0],$1000,1);
              scroll_fg_y:=valor and $3ff;
            end;
    $fe8014:if scroll_bg_x<>valor then begin
              if abs((scroll_bg_x and $1f8)-(valor and $1f8))>7 then fillchar(gfx[1].buffer[0],$1000,1);
              scroll_bg_x:=valor and $1ff;
            end;
    $fe8016:if scroll_bg_y<>valor then begin
              if abs((scroll_bg_y and $1f8)-(valor and $1f8))>7 then fillchar(gfx[1].buffer[0],$1000,1);
              scroll_bg_y:=valor and $1ff;
            end;
    $fe801a..$fe801b:bionicc_mpu_trigger_w;
    $fec000..$fecfff:if txt_ram[(direccion and $fff) shr 1]<>valor then begin
                    txt_ram[(direccion and $fff) shr 1]:=valor;
                    gfx[0].buffer[(direccion and $7ff) shr 1]:=true;
                  end;
    $ff0000..$ff3fff:if fg_ram[(direccion and $3fff) shr 1]<>valor then begin
                    fg_ram[(direccion and $3fff) shr 1]:=valor;
                    gfx[1].buffer[(direccion and $3fff) shr 2]:=true;
                  end;
    $ff4000..$ff7fff:if bg_ram[(direccion and $3fff) shr 1]<>valor then begin
                    bg_ram[(direccion and $3fff) shr 1]:=valor;
                    gfx[2].buffer[(direccion and $3fff) shr 2]:=true;
                  end;
    $ff8000..$ff87ff:if (buffer_paleta[(direccion and $7ff) shr 1]<>valor) then begin
                    buffer_paleta[(direccion and $7ff) shr 1]:=valor;
                    cambiar_color((direccion and $7ff) shr 1,valor);
                  end;
    $ffc000..$fffff7:ram2[(direccion and $3fff) shr 1]:=valor;
    $fffff8..$fffff9:sound_latch:=valor;
    $fffffa..$ffffff:input[(direccion-$fffffa) shr 1]:=valor;
end;
end;

function bionicc_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff,$c000..$c7ff:bionicc_snd_getbyte:=mem_snd[direccion];
  $8001:bionicc_snd_getbyte:=ym2151_0.status;
  $a000:bionicc_snd_getbyte:=sound_latch;
end;
end;

procedure bionicc_snd_putbyte(direccion:word;valor:byte);
begin
if direccion<$8000 then exit;
case direccion of
  $8000:ym2151_0.reg(valor);
  $8001:ym2151_0.write(valor);
  $c000..$c7ff:mem_snd[direccion]:=valor;
end;
end;

procedure bionicc_sound_update;
begin
  ym2151_0.update;
end;

procedure bionicc_snd_irq;
begin
  z80_0.change_nmi(PULSE_LINE);
end;

//Main
procedure reset_bionicc;
begin
 m68000_0.reset;
 z80_0.reset;
 ym2151_0.reset;
 reset_audio;
 marcade.in0:=$000f;
 marcade.in1:=$00ff;
 fillchar(input[0],6,0);
 scroll_fg_x:=0;
 scroll_fg_y:=0;
 scroll_bg_x:=0;
 scroll_bg_y:=0;
 sound_latch:=0;
end;

function iniciar_bionicc:boolean;
var
  memoria_temp:array[0..$3ffff] of byte;
const
  pc_x:array[0..7] of dword=(0,1,2,3,8,9,10,11);
  pc_y:array[0..7] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16 );
  pf_x:array[0..15] of dword=(0,1,2,3, 8,9,10,11,
		(8*4*8)+0,(8*4*8)+1,(8*4*8)+2,(8*4*8)+3,(8*4*8)+8,(8*4*8)+9,(8*4*8)+10,(8*4*8)+11);
  pf_y:array[0..15] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16,
		8*16, 9*16, 10*16, 11*16, 12*16, 13*16, 14*16, 15*16);
  ps_x:array[0..15] of dword=(0,1,2,3,4,5,6,7,
		(16*8)+0,(16*8)+1,(16*8)+2,(16*8)+3,(16*8)+4,(16*8)+5,(16*8)+6,(16*8)+7);
  ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
          8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8);
begin
iniciar_bionicc:=false;
iniciar_audio(false);
//Pantallas
screen_init(1,256,256,true);
screen_init(3,512,512,false,true);
screen_init(4,256+8,256+8);
screen_mod_scroll(4,264,256,255,264,256,255);
screen_init(5,256+16,256+16,true);
screen_mod_scroll(5,272,256,255,272,256,255);
screen_init(6,256+16,256+16,true);
screen_mod_scroll(6,272,256,255,272,256,255);
iniciar_video(256,224);
//Main CPU
m68000_0:=cpu_m68000.create(12000000,256);
m68000_0.change_ram16_calls(bionicc_getword,bionicc_putword);
//Sound CPU
z80_0:=cpu_z80.create(3579545,256);
z80_0.change_ram_calls(bionicc_snd_getbyte,bionicc_snd_putbyte);
z80_0.init_sound(bionicc_sound_update);
//IRQ Sound CPU
init_timer(z80_0.numero_cpu,3579545/(4*60),bionicc_snd_irq,true);
//Sound Chips
ym2151_0:=ym2151_chip.create(3579545);
//cargar roms
if not(cargar_roms16w(@rom,@bionicc_rom,'bionicc.zip',0)) then exit;
//cargar sonido
if not(roms_load(@mem_snd,@bionicc_sound,'bionicc.zip',sizeof(bionicc_sound))) then exit;
//convertir chars
if not(roms_load(@memoria_temp,@bionicc_char,'bionicc.zip',sizeof(bionicc_char))) then exit;
init_gfx(0,8,8,1024);
gfx[0].trans[3]:=true;
gfx_set_desc_data(2,0,128,4,0);
convert_gfx(0,0,@memoria_temp,@pc_x,@pc_y,false,false);
//convertir bg
if not(roms_load(@memoria_temp,@bionicc_bg,'bionicc.zip',sizeof(bionicc_bg))) then exit;
init_gfx(1,8,8,2048);
gfx[1].trans[15]:=true;
gfx_set_desc_data(4,0,128,($8000*8)+4,$8000*8,4,0);
convert_gfx(1,0,@memoria_temp,@pc_x,@pc_y,false,false);
//convertir fg
if not(roms_load(@memoria_temp,@bionicc_fg,'bionicc.zip',sizeof(bionicc_fg))) then exit;
init_gfx(2,16,16,2048);
gfx[2].trans_alt[0,15]:=true;
gfx[2].trans_alt[1,1]:=true;
gfx[2].trans_alt[1,2]:=true;
gfx[2].trans_alt[1,3]:=true;
gfx[2].trans_alt[1,4]:=true;
gfx[2].trans_alt[1,5]:=true;
gfx[2].trans_alt[1,15]:=true;
gfx_set_desc_data(4,0,512,($20000*8)+4,$20000*8,4,0);
convert_gfx(2,0,@memoria_temp,@pf_x,@pf_y,false,false);
//convertir sprites
if not(roms_load(@memoria_temp,@bionicc_sprites,'bionicc.zip',sizeof(bionicc_sprites))) then exit;
init_gfx(3,16,16,2048);
gfx[3].trans[15]:=true;
gfx_set_desc_data(4,0,256,$30000*8,$20000*8,$10000*8,0);
convert_gfx(3,0,@memoria_temp,@ps_x,@ps_y,false,false);
//DIP
marcade.dswa:=$dfff;
marcade.dswa_val:=@bionicc_dip;
//final
reset_bionicc;
iniciar_bionicc:=true;
end;

procedure Cargar_bionicc;
begin
llamadas_maquina.iniciar:=iniciar_bionicc;
llamadas_maquina.bucle_general:=bionicc_principal;
llamadas_maquina.reset:=reset_bionicc;
end;

end.
