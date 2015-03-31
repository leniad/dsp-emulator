unit tutankham_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6809,nz80,main_engine,controls_engine,gfx_engine,rom_engine,
     pal_engine,konami_snd,sound_engine;

procedure Cargar_tutankham;
procedure tutankham_principal;
function iniciar_tutankham:boolean;
procedure reset_tutankham;
procedure cerrar_tutankham;
//Main CPU
function tutankham_getbyte(direccion:word):byte;
procedure tutankham_putbyte(direccion:word;valor:byte);

const
        tutan_rom:array[0..15] of tipo_roms=(
        (n:'m1.1h';l:$1000;p:$0;crc:$da18679f),(n:'m2.2h';l:$1000;p:$1000;crc:$a0f02c85),
        (n:'3j.3h';l:$1000;p:$2000;crc:$ea03a1ab),(n:'m4.4h';l:$1000;p:$3000;crc:$bd06fad0),
        (n:'m5.5h';l:$1000;p:$4000;crc:$bf9fd9b0),(n:'j6.6h';l:$1000;p:$5000;crc:$fe079c5b),
        (n:'c1.1i';l:$1000;p:$6000;crc:$7eb59b21),(n:'c2.2i';l:$1000;p:$7000;crc:$6615eff3),
        (n:'c3.3i';l:$1000;p:$8000;crc:$a10d4444),(n:'c4.4i';l:$1000;p:$9000;crc:$58cd143c),
        (n:'c5.5i';l:$1000;p:$a000;crc:$d7e7ae95),(n:'c6.6i';l:$1000;p:$b000;crc:$91f62b82),
        (n:'c7.7i';l:$1000;p:$c000;crc:$afd0a81f),(n:'c8.8i';l:$1000;p:$d000;crc:$dabb609b),
        (n:'c9.9i';l:$1000;p:$e000;crc:$8ea9c6a6),());
        tutan_sound:array[0..2] of tipo_roms=(
        (n:'s1.7a';l:$1000;p:0;crc:$b52d01fa),(n:'s2.8a';l:$1000;p:$1000;crc:$9db5c0ce),());

var
 irq_enable:boolean;
 xorx,xory:byte;
 rom_nbank,scroll_y:byte;
 rom_bank:array[0..$f,0..$fff] of byte;
 punt:array[0..$ffff] of word;

implementation

procedure Cargar_tutankham;
begin
llamadas_maquina.iniciar:=iniciar_tutankham;
llamadas_maquina.bucle_general:=tutankham_principal;
llamadas_maquina.cerrar:=cerrar_tutankham;
llamadas_maquina.reset:=reset_tutankham;
end;

function iniciar_tutankham:boolean;
var
  f:byte;
  memoria_temp:array[0..$efff] of byte;
begin
iniciar_tutankham:=false;
iniciar_audio(false);
//Pantallas
screen_init(1,256,256);
iniciar_video(224,256);
//Main CPU
main_m6809:=cpu_m6809.Create(1536000,$100);
main_m6809.change_ram_calls(tutankham_getbyte,tutankham_putbyte);
//Sound CPU
snd_z80:=cpu_z80.create(1789772,$100);
snd_z80.change_ram_calls(konamisnd_getbyte,konamisnd_putbyte);
//Sound Chip
konamisnd_init(4,snd_z80.numero_cpu,1,snd_z80.clock,nil);
//cargar roms
if not(cargar_roms(@memoria_temp[0],@tutan_rom[0],'tutankhm.zip',0)) then exit;
copymemory(@memoria[$a000],@memoria_temp[0],$6000);
for f:=0 to 8 do copymemory(@rom_bank[f,0],@memoria_temp[$6000+(f*$1000)],$1000);
//Cargar roms sound
if not(cargar_roms(@mem_snd[0],@tutan_sound[0],'tutankhm.zip',0)) then exit;
//final
reset_tutankham;
iniciar_tutankham:=true;
end;

