unit system1_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     system1_hw_misc,system2_hw_misc,nz80,main_engine,gfx_engine,sn_76496,
     controls_engine,pal_engine,ppi8255,z80pio,qsnapshot,sound_engine;

procedure cargar_system1;

//Video
procedure update_video_system1;
procedure update_backgroud(screen:byte);
procedure cambiar_color_system2(numero:byte;pos:word);
//Events
procedure eventos_system1;
//PPI
function system1_inbyte_ppi(puerto:word):byte;
procedure system1_outbyte_ppi(puerto:word;valor:byte);
function system1_snd_getbyte_ppi(direccion:word):byte;
procedure system1_snd_putbyte(direccion:word;valor:byte);
procedure system1_port_a_write(valor:byte);
procedure system1_port_b_write(valor:byte);
procedure system1_port_gardia_write(valor:byte);
procedure system1_port_c_write(valor:byte);
//Sound
procedure system1_sound_update;
procedure system1_sound_irq;
procedure system1_ready_cb(state:byte);
//Misc
procedure system1_adjust_cycle(instruccion:byte);

const
  system1_dip_credit:array [0..2] of def_dip=(
  (mask:$0f;name:'Coin A';number:16;dip:((dip_val:$07;dip_name:'4C 1C'),(dip_val:$08;dip_name:'3C 1C'),(dip_val:$09;dip_name:'2C 1C'),(dip_val:$05;dip_name:'2C 1C/5C 3C/6C 4C'),(dip_val:$04;dip_name:'2C 1C/4C 3C'),(dip_val:$0f;dip_name:'1C 1C'),(dip_val:$01;dip_name:'1C 1C/2C 3C'),(dip_val:$02;dip_name:'1C 1C/4C 5C'),(dip_val:$03;dip_name:'1C 1C/5C 6C'),(dip_val:$06;dip_name:'2C 3C'),(dip_val:$0e;dip_name:'1C 2C'),(dip_val:$0d;dip_name:'1C 3C'),(dip_val:$0c;dip_name:'1C 4C'),(dip_val:$0b;dip_name:'1C 5C'),(dip_val:$0a;dip_name:'1C 6C'),(dip_val:$00;dip_name:'1C 1C'))),
  (mask:$f0;name:'Coin B';number:16;dip:((dip_val:$70;dip_name:'4C 1C'),(dip_val:$80;dip_name:'3C 1C'),(dip_val:$90;dip_name:'2C 1C'),(dip_val:$50;dip_name:'2C 1C/5C 3C/6C 4C'),(dip_val:$40;dip_name:'2C 1C/4C 3C'),(dip_val:$f0;dip_name:'1C 1C'),(dip_val:$10;dip_name:'1C 1C/2C 3C'),(dip_val:$20;dip_name:'1C 1C/4C 5C'),(dip_val:$30;dip_name:'1C 1C/5C 6C'),(dip_val:$60;dip_name:'2C 3C'),(dip_val:$e0;dip_name:'1C 2C'),(dip_val:$d0;dip_name:'1C 3C'),(dip_val:$c0;dip_name:'1C 4C'),(dip_val:$b0;dip_name:'1C 5C'),(dip_val:$a0;dip_name:'1C 6C'),(dip_val:$00;dip_name:'1C 1C'))),());
  pc_x:array[0..7] of dword=(0, 1, 2, 3, 4, 5, 6, 7);
  pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);

var
 //Screens
 bg_ram:array[0..$3fff] of byte;
 bg_ram_w:array[0..$1fff] of boolean;
 sprites_final_screen:array[0..$ffff] of word;
 final_screen:array[0..7,0..$ffff] of word;
 bgpixmaps:array[0..3] of byte;
 sprite_num_banks,sprite_offset,bg_ram_bank:byte;
 yscroll,mask_char:word;
 xscroll:array[0..$1f] of word;
 //Roms
 memoria_proms:array[0..$2ff] of byte;
 lookup_memory:array[0..$ff] of byte;
 mem_dec:array[0..$7fff] of byte;
 roms:array[0..3,0..$3fff] of byte;
 rom_bank:byte;
 //Colisiones
 sprite_collide:array[0..$3ff] of byte;
 mix_collide:array[0..$3f] of byte;
 memoria_sprites:array[0..$1ffff] of byte;
 mix_collide_summary,sprite_collide_summary:byte;
 //Misc
 sound_latch,scroll_x,scroll_y,system1_videomode:byte;
 char_screen:byte;

