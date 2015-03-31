unit tms99xx;

interface

uses gfx_engine,{$IFDEF WINDOWS}windows,{$endif}
     main_engine,pal_engine;

  const
    BORDER=8;
  type
    TTMS99XX=record
      regs: array[0..7] of byte;
      colour,pattern,nametbl,spriteattribute,spritepattern,colourmask,patternmask:word;
      nAddr:word;
      latch,nVR,status_reg,nFGColor,nBGColor,wkey:byte;
      int:boolean;
      TMS9918A_VRAM_SIZE:word;
      memory:array[0..$3FFF] of byte;
      dBackMem:array[0..$FFFF] of byte;  //Calculo de las colisiones de los sprites
      IRQ_Handler:procedure(int:boolean);
      pant:byte;
    end;
    PTMS99XX=^TTMS99XX;

procedure TMS99XX_Init(pant:byte);
procedure TMS99XX_refresh;
procedure TMS99XX_reset;
procedure TMS99XX_Interrupt;
function TMS99XX_vram_r:byte;
function TMS99XX_register_r:integer;
procedure TMS99XX_register_w(value:byte);
procedure TMS99XX_vram_w(nValue:byte);
procedure TMS99XX_close;

var
  TMS:PTMS99XX;

implementation

procedure TMS99XX_reset;
begin
  fillchar(tms.regs[0],16,0);
  tms.latch:=1;
  tms.naddr:=0;
  tms.nVR:=0;
  tms.status_reg:=0;
  tms.nFGColor:=0;
  tms.nBGColor:=0;
  tms.colour:=0;
  tms.pattern:=0;
  tms.nametbl:=0;
  tms.spriteattribute:=0;
  tms.spritepattern:=0;
  tms.colourmask:=0;
  tms.patternmask:=0;
  tms.int:=false;
  tms.TMS9918A_VRAM_SIZE:=$3FFF;
  fillchar(tms.memory[0],$4000,0);
  fillchar(tms.dBackMem[0],$10000,0);
  paleta[0]:=0;
end;

procedure TMS99XX_Init(pant:byte);
const
    tms992X_palete:array[0..15, 0..2] of byte =(
     (0,0,0),(0,0,0),(33, 200, 66),(94, 220, 120),
	  (84, 85, 237),(125, 118, 252),(212, 82, 77),(66, 235, 245),
    (252, 85, 84),(255, 121, 120),(212, 193, 84),(230, 206, 128),
	  (33, 176, 59),(201, 91, 186),(204, 204, 204),(255,255,255));
var
  f:byte;
  colores:tpaleta;
begin
//poner la paleta
for f:=0 to 15 do begin
  colores[f].r:=tms992X_palete[f,0];
  colores[f].g:=tms992X_palete[f,1];
  colores[f].b:=tms992X_palete[f,2];
end;
set_pal(colores,16);
getmem(tms,sizeof(TTMS99XX));
tms.pant:=pant;
TMS99XX_reset;
end;

//change register
procedure OutByte(nAddr,Val:byte);
const
  Mask:array[0..7] of byte=($03,$fb,$0f,$ff,$07,$7f,$07,$ff);
