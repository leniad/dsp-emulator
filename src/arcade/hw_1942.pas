unit hw_1942;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,gfx_engine,timer_engine,ay_8910,
     rom_engine,pal_engine,sound_engine,qsnapshot;

procedure cargar_hw1942;

implementation
const
        hw1942_rom:array[0..4] of tipo_roms=(
        (n:'srb-03.m3';l:$4000;p:0;crc:$d9dafcc3),(n:'srb-04.m4';l:$4000;p:$4000;crc:$da0cf924),
        (n:'srb-05.m5';l:$4000;p:$8000;crc:$d102911c),(n:'srb-06.m6';l:$2000;p:$c000;crc:$466f8248),
        (n:'srb-07.m7';l:$4000;p:$10000;crc:$0d31038c));
        hw1942_snd_rom:tipo_roms=(n:'sr-01.c11';l:$4000;p:0;crc:$bd87f06b);
        hw1942_pal:array[0..5] of tipo_roms=(
        (n:'sb-5.e8';l:$100;p:0;crc:$93ab8153),(n:'sb-6.e9';l:$100;p:$100;crc:$8ab44f7d),
        (n:'sb-7.e10';l:$100;p:$200;crc:$f4ade9a4),(n:'sb-0.f1';l:$100;p:$300;crc:$6047d91b),
        (n:'sb-4.d6';l:$100;p:$400;crc:$4858968d),(n:'sb-8.k3';l:$100;p:$500;crc:$f6fad943));
        hw1942_char:tipo_roms=(n:'sr-02.f2';l:$2000;p:0;crc:$6ebca191);
        hw1942_tiles:array[0..5] of tipo_roms=(
        (n:'sr-08.a1';l:$2000;p:0;crc:$3884d9eb),(n:'sr-09.a2';l:$2000;p:$2000;crc:$999cf6e0),
        (n:'sr-10.a3';l:$2000;p:$4000;crc:$8edb273a),(n:'sr-11.a4';l:$2000;p:$6000;crc:$3a2726c3),
        (n:'sr-12.a5';l:$2000;p:$8000;crc:$1bd3d8bb),(n:'sr-13.a6';l:$2000;p:$a000;crc:$658f02c4));
        hw1942_sprites:array[0..3] of tipo_roms=(
        (n:'sr-14.l1';l:$4000;p:0;crc:$2528bec6),(n:'sr-15.l2';l:$4000;p:$4000;crc:$f89287aa),
        (n:'sr-16.n1';l:$4000;p:$8000;crc:$024418f8),(n:'sr-17.n2';l:$4000;p:$c000;crc:$e2c7e489));

var
 memoria_rom:array[0..2,0..$3fff] of byte;
 scroll:word;
 sound_command,rom_bank,palette_bank:byte;

procedure draw_sprites;inline;
var
  f,color,nchar,x,y:word;
  i,h,atrib:byte;
begin
	for f:=$1f downto 0 do begin
    atrib:=memoria[$cc01+(f*4)];
		nchar:=(memoria[$cc00+(f*4)] and $7f)+(atrib and $20) shl 2+(memoria[$cc00+(f*4)] and $80) shl 1;
		color:=(atrib and $0f) shl 4;
		x:=240-(memoria[$cc03+(f*4)]-$10*(atrib and $10));
		y:=memoria[$cc02+(f*4)];
		// handle double or quadruple height
		i:=(atrib and $c0) shr 6;
		if (i=2) then i:=3;
		for h:=0 to i do begin
      put_gfx_sprite(nchar+h,color,false,false,1);
      actualiza_gfx_sprite(y+16*h,x,1,1);
    end;
  end;
end;

procedure update_video_hw1942;inline;
var
  f,color,nchar,pos,x,y:word;
  attr:byte;
