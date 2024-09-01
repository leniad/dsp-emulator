unit gb;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}lr35902,file_engine,
     main_engine,controls_engine,gfx_engine,timer_engine,sysutils,gb_sound,
     rom_engine,misc_functions,pal_engine,gb_mappers,sound_engine,
     config_gb,forms;

type
  tgameboy_machine=record
    palette:byte;
    scroll_x,stat,linea_actual,lcd_control,bg_pal,sprt0_pal,sprt1_pal:byte;
    tcontrol,tmodulo,mtimer,prog_timer,ly_compare,window_x,window_y,window_y_draw:byte;
    wram_bank:array[0..7,0..$fff] of byte;
    vram_bank:array[0..1,0..$1fff] of byte;
    io_ram,sprt_ram,bg_prio:array[0..$ff] of byte;
    bios_rom:array[0..$8ff] of byte;
    bgc_pal,spc_pal:array[0..$1f] of word;
    sprites_ord:array[0..9] of byte;
    scroll_y:array[0..$ff] of byte;
    enable_bios,rom_exist,bgcolor_inc,spcolor_inc,lcd_ena,hdma_ena:boolean;
    scroll_y_last,irq_ena,joystick,vram_nbank,wram_nbank,bgcolor_index,spcolor_index:byte;
    scroll_y_pos,dma_src,dma_dst:word;
    unlicensed,is_gbc,oam_dma,haz_dma,hay_nvram:boolean;
    oam_dma_pos,hdma_size,sprites_time:byte;
    joy_val:byte;
  end;

function iniciar_gb:boolean;
procedure gb_change_model(gbc,unlicensed:boolean);
procedure gb_change_timer;

const
  GB_CLOCK=4194304;

var
  gb_0:tgameboy_machine;
  nv_ram_name:string;
  gb_timer:byte;

implementation
uses principal,snapshot;

const
  color_pal:array[0..1,0..3] of tcolor=(
  ((r:$9b;g:$bc;b:$0f),(r:$8b;g:$ac;b:$0f),(r:$30;g:$62;b:$30),(r:$0f;g:$38;b:$0f)),
  ((r:$ff;g:$ff;b:$ff),(r:$aa;g:$aa;b:$aa),(r:$55;g:$55;b:$55),(r:0;g:0;b:0)));
  gb_rom:tipo_roms=(n:'dmg_boot.bin';l:$100;p:0;crc:$59c8598e);
  gbc_rom:array[0..1] of tipo_roms=(
  (n:'gbc_boot.1';l:$100;p:0;crc:$779ea374),(n:'gbc_boot.2';l:$700;p:$200;crc:$f741807d));

type
  tgameboy_calls=record
            read_io:function (direccion:byte):byte;
            write_io:procedure (direccion:byte;valor:byte);
            video_render:procedure;
  end;

var
  gb_calls:tgameboy_calls;

//Por fin lo entiendo! Como renderiza la GB
//Primero el fondo (0 transparente en la segunda pasada), encima window (nunca transparente) y encima sprites (0 transparente)
//Ahora las prioridades --> Si hay window encima del fondo, el fondo pierde la prioridad!
//Por lo que si pinto un sprite encima de window, el sprite tiene prioridad sobre fondo SIEMPRE, da igual las prioridades de despues
//La segunda pasada, para prioridades del fondo y window. Si no hay window debajo del fondo en esta pasada, prioridades normales
//(el 0 es transparente) y machaca sprites. Si hay window no toca nada.
//Para window en la segunda pasada es distinto, no es transparente EXCEPTO si lo que hay debajo es un sprite! Si es un sprite
//lo que hay debajo, el 0 es transparente
//Para acabar, otra pasada de sprites con prioridad maxima, 0 transparente y el resto lo machaca
procedure update_video_gb;
procedure get_active_sprites;
var
  f,h,g,pos_x,size:byte;
  sprites_x:array[0..9] of byte;
  pos_y:integer;
  pos_linea:word;
begin
fillchar(sprites_x[0],10,$ff);
fillchar(gb_0.sprites_ord[0],10,$ff);
gb_0.sprites_time:=0;
for f:=0 to $27 do begin
  pos_y:=gb_0.sprt_ram[$00+(f*4)];
  //Los sprites con y=0 o mayor de 159 no cuentan
  if ((pos_y=0) or (pos_y>=160)) then continue;
  //El parentesis es importante!!
  pos_linea:=gb_0.linea_actual-(pos_y-16);
  size:=8 shl ((gb_0.lcd_control and 4) shr 2);
  //Si el sprite esta en la linea... Lo cuento
  if (pos_linea<size) then begin
    //Los de la X siempre cuentan! Da igual si se salen fuera de la pantalla
    pos_x:=gb_0.sprt_ram[$01+(f*4)];
    //Solo se puenden pintar 10
    for h:=0 to 9 do begin
      //Si la X del sprite es menor los cambio
      if sprites_x[h]>pos_x then begin
          for g:=8 downto h do begin
              sprites_x[g+1]:=sprites_x[g];
              gb_0.sprites_ord[g+1]:=gb_0.sprites_ord[g];
          end;
          sprites_x[h]:=pos_x;
          gb_0.sprites_ord[h]:=f;
          gb_0.sprites_time:=gb_0.sprites_time+8;
          break;
      end;
    end;
  end;
end;
end;

procedure draw_sprites(pri:byte);
var
  flipx,flipy:boolean;
  f,x,pal,atrib,pval,sprite_num:byte;
  num_char,def_y,tile_val1,tile_val2,long_x,main_x:byte;
  pos_linea:word;
  ptemp:pword;
  pos_y,pos_x:integer;
begin
for f:=9 downto 0 do begin
  sprite_num:=gb_0.sprites_ord[f];
  if sprite_num=$ff then continue;
  atrib:=gb_0.sprt_ram[$03+(sprite_num*4)];
  pos_y:=gb_0.sprt_ram[$00+(sprite_num*4)];
  if (atrib and $80)<>pri then continue;
  pos_y:=pos_y-16;
  pos_linea:=gb_0.linea_actual-pos_y;
  pos_x:=gb_0.sprt_ram[$01+(sprite_num*4)];
  if ((pos_x=0) or (pos_x>=168)) then continue;
  pos_x:=pos_x-8;
  pal:=((atrib and $10) shr 2)+4;
  num_char:=gb_0.sprt_ram[$02+(sprite_num*4)];
  flipx:=(atrib and $20)<>0;
  flipy:=(atrib and $40)<>0;
  if (gb_0.lcd_control and 4)=0 then begin //8x8
      if flipy then def_y:=7-(pos_linea and 7)
        else def_y:=pos_linea and 7;
  end else begin //8x16
      if flipy then begin
        def_y:=7-(pos_linea and 7);
        num_char:=(num_char and $fe)+(not(pos_linea shr 3) and 1);
      end else begin
        def_y:=pos_linea and 7;
        num_char:=(num_char and $fe)+(pos_linea shr 3);
      end;
  end;
  ptemp:=punbuf;
  tile_val1:=gb_0.vram_bank[0,num_char*16+(def_y*2)];
  tile_val2:=gb_0.vram_bank[0,num_char*16+1+(def_y*2)];
  if flipx then begin
    for x:=0 to 7 do begin
        pval:=((tile_val1 shr x) and $1)+(((tile_val2 shr x) and $1) shl 1);
        if pval=0 then ptemp^:=paleta[MAX_COLORES]
          else begin
              ptemp^:=paleta[pval+pal];
              gb_0.bg_prio[(pos_x+x) and $ff]:=gb_0.bg_prio[(pos_x+x) and $ff] or 1;
          end;
        inc(ptemp);
    end;
    putpixel(0,0,8,punbuf,PANT_SPRITES);
  end else begin
    for x:=7 downto 0 do begin
        pval:=((tile_val1 shr x) and $1)+(((tile_val2 shr x) and $1) shl 1);
        if pval=0 then ptemp^:=paleta[MAX_COLORES]
          else begin
              gb_0.bg_prio[(pos_x+(7-x)) and $ff]:=gb_0.bg_prio[(pos_x+(7-x)) and $ff] or 1;
              ptemp^:=paleta[pval+pal];
          end;
          inc(ptemp);
    end;
    putpixel(0,0,8,punbuf,PANT_SPRITES);
  end;
  long_x:=8;
  main_x:=0;
  if pos_x<0 then begin
      long_x:=8+pos_x;
      main_x:=abs(pos_x);
      pos_x:=0;
  end;
  if (pos_x+8)>160 then long_x:=160-pos_x;
  actualiza_trozo(main_x,0,long_x,1,PANT_SPRITES,pos_x+7,pos_y+pos_linea,long_x,1,2);
end;
end;

procedure update_bg(prio:byte);
var
  tile_addr,bg_addr:word;
  f,x,tile_val1,tile_val2,y,pval,linea_pant:byte;
  n2:integer;
  tile_mid:boolean;
  ptemp:pword;
