unit super_cassette_vision;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     upd7810,main_engine,controls_engine,sysutils,dialogs,gfx_engine,
     rom_engine,misc_functions,sound_engine,file_engine,pal_engine,upd1771;

function iniciar_scv:boolean;

type tsupercassette=record
        chars:array[0..$3ff] of byte;
        porta_val,portc_val:byte;
        keys:array[0..8] of byte;
        rom:array[0..3,0..$7fff] of byte;
        rom_window,rom_bank_type:byte;
        ram_bank,ram_bank2:boolean;
     end;

var
  scv_0:tsupercassette;

implementation
uses snapshot,principal;

const
  scv_bios:array[0..1] of tipo_roms=(
    (n:'upd7801g.s01';l:$1000;p:0;crc:$7ac06182),(n:'epochtv.chr';l:$400;p:$1000;crc:$db521533));
  scv_paleta:array[0..15] of integer=(
        $00009B,$000000,$0000FF,$A100FF,
        $00FF00,$A0FF9D,$00FFFF,$00A100,
        $FF0000,$FFA100,$FF00FF,$FFA09F,
        $FFFF00,$A3A000,$A1A09D,$FFFFFF);

procedure eventos_svc;
begin
if event.keyboard then begin
   //P1
   if keyboard[KEYBOARD_0] then scv_0.keys[2]:=(scv_0.keys[2] and $bf) else scv_0.keys[2]:=(scv_0.keys[2] or $40);
   if keyboard[KEYBOARD_1] then scv_0.keys[2]:=(scv_0.keys[2] and $7f) else scv_0.keys[2]:=(scv_0.keys[2] or $80);
   if keyboard[KEYBOARD_2] then scv_0.keys[3]:=(scv_0.keys[3] and $bf) else scv_0.keys[3]:=(scv_0.keys[3] or $40);
   if keyboard[KEYBOARD_3] then scv_0.keys[3]:=(scv_0.keys[3] and $7f) else scv_0.keys[3]:=(scv_0.keys[3] or $80);
   if keyboard[KEYBOARD_4] then scv_0.keys[4]:=(scv_0.keys[4] and $bf) else scv_0.keys[4]:=(scv_0.keys[4] or $40);
   if keyboard[KEYBOARD_5] then scv_0.keys[4]:=(scv_0.keys[4] and $7f) else scv_0.keys[4]:=(scv_0.keys[4] or $80);
   if keyboard[KEYBOARD_6] then scv_0.keys[5]:=(scv_0.keys[5] and $bf) else scv_0.keys[5]:=(scv_0.keys[5] or $40);
   if keyboard[KEYBOARD_7] then scv_0.keys[5]:=(scv_0.keys[5] and $7f) else scv_0.keys[5]:=(scv_0.keys[5] or $80);
   if keyboard[KEYBOARD_8] then scv_0.keys[6]:=(scv_0.keys[6] and $bf) else scv_0.keys[6]:=(scv_0.keys[6] or $40);
   if keyboard[KEYBOARD_9] then scv_0.keys[6]:=(scv_0.keys[6] and $7f) else scv_0.keys[6]:=(scv_0.keys[6] or $80);
   if keyboard[KEYBOARD_Q] then scv_0.keys[7]:=(scv_0.keys[7] and $bf) else scv_0.keys[7]:=(scv_0.keys[7] or $40);
   if keyboard[KEYBOARD_W] then scv_0.keys[7]:=(scv_0.keys[7] and $7f) else scv_0.keys[7]:=(scv_0.keys[7] or $80);
   if keyboard[KEYBOARD_P] then scv_0.keys[8]:=(scv_0.keys[8] and $fe) else scv_0.keys[8]:=(scv_0.keys[8] or $1);
