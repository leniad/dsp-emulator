unit streetfighter_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,m68000,main_engine,controls_engine,gfx_engine,ym_2151,rom_engine,
     pal_engine,sound_engine,timer_engine,msm5205;

procedure Cargar_sfighter;
procedure sfighter_principal;
function iniciar_sfighter:boolean;
procedure reset_sfighter;
procedure cerrar_sfighter;
//Main CPU
function sfighter_getword(direccion:dword):word;
procedure sfighter_putword(direccion:dword;valor:word);
//Sound CPUs
function sf_snd_getbyte(direccion:word):byte;
procedure sf_snd_putbyte(direccion:word;valor:byte);
function sf_misc_getbyte(direccion:word):byte;
procedure sf_misc_putbyte(direccion:word;valor:byte);
function sf_misc_inbyte(puerto:word):byte;
procedure sf_misc_outbyte(valor:byte;puerto:word);
procedure sf_adpcm_instruccion;
procedure ym2151_snd_irq(irqstate:byte);
procedure sound_instruccion;

implementation
const
        sfighter_rom:array[0..6] of tipo_roms=(
        (n:'sfe-19';l:$10000;p:0;crc:$8346c3ca),(n:'sfe-22';l:$10000;p:$1;crc:$3a4bfaa8),
        (n:'sfe-20';l:$10000;p:$20000;crc:$b40e67ee),(n:'sfe-23';l:$10000;p:$20001;crc:$477c3d5b),
        (n:'sfe-21';l:$10000;p:$40000;crc:$2547192b),(n:'sfe-24';l:$10000;p:$40001;crc:$79680f4e),());
        sfighter_char:tipo_roms=(n:'sf-27.bin';l:$4000;p:0;crc:$2b09b36d);
        sfighter_bg:array[0..4] of tipo_roms=(
        (n:'sf-39.bin';l:$20000;p:0;crc:$cee3d292),(n:'sf-38.bin';l:$20000;p:$20000;crc:$2ea99676),
        (n:'sf-41.bin';l:$20000;p:$40000;crc:$e0280495),(n:'sf-40.bin';l:$20000;p:$60000;crc:$c70b30de),());
        sfighter_fg:array[0..8] of tipo_roms=(
        (n:'sf-25.bin';l:$20000;p:0;crc:$7f23042e),(n:'sf-28.bin';l:$20000;p:$20000;crc:$92f8b91c),
        (n:'sf-30.bin';l:$20000;p:$40000;crc:$b1399856),(n:'sf-34.bin';l:$20000;p:$60000;crc:$96b6ae2e),
        (n:'sf-26.bin';l:$20000;p:$80000;crc:$54ede9f5),(n:'sf-29.bin';l:$20000;p:$a0000;crc:$f0649a67),
        (n:'sf-31.bin';l:$20000;p:$c0000;crc:$8f4dd71a),(n:'sf-35.bin';l:$20000;p:$e0000;crc:$70c00fb4),());
        sfighter_tile_map1:array[0..2] of tipo_roms=(
        (n:'sf-37.bin';l:$10000;p:0;crc:$23d09d3d),(n:'sf-36.bin';l:$10000;p:$10000;crc:$ea16df6c),());
        sfighter_tile_map2:array[0..2] of tipo_roms=(
        (n:'sf-32.bin';l:$10000;p:$0;crc:$72df2bd9),(n:'sf-33.bin';l:$10000;p:$10000;crc:$3e99d3d5),());
        sfighter_sprites:array[0..14] of tipo_roms=(
        (n:'sf-15.bin';l:$20000;p:0;crc:$fc0113db),(n:'sf-16.bin';l:$20000;p:$20000;crc:$82e4a6d3),
        (n:'sf-11.bin';l:$20000;p:$40000;crc:$e112df1b),(n:'sf-12.bin';l:$20000;p:$60000;crc:$42d52299),
        (n:'sf-07.bin';l:$20000;p:$80000;crc:$49f340d9),(n:'sf-08.bin';l:$20000;p:$a0000;crc:$95ece9b1),
        (n:'sf-03.bin';l:$20000;p:$c0000;crc:$5ca05781),(n:'sf-17.bin';l:$20000;p:$e0000;crc:$69fac48e),
        (n:'sf-18.bin';l:$20000;p:$100000;crc:$71cfd18d),(n:'sf-13.bin';l:$20000;p:$120000;crc:$fa2eb24b),
        (n:'sf-14.bin';l:$20000;p:$140000;crc:$ad955c95),(n:'sf-09.bin';l:$20000;p:$160000;crc:$41b73a31),
        (n:'sf-10.bin';l:$20000;p:$180000;crc:$91c41c50),(n:'sf-05.bin';l:$20000;p:$1a0000;crc:$538c7cbe),());
        sfighter_snd:tipo_roms=(n:'sf-02.bin';l:$8000;p:0;crc:$4a9ac534);
        sfighter_msm:array[0..2] of tipo_roms=(
        (n:'sfu-00';l:$20000;p:$0;crc:$a7cce903),(n:'sf-01.bin';l:$20000;p:$20000;crc:$86e0f0d5),());
        scale:array[0..7] of byte =($00,$40,$e0,$fe,$fe,$fe,$fe,$fe);

