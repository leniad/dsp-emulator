unit freekick_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,sn_76496,gfx_engine,rom_engine,
     file_engine,pal_engine,sound_engine;

procedure Cargar_freekick;
procedure freekick_principal;
procedure reset_freekick;
procedure cerrar_freekick;
//Main CPU
function freekick_getbyte(direccion:word):byte;
procedure freekick_putbyte(direccion:word;valor:byte);
function iniciar_freekick:boolean;
procedure freekick_sound_update;

const
        //Green Beret
        freekick_rom:tipo_roms=(n:'ns6201-a_1987.10_free_kick.cpu';l:$d000;p:0;crc:$6d172850);
        freekick_sound_data:tipo_roms=(n:'11.1e';l:$8000;p:0;crc:$a6030ba9);
        freekick_pal:array[0..3] of tipo_roms=(
        (n:'577h09.2f';l:$20;p:0;crc:$c15e7c80),(n:'577h11.6f';l:$100;p:$20;crc:$2a1a992b),
        (n:'577h10.5f';l:$100;p:$120;crc:$e9de1e53),());
        freekick_chars:array[0..3] of tipo_roms=(
        (n:'12.1h';l:$4000;p:0;crc:$fb82e486),(n:'13.1j';l:$4000;p:$4000;crc:$3ad78ee2),
        (n:'14.1l';l:$4000;p:$8000;crc:$0185695f),());
        freekick_sprites:array[0..3] of tipo_roms=(
        (n:'15.1m';l:$4000;p:0;crc:$0fa7c13c),(n:'16.1p';l:$4000;p:$4000;crc:$2b996e89),
        (n:'17.1r';l:$4000;p:$8000;crc:$e7894def),());
        //Mr Goemon
        mrgoemon_rom:array[0..2] of tipo_roms=(
        (n:'621d01.10c';l:$8000;p:0;crc:$b2219c56),(n:'621d02.12c';l:$8000;p:$8000;crc:$c3337a97),());
        mrgoemon_pal:array[0..3] of tipo_roms=(
        (n:'621a06.5f';l:$20;p:0;crc:$7c90de5f),(n:'621a08.7f';l:$100;p:$20;crc:$2fb244dd),
        (n:'621a07.6f';l:$100;p:$120;crc:$3980acdc),());
        mrgoemon_char:tipo_roms=(n:'621a05.6d';l:$4000;p:0;crc:$f0a6dfc5);
        mrgoemon_sprites:array[0..2] of tipo_roms=(
        (n:'621d03.4d';l:$8000;p:0;crc:$66f2b973),(n:'621d04.5d';l:$8000;p:$8000;crc:$47df6301),());
        //Dip
        freekick_dip_a:array [0..2] of def_dip=(
        (mask:$0f;name:'Coin A';number:16;dip:((dip_val:$2;dip_name:'4C 1C'),(dip_val:$5;dip_name:'3C 1C'),(dip_val:$8;dip_name:'2C 1C'),(dip_val:$4;dip_name:'3C 2C'),(dip_val:$1;dip_name:'4C 3C'),(dip_val:$f;dip_name:'1C 1C'),(dip_val:$3;dip_name:'3C 4C'),(dip_val:$7;dip_name:'2C 3C'),(dip_val:$e;dip_name:'1C 2C'),(dip_val:$6;dip_name:'2C 5C'),(dip_val:$d;dip_name:'1C 3C'),(dip_val:$c;dip_name:'1C 4C'),(dip_val:$b;dip_name:'1C 5C'),(dip_val:$a;dip_name:'1C 6C'),(dip_val:$9;dip_name:'1C 7C'),(dip_val:$0;dip_name:'Free Play'))),
        (mask:$f0;name:'Coin B';number:16;dip:((dip_val:$20;dip_name:'4C 1C'),(dip_val:$50;dip_name:'3C 1C'),(dip_val:$80;dip_name:'2C 1C'),(dip_val:$40;dip_name:'3C 2C'),(dip_val:$10;dip_name:'4C 3C'),(dip_val:$f0;dip_name:'1C 1C'),(dip_val:$30;dip_name:'3C 4C'),(dip_val:$70;dip_name:'2C 3C'),(dip_val:$e0;dip_name:'1C 2C'),(dip_val:$60;dip_name:'2C 5C'),(dip_val:$d0;dip_name:'1C 3C'),(dip_val:$c0;dip_name:'1C 4C'),(dip_val:$b0;dip_name:'1C 5C'),(dip_val:$a0;dip_name:'1C 6C'),(dip_val:$90;dip_name:'1C 7C'),(dip_val:$0;dip_name:'Invalid'))),());
        freekick_dip_b:array [0..5] of def_dip=(
        (mask:$3;name:'Lives';number:4;dip:((dip_val:$3;dip_name:'2'),(dip_val:$2;dip_name:'3'),(dip_val:$1;dip_name:'5'),(dip_val:$0;dip_name:'7'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$4;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$18;name:'Bonus Life';number:4;dip:((dip_val:$18;dip_name:'30K 70K+'),(dip_val:$10;dip_name:'40K 80K+'),(dip_val:$8;dip_name:'50K 100K+'),(dip_val:$0;dip_name:'50K 200K+'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$60;name:'Difficulty';number:4;dip:((dip_val:$60;dip_name:'Easy'),(dip_val:$40;dip_name:'Normal'),(dip_val:$20;dip_name:'Difficult'),(dip_val:$0;dip_name:'Very Difficult'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Demo Sounds';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        freekick_dip_c:array [0..2] of def_dip=(
        (mask:$1;name:'Flip Screen';number:2;dip:((dip_val:$1;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2;name:'Upright Controls';number:2;dip:((dip_val:$2;dip_name:'Single'),(dip_val:$0;dip_name:'Dual'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        mrgoemon_dip_b:array [0..5] of def_dip=(
        (mask:$3;name:'Lives';number:4;dip:((dip_val:$3;dip_name:'2'),(dip_val:$2;dip_name:'3'),(dip_val:$1;dip_name:'5'),(dip_val:$0;dip_name:'7'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$4;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$18;name:'Bonus Life';number:4;dip:((dip_val:$18;dip_name:'20K 60K+'),(dip_val:$10;dip_name:'30K 70K+'),(dip_val:$8;dip_name:'40K 80K+'),(dip_val:$0;dip_name:'50K 90K+'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$60;name:'Difficulty';number:4;dip:((dip_val:$60;dip_name:'Easy'),(dip_val:$40;dip_name:'Normal'),(dip_val:$20;dip_name:'Difficult'),(dip_val:$0;dip_name:'Very Difficult'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Demo Sounds';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 scroll_lineas:array[0..$1f] of word;
 memoria_rom:array[0..7,0..$7ff] of byte;
 interrupt_mask,interrupt_ticks,sound_latch,rom_bank:byte;
 banco_sprites:word;
 timer_hs:byte;

implementation

procedure Cargar_freekick;
begin
llamadas_maquina.iniciar:=iniciar_freekick;
llamadas_maquina.bucle_general:=freekick_principal;
llamadas_maquina.cerrar:=cerrar_freekick;
llamadas_maquina.reset:=reset_freekick;
llamadas_maquina.fps_max:=60.60606060;
end;

function iniciar_freekick:boolean;
var
      colores:tpaleta;
      f:word;
      ctemp1:byte;
      memoria_temp:array[0..$ffff] of byte;
const
      pc_x:array[0..7] of dword=(0*4, 1*4, 2*4, 3*4, 4*4, 5*4, 6*4, 7*4);
      pc_y:array[0..7] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32);
      ps_x:array[0..15] of dword=(0*4, 1*4, 2*4, 3*4, 4*4, 5*4, 6*4, 7*4,
		32*8+0*4, 32*8+1*4, 32*8+2*4, 32*8+3*4, 32*8+4*4, 32*8+5*4, 32*8+6*4, 32*8+7*4);
      ps_y:array[0..15] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32,
		64*8+0*32, 64*8+1*32, 64*8+2*32, 64*8+3*32, 64*8+4*32, 64*8+5*32, 64*8+6*32, 64*8+7*32);
procedure convert_chars;
begin
  init_gfx(0,8,8,512);
  gfx_set_desc_data(4,0,32*8,0,1,2,3);
  convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,false);
end;
procedure convert_sprites;
begin
  init_gfx(1,16,16,512);
  gfx_set_desc_data(4,0,128*8,0,1,2,3);
  convert_gfx(1,0,@memoria_temp[0],@ps_x[0],@ps_y[0],false,false);
end;
begin
iniciar_freekick:=false;
iniciar_audio(false);
//Pantallas:  principal+char y sprites
screen_init(1,512,256);
screen_mod_scroll(1,512,256,511,0,0,0);
screen_init(2,512,256,false,true);
screen_init(3,512,256,true,false);
screen_mod_scroll(3,512,256,511,0,0,0);
iniciar_video(240,224);
//Main CPU
main_z80:=cpu_z80.create(3072000,256);
main_z80.change_ram_calls(freekick_getbyte,freekick_putbyte);
main_z80.init_sound(freekick_sound_update);
//Sound Chips
sn_76496_0:=sn76496_chip.Create(1536000);
case main_vars.tipo_maquina of
  17:begin //Green Beret
        //cargar roms
        if not(cargar_roms(@memoria[0],@freekick_rom,'freekick.zip',1)) then exit;
        //convertir chars
        //if not(cargar_roms(@memoria_temp[0],@freekick_char,'freekick.zip')) then exit;
        convert_chars;
        //convertir sprites
        if not(cargar_roms(@memoria_temp[0],@freekick_sprites[0],'freekick.zip',0)) then exit;
        convert_sprites;
        //poner la paleta
        if not(cargar_roms(@memoria_temp[0],@freekick_pal[0],'freekick.zip',0)) then exit;
        marcade.dswb_val:=@freekick_dip_b;
  end;
  203:begin //Mr. Goemon
        if not(cargar_roms(@memoria_temp[0],@mrgoemon_rom[0],'mrgoemon.zip',0)) then exit;
        copymemory(@memoria[0],@memoria_temp[0],$c000);
        for f:=0 to 7 do copymemory(@memoria_rom[f,0],@memoria_temp[$c000+(f*$800)],$800);
        //convertir chars
        if not(cargar_roms(@memoria_temp[0],@mrgoemon_char,'mrgoemon.zip')) then exit;
        convert_chars;
        //convertir sprites
        if not(cargar_roms(@memoria_temp[0],@mrgoemon_sprites[0],'mrgoemon.zip',0)) then exit;
        convert_sprites;
        //poner la paleta
        if not(cargar_roms(@memoria_temp[0],@mrgoemon_pal[0],'mrgoemon.zip',0)) then exit;
        marcade.dswb_val:=@mrgoemon_dip_b;
  end;
end;
for f:=0 to 31 do begin
    ctemp1:=memoria_temp[f];
    colores[f].r:= $21*(ctemp1 and 1)+$47*((ctemp1 shr 1) and 1)+$97*((ctemp1 shr 2) and 1);
    colores[f].g:= $21*((ctemp1 shr 3) and 1)+$47*((ctemp1 shr 4) and 1)+$97*((ctemp1 shr 5) and 1);
    colores[f].b:= 0+$47*((ctemp1 shr 6) and 1)+$97*((ctemp1 shr 7) and 1);
end;
set_pal(colores,32);
//Poner el CLUT
for f:=0 to $FF do begin
  gfx[0].colores[f]:=memoria_temp[$20+f]+$10;
  gfx[1].colores[f]:=memoria_temp[$120+f] and $f;
end;
//DIP
marcade.dswa:=$ff;
marcade.dswb:=$4a;
marcade.dswc:=$ff;
marcade.dswa_val:=@freekick_dip_a;
marcade.dswc_val:=@freekick_dip_c;
//final
reset_freekick;
iniciar_freekick:=true;
end;

procedure cerrar_freekick;
begin
if main_vars.tipo_maquina=17 then save_hi('freekick.hi',@memoria[$d900],60);
main_z80.free;
sn_76496_0.Free;
close_audio;
close_video;
end;

procedure reset_freekick;
begin
 main_z80.reset;
 sn_76496_0.reset;
 reset_audio;
 marcade.in0:=$FF;
 marcade.in1:=$FF;
 marcade.in2:=$FF;
 banco_sprites:=0;
 interrupt_mask:=0;
 interrupt_ticks:=0;
 sound_latch:=0;
 fillchar(scroll_lineas[0],$20,0);
 rom_bank:=0;
end;

procedure update_video_freekick;inline;
var
  f,x,y,color,nchar,atrib2:word;
  atrib:byte;
begin
for f:=$7ff downto 0 do begin
  if gfx[0].buffer[f] then begin
    x:=f mod 64;
    y:=f div 64;
    //Color RAM
    //c000-c7ff --> Bits
    // 0-3 --> Color
    // 4 --> flip X
    // 5 --> Flip Y
    // 6 --> Numero Char
    // 7 --> prioridad
    atrib:=memoria[f+$c000];
    color:=(atrib and $f) shl 4;
    nchar:=memoria[f+$c800]+((atrib and $40) shl 2);
    if (atrib and $80)<>0 then begin
      put_gfx_flip(x*8,y*8,nchar,color,1,0,(atrib and $10)<>0,(atrib and $20)<>0);
      put_gfx_block_trans(x*8,y*8,3,8,8);
    end else begin
      put_gfx_block(x*8,y*8,1,8,8,0);
      put_gfx_mask_flip(x*8,y*8,nchar,color,3,0,0,$f,(atrib and $10)<>0,(atrib and $20)<>0);
    end;
    gfx[0].buffer[f]:=false;
  end;
end;
//hacer el scroll independiente linea a linea
for f:=0 to 31 do scroll__x_part(1,2,scroll_lineas[f],0,f*8,8);
//sprites
for f:=0 to $2f do begin
  atrib2:=$d000+banco_sprites+(f*4);
  atrib:=memoria[$1+atrib2];
  nchar:=memoria[atrib2]+(atrib and $40) shl 2;
  color:=(atrib and $f) shl 4;
  x:=memoria[$2+atrib2]+(atrib and $80) shl 1;
  y:=memoria[$3+atrib2];
  put_gfx_sprite_mask(nchar,color,(atrib and $10)<>0,(atrib and $20)<>0,1,0,$f);
  actualiza_gfx_sprite(x,y,2,1);
end;
for f:=0 to 31 do scroll__x_part(3,2,scroll_lineas[f],0,f*8,8);
actualiza_trozo_final(8,16,240,224,2);
end;

procedure eventos_freekick;
begin
if event.arcade then begin
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $F7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $Fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
end;
end;

procedure freekick_principal;
var
  f,ticks_mask:byte;
  frame_m:single;
begin
init_controls(false,false,false,true);
frame_m:=main_z80.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to 255 do begin
    main_z80.run(frame_m);
    frame_m:=frame_m+main_z80.tframes-main_z80.contador;
    if f=239 then update_video_freekick;
    if (f and $f)=0 then begin //every 16 scanlines
       ticks_mask:=not(interrupt_ticks) and (interrupt_ticks+1); // 0->1
	     interrupt_ticks:=interrupt_ticks+1;
	     // NMI on d0
	     if (ticks_mask and interrupt_mask and 1)<>0 then main_z80.pedir_nmi:=ASSERT_LINE;
	     // IRQ on d4
       if (ticks_mask and (interrupt_mask shl 2) and 8)<>0 then main_z80.pedir_irq:=ASSERT_LINE;
	     if (ticks_mask and (interrupt_mask shl 2) and 16)<>0 then main_z80.pedir_irq:=ASSERT_LINE;
    end;
  end;
  eventos_freekick;
  video_sync;
end;
end;

function freekick_getbyte(direccion:word):byte;
begin
case direccion of
  $0000..$e03f:freekick_getbyte:=memoria[direccion];
  $f200:freekick_getbyte:=marcade.dswb;
  $f400:freekick_getbyte:=marcade.dswc;
  $f600:freekick_getbyte:=marcade.dswa;
  $f601:freekick_getbyte:=marcade.in1;
  $f602:freekick_getbyte:=marcade.in0;
  $f603:freekick_getbyte:=marcade.in2;
  $f800..$ffff:freekick_getbyte:=memoria_rom[rom_bank,direccion and $7ff];
end;
end;

procedure freekick_putbyte(direccion:word;valor:byte);
var
  ack_mask:byte;
begin
if ((direccion<$c000) or (direccion>$f7ff)) then exit;
memoria[direccion]:=valor;
case direccion of
        $c000..$cfff:gfx[0].buffer[direccion and $7ff]:=true;
        $e000..$e01f:scroll_lineas[direccion and $1f]:=(scroll_lineas[direccion and $1f] and $100) or valor;
        $e020..$e03f:scroll_lineas[direccion and $1f]:=(scroll_lineas[direccion and $1f] and $ff) or ((valor and 1) shl 8);
        $e043:banco_sprites:=(valor and 8) shl 5;
        $e044:begin
                // bits 0/1/2 = interrupt enable
	              ack_mask:=not(valor) and interrupt_mask; // 1->0
	              if (ack_mask and 1)<>0 then main_z80.clear_nmi;
                if (ack_mask and 6)<>0 then main_z80.pedir_irq:=CLEAR_LINE;
	              interrupt_mask:=valor and 7;
	              // bit 3 = flip screen
                main_screen.flip_main_screen:=(valor and 8)<>0;
              end;
        $f000:rom_bank:=(valor and $e0) shr 5;
        $f200:sound_latch:=valor;
        $f400:sn_76496_0.Write(sound_latch);
end;
end;

procedure freekick_sound_update;
begin
  sn_76496_0.update;
end;

end.
