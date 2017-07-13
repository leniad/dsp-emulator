unit popeye_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,gfx_engine,ay_8910,rom_engine,
     misc_functions,pal_engine,sound_engine,qsnapshot;

procedure cargar_popeye;

implementation
const
        popeye_rom:array[0..4] of tipo_roms=(
        (n:'tpp2-c_f.7a';l:$2000;p:0;crc:$9af7c821),(n:'tpp2-c_f.7b';l:$2000;p:$2000;crc:$c3704958),
        (n:'tpp2-c_f.7c';l:$2000;p:$4000;crc:$5882ebf9),(n:'tpp2-c_f.7e';l:$2000;p:$6000;crc:$ef8649ca),());
        popeye_pal:array[0..4] of tipo_roms=(
        (n:'tpp2-c.4a';l:$20;p:0;crc:$375e1602),(n:'tpp2-c.3a';l:$20;p:$20;crc:$e950bea1),
        (n:'tpp2-c.5b';l:$100;p:$40;crc:$c5826883),(n:'tpp2-c.5a';l:$100;p:$140;crc:$c576afba),());
        popeye_char:tipo_roms=(n:'tpp2-v.5n';l:$1000;p:0;crc:$cca61ddd);
        popeye_sprites:array[0..4] of tipo_roms=(
        (n:'tpp2-v.1e';l:$2000;p:0;crc:$0f2cd853),(n:'tpp2-v.1f';l:$2000;p:$2000;crc:$888f3474),
        (n:'tpp2-v.1j';l:$2000;p:$4000;crc:$7e864668),(n:'tpp2-v.1k';l:$2000;p:$6000;crc:$49e1d170),());
        //Dip
        popeye_dip_a:array [0..2] of def_dip=(
        (mask:$f;name:'Coinage';number:9;dip:((dip_val:$8;dip_name:'6 Coin - 1 Credit'),(dip_val:$5;dip_name:'5 Coin - 1 Credit'),(dip_val:$9;dip_name:'4 Coin - 1 Credit'),(dip_val:$a;dip_name:'3 Coin - 1 Credit'),(dip_val:$d;dip_name:'2 Coin - 1 Credit'),(dip_val:$f;dip_name:'1 Coin - 1 Credit'),(dip_val:$e;dip_name:'1 Coin - 2 Credit'),(dip_val:$3;dip_name:'1 Coin - 3 Credit'),(dip_val:$0;dip_name:'Freeplay'),(),(),(),(),(),(),())),
        (mask:$60;name:'Copyright';number:3;dip:((dip_val:$40;dip_name:'Nintendo'),(dip_val:$20;dip_name:'Nintendo Co.,Ltd'),(dip_val:$60;dip_name:'Nintendo of America'),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        popeye_dip_b:array [0..5] of def_dip=(
        (mask:$3;name:'Lives';number:4;dip:((dip_val:$3;dip_name:'1 Live'),(dip_val:$2;dip_name:'2 Lives'),(dip_val:$1;dip_name:'3 Lives'),(dip_val:$0;dip_name:'4 Lives'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Difficulty';number:4;dip:((dip_val:$c;dip_name:'Easy'),(dip_val:$8;dip_name:'Medium'),(dip_val:$4;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Bonus Life';number:4;dip:((dip_val:$30;dip_name:'40000'),(dip_val:$20;dip_name:'60000'),(dip_val:$10;dip_name:'80000'),(dip_val:$0;dip_name:'None'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Demo Sounds';number:2;dip:((dip_val:$40;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$80;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
  prot0,prot1,prot_shift,palette_bank,scroll_y,dswbit,field:byte;
  popeye_mem_pal:array[0..$1f] of byte;
  fondo_write:array[0..$1fff] of boolean;
  scroll_x:word;

procedure cambiar_paleta(valor:byte);inline;
var
  f,ctemp1,ctemp2,ctemp3,ctemp4:byte;
  colores:tcolor;
begin
  for f:=0 to 15 do begin
    ctemp4:=popeye_mem_pal[f+$10*valor];
		// red component */
		ctemp1:=(ctemp4 shr 0) and $01;
		ctemp2:=(ctemp4 shr 1) and $01;
		ctemp3:=(ctemp4 shr 2) and $01;
		colores.r:=$1c*ctemp1+$31*ctemp2+$47*ctemp3;
		// green component */
		ctemp1:=(ctemp4 shr 3) and $01;
		ctemp2:=(ctemp4 shr 4) and $01;
		ctemp3:=(ctemp4 shr 5) and $01;
		colores.g:=$1c*ctemp1+$31*ctemp2+$47*ctemp3;
		// blue component */
		ctemp1:=(ctemp4 shr 6) and $01;
		ctemp2:=(ctemp4 shr 7) and $01;
		colores.b:=$31*ctemp1+$47*ctemp2;
    set_pal_color(colores,f);
   end;
   fillchar(fondo_write[0],$2000,1);
end;

procedure update_video_popeye;inline;
var
  f,color,nchar,x,y:word;
  i,atrib,atrib2:byte;
  punto:array[0..7] of word;
begin
if scroll_y=0 then fill_full_screen(3,0)
  else begin //Fondo con scroll (lo escribe directo)
    for f:=0 to $1fff do begin
      if fondo_write[f] then begin
        x:=8*(f mod 64);
        y:=4*(f div 64);
        for i:=0 to 7 do punto[i]:=paleta[memoria[f+$c000] and $0f];
        for i:=0 to 3 do putpixel(x,y+i,8,@punto[0],1);
        fondo_write[f]:=false;
      end;
    end;
    scroll_x_y(1,3,199-scroll_x,2*scroll_y);
  end;
//Sprites
for f:=0 to $9e do begin
  atrib:=memoria[$8c07+(f*4)];
  atrib2:=memoria[$8c06+(f*4)];
  nchar:=((atrib2 and $7f)+((atrib and $10) shl 3)+((atrib and $04) shl 6)) xor $1ff;
  color:=((atrib and $7)+(palette_bank and $07) shl 3) shl 2;
  put_gfx_sprite(nchar,color+48,(atrib2 and $80)<>0,(atrib and $08)<>0,1);
  x:=(memoria[$8c04+(f*4)] shl 1)-8;
  y:=(256-memoria[$8c05+(f*4)]) shl 1;
  actualiza_gfx_sprite(x,y,3,1);
end;
//Chars
for f:=$0 to $3ff do begin
  if gfx[0].buffer[f] then begin
    x:=f mod 32;
    y:=f div 32;
    nchar:=memoria[$a000+f];
    color:=((memoria[$a400+f]) and $f) shl 1;
    put_gfx_trans(x*16,y*16,nchar,color+16,2,0);
    gfx[0].buffer[f]:=false;
  end;
end;
actualiza_trozo(0,0,512,512,2,0,0,512,512,3);
actualiza_trozo_final(0,32,512,448,3);
end;

procedure eventos_popeye;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 or $4) else marcade.in0:=(marcade.in0 and $Fb);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 or $8) else marcade.in0:=(marcade.in0 and $F7);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 or $2) else marcade.in0:=(marcade.in0 and $fd);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 or $1) else marcade.in0:=(marcade.in0 and $fe);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 or $10) else marcade.in0:=(marcade.in0 and $ef);
  //P2
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 or $4) else marcade.in1:=(marcade.in1 and $Fb);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 or $8) else marcade.in1:=(marcade.in1 and $F7);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 or $2) else marcade.in1:=(marcade.in1 and $fd);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 or $1) else marcade.in1:=(marcade.in1 and $fe);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 or $10) else marcade.in1:=(marcade.in1 and $ef);
  //SYSTEM
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 or $80) else marcade.in2:=(marcade.in2 and $7f);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 or $20) else marcade.in2:=(marcade.in2 and $df);
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 or $4) else marcade.in2:=(marcade.in2 and $fb);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 or $8) else marcade.in2:=(marcade.in2 and $f7);
end;
end;

