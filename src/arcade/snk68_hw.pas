unit snk68_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m68000,main_engine,controls_engine,gfx_engine,rom_engine,
     pal_engine,ym_3812,nz80,upd7759,sound_engine;

function iniciar_snk68:boolean;

implementation
const
        //POW
        pow_rom:array[0..1] of tipo_roms=(
        (n:'dg1ver1.j14';l:$20000;p:0;crc:$8e71a8af),(n:'dg2ver1.l14';l:$20000;p:$1;crc:$4287affc));
        pow_char:array[0..1] of tipo_roms=(
        (n:'dg9.l25';l:$8000;p:0;crc:$df864a08),(n:'dg10.m25';l:$8000;p:$8000;crc:$9e470d53));
        pow_sound:tipo_roms=(n:'dg8.e25';l:$10000;p:0;crc:$d1d61da3);
        pow_upd:tipo_roms=(n:'dg7.d20';l:$10000;p:0;crc:$aba9a9d3);
        pow_sprites:array[0..15] of tipo_roms=(
        (n:'snk880.11a';l:$20000;p:$0;crc:$e70fd906),(n:'snk880.15a';l:$20000;p:$1;crc:$7a90e957),
        (n:'snk880.12a';l:$20000;p:$40000;crc:$628b1aed),(n:'snk880.16a';l:$20000;p:$40001;crc:$e40a6c13),
        (n:'snk880.13a';l:$20000;p:$80000;crc:$19dc8868),(n:'snk880.17a';l:$20000;p:$80001;crc:$c7931cc2),
        (n:'snk880.14a';l:$20000;p:$c0000;crc:$47cd498b),(n:'snk880.18a';l:$20000;p:$c0001;crc:$eed72232),
        (n:'snk880.19a';l:$20000;p:$100000;crc:$1775b8dd),(n:'snk880.23a';l:$20000;p:$100001;crc:$adb6ad68),
        (n:'snk880.20a';l:$20000;p:$140000;crc:$f8e752ec),(n:'snk880.24a';l:$20000;p:$140001;crc:$dd41865a),
        (n:'snk880.21a';l:$20000;p:$180000;crc:$27e9fffe),(n:'snk880.25a';l:$20000;p:$180001;crc:$055759ad),
        (n:'snk880.22a';l:$20000;p:$1c0000;crc:$aa9c00d8),(n:'snk880.26a';l:$20000;p:$1c0001;crc:$9bc261c5));
        //Street Smart
        streetsm_rom:array[0..1] of tipo_roms=(
        (n:'s2-1ver2.14h';l:$20000;p:0;crc:$655f4773),(n:'s2-2ver2.14k';l:$20000;p:$1;crc:$efae4823));
        streetsm_char:array[0..1] of tipo_roms=(
        (n:'s2-9.25l';l:$8000;p:0;crc:$09b6ac67),(n:'s2-10.25m';l:$8000;p:$8000;crc:$89e4ee6f));
        streetsm_sound:tipo_roms=(n:'s2-5.16c';l:$10000;p:0;crc:$ca4b171e);
        streetsm_upd:tipo_roms=(n:'s2-6.18d';l:$20000;p:0;crc:$47db1605);
        streetsm_sprites:array[0..5] of tipo_roms=(
        (n:'stsmart.900';l:$80000;p:$0;crc:$a8279a7e),(n:'stsmart.902';l:$80000;p:$80000;crc:$2f021aa1),
        (n:'stsmart.904';l:$80000;p:$100000;crc:$167346f7),(n:'stsmart.901';l:$80000;p:$200000;crc:$c305af12),
        (n:'stsmart.903';l:$80000;p:$280000;crc:$73c16d35),(n:'stsmart.905';l:$80000;p:$300000;crc:$a5beb4e2));
        //Ikari 3
        ikari3_rom:array[0..1] of tipo_roms=(
        (n:'ik3-2-ver1.c10';l:$20000;p:0;crc:$1bae8023),(n:'ik3-3-ver1.c9';l:$20000;p:$1;crc:$10e38b66));
        ikari3_char:array[0..1] of tipo_roms=(
        (n:'ik3-7.bin';l:$8000;p:0;crc:$0b4804df),(n:'ik3-8.bin';l:$8000;p:$8000;crc:$10ab4e50));
        ikari3_sound:tipo_roms=(n:'ik3-5.bin';l:$10000;p:0;crc:$ce6706fc);
        ikari3_upd:tipo_roms=(n:'ik3-6.bin';l:$20000;p:0;crc:$59d256a4);
        ikari3_sprites:array[0..19] of tipo_roms=(
        (n:'ik3-23.bin';l:$20000;p:$000000;crc:$d0fd5c77),(n:'ik3-13.bin';l:$20000;p:$000001;crc:$9a56bd32),
        (n:'ik3-22.bin';l:$20000;p:$040000;crc:$4878d883),(n:'ik3-12.bin';l:$20000;p:$040001;crc:$0ce6a10a),
        (n:'ik3-21.bin';l:$20000;p:$080000;crc:$50d0fbf0),(n:'ik3-11.bin';l:$20000;p:$080001;crc:$e4e2be43),
        (n:'ik3-20.bin';l:$20000;p:$0c0000;crc:$9a851efc),(n:'ik3-10.bin';l:$20000;p:$0c0001;crc:$ac222372),
        (n:'ik3-19.bin';l:$20000;p:$100000;crc:$4ebdba89),(n:'ik3-9.bin';l:$20000;p:$100001;crc:$c33971c2),
        (n:'ik3-14.bin';l:$20000;p:$200000;crc:$453bea77),(n:'ik3-24.bin';l:$20000;p:$200001;crc:$e9b26d68),
        (n:'ik3-15.bin';l:$20000;p:$240000;crc:$781a81fc),(n:'ik3-25.bin';l:$20000;p:$240001;crc:$073b03f1),
        (n:'ik3-16.bin';l:$20000;p:$280000;crc:$80ba400b),(n:'ik3-26.bin';l:$20000;p:$280001;crc:$9c613561),
        (n:'ik3-17.bin';l:$20000;p:$2c0000;crc:$0cc3ce4a),(n:'ik3-27.bin';l:$20000;p:$2c0001;crc:$16dd227e),
        (n:'ik3-18.bin';l:$20000;p:$300000;crc:$ba106245),(n:'ik3-28.bin';l:$20000;p:$300001;crc:$711715ae));
        ikari3_rom2:array[0..1] of tipo_roms=(
        (n:'ik3-1.c8';l:$10000;p:0;crc:$47e4d256),(n:'ik3-4.c12';l:$10000;p:$1;crc:$a43af6b5));
        //Search and Rescue
        sar_rom:array[0..1] of tipo_roms=(
        (n:'bhw.2';l:$20000;p:0;crc:$e1430138),(n:'bhw.3';l:$20000;p:$1;crc:$ee1f9374));
        sar_char:array[0..1] of tipo_roms=(
        (n:'bh.7';l:$8000;p:0;crc:$b0f1b049),(n:'bh.8';l:$8000;p:$8000;crc:$174ddba7));
        sar_sound:tipo_roms=(n:'bh.5';l:$10000;p:0;crc:$53e2fa76);
        sar_upd:tipo_roms=(n:'bh.v1';l:$20000;p:0;crc:$07a6114b);
        sar_sprites:array[0..5] of tipo_roms=(
        (n:'bh.c1';l:$80000;p:$000000;crc:$1fb8f0ae),(n:'bh.c3';l:$80000;p:$080000;crc:$fd8bc407),
        (n:'bh.c5';l:$80000;p:$100000;crc:$1d30acc3),(n:'bh.c2';l:$80000;p:$200000;crc:$7c803767),
        (n:'bh.c4';l:$80000;p:$280000;crc:$eede7c43),(n:'bh.c6';l:$80000;p:$300000;crc:$9f785cd9));
        sar_rom2:array[0..1] of tipo_roms=(
        (n:'bhw.1';l:$20000;p:0;crc:$62b60066),(n:'bhw.4';l:$20000;p:$1;crc:$16d8525c));

