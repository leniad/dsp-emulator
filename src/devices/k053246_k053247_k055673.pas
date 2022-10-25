unit k053246_k053247_k055673;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}main_engine,gfx_engine;

type
     t_k053247_cb=procedure(var code:dword;var color:word;var priority_mask:word);
     k053246_chip=class
              constructor create(pant:byte;call_back:t_k053247_cb;rom:pbyte;rom_size:dword);
              destructor free;
          public
              procedure reset;
              function is_irq_enabled:boolean;
              function read(direccion:byte):byte;
              procedure write(direccion,valor:byte);
              function k053247_r(direccion:word):byte;
              procedure k053247_w(direccion:word;valor:byte);
              function k053247_get_ram:pword;
              procedure set_objcha_line(status:byte);
              //sprites
              procedure k053247_start(dx:byte=0;dy:byte=0);
              procedure k053247_draw_sprites(prio:byte);
              procedure k053247_update_sprites;
          private
              kx46_regs:array[0..7] of byte;
	            kx47_regs:array[0..31] of word;
              objcha_line,sprite_count:byte;
              rom:pbyte;
              rom_size,rom_mask,sprite_mask:dword;
              k053247_cb:t_k053247_cb;
              pant,dx,dy:byte;
              ram:array[0..$7ff] of word;
              sorted_list:array[0..$ff] of word;
              z_rejection:integer;
              procedure k053247_draw_single_sprite_gxcore(code:dword;offs:word;color,shadow:word);
              procedure k053247_draw_yxloop_gx(height,width,ox,oy,code,color,shadow,xa,ya:integer;zoomx,zoomy:single;nozoom,mirrorx,mirrory,flipx,flipy:boolean);
     end;

var
   k053246_0:k053246_chip;

implementation

constructor k053246_chip.create(pant:byte;call_back:t_k053247_cb;rom:pbyte;rom_size:dword);
begin
  self.pant:=pant;
  self.rom:=rom;
  self.rom_size:=rom_size;
  self.rom_mask:=rom_size-1;
  self.k053247_cb:=call_back;
end;

destructor k053246_chip.free;
begin
end;

procedure k053246_chip.reset;
var
  f:byte;
begin
	self.z_rejection:=-1;
	self.objcha_line:=CLEAR_LINE;
	for f:=0 to 7 do self.kx46_regs[f]:=0;
  for f:=0 to 31 do self.kx47_regs[f]:=0;
end;

function k053246_chip.k053247_get_ram:pword;
begin
  k053247_get_ram:=@self.ram;
end;

function k053246_chip.is_irq_enabled:boolean;
begin
     is_irq_enabled:=(kx46_regs[5] and $10)<>0
end;

function k053246_chip.read(direccion:byte):byte;
var
   addr:dword;
begin
  if self.objcha_line=ASSERT_LINE then begin
    addr:=(kx46_regs[6] shl 17) or (kx46_regs[7] shl 9) or (kx46_regs[4] shl 1) or ((direccion and 1) xor 1);
    read:=self.rom[addr and self.rom_mask];
  end else read:=0;
end;

procedure k053246_chip.write(direccion,valor:byte);
begin
     self.kx46_regs[direccion]:=valor;
end;

procedure k053246_chip.set_objcha_line(status:byte);
begin
  self.objcha_line:=status;
end;

function k053246_chip.k053247_r(direccion:word):byte;
begin
  if (direccion and 1)<>0 then k053247_r:=self.ram[direccion shr 1] and $ff
    else k053247_r:=self.ram[direccion shr 1] shr 8;
end;

procedure k053246_chip.k053247_w(direccion:word;valor:byte);
begin
if (direccion and 1)<>0 then self.ram[direccion shr 1]:=(self.ram[direccion shr 1] and $ff00) or valor
    else self.ram[direccion shr 1]:=(self.ram[direccion shr 1] and $ff) or (valor shl 8);
end;

procedure k053246_chip.k053247_start(dx:byte=0;dy:byte=0);
const
  ps_x:array[0..15] of dword=(2*4, 3*4, 0*4, 1*4, 6*4, 7*4, 4*4, 5*4,
				10*4, 11*4, 8*4, 9*4, 14*4, 15*4, 12*4, 13*4);
  ps_y:array[0..15] of dword=(0*64, 1*64, 2*64, 3*64, 4*64, 5*64, 6*64, 7*64,
				8*64, 9*64, 10*64, 11*64, 12*64, 13*64, 14*64, 15*64);
begin
  self.sprite_mask:=(self.rom_size div 128)-1;
  self.dx:=dx;
  self.dy:=dy;
  init_gfx(1,16,16,self.rom_size div 128);
  gfx_set_desc_data(4,0,8*128,0,1,2,3);
  convert_gfx(1,0,self.rom,@ps_x,@ps_y,false,false);
  gfx[1].trans[0]:=true;
  gfx[1].alpha[$f]:=true;
end;

