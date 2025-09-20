unit spaceinvaders_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,gfx_engine,rom_engine,
     samples,pal_engine,sound_engine,qsnapshot;

function iniciar_spaceinv:boolean;

implementation

const
        spaceinv_rom:array[0..3] of tipo_roms=(
        (n:'invaders.h';l:$800;p:0;crc:$734f5ad8),(n:'invaders.g';l:$800;p:$800;crc:$6bfaca4a),
        (n:'invaders.f';l:$800;p:$1000;crc:$0ccead96),(n:'invaders.e';l:$800;p:$1800;crc:$14e538b0));
        spaceinv_samples:array[0..8] of tipo_nombre_samples=(
        (nombre:'1.wav'),(nombre:'2.wav'),(nombre:'3.wav'),(nombre:'4.wav'),(nombre:'5.wav'),
        (nombre:'6.wav'),(nombre:'7.wav'),(nombre:'8.wav'),(nombre:'9.wav'));
        //DIP
        spaceinv_dip:array [0..3] of def_dip2=(
        (mask:3;name:'Lives';number:4;val4:(0,1,2,3);name4:('3','4','5','6')),
        (mask:8;name:'Bonus Life';number:2;val2:(8,0);name2:('1000','1500')),
        (mask:$80;name:'Display Coinage';number:2;val2:($80,0);name2:('Off','On')),());

var
  shift_data:word;
  shift_count,sound1,sound2:byte;

procedure update_video_spaceinv;
var
  x,y,video_data:byte;
  i,pos_temp,val:byte;
  pos:word;
  pen:array[0..$ffff] of word;
begin
pos:=0;
for x:=0 to $ff do begin
  for y:=$1f downto 0 do begin
    video_data:=memoria[$2000+pos];
    for i:=0 to 7 do begin
      pos_temp:=(y*8)+i;
      val:=(video_data and $80) shr 7;
      if val<>0 then begin //Overlay
        case pos_temp of
           32..62:val:=3;
           184..240:val:=2;
           241..255:case x of
                        48..165:val:=2;
                    end;
        end;
      end;
      pen[(pos_temp*256)+x]:=paleta[val];
      video_data:=video_data shl 1;
    end;
    pos:=pos+1;
  end;
end;
putpixel(0,0,$10000,@pen[0],1);
actualiza_trozo(32,0,224,256,1,0,0,224,256,PANT_TEMP);
end;

procedure eventos_spaceinv;
begin
if event.arcade then begin
  //P1
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 or $10) else marcade.in0:=(marcade.in0 and $ef);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 or $20) else marcade.in0:=(marcade.in0 and $df);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 or $40) else marcade.in0:=(marcade.in0 and $bf);
  //System
  if arcade_input.coin[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 or 2) else marcade.in1:=(marcade.in1 and $fd);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 or 4) else marcade.in1:=(marcade.in1 and $fb);
end;
end;

procedure spaceinv_principal;
var
  f:word;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
  for f:=0 to 261 do begin
    case f of
    96:z80_0.change_irq_vector(HOLD_LINE,$cf);
    224:begin
          z80_0.change_irq_vector(HOLD_LINE,$d7);
          update_video_spaceinv;
        end;
    end;
    z80_0.run(frame_main);
    frame_main:=frame_main+z80_0.tframes-z80_0.contador;
  end;
  eventos_spaceinv;
  video_sync;
end;
end;

function spaceinv_getbyte(direccion:word):byte;
begin
direccion:=direccion and $7fff;
case direccion of
  0..$1fff,$4000..$5fff:spaceinv_getbyte:=memoria[direccion];
  $2000..$3fff,$6000..$7fff:spaceinv_getbyte:=memoria[$2000+(direccion and $1fff)];
end;
end;

procedure spaceinv_putbyte(direccion:word;valor:byte);
begin
direccion:=direccion and $7fff;
case direccion of
  0..$1fff,$4000..$5fff:exit;
  $2000..$3fff,$6000..$7fff:memoria[$2000+(direccion and $1fff)]:=valor;
end;
end;

function spaceinv_inbyte(puerto:word):byte;
begin
case (puerto and 7) of
  0,4:spaceinv_inbyte:=8 or marcade.in0;
  1,5:spaceinv_inbyte:=marcade.in1 or marcade.in0;
  2,6:spaceinv_inbyte:=marcade.dswa or marcade.in0;
  3,7:spaceinv_inbyte:=shift_data shr shift_count;
end;
end;

