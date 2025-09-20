unit wwfsuperstars_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,m68000,main_engine,controls_engine,gfx_engine,ym_2151,rom_engine,
     pal_engine,sound_engine,oki6295;

function iniciar_wwfsstar:boolean;

implementation
const
        wwfsstar_rom:array[0..1] of tipo_roms=(
        (n:'24ac-0_j-1.34';l:$20000;p:0;crc:$ec8fd2c9),(n:'24ad-0_j-1.35';l:$20000;p:$1;crc:$54e614e4));
        wwfsstar_sound:tipo_roms=(n:'24ab-0.12';l:$8000;p:0;crc:$1e44f8aa);
        wwfsstar_oki:array[0..1] of tipo_roms=(
        (n:'24a9-0.46';l:$20000;p:0;crc:$703ff08f),(n:'24j8-0.45';l:$20000;p:$20000;crc:$61138487));
        wwfsstar_char:tipo_roms=(n:'24aa-0_j.58';l:$20000;p:0;crc:$b9201b36);
        wwfsstar_sprites:array[0..5] of tipo_roms=(
        (n:'c951.114';l:$80000;p:0;crc:$fa76d1f0),(n:'24j4-0.115';l:$40000;p:$80000;crc:$c4a589a3),
        (n:'24j5-0.116';l:$40000;p:$0c0000;crc:$d6bca436),(n:'c950.117';l:$80000;p:$100000;crc:$cca5703d),
        (n:'24j2-0.118';l:$40000;p:$180000;crc:$dc1b7600),(n:'24j3-0.119';l:$40000;p:$1c0000;crc:$3ba12d43));
        wwfsstar_bg:array[0..1] of tipo_roms=(
        (n:'24j7-0.113';l:$40000;p:0;crc:$e0a1909e),(n:'24j6-0.112';l:$40000;p:$40000;crc:$77932ef8));
        //DIP
        wwfsstar_dip_a:array [0..3] of def_dip=(
        (mask:$7;name:'Coin A';number:8;dip:((dip_val:$0;dip_name:'4C 1C'),(dip_val:$1;dip_name:'3C 1C'),(dip_val:$2;dip_name:'2C 1C'),(dip_val:$7;dip_name:'1C 1C'),(dip_val:$6;dip_name:'1C 2C'),(dip_val:$5;dip_name:'1C 3C'),(dip_val:$4;dip_name:'1C 4C'),(dip_val:$3;dip_name:'1C 5C'),(),(),(),(),(),(),(),())),
        (mask:$38;name:'Coin B';number:8;dip:((dip_val:$0;dip_name:'4C 1C'),(dip_val:$8;dip_name:'3C 1C'),(dip_val:$10;dip_name:'2C 1C'),(dip_val:$38;dip_name:'1C 1C'),(dip_val:$30;dip_name:'1C 2C'),(dip_val:$28;dip_name:'1C 3C'),(dip_val:$20;dip_name:'1C 4C'),(dip_val:$18;dip_name:'1C 5C'),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Flip Screen';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        wwfsstar_dip_b:array [0..5] of def_dip=(
        (mask:$3;name:'Difficulty';number:4;dip:((dip_val:$1;dip_name:'Easy'),(dip_val:$3;dip_name:'Normal'),(dip_val:$2;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$4;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Super Techniques';number:2;dip:((dip_val:$8;dip_name:'Normal'),(dip_val:$0;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Time';number:4;dip:((dip_val:$20;dip_name:'+2:30'),(dip_val:$30;dip_name:'Default'),(dip_val:$10;dip_name:'-2:30'),(dip_val:$0;dip_name:'-5:00'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Health for Winning';number:2;dip:((dip_val:$80;dip_name:'No'),(dip_val:$0;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 scroll_x,scroll_y:word;
 rom:array[0..$1ffff] of word;
 fg_ram,bg_ram:array[0..$7ff] of word;
 ram:array[0..$1fff] of word;
 sound_latch:byte;

procedure update_video_wwfsstar;inline;
var
  f,x,y,nchar,pos,atrib,atrib2:word;
  a,color:byte;
  flipx,flipy:boolean;
begin
//background
for f:=$0 to $3ff do begin
  x:=f and $1f;
  y:=f shr 5;
  pos:=(x and $0f)+((y and $0f) shl 4)+((x and $10) shl 4)+((y and $10) shl 5);
  atrib:=(bg_ram[pos*2] and $ff) shr 4;
  color:=atrib and $7;
  if (gfx[1].buffer[pos] or buffer_color[color+$10]) then begin
    nchar:=(bg_ram[(pos*2)+1] and $ff) or ((bg_ram[pos*2] and $f) shl 8);
    put_gfx_trans_flip(x*16,y*16,nchar,(color shl 4)+256,3,1,(atrib and $8)<>0,false);
    gfx[1].buffer[pos]:=false;
  end;
  //text
  color:=(fg_ram[f*2] and $ff) shr 4;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
    nchar:=(fg_ram[(f*2)+1] and $ff) or ((fg_ram[f*2] and $f) shl 8);
    put_gfx_trans(x*8,y*8,nchar,color shl 4,1,0);
    gfx[0].buffer[f]:=false;
  end;
end;
scroll_x_y(3,2,scroll_x,scroll_y);
//Sprites
for f:=0 to $65 do begin
atrib:=buffer_sprites_w[(f*5)+1];
if (atrib and 1)<>0 then begin
  y:=(buffer_sprites_w[f*5] and $00ff) or ((atrib and $0004) shl 6);
  y:=(((256-y) and $1ff)-32);
  x:=(buffer_sprites_w[(f*5)+4] and $00ff) or ((atrib and $0008) shl 5);
  x:=(((256-x) and $1ff)-16);
  atrib2:=buffer_sprites_w[(f*5)+2];
  flipx:=(atrib2 and $0080)<>0;
  flipy:=(atrib2 and $0040)<>0;
  nchar:=(buffer_sprites_w[(f*5)+3] and $00ff) or ((atrib2 and $003f) shl 8);
  color:=atrib and $00f0;
  if (atrib and $0002)<>0 then begin //16x32
    nchar:=nchar and $3ffe;
    if flipy then a:=16
      else a:=0;
    put_gfx_sprite_diff(nchar,color+128,flipx,flipy,2,0,a);
    put_gfx_sprite_diff(nchar+1,color+128,flipx,flipy,2,0,a xor 16);
    actualiza_gfx_sprite_size(x,y,2,16,32);
  end else begin //16x16
    put_gfx_sprite(nchar,color+128,flipx,flipy,2);
    actualiza_gfx_sprite(x,y+16,2,2);
  end;
end;
end;
actualiza_trozo(0,0,256,256,1,0,0,256,256,2);
actualiza_trozo_final(0,8,256,240,2);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure eventos_wwfsstar;
begin
if event.arcade then begin
  //p1
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $Fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  //p2
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $Fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
  //system
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
end;
end;

procedure wwfsstar_principal;
var
  frame_m,frame_s:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
frame_s:=z80_0.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to 271 do begin
    //main
    m68000_0.run(frame_m);
    frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
    //sound
    z80_0.run(frame_s);
    frame_s:=frame_s+z80_0.tframes-z80_0.contador;
    case f of
      15,31,47,63,79,95,111,127,143,159,175,191,207,223,255:m68000_0.irq[5]:=ASSERT_LINE;
      239:begin
            m68000_0.irq[5]:=ASSERT_LINE;
            m68000_0.irq[6]:=ASSERT_LINE;
            update_video_wwfsstar;
            marcade.in2:=marcade.in2 or 1;
          end;
      271:marcade.in2:=marcade.in2 and $fe;
    end;
 end;
 eventos_wwfsstar;
 video_sync;
end;
end;

function wwfsstar_getword(direccion:dword):word;
begin
case direccion of
    0..$3ffff:wwfsstar_getword:=rom[direccion shr 1];
    $080000..$080fff:wwfsstar_getword:=fg_ram[(direccion and $fff) shr 1];
    $0c0000..$0c0fff:wwfsstar_getword:=bg_ram[(direccion and $fff) shr 1];
    $100000..$1003ff:wwfsstar_getword:=buffer_sprites_w[(direccion and $3ff) shr 1];
    $180000..$180001:wwfsstar_getword:=marcade.dswa;
    $180002..$180003:wwfsstar_getword:=marcade.dswb;
    $180004..$180005:wwfsstar_getword:=marcade.in0;
    $180006..$180007:wwfsstar_getword:=marcade.in1;
    $180008..$180009:wwfsstar_getword:=marcade.in2;
    $1c0000..$1c3fff:wwfsstar_getword:=ram[(direccion and $3fff) shr 1];
end;
end;

procedure cambiar_color(pos,data:word);inline;
var
  color:tcolor;
begin
  color.b:=pal4bit(data shr 8);
  color.g:=pal4bit(data shr 4);
  color.r:=pal4bit(data);
  set_pal_color(color,pos);
  case pos of
    $000..$0ff:buffer_color[pos shr 4]:=true;
    $100..$1ff:buffer_color[((pos shr 4) and $7)+$10]:=true;
  end;
end;

procedure wwfsstar_putword(direccion:dword;valor:word);
begin
case direccion of
    0..$3ffff:;
    $80000..$80fff:if fg_ram[(direccion and $fff) shr 1]<>valor then begin
                    fg_ram[(direccion and $fff) shr 1]:=valor;
                    gfx[0].buffer[(direccion and $fff) shr 2]:=true;
                  end;
    $c0000..$c0fff:if bg_ram[(direccion and $fff) shr 1]<>valor then begin
                    bg_ram[(direccion and $fff) shr 1]:=valor;
                    gfx[1].buffer[(direccion and $fff) shr 2]:=true;
                  end;
    $100000..$1003ff:buffer_sprites_w[(direccion and $3ff) shr 1]:=valor;
    $140000..$140fff:if buffer_paleta[(direccion and $fff) shr 1]<>valor then begin
                    buffer_paleta[(direccion and $fff) shr 1]:=valor;
                    cambiar_color((direccion and $fff) shr 1,valor);
                  end;
    $180000:m68000_0.irq[6]:=CLEAR_LINE;
    $180002:m68000_0.irq[5]:=CLEAR_LINE;
    $180004:scroll_x:=valor and $1ff;
    $180006:scroll_y:=valor and $1ff;
    $180008:begin
              z80_0.change_nmi(PULSE_LINE);
              sound_latch:=valor and $ff;
            end;
    $18000a:main_screen.flip_main_screen:=(valor and 1)<>0;
    $1c0000..$1c3fff:ram[(direccion and $3fff) shr 1]:=valor;
end;
end;

function wwfsstar_snd_getbyte(direccion:word):byte;
begin
case direccion of
    0..$87ff:wwfsstar_snd_getbyte:=mem_snd[direccion];
    $8801:wwfsstar_snd_getbyte:=ym2151_0.status;
    $9800:wwfsstar_snd_getbyte:=oki_6295_0.read;
    $a000:wwfsstar_snd_getbyte:=sound_latch;
  end;
end;

procedure wwfsstar_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:;
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

procedure wwfsstar_sound_update;
begin
  ym2151_0.update;
  oki_6295_0.update;
end;

//Main
procedure reset_wwfsstar;
begin
 m68000_0.reset;
 z80_0.reset;
 ym2151_0.reset;
 oki_6295_0.reset;
 reset_audio;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$fe;
 scroll_x:=0;
 scroll_y:=0;
 sound_latch:=0;
end;

function iniciar_wwfsstar:boolean;
var
  memoria_temp:pbyte;
const
  pc_x:array[0..7] of dword=(1, 0, 8*8+1, 8*8+0, 16*8+1, 16*8+0, 24*8+1, 24*8+0);
  ps_x:array[0..15] of dword=(3, 2, 1, 0, 16*8+3, 16*8+2, 16*8+1, 16*8+0,
          32*8+3, 32*8+2, 32*8+1, 32*8+0, 48*8+3, 48*8+2, 48*8+1, 48*8+0);
  ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
          8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8);
begin
llamadas_maquina.bucle_general:=wwfsstar_principal;
llamadas_maquina.reset:=reset_wwfsstar;
llamadas_maquina.fps_max:=57.444853;
iniciar_wwfsstar:=false;
iniciar_audio(false);
screen_init(1,256,256,true);
screen_init(2,512,512,false,true);
screen_init(3,512,512);
screen_mod_scroll(3,512,256,511,512,256,511);
iniciar_video(256,240);
//Main CPU
m68000_0:=cpu_m68000.create(10000000,272);
m68000_0.change_ram16_calls(wwfsstar_getword,wwfsstar_putword);
//Sound CPU
z80_0:=cpu_z80.create(3579545,272);
z80_0.change_ram_calls(wwfsstar_snd_getbyte,wwfsstar_snd_putbyte);
z80_0.init_sound(wwfsstar_sound_update);
//Sound Chips
ym2151_0:=ym2151_chip.create(3579545);
ym2151_0.change_irq_func(ym2151_snd_irq);
oki_6295_0:=snd_okim6295.Create(1056000,OKIM6295_PIN7_HIGH);
//Cargar ADPCM ROMS
if not(roms_load(oki_6295_0.get_rom_addr,wwfsstar_oki)) then exit;
//cargar roms
if not(roms_load16w(@rom,wwfsstar_rom)) then exit;
//cargar sonido
if not(roms_load(@mem_snd,wwfsstar_sound)) then exit;
getmem(memoria_temp,$200000);
//convertir chars
if not(roms_load(memoria_temp,wwfsstar_char)) then exit;
init_gfx(0,8,8,$1000);
gfx[0].trans[0]:=true;
gfx_set_desc_data(4,0,32*8,0,2,4,6);
convert_gfx(0,0,memoria_temp,@pc_x,@ps_y,false,false);
//convertir background
if not(roms_load(memoria_temp,wwfsstar_bg)) then exit;
init_gfx(1,16,16,$1000);
gfx_set_desc_data(4,0,64*8,$40000*8+0,$40000*8+4,0,4);
convert_gfx(1,0,memoria_temp,@ps_x,@ps_y,false,false);
//convertir sprites
if not(roms_load(memoria_temp,wwfsstar_sprites)) then exit;
init_gfx(2,16,16,$4000);
gfx[2].trans[0]:=true;
gfx_set_desc_data(4,0,64*8,$100000*8+0,$100000*8+4,0,4);
convert_gfx(2,0,memoria_temp,@ps_x,@ps_y,false,false);
//DIP
marcade.dswa:=$ff;
marcade.dswa_val:=@wwfsstar_dip_a;
marcade.dswb:=$ff;
marcade.dswb_val:=@wwfsstar_dip_b;
//final
freemem(memoria_temp);
reset_wwfsstar;
iniciar_wwfsstar:=true;
end;

end.
