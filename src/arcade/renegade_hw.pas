unit renegade_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6502,m6809,main_engine,controls_engine,gfx_engine,ym_3812,rom_engine,
     pal_engine,sound_engine,msm5205,taito_68705;

function iniciar_renegade:boolean;

implementation
const
        renegade_rom:array[0..1] of tipo_roms=(
        (n:'na-5.ic52';l:$8000;p:0;crc:$de7e7df4),(n:'nb-5.ic51';l:$8000;p:$8000;crc:$ba683ddf));
        renegade_char:tipo_roms=(n:'nc-5.bin';l:$8000;p:0;crc:$9adfaa5d);
        renegade_snd:tipo_roms=(n:'n0-5.ic13';l:$8000;p:$8000;crc:$3587de3b);
        renegade_mcu:tipo_roms=(n:'nz-5.ic97';l:$800;p:0;crc:$32e47560);
        renegade_tiles:array[0..5] of tipo_roms=(
        (n:'n1-5.ic1';l:$8000;p:0;crc:$4a9f47f3),(n:'n6-5.ic28';l:$8000;p:$8000;crc:$d62a0aa8),
        (n:'n7-5.ic27';l:$8000;p:$10000;crc:$7ca5a532),(n:'n2-5.ic14';l:$8000;p:$18000;crc:$8d2e7982),
        (n:'n8-5.ic26';l:$8000;p:$20000;crc:$0dba31d3),(n:'n9-5.ic25';l:$8000;p:$28000;crc:$5b621b6a));
        renegade_sprites:array[0..11] of tipo_roms=(
        (n:'nh-5.bin';l:$8000;p:0;crc:$dcd7857c),(n:'nd-5.bin';l:$8000;p:$8000;crc:$2de1717c),
        (n:'nj-5.bin';l:$8000;p:$10000;crc:$0f96a18e),(n:'nn-5.bin';l:$8000;p:$18000;crc:$1bf15787),
        (n:'ne-5.bin';l:$8000;p:$20000;crc:$924c7388),(n:'nk-5.bin';l:$8000;p:$28000;crc:$69499a94),
        (n:'ni-5.bin';l:$8000;p:$30000;crc:$6f597ed2),(n:'nf-5.bin';l:$8000;p:$38000;crc:$0efc8d45),
        (n:'nl-5.bin';l:$8000;p:$40000;crc:$14778336),(n:'no-5.bin';l:$8000;p:$48000;crc:$147dd23b),
        (n:'ng-5.bin';l:$8000;p:$50000;crc:$a8ee3720),(n:'nm-5.bin';l:$8000;p:$58000;crc:$c100258e));
        renegade_adpcm:array[0..2] of tipo_roms=(
        (n:'n3-5.ic33';l:$8000;p:0;crc:$78fd6190),(n:'n4-5.ic32';l:$8000;p:$8000;crc:$6557564c),
        (n:'n5-5.ic31';l:$8000;p:$10000;crc:$7ee43a3c));
        //Dip
        renegade_dip_a:array [0..5] of def_dip2=(
        (mask:3;name:'Coin A';number:4;val4:(0,3,2,1);name4:('2C 1C','1C 1C','1C 2C','1C 3C')),
        (mask:$c;name:'Coin B';number:4;val4:(0,$c,8,4);name4:('2C 1C','1C 1C','1C 2C','1C 3C')),
        (mask:$10;name:'Lives';number:2;val2:($10,0);name2:('1','2')),
        (mask:$20;name:'Bonus';number:2;val2:($20,0);name2:('30K','None')),
        (mask:$40;name:'Cabinet';number:2;val2:(0,$40);name2:('Upright','Cocktail')),
        (mask:$80;name:'Flip Screen';number:2;val2:($80,0);name2:('Off','On')));
        renegade_dip_b:def_dip2=(mask:3;name:'Difficulty';number:4;val4:(2,3,1,0);name4:('Easy','Normal','Hard','Very Hard'));

var
  rom_mem:array[0..1,0..$3fff] of byte;
  rom_bank,sound_latch:byte;
  scroll_comp,scroll_x:word;

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
    nchar:=memoria[$2800+f]+((atrib and 7) shl 8);
    put_gfx_trans(x*16,y*16,nchar,(color shl 3)+192,1,1);
    gfx[1].buffer[f]:=false;
  end;
  //Foreground
  atrib:=memoria[$1c00+f];
  color:=atrib shr 6;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
    x:=f mod 32;
    y:=f div 32;
    nchar:=memoria[$1800+f]+((atrib and 3) shl 8);
    put_gfx_trans(x*8,y*8,nchar,color shl 3,2,0);
    gfx[0].buffer[f]:=false;
  end;
