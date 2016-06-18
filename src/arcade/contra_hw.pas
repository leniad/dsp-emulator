unit contra_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     hd6309,m6809,main_engine,controls_engine,gfx_engine,ym_2151,rom_engine,
     pal_engine,konami_video,sound_engine;

procedure cargar_contra;

implementation
const
        contra_rom:array[0..2] of tipo_roms=(
        (n:'633m03.18a';l:$10000;p:$0;crc:$d045e1da),(n:'633i02.17a';l:$10000;p:$10000;crc:$b2f7bd9a),());
        contra_proms:array[0..4] of tipo_roms=(
        (n:'633e08.10g';l:$100;p:0;crc:$9f0949fa),(n:'633e09.12g';l:$100;p:$100;crc:$14ca5e19),
        (n:'633f10.18g';l:$100;p:$200;crc:$2b244d84),(n:'633f11.20g';l:$100;p:$300;crc:$14ca5e19),());
        contra_chars:array[0..2] of tipo_roms=(
        (n:'633e04.7d';l:$40000;p:0;crc:$14ddc542),(n:'633e05.7f';l:$40000;p:$1;crc:$42185044),());
        contra_chars2:array[0..2] of tipo_roms=(
        (n:'633e06.16d';l:$40000;p:0;crc:$9cf6faae),(n:'633e07.16f';l:$40000;p:$1;crc:$f2d06638),());
        contra_sound:tipo_roms=(n:'633e01.12a';l:$8000;p:$8000;crc:$d1549255);

var
 memoria_rom:array[0..$b,0..$1FFF] of byte;
 banco,sound_latch:byte;

procedure draw_sprites(bank:byte);inline;
var
  color_base:word;
begin
  color_base:=(K007121_chip[bank].control[6] and $30)*2;
  K007121_draw_sprites(bank,4,16,color_base,true);
end;

procedure update_video_contra;inline;
var
  x,y,f,nchar,color,mask:word;
  atrib,bank,bit0,bit1,bit2,bit3:byte;
begin
for f:=$0 to $3ff do begin
    x:=31-(f div 32);
    y:=f mod 32;
    //background
    atrib:=memoria[$4000+f];
    color:=atrib and 7;
    if (gfx[1].buffer[f] or buffer_color[color]) then begin
      color:=color+((K007121_chip[1].control[6] and $30)*2+16);
      bit0:=(K007121_chip[1].control[$05] shr 0) and $03;
      bit1:=(K007121_chip[1].control[$05] shr 2) and $03;
      bit2:=(K007121_chip[1].control[$05] shr 4) and $03;
      bit3:=(K007121_chip[1].control[$05] shr 6) and $03;
      bank:=((atrib and $80) shr 7) or
			((atrib shr (bit0+2)) and $02) or
			((atrib shr (bit1+1)) and $04) or
			((atrib shr (bit2  )) and $08) or
			((atrib shr (bit3-1)) and $10) or
      ((K007121_chip[1].control[3] and 1) shl 5);
      mask:=(K007121_chip[1].control[$04] and $f0) shr 4;
      bank:=(bank and not(mask shl 1)) or ((K007121_chip[1].control[4] and mask) shl 1);
      nchar:=memoria[$4400+f]+bank*256;
      put_gfx(x*8,y*8,nchar,color shl 4,2,1);
      gfx[1].buffer[f]:=false;
    end;
    //foreground
    atrib:=memoria[$2000+f];
    color:=atrib and 7;
    if (gfx[0].buffer[$400+f] or buffer_color[color]) then begin
      color:=color+((K007121_chip[0].control[$6] and $30)*2+16);
      bit0:=(K007121_chip[0].control[$05] shr 0) and $03;
      bit1:=(K007121_chip[0].control[$05] shr 2) and $03;
      bit2:=(K007121_chip[0].control[$05] shr 4) and $03;
      bit3:=(K007121_chip[0].control[$05] shr 6) and $03;
      bank:=((atrib and $80) shr 7) or ((atrib shr (bit0+2)) and $02) or	((atrib shr (bit1+1)) and $04) or	((atrib shr bit2) and $08) or ((atrib shr (bit3-1)) and $10) or ((K007121_chip[0].control[$03] and $01) shl 5);
      mask:=(K007121_chip[0].control[$04] and $f0) shr 4;
      bank:=(bank and not(mask shl 1)) or ((K007121_chip[0].control[$04] and mask) shl 1);
      nchar:=memoria[$2400+f]+bank*256;
      put_gfx_trans(x*8,y*8,nchar,color shl 4,3,0);
      gfx[0].buffer[$400+f]:=false;
    end;
    //text
    atrib:=memoria[$2800+f];
    color:=atrib and 7;
    if (gfx[0].buffer[f] or buffer_color[color]) then begin
      color:=color+((K007121_chip[0].control[$6] and $30)*2+16);
      bit0:=(K007121_chip[0].control[$05] shr 0) and $03;
      bit1:=(K007121_chip[0].control[$05] shr 2) and $03;
      bit2:=(K007121_chip[0].control[$05] shr 4) and $03;
      bit3:=(K007121_chip[0].control[$05] shr 6) and $03;
      bank:= ((atrib and $80) shr 7) or
			((atrib shr (bit0+2)) and $02) or
			((atrib shr (bit1+1)) and $04) or
			((atrib shr (bit2  )) and $08) or
			((atrib shr (bit3-1)) and $10);
      nchar:=memoria[$2c00+f]+bank*256;
      if y<5 then put_gfx(x*8,y*8,nchar,color shl 4,1,0)
        else put_gfx_trans(x*8,y*8,nchar,color shl 4,1,0);
      gfx[0].buffer[f]:=false;
    end;
