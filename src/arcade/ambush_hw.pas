unit ambush_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,gfx_engine,rom_engine,ay_8910,
     pal_engine,sound_engine;

function iniciar_ambush:boolean;

implementation
const
        ambush_rom:array[0..3] of tipo_roms=(
        (n:'a1.i7';l:$2000;p:0;crc:$31b85d9d),(n:'a2.g7';l:$2000;p:$2000;crc:$8328d88a),
        (n:'a3.f7';l:$2000;p:$4000;crc:$8db57ab5),(n:'a4.e7';l:$2000;p:$6000;crc:$4a34d2a4));
        ambush_gfx:array[0..1] of tipo_roms=(
        (n:'fa1.m4';l:$2000;p:$0;crc:$ad10969e),(n:'fa2.n4';l:$2000;p:$2000;crc:$e7f134ba));
        ambush_proms:array[0..1] of tipo_roms=(
        (n:'a.bpr';l:$100;p:$0;crc:$5f27f511),(n:'b.bpr';l:$100;p:$100;crc:$1b03fd3b));
        //Dip
        ambush_dip:array [0..5] of def_dip2=(
        (mask:$3;name:'Lives';number:4;val4:(0,1,2,3);name4:('3','4','5','6')),
        (mask:$1c;name:'Coinage';number:8;val8:($10,0,$14,4,$18,8,$c,$1c);name8:('2C 1C','1C 1C','2C 3C','1C 2C','2C 5C','1C 3C','1C 4C','Service Mode/Free Play')),
        (mask:$20;name:'Difficulty';number:2;val2:(0,$20);name2:('Easy','Hard')),
        (mask:$40;name:'Bonus Life';number:2;val2:($40,0);name2:('80K','120K')),
        (mask:$80;name:'Cabinet';number:2;val2:($80,0);name2:('Upright','Cocktail')),());

var
  color_bank:byte;
  scroll_y:array[0..$1f] of word;

procedure update_video_ambush;
var
  ngfx,atrib,x,y,color:byte;
  f,nchar:word;
  wrap:boolean;
begin
for f:=0 to $3ff do begin
 if gfx[0].buffer[f] then begin
    x:=f mod 32;
    y:=f div 32;
    atrib:=memoria[$c100+(((f shr 2) and $e0) or (f and $1f))];
    nchar:=((atrib and $60) shl 3) or memoria[$c400+f];
    color:=(color_bank shl 4) or (atrib and $0f);
    put_gfx(x*8,y*8,nchar,color shl 2,1,0);
    if (atrib and $10)<>0 then put_gfx_trans(x*8,y*8,nchar,color shl 2,2,0)
      else put_gfx_block_trans(x*8,y*8,2,8,8);
    gfx[0].buffer[f]:=false;
 end;
end;
scroll__y_part2(1,3,8,@scroll_y);
for f:=$7f downto 0 do begin
  x:=memoria[$c203+(f*4)];
  y:=memoria[$c200+(f*4)];
  if ((x=0) and (y=$ff)) then continue;
  atrib:=memoria[$c202+(f*4)];
  wrap:=(atrib and $10)<>0;
  if (((x<$40) and wrap) or ((x>=$c0) and not(wrap))) then continue;
  ngfx:=atrib shr 7;
  nchar:=((atrib and $60) shl 1) or (memoria[$c201+(f*4)] and $3f);
  if ngfx=0 then begin
    nchar:=nchar shl 2;
    y:=248-y;
  end else begin
    y:=240-y;
  end;
  color:=(color_bank shl 4) or (atrib and $0f);
  put_gfx_sprite(nchar,color shl 2,(memoria[$c201+(f*4)] and $40)<>0,(memoria[$c201+(f*4)] and $80)<>0,ngfx);
  actualiza_gfx_sprite(x,y,3,ngfx);
end;
scroll__y_part2(2,3,8,@scroll_y);
actualiza_trozo_final(0,16,256,224,3);
end;

procedure eventos_ambush;
begin
if event.arcade then begin
  //botones
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.but1[1] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.but0[1] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  //players
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
end;
end;

procedure ambush_principal;
var
  frame:single;
  f:word;
begin
init_controls(false,false,false,true);
frame:=z80_0.tframes;
while EmuStatus=EsRunning do begin
  for f:=0 to 263 do begin
    z80_0.run(frame);
    frame:=frame+z80_0.tframes-z80_0.contador;
    if f=240 then begin
      update_video_ambush;
      z80_0.change_irq(HOLD_LINE);
    end;
  end;
  eventos_ambush;
  video_sync;
end;
end;

function ambush_getbyte(direccion:word):byte;
begin
case direccion of
  0..$87ff,$c000..$c7ff:ambush_getbyte:=memoria[direccion];
  $c800:ambush_getbyte:=marcade.dswa;
end;
end;

