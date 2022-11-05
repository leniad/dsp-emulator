unit gb;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}file_engine,
     lr35902,main_engine,controls_engine,gfx_engine,timer_engine,dialogs,
     sysutils,gb_sound,rom_engine,misc_functions,pal_engine,gb_mappers,
     sound_engine,config_gb,forms;

type
  tgameboy=record
            read_io:function (direccion:byte):byte;
            write_io:procedure (direccion:byte;valor:byte);
            video_render:procedure;
            is_gbc:boolean;
  end;
  tgb_head=packed record
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
    cart_size:word;
  end;

procedure cargar_gb;

var
  ram_enable:boolean;
  gb_head:^tgb_head;
  gb_palette:byte;

implementation
uses principal;

const
  color_pal:array[0..1,0..3] of tcolor=(
  ((r:$9b;g:$bc;b:$0f),(r:$8b;g:$ac;b:$0f),(r:$30;g:$62;b:$30),(r:$0f;g:$38;b:$0f)),
  ((r:$ff;g:$ff;b:$ff),(r:$aa;g:$aa;b:$aa),(r:$55;g:$55;b:$55),(r:0;g:0;b:0)));
  gb_rom:tipo_roms=(n:'dmg_boot.bin';l:$100;p:0;crc:$59c8598e);
  gbc_rom:array[0..1] of tipo_roms=(
  (n:'gbc_boot.1';l:$100;p:0;crc:$779ea374),(n:'gbc_boot.2';l:$700;p:$200;crc:$f741807d));
  GB_CLOCK=4194304;

var
 scroll_x,stat,linea_actual,lcd_control,bg_pal,sprt0_pal,sprt1_pal:byte;
 tcontrol,tmodulo,mtimer,prog_timer,ly_compare,window_x,window_y,window_y_draw:byte;
 wram_bank:array[0..7,0..$fff] of byte;
 vram_bank:array[0..1,0..$1fff] of byte;
 io_ram,sprt_ram,bg_prio:array[0..$ff] of byte;
 bios_rom:array[0..$8ff] of byte;
 bgc_pal,spc_pal:array[0..$3f] of word;
 sprites_ord:array[0..9] of byte;
 scroll_y:array[0..$ff] of byte;
 enable_bios,rom_exist,bgcolor_inc,spcolor_inc,lcd_ena,hdma_ena:boolean;
 scroll_y_last,irq_ena,joystick,vram_nbank,wram_nbank,bgcolor_index,spcolor_index:byte;
 scroll_y_pos,dma_src,dma_dst:word;
 nombre_rom:string;
 oam_dma,haz_dma,hay_nvram,cartucho_cargado:boolean;
 oam_dma_pos,hdma_size,gb_timer,sprites_time:byte;
 gameboy:tgameboy;

procedure get_active_sprites;
var
  f,h,g,pos_x,size:byte;
  sprites_x:array[0..9] of byte;
  pos_y:integer;
  pos_linea:word;
begin
fillchar(sprites_x[0],10,$ff);
fillchar(sprites_ord[0],10,$ff);
sprites_time:=0;
for f:=0 to $27 do begin
  pos_y:=sprt_ram[$00+(f*4)];
  //Los sprites con y=0 o mayor de 159 no cuentan
  if ((pos_y=0) or (pos_y>=160)) then continue;
  //El parentesis es importante!!
  pos_linea:=linea_actual-(pos_y-16);
  size:=8 shl ((lcd_control and 4) shr 2);
  //Si el sprite esta en la linea... Lo cuento
  if (pos_linea<size) then begin
    //Los de la X siempre cuentan! Da igual si se salen fuera de la pantalla
    pos_x:=sprt_ram[$01+(f*4)];
    //Solo se puenden pintar 10
    for h:=0 to 9 do begin
      //Si la X del sprite es menor los cambio
      if sprites_x[h]>pos_x then begin
          for g:=8 downto h do begin
              sprites_x[g+1]:=sprites_x[g];
              sprites_ord[g+1]:=sprites_ord[g];
          end;
          sprites_x[h]:=pos_x;
          sprites_ord[h]:=f;
          sprites_time:=sprites_time+8;
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
  sprite_num:=sprites_ord[f];
  if sprite_num=$ff then continue;
  atrib:=sprt_ram[$03+(sprite_num*4)];
  pos_y:=sprt_ram[$00+(sprite_num*4)];
  if (atrib and $80)<>pri then continue;
  pos_y:=pos_y-16;
  pos_linea:=linea_actual-pos_y;
  pos_x:=sprt_ram[$01+(sprite_num*4)];
  if ((pos_x=0) or (pos_x>=168)) then continue;
  pos_x:=pos_x-8;
  pal:=((atrib and $10) shr 2)+4;
  num_char:=sprt_ram[$02+(sprite_num*4)];
  flipx:=(atrib and $20)<>0;
  flipy:=(atrib and $40)<>0;
  if (lcd_control and 4)=0 then begin //8x8
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
  tile_val1:=vram_bank[0,num_char*16+(def_y*2)];
  tile_val2:=vram_bank[0,num_char*16+1+(def_y*2)];
  if flipx then begin
    for x:=0 to 7 do begin
        pval:=((tile_val1 shr x) and $1)+(((tile_val2 shr x) and $1) shl 1);
        if pval=0 then ptemp^:=paleta[MAX_COLORES]
          else begin
              ptemp^:=paleta[pval+pal];
              bg_prio[(pos_x+x) and $ff]:=bg_prio[(pos_x+x) and $ff] or 1;
          end;
        inc(ptemp);
    end;
    putpixel(0,0,8,punbuf,PANT_SPRITES);
  end else begin
    for x:=7 downto 0 do begin
        pval:=((tile_val1 shr x) and $1)+(((tile_val2 shr x) and $1) shl 1);
        if pval=0 then ptemp^:=paleta[MAX_COLORES]
          else begin
              bg_prio[(pos_x+(7-x)) and $ff]:=bg_prio[(pos_x+(7-x)) and $ff] or 1;
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
  bg_addr:=$1800+((lcd_control and $8) shl 7);
  tile_mid:=(lcd_control and $10)=0;
  tile_addr:=$1000*byte(tile_mid); //Cuidado! Tiene signo despues
  for f:=0 to 31 do begin
    linea_pant:=linea_actual+scroll_y[round(f*3.5625)];
    y:=(linea_pant and $7)*2;
    if tile_mid then n2:=shortint(vram_bank[0,(bg_addr+f+((linea_pant div 8)*32)) and $1fff])
      else n2:=byte(vram_bank[0,(bg_addr+f+((linea_pant div 8)*32)) and $1fff]);
    tile_val1:=vram_bank[0,(n2*16+tile_addr+y) and $1fff];
    tile_val2:=vram_bank[0,(n2*16+tile_addr+1+y) and $1fff];
    ptemp:=punbuf;
    for x:=7 downto 0 do begin
      pval:=((tile_val1 shr x) and $1)+(((tile_val2 shr x) and $1) shl 1);
      //Prioridad con los sprites
      case prio of
        0:ptemp^:=paleta[pval];
        1:if (pval<>0) then begin
             if ((bg_prio[f*8+(7-x)] and 2)=0) then ptemp^:=paleta[pval]
              else ptemp^:=paleta[MAX_COLORES];
          end else ptemp^:=paleta[MAX_COLORES];
      end;
      inc(ptemp);
    end; //del for x
    putpixel(f*8,0,8,punbuf,1);
  end; //del for f
  //Scroll X
  if scroll_x<>0 then begin
    actualiza_trozo(0,0,scroll_x,1,1,(256-scroll_x)+7,linea_actual,scroll_x,1,2);
    actualiza_trozo(scroll_x,0,256-scroll_x,1,1,7,linea_actual,256-scroll_x,1,2);
  end else actualiza_trozo(0,0,256,1,1,7,linea_actual,256,1,2);
