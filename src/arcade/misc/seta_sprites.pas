unit seta_sprites;

interface
uses {$IFDEF WINDOWS}windows,{$ELSE IF}main_engine,{$ENDIF}
     gfx_engine;

type
  tfunction=function(code:word;color:word):word;
  tseta_sprites=class
          constructor create(sprite_gfx,screen_gfx,bank_size:byte;sprite_mask:word;code_cb:tfunction=nil);
          destructor free;
        public
          control:array[0..3] of byte;
          bg_flag:byte;
          spritelow,spritehigh:array[0..$1fff] of byte;
          spritey:array[0..$2ff] of byte;
          bank_size,sprite_gfx,screen_gfx:byte;
          sprite_mask:word;
          procedure reset;
          procedure draw_sprites;
          procedure tnzs_eof;
        private
          code_cb:tfunction;
          procedure update_background;
          procedure update_sprites;
        end;

var
  seta_sprite0:tseta_sprites;

implementation

constructor tseta_sprites.create(sprite_gfx,screen_gfx,bank_size:byte;sprite_mask:word;code_cb:tfunction=nil);
begin
self.bank_size:=bank_size;
self.sprite_gfx:=sprite_gfx;
self.screen_gfx:=screen_gfx;
self.sprite_mask:=sprite_mask;
self.code_cb:=code_cb;
end;

destructor tseta_sprites.free;
begin
end;

procedure tseta_sprites.reset;
begin
self.control[0]:=0;
self.control[1]:=$ff;
self.control[2]:=$ff;
self.control[3]:=$ff;
self.bg_flag:=0;
end;

procedure tseta_sprites.update_background;
var
  startcol,ctrl,ctrl2,column,tot,x,y,atrib:byte;
  upperbits,bank_inc:word;
  f,nchar,color,sx,sy:word;
  flipx,flipy,trans:boolean;
begin
	ctrl2:=self.control[1];
  tot:=ctrl2 and $f;
  if tot=0 then exit;
  if (tot=1) then tot:=16;
  ctrl:=self.control[0];
	bank_inc:=((ctrl2 xor (not(ctrl2) shl 1)) and $40)*self.bank_size;
	upperbits:=self.control[2]+(self.control[3] shl 8);
  startcol:=(ctrl and $3)*4;
  trans:=(self.bg_flag and $80)=0;
	for column:=0 to (tot-1) do begin
		for y:=0 to 15 do begin
			for x:=0 to 1 do begin
				f:=$20*((column+startcol) and $f)+2*y+x;
        atrib:=self.spritehigh[bank_inc+$400+f];
				nchar:=self.spritelow[bank_inc+$400+f]+((atrib and $3f) shl 8);
        if @self.code_cb<>nil then nchar:=self.code_cb(nchar,self.spritehigh[bank_inc+$600+f]) and self.sprite_mask
          else nchar:=nchar and self.sprite_mask;
				color:=(self.spritehigh[bank_inc+$600+f] and $f8) shl 1;
				sx:=(x*$10)+self.spritey[$204+(column*$10)]-(256*(upperbits and 1));
        if (ctrl and $40)<>0 then begin
          sy:=238-(y*$10)+self.spritey[$200+(column*$10)]+1;
          flipx:=(atrib and $80)=0;
          flipy:=(atrib and $40)=0;
        end else begin
          flipx:=(atrib and $80)<>0;
				  flipy:=(atrib and $40)<>0;
          sy:=(y*$10)+256-(self.spritey[$200+(column*$10)])+1;
        end;
        if trans then begin
          put_gfx_sprite(nchar,color,flipx,flipy,self.sprite_gfx);
          actualiza_gfx_sprite(sx,sy,self.screen_gfx,self.sprite_gfx);
        end else begin
          put_gfx_flip(sx,sy,nchar,color,self.screen_gfx,self.sprite_gfx,flipx,flipy);
        end;
			end;
		end;
    upperbits:=upperbits shr 1;
	end;
end;

procedure tseta_sprites.update_sprites;
var
  ctrl2,atrib,sy:byte;
  nchar,color,sx,f,bank_inc:word;
  flipx,flipy:boolean;
begin
	ctrl2:=self.control[1];
	bank_inc:=((ctrl2 xor (not(ctrl2) shl 1)) and $40)*self.bank_size;
	//512 sprites
	for f:=$1ff downto 0 do begin
    atrib:=self.spritehigh[bank_inc+f];
		nchar:=(self.spritelow[bank_inc+f]+((atrib and $3f) shl 8)) and self.sprite_mask;
		color:=(self.spritehigh[bank_inc+$200+f] and $f8) shl 1;
		sx:=self.spritelow[bank_inc+$200+f]-((self.spritehigh[bank_inc+$200+f] and 1) shl 8);
    if (self.control[0] and $40)<>0 then begin
      sy:=self.spritey[f]+2;
      flipx:=(atrib and $80)=0;
      flipy:=(atrib and $40)=0;
    end else begin
      sy:=240-self.spritey[f]+2;
      flipx:=(atrib and $80)<>0;
		  flipy:=(atrib and $40)<>0;
    end;
    put_gfx_sprite(nchar,color,flipx,flipy,self.sprite_gfx);
    actualiza_gfx_sprite(sx,sy,self.screen_gfx,self.sprite_gfx);
	end;
end;

procedure tseta_sprites.draw_sprites;
begin
  self.update_background;
  self.update_sprites;
end;

procedure tseta_sprites.tnzs_eof;
begin
if (self.control[1] and $20)=0 then begin
		if (self.control[1] and $40)<>0 then begin
      copymemory(@self.spritelow[$0],@self.spritelow[$800],$400);
      copymemory(@self.spritehigh[$0],@self.spritehigh[$800],$400);
		end else begin
      copymemory(@self.spritelow[$800],@self.spritelow[$0],$400);
      copymemory(@self.spritehigh[$800],@self.spritehigh[$0],$400);
		end;
    copymemory(@self.spritelow[$400],@self.spritelow[$c00],$400);
    copymemory(@self.spritehigh[$400],@self.spritehigh[$c00],$400);
	end;
end;

end.
