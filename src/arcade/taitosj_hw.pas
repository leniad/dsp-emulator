unit taitosj_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,ay_8910,gfx_engine,rom_engine,
     pal_engine,sound_engine,timer_engine,dac,m6805;

procedure Cargar_taitosj;
procedure taitosj_nomcu_principal;
procedure taitosj_mcu_principal;
function taitosj_iniciar:boolean;
procedure taitosj_reset;
procedure taitosj_cerrar;
//Main CPU
function taitosj_nomcu_getbyte(direccion:word):byte;
procedure taitosj_nomcu_putbyte(direccion:word;valor:byte);
function taitosj_mcu_getbyte(direccion:word):byte;
procedure taitosj_mcu_putbyte(direccion:word;valor:byte);
//Sound CPU
function taitosj_snd_getbyte(direccion:word):byte;
procedure taitosj_snd_putbyte(direccion:word;valor:byte);
//MCU
function mcu_taitosj_getbyte(direccion:word):byte;
procedure mcu_taitosj_putbyte(direccion:word;valor:byte);
procedure taitosj_sound_update;
procedure taitosj_snd_irq;
function ay0_porta_read:byte;
function ay0_portb_read:byte;
procedure ay1_porta_write(valor:byte);
procedure ay1_portb_write(valor:byte);
procedure ay2_porta_write(valor:byte);
procedure ay3_portb_write(valor:byte);

