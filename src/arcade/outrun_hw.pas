unit outrun_hw;
interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,m68000,main_engine,controls_engine,gfx_engine,rom_engine,
     pal_engine,ppi8255,sound_engine,ym_2151,sega_315_5195,sega_pcm;

function iniciar_outrun:boolean;

const
        //Outrun
        outrun_rom:array[0..3] of tipo_roms=(
        (n:'epr-10380b.133';l:$10000;p:0;crc:$1f6cadad),(n:'epr-10382b.118';l:$10000;p:$1;crc:$c4c3fa1a),
        (n:'epr-10381b.132';l:$10000;p:$20000;crc:$be8c412b),(n:'epr-10383b.117';l:$10000;p:$20001;crc:$10a2014a));
        outrun_sub:array[0..3] of tipo_roms=(
        (n:'epr-10327a.76';l:$10000;p:0;crc:$e28a5baf),(n:'epr-10329a.58';l:$10000;p:$1;crc:$da131c81),
        (n:'epr-10328a.75';l:$10000;p:$20000;crc:$d5ec5e5d),(n:'epr-10330a.57';l:$10000;p:$20001;crc:$ba9ec82a));
        outrun_sound:tipo_roms=(n:'epr-10187.88';l:$8000;p:0;crc:$a10abaa9);
        outrun_tiles:array[0..5] of tipo_roms=(
        (n:'opr-10268.99';l:$8000;p:0;crc:$95344b04),(n:'opr-10232.102';l:$8000;p:$8000;crc:$776ba1eb),
        (n:'opr-10267.100';l:$8000;p:$10000;crc:$a85bb823),(n:'opr-10231.103';l:$8000;p:$18000;crc:$8908bcbf),
        (n:'opr-10266.101';l:$8000;p:$20000;crc:$9f6f1a74),(n:'opr-10230.104';l:$8000;p:$28000;crc:$686f5e50));
        outrun_sprites:array[0..7] of tipo_roms=(
        (n:'mpr-10371.9';l:$20000;p:0;crc:$7cc86208),(n:'mpr-10373.10';l:$20000;p:$1;crc:$b0d26ac9),
        (n:'mpr-10375.11';l:$20000;p:$2;crc:$59b60bd7),(n:'mpr-10377.12';l:$20000;p:$3;crc:$17a1b04a),
        (n:'mpr-10372.13';l:$20000;p:$80000;crc:$b557078c),(n:'mpr-10374.14';l:$20000;p:$80001;crc:$8051e517),
        (n:'mpr-10376.15';l:$20000;p:$80002;crc:$f3b8f318),(n:'mpr-10378.16';l:$20000;p:$80003;crc:$a1062984));
        outrun_road:array[0..1] of tipo_roms=(
        (n:'opr-10186.47';l:$8000;p:0;crc:$22794426),(n:'opr-10185.11';l:$8000;p:$8000;crc:$22794426));
        outrun_pcm:array[0..5] of tipo_roms=(
        (n:'opr-10193.66';l:$8000;p:$0000;crc:$bcd10dde),(n:'opr-10192.67';l:$8000;p:$10000;crc:$770f1270),
        (n:'opr-10191.68';l:$8000;p:$20000;crc:$20a284ab),(n:'opr-10190.69';l:$8000;p:$30000;crc:$7cab70e2),
        (n:'opr-10189.70';l:$8000;p:$40000;crc:$01366b54),(n:'opr-10188.71';l:$8000;p:$50000;crc:$bad30ad9));
        outrun_dip_a:array [0..2] of def_dip2=(
        (mask:$f;name:'Coin A';number:16;val16:(7,8,9,5,4,$f,3,2,1,6,$e,$d,$c,$b,$a,0);name16:('4C 1C','3C 1C','2C 1C','2C 1C - 5C 3C - 6C 4C','2C 1C - 4C 3C','1C 1C','1C 1C 5C 6C','1C 1C - 4C 5C','1C 1C - 2C 3C','2C 3C','1C 2C','1C 3C','1C 4C','1C 5C','1C 6C','Free Play (if Coin B too) or 1C 1C')),
        (mask:$f0;name:'Coin B';number:16;val16:($70,$80,$90,$50,$40,$f0,$30,$20,$10,$60,$e0,$d0,$c0,$b0,$a0,0);name16:('4C 1C','3C 1C','2C 1C','2C 1C - 5C 3C - 6C 4C','2C 1C - 4C 3C','1C 1C','1C 1C - 5C 6C','1C 1C - 4C 5C','1C 1C - 2C 3C','2C 3C','1C 2C','1C 3C','1C 4C','1C 5C','1C 6C','Free Play (if Coin A too) or 1C 1C')),());
        outrun_dip_b:array [0..3] of def_dip2=(
        (mask:4;name:'Demo Sounds';number:2;val2:(4,0);name2:('Off','On')),
        (mask:$30;name:'Time Adjust';number:4;val4:($20,$30,$10,0);name4:('Easy','Normal','Hard','Hardest')),
        (mask:$c0;name:'Difficulty';number:4;val4:($80,$c0,$40,0);name4:('Easy','Normal','Hard','Hardest')),());
        CPU_SYNC=4;

type
  tsystem16_info=record
    	normal,shadow,hilight:array[0..31] of byte;
      banks:byte;
      screen:array[0..7] of byte;
      screen_enabled:boolean;
      tile_buffer:array[0..7,0..$7ff] of boolean;
   end;
   toutrun_road=record
      control:byte;
      colorbase1,colorbase2,colorbase3:word;
      buffer:array[0..$7ff] of word;
      xoff:word;
   end;