begin
  bg_addr:=$1800+((gb_0.lcd_control and $8) shl 7);
  tile_mid:=(gb_0.lcd_control and $10)=0;
  tile_addr:=$1000*byte(tile_mid); //Cuidado! Tiene signo despues
  for f:=0 to 31 do begin
    linea_pant:=gb_0.linea_actual+gb_0.scroll_y[round(f*3.5625)];
    y:=(linea_pant and $7)*2;
    if tile_mid then n2:=shortint(gb_0.vram_bank[0,(bg_addr+f+((linea_pant div 8)*32)) and $1fff])
      else n2:=byte(gb_0.vram_bank[0,(bg_addr+f+((linea_pant div 8)*32)) and $1fff]);
    tile_val1:=gb_0.vram_bank[0,(n2*16+tile_addr+y) and $1fff];
    tile_val2:=gb_0.vram_bank[0,(n2*16+tile_addr+1+y) and $1fff];
    ptemp:=punbuf;
    for x:=7 downto 0 do begin
      pval:=((tile_val1 shr x) and $1)+(((tile_val2 shr x) and $1) shl 1);
      //Prioridad con los sprites
      case prio of
        0:ptemp^:=paleta[pval];
        1:if (pval<>0) then begin
             if ((gb_0.bg_prio[f*8+(7-x)] and 2)=0) then ptemp^:=paleta[pval]
              else ptemp^:=paleta[MAX_COLORES];
          end else ptemp^:=paleta[MAX_COLORES];
      end;
      inc(ptemp);
    end; //del for x
    putpixel(f*8,0,8,punbuf,1);
  end; //del for f
  //Scroll X
  if gb_0.scroll_x<>0 then begin
    actualiza_trozo(0,0,gb_0.scroll_x,1,1,(256-gb_0.scroll_x)+7,gb_0.linea_actual,gb_0.scroll_x,1,2);
    actualiza_trozo(gb_0.scroll_x,0,256-gb_0.scroll_x,1,1,7,gb_0.linea_actual,256-gb_0.scroll_x,1,2);
  end else actualiza_trozo(0,0,256,1,1,7,gb_0.linea_actual,256,1,2);
end;

procedure update_window(prio:byte);
var
  tile_addr,bg_addr:word;
  f,x,tile_val1,tile_val2,y,pval:byte;
  n2:integer;
  tile_mid:boolean;
  ptemp:pword;
begin
  if ((gb_0.linea_actual<gb_0.window_y) or (gb_0.window_x>166) or (gb_0.window_x=0)) then exit;
  bg_addr:=$1800+((gb_0.lcd_control and $40) shl 4);
  tile_mid:=(gb_0.lcd_control and $10)=0;
  tile_addr:=$1000*byte(tile_mid); //Cuidado! Tiene signo despues
  y:=(gb_0.window_y_draw and $7)*2;
  for f:=0 to 31 do begin
    if tile_mid then n2:=shortint(gb_0.vram_bank[0,(bg_addr+f+((gb_0.window_y_draw div 8)*32)) and $1fff])
      else n2:=gb_0.vram_bank[0,(bg_addr+f+((gb_0.window_y_draw div 8)*32)) and $1fff];
    tile_val1:=gb_0.vram_bank[0,(n2*16+tile_addr+y) and $1fff];
    tile_val2:=gb_0.vram_bank[0,(n2*16+tile_addr+1+y) and $1fff];
    ptemp:=punbuf;
    for x:=7 downto 0 do begin
      pval:=((tile_val1 shr x) and $1)+(((tile_val2 shr x) and $1) shl 1);
      case prio of
        0:begin
            ptemp^:=paleta[pval];
            gb_0.bg_prio[(f*8+(7-x)-(256-gb_0.scroll_x)+gb_0.window_x-7) and $ff]:=gb_0.bg_prio[(f*8+(7-x)-(256-gb_0.scroll_x)+gb_0.window_x-7) and $ff] or 2;
          end;
        1:if (pval=0) then begin
            if gb_0.bg_prio[(f*8+(7-x)-(256-gb_0.scroll_x)+gb_0.window_x-7) and $ff]=0 then ptemp^:=paleta[0]
              else ptemp^:=paleta[MAX_COLORES];
          end else ptemp^:=paleta[pval];
      end;
      inc(ptemp);
    end; //del for x
    putpixel(f*8,0,8,punbuf,1);
  end; //del for f
  actualiza_trozo(0,0,256,1,1,gb_0.window_x,gb_0.linea_actual,256,1,2);
end;

var
  f:byte;
begin
for f:=gb_0.scroll_y_pos to 113 do gb_0.scroll_y[f]:=gb_0.scroll_y_last;
gb_0.scroll_y_pos:=0;
single_line(7,gb_0.linea_actual,paleta[0],160,2);
if gb_0.lcd_ena then begin
  fillchar(gb_0.bg_prio[0],$100,0);
  if (gb_0.lcd_control and 1)<>0 then begin
    update_bg(0);
    if (gb_0.lcd_control and $20)<>0 then update_window(0);
  end;
  if (((gb_0.lcd_control and 2)<>0) and not(gb_0.oam_dma)) then begin
    get_active_sprites;
    draw_sprites($80);
  end;
  if (gb_0.lcd_control and 1)<>0 then begin
    update_bg(1);
    if (gb_0.lcd_control and $20)<>0 then update_window(1);
  end;
  if (((gb_0.lcd_control and 2)<>0)and not(gb_0.oam_dma)) then draw_sprites(0);
  if (not((gb_0.linea_actual<gb_0.window_y) or (gb_0.window_x>166) or (gb_0.window_x=0)) and ((gb_0.lcd_control and $20)<>0)) then gb_0.window_y_draw:=gb_0.window_y_draw+1;
end;
end;

//GBC
//El renderizado de la GBC es igual que la GB normal, excepto por dos cosas
//Se puede hacer que el fondo tenga prioridad sobre los sprites, independientemente de la prioridad de los sprites (Intro en 007 TWNI)
//En lugar de encender/apagar el fondo, el bit se usa para priorizar los sprites sobre fondo y window, no importa la prioridad
procedure update_video_gbc;
procedure get_active_sprites_gbc;
var
  f,size,num_sprites:byte;
  pos_y:integer;
  pos_linea:word;
begin
fillchar(gb_0.sprites_ord[0],10,$ff);
gb_0.sprites_time:=0;
num_sprites:=0;
for f:=0 to $27 do begin
  pos_y:=gb_0.sprt_ram[$00+(f*4)];
  //Los sprites con y=0 o mayor de 159 no cuentan
  if ((pos_y=0) or (pos_y>=160)) then continue;
  //El parentesis es importante!!
  pos_linea:=gb_0.linea_actual-(pos_y-16);
  size:=8 shl ((gb_0.lcd_control and 4) shr 2);
  //Si el sprite esta en la linea... Lo cuento
  if (pos_linea<size) then begin
    //El orden es la prioridad en la posicion de la memoria
    gb_0.sprites_ord[num_sprites]:=f;
    gb_0.sprites_time:=gb_0.sprites_time+(8 shr lr35902_0.speed);
    num_sprites:=num_sprites+1;
    if num_sprites=10 then exit;
  end;
end;
end;

procedure draw_sprites_gbc(pri:byte);
var
  flipx,flipy:boolean;
  sprite_num,f,x,pal,atrib,pval,spr_bank:byte;
  num_char,def_y,tile_val1,tile_val2,long_x,main_x:byte;
  pos_linea:word;
  ptemp:pword;
  pos_y,pos_x:integer;
begin
for f:=9 downto 0 do begin
  sprite_num:=gb_0.sprites_ord[f];
  if sprite_num=$ff then continue;
  pos_y:=gb_0.sprt_ram[$00+(sprite_num*4)];
  atrib:=gb_0.sprt_ram[$03+(sprite_num*4)];
  if (atrib and $80)<>pri then continue;
  pos_y:=pos_y-16;
  pos_linea:=gb_0.linea_actual-pos_y;
  pos_x:=gb_0.sprt_ram[$01+(sprite_num*4)];
  if ((pos_x=0) or (pos_x>=168)) then continue;
  pos_x:=pos_x-8;
  pal:=(atrib and $7)*4;
  spr_bank:=(atrib shr 3) and 1;
  num_char:=gb_0.sprt_ram[$02+(sprite_num*4)];
  flipx:=(atrib and $20)<>0;
  flipy:=(atrib and $40)<>0;
  if (gb_0.lcd_control and 4)=0 then begin //8x8
      if flipy then def_y:=7-(pos_linea and 7)
        else def_y:=pos_linea and 7;
  end else begin //8x16
      if flipy then begin
        def_y:=7-(pos_linea and 7);
        num_char:=(num_char and $fe)+(not(pos_linea shr 3) and 1);
      end else begin
        def_y:=pos_linea and 7;
        num_char:=(num_char and $fe)+(pos_linea shr 3);
      end;
  end;
  ptemp:=punbuf;
  //Sprites 8x8 o 8x16
  tile_val1:=gb_0.vram_bank[spr_bank,num_char*16+(def_y*2)];
  tile_val2:=gb_0.vram_bank[spr_bank,num_char*16+1+(def_y*2)];
  if flipx then begin
    for x:=0 to 7 do begin
      pval:=((tile_val1 shr x) and $1)+(((tile_val2 shr x) and $1) shl 1);
      if pval=0 then ptemp^:=paleta[MAX_COLORES]
        else begin
          if ((gb_0.bg_prio[(pos_x+x) and $ff]) and 4)=0 then begin
            ptemp^:=paleta[(gb_0.spc_pal[(pval+pal) and $1f]) and $7fff];
            gb_0.bg_prio[(pos_x+x) and $ff]:=gb_0.bg_prio[(pos_x+x) and $ff] or 1;
          end else ptemp^:=paleta[MAX_COLORES];
        end;
        inc(ptemp);
      end;
      putpixel(0,0,8,punbuf,PANT_SPRITES);
  end else begin
    for x:=7 downto 0 do begin
      pval:=((tile_val1 shr x) and $1)+(((tile_val2 shr x) and $1) shl 1);
      if pval=0 then ptemp^:=paleta[MAX_COLORES]
        else begin
          if ((gb_0.bg_prio[(pos_x+(7-x)) and $ff]) and 4)=0 then begin
            ptemp^:=paleta[(gb_0.spc_pal[(pval+pal) and $1f]) and $7fff];
            gb_0.bg_prio[(pos_x+(7-x)) and $ff]:=gb_0.bg_prio[(pos_x+(7-x)) and $ff] or 1;
          end else ptemp^:=paleta[MAX_COLORES];
        end;
        inc(ptemp);
      end;
      putpixel(0,0,8,punbuf,PANT_SPRITES);
  end;
  long_x:=8;
  main_x:=0;
  if pos_x<0 then begin
    long_x:=8+pos_x;
    main_x:=abs(pos_x);
    pos_x:=0;
  end;
  if (pos_x+8)>160 then long_x:=160-pos_x;
  actualiza_trozo(main_x,0,long_x,1,PANT_SPRITES,pos_x+7,pos_y+pos_linea,long_x,1,2);