implementation

procedure update_backgroud(screen:byte);
procedure put_gfx_system1(pos_x,pos_y,nchar,color:word;screen:byte);
var
  x,y:byte;
  temp:pword;
  pos:pbyte;
begin
pos:=gfx[0].datos;
inc(pos,nchar*8*8);
for y:=0 to 7 do begin
  temp:=punbuf;
  for x:=0 to 7 do begin
    temp^:=pos^ or color;
    inc(pos);
    inc(temp);
  end;
  copymemory(@final_screen[screen,pos_x+((pos_y+y)*256)],punbuf,8*2);
end;
end;
var
  source,f,color,nchar,atrib:word;
  x,y:word;
begin
source:=screen shl 11;
for f:=0 to $3ff do begin
   if (bg_ram_w[f+(source shr 1)]) then begin
      x:=f mod 32;
      y:=f div 32;
      atrib:=bg_ram[f*2+source]+(bg_ram[$1+(f*2)+source] shl 8);
      nchar:=(((atrib shr 4) and $800) or (atrib and $7ff)) and mask_char;
      color:=((atrib shr 5) and $ff) shl 3;
      put_gfx_system1(x*8,y*8,nchar,color,screen);
      bg_ram_w[f+(source shr 1)]:=false;
   end;
end;
end;

procedure update_video_system1;
var
  x,y:integer;
  temp:pword;
  fgbase,sprbase,bgy,bgxscroll:word;
  lookup_value,lookup_index:byte;
  bgx,fgpix,bgpix,sprpix:word;
  bgbase:array[0..1] of byte;
  bit0,bit1,bit2,bit3,bit4:byte;
procedure draw_sprites;
var
  spritedata,srcaddr,stride:word;
  bank,xstart,bottom,top,palettebase:word;
  x,y,addrdelta:integer;
  f,color1,color2,data:byte;
  gfxbankbase:dword;
  curaddr,destbase,prevpix:word;
begin
for f:=0 to 31 do begin
  spritedata:=$d000+f*$10;
  srcaddr:=memoria[spritedata+6]+(memoria[spritedata+7] shl 8);
  stride:=memoria[spritedata+4]+(memoria[spritedata+5] shl 8);
	bank:=((memoria[spritedata+3] and $80) shr 7) or ((memoria[spritedata+3] and $40) shr 5) or ((memoria[spritedata+3] and $20) shr 3);
	xstart:=(((memoria[spritedata+2]+(memoria[spritedata+3] shl 8)) and $1ff) div 2)+sprite_offset;
	bottom:=memoria[spritedata+1]+1;
	top:=memoria[spritedata+0]+1;
	palettebase:=f*$10;
  bank:=bank mod sprite_num_banks;
  gfxbankbase:=bank*$8000;
  for y:=top to bottom-1 do begin
			destbase:=y*256;
			// advance by the row counter
			srcaddr:=srcaddr+stride;
			// skip if outside of our clipping area
			if (y<0) or (y>256) then continue;
			// iterate over X
      if (srcaddr and $8000)<>0 then addrdelta:=-1
        else addrdelta:=1;
      curaddr:=srcaddr;
      x:=xstart;
      while True do begin
				data:=memoria_sprites[gfxbankbase+(curaddr and $7fff)];
				// non-flipped case
				if (curaddr and $8000)=0 then begin
					color1:=data shr 4;
					color2:=data and $f;
				end else begin
					color1:=data and $f;
					color2:=data shr 4;
				end;
				// stop when we see color 0x0f
				if (color1=$f) then break;
				// draw if non-transparent
				if (color1<>0) then begin
					if ((x>=0) and (x<=255)) then begin
						prevpix:=sprites_final_screen[destbase+x];
						if ((prevpix and $f)<>0) then begin
              sprite_collide[((prevpix shr 4) and $1f)+32*f]:=1;
              sprite_collide_summary:=1;
            end;
						sprites_final_screen[destbase+x]:=color1 or palettebase;
					end;
				end;
        // stop when we see color 0x0f
				if (color2=$f) then break;
				// draw if non-transparent
				if (color2<>0) then begin
					if (((x+1)>=0) and ((x+1)<=255)) then begin
						prevpix:=sprites_final_screen[destbase+x+1];
						if ((prevpix and $f)<>0) then begin
              sprite_collide[((prevpix shr 4) and $1f)+32*f]:=1;
              sprite_collide_summary:=1;
            end;
						sprites_final_screen[destbase+x+1]:=color2 or palettebase;
					end;
        end;
        curaddr:=curaddr+addrdelta;
        x:=x+2;
				end;
      end;
  end; //del for f
