unit legendkage_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,m6805,main_engine,controls_engine,gfx_engine,ym_2203,
     rom_engine,pal_engine,sound_engine;

procedure cargar_lk_hw;

implementation
const
        lk_rom:array[0..2] of tipo_roms=(
        (n:'a54-01-2.37';l:$8000;p:0;crc:$60fd9734),(n:'a54-02-2.38';l:$8000;p:$8000;crc:$878a25ce),());
        lk_snd:tipo_roms=(n:'a54-04.54';l:$8000;p:0;crc:$541faf9a);
        lk_mcu:tipo_roms=(n:'a54-09.53';l:$800;p:0;crc:$0e8b8846);
        lk_data:tipo_roms=(n:'a54-03.51';l:$4000;p:0;crc:$493e76d8);
        lk_char:array[0..4] of tipo_roms=(
        (n:'a54-05-1.84';l:$4000;p:0;crc:$0033c06a),(n:'a54-06-1.85';l:$4000;p:$4000;crc:$9f04d9ad),
        (n:'a54-07-1.86';l:$4000;p:$8000;crc:$b20561a4),(n:'a54-08-1.87';l:$4000;p:$c000;crc:$3ff3b230),());

var
 scroll_txt_x,scroll_txt_y,scroll_fg_x,scroll_fg_y,scroll_bg_x,scroll_bg_y:byte;
 mem_data:array[0..$3fff] of byte;
 sound_cmd,color_bnk,tipo_pant:byte;
 bg_bank,fg_bank:word;
 snd_nmi,pending_nmi,prioridad_fg:boolean;
 //mcu
 mcu_mem:array[0..$7ff] of byte;
 port_c_in,port_c_out,port_b_out,port_b_in,port_a_in,port_a_out:byte;
 ddr_a,ddr_b,ddr_c:byte;
 mcu_sent,from_main,main_sent,from_mcu:byte;

procedure draw_sprites(prio:byte);inline;
var
  f,x,y,nchar:word;
  atrib,color:byte;
  flipx,flipy:boolean;
begin
	for f:=0 to $17 do begin
		atrib:=memoria[$f102+(f*4)];
    if (atrib and $80)=prio then begin
  		// 0x01: horizontal flip
      // 0x02: vertical flip
      // 0x04: bank select
      // 0x08: sprite size
      // 0x70: color
      // 0x80: priority
  		color:=atrib and $70;
  		flipx:=(atrib and $1)<>0;
  		flipy:=(atrib and $2)<>0;
  		x:=memoria[$f100+(f*4)]-15;
  		y:=240-memoria[$f101+(f*4)];
  		nchar:=memoria[$f103+(f*4)]+((atrib and $04) shl 6);
      if (atrib and $08)<>0 then begin  //x2
        if not(flipy) then nchar:=nchar xor 1;
        put_gfx_sprite_diff(nchar xor 0,color,flipx,flipy,1,0,0);
        put_gfx_sprite_diff(nchar xor 1,color,flipx,flipy,1,0,16);
        actualiza_gfx_sprite_size(x,y-16,4,16,32);
      end else begin //x1
        put_gfx_sprite(nchar,color,flipx,flipy,1);
        actualiza_gfx_sprite(x,y,4,1);
      end;
    end;
	end;
end;

procedure update_video_lk_hw;inline;
var
  f,x,y:word;
  nchar:word;
begin
if (tipo_pant)=$f0 then begin
  for f:=0 to $3ff do begin
    //BG
    if gfx[0].buffer[$400+f] then begin
      x:=f mod 32;
      y:=f div 32;
      nchar:=memoria[$fc00+f]+bg_bank;
      put_gfx(x*8,y*8,nchar,$300+color_bnk,2,0);
      gfx[0].buffer[$400+f]:=false;
    end;
    //FG
    if gfx[0].buffer[$800+f] then begin
      x:=f mod 32;
      y:=f div 32;
      nchar:=memoria[$f800+f]+fg_bank;
      put_gfx_trans(x*8,y*8,nchar,$200+color_bnk,3,0);
      gfx[0].buffer[$800+f]:=false;
    end;
    //TXT
    if gfx[0].buffer[f] then begin
      x:=f mod 32;
      y:=f div 32;
      nchar:=memoria[$f400+f];
      put_gfx_trans(x*8,y*8,nchar,$110,1,0);
      gfx[0].buffer[f]:=false;
    end;
  end;
  scroll_x_y(2,4,scroll_bg_x,scroll_bg_y);
  if prioridad_fg then begin
    scroll_x_y(3,4,scroll_fg_x,scroll_fg_y);
    draw_sprites(0);
  end else begin
    draw_sprites(0);
    scroll_x_y(3,4,scroll_fg_x,scroll_fg_y);
  end;
