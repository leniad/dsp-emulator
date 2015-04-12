unit m72_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,nec_v20_v30,main_engine,controls_engine,gfx_engine,ym_2151,
     rom_engine,pal_engine,sound_engine,timer_engine,dac;

procedure Cargar_irem_m72;
procedure irem_m72_principal;
function iniciar_irem_m72:boolean;
procedure reset_irem_m72;
procedure cerrar_irem_m72;
//RType
function irem_m72_getbyte(direccion:dword):byte;
procedure irem_m72_putbyte(direccion:dword;valor:byte);
procedure irem_m72_outword(valor:word;puerto:word);
function irem_m72_inword(puerto:word):word;
procedure update_video_rtype;
procedure paint_video_rtype(linea_o,linea_d:word);
//Hammerin' Harry
function hharry_getbyte(direccion:dword):byte;
procedure hharry_putbyte(direccion:dword;valor:byte);
procedure hharry_outword(valor:word;puerto:word);
function hharry_inword(puerto:word):word;
procedure hharry_outbyte(valor:byte;puerto:word);
function hharry_inbyte(puerto:word):byte;
procedure update_video_hharry;
procedure paint_video_hharry(linea_o,linea_d:word);
//RType2
function rtype2_getbyte(direccion:dword):byte;
procedure rtype2_putbyte(direccion:dword;valor:byte);
procedure rtype2_outword(valor:word;puerto:word);
function rtype2_inword(puerto:word):word;
procedure rtype2_outbyte(valor:byte;puerto:word);
function rtype2_inbyte(puerto:word):byte;
procedure update_video_rtype2;
procedure paint_video_rtype2(linea_o,linea_d:word);
//Sound
procedure sound_irq_ack;
procedure ym2151_snd_irq(irqstate:byte);
function irem_m72_snd_getbyte(direccion:word):byte;
procedure irem_m72_snd_putbyte(direccion:word;valor:byte);
function irem_m72_snd_inbyte(puerto:word):byte;
procedure irem_m72_snd_outbyte(valor:byte;puerto:word);
function rtype2_snd_inbyte(puerto:word):byte;
procedure rtype2_snd_outbyte(valor:byte;puerto:word);
procedure irem_m72_sound_update;
procedure rtype2_sound_update;
procedure rtype2_perodic_int;

const
        //Rtype
        rtype_rom:array[0..4] of tipo_roms=(
        (n:'rt_r-h0-b.1b';l:$10000;p:1;crc:$591c7754),(n:'rt_r-l0-b.3b';l:$10000;p:$0;crc:$a1928df0),
        (n:'rt_r-h1-b.1c';l:$10000;p:$20001;crc:$a9d71eca),(n:'rt_r-l1-b.3c';l:$10000;p:$20000;crc:$0df3573d),());
        rtype_char:array[0..4] of tipo_roms=(
        (n:'rt_b-a0.3c';l:$8000;p:0;crc:$4e212fb0),(n:'rt_b-a1.3d';l:$8000;p:$8000;crc:$8a65bdff),
        (n:'rt_b-a2.3a';l:$8000;p:$10000;crc:$5a4ae5b9),(n:'rt_b-a3.3e';l:$8000;p:$18000;crc:$73327606),());
        rtype_char2:array[0..4] of tipo_roms=(
        (n:'rt_b-b0.3j';l:$8000;p:0;crc:$a7b17491),(n:'rt_b-b1.3k';l:$8000;p:$8000;crc:$b9709686),
        (n:'rt_b-b2.3h';l:$8000;p:$10000;crc:$433b229a),(n:'rt_b-b3.3f';l:$8000;p:$18000;crc:$ad89b072),());
        irem_m72_sprites:array[0..12] of tipo_roms=(
        (n:'rt_r-00.1h';l:$10000;p:0;crc:$dad53bc0),(n:'rt_r-01.1j';l:$8000;p:$10000;crc:$5e441e7f),
        (n:'rt_r-01.1j';l:$8000;p:$18000;crc:$5e441e7f),(n:'rt_r-10.1k';l:$10000;p:$20000;crc:$d6a66298),
        (n:'rt_r-11.1l';l:$8000;p:$30000;crc:$791df4f8),(n:'rt_r-11.1l';l:$8000;p:$38000;crc:$791df4f8),
        (n:'rt_r-20.3h';l:$10000;p:$40000;crc:$fc247c8a),(n:'rt_r-21.3j';l:$8000;p:$50000;crc:$ed793841),
        (n:'rt_r-21.3j';l:$8000;p:$58000;crc:$ed793841),(n:'rt_r-30.3k';l:$10000;p:$60000;crc:$eb02a1cb),
        (n:'rt_r-31.3l';l:$8000;p:$70000;crc:$8558355d),(n:'rt_r-31.3l';l:$8000;p:$78000;crc:$8558355d),());
        //Hammering Harry
        hharry_rom:array[0..4] of tipo_roms=(
        (n:'a-h0-v.rom';l:$20000;p:1;crc:$c52802a5),(n:'a-l0-v.rom';l:$20000;p:$0;crc:$f463074c),
        (n:'a-h1-0.rom';l:$10000;p:$60001;crc:$3ae21335),(n:'a-l1-0.rom';l:$10000;p:$60000;crc:$bc6ac5f9),());
        hharry_char:array[0..4] of tipo_roms=(
        (n:'hh_a0.rom';l:$20000;p:0;crc:$c577ba5f),(n:'hh_a1.rom';l:$20000;p:$20000;crc:$429d12ab),
        (n:'hh_a2.rom';l:$20000;p:$40000;crc:$b5b163b0),(n:'hh_a3.rom';l:$20000;p:$60000;crc:$8ef566a1),());
        hharry_sprites:array[0..4] of tipo_roms=(
        (n:'hh_00.rom';l:$20000;p:0;crc:$ec5127ef),(n:'hh_10.rom';l:$20000;p:$20000;crc:$def65294),
        (n:'hh_20.rom';l:$20000;p:$40000;crc:$bb0d6ad4),(n:'hh_30.rom';l:$20000;p:$60000;crc:$4351044e),());
        hharry_snd:tipo_roms=(n:'a-sp-0.rom';l:$10000;p:0;crc:$80e210e7);
        hharry_dac:tipo_roms=(n:'a-v0-0.rom';l:$20000;p:0;crc:$faaacaff);
        //R-Type 2
        rtype2_rom:array[0..4] of tipo_roms=(
        (n:'rt2-a-h0-d.54';l:$20000;p:1;crc:$d8ece6f4),(n:'rt2-a-l0-d.60';l:$20000;p:$0;crc:$32cfb2e4),
        (n:'rt2-a-h1-d.53';l:$20000;p:$40001;crc:$4f6e9b15),(n:'rt2-a-l1-d.59';l:$20000;p:$40000;crc:$0fd123bf),());
        rtype2_char:array[0..8] of tipo_roms=(
        (n:'ic50.7s';l:$20000;p:0;crc:$f3f8736e),(n:'ic51.7u';l:$20000;p:$20000;crc:$b4c543af),
        (n:'ic56.8s';l:$20000;p:$40000;crc:$4cb80d66),(n:'ic57.8u';l:$20000;p:$60000;crc:$bee128e0),
        (n:'ic65.9r';l:$20000;p:$80000;crc:$2dc9c71a),(n:'ic66.9u';l:$20000;p:$a0000;crc:$7533c428),
        (n:'ic63.9m';l:$20000;p:$c0000;crc:$a6ad67f2),(n:'ic64.9p';l:$20000;p:$e0000;crc:$3686d555),());
        rtype2_sprites:array[0..4] of tipo_roms=(
        (n:'ic31.6l';l:$20000;p:0;crc:$2cd8f913),(n:'ic21.4l';l:$20000;p:$20000;crc:$5033066d),
        (n:'ic32.6m';l:$20000;p:$40000;crc:$ec3a0450),(n:'ic22.4m';l:$20000;p:$60000;crc:$db6176fc),());
        rtype2_snd:tipo_roms=(n:'ic17.4f';l:$10000;p:0;crc:$73ffecb4);
        rtype2_dac:tipo_roms=(n:'ic14.4c';l:$20000;p:0;crc:$637172d5);