var
 rom:array[0..$2ffff] of word;
 ram1:array[0..$fff] of byte;
 ram3:array[0..$7fff] of byte;
 rom_misc:array[0..7,0..$7fff] of byte;
 scroll_bg,scroll_fg:word;
 bg_paint,fg_paint,bg_act,fg_act,char_act,sp_act:boolean;
 ram_tile_map1,ram_tile_map2:array[0..$1ffff] of byte;
 soundlatch,misc_bank:byte;

procedure Cargar_sfighter;
begin
llamadas_maquina.iniciar:=iniciar_sfighter;
llamadas_maquina.bucle_general:=sfighter_principal;
llamadas_maquina.cerrar:=cerrar_sfighter;
llamadas_maquina.reset:=reset_sfighter;
end;

function iniciar_sfighter:boolean;
const
  pc_x:array[0..7] of dword=(0, 1, 2, 3, 8+0, 8+1, 8+2, 8+3);
  pc_y:array[0..7] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16);
  ps_x:array[0..15] of dword=(0, 1, 2, 3, 8+0, 8+1, 8+2, 8+3,
			16*16+0, 16*16+1, 16*16+2, 16*16+3, 16*16+8+0, 16*16+8+1, 16*16+8+2, 16*16+8+3);
  ps_y:array[0..15] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16,
			8*16, 9*16, 10*16, 11*16, 12*16, 13*16, 14*16, 15*16);
var
  memoria_temp,ptemp:pbyte;
  f:byte;
begin
iniciar_sfighter:=false;
iniciar_audio(true);
//Pantallas:  principal+char y sprites
screen_init(1,512,512,false,true);
screen_init(2,512,256,true);
screen_init(3,512,256);
screen_init(4,512,256,true);
iniciar_video(384,224);
//Main CPU
main_m68000:=cpu_m68000.create(8000000,256);
main_m68000.change_ram16_calls(sfighter_getword,sfighter_putword);
//Sound CPU
snd_z80:=cpu_z80.create(3579545,256);
snd_z80.change_ram_calls(sf_snd_getbyte,sf_snd_putbyte);
snd_z80.init_sound(sound_instruccion);
//Sub CPU
sub_z80:=cpu_z80.create(3579545,256);
sub_z80.change_ram_calls(sf_misc_getbyte,sf_misc_putbyte);
sub_z80.change_io_calls(sf_misc_inbyte,sf_misc_outbyte);
init_timer(sub_z80.numero_cpu,3579545/8000,sf_adpcm_instruccion,true);
//Sound Chips
YM2151_Init(0,3579545,nil,ym2151_snd_irq);
msm_5205_0:=MSM5205_chip.create(384000,MSM5205_SEX_4B,2,nil);
msm_5205_1:=MSM5205_chip.create(384000,MSM5205_SEX_4B,2,nil);
//cargar roms
if not(cargar_roms16w(@rom[0],@sfighter_rom[0],'sf.zip',0)) then exit;
//Sound CPUs
if not(cargar_roms(@mem_snd[0],@sfighter_snd,'sf.zip',1)) then exit;
getmem(memoria_temp,$200000);
if not(cargar_roms(memoria_temp,@sfighter_msm,'sf.zip',0)) then exit;
ptemp:=memoria_temp;
for f:=0 to 7 do begin
  copymemory(@rom_misc[f,0],ptemp,$8000);
  inc(ptemp,$8000);
