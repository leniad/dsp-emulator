unit principal_misc;

interface
uses {$IFDEF windows}windows,{$else}LCLType,{$endif}principal,main_engine,
     file_engine,sound_engine,init_games,controls_engine,timer_engine,tap_tzx,
     lib_sdl2,tape_window,lenslock,sysutils,forms,lenguaje,misc_functions,
     {$ifndef fpc}gifimg,jpeg,pngimage,{$endif}vars_hide,graphics;

procedure principal_timer3;
procedure principal_formclose;
function principal_cambiarmaquina(tipo:word):word;
procedure principal_formcreate;
procedure principal_fSaveGif;

implementation

procedure principal_timer3;
begin
principal1.timer3.Enabled:=false;
if main_vars.driver_ok then begin
  if (@llamadas_maquina.close<>nil) then llamadas_maquina.close;
  file_ini_save_dip;
end;
sound_engine_close;
main_vars.tipo_maquina:=tipo_new;
reset_dsp;
cargar_maquina(main_vars.tipo_maquina);
main_vars.driver_ok:=false;
if @llamadas_maquina.iniciar<>nil then main_vars.driver_ok:=llamadas_maquina.iniciar;
if not(main_vars.driver_ok) then begin
  EmuStatus:=EsStoped;
  principal1.timer1.Enabled:=false;
  principal1.BitBtn1.Enabled:=false;
  principal1.BitBtn2.Enabled:=false;
  principal1.BitBtn3.Enabled:=false;
  principal1.BitBtn5.Enabled:=false;
  principal1.BitBtn6.Enabled:=false;
  principal1.BitBtn8.Enabled:=false;
  principal1.BitBtn9.Enabled:=false;
  principal1.BitBtn10.Enabled:=false;
  principal1.BitBtn11.Enabled:=false;
  principal1.BitBtn12.Enabled:=false;
  principal1.BitBtn14.Enabled:=false;
  principal1.BitBtn19.Enabled:=false;
end else begin
  if ((marcade.dswa_val=nil) and (length(marcade.dipsw_a)=0) and (length(marcade.dipsw_b)=0) and (length(marcade.dipsw_c)=0)) then principal1.bitbtn8.Enabled:=false
    else principal1.bitbtn8.Enabled:=true;
  timers.autofire_init;
  principal1.BitBtn3.Glyph:=nil;
  principal1.imagelist2.GetBitmap(6,principal1.BitBtn3.Glyph);
  principal1.timer1.Enabled:=true;
  EmuStatus:=EsRunning;
end;
end;

procedure principal_formclose;
begin
principal1.timer1.Enabled:=false;
EmuStatus:=EsStoped;
if cinta_tzx.cargada then vaciar_cintas;
if main_vars.driver_ok then begin
  if (@llamadas_maquina.close<>nil) then llamadas_maquina.close;
  file_ini_save_dip;
end;
sound_engine_close;
reset_dsp;
file_ini_save;
close_joystick;
sdl_videoquit;
sdl_quit;
close_sdl_lib;
end;

function principal_cambiarmaquina(tipo:word):word;
begin
if main_vars.tipo_maquina<>tipo then begin
  menus_false(tipo);
  if tipo>9 then begin
    if tape_window1.Showing then tape_window1.close;
    if lenslock1.Showing then lenslock1.close;
  end;
  //Pongo la emulacion en pausa para que terminen todos los procesos, y luego ejecuto el timer3 para cambio de driver
  if main_vars.driver_ok then EmuStatus:=EsPause;
  principal1.timer3.Enabled:=true;
  principal_cambiarmaquina:=tipo;
end;
end;

procedure principal_formcreate;
begin
Init_sdl_lib;
timers:=timer_eng.create;
EmuStatus:=EsStoped;
file_ini_load;
if not DirectoryExists(Directory.Preview) then CreateDir(Directory.Preview);
if not DirectoryExists(Directory.Arcade_nvram) then CreateDir(Directory.Arcade_nvram);
if not DirectoryExists(directory.qsnapshot) then CreateDir(directory.qsnapshot);
{$ifndef fpc}
fix_screen_pos(415,325);
{$endif}
case main_screen.video_mode of
  1,3,5:begin
        principal1.Left:=(screen.Width div 2)-(principal1.Width div 2);
        principal1.Top:=(screen.Height div 2)-(principal1.Height div 2);
      end;
  2,4:begin
        principal1.Left:=(screen.Width div 2)-principal1.Width;
        principal1.Top:=(screen.Height div 2)-principal1.Height;
      end;
