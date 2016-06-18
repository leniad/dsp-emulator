unit galaxian_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,ay_8910,controls_engine,gfx_engine,timer_engine,samples,
     rom_engine,file_engine,pal_engine,sound_engine,ppi8255,misc_functions,
     konami_snd;

procedure cargar_hgalaxian;

implementation

type
  tstars=record
          x,y,color:word;
  end;
const
        //Galaxian
        galaxian_rom:array[0..5] of tipo_roms=(
        (n:'galmidw.u';l:$800;p:0;crc:$745e2d61),(n:'galmidw.v';l:$800;p:$800;crc:$9c999a40),
        (n:'galmidw.w';l:$800;p:$1000;crc:$b5894925),(n:'galmidw.y';l:$800;p:$1800;crc:$6b3ca10b),
        (n:'7l';l:$800;p:$2000;crc:$1b933207),());
        galaxian_char:array[0..2] of tipo_roms=(
        (n:'1h.bin';l:$800;p:0;crc:$39fb43a4),(n:'1k.bin';l:$800;p:$800;crc:$7e3f56a2),());
        galaxian_pal:tipo_roms=(n:'6l.bpr';l:$20;p:0;crc:$c3ac9467);
        galaxian_num_samples=9;
        galaxian_samples:array[0..(galaxian_num_samples-1)] of tipo_nombre_samples=(
        (nombre:'fire.wav'),(nombre:'death.wav'),(nombre:'back1.wav'),(nombre:'back2.wav'),(nombre:'back3.wav'),
        (nombre:'kill.wav';restart:true),(nombre:'coin.wav'),(nombre:'music.wav'),(nombre:'extra.wav'));
        //Jump Bug
        jumpbug_rom:array[0..7] of tipo_roms=(
        (n:'jb1';l:$1000;p:0;crc:$415aa1b7),(n:'jb2';l:$1000;p:$1000;crc:$b1c27510),
        (n:'jb3';l:$1000;p:$2000;crc:$97c24be2),(n:'jb4';l:$1000;p:$3000;crc:$66751d12),
        (n:'jb5';l:$1000;p:$8000;crc:$e2d66faf),(n:'jb6';l:$1000;p:$9000;crc:$49e0bdfd),
        (n:'jb7';l:$800;p:$a000;crc:$83d71302),());
        jumpbug_char:array[0..6] of tipo_roms=(
        (n:'jbl';l:$800;p:0;crc:$9a091b0a),(n:'jbm';l:$800;p:$800;crc:$8a0fc082),
        (n:'jbn';l:$800;p:$1000;crc:$155186e0),(n:'jbi';l:$800;p:$1800;crc:$7749b111),
        (n:'jbj';l:$800;p:$2000;crc:$06e8d7df),(n:'jbk';l:$800;p:$2800;crc:$b8dbddf3),());
        jumpbug_pal:tipo_roms=(n:'l06_prom.bin';l:$20;p:0;crc:$6a0c7d87);
        //Moon Cresta
        mooncrst_rom:array[0..8] of tipo_roms=(
        (n:'mc1';l:$800;p:0;crc:$7d954a7a),(n:'mc2';l:$800;p:$800;crc:$44bb7cfa),
        (n:'mc3';l:$800;p:$1000;crc:$9c412104),(n:'mc4';l:$800;p:$1800;crc:$7e9b1ab5),
        (n:'mc5.7r';l:$800;p:$2000;crc:$16c759af),(n:'mc6.8d';l:$800;p:$2800;crc:$69bcafdb),
        (n:'mc7.8e';l:$800;p:$3000;crc:$b50dbc46),(n:'mc8';l:$800;p:$3800;crc:$18ca312b),());
        mooncrst_char:array[0..4] of tipo_roms=(
        (n:'mcs_b';l:$800;p:0;crc:$fb0f1f81),(n:'mcs_d';l:$800;p:$800;crc:$13932a15),
        (n:'mcs_a';l:$800;p:$1000;crc:$631ebb5a),(n:'mcs_c';l:$800;p:$1800;crc:$24cfd145),());
        mooncrst_pal:tipo_roms=(n:'l06_prom.bin';l:$20;p:0;crc:$6a0c7d87);
        mooncrst_samples:array[0..4] of tipo_nombre_samples=(
        (nombre:'fire.wav'),(nombre:'death.wav'),(nombre:'back1.wav'),(nombre:'back2.wav'),(nombre:'back3.wav'));
        //Scramble
        scramble_rom:array[0..8] of tipo_roms=(
        (n:'s1.2d';l:$800;p:0;crc:$ea35ccaa),(n:'s2.2e';l:$800;p:$800;crc:$e7bba1b3),
        (n:'s3.2f';l:$800;p:$1000;crc:$12d7fc3e),(n:'s4.2h';l:$800;p:$1800;crc:$b59360eb),
        (n:'s5.2j';l:$800;p:$2000;crc:$4919a91c),(n:'s6.2l';l:$800;p:$2800;crc:$26a4547b),
        (n:'s7.2m';l:$800;p:$3000;crc:$0bb49470),(n:'s8.2p';l:$800;p:$3800;crc:$6a5740e5),());
        scramble_char:array[0..2] of tipo_roms=(
        (n:'c2.5f';l:$800;p:0;crc:$4708845b),(n:'c1.5h';l:$800;p:$800;crc:$11fd2887),());
        scramble_sound:array[0..3] of tipo_roms=(
        (n:'ot1.5c';l:$800;p:0;crc:$bcd297f0),(n:'ot2.5d';l:$800;p:$800;crc:$de7912da),
        (n:'ot3.5e';l:$800;p:$1000;crc:$ba2fa933),());
        scramble_pal:tipo_roms=(n:'c01s.6e';l:$20;p:0;crc:$4e3caeab);
        //Super Cobra
        scobra_rom:array[0..6] of tipo_roms=(
        (n:'epr1265.2c';l:$1000;p:0;crc:$a0744b3f),(n:'2e';l:$1000;p:$1000;crc:$8e7245cd),
        (n:'epr1267.2f';l:$1000;p:$2000;crc:$47a4e6fb),(n:'2h';l:$1000;p:$3000;crc:$7244f21c),
        (n:'epr1269.2j';l:$1000;p:$4000;crc:$e1f8a801),(n:'2l';l:$1000;p:$5000;crc:$d52affde),());
        scobra_sound:array[0..3] of tipo_roms=(
        (n:'5c';l:$800;p:0;crc:$d4346959),(n:'5d';l:$800;p:$800;crc:$cc025d95),
        (n:'5e';l:$800;p:$1000;crc:$1628c53f),());
        scobra_char:array[0..2] of tipo_roms=(
        (n:'epr1274.5h';l:$800;p:0;crc:$64d113b4),(n:'epr1273.5f';l:$800;p:$800;crc:$a96316d3),());
        scobra_pal:tipo_roms=(n:'82s123.6e';l:$20;p:0;crc:$9b87f90d);
        //Frogger
        frogger_rom:array[0..3] of tipo_roms=(
        (n:'frogger.26';l:$1000;p:0;crc:$597696d6),(n:'frogger.27';l:$1000;p:$1000;crc:$b6e6fcc3),
        (n:'frsm3.7';l:$1000;p:$2000;crc:$aca22ae0),());
        frogger_char:array[0..2] of tipo_roms=(
        (n:'frogger.607';l:$800;p:0;crc:$05f7d883),(n:'frogger.606';l:$800;p:$800;crc:$f524ee30),());
        frogger_pal:tipo_roms=(n:'pr-91.6l';l:32;p:0;crc:$413703bf);
        frogger_sound:array[0..3] of tipo_roms=(
        (n:'frogger.608';l:$800;p:0;crc:$e8ab0256),(n:'frogger.609';l:$800;p:$800;crc:$7380a48f),
        (n:'frogger.610';l:$800;p:$1000;crc:$31d7eb27),());
        //Amidar
        amidar_rom:array[0..4] of tipo_roms=(
        (n:'amidar.2c';l:$1000;p:0;crc:$c294bf27),(n:'amidar.2e';l:$1000;p:$1000;crc:$e6e96826),
        (n:'amidar.2f';l:$1000;p:$2000;crc:$3656be6f),(n:'amidar.2h';l:$1000;p:$3000;crc:$1be170bd),());
        amidar_char:array[0..2] of tipo_roms=(
        (n:'amidar.5f';l:$800;p:0;crc:$5e51e84d),(n:'amidar.5h';l:$800;p:$800;crc:$2f7f1c30),());
        amidar_pal:tipo_roms=(n:'amidar.clr';l:32;p:0;crc:$f940dcc3);
        amidar_sound:array[0..2] of tipo_roms=(
        (n:'amidar.5c';l:$1000;p:0;crc:$c4b66ae4),(n:'amidar.5d';l:$1000;p:$1000;crc:$806785af),());
        //Stars
        star_count=252;