var
 rom,rom2:array[0..$1ffff] of word;
 ram:array[0..$1fff] of word;
 video_ram:array[0..$7ff] of word;
 sprite_ram:array[0..$3fff] of word;
 sound_latch,dsw1,sound_stat,protection:byte;
 fg_tile_offset:word;
 is_pow,sprite_flip:boolean;
 update_video_nmk68:procedure;

{Primer bloque de $1000bytes
       0:$FF -> Fijo
       1:----xxxx xxxx----
   2 y 3:xxxxyyyy yyyyyyyy}
procedure poner_sprites(group:byte);inline;
var
  f,i,nchar,atrib,color,x:word;
  tiledata_pos:word;
  y:integer;
  flipx,flipy:boolean;
begin
  tiledata_pos:=$800*2*group;
	for f:=0 to $1f do begin
		x:=(sprite_ram[((f*$80)+4*group) shr 1] and $ff) shl 4;
		y:=sprite_ram[(((f*$80)+4*group) shr 1)+1];
		x:=x or (y shr 12);
		x:=(((x+16) and $1ff)-16) and $1ff;
		y:=-y;
		//every sprite is a column 32 tiles (512 pixels) tall
    for i:=0 to $1f do begin
      y:=y and $1ff;
      if ((y<=256) and ((y+15)>=0)) then begin
	     	color:=sprite_ram[tiledata_pos shr 1] and $7f;
    	 	atrib:=sprite_ram[(tiledata_pos shr 1)+1];
        if is_pow then begin
          nchar:=atrib and $3fff;
          flipx:=(atrib and $4000)<>0;
          flipy:=(atrib and $8000)<>0;
          if nchar<>$ff then begin
            put_gfx_sprite(nchar,color shl 4,flipx,flipy,1);
            actualiza_gfx_sprite(x,y,2,1);
          end;
        end else begin
          if sprite_flip then begin
            flipx:=false;
            flipy:=(atrib and $8000)<>0;
          end else begin
            flipx:=(atrib and $8000)<>0;
            flipy:=false;
          end;
          nchar:=atrib and $7fff;
          if nchar<>$7fff then begin
            put_gfx_sprite(nchar,color shl 4,flipx,flipy,1);
            actualiza_gfx_sprite(x,y,2,1);
          end;
        end;
      end;
      tiledata_pos:=tiledata_pos+4;
      y:=y+16;
    end;
  end;