end;
if event.arcade then begin
   //P1
   if arcade_input.left[0] then scv_0.keys[0]:=(scv_0.keys[0] and $fe) else scv_0.keys[0]:=(scv_0.keys[0] or 1);
   if arcade_input.up[0] then scv_0.keys[0]:=(scv_0.keys[0] and $fd) else scv_0.keys[0]:=(scv_0.keys[0] or 2);
   if arcade_input.but0[0] then scv_0.keys[0]:=(scv_0.keys[0] and $fb) else scv_0.keys[0]:=(scv_0.keys[0] or 4);
   if arcade_input.left[1] then scv_0.keys[0]:=(scv_0.keys[0] and $f7) else scv_0.keys[0]:=(scv_0.keys[0] or 8);
   if arcade_input.up[1] then scv_0.keys[0]:=(scv_0.keys[0] and $ef) else scv_0.keys[0]:=(scv_0.keys[0] or $10);
   if arcade_input.but0[1] then scv_0.keys[0]:=(scv_0.keys[0] and $df) else scv_0.keys[0]:=(scv_0.keys[0] or $20);
   //P2
   if arcade_input.down[0] then scv_0.keys[1]:=(scv_0.keys[1] and $fe) else scv_0.keys[1]:=(scv_0.keys[1] or 1);
   if arcade_input.right[0] then scv_0.keys[1]:=(scv_0.keys[1] and $fd) else scv_0.keys[1]:=(scv_0.keys[1] or 2);
   if arcade_input.but1[0] then scv_0.keys[1]:=(scv_0.keys[1] and $fb) else scv_0.keys[1]:=(scv_0.keys[1] or 4);
   if arcade_input.down[1] then scv_0.keys[1]:=(scv_0.keys[1] and $f7) else scv_0.keys[1]:=(scv_0.keys[1] or 8);
   if arcade_input.right[1] then scv_0.keys[1]:=(scv_0.keys[1] and $ef) else scv_0.keys[1]:=(scv_0.keys[1] or $10);
   if arcade_input.but1[1] then scv_0.keys[1]:=(scv_0.keys[1] and $df) else scv_0.keys[1]:=(scv_0.keys[1] or $20);
end;
end;

procedure update_video_svc;
procedure draw_text(x,y:byte;char_data:word;fg,bg:byte);
var
  h,f,d:byte;
  tempw:array[0..7] of word;
begin
	for f:=0 to 7 do begin
		d:=scv_0.chars[char_data+f];
    for h:=0 to 7 do begin
      if (d and $80)<>0 then tempw[h]:=paleta[fg]
        else tempw[h]:=paleta[bg];
      d:=d shl 1;
    end;
    putpixel(x,(y+f) and $ff,8,@tempw,1);
	end;
  for f:=0 to 7 do tempw[f]:=paleta[bg];
	for f:=8 to 15 do putpixel(x,(y+f) and $ff,8,@tempw,1);
end;

procedure draw_semi_graph(x,y,data,fg:byte);
var
  f:byte;
  tempw:array[0..3] of word;
begin
	if (data=0) then exit;
  for f:=0 to 3 do tempw[f]:=paleta[fg];
	for f:=0 to 3 do putpixel(x,(y+f) and $ff,4,@tempw,1);
end;

procedure draw_block_graph(x,y,col:byte);
var
  f:byte;
  tempw:array[0..7] of word;
begin
  for f:=0 to 7 do tempw[f]:=paleta[col];
	for f:=0 to 7 do putpixel(x,(y+f) and $ff,8,@tempw,1);
end;

procedure plot_sprite_part(x,y,pat,col,screen_sprite_start_line:byte);
var
  tempw:word;
begin
	if ((x>=4) and ((y+2)>=screen_sprite_start_line)) then begin
		x:=x-4;
    tempw:=paleta[col];
		if (pat and $08)<>0 then putpixel(x,y+2,1,@tempw,1);
		if (((pat and $04)<>0) and (x<255)) then putpixel(x+1,y+2,1,@tempw,1);
		if (((pat and $02)<>0) and (x<254)) then putpixel(x+2,y+2,1,@tempw,1);
		if (((pat and $01)<>0) and (x<253)) then putpixel(x+3,y+2,1,@tempw,1);
	end;
end;

procedure draw_sprite(x,y,tile_idx,col:byte;left,right,top,bottom:boolean;clip_y,screen_sprite_start_line:byte);
var
  f,pat0,pat1,pat2,pat3:byte;
begin
	y:=y+clip_y*2;
	for f:=clip_y to 7 do begin
		pat0:=memoria[$2000+tile_idx*32+(f*4)];
		pat1:=memoria[$2001+tile_idx*32+(f*4)];
		pat2:=memoria[$2002+tile_idx*32+(f*4)];
		pat3:=memoria[$2003+tile_idx*32+(f*4)];
		if ((top and ((f*4)<16)) or (bottom and ((f*4)>=16))) then begin
			if left then begin
				plot_sprite_part(x     , y, pat0 shr 4, col, screen_sprite_start_line);
				plot_sprite_part(x +  4, y, pat1 shr 4, col, screen_sprite_start_line);
			end;
			if right then begin
				plot_sprite_part(x +  8, y, pat2 shr 4, col, screen_sprite_start_line);
				plot_sprite_part(x + 12, y, pat3 shr 4, col, screen_sprite_start_line);
			end;
			if left then begin
				plot_sprite_part(x     , y + 1, pat0 and $0f, col, screen_sprite_start_line);
				plot_sprite_part(x +  4, y + 1, pat1 and $0f, col, screen_sprite_start_line);
			end;
			if right then begin
				plot_sprite_part(x +  8, y + 1, pat2 and $0f, col, screen_sprite_start_line);
				plot_sprite_part(x + 12, y + 1, pat3 and $0f, col, screen_sprite_start_line);
			end;
		end;
    y:=y+2;
  end;