procedure popeye_principal;
var
  frame:single;
  main_z80_reg:npreg_z80;
  f:word;
begin
init_controls(false,false,false,true);
frame:=z80_0.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to 511 do begin
      z80_0.run(frame);
      frame:=frame+z80_0.tframes-z80_0.contador;
      if f=479 then begin
          update_video_popeye;
          main_z80_reg:=z80_0.get_internal_r;
          if (main_z80_reg.i and 1)<>0 then begin
            z80_0.change_nmi(PULSE_LINE);
            field:=field xor $10;
          end;
      end;
  end;
  eventos_popeye;
  video_sync;
end;
end;

function popeye_getbyte(direccion:word):byte;
begin
case direccion of
  $0000..$8bff,$8c04..$8fff,$a000..$a7ff,$c000..$dfff:popeye_getbyte:=memoria[direccion];
  $8c00:popeye_getbyte:=scroll_x and $ff;
  $8c01:popeye_getbyte:=scroll_y;
  $8c02:popeye_getbyte:=scroll_x shr 8;
  $8c03:popeye_getbyte:=palette_bank;
  $e000:popeye_getbyte:=((prot1 shl prot_shift) or (prot0 shr (8-prot_shift))) and $ff;
  $e001:popeye_getbyte:=0;
end;
end;