var
 rom,rom2:array[0..$2ffff] of word;
 ram,ram2:array[0..$3fff] of word;
 road_ram,char_ram,sprite_ram:array[0..$7ff] of word;
 tile_ram:array[0..$7fff] of word;
 sprite_rom:array[0..$3ffff] of dword;
 s16_info:tsystem16_info;
 road_info:toutrun_road;
 adc_select,sound_latch:byte;
 road_gfx:array[0..(((256*2+1)*512)-1)] of byte;
 pcm_rom:array[0..$5ffff] of byte;
 push_gear,gear_hi:boolean;

implementation

procedure update_video_outrun;
procedure draw_sprites(pri:byte);
var
  f,sprpri,g:byte;
  vzoom,hzoom,top,addr,bank,pix,data_7,color,height:word;
  xpos,x,y,ydelta,ytarget,xacc,yacc,pitch,xdelta:integer;
  pixels,spritedata:dword;
  hide,flip:boolean;
procedure system16b_draw_pixel(x:integer;y,pix:word);
var
  punt,punt2,temp1,temp2,temp3:word;
begin
  //only draw if onscreen, not 0 or 15
	if ((x>=0) and (x<320) and ((pix and $f)<>0) and ((pix and $f)<>15)) then begin
      if (pix and $400f)=$400a then begin //Shadow
          punt:=getpixel(x+ADD_SPRITE,y+ADD_SPRITE,7);
          punt2:=paleta[$1000];
          temp1:=(((punt and $f800)+(punt2 and $f800)) shr 1) and $f800;
          temp2:=(((punt and $7e0)+(punt2 and $7e0)) shr 1) and $7e0;
          temp3:=(((punt and $1f)+(punt2 and $1f)) shr 1) and $1f;
          punt:=temp1 or temp2 or temp3;
      end else punt:=paleta[(pix and $7ff)+$800]; //Normal
      putpixel(x+ADD_SPRITE,y+ADD_SPRITE,1,@punt,7);
	end;
end;
begin
  for f:=0 to $ff do begin
    if (sprite_ram[f*8] and $8000)<>0 then exit;
    sprpri:=(sprite_ram[(f*8)+3] shr 12) and 3;
    if sprpri<>pri then continue;
    addr:=sprite_ram[(f*8)+1];
    sprite_ram[(f*8)+7]:=addr;
    hide:=(sprite_ram[f*8] and $5000)<>0;
    if hide then continue;
    top:=(sprite_ram[f*8] and $1ff)-$100;
    bank:=((sprite_ram[f*8] shr 9) and $7) mod s16_info.banks;
		xpos:=sprite_ram[(f*8)+2] and $1ff;
    if (sprite_ram[(f*8)+4] and $2000)<>0 then xdelta:=1
      else xdelta:=-1;
    if ((xpos<$80) and (xdelta<0)) then xpos:=xpos+$149 //$200-$bd+6
      else xpos:=xpos-$b7; //-$bd+6
    vzoom:=sprite_ram[(f*8)+3] and $7ff;
    hzoom:=sprite_ram[(f*8)+4] and $7ff;
    // clamp to a maximum of 8x (not 100% confirmed)
		if (vzoom<$40) then vzoom:=$40;
		if (hzoom<$40) then hzoom:=$40;
    color:=((sprite_ram[(f*8)+5] and $7f) shl 4) or (sprite_ram[(f*8)+3] and $4000);
    // clamp to within the memory region size
		spritedata:=$10000*bank;
    flip:=((not(sprite_ram[(f*8)+4]) shr 14) and 1)<>0;
		pitch:=smallint((sprite_ram[(f*8)+2] shr 1) or ((sprite_ram[(f*8)+4] and $1000) shl 3)) div 256;
    height:=(sprite_ram[(f*8)+5] shr 8)+1;
    if (sprite_ram[(f*8)+4] and $8000)<>0 then ydelta:=1
      else ydelta:=-1;
    yacc:=0;
    y:=top;
    ytarget:=top+ydelta*height;
		while y<>ytarget do begin
			// advance a row
			if ((y<256) and (y>=0)) then begin
        xacc:=0;
				if not(flip) then begin
          data_7:=addr;
					x:=xpos;
          while (((xdelta>0) and (x<512)) or ((xdelta<0) and (x>=0))) do begin
						pixels:=sprite_rom[spritedata+data_7];
            for g:=7 downto 0 do begin
						  pix:=(pixels shr (g*4)) and $f;
              while (xacc<$200) do begin
                system16b_draw_pixel(x,y,pix or color);
                x:=x+xdelta;
                xacc:=xacc+hzoom;
              end;
              xacc:=xacc-$200;
            end;
						if (pixels and $f0)=$f0 then begin
              sprite_ram[(f*8)+7]:=data_7;
              break;
            end else data_7:=data_7+1;
					end;
				end else begin
				  // flipped case
          data_7:=addr;
					x:=xpos;
          while (((xdelta>0) and (x<512)) or ((xdelta<0) and (x>=0))) do begin
						pixels:=sprite_rom[spritedata+data_7];
            for g:=0 to 7 do begin
						  pix:=(pixels shr (g*4)) and $f;
              while (xacc<$200) do begin
                system16b_draw_pixel(x,y,pix or color);
                x:=x+xdelta;
                xacc:=xacc+hzoom;
              end;
              xacc:=xacc-$200;
            end;
						if (pixels and $0f000000)=$0f000000 then begin
              sprite_ram[(f*8)+7]:=data_7;
              break;
            end else data_7:=data_7-1;
					end;
			 	end; //del flip
        yacc:=yacc+vzoom;
			  addr:=addr+pitch*(yacc shr 9);
			  yacc:=yacc and $1ff;
			end; //De la Y
      y:=y+ydelta;
		end; //Del while
	end;