end;

const
  spr_2col_lut0:array[0..15] of byte=(0, 15, 12, 13, 10, 11,  8, 9, 6, 7,  4,  5, 2, 3,  1,  1);
  spr_2col_lut1:array[0..15] of byte=(0,  1,  8, 11,  2,  3, 10, 9, 4, 5, 12, 13, 6, 7, 14, 15);
var
  screen_start_sprite_line,clip_x,clip_y,x,y,d,fg,bg,gr_fg,gr_bg:byte;
  text_x,text_y,half,x_32,y_32,left,right,top,bottom:boolean;
  spr_col,f,spr_y,clip,col,spr_x,tile_idx:byte;
begin
fg:=memoria[$3403] shr 4;
bg:=memoria[$3403] and $0f;
gr_fg:=memoria[$3401] shr 4;
gr_bg:=memoria[$3401] and $f;
clip_x:=(memoria[$3402] and $0f)*2;
clip_y:=memoria[$3402] shr 4;
fill_full_screen(1,gr_bg);
// Draw background
for y:=0 to 15 do begin
		if (y<clip_y) then text_y:=(memoria[$3400] and $80)=0
		  else text_y:=(memoria[$3400] and $80)<>0;
		for x:=0 to 31 do begin
			d:=memoria[$3000+y*32+x];
			if (x<clip_x) then text_x:=(memoria[$3400] and $40)=0
			  else text_x:=(memoria[$3400] and $40)<>0;
			if (text_x and text_y) then begin // Text mode
				draw_text(x*8,y*16,(d and $7f)*8,fg,bg);
      end else begin
				case (memoria[$3400] and 3) of
				  01:begin      // Semi graphics mode
					    draw_semi_graph(x * 8    , y * 16     , d and $80, gr_fg );
              draw_semi_graph(x * 8 + 4, y * 16     , d and $40, gr_fg );
					    draw_semi_graph(x * 8    , y * 16 +  4, d and $20, gr_fg );
					    draw_semi_graph(x * 8 + 4, y * 16 +  4, d and $10, gr_fg );
					    draw_semi_graph(x * 8    , y * 16 +  8, d and $08, gr_fg );
					    draw_semi_graph(x * 8 + 4, y * 16 +  8, d and $04, gr_fg );
					    draw_semi_graph(x * 8    , y * 16 + 12, d and $02, gr_fg );
					    draw_semi_graph(x * 8 + 4, y * 16 + 12, d and $01, gr_fg );
             end;
				  03:begin      // Block graphics mode
					    draw_block_graph(x * 8, y * 16    , d shr 4);
					    draw_block_graph(x * 8, y * 16 + 8, d and $0f);
             end;
          end;
      end;
		end; //de X
