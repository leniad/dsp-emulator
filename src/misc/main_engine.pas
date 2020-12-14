unit main_engine;

interface
uses lib_sdl2,{$IFDEF windows}windows,{$else}LCLType,{$endif}
     {$ifndef fpc}uchild,{$endif}
     controls,forms,sysutils,misc_functions,pal_engine,sound_engine,
     gfx_engine,arcade_config,vars_hide,device_functions,timer_engine;

const
        DSP_VERSION='0.18b3';
        PANT_SPRITES=20;
        PANT_DOBLE=21;
        PANT_AUX=22;
        PANT_TEMP=23;
        PANT_SPRITES_ALPHA=24;
        MAX_PANT_VISIBLE=19;
        MAX_PANT_SPRITES=256;

        MAX_DIP_VALUES=$f;
        MAX_PUNBUF=768;
        SCREEN_DIF=20;
        //Cpu lines
        CLEAR_LINE=0;
        ASSERT_LINE=1;
        HOLD_LINE=2;
        PULSE_LINE=3;
        ALREADY_RESET=4;
        IRQ_DELAY=5;
        INPUT_LINE_NMI=$20;

type
        TMain_vars=record
            mensaje_principal,cadena_dir,caption:string;
            frames_sec,tipo_maquina:word;
            idioma:integer;
            vactual:byte;
            service1,driver_ok,auto_exec,show_crc_error,center_screen,x11:boolean;
        end;
        TDirectory=record
            Base:string;
            Nes:string;
            GameBoy:string;
            Chip8:string;
            sms:string;
            sg1000:string;
            gg:string;
            //Coleco
            coleco_snap:string;
            //Dirs Arcade
            Arcade_hi:string;
            Arcade_samples:string;
            Arcade_nvram:string;
            arcade_list_roms:array[0..$ff] of string;
            //Dirs spectrum
            spectrum_48:string;
            spectrum_128:string;
            spectrum_3:string;
            spectrum_tap_snap:string;
            spectrum_disk:string;
            spectrum_image:string;
            //Dirs amstrad
            amstrad_tap:string;
            amstrad_disk:string;
            amstrad_snap:string;
            amstrad_rom:string;
            //Dirs C64
            c64_tap:string;
            c64_disk:string;
            //Misc
            Preview:string;
            qsnapshot:string;
        end;
        tllamadas_globales = record
           iniciar,cintas,cartuchos:function:boolean;
           bucle_general,reset,close,grabar_snapshot,configurar,acepta_config:procedure;
           caption,open_file:string;
           fps_max:single;
           save_qsnap,load_qsnap:procedure(nombre:string);
           end;
        tmain_screen=record
          video_mode,old_video_mode:byte;
          flip_main_screen,flip_main_x,flip_main_y,rot90_screen,rol90_screen,pantalla_completa,rapido:boolean;
        end;
        def_dip_value=record
          dip_val:word;
          dip_name:string;
        end;
        def_dip=record
          mask:word;
          name:string;
          number:byte;
          dip:array[0..MAX_DIP_VALUES] of def_dip_value;
        end;
        pdef_dip=^def_dip;
        TEmuStatus=(EsPause, EsRuning, EsStoped);

//Video
procedure iniciar_video(x,y:word;alpha:boolean=false);
procedure close_video;
procedure cambiar_video;
procedure pasar_pantalla_completa;
procedure screen_init(num:byte;x,y:word;trans:boolean=false;final_mix:boolean=false);
procedure screen_mod_scroll(num:byte;long_x,max_x,mask_x,long_y,max_y,mask_y:word);
procedure screen_mod_sprites(num:byte;sprite_end_x,sprite_end_y,sprite_mask_x,sprite_mask_y:word);
//Update final screen
procedure actualiza_trozo(o_x1,o_y1,o_x2,o_y2:word;sitio:byte;d_x1,d_y1,d_x2,d_y2:word;dest:byte);
procedure actualiza_trozo_final(o_x1,o_y1,o_x2,o_y2:word;sitio:byte);
procedure actualiza_trozo_simple(o_x1,o_y1,o_x2,o_y2:word;sitio:byte);
procedure flip_surface(pant:byte;flipx,flipy:boolean);
procedure video_sync;
//misc
procedure change_caption;
procedure reset_dsp;
//Multidirs
function find_rom_multiple_dirs(rom_name:string):byte;
procedure split_dirs(dir:string);
function get_all_dirs:string;
{$ifndef windows}
//linux misc
procedure copymemory(dest,source:pointer;size:integer);
{$endif}