end;
//convertir chars
if not(cargar_roms(memoria_temp,@sfighter_char,'sf.zip',1)) then exit;
init_gfx(0,8,8,$400);
gfx[0].trans[3]:=true;
gfx_set_desc_data(2,0,16*8,4,0);
convert_gfx(0,0,memoria_temp,@pc_x[0],@pc_y[0],false,false);
//convertir bg y cargar tile maps
if not(cargar_roms(memoria_temp,@sfighter_bg[0],'sf.zip',0)) then exit;
if not(cargar_roms(@ram_tile_map1[0],@sfighter_tile_map1[0],'sf.zip',0)) then exit;
init_gfx(1,16,16,$1000);
gfx_set_desc_data(4,0,64*8,4,0,$40000*8+4,$40000*8+0);
convert_gfx(1,0,memoria_temp,@ps_x[0],@ps_y[0],false,false);
//convertir fg y cargar tile maps
if not(cargar_roms(memoria_temp,@sfighter_fg[0],'sf.zip',0)) then exit;
if not(cargar_roms(@ram_tile_map2[0],@sfighter_tile_map2[0],'sf.zip',0)) then exit;
init_gfx(2,16,16,$2000);
gfx[2].trans[15]:=true;
gfx_set_desc_data(4,0,64*8,4,0,$80000*8+4,$80000*8+0);
convert_gfx(2,0,memoria_temp,@ps_x[0],@ps_y[0],false,false);
//sprites
if not(cargar_roms(memoria_temp,@sfighter_sprites[0],'sf.zip',0)) then exit;
init_gfx(3,16,16,$4000);
gfx[3].trans[15]:=true;
gfx_set_desc_data(4,0,64*8,4,0,$e0000*8+4,$e0000*8+0);
convert_gfx(3,0,memoria_temp,@ps_x[0],@ps_y[0],false,false);
//final
freemem(memoria_temp);
reset_sfighter;
iniciar_sfighter:=true;
end;

procedure cerrar_sfighter;
begin
ym2151_close(0);
end;

procedure reset_sfighter;
begin
 main_m68000.reset;
 snd_z80.reset;
 sub_z80.reset;
 YM2151_reset(0);
 msm_5205_0.reset;
 msm_5205_1.reset;
 reset_audio;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in7:=$ff;
 marcade.in2:=$7f;
 marcade.in3:=0;
 marcade.in4:=0;
 marcade.in5:=0;
 marcade.in6:=0;
 scroll_bg:=0;
 scroll_fg:=0;
 bg_paint:=false;
 fg_paint:=false;
 bg_act:=false;
 fg_act:=false;
 char_act:=false;
 sp_act:=false;
 misc_bank:=1;
end;

procedure update_video_sfighter;
var
  f,x,y,nchar,atrib,color,pos,nchar1,nchar2,nchar3,nchar4:word;
  flipx,flipy:boolean;
function sf_invert(char:word):word;
const
  delta:array[0..3] of byte=($00,$18,$18,$00);
begin
	sf_invert:=char xor delta[(char shr 3) and 3];
end;
begin
//bg
if bg_act then begin
  if bg_paint then begin
    for f:=$0 to $1ff do begin
      x:=f mod 32;
      y:=f div 32;
      pos:=(y*2)+(x*32)+((scroll_bg and $fff0)*2);
      atrib:=ram_tile_map1[$10000+pos];
      nchar:=((ram_tile_map1[$10001+pos] shl 8)+ram_tile_map1[$1+pos]) and $fff;
      color:=ram_tile_map1[pos] shl 4;
      put_gfx_flip(x*16,y*16,nchar,color,3,1,(atrib and $1)<>0,(atrib and $2)<>0);
    end;
    bg_paint:=false;
  end;
  actualiza_trozo((scroll_bg and $f),0,512-(scroll_bg and $f),256,3,0,0,512-(scroll_bg and $f),256,1);