end;
end;

procedure update_bg_gbc(prio:byte);
var
  tile_addr,bg_addr:word;
  f,atrib,tile_bank,tile_pal:byte;
  x,tile_val1,tile_val2,y,pval,linea_pant:byte;
  n2:integer;
  tile_mid:boolean;
  ptemp:pword;
begin
  bg_addr:=$1800+((gb_0.lcd_control and $8) shl 7);
  tile_mid:=(gb_0.lcd_control and $10)=0;
  tile_addr:=$1000*byte(tile_mid); //Cuidado! Tiene signo despues
  for f:=0 to 31 do begin
    linea_pant:=gb_0.linea_actual+gb_0.scroll_y[round(f*3.5625)];
    if tile_mid then n2:=shortint(gb_0.vram_bank[0,bg_addr+(f+((linea_pant div 8)*32) and $3ff)])
      else n2:=byte(gb_0.vram_bank[0,bg_addr+(f+((linea_pant div 8)*32) and $3ff)]);
    atrib:=gb_0.vram_bank[1,bg_addr+(f+((linea_pant div 8)*32) and $3ff)];
    if (atrib and $40)<>0 then y:=(7-(linea_pant and $7))*2
      else y:=(linea_pant and $7)*2;
    tile_bank:=(atrib shr 3) and 1;
    tile_pal:=(atrib and 7) shl 2;
    tile_val1:=gb_0.vram_bank[tile_bank,(n2*16+tile_addr+y) and $1fff];
    tile_val2:=gb_0.vram_bank[tile_bank,(n2*16+tile_addr+1+y) and $1fff];
    ptemp:=punbuf;
    if (atrib and $20)<>0 then begin
      for x:=0 to 7 do begin
        pval:=((tile_val1 shr x) and $1)+(((tile_val2 shr x) and $1) shl 1);
        //Ignorar la prioridad de los sprites!
        if (((atrib and $80)<>0) and (pval<>0)) then begin
          gb_0.bg_prio[(f*8+x+(256-gb_0.scroll_x)) and $ff]:=gb_0.bg_prio[f*8+x+(256-gb_0.scroll_x)] or 4;
          ptemp^:=paleta[(gb_0.bgc_pal[pval+tile_pal]) and $7fff];
        end else begin
          case prio of
            0:ptemp^:=paleta[(gb_0.bgc_pal[pval+tile_pal]) and $7fff];
            1:if (pval<>0) then begin
                if ((gb_0.bg_prio[(f*8+x+(256-gb_0.scroll_x)+7) and $ff] and 2)=0) then ptemp^:=paleta[(gb_0.bgc_pal[pval+tile_pal]) and $7fff]
                  else ptemp^:=paleta[MAX_COLORES];
              end else ptemp^:=paleta[MAX_COLORES];
          end;
        end;
        inc(ptemp);
      end;
    end else begin  //Flipx
      for x:=7 downto 0 do begin
        pval:=((tile_val1 shr x) and $1)+(((tile_val2 shr x) and $1) shl 1);
        if (((atrib and $80)<>0) and (pval<>0)) then begin
          gb_0.bg_prio[(f*8+(7-x)+(256-gb_0.scroll_x)) and $ff]:=gb_0.bg_prio[f*8+(7-x)+(256-gb_0.scroll_x)] or 4;
          ptemp^:=paleta[gb_0.bgc_pal[pval+tile_pal] and $7fff];
        end else begin
          case prio of
            0:ptemp^:=paleta[gb_0.bgc_pal[pval+tile_pal] and $7fff];
            1:if (pval<>0) then begin
                if ((gb_0.bg_prio[(f*8+(7-x)+(256-gb_0.scroll_x)+7) and $ff] and 2)=0) then ptemp^:=paleta[(gb_0.bgc_pal[pval+tile_pal]) and $7fff]
                  else ptemp^:=paleta[MAX_COLORES];
              end else ptemp^:=paleta[MAX_COLORES];
          end;
        end;
        inc(ptemp);
      end;
    end;
    putpixel(f*8,0,8,punbuf,1);
  end;
  //Scroll X
  if gb_0.scroll_x<>0 then begin
    actualiza_trozo(0,0,gb_0.scroll_x,1,1,(256-gb_0.scroll_x)+7,gb_0.linea_actual,gb_0.scroll_x,1,2);
    actualiza_trozo(gb_0.scroll_x,0,256-gb_0.scroll_x,1,1,7,gb_0.linea_actual,256-gb_0.scroll_x,1,2);
  end else actualiza_trozo(0,0,256,1,1,7,gb_0.linea_actual,256,1,2);
end;

procedure update_window_gbc(prio:byte);
var
  tile_addr,bg_addr:word;
  f,atrib,tile_bank,tile_pal:byte;
  x,tile_val1,tile_val2,y,pval:byte;
  n2:integer;
  tile_mid:boolean;
  ptemp:pword;
begin
  if ((gb_0.linea_actual<gb_0.window_y) or (gb_0.window_x>166) or (gb_0.window_x=0)) then exit;
  bg_addr:=$1800+((gb_0.lcd_control and $40) shl 4);
  tile_mid:=(gb_0.lcd_control and $10)=0;
  tile_addr:=$1000*byte(tile_mid); //Cuidado! Tiene signo despues
  for f:=0 to 31 do begin
    if tile_mid then n2:=shortint(gb_0.vram_bank[0,(bg_addr+f+((gb_0.window_y_draw div 8)*32)) and $1fff])
      else n2:=byte(gb_0.vram_bank[0,(bg_addr+f+((gb_0.window_y_draw div 8)*32)) and $1fff]);
    atrib:=gb_0.vram_bank[1,(bg_addr+f+((gb_0.window_y_draw div 8)*32)) and $1fff];
    if (atrib and $40)<>0 then y:=(7-(gb_0.window_y_draw and $7))*2
      else y:=(gb_0.window_y_draw and $7)*2;
    tile_bank:=(atrib shr 3) and 1;
    tile_pal:=(atrib and 7) shl 2;
    tile_val1:=gb_0.vram_bank[tile_bank,(n2*16+tile_addr+y) and $1fff];
    tile_val2:=gb_0.vram_bank[tile_bank,(n2*16+tile_addr+1+y) and $1fff];
    ptemp:=punbuf;
    if (atrib and $20)<>0 then begin
      for x:=0 to 7 do begin
        pval:=((tile_val1 shr x) and $1)+(((tile_val2 shr x) and $1) shl 1);
        case prio of
          0:begin
              ptemp^:=paleta[gb_0.bgc_pal[pval+tile_pal] and $7fff];
              gb_0.bg_prio[(f*8+x-(256-gb_0.scroll_x)+gb_0.window_x-7) and $ff]:=gb_0.bg_prio[(f*8+x-(256-gb_0.scroll_x)+gb_0.window_x-7) and $ff] or 2;
            end;
          1:if (pval=0) then begin
              if gb_0.bg_prio[(f*8+x-(256-gb_0.scroll_x)+gb_0.window_x-7) and $ff]=0 then ptemp^:=paleta[gb_0.bgc_pal[pval+tile_pal] and $7fff]
                else ptemp^:=paleta[MAX_COLORES];
            end else ptemp^:=paleta[gb_0.bgc_pal[pval+tile_pal] and $7fff];
        end;
        inc(ptemp);
      end;
    end else begin
      for x:=7 downto 0 do begin
        pval:=((tile_val1 shr x) and $1)+(((tile_val2 shr x) and $1) shl 1);
        case prio of
          0:begin
              ptemp^:=paleta[gb_0.bgc_pal[pval+tile_pal] and $7fff];
              gb_0.bg_prio[(f*8+(7-x)-(256-gb_0.scroll_x)+gb_0.window_x-7) and $ff]:=gb_0.bg_prio[(f*8+(7-x)-(256-gb_0.scroll_x)+gb_0.window_x-7) and $ff] or 2;
            end;
          1:if (pval=0) then begin
              if gb_0.bg_prio[(f*8+(7-x)-(256-gb_0.scroll_x)+gb_0.window_x-7) and $ff]=0 then ptemp^:=paleta[gb_0.bgc_pal[pval+tile_pal] and $7fff]
                else ptemp^:=paleta[MAX_COLORES];
            end else ptemp^:=paleta[gb_0.bgc_pal[pval+tile_pal] and $7fff];
        end;
        inc(ptemp);
      end;
    end;
    putpixel(f*8,0,8,punbuf,1);
  end;
  //Pos X
  actualiza_trozo(0,0,256,1,1,gb_0.window_x,gb_0.linea_actual,256,1,2);
end;

var
  f:byte;