end;

begin
if (system1_videomode and $10)<>0 then begin
  fill_full_screen(0,$800);
  exit;
end;
fillword(@sprites_final_screen,$10000,0);
//Actualizar sprites
if memoria[$d000]<>$ff then draw_sprites;
//Pintarlo todo
for y:=0 to 255 do begin
    temp:=punbuf;
		fgbase:=(y and $ff)*256;
		sprbase:=(y and $ff)*256;
    bgy:=(y+yscroll) and $1ff;
    bgxscroll:=xscroll[y div 8];
		// get the base of the left and right pixmaps for the effective background Y
		bgbase[0]:=bgpixmaps[(bgy shr 8)*2+0];
		bgbase[1]:=bgpixmaps[(bgy shr 8)*2+1];
		// iterate over pixels
		for x:=0 to 255 do begin
			bgx:=(x-bgxscroll) and $1ff;
			fgpix:=final_screen[char_screen,fgbase+x];
			bgpix:=final_screen[bgbase[bgx shr 8],(bgx and $ff)+(bgy and $ff)*256];
			sprpix:=sprites_final_screen[sprbase+x];
			//using the sprite, background, and foreground pixels, look up the color behavior
      if (sprpix and $f)=0 then bit0:=1
        else bit0:=0;
      if (fgpix and 7)=0 then bit1:=2
        else bit1:=0;
      bit2:=((fgpix shr 9) and 3) shl 2;
      if (bgpix and 7)=0 then bit3:=16
        else bit3:=0;
      bit4:=((bgpix shr 9) and 3) shl 5;
			lookup_index:=bit0 or bit1 or bit2 or	bit3 or	bit4;
			lookup_value:=lookup_memory[lookup_index];
			// compute collisions based on two of the PROM bits
			if (lookup_value and 4)=0 then begin
				mix_collide[((lookup_value and 8) shl 2) or ((sprpix shr 4) and $1f)]:=1;
        mix_collide_summary:=1;
      end;
			// the lower 2 PROM bits select the palette and which pixels
			lookup_value:=lookup_value and 3;
      if (lookup_value=0) then temp^:=paleta[$000 or (sprpix and $1ff)]
			    else if (lookup_value=1) then temp^:=paleta[$200 or (fgpix and $1ff)]
			      else temp^:=paleta[$400 or (bgpix and $1ff)];
      inc(temp);
		end;
    putpixel(ADD_SPRITE,y+ADD_SPRITE,256,punbuf,1);
end;
//Pantalla final
if main_screen.rot270_screen then actualiza_trozo_final(8,0,240,224,1)
  else actualiza_trozo_final(0,0,256,224,1);
end;

procedure cambiar_color_system2(numero:byte;pos:word);
var
  color:tcolor;
  tmpb:byte;
