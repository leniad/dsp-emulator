unit konami_video;

interface
uses gfx_engine;

procedure K007121_reset(num:byte);
procedure K007121_draw_sprites(num,screen,x_sinc:byte;color_base:word;flip_all:boolean);

type
  K007121_type=record
    sprite_ram:array[0..$7ff] of byte;
    control:array[0..7] of byte;
  end;

var
   K007121_chip:array[0..1] of K007121_type;

implementation

procedure K007121_reset(num:byte);
var
  f:byte;
begin
  for f:=0 to 7 do K007121_chip[num].control[f]:=0;
  fillchar(K007121_chip[num].sprite_ram[0],$800,0);
end;

procedure K007121_draw_sprites(num,screen,x_sinc:byte;color_base:word;flip_all:boolean);
//Esta que averigüe como hacerlo...
const
  tipo_2x2:array[0..1,0..3] of byte=((0,1,2,3),(1,3,0,2));
  tipo_2x1:array[0..1,0..1] of byte=((1,0),(0,1));
  tipo_1x2:array[0..1,0..1] of byte=((2,0),(0,2));
  tipo_4x4:array[0..1,0..15] of byte=((2,0,3,1,6,4,7,5,10,8,11,9,14,12,15,13),
           (4,5,6,7,12,13,14,15,0,1,2,3,8,9,10,11));
var
  f,atrib,sprite_bank:byte;
  x_tmp1,x_tmp2,x_tmp3,x_tmp4,y_tmp1,y_tmp2,y_tmp3,y_tmp4:byte;
  nchar,color,sx,sy:word;
  flip_x,flip_y,tipo_gfx:byte;
