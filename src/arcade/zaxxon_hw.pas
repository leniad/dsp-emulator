unit zaxxon_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,gfx_engine,rom_engine,
     pal_engine,sound_engine,sn_76496,timer_engine,ppi8255,samples;

procedure cargar_zaxxon;

implementation
const
        //Congo
        congo_rom:array[0..4] of tipo_roms=(
        (n:'congo_rev_c_rom1.u21';l:$2000;p:0;crc:$09355b5b),(n:'congo_rev_c_rom2a.u22';l:$2000;p:$2000;crc:$1c5e30ae),
        (n:'congo_rev_c_rom3.u23';l:$2000;p:$4000;crc:$5ee1132c),(n:'congo_rev_c_rom4.u24';l:$2000;p:$6000;crc:$5332b9bf),());
        congo_pal:array[0..2] of tipo_roms=(
        (n:'mr019.u87';l:$100;p:0;crc:$b788d8ae),(n:'mr019.u87';l:$100;p:$100;crc:$b788d8ae),());
        congo_char:tipo_roms=(n:'tip_top_rom_5.u76';l:$1000;p:0;crc:$7bf6ba2b);
        congo_bg:array[0..3] of tipo_roms=(
        (n:'tip_top_rom_8.u93';l:$2000;p:0;crc:$db99a619),(n:'tip_top_rom_9.u94';l:$2000;p:$2000;crc:$93e2309e),
        (n:'tip_top_rom_10.u95';l:$2000;p:$4000;crc:$f27a9407),());
        congo_sprites:array[0..6] of tipo_roms=(
        (n:'tip_top_rom_12.u78';l:$2000;p:0;crc:$15e3377a),(n:'tip_top_rom_13.u79';l:$2000;p:$2000;crc:$1d1321c8),
        (n:'tip_top_rom_11.u77';l:$2000;p:$4000;crc:$73e2709f),(n:'tip_top_rom_14.u104';l:$2000;p:$6000;crc:$bf9169fe),
        (n:'tip_top_rom_16.u106';l:$2000;p:$8000;crc:$cb6d5775),(n:'tip_top_rom_15.u105';l:$2000;p:$a000;crc:$7b15a7a4),());
        congo_sound:tipo_roms=(n:'tip_top_rom_17.u19';l:$2000;p:0;crc:$5024e673);
        congo_tilemap:array[0..2] of tipo_roms=(
        (n:'congo6.u57';l:$2000;p:0;crc:$d637f02b),(n:'congo7.u58';l:$2000;p:$2000;crc:$80927943),());
        num_samples_congo=5;
        congo_samples:array[0..(num_samples_congo-1)] of tipo_nombre_samples=(
        (nombre:'gorilla.wav';restart:true),(nombre:'bass.wav'),(nombre:'congal.wav'),(nombre:'congah.wav'),(nombre:'rim.wav'));
        congo_dip_a:array [0..5] of def_dip=(
        (mask:$3;name:'Bonus Life';number:4;dip:((dip_val:$3;dip_name:'10000'),(dip_val:$1;dip_name:'20000'),(dip_val:$2;dip_name:'30000'),(dip_val:$0;dip_name:'40000'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Difficulty';number:4;dip:((dip_val:$c;dip_name:'Easy'),(dip_val:$4;dip_name:'Medium'),(dip_val:$8;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Lives';number:4;dip:((dip_val:$30;dip_name:'3'),(dip_val:$10;dip_name:'4'),(dip_val:$20;dip_name:'5'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Sound';number:2;dip:((dip_val:$40;dip_name:'On'),(dip_val:$0;dip_name:'Off'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$80;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        //Zaxxon
        zaxxon_rom:array[0..3] of tipo_roms=(
        (n:'zaxxon3.u27';l:$2000;p:0;crc:$6e2b4a30),(n:'zaxxon2.u28';l:$2000;p:$2000;crc:$1c9ea398),
        (n:'zaxxon1.u29';l:$1000;p:$4000;crc:$1c123ef9),());
        zaxxon_pal:array[0..2] of tipo_roms=(
        (n:'zaxxon.u98';l:$100;p:0;crc:$6cc6695b),(n:'zaxxon.u72';l:$100;p:$100;crc:$deaa21f7),());
        zaxxon_char:array[0..2] of tipo_roms=(
        (n:'zaxxon14.u68';l:$800;p:0;crc:$07bf8c52),(n:'zaxxon15.u69';l:$800;p:$800;crc:$c215edcb),());
        zaxxon_bg:array[0..3] of tipo_roms=(
        (n:'zaxxon6.u113';l:$2000;p:0;crc:$6e07bb68),(n:'zaxxon5.u112';l:$2000;p:$2000;crc:$0a5bce6a),
        (n:'zaxxon4.u111';l:$2000;p:$4000;crc:$a5bf1465),());
        zaxxon_sprites:array[0..3] of tipo_roms=(
        (n:'zaxxon11.u77';l:$2000;p:0;crc:$eaf0dd4b),(n:'zaxxon12.u78';l:$2000;p:$2000;crc:$1c5369c7),
        (n:'zaxxon13.u79';l:$2000;p:$4000;crc:$ab4e8a9a),());
        zaxxon_sound:tipo_roms=(n:'tip_top_rom_17.u19';l:$2000;p:0;crc:$5024e673);
        zaxxon_tilemap:array[0..4] of tipo_roms=(
        (n:'zaxxon8.u91';l:$2000;p:0;crc:$28d65063),(n:'zaxxon7.u90';l:$2000;p:$2000;crc:$6284c200),
        (n:'zaxxon10.u93';l:$2000;p:$4000;crc:$a95e61fd),(n:'zaxxon9.u92';l:$2000;p:$6000;crc:$7e42691f),());
        num_samples_zaxxon=12;
        zaxxon_samples:array[0..(num_samples_zaxxon-1)] of tipo_nombre_samples=(
        (nombre:'03.wav';restart:false),(nombre:'02.wav';restart:true),(nombre:'01.wav';restart:true),
        (nombre:'00.wav';restart:true),(nombre:'11.wav';restart:true),(nombre:'10.wav';restart:true),
        (nombre:'08.wav';restart:true),(nombre:'23.wav';restart:true),(nombre:'21.wav';restart:true),
        (nombre:'20.wav';restart:true),(nombre:'05.wav';restart:true),(nombre:'04.wav';restart:true));
        //DIP
        zaxxon_dip_a:array [0..4] of def_dip=(
        (mask:$3;name:'Bonus Life';number:4;dip:((dip_val:$3;dip_name:'10000'),(dip_val:$1;dip_name:'20000'),(dip_val:$2;dip_name:'30000'),(dip_val:$0;dip_name:'40000'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Lives';number:4;dip:((dip_val:$30;dip_name:'3'),(dip_val:$10;dip_name:'4'),(dip_val:$20;dip_name:'5'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Sound';number:2;dip:((dip_val:$40;dip_name:'On'),(dip_val:$0;dip_name:'Off'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$80;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        zaxxon_dip_b:array [0..2] of def_dip=(
        (mask:$0f;name:'Coin B';number:16;dip:((dip_val:$f;dip_name:'4C 1C'),(dip_val:$7;dip_name:'3C 1C'),(dip_val:$b;dip_name:'2C 1C'),(dip_val:$6;dip_name:'2C/1C 5C/3C 6C/4C'),(dip_val:$a;dip_name:'2C/1C 3C/2C 4C/3C'),(dip_val:$3;dip_name:'1C 1C'),(dip_val:$2;dip_name:'1C/1C 5C/6C'),(dip_val:$c;dip_name:'1C/1C 4C/5C'),(dip_val:$4;dip_name:'1C/1C 2C/3C'),(dip_val:$d;dip_name:'1C 2C'),(dip_val:$8;dip_name:'1C/2C 5C/11C'),(dip_val:$0;dip_name:'1C/2C 4C/9C'),(dip_val:$5;dip_name:'1C 3C'),(dip_val:$9;dip_name:'1C 4C'),(dip_val:$1;dip_name:'1C 5C'),(dip_val:$6;dip_name:'1C 6C'))),
        (mask:$f0;name:'Coin A';number:16;dip:((dip_val:$f0;dip_name:'4C 1C'),(dip_val:$70;dip_name:'3C 1C'),(dip_val:$b0;dip_name:'2C 1C'),(dip_val:$60;dip_name:'2C/1C 5C/3C 6C/4C'),(dip_val:$a0;dip_name:'2C/1C 3C/2C 4C/3C'),(dip_val:$30;dip_name:'1C 1C'),(dip_val:$20;dip_name:'1C/1C 5C/6C'),(dip_val:$c0;dip_name:'1C/1C 4C/5C'),(dip_val:$40;dip_name:'1C/1C 2C/3C'),(dip_val:$d0;dip_name:'1C 2C'),(dip_val:$80;dip_name:'1C/2C 5C/11C'),(dip_val:$00;dip_name:'1C/2C 4C/9C'),(dip_val:$50;dip_name:'1C 3C'),(dip_val:$90;dip_name:'1C 4C'),(dip_val:$10;dip_name:'1C 5C'),(dip_val:$60;dip_name:'1C 6C'))),());

var
 irq_vblank,bg_enable:boolean;
 congo_color_bank,congo_fg_bank,pal_offset,fg_color,bg_color,bg_position:word;
 sound_latch:byte;
 pal_src:array[0..$ff] of byte;
 bg_mem:array[0..4095,0..255] of byte;
 bg_mem_color:array[0..511,0..31] of byte;
 congo_sprite,coin_enable,coin_status,sound_state:array[0..2] of byte;
 coin_press:array[0..1] of byte;

function find_minimum_y(value:byte):byte;inline;
var
  y:byte;
  sum:word;
begin
	// the sum of the Y position plus a constant based on the flip state */
	// is added to the current flipped VF; if the top 3 bits are 1, we hit */
	// first find a 16-pixel bucket where we hit */
	for y:=0 to 15 do begin
		sum:=(value+$f1+1)+(y*16);
		if ((sum and $e0)=$e0) then break;
	end;
  y:=y*16;
	// then scan backwards until we no longer match */
	while true do begin
		sum:=(value+$f1+1)+(y-1);
		if ((sum and $e0)<>$e0) then break;
		y:=y-1;
	end;
	// add one line since we draw sprites on the previous line */
	find_minimum_y:=(y+1) and $ff;
end;

function find_minimum_x(value:byte):byte;inline;
begin
	// the sum of the X position plus a constant specifies the address within */
	// the line bufer; if we're flipped, we will write backwards */
	find_minimum_x:=value+$ef+1;
end;

procedure update_video_congo;
var
  f,color,nchar,x,y,srcx,srcy:word;
  atrib,atrib2:byte;
  pixel:array[0..$ff,0..$ff] of word;
begin
//Background
if bg_enable then begin
  color:=bg_color+(congo_color_bank shl 8);
  // loop over visible rows */
  for x:=0 to $ff do begin
			//VF = flipped V signals */
			//vf:=x xor flipmask;
			// base of the source row comes from VF plus the scroll value */
			// this is done by the 3 4-bit adders at U56, U74, U75 */
      srcx:=x-(((bg_position-127) shl 1) xor $fff)-1;
			// loop over visible columns */
			for y:=0 to $ff do begin
				  // start with HF = flipped H signals */
				  //srcy:=y xor flipmask;
					// position within source row is a two-stage addition */
					// first stage is HF plus half the VF, done by the 2 4-bit */
					// adders at U53, U54 */
          srcy:=y-((x shr 1) xor $ff)-1;
					// second stage is first stage plus a constant based on the flip */
					// value is 0x40 for non-flipped, or 0x38 for flipped */
          srcy:=srcy-$40;
				  // store the pixel, offset by the color offset */
          pixel[y,x]:=paleta[bg_mem[srcx and $7ff,srcy and $ff]+bg_mem_color[(srcx and $7ff) shr 3,(srcy and $ff) shr 3]+color];
			end;
	end;
  putpixel(0,0,$10000,@pixel,3);
  actualiza_trozo(0,0,256,256,3,0,0,256,256,2);
end else fill_full_screen(2,0);
for f:=$1f downto 0 do begin
        atrib:=buffer_sprites[(f*4)+1];
        atrib2:=buffer_sprites[(f*4)+2];
        y:=find_minimum_y(buffer_sprites[(f*4)+3]);
		    nchar:=atrib and $7f;
		    color:=(atrib2 and $1f)+(congo_color_bank shl 5);
		    x:=find_minimum_x(buffer_sprites[(f*4)+0]);
        put_gfx_sprite(nchar,color shl 3,(atrib and $80)<>0,(atrib2 and $80)<>0,2);
        actualiza_gfx_sprite(x,224-y,2,2);
end;
for f:=0 to $3ff do begin
    if gfx[0].buffer[f] then begin
      x:=31-(f shr 5);
      y:=f and $1f;
      color:=(memoria[$a400+f] and $1f) shl 3;
      nchar:=memoria[$a000+f]+congo_fg_bank;
      put_gfx_trans(x*8,y*8,nchar,color+pal_offset*2,1,0);
      gfx[0].buffer[f]:=false;
    end;
end;
actualiza_trozo(0,0,256,256,1,0,0,256,256,2);
actualiza_trozo_final(16,0,224,256,2);
end;

procedure eventos_zaxxon;
begin
if event.arcade then begin
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 or $1) else marcade.in0:=(marcade.in0 and $fe);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 or $2) else marcade.in0:=(marcade.in0 and $fd);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 or $4) else marcade.in0:=(marcade.in0 and $Fb);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 or $8) else marcade.in0:=(marcade.in0 and $F7);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 or $10) else marcade.in0:=(marcade.in0 and $ef);
  //SW100
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 or $4) else marcade.in2:=(marcade.in2 and $fb);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 or $8) else marcade.in2:=(marcade.in2 and $f7);
  //COIN
  if arcade_input.coin[0] then coin_press[0]:=1 else begin
    if coin_press[0]=1 then coin_status[0]:=coin_enable[0]*$20;
    coin_press[0]:=0;
  end;
  if arcade_input.coin[1] then coin_press[1]:=1 else begin
    if coin_press[1]=1 then coin_status[1]:=coin_enable[1]*$40;
    coin_press[1]:=0;
  end;
end;
end;

procedure congo_principal;
var
  frame_m,frame_s:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=z80_0.tframes;
frame_s:=z80_1.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to 263 do begin
    z80_0.run(frame_m);
    frame_m:=frame_m+z80_0.tframes-z80_0.contador;
    z80_1.run(frame_s);
    frame_s:=frame_s+z80_1.tframes-z80_1.contador;
    if f=239 then begin
      if irq_vblank then z80_0.change_irq(ASSERT_LINE);
      update_video_congo;
    end;
  end;
  eventos_zaxxon;
  video_sync;
end;
end;

function congo_getbyte(direccion:word):byte;
begin
case direccion of
        0..$8fff:congo_getbyte:=memoria[direccion];
        $a000..$bfff:congo_getbyte:=memoria[(direccion and $7ff)+$a000];
        $c000..$dfff:case (direccion and $3f) of
                        0,4:congo_getbyte:=marcade.in0;
                        1,5:congo_getbyte:=0;
                        2,6:congo_getbyte:=marcade.dswa;
                        3,7:congo_getbyte:=marcade.dswb;
                        8..$f:congo_getbyte:=marcade.in2+coin_status[0]+coin_status[1]; //SW100
                     end;
end;
end;

procedure congo_putbyte(direccion:word;valor:byte);
var
  saddr:word;
  daddr:byte;
  count:integer;
begin
if direccion<$7fff then exit;
case direccion of
        $8000..$8fff:memoria[direccion]:=valor;
        $a000..$bfff:if memoria[(direccion and $7ff)+$a000]<>valor then begin
                        memoria[(direccion and $7ff)+$a000]:=valor;
                        gfx[0].buffer[direccion and $3ff]:=true;
                     end;
        $c000..$dfff:case (direccion and $3f) of
                        $18..$1a:begin  //zaxxon_coin_enable_w
                                    coin_enable[direccion and $3]:=valor and 1;
	                                  if (coin_enable[direccion and $3]=0) then coin_status[direccion and $3]:=0;
                                 end;
	                      $1b..$1c:;//zaxxon_coin_counter_w
	                      $1d:bg_enable:=(valor and 1)<>0;
	                      $1e:main_screen.flip_main_screen:=(valor and 1)=0;//zaxxon_flipscreen_w
	                      $1f:begin
                              irq_vblank:=(valor and 1)<>0;
                              if not(irq_vblank) then z80_0.change_irq(CLEAR_LINE);
                            end;
	                      $21:begin //zaxxon_fg_color_w
                              fg_color:=(valor and 1)*$80;
                              pal_offset:=fg_color+(congo_color_bank shl 8);
                            end;
	                      $23:bg_color:=(valor and 1)*$80; //zaxxon_bg_color_w
	                      $26:begin
                              congo_fg_bank:=(valor and 1) shl 8;
                              fillchar(gfx[0].buffer[0],$400,1);
                            end;
	                      $27:begin//congo_color_bank_w
                              congo_color_bank:=valor and 1;
                              pal_offset:=fg_color+(congo_color_bank shl 8);
                            end;
	                      $28,$2a,$2c,$2e:bg_position:=(bg_position and $700) or valor; //zaxxon_bg_position_w
                        $29,$2b,$2d,$2f:bg_position:=(bg_position and $ff) or ((valor shl 8) and $700);
	                      $30..$32:congo_sprite[direccion and $3]:=valor; //congo_sprite_custom_w
                        $33:if (valor=1) then begin
                                saddr:=congo_sprite[0] or (congo_sprite[1] shl 8);
		                            count:=congo_sprite[2];
		                            // count cycles (just a guess) */
                                z80_0.contador:=z80_0.contador+(count*5);
		                            // this is just a guess; the chip is hardwired to the spriteram */
		                            while (count>=0) do begin
                            			daddr:=memoria[saddr+0]*4;
			                            buffer_sprites[(daddr+0) and $ff]:=memoria[saddr+1];
                                  buffer_sprites[(daddr+1) and $ff]:=memoria[saddr+2];
			                            buffer_sprites[(daddr+2) and $ff]:=memoria[saddr+3];
                                  buffer_sprites[(daddr+3) and $ff]:=memoria[saddr+4];
			                            saddr:=saddr+$20;
                                  count:=count-1;
                                end;
                            end;
	                      $38..$3f:sound_latch:=valor; //soundlatch_w
                     end;
end;
end;

function snd_congo_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$1fff:snd_congo_getbyte:=mem_snd[direccion];
  $4000..$5fff:snd_congo_getbyte:=mem_snd[$4000+(direccion and $7ff)];
  $8000..$9fff:snd_congo_getbyte:=pia8255_0.read(direccion and $3);
end;
end;

procedure snd_congo_putbyte(direccion:word;valor:byte);
begin
if direccion<$2000 then exit;
mem_snd[direccion]:=valor;
case direccion of
  $4000..$5fff:mem_snd[$4000+(direccion and $7ff)]:=valor;
  $6000..$7fff:sn_76496_0.Write(valor);
  $8000..$9fff:pia8255_0.write(direccion and $3,valor);
  $a000..$bfff:sn_76496_1.Write(valor);
end;
end;

function ppi8255_congo_rporta:byte;
begin
  ppi8255_congo_rporta:=sound_latch;
end;

procedure ppi8255_congo_wportb(valor:byte);
var
  diff:byte;
begin
  diff:=valor xor sound_state[1];
	sound_state[1]:=valor;
	// bit 7 = mute
  if (valor and $80)<>0 then stop_all_samples;
	// GORILLA: channel 0 */
	if (((diff and $02)<>0) and (not((valor and $02)<>0))) then start_sample(0);
end;

procedure ppi8255_congo_wportc(valor:byte);
var
  diff:byte;
begin
  diff:=valor xor sound_state[2];
	sound_state[2]:=valor;
	// BASS DRUM: channel 1 */
	if (((diff and $01)<>0) and (not((valor and $01)<>0))) then start_sample(1);
	//if (((diff and $01)<>0) and ((valor and $01)<>0)) then stop_sample(1);
	// CONGA (LOW): channel 2 */
	if (((diff and $02)<>0) and (not((valor and $02)<>0))) then start_sample(2);
	//if (((diff and $02)<>0) and ((valor and $02)<>0)) then stop_sample(2);
	// CONGA (HIGH): channel 3 */
	if (((diff and $04)<>0) and (not((valor and $04)<>0))) then start_sample(3);
	//if (((diff and $04)<>0) and ((valor and $04)<>0)) then stop_sample(3);
	// RIM: channel 4 */
	if (((diff and $08)<>0) and (not((valor and $08)<>0))) then start_sample(4);
	//if (((diff and $08)<>0) and ((valor and $08)<>0)) then stop_sample(4);
end;

procedure congo_sound_update;
begin
  sn_76496_0.update;
  sn_76496_1.update;
  samples_update;
end;

procedure congo_sound_irq;
begin
  z80_1.change_irq(HOLD_LINE);
end;

//Zaxxon
procedure update_video_zaxxon;inline;
var
  f,color,nchar:word;
  x,y,srcx,srcy:word;
  pixel:array[0..$ff,0..$ff] of word;
  flipx,flipy:boolean;
begin
//Background
if bg_enable then begin
  color:=bg_color+(congo_color_bank shl 8);
  // loop over visible rows */
  for x:=0 to $ff do begin
			//VF = flipped V signals */
			//vf:=x xor flipmask;
			// base of the source row comes from VF plus the scroll value */
			// this is done by the 3 4-bit adders at U56, U74, U75 */
      srcx:=x-(((bg_position-127) shl 1) xor $fff)-1;
			// loop over visible columns */
			for y:=0 to $ff do begin
				  // start with HF = flipped H signals */
				  //srcy:=y xor flipmask;
					// position within source row is a two-stage addition */
					// first stage is HF plus half the VF, done by the 2 4-bit */
					// adders at U53, U54 */
          srcy:=y-((x shr 1) xor $ff)-1;
					// second stage is first stage plus a constant based on the flip */
					// value is 0x40 for non-flipped, or 0x38 for flipped */
          srcy:=srcy-$40;
				  // store the pixel, offset by the color offset */
          pixel[y,x]:=paleta[bg_mem[srcx and $fff,srcy and $ff]+bg_mem_color[(srcx and $fff) shr 3,(srcy and $ff) shr 3]+color];
			end;
	end;
  putpixel(0,0,$10000,@pixel,3);
  actualiza_trozo(0,0,256,256,3,0,0,256,256,2);
end else fill_full_screen(2,0);
for f:=$1f downto 0 do begin
        y:=find_minimum_y(memoria[$a003+(f*4)]);
		    flipy:=((memoria[$a002+(f*4)]) and $80)<>0;
		    flipx:=((memoria[$a001+(f*4)]) and $80)<>0;
		    nchar:=memoria[$a001+(f*4)] and $3f;
		    color:=memoria[$a002+(f*4)] and $1f;
		    x:=find_minimum_x(memoria[$a000+(f*4)]);
        put_gfx_sprite(nchar,color shl 3,flipx,flipy,2);
        actualiza_gfx_sprite(x,224-y,2,2);
end;
for f:=0 to $3ff do begin
    if gfx[0].buffer[f] then begin
      x:=31-(f shr 5);
      y:=f and $1f;
      color:=(pal_src[y+32*(f shr 7)]) and $f;
      nchar:=memoria[$8000+f];
      put_gfx_trans(x*8,y*8,nchar,color*2 shl 2,1,0);
      gfx[0].buffer[f]:=false;
    end;
end;
actualiza_trozo(0,0,256,256,1,0,0,256,256,2);
actualiza_trozo_final(16,0,224,256,2);
end;

procedure zaxxon_principal;
var
  frame:single;
  f:word;
begin
init_controls(false,false,false,true);
frame:=z80_0.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to 263 do begin
    z80_0.run(frame);
    frame:=frame+z80_0.tframes-z80_0.contador;
    if f=239 then begin
      if irq_vblank then z80_0.change_irq(ASSERT_LINE);
      update_video_zaxxon;
    end;
  end;
  eventos_zaxxon;
  video_sync;
end;
end;

function zaxxon_getbyte(direccion:word):byte;
begin
case direccion of
    $0..$6fff:zaxxon_getbyte:=memoria[direccion];
    $8000..$9fff:zaxxon_getbyte:=memoria[$8000+(direccion and $3ff)];
    $a000..$bfff:zaxxon_getbyte:=memoria[$a000+(direccion and $ff)];
    $c000..$dfff:case (direccion and $103) of
                    $000:zaxxon_getbyte:=marcade.in0;
                    $001:zaxxon_getbyte:=0;
                    $002:zaxxon_getbyte:=marcade.dswa;
                    $003:zaxxon_getbyte:=$33;
                    $100:zaxxon_getbyte:=marcade.in2+coin_status[0]+coin_status[1]; //SW100
                 end;
    $e000..$ffff:case (direccion and $ff) of
                    $3c..$3f:zaxxon_getbyte:=pia8255_0.read(direccion and $3);
                 end;
end;
end;

procedure zaxxon_putbyte(direccion:word;valor:byte);
begin
if direccion<$6000 then exit;
case direccion of
    $6000..$6fff:memoria[direccion]:=valor;
    $8000..$9fff:if memoria[(direccion and $3ff)+$8000]<>valor then begin
                    memoria[(direccion and $3ff)+$8000]:=valor;
                    gfx[0].buffer[direccion and $3ff]:=true;
                 end;
    $a000..$bfff:memoria[$a000+(direccion and $ff)]:=valor;
    $c000..$dfff:case (direccion and $7) of
                    0..2:begin  //zaxxon_coin_enable_w
                        coin_enable[direccion and $3]:=valor and 1;
                        if (coin_enable[direccion and $3]=0) then coin_status[direccion and $3]:=0;
                      end;
                    4:; //zaxxon_coin_counter_w
                    6:main_screen.flip_main_screen:=(valor and 1)=0; //zaxxon_flipscreen_w
                 end;
    $e000..$ffff:case (direccion and $ff) of
                    $3c..$3f:pia8255_0.write(direccion and $3,valor); //ppi
                    $f0:begin //int_enable_w
                          irq_vblank:=(valor and 1)<>0;
                          if not(irq_vblank) then z80_0.change_irq(CLEAR_LINE);
                        end;
                    $f1:begin //zaxxon_fg_color_w
                              fg_color:=(valor and 1)*$80;
                              pal_offset:=fg_color+(congo_color_bank shl 8);
                            end;
                    $f8:bg_position:=(bg_position and $700) or valor; //zaxxon_bg_position_w
                    $f9:bg_position:=(bg_position and $ff) or ((valor shl 8) and $700);
                    $fa:bg_color:=(valor and 1)*$80; //zaxxon_bg_color_w
                    $fb:bg_enable:=(valor and 1)<>0; //zaxxon_bg_enable_w
                 end;
end;
end;

procedure ppi8255_zaxxon_wporta(valor:byte);
var
  diff:byte;
begin
  diff:=valor xor sound_state[0];
	sound_state[0]:=valor;
	// PLAYER SHIP A/B: volume */
	//m_samples->set_volume(10, 0.5 + 0.157 * (data & 0x03));
	//m_samples->set_volume(11, 0.5 + 0.157 * (data & 0x03));
	// PLAYER SHIP C: channel 10 */
	//if ((diff & 0x04) && !(data & 0x04)) m_samples->start(10, 10, true);
  if (((diff and $4)<>0) and (not((valor and $4)<>0))) then start_sample(10);
	// PLAYER SHIP D: channel 11 */
	//if ((diff & 0x08) && !(data & 0x08)) m_samples->start(11, 11, true);
  if (((diff and $8)<>0) and not(((valor and $8)<>0))) then start_sample(11);
	// HOMING MISSILE: channel 0 */
	//if ((diff & 0x10) && !(data & 0x10)) m_samples->start(0, 0, true);
  if (((diff and $10)<>0) and not(((valor and $10)<>0))) then start_sample(0);
	// BASE MISSILE: channel 1 */
  if (((diff and $20)<>0) and not(((valor and $20)<>0))) then start_sample(1);
	// LASER: channel 2 */
	//if ((diff & 0x40) && !(data & 0x40)) m_samples->start(2, 2, true);
  if (((diff and $40)<>0) and not(((valor and $40)<>0))) then start_sample(2);
	// BATTLESHIP: channel 3 */
	//if ((diff & 0x80) && !(data & 0x80)) m_samples->start(3, 3, true);
	if (((diff and $80)<>0) and not(((valor and $80)<>0))) then start_sample(3);
end;

procedure ppi8255_zaxxon_wportb(valor:byte);
var
  diff:byte;
begin
  diff:=valor xor sound_state[1];
	sound_state[1]:=valor;
	// S-EXP: channel 4 */
	//if ((diff & 0x10) && !(data & 0x10)) m_samples->start(4, 4);
  if (((diff and $10)<>0) and not(((valor and $10)<>0))) then start_sample(4);
	// M-EXP: channel 5 */
	//if ((diff & 0x20) && !(data & 0x20) && !m_samples->playing(5)) m_samples->start(5, 5);
  if (((diff and $20)<>0) and not(((valor and $20)<>0))) then start_sample(5);
	// CANNON: channel 6 */
	//if ((diff & 0x80) && !(data & 0x80)) m_samples->start(6, 6);
  if (((diff and $80)<>0) and not(((valor and $80)<>0))) then start_sample(6);
end;

procedure ppi8255_zaxxon_wportc(valor:byte);
var
  diff:byte;
begin
  diff:=valor xor sound_state[2];
	sound_state[2]:=valor;
	// SHOT: channel 7 */
	//if ((diff & 0x01) && !(data & 0x01)) m_samples->start(7, 7);
  if (((diff and $1)<>0) and not(((valor and $1)<>0))) then start_sample(7);
	// ALARM2: channel 8 */
	//if ((diff & 0x04) && !(data & 0x04)) m_samples->start(8, 8);
  if (((diff and $4)<>0) and not(((valor and $4)<>0))) then start_sample(8);
	// ALARM3: channel 9 */
	//if ((diff & 0x08) && !(data & 0x08) && !m_samples->playing(9)) m_samples->start(9, 9);
  if (((diff and $8)<>0) and not(((valor and $8)<>0))) then start_sample(9);
end;

procedure zaxxon_sound_update;
begin
  samples_update;
end;

//Main
procedure reset_zaxxon;
begin
 z80_0.reset;
 if main_vars.tipo_maquina=175 then begin
  z80_1.reset;
  sn_76496_0.reset;
  sn_76496_1.reset;
 end;
 reset_samples;
 pia8255_0.reset;
 reset_audio;
 irq_vblank:=false;
 marcade.in0:=0;
 marcade.in1:=0;
 marcade.in2:=0;
 congo_fg_bank:=0;
 congo_color_bank:=0;
 pal_offset:=0;
 fg_color:=0;
 bg_enable:=false;
 bg_position:=0;
 fillchar(congo_sprite[0],3,0);
 fillchar(coin_enable[0],3,0);
 fillchar(coin_status[0],3,0);
 fillchar(coin_press[0],2,0);
 sound_latch:=0;
end;

function iniciar_zaxxon:boolean;
var
  memoria_temp:array[0..$ffff] of byte;
const
  ps_x:array[0..31] of dword=(0, 1, 2, 3, 4, 5, 6, 7,
			8*8+0, 8*8+1, 8*8+2, 8*8+3, 8*8+4, 8*8+5, 8*8+6, 8*8+7,
			16*8+0, 16*8+1, 16*8+2, 16*8+3, 16*8+4, 16*8+5, 16*8+6, 16*8+7,
			24*8+0, 24*8+1, 24*8+2, 24*8+3, 24*8+4, 24*8+5, 24*8+6, 24*8+7);
  ps_y:array[0..31] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			32*8, 33*8, 34*8, 35*8, 36*8, 37*8, 38*8, 39*8,
			64*8, 65*8, 66*8, 67*8, 68*8, 69*8, 70*8, 71*8,
			96*8, 97*8, 98*8, 99*8, 100*8, 101*8, 102*8, 103*8);
  pc_x:array[0..7] of dword=(0, 1, 2, 3, 4, 5, 6, 7);
  pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
  resistances:array[0..2] of integer=(1000,470,220);
procedure conv_chars;
begin
  init_gfx(0,8,8,256);
  gfx[0].trans[0]:=true;
  gfx_set_desc_data(2,0,8*8,256*8*8,0);
  convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],true,false);
end;
procedure conv_background;
begin
  init_gfx(1,8,8,1024);
  gfx_set_desc_data(3,0,8*8,2*1024*8*8,1024*8*8,0);
  convert_gfx(1,0,@memoria_temp[0],@pc_x[0],@pc_y[0],true,false);
end;
procedure conv_static_background(size:word);
var
  f,sx,sy,nchar:word;
  atrib,x,y:byte;
  pos:pbyte;
begin
for f:=0 to (size-1) do begin
  sx:=((size shr 5)-1)-(f shr 5);
  sy:=f and $1f;
  atrib:=memoria_temp[f+size];
  bg_mem_color[sx,sy]:=(atrib and $f0) shr 1;
  nchar:=memoria_temp[f]+((atrib and $3)*256);
  pos:=gfx[1].datos;
  inc(pos,nchar*8*8);
  for y:=0 to 7 do begin
    for x:=0 to 7 do begin
      bg_mem[sx*8+x,sy*8+y]:=pos^;
      inc(pos);
    end;
  end;
end;
end;
procedure conv_sprites(size:word);
begin
  init_gfx(2,32,32,size);
  gfx[2].trans[0]:=true;
  gfx_set_desc_data(3,0,128*8,2*size*128*8,128*size*8,0);
  convert_gfx(2,0,@memoria_temp[0],@ps_x[0],@ps_y[0],true,false);
end;
procedure convert_palette(size:word);
var
  colores:tpaleta;
  f:word;
  bit0,bit1,bit2:byte;
  rweights,gweights,bweights:array[0..2] of single;
begin
compute_resistor_weights(0,	255, -1.0,
			3,@resistances[0],@rweights[0],470,0,
			3,@resistances[0],@gweights[0],470,0,
			2,@resistances[1],@bweights[0],470,0);
for f:=0 to (size-1) do begin
		// red component */
		bit0:=(memoria_temp[f] shr 0) and $01;
		bit1:=(memoria_temp[f] shr 1) and $01;
		bit2:=(memoria_temp[f] shr 2) and $01;
		colores[f].r:=combine_3_weights(@rweights[0], bit0, bit1, bit2);
		// green component */
		bit0:=(memoria_temp[f] shr 3) and $01;
		bit1:=(memoria_temp[f] shr 4) and $01;
		bit2:=(memoria_temp[f] shr 5) and $01;
		colores[f].g:=combine_3_weights(@gweights[0], bit0, bit1, bit2);
		// blue component */
		bit0:=(memoria_temp[f] shr 6) and $01;
		bit1:=(memoria_temp[f] shr 7) and $01;
		colores[f].b:=combine_2_weights(@bweights[0], bit0, bit1);
end;
set_pal(colores,size);
copymemory(@pal_src[0],@memoria_temp[$100],$100);
end;
begin
iniciar_zaxxon:=false;
iniciar_audio(false);
screen_init(1,256,256,true);
screen_init(2,256,256,false,true);
screen_init(3,256,256);
iniciar_video(224,256);
//Main CPU
z80_0:=cpu_z80.create(3041250,264);
case main_vars.tipo_maquina of
  175:begin  //Congo
        z80_0.change_ram_calls(congo_getbyte,congo_putbyte);
        //Sound
        z80_1:=cpu_z80.create(4000000,264);
        z80_1.change_ram_calls(snd_congo_getbyte,snd_congo_putbyte);
        init_timer(z80_1.numero_cpu,4000000/(4000000/16/16/16/4),congo_sound_irq,true);
        pia8255_0:=pia8255_chip.create;
        pia8255_0.change_ports(ppi8255_congo_rporta,nil,nil,nil,ppi8255_congo_wportb,ppi8255_congo_wportc);
        //Samples
        load_samples('congo.zip',@congo_samples[0],num_samples_congo);
        z80_1.init_sound(congo_sound_update);
        sn_76496_0:=sn76496_chip.Create(4000000);
        sn_76496_1:=sn76496_chip.Create(1000000);
        //cargar roms
        if not(cargar_roms(@memoria[0],@congo_rom[0],'congo.zip',0)) then exit;
        //cargar sonido & iniciar_sonido
        if not(cargar_roms(@mem_snd[0],@congo_sound,'congo.zip')) then exit;
        if not(cargar_roms(@memoria_temp[0],@congo_char,'congo.zip')) then exit;
        conv_chars;
        if not(cargar_roms(@memoria_temp[0],@congo_bg[0],'congo.zip',0)) then exit;
        conv_background;
        //convertir sprites
        if not(cargar_roms(@memoria_temp[0],@congo_sprites[0],'congo.zip',0)) then exit;
        conv_sprites($80);
        //poner la paleta
        if not(cargar_roms(@memoria_temp[0],@congo_pal[0],'congo.zip',0)) then exit;
        convert_palette($200);
        //backgroud
        if not(cargar_roms(@memoria_temp[0],@congo_tilemap[0],'congo.zip',0)) then exit;
        conv_static_background($2000);
        //DIP
        marcade.dswa:=$77;
        marcade.dswa_val:=@congo_dip_a;
        marcade.dswb:=$33;
        marcade.dswb_val:=@zaxxon_dip_b;
     end;
  188:begin  //Zaxxon
        z80_0.change_ram_calls(zaxxon_getbyte,zaxxon_putbyte);
        pia8255_0:=pia8255_chip.create;
        pia8255_0.change_ports(nil,nil,nil,ppi8255_zaxxon_wporta,ppi8255_zaxxon_wportb,ppi8255_zaxxon_wportc);
        //Samples
        if load_samples('zaxxon.zip',@zaxxon_samples[0],num_samples_zaxxon) then begin
          z80_0.init_sound(zaxxon_sound_update);
        end;
        //cargar roms
        if not(cargar_roms(@memoria[0],@zaxxon_rom[0],'zaxxon.zip',0)) then exit;
        if not(cargar_roms(@memoria_temp[0],@zaxxon_char[0],'zaxxon.zip',0)) then exit;
        conv_chars;
        if not(cargar_roms(@memoria_temp[0],@zaxxon_bg[0],'zaxxon.zip',0)) then exit;
        conv_background;
        //convertir sprites
        if not(cargar_roms(@memoria_temp[0],@zaxxon_sprites[0],'zaxxon.zip',0)) then exit;
        conv_sprites($40);
        //poner la paleta
        if not(cargar_roms(@memoria_temp[0],@zaxxon_pal[0],'zaxxon.zip',0)) then exit;
        convert_palette($100);
        //Background
        if not(cargar_roms(@memoria_temp[0],@zaxxon_tilemap[0],'zaxxon.zip',0)) then exit;
        conv_static_background($4000);
        //DIP
        marcade.dswa:=$7f;
        marcade.dswa_val:=@zaxxon_dip_a;
        marcade.dswb:=$33;
        marcade.dswb_val:=@zaxxon_dip_b;
     end;
end;
//final
reset_zaxxon;
iniciar_zaxxon:=true;
end;

procedure Cargar_zaxxon;
begin
llamadas_maquina.iniciar:=iniciar_zaxxon;
case main_vars.tipo_maquina of
  175:llamadas_maquina.bucle_general:=congo_principal;
  188:llamadas_maquina.bucle_general:=zaxxon_principal;
end;
llamadas_maquina.reset:=reset_zaxxon;
llamadas_maquina.fps_max:=59.999408;
end;

end.
