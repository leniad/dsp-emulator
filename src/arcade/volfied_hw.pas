unit volfied_hw;

interface
uses rom_engine;

function iniciar_volfied:boolean;

const
        volfied_rom:array[0..3] of tipo_roms=(
        (n:'c04-12-1.30';l:$10000;p:0;crc:$afb6a058),(n:'c04-08-1.10';l:$10000;p:1;crc:$19f7e66b),
        (n:'c04-11-1.29';l:$10000;p:$20000;crc:$1aaf6e9b),(n:'c04-25-1.9';l:$10000;p:$20001;crc:$b39e04f9));
        volfied_rom2:array[0..3] of tipo_roms=(
        (n:'c04-20.7';l:$20000;p:0;crc:$0aea651f),(n:'c04-22.9';l:$20000;p:1;crc:$f405d465),
        (n:'c04-19.6';l:$20000;p:$40000;crc:$231493ae),(n:'c04-21.8';l:$20000;p:$40001;crc:$8598d38e));
        volfied_sound:tipo_roms=(n:'c04-06.71';l:$8000;p:0;crc:$b70106b2);
        cchip_eeprom:tipo_roms=(n:'cchip_c04-23';l:$2000;p:0;crc:$46b0b479);
        volfied_sprites:array[0..8] of tipo_roms=(
        (n:'c04-16.2';l:$20000;p:0;crc:$8c2476ef),(n:'c04-18.4';l:$20000;p:1;crc:$7665212c),
        (n:'c04-15.1';l:$20000;p:$40000;crc:$7c50b978),(n:'c04-17.3';l:$20000;p:$40001;crc:$c62fdeb8),
        (n:'c04-10.15';l:$10000;p:$80000;crc:$429b6b49),(n:'c04-09.14';l:$10000;p:$80001;crc:$c78cf057),
        (n:'c04-10.15';l:$10000;p:$a0000;crc:$429b6b49),(n:'c04-09.14';l:$10000;p:$a0001;crc:$c78cf057),());

implementation
uses m68000,main_engine,controls_engine,gfx_engine,taito_sound,pal_engine,
     sound_engine,ym_2203,taito_cchip;

const
        volfied_dip1:array [0..4] of def_dip2=(
        (mask:1;name:'Cabinet';number:2;val2:(0,1);name2:('Upright','Cocktail')),
        (mask:2;name:'Flip_Screen';number:2;val2:(2,0);name2:('Off','On')),
        (mask:8;name:'Demo_Sounds';number:2;val2:(0,8);name2:('Off','On')),
        (mask:$30;name:'Coin A';number:4;val4:(0,$10,$20,$30);name4:('4C-1C','3C-1C','2C-1C','1C-1C')),
        (mask:$c0;name:'Coin B';number:4;val4:($c0,$80,$40,0);name4:('1C-2C','1C-3C','1C-4C','1C-6C')));
        volfied_dip2:array [0..3] of def_dip2=(
        (mask:3;name:'Bonus Life';number:4;val4:(2,3,1,0);name4:('20K 40K 120K 480K 2400K','50K 150K 600K 3000K','70K 280K 1400K','100K 500K')),
        (mask:$c;name:'Difficulty';number:4;val4:(8,$c,4,0);name4:('Easy','Medium','Hard','Hardest')),
        (mask:$70;name:'Lives';number:4;val4:($70,$60,$50,$40);name4:('3','4','5','6')),
        (mask:$80;name:'Languaje';number:2;val2:(0,$80);name2:('English','Japanese')));

var
 video_mask,video_ctrl:word;
 rom:array[0..$1ffff] of word;
 rom2,ram2:array[0..$3ffff] of word;
 ram1,ram3:array[0..$1fff] of word;
 spritebank:byte;

procedure update_video_volfied;
var
  x,y,nchar,atrib,color:word;
  p:dword;
  f:byte;
begin
  p:=0;
  if (video_ctrl and 1)<>0 then p:=p+$20000;
	for y:=0 to 247 do begin
		for x:=1 to 336 do begin // Hmm, 1 pixel offset is needed to align properly with sprites
      atrib:=ram2[p+x];
			color:=(atrib shl 2) and $700;
			if (atrib and $8000)<>0 then begin
				color:=color or $800 or ((atrib shr 9) and $f);
				if (atrib and $2000)<>0 then color:=color and not($f);	  // hack
			end else begin
        color:=color or (atrib and $f);
      end;
      putpixel(y,(336-x-1) and $1ff,1,@paleta[color],1);
		end;
		p:=p+512;
	end;
