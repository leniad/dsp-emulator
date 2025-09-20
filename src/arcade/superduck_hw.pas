unit superduck_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,m68000,main_engine,controls_engine,gfx_engine,rom_engine,
     pal_engine,sound_engine,oki6295;

function iniciar_superduck:boolean;

implementation
const
        superduck_rom:array[0..1] of tipo_roms=(
        (n:'5.u16n';l:$20000;p:0;crc:$837a559a),(n:'6.u16l';l:$20000;p:$1;crc:$508e9905));
        superduck_sound:tipo_roms=(n:'4.su6';l:$8000;p:0;crc:$d75863ea);
        superduck_char:tipo_roms=(n:'3.cu15';l:$8000;p:0;crc:$b1cacca4);
        superduck_bg:array[0..3] of tipo_roms=(
        (n:'11.ul29';l:$20000;p:0;crc:$1b6958a4),(n:'12.ul30';l:$20000;p:$20000;crc:$3e6bd24b),
        (n:'13.ul31';l:$20000;p:$40000;crc:$bff7b7cd),(n:'14.ul32';l:$20000;p:$60000;crc:$97a7310b));
        superduck_fg:array[0..3] of tipo_roms=(
        (n:'7.uu29';l:$20000;p:0;crc:$f3251b20),(n:'8.uu30';l:$20000;p:$20000;crc:$03c60cbd),
        (n:'9.uu31';l:$20000;p:$40000;crc:$9b6d3430),(n:'10.uu32';l:$20000;p:$60000;crc:$beed2616));
        superduck_sprites:array[0..3] of tipo_roms=(
        (n:'15.u1d';l:$20000;p:0;crc:$81bf1f27),(n:'16.u2d';l:$20000;p:1;crc:$9573d6ec),
        (n:'17.u1c';l:$20000;p:2;crc:$21ef14d4),(n:'18.u2c';l:$20000;p:3;crc:$33dd0674));
        superduck_oki:array[0..1] of tipo_roms=(
        (n:'2.su12';l:$20000;p:0;crc:$745d42fb),(n:'1.su13';l:$80000;p:$20000;crc:$7fb1ed42));
        //DIP
        superduck_dip:array [0..5] of def_dip=(
        (mask:$7;name:'Coin A';number:8;dip:((dip_val:$0;dip_name:'5C 1C'),(dip_val:$1;dip_name:'4C 1C'),(dip_val:$2;dip_name:'3C 1C'),(dip_val:$3;dip_name:'2C 1C'),(dip_val:$7;dip_name:'1C 1C'),(dip_val:$6;dip_name:'1C 2C'),(dip_val:$5;dip_name:'1C 3C'),(dip_val:$4;dip_name:'1C 4C'),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$10;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Game Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$20;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Lives';number:4;dip:((dip_val:$c0;dip_name:'2'),(dip_val:$80;dip_name:'3'),(dip_val:$40;dip_name:'4'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4000;name:'Character Test';number:2;dip:((dip_val:$4000;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 scroll_fg_x,scroll_fg_y,scroll_bg_x,scroll_bg_y:word;
 rom:array[0..$1ffff] of word;
 sprite_ram:array[0..$fff] of word;
 txt_ram:array[0..$7ff] of word;
 ram,bg_ram,fg_ram:array[0..$1fff] of word;
 sound_latch:byte;
 oki_rom:array[0..3,0..$1ffff] of byte;

procedure update_video_superduck;
var
  f,nchar,atrib,sx,sy,x,y,pos:word;
  color,atrib2:byte;
begin
for f:=0 to $50 do begin
  x:=f div 9;
  y:=f mod 9;
  //bg
  sx:=x+((scroll_bg_x and $fe0) shr 5);
  sy:=y+((scroll_bg_y and $7e0) shr 5);
  pos:=((((sx and $fff8) div $8)*64)+(((sy xor $3f) and $7)*$8)+(sx and $7)) and $3ff;
	pos:=(pos+((((sy xor $3f) and $fff8) div $8)*$400)) and $1fff;
  atrib:=bg_ram[pos];
  atrib2:=atrib shr 8;
  color:=atrib2 and $f;
  if (gfx[1].buffer[pos] or buffer_color[color+$20]) then begin
    nchar:=(atrib and $ff)+((atrib2 and $c0) shl 2);
    put_gfx_flip(x shl 5,y shl 5,nchar,(color shl 4)+256,2,1,(atrib2 and $20)<>0,(atrib2 and $10)<>0);
    gfx[1].buffer[pos]:=false;
  end;
  //fg
  sx:=x+((scroll_fg_x and $fe0) shr 5);
  sy:=y+((scroll_fg_y and $7e0) shr 5);
  pos:=((((sx and $fff8) div $8)*64)+(((sy xor $3f) and $7)*$8)+(sx and $7)) and $3ff;
	pos:=(pos+((((sy xor $3f) and $fff8) div $8)*$400)) and $1fff;
  atrib:=fg_ram[pos];
  atrib2:=atrib shr 8;
  color:=atrib2 and $f;
  if (gfx[2].buffer[pos] or buffer_color[color+$10]) then begin
    nchar:=(atrib and $ff)+((atrib2 and $c0) shl 2);
    put_gfx_trans_flip(x shl 5,y shl 5,nchar,color shl 4,3,2,(atrib2 and $20)<>0,(atrib2 and $10)<>0);
    gfx[2].buffer[pos]:=false;
  end;
end;
scroll_x_y(2,4,scroll_bg_x and $1f,scroll_bg_y and $1f);
scroll_x_y(3,4,scroll_fg_x and $1f,scroll_fg_y and $1f);
for f:=$3ff downto 0 do begin
    nchar:=buffer_sprites_w[f*4] and $fff;
    atrib:=buffer_sprites_w[(f*4)+1];
  	y:=240-buffer_sprites_w[(f*4)+2];
		x:=buffer_sprites_w[(f*4)+3];
		color:=(atrib and $3c) shl 2;
    put_gfx_sprite(nchar,color+$200,(atrib and 2)<>0,(atrib and 1)<>0,3);
    actualiza_gfx_sprite(x,y,4,3);
end;
//text
for f:=$0 to $3ff do begin
  atrib:=txt_ram[f];
  atrib2:=atrib shr 8;
  color:=atrib2 and $f;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
    x:=f mod 32;
    y:=f div 32;
    nchar:=(atrib and $ff)+((atrib2 and $c0) shl 2)+((atrib2 and $20) shl 5);
    put_gfx_trans_flip(x*8,y*8,nchar and $7ff,(color shl 2)+768,1,0,false,(atrib2 and $10)<>0);
    gfx[0].buffer[f]:=false;
  end;
end;
//front
actualiza_trozo(0,0,256,256,1,0,0,256,256,4);
actualiza_trozo_final(0,16,256,224,4);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
end;

procedure eventos_superduck;
begin
if event.arcade then begin
  //P1
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fffe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fffd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fffb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fff7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ffef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $ffdf) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.but2[0] then marcade.in0:=(marcade.in0 and $ffbf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.but3[0] then marcade.in0:=(marcade.in0 and $ff7f) else marcade.in0:=(marcade.in0 or $80);
  //P2
  if arcade_input.right[1] then marcade.in0:=(marcade.in0 and $feff) else marcade.in0:=(marcade.in0 or $100);
  if arcade_input.left[1] then marcade.in0:=(marcade.in0 and $fdff) else marcade.in0:=(marcade.in0 or $200);
  if arcade_input.down[1] then marcade.in0:=(marcade.in0 and $fbff) else marcade.in0:=(marcade.in0 or $400);
  if arcade_input.up[1] then marcade.in0:=(marcade.in0 and $f7ff) else marcade.in0:=(marcade.in0 or $800);
  if arcade_input.but0[1] then marcade.in0:=(marcade.in0 and $efff) else marcade.in0:=(marcade.in0 or $1000);
  if arcade_input.but1[1] then marcade.in0:=(marcade.in0 and $dfff) else marcade.in0:=(marcade.in0 or $2000);
  if arcade_input.but2[1] then marcade.in0:=(marcade.in0 and $bfff) else marcade.in0:=(marcade.in0 or $4000);
  if arcade_input.but3[1] then marcade.in0:=(marcade.in0 and $7fff) else marcade.in0:=(marcade.in0 or $8000);
  //system
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $feff) else marcade.in1:=(marcade.in1 or $100);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $fdff) else marcade.in1:=(marcade.in1 or $200);
  if arcade_input.coin[0] then marcade.in1:=(marcade.in1 and $bfff) else marcade.in1:=(marcade.in1 or $4000);
  if arcade_input.coin[1] then marcade.in1:=(marcade.in1 and $7fff) else marcade.in1:=(marcade.in1 or $8000);
end;
end;

procedure superduck_principal;
var
  frame_m,frame_s:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
frame_s:=z80_0.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to 261 do begin
    //main
    m68000_0.run(frame_m);
    frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
    //sound
    z80_0.run(frame_s);
    frame_s:=frame_s+z80_0.tframes-z80_0.contador;
    case f of
    245:begin
          marcade.in1:=marcade.in1 and $fbff;
          m68000_0.irq[2]:=HOLD_LINE;
          update_video_superduck;
          copymemory(@buffer_sprites_w,@sprite_ram,$1000*2);
        end;
    261:marcade.in1:=marcade.in1 or $400;
    end;
 end;
 eventos_superduck;
 video_sync;
end;
end;

function superduck_getword(direccion:dword):word;
begin
case direccion of
    0..$3ffff:superduck_getword:=rom[direccion shr 1];
    $fe0000..$fe1fff:superduck_getword:=sprite_ram[(direccion and $1fff) shr 1];
    $fe4000:superduck_getword:=marcade.in0;
    $fe4002:superduck_getword:=marcade.in1;
    $fe4004:superduck_getword:=marcade.dswa;
    $fec000..$fecfff:superduck_getword:=txt_ram[(direccion and $fff) shr 1];
    $ff0000..$ff3fff:superduck_getword:=bg_ram[(direccion and $3fff) shr 1];
    $ff4000..$ff7fff:superduck_getword:=fg_ram[(direccion and $3fff) shr 1];
    $ff8000..$ff87ff:superduck_getword:=buffer_paleta[(direccion and $7ff) shr 1];
    $ffc000..$ffffff:superduck_getword:=ram[(direccion and $3fff) shr 1];
end;
end;

procedure superduck_putword(direccion:dword;valor:word);
var
  tempw:word;
procedure cambiar_color(pos,data:word);
var
  color:tcolor;
begin
  color.r:=pal5bit(((data shr 8) and $f) or ((data shr 10) and $10));
  color.g:=pal5bit(((data shr 4) and $f) or ((data shr 9) and $10));
  color.b:=pal5bit(((data shr 0) and $f) or ((data shr 8) and $10));
  set_pal_color(color,pos);
  case pos of
    0..255:buffer_color[(pos shr 4)+$10]:=true;
    256..511:buffer_color[((pos shr 4) and $f)+$20]:=true;
    768..831:buffer_color[(pos shr 2) and $f]:=true;
  end;
end;
begin
case direccion of
    0..$3ffff:;
    $fe0000..$fe1fff:sprite_ram[(direccion and $1fff) shr 1]:=valor;
    $fe4000:;
    $fe4002:begin
              sound_latch:=valor shr 8;
              z80_0.change_irq(ASSERT_LINE);
            end;
    $fe4004:;
    $fe8000..$fe8007:case ((direccion and $7) shr 1) of
                        0:begin
                            tempw:=valor and $fff;
                            if scroll_bg_x<>tempw then begin
                              if abs((scroll_bg_x and $fe0)-(tempw and $fe0))>31 then fillchar(gfx[1].buffer,$2000,1);
                              scroll_bg_x:=tempw;
                            end;
                          end;
                        1:begin
                            tempw:=1792-(valor and $7ff);
                            if scroll_bg_y<>tempw then begin
                              if abs((scroll_bg_y and $7e0)-(tempw and $7e0))>31 then fillchar(gfx[1].buffer,$2000,1);
                              scroll_bg_y:=tempw;
                            end;
                          end;
                        2:begin
                            tempw:=valor and $fff;
                            if scroll_fg_x<>tempw then begin
                              if abs((scroll_fg_x and $fe0)-(tempw and $fe0))>31 then fillchar(gfx[2].buffer,$2000,1);
                              scroll_fg_x:=tempw;
                            end;
                          end;
                        3:begin
                            tempw:=1792-(valor and $7ff);
                            if scroll_fg_y<>tempw then begin
                              if abs((scroll_fg_y and $7e0)-(tempw and $7e0))>31 then fillchar(gfx[2].buffer,$2000,1);
                              scroll_fg_y:=tempw;
                            end;
                          end;
                     end;
    $fec000..$fecfff:if txt_ram[(direccion and $fff) shr 1]<>valor then begin
                        txt_ram[(direccion and $fff) shr 1]:=valor;
                        gfx[0].buffer[(direccion and $fff) shr 1]:=true;
                     end;
    $ff0000..$ff3fff:if bg_ram[(direccion and $3fff) shr 1]<>valor then begin
                        bg_ram[(direccion and $3fff) shr 1]:=valor;
                        gfx[1].buffer[(direccion and $3fff) shr 1]:=true;
                     end;
    $ff4000..$ff7fff:if fg_ram[(direccion and $3fff) shr 1]<>valor then begin
                        fg_ram[(direccion and $3fff) shr 1]:=valor;
                        gfx[2].buffer[(direccion and $3fff) shr 1]:=true;
                     end;
    $ff8000..$ff87ff:if (buffer_paleta[(direccion and $7ff) shr 1]<>valor) then begin
                        buffer_paleta[(direccion and $7ff) shr 1]:=valor;
                        cambiar_color((direccion and $7ff) shr 1,valor);
                     end;
    $ffc000..$ffffff:ram[(direccion and $3fff) shr 1]:=valor;
end;
end;

function superduck_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$87ff:superduck_snd_getbyte:=mem_snd[direccion];
  $9800:superduck_snd_getbyte:=oki_6295_0.read;
  $a000:begin
          superduck_snd_getbyte:=sound_latch;
          z80_0.change_irq(CLEAR_LINE);
        end;
end;
end;

procedure superduck_snd_putbyte(direccion:word;valor:byte);
var
  ptemp:pbyte;
begin
case direccion of
  0..$7fff:;
  $8000..$87ff:mem_snd[direccion]:=valor;
  $9000:begin
          ptemp:=oki_6295_0.get_rom_addr;
          copymemory(@ptemp[$20000],@oki_rom[valor and 3,0],$20000);
        end;
  $9800:oki_6295_0.write(valor);
end;
end;

procedure superduck_sound_update;
begin
  oki_6295_0.update;
end;

//Main
procedure reset_superduck;
begin
 m68000_0.reset;
 z80_0.reset;
 oki_6295_0.reset;
 reset_audio;
 marcade.in0:=$ffff;
 marcade.in1:=$ffff;
 scroll_fg_x:=0;
 scroll_fg_y:=0;
 scroll_bg_x:=0;
 scroll_bg_y:=0;
 sound_latch:=0;
end;

function iniciar_superduck:boolean;
var
  memoria_temp:pbyte;
  f:byte;
const
  pf_x:array[0..31] of dword=(0,1,2,3, 8,9,10,11,
		(4*2*2*32)+0,(4*2*2*32)+1,(4*2*2*32)+2,(4*2*2*32)+3,(4*2*2*32)+8,(4*2*2*32)+9,(4*2*2*32)+10,(4*2*2*32)+11,
    (4*2*2*64)+0,(4*2*2*64)+1,(4*2*2*64)+2,(4*2*2*64)+3,(4*2*2*64)+8,(4*2*2*64)+9,(4*2*2*64)+10,(4*2*2*64)+11,
    (4*2*2*96)+0,(4*2*2*96)+1,(4*2*2*96)+2,(4*2*2*96)+3,(4*2*2*96)+8,(4*2*2*96)+9,(4*2*2*96)+10,(4*2*2*96)+11);
  pf_y:array[0..31] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16,
		8*16, 9*16, 10*16, 11*16, 12*16, 13*16, 14*16, 15*16,
    16*16,17*16,18*16, 19*16, 20*16,21*16, 22*16, 23*16,
    24*16, 25*16, 26*16, 27*16, 28*16, 29*16, 30*16, 31*16);
  ps_x:array[0..15] of dword=(0, 1, 2, 3, 4, 5, 6, 7,
			8*4*16+0, 8*4*16+1, 8*4*16+2, 8*4*16+3, 8*4*16+4, 8*4*16+5, 8*4*16+6, 8*4*16+7 );
  ps_y:array[0..15] of dword=(0*8*4, 1*8*4, 2*8*4, 3*8*4, 4*8*4, 5*8*4, 6*8*4, 7*8*4,
			8*8*4, 9*8*4, 10*8*4, 11*8*4, 12*8*4, 13*8*4, 14*8*4, 15*8*4 );