end;

procedure update_window(prio:byte);
var
  tile_addr,bg_addr:word;
  f,x,tile_val1,tile_val2,y,pval:byte;
  n2:integer;
  tile_mid:boolean;
  ptemp:pword;
begin
  if ((linea_actual<window_y) or (window_x>166) or (window_x=0)) then exit;
  bg_addr:=$1800+((lcd_control and $40) shl 4);
  tile_mid:=(lcd_control and $10)=0;
  tile_addr:=$1000*byte(tile_mid); //Cuidado! Tiene signo despues
  y:=(window_y_draw and $7)*2;
  for f:=0 to 31 do begin
    if tile_mid then n2:=shortint(vram_bank[0,(bg_addr+f+((window_y_draw div 8)*32)) and $1fff])
      else n2:=vram_bank[0,(bg_addr+f+((window_y_draw div 8)*32)) and $1fff];
    tile_val1:=vram_bank[0,(n2*16+tile_addr+y) and $1fff];
    tile_val2:=vram_bank[0,(n2*16+tile_addr+1+y) and $1fff];
    ptemp:=punbuf;
    for x:=7 downto 0 do begin
      pval:=((tile_val1 shr x) and $1)+(((tile_val2 shr x) and $1) shl 1);
      case prio of
        0:begin
            ptemp^:=paleta[pval];
            bg_prio[(f*8+(7-x)-(256-scroll_x)+window_x-7) and $ff]:=bg_prio[(f*8+(7-x)-(256-scroll_x)+window_x-7) and $ff] or 2;
          end;
        1:if (pval=0) then begin
            if bg_prio[(f*8+(7-x)-(256-scroll_x)+window_x-7) and $ff]=0 then ptemp^:=paleta[0]
              else ptemp^:=paleta[MAX_COLORES];
          end else ptemp^:=paleta[pval];
      end;
      inc(ptemp);
    end; //del for x
    putpixel(f*8,0,8,punbuf,1);
  end; //del for f
  actualiza_trozo(0,0,256,1,1,window_x,linea_actual,256,1,2);
end;

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
var
  f:byte;
begin
for f:=scroll_y_pos to 113 do scroll_y[f]:=scroll_y_last;
scroll_y_pos:=0;
single_line(7,linea_actual,paleta[0],160,2);
if lcd_ena then begin
  fillchar(bg_prio[0],$100,0);
  if (lcd_control and 1)<>0 then begin
    update_bg(0);
    if (lcd_control and $20)<>0 then update_window(0);
  end;
  if (((lcd_control and 2)<>0) and not(oam_dma)) then begin
    get_active_sprites;
    draw_sprites($80);
  end;
  if (lcd_control and 1)<>0 then begin
    update_bg(1);
    if (lcd_control and $20)<>0 then update_window(1);
  end;
  if (((lcd_control and 2)<>0)and not(oam_dma)) then draw_sprites(0);
  if (not((linea_actual<window_y) or (window_x>166) or (window_x=0)) and ((lcd_control and $20)<>0)) then window_y_draw:=window_y_draw+1;
end;
end;

//GBC
procedure get_active_sprites_gbc;
var
  f,size,num_sprites:byte;
  pos_y:integer;
  pos_linea:word;
begin
fillchar(sprites_ord[0],10,$ff);
sprites_time:=0;
num_sprites:=0;
for f:=0 to $27 do begin
  pos_y:=sprt_ram[$00+(f*4)];
  //Los sprites con y=0 o mayor de 159 no cuentan
  if ((pos_y=0) or (pos_y>=160)) then continue;
  //El parentesis es importante!!
  pos_linea:=linea_actual-(pos_y-16);
  size:=8 shl ((lcd_control and 4) shr 2);
  //Si el sprite esta en la linea... Lo cuento
  if (pos_linea<size) then begin
    //El orden es la prioridad en la posicion de la memoria
    sprites_ord[num_sprites]:=f;
    sprites_time:=sprites_time+(8 shr lr35902_0.speed);
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
  sprite_num:=sprites_ord[f];
  if sprite_num=$ff then continue;
  pos_y:=sprt_ram[$00+(sprite_num*4)];
  atrib:=sprt_ram[$03+(sprite_num*4)];
  if (atrib and $80)<>pri then continue;
  pos_y:=pos_y-16;
  pos_linea:=linea_actual-pos_y;
  pos_x:=sprt_ram[$01+(sprite_num*4)];
  if ((pos_x=0) or (pos_x>=168)) then continue;
  pos_x:=pos_x-8;
  pal:=(atrib and $7)*4;
  spr_bank:=(atrib shr 3) and 1;
  num_char:=sprt_ram[$02+(sprite_num*4)];
  flipx:=(atrib and $20)<>0;
  flipy:=(atrib and $40)<>0;
  if (lcd_control and 4)=0 then begin //8x8
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
  tile_val1:=vram_bank[spr_bank,num_char*16+(def_y*2)];
  tile_val2:=vram_bank[spr_bank,num_char*16+1+(def_y*2)];
  if flipx then begin
    for x:=0 to 7 do begin
      pval:=((tile_val1 shr x) and $1)+(((tile_val2 shr x) and $1) shl 1);
      if pval=0 then ptemp^:=paleta[MAX_COLORES]
        else begin
          if ((bg_prio[(pos_x+x) and $ff]) and 4)=0 then begin
            ptemp^:=paleta[(spc_pal[pval+pal]) and $7fff];
            bg_prio[(pos_x+x) and $ff]:=bg_prio[(pos_x+x) and $ff] or 1;
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
          if ((bg_prio[(pos_x+(7-x)) and $ff]) and 4)=0 then begin
            ptemp^:=paleta[(spc_pal[pval+pal]) and $7fff];
            bg_prio[(pos_x+(7-x)) and $ff]:=bg_prio[(pos_x+(7-x)) and $ff] or 1;
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
  bg_addr:=$1800+((lcd_control and $8) shl 7);
  tile_mid:=(lcd_control and $10)=0;
  tile_addr:=$1000*byte(tile_mid); //Cuidado! Tiene signo despues
  for f:=0 to 31 do begin
    linea_pant:=linea_actual+scroll_y[round(f*3.5625)];
    if tile_mid then n2:=shortint(vram_bank[0,bg_addr+(f+((linea_pant div 8)*32) and $3ff)])
      else n2:=byte(vram_bank[0,bg_addr+(f+((linea_pant div 8)*32) and $3ff)]);
    atrib:=vram_bank[1,bg_addr+(f+((linea_pant div 8)*32) and $3ff)];
    if (atrib and $40)<>0 then y:=(7-(linea_pant and $7))*2
      else y:=(linea_pant and $7)*2;
    tile_bank:=(atrib shr 3) and 1;
    tile_pal:=(atrib and 7) shl 2;
    tile_val1:=vram_bank[tile_bank,(n2*16+tile_addr+y) and $1fff];
    tile_val2:=vram_bank[tile_bank,(n2*16+tile_addr+1+y) and $1fff];
    ptemp:=punbuf;
    if (atrib and $20)<>0 then begin
      for x:=0 to 7 do begin
        pval:=((tile_val1 shr x) and $1)+(((tile_val2 shr x) and $1) shl 1);
        //Ignorar la prioridad de los sprites!
        if (((atrib and $80)<>0) and (pval<>0)) then begin
          bg_prio[(f*8+x+(256-scroll_x)) and $ff]:=bg_prio[f*8+x+(256-scroll_x)] or 4;
          ptemp^:=paleta[(bgc_pal[pval+tile_pal]) and $7fff];
        end else begin
          case prio of
            0:ptemp^:=paleta[(bgc_pal[pval+tile_pal]) and $7fff];
            1:if (pval<>0) then begin
                if ((bg_prio[(f*8+x+(256-scroll_x)+7) and $ff] and 2)=0) then ptemp^:=paleta[(bgc_pal[pval+tile_pal]) and $7fff]
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
          bg_prio[(f*8+(7-x)+(256-scroll_x)) and $ff]:=bg_prio[f*8+(7-x)+(256-scroll_x)] or 4;
          ptemp^:=paleta[bgc_pal[pval+tile_pal] and $7fff];
        end else begin
          case prio of
            0:ptemp^:=paleta[bgc_pal[pval+tile_pal] and $7fff];
            1:if (pval<>0) then begin
                if ((bg_prio[(f*8+(7-x)+(256-scroll_x)+7) and $ff] and 2)=0) then ptemp^:=paleta[(bgc_pal[pval+tile_pal]) and $7fff]
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
  if scroll_x<>0 then begin
    actualiza_trozo(0,0,scroll_x,1,1,(256-scroll_x)+7,linea_actual,scroll_x,1,2);
    actualiza_trozo(scroll_x,0,256-scroll_x,1,1,7,linea_actual,256-scroll_x,1,2);
  end else actualiza_trozo(0,0,256,1,1,7,linea_actual,256,1,2);
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
  if ((linea_actual<window_y) or (window_x>166) or (window_x=0)) then exit;
  bg_addr:=$1800+((lcd_control and $40) shl 4);
  tile_mid:=(lcd_control and $10)=0;
  tile_addr:=$1000*byte(tile_mid); //Cuidado! Tiene signo despues
  for f:=0 to 31 do begin
    if tile_mid then n2:=shortint(vram_bank[0,(bg_addr+f+((window_y_draw div 8)*32)) and $1fff])
      else n2:=byte(vram_bank[0,(bg_addr+f+((window_y_draw div 8)*32)) and $1fff]);
    atrib:=vram_bank[1,(bg_addr+f+((window_y_draw div 8)*32)) and $1fff];
    if (atrib and $40)<>0 then y:=(7-(window_y_draw and $7))*2
      else y:=(window_y_draw and $7)*2;
    tile_bank:=(atrib shr 3) and 1;
    tile_pal:=(atrib and 7) shl 2;
    tile_val1:=vram_bank[tile_bank,(n2*16+tile_addr+y) and $1fff];
    tile_val2:=vram_bank[tile_bank,(n2*16+tile_addr+1+y) and $1fff];
    ptemp:=punbuf;
    if (atrib and $20)<>0 then begin
      for x:=0 to 7 do begin
        pval:=((tile_val1 shr x) and $1)+(((tile_val2 shr x) and $1) shl 1);
        case prio of
          0:begin
              ptemp^:=paleta[bgc_pal[pval+tile_pal] and $7fff];
              bg_prio[(f*8+x-(256-scroll_x)+window_x-7) and $ff]:=bg_prio[(f*8+x-(256-scroll_x)+window_x-7) and $ff] or 2;
            end;
          1:if (pval=0) then begin
              if bg_prio[(f*8+x-(256-scroll_x)+window_x-7) and $ff]=0 then ptemp^:=paleta[bgc_pal[pval+tile_pal] and $7fff]
                else ptemp^:=paleta[MAX_COLORES];
            end else ptemp^:=paleta[bgc_pal[pval+tile_pal] and $7fff];
        end;
        inc(ptemp);
      end;
    end else begin
      for x:=7 downto 0 do begin
        pval:=((tile_val1 shr x) and $1)+(((tile_val2 shr x) and $1) shl 1);
        case prio of
          0:begin
              ptemp^:=paleta[bgc_pal[pval+tile_pal] and $7fff];
              bg_prio[(f*8+(7-x)-(256-scroll_x)+window_x-7) and $ff]:=bg_prio[(f*8+(7-x)-(256-scroll_x)+window_x-7) and $ff] or 2;
            end;
          1:if (pval=0) then begin
              if bg_prio[(f*8+(7-x)-(256-scroll_x)+window_x-7) and $ff]=0 then ptemp^:=paleta[bgc_pal[pval+tile_pal] and $7fff]
                else ptemp^:=paleta[MAX_COLORES];
            end else ptemp^:=paleta[bgc_pal[pval+tile_pal] and $7fff];
        end;
        inc(ptemp);
      end;
    end;
    putpixel(f*8,0,8,punbuf,1);
  end;
  //Pos X
  actualiza_trozo(0,0,256,1,1,window_x,linea_actual,256,1,2);
