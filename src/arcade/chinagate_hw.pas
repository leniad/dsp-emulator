unit chinagate_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     hd6309,nz80,ym_2151,main_engine,controls_engine,gfx_engine,oki6295,
     rom_engine,pal_engine,sound_engine;

function iniciar_chinagate:boolean;

implementation
const
        chinagate_rom:tipo_roms=(n:'cgate51.bin';l:$20000;p:$0;crc:$439a3b19);
        chinagate_sub:tipo_roms=(n:'23j4-0.48';l:$20000;p:$0;crc:$2914af38);
        chinagate_snd:tipo_roms=(n:'23j0-0.40';l:$8000;p:$0;crc:$9ffcadb6);
        chinagate_char:tipo_roms=(n:'cgate18.bin';l:$20000;p:0;crc:$8d88d64d);
        chinagate_tiles:array[0..3] of tipo_roms=(
        (n:'chinagat_a-13';l:$10000;p:0;crc:$b745cac4),(n:'chinagat_a-12';l:$10000;p:$10000;crc:$3c864299),
        (n:'chinagat_a-15';l:$10000;p:$20000;crc:$2f268f37),(n:'chinagat_a-14';l:$10000;p:$30000;crc:$aef814c8));
        chinagate_sprites:array[0..3] of tipo_roms=(
        (n:'23j7-0.103';l:$20000;p:0;crc:$2f445030),(n:'23j8-0.102';l:$20000;p:$20000;crc:$237f725a),
        (n:'23j9-0.101';l:$20000;p:$40000;crc:$8caf6097),(n:'23ja-0.100';l:$20000;p:$60000;crc:$f678594f));
        chinagate_adpcm:array[0..1] of tipo_roms=(
        (n:'23j1-0.53';l:$20000;p:0;crc:$f91f1001),(n:'23j2-0.52';l:$20000;p:$20000;crc:$8b6f26e9));
        chinagate_dip_a:array [0..4] of def_dip2=(
        (mask:$7;name:'Coin A';number:8;val8:(0,1,2,7,6,5,4,3);name8:('4C 1C','3C 1C','2C 1C','1C 1C','1C 2C','1C 3C','1C 4C','1C 5C')),
        (mask:$38;name:'Coin B';number:8;val8:(0,8,$10,$38,$30,$28,$20,$18);name8:('4C 1C','3C 1C','2C 1C','1C 1C','1C 2C','1C 3C','1C 4C','1C 5C')),
        (mask:$40;name:'Cabinet';number:2;val2:(0,$40);name2:('Upright','Cocktail')),
        (mask:$80;name:'Flip Screen';number:2;val2:($80,0);name2:('Off','On')),());
        chinagate_dip_b:array [0..4] of def_dip2=(
        (mask:$3;name:'Difficulty';number:4;val4:(1,3,2,0);name4:('Easy','Normal','Hard','Hardest')),
        (mask:$4;name:'Demo Sounds';number:2;val2:(0,4);name2:('Off','On')),
        (mask:$30;name:'Timer';number:4;val4:(0,$20,$30,$10);name4:('50','55','60','70')),
        (mask:$c0;name:'Lives';number:4;val4:(0,$c0,$80,$40);name4:('1','2','3','4')),());
        CPU_SYNC=4;

var
 rom,rom_sub:array[0..7,0..$3fff] of byte;
 banco_rom,banco_rom_sub,soundlatch:byte;
 scroll_x,scroll_y:word;

procedure update_video_chinagate;
procedure draw_sprites;
var
  size,x,y,nchar:word;
  color,f,atrib:byte;
  flipx,flipy:boolean;
