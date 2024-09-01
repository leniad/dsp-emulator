unit lasso_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6502,main_engine,controls_engine,sn_76496,gfx_engine,rom_engine,
     pal_engine,sound_engine,misc_functions;

function iniciar_lasso:boolean;

implementation
const
        lasso_rom:array[0..1] of tipo_roms=(
        (n:'wm3';l:$2000;p:$8000;crc:$f93addd6),(n:'wm4';l:$2000;p:$a000;crc:$77719859));
        lasso_snd:array[0..2] of tipo_roms=(
        (n:'wmc';l:$1000;p:$5000;crc:$8b4eb242),(n:'wmb';l:$1000;p:$6000;crc:$4658bcb9),
        (n:'wma';l:$1000;p:$7000;crc:$2e7de3e9));
        lasso_sub:tipo_roms=(n:'wm5';l:$1000;p:$8000;crc:$7dc3ff07);
        lasso_char:array[0..1] of tipo_roms=(
        (n:'2';l:$2000;p:$4000;crc:$7db77256),(n:'wm2';l:$2000;p:$6000;crc:$9e7d0b6f));
        lasso_pal:array[0..1] of tipo_roms=(
        (n:'82s123.69';l:$20;p:0;crc:$1eabb04d),(n:'82s123.70';l:$20;p:$20;crc:$09060f8c));
        lasso_dip_a:array [0..5] of def_dip2=(
        (mask:1;name:'Cabinet';number:2;val2:(1,0);name2:('Upright','Cocktail')),
        (mask:$e;name:'Coin A';number:8;val8:(2,0,8,4,$c,6,$a,$e);name8:('2C 1C','1C 1C','1C 2C','1C 3C','1C 6C','ND','ND','ND')),
        (mask:$30;name:'Lives';number:4;val4:(0,$10,$20,$30);name4:('3','4','5','ND')),
        (mask:$40;name:'Coin B';number:2;val2:($40,0);name2:('2C 1C','1C 1C')),
        (mask:$80;name:'Warm-Up Instructions';number:2;val2:(0,$80);name2:('No','yes')),());
        lasso_dip_b:array [0..3] of def_dip2=(
        (mask:1;name:'Warm-Up';number:2;val2:(1,0);name2:('No','Yes')),
        (mask:2;name:'Warm-Up Language';number:2;val2:(0,2);name2:('English','German')),
        (mask:8;name:'Invulnerability';number:2;val2:(0,8);name2:('Off','On')),());
        chameleo_rom:array[0..3] of tipo_roms=(
        (n:'chamel4.bin';l:$2000;p:$4000;crc:$97379c47),(n:'chamel5.bin';l:$2000;p:$6000;crc:$0a2cadfd),
        (n:'chamel6.bin';l:$2000;p:$8000;crc:$b023c354),(n:'chamel7.bin';l:$2000;p:$a000;crc:$a5a03375));
        chameleo_snd:array[0..2] of tipo_roms=(
        (n:'chamel3.bin';l:$1000;p:$1000;crc:$52eab9ec),(n:'chamel2.bin';l:$1000;p:$6000;crc:$81dcc49c),
        (n:'chamel1.bin';l:$1000;p:$7000;crc:$96031d3b));
        chameleo_char:array[0..1] of tipo_roms=(
        (n:'chamel8.bin';l:$2000;p:$4000;crc:$dc67916b),(n:'chamel9.bin';l:$2000;p:$6000;crc:$6b559bf1));
        chameleo_pal:array[0..1] of tipo_roms=(
        (n:'chambprm.bin';l:$20;p:0;crc:$e3ad76df),(n:'chamaprm.bin';l:$20;p:$20;crc:$c7063b54));
        chameleon_dip_a:array [0..4] of def_dip2=(
        (mask:1;name:'Cabinet';number:2;val2:(1,0);name2:('Upright','Cocktail')),
        (mask:$e;name:'Coin A';number:8;val8:(2,0,8,4,$c,6,$a,$e);name8:('2C 1C','1C 1C','1C 2C','1C 3C','1C 6C','ND','ND','ND')),
        (mask:$30;name:'Lives';number:4;val4:(0,$30,$10,$20);name4:('3','5','ND','Infinite')),
        (mask:$40;name:'Coin B';number:2;val2:($40,0);name2:('2C 1C','1C 1C')),());
        chameleon_dip_b:array [0..1] of def_dip2=(
        (mask:8;name:'Demo Sounds';number:2;val2:(0,8);name2:('Off','On')),());