procedure popeye_putbyte(direccion:word;valor:byte);
begin
if direccion<$8000 then exit;
case direccion of
  $8000..$8bff,$8c04..$8fff:memoria[direccion]:=valor;
  $8c00:scroll_x:=(scroll_x and $ff00) or valor;
  $8c01:scroll_y:=valor;
  $8c02:scroll_x:=(scroll_x and $ff) or (valor shl 8);
  $8c03:if palette_bank<>valor then begin
          palette_bank:=valor;
          cambiar_paleta((valor shr 3) and 1);
        end;
  $a000..$a7ff:begin
                  gfx[0].buffer[direccion and $3ff]:=true;
                  memoria[direccion]:=valor;
               end;
  $c000..$dfff:begin
                  fondo_write[direccion and $1fff]:=true;
                  memoria[direccion]:=valor;
               end;
  $e000:prot_shift:=valor and $07;
  $e001:begin
          prot0:=prot1;
          prot1:=valor;
        end;
end;
end;

function popeye_inbyte(puerto:word):byte;
begin
case (puerto and $ff) of
   0:popeye_inbyte:=marcade.in0;
   1:popeye_inbyte:=marcade.in1;
   2:popeye_inbyte:=marcade.in2 or (field xor $10);
   3:popeye_inbyte:=ay8910_0.read;
end;
end;

procedure popeye_outbyte(puerto:word;valor:byte);
begin
case (puerto and $ff) of
  0:ay8910_0.control(valor);
  1:ay8910_0.write(valor);
end;
end;

function popeye_portar:byte;
begin
	popeye_portar:=marcade.dswa or (marcade.dswb shl (7-dswbit)) and $80;
end;

procedure popeye_portbw(valor:byte);
begin
  main_screen.flip_main_screen:=(valor and 1)<>0;
  dswbit:=(valor and $e) shr 1;  //El bit que quiere leer
end;

procedure popeye_sound_update;
begin
  ay8910_0.update;
end;

procedure popeye_qsave(nombre:string);
var
  data:pbyte;
  size:word;
  buffer:array[0..7] of byte;
begin
open_qsnapshot_save('popeye'+nombre);
getmem(data,200);
//CPU
size:=z80_0.save_snapshot(data);
savedata_qsnapshot(data,size);
//SND
size:=ay8910_0.save_snapshot(data);
savedata_qsnapshot(data,size);
//MEM
savedata_com_qsnapshot(@memoria[$8000],$8000);
//MISC
buffer[0]:=prot0;
buffer[1]:=prot1;
buffer[2]:=prot_shift;
buffer[3]:=palette_bank;
buffer[4]:=scroll_y;
buffer[5]:=dswbit;
buffer[6]:=scroll_x and $ff;
buffer[7]:=scroll_x shr 8;
savedata_qsnapshot(@buffer[$0],8);
freemem(data);
close_qsnapshot;
end;