const
        //Elevator Action
        elevator_rom:array[0..8] of tipo_roms=(
        (n:'ea-ic69.bin';l:$1000;p:0;crc:$24e277ef),(n:'ea-ic68.bin';l:$1000;p:$1000;crc:$13702e39),
        (n:'ea-ic67.bin';l:$1000;p:$2000;crc:$46f52646),(n:'ea-ic66.bin';l:$1000;p:$3000;crc:$e22fe57e),
        (n:'ea-ic65.bin';l:$1000;p:$4000;crc:$c10691d7),(n:'ea-ic64.bin';l:$1000;p:$5000;crc:$8913b293),
        (n:'ea-ic55.bin';l:$1000;p:$6000;crc:$1cabda08),(n:'ea-ic54.bin';l:$1000;p:$7000;crc:$f4647b4f),());
        elevator_sonido:array[0..2] of tipo_roms=(
        (n:'ea-ic70.bin';l:$1000;p:0;crc:$6d5f57cb),(n:'ea-ic71.bin';l:$1000;p:$1000;crc:$f0a769a1),());
        elevator_mcu:tipo_roms=(n:'ba3.11';l:$800;p:0;crc:$9ce75afc);
        elevator_char:array[0..8] of tipo_roms=(
        (n:'ea-ic1.bin';l:$1000;p:0;crc:$bbbb3fba),(n:'ea-ic2.bin';l:$1000;p:$1000;crc:$639cc2fd),
        (n:'ea-ic3.bin';l:$1000;p:$2000;crc:$61317eea),(n:'ea-ic4.bin';l:$1000;p:$3000;crc:$55446482),
        (n:'ea-ic5.bin';l:$1000;p:$4000;crc:$77895c0f),(n:'ea-ic6.bin';l:$1000;p:$5000;crc:$9a1b6901),
        (n:'ea-ic7.bin';l:$1000;p:$6000;crc:$839112ec),(n:'ea-ic8.bin';l:$1000;p:$7000;crc:$db7ff692),());
        elevator_prom:tipo_roms=(n:'eb16.22';l:$100;p:0;crc:$b833b5ea);
        //Jungle King
        junglek_rom:array[0..9] of tipo_roms=(
        (n:'kn21-1.bin';l:$1000;p:0;crc:$45f55d30),(n:'kn22-1.bin';l:$1000;p:$1000;crc:$07cc9a21),
        (n:'kn43.bin';l:$1000;p:$2000;crc:$a20e5a48),(n:'kn24.bin';l:$1000;p:$3000;crc:$19ea7f83),
        (n:'kn25.bin';l:$1000;p:$4000;crc:$844365ea),(n:'kn46.bin';l:$1000;p:$5000;crc:$27a95fd5),
        (n:'kn47.bin';l:$1000;p:$6000;crc:$5c3199e0),(n:'kn28.bin';l:$1000;p:$7000;crc:$194a2d09),
        (n:'kn60.bin';l:$1000;p:$8000;crc:$1a9c0a26),());
        junglek_sonido:array[0..3] of tipo_roms=(
        (n:'kn37.bin';l:$1000;p:0;crc:$dee7f5d4),(n:'kn38.bin';l:$1000;p:$1000;crc:$bffd3d21),
        (n:'kn59-1.bin';l:$1000;p:$2000;crc:$cee485fc),());
        junglek_char:array[0..8] of tipo_roms=(
        (n:'kn29.bin';l:$1000;p:0;crc:$8f83c290),(n:'kn30.bin';l:$1000;p:$1000;crc:$89fd19f1),
        (n:'kn51.bin';l:$1000;p:$2000;crc:$70e8fc12),(n:'kn52.bin';l:$1000;p:$3000;crc:$bcbac1a3),
        (n:'kn53.bin';l:$1000;p:$4000;crc:$b946c87d),(n:'kn34.bin';l:$1000;p:$5000;crc:$320db2e1),
        (n:'kn55.bin';l:$1000;p:$6000;crc:$70aef58f),(n:'kn56.bin';l:$1000;p:$7000;crc:$932eb667),());
        junglek_prom:tipo_roms=(n:'eb16.22';l:$100;p:0;crc:$b833b5ea);
        //Misc
        voltable:array[0..$ff] of byte=(
      	$ff,$fe,$fc,$fb,$f9,$f7,$f6,$f4,$f3,$f2,$f1,$ef,$ee,$ec,$eb,$ea,
      	$e8,$e7,$e5,$e4,$e2,$e1,$e0,$df,$de,$dd,$dc,$db,$d9,$d8,$d7,$d6,
      	$d5,$d4,$d3,$d2,$d1,$d0,$cf,$ce,$cd,$cc,$cb,$ca,$c9,$c8,$c7,$c6,
      	$c5,$c4,$c3,$c2,$c1,$c0,$bf,$bf,$be,$bd,$bc,$bb,$ba,$ba,$b9,$b8,
      	$b7,$b7,$b6,$b5,$b4,$b3,$b3,$b2,$b1,$b1,$b0,$af,$ae,$ae,$ad,$ac,
      	$ab,$aa,$aa,$a9,$a8,$a8,$a7,$a6,$a6,$a5,$a5,$a4,$a3,$a2,$a2,$a1,
      	$a1,$a0,$a0,$9f,$9e,$9e,$9d,$9d,$9c,$9c,$9b,$9b,$9a,$99,$99,$98,
      	$97,$97,$96,$96,$95,$95,$94,$94,$93,$93,$92,$92,$91,$91,$90,$90,
      	$8b,$8b,$8a,$8a,$89,$89,$89,$88,$88,$87,$87,$87,$86,$86,$85,$85,
      	$84,$84,$83,$83,$82,$82,$82,$81,$81,$81,$80,$80,$7f,$7f,$7f,$7e,
      	$7e,$7e,$7d,$7d,$7c,$7c,$7c,$7b,$7b,$7b,$7a,$7a,$7a,$79,$79,$79,
      	$78,$78,$77,$77,$77,$76,$76,$76,$75,$75,$75,$74,$74,$74,$73,$73,
      	$73,$73,$72,$72,$72,$71,$71,$71,$70,$70,$70,$70,$6f,$6f,$6f,$6e,
      	$6e,$6e,$6d,$6d,$6d,$6c,$6c,$6c,$6c,$6b,$6b,$6b,$6b,$6a,$6a,$6a,
      	$6a,$69,$69,$69,$68,$68,$68,$68,$68,$67,$67,$67,$66,$66,$66,$66,
      	$65,$65,$65,$65,$64,$64,$64,$64,$64,$63,$63,$63,$63,$62,$62,$62);
        //Graphics
        pc_x:array[0..7] of dword=(7, 6, 5, 4, 3, 2, 1, 0);
        pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
        ps_x:array[0..15] of dword=(7, 6, 5, 4, 3, 2, 1, 0,
  	  	8*8+7, 8*8+6, 8*8+5, 8*8+4, 8*8+3, 8*8+2, 8*8+1, 8*8+0);
        ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
  			16*8, 17*8, 18*8, 19*8, 20*8, 21*8, 22*8, 23*8);

var
 memoria_rom:array[0..1,0..$1fff] of byte;
 gfx_rom:array[0..$7fff] of byte;
 rweights,gweights,bweights:array[0..2] of single;
 collision_reg:array[0..3] of byte;
 scroll:array[0..5] of byte;
 colorbank:array[0..1] of byte;
 scroll_y:array[0..$5f] of byte;
 draw_order:array[0..31,0..3] of byte;
 gfx_pos:word;
 video_priority,soundlatch,rom_bank,video_mode,dac_out,dac_vol,
 input_port_4_f0,sprite_offset:byte;
 sndnmi_disable,rechars1,rechars2:boolean;
 gfx_back_buf,gfx_mid_buf,gfx_front_buf:array[0..$3ff] of boolean;
 //mcu
 mcu_mem:array[0..$7ff] of byte;
 mcu_toz80,mcu_zready,mcu_zaccept,mcu_address,mcu_busreq,mcu_fromz80,mcu_portA_in,
 mcu_portA_out:byte;