type
    tipo_update_video_m72=procedure;
    tipo_paint_video_irem_m72=procedure(princ,ultimo:word);

var
 rom:array[0..$7ffff] of byte;
 spriteram:array[0..$3ff] of byte;
 palette1,palette2:array[0..$bff] of byte;
 ram,videoram1,videoram2:array[0..$3fff] of byte;
 sound_latch,snd_irq_vector,timer_sound,irq_pos:byte;
 m72_raster_irq_position,scroll_x1,scroll_y1,scroll_x2,scroll_y2:word;
 video_off:boolean;
 sample_addr:dword;
 mem_dac:array[0..$1ffff] of byte;
 irq_base:array[0..5] of byte;
 //video
 update_video_irem_m72:tipo_update_video_m72;
 paint_video_irem_m72:tipo_paint_video_irem_m72;

implementation

procedure Cargar_irem_m72;
begin
llamadas_maquina.iniciar:=iniciar_irem_m72;
llamadas_maquina.cerrar:=cerrar_irem_m72;
llamadas_maquina.reset:=reset_irem_m72;
llamadas_maquina.fps_max:=55.017606;
llamadas_maquina.bucle_general:=irem_m72_principal;
end;

function iniciar_irem_m72:boolean;
const
  pc_x:array[0..7] of dword=(0, 1, 2, 3, 4, 5, 6, 7 );
  pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8 );
  ps_x:array[0..15] of dword=(0, 1, 2, 3, 4, 5, 6, 7,
			16*8+0, 16*8+1, 16*8+2, 16*8+3, 16*8+4, 16*8+5, 16*8+6, 16*8+7);
  ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8 );
var
  memoria_temp:pbyte;