end;
procedure draw_road(pri:byte);
var
  y,bgcolor:byte;
  x,data0,data1,pix0,pix1,color0,color1:word;
  hpos0,hpos1:integer;
  color_table:array[0..$1f] of word;
  src0,src1:dword;
  ptemp:pword;
const
  priority_map:array[0..1,0..7] of byte=(($80,$81,$81,$87,0,0,0,0),($81,$81,$81,$8f,0,0,0,$80));
begin
  for y:=0 to 255 do begin
    data0:=road_info.buffer[y];
    data1:=road_info.buffer[$100+y];
    if (pri=0) then begin //Background
      color0:=$ff;
      case (road_info.control and 3) of
        0:if (data0 and $800)<>0 then color0:=data0 and $7f;
        1:if (data0 and $800)<>0 then color0:=data0 and $7f
            else if (data1 and $800)<>0 then color0:=data1 and $7f;
        2:if (data1 and $800)<>0 then color0:=data1 and $7f
            else if (data0 and $800)<>0 then color0:=data0 and $7f;
        3:if (data1 and $800)<>0 then color0:=data1 and $7f;
      end;
      if color0<>$ff then single_line(ADD_SPRITE,y+ADD_SPRITE,paleta[color0 or road_info.colorbase3],320,7)
        else single_line(ADD_SPRITE,y+ADD_SPRITE,paleta[$2000],320,7);
    end else begin //Foreground
      single_line(0,y,paleta[MAX_COLORES],320,8);
      if (((data0 and $800)<>0) and ((data1 and $800)<>0)) then continue;
      // get road 0 data
      if (data0 and $800)<>0 then src0:=256*2*512
        else src0:=((data0 shr 1) and $ff)*512;
      if (road_info.control and 4)<>0 then hpos0:=road_info.buffer[$200+y] and $fff
        else hpos0:=road_info.buffer[$200+(data0 and $1ff)] and $fff;
      if (road_info.control and 4)<>0 then color0:=road_info.buffer[$600+y]
        else color0:=road_info.buffer[$600+(data0 and $1ff)];
			// get road 1 data
      if (data1 and $800)<>0 then src1:=256*2*512
        else src1:=($100+((data1 shr 1) and $ff))*512;
      if (road_info.control and 4)<>0 then hpos1:=road_info.buffer[$400+($100+y)] and $fff
        else hpos1:=road_info.buffer[$400+(data1 and $1ff)] and $fff;
      if (road_info.control and 4)<>0 then color1:=road_info.buffer[$600+($100+y)]
        else color1:=road_info.buffer[$600+(data1 and $1ff)];
      // determine the 5 colors for road 0
			color_table[$00]:=road_info.colorbase1 xor $00 xor ((color0 shr 0) and 1);
			color_table[$01]:=road_info.colorbase1 xor $02 xor ((color0 shr 1) and 1);
			color_table[$02]:=road_info.colorbase1 xor $04 xor ((color0 shr 2) and 1);
			bgcolor:=(color0 shr 8) and $f;
      if (data0 and $200)<>0 then color_table[$03]:=color_table[$00]
        else color_table[$03]:=road_info.colorbase2 xor $00 xor bgcolor;
			color_table[$07]:=road_info.colorbase1 xor $06 xor ((color0 shr 3) and 1);
      // determine the 5 colors for road 1
			color_table[$10]:=road_info.colorbase1 xor $08 xor ((color1 shr 4) and 1);
			color_table[$11]:=road_info.colorbase1 xor $0a xor ((color1 shr 5) and 1);
			color_table[$12]:=road_info.colorbase1 xor $0c xor ((color1 shr 6) and 1);
			bgcolor:=(color1 shr 8) and $f;
      if (data1 and $200)<>0 then color_table[$13]:=color_table[$10]
        else color_table[$13]:=road_info.colorbase2 xor $10 xor bgcolor;
			color_table[$17]:=road_info.colorbase1 xor $0e xor ((color1 shr 7) and 1);
      case (road_info.control and 3) of
        0:begin
            if (data0 and $800)<>0 then continue;
					  hpos0:=(hpos0-($5f8+road_info.xoff)) and $fff;
            ptemp:=punbuf;
					  for x:=0 to 319 do begin
              if (hpos0<$200) then pix0:=road_gfx[src0+hpos0]
                else pix0:=3;
						  ptemp^:=paleta[color_table[pix0]];
              inc(ptemp);
						  hpos0:=(hpos0+1) and $fff;
					  end;
            putpixel(0,y,320,punbuf,8);
        end;
        1:begin
            hpos0:=(hpos0-($5f8+road_info.xoff)) and $fff;
					  hpos1:=(hpos1-($5f8+road_info.xoff)) and $fff;
            ptemp:=punbuf;
					  for x:=0 to 319 do begin
              if (hpos0<$200) then pix0:=road_gfx[src0+hpos0]
                else pix0:=3;
              if (hpos1<$200) then pix1:=road_gfx[src1+hpos1]
                else pix1:=3;
						  if ((priority_map[0][pix0] shr pix1) and 1)<>0 then ptemp^:=paleta[color_table[$10+pix1]]
                else ptemp^:=paleta[color_table[pix0]];
              inc(ptemp);
						  hpos0:=(hpos0+1) and $fff;
						  hpos1:=(hpos1+1) and $fff;
					  end;
            putpixel(0,y,320,punbuf,8);
          end;
        2:begin
            hpos0:=(hpos0-($5f8+road_info.xoff)) and $fff;
					  hpos1:=(hpos1-($5f8+road_info.xoff)) and $fff;
            ptemp:=punbuf;
					  for x:=0 to 319 do begin
              if (hpos0<$200) then pix0:=road_gfx[src0+hpos0]
                else pix0:=3;
              if (hpos1<$200) then pix1:=road_gfx[src1+hpos1]
                else pix1:=3;
						  if ((priority_map[1][pix0] shr pix1) and 1)<>0 then ptemp^:=paleta[color_table[$10+pix1]]
                else ptemp^:=paleta[color_table[pix0]];
              inc(ptemp);
						  hpos0:=(hpos0+1) and $fff;
						  hpos1:=(hpos1+1) and $fff;
					  end;
            putpixel(0,y,320,punbuf,8);
          end;
        3:begin
            if (data1 and $800)<>0 then continue;
					  hpos1:=(hpos1-($5f8+road_info.xoff)) and $fff;
            ptemp:=punbuf;
					  for x:=0 to 319 do begin
              if (hpos1<$200) then pix1:=road_gfx[(src1+hpos1)]
                else pix1:=3;
						  ptemp^:=paleta[color_table[$10+pix1]];
              inc(ptemp);
						  hpos1:=(hpos1+1) and $fff;
					  end;
            putpixel(0,y,320,punbuf,8);
        end;
      end;
    end;
  end;