implementation

procedure Cargar_taitosj;
begin
llamadas_maquina.iniciar:=taitosj_iniciar;
case main_vars.tipo_maquina of
  185:llamadas_maquina.bucle_general:=taitosj_mcu_principal;
  189:llamadas_maquina.bucle_general:=taitosj_nomcu_principal;
end;
llamadas_maquina.cerrar:=taitosj_cerrar;
llamadas_maquina.reset:=taitosj_reset;
end;

function taitosj_iniciar:boolean;
const
  resistances:array[0..2] of integer=(1000,470,270);
var
  memoria_temp:array[0..$8fff] of byte;
  i,j,mask,data:byte;
begin
taitosj_iniciar:=false;
iniciar_audio(false);
//Back
screen_init(1,256,256,true);
screen_mod_scroll(1,256,256,255,256,256,255);
//Mid
screen_init(2,256,256,true);
screen_mod_scroll(2,256,256,255,256,256,255);
//Front
screen_init(3,256,256,true);
screen_mod_scroll(3,256,256,255,256,256,255);
screen_init(4,256,256,false,true); //Final
iniciar_video(256,224);
//Main CPU
main_z80:=cpu_z80.create(4000000,256);
//Sound CPU
snd_z80:=cpu_z80.create(3000000,256);
snd_z80.change_ram_calls(taitosj_snd_getbyte,taitosj_snd_putbyte);
snd_z80.init_sound(taitosj_sound_update);
//IRQ sonido
init_timer(snd_z80.numero_cpu,3000000/(6000000/(4*16*16*10*16)),taitosj_snd_irq,true);
//Sound Chip
ay8910_0:=ay8910_chip.create(1500000,1);
ay8910_0.change_io_calls(ay0_porta_read,ay0_portb_read,nil,nil);
ay8910_1:=ay8910_chip.create(1500000,1);
ay8910_1.change_io_calls(nil,nil,ay1_porta_write,ay1_portb_write);
ay8910_2:=ay8910_chip.create(1500000,1);
ay8910_2.change_io_calls(nil,nil,ay2_porta_write,nil);
ay8910_3:=ay8910_chip.create(1500000,1);
ay8910_3.change_io_calls(nil,nil,nil,ay3_portb_write);
dac_0:=dac_chip.create(32);
case main_vars.tipo_maquina of
  185:begin  //Elevator Action
        main_z80.change_ram_calls(taitosj_mcu_getbyte,taitosj_mcu_putbyte);
        //cargar roms
        if not(cargar_roms(@memoria_temp[0],@elevator_rom[0],'elevator.zip',0)) then exit;
        //Poner roms en sus bancos
        copymemory(@memoria[0],@memoria_temp[0],$6000);
        copymemory(@memoria_rom[0,0],@memoria_temp[$6000],$2000);
        copymemory(@memoria_rom[1,0],@memoria_temp[$6000],$1000);
        copymemory(@memoria_rom[1,$1000],@memoria_temp[$8000],$1000);
        //cargar roms sonido
        if not(cargar_roms(@mem_snd[0],@elevator_sonido[0],'elevator.zip',0)) then exit;
        //MCU CPU
        if not(cargar_roms(@mcu_mem[0],@elevator_mcu,'elevator.zip')) then exit;
        main_m6805:=cpu_m6805.create(3000000,$100,tipo_m68705);
        main_m6805.change_ram_calls(mcu_taitosj_getbyte,mcu_taitosj_putbyte);
        //cargar chars
        if not(cargar_roms(@gfx_rom[0],@elevator_char[0],'elevator.zip',0)) then exit;
        //crear gfx
        init_gfx(0,8,8,256);
        gfx[0].trans[0]:=true;
        init_gfx(1,16,16,64);
        gfx[1].trans[0]:=true;
        init_gfx(2,8,8,256);
        gfx[2].trans[0]:=true;
        init_gfx(3,16,16,64);
        gfx[3].trans[0]:=true;
        //Calculo de prioridades
        if not(cargar_roms(@memoria_temp[0],@elevator_prom,'elevator.zip')) then exit;
      end;
  189:begin //Jungle King
        main_z80.change_ram_calls(taitosj_nomcu_getbyte,taitosj_nomcu_putbyte);
        //cargar roms
        if not(cargar_roms(@memoria_temp[0],@junglek_rom[0],'junglek.zip',0)) then exit;
        //Poner roms en sus bancos
        copymemory(@memoria[0],@memoria_temp[0],$6000);
        copymemory(@memoria_rom[0,0],@memoria_temp[$6000],$2000);
        copymemory(@memoria_rom[1,0],@memoria_temp[$6000],$1000);
        copymemory(@memoria_rom[1,$1000],@memoria_temp[$8000],$1000);
        //cargar roms sonido
        if not(cargar_roms(@mem_snd[0],@junglek_sonido[0],'junglek.zip',0)) then exit;
        //cargar chars
        if not(cargar_roms(@gfx_rom[0],@junglek_char[0],'junglek.zip',0)) then exit;
        //crear gfx
        init_gfx(0,8,8,256);
        gfx[0].trans[0]:=true;
        init_gfx(1,16,16,64);
        gfx[1].trans[0]:=true;
        init_gfx(2,8,8,256);
        gfx[2].trans[0]:=true;
        init_gfx(3,16,16,64);
        gfx[3].trans[0]:=true;
        //Calculo de prioridades
        if not(cargar_roms(@memoria_temp[0],@junglek_prom,'junglek.zip')) then exit;
  end;
