unit gnw_510;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     sm510,main_engine,controls_engine,rom_engine,
     sound_engine,timer_engine,gnw_video,gfx_engine,pal_engine,graphics;

procedure cargar_gnw_510;

implementation
uses principal;

type
  tupdate_video=procedure;

const
        gnw_jr55_rom:tipo_roms=(n:'jr55_cms54c_kms560';l:$1000;p:$0;crc:$46aed0ae);
        gnw_dj101_rom:tipo_roms=(n:'dj101';l:$1000;p:$0;crc:$8dcfb5d1);

var
  input_lines,input_mux,speaker,sample_num:byte;
  lcd_output_cache:array[0..$ff] of byte;
  lcd_enabled:array[0..3,0..$f,0..3] of boolean;
  lcd_video_data:array[0..$ff] of pword;
  draw_video:boolean;
  final_y:word;
  update_video:tupdate_video;

procedure update_video_dkong_jr;
var
  punt:pword;
  row,seg,h:byte;
  y:byte;
begin
actualiza_trozo(0,0,430,292,1,0,0,430,292,2);
for row:=0 to 3 do begin
  for seg:=0 to 15 do begin
      for h:=0 to 3 do begin
         if (lcd_enabled[row,seg,h] and (lcd_video_data[gnw_dkongjr_video[row,seg,h].id]<>nil)) then begin
            punt:=lcd_video_data[gnw_dkongjr_video[row,seg,h].id];
            for y:=0 to (gnw_dkongjr_video[row,seg,h].size_y-1) do begin
              copymemory(punbuf,punt,gnw_dkongjr_video[row,seg,h].size_x*2);
              putpixel(0,y,gnw_dkongjr_video[row,seg,h].size_x,punbuf,3);
              inc(punt,gnw_dkongjr_video[row,seg,h].size_x);
            end;
            actualiza_trozo(0,0,gnw_dkongjr_video[row,seg,h].size_x,gnw_dkongjr_video[row,seg,h].size_y,3,gnw_dkongjr_video[row,seg,h].pos_x+4,gnw_dkongjr_video[row,seg,h].pos_y+12,gnw_dkongjr_video[row,seg,h].size_x,gnw_dkongjr_video[row,seg,h].size_y,2);
         end;
      end;
  end;
end;
end;

procedure update_video_dkong2;
var
  punt:pword;
  row,seg,h:byte;
  y:byte;
begin
actualiza_trozo(0,0,430,583,1,0,0,430,583,2);
for row:=0 to 3 do begin
  for seg:=0 to 15 do begin
      for h:=0 to 3 do begin
         if (lcd_enabled[row,seg,h] and (lcd_video_data[gnw_dkong2_video[row,seg,h].id]<>nil)) then begin
            punt:=lcd_video_data[gnw_dkong2_video[row,seg,h].id];
            for y:=0 to (gnw_dkong2_video[row,seg,h].size_y-1) do begin
              copymemory(punbuf,punt,gnw_dkong2_video[row,seg,h].size_x*2);
              putpixel(0,y,gnw_dkong2_video[row,seg,h].size_x,punbuf,3);
              inc(punt,gnw_dkong2_video[row,seg,h].size_x);
            end;                                                                                                                                                                 //20
            actualiza_trozo(0,0,gnw_dkong2_video[row,seg,h].size_x,gnw_dkong2_video[row,seg,h].size_y,3,gnw_dkong2_video[row,seg,h].pos_x+10,gnw_dkong2_video[row,seg,h].pos_y+7,gnw_dkong2_video[row,seg,h].size_x,gnw_dkong2_video[row,seg,h].size_y,2);
         end;
      end;
  end;
end;
end;

procedure lcd_segment_w(offset:byte;valor:word);
var
  seg,state:byte;
  index:dword;
begin
	for seg:=0 to $f do begin
		index:=(offset shl 4) or seg;
		state:=(valor shr seg) and 1;
    lcd_enabled[offset shr 2,seg,offset and 3]:=(state=1);
		if (state<>lcd_output_cache[index]) then begin
			// output to row.seg.H, where:
			// row = row a/b/bs/c (0/1/2/3) (offset shr 2)
			// seg = seg 1-16 (0-15) (seg)
			// H = H1-H4 (0-3) (offset and 3)
			lcd_output_cache[index]:=state;
      draw_video:=true;
		end;
	end;
