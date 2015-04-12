unit combatschool_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     hd6309,nz80,main_engine,controls_engine,gfx_engine,
     rom_engine,pal_engine,konami_video,ym_2203,upd7759,sound_engine;

procedure Cargar_combatsc;
procedure combatsc_principal;
function iniciar_combatsc:boolean;
procedure reset_combatsc;
procedure cerrar_combatsc;
//Main CPU
function combatsc_getbyte(direccion:word):byte;
procedure combatsc_putbyte(direccion:word;valor:byte);
//Sound CPU
function sound_getbyte(direccion:word):byte;
procedure sound_putbyte(direccion:word;valor:byte);
procedure combatsc_sound_update;

const
        combatsc_rom:array[0..2] of tipo_roms=(
        (n:'611g01.rom';l:$10000;p:$0;crc:$857ffffe),(n:'611g02.rom';l:$20000;p:$10000;crc:$9ba05327),());
        combatsc_proms:array[0..4] of tipo_roms=(
        (n:'611g06.h14';l:$100;p:0;crc:$f916129a),(n:'611g05.h15';l:$100;p:$100;crc:$207a7b07),
        (n:'611g10.h6';l:$100;p:$200;crc:$f916129a),(n:'611g09.h7';l:$100;p:$300;crc:$207a7b07),());
        combatsc_chars:array[0..2] of tipo_roms=(
        (n:'611g07.rom';l:$40000;p:0;crc:$73b38720),(n:'611g08.rom';l:$40000;p:$1;crc:$46e7d28c),());
        combatsc_chars2:array[0..2] of tipo_roms=(
        (n:'611g11.rom';l:$40000;p:0;crc:$69687538),(n:'611g12.rom';l:$40000;p:$1;crc:$9c6bf898),());
        combatsc_sound:tipo_roms=(n:'611g03.rom';l:$8000;p:$0;crc:$2a544db5);
        combatsc_upd:tipo_roms=(n:'611g04.rom';l:$20000;p:0;crc:$2987e158);

var
 memoria_rom:array[0..9,0..$3FFF] of byte;
 video_circuit,bank_rom,prot_0,prot_1,vreg,priority,sound_latch:byte;
 page_ram:array[0..1,0..$1fff] of byte;
 scroll_ram:array[0..1,0..$3f] of byte;

implementation
//uses principal,sysutils;

procedure Cargar_combatsc;
begin
llamadas_maquina.iniciar:=iniciar_combatsc;
llamadas_maquina.bucle_general:=combatsc_principal;
llamadas_maquina.cerrar:=cerrar_combatsc;
llamadas_maquina.reset:=reset_combatsc;
end;

function iniciar_combatsc:boolean;
var
  f:word;
  memoria_temp:array[0..$7ffff] of byte;
const
    pc_x:array[0..7] of dword=(0, 4, 8, 12, 16, 20, 24, 28);
    pc_y:array[0..7] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32);
procedure clut_combatsc;
var
  chip,pal,i,ctabentry,clut:byte;
begin
for chip:=0 to 1 do begin
		for pal:=0 to 7 do begin
			clut:=(chip shl 1) or (pal and 1);
			for i:=0 to $ff do begin
				if (((pal and $01)=0) and (memoria_temp[(clut shl 8) or i]=0)) then ctabentry:=0
				  else ctabentry:=(pal shl 4) or (memoria_temp[(clut shl 8) or i] and $0f);
        gfx[chip].colores[(pal shl 8) or i]:=ctabentry;
			end;
		end;
