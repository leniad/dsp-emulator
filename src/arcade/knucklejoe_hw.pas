unit knucklejoe_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,m680x,main_engine,controls_engine,ay_8910,gfx_engine,timer_engine,
     sn_76496,rom_engine,pal_engine,sound_engine;

function iniciar_knjoe:boolean;

implementation
const
        knjoe_rom:array[0..2] of tipo_roms=(
        (n:'kj-1.bin';l:$4000;p:0;crc:$4e4f5ff2),(n:'kj-2.bin';l:$4000;p:$4000;crc:$cb11514b),
        (n:'kj-3.bin';l:$4000;p:$8000;crc:$0f50697b));
        knjoe_pal:array[0..4] of tipo_roms=(
        (n:'kjclr1.bin';l:$100;p:0;crc:$c3378ac2),(n:'kjclr2.bin';l:$100;p:$100;crc:$2126da97),
        (n:'kjclr3.bin';l:$100;p:$200;crc:$fde62164),(n:'kjprom5.bin';l:$20;p:$300;crc:$5a81dd9f),
        (n:'kjprom4.bin';l:$100;p:$320;crc:$48dc2066));
        knjoe_sprites:array[0..2] of tipo_roms=(
        (n:'kj-4.bin';l:$8000;p:0;crc:$a499ea10),(n:'kj-6.bin';l:$8000;p:$8000;crc:$815f5c0a),
        (n:'kj-5.bin';l:$8000;p:$10000;crc:$11111759));
        knjoe_sprites2:array[0..2] of tipo_roms=(
        (n:'kj-7.bin';l:$4000;p:0;crc:$121fcccb),(n:'kj-9.bin';l:$4000;p:$4000;crc:$affbe3eb),
        (n:'kj-8.bin';l:$4000;p:$8000;crc:$e057e72a));
        knjoe_tiles:array[0..2] of tipo_roms=(
        (n:'kj-10.bin';l:$4000;p:0;crc:$74d3ba33),(n:'kj-11.bin';l:$4000;p:$4000;crc:$8ea01455),
        (n:'kj-12.bin';l:$4000;p:$8000;crc:$33367c41));
        knjoe_sound:tipo_roms=(n:'kj-13.bin';l:$2000;p:$6000;crc:$0a0be3f5);
        //Dip
        knjoe_dip_a:array [0..4] of def_dip=(
        (mask:$7;name:'Coin A';number:8;dip:((dip_val:$0;dip_name:'5C 1C'),(dip_val:$4;dip_name:'4C 1C'),(dip_val:$2;dip_name:'3C 1C'),(dip_val:$6;dip_name:'2C 1C'),(dip_val:$7;dip_name:'1C 1C'),(dip_val:$3;dip_name:'1C 2C'),(dip_val:$5;dip_name:'1C 3C'),(dip_val:$1;dip_name:'1C 5C'),(),(),(),(),(),(),(),())),
        (mask:$18;name:'Coin B';number:4;dip:((dip_val:$0;dip_name:'3C 1C'),(dip_val:$10;dip_name:'2C 1C'),(dip_val:$18;dip_name:'1C 1C'),(dip_val:$8;dip_name:'1C 2C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Infinite Energy';number:2;dip:((dip_val:$20;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Free Play (not working)';number:2;dip:((dip_val:$40;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        knjoe_dip_b:array [0..5] of def_dip=(
        (mask:$2;name:'Cabinet';number:2;dip:((dip_val:$2;dip_name:'Upright'),(dip_val:$0;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Lives';number:2;dip:((dip_val:$4;dip_name:'3'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$18;name:'Bonus Life';number:4;dip:((dip_val:$18;dip_name:'10K 20K+'),(dip_val:$10;dip_name:'20K 40K+'),(dip_val:$8;dip_name:'30K 60K+'),(dip_val:$0;dip_name:'40K 80K+'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$60;name:'Difficulty';number:4;dip:((dip_val:$60;dip_name:'Easy'),(dip_val:$40;dip_name:'Medium'),(dip_val:$20;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Demo Sound';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 sound_command,val_port1,val_port2,tile_bank,sprite_bank:byte;
 scroll_x:word;

procedure update_video_knjoe;
const
  pribase:array[0..3] of word=($e980, $e880, $e900, $e800);
  spr_mask:array[1..2] of word=($3ff,$1ff);
var
  f,nchar,y,x,offs:word;
  i,atrib,color:byte;
begin
//Background
for f:=0 to $7ff do begin
  if gfx[0].buffer[f] then begin
    x:=f mod 64;
    y:=31-(f div 64);
    atrib:=memoria[$c001+(f*2)];
    color:=(atrib and $f) shl 3;
    nchar:=memoria[$c000+(f*2)]+((atrib and $c0) shl 2)+(tile_bank shl 6);
    put_gfx_flip(x*8,y*8,nchar and $7ff,color,1,0,(atrib and $20)<>0,(atrib and $10)<>0);
    gfx[0].buffer[f]:=false;
  end;
end;
scroll__x(1,2,scroll_x);
//Sprites
for i:=0 to 3 do begin
		for f:=$1f downto 0 do begin
			offs:=pribase[i]+(f*4);
      y:=memoria[offs]+1;
      x:=memoria[offs+3];
      atrib:=memoria[offs+1];
			nchar:=(memoria[offs+2]+((atrib and $10) shl 5)+((atrib and $20) shl 3)) and spr_mask[sprite_bank];
			color:=(atrib and $0f) shl 3;
      put_gfx_sprite(nchar,color,(atrib and $40)<>0,(atrib and $80)=0,sprite_bank);
      actualiza_gfx_sprite(x,y,2,sprite_bank);
		end;
end;
//Devolver la parte de arriba!
actualiza_trozo(0,0,256,64,1,0,0,256,64,2);
actualiza_trozo_final(8,0,240,256,2);
end;

procedure eventos_knjoe;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  //System
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  //P2
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
end;
end;

procedure knjoe_principal;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=z80_0.tframes;
frame_s:=m6800_0.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
    //main
    z80_0.run(frame_m);
    frame_m:=frame_m+z80_0.tframes-z80_0.contador;
    //snd
    m6800_0.run(frame_s);
    frame_s:=frame_s+m6800_0.tframes-m6800_0.contador;
  end;
  z80_0.change_irq(HOLD_LINE);
  update_video_knjoe;
  eventos_knjoe;
  video_sync;
end;
end;

function knjoe_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$cfff,$e800..$ffff:knjoe_getbyte:=memoria[direccion];
  $d800:knjoe_getbyte:=marcade.in0;
  $d801:knjoe_getbyte:=marcade.in1;
  $d802:knjoe_getbyte:=marcade.in2;
  $d803:knjoe_getbyte:=marcade.dswa;
  $d804:knjoe_getbyte:=marcade.dswb;
end;
end;

procedure knjoe_putbyte(direccion:word;valor:byte);
var
  tempb:byte;
begin
case direccion of
    0..$bfff:;
    $c000..$cfff:if memoria[direccion]<>valor then begin
                    gfx[0].buffer[(direccion and $fff) shr 1]:=true;
                    memoria[direccion]:=valor;
                 end;
    $d000:scroll_x:=(scroll_x and $ff00) or valor;
    $d001:scroll_x:=(scroll_x and $00ff) or ((valor and 1) shl 8);
    $d800:if ((valor and $80)=0) then sound_command:=valor and $7f
          	else m6800_0.change_irq(ASSERT_LINE);
    $d801:begin
            tempb:=valor and $10;
            if tile_bank<>tempb then begin
              tile_bank:=tempb;
              fillchar(gfx[0].buffer,$800,1);
            end;
            tempb:=1+((valor and $04) shr 2);
            if sprite_bank<>tempb then begin
              sprite_bank:=tempb;
              fillchar(memoria[$f100],$180,0);
            end;
            main_screen.flip_main_screen:=(valor and $1)<>0;
          end;
    $d802:sn_76496_0.Write(valor);
    $d803:sn_76496_1.Write(valor);
    $e800..$ffff:memoria[direccion]:=valor;
end;
end;

//sonido
function snd_getbyte(direccion:word):byte;
begin
direccion:=direccion and $7fff;
case direccion of
  $0..$ff:snd_getbyte:=m6800_0.m6803_internal_reg_r(direccion);
  $2000..$7fff:snd_getbyte:=mem_snd[direccion];
end;
end;

procedure snd_putbyte(direccion:word;valor:byte);
begin
direccion:=direccion and $7fff;
case direccion of
  $0..$ff:m6800_0.m6803_internal_reg_w(direccion,valor);
  $1000..$1fff:m6800_0.change_irq(CLEAR_LINE);
  $2000..$7fff:;
end;
end;

procedure out_port1(valor:byte);
begin
  val_port1:=valor;
end;

procedure out_port2(valor:byte);
begin
  if (((val_port2 and $01)<>0) and ((not(valor and $01))<>0)) then begin
		// control or data port? */
		if (val_port2 and $04)<>0 then begin
			if (val_port2 and $08)<>0 then ay8910_0.control(val_port1);
		end else begin
			if (val_port2 and $08)<>0 then AY8910_0.Write(val_port1);
		end;
	end;
  val_port2:=valor;
end;

function in_port1:byte;
var
  ret:byte;
begin
 ret:=$ff;
 if (val_port2 and $08)<>0 then ret:=ay8910_0.Read;
 in_port1:=ret;
end;

function in_port2:byte;
begin
  in_port2:=0;
end;

function ay0_porta_r:byte;
begin
  ay0_porta_r:=sound_command;
end;

procedure knjoe_sound_update;
begin
  ay8910_0.update;
  sn_76496_0.Update;
  sn_76496_1.Update;
end;

procedure knjoe_snd_nmi;
begin
  m6800_0.change_nmi(PULSE_LINE);
end;

//Main
procedure reset_knjoe;
begin
 z80_0.reset;
 m6800_0.reset;
 AY8910_0.reset;
 sn_76496_0.reset;
 sn_76496_1.reset;
 reset_audio;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 sound_command:=0;
 val_port1:=0;
 val_port2:=0;
 tile_bank:=0;
 sprite_bank:=1;
 scroll_x:=0;
end;

function iniciar_knjoe:boolean;
var
  f:word;
  colores:tpaleta;
  ctemp1,ctemp2,ctemp3:byte;
  memoria_temp:array[0..$17fff] of byte;
const
  ps_x:array[0..15] of dword=(0, 1, 2, 3, 4, 5, 6, 7,
			8*8+0, 8*8+1, 8*8+2, 8*8+3, 8*8+4, 8*8+5, 8*8+6, 8*8+7 );
  ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			16*8, 17*8, 18*8, 19*8, 20*8, 21*8, 22*8, 23*8);
  pc_y:array[0..7] of dword=(7*8, 6*8, 5*8, 4*8, 3*8, 2*8, 1*8, 0*8);
begin
llamadas_maquina.bucle_general:=knjoe_principal;
llamadas_maquina.reset:=reset_knjoe;
llamadas_maquina.fps_max:=55;
iniciar_knjoe:=false;
iniciar_audio(false);
screen_init(1,512,256);
screen_mod_scroll(1,512,256,511,256,256,255);
screen_init(2,512,256,false,true);
screen_mod_sprites(2,256,0,$ff,0);
iniciar_video(240,256);
//Main CPU
z80_0:=cpu_z80.create(6000000,256);
z80_0.change_ram_calls(knjoe_getbyte,knjoe_putbyte);
//Sound CPU
m6800_0:=cpu_m6800.create(3579545,256,TCPU_M6803);
m6800_0.change_ram_calls(snd_getbyte,snd_putbyte);
m6800_0.change_io_calls(in_port1,in_port2,nil,nil,out_port1,out_port2,nil,nil);
m6800_0.init_sound(knjoe_sound_update);
//sound chips
ay8910_0:=ay8910_chip.create(3579545 div 4,AY8910,1);
ay8910_0.change_io_calls(ay0_porta_r,nil,nil,nil);
sn_76496_0:=sn76496_chip.Create(3579545);
sn_76496_1:=sn76496_chip.Create(3579545);
//Timers (Se divide por cuatro, por que internamente el M6800 va dividido!!!
timers.init(m6800_0.numero_cpu,3579545/4/3970,knjoe_snd_nmi,nil,true);
//cargar roms y ponerlas en sus bancos
if not(roms_load(@memoria,knjoe_rom)) then exit;
//cargar sonido
if not(roms_load(@mem_snd,knjoe_sound)) then exit;
//convertir tiles
if not(roms_load(@memoria_temp,knjoe_tiles)) then exit;
init_gfx(0,8,8,$800);
gfx_set_desc_data(3,0,8*8,2*$800*8*8,$800*8*8,0);
convert_gfx(0,0,@memoria_temp,@ps_x,@pc_y,false,false);
//convertir sprites
if not(roms_load(@memoria_temp,knjoe_sprites)) then exit;
init_gfx(1,16,16,$400);
gfx[1].trans[0]:=true;
gfx_set_desc_data(3,0,32*8,2*$400*32*8,$400*32*8,0);
convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,false);
//convertir sprites 2
if not(roms_load(@memoria_temp,knjoe_sprites2)) then exit;
init_gfx(2,16,16,$200);
gfx[2].trans[0]:=true;
gfx_set_desc_data(3,0,32*8,2*$200*32*8,$200*32*8,0);
convert_gfx(2,0,@memoria_temp,@ps_x,@ps_y,false,false);
//poner la paleta
if not(roms_load(@memoria_temp,knjoe_pal)) then exit;
for f:=0 to $7f do begin
    colores[f].r:=((memoria_temp[f] and $f) shl 4) or (memoria_temp[f] and $f);
    colores[f].g:=((memoria_temp[f+$100] and $f) shl 4) or (memoria_temp[f+$100] and $f);
    colores[f].b:=((memoria_temp[f+$200] and $f) shl 4) or (memoria_temp[f+$200] and $f);
end;
for f:=0 to $f do begin
    //sprites
		ctemp1:=0;
		ctemp2:=(memoria_temp[f+$300] shr 6) and $01;
		ctemp3:=(memoria_temp[f+$300] shr 7) and $01;
		colores[$80+f].r:=$21*ctemp1+$47*ctemp2+$97*ctemp3;
		ctemp1:=(memoria_temp[f+$300] shr 3) and $01;
		ctemp2:=(memoria_temp[f+$300] shr 4) and $01;
		ctemp3:=(memoria_temp[f+$300] shr 5) and $01;
    colores[$80+f].g:=$21*ctemp1+$47*ctemp2+$97*ctemp3;
		ctemp1:=(memoria_temp[f+$300] shr 0) and $01;
		ctemp2:=(memoria_temp[f+$300] shr 1) and $01;
		ctemp3:=(memoria_temp[f+$300] shr 2) and $01;
    colores[$80+f].b:=$21*ctemp1+$47*ctemp2+$97*ctemp3;
end;
set_pal(colores,$100);
//CLUT
for f:=0 to $7f do begin
  gfx[1].colores[f]:=(memoria_temp[f+$320] and $0f)+$80;
  gfx[2].colores[f]:=(memoria_temp[f+$320] and $0f)+$80;
end;
//DIP
marcade.dswa:=$ff;
marcade.dswb:=$7f;
marcade.dswa_val:=@knjoe_dip_a;
marcade.dswb_val:=@knjoe_dip_b;
//final
reset_knjoe;
iniciar_knjoe:=true;
end;

end.