var
  //variables de funciones especificas
  eventos_hardware_galaxian:procedure;
  calc_nchar:function(direccion:word):word;
  calc_sprite:function(direccion:byte):word;
  draw_stars:procedure;
  galaxian_update_video:procedure;
  sound1_pos,sound2_pos,sound3_pos,sound4_pos,sound_pos:byte;
  sound_data:array[0..3] of byte;
  //Variables globales
  haz_nmi,stars_enable:boolean;
  stars_scrollpos:dword;
  stars_blinking,port_b_latch,local_frame:byte;
  stars:array[0..star_count-1] of tstars;
  videoram_mem:array[0..$3ff] of byte;
  sprite_mem,disparo_mem:array[0..$1f] of byte;
  atributos_mem:array[0..$3f] of byte;
  gfx_bank:array[0..4] of byte;
  //scramble
  scramble_background:boolean;
  scramble_prot_state:integer;
  scramble_prot:byte;
  //frogger
  timer_hs_frogger:byte;

//Galaxian
procedure eventos_galaxian;
begin
if event.arcade then begin
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 or $4) else marcade.in0:=(marcade.in0 and $fb);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 or $8) else marcade.in0:=(marcade.in0 and $f7);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 or $10) else marcade.in0:=(marcade.in0 and $ef);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 or $1) else marcade.in1:=(marcade.in1 and $fe);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 or $1) else marcade.in0:=(marcade.in0 and $fe);
end;
end;

function galaxian_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$3fff:galaxian_getbyte:=memoria[direccion];
  $4000..$47ff:galaxian_getbyte:=memoria[$4000+(direccion and $3ff)];
  $5000..$57ff:galaxian_getbyte:=videoram_mem[direccion and $3ff];
  $5800..$5fff:case (direccion and $ff) of
                  0..$3f:galaxian_getbyte:=atributos_mem[direccion and $3f];
                  $40..$5f:galaxian_getbyte:=sprite_mem[direccion and $1f];
                  $60..$7f:galaxian_getbyte:=disparo_mem[direccion and $1f];
                  else galaxian_getbyte:=memoria[$5800+(direccion and $ff)];
               end;
  $6000..$67ff:galaxian_getbyte:=marcade.in0;
  $6800..$6fff:galaxian_getbyte:=marcade.in1;
  $7000..$77ff:galaxian_getbyte:=marcade.in2;
  else galaxian_getbyte:=$ff;
end;
end;

procedure galaxian_putbyte(direccion:word;valor:byte);
var
  f,dir:byte;
begin
if direccion<$4000 then exit;
case direccion of
  $4000..$47ff:memoria[$4000+(direccion and $3ff)]:=valor;
  $5000..$57ff:if videoram_mem[direccion and $3ff]<>valor then begin
                  gfx[0].buffer[direccion and $3ff]:=true;
                  videoram_mem[direccion and $3ff]:=valor;
               end;
  $5800..$5fff:case (direccion and $ff) of
                  0..$3f:if atributos_mem[direccion and $3f]<>valor then begin
                            atributos_mem[direccion and $3f]:=valor;
                            dir:=((direccion and $3F) shr 1);
                            for f:=0 to $1F do gfx[0].buffer[dir+(f shl 5)]:=true;
                         end;
                  $40..$5f:sprite_mem[direccion and $1f]:=valor;
                  $60..$7f:disparo_mem[direccion and $1f]:=valor;
                    else memoria[$5800+(direccion and $ff)]:=valor;
               end;
  $6800..$6fff:case (direccion and $7) of
                  0:if (valor<>0) then start_sample(2);
                  1:if (valor<>0) then start_sample(3);
                  2:if (valor<>0) then start_sample(4);
                  3:if (valor<>0) then start_sample(1);
                  5:if (valor<>0) then start_sample(0);
               end;
  $7000..$77ff:case (direccion and $7) of
                  $1:haz_nmi:=((valor and 1)<>0);
                  $4:begin
                       stars_enable:=(valor and $1)<>0;
                       if not(stars_enable) then stars_scrollpos:=0;
                    end;
               end;
  $7800:begin //case valor of
            sound_data[sound_pos]:=valor;
            case valor of
              0:sound4_pos:=sound_pos;
              4:sound2_pos:=sound_pos;
              142:sound1_pos:=sound_pos;
              208:sound3_pos:=sound_pos;
              255:exit;
            end;
            sound_pos:=(sound_pos+1) and 3;
            if ((sound_data[sound1_pos]=142) and (sound_data[(sound1_pos+1) and 3]=128) and (sound_data[(sound1_pos+2) and 3]=112) and (sound_data[(sound1_pos+3) and 3]=104)) then start_sample(5);
            if ((sound_data[sound2_pos]=4) and (sound_data[(sound2_pos+1) and 3]=8) and (sound_data[(sound2_pos+2) and 3]=12) and (sound_data[(sound2_pos+3) and 3]=16)) then start_sample(6);
            if ((sound_data[sound3_pos]=208) and (sound_data[(sound3_pos+1) and 3]=205) and (sound_data[(sound3_pos+2) and 3]=199) and (sound_data[(sound3_pos+3) and 3]=192)) then start_sample(7);
            if ((sound_data[sound4_pos]=0) and (sound_data[(sound4_pos+1) and 3]=28) and (sound_data[(sound4_pos+2) and 3]=64) and (sound_data[(sound4_pos+3) and 3]=85)) then start_sample(8);
            //principal1.statusbar1.panels[2].text:=inttostr(valor);
        end;
end;
end;

function galaxian_calc_nchar(direccion:word):word;
begin
  galaxian_calc_nchar:=videoram_mem[direccion and $3ff];
end;

function galaxian_calc_sprite(direccion:byte):word;
begin
  galaxian_calc_sprite:=sprite_mem[$1+(direccion*4)] and $3f;
end;

procedure stars_galaxian;
var
  f:byte;
  x,y,color:word;
begin
for f:=0 to star_count-1 do begin
		x:=(stars[f].x+stars_scrollpos) and $1ff;
		y:=(stars[f].y+((stars_scrollpos+stars[f].x) shr 9)) and $ff;
		if ((y and $01) xor ((x shr 3) and $01))<>0 then begin
      color:=paleta[stars[f].color];
      putpixel(y+ADD_SPRITE,x,1,@color,1);
		end;
 end;
end;

procedure galaxian_despues_instruccion;
begin
  samples_update;
end;