end; //de Y
if (memoria[$3400] and $10)<>0 then begin
  if (((memoria[$3400] and $f7)=$17) and ((memoria[$3402] and $ef)=$4f)) then screen_start_sprite_line:=21+32
    else screen_start_sprite_line:=0;
  for f:=0 to 127 do begin
			spr_y:=memoria[$3200+f*4] and $fe;
			y_32:=(memoria[$3200+f*4] and $01)<>0;       // Xx32 sprite
			clip:=memoria[$3201+f*4] shr 4;
			col:=memoria[$3201+f*4] and $0f;
			spr_x:=memoria[$3202+f*4] and $fe;
			x_32:=(memoria[$3202+f*4] and $01)<>0;       // 32xX sprite
			tile_idx:=memoria[$3203+f*4] and $7f;
			half:=(memoria[$3203+f*4] and $80)<>0;
			left:=true;
			right:=true;
			top:=true;
			bottom:=true;
			if (col=0) then continue;
			if (spr_y=0) then continue;
			if half then begin
				if (tile_idx and $40)<>0 then begin
					if y_32 then begin
						spr_y:=spr_y-8;
						top:=false;
						bottom:=true;
						y_32:=false;
					end else begin
						top:=true;
						bottom:=false;
					end;
				end;
				if x_32 then begin
					spr_x:=spr_x-8;
					left:=false;
					right:=true;
					x_32:=false;
				end else begin
					left:=true;
					right:=false;
				end;
      end; //del half
			// Check if 2 color sprites are enabled
			if (((memoria[$3400] and $20)<>0) and ((f and $20)<>0)) then begin
				// 2 color sprite handling
				draw_sprite(spr_x,spr_y,tile_idx,col,left,right,top,bottom,clip,screen_start_sprite_line);
				if (x_32 or y_32) then begin
          if (f and $40)<>0 then spr_col:=spr_2col_lut1[col]
            else spr_col:=spr_2col_lut0[col];
					draw_sprite(spr_x,spr_y,tile_idx xor (8*byte(x_32)+byte(y_32)),spr_col,left,right,top,bottom,clip,screen_start_sprite_line);
        end;
			end else begin
				// regular sprite handling
				draw_sprite(spr_x,spr_y,tile_idx,col,left,right,top,bottom,clip,screen_start_sprite_line);
				if x_32 then
					draw_sprite(spr_x+16,spr_y,tile_idx or 8,col,true,true,top,bottom,clip,screen_start_sprite_line);
				if y_32 then begin
          if (clip and $08)<>0 then clip:=(clip and $07)
            else clip:=0;
					draw_sprite(spr_x,spr_y+16,tile_idx or 1,col,left,right,true,true,clip,screen_start_sprite_line);
					if x_32 then
						draw_sprite(spr_x+16,spr_y+16,tile_idx or 9,col,true,true,true,true,clip,screen_start_sprite_line);
				end;
			end;
    end; //del for
end;
end;

procedure scv_principal;
var
  frame:single;
  f:word;
begin
init_controls(false,true,true,false);
frame:=upd7810_0.tframes;
while EmuStatus=EsRunning do begin
  for f:=0 to 261 do begin
      upd7810_0.run(frame);
      frame:=frame+upd7810_0.tframes-upd7810_0.contador;
      case f of
        8:upd7810_0.set_input_line_7801(UPD7810_INTF2,CLEAR_LINE);
        239:begin
              update_video_svc;
              upd7810_0.set_input_line_7801(UPD7810_INTF2,ASSERT_LINE);
            end;
      end;
  end;
  actualiza_trozo(24,23,192,222,1,0,0,192,222,2);
  actualiza_trozo_final(0,0,192,222,2);
  eventos_svc;
  video_sync;
end;
end;

function scv_getbyte(direccion:word):byte;
begin
  case direccion of
    0..$fff,$2000..$3403:scv_getbyte:=memoria[direccion];
    $6000..$7fff:if scv_0.ram_bank then scv_getbyte:=memoria[direccion]
                    else scv_getbyte:=$ff;
    $8000..$dfff:scv_getbyte:=scv_0.rom[scv_0.rom_window,direccion and $7fff];
    $e000..$ff7f:if scv_0.ram_bank2 then scv_getbyte:=memoria[direccion]
                    else scv_getbyte:=scv_0.rom[scv_0.rom_window,direccion and $7fff];
    $ff80..$ffff:scv_getbyte:=upd7810_0.ram[direccion and $7f];
  end;
end;

procedure scv_putbyte(direccion:word;valor:byte);
begin
  case direccion of
    0..$fff,$8000..$dfff:;
    $2000..$3403:memoria[direccion]:=valor;
    $3600:upd1771_0.write(valor);
    $6000..$7fff:if scv_0.ram_bank then memoria[direccion]:=valor;
    $e000..$ff7f:if scv_0.ram_bank2 then memoria[direccion]:=valor;
    $ff80..$ffff:upd7810_0.ram[direccion and $7f]:=valor;
  end;
end;

function scv_portb_in(mask:byte):byte;
var
  f,data:byte;
begin
  data:=$ff;
	for f:=0 to 7 do begin
		if not(BIT(scv_0.porta_val,f)) then data:=data and scv_0.keys[f];
	end;
  scv_portb_in:=data;
end;

function scv_portc_in(mask:byte):byte;
var
  data:byte;
begin
  data:=scv_0.portc_val;
	data:=(data and $fe) or scv_0.keys[8];
  scv_portc_in:=data;
end;

procedure scv_porta_out(valor:byte);
begin
  scv_0.porta_val:=valor;
end;

