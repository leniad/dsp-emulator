unit appoooh_hw;
interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     sound_engine,sn_76496,msm5205,sega_decrypt_2;

function iniciar_appoooh:boolean;

implementation
const
        appoooh_rom:array[0..8] of tipo_roms=(
        (n:'epr-5906.bin';l:$2000;p:0;crc:$fffae7fe),(n:'epr-5907.bin';l:$2000;p:$2000;crc:$57696cd6),
        (n:'epr-5908.bin';l:$2000;p:$4000;crc:$4537cddc),(n:'epr-5909.bin';l:$2000;p:$6000;crc:$cf82718d),
        (n:'epr-5910.bin';l:$2000;p:$8000;crc:$312636da),(n:'epr-5911.bin';l:$2000;p:$a000;crc:$0bc2acaa),
        (n:'epr-5913.bin';l:$2000;p:$c000;crc:$f5a0e6a7),(n:'epr-5912.bin';l:$2000;p:$e000;crc:$3c3915ab),
        (n:'epr-5914.bin';l:$2000;p:$10000;crc:$58792d4a));
        appoooh_char1:array[0..2] of tipo_roms=(
        (n:'epr-5895.bin';l:$4000;p:0;crc:$4b0d4294),(n:'epr-5896.bin';l:$4000;p:$4000;crc:$7bc84d75),
        (n:'epr-5897.bin';l:$4000;p:$8000;crc:$745f3ffa));
        appoooh_char2:array[0..2] of tipo_roms=(
        (n:'epr-5898.bin';l:$4000;p:0;crc:$cf01644d),(n:'epr-5899.bin';l:$4000;p:$4000;crc:$885ad636),
        (n:'epr-5900.bin';l:$4000;p:$8000;crc:$a8ed13f3));
        appoooh_prom:array[0..2] of tipo_roms=(
        (n:'pr5921.prm';l:$20;p:0;crc:$f2437229),(n:'pr5922.prm';l:$100;p:$20;crc:$85c542bf),
        (n:'pr5923.prm';l:$100;p:$120;crc:$16acbd53));
        appoooh_adpcm:array[0..4] of tipo_roms=(
        (n:'epr-5901.bin';l:$2000;p:0;crc:$170a10a4),(n:'epr-5902.bin';l:$2000;p:$2000;crc:$f6981640),
        (n:'epr-5903.bin';l:$2000;p:$4000;crc:$0439df50),(n:'epr-5904.bin';l:$2000;p:$6000;crc:$9988f2ae),
        (n:'epr-5905.bin';l:$2000;p:$8000;crc:$fb5cd70e));
        //DIP
        appoooh_dip:array [0..4] of def_dip2=(
        (mask:7;name:'Coin A';number:8;val8:(3,2,1,0,7,4,5,6);name8:('4C 1C','3C 1C','2C 1C','1C 1C','2C 3C','1C 2C','1C 3C','1C 6C')),
        (mask:$18;name:'Coin B';number:4;val4:($18,$10,0,8);name4:('3C 1C','2C 1C','1C 1C','1C 2C')),
        (mask:$20;name:'Demo Sounds';number:2;val2:(0,$20);name2:('Off','On')),
        (mask:$40;name:'Cabinet';number:2;val2:($40,0);name2:('Upright','Cocktail')),
        (mask:$80;name:'Difficulty';number:2;val2:(0,$80);name2:('Easy','Hard')));
        robowres_rom:array[0..2] of tipo_roms=(
        (n:'epr-7540.13d';l:$8000;p:0;crc:$a2a54237),(n:'epr-7541.14d';l:$8000;p:$8000;crc:$cbf7d1a8),
        (n:'epr-7542.15d';l:$8000;p:$10000;crc:$3475fbd4));
        robowres_char1:array[0..2] of tipo_roms=(
        (n:'epr-7544.7h';l:$8000;p:0;crc:$07b846ce),(n:'epr-7545.6h';l:$8000;p:$8000;crc:$e99897be),
        (n:'epr-7546.5h';l:$8000;p:$10000;crc:$1559235a));
        robowres_char2:array[0..2] of tipo_roms=(
        (n:'epr-7547.7d';l:$8000;p:0;crc:$b87ad4a4),(n:'epr-7548.6d';l:$8000;p:$8000;crc:$8b9c75b3),
        (n:'epr-7549.5d';l:$8000;p:$10000;crc:$f640afbb));
        robowres_prom:array[0..2] of tipo_roms=(
        (n:'pr7571.10a';l:$20;p:0;crc:$e82c6d5c),(n:'pr7572.7f';l:$100;p:$20;crc:$2b083d0c),
        (n:'pr7573.7g';l:$100;p:$120;crc:$2b083d0c));
        robowres_adpcm:tipo_roms=(n:'epr-7543.12b';l:$8000;p:0;crc:$4d108c49);
        //DIP
        robowres_dip:array [0..3] of def_dip2=(
        (mask:7;name:'Coin A';number:8;val8:(3,2,1,0,7,4,5,6);name8:('4C 1C','3C 1C','2C 1C','1C 1C','2C 3C','1C 2C','1C 3C','1C 6C')),
        (mask:$18;name:'Coin B';number:4;val4:($18,$10,0,8);name4:('3C 1C','2C 1C','1C 1C','1C 2C')),
        (mask:$20;name:'Demo Sounds';number:2;val2:(0,$20);name2:('Off','On')),
        (mask:$80;name:'Language';number:2;val2:(0,$80);name2:('Japanese','English')));