begin
  val:=val and mask[naddr];
  tms.regs[nAddr]:=Val;
  case nAddr of
     0:if (val and 2)<>0 then begin
			    tms.colour:=((tms.Regs[3] and $80)*64) and tms.TMS9918A_VRAM_SIZE;
			    tms.colourmask:=(tms.Regs[3] and $7f)*8 or 7;
			    tms.pattern:=((tms.Regs[4] and 4)*2048) and tms.TMS9918A_VRAM_SIZE;
			    tms.patternmask:=(tms.Regs[4] and 3)*256 or (tms.colourmask and 255);
		    end else begin
			    tms.colour:=(tms.Regs[3]*64) and tms.TMS9918A_VRAM_SIZE;
			    tms.pattern:=(tms.Regs[4]*2048) and tms.TMS9918A_VRAM_SIZE;
       end;
     1:begin
        tms.int:=((((tms.regs[1] xor val) and val and $20)<>0) and ((tms.Status_reg and $80)<>0));
        if @tms.IRQ_Handler<>nil then tms.IRQ_Handler(tms.int);
       end;
     2:tms.NameTbl:=(val shl 10) and tms.TMS9918A_VRAM_SIZE;
     3:begin
        if (tms.Regs[0] and 2)<>0 then begin
            tms.colour:=((val and $80)*64) and tms.TMS9918A_VRAM_SIZE;
            tms.colourmask:=(val and $7f)*8 or 7;
        end else begin
            tms.colour:=(val*64) and tms.TMS9918A_VRAM_SIZE;
        end;
		    tms.patternmask:=(tms.Regs[4] and 3)*256 or (tms.colourmask and 255);
       end;
     4:if (tms.Regs[0] and 2)<>0 then begin
            tms.pattern:=((val and 4)*2048) and tms.TMS9918A_VRAM_SIZE;
            tms.patternmask:=(val and 3)*256 or 255;
        end else begin
            tms.pattern:=(val*2048) and tms.TMS9918A_VRAM_SIZE;
        end;
     5:tms.spriteattribute:=(val*128) and tms.TMS9918A_VRAM_SIZE;
     6:tms.spritepattern:=(val*2048) and tms.TMS9918A_VRAM_SIZE;
     7: begin
       tms.nFGColor:=Val shr 4;
       if tms.nBGColor<>(Val and $0F) then begin
          tms.nBGColor:=(Val and $0F);
          if tms.nBGColor=0 then paleta[0]:=0
            else paleta[0]:=paleta[tms.nBGColor];
          //El color de fondo es transparente. La pantalla se pinta
          //de la siguiente forma: primero todo el fondo (incluido el borde),
          //despues los chars, y por ultimo los sprites.
          //Si hay char con el color 0, es transparente. Yo pongo el color 0
          //igual que el fondo y emulo el color transparente!
       end;
     end;
  end;
end;

procedure draw_sprites;
var
    attributeptr,patternptr,ptemp:pbyte;
    c:byte;
    p,x,y,size,i,j,large,yy,xx,illegalsprite,illegalspriteline:integer;
    limit:array[0..191] of integer;
    line,line2:word;
    tmp:integer;