begin
	for f:=0 to $3f do begin
		atrib:=memoria[$3801+(f*5)];
		if (atrib and $80)<>0 then begin  // visible
			x:=240-memoria[$3804+(f*5)]+((atrib and 2) shl 7);
			y:=240-memoria[$3800+(f*5)]+ ((atrib and 1) shl 8);
			size:=(atrib and $30) shr 4;
			flipx:=(atrib and 8)<>0;
			flipy:=(atrib and 4)<>0;
      color:=(memoria[$3802+(f*5)] and $70)+$80;
			nchar:=memoria[$3803+(f*5)]+((memoria[$3802+(f*5)] and $f) shl 8);
			nchar:=nchar and not(size);
			case size of
				0:begin // normal
             put_gfx_sprite(nchar,color,flipx,flipy,2);
             actualiza_gfx_sprite(x,y,3,2);
				  end;
				1:begin // double y
             put_gfx_sprite_diff(nchar,color,flipx,flipy,2,0,0);
             put_gfx_sprite_diff(nchar+1,color,flipx,flipy,2,0,16);
             actualiza_gfx_sprite_size(x,y-16,3,16,32);
				  end;
				2:begin // double x
             put_gfx_sprite_diff(nchar,color,flipx,flipy,2,0,0);
             put_gfx_sprite_diff(nchar+1,color,flipx,flipy,2,16,0);
             actualiza_gfx_sprite_size(x-16,y,3,32,16);
				  end;
				3:begin
             put_gfx_sprite_diff(nchar,color,flipx,flipy,2,0,0);
             put_gfx_sprite_diff(nchar+1,color,flipx,flipy,2,16,0);
             put_gfx_sprite_diff(nchar+2,color,flipx,flipy,2,0,16);
             put_gfx_sprite_diff(nchar+3,color,flipx,flipy,2,16,16);
             actualiza_gfx_sprite_size(x-16,y-16,3,32,32);
				  end;
			end;
		end;  //visible
	end;  //for
end;
var
  x,y,color,f,nchar,pos:word;
  atrib:byte;
begin
for f:=$0 to $3ff do begin
  x:=f mod 32;
  y:=f div 32;
  //background
  pos:=(x and $0f)+((y and $0f) shl 4)+((x and $10) shl 4)+((y and $10) shl 5);
  atrib:=memoria[(pos*2)+$2800];
  color:=(atrib and $38) shr 3;
  if (gfx[1].buffer[pos] or buffer_color[color+8]) then begin
      nchar:=memoria[(pos*2)+$2801]+((atrib and $7) shl 8);
      put_gfx_flip(x*16,y*16,nchar,$100+(color shl 4),2,1,(atrib and $40)<>0,(atrib and $80)<>0);
      gfx[1].buffer[pos]:=false;
  end;
  //foreground
  atrib:=memoria[$2000+(f*2)];
  color:=(atrib and $f0) shr 4;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
      nchar:=memoria[$2001+(f*2)]+((atrib and $f) shl 8);
      put_gfx_trans(x*8,y*8,nchar,color shl 4,1,0);
      gfx[0].buffer[f]:=false;
   end;
end;
scroll_x_y(2,3,scroll_x,scroll_y);
draw_sprites;
actualiza_trozo(0,0,256,256,1,0,0,256,256,3);
actualiza_trozo_final(0,8,256,240,3);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
end;

procedure eventos_chinagate;
begin
if event.arcade then begin
  //p1
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.but2[0] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
  //p2
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.but2[1] then marcade.in2:=(marcade.in2 and $bf) else marcade.in2:=(marcade.in2 or $40);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 and $7f) else marcade.in2:=(marcade.in2 or $80);
  //system
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
end;
end;

procedure chinagate_principal;
var
  f:word;
  frame_m,frame_s,frame_snd:single;
  h:byte;
begin
init_controls(false,false,false,true);
frame_m:=hd6309_0.tframes;
frame_s:=hd6309_1.tframes;
frame_snd:=z80_0.tframes;
while EmuStatus=EsRunning do begin
  for f:=0 to 271 do begin
    //video
    case f of
      8:marcade.in0:=marcade.in0 and $fe;
      248:begin
            hd6309_0.change_nmi(ASSERT_LINE);
            update_video_chinagate;
            marcade.in0:=marcade.in0 or 1;
          end;
    end;
    if (((f mod 16)=0) and (f<240)) then hd6309_0.change_firq(ASSERT_LINE);
    for h:=1 to CPU_SYNC do begin
      //main
      hd6309_0.run(frame_m);
      frame_m:=frame_m+hd6309_0.tframes-hd6309_0.contador;
      //sub
      hd6309_1.run(frame_s);
      frame_s:=frame_s+hd6309_1.tframes-hd6309_1.contador;
      //snd
      z80_0.run(frame_snd);
      frame_snd:=frame_snd+z80_0.tframes-z80_0.contador;
    end;
  end;
  eventos_chinagate;
  video_sync;
end;
end;