var
  chip_data,back_color,gfxbank,soundlatch:byte;
  sprite_ram:array[0..$7f] of byte;
  //Lasso
  buffer_blitter:array[0..$1fff] of boolean;

function lasso_set_color(valor:byte):tcolor;
var
  color:tcolor;
  bit0,bit1,bit2:byte;
begin
  // red component
  bit0:=(valor shr 0) and 1;
  bit1:=(valor shr 1) and 1;
  bit2:=(valor shr 2) and 1;
  color.r:=bit0*$21+bit1*$47+bit2*$97;
  // green component
  bit0:=(valor shr 3) and 1;
  bit1:=(valor shr 4) and 1;
  bit2:=(valor shr 5) and 1;
  color.g:=bit0*$21+bit1*$47+bit2*$97;
  // blue component
  bit0:=(valor shr 6) and 1;
  bit1:=(valor shr 7) and 1;
  color.b:=bit0*$4f+bit1*$a8;
  lasso_set_color:=color;
end;

procedure update_video_lasso;
var
  f,nchar:word;
  x,y,color,atrib,bit:byte;
  ptemp:pword;
begin
for f:=0 to $1fff do begin
  if buffer_blitter[f] then begin
    y:=f shr 5;
    x:=f and $1f;
    atrib:=mem_misc[$2000+f];
    ptemp:=punbuf;
    for bit:=0 to 7 do begin
      if (atrib and $80)<>0 then ptemp^:=paleta[$3f]
        else ptemp^:=paleta[0];
      atrib:=atrib shl 1;
      inc(ptemp);
    end;
    putpixel(x*8,y,8,punbuf,1);
    buffer_blitter[f]:=false;
  end;
end;
actualiza_trozo(0,0,256,256,1,0,0,256,256,3);
for f:=0 to $3ff do begin
  if gfx[0].buffer[f] then begin
    x:=f mod 32;
    y:=f div 32;
    nchar:=memoria[$400+f]+(gfxbank shl 8);
    color:=memoria[$800+f] and $f;
    put_gfx_trans(x*8,y*8,nchar,color shl 2,2,0);
    gfx[0].buffer[f]:=false;
  end;
end;
actualiza_trozo(0,0,256,256,2,0,0,256,256,3);
//Sprites
for f:=0 to $1f do begin
  atrib:=sprite_ram[1+(f*4)];
  x:=sprite_ram[3+(f*4)];
  y:=240-sprite_ram[0+(f*4)];
  nchar:=(atrib and $3f)+(gfxbank shl 6);
  color:=(sprite_ram[2+(f*4)] and $f) shl 2;
  put_gfx_sprite(nchar,color,(atrib and $40)<>0,(atrib and $80)<>0,1);
  actualiza_gfx_sprite(x,y,3,1);
end;
actualiza_trozo_final(0,16,256,224,3);
end;

procedure update_video_chameleon;
var
  f,nchar:word;
  x,y,color,atrib:byte;
begin
fill_full_screen(3,0);
for f:=0 to $3ff do begin
  if gfx[0].buffer[f] then begin
    x:=f mod 32;
    y:=f div 32;
    nchar:=memoria[$400+f]+(gfxbank shl 8);
    color:=memoria[$800+f] and $f;
    put_gfx_trans(x*8,y*8,nchar,color shl 2,2,0);
    gfx[0].buffer[f]:=false;
  end;
end;
actualiza_trozo(0,0,256,256,2,0,0,256,256,3);
//Sprites
for f:=0 to $1f do begin
  atrib:=sprite_ram[1+(f*4)];
  x:=sprite_ram[3+(f*4)];
  y:=240-sprite_ram[0+(f*4)];
  nchar:=(atrib and $3f)+(gfxbank shl 6);
  color:=(sprite_ram[2+(f*4)] and $f) shl 2;
  put_gfx_sprite(nchar,color,(atrib and $40)<>0,(atrib and $80)<>0,1);
  actualiza_gfx_sprite(x,y,3,1);
