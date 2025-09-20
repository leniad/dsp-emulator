unit toaplan1_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,m68000,main_engine,controls_engine,gfx_engine,rom_engine,ym_3812,
     pal_engine,sound_engine;

function iniciar_toaplan1:boolean;

implementation
const
        //Hellfire
        hellfire_rom:array[0..1] of tipo_roms=(
        (n:'b90_14.0';l:$20000;p:0;crc:$101df9f5),(n:'b90_15.1';l:$20000;p:$1;crc:$e67fd452));
        hellfire_sound:tipo_roms=(n:'b90_03.2';l:$8000;p:0;crc:$4058fa67);
        hellfire_char:array[0..3] of tipo_roms=(
        (n:'b90_04.3';l:$20000;p:0;crc:$ea6150fc),(n:'b90_05.4';l:$20000;p:$1;crc:$bb52c507),
        (n:'b90_06.5';l:$20000;p:$40000;crc:$cf5b0252),(n:'b90_07.6';l:$20000;p:$40001;crc:$b98af263));
        hellfire_sprite:array[0..3] of tipo_roms=(
        (n:'b90_11.10';l:$20000;p:0;crc:$c33e543c),(n:'b90_10.9';l:$20000;p:$1;crc:$35fd1092),
        (n:'b90_09.8';l:$20000;p:$40000;crc:$cf01009e),(n:'b90_08.7';l:$20000;p:$40001;crc:$3404a5e3));

var
 rom:array[0..$1ffff] of word;
 ram:array[0..$3fff] of word;
 vblank:byte;
 pf_voffset,spriteram_offs,x_offset,y_offset:word;
 tilevram:array[0..3,0..$1fff] of word;
 x_scroll,y_scroll:array[0..3] of word;
 sprite_ram:array[0..$3ff] of word;
 sprite_ram_size:array[0..$3f] of word;
 int_enable:boolean;

procedure update_video_toaplan1;
var
  f,nchar,atrib,color:word;
  x,y,h,prio:byte;
begin
for f:=0 to $fff do begin
    x:=f mod 64;
    y:=f div 64;
    //Primero todo sin transparencias
    atrib:=tilevram[0,f*2];
    color:=atrib and $3f;
    nchar:=tilevram[0,(f*2)+1] and $3fff;
    color:=color shl 4;
    put_gfx(x*8,y*8,nchar,color,1,0);
end;
scroll_x_y(1,18,x_scroll[0]+x_offset+$138,y_scroll[0]+y_offset+$f);
//resto
for f:=1 to 17 do fill_full_screen(f,MAX_COLORES);
for h:=3 downto 0 do begin
    for f:=0 to $fff do begin
        x:=f mod 64;
        y:=f div 64;
        atrib:=tilevram[h,f*2];
        prio:=(atrib shr 12);
        color:=atrib and $3f;
        nchar:=tilevram[h,(f*2)+1] and $3fff;
        color:=color shl 4;
        put_gfx_trans(x*8,y*8,nchar,color,prio+1,0);
    end;
    for f:=1 to 16 do scroll_x_y(f,18,x_scroll[h]+x_offset+$138,y_scroll[h]+y_offset+$f);
end;
//for f:=1 to 16 do actualiza_trozo(0,0,512,512,f,0,0,512,512,17);
actualiza_trozo_final(0,0,320,240,18);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
//copymemory(@buffer_sprites_w[0],@ram_sprites[0],$1000*2);
end;

procedure eventos_toaplan1;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fffe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fffd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fffb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fff7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ffef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $ffdf) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.but2[0] then marcade.in0:=(marcade.in0 and $ffbf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $feff) else marcade.in0:=(marcade.in0 or $100);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $fdff) else marcade.in0:=(marcade.in0 or $200);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fbff) else marcade.in0:=(marcade.in0 or $400);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $f7ff) else marcade.in0:=(marcade.in0 or $800);
  //P2
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $fffe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $fffd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fffb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $fff7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $ffef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $ffdf) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.but2[1] then marcade.in1:=(marcade.in1 and $ffbf) else marcade.in1:=(marcade.in1 or $40);
end;
end;

procedure toaplan1_principal;
var
  frame_m,frame_s:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
frame_s:=z80_0.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to 269 do begin
    //main
    m68000_0.run(frame_m);
    frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
    //sound
    z80_0.run(frame_s);
    frame_s:=frame_s+z80_0.tframes-z80_0.contador;
    case f of
    0:vblank:=0;
    255:begin
          if int_enable then m68000_0.irq[4]:=HOLD_LINE;
          update_video_toaplan1;
          vblank:=1;
        end;
    end;
 end;
 eventos_toaplan1;
 video_sync;
