unit vars_hide;

interface
{$IFDEF windows}uses windows;{$ENDIF}

type
  scroll_tipo=record
          long_x,long_y:word;  //Longitud de la pantalla
          max_x,max_y:word;    //Longitud que debe copiar
          mask_x,mask_y:word;  //Mascara del scroll
        end;
  tpantalla=record
                x:word;  //ancho
                y:word;  //alto
                x_real,y_real:word; //tamaño real en caso de rotacion
                trans:boolean;  //¿es transparente?
                final_mix:boolean;
                sprite_end_x,sprite_end_y,sprite_mask_x,sprite_mask_y:word;
                scroll:scroll_tipo;
        end;
  tipo_sprites=record
    pos_planos:array[0..7] of dword;
    bit_pixel:byte;
    long_sprites:dword;
    banks:byte;
  end;
  Parejas = record
          case byte of
             0: (l, h: byte);
             1: (w: word);
          end;
  Parejas680X = record
          case byte of
             0: (b, a: byte);
             1: (w: word);
        end;
  pparejas=^parejas;
  DParejas = record
          case byte of
             0: (l0,h0,l1,h1: byte);
             1: (wl,wh: word);
             2: (l:dword);
          end;
  pdparejas=^dparejas;

const
  max_pantalla=24;

var
  p_final:array[0..max_pantalla] of tpantalla;
  des_gfx:tipo_sprites;

implementation

end.