end;
scroll__x(1,3,(scroll_x-scroll_comp) and $3ff);
for f:=0 to $7f do begin
  y:=224-memoria[$2000+(f*4)];
  if y>=16 then begin
    atrib:=memoria[$2001+(f*4)];
    x:=memoria[$2003+(f*4)];
    nchar:=memoria[$2002+(f*4)]+((atrib and $f) shl 8);
    color:=((atrib and $30) shr 1)+128;
    flip_x:=(atrib and $40)<>0;
    if (atrib and $80)<>0 then begin
      nchar:=nchar and $ffe;
      put_gfx_sprite_diff(nchar or 1,color,flip_x,false,2,0,16);
      put_gfx_sprite_diff(nchar,color,flip_x,false,2,0,0);
      actualiza_gfx_sprite_size(x,y,3,16,32);
    end else begin
      put_gfx_sprite(nchar,color,flip_x,false,2);
      actualiza_gfx_sprite(x,y+16,3,2);
    end;
  end;
end;
actualiza_trozo(0,0,256,256,2,0,0,256,256,3);
actualiza_trozo_final(0,9,256,238,3);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
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
  //but
  if arcade_input.but2[0] then marcade.dswb:=marcade.dswb and $fb else marcade.dswb:=marcade.dswb or 4;
  if arcade_input.but2[1] then marcade.dswb:=marcade.dswb and $f7 else marcade.dswb:=marcade.dswb or 8;
end;
end;

procedure principal_renegade;
var
  f:word;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
 for f:=0 to 271 do begin
   case f of
      16,40,56,72,88,104,120,136,152,168,184,200,216,232,248,264:m6502_0.change_irq(ASSERT_LINE);
      19:marcade.dswb:=marcade.dswb and $bf;
      257:begin
            update_video_renegade;
            marcade.dswb:=marcade.dswb or $40;
          end;
      265:m6502_0.change_nmi(ASSERT_LINE);
   end;
   m6502_0.run(frame_main);
   frame_main:=frame_main+m6502_0.tframes-m6502_0.contador;
   //Sound
   m6809_0.run(frame_snd);
   frame_snd:=frame_snd+m6809_0.tframes-m6809_0.contador;
   //mcu
   taito_68705_0.run;
 end;
 eventos_renegade;
 video_sync;
end;
end;

function getbyte_renegade(direccion:word):byte;
begin
case direccion of
   0..$1fff,$2800..$2fff,$8000..$ffff:getbyte_renegade:=memoria[direccion];
   $2000..$27ff:getbyte_renegade:=memoria[$2000+(direccion and $1ff)];
   $3000..$31ff:getbyte_renegade:=buffer_paleta[direccion and $1ff];
   $3800:getbyte_renegade:=marcade.in0;
   $3801:getbyte_renegade:=marcade.in1;
   $3802:getbyte_renegade:=marcade.dswb or (byte(not(taito_68705_0.main_sent)) shl 4) or (byte(not(taito_68705_0.mcu_sent)) shl 5);
   $3803:getbyte_renegade:=marcade.dswa;
   $3804:getbyte_renegade:=taito_68705_0.read;
   $3805:taito_68705_0.change_reset(PULSE_LINE);
   $4000..$7fff:getbyte_renegade:=rom_mem[rom_bank,direccion and $3fff];
end;
end;

procedure putbyte_renegade(direccion:word;valor:byte);

procedure cambiar_color(dir:byte);
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
    0..$1f:buffer_color[dir shr 3]:=true;
    $c0..$ff:buffer_color[((dir shr 3) and 7)+4]:=true;
  end;
end;