//Jump Bug
procedure eventos_jumpbug;
begin
if event.arcade then begin
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 or $4) else marcade.in0:=(marcade.in0 and $fb);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 or $8) else marcade.in0:=(marcade.in0 and $f7);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 or $40) else marcade.in0:=(marcade.in0 and $bf);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 or $80) else marcade.in0:=(marcade.in0 and $7f);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 or $10) else marcade.in0:=(marcade.in0 and $ef);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 or $1) else marcade.in1:=(marcade.in1 and $fe);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 or $1) else marcade.in0:=(marcade.in0 and $fe);
end;
end;

function jumpbug_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$47ff,$8000..$afff:jumpbug_getbyte:=memoria[direccion];
  $4800..$4fff:jumpbug_getbyte:=videoram_mem[direccion and $3ff];
  $5000..$57ff:case (direccion and $ff) of
                  $0..$3f:jumpbug_getbyte:=atributos_mem[direccion and $3f];
                  $40..$5f:jumpbug_getbyte:=sprite_mem[direccion and $1f];
                  $60..$7f:jumpbug_getbyte:=disparo_mem[direccion and $1f];
                    else jumpbug_getbyte:=memoria[$5000+(direccion and $ff)];
               end;
  $6000..$67ff:jumpbug_getbyte:=marcade.in0;
  $6800..$6fff:jumpbug_getbyte:=marcade.in1;
  $7000..$77ff:jumpbug_getbyte:=marcade.in2;
  $b000..$bfff:case (direccion and $fff) of  //proteccion
                  $114:jumpbug_getbyte:=$4f;
	                $118:jumpbug_getbyte:=$d3;
	                $214:jumpbug_getbyte:=$cf;
	                $235:jumpbug_getbyte:=$02;
                  $311:jumpbug_getbyte:=$ff;
	                else jumpbug_getbyte:=$00;
               end;
    else jumpbug_getbyte:=$ff;
end;
end;

procedure jumpbug_putbyte(direccion:word;valor:byte);
var
  f,dir:byte;
begin
case direccion of
  0..$3fff,$8000..$afff:exit;  //rom
  $4000..$47ff:memoria[direccion]:=valor;
  $4800..$4fff:if videoram_mem[direccion and $3ff]<>valor then begin
                  gfx[0].buffer[direccion and $3ff]:=true;
                  videoram_mem[direccion and $3ff]:=valor;
               end;
  $5000..$57ff:case (direccion and $ff) of
                 $0..$3f:if atributos_mem[direccion and $3f]<>valor then begin
                          atributos_mem[direccion and $3f]:=valor;
                          dir:=((direccion and $3F) shr 1);
                          for f:=0 to $1F do gfx[0].buffer[dir+(f shl 5)]:=true;
                        end;
                 $40..$5f:sprite_mem[direccion and $1f]:=valor;
                 $60..$7f:disparo_mem[direccion and $1f]:=valor;
                  else memoria[$5000+(direccion and $ff)]:=valor;
               end;
  $5800..$58ff:ay8910_0.Write(valor);
  $5900..$59ff:ay8910_0.Control(valor);
  $6000..$67ff:case direccion and $7 of
                $2..$6:if gfx_bank[(direccion and $7)-2]<>valor then begin
                        gfx_bank[(direccion and $7)-2]:=valor;
                        fillchar(gfx[0].buffer[0],$400,1);
                       end;
               end;
  $7000..$77ff:case direccion and $7 of
                $1:haz_nmi:=(valor and 1)<>0;
                $4:begin
                     stars_enable:=(valor and $1)<>0;
                     if not(stars_enable) then stars_scrollpos:=0;
                  end;
                end;
end;
end;

function jumpbug_calc_nchar(direccion:word):word;
var
  charcode:word;
begin
  charcode:=videoram_mem[direccion and $3ff];
  if (((charcode and $c0)=$80) and ((gfx_bank[2] and 1)<>0)) then begin
		charcode:=charcode+(128 + ((gfx_bank[0] and 1) shl 6) +
				           ((gfx_bank[1] and 1) shl 7) +
						   ((not(gfx_bank[4]) and 1) shl 8));
	end;
  jumpbug_calc_nchar:=charcode;
end;

function jumpbug_calc_sprite(direccion:byte):word;
var
  spritecode:word;
begin
  spritecode:=sprite_mem[$1+(direccion*4)] and $3f;
  if (((spritecode and $30)=$20) and ((gfx_bank[2] and 1)<>0)) then begin
		spritecode:=spritecode+(32 + ((gfx_bank[0] and 1) shl 4) +
		                    ((gfx_bank[1] and 1) shl 5) +
		                    ((not(gfx_bank[4]) and 1) shl 6));
	end;
  jumpbug_calc_sprite:=spritecode;
end;

procedure jumpbug_blinking;
begin
  stars_blinking:=stars_blinking+1;
end;

procedure jumpbug_despues_instruccion;
begin
  ay8910_0.update;
end;

procedure stars_jumpbug;
var
  f:byte;
  x,y,color:word;
begin
for f:=0 to STAR_COUNT-1 do begin
		x:=stars[f].x;
		y:=stars[f].y;
		// determine when to skip plotting */
		if ((y and $01) xor ((x shr 3) and $01))<>0 then begin
			case (stars_blinking and $03) of
  			0:if (stars[f].color and $01)=0 then continue;
  			1:if (stars[f].color and $04)=0 then continue;
  			2:if (stars[f].y and $02)=0 then continue;
			end;
			// no stars in the status area */
			if ((x>=240) and (main_vars.tipo_maquina=48)) then continue;
      color:=paleta[stars[f].color];
      putpixel(y+ADD_SPRITE,x,1,@color,1);
		end;
end;
end;

//Moon Cresta
function mooncrst_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$3fff:mooncrst_getbyte:=memoria[direccion];
  $8000..$87ff:mooncrst_getbyte:=memoria[$8000+(direccion and $3ff)];
  $9000..$97ff:mooncrst_getbyte:=videoram_mem[direccion and $3ff];
  $9800..$9fff:case (direccion and $ff) of
                  $0..$3f:mooncrst_getbyte:=atributos_mem[direccion and $3f];
                  $40..$5f:mooncrst_getbyte:=sprite_mem[direccion and $1f];
                  $60..$7f:mooncrst_getbyte:=disparo_mem[direccion and $1f];
                   else mooncrst_getbyte:=memoria[$9800+(direccion and $ff)];
               end;
  $a000..$a7ff:mooncrst_getbyte:=marcade.in0;
  $a800..$afff:mooncrst_getbyte:=marcade.in1;
  $b000..$b7ff:mooncrst_getbyte:=marcade.in2;
    else mooncrst_getbyte:=$ff;
end;
end;

procedure mooncrst_putbyte(direccion:word;valor:byte);
var
  f,dir:byte;
begin
if direccion<$4000 then exit;
case direccion of
  $8000..$87ff:memoria[$8000+(direccion and $3ff)]:=valor;
  $9000..$97ff:if videoram_mem[direccion and $3ff]<>valor then begin
                  gfx[0].buffer[direccion and $3ff]:=true;
                  videoram_mem[direccion and $3ff]:=valor;
               end;
  $9800..$9fff:case (direccion and $ff) of
                  $0..$3f:if atributos_mem[direccion and $3f]<>valor then begin
                              atributos_mem[direccion and $3f]:=valor;
                              dir:=((direccion and $3F) shr 1);
                              for f:=0 to $1F do gfx[0].buffer[dir+(f shl 5)]:=true;
                           end;
                  $40..$5f:sprite_mem[direccion and $1f]:=valor;
                  $60..$7f:disparo_mem[direccion and $1f]:=valor;
                   else memoria[$9800+(direccion and $ff)]:=valor;
               end;
  $a000..$a7ff:case (direccion and $7) of
                  $0..$2:if gfx_bank[direccion-$a000]<>valor then begin
                            gfx_bank[direccion-$a000]:=valor;
                            fillchar(gfx[0].buffer[0],$400,1);
                         end;
               end;
  $a800..$afff:case (direccion and $7) of
                  $0:if (valor<>0) then start_sample(2);
                  $1:if (valor<>0) then start_sample(3);
                  $2:if (valor<>0) then start_sample(4);
                  $3:if (valor<>0) then start_sample(1);
                  $5:if (valor<>0) then start_sample(0);
                end;
  $b000..$b7ff:case (direccion and $7) of
                  $0:haz_nmi:=(valor and 1)<>0;
                  $4:begin
                       stars_enable:=(valor and $1)<>0;
                       if not(stars_enable) then stars_scrollpos:=0;
                     end;
               end;