procedure scv_portc_out(valor:byte);
begin
  scv_0.portc_val:=valor;
	upd1771_0.pcm_write(scv_0.portc_val and $08);
  case scv_0.rom_bank_type of
    0:;
    1:scv_0.rom_window:=(valor and $20) shr 5;
    2:scv_0.rom_window:=(valor shr 5) and 3;
  end;
end;

procedure upd1771_ack_w(state:boolean);
begin
  if state then upd7810_0.set_input_line(UPD7810_INTF1,ASSERT_LINE)
    else upd7810_0.set_input_line(UPD7810_INTF1,CLEAR_LINE);
end;

procedure scv_sound_update;
begin
  upd1771_0.update;
end;

//Pole Position II
function polepos2_getbyte(direccion:word):byte;
begin
  case direccion of
    0..$fff,$2000..$3403:polepos2_getbyte:=memoria[direccion];
    $8000..$efff:polepos2_getbyte:=scv_0.rom[scv_0.rom_window,direccion and $7fff];
    $f000..$ff7f:polepos2_getbyte:=memoria[direccion];
    $ff80..$ffff:polepos2_getbyte:=upd7810_0.ram[direccion and $7f];
  end;
end;

procedure polepos2_putbyte(direccion:word;valor:byte);
begin
  case direccion of
    0..$fff,$8000..$efff:;
    $2000..$3403:memoria[direccion]:=valor;
    $3600:upd1771_0.write(valor);
    $f000..$ff7f:memoria[direccion]:=valor;
    $ff80..$ffff:upd7810_0.ram[direccion and $7f]:=valor;
  end;
end;

//Main
procedure reset_scv;
begin
 upd7810_0.reset;
 upd1771_0.reset;
 reset_audio;
 scv_0.porta_val:=$ff;
 scv_0.portc_val:=$ff;
 fillchar(scv_0.keys,9,$ff);
 scv_0.rom_window:=0;
end;

procedure scv_grabar_snapshot;
var
  nombre:string;
begin
nombre:=snapshot_main_write(SSUPERCASSETTE);
directory.scv:=ExtractFilePath(nombre);
end;

procedure abrir_scv;
var
  extension,nombre_file,romfile:string;
  datos,datos2:pbyte;
  longitud,longitud2:integer;
  crc32,crc:dword;
procedure load_rom;
begin
fillchar(scv_0.rom[0],sizeof(scv_0.rom),0);
scv_0.rom_bank_type:=0;
if longitud<=$2000 then begin
    copymemory(@scv_0.rom[0,0],datos,longitud);
    copymemory(@scv_0.rom[0,$2000],datos,longitud);
    copymemory(@scv_0.rom[0,$4000],datos,longitud);
    copymemory(@scv_0.rom[0,$6000],datos,longitud);
  end else if longitud<=$4000 then begin
              copymemory(@scv_0.rom[0,0],@datos[0],$4000);
              copymemory(@scv_0.rom[0,$4000],@datos[$4000],$4000);
           end else if longitud<=$8000 then begin
                        copymemory(@scv_0.rom[0,0],@datos[0],$8000);
                    end else if longitud<=$10000 then begin
                        copymemory(@scv_0.rom[0,0],@datos[0],$8000);
                        copymemory(@scv_0.rom[1,0],@datos[$8000],$8000);
                        scv_0.rom_bank_type:=1;
                    end else if longitud<=$20000 then begin
                        copymemory(@scv_0.rom[0,0],@datos[0],$8000);
                        copymemory(@scv_0.rom[1,0],@datos[$8000],$8000);
                        copymemory(@scv_0.rom[2,0],@datos[$10000],$8000);
                        copymemory(@scv_0.rom[3,0],@datos[$18000],$8000);
                        scv_0.rom_bank_type:=2;
                        end;