begin
case direccion of
  0..$17ff:memoria[direccion]:=valor;
  $1800..$1fff:if memoria[direccion]<>valor then begin
                gfx[0].buffer[direccion and $3ff]:=true;
                memoria[direccion]:=valor;
             end;
  $2000..$27ff:memoria[$2000+(direccion and $1ff)]:=valor;
  $2800..$2fff:if memoria[direccion]<>valor then begin
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
          m6809_0.change_irq(ASSERT_LINE);
        end;
  $3803:if ((valor and 1)=0) then begin
            scroll_comp:=0;
            main_screen.flip_main_screen:=true;
        end else begin
            scroll_comp:=256;
            main_screen.flip_main_screen:=false;
        end;
  $3804:taito_68705_0.write(valor);
  $3805:rom_bank:=valor and 1;
  $3806:m6502_0.change_nmi(CLEAR_LINE);
  $3807:m6502_0.change_irq(CLEAR_LINE);
  $4000..$ffff:; //ROM
end;
end;

function getbyte_snd_renegade(direccion:word):byte;
begin
  case direccion of
    0..$fff,$8000..$ffff:getbyte_snd_renegade:=mem_snd[direccion];
    $1000:begin
            getbyte_snd_renegade:=sound_latch;
            m6809_0.change_irq(CLEAR_LINE);
          end;
    $2800:getbyte_snd_renegade:=ym3812_0.status;
  end;
end;

procedure putbyte_snd_renegade(direccion:word;valor:byte);
begin
case direccion of
  0..$fff:mem_snd[direccion]:=valor;
  $1800:msm5205_0.reset_w(false); //adpcm start
  $2000:begin //adpcm addr
           case (valor and  $1c) of
		          $c:msm5205_0.pos:=2*$8000*2;    // 011 -> ic31
		          $14:msm5205_0.pos:=1*$8000*2;    // 101 -> ic32
              $18:msm5205_0.pos:=0*$8000*2;    // 110 -> ic33
              else begin
                msm5205_0.pos:=0;
                msm5205_0.end_:=0;
                exit;
              end;
           end;
	         // bits 0-1 are a13-a14
           msm5205_0.pos:=msm5205_0.pos or ((valor and 3)*$2000*2);
	         // a0-a12 are driven by a binary counter; playback ends when it rolls over
	         msm5205_0.end_:=msm5205_0.pos+$2000*2;
        end;
  $2800:ym3812_0.control(valor);
  $2801:ym3812_0.write(valor);
  $3000:msm5205_0.reset_w(true); //adpcm stop
  $8000..$ffff:; //ROM
end;
end;

procedure renegade_sound_update;
begin
  ym3812_0.update;
  msm5205_0.update;
end;

procedure snd_irq(irqstate:byte);
begin
  m6809_0.change_firq(irqstate);
end;

procedure snd_adpcm;
var
  data:byte;
begin
  if msm5205_0.idle then exit;
  if (msm5205_0.pos>=msm5205_0.end_) then begin
    msm5205_0.reset_w(true);
    m6809_0.change_nmi(PULSE_LINE);
	end else begin
		data:=msm5205_0.rom_data[msm5205_0.pos shr 1];
    if (msm5205_0.pos and 1)<>0 then msm5205_0.data_w(data and $f)
      else msm5205_0.data_w(data shr 4);
		msm5205_0.pos:=msm5205_0.pos+1;
	end;
end;

//Main
procedure reset_renegade;
begin
m6502_0.reset;
m6809_0.reset;
taito_68705_0.reset;
frame_main:=m6502_0.tframes;
frame_snd:=m6809_0.tframes;
ym3812_0.reset;
msm5205_0.reset;
marcade.in0:=$ff;
marcade.in1:=$ff;
rom_bank:=0;
sound_latch:=0;
scroll_x:=0;
scroll_comp:=256;
end;

function iniciar_renegade:boolean;
const
    pc_x:array[0..7] of dword=(1, 0, 65, 64, 129, 128, 193, 192);
    pt_x:array[0..15] of dword=(3, 2, 1, 0, 16*8+3, 16*8+2, 16*8+1, 16*8+0,
		32*8+3,32*8+2 ,32*8+1 ,32*8+0 ,48*8+3 ,48*8+2 ,48*8+1 ,48*8+0);
    pt_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
		8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8);
var
  f:byte;
  memoria_temp:array[0..$5ffff] of byte;