var
  adpcm_playing,nmi_vblank:boolean;
  priority,rom_bank:byte;
  memoria_rom:array[0..1,0..$3fff] of byte;
  //scroll_x:byte; Se usa???
  rom_dec:array[0..$7fff] of byte;
  sprite_base:word;

procedure update_video_appoooh;
var
  x,y,atrib:byte;
  f,nchar,color:word;
  flip_x:boolean;
procedure draw_sprites(bank:byte);
var
  f,atrib2:byte;
  sx,sy:word;
begin
  for f:=7 downto 0 do begin
    atrib:=memoria[$f001+$800*bank+(f*4)];
    atrib2:=memoria[$f002+$800*bank+(f*4)];
    nchar:=sprite_base+((atrib shr 2)+((atrib2 and $e0) shl 1));
    color:=(atrib2 and $f) shl 3;
    sx:=memoria[$f003+$800*bank+(f*4)];
    sy:=240-memoria[$f000+$800*bank+(f*4)];
    put_gfx_sprite(nchar,color+$100*bank,(atrib and 1)<>0,false,bank+2);
    actualiza_gfx_sprite(sx,sy,3,bank+2);
  end;
end;
begin
for f:=0 to $3ff do begin
    y:=f shr 5;
    x:=f and $1f;
    //Background
    if gfx[1].buffer[f] then begin
      atrib:=memoria[$fc00+f];
      color:=(atrib and $f);
      nchar:=memoria[$f800+f]+((atrib shr 5) and 7)*256;
      flip_x:=(atrib and $10)<>0;
      put_gfx_flip(x*8,y*8,nchar,(color shl 3)+256,1,1,flip_x,false);
      gfx[1].buffer[f]:=false;
    end;
    //Foreground
    if gfx[0].buffer[f] then begin
      atrib:=memoria[$f400+f];
      color:=(atrib and $f);
      nchar:=memoria[$f000+f]+((atrib shr 5) and 7)*256;
      flip_x:=(atrib and $10)<>0;
      put_gfx_trans_flip(x*8,y*8,nchar,color shl 3,2,0,flip_x,false);
      gfx[0].buffer[f]:=false;
    end;
