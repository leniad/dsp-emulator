unit twincobra_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m68000,nz80,main_engine,controls_engine,gfx_engine,tms32010,ym_3812,
     rom_engine,pal_engine,sound_engine;

procedure cargar_twincobra;

implementation
const
        //Twin Cobra
        twincobr_rom:array[0..3] of tipo_roms=(
        (n:'b30-01';l:$10000;p:0;crc:$07f64d13),(n:'b30-03';l:$10000;p:$1;crc:$41be6978),
        (n:'tc15';l:$8000;p:$20000;crc:$3a646618),(n:'tc13';l:$8000;p:$20001;crc:$d7d1e317));
        twincobr_snd_rom:tipo_roms=(n:'tc12';l:$8000;p:0;crc:$e37b3c44);
        twincobr_char:array[0..2] of tipo_roms=(
        (n:'tc11';l:$4000;p:0;crc:$0a254133),(n:'tc03';l:$4000;p:$4000;crc:$e9e2d4b1),
        (n:'tc04';l:$4000;p:$8000;crc:$a599d845));
        twincobr_sprites:array[0..3] of tipo_roms=(
        (n:'tc20';l:$10000;p:0;crc:$cb4092b8),(n:'tc19';l:$10000;p:$10000;crc:$9cb8675e),
        (n:'tc18';l:$10000;p:$20000;crc:$806fb374),(n:'tc17';l:$10000;p:$30000;crc:$4264bff8));
        twincobr_fg_tiles:array[0..3] of tipo_roms=(
        (n:'tc01';l:$10000;p:0;crc:$15b3991d),(n:'tc02';l:$10000;p:$10000;crc:$d9e2e55d),
        (n:'tc06';l:$10000;p:$20000;crc:$13daeac8),(n:'tc05';l:$10000;p:$30000;crc:$8cc79357));
        twincobr_bg_tiles:array[0..3] of tipo_roms=(
        (n:'tc07';l:$8000;p:0;crc:$b5d48389),(n:'tc08';l:$8000;p:$8000;crc:$97f20fdc),
        (n:'tc09';l:$8000;p:$10000;crc:$170c01db),(n:'tc10';l:$8000;p:$18000;crc:$44f5accd));
        twincobr_mcu_rom:array[0..1] of tipo_roms=(
        (n:'dsp_22.bin';l:$800;p:0;crc:$79389a71),(n:'dsp_21.bin';l:$800;p:$1;crc:$2d135376));
        twincobr_dip_a:array [0..4] of def_dip=(
        (mask:$2;name:'Flip Screen';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$2;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Demo Sounds';number:2;dip:((dip_val:$8;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Coin A';number:4;dip:((dip_val:$30;dip_name:'4C 1C'),(dip_val:$20;dip_name:'3C 1C'),(dip_val:$10;dip_name:'2C 1C'),(dip_val:$0;dip_name:'1C 1C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Coin B';number:4;dip:((dip_val:$0;dip_name:'1C 2C'),(dip_val:$40;dip_name:'1C 3C'),(dip_val:$80;dip_name:'1C 4C'),(dip_val:$c0;dip_name:'1C 6C'),(),(),(),(),(),(),(),(),(),(),(),())),());
        twincobr_dip_b:array [0..4] of def_dip=(
        (mask:$3;name:'Difficulty';number:4;dip:((dip_val:$1;dip_name:'Easy'),(dip_val:$0;dip_name:'Normal'),(dip_val:$2;dip_name:'Hard'),(dip_val:$3;dip_name:'Very Hard'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Bonus Life';number:4;dip:((dip_val:$0;dip_name:'50K 200K 150K+'),(dip_val:$4;dip_name:'70K 270K 200K+'),(dip_val:$8;dip_name:'50K'),(dip_val:$c;dip_name:'100K'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Lives';number:4;dip:((dip_val:$30;dip_name:'2'),(dip_val:$0;dip_name:'3'),(dip_val:$20;dip_name:'4'),(dip_val:$10;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Dip Switch Display';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$40;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        //Flying Shark
        fshark_rom:array[0..1] of tipo_roms=(
        (n:'b02_18-1.m8';l:$10000;p:0;crc:$04739e02),(n:'b02_17-1.p8';l:$10000;p:$1;crc:$fd6ef7a8));
        fshark_snd_rom:tipo_roms=(n:'b02_16.l5';l:$8000;p:0;crc:$cdd1a153);
        fshark_char:array[0..2] of tipo_roms=(
        (n:'b02_07-1.h11';l:$4000;p:0;crc:$e669f80e),(n:'b02_06-1.h10';l:$4000;p:$4000;crc:$5e53ae47),
        (n:'b02_05-1.h8';l:$4000;p:$8000;crc:$a8b05bd0));
        fshark_sprites:array[0..3] of tipo_roms=(
        (n:'b02_01.d15';l:$10000;p:0;crc:$2234b424),(n:'b02_02.d16';l:$10000;p:$10000;crc:$30d4c9a8),
        (n:'b02_03.d17';l:$10000;p:$20000;crc:$64f3d88f),(n:'b02_04.d20';l:$10000;p:$30000;crc:$3b23a9fc));
        fshark_fg_tiles:array[0..3] of tipo_roms=(
        (n:'b02_12.h20';l:$8000;p:0;crc:$733b9997),(n:'b02_15.h24';l:$8000;p:$8000;crc:$8b70ef32),
        (n:'b02_14.h23';l:$8000;p:$10000;crc:$f711ba7d),(n:'b02_13.h21';l:$8000;p:$18000;crc:$62532cd3));
        fshark_bg_tiles:array[0..3] of tipo_roms=(
        (n:'b02_08.h13';l:$8000;p:0;crc:$ef0cf49c),(n:'b02_11.h18';l:$8000;p:$8000;crc:$f5799422),
        (n:'b02_10.h16';l:$8000;p:$10000;crc:$4bd099ff),(n:'b02_09.h15';l:$8000;p:$18000;crc:$230f1582));
        fshark_mcu_rom:array[0..7] of tipo_roms=(
        (n:'82s137-1.mcu';l:$400;p:0;crc:$cc5b3f53),(n:'82s137-2.mcu';l:$400;p:$400;crc:$47351d55),
        (n:'82s137-3.mcu';l:$400;p:$800;crc:$70b537b9),(n:'82s137-4.mcu';l:$400;p:$c00;crc:$6edb2de8),
        (n:'82s137-5.mcu';l:$400;p:$1000;crc:$f35b978a),(n:'82s137-6.mcu';l:$400;p:$1400;crc:$0459e51b),
        (n:'82s137-7.mcu';l:$400;p:$1800;crc:$cbf3184b),(n:'82s137-8.mcu';l:$400;p:$1c00;crc:$8246a05c));
        fshark_dip_a:array [0..5] of def_dip=(
        (mask:$1;name:'Cabinet';number:2;dip:((dip_val:$1;dip_name:'Upright'),(dip_val:$0;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),(mask:$2;name:'Flip Screen';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$2;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Demo Sounds';number:2;dip:((dip_val:$8;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Coin A';number:4;dip:((dip_val:$30;dip_name:'4C 1C'),(dip_val:$20;dip_name:'3C 1C'),(dip_val:$10;dip_name:'2C 1C'),(dip_val:$0;dip_name:'1C 1C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Coin B';number:4;dip:((dip_val:$0;dip_name:'1C 2C'),(dip_val:$40;dip_name:'1C 3C'),(dip_val:$80;dip_name:'1C 4C'),(dip_val:$c0;dip_name:'1C 6C'),(),(),(),(),(),(),(),(),(),(),(),())),());
        fshark_dip_b:array [0..5] of def_dip=(
        (mask:$3;name:'Difficulty';number:4;dip:((dip_val:$1;dip_name:'Easy'),(dip_val:$0;dip_name:'Normal'),(dip_val:$2;dip_name:'Hard'),(dip_val:$3;dip_name:'Very Hard'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Bonus Life';number:4;dip:((dip_val:$0;dip_name:'50K 200K 150K+'),(dip_val:$4;dip_name:'70K 270K 200K+'),(dip_val:$8;dip_name:'50K'),(dip_val:$c;dip_name:'100K'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Lives';number:4;dip:((dip_val:$30;dip_name:'2'),(dip_val:$0;dip_name:'3'),(dip_val:$20;dip_name:'1'),(dip_val:$10;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Dip Switch Display';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$40;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Allow Continue';number:2;dip:((dip_val:$0;dip_name:'No'),(dip_val:$80;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 rom:array[0..$17fff] of word;
 ram,bg_ram:array[0..$1fff] of word;
 display_on,int_enable,twincobr_dsp_BIO,dsp_execute:boolean;
 txt_ram,sprite_ram:array[0..$7ff] of word;
 fg_ram:array[0..$fff] of word;
 txt_offs,bg_offs,fg_offs,bg_bank,fg_bank:word;
 main_ram_seg,dsp_addr_w:dword;
 txt_scroll_x,txt_scroll_y,bg_scroll_x,bg_scroll_y,fg_scroll_x,fg_scroll_y:word;

procedure update_video_twincobr;
var
  f,color,nchar,x,y,atrib:word;

procedure draw_sprites(priority:word);
var
  f,atrib,x,y,nchar,color:word;
  flipx,flipy:boolean;
begin
for f:=0 to $1ff do begin
  atrib:=sprite_ram[$1+(f shl 2)];
  if ((atrib and $0c00)=priority) then begin
    x:=sprite_ram[3+(f shl 2)] shr 7;
    if (x and $1ff)>$100 then continue;
    nchar:=(sprite_ram[(f shl 2)]) and $7ff;
    color:=atrib and $3f;
    y:=512-(((sprite_ram[$2+(f shl 2)]) shr 7)+144) and $1ff;
    flipy:=(atrib and $100)<>0;
    flipx:=(atrib and $200)<>0;
    if flipy then y:=y+14;		// should really be 15 */
    put_gfx_sprite(nchar,color shl 4,flipx,flipy,3);
    actualiza_gfx_sprite((x-16) and $1ff,(y-32) and $1ff,4,3);
  end;
end;
end;

begin
if display_on then begin
  for f:=$7ff downto 0 do begin
    //Chars
    atrib:=txt_ram[f];
    color:=(atrib and $F800) shr 11;
    if (gfx[0].buffer[f] or buffer_color[color]) then begin
      x:=(f shr 6) shl 3;
      y:=(63-(f and $3f)) shl 3;
      nchar:=atrib and $7ff;
      put_gfx_trans(x,y,nchar,(color shl 3)+$600,1,0);
      gfx[0].buffer[f]:=false;
    end;
  end;
  for f:=0 to $fff do begin
      atrib:=bg_ram[f+bg_bank];
      color:=(atrib and $F000) shr 12;
      if (gfx[2].buffer[f+bg_bank] or buffer_color[color+$30]) then begin
        //background
        x:=(f shr 6) shl 3;
        y:=(63-(f and $3f)) shl 3;
        nchar:=atrib and $fff;
        put_gfx(x,y,nchar,(color shl 4)+$400,3,2);
        gfx[2].buffer[f+bg_bank]:=false;
      end;
      atrib:=fg_ram[f];
      color:=(atrib and $F000) shr 12;
      if (gfx[1].buffer[f] or buffer_color[color+$20]) then begin
        //foreground
        x:=(f shr 6) shl 3;
        y:=(63-(f and $3f)) shl 3;
        nchar:=(atrib and $fff)+fg_bank;
        put_gfx_trans(x,y,nchar,(color shl 4)+$500,2,1);
        gfx[1].buffer[f]:=false;
      end;
  end;
  scroll_x_y(3,4,bg_scroll_x+30,512-bg_scroll_y+137);
  draw_sprites($400);
  scroll_x_y(2,4,fg_scroll_x+30,512-fg_scroll_y+137);
  draw_sprites($800);
  scroll_x_y(1,4,256-txt_scroll_x-30,512-txt_scroll_y+137);
  draw_sprites($c00);
end else fill_full_screen(4,$7ff);
actualiza_trozo_final(0,0,240,320,4);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure eventos_twincobr;
begin
if event.arcade then begin
  //P1
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 or $4) else marcade.in0:=(marcade.in0 and $fb);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 or $8) else marcade.in0:=(marcade.in0 and $f7);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 or $1) else marcade.in0:=(marcade.in0 and $fe);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 or $2) else marcade.in0:=(marcade.in0 and $fd);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 or $20) else marcade.in0:=(marcade.in0 and $df);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 or $10) else marcade.in0:=(marcade.in0 and $ef);
  //P1
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 or $4) else marcade.in1:=(marcade.in1 and $fb);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 or $8) else marcade.in1:=(marcade.in1 and $f7);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 or $1) else marcade.in1:=(marcade.in1 and $fe);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 or $2) else marcade.in1:=(marcade.in1 and $fd);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 or $20) else marcade.in1:=(marcade.in1 and $df);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 or $10) else marcade.in1:=(marcade.in1 and $ef);
  //SYSTEM
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 or $8) else marcade.in2:=(marcade.in2 and $f7);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 or $10) else marcade.in2:=(marcade.in2 and $ef);
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 or $20) else marcade.in2:=(marcade.in2 and $df);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 or $40) else marcade.in2:=(marcade.in2 and $bf);
end;
end;

procedure twincobra_principal;
var
  f:word;
  frame_m,frame_s,frame_mcu:single;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
frame_s:=z80_0.tframes;
frame_mcu:=tms32010_0.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to 285 do begin
    //MAIN CPU
    m68000_0.run(frame_m);
    frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
    //SND CPU
    z80_0.run(frame_s);
    frame_s:=frame_s+z80_0.tframes-z80_0.contador;
    //MCU
    tms32010_0.run(frame_mcu);
    frame_mcu:=frame_mcu+tms32010_0.tframes-tms32010_0.contador;
    case f of
      0:marcade.in2:=marcade.in2 and $7f;
      240:begin
            marcade.in2:=marcade.in2 or $80;
            if int_enable then begin
                m68000_0.irq[4]:=HOLD_LINE;
                int_enable:=false;
            end;
            update_video_twincobr;
          end;
    end;
  end;
  eventos_twincobr;
  video_sync;
end;
end;

//Main CPU
function twincobr_getword(direccion:dword):word;
begin
case direccion of
  0..$2ffff:twincobr_getword:=rom[direccion shr 1];
  $30000..$33fff:twincobr_getword:=ram[(direccion and $3fff) shr 1];
  $40000..$40fff:twincobr_getword:=sprite_ram[(direccion and $fff) shr 1];
  $50000..$50dff:twincobr_getword:=buffer_paleta[(direccion and $fff) shr 1];
  $78000:twincobr_getword:=marcade.dswa;
  $78002:twincobr_getword:=marcade.dswb;
  $78004:twincobr_getword:=marcade.in0;
  $78006:twincobr_getword:=marcade.in1;
  $78008:twincobr_getword:=marcade.in2;
  $7e000:twincobr_getword:=txt_ram[txt_offs];
  $7e002:twincobr_getword:=bg_ram[bg_offs+bg_bank];
  $7e004:twincobr_getword:=fg_ram[fg_offs];
  $7a000..$7afff:twincobr_getword:=mem_snd[$8000+((direccion and $fff) shr 1)]; //Shared RAM
end;
end;

procedure twincobr_putword(direccion:dword;valor:word);

procedure cambiar_color(numero,valor:word);
var
  color:tcolor;
begin
  color.b:=pal5bit(valor shr 10);
  color.g:=pal5bit(valor shr 5);
  color.r:=pal5bit(valor);
  set_pal_color(color,numero);
  case numero of
    1024..1279:buffer_color[((numero shr 4) and $f)+$30]:=true;
    1280..1535:buffer_color[((numero shr 4) and $f)+$20]:=true;
    1536..1791:buffer_color[(numero shr 3) and $1f]:=true;
  end;
end;

begin
case direccion of
  0..$2ffff:;
  $30000..$33fff:ram[(direccion and $3fff) shr 1]:=valor;
  $3ffe0..$3ffef:;
  $40000..$40fff:sprite_ram[(direccion and $fff) shr 1]:=valor;
  $50000..$50dff:if buffer_paleta[(direccion and $fff) shr 1]<>valor then begin
                    buffer_paleta[(direccion and $fff) shr 1]:=valor;
                    cambiar_color((direccion and $ffe) shr 1,valor);
                 end;
  $60000..$60003:;
  $70000:txt_scroll_y:=valor;
  $70002:txt_scroll_x:=valor;
  $70004:txt_offs:=valor and $7ff;
  $72000:bg_scroll_y:=valor;
  $72002:bg_scroll_x:=valor;
  $72004:bg_offs:=valor and $fff;
  $74000:fg_scroll_y:=valor;
  $74002:fg_scroll_x:=valor;
  $74004:fg_offs:=valor and $fff;
  $76000..$76003:;
  $7800a:case (valor and $ff) of
        $00:begin	// This means assert the INT line to the DSP */
	            tms32010_0.change_halt(CLEAR_LINE);
              m68000_0.change_halt(ASSERT_LINE);
              tms32010_0.change_irq(ASSERT_LINE);
	          end;
        $01:begin	// This means inhibit the INT line to the DSP */
              tms32010_0.change_irq(CLEAR_LINE);
	            tms32010_0.change_halt(ASSERT_LINE);
            end;
         end;
  $7800c:case (valor and $ff) of
		        $04:int_enable:=false;
		        $05:int_enable:=true;
            $06,$07:;
            $08:bg_bank:=$0000;
            $09:bg_bank:=$1000;
		        $0a:fg_bank:=$0000;
            $0b:fg_bank:=$1000;
            $0c:begin	// This means assert the INT line to the DSP */
    		          tms32010_0.change_halt(CLEAR_LINE);
                  m68000_0.change_halt(ASSERT_LINE);
                  tms32010_0.change_irq(ASSERT_LINE);
		            end;
	          $0d:begin	// This means inhibit the INT line to the DSP */
                  tms32010_0.change_irq(CLEAR_LINE);
                  tms32010_0.change_halt(ASSERT_LINE);
                end;
            $0e:display_on:=false;
            $0f:display_on:=true;
         end;
  $7e000:if txt_ram[txt_offs]<>valor then begin
            txt_ram[txt_offs]:=valor;
            gfx[0].buffer[txt_offs]:=true;
         end;
  $7e002:if bg_ram[bg_offs+bg_bank]<>valor then begin
            bg_ram[bg_offs+bg_bank]:=valor;
            gfx[2].buffer[bg_offs+bg_bank]:=true;
         end;
  $7e004:if fg_ram[fg_offs]<>valor then begin
            fg_ram[fg_offs]:=valor;
            gfx[1].buffer[fg_offs]:=true;
         end;
  $7a000..$7afff:mem_snd[$8000+((direccion and $fff) shr 1)]:=valor and $ff; //Shared RAM
end;
end;

function twincobr_snd_getbyte(direccion:word):byte;
begin
if direccion<$8800 then twincobr_snd_getbyte:=mem_snd[direccion];
end;

procedure twincobr_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:;
  $8000..$87ff:mem_snd[direccion]:=valor;
end;
end;

function twincobr_snd_inbyte(puerto:word):byte;
begin
case (puerto and $ff) of
  0:twincobr_snd_inbyte:=ym3812_0.status;
  $10:twincobr_snd_inbyte:=marcade.in2;
  $20,$30:twincobr_snd_inbyte:=0;
  $40:twincobr_snd_inbyte:=marcade.dswa;
  $50:twincobr_snd_inbyte:=marcade.dswb;
end;
end;

procedure twincobr_snd_outbyte(puerto:word;valor:byte);
begin
case (puerto and $ff) of
  $0:ym3812_0.control(valor);
  $1:ym3812_0.write(valor);
end;
end;

procedure snd_irq(irqstate:byte);
begin
  z80_0.change_irq(irqstate);
end;

function twincobr_dsp_r:word;
begin
	// DSP can read data from main CPU RAM via DSP IO port 1 */
	case main_ram_seg of
		$30000,$40000,$50000:twincobr_dsp_r:=twincobr_getword(main_ram_seg+dsp_addr_w);
      else twincobr_dsp_r:=0;
	end;
end;

procedure twincobr_dsp_w(valor:word);
begin
  // Data written to main CPU RAM via DSP IO port 1 */
	dsp_execute:=false;
	case main_ram_seg of
    $30000:begin
              if ((dsp_addr_w<3) and (valor=0)) then dsp_execute:=true;
              twincobr_putword(main_ram_seg+dsp_addr_w,valor);
           end;
		$40000,$50000:twincobr_putword(main_ram_seg+dsp_addr_w,valor);
	end;
end;

procedure twincobr_dsp_addrsel_w(valor:word);
begin
  main_ram_seg:=((valor and $e000) shl 3);
	dsp_addr_w:=((valor and $1fff) shl 1);
end;

procedure twincobr_dsp_bio_w(valor:word);
begin
  twincobr_dsp_BIO:=(valor and $8000)=0;
	if (valor=0) then begin
		if dsp_execute then begin
      m68000_0.change_halt(CLEAR_LINE);
			dsp_execute:=false;
		end;
		twincobr_dsp_BIO:=true;
	end;
end;

function twincobr_BIO_r:boolean;
begin
  twincobr_BIO_r:=twincobr_dsp_BIO;
end;

procedure twincobr_update_sound;
begin
  ym3812_0.update;
end;

//Main
procedure reset_twincobra;
begin
 m68000_0.reset;
 z80_0.reset;
 tms32010_0.reset;
 ym3812_0.reset;
 reset_audio;
 txt_scroll_y:=457;
 txt_scroll_x:=226;
 bg_scroll_x:=40;
 bg_scroll_y:=0;
 fg_scroll_x:=0;
 fg_scroll_y:=0;
 marcade.in0:=0;
 marcade.in1:=0;
 marcade.in2:=0;
 txt_offs:=0;
 bg_offs:=0;
 fg_offs:=0;
 bg_bank:=0;
 fg_bank:=0;
 int_enable:=false;
 display_on:=true;
 twincobr_dsp_BIO:=false;
 dsp_execute:=false;
 main_ram_seg:=0;
 dsp_addr_w:=0;
end;

function iniciar_twincobra:boolean;
var
    memoria_temp:array[0..$3ffff] of byte;
    temp_rom:array[0..$fff] of word;
    f:word;
const
    pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
    ps_x:array[0..15] of dword=(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15);
    ps_y:array[0..15] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16,
			8*16, 9*16, 10*16, 11*16, 12*16, 13*16, 14*16, 15*16);
procedure convert_chars;
begin
  init_gfx(0,8,8,2048);
  gfx[0].trans[0]:=true;
  gfx_set_desc_data(3,0,8*8,0*2048*8*8,1*2048*8*8,2*2048*8*8);
  convert_gfx(0,0,@memoria_temp,@ps_x,@pc_y,false,true);
end;

procedure convert_tiles(ngfx:byte;ntiles:word);
begin
init_gfx(ngfx,8,8,ntiles);
gfx[ngfx].trans[0]:=true;
gfx_set_desc_data(4,0,8*8,0*ntiles*8*8,1*ntiles*8*8,2*ntiles*8*8,3*ntiles*8*8);
convert_gfx(ngfx,0,@memoria_temp,@ps_x,@pc_y,false,true);
end;

procedure convert_sprites;
begin
init_gfx(3,16,16,2048);
gfx[3].trans[0]:=true;
gfx_set_desc_data(4,0,32*8,0*2048*32*8,1*2048*32*8,2*2048*32*8,3*2048*32*8);
convert_gfx(3,0,@memoria_temp,@ps_x,@ps_y,false,true);
end;

begin
iniciar_twincobra:=false;
iniciar_audio(false);
screen_init(1,256,512,true);
screen_mod_scroll(1,256,256,255,512,512,511);
screen_init(2,512,512,true);
screen_mod_scroll(2,512,256,511,512,512,511);
screen_init(3,512,512);
screen_mod_scroll(3,512,256,511,512,512,511);
screen_init(4,512,512,false,true);
iniciar_video(240,320);
//Main CPU
m68000_0:=cpu_m68000.create(24000000 div 4,286);
m68000_0.change_ram16_calls(twincobr_getword,twincobr_putword);
//Sound CPU
z80_0:=cpu_z80.create(3500000,286);
z80_0.change_ram_calls(twincobr_snd_getbyte,twincobr_snd_putbyte);
z80_0.change_io_calls(twincobr_snd_inbyte,twincobr_snd_outbyte);
z80_0.init_sound(twincobr_update_sound);
//TMS MCU
tms32010_0:=cpu_tms32010.create(14000000,286);
tms32010_0.change_io_calls(twincobr_BIO_r,nil,twincobr_dsp_r,nil,nil,nil,nil,nil,nil,twincobr_dsp_addrsel_w,twincobr_dsp_w,nil,twincobr_dsp_bio_w,nil,nil,nil,nil);
//Sound Chips
ym3812_0:=ym3812_chip.create(YM3812_FM,3500000);
ym3812_0.change_irq_calls(snd_irq);
case main_vars.tipo_maquina of
    146:begin
          //cargar roms
          if not(roms_load16w(@rom,twincobr_rom)) then exit;
          //cargar ROMS sonido
          if not(roms_load(@mem_snd,twincobr_snd_rom)) then exit;
          //cargar ROMS MCU
          if not(roms_load16b(tms32010_0.get_rom_addr,twincobr_mcu_rom)) then exit;
          //convertir chars
          if not(roms_load(@memoria_temp,twincobr_char)) then exit;
          convert_chars;
          //convertir tiles fg
          if not(roms_load(@memoria_temp,twincobr_fg_tiles)) then exit;
          convert_tiles(1,8192);
          //convertir tiles bg
          if not(roms_load(@memoria_temp,twincobr_bg_tiles)) then exit;
          convert_tiles(2,4096);
          //convertir tiles sprites
          if not(roms_load(@memoria_temp,twincobr_sprites)) then exit;
          convert_sprites;
          marcade.dswa:=0;
          marcade.dswb:=0;
          marcade.dswa_val:=@twincobr_dip_a;
          marcade.dswb_val:=@twincobr_dip_b;
    end;
    147:begin
          //cargar roms
          if not(roms_load16w(@rom,fshark_rom)) then exit;
          //cargar ROMS sonido
          if not(roms_load(@mem_snd,fshark_snd_rom)) then exit;
          //cargar ROMS MCU
          if not(roms_load(@memoria_temp,fshark_mcu_rom)) then exit;
          for f:=0 to $3ff do begin
            temp_rom[f]:=(((memoria_temp[f] and $f) shl 4+(memoria_temp[f+$400] and $f)) shl 8) or
              (memoria_temp[f+$800] and $f) shl 4+(memoria_temp[f+$c00] and $f);
          end;
          for f:=0 to $3ff do begin
             temp_rom[f+$400]:=(((memoria_temp[f+$1000] and $f) shl 4+(memoria_temp[f+$1400] and $f)) shl 8) or
              (memoria_temp[f+$1800] and $f) shl 4+(memoria_temp[f+$1c00] and $f);
          end;
          copymemory(tms32010_0.get_rom_addr,@temp_rom,$1000);
          //convertir chars
          if not(roms_load(@memoria_temp,fshark_char)) then exit;
          convert_chars;
          //convertir tiles fg
          if not(roms_load(@memoria_temp,fshark_fg_tiles)) then exit;
          convert_tiles(1,4096);
          //convertir tiles bg
          if not(roms_load(@memoria_temp,fshark_bg_tiles)) then exit;
          convert_tiles(2,4096);
          //convertir tiles sprites
          if not(roms_load(@memoria_temp,fshark_sprites)) then exit;
          convert_sprites;
          marcade.dswa:=1;
          marcade.dswb:=$80;
          marcade.dswa_val:=@fshark_dip_a;
          marcade.dswb_val:=@fshark_dip_b;
    end;
end;
//final
reset_twincobra;
iniciar_twincobra:=true;
end;

procedure Cargar_twincobra;
begin
llamadas_maquina.iniciar:=iniciar_twincobra;
llamadas_maquina.bucle_general:=twincobra_principal;
llamadas_maquina.reset:=reset_twincobra;
llamadas_maquina.fps_max:=(28000000/4)/(446*286);
end;

end.
