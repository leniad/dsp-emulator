unit main_engine;

interface
uses lib_sdl2,{$IFDEF windows}windows,{$else}LCLType,{$endif}
     {$ifndef fpc}uchild,{$endif}
     controls,forms,sysutils,misc_functions,pal_engine,sound_engine,
     gfx_engine,arcade_config,vars_hide,device_functions,timer_engine;

const
        dsp_version='0.17b1';
        pant_sprites=20;
        pant_doble=21;
        pant_temp=23;
        pant_sprites_alpha=24;
        max_pant_visible=19;
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
        TDirectory=Record
            Base:string;
            Nes:String;
            GameBoy:String;
            Chip8:String;
            sms:String;
            //Coleco
            coleco_snap:String;
            //Dirs Arcade
            Arcade_roms:String;
            Arcade_hi:string;
            Arcade_samples:string;
            Arcade_nvram:string;
            //Dirs spectrum
            spectrum_48:String;
            spectrum_128:String;
            spectrum_3:string;
            spectrum_tap_snap:string;
            spectrum_disk:string;
            spectrum_image:string;
            //Dirs amstrad
            amstrad_tap:string;
            amstrad_disk:string;
            amstrad_snap:string;
            amstrad_rom:string;
            //Misc
            Preview:String;
            qsnapshot:string;
        end;
        tllamadas_globales = record
           iniciar,cintas,cartuchos:function:boolean;
           bucle_general,reset,close,grabar_snapshot,configurar,acepta_config:procedure;
           caption,open_file:string;
           fps_max:single;
           velocidad_cpu:dword;
           save_qsnap,load_qsnap:procedure(nombre:string);
           end;
        tmain_screen=record
          video_mode,old_video_mode:byte;
          flip_main_screen,rot90_screen,rol90_screen,pantalla_completa,rapido:boolean;
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
procedure video_sync;
//misc
procedure change_caption;
procedure reset_dsp;
//linux misc
{$ifndef windows}
procedure copymemory(dest,source:pointer;size:integer);
{$endif}

var
        //video
        pantalla:array[0..max_pantalla] of libsdlP_Surface;
        window_render:libsdlp_Window;
        punbuf,tpunbuf:pword;
        punbuf_alpha,tpunbuf_alpha:pdword;
        main_screen:tmain_screen;
        //Misc
        llamadas_maquina:tllamadas_globales;
        main_vars:TMain_vars;
        Directory:TDirectory;
        //CPU
        cpu_quantity:byte;
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
uses principal,controls_engine;

procedure cambiar_video;
//Si el sistema usa la pantalla SDL arreglos visuales
procedure uses_sdl_window;
begin
case main_vars.tipo_maquina of
     0..9,1000..1003:begin
             fix_screen_pos(350,110);
             principal1.Panel2.width:=350;
             principal1.Panel2.height:=49;
             principal1.Panel2.Align:=alLeft;
             principal1.Panel2.Anchors:=[akTop,akLeft,akRight];
             principal1.BitBtn1.top:=4;
             principal1.BitBtn1.left:=22;
             principal1.BitBtn9.top:=4;
             principal1.BitBtn9.left:=64;
             principal1.BitBtn10.top:=4;
             principal1.BitBtn10.left:=106;
             principal1.BitBtn11.top:=4;
             principal1.BitBtn11.left:=151;
             principal1.BitBtn12.top:=4;
             principal1.BitBtn12.left:=199;
             principal1.BitBtn14.top:=4;
             principal1.BitBtn14.left:=246;
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
//Si el video el *2 necesito una temporal
if pantalla[pant_doble]<>nil then SDL_FreeSurface(pantalla[pant_doble]);
pantalla[pant_doble]:=SDL_CreateRGBSurface(0,x,y,16,0,0,0,0);
{$ifdef fpc}
//En linux uso la pantalla de SDL...
uses_sdl_window;
{$else}
child.clientWidth:=x;
child.clientHeight:=y;
x:=child.width;
case main_vars.tipo_maquina of
  10..999:begin
               if x<260 then x:=260;
               x:=x+10;
          end;
    else begin
              if x<260 then x:=260;
              x:=x+60;
         end;
end;
fix_screen_pos(x,child.height+60);
if principal1.Panel2.visible then x:=x-60;
child.Left:=(x-child.width) div 2;
{$endif}
//pongo el nombre de la maquina...
change_caption;
if main_vars.center_screen then begin
  principal1.Left:=(screen.Width div 2)-(principal1.ClientWidth div 2);
  principal1.Top:=(screen.Height div 2)-(principal1.ClientHeight div 2);