end;
scroll_x_y(2,4,256-K007121_chip[1].control[$2],K007121_chip[1].control[$0]);
scroll_x_y(3,4,256-K007121_chip[0].control[$2],K007121_chip[0].control[$0]);
draw_sprites(0);
draw_sprites(1);
actualiza_trozo(16+ADD_SPRITE,0+ADD_SPRITE,224,256,4,0,40,224,256,pant_temp);
//El texto empieza en la linea 0 de la pantalla VISIBLE
actualiza_trozo(16,0,224,256,1,0,0,224,256,pant_temp);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure eventos_contra;
begin
if event.arcade then begin
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
end;
end;

procedure contra_principal;
var
  f:byte;
  frame_m,frame_s:single;
begin
init_controls(false,false,false,true);
frame_m:=main_hd6309.tframes;
frame_s:=snd_m6809.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
    //Main
    main_hd6309.run(frame_m);
    frame_m:=frame_m+main_hd6309.tframes-main_hd6309.contador;
    //SND
    snd_m6809.run(frame_s);
    frame_s:=frame_s+snd_m6809.tframes-snd_m6809.contador;
    if f=239 then begin
      if (K007121_chip[0].control[$07] and $2)<>0 then main_hd6309.change_irq(HOLD_LINE);
      update_video_contra;
    end;
  end;
  eventos_contra;
  video_sync;
end;
end;

function contra_getbyte(direccion:word):byte;
begin
    case direccion of
        0..$7:contra_getbyte:=K007121_chip[0].control[direccion];
        $10:contra_getbyte:=marcade.in0;
        $11:contra_getbyte:=marcade.in1;
        $12:contra_getbyte:=marcade.in2;
        $14:contra_getbyte:=$ff;
        $13:contra_getbyte:=0;
        $15:contra_getbyte:=$7a;
        $16:contra_getbyte:=$0f;
        $60..$67:contra_getbyte:=K007121_chip[1].control[direccion and $7];
        $3000..$37ff:contra_getbyte:=K007121_chip[0].sprite_ram[direccion and $7ff];
        $6000..$7fff:contra_getbyte:=memoria_rom[banco,direccion and $1fff];
    else contra_getbyte:=memoria[direccion];
    end;
end;

procedure cambiar_color(dir:byte);inline;
var
  data:word;
  color:tcolor;
begin
  data:=buffer_paleta[dir]+(buffer_paleta[1+dir] shl 8);
  color.r:=pal5bit(data);
  color.g:=pal5bit(data shr 5);
  color.b:=pal5bit(data shr 10);
  dir:=dir shr 1;
  set_pal_color(color,dir);
  buffer_color[(dir shr 4) and 7]:=true;
end;

procedure contra_putbyte(direccion:word;valor:byte);
begin
if ((direccion>$5fff) and (direccion<>$7000)) then exit;
memoria[direccion]:=valor;
case direccion of
  $0..$7:if K007121_chip[0].control[direccion]<>valor then begin
            K007121_chip[0].control[direccion]:=valor;
            fillchar(gfx[0].buffer[$400],$400,1);
         end;
  $1a:snd_m6809.change_irq(HOLD_LINE);
  $1c:sound_latch:=valor;
  $60..$67:begin
              if K007121_chip[1].control[direccion and $7]<>valor then begin
                  K007121_chip[1].control[direccion and $7]:=valor;
                  fillchar(gfx[1].buffer[0],$400,1);
              end;
              if (direccion and $7)=3 then begin
                if ((valor and $8)=0) then copymemory(@K007121_chip[1].sprite_ram[0],@memoria[$5800],$800)
		                else copymemory(@K007121_chip[1].sprite_ram[0],@memoria[$5000],$800);
              end;
           end;
  $c00..$cff:if buffer_paleta[direccion and $ff]<>valor then begin
                buffer_paleta[direccion and $ff]:=valor;
                cambiar_color(direccion and $fe);
             end;
  $2000..$27ff:gfx[0].buffer[$400+(direccion and $3ff)]:=true;
  $2800..$2fff:gfx[0].buffer[direccion and $3ff]:=true;
  $3000..$37ff:K007121_chip[0].sprite_ram[direccion and $7ff]:=valor;
  $4000..$47ff:gfx[1].buffer[direccion and $3ff]:=true;
  $7000:begin
          banco:=(valor and $f);
          if banco>$b then banco:=0;
        end;