end;
actualiza_trozo_final(0,16,256,224,3);
end;

procedure eventos_lasso;
begin
if event.arcade then begin
  //P1
  if arcade_input.right[0] then marcade.in0:=marcade.in0 or 1 else marcade.in0:=marcade.in0 and $fe;
  if arcade_input.left[0] then marcade.in0:=marcade.in0 or 2 else marcade.in0:=marcade.in0 and $fd;
  if arcade_input.up[0] then marcade.in0:=marcade.in0 or 4 else marcade.in0:=marcade.in0 and $fb;
  if arcade_input.down[0] then marcade.in0:=marcade.in0 or 8 else marcade.in0:=marcade.in0 and $f7;
  if arcade_input.but0[0] then marcade.in0:=marcade.in0 or $10 else marcade.in0:=marcade.in0 and $ef;
  if arcade_input.but1[0] then marcade.in0:=marcade.in0 or $20 else marcade.in0:=marcade.in0 and $df;
  //P2
  if arcade_input.right[1] then marcade.in1:=marcade.in1 or 1 else marcade.in1:=marcade.in1 and $fe;
  if arcade_input.left[1] then marcade.in1:=marcade.in1 or 2 else marcade.in1:=marcade.in1 and $fd;
  if arcade_input.up[1] then marcade.in1:=marcade.in1 or 4 else marcade.in1:=marcade.in1 and $fb;
  if arcade_input.down[1] then marcade.in1:=marcade.in1 or 8 else marcade.in1:=marcade.in1 and $f7;
  if arcade_input.but0[1] then marcade.in1:=marcade.in1 or $10 else marcade.in1:=marcade.in1 and $ef;
  if arcade_input.but1[1] then marcade.in1:=marcade.in1 or $20 else marcade.in1:=marcade.in1 and $df;
  //System
  if arcade_input.coin[0] then begin
      marcade.in2:=(marcade.in2 and $df);
      m6502_0.change_nmi(ASSERT_LINE);
  end else begin
      marcade.in2:=(marcade.in2 or $20);
      if arcade_input.coin[1] then begin
          marcade.in2:=(marcade.in2 and $ef);
          m6502_0.change_nmi(ASSERT_LINE);
      end else begin
          marcade.in2:=(marcade.in2 or $10);
          m6502_0.change_nmi(CLEAR_LINE);
      end;
  end;
  if arcade_input.start[1] then marcade.in2:=marcade.in2 or $40 else marcade.in2:=marcade.in2 and $bf;
  if arcade_input.start[0] then marcade.in2:=marcade.in2 or $80 else marcade.in2:=marcade.in2 and $7f;
end;
end;

procedure principal_lasso;
var
  f:byte;
  frame_m,frame_sub,frame_snd:single;
begin
init_controls(false,false,false,true);
frame_m:=m6502_0.tframes;
frame_snd:=m6502_1.tframes;
frame_sub:=m6502_2.tframes;
while EmuStatus=EsRunning do begin
 for f:=0 to $ff do begin
    case f of
      240:begin
            update_video_lasso;
            m6502_0.change_irq(HOLD_LINE);
          end;
    end;
    m6502_0.run(frame_m);
    frame_m:=frame_m+m6502_0.tframes-m6502_0.contador;
    m6502_1.run(frame_snd);
    frame_snd:=frame_snd+m6502_1.tframes-m6502_1.contador;
    m6502_2.run(frame_sub);
    frame_sub:=frame_sub+m6502_2.tframes-m6502_2.contador;
 end;
 eventos_lasso;
 video_sync;
end;
end;

procedure principal_chameleon;
var
  f:byte;
  frame_m,frame_snd:single;
begin
init_controls(false,false,false,true);
frame_m:=m6502_0.tframes;
frame_snd:=m6502_1.tframes;
while EmuStatus=EsRunning do begin
 for f:=0 to $ff do begin
    case f of
      240:begin
            update_video_chameleon;
            m6502_0.change_irq(HOLD_LINE);
          end;
    end;
    m6502_0.run(frame_m);
    frame_m:=frame_m+m6502_0.tframes-m6502_0.contador;
    m6502_1.run(frame_snd);
    frame_snd:=frame_snd+m6502_1.tframes-m6502_1.contador;
 end;
 eventos_lasso;
 video_sync;