end;
end;
begin
iniciar_combatsc:=false;
iniciar_audio(false);
//Pantallas
screen_init(1,256,256,true);
screen_mod_scroll(1,256,256,255,256,256,255);
screen_init(2,256,256,true);
screen_mod_scroll(2,256,256,255,256,256,255);
screen_init(5,512,256,false,true); //Final
screen_init(6,256,256,true); //Text
screen_mod_scroll(6,256,256,255,256,256,255);
iniciar_video(256,224);
//iniciar_video(256,256);
//Main CPU
main_hd6309:=cpu_hd6309.create(12000000,$100);
main_hd6309.change_ram_calls(combatsc_getbyte,combatsc_putbyte);
//Sound CPU
snd_z80:=cpu_z80.create(3579545,$100);
snd_z80.change_ram_calls(sound_getbyte,sound_putbyte);
snd_z80.init_sound(combatsc_sound_update);
//Audio chips
ym2203_0:=ym2203_chip.create(0,3000000,4);
upd7759_0:=upd7759_chip.create(640000,2);
if not(cargar_roms(upd7759_0.get_rom_addr,@combatsc_upd,'combatsc.zip')) then exit;
//cargar roms
if not(cargar_roms(@memoria_temp[0],@combatsc_rom[0],'combatsc.zip',0)) then exit;
//Pongo las ROMs en su banco
copymemory(@memoria[$8000],@memoria_temp[$8000],$8000);
for f:=0 to 7 do copymemory(@memoria_rom[f,0],@memoria_temp[$10000+(f*$4000)],$4000);
for f:=0 to 1 do copymemory(@memoria_rom[8+f,0],@memoria_temp[0+(f*$4000)],$4000);
//Cargar Sound
if not(cargar_roms(@mem_snd[0],@combatsc_sound,'combatsc.zip',1)) then exit;
//convertir chars
if not(cargar_roms16b(@memoria_temp[0],@combatsc_chars[0],'combatsc.zip',0)) then exit;
init_gfx(0,8,8,$4000);
gfx[0].trans[0]:=true;
gfx_set_desc_data(4,0,32*8,0,1,2,3);
convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,false);
//chars 2
if not(cargar_roms16b(@memoria_temp[0],@combatsc_chars2[0],'combatsc.zip',0)) then exit;
init_gfx(1,8,8,$4000);
gfx[1].trans[0]:=true;
convert_gfx(1,0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,false);
//Color lookup
if not(cargar_roms(@memoria_temp[0],@combatsc_proms,'combatsc.zip',0)) then exit;
clut_combatsc;
reset_combatsc;
iniciar_combatsc:=true;
end;

procedure cerrar_combatsc;
begin
main_hd6309.free;
snd_z80.free;
ym2203_0.free;
upd7759_0.Free;
close_audio;
close_video;
end;

procedure reset_combatsc;
begin
 main_hd6309.reset;
 snd_z80.reset;
 reset_audio;
 ym2203_0.reset;
 upd7759_0.reset;
 K007121_reset(0);
 K007121_reset(1);
 marcade.in0:=$FF;
 marcade.in1:=$5F;
 marcade.in2:=$ff;
 video_circuit:=0;
 bank_rom:=0;
 prot_0:=0;
 prot_1:=0;
 vreg:=0;
 priority:=0;
 sound_latch:=0;
end;

procedure draw_sprites(bank:byte);inline;
var
  color_base:word;
begin
  color_base:=(bank*4)*16+(K007121_chip[bank].control[$06] and $10)*2;
  K007121_draw_sprites(bank,5,0,color_base,false);
end;

procedure update_video_combatsc;
var
  x,y,f,nchar,color:word;
  atrib:byte;
  bank:integer;
  flip_x:boolean;
begin
for f:=$0 to $3ff do begin
    y:=f div 32;
    x:=f mod 32;
    //background
    atrib:=page_ram[0,f];
    color:=atrib and $f;
    if (gfx[0].buffer[$400+f] or buffer_color[color]) then begin
      color:=color+((K007121_chip[0].control[$06] and $10)*2)+$10;
      bank:=4*((vreg and $0f)-1);
      if (bank<0) then bank:=0;
	    if (atrib and $b0)=0 then bank:=0;
	    if (atrib and $80)<>0 then bank:=bank+1;
	    if (atrib and $10)<>0 then bank:=bank+2;
	    if (atrib and $20)<>0 then bank:=bank+4;
      nchar:=page_ram[0,$400+f]+bank*256;
      if priority=0 then put_gfx_trans_flip(x*8,y*8,nchar,color shl 4,1,0,flip_x,false)
        else put_gfx(x*8,y*8,nchar,color shl 4,1,0);
      gfx[0].buffer[$400+f]:=false;
    end;
    //foreground
    atrib:=page_ram[1,f];
    color:=atrib and $f;
    if (gfx[1].buffer[f] or buffer_color[color]) then begin
      color:=color+((K007121_chip[1].control[$6] and $10)*2)+$50;
      bank:=4*((vreg shr 4)-1);
      if (bank<0) then bank:=0;
	    if (atrib and $b0)=0 then bank:=0;
	    if (atrib and $80)<>0 then bank:=bank+1;
	    if (atrib and $10)<>0 then bank:=bank+2;
	    if (atrib and $20)<>0 then bank:=bank+4;
      flip_x:=false;//(atrib and $40)<>0;
      nchar:=page_ram[1,$400+f]+bank*256;
      if priority=0 then put_gfx_flip(x*8,y*8,nchar,color shl 4,2,1,flip_x,false)
        else put_gfx_trans_flip(x*8,y*8,nchar,color shl 4,2,1,flip_x,false);
      gfx[1].buffer[f]:=false;
    end;
    //text
    atrib:=page_ram[0,$800+f];
    color:=atrib and $f;
    if (gfx[0].buffer[f] or buffer_color[color]) then begin
      nchar:=page_ram[0,$c00+f];
      put_gfx_trans(x*8,y*8,nchar,(color+$10) shl 4,6,0);
      gfx[0].buffer[f]:=false;
    end;
