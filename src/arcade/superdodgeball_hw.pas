unit superdodgeball_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6502,m6809,m680x,main_engine,controls_engine,ym_3812,gfx_engine,
     rom_engine,pal_engine,sound_engine,msm5205;

function iniciar_sdodgeball:boolean;

implementation
const
        sdodgeball_rom:tipo_roms=(n:'22a-04.139';l:$10000;p:$0;crc:$66071fda);
        sdodgeball_snd:tipo_roms=(n:'22j5-0.33';l:$8000;p:$8000;crc:$c31e264e);
        sdodgeball_mcu:tipo_roms=(n:'22ja-0.162';l:$4000;p:$c000;crc:$7162a97b);
        sdodgeball_char:array[0..1] of tipo_roms=(
        (n:'22a-4.121';l:$20000;p:$0;crc:$acc26051),(n:'22a-3.107';l:$20000;p:$20000;crc:$10bb800d));
        sdodgeball_sprites:array[0..1] of tipo_roms=(
        (n:'22a-1.2';l:$20000;p:$0;crc:$3bd1c3ec),(n:'22a-2.35';l:$20000;p:$20000;crc:$409e1be1));
        sdodgeball_adpcm:array[0..1] of tipo_roms=(
        (n:'22j6-0.83';l:$10000;p:$0;crc:$744a26e3),(n:'22j7-0.82';l:$10000;p:$10000;crc:$2fa1de21));
        sdodgeball_proms:array[0..1] of tipo_roms=(
        (n:'mb7132e.158';l:$400;p:$0;crc:$7e623722),(n:'mb7122e.159';l:$400;p:$400;crc:$69706e8d));
        sdodgeball_dip_a:array [0..1] of def_dip=(
        (mask:$c0;name:'Difficulty';number:4;dip:((dip_val:$80;dip_name:'Easy'),(dip_val:$c0;dip_name:'Normal'),(dip_val:$40;dip_name:'Hard'),(dip_val:$0;dip_name:'Very Hard'),(),(),(),(),(),(),(),(),(),(),(),())),());
        sdodgeball_dip_b:array [0..4] of def_dip=(
        (mask:$7;name:'Coin A';number:8;dip:((dip_val:$0;dip_name:'4C 1C'),(dip_val:$1;dip_name:'3C 1C'),(dip_val:$2;dip_name:'2C 1C'),(dip_val:$7;dip_name:'1C 1C'),(dip_val:$6;dip_name:'1C 2C'),(dip_val:$5;dip_name:'1C 3C'),(dip_val:$4;dip_name:'1C 4C'),(dip_val:$3;dip_name:'1C 5C'),(),(),(),(),(),(),(),())),
        (mask:$38;name:'Coin B';number:8;dip:((dip_val:$0;dip_name:'4C 1C'),(dip_val:$8;dip_name:'3C 1C'),(dip_val:$10;dip_name:'2C 1C'),(dip_val:$38;dip_name:'1C 1C'),(dip_val:$30;dip_name:'1C 2C'),(dip_val:$28;dip_name:'1C 3C'),(dip_val:$20;dip_name:'1C 4C'),(dip_val:$18;dip_name:'1C 5C'),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Flip Screen';number:2;dip:((dip_val:$40;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$80;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        sdodgeball_dip_c:array [0..1] of def_dip=(
        (mask:$4;name:'Allow Continue';number:2;dip:((dip_val:$0;dip_name:'No'),(dip_val:$4;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
  rom_bank:array[0..1,0..$3fff] of byte;
  nrom_bank,sound_latch,tile_pal,sprite_pal,mcu_latch:byte;
  inputs:array[0..4] of byte;
  scroll_x:array[0..271] of word;
  scroll_x_temp:word;
  //adpcm
  adpcm_rom:array[0..1,0..$ffff] of byte;
  adpcm_pos,adpcm_end:array[0..1] of dword;
  adpcm_data:array[0..1] of integer;

procedure update_video_sdodgeball;
var
  f,nchar,color,pos:word;
  x,y,atrib:byte;
begin
//Background
for f:=$0 to $7ff do begin
    x:=f div 32;
    y:=f mod 32;
    pos:=(x and $1f)+((y and $1f) shl 5)+((x and $20) shl 5);
    atrib:=memoria[$2800+pos];
    color:=((atrib and $e0) shr 5)+8*tile_pal;
    if gfx[0].buffer[pos] then begin
      nchar:=memoria[$2000+pos]+((atrib and $1f) shl 8);
      put_gfx(x*8,y*8,nchar,color shl 4,1,0);
      gfx[0].buffer[pos]:=false;
    end;
end;
scroll__x_part2(1,2,8,@scroll_x[0]);
for f:=0 to $3f do begin
  atrib:=memoria[$1001+(f*4)];
	nchar:=memoria[$1002+(f*4)]+((atrib and $07) shl 8);
  x:=memoria[$1003+(f*4)];
	y:=240-memoria[$1000+(f*4)];
	color:=((atrib and $38) shr 3)+8*sprite_pal;
  if (atrib and $80)<>0 then begin //doble
    put_gfx_sprite_diff(nchar and $fffe,(color shl 4)+$200,(atrib and $40)=0,false,1,0,0);
    put_gfx_sprite_diff(nchar or 1,(color shl 4)+$200,(atrib and $40)=0,false,1,0,16);
    actualiza_gfx_sprite_size(x,y-16,2,16,32);
  end else begin //normol
    put_gfx_sprite(nchar,(color shl 4)+$200,(atrib and $40)=0,false,1);
    actualiza_gfx_sprite(x,y,2,1);
  end;
end;
actualiza_trozo_final(0,0,256,240,2);
end;

procedure eventos_sdodgeball;
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
  //P2
  if arcade_input.right[1] then marcade.in1:=marcade.in1 and $fe else marcade.in1:=marcade.in1 or 1;
  if arcade_input.left[1] then marcade.in1:=marcade.in1 and $fd else marcade.in1:=marcade.in1 or 2;
  if arcade_input.up[1] then marcade.in1:=marcade.in1 and $fb else marcade.in1:=marcade.in1 or 4;
  if arcade_input.down[1] then marcade.in1:=marcade.in1 and $f7 else marcade.in1:=marcade.in1 or 8;
  if arcade_input.but0[1] then marcade.in1:=marcade.in1 and $ef else marcade.in1:=marcade.in1 or $10;
  if arcade_input.but1[1] then marcade.in1:=marcade.in1 and $df else marcade.in1:=marcade.in1 or $20;
  //DSWA
  if arcade_input.coin[0] then marcade.dswa:=marcade.dswa and $f7 else marcade.dswa:=marcade.dswa or 8;
  if arcade_input.coin[1] then marcade.dswa:=marcade.dswa and $ef else marcade.dswa:=marcade.dswa or $10;
end;
end;

procedure principal_sdodgeball;
var
  frame_m,frame_s,frame_mcu:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=m6502_0.tframes;
frame_s:=m6809_0.tframes;
frame_mcu:=m6800_0.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to 271 do begin
    m6502_0.run(frame_m);
    frame_m:=frame_m+m6502_0.tframes-m6502_0.contador;
    //Sound
    m6809_0.run(frame_s);
    frame_s:=frame_s+m6809_0.tframes-m6809_0.contador;
    //MCU CPU
    m6800_0.run(frame_mcu);
    frame_mcu:=frame_mcu+m6800_0.tframes-m6800_0.contador;
    case f of
      0:begin
          m6502_0.change_irq(HOLD_LINE);
          marcade.dswa:=marcade.dswa and $fe;
        end;
      8..239,241..255:if ((f mod 8)=0) then m6502_0.change_irq(HOLD_LINE);
      240:begin
            m6502_0.change_irq(HOLD_LINE);
            marcade.dswa:=marcade.dswa or 1;
            update_video_sdodgeball;
          end;
      256:m6502_0.change_nmi(PULSE_LINE);
    end;
    //Haaaack!
    case f of
      0..255:if (f mod 8)=4 then scroll_x[(f div 8)+1]:=scroll_x_temp;
      256..271:if (f mod 8)=4 then scroll_x[(f and $ff) div 8]:=scroll_x_temp;
    end;
  end;
  eventos_sdodgeball;
  video_sync;
end;
end;

function getbyte_sdodgeball(direccion:word):byte;
begin
case direccion of
   0..$fff,$2000..$2fff,$8000..$ffff:getbyte_sdodgeball:=memoria[direccion];
   $4000..$7fff:getbyte_sdodgeball:=rom_bank[nrom_bank,direccion and $3fff];
   $3000:getbyte_sdodgeball:=marcade.dswa;
   $3001:getbyte_sdodgeball:=marcade.dswb;
   $3801..$3805:getbyte_sdodgeball:=inputs[direccion-$3801]
end;
end;

procedure putbyte_sdodgeball(direccion:word;valor:byte);
begin
case direccion of
  0..$10ff:memoria[direccion]:=valor;
  $2000..$2fff:if memoria[direccion]<>valor then begin
                  gfx[0].buffer[direccion and $7ff]:=true;
                  memoria[direccion]:=valor;
               end;
  $3002:begin
           sound_latch:=valor;
           m6809_0.change_irq(ASSERT_LINE);
        end;
  $3004:scroll_x_temp:=(scroll_x_temp and $100) or valor;
  $3005:m6800_0.change_nmi(PULSE_LINE);
  $3006:begin
            main_screen.flip_main_screen:=(valor and $1)<>0;
            nrom_bank:=(not(valor) and 2) shr 1;
            scroll_x_temp:=(scroll_x_temp and $ff) or ((valor and 4) shl 6);
            if tile_pal<>(valor and $30) shr 4 then begin
              tile_pal:=(valor and $30) shr 4;
              fillchar(gfx[0].buffer,$800,1);
            end;
            sprite_pal:=(valor and $c0) shr 6;
        end;
  $3800:mcu_latch:=valor;
  $4000..$ffff:; //ROM
end;
end;

function getbyte_snd_sdodgeball(direccion:word):byte;
begin
  case direccion of
    0..$fff,$8000..$ffff:getbyte_snd_sdodgeball:=mem_snd[direccion];
    $1000:begin
            getbyte_snd_sdodgeball:=sound_latch;
            m6809_0.change_irq(CLEAR_LINE);
          end;
  end;
end;

procedure putbyte_snd_sdodgeball(direccion:word;valor:byte);
begin
case direccion of
  0..$fff:mem_snd[direccion]:=valor;
  $2800:ym3812_0.control(valor);
  $2801:ym3812_0.write(valor);
  $3800:msm5205_0.reset_w(0);
  $3801:msm5205_1.reset_w(0);
  $3802:adpcm_end[0]:=(valor and $7f)*$200;
  $3803:adpcm_end[1]:=(valor and $7f)*$200;
  $3804:adpcm_pos[0]:=(valor and $7f)*$200;
  $3805:adpcm_pos[1]:=(valor and $7f)*$200;
  $3806:msm5205_0.reset_w(1);
  $3807:msm5205_1.reset_w(1);
  $8000..$ffff:;
end;
end;

procedure msm5205_sound1;
begin
if ((adpcm_pos[0]>=adpcm_end[0]) or (adpcm_pos[0]>=$10000)) then begin
		msm5205_0.reset_w(1);
	end	else if (adpcm_data[0]<>-1) then begin
		        msm5205_0.data_w(adpcm_data[0] and $0f);
		        adpcm_data[0]:=-1;
           end else begin
		                  adpcm_data[0]:=adpcm_rom[0,adpcm_pos[0]];
                      adpcm_pos[0]:=adpcm_pos[0]+1;
		                  msm5205_0.data_w(adpcm_data[0] shr 4);
                    end;
end;

procedure msm5205_sound2;
begin
if ((adpcm_pos[1]>=adpcm_end[1]) or (adpcm_pos[1]>=$10000)) then begin
		msm5205_1.reset_w(1);
	end	else if (adpcm_data[1]<>-1) then begin
		        msm5205_1.data_w(adpcm_data[1] and $0f);
		        adpcm_data[1]:=-1;
           end else begin
		                  adpcm_data[1]:=adpcm_rom[1,adpcm_pos[1]];
                      adpcm_pos[1]:=adpcm_pos[1]+1;
		                  msm5205_1.data_w(adpcm_data[1] shr 4);
                    end;

end;

procedure sdodgeball_sound_update;
begin
  ym3812_0.update;
end;

//MCU
function sdodgeball_mcu_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$27:sdodgeball_mcu_getbyte:=m6800_0.hd6301y_internal_reg_r(direccion);
  $40..$13f,$c000..$ffff:sdodgeball_mcu_getbyte:=mem_misc[direccion];
  $8080:sdodgeball_mcu_getbyte:=mcu_latch;
end;
end;

procedure sdodgeball_mcu_putbyte(direccion:word;valor:byte);
begin
case direccion of
  $0..$27:m6800_0.hd6301y_internal_reg_w(direccion,valor);
  $40..$13f:mem_misc[direccion]:=valor;
  $8081..$8085:inputs[direccion-$8081]:=valor;
  $c000..$ffff:;
end;
end;

procedure snd_irq(irqstate:byte);
begin
  m6809_0.change_firq(irqstate);
end;

function sdodgeball_r2:byte;
begin
  sdodgeball_r2:=marcade.in0;
end;

function sdodgeball_r5:byte;
begin
    sdodgeball_r5:=marcade.in1;
end;

function sdodgeball_r6:byte;
begin
  sdodgeball_r6:=marcade.dswc;
end;

procedure sdodgeball_w5(valor:byte);
begin
  marcade.dswa:=(marcade.dswa and $fd) or ((valor and $80) shr 6);
end;

//Main
procedure reset_sdodgeball;
begin
m6502_0.reset;
m6809_0.reset;
m6800_0.reset;
ym3812_0.reset;
msm5205_0.reset;
msm5205_1.reset;
marcade.in0:=$ff;
marcade.in1:=$ff;
nrom_bank:=0;
fillchar(inputs[0],5,0);
scroll_x_temp:=0;
tile_pal:=0;
sprite_pal:=0;
mcu_latch:=0;
fillword(@scroll_x[0],272,0);
adpcm_pos[0]:=0;
adpcm_pos[1]:=0;
adpcm_end[0]:=0;
adpcm_end[1]:=0;
adpcm_data[0]:=0;
adpcm_data[1]:=0;
end;

function iniciar_sdodgeball:boolean;
const
    pc_x:array[0..7] of dword=(1, 0, 64+1, 64+0, 128+1, 128+0, 192+1, 192+0);
    ps_x:array[0..15] of dword=(3, 2, 1, 0, 16*8+3, 16*8+2, 16*8+1, 16*8+0,
			32*8+3, 32*8+2, 32*8+1, 32*8+0, 48*8+3, 48*8+2, 48*8+1, 48*8+0);
    ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8);
var
  colores:tpaleta;
  bit0,bit1,bit2,bit3:byte;
  f:word;
  memoria_temp:array[0..$3ffff] of byte;
begin
llamadas_maquina.bucle_general:=principal_sdodgeball;
llamadas_maquina.reset:=reset_sdodgeball;
llamadas_maquina.fps_max:=12000000/2/384/272;
iniciar_sdodgeball:=false;
iniciar_audio(true); //Stereo!
screen_init(1,512,256);
screen_mod_scroll(1,512,256,511,512,256,511);
screen_init(2,512,256,false,true);
iniciar_video(256,240);
//Main CPU
m6502_0:=cpu_m6502.create(12000000 div 6,272,TCPU_M6502);
m6502_0.change_ram_calls(getbyte_sdodgeball,putbyte_sdodgeball);
if not(roms_load(@memoria_temp,sdodgeball_rom)) then exit;
copymemory(@memoria[$8000],@memoria_temp[$8000],$8000);
copymemory(@rom_bank[0,0],@memoria_temp[0],$4000);
copymemory(@rom_bank[1,0],@memoria_temp[$4000],$4000);
//Sound CPU
m6809_0:=cpu_m6809.Create(12000000 div 2,272,TCPU_MC6809);
m6809_0.change_ram_calls(getbyte_snd_sdodgeball,putbyte_snd_sdodgeball);
m6809_0.init_sound(sdodgeball_sound_update);
if not(roms_load(@mem_snd,sdodgeball_snd)) then exit;
//MCU CPU
m6800_0:=cpu_m6800.create(4000000,272,TCPU_HD63701);
m6800_0.change_ram_calls(sdodgeball_mcu_getbyte,sdodgeball_mcu_putbyte);
m6800_0.change_io_calls(nil,sdodgeball_r2,nil,nil,nil,nil,nil,nil);
m6800_0.change_iox_calls(sdodgeball_r5,sdodgeball_r6,sdodgeball_w5,nil);
if not(roms_load(@mem_misc,sdodgeball_mcu)) then exit;
//Sound Chip
ym3812_0:=ym3812_chip.create(YM3812_FM,3000000,0.6);
ym3812_0.change_irq_calls(snd_irq);
msm5205_0:=MSM5205_chip.create(384000,MSM5205_S48_4B,0.5,msm5205_sound1);
msm5205_1:=MSM5205_chip.create(384000,MSM5205_S48_4B,0.5,msm5205_sound2);
if not(roms_load(@memoria_temp,sdodgeball_adpcm)) then exit;
copymemory(@adpcm_rom[0,0],@memoria_temp[0],$10000);
copymemory(@adpcm_rom[1,0],@memoria_temp[$10000],$10000);
//Cargar chars
if not(roms_load(@memoria_temp,sdodgeball_char)) then exit;
init_gfx(0,8,8,$2000);
gfx[0].trans[0]:=true;
gfx_set_desc_data(4,0,32*8,0,2,4,6);
convert_gfx(0,0,@memoria_temp,@pc_x,@ps_y,false,false);
//sprites
if not(roms_load(@memoria_temp,sdodgeball_sprites)) then exit;
init_gfx(1,16,16,$800);
gfx[1].trans[0]:=true;
gfx_set_desc_data(4,0,64*8,$800*8*64,$800*8*64+4,0,4);
convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,false);
//Paleta
if not(roms_load(@memoria_temp,sdodgeball_proms)) then exit;
for f:=0 to $3ff do begin
  bit0:=(memoria_temp[f] shr 0) and 1;
  bit1:=(memoria_temp[f] shr 1) and 1;
  bit2:=(memoria_temp[f] shr 2) and 1;
  bit3:=(memoria_temp[f] shr 3) and 1;
  colores[f].r:=$0e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
  bit0:=(memoria_temp[f] shr 4) and 1;
  bit1:=(memoria_temp[f] shr 5) and 1;
  bit2:=(memoria_temp[f] shr 6) and 1;
  bit3:=(memoria_temp[f] shr 7) and 1;
  colores[f].g:=$0e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
  bit0:=(memoria_temp[f+$400] shr 0) and 1;
  bit1:=(memoria_temp[f+$400] shr 1) and 1;
  bit2:=(memoria_temp[f+$400] shr 2) and 1;
  bit3:=(memoria_temp[f+$400] shr 3) and 1;
  colores[f].b:=$0e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
end;
set_pal(colores,$400);
//DIP
marcade.dswa:=$fc;
marcade.dswa_val:=@sdodgeball_dip_a;
marcade.dswb:=$ff;
marcade.dswb_val:=@sdodgeball_dip_b;
marcade.dswc:=$ff;
marcade.dswc_val:=@sdodgeball_dip_c;
//final
reset_sdodgeball;
iniciar_sdodgeball:=true;
end;

end.