end;
end;

function getbyte_lasso(direccion:word):byte;
begin
case direccion of
  0..$bff,$1000..$17ff:getbyte_lasso:=memoria[direccion];
  $c00..$c7f:getbyte_lasso:=sprite_ram[direccion and $7f];
  $1804:getbyte_lasso:=marcade.in0;
  $1805:getbyte_lasso:=marcade.in1;
  $1806:getbyte_lasso:=marcade.dswa;
  $1807:getbyte_lasso:=marcade.dswb or marcade.in2;
  $8000..$ffff:getbyte_lasso:=memoria[$8000+(direccion and $3fff)];
end;
end;

procedure putbyte_lasso(direccion:word;valor:byte);
var
  tempb:byte;
begin
case direccion of
  0..$3ff,$1000..$17ff:memoria[direccion]:=valor;
  $400..$bff:if memoria[direccion]<>valor then begin
                  gfx[0].buffer[direccion and $3ff]:=true;
                  memoria[direccion]:=valor;
               end;
  $c00..$c7f:sprite_ram[direccion and $7f]:=valor;
  $1800:begin
          m6502_1.change_irq(HOLD_LINE);
          soundlatch:=valor;
        end;
  $1801:if back_color<>valor then begin
          set_pal_color(lasso_set_color(valor),0);
          fillchar(buffer_blitter,$2000,1);
          back_color:=valor;
        end;
  $1802:begin
          tempb:=(valor and 4) shr 2;
          if (gfxbank<>tempb) then begin
		        gfxbank:=tempb;
		        fillchar(gfx[0].buffer,$400,1);
          end;
          main_screen.flip_main_screen:=(valor and 3)<>0;
        end;
  $8000..$ffff:;
end;
end;

function getbyte_sublasso(direccion:word):byte;
begin
case direccion of
  0..$7ff:getbyte_sublasso:=memoria[$1000+direccion];
  $2000..$3fff:getbyte_sublasso:=mem_misc[direccion];
  $8000..$ffff:getbyte_sublasso:=mem_misc[$8000+(direccion and $fff)];
end;
end;

procedure putbyte_sublasso(direccion:word;valor:byte);
begin
case direccion of
  0..$7ff:memoria[$1000+direccion]:=valor;
  $2000..$3fff:if mem_misc[direccion]<>valor then begin
                  mem_misc[direccion]:=valor;
                  buffer_blitter[direccion and $1fff]:=true;
               end;
  $8000..$ffff:;
end;
end;

function getbyte_sndlasso(direccion:word):byte;
begin
case direccion of
  0..$1ff,$5000..$7fff:getbyte_sndlasso:=mem_snd[direccion];
  $b004:getbyte_sndlasso:=3;
  $b005:getbyte_sndlasso:=soundlatch;
  $f000..$ffff:getbyte_sndlasso:=mem_snd[$7000+(direccion and $fff)];
end;
end;

procedure putbyte_sndlasso(direccion:word;valor:byte);
begin
case direccion of
  0..$1ff:mem_snd[direccion]:=valor;
  $b000:chip_data:=BITSWAP8(valor,0,1,2,3,4,5,6,7);
  $b001:begin
          if (valor and 1)=0 then sn_76496_0.write(chip_data);
	        if (valor and 2)=0 then sn_76496_1.write(chip_data);
        end;
  $5000..$7fff,$f000..$ffff:;
end;
end;

procedure lasso_sound_update;
begin
  sn_76496_0.update;
  sn_76496_1.update;
end;

//Chameleon
function getbyte_chameleo(direccion:word):byte;
begin
case direccion of
  0..$fff,$1080..$10ff,$4000..$bfff:getbyte_chameleo:=memoria[direccion];
  $1000..$107f:getbyte_chameleo:=sprite_ram[direccion and $7f];
  $1804:getbyte_chameleo:=marcade.in0;
  $1805:getbyte_chameleo:=marcade.in1;
  $1806:getbyte_chameleo:=marcade.dswa;
  $1807:getbyte_chameleo:=marcade.dswb or marcade.in2;
  $e000..$ffff:getbyte_chameleo:=memoria[$a000+(direccion and $1fff)];
