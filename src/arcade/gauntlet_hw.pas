unit gauntlet_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6502,m68000,main_engine,controls_engine,gfx_engine,ym_2203,rom_engine,
     pal_engine,sound_engine,timer_engine,dialogs;

procedure cargar_gauntlet;

implementation
const
        gauntlet_rom:array[0..6] of tipo_roms=(
        (n:'136037-1307.9a';l:$8000;p:0;crc:$46fe8743),(n:'136037-1308.9b';l:$8000;p:$1;crc:$276e15c4),
        (n:'136037-205.10a';l:$4000;p:$38000;crc:$6d99ed51),(n:'136037-206.10b';l:$4000;p:$38001;crc:$545ead91),
        (n:'136037-1409.7a';l:$8000;p:$40000;crc:$6fb8419c),(n:'136037-1410.7b';l:$8000;p:$40001;crc:$931bd2a0),());
        gauntlet_sound:array[0..1] of tipo_roms=(
        (n:'136037-120.16r';l:$4000;p:$4000;crc:$6ee7f3cc),(n:'136037-119.16s';l:$8000;p:$8000;crc:$fa19861f));
        gauntlet_char:tipo_roms=(n:'136037-104.6p';l:$2000;p:0;crc:$9e2a5b59);
        gauntlet_mo:array[0..7] of tipo_roms=(
        (n:'136037-111.1a';l:$8000;p:0;crc:$91700f33),(n:'136037-112.1b';l:$8000;p:$8000;crc:$869330be),
        (n:'136037-113.1l';l:$8000;p:$10000;crc:$d497d0a8),(n:'136037-114.1mn';l:$8000;p:$18000;crc:$29ef9882),
        (n:'136037-115.2a';l:$8000;p:$20000;crc:$9510b898),(n:'136037-116.2b';l:$8000;p:$28000;crc:$11e0ac5b),
        (n:'136037-117.2l';l:$8000;p:$30000;crc:$29a5db41),(n:'136037-118.2mn';l:$8000;p:$30000;crc:$8bf3b263));
        gauntlet_pal:array[0..4] of tipo_roms=(
        (n:'tc1a_10f.bin';l:$100;p:0;crc:$ce07c544),(n:'tc1a_11f.bin';l:$100;p:$100;crc:$566d323a),
        (n:'tc1a_12f.bin';l:$100;p:$200;crc:$7ea63946),(n:'tc2a_2g.bin';l:$100;p:$300;crc:$08609bad),
        (n:'tc2a_4e.bin';l:$100;p:$400;crc:$2c43991f));
        //DIP
        gauntlet_dip:array [0..10] of def_dip=(
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
 rom:array[0..$3ffff] of word;
 ram:array[0..$1fff] of word;
 ram2:array[0..$3ff] of word;
 spritebank:array[0..$ff] of byte;
 sound_latch:byte;

procedure update_video_gauntlet;inline;
var
  f,color,x,y,nchar,atrib:word;
begin
end;

procedure eventos_gauntlet;
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

procedure gauntlet_principal;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
frame_s:=m6502_0.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to $ff do begin
  //main
  m68000_0.run(frame_m);
  frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
  //sound
  m6502_0.run(frame_s);
  frame_s:=frame_s+m6502_0.tframes-m6502_0.contador;
  if f=239 then begin
    update_video_gauntlet;
    copymemory(@buffer_sprites_w,@ram,$100*2);
    m68000_0.irq[1]:=HOLD_LINE;
  end;
 end;
 eventos_gauntlet;
 video_sync;
end;
end;

function gauntlet_getword(direccion:dword):word;
begin
case direccion of
    0..$37fff:gauntlet_getword:=rom[direccion shr 1];
    $40000..$7ffff:gauntlet_getword:=rom[direccion shr 1];
    $38000..$3ffff:gauntlet_getword:=rom[direccion shr 1];
    $800000..$802fff:gauntlet_getword:=ram[direccion shr 1];
    { $20000..$23fff:gauntlet_getword:=ram[(direccion and $3fff) shr 1];
    $24000:gauntlet_getword:=marcade.in1;
    $24002:gauntlet_getword:=marcade.in2;
    $24004:gauntlet_getword:=marcade.in0;
    $24006:gauntlet_getword:=marcade.dswa;
    $28000..$287ff:gauntlet_getword:=ram2[(direccion and $7ff) shr 1];}
end;
end;

procedure gauntlet_putword(direccion:dword;valor:word);
begin
case direccion of
    0..$37fff,$40000..$7ffff:exit;
    $38000..$3ffff:halt(0);
    $800000..$802fff:ram[direccion shr 1]:=valor;
end;
end;

function gauntlet_snd_getbyte(direccion:word):byte;
begin
gauntlet_snd_getbyte:=mem_snd[direccion];
end;

procedure gauntlet_snd_putbyte(direccion:word;valor:byte);
begin
if direccion<$c000 then exit;
mem_snd[direccion]:=valor;
end;

function gauntlet_snd_inbyte(puerto:word):byte;
begin
  case (puerto and $ff) of
  4:begin
      sound_latch:=0;
      gauntlet_snd_inbyte:=0;
    end;
  6:gauntlet_snd_inbyte:=sound_latch;
  end;
end;

procedure gauntlet_snd_outbyte(puerto:word;valor:byte);
begin
case (puerto and $ff) of
  $0:ym2203_0.Control(valor);
  $1:ym2203_0.Write(valor);
end;
end;

procedure gauntlet_sound_update;
begin
  ym2203_0.Update;
end;

//Main
procedure reset_gauntlet;
begin
 m68000_0.reset;
 m6502_0.reset;
 YM2203_0.reset;
 reset_audio;
 marcade.in0:=$FF00;
 marcade.in1:=$FF;
 marcade.in2:=$FF;
 scroll_x:=0;
 scroll_y:=0;
 sound_latch:=0;
 nmi_vblank:=false;
end;

function iniciar_gauntlet:boolean;
var
      colores:tpaleta;
      f,j:word;
      memoria_temp:array[0..$7ffff] of byte;
const
  pc_x:array[0..7] of dword=(0, 1, 2, 3, 8, 9, 10, 11);
  pc_y:array[0..7] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16);
  ps_x:array[0..7] of dword=(0, 1, 2, 3, 4, 5, 6, 7);
  ps_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
