unit gaplus_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6809,namco_snd,main_engine,controls_engine,gfx_engine,rom_engine,
     pal_engine,sound_engine,namcoio_56xx_58xx,samples;

function iniciar_gaplus:boolean;

implementation
type
        tstars=record
          x,y:integer;
		      col,set_:byte;
        end;
const
        gaplus_cpu1:array[0..2] of tipo_roms=(
        (n:'gp2-4.8d';l:$2000;p:$a000;crc:$e525d75d),(n:'gp2-3b.8c';l:$2000;p:$c000;crc:$d77840a4),
        (n:'gp2-2b.8b';l:$2000;p:$e000;crc:$b3cb90db));
        gaplus_cpu2:array[0..2] of tipo_roms=(
        (n:'gp2-8.11d';l:$2000;p:$a000;crc:$42b9fd7c),(n:'gp2-7.11c';l:$2000;p:$c000;crc:$0621f7df),
        (n:'gp2-6.11b';l:$2000;p:$e000;crc:$75b18652));
        gaplus_sound:tipo_roms=(n:'gp2-1.4b';l:$2000;p:$e000;crc:$ed8aa206);
        gaplus_char:tipo_roms=(n:'gp2-5.8s';l:$2000;p:0;crc:$f3d19987);
        gaplus_sprites:array[0..3] of tipo_roms=(
        (n:'gp2-11.11p';l:$2000;p:0;crc:$57740ff9),(n:'gp2-10.11n';l:$2000;p:$2000;crc:$6cd8ce11),
        (n:'gp2-12.11r';l:$2000;p:$4000;crc:$7316a1f1),(n:'gp2-9.11m';l:$2000;p:$6000;crc:$e6a9ae67));
        gaplus_prom:array[0..6] of tipo_roms=(
        (n:'gp2-3.1p';l:$100;p:$0;crc:$a5091352),(n:'gp2-1.1n';l:$100;p:$100;crc:$8bc8022a),
        (n:'gp2-2.2n';l:$100;p:$200;crc:$8dabc20b),(n:'gp2-7.6s';l:$100;p:$300;crc:$2faa3e09),
        (n:'gp2-6.6p';l:$200;p:$400;crc:$6f99c2da),(n:'gp2-5.6n';l:$200;p:$600;crc:$c7d31657),
        (n:'gp2-4.3f';l:$100;p:$800;crc:$2d9fbdd8));
        gaplus_dip_a:array [0..3] of def_dip2=(
        (mask:$3;name:'Coin B';number:4;val4:(0,1,3,2);name4:('3C 1C','2C 1C','1C 1C','1C 2C')),
        (mask:$8;name:'Demo Sounds';number:2;val2:(0,8);name2:('Off','On')),
        (mask:$30;name:'Coin A';number:4;val4:(0,$10,$30,$20);name4:('3C 1C','2C 1C','1C 1C','1C 2C')),
        (mask:$c0;name:'Lives';number:4;val4:($80,$c0,$40,0);name4:('2','3','4','5')));
        gaplus_dip_b:array [0..2] of def_dip2=(
        (mask:$7;name:'Bonus Life';number:8;val8:(0,1,2,3,4,7,5,6);name8:('30K 70K 70K+','30K 100K 100K+','30K 100K 200K+','50K 100K 100K+','50K 100K 200K+','50K 150K 150K+','50K 150K 300K+','50K 150K')),
        (mask:$8;name:'Round Advance';number:2;val2:(8,0);name2:('Off','On')),
        (mask:$70;name:'Difficulty';number:8;val8:($70,$60,$50,$40,$30,$20,$10,0);name8:('0 - Standard','1 - Easiest','2','3','4','5','6','7 - Hardest')));
        gaplus_dip_c:def_dip2=(mask:$4;name:'Cabinet';number:2;val2:(4,0);name2:('Upright','Cocktail'));
        gaplus_samples:tipo_nombre_samples=(nombre:'bang.wav');
        STARFIELD_CLIPPING_X=16;
        MAX_STARS=100-1;

var
 irq_enable,sub_irq_mask,sound_irq_mask:boolean;
 custom_3:array[0..$f] of byte;
 stars:array[0..MAX_STARS] of tstars;
 total_stars,starfield_framecount:byte;
 starfield_control:array[0..3] of byte;