end;
end;

function mooncrst_calc_nchar(direccion:word):word;
var
  charcode:word;
begin
  charcode:=videoram_mem[direccion and $3ff];
  if ((gfx_bank[2]<>0) and ((charcode and $c0)=$80)) then
		charcode:=(charcode and $3f) or (gfx_bank[0] shl 6) or (gfx_bank[1] shl 7) or $0100;
  mooncrst_calc_nchar:=charcode;
end;

function mooncrst_calc_sprite(direccion:byte):word;
var
  spritecode:word;
begin
  spritecode:=sprite_mem[$1+(direccion*4)] and $3f;
  if ((gfx_bank[2]<>0) and ((spritecode and $30)=$20)) then
		spritecode:=(spritecode and $f) or (gfx_bank[0] shl 4) or (gfx_bank[1] shl 5) or $40;
  mooncrst_calc_sprite:=spritecode;
end;

//Scramble
procedure eventos_scramble;
begin
if event.arcade then begin
  //marcade.in0
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $7F) else marcade.in0:=(marcade.in0 or $80);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $bF) else marcade.in0:=(marcade.in0 or $40);
  //marcade.in1
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
  //marcade.in2
  if arcade_input.up[0] then marcade.in2:=(marcade.in2 and $EF) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.down[0] then marcade.in2:=(marcade.in2 and $BF) else marcade.in2:=(marcade.in2 or $40);
end;
end;

function scramble_ppi8255_r(direccion:word):byte;
var
  res:byte;
begin
	res:=$ff;
	if (direccion and $0100)<>0 then res:=res and pia8255_0.read(direccion and 3);
	if (direccion and $0200)<>0 then res:=res and pia8255_1.read(direccion and 3);
	scramble_ppi8255_r:=res;
end;

function scramble_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$47ff:scramble_getbyte:=memoria[direccion];
  $4800..$4fff:scramble_getbyte:=videoram_mem[direccion and $3ff];
  $5000..$5fff:case (direccion and $7f) of
                0..$3f:scramble_getbyte:=atributos_mem[direccion and $3f];
                $40..$5f:scramble_getbyte:=sprite_mem[direccion and $1f];
                $60..$7f:scramble_getbyte:=disparo_mem[direccion and $1f];
                  else scramble_getbyte:=memoria[$5000+(direccion and $ff)];
               end;
  $8000..$ffff:scramble_getbyte:=scramble_ppi8255_r(direccion);
    else scramble_getbyte:=$ff;
end;
end;

procedure scramble_ppi8255_w(direccion:word;valor:byte);
begin
  if (direccion and $0100)<>0 then pia8255_0.write(direccion and 3,valor);
	if (direccion and $0200)<>0 then pia8255_1.write(direccion and 3,valor);
end;

procedure scramble_putbyte(direccion:word;valor:byte);
var
  f,dir:byte;
begin
if direccion<$4000 then exit;
memoria[direccion]:=valor;
case direccion of
  $4800..$4fff:if videoram_mem[direccion and $3ff]<>valor then begin
                  gfx[0].buffer[direccion and $3ff]:=true;
                  videoram_mem[direccion and $3ff]:=valor;
               end;
  $5000..$5fff:case (direccion and $ff) of
                    $0..$3f:if atributos_mem[direccion and $3f]<>valor then begin
                              atributos_mem[direccion and $3f]:=valor;
                              dir:=((direccion and $3f) shr 1);
                              for f:=0 to $1f do gfx[0].buffer[dir+(f shl 5)]:=true;
                            end;
                    $40..$5f:sprite_mem[direccion and $1f]:=valor;
                    $60..$7f:disparo_mem[direccion and $1f]:=valor;
                      else memoria[$5000+(direccion and $ff)]:=valor;
               end;
  $6800..$6fff:case (direccion and $7) of
                  1:haz_nmi:=(valor and 1)<>0;
                  3:scramble_background:=((valor and 1)<>0);
                  4:begin
                     stars_enable:=(valor and $1)<>0;
                     if not(stars_enable) then stars_scrollpos:=0;
                  end;
               end;
  $8000..$ffff:scramble_ppi8255_w(direccion,valor);
end;
end;

//8255 scramble
function scramble_port_1_c_read:byte;
begin
  scramble_port_1_c_read:=scramble_prot;
end;

procedure scramble_port_1_a_write(valor:byte);
begin
  konamisnd_0.sound_latch:=valor;
end;

procedure scramble_port_1_b_write(valor:byte);
var
  old:byte;
begin
  old:=port_b_latch;
  port_b_latch:=valor;
  if (((old and $08)<>0) and ((not(valor and $08))<>0)) then konamisnd_0.pedir_irq:=HOLD_LINE;
  //device->machine().sound().system_mute(data & 0x10);
end;

procedure scramble_port_1_c_write(valor:byte);
begin
  scramble_prot_state:=(scramble_prot_state shl 4) or (valor and $0f);
	case (scramble_prot_state and $fff) of
		// scramble */
		$f09:scramble_prot:=$ff;
		$a49:scramble_prot:=$bf;
		$319:scramble_prot:=$4f;
		$5c9:scramble_prot:=$6f;
	end;
end;

function scobra_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$7fff:scobra_getbyte:=memoria[direccion];
  $8000..$87ff,$c000..$c7ff:scobra_getbyte:=memoria[$8000+(direccion and $7ff)];
  $8800..$8bff,$c800..$cbff:scobra_getbyte:=videoram_mem[direccion and $3ff];
  $9000..$97ff,$d000..$d7ff:case (direccion and $ff) of
                0..$3f:scobra_getbyte:=atributos_mem[direccion and $3f];
                $40..$5f:scobra_getbyte:=sprite_mem[direccion and $1f];
                $60..$7f:scobra_getbyte:=disparo_mem[direccion and $1f];
                  else scobra_getbyte:=memoria[$9000+(direccion and $ff)];
               end;
  $9800..$9fff,$d800..$dfff:scobra_getbyte:=pia8255_0.read(direccion and 3);
  $a000..$a7ff,$e000..$e7ff:scobra_getbyte:=pia8255_1.read(direccion and 3);
    else scobra_getbyte:=$ff;
end;
end;

procedure scobra_putbyte(direccion:word;valor:byte);
var
  f,dir:byte;
begin
if direccion<$8000 then exit;
memoria[direccion]:=valor;
case direccion of
  $8000..$87ff,$c000..$c7ff:memoria[$8000+(direccion and $7ff)]:=valor;
  $8800..$8bff,$c800..$cbff:if videoram_mem[direccion and $3ff]<>valor then begin
                  gfx[0].buffer[direccion and $3ff]:=true;
                  videoram_mem[direccion and $3ff]:=valor;
               end;
  $9000..$97ff,$d000..$d7ff:case (direccion and $ff) of
                    $0..$3f:if atributos_mem[direccion and $3f]<>valor then begin
                              atributos_mem[direccion and $3f]:=valor;
                              dir:=((direccion and $3f) shr 1);
                              for f:=0 to $1f do gfx[0].buffer[dir+(f shl 5)]:=true;
                            end;
                    $40..$5f:sprite_mem[direccion and $1f]:=valor;
                    $60..$7f:disparo_mem[direccion and $1f]:=valor;
                      else memoria[$9000+(direccion and $ff)]:=valor;
               end;
  $9800..$9fff,$d800..$dfff:pia8255_0.write(direccion and 3,valor);
  $a000..$a7ff,$e000..$e7ff:pia8255_1.write(direccion and 3,valor);
  $a800..$afff,$e800..$efff:case (direccion and $7) of
                  1:haz_nmi:=(valor and 1)<>0;
                  3:;//scramble_background:=((valor and 1)<>0);
                  4:begin
                     stars_enable:=(valor and $1)<>0;
                     if not(stars_enable) then stars_scrollpos:=0;
                  end;
               end;
