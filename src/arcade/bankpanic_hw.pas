unit bankpanic_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     sound_engine,sn_76496;

function iniciar_bankpanic:boolean;

implementation
const
        bankpanic_rom:array[0..3] of tipo_roms=(
        (n:'epr-6175.7e';l:$4000;p:0;crc:$044552b8),(n:'epr-6174.7f';l:$4000;p:$4000;crc:$d29b1598),
        (n:'epr-6173.7h';l:$4000;p:$8000;crc:$b8405d38),(n:'epr-6176.7d';l:$2000;p:$c000;crc:$c98ac200));
        bankpanic_char:array[0..1] of tipo_roms=(
        (n:'epr-6165.5l';l:$2000;p:0;crc:$aef34a93),(n:'epr-6166.5k';l:$2000;p:$2000;crc:$ca13cb11));
        bankpanic_bg:array[0..5] of tipo_roms=(
        (n:'epr-6172.5b';l:$2000;p:0;crc:$c4c4878b),(n:'epr-6171.5d';l:$2000;p:$2000;crc:$a18165a1),
        (n:'epr-6170.5e';l:$2000;p:$4000;crc:$b58aa8fa),(n:'epr-6169.5f';l:$2000;p:$6000;crc:$1aa37fce),
        (n:'epr-6168.5h';l:$2000;p:$8000;crc:$05f3a867),(n:'epr-6167.5i';l:$2000;p:$a000;crc:$3fa337e1));
        bankpanic_prom:array[0..2] of tipo_roms=(
        (n:'pr-6177.8a';l:$20;p:0;crc:$eb70c5ae),(n:'pr-6178.6f';l:$100;p:$20;crc:$0acca001),
        (n:'pr-6179.5a';l:$100;p:$120;crc:$e53bafdb));
        combathawk_rom:array[0..3] of tipo_roms=(
        (n:'epr-10904.7e';l:$4000;p:0;crc:$4b106335),(n:'epr-10905.7f';l:$4000;p:$4000;crc:$a76fc390),
        (n:'epr-10906.7h';l:$4000;p:$8000;crc:$16d54885),(n:'epr-10903.7d';l:$2000;p:$c000;crc:$b7a59cab));
        combathawk_char:array[0..1] of tipo_roms=(
        (n:'epr-10914.5l';l:$2000;p:0;crc:$7d7a2340),(n:'epr-10913.5k';l:$2000;p:$2000;crc:$d5c1a8ae));
        combathawk_bg:array[0..5] of tipo_roms=(
        (n:'epr-10907.5b';l:$2000;p:0;crc:$08e5eea3),(n:'epr-10908.5d';l:$2000;p:$2000;crc:$d9e413f5),
        (n:'epr-10909.5e';l:$2000;p:$4000;crc:$fec7962c),(n:'epr-10910.5f';l:$2000;p:$6000;crc:$33db0fa7),
        (n:'epr-10911.5h';l:$2000;p:$8000;crc:$565d9e6d),(n:'epr-10912.5i';l:$2000;p:$a000;crc:$cbe22738));
        combathawk_prom:array[0..2] of tipo_roms=(
        (n:'pr-10900.8a';l:$20;p:0;crc:$f95fcd66),(n:'pr-10901.6f';l:$100;p:$20;crc:$6fd981c8),
        (n:'pr-10902.5a';l:$100;p:$120;crc:$84d6bded));
        //DIP
        bankpanic_dip:array [0..7] of def_dip=(
        (mask:$3;name:'Coin A';number:4;dip:((dip_val:$3;dip_name:'3C 1C'),(dip_val:$2;dip_name:'2C 1C'),(dip_val:$0;dip_name:'1C 1C'),(dip_val:$1;dip_name:'1C 2C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Coin B';number:2;dip:((dip_val:$4;dip_name:'2C 1C'),(dip_val:$0;dip_name:'1C 1C'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Lives';number:2;dip:((dip_val:$0;dip_name:'3'),(dip_val:$8;dip_name:'4'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Bonus Life';number:2;dip:((dip_val:$0;dip_name:'70K 200K 500K'),(dip_val:$10;dip_name:'100K 400K 800K'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Difficulty';number:2;dip:((dip_val:$0;dip_name:'Easy'),(dip_val:$20;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$40;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Cabinet';number:2;dip:((dip_val:$80;dip_name:'Upright'),(dip_val:$0;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        combathawk_dip:array [0..6] of def_dip=(
        (mask:$1;name:'Flip Screen';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$1;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$3;name:'Coinage';number:4;dip:((dip_val:$6;dip_name:'2C 1C'),(dip_val:$0;dip_name:'1C 1C'),(dip_val:$2;dip_name:'1C 2C'),(dip_val:$4;dip_name:'1C 3C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Lives';number:2;dip:((dip_val:$0;dip_name:'3'),(dip_val:$8;dip_name:'4'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Cabinet';number:2;dip:((dip_val:$10;dip_name:'Upright'),(dip_val:$0;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Difficulty';number:2;dip:((dip_val:$0;dip_name:'Easy'),(dip_val:$40;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Fuel';number:2;dip:((dip_val:$0;dip_name:'120 Units'),(dip_val:$80;dip_name:'90 Units'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
  priority,display_on,nmi_vblank:boolean;
  color_hi,scroll_x:byte;

procedure update_video_bankpanic;
var
  x,y,atrib:byte;
  f,nchar,color:word;
  flip_x:boolean;
begin
if display_on then begin
  for f:=0 to $3ff do begin
    y:=f shr 5;
    x:=f and $1f;
    //Background
    if gfx[1].buffer[f] then begin
      atrib:=memoria[$fc00+f];
      color:=(atrib shr 4) or (color_hi shl 4);
      nchar:=memoria[$f800+f]+((atrib and $7) shl 8);
      flip_x:=(atrib and $8)<>0;
      if priority then put_gfx_mask_flip(x*8,y*8,nchar,(color shl 3)+256,2,1,0,$f,flip_x,false)
        else put_gfx_flip(x*8,y*8,nchar,(color shl 3)+256,2,1,flip_x,false);
      gfx[1].buffer[f]:=false;
    end;
    //Foreground
    if gfx[0].buffer[f] then begin
      atrib:=memoria[$f400+f];
      color:=(atrib shr 3) or (color_hi shl 5);
      nchar:=memoria[$f000+f]+((atrib and $3) shl 8);
      flip_x:=(atrib and $4)<>0;
      if priority then put_gfx_flip(x*8,y*8,nchar,color shl 2,1,0,flip_x,false)
        else put_gfx_mask_flip(x*8,y*8,nchar,color shl 2,1,0,0,$1f,flip_x,false);
      gfx[0].buffer[f]:=false;
    end;
  end;
  if not(priority) then begin
    actualiza_trozo(0,0,256,256,2,0,0,256,256,3);
    scroll__x(1,3,scroll_x);
  end else begin
    scroll__x(1,3,scroll_x);
    actualiza_trozo(0,0,256,256,2,0,0,256,256,3);
  end;
end else fill_full_screen(3,$400);
actualiza_trozo_final(24,16,224,224,3);
end;

procedure eventos_bankpanic;
begin
if event.arcade then begin
  //p1
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 or 1) else marcade.in0:=(marcade.in0 and $fe);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 or 2) else marcade.in0:=(marcade.in0 and $fd);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 or 4) else marcade.in0:=(marcade.in0 and $fb);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 or 8) else marcade.in0:=(marcade.in0 and $f7);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 or $10) else marcade.in0:=(marcade.in0 and $ef);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 or $20) else marcade.in0:=(marcade.in0 and $df);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 or $80) else marcade.in0:=(marcade.in0 and $7f);
  //p2
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 or 1) else marcade.in1:=(marcade.in1 and $fe);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 or 2) else marcade.in1:=(marcade.in1 and $fd);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 or 4) else marcade.in1:=(marcade.in1 and $fb);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 or 8) else marcade.in1:=(marcade.in1 and $f7);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 or $10) else marcade.in1:=(marcade.in1 and $ef);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 or $20) else marcade.in1:=(marcade.in1 and $df);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 or $40) else marcade.in1:=(marcade.in1 and $bf);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 or $80) else marcade.in1:=(marcade.in1 and $7f);
  //System
  if arcade_input.but2[0] then marcade.in2:=(marcade.in2 or 1) else marcade.in2:=(marcade.in2 and $fe);
  if arcade_input.but2[1] then marcade.in2:=(marcade.in2 or 2) else marcade.in2:=(marcade.in2 and $fd);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 or 4) else marcade.in2:=(marcade.in2 and $fb);
end;
end;

procedure bankpanic_principal;
var
  frame:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame:=z80_0.tframes;
while EmuStatus=EsRunning do begin
  for f:=0 to $ff do begin
    z80_0.run(frame);
    frame:=frame+z80_0.tframes-z80_0.contador;
    if f=239 then begin
      if nmi_vblank then z80_0.change_nmi(PULSE_LINE);
      update_video_bankpanic;
    end;
  end;
  eventos_bankpanic;
  video_sync;
end;
end;

function bankpanic_getbyte(direccion:word):byte;
begin
bankpanic_getbyte:=memoria[direccion];
end;

procedure bankpanic_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$dfff:; //ROM
  $e000..$efff:memoria[direccion]:=valor;
  $f000..$f7ff:if memoria[direccion]<>valor then begin
                  gfx[0].buffer[direccion and $3ff]:=true;
                  memoria[direccion]:=valor;
               end;
  $f800..$ffff:if memoria[direccion]<>valor then begin
                  gfx[1].buffer[direccion and $3ff]:=true;
                  memoria[direccion]:=valor;
               end;
end;
end;

function bankpanic_inbyte(puerto:word):byte;
begin
case (puerto and $ff) of
  0:bankpanic_inbyte:=marcade.in0;
  1:bankpanic_inbyte:=marcade.in1;
  2:bankpanic_inbyte:=marcade.in2;
  4:bankpanic_inbyte:=marcade.dswa;
end;
end;

procedure bankpanic_outbyte(puerto:word;valor:byte);
begin
case (puerto and $ff) of
  0:sn_76496_0.write(valor);
  1:sn_76496_1.write(valor);
  2:sn_76496_2.write(valor);
  5:scroll_x:=valor;
  7:begin
      if priority<>((valor and $2)<>0) then begin
        priority:=(valor and $2)<>0;
        fillchar(gfx[0].buffer,$400,1);
        fillchar(gfx[1].buffer,$400,1);
      end;
      display_on:=(valor and 4)<>0;
      if color_hi<>((valor and 8) shr 3) then begin
        color_hi:=(valor and 8) shr 3;
        fillchar(gfx[0].buffer,$400,1);
        fillchar(gfx[1].buffer,$400,1);
      end;
      nmi_vblank:=(valor and $10)<>0;
    end;
end;
end;

procedure bankpanic_update_sound;
begin
  sn_76496_0.update;
  sn_76496_1.update;
  sn_76496_2.update;
end;

//Main
procedure bankpanic_reset;
begin
z80_0.reset;
reset_audio;
sn_76496_0.reset;
sn_76496_1.reset;
sn_76496_2.reset;
marcade.in0:=0;
marcade.in1:=0;
marcade.in2:=0;
nmi_vblank:=false;
scroll_x:=0;
color_hi:=$ff;
display_on:=true;
priority:=false;
end;

function iniciar_bankpanic:boolean;
const
      pc_x:array[0..7] of dword=(8*8+3,8*8+2,8*8+1,8*8+0,3,2,1,0);
      pc_y:array[0..7] of dword=(0*8,1*8,2*8,3*8,4*8,5*8,6*8,7*8);
      pt_x:array[0..7] of dword=(7, 6, 5, 4, 3, 2, 1, 0);
var
  memoria_temp:array[0..$ffff] of byte;
  colores:tpaleta;
  bit0,bit1,bit2,f:byte;
  index:word;
procedure chars_gfx;
begin
//convertir fg
init_gfx(0,8,8,$400);
gfx_set_desc_data(2,0,16*8,0,4);
convert_gfx(0,0,@memoria_temp,@pc_x,@pc_y,false,false);
end;
procedure tiles_gfx;
begin
//convertir bg
init_gfx(1,8,8,$800);
gfx_set_desc_data(3,0,8*8,0,2048*8*8,2048*2*8*8);
convert_gfx(1,0,@memoria_temp,@pt_x,@pc_y,false,false);
end;
begin
llamadas_maquina.bucle_general:=bankpanic_principal;
llamadas_maquina.reset:=bankpanic_reset;
llamadas_maquina.fps_max:=61.034091;
iniciar_bankpanic:=false;
iniciar_audio(false);
if main_vars.tipo_maquina=362 then main_screen.rot270_screen:=true;
screen_init(1,256,256,true);
screen_mod_scroll(1,256,256,255,256,256,255);
screen_init(2,256,256,true);
screen_init(3,256,256,false,true);
iniciar_video(224,224);
//Main CPU
z80_0:=cpu_z80.create(15468480 div 6,256);
z80_0.change_ram_calls(bankpanic_getbyte,bankpanic_putbyte);
z80_0.change_io_calls(bankpanic_inbyte,bankpanic_outbyte);
z80_0.init_sound(bankpanic_update_sound);
//Sound Chip
sn_76496_0:=sn76496_chip.Create(15468480 div 6);
sn_76496_1:=sn76496_chip.Create(15468480 div 6);
sn_76496_2:=sn76496_chip.Create(15468480 div 6);
case main_vars.tipo_maquina of
  361:begin //Bank Panic
        if not(roms_load(@memoria,bankpanic_rom)) then exit;
        if not(roms_load(@memoria_temp,bankpanic_char)) then exit;
        chars_gfx;
        if not(roms_load(@memoria_temp,bankpanic_bg)) then exit;
        tiles_gfx;
        if not(roms_load(@memoria_temp,bankpanic_prom)) then exit;
        //DIP
        marcade.dswa:=$c0;
        marcade.dswa_val:=@bankpanic_dip;
      end;
  362:begin //Combat Hawk
        if not(roms_load(@memoria,combathawk_rom)) then exit;
        if not(roms_load(@memoria_temp,combathawk_char)) then exit;
        chars_gfx;
        if not(roms_load(@memoria_temp,combathawk_bg)) then exit;
        tiles_gfx;
        if not(roms_load(@memoria_temp,combathawk_prom)) then exit;
        //DIP
        marcade.dswa:=$10;
        marcade.dswa_val:=@combathawk_dip;
      end;
end;
//color
for f:=0 to $1f do begin
		// red component
		bit0:=(memoria_temp[f] shr 0) and $1;
		bit1:=(memoria_temp[f] shr 1) and $1;
		bit2:=(memoria_temp[f] shr 2) and $1;
		colores[f].r:=$21*bit0+$47*bit1+$97*bit2;
		// green component
		bit0:=(memoria_temp[f] shr 3) and $1;
		bit1:=(memoria_temp[f] shr 4) and $1;
		bit2:=(memoria_temp[f] shr 5) and $1;
		colores[f].g:=$21*bit0+$47*bit1+$97*bit2;
		// blue component
		bit1:=(memoria_temp[f] shr 6) and $1;
		bit2:=(memoria_temp[f] shr 7) and $1;
		colores[f].b:=0+$47*bit1+$97*bit2;
end;
set_pal(colores,$20);
for f:=0 to 255 do begin
  index:=((f shl 1) and $100) or (f and $7f);
  gfx[0].colores[index]:=memoria_temp[$20+index] and $f;
  gfx[1].colores[index]:=memoria_temp[$20+index] and $f;
  gfx[0].colores[index or $80]:=(memoria_temp[$20+index] and $f) or $10;
  gfx[1].colores[index or $80]:=(memoria_temp[$20+index] and $f) or $10;
end;
//final
bankpanic_reset;
iniciar_bankpanic:=true;
end;

end.
