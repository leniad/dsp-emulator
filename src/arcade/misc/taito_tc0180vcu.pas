unit taito_tc0180vcu;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}main_engine,gfx_engine;

type
  tc0180vcu_chip=class
    constructor create(txt_color,bg_color,fg_color,gen_color:word);
    destructor free;
    public
      function read(direccion:dword):word;
      procedure write(direccion:dword;valor:word);
      procedure draw;
      procedure draw_sprites;
    private
      fg_rambank,bg_rambank:array[0..1] of word;
      tx_rambank:word;
      framebuffer_page:byte;
      video_control:byte;
      fb_color_base,bg_color_base,fg_color_base,tx_color_base:word;
      ctrl:array[0..$f] of word;
      ram:array[0..$9fff] of word;
  end;

var
  tc0180vcu_0:tc0180vcu_chip;

implementation

constructor tc0180vcu_chip.create(txt_color,bg_color,fg_color,gen_color:word);
begin
  self.tx_color_base:=txt_color;
  self.bg_color_base:=bg_color;
  self.fg_color_base:=fg_color;
  self.fb_color_base:=gen_color shl 4;
end;

destructor tc0180vcu_chip.free;
begin
end;

function tc0180vcu_chip.read(direccion:dword):word;
begin
case direccion of
  0..$13fff:read:=self.ram[direccion shr 1];
	$18000..$1801f:read:=self.ctrl[(direccion and $1f) shr 1];
	$40000..$7ffff:halt(0);// FUNC(tc0180vcu_device::framebuffer_word_r)
end;
end;

procedure tc0180vcu_chip.write(direccion:dword;valor:word);
var
  oldword:word;
begin
case direccion of
  0..$13fff:self.ram[direccion shr 1]:=valor;
	$18000..$1801f:begin //ctrl_w
                    direccion:=(direccion and $1f) shr 1;
                    oldword:=self.ctrl[direccion];
                    self.ctrl[direccion]:=valor;
                    if (oldword xor valor)<>0 then begin
                      case direccion of
			                  0:begin
				                    //tilemap[1]->mark_all_dirty();
                            self.fg_rambank[0]:=((self.ctrl[direccion] shr 8) and $f) shl 12;
				                    self.fg_rambank[1]:=((self.ctrl[direccion] shr 12) and $f) shl 12;
                        end;
                        1:begin
                  				  //m_tilemap[0]->mark_all_dirty();
				                    self.bg_rambank[0]:=((self.ctrl[direccion] shr 8) and $f) shl 12;
                            self.bg_rambank[1]:=((self.ctrl[direccion] shr 12) and $f) shl 12;
                        end;
                        4,5:begin
                            //m_tilemap[2]->mark_all_dirty();
                            end;
                        6:begin
				                    //m_tilemap[2]->mark_all_dirty();
				                    self.tx_rambank:=((self.ctrl[direccion] shr 8) and $f) shl 11;
                          end;
			                  7:begin
                            //video_control((m_ctrl[offset] >> 8) & 0xff);
                            self.video_control:=self.ctrl[direccion] shr 8;
	                          if (self.video_control and $80)<>0 then self.framebuffer_page:=(not(self.video_control) and $40) shr 6;
	                          //machine().tilemap().set_flip_all((m_video_control & 0x10) ? (TILEMAP_FLIPX | TILEMAP_FLIPY) : 0 );
                          end;
                      end;
                    end;
                 end;
	$40000..$7ffff:halt(0);// FUNC(tc0180vcu_device::framebuffer_word_w));
end;
end;

procedure tc0180vcu_chip.draw;
var
  x,y,color,f,atrib,nchar:word;
  flipx,flipy:boolean;
begin
for f:=0 to $7ff do begin
    //txt
    atrib:=self.ram[f+self.tx_rambank];
    //if (gfx[0].buffer[f] or buffer_color[color]) then begin
      x:=f mod 64;
      y:=f div 64;
      nchar:=(atrib and $7ff)+((self.ctrl[4+((atrib and $800) shr 11)] shr 8) shl 11);
      color:=self.tx_color_base+((atrib shr 12) and $f);
      put_gfx_trans(x*8,y*8,nchar,color shl 4,3,0);
      //gfx[0].buffer[f]:=false;
    //end;