begin
  tmpb:=memoria_proms[numero];
  color.r:=$0e*(tmpb and 1)+$1f*((tmpb and 2) shr 1)+$43*((tmpb and 4) shr 2)+$8f*((tmpb and 8) shr 3);
  tmpb:=memoria_proms[numero+$100];
  color.g:=$0e*(tmpb and 1)+$1f*((tmpb and 2) shr 1)+$43*((tmpb and 4) shr 2)+$8f*((tmpb and 8) shr 3);
  tmpb:=memoria_proms[numero+$200];
  color.b:=$0e*(tmpb and 1)+$1f*((tmpb and 2) shr 1)+$43*((tmpb and 4) shr 2)+$8f*((tmpb and 8) shr 3);
  set_pal_color(color,pos);
end;

//Main CPU PPI
function system1_inbyte_ppi(puerto:word):byte;
begin
case (puerto and $1f) of
  $0..$3:system1_inbyte_ppi:=marcade.in1;
  $4..$7:system1_inbyte_ppi:=marcade.in2;
  $8..$b:system1_inbyte_ppi:=marcade.in0;
  $c,$e:system1_inbyte_ppi:=marcade.dswa;
  $d,$f,$10..$13:system1_inbyte_ppi:=marcade.dswb;
  $14..$17:system1_inbyte_ppi:=pia8255_0.read(puerto and $3);
end;
end;

procedure system1_outbyte_ppi(puerto:word;valor:byte);
begin
case (puerto and $1f) of
  $14..$17:pia8255_0.write(puerto and $3,valor);
end;
end;

//Sound CPU
function system1_snd_getbyte_ppi(direccion:word):byte;
var
  port_c_val:byte;
begin
case direccion of
  $0000..$7fff:system1_snd_getbyte_ppi:=mem_snd[direccion];
  $8000..$9fff:system1_snd_getbyte_ppi:=mem_snd[(direccion and $7ff)+$8000];
  $e000..$ffff:begin
                  system1_snd_getbyte_ppi:=sound_latch;
                  port_c_val:=pia8255_0.get_port(2);
                  pia8255_0.set_port(2,port_c_val and $bf);
                  pia8255_0.set_port(2,port_c_val or $40);
               end;
end;
end;

procedure system1_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:; //ROM
  $8000..$9fff:mem_snd[(direccion and $7ff)+$8000]:=valor;
  $a000..$bfff:sn_76496_0.Write(valor);
  $c000..$dfff:sn_76496_1.Write(valor);
end;
end;

procedure system1_sound_update;
begin
  sn_76496_0.update;
  sn_76496_1.update;
end;

procedure system1_sound_irq;
begin
  z80_1.change_irq(HOLD_LINE);
end;

procedure eventos_system1;
begin
if event.arcade then begin
  //System
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  //P1
  if arcade_input.but2[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
  //P2
  if arcade_input.but2[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or 1);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or 2);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or 4);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $bf) else marcade.in2:=(marcade.in2 or $40);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $7f) else marcade.in2:=(marcade.in2 or $80);
end;
end;

//PPI 8255
procedure system1_port_a_write(valor:byte);
begin //soundport_w
  sound_latch:=valor;
end;

procedure system1_port_b_write(valor:byte);
begin
  rom_bank:=(valor and $c) shr 2;
  system1_videomode:=valor;
end;

procedure system1_port_gardia_write(valor:byte);
begin
  rom_bank:=(((valor and $40) shr 5) or ((valor and 4) shr 2));
  system1_videomode:=valor;
end;

procedure system1_port_c_write(valor:byte);
begin //sound_controlw
  if (valor and $80)<>0 then z80_1.change_nmi(CLEAR_LINE)
    else z80_1.change_nmi(ASSERT_LINE);
  bg_ram_bank:=(valor shr 1) and 3;
end;

procedure system1_adjust_cycle(instruccion:byte);
begin
  z80_0.contador:=z80_0.contador+1;
end;

procedure system1_ready_cb(state:byte);
begin
  if state=CLEAR_LINE then z80_1.change_halt(ASSERT_LINE)
    else z80_1.change_halt(CLEAR_LINE);
