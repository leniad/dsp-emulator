unit legendkage_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,gfx_engine,ym_2203,rom_engine,
     pal_engine,sound_engine,taito_68705;

function iniciar_lk_hw:boolean;

implementation
const
        lk_rom:array[0..1] of tipo_roms=(
        (n:'a54-01-2.37';l:$8000;p:0;crc:$60fd9734),(n:'a54-02-2.38';l:$8000;p:$8000;crc:$878a25ce));
        lk_snd:tipo_roms=(n:'a54-04.54';l:$8000;p:0;crc:$541faf9a);
        lk_mcu:tipo_roms=(n:'a54-09.53';l:$800;p:0;crc:$0e8b8846);
        lk_data:tipo_roms=(n:'a54-03.51';l:$4000;p:0;crc:$493e76d8);
        lk_char:array[0..3] of tipo_roms=(
        (n:'a54-05-1.84';l:$4000;p:0;crc:$0033c06a),(n:'a54-06-1.85';l:$4000;p:$4000;crc:$9f04d9ad),
        (n:'a54-07-1.86';l:$4000;p:$8000;crc:$b20561a4),(n:'a54-08-1.87';l:$4000;p:$c000;crc:$3ff3b230));
        //Dip
        lk_dip_a:array [0..5] of def_dip2=(
        (mask:3;name:'Bonus Life';number:4;val4:(3,2,1,0);name4:('200K 700K 500K+','200K 900K 700K+','300K 1000K 700K+','300K 1300K 1000K+')),
        (mask:4;name:'Free Play';number:2;val2:(4,0);name2:('Off','On')),
        (mask:$18;name:'Lives';number:4;val4:($18,$10,8,0);name4:('3','4','5','255')),
        (mask:$40;name:'Flip Screen';number:2;val2:($40,0);name2:('Off','On')),
        (mask:$80;name:'Cabinet';number:2;val2:(0,$80);name2:('Upright','Cocktail')),());
        lk_dip_b:array [0..2] of def_dip2=(
        (mask:$f;name:'Coin A';number:16;val16:($f,$e,$d,$c,$b,$a,9,8,0,1,2,3,4,5,6,7);name16:('9C 1C','8C 1C','7C 1C','6C 1C','5C 1C','4C 1C','3C 1C','2C 1C','1C 1C','1C 2C','1C 3C','1C 4C','1C 5C','1C 6C','1C 7C','1C 8C')),
        (mask:$f0;name:'Coin B';number:16;val16:($f0,$e0,$d0,$c0,$b0,$a0,$90,$80,0,$10,$20,$30,$40,$50,$60,$70);name16:('9C 1C','8C 1C','7C 1C','6C 1C','5C 1C','4C 1C','3C 1C','2C 1C','1C 1C','1C 2C','1C 3C','1C 4C','1C 5C','1C 6C','1C 7C','1C 8C')),());
        lk_dip_c:array [0..6] of def_dip2=(
        (mask:2;name:'Initial Season';number:2;val2:(2,0);name2:('Spring','Winter')),
        (mask:8;name:'Difficulty';number:2;val2:(8,0);name2:('Easy','Normal')),
        (mask:$10;name:'Coinage Display';number:2;val2:(0,$10);name2:('No','Yes')),
        (mask:$20;name:'Year Display';number:2;val2:(0,$20);name2:('1985','MCMLXXXIV')),
        (mask:$40;name:'Invulnerability (Cheat)';number:2;val2:($40,0);name2:('Off','On')),
        (mask:$80;name:'Coin Slots';number:2;val2:(0,$80);name2:('1','2')),());

var
 scroll_val:array[0..5] of byte;
 mem_data:array[0..$3fff] of byte;
 sound_latch,color_bnk:byte;
 bg_bank,fg_bank:word;
 snd_nmi,pant_enable,prioridad_fg:boolean;

procedure update_video_lk_hw;
procedure draw_sprites(prio:byte);
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
  		flipx:=(atrib and 1)<>0;
  		flipy:=(atrib and 2)<>0;
  		x:=memoria[$f100+(f*4)]-15;
  		y:=240-memoria[$f101+(f*4)];
  		nchar:=memoria[$f103+(f*4)]+((atrib and 4) shl 6);
      if (atrib and 8)<>0 then begin  //x2
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
var
  x,y:byte;
  f,nchar:word;
