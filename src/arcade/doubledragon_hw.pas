unit doubledragon_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     hd6309,m680x,m6809,nz80,ym_2151,msm5205,main_engine,controls_engine,
     gfx_engine,oki6295,rom_engine,pal_engine,sound_engine;

function iniciar_ddragon:boolean;

implementation
const
        //Double Dragon
        ddragon_rom:array[0..3] of tipo_roms=(
        (n:'21j-1-5.26';l:$8000;p:$0;crc:$42045dfd),(n:'21j-2-3.25';l:$8000;p:$8000;crc:$5779705e),
        (n:'21j-3.24';l:$8000;p:$10000;crc:$3bdea613),(n:'21j-4-1.23';l:$8000;p:$18000;crc:$728f87b9));
        ddragon_sub:tipo_roms=(n:'63701.bin';l:$4000;p:$c000;crc:$f5232d03);
        ddragon_snd:tipo_roms=(n:'21j-0-1';l:$8000;p:$8000;crc:$9efa95bb);
        ddragon_char:tipo_roms=(n:'21j-5';l:$8000;p:0;crc:$7a8b8db4);
        ddragon_tiles:array[0..3] of tipo_roms=(
        (n:'21j-8';l:$10000;p:0;crc:$7c435887),(n:'21j-9';l:$10000;p:$10000;crc:$c6640aed),
        (n:'21j-i';l:$10000;p:$20000;crc:$5effb0a0),(n:'21j-j';l:$10000;p:$30000;crc:$5fb42e7c));
        ddragon_sprites:array[0..7] of tipo_roms=(
        (n:'21j-a';l:$10000;p:0;crc:$574face3),(n:'21j-b';l:$10000;p:$10000;crc:$40507a76),
        (n:'21j-c';l:$10000;p:$20000;crc:$bb0bc76f),(n:'21j-d';l:$10000;p:$30000;crc:$cb4f231b),
        (n:'21j-e';l:$10000;p:$40000;crc:$a0a0c261),(n:'21j-f';l:$10000;p:$50000;crc:$6ba152f6),
        (n:'21j-g';l:$10000;p:$60000;crc:$3220a0b6),(n:'21j-h';l:$10000;p:$70000;crc:$65c7517d));
        ddragon_adpcm:array[0..1] of tipo_roms=(
        (n:'21j-6';l:$10000;p:0;crc:$34755de3),(n:'21j-7';l:$10000;p:$10000;crc:$904de6f8));
        //Double Dragon II
        ddragon2_rom:array[0..3] of tipo_roms=(
        (n:'26a9-04.bin';l:$8000;p:$0;crc:$f2cfc649),(n:'26aa-03.bin';l:$8000;p:$8000;crc:$44dd5d4b),
        (n:'26ab-0.bin';l:$8000;p:$10000;crc:$49ddddcd),(n:'26ac-0e.63';l:$8000;p:$18000;crc:$57acad2c));
        ddragon2_sub:tipo_roms=(n:'26ae-0.bin';l:$10000;p:$0;crc:$ea437867);
        ddragon2_snd:tipo_roms=(n:'26ad-0.bin';l:$8000;p:$0;crc:$75e36cd6);
        ddragon2_char:tipo_roms=(n:'26a8-0e.19';l:$10000;p:0;crc:$4e80cd36);
        ddragon2_tiles:array[0..1] of tipo_roms=(
        (n:'26j4-0.bin';l:$20000;p:0;crc:$a8c93e76),(n:'26j5-0.bin';l:$20000;p:$20000;crc:$ee555237));
        ddragon2_sprites:array[0..5] of tipo_roms=(
        (n:'26j0-0.bin';l:$20000;p:0;crc:$db309c84),(n:'26j1-0.bin';l:$20000;p:$20000;crc:$c3081e0c),
        (n:'26af-0.bin';l:$20000;p:$40000;crc:$3a615aad),(n:'26j2-0.bin';l:$20000;p:$60000;crc:$589564ae),
        (n:'26j3-0.bin';l:$20000;p:$80000;crc:$daf040d6),(n:'26a10-0.bin';l:$20000;p:$a0000;crc:$6d16d889));
        ddragon2_adpcm:array[0..1] of tipo_roms=(
        (n:'26j6-0.bin';l:$20000;p:0;crc:$a84b2a29),(n:'26j7-0.bin';l:$20000;p:$20000;crc:$bc6a48d5));
        //Dip
        ddragon_dip_a:array [0..4] of def_dip=(
        (mask:$7;name:'Coin A';number:8;dip:((dip_val:$0;dip_name:'4C 1C'),(dip_val:$1;dip_name:'3C 1C'),(dip_val:$2;dip_name:'2C 1C'),(dip_val:$7;dip_name:'1C 1C'),(dip_val:$6;dip_name:'1C 2C'),(dip_val:$5;dip_name:'1C 3C'),(dip_val:$4;dip_name:'1C 4C'),(dip_val:$3;dip_name:'1C 5C'),(),(),(),(),(),(),(),())),
        (mask:$38;name:'Coin B';number:8;dip:((dip_val:$0;dip_name:'4C 1C'),(dip_val:$8;dip_name:'3C 1C'),(dip_val:$10;dip_name:'2C 1C'),(dip_val:$38;dip_name:'1C 1C'),(dip_val:$30;dip_name:'1C 2C'),(dip_val:$28;dip_name:'1C 3C'),(dip_val:$20;dip_name:'1C 4C'),(dip_val:$18;dip_name:'1C 5C'),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Cabinet';number:2;dip:((dip_val:$40;dip_name:'Upright'),(dip_val:$0;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Flip Screen';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        ddragon_dip_b:array [0..4] of def_dip=(
        (mask:$3;name:'Difficulty';number:4;dip:((dip_val:$1;dip_name:'Easy'),(dip_val:$3;dip_name:'Medium'),(dip_val:$2;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$4;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Bonus Life';number:4;dip:((dip_val:$10;dip_name:'20k'),(dip_val:$00;dip_name:'40k'),(dip_val:$30;dip_name:'30k 60k+'),(dip_val:$20;dip_name:'20k 80k+'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Lives';number:4;dip:((dip_val:$c0;dip_name:'2'),(dip_val:$80;dip_name:'3'),(dip_val:$40;dip_name:'4'),(dip_val:$0;dip_name:'Infinite'),(),(),(),(),(),(),(),(),(),(),(),())),());
        ddragon2_dip_b:array [0..5] of def_dip=(
        (mask:$3;name:'Difficulty';number:4;dip:((dip_val:$1;dip_name:'Easy'),(dip_val:$3;dip_name:'Medium'),(dip_val:$2;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$4;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Hurricane Kick';number:2;dip:((dip_val:$0;dip_name:'Easy'),(dip_val:$8;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Timer';number:4;dip:((dip_val:$0;dip_name:'60'),(dip_val:$10;dip_name:'65'),(dip_val:$30;dip_name:'70'),(dip_val:$20;dip_name:'80'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Lives';number:4;dip:((dip_val:$c0;dip_name:'1'),(dip_val:$80;dip_name:'2'),(dip_val:$40;dip_name:'3'),(dip_val:$0;dip_name:'4'),(),(),(),(),(),(),(),(),(),(),(),())),());

        CPU_SYNC=4;

var
 rom:array[0..5,0..$3fff] of byte;
 tipo_video,fg_mask,banco_rom,soundlatch,dd_sub_port:byte;
 scroll_x,scroll_y:word;
 adpcm_mem:array[0..$1ffff] of byte;
 adpcm_data:array[0..1] of byte;
 adpcm_pos,adpcm_end:array[0..1] of dword;
 ddragon_scanline:array[0..271] of word;
 adpcm_ch,adpcm_idle:array [0..1] of boolean;

procedure draw_sprites;inline;
var
  size,x,y,nchar:word;
  f,color,atrib:byte;
  flipx,flipy:boolean;
begin
	for f:=0 to $3f do begin
		atrib:=memoria[$2801+(f*5)];
		if (atrib and $80)<>0 then begin  // visible
			x:=240-memoria[$2804+(f*5)]+((atrib and 2) shl 7);
			y:=240-memoria[$2800+(f*5)]+ ((atrib and 1) shl 8);
			size:=(atrib and $30) shr 4;
			flipx:=(atrib and 8)<>0;
			flipy:=(atrib and 4)<>0;
      if tipo_video<>0 then begin
          color:=((memoria[$2802+(f*5)] shr 5) shl 4)+$80;
			    nchar:=memoria[$2803+(f*5)]+((memoria[$2802+(f*5)] and $1f) shl 8);
      end else begin
          color:=(((memoria[$2802+(f*5)] shr 4) and $07) shl 4)+$80;
			    nchar:=memoria[$2803+(f*5)]+((memoria[$2802+(f*5)] and $0f) shl 8);
      end;
			nchar:=nchar and not(size);
			case size of
				0:begin // normal
             put_gfx_sprite(nchar,color,flipx,flipy,2);
             actualiza_gfx_sprite(x,y,4,2);
				  end;
				1:begin // double y
             put_gfx_sprite_diff(nchar,color,flipx,flipy,2,0,0);
             put_gfx_sprite_diff(nchar+1,color,flipx,flipy,2,0,16);
             actualiza_gfx_sprite_size(x,y-16,4,16,32);
				  end;
				2:begin // double x
             put_gfx_sprite_diff(nchar,color,flipx,flipy,2,0,0);
             put_gfx_sprite_diff(nchar+1,color,flipx,flipy,2,16,0);
             actualiza_gfx_sprite_size(x-16,y,4,32,16);
				  end;
				3:begin
             put_gfx_sprite_diff(nchar,color,flipx,flipy,2,0,0);
             put_gfx_sprite_diff(nchar+1,color,flipx,flipy,2,16,0);
             put_gfx_sprite_diff(nchar+2,color,flipx,flipy,2,0,16);
             put_gfx_sprite_diff(nchar+3,color,flipx,flipy,2,16,16);
             actualiza_gfx_sprite_size(x-16,y-16,4,32,32);
				  end;
			end;
		end;  //visible
	end;  //for
end;

procedure update_video_ddragon;inline;
var
  x,y,color,f,nchar,pos:word;
  atrib:byte;
begin
for f:=$0 to $3ff do begin
  x:=f mod 32;
  y:=f div 32;
  //background
  pos:=(x and $0f)+((y and $0f) shl 4)+((x and $10) shl 4)+((y and $10) shl 5);
  atrib:=memoria[(pos*2)+$3000];
  color:=(atrib and $38) shr 3;
  if (gfx[1].buffer[pos] or buffer_color[color+8]) then begin
      nchar:=memoria[(pos*2)+$3001]+((atrib and $7) shl 8);
      put_gfx_flip(x*16,y*16,nchar,$100+(color shl 4),2,1,(atrib and $40)<>0,(atrib and $80)<>0);
      gfx[1].buffer[pos]:=false;
  end;
  //foreground
  atrib:=memoria[$1800+(f*2)];
  color:=(atrib and $e0) shr 5;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
      nchar:=memoria[$1801+(f*2)]+((atrib and fg_mask) shl 8);
      put_gfx_trans(x*8,y*8,nchar,color shl 4,1,0);
      gfx[0].buffer[f]:=false;
   end;
end;
scroll_x_y(2,4,scroll_x,scroll_y);
draw_sprites;
actualiza_trozo(0,0,256,256,1,0,0,256,256,4);
actualiza_trozo_final(0,8,256,240,4);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
end;

procedure eventos_ddragon;inline;
begin
if event.arcade then begin
  //p1
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  if arcade_input.but2[0] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  //p2
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.coin[0] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  if arcade_input.coin[1] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
  if arcade_input.but2[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
end;
end;

procedure ddragon_principal;
var
  f,l:word;
  frame_m,frame_s,frame_snd:single;
  h:byte;
begin
init_controls(false,false,false,true);
frame_m:=hd6309_0.tframes;
frame_s:=m6800_0.tframes;
frame_snd:=m6809_0.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to 271 do begin
    for h:=1 to CPU_SYNC do begin
      //main
      hd6309_0.run(frame_m);
      frame_m:=frame_m+hd6309_0.tframes-hd6309_0.contador;
      //sub
      m6800_0.run(frame_s);
      frame_s:=frame_s+m6800_0.tframes-m6800_0.contador;
      //snd
      m6809_0.run(frame_snd);
      frame_snd:=frame_snd+m6809_0.tframes-m6809_0.contador;
    end;
    //video
    case ddragon_scanline[f] of
      $8:marcade.in2:=marcade.in2 and $f7;
      $f8:begin
            marcade.in2:=marcade.in2 or 8;
            hd6309_0.change_nmi(ASSERT_LINE);
            update_video_ddragon;
          end;
    end;
    if f<>0 then l:=f-1 else l:=271;
    if (((ddragon_scanline[l] and $8)=0) and ((ddragon_scanline[f] and $8)<>0)) then hd6309_0.change_firq(ASSERT_LINE);
  end;
  eventos_ddragon;
  video_sync;
end;
end;

procedure cambiar_color(pos:word);inline;
var
  tmp_color:byte;
  color:tcolor;
begin
  tmp_color:=buffer_paleta[pos];
  color.r:=pal4bit(tmp_color);
  color.g:=pal4bit(tmp_color shr 4);
  tmp_color:=buffer_paleta[pos+$200];
  color.b:=pal4bit(tmp_color);
  set_pal_color(color,pos);
  case pos of
    0..127:buffer_color[pos shr 4]:=true;
    256..383:buffer_color[((pos shr 4) and $7)+8]:=true;
  end;
end;

function ddragon_getbyte(direccion:word):byte;
begin
    case direccion of
        $0..$fff,$1800..$1fff,$2800..$37ff,$8000..$ffff:ddragon_getbyte:=memoria[direccion];
        $1000..$13ff:ddragon_getbyte:=buffer_paleta[direccion and $3ff];
        $2000..$27ff:if ((m6800_0.get_halt<>CLEAR_LINE) or (m6800_0.get_reset<>CLEAR_LINE)) then ddragon_getbyte:=mem_misc[$8000+(direccion and $1ff)]
                        else ddragon_getbyte:=$ff;
        $3800:ddragon_getbyte:=marcade.in0;
        $3801:ddragon_getbyte:=marcade.in1;
        $3802:ddragon_getbyte:=marcade.in2 or ($10*byte(not(((m6800_0.get_halt<>CLEAR_LINE) or (m6800_0.get_reset<>CLEAR_LINE)))));
        $3803:ddragon_getbyte:=marcade.dswa;
        $3804:ddragon_getbyte:=marcade.dswb;
        $380b:begin
                hd6309_0.change_nmi(CLEAR_LINE);
                ddragon_getbyte:=$ff;
              end;
        $380c:begin
                hd6309_0.change_firq(CLEAR_LINE);
                ddragon_getbyte:=$ff;
              end;
        $380d:begin
                hd6309_0.change_irq(CLEAR_LINE);
                ddragon_getbyte:=$ff;
              end;
        $380e:begin
                m6809_0.change_irq(ASSERT_LINE);
                ddragon_getbyte:=soundlatch;
              end;
        $380f:begin
                m6800_0.change_nmi(ASSERT_LINE);
                ddragon_getbyte:=$ff;
              end;
        $4000..$7fff:ddragon_getbyte:=rom[banco_rom,direccion and $3fff];
    end;
end;

procedure ddragon_putbyte(direccion:word;valor:byte);
begin
case direccion of
        0..$fff,$2800..$2fff:memoria[direccion]:=valor;
        $1000..$13ff:if buffer_paleta[direccion and $3ff]<>valor then begin
                          buffer_paleta[direccion and $3ff]:=valor;
                          cambiar_color(direccion and $1ff);
                     end;
        $1800..$1fff:if memoria[direccion]<>valor then begin
                        gfx[0].buffer[(direccion and $7ff) shr 1]:=true;
                        memoria[direccion]:=valor;
                     end;
        $2000..$27ff:if ((m6800_0.get_halt<>CLEAR_LINE) or (m6800_0.get_reset<>CLEAR_LINE)) then mem_misc[$8000+(direccion and $1ff)]:=valor;
        $3000..$37ff:if memoria[direccion]<>valor then begin
                        gfx[1].buffer[(direccion and $7ff) shr 1]:=true;
                        memoria[direccion]:=valor;
                     end;
        $3808:begin
                scroll_x:=(scroll_x and $ff) or ((valor and $1) shl 8);
                scroll_y:=(scroll_y and $ff) or ((valor and $2) shl 7);
                main_screen.flip_main_screen:=(valor and 4)=0;
                if (valor and $8)<>0 then m6800_0.change_reset(CLEAR_LINE)
                  else m6800_0.change_reset(ASSERT_LINE);
                if (valor and $10)<>0 then m6800_0.change_halt(ASSERT_LINE)
                  else m6800_0.change_halt(CLEAR_LINE);
                banco_rom:=(valor and $e0) shr 5;
              end;
        $3809:scroll_x:=(scroll_x and $100) or valor;
        $380a:scroll_y:=(scroll_y and $100) or valor;
        $380b:hd6309_0.change_nmi(CLEAR_LINE);
        $380c:hd6309_0.change_firq(CLEAR_LINE);
        $380d:hd6309_0.change_irq(CLEAR_LINE);
        $380e:begin
                soundlatch:=valor;
                m6809_0.change_irq(ASSERT_LINE);
              end;
        $380f:m6800_0.change_nmi(ASSERT_LINE);
        $4000..$ffff:; //ROM
end;
end;

function ddragon_sub_getbyte(direccion:word):byte;
begin
  case direccion of
      $0..$1e:ddragon_sub_getbyte:=0;
      $1f..$fff,$8000..$81ff,$c000..$ffff:ddragon_sub_getbyte:=mem_misc[direccion];
  end;
end;

procedure ddragon_sub_putbyte(direccion:word;valor:byte);
begin
case direccion of
  $17:begin
        if (valor and 1)=0 then m6800_0.change_nmi(CLEAR_LINE);
        if (((valor and 2)<>0) and ((dd_sub_port and $2)<>0)) then hd6309_0.change_irq(ASSERT_LINE);
        dd_sub_port:=valor;
      end;
  $1f..$fff,$8000..$81ff:mem_misc[direccion]:=valor;
  $c000..$ffff:; //ROM
end;
end;

function ddragon_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$fff,$8000..$ffff:ddragon_snd_getbyte:=mem_snd[direccion];
  $1000:begin
          ddragon_snd_getbyte:=soundlatch;
          m6809_0.change_irq(CLEAR_LINE);
        end;
  $1800:ddragon_snd_getbyte:=byte(adpcm_idle[0]) or (byte(adpcm_idle[1]) shl 1);
  $2801:ddragon_snd_getbyte:=ym2151_0.status;
end;
end;

procedure ddragon_snd_putbyte(direccion:word;valor:byte);
var
  adpcm_chip:byte;
begin
case direccion of
  0..$fff:mem_snd[direccion]:=valor;
  $2800:ym2151_0.reg(valor);
  $2801:ym2151_0.write(valor);
  $3800..$3807:begin
                  adpcm_chip:=direccion and $1;
                  case ((direccion and $7) shr 1) of
                    3:begin
			                  adpcm_idle[adpcm_chip]:=true;
			                  if adpcm_chip=0 then msm_5205_0.reset_w(1)
                          else msm_5205_1.reset_w(1);
                    end;
		                2:adpcm_pos[adpcm_chip]:=(valor and $7f)*$200;
		                1:adpcm_end[adpcm_chip]:=(valor and $7f)*$200;
		                0:begin
			                  adpcm_idle[adpcm_chip]:=false;
			                  if adpcm_chip=0 then msm_5205_0.reset_w(0)
                          else msm_5205_1.reset_w(0);
                    end;
                  end;
               end;
  $8000..$ffff:; //ROM
end;
end;

procedure ym2151_snd_irq(irqstate:byte);
begin
  m6809_0.change_firq(irqstate);
end;

procedure snd_adpcm0;
begin
if ((adpcm_pos[0]>=adpcm_end[0]) or (adpcm_pos[0]>=$10000)) then begin
		adpcm_idle[0]:=true;
		msm_5205_0.reset_w(1);
end else if not(adpcm_ch[0]) then begin
		          msm_5205_0.data_w(adpcm_data[0] and $0f);
		          adpcm_ch[0]:=true;
	       end else begin
              adpcm_ch[0]:=false;
              adpcm_data[0]:=adpcm_mem[adpcm_pos[0]];
              adpcm_pos[0]:=(adpcm_pos[0]+1) and $ffff;
          		msm_5205_0.data_w(adpcm_data[0] shr 4);
         end;
end;

procedure snd_adpcm1;
begin
if ((adpcm_pos[1]>=adpcm_end[1]) or (adpcm_pos[1]>=$10000)) then begin
		adpcm_idle[1]:=true;
		msm_5205_1.reset_w(1);
	end else if not(adpcm_ch[1]) then begin
		          msm_5205_1.data_w(adpcm_data[1] and $0f);
		          adpcm_ch[1]:=true;
	          end else begin
              adpcm_ch[1]:=false;
              adpcm_data[1]:=adpcm_mem[adpcm_pos[1]+$10000];
              adpcm_pos[1]:=(adpcm_pos[1]+1) and $ffff;
          		msm_5205_1.data_w(adpcm_data[1] shr 4);
            end;
end;

procedure ddragon_sound_update;
begin
  ym2151_0.update;
end;

//Double Dragon II
procedure ddragon2_principal;
var
  f,l:word;
  frame_m,frame_s,frame_snd:single;
  h:byte;
begin
init_controls(false,false,false,true);
frame_m:=hd6309_0.tframes;
frame_s:=z80_0.tframes;
frame_snd:=z80_1.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to 271 do begin
    for h:=1 to CPU_SYNC do begin
      //main
      hd6309_0.run(frame_m);
      frame_m:=frame_m+hd6309_0.tframes-hd6309_0.contador;
      //sub
      z80_0.run(frame_s);
      frame_s:=frame_s+z80_0.tframes-z80_0.contador;
      //snd
      z80_1.run(frame_snd);
      frame_snd:=frame_snd+z80_1.tframes-z80_1.contador;
    end;
    //video
    case ddragon_scanline[f] of
      $8:marcade.in2:=marcade.in2 and $f7;
      $f8:begin
            hd6309_0.change_nmi(ASSERT_LINE);
            update_video_ddragon;
            marcade.in2:=marcade.in2 or 8;
          end;
    end;
    if f<>0 then l:=f-1 else l:=271;
    if (((ddragon_scanline[l] and $8)=0) and ((ddragon_scanline[f] and $8)<>0)) then hd6309_0.change_firq(ASSERT_LINE);
  end;
  eventos_ddragon;
  video_sync;
end;
end;

function ddragon2_getbyte(direccion:word):byte;
begin
    case direccion of
        $0..$1fff,$2800..$37ff,$8000..$ffff:ddragon2_getbyte:=memoria[direccion];
        $2000..$27ff:if ((z80_0.get_halt<>CLEAR_LINE) or (z80_0.get_reset<>CLEAR_LINE)) then ddragon2_getbyte:=mem_misc[$c000+(direccion and $1ff)]
                        else ddragon2_getbyte:=$ff;
        $3800:ddragon2_getbyte:=marcade.in0;
        $3801:ddragon2_getbyte:=marcade.in1;
        $3802:ddragon2_getbyte:=marcade.in2 or $10*byte(not(((z80_0.get_halt<>CLEAR_LINE) or (z80_0.get_reset<>CLEAR_LINE))));
        $3803:ddragon2_getbyte:=marcade.dswa;
        $3804:ddragon2_getbyte:=marcade.dswb;
        $380b:begin
                hd6309_0.change_nmi(CLEAR_LINE);
                ddragon2_getbyte:=$ff;
              end;
        $380c:begin
                hd6309_0.change_firq(CLEAR_LINE);
                ddragon2_getbyte:=$ff;
              end;
        $380d:begin
                hd6309_0.change_irq(CLEAR_LINE);
                ddragon2_getbyte:=$ff;
              end;
        $380e:begin
                z80_1.change_nmi(ASSERT_LINE);
                ddragon2_getbyte:=soundlatch;
              end;
        $380f:begin
                z80_0.change_nmi(ASSERT_LINE);
                ddragon2_getbyte:=$ff;
              end;
        $3c00..$3fff:ddragon2_getbyte:=buffer_paleta[direccion and $3ff];
        $4000..$7fff:ddragon2_getbyte:=rom[banco_rom,direccion and $3fff];
    end;
end;

procedure ddragon2_putbyte(direccion:word;valor:byte);
begin
case direccion of
        0..$17ff,$2800..$2fff:memoria[direccion]:=valor;
        $1800..$1fff:if memoria[direccion]<>valor then begin
                        gfx[0].buffer[(direccion and $7ff) shr 1]:=true;
                        memoria[direccion]:=valor;
                     end;
        $2000..$27ff:if ((z80_0.get_halt<>CLEAR_LINE) or (z80_0.get_reset<>CLEAR_LINE)) then mem_misc[$c000+(direccion and $1ff)]:=valor;
        $3000..$37ff:if memoria[direccion]<>valor then begin
                        gfx[1].buffer[(direccion and $7ff) shr 1]:=true;
                        memoria[direccion]:=valor;
                     end;
        $3808:begin
                scroll_x:=(scroll_x and $ff) or ((valor and $1) shl 8);
                scroll_y:=(scroll_y and $ff) or ((valor and $2) shl 7);
                main_screen.flip_main_screen:=(valor and 4)=0;
                if (valor and $8)<>0 then z80_0.change_reset(CLEAR_LINE)
                  else z80_0.change_reset(ASSERT_LINE);
                if (valor and $10)<>0 then z80_0.change_halt(ASSERT_LINE)
                  else z80_0.change_halt(CLEAR_LINE);
                banco_rom:=(valor and $e0) shr 5;
              end;
        $3809:scroll_x:=(scroll_x and $100) or valor;
        $380a:scroll_y:=(scroll_y and $100) or valor;
        $380b:hd6309_0.change_nmi(CLEAR_LINE);
        $380c:hd6309_0.change_firq(CLEAR_LINE);
        $380d:hd6309_0.change_irq(CLEAR_LINE);
        $380e:begin
                soundlatch:=valor;
                z80_1.change_nmi(ASSERT_LINE);
              end;
        $380f:z80_0.change_nmi(ASSERT_LINE);
        $3c00..$3fff:if buffer_paleta[direccion and $3ff]<>valor then begin
                          buffer_paleta[direccion and $3ff]:=valor;
                          cambiar_color(direccion and $1ff);
                     end;
        $4000..$ffff:; //ROM
end;
end;

function ddragon2_sub_getbyte(direccion:word):byte;
begin
if direccion<$c400 then ddragon2_sub_getbyte:=mem_misc[direccion];
end;

procedure ddragon2_sub_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$bfff:; //ROM
  $c000..$c3ff:mem_misc[direccion]:=valor;
  $d000:z80_0.change_nmi(CLEAR_LINE);
	$e000:hd6309_0.change_irq(ASSERT_LINE);
end;
end;

function ddragon2_snd_getbyte(direccion:word):byte;
begin
case direccion of
    0..$87ff:ddragon2_snd_getbyte:=mem_snd[direccion];
    $8801:ddragon2_snd_getbyte:=ym2151_0.status;
    $9800:ddragon2_snd_getbyte:=oki_6295_0.read;
    $a000:begin
            ddragon2_snd_getbyte:=soundlatch;
            z80_1.change_nmi(CLEAR_LINE);
          end;
  end;
end;

procedure ddragon2_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:; //ROM
  $8000..$87ff:mem_snd[direccion]:=valor;
  $8800:ym2151_0.reg(valor);
  $8801:ym2151_0.write(valor);
  $9800:oki_6295_0.write(valor);
end;
end;

procedure ym2151_snd_irq_dd2(irqstate:byte);
begin
  z80_1.change_irq(irqstate);
end;

procedure dd2_sound_update;
begin
  ym2151_0.update;
  oki_6295_0.update;
end;

//Main
procedure reset_ddragon;
begin
 hd6309_0.reset;
 ym2151_0.reset;
 case main_vars.tipo_maquina of
    92,247:begin
         m6800_0.reset;
         m6809_0.reset;
         msm_5205_0.reset;
         msm_5205_1.reset;
    end;
    96:begin
        z80_0.reset;
        z80_1.reset;
        oki_6295_0.reset;
       end;
 end;
 reset_audio;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$e7;
 soundlatch:=0;
 banco_rom:=0;
 dd_sub_port:=0;
 scroll_x:=0;
 scroll_y:=0;
 adpcm_idle[0]:=false;
 adpcm_idle[1]:=false;
 adpcm_ch[0]:=true;
 adpcm_ch[1]:=true;
 adpcm_data[0]:=0;
 adpcm_data[1]:=0;
end;

function iniciar_ddragon:boolean;
var
  f:word;
  memoria_temp:array[0..$bffff] of byte;
const
    pc_x:array[0..7] of dword=(1, 0, 8*8+1, 8*8+0, 16*8+1, 16*8+0, 24*8+1, 24*8+0);
    pt_x:array[0..15] of dword=(3, 2, 1, 0, 16*8+3, 16*8+2, 16*8+1, 16*8+0,
		  32*8+3, 32*8+2, 32*8+1, 32*8+0, 48*8+3, 48*8+2, 48*8+1, 48*8+0);
    pt_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
		  8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8);
procedure extract_chars(num:word);
begin
  init_gfx(0,8,8,num);
  gfx[0].trans[0]:=true;
  gfx_set_desc_data(4,0,32*8,0,2,4,6);
  convert_gfx(0,0,@memoria_temp,@pc_x,@pt_y,false,false);
end;
procedure extract_tiles(num:word);
begin
  init_gfx(1,16,16,num);
  gfx_set_desc_data(4,0,64*8,$20000*8+0,$20000*8+4,0,4);
  convert_gfx(1,0,@memoria_temp,@pt_x,@pt_y,false,false);
end;
procedure extract_sprites(num:word;pos:byte);
begin
  init_gfx(2,16,16,num);
  gfx[2].trans[0]:=true;
  gfx_set_desc_data(4,0,64*8,pos*$10000*8+0,pos*$10000*8+4,0,4);
  convert_gfx(2,0,@memoria_temp,@pt_x,@pt_y,false,false);
end;
begin
case main_vars.tipo_maquina of
  92,247:llamadas_maquina.bucle_general:=ddragon_principal;
  96:llamadas_maquina.bucle_general:=ddragon2_principal;
end;
llamadas_maquina.reset:=reset_ddragon;
llamadas_maquina.fps_max:=6000000/384/272;
iniciar_ddragon:=false;
iniciar_audio(false);
screen_init(1,256,256,true);
screen_init(2,512,512);
screen_mod_scroll(2,512,256,511,512,256,511);
screen_init(4,512,512,false,true);
iniciar_video(256,240);
case main_vars.tipo_maquina of
  92,247:begin
        //Main CPU
        hd6309_0:=cpu_hd6309.create(12000000,272*CPU_SYNC,TCPU_HD6309);
        hd6309_0.change_ram_calls(ddragon_getbyte,ddragon_putbyte);
        //Sub CPU
        m6800_0:=cpu_m6800.create(6000000+(6000000*byte(main_vars.tipo_maquina=247)),272*CPU_SYNC,TCPU_HD63701);
        m6800_0.change_ram_calls(ddragon_sub_getbyte,ddragon_sub_putbyte);
        //Sound CPU
        m6809_0:=cpu_m6809.Create(1500000,272*CPU_SYNC,TCPU_M6809);
        m6809_0.change_ram_calls(ddragon_snd_getbyte,ddragon_snd_putbyte);
        m6809_0.init_sound(ddragon_sound_update);
        //Sound Chips
        ym2151_0:=ym2151_chip.create(3579545);
        ym2151_0.change_irq_func(ym2151_snd_irq);
        msm_5205_0:=MSM5205_chip.create(375000,MSM5205_S48_4B,1,snd_adpcm0);
        msm_5205_1:=MSM5205_chip.create(375000,MSM5205_S48_4B,1,snd_adpcm1);
        //Main roms
        if not(roms_load(@memoria_temp,ddragon_rom)) then exit;
        //Pongo las ROMs en su banco
        copymemory(@memoria[$8000],@memoria_temp,$8000);
        for f:=0 to 5 do copymemory(@rom[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
        //Sub roms
        if not(roms_load(@mem_misc,ddragon_sub)) then exit;
        //Sound roms
        if not(roms_load(@mem_snd,ddragon_snd)) then exit;
        if not(roms_load(@adpcm_mem,ddragon_adpcm)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,ddragon_char)) then exit;
        extract_chars($400);
        //convertir tiles
        if not(roms_load(@memoria_temp,ddragon_tiles)) then exit;
        extract_tiles($800);
        //convertir sprites
        if not(roms_load(@memoria_temp,ddragon_sprites)) then exit;
        extract_sprites($1000,4);
        tipo_video:=0;
        fg_mask:=$3;
        //DIP
        marcade.dswa:=$ff;
        marcade.dswb:=$ff;
        marcade.dswa_val:=@ddragon_dip_a;
        marcade.dswb_val:=@ddragon_dip_b;
     end;
  96:begin
        //Main CPU
        hd6309_0:=cpu_hd6309.create(12000000,272*CPU_SYNC,TCPU_HD6309);
        hd6309_0.change_ram_calls(ddragon2_getbyte,ddragon2_putbyte);
        //Sub CPU
        z80_0:=cpu_z80.create(4000000,272*CPU_SYNC);
        z80_0.change_ram_calls(ddragon2_sub_getbyte,ddragon2_sub_putbyte);
        //Sound CPU
        z80_1:=cpu_z80.create(3579545,272*CPU_SYNC);
        z80_1.change_ram_calls(ddragon2_snd_getbyte,ddragon2_snd_putbyte);
        z80_1.init_sound(dd2_sound_update);
        //Sound Chips
        ym2151_0:=ym2151_chip.create(3579545);
        ym2151_0.change_irq_func(ym2151_snd_irq_dd2);
        oki_6295_0:=snd_okim6295.Create(1056000,OKIM6295_PIN7_HIGH);
        //Cargar ADPCM ROMS
        if not(roms_load(oki_6295_0.get_rom_addr,ddragon2_adpcm)) then exit;
        //Main roms
        if not(roms_load(@memoria_temp,ddragon2_rom)) then exit;
        //Pongo las ROMs en su banco
        copymemory(@memoria[$8000],@memoria_temp,$8000);
        for f:=0 to 5 do copymemory(@rom[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
        //Sub roms
        if not(roms_load(@mem_misc,ddragon2_sub)) then exit;
        //Sound roms
        if not(roms_load(@mem_snd,ddragon2_snd)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,ddragon2_char)) then exit;
        extract_chars($800);
        //convertir tiles
        if not(roms_load(@memoria_temp,ddragon2_tiles)) then exit;
        extract_tiles($800);
        //convertir sprites
        if not(roms_load(@memoria_temp,ddragon2_sprites)) then exit;
        extract_sprites($1800,6);
        tipo_video:=1;
        fg_mask:=$7;
        //DIP
        marcade.dswa:=$ff;
        marcade.dswb:=$96;
        marcade.dswa_val:=@ddragon_dip_a;
        marcade.dswb_val:=@ddragon2_dip_b;
     end;
end;
//init scanlines
for f:=8 to $ff do ddragon_scanline[f-8]:=f; //08,09,0A,0B,...,FC,FD,FE,FF
for f:=$e8 to $ff do ddragon_scanline[f+$10]:=f+$100; //E8,E9,EA,EB,...,FC,FD,FE,FF
//final
reset_ddragon;
iniciar_ddragon:=true;
end;

end.