end;
//No puedo evitar este timer... Hasta que no está creada la ventana de la aplicacion no puedo crear la ventana interior
principal1.timer2.Enabled:=true;
cambiar_idioma;
principal_idioma;
end;

procedure principal_fSaveGif;
var
  r:integer;
  nombre:string;
  indice:byte;
  nombre2:ansistring;
  rect2:libsdl_rect;
  temp_s:libsdlP_Surface;
  gif:tgifimage;
  {$ifndef fpc}
  png:TPngImage;
  {$else if}
  png:TPortableNetworkGraphic;
  {$endif}
  JPG:TJPEGImage;
  imagen1:tbitmap;
begin
estado_actual:=EmuStatus;
EmuStatus:=EsPause;
if saverom(nombre,indice,SBITMAP) then begin
  case indice of
    1:nombre:=ChangeFileExt(nombre,'.png');
    2:nombre:=ChangeFileExt(nombre,'.jpg');
    3:nombre:=ChangeFileExt(nombre,'.gif');
  end;
  if FileExists(nombre) then begin
    {$ifdef windows}
    r:=MessageBox(0,pointer(leng.mensajes[3]), pointer(leng.mensajes[6]), MB_YESNO or MB_ICONWARNING);
    {$else if}
    r:=application.MessageBox(pointer(leng.mensajes[3]), pointer(leng.mensajes[6]), MB_YESNO or MB_ICONWARNING);
    {$endif}
    if r=IDNO then exit;
    deletefile(nombre);
  end;
  Directory.spectrum_image:=ExtractFilePath(nombre);
  rect2.x:=0;
  rect2.y:=0;
  case main_screen.video_mode of
      1,3:begin
            rect2.w:=p_final[0].x;
            rect2.h:=p_final[0].y;
          end;
      2,4:begin
            rect2.w:=p_final[0].x*2;
            rect2.h:=p_final[0].y*2;
          end;
      5:begin
            rect2.w:=p_final[0].x*3;
            rect2.h:=p_final[0].y*3;
          end;
  end;
  temp_s:=SDL_CreateRGBSurface(0,rect2.w,rect2.h,16,0,0,0,0);
  SDL_UpperBlit(pantalla[0],@rect2,temp_s,@rect2);
  nombre2:=directory.Base+'temp.bmp';
  SDL_SaveBMP_RW(temp_s,SDL_RWFromFile(pointer(nombre2),'wb'), 1);
  SDL_FreeSurface(temp_s);
  imagen1:=tbitmap.Create;
  imagen1.LoadFromFile(nombre2);
  deletefile(nombre2);
  case indice of
    {$ifndef fpc}
    1:begin //png
         PNG:=TPngImage.Create;
         PNG.Assign(imagen1);
         PNG.SaveToFile(nombre);
         PNG.free;
      end;
    2:begin //jpg
         jpg:=TJPEGImage.Create;
         jpg.Assign(imagen1);
         jpg.SaveToFile(nombre);
         jpg.free;
      end;
    3:begin
        gif:=tgifimage.create;
        gif.assign(imagen1);
        gif.Optimize([ooMerge, ooCleanup, ooColorMap], rmNone, dmNearest,8);
        gif.SaveToFile(nombre);
        gif.free;
    end;
    {$else if}
    1:begin //png
         PNG:=TPortableNetworkGraphic.Create;
         PNG.Assign(imagen1);
         PNG.SaveToFile(nombre);
         PNG.free;
      end;
    2:begin //jpg
         jpg:=TJPEGImage.Create;
         jpg.Assign(imagen1);
         jpg.SaveToFile(nombre);
         jpg.free;
      end;
    3:begin
        gif:=tgifimage.create;
        gif.assign(imagen1);
        gif.SaveToFile(nombre);
        gif.free;
    end;
    {$endif}
  end;
  imagen1.Free;
end;
end;

end.
