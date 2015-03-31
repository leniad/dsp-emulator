unit ladybug_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,sn_76496,controls_engine,gfx_engine,rom_engine,
     pal_engine,sound_engine,misc_functions;

procedure Cargar_ladybug;
procedure ladybug_principal;
function iniciar_ladybug:boolean;
procedure reset_ladybug;
procedure cerrar_ladybug;
//Main CPU
function ladybug_getbyte(direccion:word):byte;
procedure ladybug_putbyte(direccion:word;valor:byte);
procedure ladybug_sound_update;

const
        //Lady Bug
        ladybug_rom:array[0..6] of tipo_roms=(
        (n:'l1.c4';l:$1000;p:0;crc:$d09e0adb),(n:'l2.d4';l:$1000;p:$1000;crc:$88bc4a0a),
        (n:'l3.e4';l:$1000;p:$2000;crc:$53e9efce),(n:'l4.h4';l:$1000;p:$3000;crc:$ffc424d7),
        (n:'l5.j4';l:$1000;p:$4000;crc:$ad6af809),(n:'l6.k4';l:$1000;p:$5000;crc:$cf1acca4),());
        ladybug_pal:array[0..2] of tipo_roms=(
        (n:'10-2.k1';l:$20;p:0;crc:$df091e52),(n:'10-1.f4';l:$20;p:$20;crc:$40640d8f),());
        ladybug_char:array[0..2] of tipo_roms=(
        (n:'l9.f7';l:$1000;p:0;crc:$77b1da1e),(n:'l0.h7';l:$1000;p:$1000;crc:$aa82e00b),());
        ladybug_sprites:array[0..2] of tipo_roms=(
        (n:'l8.l7';l:$1000;p:0;crc:$8b99910b),(n:'l7.m7';l:$1000;p:$1000;crc:$86a5b448),());
        //Snap Jack
        snapjack_rom:array[0..6] of tipo_roms=(
        (n:'sj1.c4';l:$1000;p:0;crc:$6b30fcda),(n:'sj2.d4';l:$1000;p:$1000;crc:$1f1088d1),
        (n:'sj3.e4';l:$1000;p:$2000;crc:$edd65f3a),(n:'sj4.h4';l:$1000;p:$3000;crc:$f4481192),
        (n:'sj5.j4';l:$1000;p:$4000;crc:$1bff7d05),(n:'sj6.k4';l:$1000;p:$5000;crc:$21793edf),());
        snapjack_pal:array[0..2] of tipo_roms=(
        (n:'10-2.k1';l:$20;p:0;crc:$cbbd9dd1),(n:'10-1.f4';l:$20;p:$20;crc:$5b16fbd2),());
        snapjack_char:array[0..2] of tipo_roms=(
        (n:'sj9.f7';l:$1000;p:0;crc:$ff2011c7),(n:'sj0.h7';l:$1000;p:$1000;crc:$f097babb),());
        snapjack_sprites:array[0..2] of tipo_roms=(
        (n:'sj8.l7';l:$1000;p:0;crc:$b7f105b6),(n:'sj7.m7';l:$1000;p:$1000;crc:$1cdb03a8),());
        //Cosmic Avenger
        cavenger_rom:array[0..6] of tipo_roms=(
        (n:'1.c4';l:$1000;p:0;crc:$9e0cc781),(n:'2.d4';l:$1000;p:$1000;crc:$5ce5b950),
        (n:'3.e4';l:$1000;p:$2000;crc:$bc28218d),(n:'4.h4';l:$1000;p:$3000;crc:$2b32e9f5),
        (n:'5.j4';l:$1000;p:$4000;crc:$d117153e),(n:'6.k4';l:$1000;p:$5000;crc:$c7d366cb),());
        cavenger_pal:array[0..2] of tipo_roms=(
        (n:'10-2.k1';l:$20;p:0;crc:$42a24dd5),(n:'10-1.f4';l:$20;p:$20;crc:$d736b8de),());
        cavenger_char:array[0..2] of tipo_roms=(
        (n:'9.f7';l:$1000;p:0;crc:$63357785),(n:'0.h7';l:$1000;p:$1000;crc:$52ad1133),());
        cavenger_sprites:array[0..2] of tipo_roms=(
        (n:'8.l7';l:$1000;p:0;crc:$b022bf2d),(n:'8.l7';l:$1000;p:$1000;crc:$b022bf2d),());
        //Dip
        ladybug_dip_a:array [0..7] of def_dip=(
        (mask:$3;name:'Difficulty';number:4;dip:((dip_val:$3;dip_name:'Easy'),(dip_val:$2;dip_name:'Medium'),(dip_val:$1;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'High Score Names';number:2;dip:((dip_val:$0;dip_name:'3 Letters'),(dip_val:$4;dip_name:'10 Letters'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Rack Test';number:2;dip:((dip_val:$8;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Freeze';number:2;dip:((dip_val:$10;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$20;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Free Play';number:2;dip:((dip_val:$40;dip_name:'No'),(dip_val:$0;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Lives';number:2;dip:((dip_val:$80;dip_name:'3'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        ladybug_dip_b:array [0..2] of def_dip=(
        (mask:$f0;name:'Coin A';number:10;dip:((dip_val:$60;dip_name:'4C 1C'),(dip_val:$80;dip_name:'3C 1C'),(dip_val:$a0;dip_name:'2C 1C'),(dip_val:$70;dip_name:'3C 2C'),(dip_val:$f0;dip_name:'1C 1C'),(dip_val:$90;dip_name:'2C 3C'),(dip_val:$e0;dip_name:'1C 2C'),(dip_val:$d0;dip_name:'1C 3C'),(dip_val:$c0;dip_name:'1C 4C'),(dip_val:$b0;dip_name:'1C 5C'),(),(),(),(),(),())),
        (mask:$0f;name:'Coin B';number:10;dip:((dip_val:$06;dip_name:'4C 1C'),(dip_val:$08;dip_name:'3C 1C'),(dip_val:$0a;dip_name:'2C 1C'),(dip_val:$07;dip_name:'3C 2C'),(dip_val:$0f;dip_name:'1C 1C'),(dip_val:$09;dip_name:'2C 3C'),(dip_val:$0e;dip_name:'1C 2C'),(dip_val:$0d;dip_name:'1C 3C'),(dip_val:$0c;dip_name:'1C 4C'),(dip_val:$0b;dip_name:'1C 5C'),(),(),(),(),(),())),());
        snapjack_dip_a:array [0..4] of def_dip=(
        (mask:$3;name:'Difficulty';number:4;dip:((dip_val:$3;dip_name:'Easy'),(dip_val:$2;dip_name:'Medium'),(dip_val:$1;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'High Score Names';number:2;dip:((dip_val:$0;dip_name:'3 Letters'),(dip_val:$4;dip_name:'10 Letters'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Cabinet';number:2;dip:((dip_val:$8;dip_name:'Upright'),(dip_val:$0;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Lives';number:4;dip:((dip_val:$0;dip_name:'2'),(dip_val:$c0;dip_name:'3'),(dip_val:$80;dip_name:'4'),(dip_val:$40;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),());
        snapjack_dip_b:array [0..2] of def_dip=(
        (mask:$f0;name:'Coin A';number:11;dip:((dip_val:$50;dip_name:'4C 1C'),(dip_val:$70;dip_name:'3C 1C'),(dip_val:$a0;dip_name:'2C 1C'),(dip_val:$60;dip_name:'3C 2C'),(dip_val:$90;dip_name:'2C 2C'),(dip_val:$f0;dip_name:'1C 1C'),(dip_val:$80;dip_name:'2C 3C'),(dip_val:$e0;dip_name:'1C 2C'),(dip_val:$d0;dip_name:'1C 3C'),(dip_val:$c0;dip_name:'1C 4C'),(dip_val:$b0;dip_name:'1C 5C'),(),(),(),(),())),
        (mask:$0f;name:'Coin B';number:11;dip:((dip_val:$05;dip_name:'4C 1C'),(dip_val:$07;dip_name:'3C 1C'),(dip_val:$0a;dip_name:'2C 1C'),(dip_val:$06;dip_name:'3C 2C'),(dip_val:$09;dip_name:'2C 2C'),(dip_val:$0f;dip_name:'1C 1C'),(dip_val:$08;dip_name:'2C 3C'),(dip_val:$0e;dip_name:'1C 2C'),(dip_val:$0d;dip_name:'1C 3C'),(dip_val:$0c;dip_name:'1C 4C'),(dip_val:$0b;dip_name:'1C 5C'),(),(),(),(),())),());
        cavenger_dip_a:array [0..5] of def_dip=(
        (mask:$3;name:'Difficulty';number:4;dip:((dip_val:$3;dip_name:'Easy'),(dip_val:$2;dip_name:'Medium'),(dip_val:$1;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'High Score Names';number:2;dip:((dip_val:$0;dip_name:'3 Letters'),(dip_val:$4;dip_name:'10 Letters'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$8;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Initial High Score';number:4;dip:((dip_val:$0;dip_name:'0'),(dip_val:$30;dip_name:'5000'),(dip_val:$20;dip_name:'8000'),(dip_val:$10;dip_name:'10000'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Lives';number:4;dip:((dip_val:$0;dip_name:'2'),(dip_val:$c0;dip_name:'3'),(dip_val:$80;dip_name:'4'),(dip_val:$40;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 irq_vblank:boolean;
 vblank_val:byte;

implementation

procedure Cargar_ladybug;
begin
llamadas_maquina.iniciar:=iniciar_ladybug;
llamadas_maquina.bucle_general:=ladybug_principal;
llamadas_maquina.cerrar:=cerrar_ladybug;
llamadas_maquina.reset:=reset_ladybug;
end;

function iniciar_ladybug:boolean;
var
      colores:tpaleta;
      f:word;
      bit0,bit1:byte;
      memoria_temp:array[0..$1fff] of byte;
      rweights,gweights,bweights:array[0..1] of single;
const
  ps_x:array[0..15] of dword=(0, 2, 4, 6, 8, 10, 12, 14,
			8*16+0, 8*16+2, 8*16+4, 8*16+6, 8*16+8, 8*16+10, 8*16+12, 8*16+14);
  ps_y:array[0..15] of dword=(23*16, 22*16, 21*16, 20*16, 19*16, 18*16, 17*16, 16*16,
			7*16, 6*16, 5*16, 4*16, 3*16, 2*16, 1*16, 0*16);
  pc_x:array[0..7] of dword=(7, 6, 5, 4, 3, 2, 1, 0);
  pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
  pss_x:array[0..7] of dword=(0, 2, 4, 6, 8, 10, 12, 14);
  pss_y:array[0..7] of dword=(7*16, 6*16, 5*16, 4*16, 3*16, 2*16, 1*16, 0*16);
  resistances:array[0..1] of integer=(470,220);
begin
iniciar_ladybug:=false;
iniciar_audio(false);
//Pantallas:  principal+char y sprites
screen_init(1,256,256,false,true);
screen_init(2,256,256,true);
screen_mod_scroll(2,0,0,0,256,256,255);
case main_vars.tipo_maquina of
  34:iniciar_video(192,240);
  200,201:begin
        screen_0_mod_real(256,256);
        iniciar_video(240,192);
        main_screen.rot90_screen:=true;
      end;
end;
//Main CPU
main_z80:=cpu_z80.create(4000000,256);
main_z80.change_ram_calls(ladybug_getbyte,ladybug_putbyte);
main_z80.init_sound(ladybug_sound_update);
//Audio chips
sn_76496_0:=sn76496_chip.Create(4000000);
sn_76496_1:=sn76496_chip.Create(4000000);
case main_vars.tipo_maquina of
  34:begin //Lady bug
        //cargar roms
        if not(cargar_roms(@memoria[0],@ladybug_rom[0],'ladybug.zip',0)) then exit;
        //convertir chars
        if not(cargar_roms(@memoria_temp[0],@ladybug_char[0],'ladybug.zip',0)) then exit;
        init_gfx(0,8,8,512);
        gfx[0].trans[0]:=true;
        gfx_set_desc_data(2,0,8*8,0,512*8*8);
        convert_gfx(@gfx[0],0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,true);
        //convertir sprites
        if not(cargar_roms(@memoria_temp[0],@ladybug_sprites[0],'ladybug.zip',0)) then exit;
        init_gfx(1,16,16,128);
        gfx[1].trans[0]:=true;
        gfx_set_desc_data(2,0,64*8,1,0);
        convert_gfx(@gfx[1],0,@memoria_temp[0],@ps_x[0],@ps_y[0],false,true);
        //convetir sprites pequeños
        init_gfx(2,8,8,512);
        gfx[2].trans[0]:=true;
        gfx_set_desc_data(2,0,16*8,1,0);
        convert_gfx(@gfx[2],0,@memoria_temp[0],@pss_x[0],@pss_y[0],false,true);
        //DIP
        marcade.dswa:=$df;
        marcade.dswb:=$ff;
        marcade.dswa_val:=@ladybug_dip_a;
        marcade.dswb_val:=@ladybug_dip_b;
        //poner la paleta
        if not(cargar_roms(@memoria_temp[0],@ladybug_pal[0],'ladybug.zip',0)) then exit;
  end;
  200:begin //SnapJack
        //cargar roms
        if not(cargar_roms(@memoria[0],@snapjack_rom[0],'snapjack.zip',0)) then exit;
        //convertir chars
        if not(cargar_roms(@memoria_temp[0],@snapjack_char[0],'snapjack.zip',0)) then exit;
        init_gfx(0,8,8,512);
        gfx[0].trans[0]:=true;
        gfx_set_desc_data(2,0,8*8,0,512*8*8);
        convert_gfx(@gfx[0],0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,true);
        //convertir sprites
        if not(cargar_roms(@memoria_temp[0],@snapjack_sprites[0],'snapjack.zip',0)) then exit;
        init_gfx(1,16,16,128);
        gfx[1].trans[0]:=true;
        gfx_set_desc_data(2,0,64*8,1,0);
        convert_gfx(@gfx[1],0,@memoria_temp[0],@ps_x[0],@ps_y[0],false,true);
        //convetir sprites pequeños
        init_gfx(2,8,8,512);
        gfx[2].trans[0]:=true;
        gfx_set_desc_data(2,0,16*8,1,0);
        convert_gfx(@gfx[2],0,@memoria_temp[0],@pss_x[0],@pss_y[0],false,true);
        //DIP
        marcade.dswa:=$c7;
        marcade.dswb:=$ff;
        marcade.dswa_val:=@snapjack_dip_a;
        marcade.dswb_val:=@snapjack_dip_b;
        //poner la paleta
        if not(cargar_roms(@memoria_temp[0],@snapjack_pal[0],'snapjack.zip',0)) then exit;
  end;
  201:begin //Cosmic Avenger
        //cargar roms
        if not(cargar_roms(@memoria[0],@cavenger_rom[0],'cavenger.zip',0)) then exit;
        //convertir chars
        if not(cargar_roms(@memoria_temp[0],@cavenger_char[0],'cavenger.zip',0)) then exit;
        init_gfx(0,8,8,512);
        gfx[0].trans[0]:=true;
        gfx_set_desc_data(2,0,8*8,0,512*8*8);
        convert_gfx(@gfx[0],0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,true);
        //convertir sprites
        if not(cargar_roms(@memoria_temp[0],@cavenger_sprites[0],'cavenger.zip',0)) then exit;
        init_gfx(1,16,16,128);
        gfx[1].trans[0]:=true;
        gfx_set_desc_data(2,0,64*8,1,0);
        convert_gfx(@gfx[1],0,@memoria_temp[0],@ps_x[0],@ps_y[0],false,true);
        //convetir sprites pequeños
        init_gfx(2,8,8,512);
        gfx[2].trans[0]:=true;
        gfx_set_desc_data(2,0,16*8,1,0);
        convert_gfx(@gfx[2],0,@memoria_temp[0],@pss_x[0],@pss_y[0],false,true);
        //DIP
        marcade.dswa:=$c7;
        marcade.dswb:=$ff;
        marcade.dswa_val:=@cavenger_dip_a;
        marcade.dswb_val:=@ladybug_dip_b;
        //poner la paleta
        if not(cargar_roms(@memoria_temp[0],@cavenger_pal[0],'cavenger.zip',0)) then exit;
  end;
end;
compute_resistor_weights(0,	255, -1.0,
  2,@resistances[0],@rweights[0],470,0,
  2,@resistances[0],@gweights[0],470,0,
  2,@resistances[0],@bweights[0],470,0);
for f:=0 to $1f do begin
  // red component */
  bit0:=(not(memoria_temp[f]) shr 0) and $01;
  bit1:=(not(memoria_temp[f]) shr 5) and $01;
  colores[f].r:=combine_2_weights(@rweights[0],bit0,bit1);
  // green component */
  bit0:=(not(memoria_temp[f]) shr 2) and $01;
  bit1:=(not(memoria_temp[f]) shr 6) and $01;
  colores[f].g:=combine_2_weights(@gweights[0],bit0,bit1);
  // blue component */
  bit0:=(not(memoria_temp[f]) shr 4) and $01;
  bit1:=(not(memoria_temp[f]) shr 7) and $01;
  colores[f].b:=combine_2_weights(@bweights[0],bit0,bit1);
end;
set_pal(colores,$20);
for f:=0 to $1f do gfx[0].colores[f]:=((f shl 3) and $18) or ((f shr 2) and $07);
for f:=0 to $1f do begin
  gfx[1].colores[f]:=BITSWAP8((memoria_temp[f+$20] shr 0) and $f,7,6,5,4,0,1,2,3);
  gfx[1].colores[f+$20]:=BITSWAP8((memoria_temp[f+$20] shr 4) and $f,7,6,5,4,0,1,2,3);
  gfx[2].colores[f]:=gfx[1].colores[f];
  gfx[2].colores[f+$20]:=gfx[1].colores[f+$20];
end;
//final
reset_ladybug;
iniciar_ladybug:=true;
end;

procedure cerrar_ladybug;
begin
main_z80.free;
sn_76496_0.Free;
sn_76496_1.Free;
close_audio;
close_video;
end;

procedure reset_ladybug;
begin
 main_z80.reset;
 sn_76496_0.reset;
 sn_76496_1.reset;
 reset_audio;
 irq_vblank:=false;
 vblank_val:=$40;
 marcade.in0:=$FF;
 marcade.in1:=$3F;
 marcade.in2:=$FF;
end;

procedure update_video_ladybug;
var
  f,h,color,nchar:word;
  x,y,atrib:byte;
  flipx,flipy:boolean;
  i:integer;
begin
fill_full_screen(1,0);
for f:=$0 to $3ff do begin
  if gfx[0].buffer[f] then begin
    x:=f div 32;
    y:=31-(f mod 32);
    atrib:=memoria[$d400+f];
    nchar:=memoria[$d000+f]+(atrib and $08) shl 5;
    color:=(atrib and $7) shl 2;
    put_gfx_trans(x*8,y*8,nchar,color,2,0);
    gfx[0].buffer[f]:=false;
  end;
end;
for f:=0 to 31 do scroll__y_part(2,1,255-memoria[$d000+(32*(f mod 4)+(f div 4))],0,f*8,8);
{abccdddd eeeeeeee fffghhhh iiiiiiii
 a enable?
 b size (0 = 8x8, 1 = 16x16)
 cc flip
 dddd x offset
 eeeeeeee sprite code (shift right 2 bits for 16x16 sprites)
 fff unknown
 g sprite bank
 hhhh color
 iiiiiiii y position}
for f:=$e downto $2 do begin
  i:=0;
  h:=f*$40;
  while ((i<$40) and (buffer_sprites[h+i]<>0)) do i:=i+4;
  while (i>0) do begin
    i:=i-4;
    atrib:=buffer_sprites[h+i];
    if (atrib and $80)<>0 then begin
      color:=(buffer_sprites[$2+(h+i)] and $f) shl 2;
      if main_screen.flip_main_screen then y:=buffer_sprites[$3+(h+i)]+1
        else y:=241-(buffer_sprites[$3+(h+i)]);
      flipy:=(atrib and $20)<>0;
      flipx:=(atrib and $10)<>0;
      if (atrib and $40)<>0	then begin // 16x16
        nchar:=(buffer_sprites[$1+(h+i)] shr 2)+4*(buffer_sprites[$2+(h+i)] and $10);
        x:=(h shr 2)-8+(atrib and $f);
        if main_screen.flip_main_screen then begin
          x:=240-x;
          flipy:=not(flipy);
          flipx:=not(flipx);
        end;
        put_gfx_sprite(nchar and $7f,color,flipx,flipy,1);
        actualiza_gfx_sprite(x,y,1,1);
      end else begin  //8x8 Parece ser que LB no usa los sprites pequeños!!!
        nchar:=buffer_sprites[$1+(h+i)]+16*(buffer_sprites[$2+(h+i)] and $10);
        x:=(h shr 2)+(atrib and $f);
        if main_screen.flip_main_screen then begin
          x:=240-x;
          flipy:=not(flipy);
          flipx:=not(flipx);
        end;
        put_gfx_sprite(nchar and $1ff,color,flipx,flipy,2);
        actualiza_gfx_sprite(x,y+8,1,2);
      end;
    end;
  end;
end;
actualiza_trozo_final(32,8,192,240,1);
end;

procedure eventos_ladybug;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $F7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $Fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  //MISC
  if arcade_input.but1[0] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  //P2
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $F7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $Fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  //SYS
  if arcade_input.coin[0] then main_z80.pedir_nmi:=ASSERT_LINE else main_z80.clear_nmi;
  if arcade_input.coin[1] then main_z80.pedir_irq:=HOLD_LINE;
end;
end;

procedure ladybug_principal;
var
  frame:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame:=main_z80.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
    main_z80.run(frame);
    frame:=frame+main_z80.tframes-main_z80.contador;
    if f=224 then begin
      vblank_val:=$80;
      update_video_ladybug;
    end;
  end;
  eventos_ladybug;
  video_sync;
  copymemory(@buffer_sprites[0],@memoria[$7000],$400);
  vblank_val:=$40;
end;
end;

function ladybug_getbyte(direccion:word):byte;
begin
case direccion of
  0..$6fff,$d000..$d7ff:ladybug_getbyte:=memoria[direccion];
  $9000:ladybug_getbyte:=marcade.in0;
  $9001:ladybug_getbyte:=marcade.in1 or vblank_val;
  $9002:ladybug_getbyte:=marcade.dswa;
  $9003:ladybug_getbyte:=marcade.dswb;
  $e000:ladybug_getbyte:=marcade.in2;
end;
end;

procedure ladybug_putbyte(direccion:word;valor:byte);
begin
if direccion<$6000 then exit;
memoria[direccion]:=valor;
case direccion of
  $a000:main_screen.flip_main_screen:=(valor and 1)<>0;
  $b000..$bfff:sn_76496_0.Write(valor);
  $c000..$cfff:sn_76496_1.Write(valor);
  $d000..$dfff:gfx[0].buffer[direccion and $3ff]:=true;
end;
end;

procedure ladybug_sound_update;
begin
  sn_76496_0.Update;
  sn_76496_1.Update;
end;

end.
