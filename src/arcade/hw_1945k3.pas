unit hw_1945k3;
interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m68000,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     oki6295,sound_engine;

function iniciar_k31945:boolean;

implementation
const
        k31945_rom:array[0..1] of tipo_roms=(
        (n:'prg-1.u51';l:$80000;p:1;crc:$6b345f27),(n:'prg-2.u52';l:$80000;p:$0;crc:$ce09b98c));
        k31945_sprites:array[0..1] of tipo_roms=(
        (n:'m16m-1.u62';l:$200000;p:0;crc:$0b9a6474),(n:'m16m-2.u63';l:$200000;p:2;crc:$368a8c2e));
        k31945_tiles:tipo_roms=(n:'m16m-3.u61';l:$200000;p:0;crc:$32fc80dd);
        k31945_oki1:tipo_roms=(n:'snd-1.su7';l:$80000;p:0;crc:$bbb7f0ff);
        k31945_oki2:tipo_roms=(n:'snd-2.su4';l:$80000;p:0;crc:$47e3952e);
        k31945_dip_a:array [0..5] of def_dip=(
        (mask:$7;name:'Coinage';number:8;dip:((dip_val:$2;dip_name:'5C 1C'),(dip_val:$1;dip_name:'4C 1C'),(dip_val:$5;dip_name:'3C 1C'),(dip_val:$6;dip_name:'2C 1C'),(dip_val:$7;dip_name:'1C 1C'),(dip_val:$4;dip_name:'1C 2C'),(dip_val:$0;dip_name:'1C 3C'),(dip_val:$3;dip_name:'Free Play'),(),(),(),(),(),(),(),())),
        (mask:$18;name:'Difficulty';number:4;dip:((dip_val:$0;dip_name:'Easy'),(dip_val:$8;dip_name:'Normal'),(dip_val:$10;dip_name:'Hard'),(dip_val:$18;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$60;name:'Lives';number:4;dip:((dip_val:$40;dip_name:'2'),(dip_val:$60;dip_name:'3'),(dip_val:$20;dip_name:'4'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$100;name:'Demo Sounds';number:2;dip:((dip_val:$100;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$200;name:'Allow Continue';number:2;dip:((dip_val:$0;dip_name:'No'),(dip_val:$200;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        flagrall_rom:array[0..1] of tipo_roms=(
        (n:'11_u34.bin';l:$40000;p:1;crc:$24dd439d),(n:'12_u35.bin';l:$40000;p:$0;crc:$373b71a5));
        flagrall_sprites:array[0..7] of tipo_roms=(
        (n:'1_u5.bin';l:$80000;p:0;crc:$9377704b),(n:'5_u6.bin';l:$80000;p:1;crc:$1ac0bd0c),
        (n:'2_u7.bin';l:$80000;p:2;crc:$5f6db2b3),(n:'6_u8.bin';l:$80000;p:3;crc:$79e4643c),
        (n:'3_u58.bin';l:$40000;p:$200000;crc:$c913df7d),(n:'4_u59.bin';l:$40000;p:$200001;crc:$cb192384),
        (n:'7_u60.bin';l:$40000;p:$200002;crc:$f187a7bf),(n:'8_u61.bin';l:$40000;p:$200003;crc:$b73fa441));
        flagrall_tiles:array[0..1] of tipo_roms=(
        (n:'10_u102.bin';l:$80000;p:0;crc:$b1fd3279),(n:'9_u103.bin';l:$80000;p:$80000;crc:$01e6d654));
        flagrall_oki:array[0..1] of tipo_roms=(
        (n:'13_su4.bin';l:$80000;p:0;crc:$7b0630b3),(n:'14_su6.bin';l:$40000;p:$80000;crc:$593b038f));
        flagrall_dip_a:array [0..8] of def_dip=(
        (mask:$3;name:'Coinage';number:4;dip:((dip_val:$0;dip_name:'3C 1C'),(dip_val:$1;dip_name:'2C 1C'),(dip_val:$3;dip_name:'1C 1C'),(dip_val:$2;dip_name:'1C 2C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Demo Sounds';number:2;dip:((dip_val:$10;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Dip Control';number:2;dip:((dip_val:$20;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Picture Test';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$300;name:'Lives';number:4;dip:((dip_val:$200;dip_name:'1'),(dip_val:$100;dip_name:'2'),(dip_val:$300;dip_name:'3'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$400;name:'Bonus Type';number:2;dip:((dip_val:$400;dip_name:'0'),(dip_val:$0;dip_name:'1'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$3000;name:'Difficulty';number:4;dip:((dip_val:$2000;dip_name:'Easy'),(dip_val:$3000;dip_name:'Normal'),(dip_val:$1000;dip_name:'Hard'),(dip_val:$0;dip_name:'Very Hard'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8000;name:'Free Play';number:2;dip:((dip_val:$8000;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 rom:array[0..$7ffff] of word;
 ram1,ram2:array[0..$7fff] of word;
 video,video_buffer:array[0..$7ff] of word;
 sprite,sprite_buffer:array[0..$fff] of word;
 oki1_rom,oki2_rom:array[0..3,0..$3ffff] of byte;
 y_size,oki1_bank,oki2_bank:byte;
 sprites_count,y_count,char_mask,sprite_mask,t1scroll_x,t1scroll_y:word;
 vram_refresh:boolean;

procedure update_video_k31945;
procedure put_gfx_sprite_1945(nchar:dword;ngfx:byte;flick:boolean);
var
  x,y,pos_y,ptemp:byte;
  temp,temp2:pword;
  pos:pbyte;
begin
pos:=gfx[ngfx].datos;
inc(pos,nchar*16*16);
pos_y:=0;
temp2:=punbuf;
for y:=0 to 15 do begin
  temp:=temp2;
  for x:=0 to 15 do begin
    if not(gfx[ngfx].trans[pos^]) then begin
      if flick then ptemp:=$ff
        else ptemp:=pos^;
      temp^:=paleta[gfx[ngfx].colores[ptemp+$100]];
    end else temp^:=paleta[MAX_COLORES];
    inc(temp);
    inc(pos);
  end;
  putpixel_gfx_int(0,pos_y,16,PANT_SPRITES);
  pos_y:=pos_y+1;
end;
end;
var
  f,nchar,x,y:word;
begin
for f:=0 to $3ff do begin
  if gfx[0].buffer[f] then begin
    x:=f mod 32;
    y:=f div 32;
    nchar:=video_buffer[f] and char_mask;
    put_gfx(x*16,y*16,nchar,0,1,0);
    gfx[0].buffer[f]:=false;
  end;
end;
scroll_x_y(1,2,t1scroll_x,t1scroll_y);
for f:=0 to sprites_count do begin
  x:=((sprite_buffer[f] and $ff00) shr 8) or ((sprite_buffer[f+$7ff] and $1) shl 8);
  y:=sprite_buffer[f] and $ff;
  nchar:=(sprite_buffer[$7ff+f] and $7ffe) shr 1;
  put_gfx_sprite_1945(nchar and sprite_mask,1,(sprite_buffer[f+$7ff] and $8000)<>0);
  actualiza_gfx_sprite(x,y,2,1);
end;
actualiza_trozo_final(0,0,320,y_size,2);
end;

procedure eventos_k31945;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fffe) else marcade.in0:=(marcade.in0 or $0001);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fffd) else marcade.in0:=(marcade.in0 or $0002);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fffb) else marcade.in0:=(marcade.in0 or $0004);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fff7) else marcade.in0:=(marcade.in0 or $0008);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ffef) else marcade.in0:=(marcade.in0 or $0010);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $ffdf) else marcade.in0:=(marcade.in0 or $0020);
  if arcade_input.but2[0] then marcade.in0:=(marcade.in0 and $ffbf) else marcade.in0:=(marcade.in0 or $0040);
  if arcade_input.but3[0] then marcade.in0:=(marcade.in0 and $ff7f) else marcade.in0:=(marcade.in0 or $0080);
  //P2
  if arcade_input.up[1] then marcade.in0:=(marcade.in0 and $feff) else marcade.in0:=(marcade.in0 or $0100);
  if arcade_input.down[1] then marcade.in0:=(marcade.in0 and $fdff) else marcade.in0:=(marcade.in0 or $0200);
  if arcade_input.left[1] then marcade.in0:=(marcade.in0 and $fbff) else marcade.in0:=(marcade.in0 or $0400);
  if arcade_input.right[1] then marcade.in0:=(marcade.in0 and $f7ff) else marcade.in0:=(marcade.in0 or $0800);
  if arcade_input.but0[1] then marcade.in0:=(marcade.in0 and $efff) else marcade.in0:=(marcade.in0 or $1000);
  if arcade_input.but1[1] then marcade.in0:=(marcade.in0 and $dfff) else marcade.in0:=(marcade.in0 or $2000);
  if arcade_input.but2[1] then marcade.in0:=(marcade.in0 and $bfff) else marcade.in0:=(marcade.in0 or $4000);
  if arcade_input.but3[1] then marcade.in0:=(marcade.in0 and $7fff) else marcade.in0:=(marcade.in0 or $8000);
  //SYS
  if arcade_input.coin[0] then marcade.in1:=(marcade.in1 and $fffe) else marcade.in1:=(marcade.in1 or $0001);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $fffb) else marcade.in1:=(marcade.in1 or $0004);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $fff7) else marcade.in1:=(marcade.in1 or $0008);
end;
end;

procedure k31945_principal;
var
  frame:single;
  f:word;
begin
init_controls(false,false,false,true);
frame:=m68000_0.tframes;
while EmuStatus=EsRunning do begin
 for f:=0 to y_count do begin
   m68000_0.run(frame);
   frame:=frame+m68000_0.tframes-m68000_0.contador;
   if f=y_size then begin
      m68000_0.irq[4]:=HOLD_LINE;
      update_video_k31945;
   end;
 end;
 eventos_k31945;
 video_sync;
end;
end;

procedure cambiar_color(tmp_color,numero:word);
var
  color:tcolor;
begin
  color.b:=pal5bit(tmp_color shr 10);
  color.g:=pal5bit(tmp_color shr 5);
  color.r:=pal5bit(tmp_color);
  set_pal_color(color,numero);
end;

procedure vram_buffer(newval:boolean);
var
  oldval:boolean;
begin
  oldval:=vram_refresh;
	if (not(oldval) and newval) then begin
    copymemory(@sprite_buffer,@sprite,$1000*2);
    copymemory(@video_buffer,@video,$400*2);
    fillchar(gfx[0].buffer,$400,1);
  end;
	vram_refresh:=newval;
end;

function k31945_getword(direccion:dword):word;
begin
case direccion of
  $0..$fffff:k31945_getword:=rom[direccion shr 1];
  $100000..$10ffff:k31945_getword:=ram1[(direccion and $ffff) shr 1];
  $200000..$2003ff:k31945_getword:=buffer_paleta[(direccion and $3ff) shr 1];
  $240000..$240fff:k31945_getword:=sprite[(direccion and $fff) shr 1];
  $280000..$280fff:k31945_getword:=sprite[$7ff+((direccion and $fff) shr 1)];
  $2c0000..$2c0fff:k31945_getword:=video[(direccion and $fff) shr 1];
  $400000:k31945_getword:=marcade.in0;
  $440000:k31945_getword:=marcade.in1;
  $480000:k31945_getword:=marcade.dswa;
  $4c0000:k31945_getword:=oki_6295_0.read shl 8;
  $500000:k31945_getword:=oki_6295_1.read shl 8;
  $8c0000..$8cffff:k31945_getword:=ram2[(direccion and $ffff) shr 1];
end;
end;

procedure k31945_putword(direccion:dword;valor:word);
begin
case direccion of
  0..$fffff:; //ROM
  $100000..$10ffff:ram1[(direccion and $ffff) shr 1]:=valor;
  $200000..$2003ff:if (buffer_paleta[(direccion and $3ff) shr 1]<>valor) then begin
                      buffer_paleta[(direccion and $3ff) shr 1]:=valor;
                      cambiar_color(valor,(direccion and $3ff) shr 1);
                   end;
  $240000..$240fff:sprite[(direccion and $fff) shr 1]:=valor;
  $280000..$280fff:sprite[$7ff+((direccion and $fff) shr 1)]:=valor;
  $2c0000..$2c0fff:if video[(direccion and $fff) shr 1]<>valor then begin
                      video[(direccion and $fff) shr 1]:=valor;
                      gfx[0].buffer[(direccion and $fff) shr 1]:=true;
                   end;
  $340000:t1scroll_x:=valor;
  $380000:t1scroll_y:=valor;
  $3c0000:begin
            if oki1_bank<>(valor and 2) then begin
              oki1_bank:=valor and 2;
              copymemory(oki_6295_0.get_rom_addr,@oki1_rom[oki1_bank shr 1,0],$40000);
            end;
            if oki2_bank<>(valor and 4) then begin
              oki2_bank:=valor and 4;
              copymemory(oki_6295_1.get_rom_addr,@oki2_rom[oki2_bank shr 2,0],$40000);
            end;
            vram_buffer((valor and 1)<>0);
          end;
  $4c0000:oki_6295_0.write(valor shr 8);
  $500000:oki_6295_1.write(valor shr 8);
  $8c0000..$8cffff:ram2[(direccion and $ffff) shr 1]:=valor;
end;
end;

procedure k31945_sound_update;
begin
  oki_6295_0.update;
  oki_6295_1.update;
end;

function flagrall_getword(direccion:dword):word;
begin
case direccion of
  $0..$fffff:flagrall_getword:=rom[direccion shr 1];
  $100000..$10ffff:flagrall_getword:=ram1[(direccion and $ffff) shr 1];
  $200000..$2003ff:flagrall_getword:=buffer_paleta[(direccion and $3ff) shr 1];
  $240000..$240fff:flagrall_getword:=sprite[(direccion and $fff) shr 1];
  $280000..$280fff:flagrall_getword:=sprite[$7ff+((direccion and $fff) shr 1)];
  $2c0000..$2c0fff:flagrall_getword:=video[(direccion and $fff) shr 1];
  $400000:flagrall_getword:=marcade.in0;
  $440000:flagrall_getword:=marcade.in1;
  $480000:flagrall_getword:=marcade.dswa;
  $4c0000:flagrall_getword:=oki_6295_0.read;
end;
end;

procedure flagrall_putword(direccion:dword;valor:word);
begin
case direccion of
  0..$fffff:; //ROM
  $100000..$10ffff:ram1[(direccion and $ffff) shr 1]:=valor;
  $200000..$2003ff:if (buffer_paleta[(direccion and $3ff) shr 1]<>valor) then begin
                      buffer_paleta[(direccion and $3ff) shr 1]:=valor;
                      cambiar_color(valor,(direccion and $3ff) shr 1);
                   end;
  $240000..$240fff:sprite[(direccion and $fff) shr 1]:=valor;
  $280000..$280fff:sprite[$7ff+((direccion and $fff) shr 1)]:=valor;
  $2c0000..$2c0fff:if video[(direccion and $fff) shr 1]<>valor then begin
                      video[(direccion and $fff) shr 1]:=valor;
                      gfx[0].buffer[(direccion and $fff) shr 1]:=true;
                   end;
  $340000:t1scroll_x:=valor;
  $380000:t1scroll_y:=valor;
  $3c0000:begin
            if oki1_bank<>(valor and 6) then begin
              oki1_bank:=valor and 6;
              copymemory(oki_6295_0.get_rom_addr,@oki1_rom[oki1_bank shr 1,0],$40000);
            end;
            vram_buffer((valor and $20)=0);
          end;
  $4c0000:oki_6295_0.write(valor);
end;
end;

procedure flagrall_sound_update;
begin
  oki_6295_0.update;
end;

//Main
procedure reset_k31945;
begin
 m68000_0.reset;
 oki_6295_0.reset;
 if main_vars.tipo_maquina=283 then oki_6295_1.reset;
 reset_audio;
 oki1_bank:=0;
 oki2_bank:=0;
 t1scroll_x:=0;
 t1scroll_y:=0;
 marcade.in0:=$ffff;
 marcade.in1:=$ffff;
 vram_refresh:=false;
end;

function iniciar_k31945:boolean;
const
  pt_x:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
   8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8);
  pt_y:array[0..15] of dword=(0*128, 1*128, 2*128, 3*128, 4*128, 5*128, 6*128, 7*128,
   8*128, 9*128,10*128,11*128,12*128,13*128,14*128,15*128);
var
  memoria_temp:pbyte;
procedure convert_gfx1(gfx_num:byte;num:word);
begin
  init_gfx(gfx_num,16,16,num);
  gfx_set_desc_data(8,0,128*16,0,1,2,3,4,5,6,7);
  convert_gfx(gfx_num,0,memoria_temp,@pt_x,@pt_y,false,false);
end;
begin
iniciar_k31945:=false;
llamadas_maquina.bucle_general:=k31945_principal;
llamadas_maquina.iniciar:=iniciar_k31945;
llamadas_maquina.reset:=reset_k31945;
iniciar_audio(false);
screen_init(1,512,512);
screen_mod_scroll(1,512,512,511,512,512,511);
screen_init(2,512,512,false,true);
screen_mod_sprites(2,512,256,511,255);
if main_vars.tipo_maquina=283 then begin
  main_screen.rot270_screen:=true;
  y_size:=224;
  llamadas_maquina.fps_max:=59.637405;
end else begin
  y_size:=240;
  llamadas_maquina.fps_max:=49.603176;
end;
iniciar_video(320,y_size);
//mem aux
getmem(memoria_temp,$400000);
case main_vars.tipo_maquina of
  283:begin //1945k III
        //Main CPU
        m68000_0:=cpu_m68000.create(16000000,262);
        m68000_0.change_ram16_calls(k31945_getword,k31945_putword);
        m68000_0.init_sound(k31945_sound_update);
        if not(roms_load16w(@rom,k31945_rom)) then exit;
        //OKI1
        oki_6295_0:=snd_okim6295.Create(1000000,OKIM6295_PIN7_HIGH);
        if not(roms_load(memoria_temp,k31945_oki1)) then exit;
        copymemory(oki_6295_0.get_rom_addr,memoria_temp,$40000);
        copymemory(@oki1_rom[0,0],memoria_temp,$40000);
        copymemory(@oki1_rom[1,0],@memoria_temp[$40000],$40000);
        //OKI2
        oki_6295_1:=snd_okim6295.Create(1000000,OKIM6295_PIN7_HIGH);
        if not(roms_load(memoria_temp,k31945_oki2)) then exit;
        copymemory(oki_6295_1.get_rom_addr,memoria_temp,$40000);
        copymemory(@oki2_rom[0,0],memoria_temp,$40000);
        copymemory(@oki2_rom[1,0],@memoria_temp[$40000],$40000);
        char_mask:=$1fff;
        sprite_mask:=$3fff;
        //x_size=432 y_size=262, total sprites=432*262/(4+128)
        y_count:=262-1;
        sprites_count:=round((432*262)/(4+128))-1;
        //tiles
        if not(roms_load(memoria_temp,k31945_tiles)) then exit;
        convert_gfx1(0,$2000);
        //sprites
        fillchar(memoria_temp^,$400000,0);
        if not(roms_load32b(memoria_temp,k31945_sprites)) then exit;
        convert_gfx1(1,$4000);
        gfx[1].trans[0]:=true;
        //Dip
        marcade.dswa:=$feef;
        marcade.dswa_val:=@k31945_dip_a;
      end;
  284:begin //96 flag rally
        //Main CPU
        m68000_0:=cpu_m68000.create(16000000,315);
        m68000_0.change_ram16_calls(flagrall_getword,flagrall_putword);
        m68000_0.init_sound(flagrall_sound_update);
        if not(roms_load16w(@rom,flagrall_rom)) then exit;
        //OKI
        oki_6295_0:=snd_okim6295.Create(1000000,OKIM6295_PIN7_HIGH);
        if not(roms_load(memoria_temp,flagrall_oki)) then exit;
        copymemory(oki_6295_0.get_rom_addr,memoria_temp,$40000);
        copymemory(@oki1_rom[0,0],memoria_temp,$40000);
        copymemory(@oki1_rom[1,0],@memoria_temp[$40000],$40000);
        copymemory(@oki1_rom[2,0],@memoria_temp[$80000],$40000);
        char_mask:=$fff;
        sprite_mask:=$3fff;
        //x_size=432 y_size=315
        y_count:=315-1;
        sprites_count:=round((432*315)/(4+128))-1;
        //tiles
        if not(roms_load(memoria_temp,flagrall_tiles)) then exit;
        convert_gfx1(0,$1000);
        //sprites
        fillchar(memoria_temp^,$400000,0);
        if not(roms_load32b_b(memoria_temp,flagrall_sprites)) then exit;
        convert_gfx1(1,$4000); //Son $3000, pero pongo $4000 por la mascara
        gfx[1].trans[0]:=true;
        //Dip
        marcade.dswa:=$ffef;
        marcade.dswa_val:=@flagrall_dip_a;
      end;
end;
//final
freemem(memoria_temp);
reset_k31945;
iniciar_k31945:=true;
end;

end.
