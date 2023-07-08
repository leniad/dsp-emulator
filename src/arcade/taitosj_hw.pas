unit taitosj_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,ay_8910,gfx_engine,rom_engine,
     pal_engine,sound_engine,timer_engine,dac,m6805;

function taitosj_iniciar:boolean;

implementation
const
        //Elevator Action
        elevator_rom:array[0..3] of tipo_roms=(
        (n:'ba3__01.2764.ic1';l:$2000;p:0;crc:$da775a24),(n:'ba3__02.2764.ic2';l:$2000;p:$2000;crc:$fbfd8b3a),
        (n:'ba3__03-1.2764.ic3';l:$2000;p:$4000;crc:$a2e69833),(n:'ba3__04-1.2764.ic6';l:$2000;p:$6000;crc:$2b78c462));
        elevator_sonido:array[0..1] of tipo_roms=(
        (n:'ba3__09.2732.ic70';l:$1000;p:0;crc:$6d5f57cb),(n:'ba3__10.2732.ic71';l:$1000;p:$1000;crc:$f0a769a1));
        elevator_mcu:tipo_roms=(n:'ba3__11.mc68705p3.ic24';l:$800;p:0;crc:$9ce75afc);
        elevator_char:array[0..3] of tipo_roms=(
        (n:'ba3__05.2764.ic4';l:$2000;p:0;crc:$6c4ee58f),(n:'ba3__06.2764.ic5';l:$2000;p:$2000;crc:$41ab0afc),
        (n:'ba3__07.2764.ic9';l:$2000;p:$4000;crc:$efe43731),(n:'ba3__08.2764.ic10';l:$2000;p:$6000;crc:$3ca20696));
        elevator_prom:tipo_roms=(n:'eb16.22';l:$100;p:0;crc:$b833b5ea);
        elevator_dip_a:array [0..5] of def_dip=(
        (mask:$3;name:'Bonus Life';number:4;dip:((dip_val:$3;dip_name:'10000'),(dip_val:$2;dip_name:'15000'),(dip_val:$1;dip_name:'20000'),(dip_val:$0;dip_name:'25000'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Free Play';number:2;dip:((dip_val:$4;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$18;name:'Lives';number:4;dip:((dip_val:$18;dip_name:'3'),(dip_val:$10;dip_name:'4'),(dip_val:$8;dip_name:'5'),(dip_val:$0;dip_name:'6'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Flip Screen';number:2;dip:((dip_val:$40;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$80;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        elevator_dip_c:array [0..5] of def_dip=(
        (mask:$3;name:'Difficulty';number:4;dip:((dip_val:$3;dip_name:'Easiest'),(dip_val:$2;dip_name:'Easy'),(dip_val:$1;dip_name:'Normal'),(dip_val:$0;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Coinage Display';number:2;dip:((dip_val:$10;dip_name:'Coins/Credits'),(dip_val:$0;dip_name:'Insert Coin'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Year Display';number:2;dip:((dip_val:$0;dip_name:'No'),(dip_val:$20;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Hit Detection';number:2;dip:((dip_val:$40;dip_name:'Normal Game'),(dip_val:$0;dip_name:'No Hit'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Coin Slots';number:2;dip:((dip_val:$80;dip_name:'A and B'),(dip_val:$0;dip_name:'A only'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        //Jungle King
        junglek_rom:array[0..8] of tipo_roms=(
        (n:'kn21-1.bin';l:$1000;p:0;crc:$45f55d30),(n:'kn22-1.bin';l:$1000;p:$1000;crc:$07cc9a21),
        (n:'kn43.bin';l:$1000;p:$2000;crc:$a20e5a48),(n:'kn24.bin';l:$1000;p:$3000;crc:$19ea7f83),
        (n:'kn25.bin';l:$1000;p:$4000;crc:$844365ea),(n:'kn46.bin';l:$1000;p:$5000;crc:$27a95fd5),
        (n:'kn47.bin';l:$1000;p:$6000;crc:$5c3199e0),(n:'kn28.bin';l:$1000;p:$7000;crc:$194a2d09),
        (n:'kn60.bin';l:$1000;p:$8000;crc:$1a9c0a26));
        junglek_sonido:array[0..2] of tipo_roms=(
        (n:'kn37.bin';l:$1000;p:0;crc:$dee7f5d4),(n:'kn38.bin';l:$1000;p:$1000;crc:$bffd3d21),
        (n:'kn59-1.bin';l:$1000;p:$2000;crc:$cee485fc));
        junglek_char:array[0..7] of tipo_roms=(
        (n:'kn29.bin';l:$1000;p:0;crc:$8f83c290),(n:'kn30.bin';l:$1000;p:$1000;crc:$89fd19f1),
        (n:'kn51.bin';l:$1000;p:$2000;crc:$70e8fc12),(n:'kn52.bin';l:$1000;p:$3000;crc:$bcbac1a3),
        (n:'kn53.bin';l:$1000;p:$4000;crc:$b946c87d),(n:'kn34.bin';l:$1000;p:$5000;crc:$320db2e1),
        (n:'kn55.bin';l:$1000;p:$6000;crc:$70aef58f),(n:'kn56.bin';l:$1000;p:$7000;crc:$932eb667));
        junglek_prom:tipo_roms=(n:'eb16.22';l:$100;p:0;crc:$b833b5ea);
        junglek_dip_a:array [0..4] of def_dip=(
        (mask:$3;name:'Finish Bonus';number:4;dip:((dip_val:$3;dip_name:'None'),(dip_val:$2;dip_name:'Timer x1'),(dip_val:$1;dip_name:'Timer x2'),(dip_val:$0;dip_name:'Timer x3'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$18;name:'Lives';number:4;dip:((dip_val:$18;dip_name:'3'),(dip_val:$10;dip_name:'4'),(dip_val:$8;dip_name:'5'),(dip_val:$0;dip_name:'6'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Flip Screen';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$40;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$80;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        junglek_dip_c:array [0..4] of def_dip=(
        (mask:$3;name:'Bonus Life';number:4;dip:((dip_val:$2;dip_name:'10000'),(dip_val:$1;dip_name:'20000'),(dip_val:$0;dip_name:'30000'),(dip_val:$3;dip_name:'None'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Year Display';number:2;dip:((dip_val:$0;dip_name:'No'),(dip_val:$20;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Infinite Lives';number:2;dip:((dip_val:$40;dip_name:'No'),(dip_val:$0;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Coin Slots';number:2;dip:((dip_val:$80;dip_name:'A and B'),(dip_val:$0;dip_name:'A only'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        //General
        coin_dip:array [0..2] of def_dip=(
        (mask:$0f;name:'Coin A';number:16;dip:((dip_val:$0f;dip_name:'9C 1C'),(dip_val:$0e;dip_name:'8C 1C'),(dip_val:$0d;dip_name:'7C 1C'),(dip_val:$0c;dip_name:'6C 1C'),(dip_val:$0b;dip_name:'5C 1C'),(dip_val:$0a;dip_name:'4C 1C'),(dip_val:$09;dip_name:'3C 1C'),(dip_val:$08;dip_name:'2C 1C'),(dip_val:$00;dip_name:'1C 1C'),(dip_val:$01;dip_name:'1C 2C'),(dip_val:$02;dip_name:'1C 3C'),(dip_val:$03;dip_name:'1C 4C'),(dip_val:$04;dip_name:'1C 5C'),(dip_val:$05;dip_name:'1C 6C'),(dip_val:$06;dip_name:'1C 7C'),(dip_val:$07;dip_name:'1C 8C'))),
        (mask:$f0;name:'Coin B';number:16;dip:((dip_val:$f0;dip_name:'9C 1C'),(dip_val:$e0;dip_name:'8C 1C'),(dip_val:$d0;dip_name:'7C 1C'),(dip_val:$c0;dip_name:'6C 1C'),(dip_val:$b0;dip_name:'5C 1C'),(dip_val:$a0;dip_name:'4C 1C'),(dip_val:$90;dip_name:'3C 1C'),(dip_val:$80;dip_name:'2C 1C'),(dip_val:$00;dip_name:'1C 1C'),(dip_val:$10;dip_name:'1C 2C'),(dip_val:$20;dip_name:'1C 3C'),(dip_val:$30;dip_name:'1C 4C'),(dip_val:$40;dip_name:'1C 5C'),(dip_val:$50;dip_name:'1C 6C'),(dip_val:$60;dip_name:'1C 7C'),(dip_val:$70;dip_name:'1C 8C'))),());

var
 memoria_rom:array[0..1,0..$1fff] of byte;
 gfx_rom:array[0..$7fff] of byte;
 rweights,gweights,bweights:array[0..2] of single;
 collision_reg:array[0..3] of byte;
 scroll:array[0..5] of byte;
 colorbank:array[0..1] of byte;
 scroll_y:array[0..$5f] of word;
 draw_order:array[0..31,0..3] of byte;
 gfx_pos:word;
 video_priority,soundlatch,rom_bank,video_mode,dac_out,dac_vol:byte;
 sound_semaphore,rechars1,rechars2:boolean;
 sound_nmi:array[0..1] of boolean;
 pos_x:array[0..4] of shortint;
 //mcu
 mcu_mem:array[0..$7ff] of byte;
 mcu_toz80,mcu_address,mcu_fromz80,mcu_portA_in,mcu_portA_out:byte;
 mcu_zaccept,mcu_zready,mcu_busreq:boolean;

procedure update_video_taitosj;
const
  ps_x:array[0..15] of dword=(7, 6, 5, 4, 3, 2, 1, 0,
  	  	8*8+7, 8*8+6, 8*8+5, 8*8+4, 8*8+3, 8*8+2, 8*8+1, 8*8+0);
  ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
  			16*8, 17*8, 18*8, 19*8, 20*8, 21*8, 22*8, 23*8);
procedure conv_chars1;
begin
  gfx_set_desc_data(3,0,8*8,512*8*8,256*8*8,0);
  convert_gfx(0,0,@memoria[$9000],@ps_x,@ps_y,false,false);
  //sprites
  gfx_set_desc_data(3,0,32*8,128*16*16,64*16*16,0);
  convert_gfx(1,0,@memoria[$9000],@ps_x,@ps_y,false,false);
end;

procedure conv_chars2;
begin
  //Chars 2
  gfx_set_desc_data(3,0,8*8,512*8*8,256*8*8,0);
  convert_gfx(2,0,@memoria[$a800],@ps_x,@ps_y,false,false);
  //sprites
  gfx_set_desc_data(3,0,32*8,128*16*16,64*16*16,0);
  convert_gfx(3,0,@memoria[$a800],@ps_x,@ps_y,false,false);
end;

procedure taitosj_putsprites(sprite_offset:byte);
var
  f,sx,sy,nchar,which,atrib,ngfx,offs,color:byte;
begin
// drawing order is a bit strange. The last sprite has to be moved at the start of the list
for f:=$1f downto 0 do begin
  which:=(f-1) and $1f;    // move last sprite at the head of the list
  offs:=which*4;
  if ((which>=$10) and (which<=$17)) then continue;   // no sprites here
  sx:=memoria[$d100+sprite_offset+offs+0]+pos_x[3];
	sy:=240-memoria[$d100+sprite_offset+offs+1]+pos_x[4];
  if (sy<240) then begin
        atrib:=memoria[$d100+sprite_offset+offs+2];
				nchar:=memoria[$d100+sprite_offset+offs+3] and $3f;
        ngfx:=((memoria[$d100+sprite_offset+offs+3] and $40) shr 5) or 1;
				color:=2*((colorbank[1] shr 4) and $03)+((atrib shr 2) and $01);
        put_gfx_sprite(nchar,color shl 3,(atrib and $01)<>0,(atrib and $02)<>0,ngfx);
        actualiza_gfx_sprite(sx,sy,4,ngfx);
  end;
end;
end;

var
  color_back,color_mid,color_front,gfx_back,gfx_mid,gfx_front,nchar,layer:byte;
  f,x,y:word;
  scroll_def:array[0..31] of word;
begin
if rechars1 then begin
  conv_chars1;
  rechars1:=false;
end;
if rechars2 then begin
  conv_chars2;
  rechars2:=false;
end;
color_back:=(colorbank[0] and $07) shl 3;
color_mid:=((colorbank[0] shr 4) and $07) shl 3;
color_front:=(colorbank[1] and $07) shl 3;
gfx_back:=(colorbank[0] and $08) shr 2;
gfx_mid:=(colorbank[0] and $80) shr 6;
gfx_front:=(colorbank[1] and $08) shr 2;
for f:=$0 to $3ff do begin
   //back
   x:=f mod 32;
   y:=f div 32;
   if (video_mode and $10)<>0 then begin
     if gfx[0].buffer[f] then begin
      nchar:=memoria[$c400+f];
      put_gfx_trans(x*8,y*8,nchar,color_back,1,gfx_back);
      gfx[0].buffer[f]:=false;
     end;
   end;
   //mid
   if (video_mode and $20)<>0 then begin
      if gfx[0].buffer[f+$400] then begin
        nchar:=memoria[$c800+f];
        put_gfx_trans(x*8,y*8,nchar,color_mid,2,gfx_mid);
        gfx[0].buffer[f+$400]:=false;
      end;
   end;
   //front
   if (video_mode and $40)<>0 then begin
      if gfx[0].buffer[f+$800] then begin
          nchar:=memoria[$cc00+f];
          put_gfx_trans(x*8,y*8,nchar,color_front,3,gfx_front);
          gfx[0].buffer[f+$800]:=false;
      end;
   end;
end;
fill_full_screen(4,(colorbank[1] and $07) shl 3);
for f:=0 to 3 do begin
  layer:=draw_order[video_priority and $1f,f];
  case layer of
    0:if (video_mode and $80)<>0 then taitosj_putsprites((video_mode and $4) shl 5);
    1:if (video_mode and $10)<>0 then begin
          x:=scroll[0];
          x:=(x and $f8)+((x+3) and 7)+pos_x[0];
          //Ordena los scrolls de la Y!!!
          for y:=0 to $1f do scroll_def[y]:=scroll_y[(y+(x div 8)) and $1f];
          scroll__y_part2(1,4,8,@scroll_def,x,scroll[1]);
      end;
    2:if (video_mode and $20)<>0 then begin
          x:=scroll[2];
          x:=(x and $f8)+((x+1) and 7)+pos_x[1];
          //Ordena los scrolls de la Y!!!
          for y:=0 to $1f do scroll_def[y]:=scroll_y[32+((y+(x div 8)) and $1f)];
          scroll__y_part2(2,4,8,@scroll_def,x,scroll[3]);
      end;
    3:if (video_mode and $40)<>0 then begin
          x:=scroll[4];
          x:=(x and $f8)+((x-1) and 7)+pos_x[2];
          //Ordena los scrolls de la Y!!!
          for y:=0 to $1f do scroll_def[y]:=scroll_y[64+((y+(x div 8)) and $1f)];
          scroll__y_part2(3,4,8,@scroll_def,x,scroll[5]);
      end;
  end;
end;
actualiza_trozo_final(0,16,256,224,4);
end;

procedure eventos_taitosj;
begin
if event.arcade then begin
  //p1
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  //p2
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or 8);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  //System
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 and $bf) else marcade.in2:=(marcade.in2 or $40);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 and $7f) else marcade.in2:=(marcade.in2 or $80);
end;
end;

procedure taitosj_nomcu_principal;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=z80_0.tframes;
frame_s:=z80_1.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
    //Main CPU
    z80_0.run(frame_m);
    frame_m:=frame_m+z80_0.tframes-z80_0.contador;
    //Sound
    z80_1.run(frame_s);
    frame_s:=frame_s+z80_1.tframes-z80_1.contador;
    if f=239 then begin
      z80_0.change_irq(HOLD_LINE);
      update_video_taitosj;
    end;
  end;
  eventos_taitosj;
  video_sync;
end;
end;

function taitosj_nomcu_getbyte(direccion:word):byte;
begin
case direccion of
  0..$5fff,$8000..$87ff,$c000..$cfff,$e000..$ffff:taitosj_nomcu_getbyte:=memoria[direccion];
  $6000..$7fff:taitosj_nomcu_getbyte:=memoria_rom[rom_bank,direccion and $1fff];
  $8800..$8fff:taitosj_nomcu_getbyte:=0;  //Fake MCU
  $d000..$d05f:taitosj_nomcu_getbyte:=scroll_y[direccion and $7f];
  $d200..$d2ff:taitosj_nomcu_getbyte:=buffer_paleta[direccion and $7f];
  $d400..$d4ff:case (direccion and $f) of
                  $0..$3:taitosj_nomcu_getbyte:=collision_reg[direccion and $f];
                  $4..$7:begin
                            if gfx_pos<$8000 then taitosj_nomcu_getbyte:=gfx_rom[gfx_pos]
                              else taitosj_nomcu_getbyte:=0;
                            gfx_pos:=gfx_pos+1;
                         end;
                  $8:taitosj_nomcu_getbyte:=marcade.in0;
                  $9:taitosj_nomcu_getbyte:=marcade.in1;
                  $a:taitosj_nomcu_getbyte:=marcade.dswa;
                  $b:taitosj_nomcu_getbyte:=marcade.in2;
                  $c:taitosj_nomcu_getbyte:=$ef;
                  $d:taitosj_nomcu_getbyte:=marcade.in4 or $f;
                  $f:taitosj_nomcu_getbyte:=ay8910_0.Read;
               end;
end;
end;

procedure taitosj_nomcu_putbyte(direccion:word;valor:byte);
procedure cambiar_color(dir:word);
var
  val,bit0,bit1,bit2:byte;
  color:tcolor;
begin
    dir:=dir and $fe;
    // blue component */
		val:=not(buffer_paleta[dir or 1]);
		bit0:=(val shr 0) and $01;
		bit1:=(val shr 1) and $01;
		bit2:=(val shr 2) and $01;
    color.b:=combine_3_weights(@bweights,bit0,bit1,bit2);
    // green component */
		bit0:=(val shr 3) and $01;
		bit1:=(val shr 4) and $01;
		bit2:=(val shr 5) and $01;
		color.g:=combine_3_weights(@gweights,bit0,bit1,bit2);
		// red component
		bit0:=(val shr 6) and $01;
		bit1:=(val shr 7) and $01;
		val:=not(buffer_paleta[dir]);
		bit2:=(val shr 0) and $01;
		color.r:=combine_3_weights(@rweights,bit0,bit1,bit2);
    set_pal_color(color,dir shr 1);
end;

begin
case direccion of
  0..$7fff,$d700..$ffff:;
  $8000..$87ff,$c000..$c3ff,$d100..$d1ff:memoria[direccion]:=valor;
  $8800..$8fff:; //Fake MCU
	$9000..$a7ff:if memoria[direccion]<>valor then begin
                  rechars1:=true;
                  memoria[direccion]:=valor;
               end;
  $a800..$bfff:if memoria[direccion]<>valor then begin
                  rechars2:=true;
                  memoria[direccion]:=valor;
               end;
  $c400..$cfff:if memoria[direccion]<>valor then begin
                  gfx[0].buffer[direccion-$c400]:=true;
                  memoria[direccion]:=valor;
               end;
  $d000..$d05f:scroll_y[direccion and $7f]:=valor;
  $d200..$d2ff:if buffer_paleta[direccion and $7f]<>valor then begin
                  buffer_paleta[direccion and $7f]:=valor;
                  cambiar_color(direccion and $7f);
               end;
	$d300..$d3ff:video_priority:=valor;
  $d400..$d4ff:case (direccion and $f) of
                  $e:ay8910_0.Control(valor);
                  $f:ay8910_0.Write(valor);
               end;
  $d500..$d5ff:case (direccion and $f) of
                  $0..$5:scroll[direccion and $f]:=valor;
	                $6,$7:if colorbank[direccion and 1]<>valor then begin
                          colorbank[direccion and 1]:=valor;
                          fillchar(gfx[0].buffer,$c00,1);
                        end;
                  $8:fillchar(collision_reg,4,0);
                  $9:gfx_pos:=(gfx_pos and $ff00) or valor;
                  $a:gfx_pos:=(gfx_pos and $ff) or (valor shl 8);
                  $b:begin
                        soundlatch:=valor;
                        sound_nmi[1]:=true;
                        if (sound_nmi[0] and sound_nmi[1]) then z80_1.change_nmi(PULSE_LINE);
                     end;
                  $c:begin
                        sound_semaphore:=(valor and 1)<>0;
	                      if sound_semaphore then z80_1.change_nmi(PULSE_LINE);
                     end;
                  $d:; //WD
                  $e:rom_bank:=valor shr 7;
               end;
  $d600..$d6ff:if video_mode<>valor then begin
                  video_mode:=valor;
                  fillchar(gfx[0].buffer,$c00,1);
                  main_screen.flip_main_x:=(valor and 1)<>0;
                  main_screen.flip_main_y:=(valor and 2)<>0;
               end;
end;
end;

procedure taitosj_mcu_principal;
var
  frame_m,frame_s,frame_mcu:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=z80_0.tframes;
frame_s:=z80_1.tframes;
frame_mcu:=m6805_0.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
    //Main CPU
    z80_0.run(frame_m);
    frame_m:=frame_m+z80_0.tframes-z80_0.contador;
    //Sound
    z80_1.run(frame_s);
    frame_s:=frame_s+z80_1.tframes-z80_1.contador;
    //mcu
    m6805_0.run(frame_mcu);
    frame_mcu:=frame_mcu+m6805_0.tframes-m6805_0.contador;
    if f=239 then begin
      z80_0.change_irq(HOLD_LINE);
      update_video_taitosj;
    end;
  end;
  eventos_taitosj;
  video_sync;
end;
end;

function taitosj_mcu_getbyte(direccion:word):byte;
begin
case direccion of
  0..$87ff,$9000..$ffff:taitosj_mcu_getbyte:=taitosj_nomcu_getbyte(direccion);
  $8800..$8fff:if (direccion and 1)=0 then begin
                  taitosj_mcu_getbyte:=mcu_toz80;
                  mcu_zaccept:=true;
               end else begin
                  taitosj_mcu_getbyte:=not(byte(mcu_zready) or (byte(mcu_zaccept)*2));
               end;
end;
end;

procedure taitosj_mcu_putbyte(direccion:word;valor:byte);
begin
case direccion of
  $0..$7fff:;
  $8000..$87ff,$9000..$ffff:taitosj_nomcu_putbyte(direccion,valor);
  $8800..$8fff:if (direccion and 1)=0 then begin
                  mcu_zready:=true;
	                m6805_0.irq_request(0,ASSERT_LINE);
	                mcu_fromz80:=valor;
               end;
end;
end;

function mcu_taitosj_getbyte(direccion:word):byte;
begin
direccion:=direccion and $7ff;
case direccion of
  0:mcu_taitosj_getbyte:=mcu_portA_in;
  1:mcu_taitosj_getbyte:=$ff;
  2:mcu_taitosj_getbyte:=byte(mcu_zready) or byte(mcu_zaccept)*2 or byte(not(mcu_busreq))*4;
  3..$7ff:mcu_taitosj_getbyte:=mcu_mem[direccion];
end;
end;

procedure mcu_taitosj_putbyte(direccion:word;valor:byte);
begin
direccion:=direccion and $7ff;
case direccion of
  0:mcu_portA_out:=valor;
  1:begin
      if (not(valor) and $01)<>0 then exit;
	    if (not(valor) and $02)<>0 then begin
    		// 68705 is going to read data from the Z80
        mcu_zready:=false;
        m6805_0.irq_request(0,CLEAR_LINE);
		    mcu_portA_in:=mcu_fromz80;
	    end;
	    mcu_busreq:=(not(valor) and $08)<>0;
	    if (not(valor) and $04)<>0 then begin
		    // 68705 is writing data for the Z80
        mcu_toz80:=mcu_portA_out;
	      mcu_zaccept:=false;
	    end;
	    if (not(valor) and $10)<>0 then begin
		    memoria[mcu_address]:=mcu_portA_out;
		    // increase low 8 bits of latched address for burst writes
		    mcu_address:= (mcu_address and $ff00) or ((mcu_address+1) and $ff);
	    end;
	    if (not(valor) and $20)<>0 then mcu_portA_in:=memoria[mcu_address];
	    if (not(valor) and $40)<>0 then mcu_address:=(mcu_address and $ff00) or mcu_portA_out;
	    if (not(valor) and $80)<>0 then mcu_address:=(mcu_address and $00ff) or (mcu_portA_out shl 8);
    end;
  2:;
  3..$7f:mcu_mem[direccion]:=valor;
end;
end;

function taitosj_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$43ff:taitosj_snd_getbyte:=mem_snd[direccion];
  $4801:taitosj_snd_getbyte:=ay8910_1.Read;
  $4803:taitosj_snd_getbyte:=ay8910_2.Read;
  $4805:taitosj_snd_getbyte:=ay8910_3.Read;
  $5000:begin
          sound_nmi[1]:=false;
          taitosj_snd_getbyte:=soundlatch;
        end;
  $5001:taitosj_snd_getbyte:=byte(sound_nmi[1])*8 or byte(sound_semaphore)*4 or 3;
end;
end;

procedure taitosj_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$3fff:;
  $4000..$43ff:mem_snd[direccion]:=valor;
  $4800:ay8910_1.Control(valor);
  $4801:ay8910_1.Write(valor);
  $4802:ay8910_2.Control(valor);
  $4803:ay8910_2.Write(valor);
  $4804:ay8910_3.Control(valor);
  $4805:ay8910_3.Write(valor);
  $5000:soundlatch:=soundlatch and $7f;
  $5001:sound_semaphore:=false;
end;
end;

function ay0_porta_read:byte;
begin
  ay0_porta_read:=marcade.dswb;
end;

function ay0_portb_read:byte;
begin
  ay0_portb_read:=marcade.dswc;
end;

procedure ay1_porta_write(valor:byte);
begin
dac_out:=not(valor);
dac_0.signed_data16_w(dac_out*dac_vol);
end;

procedure ay1_portb_write(valor:byte);
const
  voltable:array[0..$ff] of byte=(
      	$ff,$fe,$fc,$fb,$f9,$f7,$f6,$f4,$f3,$f2,$f1,$ef,$ee,$ec,$eb,$ea,
      	$e8,$e7,$e5,$e4,$e2,$e1,$e0,$df,$de,$dd,$dc,$db,$d9,$d8,$d7,$d6,
      	$d5,$d4,$d3,$d2,$d1,$d0,$cf,$ce,$cd,$cc,$cb,$ca,$c9,$c8,$c7,$c6,
      	$c5,$c4,$c3,$c2,$c1,$c0,$bf,$bf,$be,$bd,$bc,$bb,$ba,$ba,$b9,$b8,
      	$b7,$b7,$b6,$b5,$b4,$b3,$b3,$b2,$b1,$b1,$b0,$af,$ae,$ae,$ad,$ac,
      	$ab,$aa,$aa,$a9,$a8,$a8,$a7,$a6,$a6,$a5,$a5,$a4,$a3,$a2,$a2,$a1,
      	$a1,$a0,$a0,$9f,$9e,$9e,$9d,$9d,$9c,$9c,$9b,$9b,$9a,$99,$99,$98,
      	$97,$97,$96,$96,$95,$95,$94,$94,$93,$93,$92,$92,$91,$91,$90,$90,
      	$8b,$8b,$8a,$8a,$89,$89,$89,$88,$88,$87,$87,$87,$86,$86,$85,$85,
      	$84,$84,$83,$83,$82,$82,$82,$81,$81,$81,$80,$80,$7f,$7f,$7f,$7e,
      	$7e,$7e,$7d,$7d,$7c,$7c,$7c,$7b,$7b,$7b,$7a,$7a,$7a,$79,$79,$79,
      	$78,$78,$77,$77,$77,$76,$76,$76,$75,$75,$75,$74,$74,$74,$73,$73,
      	$73,$73,$72,$72,$72,$71,$71,$71,$70,$70,$70,$70,$6f,$6f,$6f,$6e,
      	$6e,$6e,$6d,$6d,$6d,$6c,$6c,$6c,$6c,$6b,$6b,$6b,$6b,$6a,$6a,$6a,
      	$6a,$69,$69,$69,$68,$68,$68,$68,$68,$67,$67,$67,$66,$66,$66,$66,
      	$65,$65,$65,$65,$64,$64,$64,$64,$64,$63,$63,$63,$63,$62,$62,$62);
begin
dac_vol:=voltable[valor];
dac_0.signed_data16_w(dac_out*dac_vol);
end;

procedure ay2_porta_write(valor:byte);
begin
  marcade.in4:=valor and $f0;
end;

procedure ay3_portb_write(valor:byte);
begin
  sound_nmi[0]:=(not(valor) and 1)<>0;
  if (sound_nmi[0] and sound_nmi[1]) then z80_1.change_nmi(PULSE_LINE);
end;

procedure taitosj_snd_irq;
begin
  z80_1.change_irq(HOLD_LINE);
end;

procedure taitosj_sound_update;
begin
  ay8910_0.update;
  ay8910_1.update;
  ay8910_2.update;
  ay8910_3.update;
  dac_0.update;
end;

//Main
procedure taitosj_reset;
begin
z80_0.reset;
z80_1.reset;
if main_vars.tipo_maquina=185 then m6805_0.reset;
ay8910_0.reset;
ay8910_1.reset;
ay8910_2.reset;
ay8910_3.reset;
dac_0.reset;
reset_audio;
marcade.in0:=$ff;
marcade.in1:=$ff;
marcade.in2:=$ff;
marcade.in4:=0;
fillchar(collision_reg,4,0);
gfx_pos:=0;
video_priority:=0;
fillchar(scroll[0],6,0);
colorbank[0]:=0;
colorbank[1]:=0;
rechars1:=false;
rechars2:=false;
rom_bank:=0;
video_mode:=0;
dac_vol:=0;
sound_semaphore:=false;
sound_nmi[0]:=false;
sound_nmi[1]:=false;
//mcu
mcu_zaccept:=true;
mcu_zready:=false;
mcu_busreq:=false;
end;

function taitosj_iniciar:boolean;
const
  resistances:array[0..2] of integer=(1000,470,270);
var
  memoria_temp:array[0..$8fff] of byte;
  i,j,mask,data:byte;
begin
taitosj_iniciar:=false;
case main_vars.tipo_maquina of
  185:llamadas_maquina.bucle_general:=taitosj_mcu_principal;
  189:llamadas_maquina.bucle_general:=taitosj_nomcu_principal;
end;
llamadas_maquina.reset:=taitosj_reset;
iniciar_audio(false);
//Back
screen_init(1,256,256,true);
screen_mod_scroll(1,256,256,255,256,256,255);
//Mid
screen_init(2,256,256,true);
screen_mod_scroll(2,256,256,255,256,256,255);
//Front
screen_init(3,256,256,true);
screen_mod_scroll(3,256,256,255,256,256,255);
screen_init(4,256,256,false,true); //Final
iniciar_video(256,224);
//Main CPU
z80_0:=cpu_z80.create(4000000,256);
//Sound CPU
z80_1:=cpu_z80.create(3000000,256);
z80_1.change_ram_calls(taitosj_snd_getbyte,taitosj_snd_putbyte);
z80_1.init_sound(taitosj_sound_update);
//IRQ sonido
timers.init(z80_1.numero_cpu,3000000/(6000000/(4*16*16*10*16)),taitosj_snd_irq,nil,true);
//Sound Chip
ay8910_0:=ay8910_chip.create(1500000,AY8910,0.15);
ay8910_0.change_io_calls(ay0_porta_read,ay0_portb_read,nil,nil);
ay8910_1:=ay8910_chip.create(1500000,AY8910,0.5);
ay8910_1.change_io_calls(nil,nil,ay1_porta_write,ay1_portb_write);
ay8910_2:=ay8910_chip.create(1500000,AY8910,0.5);
ay8910_2.change_io_calls(nil,nil,ay2_porta_write,nil);
ay8910_3:=ay8910_chip.create(1500000,AY8910,1);
ay8910_3.change_io_calls(nil,nil,nil,ay3_portb_write);
dac_0:=dac_chip.create(0.15);
case main_vars.tipo_maquina of
  185:begin  //Elevator Action
        z80_0.change_ram_calls(taitosj_mcu_getbyte,taitosj_mcu_putbyte);
        //cargar roms
        if not(roms_load(@memoria_temp,elevator_rom)) then exit;
        //Poner roms en sus bancos
        copymemory(@memoria[0],@memoria_temp[0],$6000);
        copymemory(@memoria_rom[0,0],@memoria_temp[$6000],$2000);
        copymemory(@memoria_rom[1,0],@memoria_temp[$6000],$1000);
        copymemory(@memoria_rom[1,$1000],@memoria_temp[$8000],$1000);
        //cargar roms sonido
        if not(roms_load(@mem_snd,elevator_sonido)) then exit;
        //MCU CPU
        if not(roms_load(@mcu_mem,elevator_mcu)) then exit;
        m6805_0:=cpu_m6805.create(3000000,256,tipo_m68705);
        m6805_0.change_ram_calls(mcu_taitosj_getbyte,mcu_taitosj_putbyte);
        //cargar chars
        if not(roms_load(@gfx_rom,elevator_char)) then exit;
        //Calculo de prioridades
        if not(roms_load(@memoria_temp,elevator_prom)) then exit;
        marcade.dswa:=$7f;
        marcade.dswa_val:=@elevator_dip_a;
        marcade.dswc:=$ff;
        marcade.dswc_val:=@elevator_dip_c;
        pos_x[0]:=-8;
        pos_x[1]:=-23;
        pos_x[2]:=-21;
        pos_x[3]:=-2;
        pos_x[4]:=0;
      end;
  189:begin //Jungle King
        main_screen.rot180_screen:=true;
        z80_0.change_ram_calls(taitosj_nomcu_getbyte,taitosj_nomcu_putbyte);
        //cargar roms
        if not(roms_load(@memoria_temp,junglek_rom)) then exit;
        //Poner roms en sus bancos
        copymemory(@memoria[0],@memoria_temp[0],$6000);
        copymemory(@memoria_rom[0,0],@memoria_temp[$6000],$2000);
        copymemory(@memoria_rom[1,0],@memoria_temp[$6000],$1000);
        copymemory(@memoria_rom[1,$1000],@memoria_temp[$8000],$1000);
        //cargar roms sonido
        if not(roms_load(@mem_snd,junglek_sonido)) then exit;
        //cargar chars
        if not(roms_load(@gfx_rom,junglek_char)) then exit;
        //Calculo de prioridades
        if not(roms_load(@memoria_temp,junglek_prom)) then exit;
        marcade.dswa:=$3f;
        marcade.dswa_val:=@junglek_dip_a;
        marcade.dswc:=$ff;
        marcade.dswc_val:=@junglek_dip_c;
        pos_x[0]:=8;
        pos_x[1]:=10;
        pos_x[2]:=12;
        pos_x[3]:=1;
        pos_x[4]:=-2;
  end;
end;
//crear gfx
init_gfx(0,8,8,256);
gfx[0].trans[0]:=true;
init_gfx(1,16,16,64);
gfx[1].trans[0]:=true;
init_gfx(2,8,8,256);
gfx[2].trans[0]:=true;
init_gfx(3,16,16,64);
gfx[3].trans[0]:=true;
marcade.dswb:=$0;
marcade.dswb_val:=@coin_dip;
for i:=0 to $1f do begin
		mask:=0;
    // start with all four layers active, so we'll get the highest
    // priority one in the first loop
		for j:=3 downto 0 do begin
			data:=memoria_temp[$10*(i and $0f)+mask] and $0f;
  		if (i and $10)<>0 then data:=data shr 2
  			else data:=data and $03;
      mask:=mask or (1 shl data);
      // in next loop, we'll see which of the remaining
      // layers has top priority when this one is transparent
	 		draw_order[i,j]:=data;
		end;
end;
//precalculo de la paleta
compute_resistor_weights(0,255,-1.0,
			3,@resistances[0],@rweights[0],0,0,
			3,@resistances[0],@gweights[0],0,0,
			3,@resistances[0],@bweights[0],0,0);
//final
taitosj_reset;
taitosj_iniciar:=true;
end;

end.
