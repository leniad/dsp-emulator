unit cavemanninja_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m68000,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     oki6295,sound_engine,hu6280,deco_16ic,deco_common,deco_104,deco_146,
     misc_functions;

function iniciar_cninja:boolean;

implementation
const
        //Caveman Ninja
        cninja_rom:array[0..5] of tipo_roms=(
        (n:'gn-02-3.1k';l:$20000;p:0;crc:$39aea12a),(n:'gn-05-2.3k';l:$20000;p:$1;crc:$0f4360ef),
        (n:'gn-01-2.1j';l:$20000;p:$40000;crc:$f740ef7e),(n:'gn-04-2.3j';l:$20000;p:$40001;crc:$c98fcb62),
        (n:'gn-00.rom';l:$20000;p:$80000;crc:$0b110b16),(n:'gn-03.rom';l:$20000;p:$80001;crc:$1e28e697));
        cninja_sound:tipo_roms=(n:'gl-07.rom';l:$10000;p:$0;crc:$ca8bef96);
        cninja_chars:array[0..1] of tipo_roms=(
        (n:'gl-09.rom';l:$10000;p:$0;crc:$5a2d4752),(n:'gl-08.rom';l:$10000;p:1;crc:$33a2b400));
        cninja_tiles1:tipo_roms=(n:'mag-02.rom';l:$80000;p:$0;crc:$de89c69a);
        cninja_tiles2:array[0..1] of tipo_roms=(
        (n:'mag-00.rom';l:$80000;p:$0;crc:$a8f05d33),(n:'mag-01.rom';l:$80000;p:$80000;crc:$5b399eed));
        cninja_oki2:tipo_roms=(n:'mag-07.rom';l:$80000;p:0;crc:$08eb5264);
        cninja_oki1:tipo_roms=(n:'gl-06.rom';l:$20000;p:0;crc:$d92e519d);
        cninja_sprites:array[0..3] of tipo_roms=(
        (n:'mag-03.rom';l:$80000;p:0;crc:$2220eb9f),(n:'mag-05.rom';l:$80000;p:$1;crc:$56a53254),
        (n:'mag-04.rom';l:$80000;p:$100000;crc:$144b94cc),(n:'mag-06.rom';l:$80000;p:$100001;crc:$82d44749));
        cninja_dip:array [0..7] of def_dip=(
        (mask:$0007;name:'Coin A';number:8;dip:((dip_val:$0;dip_name:'3C 1C'),(dip_val:$1;dip_name:'2C 1C'),(dip_val:$7;dip_name:'1C 1C'),(dip_val:$6;dip_name:'1C 2C'),(dip_val:$5;dip_name:'1C 3C'),(dip_val:$4;dip_name:'1C 4C'),(dip_val:$3;dip_name:'1C 5C'),(dip_val:$2;dip_name:'1C 6C'),(),(),(),(),(),(),(),())),
        (mask:$0038;name:'Coin B';number:8;dip:((dip_val:$0;dip_name:'3C 1C'),(dip_val:$8;dip_name:'2C 1C'),(dip_val:$38;dip_name:'1C 1C'),(dip_val:$30;dip_name:'1C 2C'),(dip_val:$28;dip_name:'1C 3C'),(dip_val:$20;dip_name:'1C 4C'),(dip_val:$18;dip_name:'1C 5C'),(dip_val:$10;dip_name:'1C 6C'),(),(),(),(),(),(),(),())),
        (mask:$0040;name:'Flip Screen';number:2;dip:((dip_val:$40;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0300;name:'Lives';number:4;dip:((dip_val:$100;dip_name:'1'),(dip_val:$0;dip_name:'2'),(dip_val:$300;dip_name:'3'),(dip_val:$200;dip_name:'4'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0c00;name:'Difficulty';number:4;dip:((dip_val:$800;dip_name:'Easy'),(dip_val:$c00;dip_name:'Normal'),(dip_val:$400;dip_name:'Hard'),(dip_val:$000;dip_name:'Very Hard'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$1000;name:'Restore Live Meter';number:2;dip:((dip_val:$1000;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8000;name:'Demo Sounds';number:2;dip:((dip_val:$8000;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        //Robocop 2
        robocop2_rom:array[0..7] of tipo_roms=(
        (n:'gq-03.k1';l:$20000;p:0;crc:$a7e90c28),(n:'gq-07.k3';l:$20000;p:$1;crc:$d2287ec1),
        (n:'gq-02.j1';l:$20000;p:$40000;crc:$6777b8a0),(n:'gq-06.j3';l:$20000;p:$40001;crc:$e11e27b5),
        (n:'go-01-1.h1';l:$20000;p:$80000;crc:$ab5356c0),(n:'go-05-1.h3';l:$20000;p:$80001;crc:$ce21bda5),
        (n:'go-00.f1';l:$20000;p:$c0000;crc:$a93369ea),(n:'go-04.f3';l:$20000;p:$c0001;crc:$ee2f6ad9));
        robocop2_char:array[0..1] of tipo_roms=(
        (n:'gp10-1.y6';l:$10000;p:1;crc:$d25d719c),(n:'gp11-1.z6';l:$10000;p:0;crc:$030ded47));
        robocop2_sound:tipo_roms=(n:'gp-09.k13';l:$10000;p:$0;crc:$4a4e0f8d);
        robocop2_oki1:tipo_roms=(n:'gp-08.j13';l:$20000;p:0;crc:$365183b1);
        robocop2_oki2:tipo_roms=(n:'mah-11.f13';l:$80000;p:0;crc:$642bc692);
        robocop2_tiles1:array[0..1] of tipo_roms=(
        (n:'mah-04.z4';l:$80000;p:$0;crc:$9b6ca18c),(n:'mah-03.y4';l:$80000;p:$80000;crc:$37894ddc));
        robocop2_tiles2:array[0..2] of tipo_roms=(
        (n:'mah-01.z1';l:$80000;p:0;crc:$26e0dfff),(n:'mah-00.y1';l:$80000;p:$80000;crc:$7bd69e41),
        (n:'mah-02.a1';l:$80000;p:$100000;crc:$328a247d));
        robocop2_sprites:array[0..5] of tipo_roms=(
        (n:'mah-05.y9';l:$80000;p:$000000;crc:$6773e613),(n:'mah-08.y12';l:$80000;p:$000001;crc:$88d310a5),
        (n:'mah-06.z9';l:$80000;p:$100000;crc:$27a8808a),(n:'mah-09.z12';l:$80000;p:$100001;crc:$a58c43a7),
        (n:'mah-07.a9';l:$80000;p:$200000;crc:$526f4190),(n:'mah-10.a12';l:$80000;p:$200001;crc:$14b770da));
        robocop2_dip_a:array [0..8] of def_dip=(
        (mask:$0007;name:'Coin A';number:8;dip:((dip_val:$0;dip_name:'3C 1C'),(dip_val:$1;dip_name:'2C 1C'),(dip_val:$7;dip_name:'1C 1C'),(dip_val:$6;dip_name:'1C 2C'),(dip_val:$5;dip_name:'1C 3C'),(dip_val:$4;dip_name:'1C 4C'),(dip_val:$3;dip_name:'1C 5C'),(dip_val:$2;dip_name:'1C 6C'),(),(),(),(),(),(),(),())),
        (mask:$0038;name:'Coin B';number:8;dip:((dip_val:$0;dip_name:'3C 1C'),(dip_val:$8;dip_name:'2C 1C'),(dip_val:$38;dip_name:'1C 1C'),(dip_val:$30;dip_name:'1C 2C'),(dip_val:$28;dip_name:'1C 3C'),(dip_val:$20;dip_name:'1C 4C'),(dip_val:$18;dip_name:'1C 5C'),(dip_val:$10;dip_name:'1C 6C'),(),(),(),(),(),(),(),())),
        (mask:$0040;name:'Flip Screen';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$40;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0300;name:'Lives';number:4;dip:((dip_val:$100;dip_name:'1'),(dip_val:$0;dip_name:'2'),(dip_val:$300;dip_name:'3'),(dip_val:$200;dip_name:'4'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0c00;name:'Time';number:4;dip:((dip_val:$800;dip_name:'400 Seconds'),(dip_val:$c00;dip_name:'300 Seconds'),(dip_val:$400;dip_name:'200 Seconds'),(dip_val:$000;dip_name:'100 Seconds'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$3000;name:'Health';number:4;dip:((dip_val:$000;dip_name:'17'),(dip_val:$1000;dip_name:'24'),(dip_val:$3000;dip_name:'33'),(dip_val:$2000;dip_name:'40'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4000;name:'Continues';number:2;dip:((dip_val:$000;dip_name:'Off'),(dip_val:$4000;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8000;name:'Demo Sounds';number:2;dip:((dip_val:$8000;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        robocop2_dip_b:array [0..5] of def_dip=(
        (mask:$3;name:'Bullets';number:4;dip:((dip_val:$0;dip_name:'Least'),(dip_val:$1;dip_name:'Less'),(dip_val:$3;dip_name:'Normal'),(dip_val:$2;dip_name:'More'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Enemy Movement';number:4;dip:((dip_val:$8;dip_name:'Slow'),(dip_val:$c;dip_name:'Normal'),(dip_val:$4;dip_name:'Fast'),(dip_val:$0;dip_name:'Fastest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Enemy Strength';number:4;dip:((dip_val:$20;dip_name:'Less'),(dip_val:$30;dip_name:'Normal'),(dip_val:$10;dip_name:'More'),(dip_val:$0;dip_name:'Most'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Enemy Weapon Speed';number:2;dip:((dip_val:$40;dip_name:'Normal'),(dip_val:$0;dip_name:'Fast'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Game Over Message';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 rom:array[0..$7ffff] of word;
 ram:array[0..$1fff] of word;
 screen_line,irq_mask,irq_line:byte;
 prioridad:word;
 raster_irq:boolean;
 proc_update_video:procedure;

procedure update_video_cninja;
begin
deco16ic_1.update_pf_2(5,false);
deco_sprites_0.draw_sprites($80);
deco16ic_1.update_pf_1(5,true);
deco_sprites_0.draw_sprites($40);
deco16ic_0.update_pf_2(5,true);
deco_sprites_0.draw_sprites($00);
deco16ic_0.update_pf_1(5,true);
actualiza_trozo_final(0,8,256,240,5);
end;

procedure update_video_robocop2;
begin
if (prioridad and 4)=0 then deco16ic_1.update_pf_2(5,false)
  else begin
    deco_sprites_0.draw_sprites($c0);
    fill_full_screen(5,$200);
  end;
deco_sprites_0.draw_sprites($80);
if (prioridad and $8)<>0 then begin
      deco16ic_0.update_pf_2(5,true);
      deco_sprites_0.draw_sprites($40);
      deco16ic_1.update_pf_1(5,true);
end else begin
      deco16ic_1.update_pf_1(5,(prioridad and 4)=0);
      deco_sprites_0.draw_sprites($40);
      deco16ic_0.update_pf_2(5,true);
end;
deco_sprites_0.draw_sprites($00);
deco16ic_0.update_pf_1(5,true);
actualiza_trozo_final(0,8,320,240,5);
end;

procedure eventos_cninja;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fffe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fffd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fffb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fff7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ffef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $ffdf) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.but2[0] then marcade.in0:=(marcade.in0 and $ffbf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $ff7f) else marcade.in0:=(marcade.in0 or $80);
  //P2
  if arcade_input.up[1] then marcade.in0:=(marcade.in0 and $feff) else marcade.in0:=(marcade.in0 or $100);
  if arcade_input.down[1] then marcade.in0:=(marcade.in0 and $fdff) else marcade.in0:=(marcade.in0 or $200);
  if arcade_input.left[1] then marcade.in0:=(marcade.in0 and $fbff) else marcade.in0:=(marcade.in0 or $400);
  if arcade_input.right[1] then marcade.in0:=(marcade.in0 and $f7ff) else marcade.in0:=(marcade.in0 or $800);
  if arcade_input.but0[1] then marcade.in0:=(marcade.in0 and $efff) else marcade.in0:=(marcade.in0 or $1000);
  if arcade_input.but1[1] then marcade.in0:=(marcade.in0 and $dfff) else marcade.in0:=(marcade.in0 or $2000);
  if arcade_input.but1[1] then marcade.in0:=(marcade.in0 and $bfff) else marcade.in0:=(marcade.in0 or $4000);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $7fff) else marcade.in0:=(marcade.in0 or $8000);
  //SYSTEM
  if arcade_input.coin[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.coin[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
end;
end;

procedure cninja_principal;
var
  frame_m,frame_s:single;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
frame_s:=h6280_0.tframes;
while EmuStatus=EsRuning do begin
 for screen_line:=0 to $ff do begin
   m68000_0.run(frame_m);
   frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
   h6280_0.run(trunc(frame_s));
   frame_s:=frame_s+h6280_0.tframes-h6280_0.contador;
   case screen_line of
      1..239:if raster_irq then begin
               if irq_line=screen_line then begin
                  if (irq_mask and $10)<>0 then m68000_0.irq[3]:=ASSERT_LINE
                    else m68000_0.irq[4]:=ASSERT_LINE;
                  raster_irq:=false;
               end;
             end;
      247:begin
            m68000_0.irq[5]:=HOLD_LINE;
            proc_update_video;
            marcade.in1:=marcade.in1 or $8;
          end;
      255:marcade.in1:=marcade.in1 and $f7;
   end;
 end;
 eventos_cninja;
 video_sync;
end;
end;

function cninja_protection_deco_104_r(real_address:word):word;
var
  data,deco104_addr:word;
  cs:byte;
begin
	//int real_address = 0 + (offset *2);
	deco104_addr:=BITSWAP32(real_address,31,30,29,28,27,26,25,24,23,22,21,20,19,18, 13,12,11,17,16,15,14,    10,9,8, 7,6,5,4, 3,2,1,0) and $7fff;
	cs:=0;
	data:=main_deco104.read_data(deco104_addr,cs);
	cninja_protection_deco_104_r:=data;
end;

function cninja_getword(direccion:dword):word;
begin
case direccion of
  $0..$bffff:cninja_getword:=rom[direccion shr 1];
  $144000..$144fff:cninja_getword:=deco16ic_0.pf1.data[(direccion and $fff) shr 1];
  $146000..$146fff:cninja_getword:=deco16ic_0.pf2.data[(direccion and $fff) shr 1];
  $14c000..$14c7ff:cninja_getword:=deco16ic_0.pf1.rowscroll[(direccion and $7ff) shr 1];
  $14e000..$14e7ff:cninja_getword:=deco16ic_0.pf2.rowscroll[(direccion and $7ff) shr 1];
  $154000..$154fff:cninja_getword:=deco16ic_1.pf1.data[(direccion and $fff) shr 1];
  $156000..$156fff:cninja_getword:=deco16ic_1.pf2.data[(direccion and $fff) shr 1];
  $15c000..$15c7ff:cninja_getword:=deco16ic_1.pf1.rowscroll[(direccion and $7ff) shr 1];
  $15e000..$15e7ff:cninja_getword:=deco16ic_1.pf2.rowscroll[(direccion and $7ff) shr 1];
  $184000..$187fff:cninja_getword:=ram[(direccion and $3fff) shr 1];
  $190000..$190007:case ((direccion shr 1) and $7) of
                      1:cninja_getword:=screen_line; // Raster IRQ scanline position
	                    2:begin // Raster IRQ ACK
                          m68000_0.irq[3]:=CLEAR_LINE;
                          m68000_0.irq[4]:=CLEAR_LINE;
                          cninja_getword:=0;
                      end;
                        else cninja_getword:=0;
                   end;
  $19c000..$19dfff:cninja_getword:=buffer_paleta[(direccion and $1fff) shr 1];
  $1a4000..$1a47ff:cninja_getword:=buffer_sprites_w[(direccion and $7ff) shr 1];
	$1bc000..$1bffff:cninja_getword:=cninja_protection_deco_104_r(direccion-$1bc000);
end;
end;

procedure cambiar_color(numero:word);
var
  color:tcolor;
begin
  color.b:=buffer_paleta[numero shl 1] and $ff;
  color.g:=buffer_paleta[(numero shl 1)+1] shr 8;
  color.r:=buffer_paleta[(numero shl 1)+1] and $ff;
  set_pal_color(color,numero);
  case numero of
    $000..$0ff:deco16ic_0.pf1.buffer_color[(numero shr 4) and $f]:=true;
    $100..$1ff:deco16ic_0.pf2.buffer_color[(numero shr 4) and $f]:=true;
    $200..$2ff:deco16ic_1.pf1.buffer_color[(numero shr 4) and $f]:=true;
    $500..$5ff:deco16ic_1.pf2.buffer_color[(numero shr 4) and deco16ic_1.color_mask[2]]:=true;
  end;
end;

procedure cninja_protection_deco_104_w(real_address,data:word);
var
  deco104_addr:word;
  cs:byte;
begin
	//int real_address = 0 + (offset *2);
	deco104_addr:=BITSWAP32(real_address,31,30,29,28,27,26,25,24,23,22,21,20,19,18, 13,12,11,17,16,15,14,    10,9,8, 7,6,5,4, 3,2,1,0) and $7fff;
	cs:=0;
	main_deco104.write_data(deco104_addr, data,cs);
end;

procedure cninja_putword(direccion:dword;valor:word);
begin
case direccion of
  0..$bffff:; //ROM
  $140000..$14000f:deco16ic_0.control_w((direccion and $f) shr 1,valor);
  $144000..$144fff:if deco16ic_0.pf1.data[(direccion and $fff) shr 1]<>valor then begin
                      deco16ic_0.pf1.data[(direccion and $fff) shr 1]:=valor;
                      deco16ic_0.pf1.buffer[(direccion and $fff) shr 1]:=true
                   end;
  $146000..$146fff:if deco16ic_0.pf2.data[(direccion and $fff) shr 1]<>valor then begin
                      deco16ic_0.pf2.data[(direccion and $fff) shr 1]:=valor;
                      deco16ic_0.pf2.buffer[(direccion and $fff) shr 1]:=true
                   end;
  $14c000..$14c7ff:deco16ic_0.pf1.rowscroll[(direccion and $7ff) shr 1]:=valor;
  $14e000..$14e7ff:deco16ic_0.pf2.rowscroll[(direccion and $7ff) shr 1]:=valor;
  $150000..$15000f:begin
                      deco16ic_1.control_w((direccion and $f) shr 1,valor);
                      if ((direccion and $f)=0) then main_screen.flip_main_screen:=(valor and $0080)<>0
                   end;
	$154000..$154fff:if deco16ic_1.pf1.data[(direccion and $fff) shr 1]<>valor then begin
                      deco16ic_1.pf1.data[(direccion and $fff) shr 1]:=valor;
                      deco16ic_1.pf1.buffer[(direccion and $fff) shr 1]:=true
                   end;
  $156000..$156fff:if deco16ic_1.pf2.data[(direccion and $fff) shr 1]<>valor then begin
                      deco16ic_1.pf2.data[(direccion and $fff) shr 1]:=valor;
                      deco16ic_1.pf2.buffer[(direccion and $fff) shr 1]:=true
                   end;
  $15c000..$15c7ff:deco16ic_1.pf1.rowscroll[(direccion and $7ff) shr 1]:=valor;
  $15e000..$15e7ff:deco16ic_1.pf2.rowscroll[(direccion and $7ff) shr 1]:=valor;
  $184000..$187fff:ram[(direccion and $3fff) shr 1]:=valor;
	$190000..$190007:case ((direccion shr 1) and 7) of
	                    0:irq_mask:=valor and $ff; // IRQ enable:
	                    1:begin // Raster IRQ scanline position, only valid for values between 1 & 239 (0 and 240-256 do NOT generate IRQ's)
                          irq_line:=valor and $ff;
                          raster_irq:=(irq_line>0) and (irq_line<240) and ((irq_mask and $2)=0);
                        end;
                   end;
  $19c000..$19dfff:if (buffer_paleta[(direccion and $1fff) shr 1]<>valor) then begin
                      buffer_paleta[(direccion and $1fff) shr 1]:=valor;
                      cambiar_color((direccion and $1fff) shr 2);
                   end;
  $1a4000..$1a47ff:buffer_sprites_w[(direccion and $7ff) shr 1]:=valor;
  $1b4000..$1b4001:copymemory(@deco_sprites_0.ram[0],@buffer_sprites_w[0],$400*2);
  $1b0002..$1b000f:;
	$1bc000..$1bffff:cninja_protection_deco_104_w(direccion-$1bc000,valor);
end;
end;

//Roboop 2
function robocop2_protection_deco_146_r(real_address:word):word;
var
  deco146_addr,data:word;
  cs:byte;
begin
	//int real_address = 0 + (offset *2);
	deco146_addr:=BITSWAP32(real_address,31,30,29,28,27,26,25,24,23,22,21,20,19,18, 13,12,11,   17,16,15,14,    10,9,8, 7,6,5,4, 3,2,1,0) and $7fff;
	cs:=0;
	data:=main_deco146.read_data(deco146_addr,cs);
  robocop2_protection_deco_146_r:=data;
end;

function robocop2_getword(direccion:dword):word;
begin
case direccion of
  $0..$fffff:robocop2_getword:=rom[direccion shr 1];
  $144000..$144fff:robocop2_getword:=deco16ic_0.pf1.data[(direccion and $fff) shr 1];
  $146000..$146fff:robocop2_getword:=deco16ic_0.pf2.data[(direccion and $fff) shr 1];
  $14c000..$14c7ff:robocop2_getword:=deco16ic_0.pf1.rowscroll[(direccion and $7ff) shr 1];
  $14e000..$14e7ff:robocop2_getword:=deco16ic_0.pf2.rowscroll[(direccion and $7ff) shr 1];
  $154000..$154fff:robocop2_getword:=deco16ic_1.pf1.data[(direccion and $fff) shr 1];
  $156000..$156fff:robocop2_getword:=deco16ic_1.pf2.data[(direccion and $fff) shr 1];
  $15c000..$15c7ff:robocop2_getword:=deco16ic_1.pf1.rowscroll[(direccion and $7ff) shr 1];
  $15e000..$15e7ff:robocop2_getword:=deco16ic_1.pf2.rowscroll[(direccion and $7ff) shr 1];
  $180000..$1807ff:robocop2_getword:=buffer_sprites_w[(direccion and $7ff) shr 1];
  $18c000..$18ffff:robocop2_getword:=robocop2_protection_deco_146_r(direccion-$18c000);
  $1a8000..$1a9fff:robocop2_getword:=buffer_paleta[(direccion and $1fff) shr 1];
  $1b0000..$1b0007:case ((direccion shr 1) and $7) of
                      1:robocop2_getword:=screen_line; // Raster IRQ scanline position
	                    2:begin // Raster IRQ ACK
                          m68000_0.irq[3]:=CLEAR_LINE;
                          m68000_0.irq[4]:=CLEAR_LINE;
                          robocop2_getword:=0;
                      end;
                        else robocop2_getword:=0;
                   end;
  $1b8000..$1bbfff:robocop2_getword:=ram[(direccion and $3fff) shr 1];
	$1f8000..$1f8001:robocop2_getword:=marcade.dswb;
end;
end;

procedure robocop2_protection_deco_146_w(real_address,data:word);
var
  deco146_addr:word;
  cs:byte;
begin
	//int real_address = 0 + (offset *2);
	deco146_addr:=BITSWAP32(real_address, 31,30,29,28,27,26,25,24,23,22,21,20,19,18, 13,12,11,    17,16,15,14,    10,9,8, 7,6,5,4, 3,2,1,0) and $7fff;
	cs:=0;
	main_deco146.write_data(deco146_addr,data,cs);
end;

procedure robocop2_putword(direccion:dword;valor:word);
begin
case direccion of
  0..$fffff:; //ROM
  $140000..$14000f:deco16ic_0.control_w((direccion and $f) shr 1,valor);
  $144000..$144fff:if deco16ic_0.pf1.data[(direccion and $fff) shr 1]<>valor then begin
                      deco16ic_0.pf1.data[(direccion and $fff) shr 1]:=valor;
                      deco16ic_0.pf1.buffer[(direccion and $fff) shr 1]:=true
                   end;
  $146000..$146fff:if deco16ic_0.pf2.data[(direccion and $fff) shr 1]<>valor then begin
                      deco16ic_0.pf2.data[(direccion and $fff) shr 1]:=valor;
                      deco16ic_0.pf2.buffer[(direccion and $fff) shr 1]:=true
                   end;
  $14c000..$14c7ff:deco16ic_0.pf1.rowscroll[(direccion and $7ff) shr 1]:=valor;
  $14e000..$14e7ff:deco16ic_0.pf2.rowscroll[(direccion and $7ff) shr 1]:=valor;
  $150000..$15000f:begin
                      deco16ic_1.control_w((direccion and $f) shr 1,valor);
                      if ((direccion and $f)=0) then main_screen.flip_main_screen:=(valor and $0080)<>0
                   end;
	$154000..$154fff:if deco16ic_1.pf1.data[(direccion and $fff) shr 1]<>valor then begin
                      deco16ic_1.pf1.data[(direccion and $fff) shr 1]:=valor;
                      deco16ic_1.pf1.buffer[(direccion and $fff) shr 1]:=true
                   end;
  $156000..$156fff:if deco16ic_1.pf2.data[(direccion and $fff) shr 1]<>valor then begin
                      deco16ic_1.pf2.data[(direccion and $fff) shr 1]:=valor;
                      deco16ic_1.pf2.buffer[(direccion and $fff) shr 1]:=true
                   end;
  $15c000..$15c7ff:deco16ic_1.pf1.rowscroll[(direccion and $7ff) shr 1]:=valor;
  $15e000..$15e7ff:deco16ic_1.pf2.rowscroll[(direccion and $7ff) shr 1]:=valor;
  $180000..$1807ff:buffer_sprites_w[(direccion and $7ff) shr 1]:=valor;
  $18c000..$18ffff:robocop2_protection_deco_146_w(direccion-$18c000,valor);
  $198000..$198001:copymemory(@deco_sprites_0.ram[0],@buffer_sprites_w[0],$400*2);
  $1a0002..$1a00ff:;
  $1a8000..$1a9fff:if buffer_paleta[(direccion and $1fff) shr 1]<>valor then begin
                      buffer_paleta[(direccion and $1fff) shr 1]:=valor;
                      cambiar_color((direccion and $1fff) shr 2);
                   end;
  $1b0000..$1b0007:case ((direccion shr 1) and 7) of
	                    0:irq_mask:=valor and $ff; // IRQ enable:
	                    1:begin // Raster IRQ scanline position, only valid for values between 1 & 239 (0 and 240-256 do NOT generate IRQ's)
                          irq_line:=valor and $ff;
                          raster_irq:=(irq_line>0) and (irq_line<240) and ((irq_mask and $2)=0);
                        end;
                   end;
  $1b8000..$1bbfff:ram[(direccion and $3fff) shr 1]:=valor;
  $1f0000..$1f0001:if prioridad<>valor then begin
                     prioridad:=valor;
                     if (prioridad and 4)<>0 then begin
                        deco16ic_1.gfx_plane[2]:=4;
                        deco16ic_1.color_mask[2]:=0;
                     end else begin
                        deco16ic_1.gfx_plane[2]:=2;
                        deco16ic_1.color_mask[2]:=$f;
                     end;
                     fillchar(deco16ic_1.pf1.buffer[0],$800,1);
                     fillchar(deco16ic_1.pf2.buffer[0],$800,1);
                   end;
end;
end;

procedure sound_bank_rom(valor:byte);
begin
  copymemory(oki_6295_1.get_rom_addr,@oki_rom[valor and 1],$40000);
end;

function cninja_video_bank(bank:word):word;
begin
  	if ((bank shr 4) and $f)<>0 then cninja_video_bank:=$0 //Only 2 banks
	    else cninja_video_bank:=$1000;
end;

function robocop2_video_bank(bank:word):word;
begin
  	robocop2_video_bank:=(bank and $30) shl 8;
end;

//Main
procedure reset_cninja;
begin
 m68000_0.reset;
 deco16ic_0.reset;
 deco16ic_1.reset;
 deco_sprites_0.reset;
 case main_vars.tipo_maquina of
  162:main_deco104.reset;
  163:main_deco146.reset;
 end;
 deco16_snd_double_reset;
 copymemory(oki_6295_1.get_rom_addr,@oki_rom[0],$40000);
 reset_audio;
 marcade.in0:=$ffff;
 marcade.in1:=$f7;
 irq_mask:=0;
 raster_irq:=false;
end;

function iniciar_cninja:boolean;
const
  pt_x:array[0..15] of dword=(32*8+0, 32*8+1, 32*8+2, 32*8+3, 32*8+4, 32*8+5, 32*8+6, 32*8+7,
		0, 1, 2, 3, 4, 5, 6, 7);
  pt_y:array[0..15] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16,
			8*16, 9*16, 10*16, 11*16, 12*16, 13*16, 14*16, 15*16);
  ps_x:array[0..15] of dword=(64*8+0, 64*8+1, 64*8+2, 64*8+3, 64*8+4, 64*8+5, 64*8+6, 64*8+7,
		0, 1, 2, 3, 4, 5, 6, 7);
  ps_y:array[0..15] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32,
			8*32, 9*32, 10*32, 11*32, 12*32, 13*32, 14*32, 15*32);
var
  memoria_temp,memoria_temp2,ptemp,ptemp2:pbyte;
  tempw:word;
procedure cninja_convert_chars(num:word);
begin
  init_gfx(0,8,8,num);
  gfx[0].trans[0]:=true;
  gfx_set_desc_data(4,0,16*8,num*16*8+8,num*16*8+0,8,0);
  convert_gfx(0,0,memoria_temp,@pt_x[8],@pt_y,false,false);
end;
procedure cninja_convert_tiles(ngfx:byte;num:word);
begin
  init_gfx(ngfx,16,16,num);
  gfx[ngfx].trans[0]:=true;
  gfx_set_desc_data(4,0,64*8,num*64*8+8,num*64*8+0,8,0);
  convert_gfx(ngfx,0,memoria_temp2,@pt_x,@pt_y,false,false);
end;
procedure cninja_convert_sprites(num:dword);
begin
  init_gfx(3,16,16,num);
  gfx[3].trans[0]:=true;
  gfx_set_desc_data(4,0,128*8,16,0,24,8);
  convert_gfx(3,0,memoria_temp,@ps_x,@ps_y,false,false);
end;
begin
llamadas_maquina.bucle_general:=cninja_principal;
llamadas_maquina.reset:=reset_cninja;
llamadas_maquina.fps_max:=58;
iniciar_cninja:=false;
iniciar_audio(false);
case main_vars.tipo_maquina of
  162:begin
        tempw:=256;
        deco16ic_0:=chip_16ic.create(1,2,$000,$000,$f,$f,0,1,0,16,nil,nil);
        deco16ic_1:=chip_16ic.create(3,4,$000,$200,$f,$f,0,2,0,48,cninja_video_bank,cninja_video_bank);
        deco_sprites_0:=tdeco16_sprite.create(3,5,240,$300,$3fff);
      end;
  163:begin
        tempw:=320;
        deco16ic_0:=chip_16ic.create(1,2,$000,$000,$f,$f,0,1,0,16,nil,robocop2_video_bank);
        deco16ic_1:=chip_16ic.create(3,4,$000,$200,$f,$f,0,2,0,48,robocop2_video_bank,robocop2_video_bank);
        deco_sprites_0:=tdeco16_sprite.create(3,5,304,$300,$7fff);
      end;
end;
screen_init(5,512,512,false,true);
iniciar_video(tempw,240);
//Sound CPU
deco16_snd_double_init(32220000 div 8,32220000,sound_bank_rom);
getmem(memoria_temp,$300000);
case main_vars.tipo_maquina of
  162:begin //Caveman Ninja
        //Main CPU
        m68000_0:=cpu_m68000.create(12000000,$100);
        m68000_0.change_ram16_calls(cninja_getword,cninja_putword);
        proc_update_video:=update_video_cninja;
        //cargar roms
        if not(roms_load16w(@rom,cninja_rom)) then exit;
        //cargar sonido
        if not(roms_load(@mem_snd,cninja_sound)) then exit;
        //OKIs rom
        if not(roms_load(oki_6295_0.get_rom_addr,cninja_oki1)) then exit;
        if not(roms_load(memoria_temp,cninja_oki2)) then exit;
        ptemp:=memoria_temp;
        copymemory(@oki_rom[0],ptemp,$40000);
        inc(ptemp,$40000);
        copymemory(@oki_rom[1],ptemp,$40000);
        //convertir chars
        if not(roms_load16b(memoria_temp,cninja_chars)) then exit;
        cninja_convert_chars($1000);
        //Tiles
        getmem(memoria_temp2,$100000);
        if not(roms_load(memoria_temp2,cninja_tiles1)) then exit;
        cninja_convert_tiles(1,$1000);
        if not(roms_load(memoria_temp,cninja_tiles2)) then exit;
        //ordenar
        ptemp:=memoria_temp2;
        ptemp2:=memoria_temp;
        copymemory(ptemp,ptemp2,$40000);
        inc(ptemp2,$40000);
        inc(ptemp,$80000);
        copymemory(ptemp,ptemp2,$40000);
        inc(ptemp2,$40000);
        ptemp:=memoria_temp2;
        inc(ptemp,$40000);
        copymemory(ptemp,ptemp2,$40000);
        inc(ptemp2,$40000);
        inc(ptemp,$80000);
        copymemory(ptemp,ptemp2,$40000);
        cninja_convert_tiles(2,$2000);
        freemem(memoria_temp2);
        //Sprites
        if not(roms_load16b(memoria_temp,cninja_sprites)) then exit;
        cninja_convert_sprites($4000);
        //Proteccion deco104
        main_deco104:=cpu_deco_104.create;
        main_deco104.SET_USE_MAGIC_ADDRESS_XOR;
        //Dip
        marcade.dswa:=$7fff;
        marcade.dswa_val:=@cninja_dip;
  end;
  163:begin //Robocop 2
        //Main CPU
        m68000_0:=cpu_m68000.create(14000000,$100);
        m68000_0.change_ram16_calls(robocop2_getword,robocop2_putword);
        proc_update_video:=update_video_robocop2;
        //cargar roms
        if not(roms_load16w(@rom,robocop2_rom)) then exit;
        //cargar sonido
        if not(roms_load(@mem_snd,robocop2_sound)) then exit;
        //OKIs rom
        if not(roms_load(oki_6295_0.get_rom_addr,robocop2_oki1)) then exit;
        if not(roms_load(memoria_temp,robocop2_oki2)) then exit;
        ptemp:=memoria_temp;
        copymemory(@oki_rom[0],ptemp,$40000);
        inc(ptemp,$40000);
        copymemory(@oki_rom[1],ptemp,$40000);
        //convertir chars
        if not(roms_load16b(memoria_temp,robocop2_char)) then exit;
        cninja_convert_chars($1000);
        //Tiles
        if not(roms_load(memoria_temp,robocop2_tiles1)) then exit;
        getmem(memoria_temp2,$180000);
        ptemp:=memoria_temp2;
        ptemp2:=memoria_temp;
        copymemory(ptemp,ptemp2,$40000);
        inc(ptemp2,$40000);
        inc(ptemp,$80000);
        copymemory(ptemp,ptemp2,$40000);
        inc(ptemp2,$40000);
        ptemp:=memoria_temp2;
        inc(ptemp,$40000);
        copymemory(ptemp,ptemp2,$40000);
        inc(ptemp2,$40000);
        inc(ptemp,$80000);
        copymemory(ptemp,ptemp2,$40000);
        cninja_convert_tiles(1,$2000);
        //Tiles 2
        if not(roms_load(memoria_temp,robocop2_tiles2)) then exit;
        ptemp:=memoria_temp2;
        ptemp2:=memoria_temp;
        copymemory(ptemp,ptemp2,$40000);
        inc(ptemp,$c0000);
        inc(ptemp2,$40000);
        copymemory(ptemp,ptemp2,$40000);
        inc(ptemp2,$40000);
        ptemp:=memoria_temp2;
        inc(ptemp,$40000);
        copymemory(ptemp,ptemp2,$40000);
        inc(ptemp2,$40000);
        inc(ptemp,$c0000);
        copymemory(ptemp,ptemp2,$40000);
        inc(ptemp2,$40000);
        ptemp:=memoria_temp2;
        inc(ptemp,$80000);
        copymemory(ptemp,ptemp2,$40000);
        inc(ptemp2,$40000);
        inc(ptemp,$c0000);
        copymemory(ptemp,ptemp2,$40000);
        cninja_convert_tiles(2,$3000);
        //Tiles 8bbp
        init_gfx(4,16,16,$1000);
        gfx[4].trans[0]:=true;
        gfx_set_desc_data(8,0,64*8,$100000*8+8,$100000*8,$40000*8+8,$40000*8,$c0000*8+8,$c0000*8,8,0);
        convert_gfx(4,0,memoria_temp2,@pt_x,@pt_y,false,false);
        freemem(memoria_temp2);
        //Sprites
        if not(roms_load16b(memoria_temp,robocop2_sprites)) then exit;
        cninja_convert_sprites($6000);
        //Proteccion deco146
        main_deco146:=cpu_deco_146.create;
        main_deco146.SET_USE_MAGIC_ADDRESS_XOR;
        //Dip
        marcade.dswa:=$7fbf;
        marcade.dswa_val:=@robocop2_dip_a;
        marcade.dswb:=$ff;
        marcade.dswb_val:=@robocop2_dip_b;
  end;
end;
//final
freemem(memoria_temp);
reset_cninja;
iniciar_cninja:=true;
end;

end.