begin
    fillchar(tms.dBackMem[0],$10000,0);
    attributeptr:=@tms.memory[0];
    inc(attributeptr,tms.spriteattribute);
    if (tms.Regs[1] and 2)<>0 then size:=16
      else size:=8;
    large:=tms.Regs[1] and 1;
    for x:=0 to 191 do limit[x]:=4;
    tms.Status_Reg:=$80;
    illegalspriteline:=255;
    illegalsprite:=0;
    for p:=0 to 31 do begin
        y:=attributeptr^;
        inc(attributeptr);
        if (y=208) then break;
        if (y>208) then y:=-(not(y and 255))
          else y:=y+1;
        x:=attributeptr^;
        inc(attributeptr);
        patternptr:=@tms.memory[0];
        if size=16 then tmp:=tms.spritepattern+((attributeptr^ and $fc)*8)
          else tmp:=tms.spritepattern+(attributeptr^*8);
        inc(patternptr,tmp);
        inc(attributeptr);
        c:=attributeptr^ and $0f;
        if (attributeptr^ and $80)<>0 then x:=x-32;
        inc(attributeptr);
        if (large=0) then begin // draw sprite (not enlarged) */
            for yy:=y to (y+size)-1 do begin
                if ((yy < 0) or (yy > 191) ) then continue;
                if (limit[yy]=0) then begin
                    // illegal sprite line */
                    if (yy < illegalspriteline) then begin
                        illegalspriteline:= yy;
                        illegalsprite:= p;
                    end else begin
                        if (illegalspriteline=yy) then begin
                            if (illegalsprite > p) then begin
                              illegalsprite:= p;
                            end;
                        end;
                    end;
                continue;
                end else begin
                  limit[yy]:=limit[yy]-1;
                end;
                ptemp:=patternptr;
                inc(ptemp,yy-y);
                line:=256*ptemp^;
                inc(ptemp,16);
                line:=line+ptemp^;
                for xx:=x to (x+size)-1 do begin
                    if (line and $8000)<>0 then begin
                        if ((xx >= 0) and (xx < 256)) then begin
                            if (tms.dBackMem[yy*256+xx])<>0 then begin
                                tms.Status_Reg:=tms.status_reg or $20;
                            end else begin
                                tms.dBackMem[yy*256+xx]:=$01;
                            end;
                            if ((c<>0) and ((tms.dBackMem[yy*256+xx] and $02)=0)) then begin
                            	  tms.dBackMem[yy*256+xx]:=tms.dBackMem[yy*256+xx] or $02;
                                punbuf^:=paleta[c];
                            	  putpixel(xx+BORDER,yy+BORDER,1,punbuf,tms.pant);
                            end;
                        end;
                    end;
                    line:=line*2;
                end;
            end;
        end else begin  // draw enlarged sprite */
            for i:=0 to size-1 do begin
                yy:=y+i*2;
                ptemp:=patternptr;
                inc(ptemp,i);
                line2:=256*ptemp^;
                inc(ptemp,16);
                line2:=line2+ptemp^;
                for j:=0 to 1 do begin
                    if ((yy>=0) and (yy<=191)) then begin
                        if (limit[yy]=0) then begin
                            // illegal sprite line */
                            if (yy < illegalspriteline) then begin
                                illegalspriteline:= yy;
                                illegalsprite:=p;
                            end else begin
                              if (illegalspriteline=yy) then begin
                                if (illegalsprite > p) then begin
                                    illegalsprite:= p;
                                end;
                              end;
                            end;
                        continue;
                        end else begin
                          limit[yy]:=limit[yy]-1;
                        end;
                        line:=line2;
                        xx:=x;
                        repeat
                            if (line and $8000)<>0 then begin
                                if ((xx >=0) and (xx < 256)) then begin
                                    if (tms.dBackMem[yy*256+xx]<>0) then begin
                                        tms.Status_Reg:=tms.Status_Reg or $20;
                                    end else begin
                                        tms.dBackMem[yy*256+xx]:= $01;
                                    end;
		                                if ((c<>0) and ((tms.dBackMem[yy*256+xx] and $02)=0)) then begin
                		            	      tms.dBackMem[yy*256+xx]:=tms.dBackMem[yy*256+xx] or $02;
		                            	      punbuf^:=paleta[c];
                            	          putpixel(xx+BORDER,yy+BORDER,1,punbuf,tms.pant);
                                    end;
                                end;
                                if (((xx+1)>=0) and ((xx+1) < 256)) then begin
                                    if (tms.dBackMem[yy*256+xx+1])<>0 then begin
                                        tms.Status_Reg:=tms.Status_Reg or $20;
                                    end else begin
                                        tms.dBackMem[yy*256+xx+1]:=$01;
                                    end;
		                                if ((c<>0) and ((tms.dBackMem[yy*256+xx+1] and $02)=0)) then begin
                		            	      tms.dBackMem[yy*256+xx+1]:=tms.dBackMem[yy*256+xx+1] or $02;
                                        punbuf^:=paleta[c];
                            	          putpixel(xx+1+BORDER,yy+BORDER,1,punbuf,tms.pant);
                                    end;
                                end;
                            end;
                            line:=line*2;
                            xx:=xx+2;
                        until (xx=x+size*2);
                    end;
                    yy:=yy+1;
                end;
            end;
        end;
    end;
    if (illegalspriteline=255) then begin
        if p>31 then tms.Status_Reg:=tms.Status_Reg or 31
          else  tms.Status_Reg:=tms.Status_Reg or p;
    end else begin
        tms.Status_Reg:=tms.Status_Reg or $40+illegalsprite;
    end;
end;

procedure draw_mode0;
var
  I,X,Y,FC,BC,k:byte;
  ptemp:pword;
  patternptr,charcode,name_base:dword;