end;

//El renderizado de la GBC es igual que la GB normal, excepto por dos cosas
//Se puede hacer que el fondo tenga prioridad sobre los sprites, independientemente de la prioridad de los sprites (Intro en 007 TWNI)
//En lugar de encender/apagar el fondo, el bit se usa para priorizar los sprites sobre fondo y window, no importa la prioridad
procedure update_video_gbc;
var
  f:byte;
begin
for f:=scroll_y_pos to 113 do scroll_y[f]:=scroll_y_last;
scroll_y_pos:=0;
single_line(7,linea_actual,paleta[0],160,2);
if lcd_ena then begin
  fillchar(bg_prio[0],$100,0);
  update_bg_gbc(0);
  if (lcd_control and $20)<>0 then update_window_gbc(0);
  if (((lcd_control and 2)<>0) and not(oam_dma)) then begin
      get_active_sprites_gbc;
      draw_sprites_gbc($80);
    end;
  if (lcd_control and 1)<>0 then begin //Mirar si fondo y window pierden sus prioridades!
    update_bg_gbc(1);
    if (lcd_control and $20)<>0 then update_window_gbc(1);
  end;
  if (((lcd_control and 2)<>0) and not(oam_dma)) then draw_sprites_gbc(0);
  if (not((linea_actual<window_y) or (window_x>166) or (window_x=0)) and ((lcd_control and $20)<>0)) then window_y_draw:=window_y_draw+1;
end;
end;

procedure eventos_gb;
var
  tmp_in0:byte;
begin
if event.arcade then begin
  tmp_in0:=marcade.in0;
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  if tmp_in0<>marcade.in0 then lr35902_0.joystick_req:=true;
end;
end;

procedure cerrar_gb;
begin
if hay_nvram then write_file(nombre_rom,@ram_bank[0,0],$2000);
gameboy_sound_close;
freemem(gb_head);
end;

function leer_io(direccion:byte):byte;
var
  tempb:byte;
begin
case direccion of
  $00:begin
        //Es muy importante este orden!!! Por ejemplo Robocop Rev1 no funciona si no es asi
        if (joystick and $10)=0 then joystick:=(joystick or $f) and (marcade.in0 or $f0);
        if (joystick and $20)=0 then joystick:=(joystick or $f) and ((marcade.in0 shr 4) or $f0);
        leer_io:=joystick;
      end;
  $01:leer_io:=0;
  $02:leer_io:=$7e; //Serial
  $04:leer_io:=mtimer;
  $05:leer_io:=prog_timer;
  $06:leer_io:=tmodulo;
  $07:leer_io:=$f8 or tcontrol;
  $0f:begin
        tempb:=$e0;
        if lr35902_0.vblank_req then tempb:=tempb or $1;
        if lr35902_0.lcdstat_req then tempb:=tempb or $2;
        if lr35902_0.timer_req then tempb:=tempb or $4;
        if lr35902_0.serial_req then tempb:=tempb or $8;
        if lr35902_0.joystick_req then tempb:=tempb or $10;
        leer_io:=tempb;
      end;
  $10..$26:leer_io:=gb_sound_r(direccion-$10); //Sound
  $30..$3f:leer_io:=gb_wave_r(direccion-$30); //Sound Wav
  $40:leer_io:=lcd_control;
  $41:leer_io:=$80 or stat;
  $42:leer_io:=scroll_y_last;
  $43:leer_io:=scroll_x;
  $44:leer_io:=linea_actual;
  $45:leer_io:=ly_compare;
  $47:leer_io:=bg_pal;
  $48:leer_io:=sprt0_pal;
  $49:leer_io:=sprt1_pal;
  $4a:leer_io:=window_y;
  $4b:leer_io:=window_x;
  //$80..$fe:leer_io:=io_ram[direccion];  //high memory
  $ff:leer_io:=irq_ena;
  else leer_io:=io_ram[direccion];