begin
for f:=gb_0.scroll_y_pos to 113 do gb_0.scroll_y[f]:=gb_0.scroll_y_last;
gb_0.scroll_y_pos:=0;
single_line(7,gb_0.linea_actual,paleta[0],160,2);
if gb_0.lcd_ena then begin
  fillchar(gb_0.bg_prio[0],$100,0);
  update_bg_gbc(0);
  if (gb_0.lcd_control and $20)<>0 then update_window_gbc(0);
  if (((gb_0.lcd_control and 2)<>0) and not(gb_0.oam_dma)) then begin
      get_active_sprites_gbc;
      draw_sprites_gbc($80);
    end;
  if (gb_0.lcd_control and 1)<>0 then begin //Mirar si fondo y window pierden sus prioridades!
    update_bg_gbc(1);
    if (gb_0.lcd_control and $20)<>0 then update_window_gbc(1);
  end;
  if (((gb_0.lcd_control and 2)<>0) and not(gb_0.oam_dma)) then draw_sprites_gbc(0);
  if (not((gb_0.linea_actual<gb_0.window_y) or (gb_0.window_x>166) or (gb_0.window_x=0)) and ((gb_0.lcd_control and $20)<>0)) then gb_0.window_y_draw:=gb_0.window_y_draw+1;
end;
end;

procedure eventos_gb;
var
  tmp_in0:byte;
begin
if event.arcade then begin
  tmp_in0:=gb_0.joy_val;
  if arcade_input.right[0] then gb_0.joy_val:=(gb_0.joy_val and $fe) else gb_0.joy_val:=(gb_0.joy_val or $1);
  if arcade_input.left[0] then gb_0.joy_val:=(gb_0.joy_val and $fd) else gb_0.joy_val:=(gb_0.joy_val or $2);
  if arcade_input.up[0] then gb_0.joy_val:=(gb_0.joy_val and $fb) else gb_0.joy_val:=(gb_0.joy_val or $4);
  if arcade_input.down[0] then gb_0.joy_val:=(gb_0.joy_val and $f7) else gb_0.joy_val:=(gb_0.joy_val or $8);
  if arcade_input.but0[0] then gb_0.joy_val:=(gb_0.joy_val and $ef) else gb_0.joy_val:=(gb_0.joy_val or $10);
  if arcade_input.but1[0] then gb_0.joy_val:=(gb_0.joy_val and $df) else gb_0.joy_val:=(gb_0.joy_val or $20);
  if arcade_input.coin[0] then gb_0.joy_val:=(gb_0.joy_val and $bf) else gb_0.joy_val:=(gb_0.joy_val or $40);
  if arcade_input.start[0] then gb_0.joy_val:=(gb_0.joy_val and $7f) else gb_0.joy_val:=(gb_0.joy_val or $80);
  if tmp_in0<>gb_0.joy_val then lr35902_0.joystick_req:=true;
end;
end;

function leer_io(direccion:byte):byte;
var
  tempb:byte;
begin
case direccion of
  $00:begin
        //Es muy importante este orden!!! Por ejemplo Robocop Rev1 no funciona si no es asi
        if (gb_0.joystick and $10)=0 then gb_0.joystick:=(gb_0.joystick or $f) and (gb_0.joy_val or $f0);
        if (gb_0.joystick and $20)=0 then gb_0.joystick:=(gb_0.joystick or $f) and ((gb_0.joy_val shr 4) or $f0);
        leer_io:=gb_0.joystick;
      end;
  $01:leer_io:=0;
  $02:leer_io:=$7e; //Serial
  $04:leer_io:=gb_0.mtimer;
  $05:leer_io:=gb_0.prog_timer;
  $06:leer_io:=gb_0.tmodulo;
  $07:leer_io:=$f8 or gb_0.tcontrol;
  $0f:begin
        tempb:=$e0;
        if lr35902_0.vblank_req then tempb:=tempb or $1;
        if lr35902_0.lcdstat_req then tempb:=tempb or $2;
        if lr35902_0.timer_req then tempb:=tempb or $4;
        if lr35902_0.serial_req then tempb:=tempb or $8;
        if lr35902_0.joystick_req then tempb:=tempb or $10;
        leer_io:=tempb;
      end;
  $10..$26:leer_io:=gb_snd_0.sound_r(direccion-$10); //Sound
  $30..$3f:leer_io:=gb_snd_0.wave_r(direccion-$30); //Sound Wav
  $40:leer_io:=gb_0.lcd_control;
  $41:leer_io:=$80 or gb_0.stat;
  $42:leer_io:=gb_0.scroll_y_last;
  $43:leer_io:=gb_0.scroll_x;
  $44:leer_io:=gb_0.linea_actual;
  $45:leer_io:=gb_0.ly_compare;
  $47:leer_io:=gb_0.bg_pal;
  $48:leer_io:=gb_0.sprt0_pal;
  $49:leer_io:=gb_0.sprt1_pal;
  $4a:leer_io:=gb_0.window_y;
  $4b:leer_io:=gb_0.window_x;
  //$80..$fe:leer_io:=io_ram[direccion];  //high memory
  $ff:leer_io:=gb_0.irq_ena;
  else leer_io:=gb_0.io_ram[direccion];
end;
end;

procedure escribe_io(direccion,valor:byte);
var
  f:byte;
  addrs:word;
begin
gb_0.io_ram[direccion]:=valor;
case direccion of
  $00:gb_0.joystick:=$cf or (valor and $30);
  $01:; //Serial
  $02:if (valor and $81)=$81 then lr35902_0.serial_req:=true;
  $04:gb_0.mtimer:=0;
  $05:gb_0.prog_timer:=valor;
  $06:gb_0.tmodulo:=valor;
  $07:begin  //timer control
        gb_0.tcontrol:=valor and $7;
        case (valor and $3) of
          0:timers.timer[gb_timer].time_final:=GB_CLOCK/4096;
          1:timers.timer[gb_timer].time_final:=GB_CLOCK/262144;
          2:timers.timer[gb_timer].time_final:=GB_CLOCK/65536;
          3:timers.timer[gb_timer].time_final:=GB_CLOCK/16384;
        end;
        timers.enabled(gb_timer,(valor and $4)<>0);
      end;
  $0f:begin //irq request
        lr35902_0.vblank_req:=(valor and $1)<>0;
        lr35902_0.lcdstat_req:=(valor and $2)<>0;
        lr35902_0.timer_req:=(valor and $4)<>0;
        lr35902_0.serial_req:=(valor and $8)<>0;
        lr35902_0.joystick_req:=(valor and $10)<>0;
      end;
  $10..$26:gb_snd_0.sound_w(direccion-$10,valor); //Sound
  $30..$3f:gb_snd_0.wave_w(direccion and $f,valor); //Sound Wav
  $40:begin
        gb_0.lcd_control:=valor;
        gb_0.lcd_ena:=(valor and $80)<>0;
        if not(gb_0.lcd_ena) then gb_0.stat:=gb_0.stat and $fc;
      end;
  $41:gb_0.stat:=(gb_0.stat and $7) or (valor and $f8);
  $42:begin
        addrs:=lr35902_0.contador div 4;
        for f:=gb_0.scroll_y_pos to (addrs-1) do gb_0.scroll_y[f]:=valor;
        gb_0.scroll_y_pos:=addrs;
        gb_0.scroll_y_last:=valor;
      end;
  $43:gb_0.scroll_x:=valor;
  $44:;
  $45:gb_0.ly_compare:=valor;
  $46:begin //DMA trans OAM
        addrs:=valor shl 8;
        for f:=0 to $9f do begin
          case addrs of
            $0000..$7fff:gb_0.sprt_ram[f]:=memoria[addrs];
            $8000..$9fff:gb_0.sprt_ram[f]:=$ff; //Lee datos incorrectos
            $a000..$bfff:if @gb_mapper_0.calls.ext_ram_getbyte<>nil then gb_0.sprt_ram[f]:=gb_mapper_0.calls.ext_ram_getbyte(addrs and $1fff)
                            else gb_0.sprt_ram[f]:=$ff;
            $c000..$cfff:gb_0.sprt_ram[f]:=gb_0.wram_bank[0,addrs and $fff];
            $d000..$dfff:gb_0.sprt_ram[f]:=gb_0.wram_bank[1,addrs and $fff];
            $e000..$ffff:if @gb_mapper_0.calls.ext_ram_getbyte<>nil then gb_0.sprt_ram[f]:=gb_mapper_0.calls.ext_ram_getbyte(addrs and $1fff) //a000
                            else gb_0.sprt_ram[f]:=$ff;
          end;
          addrs:=addrs+1;
        end;
        //CUIDADO!!! La CPU no se para!! Sigue funcionando, pero la memoria NO es accesible!
        gb_0.oam_dma_pos:=0;
        gb_0.oam_dma:=true;
      end;
  $47:begin
        gb_0.bg_pal:=valor;
        set_pal_color(color_pal[gb_0.palette,(valor shr 0) and $3],0);
        set_pal_color(color_pal[gb_0.palette,(valor shr 2) and $3],1);
        set_pal_color(color_pal[gb_0.palette,(valor shr 4) and $3],2);
        set_pal_color(color_pal[gb_0.palette,(valor shr 6) and $3],3);
      end;
  $48:begin //sprt0
        gb_0.sprt0_pal:=valor;
        set_pal_color(color_pal[gb_0.palette,(valor shr 0) and $3],4);
        set_pal_color(color_pal[gb_0.palette,(valor shr 2) and $3],5);
        set_pal_color(color_pal[gb_0.palette,(valor shr 4) and $3],6);
        set_pal_color(color_pal[gb_0.palette,(valor shr 6) and $3],7);
      end;
  $49:begin
        gb_0.sprt1_pal:=valor;
        set_pal_color(color_pal[gb_0.palette,(valor shr 0) and $3],8);
        set_pal_color(color_pal[gb_0.palette,(valor shr 2) and $3],9);
        set_pal_color(color_pal[gb_0.palette,(valor shr 4) and $3],10);
        set_pal_color(color_pal[gb_0.palette,(valor shr 6) and $3],11);
      end;
  $4a:gb_0.window_y:=valor;
  $4b:gb_0.window_x:=valor;
  $50:gb_0.enable_bios:=false;  //disable ROM
  //$80..$fe:io_ram[direccion]:=valor;  //high memory
  $ff:begin  //irq enable
        gb_0.irq_ena:=valor;
        lr35902_0.vblank_ena:=(valor and $1)<>0;
        lr35902_0.lcdstat_ena:=(valor and $2)<>0;
        lr35902_0.timer_ena:=(valor and $4)<>0;
        lr35902_0.serial_ena:=(valor and $8)<>0;
        lr35902_0.joystick_ena:=(valor and $10)<>0;
      end;
  //MessageDlg('IO desconocida escribe pos= '+inttohex(direccion and $ff,2)+' - '+inttohex(valor,2), mtInformation,[mbOk], 0);