end;

function read_inputs(cols:byte):byte;
var
  f,ret:byte;
begin
ret:=0;
for f:=0 to (cols-1) do begin
  if ((input_mux shr f) and 1)<>0 then begin
    case f of
         0:ret:=marcade.in0;
         1:ret:=marcade.in1;
         2:ret:=marcade.in2;
    end;
  end;
end;
read_inputs:=ret;
end;

procedure update_k_line;
begin
   // this is necessary because the MCU can wake up on K input activity
   if read_inputs(input_lines)<>0 then sm510_0.set_input_line(SM510_INPUT_LINE_K,ASSERT_LINE)
      else sm510_0.set_input_line(SM510_INPUT_LINE_K,CLEAR_LINE);
end;

procedure eventos_gnw_510;
begin
if event.arcade then begin
  //IN0
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 or $8) else marcade.in0:=(marcade.in0 and $f7);
  //IN1
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 or $1) else marcade.in1:=(marcade.in1 and $fe);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 or $2) else marcade.in1:=(marcade.in1 and $fd);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 or $4) else marcade.in1:=(marcade.in1 and $fb);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 or $8) else marcade.in1:=(marcade.in1 and $f7);
  //IN2
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 or $1) else marcade.in2:=(marcade.in2 and $fe);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 or $2) else marcade.in2:=(marcade.in2 and $fd);
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 or $4) else marcade.in2:=(marcade.in2 and $fb);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 or $8) else marcade.in2:=(marcade.in2 and $f7);
  update_k_line;
end;
end;

procedure speaker_level(valor:byte);
begin
  speaker:=valor and 1;
end;

procedure input_w(valor:byte);
begin
  input_mux:=valor;
  update_k_line;
end;

function input_r:byte;
begin
  input_r:=read_inputs(input_lines);
end;

procedure gnw_510_principal;
var
  frame_m:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=sm510_0.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to 255 do begin
    //Main CPU
    sm510_0.run(frame_m);
    frame_m:=frame_m+sm510_0.tframes-sm510_0.contador;
  end;
  if draw_video then begin
      update_video;
      draw_video:=false;
  end;
  actualiza_trozo_final(0,0,430,final_y,2);
  eventos_gnw_510;
  video_sync;
end;
end;

procedure gnw_sound;
begin
  tsample[sample_num,sound_status.posicion_sonido]:=speaker*$7fff;
end;

procedure reset_gnw_510;
begin
 sm510_0.reset;
 marcade.in0:=0;
 marcade.in1:=0;
 marcade.in2:=0;
 speaker:=0;
 input_mux:=0;
 fillchar(lcd_output_cache,$100,0);
 fillchar(lcd_enabled[0,0,0],$100,0);
end;

function iniciar_gnw_510:boolean;
var
  punt,punt2:pword;
  f,g:word;
  row,seg,h:byte;
