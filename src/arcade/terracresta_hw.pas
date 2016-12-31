unit terracresta_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,m68000,main_engine,controls_engine,gfx_engine,ym_2203,dac,rom_engine,
     pal_engine,sound_engine,qsnapshot,timer_engine;

procedure cargar_terracre;

implementation
const
        terracre_rom:array[0..8] of tipo_roms=(
        (n:'1a_4b.rom';l:$4000;p:1;crc:$76f17479),(n:'1a_4d.rom';l:$4000;p:$0;crc:$8119f06e),
        (n:'1a_6b.rom';l:$4000;p:$8001;crc:$ba4b5822),(n:'1a_6d.rom';l:$4000;p:$8000;crc:$ca4852f6),
        (n:'1a_7b.rom';l:$4000;p:$10001;crc:$d0771bba),(n:'1a_7d.rom';l:$4000;p:$10000;crc:$029d59d9),
        (n:'1a_9b.rom';l:$4000;p:$18001;crc:$69227b56),(n:'1a_9d.rom';l:$4000;p:$18000;crc:$5a672942),());
        terracre_pal:array[0..4] of tipo_roms=(
        (n:'tc1a_10f.bin';l:$100;p:0;crc:$ce07c544),(n:'tc1a_11f.bin';l:$100;p:$100;crc:$566d323a),
        (n:'tc1a_12f.bin';l:$100;p:$200;crc:$7ea63946),(n:'tc2a_2g.bin';l:$100;p:$300;crc:$08609bad),
        (n:'tc2a_4e.bin';l:$100;p:$400;crc:$2c43991f));
        terracre_char:tipo_roms=(n:'2a_16b.rom';l:$2000;p:0;crc:$591a3804);
        terracre_sound:array[0..1] of tipo_roms=(
        (n:'tc2a_15b.bin';l:$4000;p:0;crc:$790ddfa9),(n:'tc2a_17b.bin';l:$4000;p:$4000;crc:$d4531113));
        terracre_fondo:array[0..1] of tipo_roms=(
        (n:'1a_15f.rom';l:$8000;p:0;crc:$984a597f),(n:'1a_17f.rom';l:$8000;p:$8000;crc:$30e297ff));
        terracre_sprites:array[0..3] of tipo_roms=(
        (n:'2a_6e.rom';l:$4000;p:0;crc:$bcf7740b),(n:'2a_7e.rom';l:$4000;p:$4000;crc:$a70b565c),
        (n:'2a_6g.rom';l:$4000;p:$8000;crc:$4a9ec3e6),(n:'2a_7g.rom';l:$4000;p:$c000;crc:$450749fc));
        //DIP
        terracre_dip:array [0..10] of def_dip=(
        (mask:$3;name:'Lives';number:4;dip:((dip_val:$3;dip_name:'3'),(dip_val:$2;dip_name:'4'),(dip_val:$1;dip_name:'5'),(dip_val:$0;dip_name:'6'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Bonus Life';number:4;dip:((dip_val:$c;dip_name:'20k then every 60k'),(dip_val:$8;dip_name:'30k then every 70k'),(dip_val:$4;dip_name:'40k then every 80k'),(dip_val:$0;dip_name:'50k then every 90k'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$10;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$20;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$300;name:'Coin A';number:4;dip:((dip_val:$100;dip_name:'2 Coin - 1 Credit '),(dip_val:$300;dip_name:'1 Coin - 1 Credit'),(dip_val:$200;dip_name:'1 Coin - 2 Credit'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c00;name:'Coin B';number:4;dip:((dip_val:$0;dip_name:'3 Coin - 1 Credit '),(dip_val:$400;dip_name:'2 Coin - 3 Credit'),(dip_val:$c00;dip_name:'1 Coin - 3 Credit'),(dip_val:$800;dip_name:'1 Coin - 6 Credit'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$1000;name:'Difficulty';number:2;dip:((dip_val:$1000;dip_name:'Easy'),(dip_val:$0;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2000;name:'Flip Screen';number:2;dip:((dip_val:$2000;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4000;name:'Complete Invulnerability';number:2;dip:((dip_val:$4000;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8000;name:'Base Ship Invulnerability';number:2;dip:((dip_val:$8000;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 nmi_vblank:boolean;
 scroll_x,scroll_y:word;
 rom:array[0..$ffff] of word;
 ram:array[0..$1fff] of word;
 ram2:array[0..$3ff] of word;
 spritebank:array[0..$ff] of byte;
 sound_latch:byte;

procedure update_video_terracre;inline;
var
  f,color,x,y,nchar,atrib:word;
begin
//background
if (scroll_y and $2000)<>0 then begin
  fill_full_screen(3,$100);
end else begin
  for f:=$0 to $7ff do begin
    if gfx[1].buffer[f] then begin
      x:=f and $1f;
      y:=63-(f shr 5);
      nchar:=ram[$1000+f];
      color:=((nchar shr 11) and $f) shl 4;
      put_gfx(x shl 4,y shl 4,nchar and $1ff,color,1,1);
      gfx[1].buffer[f]:=false;
    end;
  end;
  scroll_x_y(1,3,scroll_x,(768-scroll_y) and $3ff);
end;
//sprites
for f:=0 to $3f do begin
    atrib:=buffer_sprites_w[(f*4)+2];
		nchar:=(buffer_sprites_w[(f*4)+1] and $ff)+((atrib and $2) shl 7);
	  y:=240-((buffer_sprites_w[(f*4)+3] and $ff)-$80+((atrib and 1) shl 8));
	  x:=240-(buffer_sprites_w[f*4] and $ff);
    color:=((atrib and $f0) shr 4)+16*(spritebank[(nchar shr 1) and $ff] and $0f);
    put_gfx_sprite(nchar,color shl 4,(atrib and 8)<>0,(atrib and 4)<>0,2);
    actualiza_gfx_sprite(x,y,3,2);
end;
//foreground
for f:=$0 to $3ff do begin
 if gfx[0].buffer[f] then begin
    x:=f and $1f;
    y:=31-(f shr 5);
    nchar:=ram2[f] and $ff;
    put_gfx_trans(x shl 3,y shl 3,nchar,0,2,0);
    gfx[0].buffer[f]:=false;
 end;
end;
actualiza_trozo(0,0,256,256,2,0,0,256,256,3);
actualiza_trozo_final(16,0,224,256,3);
end;

procedure eventos_terracre;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $Fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $F7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  //P2
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $Fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $F7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  //SYSTEM
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fbff) else marcade.in0:=(marcade.in0 or $400);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $f7ff) else marcade.in0:=(marcade.in0 or $800);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $feff) else marcade.in0:=(marcade.in0 or $100);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $fdff) else marcade.in0:=(marcade.in0 or $200);
end;
end;