begin
iniciar_irem_m72:=false;
iniciar_audio(false);
//Pantallas:  principal+char y sprites
screen_init(1,512,512);
screen_mod_scroll(1,512,512,511,512,256,511);
screen_init(2,512,512,true);
screen_mod_scroll(2,512,512,511,512,256,511);
screen_init(3,512,512,true);
screen_mod_scroll(3,512,512,511,512,256,511);
screen_init(4,512,512,true);
screen_mod_scroll(4,512,512,511,512,256,511);
screen_init(5,1024,512,false,true);
screen_init(6,384,256);
iniciar_video(384,256);
//iniciar_video(1024,512);
//Main CPU
main_nec:=cpu_nec.create(8000000,284,NEC_V30);
//Sound CPU
snd_z80:=cpu_z80.create(3579545,284);
snd_z80.change_ram_calls(irem_m72_snd_getbyte,irem_m72_snd_putbyte);
timer_sound:=init_timer(snd_z80.numero_cpu,1,sound_irq_ack,true);
getmem(memoria_temp,$100000);
case main_vars.tipo_maquina of
  87:begin //R-Type
      //Main CPU
      main_nec.change_ram_calls(irem_m72_getbyte,irem_m72_putbyte);
      main_nec.change_io_calls16(irem_m72_inword,irem_m72_outword);
      if not(cargar_roms16b(@rom[0],@rtype_rom[0],'rtype.zip',0)) then exit;
      //Sound
      snd_z80.change_io_calls(irem_m72_snd_inbyte,irem_m72_snd_outbyte);
      snd_z80.init_sound(irem_m72_sound_update);
      //video
      update_video_irem_m72:=update_video_rtype;
      paint_video_irem_m72:=paint_video_rtype;
      //convertir chars
      if not(cargar_roms(@memoria_temp[0],@rtype_char[0],'rtype.zip',0)) then exit;
      init_gfx(0,8,8,$1000);
      gfx[0].trans[0]:=true;
      gfx_set_desc_data(4,0,8*8,$18000*8,$10000*8,$8000*8,0*8);
      convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,false);
      //chars 2
      if not(cargar_roms(@memoria_temp[0],@rtype_char2[0],'rtype.zip',0)) then exit;
      init_gfx(1,8,8,$1000);
      gfx[1].trans[0]:=true;
      convert_gfx(1,0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,false);
      //convertir sprites
      if not(cargar_roms(@memoria_temp[0],@irem_m72_sprites[0],'rtype.zip',0)) then exit;
      init_gfx(2,16,16,$1000);
      gfx[2].trans[0]:=true;
      gfx_set_desc_data(4,0,32*8,$60000*8,$40000*8,$20000*8,0);
      convert_gfx(2,0,@memoria_temp[0],@ps_x[0],@ps_y[0],false,false);
    end;
  190:begin //Hammerin' Harry
      //Main CPU
      main_nec.change_ram_calls(hharry_getbyte,hharry_putbyte);
      main_nec.change_io_calls16(hharry_inword,hharry_outword);
      main_nec.change_io_calls(hharry_inbyte,hharry_outbyte);
      if not(cargar_roms16b(@rom[0],@hharry_rom[0],'hharry.zip',0)) then exit;
      //Sound
      if not(cargar_roms(@mem_snd[0],@hharry_snd,'hharry.zip')) then exit;
      snd_z80.change_io_calls(rtype2_snd_inbyte,rtype2_snd_outbyte);
      init_timer(snd_z80.numero_cpu,3579645/(128*55),rtype2_perodic_int,true);
      snd_z80.init_sound(rtype2_sound_update);
      dac_0:=dac_chip.Create;
      if not(cargar_roms(@mem_dac[0],@hharry_dac,'hharry.zip')) then exit;
      //video
      update_video_irem_m72:=update_video_hharry;
      paint_video_irem_m72:=paint_video_hharry;
      //convertir chars
      if not(cargar_roms(@memoria_temp[0],@hharry_char[0],'hharry.zip',0)) then exit;
      init_gfx(0,8,8,$4000);
      gfx[0].trans[0]:=true;
      gfx_set_desc_data(4,0,8*8,$18000*8*4,$10000*8*4,$8000*8*4,0*8);
      convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,false);
      //convertir sprites
      if not(cargar_roms(@memoria_temp[0],@hharry_sprites[0],'hharry.zip',0)) then exit;
      init_gfx(2,16,16,$1000);
      gfx[2].trans[0]:=true;
      gfx_set_desc_data(4,0,32*8,$60000*8,$40000*8,$20000*8,0);
      convert_gfx(2,0,@memoria_temp[0],@ps_x[0],@ps_y[0],false,false);
    end;
    191:begin //R-Type 2
      //Main CPU
      main_nec.change_ram_calls(rtype2_getbyte,rtype2_putbyte);
      main_nec.change_io_calls16(rtype2_inword,rtype2_outword);
      main_nec.change_io_calls(rtype2_inbyte,rtype2_outbyte);
      if not(cargar_roms16b(@rom[0],@rtype2_rom[0],'rtype2.zip',0)) then exit;
      //Sound
      if not(cargar_roms(@mem_snd[0],@rtype2_snd,'rtype2.zip')) then exit;
      snd_z80.change_io_calls(rtype2_snd_inbyte,rtype2_snd_outbyte);
      init_timer(snd_z80.numero_cpu,3579645/(128*55),rtype2_perodic_int,true);
      snd_z80.init_sound(rtype2_sound_update);
      dac_0:=dac_chip.Create;
      if not(cargar_roms(@mem_dac[0],@rtype2_dac,'rtype2.zip')) then exit;
      //video
      update_video_irem_m72:=update_video_rtype2;
      paint_video_irem_m72:=paint_video_rtype2;
      //convertir chars
      if not(cargar_roms(@memoria_temp[0],@rtype2_char[0],'rtype2.zip',0)) then exit;
      init_gfx(0,8,8,$8000);
      gfx[0].trans[0]:=true;
      gfx_set_desc_data(4,0,8*8,$18000*8*4*2,$10000*8*4*2,$8000*8*4*2,0*8);
      convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,false);
      //convertir sprites
      if not(cargar_roms(@memoria_temp[0],@rtype2_sprites[0],'rtype2.zip',0)) then exit;
      init_gfx(2,16,16,$1000);
      gfx[2].trans[0]:=true;
      gfx_set_desc_data(4,0,32*8,$60000*8,$40000*8,$20000*8,0);
      convert_gfx(2,0,@memoria_temp[0],@ps_x[0],@ps_y[0],false,false);
    end;
end;
//Sound Chips
YM2151_Init(0,3579545,nil,ym2151_snd_irq);
freemem(memoria_temp);
reset_irem_m72;
iniciar_irem_m72:=true;
end;