end;
end;

procedure putbyte_chameleo(direccion:word;valor:byte);
var
  tempb:byte;
begin
case direccion of
  0..$3ff,$c00..$fff,$1080..$10ff:memoria[direccion]:=valor;
  $400..$bff:if memoria[direccion]<>valor then begin
                  gfx[0].buffer[direccion and $3ff]:=true;
                  memoria[direccion]:=valor;
               end;
  $1000..$107f:sprite_ram[direccion and $7f]:=valor;
  $1800:begin
          m6502_1.change_irq(HOLD_LINE);
          soundlatch:=valor;
        end;
  $1801:if back_color<>valor then begin
          set_pal_color(lasso_set_color(valor),0);
          fillchar(buffer_blitter,$2000,1);
          back_color:=valor;
        end;
  $1802:begin
          tempb:=(valor and 4) shr 2;
          if (gfxbank<>tempb) then begin
		        gfxbank:=tempb;
		        fillchar(gfx[0].buffer,$400,1);
          end;
          main_screen.flip_main_screen:=(valor and 3)<>0;
        end;
  $4000..$bfff,$e000..$ffff:;
end;
end;

function getbyte_sndchameleo(direccion:word):byte;
begin
case direccion of
  0..$1ff,$1000..$1fff,$6000..$7fff:getbyte_sndchameleo:=mem_snd[direccion];
  $b004:getbyte_sndchameleo:=3;
  $b005:getbyte_sndchameleo:=soundlatch;
  $f000..$ffff:getbyte_sndchameleo:=mem_snd[$7000+(direccion and $fff)];
end;
end;

procedure putbyte_sndchameleo(direccion:word;valor:byte);
begin
case direccion of
  0..$1ff:mem_snd[direccion]:=valor;
  $b000:chip_data:=BITSWAP8(valor,0,1,2,3,4,5,6,7);
  $b001:begin
          if (valor and 1)=0 then sn_76496_0.write(chip_data);
	        if (valor and 2)=0 then sn_76496_1.write(chip_data);
        end;
  $1000..$1fff,$6000..$7fff,$f000..$ffff:;
end;
end;

//Main
procedure reset_lasso;
begin
m6502_0.reset;
m6502_1.reset;
if main_vars.tipo_maquina=390 then m6502_2.reset;
sn_76496_0.reset;
sn_76496_1.reset;
reset_audio;
soundlatch:=0;
back_color:=0;
chip_data:=0;
gfxbank:=0;
marcade.in0:=0;
marcade.in1:=0;
marcade.in2:=$30;
end;

function iniciar_lasso:boolean;
var
  f:byte;
  colores:tpaleta;
  memoria_temp:array[0..$7fff] of byte;
procedure convert_char_sprites;
const
    ps_x:array[0..15] of dword=(0, 1, 2, 3, 4, 5, 6, 7,
      8*8+0, 8*8+1, 8*8+2, 8*8+3, 8*8+4, 8*8+5, 8*8+6, 8*8+7);
    ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			8*8*2+(8*0), 8*8*2+(8*1), 8*8*2+(8*2), 8*8*2+(8*3), 8*8*2+(8*4), 8*8*2+(8*5), 8*8*2+(8*6), 8*8*2+(8*7));