procedure terracre_principal;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
frame_s:=z80_0.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to $ff do begin
  //main
  m68000_0.run(frame_m);
  frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
  //sound
  z80_0.run(frame_s);
  frame_s:=frame_s+z80_0.tframes-z80_0.contador;
  if f=239 then begin
    update_video_terracre;
    copymemory(@buffer_sprites_w,@ram,$100*2);
    m68000_0.irq[1]:=HOLD_LINE;
  end;
 end;
 eventos_terracre;
 video_sync;
end;
end;

function terracre_getword(direccion:dword):word;
begin
case direccion of
    0..$1ffff:terracre_getword:=rom[direccion shr 1];
    $20000..$23fff:terracre_getword:=ram[(direccion and $3fff) shr 1];
    $24000:terracre_getword:=marcade.in1;
    $24002:terracre_getword:=marcade.in2;
    $24004:terracre_getword:=marcade.in0;
    $24006:terracre_getword:=marcade.dswa;
    $28000..$287ff:terracre_getword:=ram2[(direccion and $7ff) shr 1];
end;
end;

procedure terracre_putword(direccion:dword;valor:word);
begin
if direccion<$20000 then exit;
case direccion of
    $20000..$21fff,$23000..$23fff:ram[(direccion and $3fff) shr 1]:=valor;
    $22000..$22fff:if ram[(direccion and $3fff) shr 1]<>valor then begin
                    gfx[1].buffer[(direccion and $fff) shr 1]:=true;
                    ram[(direccion and $3fff) shr 1]:=valor;
                   end;
    $26000:main_screen.flip_main_screen:=(valor and $4)<>0;
    $26002:scroll_y:=valor;
    $26004:scroll_x:=valor and $1ff;
    $2600c:sound_latch:=((valor and $7f) shl 1) or 1;
    $28000..$287ff:if ram2[(direccion and $7ff) shr 1]<>valor then begin
                    gfx[0].buffer[(direccion and $7ff) shr 1]:=true;
                    ram2[(direccion and $7ff) shr 1]:=valor;
                   end;
  end;
end;

function terracre_snd_getbyte(direccion:word):byte;
begin
terracre_snd_getbyte:=mem_snd[direccion];
end;

procedure terracre_snd_putbyte(direccion:word;valor:byte);
begin
if direccion<$c000 then exit;
mem_snd[direccion]:=valor;
end;