end;
end;

function toaplan1_getword(direccion:dword):word;
var
  layer:byte;
  offset,vram_offset:word;
begin
case direccion of
    0..$3ffff:toaplan1_getword:=rom[direccion shr 1];
    $40000..$47fff:toaplan1_getword:=ram[(direccion and $7fff) shr 1];
    $80000,$140000:toaplan1_getword:=vblank;
    $84000..$847ff:toaplan1_getword:=buffer_paleta[(direccion and $7ff) shr 1];
    $86000..$867ff:toaplan1_getword:=buffer_paleta[((direccion and $7ff) shr 1)+$400];
    $c0000..$c0fff:toaplan1_getword:=mem_snd[$8000+((direccion and $fff) shr 1)];
    $100002:toaplan1_getword:=pf_voffset;
    $100004..$100006:begin
              layer:=pf_voffset shr 12;
              offset:=pf_voffset and $fff;
              vram_offset:=((offset*2)+((direccion shr 1) and 1)) and $1fff;
				      toaplan1_getword:=tilevram[layer][vram_offset];
            end;
    $100010..$10001f:begin
                      offset:=((direccion and $f) shr 1);
                      case offset of
                        0,2,4,6:toaplan1_getword:=x_scroll[offset shr 1];
                        1,3,5,7:toaplan1_getword:=y_scroll[offset shr 1];
                      end;
                   end;
    $140002:toaplan1_getword:=spriteram_offs;
    $140004:toaplan1_getword:=sprite_ram[(spriteram_offs and $7ff) shr 1];
    $140006:toaplan1_getword:=sprite_ram_size[(spriteram_offs and $7f) shr 1];
end;
end;

procedure cambiar_color(pos,data:word);
var
  color:tcolor;
begin
  color.b:=pal5bit(data shr 10);
  color.g:=pal5bit(data shr 5);
  color.r:=pal5bit(data);
  set_pal_color(color,pos);
  case pos of
    0..$1ff:buffer_color[pos shr 4]:=true;//chars
    $400..$5ff:buffer_color[((pos and $1ff) shr 4)+$20]:=true; //fg
    $600..$7ff:buffer_color[((pos and $1ff) shr 4)+$40]:=true; //bg
  end;
end;

procedure toaplan1_putword(direccion:dword;valor:word);
var
  layer:byte;
  offset,vram_offset:word;
begin
case direccion of
    0..$3ffff:;
    $40000..$47fff:ram[(direccion and $7fff) shr 1]:=valor;
    $80002:int_enable:=(valor and 1)<>0;
    $80008..$8000f:; //bcu_control_w
    $84000..$847ff:begin
                      buffer_paleta[(direccion and $7ff) shr 1]:=valor;
                      cambiar_color((direccion and $7ff) shr 1,valor);
                   end;
    $86000..$867ff:begin
                      buffer_paleta[((direccion and $7ff) shr 1)+$400]:=valor;
                      cambiar_color(((direccion and $7ff) shr 1)+$400,valor);
                   end;
    $c0000..$c0fff:mem_snd[$8000+((direccion and $fff) shr 1)]:=valor and $ff;
    $100000:;  //bcu_flipscreen_w
    $100002:pf_voffset:=valor;
    $100004..$100006:begin
              layer:=pf_voffset shr 12;
              offset:=pf_voffset and $fff;
              vram_offset:=((offset*2)+((direccion shr 1) and 1)) and $1fff;
				      tilevram[layer][vram_offset]:=valor;
            end;
    $100010..$10001f:begin
                      offset:=((direccion and $f) shr 1);
                      case offset of
                        0,2,4,6:x_scroll[offset shr 1]:=valor shr 7;
                        1,3,5,7:y_scroll[offset shr 1]:=valor shr 7;
                      end;
                   end;
    $140002:spriteram_offs:=valor;
    $140004:sprite_ram[(spriteram_offs and $7ff) shr 1]:=valor;
    $140006:sprite_ram_size[(spriteram_offs and $7f) shr 1]:=valor;
    $180000..$180003:if (direccion and 1)<>0 then y_offset:=valor
                      else x_offset:=valor;
    $180006:; //fcu_flipscreen_w
    $180008:if valor=0 then begin
              z80_0.change_reset(PULSE_LINE);
              YM3812_0.reset;
            end;
end;
end;

//Sound
function toaplan1_snd_getbyte(direccion:word):byte;
begin
   toaplan1_snd_getbyte:=mem_snd[direccion];
end;

procedure toaplan1_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:;
  $8000..$87ff:mem_snd[direccion]:=valor;
end;
end;