end;
procedure draw_tiles(num:byte;px,py:word;scr:byte);
var
  pos,f,nchar,color,data,x,y:word;
begin
  pos:=s16_info.screen[num]*$800;
  for f:=$0 to $7ff do begin
    data:=tile_ram[pos+f];
    color:=(data shr 6) and $7f;
    if (s16_info.tile_buffer[num,f] or buffer_color[color]) then begin
      x:=((f and $3f) shl 3)+px;
      y:=((f shr 6) shl 3)+py;
      nchar:=data and $1fff;
      put_gfx_trans(x,y,nchar,color shl 3,scr,0);
      if (data and $8000)<>0 then put_gfx_trans(x,y,nchar,color shl 3,scr+1,0)
        else put_gfx_block_trans(x,y,scr+1,8,8);
      s16_info.tile_buffer[num,f]:=false;
    end;
  end;
end;
var
  f,nchar,color,scroll_x1,scroll_x2,x,y,atrib,scroll_y1,scroll_y2:word;
begin
if not(s16_info.screen_enabled) then begin
  fill_full_screen(7,$2000);
  actualiza_trozo_final(0,0,320,224,7);
  exit;
end;
//Background
draw_tiles(0,0,256,3);
draw_tiles(1,512,256,3);
draw_tiles(2,0,0,3);
draw_tiles(3,512,0,3);
scroll_x1:=char_ram[$74d] and $3ff;
scroll_x1:=(704-scroll_x1) and $3ff;
scroll_y1:=char_ram[$749] and $1ff;
//Foreground
draw_tiles(4,0,256,5);
draw_tiles(5,512,256,5);
draw_tiles(6,0,0,5);
draw_tiles(7,512,0,5);
scroll_x2:=char_ram[$74c] and $3ff;
scroll_x2:=(704-scroll_x2) and $3ff;
scroll_y2:=char_ram[$748] and $1ff;
//text
for f:=$0 to $6ff do begin
  atrib:=char_ram[f];
  color:=(atrib shr 9) and $7;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
    x:=(f and $3f) shl 3;
    y:=(f shr 6) shl 3;
    nchar:=atrib and $1ff;
    put_gfx_trans(x,y,nchar,color shl 3,1,0);
    if (atrib and $8000)<>0 then put_gfx_trans(x,y,nchar,color shl 3,2,0)
      else put_gfx_block_trans(x,y,2,8,8);
    gfx[0].buffer[f]:=false;
  end;
end;
//Lo pongo todo con prioridades, falta scrollrow y scrollcol!!
draw_road(0); //R0
scroll_x_y(3,7,scroll_x1,scroll_y1); //B0
draw_sprites(0);
scroll_x_y(4,7,scroll_x1,scroll_y1); //B1
draw_sprites(1);
scroll_x_y(5,7,scroll_x2,scroll_y2);  //F0
draw_sprites(2);
scroll_x_y(6,7,scroll_x2,scroll_y2); //F1
draw_road(1); //R1
actualiza_trozo(0,0,320,256,8,0,0,320,256,7); //R1
actualiza_trozo(192,0,320,224,1,0,0,320,224,7); //T0
draw_sprites(3);
actualiza_trozo(192,0,320,224,2,0,0,320,224,7); //T1
//Y lo pinto a la pantalla principal
actualiza_trozo_final(0,0,320,224,7);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
end;

procedure eventos_outrun;
begin
if event.arcade then begin
  //Service
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.but2[0] then push_gear:=true else begin
      if push_gear then begin
        gear_hi:=not(gear_hi);
        if gear_hi then begin
          marcade.in0:=marcade.in0 or $10;
          main_vars.mensaje_principal:='Gear Hi';
        end else begin
          marcade.in0:=marcade.in0 and $ef;
          main_vars.mensaje_principal:='Gear Lo';
        end;
      end;
      push_gear:=false;
  end;
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
end;
end;

