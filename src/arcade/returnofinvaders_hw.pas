unit returnofinvaders_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,gfx_engine,m6805,rom_engine,pal_engine,
     timer_engine,sound_engine,sn_76496,misc_functions;

procedure cargar_retofinv;

implementation
const
        retofinv_rom:array[0..2] of tipo_roms=(
        (n:'a37-03.70';l:$2000;p:$0;crc:$eae7459d),(n:'a37-02.71';l:$2000;p:$2000;crc:$72895e37),
        (n:'a37-01.72';l:$2000;p:$4000;crc:$505dd20b));
        retofinv_sub:tipo_roms=(n:'a37-04.62';l:$2000;p:$0;crc:$d2899cc1);
        retofinv_snd:tipo_roms=(n:'a37-05.17';l:$2000;p:$0;crc:$9025abea);
        retofinv_mcu:tipo_roms=(n:'a37-09.37';l:$800;p:$0;crc:$79bd6ded);
        retofinv_char:tipo_roms=(n:'a37-16.61';l:$2000;p:$0;crc:$4e3f501c);
        retofinv_tiles:array[0..1] of tipo_roms=(
        (n:'a37-14.55';l:$2000;p:0;crc:$ef7f8651),(n:'a37-15.56';l:$2000;p:$2000;crc:$03b40905));
        retofinv_sprites:array[0..3] of tipo_roms=(
        (n:'a37-10.8';l:$2000;p:$0;crc:$6afdeec8),(n:'a37-11.9';l:$2000;p:$2000;crc:$d3dc9da3),
        (n:'a37-12.10';l:$2000;p:$4000;crc:$d10b2eed),(n:'a37-13.11';l:$2000;p:$6000;crc:$00ca6b3d));
        retofinv_proms:array[0..3] of tipo_roms=(
        (n:'a37-06.13';l:$100;p:$0;crc:$e9643b8b),(n:'a37-07.4';l:$100;p:$100;crc:$e8f34e11),
        (n:'a37-08.3';l:$100;p:$200;crc:$50030af0),(n:'82s191n';l:$800;p:$300;crc:$93c891e3));
        //Dip
        retofinv_dip_a:array [0..5] of def_dip=(
        (mask:$3;name:'Bonus Life';number:4;dip:((dip_val:$3;dip_name:'30K 80K 80K+'),(dip_val:$2;dip_name:'30K 80K'),(dip_val:$1;dip_name:'30K'),(dip_val:$0;dip_name:'None'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Free Play';number:2;dip:((dip_val:$4;dip_name:'No'),(dip_val:$0;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$18;name:'Lives';number:4;dip:((dip_val:$18;dip_name:'1'),(dip_val:$10;dip_name:'2'),(dip_val:$8;dip_name:'3'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Flip Screen';number:2;dip:((dip_val:$40;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$80;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        retofinv_dip_b:array [0..2] of def_dip=(
        (mask:$0f;name:'Coin A';number:16;dip:((dip_val:$0f;dip_name:'9C 1C'),(dip_val:$0e;dip_name:'8C 1C'),(dip_val:$0d;dip_name:'7C 1C'),(dip_val:$0c;dip_name:'6C 1C'),(dip_val:$0b;dip_name:'5C 1C'),(dip_val:$0a;dip_name:'4C 1C'),(dip_val:$09;dip_name:'3C 1C'),(dip_val:$08;dip_name:'2C 1C'),(dip_val:$0;dip_name:'1C 1C'),(dip_val:$01;dip_name:'1C 2C'),(dip_val:$02;dip_name:'1C 3C'),(dip_val:$03;dip_name:'1C 4C'),(dip_val:$04;dip_name:'1C 5C'),(dip_val:$05;dip_name:'1C 6C'),(dip_val:$06;dip_name:'1C 7C'),(dip_val:$07;dip_name:'1C 8C'))),
        (mask:$f0;name:'Coin B';number:16;dip:((dip_val:$f0;dip_name:'9C 1C'),(dip_val:$e0;dip_name:'8C 1C'),(dip_val:$d0;dip_name:'7C 1C'),(dip_val:$c0;dip_name:'6C 1C'),(dip_val:$b0;dip_name:'5C 1C'),(dip_val:$a0;dip_name:'4C 1C'),(dip_val:$90;dip_name:'3C 1C'),(dip_val:$80;dip_name:'2C 1C'),(dip_val:$0;dip_name:'1C 1C'),(dip_val:$10;dip_name:'1C 2C'),(dip_val:$20;dip_name:'1C 3C'),(dip_val:$30;dip_name:'1C 4C'),(dip_val:$40;dip_name:'1C 5C'),(dip_val:$50;dip_name:'1C 6C'),(dip_val:$60;dip_name:'1C 7C'),(dip_val:$70;dip_name:'1C 8C'))),());
        retofinv_dip_c:array [0..5] of def_dip=(
        (mask:$1;name:'Push Start to Skip Stage';number:2;dip:((dip_val:$1;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Coin Per Play Display';number:2;dip:((dip_val:$0;dip_name:'No'),(dip_val:$10;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Year Display';number:2;dip:((dip_val:$0;dip_name:'No'),(dip_val:$20;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Invulnerability';number:2;dip:((dip_val:$40;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Coinage';number:2;dip:((dip_val:$80;dip_name:'A and B'),(dip_val:$0;dip_name:'A only'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
  mcu_mem:array[0..$7ff] of byte;
  sound_latch,sound_return,bg_bank,fg_bank:byte;
  port_c_in,port_c_out,port_b_out,port_b_in,port_a_in,port_a_out:byte;
  ddr_a,ddr_b,ddr_c,from_main,from_mcu:byte;
  main_vblank,sub_vblank,main_sent,mcu_sent:boolean;

procedure update_video_retofinv;
var
  f,nchar,x,y,offs,color:word;
  size_sprite,atrib,sx,sy:byte;
  flip_x,flip_y:boolean;
begin
for x:=0 to 27 do begin
  for y:=0 to 35 do begin
     sx:=29-x;
     sy:=y-2;
     if (sy and $20)<>0 then offs:=sx+((sy and $1f) shl 5)
        else offs:=sy+(sx shl 5);
     if gfx[0].buffer[offs] then begin
        color:=(memoria[$8400+offs]) shl 1;
        put_gfx_mask(x*8,y*8,memoria[$8000+offs]+(fg_bank shl 8),color,1,0,0,$ff);
        gfx[0].buffer[offs]:=false;
     end;
     if gfx[1].buffer[offs] then begin
        color:=((memoria[$a400+offs]) and $3f) shl 4;
        put_gfx(x*8,y*8,memoria[$a000+offs]+(bg_bank shl 8),$400+color,2,1);
        gfx[1].buffer[offs]:=false;
     end;
  end;
end;
actualiza_trozo(0,0,224,288,2,0,0,224,288,3);
for f:=0 to $3f do begin
    nchar:=memoria[$8f80+(f*2)];
    color:=(memoria[$8f81+(f*2)] and $3f) shl 4;
    atrib:=memoria[$9f80+(f*2)];
    x:=((memoria[$9780+(f*2)] shl 1)+((atrib and $80) shr 7))-15;
    y:=((memoria[$9781+(f*2)] shl 1)+((memoria[$9f81+(f*2)] and $80) shr 7))-39;
    flip_x:=(atrib and $2)<>0;
    flip_y:=(atrib and $1)<>0;
    size_sprite:=(atrib and $c) shr 2;
    nchar:=nchar and not(size_sprite);
    case size_sprite of
         0:begin //16x16
              put_gfx_sprite_mask(nchar,color,flip_x,flip_y,2,$ff,$ff);
              actualiza_gfx_sprite(x,y,3,2);
           end;
         1:begin //32x16
              put_gfx_sprite_mask_diff(nchar+2,color,flip_x,flip_y,2,$ff,$ff,0,0);
              put_gfx_sprite_mask_diff(nchar,color,flip_x,flip_y,2,$ff,$ff,16,0);
              actualiza_gfx_sprite_size(x,y,3,32,16);
           end;
         2:begin //16x32
              put_gfx_sprite_mask_diff(nchar,color,flip_x,flip_y,2,$ff,$ff,0,0);
              put_gfx_sprite_mask_diff(nchar+1,color,flip_x,flip_y,2,$ff,$ff,0,16);
              actualiza_gfx_sprite_size(x,y,3,16,32);
           end;
         3:begin //32x32;
              put_gfx_sprite_mask_diff(nchar+2,color,flip_x,flip_y,2,$ff,$ff,0,0);
              put_gfx_sprite_mask_diff(nchar,color,flip_x,flip_y,2,$ff,$ff,16,0);
              put_gfx_sprite_mask_diff(nchar+3,color,flip_x,flip_y,2,$ff,$ff,0,16);
              put_gfx_sprite_mask_diff(nchar+1,color,flip_x,flip_y,2,$ff,$ff,16,16);
              actualiza_gfx_sprite_size(x,y,3,32,32);
           end;
    end;
end;
actualiza_trozo(0,0,224,288,1,0,0,224,288,3);
actualiza_trozo_final(0,0,224,288,3);
end;

procedure eventos_retofinv;
begin
if event.arcade then begin
  //P1
  if arcade_input.left[0] then marcade.in0:=marcade.in0 and $fd else marcade.in0:=marcade.in0 or 2;
  if arcade_input.right[0] then marcade.in0:=marcade.in0 and $f7 else marcade.in0:=marcade.in0 or 8;
  if arcade_input.but0[0] then marcade.in0:=marcade.in0 and $7f else marcade.in0:=marcade.in0 or $80;
  //p2
  if arcade_input.left[1] then marcade.in1:=marcade.in1 and $fd else marcade.in1:=marcade.in1 or 2;
  if arcade_input.right[1] then marcade.in1:=marcade.in1 and $f7 else marcade.in1:=marcade.in1 or 8;
  if arcade_input.but0[1] then marcade.in1:=marcade.in1 and $7f else marcade.in1:=marcade.in1 or $80;
  //botones 3
  if arcade_input.start[0] then marcade.in2:=marcade.in2 and $fe else marcade.in2:=marcade.in2 or 1;
  if arcade_input.start[1] then marcade.in2:=marcade.in2 and $fd else marcade.in2:=marcade.in2 or 2;
  if arcade_input.coin[0] then marcade.in2:=marcade.in2 or $10 else marcade.in2:=marcade.in2 and $ef;
  if arcade_input.coin[1] then marcade.in2:=marcade.in2 or $20 else marcade.in2:=marcade.in2 and $df;

end;
end;

procedure principal_retofinv;
var
  frame_m,frame_sub,frame_s,frame_mcu:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=z80_0.tframes;
frame_sub:=z80_1.tframes;
frame_s:=z80_2.tframes;
frame_mcu:=m6805_0.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to $df do begin
   z80_0.run(frame_m);
   frame_m:=frame_m+z80_0.tframes-z80_0.contador;
   //Sub
   z80_1.run(frame_sub);
   frame_sub:=frame_sub+z80_1.tframes-z80_1.contador;
   //Sound
   z80_2.run(frame_s);
   frame_s:=frame_s+z80_2.tframes-z80_2.contador;
   //mcu
   m6805_0.run(frame_mcu);
   frame_mcu:=frame_mcu+m6805_0.tframes-m6805_0.contador;
   case f of
      $df:begin
               if main_vblank then z80_0.change_irq(ASSERT_LINE);
               if sub_vblank then z80_1.change_irq(ASSERT_LINE);
               update_video_retofinv;
          end;
   end;
 end;
 eventos_retofinv;
 video_sync;
end;
end;

function getbyte_retofinv(direccion:word):byte;
begin
case direccion of
   0..$a7ff:getbyte_retofinv:=memoria[direccion];
   $c000:getbyte_retofinv:=marcade.in0; // p1
   $c001:getbyte_retofinv:=marcade.in1; // p2
   $c002:getbyte_retofinv:=0; //Debe devolve 0 o se resetea
   $c003:getbyte_retofinv:=(byte(not(main_sent)) shl 4) or (byte(mcu_sent) shl 5); //mcu_status_r
   $c004:getbyte_retofinv:=marcade.in2; //system
   $c005:getbyte_retofinv:=marcade.dswa;// dsw1
   $c006:getbyte_retofinv:=marcade.dswb;// dsw2
   $c007:getbyte_retofinv:=marcade.dswc;// dsw3
   $e000:begin  //mcu_r
           getbyte_retofinv:=from_mcu;
           mcu_sent:=false;
         end;
   $f800:getbyte_retofinv:=sound_return;
end;
end;

procedure putbyte_retofinv(direccion:word;valor:byte);
begin
if (direccion<$8000) then exit;
case direccion of
  $8000..$87ff:begin
                  memoria[direccion]:=valor;
                  gfx[0].buffer[direccion and $3ff]:=true;
               end;
  $8800..$9fff:memoria[direccion]:=valor;
  $a000..$a7ff:begin
                  memoria[direccion]:=valor;
                  gfx[1].buffer[direccion and $3ff]:=true;
               end;
  $b800:main_screen.flip_main_screen:=(valor and 1)<>0;
  $b801:begin
          fg_bank:=(valor and 1);
          fillchar(gfx[0].buffer,$400,1);
        end;
  $b802:begin
          bg_bank:=(valor and 1);
          fillchar(gfx[1].buffer,$400,1);
        end;
  $c800:begin
           main_vblank:=(valor and 1)<>0;
           if not(main_vblank) then z80_0.change_irq(CLEAR_LINE);
        end;
  $c801,$d000:; //coinlockout + watch dog
  $c802:if valor=0 then z80_2.change_reset(ASSERT_LINE)
           else z80_2.change_reset(CLEAR_LINE);
  $c803:if valor=0 then m6805_0.change_reset(ASSERT_LINE)
           else m6805_0.change_reset(CLEAR_LINE);
  $c805:if valor=0 then z80_1.change_reset(ASSERT_LINE)
           else z80_1.change_reset(CLEAR_LINE);
  $d800:begin
           sound_latch:=valor;
           z80_2.change_irq(HOLD_LINE);
        end;
  $e800:begin
           from_main:=valor;
           main_sent:=true;
           m6805_0.irq_request(0,ASSERT_LINE);
        end;
end;
end;

function getbyte_sub_retofinv(direccion:word):byte;
begin
  case direccion of
    0..$1fff:getbyte_sub_retofinv:=mem_misc[direccion];
    $8000..$a7ff:getbyte_sub_retofinv:=memoria[direccion];
  end;
end;

procedure putbyte_sub_retofinv(direccion:word;valor:byte);
begin
if (direccion<$2000) then exit;
case direccion of
  $8000..$87ff:begin
                  memoria[direccion]:=valor;
                  gfx[0].buffer[direccion and $3ff]:=true;
               end;
  $8800..$9fff:memoria[direccion]:=valor;
  $a000..$a7ff:begin
                  memoria[direccion]:=valor;
                  gfx[1].buffer[direccion and $3ff]:=true;
               end;
  $c804:begin
           sub_vblank:=(valor and 1)<>0;
           if not(sub_vblank) then z80_1.change_irq(CLEAR_LINE);
        end;
end;
end;

function getbyte_snd_retofinv(direccion:word):byte;
begin
  case direccion of
    0..$27ff,$e000..$ffff:getbyte_snd_retofinv:=mem_snd[direccion];
    $4000:getbyte_snd_retofinv:=sound_latch;
  end;
end;

procedure putbyte_snd_retofinv(direccion:word;valor:byte);
begin
if ((direccion<$2000) or (direccion>$dfff)) then exit;
case direccion of
  $2000..$27ff:mem_snd[direccion]:=valor;
  $6000:sound_return:=valor;
  $8000:sn_76496_0.Write(valor);
  $a000:sn_76496_1.Write(valor);
end;
end;

function retofinv_mcu_getbyte(direccion:word):byte;
begin
direccion:=direccion and $7ff;
case direccion of
  0:retofinv_mcu_getbyte:=(port_a_out and ddr_a) or (port_a_in and not(ddr_a));
  1:retofinv_mcu_getbyte:=(port_b_out and ddr_b) or (port_b_in and not(ddr_b));
  2:begin
      port_c_in:=byte(main_sent) or (byte(not(mcu_sent)) shl 1);
      retofinv_mcu_getbyte:=(port_c_out and ddr_c) or (port_c_in and not(ddr_c));
    end;
  $10..$7ff:retofinv_mcu_getbyte:=mcu_mem[direccion];
end;
end;

procedure retofinv_mcu_putbyte(direccion:word;valor:byte);
begin
direccion:=direccion and $7ff;
if direccion>$7f then exit;
case direccion of
  0:port_a_out:=valor;
  1:begin
      if (((ddr_b and $02)<>0) and ((not(valor) and $02)<>0) and ((port_b_out and $2)<>0)) then begin
        port_a_in:=from_main;
        if main_sent then m6805_0.irq_request(0,CLEAR_LINE);
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

procedure retofinv_sound_update;
begin
  sn_76496_0.update;
  sn_76496_1.update;
end;

procedure retofinv_snd_nmi;
begin
  z80_2.change_nmi(PULSE_LINE);
end;

//Main
procedure reset_retofinv;
begin
z80_0.reset;
z80_1.reset;
z80_2.reset;
m6805_0.reset;
sn_76496_0.reset;
sn_76496_1.reset;
marcade.in0:=$ff;
marcade.in1:=$ff;
marcade.in2:=$cf;
sound_latch:=0;
sound_return:=0;
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
bg_bank:=0;
fg_bank:=0;
main_sent:=false;
mcu_sent:=false;
main_vblank:=false;
sub_vblank:=false;
end;

function iniciar_retofinv:boolean;
const
    pc_x:array[0..7] of dword=(7, 6, 5, 4, 3, 2, 1, 0);
    ps_x:array[0..15] of dword=(0, 1, 2, 3, 8*8, 8*8+1, 8*8+2, 8*8+3, 16*8+0, 16*8+1, 16*8+2, 16*8+3,
			24*8+0, 24*8+1, 24*8+2, 24*8+3);
    ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			32*8, 33*8, 34*8, 35*8, 36*8, 37*8, 38*8, 39*8);
var
  colores:tpaleta;
  f:word;
  memoria_temp:array[0..$7fff] of byte;
begin
iniciar_retofinv:=false;
iniciar_audio(false);
screen_init(1,224,288,true);
screen_init(2,224,288);
screen_init(3,512,512,false,true);
iniciar_video(224,288);
//Main CPU
z80_0:=cpu_z80.create(18432000 div 6,224);
z80_0.change_ram_calls(getbyte_retofinv,putbyte_retofinv);
//Sub
z80_1:=cpu_z80.create(18432000 div 6,224);
z80_1.change_ram_calls(getbyte_sub_retofinv,putbyte_sub_retofinv);
//Sound CPU
z80_2:=cpu_z80.Create(18432000 div 6,224);
z80_2.change_ram_calls(getbyte_snd_retofinv,putbyte_snd_retofinv);
z80_2.init_sound(retofinv_sound_update);
init_timer(z80_2.numero_cpu,(18432000 div 6)/(2*60),retofinv_snd_nmi,true);
//MCU CPU
m6805_0:=cpu_m6805.create(18432000 div 6,224,tipo_m68705);
m6805_0.change_ram_calls(retofinv_mcu_getbyte,retofinv_mcu_putbyte);
//Sound Chips
sn_76496_0:=sn76496_chip.Create(18432000 div 6);
sn_76496_1:=sn76496_chip.Create(18432000 div 6);
//cargar roms
if not(roms_load(@memoria,@retofinv_rom,'retofinv.zip',sizeof(retofinv_rom))) then exit;
if not(roms_load(@mem_misc,@retofinv_sub,'retofinv.zip',sizeof(retofinv_sub))) then exit;
//cargar roms audio
if not(roms_load(@mem_snd,@retofinv_snd,'retofinv.zip',sizeof(retofinv_snd))) then exit;
//cargar roms mcu
if not(roms_load(@mcu_mem,@retofinv_mcu,'retofinv.zip',sizeof(retofinv_mcu))) then exit;
//Cargar chars
if not(roms_load(@memoria_temp,@retofinv_char,'retofinv.zip',sizeof(retofinv_char))) then exit;
init_gfx(0,8,8,$200);
gfx_set_desc_data(1,0,8*8,0);
convert_gfx(0,0,@memoria_temp,@pc_x,@ps_y,true,false);
//Cargar tiles
if not(roms_load(@memoria_temp,@retofinv_tiles,'retofinv.zip',sizeof(retofinv_tiles))) then exit;
init_gfx(1,8,8,$200);
gfx_set_desc_data(4,0,16*8,0,($200*16*8)+4,$200*16*8,4);
convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,true,false);
//sprites
if not(roms_load(@memoria_temp,@retofinv_sprites,'retofinv.zip',sizeof(retofinv_sprites))) then exit;
init_gfx(2,16,16,$100);
gfx_set_desc_data(4,0,64*8,0,($100*64*8)+4,$100*64*8,4);
convert_gfx(2,0,@memoria_temp,@ps_x,@ps_y,true,false);
//pal
if not(roms_load(@memoria_temp,@retofinv_proms,'retofinv.zip',sizeof(retofinv_proms))) then exit;
for f:=0 to $ff do begin
    colores[f].r:=pal4bit(memoria_temp[f+$000]);
    colores[f].g:=pal4bit(memoria_temp[f+$100]);
    colores[f].b:=pal4bit(memoria_temp[f+$200]);
end;
set_pal(colores,$100);
for f:=0 to $1ff do begin
    if (f and 1)<>0 then gfx[0].colores[f]:=f shr 1
       else gfx[0].colores[f]:=0;
end;
for f:=0 to $7ff do begin
    gfx[1].colores[f]:=bitswap8(memoria_temp[$300+f],4,5,6,7,3,2,1,0);
    gfx[2].colores[f]:=bitswap8(memoria_temp[$300+f],4,5,6,7,3,2,1,0);
end;
//Dip
marcade.dswa:=$6f;
marcade.dswb:=$0;
marcade.dswc:=$ff;
marcade.dswa_val:=@retofinv_dip_a;
marcade.dswb_val:=@retofinv_dip_b;
marcade.dswc_val:=@retofinv_dip_c;
//final
reset_retofinv;
iniciar_retofinv:=true;
end;

procedure Cargar_retofinv;
begin
llamadas_maquina.iniciar:=iniciar_retofinv;
llamadas_maquina.bucle_general:=principal_retofinv;
llamadas_maquina.reset:=reset_retofinv;
end;

end.
