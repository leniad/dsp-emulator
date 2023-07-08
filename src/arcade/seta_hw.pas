unit seta_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m68000,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     sound_engine,m6502,seta_sprites,ym_2203,ym_3812,x1_010,misc_functions;

function iniciar_seta:boolean;

implementation
const
        //Thundercade
        tndrcade_rom:array[0..3] of tipo_roms=(
        (n:'ua0-4.u19';l:$20000;p:0;crc:$73bd63eb),(n:'ua0-2.u17';l:$20000;p:$1;crc:$e96194b1),
        (n:'ua0-3.u18';l:$20000;p:$40000;crc:$0a7b1c41),(n:'ua0-1.u16';l:$20000;p:$40001;crc:$fa906626));
        tndrcade_snd:tipo_roms=(n:'ua10-5.u24';l:$20000;p:0;crc:$8eff6122);
        tndrcade_sprites:array[0..7] of tipo_roms=(
        (n:'ua0-10.u12';l:$40000;p:0;crc:$aa7b6757),(n:'ua0-11.u13';l:$40000;p:$40000;crc:$11eaf931),
        (n:'ua0-12.u14';l:$40000;p:$80000;crc:$00b5381c),(n:'ua0-13.u15';l:$40000;p:$c0000;crc:$8f9a0ed3),
        (n:'ua0-6.u8';l:$40000;p:$100000;crc:$14ecc7bb),(n:'ua0-7.u9';l:$40000;p:$140000;crc:$ff1a4e68),
        (n:'ua0-8.u10';l:$40000;p:$180000;crc:$936e1884),(n:'ua0-9.u11';l:$40000;p:$1c0000;crc:$e812371c));
        tndrcade_dip:array [0..10] of def_dip=(
        (mask:$3;name:'Difficulty';number:4;dip:((dip_val:$2;dip_name:'Easy'),(dip_val:$3;dip_name:'Normal'),(dip_val:$1;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Bonus Life';number:4;dip:((dip_val:$c;dip_name:'50K'),(dip_val:$4;dip_name:'50K 150K+'),(dip_val:$0;dip_name:'70K 200K+'),(dip_val:$8;dip_name:'100K'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Lives';number:4;dip:((dip_val:$10;dip_name:'1'),(dip_val:$0;dip_name:'2'),(dip_val:$30;dip_name:'3'),(dip_val:$20;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Allow Continue';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$40;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Licensed To';number:2;dip:((dip_val:$80;dip_name:'Taito America Corp.'),(dip_val:$0;dip_name:'Taito Corp. Japan'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$100;name:'Title';number:2;dip:((dip_val:$100;dip_name:'Thundercade'),(dip_val:$0;dip_name:'Twin Formation'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$200;name:'Flip Screen';number:2;dip:((dip_val:$200;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$800;name:'Demo Sounds';number:2;dip:((dip_val:$800;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$3000;name:'Coin A';number:4;dip:((dip_val:$1000;dip_name:'2C 1C'),(dip_val:$3000;dip_name:'1C 1C'),(dip_val:$0;dip_name:'2C 3C'),(dip_val:$2000;dip_name:'1C 2C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c000;name:'Coin B';number:4;dip:((dip_val:$4000;dip_name:'2C 1C'),(dip_val:$c000;dip_name:'1C 1C'),(dip_val:$0;dip_name:'2C 3C'),(dip_val:$8000;dip_name:'1C 2C'),(),(),(),(),(),(),(),(),(),(),(),())),());
        //Twin Eagle
        twineagl_rom:tipo_roms=(n:'ua2-1';l:$80000;p:0;crc:$5c3fe531);
        twineagl_snd:tipo_roms=(n:'ua2-2';l:$2000;p:0;crc:$783ca84e);
        twineagl_sprites:array[0..3] of tipo_roms=(
        (n:'ua2-4';l:$40000;p:1;crc:$8b7532d6),(n:'ua2-3';l:$40000;p:$0;crc:$1124417a),
        (n:'ua2-6';l:$40000;p:$80001;crc:$99d8dbba),(n:'ua2-5';l:$40000;p:$80000;crc:$6e450d28));
        twineagl_tiles:array[0..3] of tipo_roms=(
        (n:'ua2-7';l:$80000;p:0;crc:$fce56907),(n:'ua2-8';l:$80000;p:$1;crc:$7d3a8d73),
        (n:'ua2-9';l:$80000;p:$100000;crc:$a451eae9),(n:'ua2-10';l:$80000;p:$100001;crc:$5bbe1f56));
        twineagl_pcm:array[0..1] of tipo_roms=(
        (n:'ua2-11';l:$80000;p:0;crc:$624e6057),(n:'ua2-12';l:$80000;p:$80000;crc:$3068ff64));
        twineagl_dip:array [0..10] of def_dip=(
        (mask:$1;name:'Copyright / License';number:2;dip:((dip_val:$0;dip_name:'Taito America / Romstar'),(dip_val:$1;dip_name:'Taito Corp Japan'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2;name:'Flip Screen';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$8;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Coin A';number:4;dip:((dip_val:$10;dip_name:'2C 1C'),(dip_val:$30;dip_name:'1C 1C'),(dip_val:$0;dip_name:'2C 3C'),(dip_val:$20;dip_name:'1C 2C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Coin B';number:4;dip:((dip_val:$40;dip_name:'2C 1C'),(dip_val:$c0;dip_name:'1C 1C'),(dip_val:$0;dip_name:'2C 3C'),(dip_val:$80;dip_name:'1C 2C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$300;name:'Difficulty';number:4;dip:((dip_val:$200;dip_name:'Easy'),(dip_val:$300;dip_name:'Normal'),(dip_val:$100;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c00;name:'Bonus Life';number:4;dip:((dip_val:$c00;dip_name:'Never'),(dip_val:$800;dip_name:'500K'),(dip_val:$400;dip_name:'1000K'),(dip_val:$8;dip_name:'500K 1500K'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$3000;name:'Lives';number:4;dip:((dip_val:$1000;dip_name:'1'),(dip_val:$0;dip_name:'2'),(dip_val:$3000;dip_name:'3'),(dip_val:$2000;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4000;name:'Licensor Option';number:2;dip:((dip_val:$4000;dip_name:'Option 1'),(dip_val:$0;dip_name:'Option 2'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8000;name:'Coinage Type';number:2;dip:((dip_val:$8000;dip_name:'Coin Mode 2'),(dip_val:$0;dip_name:'Coin Mode 2'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        //Thunder & Lightning
        thunderl_rom:array[0..1] of tipo_roms=(
        (n:'m4';l:$8000;p:0;crc:$1e6b9462),(n:'m5';l:$8000;p:$1;crc:$7e82793e));
        thunderl_sprites:array[0..3] of tipo_roms=(
        (n:'t17';l:$20000;p:1;crc:$599a632a),(n:'t16';l:$20000;p:$0;crc:$3aeef91c),
        (n:'t15';l:$20000;p:$40001;crc:$b97a7b56),(n:'t14';l:$20000;p:$40000;crc:$79c707be));
        thunderl_pcm:array[0..1] of tipo_roms=(
        (n:'r28';l:$80000;p:0;crc:$a043615d),(n:'r27';l:$80000;p:$80000;crc:$cb8425a3));
        thunderl_dip_a:array [0..2] of def_dip=(
        (mask:$10;name:'Force 1 Life';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$10;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$e0;name:'Copyright';number:8;dip:((dip_val:$80;dip_name:'Romstar'),(dip_val:$c0;dip_name:'Seta (Romstar License)'),(dip_val:$e0;dip_name:'Seta (Visco License)'),(dip_val:$a0;dip_name:'Visco'),(dip_val:$60;dip_name:'None'),(dip_val:$40;dip_name:'None'),(dip_val:$20;dip_name:'None'),(dip_val:$0;dip_name:'None'),(),(),(),(),(),(),(),())),());
        thunderl_dip_b:array [0..8] of def_dip=(
        (mask:$0f;name:'Coin A';number:16;dip:((dip_val:$0c;dip_name:'4C 1C'),(dip_val:$0d;dip_name:'3C 1C'),(dip_val:$08;dip_name:'4C 2C'),(dip_val:$0e;dip_name:'2C 1C'),(dip_val:$09;dip_name:'3C 2C'),(dip_val:$04;dip_name:'4C 3C'),(dip_val:$0;dip_name:'4C 4C'),(dip_val:$05;dip_name:'3C 3C'),(dip_val:$0a;dip_name:'3C 3C'),(dip_val:$0f;dip_name:'1C 1C'),(dip_val:$01;dip_name:'3C 4C'),(dip_val:$06;dip_name:'2C 3C'),(dip_val:$02;dip_name:'2C 4C'),(dip_val:$0b;dip_name:'1C 2C'),(dip_val:$07;dip_name:'1C 3C'),(dip_val:$03;dip_name:'1C 4C'))),
        (mask:$f0;name:'Coin B';number:16;dip:((dip_val:$c0;dip_name:'4C 1C'),(dip_val:$d0;dip_name:'3C 1C'),(dip_val:$80;dip_name:'4C 2C'),(dip_val:$e0;dip_name:'2C 1C'),(dip_val:$90;dip_name:'3C 2C'),(dip_val:$40;dip_name:'4C 3C'),(dip_val:$0;dip_name:'4C 4C'),(dip_val:$50;dip_name:'3C 3C'),(dip_val:$a0;dip_name:'3C 3C'),(dip_val:$f0;dip_name:'1C 1C'),(dip_val:$10;dip_name:'3C 4C'),(dip_val:$60;dip_name:'2C 3C'),(dip_val:$20;dip_name:'2C 4C'),(dip_val:$b0;dip_name:'1C 2C'),(dip_val:$70;dip_name:'1C 3C'),(dip_val:$30;dip_name:'1C 4C'))),
        (mask:$200;name:'Flip Screen';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$200;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$400;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$400;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$800;name:'Controls';number:2;dip:((dip_val:$800;dip_name:'2'),(dip_val:$0;dip_name:'1'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$1000;name:'Demo Sounds';number:2;dip:((dip_val:$1000;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2000;name:'Lives';number:2;dip:((dip_val:$2000;dip_name:'3'),(dip_val:$0;dip_name:'2'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c000;name:'Difficulty';number:4;dip:((dip_val:$8000;dip_name:'Easy'),(dip_val:$c000;dip_name:'Normal'),(dip_val:$4000;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 rom:array[0..$4ffff] of word;
 ram:array[0..$7ffff] of word;
 shared_ram:array[0..$7ff] of byte;
 scanlines_proc:procedure(line:byte);
 eventos_proc:procedure;
 //Twin Eagle
 vram0:array[0..$1fff] of word;
 tilebank:array[0..3] of word;
 scroll_x,scroll_y,vram_control:word;
 xtra_mem:array[0..7] of byte;
 //Sound
 rom_snd:array[0..$f,0..$3fff] of byte;
 sound_latch0,sound_latch1,snd_bank:byte;
 control_data:word;
 //Thunder & lighting
 thunderl_protection_reg:word;


procedure update_video_seta_sprites;
begin
  if (seta_sprite0.bg_flag and $80)=0 then fill_full_screen(1,$1f0);
  seta_sprite0.draw_sprites;
  actualiza_trozo_final(0,16,384,224,1);
end;

procedure cambiar_color(pos,data:word);
var
  color:tcolor;
begin
		color.r:=pal5bit(data shr 10);
		color.g:=pal5bit(data shr 5);
		color.b:=pal5bit(data);
    set_pal_color(color,pos);
    buffer_color[pos shr 4]:=true;
end;

procedure eventos_seta;
begin
if event.arcade then begin
  //p1
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  //p2
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or 8);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  //coins
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or 1);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or 2);
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or 4);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or 8);
end;
end;

procedure seta_principal_snd_cpu;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
frame_s:=m6502_0.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to 255 do begin
    //main
    m68000_0.run(frame_m);
    frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
    //sound
    m6502_0.run(frame_s);
    frame_s:=frame_s+m6502_0.tframes-m6502_0.contador;
    scanlines_proc(f);
 end;
 eventos_seta;
 video_sync;
end;
end;

procedure seta_principal;
var
  frame_m:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to 255 do begin
    //main
    m68000_0.run(frame_m);
    frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
    scanlines_proc(f);
 end;
 eventos_proc;
 video_sync;
end;
end;

procedure seta_sound_update;
begin
  x1_010_0.update;
end;

function seta_sprite_cb(code,color:word):word;
var
  bank:byte;
begin
  bank:=(color and $6) shr 1;
	code:=(code and $3fff)+(bank*$4000);
	seta_sprite_cb:=code;
end;

//Thundercade
procedure tndrcade_scan_lines(line:byte);
begin
case line of
  0,16,32,48,64,80,96,112,128,144,160,176,192,208,224:m6502_0.change_irq(HOLD_LINE);
  239:begin
        m68000_0.irq[2]:=ASSERT_LINE;
        m6502_0.change_nmi(PULSE_LINE);
        m6502_0.change_irq(HOLD_LINE);
        update_video_seta_sprites;
      end;
end;
end;

function tndrcade_getword(direccion:dword):word;
begin
case direccion of
    0..$7ffff:tndrcade_getword:=rom[direccion shr 1];
    $380000..$3803ff:tndrcade_getword:=buffer_paleta[(direccion and $3ff) shr 1];
    $600000..$6005ff:tndrcade_getword:=seta_sprite0.spritey[(direccion and $fff) shr 1];
    $600600..$600607:tndrcade_getword:=seta_sprite0.control[(direccion and $7) shr 1];
    $a00000..$a00fff:tndrcade_getword:=shared_ram[(direccion and $fff) shr 1];
    $c00000..$c03fff:tndrcade_getword:=seta_sprite0.spritelow[(direccion and $3fff) shr 1]+(seta_sprite0.spritehigh[(direccion and $3fff) shr 1] shl 8);
    $e00000..$e03fff,$ffc000..$ffffff:tndrcade_getword:=ram[(direccion and $3fff) shr 1];
end;
end;

procedure tndrcade_putword(direccion:dword;valor:word);
begin
case direccion of
    0..$7ffff:;
    $200000:m68000_0.irq[2]:=CLEAR_LINE;
    $380000..$3803ff:if buffer_paleta[(direccion and $3ff) shr 1]<>valor then begin
                      buffer_paleta[(direccion and $3ff) shr 1]:=valor;
                      cambiar_color((direccion and $3ff) shr 1,valor);
                     end;
    $600000..$6005ff:seta_sprite0.spritey[(direccion and $7ff) shr 1]:=valor and $ff;
    $600600..$600607:seta_sprite0.control[(direccion and $7) shr 1]:=valor and $ff;
    $800000..$800007:case ((direccion and $7) shr 1) of
                        0:begin
                            if (((control_data and 1)=0) and ((valor and 1)<>0))  then
                              m6502_0.change_reset(HOLD_LINE);
                            control_data:=valor;
                          end;
                        1:;
                        2:;
                        3:;
                     end;
    $a00000..$a00fff:shared_ram[(direccion and $fff) shr 1]:=valor and $ff;
    $c00000..$c03fff:begin
                        seta_sprite0.spritelow[(direccion and $3fff) shr 1]:=valor and $ff;
                        seta_sprite0.spritehigh[(direccion and $3fff) shr 1]:=valor shr 8;
                     end;
    $e00000..$e03fff,$ffc000..$ffffff:ram[(direccion and $3fff) shr 1]:=valor;
end;
end;

function tndrcade_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$1ff,$6000..$7fff,$c000..$ffff:tndrcade_snd_getbyte:=mem_snd[direccion];
  $800:tndrcade_snd_getbyte:=$ff;
  $1000:tndrcade_snd_getbyte:=marcade.in0; //p1
  $1001:tndrcade_snd_getbyte:=marcade.in1; //p2
  $1002:tndrcade_snd_getbyte:=marcade.in2; //coin
  $2000:tndrcade_snd_getbyte:=ym2203_0.status;
  $2001:tndrcade_snd_getbyte:=ym2203_0.read;
  $5000..$57ff:tndrcade_snd_getbyte:=shared_ram[direccion and $7ff];
  $8000..$bfff:tndrcade_snd_getbyte:=rom_snd[snd_bank,direccion and $3fff];
end;
end;

procedure tndrcade_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$1ff:mem_snd[direccion]:=valor;
  $1000:snd_bank:=valor shr 4;
  $2000:ym2203_0.control(valor);
  $2001:ym2203_0.write(valor);
  $3000:ym3812_0.control(valor);
  $3001:ym3812_0.write(valor);
  $5000..$57ff:shared_ram[direccion and $7ff]:=valor;
  $6000..$ffff:;
end;
end;

function tndrcade_porta_read:byte;
begin
  tndrcade_porta_read:=marcade.dswa shr 8;
end;

function tndrcade_portb_read:byte;
begin
  tndrcade_portb_read:=marcade.dswa and $ff;
end;

procedure tndrcade_sound_update;
begin
  ym2203_0.update;
  ym3812_0.update;
end;

//Twin Eagle
procedure update_video_twineagl;
var
  x,y,f,nchar,pos:word;
  color:byte;
begin
  //Hay dos pantallas una en 0 y la otra en $1000
  pos:=(vram_control and 8) shl 9;
  for f:=$0 to $7ff do begin
    nchar:=vram0[f+pos];
    color:=vram0[$800+pos+f] and $1f;
    if ((nchar and $3e00)=$3e00) then nchar:=(nchar and $c07f) or ((tilebank[(nchar and $0180) shr 7] shr 1) shl 7);
    if (gfx[1].buffer[pos+f] or buffer_color[color]) then begin
      x:=f mod 64;
      y:=f div 64;
      put_gfx_flip(x*16,y*16,nchar and $3fff,color shl 4,2,1,(nchar and $4000)<>0,(nchar and $8000)<>0);
      gfx[1].buffer[pos+f]:=false;
    end;
  end;
  scroll_x_y(2,1,scroll_x,scroll_y);
  seta_sprite0.draw_sprites;
  actualiza_trozo_final(0,16,384,224,1);
  fillchar(buffer_color,MAX_COLOR_BUFFER,0);
end;

procedure twineagl_scan_lines(line:byte);
begin
case line of
  112:m6502_0.change_irq(HOLD_LINE);
  239:begin
        m68000_0.irq[3]:=ASSERT_LINE;
        m6502_0.change_nmi(PULSE_LINE);
        update_video_twineagl;
      end;
end;
end;

function twineagl_getword(direccion:dword):word;
begin
case direccion of
    0..$9ffff:twineagl_getword:=rom[direccion shr 1];
    $100000..$103fff:twineagl_getword:=x1_010_0.read16((direccion and $3fff) shr 1);
    $200100..$20010f:twineagl_getword:=xtra_mem[(direccion and $f) shr 1];
    $600000..$600003:case ((direccion and 3) shr 1) of
                        0:twineagl_getword:=marcade.dswa shr 8;
                        1:twineagl_getword:=marcade.dswa and $ff;
                     end;
    $700000..$7003ff:twineagl_getword:=buffer_paleta[(direccion and $3ff) shr 1];
    $900000..$903fff:twineagl_getword:=vram0[(direccion and $3fff) shr 1];
    $b00000..$b00fff:twineagl_getword:=shared_ram[(direccion and $fff) shr 1];
    $d00000..$d005ff:twineagl_getword:=seta_sprite0.spritey[(direccion and $fff) shr 1];
    $d00600..$d00607:twineagl_getword:=seta_sprite0.control[(direccion and $7) shr 1];
    $e00000..$e03fff:twineagl_getword:=seta_sprite0.spritelow[(direccion and $3fff) shr 1]+(seta_sprite0.spritehigh[(direccion and $3fff) shr 1] shl 8);
    $f00000..$ffffff:twineagl_getword:=ram[(direccion and $fffff) shr 1];
end;
end;

procedure twineagl_putword(direccion:dword;valor:word);
var
  pos:word;
begin
case direccion of
    0..$9ffff:;
    $100000..$103fff:x1_010_0.write16((direccion and $3fff) shr 1,valor); //x10
    $200100..$20010f:xtra_mem[(direccion and $f) shr 1]:=valor and $ff;
    $300000:;
    $400000..$400007:if tilebank[(direccion and 7) shr 1]<>valor then begin
                        tilebank[(direccion and 7) shr 1]:=valor;
                        fillchar(gfx[1].buffer,$2000,1);
                     end;
    $500000..$500001:if m68000_0.write_8bits_hi_dir then begin
                        if (valor and $30)=0 then m68000_0.irq[3]:=CLEAR_LINE;
                     end;
    $700000..$7003ff:if buffer_paleta[(direccion and $3ff) shr 1]<>valor then begin
                      buffer_paleta[(direccion and $3ff) shr 1]:=valor;
                      cambiar_color((direccion and $3ff) shr 1,valor);
                     end;
    $800000..$800005:case ((direccion and 7) shr 1) of //VRAM Ctrl
                        0:scroll_x:=valor+16;
                        1:scroll_y:=valor-8;
                        2:if vram_control<>valor then begin
                            vram_control:=valor;
                            fillchar(gfx[1].buffer,$2000,1);
                          end;
                     end;
    $900000..$903fff:begin
                        pos:=(direccion and $3fff) shr 1;
                        if vram0[pos]<>valor then begin
                          vram0[pos]:=valor;
                          gfx[1].buffer[(pos and $7ff)+(pos and $1000)]:=true;
                        end;
                      end;
    $a00000..$a00007:case ((direccion and $7) shr 1) of
                        0:begin
                            if (((control_data and 1)=0) and ((valor and 1)<>0))  then
                              m6502_0.change_reset(HOLD_LINE);
                              control_data:=valor;
                          end;
                        1:;
                        2:sound_latch0:=valor and $ff;
                        3:sound_latch1:=valor and $ff;
                     end;
    $b00000..$b00fff:shared_ram[(direccion and $fff) shr 1]:=valor and $ff;
    $d00000..$d005ff:seta_sprite0.spritey[(direccion and $7ff) shr 1]:=valor and $ff;
    $d00600..$d00607:seta_sprite0.control[(direccion and $7) shr 1]:=valor and $ff;
    $e00000..$e03fff:begin
                        seta_sprite0.spritelow[(direccion and $3fff) shr 1]:=valor and $ff;
                        seta_sprite0.spritehigh[(direccion and $3fff) shr 1]:=valor shr 8;
                     end;
    $f00000..$ffffff:ram[(direccion and $fffff) shr 1]:=valor;
end;
end;

function twineagl_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$1ff,$7000..$ffff:twineagl_snd_getbyte:=mem_snd[direccion];
  $800:twineagl_snd_getbyte:=sound_latch0;
  $801:twineagl_snd_getbyte:=sound_latch1;
  $1000:twineagl_snd_getbyte:=marcade.in0; //p1
  $1001:twineagl_snd_getbyte:=marcade.in1; //p2
  $1002:twineagl_snd_getbyte:=marcade.in2; //coin
  $5000..$57ff:twineagl_snd_getbyte:=shared_ram[direccion and $7ff];
end;
end;

procedure twineagl_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$1ff:mem_snd[direccion]:=valor;
  $1000:;
  $5000..$57ff:shared_ram[direccion and $7ff]:=valor;
  $7000..$ffff:;
end;
end;

//Thunder & Ligthning
procedure thunderl_eventos;
begin
if event.arcade then begin
  //p1
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  //p2
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or 8);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
  //coins
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or 1);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or 2);
end;
end;

procedure thunderl_scan_lines(line:byte);
begin
case line of
  239:begin
        m68000_0.irq[2]:=ASSERT_LINE;
        update_video_seta_sprites;
      end;
end;
end;

function thunderl_getword(direccion:dword):word;
begin
case direccion of
    0..$ffff:thunderl_getword:=rom[direccion shr 1];
    $100000..$103fff:thunderl_getword:=x1_010_0.read16((direccion and $3fff) shr 1);
    $200000:m68000_0.irq[2]:=CLEAR_LINE;
    $600000..$600003:case ((direccion and 3) shr 1) of
                        0:thunderl_getword:=marcade.dswb shr 8;
                        1:thunderl_getword:=marcade.dswb and $ff;
                     end;
    $700000..$7003ff:thunderl_getword:=buffer_paleta[(direccion and $3ff) shr 1];
    $b00000:thunderl_getword:=marcade.in0;
    $b00002:thunderl_getword:=marcade.in1;
    $b00004:thunderl_getword:=(marcade.in2 and $f) or marcade.dswa;
    $b00008:thunderl_getword:=$ffff; //p3
    $b0000a:thunderl_getword:=$ffff; //p4
    $b0000c:thunderl_getword:=thunderl_protection_reg;
    $c00000:thunderl_getword:=ram[$4000];
    $d00000..$d005ff:thunderl_getword:=seta_sprite0.spritey[(direccion and $fff) shr 1];
    $d00600..$d00607:thunderl_getword:=seta_sprite0.control[(direccion and $7) shr 1];
    $e00000..$e03fff:thunderl_getword:=seta_sprite0.spritelow[(direccion and $3fff) shr 1]+(seta_sprite0.spritehigh[(direccion and $3fff) shr 1] shl 8);
    $e04000..$e07fff:thunderl_getword:=ram[$2000+((direccion and $3fff) shr 1)];
    $ffc000..$ffffff:thunderl_getword:=ram[(direccion and $3fff) shr 1];
end;
end;

procedure thunderl_putword(direccion:dword;valor:word);
var
  addr:dword;
begin
case direccion of
    0..$ffff:;
    $100000..$103fff:x1_010_0.write16((direccion and $3fff) shr 1,valor); //x10
    $200000:m68000_0.irq[2]:=CLEAR_LINE;
    $300000:;
    $400000..$41ffff:begin //proteccion
                       addr:=direccion and $1ffff;
                       thunderl_protection_reg:=
		                    (bit_n(addr,2) shl 0)
		                    or ((BIT_n(addr, 2) and BIT_n(not(addr), 3)) shl 1)
		                    or ((BIT_n(addr, 2) or BIT_n(not(addr), 6)) shl 2)
		                    or ((BIT_n(addr, 2) or BIT_n(not(addr), 6) or BIT_n(not(addr), 8)) shl 3)
		                    or ((BIT_n(addr, 3) and BIT_n(not(addr), 11) and BIT_n(addr, 15)) shl 4)
		                    or ((BIT_n(addr, 6) and BIT_n(addr, 13)) shl 5)
		                    or (((BIT_n(addr, 6) and BIT_n(addr, 13)) or BIT_n(not(addr), 16)) shl 6)
		                    or ((((BIT_n(addr, 6) and BIT_n(addr, 13)) or BIT_n(not(addr), 16)) and (BIT_n(addr, 2) or BIT_n(not(addr), 6) or BIT_n(not(addr), 8))) shl 7);
                     end;
    $500000..$500001:; //coin lockout
    $700000..$7003ff:if buffer_paleta[(direccion and $3ff) shr 1]<>valor then begin
                      buffer_paleta[(direccion and $3ff) shr 1]:=valor;
                      cambiar_color((direccion and $3ff) shr 1,valor);
                     end;
    $c00000:ram[$4000]:=valor;
    $d00000..$d005ff:seta_sprite0.spritey[(direccion and $7ff) shr 1]:=valor and $ff;
    $d00600..$d00607:seta_sprite0.control[(direccion and $7) shr 1]:=valor and $ff;
    $e00000..$e03fff:begin
                        seta_sprite0.spritelow[(direccion and $3fff) shr 1]:=valor and $ff;
                        seta_sprite0.spritehigh[(direccion and $3fff) shr 1]:=valor shr 8;
                     end;
    $e04000..$e07fff:ram[$2000+((direccion and $3fff) shr 1)]:=valor;
    $ffc000..$ffffff:ram[(direccion and $3fff) shr 1]:=valor;
end;
end;

//Main
procedure reset_seta;
begin
 m68000_0.reset;
 case main_vars.tipo_maquina of
  302:begin
        ym2203_0.reset;
        ym3812_0.reset;
        m6502_0.reset;
      end;
  303:begin
        x1_010_0.reset;
        m6502_0.reset;
      end;
  304:x1_010_0.reset;
 end;
 reset_audio;
 seta_sprite0.reset;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 sound_latch0:=0;
 sound_latch1:=0;
 scroll_x:=0;
 scroll_y:=0;
 vram_control:=0;
 thunderl_protection_reg:=0;
end;

function iniciar_seta:boolean;
var
  memoria_temp:array[0..$3ffff] of byte;
  ptemp:pbyte;
  f:byte;
const
  ps_x:array[0..15] of dword=(0, 1, 2, 3, 4, 5, 6, 7,
    8*2*8, 8*2*8+1, 8*2*8+2, 8*2*8+3, 8*2*8+4, 8*2*8+5, 8*2*8+6, 8*2*8+7);
  ps_y:array[0..15] of dword=(0*8*2, 1*8*2, 2*8*2, 3*8*2, 4*8*2, 5*8*2, 6*8*2, 7*8*2,
    8*2*8*2+(8*2*0), 8*2*8*2+(8*2*1), 8*2*8*2+(8*2*2), 8*2*8*2+(8*2*3), 8*2*8*2+(8*2*4), 8*2*8*2+(8*2*5), 8*2*8*2+(8*2*6), 8*2*8*2+(8*2*7));
  ps_x_te:array[0..15] of dword=(4*4*8*3+0, 4*4*8*3+1, 4*4*8*3+2, 4*4*8*3+3, 4*4*8*2+0, 4*4*8*2+1, 4*4*8*2+2, 4*4*8*2+3,
    4*4*8+0, 4*4*8+1, 4*4*8+2, 4*4*8+3, 0, 1, 2, 3);
  ps_y_te:array[0..15] of dword=(0*4*4, 1*4*4, 2*4*4, 3*4*4, 4*4*4, 5*4*4, 6*4*4, 7*4*4,
    4*4*8*4+(4*4*0), 4*4*8*4+(4*4*1), 4*4*8*4+(4*4*2), 4*4*8*4+(4*4*3), 4*4*8*4+(4*4*4), 4*4*8*4+(4*4*5), 4*4*8*4+(4*4*6), 4*4*8*4+(4*4*7));

procedure convert_sprites(num:word);
begin
  init_gfx(0,16,16,num);
  gfx[0].trans[0]:=true;
  gfx_set_desc_data(4,0,16*16*2,num*16*16*2+8,num*16*16*2,8,0);
  convert_gfx(0,0,ptemp,@ps_x,@ps_y,false,false);
end;

begin
llamadas_maquina.reset:=reset_seta;
case main_vars.tipo_maquina of
  302:llamadas_maquina.bucle_general:=seta_principal_snd_cpu;
  303:begin
        llamadas_maquina.bucle_general:=seta_principal_snd_cpu;
        llamadas_maquina.fps_max:=57.42;
      end;
  304:llamadas_maquina.bucle_general:=seta_principal;
end;
iniciar_seta:=false;
iniciar_audio(false);
//Pantallas
screen_init(1,512,256,false,true);
case main_vars.tipo_maquina of
  303:begin
        screen_init(2,1024,512,false,false);
        screen_mod_scroll(2,1024,512,1023,512,256,511);
      end;
end;
main_screen.rot270_screen:=true;
iniciar_video(384,224);
//Main CPU
m68000_0:=cpu_m68000.create(16000000 div 2,256);
getmem(ptemp,$200000);
case main_vars.tipo_maquina of
  302:begin
        scanlines_proc:=tndrcade_scan_lines;
        //Main CPU
        m68000_0.change_ram16_calls(tndrcade_getword,tndrcade_putword);
        if not(roms_load16w(@rom,tndrcade_rom)) then exit;
        //Sound CPU
        m6502_0:=cpu_m6502.create(16000000 div 8,256,TCPU_M65C02);
        m6502_0.change_ram_calls(tndrcade_snd_getbyte,tndrcade_snd_putbyte);
        m6502_0.init_sound(tndrcade_sound_update);
        if not(roms_load(@memoria_temp,tndrcade_snd)) then exit;
        copymemory(@mem_snd[$6000],@memoria_temp[$2000],$2000);
        copymemory(@mem_snd[$c000],@memoria_temp[$0],$4000);
        for f:=0 to $e do copymemory(@rom_snd[f,0],@memoria_temp[f*$4000],$4000);
        //Sound
        ym2203_0:=ym2203_chip.create(16000000 div 4);
        ym2203_0.change_io_calls(tndrcade_porta_read,tndrcade_portb_read,nil,nil);
        ym3812_0:=ym3812_chip.create(YM3812_FM,16000000 div 4);
        //Video chips (sin bancos de sprites)
        seta_sprite0:=tseta_sprites.create(0,1,$1000 div $40,$3fff,nil);
        //convertir gfx
        if not(roms_load(ptemp,tndrcade_sprites)) then exit;
        convert_sprites($4000);
        //DIP
        marcade.dswa:=$f77f;
        marcade.dswa_val:=@tndrcade_dip;
    end;
    303:begin  //Twin Eagle
        scanlines_proc:=twineagl_scan_lines;
        //Main CPU
        m68000_0.change_ram16_calls(twineagl_getword,twineagl_putword);
        if not(roms_load_swap_word(@rom,twineagl_rom)) then exit;
        //Sound CPU
        m6502_0:=cpu_m6502.create(16000000 div 8,256,TCPU_M65C02);
        m6502_0.change_ram_calls(twineagl_snd_getbyte,twineagl_snd_putbyte);
        m6502_0.init_sound(seta_sound_update);
        if not(roms_load(@memoria_temp,twineagl_snd)) then exit;
        copymemory(@mem_snd[$7000],@memoria_temp[$1000],$1000);
        copymemory(@mem_snd[$8000],@memoria_temp[$0],$2000);
        copymemory(@mem_snd[$a000],@memoria_temp[$0],$2000);
        copymemory(@mem_snd[$c000],@memoria_temp[$0],$2000);
        copymemory(@mem_snd[$e000],@memoria_temp[$0],$2000);
        //Sound
        x1_010_0:=tx1_010.create(16000000);
        if not(roms_load(@x1_010_0.rom,twineagl_pcm)) then exit;
        //Video chips (Sin bancos de sprites)
        seta_sprite0:=tseta_sprites.create(0,1,$1000 div $40,$1fff,nil);
        //convertir gfx
        if not(roms_load16w(pword(ptemp),twineagl_sprites)) then exit;
        convert_sprites($2000);
        if not(roms_load16w(pword(ptemp),twineagl_tiles)) then exit;
        init_gfx(1,16,16,$4000);
        gfx_set_desc_data(4,0,16*16*4,0,4,8,12);
        convert_gfx(1,0,ptemp,@ps_x_te,@ps_y_te,false,false);
        //DIP
        marcade.dswa:=$bff7;
        marcade.dswa_val:=@twineagl_dip;
    end;
    304:begin
        scanlines_proc:=thunderl_scan_lines;
        eventos_proc:=thunderl_eventos;
        //Main CPU
        m68000_0.change_ram16_calls(thunderl_getword,thunderl_putword);
        m68000_0.init_sound(seta_sound_update);
        if not(roms_load16w(@rom,thunderl_rom)) then exit;
        //Sound
        x1_010_0:=tx1_010.create(16000000);
        if not(roms_load(@x1_010_0.rom,thunderl_pcm)) then exit;
        //Video chips (sin bancos de sprites)
        seta_sprite0:=tseta_sprites.create(0,1,$1000 div $40,$fff,nil);
        //convertir gfx
        if not(roms_load16w(pword(ptemp),thunderl_sprites)) then exit;
        convert_sprites($1000);
        //DIP
        marcade.dswa:=$e0;
        marcade.dswa_val:=@thunderl_dip_a;
        marcade.dswb:=$e9ff;
        marcade.dswb_val:=@thunderl_dip_b;
    end;
end;
freemem(ptemp);
//final
reset_seta;
iniciar_seta:=true;
end;

end.
