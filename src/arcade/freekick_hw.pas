unit freekick_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,sn_76496,gfx_engine,rom_engine,
     timer_engine,pal_engine,sound_engine,ppi8255;

procedure cargar_freekick;

implementation
const
        //Freekick
        freekick_rom:tipo_roms=(n:'ns6201-a_1987.10_free_kick.cpu';l:$d000;p:0;crc:$6d172850);
        freekick_sound_data:tipo_roms=(n:'11.1e';l:$8000;p:0;crc:$a6030ba9);
        freekick_pal:array[0..6] of tipo_roms=(
        (n:'24s10n.8j';l:$100;p:0;crc:$53a6bc21),(n:'24s10n.7j';l:$100;p:$100;crc:$38dd97d8),
        (n:'24s10n.8k';l:$100;p:$200;crc:$18e66087),(n:'24s10n.7k';l:$100;p:$300;crc:$bc21797a),
        (n:'24s10n.8h';l:$100;p:$400;crc:$8aac5fd0),(n:'24s10n.7h';l:$100;p:$500;crc:$a507f941),());
        freekick_chars:array[0..3] of tipo_roms=(
        (n:'12.1h';l:$4000;p:0;crc:$fb82e486),(n:'13.1j';l:$4000;p:$4000;crc:$3ad78ee2),
        (n:'14.1l';l:$4000;p:$8000;crc:$0185695f),());
        freekick_sprites:array[0..3] of tipo_roms=(
        (n:'15.1m';l:$4000;p:0;crc:$0fa7c13c),(n:'16.1p';l:$4000;p:$4000;crc:$2b996e89),
        (n:'17.1r';l:$4000;p:$8000;crc:$e7894def),());
        //Dip
        freekick_dip_a:array [0..6] of def_dip=(
        (mask:$1;name:'Lives';number:2;dip:((dip_val:$1;dip_name:'3'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$6;name:'Bonus Life';number:4;dip:((dip_val:$6;dip_name:'2-3-4-5-60000 Points'),(dip_val:$2;dip_name:'3-4-5-6-7-80000 Points'),(dip_val:$4;dip_name:'20000 & 60000 Points'),(dip_val:$0;dip_name:'ONLY 20000 Points'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$18;name:'Difficulty';number:4;dip:((dip_val:$18;dip_name:'Easy'),(dip_val:$10;dip_name:'Normal'),(dip_val:$8;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Allow Continue';number:2;dip:((dip_val:$0;dip_name:'No'),(dip_val:$20;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$40;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Flip Screen';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        freekick_dip_b:array [0..2] of def_dip=(
        (mask:$0f;name:'Coin A';number:16;dip:((dip_val:$0;dip_name:'5C 1C'),(dip_val:$c;dip_name:'4C 1C'),(dip_val:$e;dip_name:'3C 1C'),(dip_val:$5;dip_name:'2C 1C'),(dip_val:$6;dip_name:'3C 2C'),(dip_val:$4;dip_name:'4C 3C'),(dip_val:$f;dip_name:'1C 1C'),(dip_val:$8;dip_name:'4C 5C'),(dip_val:$a;dip_name:'3C 4C'),(dip_val:$9;dip_name:'2C 3C'),(dip_val:$2;dip_name:'3C 5C'),(dip_val:$7;dip_name:'1C 2C'),(dip_val:$1;dip_name:'2C 5C'),(dip_val:$b;dip_name:'1C 3C'),(dip_val:$3;dip_name:'1C 4C'),(dip_val:$d;dip_name:'1C 5C'))),
        (mask:$f0;name:'Coin B';number:16;dip:((dip_val:$0;dip_name:'5C 1C'),(dip_val:$e0;dip_name:'3C 1C'),(dip_val:$50;dip_name:'2C 1C'),(dip_val:$60;dip_name:'3C 2C'),(dip_val:$f0;dip_name:'1C 1C'),(dip_val:$a0;dip_name:'3C 4C'),(dip_val:$90;dip_name:'2C 3C'),(dip_val:$20;dip_name:'3C 5C'),(dip_val:$70;dip_name:'1C 2C'),(dip_val:$10;dip_name:'2C 5C'),(dip_val:$b0;dip_name:'1C 3C'),(dip_val:$30;dip_name:'1C 4C'),(dip_val:$d0;dip_name:'1C 5C'),(dip_val:$c0;dip_name:'1C 10C'),(dip_val:$40;dip_name:'1C 25C'),(dip_val:$80;dip_name:'1C 50C'))),());
        freekick_dip_c:array [0..2] of def_dip=(
        (mask:$1;name:'Manufacturer';number:2;dip:((dip_val:$0;dip_name:'Nihon System'),(dip_val:$1;dip_name:'Sega/Nihon System'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Coin Slots';number:2;dip:((dip_val:$0;dip_name:'1'),(dip_val:$80;dip_name:'2'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
  spinner,nmi_enable:boolean;
  snd_rom_addr:word;
  snd_rom:array[0..$7fff] of byte;
  freekick_ff:byte;

procedure update_video_freekick;inline;
var
  f,x,y,color,nchar:word;
  atrib:byte;
begin
for f:=$3ff downto 0 do begin
  if gfx[0].buffer[f] then begin
    x:=f div 32;
    y:=31-(f mod 32);
    atrib:=memoria[f+$e400];
    color:=(atrib and $1f) shl 3;
    nchar:=memoria[f+$e000]+((atrib and $e0) shl 3);
    put_gfx(x*8,y*8,nchar,color,1,0);
    gfx[0].buffer[f]:=false;
  end;
end;
actualiza_trozo(0,0,256,256,1,0,0,256,256,2);
//sprites
for f:=0 to $3f do begin
  atrib:=memoria[$e802+(f*4)];
  nchar:=memoria[$e801+(f*4)]+((atrib and $20) shl 3);
  color:=(atrib and $1f) shl 3;
  y:=240-memoria[$e803+(f*4)];
  x:=248-memoria[$e800+(f*4)];
  put_gfx_sprite(nchar,color+$100,(atrib and $40)<>0,(atrib and $80)<>0,1);
  actualiza_gfx_sprite(x,y,2,1);
end;
actualiza_trozo_final(16,0,224,256,2);
end;

procedure eventos_freekick;
begin
if event.arcade then begin
  //IN0
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  //IN1
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  if arcade_input.coin[1] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
end;
end;

procedure freekick_principal;
var
  f:word;
  frame_m:single;
begin
init_controls(false,false,false,true);
frame_m:=z80_0.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to 262 do begin
    z80_0.run(frame_m);
    frame_m:=frame_m+z80_0.tframes-z80_0.contador;
    if f=239 then begin
      update_video_freekick;
      if nmi_enable then z80_0.change_nmi(PULSE_LINE);
    end;
  end;
  eventos_freekick;
  video_sync;
end;
end;

function freekick_getbyte(direccion:word):byte;
begin
case direccion of
  $0000..$e8ff:freekick_getbyte:=memoria[direccion];
  $ec00..$ec03:freekick_getbyte:=pia8255_0.read(direccion and $3);
  $f000..$f003:freekick_getbyte:=pia8255_1.read(direccion and $3);
  $f800:freekick_getbyte:=marcade.in0;
  $f801:freekick_getbyte:=marcade.in1;
  $f802:freekick_getbyte:=0;
  $f803:if spinner then freekick_getbyte:=analog.x[0]
          else freekick_getbyte:=analog.x[1];
end;
end;

procedure freekick_putbyte(direccion:word;valor:byte);
begin
if (direccion<$d000) then exit;
case direccion of
        $d000..$dfff,$e800..$e8ff:memoria[direccion]:=valor;
        $e000..$e7ff:if memoria[direccion]<>valor then begin
                        gfx[0].buffer[direccion and $3ff]:=true;
                        memoria[direccion]:=valor;
                     end;
        $ec00..$ec03:pia8255_0.write(direccion and $3,valor);
        $f000..$f003:pia8255_1.write(direccion and $3,valor);
        $f804:nmi_enable:=(valor and 1)<>0;
        $f806:spinner:=(valor and 1)=0;
        $fc00:sn_76496_0.Write(valor);
        $fc01:sn_76496_1.Write(valor);
        $fc02:sn_76496_2.Write(valor);
        $fc03:sn_76496_3.Write(valor);
end;
end;

function freekick_inbyte(puerto:word):byte;
begin
  if (puerto and $ff)=$ff then freekick_inbyte:=freekick_ff;
end;

procedure freekick_outbyte(valor:byte;puerto:word);
begin
  if (puerto and $ff)=$ff then freekick_ff:=valor;
end;

procedure freeckick_snd_irq;
begin
  z80_0.change_irq(HOLD_LINE);
end;

function ppi0_c_read:byte;
begin
  ppi0_c_read:=snd_rom[snd_rom_addr];
end;

procedure ppi0_a_write(valor:byte);
begin
  snd_rom_addr:=(snd_rom_addr and $ff00) or valor;
end;

procedure ppi0_b_write(valor:byte);
begin
  snd_rom_addr:=(snd_rom_addr and $ff) or (valor shl 8);
end;

function ppi1_a_read:byte;
begin
  ppi1_a_read:=marcade.dswa;
end;

function ppi1_b_read:byte;
begin
  ppi1_b_read:=marcade.dswb;
end;

function ppi1_c_read:byte;
begin
  ppi1_c_read:=marcade.dswc;
end;

procedure freekick_sound_update;
begin
  sn_76496_0.update;
  sn_76496_1.update;
  sn_76496_2.update;
  sn_76496_3.update;
end;

//Main
procedure reset_freekick;
begin
 z80_0.reset;
 sn_76496_0.reset;
 sn_76496_1.reset;
 sn_76496_2.reset;
 sn_76496_3.reset;
 pia8255_0.reset;
 pia8255_1.reset;
 reset_audio;
 snd_rom_addr:=0;
 spinner:=false;
 nmi_enable:=false;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
end;

function iniciar_freekick:boolean;
var
  colores:tpaleta;
  f:word;
  bit0,bit1,bit2,bit3:byte;
  memoria_temp:array[0..$ffff] of byte;
const
      pc_x:array[0..7] of dword=(0,1,2,3, 4,5,6,7);
      pc_y:array[0..7] of dword=(0*8,1*8,2*8,3*8,4*8,5*8,6*8,7*8);
      ps_x:array[0..15] of dword=(0, 1, 2, 3, 4, 5, 6, 7,
	128+0,128+1,128+2,128+3,128+4,128+5,128+6,128+7);
      ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
		8*8, 9*8, 10*8, 11*8,12*8,13*8,14*8,15*8);
begin
iniciar_freekick:=false;
iniciar_audio(false);
screen_init(1,256,256);
screen_init(2,256,256,false,true);
iniciar_video(224,256);
//Main CPU
z80_0:=cpu_z80.create(3000000,263);
z80_0.change_ram_calls(freekick_getbyte,freekick_putbyte);
z80_0.change_io_calls(freekick_inbyte,freekick_outbyte);
z80_0.init_sound(freekick_sound_update);
//Sound Chips
sn_76496_0:=sn76496_chip.Create(3000000);
sn_76496_1:=sn76496_chip.Create(3000000);
sn_76496_2:=sn76496_chip.Create(3000000);
sn_76496_3:=sn76496_chip.Create(3000000);
//IRQ Sound CPU
init_timer(z80_0.numero_cpu,3000000/120,freeckick_snd_irq,true);
case main_vars.tipo_maquina of
  211:begin //Free Kick
        //analog
        init_analog(z80_0.numero_cpu,z80_0.clock,30,15,$ff,$FFFF,0,false);
        //PPI
        pia8255_0:=pia8255_chip.create;
        pia8255_0.change_ports(nil,nil,ppi0_c_read,ppi0_a_write,ppi0_b_write,nil);
        pia8255_1:=pia8255_chip.create;
        pia8255_1.change_ports(ppi1_a_read,ppi1_b_read,ppi1_c_read,nil,nil,nil);
        //cargar roms
        if not(cargar_roms(@memoria[0],@freekick_rom,'freekick.zip')) then exit;
        //snd rom
        if not(cargar_roms(@snd_rom[0],@freekick_sound_data,'freekick.zip')) then exit;
        //convertir chars
        if not(cargar_roms(@memoria_temp[0],@freekick_chars[0],'freekick.zip',0)) then exit;
        init_gfx(0,8,8,$800);
        gfx_set_desc_data(3,0,8*8,$800*2*8*8,$800*1*8*8,$800*0*8*8);
        convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,true);
        //convertir sprites
        if not(cargar_roms(@memoria_temp[0],@freekick_sprites[0],'freekick.zip',0)) then exit;
        init_gfx(1,16,16,$200);
        gfx[1].trans[0]:=true;
        gfx_set_desc_data(3,0,16*16,$200*0*16*16,$200*2*16*16,$200*1*16*16);
        convert_gfx(1,0,@memoria_temp[0],@ps_x[0],@ps_y[0],false,true);
        //poner la paleta
        if not(cargar_roms(@memoria_temp[0],@freekick_pal[0],'freekick.zip',0)) then exit;
        //DIP
        marcade.dswa:=$bf;
        marcade.dswb:=$ff;
        marcade.dswc:=$80;
        marcade.dswa_val:=@freekick_dip_a;
        marcade.dswb_val:=@freekick_dip_b;
        marcade.dswc_val:=@freekick_dip_c;
  end;
end;
//Pal
for f:=0 to $1ff do begin
		//red
		bit0:=(memoria_temp[f] shr 0) and 1;
		bit1:=(memoria_temp[f] shr 1) and 1;
		bit2:=(memoria_temp[f] shr 2) and 1;
		bit3:=(memoria_temp[f] shr 3) and 1;
		colores[f].r:=$0e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
		//green
		bit0:=(memoria_temp[f+$200] shr 0) and 1;
		bit1:=(memoria_temp[f+$200] shr 1) and 1;
		bit2:=(memoria_temp[f+$200] shr 2) and 1;
		bit3:=(memoria_temp[f+$200] shr 3) and 1;
		colores[f].g:=$0e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
		// blue
		bit0:=(memoria_temp[f+$400] shr 0) and 1;
		bit1:=(memoria_temp[f+$400] shr 1) and 1;
		bit2:=(memoria_temp[f+$400] shr 2) and 1;
		bit3:=(memoria_temp[f+$400] shr 3) and 1;
		colores[f].b:=$0e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
end;
set_pal(colores,$200);
//final
reset_freekick;
iniciar_freekick:=true;
end;

procedure Cargar_freekick;
begin
  llamadas_maquina.iniciar:=iniciar_freekick;
  llamadas_maquina.bucle_general:=freekick_principal;
  llamadas_maquina.reset:=reset_freekick;
  llamadas_maquina.fps_max:=59.410646;
end;

end.