actualiza_trozo(0,0,248,336,1,0,0,248,336,2);
//Sprites
for f:=$ff downto 0 do begin
    nchar:=(ram3[2+(f*4)]) mod $1800;
    atrib:=ram3[f*4];
    color:=((atrib and $f) or spritebank) shl 4;
    put_gfx_sprite(nchar,color+$1000,(atrib and $8000)<>0,(atrib and $4000)<>0,0);
    y:=320-ram3[3+(f*4)];
    x:=ram3[1+(f*4)];
    actualiza_gfx_sprite(x and $1ff,y and $1ff,2,0);
end;
actualiza_trozo_final(8,16,240,320,2);
end;

procedure eventos_volfied;
begin
if event.arcade then begin
  marcade.in0:=$ff;
  marcade.in1:=$fc;
  marcade.in2:=$ff;
  marcade.in3:=$ff;
  //F00007
  if arcade_input.start[1] then marcade.in0:=marcade.in0 and $df;
  if arcade_input.start[0] then marcade.in0:=marcade.in0 and $bf;
  //F00009
  if arcade_input.coin[0] then marcade.in1:=marcade.in1 or 1;
  if arcade_input.coin[1] then marcade.in1:=marcade.in1 or 2;
  //F0000B
  if arcade_input.up[0] then marcade.in2:=marcade.in2 and $fb;
  if arcade_input.down[0] then marcade.in2:=marcade.in2 and $f7;
  if arcade_input.left[0] then marcade.in2:=marcade.in2 and $ef;
  if arcade_input.right[0] then marcade.in2:=marcade.in2 and $df;
  if arcade_input.but0[0] then marcade.in2:=marcade.in2 and $bf;
  //F0000D
  if arcade_input.up[1] then marcade.in3:=marcade.in3 and $fd;
  if arcade_input.down[1] then marcade.in3:=marcade.in3 and $fb;
  if arcade_input.right[1] then marcade.in3:=marcade.in3 and $ef;
  if arcade_input.but0[1] then marcade.in3:=marcade.in3 and $df;
  if arcade_input.left[1] then marcade.in3:=marcade.in3 and $7f;
end;
end;

procedure volfied_principal;
var
  f:byte;
begin
while EmuStatus=EsRunning do begin
    for f:=0 to 255 do begin
        eventos_volfied;
        if f=248 then begin
          update_video_volfied;
          m68000_0.irq[4]:=HOLD_LINE;
          cchip_0.set_int;
        end;
        //Main CPU
        m68000_0.run(frame_main);
        frame_main:=frame_main+m68000_0.tframes-m68000_0.contador;
        //Sound CPU
        tc0140syt_0.run;
        //MCU
        cchip_0.upd7810.run(frame_mcu);
        frame_mcu:=frame_mcu+cchip_0.upd7810.tframes-cchip_0.upd7810.contador;
    end;
    video_sync;
end;
end;

function volfied_getword(direccion:dword):word;
begin
case direccion of
  0..$3ffff:volfied_getword:=rom[direccion shr 1];
  $80000..$fffff:volfied_getword:=rom2[(direccion and $7ffff) shr 1];
  $100000..$103fff:volfied_getword:=ram1[(direccion and $3fff) shr 1];
  $200000..$203fff:volfied_getword:=ram3[(direccion and $3fff) shr 1];
  $400000..$47ffff:volfied_getword:=ram2[(direccion and $7ffff) shr 1];
  $500000..$503fff:volfied_getword:=buffer_paleta[(direccion and $3fff) shr 1];
  $d00000:volfied_getword:=$60;
  $e00002:if m68000_0.read_8bits_hi_dir then volfied_getword:=tc0140syt_0.comm_r;
  $f00000..$f007ff:volfied_getword:=cchip_0.mem68_r((direccion and $7ff) shr 1);
  $f00800..$f00fff:volfied_getword:=cchip_0.asic_r((direccion and $7ff) shr 1);
end;
end;

procedure volfied_putword(direccion:dword;valor:word);
procedure cambiar_color(tmp_color,numero:word);
var
  color:tcolor;
begin
  color.b:=pal5bit(tmp_color shr 10);
  color.g:=pal5bit(tmp_color shr 5);
  color.r:=pal5bit(tmp_color);
  set_pal_color(color,numero);