var
        //video
        pantalla:array[0..max_pantalla] of libsdlP_Surface;
        window_render:libsdlp_Window;
        punbuf:pword;
        punbuf_alpha:pdword;
        main_screen:tmain_screen;
        //Misc
        llamadas_maquina:tllamadas_globales;
        main_vars:TMain_vars;
        Directory:TDirectory;
        {$ifndef fpc}
        cont_sincroniza,cont_micro:int64;
        valor_sync:single;
        {$else}
        cont_sincroniza:dword;
        cont_micro,valor_sync:single;
        {$endif}
        EmuStatus,EmuStatusTemp:TEmuStatus;
        //Basic memory...
        memoria,mem_snd,mem_misc:array[0..$ffff] of byte;

implementation
uses principal,controls_engine,cpu_misc,tap_tzx;

function find_rom_multiple_dirs(rom_name:string):byte;
var
  f,long:byte;
begin
for f:=0 to $ff do begin
    if directory.arcade_list_roms[f]='' then begin
       long:=f-1;
       break;
    end;
end;
for f:=0 to long do begin
  if fileexists(directory.arcade_list_roms[f]+rom_name) then begin
    find_rom_multiple_dirs:=f;
    exit;
  end;
end;
//Not found
find_rom_multiple_dirs:=0;
end;

function test_dir(cadena:string):string;
var
   f:word;
begin
    for f:=length(cadena) downto 1 do
       if cadena[f]<>main_vars.cadena_dir then break;
    test_dir:=system.copy(cadena,1,f);
end;

procedure split_dirs(dir:string);
var
   f,long,old_pos:word;
   total:byte;
begin
//Limpio todos los directorios
for f:=0 to $ff do if directory.arcade_list_roms[f]<>'' then directory.arcade_list_roms[f]:='';
//Check de vacio...
if dir='' then begin
   directory.arcade_list_roms[0]:=directory.Base+'roms'+main_vars.cadena_dir;
   exit;
end;
//Divido el directorio
long:=1;
total:=0;
old_pos:=1;
for f:=1 to length(dir) do begin
    if dir[f]=';' then begin
       directory.arcade_list_roms[total]:=test_dir(copy(dir,old_pos,long-1))+main_vars.cadena_dir;
       long:=1;
       total:=total+1;
       old_pos:=f+1;
    end else long:=long+1;
end;
long:=long-1;
//Comprobar si he llegado al final y debo pasarlo
if long<>0 then directory.arcade_list_roms[total]:=test_dir(copy(dir,old_pos,long))+main_vars.cadena_dir;
end;

function get_all_dirs:string;
var
   f:byte;
   res:string;
begin
res:='';
for f:=0 to $ff do begin
    if directory.arcade_list_roms[f]='' then break;
    res:=res+test_dir(directory.arcade_list_roms[f])+';';
end;
get_all_dirs:=res;
end;

procedure cambiar_video;
//Si el sistema usa la pantalla SDL arreglos visuales
procedure uses_sdl_window;
begin
case main_vars.tipo_maquina of
     0..9,1000..1003,3000:begin
             fix_screen_pos(400,120);
             principal1.Panel2.width:=400;
             principal1.Panel2.height:=55;
             {principal1.Panel2.Align:=alLeft;
             principal1.Panel2.Anchors:=[akTop,akLeft,akRight];
             principal1.BitBtn1.top:=2;
             principal1.BitBtn1.left:=55;
             principal1.BitBtn9.top:=2;
             principal1.BitBtn9.left:=104;
             principal1.BitBtn10.top:=2;
             principal1.BitBtn10.left:=153;
             principal1.BitBtn11.top:=2;
             principal1.BitBtn11.left:=203;
             principal1.BitBtn12.top:=2;
             principal1.BitBtn12.left:=253;
             principal1.BitBtn14.top:=2;
             principal1.BitBtn14.left:=303;}
          end;
     else fix_screen_pos(350,70);
end;
end;

var
  x,y:word;