end;
SDL_SetWindowSize(window_render,x,y);
if pantalla[0]<>nil then SDL_FreeSurface(pantalla[0]);
pantalla[0]:=SDL_GetWindowSurface(window_render);
end;

procedure iniciar_video(x,y:word;alpha:boolean=false);
var
  f:word;
  {$ifndef fpc}
  handle_:integer;
  {$endif}
begin
if SDL_WasInit(libSDL_INIT_VIDEO)=0 then
  if (SDL_init(libSDL_INIT_VIDEO or libSDL_INIT_JOYSTICK or libSDL_INIT_NOPARACHUTE or libSDL_INIT_AUDIO)<0) then halt(0);
//Puntero general del pixels
getmem(punbuf,MAX_PUNBUF);
getmem(tpunbuf,MAX_PUNBUF);
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
pantalla[pant_temp]:=SDL_CreateRGBSurface(0,p_final[0].x,p_final[0].y,16,0,0,0,0);
//Creo la pantalla de los sprites
if alpha then begin
  pantalla[pant_sprites_alpha]:=SDL_CreateRGBSurface(0,MAX_PANT_SPRITES,MAX_PANT_SPRITES,32,$ff,$ff00,$ff0000,$ff000000);
  getmem(punbuf_alpha,MAX_PUNBUF*2);
  getmem(tpunbuf_alpha,MAX_PUNBUF*2);
end;
pantalla[pant_sprites]:=SDL_CreateRGBSurface(0,MAX_PANT_SPRITES,MAX_PANT_SPRITES,16,0,0,0,0);
SDL_Setcolorkey(pantalla[pant_sprites],1,set_trans_color);
paleta[max_colores]:=set_trans_color;
//Pantallas restantes
for f:=1 to max_pant_visible do
  if p_final[f].x<>0 then begin
    if p_final[f].final_mix then begin
      if p_final[f].sprite_end_x=0 then p_final[f].sprite_end_x:=p_final[f].x;
      if p_final[f].sprite_mask_x=0 then p_final[f].sprite_mask_x:=p_final[f].x-1;
      if p_final[f].sprite_end_y=0 then p_final[f].sprite_end_y:=p_final[f].y;
      if p_final[f].sprite_mask_y=0 then p_final[f].sprite_mask_y:=p_final[f].y-1;
      p_final[f].x:=p_final[f].x+(ADD_SPRITE*2);
      p_final[f].y:=p_final[f].y+(ADD_SPRITE*2);
    end;
    pantalla[f]:=SDL_CreateRGBSurface(0,p_final[f].x,p_final[f].y,16,0,0,0,0);
    //Y si son transparentes las creo
    if p_final[f].trans then SDL_Setcolorkey(pantalla[f],1,set_trans_color);
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
if tpunbuf<>nil then freemem(tpunbuf);
if punbuf_alpha<>nil then freemem(punbuf_alpha);
if tpunbuf_alpha<>nil then freemem(tpunbuf_alpha);
punbuf:=nil;
tpunbuf:=nil;
punbuf_alpha:=nil;
tpunbuf_alpha:=nil;
end;

procedure actualiza_trozo_simple(o_x1,o_y1,o_x2,o_y2:word;sitio:byte);inline;
var
  origen:libsdl_rect;
begin
origen.x:=o_x1;
origen.y:=o_y1;
origen.w:=o_x2;
origen.h:=o_y2;
SDL_UpperBlit(pantalla[sitio],@origen,pantalla[pant_temp],@origen);
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
  dest_p:=pantalla[pant_temp].pitch shr 1; //Cantidad de bytes por fila
  for y:=0 to (o_y2-1) do begin
    //Origen
    porig:=pantalla[sitio].pixels; //Apunto a los pixels
    inc(porig,((y+o_y1+ADD_SPRITE)*orig_p)+o_x1+ADD_SPRITE); //Muevo el puntero al primer punto de la linea y le añado el recorte
    //Destino
    pdest:=pantalla[pant_temp].pixels; //Apunto a los pixels
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
             dest_p:=pantalla[pant_temp].pitch shr 1; //Cantidad de bytes por fila
             for y:=0 to (o_y2-1) do begin
                 //Origen
                 porig:=pantalla[sitio].pixels; //Apunto a los pixels
                 inc(porig,((y+o_y1+ADD_SPRITE)*orig_p)+o_x1+ADD_SPRITE); //Muevo el puntero al primer punto de la linea y le añado el recorte
                 //Destino
                 pdest:=pantalla[pant_temp].pixels; //Apunto a los pixels
                 inc(pdest,(dest_p*(pantalla[pant_temp].h-1))+y);  //Muevo el cursor al ultimo punto de la columna
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
           destino.w:=pantalla[pant_temp].w;
           destino.h:=pantalla[pant_temp].h;
           SDL_UpperBlit(pantalla[sitio],@origen,pantalla[pant_temp],@destino);
         end;
