unit main_engine;

interface
uses lib_sdl2,{$IFDEF windows}windows,{$else}LCLType,{$endif}
     {$ifndef fpc}uchild,{$endif}
     controls,forms,sysutils,misc_functions,pal_engine,timer_engine,
     gfx_engine,sound_engine,arcade_config,vars_hide;

const
        {$ifndef fpc}
        dsp_version='0.16ß1WIP';
        {$else}
        dsp_version='0.16b1WIP';
        {$endif}

        pant_sprites=20;
        pant_doble=21;
        pant_rot=22;
        pant_temp=23;
        max_pant_visible=19;

        CLEAR_LINE=0;
        ASSERT_LINE=1;
        HOLD_LINE=2;
        PULSE_LINE=3;
        ALREADY_RESET=4;
        IRQ_DELAY=5;
        INPUT_LINE_NMI=$20;

        MAX_DIP_VALUES=$f;

        MAX_PUNBUF=768;

type
        tgetbyte=function (direccion:word):byte;
        tputbyte=procedure (direccion:word;valor:byte);
        tgetbyte16=function (direccion:dword):byte;
        tputbyte16=procedure (direccion:dword;valor:byte);
        tgetword=function (direccion:dword):word;
        tputword=procedure (direccion:dword;valor:word);
        tdespues_instruccion=procedure (tstates:word);
        cpu_inport_call=function:byte;
        cpu_outport_call=procedure (valor:byte);
        cpu_inport_call16=function:word;
        cpu_outport_call16=procedure (valor:word);
        cpu_inport_full=function(puerto:word):byte;
        cpu_outport_full=procedure (valor:byte;puerto:word);
        cpu_inport_full16=function(puerto:word):word;
        cpu_outport_full16=procedure (valor:word;puerto:word);
        cpu_class=class
          public
            //Llamadas a RAM
            getbyte:tgetbyte;
            putbyte:tputbyte;
            despues_instruccion:tdespues_instruccion;
            //Misc
            clock:dword;
            contador:integer;
            opcode:boolean;
            numero_cpu,pedir_halt,pedir_reset:byte;
            tframes:single;
            estados_demas:word;
            procedure change_ram_calls(getbyte:tgetbyte;putbyte:tputbyte);
            procedure change_despues_instruccion(despues_instruccion:tdespues_instruccion);
            procedure init_sound(update_call:exec_type);
        end;
        TMain_vars=record
            mensaje_general,cadena_dir:string;
            frames_sec,tipo_maquina:word;
            idioma:integer;
            vactual:byte;
            driver_ok,auto_exec,show_crc_error,lenguaje_ok,center_screen,x11:boolean;
        end;
        TDirectory=Record
            Base:string;
            Nes:String;
            GameBoy:String;
            Chip8:String;
            sms:String;
            //Coleco
            ColecoVision:String;
            Coleco_snap:string;
            //Dirs Arcade
            Arcade_roms:String;
            Arcade_hi:string;
            Arcade_samples:string;
            Arcade_nvram:string;
            //Dirs spectrum
            spectrum_48:String;
            spectrum_128:String;
            spectrum_3:string;
            spectrum_tap:string;
            spectrum_snap:string;
            spectrum_disk:string;
            spectrum_image:string;
            //Dirs amstrad
            amstrad_tap:string;
            amstrad_disk:string;
            amstrad_snap:string;
            //Misc
            Preview:String;
            lenguaje:string;
            qsnapshot:string;
        end;
        tllamadas_globales = record
           iniciar,cintas,cartuchos:function:boolean;
           bucle_general,reset,cerrar,grabar_snapshot,configurar,acepta_config:procedure;
           caption:string;
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
procedure iniciar_video(x,y:word);
procedure close_video;
procedure cambiar_video;
procedure pasar_pantalla_completa;
procedure screen_init(num:byte;x,y:word;trans:boolean=false;final_mix:boolean=false);
procedure screen_mod_scroll(num:byte;long_x,max_x,mask_x,long_y,max_y,mask_y:word);
procedure screen_mod_sprites(num:byte;sprite_end_x,sprite_end_y,sprite_mask_x,sprite_mask_y:word);
procedure screen_0_mod_real(x_real,y_real:word);
//Update final screen
//procedure actualiza_trozo_principal(x1,y1,x2,y2:word);
procedure actualiza_trozo(o_x1,o_y1,o_x2,o_y2:word;sitio:byte;d_x1,d_y1,d_x2,d_y2:word;dest:byte);
procedure actualiza_trozo_final(o_x1,o_y1,o_x2,o_y2:word;sitio:byte);
procedure actualiza_trozo_simple(o_x1,o_y1,o_x2,o_y2:word;sitio:byte);
procedure video_sync;
//misc
procedure change_caption(nombre:string);
procedure reset_dsp;
//linux misc
{$ifndef windows}
procedure copymemory(dest,source:pointer;size:integer);
{$endif}