begin
     name_base:=tms.NameTbl;
      for Y:=0 to 23 do begin
        for x:=0 to 31 do begin
          charcode:=tms.memory[name_base];
          name_base:=name_base+1;
          patternptr:=tms.pattern+charcode shl 3;
          bc:=tms.memory[tms.colour+charcode shr 3];
          fc:=bc shr 4;
          bc:=bc and $f;
          for i:=0 to 7 do begin
            ptemp:=punbuf;
            K:=tms.memory[patternptr];
            patternptr:=patternptr+1;
            if (k and $80)<>0 then ptemp^:=paleta[FC] else ptemp^:=paleta[BC];inc(ptemp);
            if (k and $40)<>0 then ptemp^:=paleta[FC] else ptemp^:=paleta[BC];inc(ptemp);
            if (k and $20)<>0 then ptemp^:=paleta[FC] else ptemp^:=paleta[BC];inc(ptemp);
            if (k and $10)<>0 then ptemp^:=paleta[FC] else ptemp^:=paleta[BC];inc(ptemp);
            if (k and 8)<>0 then ptemp^:=paleta[FC] else ptemp^:=paleta[BC];inc(ptemp);
            if (k and 4)<>0 then ptemp^:=paleta[FC] else ptemp^:=paleta[BC];inc(ptemp);
            if (k and 2)<>0 then ptemp^:=paleta[FC] else ptemp^:=paleta[BC];inc(ptemp);
            if (k and 1)<>0 then ptemp^:=paleta[FC] else ptemp^:=paleta[BC];
            putpixel((x*8)+BORDER,(Y shl 3+i)+BORDER,8,punbuf,tms.pant);
          end;
        end;
      end;
end;

procedure draw_mode1;
var
  I,X,Y,name_base:word;
  ptemp:pword;
  FC,BC:byte;
  S,k:integer;
begin
      FC:=tms.nFGColor;
      BC:=tms.nBGColor;
      name_base:=tms.Nametbl;
      for Y:=0 to 23 do begin    // 6x8
        for x:=0 to 39 do begin
          S:=tms.pattern+(tms.memory[name_base] shl 3);
          for i:=0 to 7 do begin
            K:=tms.memory[S];
            ptemp:=punbuf;
            if (k and $80)<>0 then ptemp^:=paleta[FC] else ptemp^:=paleta[BC];inc(ptemp);
            if (k and $40)<>0 then ptemp^:=paleta[FC] else ptemp^:=paleta[BC];inc(ptemp);
            if (k and $20)<>0 then ptemp^:=paleta[FC] else ptemp^:=paleta[BC];inc(ptemp);
            if (k and $10)<>0 then ptemp^:=paleta[FC] else ptemp^:=paleta[BC];inc(ptemp);
            if (k and 8)<>0 then ptemp^:=paleta[FC] else ptemp^:=paleta[BC];inc(ptemp);
            if (k and 4)<>0 then ptemp^:=paleta[FC] else ptemp^:=paleta[BC];
            putpixel((6*X)+BORDER, (Y shl 3+i)+BORDER, 6,punbuf,tms.pant);
            s:=s+1;
          end;
          name_base:=name_base+1;
        end;
      end;
end;

procedure draw_mode12;
var
  I,X,Y,name_base:word;
  ptemp:pword;
  FC,BC,pattern:byte;
  charcode,patternptr:word;
begin
      FC:=tms.nFGColor;
      BC:=tms.nBGColor;
      name_base:=tms.Nametbl;
      for Y:=0 to 23 do begin
        for x:=0 to 39 do begin
          charcode:=(tms.memory[name_base]+(y shr 3)*256) and tms.patternmask;
          name_base:=name_base+1;
          patternptr:=tms.pattern+(charcode shl 3);
          for i:=0 to 7 do begin
            pattern:=tms.memory[patternptr];
            patternptr:=patternptr+1;
            ptemp:=punbuf;
            if (pattern and $80)<>0 then ptemp^:=paleta[FC] else ptemp^:=paleta[BC];inc(ptemp);
            if (pattern and $40)<>0 then ptemp^:=paleta[FC] else ptemp^:=paleta[BC];inc(ptemp);
            if (pattern and $20)<>0 then ptemp^:=paleta[FC] else ptemp^:=paleta[BC];inc(ptemp);
            if (pattern and $10)<>0 then ptemp^:=paleta[FC] else ptemp^:=paleta[BC];inc(ptemp);
            if (pattern and 8)<>0 then ptemp^:=paleta[FC] else ptemp^:=paleta[BC];inc(ptemp);
            if (pattern and 4)<>0 then ptemp^:=paleta[FC] else ptemp^:=paleta[BC];
            putpixel((6*X)+BORDER, (Y shl 3+i)+BORDER, 6,punbuf,tms.pant);
          end;
        end;
      end;