begin
llamadas_maquina.bucle_general:=superduck_principal;
llamadas_maquina.reset:=reset_superduck;
llamadas_maquina.fps_max:=6000000/384/262;
iniciar_superduck:=false;
iniciar_audio(false);
//Pantallas
screen_init(1,256,256,true);
screen_init(2,288,288);
screen_mod_scroll(2,288,256,255,288,256,255);
screen_init(3,288,288,true);
screen_mod_scroll(3,288,256,255,288,256,255);
screen_init(4,512,512,false,true);
iniciar_video(256,224);
//Main CPU
m68000_0:=cpu_m68000.create(8000000,262);
m68000_0.change_ram16_calls(superduck_getword,superduck_putword);
//Sound CPU
z80_0:=cpu_z80.create(2000000,262);
z80_0.change_ram_calls(superduck_snd_getbyte,superduck_snd_putbyte);
z80_0.init_sound(superduck_sound_update);
getmem(memoria_temp,$1000000);
//Sound Chips
oki_6295_0:=snd_okim6295.Create(1000000,OKIM6295_PIN7_HIGH);
if not(roms_load(memoria_temp,superduck_oki)) then exit;
copymemory(oki_6295_0.get_rom_addr,memoria_temp,$40000);
for f:=0 to 3 do copymemory(@oki_rom[f,0],@memoria_temp[$20000+(f*$20000)],$20000);
//cargar roms
if not(roms_load16w(@rom,superduck_rom)) then exit;
//cargar sonido
if not(roms_load(@mem_snd,superduck_sound)) then exit;
//convertir chars
if not(roms_load(memoria_temp,superduck_char)) then exit;
init_gfx(0,8,8,$800);
gfx[0].trans[3]:=true;
gfx_set_desc_data(2,0,128,4,0);
convert_gfx(0,0,memoria_temp,@pf_x,@pf_y,false,false);
//convertir bg
if not(roms_load(memoria_temp,superduck_bg)) then exit;
init_gfx(1,32,32,$400);
gfx_set_desc_data(4,0,256*8,($400*8*256)+4,$400*8*256,4,0);
convert_gfx(1,0,memoria_temp,@pf_x,@pf_y,false,false);
//convertir fg
if not(roms_load(memoria_temp,superduck_fg)) then exit;
init_gfx(2,32,32,$400);
gfx[2].trans[$f]:=true;
gfx_set_desc_data(4,0,256*8,($400*8*256)+4,$400*8*256,4,0);
convert_gfx(2,0,memoria_temp,@pf_x,@pf_y,false,false);
//convertir sprites
if not(roms_load32b_b(memoria_temp,superduck_sprites)) then exit;
init_gfx(3,16,16,$1000);
gfx[3].trans[15]:=true;
gfx_set_desc_data(4,0,16*16*4,0,8,16,24);
convert_gfx(3,0,memoria_temp,@ps_x,@ps_y,false,false);
freemem(memoria_temp);
//DIP
marcade.dswa:=$ffbf;
marcade.dswa_val:=@superduck_dip;
//final
reset_superduck;
iniciar_superduck:=true;
end;

end.