begin
for f:=0 to $3ff do begin
  x:=f mod 32;
  y:=f div 32;
  //char
  if gfx[0].buffer[f] then begin
    nchar:=memoria[$f400+f];
    put_gfx_trans(x*8,y*8,nchar,$110,1,0);
    gfx[0].buffer[f]:=false;
  end;
  if pant_enable then begin
    //BG
    if gfx[0].buffer[$400+f] then begin
      nchar:=memoria[$fc00+f]+bg_bank;
      put_gfx(x*8,y*8,nchar,$300+color_bnk,2,0);
      gfx[0].buffer[$400+f]:=false;
    end;
    //FG
    if gfx[0].buffer[$800+f] then begin
      nchar:=memoria[$f800+f]+fg_bank;
      put_gfx_trans(x*8,y*8,nchar,$200+color_bnk,3,0);
      gfx[0].buffer[$800+f]:=false;
    end;
  end;
end;
if pant_enable then scroll_x_y(2,4,scroll_val[4]+5,scroll_val[5])
  else fill_full_screen(4,$400);
if prioridad_fg then begin
  draw_sprites($80);
  if pant_enable then scroll_x_y(3,4,scroll_val[2]+3,scroll_val[3]);
  draw_sprites(0);
end else begin
  draw_sprites(0);
  if pant_enable then scroll_x_y(3,4,scroll_val[2]+3,scroll_val[3]);
  draw_sprites($80);
end;
scroll_x_y(1,4,scroll_val[0]+1,scroll_val[1]);
actualiza_trozo_final(16,16,240,224,4);
end;

procedure eventos_lk_hw;
begin
if event.arcade then begin
  //P1
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or 8);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  //P2
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or 1);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or 2);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or 4);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or 8);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  //SYS
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 or $10) else marcade.in0:=(marcade.in0 and $ef);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 or $20) else marcade.in0:=(marcade.in0 and $df);
end;
end;

procedure lk_hw_principal;
var
  f:byte;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
  for f:=0 to $ff do begin
    if f=240 then begin
      z80_0.change_irq(HOLD_LINE);
      update_video_lk_hw;
    end;
    //Main CPU
    z80_0.run(frame_main);
    frame_main:=frame_main+z80_0.tframes-z80_0.contador;
    //Sound CPU
    z80_1.run(frame_snd);
    frame_snd:=frame_snd+z80_1.tframes-z80_1.contador;
    //MCU CPU
    taito_68705_0.run;
  end;
  eventos_lk_hw;
  video_sync;
end;
end;

function lk_getbyte(direccion:word):byte;
begin
case direccion of
  0..$e7ff,$f000..$f003,$f0a0..$f0a3,$f400..$ffff:lk_getbyte:=memoria[direccion];
  $e800..$efff:lk_getbyte:=buffer_paleta[direccion and $7ff];
  $f061:lk_getbyte:=$ff;
  $f062:lk_getbyte:=taito_68705_0.read;
  $f080:lk_getbyte:=marcade.dswa;
  $f081:lk_getbyte:=marcade.dswb;
  $f082:lk_getbyte:=marcade.dswc;
  $f083:lk_getbyte:=marcade.in0;
  $f084:lk_getbyte:=marcade.in1;
  $f086:lk_getbyte:=marcade.in2;
  $f087:lk_getbyte:=byte(not(taito_68705_0.main_sent)) or (byte(taito_68705_0.mcu_sent) shl 1);
  $f0c0..$f0c5:lk_getbyte:=scroll_val[direccion and 7];
end;
end;

procedure lk_putbyte(direccion:word;valor:byte);
var
  bank:word;

procedure cambiar_color(pos:word);
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

begin
case direccion of
  0..$dfff:;
  $e000..$e7ff,$f0a0..$f0a3,$f100..$f15f:memoria[direccion]:=valor;
  $e800..$efff:if buffer_paleta[direccion and $7ff]<>valor then begin
                  buffer_paleta[direccion and $7ff]:=valor;
                  cambiar_color(direccion and $7fe);
               end;
  $f000..$f003:begin
                  memoria[direccion]:=valor;
                  case (direccion and 3) of
                    0:begin
                        bank:=(valor and 4) shl 6;
                        if fg_bank<>bank then begin
                          fg_bank:=bank;
                          fillchar(gfx[0].buffer[$800],$400,1);
                        end;
                      end;
                    1:begin
                        prioridad_fg:=(valor and 2)<>0;
                        if (valor and 8)<>0 then bank:=$100*5
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
                    2:pant_enable:=(valor and $f0)=$f0;
                  end;
               end;
  $f060:if not(snd_nmi) then begin
          sound_latch:=valor;
          z80_1.change_nmi(ASSERT_LINE);
          snd_nmi:=true;
        end;
  $f062:taito_68705_0.write(valor);
  $f0c0..$f0c5:scroll_val[direccion and 7]:=valor;
  $f400..$f7ff:if memoria[direccion]<>valor then begin
                  gfx[0].buffer[direccion and $3ff]:=true;
                  memoria[direccion]:=valor;
               end;
  $f800..$fbff:if memoria[direccion]<>valor then begin
                  gfx[0].buffer[$800+(direccion and $3ff)]:=true;
                  memoria[direccion]:=valor;
               end;
  $fc00..$ffff:if memoria[direccion]<>valor then begin
                  gfx[0].buffer[$400+(direccion and $3ff)]:=true;
                  memoria[direccion]:=valor;
               end;
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
  0..$87ff:snd_lk_hw_getbyte:=mem_snd[direccion];
  $9000:snd_lk_hw_getbyte:=ym2203_0.status;
  $9001:snd_lk_hw_getbyte:=ym2203_0.read;
  $a000:snd_lk_hw_getbyte:=ym2203_1.status;
  $a001:snd_lk_hw_getbyte:=ym2203_1.read;
  $b000:snd_lk_hw_getbyte:=sound_latch;
