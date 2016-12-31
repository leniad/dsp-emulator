unit deco16ic;

interface
uses main_engine,gfx_engine;

type
    tipo_deco16ic_bank=function(direccion:word):word;
    tipo_deco16ic=record
       dec16ic_pf_data:array[1..2,0..$7ff] of word;
       dec16ic_pf_control:array[0..7] of word;
       dec16ic_pf_rowscroll:array[1..2,0..$7ff] of word;
       dec16ic_color_mask,dec16ic_pant,dec16ic_gfx_plane,dec16ic_color_bank:array[1..2] of byte;
       dec16ic_buffer:array[1..2,0..$7ff] of boolean;
       dec16ic_buffer_color:array[1..2,0..$3f] of boolean;
       dec16ic_color_base,dec16ic_pf_bank:array[1..2] of word;
       dec16_call_bank1,dec16_call_bank2:tipo_deco16ic_bank;
       dec16_is_8x8:array[1..2] of boolean;
       end;
    ptipo_deco16ic=^tipo_deco16ic;

var
  deco16ic_chip:array[0..1] of ptipo_deco16ic;

procedure reset_dec16ic(num:byte);
procedure close_dec16ic(num:byte);
procedure dec16ic_pf_control_w(num:byte;pos,valor:word);
function dec16ic_pf_control_r(num:byte;pos:word):word;
procedure init_dec16ic(num,pant1,pant2:byte;color_base1,color_base2,tmask1,tmask2:word;gfx_plane8,gfx_plane16,col_bank1,col_bank2:byte;call_bank1,call_bank2:tipo_deco16ic_bank);
procedure update_pf_1(num,screen:byte;trans:boolean);
procedure update_pf_2(num,screen:byte;trans:boolean);

implementation

procedure init_dec16ic(num,pant1,pant2:byte;color_base1,color_base2,tmask1,tmask2:word;gfx_plane8,gfx_plane16,col_bank1,col_bank2:byte;call_bank1,call_bank2:tipo_deco16ic_bank);
begin
getmem(deco16ic_chip[num],sizeof(tipo_deco16ic));
deco16ic_chip[num].dec16ic_pant[1]:=pant1;
deco16ic_chip[num].dec16ic_pant[2]:=pant2;
screen_init(pant1,1024,512,true);
screen_mod_scroll(pant1,1024,512,1023,512,256,511);
screen_init(pant2,1024,512,true);
screen_mod_scroll(pant2,1024,512,1023,512,256,511);
deco16ic_chip[num].dec16ic_color_bank[1]:=col_bank1;
deco16ic_chip[num].dec16ic_color_bank[2]:=col_bank2;
deco16ic_chip[num].dec16ic_color_base[1]:=color_base1;
deco16ic_chip[num].dec16ic_color_base[2]:=color_base2;
deco16ic_chip[num].dec16ic_color_mask[1]:=tmask1;
deco16ic_chip[num].dec16ic_color_mask[2]:=tmask2;
deco16ic_chip[num].dec16ic_gfx_plane[1]:=gfx_plane8;
deco16ic_chip[num].dec16ic_gfx_plane[2]:=gfx_plane16;
deco16ic_chip[num].dec16_call_bank1:=call_bank1;
deco16ic_chip[num].dec16_call_bank2:=call_bank2;
end;

procedure reset_dec16ic(num:byte);
var
  r:ptipo_deco16ic;
begin
 r:=deco16ic_chip[num];
 fillchar(r.dec16ic_pf_data[1,0],$800*2,0);
 fillchar(r.dec16ic_pf_data[2,0],$800*2,0);
 fillchar(r.dec16ic_pf_control[0],$10,0);
 fillchar(r.dec16ic_pf_rowscroll[1,0],$800,0);
 fillchar(r.dec16ic_pf_rowscroll[2,0],$800,0);
 fillchar(r.dec16ic_buffer[1,0],$800,1);
 fillchar(r.dec16ic_buffer[2,0],$800,1);
 fillchar(r.dec16ic_buffer_color[1,0],$40,1);
 fillchar(r.dec16ic_buffer_color[2,0],$40,1);
 r.dec16ic_pf_bank[1]:=0;
 r.dec16ic_pf_bank[2]:=0;
 r.dec16_is_8x8[1]:=true;
 r.dec16_is_8x8[2]:=true;