end;
for i:=0 to $1f do begin
		mask:=0;
    // start with all four layers active, so we'll get the highest
    // priority one in the first loop
		for j:=3 downto 0 do begin
			data:=memoria_temp[$10*(i and $0f)+mask] and $0f;
  		if (i and $10)<>0 then data:=data shr 2
  			else data:=data and $03;
      mask:=mask or (1 shl data);
      // in next loop, we'll see which of the remaining
      // layers has top priority when this one is transparent
	 		draw_order[i,j]:=data;
		end;
end;
//precalculo de la paleta
compute_resistor_weights(0,255,-1.0,
			3,@resistances[0],@rweights[0],0,0,
			3,@resistances[0],@gweights[0],0,0,
			3,@resistances[0],@bweights[0],0,0);
//final
taitosj_reset;
taitosj_iniciar:=true;
end;

procedure conv_chars1;inline;
begin
  gfx_set_desc_data(3,0,8*8,512*8*8,256*8*8,0);
  convert_gfx(0,0,@memoria[$9000],@pc_x[0],@pc_y[0],false,false);
  //sprites
  gfx_set_desc_data(3,0,32*8,128*16*16,64*16*16,0);
  convert_gfx(1,0,@memoria[$9000],@ps_x[0],@ps_y[0],false,false);
end;

procedure conv_chars2;inline;
begin
  //Chars 2
  gfx_set_desc_data(3,0,8*8,512*8*8,256*8*8,0);
  convert_gfx(2,0,@memoria[$a800],@pc_x[0],@pc_y[0],false,false);
  //sprites
  gfx_set_desc_data(3,0,32*8,128*16*16,64*16*16,0);
  convert_gfx(3,0,@memoria[$a800],@ps_x[0],@ps_y[0],false,false);
end;

procedure taitosj_cerrar;
begin
main_z80.free;
snd_z80.free;
if main_vars.tipo_maquina=185 then main_m6805.free;
ay8910_0.free;
ay8910_1.free;
ay8910_2.free;
ay8910_3.free;
dac_0.Free;
close_audio;
close_video;
end;

procedure taitosj_reset;
begin
main_z80.reset;
snd_z80.reset;
if main_vars.tipo_maquina=185 then main_m6805.reset;
ay8910_0.reset;
ay8910_1.reset;
ay8910_2.reset;
ay8910_3.reset;
dac_0.reset;
reset_audio;
marcade.in0:=$ff;
marcade.in1:=$ff;
marcade.in2:=$ff;
collision_reg[0]:=0;
collision_reg[1]:=0;
collision_reg[2]:=0;
collision_reg[3]:=0;
gfx_pos:=0;
video_priority:=0;
fillchar(scroll[0],6,0);
colorbank[0]:=0;
colorbank[1]:=0;
sndnmi_disable:=false;
rechars1:=false;
rechars2:=false;
rom_bank:=0;
video_mode:=0;
sprite_offset:=0;
dac_vol:=0;
input_port_4_f0:=0;
//mcu
mcu_zaccept:=1;
mcu_zready:=0;
mcu_busreq:=0;
end;

function get_sprite_xy(offs:word;sx,sy:pbyte):boolean;
begin
	sx^:=memoria[$d100+sprite_offset+offs+0]-1;
	sy^:=240-memoria[$d100+sprite_offset+offs+1];
	get_sprite_xy:=(sy^)<240;