var
        //video
        pantalla:array[0..max_pantalla] of libsdlP_Surface;
        window_render:libsdlp_Window;
        punbuf:pword;
        main_screen:tmain_screen;
        //Misc
        llamadas_maquina:tllamadas_globales;
        main_vars:TMain_vars;
        Directory:TDirectory;
        //CPU
        cpu_quantity:byte;
        {$ifdef windows}
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

//CPU Calls
procedure cpu_class.change_ram_calls(getbyte:tgetbyte;putbyte:tputbyte);
begin
  self.getbyte:=getbyte;
  self.putbyte:=putbyte;
end;

procedure cpu_class.change_despues_instruccion(despues_instruccion:tdespues_instruccion);
begin
  self.despues_instruccion:=despues_instruccion;
end;

procedure cpu_class.init_sound(update_call:exec_type);
begin
sound_engine_init(self.numero_cpu,self.clock,update_call);
end;

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
             principal1.BitBtn9.top:=4;
             principal1.BitBtn9.left:=24;
             principal1.BitBtn10.top:=4;
             principal1.BitBtn10.left:=66;
             principal1.BitBtn11.top:=4;
             principal1.BitBtn11.left:=111;
             principal1.BitBtn12.top:=4;
             principal1.BitBtn12.left:=159;
             principal1.BitBtn14.top:=4;
             principal1.BitBtn14.left:=206;
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
{$ifndef windows}
//En linux uso la pantalla de SDL...
uses_sdl_window;
{$else}
{$ifdef fpc}
principal1.panel4.Width:=x;
principal1.panel4.Height:=y;
principal1.GroupBox4.Width:=x+15;
principal1.GroupBox4.Height:=y+25;
x:=principal1.GroupBox4.width;
{$else}
child.clientWidth:=x;
child.clientHeight:=y;
x:=child.width;
{$endif}
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
{$ifdef fpc}
fix_screen_pos(x,principal1.groupbox4.height+60);
if principal1.Panel2.visible then x:=x-60;
principal1.groupbox4.Left:=((x-principal1.groupbox4.width) div 2)+3;
principal1.groupbox4.top:=36;
principal1.panel4.top:=0;
principal1.Panel4.Left:=5;
{$else}
fix_screen_pos(x,child.height+60);
if principal1.Panel2.visible then x:=x-60;
child.Left:=(x-child.width) div 2;
{$endif}
{$endif}
//pongo el nombre de la maquina...
change_caption(llamadas_maquina.caption);
if main_vars.center_screen then begin
  principal1.Left:=(screen.Width div 2)-(principal1.ClientWidth div 2);
  principal1.Top:=(screen.Height div 2)-(principal1.ClientHeight div 2);
end;
SDL_SetWindowSize(window_render,x,y);
if pantalla[0]<>nil then SDL_FreeSurface(pantalla[0]);
pantalla[0]:=SDL_GetWindowSurface(window_render);
end;

procedure iniciar_video(x,y:word);
var
  f:word;
  handle_:integer;
begin
if SDL_WasInit(libSDL_INIT_VIDEO)=0 then begin
  {$ifdef windows}
  if (SDL_init(libSDL_INIT_VIDEO or libSDL_INIT_JOYSTICK or libSDL_INIT_NOPARACHUTE)<0) then halt(0);
  {$else}
  if (SDL_init(libSDL_INIT_VIDEO or libSDL_INIT_JOYSTICK or libSDL_INIT_NOPARACHUTE or libSDL_INIT_AUDIO)<0) then halt(0);
  {$endif}
  keystate:=pbyte(SDL_GetKeyboardState(nil));
  SDL_SetHintWithPriority(libSDL_HINT_GRAB_KEYBOARD,'1',libSDL_HINT_OVERRIDE);
