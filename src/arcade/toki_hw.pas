unit toki_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,m68000,main_engine,controls_engine,gfx_engine,ym_3812,oki6295,
     seibu_sound,rom_engine,pal_engine,sound_engine,misc_functions;

procedure Cargar_toki;
procedure toki_principal;
function iniciar_toki:boolean;
procedure reset_toki;
procedure cerrar_toki;
//Main CPU
function toki_getword(direccion:dword):word;
procedure toki_putword(direccion:dword;valor:word);
//Sound CPU
function toki_snd_getbyte(direccion:word):byte;
procedure toki_snd_putbyte(direccion:word;valor:byte);
procedure toki_sound_update;
procedure snd_irq(irqstate:byte);

implementation
const
        toki_rom:array[0..4] of tipo_roms=(
        (n:'l10_6.bin';l:$20000;p:0;crc:$94015d91),(n:'k10_4e.bin';l:$20000;p:$1;crc:$531bd3ef),
        (n:'tokijp.005';l:$10000;p:$40000;crc:$d6a82808),(n:'tokijp.003';l:$10000;p:$40001;crc:$a01a5b10),());
        toki_char:array[0..2] of tipo_roms=(
        (n:'tokijp.001';l:$10000;p:0;crc:$8aa964a2),(n:'tokijp.002';l:$10000;p:$10000;crc:$86e87e48),());
        toki_sprites:array[0..2] of tipo_roms=(
        (n:'toki.ob1';l:$80000;p:0;crc:$a27a80ba),(n:'toki.ob2';l:$80000;p:$80000;crc:$fa687718),());
        toki_tiles1:tipo_roms=(n:'toki.bk1';l:$80000;p:0;crc:$fdaa5f4b);
        toki_tiles2:tipo_roms=(n:'toki.bk2';l:$80000;p:0;crc:$d86ac664);
        toki_sound:array[0..2] of tipo_roms=(
        (n:'tokijp.008';l:$2000;p:0;crc:$6c87c4c5),(n:'tokijp.007';l:$10000;p:$10000;crc:$a67969c4),());
        toki_adpcm:tipo_roms=(n:'tokijp.009';l:$20000;p:0;crc:$ae7a6b8b);
        toki_dip:array [0..9] of def_dip=(
        (mask:$1f;name:'Coinage';number:16;dip:((dip_val:$15;dip_name:'6C 1C'),(dip_val:$17;dip_name:'5C 1C'),(dip_val:$19;dip_name:'4C 1C'),(dip_val:$1b;dip_name:'3C 1C'),(dip_val:$3;dip_name:'8C 3C'),(dip_val:$1d;dip_name:'2C 1C'),(dip_val:$5;dip_name:'5C 3C'),(dip_val:$7;dip_name:'3C 2C'),(dip_val:$1f;dip_name:'1C 1C'),(dip_val:$9;dip_name:'2C 3C'),(dip_val:$13;dip_name:'1C 2C'),(dip_val:$11;dip_name:'1C 3C'),(dip_val:$f;dip_name:'1C 4C'),(dip_val:$d;dip_name:'1C 5C'),(dip_val:$b;dip_name:'1C 6C'),(dip_val:$1e;dip_name:'A 1C 1C/B 1/2'))),
        (mask:$20;name:'Joysticks';number:2;dip:((dip_val:$20;dip_name:'1'),(dip_val:$0;dip_name:'2'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Cabinet';number:2;dip:((dip_val:$40;dip_name:'Upright'),(dip_val:$0;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Flip Screen';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$300;name:'Lives';number:4;dip:((dip_val:$200;dip_name:'2'),(dip_val:$300;dip_name:'3'),(dip_val:$100;dip_name:'5'),(dip_val:$0;dip_name:'Infinite'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c00;name:'Bonus Life';number:4;dip:((dip_val:$800;dip_name:'50k 150k'),(dip_val:$0;dip_name:'70k 140k 210k'),(dip_val:$c00;dip_name:'70k'),(dip_val:$400;dip_name:'100k 200k'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$3000;name:'Difficulty';number:4;dip:((dip_val:$2000;dip_name:'Easy'),(dip_val:$3000;dip_name:'Medium'),(dip_val:$1000;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4000;name:'Allow Continue';number:2;dip:((dip_val:$0;dip_name:'No'),(dip_val:$4000;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8000;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$8000;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 rom:array[0..$2ffff] of word;
 ram:array[0..$7fff] of word;
 sprite_ram:array[0..$3ff] of word;
 sound_rom:array[0..1,0..$7fff] of byte;
 decrypt:array[0..$1fff] of byte;
 snd_bank,irq1,irq2:byte;
 scroll_x2_tmp,scroll_x1,scroll_y1,scroll_y2:word;
 scroll_x2:array[0..$ff] of word;
 prioridad_pant:boolean;

procedure Cargar_toki;
begin
llamadas_maquina.iniciar:=iniciar_toki;
llamadas_maquina.bucle_general:=toki_principal;
llamadas_maquina.cerrar:=cerrar_toki;
llamadas_maquina.reset:=reset_toki;
llamadas_maquina.fps_max:=59.61;
end;

function iniciar_toki:boolean; 
const
  pc_x:array[0..7] of dword=(3, 2, 1, 0, 8+3, 8+2, 8+1, 8+0);
  pc_y:array[0..7] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16);
  ps_x:array[0..15] of dword=(3, 2, 1, 0, 16+3, 16+2, 16+1, 16+0,
			64*8+3, 64*8+2, 64*8+1, 64*8+0, 64*8+16+3, 64*8+16+2, 64*8+16+1, 64*8+16+0);
  ps_y:array[0..15] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32,
			8*32, 9*32, 10*32, 11*32, 12*32, 13*32, 14*32, 15*32);
var
   memoria_temp,ptemp:pbyte;
   f:dword;
   memoria_temp2:array[0..$1ffff] of byte;
begin
iniciar_toki:=false;
iniciar_audio(false);
//Pantallas:  principal+char y sprites
screen_init(1,256,256,true);
screen_init(2,512,512,true);
screen_mod_scroll(2,512,256,511,512,256,511);
screen_init(3,256,256,false,true);
screen_mod_sprites(3,512,512,$1ff,$1ff);
screen_init(4,512,512,true);
screen_mod_scroll(4,512,256,511,512,256,511);
iniciar_video(256,224);
getmem(memoria_temp,$100000);
//Main CPU
main_m68000:=cpu_m68000.create(10000000,256);
main_m68000.change_ram16_calls(toki_getword,toki_putword);
//Sound CPU
snd_z80:=cpu_z80.create(3579545,256);
snd_z80.change_ram_calls(toki_snd_getbyte,toki_snd_putbyte);
snd_z80.init_sound(toki_sound_update);
//Sound Chips
ym3812_init(0,3579545,snd_irq);
oki_6295_0:=snd_okim6295.Create(0,1000000,OKIM6295_PIN7_HIGH,0.40);
if not(cargar_roms(@memoria_temp2[0],@toki_adpcm,'toki.zip',1)) then exit;
ptemp:=oki_6295_0.get_rom_addr;
for f:=0 to $1ffff do begin
  ptemp^:=memoria_temp2[BITSWAP24(f,23,22,21,20,19,18,17,16,13,14,15,12,11,10,9,8,7,6,5,4,3,2,1,0)];
  inc(ptemp);
end;
//cargar roms
if not(cargar_roms16w(@rom[0],@toki_rom[0],'toki.zip',0)) then exit;
//cargar sonido, desencriptar y poner bancos
if not(cargar_roms(memoria_temp,@toki_sound,'toki.zip',0)) then exit;
decript_seibu_sound(memoria_temp,@decrypt[0],@mem_snd[0]);
ptemp:=memoria_temp;
inc(ptemp,$10000);copymemory(@sound_rom[0,0],ptemp,$8000);
inc(ptemp,$8000);copymemory(@sound_rom[1,0],ptemp,$8000);
//convertir chars
if not(cargar_roms(memoria_temp,@toki_char,'toki.zip',0)) then exit;
init_gfx(0,8,8,4096);
gfx[0].trans[15]:=true;
gfx_set_desc_data(4,0,16*8,4096*16*8+0,4096*16*8+4,0,4);
convert_gfx(0,0,memoria_temp,@pc_x[0],@pc_y[0],false,false);
//sprites
if not(cargar_roms(memoria_temp,@toki_sprites,'toki.zip',0)) then exit;
init_gfx(1,16,16,8192);
gfx[1].trans[15]:=true;
gfx_set_desc_data(4,0,128*8,2*4,3*4,0*4,1*4);
convert_gfx(1,0,memoria_temp,@ps_x[0],@ps_y[0],false,false);
//tiles
if not(cargar_roms(memoria_temp,@toki_tiles1,'toki.zip',1)) then exit;
init_gfx(2,16,16,4096);
gfx[2].trans[15]:=true;
convert_gfx(2,0,memoria_temp,@ps_x[0],@ps_y[0],false,false);
if not(cargar_roms(memoria_temp,@toki_tiles2,'toki.zip',1)) then exit;
init_gfx(3,16,16,4096);
gfx[3].trans[15]:=true;
convert_gfx(3,0,memoria_temp,@ps_x[0],@ps_y[0],false,false);
//DIP
marcade.dswa:=$ffdf;
marcade.dswa_val:=@toki_dip;
//final
freemem(memoria_temp);
reset_toki;
iniciar_toki:=true;
end;

procedure cerrar_toki;
begin
main_m68000.free;
snd_z80.free;
ym3812_close(0);
oki_6295_0.Free;
close_audio;
close_video;
end;

procedure reset_toki;
begin
 main_m68000.reset;
 snd_z80.reset;
 YM3812_Reset(0);
 oki_6295_0.reset;
 seibu_reset;
 reset_audio;
 marcade.in0:=$FFFF;
 marcade.in1:=$FF;
 marcade.in2:=0;
 scroll_x1:=0;
 scroll_y1:=0;
 scroll_x2_tmp:=0;
 fillchar(scroll_x2,$100,0);
 scroll_y2:=0;
 snd_bank:=0;
end;

procedure update_video_toki;
var
  f,color,sy,x,y,nchar,atrib,atrib2,atrib3:word;
begin
for f:=0 to $3ff do begin
  //Background 1
  atrib:=ram[$7400+f];
  color:=atrib shr 12;
  if (gfx[2].buffer[f] or buffer_color[color+$10]) then begin
    x:=f mod 32;
    y:=f div 32;
    nchar:=atrib and $fff;
    if prioridad_pant then put_gfx(x*16,y*16,nchar,(color shl 4)+$200,2,2)
      else put_gfx_trans(x*16,y*16,nchar,(color shl 4)+$200,2,2);
    gfx[2].buffer[f]:=false;
  end;
  //Background 2
  atrib:=ram[$7800+f];
  color:=atrib shr 12;
  if (gfx[3].buffer[f] or buffer_color[color+$20]) then begin
    x:=f mod 32;
    y:=f div 32;
    nchar:=atrib and $fff;
    if prioridad_pant then put_gfx_trans(x*16,y*16,nchar,(color shl 4)+$300,4,3)
      else put_gfx(x*16,y*16,nchar,(color shl 4)+$300,4,3);
    gfx[3].buffer[f]:=false;
  end;
  //Foreground
  atrib:=ram[$7c00+f];
  color:=atrib shr 12;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
    x:=f mod 32;
    y:=f div 32;
    nchar:=atrib and $fff;
    put_gfx_trans(x*8,y*8,nchar,(color shl 4)+$100,1,0);
    gfx[0].buffer[f]:=false;
  end;
end;
if prioridad_pant then begin
  scroll_x_y(2,3,scroll_x1,scroll_y1);
  for f:=0 to $ff do scroll__x_part(4,3,scroll_x2[f],scroll_y2,f,1);
end else begin
  scroll_x_y(4,3,scroll_x2_tmp,scroll_y2);
  scroll_x_y(2,3,scroll_x1,scroll_y1);
end;
for f:=$ff downto 0 do begin
    atrib:=sprite_ram[f*4];
    atrib2:=sprite_ram[(f*4)+2];
		if ((atrib2<>$f000) and (atrib<>$ffff)) then begin
			x:=atrib2+(atrib and $f0);
			sy:=(atrib and $0f) shl 4;
			y:=sprite_ram[(f*4)+3]+sy;
      atrib3:=sprite_ram[(f*4)+1];
			color:=(atrib3 shr 8) and $f0;
			nchar:=(atrib3 and $fff)+((atrib2 and $8000) shr 3);
      put_gfx_sprite(nchar,color,(atrib and $100)<>0,false,1);
      actualiza_gfx_sprite(x,y,3,1);
    end;
end;
actualiza_trozo(0,0,256,256,1,0,0,256,256,3);
actualiza_trozo_final(0,16,256,224,3);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure eventos_toki;
begin
if event.arcade then begin
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fffe) else marcade.in0:=(marcade.in0 or $0001);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fffd) else marcade.in0:=(marcade.in0 or $0002);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fffb) else marcade.in0:=(marcade.in0 or $0004);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fff7) else marcade.in0:=(marcade.in0 or $0008);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $ffef) else marcade.in0:=(marcade.in0 or $0010);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ffdf) else marcade.in0:=(marcade.in0 or $0020);
  if arcade_input.up[1] then marcade.in0:=(marcade.in0 and $fffe) else marcade.in0:=(marcade.in0 or $0100);
  if arcade_input.down[1] then marcade.in0:=(marcade.in0 and $fdff) else marcade.in0:=(marcade.in0 or $0200);
  if arcade_input.left[1] then marcade.in0:=(marcade.in0 and $fbff) else marcade.in0:=(marcade.in0 or $0400);
  if arcade_input.right[1] then marcade.in0:=(marcade.in0 and $f7ff) else marcade.in0:=(marcade.in0 or $0800);
  if arcade_input.but1[1] then marcade.in0:=(marcade.in0 and $efff) else marcade.in0:=(marcade.in0 or $1000);
  if arcade_input.but0[1] then marcade.in0:=(marcade.in0 and $dfff) else marcade.in0:=(marcade.in0 or $2000);
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 or $1) else marcade.in2:=(marcade.in2 and $fe);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 or $2) else marcade.in2:=(marcade.in2 and $fd);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
end;
end;

procedure toki_principal;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=main_m68000.tframes;
frame_s:=snd_z80.tframes;
while EmuStatus=EsRuning do begin
   for f:=0 to $ff do begin
     //Main CPU
     main_m68000.run(frame_m);
     frame_m:=frame_m+main_m68000.tframes-main_m68000.contador;
     //Sound CPU
     snd_z80.run(frame_s);
     frame_s:=frame_s+snd_z80.tframes-snd_z80.contador;
     if f=239 then begin
        main_m68000.irq[1]:=HOLD_LINE;
        update_video_toki;
        copymemory(@sprite_ram[0],@ram[$6c00],$800);
     end;
     scroll_x2[f]:=scroll_x2_tmp;
   end;
   eventos_toki;
   video_sync;
end;
end;

function toki_getword(direccion:dword):word;
begin
case direccion of
    $0..$5ffff:toki_getword:=rom[direccion shr 1];
    $60000..$6dfff,$6e800..$6ffff:toki_getword:=ram[(direccion and $ffff) shr 1];
    $6e000..$6e7ff:toki_getword:=buffer_paleta[(direccion and $7ff) shr 1];
    $80000..$8000d:toki_getword:=seibu_get(direccion and $e);
    $c0000:toki_getword:=marcade.dswa;
    $c0002:toki_getword:=marcade.in0;
    $c0004:toki_getword:=marcade.in1;
end;
end;

procedure cambiar_color(tmp_color,numero:word);inline;
var
  color:tcolor;
begin
  color.b:=pal4bit(tmp_color shr 8);
  color.g:=pal4bit(tmp_color shr 4);
  color.r:=pal4bit(tmp_color);
  set_pal_color(color,@paleta[numero]);
  case numero of
    256..511:buffer_color[(numero shr 4) and $f]:=true;
    512..767:buffer_color[((numero shr 4) and $f)+$10]:=true;
    768..1023:buffer_color[((numero shr 4) and $f)+$20]:=true;
  end;
end;

procedure toki_putword(direccion:dword;valor:word);
begin
if direccion<$60000 then exit;
case direccion of
  $60000..$6dfff:ram[(direccion and $ffff) shr 1]:=valor;
  $6e000..$6e7ff:if buffer_paleta[(direccion and $7ff) shr 1]<>valor then begin
                    buffer_paleta[(direccion and $7ff) shr 1]:=valor;
                    cambiar_color(valor,((direccion and $7ff) shr 1));
                 end;
  $6e800..$6efff:begin
                    ram[(direccion and $ffff) shr 1]:=valor;
                    gfx[2].buffer[(direccion and $7ff) shr 1]:=true;
                 end;
  $6f000..$6f7ff:begin
                    ram[(direccion and $ffff) shr 1]:=valor;
                    gfx[3].buffer[(direccion and $7ff) shr 1]:=true;
                 end;
  $6f800..$6ffff:begin
                    ram[(direccion and $ffff) shr 1]:=valor;
                    gfx[0].buffer[(direccion and $7ff) shr 1]:=true;
                 end;
  $80000..$8000d:seibu_put(direccion and $e,valor);
  $a0000..$a005f:case (direccion and $ff) of
                    $0a:scroll_x1:=(scroll_x1 and $ff) or ((valor and $10) shl 4);
                    $0c:scroll_x1:=(scroll_x1 and $100) or ((valor and $7f) shl 1) or ((valor and $80) shr 7);
                    $1a:scroll_y1:=(scroll_y1 and $ff) or ((valor and $10) shl 4);
                    $1c:scroll_y1:=(scroll_y1 and $100) or ((valor and $7f) shl 1) or ((valor and $80) shr 7);
                    $2a:scroll_x2_tmp:=(scroll_x2_tmp and $ff) or ((valor and $10) shl 4);
                    $2c:scroll_x2_tmp:=(scroll_x2_tmp and $100) or ((valor and $7f) shl 1) or ((valor and $80) shr 7);
                    $3a:scroll_y2:=(scroll_y2 and $ff) or ((valor and $10) shl 4);
                    $3c:scroll_y2:=(scroll_y2 and $100) or ((valor and $7f) shl 1) or ((valor and $80) shr 7);
                    $50:begin
                          main_screen.flip_main_screen:=(valor and $8000)=0;
                          if prioridad_pant<>((valor and $100)<>0) then begin
                            prioridad_pant:=(valor and $100)<>0;
                            fillchar(gfx[2].buffer[0],$400,1);
                            fillchar(gfx[3].buffer[0],$400,1);
                          end;
                        end;
                 end;
end;
end;

function toki_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$1fff:if snd_z80.opcode then toki_snd_getbyte:=decrypt[direccion]
              else toki_snd_getbyte:=mem_snd[direccion];
  $2000..$27ff:toki_snd_getbyte:=mem_snd[direccion];
  $4008:toki_snd_getbyte:=YM3812_status_port(0);
  $4010:toki_snd_getbyte:=sound_latch[0];
  $4011:toki_snd_getbyte:=sound_latch[1];
  $4012:if sub2main_pending then toki_snd_getbyte:=1
          else toki_snd_getbyte:=0;
  $4013:toki_snd_getbyte:=marcade.in2;
  $6000:toki_snd_getbyte:=oki_6295_0.read;
  $8000..$ffff:toki_snd_getbyte:=sound_rom[snd_bank,direccion and $7fff];
end;
end;

procedure toki_snd_putbyte(direccion:word;valor:byte);
begin
if ((direccion<$2000) or (direccion>$7fff)) then exit;
case direccion of
  $2000..$27ff:mem_snd[direccion]:=valor;
  $4000:begin
          main2sub_pending:=false;
        	sub2main_pending:=true;
        end;
  $4001:;//seibu_update_irq_lines(RESET_ASSERT);
  $4002:;
  $4003:seibu_update_irq_lines(RST18_CLEAR);
  $4007:snd_bank:=valor and 1;
  $4008:ym3812_control_port(0,valor);
  $4009:ym3812_write_port(0,valor);
  $4018:sub2main[0]:=valor;
  $4019:sub2main[1]:=valor;
  $6000:oki_6295_0.write(valor);
end;
end;

procedure toki_sound_update;
begin
  ym3812_Update(0);
  oki_6295_0.update;
end;

procedure snd_irq(irqstate:byte);
begin
  if irqstate=0 then seibu_update_irq_lines(RST10_CLEAR)
    else seibu_update_irq_lines(RST10_ASSERT);
end;

end.