end;
actualiza_trozo(0,0,256,256,1,0,0,256,256,3);
if priority=0 then actualiza_trozo(0,0,256,256,2,0,0,256,256,3);
if priority=1 then begin
  draw_sprites(0);
  draw_sprites(1);
end else begin
  draw_sprites(1);
  draw_sprites(0);
end;
if priority<>0 then actualiza_trozo(0,0,256,256,2,0,0,256,256,3);
actualiza_trozo_final(0,16,256,224,3);
end;

procedure eventos_appoooh;
begin
if event.arcade then begin
  //p1
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 or 1) else marcade.in0:=(marcade.in0 and $fe);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 or 2) else marcade.in0:=(marcade.in0 and $fd);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 or 4) else marcade.in0:=(marcade.in0 and $fb);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 or 8) else marcade.in0:=(marcade.in0 and $f7);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 or $10) else marcade.in0:=(marcade.in0 and $ef);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 or $20) else marcade.in0:=(marcade.in0 and $df);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 or $40) else marcade.in0:=(marcade.in0 and $bf);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 or $80) else marcade.in0:=(marcade.in0 and $7f);
  //p2
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 or 1) else marcade.in1:=(marcade.in1 and $fe);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 or 2) else marcade.in1:=(marcade.in1 and $fd);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 or 4) else marcade.in1:=(marcade.in1 and $fb);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 or 8) else marcade.in1:=(marcade.in1 and $f7);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 or $10) else marcade.in1:=(marcade.in1 and $ef);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 or $20) else marcade.in1:=(marcade.in1 and $df);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 or $40) else marcade.in1:=(marcade.in1 and $bf);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 or $80) else marcade.in1:=(marcade.in1 and $7f);
  //System
  if arcade_input.but2[0] then marcade.in2:=(marcade.in2 or 1) else marcade.in2:=(marcade.in2 and $fe);
  if arcade_input.but2[1] then marcade.in2:=(marcade.in2 or 2) else marcade.in2:=(marcade.in2 and $fd);
end;
end;

procedure appoooh_principal;
var
  f:byte;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
  for f:=0 to $ff do begin
    eventos_appoooh;
    if f=240 then begin
      if nmi_vblank then z80_0.change_nmi(PULSE_LINE);
      update_video_appoooh;
    end;
    z80_0.run(frame_main);
    frame_main:=frame_main+z80_0.tframes-z80_0.contador;
  end;
  video_sync;
end;
end;

function appoooh_getbyte(direccion:word):byte;
begin
case direccion of
  0..$9fff,$e000..$ffff:appoooh_getbyte:=memoria[direccion];
  $a000..$dfff:appoooh_getbyte:=memoria_rom[rom_bank,direccion-$a000];
end;
end;

procedure appoooh_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$dfff:; //ROM
  $e000..$efff:memoria[direccion]:=valor;
  $f000..$f7ff:if memoria[direccion]<>valor then begin
                  gfx[0].buffer[direccion and $3ff]:=true;
                  memoria[direccion]:=valor;
               end;
  $f800..$ffff:if memoria[direccion]<>valor then begin
                  gfx[1].buffer[direccion and $3ff]:=true;
                  memoria[direccion]:=valor;
               end;
end;
end;

function appoooh_inbyte(puerto:word):byte;
begin
case (puerto and $ff) of
  0:appoooh_inbyte:=marcade.in0;
  1:appoooh_inbyte:=marcade.in1;
  3:appoooh_inbyte:=marcade.dswa;
  4:appoooh_inbyte:=marcade.in2;
end;
end;