begin
init_gfx(0,8,8,$200);
gfx[0].trans[0]:=true;
gfx_set_desc_data(2,0,8*8,0,$2000*8);
convert_gfx(0,0,@memoria_temp,@ps_x,@ps_y,false,false);
//sprites
init_gfx(1,16,16,$80);
gfx[1].trans[0]:=true;
gfx_set_desc_data(2,0,16*16,$1000*8,$3000*8);
convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,false);
end;
begin
llamadas_maquina.reset:=reset_lasso;
llamadas_maquina.fps_max:=57;
iniciar_lasso:=false;
iniciar_audio(false);
if main_vars.tipo_maquina=390 then main_screen.rot90_screen:=true;
screen_init(1,256,256);
screen_init(2,256,256,true);
screen_init(3,256,256,false,true);
iniciar_video(256,224);
//Main CPU
m6502_0:=cpu_m6502.create(11289000 div 16,256,TCPU_M6502);
//Sound CPU
m6502_1:=cpu_m6502.create(600000,256,TCPU_M6502);
m6502_1.init_sound(lasso_sound_update);
//Sound Chip
sn_76496_0:=sn76496_chip.Create(2000000);
sn_76496_1:=sn76496_chip.Create(2000000);
case main_vars.tipo_maquina of
  390:begin
        llamadas_maquina.bucle_general:=principal_lasso;
        m6502_0.change_ram_calls(getbyte_lasso,putbyte_lasso);
        if not(roms_load(@memoria,lasso_rom)) then exit;
        m6502_1.change_ram_calls(getbyte_sndlasso,putbyte_sndlasso);
        if not(roms_load(@mem_snd,lasso_snd)) then exit;
        //Sub CPU
        m6502_2:=cpu_m6502.create(11289000 div 16,256,TCPU_M6502);
        m6502_2.change_ram_calls(getbyte_sublasso,putbyte_sublasso);
        if not(roms_load(@mem_misc,lasso_sub)) then exit;
        //Cargar chars
        if not(roms_load(@memoria_temp,lasso_char)) then exit;
        copymemory(@memoria_temp[0],@memoria_temp[$4000],$800);
        copymemory(@memoria_temp[$1000],@memoria_temp[$4800],$800);
        copymemory(@memoria_temp[$800],@memoria_temp[$5000],$800);
        copymemory(@memoria_temp[$1800],@memoria_temp[$5800],$800);
        copymemory(@memoria_temp[$2000],@memoria_temp[$6000],$800);
        copymemory(@memoria_temp[$3000],@memoria_temp[$6800],$800);
        copymemory(@memoria_temp[$2800],@memoria_temp[$7000],$800);
        copymemory(@memoria_temp[$3800],@memoria_temp[$7800],$800);
        convert_char_sprites;
        //DIP
        marcade.dswa:=$81;
        marcade.dswb:=0;
        marcade.dswa_val2:=@lasso_dip_a;
        marcade.dswb_val2:=@lasso_dip_b;
        //poner la paleta
        if not(roms_load(@memoria_temp,lasso_pal)) then exit;
      end;
  391:begin
        llamadas_maquina.bucle_general:=principal_chameleon;
        m6502_0.change_ram_calls(getbyte_chameleo,putbyte_chameleo);
        if not(roms_load(@memoria,chameleo_rom)) then exit;
        m6502_1.change_ram_calls(getbyte_sndchameleo,putbyte_sndchameleo);
        if not(roms_load(@mem_snd,chameleo_snd)) then exit;
        //Cargar chars
        if not(roms_load(@memoria_temp,chameleo_char)) then exit;
        copymemory(@memoria_temp[$800],@memoria_temp[$4000],$800);
        copymemory(@memoria_temp[$1800],@memoria_temp[$4800],$800);
        copymemory(@memoria_temp[0],@memoria_temp[$5000],$800);
        copymemory(@memoria_temp[$1000],@memoria_temp[$5800],$800);
        copymemory(@memoria_temp[$2800],@memoria_temp[$6000],$800);
        copymemory(@memoria_temp[$3800],@memoria_temp[$6800],$800);
        copymemory(@memoria_temp[$2000],@memoria_temp[$7000],$800);
        copymemory(@memoria_temp[$3000],@memoria_temp[$7800],$800);
        convert_char_sprites;
        //DIP
        marcade.dswa:=1;
        marcade.dswb:=0;
        marcade.dswa_val2:=@chameleon_dip_a;
        marcade.dswb_val2:=@chameleon_dip_b;
        //poner la paleta
        if not(roms_load(@memoria_temp,chameleo_pal)) then exit;
      end;
end;
for f:=0 to $3f do colores[f]:=lasso_set_color(memoria_temp[f]);
set_pal(colores,$40);
//final
reset_lasso;
iniciar_lasso:=true;
end;

end.