begin
 { byte | Bit(s)   | Use
 * -----+-76543210-+----------------
 *   0  | xxxxxxxx | sprite code
 *   1  | xxxx---- | color
 *   1  | ----xx-- | sprite code low 2 bits for 16x8/8x8 sprites
 *   1  | ------xx | sprite code bank bits 1/0
 *   2  | xxxxxxxx | y position
 *   3  | xxxxxxxx | x position (low 8 bits)
 *   4  | xx------ | sprite code bank bits 3/2
 *   4  | --x----- | flip y
 *   4  | ---x---- | flip x
 *   4  | ----xxx- | sprite size 000=16x16 001=16x8 010=8x16 011=8x8 100=32x32
 *   4  | -------x | x position (high bit)}
  for f:=0 to $3f do begin
    //variables
		sprite_bank:=K007121_chip[num].sprite_ram[$1+(f*$5)] and $0f;
    atrib:=K007121_chip[num].sprite_ram[$4+(f*$5)];
    if flip_all then begin
  		sx:=224-(K007121_chip[num].sprite_ram[$2+(f*$5)]+((atrib and $1) shl 8));
      sy:=K007121_chip[num].sprite_ram[$3+(f*$5)];
      flip_y:=(atrib and $10) shr 1;
      flip_x:=(atrib and $20) shr 2;
      tipo_gfx:=0;
    end else begin
      sx:=K007121_chip[num].sprite_ram[$3+(f*$5)]+((atrib and $1) shl 8);
  		sy:=K007121_chip[num].sprite_ram[$2+(f*$5)];
      flip_x:=(atrib and $10) shr 1;
      flip_y:=(atrib and $20) shr 2;
      tipo_gfx:=1;
    end;
		color:=(color_base+((K007121_chip[num].sprite_ram[$1+(f*$5)] and $f0) shr 4)) shl 4;
		//calcular numero de char
    nchar:=K007121_chip[num].sprite_ram[f*$5]+(((sprite_bank and $3) shl 8)+((atrib and $c0) shl 4));
		nchar:=nchar shl 2;
		nchar:=nchar+((sprite_bank shr 2) and 3);
    case (atrib and $e) of
         $00:begin //2x y 2x
              x_tmp3:=flip_x;
              x_tmp1:=flip_x xor 8;
              y_tmp1:=flip_y;
              y_tmp3:=flip_y xor 8;
              put_gfx_sprite_diff(nchar+tipo_2x2[tipo_gfx,0],color,flip_x<>0,flip_y<>0,num,x_tmp1,y_tmp1);
              put_gfx_sprite_diff(nchar+tipo_2x2[tipo_gfx,1],color,flip_x<>0,flip_y<>0,num,x_tmp1,y_tmp3);
              put_gfx_sprite_diff(nchar+tipo_2x2[tipo_gfx,2],color,flip_x<>0,flip_y<>0,num,x_tmp3,y_tmp1);
              put_gfx_sprite_diff(nchar+tipo_2x2[tipo_gfx,3],color,flip_x<>0,flip_y<>0,num,x_tmp3,y_tmp3);
              actualiza_gfx_sprite_size(sx+x_sinc,sy,screen,16,16);
            end;
			   $02:begin //2x ancho y 1x largo
              x_tmp1:=flip_x xor 8;
              x_tmp3:=flip_x;
              put_gfx_sprite_diff(nchar+tipo_2x1[tipo_gfx,0],color,flip_x<>0,flip_y<>0,num,x_tmp3,0);
              put_gfx_sprite_diff(nchar+tipo_2x1[tipo_gfx,1],color,flip_x<>0,flip_y<>0,num,x_tmp1,0);
              actualiza_gfx_sprite_size(sx+x_sinc,sy,screen,16,8);
            end;
        $04:begin //1x ancho y 2x largo
              y_tmp1:=flip_y;
              y_tmp3:=flip_y xor 8;
              put_gfx_sprite_diff(nchar+tipo_1x2[tipo_gfx,0],color,flip_x<>0,flip_y<>0,num,0,y_tmp1);
              put_gfx_sprite_diff(nchar+tipo_1x2[tipo_gfx,1],color,flip_x<>0,flip_y<>0,num,0,y_tmp3);
              actualiza_gfx_sprite_size(sx+x_sinc,sy,screen,8,16);
            end;
			 	$08:begin //4x alto y 4x ancho
              if flip_x<>0 then begin
                x_tmp1:=8;x_tmp2:=24;x_tmp3:=0;x_tmp4:=16;
              end else begin
                x_tmp1:=16;x_tmp2:=0;x_tmp3:=24;x_tmp4:=8;
              end;
              if flip_y<>0 then begin
                y_tmp1:=24;y_tmp2:=8;y_tmp3:=16;y_tmp4:=0;
              end else begin
                y_tmp1:=0;y_tmp2:=16;y_tmp3:=8;y_tmp4:=24;
              end;
              //0
              put_gfx_sprite_diff(nchar+tipo_4x4[tipo_gfx,0],color,flip_x<>0,flip_y<>0,num,x_tmp1,y_tmp1);
              put_gfx_sprite_diff(nchar+tipo_4x4[tipo_gfx,1],color,flip_x<>0,flip_y<>0,num,x_tmp3,y_tmp1);
              put_gfx_sprite_diff(nchar+tipo_4x4[tipo_gfx,2],color,flip_x<>0,flip_y<>0,num,x_tmp1,y_tmp3);
              put_gfx_sprite_diff(nchar+tipo_4x4[tipo_gfx,3],color,flip_x<>0,flip_y<>0,num,x_tmp3,y_tmp3);
              //1
              put_gfx_sprite_diff(nchar+tipo_4x4[tipo_gfx,4],color,flip_x<>0,flip_y<>0,num,x_tmp1,y_tmp2);
              put_gfx_sprite_diff(nchar+tipo_4x4[tipo_gfx,5],color,flip_x<>0,flip_y<>0,num,x_tmp3,y_tmp2);
              put_gfx_sprite_diff(nchar+tipo_4x4[tipo_gfx,6],color,flip_x<>0,flip_y<>0,num,x_tmp1,y_tmp4);
              put_gfx_sprite_diff(nchar+tipo_4x4[tipo_gfx,7],color,flip_x<>0,flip_y<>0,num,x_tmp3,y_tmp4);
              //2
              put_gfx_sprite_diff(nchar+tipo_4x4[tipo_gfx,8],color,flip_x<>0,flip_y<>0,num,x_tmp2,y_tmp1);
              put_gfx_sprite_diff(nchar+tipo_4x4[tipo_gfx,9],color,flip_x<>0,flip_y<>0,num,x_tmp4,y_tmp1);
              put_gfx_sprite_diff(nchar+tipo_4x4[tipo_gfx,10],color,flip_x<>0,flip_y<>0,num,x_tmp2,y_tmp3);
              put_gfx_sprite_diff(nchar+tipo_4x4[tipo_gfx,11],color,flip_x<>0,flip_y<>0,num,x_tmp4,y_tmp3);
              //3
              put_gfx_sprite_diff(nchar+tipo_4x4[tipo_gfx,12],color,flip_x<>0,flip_y<>0,num,x_tmp2,y_tmp2);
              put_gfx_sprite_diff(nchar+tipo_4x4[tipo_gfx,13],color,flip_x<>0,flip_y<>0,num,x_tmp4,y_tmp2);
              put_gfx_sprite_diff(nchar+tipo_4x4[tipo_gfx,14],color,flip_x<>0,flip_y<>0,num,x_tmp2,y_tmp4);
              put_gfx_sprite_diff(nchar+tipo_4x4[tipo_gfx,15],color,flip_x<>0,flip_y<>0,num,x_tmp4,y_tmp4);
              actualiza_gfx_sprite_size(sx,sy,screen,32,32);
            end;
        else begin
              put_gfx_sprite(nchar,color,flip_x<>0,flip_y<>0,num);
              actualiza_gfx_sprite(sx+x_sinc,sy,screen,num);
            end;
    end;
  end;
end;

end.