function terracre_snd_inbyte(puerto:word):byte;
begin
  case (puerto and $ff) of
  4:begin
      sound_latch:=0;
      terracre_snd_inbyte:=0;
    end;
  6:terracre_snd_inbyte:=sound_latch;
  end;
end;

procedure terracre_snd_outbyte(valor:byte;puerto:word);
begin
case (puerto and $ff) of
  $0:ym2203_0.Control(valor);
  $1:ym2203_0.Write(valor);
  $2:dac_0.signed_data8_w(valor);
  $3:dac_1.signed_data8_w(valor);
end;
end;

procedure terracre_sound_update;
begin
  ym2203_0.Update;
  dac_0.update;
  dac_1.update;
end;

procedure terracre_snd_timer;
begin
  z80_0.change_irq(HOLD_LINE);
end;

procedure terracre_qsave(nombre:string);
var
  data:pbyte;
  buffer:array[0..6] of byte;
  size:word;
begin
open_qsnapshot_save('terracresta'+nombre);
getmem(data,20000);
//CPU
size:=m68000_0.save_snapshot(data);
savedata_qsnapshot(data,size);
size:=z80_0.save_snapshot(data);
savedata_qsnapshot(data,size);
//SND
size:=ym2203_0.save_snapshot(data);
savedata_com_qsnapshot(data,size);
size:=dac_0.save_snapshot(data);
savedata_qsnapshot(data,size);
size:=dac_1.save_snapshot(data);
savedata_qsnapshot(data,size);
//MEM
savedata_com_qsnapshot(@ram,$2000*2);
savedata_com_qsnapshot(@ram2,$400*2);
savedata_com_qsnapshot(@mem_snd[$c000],$1000);
//MISC
buffer[0]:=byte(nmi_vblank);
buffer[1]:=scroll_x and $ff;
buffer[2]:=scroll_x shr 8;
buffer[3]:=scroll_y and $ff;
buffer[4]:=scroll_y shr 8;
buffer[5]:=sound_latch;
savedata_qsnapshot(@buffer,7);
freemem(data);
close_qsnapshot;
end;

procedure terracre_qload(nombre:string);
var
  data:pbyte;
  buffer:array[0..6] of byte;
begin
if not(open_qsnapshot_load('terracresta'+nombre)) then exit;
getmem(data,20000);
//CPU
loaddata_qsnapshot(data);
m68000_0.load_snapshot(data);
loaddata_qsnapshot(data);
z80_0.load_snapshot(data);
//SND
loaddata_qsnapshot(data);
ym2203_0.load_snapshot(data);
loaddata_qsnapshot(data);
dac_0.load_snapshot(data);
loaddata_qsnapshot(data);
dac_1.load_snapshot(data);
//MEM
loaddata_qsnapshot(@ram);
loaddata_qsnapshot(@ram2);
loaddata_qsnapshot(@mem_snd[$c000]);
//MISC
loaddata_qsnapshot(@buffer);
nmi_vblank:=(buffer[0]<>0);
scroll_x:=buffer[1] or (buffer[2] shl 8);
scroll_y:=buffer[3] or (buffer[4] shl 8);
sound_latch:=buffer[5];
freemem(data);
close_qsnapshot;
//END
fillchar(gfx[0].buffer[0],$400,1);
fillchar(gfx[1].buffer[0],$800,1);
end;

//Main
procedure reset_terracre;
begin
 m68000_0.reset;
 z80_0.reset;
 YM2203_0.reset;
 dac_0.reset;
 dac_1.reset;
 reset_audio;
 marcade.in0:=$FF00;
 marcade.in1:=$FF;
 marcade.in2:=$FF;
 scroll_x:=0;
 scroll_y:=0;
 sound_latch:=0;
 nmi_vblank:=false;
end;

function iniciar_terracre:boolean;
var
      colores:tpaleta;
      f,j:word;
      memoria_temp:array[0..$ffff] of byte;
const
  pf_x:array[0..15] of dword=(4, 0, 12, 8, 20, 16, 28, 24,
		32+4, 32+0, 32+12, 32+8, 32+20, 32+16, 32+28, 32+24);
  pf_y:array[0..15] of dword=(0*64, 1*64, 2*64, 3*64, 4*64, 5*64, 6*64, 7*64,
		8*64, 9*64, 10*64, 11*64, 12*64, 13*64, 14*64, 15*64);
  pc_x:array[0..7] of dword=(1*4, 0*4, 3*4, 2*4, 5*4, 4*4, 7*4, 6*4);
  pc_y:array[0..7] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32);
  ps_x:array[0..15] of dword=(4, 0, 4+$8000*8, 0+$8000*8, 12, 8, 12+$8000*8, 8+$8000*8,
		20, 16, 20+$8000*8, 16+$8000*8, 28, 24, 28+$8000*8, 24+$8000*8);
  ps_y:array[0..15] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32,
          8*32, 9*32, 10*32, 11*32, 12*32, 13*32, 14*32, 15*32);