end else begin
  for f:=0 to $3ff do begin
    if gfx[0].buffer[f] then begin
      x:=f mod 32;
      y:=f div 32;
      nchar:=memoria[$f400+f];
      put_gfx(x*8,y*8,nchar,$110,1,0);
      gfx[0].buffer[f]:=false;
    end;
  end;
end;
draw_sprites($80);
scroll_x_y(1,4,scroll_txt_x,scroll_txt_y);
actualiza_trozo_final(16,16,240,224,4);
end;

procedure eventos_lk_hw;
begin
if event.arcade then begin
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $Fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $F7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
end;
end;

procedure lk_hw_principal;
var
  frame_m,frame_s,frame_mcu:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=main_z80.tframes;
frame_s:=snd_z80.tframes;
frame_mcu:=main_m6805.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
    //Main CPU
    main_z80.run(frame_m);
    frame_m:=frame_m+main_z80.tframes-main_z80.contador;
    //Sound CPU
    snd_z80.run(frame_s);
    frame_s:=frame_s+snd_z80.tframes-snd_z80.contador;
    //MCU CPU
    main_m6805.run(frame_mcu);
    frame_mcu:=frame_mcu+main_m6805.tframes-main_m6805.contador;
    if f=239 then begin
      main_z80.change_irq(HOLD_LINE);
      update_video_lk_hw;
    end;
  end;
  eventos_lk_hw;
  video_sync;
end;
end;

function lkage_mcu_status_r:byte;
var
  res:byte;
begin
	res:=0;
	// bit 0 = when 1, mcu is ready to receive data from main cpu */
	// bit 1 = when 1, mcu has sent data to the main cpu */
	if (main_sent=0) then res:=res or $01;
	if (mcu_sent<>0) then res:=res or $02;
  lkage_mcu_status_r:=res;
end;

function lk_getbyte(direccion:word):byte;
begin
case direccion of
  $f062:begin
          mcu_sent:=0;
	        lk_getbyte:=from_mcu;
        end;
  $f080:lk_getbyte:=$7f;
  $f081:lk_getbyte:=$00;
  $f082:lk_getbyte:=$ff;
  $f083:lk_getbyte:=marcade.in0;
  $f084:lk_getbyte:=marcade.in1;
  $f086:lk_getbyte:=$ff;
  $f087:lk_getbyte:=lkage_mcu_status_r;
  else lk_getbyte:=memoria[direccion];
end;
end;

procedure cambiar_color(pos:word);inline;
var
  tmp_color:byte;
  color:tcolor;
begin
  tmp_color:=buffer_paleta[pos+1];
  color.r:=pal4bit(tmp_color);
  tmp_color:=buffer_paleta[pos];
  color.g:=pal4bit(tmp_color shr 4);
  color.b:=pal4bit(tmp_color);
  pos:=pos shr 1;
  set_pal_color(color,pos);
  case pos of
    $110..$11f:fillchar(gfx[0].buffer[0],$400,1);
    $200..$2ff:fillchar(gfx[0].buffer[$800],$400,1);
    $300..$3ff:fillchar(gfx[0].buffer[$400],$400,1);
  end;
end;

procedure lk_putbyte(direccion:word;valor:byte);
var
  bank:word;