end;

procedure taitosj_putsprites;
var
  f,sx,sy,nchar,which,atrib,ngfx:byte;
  offs,color:word;
  flip_x,flip_y:boolean;
begin
// drawing order is a bit strange. The last sprite has to be moved at the start of the list. */
for f:=$1f downto 0 do begin
  which:=(f-1) and $1f;    // move last sprite at the head of the list */
  offs:=which*4;
  if ((which>=$10) and (which<=$17)) then continue;   // no sprites here */
  if (get_sprite_xy(offs,@sx,@sy)) then begin
        atrib:=memoria[$d100+sprite_offset+offs+2];
				nchar:=memoria[$d100+sprite_offset+offs+3] and $3f;
        if (memoria[$d100+sprite_offset+offs+3] and $40)<>0 then ngfx:=3
          else ngfx:=1;
				color:= 2*((colorbank[1] shr 4) and $03) + ((atrib shr 2) and $01);
				flip_x:=(atrib and $01)<>0;
				flip_y:=(atrib and $02)<>0;
        put_gfx_sprite(nchar,color shl 3,flip_x,flip_y,ngfx);
        actualiza_gfx_sprite(sx,sy,4,ngfx);
  end;
end;
end;

procedure update_video_taitosj;inline;
var
  color_back,color_mid,color_front,gfx_back,gfx_mid,gfx_front,nchar,layer:byte;
  f,scr_y,x,y:word;
begin
if rechars1 then begin
  conv_chars1;
  rechars1:=false;
end;
if rechars2 then begin
  conv_chars2;
  rechars2:=false;
end;
color_back:=(colorbank[0] and $07) shl 3;
color_mid:=((colorbank[0] shr 4) and $07) shl 3;
color_front:=(colorbank[1] and $07) shl 3;
gfx_back:=(colorbank[0] and $08) shr 2;
gfx_mid:=(colorbank[0] and $80) shr 6;
gfx_front:=(colorbank[1] and $08) shr 2;
for f:=$0 to $3ff do begin
   //back
   x:=f mod 32;
   y:=f div 32;
   if (video_mode and $10)<>0 then begin
     if gfx_back_buf[f] then begin
      nchar:=memoria[$c400+f];
      put_gfx_trans(x*8,y*8,nchar,color_back,1,gfx_back);
      gfx_back_buf[f]:=false;
     end;
   end;
   //mid
   if (video_mode and $20)<>0 then begin
      if gfx_mid_buf[f] then begin
        nchar:=memoria[$c800+f];
        put_gfx_trans(x*8,y*8,nchar,color_mid,2,gfx_mid);
        gfx_mid_buf[f]:=false;
      end;
   end;
   //front
   if (video_mode and $20)<>0 then begin
      if gfx_front_buf[f] then begin
          nchar:=memoria[$cc00+f];
          put_gfx_trans(x*8,y*8,nchar,color_front,3,gfx_front);
          gfx_front_buf[f]:=false;
      end;
   end;
end;
fill_full_screen(4,(colorbank[1] and $07) shl 3);
for f:=0 to 3 do begin
  layer:=draw_order[video_priority and $1f,f];
  case layer of
    0:if (video_mode and $80)<>0 then begin
          if (video_mode and $4)<>0 then sprite_offset:=$80
            else sprite_offset:=$0;
          taitosj_putsprites;
      end;
    1:if (video_mode and $10)<>0 then begin
          x:=scroll[0];
          x:=(x and $f8)+((x+3) and 7)+8;
          for y:=0 to 31 do begin
            scr_y:=scroll_y[y]+scroll[1];
            scroll__y_part(1,4,scr_y,x,y*8,8);
          end;
      end;
    2:if (video_mode and $20)<>0 then begin
          x:=scroll[2];
          x:=(x and $f8)+((x+1) and 7)+10;
          for y:=0 to 31 do begin
            scr_y:=scroll_y[32+y]+scroll[3];
            scroll__y_part(2,4,scr_y,x,y*8,8);
          end;
      end;
    3:if (video_mode and $40)<>0 then begin
          x:=scroll[4];
          x:=(x and $f8)+((x-1) and 7)+12;
          for y:=0 to 31 do begin
            scr_y:=scroll_y[64+y]+scroll[5];
            scroll__y_part(3,4,scr_y,x,y*8,8);
          end;
      end;
  end;
end;
actualiza_trozo_final(0,16,256,224,4);
end;