begin
for f:=0 to $1ff do begin
  //tiles
  if gfx[2].buffer[f] then begin
      x:=f and $f;
      y:=31-(f shr 4);
      pos:=x+((f and $1f0) shl 1);
      attr:=memoria[$d810+pos];
      nchar:=memoria[$d800+pos]+((attr and $80) shl 1);
      color:=((attr and $1f)+(palette_bank*$20)) shl 3;
      put_gfx_flip(x*16,y*16,nchar,color,2,2,(attr and $40)<>0,(attr and $20)<>0);
      gfx[2].buffer[f]:=false;
  end;
end;
for f:=0 to $3ff do begin
  //Chars
  if gfx[0].buffer[f] then begin
    x:=f div 32;
    y:=31-(f mod 32);
    attr:=memoria[f+$d400];
    color:=(attr and $3f) shl 2;
    nchar:=memoria[f+$d000]+((attr and $80) shl 1);
    put_gfx_trans(x*8,y*8,nchar,color,3,0);
    gfx[0].buffer[f]:=false;
  end;
end;
scroll__y(2,1,256-scroll);
draw_sprites;
actualiza_trozo(0,0,256,256,3,0,0,256,256,1);
actualiza_trozo_final(16,0,224,256,1);
end;

procedure eventos_hw1942;
begin
if event.arcade then begin
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $F7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
end;
end;

procedure hw1942_principal;
var
  f:byte;
  frame_m,frame_s:single;
begin
init_controls(false,false,false,true);
frame_m:=z80_0.tframes;
frame_s:=z80_1.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
    //Main
    z80_0.run(frame_m);
    frame_m:=frame_m+z80_0.tframes-z80_0.contador;
    //Sound
    z80_1.run(frame_s);
    frame_s:=frame_s+z80_1.tframes-z80_1.contador;
    case f of
      239:begin //rst 10
          z80_0.im0:=$d7;
          z80_0.change_irq(HOLD_LINE);
          update_video_hw1942;
        end;
      $ff:begin //rst 8
          z80_0.im0:=$cf;
          z80_0.change_irq(HOLD_LINE);
        end;
    end;
  end;
  eventos_hw1942;
  video_sync;
end;
end;

function hw1942_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$7fff,$cc00..$cc7f,$d000..$dbff,$e000..$efff:hw1942_getbyte:=memoria[direccion];
  $8000..$bfff:hw1942_getbyte:=memoria_rom[rom_bank,direccion and $3fff];
  $c000:hw1942_getbyte:=marcade.in0;
  $c001:hw1942_getbyte:=marcade.in1;
  $c002:hw1942_getbyte:=$ff;
  $c003:hw1942_getbyte:=$77;
  $c004:hw1942_getbyte:=$ff;
end;
end;

procedure hw1942_putbyte(direccion:word;valor:byte);
begin
if direccion<$c000 then exit;
case direccion of
        $c800:sound_command:=valor;
        $c802:scroll:=valor or (scroll and $100);
        $c803:scroll:=((valor and $1) shl 8) or (scroll and $ff);
        $c804:begin
                if (valor and $10)<>0 then z80_1.change_reset(ASSERT_LINE)
                  else z80_1.change_reset(CLEAR_LINE);
                main_screen.flip_main_screen:=(valor and $80)<>0;
              end;
        $c805:palette_bank:=valor;
        $c806:rom_bank:=valor and $3;
        $cc00..$cc7f,$e000..$efff:memoria[direccion]:=valor;
        $d000..$d7ff:if memoria[direccion]<>valor then begin
                        gfx[0].buffer[direccion and $3ff]:=true;
                        memoria[direccion]:=valor;
                      end;
        $d800..$dbff:if memoria[direccion]<>valor then begin
                        gfx[2].buffer[(direccion and $f)+((direccion and $3e0) shr 1)]:=true;
                        memoria[direccion]:=valor;
                     end;
end;
end;

function hw1942_snd_getbyte(direccion:word):byte;
begin
if direccion=$6000 then hw1942_snd_getbyte:=sound_command
 else hw1942_snd_getbyte:=mem_snd[direccion];