procedure outrun_principal;
var
  f:word;
  h:byte;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
  for f:=0 to 261 do begin
     eventos_outrun;
     case f of
        65,129,193:begin
             m68000_0.irq[2]:=ASSERT_LINE;
            end;
        66,130,194:begin
             m68000_0.irq[2]:=CLEAR_LINE;
            end;
        223:begin
              m68000_0.irq[4]:=ASSERT_LINE;
              m68000_1.irq[4]:=ASSERT_LINE;
              update_video_outrun;
            end;
        224:begin
              m68000_0.irq[4]:=CLEAR_LINE;
              m68000_1.irq[4]:=CLEAR_LINE;
            end;
     end;
     for h:=1 to CPU_SYNC do begin
        //main
        m68000_0.run(frame_main);
        frame_main:=frame_main+m68000_0.tframes-m68000_0.contador;
        //main
        m68000_1.run(frame_sub);
        frame_sub:=frame_sub+m68000_1.tframes-m68000_1.contador;
        //sound
        z80_0.run(frame_snd);
        frame_snd:=frame_snd+z80_0.tframes-z80_0.contador;
     end;
  end;
  video_sync;
end;
end;

function standar_s16_io_r(direccion:word):word;
var
  res:word;
begin
case (direccion and $38) of
	$0:res:=pia8255_0.read(direccion and 3);
	$8:case (direccion and 3) of
        0:res:=marcade.in0; //system
        1:res:=$ff; //unknown
        2:res:=marcade.dswa; //coin
        3:res:=marcade.dswb; //dsw
     end;
  $18:case adc_select of  //controles
        0:res:=analog.c[0].x[0]; //Volante
        1:res:=analog.c[1].val[0]; //gas
        2:res:=analog.c[2].val[0]; //brake
        3:res:=$ff; //motor
      end;
  $30:; //watchdog
	end;
standar_s16_io_r:=res;
end;

function outrun_getword(direccion:dword):word;
var
  zona:boolean;
  f,tempw:word;
begin
zona:=false;
if ((direccion>=s315_5195_0.dirs_start[0]) and (direccion<s315_5195_0.dirs_end[0])) then begin
  //Esta zona no se puede solapar!!!!
  case direccion of
    0..$5ffff:outrun_getword:=rom[(direccion and $3ffff) shr 1];
    $60000..$67fff:outrun_getword:=ram[(direccion and $7fff) shr 1];
  end;
  exit;
end;
if ((direccion>=s315_5195_0.dirs_start[1]) and (direccion<s315_5195_0.dirs_end[1])) then begin
  case direccion and $1ffff of //Text/Tile RAM
    0..$ffff:outrun_getword:=tile_ram[(direccion and $ffff) shr 1];
    $10000..$1ffff:outrun_getword:=char_ram[(direccion and $fff) shr 1];
  end;
  zona:=true;
end;
if ((direccion>=s315_5195_0.dirs_start[2]) and (direccion<s315_5195_0.dirs_end[2])) then begin
  outrun_getword:=buffer_paleta[(direccion and $1fff) shr 1]; //Color RAM
  zona:=true;
end;
if ((direccion>=s315_5195_0.dirs_start[3]) and (direccion<s315_5195_0.dirs_end[3])) then begin
  outrun_getword:=sprite_ram[(direccion and $fff) shr 1]; //Object RAM
  zona:=true;
end;
if ((direccion>=s315_5195_0.dirs_start[4]) and (direccion<s315_5195_0.dirs_end[4])) then begin
  outrun_getword:=standar_s16_io_r((direccion and $7f) shr 1); //IO Read
  zona:=true;
end;
if ((direccion>=s315_5195_0.dirs_start[5]) and (direccion<s315_5195_0.dirs_end[5])) then begin
  case (direccion and $fffff) of
    0..$5ffff:outrun_getword:=rom2[(direccion and $3ffff) shr 1]; //ROM
    $60000..$7ffff:outrun_getword:=ram2[(direccion and $7fff) shr 1]; //RAM
    $80000..$8ffff:outrun_getword:=road_ram[(direccion and $fff) shr 1]; //RAM ROAD
    $90000..$9ffff:if m68000_1.read_8bits_hi_dir then begin
                      for f:=0 to $7ff do begin
                        tempw:=road_ram[f];
                        road_ram[f]:=road_info.buffer[f];
                        road_info.buffer[f]:=tempw;
                      end;
                      outrun_getword:=$ffff;
                   end;
  end;
  zona:=true;
end;
if not(zona) then outrun_getword:=s315_5195_0.read_reg((direccion shr 1) and $1f);
end;

procedure test_screen_change(direccion:word);
var
  tmp:byte;
begin
if direccion=$740 then begin
          //Foreground
          tmp:=(char_ram[$740] shr 12) and $f;
          if tmp<>s16_info.screen[4] then begin
            s16_info.screen[4]:=tmp;
            fillchar(s16_info.tile_buffer[4,0],$800,1);
          end;
          tmp:=(char_ram[$740] shr 8) and $f;
          if tmp<>s16_info.screen[5] then begin
            s16_info.screen[5]:=tmp;
            fillchar(s16_info.tile_buffer[5,0],$800,1);
          end;
          tmp:=(char_ram[$740] shr 4) and $f;
          if tmp<>s16_info.screen[6] then begin
            s16_info.screen[6]:=tmp;
            fillchar(s16_info.tile_buffer[6,0],$800,1);
          end;
          tmp:=char_ram[$740] and $f;
          if tmp<>s16_info.screen[7] then begin
            s16_info.screen[7]:=tmp;
            fillchar(s16_info.tile_buffer[7,0],$800,1);
          end;
