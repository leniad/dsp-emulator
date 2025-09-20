unit unico_hw;
interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m68000,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     sound_engine,ym_3812,oki6295;

function iniciar_unico:boolean;

implementation

const
        burglarx_rom:array[0..1] of tipo_roms=(
        (n:'bx-rom2.pgm';l:$80000;p:0;crc:$f81120c8),(n:'bx-rom3.pgm';l:$80000;p:$1;crc:$080b4e82));
        burglarx_sprites:array[0..7] of tipo_roms=(
        (n:'bx-rom4';l:$80000;p:0;crc:$f74ce31f),(n:'bx-rom10';l:$80000;p:$1;crc:$6f56ca23),
        (n:'bx-rom9';l:$80000;p:$100000;crc:$33f29d79),(n:'bx-rom8';l:$80000;p:$100001;crc:$24367092),
        (n:'bx-rom7';l:$80000;p:$200000;crc:$aff6bdea),(n:'bx-rom6';l:$80000;p:$200001;crc:$246afed2),
        (n:'bx-rom11';l:$80000;p:$300000;crc:$898d176a),(n:'bx-rom5';l:$80000;p:$300001;crc:$fdee1423));
        burglarx_tiles:array[0..7] of tipo_roms=(
        (n:'bx-rom14';l:$80000;p:0;crc:$30413373),(n:'bx-rom18';l:$80000;p:$1;crc:$8e7fc99f),
        (n:'bx-rom19';l:$80000;p:$100000;crc:$d40eabcd),(n:'bx-rom15';l:$80000;p:$100001;crc:$78833c75),
        (n:'bx-rom17';l:$80000;p:$200000;crc:$f169633f),(n:'bx-rom12';l:$80000;p:$200001;crc:$71eb160f),
        (n:'bx-rom13';l:$80000;p:$300000;crc:$da34bbb5),(n:'bx-rom16';l:$80000;p:$300001;crc:$55b28ef9));
        burglarx_oki:tipo_roms=(n:'bx-rom1.snd';l:$80000;p:0;crc:$8ae67138);
        burglarx_dip_a:array [0..3] of def_dip=(
        (mask:$200;name:'Free Play';number:2;dip:((dip_val:$200;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$800;name:'Demo Sounds';number:2;dip:((dip_val:$800;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$e000;name:'Coinage';number:8;dip:((dip_val:$0;dip_name:'5C 1C'),(dip_val:$2000;dip_name:'4C 1C'),(dip_val:$4000;dip_name:'3C 1C'),(dip_val:$6000;dip_name:'2C 1C'),(dip_val:$e000;dip_name:'1C 1C'),(dip_val:$c000;dip_name:'1C 2C'),(dip_val:$a000;dip_name:'1C 3C'),(dip_val:$8000;dip_name:'1C 4C'),(),(),(),(),(),(),(),())),());
        burglarx_dip_b:array [0..4] of def_dip=(
        (mask:$300;name:'Bonus Life';number:4;dip:((dip_val:$200;dip_name:'None'),(dip_val:$300;dip_name:'A'),(dip_val:$100;dip_name:'B'),(dip_val:$0;dip_name:'C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$800;name:'Energy';number:2;dip:((dip_val:$0;dip_name:'2'),(dip_val:$800;dip_name:'3'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$3000;name:'Difficulty';number:4;dip:((dip_val:$2000;dip_name:'Easy'),(dip_val:$3000;dip_name:'Normal'),(dip_val:$1000;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c000;name:'Lives';number:4;dip:((dip_val:$8000;dip_name:'2'),(dip_val:$c000;dip_name:'3'),(dip_val:$4000;dip_name:'4'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),());
        zeropnt_rom:array[0..1] of tipo_roms=(
        (n:'unico_2.rom2';l:$80000;p:0;crc:$1e599509),(n:'unico_3.rom3';l:$80000;p:$1;crc:$588aeef7));
        zeropnt_sprites:array[0..3] of tipo_roms=(
        (n:'unico_zpobj_z01.bin';l:$200000;p:0;crc:$1f2768a3),(n:'unico_zpobj_z02.bin';l:$200000;p:$200000;crc:$de34f33a),
        (n:'unico_zpobj_z03.bin';l:$200000;p:$400000;crc:$d7a657f7),(n:'unico_zpobj_z04.bin';l:$200000;p:$600000;crc:$3aec2f8d));
        zeropnt_tiles:array[0..3] of tipo_roms=(
        (n:'unico_zpscr_z06.bin';l:$200000;p:0;crc:$e1e53cf0),(n:'unico_zpscr_z05.bin';l:$200000;p:$200000;crc:$0d7d4850),
        (n:'unico_zpscr_z07.bin';l:$200000;p:$400000;crc:$bb178f32),(n:'unico_zpscr_z08.bin';l:$200000;p:$600000;crc:$672f02e5));
        zeropnt_oki:tipo_roms=(n:'unico_1.rom1';l:$80000;p:0;crc:$fd2384fa);
        zeropnt_dip_b:array [0..2] of def_dip=(
        (mask:$3000;name:'Difficulty';number:4;dip:((dip_val:$2000;dip_name:'Easy'),(dip_val:$3000;dip_name:'Normal'),(dip_val:$1000;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c000;name:'Lives';number:4;dip:((dip_val:$8000;dip_name:'2'),(dip_val:$c000;dip_name:'3'),(dip_val:$4000;dip_name:'4'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 rom:array[0..$7ffff] of word;
 ram:array[0..$7fff] of word;
 ram2:array[0..$1fff] of word;
 video_ram:array[0..$5fff] of word;
 sprite_ram:array[0..$3ff] of word;
 oki_rom:array[0..1,0..$3ffff] of byte;
 scroll_ram:array[0..$15] of word;
 gr_mask:word;
 eventos_unico:procedure;
 scr_frame:byte;

procedure update_video_unico;
var
  f,x,y,nchar,atrib:word;
  color:byte;
procedure draw_sprites(pri:byte);
var
  f,size:byte;
  x,y,nchar,atrib:word;
  flipx,flipy:boolean;
  startx,endx:word;
  incr:integer;
begin
  for f:=0 to $ff do begin
    atrib:=sprite_ram[(f*4)+3];
    if (pri<>((atrib shr 12) and 3)) then continue;
    x:=sprite_ram[(f*4)+0]-15;
		y:=sprite_ram[(f*4)+1]+2;
		nchar:=sprite_ram[(f*4)+2] and gr_mask;
		flipx:=(atrib and $20)<>0;
		flipy:=(atrib and $40)<>0;
    size:=((atrib shr 8) and $f)+1;
    if flipx then begin
      startx:=x+(size-1)*16;
      endx:=x-16;
      incr:=-16;
    end	else begin
      startx:=x;
      endx:=x+size*16;
      incr:=16;
    end;
    x:=startx;
    while x<>endx do begin
      put_gfx_sprite(nchar,(atrib and $1f) shl 8,flipx,flipy,1);
      actualiza_gfx_sprite(x,y,4,1);
      nchar:=nchar+1;
      x:=x+incr;
    end;
  end;
end;
begin
fill_full_screen(4,$1f00);
for f:=$0 to $fff do begin
  x:=f mod 64;
  y:=f div 64;
  atrib:=video_ram[(f*2)+$4001];
  color:=atrib and $1f;
  if (gfx[1].buffer[f+$2000] or (buffer_color[color])) then begin
    nchar:=video_ram[$4000+(f*2)] and gr_mask;
    put_gfx_trans_flip(x*16,y*16,nchar,color shl 8,1,0,(atrib and $20)<>0,(atrib and $40)<>0);
    gfx[1].buffer[f+$2000]:=false;
  end;
  atrib:=video_ram[(f*2)+1];
  color:=atrib and $1f;
  if (gfx[1].buffer[f] or (buffer_color[color])) then begin
    nchar:=video_ram[f*2] and gr_mask;
    put_gfx_trans_flip(x*16,y*16,nchar,color shl 8,2,0,(atrib and $20)<>0,(atrib and $40)<>0);
    gfx[1].buffer[f]:=false;
  end;
  atrib:=video_ram[(f*2)+$2001];
  color:=atrib and $1f;
  if (gfx[1].buffer[f+$1000] or (buffer_color[color])) then begin
    nchar:=video_ram[$2000+(f*2)] and gr_mask;
    put_gfx_trans_flip(x*16,y*16,nchar,color shl 8,3,0,(atrib and $20)<>0,(atrib and $40)<>0);
    gfx[1].buffer[f+$1000]:=false;
  end;
end;
draw_sprites(0);
scroll_x_y(1,4,scroll_ram[0]+2,scroll_ram[1]);
draw_sprites(2);
scroll_x_y(2,4,scroll_ram[5]+2,scroll_ram[$a]);
draw_sprites(1);
scroll_x_y(3,4,scroll_ram[4]+2,scroll_ram[2]);
draw_sprites(3);
actualiza_trozo_final(48,16,384,224,4);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
end;

procedure eventos_burglarx;
begin
if event.arcade then begin
  //P1+P2
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fffe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fffd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fffb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fff7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ffef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $ffdf) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.but2[0] then marcade.in0:=(marcade.in0 and $ffbf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $feff) else marcade.in0:=(marcade.in0 or $100);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fdff) else marcade.in0:=(marcade.in0 or $200);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fbff) else marcade.in0:=(marcade.in0 or $400);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $f7ff) else marcade.in0:=(marcade.in0 or $800);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $efff) else marcade.in0:=(marcade.in0 or $1000);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $dfff) else marcade.in0:=(marcade.in0 or $2000);
  if arcade_input.but2[0] then marcade.in0:=(marcade.in0 and $bfff) else marcade.in0:=(marcade.in0 or $4000);
  //SYSTEM
  if arcade_input.coin[0] then marcade.in1:=(marcade.in1 and $fffe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.coin[1] then marcade.in1:=(marcade.in1 and $fffd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $ffef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $ffdf) else marcade.in1:=(marcade.in1 or $20);
end;
end;

procedure eventos_zeropoint;
begin
if event.arcade then begin
  //SYSTEM
  if arcade_input.coin[0] then marcade.in1:=(marcade.in1 or 1) else marcade.in1:=(marcade.in1 and $fffe);
  if arcade_input.coin[1] then marcade.in1:=(marcade.in1 or 2) else marcade.in1:=(marcade.in1 and $fffd);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 or $10) else marcade.in1:=(marcade.in1 and $ffef);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 or $20) else  marcade.in1:=(marcade.in1 and $ffdf);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $feff) else marcade.in1:=(marcade.in1 or $100);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $fdff) else marcade.in1:=(marcade.in1 or $200);
end;
end;

procedure unico_principal;
var
  frame_m:single;
  f:byte;
begin
init_controls(true,false,false,true);
frame_m:=m68000_0.tframes;
while EmuStatus=EsRunning do begin
 for f:=0 to 223 do begin
  m68000_0.run(frame_m);
  frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
  if f=0 then begin
    update_video_unico;
    m68000_0.irq[2]:=HOLD_LINE;
  end;
 end;
 scr_frame:=scr_frame xor 1;
 eventos_unico;
 video_sync;
end;
end;

function burglarx_getword(direccion:dword):word;
begin
case direccion of
    0..$fffff:burglarx_getword:=rom[direccion shr 1];
    $800000:burglarx_getword:=marcade.in0;
    $800018:burglarx_getword:=marcade.in1;
    $80001a:burglarx_getword:=marcade.dswa;
    $80001c:burglarx_getword:=marcade.dswb;
    $80010c..$800121:burglarx_getword:=scroll_ram[(direccion-$80010c) shr 1];
	  $800188:burglarx_getword:=oki_6295_0.read;
	  $80018c:burglarx_getword:=ym3812_0.status shl 8;
    $904000..$90ffff:burglarx_getword:=video_ram[(direccion-$904000) shr 1];
	  $920000..$923fff:burglarx_getword:=ram2[(direccion and $3fff) shr 1];
	  $930000..$9307ff:burglarx_getword:=sprite_ram[(direccion and $7ff) shr 1];
	  $940000..$947fff:burglarx_getword:=buffer_paleta[(direccion and $7fff) shr 1];
    $ff0000..$ffffff:burglarx_getword:=ram[(direccion and $ffff) shr 1];
end;
end;

procedure burglarx_putword(direccion:dword;valor:word);
procedure cambiar_color(dir:word);
var
  tmp_color:dword;
  color:tcolor;
begin
  tmp_color:=(buffer_paleta[dir or 1] shl 16)+buffer_paleta[dir or 0];
  color.r:=(tmp_color shr 8) and $fc;
  color.r:=color.r or (color.r shr 6);
  color.g:=(tmp_color shr 0) and $fc;
  color.g:=color.g or (color.g shr 6);
  color.b:=(tmp_color shr 24) and $fc;
  color.b:=color.b or (color.b shr 6);
  dir:=dir shr 1;
  set_pal_color(color,dir);
  buffer_color[dir shr 8]:=true;
end;
begin
case direccion of
    0..$fffff:;
    $800030,$8001e0:;
    $80010c..$800121:scroll_ram[(direccion-$80010c) shr 1]:=valor;
	  $800188:oki_6295_0.write(valor);
    $80018a:ym3812_0.write(valor shr 8);
	  $80018c:ym3812_0.control(valor shr 8);
	  $80018e:copymemory(oki_6295_0.get_rom_addr,@oki_rom[valor and 1,0],$40000);
    $904000..$90ffff:if video_ram[(direccion-$904000) shr 1]<>valor then begin
                        video_ram[(direccion-$904000) shr 1]:=valor;
                        gfx[1].buffer[(direccion-$904000) shr 2]:=true;
                     end;
	  $920000..$923fff:ram2[(direccion and $3fff) shr 1]:=valor;
	  $930000..$9307ff:sprite_ram[(direccion and $7ff) shr 1]:=valor;
	  $940000..$947fff:if buffer_paleta[(direccion and $7fff) shr 1]<>valor then begin
                        buffer_paleta[(direccion and $7fff) shr 1]:=valor;
                        cambiar_color((direccion and $7ffc) shr 1);
                     end;
    $ff0000..$ffffff:ram[(direccion and $ffff) shr 1]:=valor;
  end;
end;

//Zero Point
function zeropnt_getword(direccion:dword):word;
begin
case direccion of
    0..$fffff:zeropnt_getword:=rom[direccion shr 1];
    //Para que funcione bien, tengo que meterle la pistola por las dos entradas de los players...
    //Ademas tengo que hacer que tiemble un poco para que funcione el disparo ¿?
    $800170:zeropnt_getword:=($80 xor scr_frame) shl 8; //P2 Y
    $800174:zeropnt_getword:=($80 xor scr_frame) shl 8; //P2 X
    $800178:zeropnt_getword:=(((raton.y+24) and $ff) xor scr_frame) shl 8; //P1 Y
    $80017c:zeropnt_getword:=(((trunc((raton.x+52)*0.666667)) and $ff) xor scr_frame) shl 8; //P1 X
    $ef0000..$efffff:zeropnt_getword:=ram[(direccion and $ffff) shr 1];
    else zeropnt_getword:=burglarx_getword(direccion);
end;
end;

procedure zeropnt_putword(direccion:dword;valor:word);
var
  ptemp:pbyte;
begin
case direccion of
    0..$fffff:;
	  $80018e:begin
              ptemp:=oki_6295_0.get_rom_addr;
              copymemory(@ptemp[$20000],@oki_rom[valor and 1,0],$20000);
            end;
    $ef0000..$efffff:ram[(direccion and $ffff) shr 1]:=valor;
    else burglarx_putword(direccion,valor);
  end;
end;

procedure unico_sound_update;
begin
  ym3812_0.update;
  oki_6295_0.update;
end;

//Main
procedure reset_unico;
begin
 m68000_0.reset;
 ym3812_0.reset;
 oki_6295_0.reset;
 reset_video;
 reset_audio;
 scr_frame:=0;
 marcade.in0:=$ffff;
 case main_vars.tipo_maquina of
    380:marcade.in1:=$ffff;
    381:marcade.in1:=$ff00;
 end;
end;

function iniciar_unico:boolean;
var
  ptemp:pbyte;
const
  pt_x:array[0..15] of dword=(0,1,2,3,4,5,6,7,16,17,18,19,20,21,22,23);
  pt_y:array[0..15] of dword=(0*16*2, 1*16*2, 2*16*2, 3*16*2, 4*16*2, 5*16*2, 6*16*2, 7*16*2,
		8*16*2, 9*16*2, 10*16*2, 11*16*2, 12*16*2, 13*16*2, 14*16*2, 15*16*2);
procedure convert_graph(gfxn:byte;num:word);
begin
  init_gfx(gfxn,16,16,num);
  gfx[gfxn].trans[0]:=true;
  gfx_set_desc_data(8,0,16*16*2,$c0*num*8+8,$c0*num*8+0,$80*num*8+8,$80*num*8+0,$40*num*8+8,$40*num*8+0,8,0);
  convert_gfx(gfxn,0,ptemp,@pt_x,@pt_y,false,false,true);
end;
begin
llamadas_maquina.bucle_general:=unico_principal;
llamadas_maquina.reset:=reset_unico;
iniciar_unico:=false;
iniciar_audio(true);
screen_init(1,1024,1024,true);
screen_mod_scroll(1,1024,512,1023,1024,256,1023);
screen_init(2,1024,1024,true);
screen_mod_scroll(2,1024,512,1023,1024,256,1023);
screen_init(3,1024,1024,true);
screen_mod_scroll(3,1024,512,1023,1024,256,1023);
screen_init(4,1024,1024,false,true);
iniciar_video(384,224);
//Main CPU
m68000_0:=cpu_m68000.create(16000000,224);
m68000_0.init_sound(unico_sound_update);
//Sound Chips
ym3812_0:=ym3812_chip.create(YM3812_FM,14318181 div 4,1);
oki_6295_0:=snd_okim6295.Create(1000000,OKIM6295_PIN7_HIGH);
case main_vars.tipo_maquina of
  380:begin //BurglarX
      //cargar roms
      m68000_0.change_ram16_calls(burglarx_getword,burglarx_putword);
      if not(roms_load16w(@rom,burglarx_rom)) then exit;
      if not(roms_load(@oki_rom[0,0],burglarx_oki)) then exit;
      copymemory(oki_6295_0.get_rom_addr,@oki_rom[0,0],$40000);
      //convertir tiles
      getmem(ptemp,$400000);
      if not(roms_load16b(ptemp,burglarx_tiles)) then exit;
      convert_graph(0,$4000);
      //convertir sprites
      if not(roms_load16b(ptemp,burglarx_sprites)) then exit;
      convert_graph(1,$4000);
      freemem(ptemp);
      gr_mask:=$3fff;
      eventos_unico:=eventos_burglarx;
      //DIP
      marcade.dswa:=$f7ff;
      marcade.dswa_val:=@burglarx_dip_a;
      marcade.dswb:=$ffff;
      marcade.dswb_val:=@burglarx_dip_b;
  end;
  381:begin //Zero Point
      //cargar roms
      m68000_0.change_ram16_calls(zeropnt_getword,zeropnt_putword);
      if not(roms_load16w(@rom,zeropnt_rom)) then exit;
      if not(roms_load(@oki_rom[0,0],zeropnt_oki)) then exit;
      copymemory(oki_6295_0.get_rom_addr,@oki_rom[0,0],$40000);
      //convertir tiles
      getmem(ptemp,$800000);
      if not(roms_load(ptemp,zeropnt_tiles)) then exit;
      convert_graph(0,$8000);
      //convertir sprites
      if not(roms_load(ptemp,zeropnt_sprites)) then exit;
      convert_graph(1,$8000);
      freemem(ptemp);
      gr_mask:=$7fff;
      eventos_unico:=eventos_zeropoint;
      show_mouse_cursor;
      //DIP
      marcade.dswa:=$800;
      marcade.dswa_val:=@burglarx_dip_a;
      marcade.dswb:=0;
      marcade.dswb_val:=@zeropnt_dip_b;
  end;
end;
//final
reset_unico;
iniciar_unico:=true;
end;

end.
