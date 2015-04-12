unit ddragon3_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,m68000,main_engine,controls_engine,gfx_engine,ym_2151,rom_engine,
     pal_engine,sound_engine,oki6295;

procedure Cargar_ddragon3;
procedure ddragon3_principal;
function iniciar_ddragon3:boolean;
procedure reset_ddragon3;
procedure cerrar_ddragon3;
//Main CPU
function ddragon3_getword(direccion:dword;putbyte:boolean):word;
procedure ddragon3_putword(direccion:dword;valor:word);
//Sound CPU
function ddragon3_snd_getbyte(direccion:word):byte;
procedure ddragon3_snd_putbyte(direccion:word;valor:byte);
procedure ddragon3_sound_update;
procedure ym2151_snd_irq(irqstate:byte);

const
        ddragon3_rom:array[0..2] of tipo_roms=(
        (n:'30a14-0.ic78';l:$40000;p:1;crc:$f42fe016),(n:'30a15-0.ic79';l:$20000;p:$0;crc:$ad50e92c),());
        ddragon3_sound:tipo_roms=(n:'30a13-0.ic43';l:$10000;p:0;crc:$1e974d9b);
        ddragon3_oki:tipo_roms=(n:'30j-8.ic73';l:$80000;p:0;crc:$c3ad40f3);
        ddragon3_sprites:array[0..8] of tipo_roms=(
        (n:'30j-3.ic9';l:$80000;p:0;crc:$b3151871),(n:'30a12-0.ic8';l:$10000;p:$80000;crc:$20d64bea),
        (n:'30j-2.ic11';l:$80000;p:$100000;crc:$41c6fb08),(n:'30a11-0.ic10';l:$10000;p:$180000;crc:$785d71b0),
        (n:'30j-1.ic13';l:$80000;p:$200000;crc:$67a6f114),(n:'30a10-0.ic12';l:$10000;p:$280000;crc:$15e43d12),
        (n:'30j-0.ic15';l:$80000;p:$300000;crc:$f15dafbe),(n:'30a9-0.ic14';l:$10000;p:$380000;crc:$5a47e7a4),());
        ddragon3_bg:array[0..4] of tipo_roms=(
        (n:'30j-7.ic4';l:$40000;p:0;crc:$89d58d32),(n:'30j-6.ic5';l:$40000;p:$1;crc:$9bf1538e),
        (n:'30j-5.ic6';l:$40000;p:$80000;crc:$8f671a62),(n:'30j-4.ic7';l:$40000;p:$80001;crc:$0f74ea1c),());
        //DIP
        ddragon3_dip_a:array [0..3] of def_dip=(
        (mask:$7;name:'Coin A';number:8;dip:((dip_val:$0;dip_name:'4C 1C'),(dip_val:$1;dip_name:'3C 1C'),(dip_val:$2;dip_name:'2C 1C'),(dip_val:$7;dip_name:'1C 1C'),(dip_val:$6;dip_name:'1C 2C'),(dip_val:$5;dip_name:'1C 3C'),(dip_val:$4;dip_name:'1C 4C'),(dip_val:$3;dip_name:'1C 5C'),(),(),(),(),(),(),(),())),
        (mask:$38;name:'Coin B';number:8;dip:((dip_val:$0;dip_name:'4C 1C'),(dip_val:$8;dip_name:'3C 1C'),(dip_val:$10;dip_name:'2C 1C'),(dip_val:$38;dip_name:'1C 1C'),(dip_val:$30;dip_name:'1C 2C'),(dip_val:$28;dip_name:'1C 3C'),(dip_val:$20;dip_name:'1C 4C'),(dip_val:$18;dip_name:'1C 5C'),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Flip Screen';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        ddragon3_dip_b:array [0..5] of def_dip=(
        (mask:$3;name:'Difficulty';number:4;dip:((dip_val:$1;dip_name:'Easy'),(dip_val:$3;dip_name:'Normal'),(dip_val:$2;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$4;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Super Techniques';number:2;dip:((dip_val:$8;dip_name:'Normal'),(dip_val:$0;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Time';number:4;dip:((dip_val:$20;dip_name:'+2:30'),(dip_val:$30;dip_name:'Default'),(dip_val:$10;dip_name:'-2:30'),(dip_val:$0;dip_name:'-5:00'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Health for Winning';number:2;dip:((dip_val:$80;dip_name:'No'),(dip_val:$0;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 vreg,bg_tilebase,fg_scrollx,fg_scrolly,bg_scrollx,bg_scrolly:word;
 mem_oki:array[0..$7ffff] of byte;
 rom:array[0..$3ffff] of word;
 fg_ram:array[0..$7ff] of word;
 bg_ram:array[0..$3ff] of word;
 ram:array[0..$1fff] of word;
 sprite_ram:array[0..$7ff] of word;
 sound_latch:byte;

implementation

procedure Cargar_ddragon3;
begin
llamadas_maquina.iniciar:=iniciar_ddragon3;
llamadas_maquina.bucle_general:=ddragon3_principal;
llamadas_maquina.cerrar:=cerrar_ddragon3;
llamadas_maquina.reset:=reset_ddragon3;
llamadas_maquina.fps_max:=57.444853;
end;

function iniciar_ddragon3:boolean;
var
  memoria_temp:pbyte;
const
  pt_x:array[0..15] of dword=(0, 1, 2, 3, 4, 5, 6, 7,
			32*8+0, 32*8+1, 32*8+2, 32*8+3, 32*8+4, 32*8+5, 32*8+6, 32*8+7);
  pt_y:array[0..15] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16,
			16*8, 16*9, 16*10, 16*11, 16*12, 16*13, 16*14, 16*15);
  ps_x:array[0..15] of dword=(0, 1, 2, 3, 4, 5, 6, 7,
		16*8+0, 16*8+1, 16*8+2, 16*8+3, 16*8+4, 16*8+5, 16*8+6, 16*8+7);
  ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
		8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8);
begin
iniciar_ddragon3:=false;
iniciar_audio(false);
//Pantallas
screen_init(1,512,512,true);
screen_mod_scroll(1,512,320,511,512,256,511);
screen_init(2,512,512,true);
screen_mod_scroll(2,512,320,511,512,256,511);
screen_init(3,512,512,false,true);
iniciar_video(320,240);
//Main CPU
main_m68000:=cpu_m68000.create(10000000,272);
main_m68000.change_ram16_calls(ddragon3_getword,ddragon3_putword);
//Sound CPU
snd_z80:=cpu_z80.create(3579545,272);
snd_z80.change_ram_calls(ddragon3_snd_getbyte,ddragon3_snd_putbyte);
snd_z80.init_sound(ddragon3_sound_update);
//Sound Chips
YM2151_Init(0,3579545,nil,ym2151_snd_irq);
oki_6295_0:=snd_okim6295.Create(0,1056000,OKIM6295_PIN7_HIGH);
//Cargar ADPCM ROMS
if not(cargar_roms(@mem_oki[0],@ddragon3_oki,'ddragon3.zip',1)) then exit;
copymemory(oki_6295_0.get_rom_addr,@mem_oki[0],$40000);
//cargar roms
if not(cargar_roms16w(@rom[0],@ddragon3_rom[0],'ddragon3.zip',0)) then exit;
//cargar sonido
if not(cargar_roms(@mem_snd[0],@ddragon3_sound,'ddragon3.zip',1)) then exit;
getmem(memoria_temp,$400000);
//convertir background
if not(cargar_roms16w(pword(memoria_temp),@ddragon3_bg[0],'ddragon3.zip',0)) then exit;
init_gfx(0,16,16,$2000);
gfx[0].trans[0]:=true;
gfx_set_desc_data(4,0,64*8,8,0,$80000*8+8,$80000*8+0);
convert_gfx(0,0,memoria_temp,@pt_x[0],@pt_y[0],false,false);
//convertir sprites
if not(cargar_roms(memoria_temp,@ddragon3_sprites[0],'ddragon3.zip',0)) then exit;
init_gfx(1,16,16,$8000);
gfx[1].trans[0]:=true;
gfx_set_desc_data(4,0,32*8,0,$100000*8,$100000*8*2,$100000*8*3);
convert_gfx(1,0,memoria_temp,@ps_x[0],@ps_y[0],false,false);
//DIP
marcade.dswa:=$ff;
marcade.dswa_val:=@ddragon3_dip_a;
marcade.dswb:=$ff;
marcade.dswb_val:=@ddragon3_dip_b;
//final
freemem(memoria_temp);
reset_ddragon3;
iniciar_ddragon3:=true;
end;

procedure cerrar_ddragon3;
begin
main_m68000.free;
snd_z80.free;
YM2151_close(0);
close_audio;
close_video;
end;

procedure reset_ddragon3;
begin
 main_m68000.reset;
 snd_z80.reset;
 YM2151_reset(0);
 reset_audio;
 marcade.in0:=$FFFF;
 marcade.in1:=$FFFF;
 bg_tilebase:=0;
 fg_scrollx:=0;
 fg_scrolly:=0;
 bg_scrollx:=0;
 bg_scrolly:=0;
 vreg:=0;
 sound_latch:=0;
end;

procedure draw_sprites;inline;
var
  atrib,nchar,color,x,y,count:word;
  f,h:byte;
	{- SPR RAM Format -**

	  16 bytes per sprite  (8-bit RAM? only every other byte is used)

	  ---- ----  yyyy yyyy  ---- ----  lllF fXYE  ---- ----  nnnn nnnn  ---- ----  NNNN NNNN
	  ---- ----  ---- CCCC  ---- ----  xxxx xxxx  ---- ----  ---- ----  ---- ----  ---- ----

	  Yy = sprite Y Position
	  Xx = sprite X Position
	  C  = colour bank
	  f  = flip Y
	  F  = flip X
	  l  = chain sprite
	  E  = sprite enable
	  Nn = Sprite Number

	  other bits unused}
begin
for f:=0 to $ff do begin
    atrib:=sprite_ram[(f*8)+1];
		if (atrib and 1)<>0 then begin
			x:=(sprite_ram[(f*8)+5] and $00ff) or ((atrib and $0004) shl 6);
			y:=(sprite_ram[f*8] and $00ff) or ((atrib and $0002) shl 7);
			y:=((256-y) and $1ff)-16;
      count:=(atrib and $00e0) shr 5;
			nchar:=((sprite_ram[(f*8)+2] and $00ff) or ((sprite_ram[(f*8)+3] and $00ff) shl 8)) and $7fff;
			color:= sprite_ram[(f*8)+4] and $000f;
      for h:=0 to count do begin
        put_gfx_sprite(nchar+h,color shl 4,atrib and $10<>0,atrib and $8<>0,1);
        actualiza_gfx_sprite(x,y-(16*h),3,1);
      end;
    end; //del enable
	end; //del for
end;

procedure update_video_ddragon3;
var
  f,x,y,nchar,atrib:word;
  color:byte;
begin
for f:=$0 to $3ff do begin
  x:=f and $1f;
  y:=f shr 5;
  //background
  atrib:=bg_ram[f];
  color:=(atrib and $f000) shr 12;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
    nchar:=(atrib and $0fff) or ((bg_tilebase and $01) shl 12);
    put_gfx_trans(x*16,y*16,nchar,(color shl 4)+512,1,0);
    gfx[0].buffer[f]:=false;
  end;
  //fg
  atrib:=fg_ram[f*2];
  color:=(atrib and $f);
  if (gfx[0].buffer[$400+f] or buffer_color[$10+color]) then begin
    nchar:=fg_ram[(f*2)+1] and $1fff;
    put_gfx_trans_flip(x*16,y*16,nchar,(color shl 4)+256,2,0,(atrib and $40)<>0,(atrib and $80)<>0);
    gfx[0].buffer[$400+f]:=false;
  end;
end;
fill_full_screen(3,$600);
case (vreg and $60) of
  $40:begin
        scroll_x_y(1,3,bg_scrollx,bg_scrolly);
        scroll_x_y(2,3,fg_scrollx,fg_scrolly);
        draw_sprites;
      end;
  $60:begin
        scroll_x_y(2,3,bg_scrollx,bg_scrolly);
        scroll_x_y(1,3,fg_scrollx,fg_scrolly);
        draw_sprites;
      end;
  else begin
        scroll_x_y(1,3,bg_scrollx,bg_scrolly);
        draw_sprites;
        scroll_x_y(2,3,fg_scrollx,fg_scrolly);
      end;
end;
actualiza_trozo_final(0,8,320,240,3);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure eventos_ddragon3;
begin
if event.arcade then begin
  //p1
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $ffFe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fffd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fffb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fff7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ffef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $ffdf) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $ffbf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $ff7f) else marcade.in0:=(marcade.in0 or $80);
  //p2
  if arcade_input.right[1] then marcade.in0:=(marcade.in0 and $Feff) else marcade.in0:=(marcade.in0 or $100);
  if arcade_input.left[1] then marcade.in0:=(marcade.in0 and $fdff) else marcade.in0:=(marcade.in0 or $200);
  if arcade_input.up[1] then marcade.in0:=(marcade.in0 and $fbff) else marcade.in0:=(marcade.in0 or $400);
  if arcade_input.down[1] then marcade.in0:=(marcade.in0 and $f7ff) else marcade.in0:=(marcade.in0 or $800);
  if arcade_input.but0[1] then marcade.in0:=(marcade.in0 and $efff) else marcade.in0:=(marcade.in0 or $1000);
  if arcade_input.but1[1] then marcade.in0:=(marcade.in0 and $dfff) else marcade.in0:=(marcade.in0 or $2000);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $7fff) else marcade.in0:=(marcade.in0 or $8000);
  //system
  if arcade_input.coin[0] then marcade.in1:=(marcade.in1 and $fffe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.coin[1] then marcade.in1:=(marcade.in1 and $fffd) else marcade.in1:=(marcade.in1 or $2);
end;
end;

procedure ddragon3_principal;
var
  frame_m,frame_s:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=main_m68000.tframes;
frame_s:=snd_z80.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to 271 do begin
    //main
    main_m68000.run(frame_m);
    frame_m:=frame_m+main_m68000.tframes-main_m68000.contador;
    //sound
    snd_z80.run(frame_s);
    frame_s:=frame_s+snd_z80.tframes-snd_z80.contador;
    if (((f mod 16)=0) and (f<>0)) then main_m68000.irq[5]:=ASSERT_LINE;
    if f=247 then begin
        main_m68000.irq[6]:=ASSERT_LINE;
        update_video_ddragon3;
    end;
 end;
 eventos_ddragon3;
 video_sync;
end;
end;

function ddragon3_getword(direccion:dword;putbyte:boolean):word;
begin

direccion:=direccion and $fffffe;
case direccion of
    0..$7ffff:ddragon3_getword:=rom[direccion shr 1];
    $080000..$080fff:ddragon3_getword:=fg_ram[(direccion and $fff) shr 1];
    $082000..$0827ff:ddragon3_getword:=bg_ram[(direccion and $7ff) shr 1];
    $100000:ddragon3_getword:=marcade.in0;
    $100002:ddragon3_getword:=marcade.in1;
    $100004:ddragon3_getword:=$FFFF;//marcade.dswa;
    $100006:ddragon3_getword:=$FFFF;  //P3!!
    $140000..$1405ff:ddragon3_getword:=buffer_paleta[(direccion and $fff)];
    $180000..$180fff:ddragon3_getword:=sprite_ram[(direccion and $fff) shr 1];
    $1c0000..$1c3fff:ddragon3_getword:=ram[(direccion and $3fff) shr 1];
end;
end;

procedure cambiar_color(pos,data:word);inline;
var
  color:tcolor;
begin
  color.b:=pal5bit(data shr 10);
  color.g:=pal5bit(data shr 5);
  color.r:=pal5bit(data);
  set_pal_color(color,@paleta[pos]);
  case pos of
    $100..$1ff:buffer_color[$10+((pos shr 4) and $f)]:=true;
    $200..$2ff:buffer_color[(pos shr 4) and $f]:=true;
  end;
end;

procedure ddragon3_putword(direccion:dword;valor:word);
begin
direccion:=direccion and $fffffe;
if direccion<$80000 then exit;
case direccion of
    $080000..$080fff:begin
                    fg_ram[(direccion and $fff) shr 1]:=valor;
                    gfx[0].buffer[$400+((direccion and $fff) shr 2)]:=true;
                  end;
    $082000..$0827ff:begin
                    bg_ram[(direccion and $7ff) shr 1]:=valor;
                    gfx[0].buffer[(direccion and $7ff) shr 1]:=true;
                  end;
    $0c0000..$0c000f:case ((direccion and $f) shr 1) of
                        0:fg_scrollx:=valor;
                        1:fg_scrolly:=valor;
                        2:bg_scrollx:=valor;
                        3:bg_scrolly:=valor;
                        5:main_screen.flip_main_screen:=(valor and 1)<>0;
                        6:if bg_tilebase<>(valor and $1ff) then begin
                          bg_tilebase:=valor and $1ff;
                          fillchar(gfx[0].buffer[0],$400,1);
                        end;
                     end;
    $100000..$10000f:case ((direccion and $f) shr 1) of
                        0:vreg:=valor and $ff;
                        1:begin
                            sound_latch:=valor and $ff;
                            snd_z80.pedir_nmi:=PULSE_LINE;
                          end;
                        2,4:main_m68000.irq[6]:=CLEAR_LINE;
                        3:main_m68000.irq[5]:=CLEAR_LINE;
                     end;
    $140000..$1405ff:if buffer_paleta[(direccion and $fff) shr 1]<>valor then begin
                    buffer_paleta[(direccion and $fff) shr 1]:=valor;
                    cambiar_color((direccion and $fff) shr 1,valor);
                  end;
    $180000..$180fff:sprite_ram[(direccion and $fff) shr 1]:=valor;
    $1c0000..$1c3fff:ram[(direccion and $3fff) shr 1]:=valor;
end;
end;

function ddragon3_snd_getbyte(direccion:word):byte;
begin
case direccion of
    $c801:ddragon3_snd_getbyte:=YM2151_status_port_read(0);
    $d800:ddragon3_snd_getbyte:=oki_6295_0.read;
    $e000:ddragon3_snd_getbyte:=sound_latch;
    else ddragon3_snd_getbyte:=mem_snd[direccion];
  end;
end;

procedure ddragon3_snd_putbyte(direccion:word;valor:byte);
begin
if direccion<$c000 then exit;
mem_snd[direccion]:=valor;
case direccion of
  $c800:YM2151_register_port_write(0,valor);
  $c801:YM2151_data_port_write(0,valor);
  $d800:oki_6295_0.write(valor);
  $e800:copymemory(oki_6295_0.get_rom_addr,@mem_oki[(valor and 1)*$40000],$40000);
end;
end;

procedure ym2151_snd_irq(irqstate:byte);
begin
  if (irqstate=1) then snd_z80.pedir_irq:=ASSERT_LINE
    else snd_z80.pedir_irq:=CLEAR_LINE;
end;

procedure ddragon3_sound_update;
begin
  ym2151_Update(0);
  oki_6295_0.update;
end;

end.