procedure appoooh_outbyte(puerto:word;valor:byte);
begin
case (puerto and $ff) of
  0:sn_76496_0.write(valor);
  1:sn_76496_1.write(valor);
  2:sn_76496_2.write(valor);
  3:begin
      msm5205_0.pos:=(valor shl 8)*2;
	    msm5205_0.reset_w(false);
	    adpcm_playing:=true;
    end;
  4:begin
      nmi_vblank:=(valor and 1)<>0;
      main_screen.flip_main_screen:=(valor and 2)<>0;
      if priority<>((valor and $30) shr 4) then begin
        priority:=(valor and $30) shr 4;
        fillchar(gfx[0].buffer,$400,1);
        fillchar(gfx[1].buffer,$400,1);
      end;
      rom_bank:=(valor and $40) shr 6;
    end;
  5:;//scroll_x:=valor-16; Se usa???
end;
end;

procedure snd_adpcm;
begin
	if not(adpcm_playing) then exit;
	msm5205_0.data_val:=msm5205_0.rom_data[msm5205_0.pos div 2];
	if (msm5205_0.data_val=$70) then begin
    msm5205_0.reset_w(true);
		adpcm_playing:=false;
	end else begin
    if (msm5205_0.pos and 1)<>0 then msm5205_0.data_w(msm5205_0.data_val and $f)
      else msm5205_0.data_w(msm5205_0.data_val shr 4);
		msm5205_0.pos:=(msm5205_0.pos+1) and $1ffff;
	end;
end;

procedure appoooh_update_sound;
begin
  sn_76496_0.update;
  sn_76496_1.update;
  sn_76496_2.update;
  msm5205_0.update;
end;

//Robo Wres
function robowres_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff:if z80_0.opcode then robowres_getbyte:=rom_dec[direccion]
              else robowres_getbyte:=memoria[direccion];
  $8000..$9fff,$e000..$ffff:robowres_getbyte:=memoria[direccion];
  $a000..$dfff:robowres_getbyte:=memoria_rom[rom_bank,direccion-$a000];
end;
end;

//Main
procedure appoooh_reset;
begin
z80_0.reset;
frame_main:=z80_0.tframes;
sn_76496_0.reset;
sn_76496_1.reset;
sn_76496_2.reset;
msm5205_0.reset;
marcade.in0:=0;
marcade.in1:=0;
marcade.in2:=0;
nmi_vblank:=false;
adpcm_playing:=false;
//scroll_x:=0;
priority:=$ff;
rom_bank:=0;
end;

function iniciar_appoooh:boolean;
const
      pc_x:array[0..15] of dword=(7, 6, 5, 4, 3, 2, 1, 0 ,
		                              8*8+7,8*8+6,8*8+5,8*8+4,8*8+3,8*8+2,8*8+1,8*8+0);
      pc_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
		                              16*8, 17*8, 18*8, 19*8, 20*8, 21*8, 22*8, 23*8);
var
  memoria_temp:array[0..$2ffff] of byte;
  colores:tpaleta;
  pen,bit0,bit1,bit2:byte;
  f:word;