procedure cerrar_irem_m72;
begin
main_nec.free;
snd_z80.free;
YM2151_Close(0);
case main_vars.tipo_maquina of
  190,191:dac_0.Free;
end;
close_audio;
close_video;
end;

procedure reset_irem_m72;
begin
 main_nec.reset;
 snd_z80.reset;
 YM2151_Reset(0);
 case main_vars.tipo_maquina of
  190,191:dac_0.reset;
 end;
 reset_audio;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 scroll_x1:=0;
 scroll_x2:=0;
 scroll_y1:=0;
 scroll_y2:=0;
 snd_irq_vector:=$ff;
 sound_latch:=0;
 m72_raster_irq_position:=0;
 video_off:=true;
 sample_addr:=0;
 fillchar(irq_base[0],5,0);
 irq_pos:=0;
 timer[timer_sound].enabled:=false;
end;

procedure draw_sprites;inline;
var
  f,nchar,atrib,color,c:word;
  flipx,flipy:boolean;
  w,h,wx,wy:byte;
  x,y:integer;
begin
for f:=0 to $7f do begin
		nchar:=(buffer_sprites[(f*8)+2]+(buffer_sprites[(f*8)+3] shl 8)) and $fff;
		atrib:=buffer_sprites[(f*8)+4]+(buffer_sprites[(f*8)+5] shl 8);
    color:=(atrib and $f) shl 4;
		x:=(buffer_sprites[(f*8)+6]+(buffer_sprites[(f*8)+7] shl 8))-256;
		y:=384-(buffer_sprites[(f*8)+0]+(buffer_sprites[(f*8)+1] shl 8));
		flipx:=(atrib and $800)<>0;
		flipy:=(atrib and $400)<>0;
		w:=1 shl ((atrib and $c000) shr 14);
		h:=1 shl ((atrib and $3000) shr 12);
		y:=y-(16*h);
		for wx:=0 to (w-1) do begin
			for wy:=0 to (h-1) do begin
        c:=nchar;
				if flipx then c:=c+8*(w-1-wx)
				  else c:=c+8*wx;
				if flipy then c:=c+h-1-wy
				  else c:=c+wy;
        put_gfx_sprite(c and $fff,color,flipx,flipy,2);
        actualiza_gfx_sprite((x+16*wx) and $3ff,(y+16*wy) and $1ff,5,2);
			end;
		end;
end;
end;

procedure update_video_rtype;
var
  f,x,y,nchar,atrib,atrib2,color:word;
begin
for f:=0 to $fff do begin
    x:=f mod 64;
    y:=f div 64;
    atrib2:=videoram2[(f*4)+2];
    color:=atrib2 and $f;
      if (gfx[1].buffer[f] or buffer_color[color]) then begin
        //Background
        atrib:=videoram2[(f*4)+1];
        nchar:=(videoram2[(f*4)+0]+((atrib and $3f) shl 8)) and $fff;
        if (atrib2 and $80)=0 then begin
          put_gfx_flip(x*8,y*8,nchar,(color shl 4)+256,1,1,(atrib and $40)<>0,(atrib and $80)<>0);
          put_gfx_block_trans(x*8,y*8,2,8,8);
        end else begin
          put_gfx_block(x*8,y*8,1,8,8,0);
          put_gfx_trans_flip(x*8,y*8,nchar,(color shl 4)+256,2,1,(atrib and $40)<>0,(atrib and $80)<>0);
        end;
        gfx[1].buffer[f]:=false;
      end;
      //Foreground
      atrib2:=videoram1[(f*4)+2];
      color:=atrib2 and $f;
      if (gfx[0].buffer[f] or buffer_color[color]) then begin
        atrib:=videoram1[(f*4)+1];
        nchar:=(videoram1[(f*4)+0]+((atrib and $3f) shl 8)) and $fff;
        if (atrib2 and $80)=0 then begin
          put_gfx_trans_flip(x*8,y*8,nchar,(color shl 4)+256,3,0,(atrib and $40)<>0,(atrib and $80)<>0);
          put_gfx_block_trans(x*8,y*8,4,8,8);
        end else begin
          put_gfx_block_trans(x*8,y*8,3,8,8);
          put_gfx_trans_flip(x*8,y*8,nchar,(color shl 4)+256,4,0,(atrib and $40)<>0,(atrib and $80)<>0);
        end;
        gfx[0].buffer[f]:=false;
      end;
end;
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure paint_video_rtype(linea_o,linea_d:word);
begin
scroll_x_y(1,5,scroll_x2,scroll_y2+128);
scroll_x_y(3,5,scroll_x1,scroll_y1+129);
draw_sprites;
scroll_x_y(2,5,scroll_x2,scroll_y2+128);
scroll_x_y(4,5,scroll_x1,scroll_y1+129);
//Actualizar el video desde la linea actual a la ultima pintada
actualiza_trozo(64+ADD_SPRITE,linea_o+ADD_SPRITE,384+ADD_SPRITE,(linea_d-linea_o)+ADD_SPRITE,5,0,linea_o,384,linea_d-linea_o,6);
end;

procedure cambiar_color1(num:word);
var
  color:tcolor;
begin
  color.r:=pal5bit(palette1[num]);
  color.g:=pal5bit(palette1[num+$400]);
  color.b:=pal5bit(palette1[num+$800]);
  set_pal_color(color,@paleta[num shr 1]);
end;

procedure cambiar_color2(num:word);
var
  color:tcolor;