begin
x:=p_final[0].x*mul_video;
y:=p_final[0].y*mul_video;
principal1.n1x1.Checked:=false;
principal1.n2x1.Checked:=false;
principal1.scanlines1.Checked:=false;
principal1.scanlines2x1.Checked:=false;
principal1.n3x1.Checked:=false;
principal1.FullScreen1.Checked:=false;
case main_screen.video_mode of
  1:principal1.n1x1.Checked:=true;
  2:principal1.n2x1.Checked:=true;
  3:principal1.scanlines1.Checked:=true;
  4:principal1.scanlines2x1.Checked:=true;
  5:principal1.n3x1.Checked:=true;
  6:principal1.FullScreen1.checked:=true;
end;
{$ifdef fpc}
//En linux uso la pantalla de SDL...
uses_sdl_window;
{$else}
child.clientWidth:=x;
child.clientHeight:=y;
x:=child.width;
if x<310 then x:=310;
case main_vars.tipo_maquina of
  10..999:x:=x+10;
    else x:=x+60;
end;
fix_screen_pos(x,child.height+70);
if principal1.Panel2.visible then x:=x-60;
child.Left:=(x-child.width) div 2;
{$endif}
//pongo el nombre de la maquina...
change_caption;
if main_vars.center_screen then begin
  principal1.Left:=(screen.Width div 2)-(principal1.Width div 2);
  principal1.Top:=(screen.Height div 2)-(principal1.Height div 2);
end;
SDL_SetWindowSize(window_render,x,y);
if pantalla[0]<>nil then SDL_FreeSurface(pantalla[0]);
pantalla[0]:=SDL_GetWindowSurface(window_render);
//Si el video el *2 necesito una temporal
if pantalla[PANT_DOBLE]<>nil then SDL_FreeSurface(pantalla[PANT_DOBLE]);
pantalla[PANT_DOBLE]:=SDL_CreateRGBSurface(0,x*3,y*3,16,0,0,0,0);
end;

procedure iniciar_video(x,y:word;alpha:boolean=false);
var
  f:word;
  {$ifndef fpc}
  handle_:integer;
  {$endif}
begin
//Puntero general del pixels
getmem(punbuf,MAX_PUNBUF);
//creo la pantalla general
if main_screen.rot90_screen or main_screen.rol90_screen then begin
    p_final[0].x:=y;
    p_final[0].y:=x;
end else begin
    p_final[0].x:=x;
    p_final[0].y:=y;
end;
{$ifndef fpc}
handle_:=child.Handle;
if window_render=nil then window_render:=SDL_CreateWindowFrom(pointer(handle_));
{$else}
if window_render=nil then window_render:=SDL_CreateWindow('',libSDL_WINDOWPOS_UNDEFINED,libSDL_WINDOWPOS_UNDEFINED,x,y,0);
{$endif}
cambiar_video;
pantalla[PANT_TEMP]:=SDL_CreateRGBSurface(0,p_final[0].x,p_final[0].y,16,0,0,0,0);
//Creo la pantalla de los sprites
if alpha then begin
  pantalla[PANT_SPRITES_ALPHA]:=SDL_CreateRGBSurface(0,MAX_PANT_SPRITES,MAX_PANT_SPRITES,32,$ff,$ff00,$ff0000,$ff000000);
  getmem(punbuf_alpha,MAX_PUNBUF*2);
end;
pantalla[PANT_SPRITES]:=SDL_CreateRGBSurface(0,MAX_PANT_SPRITES,MAX_PANT_SPRITES,16,0,0,0,0);
SDL_Setcolorkey(pantalla[PANT_SPRITES],1,SET_TRANS_COLOR);
paleta[MAX_COLORES]:=SET_TRANS_COLOR;
//Pantallas restantes
for f:=1 to MAX_PANT_VISIBLE do
  if p_final[f].x<>0 then begin
    if p_final[f].final_mix then begin
        if p_final[f].sprite_end_x=0 then p_final[f].sprite_end_x:=p_final[f].x;
      if p_final[f].sprite_mask_x=0 then p_final[f].sprite_mask_x:=p_final[f].x-1;
      if p_final[f].sprite_end_y=0 then p_final[f].sprite_end_y:=p_final[f].y;
      if p_final[f].sprite_mask_y=0 then p_final[f].sprite_mask_y:=p_final[f].y-1;
      p_final[f].x:=p_final[f].x+(ADD_SPRITE*2);
      p_final[f].y:=p_final[f].y+(ADD_SPRITE*2);
    end;
    if p_final[f].scroll.mask_x=0 then p_final[f].scroll.mask_x:=$ffff;
    if p_final[f].scroll.mask_y=0 then p_final[f].scroll.mask_y:=$ffff;
    pantalla[f]:=SDL_CreateRGBSurface(0,p_final[f].x,p_final[f].y,16,0,0,0,0);
    //Y si son transparentes las creo
    if p_final[f].trans then SDL_Setcolorkey(pantalla[f],1,SET_TRANS_COLOR);