procedure k053246_chip.k053247_draw_yxloop_gx(height,width,ox,oy,code,color,shadow,xa,ya:integer;zoomx,zoomy:single;nozoom,mirrorx,mirrory,flipx,flipy:boolean);
const
   xoffset:array [0..7] of byte=(0,1,4,5,16,17,20,21);
   yoffset:array [0..7] of byte=(0,2,8,10,32,34,40,42);
var
  sx,sy:integer;
  fx,fy:boolean;
  tempcode,x,y:integer;
begin
		for y:=0 to (height-1) do begin
      sy:=oy+(round(zoomy*y*16));
			//zh:=(oy+((zoomy*(y+1)+(1 shl 11)) shr 12))-sy;
			for x:=0 to (width-1) do begin
        sx:=ox+(round(zoomx*x*16));
				//zw:=(ox+((zoomx*(x+1)+(1 shl 11)) shr 12))-sx;
				tempcode:=code;
				if mirrorx then begin
					if (not(flipx) xor ((x shl 1)<width)) then begin
						// mirror left/right */
						tempcode:=tempcode+(xoffset[(width-1-x+xa) and 7]);
						fx:=true;
					end else begin
						tempcode:=tempcode+(xoffset[(x+xa) and 7]);
						fx:=false;
					end;
				end else begin
					if flipx then tempcode:=tempcode+(xoffset[(width-1-x+xa) and 7])
					  else tempcode:=tempcode+(xoffset[(x+xa) and 7]);
					fx:=flipx;
				end;
				if mirrory then begin
					if (not(flipy) xor ((y shl 1)>=height)) then begin
						// mirror top/bottom */
						tempcode:=tempcode+(yoffset[(height-1-y+ya) and 7]);
						fy:=true;
					end else begin
						tempcode:=tempcode+(yoffset[(y+ya) and 7]);
						fy:=false;
					end;
				end else begin
					if flipy then tempcode:=tempcode+(yoffset[(height-1-y+ya) and 7])
					  else tempcode:=tempcode+(yoffset[(y+ya) and 7]);
					fy:=flipy;
				end;
        if (shadow shr 10)<>0 then begin
          if not(nozoom) then begin
            put_gfx_sprite_zoom_alpha(tempcode,color shl 4,fx,fy,1,zoomx,zoomy);
            actualiza_gfx_sprite_zoom_alpha(sx and $3ff,sy and $3ff,4,1,zoomx,zoomy);
          end else begin
            put_gfx_sprite_alpha(tempcode,color shl 4,fx,fy,1);
            actualiza_gfx_sprite_alpha(sx and $3ff,sy and $3ff,4,1);
          end;
        end else begin
          if not(nozoom) then begin
            put_gfx_sprite_zoom(tempcode,color shl 4,fx,fy,1,zoomx,zoomy);
            actualiza_gfx_sprite_zoom(sx and $3ff,sy and $3ff,4,1,zoomx,zoomy);
          end else begin
            put_gfx_sprite(tempcode,color shl 4,fx,fy,1);
            actualiza_gfx_sprite(sx and $3ff,sy and $3ff,4,1);
          end;
        end;
        if (mirrory and (height=1)) then begin  // Simpsons shadows
					 if not(nozoom) then begin
              put_gfx_sprite_zoom_alpha(tempcode,color shl 4,fx,not(fy),1,zoomx,zoomy);
              actualiza_gfx_sprite_zoom_alpha(sx and $3ff,sy and $3ff,4,1,zoomx,zoomy);
           end else begin
              put_gfx_sprite_alpha(tempcode,color shl 4,fx,not(fy),1);
              actualiza_gfx_sprite_alpha(sx and $3ff,sy and $3ff,4,1);
           end;
        end;
			end; // end of X loop
		end; // end of Y loop
end;

procedure k053246_chip.k053247_draw_single_sprite_gxcore(code:dword;offs:word;color,shadow:word);
var
		xa,ya,ox,oy:integer;
    scalex,scaley:byte;
		wrapsize,xwraplim,ywraplim,screenwidth,objset1,temp,temp4,flipscreenx,flipscreeny:integer;
    k053247_opset,offx,offy,width,height:integer;
    zoomx,zoomy:single;
    nozoom,mirrorx,mirrory,flipx,flipy:boolean;
