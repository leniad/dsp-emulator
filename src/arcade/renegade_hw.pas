unit renegade_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6502,m6809,main_engine,controls_engine,gfx_engine,m6805,ym_3812,
     rom_engine,pal_engine,sound_engine,generic_adpcm;

procedure Cargar_renegade;
procedure principal_renegade;
function iniciar_renegade:boolean;
procedure cerrar_renegade;
procedure reset_renegade;
//Main CPU
function getbyte_renegade(direccion:word):byte;
procedure putbyte_renegade(direccion:word;valor:byte);
//Sound CPU
function getbyte_snd_renegade(direccion:word):byte;
procedure putbyte_snd_renegade(direccion:word;valor:byte);
procedure renegade_sound_update;
procedure snd_irq(irqstate:byte);
//MCU CPU
function renegade_mcu_getbyte(direccion:word):byte;
procedure renegade_mcu_putbyte(direccion:word;valor:byte);

implementation
const
        renegade_rom:array[0..2] of tipo_roms=(
        (n:'nb-5.ic51';l:$8000;p:$0;crc:$ba683ddf),(n:'na-5.ic52';l:$8000;p:$8000;crc:$de7e7df4),());
        renegade_char:tipo_roms=(n:'nc-5.bin';l:$8000;p:$0;crc:$9adfaa5d);
        renegade_snd:tipo_roms=(n:'n0-5.ic13';l:$8000;p:$8000;crc:$3587de3b);
        renegade_mcu:tipo_roms=(n:'nz-5.ic97';l:$800;p:$0;crc:$32e47560);
        renegade_tiles:array[0..6] of tipo_roms=(
        (n:'n1-5.ic1';l:$8000;p:$0;crc:$4a9f47f3),(n:'n6-5.ic28';l:$8000;p:$8000;crc:$d62a0aa8),
        (n:'n7-5.ic27';l:$8000;p:$10000;crc:$7ca5a532),(n:'n2-5.ic14';l:$8000;p:$18000;crc:$8d2e7982),
        (n:'n8-5.ic26';l:$8000;p:$20000;crc:$0dba31d3),(n:'n9-5.ic25';l:$8000;p:$28000;crc:$5b621b6a),());
        renegade_sprites:array[0..12] of tipo_roms=(
        (n:'nh-5.bin';l:$8000;p:$0;crc:$dcd7857c),(n:'nd-5.bin';l:$8000;p:$8000;crc:$2de1717c),
        (n:'nj-5.bin';l:$8000;p:$10000;crc:$0f96a18e),(n:'nn-5.bin';l:$8000;p:$18000;crc:$1bf15787),
        (n:'ne-5.bin';l:$8000;p:$20000;crc:$924c7388),(n:'nk-5.bin';l:$8000;p:$28000;crc:$69499a94),
        (n:'ni-5.bin';l:$8000;p:$30000;crc:$6f597ed2),(n:'nf-5.bin';l:$8000;p:$38000;crc:$0efc8d45),
        (n:'nl-5.bin';l:$8000;p:$40000;crc:$14778336),(n:'no-5.bin';l:$8000;p:$48000;crc:$147dd23b),
        (n:'ng-5.bin';l:$8000;p:$50000;crc:$a8ee3720),(n:'nm-5.bin';l:$8000;p:$58000;crc:$c100258e),());
        renegade_adpcm:array[0..3] of tipo_roms=(
        (n:'n5-5.ic31';l:$8000;p:$0;crc:$7ee43a3c),(n:'n4-5.ic32';l:$8000;p:$10000;crc:$6557564c),
        (n:'n3-5.ic33';l:$8000;p:$18000;crc:$78fd6190),());
        //Dip
        renegade_dip_a:array [0..6] of def_dip=(
        (mask:$3;name:'Coin A';number:4;dip:((dip_val:$0;dip_name:'2C 1C'),(dip_val:$3;dip_name:'1C 1C'),(dip_val:$2;dip_name:'1C 2C'),(dip_val:$1;dip_name:'1C 3C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Coin B';number:4;dip:((dip_val:$0;dip_name:'2C 1C'),(dip_val:$c;dip_name:'1C 1C'),(dip_val:$8;dip_name:'1C 2C'),(dip_val:$4;dip_name:'1C 3C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Lives';number:2;dip:((dip_val:$10;dip_name:'1'),(dip_val:$0;dip_name:'2'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Bonus';number:2;dip:((dip_val:$20;dip_name:'30K'),(dip_val:$0;dip_name:'None'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Cabinet';number:2;dip:((dip_val:$40;dip_name:'Upright'),(dip_val:$0;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Flip Screen';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        renegade_dip_b:array [0..1] of def_dip=(
        (mask:$3;name:'Difficulty';number:4;dip:((dip_val:$2;dip_name:'Easy'),(dip_val:$3;dip_name:'Normal'),(dip_val:$1;dip_name:'Hard'),(dip_val:$0;dip_name:'Very Hard'),(),(),(),(),(),(),(),(),(),(),(),())),());

var
  rom_mem:array[0..1,0..$3fff] of byte;
  mcu_mem:array[0..$7ff] of byte;
  rom_bank,sound_latch:byte;
  scroll_x:word;
  port_c_in,port_c_out,port_b_out,port_b_in,port_a_in,port_a_out:byte;
  ddr_a,ddr_b,ddr_c,from_main,from_mcu:byte;
  main_sent,mcu_sent:boolean;
  scroll_comp:integer;

procedure Cargar_renegade;
begin
llamadas_maquina.iniciar:=iniciar_renegade;
llamadas_maquina.bucle_general:=principal_renegade;
llamadas_maquina.cerrar:=cerrar_renegade;
llamadas_maquina.reset:=reset_renegade;
end;

function iniciar_renegade:boolean;
const
    pc_x:array[0..7] of dword=(1, 0, 65, 64, 129, 128, 193, 192);
    pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
    pt_x:array[0..15] of dword=(3, 2, 1, 0, 16*8+3, 16*8+2, 16*8+1, 16*8+0,
		32*8+3,32*8+2 ,32*8+1 ,32*8+0 ,48*8+3 ,48*8+2 ,48*8+1 ,48*8+0);
    pt_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
		8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8);
var
  f:byte;
  memoria_temp:array[0..$5ffff] of byte;
begin
iniciar_renegade:=false;
iniciar_audio(false);
screen_init(1,1024,256);
screen_mod_scroll(1,1024,256,1023,0,0,0);
screen_init(2,256,256,true);
screen_init(3,256,256,false,true);
iniciar_video(240,240);
//Main CPU
main_m6502:=cpu_m6502.create(1500000,256,TCPU_M6502);
main_m6502.change_ram_calls(getbyte_renegade,putbyte_renegade);
//Sound CPU
snd_m6809:=cpu_m6809.Create(1500000,256);
snd_m6809.change_ram_calls(getbyte_snd_renegade,putbyte_snd_renegade);
snd_m6809.init_sound(renegade_sound_update);
//MCU CPU
main_m6805:=cpu_m6805.create(3000000,256,tipo_m68705);
main_m6805.change_ram_calls(renegade_mcu_getbyte,renegade_mcu_putbyte);
//Sound Chip
ym3812_0:=ym3812_chip.create(YM3526_FM,3000000);
ym3812_0.change_irq_calls(snd_irq);
gen_adpcm_init(0,8000,$20000);
//cargar roms
if not(cargar_roms(@memoria_temp,@renegade_rom,'renegade.zip',0)) then exit;
copymemory(@memoria[$8000],@memoria_temp[0],$8000);
copymemory(@rom_mem[0,0],@memoria_temp[$8000],$4000);
copymemory(@rom_mem[1,0],@memoria_temp[$c000],$4000);
//cargar roms audio
if not(cargar_roms(@mem_snd,@renegade_snd,'renegade.zip')) then exit;
//cargar roms mcu
if not(cargar_roms(@mcu_mem,@renegade_mcu,'renegade.zip')) then exit;
//adpcm roms
if not(cargar_roms(@gen_adpcm[0].mem[0],@renegade_adpcm,'renegade.zip',0)) then exit;
//Cargar chars
if not(cargar_roms(@memoria_temp,@renegade_char,'renegade.zip')) then exit;
init_gfx(0,8,8,$400);
gfx[0].trans[0]:=true;
gfx_set_desc_data(3,0,32*8,2,4,6);
convert_gfx(0,0,@memoria_temp,@pc_x,@pc_y,false,false);
//Cargar tiles
if not(cargar_roms(@memoria_temp,@renegade_tiles,'renegade.zip',0)) then exit;
init_gfx(1,16,16,$800);
for f:=0 to 1 do begin
  gfx_set_desc_data(3,8,64*8,4,$8000*8+0,$8000*8+4);
  convert_gfx(1,f*$400*16*16,@memoria_temp[f*$18000],@pt_x,@pt_y,false,false);
  gfx_set_desc_data(3,8,64*8,0,$C000*8+0,$C000*8+4);
  convert_gfx(1,(f*$400*16*16)+($100*16*16),@memoria_temp[f*$18000],@pt_x,@pt_y,false,false);
  gfx_set_desc_data(3,8,64*8,$4000*8+4,$10000*8+0,$10000*8+4);
  convert_gfx(1,(f*$400*16*16)+($200*16*16),@memoria_temp[f*$18000],@pt_x,@pt_y,false,false);
  gfx_set_desc_data(3,8,64*8,$4000*8+0,$14000*8+0,$14000*8+4);
  convert_gfx(1,(f*$400*16*16)+($300*16*16),@memoria_temp[f*$18000],@pt_x,@pt_y,false,false);
end;
//sprites
if not(cargar_roms(@memoria_temp,@renegade_sprites,'renegade.zip',0)) then exit;
init_gfx(2,16,16,$1000);
gfx[2].trans[0]:=true;
for f:=0 to 3 do begin
  gfx_set_desc_data(3,16,64*8,4,$8000*8+0,$8000*8+4);
  convert_gfx(2,f*$400*16*16,@memoria_temp[f*$18000],@pt_x,@pt_y,false,false);
  gfx_set_desc_data(3,16,64*8,0,$C000*8+0,$C000*8+4);
  convert_gfx(2,(f*$400*16*16)+($100*16*16),@memoria_temp[f*$18000],@pt_x,@pt_y,false,false);
  gfx_set_desc_data(3,16,64*8,$4000*8+4,$10000*8+0,$10000*8+4);
  convert_gfx(2,(f*$400*16*16)+($200*16*16),@memoria_temp[f*$18000],@pt_x,@pt_y,false,false);
  gfx_set_desc_data(3,16,64*8,$4000*8+0,$14000*8+0,$14000*8+4);
  convert_gfx(2,(f*$400*16*16)+($300*16*16),@memoria_temp[f*$18000],@pt_x,@pt_y,false,false);
end;
//Dip
marcade.dswa:=$bf;
marcade.dswb:=$8f;
marcade.dswa_val:=@renegade_dip_a;
marcade.dswb_val:=@renegade_dip_b;
//final
reset_renegade;
iniciar_renegade:=true;
end;

procedure cerrar_renegade;
begin
gen_adpcm_close(0);
end;

procedure reset_renegade;
begin
main_m6502.reset;
snd_m6809.reset;
main_m6805.reset;
ym3812_0.reset;
gen_adpcm_reset(0);
marcade.in0:=$ff;
marcade.in1:=$ff;
rom_bank:=0;
sound_latch:=0;
scroll_x:=0;
port_c_in:=0;
port_c_out:=0;
port_b_out:=0;
port_b_in:=0;
port_a_in:=0;
port_a_out:=0;
ddr_a:=0;
ddr_b:=0;
ddr_c:=0;
from_main:=0;
from_mcu:=0;
main_sent:=false;
mcu_sent:=false;
scroll_comp:=-256;
end;

procedure update_video_renegade;
var
  f,nchar,x,y:word;
  color,atrib:byte;
  flip_x:boolean;
begin
for f:=0 to $3ff do begin
  //Background
  atrib:=memoria[$2c00+f];
  color:=atrib shr 5;
  if (gfx[1].buffer[f] or buffer_color[color+4]) then begin
    x:=f mod 64;
    y:=f div 64;
    nchar:=memoria[$2800+f]+((atrib and $7) shl 8);
    put_gfx_trans(x*16,y*16,nchar,(color shl 3)+192,1,1);
    gfx[1].buffer[f]:=false;
  end;
  //Foreground
  atrib:=memoria[$1c00+f];
  color:=atrib shr 6;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
    x:=f mod 32;
    y:=f div 32;
    nchar:=memoria[$1800+f]+((atrib and $3) shl 8);
    put_gfx_trans(x*8,y*8,nchar,color shl 3,2,0);
    gfx[0].buffer[f]:=false;
  end;
end;
scroll__x(1,3,(scroll_x+scroll_comp) and $3ff);
for f:=0 to 95 do begin
  y:=240-memoria[$2000+(f*4)];
  if y>=16 then begin
    atrib:=memoria[$2001+(f*4)];
    x:=memoria[$2003+(f*4)];
    nchar:=memoria[$2002+(f*4)]+((atrib and $f) shl 8);
    color:=(atrib and $30) shr 1;
    flip_x:=(atrib and $40)<>0;
    if (atrib and $80)<>0 then begin
      nchar:=nchar and $fffe;
      put_gfx_sprite(nchar+1,color+128,flip_x,false,2);
      actualiza_gfx_sprite(x,y+16,3,2);
      put_gfx_sprite(nchar,color+128,flip_x,false,2);
      actualiza_gfx_sprite(x,y,3,2);
    end else begin
      put_gfx_sprite(nchar,color+128,flip_x,false,2);
      actualiza_gfx_sprite(x,y+16,3,2);
    end;
  end;
end;
actualiza_trozo(0,0,256,256,2,0,0,256,256,3);
actualiza_trozo_final(8,0,240,240,3);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure eventos_renegade;
begin
if event.arcade then begin
  //P1
  if arcade_input.right[0] then marcade.in0:=marcade.in0 and $fe else marcade.in0:=marcade.in0 or 1;
  if arcade_input.left[0] then marcade.in0:=marcade.in0 and $fd else marcade.in0:=marcade.in0 or 2;
  if arcade_input.up[0] then marcade.in0:=marcade.in0 and $fb else marcade.in0:=marcade.in0 or 4;
  if arcade_input.down[0] then marcade.in0:=marcade.in0 and $f7 else marcade.in0:=marcade.in0 or 8;
  if arcade_input.but0[0] then marcade.in0:=marcade.in0 and $ef else marcade.in0:=marcade.in0 or $10;
  if arcade_input.but1[0] then marcade.in0:=marcade.in0 and $df else marcade.in0:=marcade.in0 or $20;
  if arcade_input.start[0] then marcade.in0:=marcade.in0 and $bf else marcade.in0:=marcade.in0 or $40;
  if arcade_input.start[1] then marcade.in0:=marcade.in0 and $7f else marcade.in0:=marcade.in0 or $80;
  //p2
  if arcade_input.right[1] then marcade.in1:=marcade.in1 and $fe else marcade.in1:=marcade.in1 or 1;
  if arcade_input.left[1] then marcade.in1:=marcade.in1 and $fd else marcade.in1:=marcade.in1 or 2;
  if arcade_input.up[1] then marcade.in1:=marcade.in1 and $fb else marcade.in1:=marcade.in1 or 4;
  if arcade_input.down[1] then marcade.in1:=marcade.in1 and $f7 else marcade.in1:=marcade.in1 or 8;
  if arcade_input.but0[1] then marcade.in1:=marcade.in1 and $ef else marcade.in1:=marcade.in1 or $10;
  if arcade_input.but1[1] then marcade.in1:=marcade.in1 and $df else marcade.in1:=marcade.in1 or $20;
  if arcade_input.coin[0] then marcade.in1:=marcade.in1 and $bf else marcade.in1:=marcade.in1 or $40;
  if arcade_input.coin[1] then marcade.in1:=marcade.in1 and $7f else marcade.in1:=marcade.in1 or $80;
  //botones 3
  if arcade_input.but2[0] then marcade.dswb:=marcade.dswb and $fb else marcade.dswb:=marcade.dswb or $4;
  if arcade_input.but2[1] then marcade.dswb:=marcade.dswb and $f7 else marcade.dswb:=marcade.dswb or $8;
end;
end;

procedure principal_renegade;
var
  frame_m,frame_s,frame_mcu:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=main_m6502.tframes;
frame_s:=snd_m6809.tframes;
frame_mcu:=main_m6805.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to $ff do begin
   main_m6502.run(frame_m);
   frame_m:=frame_m+main_m6502.tframes-main_m6502.contador;
   //Sound
   snd_m6809.run(frame_s);
   frame_s:=frame_s+snd_m6809.tframes-snd_m6809.contador;
   //mcu
   main_m6805.run(frame_mcu);
   frame_mcu:=frame_mcu+main_m6805.tframes-main_m6805.contador;
   case f of
      111:main_m6502.change_nmi(PULSE_LINE);
      239:begin
            update_video_renegade;
            main_m6502.change_irq(HOLD_LINE);
            marcade.dswb:=marcade.dswb and $bf;
          end;
      63:marcade.dswb:=marcade.dswb or $40;
   end;
 end;
 eventos_renegade;
 video_sync;
end;
end;

function getbyte_renegade(direccion:word):byte;
var
  ret:byte;
begin
case direccion of
   0..$2fff,$8000..$ffff:getbyte_renegade:=memoria[direccion];
   $3000..$31ff:getbyte_renegade:=buffer_paleta[direccion and $1ff];
   $3800:getbyte_renegade:=marcade.in0;
   $3801:getbyte_renegade:=marcade.in1;
   $3802:begin
            ret:=0;
            if not(main_sent) then ret:=ret or 1;
		        if not(mcu_sent) then ret:=ret or 2;
            getbyte_renegade:=marcade.dswb or (ret shl 4);
         end;
   $3803:getbyte_renegade:=marcade.dswa;
   $3804:begin
            mcu_sent:=false;
		        getbyte_renegade:=from_mcu;
         end;
   $3805:main_m6805.pedir_reset:=PULSE_LINE;
   $4000..$7fff:getbyte_renegade:=rom_mem[rom_bank,direccion and $3fff];
end;
end;

procedure cambiar_color(dir:byte);inline;
var
  tmp_color:byte;
  color:tcolor;
begin
  tmp_color:=buffer_paleta[dir];
  color.g:=pal4bit(tmp_color shr 4);
  color.r:=pal4bit(tmp_color);
  tmp_color:=buffer_paleta[dir+$100];
  color.b:=pal4bit(tmp_color);
  set_pal_color(color,dir);
  case dir of
    $0..$1f:buffer_color[dir shr 3]:=true;
    $c0..$ff:buffer_color[((dir shr 3) and 7)+4]:=true;
  end;
end;

procedure putbyte_renegade(direccion:word;valor:byte);
begin
if direccion>$3fff then exit;
case direccion of
  0..$17ff,$2000..$27ff:memoria[direccion]:=valor;
  $1800..$1fff:begin
                gfx[0].buffer[direccion and $3ff]:=true;
                memoria[direccion]:=valor;
             end;
  $2800..$2fff:begin
                gfx[1].buffer[direccion and $3ff]:=true;
                memoria[direccion]:=valor;
             end;
  $3000..$31ff:if buffer_paleta[direccion and $1ff]<>valor then begin
                buffer_paleta[direccion and $1ff]:=valor;
                cambiar_color(direccion and $ff);
             end;
  $3800:scroll_x:=(scroll_x and $ff00) or valor;
  $3801:scroll_x:=(scroll_x and $ff) or (valor shl 8);
  $3802:begin
          sound_latch:=valor;
          snd_m6809.change_irq(HOLD_LINE);
        end;
  $3803:begin
          if ((valor and 1)=0) then begin
            scroll_comp:=0;
            main_screen.flip_main_screen:=true;
          end else begin
            scroll_comp:=-256;
            main_screen.flip_main_screen:=false;
          end;
        end;
  $3804:begin
          from_main:=valor;
		      main_sent:=true;
		      main_m6805.irq_request(0,ASSERT_LINE);
        end;
  $3805:rom_bank:=valor and 1;
end;
end;

function getbyte_snd_renegade(direccion:word):byte;
begin
  case direccion of
    0..$fff,$8000..$ffff:getbyte_snd_renegade:=mem_snd[direccion];
    $1000:getbyte_snd_renegade:=sound_latch;
    $2800:getbyte_snd_renegade:=ym3812_0.status;
  end;
end;

procedure putbyte_snd_renegade(direccion:word;valor:byte);
var
  offs:integer;
  len:word;
begin
if direccion>$7fff then exit;
case direccion of
  0..$fff:mem_snd[direccion]:=valor;
  $2000:begin
            offs:=(valor-$2c)*$2000;
	          len:=$2000*2;
	          // kludge to avoid reading past end of ROM */
	          if ((offs+len)>$20000) then len:=$1000;
	          if ((offs>=0) and ((offs+len)<=$20000)) then begin
		            gen_adpcm_reset(0);
                gen_adpcm[0].current:=offs;
                gen_adpcm[0].end_:=offs+(len shr 1);
                gen_adpcm[0].nibble:=4;
                gen_adpcm_timer(0,true);
	          end;
  end;
  $2800:ym3812_0.control(valor);
  $2801:ym3812_0.write(valor);
end;
end;

function renegade_mcu_getbyte(direccion:word):byte;
begin
direccion:=direccion and $7ff;
case direccion of
  0:renegade_mcu_getbyte:=(port_a_out and ddr_a) or (port_a_in and not(ddr_a));
	1:renegade_mcu_getbyte:=(port_b_out and ddr_b) or (port_b_in and not(ddr_b));
	2:begin
      port_c_in:=0;
    	if main_sent then port_c_in:=port_c_in or $01;
    	if not(mcu_sent) then port_c_in:=port_c_in or $02;
    	renegade_mcu_getbyte:=(port_c_out and ddr_c) or (port_c_in and not(ddr_c));
    end;
  $10..$7ff:renegade_mcu_getbyte:=mcu_mem[direccion];
end;
end;

procedure renegade_mcu_putbyte(direccion:word;valor:byte);
begin
direccion:=direccion and $7ff;
if direccion>$7f then exit;
case direccion of
  0:port_a_out:=valor;
	1:begin
      if (((ddr_b and $02)<>0) and ((not(valor) and $02)<>0) and ((port_b_out and $2)<>0)) then begin
    		port_a_in:=from_main;
    	  if main_sent then main_m6805.irq_request(0,CLEAR_LINE);
        main_sent:=false;
    	end;
    	if (((ddr_b and $04)<>0) and ((valor and $04)<>0) and ((not(port_b_out) and $04)<>0)) then begin
    		from_mcu:=port_a_out;
    		mcu_sent:=true;
    	end;
    	port_b_out:=valor;
    end;
	2:port_c_out:=valor;
	4:ddr_a:=valor;
	5:ddr_b:=valor;
	6:ddr_c:=valor;
  $10..$7f:mcu_mem[direccion]:=valor;
end;
end;

procedure renegade_sound_update;
begin
  ym3812_0.update;
  gen_adpcm_update(0);
end;

procedure snd_irq(irqstate:byte);
begin
  snd_m6809.change_firq(irqstate);
end;

end.
