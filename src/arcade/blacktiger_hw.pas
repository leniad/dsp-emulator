unit blacktiger_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,mcs51,main_engine,controls_engine,ym_2203,gfx_engine,timer_engine,
     rom_engine,file_engine,pal_engine,sound_engine,qsnapshot;

// {$define speed_debug}

procedure cargar_blktiger;

implementation
{$ifdef speed_debug}uses principal,sysutils;{$endif}
const
        blktiger_rom:array[0..4] of tipo_roms=(
        (n:'bdu-01a.5e';l:$8000;p:0;crc:$a8f98f22),(n:'bdu-02a.6e';l:$10000;p:$8000;crc:$7bef96e8),
        (n:'bdu-03a.8e';l:$10000;p:$18000;crc:$4089e157),(n:'bd-04.9e';l:$10000;p:$28000;crc:$ed6af6ec),
        (n:'bd-05.10e';l:$10000;p:$38000;crc:$ae59b72e));
        blktiger_char:tipo_roms=(n:'bd-15.2n';l:$8000;p:0;crc:$70175d78);
        blktiger_sprites:array[0..3] of tipo_roms=(
        (n:'bd-08.5a';l:$10000;p:0;crc:$e2f17438),(n:'bd-07.4a';l:$10000;p:$10000;crc:$5fccbd27),
        (n:'bd-10.9a';l:$10000;p:$20000;crc:$fc33ccc6),(n:'bd-09.8a';l:$10000;p:$30000;crc:$f449de01));
        blktiger_tiles:array[0..3] of tipo_roms=(
        (n:'bd-12.5b';l:$10000;p:0;crc:$c4524993),(n:'bd-11.4b';l:$10000;p:$10000;crc:$7932c86f),
        (n:'bd-14.9b';l:$10000;p:$20000;crc:$dc49593a),(n:'bd-13.8b';l:$10000;p:$30000;crc:$7ed7a122));
        blktiger_snd:tipo_roms=(n:'bd-06.1l';l:$8000;p:0;crc:$2cf54274);
        blktiger_mcu:tipo_roms=(n:'bd.6k';l:$1000;p:0;crc:$ac7d14f1);
        //Dip
        blktiger_dip_a:array [0..4] of def_dip=(
        (mask:$7;name:'Coin A';number:8;dip:((dip_val:$0;dip_name:'4C 1C'),(dip_val:$1;dip_name:'3C 1C'),(dip_val:$2;dip_name:'2C 1C'),(dip_val:$7;dip_name:'1C 1C'),(dip_val:$6;dip_name:'1C 2C'),(dip_val:$5;dip_name:'1C 3C'),(dip_val:$4;dip_name:'1C 4C'),(dip_val:$3;dip_name:'1C 5C'),(),(),(),(),(),(),(),())),
        (mask:$38;name:'Coin B';number:8;dip:((dip_val:$0;dip_name:'4C 1C'),(dip_val:$8;dip_name:'3C 1C'),(dip_val:$10;dip_name:'2C 1C'),(dip_val:$38;dip_name:'1C 1C'),(dip_val:$30;dip_name:'1C 2C'),(dip_val:$28;dip_name:'1C 3C'),(dip_val:$20;dip_name:'1C 4C'),(dip_val:$18;dip_name:'1C 5C'),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Flip Screen';number:2;dip:((dip_val:$40;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Test';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        blktiger_dip_b:array [0..5] of def_dip=(
        (mask:$3;name:'Lives';number:4;dip:((dip_val:$2;dip_name:'2'),(dip_val:$3;dip_name:'3'),(dip_val:$1;dip_name:'5'),(dip_val:$0;dip_name:'7'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$1c;name:'Difficulty';number:8;dip:((dip_val:$1c;dip_name:'Very Easy'),(dip_val:$18;dip_name:'Easy 3'),(dip_val:$14;dip_name:'Easy 2'),(dip_val:$10;dip_name:'Easy 1'),(dip_val:$c;dip_name:'Normal'),(dip_val:$8;dip_name:'Difficult 1'),(dip_val:$4;dip_name:'Difficult 2'),(dip_val:$0;dip_name:'Very Difficult'),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$20;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Allow Continue';number:2;dip:((dip_val:$0;dip_name:'No'),(dip_val:$40;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$80;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 scroll_ram:array[0..$3fff] of byte;
 memoria_rom:array[0..$f,$0..$3fff] of byte;
 banco_rom,soundlatch,i8751_latch,z80_latch,timer_hs,mask_x,mask_y,shl_row:byte;
 mask_sx,mask_sy,scroll_x,scroll_y,scroll_bank:word;
 bg_on,ch_on,spr_on:boolean;

procedure update_video_blktiger;inline;
const
  split_table:array[0..15] of byte=(3,3,2,2,1,1,0,0,0,0,0,0,0,0,0,0);
var
    f,x,y,nchar,pos_x,pos_y,color:word;
    sx,sy,pos,atrib:word;
    flip_x:boolean;
begin
//Para que el fondo de la pantalla 4 se vea negro, tengo que hacerlo asi... Rellenar
//la pantalla final y todo el fondo con transparencias...
fill_full_screen(4,$400);
if bg_on then begin
  pos_x:=(scroll_x and mask_sx) shr 4;
  pos_y:=(scroll_y and mask_sy) shr 4;
  for f:=0 to $120 do begin
    x:=f mod 17;
    y:=f div 17;
    sx:=x+pos_x;
    sy:=y+pos_y;
    pos:=((sx and $0f)+((sy and $0f) shl 4)+((sx and mask_x) shl 4)+((sy and mask_y) shl shl_row)) shl 1;
    atrib:=scroll_ram[pos+1];
    color:=(atrib and $78) shr 3;
    if (gfx[2].buffer[pos shr 1] or buffer_color[color+$20]) then begin
      nchar:=scroll_ram[pos]+((atrib and $7) shl 8);
      flip_x:=(atrib and $80)<>0;
      put_gfx_trans_flip(x*16,y*16,nchar,color shl 4,1,2,flip_x,false);
      if split_table[color]<>0 then put_gfx_trans_flip_alt(x*16,y*16,nchar,color shl 4,2,2,flip_x,false,split_table[color])
        else put_gfx_block_trans(x*16,y*16,2,16,16);
      gfx[2].buffer[pos shr 1]:=false;
    end;
  end;
  scroll_x_y(1,4,scroll_x and $f,scroll_y and $f);
end;
if spr_on then begin
  for f:=$7f downto 0 do begin
    atrib:=buffer_sprites[$1+(f*4)];
    nchar:=buffer_sprites[f*4]+(atrib and $e0) shl 3;
    color:=(atrib and $7) shl 4;
    x:=buffer_sprites[$3+(f*4)]+(atrib and $10) shl 4;
    y:=buffer_sprites[$2+(f*4)];
    put_gfx_sprite(nchar,color+$200,(atrib and 8)<>0,false,1);
    actualiza_gfx_sprite(x,y,4,1);
  end;
end;
if bg_on then scroll_x_y(2,4,scroll_x and $f,scroll_y and $f);
if ch_on then begin
  for f:=$0 to $3ff do begin
   atrib:=memoria[$d400+f];
   color:=atrib and $1f;
   if (gfx[0].buffer[f] or buffer_color[color]) then begin
      y:=f shr 5;
      x:=f and $1f;
      nchar:=memoria[$d000+f]+(atrib and $e0) shl 3;
      put_gfx_trans(x*8,y*8,nchar,(color shl 2)+$300,3,0);
      gfx[0].buffer[f]:=false;
   end;
  end;
  actualiza_trozo(0,0,256,256,3,0,0,256,256,4);
end;
actualiza_trozo_final(0,16,256,224,4);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
end;

procedure eventos_blktiger;
begin
if event.arcade then begin
  //SYS
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  //P1
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  //P2
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
end;
end;

procedure blktiger_principal;
var
  frame_m,frame_s,frame_mcu:single;
  f:byte;
  {$ifdef speed_debug}cont1,cont2:int64;{$endif}
begin
init_controls(false,false,false,true);
frame_m:=z80_0.tframes;
frame_s:=z80_1.tframes;
frame_mcu:=mcs51_0.tframes;
while EmuStatus=EsRuning do begin
  {$ifdef speed_debug}
  QueryPerformanceCounter(cont1);
  {$endif}
  for f:=0 to $ff do begin
    //Main CPU
    z80_0.run(frame_m);
    frame_m:=frame_m+z80_0.tframes-z80_0.contador;
    //Sound CPU
    z80_1.run(frame_s);
    frame_s:=frame_s+z80_1.tframes-z80_1.contador;
    //MCU
    mcs51_0.run(frame_mcu);
    frame_mcu:=frame_mcu+mcs51_0.tframes-mcs51_0.contador;
    if f=239 then begin
      z80_0.change_irq(HOLD_LINE);
      copymemory(@buffer_sprites,@memoria[$fe00],$200);
      update_video_blktiger;
    end;
  end;
  eventos_blktiger;
  {$ifdef speed_debug}
  QueryPerformanceCounter(cont2);
  principal1.statusbar1.panels[2].text:=inttostr(cont2-cont1);
  {$endif}
  video_sync;
end;
end;

function blktiger_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff,$d000..$d7ff,$e000..$ffff:blktiger_getbyte:=memoria[direccion];
  $8000..$bfff:blktiger_getbyte:=memoria_rom[banco_rom,(direccion and $3fff)];
  $c000..$cfff:blktiger_getbyte:=scroll_ram[scroll_bank+(direccion and $fff)];
  $d800..$dfff:blktiger_getbyte:=buffer_paleta[direccion and $7ff];
  //$f3a1:blktiger_getbyte:=4;
end;
end;

procedure cambiar_color(dir:word);inline;
var
  tmp_color:byte;
  color:tcolor;
begin
  tmp_color:=buffer_paleta[dir];
  color.r:=pal4bit(tmp_color shr 4);
  color.g:=pal4bit(tmp_color);
  tmp_color:=buffer_paleta[dir+$400];
  color.b:=pal4bit(tmp_color);
  set_pal_color(color,dir);
  case dir of
    $0..$ff:buffer_color[(dir shr 4)+$20]:=true;
    $300..$37f:buffer_color[(dir shr 2) and $1f]:=true;
  end;
end;

procedure blktiger_putbyte(direccion:word;valor:byte);
begin
case direccion of
        0..$bfff:; //ROM
        $c000..$cfff:if scroll_ram[scroll_bank+(direccion and $fff)]<>valor then begin
                          scroll_ram[scroll_bank+(direccion and $fff)]:=valor;
                          gfx[2].buffer[(scroll_bank+(direccion and $fff)) shr 1]:=true;
                          memoria[direccion]:=valor;
                     end;
        $d000..$d7ff:if memoria[direccion]<>valor then begin
                        gfx[0].buffer[direccion and $3ff]:=true;
                        memoria[direccion]:=valor;
                     end;
        $d800..$dfff:if buffer_paleta[direccion and $7ff]<>valor then begin
                        buffer_paleta[direccion and $7ff]:=valor;
                        cambiar_color(direccion and $3ff);
                     end;
        $e000..$ffff:memoria[direccion]:=valor;
end;
end;

function blktiger_inbyte(puerto:word):byte;
begin
case (puerto and $ff) of
  0:blktiger_inbyte:=marcade.in0;
  1:blktiger_inbyte:=marcade.in1;
  2:blktiger_inbyte:=marcade.in2;
  3:blktiger_inbyte:=marcade.dswa;
  4:blktiger_inbyte:=marcade.dswb;
  5:blktiger_inbyte:=$1; //Freeze?
  7:blktiger_inbyte:=i8751_latch;  //Proteccion
  else blktiger_inbyte:=$ff;
end;
end;

procedure blktiger_outbyte(puerto:word;valor:byte);
begin
case (puerto and $ff) of
  0:soundlatch:=valor;
  1:banco_rom:=valor and $f;
  4:begin
      if ch_on<>((valor and $80)=0) then begin
         ch_on:=(valor and $80)=0;
         if ch_on then fillchar(gfx[0].buffer,$400,1);
      end;
      main_screen.flip_main_screen:=(valor and $40)<>0;
      z80_1.change_reset((valor and $20) shr 5);
    end;
  7:begin
      z80_latch:=valor;
      mcs51_0.change_irq1(ASSERT_LINE);
    end;
  8:if ((scroll_x and $ff)<>valor) then begin
      if abs((scroll_x and mask_sx)-(valor and mask_sx))>15 then fillchar(gfx[2].buffer,$2000,1);
      scroll_x:=(scroll_x and $ff00) or valor;
    end;
  9:if ((scroll_x shr 8)<>valor) then begin
      if abs((scroll_x and mask_sx)-(valor and mask_sx))>15 then fillchar(gfx[2].buffer,$2000,1);
      scroll_x:=(scroll_x and $ff) or (valor shl 8);
    end;
  $a:if ((scroll_y and $ff)<>valor) then begin
      if abs((scroll_y and mask_sy)-(valor and mask_sy))>15 then fillchar(gfx[2].buffer,$2000,1);
      scroll_y:=(scroll_y and $ff00) or valor;
    end;
  $b:if ((scroll_y shr 8)<>valor) then begin
      if abs((scroll_y and mask_sy)-(valor and mask_sy))>15 then fillchar(gfx[2].buffer,$2000,1);
      scroll_y:=(scroll_y and $ff) or (valor shl 8);
    end;
  $c:begin
      if bg_on<>((valor and $2)=0) then begin
         bg_on:=(valor and $2)=0;
         if bg_on then fillchar(gfx[2].buffer,$2000,1);
      end;
      spr_on:=(valor and $4)=0;
     end;
  $d:scroll_bank:=(valor and 3) shl 12;
  $e:if ((valor and 1)<>0) then begin
        mask_x:=$70;
        mask_y:=$30;
        shl_row:=7;
        mask_sx:=$1ff0;
        mask_sy:=$ff0;
     end else begin
        mask_x:=$30;
        mask_y:=$70;
        shl_row:=6;
        mask_sx:=$ff0;
        mask_sy:=$1ff0;
     end
end;
end;

function blksnd_getbyte(direccion:word):byte;
begin
  case direccion of
    0..$7fff,$c000..$c7ff:blksnd_getbyte:=mem_snd[direccion];
    $c800:blksnd_getbyte:=soundlatch;
    $e000:blksnd_getbyte:=ym2203_0.status;
    $e002:blksnd_getbyte:=ym2203_1.status;
  end;
end;

procedure blksnd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:; //ROM
  $c000..$c7ff:mem_snd[direccion]:=valor;
  $e000:ym2203_0.Control(valor);
  $e001:ym2203_0.write(valor);
  $e002:ym2203_1.Control(valor);
  $e003:ym2203_1.write(valor);
end;
end;

procedure out_port0(valor:byte);
begin
  i8751_latch:=valor;
end;

function in_port0:byte;
begin
  mcs51_0.change_irq1(CLEAR_LINE);
  in_port0:=z80_latch;
end;

procedure blktiger_sound_update;
begin
  ym2203_0.update;
  ym2203_1.update;
end;

procedure snd_irq(irqstate:byte);
begin
  z80_1.change_irq(irqstate);
end;

procedure blk_hi_score;
begin
if ((memoria[$e204]=2) and (memoria[$e205]=0) and (memoria[$e206]=0)) then begin
    load_hi('blktiger.hi',@memoria[$e200],80);
    copymemory(@memoria[$e1e0],@memoria[$e200],8);
    timers.enabled(timer_hs,false);
end;
end;

procedure blktiger_qsave(nombre:string);
var
  data:pbyte;
  buffer:array[0..19] of byte;
  size:word;
begin
open_qsnapshot_save('blacktiger'+nombre);
getmem(data,20000);
//CPU
size:=z80_0.save_snapshot(data);
savedata_qsnapshot(data,size);
size:=z80_1.save_snapshot(data);
savedata_qsnapshot(data,size);
size:=mcs51_0.save_snapshot(data);
savedata_qsnapshot(data,size);
//SND
size:=ym2203_0.save_snapshot(data);
savedata_com_qsnapshot(data,size);
size:=ym2203_1.save_snapshot(data);
savedata_com_qsnapshot(data,size);
//MEM
savedata_com_qsnapshot(@memoria[$c000],$4000);
savedata_com_qsnapshot(@mem_snd[$8000],$8000);
//MISC
savedata_com_qsnapshot(@scroll_ram,$4000);
buffer[0]:=banco_rom;
buffer[1]:=soundlatch;
buffer[2]:=scroll_x and $ff;
buffer[3]:=scroll_x shr 8;
buffer[4]:=scroll_y and $ff;
buffer[5]:=scroll_y shr 8;
buffer[6]:=scroll_bank and $ff;
buffer[7]:=scroll_bank shr 8;
buffer[8]:=mask_x;
buffer[9]:=mask_y;
buffer[10]:=shl_row;
buffer[11]:=mask_sx and $ff;
buffer[12]:=mask_sx shr 8;
buffer[13]:=mask_sy and $ff;
buffer[14]:=mask_sy shr 8;
buffer[15]:=i8751_latch;
buffer[16]:=z80_latch;
buffer[17]:=byte(bg_on);
buffer[18]:=byte(ch_on);
buffer[19]:=byte(spr_on);
savedata_qsnapshot(@buffer,20);
savedata_com_qsnapshot(@buffer_paleta,$800*2);
savedata_com_qsnapshot(@buffer_sprites,$200);
freemem(data);
close_qsnapshot;
end;

procedure blktiger_qload(nombre:string);
var
  data:pbyte;
  buffer:array[0..19] of byte;
  f:word;
begin
if not(open_qsnapshot_load('blacktiger'+nombre)) then exit;
getmem(data,20000);
//CPU
loaddata_qsnapshot(data);
z80_0.load_snapshot(data);
loaddata_qsnapshot(data);
z80_1.load_snapshot(data);
loaddata_qsnapshot(data);
mcs51_0.load_snapshot(data);
//SND
loaddata_qsnapshot(data);
ym2203_0.load_snapshot(data);
loaddata_qsnapshot(data);
ym2203_1.load_snapshot(data);
//MEM
loaddata_qsnapshot(@memoria[$c000]);
loaddata_qsnapshot(@mem_snd[$8000]);
//MISC
loaddata_qsnapshot(@scroll_ram);
loaddata_qsnapshot(@buffer);
banco_rom:=buffer[0];
soundlatch:=buffer[1];
scroll_x:=buffer[2] or (buffer[3] shl 8);
scroll_y:=buffer[4] or (buffer[5] shl 8);
scroll_bank:=buffer[6] or (buffer[7] shl 8);
mask_x:=buffer[8];
mask_y:=buffer[9];
shl_row:=buffer[10];
mask_sx:=buffer[11] or (buffer[12] shl 8);
mask_sy:=buffer[13] or (buffer[14] shl 8);
i8751_latch:=buffer[15];
z80_latch:=buffer[16];
bg_on:=buffer[17]<>0;
ch_on:=buffer[18]<>0;
spr_on:=buffer[19]<>0;
loaddata_qsnapshot(@buffer_paleta);
loaddata_qsnapshot(@buffer_sprites);
freemem(data);
close_qsnapshot;
//END
for f:=0 to $3ff do cambiar_color(f);
fillchar(buffer_color,$400,1);
fillchar(gfx[0].buffer,$400,1);
fillchar(gfx[2].buffer,$4000,1);
end;

//Main
procedure reset_blktiger;
begin
 z80_0.reset;
 z80_1.reset;
 mcs51_0.reset;
 ym2203_0.reset;
 ym2203_1.reset;
 reset_audio;
 banco_rom:=0;
 soundlatch:=0;
 scroll_bank:=0;
 scroll_x:=0;
 scroll_y:=0;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 mask_x:=$70;
 mask_y:=$30;
 shl_row:=7;
 i8751_latch:=0;
 z80_latch:=0;
 bg_on:=true;
 ch_on:=true;
 spr_on:=true;
end;

function iniciar_blktiger:boolean;
var
  f:word;
  memoria_temp:array[0..$47fff] of byte;
const
  ps_x:array[0..15] of dword=(0, 1, 2, 3, 8+0, 8+1, 8+2, 8+3,
			16*16+0, 16*16+1, 16*16+2, 16*16+3, 16*16+8+0, 16*16+8+1, 16*16+8+2, 16*16+8+3);
  ps_y:array[0..15] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16,
			8*16, 9*16, 10*16, 11*16, 12*16, 13*16, 14*16, 15*16);
begin
iniciar_blktiger:=false;
iniciar_audio(false);
//Background
screen_init(1,272,272,true);
screen_mod_scroll(1,272,256,255,272,256,255);
//Foreground
screen_init(2,272,272,true);
screen_mod_scroll(2,272,256,255,272,256,255);
screen_init(3,256,256,true); //Chars
screen_init(4,512,256,false,true); //Final
iniciar_video(256,224);
//Main CPU
z80_0:=cpu_z80.create(6000000,256);
z80_0.change_ram_calls(blktiger_getbyte,blktiger_putbyte);
z80_0.change_io_calls(blktiger_inbyte,blktiger_outbyte);
//Sound CPU
z80_1:=cpu_z80.create(3579545,256);
z80_1.change_ram_calls(blksnd_getbyte,blksnd_putbyte);
z80_1.init_sound(blktiger_sound_update);
//MCU
mcs51_0:=cpu_mcs51.create(6000000,256);
mcs51_0.change_io_calls(in_port0,nil,nil,nil,out_port0,nil,nil,nil);
//Sound Chip
ym2203_0:=ym2203_chip.create(3579545,0.15,0.15);
ym2203_0.change_irq_calls(snd_irq);
ym2203_1:=ym2203_chip.create(3579545,0.15,0.15);
//Timers
timer_hs:=timers.init(z80_0.numero_cpu,10000,blk_hi_score,nil,true);
//cargar roms
if not(roms_load(@memoria_temp,blktiger_rom)) then exit;
//poner las roms y los bancos de rom
copymemory(@memoria,@memoria_temp,$8000);
for f:=0 to 15 do copymemory(@memoria_rom[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
//sonido
if not(roms_load(@mem_snd,blktiger_snd)) then exit;
//MCU ROM
if not(roms_load(mcs51_0.get_rom_addr,blktiger_mcu)) then exit;
//convertir chars
if not(roms_load(@memoria_temp,blktiger_char)) then exit;
init_gfx(0,8,8,2048);
gfx[0].trans[3]:=true;
gfx_set_desc_data(2,0,16*8,4,0);
convert_gfx(0,0,@memoria_temp,@ps_x,@ps_y,false,false);
//convertir sprites
if not(roms_load(@memoria_temp,blktiger_sprites)) then exit;
init_gfx(1,16,16,$800);
gfx[1].trans[15]:=true;
gfx_set_desc_data(4,0,32*16,$800*32*16+4,$800*32*16+0,4,0);
convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,false);
//tiles
if not(roms_load(@memoria_temp,blktiger_tiles)) then exit;
init_gfx(2,16,16,$800);
gfx[2].trans[15]:=true;
gfx[2].trans_alt[0,15]:=true;
for f:=4 to 15 do gfx[2].trans_alt[1,f]:=true;
for f:=8 to 15 do gfx[2].trans_alt[2,f]:=true;
for f:=12 to 15 do gfx[2].trans_alt[3,f]:=true;
gfx_set_desc_data(4,0,32*16,$800*32*16+4,$800*32*16+0,4,0);
convert_gfx(2,0,@memoria_temp,@ps_x,@ps_y,false,false);
//DIP
marcade.dswa:=$ff;
marcade.dswb:=$6f;
marcade.dswa_val:=@blktiger_dip_a;
marcade.dswb_val:=@blktiger_dip_b;
//final
reset_blktiger;
iniciar_blktiger:=true;
end;

procedure cerrar_blktiger;
begin
save_hi('blktiger.hi',@memoria[$e200],80);
end;

procedure cargar_blktiger;
begin
llamadas_maquina.iniciar:=iniciar_blktiger;
llamadas_maquina.bucle_general:=blktiger_principal;
llamadas_maquina.close:=cerrar_blktiger;
llamadas_maquina.reset:=reset_blktiger;
llamadas_maquina.save_qsnap:=blktiger_qsave;
llamadas_maquina.load_qsnap:=blktiger_qload;
end;

end.