end;

procedure actualiza_video;
var
  punt,punt2,punt3,punt4:pword;
  f,i,h:word;
  origen:libsdl_rect;
begin
origen.x:=0;
origen.y:=0;
if main_screen.flip_main_screen then begin
  h:=0;
  for i:=p_final[0].y-1 downto 0 do begin
    punt:=pantalla[pant_temp].pixels;
    inc(punt,(i*pantalla[pant_temp].pitch) shr 1);
    punt2:=pantalla[pant_doble].pixels;
    inc(punt2,((h*pantalla[pant_doble].pitch) shr 1)+(p_final[0].x-1));
    h:=h+1;
    for f:=p_final[0].x-1 downto 0 do begin
      punt2^:=punt^;
      inc(punt);
      dec(punt2);
    end;
  end;
  origen.w:=p_final[0].x;
  origen.h:=p_final[0].y;
  SDL_UpperBlit(pantalla[pant_doble],@origen,pantalla[pant_temp],@origen);
end;
case main_screen.video_mode of
  1,6:begin
      origen.w:=pantalla[pant_temp].w;
      origen.h:=pantalla[pant_temp].h;
      SDL_UpperBlit(pantalla[pant_temp],@origen,pantalla[0],@origen);
    end;
  2:begin
        for i:=0 to p_final[0].y-1 do begin
          punt:=pantalla[pant_temp].pixels;
          inc(punt,(i*pantalla[pant_temp].pitch) shr 1);
          punt2:=pantalla[pant_doble].pixels;
          inc(punt2,((i*2)*pantalla[pant_doble].pitch) shr 1);
          punt3:=pantalla[pant_doble].pixels;
          inc(punt3,(((i*2)+1)*pantalla[pant_doble].pitch) shr 1);
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
       SDL_UpperBlit(pantalla[pant_doble],@origen,pantalla[0],@origen);
    end;
  3:begin
        for i:=0 to ((p_final[0].y-1) shr 1) do begin
           punt:=pantalla[pant_temp].pixels;
           inc(punt,((i*2)* pantalla[pant_temp].pitch) shr 1);
           punt2:=pantalla[pant_doble].pixels;
           inc(punt2,((i*2)*pantalla[pant_doble].pitch) shr 1);
           copymemory(punt2,punt,p_final[0].x*2);
        end;
        actualiza_trozo(0,0,p_final[0].x,p_final[0].y,pant_doble,0,0,p_final[0].x,p_final[0].y,0);
        end;
  4:begin
        for i:=0 to p_final[0].y-1 do begin
           punt:=pantalla[pant_temp].pixels;
           inc(punt,(i*pantalla[pant_temp].pitch) shr 1);
           punt2:=pantalla[pant_doble].pixels;
           inc(punt2,((i*2)*pantalla[pant_doble].pitch) shr 1);
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
        SDL_UpperBlit(pantalla[pant_doble],@origen,pantalla[0],@origen);
    end;
  5:begin
        for i:=0 to p_final[0].y-1 do begin
           punt:=pantalla[pant_temp].pixels;
           inc(punt,(i*pantalla[pant_temp].pitch) shr 1);
           punt2:=pantalla[pant_doble].pixels;
           inc(punt2,((i*3)*pantalla[pant_doble].pitch) shr 1);
           punt3:=pantalla[pant_doble].pixels;
           inc(punt3,(((i*3)+1)*pantalla[pant_doble].pitch) shr 1);
           punt4:=pantalla[pant_doble].pixels;
           inc(punt4,(((i*3)+2)*pantalla[pant_doble].pitch) shr 1);
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
        SDL_UpperBlit(pantalla[pant_doble],@origen,pantalla[0],@origen);
        end;
  end;
SDL_UpdateWindowSurface(window_render);
end;

procedure change_caption;
var
  cadena:string;
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
if main_screen.rapido then exit;
{$ifndef fpc}
QueryPerformanceCounter(l2);
res:=(l2-cont_sincroniza);
while (res<valor_sync) do begin
  QueryPerformanceCounter(l2);
  res:=(l2-cont_sincroniza);
end;
QueryPerformanceCounter(cont_sincroniza);
{$else}
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
cpu_quantity:=0;
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
sound_status.canales_usados:=-1;
principal1.timer1.Enabled:=false;
main_screen.rot90_screen:=false;
main_screen.rol90_screen:=false;
main_screen.flip_main_screen:=false;
main_screen.rapido:=false;
close_all_devices;
reset_timer;
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
