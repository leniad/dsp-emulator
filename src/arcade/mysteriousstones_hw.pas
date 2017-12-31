unit mysteriousstones_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6502,main_engine,controls_engine,ay_8910,gfx_engine,rom_engine,
     pal_engine,sound_engine;

procedure cargar_ms;

implementation
const
        ms_rom:array[0..5] of tipo_roms=(
        (n:'rom6.bin';l:$2000;p:$4000;crc:$7bd9c6cd),(n:'rom5.bin';l:$2000;p:$6000;crc:$a83f04a6),
        (n:'rom4.bin';l:$2000;p:$8000;crc:$46c73714),(n:'rom3.bin';l:$2000;p:$A000;crc:$34f8b8a3),
        (n:'rom2.bin';l:$2000;p:$C000;crc:$bfd22cfc),(n:'rom1.bin';l:$2000;p:$E000;crc:$fb163e38));
        ms_char:array[0..5] of tipo_roms=(
        (n:'ms6';l:$2000;p:$0000;crc:$85c83806),(n:'ms9';l:$2000;p:$2000;crc:$b146c6ab),
        (n:'ms7';l:$2000;p:$4000;crc:$d025f84d),(n:'ms10';l:$2000;p:$6000;crc:$d85015b5),
        (n:'ms8';l:$2000;p:$8000;crc:$53765d89),(n:'ms11';l:$2000;p:$A000;crc:$919ee527));
        ms_sprite:array[0..5] of tipo_roms=(
        (n:'ms12';l:$2000;p:$0000;crc:$72d8331d),(n:'ms13';l:$2000;p:$2000;crc:$845a1f9b),
        (n:'ms14';l:$2000;p:$4000;crc:$822874b0),(n:'ms15';l:$2000;p:$6000;crc:$4594e53c),
        (n:'ms16';l:$2000;p:$8000;crc:$2f470b0f),(n:'ms17';l:$2000;p:$A000;crc:$38966d1b));
        ms_pal:tipo_roms=(n:'ic61';l:$20;p:0;crc:$e802d6cf);
        //Dip
        ms_dip_a:array [0..3] of def_dip=(
        (mask:$1;name:'Lives';number:2;dip:((dip_val:$1;dip_name:'3'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2;name:'Difficulty';number:2;dip:((dip_val:$2;dip_name:'Easy'),(dip_val:$0;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Demo Sounds';number:2;dip:((dip_val:$4;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        ms_dip_b:array [0..4] of def_dip=(
        (mask:$3;name:'Coin A';number:4;dip:((dip_val:$0;dip_name:'2C 1C'),(dip_val:$3;dip_name:'1C 1C'),(dip_val:$2;dip_name:'1C 2C'),(dip_val:$1;dip_name:'1C 3C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Coin B';number:4;dip:((dip_val:$0;dip_name:'2C 1C'),(dip_val:$c;dip_name:'1C 1C'),(dip_val:$8;dip_name:'1C 2C'),(dip_val:$4;dip_name:'1C 3C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Flip Screen';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$20;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$40;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
  scroll,soundlatch,last,char_color:byte;
  video_page:word;
  weights_rg:array[0..2] of single;
  weights_b:array[0..1] of single;
  ms_scanline:array[0..271] of word;

procedure cambiar_color(pos:byte);inline;
var
  valor,bit0,bit1,bit2:byte;
  color:tcolor;
begin
  valor:=buffer_paleta[pos];
  //red
  bit0:=(valor shr 0) and $01;
  bit1:=(valor shr 1) and $01;
  bit2:=(valor shr 2) and $01;
  color.r:=combine_3_weights(@weights_rg[0],bit0,bit1,bit2);
  // green
  bit0:=(valor shr 3) and $01;
  bit1:=(valor shr 4) and $01;
  bit2:=(valor shr 5) and $01;
  color.g:=combine_3_weights(@weights_rg[0],bit0,bit1,bit2);
  // blue
  bit0:=(valor shr 6) and $01;
  bit1:=(valor shr 7) and $01;
  color.b:=combine_2_weights(@weights_b[0],bit0,bit1);
  set_pal_color(color,pos);
end;

procedure update_video_ms;inline;
var
  f,nchar,color:word;
  x,y:word;
  atrib:byte;
begin
for f:=0 to $1ff do begin
  if gfx[2].buffer[f+video_page] then begin
    x:=f mod 32;
    y:=f div 32;
    nchar:=((memoria[$1a00+video_page+f] and $1) shl 8)+memoria[$1800+f+video_page];
    put_gfx_flip(x*16,y*16,nchar,16,1,2,(x and $10)<>0,false);
    gfx[2].buffer[f+video_page]:=false;
  end;
end;
scroll__x(1,2,scroll);
//Sprites
for f:=0 to $17 do begin
  atrib:=memoria[$780+(f*4)];
  if (atrib and 1)<>0 then begin
    x:=240-memoria[$782+(f*4)];
    y:=memoria[$783+(f*4)];
    nchar:=memoria[$781+(f*4)]+((atrib and $10) shl 4);
    color:=(atrib and $8) shl 1;
    put_gfx_sprite(nchar,color,(atrib and 2)<>0,(atrib and 4)<>0,1);
    actualiza_gfx_sprite(x and $ff,y,2,1);
  end;
end;
for f:=0 to $3ff do begin
  if gfx[0].buffer[f] then begin
    x:=f mod 32;
    y:=f div 32;
    nchar:=((memoria[$1400+f] and $07) shl 8)+memoria[$1000+f];
    put_gfx_trans(x*8,y*8,nchar,24+(char_color shl 3),3,0);
    gfx[0].buffer[f]:=false;
  end;
end;
actualiza_trozo(0,0,256,256,3,0,0,256,256,2);
actualiza_trozo_final(8,0,240,256,2);
end;

procedure eventos_ms;
begin
if event.arcade then begin
  //P1
  if arcade_input.right[0] then marcade.in0:=marcade.in0 and $fe else marcade.in0:=marcade.in0 or 1;
  if arcade_input.left[0] then marcade.in0:=marcade.in0 and $fd else marcade.in0:=marcade.in0 or 2;
  if arcade_input.up[0] then marcade.in0:=marcade.in0 and $fb else marcade.in0:=marcade.in0 or 4;
  if arcade_input.down[0] then marcade.in0:=marcade.in0 and $f7 else marcade.in0:=marcade.in0 or 8;
  if arcade_input.but0[0] then marcade.in0:=marcade.in0 and $ef else marcade.in0:=marcade.in0 or $10;
  if arcade_input.but1[0] then marcade.in0:=marcade.in0 and $df else marcade.in0:=marcade.in0 or $20;
  if arcade_input.coin[0] then begin
      marcade.in0:=(marcade.in0 and $bf);
      m6502_0.change_nmi(ASSERT_LINE);
  end else begin
      marcade.in0:=(marcade.in0 or $40);
      if arcade_input.coin[1] then begin
          marcade.in0:=(marcade.in0 and $7f);
          m6502_0.change_nmi(ASSERT_LINE);
      end else begin
          marcade.in0:=(marcade.in0 or $80);
          m6502_0.change_nmi(CLEAR_LINE);
      end;
  end;
  //P2
  if arcade_input.right[1] then marcade.in1:=marcade.in1 and $fe else marcade.in1:=marcade.in1 or 1;
  if arcade_input.left[1] then marcade.in1:=marcade.in1 and $fd else marcade.in1:=marcade.in1 or 2;
  if arcade_input.up[1] then marcade.in1:=marcade.in1 and $fb else marcade.in1:=marcade.in1 or 4;
  if arcade_input.down[1] then marcade.in1:=marcade.in1 and $f7 else marcade.in1:=marcade.in1 or 8;
  if arcade_input.but0[1] then marcade.in1:=marcade.in1 and $ef else marcade.in1:=marcade.in1 or $10;
  if arcade_input.but1[1] then marcade.in1:=marcade.in1 and $df else marcade.in1:=marcade.in1 or $20;
  if arcade_input.start[0] then marcade.in1:=marcade.in1 and $bf else marcade.in1:=marcade.in1 or $40;
  if arcade_input.start[1] then marcade.in1:=marcade.in1 and $7f else marcade.in1:=marcade.in1 or $80;
end;
end;

procedure principal_ms;
var
  f:word;
  frame:single;
begin
init_controls(false,false,false,true);
frame:=m6502_0.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to 271 do begin
    m6502_0.run(frame);
    frame:=frame+m6502_0.tframes-m6502_0.contador;
    //video
    case ms_scanline[f] of
      $8:marcade.dswb:=marcade.dswb and $7f;
      $f8:begin
            update_video_ms;
            marcade.dswb:=marcade.dswb or $80;
          end;
    end;
    if ((ms_scanline[f] and $f)=8) then m6502_0.change_irq(ASSERT_LINE);
 end;
 eventos_ms;
 video_sync;
end;
end;

function getbyte_ms(direccion:word):byte;
begin
case direccion of
  0..$1fff,$4000..$ffff:getbyte_ms:=memoria[direccion];
  $2000..$3fff:case (direccion and $7f) of
                  $0..$f:getbyte_ms:=marcade.in0;
                  $10..$1f:getbyte_ms:=marcade.in1;
                  $20..$2f:getbyte_ms:=marcade.dswa;
                  $30..$3f:getbyte_ms:=marcade.dswb;
                  $60..$7f:getbyte_ms:=buffer_paleta[direccion and $1f];
               end;
end;
end;

procedure putbyte_ms(direccion:word;valor:byte);
var
  temp:byte;
begin
if direccion>$3fff then exit;
case direccion of
  0..$fff:memoria[direccion]:=valor;
  $1000..$17ff:if memoria[direccion]<>valor then begin
                  gfx[0].buffer[direccion and $3ff]:=true;
                  memoria[direccion]:=valor;
               end;
  $1800..$1fff:if memoria[direccion]<>valor then begin
                  gfx[2].buffer[direccion and $3ff]:=true;
                  memoria[direccion]:=valor;
               end;
  $2000..$3fff:case (direccion and $7f) of
                $0..$f:begin
                      temp:=((valor and $1) shl 1)+((valor and $2) shr 1);
                      if char_color<>temp then begin
                        fillchar(gfx[0].buffer[0],$400,1);
                        char_color:=temp;
                      end;
                      video_page:=(valor and $4) shl 8;
                    end;
                $10..$1f:m6502_0.change_irq(CLEAR_LINE);
                $20..$2f:scroll:=valor;
                $30..$3f:soundlatch:=valor;
                $40..$4f:begin
                     if (((last and $20)=$20) and ((valor and $20)=0)) then begin
                        if (last and $10)<>0 then ay8910_0.Control(soundlatch)
                          else AY8910_0.write(soundlatch);
                     end;
                     if (((last and $80)=$80) and ((valor and $80)=0)) then begin
                        if (last and $40)<>0 then AY8910_1.control(soundlatch)
                          else AY8910_1.write(soundlatch);
                     end;
                     last:=valor;
                  end;
                $60..$7f:if buffer_paleta[direccion and $1f]<>valor then begin
                          buffer_paleta[direccion and $1f]:=valor;
                          cambiar_color(direccion and $1f);
                          if (direccion and $1f)>=$10 then fillchar(gfx[2].buffer[0],$400,1);
                         end;
              end;
      end;
end;

procedure ms_sound_update;
begin
  ay8910_0.update;
  ay8910_1.update;
end;

//Main
procedure reset_ms;
begin
m6502_0.reset;
ay8910_0.reset;
ay8910_1.reset;
reset_audio;
scroll:=0;
last:=0;
soundlatch:=0;
marcade.in0:=$ff;
marcade.in1:=$ff;
char_color:=0;
end;

function iniciar_ms:boolean;
var
  f:byte;
  memoria_temp:array[0..$bfff] of byte;
const
    pc_x:array[0..7] of dword=(0, 1, 2, 3, 4, 5, 6, 7);
    ps_x:array[0..15] of dword=(16*8+0, 16*8+1, 16*8+2, 16*8+3, 16*8+4, 16*8+5, 16*8+6, 16*8+7,
			0, 1, 2, 3, 4, 5, 6, 7);
    ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8);
    resistances_rg:array[0..2] of integer=(4700,3300,1500);
	  resistances_b:array[0..1] of integer=(3300,1500);
begin
iniciar_ms:=false;
iniciar_audio(false);
screen_init(1,512,256);
screen_mod_scroll(1,512,256,511,256,256,255);
screen_init(2,256,512,false,true);
screen_init(3,256,256,true);
iniciar_video(240,256);
//Main CPU
m6502_0:=cpu_m6502.create(1500000,272,TCPU_M6502);
m6502_0.change_ram_calls(getbyte_ms,putbyte_ms);
m6502_0.init_sound(ms_sound_update);
//Sound Chip
ay8910_0:=ay8910_chip.create(1500000,AY8910,0.3);
ay8910_1:=ay8910_chip.create(1500000,AY8910,0.3);
//cargar roms
if not(roms_load(@memoria,@ms_rom,'mystston.zip',sizeof(ms_rom))) then exit;
//Cargar chars
if not(roms_load(@memoria_temp,@ms_char,'mystston.zip',sizeof(ms_char))) then exit;
init_gfx(0,8,8,2048);
gfx[0].trans[0]:=true;
gfx_set_desc_data(3,0,8*8,$4000*8*2,$4000*8,0);
convert_gfx(0,0,@memoria_temp,@pc_x,@ps_y,false,true);
//sprites
init_gfx(1,16,16,512);
gfx[1].trans[0]:=true;
gfx_set_desc_data(3,0,32*8,$4000*8*2,$4000*8,0);
convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,true);
//Cargar sprites fondo
if not(roms_load(@memoria_temp,@ms_sprite,'mystston.zip',sizeof(ms_sprite))) then exit;
init_gfx(2,16,16,512);
convert_gfx(2,0,@memoria_temp,@ps_x,@ps_y,false,true);
//poner la paleta
if not(roms_load(@memoria_temp,@ms_pal,'mystston.zip',sizeof(ms_pal))) then exit;
compute_resistor_weights(0,	255, -1.0,
			3,@resistances_rg,@weights_rg,0,4700,
			2,@resistances_b,@weights_b,0,4700,
			0,nil,nil,0,0);
for f:=24 to 63 do begin
  buffer_paleta[f]:=memoria_temp[f-24];
  cambiar_color(f);
end;
//init scanlines
for f:=8 to $ff do ms_scanline[f-8]:=f; //08,09,0A,0B,...,FC,FD,FE,FF
for f:=$e8 to $ff do ms_scanline[f+$10]:=f+$100; //E8,E9,EA,EB,...,FC,FD,FE,FF
//DIP
marcade.dswa:=$fb;
marcade.dswb:=$1f;
marcade.dswa_val:=@ms_dip_a;
marcade.dswb_val:=@ms_dip_b;
//final
reset_ms;
iniciar_ms:=true;
end;

procedure cargar_ms;
begin
llamadas_maquina.iniciar:=iniciar_ms;
llamadas_maquina.bucle_general:=principal_ms;
llamadas_maquina.reset:=reset_ms;
llamadas_maquina.fps_max:=((12000000/256)/3)/272;
end;

end.