begin
if direccion<$e000 then exit;
memoria[direccion]:=valor;
case direccion of
  $e800..$efff:if buffer_paleta[direccion and $7ff]<>valor then begin
                  buffer_paleta[direccion and $7ff]:=valor;
                  cambiar_color(direccion and $7fe);
               end;
  $f000:begin
          if (valor and $4)<>0 then bank:=$100
            else bank:=0;
          if fg_bank<>bank then begin
            fg_bank:=bank;
            fillchar(gfx[0].buffer[$800],$400,1);
          end;
        end;
  $f001:begin
          prioridad_fg:=(valor and $2)<>0;
          if (valor and $8)<>0 then bank:=$100*5
            else bank:=$100*1;
          if bg_bank<>bank then begin
            bg_bank:=bank;
            fillchar(gfx[0].buffer[$400],$400,1);
          end;
          if color_bnk<>(valor and $f0) then begin
            color_bnk:=valor and $f0;
            fillchar(gfx[0].buffer[$400],$800,1);
          end;
        end;
  $f002:if tipo_pant<>(valor and $f0) then begin
            tipo_pant:=valor and $f0;
            fillchar(gfx[0].buffer[0],$c00,1);
          end;
  $f060:begin
          if snd_nmi then snd_z80.change_nmi(PULSE_LINE)
            else pending_nmi:=true;
          sound_cmd:=valor;
        end;
  $f062:begin
          from_main:=valor;
	        main_sent:=1;
          main_m6805.irq_request(0,ASSERT_LINE);
        end;
  $f0c0:scroll_txt_x:=valor+1;
  $f0c1:scroll_txt_y:=valor;
  $f0c2:scroll_fg_x:=valor+3;
  $f0c3:scroll_fg_y:=valor;
  $f0c4:scroll_bg_x:=valor+5;
  $f0c5:scroll_bg_y:=valor;
  $f400..$f7ff:gfx[0].buffer[direccion and $3ff]:=true;
  $f800..$fbff:gfx[0].buffer[$800+(direccion and $3ff)]:=true;
  $fc00..$ffff:gfx[0].buffer[$400+(direccion and $3ff)]:=true;
end;
end;

function lk_inbyte(puerto:word):byte;
begin
  case puerto of
    $4000..$7fff:lk_inbyte:=mem_data[puerto and $3fff];
  end;
end;

//Sound
function snd_lk_hw_getbyte(direccion:word):byte;
begin
case direccion of
  $9000:snd_lk_hw_getbyte:=ym2203_0.status;
  $9001:snd_lk_hw_getbyte:=ym2203_0.read;
  $a000:snd_lk_hw_getbyte:=ym2203_1.status;
  $a001:snd_lk_hw_getbyte:=ym2203_1.read;
  $b000:snd_lk_hw_getbyte:=sound_cmd;
    else snd_lk_hw_getbyte:=mem_snd[direccion];
end;
end;

procedure snd_lk_hw_putbyte(direccion:word;valor:byte);
begin
if (direccion<$8000) then exit;
mem_snd[direccion]:=valor;
case direccion of
  $9000:ym2203_0.control(valor);
  $9001:ym2203_0.write(valor);
  $a000:ym2203_1.control(valor);
  $a001:ym2203_1.write(valor);
  $b001:begin
          snd_nmi:=true;
          if pending_nmi then begin
              pending_nmi:=false;
              snd_z80.change_nmi(PULSE_LINE);
          end;
        end;
  $b002:snd_nmi:=false;
end;
end;

function mcu_lk_hw_getbyte(direccion:word):byte;
begin
direccion:=direccion and $7ff;
case direccion of
  0:mcu_lk_hw_getbyte:=(port_a_out and ddr_a) or (port_a_in and not(ddr_a));
	1:mcu_lk_hw_getbyte:=(port_b_out and ddr_b) or (port_b_in and not(ddr_b));
	2:begin
      port_c_in:=0;
    	if (main_sent<>0) then port_c_in:=port_c_in or $01;
    	if (mcu_sent=0) then port_c_in:=port_c_in or $02;
    	mcu_lk_hw_getbyte:=(port_c_out and ddr_c) or (port_c_in and not(ddr_c));
    end;
  else mcu_lk_hw_getbyte:=mcu_mem[direccion];
end;
end;

procedure mcu_lk_hw_putbyte(direccion:word;valor:byte);
begin
direccion:=direccion and $7ff;
if direccion>$7f then exit;
mcu_mem[direccion]:=valor;
case direccion of
  0:port_a_out:=valor;
	1:begin
      if (((ddr_b and $02)<>0) and ((not(valor) and $02)<>0) and ((port_b_out and $02)<>0)) then begin
    		port_a_in:=from_main;
    		if (main_sent<>0) then main_m6805.irq_request(0,CLEAR_LINE);
    		main_sent:=0;
    	end;
    	if (((ddr_b and $04)<>0) and ((valor and $04)<>0) and ((not(port_b_out) and $04)<>0)) then begin
    		from_mcu:=port_a_out;
    		mcu_sent:=1;
    	end;
    	port_b_out:=valor;
    end;
	2:port_c_out:=valor;
	4:ddr_a:=valor;
	5:ddr_b:=valor;
	6:ddr_c:=valor;
end;
end;

procedure snd_irq(irqstate:byte);
begin
  snd_z80.change_irq(irqstate);
end;

procedure lk_hw_sound_update;
begin
  ym2203_0.Update;
  ym2203_1.Update;
end;