end;
sdl_showcursor(0);
end;

//funciones de creacion de pantallas de video
procedure screen_init(num:byte;x,y:word;trans:boolean=false;final_mix:boolean=false);
begin
  p_final[num].x:=x;
  p_final[num].y:=y;
  p_final[num].trans:=trans;
  p_final[num].final_mix:=final_mix;
end;

procedure screen_mod_scroll(num:byte;long_x,max_x,mask_x,long_y,max_y,mask_y:word);
begin
  p_final[num].scroll.long_x:=long_x;
  p_final[num].scroll.max_x:=max_x;
  p_final[num].scroll.mask_x:=mask_x;
  p_final[num].scroll.long_y:=long_y;
  p_final[num].scroll.max_y:=max_y;
  p_final[num].scroll.mask_y:=mask_y;
end;

procedure screen_mod_sprites(num:byte;sprite_end_x,sprite_end_y,sprite_mask_x,sprite_mask_y:word);
begin
  p_final[num].sprite_end_x:=sprite_end_x;
  p_final[num].sprite_end_y:=sprite_end_y;
  p_final[num].sprite_mask_x:=sprite_mask_x;
  p_final[num].sprite_mask_y:=sprite_mask_y;
end;

procedure pasar_pantalla_completa;
{$ifndef fpc}
var
  handle_:integer;
{$endif}
begin
if not(main_screen.pantalla_completa) then begin
  main_screen.old_video_mode:=main_screen.video_mode;
  main_screen.video_mode:=6;
  principal1.n1x1.Checked:=false;
  principal1.n2x1.Checked:=false;
  principal1.scanlines1.Checked:=false;
  principal1.scanlines2x1.Checked:=false;
  principal1.n3x1.Checked:=false;
  principal1.FullScreen1.Checked:=true;
  SDL_FreeSurface(pantalla[0]);
  SDL_DestroyWindow(window_render);
  window_render:=SDL_CreateWindow('',libSDL_WINDOWPOS_UNDEFINED,libSDL_WINDOWPOS_UNDEFINED,p_final[0].x,p_final[0].y,libSDL_WINDOW_FULLSCREEN);
  main_screen.pantalla_completa:=true;
end else begin
  main_screen.video_mode:=main_screen.old_video_mode;
  SDL_FreeSurface(pantalla[0]);
  SDL_DestroyWindow(window_render);
  {$ifndef fpc}
  Child:=TfrChild.Create(application);
  child.Left:=0;
  child.Top:=0;
  handle_:=child.Handle;
  window_render:=SDL_CreateWindowFrom(pointer(handle_));
  {$else}
  window_render:=SDL_CreateWindow('',libSDL_WINDOWPOS_UNDEFINED,libSDL_WINDOWPOS_UNDEFINED,p_final[0].x,p_final[0].y,0);
  {$endif}
  cambiar_video;
  main_screen.pantalla_completa:=false;
end;
pantalla[0]:=SDL_GetWindowSurface(window_render);
end;

procedure close_video;
var
  h:byte;
  f:word;
begin
//reseterar todas las variables
for h:=0 to (MAX_GFX-1) do begin
    if gfx[h].datos<>nil then freemem(gfx[h].datos);
    gfx[h].datos:=nil;
end;
for f:=0 to max_pantalla do begin
  if pantalla[f]<>nil then SDL_FreeSurface(pantalla[f]);
  pantalla[f]:=nil;
  fillchar(p_final[f],sizeof(tpantalla),0);
end;
if punbuf<>nil then freemem(punbuf);
if punbuf_alpha<>nil then freemem(punbuf_alpha);
punbuf:=nil;
punbuf_alpha:=nil;
end;

procedure actualiza_trozo_simple(o_x1,o_y1,o_x2,o_y2:word;sitio:byte);inline;
var
  origen:libsdl_rect;
  y,x:word;
  porig,pdest:pword;
  orig_p,dest_p:dword;
