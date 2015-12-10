unit tmnt_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,m68000,main_engine,controls_engine,gfx_engine,rom_engine,
     pal_engine,sound_engine,timer_engine,upd7759,ym_2151,k052109,k051960,
     misc_functions,samples;

procedure Cargar_tmnt;
procedure tmnt_principal;
function iniciar_tmnt:boolean;
procedure reset_tmnt;
procedure cerrar_tmnt;
//Main CPU
function tmnt_getword(direccion:dword):word;
procedure tmnt_putword(direccion:dword;valor:word);
//Sound CPU
function tmnt_snd_getbyte(direccion:word):byte;
procedure tmnt_snd_putbyte(direccion:word;valor:byte);
procedure tmnt_sound_update;
procedure tmnt_cb(layer,bank:word;var code:word;var color:word;var flags:word;var priority:word);
procedure tmnt_sprite_cb(var code:word;var color:word;var pri:word;var shadow:word);

implementation
const
        tmnt_rom:array[0..4] of tipo_roms=(
        (n:'963-x23.j17';l:$20000;p:0;crc:$a9549004),(n:'963-x24.k17';l:$20000;p:$1;crc:$e5cc9067),
        (n:'963-x21.j15';l:$10000;p:$40000;crc:$5789cf92),(n:'963-x22.k15';l:$10000;p:$40001;crc:$0a74e277),());
        tmnt_sound:tipo_roms=(n:'963e20.g13';l:$8000;p:0;crc:$1692a6d6);
        tmnt_char:array[0..2] of tipo_roms=(
        (n:'963a28.h27';l:$80000;p:0;crc:$db4769a8),(n:'963a29.k27';l:$80000;p:$2;crc:$8069cd2e),());
        tmnt_sprites:array[0..4] of tipo_roms=(
        (n:'963a17.h4';l:$80000;p:0;crc:$b5239a44),(n:'963a15.k4';l:$80000;p:$2;crc:$1f324eed),
        (n:'963a18.h6';l:$80000;p:$100000;crc:$dd51adef),(n:'963a16.k6';l:$80000;p:$100002;crc:$d4bd9984),());
        tmnt_prom:array[0..2] of tipo_roms=(
        (n:'963a30.g7';l:$100;p:0;crc:$abd82680),(n:'963a31.g19';l:$100;p:$100;crc:$f8004a1c),());
        tmnt_upd:tipo_roms=(n:'963a27.d18';l:$20000;p:0;crc:$2dfd674b);
        tmnt_title:tipo_roms=(n:'963a25.d5';l:$80000;p:0;crc:$fca078c7);
        //DIP
        tmnt_dip:array [0..10] of def_dip=(
        (mask:$3;name:'Lives';number:4;dip:((dip_val:$3;dip_name:'3'),(dip_val:$2;dip_name:'4'),(dip_val:$1;dip_name:'5'),(dip_val:$0;dip_name:'6'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Bonus Life';number:4;dip:((dip_val:$c;dip_name:'20k then every 60k'),(dip_val:$8;dip_name:'30k then every 70k'),(dip_val:$4;dip_name:'40k then every 80k'),(dip_val:$0;dip_name:'50k then every 90k'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$10;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$20;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$300;name:'Coin A';number:4;dip:((dip_val:$100;dip_name:'2 Coin - 1 Credit '),(dip_val:$300;dip_name:'1 Coin - 1 Credit'),(dip_val:$200;dip_name:'1 Coin - 2 Credit'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c00;name:'Coin B';number:4;dip:((dip_val:$0;dip_name:'3 Coin - 1 Credit '),(dip_val:$400;dip_name:'2 Coin - 3 Credit'),(dip_val:$c00;dip_name:'1 Coin - 3 Credit'),(dip_val:$800;dip_name:'1 Coin - 6 Credit'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$1000;name:'Difficulty';number:2;dip:((dip_val:$1000;dip_name:'Easy'),(dip_val:$0;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2000;name:'Flip Screen';number:2;dip:((dip_val:$2000;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4000;name:'Complete Invulnerability';number:2;dip:((dip_val:$4000;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8000;name:'Base Ship Invulnerability';number:2;dip:((dip_val:$8000;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 rom:array[0..$2ffff] of word;
 ram:array[0..$1fff] of word;
 char_rom,sprite_rom:pbyte;
 sound_latch,sound_latch2,sprite_colorbase,last_snd,sprites_pri:byte;
 layer_colorbase:array[0..2] of byte;
 irq5_mask:boolean;

procedure Cargar_tmnt;
begin
llamadas_maquina.iniciar:=iniciar_tmnt;
llamadas_maquina.bucle_general:=tmnt_principal;
llamadas_maquina.cerrar:=cerrar_tmnt;
llamadas_maquina.reset:=reset_tmnt;
end;

function iniciar_tmnt:boolean;
var
  f,tempdw:dword;
  mem_temp:array[0..$1ff] of byte;
  ptemp:pbyte;
  ptempw:pword;
procedure desencriptar_sprites;
var
  len,a,b:dword;
  entry,i:byte;
  bits:array[0..31] of byte;
  temp:pbyte;
const
  CA0=0;
  CA1=1;
  CA2=2;
  CA3=3;
  CA4=4;
  CA5=5;
  CA6=6;
  CA7=7;
  CA8=8;
  CA9=9;
		// following table derived from the schematics. It indicates, for each of the */
		// 9 low bits of the sprite line address, which bit to pick it from. */
		// For example, when the PROM contains 4, which applies to 4x2 sprites, */
		// bit OA1 comes from CA5, OA2 from CA0, and so on. */
	bit_pick_table:array[0..9,0..7] of byte=(
			//0(1x1) 1(2x1) 2(1x2) 3(2x2) 4(4x2) 5(2x4) 6(4x4) 7(8x8) */
			( CA3,   CA3,   CA3,   CA3,   CA3,   CA3,   CA3,   CA3 ),   // CA3 */
			( CA0,   CA0,   CA5,   CA5,   CA5,   CA5,   CA5,   CA5 ),   // OA1 */
			( CA1,   CA1,   CA0,   CA0,   CA0,   CA7,   CA7,   CA7 ),   // OA2 */
			( CA2,   CA2,   CA1,   CA1,   CA1,   CA0,   CA0,   CA9 ),   // OA3 */
			( CA4,   CA4,   CA2,   CA2,   CA2,   CA1,   CA1,   CA0 ),   // OA4 */
			( CA5,   CA6,   CA4,   CA4,   CA4,   CA2,   CA2,   CA1 ),   // OA5 */
			( CA6,   CA5,   CA6,   CA6,   CA6,   CA4,   CA4,   CA2 ),   // OA6 */
			( CA7,   CA7,   CA7,   CA7,   CA8,   CA6,   CA6,   CA4 ),   // OA7 */
			( CA8,   CA8,   CA8,   CA8,   CA7,   CA8,   CA8,   CA6 ),   // OA8 */
			( CA9,   CA9,   CA9,   CA9,   CA9,   CA9,   CA9,   CA8 ));  // OA9 */
begin
	// unscramble the sprite ROM address lines
	len:=$200000 div 4;
	getmem(temp,$200000);
  copymemory(temp,sprite_rom,$200000);
	for a:=0 to (len-1) do begin
		// pick the correct entry in the PROM (top 8 bits of the address) */
		entry:=mem_temp[(A and $7f800) shr 11] and 7;
		// the bits to scramble are the low 10 ones */
		for i:=0 to 9 do bits[i]:=(A shr i) and $1;
		B:=A and $7fc00;
		for i:=0 to 9 do B:=b or (bits[bit_pick_table[i][entry]] shl i);
    sprite_rom[a*4]:=temp[b*4];
    sprite_rom[(a*4)+1]:=temp[(b*4)+1];
    sprite_rom[(a*4)+2]:=temp[(b*4)+2];
    sprite_rom[(a*4)+3]:=temp[(b*4)+3];
	end;
  freemem(temp);
end;

function decode_sample(orig:pbyte;dest:pword):dword;
var
  i:dword;
  val:word;
  expo,cont1,cont2:byte;
  ptemp:pword;
  pos:dword;
begin
	//  Sound sample for TMNT.D05 is stored in the following mode (ym3012 format):
	//  Bit 15-13:  Exponent (2 ^ x)
	//  Bit 12-3 :  Sound data (10 bit)
	//  (Sound info courtesy of Dave <dave@finalburn.com>)
  //El original viene a 20Khz, lo convierto a 44Khz
  pos:=0;
  cont2:=0;
	for i:=0 to $3ffff do begin
		val:=orig[2*i]+orig[2*i+1]*256;
		expo:=val shr 13;
		val:=(val shr 3) and $3ff; // 10 bit, Max Amplitude 0x400 */
		val:=val-$200;                   // Centralize value */
		val:=val shl (expo-3);
    for cont1:=0 to 1 do begin
      ptemp:=dest;
      inc(ptemp,pos);
		  ptemp^:=val;
      pos:=pos+1;
    end;
    cont2:=cont2+1;
    if cont2=5 then begin
      cont2:=0;
      ptemp:=dest;
      inc(ptemp,pos);
		  ptemp^:=val;
      pos:=pos+1;
    end;
  end;
  decode_sample:=pos;
end;

begin
iniciar_tmnt:=false;
iniciar_audio(false);
//Pantallas para el K052109
screen_init(1,512,256,true);
screen_init(2,512,256,true);
screen_mod_scroll(2,512,512,511,256,256,255);
screen_init(3,512,256,true);
screen_mod_scroll(3,512,512,511,256,256,255);
screen_init(4,512,512,false,true);
iniciar_video(320,224);
//cargar roms
if not(cargar_roms16w(@rom[0],@tmnt_rom[0],'tmnt.zip',0)) then exit;
//cargar sonido
if not(cargar_roms(@mem_snd[0],@tmnt_sound,'tmnt.zip',1)) then exit;
//Main CPU
main_m68000:=cpu_m68000.create(8000000,256);
main_m68000.change_ram16_calls(tmnt_getword,tmnt_putword);
//Sound CPU
snd_z80:=cpu_z80.create(3579545,256);
snd_z80.change_ram_calls(tmnt_snd_getbyte,tmnt_snd_putbyte);
snd_z80.init_sound(tmnt_sound_update);
//Sound Chips
YM2151_Init(0,3579545,nil,nil);
upd7759_0:=upd7759_chip.create(640000,0.6);
if not(cargar_roms(upd7759_0.get_rom_addr,@tmnt_upd,'tmnt.zip',1)) then exit;
getmem(ptemp,$80000);
getmem(ptempw,$80000*3);
if not(cargar_roms(ptemp,@tmnt_title,'tmnt.zip',1)) then exit;
load_samples_raw(ptempw,decode_sample(ptemp,ptempw),false,false);
freemem(ptemp);
freemem(ptempw);
//Iniciar video
getmem(char_rom,$100000);
if not(cargar_roms32b(char_rom,@tmnt_char,'tmnt.zip',0)) then exit;
//Ordenar
for f:=0 to $3FFFF do begin
  tempdw:=char_rom[(f*4)+0];
  tempdw:=tempdw or (char_rom[(f*4)+1] shl 8);
  tempdw:=tempdw or (char_rom[(f*4)+2] shl 16);
  tempdw:=tempdw or (char_rom[(f*4)+3] shl 24);
  tempdw:=BITSWAP32(tempdw,31,27,23,19,15,11,7,3,30,26,22,18,14,10,6,2,29,25,21,17,13,9,5,1,28,24,20,16,12,8,4,0);
  char_rom[(f*4)+0]:=tempdw and $ff;
  char_rom[(f*4)+1]:=(tempdw shr 8) and $ff;
  char_rom[(f*4)+2]:=(tempdw shr 16) and $ff;
  char_rom[(f*4)+3]:=(tempdw shr 24) and $ff;
end;
k052109_0:=k052109_chip.create(1,2,3,tmnt_cb,char_rom,$100000);
//Init sprites
getmem(sprite_rom,$200000);
if not(cargar_roms32b(sprite_rom,@tmnt_sprites,'tmnt.zip',0)) then exit;
if not(cargar_roms(@mem_temp[0],@tmnt_prom,'tmnt.zip',0)) then exit;
//Ordenar
for f:=0 to $7FFFF do begin
  tempdw:=sprite_rom[(f*4)+0];
  tempdw:=tempdw or (sprite_rom[(f*4)+1] shl 8);
  tempdw:=tempdw or (sprite_rom[(f*4)+2] shl 16);
  tempdw:=tempdw or (sprite_rom[(f*4)+3] shl 24);
  tempdw:=BITSWAP32(tempdw,31,27,23,19,15,11,7,3,30,26,22,18,14,10,6,2,29,25,21,17,13,9,5,1,28,24,20,16,12,8,4,0);
  sprite_rom[(f*4)+0]:=tempdw and $ff;
  sprite_rom[(f*4)+1]:=(tempdw shr 8) and $ff;
  sprite_rom[(f*4)+2]:=(tempdw shr 16) and $ff;
  sprite_rom[(f*4)+3]:=(tempdw shr 24) and $ff;
end;
desencriptar_sprites;
k051960_0:=k051960_chip.create(4,sprite_rom,$200000,tmnt_sprite_cb);
layer_colorbase[0]:=0;
layer_colorbase[1]:=32;
layer_colorbase[2]:=40;
sprite_colorbase:=16;
//DIP
marcade.dswa:=$ffdf;
marcade.dswa_val:=@tmnt_dip;
//final
reset_tmnt;
iniciar_tmnt:=true;
end;

procedure cerrar_tmnt;
begin
main_m68000.free;
snd_z80.free;
YM2151_close(0);
upd7759_0.free;
k052109_0.Free;
k051960_0.free;
close_samples;
freemem(char_rom);
freemem(sprite_rom);
close_audio;
close_video;
end;

procedure reset_tmnt;
begin
 main_m68000.reset;
 snd_z80.reset;
 k052109_0.reset;
 k051960_0.reset;
 YM2151_reset(0);
 upd7759_0.reset;
 upd7759_0.start_w(0);
 upd7759_0.reset_w(1);
 reset_samples;
 reset_audio;
 marcade.in0:=$FF;
 marcade.in1:=$FF;
 marcade.in2:=$FF;
 sound_latch:=0;
 sound_latch2:=0;
 irq5_mask:=false;
 last_snd:=0;
 sprites_pri:=0;
end;

procedure tmnt_cb(layer,bank:word;var code:word;var color:word;var flags:word;var priority:word);
begin
code:=code or ((color and $03) shl 8) or ((color and $10) shl 6) or ((color and $0c) shl 9) or (bank shl 13);
color:=layer_colorbase[layer]+((color and $e0) shr 5);
end;

procedure tmnt_sprite_cb(var code:word;var color:word;var pri:word;var shadow:word);
begin
  code:=code or ((color and $10) shl 9);
	color:=sprite_colorbase+(color and $0f);
end;

procedure update_video_tmnt;
begin
k052109_0.updatetile;
fill_full_screen(4,0);
case k052109_0.scroll_tipo[2] of
  0,1,2:;
  3:scroll_x_y(3,4,k052109_0.scroll_x[2,0],k052109_0.scroll_y[2,0]);
end;
if (sprites_pri and 1)=1 then k051960_0.draw_sprites(0,0);
case k052109_0.scroll_tipo[1] of
  0,1,2:;
  3:scroll_x_y(2,4,k052109_0.scroll_x[1,0],k052109_0.scroll_y[1,0]);
end;
if (sprites_pri and 1)=0 then k051960_0.draw_sprites(0,0);
//Esta es fija
actualiza_trozo(0,0,512,256,1,0,0,512,256,4);
actualiza_trozo_final(96,16,320,224,4);
end;

procedure eventos_tmnt;
begin
if event.arcade then begin
  //P1
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $Fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $F7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.but2[0] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
  //P2
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $Fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $F7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.but2[1] then marcade.in2:=(marcade.in2 and $bf) else marcade.in2:=(marcade.in2 or $40);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 and $7f) else marcade.in2:=(marcade.in2 or $80);
  //SYSTEM
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
end;
end;

procedure tmnt_principal;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=main_m68000.tframes;
frame_s:=snd_z80.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to $ff do begin
  //main
  main_m68000.run(frame_m);
  frame_m:=frame_m+main_m68000.tframes-main_m68000.contador;
  //sound
  snd_z80.run(frame_s);
  frame_s:=frame_s+snd_z80.tframes-snd_z80.contador;
  if f=239 then begin
    update_video_tmnt;
    if irq5_mask then main_m68000.irq[5]:=HOLD_LINE;
  end;
 end;
 eventos_tmnt;
 video_sync;
end;
end;

function tmnt_getword(direccion:dword):word;
begin
case direccion of
    0..$05ffff:tmnt_getword:=rom[direccion shr 1];
    $060000..$063fff:tmnt_getword:=ram[(direccion and $3fff) shr 1];
    $080000..$080fff:tmnt_getword:=buffer_paleta[(direccion and $fff) shr 1];
    $0a0000:tmnt_getword:=marcade.in0; //coin
    $0a0002:tmnt_getword:=marcade.in1; //p1
    $0a0004:tmnt_getword:=marcade.in2; //p2
    $0a0006:tmnt_getword:=$ff; //p3
    $0a0010:tmnt_getword:=$ff; //dsw1
    $0a0012:tmnt_getword:=$5e; //dsw2
    $0a0014:tmnt_getword:=$ff; //p4
    $0a0018:tmnt_getword:=$ff; //dsw3
    $100000..$107fff:begin
                        direccion:=direccion shr 1;
                        tmnt_getword:=k052109_0.word_r(((direccion and $3000) shr 1) or (direccion and $07ff));
                     end;
    $140000..$140007:tmnt_getword:=k051960_0.k051937_read(direccion and 7);
	  $140400..$1407ff:if main_m68000.access_8bits then tmnt_getword:=k051960_0.read((direccion and $3ff)+1)
                          else tmnt_getword:=k051960_0.read(direccion and $3ff) shl 8;
end;
end;

procedure cambiar_color(pos:word);
var
  color:tcolor;
  data:word;
begin
  data:=(buffer_paleta[pos and $7fe] shl 8) or (buffer_paleta[(pos and $7fe)+1] shl 0);
  color.b:=pal5bit(data shr 10);
  color.g:=pal5bit(data shr 5);
  color.r:=pal5bit(data);
  set_pal_color(color,@paleta[pos shr 1]);
  {case pos of
    $100..$1ff:buffer_color[$10+((pos shr 4) and $f)]:=true;
    $200..$2ff:buffer_color[(pos shr 4) and $f]:=true;
  end; }
end;

procedure tmnt_putword(direccion:dword;valor:word);
begin
if direccion<$60000 then exit;
case direccion of
    $060000..$063fff:ram[(direccion and $3fff) shr 1]:=valor;
    $080000..$080fff:if buffer_paleta[(direccion and $fff) shr 1]<>(valor and $ff) then begin
                        buffer_paleta[(direccion and $fff) shr 1]:=valor and $ff;
                        cambiar_color((direccion and $fff) shr 1);
                   end;
    $0a0000:begin
              if ((last_snd=8) and ((valor and 8)=0)) then snd_z80.pedir_irq:=HOLD_LINE;
              last_snd:=valor and 8;
		          // bit 5 = irq enable
		          irq5_mask:=(valor and $20)<>0;
		          // bit 7 = enable char ROM reading through the video RAM */
		          if (valor and $80)<>0 then k052109_0.rmrd_line:=ASSERT_LINE
                else k052109_0.rmrd_line:=CLEAR_LINE;
            end;
    $0a0008:sound_latch:=valor and $ff;
    $0c0000:sprites_pri:=(valor and $0c) shr 2; //prioridad
    $100000..$107fff:begin
                        direccion:=direccion shr 1;
                        k052109_0.word_w(((direccion and $3000) shr 1) or (direccion and $07ff),valor,main_m68000.access_8bits);
                     end;
    $140000..$140007:k051960_0.k051937_write((direccion and $7),valor);
	  $140400..$1407ff:if main_m68000.access_8bits then k051960_0.write((direccion and $3ff)+1,valor and $ff)
                        else k051960_0.write(direccion and $3ff,valor shr 8)
  end;
end;

function tmnt_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$87ff:tmnt_snd_getbyte:=mem_snd[direccion];
  $9000:tmnt_snd_getbyte:=sound_latch2;
  $a000:tmnt_snd_getbyte:=sound_latch;
  $b000..$b00d:tmnt_snd_getbyte:=0;
  $c001:tmnt_snd_getbyte:=YM2151_status_port_read(0);
  $f000:tmnt_snd_getbyte:=upd7759_0.busy_r;
end;
end;

procedure tmnt_snd_putbyte(direccion:word;valor:byte);
begin
if direccion<$8000 then exit;
case direccion of
  $8000..$87ff:mem_snd[direccion]:=valor;
  $9000:begin
          upd7759_0.reset_w(valor and 2);
	        // bit 2 plays the title music
	        if (((valor and 4)<>0) and not(sample_status(0))) then start_sample(0)
            else stop_sample(0);
	        sound_latch2:=valor;
        end;
  $b000..$b00d:;
  $c000:YM2151_register_port_write(0,valor);
  $c001:YM2151_data_port_write(0,valor);
  $d000:upd7759_0.port_w(valor);
  $e000:upd7759_0.start_w(valor and 1);
end;
end;

procedure tmnt_sound_update;
begin
  ym2151_Update(0);
  upd7759_0.update;
  samples_update;
end;

end.