begin
iniciar_gauntlet:=false;
if MessageDlg('Warning. This is a WIP driver, it''s not finished yet and bad things could happen!. Do you want to continue?', mtWarning, [mbYes]+[mbNo],0)=7 then exit;
iniciar_audio(false);
screen_init(1,512,1024);
screen_mod_scroll(1,512,256,511,1024,256,1023);
screen_init(2,256,256,true);
screen_init(3,256,512,false,true);
iniciar_video(224,256);
//cargar roms
if not(cargar_roms16w(@memoria_temp,@gauntlet_rom,'gauntlet.zip',0)) then exit;
copymemory(@rom[0],@memoria_temp[$8000],$8000);
copymemory(@rom[$8000 shr 1],@memoria_temp[$0],$8000);
//copymemory(@rom[$10000],@memoria_temp[$10000],$30000);
copymemory(@rom[$40000 shr 1],@memoria_temp[$48000],$8000);
copymemory(@rom[$48000 shr 1],@memoria_temp[$40000],$8000);
copymemory(@rom[$50000 shr 1],@memoria_temp[$58000],$8000);
copymemory(@rom[$58000 shr 1],@memoria_temp[$50000],$8000);
copymemory(@rom[$60000 shr 1],@memoria_temp[$68000],$8000);
copymemory(@rom[$68000 shr 1],@memoria_temp[$60000],$8000);
copymemory(@rom[$70000 shr 1],@memoria_temp[$78000],$8000);
copymemory(@rom[$78000 shr 1],@memoria_temp[$70000],$8000);
//cargar sonido
if not(roms_load(@mem_snd,@gauntlet_sound,'gauntlet.zip',sizeof(gauntlet_sound))) then exit;
//Main CPU
m68000_0:=cpu_m68000.create(7000000,256);
m68000_0.change_ram16_calls(gauntlet_getword,gauntlet_putword);
//Sound CPU
m6502_0:=cpu_m6502.create(1750000,256,TCPU_M6502);
m6502_0.change_ram_calls(gauntlet_snd_getbyte,gauntlet_snd_putbyte);
m6502_0.init_sound(gauntlet_sound_update);
//Sound Chips
YM2203_0:=ym2203_chip.create(4000000,0.8,0.4);
//convertir chars
if not(roms_load(@memoria_temp,@gauntlet_char,'gauntlet.zip',sizeof(gauntlet_char))) then exit;
init_gfx(0,8,8,$400);
gfx[0].trans[0]:=true;
gfx_set_desc_data(2,0,16*8,0,4);
convert_gfx(0,0,@memoria_temp,@pc_x,@pc_y,false,false);
//convertir fondo
if not(roms_load(@memoria_temp,@gauntlet_mo,'gauntlet.zip',sizeof(gauntlet_mo))) then exit;
init_gfx(1,8,8,$2000);
gfx_set_desc_data(4,0,8*8,$2000*8*8*3,$2000*8*8*2,$2000*8*8*1,$2000*8*8*0);
convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,false);
//poner la paleta
//DIP
marcade.dswa:=$ffdf;
marcade.dswa_val:=@gauntlet_dip;
//final
reset_gauntlet;
iniciar_gauntlet:=true;
end;

procedure Cargar_gauntlet;
begin
llamadas_maquina.iniciar:=iniciar_gauntlet;
llamadas_maquina.bucle_general:=gauntlet_principal;
llamadas_maquina.reset:=reset_gauntlet;
end;

end.
