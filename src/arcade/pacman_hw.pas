unit pacman_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,namco_snd,controls_engine,gfx_engine,rom_engine,
     misc_functions,pal_engine,sound_engine,qsnapshot;

procedure cargar_pacman;

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
        (mask:$30;name:'Bonus Life';number:3;dip:((dip_val:$0;dip_name:'10000'),(dip_val:$10;dip_name:'15000'),(dip_val:$20;dip_name:'20000'),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Difficulty';number:2;dip:((dip_val:$40;dip_name:'Normal'),(dip_val:$0;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        crush_dip_a:array [0..4] of def_dip=(
        (mask:$3;name:'Coinage';number:4;dip:((dip_val:$3;dip_name:'2C 1C'),(dip_val:$1;dip_name:'1C 1C'),(dip_val:$2;dip_name:'1C 2C'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Lives';number:4;dip:((dip_val:$0;dip_name:'3'),(dip_val:$4;dip_name:'4'),(dip_val:$8;dip_name:'5'),(dip_val:$c;dip_name:'6'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'First Pattern';number:2;dip:((dip_val:$10;dip_name:'Easy'),(dip_val:$0;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Teleport Holes';number:2;dip:((dip_val:$20;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        crush_dip_b:array [0..1] of def_dip=(
        (mask:$10;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$10;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

type
  tpacman_event=procedure;

var
 irq_vblank:boolean;
 rom_decode:array[0..$bfff] of byte;
 dec_enable:boolean;
 read_events:tpacman_event;

procedure update_video_pacman;inline;
var
  f,color,nchar,offs:word;
  sx,sy,atrib,x,y:byte;
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
//sprites pacman atributos $4FF0
//byte 0
//      bit 0 --> flipy
//      bit 1 --> flipx
//      bits 2..7 --> numero char
for f:=7 downto 0 do begin
        atrib:=memoria[$4ff0+(f*2)];
        nchar:=atrib shr 2;
        color:=(memoria[$4ff1+(f*2)] and $1f) shl 2;
        if main_screen.flip_main_screen then begin
          y:=memoria[$5061+(f*2)];
          x:=memoria[$5060+(f*2)]-30;
          flip_y:=(atrib and 1)=0;
          flip_x:=(atrib and 2)=0;
        end else begin
          x:=240-memoria[$5060+(f*2)];
          y:=272-memoria[$5061+(f*2)];
          flip_y:=(atrib and 1)<>0;
          flip_x:=(atrib and 2)<>0;
        end;
        put_gfx_sprite_mask(nchar,color,flip_x,flip_y,1,0,$f);
        actualiza_gfx_sprite(x-1,y,2,1);
end;
actualiza_trozo_final(0,0,224,288,2);
end;

procedure eventos_pacman;
begin
if event.arcade then begin
  //in 0
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $F7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $Fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  //in 1
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $F7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $Fb) else marcade.in1:=(marcade.in1 or $4);
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

procedure eventos_mspacman;
begin
if event.arcade then begin
  //in 0
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $F7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $Fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  //in 1
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $F7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $Fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
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
    if f=223 then begin
      if irq_vblank then z80_0.change_irq(HOLD_LINE);
      update_video_pacman;
    end;
  end;
  read_events;
  video_sync;
end;
end;

function pacman_getbyte(direccion:word):byte;
begin
direccion:=direccion and $7FFF;
case direccion of
        0..$3fff:pacman_getbyte:=memoria[direccion];
        $4000..$47ff,$6000..$67ff:pacman_getbyte:=memoria[(direccion and $7ff)+$4000];
        $4800..$4bff,$6800..$6bff:pacman_getbyte:=$bf;
        $4c00..$4fff,$6c00..$6fff:pacman_getbyte:=memoria[(direccion and $3ff)+$4c00];
        $5000..$5fff,$7000..$7fff:case (direccion and $ff) of
                        $00..$3f:pacman_getbyte:=marcade.in0+marcade.dswb;
                        $40..$7f:pacman_getbyte:=marcade.in1+marcade.dswc;
                        $80..$bf:pacman_getbyte:=marcade.dswa;
                        $c0..$ff:pacman_getbyte:=$0;
                     end;
end;
end;

procedure pacman_putbyte(direccion:word;valor:byte);
begin
direccion:=direccion and $7FFF;
case direccion of
        $4000..$47ff,$6000..$67ff:begin
                        memoria[(direccion and $7ff)+$4000]:=valor;
                        gfx[0].buffer[direccion and $3ff]:=true;
                     end;
        $4c00..$4fff,$6c00..$6fff:memoria[(direccion and $3ff)+$4c00]:=valor;
        $5000..$5fff,$7000..$7fff:case (direccion and $ff) of
                        0:irq_vblank:=valor<>0;
                        1:namco_snd_0.enabled:=valor<>0;
                        3:main_screen.flip_main_screen:=(valor and 1)<>0;
                        $40..$5f:namco_snd_0.regs[direccion and $1f]:=valor;
                        $60..$6f:memoria[(direccion and $ff)+$5000]:=valor;
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
function mspacman_getbyte(direccion:word):byte;
begin
case direccion of
        $38..$3f,$3b0..$3b7,$1600..$1607,$2120..$2127,$3ff0..$3ff7,$8000..$8007,$97f0..$97f7:dec_enable:=false;
        $3ff8..$3fff:dec_enable:=true;
end;
case direccion of
        $0..$3fff,$8000..$bfff:if dec_enable then mspacman_getbyte:=rom_decode[direccion]
                                  else mspacman_getbyte:=memoria[direccion and $3fff];
        $4000..$47ff,$6000..$67ff,$c000..$c7ff,$e000..$e7ff:mspacman_getbyte:=memoria[(direccion and $7ff)+$4000];
        $4800..$4bff,$6800..$6bff,$c800..$cbff,$e800..$ebff:mspacman_getbyte:=$bf;
        $4c00..$4fff,$6c00..$6fff,$cc00..$cfff,$ec00..$efff:mspacman_getbyte:=memoria[(direccion and $3ff)+$4c00];
        $5000..$5fff,$7000..$7fff,$d000..$dfff,$f000..$ffff:case (direccion and $ff) of
                        $00..$3f:mspacman_getbyte:=marcade.in0+marcade.dswb;
                        $40..$7f:mspacman_getbyte:=marcade.in1+marcade.dswc;
                        $80..$bf:mspacman_getbyte:=marcade.dswa;
                        $c0..$ff:mspacman_getbyte:=0;
                     end;
end;
end;

procedure mspacman_putbyte(direccion:word;valor:byte);
begin
case direccion of
        $38..$3f,$3b0..$3b7,$1600..$1607,$2120..$2127,$3ff0..$3ff7,$8000..$8007,$97f0..$97f7:dec_enable:=false;
        $3ff8..$3fff:dec_enable:=true;
        $4000..$47ff,$6000..$67ff,$c000..$c7ff,$e000..$e7ff:begin
          memoria[(direccion and $7ff)+$4000]:=valor;
          gfx[0].buffer[direccion and $3ff]:=true;
        end;
        $4c00..$4fff,$6c00..$6fff,$cc00..$cfff,$ec00..$efff:memoria[(direccion and $3ff)+$4c00]:=valor;
        $5000..$5fff,$7000..$7fff,$d000..$dfff,$f000..$ffff:case (direccion and $ff) of
                  0:irq_vblank:=valor<>0;
                  1:namco_snd_0.enabled:=valor<>0;
                  3:main_screen.flip_main_screen:=(valor and 1)<>0;
                  $40..$5f:namco_snd_0.regs[direccion and $1f]:=valor;
                  $60..$6f:memoria[(direccion and $ff)+$5000]:=valor;
        end;
end;
end;

//Crush Roller
function crush_getbyte(direccion:word):byte;
var
  tempb:byte;
begin
direccion:=direccion and $7FFF;
case direccion of
        0..$3fff:if z80_0.opcode then crush_getbyte:=rom_decode[direccion]
                    else crush_getbyte:=memoria[direccion];
        $4000..$47ff,$6000..$67ff:crush_getbyte:=memoria[(direccion and $7ff)+$4000];
        $4800..$4bff,$6800..$6bff:crush_getbyte:=$bf;
        $4c00..$4fff,$6c00..$6fff:crush_getbyte:=memoria[(direccion and $3ff)+$4c00];
        $5080..$50bf:begin
                        tempb:=marcade.dswa;
                        if ((z80_0.get_pc=$1973) or (z80_0.get_pc=$2389)) then begin
                          crush_getbyte:=tempb or $40;
                          exit;
                        end;
                        case (direccion-$5080) of
		                        $1,$4:tempb:=tempb or $40;
		                        $5:tempb:=tempb or $c0;
                            else tempb:=tempb and $3f;
                        end;
	                      crush_getbyte:=tempb;
                     end;
        $50c0..$50cf:begin
                        if (z80_0.get_pc=$040e) then begin
                          crush_getbyte:=$20;
                          exit;
                        end;
	                      if ((z80_0.get_pc=$115e) or (z80_0.get_pc=$3ae2)) then begin
                          crush_getbyte:=0;
                          exit;
                        end;
	                      case (direccion-$50c0) of
                          $0:crush_getbyte:=$1f;
                          $9:crush_getbyte:=$30;
                          $c:crush_getbyte:=0;
                          else crush_getbyte:=$20;
                        end;
                     end;
        $5000..$507f,$5100..$5fff,$7000..$7fff:case (direccion and $ff) of
                        $00..$3f:crush_getbyte:=marcade.in0+marcade.dswb;
                        $40..$7f:crush_getbyte:=marcade.in1;
                        $80..$bf:crush_getbyte:=marcade.dswa;
                        $c0..$ff:crush_getbyte:=$0;
                     end;
end;
end;


procedure pacman_qsave(nombre:string);
var
  data:pbyte;
  size:word;
  buffer:array[0..1] of byte;
begin
case main_vars.tipo_maquina of
  10:open_qsnapshot_save('pacman'+nombre);
  88:open_qsnapshot_save('mspacman'+nombre);
  234:open_qsnapshot_save('crushroller'+nombre);
end;
getmem(data,2000);
//CPU
size:=z80_0.save_snapshot(data);
savedata_qsnapshot(data,size);
//SND
size:=namco_snd_0.save_snapshot(data);
savedata_qsnapshot(data,size);
//MEM
savedata_com_qsnapshot(@memoria[$4000],$4000);
if main_vars.tipo_maquina=88 then savedata_com_qsnapshot(@memoria[$c000],$4000);
//MISC
buffer[0]:=byte(irq_vblank);
buffer[1]:=byte(dec_enable);
savedata_qsnapshot(@buffer[0],2);
freemem(data);
close_qsnapshot;
end;

procedure pacman_qload(nombre:string);
var
  data:pbyte;
  buffer:array[0..1] of byte;
begin
case main_vars.tipo_maquina of
  10:if not(open_qsnapshot_load('pacman'+nombre)) then exit;
  88:if not(open_qsnapshot_load('mspacman'+nombre)) then exit;
  234:if not(open_qsnapshot_load('crushroller'+nombre)) then exit;
end;
getmem(data,2000);
//CPU
loaddata_qsnapshot(data);
z80_0.load_snapshot(data);
//SND
loaddata_qsnapshot(data);
namco_snd_0.load_snapshot(data);
//MEM
loaddata_qsnapshot(@memoria[$4000]);
if main_vars.tipo_maquina=88 then loaddata_qsnapshot(@memoria[$c000]);
//MISC
loaddata_qsnapshot(@buffer[0]);
irq_vblank:=buffer[0]<>0;
dec_enable:=buffer[1]<>0;
freemem(data);
close_qsnapshot;
fillchar(gfx[0].buffer[0],$400,1);
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
end;

procedure mspacman_install_patches;
var
  i:word;
begin
	// copy forty 8-byte patches into Pac-Man code */
	for i:=0 to 7 do begin
		rom_decode[$0410+i]:=rom_decode[$8008+i];
		rom_decode[$08E0+i]:=rom_decode[$81D8+i];
		rom_decode[$0A30+i]:=rom_decode[$8118+i];
		rom_decode[$0BD0+i]:=rom_decode[$80D8+i];
		rom_decode[$0C20+i]:=rom_decode[$8120+i];
		rom_decode[$0E58+i]:=rom_decode[$8168+i];
		rom_decode[$0EA8+i]:=rom_decode[$8198+i];

		rom_decode[$1000+i]:=rom_decode[$8020+i];
		rom_decode[$1008+i]:=rom_decode[$8010+i];
		rom_decode[$1288+i]:=rom_decode[$8098+i];
		rom_decode[$1348+i]:=rom_decode[$8048+i];
		rom_decode[$1688+i]:=rom_decode[$8088+i];
		rom_decode[$16B0+i]:=rom_decode[$8188+i];
		rom_decode[$16D8+i]:=rom_decode[$80C8+i];
		rom_decode[$16F8+i]:=rom_decode[$81C8+i];
		rom_decode[$19A8+i]:=rom_decode[$80A8+i];
		rom_decode[$19B8+i]:=rom_decode[$81A8+i];

		rom_decode[$2060+i]:=rom_decode[$8148+i];
		rom_decode[$2108+i]:=rom_decode[$8018+i];
		rom_decode[$21A0+i]:=rom_decode[$81A0+i];
		rom_decode[$2298+i]:=rom_decode[$80A0+i];
		rom_decode[$23E0+i]:=rom_decode[$80E8+i];
		rom_decode[$2418+i]:=rom_decode[$8000+i];
		rom_decode[$2448+i]:=rom_decode[$8058+i];
		rom_decode[$2470+i]:=rom_decode[$8140+i];
		rom_decode[$2488+i]:=rom_decode[$8080+i];
		rom_decode[$24B0+i]:=rom_decode[$8180+i];
		rom_decode[$24D8+i]:=rom_decode[$80C0+i];
		rom_decode[$24F8+i]:=rom_decode[$81C0+i];
		rom_decode[$2748+i]:=rom_decode[$8050+i];
		rom_decode[$2780+i]:=rom_decode[$8090+i];
		rom_decode[$27B8+i]:=rom_decode[$8190+i];
		rom_decode[$2800+i]:=rom_decode[$8028+i];
		rom_decode[$2B20+i]:=rom_decode[$8100+i];
		rom_decode[$2B30+i]:=rom_decode[$8110+i];
		rom_decode[$2BF0+i]:=rom_decode[$81D0+i];
		rom_decode[$2CC0+i]:=rom_decode[$80D0+i];
		rom_decode[$2CD8+i]:=rom_decode[$80E0+i];
		rom_decode[$2CF0+i]:=rom_decode[$81E0+i];
		rom_decode[$2D60+i]:=rom_decode[$8160+i];
	end;
end;

function iniciar_pacman:boolean;
var
      colores:tpaleta;
      f:word;
      bit0,bit1,bit2:byte;
      memoria_temp:array[0..$ffff] of byte;
      rweights,gweights,bweights:array[0..2] of single;
const
  ps_x:array[0..15] of dword=(8*8, 8*8+1, 8*8+2, 8*8+3, 16*8+0, 16*8+1, 16*8+2, 16*8+3,
			24*8+0, 24*8+1, 24*8+2, 24*8+3, 0, 1, 2, 3);
  ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			32*8, 33*8, 34*8, 35*8, 36*8, 37*8, 38*8, 39*8);
  pc_x:array[0..7] of dword=(8*8+0, 8*8+1, 8*8+2, 8*8+3, 0, 1, 2, 3);
  pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
  resistances:array[0..2] of integer=(1000,470,220);
procedure conv_chars;
begin
  init_gfx(0,8,8,256);
  gfx_set_desc_data(2,0,16*8,0,4);
  convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],true,false);
end;
procedure conv_sprites;
begin
  init_gfx(1,16,16,64);
  gfx_set_desc_data(2,0,64*8,0,4);
  convert_gfx(1,0,@memoria_temp[0],@ps_x[0],@ps_y[0],true,false);
end;
begin
iniciar_pacman:=false;
iniciar_audio(false);
screen_init(1,224,288);
screen_init(2,256,288,false,true);
screen_mod_sprites(2,0,512,0,$1ff);
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
        if not(roms_load(@memoria,@pacman_rom,'pacman.zip',sizeof(pacman_rom))) then exit;
        //cargar sonido & iniciar_sonido
        if not(roms_load(namco_snd_0.get_wave_dir,@pacman_sound,'pacman.zip',sizeof(pacman_sound))) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,@pacman_char,'pacman.zip',sizeof(pacman_char))) then exit;
        conv_chars;
        //convertir sprites
        if not(roms_load(@memoria_temp,@pacman_sprites,'pacman.zip',sizeof(pacman_sprites))) then exit;
        conv_sprites;
        //poner la paleta
        if not(roms_load(@memoria_temp,@pacman_pal,'pacman.zip',sizeof(pacman_pal))) then exit;
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
        if not(roms_load(@memoria,@mspacman_rom,'mspacman.zip',sizeof(mspacman_rom))) then exit;
        copymemory(@rom_decode[0],@memoria[0],$1000);  // pacman.6e */
        copymemory(@rom_decode[$1000],@memoria[$1000],$1000); // pacman.6f */
        copymemory(@rom_decode[$2000],@memoria[$2000],$1000); // pacman.6h */
        for f:=0 to $fff do
      		rom_decode[$3000+f]:=BITSWAP8(memoria[$b000+BITSWAP16(f,15,14,13,12,11,3,7,9,10,8,6,5,4,2,1,0)],0,4,5,7,6,3,2,1);	// decrypt u7 */
	      for f:=0 to $7ff do begin
		      rom_decode[$8000+f]:=BITSWAP8(memoria[$8000+BITSWAP16(f,15,14,13,12,11,8,7,5,9,10,6,3,4,2,1,0)],0,4,5,7,6,3,2,1);	// decrypt u5 */
		      rom_decode[$8800+f]:=BITSWAP8(memoria[$9800+BITSWAP16(f,15,14,13,12,11,3,7,9,10,8,6,5,4,2,1,0)],0,4,5,7,6,3,2,1);	// decrypt half of u6 */
		      rom_decode[$9000+f]:=BITSWAP8(memoria[$9000+BITSWAP16(f,15,14,13,12,11,3,7,9,10,8,6,5,4,2,1,0)],0,4,5,7,6,3,2,1);	// decrypt half of u6 */
	      end;
        copymemory(@rom_decode[$9800],@memoria[$1800],$800); // mirror of pacman.6f high */
        copymemory(@rom_decode[$a000],@memoria[$2000],$1000); // mirror of pacman.6h */
        copymemory(@rom_decode[$b000],@memoria[$3000],$1000); // mirror of pacman.6j */
        mspacman_install_patches;
        //cargar sonido & iniciar_sonido
        if not(roms_load(namco_snd_0.get_wave_dir,@pacman_sound,'mspacman.zip',sizeof(pacman_sound))) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,@mspacman_char,'mspacman.zip',sizeof(mspacman_char))) then exit;
        conv_chars;
        //convertir sprites
        if not(roms_load(@memoria_temp,@mspacman_sprites,'mspacman.zip',sizeof(mspacman_sprites))) then exit;
        conv_sprites;
        //poner la paleta
        if not(roms_load(@memoria_temp,@pacman_pal,'mspacman.zip',sizeof(pacman_pal))) then exit;
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
        z80_0.change_ram_calls(crush_getbyte,pacman_putbyte);
        //cargar roms
        if not(roms_load(@memoria,@crush_rom,'crush.zip',sizeof(crush_rom))) then exit;
        copymemory(@rom_decode,@memoria,$4000);
        rom_decode[$0415]:=$c9;
        rom_decode[$1978]:=$18;
        rom_decode[$238e]:=$c9;
        rom_decode[$3ae5]:=$e6;
        rom_decode[$3ae7]:=$00;
        rom_decode[$3ae8]:=$c9;
        rom_decode[$3aed]:=$86;
        rom_decode[$3aee]:=$c0;
        rom_decode[$3aef]:=$b0;
        //cargar sonido & iniciar_sonido
        if not(roms_load(namco_snd_0.get_wave_dir,@pacman_sound,'crush.zip',sizeof(pacman_sound))) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,@crush_char,'crush.zip',sizeof(crush_char))) then exit;
        conv_chars;
        //convertir sprites
        if not(roms_load(@memoria_temp,@crush_sprites,'crush.zip',sizeof(crush_sprites))) then exit;
        conv_sprites;
        //poner la paleta
        if not(roms_load(@memoria_temp,@crush_pal,'crush.zip',sizeof(crush_pal))) then exit;
        //DIP
        read_events:=eventos_mspacman;
        marcade.dswa:=$31;
        marcade.dswb:=$0;
        marcade.dswa_val:=@crush_dip_a;
        marcade.dswb_val:=@crush_dip_b;
     end;
end;
compute_resistor_weights(0,	255, -1.0,
			3,@resistances[0],@rweights[0],0,0,
			3,@resistances[0],@gweights[0],0,0,
			2,@resistances[1],@bweights[0],0,0);
for f:=0 to $1f do begin
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
set_pal(colores,$20);
for f:=0 to 255 do begin
  gfx[0].colores[f]:=memoria_temp[$20+f] and $f;
  gfx[1].colores[f]:=memoria_temp[$20+f] and $f;
end;
//final
reset_pacman;
iniciar_pacman:=true;
end;

procedure cargar_pacman;
begin
llamadas_maquina.iniciar:=iniciar_pacman;
llamadas_maquina.bucle_general:=pacman_principal;
llamadas_maquina.reset:=reset_pacman;
llamadas_maquina.fps_max:=60.6060606060;
llamadas_maquina.save_qsnap:=pacman_qsave;
llamadas_maquina.load_qsnap:=pacman_qload;
end;

end.