end;
end;

//Frogger
procedure eventos_frogger;
begin
if event.arcade then begin
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $7F) else marcade.in0:=(marcade.in0 or $80);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $bF) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.start[0] then marcade.in1:=marcade.in1 and $7F else marcade.in1:=marcade.in1 or $80;
  if arcade_input.up[0] then marcade.in2:=marcade.in2 and $EF else marcade.in2:=marcade.in2 or $10;
  if arcade_input.down[0] then marcade.in2:=marcade.in2 and $BF else marcade.in2:=marcade.in2 or $40;
  if arcade_input.left[0] then marcade.in0:=marcade.in0 and $DF else marcade.in0:=marcade.in0 or $20;
  if arcade_input.right[0] then marcade.in0:=marcade.in0 and $EF else marcade.in0:=marcade.in0 or $10;
end;
end;

function frogger_ppi8255_r(direccion:word):byte;
var
  res:byte;
begin
	// the decoding here is very simplistic, and you can address both simultaneously
	res:=$ff;
	if (direccion and $1000)<>0 then res:=res and pia8255_1.read((direccion shr 1) and 3);
	if (direccion and $2000)<>0 then res:=res and pia8255_0.read((direccion shr 1) and 3);
	frogger_ppi8255_r:=res;
end;

function frogger_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$3fff,$8000..$87ff:frogger_getbyte:=memoria[direccion];
  $a800..$afff:frogger_getbyte:=videoram_mem[direccion and $3ff];
  $b000..$b7ff:case (direccion and $ff) of
                0..$3f:frogger_getbyte:=atributos_mem[direccion and $3f];
                $40..$5f:frogger_getbyte:=sprite_mem[direccion and $1f];
                $60..$7f:frogger_getbyte:=disparo_mem[direccion and $1f];
                  else frogger_getbyte:=memoria[$b000+(direccion and $ff)];
               end;
  $c000..$ffff:frogger_getbyte:=frogger_ppi8255_r(direccion);
    else frogger_getbyte:=$ff;
end;
end;

procedure frogger_ppi8255_w(direccion:word;valor:byte);
begin
  if (direccion and $1000)<>0 then pia8255_1.write((direccion shr 1) and 3,valor);
	if (direccion and $2000)<>0 then pia8255_0.write((direccion shr 1) and 3,valor);
end;

procedure frogger_putbyte(direccion:word;valor:byte);
var
  dir,f:byte;
begin
if direccion<$4000 then exit;
memoria[direccion]:=valor;
case direccion of
        $a800..$afff:if videoram_mem[direccion and $3ff]<>valor then begin
                  gfx[0].buffer[direccion and $3ff]:=true;
                  videoram_mem[direccion and $3ff]:=valor;
               end;
        $b000..$b7ff:case (direccion and $ff) of
                    $0..$3f:if atributos_mem[direccion and $3f]<>valor then begin
                              atributos_mem[direccion and $3f]:=valor;
                              dir:=((direccion and $3f) shr 1);
                              for f:=0 to $1f do gfx[0].buffer[dir+(f shl 5)]:=true;
                            end;
                    $40..$5f:sprite_mem[direccion and $1f]:=valor;
                    $60..$7f:disparo_mem[direccion and $1f]:=valor;
                      else memoria[$b000+(direccion and $ff)]:=valor;
               end;
        $b800..$bfff:case (direccion and $1f) of
                        8:haz_nmi:=(valor and 1)<>0;
                     end;
        $c000..$ffff:frogger_ppi8255_w(direccion,valor);
end;
end;

procedure frogger_port_1_a_write(valor:byte);
begin
  konamisnd_0.sound_latch:=valor;
end;

procedure frogger_port_1_b_write(valor:byte);
begin
  if ((port_b_latch=0) and (valor<>0)) then konamisnd_0.pedir_irq:=HOLD_LINE;
  port_b_latch:=valor;
end;

procedure frogger_hi_score;
begin
if ((memoria[$83f1]=$63) and (memoria[$83f2]=$04)) then begin
    load_hi('frogger.hi',@memoria[$83f1],10);
    copymemory(@memoria[$83ef],@memoria[$83f1],2);
    timer[timer_hs_frogger].enabled:=false;
end;
end;

//amidar
procedure eventos_amidar;
begin
if event.arcade then begin
  if arcade_input.but0[0] then marcade.in0:=marcade.in0 and $F7 else marcade.in0:=marcade.in0 or $8;
  if arcade_input.left[0] then marcade.in0:=marcade.in0 and $DF else marcade.in0:=marcade.in0 or $20;
  if arcade_input.right[0] then marcade.in0:=marcade.in0 and $EF else marcade.in0:=marcade.in0 or $10;
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $7F) else marcade.in0:=(marcade.in0 or $80);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $bF) else marcade.in0:=(marcade.in0 or $40);
  //marcade.in1
  if arcade_input.start[1] then marcade.in1:=marcade.in1 and $bF else marcade.in1:=marcade.in1 or $40;
  if arcade_input.start[0] then marcade.in1:=marcade.in1 and $7F else marcade.in1:=marcade.in1 or $80;
  //marcade.in2
  if arcade_input.up[0] then marcade.in2:=marcade.in2 and $ef else marcade.in2:=marcade.in2 or $10;
  if arcade_input.down[0] then marcade.in2:=marcade.in2 and $BF else marcade.in2:=marcade.in2 or $40;
end;
end;

function amidar_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$7fff:amidar_getbyte:=memoria[direccion];
  $8000..$87ff,$c000..$c7ff:amidar_getbyte:=memoria[$8000-(direccion and $7ff)];
  $9000..$97ff,$d000..$d7ff:amidar_getbyte:=videoram_mem[direccion and $3ff];
  $9800..$9fff,$d800..$dfff:case (direccion and $ff) of
                              0..$3f:amidar_getbyte:=atributos_mem[direccion and $3f];
                              $40..$5f:amidar_getbyte:=sprite_mem[direccion and $1f];
                              $60..$7f:amidar_getbyte:=disparo_mem[direccion and $1f];
                                 else amidar_getbyte:=memoria[$9800+(direccion and $ff)];
                            end;
  $b000..$b7ff,$f000..$f7ff:amidar_getbyte:=pia8255_0.read((direccion shr 4) and 3);
  $b800..$bfff,$f800..$ffff:amidar_getbyte:=pia8255_1.read((direccion shr 4) and 3);
    else amidar_getbyte:=$ff;
end;
end;

procedure amidar_putbyte(direccion:word;valor:byte);
var
  dir,f:byte;
