unit sidearms_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,gfx_engine,ym_2203,rom_engine,pal_engine,
     sound_engine;

function iniciar_sidearms:boolean;

implementation
const
        sidearms_rom:array[0..2] of tipo_roms=(
        (n:'sa03.bin';l:$8000;p:0;crc:$e10fe6a0),(n:'a_14e.rom';l:$8000;p:$8000;crc:$4925ed03),
        (n:'a_12e.rom';l:$8000;p:$10000;crc:$81d0ece7));
        sidearms_snd_rom:tipo_roms=(n:'a_04k.rom';l:$8000;p:0;crc:$34efe2d2);
        sidearms_stars:tipo_roms=(n:'b_11j.rom';l:$8000;p:0;crc:$134dc35b);
        sidearms_char:tipo_roms=(n:'a_10j.rom';l:$4000;p:0;crc:$651fef75);
        sidearms_tiles:array[0..7] of tipo_roms=(
        (n:'b_13d.rom';l:$8000;p:0;crc:$3c59afe1),(n:'b_13e.rom';l:$8000;p:$8000;crc:$64bc3b77),
        (n:'b_13f.rom';l:$8000;p:$10000;crc:$e6bcea6f),(n:'b_13g.rom';l:$8000;p:$18000;crc:$c71a3053),
        (n:'b_14d.rom';l:$8000;p:$20000;crc:$826e8a97),(n:'b_14e.rom';l:$8000;p:$28000;crc:$6cfc02a4),
        (n:'b_14f.rom';l:$8000;p:$30000;crc:$9b9f6730),(n:'b_14g.rom';l:$8000;p:$38000;crc:$ef6af630));
        sidearms_sprites:array[0..7] of tipo_roms=(
        (n:'b_11b.rom';l:$8000;p:0;crc:$eb6f278c),(n:'b_13b.rom';l:$8000;p:$8000;crc:$e91b4014),
        (n:'b_11a.rom';l:$8000;p:$10000;crc:$2822c522),(n:'b_13a.rom';l:$8000;p:$18000;crc:$3e8a9f75),
        (n:'b_12b.rom';l:$8000;p:$20000;crc:$86e43eda),(n:'b_14b.rom';l:$8000;p:$28000;crc:$076e92d1),
        (n:'b_12a.rom';l:$8000;p:$30000;crc:$ce107f3c),(n:'b_14a.rom';l:$8000;p:$38000;crc:$dba06076));
        sidearms_back_tiles:tipo_roms=(n:'b_03d.rom';l:$8000;p:0;crc:$6f348008);
        sidearms_dip_a:array [0..4] of def_dip=(
        (mask:$07;name:'Difficulty';number:8;dip:((dip_val:$7;dip_name:'0 (Easiest)'),(dip_val:$6;dip_name:'1'),(dip_val:$5;dip_name:'2'),(dip_val:$4;dip_name:'3 (Normal)'),(dip_val:$3;dip_name:'4'),(dip_val:$2;dip_name:'5'),(dip_val:$1;dip_name:'6'),(dip_val:$0;dip_name:'7 (Hardest)'),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Lives';number:2;dip:((dip_val:$8;dip_name:'3'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Bonus Life';number:4;dip:((dip_val:$30;dip_name:'100K'),(dip_val:$20;dip_name:'100K 100K'),(dip_val:$10;dip_name:'150K 150K'),(dip_val:$0;dip_name:'200K 200K'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Flip Screen';number:2;dip:((dip_val:$40;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        sidearms_dip_b:array [0..4] of def_dip=(
        (mask:$07;name:'Coin A';number:8;dip:((dip_val:$0;dip_name:'4C 1C'),(dip_val:$1;dip_name:'3C 1C'),(dip_val:$02;dip_name:'2C 1C'),(dip_val:$07;dip_name:'1C 1C'),(dip_val:$06;dip_name:'1C 2C'),(dip_val:$05;dip_name:'1C 3C'),(dip_val:$04;dip_name:'1C 4C'),(dip_val:$03;dip_name:'1C 6C'),(),(),(),(),(),(),(),())),
        (mask:$38;name:'Coin B';number:8;dip:((dip_val:$0;dip_name:'4C 1C'),(dip_val:$8;dip_name:'3C 1C'),(dip_val:$10;dip_name:'2C 1C'),(dip_val:$38;dip_name:'1C 1C'),(dip_val:$30;dip_name:'1C 2C'),(dip_val:$28;dip_name:'1C 3C'),(dip_val:$20;dip_name:'1C 4C'),(dip_val:$18;dip_name:'1C 6C'),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Allow Continue';number:2;dip:((dip_val:$0;dip_name:'No'),(dip_val:$40;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$80;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 memoria_rom:array[0..7,0..$3fff] of byte;
 memoria_back,memoria_stars:array[0..$7fff] of byte;
 scroll_x,scroll_y:word;
 sound_command,rom_bank,vblank:byte;
 char_on,obj_on,bg_on,star_on,back_redraw:boolean;
 //Stars
 vcount_191,latch_374,hflop_74a_n:byte;
 hcount_191:word;

procedure draw_sprites;
procedure draw_sprites_def(total:byte;pos:word);
var
  nchar,x:word;
  f,y,atrib,color:byte;
begin
	for f:=total downto 0 do begin
    y:=buffer_sprites[pos+$2+(f*32)];
    if ((y=0) or (buffer_sprites[pos+$5+(f*32)]=$c3)) then continue;
    atrib:=buffer_sprites[pos+$1+(f*32)];
		color:=(atrib and $f) shl 4;
		nchar:=buffer_sprites[pos+$0+(f*32)]+((atrib shl 3) and $700);
		x:=buffer_sprites[pos+$3+(f*32)]+((atrib shl 4) and $100);
    put_gfx_sprite(nchar,color+$200,false,false,1);
    actualiza_gfx_sprite(x,y,3,1);
  end;
end;
begin
draw_sprites_def(8,$700);
draw_sprites_def($10,$e00);
draw_sprites_def($38,$800);
draw_sprites_def($38,0);
end;

procedure update_video_sidearms;
procedure draw_back;
var
  pos,offset,f,color,nchar:word;
  x,y,attr:byte;
begin
for f:=0 to $3fff do begin
    y:=f div 128;
    x:=f mod 128;
    offset:=((y shl 7)+x) shl 1;
    pos:=((offset and $f801) or ((offset and $0700) shr 7) or ((offset and $00fe) shl 3)) and $7fff;
    attr:=memoria_back[pos+1];
    color:=(attr shr 3) and $1f;
    nchar:=memoria_back[pos] or (attr and $1) shl 8;
    put_gfx_trans_flip(x*32,y*32,nchar,color shl 4,2,2,(attr and 2)<>0,(attr and 4)<>0);
end;
back_redraw:=false;
end;
procedure draw_stars;
var
  i,hadd_283,vadd_283,x,y:word;
  punt:array[0..511] of word;
begin
hadd_283:=0;
for y:=0 to 255 do begin// 8-bit V-clock input
    fillword(@punt,512,0);
		for x:=0 to 511 do begin  // 9-bit H-clock input
			i:=hadd_283; // store horizontal adder's previous state in i
			hadd_283:=hcount_191+(x and $ff); // add lower 8 bits and preserve carry
			if ((x<64) or (x>447) or (y<16) or (y>239)) then continue; // clip rejection
			vadd_283:=vcount_191+y; // add lower 8 bits and discard carry (later)
			if ((vadd_283 xor (x shr 3)) and 4)=0 then continue;       // logic rejection 1
			if ((vadd_283 or (hadd_283 shr 1)) and 2)<>0 then continue;   // logic rejection 2
			// latch data from starfield EPROM on rising edge of 74LS374's clock input
			if ((not(i) and $1f)=0) then begin
				i:=(vadd_283 shl 4) and $ff0;                // to starfield EPROM A04-A11 (8 bits)
				i:=i or ((hflop_74a_n xor (hadd_283 shr 8)) shl 3); // to starfield EPROM A03     (1 bit)
				i:=i or (hadd_283 shr 5 and 7);                   // to starfield EPROM A00-A02 (3 bits)
				latch_374:=memoria_stars[i+$3000];         // lines A12-A13 are always high
			end;
			if ((not((latch_374 xor hadd_283) xor 1) and $1f)<>0) then continue; // logic rejection 3
			punt[x]:=paleta[(latch_374 shr 5) or $378];
		end;
    putpixel(0+ADD_SPRITE,y+ADD_SPRITE,512,@punt,3);
  end;
end;
var
  f,nchar:word;
  color,attr,x,y:byte;
begin
if star_on then draw_stars
  else fill_full_screen(3,$400);
if bg_on then begin
  if back_redraw then draw_back;
  scroll_x_y(2,3,scroll_x,scroll_y);
end;
if obj_on then draw_sprites;
if char_on then begin
  for f:=0 to $7ff do begin
    //Chars
    attr:=memoria[f+$d800];
    color:=attr and $3f;
    if (gfx[0].buffer[f] or buffer_color[color]) then begin
      y:=f div 64;
      x:=f mod 64;
      nchar:=memoria[f+$d000] or ((attr and $c0) shl 2);
      put_gfx_trans(x*8,y*8,nchar,(color shl 2)+$300,1,0);
      gfx[0].buffer[f]:=false;
    end;
  end;
  actualiza_trozo(0,0,512,256,1,0,0,512,256,3);
end;
actualiza_trozo_final(64,16,384,224,3);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
end;

procedure eventos_sidearms;
begin
if event.arcade then begin
  //P1
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.but2[0] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  //P2
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.but2[1] then marcade.in2:=(marcade.in2 and $bf) else marcade.in2:=(marcade.in2 or $40);
  //SYSTEM
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
end;
end;

procedure sidearms_principal;
var
  f:byte;
  frame_m,frame_s:single;
begin
init_controls(false,false,false,true);
frame_m:=z80_0.tframes;
frame_s:=z80_1.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
    //Main
    z80_0.run(frame_m);
    frame_m:=frame_m+z80_0.tframes-z80_0.contador;
    //Sound
    z80_1.run(frame_s);
    frame_s:=frame_s+z80_1.tframes-z80_1.contador;
    case f of
      0:vblank:=0;
      $f0:begin
            z80_0.change_irq(HOLD_LINE);
            update_video_sidearms;
            vblank:=$80;
            copymemory(@buffer_sprites,@memoria[$f000],$1000);
          end;
    end;
  end;
  eventos_sidearms;
  video_sync;
end;
end;

function sidearms_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$7fff,$c000..$c7ff,$d000..$ffff:sidearms_getbyte:=memoria[direccion];
  $8000..$bfff:sidearms_getbyte:=memoria_rom[rom_bank,direccion and $3fff];
  $c800:sidearms_getbyte:=marcade.in0;
  $c801:sidearms_getbyte:=marcade.in1;
  $c802:sidearms_getbyte:=marcade.in2;
  $c803:sidearms_getbyte:=marcade.dswa;
  $c804:sidearms_getbyte:=marcade.dswb;
  $c805:sidearms_getbyte:=$7f or vblank;
end;
end;

procedure cambiar_color(numero:word);
var
  color:tcolor;
  tmp_color:word;
begin
  tmp_color:=memoria[$c000+numero]+(memoria[$c400+numero] shl 8);
  color.b:=pal4bit(tmp_color shr 8);
  color.r:=pal4bit(tmp_color shr 4);
  color.g:=pal4bit(tmp_color);
  set_pal_color(color,numero);
  case numero of
    $0..$1ff:back_redraw:=true;
    $300..$3ff:buffer_color[(numero shr 2) and $3f]:=true;
  end;
end;

procedure sidearms_putbyte(direccion:word;valor:byte);
var
  last_state:word;
begin
case direccion of
  0..$bfff:;
  $c000..$c7ff:begin
                  memoria[direccion]:=valor;
                  cambiar_color(direccion and $3ff);
               end;
  $c800:sound_command:=valor;
  $c801:rom_bank:=valor and $7;
  $c802:; //WD
  $c804:begin
          if (valor and $10)<>0 then z80_1.change_reset(ASSERT_LINE)
            else z80_1.change_reset(CLEAR_LINE);
          if (star_on<>((valor and $20)<>0)) then begin
            star_on:=(valor and $20)<>0;
		        hflop_74a_n:=1;
		        hcount_191:=0;
            vcount_191:=0;
          end;
          char_on:=(valor and $40)<>0;
          main_screen.flip_main_screen:=(valor and $80)<>0;
        end;
  $c805:begin
          last_state:=hcount_191;
	        hcount_191:=(hcount_191+1) and $1ff;
	        // invert 74LS74A(flipflop) output on 74LS191(hscan counter) carry's rising edge
	        if (hcount_191 and not(last_state) and $100)<>0 then hflop_74a_n:=hflop_74a_n xor 1;
        end;
  $c806:vcount_191:=vcount_191+1;
  $c808:scroll_x:=valor or (scroll_x and $f00);
  $c809:scroll_x:=((valor and $f) shl 8) or (scroll_x and $ff);
  $c80a:scroll_y:=valor or (scroll_y and $f00);
  $c80b:scroll_y:=((valor and $f) shl 8) or (scroll_y and $ff);
  $c80c:begin
          obj_on:=(valor and $1)<>0;
          bg_on:=(valor and $2)<>0;
        end;
  $d000..$dfff:if memoria[direccion]<>valor then begin
                  gfx[0].buffer[direccion and $7ff]:=true;
                  memoria[direccion]:=valor;
               end;
  $e000..$ffff:memoria[direccion]:=valor;
end;
end;

function sidearms_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff,$c000..$c7ff:sidearms_snd_getbyte:=mem_snd[direccion];
  $d000:sidearms_snd_getbyte:=sound_command;
  $f000:sidearms_snd_getbyte:=ym2203_0.status;
  $f002:sidearms_snd_getbyte:=ym2203_1.status;
end;
end;

procedure sidearms_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
    0..$7fff:;
    $c000..$c7ff:mem_snd[direccion]:=valor;
    $f000:ym2203_0.Control(valor);
    $f001:ym2203_0.Write(valor);
    $f002:ym2203_1.Control(valor);
    $f003:ym2203_1.Write(valor);
end;
end;

procedure snd_irq(irqstate:byte);
begin
  z80_1.change_irq(irqstate);
end;

procedure sidearms_sound_update;
begin
  ym2203_0.update;
  ym2203_1.update;
end;

//Main
procedure reset_sidearms;
begin
 z80_0.reset;
 z80_1.reset;
 ym2203_0.reset;
 ym2203_1.reset;
 reset_audio;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 scroll_x:=0;
 scroll_y:=0;
 rom_bank:=0;
 vblank:=0;
 sound_command:=0;
 back_redraw:=false;
 star_on:=false;
 bg_on:=false;
 obj_on:=false;
 char_on:=false;
 hflop_74a_n:=1;
 latch_374:=0;
 vcount_191:=0;
 hcount_191:=0;
end;

function iniciar_sidearms:boolean;
var
  f:word;
  memoria_temp:array[0..$3ffff] of byte;
const
    ps_x:array[0..15] of dword=(0, 1, 2, 3, 8+0, 8+1, 8+2, 8+3,
			32*8+0, 32*8+1, 32*8+2, 32*8+3, 33*8+0, 33*8+1, 33*8+2, 33*8+3);
    pt_x:array[0..31] of dword=(0, 1, 2, 3, 8+0, 8+1, 8+2, 8+3,
		32*16+0, 32*16+1, 32*16+2, 32*16+3, 32*16+8+0, 32*16+8+1, 32*16+8+2, 32*16+8+3,
		64*16+0, 64*16+1, 64*16+2, 64*16+3, 64*16+8+0, 64*16+8+1, 64*16+8+2, 64*16+8+3,
		96*16+0, 96*16+1, 96*16+2, 96*16+3, 96*16+8+0, 96*16+8+1, 96*16+8+2, 96*16+8+3);
    pt_y:array[0..31] of dword=(0*16,  1*16,  2*16,  3*16,  4*16,  5*16,  6*16,  7*16,
		8*16,  9*16, 10*16, 11*16, 12*16, 13*16, 14*16, 15*16,
		16*16, 17*16, 18*16, 19*16, 20*16, 21*16, 22*16, 23*16,
		24*16, 25*16, 26*16, 27*16, 28*16, 29*16, 30*16, 31*16);
begin
llamadas_maquina.bucle_general:=sidearms_principal;
llamadas_maquina.reset:=reset_sidearms;
iniciar_sidearms:=false;
iniciar_audio(false);
screen_init(1,512,512,true);
screen_init(2,4096,4096,true);
screen_mod_scroll(2,4096,512,4095,4096,512,4095);
screen_init(3,512,512,false,true);
iniciar_video(384,224);
//Main CPU
z80_0:=cpu_z80.create(4000000,$100);
z80_0.change_ram_calls(sidearms_getbyte,sidearms_putbyte);
//Sound CPU
z80_1:=cpu_z80.create(4000000,$100);
z80_1.change_ram_calls(sidearms_snd_getbyte,sidearms_snd_putbyte);
z80_1.init_sound(sidearms_sound_update);
//Sound Chips
ym2203_0:=ym2203_chip.create(4000000,0.25,1);
ym2203_0.change_irq_calls(snd_irq);
ym2203_1:=ym2203_chip.create(4000000,0.25,1);
//cargar roms y ponerlas en su sitio
if not(roms_load(@memoria_temp,sidearms_rom)) then exit;
copymemory(@memoria,@memoria_temp,$8000);
for f:=0 to 3 do copymemory(@memoria_rom[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
//cargar ROMS sonido
if not(roms_load(@mem_snd,sidearms_snd_rom)) then exit;
//convertir chars
if not(roms_load(@memoria_temp,sidearms_char)) then exit;
init_gfx(0,8,8,$400);
gfx[0].trans[3]:=true;
gfx_set_desc_data(2,0,16*8,4,0);
convert_gfx(0,0,@memoria_temp,@ps_x,@pt_y,false,false);
//background & stars
if not(roms_load(@memoria_back,sidearms_back_tiles)) then exit;
if not(roms_load(@memoria_stars,sidearms_stars)) then exit;
//convertir sprites
if not(roms_load(@memoria_temp,sidearms_sprites)) then exit;
init_gfx(1,16,16,$800);
gfx[1].trans[15]:=true;
gfx_set_desc_data(4,0,64*8,$800*64*8+4,$800*64*8+0,4,0);
convert_gfx(1,0,@memoria_temp,@ps_x,@pt_y,false,false);
//tiles
if not(roms_load(@memoria_temp,sidearms_tiles)) then exit;
init_gfx(2,32,32,$200);
gfx[2].trans[15]:=true;
gfx_set_desc_data(4,0,256*8,$200*256*8+4,$200*256*8+0,4,0);
convert_gfx(2,0,@memoria_temp,@pt_x,@pt_y,false,false);
//DIP
marcade.dswa:=$fc;
marcade.dswa_val:=@sidearms_dip_a;
marcade.dswb:=$ff;
marcade.dswb_val:=@sidearms_dip_b;
//final
reset_sidearms;
iniciar_sidearms:=true;
end;

end.