end else begin
  fill_full_screen(1,0);
end;
//foreground
if fg_act then begin
  if fg_paint then begin
    for f:=$0 to $1ff do begin
      x:=f mod 32;
      y:=f div 32;
      pos:=(y*2)+(x*32)+((scroll_fg and $fff0)*2);
      atrib:=ram_tile_map2[$10000+pos];
      nchar:=((ram_tile_map2[$10001+pos] shl 8)+ram_tile_map2[$1+pos]) and $1fff;
      color:=ram_tile_map2[pos] shl 4;
      put_gfx_trans_flip(x*16,y*16,nchar,color+256,4,2,(atrib and $1)<>0,(atrib and $2)<>0);
    end;
    fg_paint:=false;
  end;
  actualiza_trozo((scroll_fg and $f),0,512-(scroll_fg and $f),256,4,0,0,512-(scroll_fg and $f),256,1);
end;
//Sprites
if sp_act then begin
  for f:=$7f downto 0 do begin
    nchar:=(((ram3[$6000+(f*$20)] and $3f) shl 8) or ram3[$6001+(f*$20)]);
    atrib:=(ram3[$6002+(f*$20)] shl 8) or ram3[$6003+(f*$20)];
    color:=((atrib and $f) shl 4)+512;
    flipx:=(atrib and $0100)<>0;
    flipy:=(atrib and $0200)<>0;
    if (atrib and $400)<>0 then begin
      nchar1:=nchar;
      nchar2:=nchar+1;
      nchar3:=nchar+16;
      nchar4:=nchar+17;
      if flipx then begin
        x:=nchar2;nchar2:=nchar1;nchar1:=x;
        x:=nchar4;nchar4:=nchar3;nchar3:=x;
      end;
      if flipy then begin
        x:=nchar3;nchar3:=nchar1;nchar1:=x;
        x:=nchar2;nchar2:=nchar4;nchar4:=x;
      end;
      put_gfx_sprite_diff(sf_invert(nchar1),color,flipx,flipy,3,0,0);
      put_gfx_sprite_diff(sf_invert(nchar2),color,flipx,flipy,3,16,0);
      put_gfx_sprite_diff(sf_invert(nchar3),color,flipx,flipy,3,0,16);
      put_gfx_sprite_diff(sf_invert(nchar4),color,flipx,flipy,3,16,16);
      y:=(ram3[$6004+(f*$20)] shl 8) or ram3[$6005+(f*$20)];
      x:=(ram3[$6006+(f*$20)] shl 8) or ram3[$6007+(f*$20)];
      actualiza_gfx_sprite_size(x,y,1,32,32);
    end else begin
      put_gfx_sprite(sf_invert(nchar),color,flipx,flipy,3);
      y:=(ram3[$6004+(f*$20)] shl 8) or ram3[$6005+(f*$20)];
      x:=(ram3[$6006+(f*$20)] shl 8) or ram3[$6007+(f*$20)];
      actualiza_gfx_sprite(x,y,1,3);
    end;
  end;
end;
//chars
if char_act then begin
  for f:=$0 to $7ff do begin
    if gfx[0].buffer[f] then begin
      x:=f mod 64;
      y:=f div 64;
      atrib:=(ram1[(f*2)] shl 8) or ram1[$1+(f*2)];
      nchar:=atrib and $3ff;
      color:=(atrib shr 12) shl 2;
      flipx:=(atrib and $400)<>0;
      flipy:=(atrib and $800)<>0;
      put_gfx_trans_flip(x*8,y*8,nchar,color+768,2,0,flipx,flipy);
      gfx[0].buffer[f]:=false;
    end;
  end;
  actualiza_trozo(64,16,384,224,2,64,16,384,224,1);
end;
actualiza_trozo_final(64,16,384,224,1);
end;