procedure ambush_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:; //ROM
  $8000..$87ff,$c000..$c07f,$c0a0..$c0ff,$c200..$c3ff:memoria[direccion]:=valor;
  $a000:; //Watch Dog
  $c080..$c09f:scroll_y[direccion and $1f]:=valor+1;
  $c100..$c1ff:if memoria[direccion]<>valor then begin
                  memoria[direccion]:=valor;
                  fillchar(gfx[0].buffer,$400,1);
               end;
  $c400..$c7ff:if memoria[direccion]<>valor then begin
                memoria[direccion]:=valor;
                gfx[0].buffer[direccion and $3ff]:=true;
               end;
  $cc00..$cc07:case (direccion and $7) of
                  4:main_screen.flip_main_screen:=(valor and 1)<>0;
                  5:if color_bank<>(valor and 3) then begin
                      color_bank:=valor and 3;
                      fillchar(gfx[0].buffer,$400,1);
                    end;
               end;
end;
end;

function ambush_inbyte(puerto:word):byte;
begin
case (puerto and $ff) of
  $0:ambush_inbyte:=ay8910_0.read;
  $80:ambush_inbyte:=ay8910_1.read;
end;
end;

procedure ambush_outbyte(puerto:word;valor:byte);
begin
case (puerto and $ff) of
  $0:ay8910_0.control(valor);
  $1:ay8910_0.write(valor);
  $80:ay8910_1.control(valor);
  $81:ay8910_1.write(valor);
end;
end;

function ambush_portar_0:byte;
begin
  ambush_portar_0:=marcade.in0;
end;

function ambush_portar_1:byte;
begin
  ambush_portar_1:=marcade.in1;
end;

procedure ambush_sound_update;
begin
  ay8910_0.update;
  ay8910_1.update;
end;

//Main
procedure reset_ambush;
begin
 z80_0.reset;
 ay8910_0.reset;
 ay8910_1.reset;
 reset_audio;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 color_bank:=0;
 fillword(@scroll_y,$20,0);
end;

function iniciar_ambush:boolean;
const
  ps_x:array[0..15] of dword=(0, 1, 2, 3, 4, 5, 6, 7,
		8*8+0, 8*8+1, 8*8+2, 8*8+3, 8*8+4, 8*8+5, 8*8+6, 8*8+7);
  ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
		16*8, 17*8, 18*8, 19*8, 20*8, 21*8, 22*8, 23*8);
var
  memoria_temp:array[0..$3fff] of byte;
  f,bit0,bit1,bit2:byte;
  colores:tpaleta;
begin
llamadas_maquina.bucle_general:=ambush_principal;
llamadas_maquina.reset:=reset_ambush;
iniciar_ambush:=false;
iniciar_audio(false);
screen_init(1,256,256);
screen_mod_scroll(1,256,256,255,256,256,255);
screen_init(2,256,256,true);
screen_mod_scroll(2,256,256,255,256,256,255);
screen_init(3,256,256,false,true);
iniciar_video(256,224);
//Main CPU
z80_0:=cpu_z80.create(18432000 div 6,264);
z80_0.change_ram_calls(ambush_getbyte,ambush_putbyte);
z80_0.change_io_calls(ambush_inbyte,ambush_outbyte);
z80_0.init_sound(ambush_sound_update);
//Audio chips
ay8910_0:=ay8910_chip.create(18432000 div 6 div 2,AY8912);
ay8910_0.change_io_calls(ambush_portar_0,nil,nil,nil);
ay8910_1:=ay8910_chip.create(18432000 div 6 div 2,AY8912);
ay8910_1.change_io_calls(ambush_portar_1,nil,nil,nil);
//cargar roms
if not(roms_load(@memoria,ambush_rom)) then exit;
//convertir chars
if not(roms_load(@memoria_temp,ambush_gfx)) then exit;
init_gfx(0,8,8,$400);
gfx_set_desc_data(2,0,8*8,$400*8*8,0);
convert_gfx(0,0,@memoria_temp,@ps_x,@ps_y,false,false);
gfx[0].trans[0]:=true;
//Sprites
init_gfx(1,16,16,$100);
gfx_set_desc_data(2,0,32*8,$100*32*8,0);
convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,false);
gfx[1].trans[0]:=true;
//colores
if not(roms_load(@memoria_temp,ambush_proms)) then exit;
for f:=0 to $ff do begin
		// red component
		bit0:=(memoria_temp[f] shr 0) and $01;
		bit1:=(memoria_temp[f] shr 1) and $01;
		bit2:=(memoria_temp[f] shr 2) and $01;
		colores[f].r:=$21*bit0+$47*bit1+$97*bit2;
		// green component
		bit0:=(memoria_temp[f] shr 3) and $01;
		bit1:=(memoria_temp[f] shr 4) and $01;
		bit2:=(memoria_temp[f] shr 5) and $01;
		colores[f].g:=$21*bit0+$47*bit1+$97*bit2;
		// blue component
    bit0:=0;
		bit1:=(memoria_temp[f] shr 6) and $01;
		bit2:=(memoria_temp[f] shr 7) and $01;
		colores[f].b:=$21*bit0+$47*bit1+$97*bit2;
end;
set_pal(colores,$100);
marcade.dswa:=$c4;
marcade.dswa_val2:=@ambush_dip;
//final
reset_ambush;
iniciar_ambush:=true;
end;

end.