end;

procedure update_video_pow;
var
        f:word;
        color:word;
        x,y,nchar:word;
begin
fill_full_screen(2,$7ff);
for f:=$0 to $3ff do begin
  color:=video_ram[((f*4) shr 1)+1] and $7;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
    x:=f div 32;
    y:=f mod 32;
    nchar:=fg_tile_offset+(video_ram[(f*4) shr 1] and $ff);
    put_gfx_trans(x*8,y*8,nchar,color shl 4,1,0);
    gfx[0].buffer[f]:=false;
  end;
end;
poner_sprites(2);
poner_sprites(3);
poner_sprites(1);
actualiza_trozo(0,0,256,256,1,0,0,256,256,2);
actualiza_trozo_final(0,16,256,224,2);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
end;

procedure update_video_ikari3;
var
  f,atrib,nchar:word;
  color,x,y:byte;
begin
fill_full_screen(2,$7ff);
for f:=$0 to $3ff do begin
  atrib:=video_ram[(f*4) shr 1];
  color:=(atrib shr 12) and $7;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
    x:=f div 32;
    y:=f mod 32;
    nchar:=atrib and $7ff;
    if (atrib and $8000)<>0 then put_gfx(x*8,y*8,nchar,color shl 4,1,0)
      else put_gfx_trans(x*8,y*8,nchar,color shl 4,1,0);
    gfx[0].buffer[f]:=false;
  end;
end;
poner_sprites(2);
poner_sprites(3);
poner_sprites(1);
actualiza_trozo(0,0,256,256,1,0,0,256,256,2);
actualiza_trozo_final(0,16,256,224,2);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
end;

procedure eventos_pow;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $Fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $F7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.but2[0] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  //P2
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $Fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $F7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.but2[1] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
  //COIN
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
end;
end;

procedure snk68_principal;
var
  frame_m,frame_s:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