end;
end;

procedure escribe_io(direccion,valor:byte);
var
  f:byte;
  addrs:word;
begin
case direccion of
  $00:joystick:=$cf or (valor and $30);
  $01:; //Serial
  $02:if (valor and $81)=$81 then lr35902_0.serial_req:=true;
  $04:mtimer:=0;
  $05:prog_timer:=valor;
  $06:tmodulo:=valor;
  $07:begin  //timer control
        tcontrol:=valor and $7;
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
  $10..$26:gb_sound_w(direccion-$10,valor); //Sound
  $30..$3f:gb_wave_w(direccion and $f,valor); //Sound Wav
  $40:begin
        lcd_control:=valor;
        lcd_ena:=(valor and $80)<>0;
        if not(lcd_ena) then stat:=stat and $fc;
      end;
  $41:stat:=(stat and $7) or (valor and $f8);
  $42:begin
        addrs:=lr35902_0.contador div 4;
        for f:=scroll_y_pos to (addrs-1) do scroll_y[f]:=valor;
        scroll_y_pos:=addrs;
        scroll_y_last:=valor;
      end;
  $43:scroll_x:=valor;
  $44:;
  $45:ly_compare:=valor;
  $46:begin //DMA trans OAM
        addrs:=valor shl 8;
        for f:=0 to $9f do begin
          case addrs of
            $0000..$7fff:sprt_ram[f]:=memoria[addrs];
            $8000..$9fff:sprt_ram[f]:=$ff; //Lee datos incorrectos
            $a000..$bfff:if @gb_mapper.ext_ram_getbyte<>nil then sprt_ram[f]:=gb_mapper.ext_ram_getbyte(addrs and $1fff)
                            else sprt_ram[f]:=$ff;
            $c000..$cfff:sprt_ram[f]:=wram_bank[0,addrs and $fff];
            $d000..$dfff:sprt_ram[f]:=wram_bank[1,addrs and $fff];
            $e000..$ffff:if @gb_mapper.ext_ram_getbyte<>nil then sprt_ram[f]:=gb_mapper.ext_ram_getbyte(addrs and $1fff) //a000
                            else sprt_ram[f]:=$ff;
          end;
          addrs:=addrs+1;
        end;
        //CUIDADO!!! La CPU no se para!! Sigue funcionando, pero la memoria NO es accesible!
        oam_dma_pos:=0;
        oam_dma:=true;
      end;
  $47:begin
        bg_pal:=valor;
        set_pal_color(color_pal[gb_palette,(valor shr 0) and $3],0);
        set_pal_color(color_pal[gb_palette,(valor shr 2) and $3],1);
        set_pal_color(color_pal[gb_palette,(valor shr 4) and $3],2);
        set_pal_color(color_pal[gb_palette,(valor shr 6) and $3],3);
      end;
  $48:begin //sprt0
        sprt0_pal:=valor;
        set_pal_color(color_pal[gb_palette,(valor shr 0) and $3],4);
        set_pal_color(color_pal[gb_palette,(valor shr 2) and $3],5);
        set_pal_color(color_pal[gb_palette,(valor shr 4) and $3],6);
        set_pal_color(color_pal[gb_palette,(valor shr 6) and $3],7);
      end;
  $49:begin
        sprt1_pal:=valor;
        set_pal_color(color_pal[gb_palette,(valor shr 0) and $3],8);
        set_pal_color(color_pal[gb_palette,(valor shr 2) and $3],9);
        set_pal_color(color_pal[gb_palette,(valor shr 4) and $3],10);
        set_pal_color(color_pal[gb_palette,(valor shr 6) and $3],11);
      end;
  $4a:window_y:=valor;
  $4b:window_x:=valor;
  $50:enable_bios:=false;  //disable ROM
  //$80..$fe:io_ram[direccion]:=valor;  //high memory
  $ff:begin  //irq enable
        irq_ena:=valor;
        lr35902_0.vblank_ena:=(valor and $1)<>0;
        lr35902_0.lcdstat_ena:=(valor and $2)<>0;
        lr35902_0.timer_ena:=(valor and $4)<>0;
        lr35902_0.serial_ena:=(valor and $8)<>0;
        lr35902_0.joystick_ena:=(valor and $10)<>0;
      end;
  else io_ram[direccion]:=valor;
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
        if (joystick and $10)=0 then joystick:=(joystick or $f) and (marcade.in0 or $f0);
        if (joystick and $20)=0 then joystick:=(joystick or $f) and ((marcade.in0 shr 4) or $f0);
        leer_io_gbc:=joystick;
      end;
  $01:leer_io_gbc:=0;
  $02:leer_io_gbc:=$7c; //Serial
  $04:leer_io_gbc:=mtimer;
  $05:leer_io_gbc:=prog_timer;
  $06:leer_io_gbc:=tmodulo;
  $07:leer_io_gbc:=$f8 or tcontrol;
  $0f:begin
        tempb:=$e0;
        if lr35902_0.vblank_req then tempb:=tempb or $1;
        if lr35902_0.lcdstat_req then tempb:=tempb or $2;
        if lr35902_0.timer_req then tempb:=tempb or $4;
        if lr35902_0.serial_req then tempb:=tempb or $8;
        if lr35902_0.joystick_req then tempb:=tempb or $10;
        leer_io_gbc:=tempb;
      end;
  $10..$26:leer_io_gbc:=gb_sound_r(direccion-$10); //Sound
//  $27..$2f:leer_io_gbc:=io_ram[direccion];
  $30..$3f:leer_io_gbc:=gb_wave_r(direccion and $f); //Sound Wav
  $40:leer_io_gbc:=lcd_control;
  $41:leer_io_gbc:=$80 or stat;
  $42:leer_io_gbc:=scroll_y_last;
  $43:leer_io_gbc:=scroll_x;
  $44:leer_io_gbc:=linea_actual;
  $45:leer_io_gbc:=ly_compare;
  $47:leer_io_gbc:=bg_pal;
  $48:leer_io_gbc:=sprt0_pal;
  $49:leer_io_gbc:=sprt1_pal;
  $4a:leer_io_gbc:=window_y;
  $4b:leer_io_gbc:=window_x;
  $4d:leer_io_gbc:=(lr35902_0.speed shl 7)+$7e+byte(lr35902_0.change_speed);
  $4f:leer_io_gbc:=$fe or vram_nbank;
  $51..$54:leer_io_gbc:=$ff;
  $55:leer_io_gbc:=hdma_size;
  $56:leer_io_gbc:=1;
  $68:leer_io_gbc:=bgcolor_index;
  $69:if (bgcolor_index and 1)<>0 then leer_io_gbc:=bgc_pal[bgcolor_index shr 1] shr 8
        else leer_io_gbc:=bgc_pal[bgcolor_index shr 1] and $ff;
  $6a:leer_io_gbc:=spcolor_index;
  $6b:if (spcolor_index and 1)<>0 then leer_io_gbc:=spc_pal[spcolor_index shr 1] shr 8
        else leer_io_gbc:=spc_pal[spcolor_index shr 1] and $ff;
  $70:leer_io_gbc:=$f8 or wram_nbank;
  $80..$fe:leer_io_gbc:=io_ram[direccion];  //high memory
  $ff:leer_io_gbc:=irq_ena;
  else begin
    //MessageDlg('IO desconocida leer pos= '+inttohex(direccion and $ff,2), mtInformation,[mbOk], 0);
    leer_io_gbc:=io_ram[direccion];
  end;
end;
end;

procedure dma_trans(size:word);
var
  f:word;
  temp:byte;