end;

procedure draw_mode2;
var
  i,x,y,fc,bc:byte;
  name_base,colour,pattern,patternptr,colourptr,charcode:word;
  ptemp:pword;
 begin
      name_base:=tms.NameTbl;
      for y:=0 to 23 do begin
          for x:=0 to 31 do begin
            charcode:=tms.memory[name_base]+(y shr 3)*256;
            name_base:=name_base+1;
            colour:=charcode and tms.colourmask;
            pattern:=charcode and tms.patternmask;
            patternptr:=tms.pattern+(colour*8);
            colourptr:=tms.colour+(pattern*8);
            for i:=0 to 7 do begin
              pattern:=tms.memory[patternptr];
              patternptr:=patternptr+1;
              bc:=tms.memory[colourptr];
              colourptr:=colourptr+1;
              fc:=bc shr 4;
              bc:=bc and $F;
              ptemp:=punbuf;
              if (pattern and $80)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
              if (pattern and $40)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
              if (pattern and $20)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
              if (pattern and $10)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
              if (pattern and 8)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
              if (pattern and 4)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
              if (pattern and 2)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];inc(ptemp);
              if (pattern and 1)<>0 then ptemp^:=paleta[fc] else ptemp^:=paleta[bc];
              putpixel((x shl 3)+BORDER,(y shl 3)+i+BORDER,8,punbuf,tms.pant);
            end;
          end;
      end;
end;

procedure draw_mode3;
var
    fc,x,y,i,h:byte;
    patternptr,charcode,name_base:word;
begin
    name_base:=tms.nametbl;
    for y:=0 to 23 do begin
        for x:=0 to 31 do begin
            charcode:=tms.memory[name_base];
            name_base:=name_base+1;
            patternptr:=tms.pattern+(charcode*8)+(y and 3)*2;
            for i:=0 to 1 do begin
                FC:=tms.memory[patternptr] shr 4;
                patternptr:=patternptr+1;
                for h:=0 to 3 do begin
                    punbuf^:=paleta[fc];
                    putpixel((X shl 3)+0+BORDER,(y shl 3)+i*4+h+BORDER,1,punbuf,tms.pant);
                    putpixel((X shl 3)+1+BORDER,(y shl 3)+i*4+h+BORDER,1,punbuf,tms.pant);
                    putpixel((X shl 3)+2+BORDER,(y shl 3)+i*4+h+BORDER,1,punbuf,tms.pant);
                    putpixel((X shl 3)+3+BORDER,(y shl 3)+i*4+h+BORDER,1,punbuf,tms.pant);
                    putpixel((X shl 3)+4+BORDER,(y shl 3)+i*4+h+BORDER,1,punbuf,tms.pant);
                    putpixel((X shl 3)+5+BORDER,(y shl 3)+i*4+h+BORDER,1,punbuf,tms.pant);
                    putpixel((X shl 3)+6+BORDER,(y shl 3)+i*4+h+BORDER,1,punbuf,tms.pant);
                    putpixel((X shl 3)+7+BORDER,(y shl 3)+i*4+h+BORDER,1,punbuf,tms.pant);
                end;
            end;
        end;
    end;
end;

procedure draw_modebogus;
var
    fc,bc:byte;
    x,y,n,xx:byte;