end;
end;

//Color GB
function leer_io_gbc(direccion:byte):byte;
var
  tempb:byte;
begin
case direccion of
  $00:begin
        if (gb_0.joystick and $10)=0 then gb_0.joystick:=(gb_0.joystick or $f) and (gb_0.joy_val or $f0);
        if (gb_0.joystick and $20)=0 then gb_0.joystick:=(gb_0.joystick or $f) and ((gb_0.joy_val shr 4) or $f0);
        leer_io_gbc:=gb_0.joystick;
      end;
  $01:leer_io_gbc:=0;
  $02:leer_io_gbc:=$7c; //Serial
  $04:leer_io_gbc:=gb_0.mtimer;
  $05:leer_io_gbc:=gb_0.prog_timer;
  $06:leer_io_gbc:=gb_0.tmodulo;
  $07:leer_io_gbc:=$f8 or gb_0.tcontrol;
  $0f:begin
        tempb:=$e0;
        if lr35902_0.vblank_req then tempb:=tempb or $1;
        if lr35902_0.lcdstat_req then tempb:=tempb or $2;
        if lr35902_0.timer_req then tempb:=tempb or $4;
        if lr35902_0.serial_req then tempb:=tempb or $8;
        if lr35902_0.joystick_req then tempb:=tempb or $10;
        leer_io_gbc:=tempb;
      end;
  $10..$26:leer_io_gbc:=gb_snd_0.sound_r(direccion-$10); //Sound
//  $27..$2f:leer_io_gbc:=io_ram[direccion];
  $30..$3f:leer_io_gbc:=gb_snd_0.wave_r(direccion and $f); //Sound Wav
  $40:leer_io_gbc:=gb_0.lcd_control;
  $41:leer_io_gbc:=$80 or gb_0.stat;
  $42:leer_io_gbc:=gb_0.scroll_y_last;
  $43:leer_io_gbc:=gb_0.scroll_x;
  $44:leer_io_gbc:=gb_0.linea_actual;
  $45:leer_io_gbc:=gb_0.ly_compare;
  $47:leer_io_gbc:=gb_0.bg_pal;
  $48:leer_io_gbc:=gb_0.sprt0_pal;
  $49:leer_io_gbc:=gb_0.sprt1_pal;
  $4a:leer_io_gbc:=gb_0.window_y;
  $4b:leer_io_gbc:=gb_0.window_x;
  $4d:leer_io_gbc:=(lr35902_0.speed shl 7)+$7e+byte(lr35902_0.change_speed);
  $4f:leer_io_gbc:=$fe or gb_0.vram_nbank;
  $51..$54:leer_io_gbc:=$ff;
  $55:leer_io_gbc:=gb_0.hdma_size;
  $56:leer_io_gbc:=1;
  $68:leer_io_gbc:=gb_0.bgcolor_index;
  $69:if (gb_0.bgcolor_index and 1)<>0 then leer_io_gbc:=gb_0.bgc_pal[gb_0.bgcolor_index shr 1] shr 8
        else leer_io_gbc:=gb_0.bgc_pal[gb_0.bgcolor_index shr 1] and $ff;
  $6a:leer_io_gbc:=gb_0.spcolor_index;
  $6b:if (gb_0.spcolor_index and 1)<>0 then leer_io_gbc:=gb_0.spc_pal[gb_0.spcolor_index shr 1] shr 8
        else leer_io_gbc:=gb_0.spc_pal[gb_0.spcolor_index shr 1] and $ff;
  $70:leer_io_gbc:=$f8 or gb_0.wram_nbank;
  $80..$fe:leer_io_gbc:=gb_0.io_ram[direccion];  //high memory
  $ff:leer_io_gbc:=gb_0.irq_ena;
  else begin
    //MessageDlg('IO desconocida leer pos= '+inttohex(direccion and $ff,2), mtInformation,[mbOk], 0);
    leer_io_gbc:=gb_0.io_ram[direccion];
  end;
end;
end;

procedure dma_trans(size:word);
var
  f:word;
  temp:byte;
begin
for f:=1 to size do begin
  temp:=$ff;
  case gb_0.dma_src of
    $0000..$7fff:temp:=memoria[gb_0.dma_src];
    //$8000..$9fff:temp:=$ff;
    $a000..$bfff:if @gb_mapper_0.calls.ext_ram_getbyte<>nil then temp:=gb_mapper_0.calls.ext_ram_getbyte(gb_0.dma_src and $1fff);
    $c000..$cfff:temp:=gb_0.wram_bank[0,gb_0.dma_src and $fff];
    $d000..$dfff:temp:=gb_0.wram_bank[gb_0.wram_nbank,gb_0.dma_src and $fff];
    $e000..$ffff:if @gb_mapper_0.calls.ext_ram_getbyte<>nil then temp:=gb_mapper_0.calls.ext_ram_getbyte(gb_0.dma_src and $1fff);
  end;
  gb_0.vram_bank[gb_0.vram_nbank,gb_0.dma_dst and $1fff]:=temp;
  gb_0.dma_dst:=gb_0.dma_dst+1;
  gb_0.dma_src:=gb_0.dma_src+1;
end;
end;

procedure escribe_io_gbc(direccion,valor:byte);
var
  addrs:word;
  f:byte;
begin
gb_0.io_ram[direccion]:=valor;
case direccion of
  $00:gb_0.joystick:=$cf or (valor and $30);
  $01:; //Serial
  $02:if (valor and $81)=$81 then lr35902_0.serial_req:=true;
  $04:gb_0.mtimer:=0;
  $05:gb_0.prog_timer:=valor;
  $06:gb_0.tmodulo:=valor;
  $07:begin  //timer control
        gb_0.tcontrol:=valor and $7;
        case (valor and $3) of
          0:timers.timer[gb_timer].time_final:=GB_CLOCK/4096;
          1:timers.timer[gb_timer].time_final:=GB_CLOCK/262144;
          2:timers.timer[gb_timer].time_final:=GB_CLOCK/65536;
          3:timers.timer[gb_timer].time_final:=GB_CLOCK/16384;
        end;
        timers.reset(gb_timer);
        timers.enabled(gb_timer,(valor and $4)<>0);
      end;
  $0f:begin //irq request
        lr35902_0.vblank_req:=(valor and $1)<>0;
        lr35902_0.lcdstat_req:=(valor and $2)<>0;
        lr35902_0.timer_req:=(valor and $4)<>0;
        lr35902_0.serial_req:=(valor and $8)<>0;
        lr35902_0.joystick_req:=(valor and $10)<>0;
      end;
  $10..$26:gb_snd_0.sound_w(direccion-$10,valor); //Sound
  //$27..$2f:io_ram[direccion]:=valor;
  $30..$3f:gb_snd_0.wave_w(direccion and $f,valor); //Sound Wav
  $40:begin
        gb_0.lcd_control:=valor;
        gb_0.lcd_ena:=(valor and $80)<>0;
        if not(gb_0.lcd_ena) then gb_0.stat:=gb_0.stat and $fc;
      end;
  $41:gb_0.stat:=(gb_0.stat and $7) or (valor and $f8);
  $42:begin
        addrs:=(lr35902_0.contador shr lr35902_0.speed) div 4;
        for f:=gb_0.scroll_y_pos to (addrs-1) do gb_0.scroll_y[f]:=valor;
        gb_0.scroll_y_pos:=addrs;
        gb_0.scroll_y_last:=valor;
      end;
  $43:gb_0.scroll_x:=valor;
  $44:;
  $45:gb_0.ly_compare:=valor;
  $46:begin //DMA trans OAM
        addrs:=valor shl 8;
        for f:=0 to $9f do begin
          case addrs of
            $0000..$7fff:gb_0.sprt_ram[f]:=memoria[addrs];
            $8000..$9fff:gb_0.sprt_ram[f]:=$ff; //Lee datos incorrectos
            $a000..$bfff:if @gb_mapper_0.calls.ext_ram_getbyte<>nil then gb_0.sprt_ram[f]:=gb_mapper_0.calls.ext_ram_getbyte(addrs and $1fff)
                            else gb_0.sprt_ram[f]:=$ff;
            $c000..$cfff:gb_0.sprt_ram[f]:=gb_0.wram_bank[0,addrs and $fff];
            $d000..$dfff:gb_0.sprt_ram[f]:=gb_0.wram_bank[gb_0.wram_nbank,addrs and $fff];
            $e000..$ffff:if @gb_mapper_0.calls.ext_ram_getbyte<>nil then gb_0.sprt_ram[f]:=gb_mapper_0.calls.ext_ram_getbyte(addrs and $1fff) //a000
                            else gb_0.sprt_ram[f]:=$ff;
          end;
          addrs:=addrs+1;
        end;
        gb_0.oam_dma_pos:=0;
        gb_0.oam_dma:=true;
      end;
  $47:gb_0.bg_pal:=valor;
  $48:gb_0.sprt0_pal:=valor;
  $49:gb_0.sprt1_pal:=valor;
  $4a:gb_0.window_y:=valor;
  $4b:gb_0.window_x:=valor;
