unit blockout_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,m68000,main_engine,controls_engine,gfx_engine,ym_2151,rom_engine,
     pal_engine,sound_engine,oki6295;

procedure cargar_blockout;

implementation
const
        blockout_rom:array[0..2] of tipo_roms=(
        (n:'bo29a0-2.bin';l:$20000;p:0;crc:$b0103427),(n:'bo29a1-2.bin';l:$20000;p:$1;crc:$5984d5a2),());
        blockout_sound:tipo_roms=(n:'bo29e3-0.bin';l:$8000;p:0;crc:$3ea01f78);
        blockout_oki:tipo_roms=(n:'bo29e2-0.bin';l:$20000;p:0;crc:$15c5a99d);
        //DIP
        blockout_dipa:array [0..3] of def_dip=(
        (mask:$3;name:'Coinage';number:4;dip:((dip_val:$0;dip_name:'3C 1C'),(dip_val:$1;dip_name:'2C 1C'),(dip_val:$3;dip_name:'1C 1C'),(dip_val:$2;dip_name:'1C 2C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'1 Coint to Continue';number:2;dip:((dip_val:$10;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$20;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        blockout_dipb:array [0..2] of def_dip=(
        (mask:$3;name:'Difficulty';number:4;dip:((dip_val:$2;dip_name:'Easy'),(dip_val:$3;dip_name:'Normal'),(dip_val:$1;dip_name:'Hard'),(dip_val:$0;dip_name:'Very Hard'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Rotate Buttons';number:2;dip:((dip_val:$0;dip_name:'2'),(dip_val:$4;dip_name:'3'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 rom:array[0..$1ffff] of word;
 ram,ram2:array[0..$5fff] of word;
 ram3:array[0..$bfff] of word;
 video_ram:array[0..$1ffff] of word;
 video_ram_buff:array[0..$1ffff] of boolean;
 fvideo_ram:array[0..$7fff] of byte;
 sound_latch:byte;

procedure update_video_blockout;
var
  x,y,atrib:word;
  punt:array[0..319] of word;
  front,back:word;
begin
fill_full_screen(2,max_colores);
for y:=0 to $ff do begin
  fillword(@punt[0],320,paleta[max_colores]);
  for x:=0 to $27 do begin
    atrib:=fvideo_ram[(y*64+x)*2];
    if (atrib<>0) then begin
				if (atrib and $80)<>0 then punt[0+(x*8)]:=paleta[512];
				if (atrib and $40)<>0 then punt[1+(x*8)]:=paleta[512];
				if (atrib and $20)<>0 then punt[2+(x*8)]:=paleta[512];
				if (atrib and $10)<>0 then punt[3+(x*8)]:=paleta[512];
				if (atrib and $08)<>0 then punt[4+(x*8)]:=paleta[512];
				if (atrib and $04)<>0 then punt[5+(x*8)]:=paleta[512];
				if (atrib and $02)<>0 then punt[6+(x*8)]:=paleta[512];
				if (atrib and $01)<>0 then punt[7+(x*8)]:=paleta[512];
    end;
  end;
  putpixel(0,y,320,@punt[0],2);
end;
for y:=0 to $ff do begin
  for x:=0 to 159 do begin
      if video_ram_buff[(y*256)+x] then begin
        front:=video_ram[(y*256)+x];
	      back:=video_ram[$10000+(y*256)+x];
	      if (front shr 8)<>0 then punt[0]:=paleta[front shr 8]
	        else punt[0]:=paleta[(back shr 8)+256];
	      if (front and $ff)<>0 then punt[1]:=paleta[front and $ff]
	        else punt[1]:=paleta[(back and $ff)+256];
        putpixel(x*2,y,2,@punt[0],1);
        video_ram_buff[(y*256)+x]:=false;
      end;
  end;
end;
actualiza_trozo(0,0,320,256,1,0,0,320,256,3);
actualiza_trozo(0,0,320,256,2,0,0,320,256,3);
actualiza_trozo_final(0,8,320,240,3);
end;

procedure eventos_blockout;inline;
begin
if event.arcade then begin
  //p1
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but2[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.but3[0] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
  if arcade_input.but0[0] then marcade.dswa:=(marcade.dswa and $bf) else marcade.dswa:=(marcade.dswa or $40);
  //p2
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.but2[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.but3[1] then marcade.in2:=(marcade.in2 and $bf) else marcade.in2:=(marcade.in2 or $40);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 and $7f) else marcade.in2:=(marcade.in2 or $80);
  if arcade_input.but0[1] then marcade.dswa:=(marcade.dswa and $7f) else marcade.dswa:=(marcade.dswa or $80);
  //system
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
end;
end;

procedure blockout_principal;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=main_m68000.tframes;
frame_s:=snd_z80.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to $ff do begin
    //main
    main_m68000.run(frame_m);
    frame_m:=frame_m+main_m68000.tframes-main_m68000.contador;
    //sound
    snd_z80.run(frame_s);
    frame_s:=frame_s+snd_z80.tframes-snd_z80.contador;
    case f of
      247:begin
            main_m68000.irq[6]:=ASSERT_LINE;
            update_video_blockout;
          end;
      255:main_m68000.irq[5]:=ASSERT_LINE;
    end;
 end;
 eventos_blockout;
 video_sync;
end;
end;

function blockout_getword(direccion:dword):word;
begin
case direccion of
    0..$3ffff:blockout_getword:=rom[direccion shr 1];
    $100000:blockout_getword:=marcade.in1; //p1
    $100002:blockout_getword:=marcade.in2; //p2
    $100004:blockout_getword:=marcade.in0; //sys
    $100006:blockout_getword:=marcade.dswa; //dsw1
    $100008:blockout_getword:=marcade.dswb; //dsw2
    $180000..$1bffff:blockout_getword:=video_ram[(direccion and $3ffff) shr 1];
    $1d4000..$1dffff:blockout_getword:=ram[(direccion-$1d4000) shr 1];
    $1f4000..$1fffff:blockout_getword:=ram2[(direccion-$1f4000) shr 1];
    $200000..$207fff:blockout_getword:=fvideo_ram[direccion and $7fff];
    $208000..$21ffff:blockout_getword:=ram3[(direccion-$208000) shr 1];
    $280002:blockout_getword:=buffer_paleta[512];
    $280200..$2805ff:blockout_getword:=buffer_paleta[(direccion-$280200) shr 1];
end;
end;

procedure cambiar_color(pos,data:word);inline;
var
  bit0,bit1,bit2,bit3:byte;
  color:tcolor;
begin
  // red component */
	bit0:=(data shr 0) and $01;
	bit1:=(data shr 1) and $01;
	bit2:=(data shr 2) and $01;
	bit3:=(data shr 3) and $01;
	color.r:=$0e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
	// green component */
	bit0:=(data shr 4) and $01;
	bit1:=(data shr 5) and $01;
	bit2:=(data shr 6) and $01;
	bit3:=(data shr 7) and $01;
	color.g:=$0e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
	// blue component */
	bit0:=(data shr 8) and $01;
	bit1:=(data shr 9) and $01;
	bit2:=(data shr 10) and $01;
	bit3:=(data shr 11) and $01;
	color.b:=$0e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
  set_pal_color(color,pos);
  fillchar(video_ram_buff,$20000,1);
end;

procedure blockout_putword(direccion:dword;valor:word);
begin
if direccion<$40000 then exit;
case direccion of
    $100010:main_m68000.irq[6]:=CLEAR_LINE;
    $100012:main_m68000.irq[5]:=CLEAR_LINE;
    $100014:begin
              sound_latch:=valor and $ff;
              snd_z80.change_nmi(PULSE_LINE);
            end;
    $180000..$1bffff:begin
                        video_ram[(direccion and $3ffff) shr 1]:=valor;
                        video_ram_buff[(direccion and $3ffff) shr 1]:=true;
                      end;
    $1d4000..$1dffff:ram[(direccion-$1d4000) shr 1]:=valor;
    $1f4000..$1fffff:ram2[(direccion-$1f4000) shr 1]:=valor;
    $200000..$207fff:fvideo_ram[direccion and $7fff]:=valor;
    $208000..$21ffff:ram3[(direccion-$208000) shr 1]:=valor;
    $280002:if buffer_paleta[512]<>valor then begin
              buffer_paleta[512]:=valor;
              cambiar_color(512,valor);
            end;
    $280200..$2805ff:if buffer_paleta[(direccion-$280200) shr 1]<>valor then begin
                    buffer_paleta[(direccion-$280200) shr 1]:=valor;
                    cambiar_color((direccion-$280200) shr 1,valor);
                  end;
end;
end;

function blockout_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$87ff:blockout_snd_getbyte:=mem_snd[direccion];
  $8801:blockout_snd_getbyte:=ym2151_0.status;
  $9800:blockout_snd_getbyte:=oki_6295_0.read;
  $a000:blockout_snd_getbyte:=sound_latch;
end;
end;

procedure blockout_snd_putbyte(direccion:word;valor:byte);
begin
if direccion<$8000 then exit;
case direccion of
  $8000..$87ff:mem_snd[direccion]:=valor;
  $8800:ym2151_0.reg(valor);
  $8801:ym2151_0.write(valor);
  $9800:oki_6295_0.write(valor);
end;
end;

procedure ym2151_snd_irq(irqstate:byte);
begin
  snd_z80.pedir_irq:=irqstate;
end;

procedure blockout_sound_update;
begin
  ym2151_0.update;
  oki_6295_0.update;
end;

//Main
procedure reset_blockout;
begin
 main_m68000.reset;
 snd_z80.reset;
 ym2151_0.reset;
 oki_6295_0.reset;
 reset_audio;
 marcade.in0:=$FF;
 marcade.in1:=$FF;
 marcade.in1:=$FF;
 sound_latch:=0;
 fillchar(video_ram_buff,$20000,1);
end;

function iniciar_blockout:boolean;
begin
iniciar_blockout:=false;
iniciar_audio(false);
//Pantallas
screen_init(1,320,256);
screen_init(2,320,256,true);
screen_init(3,320,256,false,true);
iniciar_video(320,240);
//Main CPU
main_m68000:=cpu_m68000.create(10000000,256);
main_m68000.change_ram16_calls(blockout_getword,blockout_putword);
//Sound CPU
snd_z80:=cpu_z80.create(3579545,256);
snd_z80.change_ram_calls(blockout_snd_getbyte,blockout_snd_putbyte);
snd_z80.init_sound(blockout_sound_update);
//Sound Chips
ym2151_0:=ym2151_chip.create(3579545);
ym2151_0.change_irq_func(ym2151_snd_irq);
oki_6295_0:=snd_okim6295.Create(1056000,OKIM6295_PIN7_HIGH);
if not(cargar_roms(oki_6295_0.get_rom_addr,@blockout_oki,'blockout.zip',1)) then exit;
//cargar roms
if not(cargar_roms16w(@rom[0],@blockout_rom[0],'blockout.zip',0)) then exit;
//cargar sonido
if not(cargar_roms(@mem_snd[0],@blockout_sound,'blockout.zip')) then exit;
//DIP
marcade.dswa:=$ff;
marcade.dswa_val:=@blockout_dipa;
marcade.dswb:=$ff;
marcade.dswb_val:=@blockout_dipb;
//final
reset_blockout;
iniciar_blockout:=true;
end;

procedure Cargar_blockout;
begin
llamadas_maquina.iniciar:=iniciar_blockout;
llamadas_maquina.bucle_general:=blockout_principal;
llamadas_maquina.reset:=reset_blockout;
end;

end.