function chinagate_getbyte(direccion:word):byte;
begin
    case direccion of
        $0..$1fff,$2000..$2fff,$3800..$397f,$8000..$ffff:chinagate_getbyte:=memoria[direccion];
        $3f00:chinagate_getbyte:=marcade.in0;
        $3f01:chinagate_getbyte:=marcade.dswa;
        $3f02:chinagate_getbyte:=marcade.dswb;
        $3f03:chinagate_getbyte:=marcade.in1;
        $3f04:chinagate_getbyte:=marcade.in2;
        $4000..$7fff:chinagate_getbyte:=rom[banco_rom,direccion and $3fff];
    end;
end;

procedure chinagate_putbyte(direccion:word;valor:byte);
procedure cambiar_color(pos:word);
var
  tmp_color:byte;
  color:tcolor;
begin
  tmp_color:=buffer_paleta[pos];
  color.r:=pal4bit(tmp_color);
  color.g:=pal4bit(tmp_color shr 4);
  tmp_color:=buffer_paleta[pos+$400];
  color.b:=pal4bit(tmp_color);
  set_pal_color(color,pos);
  case pos of
    0..127:buffer_color[pos shr 4]:=true;
    256..383:buffer_color[((pos shr 4) and $7)+8]:=true;
  end;
end;
begin
case direccion of
        0..$1fff,$3800..$397f:memoria[direccion]:=valor;
        $2000..$27ff:if memoria[direccion]<>valor then begin
                        gfx[0].buffer[(direccion and $7ff) shr 1]:=true;
                        memoria[direccion]:=valor;
                     end;
        $2800..$2fff:if memoria[direccion]<>valor then begin
                        gfx[1].buffer[(direccion and $7ff) shr 1]:=true;
                        memoria[direccion]:=valor;
                     end;
        $3000..$37ff:if buffer_paleta[direccion and $7ff]<>valor then begin
                        buffer_paleta[direccion and $7ff]:=valor;
                        cambiar_color(direccion and $3ff);
                     end;
        $3e00:begin
                soundlatch:=valor;
                z80_0.change_nmi(ASSERT_LINE);
              end;
        $3e01:hd6309_0.change_nmi(CLEAR_LINE);
        $3e02:hd6309_0.change_firq(CLEAR_LINE);
        $3e03:hd6309_0.change_irq(CLEAR_LINE);
        $3e04:hd6309_1.change_irq(ASSERT_LINE);
        $3e06:scroll_y:=(scroll_y and $100) or valor;
        $3e07:scroll_x:=(scroll_x and $100) or valor;
        $3f00:begin
                scroll_x:=(scroll_x and $ff) or ((valor and $1) shl 8);
                scroll_y:=(scroll_y and $ff) or ((valor and $2) shl 7);
                main_screen.flip_main_screen:=(valor and 4)=0;
              end;
        $3f01:banco_rom:=valor and $7;
        $4000..$ffff:; //ROM
end;
end;

function chinagate_sub_getbyte(direccion:word):byte;
begin
case direccion of
  0..$1fff:chinagate_sub_getbyte:=memoria[direccion];
  $4000..$7fff:chinagate_sub_getbyte:=rom_sub[banco_rom_sub,direccion and $3fff];
  $8000..$ffff:chinagate_sub_getbyte:=mem_misc[direccion];
end;
end;

procedure chinagate_sub_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$1fff:memoria[direccion]:=valor;
  $2000:banco_rom_sub:=valor and 7;
  $2800:hd6309_1.change_irq(CLEAR_LINE);
  $4000..$ffff:;
end;
end;

function chinagate_snd_getbyte(direccion:word):byte;
begin
case direccion of
    0..$87ff:chinagate_snd_getbyte:=mem_snd[direccion];
    $8801:chinagate_snd_getbyte:=ym2151_0.status;
    $9800:chinagate_snd_getbyte:=oki_6295_0.read;
    $a000:begin
            chinagate_snd_getbyte:=soundlatch;
            z80_0.change_nmi(CLEAR_LINE);
          end;
  end;
end;

procedure chinagate_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:; //ROM
  $8000..$87ff:mem_snd[direccion]:=valor;
  $8800:ym2151_0.reg(valor);
  $8801:ym2151_0.write(valor);
  $9800:oki_6295_0.write(valor);
end;
end;

procedure ym2151_snd_irq(irqstate:byte);
begin
  z80_0.change_irq(irqstate);
end;

procedure chinagate_sound_update;
begin
  ym2151_0.update;
  oki_6295_0.update;
end;