begin
if main_screen.rot90_screen then begin
  //Muevo desde la normal a la final rotada
  orig_p:=pantalla[sitio].pitch shr 1;  //Cantidad de bytes por fila
  dest_p:=pantalla[PANT_TEMP].pitch shr 1; //Cantidad de bytes por fila
  for y:=0 to (o_y2-1) do begin
    //Origen
    porig:=pantalla[sitio].pixels; //Apunto a los pixels
    inc(porig,((y+o_y1)*orig_p)+o_x1); //Muevo el puntero al primer punto de la linea y le añado el recorte
    //Destino
    pdest:=pantalla[PANT_TEMP].pixels; //Apunto a los pixels
    inc(pdest,dest_p-(y+1));  //Muevo el cursor al ultimo punto de la columna
    for x:=0 to (o_x2-1) do begin
      //Pongo el pixel
      pdest^:=porig^;
      //Avanzo en la fila de origen
      inc(porig);
      //Avanzo la columna de origen
      inc(pdest,dest_p);
    end;
  end;
end else begin
    origen.x:=o_x1;
    origen.y:=o_y1;
    origen.w:=o_x2;
    origen.h:=o_y2;
    SDL_UpperBlit(pantalla[sitio],@origen,pantalla[PANT_TEMP],@origen);
end;
end;

procedure actualiza_trozo(o_x1,o_y1,o_x2,o_y2:word;sitio:byte;d_x1,d_y1,d_x2,d_y2:word;dest:byte);inline;
var
  origen,destino:libsdl_rect;
begin
origen.x:=o_x1;
origen.y:=o_y1;
origen.w:=o_x2;
origen.h:=o_y2;
destino.x:=d_x1;
destino.y:=d_y1;
destino.w:=d_x2;
destino.h:=d_y2;
if p_final[dest].final_mix then begin
  destino.x:=destino.x+ADD_SPRITE;
  destino.y:=destino.y+ADD_SPRITE;
end;
SDL_UpperBlit(pantalla[sitio],@origen,pantalla[dest],@destino);
end;

procedure actualiza_trozo_final(o_x1,o_y1,o_x2,o_y2:word;sitio:byte);inline;
var
  origen,destino:libsdl_rect;
  y,x:word;
  porig,pdest:pword;
  orig_p,dest_p:dword;
begin
if main_screen.rot90_screen then begin
  //Muevo desde la normal a la final rotada
  orig_p:=pantalla[sitio].pitch shr 1;  //Cantidad de bytes por fila
  dest_p:=pantalla[PANT_TEMP].pitch shr 1; //Cantidad de bytes por fila
  for y:=0 to (o_y2-1) do begin
    //Origen
    porig:=pantalla[sitio].pixels; //Apunto a los pixels
    inc(porig,((y+o_y1+ADD_SPRITE)*orig_p)+o_x1+ADD_SPRITE); //Muevo el puntero al primer punto de la linea y le añado el recorte
    //Destino
    pdest:=pantalla[PANT_TEMP].pixels; //Apunto a los pixels
    inc(pdest,dest_p-(y+1));  //Muevo el cursor al ultimo punto de la columna
    for x:=0 to (o_x2-1) do begin
      //Pongo el pixel
      pdest^:=porig^;
      //Avanzo en la fila de origen
      inc(porig);
      //Avanzo la columna de origen
      inc(pdest,dest_p);
    end;
  end;
end else if main_screen.rol90_screen then begin
             //Muevo desde la normal a la final rotada
             orig_p:=pantalla[sitio].pitch shr 1;  //Cantidad de bytes por fila
             dest_p:=pantalla[PANT_TEMP].pitch shr 1; //Cantidad de bytes por fila
             for y:=0 to (o_y2-1) do begin
                 //Origen
                 porig:=pantalla[sitio].pixels; //Apunto a los pixels
                 inc(porig,((y+o_y1+ADD_SPRITE)*orig_p)+o_x1+ADD_SPRITE); //Muevo el puntero al primer punto de la linea y le añado el recorte
                 //Destino
                 pdest:=pantalla[PANT_TEMP].pixels; //Apunto a los pixels
                 inc(pdest,(dest_p*(pantalla[PANT_TEMP].h-1))+y);  //Muevo el cursor al ultimo punto de la columna
                 for x:=0 to (o_x2-1) do begin
                     //Pongo el pixel
                     pdest^:=porig^;
                     //Avanzo en la fila de origen
                     inc(porig);
                     //Avanzo la columna de origen
                     dec(pdest,dest_p);
                 end;
             end;
         end else begin
           origen.x:=o_x1+ADD_SPRITE;
           origen.y:=o_y1+ADD_SPRITE;
           origen.w:=o_x2;
           origen.h:=o_y2;
           destino.x:=0;
           destino.y:=0;
           destino.w:=pantalla[PANT_TEMP].w;
           destino.h:=pantalla[PANT_TEMP].h;
           SDL_UpperBlit(pantalla[sitio],@origen,pantalla[PANT_TEMP],@destino);
         end;