end;
//Puntero general del pixels
getmem(punbuf,MAX_PUNBUF);
//creo la pantalla general
p_final[0].x:=x;
p_final[0].y:=y;
{$ifndef fpc}
handle_:=child.Handle;
if window_render=nil then window_render:=SDL_CreateWindowFrom(pointer(handle_));
{$else}
{$ifdef windows}
handle_:=principal1.panel4.Handle;
if window_render=nil then window_render:=SDL_CreateWindowFrom(pointer(handle_));
{$else}
principal1.groupbox4.visible:=false;
if window_render=nil then window_render:=SDL_CreateWindow('',libSDL_WINDOWPOS_UNDEFINED,libSDL_WINDOWPOS_UNDEFINED,x,y,0);
{$endif}
{$endif}
cambiar_video;
pantalla[pant_temp]:=SDL_CreateRGBSurface(0,p_final[0].x,p_final[0].y,16,0,0,0,0);
//Creo la pantalla de los sprites
pantalla[pant_sprites]:=SDL_CreateRGBSurface(0,64,64,16,0,0,0,0);
SDL_Setcolorkey(pantalla[pant_sprites],1,set_trans_color);
paleta[max_colores]:=set_trans_color;
//Pantallas restantes
for f:=1 to max_pant_visible do
  if p_final[f].x<>0 then begin                  //Añado 32 por la derecha y 32 por la izquierda
    if p_final[f].final_mix then begin
      if p_final[f].sprite_end_x=0 then p_final[f].sprite_end_x:=p_final[f].x;
      if p_final[f].sprite_mask_x=0 then p_final[f].sprite_mask_x:=p_final[f].x-1;
      if p_final[f].sprite_end_y=0 then p_final[f].sprite_end_y:=p_final[f].y;
      if p_final[f].sprite_mask_y=0 then p_final[f].sprite_mask_y:=p_final[f].y-1;
      p_final[f].x:=p_final[f].x+(ADD_SPRITE*2);
      p_final[f].y:=p_final[f].y+(ADD_SPRITE*2);
      pantalla[pant_rot]:=SDL_CreateRGBSurface(0,p_final[f].x,p_final[f].y,16,0,0,0,0);
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

procedure screen_0_mod_real(x_real,y_real:word);
begin
  p_final[0].x_real:=x_real;
  p_final[0].y_real:=y_real;
end;

procedure pasar_pantalla_completa;
var
  handle_:integer;
begin
if not(main_screen.pantalla_completa) then begin
  main_screen.old_video_mode:=main_screen.video_mode;
  main_screen.video_mode:=6;
  SDL_FreeSurface(pantalla[0]);
  SDL_DestroyWindow(window_render);
  window_render:=SDL_CreateWindow('',libSDL_WINDOWPOS_UNDEFINED,libSDL_WINDOWPOS_UNDEFINED,p_final[0].x,p_final[0].y,libSDL_WINDOW_FULLSCREEN);
  pantalla[0]:=SDL_GetWindowSurface(window_render);
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
  {$ifdef windows}
  principal1.panel4.visible:=false;
  principal1.panel4.visible:=true;
  handle_:=principal1.panel4.Handle;
  window_render:=SDL_CreateWindowFrom(pointer(handle_));
  {$else}
  principal1.groupbox4.visible:=false;
  window_render:=SDL_CreateWindow('',libSDL_WINDOWPOS_UNDEFINED,libSDL_WINDOWPOS_UNDEFINED,p_final[0].x,p_final[0].y,0);
  {$endif}
  {$endif}
  pantalla[0]:=SDL_GetWindowSurface(window_render);
  cambiar_video;
  main_screen.pantalla_completa:=false;
end;
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
punbuf:=nil;
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
  orig_p,dest_p:word;
begin
if main_screen.rot90_screen then begin
  orig_p:=pantalla[sitio].pitch shr 1;
  dest_p:=pantalla[pant_rot].pitch shr 1;
  for y:=0 to (p_final[0].x_real+(ADD_SPRITE-1)) do begin
    porig:=pantalla[sitio].pixels;
    inc(porig,y*orig_p);
    pdest:=pantalla[pant_rot].pixels;
    inc(pdest,p_final[0].x_real+((ADD_SPRITE*2)-1)-y);
    for x:=0 to (p_final[0].y_real+((ADD_SPRITE*2)-1)) do begin
      pdest^:=porig^;
      inc(porig);
      inc(pdest,dest_p);
    end;
  end;
  sitio:=pant_rot;
  origen.y:=o_x1+ADD_SPRITE;
  origen.x:=o_y1+ADD_SPRITE;
  origen.h:=o_x2;
  origen.w:=o_y2;