begin
if direccion<$8000 then exit;
memoria[direccion]:=valor;
case direccion of
        $8000..$87ff,$c000..$c7ff:memoria[$8000-(direccion and $7ff)]:=valor;
        $9000..$97ff,$d000..$d7ff:if videoram_mem[direccion and $3ff]<>valor then begin
                  gfx[0].buffer[direccion and $3ff]:=true;
                  videoram_mem[direccion and $3ff]:=valor;
               end;
        $9800..$9fff,$d800..$dfff:case (direccion and $ff) of
                                    $0..$3f:if atributos_mem[direccion and $3f]<>valor then begin
                                              atributos_mem[direccion and $3f]:=valor;
                                              dir:=((direccion and $3f) shr 1);
                                              for f:=0 to $1f do gfx[0].buffer[dir+(f shl 5)]:=true;
                                            end;
                                    $40..$5f:sprite_mem[direccion and $1f]:=valor;
                                    $60..$7f:disparo_mem[direccion and $1f]:=valor;
                                        else memoria[$9800+(direccion and $ff)]:=valor;
                                 end;
        $a000..$a7ff,$e000..$e7ff:case (direccion and $3f) of
                                    8:haz_nmi:=(valor and 1)<>0;
                                  end;
        $b000..$b7ff,$f000..$f7ff:pia8255_0.write((direccion shr 4) and 3,valor);
        $b800..$bfff,$f800..$ffff:pia8255_1.write((direccion shr 4) and 3,valor);
end;
end;

//Definiciones Hardware General
//PPI 8255 0 y 1
function port_0_a_read:byte;
begin
  port_0_a_read:=marcade.in0;
end;

function port_0_b_read:byte;
begin
  port_0_b_read:=marcade.in1;
end;

function port_0_c_read:byte;
begin
  port_0_c_read:=marcade.in2;
end;

function port_1_c_read:byte;
begin
  port_1_c_read:=$ff;  //Amidar IN3
end;

procedure update_video_frogger;
var
        f,color,nchar:word;
        scroll,x,y,atrib:byte;
begin
//Chars
for f:=$0 to $3ff do begin
  if gfx[0].buffer[f] then begin
    x:=31-(f div 32);
    y:=f mod 32;
    atrib:=atributos_mem[y*2];
    color:=atributos_mem[$1+(y*2)];
    color:=(((color shr 1) and $3)+((color shl 2) and $4)) shl 2;
    scroll:=(x*8)+((atrib and $f) shl 4)+(atrib shr 4);
    nchar:=videoram_mem[f];
    if y<16 then color:=color+100;
    put_gfx(scroll,y*8,nchar,color,2,0);
    gfx[0].buffer[f]:=false;
  end;
end;
actualiza_trozo(0,0,256,256,2,0,0,256,256,1);
//Sprites
for f:=7 downto 0 do begin
  y:=sprite_mem[$3+(f*4)]+1;
  if y<16 then continue;
  atrib:=sprite_mem[$1+(f*4)];
  nchar:=atrib and $3f;
  color:=sprite_mem[$2+(f*4)];
  color:=(((color shr 1) and $3)+((color shl 2) and $4)) shl 2;
  x:=((sprite_mem[f*4] and $F) shl 4)+(sprite_mem[f*4] shr 4);
  put_gfx_sprite(nchar,color,(atrib and $80)<>0,(atrib and $40)<>0,1);
  actualiza_gfx_sprite(x,y,1,1);
end;
actualiza_trozo_final(16,0,224,256,1);
end;

procedure update_video_hgalaxian;
var
        f,color,nchar:word;
        scroll,x,y,atrib:byte;
begin
if scramble_background then fill_full_screen(1,99)
  else fill_full_screen(1,150);
//estellas
if stars_enable then draw_stars;
//Chars
for f:=$0 to $3ff do begin
  if gfx[0].buffer[f] then begin
    x:=31-(f div 32);
    y:=f mod 32;
    color:=(atributos_mem[$1+(y shl 1)] and $07) shl 2;
    scroll:=(x*8)+atributos_mem[y shl 1];
    nchar:=calc_nchar(f);
    if y<2 then put_gfx(scroll,y*8,nchar,color,2,0)
      else put_gfx_trans(scroll,y*8,nchar,color,2,0);
    gfx[0].buffer[f]:=false;
  end;
end;
actualiza_trozo(0,24,256,232,2,0,24,256,232,1);
//Disparos
for f:=0 to 7 do begin
  if f=7 then color:=32 else color:=33;
  y:=251-disparo_mem[$3+(f*4)];
  x:=disparo_mem[$1+(f*4)];
  put_gfx_sprite(0,color,false,false,2);
  actualiza_gfx_sprite(x,y,1,2);
end;
//Sprites
for f:=7 downto 0 do begin
  y:=sprite_mem[$3+(f*4)]+1;
  nchar:=calc_sprite(f);
  atrib:=sprite_mem[$1+(f*4)];
  color:=(sprite_mem[$2+(f*4)] and $7) shl 2;
  x:=sprite_mem[f*4];
  put_gfx_sprite(nchar,color,(atrib and $80)<>0,(atrib and $40)<>0,1);
  actualiza_gfx_sprite(x,y,1,1);
end;
actualiza_trozo(0,0,256,24,2,0,0,256,24,1);
actualiza_trozo_final(16,0,224,256,1);
end;

procedure frogger_principal;
var
  frame_m:single;
begin
init_controls(false,false,false,true);
frame_m:=main_z80.tframes;
while EmuStatus=EsRuning do begin
  for local_frame:=0 to $ff do begin
    main_z80.run(frame_m);
    frame_m:=frame_m+main_z80.tframes-main_z80.contador;
    //SND
    konamisnd_0.run(local_frame);
    if local_frame=248 then begin
      if haz_nmi then main_z80.change_nmi(PULSE_LINE);
      if stars_enable then stars_scrollpos:=stars_scrollpos+1;
      galaxian_update_video;
    end;
  end;
  eventos_hardware_galaxian;
  video_sync;
end;
end;

procedure hgalaxian_principal;
var
  frame:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame:=main_z80.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
    main_z80.run(frame);
    frame:=frame+main_z80.tframes-main_z80.contador;
    if f=248 then begin
      if haz_nmi then main_z80.change_nmi(PULSE_LINE);
      if stars_enable then stars_scrollpos:=stars_scrollpos+1;
      update_video_hgalaxian;  //el general, no hace falta la funcion
    end;
  end;
  eventos_hardware_galaxian;
  video_sync;
end;
end;

//Main
procedure reset_hgalaxian;
begin
 main_z80.reset;
 reset_audio;
 stars_scrollpos:=0;
 haz_nmi:=false;
 stars_enable:=false;
 scramble_background:=false;
 port_b_latch:=0;
 sound1_pos:=0;
 sound2_pos:=0;
 sound3_pos:=0;
 sound4_pos:=0;
 sound_pos:=0;
 scramble_prot:=0;
 scramble_prot_state:=0;
 case main_vars.tipo_maquina of
  14:begin
       konamisnd_0.reset;
       pia8255_0.reset;
       pia8255_1.reset;
       marcade.in0:=$FF;
       marcade.in1:=$FC;
       marcade.in2:=$F1;
     end;
  47:begin
       marcade.in0:=0;
       marcade.in1:=0;
       marcade.in2:=4;
       reset_samples;
  end;
  48:begin
       marcade.in0:=0;
       marcade.in1:=0;
       marcade.in2:=1;
       ay8910_0.reset;
  end;
  49:begin
       marcade.in0:=0;
       marcade.in1:=$80;
       marcade.in2:=0;
       reset_samples;
  end;
  143:begin
        konamisnd_0.reset;
        marcade.in0:=$ff;
        marcade.in1:=$fc;
        marcade.in2:=$f1;
        pia8255_0.reset;
        pia8255_1.reset;
      end;
  144:begin
        konamisnd_0.reset;
        marcade.in0:=$ff;
        marcade.in1:=$fd;
        marcade.in2:=$f2;
        pia8255_0.reset;
        pia8255_1.reset;
      end;
  145:begin
        konamisnd_0.reset;
        marcade.in0:=$ff;
        marcade.in1:=$ff;
        marcade.in2:=$f1;
        pia8255_0.reset;
        pia8255_1.reset;
      end;
 end;
end;