end;
for f:=0 to $fff do begin
    //background
    atrib:=self.ram[f+self.bg_rambank[1]];
    //if (gfx[0].buffer[f] or buffer_color[color]) then begin
      x:=f mod 64;
      y:=f div 64;
      nchar:=self.ram[f+self.bg_rambank[0]];
      color:=self.bg_color_base+(atrib and $3f);
      put_gfx_flip(x*16,y*16,nchar,color shl 4,1,1,(atrib and $40)<>0,(atrib and $80)<>0);
      //gfx[0].buffer[f]:=false;
    //end;
    //foreground
    atrib:=self.ram[f+self.fg_rambank[1]];
    //if (gfx[0].buffer[f] or buffer_color[color]) then begin
      x:=f mod 64;
      y:=f div 64;
      nchar:=self.ram[f+self.fg_rambank[0]];
      color:=self.fg_color_base+(atrib and $3f);
      put_gfx_trans_flip(x*16,y*16,nchar,color shl 4,2,1,(atrib and $40)<>0,(atrib and $80)<>0);
      //gfx[0].buffer[f]:=false;
    //end;
end;
end;

procedure tc0180vcu_chip.draw_sprites;
var
  color,atrib,nchar:word;
  flipx,flipy,bigsprite:boolean;
  tempw:word;
  x_num,y_num:byte;
  x,y,x_no,y_no,xlatch,ylatch:integer;
  zoomx,zoomy,zoomxlatch,zoomylatch:dword;
  //alt
  f:integer;
  fx,fy,size_x,size_y:byte;
  zx,zy:single;
begin
bigsprite:=false;
x_num:=0;
y_num:=0;
zoomxlatch:=0;
zoomylatch:=0;
x_no:=0;
y_no:=0;
xlatch:=0;
ylatch:=0;
f:=$195;
while (f>=0) do begin
    nchar:=self.ram[$8000+(f*8)];
		atrib:=self.ram[$8001+(f*8)];
		flipx:=(atrib and $4000)<>0;
		flipy:=(atrib and $8000)<>0;
    color:=(atrib and $3f) shl 4;
		x:=self.ram[$8002+(f*8)] and $3ff;
    y:=self.ram[$8003+(f*8)] and $3ff;
    if x>$200 then x:=x-$400;
    if y>$200 then y:=y-$400;
    tempw:=self.ram[$8005+(f*8)];
    size_x:=tempw shr 8;
    size_y:=tempw and $ff;
    tempw:=self.ram[$8004+(f*8)];
    zx:=($100-(tempw shr 8))/$100;
    zy:=($100-(tempw and $ff))/$100;
    for fx:=0 to size_x do begin
      for fy:=0 to size_y do begin
        put_gfx_sprite(nchar,color+self.fb_color_base,flipx,flipy,1);
        //actualiza_gfx_sprite(x+(fx*16),y+(fy*16),4,1);
        actualiza_gfx_sprite_zoom(x+trunc((fx*16)*zx),y+trunc((fy*16)*zy),4,1,zx,zy);
        f:=f-1;
        if f<0 then exit;
        nchar:=self.ram[$8000+(f*8)];
        atrib:=self.ram[$8001+(f*8)];
		    flipx:=(atrib and $4000)<>0;
		    flipy:=(atrib and $8000)<>0;
        color:=(atrib and $3f) shl 4;
        tempw:=self.ram[$8004+(f*8)];
        zx:=($100-(tempw shr 8))/$100;
        zy:=($100-(tempw and $ff))/$100;
      end;
    end;
    {if tempw<>0 then begin
      if not(bigsprite) then begin
        x_num:=(tempw shr 8) and $ff;
				y_num:=(tempw shr 0) and $ff;
				x_no:=0;
				y_no:=0;
				xlatch:=x;
				ylatch:=y;
				tempw:=self.ram[$8004+(f*8)];
				zoomxlatch:=(tempw shr 8) and $ff;
				zoomylatch:=(tempw shr 0) and $ff;
				bigsprite:=true;
      end;
    end;
    tempw:=self.ram[$8004+(f*8)];
    zoomx:=(tempw shr 8) and $ff;
		zoomy:=(tempw shr 0) and $ff;
		zx:=($100-zoomx) div 16;
		zy:=($100-zoomy) div 16;
    if bigsprite then begin
			zoomx:=zoomxlatch;
			zoomy:=zoomylatch;
			x:=xlatch+(x_no*($ff-zoomx)+15) div 16;
			y:=ylatch+(y_no*($ff-zoomy)+15) div 16;
			zx:=xlatch+((x_no+1)*($ff-zoomx)+15) div 16-x;
			zy:=ylatch+((y_no+1)*($ff-zoomy)+15) div 16-y;
			y_no:=y_no+1;
			if (y_no>y_num) then begin
				y_no:=0;
				x_no:=x_no+1;
				if (x_no>x_num) then bigsprite:=false;
			end;
		end;
    put_gfx_sprite(nchar,color+self.fb_color_base,flipx,flipy,1);
    if ((zoomx<>0) or (zoomy<>0)) then actualiza_gfx_sprite_zoom(x,y,4,1,zx/16,zy/16)
      else actualiza_gfx_sprite(x,y,4,1);}
end;
end;

end.