begin
iniciar_terracre:=false;
iniciar_audio(false);
screen_init(1,512,1024);
screen_mod_scroll(1,512,256,511,1024,256,1023);
screen_init(2,256,256,true);
screen_init(3,256,512,false,true);
iniciar_video(224,256);
//cargar roms
if not(cargar_roms16w(@rom,@terracre_rom,'terracre.zip',0)) then exit;
//cargar sonido
if not(roms_load(@mem_snd,@terracre_sound,'terracre.zip',sizeof(terracre_sound))) then exit;
//Main CPU
m68000_0:=cpu_m68000.create(8000000,256);
m68000_0.change_ram16_calls(terracre_getword,terracre_putword);
//Sound CPU
z80_0:=cpu_z80.create(4000000,256);
z80_0.change_ram_calls(terracre_snd_getbyte,terracre_snd_putbyte);
z80_0.change_io_calls(terracre_snd_inbyte,terracre_snd_outbyte);
z80_0.init_sound(terracre_sound_update);
//Sound Chips
YM2203_0:=ym2203_chip.create(4000000,0.8,0.4);
dac_0:=dac_chip.Create(0.5);
dac_1:=dac_chip.Create(0.5);
init_timer(z80_0.numero_cpu,4000000/(4000000/512),terracre_snd_timer,true);
//convertir chars
if not(roms_load(@memoria_temp,@terracre_char,'terracre.zip',sizeof(terracre_char))) then exit;
init_gfx(0,8,8,256);
gfx[0].trans[15]:=true;
gfx_set_desc_data(4,0,32*8,0,1,2,3);
convert_gfx(0,0,@memoria_temp,@pc_x,@pc_y,false,true);
//convertir fondo
if not(roms_load(@memoria_temp,@terracre_fondo,'terracre.zip',sizeof(terracre_fondo))) then exit;
init_gfx(1,16,16,512);
gfx_set_desc_data(4,0,64*16,0,1,2,3);
convert_gfx(1,0,@memoria_temp,@pf_x,@pf_y,false,true);
//convertir sprites
if not(roms_load(@memoria_temp,@terracre_sprites,'terracre.zip',sizeof(terracre_sprites))) then exit;
init_gfx(2,16,16,512);
gfx[2].trans[0]:=true;
gfx_set_desc_data(4,0,32*16,0,1,2,3);
convert_gfx(2,0,@memoria_temp,@ps_x,@ps_y,false,true);
//poner la paleta
if not(roms_load(@memoria_temp,@terracre_pal,'terracre.zip',sizeof(terracre_pal))) then exit;
copymemory(@spritebank,@memoria_temp[$400],$100);
for f:=0 to $ff do begin
  colores[f].r:=pal4bit(memoria_temp[f]);
  colores[f].g:=pal4bit(memoria_temp[f+$100]);
  colores[f].b:=pal4bit(memoria_temp[f+$200]);
  //color lookup de fondo
  if (f and 8)<>0 then gfx[1].colores[f]:=192+(f and $0f)+((f and $c0) shr 2)
		  else gfx[1].colores[f]:=192+(f and $0f)+((f and $30) shr 0);
  //color lookup de sprites
  for j:=0 to $f do begin
			if (f and $8)<>0 then gfx[2].colores[f+j*$100]:=$80+((j and $0c) shl 2)+(memoria_temp[$300+f] and $0f)
			  else gfx[2].colores[f+j*$100]:=$80+((j and $03) shl 4)+(memoria_temp[$300+f] and $0f);
    end;
end;
set_pal(colores,$100);
//DIP
marcade.dswa:=$ffdf;
marcade.dswa_val:=@terracre_dip;
//final
reset_terracre;
iniciar_terracre:=true;
end;

procedure Cargar_terracre;
begin
llamadas_maquina.iniciar:=iniciar_terracre;
llamadas_maquina.bucle_general:=terracre_principal;
llamadas_maquina.reset:=reset_terracre;
llamadas_maquina.save_qsnap:=terracre_qsave;
llamadas_maquina.load_qsnap:=terracre_qload;
end;

end.