begin
for f:=0 to (size-1) do begin
  temp:=$ff;
  case dma_src of
    $0000..$7fff:temp:=memoria[dma_src];
    //$8000..$9fff:temp:=$ff;
    $a000..$bfff:if @gb_mapper.ext_ram_getbyte<>nil then temp:=gb_mapper.ext_ram_getbyte(dma_src and $1fff);
    $c000..$cfff:temp:=wram_bank[0,dma_src and $fff];
    $d000..$dfff:temp:=wram_bank[wram_nbank,dma_src and $fff];
    $e000..$ffff:if @gb_mapper.ext_ram_getbyte<>nil then temp:=gb_mapper.ext_ram_getbyte(dma_src and $1fff);
  end;
  vram_bank[vram_nbank,dma_dst and $1fff]:=temp;
  dma_dst:=dma_dst+1;
  dma_src:=dma_src+1;
end;
end;

procedure escribe_io_gbc(direccion,valor:byte);
var
  addrs:word;
  f:byte;
begin
io_ram[direccion]:=valor;
case direccion of
  $00:joystick:=$cf or (valor and $30);
  $01:; //Serial
  $02:if (valor and $81)=$81 then lr35902_0.serial_req:=true;
  $04:mtimer:=0;
  $05:prog_timer:=valor;
  $06:tmodulo:=valor;
  $07:begin  //timer control
        tcontrol:=valor and $7;
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
  $10..$26:gb_sound_w(direccion-$10,valor); //Sound
  //$27..$2f:io_ram[direccion]:=valor;
  $30..$3f:gb_wave_w(direccion and $f,valor); //Sound Wav
  $40:begin
        lcd_control:=valor;
        lcd_ena:=(valor and $80)<>0;
        if not(lcd_ena) then stat:=stat and $fc;
      end;
  $41:stat:=(stat and $7) or (valor and $f8);
  $42:begin
        addrs:=(lr35902_0.contador shr lr35902_0.speed) div 4;
        for f:=scroll_y_pos to (addrs-1) do scroll_y[f]:=valor;
        scroll_y_pos:=addrs;
        scroll_y_last:=valor;
      end;
  $43:scroll_x:=valor;
  $44:;
  $45:ly_compare:=valor;
  $46:begin //DMA trans OAM
        addrs:=valor shl 8;
        for f:=0 to $9f do begin
          case addrs of
            $0000..$7fff:sprt_ram[f]:=memoria[addrs];
            $8000..$9fff:sprt_ram[f]:=$ff; //Lee datos incorrectos
            $a000..$bfff:if @gb_mapper.ext_ram_getbyte<>nil then sprt_ram[f]:=gb_mapper.ext_ram_getbyte(addrs and $1fff)
                            else sprt_ram[f]:=$ff;
            $c000..$cfff:sprt_ram[f]:=wram_bank[0,addrs and $fff];
            $d000..$dfff:sprt_ram[f]:=wram_bank[1,addrs and $fff];
            $e000..$ffff:if @gb_mapper.ext_ram_getbyte<>nil then sprt_ram[f]:=gb_mapper.ext_ram_getbyte(addrs and $1fff) //a000
                            else sprt_ram[f]:=$ff;
          end;
          addrs:=addrs+1;
        end;
        oam_dma_pos:=0;
        oam_dma:=true;
      end;
  $47:bg_pal:=valor;
  $48:sprt0_pal:=valor;
  $49:sprt1_pal:=valor;
  $4a:window_y:=valor;
  $4b:window_x:=valor;
//  $4c:io_ram[direccion]:=valor;  //????
  $4d:lr35902_0.change_speed:=(valor and 1)<>0;  //Cambiar velocidad
  $4f:vram_nbank:=valor and 1; //VRAM Bank
  $50:enable_bios:=false;  //disable ROM
  $51:dma_src:=(dma_src and $ff) or (valor shl 8);
  $52:dma_src:=(dma_src and $ff00) or (valor and $f0);
  $53:dma_dst:=(dma_dst and $ff) or ((valor and $1f) shl 8);
  $54:dma_dst:=(dma_dst and $ff00) or (valor and $f0);
  $55:if (hdma_ena and ((valor and $80)<>0)) then begin //Cancelar la transferencia!
          hdma_ena:=false;
          hdma_size:=hdma_size or $80;
      end else begin
          if (valor and $80)<>0 then begin
            hdma_size:=valor and $7f;
            hdma_ena:=true;
          end else begin
            valor:=valor+1;
            dma_trans(valor*$10);
            lr35902_0.estados_demas:=lr35902_0.estados_demas+(220 shr lr35902_0.speed)+(8*valor);
          end;
      end;
  $56:;
  $68:begin
        bgcolor_inc:=(valor and $80)<>0;
        bgcolor_index:=valor and $3f;
      end;
  $69:begin
        if (stat and 3)<>3 then begin
          if (bgcolor_index and 1)<>0 then bgc_pal[bgcolor_index shr 1]:=(bgc_pal[bgcolor_index shr 1] and $ff) or (valor shl 8)
            else bgc_pal[bgcolor_index shr 1]:=(bgc_pal[bgcolor_index shr 1] and $ff00) or valor;
        end;
        if bgcolor_inc then bgcolor_index:=(bgcolor_index+1) and $3f;
      end;
  $6a:begin
        spcolor_inc:=(valor and $80)<>0;
        spcolor_index:=valor and $3f;
      end;
  $6b:begin
        if (stat and 3)<>3 then begin
          if (spcolor_index and 1)<>0 then spc_pal[spcolor_index shr 1]:=(spc_pal[spcolor_index shr 1] and $ff) or (valor shl 8)
            else spc_pal[spcolor_index shr 1]:=(spc_pal[spcolor_index shr 1] and $ff00) or valor;
        end;
        if spcolor_inc then spcolor_index:=(spcolor_index+1) and $3f;
      end;
  $70:begin
        wram_nbank:=valor and 7;
        if wram_nbank=0 then wram_nbank:=1;
       end;
  $7e,$7f:;
//  $80..$fe:io_ram[direccion]:=valor;  //high memory
  $ff:begin  //irq enable
        irq_ena:=valor;
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
if not(cartucho_cargado) then exit;
init_controls(false,false,false,true);
frame_m:=lr35902_0.tframes;
while EmuStatus=EsRuning do begin
  for linea_actual:=0 to 153 do begin
    lr35902_0.run(frame_m);
    frame_m:=frame_m+lr35902_0.tframes-lr35902_0.contador;
    if linea_actual<144 then gameboy.video_render;  //Modos 2-3-0
  end;
  window_y_draw:=0;
  eventos_gb;
  actualiza_trozo(7,0,160,144,2,0,0,160,144,PANT_TEMP);
  video_sync;
end;
end;

function gb_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$ff,$200..$8ff:if enable_bios then gb_getbyte:=bios_rom[direccion]
                        else gb_getbyte:=memoria[direccion];
  $0100..$1ff,$900..$3fff:gb_getbyte:=memoria[direccion];
  $4000..$7fff:gb_getbyte:=memoria[direccion];
  $8000..$9fff:gb_getbyte:=vram_bank[vram_nbank,direccion and $1fff];
  $a000..$bfff:if @gb_mapper.ext_ram_getbyte<>nil then gb_getbyte:=gb_mapper.ext_ram_getbyte(direccion)
                  else gb_getbyte:=$ff;
  $c000..$cfff,$e000..$efff:gb_getbyte:=wram_bank[0,direccion and $fff];
  $d000..$dfff,$f000..$fdff:gb_getbyte:=wram_bank[wram_nbank,direccion and $fff];
  $fe00..$fe9f:gb_getbyte:=sprt_ram[direccion and $ff];
  $fea0..$feff:if not(gameboy.is_gbc) then gb_getbyte:=0
                  else begin
                        case (direccion and $ff) of
                         $a0..$cf:gb_getbyte:=memoria[direccion];
                         $d0..$ff:gb_getbyte:=memoria[$fec0+(direccion and $f)];
                        end;
                  end;
  $ff00..$ffff:gb_getbyte:=gameboy.read_io(direccion and $ff);