//Main
procedure reset_chinagate;
begin
 hd6309_0.reset;
 hd6309_1.reset;
 z80_0.reset;
 ym2151_0.reset;
 oki_6295_0.reset;
 reset_audio;
 marcade.in0:=$e;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 soundlatch:=0;
 banco_rom:=0;
 banco_rom_sub:=0;
 scroll_x:=0;
 scroll_y:=0;
end;

function iniciar_chinagate:boolean;
var
  f:word;
  memoria_temp:array[0..$7ffff] of byte;
const
    pc_x:array[0..7] of dword=(1, 0, 65, 64, 129, 128, 193, 192);
    pt_x:array[0..15] of dword=(3, 2, 1, 0, 16*8+3, 16*8+2, 16*8+1, 16*8+0,
		32*8+3,32*8+2 ,32*8+1 ,32*8+0 ,48*8+3 ,48*8+2 ,48*8+1 ,48*8+0);
    pt_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
		  8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8);
begin
llamadas_maquina.bucle_general:=chinagate_principal;
llamadas_maquina.reset:=reset_chinagate;
llamadas_maquina.fps_max:=6000000/384/272;
iniciar_chinagate:=false;
iniciar_audio(false);
screen_init(1,256,256,true);
screen_init(2,512,512);
screen_mod_scroll(2,512,256,511,512,256,511);
screen_init(3,512,512,false,true);
iniciar_video(256,240);
//Main CPU
hd6309_0:=cpu_hd6309.create(12000000 div 2,272*CPU_SYNC,TCPU_HD6309);
hd6309_0.change_ram_calls(chinagate_getbyte,chinagate_putbyte);
if not(roms_load(@memoria_temp,chinagate_rom)) then exit;
copymemory(@memoria[$8000],@memoria_temp[$18000],$8000);
for f:=0 to 5 do copymemory(@rom[f,0],@memoria_temp[(f*$4000)],$4000);
//Sub CPU
hd6309_1:=cpu_hd6309.create(12000000 div 2,272*CPU_SYNC,TCPU_HD6309);
hd6309_1.change_ram_calls(chinagate_sub_getbyte,chinagate_sub_putbyte);
if not(roms_load(@memoria_temp,chinagate_sub)) then exit;
copymemory(@mem_misc[$8000],@memoria_temp[$18000],$8000);
for f:=0 to 5 do copymemory(@rom_sub[f,0],@memoria_temp[(f*$4000)],$4000);
//Sound CPU
z80_0:=cpu_z80.create(3579545,272*CPU_SYNC);
z80_0.change_ram_calls(chinagate_snd_getbyte,chinagate_snd_putbyte);
z80_0.init_sound(chinagate_sound_update);
if not(roms_load(@mem_snd,chinagate_snd)) then exit;
//Sound Chips
ym2151_0:=ym2151_chip.create(3579545);
ym2151_0.change_irq_func(ym2151_snd_irq);
oki_6295_0:=snd_okim6295.Create(1056000,OKIM6295_PIN7_HIGH,0.5);
if not(roms_load(oki_6295_0.get_rom_addr,chinagate_adpcm)) then exit;
//convertir chars
if not(roms_load(@memoria_temp,chinagate_char)) then exit;
init_gfx(0,8,8,$1000);
gfx[0].trans[0]:=true;
gfx_set_desc_data(4,0,32*8,0,2,4,6);
convert_gfx(0,0,@memoria_temp,@pc_x,@pt_y,false,false);
//convertir tiles
if not(roms_load(@memoria_temp,chinagate_tiles)) then exit;
init_gfx(1,16,16,$800);
gfx_set_desc_data(4,0,64*8,$800*64*8+0,$800*64*8+4,0,4);
convert_gfx(1,0,@memoria_temp,@pt_x,@pt_y,false,false);
//convertir sprites
if not(roms_load(@memoria_temp,chinagate_sprites)) then exit;
init_gfx(2,16,16,$1000);
gfx[2].trans[0]:=true;
gfx_set_desc_data(4,0,64*8,$1000*64*8+0,$1000*64*8+4,0,4);
convert_gfx(2,0,@memoria_temp,@pt_x,@pt_y,false,false);
//DIP
marcade.dswa:=$bf;
marcade.dswb:=$e7;
marcade.dswa_val2:=@chinagate_dip_a;
marcade.dswb_val2:=@chinagate_dip_b;
//final
reset_chinagate;
iniciar_chinagate:=true;
end;

end.