//  $4c:io_ram[direccion]:=valor;  //????
  $4d:lr35902_0.change_speed:=(valor and 1)<>0;  //Cambiar velocidad
  $4f:gb_0.vram_nbank:=valor and 1; //VRAM Bank
  $50:gb_0.enable_bios:=false;  //disable ROM
  $51:gb_0.dma_src:=(gb_0.dma_src and $ff) or (valor shl 8);
  $52:gb_0.dma_src:=(gb_0.dma_src and $ff00) or (valor and $f0);
  $53:gb_0.dma_dst:=(gb_0.dma_dst and $ff) or ((valor and $1f) shl 8);
  $54:gb_0.dma_dst:=(gb_0.dma_dst and $ff00) or (valor and $f0);
  $55:if (gb_0.hdma_ena and ((valor and $80)<>0)) then begin //Cancelar la transferencia!
          gb_0.hdma_ena:=false;
          gb_0.hdma_size:=gb_0.hdma_size or $80;
      end else begin
          if (valor and $80)<>0 then begin
            gb_0.hdma_size:=valor and $7f;
            gb_0.hdma_ena:=true;
          end else begin
            valor:=valor+1;
            dma_trans(valor*$10);
            lr35902_0.estados_demas:=lr35902_0.estados_demas+(220 shr lr35902_0.speed)+(8*valor);
          end;
      end;
  $56:;
  $68:begin
        gb_0.bgcolor_inc:=(valor and $80)<>0;
        gb_0.bgcolor_index:=valor and $3f;
      end;
  $69:begin
        if (gb_0.stat and 3)<>3 then begin
          if (gb_0.bgcolor_index and 1)<>0 then gb_0.bgc_pal[gb_0.bgcolor_index shr 1]:=(gb_0.bgc_pal[gb_0.bgcolor_index shr 1] and $ff) or (valor shl 8)
            else gb_0.bgc_pal[gb_0.bgcolor_index shr 1]:=(gb_0.bgc_pal[gb_0.bgcolor_index shr 1] and $ff00) or valor;
        end;
        if gb_0.bgcolor_inc then gb_0.bgcolor_index:=(gb_0.bgcolor_index+1) and $3f;
      end;
  $6a:begin
        gb_0.spcolor_inc:=(valor and $80)<>0;
        gb_0.spcolor_index:=valor and $3f;
      end;
  $6b:begin
        if (gb_0.stat and 3)<>3 then begin
          if (gb_0.spcolor_index and 1)<>0 then gb_0.spc_pal[gb_0.spcolor_index shr 1]:=(gb_0.spc_pal[gb_0.spcolor_index shr 1] and $ff) or (valor shl 8)
            else gb_0.spc_pal[gb_0.spcolor_index shr 1]:=(gb_0.spc_pal[gb_0.spcolor_index shr 1] and $ff00) or valor;
        end;
        if gb_0.spcolor_inc then gb_0.spcolor_index:=(gb_0.spcolor_index+1) and $3f;
      end;
  $70:begin
        gb_0.wram_nbank:=valor and 7;
        if gb_0.wram_nbank=0 then gb_0.wram_nbank:=1;
       end;
  $7e,$7f:;
//  $80..$fe:io_ram[direccion]:=valor;  //high memory
  $ff:begin  //irq enable
        gb_0.irq_ena:=valor;
        lr35902_0.vblank_ena:=(valor and $1)<>0;
        lr35902_0.lcdstat_ena:=(valor and $2)<>0;
        lr35902_0.timer_ena:=(valor and $4)<>0;
        lr35902_0.serial_ena:=(valor and $8)<>0;
        lr35902_0.joystick_ena:=(valor and $10)<>0;
      end;
//  else io_ram[direccion]:=valor;//MessageDlg('IO desconocida escribe pos= '+inttohex(direccion and $ff,2)+' - '+inttohex(valor,2), mtInformation,[mbOk], 0);
end;
end;

procedure gb_principal;
var
  frame_m:single;
begin
init_controls(false,false,false,true);
frame_m:=lr35902_0.tframes;
while EmuStatus=EsRunning do begin
  while gb_0.linea_actual<>154 do begin
    lr35902_0.run(frame_m);
    frame_m:=frame_m+lr35902_0.tframes-lr35902_0.contador;
    if gb_0.linea_actual<144 then gb_calls.video_render;  //Modos 2-3-0
    gb_0.linea_actual:=gb_0.linea_actual+1;
  end;
  //principal1.statusbar1.panels[2].text:=inttostr(gb_0.wram_nbank);
  gb_0.linea_actual:=0;
  gb_0.window_y_draw:=0;
  eventos_gb;
  actualiza_trozo(7,0,160,144,2,0,0,160,144,PANT_TEMP);
  video_sync;
end;
end;

function gb_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$ff,$200..$8ff:if gb_0.enable_bios then gb_getbyte:=gb_0.bios_rom[direccion]
                        else gb_getbyte:=memoria[direccion];
  $100..$1ff,$900..$7fff:gb_getbyte:=memoria[direccion];
  $8000..$9fff:gb_getbyte:=gb_0.vram_bank[gb_0.vram_nbank,direccion and $1fff];
  $a000..$bfff:if @gb_mapper_0.calls.ext_ram_getbyte<>nil then gb_getbyte:=gb_mapper_0.calls.ext_ram_getbyte(direccion)
                  else gb_getbyte:=$ff;
  $c000..$cfff,$e000..$efff:gb_getbyte:=gb_0.wram_bank[0,direccion and $fff];
  $d000..$dfff,$f000..$fdff:gb_getbyte:=gb_0.wram_bank[gb_0.wram_nbank,direccion and $fff];
  $fe00..$fe9f:gb_getbyte:=gb_0.sprt_ram[direccion and $ff];
  $fea0..$feff:if not(gb_0.is_gbc) then gb_getbyte:=0
                  else begin
                        case (direccion and $ff) of
                         $a0..$cf:gb_getbyte:=memoria[direccion];
                         $d0..$ff:gb_getbyte:=memoria[$fec0+(direccion and $f)];
                        end;
                  end;
  $ff00..$ffff:gb_getbyte:=gb_calls.read_io(direccion and $ff);
end;
end;

procedure gb_putbyte(direccion:word;valor:byte);
begin
case direccion of
  $0000..$7fff:if @gb_mapper_0.calls.rom_putbyte<>nil then gb_mapper_0.calls.rom_putbyte(direccion,valor);
  $8000..$9fff:gb_0.vram_bank[gb_0.vram_nbank,direccion and $1fff]:=valor;
  $a000..$bfff:if @gb_mapper_0.calls.ext_ram_putbyte<>nil then gb_mapper_0.calls.ext_ram_putbyte(direccion,valor);
  $c000..$cfff,$e000..$efff:gb_0.wram_bank[0,direccion and $fff]:=valor;
  $d000..$dfff,$f000..$fdff:gb_0.wram_bank[gb_0.wram_nbank,direccion and $fff]:=valor;
  $fe00..$fe9f:gb_0.sprt_ram[direccion and $ff]:=valor;
  $fea0..$feff:if gb_0.is_gbc then begin
                  case (direccion and $ff) of
                    $a0..$cf:memoria[direccion]:=valor;
                    $d0..$ff:memoria[$fec0+(direccion and $f)]:=valor;
                  end;
               end;
  $ff00..$ffff:gb_calls.write_io(direccion and $ff,valor);
end;
end;

procedure gb_despues_instruccion(estados_t:word);
var
  lcd_compare,lcd_mode:boolean;
begin
lcd_compare:=false;
lcd_mode:=false;
//Ver si estoy en OAM DMA
if gb_0.oam_dma then begin
  gb_0.oam_dma_pos:=gb_0.oam_dma_pos+estados_t;
  if gb_0.oam_dma_pos>=160 then gb_0.oam_dma:=false;
end;
if not(gb_0.lcd_ena) then exit;
//CUIDADO! Cuando se activa la IRQ en la linea del LCD ya no se aceptan más IRQ en la misma linea!!
//Esto se llama STAT IRQ glitch
case lr35902_0.contador of
  0:begin
          if gb_0.linea_actual=gb_0.ly_compare then begin //LY compare
            lcd_compare:=(gb_0.stat and $40)<>0;
            gb_0.stat:=gb_0.stat or $4;
          end else gb_0.stat:=gb_0.stat and $fb;
          if gb_0.linea_actual<144 then begin //Modo 2
            lcd_mode:=(gb_0.stat and $20)<>0;
            gb_0.stat:=(gb_0.stat and $fc) or $2;
          end;
          if gb_0.linea_actual=144 then begin //Modo 1
            lcd_mode:=(gb_0.stat and $10)<>0;
            gb_0.stat:=(gb_0.stat and $fc) or $1;
          end;
        end;
  80:begin
          if (gb_0.linea_actual<144) then begin //Modo 3
             lcd_mode:=((gb_0.stat and $20)<>0) and ((gb_0.stat and $10)=0);
             gb_0.stat:=(gb_0.stat and $fc) or $3;
          end;
          //VBLANK
          if (gb_0.linea_actual=144) then lr35902_0.vblank_req:=true;
     end;
  248..600:if ((gb_0.linea_actual<144) and ((gb_0.sprites_time+248)=lr35902_0.contador) and ((gb_0.stat and 3)<>0)) then begin //Modo 0
                lcd_mode:=((gb_0.stat and $8)<>0) and ((gb_0.stat and $20)=0);
                gb_0.stat:=gb_0.stat and $fc;
           end;