procedure eventos_taitosj;
begin
if event.arcade then begin
  //p1
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  //p2
  {if arcade_input.right[1] then marcade.in1:=(marcade.in1 or 1) else marcade.in1:=(marcade.in1 and $fe);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 or 2) else marcade.in1:=(marcade.in1 and $fd);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 or 4) else marcade.in1:=(marcade.in1 and $fb);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 or 8) else marcade.in1:=(marcade.in1 and $f7);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 or $10) else marcade.in1:=(marcade.in1 and $ef);}
  //System
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 and $bf) else marcade.in2:=(marcade.in2 or $40);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 and $7f) else marcade.in2:=(marcade.in2 or $80);
end;
end;

procedure taitosj_nomcu_principal;
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
    //Sound
    snd_z80.run(frame_s);
    frame_s:=frame_s+snd_z80.tframes-snd_z80.contador;
    if f=239 then begin
      main_z80.pedir_irq:=HOLD_LINE;
      update_video_taitosj;
    end;
  end;
  eventos_taitosj;
  video_sync;
end;
end;

function taitosj_nomcu_getbyte(direccion:word):byte;
begin
case direccion of
  0..$5fff,$8000..$87ff,$c000..$cfff,$e000..$ffff:taitosj_nomcu_getbyte:=memoria[direccion];
  $6000..$7fff:taitosj_nomcu_getbyte:=memoria_rom[rom_bank,direccion and $1fff];
  $8800..$8fff:taitosj_nomcu_getbyte:=0;  //Fake MCU
  $d000..$d05f:taitosj_nomcu_getbyte:=scroll_y[direccion and $7f];
  $d200..$d2ff:taitosj_nomcu_getbyte:=buffer_paleta[direccion and $7f];
  $d400..$d4ff:case (direccion and $f) of
                  $0..$3:taitosj_nomcu_getbyte:=collision_reg[direccion and $f];
                  $4..$7:begin
                        if gfx_pos<$8000 then taitosj_nomcu_getbyte:=gfx_rom[gfx_pos]
                          else taitosj_nomcu_getbyte:=0;
                        gfx_pos:=gfx_pos+1;
                     end;
                  $8:taitosj_nomcu_getbyte:=marcade.in0;
                  $9:taitosj_nomcu_getbyte:=marcade.in1;
                  $a:taitosj_nomcu_getbyte:=$3f; //DSW1
                  $b:taitosj_nomcu_getbyte:=marcade.in2;
                  $c:taitosj_nomcu_getbyte:=$ef;
                  $d:taitosj_nomcu_getbyte:=$f+input_port_4_f0;
                  $f:taitosj_nomcu_getbyte:=ay8910_0.Read;
               end;
end;
end;

procedure cambiar_color(dir:word);inline;
var
  val,bit0,bit1,bit2:byte;
  color:tcolor;
begin
    dir:=dir and $fe;
    // blue component */
		val:=not(buffer_paleta[dir or 1]);
		bit0:=(val shr 0) and $01;
		bit1:=(val shr 1) and $01;
		bit2:=(val shr 2) and $01;
    color.b:=combine_3_weights(@bweights,bit0,bit1,bit2);
    // green component */
		bit0:=(val shr 3) and $01;
		bit1:=(val shr 4) and $01;
		bit2:=(val shr 5) and $01;
		color.g:=combine_3_weights(@gweights,bit0,bit1,bit2);
		// red component
		bit0:=(val shr 6) and $01;
		bit1:=(val shr 7) and $01;
		val:=not(buffer_paleta[dir]);
		bit2:=(val shr 0) and $01;
		color.r:=combine_3_weights(@rweights,bit0,bit1,bit2);
    set_pal_color(color,@paleta[dir shr 1]);
end;

procedure taitosj_nomcu_putbyte(direccion:word;valor:byte);
begin
if ((direccion<$8000) or (direccion>$d6ff)) then exit;
memoria[direccion]:=valor;
case direccion of
  $8800..$8fff:; //Fake MCU
	$9000..$a7ff:rechars1:=true;
  $a800..$bfff:rechars2:=true;
  $c400..$c7ff:gfx_back_buf[direccion and $3ff]:=true;
  $c800..$cbff:gfx_mid_buf[direccion and $3ff]:=true;
  $cc00..$cfff:gfx_front_buf[direccion and $3ff]:=true;
  $d000..$d05f:scroll_y[direccion and $7f]:=valor;
  $d200..$d2ff:begin
                  buffer_paleta[direccion and $7f]:=valor;
                  cambiar_color(direccion and $7f);
               end;
	$d300..$d3ff:video_priority:=valor;
  $d400..$d4ff:case (direccion and $f) of
      $e:ay8910_0.Control(valor);
      $f:ay8910_0.Write(valor);
  end;
  $d500..$d5ff:case (direccion and $f) of
      $0..$5:scroll[direccion and $f]:=valor;
	    $6,$7:colorbank[direccion and 1]:=valor;
      $8:begin
          collision_reg[0]:=0;
          collision_reg[1]:=0;
          collision_reg[2]:=0;
          collision_reg[3]:=0;
        end;
      $9:gfx_pos:=(gfx_pos and $ff00) or valor;
      $a:gfx_pos:=(gfx_pos and $ff) or (valor shl 8);
      $b:begin
            soundlatch:=valor;
	          if not(sndnmi_disable) then snd_z80.pedir_nmi:=PULSE_LINE;
         end;
      $e:rom_bank:=valor shr 7;
  end;
  $d600..$d6ff:video_mode:=valor;