begin
		flipscreenx:=0;//self.kx46_regs[5] and $01;
		flipscreeny:=0;//self.kx46_regs[5] and $02;
		xa:=0;
    ya:=0;
		if (code and $01)<>0 then xa:=xa+1;
		if (code and $02)<>0 then ya:=ya+1;
		if (code and $04)<>0 then xa:=xa+2;
		if (code and $08)<>0 then ya:=ya+2;
		if (code and $10)<>0 then xa:=xa+4;
		if (code and $20)<>0 then ya:=ya+4;
		code:=code and not($3f);
		temp4:=self.ram[offs];
		// mask off the upper 6 bits of coordinate and zoom registers
		oy:=self.ram[offs+2] and $3ff;
		ox:=self.ram[offs+3] and $3ff;
    scaley:=self.ram[offs+4];
    if (scaley<>0) then zoomy:=$40/scaley
      else zoomy:=0;
  	if ((temp4 and $4000)=0) then begin
      scalex:=self.ram[offs+5];
      if (scalex<>0) then zoomx:=$40/scalex
        else zoomx:=0;
		end else begin
      zoomx:=zoomy;
      scalex:=scaley;
    end;
		nozoom:=(scalex=$40) and (scaley=$40);
		flipx:=(temp4 and $1000)<>0;
		flipy:=(temp4 and $2000)<>0;
		temp:=self.ram[offs+6];
		mirrorx:=(temp and $4000)<>0;
		if mirrorx then flipx:=false; // only applies to x mirror, proven
		mirrory:=(temp and $8000)<>0;
		objset1:=self.kx46_regs[5];
		// for Escape Kids (GX975)
		if (objset1 and 8)<>0 then begin // Check only "Bit #3 is '1'?"
			screenwidth:=512;// m_screen->width();
			zoomx:=zoomx/2; // Fix sprite width to HALF size
			ox:=(ox shr 1)+1; // Fix sprite draw position
			//if (flipscreenx<>0) then ox:=ox+screenwidth;
			nozoom:=false;
		end;
		{if (flipscreenx<>0) then begin
      ox:=-ox;
      if (mirrorx=0) then flipx:=not(flipx);
    end;
		if (flipscreeny<>0) then begin
      oy:=-oy;
      if (mirrory=0) then flipy:=not(flipy);
    end;}
		k053247_opset:=self.kx47_regs[$c div 2];
		if (k053247_opset and $40)<>0 then begin
			wrapsize:=512;
			xwraplim:=512-64;
			ywraplim:=512-128;
		end else begin
			wrapsize:=1024;
			xwraplim:=1024-384;
			ywraplim:=1024-512;
		end;
		// get "display window" offsets
		offx:=smallint((self.kx46_regs[0] shl 8) or self.kx46_regs[1]);
		offy:=smallint((self.kx46_regs[2] shl 8) or self.kx46_regs[3]);
		// apply wrapping and global offsets
		temp:=wrapsize-1;
		ox:=(ox-offx) and temp;
		oy:=(-oy-offy) and temp;
		if (ox>=xwraplim) then ox:=ox-wrapsize;
		if (oy>=ywraplim) then oy:=oy-wrapsize;
		temp:=(temp4 shr 8) and $0f;
		width:=1 shl (temp and 3);
		height:=1 shl ((temp shr 2) and 3);
		ox:=ox-trunc(zoomx*width*8);
		oy:=oy-trunc(zoomy*height*8);
  	//color:=color and $ffff; // strip attribute flags
		self.k053247_draw_yxloop_gx(height,width,ox+53-self.dx,oy-6-self.dy,code,color,shadow,xa,ya,zoomx,zoomy,nozoom,mirrorx,mirrory,flipx,flipy);
end;

procedure k053246_chip.k053247_update_sprites;
var
  count,f:byte;
begin
count:=0;
if (self.z_rejection=-1) then begin
		for f:=0 to $ff do
			if (self.ram[f*8] and $8000)<>0 then begin
        self.sorted_list[count]:=f*8;
        count:=count+1;
      end;
end else begin
		for f:=0 to $ff do
			if (((self.ram[f*8] and $8000)<>0) and ((self.ram[f*8] and $ff)<>self.z_rejection)) then begin
        self.sorted_list[count]:=f*8;
        count:=count+1;
      end;
end;
self.sprite_count:=count;
end;

procedure k053246_chip.k053247_draw_sprites(prio:byte);
var
  zcode:integer;
  shadow,color,primask,temp,w,y,x,f:word;
  code:dword;
begin
  if self.sprite_count=0 then exit;
  if ((self.kx47_regs[$c div 2] and $10)=0) then begin
		// sort objects in decending order(smaller z closer) when OPSET PRI is clear
		for y:=0 to (self.sprite_count-1) do begin
			f:=sorted_list[y];
			zcode:=self.ram[f] and $ff;
			for x:=y+1 to self.sprite_count do begin
				temp:=sorted_list[x];
				code:=self.ram[temp] and $ff;
				if (zcode<=code) then begin
					zcode:=code;
					sorted_list[x]:=f;
					sorted_list[y]:=temp;
          f:=temp;
				end;
			end;
		end;
	end else begin
		// sort objects in ascending order(bigger z closer) when OPSET PRI is set
		for y:=0 to (self.sprite_count-1) do begin
			f:=sorted_list[y];
			zcode:=self.ram[f] and $ff;
			for x:=y+1 to self.sprite_count do begin
				temp:=sorted_list[x];
				code:=self.ram[temp] and $ff;
				if (zcode>=code) then begin
					zcode:=code;
					sorted_list[x]:=f;
					sorted_list[y]:=temp;
          f:=temp;
				end;
			end;
		end;
	end;
  for f:=0 to (self.sprite_count-1) do begin
		w:=sorted_list[f];
		code:=self.ram[w+1] and self.sprite_mask;
    color:=self.ram[w+6];
    shadow:=color;
		primask:=0;
    self.k053247_cb(code,color,primask);
    if primask<>prio then continue;
    self.k053247_draw_single_sprite_gxcore(code,w,color,shadow);
	end; // end of sprite-list loop
end;

end.