end;
lr35902_0.lcdstat_req:=lr35902_0.lcdstat_req or lcd_compare or lcd_mode;
end;

procedure gbc_despues_instruccion(estados_t:word);
var
  lcd_compare,lcd_mode:boolean;
  contador:word;
begin
lcd_compare:=false;
lcd_mode:=false;
if gb_0.wram_bank[0,$1a4]=gb_0.wram_bank[1,$1a4] then begin
  gb_0.wram_bank[0,$1a4]:=$ed;
end;
//Ver si estoy en OAM DMA
if gb_0.oam_dma then begin
  gb_0.oam_dma_pos:=gb_0.oam_dma_pos+(estados_t shr lr35902_0.speed);
  if gb_0.oam_dma_pos>=160 then gb_0.oam_dma:=false;
end;
if lr35902_0.changed_speed then begin
  lr35902_0.tframes:=((GB_CLOCK shl lr35902_0.speed)/154)/llamadas_maquina.fps_max;
  sound_engine_change_clock(GB_CLOCK shl lr35902_0.speed);
  lr35902_0.changed_speed:=false;
end;
if not(gb_0.lcd_ena) then exit;
contador:=lr35902_0.contador shr lr35902_0.speed;
case contador of
  0:begin
        gb_0.haz_dma:=false;
        //LY compare
        if gb_0.linea_actual=gb_0.ly_compare then begin
           lcd_compare:=(gb_0.stat and $40)<>0;
           gb_0.stat:=gb_0.stat or $4;
        end else gb_0.stat:=gb_0.stat and $fb;
        if (gb_0.linea_actual<144) then begin //modo 2
            lcd_mode:=(gb_0.stat and $20)<>0;
            gb_0.stat:=(gb_0.stat and $fc) or $2;
        end;
        if (gb_0.linea_actual=144) then begin //modo 1 VBlank
            lcd_mode:=((gb_0.stat and $10)<>0);
            gb_0.stat:=(gb_0.stat and $fc) or $1;
        end;
     end;
  80:begin
          if (gb_0.linea_actual<144) then begin //Modo 3 HBlank
             lcd_mode:=((gb_0.stat and $20)<>0) and ((gb_0.stat and $10)=0);
             gb_0.stat:=(gb_0.stat and $fc) or $3;
          end;
          //VBlank
          if (gb_0.linea_actual=144) then lr35902_0.vblank_req:=true;
     end;
  248..600:begin
              if (gb_0.linea_actual<144) then begin
                if ((contador>=300) and gb_0.hdma_ena and not(gb_0.haz_dma)) then begin //DMA H-Blank
                  dma_trans($10);
                  gb_0.hdma_size:=gb_0.hdma_size-1;
                  if gb_0.hdma_size=$ff then gb_0.hdma_ena:=false;
                  lr35902_0.contador:=lr35902_0.contador+8;
                  gb_0.haz_dma:=true;
                end;
                if (((gb_0.sprites_time+248)=contador) and ((gb_0.stat and 3)<>0)) then begin   //Modo 0
                  lcd_mode:=((gb_0.stat and $8)<>0) and ((gb_0.stat and $20)=0);
                  gb_0.stat:=gb_0.stat and $fc;
                end;
              end;
           end;
end;
lr35902_0.lcdstat_req:=lr35902_0.lcdstat_req or lcd_compare or lcd_mode;
end;

//Sonido and timers
procedure gb_main_timer;
begin
  gb_0.mtimer:=gb_0.mtimer+1;
end;

procedure gb_sound_update;
begin
  gb_snd_0.update;
end;

//Main
procedure cerrar_gb;
begin
if (gb_0.hay_nvram and (nv_ram_name<>'')) then write_file(nv_ram_name,@gb_mapper_0.ram_bank[0,0],$2000);
gb_mapper_0.free;
end;

procedure reset_gb;
var
  lr_reg:reg_lr;
  f:byte;
begin
 lr35902_0.reset;
 reset_audio;
 gb_snd_0.reset;
 sound_engine_change_clock(GB_CLOCK);
 gb_0.scroll_x:=0;
 gb_0.linea_actual:=0;
 fillchar(gb_0.scroll_y[0],$ff,0);
 fillchar(gb_0.io_ram[0],$ff,0);
 //io_ram[128]:=$e0; //3e
 //io_ram[129]:=$46; //df
 //io_ram[130]:=$3e; //e0
 //io_ram[131]:=$28; //46
 //io_ram[132]:=$3d; //3e
 //io_ram[133]:=$20; //28
 //io_ram[134]:=$fd; //3d
 //io_ram[135]:=$c9; //20
 //io_ram[136]:=$fd;
 //io_ram[137]:=$c9;
 fillchar(gb_0.sprt_ram[0],$ff,0);
 fillchar(gb_0.bgc_pal[0],$ff,0);
 fillchar(gb_0.bgc_pal[0],$ff,0);
 gb_0.scroll_y_pos:=0;
 gb_0.scroll_y_last:=0;
 gb_0.stat:=0;
 gb_0.tmodulo:=0;
 gb_0.mtimer:=0;
 gb_0.prog_timer:=0;
 gb_0.vram_nbank:=0;
 gb_0.wram_nbank:=1;
 gb_0.ly_compare:=$ff;
 gb_0.irq_ena:=0;
 gb_0.joy_val:=$ff;
 gb_0.joystick:=$ff;
 gb_0.hdma_ena:=false;
 gb_0.hdma_size:=$ff;
 gb_0.lcd_control:=$80;
 gb_0.lcd_ena:=true;
 gb_0.oam_dma_pos:=0;
 gb_0.oam_dma:=false;
 gb_0.window_y_draw:=0;
 gb_0.bg_pal:=0;
 gb_0.sprt0_pal:=0;
 gb_0.sprt1_pal:=0;
 gb_0.window_x:=0;
 gb_0.window_y:=0;
 if not(gb_0.rom_exist) then begin
   gb_0.enable_bios:=false;
   lr_reg.pc:=$100;
   lr_reg.sp:=$fffe;
   lr_reg.f.z:=true;
   lr_reg.f.n:=false;
   if not(gb_0.is_gbc) then begin
     lr_reg.a:=$11;
     lr_reg.f.h:=false;
     lr_reg.f.c:=false;
     lr_reg.bc.w:=$0;
     lr_reg.de.w:=$ff56;
     lr_reg.hl.w:=$000d;
   end else begin
     lr_reg.a:=$01;
     lr_reg.f.h:=true;
     lr_reg.f.c:=true;
     lr_reg.bc.w:=$0013;
     lr_reg.de.w:=$00d8;
     lr_reg.hl.w:=$014d;
     escribe_io(05,00);
     escribe_io(06,00);
     escribe_io(07,00);
     escribe_io($10,$80);
     escribe_io($11,$bf);
     escribe_io($12,$f3);
     escribe_io($14,$bf);
     escribe_io($16,$3f);
     escribe_io($17,$00);
     escribe_io($19,$bf);
     escribe_io($1a,$7f);
     escribe_io($1b,$f);
     escribe_io($1c,$9f);
     escribe_io($1e,$bf);
     escribe_io($20,$ff);
     escribe_io($21,$00);
     escribe_io($22,$00);
     escribe_io($23,$bf);
     escribe_io($24,$77);
     escribe_io($25,$f3);
     escribe_io($26,$f1);
     escribe_io($40,$91);
     escribe_io($42,$00);
     escribe_io($43,$00);
     escribe_io($45,$00);
     escribe_io($47,$fc);
     escribe_io($48,$ff);
     escribe_io($49,$ff);
     escribe_io($4a,$00);
     escribe_io($4b,$00);
     escribe_io($00,$00);
     for f:=0 to $1f do gb_0.bgc_pal[f]:=$7fff;
     for f:=0 to $1f do gb_0.spc_pal[f]:=0;
   end;
   lr35902_0.set_internal_r(lr_reg);
  end else gb_0.enable_bios:=true;
  gb_mapper_0.reset;
end;

procedure gb_prog_timer;
begin
  gb_0.prog_timer:=gb_0.prog_timer+1;
  if gb_0.prog_timer=0 then begin
    gb_0.prog_timer:=gb_0.tmodulo;
    lr35902_0.timer_req:=true; //timer request irq
  end;
end;

procedure gb_change_timer;
begin
case (gb_0.tcontrol and $3) of
  0:timers.timer[gb_timer].time_final:=GB_CLOCK/4096;
  1:timers.timer[gb_timer].time_final:=GB_CLOCK/262144;
  2:timers.timer[gb_timer].time_final:=GB_CLOCK/65536;
  3:timers.timer[gb_timer].time_final:=GB_CLOCK/16384;
end;
timers.enabled(gb_timer,(gb_0.tcontrol and $4)<>0);
end;

procedure gb_set_pal;
var
  colores:tpaleta;
  f:word;