begin
    fc:=tms.nFGColor;
    bc:=tms.nBGColor;
    for y:=0 to 191 do begin
        xx:=0;
        n:=8;
        punbuf^:=paleta[bc];
        while (n<>0) do begin
          n:=n-1;
          putpixel(xx+BORDER,y+BORDER,1,punbuf,tms.pant);
          xx:=xx+1;
        end;
        for x:=0 to 39 do begin
            n:=4;
            punbuf^:=paleta[fc];
            while (n<>0) do begin
              n:=n-1;
              putpixel(xx+BORDER,y+BORDER,1,punbuf,tms.pant);
              xx:=xx+1;
            end;
            n:=2;
            punbuf^:=paleta[bc];
            while (n<>0) do begin
              n:=n-1;
              putpixel(xx+BORDER,y+BORDER,1,punbuf,tms.pant);
              xx:=xx+1;
            end;
        end;
        n:=8;
        punbuf^:=paleta[bc];
        while (n<>0) do begin
          n:=n-1;
          putpixel(xx+BORDER,y+BORDER,1,punbuf,tms.pant);
          xx:=xx+1;
        end;
    end;
end;

procedure refresh_border(bcolor:byte);
var
  f:word;
begin
for f:=0 to (BORDER-1) do begin
  single_line(0,f,bcolor,256+(BORDER*2),tms.pant);
  single_line(0,192+BORDER+f,bcolor,256+(BORDER*2),tms.pant);
end;
for f:=BORDER to 191+BORDER do begin
  single_line(0,f,bcolor,BORDER,tms.pant);
  single_line(256+BORDER,f,bcolor,BORDER,tms.pant);
end;
end;

procedure TMS99XX_refresh;
var
  modo:byte;
begin
  if (tms.regs[1] and $40)=0 then begin
    fill_full_screen(0,tms.nBGColor);
    exit;
  end;
  refresh_border(tms.nBGColor);
  modo:=(tms.Regs[0] and 2) or ((tms.Regs[1] and $10) shr 4) or ((tms.Regs[1] and 8) shr 1);
  case Modo of
    0:draw_mode0;
    1:draw_mode1;
    2:draw_mode2;
    3:draw_mode12;
    4:draw_mode3;
    5,7:draw_modebogus;
  end;
  if((tms.regs[1] and $50)=$40) then draw_sprites;
end;

function TMS99XX_register_r:integer;
begin
     TMS99XX_register_r:=tms.status_reg;
     tms.status_reg:=tms.status_reg and $5F;
     tms.latch:=1;
     if tms.int then begin
      tms.int:=false;
      if @tms.IRQ_Handler<>nil then tms.IRQ_Handler(tms.INT);
     end;
end;

procedure TMS99XX_register_w(value:byte);
begin
if tms.latch<>0 then begin
  tms.nVR:=value;
  tms.latch:=0;
end else begin
  tms.latch:=1;
  case (value and $C0) of
    $80:OutByte(value and $7,tms.nVR);
    $00,$40:begin
              tms.nAddr:=(tms.nVR or (value shl 8)) and tms.TMS9918A_VRAM_SIZE;
              tms.wkey:=value and $40;
            end;
  end;
end;
end;

procedure TMS99XX_Interrupt;
var
  b:boolean;
begin
b:=((tms.regs[1] and $20)<>0);
if b<>tms.int then begin
    tms.int:=b;
    if @tms.IRQ_Handler<>nil then tms.IRQ_Handler(tms.INT);
    tms.status_reg:=tms.status_reg or $80;
end;
end;

function TMS99XX_vram_r:byte;
begin
  TMS99XX_vram_r:=tms.memory[tms.nAddr];
  tms.nAddr:=(tms.nAddr+1) and tms.TMS9918A_VRAM_SIZE; // neue adresse setzten
end;

procedure WriteVRAM(nValue:byte);
begin
if tms.wkey<>0 then begin
  tms.memory[tms.nAddr]:=nValue;
  tms.nAddr:=(tms.nAddr+1) and tms.TMS9918A_VRAM_SIZE;
end else begin
  tms.nAddr:=(tms.nAddr+1) and tms.TMS9918A_VRAM_SIZE;
  tms.memory[tms.nAddr]:=nValue;
end;
end;

procedure TMS99XX_vram_w(nValue:byte);
begin
if (tms.latch<>0) then WriteVram(nValue);
end;

procedure TMS99XX_close;
begin
if tms<>nil then begin
  freemem(tms);
  tms:=nil;
end;
end;

end.