begin
iniciar_gnw_510:=false;
iniciar_audio(false);
//Main CPU
sm510_0:=cpu_sm510.Create(32768,SM_510,256);
sm510_0.change_io_calls(nil,input_r,input_w,speaker_level,lcd_segment_w,lcd_segment_w,lcd_segment_w,lcd_segment_w);
//Sound
sm510_0.init_sound(gnw_sound);
sample_num:=init_channel;
case main_vars.tipo_maquina of
  2000:begin  //Donkey Kong Jr.
          screen_init(1,430,292);
          screen_init(2,430,292,false,true);
          screen_init(3,70,70,true);
          iniciar_video(430,292);
          input_lines:=3;
          final_y:=292;
          update_video:=update_video_dkong_jr;
          //if not(roms_load(sm510_0.get_rom_addr,@gnw_jr55_rom,'gnw_jr55.zip',sizeof(gnw_jr55_rom))) then exit;
          if not(roms_load(sm510_0.get_rom_addr,@gnw_dj101_rom,'gnw_dj101.zip',sizeof(gnw_dj101_rom))) then exit;
          //Copiar el fondo al surface 1...
          for f:=0 to 291 do begin
              punt:=gnw_video_form.dkong_jr_back.Picture.Bitmap.ScanLine[f];
              putpixel(0,f,430,punt,1);
          end;
          //Convierto todos los graficos
          for row:=0 to 3 do begin
            for seg:=0 to 15 do begin
              for h:=0 to 3 do begin
                  if (gnw_dkongjr_video[row,seg,h].size_y<>0) then begin
                      //Limpiar la imagen y poner el formato de pixel 16bits
                      gnw_video_form.image2.Picture:=nil;
                      gnw_video_form.image2.Picture.Bitmap.PixelFormat:=pf16bit;
                      gnw_video_form.dkong_jr_images.getbitmap(gnw_dkongjr_video[row,seg,h].id,gnw_video_form.image2.Picture.Bitmap);
                      getmem(lcd_video_data[gnw_dkongjr_video[row,seg,h].id],gnw_dkongjr_video[row,seg,h].size_x*gnw_dkongjr_video[row,seg,h].size_y*2);
                      punt:=lcd_video_data[gnw_dkongjr_video[row,seg,h].id];
                      for f:=0 to (gnw_dkongjr_video[row,seg,h].size_y-1) do begin
                        punt2:=gnw_video_form.image2.Picture.Bitmap.ScanLine[f];
                        for g:=0 to (gnw_dkongjr_video[row,seg,h].size_x-1) do begin
                          if punt2^=$ffff then punt^:=set_trans_color
                            else punt^:=punt2^;
                          inc(punt2);
                          inc(punt);
                        end;
                      end;
                  end;
              end;
            end;
          end;
  end;
  2001:begin  //Donkey Kong II
          screen_init(1,430,583);
          screen_init(2,430,583,false,true);
          screen_init(3,112,112,true);
          iniciar_video(430,583);
          input_lines:=3;
          final_y:=583;
          update_video:=update_video_dkong2;
          if not(roms_load(sm510_0.get_rom_addr,@gnw_jr55_rom,'gnw_jr55.zip',sizeof(gnw_jr55_rom))) then exit;
          //Copiar el fondo al surface 1...
          for f:=0 to 582 do begin
              punt:=gnw_video_form.dkong2_back.Picture.Bitmap.ScanLine[f];
              putpixel(0,f,430,punt,1);
          end;
          //Convierto todos los graficos
          for row:=0 to 3 do begin
            for seg:=0 to 15 do begin
              for h:=0 to 3 do begin
                  if (gnw_dkong2_video[row,seg,h].size_y<>0) then begin
                      //Limpiar la imagen y poner el formato de pixel 16bits
                      gnw_video_form.image2.Picture:=nil;
                      gnw_video_form.image2.Picture.Bitmap.PixelFormat:=pf16bit;
                      gnw_video_form.dkong2_images.getbitmap(gnw_dkong2_video[row,seg,h].id,gnw_video_form.image2.Picture.Bitmap);
                      getmem(lcd_video_data[gnw_dkong2_video[row,seg,h].id],gnw_dkong2_video[row,seg,h].size_x*gnw_dkong2_video[row,seg,h].size_y*2);
                      punt:=lcd_video_data[gnw_dkong2_video[row,seg,h].id];
                      for f:=0 to (gnw_dkong2_video[row,seg,h].size_y-1) do begin
                        punt2:=gnw_video_form.image2.Picture.Bitmap.ScanLine[f];
                        for g:=0 to (gnw_dkong2_video[row,seg,h].size_x-1) do begin
                          if punt2^=$ffff then punt^:=set_trans_color
                            else punt^:=punt2^;
                          inc(punt2);
                          inc(punt);
                        end;
                      end;
                  end;
              end;
            end;
          end;
  end;
end;
reset_gnw_510;
iniciar_gnw_510:=true;
end;

procedure close_gnw_510;
var
  f:byte;
begin
  for f:=0 to $ff do if lcd_video_data[f]<>nil then begin
      freemem(lcd_video_data[f]);
      lcd_video_data[f]:=nil;
  end;
end;

procedure cargar_gnw_510;
begin
llamadas_maquina.iniciar:=iniciar_gnw_510;
llamadas_maquina.bucle_general:=gnw_510_principal;
llamadas_maquina.reset:=reset_gnw_510;
llamadas_maquina.close:=close_gnw_510;
llamadas_maquina.fps_max:=50;
end;

end.