end else begin
if main_screen.rol90_screen then begin
  orig_p:=pantalla[sitio].pitch shr 1;
  dest_p:=pantalla[pant_rot].pitch shr 1;
  for y:=0 to (p_final[0].x_real+(ADD_SPRITE-1)) do begin
    porig:=pantalla[sitio].pixels;
    inc(porig,y*orig_p);
    pdest:=pantalla[pant_rot].pixels;
    inc(pdest,(p_final[0].x_real+((ADD_SPRITE*2)-1))*dest_p+y);
    for x:=0 to (p_final[0].y_real+((ADD_SPRITE*2)-1)) do begin
      pdest^:=porig^;
      inc(porig);
      dec(pdest,dest_p);
    end;
  end;
  sitio:=pant_rot;
  origen.y:=o_x1+ADD_SPRITE;
  origen.x:=o_y1+ADD_SPRITE;
  origen.h:=o_x2;
  origen.w:=o_y2;
end else begin
  origen.x:=o_x1+ADD_SPRITE;
  origen.y:=o_y1+ADD_SPRITE;
  origen.w:=o_x2;
  origen.h:=o_y2;
end;
end;
destino.x:=0;
destino.y:=0;
destino.w:=pantalla[pant_temp].w;
destino.h:=pantalla[pant_temp].h;
SDL_UpperBlit(pantalla[sitio],@origen,pantalla[pant_temp],@destino);
end;

procedure actualiza_video;
var
  punt,punt2,punt3,punt4:pword;
  f,i,h:word;
  origen:libsdl_rect;
begin
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
  origen.x:=0;
  origen.y:=0;
  origen.w:=p_final[0].x;
  origen.h:=p_final[0].y;
  SDL_UpperBlit(pantalla[pant_doble],@origen,pantalla[pant_temp],@origen);
end;
case main_screen.video_mode of
  1,6:begin
      origen.x:=0;
      origen.y:=0;
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
       origen.x:=0;
       origen.y:=0;
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
        origen.x:=0;
        origen.y:=0;
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
        origen.x:=0;
        origen.y:=0;
        origen.w:=p_final[0].x*3;
        origen.h:=p_final[0].y*3;
        SDL_UpperBlit(pantalla[pant_doble],@origen,pantalla[0],@origen);
        end;
  end;
SDL_UpdateWindowSurface(window_render);
end;

procedure change_caption(nombre:string);
begin
{$IFnDEF fpc}
child.Caption:=nombre;
{$Else}
{$ifndef windows}
SDL_SetWindowTitle(window_render,pointer(nombre));
{$Else}
principal1.GroupBox4.Caption:=nombre;
{$endif}
{$ENDIF}
end;

{$ifdef windows}
procedure video_sync;
var
        l2:int64;
        res:single;
begin
main_vars.frames_sec:=main_vars.frames_sec+1;
actualiza_video;
evalue_controls;
if main_screen.rapido then exit;
QueryPerformanceCounter(Int64((@l2)^));
res:=(l2-cont_sincroniza);
while (res<valor_sync) do begin
  QueryPerformanceCounter(Int64((@l2)^));
  res:=(l2-cont_sincroniza);
end;
QueryPerformanceCounter(Int64((@cont_sincroniza)^));
end;
{$else}
procedure copymemory(dest,source:pointer;size:integer);inline;
begin
move(source^,dest^,size);
end;

procedure video_sync;inline;
var
  res:dword;
begin
application.ProcessMessages;
main_vars.frames_sec:=main_vars.frames_sec+1;
actualiza_video;
evalue_controls;
if main_screen.rapido then exit;
res:=0;
while res<valor_sync do res:=sdl_getticks()-cont_sincroniza;
valor_sync:=cont_micro-(res-valor_sync);
cont_sincroniza:=sdl_getticks();
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
llamadas_maquina.cerrar:=nil;
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
main_vars.vactual:=0;
main_vars.mensaje_general:='';
sound_status.canales_usados:=-1;
principal1.timer1.Enabled:=false;
main_screen.rot90_screen:=false;
main_screen.rol90_screen:=false;
main_screen.flip_main_screen:=false;
main_screen.rapido:=false;
reset_timer;
marcade.dswa_val:=nil;
marcade.dswb_val:=nil;
marcade.dswc_val:=nil;
{$ifndef windows}
cont_sincroniza:=sdl_getticks();
{$endif}
end;

end.