end;

procedure flip_surface(pant:byte;flipx,flipy:boolean);
var
  f,i,h:word;
  punt,punt2:pword;
  origen:libsdl_rect;
begin
origen.x:=0;
origen.y:=0;
origen.w:=p_final[pant].x;
origen.h:=p_final[pant].y;
if (flipx and flipy) then begin
  h:=0;
  for i:=p_final[pant].y-1 downto 0 do begin
    punt:=pantalla[pant].pixels;
    inc(punt,(i*pantalla[pant].pitch) shr 1);
    punt2:=pantalla[PANT_DOBLE].pixels;
    inc(punt2,((h*pantalla[PANT_DOBLE].pitch) shr 1)+(p_final[pant].x-1));
    h:=h+1;
    for f:=p_final[pant].x-1 downto 0 do begin
      punt2^:=punt^;
      inc(punt);
      dec(punt2);
    end;
  end;
  SDL_UpperBlit(pantalla[PANT_DOBLE],@origen,pantalla[pant],@origen);
end else if flipx then begin
            for i:=0 to p_final[pant].y-1 do begin
              punt:=pantalla[pant].pixels;
              inc(punt,(i*pantalla[pant].pitch) shr 1);
              punt2:=pantalla[PANT_DOBLE].pixels;
              inc(punt2,((i*pantalla[PANT_DOBLE].pitch) shr 1)+(p_final[pant].x)-1);
              for f:=p_final[pant].x-1 downto 0 do begin
                punt2^:=punt^;
                inc(punt);
                dec(punt2);
              end;
            end;
            SDL_UpperBlit(pantalla[PANT_DOBLE],@origen,pantalla[pant],@origen);
         end else if flipy then begin
                      h:=0;
                      for i:=p_final[pant].y-1 downto 0 do begin
                        punt:=pantalla[pant].pixels;
                        inc(punt,(i*pantalla[pant].pitch) shr 1);
                        punt2:=pantalla[PANT_DOBLE].pixels;
                        inc(punt2,(h*pantalla[PANT_DOBLE].pitch) shr 1);
                        h:=h+1;
                        for f:=0 to p_final[pant].x-1 do begin
                          punt2^:=punt^;
                          inc(punt);
                          inc(punt2);
                        end;
                      end;
                      SDL_UpperBlit(pantalla[PANT_DOBLE],@origen,pantalla[pant],@origen);
                  end;
end;

procedure actualiza_video;
var
  punt,punt2,punt3,punt4:pword;
  f,i,h,pant_final:word;
  origen:libsdl_rect;
begin
origen.x:=0;
origen.y:=0;
if main_screen.flip_main_screen then begin
  h:=0;
  for i:=p_final[0].y-1 downto 0 do begin
    punt:=pantalla[PANT_TEMP].pixels;
    inc(punt,(i*pantalla[PANT_TEMP].pitch) shr 1);
    punt2:=pantalla[PANT_DOBLE].pixels;
    inc(punt2,((h*pantalla[PANT_DOBLE].pitch) shr 1)+(p_final[0].x-1));
    h:=h+1;
    for f:=p_final[0].x-1 downto 0 do begin
      punt2^:=punt^;
      inc(punt);
      dec(punt2);
    end;
  end;
  origen.w:=p_final[0].x;
  origen.h:=p_final[0].y;
  SDL_UpperBlit(pantalla[PANT_DOBLE],@origen,pantalla[PANT_TEMP],@origen);