end;
end;

procedure taitosj_mcu_principal;
var
  frame_m,frame_s,frame_mcu:single;
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
    //Sound
    snd_z80.run(frame_s);
    frame_s:=frame_s+snd_z80.tframes-snd_z80.contador;
    //mcu
    main_m6805.run(frame_mcu);
    frame_mcu:=frame_mcu+main_m6805.tframes-main_m6805.contador;
    if f=239 then begin
      main_z80.pedir_irq:=HOLD_LINE;
      update_video_taitosj;
    end;
  end;
  eventos_taitosj;
  video_sync;
end;
end;

function taitosj_mcu_getbyte(direccion:word):byte;
begin
case direccion of
  0..$5fff,$8000..$87ff,$c000..$cfff,$e000..$ffff:taitosj_mcu_getbyte:=memoria[direccion];
  $6000..$7fff:taitosj_mcu_getbyte:=memoria_rom[rom_bank,direccion and $1fff];
  $8800..$8fff:if (direccion and 1)=0 then begin
                  taitosj_mcu_getbyte:=mcu_toz80;
                  mcu_zaccept:=1;
               end else begin
                  taitosj_mcu_getbyte:= not((mcu_zready shl 0) or (mcu_zaccept shl 1));
               end;
  $d000..$d05f:taitosj_mcu_getbyte:=scroll_y[direccion and $7f];
  $d200..$d2ff:taitosj_mcu_getbyte:=buffer_paleta[direccion and $7f];
  $d400..$d4ff:case (direccion and $f) of
                  $0..$3:taitosj_mcu_getbyte:=collision_reg[direccion and $f];
                  $4..$7:begin
                        if gfx_pos<$8000 then taitosj_mcu_getbyte:=gfx_rom[gfx_pos]
                          else taitosj_mcu_getbyte:=0;
                        gfx_pos:=gfx_pos+1;
                     end;
                  $8:taitosj_mcu_getbyte:=marcade.in0;
                  $9:taitosj_mcu_getbyte:=marcade.in1;
                  $a:taitosj_mcu_getbyte:=$3f; //DSW1
                  $b:taitosj_mcu_getbyte:=marcade.in2;
                  $c:taitosj_mcu_getbyte:=$ef;
                  $d:taitosj_mcu_getbyte:=$f+input_port_4_f0;
                  $f:taitosj_mcu_getbyte:=ay8910_0.Read;
               end;
end;
end;

procedure taitosj_mcu_putbyte(direccion:word;valor:byte);
begin
if ((direccion<$8000) or (direccion>$d6ff)) then exit;
memoria[direccion]:=valor;
case direccion of
  $8800..$8fff:if (direccion and 1)=0 then begin
                  mcu_zready:=1;
	                main_m6805.irq_request(0,ASSERT_LINE);
	                mcu_fromz80:=valor;
               end;
	$9000..$a7ff:rechars1:=true;
  $a800..$bfff:rechars2:=true;
  $c400..$c7ff:gfx_back_buf[direccion and $3ff]:=true;
  $c800..$cbff:gfx_mid_buf[direccion and $3ff]:=true;
  $cc00..$cfff:gfx_front_buf[direccion and $3ff]:=true;
  $d000..$d05f:scroll_y[direccion and $7f]:=valor;
  $d200..$d2ff:begin
                  buffer_paleta[direccion and $7f]:=valor;
                  cambiar_color(direccion and $7f);
               end;
	$d300..$d3ff:video_priority:=valor;
  $d400..$d4ff:case (direccion and $f) of
      $e:ay8910_0.Control(valor);
      $f:ay8910_0.Write(valor);
  end;
  $d500..$d5ff:case (direccion and $f) of
      $0..$5:scroll[direccion and $f]:=valor;
	    $6,$7:colorbank[direccion and 1]:=valor;
      $8:begin
          collision_reg[0]:=0;
          collision_reg[1]:=0;
          collision_reg[2]:=0;
          collision_reg[3]:=0;
        end;
      $9:gfx_pos:=(gfx_pos and $ff00) or valor;
      $a:gfx_pos:=(gfx_pos and $00ff) or (valor shl 8);
      $b:begin
            soundlatch:=valor;
	          if not(sndnmi_disable) then snd_z80.pedir_nmi:=PULSE_LINE;
         end;
      $e:rom_bank:=valor shr 7;
  end;
  $d600..$d6ff:video_mode:=valor;