procedure chars_gfx(ngfx:byte;num:word);
begin
init_gfx(ngfx,8,8,num);
gfx[ngfx].trans[0]:=true;
gfx_set_desc_data(3,0,8*8,num*8*8*2,num*8*8*1,num*8*8*0);
convert_gfx(ngfx,0,@memoria_temp,@pc_x,@pc_y,false,false);
end;
procedure sprites_gfx(ngfx:byte;num:word);
begin
init_gfx(ngfx,16,16,num);
gfx[ngfx].trans[0]:=true;
gfx_set_desc_data(3,0,32*8,num*8*8*2,num*8*8*1,num*8*8*0);
convert_gfx(ngfx,0,@memoria_temp,@pc_x,@pc_y,false,false);
end;
begin
llamadas_maquina.bucle_general:=appoooh_principal;
llamadas_maquina.reset:=appoooh_reset;
llamadas_maquina.fps_max:=60;
llamadas_maquina.scanlines:=256;
iniciar_appoooh:=false;
iniciar_audio(false);
screen_init(1,256,256,true);
screen_init(2,256,256,true);
screen_init(3,256,256,false,true);
iniciar_video(256,224);
//Main CPU
z80_0:=cpu_z80.create(18432000 div 6);
z80_0.change_ram_calls(appoooh_getbyte,appoooh_putbyte);
z80_0.change_io_calls(appoooh_inbyte,appoooh_outbyte);
z80_0.init_sound(appoooh_update_sound);
//Sound Chip
sn_76496_0:=sn76496_chip.Create(18432000 div 6);
sn_76496_1:=sn76496_chip.Create(18432000 div 6);
sn_76496_2:=sn76496_chip.Create(18432000 div 6);
msm5205_0:=MSM5205_chip.create(384000,MSM5205_S64_4B,0.5,$10000);
msm5205_0.change_advance(snd_adpcm);
case main_vars.tipo_maquina of
  364:begin //Appoooh
        if not(roms_load(msm5205_0.rom_data,appoooh_adpcm)) then exit;
        if not(roms_load(@memoria_temp,appoooh_rom)) then exit;
        //Ponerlas en su sitio
        copymemory(@memoria,@memoria_temp,$a000);
        copymemory(@memoria_rom[0,0],@memoria_temp[$a000],$4000);
        copymemory(@memoria_rom[1,0],@memoria_temp[$e000],$4000);
        if not(roms_load(@memoria_temp,appoooh_char1)) then exit;
        chars_gfx(0,$800);
        sprites_gfx(2,$800);
        if not(roms_load(@memoria_temp,appoooh_char2)) then exit;
        chars_gfx(1,$800);
        sprites_gfx(3,$800);
        if not(roms_load(@memoria_temp,appoooh_prom)) then exit;
        sprite_base:=0;
        //DIP
        init_dips(1,appoooh_dip,$60);
      end;
  365:begin //Robo Wres 2001
        z80_0.change_ram_calls(robowres_getbyte,appoooh_putbyte);
        if not(roms_load(msm5205_0.rom_data,robowres_adpcm)) then exit;
        if not(roms_load(@memoria_temp,robowres_rom)) then exit;
        //Ponerlas en su sitio
        decode_sega_type2(@memoria_temp,@rom_dec,S315_5179);
        copymemory(@memoria,@memoria_temp,$a000);
        copymemory(@memoria_rom[0,0],@memoria_temp[$a000],$4000);
        copymemory(@memoria_rom[1,0],@memoria_temp[$12000],$4000);
        if not(roms_load(@memoria_temp,robowres_char1)) then exit;
        chars_gfx(0,$1000);
        sprites_gfx(2,$1000);
        if not(roms_load(@memoria_temp,robowres_char2)) then exit;
        chars_gfx(1,$1000);
        sprites_gfx(3,$1000);
        if not(roms_load(@memoria_temp,robowres_prom)) then exit;
        sprite_base:=$200;
        //DIP
        init_dips(1,robowres_dip,$e0);
      end;
end;
//color
for f:=0 to $1ff do begin
    pen:=(memoria_temp[$20+f] and $f);
    if ((f>$ff) and (main_vars.tipo_maquina=364)) then pen:=pen or $10;
		// red component
		bit0:=(memoria_temp[pen] shr 0) and 1;
		bit1:=(memoria_temp[pen] shr 1) and 1;
		bit2:=(memoria_temp[pen] shr 2) and 1;
		colores[f].r:=$21*bit0+$47*bit1+$97*bit2;
		// green component
		bit0:=(memoria_temp[pen] shr 3) and 1;
		bit1:=(memoria_temp[pen] shr 4) and 1;
		bit2:=(memoria_temp[pen] shr 5) and 1;
		colores[f].g:=$21*bit0+$47*bit1+$97*bit2;
		// blue component
		bit1:=(memoria_temp[pen] shr 6) and 1;
		bit2:=(memoria_temp[pen] shr 7) and 1;
		colores[f].b:=0+$47*bit1+$97*bit2;
end;
set_pal(colores,$200);
//final
iniciar_appoooh:=true;
end;

end.