end;

procedure close_dec16ic(num:byte);
begin
 freemem(deco16ic_chip[num]);
 deco16ic_chip[num]:=nil;
end;

function dec16ic_pf_control_r(num:byte;pos:word):word;
begin
  dec16ic_pf_control_r:=deco16ic_chip[num].dec16ic_pf_control[pos];
end;

procedure dec16ic_pf_control_w(num:byte;pos,valor:word);
var
  r:ptipo_deco16ic;
begin
r:=deco16ic_chip[num];
if pos=6 then begin
  //¿es de 8x8?
  if (r.dec16ic_pf_control[6] and $8000)<>(valor and $8000) then fillchar(r.dec16ic_buffer[2,0],$800,1);
  if (r.dec16ic_pf_control[6] and $80)<>(valor and $80) then fillchar(r.dec16ic_buffer[1,0],$800,1);
  if (valor and $8000)<>0 then begin //8x8
    screen_mod_scroll(r.dec16ic_pant[2],512,512,511,256,256,255);
    r.dec16_is_8x8[2]:=true;
  end else begin //16x16
    screen_mod_scroll(r.dec16ic_pant[2],1024,512,1023,512,256,511);
    r.dec16_is_8x8[2]:=false;
  end;
  if (valor and $80)<>0 then begin  //8x8
    screen_mod_scroll(r.dec16ic_pant[1],512,512,511,256,256,255);
    r.dec16_is_8x8[1]:=true;
  end else begin  //16x16
    screen_mod_scroll(r.dec16ic_pant[1],1024,512,1023,512,256,511);
    r.dec16_is_8x8[1]:=false;
  end;
end;
r.dec16ic_pf_control[pos]:=valor;
end;

procedure update_plane(num,screen,plane:byte;shr_mask:word;scroll_x,scroll_y:word;trans:boolean);
var
  f,x,y,atrib,nchar,pos,rows,cols:word;
  color,color_mask:byte;
  flipx,flipy:boolean;
  r:ptipo_deco16ic;
begin
r:=deco16ic_chip[num];
for f:=0 to $7ff do begin
  x:=f mod 64;
  y:=f div 64;
  if r.dec16_is_8x8[plane] then pos:=f
    else pos:=(x and $1f)+((y and $1f) shl 5)+((x and $20) shl 5)+((y and $20) shl 6);
  atrib:=r.dec16ic_pf_data[plane,pos];
  flipx:=false;
  flipy:=false;
  if r.dec16_is_8x8[plane] then color_mask:=r.dec16ic_color_mask[1]
    else color_mask:=r.dec16ic_color_mask[2];
  if (atrib and $8000)<>0 then begin
    if ((r.dec16ic_pf_control[6] shr shr_mask) and 1)<>0 then begin
      flipx:=true;
      color_mask:=color_mask shr 1;
    end;
    if ((r.dec16ic_pf_control[6] shr shr_mask) and 2)<>0 then begin
      flipy:=true;
      color_mask:=color_mask shr 1;
    end;
  end;
  color:=(atrib shr 12) and color_mask;
  if ((r.dec16ic_buffer[plane,pos]) or (r.dec16ic_buffer_color[plane,color])) then begin
    nchar:=(atrib and $fff) or r.dec16ic_pf_bank[plane];
    if r.dec16_is_8x8[plane] then begin //8x8
      if trans then put_gfx_trans_flip(x*8,y*8,nchar,((color+r.dec16ic_color_bank[plane]) shl 4)+r.dec16ic_color_base[1],r.dec16ic_pant[plane],r.dec16ic_gfx_plane[1],flipx,flipy)
        else put_gfx_flip(x*8,y*8,nchar,((color+r.dec16ic_color_bank[plane]) shl 4)+r.dec16ic_color_base[1],r.dec16ic_pant[plane],r.dec16ic_gfx_plane[1],flipx,flipy);
    end else begin //16x16
      if trans then put_gfx_trans_flip(x*16,y*16,nchar,((color+r.dec16ic_color_bank[plane]) shl 4)+r.dec16ic_color_base[2],r.dec16ic_pant[plane],r.dec16ic_gfx_plane[2],flipx,flipy)
        else put_gfx_flip(x*16,y*16,nchar,((color+r.dec16ic_color_bank[plane]) shl 4)+r.dec16ic_color_base[2],r.dec16ic_pant[plane],r.dec16ic_gfx_plane[2],flipx,flipy);
    end;
    r.dec16ic_buffer[plane,pos]:=false;
  end;
