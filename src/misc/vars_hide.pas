unit vars_hide;

interface
{$IFDEF windows}uses windows;{$ENDIF}

type
  tpantalla=record
                x:word;  //ancho
                y:word;  //alto
                trans:boolean;  //¿es transparente?
                final_mix,alpha:boolean;
                sprite_end_x,sprite_end_y,sprite_mask_x,sprite_mask_y:word;
                mask_x,mask_y:word;
        end;
  tipo_sprites=record
    pos_planos:array[0..7] of dword;
    bit_pixel:byte;
    long_sprites:dword;
    banks:byte;
  end;
  parejas=record
          case byte of
             0:(l,h:byte);
             1:(w:word);
          end;
  pparejas=^parejas;
  parejas680X = record
          case byte of
             0:(b,a:byte);
             1:(w:word);
        end;
  DParejas = record
          case byte of
             0:(l0,h0,l1,h1:byte);
             1:(wl,wh:word);
             2:(l:dword);
          end;
  pdparejas=^dparejas;

const
  MAX_PANTALLA=24;

var
  p_final:array[0..MAX_PANTALLA] of tpantalla;
  des_gfx:tipo_sprites;
  scroll_final_x,scroll_final_y:word;

implementation

end.