end;
end;

procedure gb_putbyte(direccion:word;valor:byte);
begin
case direccion of
  $0000..$7fff:if @gb_mapper.rom_putbyte<>nil then gb_mapper.rom_putbyte(direccion,valor);
  $8000..$9fff:vram_bank[vram_nbank,direccion and $1fff]:=valor;
  $a000..$bfff:if @gb_mapper.ext_ram_putbyte<>nil then gb_mapper.ext_ram_putbyte(direccion,valor);
  $c000..$cfff,$e000..$efff:wram_bank[0,direccion and $fff]:=valor;
  $d000..$dfff,$f000..$fdff:wram_bank[wram_nbank,direccion and $fff]:=valor;
  $fe00..$fe9f:sprt_ram[direccion and $ff]:=valor;
  $fea0..$feff:if gameboy.is_gbc then begin
                  case (direccion and $ff) of
                    $a0..$cf:memoria[direccion]:=valor;
                    $d0..$ff:memoria[$fec0+(direccion and $f)]:=valor;
                  end;
               end;
  $ff00..$ffff:gameboy.write_io(direccion and $ff,valor);
end;
end;

procedure gb_despues_instruccion(estados_t:word);
var
  lcd_compare,lcd_mode:boolean;
begin
lcd_compare:=false;
lcd_mode:=false;
//Ver si estoy en OAM DMA
if oam_dma then begin
  oam_dma_pos:=oam_dma_pos+estados_t;
  if oam_dma_pos>=160 then oam_dma:=false;
end;
if not(lcd_ena) then exit;
//Si la linea es 144 y el LCD está en ON --> VBLANK
//Haaaaaack, si no lo hace en la 146 SML2 no funciona...
if ((linea_actual=146) and (lr35902_0.contador=8)) then lr35902_0.vblank_req:=true;
//CUIDADO! Cuando se activa la IRQ en la linea del LCD ya no se aceptan más IRQ en la misma linea!!
//Esto se llama STAT IRQ glitch
case lr35902_0.contador of
  8:begin
          //LY compare
          if linea_actual=ly_compare then begin
            lcd_compare:=(stat and $40)<>0;
            stat:=stat or $4;
          end else stat:=stat and $fb;
          case linea_actual of
            0..143:if ((stat and 3)<>2) then begin //Modo 2
                     lcd_mode:=(stat and $20)<>0;
                     stat:=(stat and $fc) or $2;
                   end;
            144:if ((stat and 3)<>1) then begin
                  //Modo 1
                  lcd_mode:=(stat and $10)<>0;
                  stat:=(stat and $fc) or $1;
                end;
          end;
        end;
  88:if ((linea_actual<144) and ((stat and 3)<>3)) then begin //Modo 3
             lcd_mode:=((stat and $20)<>0) and ((stat and $10)=0);
             stat:=(stat and $fc) or $3;
          end;
  252..600:if ((linea_actual<144) and ((sprites_time+252)>=lr35902_0.contador) and ((stat and 3)<>0)) then begin //Modo 0
                lcd_mode:=((stat and $8)<>0) and ((stat and $20)=0);
                stat:=stat and $fc;
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
//Ver si estoy en OAM DMA
if oam_dma then begin
  oam_dma_pos:=oam_dma_pos+(estados_t shr lr35902_0.speed);;
  if oam_dma_pos>=160 then oam_dma:=false;
end;
if lr35902_0.changed_speed then begin
  lr35902_0.tframes:=round(((GB_CLOCK shl lr35902_0.speed)/154)/llamadas_maquina.fps_max);
  sound_engine_change_clock(GB_CLOCK shl lr35902_0.speed);
  lr35902_0.changed_speed:=false;
end;
if not(lcd_ena) then exit;
contador:=lr35902_0.contador shr lr35902_0.speed;
if ((linea_actual=144) and (contador=8)) then lr35902_0.vblank_req:=true;  //int 40!!
case contador of
    8:begin
            haz_dma:=false;
            //LY compare
            if linea_actual=ly_compare then begin
               lcd_compare:=(stat and $40)<>0;
               stat:=stat or $4;
            end else stat:=stat and $fb;
            case linea_actual of
              0..143:if ((stat and 3)<>2) then begin //Mode 2
                     lcd_mode:=(stat and $20)<>0;
                     stat:=(stat and $fc) or $2;
                   end;
              144:if ((stat and 3)<>1) then begin
                  lcd_mode:=((stat and $10)<>0);
                  stat:=(stat and $fc) or $1;
                end;
            end;
          end;
  88:if ((linea_actual<144) and ((stat and 3)<>3)) then begin //Modo 3
             lcd_mode:=((stat and $20)<>0) and ((stat and $10)=0);
             stat:=(stat and $fc) or $3;
          end;
  252..600:if (linea_actual<144) then begin
              if ((contador>=308) and hdma_ena and not(haz_dma)) then begin //DMA H-Blank
                  dma_trans($10);
                  hdma_size:=hdma_size-1;
                  if hdma_size=$ff then hdma_ena:=false;
                  lr35902_0.contador:=lr35902_0.contador+8;
                  haz_dma:=true;
              end;
              if (((sprites_time+252)>=contador) and ((stat and 3)<>0)) then begin   //Modo 0
                lcd_mode:=((stat and $8)<>0) and ((stat and $20)=0);
                stat:=stat and $fc;
              end;
           end;
end;
lr35902_0.lcdstat_req:=lr35902_0.lcdstat_req or lcd_compare or lcd_mode;
end;


//Sonido and timers
procedure gb_main_timer;
begin
  mtimer:=mtimer+1;
end;

//Main
procedure reset_gb;
var
  lr_reg:reg_lr;
begin
 lr35902_0.tframes:=(GB_CLOCK/154)/llamadas_maquina.fps_max;
 sound_engine_change_clock(GB_CLOCK);
 lr35902_0.reset;
 reset_audio;
 gameboy_sound_reset;
 scroll_x:=0;
 fillchar(scroll_y[0],$ff,0);
 fillchar(io_ram[0],$ff,0);
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
 fillchar(sprt_ram[0],$ff,0);
 fillchar(bgc_pal[0],$ff,0);
 fillchar(bgc_pal[0],$ff,0);
 scroll_y_pos:=0;
 scroll_y_last:=0;
 stat:=0;
 tmodulo:=0;
 mtimer:=0;
 prog_timer:=0;
 rom_nbank:=0;
 ram_nbank:=0;
 vram_nbank:=0;
 wram_nbank:=1;
 ly_compare:=$ff;
 irq_ena:=0;
 marcade.in0:=$ff;
 joystick:=$ff;
 hdma_ena:=false;
 hdma_size:=$ff;
 lcd_control:=$80;
 lcd_ena:=true;
 oam_dma_pos:=0;
 oam_dma:=false;
 window_y_draw:=0;
 bg_pal:=0;
 sprt0_pal:=0;
 sprt1_pal:=0;
 window_x:=0;
 window_y:=0;

 {
 tcontrol:byte;
 bgc_pal,spc_pal:array[0..$3f] of word;
 enable_bios,rom_exist,bgcolor_inc,spcolor_inc,hdma_ena:boolean;
 bgcolor_index,spcolor_index:byte;
 dma_src,dma_dst:word;
 gb_timer,sprites_time:byte;}


 if not(rom_exist) then begin
   enable_bios:=false;
   lr_reg.pc:=$100;
   lr_reg.sp:=$fffe;
   lr_reg.f.z:=true;
   lr_reg.f.n:=false;
   if (gb_head.cgb_flag and $80)<>0 then begin
     lr_reg.a:=$11;
     lr_reg.f.h:=false;
     lr_reg.f.c:=false;
     lr_reg.BC.w:=$0;
     lr_reg.DE.w:=$ff56;
     lr_reg.HL.w:=$000d;
   end else begin
     lr_reg.a:=$01;
     lr_reg.f.h:=true;
     lr_reg.f.c:=true;
     lr_reg.BC.w:=$0013;
     lr_reg.DE.w:=$00D8;
     lr_reg.HL.w:=$014D;
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
   end;
   lr35902_0.set_internal_r(@lr_reg);
  end else enable_bios:=true;
  gb_mapper_reset(gb_head.cart_type);