procedure eventos_sfighter;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $F7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $Fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  //P2
  if arcade_input.up[1] then marcade.in7:=(marcade.in7 and $F7) else marcade.in7:=(marcade.in7 or $8);
  if arcade_input.down[1] then marcade.in7:=(marcade.in7 and $fb) else marcade.in7:=(marcade.in7 or $4);
  if arcade_input.left[1] then marcade.in7:=(marcade.in7 and $Fd) else marcade.in7:=(marcade.in7 or $2);
  if arcade_input.right[1] then marcade.in7:=(marcade.in7 and $fe) else marcade.in7:=(marcade.in7 or $1);
  //Misc
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  //P2
  if arcade_input.but0[0] then marcade.in3:=(marcade.in3 or $1) else marcade.in3:=(marcade.in3 and $fe);
  if arcade_input.but1[0] then marcade.in3:=(marcade.in3 or $2) else marcade.in3:=(marcade.in3 and $fd);
  if arcade_input.but2[0] then marcade.in3:=(marcade.in3 or $4) else marcade.in3:=(marcade.in3 and $fb);
  if arcade_input.but3[0] then marcade.in4:=(marcade.in4 or $1) else marcade.in4:=(marcade.in4 and $fe);
  if arcade_input.but4[0] then marcade.in4:=(marcade.in4 or $2) else marcade.in4:=(marcade.in4 and $fd);
  if arcade_input.but5[0] then marcade.in4:=(marcade.in4 or $4) else marcade.in4:=(marcade.in4 and $fb);
  //P2
  if arcade_input.but0[1] then marcade.in5:=(marcade.in5 or $1) else marcade.in5:=(marcade.in5 and $fe);
  if arcade_input.but1[1] then marcade.in5:=(marcade.in5 or $2) else marcade.in5:=(marcade.in5 and $fd);
  if arcade_input.but2[1] then marcade.in5:=(marcade.in5 or $4) else marcade.in5:=(marcade.in5 and $fb);
  if arcade_input.but3[1] then marcade.in6:=(marcade.in6 or $1) else marcade.in6:=(marcade.in6 and $fe);
  if arcade_input.but4[1] then marcade.in6:=(marcade.in6 or $2) else marcade.in6:=(marcade.in6 and $fd);
  if arcade_input.but5[1] then marcade.in6:=(marcade.in6 or $4) else marcade.in6:=(marcade.in6 and $fb);
end;
end;

procedure sfighter_principal;
var
  frame_m,frame_s,frame_a:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=main_m68000.tframes;
frame_s:=snd_z80.tframes;
frame_a:=sub_z80.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to $ff do begin
   //Main CPU
   main_m68000.run(frame_m);
   frame_m:=frame_m+main_m68000.tframes-main_m68000.contador;
   //Sound CPU
   snd_z80.run(frame_s);
   frame_s:=frame_s+snd_z80.tframes-snd_z80.contador;
   //ADPCM CPU
   sub_z80.run(frame_a);
   frame_a:=frame_a+sub_z80.tframes-sub_z80.contador;
   if f=239 then begin
      update_video_sfighter;
      main_m68000.irq[1]:=HOLD_LINE;
   end;
 end;
 eventos_sfighter;
 video_sync;
end;
end;

function sfighter_getword(direccion:dword):word;
begin
case direccion of
  0..$4ffff:sfighter_getword:=rom[direccion shr 1];
  $800000..$800fff:sfighter_getword:=ram1[(direccion+1) and $fff] or (ram1[direccion and $fff] shl 8);
  $b00000..$b007ff:sfighter_getword:=buffer_paleta[(direccion and $7ff) shr 1];
  $c00000:sfighter_getword:=$ff00+marcade.in0;  //coins
  $c00002:sfighter_getword:=(marcade.in7 shl 8)+marcade.in1;  //marcade.in0
  $c00004:sfighter_getword:=(0 shl 8)+scale[marcade.in3];
  $c00006:sfighter_getword:=(0 shl 8)+scale[marcade.in4];
  $c00008:sfighter_getword:=$dfff;
  $c0000a,$c0000e:sfighter_getword:=$ffff;
  $c0000c:sfighter_getword:=$ff00+marcade.in2;
  $c0001a:sfighter_getword:=(byte(char_act) shl 3)+(byte(bg_act) shl 5)+(byte(fg_act) shl 6)+(byte(sp_act) shl 7);
  $ff8000..$ffffff:sfighter_getword:=ram3[(direccion+1) and $7fff] or (ram3[direccion and $7fff] shl 8);