procedure spaceinv_outbyte(puerto:word;valor:byte);
begin
case (puerto and 7) of
  2:shift_count:=not(valor) and 7;
  3:begin //sound1
       if (((valor and 1)<>0) and ((sound1 and 1)=0)) then start_sample(7);
       if (((valor and 2)<>0) and ((sound1 and 2)=0)) then start_sample(0);
       if (((valor and 4)<>0) and ((sound1 and 4)=0)) then start_sample(1);
       if (((valor and 8)<>0) and ((sound1 and 8)=0)) then start_sample(2);
       if (((valor and $10)<>0) and ((sound1 and $10)=0)) then start_sample(8); //????
       sound1:=valor;
    end;
  4:shift_data:=(shift_data shr 8) or (valor shl 7);
  5:begin
       if (((valor and 1)<>0) and ((sound2 and 1)=0)) then start_sample(3);
       if (((valor and 2)<>0) and ((sound2 and 2)=0)) then start_sample(4);
       if (((valor and 4)<>0) and ((sound2 and 4)=0)) then start_sample(5);
       if (((valor and 8)<>0) and ((sound2 and 8)=0)) then start_sample(6);
       if (((valor and $10)<>0) and ((sound2 and $10)=0)) then start_sample(8);
       sound2:=valor;
    end;
end;
end;

procedure spaceinv_sound_update;
begin
  samples_update;
end;

procedure spaceinv_qsave(nombre:string);
var
  data:pbyte;
  size:word;
  buffer:array[0..4] of byte;
begin
open_qsnapshot_save('spaceinv'+nombre);
getmem(data,2000);
//CPU
size:=z80_0.save_snapshot(data);
savedata_qsnapshot(data,size);
//MEM
savedata_qsnapshot(@memoria[$2000],$2000);
//MISC
buffer[0]:=shift_data shr 8;
buffer[1]:=shift_data and $ff;
buffer[2]:=shift_count;
buffer[3]:=sound1;
buffer[4]:=sound2;
savedata_qsnapshot(@buffer[0],5);
freemem(data);
close_qsnapshot;
end;

procedure spaceinv_qload(nombre:string);
var
  data:pbyte;
  buffer:array[0..4] of byte;
begin
if not(open_qsnapshot_load('spaceinv'+nombre)) then exit;
getmem(data,2000);
//CPU
loaddata_qsnapshot(data);
z80_0.load_snapshot(data);
//MEM
loaddata_qsnapshot(@memoria[$2000]);
//MISC
loaddata_qsnapshot(@buffer[0]);
shift_data:=buffer[0] shl 8;
shift_data:=shift_data or buffer[1];
shift_count:=buffer[2];
sound1:=buffer[3];
sound2:=buffer[4];
freemem(data);
close_qsnapshot;
end;

//Main
procedure reset_spaceinv;
begin
 z80_0.reset;
 frame_main:=z80_0.tframes;
 reset_video;
 reset_audio;
 shift_data:=0;
 shift_count:=0;
 sound1:=0;
 sound2:=0;
 marcade.in0:=0;
 marcade.in1:=9;
end;

function iniciar_spaceinv:boolean;
var
  colores:tpaleta;
begin
iniciar_spaceinv:=false;
llamadas_maquina.bucle_general:=spaceinv_principal;
llamadas_maquina.reset:=reset_spaceinv;
llamadas_maquina.fps_max:=59.541985;
llamadas_maquina.save_qsnap:=spaceinv_qsave;
llamadas_maquina.load_qsnap:=spaceinv_qload;
iniciar_audio(false);
screen_init(1,256,256);
iniciar_video(224,256);
//Main CPU
z80_0:=cpu_z80.create(1996800,262);
z80_0.change_io_calls(spaceinv_inbyte,spaceinv_outbyte);
z80_0.change_ram_calls(spaceinv_getbyte,spaceinv_putbyte);
//cargar roms
if not(roms_load(@memoria,spaceinv_rom)) then exit;
//Sound
if (load_samples(spaceinv_samples)) then z80_0.init_sound(spaceinv_sound_update);
//DIP
marcade.dswa:=0;
marcade.dswa_val2:=@spaceinv_dip;
colores[0].r:=0;
colores[0].g:=0;
colores[0].b:=0;
colores[1].r:=255;
colores[1].g:=255;
colores[1].b:=255;
colores[2].r:=0;
colores[2].g:=255;
colores[2].b:=0;
colores[3].r:=255;
colores[3].g:=0;
colores[3].b:=0;
set_pal(colores,4);
//final
reset_spaceinv;
iniciar_spaceinv:=true;
end;

end.