end;
begin
case direccion of
      0..$fffff:; //ROM
      $100000..$103fff:ram1[(direccion and $3fff) shr 1]:=valor;
      $200000..$203fff:ram3[(direccion and $3fff) shr 1]:=valor;
      $400000..$47ffff:ram2[(direccion and $7ffff) shr 1]:=(ram2[(direccion and $7ffff) shr 1] and not(video_mask)) or (valor and video_mask);
      $500000..$503fff:if buffer_paleta[(direccion and $3fff) shr 1]<>valor then begin
                              buffer_paleta[(direccion and $3fff) shr 1]:=valor;
                              cambiar_color(valor,(direccion and $3fff) shr 1);
                       end;
      $600000:video_mask:=valor;
      $700000:spritebank:=(valor and $3c) shl 2;
      $d00000:video_ctrl:=valor;
      $e00000:tc0140syt_0.port_w(valor and $ff);
      $e00002:tc0140syt_0.comm_w(valor and $ff);
      $f00000..$f007ff:cchip_0.mem68_w((direccion and $7ff) shr 1,valor and $ff);
      $f00800..$f00fff:cchip_0.asic68_w((direccion and $7ff) shr 1,valor and $ff);
end;
end;

function volfied_dipa:byte;
begin
  volfied_dipa:=marcade.dswa;
end;

function volfied_dipb:byte;
begin
  volfied_dipb:=marcade.dswb;
end;

function volfied_f00007:byte;
begin
  volfied_f00007:=marcade.in0;
end;

function volfied_f00009:byte;
begin
  volfied_f00009:=marcade.in1;
end;

function volfied_f0000c:byte;
begin
  volfied_f0000c:=marcade.in2;
end;

function volfied_f0000d:byte;
begin
  volfied_f0000d:=marcade.in3;
end;

//Main
procedure reset_volfied;
begin
 m68000_0.reset;
 tc0140syt_0.reset;
 cchip_0.reset;
 frame_main:=m68000_0.tframes;
 frame_mcu:=cchip_0.upd7810.tframes;
 marcade.in0:=$ff;
 marcade.in1:=$fc;
 marcade.in2:=$ff;
 marcade.in3:=$ff;
 video_mask:=0;
 video_ctrl:=0;
 spritebank:=0;
end;

function iniciar_volfied:boolean;
const
  ps_x:array[0..15] of dword=(0*4, 1*4, 2*4, 3*4, 4*4, 5*4, 6*4, 7*4, 8*4, 9*4, 10*4, 11*4, 12*4, 13*4, 14*4, 15*4);
  ps_y:array[0..15] of dword=(0*64, 1*64, 2*64, 3*64, 4*64, 5*64, 6*64, 7*64, 8*64, 9*64, 10*64, 11*64, 12*64, 13*64, 14*64, 15*64);
var
  memoria_temp:pbyte;
begin
iniciar_volfied:=false;
llamadas_maquina.bucle_general:=volfied_principal;
llamadas_maquina.reset:=reset_volfied;
llamadas_maquina.scanlines:=256;
iniciar_audio(false);
screen_init(1,248,512);
screen_init(2,512,512,false,true);
iniciar_video(240,320);
//Main CPU
m68000_0:=cpu_m68000.create(8000000);
m68000_0.change_ram16_calls(volfied_getword,volfied_putword);
if not(roms_load16w(@rom,volfied_rom)) then exit;
if not(roms_load16w(@rom2,volfied_rom2)) then exit;
//Sound CPU
tc0140syt_0:=tc0140syt_chip.create(4000000,SOUND_VOLFIED);
ym2203_0.change_io_calls(volfied_dipa,volfied_dipb,nil,nil);
if not(roms_load(@tc0140syt_0.snd_rom,volfied_sound)) then exit;
//MCU
cchip_0:=cchip_chip.create(10000000);
cchip_0.change_ad(volfied_f0000d);
cchip_0.change_in(volfied_f00007,volfied_f00009,volfied_f0000c,nil,nil);
if not(roms_load(cchip_0.get_eeprom_dir,cchip_eeprom)) then exit;
//convertir sprites
getmem(memoria_temp,$100000);
if not(roms_load16b(memoria_temp,volfied_sprites)) then exit;
init_gfx(0,16,16,$1800);
gfx[0].trans[0]:=true;
gfx_set_desc_data(4,0,128*8,0,1,2,3);
convert_gfx(0,0,memoria_temp,@ps_x,@ps_y,false,true);
freemem(memoria_temp);
//DIP
init_dips(1,volfied_dip1,$fe);
init_dips(2,volfied_dip2,$7f);
//final
iniciar_volfied:=true;
end;

end.