begin
  color.r:=pal5bit(palette2[num]);
  color.g:=pal5bit(palette2[num+$400]);
  color.b:=pal5bit(palette2[num+$800]);
  num:=num shr 1;
  set_pal_color(color,@paleta[num+$100]);
  buffer_color[(num shr 4) and $f]:=true;
end;

procedure eventos_irem_m72;
begin
if event.arcade then begin
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $Fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $F7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.but2[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  //marcade.in1
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $Fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.coin[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.coin[1] then marcade.in1:=(marcade.in1 and $F7) else marcade.in1:=(marcade.in1 or $8);
end;
end;

procedure irem_m72_principal;
var
  frame_m,frame_s:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=main_nec.tframes;
frame_s:=snd_z80.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to 283 do begin
    //Main CPU
    main_nec.run(frame_m);
    frame_m:=frame_m+main_nec.tframes-main_nec.contador;
    //Sound CPU
    snd_z80.run(frame_s);
    frame_s:=frame_s+snd_z80.tframes-snd_z80.contador;
    if ((f<255) and (f=(m72_raster_irq_position-1))) then begin
      main_nec.vect_req:=irq_base[1]+2;
      main_nec.pedir_irq:=true;
      if not(video_off) then paint_video_irem_m72(0,f);
    end;
    if f=255 then begin
      main_nec.vect_req:=irq_base[1];
      main_nec.pedir_irq:=true;
      if not(video_off) then begin
        paint_video_irem_m72(m72_raster_irq_position and $ff,f);
        update_video_irem_m72;
      end else fill_full_screen(0,0);
    end;
 end;
 actualiza_trozo_simple(0,0,384,256,6);
 eventos_irem_m72;
 video_sync;
end;
end;

//R-Type
function irem_m72_getbyte(direccion:dword):byte;
begin
case direccion of
  0..$3ffff:irem_m72_getbyte:=rom[direccion];
  $40000..$43fff:irem_m72_getbyte:=ram[direccion and $3fff];
  $c0000..$c03ff:irem_m72_getbyte:=spriteram[direccion and $3ff];
	$c8000..$c8bff:if (direccion and 1)<>0 then irem_m72_getbyte:=$ff
                      else irem_m72_getbyte:=palette1[(direccion and $1ff)+(direccion and $c00)]+$e0;
	$cc000..$ccbff:if (direccion and 1)<>0 then irem_m72_getbyte:=$ff
                    else irem_m72_getbyte:=palette2[(direccion and $1ff)+(direccion and $c00)]+$e0;
	$d0000..$d3fff:irem_m72_getbyte:=videoram1[direccion and $3fff];
	$d8000..$dbfff:irem_m72_getbyte:=videoram2[direccion and $3fff];
	$e0000..$effff:irem_m72_getbyte:=mem_snd[direccion and $ffff];
  $ffff0..$fffff:irem_m72_getbyte:=rom[direccion and $3ffff];
end;
end;

procedure irem_m72_putbyte(direccion:dword;valor:byte);
begin
case direccion of
  0..$3ffff,$ffff0..$fffff:exit;
  $40000..$43fff:ram[direccion and $3fff]:=valor;  //ram 1
  $c0000..$c03ff:spriteram[direccion and $3ff]:=valor; //ram 7
  $c8000..$c8bff:begin //ram 0
                    palette1[(direccion and $1ff)+(direccion and $c00)]:=valor;
                    cambiar_color1(direccion and $1fe);
                 end;
	$cc000..$ccbff:begin
                    palette2[(direccion and $1ff)+(direccion and $c00)]:=valor; //ram 9
                    cambiar_color2(direccion and $1fe);
                 end;
	$d0000..$d3fff:begin  //ram 3
                    videoram1[direccion and $3fff]:=valor;
                    gfx[0].buffer[(direccion and $3fff) shr 2]:=true;
                 end;
	$d8000..$dbfff:begin
                    videoram2[direccion and $3fff]:=valor;  //ram 4
                    gfx[1].buffer[(direccion and $3fff) shr 2]:=true;
                 end;
	$e0000..$effff:mem_snd[direccion and $ffff]:=valor;
end;
end;

procedure irem_m72_outword(valor:word;puerto:word);
begin
case puerto of
  0:begin
      sound_latch:=valor and $ff;
      snd_irq_vector:=snd_irq_vector and $df;
      timer[timer_sound].enabled:=true;
    end;
  2:begin
      if (valor and $10)=0 then snd_z80.pedir_reset:=ASSERT_LINE
        else snd_z80.pedir_reset:=CLEAR_LINE;
      video_off:=(valor and $08)<>0;
    end;
  4:begin //DMA
      copymemory(@buffer_sprites[0],@spriteram[0],$400);
      fillchar(spriteram[0],$400,0);
   end;
  6:m72_raster_irq_position:=valor-128;
  $40:begin
        irq_base[0]:=valor;
        irq_pos:=1;
      end;
  $42:begin
        irq_base[irq_pos]:=valor;
        irq_pos:=irq_pos+1;
      end;
  $80:if scroll_y1<>valor then scroll_y1:=valor;  //FG
  $82:if scroll_x1<>valor then scroll_x1:=valor;  //FG
  $84:if scroll_y2<>valor then scroll_y2:=valor;  //BG
  $86:if scroll_x2<>valor then scroll_x2:=valor;  //FG
end;
end;

function irem_m72_inword(puerto:word):word;
begin
  case puerto of
    0:irem_m72_inword:=$ff00+marcade.in0;
    2:irem_m72_inword:=$ff00+marcade.in1;
    4:irem_m72_inword:=$fdfb;
  end;
end;

//Hammerin' Harry
procedure update_video_hharry;
var
  f,x,y,nchar,atrib,atrib2,color:word;
begin
for f:=0 to $fff do begin
    x:=f mod 64;
    y:=f div 64;
    atrib2:=videoram2[(f*4)+2];
    color:=atrib2 and $f;
      if (gfx[1].buffer[f] or buffer_color[color]) then begin
        //Background
        atrib:=videoram2[(f*4)+1];
        nchar:=(videoram2[(f*4)+0]+((atrib and $3f) shl 8)) and $3fff;
        if (atrib2 and $80)=0 then begin
          put_gfx_flip(x*8,y*8,nchar,(color shl 4)+256,1,0,(atrib and $40)<>0,(atrib and $80)<>0);
          put_gfx_block_trans(x*8,y*8,2,8,8);
        end else begin
          put_gfx_block(x*8,y*8,1,8,8,0);
          put_gfx_trans_flip(x*8,y*8,nchar,(color shl 4)+256,2,0,(atrib and $40)<>0,(atrib and $80)<>0);
        end;
        gfx[1].buffer[f]:=false;
      end;
      //Foreground
      atrib2:=videoram1[(f*4)+2];
      color:=atrib2 and $f;
      if (gfx[0].buffer[f] or buffer_color[color]) then begin
        atrib:=videoram1[(f*4)+1];
        nchar:=(videoram1[(f*4)+0]+((atrib and $3f) shl 8)) and $3fff;
        if (atrib2 and $80)=0 then begin
          put_gfx_trans_flip(x*8,y*8,nchar,(color shl 4)+256,3,0,(atrib and $40)<>0,(atrib and $80)<>0);
          put_gfx_block_trans(x*8,y*8,4,8,8);
        end else begin
          put_gfx_block_trans(x*8,y*8,3,8,8);
          put_gfx_trans_flip(x*8,y*8,nchar,(color shl 4)+256,4,0,(atrib and $40)<>0,(atrib and $80)<>0);
        end;
        gfx[0].buffer[f]:=false;
      end;
end;
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure paint_video_hharry(linea_o,linea_d:word);
begin
scroll_x_y(1,5,scroll_x2-6,scroll_y2+128);
scroll_x_y(3,5,scroll_x1-4,scroll_y1+128);
draw_sprites;
scroll_x_y(2,5,scroll_x2-6,scroll_y2+128);
scroll_x_y(4,5,scroll_x1-4,scroll_y1+128);
//Actualizar el video desde la linea actual a la ultima pintada
actualiza_trozo(64+ADD_SPRITE,linea_o+ADD_SPRITE,384+ADD_SPRITE,(linea_d-linea_o)+ADD_SPRITE,5,0,linea_o,384,linea_d-linea_o,6);
end;

function hharry_getbyte(direccion:dword):byte;
begin
case direccion of
  0..$7ffff:hharry_getbyte:=rom[direccion];
  $a0000..$a3fff:hharry_getbyte:=ram[direccion and $3fff];
  $c0000..$c03ff:hharry_getbyte:=spriteram[direccion and $3ff];
	$c8000..$c8bff:if (direccion and 1)<>0 then hharry_getbyte:=$ff
                      else hharry_getbyte:=palette1[(direccion and $1ff)+(direccion and $c00)]+$e0;
	$cc000..$ccbff:if (direccion and 1)<>0 then hharry_getbyte:=$ff
                    else hharry_getbyte:=palette2[(direccion and $1ff)+(direccion and $c00)]+$e0;
	$d0000..$d3fff:hharry_getbyte:=videoram1[direccion and $3fff];
	$d8000..$dbfff:hharry_getbyte:=videoram2[direccion and $3fff];
  $ffff0..$fffff:hharry_getbyte:=rom[direccion and $7ffff];
end;
end;

procedure hharry_putbyte(direccion:dword;valor:byte);
begin
case direccion of
  0..$7ffff,$ffff0..$fffff:exit;
  $a0000..$a3fff:ram[direccion and $3fff]:=valor;  //ram 1
  $c0000..$c03ff:spriteram[direccion and $3ff]:=valor; //ram 7
  $c8000..$c8bff:begin //ram 0
                    palette1[(direccion and $1ff)+(direccion and $c00)]:=valor;
                    cambiar_color1(direccion and $1fe);
                 end;
	$cc000..$ccbff:begin
                    palette2[(direccion and $1ff)+(direccion and $c00)]:=valor; //ram 9
                    cambiar_color2(direccion and $1fe);
                 end;
	$d0000..$d3fff:begin  //ram 3
                    videoram1[direccion and $3fff]:=valor;
                    gfx[0].buffer[(direccion and $3fff) shr 2]:=true;
                 end;
	$d8000..$dbfff:begin
                    videoram2[direccion and $3fff]:=valor;  //ram 4
                    gfx[1].buffer[(direccion and $3fff) shr 2]:=true;
                 end;
end;
end;

procedure out_io(puerto,valor:word);
begin
case puerto of
  0:begin
      sound_latch:=valor and $ff;
      snd_irq_vector:=snd_irq_vector and $df;
      timer[timer_sound].enabled:=true;
    end;
  2:video_off:=(valor and $08)<>0;
  4:begin //DMA
      copymemory(@buffer_sprites[0],@spriteram[0],$400);
      fillchar(spriteram[0],$400,0);
   end;
  6:m72_raster_irq_position:=valor-128;
  $40:begin
        irq_base[0]:=valor;
        irq_pos:=1;
      end;
  $42:begin
        irq_base[irq_pos]:=valor;
        irq_pos:=irq_pos+1;
      end;
  $80:if scroll_y1<>valor then scroll_y1:=valor;  //FG
  $82:if scroll_x1<>valor then scroll_x1:=valor;  //FG
  $84:if scroll_y2<>valor then scroll_y2:=valor;  //BG
  $86:if scroll_x2<>valor then scroll_x2:=valor;  //FG
end;
end;

procedure hharry_outword(valor:word;puerto:word);
begin
  out_io(puerto,valor);
end;

function in_io(puerto:word):word;
begin
  case puerto of
    0:in_io:=$ff00+marcade.in0;
    2:in_io:=$ff00+marcade.in1;
    4:in_io:=$fdbf;
  end;
end;

function hharry_inword(puerto:word):word;
begin
  hharry_inword:=in_io(puerto);
end;

procedure hharry_outbyte(valor:byte;puerto:word);
begin
  out_io(puerto,valor);
end;

function hharry_inbyte(puerto:word):byte;
begin
  if (puerto and 1)<>0 then hharry_inbyte:=in_io(puerto) shr 8
    else hharry_inbyte:=in_io(puerto) and $ff;
end;

//Rtype2
procedure update_video_rtype2;
var
  f,x,y,nchar,atrib,atrib2,color:word;
begin
for f:=0 to $fff do begin
    x:=f mod 64;
    y:=f div 64;
    atrib2:=videoram2[(f*4)+2];
    color:=atrib2 and $f;
      if (gfx[1].buffer[f] or buffer_color[color]) then begin
        //Background
        atrib:=videoram2[(f*4)+3];
        nchar:=(videoram2[(f*4)+0]+(videoram2[(f*4)+1] shl 8)) and $7fff;
        if (atrib and $1)=0 then begin
          put_gfx_flip(x*8,y*8,nchar,(color shl 4)+256,1,0,(atrib2 and $20)<>0,(atrib2 and $40)<>0);
          put_gfx_block_trans(x*8,y*8,2,8,8);
        end else begin
          put_gfx_block(x*8,y*8,1,8,8,0);
          put_gfx_trans_flip(x*8,y*8,nchar,(color shl 4)+256,2,0,(atrib2 and $20)<>0,(atrib2 and $40)<>0);
        end;
        gfx[1].buffer[f]:=false;
      end;
      //Foreground
      atrib2:=videoram1[(f*4)+2];
      color:=atrib2 and $f;
      if (gfx[0].buffer[f] or buffer_color[color]) then begin
        atrib:=videoram1[(f*4)+3];
        nchar:=(videoram1[(f*4)+0]+(videoram1[(f*4)+1] shl 8)) and $7fff;
        if (atrib and $1)=0 then begin
          put_gfx_trans_flip(x*8,y*8,nchar,(color shl 4)+256,3,0,(atrib2 and $20)<>0,(atrib2 and $40)<>0);
          put_gfx_block_trans(x*8,y*8,4,8,8);
        end else begin
          put_gfx_block_trans(x*8,y*8,3,8,8);
          put_gfx_trans_flip(x*8,y*8,nchar,(color shl 4)+256,4,0,(atrib2 and $20)<>0,(atrib2 and $40)<>0);
        end;
        gfx[0].buffer[f]:=false;
      end;
end;
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure paint_video_rtype2(linea_o,linea_d:word);
begin
scroll_x_y(1,5,scroll_x2-6,scroll_y2+128);
scroll_x_y(3,5,scroll_x1-4,scroll_y1+128);
draw_sprites;
scroll_x_y(2,5,scroll_x2-6,scroll_y2+128);
scroll_x_y(4,5,scroll_x1-4,scroll_y1+128);
//Actualizar el video desde la linea actual a la ultima pintada
actualiza_trozo(64+ADD_SPRITE,linea_o+ADD_SPRITE,384+ADD_SPRITE,(linea_d-linea_o)+ADD_SPRITE,5,0,linea_o,384,linea_d-linea_o,6);
end;

function rtype2_getbyte(direccion:dword):byte;
begin
case direccion of
  0..$7ffff:rtype2_getbyte:=rom[direccion];
  $c0000..$c03ff:rtype2_getbyte:=spriteram[direccion and $3ff];
	$c8000..$c8bff:if (direccion and 1)<>0 then rtype2_getbyte:=$ff
                      else rtype2_getbyte:=palette1[(direccion and $1ff)+(direccion and $c00)]+$e0;
	$d0000..$d3fff:rtype2_getbyte:=videoram1[direccion and $3fff];
	$d4000..$d7fff:rtype2_getbyte:=videoram2[direccion and $3fff];
  $d8000..$d8bff:if (direccion and 1)<>0 then rtype2_getbyte:=$ff
                    else rtype2_getbyte:=palette2[(direccion and $1ff)+(direccion and $c00)]+$e0;
  $e0000..$e3fff:rtype2_getbyte:=ram[direccion and $3fff];
  $ffff0..$fffff:rtype2_getbyte:=rom[direccion and $7ffff];
end;
end;

procedure rtype2_putbyte(direccion:dword;valor:byte);
begin
case direccion of
  0..$7ffff,$ffff0..$fffff:exit;
  $b0000..$b0001:begin //DMA
      copymemory(@buffer_sprites[0],@spriteram[0],$400);
      //fillchar(spriteram[0],$400,0);
   end;
  $bc000..$bc001:m72_raster_irq_position:=valor+64;
  $c0000..$c03ff:spriteram[direccion and $3ff]:=valor; //ram 7
  $c8000..$c8bff:begin //ram 0
                    palette1[(direccion and $1ff)+(direccion and $c00)]:=valor;
                    cambiar_color1(direccion and $1fe);
                 end;
	$d0000..$d3fff:begin  //ram 3
                    videoram1[direccion and $3fff]:=valor;
                    gfx[0].buffer[(direccion and $3fff) shr 2]:=true;
                 end;
	$d4000..$d7fff:begin
                    videoram2[direccion and $3fff]:=valor;  //ram 4
                    gfx[1].buffer[(direccion and $3fff) shr 2]:=true;
                 end;
  $d8000..$d8bff:begin
                    palette2[(direccion and $1ff)+(direccion and $c00)]:=valor; //ram 9
                    cambiar_color2(direccion and $1fe);
                 end;
  $e0000..$e3fff:ram[direccion and $3fff]:=valor;  //ram 1
end;
end;

procedure rtype2_out_io(puerto,valor:word);
begin
case puerto of
  0:begin
      sound_latch:=valor and $ff;
      snd_irq_vector:=snd_irq_vector and $df;
      timer[timer_sound].enabled:=true;
    end;
  2:video_off:=(valor and $08)<>0;
  $40:begin
        irq_base[0]:=valor;
        irq_pos:=1;
      end;
  $42:begin
        irq_base[irq_pos]:=valor;
        irq_pos:=irq_pos+1;
      end;
  $80:if scroll_y1<>valor then scroll_y1:=valor;  //FG
  $82:if scroll_x1<>valor then scroll_x1:=valor;  //FG
  $84:if scroll_y2<>valor then scroll_y2:=valor;  //BG
  $86:if scroll_x2<>valor then scroll_x2:=valor;  //FG
  $8c:;
end;
end;

procedure rtype2_outword(valor:word;puerto:word);
begin
  rtype2_out_io(puerto,valor);
end;

function rtype2_in_io(puerto:word):word;
begin
  case puerto of
    0:rtype2_in_io:=$ff00+marcade.in0;
    2:rtype2_in_io:=$ff00+marcade.in1;
    4:rtype2_in_io:=$f7ff;
  end;
end;

function rtype2_inword(puerto:word):word;
begin
  rtype2_inword:=rtype2_in_io(puerto);
end;

procedure rtype2_outbyte(valor:byte;puerto:word);
begin
  rtype2_out_io(puerto,valor);
end;

function rtype2_inbyte(puerto:word):byte;
begin
  if (puerto and 1)<>0 then rtype2_inbyte:=rtype2_in_io(puerto) shr 8
    else rtype2_inbyte:=rtype2_in_io(puerto) and $ff;
end;

//Sound
procedure sound_irq_ack;
begin
snd_z80.im0:=snd_irq_vector;
if snd_irq_vector=$ff then snd_z80.pedir_irq:=CLEAR_LINE
  else snd_z80.pedir_irq:=ASSERT_LINE;
timer[timer_sound].enabled:=false;
end;

function irem_m72_snd_getbyte(direccion:word):byte;
begin
  irem_m72_snd_getbyte:=mem_snd[direccion];
end;

procedure irem_m72_snd_putbyte(direccion:word;valor:byte);
begin
  mem_snd[direccion]:=valor;
end;

function irem_m72_snd_inbyte(puerto:word):byte;
begin
case (puerto and $ff) of
  $1:irem_m72_snd_inbyte:=YM2151_status_port_read(0);
  $2:irem_m72_snd_inbyte:=sound_latch;
end;
end;

procedure irem_m72_snd_outbyte(valor:byte;puerto:word);
begin
case (puerto and $ff) of
  $0:YM2151_register_port_write(0,valor);
  $1:YM2151_data_port_write(0,valor);
  $6:begin
      snd_irq_vector:=snd_irq_vector or $20;
      timer[timer_sound].enabled:=true;
    end;
end;
end;

function rtype2_snd_inbyte(puerto:word):byte;
begin
case (puerto and $ff) of
  $1:rtype2_snd_inbyte:=YM2151_status_port_read(0);
  $80:rtype2_snd_inbyte:=sound_latch;
  $84:rtype2_snd_inbyte:=mem_dac[sample_addr];
end;
end;

procedure rtype2_snd_outbyte(valor:byte;puerto:word);
begin
case (puerto and $ff) of
  $0:YM2151_register_port_write(0,valor);
  $1:YM2151_data_port_write(0,valor);
  $80:begin
        sample_addr:=sample_addr shr 5;
        sample_addr:=(sample_addr and $ff00) or valor;
        sample_addr:=sample_addr shl 5;
      end;
  $81:begin
        sample_addr:=sample_addr shr 5;
        sample_addr:=(sample_addr and $ff) or (valor shl 8);
        sample_addr:=sample_addr shl 5;
      end;
  $82:begin
        dac_0.signed_data8_w(valor);
        sample_addr:=(sample_addr+1) and $1ffff;
      end;
  $83:begin
      snd_irq_vector:=snd_irq_vector or $20;
      timer[timer_sound].enabled:=true;
    end;
end;
end;

procedure ym2151_snd_irq(irqstate:byte);
begin
  if irqstate=1 then snd_irq_vector:=snd_irq_vector and $ef
    else snd_irq_vector:=snd_irq_vector or $10;
  timer[timer_sound].enabled:=true;
end;

procedure rtype2_perodic_int;
begin
  snd_z80.pedir_nmi:=PULSE_LINE;
end;

procedure irem_m72_sound_update;
begin
  ym2151_Update(0);
end;

procedure rtype2_sound_update;
begin
  ym2151_Update(0);
  dac_0.update;
end;


end.