end;

procedure hw1942_snd_putbyte(direccion:word;valor:byte);
begin
if direccion<$4000 then exit;
case direccion of
    $4000..$47ff:mem_snd[direccion]:=valor;
    $8000:ay8910_0.Control(valor);
    $8001:ay8910_0.Write(valor);
    $c000:ay8910_1.Control(valor);
    $c001:ay8910_1.Write(valor);
end;
end;

procedure hw1942_snd_irq;
begin
  z80_1.change_irq(HOLD_LINE);
end;

procedure hw1942_sound_update;
begin
  ay8910_0.update;
  ay8910_1.update;
end;

procedure hw1942_qsave(nombre:string);
var
  data:pbyte;
  size:word;
  buffer:array[0..4] of byte;
begin
open_qsnapshot_save('1942'+nombre);
getmem(data,200);
//CPU
size:=z80_0.save_snapshot(data);
savedata_qsnapshot(data,size);
size:=z80_1.save_snapshot(data);
savedata_qsnapshot(data,size);
//SND
size:=ay8910_0.save_snapshot(data);
savedata_qsnapshot(data,size);
size:=ay8910_1.save_snapshot(data);
savedata_qsnapshot(data,size);
//MEM
savedata_com_qsnapshot(@memoria[$c000],$4000);
savedata_com_qsnapshot(@mem_snd[$4000],$800);
//MISC
buffer[0]:=scroll and $ff;
buffer[1]:=scroll shr 8;
buffer[2]:=sound_command;
buffer[3]:=rom_bank;
buffer[4]:=palette_bank;
savedata_qsnapshot(@buffer,5);
freemem(data);
close_qsnapshot;
end;

procedure hw1942_qload(nombre:string);
var
  data:pbyte;
  buffer:array[0..4] of byte;
begin
if not(open_qsnapshot_load('1942'+nombre)) then exit;
getmem(data,200);
//CPU
loaddata_qsnapshot(data);
z80_0.load_snapshot(data);
loaddata_qsnapshot(data);
z80_1.load_snapshot(data);
//SND
loaddata_qsnapshot(data);
ay8910_0.load_snapshot(data);
loaddata_qsnapshot(data);
ay8910_1.load_snapshot(data);
//MEM
loaddata_qsnapshot(@memoria[$c000]);
loaddata_qsnapshot(@mem_snd[$4000]);
//MISC
loaddata_qsnapshot(@buffer);
scroll:=buffer[0] or (buffer[1] shl 8);
sound_command:=buffer[2];
rom_bank:=buffer[3];
palette_bank:=buffer[4];
freemem(data);
close_qsnapshot;
end;

//Main
procedure reset_hw1942;
begin
 z80_0.reset;
 z80_1.reset;
 ay8910_0.reset;
 ay8910_1.reset;
 reset_audio;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 scroll:=0;
 rom_bank:=0;
 palette_bank:=0;
 sound_command:=0;
end;

function iniciar_hw1942:boolean;
var
      colores:tpaleta;
      f:word;
      memoria_temp:array[0..$17fff] of byte;
const
    ps_x:array[0..15] of dword=(0, 1, 2, 3, 8+0, 8+1, 8+2, 8+3,
			16*16+0, 16*16+1, 16*16+2, 16*16+3, 16*16+8+0, 16*16+8+1, 16*16+8+2, 16*16+8+3);
    ps_y:array[0..15] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16,
			8*16, 9*16, 10*16, 11*16, 12*16, 13*16, 14*16, 15*16);
    pt_x:array[0..15] of dword=(0, 1, 2, 3, 4, 5, 6, 7,
			16*8+0, 16*8+1, 16*8+2, 16*8+3, 16*8+4, 16*8+5, 16*8+6, 16*8+7);
    pt_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8);