function iniciar_hgalaxian:boolean;
var
      colores:tpaleta;
      f,x,y:word;
      pos:pbyte;
      ctemp1,ctemp2,total_stars:byte;
      bit0,generator:dword;
      memoria_temp:array[0..$afff] of byte;
const
  ps_x:array[0..15] of dword=(0, 1, 2, 3, 4, 5, 6, 7,
			8*8+0, 8*8+1, 8*8+2, 8*8+3, 8*8+4, 8*8+5, 8*8+6, 8*8+7);
  ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			16*8, 17*8, 18*8, 19*8, 20*8, 21*8, 22*8, 23*8);
  pc_x:array[0..7] of dword=(0, 1, 2, 3, 4, 5, 6, 7 );
  pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
  map:array[0..3] of byte =($00,$88,$cc,$ff);
//pequeñas funciones para aclarar el codigo
procedure convert_chars(n:word);
begin
  init_gfx(0,8,8,n);
  gfx[0].trans[0]:=true;
  gfx_set_desc_data(2,0,8*8,0,n*8*8);
  convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],true,false);
end;
procedure convert_sprt(n:word);
begin
  init_gfx(1,16,16,n);
  gfx[1].trans[0]:=true;
  gfx_set_desc_data(2,0,32*8,0,n*16*16);
  convert_gfx(1,0,@memoria_temp[0],@ps_x[0],@ps_y[0],true,false);
end;
begin
iniciar_hgalaxian:=false;
iniciar_audio(false);
screen_init(1,256,512,true,true);
screen_init(2,512,256,true);
iniciar_video(224,256);
//Main CPU
main_z80:=cpu_z80.create(3072000,256);
case main_vars.tipo_maquina of
  14:begin  //frogger
      //Main CPU
      main_z80.change_ram_calls(frogger_getbyte,frogger_putbyte);
      //Sound
      konamisnd_0:=konamisnd_chip.create(1,TIPO_FROGGER,1789750,256);
      //Hi-Score
      timer_hs_frogger:=init_timer(main_z80.numero_cpu,10000,frogger_hi_score,true);
      //PPI 8255
      pia8255_0:=pia8255_chip.create;
      pia8255_0.change_ports(port_0_a_read,port_0_b_read,port_0_c_read,nil,nil,nil);
      pia8255_1:=pia8255_chip.create;
      pia8255_1.change_ports(nil,nil,nil,frogger_port_1_a_write,frogger_port_1_b_write,nil);
      //cargar roms
      if not(cargar_roms(@memoria[0],@frogger_rom[0],'frogger.zip',0)) then exit;
      if not(cargar_roms(@mem_snd[0],@frogger_sound[0],'frogger.zip',0)) then exit;
      //Las ROMS tienen lineas movidas...
      for f:=0 to $7FF do mem_snd[f]:=BITSWAP8(mem_snd[f],7,6,5,4,3,2,0,1);
      //convertir chars & sprites
      if not(cargar_roms(@memoria_temp[0],@frogger_char[0],'frogger.zip',0)) then exit;
      //la rom tiene cambiadas D1 y D0
      for f:=$800 to $FFF do memoria_temp[f]:=BITSWAP8(memoria_temp[f],7,6,5,4,3,2,0,1);
      convert_chars(256);
      convert_sprt(64);
      if not(cargar_roms(@memoria_temp[$0],@frogger_pal,'frogger.zip',1)) then exit;
  end;
  47:begin  //galaxian
      //funciones Z80
      main_z80.change_ram_calls(galaxian_getbyte,galaxian_putbyte);
      //cargar roms
      if not(cargar_roms(@memoria[0],@galaxian_rom[0],'galaxian.zip',0)) then exit;
      //cargar samples
      if load_samples('galaxian.zip',@galaxian_samples[0],galaxian_num_samples) then main_z80.init_sound(galaxian_despues_instruccion);
      //convertir chars &sprites
      if not(cargar_roms(@memoria_temp[0],@galaxian_char[0],'galaxian.zip',0)) then exit;
      convert_chars(256);
      convert_sprt(64);
      if not(cargar_roms(@memoria_temp[0],@galaxian_pal,'galaxian.zip',1)) then exit;
  end;
  48:begin //Jump Bug
      //funciones Z80
      main_z80.change_ram_calls(jumpbug_getbyte,jumpbug_putbyte);
      //chip de sonido
      main_z80.init_sound(jumpbug_despues_instruccion);
      ay8910_0:=ay8910_chip.create(1500000,1);
      //Timers
      init_timer(0,3072000*(0.693*(100000+2*10000)*0.00001),jumpbug_blinking,true);
      //cargar roms
      if not(cargar_roms(@memoria[0],@jumpbug_rom[0],'jumpbug.zip',0)) then exit;
      //convertir chars &sprites
      if not(cargar_roms(@memoria_temp[0],@jumpbug_char[0],'jumpbug.zip',0)) then exit;
      convert_chars(768);
      convert_sprt(192);
      if not(cargar_roms(@memoria_temp[0],@jumpbug_pal,'jumpbug.zip',1)) then exit;
  end;
  49:begin  //mooncrst
      //funciones Z80
      main_z80.change_ram_calls(mooncrst_getbyte,mooncrst_putbyte);
      //cargar roms
      if not(cargar_roms(@memoria[0],@mooncrst_rom[0],'mooncrst.zip',0)) then exit;
      //Desencriptarlas
      for f:=0 to $3fff do begin
		    ctemp1:=memoria[f];
		    ctemp2:=ctemp1;
		    if ((ctemp1 and 2)<>0) then ctemp2:=ctemp2 xor $40;
		    if ((ctemp1 and $20)<>0) then ctemp2:=ctemp2 xor $04;
		    if ((f and 1)=0) then ctemp1:=BITSWAP8(ctemp2,7,2,5,4,3,6,1,0)
          else ctemp1:=ctemp2;
		    memoria[f]:=ctemp1;
      end;
      if load_samples('mooncrst.zip',@mooncrst_samples[0],5) then main_z80.init_sound(galaxian_despues_instruccion);
      //convertir chars & sprites
      if not(cargar_roms(@memoria_temp[0],@mooncrst_char[0],'mooncrst.zip',0)) then exit;
      convert_chars(512);
      convert_sprt(128);
      if not(cargar_roms(@memoria_temp[0],@mooncrst_pal,'mooncrst.zip',1)) then exit;
  end;
  143:begin  //scramble
      //Main CPU
      main_z80.change_ram_calls(scramble_getbyte,scramble_putbyte);
      //Sound
      konamisnd_0:=konamisnd_chip.create(1,TIPO_SCRAMBLE,1789750,256);
      //PPI 8255
      pia8255_0:=pia8255_chip.create;
      pia8255_0.change_ports(port_0_a_read,port_0_b_read,port_0_c_read,nil,nil,nil);
      pia8255_1:=pia8255_chip.create;
      pia8255_1.change_ports(nil,nil,scramble_port_1_c_read,scramble_port_1_a_write,scramble_port_1_b_write,scramble_port_1_c_write);
      init_timer(0,3072000*(0.693*(100000+2*10000)*0.00001),jumpbug_blinking,true);
      //cargar roms
      if not(cargar_roms(@memoria[0],@scramble_rom[0],'scramble.zip',0)) then exit;
      if not(cargar_roms(@mem_snd[0],@scramble_sound[0],'scramble.zip',0)) then exit;
      //convertir chars & sprites
      if not(cargar_roms(@memoria_temp[0],@scramble_char[0],'scramble.zip',0)) then exit;
      convert_chars(256);
      convert_sprt(64);
      if not(cargar_roms(@memoria_temp[0],@scramble_pal,'scramble.zip',1)) then exit;
  end;
  144:begin  //super cobra
      //Main CPU
      main_z80.change_ram_calls(scobra_getbyte,scobra_putbyte);
      //Sound
      konamisnd_0:=konamisnd_chip.create(1,TIPO_SCRAMBLE,1789750,256);
      //PPI 8255
      pia8255_0:=pia8255_chip.create;
      pia8255_0.change_ports(port_0_a_read,port_0_b_read,port_0_c_read,nil,nil,nil);
      pia8255_1:=pia8255_chip.create;
      pia8255_1.change_ports(nil,nil,nil,scramble_port_1_a_write,scramble_port_1_b_write,nil);
      init_timer(0,3072000*(0.693*(100000+2*10000)*0.00001),jumpbug_blinking,true);
      //cargar roms
      if not(cargar_roms(@memoria[0],@scobra_rom[0],'scobra.zip',0)) then exit;
      if not(cargar_roms(@mem_snd[0],@scobra_sound[0],'scobra.zip',0)) then exit;
      //convertir chars & sprites
      if not(cargar_roms(@memoria_temp[0],@scobra_char[0],'scobra.zip',0)) then exit;
      convert_chars(256);
      convert_sprt(64);
      if not(cargar_roms(@memoria_temp[0],@scobra_pal,'scobra.zip',1)) then exit;
  end;
  145:begin  //amidar
      //Main CPU
      main_z80.change_ram_calls(amidar_getbyte,amidar_putbyte);
      //Sound
      konamisnd_0:=konamisnd_chip.create(1,TIPO_SCRAMBLE,1789750,256);
      //PPI 8255
      pia8255_0:=pia8255_chip.create;
      pia8255_0.change_ports(port_0_a_read,port_0_b_read,port_0_c_read,nil,nil,nil);
      pia8255_1:=pia8255_chip.create;
      pia8255_1.change_ports(nil,nil,port_1_c_read,scramble_port_1_a_write,scramble_port_1_b_write,nil);
      //cargar roms
      if not(cargar_roms(@memoria[0],@amidar_rom[0],'amidar.zip',0)) then exit;
      if not(cargar_roms(@mem_snd[0],@amidar_sound[0],'amidar.zip',0)) then exit;
      //convertir chars & sprites
      if not(cargar_roms(@memoria_temp[0],@amidar_char[0],'amidar.zip',0)) then exit;
      convert_chars(256);
      convert_sprt(64);
      if not(cargar_roms(@memoria_temp[0],@amidar_pal,'amidar.zip',1)) then exit;
  end;