function toaplan1_snd_in(puerto:word):byte;
begin
case (puerto and $ff) of
  $0,$10,$40,$50,$60:toaplan1_snd_in:=0;
  $20:toaplan1_snd_in:=2;
  $70:toaplan1_snd_in:=ym3812_0.status;
  $71:toaplan1_snd_in:=ym3812_0.read;
end;
end;

procedure toaplan1_snd_out(puerto:word;valor:byte);
begin
case (puerto and $ff) of
  $30:; //coin_w
  $70:ym3812_0.control(valor);
  $71:ym3812_0.write(valor);
end;
end;

procedure toaplan1_snd_irq(irqstate:byte);
begin
  if irqstate=0 then z80_0.change_irq(CLEAR_LINE)
    else z80_0.change_irq(ASSERT_LINE);
end;

procedure cclimb2_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$bfff:;
  $c000..$ffff:mem_snd[direccion]:=valor;
end;
end;

procedure toaplan1_sound_update;
begin
  ym3812_0.update;
end;

//Main
procedure reset_toaplan1;
begin
 m68000_0.reset;
 z80_0.reset;
 YM3812_0.reset;
 reset_audio;
 marcade.in0:=$ffff;
 marcade.in1:=$ffff;
 vblank:=0;
 pf_voffset:=0;
 x_offset:=0;
 y_offset:=0;
end;

function iniciar_toaplan1:boolean;
var
  memoria_temp:array[0..$7ffff] of byte;
  f:byte;
const
  pf_x:array[0..7] of dword=(0, 1, 2, 3, 4, 5, 6, 7);
  pf_y:array[0..7] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16);

procedure conv_chars(num:word);
begin
init_gfx(0,8,8,num);
gfx[0].trans[0]:=true;
gfx_set_desc_data(4,0,16*8,num*16*8+8,num*16*8+0,8,0);
convert_gfx(0,0,@memoria_temp,@pf_x,@pf_y,false,false);
end;

procedure conv_tiles(num:word;ngfx:byte);
begin
init_gfx(ngfx,16,16,num);
gfx[ngfx].trans[15]:=true;
gfx_set_desc_data(4,0,128*8,0,1,2,3);
convert_gfx(ngfx,0,@memoria_temp,@pf_x,@pf_y,false,false);
end;

procedure conv_sprites(num:word);
begin
init_gfx(3,16,16,num);
gfx_set_desc_data(4,0,64*8,0,1,2,3);
{case main_vars.tipo_maquina of
  275,277:convert_gfx(3,0,@memoria_temp,@ps_x,@ps_y,false,false);
  276,278:convert_gfx(3,0,@memoria_temp,@ps_x_terraf,@ps_y,false,false)
end;}
end;
begin
iniciar_toaplan1:=false;
llamadas_maquina.bucle_general:=toaplan1_principal;
llamadas_maquina.reset:=reset_toaplan1;
llamadas_maquina.fps_max:=57.613171;
iniciar_audio(false);
//Pantallas
for f:=1 to 17 do begin
  screen_init(f,512,512,true);
  screen_mod_scroll(f,512,512,511,512,512,511);
end;
screen_init(18,512,512,false,true);
//if ((main_vars.tipo_maquina=275) or (main_vars.tipo_maquina=278)) then main_screen.rol90_screen:=true;
iniciar_video(320,240);
//iniciar_video(512,512);
//Main CPU
m68000_0:=cpu_m68000.create(10000000,270);
//Sound CPU
z80_0:=cpu_z80.create(3500000,270);
z80_0.change_ram_calls(toaplan1_snd_getbyte,toaplan1_snd_putbyte);
z80_0.change_io_calls(toaplan1_snd_in,toaplan1_snd_out);
z80_0.init_sound(toaplan1_sound_update);
//Sound Chips
ym3812_0:=ym3812_chip.create(YM3812_FM,3500000);
ym3812_0.change_irq_calls(toaplan1_snd_irq);
case main_vars.tipo_maquina of
  298:begin //Hellfire
            m68000_0.change_ram16_calls(toaplan1_getword,toaplan1_putword);
            //cargar roms
            if not(roms_load16w(@rom,hellfire_rom)) then exit;
            //cargar sonido
            if not(roms_load(@mem_snd,hellfire_sound)) then exit;
            //convertir chars
            if not(roms_load16b(@memoria_temp,hellfire_char)) then exit;
            conv_chars($4000);
            //convertir bg
            //if not(roms_load(@memoria_temp,hellfire_bg)) then exit;
            //conv_tiles($400,1);
            //DIP
            marcade.dswa:=$ffdf;
            marcade.dswb:=$ffcf;
  end;
end;
//final
reset_toaplan1;
iniciar_toaplan1:=true;
end;

end.