end;
end;

function mcu_taitosj_getbyte(direccion:word):byte;
begin
direccion:=direccion and $7ff;
case direccion of
  0:mcu_taitosj_getbyte:=mcu_portA_in;
  1:mcu_taitosj_getbyte:=$ff;
  2:mcu_taitosj_getbyte:=(mcu_zready shl 0) or (mcu_zaccept shl 1) or ((mcu_busreq xor 1) shl 2);
  3..$7ff:mcu_taitosj_getbyte:=mcu_mem[direccion];
end;
end;

procedure mcu_taitosj_putbyte(direccion:word;valor:byte);
begin
direccion:=direccion and $7ff;
case direccion of
  0:mcu_portA_out:=valor;
  1:begin
      if (not(valor) and $01)<>0 then exit;
	    if (not(valor) and $02)<>0 then begin
    		// 68705 is going to read data from the Z80 */
        mcu_zready:=0;
        main_m6805.irq_request(0,CLEAR_LINE);
		    mcu_portA_in:=mcu_fromz80;
	    end;
	    if (not(valor) and $08)<>0 then mcu_busreq:=1 else mcu_busreq:=0;
	    if (not(valor) and $04)<>0 then begin
		    // 68705 is writing data for the Z80 */
        mcu_toz80:=mcu_portA_out;
	      mcu_zaccept:=0;
	    end;
	    if (not(valor) and $10)<>0 then begin
		    memoria[mcu_address]:=mcu_portA_out;
		    // increase low 8 bits of latched address for burst writes */
		    mcu_address:= (mcu_address and $ff00) or ((mcu_address+1) and $ff);
	    end;
	    if (not(valor) and $20)<>0 then mcu_portA_in:=memoria[mcu_address];
	    if (not(valor) and $40)<>0 then mcu_address:=(mcu_address and $ff00) or mcu_portA_out;
	    if (not(valor) and $80)<>0 then mcu_address:=(mcu_address and $00ff) or (mcu_portA_out shl 8);
    end;
  2:;
  3..$7f:mcu_mem[direccion]:=valor;
end;
end;

function taitosj_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$43ff:taitosj_snd_getbyte:=mem_snd[direccion];
  $4801:taitosj_snd_getbyte:=ay8910_1.Read;
  $4803:taitosj_snd_getbyte:=ay8910_2.Read;
  $4805:taitosj_snd_getbyte:=ay8910_3.Read;
  $5000:taitosj_snd_getbyte:=soundlatch;
end;
end;

procedure taitosj_snd_putbyte(direccion:word;valor:byte);
begin
if (direccion<$4000) then exit;
mem_snd[direccion]:=valor;
case direccion of
  $4800:ay8910_1.Control(valor);
  $4801:ay8910_1.Write(valor);
  $4802:ay8910_2.Control(valor);
  $4803:ay8910_2.Write(valor);
  $4804:ay8910_3.Control(valor);
  $4805:ay8910_3.Write(valor);
end;
end;

function ay0_porta_read:byte;
begin
  ay0_porta_read:=0; //DSW2
end;

function ay0_portb_read:byte;
begin
  ay0_portb_read:=$ff; //DSW3
end;

procedure ay1_porta_write(valor:byte);
begin
dac_out:=valor-$80;
dac_0.signed_data16_w(dac_out*dac_vol+$8000);
end;

procedure ay1_portb_write(valor:byte);
begin
dac_vol:=voltable[valor];
dac_0.signed_data16_w(dac_out*dac_vol+$8000);
end;

procedure ay2_porta_write(valor:byte);
begin
  input_port_4_f0:=valor and $f0;
end;

procedure ay3_portb_write(valor:byte);
begin
  sndnmi_disable:=(valor and $01)<>0;
end;

procedure taitosj_snd_irq;
begin
  snd_z80.pedir_irq:=HOLD_LINE;
end;

procedure taitosj_sound_update;
begin
  ay8910_0.update;
  ay8910_1.update;
  ay8910_2.update;
  ay8910_3.update;
  dac_0.update;
end;

end.