end else if main_screen.flip_main_x then begin
            for i:=0 to p_final[0].y-1 do begin
              punt:=pantalla[PANT_TEMP].pixels;
              inc(punt,(i*pantalla[PANT_TEMP].pitch) shr 1);
              punt2:=pantalla[PANT_DOBLE].pixels;
              inc(punt2,((i*pantalla[PANT_DOBLE].pitch) shr 1)+(p_final[0].x-1));
              for f:=p_final[0].x-1 downto 0 do begin
                punt2^:=punt^;
                inc(punt);
                dec(punt2);
              end;
            end;
            origen.w:=p_final[0].x;
            origen.h:=p_final[0].y;
            SDL_UpperBlit(pantalla[PANT_DOBLE],@origen,pantalla[PANT_TEMP],@origen);
         end else if main_screen.flip_main_y then begin
                      h:=0;
                      for i:=p_final[0].y-1 downto 0 do begin
                        punt:=pantalla[PANT_TEMP].pixels;
                        inc(punt,(i*pantalla[PANT_TEMP].pitch) shr 1);
                        punt2:=pantalla[PANT_DOBLE].pixels;
                        inc(punt2,(h*pantalla[PANT_DOBLE].pitch) shr 1);
                        h:=h+1;
                        for f:=0 to p_final[0].x-1 do begin
                          punt2^:=punt^;
                          inc(punt);
                          inc(punt2);
                        end;
                      end;
                      origen.w:=p_final[0].x;
                      origen.h:=p_final[0].y;
                      SDL_UpperBlit(pantalla[PANT_DOBLE],@origen,pantalla[PANT_TEMP],@origen);
                  end;
case main_screen.video_mode of
  0:exit;
  1,6:begin
      origen.w:=pantalla[PANT_TEMP].w;
      origen.h:=pantalla[PANT_TEMP].h;
      pant_final:=PANT_TEMP;
    end;
  2:begin
        for i:=0 to p_final[0].y-1 do begin
          punt:=pantalla[PANT_TEMP].pixels;
          inc(punt,(i*pantalla[PANT_TEMP].pitch) shr 1);
          punt2:=pantalla[PANT_DOBLE].pixels;
          inc(punt2,((i*2)*pantalla[PANT_DOBLE].pitch) shr 1);
          punt3:=pantalla[PANT_DOBLE].pixels;
          inc(punt3,(((i*2)+1)*pantalla[PANT_DOBLE].pitch) shr 1);
          for f:=0 to p_final[0].x-1 do begin
              punt2^:=punt^;
              punt3^:=punt^;
              inc(punt2);
              inc(punt3);
              punt2^:=punt^;
              punt3^:=punt^;
              inc(punt2);
              inc(punt3);
              inc(punt);
          end;
       end;
       origen.w:=p_final[0].x*2;
       origen.h:=p_final[0].y*2;
       pant_final:=PANT_DOBLE;
    end;
  3:begin
        for i:=0 to ((p_final[0].y-1) shr 1) do begin
           punt:=pantalla[PANT_TEMP].pixels;
           inc(punt,((i*2)* pantalla[PANT_TEMP].pitch) shr 1);
           punt2:=pantalla[PANT_DOBLE].pixels;
           inc(punt2,((i*2)*pantalla[PANT_DOBLE].pitch) shr 1);
           copymemory(punt2,punt,p_final[0].x*2);
        end;
        origen.w:=p_final[0].x;
        origen.h:=p_final[0].y;
        pant_final:=PANT_DOBLE;
        end;
  4:begin
        for i:=0 to p_final[0].y-1 do begin
           punt:=pantalla[PANT_TEMP].pixels;
           inc(punt,(i*pantalla[PANT_TEMP].pitch) shr 1);
           punt2:=pantalla[PANT_DOBLE].pixels;
           inc(punt2,((i*2)*pantalla[PANT_DOBLE].pitch) shr 1);
           for f:=0 to p_final[0].x-1 do begin
              punt2^:=punt^;
              inc(punt2);
              punt2^:=punt^;
              inc(punt2);
              inc(punt);
           end;
        end;
        origen.w:=p_final[0].x*2;
        origen.h:=p_final[0].y*2;
        pant_final:=PANT_DOBLE;
    end;
  5:begin
        for i:=0 to p_final[0].y-1 do begin
           punt:=pantalla[PANT_TEMP].pixels;
           inc(punt,(i*pantalla[PANT_TEMP].pitch) shr 1);
           punt2:=pantalla[PANT_DOBLE].pixels;
           inc(punt2,((i*3)*pantalla[PANT_DOBLE].pitch) shr 1);
           punt3:=pantalla[PANT_DOBLE].pixels;
           inc(punt3,(((i*3)+1)*pantalla[PANT_DOBLE].pitch) shr 1);
           punt4:=pantalla[PANT_DOBLE].pixels;
           inc(punt4,(((i*3)+2)*pantalla[PANT_DOBLE].pitch) shr 1);
           for f:=0 to p_final[0].x-1 do begin
              for h:=0 to 2 do begin
                punt2^:=punt^;
                punt3^:=punt^;
                punt4^:=punt^;
                inc(punt2);
                inc(punt3);
                inc(punt4);
              end;
              inc(punt);
           end;
        end;
        origen.w:=p_final[0].x*3;
        origen.h:=p_final[0].y*3;
        pant_final:=PANT_DOBLE;
        end;
  end;