end;
if direccion=$741 then begin
          //Background
          tmp:=(char_ram[$741] shr 12) and $f;
          if tmp<>s16_info.screen[0] then begin
            s16_info.screen[0]:=tmp;
            fillchar(s16_info.tile_buffer[0,0],$800,1);
          end;
          tmp:=(char_ram[$741] shr 8) and $f;
          if tmp<>s16_info.screen[1] then begin
            s16_info.screen[1]:=tmp;
            fillchar(s16_info.tile_buffer[1,0],$800,1);
          end;
          tmp:=(char_ram[$741] shr 4) and $f;
          if tmp<>s16_info.screen[2] then begin
            s16_info.screen[2]:=tmp;
            fillchar(s16_info.tile_buffer[2,0],$800,1);
          end;
          tmp:=char_ram[$741] and $f;
          if tmp<>s16_info.screen[3] then begin
            s16_info.screen[3]:=tmp;
            fillchar(s16_info.tile_buffer[3,0],$800,1);
          end;
end;
end;

procedure standard_io_w(direccion,valor:word);
begin
case (direccion and $38) of
		$0:pia8255_0.write(direccion and $3,valor and $ff);
    $10:;
    $18:;
    $30:; //watchdog
    $38:;
end;
end;

procedure outrun_putword(direccion:dword;valor:word);

procedure change_pal(direccion,valor:word);
var
	r,g,b:word;
  color:tcolor;
begin
	//     byte 0    byte 1
	//  sBGR BBBB GGGG RRRR
	//  x000 4321 4321 4321
	r:=((valor shr 12) and $01) or ((valor shl 1) and $1e);
	g:=((valor shr 13) and $01) or ((valor shr 3) and $1e);
	b:=((valor shr 14) and $01) or ((valor shr 7) and $1e);
  //normal
  color.r:=s16_info.normal[r];
  color.g:=s16_info.normal[g];
  color.b:=s16_info.normal[b];
  set_pal_color(color,direccion);
  //shadow
  if (valor and $8000)<>0 then begin
    color.r:=s16_info.shadow[r];
    color.g:=s16_info.shadow[g];
    color.b:=s16_info.shadow[b];
  end else begin
    //hilight
    color.r:=s16_info.hilight[r];
    color.g:=s16_info.hilight[g];
    color.b:=s16_info.hilight[b];
  end;
  set_pal_color(color,direccion+$1000);
  buffer_color[(direccion shr 3) and $7f]:=true;
end;

procedure test_tile_buffer(direccion:word);
var
  num_scr,f:byte;
  pos:word;
begin
  num_scr:=direccion shr 11;
  pos:=direccion and $7ff;
  for f:=0 to 7 do
    if s16_info.screen[f]=num_scr then s16_info.tile_buffer[f,pos]:=true;
end;

var
  zona:boolean;
  tempd:dword;
begin
{
Zona 0 --> ROM CPU1
Zona 1 --> tiles y text
Zona 2 --> Paleta
Zona 3 --> Sprites
Zona 4 --> IO
Zona 5 --> Road RAM, CPU2 RAM y CPU2 ROM
}
zona:=false;
if ((direccion>=s315_5195_0.dirs_start[0]) and (direccion<s315_5195_0.dirs_end[0])) then begin
  case direccion of
    0..$5ffff:;
    $60000..$67fff:ram[(direccion and $7fff) shr 1]:=valor;
  end;
  zona:=true;
end;
if ((direccion>=s315_5195_0.dirs_start[1]) and (direccion<s315_5195_0.dirs_end[1])) then begin
  case direccion and $1ffff of
      0..$ffff:begin
                  direccion:=(direccion and $ffff) shr 1;
                  if tile_ram[direccion]<>valor then begin
                    tile_ram[direccion]:=valor;
                    test_tile_buffer(direccion);
                  end;
               end;
      $10000..$1ffff:begin
                  if char_ram[(direccion and $fff) shr 1]<>valor then begin
                    char_ram[(direccion and $fff) shr 1]:=valor;
                    gfx[0].buffer[(direccion and $fff) shr 1]:=true;
                  end;
                  test_screen_change((direccion and $fff) shr 1);
               end;
  end;
  zona:=true;
end;
if ((direccion>=s315_5195_0.dirs_start[2]) and (direccion<s315_5195_0.dirs_end[2])) then begin
  buffer_paleta[(direccion and $1fff) shr 1]:=valor;
  change_pal((direccion and $1fff) shr 1,valor);
  zona:=true;
end;
if ((direccion>=s315_5195_0.dirs_start[3]) and (direccion<s315_5195_0.dirs_end[3])) then begin
  sprite_ram[(direccion and $fff) shr 1]:=valor; //Object RAM
  zona:=true;
end;
if ((direccion>=s315_5195_0.dirs_start[4]) and (direccion<s315_5195_0.dirs_end[4])) then begin
  standard_io_w((direccion and $7f) shr 1,valor);
  zona:=true;
