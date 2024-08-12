unit breakthru_hw;
interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6809,main_engine,controls_engine,gfx_engine,ym_3812,ym_2203,rom_engine,
     pal_engine,sound_engine;
function iniciar_brkthru:boolean;
implementation
const
        //Break Thru
        brkthru_rom:array[0..3] of tipo_roms=(
        (n:'brkthru.1';l:$4000;p:$0;crc:$cfb4265f),(n:'brkthru.2';l:$8000;p:$4000;crc:$fa8246d9),
        (n:'brkthru.4';l:$8000;p:$c000;crc:$8cabf252),(n:'brkthru.3';l:$8000;p:$14000;crc:$2f2c40c2));
        brkthru_snd:tipo_roms=(n:'brkthru.5';l:$8000;p:$8000;crc:$c309435f);
        brkthru_char:tipo_roms=(n:'brkthru.12';l:$2000;p:0;crc:$58c0b29b);
        brkthru_sprites:array[0..2] of tipo_roms=(
        (n:'brkthru.9';l:$8000;p:0;crc:$f54e50a7),(n:'brkthru.10';l:$8000;p:$8000;crc:$fd156945),
        (n:'brkthru.11';l:$8000;p:$10000;crc:$c152a99b));
        brkthru_tiles:array[0..2] of tipo_roms=(
        (n:'brkthru.7';l:$8000;p:0;crc:$920cc56a),(n:'brkthru.6';l:$8000;p:$8000;crc:$fd3cee40),
        (n:'brkthru.8';l:$8000;p:$10000;crc:$f67ee64e));
        brkthru_pal:array[0..1] of tipo_roms=(
        (n:'brkthru.13';l:$100;p:0;crc:$aae44269),(n:'brkthru.14';l:$100;p:$100;crc:$f2d4822a));
        //DIP
        brkthru_dip_a:array [0..6] of def_dip=(
        (mask:$3;name:'Coin A';number:4;dip:((dip_val:$0;dip_name:'2C 1C'),(dip_val:$3;dip_name:'1C 1C'),(dip_val:$2;dip_name:'1C 2C'),(dip_val:$1;dip_name:'1C 3C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Coin B';number:4;dip:((dip_val:$0;dip_name:'2C 1C'),(dip_val:$c;dip_name:'1C 1C'),(dip_val:$8;dip_name:'1C 2C'),(dip_val:$4;dip_name:'1C 3C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Enemy Vehicles';number:2;dip:((dip_val:$10;dip_name:'Slow'),(dip_val:$0;dip_name:'Fast'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Enemy Bullets';number:2;dip:((dip_val:$20;dip_name:'Slow'),(dip_val:$0;dip_name:'Fast'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Control Panel';number:2;dip:((dip_val:$40;dip_name:'1 Player'),(dip_val:$0;dip_name:'2 Player'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$80;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        brkthru_dip_b:array [0..3] of def_dip=(
        (mask:$3;name:'Lives';number:4;dip:((dip_val:$2;dip_name:'2'),(dip_val:$3;dip_name:'3'),(dip_val:$1;dip_name:'5'),(dip_val:$0;dip_name:'99'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Bonus Life';number:4;dip:((dip_val:$0;dip_name:'20K'),(dip_val:$4;dip_name:'10K 20K'),(dip_val:$c;dip_name:'20K 30K'),(dip_val:$8;dip_name:'20K 40K'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Allow Continue';number:2;dip:((dip_val:$0;dip_name:'No'),(dip_val:$10;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        //Darwin
        darwin_rom:array[0..3] of tipo_roms=(
        (n:'darw_04.rom';l:$4000;p:$0;crc:$0eabf21c),(n:'darw_05.rom';l:$8000;p:$4000;crc:$e771f864),
        (n:'darw_07.rom';l:$8000;p:$c000;crc:$97ac052c),(n:'darw_06.rom';l:$8000;p:$14000;crc:$2a9fb208));
        darwin_snd:tipo_roms=(n:'darw_08.rom';l:$8000;p:$8000;crc:$6b580d58);
        darwin_char:tipo_roms=(n:'darw_09.rom';l:$2000;p:0;crc:$067b4cf5);
        darwin_sprites:array[0..2] of tipo_roms=(
        (n:'darw_10.rom';l:$8000;p:0;crc:$487a014c),(n:'darw_11.rom';l:$8000;p:$8000;crc:$548ce2d1),
        (n:'darw_12.rom';l:$8000;p:$10000;crc:$faba5fef));
        darwin_tiles:array[0..2] of tipo_roms=(
        (n:'darw_03.rom';l:$8000;p:0;crc:$57d0350d),(n:'darw_02.rom';l:$8000;p:$8000;crc:$559a71ab),
        (n:'darw_01.rom';l:$8000;p:$10000;crc:$15a16973));
        darwin_pal:array[0..1] of tipo_roms=(
        (n:'df.12';l:$100;p:0;crc:$89b952ef),(n:'df.13';l:$100;p:$100;crc:$d595e91d));
        //DIP
        darwin_dip_a:array [0..4] of def_dip=(
        (mask:$3;name:'Coin A';number:4;dip:((dip_val:$0;dip_name:'2C 1C'),(dip_val:$3;dip_name:'1C 1C'),(dip_val:$2;dip_name:'1C 2C'),(dip_val:$1;dip_name:'1C 3C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Coin B';number:4;dip:((dip_val:$0;dip_name:'2C 1C'),(dip_val:$c;dip_name:'1C 1C'),(dip_val:$8;dip_name:'1C 2C'),(dip_val:$4;dip_name:'1C 3C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$20;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$40;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        darwin_dip_b:array [0..4] of def_dip=(
        (mask:$1;name:'Lives';number:2;dip:((dip_val:$1;dip_name:'3'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2;name:'Bonus Life';number:2;dip:((dip_val:$2;dip_name:'20K 50K+'),(dip_val:$0;dip_name:'30K 80K+'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Difficulty';number:4;dip:((dip_val:$c;dip_name:'Easy'),(dip_val:$8;dip_name:'Meidum'),(dip_val:$4;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Allow Continue';number:2;dip:((dip_val:$0;dip_name:'No'),(dip_val:$10;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
var
 rom:array[0..7,0..$1fff] of byte;
 mem_sprt:array[0..$ff] of byte;
 sound_latch,rom_bank,bg_color:byte;
 nmi_ena,old_val,old_val2:boolean;
 scroll_x:word;
 bg_video,fg_video:array[0..$3ff] of byte;
procedure update_video_brkthru;
var
  x,y,atrib:byte;
  f,nchar,color:word;
procedure draw_sprites(prio:byte);
var
  f,x,y,nchar,color:word;
  atrib:byte;
begin
	{ Draw the sprites. Note that it is important to draw them exactly in this
	  order, to have the correct priorities.
        0         1         2         3
        ccc- ---- ---- ---- ---- ---- ---- ---- = Color
        ---d ---- ---- ---- ---- ---- ---- ---- = Double Size
        ---- p--- ---- ---- ---- ---- ---- ---- = Priority
        ---- -bb- ---- ---- ---- ---- ---- ---- = Bank
        ---- ---e ---- ---- ---- ---- ---- ---- = Enable/Disable
        ---- ---- ssss ssss ---- ---- ---- ---- = Sprite code
        ---- ---- ---- ---- yyyy yyyy ---- ---- = Y position
        ---- ---- ---- ---- ---- ---- xxxx xxxx = X position}
	for f:=0 to $3f do begin
    atrib:=mem_sprt[$0+(f*4)];
		if ((atrib and $9)=prio) then begin	// Enabled + Priority
      nchar:=mem_sprt[$1+(f*4)]+((atrib and $06) shl 7);
			color:=(atrib and $e0) shr 2;
      x:=(240-mem_sprt[$3+(f*4)]) and $ff;
      y:=(224-mem_sprt[$2+(f*4)]) and $ff;
      if (atrib and $10)<>0 then begin	// double height
          put_gfx_sprite_diff((nchar and $3fe),$40+color,false,false,2,0,0);
          put_gfx_sprite_diff((nchar or 1),$40+color,false,false,2,0,16);
          actualiza_gfx_sprite_size(x,y,4,16,32);
      end else begin
          put_gfx_sprite(nchar,$40+color,false,false,2);
          actualiza_gfx_sprite(x,y+16,4,2);
      end;
    end;
	end;
end;
begin
for f:=0 to $1ff do begin
    if gfx[1].buffer[f] then begin
      x:=f div 16;
      y:=f mod 16;
      atrib:=fg_video[$1+(f*2)];
      nchar:=fg_video[$0+(f*2)]+((atrib and $3) shl 8);
      color:=(bg_color+((atrib and $4) shr 2)) shl 3;
      put_gfx(x*16,y*16,nchar,$80+color,2,1);
      put_gfx_trans(x*16,y*16,nchar,$80+color,3,1);
      gfx[1].buffer[f]:=false;
    end;
end;
for f:=0 to $3ff do begin
    if gfx[0].buffer[f] then begin
      x:=f mod 32;
      y:=f div 32;
      nchar:=bg_video[f];
      put_gfx_trans(x*8,y*8,nchar,0,1,0);
      gfx[0].buffer[f]:=false;
    end;
end;
scroll__x(2,4,scroll_x);
draw_sprites($1);
scroll__x(3,4,scroll_x);
draw_sprites($9);
actualiza_trozo(0,0,256,256,1,0,0,256,256,4);
actualiza_trozo_final(8,8,240,240,4);
end;
procedure eventos_brkthru;
begin
if event.arcade then begin
  //p1
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  //p2
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or 8);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  //misc
  if (arcade_input.coin[0] and not(old_val)) then begin
      marcade.in2:=(marcade.in2 and $df);
      m6809_0.change_irq(ASSERT_LINE);
  end else begin
      marcade.in2:=(marcade.in2 or $20);
  end;
  if (arcade_input.coin[1] and not(old_val2)) then begin
      marcade.in2:=(marcade.in2 and $bf);
      m6809_0.change_irq(ASSERT_LINE);
  end else begin
      marcade.in2:=(marcade.in2 or $40);
  end;
  old_val:=arcade_input.coin[0];
  old_val2:=arcade_input.coin[1];
end;
end;
procedure brkthru_principal;
var
  frame_m,frame_s:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=m6809_0.tframes;
frame_s:=m6809_1.tframes;
while EmuStatus=EsRunning do begin
  for f:=0 to 271 do begin
    //main
    m6809_0.run(frame_m);
    frame_m:=frame_m+m6809_0.tframes-m6809_0.contador;
    //snd
    m6809_1.run(frame_s);
    frame_s:=frame_s+m6809_1.tframes-m6809_1.contador;
    if f=247 then begin
      if nmi_ena then m6809_0.change_nmi(PULSE_LINE);
      update_video_brkthru;
      marcade.in1:=marcade.in1 and $7f;
    end;
  end;
  marcade.in1:=marcade.in1 or $80;
  eventos_brkthru;
  video_sync;
end;
end;
function read_mem_gen(direccion:word):byte;
begin
case direccion of
  0..$3ff:read_mem_gen:=bg_video[direccion];
  $400..$bff:read_mem_gen:=memoria[direccion];
  $c00..$fff:read_mem_gen:=fg_video[direccion and $3ff];
  $1000..$10ff:read_mem_gen:=mem_sprt[direccion and $ff];
  $1800:read_mem_gen:=marcade.in0;
  $1801:read_mem_gen:=marcade.in1;
  $1802:read_mem_gen:=marcade.dswa;
  $1803:read_mem_gen:=marcade.dswb or marcade.in2;
end;
end;
procedure write_mem_gen(direccion:word;valor:byte);
begin
case direccion of
    $0..$3ff:if bg_video[direccion]<>valor then begin
                gfx[0].buffer[direccion]:=true;
                bg_video[direccion]:=valor;
             end;
    $400..$bff:memoria[direccion]:=valor;
    $c00..$fff:if fg_video[direccion and $3ff]<>valor then begin
                gfx[1].buffer[(direccion and $3ff) shr 1]:=true;
                fg_video[direccion and $3ff]:=valor;
               end;
    $1000..$10ff:mem_sprt[direccion and $ff]:=valor;
    $1800:scroll_x:=(scroll_x and $ff00) or valor;
    $1801:begin
            rom_bank:=valor and $7;
            if ((valor and $38) shr 2)<>bg_color then begin
              bg_color:=(valor and $38) shr 2;
              fillchar(gfx[1].buffer[0],$200,1);
            end;
            main_screen.flip_main_screen:=(valor and $40)<>0;
            scroll_x:=(scroll_x and $00ff) or ((valor shr 7) shl 8);
          end;
    $1802:begin
            sound_latch:=valor;
            m6809_1.change_nmi(PULSE_LINE);
          end;
end;
end;
//Break Thru
function brkthru_getbyte(direccion:word):byte;
begin
case direccion of
    $0..$10ff,$1800..$1803:brkthru_getbyte:=read_mem_gen(direccion);
    $1100..$17ff,$4000..$ffff:brkthru_getbyte:=memoria[direccion];
    $2000..$3fff:brkthru_getbyte:=rom[rom_bank,direccion and $1fff];
end;
end;
procedure brkthru_putbyte(direccion:word;valor:byte);
begin
case direccion of
    $0..$10ff,$1800..$1802:write_mem_gen(direccion,valor);
    $1100..$17ff:memoria[direccion]:=valor;
    $1803:begin
            nmi_ena:=((valor and 1)=0);
            if (valor and 2)<>2 then m6809_0.change_irq(CLEAR_LINE);
          end;
    $2000..$ffff:; //ROM
end;
end;
function brkthru_snd_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$1fff,$8000..$ffff:brkthru_snd_getbyte:=mem_snd[direccion];
  $2000:brkthru_snd_getbyte:=ym3812_0.status;
  $4000:brkthru_snd_getbyte:=sound_latch;
  $6000:brkthru_snd_getbyte:=ym2203_0.status;
end;
end;
procedure brkthru_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  $0..$1fff:mem_snd[direccion]:=valor;
  $2000:ym3812_0.control(valor);
  $2001:ym3812_0.write(valor);
  $6000:ym2203_0.control(valor);
  $6001:ym2203_0.write(valor);
  $8000..$ffff:; //ROM
end;
end;
procedure brkthru_snd_irq(irqstate:byte);
begin
  m6809_1.change_irq(irqstate);
end;
procedure brkthru_sound_update;
begin
  ym2203_0.update;
  ym3812_0.update;
end;
//Darwin
function darwin_getbyte(direccion:word):byte;
begin
case direccion of
    0..$ff,$800..$803:darwin_getbyte:=read_mem_gen(direccion+$1000);
    $1000..$1fff:darwin_getbyte:=read_mem_gen(direccion-$1000);
    $2000..$3fff:darwin_getbyte:=rom[rom_bank,direccion and $1fff];
    $4000..$ffff:darwin_getbyte:=memoria[direccion];
end;
end;
procedure darwin_putbyte(direccion:word;valor:byte);
begin
case direccion of
    $0..$ff,$800..$802:write_mem_gen(direccion+$1000,valor);
    $803:begin
            nmi_ena:=(valor and 1)<>0;
            if (valor and 2)<>2 then m6809_0.change_irq(CLEAR_LINE);
         end;
    $1000..$1fff:write_mem_gen(direccion-$1000,valor);
    $2000..$ffff:; //ROM
end;
end;
//Main
procedure reset_brkthru;
begin
 m6809_0.reset;
 m6809_1.reset;
 ym2203_0.reset;
 ym3812_0.reset;
 reset_audio;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$e0;
 rom_bank:=0;
 scroll_x:=0;
 old_val:=false;
 old_val2:=false;
 sound_latch:=0;
 bg_color:=0;
 nmi_ena:=true;
end;
function iniciar_brkthru:boolean;
var
  colores:tpaleta;
  bit0,bit1,bit2,bit3:byte;
  f:word;
  memoria_temp:array[0..$1ffff] of byte;
const
  pc_x:array[0..7] of dword=(256*8*8+0, 256*8*8+1, 256*8*8+2, 256*8*8+3, 0, 1, 2, 3);
  ps_x:array[0..15] of dword=(16*8+0, 16*8+1, 16*8+2, 16*8+3, 16*8+4, 16*8+5, 16*8+6, 16*8+7,
			0, 1, 2, 3, 4, 5, 6, 7);
  pt_x:array[0..15] of dword=(0, 1, 2, 3, 1024*8*8+0, 1024*8*8+1, 1024*8*8+2, 1024*8*8+3,
			16*8+0, 16*8+1, 16*8+2, 16*8+3, 16*8+1024*8*8+0, 16*8+1024*8*8+1, 16*8+1024*8*8+2, 16*8+1024*8*8+3);
  pt_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8);
procedure convert_chars;
begin
  init_gfx(0,8,8,$100);
  gfx[0].trans[0]:=true;
  gfx_set_desc_data(3,0,8*8,512*8*8+4,0,4);
  convert_gfx(0,0,@memoria_temp,@pc_x,@pt_y,false,false);
end;
procedure convert_tiles;
var
  memoria_temp2:array[0..$1ffff] of byte;
  f:byte;
begin
  copymemory(@memoria_temp2[0],@memoria_temp[0],$4000);	          // bitplanes 1,2 for bank 1,2
  copymemory(@memoria_temp2[$8000],@memoria_temp[$4000],$4000);   // bitplanes 1,2 for bank 3,4
  copymemory(@memoria_temp2[$10000],@memoria_temp[$8000],$4000);  // bitplanes 1,2 for bank 5,6
  copymemory(@memoria_temp2[$18000],@memoria_temp[$c000],$4000);  // bitplanes 1,2 for bank 7,8
  copymemory(@memoria_temp2[$4000],@memoria_temp[$10000],$1000);  // bitplane 3 for bank 1,2
  copymemory(@memoria_temp2[$6000],@memoria_temp[$11000],$1000);
  copymemory(@memoria_temp2[$c000],@memoria_temp[$12000],$1000);  // bitplane 3 for bank 3,4
  copymemory(@memoria_temp2[$e000],@memoria_temp[$13000],$1000);
  copymemory(@memoria_temp2[$14000],@memoria_temp[$14000],$1000); // bitplane 3 for bank 5,6
  copymemory(@memoria_temp2[$16000],@memoria_temp[$15000],$1000);
  copymemory(@memoria_temp2[$1c000],@memoria_temp[$16000],$1000); // bitplane 3 for bank 7,8
  copymemory(@memoria_temp2[$1e000],@memoria_temp[$17000],$1000);
  init_gfx(1,16,16,$400);
  gfx[1].trans[0]:=true;
  for f:=0 to 3 do begin
    gfx_set_desc_data(3,8,32*8,$4000*8+4,0,4);
    convert_gfx(1,(f*2)*16*16*$80,@memoria_temp2[$8000*f],@pt_x[0],@pt_y[0],false,false);
    gfx_set_desc_data(3,8,32*8,$3000*8+0,0,4);
    convert_gfx(1,((f*2)+1)*16*16*$80,@memoria_temp2[($8000*f)+$1000],@pt_x[0],@pt_y[0],false,false);
  end;
end;
procedure convert_sprt;
begin
  init_gfx(2,16,16,$400);
  gfx[2].trans[0]:=true;
  gfx_set_desc_data(3,0,32*8,2*1024*32*8,1024*32*8,0);
  convert_gfx(2,0,@memoria_temp,@ps_x,@pt_y,false,false);
end;
begin
llamadas_maquina.bucle_general:=brkthru_principal;
llamadas_maquina.reset:=reset_brkthru;
llamadas_maquina.fps_max:=57.444885;
iniciar_brkthru:=false;
iniciar_audio(false);
screen_init(1,256,256,true);
screen_init(2,512,512);
screen_mod_scroll(2,512,256,511,512,256,511);
screen_init(3,512,512,true);
screen_mod_scroll(3,512,256,511,512,256,511);
screen_init(4,512,512,false,true);
iniciar_video(240,240);
//Main CPU
m6809_0:=cpu_m6809.create(12000000 div 8,272,TCPU_MC6809E);
//Sound CPU
m6809_1:=cpu_m6809.create(12000000 div 2,272,TCPU_MC6809);
m6809_1.change_ram_calls(brkthru_snd_getbyte,brkthru_snd_putbyte);
m6809_1.init_sound(brkthru_sound_update);
//Sound Chip
ym2203_0:=ym2203_chip.create(1500000,0.5,0.1);
ym3812_0:=ym3812_chip.create(YM3526_FM,3000000);
ym3812_0.change_irq_calls(brkthru_snd_irq);
case main_vars.tipo_maquina of
  89:begin
        m6809_0.change_ram_calls(brkthru_getbyte,brkthru_putbyte);
        //cargar roms y ponerlas en su sitio
        if not(roms_load(@memoria_temp,brkthru_rom)) then exit;
        copymemory(@memoria[$4000],@memoria_temp[0],$c000);
        for f:=0 to 7 do copymemory(@rom[f,0],@memoria_temp[$c000+(f*$2000)],$2000);
        //roms sonido
        if not(roms_load(@mem_snd,brkthru_snd)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,brkthru_char)) then exit;
        convert_chars;
        //convertir tiles y organizar
        if not(roms_load(@memoria_temp,brkthru_tiles)) then exit;
        convert_tiles;
        //convertir sprites
        if not(roms_load(@memoria_temp,brkthru_sprites)) then exit;
        convert_sprt;
        //paleta
        if not(roms_load(@memoria_temp,brkthru_pal)) then exit;
        //DIP
        marcade.dswa:=$3f;
        marcade.dswa_val:=@brkthru_dip_a;
        marcade.dswb:=$1f;
        marcade.dswb_val:=@brkthru_dip_b;
     end;
  90:begin
        main_screen.rot270_screen:=true;
        m6809_0.change_ram_calls(darwin_getbyte,darwin_putbyte);
        //cargar roms y ponerlas en su sitio
        if not(roms_load(@memoria_temp,darwin_rom)) then exit;
        copymemory(@memoria[$4000],@memoria_temp[0],$c000);
        for f:=0 to 7 do copymemory(@rom[f,0],@memoria_temp[$c000+(f*$2000)],$2000);
        //roms sonido
        if not(roms_load(@mem_snd,darwin_snd)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,darwin_char)) then exit;
        convert_chars;
        //convertir tiles y organizar
        if not(roms_load(@memoria_temp,darwin_tiles)) then exit;
        convert_tiles;
        //convertir sprites
        if not(roms_load(@memoria_temp,darwin_sprites)) then exit;
        convert_sprt;
        //paleta
        if not(roms_load(@memoria_temp,darwin_pal)) then exit;
        //DIP
        marcade.dswa:=$df;
        marcade.dswa_val:=@darwin_dip_a;
        marcade.dswb:=$1f;
        marcade.dswb_val:=@darwin_dip_b;
     end;
end;
for f:=0 to $ff do begin
    bit0:=(memoria_temp[f] shr 0) and $01;
		bit1:=(memoria_temp[f] shr 1) and $01;
		bit2:=(memoria_temp[f] shr 2) and $01;
    bit3:=(memoria_temp[f] shr 3) and $01;
		colores[f].r:=$0e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
		bit0:=(memoria_temp[f] shr 4) and $01;
		bit1:=(memoria_temp[f] shr 5) and $01;
		bit2:=(memoria_temp[f] shr 6) and $01;
    bit3:=(memoria_temp[f] shr 7) and $01;
		colores[f].g:=$0e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
		bit0:=(memoria_temp[f+$100] shr 0) and $01;
		bit1:=(memoria_temp[f+$100] shr 1) and $01;
		bit2:=(memoria_temp[f+$100] shr 2) and $01;
    bit3:=(memoria_temp[f+$100] shr 3) and $01;
		colores[f].b:=$0e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
end;
set_pal(colores,$100);
//final
reset_brkthru;
iniciar_brkthru:=true;
end;
end.