end;

//Main
procedure reset_system1;
begin
case main_vars.tipo_maquina of
  27,35,36,153,155,384:pio_0.reset;
  37,151,152,154:pia8255_0.reset;
end;
z80_0.reset;
z80_1.reset;
frame_main:=z80_0.tframes;
frame_snd:=z80_1.tframes;
sn_76496_0.reset;
sn_76496_1.reset;
reset_game_general;
marcade.in0:=$ff;
marcade.in1:=$ff;
marcade.in2:=$ff;
sound_latch:=0;
mix_collide_summary:=0;
sprite_collide_summary:=0;
scroll_x:=0;
scroll_y:=0;
system1_videomode:=0;
//System 2
rom_bank:=0;
bg_ram_bank:=0;
//Clear all
fillchar(bg_ram,$4000,0);
fillchar(bg_ram_w,$2000,0);
fillchar(sprites_final_screen,$20000,0);
fillchar(final_screen[0,0],8*$10000*2,0);
fillchar(bgpixmaps,4,0);
yscroll:=0;
fillchar(xscroll,$20*2,0);
fillchar(sprite_collide,$400,0);
fillchar(mix_collide,$40,0);
end;

procedure system1_qsave(nombre:string);
var
  data:pbyte;
  size:word;
  buffer:array[0..9] of byte;
  f:byte;
begin
case main_vars.tipo_maquina of
  27:open_qsnapshot_save('pitfall2'+nombre);
  35:open_qsnapshot_save('teddybb'+nombre);
  36:open_qsnapshot_save('wonderboy'+nombre);
  37:open_qsnapshot_save('wbml'+nombre);
  151:open_qsnapshot_save('choplifter'+nombre);
  152:open_qsnapshot_save('viking'+nombre);
  153:open_qsnapshot_save('sninja'+nombre);
  154:open_qsnapshot_save('upanddown'+nombre);
  155:open_qsnapshot_save('flicky'+nombre);
  384:open_qsnapshot_save('gardia'+nombre);
end;
getmem(data,2000);
//CPU1
size:=z80_0.save_snapshot(data);
savedata_qsnapshot(data,size);
//CPU2
size:=z80_1.save_snapshot(data);
savedata_qsnapshot(data,size);
//SND
size:=sn_76496_0.save_snapshot(data);
savedata_qsnapshot(data,size);
size:=sn_76496_1.save_snapshot(data);
savedata_qsnapshot(data,size);
//PIA
if ((main_vars.tipo_maquina=37) or (main_vars.tipo_maquina=151) or (main_vars.tipo_maquina=152) or (main_vars.tipo_maquina=154)) then begin
  size:=pia8255_0.save_snapshot(data);
  savedata_qsnapshot(data,size);
end;
//MEM
savedata_qsnapshot(@memoria[$c000],$1800);
savedata_qsnapshot(@mem_snd[$8000],$800);
savedata_qsnapshot(@bg_ram[0],$4000);
savedata_qsnapshot(@sprites_final_screen[0],$10000*2);
for f:=0 to 7 do savedata_qsnapshot(@final_screen[0,f],$10000*2);
savedata_qsnapshot(@bgpixmaps[0],4);
savedata_qsnapshot(@xscroll[0],$20*2);
savedata_qsnapshot(@sprite_collide,$400);;
savedata_qsnapshot(@mix_collide,$40);
savedata_qsnapshot(@memoria_sprites,$20000);
savedata_qsnapshot(@buffer_paleta,$800*2);
//MISC
buffer[0]:=sound_latch;
buffer[1]:=bg_ram_bank;
buffer[2]:=rom_bank;
buffer[3]:=mix_collide_summary;
buffer[4]:=sprite_collide_summary;
buffer[5]:=scroll_x;
buffer[6]:=scroll_y;
buffer[7]:=system1_videomode;
buffer[8]:=yscroll and $ff;
buffer[9]:=yscroll shr 8;
savedata_qsnapshot(@buffer,10);
freemem(data);
close_qsnapshot;
end;