frame_s:=z80_0.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to 263 do begin
   //Main CPU
   m68000_0.run(frame_m);
   frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
   //Sound CPU
   z80_0.run(frame_s);
   frame_s:=frame_s+z80_0.tframes-z80_0.contador;
   if f=239 then begin
      m68000_0.irq[1]:=HOLD_LINE;
      update_video_nmk68;
   end;
 end;
 eventos_pow;
 video_sync;
end;
end;

function pow_getword(direccion:dword):word;
begin
case direccion of
  $0..$3ffff:pow_getword:=rom[direccion shr 1];
  $40000..$43fff:pow_getword:=ram[(direccion and $3fff) shr 1];
  $80000:pow_getword:=(marcade.in1 shl 8)+marcade.in0;
  $c0000:pow_getword:=marcade.in2;
  $f0000:pow_getword:=(dsw1 shl 8) or $ff;
  $f0008:pow_getword:=$00ff;
  $f8000:pow_getword:=sound_stat shl 8;
  $100000..$101fff:pow_getword:=video_ram[(direccion and $fff) shr 1] or $ff00;
  $200000..$207fff:if (direccion and $2)=0 then pow_getword:=sprite_ram[(direccion and $7fff) shr 1] or $ff00
                      else pow_getword:=sprite_ram[(direccion and $7fff) shr 1];
  $400000..$400fff:pow_getword:=buffer_paleta[(direccion and $fff) shr 1];
end;
end;

procedure cambiar_color(tmp_color,numero:word);inline;
var
  color:tcolor;
begin
  color.r:=pal5bit(((tmp_color shr 7) and $1e) or ((tmp_color shr 14) and $01));
  color.g:=pal5bit(((tmp_color shr 3) and $1e) or ((tmp_color shr 13) and $01));
  color.b:=pal5bit(((tmp_color shl 1) and $1e) or ((tmp_color shr 12) and $01));
  set_pal_color(color,numero);
  buffer_color[(numero shr 4) and $7]:=true;
end;

procedure pow_putword(direccion:dword;valor:word);
begin
case direccion of
    0..$3ffff:;
    $40000..$43fff:ram[(direccion and $3fff) shr 1]:=valor;
    $80000:begin
          sound_latch:=valor shr 8;
          z80_0.change_nmi(PULSE_LINE);
         end;
    $c0000:begin
            fg_tile_offset:=(valor and $70) shl 4;
            sprite_flip:=(valor and 4)<>0;
         end;
    $100000..$101fff:if video_ram[(direccion and $fff) shr 1]<>valor then begin
                        video_ram[(direccion and $fff) shr 1]:=valor;
                        gfx[0].buffer[(direccion and $fff) div 4]:=true;
                     end;
    $200000..$207fff:sprite_ram[(direccion and $7fff) shr 1]:=valor;
    $400000..$400fff:if buffer_paleta[(direccion and $fff) shr 1]<>valor then begin
                        buffer_paleta[(direccion and $fff) shr 1]:=valor;
                        cambiar_color(valor,(direccion and $fff) shr 1);
                     end;
  end;
end;

function pow_snd_getbyte(direccion:word):byte;
begin
if direccion=$f800 then pow_snd_getbyte:=sound_latch
  else pow_snd_getbyte:=mem_snd[direccion];
end;

procedure pow_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$efff:;
  $f800:sound_stat:=valor;
    else mem_snd[direccion]:=valor;
end;
end;

function pow_snd_inbyte(puerto:word):byte;
begin
if (puerto and $ff)=0 then pow_snd_inbyte:=ym3812_0.status;
end;

procedure pow_snd_outbyte(puerto:word;valor:byte);
begin
case (puerto and $ff) of
  $00:ym3812_0.control(valor);
  $20:ym3812_0.write(valor);
  $40:begin
        upd7759_0.port_w(valor);
      	upd7759_0.start_w(0);
      	upd7759_0.start_w(1);
      end;
  $80:upd7759_0.reset_w(valor and $80);
end;
end;

procedure snk68_sound_update;
begin
  YM3812_0.update;
  upd7759_0.update;
end;

procedure snd_irq(irqstate:byte);
begin
  z80_0.change_irq(irqstate);
end;

