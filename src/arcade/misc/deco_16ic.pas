unit deco_16ic;

interface
uses main_engine,gfx_engine;

type
    tipo_deco16ic_bank=function(direccion:word):word;
    type_pf=class
          constructor create(pant:byte;col_bank:byte;call_bank:tipo_deco16ic_bank);
          destructor free;
       public
          data:array[0..$fff] of word;
          rowscroll:array[0..$7ff] of word;
          buffer_color:array[0..$3f] of boolean;
          buffer:array[0..$fff] of boolean;
          procedure reset;
       private
          pant,color_bank:byte;
          bank:word;
          call_bank:tipo_deco16ic_bank;
          is_8x8:boolean;
    end;
    chip_16ic=class
          constructor create(pant1,pant2:byte;color_base1,color_base2,tmask1,tmask2:word;gfx_plane8,gfx_plane16,col_bank1,col_bank2:byte;call_bank1,call_bank2:tipo_deco16ic_bank);
          destructor free;
       public
          pf1,pf2:type_pf;
          color_mask:array[1..2] of word;
          gfx_plane:array[1..2] of byte;
          procedure reset;
          procedure control_w(pos,valor:word);
          function control_r(pos:word):word;
          procedure update_pf_1(screen:byte;trans:boolean);
          procedure update_pf_2(screen:byte;trans:boolean);
       private
          control:array[0..7] of word;
          color_base:array[1..2] of word;
          procedure update_plane_1(screen:byte;trans:boolean);
          procedure update_plane_2(screen:byte;trans:boolean);
    end;

var
  deco16ic_0,deco16ic_1:chip_16ic;

implementation

constructor type_pf.create(pant:byte;col_bank:byte;call_bank:tipo_deco16ic_bank);
begin
self.pant:=pant;
screen_init(pant,1024,512,true);
self.color_bank:=col_bank;
self.call_bank:=call_bank;
end;

destructor type_pf.free;
begin
end;

procedure type_pf.reset;
begin
 fillchar(self.data[0],$800*2,0);
 fillchar(self.rowscroll[0],$800*2,0);
 fillchar(self.buffer[0],$800,1);
 fillchar(self.buffer_color[0],$40,1);
 self.bank:=0;
 self.is_8x8:=true;
end;

constructor chip_16ic.create(pant1,pant2:byte;color_base1,color_base2,tmask1,tmask2:word;gfx_plane8,gfx_plane16,col_bank1,col_bank2:byte;call_bank1,call_bank2:tipo_deco16ic_bank);
begin
self.pf1:=type_pf.create(pant1,col_bank1,call_bank1);
self.pf2:=type_pf.create(pant2,col_bank2,call_bank2);
self.color_mask[1]:=tmask1;
self.color_mask[2]:=tmask2;
self.color_base[1]:=color_base1;
self.color_base[2]:=color_base2;
self.gfx_plane[1]:=gfx_plane8;
self.gfx_plane[2]:=gfx_plane16;
end;

destructor chip_16ic.free;
begin
end;

procedure chip_16ic.reset;
begin
 fillchar(self.control[0],8*2,0);
 self.pf1.reset;
 self.pf2.reset;
end;

function chip_16ic.control_r(pos:word):word;
begin
  control_r:=self.control[pos];
end;

procedure chip_16ic.control_w(pos,valor:word);
begin
if pos=6 then begin
  //¿es de 8x8?
  if (self.control[6] and $80)<>(valor and $80) then fillchar(self.pf1.buffer[0],$800,1);
  if (self.control[6] and $8000)<>(valor and $8000) then fillchar(self.pf2.buffer[0],$800,1);
  if (valor and $80)<>0 then begin  //8x8
    mod_screen(self.pf1.pant,512,256);
    self.pf1.is_8x8:=true;
  end else begin  //16x16
    mod_screen(self.pf1.pant,1024,512);
    self.pf1.is_8x8:=false;
  end;
  if (valor and $8000)<>0 then begin //8x8
    mod_screen(self.pf2.pant,512,256);
    self.pf2.is_8x8:=true;
  end else begin //16x16
    mod_screen(self.pf2.pant,1024,512);
    self.pf2.is_8x8:=false;
  end;
