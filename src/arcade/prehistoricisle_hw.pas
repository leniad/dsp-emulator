unit prehistoricisle_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m68000,main_engine,controls_engine,gfx_engine,rom_engine,
     pal_engine,ym_3812,nz80,upd7759,sound_engine;

procedure Cargar_prehisle;
procedure prehisle_principal;
function iniciar_prehisle:boolean;
procedure reset_prehisle;
procedure cerrar_prehisle;
//Main CPU
function prehisle_getword(direccion:dword):word;
procedure prehisle_putword(direccion:dword;valor:word);
//Sound CPU
function prehisle_snd_getbyte(direccion:word):byte;
procedure prehisle_snd_putbyte(direccion:word;valor:byte);
function prehisle_snd_inbyte(puerto:word):byte;
procedure prehisle_snd_outbyte(valor:byte;puerto:word);
procedure prehisle_sound_update;
procedure snd_irq(irqstate:byte);

const
        prehisle_rom:array[0..2] of tipo_roms=(
        (n:'gt-e2.2h';l:$20000;p:0;crc:$7083245a),(n:'gt-e3.3h';l:$20000;p:$1;crc:$6d8cdf58),());
        prehisle_char:tipo_roms=(n:'gt15.b15';l:$8000;p:0;crc:$ac652412);
        prehisle_fondo_rom:tipo_roms=(n:'gt.11';l:$10000;p:0;crc:$b4f0fcf0);
        prehisle_fondo1:tipo_roms=(n:'pi8914.b14';l:$40000;p:0;crc:$207d6187);
        prehisle_fondo2:tipo_roms=(n:'pi8916.h16';l:$40000;p:0;crc:$7cffe0f6);
        prehisle_sound:tipo_roms=(n:'gt1.1';l:$10000;p:0;crc:$80a4c093);
        prehisle_upd:tipo_roms=(n:'gt4.4';l:$20000;p:0;crc:$85dfb9ec);
        prehisle_sprites:array[0..2] of tipo_roms=(
        (n:'pi8910.k14';l:$80000;p:0;crc:$5a101b0b),(n:'gt.5';l:$20000;p:$80000;crc:$3d3ab273),());
        //Dip
        prehisle_dip_a:array [0..5] of def_dip=(
        (mask:$1;name:'Flip Screen';number:2;dip:((dip_val:$1;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2;name:'Level Select';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Bonus Life';number:2;dip:((dip_val:$4;dip_name:'Only Twice'),(dip_val:$0;dip_name:'Allways'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Coinage';number:4;dip:((dip_val:$0;dip_name:'A 4C/1C B 1C/4C'),(dip_val:$10;dip_name:'A 3C/1C B 1C/3C'),(dip_val:$20;dip_name:'A 2C/1C B 1C/2C'),(dip_val:$30;dip_name:'1C 1C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Lives';number:4;dip:((dip_val:$80;dip_name:'2'),(dip_val:$c0;dip_name:'3'),(dip_val:$40;dip_name:'4'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),());
        prehisle_dip_b:array [0..4] of def_dip=(
        (mask:$3;name:'Difficulty';number:4;dip:((dip_val:$2;dip_name:'Easy'),(dip_val:$3;dip_name:'Standard'),(dip_val:$1;dip_name:'Middle'),(dip_val:$0;dip_name:'Difficult'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Game Mode';number:4;dip:((dip_val:$8;dip_name:'Demo Sounds Off'),(dip_val:$c;dip_name:'Demo Sounds On'),(dip_val:$0;dip_name:'Freeze'),(dip_val:$4;dip_name:'Infinite Lives'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Bonus Life';number:4;dip:((dip_val:$30;dip_name:'100k 200k'),(dip_val:$20;dip_name:'150k 300k'),(dip_val:$10;dip_name:'300k 500k'),(dip_val:$0;dip_name:'None'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Allow Continue';number:2;dip:((dip_val:$0;dip_name:'No'),(dip_val:$40;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 rom:array[0..$1ffff] of word;
 ram,back_ram:array[0..$1fff] of word;
 fondo_rom:array[0..$ffff] of byte;
 video_ram,sprite_ram:array[0..$3ff] of word;
 invert_controls,sound_latch,vblank_val:byte;
 scroll_x1,scroll_y1,scroll_x2,scroll_y2:word;

implementation

procedure Cargar_prehisle;
begin
llamadas_maquina.iniciar:=iniciar_prehisle;
llamadas_maquina.bucle_general:=prehisle_principal;
llamadas_maquina.cerrar:=cerrar_prehisle;
llamadas_maquina.reset:=reset_prehisle;
end;

function iniciar_prehisle:boolean;
const
  pc_x:array[0..7] of dword=(0, 4, 8, 12, 16, 20, 24, 28);
  pc_y:array[0..7] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32);
  ps_x:array[0..15] of dword=(0,4,8,12,16,20,24,28,
		0+64*8,4+64*8,8+64*8,12+64*8,16+64*8,20+64*8,24+64*8,28+64*8);
  ps_y:array[0..15] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32,
		8*32, 9*32, 10*32, 11*32, 12*32, 13*32, 14*32, 15*32 );
var
  memoria_temp:pbyte;
begin
iniciar_prehisle:=false;
iniciar_audio(false);
//Pantallas:  principal+char y sprites
screen_init(1,512,512,false,true);
screen_init(2,256,256,true);
//BG2
screen_init(4,272,272);
screen_mod_scroll(4,272,256,255,272,256,255);
//BG0
screen_init(5,272,272,true);
screen_mod_scroll(5,272,256,255,272,256,255);
iniciar_video(256,224);
//Main CPU
getmem(memoria_temp,$100000);
main_m68000:=cpu_m68000.create(9000000,$100);
main_m68000.change_ram16_calls(prehisle_getword,prehisle_putword);
//Sound CPU
snd_z80:=cpu_z80.create(4000000,$100);
snd_z80.change_ram_calls(prehisle_snd_getbyte,prehisle_snd_putbyte);
snd_z80.change_io_calls(prehisle_snd_inbyte,prehisle_snd_outbyte);
snd_z80.init_sound(prehisle_sound_update);
//Sound Chips
ym3812_init(0,4000000,snd_irq);
upd7759_0:=upd7759_chip.create(640000,2);
//cargar roms
if not(cargar_roms16w(@rom[0],@prehisle_rom[0],'prehisle.zip',0)) then exit;
//cargar sonido
if not(cargar_roms(@mem_snd[0],@prehisle_sound,'prehisle.zip',1)) then exit;
if not(cargar_roms(upd7759_0.get_rom_addr,@prehisle_upd,'prehisle.zip',1)) then exit;
//convertir chars
if not(cargar_roms(memoria_temp,@prehisle_char,'prehisle.zip',1)) then exit;
init_gfx(0,8,8,1024);
gfx_set_desc_data(4,0,32*8,0,1,2,3);
convert_gfx(0,0,memoria_temp,@pc_x[0],@pc_y[0],false,false);
gfx[0].trans[15]:=true;
//sprites
if not(cargar_roms(memoria_temp,@prehisle_sprites,'prehisle.zip',0)) then exit;
init_gfx(1,16,16,$1400);
gfx[1].trans[15]:=true;
gfx_set_desc_data(4,0,128*8,0,1,2,3);
convert_gfx(1,0,memoria_temp,@ps_x[0],@ps_y[0],false,false);
//fondo 1
if not(cargar_roms(@fondo_rom[0],@prehisle_fondo_rom,'prehisle.zip',1)) then exit;
if not(cargar_roms(memoria_temp,@prehisle_fondo1,'prehisle.zip',1)) then exit;
init_gfx(2,16,16,$800);
gfx_set_desc_data(4,0,128*8,0,1,2,3);
convert_gfx(2,0,memoria_temp,@ps_x[0],@ps_y[0],false,false);
//fondo2
if not(cargar_roms(memoria_temp,@prehisle_fondo2,'prehisle.zip',1)) then exit;
init_gfx(3,16,16,$800);
gfx[3].trans[15]:=true;
gfx_set_desc_data(4,0,128*8,0,1,2,3);
convert_gfx(3,0,memoria_temp,@ps_x[0],@ps_y[0],false,false);
//DIP
marcade.dswa:=$ff;
marcade.dswb:=$7f;
marcade.dswa_val:=@prehisle_dip_a;
marcade.dswb_val:=@prehisle_dip_b;
//final
freemem(memoria_temp);
reset_prehisle;
iniciar_prehisle:=true;
end;

procedure cerrar_prehisle;
begin
main_m68000.free;
snd_z80.free;
ym3812_close(0);
upd7759_0.Free;
close_audio;
close_video;
end;

procedure reset_prehisle;
begin
 main_m68000.reset;
 snd_z80.reset;
 ym3812_reset(0);
 upd7759_0.reset;
 reset_audio;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 invert_controls:=0;
 scroll_x1:=0;
 scroll_y1:=0;
 scroll_x2:=0;
 scroll_y2:=0;
 sound_latch:=0;
 vblank_val:=0;
end;

procedure poner_sprites(prioridad:boolean);inline;
var
  f,atrib,nchar,color:word;
  x,y:integer;
begin
for f:=0 to $ff do begin
    color:=sprite_ram[(f*4)+3] shr 12;
    if (color<$4)<>prioridad then continue;
		atrib:=sprite_ram[(f*4)+2];
		nchar:=atrib and $1fff;
    if nchar>$1400 then nchar:=nchar-$1400;
		x:=sprite_ram[(f*4)+1];
		y:=sprite_ram[(f*4)];
    put_gfx_sprite(nchar,256+(color shl 4),(atrib and $4000)<>0,(atrib and $8000)<>0,1);
    actualiza_gfx_sprite(x,y,1,1);
end;
end;

procedure update_video_prehisle;inline;
var
  f,color,pos,x,y,sx,sy,nchar,atrib:word;
begin
for f:=$0 to $120 do begin
  x:=f div 17;
  y:=f mod 17;
  //background
  sx:=x+((scroll_x1 and $3FF0) shr 4);
  sy:=y+((scroll_y1 and $1f0) shr 4);
  pos:=(sy and $1f)+((sx and $3ff) shl 5);
  atrib:=(fondo_rom[pos shl 1] shl 8)+fondo_rom[1+(pos shl 1)];
  color:=atrib shr 12;
  if (gfx[2].buffer[pos] or buffer_color[color+$10]) then begin
    nchar:=atrib and $7ff;
    put_gfx_flip(x*16,y*16,nchar,(color shl 4)+768,4,2,(atrib and $800)<>0,false);
    gfx[2].buffer[pos]:=false;
  end;
  //background 2
  sx:=x+((scroll_x2 and $FF0) shr 4);
  sy:=y+((scroll_y2 and $1f0) shr 4);
  pos:=(sy and $1f)+((sx and $ff) shl 5);
  atrib:=back_ram[pos];
  color:=atrib shr 12;
  if (gfx[3].buffer[pos] or buffer_color[color+$20]) then begin
    nchar:=atrib and $7ff;
    put_gfx_trans_flip(x*16,y*16,nchar,(color shl 4)+512,5,3,false,(atrib and $800)<>0);
    gfx[3].buffer[pos]:=false;
  end;
end;
//foreground
for f:=$0 to $3ff do begin
  atrib:=video_ram[f];
  color:=atrib shr 12;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
    x:=f mod 32;
    y:=f div 32;
    nchar:=atrib and $3ff;
    put_gfx_trans(x*8,y*8,nchar,color shl 4,2,0);
    gfx[0].buffer[f]:=false;
  end;
end;
//Mix
scroll_x_y(4,1,scroll_x1 and $f,scroll_y1 and $f);
poner_sprites(false);
scroll_x_y(5,1,scroll_x2 and $f,scroll_y2 and $f);
poner_sprites(true);
actualiza_trozo(0,0,256,256,2,0,0,256,256,1);
actualiza_trozo_final(0,16,256,224,1);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure eventos_prehisle;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $Fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $F7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.but2[0] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  //P2
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $Fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $F7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.but2[1] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
  //COIN
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $Fd) else marcade.in2:=(marcade.in2 or $2);
end;
end;

procedure prehisle_principal;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=main_m68000.tframes;
frame_s:=snd_z80.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to $ff do begin
   main_m68000.run(frame_m);
   frame_m:=frame_m+main_m68000.tframes-main_m68000.contador;
   snd_z80.run(frame_s);
   frame_s:=frame_s+snd_z80.tframes-snd_z80.contador;
   case f of
    21:vblank_val:=$0;
    239:begin
          vblank_val:=$80;
          main_m68000.irq[4]:=HOLD_LINE;
          update_video_prehisle;
        end;
   end;
 end;
 eventos_prehisle;
 video_sync;
end;
end;

function prehisle_getword(direccion:dword):word;
begin
case direccion of
  $0..$3ffff:prehisle_getword:=rom[direccion shr 1];
  $70000..$73fff:prehisle_getword:=ram[(direccion and $3fff) shr 1];
  $90000..$907ff:prehisle_getword:=video_ram[(direccion and $7ff) shr 1];
  $a0000..$a07ff:prehisle_getword:=sprite_ram[(direccion and $7ff) shr 1];
  $b0000..$b3fff:prehisle_getword:=back_ram[(direccion and $3fff) shr 1];
  $d0000..$d07ff:prehisle_getword:=buffer_paleta[(direccion and $7ff) shr 1];
  $e0010:prehisle_getword:=marcade.in1;  //P2
  $e0020:prehisle_getword:=marcade.in2;  //COIN
  $e0040:prehisle_getword:=marcade.in0 xor invert_controls;  //P1
  $e0042:prehisle_getword:=marcade.dswa;
  $e0044:prehisle_getword:=marcade.dswb or vblank_val;
end;
end;

procedure cambiar_color(tmp_color,numero:word);inline;
var
  color:tcolor;
begin
  color.r:=pal4bit(tmp_color shr 12);
  color.g:=pal4bit(tmp_color shr 8);
  color.b:=pal4bit(tmp_color shr 4);
  set_pal_color(color,@paleta[numero]);
  case numero of
    0..255:buffer_color[numero shr 4]:=true;
    512..767:buffer_color[((numero shr 4) and $f)+$20]:=true;
    768..1023:buffer_color[((numero shr 4) and $f)+$10]:=true;
  end;
end;

procedure prehisle_putword(direccion:dword;valor:word);
begin
case direccion of
    $70000..$73fff:ram[(direccion and $3fff) shr 1]:=valor;
    $90000..$907ff:begin
                      video_ram[(direccion and $7ff) shr 1]:=valor;
                      gfx[0].buffer[(direccion and $7ff) div 2]:=true;
                   end;
    $a0000..$a07ff:sprite_ram[(direccion and $7ff) shr 1]:=valor;
    $b0000..$b3fff:begin
                      back_ram[(direccion and $3fff) shr 1]:=valor;
                      gfx[3].buffer[(direccion and $3fff) div 2]:=true;
                   end;
    $d0000..$d07ff:if buffer_paleta[(direccion and $7ff) shr 1]<>valor then begin
                        buffer_paleta[(direccion and $7ff) shr 1]:=valor;
                        cambiar_color(valor,(direccion and $7ff) shr 1);
                   end;

    $f0000:if scroll_y2<>(valor and $1ff) then begin
              if abs((scroll_y2 and $1f0)-(valor and $1f0))>15 then fillchar(gfx[3].buffer[0],$2000,1);
              scroll_y2:=(valor and $1ff);
           end;
    $f0010:if scroll_x2<>(valor and $fff) then begin
              if abs((scroll_x2 and $ff0)-(valor and $ff0))>15 then fillchar(gfx[3].buffer[0],$2000,1);
              scroll_x2:=(valor and $fff);
           end;
    $f0020:if scroll_y1<>(valor and $1ff) then begin
              if abs((scroll_y1 and $1f0)-(valor and $1f0))>15 then fillchar(gfx[2].buffer[0],$8000,1);
              scroll_y1:=(valor and $1ff);
           end;
    $f0030:if scroll_x1<>(valor and $3fff) then begin
              if abs((scroll_x1 and $3ff0)-(valor and $3ff0))>15 then fillchar(gfx[2].buffer[0],$8000,1);
              scroll_x1:=(valor and $3fff);
           end;
    $f0046:if valor<>0 then invert_controls:=$ff
              else invert_controls:=0;
    $f0060:main_screen.flip_main_screen:=(valor and $1)<>0;
    $f0031..$f0045,$f0047..$f005f,$f0061..$f0069:;
    $f0070:begin
              sound_latch:=valor and $ff;
              snd_z80.pedir_nmi:=PULSE_LINE;
           end;
end;
end;

function prehisle_snd_getbyte(direccion:word):byte;
begin
if direccion=$f800 then prehisle_snd_getbyte:=sound_latch
  else prehisle_snd_getbyte:=mem_snd[direccion];
end;

procedure prehisle_snd_putbyte(direccion:word;valor:byte);
begin
if direccion>$efff then mem_snd[direccion]:=valor;
end;

function prehisle_snd_inbyte(puerto:word):byte;
begin
if (puerto and $ff)=0 then prehisle_snd_inbyte:=ym3812_status_port(0);
end;

procedure prehisle_snd_outbyte(valor:byte;puerto:word);
begin
case (puerto and $ff) of
  $00:ym3812_control_port(0,valor);
  $20:ym3812_write_port(0,valor);
  $40:begin
        upd7759_0.port_w(valor);
      	upd7759_0.start_w(0);
      	upd7759_0.start_w(1);
      end;
  $80:upd7759_0.reset_w(valor and $80);
end;
end;

procedure prehisle_sound_update;
begin
  YM3812_Update(0);
  upd7759_0.update;
end;

procedure snd_irq(irqstate:byte);
begin
  if (irqstate<>0) then snd_z80.pedir_irq:=ASSERT_LINE
    else snd_z80.pedir_irq:=CLEAR_LINE;
end;

end.