procedure popeye_qload(nombre:string);
var
  data:pbyte;
  buffer:array[0..7] of byte;
begin
if not(open_qsnapshot_load('popeye'+nombre)) then exit;
getmem(data,200);
//CPU
loaddata_qsnapshot(data);
z80_0.load_snapshot(data);
//SND
loaddata_qsnapshot(data);
ay8910_0.load_snapshot(data);
//MEM
loaddata_qsnapshot(@memoria[$8000]);
//MISC
loaddata_qsnapshot(@buffer[0]);
prot0:=buffer[0];
prot1:=buffer[1];
prot_shift:=buffer[2];
palette_bank:=buffer[3];
scroll_y:=buffer[4];
dswbit:=buffer[5];
scroll_x:=buffer[6] or (buffer[7] shl 8);
freemem(data);
close_qsnapshot;
fillchar(fondo_write[$0],$2000,1);
fillchar(gfx[0].buffer[0],$400,1);
end;

//Main
procedure reset_popeye;
begin
 z80_0.reset;
 ay8910_0.reset;
 reset_audio;
 marcade.in0:=0;
 marcade.in1:=0;
 marcade.in2:=0;
 palette_bank:=0;
 prot0:=0;
 prot1:=0;
 prot_shift:=0;
 scroll_y:=0;
 dswbit:=0;
 scroll_x:=0;
 field:=0;
 cambiar_paleta(0);
 fillchar(fondo_write[0],$2000,1);
end;

function iniciar_popeye:boolean;
var
  colores:tcolor;
  f,pos:word;
  ctemp1,ctemp2,ctemp3,ctemp4:byte;
  memoria_temp:array[0..$7fff] of byte;
const
  ps_x:array[0..15] of dword=(7+($2000*8),6+($2000*8),5+($2000*8),4+($2000*8),
     3+($2000*8),2+($2000*8),1+($2000*8),0+($2000*8),7,6,5,4,3,2,1,0);
  ps_y:array[0..15] of dword=(15*8, 14*8, 13*8, 12*8, 11*8, 10*8, 9*8, 8*8,
	  7*8, 6*8, 5*8, 4*8, 3*8, 2*8, 1*8, 0*8 );
  pc_x:array[0..15] of dword=(7,7, 6,6, 5,5, 4,4, 3,3, 2,2, 1,1, 0,0);
  pc_y:array[0..15] of dword=(0*8,0*8, 1*8,1*8, 2*8,2*8, 3*8,3*8, 4*8,4*8, 5*8,5*8, 6*8,6*8, 7*8,7*8);
begin
iniciar_popeye:=false;
iniciar_audio(false);
screen_init(1,512,512);
screen_mod_scroll(1,512,512,511,512,512,511);
screen_init(2,512,512,true);
screen_init(3,512,512,false,true);
iniciar_video(512,448);
//Main CPU
z80_0:=cpu_z80.create(4000000,512);
z80_0.change_ram_calls(popeye_getbyte,popeye_putbyte);
z80_0.change_io_calls(popeye_inbyte,popeye_outbyte);
z80_0.init_sound(popeye_sound_update);
//Audio chips
ay8910_0:=ay8910_chip.create(2000000,AY8910,1);
ay8910_0.change_io_calls(popeye_portar,nil,nil,popeye_portbw);
//cargar roms y decodificarlas
if not(cargar_roms(@memoria_temp[0],@popeye_rom[0],'popeye.zip',0)) then exit;
for f:=0 to $7fff do begin
  pos:=bitswap16(f,15,14,13,12,11,10,8,7,6,3,9,5,4,2,1,0);
  memoria[f]:=bitswap8(memoria_temp[pos xor $3f],3,4,2,5,1,6,0,7);