//Ikari 3
function ikari3_getword(direccion:dword):word;
begin
case direccion of
  $0..$3ffff:ikari3_getword:=rom[direccion shr 1];
  $40000..$43fff:ikari3_getword:=ram[(direccion and $3fff) shr 1];
  $80000:ikari3_getword:=marcade.in0 xor protection;
  $80002:ikari3_getword:=marcade.in1 xor protection;
  $80004:ikari3_getword:=marcade.in2 xor protection;
  $f0000:ikari3_getword:=$00ff;
  $f0008:ikari3_getword:=$80ff;
  $f8000:ikari3_getword:=sound_stat shl 8;
  $100000..$107fff:if (direccion and $2)=0 then ikari3_getword:=sprite_ram[(direccion and $7fff) shr 1] or $ff00
                      else ikari3_getword:=sprite_ram[(direccion and $7fff) shr 1];
  $200000..$201fff:ikari3_getword:=video_ram[(direccion and $fff) shr 1];
  $300000..$33ffff:ikari3_getword:=rom2[(direccion and $3ffff) shr 1];
  $400000..$400fff:ikari3_getword:=buffer_paleta[(direccion and $fff) shr 1];
end;
end;

procedure ikari3_putword(direccion:dword;valor:word);
begin
case direccion of
    0..$3ffff,$300000..$33ffff:;
    $40000..$43fff:ram[(direccion and $3fff) shr 1]:=valor;
    $80000:begin
             sound_latch:=valor shr 8;
             z80_0.change_nmi(PULSE_LINE);
         end;
    $80006:if (valor=7) then protection:=$ff
            else protection:=0;
    $c0000:sprite_flip:=(valor and $4)<>0;
    $100000..$107fff:sprite_ram[(direccion and $7fff) shr 1]:=valor;
    $200000..$201fff:if video_ram[(direccion and $fff) shr 1]<>valor then begin
                        video_ram[(direccion and $fff) shr 1]:=valor;
                        gfx[0].buffer[(direccion and $fff) div 4]:=true;
                     end;
    $400000..$400fff:if (buffer_paleta[(direccion and $fff) shr 1]<>valor) then begin
                        buffer_paleta[(direccion and $fff) shr 1]:=valor;
                        cambiar_color(valor,((direccion and $fff) shr 1));
                     end;
  end;
end;

//Main
procedure reset_snk68;
begin
 m68000_0.reset;
 z80_0.reset;
 ym3812_0.reset;
 upd7759_0.reset;
 reset_audio;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 fg_tile_offset:=0;
 sound_latch:=0;
 sound_stat:=0;
 protection:=0;
 sprite_flip:=false;
end;

function iniciar_snk68:boolean;
const
  pc_x:array[0..7] of dword=(8*8+3, 8*8+2, 8*8+1, 8*8+0, 3, 2, 1, 0);
  pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
  ps_x:array[0..15] of dword=(32*8+7,32*8+6,32*8+5,32*8+4,32*8+3,32*8+2,32*8+1,32*8+0,
		7,6,5,4,3,2,1,0);
  ps_y:array[0..15] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16,
		8*16, 9*16, 10*16, 11*16, 12*16, 13*16, 14*16, 15*16 );
var
  memoria_temp:pbyte;

procedure convert_chars;
begin
  init_gfx(0,8,8,$800);
  gfx[0].trans[0]:=true;
  gfx_set_desc_data(4,0,16*8,0,4,$800*16*8+0,$800*16*8+4);
  convert_gfx(0,0,memoria_temp,@pc_x,@pc_y,false,false);
end;

procedure convert_sprites(num:dword);
begin
  init_gfx(1,16,16,num);
  gfx[1].trans[0]:=true;
  gfx_set_desc_data(4,0,64*8,0,8,num*64*8+0,num*64*8+8);
  convert_gfx(1,0,memoria_temp,@ps_x,@ps_y,false,false);
end;

