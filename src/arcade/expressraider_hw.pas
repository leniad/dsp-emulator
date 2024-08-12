unit expressraider_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6502,m6809,main_engine,controls_engine,ym_2203,ym_3812,gfx_engine,
     rom_engine,pal_engine,sound_engine,qsnapshot;

function iniciar_expraid:boolean;

implementation
const
        expraid_rom:array[0..1] of tipo_roms=(
        (n:'cz01-2e.16b';l:$4000;p:$4000;crc:$a0ae6756),(n:'cz00-4e.15a';l:$8000;p:$8000;crc:$910f6ccc));
        expraid_char:tipo_roms=(n:'cz07.5b';l:$4000;p:$0000;crc:$686bac23);
        expraid_tiles:array[0..2] of tipo_roms=(
        (n:'cz04.8e';l:$8000;p:$0000;crc:$643a1bd3),(n:'cz05.8f';l:$8000;p:$10000;crc:$c44570bf),
        (n:'cz06.8h';l:$8000;p:$18000;crc:$b9bb448b));
        expraid_snd:tipo_roms=(n:'cz02-1.2a';l:$8000;p:$8000;crc:$552e6112);
        expraid_tiles_mem:tipo_roms=(n:'cz03.12d';l:$8000;p:$0000;crc:$6ce11971);
        expraid_sprites:array[0..5] of tipo_roms=(
        (n:'cz09.16h';l:$8000;p:$0000;crc:$1ed250d1),(n:'cz08.14h';l:$8000;p:$8000;crc:$2293fc61),
        (n:'cz13.16k';l:$8000;p:$10000;crc:$7c3bfd00),(n:'cz12.14k';l:$8000;p:$18000;crc:$ea2294c8),
        (n:'cz11.13k';l:$8000;p:$20000;crc:$b7418335),(n:'cz10.11k';l:$8000;p:$28000;crc:$2f611978));
        expraid_proms:array[0..3] of tipo_roms=(
        (n:'cy-17.5b';l:$100;p:$000;crc:$da31dfbc),(n:'cy-16.6b';l:$100;p:$100;crc:$51f25b4c),
        (n:'cy-15.7b';l:$100;p:$200;crc:$a6168d7f),(n:'cy-14.9b';l:$100;p:$300;crc:$52aad300));
        expraid_dip_a:array [0..5] of def_dip=(
        (mask:$3;name:'Coin A';number:4;dip:((dip_val:$0;dip_name:'2C 1C'),(dip_val:$3;dip_name:'1C 1C'),(dip_val:$2;dip_name:'1C 2C'),(dip_val:$1;dip_name:'1C 3C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Coin B';number:4;dip:((dip_val:$0;dip_name:'2C 1C'),(dip_val:$c;dip_name:'1C 1C'),(dip_val:$8;dip_name:'1C 2C'),(dip_val:$4;dip_name:'1C 3C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Coin Mode';number:2;dip:((dip_val:$10;dip_name:'Mode 1'),(dip_val:$0;dip_name:'Mode 2'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Flip Screen';number:2;dip:((dip_val:$20;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$40;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        expraid_dip_b:array [0..4] of def_dip=(
        (mask:$3;name:'Lives';number:4;dip:((dip_val:$1;dip_name:'1'),(dip_val:$3;dip_name:'3'),(dip_val:$5;dip_name:'2'),(dip_val:$0;dip_name:'Infinite'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Bonus Life';number:2;dip:((dip_val:$0;dip_name:'50K 80K'),(dip_val:$4;dip_name:'50K only'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$18;name:'Difficulty';number:4;dip:((dip_val:$18;dip_name:'Easy'),(dip_val:$10;dip_name:'Normal'),(dip_val:$8;dip_name:'Hard'),(dip_val:$0;dip_name:'Very Hard'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$20;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
  vb,prot_val,sound_latch,scroll_x,scroll_y,scroll_x2:byte;
  mem_tiles:array[0..$7fff] of byte;
  bg_tiles:array[0..3] of byte;
  bg_tiles_cam:array[0..3] of boolean;
  old_val,old_val2:boolean;

procedure update_video_expraid;
var
  f,i,nchar,color,atrib:word;
  x,y,pos_ini:word;
  rest_scroll:word;
begin
//Background
for i:=0 to 3 do begin
 if bg_tiles_cam[i] then begin
  pos_ini:=bg_tiles[i]*$100;
  for f:=0 to $ff do begin
    x:=(f mod 16)*16;
    y:=(f div 16)*16;
    if i>1 then y:=y+256;
    x:=x+(256*(i and 1));
    atrib:=mem_tiles[$4000+pos_ini+f];
    nchar:=mem_tiles[pos_ini+f]+((atrib and $03) shl 8);
    color:=atrib and $18;
    put_gfx_flip(x,y,nchar,color,2,2,(atrib and 4)<>0,false);
    if (atrib and $80)<>0 then put_gfx_trans_flip(x,y,nchar,color,4,2,(atrib and 4)<>0,false)
      else put_gfx_block_trans(x,y,4,16,16);
  end;
  bg_tiles_cam[i]:=false;
 end;
end;
//Para acelerar las cosas (creo)
rest_scroll:=256-scroll_y;
//Express Rider divide en dos la pantalla vertical, con dos scrolls
//diferentes, en total 512x256 y otra de 512x256
actualiza_trozo(scroll_x,scroll_y,256,rest_scroll,2,0,0,256,rest_scroll,1);
actualiza_trozo(scroll_x2,256,256,scroll_y,2,0,rest_scroll,256,scroll_y,1);
//Sprites
for f:=0 to $7f do begin
    x:=((248-memoria[$602+(f*4)]) and $ff)-8;
    y:=memoria[$600+(f*4)];
    nchar:=memoria[$603+(f*4)]+((memoria[$601+(f*4)] and $e0) shl 3);
    color:=((memoria[$601+(f*4)] and $03) + ((memoria[$601+(f*4)] and $08) shr 1)) shl 3;
    put_gfx_sprite(nchar,64+color,(memoria[$601+(f*4)] and 4)<>0,false,1);
    actualiza_gfx_sprite(x,y,1,1);
    if (memoria[$601+(f*4)] and $10)<>0 then begin
        put_gfx_sprite(nchar+1,64+color,(memoria[$601+(f*4)] and 4)<>0,false,1);
        actualiza_gfx_sprite(x,y+16,1,1);
    end;
end;
//Prioridad del fondo
actualiza_trozo(scroll_x,scroll_y,256,rest_scroll,4,0,0,256,rest_scroll,1);
actualiza_trozo(scroll_x2,256,256,scroll_y,4,0,rest_scroll,256,scroll_y,1);
//Foreground
for f:=0 to $3ff do begin
  if gfx[0].buffer[f] then begin
    x:=f mod 32;
    y:=f div 32;
    nchar:=memoria[$800+f]+((memoria[$c00+f] and $07) shl 8);
    color:=(memoria[$c00+f] and $10) shr 2;
    put_gfx_trans(x*8,y*8,nchar,128+color,6,0);
    gfx[0].buffer[f]:=false;
 end;
end;
actualiza_trozo(0,0,256,256,6,0,0,256,256,1);
actualiza_trozo_final(8,8,240,240,1);
end;

procedure eventos_expraid;
begin
if event.arcade then begin
  if arcade_input.right[0] then marcade.in0:=marcade.in0 and $fe else marcade.in0:=marcade.in0 or 1;
  if arcade_input.left[0] then marcade.in0:=marcade.in0 and $fd else marcade.in0:=marcade.in0 or 2;
  if arcade_input.up[0] then marcade.in0:=marcade.in0 and $fb else marcade.in0:=marcade.in0 or 4;
  if arcade_input.down[0] then marcade.in0:=marcade.in0 and $f7 else marcade.in0:=marcade.in0 or 8;
  if arcade_input.but0[0] then marcade.in0:=marcade.in0 and $ef else marcade.in0:=marcade.in0 or $10;
  if arcade_input.but1[0] then marcade.in0:=marcade.in0 and $df else marcade.in0:=marcade.in0 or $20;
  if (arcade_input.coin[0] and not(old_val)) then begin
      marcade.in2:=(marcade.in2 and $bf);
      m6502_0.change_nmi(ASSERT_LINE);
  end else begin
      marcade.in2:=(marcade.in2 or $40);
  end;
  if (arcade_input.coin[1] and not(old_val2)) then begin
      marcade.in2:=(marcade.in2 and $7f);
      m6502_0.change_nmi(ASSERT_LINE);
  end else begin
      marcade.in2:=(marcade.in2 or $80);
  end;
  old_val:=arcade_input.coin[0];
  old_val2:=arcade_input.coin[1];
  if arcade_input.start[0] then marcade.in0:=marcade.in0 and $bf else marcade.in0:=marcade.in0 or $40;
  if arcade_input.start[1] then marcade.in0:=marcade.in0 and $7f else marcade.in0:=marcade.in0 or $80;
end;
end;

procedure principal_expraid;
var
  frame_m,frame_s:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=m6502_0.tframes;
frame_s:=m6809_0.tframes;
while EmuStatus=EsRunning do begin
 for f:=0 to 261 do begin
   case f of
      8:vb:=0;
      248:begin
            update_video_expraid;
            vb:=$2;
          end;
   end;
   m6502_0.run(frame_m);
   frame_m:=frame_m+m6502_0.tframes-m6502_0.contador;
   //Sound
   m6809_0.run(frame_s);
   frame_s:=frame_s+m6809_0.tframes-m6809_0.contador;
 end;
 eventos_expraid;
 video_sync;
end;
end;

function getbyte_expraid(direccion:word):byte;
begin
case direccion of
   0..$fff,$4000..$ffff:getbyte_expraid:=memoria[direccion];
   $1800:getbyte_expraid:=marcade.dswa;
   $1801:getbyte_expraid:=marcade.in0;
   $1802:getbyte_expraid:=marcade.in2;
   $1803:getbyte_expraid:=marcade.dswb;
   $2800:getbyte_expraid:=prot_val;
   $2801:getbyte_expraid:=$2;
end;
end;

procedure putbyte_expraid(direccion:word;valor:byte);
begin
case direccion of
  0..$7ff:memoria[direccion]:=valor;
  $800..$fff:if memoria[direccion]<>valor then begin
                gfx[0].buffer[direccion and $3ff]:=true;
                memoria[direccion]:=valor;
             end;
  $2000:m6502_0.change_nmi(CLEAR_LINE);
  $2001:begin
           sound_latch:=valor;
           m6809_0.change_nmi(ASSERT_LINE);
        end;
  $2002:main_screen.flip_main_screen:=(valor and $1)<>0;
  $2800..$2803:if bg_tiles[direccion and $3]<>(valor and $3f) then begin
                  bg_tiles[direccion and $3]:=valor and $3f;
                  bg_tiles_cam[direccion and $3]:=true;
               end;
  $2804:scroll_y:=valor;
  $2805:scroll_x:=valor;
  $2806:scroll_x2:=valor;
  $2807:case valor of
          $20,$60:;
          $80:prot_val:=prot_val+1;
          $90:prot_val:=0;
        end;
  $4000..$ffff:; //ROM
end;
end;

function get_io_expraid:byte;
begin
  get_io_expraid:=vb;
end;

function getbyte_snd_expraid(direccion:word):byte;
begin
  case direccion of
    0..$1fff,$8000..$ffff:getbyte_snd_expraid:=mem_snd[direccion];
    $2000:getbyte_snd_expraid:=ym2203_0.status;
    $2001:getbyte_snd_expraid:=ym2203_0.Read;
    $4000:getbyte_snd_expraid:=ym3812_0.status;
    $6000:begin
            getbyte_snd_expraid:=sound_latch;
            m6809_0.change_nmi(CLEAR_LINE);
          end;
  end;
end;

procedure putbyte_snd_expraid(direccion:word;valor:byte);
begin
case direccion of
  0..$1fff:mem_snd[direccion]:=valor;
  $2000:ym2203_0.control(valor);
  $2001:ym2203_0.write(valor);
  $4000:ym3812_0.control(valor);
  $4001:ym3812_0.write(valor);
  $8000..$ffff:; //ROM
end;
end;

procedure expraid_sound_update;
begin
  ym2203_0.Update;
  ym3812_0.update;
end;

procedure snd_irq(irqstate:byte);
begin
  m6809_0.change_irq(irqstate);
end;

//Main
procedure expraid_qsave(nombre:string);
var
  data:pbyte;
  buffer:array[0..15] of byte;
  size:word;
begin
open_qsnapshot_save('expressraider'+nombre);
getmem(data,20000);
//CPU
size:=m6502_0.save_snapshot(data);
savedata_qsnapshot(data,size);
size:=m6809_0.save_snapshot(data);
savedata_qsnapshot(data,size);
//SND
size:=ym2203_0.save_snapshot(data);
savedata_qsnapshot(data,size);
size:=ym3812_0.save_snapshot(data);
savedata_qsnapshot(data,size);
//MEM
savedata_qsnapshot(@memoria[0],$4000);
savedata_qsnapshot(@mem_snd[0],$8000);
//MISC
buffer[0]:=vb;
buffer[1]:=prot_val;
buffer[2]:=sound_latch;
buffer[3]:=scroll_x;
buffer[4]:=scroll_y;
buffer[5]:=scroll_x2;
buffer[6]:=bg_tiles[0];
buffer[7]:=bg_tiles[1];
buffer[8]:=bg_tiles[2];
buffer[9]:=bg_tiles[3];
buffer[10]:=byte(bg_tiles_cam[0]);
buffer[11]:=byte(bg_tiles_cam[1]);
buffer[12]:=byte(bg_tiles_cam[2]);
buffer[13]:=byte(bg_tiles_cam[3]);
buffer[14]:=byte(old_val);
buffer[15]:=byte(old_val2);
savedata_qsnapshot(@buffer,16);
freemem(data);
close_qsnapshot;
end;

procedure expraid_qload(nombre:string);
var
  data:pbyte;
  buffer:array[0..15] of byte;
begin
if not(open_qsnapshot_load('expressraider'+nombre)) then exit;
getmem(data,20000);
//CPU
loaddata_qsnapshot(data);
m6502_0.load_snapshot(data);
loaddata_qsnapshot(data);
m6809_0.load_snapshot(data);
//SND
loaddata_qsnapshot(data);
ym2203_0.load_snapshot(data);
loaddata_qsnapshot(data);
ym3812_0.load_snapshot(data);
//MEM
loaddata_qsnapshot(@memoria);
loaddata_qsnapshot(@mem_snd);
//MISC
vb:=buffer[0];
prot_val:=buffer[1];
sound_latch:=buffer[2];
scroll_x:=buffer[3];
scroll_y:=buffer[4];
scroll_x2:=buffer[5];
bg_tiles[0]:=buffer[6];
bg_tiles[1]:=buffer[7];
bg_tiles[2]:=buffer[8];
bg_tiles[3]:=buffer[9];
bg_tiles_cam[0]:=buffer[10]<>0;
bg_tiles_cam[1]:=buffer[11]<>0;
bg_tiles_cam[2]:=buffer[12]<>0;
bg_tiles_cam[3]:=buffer[13]<>0;
old_val:=buffer[14]<>0;
old_val2:=buffer[15]<>0;
freemem(data);
close_qsnapshot;
//END
fillchar(gfx[0].buffer,$400,1);
end;

procedure reset_expraid;
begin
m6502_0.reset;
m6809_0.reset;
ym2203_0.Reset;
ym3812_0.reset;
marcade.in0:=$ff;
marcade.in1:=$ff;
marcade.in2:=$ff;
vb:=0;
prot_val:=0;
sound_latch:=0;
old_val:=false;
old_val2:=false;
scroll_x:=0;
scroll_y:=0;
scroll_x2:=0;
end;

function iniciar_expraid:boolean;
const
    pc_x:array[0..7] of dword=(0+($2000*8),1+($2000*8), 2+($2000*8), 3+($2000*8), 0, 1, 2, 3);
    ps_x:array[0..15] of dword=(128+0, 128+1, 128+2, 128+3, 128+4, 128+5, 128+6, 128+7,
			0, 1, 2, 3, 4, 5, 6, 7);
    ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8);
    pt_x:array[0..15] of dword=(0, 1, 2, 3, 1024*32*2,1024*32*2+1,1024*32*2+2,1024*32*2+3,
		128+0,128+1,128+2,128+3,128+1024*32*2,128+1024*32*2+1,128+1024*32*2+2,128+1024*32*2+3);
var
  colores:tpaleta;
  f,offs:byte;
  memoria_temp:array[0..$2ffff] of byte;
begin
llamadas_maquina.bucle_general:=principal_expraid;
llamadas_maquina.reset:=reset_expraid;
llamadas_maquina.fps_max:=59.637405;
llamadas_maquina.save_qsnap:=expraid_qsave;
llamadas_maquina.load_qsnap:=expraid_qload;
iniciar_expraid:=false;
iniciar_audio(false);
screen_init(1,512,256,false,true);
screen_init(2,512,512);
screen_init(3,512,512,true);
screen_init(4,512,512,true);
screen_init(6,256,256,true);
iniciar_video(240,240);
//Main CPU
m6502_0:=cpu_m6502.create(1500000,262,TCPU_DECO16);
m6502_0.change_ram_calls(getbyte_expraid,putbyte_expraid);
m6502_0.change_io_calls(nil,get_io_expraid);
//Sound CPU
m6809_0:=cpu_m6809.Create(1500000,262,TCPU_M6809);
m6809_0.change_ram_calls(getbyte_snd_expraid,putbyte_snd_expraid);
m6809_0.init_sound(expraid_sound_update);
//Sound Chip
ym2203_0:=ym2203_chip.create(1500000,0.3,0.3);
ym3812_0:=ym3812_chip.create(YM3526_FM,3000000,0.6);
ym3812_0.change_irq_calls(snd_irq);
//cargar roms
if not(roms_load(@memoria,expraid_rom)) then exit;
//cargar roms audio
if not(roms_load(@mem_snd,expraid_snd)) then exit;
//Cargar chars
if not(roms_load(@memoria_temp,expraid_char)) then exit;
init_gfx(0,8,8,1024);
gfx[0].trans[0]:=true;
gfx_set_desc_data(2,0,8*8,0,4);
convert_gfx(0,0,@memoria_temp,@pc_x,@ps_y,false,false);
//sprites
if not(roms_load(@memoria_temp,expraid_sprites)) then exit;
init_gfx(1,16,16,2048);
gfx[1].trans[0]:=true;
gfx_set_desc_data(3,0,32*8,2*2048*32*8,2048*32*8,0);
convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,false);
//Cargar tiles
if not(roms_load(@memoria_temp,expraid_tiles)) then exit;
//Mover los datos de los tiles para poder usar las rutinas de siempre...
offs:=$10-$1;
for f:=$7 downto 0 do begin
  copymemory(@memoria_temp[offs*$1000],@memoria_temp[f*$1000],$1000);
	offs:=offs-$1;
  copymemory(@memoria_temp[offs*$1000],@memoria_temp[f*$1000],$1000);
  offs:=offs-$1;
end;
init_gfx(2,16,16,1024);
gfx[2].trans[0]:=true;
for f:=0 to 3 do begin
  gfx_set_desc_data(3,8,32*8,4+(f*$4000)*8,($10000+f*$4000)*8+0,($10000+f*$4000)*8+4);
  convert_gfx(2,f*$100*16*16,@memoria_temp,@pt_x,@ps_y,false,false);
  gfx_set_desc_data(3,8,32*8,0+(f*$4000)*8,($11000+f*$4000)*8+0,($11000+f*$4000)*8+4);
  convert_gfx(2,(f*$100*16*16)+($80*16*16),@memoria_temp,@pt_x,@ps_y,false,false);
end;
if not(roms_load(@mem_tiles,expraid_tiles_mem)) then exit;
//Paleta
if not(roms_load(@memoria_temp,expraid_proms)) then exit;
for f:=0 to $ff do begin
  colores[f].r:=((memoria_temp[f] and $f) shl 4) or (memoria_temp[f] and $f);
  colores[f].g:=((memoria_temp[f+$100] and $f) shl 4) or (memoria_temp[f+$100] and $f);
  colores[f].b:=((memoria_temp[f+$200] and $f) shl 4) or (memoria_temp[f+$200] and $f);
end;
set_pal(colores,256);
//DIP
marcade.dswa:=$bf;
marcade.dswa_val:=@expraid_dip_a;
marcade.dswb:=$ff;
marcade.dswb_val:=@expraid_dip_b;
//final
reset_expraid;
iniciar_expraid:=true;
end;

end.
