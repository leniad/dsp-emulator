unit blitter_williams;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     main_engine,cpu_misc,m6809;

type
  williams_blitter=class
      constructor create(xor_:byte;window_enable:boolean;clip_address:word);
      destructor free;
    public
      procedure reset;
      procedure blitter_w(dir,valor:byte);
      procedure set_read_write(getbyte:tgetbyte;putbyte:tputbyte);
    private
      ram:array[0..7] of byte;
      xor_:byte;
      remap:array[0..$ffff] of byte;
      window_enable:boolean;
      clip_address:word;
      getbyte:tgetbyte;
      putbyte:tputbyte;
      procedure blit_pixel(dstaddr,srcdata:word);
      function blitter_core(sstart,dstart:word;w,h:byte):byte;
    end;
const
  CONTROLBYTE_NO_EVEN=$80;
  CONTROLBYTE_NO_ODD=$40;
  CONTROLBYTE_SHIFT=$20;
  CONTROLBYTE_SOLID=$10;
  CONTROLBYTE_FOREGROUND_ONLY=8;
  CONTROLBYTE_SLOW=4; //2us blits instead of 1us
  CONTROLBYTE_DST_STRIDE_256=2;
  CONTROLBYTE_SRC_STRIDE_256=1;

var
  blitter_0:williams_blitter;

implementation

constructor williams_blitter.create(xor_:byte;window_enable:boolean;clip_address:word);
const
  dummy_table:array[0..$f] of byte=(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15);
var
  i,f:byte;
begin
  self.xor_:=xor_;
  self.window_enable:=window_enable;
  self.clip_address:=clip_address;
  for i:=0 to 255 do
    for f:=0 to 255 do
      self.remap[i*256+f]:=(dummy_table[f shr 4] shl 4) or dummy_table[f and $0f];
end;

destructor williams_blitter.free;
begin
end;

procedure williams_blitter.reset;
begin
  fillchar(self.ram,8,0);
end;

procedure williams_blitter.set_read_write(getbyte:tgetbyte;putbyte:tputbyte);
begin
  self.getbyte:=getbyte;
  self.putbyte:=putbyte;
end;

procedure williams_blitter.blit_pixel(dstaddr,srcdata:word);
var
  solid,keepmask,curpix:byte;
begin
	// always read from video RAM regardless of the bank setting
	if (dstaddr<$c000) then curpix:=memoria[dstaddr]
    else curpix:=self.getbyte(dstaddr);   //current pixel values at dest
	solid:=self.ram[1];
	keepmask:=$ff;          //what part of original dst byte should be kept, based on NO_EVEN and NO_ODD flags
	//even pixel (D7-D4)
	if (((self.ram[0] and CONTROLBYTE_FOREGROUND_ONLY)<>0) and ((srcdata and $f0)=0)) then begin //FG only and src even pixel=0
		if (self.ram[0] and CONTROLBYTE_NO_EVEN)<>0 then keepmask:=keepmask and $0f;
	end else begin
		if ((self.ram[0] and CONTROLBYTE_NO_EVEN))=0 then keepmask:=keepmask and $0f;
  end;
	//odd pixel (D3-D0)
	if (((self.ram[0] and CONTROLBYTE_FOREGROUND_ONLY)<>0) and ((srcdata and $0f)=0)) then begin    //FG only and src odd pixel=0
		if (self.ram[0] and CONTROLBYTE_NO_ODD)<>0 then keepmask:=keepmask and $f0;
	end else begin
		if ((self.ram[0] and CONTROLBYTE_NO_ODD))=0 then keepmask:=keepmask and $f0;
	end;
	curpix:=curpix and keepmask;
	if (self.ram[0] and CONTROLBYTE_SOLID)<>0 then curpix:=curpix or (solid and not(keepmask))
	  else curpix:=curpix or (srcdata and not(keepmask));
  // if the window is enabled, only blit to videoram below the clipping address
  // note that we have to allow blits to non-video RAM (e.g. tileram, Sinistar $DXXX SRAM) because those
  // are not blocked by the window enable
	if (not(self.window_enable) or (dstaddr<self.clip_address) or (dstaddr>=$c000)) then self.putbyte(dstaddr,curpix);
end;

function williams_blitter.blitter_core(sstart,dstart:word;w,h:byte):byte;
var
  accesses,y,x:byte;
  sxadv,syadv,dxadv,dyadv:word;
  source,dest,pixdata:word;
begin
  accesses:=0;
	// compute how much to advance in the x and y loops
	if (self.ram[0] and CONTROLBYTE_SRC_STRIDE_256)<>0 then begin
    sxadv:=$100;
	  syadv:=1;
  end else begin
    sxadv:=1;
    syadv:=w;
  end;
  if (self.ram[0] and CONTROLBYTE_DST_STRIDE_256)<>0 then begin
    dxadv:=$100;
    dyadv:=1;
  end else begin
    dxadv:=1;
    dyadv:=w;
  end;
	pixdata:=0;
	// loop over the height
	for y:=0 to (h-1) do begin
		source:=sstart;
		dest:=dstart;
		// loop over the width
		for x:=0 to (w-1) do begin
			  if ((self.ram[0] and CONTROLBYTE_SHIFT)=0) then begin //no shift
				  self.blit_pixel(dest,self.remap[self.getbyte(source)]);
			  end else begin //shift one pixel right
				  pixdata:=(pixdata shl 8) or self.remap[self.getbyte(source)];
				  self.blit_pixel(dest,(pixdata shr 4) and $ff);
        end;
			  accesses:=accesses+2;
			  // advance src and dst pointers
			  source:=source+sxadv;
			  dest:=dest+dxadv;
    end;
		// note that PlayBall! indicates the X coordinate doesn't wrap
		if (self.ram[0] and CONTROLBYTE_DST_STRIDE_256)<>0 then dstart:=(dstart and $ff00) or ((dstart+dyadv) and $ff)
		  else dstart:=dstart+dyadv;
		if (self.ram[0] and CONTROLBYTE_SRC_STRIDE_256)<>0 then sstart:=(sstart and $ff00) or ((sstart+syadv) and $ff)
		  else sstart:=sstart+syadv;
  end;
	blitter_core:=accesses;
end;

procedure williams_blitter.blitter_w(dir,valor:byte);
var
  estimated_clocks_at_4MHz,sstart,dstart:word;
  w,h,accesses:byte;
begin
  self.ram[dir]:=valor;
  if (dir<>0) then exit;
  // compute the starting locations
	sstart:=(self.ram[2] shl 8)+self.ram[3];
	dstart:=(self.ram[4] shl 8)+self.ram[5];
	// compute the width and height
	w:=self.ram[6] xor self.xor_;
	h:=self.ram[7] xor self.xor_;
	// adjust the width and height
	if (w=0) then w:=1;
	if (h=0) then h:=1;
	// do the actual blit
	accesses:=self.blitter_core(sstart,dstart,w,h);
	// based on the number of memory accesses needed to do the blit, compute how long the blit will take
	estimated_clocks_at_4MHz:=4;
	if (valor and CONTROLBYTE_SLOW)<>0 then estimated_clocks_at_4MHz:=estimated_clocks_at_4MHz+(4*(accesses+2))
    else estimated_clocks_at_4MHz:=estimated_clocks_at_4MHz+(2*(accesses+3));
  m6809_0.contador:=m6809_0.contador+((estimated_clocks_at_4MHz+3) div 4);
end;


end.