end;
end;

procedure snd_lk_hw_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:;
  $8000..$87ff:mem_snd[direccion]:=valor;
  $9000:ym2203_0.control(valor);
  $9001:ym2203_0.write(valor);
  $a000:ym2203_1.control(valor);
  $a001:ym2203_1.write(valor);
  $b002:begin
          z80_1.change_nmi(CLEAR_LINE);
          snd_nmi:=false;
        end;
end;
end;

procedure snd_irq(irqstate:byte);
begin
  z80_1.change_irq(irqstate);
end;

procedure lk_hw_sound_update;
begin
  ym2203_0.update;
  ym2203_1.update;
end;

//Main
procedure reset_lk_hw;
begin
 z80_0.reset;
 z80_1.reset;
 frame_main:=z80_0.tframes;
 frame_snd:=z80_1.tframes;
 taito_68705_0.reset;
 ym2203_0.reset;
 ym2203_1.reset;
 reset_video;
 reset_audio;
 fillchar(scroll_val[0],5,0);
 marcade.in0:=$b;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 sound_latch:=0;
 color_bnk:=0;
 pant_enable:=false;
 bg_bank:=0;
 fg_bank:=0;
 snd_nmi:=false;
 prioridad_fg:=false;
end;

function iniciar_lk_hw:boolean;
var
  memoria_temp:array[0..$ffff] of byte;
const
  ps_x:array[0..15] of dword=(7, 6, 5, 4, 3, 2, 1, 0,
    64+7, 64+6, 64+5, 64+4, 64+3, 64+2, 64+1, 64+0);
  ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
    128+0*8, 128+1*8, 128+2*8, 128+3*8, 128+4*8, 128+5*8, 128+6*8, 128+7*8);
begin
llamadas_maquina.bucle_general:=lk_hw_principal;
llamadas_maquina.reset:=reset_lk_hw;
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
z80_0:=cpu_z80.create(6000000,$100);
z80_0.change_ram_calls(lk_getbyte,lk_putbyte);
z80_0.change_io_calls(lk_inbyte,nil);
if not(roms_load(@memoria,lk_rom)) then exit;
//Sound CPU
z80_1:=cpu_z80.create(4000000,$100);
z80_1.change_ram_calls(snd_lk_hw_getbyte,snd_lk_hw_putbyte);
z80_1.init_sound(lk_hw_sound_update);
if not(roms_load(@mem_snd,lk_snd)) then exit;
//MCU CPU
taito_68705_0:=taito_68705p.create(3000000,$100);
if not(roms_load(taito_68705_0.get_rom_addr,lk_mcu)) then exit;
//Sound Chips
ym2203_0:=ym2203_chip.create(4000000);
ym2203_0.change_irq_calls(snd_irq);
ym2203_1:=ym2203_chip.create(4000000);
//cargar data
if not(roms_load(@mem_data,lk_data)) then exit;
//convertir chars
if not(roms_load(@memoria_temp,lk_char)) then exit;
init_gfx(0,8,8,$800);
gfx[0].trans[0]:=true;
gfx_set_desc_data(4,0,8*8,$800*8*8*1,$800*8*8*0,$800*8*8*3,$800*8*8*2);
convert_gfx(0,0,@memoria_temp,@ps_x,@ps_y,false,false);
//convertir sprites
init_gfx(1,16,16,$200);
gfx[1].trans[0]:=true;
gfx_set_desc_data(4,0,32*8,$200*32*8*1,$200*32*8*0,$200*32*8*3,$200*32*8*2);
convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,false);
//DIP
marcade.dswa:=$7f;
marcade.dswb:=0;
marcade.dswc:=$ff;
marcade.dswa_val2:=@lk_dip_a;
marcade.dswb_val2:=@lk_dip_b;
marcade.dswc_val2:=@lk_dip_c;
reset_lk_hw;
iniciar_lk_hw:=true;
end;

end.
