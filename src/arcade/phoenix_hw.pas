unit phoenix_hw;
interface
//{$DEFINE PHOENIX_DEBUG}
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,gfx_engine,tms36xx,phoenix_audio_digital,
     rom_engine,pal_engine,sound_engine;

procedure cargar_phoenix;

implementation
var
 banco_pal,scroll_y,banco,sound_latch_b:byte;
 mem_video:array[0..1,0..$fff] of byte;

const
        phoenix_rom:array[0..7] of tipo_roms=(
        (n:'ic45';l:$800;p:0;crc:$9f68086b),(n:'ic46';l:$800;p:$800;crc:$273a4a82),
        (n:'ic47';l:$800;p:$1000;crc:$3d4284b9),(n:'ic48';l:$800;p:$1800;crc:$cb5d9915),
        (n:'h5-ic49.5a';l:$800;p:$2000;crc:$a105e4e7),(n:'h6-ic50.6a';l:$800;p:$2800;crc:$ac5e9ec1),
        (n:'h7-ic51.7a';l:$800;p:$3000;crc:$2eab35b4),(n:'h8-ic52.8a';l:$800;p:$3800;crc:$aff8e9c5));
        phoenix_char1:array[0..1] of tipo_roms=(
        (n:'ic23.3d';l:$800;p:0;crc:$3c7e623f),(n:'ic24.4d';l:$800;p:$800;crc:$59916d3b));
        phoenix_char2:array[0..1] of tipo_roms=(
        (n:'b1-ic39.3b';l:$800;p:0;crc:$53413e8f),(n:'b2-ic40.4b';l:$800;p:$800;crc:$0be2ba91));
        phoenix_pal:array[0..1] of tipo_roms=(
        (n:'mmi6301.ic40';l:$100;p:0;crc:$79350b25),(n:'mmi6301.ic41';l:$100;p:$100;crc:$e176b768));
        //Pleiads
        pleiads_rom:array[0..7] of tipo_roms=(
        (n:'ic47.r1';l:$800;p:0;crc:$960212c8),(n:'ic48.r2';l:$800;p:$800;crc:$b254217c),
        (n:'ic47.bin';l:$800;p:$1000;crc:$87e700bb),(n:'ic48.bin';l:$800;p:$1800;crc:$2d5198d0),
        (n:'ic51.r5';l:$800;p:$2000;crc:$49c629bc),(n:'ic50.bin';l:$800;p:$2800;crc:$f1a8a00d),
        (n:'ic53.r7';l:$800;p:$3000;crc:$b5f07fbc),(n:'ic52.bin';l:$800;p:$3800;crc:$b1b5a8a6));
        pleiads_char1:array[0..1] of tipo_roms=(
        (n:'ic23.bin';l:$800;p:0;crc:$4e30f9e7),(n:'ic24.bin';l:$800;p:$800;crc:$5188fc29));
        pleiads_char2:array[0..1] of tipo_roms=(
        (n:'ic39.bin';l:$800;p:0;crc:$85866607),(n:'ic40.bin';l:$800;p:$800;crc:$a841d511));
        pleiads_pal:array[0..1] of tipo_roms=(
        (n:'7611-5.33';l:$100;p:0;crc:$e38eeb83),(n:'7611-5.26';l:$100;p:$100;crc:$7a1bcb1e));
        //Dip
        phoenix_dip_a:array [0..3] of def_dip=(
        (mask:$3;name:'Lives';number:4;dip:((dip_val:$0;dip_name:'3'),(dip_val:$1;dip_name:'4'),(dip_val:$2;dip_name:'5'),(dip_val:$3;dip_name:'6'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0c;name:'Bonus Life';number:4;dip:((dip_val:$0;dip_name:'3k 30k'),(dip_val:$4;dip_name:'4k 40k'),(dip_val:$8;dip_name:'5k 50k'),(dip_val:$c;dip_name:'6k 60k'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Coinage';number:2;dip:((dip_val:$10;dip_name:'2C 1C'),(dip_val:$0;dip_name:'1C 1C'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        pleiads_dip_a:array [0..4] of def_dip=(
        (mask:$3;name:'Lives';number:4;dip:((dip_val:$0;dip_name:'3'),(dip_val:$1;dip_name:'4'),(dip_val:$2;dip_name:'5'),(dip_val:$3;dip_name:'6'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0c;name:'Bonus Life';number:4;dip:((dip_val:$0;dip_name:'3k 30k'),(dip_val:$4;dip_name:'4k 40k'),(dip_val:$8;dip_name:'5k 50k'),(dip_val:$c;dip_name:'6k 60k'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Coinage';number:2;dip:((dip_val:$10;dip_name:'2C 1C'),(dip_val:$0;dip_name:'1C 1C'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$40;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

procedure update_video_phoenix;inline;
var
    nchar:byte;
    color,f,x,y:word;
begin
for f:=0 to $3ff do begin
  x:=(31-(f shr 5)) shl 3;
  y:=(f and $1f) shl 3;
  if gfx[0].buffer[f+$400] then begin
    nchar:=mem_video[banco,$800+f];
    color:=((nchar shr 5)+(banco_pal shl 4)) shl 2;
    put_gfx(x,y,nchar,color,1,0);
    gfx[0].buffer[f+$400]:=false;
  end;
  if gfx[0].buffer[f] then begin
    nchar:=mem_video[banco,f];
    color:=((nchar shr 5)+(banco_pal shl 4)+8) shl 2;
    put_gfx_trans(x,y,nchar+256,color,2,0);
    gfx[0].buffer[f]:=false;
  end;
end;
scroll__y(1,3,scroll_y);
actualiza_trozo(0,0,256,256,2,0,0,256,256,3);
actualiza_trozo_final(48,0,208,248,3);
end;

procedure eventos_phoenix;
begin
if event.arcade then begin
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
end;
end;

//Phoenix
procedure phoenix_principal;
var
  frame:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame:=z80_0.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
    z80_0.run(frame);
    frame:=frame+z80_0.tframes-z80_0.contador;
    case f of
        207:begin
              marcade.dswa:=marcade.dswa and $7f;
              update_video_phoenix;
            end;
        255:marcade.dswa:=marcade.dswa or $80;
    end;
  end;
  phoenix_audio_update;
  eventos_phoenix;
  video_sync;
end;
end;

function phoenix_getbyte(direccion:word):byte;
begin
direccion:=direccion and $7fff;
case direccion of
  0..$3fff:phoenix_getbyte:=memoria[direccion];
  $4000..$4fff:phoenix_getbyte:=mem_video[banco,direccion and $fff];
  $7000..$73ff:phoenix_getbyte:=marcade.in0;
  $7800..$7bff:phoenix_getbyte:=marcade.dswa;
end;
end;

procedure phoenix_putbyte(direccion:word;valor:byte);
begin
direccion:=direccion and $7fff;
case direccion of
  0..$3fff:;
  $4000..$43ff:if mem_video[banco,direccion and $fff]<>valor then begin
                  mem_video[banco,direccion and $fff]:=valor;
                  gfx[0].buffer[direccion and $3ff]:=true;
               end;
  $4400..$47ff,$4c00..$4fff:mem_video[banco,direccion and $fff]:=valor;
  $4800..$4bff:if mem_video[banco,direccion and $fff]<>valor then begin
                  mem_video[banco,direccion and $fff]:=valor;
                  gfx[0].buffer[(direccion and $3ff)+$400]:=true;
               end;
  $5000..$53ff:begin
                  if banco<>(valor and 1) then begin
                    fillchar(gfx[0].buffer[0],$800,1);
                    banco:=(valor and 1);
                  end;
                  if banco_pal<>((valor shr 1) and 1) then begin
                    banco_pal:=((valor shr 1) and 1);
                    fillchar(gfx[0].buffer[0],$800,1);
                  end;
               end;
  $5800..$5bff:scroll_y:=valor;
  $6000..$63ff:phoenix_wsound_a(valor);
  $6800..$6bff:begin
                  phoenix_wsound_b(valor);
                  mm6221aa_tune_w(valor shr 6);
               end;
end;
end;

//Pleiads
procedure pleiads_principal;
var
  frame:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame:=z80_0.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
    z80_0.run(frame);
    frame:=frame+z80_0.tframes-z80_0.contador;
    case f of
        207:begin
              marcade.dswa:=marcade.dswa and $7f;
              update_video_phoenix;
            end;
        255:marcade.dswa:=marcade.dswa or $80;
    end;
  end;
  eventos_phoenix;
  video_sync;
end;
end;

procedure pleiads_putbyte(direccion:word;valor:byte);
var
  pitch,note:byte;
begin
direccion:=direccion and $7fff;
case direccion of
  0..$3fff:;
  $4000..$43ff:if mem_video[banco,direccion and $fff]<>valor then begin
                  mem_video[banco,direccion and $fff]:=valor;
                  gfx[0].buffer[direccion and $3ff]:=true;
               end;
  $4400..$47ff,$4c00..$4fff:mem_video[banco,direccion and $fff]:=valor;
  $4800..$4bff:if mem_video[banco,direccion and $fff]<>valor then begin
                  mem_video[banco,direccion and $fff]:=valor;
                  gfx[0].buffer[(direccion and $3ff)+$400]:=true;
               end;
  $5000..$53ff:begin
                  if banco<>(valor and 1) then begin
                    fillchar(gfx[0].buffer[0],$800,1);
                    banco:=(valor and 1);
                  end;
                  if banco_pal<>((valor shr 1) and 3) then begin
                    banco_pal:=((valor shr 1) and 3);
                    fillchar(gfx[0].buffer[0],$800,1);
                  end;
                  //Proteccion
                  case (valor and $fc) of
                    0,$20:marcade.in0:=(marcade.in0 and $F7);
                    $c,$30:marcade.in0:=(marcade.in0 or 8);
                  end;
               end;
  $5800..$5bff:scroll_y:=valor;
  $6000..$63ff:;//analog
  $6800..$6bff:{$IFDEF PHOENIX_DEBUG}if (valor<>sound_latch_b) then begin
                    note:=valor and 15;
	                  pitch:=(valor shr 6) and 3;
	                  if (pitch=3) then pitch:=2;  // 2 and 3 are the same
	                  tms36xx_note_w(pitch,note);
	                  sound_latch_b:=valor;
               end{$ENDIF};
end;
end;

procedure phoenix_sound_update;
begin
  tms36xx_sound_update;
end;

//Main
procedure phoenix_reset;
begin
z80_0.reset;
scroll_y:=0;
banco_pal:=0;
marcade.in0:=$ff;
if main_vars.tipo_maquina=11 then phoenix_audio_reset;
end;

function phoenix_iniciar:boolean;
var
      colores:tpaleta;
      ctemp1,ctemp2,f:byte;
      memoria_temp:array[0..$fff] of byte;
const
      pc_x:array[0..7] of dword=(7, 6, 5, 4, 3, 2, 1, 0);
      pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
      phoenix_dec:array[0..5] of single=(0.5,0,0,1.05,0,0);
      pleiads_dec:array[0..5] of single=(0.33,0.33,0,0.33,0,0.33);
begin
phoenix_iniciar:=false;
iniciar_audio(false);
screen_init(1,256,256);
screen_mod_scroll(1,256,256,255,256,256,255);
screen_init(2,256,256,true);
screen_init(3,256,256,false,true);
iniciar_video(208,248);
//Main CPU
z80_0:=cpu_z80.create(5500000,256);
z80_0.init_sound(phoenix_sound_update);
case main_vars.tipo_maquina of
  11:begin //Phoenix
        z80_0.change_ram_calls(phoenix_getbyte,phoenix_putbyte);
        //Chip sonido
        tms36xx_start(372,0.21,@phoenix_dec);
        phoenix_audio_start;
        //cargar roms
        if not(roms_load(@memoria,phoenix_rom)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,phoenix_char1)) then exit;
        init_gfx(0,8,8,512);
        gfx[0].trans[0]:=true;
        gfx_set_desc_data(2,2,8*8,256*8*8,0);
        convert_gfx(0,0,@memoria_temp,@pc_x,@pc_y,true,false);
        //Segundo juego de chars
        if not(roms_load(@memoria_temp,phoenix_char2)) then exit;
        convert_gfx(0,256*8*8,@memoria_temp[0],@pc_x[0],@pc_y[0],true,false);
        //poner paleta
        if not(roms_load(@memoria_temp,phoenix_pal)) then exit;
        for f:=0 to $ff do gfx[0].colores[f]:=((f shl 3) and $18) or ((f shr 2) and $07) or (f and $60);
        //DIP
        marcade.dswa:=$e0;
        marcade.dswa_val:=@phoenix_dip_a;
  end;
  202:begin //Pleiads
        z80_0.change_ram_calls(phoenix_getbyte,pleiads_putbyte);
        //Chip sonido
        tms36xx_start(247,0,@pleiads_dec);
        //phoenix_audio_start;
        //cargar roms
        if not(roms_load(@memoria,pleiads_rom)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,pleiads_char1)) then exit;
        init_gfx(0,8,8,512);
        gfx[0].trans[0]:=true;
        gfx_set_desc_data(2,2,8*8,256*8*8,0);
        convert_gfx(0,0,@memoria_temp,@pc_x,@pc_y,true,false);
        //Segundo juego de chars
        if not(roms_load(@memoria_temp,pleiads_char2)) then exit;
        convert_gfx(0,256*8*8,@memoria_temp,@pc_x,@pc_y,true,false);
        //poner paleta
        if not(roms_load(@memoria_temp,pleiads_pal)) then exit;
        for f:=0 to $ff do gfx[0].colores[f]:=((f shl 3 ) and $18) or ((f shr 2) and $07) or (f and $e0);
        //DIP
        marcade.dswa:=$e0;
        marcade.dswa_val:=@pleiads_dip_a;
  end;
end;
for f:=0 to $ff do begin
    //paleta
    ctemp1:=memoria_temp[f];
    ctemp2:=memoria_temp[f+256];
    colores[f].r:=$55*(ctemp1 and 1)+$aa*(ctemp2 and 1);
    colores[f].g:=$55*((ctemp1 shr 2) and 1)+$aa*((ctemp2 shr 2) and 1);
    colores[f].b:=$55*((ctemp1 shr 1) and 1)+$aa*((ctemp2 shr 1) and 1);
end;
set_pal(colores,256);
//final
phoenix_reset;
phoenix_iniciar:=true;
end;
procedure phoenix_cerrar;
begin
tms36xx_close;
if main_vars.tipo_maquina=11 then phoenix_audio_cerrar;
end;
procedure cargar_phoenix;
begin
llamadas_maquina.iniciar:=phoenix_iniciar;
case main_vars.tipo_maquina of
  11:llamadas_maquina.bucle_general:=phoenix_principal;
  202:llamadas_maquina.bucle_general:=pleiads_principal;
end;
llamadas_maquina.close:=phoenix_cerrar;
llamadas_maquina.reset:=phoenix_reset;
llamadas_maquina.fps_max:=61.035156;
end;

end.