SDL_UpperBlit(pantalla[pant_final],@origen,pantalla[0],@origen);
SDL_UpdateWindowSurface(window_render);
end;

procedure change_caption;
var
  cadena:ansistring;
begin
if llamadas_maquina.open_file='' then cadena:=llamadas_maquina.caption
  else cadena:=llamadas_maquina.caption+' - '+llamadas_maquina.open_file;
{$IFnDEF fpc}
child.Caption:=cadena;
{$Else}
SDL_SetWindowTitle(window_render,pointer(cadena));
{$endif}
end;

procedure video_sync;
var
{$ifndef fpc}
  l2:int64;
  res:single;
{$else}
  res:dword;
{$endif}
begin
actualiza_video;
evalue_controls;
main_vars.frames_sec:=main_vars.frames_sec+1;
{$ifndef fpc}
if main_screen.rapido then exit;
QueryPerformanceCounter(l2);
res:=(l2-cont_sincroniza);
while (res<valor_sync) do begin
  QueryPerformanceCounter(l2);
  res:=(l2-cont_sincroniza);
end;
QueryPerformanceCounter(cont_sincroniza);
{$else}
application.ProcessMessages;
if main_screen.rapido then exit;
res:=0;
while res<valor_sync do res:=sdl_getticks()-cont_sincroniza;
valor_sync:=cont_micro-(res-valor_sync);
cont_sincroniza:=sdl_getticks();
{$endif}
end;

{$ifndef windows}
procedure copymemory(dest,source:pointer;size:integer);inline;
begin
move(source^,dest^,size);
end;
{$endif}

procedure reset_dsp;
begin
fillchar(paleta[0],max_colores*2,0);
fillchar(memoria[0],$10000,0);
fillchar(mem_snd[0],$10000,0);
fillchar(buffer_paleta[0],max_colores*2,1);
cpu_main_reset;
llamadas_maquina.cartuchos:=nil;
llamadas_maquina.cintas:=nil;
llamadas_maquina.grabar_snapshot:=nil;
llamadas_maquina.cintas:=nil;
llamadas_maquina.iniciar:=nil;
llamadas_maquina.reset:=nil;
llamadas_maquina.close:=nil;
llamadas_maquina.bucle_general:=nil;
llamadas_maquina.configurar:=nil;
llamadas_maquina.acepta_config:=nil;
llamadas_maquina.save_qsnap:=nil;
llamadas_maquina.load_qsnap:=nil;
if ((main_vars.tipo_maquina>9) and (main_vars.tipo_maquina<1000)) then llamadas_maquina.configurar:=arcade_config.activate_arcade_config
  else llamadas_maquina.configurar:=nil;
llamadas_maquina.acepta_config:=nil;
llamadas_maquina.bucle_general:=nil;
llamadas_maquina.fps_max:=60;
llamadas_maquina.open_file:='';
main_vars.vactual:=0;
main_vars.mensaje_principal:='';
main_vars.service1:=false;
main_vars.frames_sec:=0;
sound_status.canales_usados:=-1;
principal1.timer1.Enabled:=false;
main_screen.rot90_screen:=false;
main_screen.rol90_screen:=false;
main_screen.flip_main_screen:=false;
main_screen.flip_main_x:=false;
main_screen.flip_main_y:=false;
main_screen.rapido:=false;
close_all_devices;
cinta_tzx.tape_stop:=nil;
cinta_tzx.tape_start:=nil;
hide_mouse_cursor;
timers.clear;
marcade.dswa_val:=nil;
marcade.dswb_val:=nil;
marcade.dswc_val:=nil;
{$ifndef windows}
cont_sincroniza:=sdl_getticks();
{$endif}
close_audio;
close_video;
end;

end.