//Main
procedure reset_lk_hw;
begin
 main_z80.reset;
 snd_z80.reset;
 main_m6805.reset;
 ym2203_0.reset;
 ym2203_1.reset;
 reset_audio;
 scroll_txt_x:=0;
 scroll_fg_x:=0;
 scroll_bg_x:=0;
 scroll_txt_y:=0;
 scroll_fg_y:=0;
 scroll_bg_y:=0;
 marcade.in0:=$0b;
 marcade.in1:=$ff;
 snd_nmi:=false;
 pending_nmi:=false;
 sound_cmd:=0;
 color_bnk:=0;
 tipo_pant:=$f0;
 bg_bank:=0;
 fg_bank:=0;
 prioridad_fg:=false;
 //mcu
 port_a_in:=0;
 port_a_out:=0;
 ddr_a:=0;
 port_b_in:=0;
 port_b_out:=0;
 ddr_b:=0;
 port_c_in:=0;
 port_c_out:=0;
 ddr_c:=0;
 mcu_sent:=0;
 main_sent:=0;
 from_main:=0;
 from_mcu:=0;
end;

function iniciar_lk_hw:boolean;
var
  memoria_temp:array[0..$ffff] of byte;
const
  pc_x:array[0..7] of dword=(7, 6, 5, 4, 3, 2, 1, 0);
  pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
  ps_x:array[0..15] of dword=(7, 6, 5, 4, 3, 2, 1, 0,
    64+7, 64+6, 64+5, 64+4, 64+3, 64+2, 64+1, 64+0);
  ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
    128+0*8, 128+1*8, 128+2*8, 128+3*8, 128+4*8, 128+5*8, 128+6*8, 128+7*8);
begin
iniciar_lk_hw:=false;
iniciar_audio(false);
screen_init(1,256,256,true);
screen_mod_scroll(1,256,256,255,256,256,255);
screen_init(2,256,256);
screen_mod_scroll(2,256,256,255,256,256,255);
screen_init(3,256,256,true);
screen_mod_scroll(3,256,256,255,256,256,255);
screen_init(4,256,256,false,true);
iniciar_video(240,224);
//Main CPU
main_z80:=cpu_z80.create(6000000,$100);
main_z80.change_ram_calls(lk_getbyte,lk_putbyte);
main_z80.change_io_calls(lk_inbyte,nil);
//Sound CPU
snd_z80:=cpu_z80.create(4000000,$100);
snd_z80.change_ram_calls(snd_lk_hw_getbyte,snd_lk_hw_putbyte);
snd_z80.init_sound(lk_hw_sound_update);
//MCU CPU
main_m6805:=cpu_m6805.create(3000000,$100,tipo_m68705);
main_m6805.change_ram_calls(mcu_lk_hw_getbyte,mcu_lk_hw_putbyte);
//Sound Chips
ym2203_0:=ym2203_chip.create(4000000);
ym2203_0.change_irq_calls(snd_irq);
ym2203_1:=ym2203_chip.create(4000000);
//cargar roms
if not(cargar_roms(@memoria[0],@lk_rom[0],'lkage.zip',0)) then exit;
//cargar roms snd
if not(cargar_roms(@mem_snd[0],@lk_snd,'lkage.zip')) then exit;
//cargar roms mcu
if not(cargar_roms(@mcu_mem[0],@lk_mcu,'lkage.zip')) then exit;
//cargar data
if not(cargar_roms(@mem_data[0],@lk_data,'lkage.zip')) then exit;
//convertir chars
if not(cargar_roms(@memoria_temp[0],@lk_char[0],'lkage.zip',0)) then exit;
init_gfx(0,8,8,$800);
gfx[0].trans[0]:=true;
gfx_set_desc_data(4,0,8*8,$800*8*8*1,$800*8*8*0,$800*8*8*3,$800*8*8*2);
convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,false);
//convertir sprites
init_gfx(1,16,16,$200);
gfx[1].trans[0]:=true;
gfx_set_desc_data(4,0,32*8,$200*32*8*1,$200*32*8*0,$200*32*8*3,$200*32*8*2);
convert_gfx(1,0,@memoria_temp[0],@ps_x[0],@ps_y[0],false,false);
reset_lk_hw;
iniciar_lk_hw:=true;
end;

procedure Cargar_lk_hw;
begin
llamadas_maquina.iniciar:=iniciar_lk_hw;
llamadas_maquina.bucle_general:=lk_hw_principal;
llamadas_maquina.reset:=reset_lk_hw;
end;

end.