end;
if ((direccion>=s315_5195_0.dirs_start[5]) and (direccion<s315_5195_0.dirs_end[5])) then begin
  case (direccion and $fffff) of
    0..$5ffff:; //ROM
    $60000..$7ffff:ram2[(direccion and $7fff) shr 1]:=valor; //RAM
    $80000..$8ffff:road_ram[(direccion and $fff) shr 1]:=valor; //RAM
    $90000..$9ffff:road_info.control:=valor and 3;
  end;
  zona:=true;
end;
if not(zona) then begin
  tempd:=s315_5195_0.dirs_start[1];
  s315_5195_0.write_reg((direccion shr 1) and $1f,valor and $ff);
  if tempd<>s315_5195_0.dirs_start[1] then fillchar(s16_info.tile_buffer,$4000,0);
end;
end;

function outrun_sub_getword(direccion:dword):word;
var
  f,tempw:word;
begin
direccion:=direccion and $fffff;
case direccion of
  0..$5ffff:outrun_sub_getword:=rom2[(direccion and $3ffff) shr 1];
  $60000..$7ffff:outrun_sub_getword:=ram2[(direccion and $7fff) shr 1];
  $80000..$8ffff:outrun_sub_getword:=road_ram[(direccion and $fff) shr 1];
  $90000..$9ffff:if m68000_1.read_8bits_hi_dir then begin
                  for f:=0 to $7ff do begin
                    tempw:=road_ram[f];
                    road_ram[f]:=road_info.buffer[f];
                    road_info.buffer[f]:=tempw;
                  end;
                  outrun_sub_getword:=$ffff;
                 end;
end;
end;

procedure outrun_sub_putword(direccion:dword;valor:word);
begin
direccion:=direccion and $fffff;
case direccion of
  0..$5ffff:;
  $60000..$67fff:ram2[(direccion and $7fff) shr 1]:=valor;
  $80000..$8ffff:road_ram[(direccion and $fff) shr 1]:=valor;
  $90000..$9ffff:road_info.control:=valor and 3;
end;
end;

procedure outrun_reset_cpu2;
begin
  m68000_1.change_reset(PULSE_LINE);
end;

function outrun_snd_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$efff,$f800..$ffff:outrun_snd_getbyte:=mem_snd[direccion];
  $f000..$f7ff:outrun_snd_getbyte:=sega_pcm_0.read(direccion and $ff);
end;
end;

procedure outrun_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$efff:;
  $f000..$f7ff:sega_pcm_0.write(direccion and $ff,valor);
  $f800..$ffff:mem_snd[direccion]:=valor;
end;
end;

function outrun_snd_inbyte(puerto:word):byte;
var
  res:byte;
begin
res:=$ff;
case (puerto and $ff) of
  $00..$3f:if (puerto and 1)<>0 then res:=ym2151_0.status;
  $40..$7f:begin
            res:=sound_latch;
            z80_0.change_nmi(CLEAR_LINE);
           end;
end;
outrun_snd_inbyte:=res;
end;

procedure outrun_snd_outbyte(puerto:word;valor:byte);
begin
case (puerto and $ff) of
  $00..$3f:case (puerto and 1) of
              0:ym2151_0.reg(valor);
              1:ym2151_0.write(valor);
           end;
end;
end;

procedure outrun_snd_irq(valor:byte);
begin
  sound_latch:=valor;
  z80_0.change_nmi(ASSERT_LINE);
end;

function outrun_read_pcm(dir:dword):byte;
begin
  outrun_read_pcm:=pcm_rom[dir];
end;

procedure ppi8255_wportc(valor:byte);
begin
s16_info.screen_enabled:=(valor and $20)<>0;
adc_select:=(valor shr 2) and 7;
if (valor and $1)<>0 then z80_0.change_reset(CLEAR_LINE)
  else z80_0.change_reset(ASSERT_LINE);
end;

procedure outrun_sound_act;
begin
  ym2151_0.update;
  sega_pcm_0.update;
end;

//Main
procedure reset_outrun;
begin
 s315_5195_0.reset;
 m68000_0.reset;
 m68000_1.reset;
 z80_0.reset;
 frame_main:=m68000_0.tframes;
 frame_sub:=m68000_1.tframes;
 frame_snd:=z80_0.tframes;
 ym2151_0.reset;
 sega_pcm_0.reset;
 pia8255_0.reset;
 marcade.in0:=$ef;
 s16_info.screen_enabled:=false;
 fillchar(s16_info.tile_buffer,$4000,1);
 fillchar(road_info.buffer,$1000,1);
 adc_select:=0;
 sound_latch:=0;
 gear_hi:=false;
 main_vars.mensaje_principal:='Gear Lo';
 push_gear:=false;
end;

function iniciar_outrun:boolean;
var
  f:word;
  memoria_temp:array[0..$7ffff] of byte;
  weights:array[0..1,0..5] of single;
  i0,i1,i2,i3,i4:integer;
const
  pt_x:array[0..7] of dword=(0, 1, 2, 3, 4, 5, 6, 7 );
  pt_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
  resistances_normal:array[0..5] of integer=(3900, 2000, 1000, 1000 div 2,1000 div 4, 0);
	resistances_sh:array[0..5] of integer=(3900, 2000, 1000, 1000 div 2, 1000 div 4, 470);
procedure decode_road;
var
  len,src,dst:dword;
  y,x:word;
