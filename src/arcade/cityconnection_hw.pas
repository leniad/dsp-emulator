unit cityconnection_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6809,ay_8910,ym_2203,main_engine,controls_engine,gfx_engine,rom_engine,
     pal_engine,sound_engine,qsnapshot;

function iniciar_citycon:boolean;

implementation
const
        citycon_rom:array[0..1] of tipo_roms=(
        (n:'c10';l:$4000;p:$4000;crc:$ae88b53c),(n:'c11';l:$8000;p:$8000;crc:$139eb1aa));
        citycon_sonido:tipo_roms=(n:'c1';l:$8000;p:$8000;crc:$1fad7589);
        citycon_char:tipo_roms=(n:'c4';l:$2000;p:0;crc:$a6b32fc6);
        citycon_sprites:array[0..1] of tipo_roms=(
        (n:'c12';l:$2000;p:0;crc:$08eaaccd),(n:'c13';l:$2000;p:$2000;crc:$1819aafb));
        citycon_tiles:array[0..3] of tipo_roms=(
        (n:'c9';l:$8000;p:0;crc:$8aeb47e6),(n:'c8';l:$4000;p:$8000;crc:$0d7a1eeb),
        (n:'c6';l:$8000;p:$c000;crc:$2246fe9d),(n:'c7';l:$4000;p:$14000;crc:$e8b97de9));
        citycon_fondo:array[0..2] of tipo_roms=(
        (n:'c2';l:$8000;p:0;crc:$f2da4f23),(n:'c3';l:$4000;p:$8000;crc:$7ef3ac1b),
        (n:'c5';l:$2000;p:$c000;crc:$c03d8b1b));
        //Dip
        citycon_dip_a:array [0..3] of def_dip=(
        (mask:$3;name:'Lives';number:4;dip:((dip_val:$0;dip_name:'3'),(dip_val:$1;dip_name:'4'),(dip_val:$2;dip_name:'5'),(dip_val:$3;dip_name:'Infinite'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Demo Sounds';number:2;dip:((dip_val:$20;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$40;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        citycon_dip_b:array [0..2] of def_dip=(
        (mask:$7;name:'Coinage';number:8;dip:((dip_val:$7;dip_name:'5C 1C'),(dip_val:$6;dip_name:'4C 1C'),(dip_val:$5;dip_name:'3C 1C'),(dip_val:$4;dip_name:'2C 1C'),(dip_val:$0;dip_name:'1C 1C'),(dip_val:$1;dip_name:'1C 2C'),(dip_val:$2;dip_name:'1C 3C'),(dip_val:$3;dip_name:'1C 4C'),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Difficulty';number:2;dip:((dip_val:$0;dip_name:'Easy'),(dip_val:$8;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 fondo,soundlatch,soundlatch2:byte;
 scroll_x:word;
 lines_color_look:array[0..$ff] of byte;
 memoria_fondo:array[0..$dfff] of byte;
 cambia_fondo:boolean;

procedure cambiar_fondo;inline;
var
  f,x,y,nchar,color:word;
begin
for f:=$fff downto 0 do begin
    y:=f shr 5;
    x:=((f and $1f)+(y and $60)) shl 3;
    y:=(y and $1f) shl 3;
    nchar:=memoria_fondo[$1000*fondo+f]+(fondo shl 8);
    color:=memoria_fondo[$c000+nchar];
    put_gfx(x,y,nchar,(color shl 4)+256,2,1);
end;
cambia_fondo:=false;
end;

procedure update_video_citycon;inline;
var
  f,x,y,color,nchar:word;
  y2,x2,atrib:byte;
  temp:pword;
  pos:pbyte;
begin
if cambia_fondo then cambiar_fondo;
scroll__x(2,3,scroll_x);
for f:=$fff downto 0 do begin
 if gfx[0].buffer[f] then begin
    y:=f shr 5;
    x:=(f and $1f)+(y and $60);
    y:=y and $1f;
    nchar:=memoria[$1000+f];
    pos:=gfx[0].datos;
    inc(pos,nchar shl 6);
    for y2:=0 to 7 do begin
      temp:=punbuf;
      color:=(lines_color_look[y2+(y shl 3)] shl 2)+512;
      for x2:=0 to 7 do begin
        if not(gfx[0].trans[pos^]) then temp^:=paleta[pos^+color]
          else temp^:=paleta[max_colores];
        inc(temp);
        inc(pos);
      end;
      putpixel(x shl 3,(y shl 3)+y2,8,punbuf,1);
    end;
 gfx[0].buffer[f]:=false;
 end;
end;
actualiza_trozo(0,0,256,48,1,0,0,256,48,3);
scroll__x_part2(1,3,208,@scroll_x,0,0,48);
for f:=$3f downto 0 do begin
    x:=memoria[$2803+(f*4)];
    y:=239-memoria[$2800+(f*4)];
    nchar:=memoria[$2801+(f*4)];
    atrib:=memoria[$2802+(f*4)];
    color:=(atrib and $f) shl 4;
    put_gfx_sprite(nchar,color,(atrib and $10)=0,false,2);
    actualiza_gfx_sprite(x,y,3,2);
end;
actualiza_trozo_final(8,16,240,224,3);
end;

procedure eventos_citycon;inline;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  //P2
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  //SYS
  if arcade_input.coin[0] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
end;
end;

procedure citycon_principal;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=m6809_0.tframes;
frame_s:=m6809_1.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
    //Main CPU
    m6809_0.run(frame_m);
    frame_m:=frame_m+m6809_0.tframes-m6809_0.contador;
    //Sound CPU
    m6809_1.run(frame_s);
    frame_s:=frame_s+m6809_1.tframes-m6809_1.contador;
    if f=239 then begin
      m6809_0.change_irq(ASSERT_LINE);
      update_video_citycon;
    end;
  end;
  eventos_citycon;
  video_sync;
end;
end;

function citycon_getbyte(direccion:word):byte;
begin
  case direccion of
        0..$1fff,$2800..$28ff,$4000..$ffff:citycon_getbyte:=memoria[direccion];
        $2000..$20ff:citycon_getbyte:=lines_color_look[direccion and $ff];
        $3000:if main_screen.flip_main_screen then citycon_getbyte:=marcade.in2
                else citycon_getbyte:=marcade.in0;
        $3001:citycon_getbyte:=marcade.dswa+marcade.in1;
        $3002:citycon_getbyte:=marcade.dswb;
        $3007:m6809_0.change_irq(CLEAR_LINE);
        $3800..$3cff:citycon_getbyte:=buffer_paleta[direccion and $7ff];
  end;
end;

procedure cambiar_color(dir:word);inline;
var
  tmp_color:byte;
  color:tcolor;
  pos:word;
begin
  tmp_color:=buffer_paleta[dir];
  color.r:=pal4bit(tmp_color shr 4);
  color.g:=pal4bit(tmp_color);
  tmp_color:=buffer_paleta[dir+1];
  color.b:=pal4bit(tmp_color shr 4);
  pos:=dir shr 1;
  set_pal_color(color,pos);
  case pos of
    256..511:cambia_fondo:=true;
    512..639:fillchar(gfx[0].buffer[0],$1000,1);
  end;
end;

procedure citycon_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$fff,$2800..$28ff:memoria[direccion]:=valor;
  $1000..$1fff:if memoria[direccion]<>valor then begin
                  gfx[0].buffer[direccion and $fff]:=true;
                  memoria[direccion]:=valor;
               end;
  $2000..$20ff:lines_color_look[direccion and $ff]:=valor;
  $3000:begin
          if fondo<>(valor shr 4) then begin
            fondo:=valor shr 4;
            cambia_fondo:=true;
          end;
          main_screen.flip_main_screen:=(valor and $1)<>0;
        end;
  $3001:soundlatch:=valor;
  $3002:soundlatch2:=valor;
  $3004:scroll_x:=(scroll_x and $ff) or ((valor and $3) shl 8);
  $3005:scroll_x:=(scroll_x and $300) or valor;
  $3800..$3cff:if buffer_paleta[direccion and $7ff]<>valor then begin
                  buffer_paleta[direccion and $7ff]:=valor;
                  cambiar_color(direccion and $7fe);
               end;
  $4000..$ffff:;
end;
end;

function scitycon_getbyte(direccion:word):byte;
begin
case direccion of
  0..$fff,$8000..$ffff:scitycon_getbyte:=mem_snd[direccion];
  $4000:scitycon_getbyte:=ay8910_0.Read;
  $6000:scitycon_getbyte:=ym2203_0.status;
  $6001:scitycon_getbyte:=ym2203_0.Read;
end;
end;

procedure scitycon_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$fff:mem_snd[direccion]:=valor;
  $4000:ay8910_0.Control(valor);
  $4001:ay8910_0.Write(valor);
  $6000:ym2203_0.Control(valor);
  $6001:ym2203_0.Write(valor);
  $8000..$ffff:; //ROM
end;
end;

function citycon_porta:byte;
begin
  citycon_porta:=soundlatch;
end;

function citycon_portb:byte;
begin
  citycon_portb:=soundlatch2;
end;

procedure citycon_sound_update;
begin
  ay8910_0.update;
  ym2203_0.Update;
end;

procedure citycon_qsave(nombre:string);
var
  data:pbyte;
  buffer:array[0..5] of byte;
  size:word;
begin
open_qsnapshot_save('cityconn'+nombre);
getmem(data,20000);
//CPU
size:=m6809_0.save_snapshot(data);
savedata_qsnapshot(data,size);
size:=m6809_1.save_snapshot(data);
savedata_qsnapshot(data,size);
//SND
size:=ym2203_0.save_snapshot(data);
savedata_com_qsnapshot(data,size);
size:=AY8910_0.save_snapshot(data);
savedata_qsnapshot(data,size);
//MEM
savedata_com_qsnapshot(@memoria,$4000);
savedata_com_qsnapshot(@mem_snd,$8000);
//MISC
buffer[0]:=fondo;
buffer[1]:=soundlatch;
buffer[2]:=soundlatch2;
buffer[3]:=scroll_x and $ff;
buffer[4]:=scroll_x shr 8;
buffer[5]:=byte(cambia_fondo);
savedata_qsnapshot(@buffer[0],6);
savedata_com_qsnapshot(@lines_color_look,$100);
savedata_com_qsnapshot(@buffer_paleta,$500*2);
freemem(data);
close_qsnapshot;
end;

procedure citycon_qload(nombre:string);
var
  data:pbyte;
  buffer:array[0..5] of byte;
  f:word;
begin
if not(open_qsnapshot_load('cityconn'+nombre)) then exit;
getmem(data,20000);
//CPU
loaddata_qsnapshot(data);
m6809_0.load_snapshot(data);
loaddata_qsnapshot(data);
m6809_1.load_snapshot(data);
//SND
loaddata_qsnapshot(data);
ym2203_0.load_snapshot(data);
loaddata_qsnapshot(data);
AY8910_0.load_snapshot(data);
//MEM
loaddata_qsnapshot(@memoria);
loaddata_qsnapshot(@mem_snd);
//MISC
loaddata_qsnapshot(@buffer);
fondo:=buffer[0];
soundlatch:=buffer[1];
soundlatch2:=buffer[2];
scroll_x:=buffer[3] or (buffer[4] shl 8);
cambia_fondo:=buffer[5]<>0;
loaddata_qsnapshot(@lines_color_look);
loaddata_qsnapshot(@buffer_paleta);
freemem(data);
close_qsnapshot;
//END
for f:=0 to 639 do cambiar_color(f*2);
end;

//Main
procedure reset_citycon;
begin
 m6809_0.reset;
 m6809_1.reset;
 YM2203_0.Reset;
 ay8910_0.reset;
 reset_audio;
 fillchar(lines_color_look[0],$100,0);
 marcade.in0:=$ff;
 marcade.in1:=$80;
 marcade.in2:=$ff;
 fondo:=0;
 soundlatch:=0;
 soundlatch2:=0;
 scroll_x:=0;
 cambia_fondo:=false;
end;

function iniciar_citycon:boolean;
var
  f:word;
  memoria_temp:array[0..$17fff] of byte;
const
  pc_x:array[0..7] of dword=(0, 1, 2, 3, 256*8*8+0, 256*8*8+1, 256*8*8+2, 256*8*8+3 );
  ps_x:array[0..7] of dword=(0, 1, 2, 3, 128*16*8+0, 128*16*8+1, 128*16*8+2, 128*16*8+3);
  ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
            8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8);
begin
llamadas_maquina.bucle_general:=citycon_principal;
llamadas_maquina.reset:=reset_citycon;
llamadas_maquina.save_qsnap:=citycon_qsave;
llamadas_maquina.load_qsnap:=citycon_qload;
iniciar_citycon:=false;
iniciar_audio(false);
screen_init(1,1024,256,true);
screen_mod_scroll(1,1024,256,1023,256,256,255);
screen_init(2,1024,256);
screen_mod_scroll(2,1024,256,1023,256,256,255);
screen_init(3,256,256,false,true);
iniciar_video(240,224);
//Main CPU
m6809_0:=cpu_m6809.Create(8000000,$100,TCPU_MC6809);
m6809_0.change_ram_calls(citycon_getbyte,citycon_putbyte);
//Sound CPU
m6809_1:=cpu_m6809.Create(8000000 div 12,$100,TCPU_MC6809E); //???
m6809_1.change_ram_calls(scitycon_getbyte,scitycon_putbyte);
m6809_1.init_sound(citycon_sound_update);
//Sound Chip
ym2203_0:=ym2203_chip.create(20000000 div 16,0.2,0.4);
ym2203_0.change_io_calls(citycon_porta,citycon_portb,nil,nil);
ay8910_0:=ay8910_chip.create(20000000 div 16,AY8910,0.40);
//cargar roms
if not(roms_load(@memoria,citycon_rom)) then exit;
//Cargar Sound
if not(roms_load(@mem_snd,citycon_sonido)) then exit;
//convertir chars
if not(roms_load(@memoria_temp,citycon_char)) then exit;
init_gfx(0,8,8,256);
gfx[0].trans[0]:=true;
gfx_set_desc_data(2,0,8*8,4,0);
convert_gfx(0,0,@memoria_temp,@pc_x,@ps_y,false,false);
//tiles
if not(roms_load(@memoria_temp,citycon_tiles)) then exit;
init_gfx(1,8,8,3072);
for f:=0 to $b do begin
  gfx_set_desc_data(4,12,8*8,4+($1000*f*8),0+($1000*f*8),($c000+($1000*f))*8+4,($c000+($1000*f))*8+0);
  convert_gfx(1,$100*8*8*f,@memoria_temp,@pc_x,@ps_y,false,false);
end;
if not(roms_load(@memoria_fondo,citycon_fondo)) then exit;
//sprites
if not(roms_load(@memoria_temp,citycon_sprites)) then exit;
init_gfx(2,8,16,256);
gfx[2].trans[0]:=true;
for f:=0 to 1 do begin
  gfx_set_desc_data(4,2,16*8,($1000*f*8)+4,($1000*f*8)+0,($2000+$1000*f)*8+4,($2000+$1000*f)*8+0);
  convert_gfx(2,$80*16*8*f,@memoria_temp,@ps_x,@ps_y,false,false);
end;
//DIP
marcade.dswa:=$0;
marcade.dswb:=$80;
marcade.dswa_val:=@citycon_dip_a;
marcade.dswb_val:=@citycon_dip_b;
//final
reset_citycon;
iniciar_citycon:=true;
end;

end.
