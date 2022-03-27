unit suna8_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,timer_engine,ym_3812,ay_8910,
     rom_engine,misc_functions,pal_engine,sound_engine,dac,gfx_engine;

function iniciar_suna_hw:boolean;

implementation

const
        //Hard Head
        hardhead_rom:array[0..7] of tipo_roms=(
        (n:'p1';l:$8000;p:0;crc:$c6147926),(n:'p2';l:$8000;p:$8000;crc:$faa2cf9a),
        (n:'p3';l:$8000;p:$10000;crc:$3d24755e),(n:'p4';l:$8000;p:$18000;crc:$0241ac79),
        (n:'p7';l:$8000;p:$20000;crc:$beba8313),(n:'p8';l:$8000;p:$28000;crc:$211a9342),
        (n:'p9';l:$8000;p:$30000;crc:$2ad430c4),(n:'p10';l:$8000;p:$38000;crc:$b6894517));
        hardhead_sprites:array[0..7] of tipo_roms=(
        (n:'p5';l:$8000;p:$0;crc:$e9aa6fba),(n:'p5';l:$8000;p:$8000;crc:$e9aa6fba),
        (n:'p6';l:$8000;p:$10000;crc:$15d5f5dd),(n:'p6';l:$8000;p:$18000;crc:$15d5f5dd),
        (n:'p11';l:$8000;p:$20000;crc:$055f4c29),(n:'p11';l:$8000;p:$28000;crc:$055f4c29),
        (n:'p12';l:$8000;p:$30000;crc:$9582e6db),(n:'p12';l:$8000;p:$38000;crc:$9582e6db));
        hardhead_dac:tipo_roms=(n:'p14';l:$8000;p:0;crc:$41314ac1);
        hardhead_sound:tipo_roms=(n:'p13';l:$8000;p:0;crc:$493c0b41);
        //Hard Head 2
        hardhead2_rom:array[0..4] of tipo_roms=(
        (n:'hrd-hd9';l:$8000;p:0;crc:$69c4c307),(n:'hrd-hd10';l:$10000;p:$10000;crc:$77ec5b0a),
        (n:'hrd-hd11';l:$10000;p:$20000;crc:$12af8f8e),(n:'hrd-hd12';l:$10000;p:$30000;crc:$35d13212),
        (n:'hrd-hd13';l:$10000;p:$40000;crc:$3225e7d7));
        hardhead2_sprites:array[0..7] of tipo_roms=(
        (n:'hrd-hd1';l:$10000;p:$0;crc:$7e7b7a58),(n:'hrd-hd2';l:$10000;p:$10000;crc:$303ec802),
        (n:'hrd-hd3';l:$10000;p:$20000;crc:$3353b2c7),(n:'hrd-hd4';l:$10000;p:$30000;crc:$dbc1f9c1),
        (n:'hrd-hd5';l:$10000;p:$40000;crc:$f738c0af),(n:'hrd-hd6';l:$10000;p:$50000;crc:$bf90d3ca),
        (n:'hrd-hd7';l:$10000;p:$60000;crc:$992ce8cb),(n:'hrd-hd8';l:$10000;p:$70000;crc:$359597a4));
        hardhead2_pcm:tipo_roms=(n:'hrd-hd15';l:$10000;p:0;crc:$bcbd88c3);
        hardhead2_sound:tipo_roms=(n:'hrd-hd14';l:$8000;p:0;crc:$79a3be51);
        //DIPS
        hardhead_dip_a:array [0..4] of def_dip=(
        (mask:$1;name:'Demo Sounds';number:2;dip:((dip_val:$1;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$e;name:'Bonus Life';number:8;dip:((dip_val:$e;dip_name:'No Bonus'),(dip_val:$c;dip_name:'10K'),(dip_val:$a;dip_name:'20K'),(dip_val:$8;dip_name:'50K'),(dip_val:$6;dip_name:'50K+'),(dip_val:$4;dip_name:'100K 50K+'),(dip_val:$2;dip_name:'100K 100K+'),(dip_val:$0;dip_name:'200K 100K+'),(),(),(),(),(),(),(),())),
        (mask:$70;name:'Coinage';number:8;dip:((dip_val:$0;dip_name:'5C 1C'),(dip_val:$10;dip_name:'4C 1C'),(dip_val:$20;dip_name:'3C 1C'),(dip_val:$30;dip_name:'2C 1C'),(dip_val:$70;dip_name:'1C 1C'),(dip_val:$60;dip_name:'1C 2C'),(dip_val:$50;dip_name:'1C 3C'),(dip_val:$40;dip_name:'1C 4C'),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Invulnerability';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        hardhead_dip_b:array [0..5] of def_dip=(
        (mask:$1;name:'Flip Screen';number:2;dip:((dip_val:$1;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2;name:'Cabinet';number:2;dip:((dip_val:$2;dip_name:'Upright'),(dip_val:$0;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Play Together';number:2;dip:((dip_val:$0;dip_name:'No'),(dip_val:$4;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$18;name:'Lives';number:4;dip:((dip_val:$18;dip_name:'2'),(dip_val:$10;dip_name:'3'),(dip_val:$8;dip_name:'4'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$e0;name:'Difficulty';number:8;dip:((dip_val:$e0;dip_name:'Easiest'),(dip_val:$c0;dip_name:'Very Easy'),(dip_val:$a0;dip_name:'Easy'),(dip_val:$80;dip_name:'Moderate'),(dip_val:$60;dip_name:'Normal'),(dip_val:$40;dip_name:'Harder'),(dip_val:$20;dip_name:'Very Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),())),());
        hardhead2_dip_a:array [0..3] of def_dip=(
        (mask:$7;name:'Coinage';number:8;dip:((dip_val:$0;dip_name:'5C 1C'),(dip_val:$1;dip_name:'4C 1C'),(dip_val:$2;dip_name:'3C 1C'),(dip_val:$3;dip_name:'2C 1C'),(dip_val:$7;dip_name:'1C 1C'),(dip_val:$6;dip_name:'1C 2C'),(dip_val:$5;dip_name:'1C 3C'),(dip_val:$4;dip_name:'1C 4C'),(),(),(),(),(),(),(),())),
        (mask:$38;name:'Difficulty';number:8;dip:((dip_val:$38;dip_name:'Easiest'),(dip_val:$30;dip_name:'Very Easy'),(dip_val:$28;dip_name:'Easy'),(dip_val:$20;dip_name:'Moderate'),(dip_val:$18;dip_name:'Normal'),(dip_val:$10;dip_name:'Harder'),(dip_val:$8;dip_name:'Very Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Demo Sounds';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        hardhead2_dip_b:array [0..5] of def_dip=(
        (mask:$1;name:'Flip Screen';number:2;dip:((dip_val:$1;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2;name:'Cabinet';number:2;dip:((dip_val:$2;dip_name:'Upright'),(dip_val:$0;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Play Together';number:2;dip:((dip_val:$0;dip_name:'No'),(dip_val:$4;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$38;name:'Bonus Life';number:8;dip:((dip_val:$38;dip_name:'No Bonus'),(dip_val:$30;dip_name:'10K'),(dip_val:$28;dip_name:'30K'),(dip_val:$18;dip_name:'50K 50K+'),(dip_val:$20;dip_name:'50K'),(dip_val:$10;dip_name:'100K 50K+'),(dip_val:$8;dip_name:'100K 100K+'),(dip_val:$0;dip_name:'200K 100K+'),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Lives';number:4;dip:((dip_val:$80;dip_name:'2'),(dip_val:$c0;dip_name:'3'),(dip_val:$40;dip_name:'4'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),());
var
 rom_bank:array[0..$f,0..$3fff] of byte;
 suna_dac:array[0..$ffff] of smallint;
 mem_opcodes:array[0..$7fff] of byte;
 ram_bank:array[0..1,0..$17ff] of byte;
 sprite_bank:array[0..$3fff] of byte;
 banco_rom,banco_sprite,banco_ram:byte;
 soundlatch,soundlatch2,protection_val,hardhead_ip,vblank:byte;
 haz_nmi:boolean;
 dac_timer,dac_tsample:byte;
 //DAC
 dac_play,dac_sample,dac_index:byte;
 dac_value:smallint;
 dac_pos:word;

//Hard Head
procedure update_video_hardhead;inline;
var
  x,y,nchar,bank:word;
  f,ty,tx:byte;
  real_ty,addr:word;
  dimy,srcx,srcy,srcpg:word;
  mx:word;
  atrib,color:word;
  flipx,flipy:boolean;
  sx,sy:word;
begin
fill_full_screen(1,$ff);
//primero sprites
mx:=0;
for f:=0 to $bf do begin
		y:=memoria[$fd00+(f shl 2)];
		nchar:=memoria[$fd01+(f shl 2)];
		x:=memoria[$fd02+(f shl 2)];
		bank:=memoria[$fd03+(f shl 2)];
    srcx:=(nchar and $f) shl 1;
		if (nchar and $80)=$80 then begin
      dimy:=32;
      srcy:=0;
      srcpg:=(nchar shr 4) and 3;
    end else begin
      dimy:=2;
      srcy:=(((nchar shr 5) and $3) shl 3)+6;
      srcpg:=(nchar shr 4) and 1;
    end;
    if (bank and $40)<>0 then x:=x-$100;
		y:=($100-y-(dimy shl 3)) and $ff;
		// Multi Sprite
    if ((nchar and $c0)=$c0) then begin
      mx:=mx+$10;
      x:=mx;
		end else begin
      mx:=x;
    end;
    bank:=(bank and $3f) shl 10;
		for ty:=0 to dimy-1 do begin
			for tx:=0 to 1 do begin
				addr:=((srcpg shl 10)+(((srcx+tx) and $1f) shl 5)+((srcy+ty) and $1f)) shl 1;
        atrib:=memoria[addr+$e001];
        nchar:=memoria[addr+$e000]+((atrib and $3) shl 8)+bank;
        color:=(atrib and $3c) shl 2;
        flipx:=(atrib and $40)<>0;
        flipy:=(atrib and $80)<>0;
        sx:=x+(tx shl 3);
        sy:=y+(ty shl 3);
        put_gfx_sprite(nchar,color,flipx,flipy,0);
        actualiza_gfx_sprite(sx,sy,1,0);
			end;
		end;
end;
//por ultimo char sprites
for f:=0 to $3f do begin
    nchar:=memoria[$f901+(f shl 2)];
    if (not(nchar) and $80)<>0 then continue;
		y:=memoria[$f900+(f shl 2)];
		x:=memoria[$f902+(f shl 2)];
		bank:=memoria[$f903+(f shl 2)];
		srcx:=(nchar and $f) shl 1;
    srcy:=(y and $f0) shr 3;
		srcpg:=(nchar shr 4) and 3;
    if (bank and $40)<>0 then x:=x-$100;
		bank:=(bank and $3f) shl 10;
		for ty:=0 to 11 do begin
			for tx:=0 to 2 do begin
        if (ty<6) then real_ty:=ty
          else real_ty:=ty+$14;
        addr:=((srcpg shl 10)+(((srcx+tx) and $1f) shl 5)+((srcy+real_ty) and $1f)) shl 1;
        atrib:=memoria[addr+$e001];
				nchar:=memoria[addr+$e000]+((atrib and $3) shl 8)+bank;
        color:=(atrib and $3c) shl 2;
				flipx:=(atrib and $40)<>0;
				flipy:=(atrib and $80)<>0;
				sx:=x+(tx shl 3);
				sy:=real_ty shl 3;
        put_gfx_sprite(nchar,color,flipx,flipy,0);
        actualiza_gfx_sprite(sx,sy,1,0);
			end;
		end;
end;
actualiza_trozo_final(0,16,256,224,1);
end;

procedure eventos_suna_hw;
begin
if event.arcade then begin
  //P1
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  //P2
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or 8);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  if arcade_input.coin[1] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
end;
end;

procedure hardhead_principal;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=z80_0.tframes;
frame_s:=z80_1.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to $ff do begin
    //Main CPU
    z80_0.run(frame_m);
    frame_m:=frame_m+z80_0.tframes-z80_0.contador;
    //Sound CPU
    z80_1.run(frame_s);
    frame_s:=frame_s+z80_1.tframes-z80_1.contador;
    if f=239 then begin
      z80_0.change_irq(HOLD_LINE);
      update_video_hardhead;
    end;
 end;
  eventos_suna_hw;
  video_sync;
end;
end;

function hardhead_getbyte(direccion:word):byte;
var
  res_prot:byte;
begin
case direccion of
  0..$7fff,$c000..$d7ff,$e000..$ffff:hardhead_getbyte:=memoria[direccion];
  $8000..$bfff:hardhead_getbyte:=rom_bank[banco_rom,(direccion and $3fff)];
  $d800..$d9ff:hardhead_getbyte:=buffer_paleta[direccion and $1ff];
  $da00:case hardhead_ip of
          0:hardhead_getbyte:=marcade.in0;
          1:hardhead_getbyte:=marcade.in1;
          2:hardhead_getbyte:=marcade.dswa;
          3:hardhead_getbyte:=marcade.dswb;
        end;
  $da80:hardhead_getbyte:=soundlatch2;
  $dd80..$ddff:begin  //proteccion
                  if (not(direccion) and $20)<>0 then res_prot:=$20
                      else res_prot:=0;
                  if (protection_val and $80)<>0 then begin
                    if (protection_val and $4)<>0 then res_prot:=res_prot or $80;
                    if (protection_val and $1)<>0 then res_prot:=res_prot or $4;
                  end else begin
                    if ((direccion xor protection_val) and $1)<>0 then res_prot:=res_prot or $84;
                  end;
                  hardhead_getbyte:=res_prot;
               end;
end;
end;

procedure cambiar_color(dir:word);
var
  tmp_color:byte;
  color:tcolor;
begin
  tmp_color:=buffer_paleta[dir];
  color.r:=pal4bit(tmp_color shr 4);
  color.g:=pal4bit(tmp_color);
  tmp_color:=buffer_paleta[dir+1];
  color.b:=pal4bit(tmp_color shr 4);
  set_pal_color(color,dir shr 1);
end;

procedure hardhead_putbyte(direccion:word;valor:byte);
begin
case direccion of
    0..$bfff:;
    $c000..$d7ff,$e000..$ffff:memoria[direccion]:=valor;
    $d800..$d9ff:if buffer_paleta[direccion and $1ff]<>valor then begin
                    buffer_paleta[direccion and $1ff]:=valor;
                    cambiar_color(direccion and $1fe);
                 end;
    $da00:hardhead_ip:=valor;
    $da80:banco_rom:=valor and $f;
    $db00:soundlatch:=valor;
    $db80:main_screen.flip_main_screen:=(valor and 4)<>0;
    $dd80..$ddff:if (valor and $80)<>0 then	protection_val:=valor //proteccion
                    else protection_val:=direccion and 1;
end;
end;

function hardhead_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff,$c000..$c7ff:hardhead_snd_getbyte:=mem_snd[direccion];
  $a000:hardhead_snd_getbyte:=ym3812_0.read;
  $c800:hardhead_snd_getbyte:=ym3812_0.status;
  $d800:hardhead_snd_getbyte:=soundlatch;
end;
end;

procedure hardhead_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:;
  $a000:ym3812_0.control(valor);
  $a001:ym3812_0.write(valor);
  $a002:ay8910_0.control(valor);
  $a003:ay8910_0.write(valor);
  $c000..$c7ff:mem_snd[direccion]:=valor;
  $d000:soundlatch2:=valor;
end;
end;

procedure hardhead_play_sound;
begin
  ym3812_0.update;
  ay8910_0.update;
  tsample[dac_tsample,sound_status.posicion_sonido]:=dac_value;
end;

procedure hardhead_snd;
begin
  z80_1.change_irq(HOLD_LINE);
end;

procedure hardhead_portaw(valor:byte);
begin
  // At boot: ff (ay reset) -> 00 (game writes ay enable) -> f9 (game writes to port A).
	// Then game writes f9 -> f1 -> f9. Is bit 3 stop/reset?
	if ((dac_play=$e9) and (valor=$f9)) then begin
		dac_index:=dac_sample and $f;
    dac_pos:=0;
    timers.enabled(dac_timer,true);
  end	else if ((dac_play=$b9) and (valor=$f9)) then begin // second sample rom
		dac_index:=((dac_sample shr 4) and $f)+$10;
    dac_pos:=0;
    timers.enabled(dac_timer,true);
  end;
	dac_play:=valor;
end;

procedure hardhead_portbw(valor:byte);
begin
  dac_sample:=valor;
end;

procedure dac_sound;
begin
  dac_value:=suna_dac[dac_pos+dac_index*$1000];
  dac_pos:=dac_pos+1;
  if dac_pos=$1000 then begin
    timers.enabled(dac_timer,false);
    dac_value:=0;
  end;
end;

//Hard Head 2
procedure update_video_hardhead2;
var
  bank,code,sy,y,dimx,dimy,f,ty,tx,attr,srcx,srcy,srcpg:byte;
  gfxbank,nchar,addr,colorbank,sx,x,mx,color:word;
  flipx,flipy,multisprite,tile_flipx,tile_flipy:boolean;
begin
  mx:=0;
  fill_full_screen(1,$ff);
	for f:=0 to $bf do begin
    colorbank:=0;
		y:=sprite_bank[$1d00+(f*4)];
		code:=sprite_bank[$1d01+(f*4)];
		x:=sprite_bank[$1d02+(f*4)];
		bank:=sprite_bank[$1d03+(f*4)];
    flipx:=false;
    flipy:=false;
    case (code and $c0) of
			$c0:begin
    				dimx:=4;
            dimy:=32;
    				srcx:=(code and $e)*2;
            srcy:=0;
    				flipx:=(code and $1)<>0;
    				gfxbank:=bank and $1f;
    				srcpg:=(code shr 4) and 3;
				  end;
			$80:begin
    				dimx:=2;
            dimy:=32;
    				srcx:=(code and $f)*2;
            srcy:=0;
    				gfxbank:=bank and $1f;
    				srcpg:=(code shr 4) and 3;
          end;
// hardhea2: fire code=52/54 bank=a4; player code=02/04/06 bank=08; arrow:code=16 bank=27
			$40:begin
    				dimx:=4;
            dimy:=4;
    				srcx:=(code and $e)*2;
    				flipx:=(code and $01)<>0;
    				flipy:=(bank and $10)<>0;
    				srcy:=(((bank and $80) shr 4)+(bank and $04)+((not(bank) shr 4) and 2))*2;
    				srcpg:=((code shr 4) and 3)+4;
    				gfxbank:=bank and $3;
            gfxbank:=gfxbank+4;   // brickzn: 06,a6,a2,b2->6
    				colorbank:=(bank and 8) shr 3;
				  end;
			else begin
    				dimx:=2;
            dimy:=2;
    				srcx:=(code and $f)*2;
    				srcy:=(((bank and $80) shr 4)+(bank and $04)+((not(bank) shr 4) and 3))*2;
    				srcpg:=(code shr 4) and 3;
            gfxbank:=bank and $03;
          end;
			end;
			multisprite:=(((code and $80)<>0) and ((bank and $80)<>0));
      if (bank and $40)<>0 then x:=x-$100;
  		y:=($100-y-dimy*8) and $ff;
  		// Multi Sprite
  		if multisprite then	begin
      	mx:=mx+dimx*8;
        x:=mx;
      end else mx:=x;
  		gfxbank:=gfxbank*$400;
  		for ty:=0 to dimy-1 do begin
  			for tx:=0 to dimx-1 do begin
  				addr:=srcpg*$20*$20;
          if flipx then addr:=addr+((srcx+(dimx-tx-1)) and $1f)*$20
            else addr:=addr+((srcx+tx) and $1f)*$20;
          if flipy then addr:=addr+((srcy+(dimy-ty-1)) and $1f)
            else addr:=addr+((srcy+ty) and $1f);
          attr:=sprite_bank[addr*2+1];
  				tile_flipx:=(attr and $40)<>0;
	  			tile_flipy:=(attr and $80)<>0;
				  sx:=x+tx*8;
			  	sy:=(y+ty*8) and $ff;
  				if (flipx) then	tile_flipx:=not(tile_flipx);
	  			if (flipy) then	tile_flipy:=not(tile_flipy);
          color:=(((attr shr 2) and $f) xor colorbank);//+$10*palettebank;
          nchar:=sprite_bank[addr*2+0]+(attr and $3)*$100+gfxbank;
          put_gfx_sprite(nchar,color shl 4,tile_flipx,tile_flipy,0);
          actualiza_gfx_sprite(sx,sy,1,0);
        end;
     end;
  end;
actualiza_trozo_final(0,16,256,224,1);
end;

procedure hardhead2_principal;
var
  frame_m,frame_s,frame_dac:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=z80_0.tframes;
frame_s:=z80_1.tframes;
frame_dac:=z80_2.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to 255 do begin
    //Main CPU
    z80_0.run(frame_m);
    frame_m:=frame_m+z80_0.tframes-z80_0.contador;
    //Sound CPU
    z80_1.run(frame_s);
    frame_s:=frame_s+z80_1.tframes-z80_1.contador;
    //Sound DAC
    z80_2.run(frame_dac);
    frame_dac:=frame_dac+z80_2.tframes-z80_2.contador;
    case f of
        22:vblank:=0;
        111:if haz_nmi then z80_0.change_nmi(PULSE_LINE);
        239:begin
              z80_0.change_irq(HOLD_LINE);
              update_video_hardhead2;
              vblank:=$40;
            end;
    end;
 end;
  eventos_suna_hw;
  video_sync;
end;
end;

function hardhead2_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff:if z80_0.opcode then hardhead2_getbyte:=mem_opcodes[direccion]
              else hardhead2_getbyte:=memoria[direccion];
  $8000..$bfff:hardhead2_getbyte:=rom_bank[banco_rom,direccion and $3fff];
  $c000:hardhead2_getbyte:=marcade.in0;
  $c001:hardhead2_getbyte:=marcade.in1;
  $c002:hardhead2_getbyte:=marcade.dswa;
  $c003:hardhead2_getbyte:=marcade.dswb;
  $c080:hardhead2_getbyte:=$bf or vblank;
  $c600..$c7ff:hardhead2_getbyte:=buffer_paleta[direccion-$c600];
  $c800..$dfff:hardhead2_getbyte:=ram_bank[banco_ram,direccion-$c800];
  $e000..$ffff:hardhead2_getbyte:=sprite_bank[banco_sprite*$2000+(direccion and $1fff)];
end;
end;

procedure hardhead2_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$bfff:;
  $c200:banco_sprite:=(valor shr 1) and 1;
  $c280,$c28c:banco_rom:=valor and $f;
  $c300:main_screen.flip_main_screen:=(valor and 1)<>0;
  $c380:haz_nmi:=(valor and 1)<>0;
  $c400:; //leds
  $c500:soundlatch:=valor;
  $c507,$c556,$c560:banco_ram:=1;
  $c508:banco_sprite:=0;
  $c522,$c528,$c533:banco_ram:=0;
  $c50f:banco_sprite:=1;
  $c600..$c7ff:begin
                  direccion:=direccion-$c600;
                  if buffer_paleta[direccion]<>valor then begin
                    buffer_paleta[direccion]:=valor;
                    cambiar_color(direccion and $1fe);
                  end;
               end;
  $c800..$dfff:ram_bank[banco_ram,direccion-$c800]:=valor;
  $e000..$ffff:sprite_bank[banco_sprite*$2000+(direccion and $1fff)]:=valor;
end;
end;

function hardhead2_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$bfff,$e000..$e7ff:hardhead2_snd_getbyte:=mem_snd[direccion];
  $f800:hardhead2_snd_getbyte:=soundlatch;
end;
end;

procedure hardhead2_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$bfff:;
  $c000:ym3812_0.control(valor);
  $c001:ym3812_0.write(valor);
  $c002:ay8910_0.control(valor);
  $c003:ay8910_0.write(valor);
  $e000..$e7ff:mem_snd[direccion]:=valor;
  $f000:soundlatch2:=valor;
end;
end;

function hardhead2_dac_getbyte(direccion:word):byte;
begin
hardhead2_dac_getbyte:=mem_misc[direccion];
end;

procedure hardhead2_dac_putbyte(direccion:word;valor:byte);
begin
end;

function hardhead2_dac_inbyte(puerto:word):byte;
begin
  if (puerto and $ff)=0 then hardhead2_dac_inbyte:=soundlatch2;
end;

procedure hardhead2_dac_outbyte(puerto:word;valor:byte);
begin
  case (puerto and $ff) of
    0:dac_0.data8_w(valor);
    1:dac_1.data8_w(valor);
    2:dac_2.data8_w(valor);
    3:dac_3.data8_w(valor);
  end;
end;

procedure hardhead2_snd(status:byte);
begin
  z80_1.change_irq(status);
end;

procedure hardhead2_play_sound;
begin
  ym3812_0.update;
  ay8910_0.update;
  dac_0.update;
  dac_1.update;
  dac_2.update;
  dac_3.update;
end;

//Main
procedure reset_suna_hw;
begin
 z80_0.reset;
 z80_1.reset;
 ay8910_0.reset;
 ym3812_0.reset;
 if main_vars.tipo_maquina=68 then begin
   dac_0.reset;
   dac_1.reset;
   dac_2.reset;
   dac_3.reset;
 end;
 reset_audio;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 banco_rom:=0;
 soundlatch:=0;
 soundlatch2:=0;
 hardhead_ip:=0;
 dac_sample:=0;
 dac_play:=0;
 dac_value:=0;
 dac_index:=0;
 dac_pos:=0;
 banco_sprite:=0;
 banco_ram:=0;
 haz_nmi:=false;
 vblank:=0;
end;

function iniciar_suna_hw:boolean;
const
  pc_x:array[0..7] of dword=(3,2,1,0,11,10,9,8);
  pc_y:array[0..7] of dword=(0*16,1*16,2*16,3*16,4*16,5*16,6*16,7*16);
  swaptable_hh:array[0..7] of byte=(1,1,0,1,1,1,1,0);
  swaptable_data_hh2:array[0..7] of byte=(1,1,0,1,0,1,1,0);
  swaptable_lines_hh2:array[0..79] of byte=(
			1,1,1,1,0,0,1,1,    0,0,0,0,0,0,0,0,    // 8000-ffff not used
			1,1,0,0,0,0,0,0,0,0,0,0,1,1,0,0,
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
			1,1,0,0,0,0,0,0,1,1,0,0,1,1,0,0);
  swaptable_opcodes_hh2:array[0..31] of byte=(
			1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,
			1,1,0,1,1,1,1,1,1,1,1,1,0,1,0,0);
	xortable_hh2:array[0..31] of byte=(
			$04,$04,$00,$04,$00,$04,$00,$00,$04,$45,$00,$04,$00,$04,$00,$00,
			$04,$45,$00,$04,$00,$04,$00,$00,$04,$04,$00,$04,$00,$04,$00,$00);
var
  f,addr:dword;
  valor,table:byte;
  mem_final:array[0..$4ffff] of byte;
  memoria_temp:array[0..$7ffff] of byte;
begin
llamadas_maquina.reset:=reset_suna_hw;
iniciar_suna_hw:=false;
iniciar_audio(false);
screen_init(1,512,512,false,true);
iniciar_video(256,224);
case main_vars.tipo_maquina of
  67:begin
        llamadas_maquina.bucle_general:=hardhead_principal;
        llamadas_maquina.fps_max:=59.1;
        //Main CPU
        z80_0:=cpu_z80.create(6000000,256);
        z80_0.change_ram_calls(hardhead_getbyte,hardhead_putbyte);
        //Sound CPU
        z80_1:=cpu_z80.create(3000000,256);
        z80_1.change_ram_calls(hardhead_snd_getbyte,hardhead_snd_putbyte);
        z80_1.init_sound(hardhead_play_sound);
        timers.init(z80_1.numero_cpu,3000000/(60*4),hardhead_snd,nil,true);
        //sound chips
        ym3812_0:=ym3812_chip.create(YM3812_FM,3000000);
        ay8910_0:=ay8910_chip.create(1500000,AY8910,0.8);
        ay8910_0.change_io_calls(nil,nil,hardhead_portaw,hardhead_portbw);
        //Y para el DAC 8Khz
        dac_timer:=timers.init(z80_1.numero_cpu,3000000/8000,dac_sound,nil,false);
        //cargar roms y rom en bancos
        if not(roms_load(@memoria_temp,hardhead_rom)) then exit;
        for f:=0 to $f do copymemory(@rom_bank[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
        for f:=0 to $7fff do begin
        		table:=((f and $0c00) shr 10) or ((f and $4000) shr 12);
        		if (swaptable_hh[table])<>0 then memoria[f]:=BITSWAP8(memoria_temp[f],7,6,5,3,4,2,1,0) xor $58
              else memoria[f]:=memoria_temp[f];
        end;
        //cargar sonido
        if not(roms_load(@mem_snd,hardhead_sound)) then exit;
        if not(roms_load(@memoria_temp,hardhead_dac)) then exit;
        //Convierto los samples
        for f:=0 to $7fff do begin
          suna_dac[f*2]:=shortint((((memoria_temp[f] and $f) shl 4) xor $80))*$100;
          suna_dac[(f*2)+1]:=shortint(((memoria_temp[f] and $f0) xor $80))*$100;
        end;
        dac_tsample:=init_channel;
        //convertir sprites e invertirlos, solo hay sprites!!
        if not(roms_load(@memoria_temp,hardhead_sprites)) then exit;
        for f:=0 to $3ffff do memoria_temp[f]:=not(memoria_temp[f]);
        init_gfx(0,8,8,$2000);
        gfx[0].trans[15]:=true;
        gfx_set_desc_data(4,0,8*8*2,$20000*8+0,$20000*8+4,0,4);
        convert_gfx(0,0,@memoria_temp,@pc_x,@pc_y,false,false);
        //DIP
        marcade.dswa:=$fc;
        marcade.dswb:=$77;
        marcade.dswa_val:=@hardhead_dip_a;
        marcade.dswb_val:=@hardhead_dip_b;
     end;
     68:begin
        llamadas_maquina.bucle_general:=hardhead2_principal;
        //Main CPU
        z80_0:=cpu_z80.create(6000000,256);
        z80_0.change_ram_calls(hardhead2_getbyte,hardhead2_putbyte);
        //Sound CPU
        z80_1:=cpu_z80.create(6000000,256);
        z80_1.change_ram_calls(hardhead2_snd_getbyte,hardhead2_snd_putbyte);
        z80_1.init_sound(hardhead2_play_sound);
        //cargar sonido
        if not(roms_load(@mem_snd,hardhead2_sound)) then exit;
        //DAC CPU
        z80_2:=cpu_z80.create(6000000,256);
        z80_2.change_ram_calls(hardhead2_dac_getbyte,hardhead2_dac_putbyte);
        z80_2.change_io_calls(hardhead2_dac_inbyte,hardhead2_dac_outbyte);
        if not(roms_load(@mem_misc,hardhead2_pcm)) then exit;
        //sound chips
        ym3812_0:=ym3812_chip.create(YM3812_FM,3000000);
        ym3812_0.change_irq_calls(hardhead2_snd);
        ay8910_0:=ay8910_chip.create(1500000,AY8910,0.3);
        dac_0:=dac_chip.create(1);
        dac_1:=dac_chip.create(1);
        dac_2:=dac_chip.create(1);
        dac_3:=dac_chip.create(1);
        //cargar roms
        if not(roms_load(@memoria_temp,hardhead2_rom)) then exit;
        //desencriptarlas
        //Primero muevo los datos a su sitio
        copymemory(@mem_final,@memoria_temp,$50000);
        for f:=0 to $4ffff do begin
            addr:=f;
        		if (swaptable_lines_hh2[(f and $ff000) shr 12])<>0 then
        			addr:=(addr and $f0000) or BITSWAP16(addr,15,14,13,12,11,10,9,8,6,7,5,4,3,2,1,0);
        		memoria_temp[f]:=mem_final[addr];
        end;
        //Pongo los bancos ROM
        for f:=0 to $f do copymemory(@rom_bank[f,0],@memoria_temp[$10000+(f*$4000)],$4000);
        //Y ahora desencripto los opcodes
        for f:=0 to $7fff do begin
      		table:=(f and 1) or ((f and $400) shr 9) or ((f and $7000) shr 10);
      		valor:=memoria_temp[f];
      		valor:=BITSWAP8(valor,7,6,5,3,4,2,1,0) xor $41 xor xortable_hh2[table];
      		if (swaptable_opcodes_hh2[table])<>0 then valor:=BITSWAP8(valor,5,6,7,4,3,2,1,0);
      		mem_opcodes[f]:=valor;
        end;
        //Y despues los datos
        for f:=0 to $7fff do begin
		      if (swaptable_data_hh2[(f and $7000) shr 12])<>0 then memoria[f]:=BITSWAP8(memoria_temp[f],5,6,7,4,3,2,1,0) xor $41
            else memoria[f]:=memoria_temp[f];
        end;
        //convertir sprites e invertirlos, solo hay sprites!!
        if not(roms_load(@memoria_temp,hardhead2_sprites)) then exit;
        for f:=0 to $7ffff do memoria_temp[f]:=not(memoria_temp[f]);
        init_gfx(0,8,8,$4000);
        gfx[0].trans[15]:=true;
        gfx_set_desc_data(4,0,8*8*2,$40000*8+0,$40000*8+4,0,4);
        convert_gfx(0,0,@memoria_temp,@pc_x,@pc_y,false,false);
        //DIP
        marcade.dswa:=$5f;
        marcade.dswb:=$F7;
        marcade.dswa_val:=@hardhead2_dip_a;
        marcade.dswb_val:=@hardhead2_dip_b;
     end;
end;
//final
reset_suna_hw;
iniciar_suna_hw:=true;
end;

end.