procedure system1_qload(nombre:string);
var
  data:pbyte;
  buffer:array[0..9] of byte;
  f:word;
begin
case main_vars.tipo_maquina of
  27:if not(open_qsnapshot_load('pitfall2'+nombre)) then exit;
  35:if not(open_qsnapshot_load('teddybb'+nombre)) then exit;
  36:if not(open_qsnapshot_load('wonderboy'+nombre)) then exit;
  37:if not(open_qsnapshot_load('wbml'+nombre)) then exit;
  151:if not(open_qsnapshot_load('choplifter'+nombre)) then exit;
  152:if not(open_qsnapshot_load('viking'+nombre)) then exit;
  153:if not(open_qsnapshot_load('sninja'+nombre)) then exit;
  154:if not(open_qsnapshot_load('upanddown'+nombre)) then exit;
  155:if not(open_qsnapshot_load('flicky'+nombre)) then exit;
  384:if not(open_qsnapshot_load('gardia'+nombre)) then exit;
end;
getmem(data,2000);
//CPU1
loaddata_qsnapshot(data);
z80_0.load_snapshot(data);
//CPU2
loaddata_qsnapshot(data);
z80_1.load_snapshot(data);
//SND
loaddata_qsnapshot(data);
sn_76496_0.load_snapshot(data);
loaddata_qsnapshot(data);
sn_76496_1.load_snapshot(data);
//PIA
if ((main_vars.tipo_maquina=37) or (main_vars.tipo_maquina=151) or (main_vars.tipo_maquina=152) or (main_vars.tipo_maquina=154)) then begin
  loaddata_qsnapshot(data);
  pia8255_0.load_snapshot(data);
end;
//MEM
loaddata_qsnapshot(@memoria[$c000]);
loaddata_qsnapshot(@mem_snd[$8000]);
loaddata_qsnapshot(@bg_ram[0]);
loaddata_qsnapshot(@sprites_final_screen[0]);
for f:=0 to 7 do loaddata_qsnapshot(@final_screen[0,f]);
loaddata_qsnapshot(@bgpixmaps[0]);
loaddata_qsnapshot(@xscroll[0]);
loaddata_qsnapshot(@sprite_collide);
loaddata_qsnapshot(@mix_collide);
loaddata_qsnapshot(@memoria_sprites);
loaddata_qsnapshot(@buffer_paleta);
//MISC
loaddata_qsnapshot(@buffer);
sound_latch:=buffer[0];
bg_ram_bank:=buffer[1];
rom_bank:=buffer[2];
mix_collide_summary:=buffer[3];
sprite_collide_summary:=buffer[4];
scroll_x:=buffer[5];
scroll_y:=buffer[6];
system1_videomode:=buffer[7];
yscroll:=buffer[8];
yscroll:=yscroll or (buffer[9] shl 8);
freemem(data);
close_qsnapshot;
fillchar(bg_ram_w[$0],$2000,1);
case main_vars.tipo_maquina of
  27,35,36,152,153,154,155:for f:=0 to $7ff do cambiar_color_system1(buffer_paleta[f],f);
  37,151,384:for f:=0 to $7ff do cambiar_color_system2(buffer_paleta[f],f);
end;
end;

procedure cargar_system1;
begin
case main_vars.tipo_maquina of
  27,35,36,152,153,154,155,384:begin
        llamadas_maquina.iniciar:=iniciar_system1;
        llamadas_maquina.bucle_general:=system1_principal;
     end;
  37,151:begin
        llamadas_maquina.iniciar:=iniciar_system2;
        llamadas_maquina.bucle_general:=system2_principal;
     end;
end;
llamadas_maquina.reset:=reset_system1;
llamadas_maquina.save_qsnap:=system1_qsave;
llamadas_maquina.load_qsnap:=system1_qload;
llamadas_maquina.fps_max:=60.096154;
end;

end.