end;

procedure gb_prog_timer;
begin
  prog_timer:=prog_timer+1;
  if prog_timer=0 then begin
    prog_timer:=tmodulo;
    lr35902_0.timer_req:=true; //timer request irq
  end;
end;

type
  tgb_logo=packed record
    none1:array[0..$103] of byte;
    logo:array[0..$2f] of byte;
  end;

procedure abrir_gb;
const
  main_logo:array[0..$2f] of byte=(
  $CE,$ED,$66,$66,$CC,$0D,$00,$0B,$03,$73,$00,$83,$00,$0C,$00,$0D,
  $00,$08,$11,$1F,$88,$89,$00,$0E,$DC,$CC,$6E,$E6,$DD,$DD,$D9,$99,
  $BB,$BB,$67,$63,$6E,$0E,$EC,$CC,$DD,$DC,$99,$9F,$BB,$B9,$33,$3E);
var
  mal,resultado:boolean;
  extension,nombre_file,RomFile,dir,cadena:string;
  datos,ptemp:pbyte;
  longitud,crc:integer;
  f,h:word;
  colores:tpaleta;
  gb_logo:^tgb_logo;
  crc32:dword;
begin
  if not(OpenRom(StGb,RomFile)) then exit;
  getmem(gb_logo,sizeof(tgb_logo));
  gameboy.read_io:=leer_io;
  gameboy.write_io:=escribe_io;
  gameboy.video_render:=update_video_gb;
  gameboy.is_gbc:=false;
  lr35902_0.change_despues_instruccion(gb_despues_instruccion);
  extension:=extension_fichero(RomFile);
  resultado:=false;
  if extension='ZIP' then begin
    if not(search_file_from_zip(RomFile,'*.gb',nombre_file,longitud,crc,false)) then
      if not(search_file_from_zip(RomFile,'*.gbc',nombre_file,longitud,crc,false)) then begin
        MessageDlg('Error cargando snapshot/ROM.'+chr(10)+chr(13)+'Error loading the snapshot/ROM.', mtInformation,[mbOk], 0);
        exit;
      end;
    getmem(datos,longitud);
    if not(load_file_from_zip(RomFile,nombre_file,datos,longitud,crc,true)) then begin
      freemem(datos);
      freemem(gb_logo);
    end else resultado:=true;
  end else begin
    if ((extension<>'GB') and (extension<>'GBC')) then begin
      MessageDlg('Error cargando snapshot/ROM.'+chr(10)+chr(13)+'Error loading the snapshot/ROM.', mtInformation,[mbOk], 0);
      exit;
    end;
    if read_file_size(RomFile,longitud) then begin
      getmem(datos,longitud);
      if not(read_file(RomFile,datos,longitud)) then begin
        freemem(datos);
        freemem(gb_logo);
      end else resultado:=true;
      nombre_file:=extractfilename(RomFile);
    end;
  end;
  if not(resultado) then begin
    MessageDlg('Error cargando snapshot/ROM.'+chr(10)+chr(13)+'Error loading the snapshot/ROM.', mtInformation,[mbOk], 0);
    exit;
  end;
  ptemp:=datos;
  //Comprobar si hay una cabecera extra delante, detras me da igual...
  copymemory(gb_logo,ptemp,sizeof(tgb_logo));
  if (longitud mod $2000)<>0 then begin
    //Esta delante? --> No estara el logo de Nintendo
    for f:=0 to $2f do begin
       mal:=(main_logo[f]=gb_logo.logo[f]);
       if not(mal) then break;
    end;
    if not(mal) then inc(ptemp,longitud mod $2000);
  end;
  inc(ptemp,sizeof(tgb_logo));
  copymemory(gb_head,ptemp,sizeof(tgb_head));
  dec(ptemp,sizeof(tgb_logo));
  //Is GBC?
  if (gb_head.cgb_flag and $80)<>0 then begin
    gameboy.read_io:=leer_io_gbc;
    gameboy.write_io:=escribe_io_gbc;
    gameboy.video_render:=update_video_gbc;
    gameboy.is_gbc:=true;
    lr35902_0.change_despues_instruccion(gbc_despues_instruccion);
  end;
  if hay_nvram then write_file(nombre_rom,@ram_bank[0,0],$2000);
  nombre_rom:=Directory.Arcade_nvram+ChangeFileExt(nombre_file,'.nv');
  hay_nvram:=false;
  crc32:=calc_crc(ptemp,longitud);
  if longitud<32768 then begin
    if longitud>16384 then begin
      gb_head.rom_size:=2;
      gb_head.cart_size:=2;
    end else begin
      gb_head.rom_size:=1;
      gb_head.cart_size:=1;
    end;
  end else begin
    gb_head.cart_size:=(32 shl gb_head.rom_size) div 16;
  end;
  for f:=0 to (gb_head.cart_size-1) do begin
    copymemory(@rom_bank[f,0],ptemp,$4000);
    inc(ptemp,$4000);
  end;
  gb_mapper.ext_ram_getbyte:=nil;
  gb_mapper.ext_ram_putbyte:=nil;
  gb_mapper.rom_putbyte:=nil;
  mal:=true;
  case gb_head.cart_type of
    0:mal:=false; //No mapper
    $01..$03:begin  //mbc1
          gb_mapper.rom_putbyte:=gb_putbyte_mbc1;
          case crc32 of
            $b91d6c8d,$509a6b73,$f724b5ce,$b1a8dfd0,$339f1694,$ad376905,$7d1d8fdc,$18b4a02:begin
                mbc1_mask:=$f;
                mbc1_shift:=4;
            end;
            else begin
                    mbc1_mask:=$1f;
                    mbc1_shift:=5;
                 end;
          end;
          case gb_head.cart_type of
            1:;
            2:begin //RAM
                gb_mapper.ext_ram_getbyte:=gb_get_ext_ram_mbc1;
                gb_mapper.ext_ram_putbyte:=gb_put_ext_ram_mbc1;
              end;
            3:begin //RAM + Battery
                gb_mapper.ext_ram_getbyte:=gb_get_ext_ram_mbc1;
                gb_mapper.ext_ram_putbyte:=gb_put_ext_ram_mbc1;
                if read_file_size(nombre_rom,longitud) then read_file(nombre_rom,@ram_bank[0,0],longitud);
                hay_nvram:=true;
              end;
          end;
        mal:=false;
      end;
      $5,$6:begin //mbc2
        gb_mapper.rom_putbyte:=gb_putbyte_mbc2;
        gb_mapper.ext_ram_getbyte:=gb_get_ext_ram_mbc2;
        gb_mapper.ext_ram_putbyte:=gb_put_ext_ram_mbc2;
        gb_head.ram_size:=0;
        if gb_head.cart_type=6 then begin //Battery (No extra RAM!)
           if read_file_size(nombre_rom,longitud) then read_file(nombre_rom,@ram_bank[0,0],longitud);
           hay_nvram:=true;
        end;
        mal:=false;
      end;
      $b..$d:begin //mmm01
            gb_mapper.rom_putbyte:=gb_putbyte_mmm01;
            gb_mapper.ext_ram_getbyte:=gb_get_ext_ram_mmm01;
            gb_mapper.ext_ram_putbyte:=gb_put_ext_ram_mmm01;
            mal:=false;
          end;
      $f..$13:begin //mbc3
            gb_mapper.rom_putbyte:=gb_putbyte_mbc3;
            case gb_head.cart_type of
                $f:begin //Timer + Battery
                      if read_file_size(nombre_rom,longitud) then read_file(nombre_rom,@ram_bank[0,0],longitud);
                      hay_nvram:=true;
                   end;
                $10,$13:begin //[Timer] + RAM + Battery
                      gb_mapper.ext_ram_getbyte:=gb_get_ext_ram_mbc3;
                      gb_mapper.ext_ram_putbyte:=gb_put_ext_ram_mbc3;
                      if read_file_size(nombre_rom,longitud) then read_file(nombre_rom,@ram_bank[0,0],longitud);
                      hay_nvram:=true;
                    end;
                $11:;
                $12:begin //RAM
                      gb_mapper.ext_ram_getbyte:=gb_get_ext_ram_mbc3;
                      gb_mapper.ext_ram_putbyte:=gb_put_ext_ram_mbc3;
                end;
            end;
            mal:=false;
          end;
      $19..$1e:begin //mbc5
          gb_mapper.rom_putbyte:=gb_putbyte_mbc5;
          case gb_head.cart_type of
            $19,$1c:; // [Rumble]
            $1a,$1d:begin //RAM + [Rumble]
                      gb_mapper.ext_ram_getbyte:=gb_get_ext_ram_mbc5;
                      gb_mapper.ext_ram_putbyte:=gb_put_ext_ram_mbc5;
                    end;
            $1b,$1e:begin //RAM + Battery + [Rumble]
                      gb_mapper.ext_ram_getbyte:=gb_get_ext_ram_mbc5;
                      gb_mapper.ext_ram_putbyte:=gb_put_ext_ram_mbc5;
                      if read_file_size(nombre_rom,longitud) then read_file(nombre_rom,@ram_bank[0,0],longitud);
                      hay_nvram:=true;
                    end;
          end;
          mal:=false;
         end;
      $22:begin //RAM + Acelerometro
             gb_mapper.rom_putbyte:=gb_putbyte_mbc7;
             gb_mapper.ext_ram_getbyte:=gb_get_ext_ram_mbc7;
             gb_mapper.ext_ram_putbyte:=gb_put_ext_ram_mbc7;
             mal:=false;
          end;
      $ff:begin //HuC-1 (RAM+Battery)
            gb_mapper.rom_putbyte:=gb_putbyte_huc1;
            gb_mapper.ext_ram_getbyte:=gb_get_ext_ram_huc1;
            gb_mapper.ext_ram_putbyte:=gb_put_ext_ram_huc1;
            if read_file_size(nombre_rom,longitud) then read_file(nombre_rom,@ram_bank[0,0],longitud);
            hay_nvram:=true;
            mal:=false;
          end;
      else MessageDlg('Mapper '+inttohex(gb_head.cart_type,2)+' no implementado', mtInformation,[mbOk], 0);
  end;
  cadena:='';
  if not(mal) then begin
    if (gb_head.cgb_flag and $80)<>0 then begin //GameBoy Color
      dir:=directory.arcade_list_roms[find_rom_multiple_dirs('gbcolor.zip')];
      cadena:=gb_head.title;
      rom_exist:=false;
      if carga_rom_zip(dir+'gbcolor.zip',gbc_rom[0].n,@bios_rom[0],gbc_rom[0].l,gbc_rom[0].crc,false) then
        if rom_exist or carga_rom_zip(dir+'gbcolor.zip',gbc_rom[1].n,@bios_rom[gbc_rom[1].p],gbc_rom[1].l,gbc_rom[1].crc,false) then rom_exist:=true;
      //Iniciar Paletas
      for h:=0 to $7fff do begin
        colores[h].r:=(h and $1F) shl 3;
    	  colores[h].g:=((h shr 5) and $1F) shl 3;
    	  colores[h].b:=((h shr 10) and $1F) shl 3;
      end;
      set_pal(colores,$8000);
      for f:=0 to $1f do bgc_pal[f]:=$7fff;
      for f:=0 to $1f do spc_pal[f]:=0;
    end else begin
      dir:=directory.arcade_list_roms[find_rom_multiple_dirs('gameboy.zip')];
      rom_exist:=carga_rom_zip(dir+'gameboy.zip',gb_rom.n,@bios_rom[0],gb_rom.l,gb_rom.crc,false);
      cadena:=gb_head.title+gb_head.manu+ansichar(gb_head.cgb_flag);
    end;
  end;
  change_caption(cadena);
  cartucho_cargado:=true;
  freemem(datos);
  freemem(gb_logo);
  reset_gb;
  directory.GameBoy:=ExtractFilePath(romfile);