end;
if priority=0 then begin
  if (K007121_chip[1].control[1] and 2)<>0 then for f:=0 to 31 do scroll__x_part(2,5,scroll_ram[1,f],0,f*8,8)
    else scroll_x_y(2,5,K007121_chip[1].control[0] or ((K007121_chip[1].control[1] and 1) shl 8),K007121_chip[1].control[2]);
  draw_sprites(0);
  if (K007121_chip[0].control[1] and 2)<>0 then for f:=0 to 31 do scroll__x_part(1,5,scroll_ram[0,f],0,f*8,8)
    else scroll_x_y(1,5,K007121_chip[0].control[0] or ((K007121_chip[0].control[1] and 1) shl 8),K007121_chip[0].control[2]);
  draw_sprites(1);
end else begin
  if (K007121_chip[0].control[1] and 2)<>0 then for f:=0 to 31 do scroll__x_part(1,5,scroll_ram[0,f],0,f*8,8)
    else scroll_x_y(1,5,K007121_chip[0].control[0] or ((K007121_chip[0].control[1] and 1) shl 8),K007121_chip[0].control[2]);
  draw_sprites(1);
  if (K007121_chip[1].control[1] and 2)<>0 then for f:=0 to 31 do scroll__x_part(2,5,scroll_ram[1,f],0,f*8,8)
    else scroll_x_y(2,5,K007121_chip[1].control[0] or ((K007121_chip[1].control[1] and 1) shl 8),K007121_chip[1].control[2]);
  draw_sprites(0);
end;
{f:=K007121_chip[0].control[0] or ((K007121_chip[0].control[1] and 1) shl 8);
atrib:=K007121_chip[0].control[2];
form1.statusbar1.panels[2].text:=inttostr(f)+' '+inttostr(atrib);
//scroll_x_y(1,5,f,atrib);
actualiza_trozo(0,0,256,256,1,0,0,256,256,5);}
//Text
if (K007121_chip[0].control[$1] and 8)<>0 then for f:=0 to 31 do scroll__x_part(6,5,scroll_ram[0,32+f],0,f*8,8);
//Crop
if (K007121_chip[0].control[$3] and $40)<>0 then begin
  for f:=0 to $1f do begin
    put_gfx_block(64,64+(f*8),5,8,8,$300);
    put_gfx_block(248+64,64+(f*8),5,8,8,$300);
  end;
end;
actualiza_trozo_final(0,16,256,224,5);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
//actualiza_trozo_final(0,0,256,256,5);
end;

procedure eventos_combatsc;
begin
if event.arcade then begin
  //marcade.in0
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  //marcade.in1
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
  //dsw3
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
end;
end;

procedure combatsc_principal;
var
  f:byte;
  frame_m,frame_s:single;
begin
init_controls(false,false,false,true);
frame_m:=main_hd6309.tframes;
frame_s:=snd_z80.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
    //Main CPU
    main_hd6309.run(frame_m);
    frame_m:=frame_m+main_hd6309.tframes-main_hd6309.contador;
    //Sound CPU
    snd_z80.run(frame_s);
    frame_s:=frame_s+snd_z80.tframes-snd_z80.contador;
    if f=239 then begin
        main_hd6309.pedir_irq:=HOLD_LINE;
        update_video_combatsc;
    end;
  end;
  eventos_combatsc;
  video_sync;
end;
end;