end;
self.control[pos]:=valor;
end;

procedure chip_16ic.update_plane_1(screen:byte;trans:boolean);
var
  f,x,y,atrib,nchar,pos,rows,cols:word;
  color,color_mask:byte;
  flipx,flipy:boolean;
begin
for f:=0 to $7ff do begin
  x:=f mod 64;
  y:=f div 64;
  if self.pf1.is_8x8 then pos:=f
    else pos:=(x and $1f)+((y and $1f) shl 5)+((x and $20) shl 5)+((y and $20) shl 6);
  atrib:=self.pf1.data[pos];
  flipx:=false;
  flipy:=false;
  if self.pf1.is_8x8 then color_mask:=self.color_mask[1]
    else color_mask:=self.color_mask[2];
  if (atrib and $8000)<>0 then begin
    if (self.control[6] and 1)<>0 then begin
      flipx:=true;
      color_mask:=color_mask shr 1;
    end;
    if (self.control[6] and 2)<>0 then begin
      flipy:=true;
      color_mask:=color_mask shr 1;
    end;
  end;
  color:=(atrib shr 12) and color_mask;
  if ((self.pf1.buffer[pos]) or (self.pf1.buffer_color[color])) then begin
    nchar:=(atrib and $fff) or self.pf1.bank;
    if self.pf1.is_8x8 then begin //8x8
      if trans then put_gfx_trans_flip(x*8,y*8,nchar,((color+self.pf1.color_bank) shl 4)+self.color_base[1],self.pf1.pant,self.gfx_plane[1],flipx,flipy)
        else put_gfx_flip(x*8,y*8,nchar,((color+self.pf1.color_bank) shl 4)+self.color_base[1],self.pf1.pant,self.gfx_plane[1],flipx,flipy);
    end else begin //16x16
      if trans then put_gfx_trans_flip(x*16,y*16,nchar,((color+self.pf1.color_bank) shl 4)+self.color_base[2],self.pf1.pant,self.gfx_plane[2],flipx,flipy)
        else put_gfx_flip(x*16,y*16,nchar,((color+self.pf1.color_bank) shl 4)+self.color_base[2],self.pf1.pant,self.gfx_plane[2],flipx,flipy);
    end;
    self.pf1.buffer[pos]:=false;
  end;
end;
case (self.control[6] and $60) of
  $00:scroll_x_y(self.pf1.pant,screen,self.control[1],self.control[2]);
  $20:begin //col_scroll
        //scroll_x_y(self.pf1.pant,screen,self.control[1],self.control[2]);
        cols:=8 shl (self.control[5] and $7);
        atrib:=1024 div cols;
        scroll__y_part2(self.pf1.pant,screen,atrib,@self.pf1.rowscroll[$200],self.control[1],self.control[2]);
  end;
  $40:begin //row_scroll
        rows:=512 shr ((self.control[5] shr 3) and $f);
        if self.pf1.is_8x8 then begin
            rows:=rows shr 1;
            atrib:=256 div rows;
        end else atrib:=512 div rows;
        scroll__x_part2(self.pf1.pant,screen,atrib,@self.pf1.rowscroll[0],self.control[1],self.control[2]);
  end;
  $60:halt(0); //col & row scroll
end;
end;

procedure chip_16ic.update_plane_2(screen:byte;trans:boolean);
var
  f,x,y,atrib,nchar,pos,rows,cols:word;
  color,color_mask:byte;
  flipx,flipy:boolean;
