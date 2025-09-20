unit bloodbros_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,m68000,main_engine,controls_engine,gfx_engine,ym_3812,oki6295,
     seibu_sound,rom_engine,pal_engine,sound_engine;

function iniciar_bloodbros:boolean;

implementation
const
        bloodbros_rom:array[0..3] of tipo_roms=(
        (n:'2.u021.7n';l:$20000;p:1;crc:$204dca6e),(n:'1.u022.8n';l:$20000;p:$0;crc:$ac6719e7),
        (n:'4.u023.7l';l:$20000;p:$40001;crc:$fd951c2c),(n:'3.u024.8l';l:$20000;p:$40000;crc:$18d3c460));
        bloodbros_sound:tipo_roms=(n:'bb_07.u1016.6a';l:$10000;p:0;crc:$411b94e8);
        bloodbros_char:array[0..1] of tipo_roms=(
        (n:'bb_05.u061.6f';l:$10000;p:0;crc:$04ba6d19),(n:'bb_06.u063.6d';l:$10000;p:$10000;crc:$7092e35b));
        bloodbros_tiles:tipo_roms=(n:'blood_bros_bk__=c=1990_tad_corp.u064.4d';l:$100000;p:0;crc:$1aa87ee6);
        bloodbros_sprites:tipo_roms=(n:'blood_bros_obj__=c=1990_tad_corp.u078.2n';l:$100000;p:0;crc:$d27c3952);
        bloodbros_oki:tipo_roms=(n:'bb_08.u095.5a';l:$20000;p:0;crc:$deb1b975);
        bloodbros_dip:array [0..7] of def_dip=(
        (mask:$1e;name:'Coinage';number:16;dip:((dip_val:$14;dip_name:'6C 1C'),(dip_val:$16;dip_name:'5C 1C'),(dip_val:$18;dip_name:'4C 1C'),(dip_val:$1a;dip_name:'3C 1C'),(dip_val:$2;dip_name:'8C 3C'),(dip_val:$1c;dip_name:'2C 1C'),(dip_val:$4;dip_name:'5C 3C'),(dip_val:$6;dip_name:'3C 2C'),(dip_val:$1e;dip_name:'1C 1C'),(dip_val:$8;dip_name:'2C 3C'),(dip_val:$12;dip_name:'1C 2C'),(dip_val:$10;dip_name:'1C 3C'),(dip_val:$e;dip_name:'1C 4C'),(dip_val:$c;dip_name:'1C 5C'),(dip_val:$a;dip_name:'1C 6C'),(dip_val:$0;dip_name:'Free Play'))),
        (mask:$20;name:'Start Coin';number:2;dip:((dip_val:$20;dip_name:'Normal'),(dip_val:$0;dip_name:'X2'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$300;name:'Lives';number:4;dip:((dip_val:$0;dip_name:'1'),(dip_val:$200;dip_name:'2'),(dip_val:$300;dip_name:'3'),(dip_val:$100;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c00;name:'Bonus Life';number:4;dip:((dip_val:$c00;dip_name:'300k 500k+'),(dip_val:$800;dip_name:'500k+'),(dip_val:$400;dip_name:'500k'),(dip_val:$0;dip_name:'None'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$3000;name:'Difficulty';number:4;dip:((dip_val:$2000;dip_name:'Easy'),(dip_val:$3000;dip_name:'Normal'),(dip_val:$1000;dip_name:'Hard'),(dip_val:$0;dip_name:'Very Hard'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4000;name:'Allow Continue';number:2;dip:((dip_val:$0;dip_name:'No'),(dip_val:$4000;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8000;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$8000;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        skysmash_rom:array[0..3] of tipo_roms=(
        (n:'rom5';l:$20000;p:0;crc:$867f9897),(n:'rom6';l:$20000;p:$1;crc:$e9c1d308),
        (n:'rom7';l:$20000;p:$40000;crc:$d209db4d),(n:'rom8';l:$20000;p:$40001;crc:$d3646728));
        skysmash_sound:tipo_roms=(n:'rom2';l:$10000;p:0;crc:$75b194cf);
        skysmash_char:array[0..1] of tipo_roms=(
        (n:'rom3';l:$10000;p:0;crc:$fbb241be),(n:'rom4';l:$10000;p:$10000;crc:$ad3cde81));
        skysmash_tiles:tipo_roms=(n:'rom9';l:$100000;p:0;crc:$b0a5eecf);
        skysmash_sprites:tipo_roms=(n:'rom10';l:$80000;p:0;crc:$1bbcda5d);
        skysmash_oki:tipo_roms=(n:'rom1';l:$20000;p:0;crc:$e69986f6);
        skysmash_dip:array [0..7] of def_dip=(
        (mask:$1e;name:'Coinage';number:16;dip:((dip_val:$14;dip_name:'6C 1C'),(dip_val:$16;dip_name:'5C 1C'),(dip_val:$18;dip_name:'4C 1C'),(dip_val:$1a;dip_name:'3C 1C'),(dip_val:$2;dip_name:'8C 3C'),(dip_val:$1c;dip_name:'2C 1C'),(dip_val:$4;dip_name:'5C 3C'),(dip_val:$6;dip_name:'3C 2C'),(dip_val:$1e;dip_name:'1C 1C'),(dip_val:$8;dip_name:'2C 3C'),(dip_val:$12;dip_name:'1C 2C'),(dip_val:$10;dip_name:'1C 3C'),(dip_val:$e;dip_name:'1C 4C'),(dip_val:$c;dip_name:'1C 5C'),(dip_val:$a;dip_name:'1C 6C'),(dip_val:$0;dip_name:'Free Play'))),
        (mask:$20;name:'Start Coin';number:2;dip:((dip_val:$20;dip_name:'Normal'),(dip_val:$0;dip_name:'X2'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$300;name:'Lives';number:4;dip:((dip_val:$200;dip_name:'2'),(dip_val:$300;dip_name:'3'),(dip_val:$100;dip_name:'5'),(dip_val:$0;dip_name:'Infinite'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c00;name:'Bonus Life';number:4;dip:((dip_val:$c00;dip_name:'120k 200k+'),(dip_val:$800;dip_name:'200k+'),(dip_val:$400;dip_name:'250k+'),(dip_val:$0;dip_name:'200k'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$3000;name:'Difficulty';number:4;dip:((dip_val:$0;dip_name:'Easy'),(dip_val:$3000;dip_name:'Normal'),(dip_val:$2000;dip_name:'Hard'),(dip_val:$1000;dip_name:'Very Hard'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4000;name:'Allow Continue';number:2;dip:((dip_val:$0;dip_name:'No'),(dip_val:$4000;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8000;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$8000;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 rom:array[0..$3ffff] of word;
 ram:array[0..$7fff] of word;
 sound_rom:array[0..1,0..$7fff] of byte;
 snd_bank,irq_level:byte;
 crt_ram:array[0..$27] of word;
 read_crt:function(direccion:word):word;
 write_crt:procedure(direccion,valor:word);

procedure draw_sprites(prio:byte);
var
  f,color,nchar,x,y,atrib:word;
  width,height,w,h,pos_x,pos_y:byte;
  flipx,flipy:boolean;
  inc_x,inc_y:integer;
begin
for f:=$1ff downto 0 do begin
    atrib:=ram[$5800+(f*4)];
		if (atrib and $8000)<>0 then continue;
    if ((atrib and $0800) shr 11)<>prio then continue;
    width:=(atrib shr 7) and 7;
		height:=(atrib shr 4) and 7;
    x:=ram[$5802+(f*4)] and $1ff;
    y:=ram[$5803+(f*4)] and $1ff;
    if (atrib and $2000)<>0 then begin
      flipx:=true;
      inc_x:=-16;
      pos_x:=width*16;
    end else begin
      flipx:=false;
      inc_x:=16;
      pos_x:=0;
    end;
    if (atrib and $4000)<>0 then begin
      flipy:=true;
      inc_y:=-16;
    end else begin
      flipy:=false;
      inc_y:=16;
    end;
    color:=(atrib and $f) shl 4;
    nchar:=ram[$5801+(f*4)] and $1fff;
    for w:=0 to width do begin
      pos_y:=height*16*byte(flipy);
      for h:=0 to height do begin
        put_gfx_sprite_diff(nchar,color,flipx,flipy,2,pos_x,pos_y);
        nchar:=nchar+1;
        pos_y:=pos_y+inc_y;
      end;
      pos_x:=pos_x+inc_x;
    end;
    actualiza_gfx_sprite_size(x,y,4,16*(width+1),16*(height+1));
end;
end;

procedure update_video_bloodbros;
var
  f,nchar,atrib:word;
  color,x,y:byte;
begin
for f:=0 to $3ff do begin //Background
  atrib:=ram[$6c00+f];
  color:=atrib shr 12;
  if (gfx[0].buffer[f] or buffer_color[color+$20]) then begin
    x:=f mod 32;
    y:=f div 32;
    nchar:=atrib and $fff;
    put_gfx_trans(x*8,y*8,nchar,(color shl 4)+$700,1,0);
    gfx[0].buffer[f]:=false;
  end;
end;
for f:=0 to $1ff do begin //Foreground 1+2
  x:=f mod 32;
  y:=f div 32;
  atrib:=ram[$6000+f];
  color:=atrib shr 12;
  if (gfx[1].buffer[f] or buffer_color[color]) then begin
    nchar:=atrib and $fff;
    put_gfx(x*16,y*16,nchar,(color shl 4)+$400,2,1);
    gfx[1].buffer[f]:=false;
  end;
  atrib:=ram[$6800+f];
  color:=atrib shr 12;
  if (gfx[1].buffer[f+$200] or buffer_color[color+$10]) then begin
    nchar:=(atrib and $fff)+$1000;
    put_gfx_trans(x*16,y*16,nchar,(color shl 4)+$500,3,1);
    gfx[1].buffer[f+$200]:=false;
  end;
end;
if (crt_ram[$e] and 1)=0 then scroll_x_y(2,4,crt_ram[$10],crt_ram[$11])
  else fill_full_screen(4,$800);
if (crt_ram[$e] and $10)=0 then draw_sprites(1);
if (crt_ram[$e] and 2)=0 then scroll_x_y(3,4,crt_ram[$12],crt_ram[$13]);
if (crt_ram[$e] and $10)=0 then draw_sprites(0);
if (crt_ram[$e] and 8)=0 then actualiza_trozo(0,0,256,256,1,0,0,256,256,4);
actualiza_trozo_final(0,16,256,224,4);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure eventos_bloodbros;
begin
if event.arcade then begin
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fffe) else marcade.in0:=(marcade.in0 or $0001);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fffd) else marcade.in0:=(marcade.in0 or $0002);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fffb) else marcade.in0:=(marcade.in0 or $0004);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fff7) else marcade.in0:=(marcade.in0 or $0008);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ffef) else marcade.in0:=(marcade.in0 or $0010);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $ffdf) else marcade.in0:=(marcade.in0 or $0020);
  if arcade_input.but2[0] then marcade.in0:=(marcade.in0 and $ffbf) else marcade.in0:=(marcade.in0 or $0040);
  if arcade_input.up[1] then marcade.in0:=(marcade.in0 and $feff) else marcade.in0:=(marcade.in0 or $0100);
  if arcade_input.down[1] then marcade.in0:=(marcade.in0 and $fdff) else marcade.in0:=(marcade.in0 or $0200);
  if arcade_input.left[1] then marcade.in0:=(marcade.in0 and $fbff) else marcade.in0:=(marcade.in0 or $0400);
  if arcade_input.right[1] then marcade.in0:=(marcade.in0 and $f7ff) else marcade.in0:=(marcade.in0 or $0800);
  if arcade_input.but0[1] then marcade.in0:=(marcade.in0 and $efff) else marcade.in0:=(marcade.in0 or $1000);
  if arcade_input.but1[1] then marcade.in0:=(marcade.in0 and $dfff) else marcade.in0:=(marcade.in0 or $2000);
  if arcade_input.but2[1] then marcade.in0:=(marcade.in0 and $bfff) else marcade.in0:=(marcade.in0 or $4000);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $fffe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $ffef) else marcade.in1:=(marcade.in1 or $10);
  //COINS por la CPU de sonido!!
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 or $1) else marcade.in2:=(marcade.in2 and $fe);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 or $2) else marcade.in2:=(marcade.in2 and $fd);
end;
end;

procedure bloodbros_principal;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
///PRECAUCION EL Z80 ES EL 1, PORQUE EL SISTEMA DE SONIDO LO COGE ASI, HAY QUE CAMBIARLO...
frame_s:=z80_1.tframes;
while EmuStatus=EsRuning do begin
   for f:=0 to $ff do begin
     //Main CPU
     m68000_0.run(frame_m);
     frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
     //Sound CPU
     z80_1.run(frame_s);
     frame_s:=frame_s+z80_1.tframes-z80_1.contador;
     if f=239 then begin
        m68000_0.irq[irq_level]:=HOLD_LINE;
        update_video_bloodbros;
     end;
   end;
   eventos_bloodbros;
   video_sync;
end;
end;

function bloodbros_read_crt(direccion:word):word;
begin
  bloodbros_read_crt:=crt_ram[(direccion and $7f) shr 1];
end;

procedure bloodbros_write_crt(direccion,valor:word);
begin
  crt_ram[(direccion and $7f) shr 1]:=valor;
end;

function skysmash_read_crt(direccion:word):word;
var
  tempw:word;
begin
  direccion:=(direccion and $7f) shr 1;
  tempw:=(direccion and $ffe7) or ((direccion and $10) shr 1) or ((direccion and 8) shl 1);
  skysmash_read_crt:=crt_ram[tempw];
end;

procedure skysmash_write_crt(direccion,valor:word);
var
  tempw:word;
begin
  direccion:=(direccion and $7f) shr 1;
  tempw:=(direccion and $ffe7) or ((direccion and $10) shr 1) or ((direccion and 8) shl 1);
  crt_ram[tempw]:=valor;
end;

function bloodbros_getword(direccion:dword):word;
begin
case direccion of
    $0..$7ffff:bloodbros_getword:=rom[direccion shr 1];
    $80000..$8e7ff,$8f800..$8ffff:bloodbros_getword:=ram[(direccion and $ffff) shr 1];
    $8e800..$8f7ff:bloodbros_getword:=buffer_paleta[(direccion-$8e800) shr 1];
    $a0000..$a000d:bloodbros_getword:=seibu_get(direccion and $e);
    $c0000..$c004f:bloodbros_getword:=read_crt(direccion);
    $e0000:bloodbros_getword:=marcade.dswa;
    $e0002:bloodbros_getword:=marcade.in0;
    $e0004:bloodbros_getword:=marcade.in1;
end;
end;

procedure cambiar_color(tmp_color,numero:word);inline;
var
  color:tcolor;
begin
  color.b:=pal4bit(tmp_color shr 8);
  color.g:=pal4bit(tmp_color shr 4);
  color.r:=pal4bit(tmp_color);
  set_pal_color(color,numero);
  case numero of
    $400..$4ff:buffer_color[(numero shr 4) and $f]:=true;
    $500..$5ff:buffer_color[((numero shr 4) and $f)+$10]:=true;
    $700..$7ff:buffer_color[((numero shr 4) and $f)+$20]:=true;
  end;
end;

procedure bloodbros_putword(direccion:dword;valor:word);
begin
case direccion of
  0..$7ffff:; //ROM
  $80000..$8bfff,$8c400..$8cfff,$8d400..$8d7ff,$8e000..$8e7ff,$8f800..$8ffff:ram[(direccion and $ffff) shr 1]:=valor;
  $8c000..$8c3ff:if ram[(direccion and $ffff) shr 1]<>valor then begin
                      ram[(direccion and $ffff) shr 1]:=valor;
                      gfx[1].buffer[(direccion and $3ff) shr 1]:=true;
                   end;
  $8d000..$8d3ff:if ram[(direccion and $ffff) shr 1]<>valor then begin
                      ram[(direccion and $ffff) shr 1]:=valor;
                      gfx[1].buffer[((direccion and $3ff) shr 1)+$200]:=true;
                   end;
  $8d800..$8dfff:if ram[(direccion and $ffff) shr 1]<>valor then begin
                      ram[(direccion and $ffff) shr 1]:=valor;
                      gfx[0].buffer[(direccion and $7ff) shr 1]:=true;
                   end;
  $8e800..$8f7ff:if buffer_paleta[(direccion-$8e800) shr 1]<>valor then begin
                    buffer_paleta[(direccion-$8e800) shr 1]:=valor;
                    cambiar_color(valor,((direccion-$8e800) shr 1));
                 end;
  $a0000..$a000d:seibu_put(direccion and $e,valor);
  $c0000..$c004f:write_crt(direccion,valor);
end;
end;

function bloodbros_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$1fff:bloodbros_snd_getbyte:=mem_snd[direccion];
  $2000..$27ff:bloodbros_snd_getbyte:=mem_snd[direccion];
  $4008:bloodbros_snd_getbyte:=ym3812_0.status;
  $4010:bloodbros_snd_getbyte:=sound_latch[0];
  $4011:bloodbros_snd_getbyte:=sound_latch[1];
  $4012:bloodbros_snd_getbyte:=byte(sub2main_pending);
  $4013:bloodbros_snd_getbyte:=marcade.in2;
  $6000:bloodbros_snd_getbyte:=oki_6295_0.read;
  $8000..$ffff:bloodbros_snd_getbyte:=sound_rom[snd_bank,direccion and $7fff];
end;
end;

procedure bloodbros_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$1fff,$8000..$ffff:; //ROM
  $2000..$27ff:mem_snd[direccion]:=valor;
  $4000:begin
          main2sub_pending:=false;
        	sub2main_pending:=true;
        end;
  $4001:;//seibu_update_irq_lines(RESET_ASSERT);
  $4002:;
  $4003:seibu_update_irq_lines(RST18_CLEAR);
  $4007:snd_bank:=valor and 1;
  $4008:ym3812_0.control(valor);
  $4009:ym3812_0.write(valor);
  $4018:sub2main[0]:=valor;
  $4019:sub2main[1]:=valor;
  $6000:oki_6295_0.write(valor);
end;
end;

procedure bloodbros_sound_update;
begin
  ym3812_0.update;
  oki_6295_0.update;
end;

procedure snd_irq(irqstate:byte);
begin
  if irqstate=0 then seibu_update_irq_lines(RST10_CLEAR)
    else seibu_update_irq_lines(RST10_ASSERT);
end;

//Main
procedure reset_bloodbros;
begin
 m68000_0.reset;
 z80_1.reset;
 ym3812_0.reset;
 oki_6295_0.reset;
 seibu_reset;
 reset_audio;
 marcade.in0:=$ffff;
 marcade.in1:=$ffff;
 marcade.in2:=0;
 snd_bank:=0;
end;

function iniciar_bloodbros:boolean;
const
  pc_x:array[0..7] of dword=(3, 2, 1, 0, 8+3, 8+2, 8+1, 8+0);
  pc_y:array[0..7] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16);
  ps_x:array[0..15] of dword=(3, 2, 1, 0, 16+3, 16+2, 16+1, 16+0,
				3+32*16, 2+32*16, 1+32*16, 0+32*16, 16+3+32*16, 16+2+32*16, 16+1+32*16, 16+0+32*16);
  ps_y:array[0..15] of dword=(0*16, 2*16, 4*16, 6*16, 8*16, 10*16, 12*16, 14*16,
			16*16, 18*16, 20*16, 22*16, 24*16, 26*16, 28*16, 30*16);
var
   memoria_temp:pbyte;
procedure char_convert;
begin
  init_gfx(0,8,8,$1000);
  gfx[0].trans[15]:=true;
  gfx_set_desc_data(4,0,16*8,0,4,$1000*16*8,($1000*16*8)+4);
  convert_gfx(0,0,memoria_temp,@pc_x,@pc_y,false,false);
end;
procedure tiles_convert(num:byte;cant:word);
begin
  init_gfx(num,16,16,cant);
  gfx[num].trans[15]:=true;
  gfx_set_desc_data(4,0,128*8,8,12,0,4);
  convert_gfx(num,0,memoria_temp,@ps_x,@ps_y,false,false);
end;
begin
llamadas_maquina.bucle_general:=bloodbros_principal;
llamadas_maquina.reset:=reset_bloodbros;
llamadas_maquina.fps_max:=59.389999;
iniciar_bloodbros:=false;
iniciar_audio(false);
screen_init(1,256,256,true);
screen_init(2,512,256,true);
screen_mod_scroll(2,512,512,511,256,256,255);
screen_init(3,512,256,true);
screen_mod_scroll(3,512,512,511,256,256,255);
screen_init(4,512,512,false,true);
if main_vars.tipo_maquina=286 then main_screen.rol90_screen:=true;
iniciar_video(256,224);
getmem(memoria_temp,$100000);
//Main CPU
m68000_0:=cpu_m68000.create(20000000 div 2,256);
m68000_0.change_ram16_calls(bloodbros_getword,bloodbros_putword);
//Sound CPU
z80_1:=cpu_z80.create(7159090 div 2,256);
z80_1.init_sound(bloodbros_sound_update);
z80_1.change_ram_calls(bloodbros_snd_getbyte,bloodbros_snd_putbyte);
//Sound Chips
ym3812_0:=ym3812_chip.create(YM3812_FM,7159090 div 2);
ym3812_0.change_irq_calls(snd_irq);
oki_6295_0:=snd_okim6295.Create(12000000 div 12,OKIM6295_PIN7_HIGH);
case main_vars.tipo_maquina of
  285:begin //Blood Bros
        read_crt:=bloodbros_read_crt;
        write_crt:=bloodbros_write_crt;
        irq_level:=4;
        //Main CPU
        if not(roms_load16w(@rom,bloodbros_rom)) then exit;
        //Sound CPU
        if not(roms_load(memoria_temp,bloodbros_sound)) then exit;
        copymemory(@mem_snd,memoria_temp,$2000);
        copymemory(@sound_rom[0,0],@memoria_temp[$8000],$8000);
        copymemory(@sound_rom[1,0],memoria_temp,$8000);
        //OKI Roms
        if not(roms_load(oki_6295_0.get_rom_addr,bloodbros_oki)) then exit;
        //chars
        if not(roms_load(memoria_temp,bloodbros_char)) then exit;
        char_convert;
        //tiles
        if not(roms_load(memoria_temp,bloodbros_tiles)) then exit;
        tiles_convert(1,$2000);
        //sprites
        if not(roms_load(memoria_temp,bloodbros_sprites)) then exit;
        tiles_convert(2,$2000);
        //DIP
        marcade.dswa:=$ffff;
        marcade.dswa_val:=@bloodbros_dip;
  end;
  286:begin //Sky Smasher
        read_crt:=skysmash_read_crt;
        write_crt:=skysmash_write_crt;
        irq_level:=2;
        //Main CPU
        if not(roms_load16w(@rom,skysmash_rom)) then exit;
        //Sound CPU
        if not(roms_load(memoria_temp,skysmash_sound)) then exit;
        copymemory(@mem_snd,memoria_temp,$2000);
        copymemory(@sound_rom[0,0],@memoria_temp[$8000],$8000);
        copymemory(@sound_rom[1,0],memoria_temp,$8000);
        //OKI Roms
        if not(roms_load(oki_6295_0.get_rom_addr,skysmash_oki)) then exit;
        //chars
        if not(roms_load(memoria_temp,skysmash_char)) then exit;
        char_convert;
        //tiles
        if not(roms_load(memoria_temp,skysmash_tiles)) then exit;
        tiles_convert(1,$2000);
        //sprites
        if not(roms_load(memoria_temp,skysmash_sprites)) then exit;
        tiles_convert(2,$2000);
        //DIP
        marcade.dswa:=$ffff;
        marcade.dswa_val:=@skysmash_dip;
  end;
end;
//final
freemem(memoria_temp);
reset_bloodbros;
iniciar_bloodbros:=true;
end;

end.