begin
llamadas_maquina.bucle_general:=principal_renegade;
llamadas_maquina.reset:=reset_renegade;
llamadas_maquina.fps_max:=57.444853;
llamadas_maquina.scanlines:=272;
iniciar_renegade:=false;
iniciar_audio(false);
screen_init(1,1024,256);
screen_init(2,256,256,true);
screen_init(3,256,256,false,true);
iniciar_video(256,238);
//Main CPU
m6502_0:=cpu_m6502.create(1500000,TCPU_M6502);
m6502_0.change_ram_calls(getbyte_renegade,putbyte_renegade);
if not(roms_load(@memoria_temp,renegade_rom)) then exit;
copymemory(@memoria[$8000],@memoria_temp[$8000],$8000);
copymemory(@rom_mem[0,0],@memoria_temp[0],$4000);
copymemory(@rom_mem[1,0],@memoria_temp[$4000],$4000);
//Sound CPU
m6809_0:=cpu_m6809.Create(1500000,TCPU_M6809);
m6809_0.change_ram_calls(getbyte_snd_renegade,putbyte_snd_renegade);
m6809_0.init_sound(renegade_sound_update);
if not(roms_load(@mem_snd,renegade_snd)) then exit;
//MCU CPU
taito_68705_0:=taito_68705p.create(3000000);
if not(roms_load(taito_68705_0.get_rom_addr,renegade_mcu)) then exit;
//Sound Chip
ym3812_0:=ym3812_chip.create(YM3526_FM,3000000);
ym3812_0.change_irq_calls(snd_irq);
msm5205_0:=MSM5205_chip.create(12000000 div 32,MSM5205_S48_4B,1,$18000);
msm5205_0.change_advance(snd_adpcm);
if not(roms_load(msm5205_0.rom_data,renegade_adpcm)) then exit;
//Cargar chars
if not(roms_load(@memoria_temp,renegade_char)) then exit;
init_gfx(0,8,8,$400);
gfx[0].trans[0]:=true;
gfx_set_desc_data(3,0,32*8,2,4,6);
convert_gfx(0,0,@memoria_temp,@pc_x,@pt_y,false,false);
//Cargar tiles
if not(roms_load(@memoria_temp,renegade_tiles)) then exit;
init_gfx(1,16,16,$800);
for f:=0 to 1 do begin
  gfx_set_desc_data(3,8,64*8,4,$8000*8+0,$8000*8+4);
  convert_gfx(1,f*$400*16*16,@memoria_temp[f*$18000],@pt_x,@pt_y,false,false);
  gfx_set_desc_data(3,8,64*8,0,$c000*8+0,$c000*8+4);
  convert_gfx(1,(f*$400*16*16)+($100*16*16),@memoria_temp[f*$18000],@pt_x,@pt_y,false,false);
  gfx_set_desc_data(3,8,64*8,$4000*8+4,$10000*8+0,$10000*8+4);
  convert_gfx(1,(f*$400*16*16)+($200*16*16),@memoria_temp[f*$18000],@pt_x,@pt_y,false,false);
  gfx_set_desc_data(3,8,64*8,$4000*8+0,$14000*8+0,$14000*8+4);
  convert_gfx(1,(f*$400*16*16)+($300*16*16),@memoria_temp[f*$18000],@pt_x,@pt_y,false,false);
end;
//sprites
if not(roms_load(@memoria_temp,renegade_sprites)) then exit;
init_gfx(2,16,16,$1000);
gfx[2].trans[0]:=true;
for f:=0 to 3 do begin
  gfx_set_desc_data(3,16,64*8,4,$8000*8+0,$8000*8+4);
  convert_gfx(2,f*$400*16*16,@memoria_temp[f*$18000],@pt_x,@pt_y,false,false);
  gfx_set_desc_data(3,16,64*8,0,$c000*8+0,$c000*8+4);
  convert_gfx(2,(f*$400*16*16)+($100*16*16),@memoria_temp[f*$18000],@pt_x,@pt_y,false,false);
  gfx_set_desc_data(3,16,64*8,$4000*8+4,$10000*8+0,$10000*8+4);
  convert_gfx(2,(f*$400*16*16)+($200*16*16),@memoria_temp[f*$18000],@pt_x,@pt_y,false,false);
  gfx_set_desc_data(3,16,64*8,$4000*8+0,$14000*8+0,$14000*8+4);
  convert_gfx(2,(f*$400*16*16)+($300*16*16),@memoria_temp[f*$18000],@pt_x,@pt_y,false,false);
end;
//Dip
init_dips(1,renegade_dip_a,$bf);
init_dips(2,renegade_dip_b,$8f);
//final
reset_renegade;
iniciar_renegade:=true;
end;

end.