procedure cerrar_tutankham;
begin
main_m6809.Free;
snd_z80.free;
konamisnd_close;
close_audio;
close_video;
end;

procedure reset_tutankham;
begin
 main_m6809.reset;
 snd_z80.reset;
 reset_audio;
 konamisnd_reset;
 marcade.in0:=$fF;
 marcade.in1:=$FF;
 marcade.in2:=$FF;
 irq_enable:=false;
end;

procedure update_video_tutankham;inline;
var
  y,x:word;
  effx,yscroll,effy,vrambyte,shifted:byte;
begin
for y:=0 to 255 do begin
		for x:=0 to 255 do begin
			effy:=y xor xory;
      if effy<192 then yscroll:=scroll_y
        else yscroll:=0;
			effx:=(x xor xorx)+yscroll;
			vrambyte:=memoria[effx*128+effy shr 1];
			shifted:=vrambyte shr (4*(effy and 1));
      punt[y*256+x]:=paleta[shifted and $0f];
		end;
end;
putpixel(0,0,$10000,@punt[0],1);
actualiza_trozo(16,0,224,256,1,0,0,224,256,pant_temp);
end;

procedure eventos_tutankham;
begin
if event.arcade then begin
  //marcade.in1
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but2[0] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  //marcade.in2
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.but2[1] then marcade.in2:=(marcade.in2 and $bf) else marcade.in2:=(marcade.in2 or $40);
  //service
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
end;
end;

procedure tutankham_principal;
var
  frame_m,frame_s:single;
  f:byte;
  irq_req:boolean;
begin
init_controls(false,false,false,true);
frame_m:=main_m6809.tframes;
frame_s:=snd_z80.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
    konami_sound.frame:=f;
    //Main CPU
    main_m6809.run(frame_m);
    frame_m:=frame_m+main_m6809.tframes-main_m6809.contador;
    //Sound CPU
    snd_z80.run(frame_s);
    frame_s:=frame_s+snd_z80.tframes-snd_z80.contador;
    if f=239 then begin
      if (irq_req and irq_enable) then main_m6809.pedir_irq:=ASSERT_LINE;
      update_video_tutankham;
    end;
  end;
  irq_req:=not(irq_req);
  eventos_tutankham;
  video_sync;
end;
end;

function tutankham_getbyte(direccion:word):byte;
begin
case direccion of
  $8160..$816f:tutankham_getbyte:=$7b;
  $8180..$818f:tutankham_getbyte:=marcade.in0;
  $81a0..$81af:tutankham_getbyte:=marcade.in1;
  $81c0..$81cf:tutankham_getbyte:=marcade.in2;
  $81e0..$81ef:tutankham_getbyte:=$ff;
  $9000..$9fff:tutankham_getbyte:=rom_bank[rom_nbank,direccion and $fff];
    else tutankham_getbyte:=memoria[direccion];
end;
end;

procedure tutankham_putbyte(direccion:word;valor:byte);
var
  color:tcolor;
begin
if direccion>$8FFF then exit;
memoria[direccion]:=valor;
case direccion of
  $8000..$80ff:begin
                color.r:=pal3bit(valor shr 0);
                color.g:=pal3bit(valor shr 3);
                color.b:=pal2bit(valor shr 6);
                set_pal_color(color,@paleta[direccion and $f]);
               end;
  $8100..$810f:scroll_y:=valor;
  $8200..$82ff:case (direccion and $7) of
                  0:begin
                      irq_enable:=(valor and 1)<>0;
                      if not(irq_enable) then main_m6809.pedir_irq:=CLEAR_LINE;
                    end;
                  6:if (valor and 1)<>0 then xory:=255
                      else xory:=0;
                  7:if (valor and 1)<>0 then xorx:=0
                      else xorx:=255;  //La x esta invertida...
               end;
  $8300..$83ff:rom_nbank:=valor and $f;
  $8600..$86ff:snd_z80.pedir_irq:=HOLD_LINE;
  $8700..$87ff:konami_sound.sound_latch:=valor;
end;
end;

end.
