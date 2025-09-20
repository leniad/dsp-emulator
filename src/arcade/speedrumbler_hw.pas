unit speedrumbler_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6809,nz80,ym_2203,main_engine,controls_engine,gfx_engine,rom_engine,
     pal_engine,sound_engine;

function iniciar_speedr:boolean;

implementation
const
        speedr_rom:array[0..7] of tipo_roms=(
        (n:'rc04.14e';l:$8000;p:$0;crc:$a68ce89c),(n:'rc03.13e';l:$8000;p:$8000;crc:$87bda812),
        (n:'rc02.12e';l:$8000;p:$10000;crc:$d8609cca),(n:'rc01.11e';l:$8000;p:$18000;crc:$27ec4776),
        (n:'rc09.14f';l:$8000;p:$20000;crc:$2146101d),(n:'rc08.13f';l:$8000;p:$28000;crc:$838369a6),
        (n:'rc07.12f';l:$8000;p:$30000;crc:$de785076),(n:'rc06.11f';l:$8000;p:$38000;crc:$a70f4fd4));
        speedr_sound:tipo_roms=(n:'rc05.2f';l:$8000;p:0;crc:$0177cebe);
        speedr_char:tipo_roms=(n:'rc10.6g';l:$4000;p:0;crc:$adabe271);
        speedr_tiles:array[0..7] of tipo_roms=(
        (n:'rc11.11a';l:$8000;p:$0;crc:$5fa042ba),(n:'rc12.13a';l:$8000;p:$8000;crc:$a2db64af),
        (n:'rc13.14a';l:$8000;p:$10000;crc:$f1df5499),(n:'rc14.15a';l:$8000;p:$18000;crc:$b22b31b3),
        (n:'rc15.11c';l:$8000;p:$20000;crc:$ca3a3af3),(n:'rc16.13c';l:$8000;p:$28000;crc:$c49a4a11),
        (n:'rc17.14c';l:$8000;p:$30000;crc:$aa80aaab),(n:'rc18.15c';l:$8000;p:$38000;crc:$ce67868e));
        speedr_sprites:array[0..7] of tipo_roms=(
        (n:'rc20.15e';l:$8000;p:$0;crc:$3924c861),(n:'rc19.14e';l:$8000;p:$8000;crc:$ff8f9129),
        (n:'rc22.15f';l:$8000;p:$10000;crc:$ab64161c),(n:'rc21.14f';l:$8000;p:$18000;crc:$fd64bcd1),
        (n:'rc24.15h';l:$8000;p:$20000;crc:$c972af3e),(n:'rc23.14h';l:$8000;p:$28000;crc:$8c9abf57),
        (n:'rc26.15j';l:$8000;p:$30000;crc:$d4f1732f),(n:'rc25.14j';l:$8000;p:$38000;crc:$d2a4ea4f));
        speedr_prom:array[0..1] of tipo_roms=(
        (n:'63s141.12a';l:$100;p:$0;crc:$8421786f),(n:'63s141.13a';l:$100;p:$100;crc:$6048583f));
        //Dip
        speedr_dip_a:array [0..3] of def_dip=(
        (mask:$7;name:'Coin B';number:8;dip:((dip_val:$0;dip_name:'4C 1C'),(dip_val:$1;dip_name:'3C 1C'),(dip_val:$2;dip_name:'2C 1C'),(dip_val:$7;dip_name:'1C 1C'),(dip_val:$6;dip_name:'1C 2C'),(dip_val:$5;dip_name:'1C 3C'),(dip_val:$4;dip_name:'1C 4C'),(dip_val:$3;dip_name:'1C 6C'),(),(),(),(),(),(),(),())),
        (mask:$38;name:'Coin A';number:8;dip:((dip_val:$0;dip_name:'4C 1C'),(dip_val:$8;dip_name:'3C 1C'),(dip_val:$10;dip_name:'2C 1C'),(dip_val:$38;dip_name:'1C 1C'),(dip_val:$30;dip_name:'1C 2C'),(dip_val:$28;dip_name:'1C 3C'),(dip_val:$20;dip_name:'1C 4C'),(dip_val:$18;dip_name:'1C 6C'),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Flip Screen';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        speedr_dip_b:array [0..5] of def_dip=(
        (mask:$3;name:'Lives';number:4;dip:((dip_val:$3;dip_name:'3'),(dip_val:$2;dip_name:'4'),(dip_val:$1;dip_name:'5'),(dip_val:$0;dip_name:'7'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$4;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$18;name:'Bonus Life';number:4;dip:((dip_val:$18;dip_name:'20K 70K+'),(dip_val:$10;dip_name:'30K 80K+'),(dip_val:$8;dip_name:'20K 80K'),(dip_val:$0;dip_name:'30K 80K'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$60;name:'Difficulty';number:4;dip:((dip_val:$40;dip_name:'Easy'),(dip_val:$60;dip_name:'Normal'),(dip_val:$20;dip_name:'Difficult'),(dip_val:$0;dip_name:'Very Difficult'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Allow Continue';number:2;dip:((dip_val:$0;dip_name:'No'),(dip_val:$80;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 memoria_rom:array[0..$3f,0..$fff] of byte;
 prom_bank:array[0..$1ff] of byte;
 memoria_fg:array[0..$fff] of byte;
 soundlatch:byte;
 scroll_x,scroll_y:word;

procedure update_video_speedr;
var
  x,y,f,color,nchar:word;
  atrib:byte;
begin
//background
for f:=$0 to $fff do begin
    atrib:=memoria[$2000+(f*2)];
    color:=(atrib and $e0) shr 5;
    if (gfx[1].buffer[f] or buffer_color[color+$10]) then begin
      x:=f mod 64;
      y:=63-(f div 64);
      nchar:=memoria[$2001+(f*2)]+((atrib and $7) shl 8);
      put_gfx_flip(x*16,y*16,nchar,(color shl 4)+$80,2,1,(atrib and 8)<>0,false);
      if (atrib and $10)<>0 then put_gfx_trans_flip(x*16,y*16,nchar,(color shl 4)+$80,3,1,(atrib and 8)<>0,false)
        else put_gfx_block_trans(x*16,y*16,3,16,16);
      gfx[1].buffer[f]:=false;
    end;
end;
//foreground
for f:=$0 to $7ff do begin
    atrib:=memoria_fg[f*2];
    color:=(atrib and $3c) shr 2;
    if (gfx[0].buffer[f] or buffer_color[color]) then begin
      x:=f mod 32;
      y:=63-(f div 32);
      nchar:=memoria_fg[$1+(f*2)]+((atrib and $3) shl 8);
      if (atrib and $40)<>0 then put_gfx(x*8,y*8,nchar,(color shl 2)+$1c0,1,0)
        else put_gfx_trans(x*8,y*8,nchar,(color shl 2)+$1c0,1,0);
      gfx[0].buffer[f]:=false;
    end;
end;
scroll_x_y(2,4,scroll_x,512-scroll_y);
//sprites
for f:=$7f downto 0 do begin
    atrib:=buffer_sprites[(f shl 2)+1];
    nchar:=buffer_sprites[f shl 2]+((atrib and $e0) shl 3);
    color:=((atrib and $1c) shl 2)+$100;
    x:=buffer_sprites[$2+(f shl 2)];
    y:=496-(buffer_sprites[$3+(f shl 2)]+((atrib and $1) shl 8));
    put_gfx_sprite(nchar,color,(atrib and 2)<>0,false,2);
    actualiza_gfx_sprite(x,y,4,2);
end;
scroll_x_y(3,4,scroll_x,512-scroll_y);
actualiza_trozo(0,0,256,512,1,0,0,256,512,4);
//Actualiza buffer sprites
copymemory(@buffer_sprites,@memoria[$1e00],$200);
//chars
actualiza_trozo_final(8,80,240,352,4);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
end;

procedure eventos_speedr;
begin
if event.arcade then begin
  //P1
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  //P2
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  //SYS
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
end;
end;

procedure speedr_principal;
var
  f:byte;
  frame_m,frame_s:single;
begin
init_controls(false,false,false,true);
frame_m:=m6809_0.tframes;
frame_s:=z80_0.tframes;
while EmuStatus=EsRunning do begin
  for f:=0 to $ff do begin
    //Main CPU
    m6809_0.run(frame_m);
    frame_m:=frame_m+m6809_0.tframes-m6809_0.contador;
    //Sound CPU
    z80_0.run(frame_s);
    frame_s:=frame_s+z80_0.tframes-z80_0.contador;
    case f of
      0:m6809_0.change_firq(HOLD_LINE);
      248:begin
            update_video_speedr;
            m6809_0.change_irq(HOLD_LINE);
          end;
    end;
  end;
  eventos_speedr;
  video_sync;
end;
end;

procedure cambiar_color(pos:word);
var
  tmp_color:byte;
  color:tcolor;
begin
  tmp_color:=buffer_paleta[pos];
  color.r:=pal4bit(tmp_color shr 4);
  color.g:=pal4bit(tmp_color);
  tmp_color:=buffer_paleta[$1+pos];
  color.b:=pal4bit(tmp_color shr 4);
  pos:=pos shr 1;
  set_pal_color(color,pos);
  case pos of
    $80..$ff:buffer_color[((pos shr 4) and $7)+$10]:=true;
    $1c0..$1ff:buffer_color[(pos shr 2) and $f]:=true;
  end;
end;

procedure cambiar_banco(valor:byte);
var
  f,bank:byte;
  pos1,pos2:word;
begin
  pos1:=valor and $f0;
  pos2:=$100+((valor and $f) shl 4);
  for f:=5 to $f do begin
    bank:=((prom_bank[f+pos1] and $03) shl 4) or (prom_bank[f+pos2] and $0f);
    copymemory(@memoria[f*$1000],@memoria_rom[bank,0],$1000);
  end;
end;

function speedr_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$3fff,$5000..$ffff:speedr_getbyte:=memoria[direccion];
  $4008:speedr_getbyte:=marcade.in0;
  $4009:speedr_getbyte:=marcade.in1;
  $400a:speedr_getbyte:=marcade.in2;
  $400b:speedr_getbyte:=marcade.dswa;
  $400c:speedr_getbyte:=marcade.dswb;
end;
end;

procedure speedr_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$1fff:memoria[direccion]:=valor;
  $2000..$3fff:if memoria[direccion]<>valor then begin
                  memoria[direccion]:=valor;
                  gfx[1].buffer[(direccion and $1fff) shr 1]:=true;
               end;
  $4009:main_screen.flip_main_screen:=(valor and 1)<>0;
  $4008:cambiar_banco(valor);
  $400a:scroll_y:=(scroll_y and $300) or valor;
  $400b:scroll_y:=(scroll_y and $ff) or ((valor and 3) shl 8);
  $400c:scroll_x:=(scroll_x and $300) or valor;
  $400d:scroll_x:=(scroll_x and $ff) or ((valor and 3) shl 8);
  $400e:soundlatch:=valor;
  $5000..$5fff:if memoria_fg[direccion and $fff]<>valor then begin
                  gfx[0].buffer[(direccion and $fff) shr 1]:=true;
                  memoria_fg[direccion and $fff]:=valor;
               end;
  $7000..$73ff:if buffer_paleta[direccion and $3ff]<>valor then begin
                 buffer_paleta[direccion and $3ff]:=valor;
                 cambiar_color(direccion and $3fe);
               end;
  $6000..$6fff,$7400..$ffff:; //ROM
end;
end;

function sound_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff,$c000..$c7ff:sound_getbyte:=mem_snd[direccion];
  $e000:sound_getbyte:=soundlatch;
end;
end;

procedure sound_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:; //ROM
  $c000..$c7ff:mem_snd[direccion]:=valor;
  $8000:ym2203_0.Control(valor);
  $8001:ym2203_0.Write(valor);
  $a000:ym2203_1.Control(valor);
  $a001:ym2203_1.Write(valor);
end;
end;

procedure speedr_sound_update;
begin
  ym2203_0.update;
  ym2203_1.update;
end;

procedure snd_irq(irqstate:byte);
begin
  z80_0.change_irq(irqstate);
end;

//Main
procedure reset_speedr;
begin
 //Poner el banco antes que el reset!!!
 cambiar_banco(0);
 m6809_0.reset;
 z80_0.reset;
 ym2203_0.reset;
 ym2203_1.reset;
 reset_video;
 reset_audio;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 soundlatch:=0;
 scroll_x:=0;
 scroll_y:=0;
end;

function iniciar_speedr:boolean;
var
  f:byte;
  memoria_temp:array[0..$3ffff] of byte;
const
    ps_x:array[0..15] of dword=(0, 1, 2, 3, 4, 5, 6, 7,
			2*64+0, 2*64+1, 2*64+2, 2*64+3, 2*64+4, 2*64+5, 2*64+6, 2*64+7);
    ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8);
    pt_x:array[0..15] of dword=(0, 1, 2, 3, 8+0, 8+1, 8+2, 8+3,
			32*8+0, 32*8+1, 32*8+2, 32*8+3, 33*8+0, 33*8+1, 33*8+2, 33*8+3);
    pt_y:array[0..15] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16,
			8*16, 9*16, 10*16, 11*16, 12*16, 13*16, 14*16, 15*16);
begin
llamadas_maquina.bucle_general:=speedr_principal;
llamadas_maquina.reset:=reset_speedr;
iniciar_speedr:=false;
iniciar_audio(false);
//Background
screen_init(1,256,512,true);
//Foreground
screen_init(2,1024,1024);
screen_mod_scroll(2,1024,256,1023,1024,512,1023);
screen_init(3,1024,1024,true);
screen_mod_scroll(3,1024,256,1023,1024,512,1023);
screen_init(4,256,512,false,true); //Final
iniciar_video(240,352);
//Main CPU
m6809_0:=cpu_m6809.Create(8000000,256,TCPU_MC6809);
m6809_0.change_ram_calls(speedr_getbyte,speedr_putbyte);
//Sound CPU
z80_0:=cpu_z80.create(4000000,256);
z80_0.change_ram_calls(sound_getbyte,sound_putbyte);
z80_0.init_sound(speedr_sound_update);
//Sound Chip
ym2203_0:=ym2203_chip.create(4000000);
ym2203_0.change_irq_calls(snd_irq);
ym2203_1:=ym2203_chip.create(4000000);
//cargar roms
if not(roms_load(@memoria_temp,speedr_rom)) then exit;
if not(roms_load(@prom_bank,speedr_prom)) then exit;
//Pongo las ROMs en su banco
for f:=0 to $3f do copymemory(@memoria_rom[f,0],@memoria_temp[(f*$1000)],$1000);
//Cargar Sound
if not(roms_load(@mem_snd,speedr_sound)) then exit;
//convertir chars
if not(roms_load(@memoria_temp,speedr_char)) then exit;
init_gfx(0,8,8,$400);
gfx[0].trans[3]:=true;
gfx_set_desc_data(2,0,16*8,4,0);
convert_gfx(0,0,@memoria_temp,@pt_x,@pt_y,false,true);
//tiles
if not(roms_load(@memoria_temp,speedr_tiles)) then exit;
init_gfx(1,16,16,$800);
for f:=0 to 10 do gfx[1].trans[f]:=true;
gfx_set_desc_data(4,0,64*8,$800*64*8+4,$800*64*8+0,4,0);
convert_gfx(1,0,@memoria_temp,@pt_x,@pt_y,false,true);
//sprites
if not(roms_load(@memoria_temp,speedr_sprites)) then exit;
init_gfx(2,16,16,$800);
gfx[2].trans[15]:=true;
gfx_set_desc_data(4,0,32*8,$1800*32*8,$1000*32*8,$800*32*8,$0*32*8);
convert_gfx(2,0,@memoria_temp,@ps_x,@ps_y,false,true);
//Dip
marcade.dswa:=$ff;
marcade.dswb:=$73;
marcade.dswa_val:=@speedr_dip_a;
marcade.dswb_val:=@speedr_dip_b;
//final
reset_speedr;
iniciar_speedr:=true;
end;

end.