end;
end;

function sound_getbyte(direccion:word):byte;
begin
case direccion of
  0:sound_getbyte:=sound_latch;
  $2001:sound_getbyte:=ym2151_0.status;
    else sound_getbyte:=mem_snd[direccion];
end;
end;

procedure sound_putbyte(direccion:word;valor:byte);
begin
if direccion>$7fff then exit;
mem_snd[direccion]:=valor;
case direccion of
  $2000:ym2151_0.reg(valor);
  $2001:YM2151_0.write(valor);
end;
end;

procedure contra_sound_update;
begin
  ym2151_0.update;
end;

//Main
procedure reset_contra;
begin
 main_hd6309.reset;
 snd_m6809.reset;
 reset_audio;
 K007121_reset(0);
 K007121_reset(1);
 ym2151_0.reset;
 marcade.in0:=$FF;
 marcade.in1:=$FF;
 marcade.in2:=$ff;
 banco:=0;
 sound_latch:=0;
end;

function iniciar_contra:boolean;
var
  f:byte;
  memoria_temp:array[0..$7ffff] of byte;
const
    pc_x:array[0..7] of dword=(0, 4, 8, 12, 16, 20, 24, 28 );
    pc_y:array[0..7] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32);
procedure clut_contra;
var
  chip,pal,i,ctabentry,clut:byte;
begin
for chip:=0 to 1 do begin
		for pal:=0 to 7 do begin
			clut:=(chip shl 1) or (pal and 1);
			for i:=0 to $ff do begin
				if (((pal and $01)=0) and (memoria_temp[(clut shl 8) or i]=0)) then ctabentry:=0
				  else ctabentry:=(pal shl 4) or (memoria_temp[(clut shl 8) or i] and $0f);
        gfx[chip].colores[(pal shl 8) or i]:=ctabentry;
			end;
		end;
end;
end;
begin
iniciar_contra:=false;
iniciar_audio(true);
//Pantallas
screen_init(1,256,256,true);
screen_init(2,256,256);
screen_mod_scroll(2,256,256,255,256,256,255);
screen_init(3,256,256,true);
screen_mod_scroll(3,256,256,255,256,256,255);
screen_init(4,512,256,false,true);
iniciar_video(224,280);
//Main CPU
main_hd6309:=cpu_hd6309.create(24000000 div 2,$100);
main_hd6309.change_ram_calls(contra_getbyte,contra_putbyte);
//Sound CPU
snd_m6809:=cpu_m6809.Create(24000000 div 8,$100);
snd_m6809.change_ram_calls(sound_getbyte,sound_putbyte);
snd_m6809.init_sound(contra_sound_update);
//Audio chips
ym2151_0:=ym2151_chip.create(3579545);
//cargar roms
if not(cargar_roms(@memoria_temp[0],@contra_rom[0],'contra.zip',0)) then exit;
//Pongo las ROMs en su banco
copymemory(@memoria[$8000],@memoria_temp[$8000],$8000);
for f:=0 to 7 do copymemory(@memoria_rom[f,0],@memoria_temp[$10000+(f*$2000)],$2000);
for f:=0 to 3 do copymemory(@memoria_rom[8+f,0],@memoria_temp[0+(f*$2000)],$2000);
//Cargar Sound
if not(cargar_roms(@mem_snd[0],@contra_sound,'contra.zip',1)) then exit;
//convertir chars
if not(cargar_roms16b(@memoria_temp[0],@contra_chars[0],'contra.zip',0)) then exit;
init_gfx(0,8,8,$4000);
gfx[0].trans[0]:=true;
gfx_set_desc_data(4,0,32*8,0,1,2,3);
convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],true,false);
//chars 2
if not(cargar_roms16b(@memoria_temp[0],@contra_chars2[0],'contra.zip',0)) then exit;
init_gfx(1,8,8,$4000);
gfx[1].trans[0]:=true;
convert_gfx(1,0,@memoria_temp[0],@pc_x[0],@pc_y[0],true,false);
//Color lookup
if not(cargar_roms(@memoria_temp[0],@contra_proms,'contra.zip',0)) then exit;
clut_contra;
reset_contra;
iniciar_contra:=true;
end;

procedure Cargar_contra;
begin
llamadas_maquina.iniciar:=iniciar_contra;
llamadas_maquina.bucle_general:=contra_principal;
llamadas_maquina.reset:=reset_contra;
end;

end.