procedure update_video_gaplus;
var
  color,nchar,pos,sx,sy:word;
  f,x,y,atrib,size,mix,a,b,c,d:byte;
  flipx,flipy,duplicate:boolean;
  xs,ys:integer;
begin
fill_full_screen(3,$100);
//Startfield
starfield_framecount:=starfield_framecount+1;
// check if we're running
if ((starfield_control[0] and 1)<>0) then begin
	// draw the starfields
	for f:=0 to MAX_STARS do begin
    case starfield_control[stars[f].set_+1] of
				$87:; //stand still
				$85,$86:stars[f].x:=stars[f].x+1; //scroll down (speed 1)
				$06:stars[f].x:=stars[f].x+2; //scroll down (speed 2)
				$80:stars[f].x:=stars[f].x-1; //scroll up (speed 1)
				$82:stars[f].x:=stars[f].x-2; //scroll up (speed 2)
				$81:stars[f].x:=stars[f].x-3; //scroll up (speed 3)
				$9f:stars[f].y:=stars[f].y+3; //scroll left (speed 3)
				$af:stars[f].y:=stars[f].y-3; //scroll right (speed 3)
    end;
    if (stars[f].x<STARFIELD_CLIPPING_X) then stars[f].x:=(288-STARFIELD_CLIPPING_X*2)+stars[f].x;
		if (stars[f].x>=(288-STARFIELD_CLIPPING_X)) then stars[f].x:=stars[f].x-(288-STARFIELD_CLIPPING_X*2);
		if (stars[f].y<0) then stars[f].y:=224+stars[f].y;
		if (stars[f].y>=224) then stars[f].y:=stars[f].y-224;
		{ Some stars in the second layer will flash erratically when changing their movements.
		   (It is when at reverse scrolling stage or get elephant head.)
		   This is based on a guess from the video output of the PCB.
		   https://www.youtube.com/watch?v=_1x5Oid3uPg (3:35-, 13:12-)
		   https://www.youtube.com/watch?v=vrmZAUJYXnI (3:14-, 12:40-) }
		if ((stars[f].set_=1) and (starfield_control[2]<>$85) and ((f mod 2)=0)) then begin
			if ((starfield_framecount+f) and 8)<>0 then atrib:=1
        else atrib:=2;
			if ((starfield_framecount+f) and (1 shl atrib))<>0 then continue;
    end;
    xs:=stars[f].x;
		ys:=stars[f].y;
		if ((xs>=0) and (xs<288) and (ys>=0) and (ys<224)) then putpixel(ys+ADD_SPRITE,xs+ADD_SPRITE,1,@paleta[stars[f].col],3);
  end;
end;
for x:=0 to 27 do begin
  for y:=0 to 35 do begin
      sx:=29-x;
      sy:=y-2;
	    if (sy and $20)<>0 then pos:=sx+((sy and $1f) shl 5)
  	    else pos:=sy+(sx shl 5);
      if gfx[0].buffer[pos] then begin
        atrib:=memoria[$400+pos];
        color:=(atrib and $3f) shl 2;
        nchar:=memoria[pos]+((atrib and $80) shl 1);
        put_gfx_mask(x*8,y*8,nchar,color,1,0,$3f,$3f);
        if (atrib and $40)<>0 then put_gfx_mask(x*8,y*8,nchar,color,2,0,$3f,$3f)
          else put_gfx_block_trans(x*8,y*8,2,8,8);
        gfx[0].buffer[pos]:=false;
      end;
  end;
end;
actualiza_trozo(0,0,224,288,1,0,0,224,288,3);
for f:=0 to $3f do begin
  // is it on?
  if (memoria[$1f81+(f*2)] and 2)=0 then begin
      atrib:=memoria[$1f80+(f*2)];
      nchar:=(memoria[$f80+(f*2)] or ((atrib and $40) shl 2)) mod $180;
			color:=(memoria[$f81+(f*2)] and $3f) shl 3;
			sy:=memoria[$1781+(f*2)]+$100*(memoria[$1f81+(f*2)] and 1)-71;
			sx:=memoria[$1780+(f*2)]-8;
			flipy:=(atrib and 1)<>0;
			flipx:=(atrib and 2)<>0;
			size:=((atrib shr 3) and 1) or ((atrib shr 4) and 2);
      //Ver si en lugar de poner los dos sprites solo duplica el primero
			duplicate:=(atrib and $80)<>0;
      case size of
        0:begin //16x16
            put_gfx_sprite_mask(nchar,color,flipx,flipy,1,$3f,$3f);
            actualiza_gfx_sprite(sx,sy,3,1);
          end;
        1:begin //16x32
            if duplicate then begin
              a:=0;b:=0;
            end else begin
              nchar:=nchar and $1fe;
              a:=0 xor byte(flipy);
              b:=1 xor byte(flipy);
            end;
            put_gfx_sprite_mask_diff(nchar+a,color,flipx,false,1,$3f,$3f,0,0);
            put_gfx_sprite_mask_diff(nchar+b,color,flipx,false,1,$3f,$3f,0,16);
            actualiza_gfx_sprite_size(sx,sy,3,16,32);
          end;
        2:begin //32x16
            if duplicate then begin
              a:=0;b:=0;
            end else begin
              nchar:=nchar and $1fd;
              a:=2 xor (byte(flipx) shl 1);
              b:=0 xor (byte(flipx) shl 1);
            end;
            put_gfx_sprite_mask_diff(nchar+a,color,flipx,flipy,1,$3f,$3f,0,0);
            put_gfx_sprite_mask_diff(nchar+b,color,flipx,flipy,1,$3f,$3f,16,0);
            actualiza_gfx_sprite_size(sx,sy,3,32,16);
          end;
        3:begin //32x32
            if duplicate then begin
              a:=0;b:=0;c:=0;d:=0;
            end else begin
              nchar:=nchar and $1fc;
              if flipx then begin
                a:=0;b:=2;c:=1;d:=3
              end else begin
                a:=2;b:=0;c:=3;d:=1;
              end;
              if flipy then begin
                mix:=a;a:=c;c:=mix;
                mix:=b;b:=d;d:=mix;
              end;
            end;
            put_gfx_sprite_mask_diff(nchar+a,color,flipx,flipy,1,$3f,$3f,0,0);
            put_gfx_sprite_mask_diff(nchar+b,color,flipx,flipy,1,$3f,$3f,16,0);
            put_gfx_sprite_mask_diff(nchar+c,color,flipx,flipy,1,$3f,$3f,0,16);
            put_gfx_sprite_mask_diff(nchar+d,color,flipx,flipy,1,$3f,$3f,16,16);
            actualiza_gfx_sprite_size(sx,sy,3,32,32);
         end;
      end;
  end;
end;
actualiza_trozo(0,0,224,288,2,0,0,224,288,3);
actualiza_trozo_final(0,0,224,288,3);
end;

procedure eventos_gaplus;
begin
if event.arcade then begin
  //P1 & P2
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.up[1] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.right[1] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.down[1] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.left[1] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  //System
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.coin[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.coin[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
end;
end;

procedure gaplus_principal;
var
  f:byte;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
  for f:=0 to 223 do begin
    eventos_gaplus;
    if f=0 then begin
      if irq_enable then m6809_0.change_irq(ASSERT_LINE);
      if sub_irq_mask then m6809_1.change_irq(ASSERT_LINE);
      if sound_irq_mask then m6809_2.change_irq(ASSERT_LINE);
      if not(namco_5x_0.reset_status) then namco_5x_0.run;
      if not(namco_5x_1.reset_status) then namco_5x_1.run;
      update_video_gaplus;
    end;
    //Main CPU
    m6809_0.run(frame_main);
    frame_main:=frame_main+m6809_0.tframes-m6809_0.contador;
    //Sub CPU
    m6809_1.run(frame_sub);
    frame_sub:=frame_sub+m6809_1.tframes-m6809_1.contador;
    //Sound CPU
    m6809_2.run(frame_snd);
    frame_snd:=frame_snd+m6809_2.tframes-m6809_2.contador;
  end;
  video_sync;
end;
end;

function gaplus_getbyte(direccion:word):byte;
var
  mode:byte;
begin
case direccion of
  0..$1fff,$6000..$63ff,$a000..$ffff:gaplus_getbyte:=memoria[direccion];
  $6800..$680f:gaplus_getbyte:=namco_5x_0.read(direccion and $f);
  $6810..$681f:gaplus_getbyte:=namco_5x_1.read(direccion and $f);
  $6820..$682f:begin
                  mode:=custom_3[8];
                  case (direccion and $f) of
                    0:gaplus_getbyte:=marcade.dswc;
                    1:if mode=2 then gaplus_getbyte:=custom_3[1]
                        else gaplus_getbyte:=$f;
                    2:if mode=2 then gaplus_getbyte:=$f
                        else gaplus_getbyte:=$e;
                    3:if mode=2 then gaplus_getbyte:=custom_3[3]
                        else gaplus_getbyte:=1;
                    else gaplus_getbyte:=custom_3[direccion and $f];
                  end;
               end;
  $7800..$7fff:gaplus_getbyte:=0; //WD?
end;
end;

procedure gaplus_putbyte(direccion:word;valor:byte);
begin
case direccion of
  $0..$7ff:if memoria[direccion]<>valor then begin
              memoria[direccion]:=valor;
              gfx[0].buffer[direccion and $3ff]:=true;
           end;
  $800..$1fff,$6040..$63ff:memoria[direccion]:=valor;
  $6000..$603f:begin
                  namco_snd_0.regs[direccion and $3f]:=valor;
                  memoria[direccion]:=valor;
               end;
  $6800..$680f:namco_5x_0.write(direccion and $f,valor);
  $6810..$681f:namco_5x_1.write(direccion and $f,valor);
  $6820..$682f:begin
                  if ((direccion=$6829) and (valor>=$f)) then start_sample(0);
                  custom_3[direccion and $f]:=valor;
               end;
  $7000..$7fff:begin
                  irq_enable:=(direccion and $800)=0;
                  if not(irq_enable) then m6809_0.change_irq(CLEAR_LINE);
               end;
  $8000..$8fff:if (direccion and $800)=0 then begin
                  m6809_1.change_reset(CLEAR_LINE);
                  m6809_2.change_reset(CLEAR_LINE);
                  namco_snd_0.enabled:=true;
               end else begin
                  m6809_1.change_reset(ASSERT_LINE);
                  m6809_2.change_reset(ASSERT_LINE);
                  namco_snd_0.enabled:=false;
               end;
  $9000..$9fff:if (direccion and $800)=0 then begin
                  namco_5x_0.reset_internal(false);
                  namco_5x_1.reset_internal(false);
               end else begin
                  namco_5x_0.reset_internal(true);
                  namco_5x_1.reset_internal(true);
               end;
  $a000..$a7ff:starfield_control[direccion and 3]:=valor;
  $a800..$ffff:;
end;
end;

function gaplus_sub_getbyte(direccion:word):byte;
begin
case direccion of
  0..$1fff:gaplus_sub_getbyte:=memoria[direccion];
  $a000..$ffff:gaplus_sub_getbyte:=mem_misc[direccion];
end;
end;

procedure gaplus_sub_putbyte(direccion:word;valor:byte);
begin
case direccion of
  $0..$1fff:gaplus_putbyte(direccion,valor);
  $6000..$6fff:begin
                  sub_irq_mask:=(direccion and 1)<>0;
                  if not(sub_irq_mask) then m6809_1.change_irq(CLEAR_LINE);
               end;
  $a000..$ffff:;
end;
end;

function gaplus_sound_getbyte(direccion:word):byte;
begin
case direccion of
  0..$3ff:gaplus_sound_getbyte:=gaplus_getbyte($6000+direccion);
  $2000..$3fff:; //WD
  $e000..$ffff:gaplus_sound_getbyte:=mem_snd[direccion];
end;
end;

procedure gaplus_sound_putbyte(direccion:word;valor:byte);
begin
case direccion of
  $0..$3ff:gaplus_putbyte($6000+direccion,valor);
  $2000..$3fff:; //WD?
  $4000..$7fff:begin
                  sound_irq_mask:=(direccion and $2000)=0;
                  if not(sound_irq_mask) then m6809_2.change_irq(CLEAR_LINE);
               end;
  $e000..$ffff:;
end;
end;

procedure gaplus_sound_update;
begin
  samples_update;
  namco_snd_0.update;
end;

//Funciones IO Chips
function inport0_0:byte;
begin
  inport0_0:=marcade.in1 shr 4;  //coins
end;

function inport0_1:byte;
begin
  inport0_1:=marcade.in0 and $f; //p1
end;

function inport0_2:byte;
begin
  inport0_2:=marcade.in0 shr 4; //p2
end;

function inport0_3:byte;
begin
  inport0_3:=marcade.in1 and $f; //buttons
end;

function inport1_0:byte;
begin
  inport1_0:=marcade.dswa shr 4;  //dip_a_h
end;

function inport1_1:byte;
begin
  inport1_1:=marcade.dswa and $f; //dip_a_l
end;

function inport1_2:byte;
begin
  inport1_2:=marcade.dswb shr 4; //dip_b_h
end;

function inport1_3:byte;
begin
  inport1_3:=marcade.dswb and $f; //dip_b_l
end;

//Main
procedure reset_gaplus;
begin
 m6809_0.reset;
 m6809_1.reset;
 m6809_2.reset;
 frame_main:=m6809_0.tframes;
 frame_sub:=m6809_1.tframes;
 frame_snd:=m6809_2.tframes;
 namco_5x_0.reset;
 namco_5x_1.reset;
 namco_snd_0.reset;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 irq_enable:=false;
 sub_irq_mask:=false;
 sound_irq_mask:=false;
end;

function iniciar_gaplus:boolean;
var
  f:word;
  memoria_temp:array[0..$ffff] of byte;
  ctemp0,ctemp1,ctemp2,ctemp3:byte;
  colores:tpaleta;
const
    pc_x:array[0..7] of dword=(16*8, 16*8+1, 24*8, 24*8+1, 0, 1, 8*8, 8*8+1);
    ps_x:array[0..15] of dword=(0, 1, 2, 3, 8*8, 8*8+1, 8*8+2, 8*8+3,
		16*8+0, 16*8+1, 16*8+2, 16*8+3, 24*8+0, 24*8+1, 24*8+2, 24*8+3);
    ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
		32*8, 33*8, 34*8, 35*8, 36*8, 37*8, 38*8, 39*8);
procedure starfield_init;
var
  generator:integer;
  x:word;
  y,color,color_base,set_,bit1,bit2:byte;
begin
  generator:=0;
	set_:=0;
  total_stars:=0;
	starfield_framecount:=0;
	// precalculate the star background
	// this comes from the Galaxian hardware, Gaplus is probably different
	for y:=0 to 223 do begin
		for x:=288-(STARFIELD_CLIPPING_X*2)-1 downto 0 do begin
			generator:=generator shl 1;
      bit1:=(not(generator) shr 17) and 1;
			bit2:=(generator shr 5) and 1;
			if (bit1 xor bit2)<>0 then generator:=generator or 1;
			if (((not(generator) and $10000)<>0) and ((generator and $ff)=$ff)) then begin
				color:=(not(generator shr 8)) mod 7+1;
				color_base:=0;
				// A guess based on comparison with PCB video output
				case set_ of
				  0:color_base:=$50;
				  1:color_base:=$30;
				  2:color_base:=$10;
				end;
				if ((color<>0) and (total_stars<MAX_STARS)) then begin
					stars[total_stars].x:=x+STARFIELD_CLIPPING_X;
					stars[total_stars].y:=y;
					stars[total_stars].col:=color_base+color;
					stars[total_stars].set_:=set_;
          set_:=(set_+1) mod 3;
          total_stars:=total_stars+1;
        end;
      end;
    end;
  end;
end;

begin
iniciar_gaplus:=false;
llamadas_maquina.bucle_general:=gaplus_principal;
llamadas_maquina.reset:=reset_gaplus;
llamadas_maquina.fps_max:=60.60606060606060;
llamadas_maquina.scanlines:=224;
iniciar_audio(false);
screen_init(1,224,288,true);
screen_init(2,224,288,true);
screen_init(3,256,512,false,true);
iniciar_video(224,288);
//CPUs
m6809_0:=cpu_m6809.create(24576000 div 16,TCPU_MC6809E);
m6809_0.change_ram_calls(gaplus_getbyte,gaplus_putbyte);
m6809_1:=cpu_m6809.create(24576000 div 16,TCPU_MC6809E);
m6809_1.change_ram_calls(gaplus_sub_getbyte,gaplus_sub_putbyte);
m6809_2:=cpu_m6809.create(24576000 div 16,TCPU_MC6809E);
m6809_2.change_ram_calls(gaplus_sound_getbyte,gaplus_sound_putbyte);
m6809_2.init_sound(gaplus_sound_update);
namco_snd_0:=namco_snd_chip.create(8);
load_samples(gaplus_samples,0.25);
//cargar roms
if not(roms_load(@memoria,gaplus_cpu1)) then exit;
if not(roms_load(@mem_misc,gaplus_cpu2)) then exit;
if not(roms_load(@mem_snd,gaplus_sound)) then exit;
//IO
namco_5x_0:=namco_5x_chip.create(m6809_0.numero_cpu,NAMCO_56XX);
namco_5x_0.change_io(inport0_0,inport0_1,inport0_2,inport0_3,nil,nil);
namco_5x_1:=namco_5x_chip.create(m6809_0.numero_cpu,NAMCO_58XX);
namco_5x_1.change_io(inport1_0,inport1_1,inport1_2,inport1_3,nil,nil);
//chars
if not(roms_load(@memoria_temp,gaplus_char)) then exit;
for f:=0 to $1fff do memoria_temp[f+$2000]:=memoria_temp[f] shr 4;
init_gfx(0,8,8,$200);
gfx_set_desc_data(2,0,32*8,4,6);
convert_gfx(0,0,@memoria_temp,@pc_x,@ps_y,true,false);
//sprites
if not(roms_load(@memoria_temp,gaplus_sprites)) then exit;
for f:=$6000 to $7fff do memoria_temp[f+$2000]:=memoria_temp[f] shl 4;
fillchar(memoria_temp[$a000],$2000,0);
init_gfx(1,16,16,$180);
gfx_set_desc_data(3,0,64*8,$180*64*8,0,4);
convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,true,false);
//Paleta
if not(roms_load(@memoria_temp,gaplus_prom)) then exit;
copymemory(namco_snd_0.get_wave_dir,@memoria_temp[$800],$100);
// tiles/sprites color table
for f:=0 to $ff do begin
  ctemp0:=(memoria_temp[f] shr 0) and 1;
  ctemp1:=(memoria_temp[f] shr 1) and 1;
  ctemp2:=(memoria_temp[f] shr 2) and 1;
  ctemp3:=(memoria_temp[f] shr 3) and 1;
  colores[f].r:=$0e*ctemp0+$1f*ctemp1+$43*ctemp2+$8f*ctemp3;
  ctemp0:=(memoria_temp[f+$100] shr 0) and 1;
  ctemp1:=(memoria_temp[f+$100] shr 1) and 1;
  ctemp2:=(memoria_temp[f+$100] shr 2) and 1;
  ctemp3:=(memoria_temp[f+$100] shr 3) and 1;
  colores[f].g:=$0e*ctemp0+$1f*ctemp1+$43*ctemp2+$8f*ctemp3;
  ctemp0:=(memoria_temp[f+$200] shr 0) and 1;
  ctemp1:=(memoria_temp[f+$200] shr 1) and 1;
  ctemp2:=(memoria_temp[f+$200] shr 2) and 1;
  ctemp3:=(memoria_temp[f+$200] shr 3) and 1;
  colores[f].b:=$0e*ctemp0+$1f*ctemp1+$43*ctemp2+$8f*ctemp3;
end;
set_pal(colores,$100);
init_dips(1,gaplus_dip_a,$ff);
init_dips(2,gaplus_dip_b,$ff);
init_dips(3,gaplus_dip_c,$f);
//CLUT chars
for f:=0 to $ff do gfx[0].colores[f]:=$f0+(memoria_temp[$300+f] and $0f);
//CLUT sprites
for f:=0 to $1ff do gfx[1].colores[f]:=(memoria_temp[$400+f] and $0f)+((memoria_temp[$600+f] and $0f) shl 4);
starfield_init;
//final
iniciar_gaplus:=true;
end;

end.