end;
case ((r.dec16ic_pf_control[6] shr shr_mask) and $60) of
  $00:scroll_x_y(r.dec16ic_pant[plane],screen,scroll_x,scroll_y);
  $20:begin //col_scroll
        cols:=8 shl ((r.dec16ic_pf_control[5] shr shr_mask) and $7);
        atrib:=1024 div cols;
        for f:=0 to cols-1 do scroll__y_part(r.dec16ic_pant[plane],screen,scroll_y+r.dec16ic_pf_rowscroll[plane,f+$200],scroll_x,f*atrib,atrib);
  end;
  $40:begin //row_scroll
        rows:=512 shr (((r.dec16ic_pf_control[5] shr shr_mask) shr 3) and $f);
        if r.dec16_is_8x8[plane] then begin
            rows:=rows shr 1;
            atrib:=256 div rows;
        end else atrib:=512 div rows;
        for f:=0 to rows-1 do scroll__x_part(r.dec16ic_pant[plane],screen,scroll_x+r.dec16ic_pf_rowscroll[plane,f],scroll_y,f*atrib,atrib);
  end;
  $60:halt(0); //col & row scroll
end;
end;

procedure update_pf_1(num,screen:byte;trans:boolean);
var
  bank:word;
begin
  if @deco16ic_chip[num].dec16_call_bank1<>nil then begin
    bank:=deco16ic_chip[num].dec16_call_bank1(deco16ic_chip[num].dec16ic_pf_control[7] and $ff);
    if bank<>deco16ic_chip[num].dec16ic_pf_bank[1] then begin
      deco16ic_chip[num].dec16ic_pf_bank[1]:=bank;
      fillchar(deco16ic_chip[num].dec16ic_buffer[1,0],$800,1);
    end;
  end;
  if (deco16ic_chip[num].dec16ic_pf_control[5] and $80)<>0 then update_plane(num,screen,1,0,deco16ic_chip[num].dec16ic_pf_control[1],deco16ic_chip[num].dec16ic_pf_control[2],trans);
  fillchar(deco16ic_chip[num].dec16ic_buffer_color[1,0],$40,0);
end;

procedure update_pf_2(num,screen:byte;trans:boolean);
var
  bank:word;
begin
  if @deco16ic_chip[num].dec16_call_bank2<>nil then begin
    bank:=deco16ic_chip[num].dec16_call_bank2((deco16ic_chip[num].dec16ic_pf_control[7] shr 8) and $ff);
    if bank<>deco16ic_chip[num].dec16ic_pf_bank[2] then begin
      deco16ic_chip[num].dec16ic_pf_bank[2]:=bank;
      fillchar(deco16ic_chip[num].dec16ic_buffer[2,0],$800,1);
    end;
  end;
  if (deco16ic_chip[num].dec16ic_pf_control[5] and $8000)<>0 then update_plane(num,screen,2,8,deco16ic_chip[num].dec16ic_pf_control[3],deco16ic_chip[num].dec16ic_pf_control[4],trans);
  fillchar(deco16ic_chip[num].dec16ic_buffer_color[2,0],$40,0);
end;

end.