end;

function iniciar_gb:boolean;
begin
iniciar_audio(true);
//Pantallas:  principal+char y sprites
screen_init(1,256,1,true);
screen_init(2,256+166+7,154);  //256 pantalla normal + 166 window + 7 de desplazamiento
iniciar_video(160,144);
//iniciar_video(512,512);
//Main CPU
lr35902_0:=cpu_lr.Create(GB_CLOCK,154); //154 lineas, 456 estados t por linea
lr35902_0.change_ram_calls(gb_getbyte,gb_putbyte);
lr35902_0.init_sound(gameboy_sound_update);
//Timers internos de la GB
timers.init(0,GB_CLOCK/16384,gb_main_timer,nil,true);
gb_timer:=timers.init(0,GB_CLOCK/4096,gb_prog_timer,nil,false);
//Sound Chips
gameboy_sound_ini(FREQ_BASE_AUDIO);
//cargar roms
hay_nvram:=false;
//final
getmem(gb_head,sizeof(tgb_head));
fill_full_screen(PANT_TEMP,$100);
actualiza_video;
if main_vars.console_init then abrir_gb;
iniciar_gb:=true;
end;

procedure gb_config_call;
begin
  configgb.show;
  while configgb.Showing do application.ProcessMessages;
  if not(gameboy.is_gbc) then begin
    set_pal_color(color_pal[gb_palette,(bg_pal shr 0) and $3],0);
    set_pal_color(color_pal[gb_palette,(bg_pal shr 2) and $3],1);
    set_pal_color(color_pal[gb_palette,(bg_pal shr 4) and $3],2);
    set_pal_color(color_pal[gb_palette,(bg_pal shr 6) and $3],3);
    set_pal_color(color_pal[gb_palette,(sprt0_pal shr 0) and $3],4);
    set_pal_color(color_pal[gb_palette,(sprt0_pal shr 2) and $3],5);
    set_pal_color(color_pal[gb_palette,(sprt0_pal shr 4) and $3],6);
    set_pal_color(color_pal[gb_palette,(sprt0_pal shr 6) and $3],7);
    set_pal_color(color_pal[gb_palette,(sprt1_pal shr 0) and $3],8);
    set_pal_color(color_pal[gb_palette,(sprt1_pal shr 2) and $3],9);
    set_pal_color(color_pal[gb_palette,(sprt1_pal shr 4) and $3],10);
    set_pal_color(color_pal[gb_palette,(sprt1_pal shr 6) and $3],11);
  end;
end;

procedure Cargar_gb;
begin
principal1.BitBtn10.Glyph:=nil;
principal1.imagelist2.GetBitmap(2,principal1.BitBtn10.Glyph);
principal1.BitBtn10.OnClick:=principal1.fLoadCartucho;
llamadas_maquina.iniciar:=iniciar_gb;
llamadas_maquina.bucle_general:=gb_principal;
llamadas_maquina.close:=cerrar_gb;
llamadas_maquina.reset:=reset_gb;
llamadas_maquina.fps_max:=59.727500569605832763727500569606;
llamadas_maquina.cartuchos:=abrir_gb;
cartucho_cargado:=false;
llamadas_maquina.configurar:=gb_config_call;
end;

end.

