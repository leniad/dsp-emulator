unit pacman_hw;
interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,namco_snd,controls_engine,gfx_engine,rom_engine,
     misc_functions,pal_engine,sound_engine,qsnapshot;

function iniciar_pacman:boolean;

implementation

const
        //Pacman
        pacman_rom:array[0..3] of tipo_roms=(
        (n:'pacman.6e';l:$1000;p:0;crc:$c1e6ab10),(n:'pacman.6f';l:$1000;p:$1000;crc:$1a6fb2d4),
        (n:'pacman.6h';l:$1000;p:$2000;crc:$bcdd1beb),(n:'pacman.6j';l:$1000;p:$3000;crc:$817d94e3));
        pacman_pal:array[0..1] of tipo_roms=(
        (n:'82s123.7f';l:$20;p:0;crc:$2fc650bd),(n:'82s126.4a';l:$100;p:$20;crc:$3eb3a8e4));
        pacman_char:tipo_roms=(n:'pacman.5e';l:$1000;p:0;crc:$0c944964);
        pacman_sound:tipo_roms=(n:'82s126.1m';l:$100;p:0;crc:$a9cc86bf);
        pacman_sprites:tipo_roms=(n:'pacman.5f';l:$1000;p:0;crc:$958fedf9);
        //MS-Pacman
        mspacman_rom:array[0..6] of tipo_roms=(
        (n:'pacman.6e';l:$1000;p:0;crc:$c1e6ab10),(n:'pacman.6f';l:$1000;p:$1000;crc:$1a6fb2d4),
        (n:'pacman.6h';l:$1000;p:$2000;crc:$bcdd1beb),(n:'pacman.6j';l:$1000;p:$3000;crc:$817d94e3),
        (n:'u5';l:$800;p:$8000;crc:$f45fbbcd),(n:'u6';l:$1000;p:$9000;crc:$a90e7000),
        (n:'u7';l:$1000;p:$b000;crc:$c82cd714));
        mspacman_char:tipo_roms=(n:'5e';l:$1000;p:0;crc:$5c281d01);
        mspacman_sprites:tipo_roms=(n:'5f';l:$1000;p:0;crc:$615af909);
        //Crush Roller
        crush_rom:array[0..3] of tipo_roms=(
        (n:'crushkrl.6e';l:$1000;p:0;crc:$a8dd8f54),(n:'crushkrl.6f';l:$1000;p:$1000;crc:$91387299),
        (n:'crushkrl.6h';l:$1000;p:$2000;crc:$d4455f27),(n:'crushkrl.6j';l:$1000;p:$3000;crc:$d59fc251));
        crush_char:tipo_roms=(n:'maketrax.5e';l:$1000;p:0;crc:$91bad2da);
        crush_sprites:tipo_roms=(n:'maketrax.5f';l:$1000;p:0;crc:$aea79f55);
        crush_pal:array[0..1] of tipo_roms=(
        (n:'82s123.7f';l:$20;p:0;crc:$2fc650bd),(n:'2s140.4a';l:$100;p:$20;crc:$63efb927));
        //Ms Pac Man Twin
        mspactwin_rom:tipo_roms=(n:'m27256.bin';l:$8000;p:0;crc:$77a99184);
        mspactwin_char:array[0..1] of tipo_roms=(
        (n:'4__2716.5d';l:$800;p:0;crc:$483c1d1c),(n:'2__2716.5g';l:$800;p:$800;crc:$c08d73a2));
        mspactwin_sprites:array[0..1] of tipo_roms=(
        (n:'3__2516.5f';l:$800;p:$0;crc:$22b0188a),(n:'1__2516.5j';l:$800;p:$800;crc:$0a8c46a0));
        mspactwin_pal:array[0..1] of tipo_roms=(
        (n:'mb7051.8h';l:$20;p:0;crc:$ff344446),(n:'82s129.4a';l:$100;p:$20;crc:$a8202d0d));
        //Birdiy
        birdiy_rom:array[0..3] of tipo_roms=(
        (n:'a6.6a';l:$1000;p:0;crc:$3a58f8ad),(n:'c6.6c';l:$1000;p:$1000;crc:$fec61ea2),
        (n:'a4.4a';l:$1000;p:$2000;crc:$3392783b),(n:'c4.4c';l:$1000;p:$3000;crc:$2391d83d));
        birdiy_pal:array[0..1] of tipo_roms=(
        (n:'n82s123n.10n';l:$20;p:0;crc:$ff344446),(n:'n82s129n.9m';l:$100;p:$20;crc:$63efb927));
        birdiy_char:tipo_roms=(n:'c1.1c';l:$1000;p:0;crc:$8f6bf54f);
        birdiy_sound:tipo_roms=(n:'n82s129n.4k';l:$100;p:0;crc:$a9cc86bf);
        birdiy_sprites:tipo_roms=(n:'c3.3c';l:$1000;p:0;crc:$10b55440);
        //DIP
        pacman_dip_a:array [0..5] of def_dip=(
        (mask:$3;name:'Coinage';number:4;dip:((dip_val:$3;dip_name:'2C 1C'),(dip_val:$1;dip_name:'1C 1C'),(dip_val:$2;dip_name:'1C 2C'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Lives';number:4;dip:((dip_val:$0;dip_name:'1'),(dip_val:$4;dip_name:'2'),(dip_val:$8;dip_name:'3'),(dip_val:$c;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Bonus Life';number:3;dip:((dip_val:$0;dip_name:'10000'),(dip_val:$10;dip_name:'15000'),(dip_val:$20;dip_name:'20000'),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Difficulty';number:2;dip:((dip_val:$40;dip_name:'Normal'),(dip_val:$0;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Ghost Names';number:2;dip:((dip_val:$80;dip_name:'Normal'),(dip_val:$0;dip_name:'Alternate'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        pacman_dip_b:array [0..1] of def_dip=(
        (mask:$10;name:'Rack Test';number:2;dip:((dip_val:$10;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        pacman_dip_c:array [0..1] of def_dip=(
        (mask:$80;name:'Cabinet';number:2;dip:((dip_val:$80;dip_name:'Upright'),(dip_val:$0;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        mspacman_dip:array [0..4] of def_dip=(
        (mask:$3;name:'Coinage';number:4;dip:((dip_val:$3;dip_name:'2C 1C'),(dip_val:$1;dip_name:'1C 1C'),(dip_val:$2;dip_name:'1C 2C'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Lives';number:4;dip:((dip_val:$0;dip_name:'1'),(dip_val:$4;dip_name:'2'),(dip_val:$8;dip_name:'3'),(dip_val:$c;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Bonus Life';number:4;dip:((dip_val:$0;dip_name:'10000'),(dip_val:$10;dip_name:'15000'),(dip_val:$20;dip_name:'20000'),(dip_val:$30;dip_name:'None'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Difficulty';number:2;dip:((dip_val:$40;dip_name:'Normal'),(dip_val:$0;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        crush_dip_a:array [0..4] of def_dip=(
        (mask:$3;name:'Coinage';number:4;dip:((dip_val:$3;dip_name:'2C 1C'),(dip_val:$1;dip_name:'1C 1C'),(dip_val:$2;dip_name:'1C 2C'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Lives';number:4;dip:((dip_val:$0;dip_name:'3'),(dip_val:$4;dip_name:'4'),(dip_val:$8;dip_name:'5'),(dip_val:$c;dip_name:'6'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'First Pattern';number:2;dip:((dip_val:$10;dip_name:'Easy'),(dip_val:$0;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Teleport Holes';number:2;dip:((dip_val:$20;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        crush_dip_b:array [0..1] of def_dip=(
        (mask:$10;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$10;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        mspactwin_dip_a:array [0..3] of def_dip=(
        (mask:$3;name:'Coinage';number:4;dip:((dip_val:$3;dip_name:'2C 1C'),(dip_val:$1;dip_name:'1C 1C'),(dip_val:$2;dip_name:'1C 2C'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Lives';number:4;dip:((dip_val:$0;dip_name:'1'),(dip_val:$4;dip_name:'2'),(dip_val:$8;dip_name:'3'),(dip_val:$c;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Bonus Life';number:4;dip:((dip_val:$0;dip_name:'10000'),(dip_val:$10;dip_name:'15000'),(dip_val:$20;dip_name:'20000'),(dip_val:$30;dip_name:'None'),(),(),(),(),(),(),(),(),(),(),(),())),());
        mspactwin_dip_b:array [0..1] of def_dip=(
        (mask:$10;name:'Jama';number:2;dip:((dip_val:$10;dip_name:'Slow'),(dip_val:$0;dip_name:'Fast'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        mspactwin_dip_c:array [0..1] of def_dip=(
        (mask:$80;name:'Skip Screen';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        birdiy_dip_a:array [0..4] of def_dip=(
        (mask:$3;name:'Coinage';number:4;dip:((dip_val:$3;dip_name:'2C 1C'),(dip_val:$1;dip_name:'1C 1C'),(dip_val:$2;dip_name:'1C 2C'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Lives';number:4;dip:((dip_val:$0;dip_name:'1'),(dip_val:$4;dip_name:'2'),(dip_val:$8;dip_name:'3'),(dip_val:$c;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$10;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Skip Screen';number:2;dip:((dip_val:$20;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 irq_vblank,dec_enable,croller_disable_protection:boolean;
 rom_decode:array[0..$bfff] of byte;
 read_events:procedure;
 croller_counter,croller_offset,unk_latch:byte;
 sprite_ram:array[0..$f] of byte;

procedure update_video_pacman;
var
  color,offs:word;
  nchar,f,sx,sy,atrib,x,y:byte;
  flip_x,flip_y:boolean;
begin
for x:=0 to 27 do begin
  for y:=0 to 35 do begin
     sx:=29-x;
     sy:=y-2;
     if (sy and $20)<>0 then offs:=sx+((sy and $1f) shl 5)
        else offs:=sy+(sx shl 5);
     if gfx[0].buffer[offs] then begin
        color:=((memoria[$4400+offs]) and $1f) shl 2;
        put_gfx(x*8,y*8,memoria[$4000+offs],color,1,0);
        gfx[0].buffer[offs]:=false;
     end;
  end;
end;
actualiza_trozo(0,0,224,288,1,0,0,224,288,2);
//sprites pacman posicion $5060
//byte 0 --> x
//byte 1 --> y
//sprites pacman atributos $4ff0
//byte 0
//      bit 0 --> flipy
//      bit 1 --> flipx
//      bits 2..7 --> numero char
for f:=7 downto 0 do begin
        atrib:=memoria[$4ff0+(f*2)];
        nchar:=atrib shr 2;
        color:=(memoria[$4ff1+(f*2)] and $1f) shl 2;
        if main_screen.flip_main_screen then begin
          x:=sprite_ram[$0+(f*2)]-32;
          y:=sprite_ram[$1+(f*2)];
          flip_y:=(atrib and 1)=0;
          flip_x:=(atrib and 2)=0;
        end else begin
          x:=240-sprite_ram[$0+(f*2)]-1;
          y:=272-sprite_ram[$1+(f*2)];
          flip_y:=(atrib and 1)<>0;
          flip_x:=(atrib and 2)<>0;
        end;
        put_gfx_sprite_mask(nchar,color,flip_x,flip_y,1,0,$f);
        if (f<2) then actualiza_gfx_sprite((x-1) and $ff,y,2,1)
           else actualiza_gfx_sprite(x and $ff,y,2,1)
end;
actualiza_trozo_final(0,0,224,288,2);
end;

procedure eventos_pacman;
begin
if event.arcade then begin
  //in 0
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  //in 1
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  if arcade_input.but0[0] then begin
    if (memoria[$180b]<>$01) then begin
      memoria[$180b]:=$01;
      memoria[$1ffd]:=$bd;
    end
  end else begin
    if (memoria[$180b]<>$be) then begin
      memoria[$180b]:=$be;
      memoria[$1ffd]:=$00;
    end
  end;
end;
end;

procedure pacman_principal;
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
    //Si no pinto la pantalla aqui, Ms Pac Man Twin no hace el efecto de la pantalla...
    //Los timings del Z80 estan bien, supongo que es correcto (parece que no hay da�os colaterales!)
    if f=95 then update_video_pacman;
    if ((f=223) and irq_vblank) then z80_0.change_irq(ASSERT_LINE);
  end;
  read_events;
  video_sync;
end;
end;

function pacman_getbyte(direccion:word):byte;
begin
direccion:=direccion and $7fff;
case direccion of
        0..$3fff:pacman_getbyte:=memoria[direccion];
        $4000..$47ff,$6000..$67ff:pacman_getbyte:=memoria[(direccion and $7ff)+$4000];
        $4800..$4bff,$6800..$6bff:pacman_getbyte:=$bf;
        $4c00..$4fff,$6c00..$6fff:pacman_getbyte:=memoria[(direccion and $3ff)+$4c00];
        $5000..$5fff,$7000..$7fff:case (direccion and $ff) of
                        $00..$3f:pacman_getbyte:=marcade.in0 or marcade.dswb;
                        $40..$7f:pacman_getbyte:=marcade.in1 or marcade.dswc;
                        $80..$bf:pacman_getbyte:=marcade.dswa;
                        $c0..$ff:pacman_getbyte:=$0;
                     end;
end;
end;

procedure pacman_putbyte(direccion:word;valor:byte);
begin
direccion:=direccion and $7fff;
case direccion of
        0..$3fff:; //ROM
        $4000..$47ff,$6000..$67ff:if memoria[(direccion and $7ff)+$4000]<>valor then begin
                        memoria[(direccion and $7ff)+$4000]:=valor;
                        gfx[0].buffer[direccion and $3ff]:=true;
                     end;
        $4c00..$4fff,$6c00..$6fff:memoria[(direccion and $3ff)+$4c00]:=valor;
        $5000..$5fff,$7000..$7fff:case (direccion and $ff) of
                        0:begin
                            irq_vblank:=valor<>0;
                            if not(irq_vblank) then z80_0.change_irq(CLEAR_LINE);
                          end;
                        1:namco_snd_0.enabled:=valor<>0;
                        3:main_screen.flip_main_screen:=(valor and 1)<>0;
                        $40..$5f:namco_snd_0.regs[direccion and $1f]:=valor;
                        $60..$6f:sprite_ram[direccion and $f]:=valor;
                     end;
end;
end;

procedure pacman_outbyte(puerto:word;valor:byte);
begin
if (puerto and $ff)=0 then z80_0.im2_lo:=valor;
end;

procedure pacman_sound_update;
begin
  namco_snd_0.update;
end;

//MS Pacman
procedure eventos_mspacman;
begin
if event.arcade then begin
  //in 0
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  //in 1
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
end;
end;

function mspacman_getbyte(direccion:word):byte;
begin
case direccion of
        $38..$3f,$3b0..$3b7,$1600..$1607,$2120..$2127,$3ff0..$3ff7,$8000..$8007,$97f0..$97f7:dec_enable:=false;
        $3ff8..$3fff:dec_enable:=true;
end;
case direccion of
        $0..$3fff,$8000..$bfff:if dec_enable then mspacman_getbyte:=rom_decode[direccion]
                                  else mspacman_getbyte:=memoria[direccion and $3fff];
        else mspacman_getbyte:=pacman_getbyte(direccion);
end;
end;

procedure mspacman_putbyte(direccion:word;valor:byte);
begin
case direccion of
        $38..$3f,$3b0..$3b7,$1600..$1607,$2120..$2127,$3ff0..$3ff7,$8000..$8007,$97f0..$97f7:dec_enable:=false;
        $3ff8..$3fff:dec_enable:=true;
        else pacman_putbyte(direccion,valor);
end;
end;

//Crush Roller
function crush_getbyte(direccion:word):byte;
const
  protdata_odd:array[0..$1d] of byte=( // table at $ebd (odd entries)
		$00, $c0, $00, $40, $c0, $40, $00, $c0, $00, $40, $00, $c0, $00, $40, $c0, $40,
		$00, $c0, $00, $40, $00, $c0, $00, $40, $c0, $40, $00, $c0, $00, $40);
  protdata_even:array[0..$1d] of byte=( // table at $ebd (even entries)
		$1f, $3f, $2f, $2f, $0f, $0f, $0f, $3f, $0f, $0f, $1c, $3c, $2c, $2c, $0c, $0c,
		$0c, $3c, $0c, $0c, $11, $31, $21, $21, $01, $01, $01, $31, $01, $01);
var
  tempb:byte;
begin
direccion:=direccion and $7fff;
case direccion of
        $5000..$5fff,$7000..$7fff:case (direccion and $ff) of
                        $00..$3f:crush_getbyte:=marcade.in0+marcade.dswb;
                        $40..$7f:crush_getbyte:=marcade.in1;
                        $80..$bf:begin //proteccion 1
                                      tempb:=marcade.dswa and $3f;
                                      if not(croller_disable_protection) then begin
                                         crush_getbyte:=protdata_odd[croller_offset] or tempb;
                                         exit;
                                      end;
	                                    case (direccion and $3f) of
		                                      $01,$04:crush_getbyte:=tempb or $40;
		                                      $05,$0e,$10:crush_getbyte:=tempb or $c0;
		                                      else crush_getbyte:=tempb;
	                                    end;
                                 end;
                        $c0..$cf:begin //proteccion 2
                                      if not(croller_disable_protection) then begin
		                                      crush_getbyte:=protdata_even[croller_offset];
                                         exit;
                                      end;
	                                    case (direccion and $f) of
                                           $0:crush_getbyte:=$1f;
                                           $9:crush_getbyte:=$30;
                                           $c:crush_getbyte:=0;
                                           else crush_getbyte:=$20;
                                      end;
                                 end;
                        $d0..$ff:crush_getbyte:=$0;
                     end;
        else crush_getbyte:=pacman_getbyte(direccion);
end;
end;

procedure crush_putbyte(direccion:word;valor:byte);
begin
direccion:=direccion and $7fff;
case direccion of
        $5000..$5fff,$7000..$7fff:case (direccion and $ff) of
                        0:begin
                            irq_vblank:=valor<>0;
                            if not(irq_vblank) then z80_0.change_irq(CLEAR_LINE);
                          end;
                        1:namco_snd_0.enabled:=valor<>0;
                        3:main_screen.flip_main_screen:=(valor and 1)<>0;
                        4:case valor of //proteccion
                             0:begin // disable protection / reset?
		                            croller_counter:=0;
		                            croller_offset:=0;
		                            croller_disable_protection:=true;
	                             end;
                             1:begin
		                            croller_disable_protection:=false;
		                            croller_counter:=croller_counter+1;
		                            if (croller_counter=$3c) then begin
			                            croller_counter:=0;
                                  croller_offset:=croller_offset+1;
			                            if (croller_offset=$1e) then croller_offset:=0;
		                            end;
	                             end;
                          end;
                        $40..$5f:namco_snd_0.regs[direccion and $1f]:=valor;
                        $60..$6f:sprite_ram[direccion and $f]:=valor;
                     end;
        else pacman_putbyte(direccion,valor);
end;
end;

//Ms Pac Man Twin
function mspactwin_getbyte(direccion:word):byte;
begin
case direccion of
        $0..$3fff,$8000..$bfff:if z80_0.opcode then mspactwin_getbyte:=rom_decode[direccion]
                                  else mspactwin_getbyte:=memoria[direccion];
        $6000..$67ff:if z80_0.opcode then mspactwin_getbyte:=rom_decode[(direccion and $1fff)+$2000]
                                  else mspactwin_getbyte:=memoria[(direccion and $1fff)+$2000];
        $4000..$47ff,$c000..$c7ff:mspactwin_getbyte:=memoria[(direccion and $7ff)+$4000];
        $4800..$4bff,$6800..$6bff,$c800..$cbff:mspactwin_getbyte:=0;
        $4c00..$4fff,$6c00..$6fff,$cc00..$cfff,$ec00..$efff:mspactwin_getbyte:=memoria[(direccion and $3ff)+$4c00];
        $5000..$5fff,$7000..$7fff,$d000..$dfff,$f000..$ffff:case (direccion and $ff) of
                                    $00..$3f:mspactwin_getbyte:=marcade.in0 or marcade.dswb;
                                    $40..$7f:mspactwin_getbyte:=marcade.in1 or marcade.dswc;
                                    $80..$bf:mspactwin_getbyte:=marcade.dswa;
                                    $c0..$ff:mspactwin_getbyte:=unk_latch;
                                  end;
end;
end;

procedure mspactwin_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$3fff,$6000..$67ff,$8000..$bfff:;
  $4000..$47ff,$c000..$c7ff:if memoria[(direccion and $7ff)+$4000]<>valor then begin
                                  memoria[(direccion and $7ff)+$4000]:=valor;
                                  gfx[0].buffer[direccion and $3ff]:=true;
                            end;
  $4c00..$4fff,$6c00..$6fff,$cc00..$cfff,$ec00..$efff:memoria[(direccion and $3ff)+$4c00]:=valor;
  $5000..$5fff,$7000..$7fff,$d000..$dfff,$f000..$ffff:case (direccion and $ff) of
                              0:begin
                                  irq_vblank:=valor<>0;
                                  if not(irq_vblank) then z80_0.change_irq(CLEAR_LINE);
                                end;
                              1:namco_snd_0.enabled:=valor<>0;
                              3:main_screen.flip_main_screen:=(valor and 1)<>0;
                              $40..$5f:namco_snd_0.regs[direccion and $1f]:=valor;
                              $60..$6f:sprite_ram[direccion and $f]:=valor;
                              $80..$bf:unk_latch:=valor;
                              $c0..$ff:; //WD
                            end;
end;
end;

//Birdiy
function birdiy_getbyte(direccion:word):byte;
begin
direccion:=direccion and $7fff;
case direccion of
        0..$3fff:birdiy_getbyte:=memoria[direccion];
        $4000..$47ff:birdiy_getbyte:=memoria[(direccion and $7ff)+$4000];
        $4c00..$4fff:birdiy_getbyte:=memoria[(direccion and $3ff)+$4c00];
        $5000..$5fff:case (direccion and $ff) of
                        $00..$3f:birdiy_getbyte:=marcade.in0 or $10;
                        $40..$7f:birdiy_getbyte:=marcade.in1;
                        $80..$bf:birdiy_getbyte:=marcade.dswa;
                        $c0..$ff:birdiy_getbyte:=$ff;
                     end;
end;
end;

procedure birdiy_putbyte(direccion:word;valor:byte);
begin
direccion:=direccion and $7fff;
case direccion of
        0..$3fff:; //ROM
        $4000..$47ff:if memoria[(direccion and $7ff)+$4000]<>valor then begin
                        memoria[(direccion and $7ff)+$4000]:=valor;
                        gfx[0].buffer[direccion and $3ff]:=true;
                     end;
        $4c00..$4fff:memoria[(direccion and $3ff)+$4c00]:=valor;
        $5000..$5fff:case (direccion and $ff) of
                        1:begin
                            irq_vblank:=valor<>0;
                            if not(irq_vblank) then z80_0.change_irq(CLEAR_LINE);
                          end;
                        $80..$9f:namco_snd_0.regs[direccion and $1f]:=valor;
                        $a0..$af:sprite_ram[direccion and $f]:=valor;
                     end;
end;
end;

procedure pacman_qsave(nombre:string);
var
  data:pbyte;
  size:word;
  buffer:array[0..5] of byte;
begin
case main_vars.tipo_maquina of
  10:open_qsnapshot_save('pacman'+nombre);
  88:open_qsnapshot_save('mspacman'+nombre);
  234:open_qsnapshot_save('crushroller'+nombre);
  305:open_qsnapshot_save('mspactwin'+nombre);
  353:open_qsnapshot_save('birdiy'+nombre);
end;
getmem(data,2000);
//CPU
size:=z80_0.save_snapshot(data);
savedata_qsnapshot(data,size);
//SND
size:=namco_snd_0.save_snapshot(data);
savedata_qsnapshot(data,size);
//MEM
savedata_com_qsnapshot(@sprite_ram[0],$10);
savedata_com_qsnapshot(@memoria[$4000],$4000);
if main_vars.tipo_maquina=88 then savedata_com_qsnapshot(@memoria[$c000],$4000);
//MISC
buffer[0]:=byte(irq_vblank);
buffer[1]:=byte(dec_enable);
buffer[2]:=croller_counter;
buffer[3]:=croller_offset;
buffer[4]:=byte(croller_disable_protection);
buffer[5]:=unk_latch;
savedata_qsnapshot(@buffer,6);
freemem(data);
close_qsnapshot;
end;

procedure pacman_qload(nombre:string);
var
  data:pbyte;
  buffer:array[0..5] of byte;
begin
case main_vars.tipo_maquina of
  10:if not(open_qsnapshot_load('pacman'+nombre)) then exit;
  88:if not(open_qsnapshot_load('mspacman'+nombre)) then exit;
  234:if not(open_qsnapshot_load('crushroller'+nombre)) then exit;
  305:if not(open_qsnapshot_load('mspactwin'+nombre)) then exit;
  353:if not(open_qsnapshot_load('birdiy'+nombre)) then exit;
end;
getmem(data,2000);
//CPU
loaddata_qsnapshot(data);
z80_0.load_snapshot(data);
//SND
loaddata_qsnapshot(data);
namco_snd_0.load_snapshot(data);
//MEM
loaddata_qsnapshot(@sprite_ram[0]);
loaddata_qsnapshot(@memoria[$4000]);
if main_vars.tipo_maquina=88 then loaddata_qsnapshot(@memoria[$c000]);
//MISC
loaddata_qsnapshot(@buffer);
irq_vblank:=buffer[0]<>0;
dec_enable:=buffer[1]<>0;
croller_counter:=buffer[2];
croller_offset:=buffer[3];
croller_disable_protection:=buffer[4]<>0;
unk_latch:=buffer[5];
freemem(data);
close_qsnapshot;
fillchar(gfx[0].buffer,$400,1);
end;

//Main
procedure reset_pacman;
begin
 z80_0.reset;
 namco_snd_0.reset;
 reset_audio;
 irq_vblank:=false;
 dec_enable:=false;
 marcade.in0:=$ef;
 marcade.in1:=$7f;
 croller_counter:=0;
 croller_offset:=0;
 croller_disable_protection:=false;
 unk_latch:=0;
end;

procedure mspacman_install_patches;
var
  i:byte;
begin
	// copy forty 8-byte patches into Pac-Man code
	for i:=0 to 7 do begin
		rom_decode[$0410+i]:=rom_decode[$8008+i];
		rom_decode[$08e0+i]:=rom_decode[$81d8+i];
		rom_decode[$0a30+i]:=rom_decode[$8118+i];
		rom_decode[$0bd0+i]:=rom_decode[$80d8+i];
		rom_decode[$0c20+i]:=rom_decode[$8120+i];
		rom_decode[$0e58+i]:=rom_decode[$8168+i];
		rom_decode[$0ea8+i]:=rom_decode[$8198+i];
		rom_decode[$1000+i]:=rom_decode[$8020+i];
		rom_decode[$1008+i]:=rom_decode[$8010+i];
		rom_decode[$1288+i]:=rom_decode[$8098+i];
		rom_decode[$1348+i]:=rom_decode[$8048+i];
		rom_decode[$1688+i]:=rom_decode[$8088+i];
		rom_decode[$16b0+i]:=rom_decode[$8188+i];
		rom_decode[$16d8+i]:=rom_decode[$80c8+i];
		rom_decode[$16f8+i]:=rom_decode[$81c8+i];
		rom_decode[$19a8+i]:=rom_decode[$80a8+i];
		rom_decode[$19b8+i]:=rom_decode[$81a8+i];
		rom_decode[$2060+i]:=rom_decode[$8148+i];
		rom_decode[$2108+i]:=rom_decode[$8018+i];
		rom_decode[$21a0+i]:=rom_decode[$81a0+i];
		rom_decode[$2298+i]:=rom_decode[$80a0+i];
		rom_decode[$23e0+i]:=rom_decode[$80e8+i];
		rom_decode[$2418+i]:=rom_decode[$8000+i];
		rom_decode[$2448+i]:=rom_decode[$8058+i];
		rom_decode[$2470+i]:=rom_decode[$8140+i];
		rom_decode[$2488+i]:=rom_decode[$8080+i];
		rom_decode[$24b0+i]:=rom_decode[$8180+i];
		rom_decode[$24d8+i]:=rom_decode[$80c0+i];
		rom_decode[$24f8+i]:=rom_decode[$81c0+i];
		rom_decode[$2748+i]:=rom_decode[$8050+i];
		rom_decode[$2780+i]:=rom_decode[$8090+i];
		rom_decode[$27b8+i]:=rom_decode[$8190+i];
		rom_decode[$2800+i]:=rom_decode[$8028+i];
		rom_decode[$2b20+i]:=rom_decode[$8100+i];
		rom_decode[$2b30+i]:=rom_decode[$8110+i];
		rom_decode[$2bf0+i]:=rom_decode[$81d0+i];
		rom_decode[$2cc0+i]:=rom_decode[$80d0+i];
		rom_decode[$2cd8+i]:=rom_decode[$80e0+i];
		rom_decode[$2cf0+i]:=rom_decode[$81e0+i];
		rom_decode[$2d60+i]:=rom_decode[$8160+i];
	end;
end;

function iniciar_pacman:boolean;
var
  colores:tpaleta;
  f:word;
  bit0,bit1,bit2:byte;
  memoria_temp:array[0..$7fff] of byte;
  rweights,gweights,bweights:array[0..2] of single;
const
  ps_x:array[0..15] of dword=(8*8, 8*8+1, 8*8+2, 8*8+3, 16*8+0, 16*8+1, 16*8+2, 16*8+3,
			24*8+0, 24*8+1, 24*8+2, 24*8+3, 0, 1, 2, 3);
  ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			32*8, 33*8, 34*8, 35*8, 36*8, 37*8, 38*8, 39*8);
  pc_x:array[0..7] of dword=(8*8+0, 8*8+1, 8*8+2, 8*8+3, 0, 1, 2, 3);
  resistances:array[0..2] of integer=(1000,470,220);
procedure conv_chars;
begin
  init_gfx(0,8,8,256);
  gfx_set_desc_data(2,0,16*8,0,4);
  convert_gfx(0,0,@memoria_temp,@pc_x,@ps_y,true,false);
end;
procedure conv_sprites;
begin
  init_gfx(1,16,16,64);
  gfx_set_desc_data(2,0,64*8,0,4);
  convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,true,false);
end;
begin
llamadas_maquina.bucle_general:=pacman_principal;
llamadas_maquina.reset:=reset_pacman;
llamadas_maquina.fps_max:=60.6060606060;
llamadas_maquina.save_qsnap:=pacman_qsave;
llamadas_maquina.load_qsnap:=pacman_qload;
iniciar_pacman:=false;
iniciar_audio(false);
screen_init(1,224,288);
screen_init(2,256,512,false,true);
iniciar_video(224,288);
//Main CPU
z80_0:=cpu_z80.create(3072000,264);
z80_0.change_io_calls(nil,pacman_outbyte);
z80_0.init_sound(pacman_sound_update);
namco_snd_0:=namco_snd_chip.create(3);
case main_vars.tipo_maquina of
  10:begin  //Pacman
        z80_0.change_ram_calls(pacman_getbyte,pacman_putbyte);
        //cargar roms
        if not(roms_load(@memoria,pacman_rom)) then exit;
        //cargar sonido
        if not(roms_load(namco_snd_0.get_wave_dir,pacman_sound)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,pacman_char)) then exit;
        conv_chars;
        //convertir sprites
        if not(roms_load(@memoria_temp,pacman_sprites)) then exit;
        conv_sprites;
        //poner la paleta
        if not(roms_load(@memoria_temp,pacman_pal)) then exit;
        //DIP
        read_events:=eventos_pacman;
        marcade.dswa:=$c9;
        marcade.dswb:=$10;
        marcade.dswc:=$80;
        marcade.dswa_val:=@pacman_dip_a;
        marcade.dswb_val:=@pacman_dip_b;
        marcade.dswc_val:=@pacman_dip_c;
     end;
     88:begin  //MS Pacman
        z80_0.change_ram_calls(mspacman_getbyte,mspacman_putbyte);
        //cargar y desencriptar roms
        if not(roms_load(@memoria,mspacman_rom)) then exit;
        copymemory(@rom_decode,@memoria,$1000);  // pacman.6e
        copymemory(@rom_decode[$1000],@memoria[$1000],$1000); // pacman.6f
        copymemory(@rom_decode[$2000],@memoria[$2000],$1000); // pacman.6h
        for f:=0 to $fff do
      	      rom_decode[$3000+f]:=BITSWAP8(memoria[$b000+BITSWAP16(f,15,14,13,12,11,3,7,9,10,8,6,5,4,2,1,0)],0,4,5,7,6,3,2,1);	// decrypt u7 */
	      for f:=0 to $7ff do begin
		      rom_decode[$8000+f]:=BITSWAP8(memoria[$8000+BITSWAP16(f,15,14,13,12,11,8,7,5,9,10,6,3,4,2,1,0)],0,4,5,7,6,3,2,1);	// decrypt u5 */
		      rom_decode[$8800+f]:=BITSWAP8(memoria[$9800+BITSWAP16(f,15,14,13,12,11,3,7,9,10,8,6,5,4,2,1,0)],0,4,5,7,6,3,2,1);	// decrypt half of u6 */
		      rom_decode[$9000+f]:=BITSWAP8(memoria[$9000+BITSWAP16(f,15,14,13,12,11,3,7,9,10,8,6,5,4,2,1,0)],0,4,5,7,6,3,2,1);	// decrypt half of u6 */
	      end;
        copymemory(@rom_decode[$9800],@memoria[$1800],$800); // mirror of pacman.6f high
        copymemory(@rom_decode[$a000],@memoria[$2000],$1000); // mirror of pacman.6h
        copymemory(@rom_decode[$b000],@memoria[$3000],$1000); // mirror of pacman.6j
        mspacman_install_patches;
        //cargar sonido
        if not(roms_load(namco_snd_0.get_wave_dir,pacman_sound)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,mspacman_char)) then exit;
        conv_chars;
        //convertir sprites
        if not(roms_load(@memoria_temp,mspacman_sprites)) then exit;
        conv_sprites;
        //poner la paleta
        if not(roms_load(@memoria_temp,pacman_pal)) then exit;
        //DIP
        read_events:=eventos_mspacman;
        marcade.dswa:=$c9;
        marcade.dswb:=$10;
        marcade.dswc:=$80;
        marcade.dswa_val:=@mspacman_dip;
        marcade.dswb_val:=@pacman_dip_b;
        marcade.dswc_val:=@pacman_dip_c;
     end;
     234:begin  //Crush Roller
        z80_0.change_ram_calls(crush_getbyte,crush_putbyte);
        //cargar roms
        if not(roms_load(@memoria,crush_rom)) then exit;
        //cargar sonido
        if not(roms_load(namco_snd_0.get_wave_dir,pacman_sound)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,crush_char)) then exit;
        conv_chars;
        //convertir sprites
        if not(roms_load(@memoria_temp,crush_sprites)) then exit;
        conv_sprites;
        //poner la paleta
        if not(roms_load(@memoria_temp,crush_pal)) then exit;
        //DIP
        read_events:=eventos_mspacman;
        marcade.dswa:=$31;
        marcade.dswb:=$0;
        marcade.dswa_val:=@crush_dip_a;
        marcade.dswb_val:=@crush_dip_b;
     end;
     305:begin  //MS Pacman Twin
        z80_0.change_ram_calls(mspactwin_getbyte,mspactwin_putbyte);
        //cargar y desencriptar roms
        if not(roms_load(@memoria_temp,mspactwin_rom)) then exit;
        copymemory(@memoria,@memoria_temp,$4000);
        copymemory(@memoria[$8000],@memoria_temp[$4000],$4000);
	      for f:=0 to $1fff do begin
          // decode opcode
		      rom_decode[f*2]:=BITSWAP8(memoria[f*2],4,5,6,7,0,1,2,3);
		      rom_decode[(f*2)+1]:=BITSWAP8(memoria[(f*2)+1] xor $9a,6,4,5,7,2,0,3,1);
		      rom_decode[$8000+(f*2)]:=BITSWAP8(memoria[$8000+(f*2)],4,5,6,7,0,1,2,3);
		      rom_decode[$8001+(f*2)]:=BITSWAP8(memoria[$8001+(f*2)] xor $9a,6,4,5,7,2,0,3,1);
      		// decode operand
	      	memoria[f*2]:=BITSWAP8(memoria[f*2],0,1,2,3,4,5,6,7);
		      memoria[(f*2)+1]:=BITSWAP8(memoria[(f*2)+1] xor $a3,2,4,6,3,7,0,5,1);
		      memoria[$8000+(f*2)]:=BITSWAP8(memoria[$8000+(f*2)],0,1,2,3,4,5,6,7);
		      memoria[$8001+(f*2)]:=BITSWAP8(memoria[$8001+(f*2)] xor $a3,2,4,6,3,7,0,5,1);
	      end;
        //cargar sonido
        if not(roms_load(namco_snd_0.get_wave_dir,pacman_sound)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,mspactwin_char)) then exit;
        conv_chars;
        //convertir sprites
        if not(roms_load(@memoria_temp,mspactwin_sprites)) then exit;
        conv_sprites;
        //poner la paleta
        if not(roms_load(@memoria_temp,mspactwin_pal)) then exit;
        //DIP
        read_events:=eventos_mspacman;
        marcade.dswa:=$c9;
        marcade.dswa_val:=@mspactwin_dip_a;
        marcade.dswb:=$10;
        marcade.dswb_val:=@mspactwin_dip_b;
        marcade.dswc:=$80;
        marcade.dswc_val:=@mspactwin_dip_c;
     end;
     353:begin  //Birdiy
        z80_0.change_ram_calls(birdiy_getbyte,birdiy_putbyte);
        if not(roms_load(@memoria,birdiy_rom)) then exit;
        if not(roms_load(namco_snd_0.get_wave_dir,pacman_sound)) then exit;
        if not(roms_load(@memoria_temp,birdiy_char)) then exit;
        conv_chars;
        if not(roms_load(@memoria_temp,birdiy_sprites)) then exit;
        conv_sprites;
        if not(roms_load(@memoria_temp,birdiy_pal)) then exit;
        read_events:=eventos_mspacman;
        marcade.dswa:=$e9;
        marcade.dswa_val:=@birdiy_dip_a;
     end;
end;
compute_resistor_weights(0,	255, -1.0,
			3,@resistances,@rweights,0,0,
			3,@resistances,@gweights,0,0,
			2,@resistances[1],@bweights,0,0);
for f:=0 to $1f do begin
		// red component
		bit0:=(memoria_temp[f] shr 0) and $01;
		bit1:=(memoria_temp[f] shr 1) and $01;
		bit2:=(memoria_temp[f] shr 2) and $01;
		colores[f].r:=combine_3_weights(@rweights, bit0, bit1, bit2);
		// green component
		bit0:=(memoria_temp[f] shr 3) and $01;
		bit1:=(memoria_temp[f] shr 4) and $01;
		bit2:=(memoria_temp[f] shr 5) and $01;
		colores[f].g:=combine_3_weights(@gweights, bit0, bit1, bit2);
		// blue component
		bit0:=(memoria_temp[f] shr 6) and $01;
		bit1:=(memoria_temp[f] shr 7) and $01;
		colores[f].b:=combine_2_weights(@bweights, bit0, bit1);
end;
set_pal(colores,$20);
for f:=0 to 255 do begin
  gfx[0].colores[f]:=memoria_temp[$20+f] and $f;
  gfx[1].colores[f]:=memoria_temp[$20+f] and $f;
end;
//final
reset_pacman;
iniciar_pacman:=true;
end;

end.