begin
if not(gb_0.is_gbc) then begin
    set_pal_color(color_pal[gb_0.palette,(gb_0.bg_pal shr 0) and $3],0);
    set_pal_color(color_pal[gb_0.palette,(gb_0.bg_pal shr 2) and $3],1);
    set_pal_color(color_pal[gb_0.palette,(gb_0.bg_pal shr 4) and $3],2);
    set_pal_color(color_pal[gb_0.palette,(gb_0.bg_pal shr 6) and $3],3);
    set_pal_color(color_pal[gb_0.palette,(gb_0.sprt0_pal shr 0) and $3],4);
    set_pal_color(color_pal[gb_0.palette,(gb_0.sprt0_pal shr 2) and $3],5);
    set_pal_color(color_pal[gb_0.palette,(gb_0.sprt0_pal shr 4) and $3],6);
    set_pal_color(color_pal[gb_0.palette,(gb_0.sprt0_pal shr 6) and $3],7);
    set_pal_color(color_pal[gb_0.palette,(gb_0.sprt1_pal shr 0) and $3],8);
    set_pal_color(color_pal[gb_0.palette,(gb_0.sprt1_pal shr 2) and $3],9);
    set_pal_color(color_pal[gb_0.palette,(gb_0.sprt1_pal shr 4) and $3],10);
    set_pal_color(color_pal[gb_0.palette,(gb_0.sprt1_pal shr 6) and $3],11);
end else begin
    //Iniciar Paletas
  for f:=0 to $7fff do begin
    colores[f].r:=(f and $1f) shl 3;
    colores[f].g:=((f shr 5) and $1f) shl 3;
    colores[f].b:=((f shr 10) and $1f) shl 3;
  end;
  set_pal(colores,$8000);
end;
end;

procedure gb_change_model(gbc,unlicensed:boolean);
begin
gb_0.unlicensed:=unlicensed;
if gbc then begin //GameBoy Color
  gb_calls.read_io:=leer_io_gbc;
  gb_calls.write_io:=escribe_io_gbc;
  gb_calls.video_render:=update_video_gbc;
  gb_0.is_gbc:=true;
  lr35902_0.change_despues_instruccion(gbc_despues_instruccion);
  if not(unlicensed) then gb_0.rom_exist:=roms_load(@gb_0.bios_rom[0],gbc_rom,false,true,'gbcolor.zip');
end else begin
  gb_calls.read_io:=leer_io;
  gb_calls.write_io:=escribe_io;
  gb_calls.video_render:=update_video_gb;
  gb_0.is_gbc:=false;
  lr35902_0.change_despues_instruccion(gb_despues_instruccion);
  if not(unlicensed) then gb_0.rom_exist:=roms_load(@gb_0.bios_rom[0],gb_rom,false);
end;
gb_set_pal;
//Cambio la velocidad de la CPU! Si reseteo la CPU da igual, pero si cargo un snapshot no
lr35902_0.tframes:=((GB_CLOCK shl lr35902_0.speed)/154)/llamadas_maquina.fps_max;
sound_engine_change_clock(GB_CLOCK shl lr35902_0.speed);
end;

procedure abrir_gb;
const
  main_logo:array[0..$2f] of byte=(
  $ce,$ed,$66,$66,$cc,$0d,$00,$0B,$03,$73,$00,$83,$00,$0c,$00,$0d,
  $00,$08,$11,$1f,$88,$89,$00,$0e,$dc,$cc,$6e,$e6,$dd,$dd,$d9,$99,
  $bb,$bb,$67,$63,$6e,$0e,$ec,$cc,$dd,$dc,$99,$9f,$bb,$b9,$33,$3e);
type
  tgb_head=packed record
    none1:array[0..$103] of byte;
    logo:array[0..$2f] of byte;
    title:array[0..10] of ansichar;
    manu:array[0..3] of ansichar;
    cgb_flag:byte;
    new_license:array[0..1] of byte;
    sbg_flag:byte;
    cart_type:byte;
    rom_size:byte;
    ram_size:byte;
    region:byte;
    license:byte;
    rom_ver:byte;
    head_sum:byte;
    total_sum:word;
  end;
var
  unlicensed:boolean;
  extension,nombre_file,romfile,cadena:string;
  datos,ptemp:pbyte;
  longitud:integer;
  crc32:dword;
  f,rom_size_t:word;
  gb_head:tgb_head;
begin
  if not(openrom(romfile,SGB)) then exit;
  getmem(datos,$1000000); //8Gb??
  if not(extract_data(romfile,datos,longitud,nombre_file,SGB)) then begin
    freemem(datos);
    exit;
  end;
  extension:=extension_fichero(nombre_file);
  //Guardar NVRAM si la hay...
  if (gb_0.hay_nvram and (nv_ram_name<>'')) then write_file(nv_ram_name,@gb_mapper_0.ram_bank[0,0],$2000);
  gb_0.hay_nvram:=false;
  if extension='DSP' then snapshot_r(datos,longitud,SGB)
  else begin //Cartucho
      ptemp:=datos;
      //Copiar datos del cartucho
      copymemory(@gb_head,ptemp,sizeof(tgb_head));
      //Comprobar si está el logo de nintendo... Si no está, unlicensed
      for f:=0 to $2f do begin
        unlicensed:=(main_logo[f]<>gb_head.logo[f]);
        if unlicensed then break;
      end;
      //Detectar variantes extrañas...
      if gb_head.title='WISDOM TREE' then gb_head.cart_type:=$c0
        else if ((gb_head.title='') and (gb_head.cart_type=0) and (gb_head.rom_size=0) and (longitud>32768)) then gb_head.cart_type:=$c0;
      fillchar(gb_mapper_0.rom_bank,sizeof(gb_mapper_0.rom_bank),0);
      fillchar(gb_mapper_0.ram_bank,sizeof(gb_mapper_0.ram_bank),0);
      rom_size_t:=longitud div 16384;
      if rom_size_t=0 then rom_size_t:=1;
      for f:=0 to (rom_size_t-1) do begin
        copymemory(@gb_mapper_0.rom_bank[f,0],ptemp,$4000);
        inc(ptemp,$4000);
      end;
      if gb_head.cart_type=$c0 then begin
        rom_size_t:=longitud div 32768;
        gb_head.rom_size:=0;
        while rom_size_t<>1 do begin
          gb_head.rom_size:=gb_head.rom_size+1;
          rom_size_t:=rom_size_t shr 1;
        end;
      end;
      if longitud<32768 then begin
        if longitud>16384 then rom_size_t:=2
          else rom_size_t:=1;
      end else rom_size_t:=(32 shl gb_head.rom_size) div 16;
      gb_0.rom_exist:=false;
      gb_change_model((gb_head.cgb_flag and $80)<>0,unlicensed);
      if gb_0.is_gbc then cadena:=gb_head.title
        else cadena:=gb_head.title+gb_head.manu+ansichar(gb_head.cgb_flag);
      //Cambio el mapper!
      crc32:=calc_crc(datos,longitud);
      gb_mapper_0.set_mapper(gb_head.cart_type,crc32,rom_size_t,gb_head.ram_size);
      freemem(datos);
      if gb_0.hay_nvram then nv_ram_name:=Directory.Arcade_nvram+ChangeFileExt(nombre_file,'.nv');
      reset_gb;
  end;
  change_caption(cadena);
  directory.GameBoy:=ExtractFilePath(romfile);
end;

procedure gb_config_call;
begin
  configgb.show;
  while configgb.Showing do application.ProcessMessages;
  gb_set_pal;
end;

procedure grabar_gb;
var
  nombre:string;
begin
nombre:=snapshot_main_write(SGB);
Directory.gameboy:=ExtractFilePath(nombre);
end;

function iniciar_gb:boolean;
begin
iniciar_audio(true);
principal1.BitBtn10.Glyph:=nil;
principal1.imagelist2.GetBitmap(2,principal1.BitBtn10.Glyph);
principal1.BitBtn10.OnClick:=principal1.fLoadCartucho;
llamadas_maquina.bucle_general:=gb_principal;
llamadas_maquina.close:=cerrar_gb;
llamadas_maquina.reset:=reset_gb;
llamadas_maquina.grabar_snapshot:=grabar_gb;
llamadas_maquina.fps_max:=59.727500569605832763727500569606;
llamadas_maquina.cartuchos:=abrir_gb;
llamadas_maquina.configurar:=gb_config_call;
//Pantallas:  principal+char y sprites
screen_init(1,256,1,true);
screen_init(2,256+166+7,154);  //256 pantalla normal + 166 window + 7 de desplazamiento
iniciar_video(160,144);
//Main CPU
lr35902_0:=cpu_lr.create(GB_CLOCK,154); //154 lineas, 456 estados t por linea
lr35902_0.change_ram_calls(gb_getbyte,gb_putbyte);
lr35902_0.init_sound(gb_sound_update);
lr35902_0.change_despues_instruccion(gb_despues_instruccion);
gb_calls.read_io:=leer_io;
gb_calls.write_io:=escribe_io;
gb_calls.video_render:=update_video_gb;
gb_0.is_gbc:=false;
//Timers internos de la GB
timers.init(lr35902_0.numero_cpu,GB_CLOCK/16384,gb_main_timer,nil,true);
gb_timer:=timers.init(lr35902_0.numero_cpu,GB_CLOCK/4096,gb_prog_timer,nil,false);
//Sound Chips
gb_snd_0:=gb_sound_chip.create;
gb_mapper_0:=tgb_mapper.create;
if main_vars.console_init then abrir_gb;
iniciar_gb:=true;
end;

end.