begin
for f:=0 to $7ff do begin
  x:=f mod 64;
  y:=f div 64;
  if self.pf2.is_8x8 then pos:=f
    else pos:=(x and $1f)+((y and $1f) shl 5)+((x and $20) shl 5)+((y and $20) shl 6);
  atrib:=self.pf2.data[pos];
  flipx:=false;
  flipy:=false;
  if self.pf2.is_8x8 then color_mask:=self.color_mask[1]
    else color_mask:=self.color_mask[2];
  if (atrib and $8000)<>0 then begin
    if (self.control[6] and $100)<>0 then begin
      flipx:=true;
      color_mask:=color_mask shr 1;
    end;
    if (self.control[6] and $200)<>0 then begin
      flipy:=true;
      color_mask:=color_mask shr 1;
    end;
  end;
  color:=(atrib shr 12) and color_mask;
  if ((self.pf2.buffer[pos]) or (self.pf2.buffer_color[color])) then begin
    nchar:=(atrib and $fff) or self.pf2.bank;
    if self.pf2.is_8x8 then begin //8x8
      if trans then put_gfx_trans_flip(x*8,y*8,nchar,((color+self.pf2.color_bank) shl 4)+self.color_base[1],self.pf2.pant,self.gfx_plane[1],flipx,flipy)
        else put_gfx_flip(x*8,y*8,nchar,((color+self.pf2.color_bank) shl 4)+self.color_base[1],self.pf2.pant,self.gfx_plane[1],flipx,flipy);
    end else begin //16x16
      if trans then put_gfx_trans_flip(x*16,y*16,nchar,((color+self.pf2.color_bank) shl 4)+self.color_base[2],self.pf2.pant,self.gfx_plane[2],flipx,flipy)
        else put_gfx_flip(x*16,y*16,nchar,((color+self.pf2.color_bank) shl 4)+self.color_base[2],self.pf2.pant,self.gfx_plane[2],flipx,flipy);
    end;
    self.pf2.buffer[pos]:=false;
  end;
end;
case ((self.control[6] shr 8) and $60) of
  $00:scroll_x_y(self.pf2.pant,screen,self.control[3],self.control[4]);
  $20:begin //col_scroll
        cols:=8 shl ((self.control[5] shr 8) and $7);
        atrib:=1024 div cols;
        scroll__y_part2(self.pf2.pant,screen,atrib,@self.pf2.rowscroll[$200],self.control[3],self.control[4]);
  end;
  $40:begin //row_scroll
        rows:=512 shr (((self.control[5] shr 8) shr 3) and $f);
        if self.pf2.is_8x8 then begin
            rows:=rows shr 1;
            atrib:=256 div rows;
        end else atrib:=512 div rows;
        scroll__x_part2(self.pf2.pant,screen,atrib,@self.pf2.rowscroll[0],self.control[3],self.control[4]);
  end;
  $60:; //col & row scroll
end;
end;

procedure chip_16ic.update_pf_1(screen:byte;trans:boolean);
var
  bank:word;
begin
  if @self.pf1.call_bank<>nil then begin
    bank:=self.pf1.call_bank(self.control[7] and $ff);
    if bank<>self.pf1.bank then begin
      self.pf1.bank:=bank;
      fillchar(self.pf1.buffer[0],$800,1);
    end;
  end;
  if (self.control[5] and $80)<>0 then self.update_plane_1(screen,trans);
  fillchar(self.pf1.buffer_color[0],$40,0);
end;

procedure chip_16ic.update_pf_2(screen:byte;trans:boolean);
var
  bank:word;
begin
  if @self.pf2.call_bank<>nil then begin
    bank:=self.pf2.call_bank((self.control[7] shr 8) and $ff);
    if bank<>self.pf2.bank then begin
      self.pf2.bank:=bank;
      fillchar(self.pf2.buffer[0],$800,1);
    end;
  end;
  if (self.control[5] and $8000)<>0 then self.update_plane_2(screen,trans);
  fillchar(self.pf2.buffer_color[0],$40,0);
end;

end.
