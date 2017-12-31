unit karnov_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m68000,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     ym_2203,ym_3812,m6502,sound_engine;

procedure cargar_karnov;

implementation
const
        //Karnov
        karnov_rom:array[0..6] of tipo_roms=(
        (n:'dn08-6';l:$10000;p:0;crc:$4c60837f),(n:'dn11-6';l:$10000;p:$1;crc:$cd4abb99),
        (n:'dn07-';l:$10000;p:$20000;crc:$fc14291b),(n:'dn10-';l:$10000;p:$20001;crc:$a4a34e37),
        (n:'dn06-5';l:$10000;p:$40000;crc:$29d64e42),(n:'dn09-5';l:$10000;p:$40001;crc:$072d7c49),());
        karnov_sound:tipo_roms=(n:'dn05-5';l:$8000;p:$8000;crc:$fa1a31a8);
        karnov_char:tipo_roms=(n:'dn00-';l:$8000;p:$0;crc:$0ed77c6d);
        karnov_tiles:array[0..3] of tipo_roms=(
        (n:'dn04-';l:$10000;p:0;crc:$a9121653),(n:'dn01-';l:$10000;p:$10000;crc:$18697c9e),
        (n:'dn03-';l:$10000;p:$20000;crc:$90d9dd9c),(n:'dn02-';l:$10000;p:$30000;crc:$1e04d7b9));
        karnov_sprites:array[0..7] of tipo_roms=(
        (n:'dn12-';l:$10000;p:$00000;crc:$9806772c),(n:'dn14-5';l:$8000;p:$10000;crc:$ac9e6732),
        (n:'dn13-';l:$10000;p:$20000;crc:$a03308f9),(n:'dn15-5';l:$8000;p:$30000;crc:$8933fcb8),
        (n:'dn16-';l:$10000;p:$40000;crc:$55e63a11),(n:'dn17-5';l:$8000;p:$50000;crc:$b70ae950),
        (n:'dn18-';l:$10000;p:$60000;crc:$2ad53213),(n:'dn19-5';l:$8000;p:$70000;crc:$8fd4fa40));
        karnov_proms:array[0..1] of tipo_roms=(
        (n:'karnprom.21';l:$400;p:$0;crc:$aab0bb93),(n:'karnprom.20';l:$400;p:$400;crc:$02f78ffb));
        //Chelnov
        chelnov_rom:array[0..6] of tipo_roms=(
        (n:'ee08-e.j16';l:$10000;p:0;crc:$8275cc3a),(n:'ee11-e.j19';l:$10000;p:$1;crc:$889e40a0),
        (n:'a-j14.bin';l:$10000;p:$20000;crc:$51465486),(n:'a-j18.bin';l:$10000;p:$20001;crc:$d09dda33),
        (n:'ee06-e.j13';l:$10000;p:$40000;crc:$55acafdb),(n:'ee09-e.j17';l:$10000;p:$40001;crc:$303e252c),());
        chelnov_sound:tipo_roms=(n:'ee05-.f3';l:$8000;p:$8000;crc:$6a8936b4);
        chelnov_char:tipo_roms=(n:'ee00-e.c5';l:$8000;p:$0;crc:$e06e5c6b);
        chelnov_tiles:array[0..3] of tipo_roms=(
        (n:'ee04-.d18';l:$10000;p:0;crc:$96884f95),(n:'ee01-.c15';l:$10000;p:$10000;crc:$f4b54057),
        (n:'ee03-.d15';l:$10000;p:$20000;crc:$7178e182),(n:'ee02-.c18';l:$10000;p:$30000;crc:$9d7c45ae));
        chelnov_sprites:array[0..3] of tipo_roms=(
        (n:'ee12-.f8';l:$10000;p:$00000;crc:$9b1c53a5),(n:'ee13-.f9';l:$10000;p:$20000;crc:$72b8ae3e),
        (n:'ee14-.f13';l:$10000;p:$40000;crc:$d8f4bbde),(n:'ee15-.f15';l:$10000;p:$60000;crc:$81e3e68b));
        chelnov_proms:array[0..1] of tipo_roms=(
        (n:'ee21.k8';l:$400;p:$0;crc:$b1db6586),(n:'ee20.l6';l:$400;p:$400;crc:$41816132));
        //DIP
        karnov_dip:array [0..9] of def_dip=(
        (mask:$3;name:'Coin A';number:4;dip:((dip_val:0;dip_name:'2C 1C'),(dip_val:3;dip_name:'1C 1C'),(dip_val:2;dip_name:'1C 2C'),(dip_val:1;dip_name:'1C 3C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Coin B';number:4;dip:((dip_val:0;dip_name:'2C 1C'),(dip_val:$c;dip_name:'1C 1C'),(dip_val:8;dip_name:'1C 2C'),(dip_val:4;dip_name:'1C 3C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Flip Screen';number:2;dip:((dip_val:$20;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Cabinet';number:2;dip:((dip_val:0;dip_name:'Upright'),(dip_val:$40;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$300;name:'Lives';number:4;dip:((dip_val:$100;dip_name:'1'),(dip_val:$300;dip_name:'3'),(dip_val:$200;dip_name:'5'),(dip_val:0;dip_name:'Infinite'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c00;name:'Bonus Life';number:4;dip:((dip_val:$c00;dip_name:'50 "K"'),(dip_val:$800;dip_name:'70 "K"'),(dip_val:$400;dip_name:'90 "K"'),(dip_val:0;dip_name:'100 "K"'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$3000;name:'Difficulty';number:4;dip:((dip_val:$2000;dip_name:'Easy'),(dip_val:$3000;dip_name:'Normal'),(dip_val:$1000;dip_name:'Hard'),(dip_val:0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4000;name:'Demo Sounds';number:2;dip:((dip_val:0;dip_name:'Off'),(dip_val:$4000;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8000;name:'Time Speed';number:2;dip:((dip_val:$8000;dip_name:'Normal'),(dip_val:0;dip_name:'Fast'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        chelnov_dip:array [0..8] of def_dip=(
        (mask:$3;name:'Coin A';number:4;dip:((dip_val:0;dip_name:'1C 6C'),(dip_val:3;dip_name:'1C 2C'),(dip_val:2;dip_name:'1C 3C'),(dip_val:1;dip_name:'1C 4C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Coin B';number:4;dip:((dip_val:0;dip_name:'1C 4C'),(dip_val:$c;dip_name:'1C 1C'),(dip_val:8;dip_name:'2C 1C'),(dip_val:4;dip_name:'3C 1C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Demo Sounds';number:2;dip:((dip_val:$20;dip_name:'On'),(dip_val:$0;dip_name:'Off'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Flip Screen';number:2;dip:((dip_val:0;dip_name:'On'),(dip_val:$40;dip_name:'Off'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Cainet';number:2;dip:((dip_val:0;dip_name:'Upright'),(dip_val:$80;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$300;name:'Lives';number:4;dip:((dip_val:$100;dip_name:'1'),(dip_val:$300;dip_name:'3'),(dip_val:$200;dip_name:'5'),(dip_val:0;dip_name:'Infinite'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c00;name:'Difficulty';number:4;dip:((dip_val:$800;dip_name:'Easy'),(dip_val:$c00;dip_name:'Normal'),(dip_val:$400;dip_name:'Hard'),(dip_val:0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$1000;name:'Allow Continue';number:2;dip:((dip_val:$0;dip_name:'No'),(dip_val:$1000;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

type
 t_i8751_w=procedure (valor:word);
var
 rom:array[0..$2ffff] of word;
 ram:array[0..$1fff] of word;
 sprite_ram,sprite_ram2:array[0..$7ff] of word;
 background_ram,video_ram:array[0..$3ff] of word;
 sound_latch,i8751_coin_mask,i8751_level:byte;
 i8751_command_queue,i8751_coin_pending,i8751_return,scroll_x,scroll_y:word;
 i8751_latch,i8751_needs_ack:boolean;
 i8751_write_proc:t_i8751_w;

procedure karnov_i8751_w(valor:word);
begin
// Pending coin operations may cause protection commands to be queued */
if i8751_needs_ack then begin
   i8751_command_queue:=valor;
   exit;
end;
i8751_return:=0;
if (valor=$100) then i8751_return:=$56b;
if ((valor and $f00)=$300) then i8751_return:=(valor and $ff)*$12; // Player sprite mapping */
// I'm not sure the ones marked ^ appear in the right order */
if (valor=$400) then i8751_return:=$4000; // Get The Map... */
if (valor=$402) then i8751_return:=$40a6; // Ancient Ruins */
if (valor=$403) then i8751_return:=$4054; // Forest... */
if (valor=$404) then i8751_return:=$40de; // ^Rocky hills */
if (valor=$405) then i8751_return:=$4182; // Sea */
if (valor=$406) then i8751_return:=$41ca; // Town */
if (valor=$407) then i8751_return:=$421e; // Desert */
if (valor=$401) then i8751_return:=$4138; // ^Whistling wind */
if (valor=$408) then i8751_return:=$4276; // ^Heavy Gates */
m68000_0.irq[6]:=HOLD_LINE; // Signal main cpu task is complete */
i8751_needs_ack:=true;
end;

procedure chelnov_i8751_w(valor:word);
begin
// Pending coin operations may cause protection commands to be queued */
if i8751_needs_ack then begin
   i8751_command_queue:=valor;
   exit;
end;
i8751_return:=0;
if (valor=$200) then i8751_return:=$7736;
if (valor=$100) then i8751_return:=$71c;
if ((valor and $e000)=$6000) then begin
   if (valor and $1000)<>0 then i8751_return:=((valor and $0f)+((valor shr 4) and $0f))*((valor shr 8) and $0f)
      else i8751_return:=(valor and $0f)*(((valor shr 8) and $0f)+((valor shr 4) and $0f));
end;
if ((valor and $f000)=$1000) then i8751_level:=1;  // Level 1
if ((valor and $f000)=$2000) then i8751_level:=i8751_level+1;  // Level Increment
if ((valor and $f000)=$3000) then begin
   // Sprite table mapping */
   case i8751_level of
        1:begin // Level 1, Sprite mapping tables */
                case (valor and $ff) of
                     0..2:i8751_return:=0;
                     3..7:i8751_return:=1;
                     8..$b:i8751_return:=2;
                     $c..$f:i8751_return:=3;
                     $10..$18:i8751_return:=4;
                     $19..$1a:i8751_return:=5;
                     $1b..$21:i8751_return:=6;
                     $22..$27:i8751_return:=7;
                       else i8751_return:=8;
                end;
          end;
	2:begin // Level 2, Sprite mapping tables, all sets are the same
                case (valor and $ff) of
                     0..2:i8751_return:=0;
                     3..8:i8751_return:=1;
                     9..$10:i8751_return:=2;
                     $11..$1a:i8751_return:=3;
                     $1b..$20:i8751_return:=4;
                     $21..$27:i8751_return:=5;
                        else i8751_return:=6;
                 end;
          end;
	3:begin // Level 3, Sprite mapping tables, all sets are the same
                 case (valor and $ff) of
                      0..4:i8751_return:=0;
                      5..8:i8751_return:=1;
                      9..$c:i8751_return:=2;
                      $d..$10:i8751_return:=3;
                      $11..$1a:i8751_return:=4;
                      $1b:i8751_return:=5;
                      $1c..$21:i8751_return:=6;
                      $22..$26:i8751_return:=7;
                         else i8751_return:=8;
                  end;
          end;
	4:begin // Level 4, Sprite mapping tables, all sets are the same
                   case (valor and $ff) of
                        0..3:i8751_return:=0;
                        4..$b:i8751_return:=1;
                        $c..$e:i8751_return:=2;
                        $f..$18:i8751_return:=3;
                        $19..$1b:i8751_return:=4;
                        $1c..$21:i8751_return:=5;
                        $22..$28:i8751_return:=6;
                           else i8751_return:=7;
                   end;
          end;
	5:begin // Level 5, Sprite mapping tables, all sets are the same
                   case (valor and $ff) of
                        0..6:i8751_return:=0;
                        7..$d:i8751_return:=1;
                        $e..$13:i8751_return:=2;
                        $14..$19:i8751_return:=3;
                        $1a..$22:i8751_return:=4;
                        $23..$26:i8751_return:=5;
                           else i8751_return:=6;
                   end;
          end;
	6:begin //Level 6, Sprite mapping tables, all sets are the same
                   case (valor and $ff) of
                        0..2:i8751_return:=0;
                        3..$a:i8751_return:=1;
                        $b..$10:i8751_return:=2;
                        $11..$16:i8751_return:=3;
                        $17..$1c:i8751_return:=4;
                        $1d..$23:i8751_return:=5;
                            else i8751_return:=6;
                   end;
          end;
	7:begin // Level 7, Sprite mapping tables, all sets are the same
                   case (valor and $ff) of
                        0..4:i8751_return:=0;
                        5..$a:i8751_return:=1;
                        $b..$10:i8751_return:=2;
                        $11..$19:i8751_return:=3;
                        $1a..$20:i8751_return:=4;
                        $21..$26:i8751_return:=5;
                            else i8751_return:=6;
                   end;
          end;
   end;
end;
m68000_0.irq[6]:=HOLD_LINE;
i8751_needs_ack:=true;
end;

procedure eventos_karnov;
begin
if event.arcade then begin
  //P1 + P2
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fffe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fffd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fffb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fff7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ffef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $ffdf) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.but2[0] then marcade.in0:=(marcade.in0 and $ffbf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.up[1] then marcade.in0:=(marcade.in0 and $feff) else marcade.in0:=(marcade.in0 or $100);
  if arcade_input.down[1] then marcade.in0:=(marcade.in0 and $fdff) else marcade.in0:=(marcade.in0 or $200);
  if arcade_input.left[1] then marcade.in0:=(marcade.in0 and $fbff) else marcade.in0:=(marcade.in0 or $400);
  if arcade_input.right[1] then marcade.in0:=(marcade.in0 and $f7ff) else marcade.in0:=(marcade.in0 or $800);
  if arcade_input.but0[1] then marcade.in0:=(marcade.in0 and $efff) else marcade.in0:=(marcade.in0 or $1000);
  if arcade_input.but1[1] then marcade.in0:=(marcade.in0 and $dfff) else marcade.in0:=(marcade.in0 or $2000);
  if arcade_input.but2[1] then marcade.in0:=(marcade.in0 and $bfff) else marcade.in0:=(marcade.in0 or $4000);
  //SYSTEM
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $F7) else marcade.in1:=(marcade.in1 or $8);
  //Coin
  if main_vars.tipo_maquina=219 then begin
     if arcade_input.coin[0] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
     if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  end else begin
     if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
     if arcade_input.coin[0] then marcade.in2:=(marcade.in2 and $bf) else marcade.in2:=(marcade.in2 or $40);
  end;
end;
end;

procedure update_video_karnov;
var
   f,atrib,nchar,nchar2,x,y:word;
   color:byte;
   extra,fx,fy:boolean;
begin
for f:=$0 to $3ff do begin
    y:=f shr 5;
    x:=f and $1f;
    //Chars
    if gfx[0].buffer[f] then begin
      atrib:=video_ram[f];
      nchar:=atrib and $3ff;
      color:=atrib shr 14;
      put_gfx_trans(x*8,y*8,nchar,color shl 3,1,0);
      gfx[0].buffer[f]:=false;
    end;
    //Tiles
    if gfx[1].buffer[f] then begin
      atrib:=background_ram[f];
      nchar:=atrib and $7ff;
      color:=atrib shr 12;
      put_gfx(x*16,y*16,nchar,(color shl 4)+$200,2,1);
      gfx[1].buffer[f]:=false;
    end;
end;
scroll_x_y(2,3,scroll_x,scroll_y);
//Sprites
for f:=0 to $1ff do begin
    y:=sprite_ram2[f*4];
    if ((y and $8000)=0) then continue;
    atrib:=sprite_ram2[(f*4)+1];
    if ((atrib and $1)=0) then continue;
    y:=y and $1ff;
    nchar:=sprite_ram2[(f*4)+3];
    color:=nchar shr 12;
    nchar:=nchar and $fff;
    x:=sprite_ram2[(f*4)+2] and $1ff;
    extra:=(atrib and $10)<>0;
    fy:=(atrib and $2)<>0;
    fx:=(atrib and $4)<>0;
    if extra then begin
       y:=y+16;
       nchar:=nchar and $ffe;
    end;
    //Convert the co-ords..
    x:=(x+16) and $1ff;
    y:=(y+16) and $1ff;
    x:=(256-x) and $1ff;
    y:=(256-y) and $1ff;
    // Y Flip determines order of multi-sprite */
    if (extra and fy) then begin
       nchar2:=nchar;
       nchar:=nchar+1;
    end else nchar2:=nchar+1;
    put_gfx_sprite(nchar,(color shl 4)+256,fx,fy,2);
    actualiza_gfx_sprite(x,y,3,2);
    // 1 more sprite drawn underneath */
    if extra then begin
       put_gfx_sprite(nchar2,(color shl 4)+256,fx,fy,2);
       actualiza_gfx_sprite(x,y+16,3,2);
    end;
end;
actualiza_trozo(0,0,256,256,1,0,0,256,256,3);
actualiza_trozo_final(0,8,256,240,3);
end;

procedure karnov_i8751_interrupt;
begin
if (marcade.in2=i8751_coin_mask) then i8751_latch:=true;
if ((marcade.in2<>i8751_coin_mask) and i8751_latch) then begin
   if i8751_needs_ack then begin
      // i8751 is busy - queue the command
      i8751_coin_pending:=marcade.in2 or $8000;
   end else begin
       i8751_return:=marcade.in2 or $8000;
       m68000_0.irq[6]:=HOLD_LINE;
       i8751_needs_ack:=true;
   end;
   i8751_latch:=false;
end;
end;

procedure karnov_principal;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
frame_s:=m6502_0.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to $ff do begin
   m68000_0.run(frame_m);
   frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
   m6502_0.run(frame_s);
   frame_s:=frame_s+m6502_0.tframes-m6502_0.contador;
   case f of
      30:marcade.in1:=marcade.in1 and $7f;
      247:begin
            marcade.in1:=marcade.in1 or $80;
            karnov_i8751_interrupt;
            m68000_0.irq[7]:=HOLD_LINE;
            update_video_karnov;
          end;
   end;
 end;
 eventos_karnov;
 video_sync;
end;
end;

function karnov_control_r(direccion:byte):word;
var
   ret:word;
begin
ret:=$ffff;
case (direccion shl 1) of
     0:ret:=marcade.in0;
     2:ret:=marcade.in1; //Start buttons & VBL
     4:ret:=marcade.dswa; //dsw
     6:ret:=i8751_return; //i8751 return values
end;
karnov_control_r:=ret;
end;

function karnov_getword(direccion:dword):word;
begin
case direccion of
  $0..$5ffff:karnov_getword:=rom[direccion shr 1];
  $60000..$63fff:karnov_getword:=ram[(direccion and $3fff) shr 1];
  $80000..$80fff:karnov_getword:=sprite_ram[(direccion and $fff) shr 1];
  $a0000..$a07ff:karnov_getword:=video_ram[(direccion and $7ff) shr 1];
  $c0000..$c0007:karnov_getword:=karnov_control_r((direccion and $7) shr 1);
end;
end;

procedure karnov_control_w(direccion,valor:word);
begin
// Mnemonics filled in from the schematics, brackets are my comments */
case (direccion shl 1) of
     0:begin // SECLR (Interrupt ack for Level 6 i8751 interrupt)
           m68000_0.irq[6]:=CLEAR_LINE;
	   if i8751_needs_ack then begin
	      // If a command and coin insert happen at once, then the i8751 will queue the coin command until the previous command is ACK'd */
	      if (i8751_coin_pending<>0) then begin
	          i8751_return:=i8751_coin_pending;
		        m68000_0.irq[6]:=HOLD_LINE;
		        i8751_coin_pending:=0;
	      end else if (i8751_command_queue<>0) then begin
	                  // Pending control command - just write it back as SECREQ
			              i8751_needs_ack:=false;
			              karnov_control_w(3,$ffff);
			              i8751_command_queue:=0;
	               end else begin
			              i8751_needs_ack:=false;
				         end;
           end;
       end;
     2:begin // SONREQ (Sound CPU byte)
          sound_latch:=valor and $ff;
	        m6502_0.change_nmi(PULSE_LINE);
       end;
     4:copymemory(@sprite_ram2,@sprite_ram,$800*2); // DM (DMA to buffer spriteram)
     6:i8751_write_proc(valor); // SECREQ (Interrupt & Data to i8751)
     8:begin //HSHIFT (9 bits) - Top bit indicates video flip
          scroll_x:=valor and $1ff;
	        main_screen.flip_main_screen:=(valor shr 15)<>0;
       end;
     $a:scroll_y:=valor and $1ff; // VSHIFT
     $c:begin // SECR (Reset i8751)
          i8751_needs_ack:=false;
	        i8751_coin_pending:=0;
	        i8751_command_queue:=0;
	        i8751_return:=0;
        end;
     $e:m68000_0.irq[7]:=CLEAR_LINE; // INTCLR (Interrupt ack for Level 7 vbl interrupt) */
end;
end;

procedure karnov_putword(direccion:dword;valor:word);
begin
if direccion<$60000 then exit;
case direccion of
  $60000..$63fff:ram[(direccion and $3fff) shr 1]:=valor;
  $80000..$80fff:sprite_ram[(direccion and $fff) shr 1]:=valor;
  $a0000..$a0fff:begin
                      video_ram[(direccion and $7ff) shr 1]:=valor;
                      gfx[0].buffer[(direccion and $7ff) shr 1]:=true;
                 end;
  $a1000..$a17ff:begin
                      background_ram[(direccion and $7ff) shr 1]:=valor;
                      gfx[1].buffer[(direccion and $7ff) shr 1]:=true;
                 end;
  $a1800..$a1fff:begin
                      direccion:=(direccion and $7ff) shr 1;
                      direccion:=((direccion and $1f) shl 5) or ((direccion and $3e0) shr 5);
	                    background_ram[direccion and $3ff]:=valor;
                      gfx[1].buffer[direccion and $3ff]:=true;
                 end;
  $c0000..$c000f:karnov_control_w((direccion and $f) shr 1,valor);
end;
end;

function karnov_snd_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$5ff,$8000..$ffff:karnov_snd_getbyte:=mem_snd[direccion];
  $800:karnov_snd_getbyte:=sound_latch;
end;
end;

procedure karnov_snd_putbyte(direccion:word;valor:byte);
begin
if direccion>$7fff then exit;
case direccion of
  $0..$5ff:mem_snd[direccion]:=valor;
  $1000:ym2203_0.Control(valor);
  $1001:ym2203_0.Write(valor);
  $1800:ym3812_0.control(valor);
  $1801:ym3812_0.write(valor);
end;
end;

procedure karnov_sound_update;
begin
  ym3812_0.update;
  ym2203_0.Update;
end;

procedure snd_irq(irqstate:byte);
begin
  m6502_0.change_irq(irqstate);
end;

//Main
procedure reset_karnov;
begin
 m68000_0.reset;
 m6502_0.reset;
 ym3812_0.reset;
 ym2203_0.reset;
 reset_audio;
 marcade.in0:=$FFFF;
 marcade.in1:=$7f;
 if main_vars.tipo_maquina=219 then marcade.in2:=$7
   else marcade.in2:=$e0;
 sound_latch:=0;
 i8751_latch:=false;
 i8751_return:=0;
 i8751_needs_ack:=false;
 i8751_coin_pending:=0;
 i8751_command_queue:=0;
 i8751_level:=0;
end;

function iniciar_karnov:boolean;
const
  pc_x:array[0..7] of dword=(0, 1, 2, 3, 4, 5, 6, 7);
  ps_x:array[0..15] of dword=(16*8+0, 16*8+1, 16*8+2, 16*8+3, 16*8+4, 16*8+5, 16*8+6, 16*8+7,
			0, 1, 2, 3, 4, 5, 6, 7);
  ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8 );
var
  memoria_temp:array[0..$7ffff] of byte;
  f:word;
  ctemp1,ctemp2,ctemp3,ctemp4:byte;
  colores:tpaleta;

procedure convert_chars;
begin
init_gfx(0,8,8,$400);
gfx[0].trans[0]:=true;
gfx_set_desc_data(3,0,8*8,$6000*8,$4000*8,$2000*8);
convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@ps_y[0],false,false);
end;

procedure convert_tiles(num_gfx,mul:byte);
begin
init_gfx(num_gfx,16,16,$800*mul);
gfx[num_gfx].trans[0]:=true;
gfx_set_desc_data(4,0,16*16,($30000*mul)*8,0,($10000*mul)*8,($20000*mul)*8);
convert_gfx(num_gfx,0,@memoria_temp[0],@ps_x[0],@ps_y[0],false,false);
end;

begin
iniciar_karnov:=false;
iniciar_audio(false);
screen_init(1,256,256,true);
screen_init(2,512,512,true);
screen_mod_scroll(2,512,256,511,512,256,511);
screen_init(3,512,512,false,true);
iniciar_video(256,240);
//Main CPU
m68000_0:=cpu_m68000.create(10000000,256);
m68000_0.change_ram16_calls(karnov_getword,karnov_putword);
//Sound CPU
m6502_0:=cpu_m6502.create(1500000,256,TCPU_M6502);
m6502_0.change_ram_calls(karnov_snd_getbyte,karnov_snd_putbyte);
m6502_0.init_sound(karnov_sound_update);
//Sound Chips
ym3812_0:=ym3812_chip.create(YM3526_FM,3000000);
ym3812_0.change_irq_calls(snd_irq);
ym2203_0:=ym2203_chip.create(1500000,0.25,0.25);
case main_vars.tipo_maquina of
  219:begin  //Karnov
        //cargar roms
        if not(cargar_roms16w(@rom,@karnov_rom,'karnov.zip',0)) then exit;
        //cargar sonido
        if not(roms_load(@mem_snd,@karnov_sound,'karnov.zip',sizeof(karnov_sound))) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,@karnov_char,'karnov.zip',sizeof(karnov_char))) then exit;
        convert_chars;
        //tiles
        if not(roms_load(@memoria_temp,@karnov_tiles,'karnov.zip',sizeof(karnov_tiles))) then exit;
        convert_tiles(1,1);
        //sprites
        if not(roms_load(@memoria_temp,@karnov_sprites,'karnov.zip',sizeof(karnov_sprites))) then exit;
        convert_tiles(2,2);
        //Paleta
        if not(roms_load(@memoria_temp,@karnov_proms,'karnov.zip',sizeof(karnov_proms))) then exit;
        //DIP
        marcade.dswa:=$ffbf;
        marcade.dswa_val:=@karnov_dip;
        i8751_coin_mask:=$7;
        i8751_write_proc:=karnov_i8751_w;
      end;
  220:begin  //Karnov
        //cargar roms
        if not(cargar_roms16w(@rom,@chelnov_rom,'chelnov.zip',0)) then exit;
        //cargar sonido
        if not(roms_load(@mem_snd,@chelnov_sound,'chelnov.zip',sizeof(chelnov_sound))) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,@chelnov_char,'chelnov.zip',sizeof(chelnov_char))) then exit;
        convert_chars;
        //tiles
        if not(roms_load(@memoria_temp,@chelnov_tiles,'chelnov.zip',sizeof(chelnov_tiles))) then exit;
        convert_tiles(1,1);
        //sprites
        if not(roms_load(@memoria_temp,@chelnov_sprites,'chelnov.zip',sizeof(chelnov_sprites))) then exit;
        convert_tiles(2,2);
        //Paleta
        if not(roms_load(@memoria_temp,@chelnov_proms,'chelnov.zip',sizeof(chelnov_proms))) then exit;
        //DIP
        marcade.dswa:=$ff7f;
        marcade.dswa_val:=@chelnov_dip;
        i8751_coin_mask:=$e0;
        rom[$062a shr 1]:=$4e71;  // hangs waiting on i8751 int
        i8751_write_proc:=chelnov_i8751_w;
      end;
end;
//poner la paleta
for f:=0 to $3ff do begin
    // red
    ctemp1:=(memoria_temp[f] shr 0) and $01;
    ctemp2:=(memoria_temp[f] shr 1) and $01;
    ctemp3:=(memoria_temp[f] shr 2) and $01;
    ctemp4:=(memoria_temp[f] shr 3) and $01;
    colores[f].r:=$e*ctemp1+$1f*ctemp2+$43*ctemp3+$8f*ctemp4;
    // green
    ctemp1:=(memoria_temp[f] shr 4) and $01;
    ctemp2:=(memoria_temp[f] shr 5) and $01;
    ctemp3:=(memoria_temp[f] shr 6) and $01;
    ctemp4:=(memoria_temp[f] shr 7) and $01;
    colores[f].g:=$e*ctemp1+$1f*ctemp2+$43*ctemp3+$8f*ctemp4;
    // blue
    ctemp1:=(memoria_temp[f+$400] shr 0) and $01;
    ctemp2:=(memoria_temp[f+$400] shr 1) and $01;
    ctemp3:=(memoria_temp[f+$400] shr 2) and $01;
    ctemp4:=(memoria_temp[f+$400] shr 3) and $01;
    colores[f].b:=$e*ctemp1+$1f*ctemp2+$43*ctemp3+$8f*ctemp4;
end;
set_pal(colores,$400);
//final
reset_karnov;
iniciar_karnov:=true;
end;

procedure Cargar_karnov;
begin
llamadas_maquina.bucle_general:=karnov_principal;
llamadas_maquina.iniciar:=iniciar_karnov;
llamadas_maquina.reset:=reset_karnov;
end;

end.
