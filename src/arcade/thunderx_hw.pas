unit thunderx_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,konami,main_engine,controls_engine,gfx_engine,rom_engine,
     pal_engine,sound_engine,ym_2151,k052109,k051960,k007232,timer_engine;

procedure cargar_thunderx;

implementation

type
        tvideo_bank_func=procedure(valor:byte);
        tfunction_1f98=procedure(valor:byte);
const
        //Super Contra
        scontra_rom:array[0..2] of tipo_roms=(
        (n:'775-e02.k11';l:$10000;p:0;crc:$a61c0ead),(n:'775-e03.k13';l:$10000;p:$10000;crc:$00b02622),());
        scontra_sound:tipo_roms=(n:'775-c01.bin';l:$8000;p:0;crc:$0ced785a);
        scontra_tiles:array[0..12] of tipo_roms=(
        (n:'775-a07a.bin';l:$20000;p:0;crc:$e716bdf3),(n:'775-a07e.bin';l:$20000;p:1;crc:$0986e3a5),
        (n:'775-a08a.bin';l:$20000;p:2;crc:$3ddd11a4),(n:'775-a08e.bin';l:$20000;p:3;crc:$1007d963),
        (n:'775-f07c.bin';l:$10000;p:$80000;crc:$b0b30915),(n:'775-f07g.bin';l:$10000;p:$80001;crc:$fbed827d),
        (n:'775-f08c.bin';l:$10000;p:$80002;crc:$53abdaec),(n:'775-f08g.bin';l:$10000;p:$80003;crc:$3df85a6e),
        (n:'775-f07d.bin';l:$10000;p:$c0000;crc:$f184be8e),(n:'775-f07h.bin';l:$10000;p:$c0001;crc:$7b56c348),
        (n:'775-f08d.bin';l:$10000;p:$c0002;crc:$102dcace),(n:'775-f08h.bin';l:$10000;p:$c0003;crc:$ad9d7016),());
        scontra_sprites:array[0..16] of tipo_roms=(
        (n:'775-a05a.bin';l:$10000;p:0;crc:$a0767045),(n:'775-a05e.bin';l:$10000;p:1;crc:$2f656f08),
        (n:'775-a06a.bin';l:$10000;p:2;crc:$77a34ad0),(n:'775-a06e.bin';l:$10000;p:3;crc:$8a910c94),
        (n:'775-a05b.bin';l:$10000;p:$40000;crc:$ab8ad4fd),(n:'775-a05f.bin';l:$10000;p:$40001;crc:$1c0eb1b6),
        (n:'775-a06b.bin';l:$10000;p:$40002;crc:$563fb565),(n:'775-a06f.bin';l:$10000;p:$40003;crc:$e14995c0),
        (n:'775-f05c.bin';l:$10000;p:$80000;crc:$5647761e),(n:'775-f05g.bin';l:$10000;p:$80001;crc:$a1692cca),
        (n:'775-f06c.bin';l:$10000;p:$80002;crc:$5ee6f3c1),(n:'775-f06g.bin';l:$10000;p:$80003;crc:$2645274d),
        (n:'775-f05d.bin';l:$10000;p:$c0000;crc:$ad676a6f),(n:'775-f05h.bin';l:$10000;p:$c0001;crc:$3f925bcf),
        (n:'775-f06d.bin';l:$10000;p:$c0002;crc:$c8b764fa),(n:'775-f06h.bin';l:$10000;p:$c0003;crc:$d6595f59),());
        scontra_k007232:array[0..8] of tipo_roms=(
        (n:'775-a04a.bin';l:$10000;p:$0;crc:$7efb2e0f),(n:'775-a04b.bin';l:$10000;p:$10000;crc:$f41a2b33),
        (n:'775-a04c.bin';l:$10000;p:$20000;crc:$e4e58f14),(n:'775-a04d.bin';l:$10000;p:$30000;crc:$d46736f6),
        (n:'775-f04e.bin';l:$10000;p:$40000;crc:$fbf7e363),(n:'775-f04f.bin';l:$10000;p:$50000;crc:$b031ef2d),
        (n:'775-f04g.bin';l:$10000;p:$60000;crc:$ee107bbb),(n:'775-f04h.bin';l:$10000;p:$70000;crc:$fb0fab46),());
        //Gang Busters
        gbusters_rom:array[0..2] of tipo_roms=(
        (n:'878n02.k13';l:$10000;p:0;crc:$51697aaa),(n:'878j03.k15';l:$10000;p:$10000;crc:$3943a065),());
        gbusters_sound:tipo_roms=(n:'878h01.f8';l:$8000;p:0;crc:$96feafaa);
        gbusters_tiles:array[0..2] of tipo_roms=(
        (n:'878c07.h27';l:$40000;p:0;crc:$eeed912c),(n:'878c08.k27';l:$40000;p:2;crc:$4d14626d),());
        gbusters_sprites:array[0..2] of tipo_roms=(
        (n:'878c05.h5';l:$40000;p:0;crc:$01f4aea5),(n:'878c06.k5';l:$40000;p:2;crc:$edfaaaaf),());
        gbusters_k007232:tipo_roms=(n:'878c04.d5';l:$40000;p:0;crc:$9e982d1c);
        //Thunder Cross
        thunderx_rom:array[0..2] of tipo_roms=(
        (n:'873-s02.k13';l:$10000;p:0;crc:$6619333a),(n:'873-s03.k15';l:$10000;p:$10000;crc:$2aec2699),());
        thunderx_sound:tipo_roms=(n:'873-f01.f8';l:$8000;p:0;crc:$ea35ffa3);
        thunderx_tiles:array[0..8] of tipo_roms=(
        (n:'873c06a.f6';l:$10000;p:0;crc:$0e340b67),(n:'873c06c.f5';l:$10000;p:1;crc:$ef0e72cd),
        (n:'873c07a.f4';l:$10000;p:2;crc:$a8aab84f),(n:'873c07c.f3';l:$10000;p:3;crc:$2521009a),
        (n:'873c06b.e6';l:$10000;p:$40000;crc:$97ad202e),(n:'873c06d.e5';l:$10000;p:$40001;crc:$8393d42e),
        (n:'873c07b.e4';l:$10000;p:$40002;crc:$12a2b8ba),(n:'873c07d.e3';l:$10000;p:$40003;crc:$fae9f965),());
        thunderx_sprites:array[0..8] of tipo_roms=(
        (n:'873c04a.f11';l:$10000;p:0;crc:$f7740bf3),(n:'873c04c.f10';l:$10000;p:1;crc:$5dacbd2b),
        (n:'873c05a.f9';l:$10000;p:2;crc:$d73e107d),(n:'873c05c.f8';l:$10000;p:3;crc:$59903200),
        (n:'873c04b.e11';l:$10000;p:$40000;crc:$9ac581da),(n:'873c04d.e10';l:$10000;p:$40001;crc:$44a4668c),
        (n:'873c05b.e9';l:$10000;p:$40002;crc:$81059b99),(n:'873c05d.e8';l:$10000;p:$40003;crc:$7fa3d7df),());
        //DIP
        scontra_dip_a:array [0..2] of def_dip=(
        (mask:$0f;name:'Coin A';number:16;dip:((dip_val:$02;dip_name:'4C 1C'),(dip_val:$05;dip_name:'3C 1C'),(dip_val:$08;dip_name:'2C 1C'),(dip_val:$04;dip_name:'3C 2C'),(dip_val:$01;dip_name:'4C 3C'),(dip_val:$0f;dip_name:'1C 1C'),(dip_val:$03;dip_name:'3C 4C'),(dip_val:$07;dip_name:'2C 3C'),(dip_val:$0e;dip_name:'1C 2C'),(dip_val:$06;dip_name:'2C 5C'),(dip_val:$0d;dip_name:'1C 3C'),(dip_val:$0c;dip_name:'1C 4C'),(dip_val:$0b;dip_name:'1C 5C'),(dip_val:$0a;dip_name:'1C 6C'),(dip_val:$09;dip_name:'1C 7C'),(dip_val:$0;dip_name:'Free Play'))),
        (mask:$f0;name:'Coin B';number:16;dip:((dip_val:$20;dip_name:'4C 1C'),(dip_val:$50;dip_name:'3C 1C'),(dip_val:$80;dip_name:'2C 1C'),(dip_val:$40;dip_name:'3C 2C'),(dip_val:$10;dip_name:'4C 3C'),(dip_val:$f0;dip_name:'1C 1C'),(dip_val:$30;dip_name:'3C 4C'),(dip_val:$70;dip_name:'2C 3C'),(dip_val:$e0;dip_name:'1C 2C'),(dip_val:$60;dip_name:'2C 5C'),(dip_val:$d0;dip_name:'1C 3C'),(dip_val:$c0;dip_name:'1C 4C'),(dip_val:$b0;dip_name:'1C 5C'),(dip_val:$a0;dip_name:'1C 6C'),(dip_val:$90;dip_name:'1C 7C'),(dip_val:$0;dip_name:'No Coin'))),());
        scontra_dip_b:array [0..4] of def_dip=(
        (mask:$3;name:'Lives';number:4;dip:((dip_val:$3;dip_name:'2'),(dip_val:$2;dip_name:'3'),(dip_val:$1;dip_name:'5'),(dip_val:$0;dip_name:'7'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$18;name:'Bonus Life';number:4;dip:((dip_val:$18;dip_name:'30K 200K'),(dip_val:$10;dip_name:'50K 300K'),(dip_val:$8;dip_name:'30K'),(dip_val:$0;dip_name:'50K'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$60;name:'Difficulty';number:4;dip:((dip_val:$60;dip_name:'Easy'),(dip_val:$40;dip_name:'Normal'),(dip_val:$20;dip_name:'Hard'),(dip_val:$0;dip_name:'Very Hard'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Demo Sounds';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        scontra_dip_c:array [0..2] of def_dip=(
        (mask:$1;name:'Flip Screen';number:2;dip:((dip_val:$1;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Continue Limit 1P/2P';number:2;dip:((dip_val:$8;dip_name:'3 Times/2 altogether'),(dip_val:$0;dip_name:'5 Times/4 altogether'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        gbusters_dip_b:array [0..5] of def_dip=(
        (mask:$3;name:'Lives';number:4;dip:((dip_val:$3;dip_name:'2'),(dip_val:$2;dip_name:'3'),(dip_val:$1;dip_name:'5'),(dip_val:$0;dip_name:'7'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Bullets';number:2;dip:((dip_val:$4;dip_name:'50'),(dip_val:$0;dip_name:'60'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$18;name:'Bonus Life';number:4;dip:((dip_val:$18;dip_name:'30K 200K 400K+'),(dip_val:$10;dip_name:'70K 250K 500K+'),(dip_val:$8;dip_name:'50K'),(dip_val:$0;dip_name:'70K'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$60;name:'Difficulty';number:4;dip:((dip_val:$60;dip_name:'Easy'),(dip_val:$40;dip_name:'Normal'),(dip_val:$20;dip_name:'Hard'),(dip_val:$0;dip_name:'Very Hard'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Demo Sounds';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        gbusters_dip_c:array [0..1] of def_dip=(
        (mask:$1;name:'Flip Screen';number:2;dip:((dip_val:$1;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        thunderx_dip_b:array [0..5] of def_dip=(
        (mask:$3;name:'Lives';number:4;dip:((dip_val:$3;dip_name:'2'),(dip_val:$2;dip_name:'3'),(dip_val:$1;dip_name:'5'),(dip_val:$0;dip_name:'7'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Award Bonus Life';number:2;dip:((dip_val:$4;dip_name:'No'),(dip_val:$0;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$18;name:'Bonus Life';number:4;dip:((dip_val:$18;dip_name:'30K 200K'),(dip_val:$10;dip_name:'50K 300K'),(dip_val:$8;dip_name:'30K'),(dip_val:$0;dip_name:'50K'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$60;name:'Difficulty';number:4;dip:((dip_val:$60;dip_name:'Easy'),(dip_val:$40;dip_name:'Normal'),(dip_val:$20;dip_name:'Hard'),(dip_val:$0;dip_name:'Very Hard'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Demo Sounds';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 tiles_rom,sprite_rom,k007232_rom:pbyte;
 sound_latch,sprite_colorbase,bank0_bank,rom_bank1,latch_1f98,priority,thunderx_timer:byte;
 layer_colorbase:array[0..2] of byte;
 rom_bank:array[0..$f,0..$1fff] of byte;
 ram_bank:array[0..2,0..$7ff] of byte;
 video_bank_call:tvideo_bank_func;
 call_function_1f98:tfunction_1f98;

procedure scontra_videobank(valor:byte);
begin
     rom_bank1:=valor and $f;
     bank0_bank:=(valor and $10) shr 4;
     priority:=valor and $80;
end;

procedure gbusters_videobank(valor:byte);
begin
     bank0_bank:=valor and $1;
     priority:=valor and $8;
end;

procedure thunderx_videobank(valor:byte);
begin
     if (valor and $10)<>0 then bank0_bank:=2
        else bank0_bank:=valor and $1;
     priority:=valor and $8;
end;

procedure scontra_1f98_call(valor:byte);
begin
     if (valor and $1)<>0 then k052109_0.set_rmrd_line(ASSERT_LINE)
        else k052109_0.set_rmrd_line(CLEAR_LINE);
     latch_1f98:=valor;
end;

procedure run_collisions(s0,e0,s1,e1:integer;cm,hm:byte);inline;
var
   p0,p1:integer;
   ii,jj:integer;
   l0,r0,b0,t0,l1,r1,b1,t1:integer;
begin
p0:=(16+5*s0)-5;
for ii:=s0 to (e0-1) do begin
    p0:=p0+5;
    if ((ram_bank[2,p0+0] and cm)=0) then continue; // check valid
    // get area
    l0:=ram_bank[2,p0+3]-ram_bank[2,p0+1];
    r0:=ram_bank[2,p0+3]+ram_bank[2,p0+1];
    t0:=ram_bank[2,p0+4]-ram_bank[2,p0+2];
    b0:=ram_bank[2,p0+4]+ram_bank[2,p0+2];
    p1:=(16+5*s1)-5;
    for jj:=s1 to (e1-1) do begin
        p1:=p1+5;
	if ((ram_bank[2,p1+0] and hm)=0) then continue; // check valid
	// get area
	l1:=ram_bank[2,p1+3]-ram_bank[2,p1+1];
	r1:=ram_bank[2,p1+3]+ram_bank[2,p1+1];
	t1:=ram_bank[2,p1+4]-ram_bank[2,p1+2];
	b1:=ram_bank[2,p1+4]+ram_bank[2,p1+2];
	// overlap check
	if (l1>=r0) then continue;
	if (l0>=r1) then continue;
	if (t1>=b0) then continue;
	if (t0>=b1) then continue;
	// set flags
	ram_bank[2,p0+0]:=(ram_bank[2,p0+0] and $9f) or (ram_bank[2,p1+0] and $04) or $10;
	ram_bank[2,p1+0]:=(ram_bank[2,p1+0] and $9f) or $10;
    end;
end;
end;

procedure calculate_collisions;inline;
var
    X0,Y0,X1,Y1:integer;
    CM,HM:byte;
begin
	// the data at 0x00 to 0x06 defines the operation
	//
	// 0x00 : word : last byte of set 0
	// 0x02 : byte : last byte of set 1
	// 0x03 : byte : collide mask
	// 0x04 : byte : hit mask
	// 0x05 : byte : first byte of set 0
	// 0x06 : byte : first byte of set 1
	//
	// the USA version is slightly different:
	//
	// 0x05 : word : first byte of set 0
	// 0x07 : byte : first byte of set 1
	//
	// the operation is to intersect set 0 with set 1
	// collide mask specifies objects to ignore
	// hit mask is 40 to set bit on object 0 and object 1
	// hit mask is 20 to set bit on object 1 only
	Y0:=(ram_bank[2,0] shl 8)+ram_bank[2,1];
	Y0:=(Y0-15) div 5;
	Y1:=(ram_bank[2,2]-15) div 5;
	if (ram_bank[2,5]<16) then begin // US Thunder Cross uses this form
		X0:=(ram_bank[2,5] shl 8)+ram_bank[2,6];
		X0:=(X0-16) div 5;
		X1:= (ram_bank[2,7]-16) div 5;
	end else begin // Japan Thunder Cross uses this form
		X0:=(ram_bank[2,5]-16) div 5;
		X1:=(ram_bank[2,6]-16) div 5;
        end;
	CM:=ram_bank[2,3];
	HM:=ram_bank[2,4];
	run_collisions(X0,Y0,X1,Y1,CM,HM);
end;

procedure thunderx_1f98_call(valor:byte);
begin
if (valor and $1)<>0 then k052109_0.set_rmrd_line(ASSERT_LINE)
   else k052109_0.set_rmrd_line(CLEAR_LINE);
if (((valor and 4)<>0) and ((latch_1f98 and 4)=0)) then begin
   calculate_collisions;
   timer[thunderx_timer].enabled:=true;
end;
latch_1f98:=valor;
end;

procedure thunderx_firq;
begin
     main_konami.change_firq(HOLD_LINE);
     timer[thunderx_timer].enabled:=false;
end;

procedure thunderx_cb(layer,bank:word;var code:dword;var color:word;var flags:word;var priority:word);
begin
code:=code or (((color and $1f) shl 8) or (bank shl 13));
color:=layer_colorbase[layer]+((color and $e0) shr 5);
end;

procedure gbusters_cb(layer,bank:word;var code:dword;var color:word;var flags:word;var priority:word);
begin
// (color & 0x02) is flip y handled internally by the 052109
code:=code or (((color and $d) shl 8) or ((color and $10) shl 5) or (bank shl 12));
color:=layer_colorbase[layer]+((color and $e0) shr 5);
end;

procedure thunderx_sprite_cb(var code:word;var color:word;var pri:word;var shadow:word);
begin
// The PROM allows for mixed priorities, where sprites would have */
// priority over text but not on one or both of the other two planes. */
case (color and $30) of
     $0:pri:=0;
     $10:pri:=3;
     $20:pri:=2;
     $30:pri:=4;
end;
color:=sprite_colorbase+(color and $f);
end;

procedure scontra_k007232_cb(valor:byte);
begin
  k007232_0.set_volume(0,(valor shr 4)*$11,0);
  k007232_0.set_volume(1,0,(valor and $f)*$11);
end;

procedure update_video_thunderx;
begin
k052109_0.draw_tiles;
fill_full_screen(4,layer_colorbase[1]*16);
k051960_0.draw_sprites(4,-1);
if priority<>0 then begin
   k052109_0.draw_layer(2,4);
   k051960_0.draw_sprites(2,-1);
   k052109_0.draw_layer(1,4);
   k051960_0.draw_sprites(3,-1);
end else begin
   k052109_0.draw_layer(1,4);
   k051960_0.draw_sprites(3,-1);
   k052109_0.draw_layer(2,4);
   k051960_0.draw_sprites(2,-1);
end;
k051960_0.draw_sprites(0,-1);
k052109_0.draw_layer(0,4);
actualiza_trozo_final(112,16,288,224,4);
end;

procedure eventos_thunderx;
begin
if event.arcade then begin
  //P1
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $Fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $F7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  //P2
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $Fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $F7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  //system
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
end;
end;

procedure thunderx_principal;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=main_konami.tframes;
frame_s:=snd_z80.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
    //main
    main_konami.run(frame_m);
    frame_m:=frame_m+main_konami.tframes-main_konami.contador;
    //sound
    snd_z80.run(frame_s);
    frame_s:=frame_s+snd_z80.tframes-snd_z80.contador;
    if f=239 then begin
                    update_video_thunderx;
                    if k052109_0.is_irq_enabled then main_konami.change_irq(HOLD_LINE);
                  end;
  end;
  eventos_thunderx;
  video_sync;
end;
end;

//Main CPU
function thunderx_getbyte(direccion:word):byte;
begin
case direccion of
    $0..$3fff:case direccion of
                   $1f90:thunderx_getbyte:=marcade.in2; //system
                   $1f91:thunderx_getbyte:=marcade.in0; //p1
                   $1f92:thunderx_getbyte:=marcade.in1; //p2
                   $1f93:thunderx_getbyte:=marcade.dswc; //dsw3
                   $1f94:thunderx_getbyte:=marcade.dswa; //dsw1
                   $1f95:thunderx_getbyte:=marcade.dswb; //dsw2
                   $1f98:thunderx_getbyte:=latch_1f98;
                   else if k052109_0.get_rmrd_line=CLEAR_LINE then begin
                           if ((direccion>=$3800) and (direccion<$3808)) then thunderx_getbyte:=k051960_0.k051937_read(direccion-$3800)
                              else if (direccion<$3c00) then thunderx_getbyte:=k052109_0.read(direccion)
                                  else thunderx_getbyte:=k051960_0.read(direccion-$3c00);
                        end else thunderx_getbyte:=k052109_0.read(direccion);
              end;
    $4000..$57ff,$8000..$ffff:thunderx_getbyte:=memoria[direccion];
    $5800..$5fff:if (bank0_bank=2) then begin
                    if (latch_1f98 and 2)<>0 then thunderx_getbyte:=ram_bank[2,direccion and $7ff]
                       else thunderx_getbyte:=0;
                 end else thunderx_getbyte:=ram_bank[bank0_bank,direccion and $7ff];
    $6000..$7fff:thunderx_getbyte:=rom_bank[rom_bank1,direccion and $1fff];
    end;
end;

procedure cambiar_color(pos:word);inline;
var
  color:tcolor;
  valor:word;
begin
  valor:=(buffer_paleta[pos*2] shl 8)+buffer_paleta[(pos*2)+1];
  color.b:=pal5bit(valor shr 10);
  color.g:=pal5bit(valor shr 5);
  color.r:=pal5bit(valor);
  set_pal_color_alpha(color,pos);
  k052109_0.clean_video_buffer;
end;

procedure thunderx_putbyte(direccion:word;valor:byte);
begin
if direccion>$5fff then exit;
case direccion of
    $0..$3fff:case direccion of
                   $1f80:video_bank_call(valor);
                   $1f84:sound_latch:=valor;
                   $1f88:snd_z80.change_irq(HOLD_LINE);
                   $1f98:call_function_1f98(valor);
                   else if ((direccion>=$3800) and (direccion<$3808)) then k051960_0.k051937_write(direccion-$3800,valor)
                           else if (direccion<$3c00) then k052109_0.write(direccion,valor)
                               else k051960_0.write(direccion-$3c00,valor);
              end;
    $4000..$57ff:memoria[direccion]:=valor;
    $5800..$5fff:begin
                 direccion:=direccion and $7ff;
                 if bank0_bank=0 then begin
                    if buffer_paleta[direccion]<>valor then begin
                       buffer_paleta[direccion]:=valor;
                       cambiar_color(direccion shr 1);
                    end;
                 end;
                 if (bank0_bank=2) then begin
                    if (latch_1f98 and 2)<>0 then ram_bank[2,direccion]:=valor;
                 end else ram_bank[bank0_bank,direccion]:=valor;
            end;
end;
end;

procedure thunderx_bank(valor:byte);
begin
  rom_bank1:=valor and $f;
end;

//Audio CPU
function thunderx_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$87ff:thunderx_snd_getbyte:=mem_snd[direccion];
  $a000:thunderx_snd_getbyte:=sound_latch;
  $c001:thunderx_snd_getbyte:=ym2151_0.status;
end;
end;

procedure thunderx_snd_putbyte(direccion:word;valor:byte);
begin
if direccion<$8000 then exit;
case direccion of
  $8000..$87ff:mem_snd[direccion]:=valor;
  $c000:ym2151_0.reg(valor);
  $c001:ym2151_0.write(valor);
end;
end;

procedure thunderx_sound_update;
begin
  ym2151_0.update;
end;

function scontra_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$87ff:scontra_snd_getbyte:=mem_snd[direccion];
  $a000:scontra_snd_getbyte:=sound_latch;
  $b000..$b00d:scontra_snd_getbyte:=k007232_0.read(direccion and $f);
  $c001:scontra_snd_getbyte:=ym2151_0.status;
end;
end;

procedure scontra_snd_putbyte(direccion:word;valor:byte);
begin
if direccion<$8000 then exit;
case direccion of
  $8000..$87ff:mem_snd[direccion]:=valor;
  $b000..$b00d:k007232_0.write(direccion and $f,valor);
  $c000:ym2151_0.reg(valor);
  $c001:ym2151_0.write(valor);
  $f000:k007232_0.set_bank(valor and $3,(valor shr 2) and $3);
end;
end;

procedure scontra_sound_update;
begin
  ym2151_0.update;
  k007232_0.update;
end;

//Main
procedure reset_thunderx;
begin
 main_konami.reset;
 snd_z80.reset;
 k052109_0.reset;
 ym2151_0.reset;
 k051960_0.reset;
 reset_audio;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 sound_latch:=0;
 bank0_bank:=0;
 rom_bank1:=0;
 latch_1f98:=0;
 priority:=0;
end;

function iniciar_thunderx:boolean;
var
   temp_mem:array[0..$1ffff] of byte;
   f:byte;
begin
iniciar_thunderx:=false;
//Pantallas para el K052109
screen_init(1,512,256,true);
screen_init(2,512,256,true);
screen_mod_scroll(2,512,512,511,256,256,255);
screen_init(3,512,256,true);
screen_mod_scroll(3,512,512,511,256,256,255);
screen_init(4,1024,1024,false,true);
if main_vars.tipo_maquina<>224 then main_screen.rot90_screen:=true;
iniciar_video(288,224,true);
iniciar_audio(false);
//Main CPU
main_konami:=cpu_konami.create(3000000,256);
main_konami.change_ram_calls(thunderx_getbyte,thunderx_putbyte);
//Sound CPU
snd_z80:=cpu_z80.create(3579545,256);
case main_vars.tipo_maquina of
     222:begin //Super contra
            call_function_1f98:=scontra_1f98_call;
            //cargar roms y ponerlas en su sitio...
            if not(cargar_roms(@temp_mem[0],@scontra_rom[0],'scontra.zip',0)) then exit;
            copymemory(@memoria[$8000],@temp_mem[$8000],$8000);
            for f:=0 to 3 do begin
                copymemory(@rom_bank[f,0],@temp_mem[f*$2000],$2000);
                copymemory(@rom_bank[4+f,0],@temp_mem[f*$2000],$2000); //Estas son un mirror de las otras tres...
            end;
            for f:=8 to $f do copymemory(@rom_bank[f,0],@temp_mem[f*$2000],$2000);
            //cargar sonido
            if not(cargar_roms(@mem_snd[0],@scontra_sound,'scontra.zip',1)) then exit;
            //Sound CPU
            snd_z80.change_ram_calls(scontra_snd_getbyte,scontra_snd_putbyte);
            snd_z80.init_sound(scontra_sound_update);
            //Sound Chips
            ym2151_0:=ym2151_chip.create(3579545);
            getmem(k007232_rom,$80000);
            if not(cargar_roms(k007232_rom,@scontra_k007232[0],'scontra.zip',0)) then exit;
            k007232_0:=k007232_chip.create(3579545,k007232_rom,$80000,0.20,scontra_k007232_cb);
            //Iniciar video
            video_bank_call:=scontra_videobank;
            getmem(tiles_rom,$100000);
            if not(cargar_roms32b_b(tiles_rom,@scontra_tiles,'scontra.zip',0)) then exit;
            k052109_0:=k052109_chip.create(1,2,3,thunderx_cb,tiles_rom,$100000);
            getmem(sprite_rom,$100000);
            if not(cargar_roms32b_b(sprite_rom,@scontra_sprites,'scontra.zip',0)) then exit;
            k051960_0:=k051960_chip.create(4,sprite_rom,$100000,thunderx_sprite_cb,2);
            //DIP
            marcade.dswa:=$ff;
            marcade.dswa_val:=@scontra_dip_a;
            marcade.dswb:=$5a;
            marcade.dswb_val:=@scontra_dip_b;
            marcade.dswc:=$f7;
            marcade.dswc_val:=@scontra_dip_c;
     end;
     223:begin //Gang Busters
            main_konami.change_set_lines(thunderx_bank);
            call_function_1f98:=scontra_1f98_call;
            //cargar roms y ponerlas en su sitio...
            if not(cargar_roms(@temp_mem[0],@gbusters_rom[0],'gbusters.zip',0)) then exit;
            copymemory(@memoria[$8000],@temp_mem[$8000],$8000);
            for f:=0 to 3 do begin
                copymemory(@rom_bank[f,0],@temp_mem[f*$2000],$2000);
                copymemory(@rom_bank[4+f,0],@temp_mem[f*$2000],$2000); //Estas son un mirror de las otras tres...
            end;
            for f:=8 to $f do copymemory(@rom_bank[f,0],@temp_mem[f*$2000],$2000);
            //cargar sonido
            if not(cargar_roms(@mem_snd[0],@gbusters_sound,'gbusters.zip',1)) then exit;
            //Sound CPU
            snd_z80.change_ram_calls(scontra_snd_getbyte,scontra_snd_putbyte);
            snd_z80.init_sound(scontra_sound_update);
            //Sound Chips
            ym2151_0:=ym2151_chip.create(3579545);
            getmem(k007232_rom,$40000);
            if not(cargar_roms(k007232_rom,@gbusters_k007232,'gbusters.zip',1)) then exit;
            k007232_0:=k007232_chip.create(3579545,k007232_rom,$40000,0.20,scontra_k007232_cb);
            //Iniciar video
            video_bank_call:=gbusters_videobank;
            getmem(tiles_rom,$80000);
            if not(cargar_roms32b(tiles_rom,@gbusters_tiles,'gbusters.zip',0)) then exit;
            k052109_0:=k052109_chip.create(1,2,3,gbusters_cb,tiles_rom,$80000);
            getmem(sprite_rom,$80000);
            if not(cargar_roms32b(sprite_rom,@gbusters_sprites,'gbusters.zip',0)) then exit;
            k051960_0:=k051960_chip.create(4,sprite_rom,$80000,thunderx_sprite_cb,2);
            //DIP
            marcade.dswa:=$ff;
            marcade.dswa_val:=@scontra_dip_a;
            marcade.dswb:=$56;
            marcade.dswb_val:=@gbusters_dip_b;
            marcade.dswc:=$ff;
            marcade.dswc_val:=@gbusters_dip_c;
     end;
     224:begin //Thunder Cross
            main_konami.change_set_lines(thunderx_bank);
            call_function_1f98:=thunderx_1f98_call;
            //cargar roms y ponerlas en su sitio...
            if not(cargar_roms(@temp_mem[0],@thunderx_rom[0],'thunderx.zip',0)) then exit;
            copymemory(@memoria[$8000],@temp_mem[$8000],$8000);
            for f:=0 to 3 do begin
                copymemory(@rom_bank[f,0],@temp_mem[f*$2000],$2000);
                copymemory(@rom_bank[4+f,0],@temp_mem[f*$2000],$2000); //Estas son un mirror de las otras tres...
            end;
            for f:=8 to $f do copymemory(@rom_bank[f,0],@temp_mem[f*$2000],$2000);
            //Despues de calcular las colisiones hay que llamar a FIRQ, pero hay que retrasarla 100T o se cuelga...
            thunderx_timer:=init_timer(main_konami.numero_cpu,100,thunderx_firq,false);
            //cargar sonido
            if not(cargar_roms(@mem_snd[0],@thunderx_sound,'thunderx.zip',1)) then exit;
            //Sound CPU
            snd_z80.change_ram_calls(thunderx_snd_getbyte,thunderx_snd_putbyte);
            snd_z80.init_sound(thunderx_sound_update);
            //Sound Chips
            ym2151_0:=ym2151_chip.create(3579545);
            //Iniciar video
            video_bank_call:=thunderx_videobank;
            getmem(tiles_rom,$80000);
            if not(cargar_roms32b_b(tiles_rom,@thunderx_tiles,'thunderx.zip',0)) then exit;
            k052109_0:=k052109_chip.create(1,2,3,thunderx_cb,tiles_rom,$80000);
            getmem(sprite_rom,$80000);
            if not(cargar_roms32b_b(sprite_rom,@thunderx_sprites,'thunderx.zip',0)) then exit;
            k051960_0:=k051960_chip.create(4,sprite_rom,$80000,thunderx_sprite_cb,2);
            //DIP
            marcade.dswa:=$ff;
            marcade.dswa_val:=@scontra_dip_a;
            marcade.dswb:=$7a;
            marcade.dswb_val:=@thunderx_dip_b;
            marcade.dswc:=$ff;
            marcade.dswc_val:=@gbusters_dip_c;
     end;
end;
layer_colorbase[0]:=48;
layer_colorbase[1]:=0;
layer_colorbase[2]:=16;
sprite_colorbase:=32;
//final
reset_thunderx;
iniciar_thunderx:=true;
end;

procedure cerrar_thunderx;
begin
if main_vars.tipo_maquina<>224 then if k007232_rom<>nil then freemem(k007232_rom);
if sprite_rom<>nil then freemem(sprite_rom);
if tiles_rom<>nil then freemem(tiles_rom);
k007232_rom:=nil;
sprite_rom:=nil;
tiles_rom:=nil;
end;

procedure Cargar_thunderx;
begin
llamadas_maquina.iniciar:=iniciar_thunderx;
llamadas_maquina.close:=cerrar_thunderx;
llamadas_maquina.reset:=reset_thunderx;
llamadas_maquina.bucle_general:=thunderx_principal;
llamadas_maquina.fps_max:=59.185606;
end;

end.