end;
//poner la paleta
for f:=0 to 31 do begin
  ctemp1:=memoria_temp[f];
  colores[f].r:=$21*(ctemp1 and 1)+$47*((ctemp1 shr 1) and 1)+$97*((ctemp1 shr 2) and 1);
  colores[f].g:=$21*((ctemp1 shr 3) and 1)+$47*((ctemp1 shr 4) and 1)+$97*((ctemp1 shr 5) and 1);
  colores[f].b:=0+$47*((ctemp1 shr 6) and 1)+$97*((ctemp1 shr 7) and 1);
  //Para frogger una paleta extra con la parte de arriba mas azul
  if main_vars.tipo_maquina=14 then begin
    colores[f+100].r:=colores[f].r;
    colores[f+100].g:=colores[f].g;
    colores[f+100].b:=colores[f].b;
    if ((colores[f].r=0) and (colores[f].g=0) and (colores[f].b=0)) then colores[f+100].b:=colores[f+100].b+$39;
  end;
end;
//y la paleta del disparo
colores[32].r:=$FF;colores[32].g:=$FF;colores[32].b:=$0;
colores[33].r:=$FF;colores[33].g:=$FF;colores[33].b:=$FF;
//y la de las estrellas de fondo
for f:=0 to 63 do begin
  ctemp1:=(f shr 0) and $03;
  colores[f+34].r:=map[ctemp1];
  ctemp1:=(f shr 2) and $03;
  colores[f+34].g:=map[ctemp1];
  ctemp1:=(f shr 4) and $03;
  colores[f+34].b:=map[ctemp1];
end;
//Color especial Scramble Background
colores[99].r:=0;
colores[99].g:=0;
colores[99].b:=$56;
//32 paleta,2 disparo,64 estrellas,1 fondo azul scramble,1 vacio y 32 fondo azul frogger
set_pal(colores,32+2+64+1+1+32);
//El disparo, creado por hardware aqui lo emulo como si fuera un sprite...
case main_vars.tipo_maquina of
  143,144,145:begin
            init_gfx(2,1,1,1);
            gfx[2].datos^:=0;
          end;
    else begin
        init_gfx(2,1,4,1);
        pos:=gfx[2].datos;
        for f:=0 to 3 do begin
          pos^:=0;
          inc(pos);
        end;
    end;
end;
//iniciar las estrellas de fondo
total_stars:=0;
generator:=0;
for y:=0 to 255 do begin
		for x:=0 to 511 do begin
			bit0:=((not(generator) shr 16) and $01) xor ((generator shr 4) and $01);
			generator:=(generator shl 1) or bit0;
			if ((((not(generator) shr 16) and $01)<>0) and ((generator and $ff)=$ff)) then begin
				ctemp1:= (not(generator shr 8)) and $3f;
				if (ctemp1<>0) then begin
					stars[total_stars].x:=x;
					stars[total_stars].y:=y;
					stars[total_stars].color:=ctemp1+34;
					total_stars:=total_stars+1;
				end;
      end;
		end;
end;
//final
reset_hgalaxian;
iniciar_hgalaxian:=true;
end;

procedure cerrar_hgalaxian;
begin
if main_vars.tipo_maquina=14 then save_hi('frogger.hi',@memoria[$83f1],10);
end;

procedure Cargar_hgalaxian;
begin
case main_vars.tipo_maquina of
  14:begin
      llamadas_maquina.bucle_general:=frogger_principal;
      eventos_hardware_galaxian:=eventos_frogger;
      calc_nchar:=galaxian_calc_nchar; //no usado
      calc_sprite:=galaxian_calc_sprite;  //no usado
      draw_stars:=stars_galaxian;  //no usado
      galaxian_update_video:=update_video_frogger;
     end;
  47:begin
      llamadas_maquina.bucle_general:=hgalaxian_principal;
      eventos_hardware_galaxian:=eventos_galaxian;
      calc_nchar:=galaxian_calc_nchar;
      calc_sprite:=galaxian_calc_sprite;
      draw_stars:=stars_galaxian;
      galaxian_update_video:=update_video_hgalaxian;
     end;
  48:begin
      llamadas_maquina.bucle_general:=hgalaxian_principal;
      eventos_hardware_galaxian:=eventos_jumpbug;
      calc_nchar:=jumpbug_calc_nchar;
      calc_sprite:=jumpbug_calc_sprite;
      draw_stars:=stars_jumpbug;
      galaxian_update_video:=update_video_hgalaxian;
  end;
  49:begin
      llamadas_maquina.bucle_general:=hgalaxian_principal;
      eventos_hardware_galaxian:=eventos_galaxian;
      calc_nchar:=mooncrst_calc_nchar;
      calc_sprite:=mooncrst_calc_sprite;
      draw_stars:=stars_galaxian;
      galaxian_update_video:=update_video_hgalaxian;
  end;
  143..145:begin
      llamadas_maquina.bucle_general:=frogger_principal;
      eventos_hardware_galaxian:=eventos_scramble;
      calc_nchar:=galaxian_calc_nchar;
      calc_sprite:=galaxian_calc_sprite;
      draw_stars:=stars_jumpbug;
      galaxian_update_video:=update_video_hgalaxian;
  end;
end;
llamadas_maquina.iniciar:=iniciar_hgalaxian;
llamadas_maquina.cerrar:=cerrar_hgalaxian;
llamadas_maquina.reset:=reset_hgalaxian;
llamadas_maquina.fps_max:=60.6060606060;
end;

end.