end;
//convertir chars
if not(cargar_roms(@memoria_temp[0],@popeye_char,'popeye.zip',1)) then exit;
init_gfx(0,16,16,256);
gfx[0].trans[0]:=true;
gfx_set_desc_data(1,0,8*8,0);
convert_gfx(0,0,@memoria_temp[$800],@pc_x[0],@pc_y[0],false,false);
//convertir sprites
if not(cargar_roms(@memoria_temp[0],@popeye_sprites[0],'popeye.zip',0)) then exit;
init_gfx(1,16,16,512);
gfx[1].trans[0]:=true;
for f:=0 to 1 do begin
  gfx_set_desc_data(2,2,16*8,(0+f*$1000)*8,($4000+f*$1000)*8);
  convert_gfx(1,256*f*16*16,@memoria_temp[0],@ps_x[0],@ps_y[0],false,false);
end;
//poner la paleta chars
if not(cargar_roms(@memoria_temp[0],@popeye_pal[0],'popeye.zip',0)) then exit;
for f:=0 to $23f do memoria_temp[f]:=memoria_temp[f] xor $ff;
copymemory(@popeye_mem_pal[0],@memoria_temp[0],$20);
for f:=0 to 15 do begin
		ctemp4:=f or ((f and 8) shl 1);	// address bits 3 and 4 are tied together */
		// red component */
		ctemp1:=(memoria_temp[ctemp4+$20] shr 0) and $01;
		ctemp2:=(memoria_temp[ctemp4+$20] shr 1) and $01;
		ctemp3:=(memoria_temp[ctemp4+$20] shr 2) and $01;
		colores.r:=$21*ctemp1+$47*ctemp2+$97*ctemp3;
		// green component */
		ctemp1:=(memoria_temp[ctemp4+$20] shr 3) and $01;
		ctemp2:=(memoria_temp[ctemp4+$20] shr 4) and $01;
		ctemp3:=(memoria_temp[ctemp4+$20] shr 5) and $01;
		colores.g:=$21*ctemp1+$47*ctemp2+$97*ctemp3;
		// blue component */
		ctemp1:=0;
		ctemp2:=(memoria_temp[ctemp4+$20] shr 6) and $01;
		ctemp3:=(memoria_temp[ctemp4+$20] shr 7) and $01;
		colores.b:=$21*ctemp1+$47*ctemp2+$97*ctemp3;
    set_pal_color(colores,16+(2*f)+1);
end;
//Poner la paleta sprites
for f:=0 to $FF do begin
		// red component */
		ctemp1:=(memoria_temp[$40+f] shr 0) and $01;
		ctemp2:=(memoria_temp[$40+f] shr 1) and $01;
		ctemp3:=(memoria_temp[$40+f] shr 2) and $01;
		colores.r:=$21*ctemp1+$47*ctemp2+$97*ctemp3;
		// green component */
		ctemp1:=(memoria_temp[$40+f] shr 3) and $01;
		ctemp2:=(memoria_temp[$140+f] shr 0) and $01;
		ctemp3:=(memoria_temp[$140+f] shr 1) and $01;
		colores.g:=$21*ctemp1+$47*ctemp2+$97*ctemp3;
		// blue component */
		ctemp1:=0;
		ctemp2:=(memoria_temp[$140+f] shr 2) and $01;
		ctemp3:=(memoria_temp[$140+f] shr 3) and $01;
		colores.b:=$21*ctemp1+$47*ctemp2+$97*ctemp3;
    set_pal_color(colores,48+f);
end;
//DIP
marcade.dswa:=$5f;
marcade.dswb:=$3d;
marcade.dswa_val:=@popeye_dip_a;
marcade.dswb_val:=@popeye_dip_b;
//final
reset_popeye;
iniciar_popeye:=true;
end;

procedure Cargar_popeye;
begin
llamadas_maquina.iniciar:=iniciar_popeye;
llamadas_maquina.bucle_general:=popeye_principal;
llamadas_maquina.reset:=reset_popeye;
llamadas_maquina.save_qsnap:=popeye_qsave;
llamadas_maquina.load_qsnap:=popeye_qload;
end;

end.