reset_scv;
end;
begin
  if not(openrom(romfile,SSUPERCASSETTE)) then exit;
  getmem(datos,$20000);
  if not(extract_data(romfile,datos,longitud,nombre_file,SSUPERCASSETTE)) then begin
    freemem(datos);
    exit;
  end;
  extension:=extension_fichero(nombre_file);
  crc:=calc_crc(datos,longitud);
  //Mapper o extraRAM?
  upd7810_0.change_ram_calls(scv_getbyte,scv_putbyte);
  scv_0.ram_bank:=false;
  scv_0.ram_bank2:=false;
  case crc of
    $5971940f,$84005c4c,$ca965c2b:scv_0.ram_bank2:=true; //Dragon Slayer, Shougi Nyuumon, BASIC Nyuumon
    $cc4fb04d:scv_0.ram_bank:=true; //pop & chips
    $cb69903d,$5b3a04e0:upd7810_0.change_ram_calls(polepos2_getbyte,polepos2_putbyte); //Pole Position II
  end;
  fillchar(memoria[$1000],$f000,0); //Doreamon confia en esto!
  if extension='BIN' then load_rom;
  if extension='DSP' then snapshot_r(datos,longitud,SSUPERCASSETTE);
  if (extension='0') then begin //Tiene dos partes el cartucho?
    getmem(datos2,$20000);
    copymemory(datos2,datos,longitud);
    if extension_fichero(romfile)='ZIP' then begin
        if search_file_from_zip(romfile,'*.1',nombre_file,longitud2,crc,false) then
            if not(load_file_from_zip(romfile,nombre_file,datos,longitud2,crc,true)) then begin
              MessageDlg('Error cargando snapshot/ROM.'+chr(10)+chr(13)+'Error loading the snapshot/ROM.', mtInformation,[mbOk], 0);
              freemem(datos2);
              freemem(datos);
              exit;
            end;
    end;
    crc32:=calc_crc(datos,longitud2);
    case crc32 of
          $d2de91a6:begin //Doraemon
                  copymemory(@datos2[$8000],datos,$8000);
                  freemem(datos);
                  getmem(datos,$10000);
                  longitud:=$10000;
                  copymemory(datos,datos2,longitud);
                end;
          $a895375a:begin //kungfu
                  copymemory(@datos2[$8000],datos2,$6000);
                  copymemory(@datos2[$e000],datos,$2000);
                  freemem(datos);
                  getmem(datos,$20000);
                  longitud:=$10000;
                  copymemory(datos,datos2,longitud);
                end;
          $7978c4a6:begin  //star speeder
                  copymemory(@datos2[$8000],@datos2[0],$8000);
                  copymemory(@datos2[0],@datos[0],$2000);
                  copymemory(@datos2[$2000],datos,$2000);
                  copymemory(@datos2[$4000],datos,$2000);
                  copymemory(@datos2[$6000],datos,$2000);
                  freemem(datos);
                  getmem(datos,$20000);
                  longitud:=$10000;
                  copymemory(datos,datos2,longitud);
                end;
    end;
    load_rom;
    freemem(datos2);
  end;
  freemem(datos);
  change_caption(nombre_file);
  Directory.scv:=ExtractFilePath(romfile);
end;

function iniciar_scv:boolean;
var
  temp:array[0..$13ff] of byte;
  f:byte;
  colores:tpaleta;
begin
iniciar_scv:=false;
principal1.BitBtn10.Glyph:=nil;
principal1.imagelist2.GetBitmap(4,principal1.BitBtn10.Glyph);
principal1.BitBtn10.OnClick:=principal1.fLoadCartucho;
llamadas_maquina.bucle_general:=scv_principal;
llamadas_maquina.reset:=reset_scv;
llamadas_maquina.cartuchos:=abrir_scv;
llamadas_maquina.grabar_snapshot:=scv_grabar_snapshot;
llamadas_maquina.fps_max:=59.922745;
iniciar_audio(false);
screen_init(1,512,512);
screen_init(2,192,222,false,true);
iniciar_video(192,222);
//Main CPU
upd7810_0:=cpu_upd7810.create(4000000,262,CPU_7801);
upd7810_0.change_ram_calls(scv_getbyte,scv_putbyte);
upd7810_0.change_in(nil,scv_portb_in,scv_portc_in,nil,nil);
upd7810_0.change_out(scv_porta_out,nil,scv_portc_out,nil,nil);
upd7810_0.init_sound(scv_sound_update);
//Chip Sonido
upd1771_0:=upd1771_chip.create(6000000,10);
upd1771_0.change_calls(upd1771_ack_w);
//cargar roms
if not(roms_load(@temp,scv_bios)) then exit;
copymemory(@memoria,@temp,$1000);
copymemory(@scv_0.chars,@temp[$1000],$400);
//Pal
for f:=0 to 15 do begin
  colores[f].r:=scv_paleta[f] shr 16;
  colores[f].g:=(scv_paleta[f] shr 8) and $ff;
  colores[f].b:=scv_paleta[f] and $ff;
end;
set_pal(colores,$10);
//final
reset_scv;
if main_vars.console_init then abrir_scv;
iniciar_scv:=true;
end;

end.