begin
llamadas_maquina.bucle_general:=snk68_principal;
llamadas_maquina.reset:=reset_snk68;
llamadas_maquina.fps_max:=59.185606;
iniciar_snk68:=false;
iniciar_audio(false);
screen_init(1,256,256,true);
screen_init(2,512,512,false,true);
//SIEMPRE ANTES DE INICIAR EL VIDEO!!!
if main_vars.tipo_maquina=150 then main_screen.rot90_screen:=true;
iniciar_video(256,224);
//Main CPU
getmem(memoria_temp,$400000);
m68000_0:=cpu_m68000.create(9000000,264);
//Sound CPU
z80_0:=cpu_z80.create(4000000,264);
z80_0.change_ram_calls(pow_snd_getbyte,pow_snd_putbyte);
z80_0.change_io_calls(pow_snd_inbyte,pow_snd_outbyte);
z80_0.init_sound(snk68_sound_update);
//Sound Chips
ym3812_0:=ym3812_chip.create(YM3812_FM,4000000);
ym3812_0.change_irq_calls(snd_irq);
upd7759_0:=upd7759_chip.create(0.5);
case main_vars.tipo_maquina of
  136:begin //POW
        m68000_0.change_ram16_calls(pow_getword,pow_putword);
        //cargar roms
        if not(roms_load16w(@rom,pow_rom)) then exit;
        //cargar sonido
        if not(roms_load(@mem_snd,pow_sound)) then exit;
        //ADPCM Sounds
        if not(roms_load(upd7759_0.get_rom_addr,pow_upd)) then exit;
        //convertir chars
        if not(roms_load(memoria_temp,pow_char)) then exit;
        convert_chars;
        //sprites
        if not(roms_load16b(memoria_temp,pow_sprites)) then exit;
        convert_sprites($4000);
        is_pow:=true;
        dsw1:=$10;
        update_video_nmk68:=update_video_pow;
      end;
  137:begin  //Street Smart
        m68000_0.change_ram16_calls(pow_getword,pow_putword);
        //cargar roms
        if not(roms_load16w(@rom,streetsm_rom)) then exit;
        //cargar sonido
        if not(roms_load(@mem_snd,streetsm_sound)) then exit;
        //ADPCM Sounds
        if not(roms_load(upd7759_0.get_rom_addr,streetsm_upd)) then exit;
        //convertir chars
        if not(roms_load(memoria_temp,streetsm_char)) then exit;
        convert_chars;
        //sprites
        if not(roms_load(memoria_temp,streetsm_sprites)) then exit;
        convert_sprites($8000);
        is_pow:=false;
        dsw1:=0;
        update_video_nmk68:=update_video_pow;
      end;
  149:begin //Ikari 3
        m68000_0.change_ram16_calls(ikari3_getword,ikari3_putword);
        //cargar roms
        if not(roms_load16w(@rom,ikari3_rom)) then exit;
        if not(roms_load16w(@rom2,ikari3_rom2)) then exit;
        //cargar sonido
        if not(roms_load(@mem_snd,ikari3_sound)) then exit;
        //ADPCM Sounds
        if not(roms_load(upd7759_0.get_rom_addr,ikari3_upd)) then exit;
        //convertir chars
        if not(roms_load(memoria_temp,ikari3_char)) then exit;
        convert_chars;
        //sprites
        if not(roms_load16b(memoria_temp,ikari3_sprites)) then exit;
        convert_sprites($8000);
        is_pow:=false;
        update_video_nmk68:=update_video_ikari3;
      end;
  150:begin //Search and Rescue
        m68000_0.change_ram16_calls(ikari3_getword,ikari3_putword);
        //cargar roms
        if not(roms_load16w(@rom,sar_rom)) then exit;
        if not(roms_load16w(@rom2,sar_rom2)) then exit;
        //cargar sonido
        if not(roms_load(@mem_snd,sar_sound)) then exit;
        //ADPCM Sounds
        if not(roms_load(upd7759_0.get_rom_addr,sar_upd)) then exit;
        //convertir chars
        if not(roms_load(memoria_temp,sar_char)) then exit;
        convert_chars;
        //sprites
        if not(roms_load(memoria_temp,sar_sprites)) then exit;
        convert_sprites($8000);
        is_pow:=false;
        update_video_nmk68:=update_video_ikari3;
      end;
end;
//final
freemem(memoria_temp);
reset_snk68;
iniciar_snk68:=true;
end;

end.