function combatsc_getbyte(direccion:word):byte;
begin
    case direccion of
        $20..$5f:combatsc_getbyte:=scroll_ram[video_circuit,direccion-$20];
        $200:combatsc_getbyte:=(prot_0*prot_1) and $ff;
        $201:combatsc_getbyte:=((prot_0*prot_1) shr 8) and $ff;
        $400:combatsc_getbyte:=marcade.in0;  //marcade.in0
        $401:combatsc_getbyte:=marcade.in2;  //dsw3
        $402:combatsc_getbyte:=$ff;
        $403:combatsc_getbyte:=$7b;
        $404:combatsc_getbyte:=marcade.in1;  //marcade.in1
        $2000..$3fff:combatsc_getbyte:=page_ram[video_circuit,direccion and $1fff];
        $4000..$7fff:combatsc_getbyte:=memoria_rom[bank_rom,direccion and $3fff];
    else combatsc_getbyte:=memoria[direccion];
    end;
end;

procedure cambiar_color(dir:word);inline;
var
  data:word;
  color:tcolor;
begin
  data:=buffer_paleta[dir]+(buffer_paleta[1+dir] shl 8);
  color.r:=pal5bit(data);
  color.g:=pal5bit(data shr 5);
  color.b:=pal5bit(data shr 10);
  dir:=dir shr 1;
  set_pal_color(color,@paleta[dir]);
  buffer_color[dir shl 4]:=true;
end;

procedure combatsc_putbyte(direccion:word;valor:byte);
begin
if direccion>$3fff then exit;
memoria[direccion]:=valor;
case direccion of
  $0..$7:begin
            K007121_chip[video_circuit].control[direccion]:=valor;
            case direccion of
              3:if (valor and $08)<>0 then copymemory(@K007121_chip[video_circuit].sprite_ram[0],@page_ram[video_circuit,$1000],$800)
                  else copymemory(@K007121_chip[video_circuit].sprite_ram[0],@page_ram[video_circuit,$1800],$800);
              6:if video_circuit=0 then fillchar(gfx[0].buffer[$400],$400,1)
                    else fillchar(gfx[1].buffer[0],$400,1);
              7:;//Flip BG!!!
            end;
         end;
  $20..$5f:scroll_ram[video_circuit,direccion-$20]:=valor;
  $200:prot_0:=valor;
  $201:prot_1:=valor;
  $40c:vreg:=valor;
  $410:begin
        priority:=(valor and $20) shr 5;
        video_circuit:=(valor and $40) shr 6;
	      if (valor and $10)<>0 then bank_rom:=(valor and $0e) shr 1
          else bank_rom:=8+(valor and 1);
       end;
  $414:sound_latch:=valor;
  $418:snd_z80.pedir_irq:=HOLD_LINE;
  $600..$6ff:if buffer_paleta[direccion and $ff]<>valor then begin
        buffer_paleta[direccion and $ff]:=valor;
        cambiar_color(direccion and $fe);
       end;
  $2000..$3fff:begin
        page_ram[video_circuit,direccion and $1fff]:=valor;
        {if ((video_circuit=0) and (direccion=$240d)) then begin
          video_circuit:=valor;
          video_circuit:=0;
        end;
        if ((video_circuit=1) and (direccion=$240d)) then begin
          video_circuit:=valor;
          video_circuit:=1;
        end;}
        if video_circuit=0 then begin
          case direccion and $1fff of
            0..$7ff:gfx[0].buffer[$400+(direccion and $3ff)]:=true;
            $800..$fff:gfx[0].buffer[direccion and $3ff]:=true;
          end;
        end else begin
          case direccion and $1fff of
            0..$7ff:gfx[1].buffer[direccion and $3ff]:=true;
          end;
        end;
       end;
end;
end;

function sound_getbyte(direccion:word):byte;
begin
case direccion of
  $b000:sound_getbyte:=upd7759_0.busy_r;
  $d000:sound_getbyte:=sound_latch;
  $e000:sound_getbyte:=ym2203_0.read_status;
  else sound_getbyte:=mem_snd[direccion];
end;
end;

procedure sound_putbyte(direccion:word;valor:byte);
begin
if direccion<$7fff then exit;
mem_snd[direccion]:=valor;
case direccion of
    $9000:upd7759_0.start_w(valor and $2);
    $a000:upd7759_0.port_w(valor);
    $c000:upd7759_0.reset_w(valor and 1);
    $e000:ym2203_0.Control(valor);
    $e001:ym2203_0.Write_Reg(valor);
end;
end;

procedure combatsc_sound_update;
begin
  ym2203_0.Update;
  upd7759_0.update;
end;

end.