end;
end;

procedure cambiar_color(tmp_color,numero:word);inline;
var
  color:tcolor;
begin
  color.r:=pal4bit(tmp_color shr 8);
  color.g:=pal4bit(tmp_color shr 4);
  color.b:=pal4bit(tmp_color);
  set_pal_color(color,numero);
  case numero of
    0..$ff:bg_paint:=true;
    $100..$1ff:fg_paint:=true;
  end;
end;

procedure sfighter_putword(direccion:dword;valor:word);
begin
if direccion<$50000 then exit;
case direccion of
    $800000..$800fff:begin
                    ram1[(direccion and $fff)+1]:=valor and $ff;
                    ram1[direccion and $fff]:=valor shr 8;
                    gfx[0].buffer[(direccion and $fff) shr 1]:=true;
                   end;
    $b00000..$b007ff:if buffer_paleta[(direccion and $7ff) shr 1]<>valor then begin
                      buffer_paleta[(direccion and $7ff) shr 1]:=valor;
                      cambiar_color(valor,(direccion and $7ff) shr 1);
                   end;
    $c00016,$c00010:;
    $c00014:if valor<>scroll_fg then begin
              scroll_fg:=valor;
              fg_paint:=true;
          end;
    $c00018:if valor<>scroll_bg then begin
              scroll_bg:=valor;
              bg_paint:=true;
          end;
    $c0001a:begin
              char_act:=(valor and $8)<>0;
              bg_act:=(valor and $20)<>0;
              fg_act:=(valor and $40)<>0;
              sp_act:=(valor and $80)<>0;
            end;
    $c0001c:begin
              soundlatch:=valor and $ff;
              snd_z80.pedir_nmi:=PULSE_LINE;
            end;
    $ff8000..$ffffff:begin
                        ram3[(direccion and $7fff)+1]:=valor and $ff;
                        ram3[direccion and $7fff]:=valor shr 8;
                     end;
end;
end;

//sound
function sf_snd_getbyte(direccion:word):byte;
begin
case direccion of
  $c800:sf_snd_getbyte:=soundlatch;
  $e001:sf_snd_getbyte:=YM2151_status_port_read(0);
  else sf_snd_getbyte:=mem_snd[direccion];
end;
end;

procedure sf_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:exit;
  $e000:YM2151_register_port_write(0,valor);
  $e001:YM2151_data_port_write(0,valor);
    else mem_snd[direccion]:=valor;
end;
end;

function sf_misc_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff:sf_misc_getbyte:=rom_misc[0,direccion];
  $8000..$ffff:sf_misc_getbyte:=rom_misc[misc_bank,direccion and $7fff];
end;
end;

procedure sf_misc_putbyte(direccion:word;valor:byte);
begin
end;

function sf_misc_inbyte(puerto:word):byte;
begin
case (puerto and $ff) of
  1:sf_misc_inbyte:=soundlatch;
end;
end;

procedure sf_misc_outbyte(valor:byte;puerto:word);
begin
case (puerto and $ff) of
  0:begin
        msm_5205_0.reset_w((valor shr 7) and 1);
        msm_5205_0.data_w(valor);
	      msm_5205_0.vclk_w(1);
	      msm_5205_0.vclk_w(0);
     end;
  1:begin
        msm_5205_1.reset_w((valor shr 7) and 1);
        msm_5205_1.data_w(valor);
	      msm_5205_1.vclk_w(1);
	      msm_5205_1.vclk_w(0);
    end;
  2:misc_bank:=valor+1;
end;
end;

procedure ym2151_snd_irq(irqstate:byte);
begin
  if (irqstate=1) then snd_z80.pedir_irq:=ASSERT_LINE
    else snd_z80.pedir_irq:=CLEAR_LINE;
end;

procedure sound_instruccion;
begin
  ym2151_Update(0);
end;

procedure sf_adpcm_instruccion;
begin
  sub_z80.pedir_irq:=HOLD_LINE;
end;

end.