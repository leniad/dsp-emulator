unit centipede_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6502,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     sound_engine,file_engine,pokey;

procedure cargar_centipede;

implementation

const
        centipede_rom:array[0..3] of tipo_roms=(
        (n:'136001-407.d1';l:$800;p:$2000;crc:$c4d995eb),(n:'136001-408.e1';l:$800;p:$2800;crc:$bcdebe1b),
        (n:'136001-409.fh1';l:$800;p:$3000;crc:$66d7b04a),(n:'136001-410.j1';l:$800;p:$3800;crc:$33ce4640));
        centipede_chars:array[0..1] of tipo_roms=(
        (n:'136001-211.f7';l:$800;p:0;crc:$880acfb9),(n:'136001-212.hj7';l:$800;p:$800;crc:$b1397029));
        //DIP
        centipede_dip_a:array [0..5] of def_dip=(
        (mask:$3;name:'Lenguage';number:4;dip:((dip_val:$0;dip_name:'English'),(dip_val:$1;dip_name:'German'),(dip_val:$2;dip_name:'French'),(dip_val:$3;dip_name:'Spanish'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Lives';number:4;dip:((dip_val:$0;dip_name:'2'),(dip_val:$4;dip_name:'3'),(dip_val:$8;dip_name:'4'),(dip_val:$c;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Bonis Life';number:4;dip:((dip_val:$0;dip_name:'10000'),(dip_val:$10;dip_name:'12000'),(dip_val:$20;dip_name:'15000'),(dip_val:$30;dip_name:'20000'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Difficulty';number:2;dip:((dip_val:$40;dip_name:'Easy'),(dip_val:$0;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Credit Minimum';number:2;dip:((dip_val:$0;dip_name:'1'),(dip_val:$80;dip_name:'2'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        centipede_dip_b:array [0..3] of def_dip=(
        (mask:$3;name:'Coinage';number:4;dip:((dip_val:$3;dip_name:'2C 1C'),(dip_val:$2;dip_name:'1C 1C'),(dip_val:$1;dip_name:'1C 2C'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$1c;name:'Game Time';number:4;dip:((dip_val:$0;dip_name:'Untimed'),(dip_val:$4;dip_name:'1 Minute'),(dip_val:$8;dip_name:'2 Minutes'),(dip_val:$c;dip_name:'3 Minutes'),(dip_val:$10;dip_name:'4 Minutes'),(dip_val:$14;dip_name:'5 Minutes'),(dip_val:$18;dip_name:'6 Minutes'),(dip_val:$1c;dip_name:'7 Minutes'),(),(),(),(),(),(),(),())),
        (mask:$e0;name:'Bonus Coin';number:6;dip:((dip_val:$0;dip_name:'None'),(dip_val:$20;dip_name:'3C 2C'),(dip_val:$40;dip_name:'5C 4C'),(dip_val:$60;dip_name:'6C 4C'),(dip_val:$80;dip_name:'6C 5C'),(dip_val:$a0;dip_name:'4C 3C'),(),(),(),(),(),(),(),(),(),())),());
        centipede_dip_c:array [0..1] of def_dip=(
        (mask:$10;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$10;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 nvram,penmask:array[0..$3f] of byte;

procedure update_video_centipede;
var
  f,color:word;
  x,y,atrib,nchar:byte;
begin
for f:=0 to $3ff do begin
  if gfx[0].buffer[f] then begin
    x:=f div 32;
    y:=31-(f mod 32);
    atrib:=memoria[$400+f];
    nchar:=(atrib and $3f)+$40;
    put_gfx_flip(x*8,y*8,nchar,0,1,0,(atrib and $40)<>0,(atrib and $80)<>0);
    gfx[0].buffer[f]:=false;
  end;
end;
actualiza_trozo(0,0,256,256,1,0,0,256,256,2);
for f:=0 to $f do begin
  atrib:=memoria[$7c0+f];
  nchar:=((atrib and $3e) shr 1) or ((atrib and $01) shl 6);// or (m_gfx_bank << 7);
  color:=memoria[$7f0+f] shl 2;
	x:=240-memoria[$7d0+f];
  y:=255-memoria[$7e0+f];
  if y>7 then begin
    put_gfx_sprite_mask(nchar,color+4,(atrib and $80)<>0,(atrib and $40)<>0,1,0,penmask[color and $3f]);
    actualiza_gfx_sprite(x,y-7,2,1);
  end;
end;
actualiza_trozo_final(0,0,240,256,2);
end;

procedure eventos_centipede;inline;
begin
if event.arcade then begin
  //system
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.coin[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.coin[1] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  //P1+P2
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.up[0] then marcade.in2:=(marcade.in2 and $fef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.down[0] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.left[0] then marcade.in2:=(marcade.in2 and $bf) else marcade.in2:=(marcade.in2 or $40);
  if arcade_input.right[0] then marcade.in2:=(marcade.in2 and $7f) else marcade.in2:=(marcade.in2 or $80);
end;
end;

procedure centipede_principal;
var
  frame_m:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=m6502_0.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to $ff do begin
    //main
    m6502_0.run(frame_m);
    frame_m:=frame_m+m6502_0.tframes-m6502_0.contador;
    case f of
    0:marcade.in0:=marcade.in0 and $bf;
    31,95,159,224:m6502_0.change_irq(CLEAR_LINE);
    47,111,175:m6502_0.change_irq(ASSERT_LINE);
    239:begin
          update_video_centipede;
          m6502_0.change_irq(ASSERT_LINE);
          marcade.in0:=marcade.in0 or $40;
        end;
    end;
 end;
 eventos_centipede;
 video_sync;
end;
end;

function centipede_getbyte(direccion:word):byte;
begin
direccion:=direccion and $3fff;
case direccion of
    0..$7ff,$2000..$3fff:centipede_getbyte:=memoria[direccion];
    $800:centipede_getbyte:=marcade.dswa;
    $801:centipede_getbyte:=marcade.dswb;
    $c00:centipede_getbyte:=marcade.in0+marcade.dswb; //trackball 1
    $c01:centipede_getbyte:=marcade.in1;
    $c02:centipede_getbyte:=0; //trackball 2
    $c03:centipede_getbyte:=marcade.in2;
    $1000..$100f:centipede_getbyte:=pokey_0.read(direccion and $f);
    $1700..$173f:centipede_getbyte:=nvram[direccion and $3f];
end;
end;

procedure cambiar_color(pos,data:word);inline;
var
  color:tcolor;
  f:byte;
begin
	// bit 2 of the output palette RAM is always pulled high, so we ignore
	// any palette changes unless the write is to a palette RAM address
	// that is actually used
	if (pos and 4)<>0 then begin
		color.r:=$ff*((not(data) shr 0) and 1);
		color.g:=$ff*((not(data) shr 1) and 1);
		color.b:=$ff*((not(data) shr 2) and 1);
		if (not(data) and $08)<>0 then begin // alternate = 1
			// when blue component is not 0, decrease it. When blue component is 0,
			// decrease green component.
			if (color.b)<>0 then color.b:=$c0
			  else if (color.g)<>0 then color.g:=$c0;
		end;
		// character colors, set directly
		if ((pos and $08)=0) then begin
      set_pal_color(color,pos and $3);
		// sprite colors - set all the applicable ones */
		end else begin
			pos:=pos and $3;
			for f:=0 to $3f do begin
				if (pos=(((f*4) shr 2) and $03)) then set_pal_color(color,(f*4)+4+1);
				if (pos=(((f*4) shr 4) and $03)) then set_pal_color(color,(f*4)+4+2);
				if (pos=(((f*4) shr 6) and $03)) then set_pal_color(color,(f*4)+4+3);
			end;
		end;
	end;
end;

procedure centipede_putbyte(direccion:word;valor:byte);
begin
direccion:=direccion and $3fff;
case direccion of
    0..$3ff:memoria[direccion]:=valor;
    $400..$7ff:if memoria[direccion]<>valor then begin  //video+sprites
                  memoria[direccion]:=valor;
                  gfx[0].buffer[direccion and $3ff]:=true;
               end;
    $1000..$100f:pokey_0.write(direccion and $f,valor);
    $1400..$140f:cambiar_color(direccion and $f,valor);
    $1600..$163f:nvram[direccion and $3f]:=valor;
    $1680:; //nvram clock
    $1800:m6502_0.change_irq(CLEAR_LINE);
    $1c07:main_screen.flip_main_screen:=(valor and $80)<>0;
    $2000:; //watchdog
    $2001..$3fff:; //ROM
end;
end;

procedure centipede_sound_update;
begin
pokey_0.update;
end;

//Main
procedure reset_centipede;
begin
 m6502_0.reset;
 pokey_0.reset;
 reset_audio;
 marcade.in0:=$20;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
end;

function iniciar_centipede:boolean;
var
  memoria_temp:array[0..$fff] of byte;
  longitud:integer;
  f,mask:byte;
const
  pc_x:array[0..7] of dword=(0, 1, 2, 3, 4, 5, 6, 7);
  ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8);
begin
iniciar_centipede:=false;
iniciar_audio(false);
//Pantallas
screen_init(1,256,256);
screen_init(2,256,256,true,true);
iniciar_video(240,256);
//Main CPU
m6502_0:=cpu_m6502.create(12096000 div 8,256,TCPU_M6502);
m6502_0.change_ram_calls(centipede_getbyte,centipede_putbyte);
m6502_0.init_sound(centipede_sound_update);
//Sound Chips
pokey_0:=pokey_chip.create(0,12096000 div 8);
//cargar roms
if not(roms_load(@memoria,centipede_rom)) then exit;
//convertir chars y sprites
if not(roms_load(@memoria_temp,centipede_chars)) then exit;
init_gfx(0,8,8,$100);
gfx_set_desc_data(2,0,8*8,$100*8*8,0);
convert_gfx(0,0,@memoria_temp,@pc_x,@ps_y,false,true);
init_gfx(1,8,16,$80);
gfx[1].trans[0]:=true;
gfx_set_desc_data(2,0,16*8,$80*16*8,0);
convert_gfx(1,0,@memoria_temp,@pc_x,@ps_y,false,true);
gfx[1].x:=16;
gfx[1].y:=8;
//DIP
marcade.dswa:=$54;
marcade.dswa_val:=@centipede_dip_a;
marcade.dswb:=$2;
marcade.dswb_val:=@centipede_dip_b;
marcade.dswc:=$0;
marcade.dswc_val:=@centipede_dip_c;
//NVRAM
if read_file_size(Directory.Arcade_nvram+'centiped.nv',longitud) then read_file(Directory.Arcade_nvram+'centiped.nv',@nvram[0],longitud);
//final
for f:=0 to 63 do begin
		mask:=1;
		if (((f shr 0) and 3)=0) then mask:=mask or 2;
		if (((f shr 2) and 3)=0) then mask:=mask or 4;
		if (((f shr 4) and 3)=0) then mask:=mask or 8;
		penmask[f]:=mask;
end;
reset_centipede;
iniciar_centipede:=true;
end;

procedure cerrar_centipede;
begin
write_file(Directory.Arcade_nvram+'centiped.nv',@nvram,$40);
end;

procedure Cargar_centipede;
begin
llamadas_maquina.iniciar:=iniciar_centipede;
llamadas_maquina.bucle_general:=centipede_principal;
llamadas_maquina.close:=cerrar_centipede;
llamadas_maquina.reset:=reset_centipede;
end;

end.