begin
  len:=$8000*2;
  for y:=0 to 511 do begin
		src:=((y and $ff)*$40+(y shr 8)*$8000) mod len;
		dst:=y*512;
		// loop over columns
		for x:=0 to 511 do begin
			road_gfx[dst+x]:=(((memoria_temp[src+(x div 8)] shr (not(x) and 7)) and 1) shl 0) or (((memoria_temp[src+((x div 8)+$4000)] shr (not(x) and 7)) and 1) shl 1);
			// pre-mark road data in the "stripe" area with a high bit
			if ((x>=256-8) and (x<256) and (road_gfx[dst+x]=3)) then road_gfx[dst+x]:=road_gfx[dst+x] or 4;
		end;
	end;
	// set up a dummy road in the last entry
	fillchar(road_gfx[256*2*512],3,512);
end;
begin
llamadas_maquina.bucle_general:=outrun_principal;
llamadas_maquina.reset:=reset_outrun;
iniciar_outrun:=false;
iniciar_audio(true);
//Text
screen_init(1,512,256,true);
screen_init(2,512,256,true);
//Background
screen_init(3,1024,512,true);
screen_mod_scroll(3,1024,512,1023,512,256,511);
screen_init(4,1024,512,true);
screen_mod_scroll(4,1024,512,1023,512,256,511);
//Foreground
screen_init(5,1024,512,true);
screen_mod_scroll(5,1024,512,1023,512,256,511);
screen_init(6,1024,512,true);
screen_mod_scroll(6,1024,512,1023,512,256,511);
//Road
screen_init(8,320,256,true);
//Final
screen_init(7,512,256,false,true);
iniciar_video(320,224);
//Main CPU
m68000_0:=cpu_m68000.create(10000000,262*CPU_SYNC);
m68000_0.change_ram16_calls(outrun_getword,outrun_putword);
m68000_0.change_reset_call(outrun_reset_cpu2);
if not(roms_load16w(@rom,outrun_rom)) then exit;
//Sub CPU
m68000_1:=cpu_m68000.create(10000000,262*CPU_SYNC);
m68000_1.change_ram16_calls(outrun_sub_getword,outrun_sub_putword);
if not(roms_load16w(@rom2,outrun_sub)) then exit;
//Sound CPU
z80_0:=cpu_z80.create(4000000,262*CPU_SYNC);
z80_0.change_ram_calls(outrun_snd_getbyte,outrun_snd_putbyte);
z80_0.change_io_calls(outrun_snd_inbyte,outrun_snd_outbyte);
z80_0.init_sound(outrun_sound_act);
if not(roms_load(@mem_snd,outrun_sound)) then exit;
//Memory Mapper
s315_5195_0:=t315_5195.create(m68000_0,outrun_snd_irq);
//PPI 825
pia8255_0:=pia8255_chip.create;
pia8255_0.change_ports(nil,nil,nil,nil,nil,ppi8255_wportc);
//Sound
ym2151_0:=ym2151_chip.create(4000000);
sega_pcm_0:=tsega_pcm.create(4000000,outrun_read_pcm,1);
sega_pcm_0.set_bank(BANK_512);
if not(roms_load(@pcm_rom,outrun_pcm)) then exit;
for f:=0 to 5 do copymemory(@pcm_rom[$8000+(f*$10000)],@pcm_rom[0+(f*$10000)],$8000);
//Controls
init_analog(m68000_0.numero_cpu,m68000_0.clock);
analog_0(100,4,$80,$e0,$20,true,false,true,true);
analog_1(100,20,$ff,0,true);
analog_2(100,20,$ff,0,true);
//convertir tiles
if not(roms_load(@memoria_temp,outrun_tiles)) then exit;
init_gfx(0,8,8,$2000);
gfx[0].trans[0]:=true;
gfx_set_desc_data(3,0,8*8,$20000*8,$10000*8,0);
convert_gfx(0,0,@memoria_temp,@pt_x,@pt_y,false,false);
//Cargar ROM de los sprites
if not(roms_load32dw(@sprite_rom,outrun_sprites)) then exit;
s16_info.banks:=4;
//Cargar ROM road y decodificarla
if not(roms_load(@memoria_temp,outrun_road)) then exit;
decode_road;
road_info.colorbase1:=$400;
road_info.colorbase2:=$420;
road_info.colorbase3:=$780;
road_info.xoff:=0;
//dip
marcade.dswa:=$ff;
marcade.dswa_val2:=@outrun_dip_a;
marcade.dswb:=$fb;
marcade.dswb_val2:=@outrun_dip_b;
//poner la paleta
compute_resistor_weights(0,255,-1.0,
  6,addr(resistances_normal[0]),addr(weights[0]),0,0,
  0,nil,nil,0,0,
  0,nil,nil,0,0);
compute_resistor_weights(0,255,-1.0,
  6,addr(resistances_sh[0]),addr(weights[1]),0,0,
  0,nil,nil,0,0,
  0,nil,nil,0,0);
for f:=0 to 31 do begin
  i4:=(f shr 4) and 1;
  i3:=(f shr 3) and 1;
  i2:=(f shr 2) and 1;
  i1:=(f shr 1) and 1;
  i0:=(f shr 0) and 1;
  s16_info.normal[f]:=combine_6_weights(addr(weights[0]),i0,i1,i2,i3,i4,0);
  s16_info.shadow[f]:=combine_6_weights(addr(weights[1]),i0,i1,i2,i3,i4,0);
  s16_info.hilight[f]:=combine_6_weights(addr(weights[1]),i0,i1,i2,i3,i4,1);
end;
//final
iniciar_outrun:=true;
end;

end.