begin
iniciar_hw1942:=false;
iniciar_audio(false);
screen_init(1,256,512,false,true);
screen_init(2,256,512);
screen_mod_scroll(2,256,256,255,512,256,511);
screen_init(3,256,256,true);
iniciar_video(224,256);
//Main CPU
z80_0:=cpu_z80.create(4000000,$100);
z80_0.change_ram_calls(hw1942_getbyte,hw1942_putbyte);
//Sound CPU
z80_1:=cpu_z80.create(3000000,$100);
z80_1.change_ram_calls(hw1942_snd_getbyte,hw1942_snd_putbyte);
z80_1.init_sound(hw1942_sound_update);
//Sound Chips
AY8910_0:=ay8910_chip.create(1500000,AY8910,1);
AY8910_1:=ay8910_chip.create(1500000,AY8910,1);
//IRQ Sound CPU
init_timer(z80_1.numero_cpu,3000000/(4*60),hw1942_snd_irq,true);
//cargar roms y ponerlas en su sitio
if not(roms_load(@memoria_temp,@hw1942_rom,'1942.zip',sizeof(hw1942_rom))) then exit;
copymemory(@memoria,@memoria_temp,$8000);
for f:=0 to 2 do copymemory(@memoria_rom[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
//cargar ROMS sonido
if not(roms_load(@mem_snd,@hw1942_snd_rom,'1942.zip',sizeof(hw1942_snd_rom))) then exit;
//convertir chars
if not(roms_load(@memoria_temp,@hw1942_char,'1942.zip',sizeof(hw1942_char))) then exit;
init_gfx(0,8,8,$200);
gfx[0].trans[0]:=true;
gfx_set_desc_data(2,0,16*8,4,0);
convert_gfx(0,0,@memoria_temp,@ps_x,@ps_y,false,true);
//convertir sprites
if not(roms_load(@memoria_temp,@hw1942_sprites,'1942.zip',sizeof(hw1942_sprites))) then exit;
init_gfx(1,16,16,$200);
gfx[1].trans[15]:=true;
gfx_set_desc_data(4,0,64*8,512*64*8+4,512*64*8+0,4,0);
convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,true);
//tiles
if not(roms_load(@memoria_temp,@hw1942_tiles,'1942.zip',sizeof(hw1942_tiles))) then exit;
init_gfx(2,16,16,$200);
gfx_set_desc_data(3,0,32*8,0,$4000*8,$4000*8*2);
convert_gfx(2,0,@memoria_temp,@pt_x,@pt_y,false,true);
//poner la paleta
if not(roms_load(@memoria_temp,@hw1942_pal,'1942.zip',sizeof(hw1942_pal))) then exit;
for f:=0 to $ff do begin
    colores[f].r:=pal4bit(memoria_temp[f]);
    colores[f].g:=pal4bit(memoria_temp[f+$100]);
    colores[f].b:=pal4bit(memoria_temp[f+$200]);
    gfx[0].colores[f]:=memoria_temp[$300+f]+$80;  //chars
    gfx[2].colores[f]:=memoria_temp[$400+f];  //tiles
    gfx[2].colores[f+$100]:=memoria_temp[$400+f]+$10;
    gfx[2].colores[f+$200]:=memoria_temp[$400+f]+$20;
    gfx[2].colores[f+$300]:=memoria_temp[$400+f]+$30;
    gfx[1].colores[f]:=memoria_temp[$500+f]+$40;  //sprites
end;
set_pal(colores,256);
//final
reset_hw1942;
iniciar_hw1942:=true;
end;

procedure cargar_hw1942;
begin
llamadas_maquina.iniciar:=iniciar_hw1942;
llamadas_maquina.bucle_general:=hw1942_principal;
llamadas_maquina.reset:=reset_hw1942;
llamadas_maquina.save_qsnap:=hw1942_qsave;
llamadas_maquina.load_qsnap:=hw1942_qload;
end;

end.
