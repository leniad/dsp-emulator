unit atari_mo;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     gfx_engine;

const
  MAX_PER_BANK=1024;
type
  entry=array[0..3] of word;
  dual_entry=record
          data_lower:entry;
          data_upper:entry;
  end;
  atari_motion_objects_config=record
	        gfxindex:byte;           // index to which gfx system
          bankcount:byte;          // number of motion object banks
          linked:boolean;             // are the entries linked?
          split:boolean;              // are the entries split?
          reverse:boolean;            // render in reverse order?
          swapxy:boolean;             // render in swapped X/Y order?
          nextneighbor:boolean;       // does the neighbor bit affect the next object?
          slipheight:word;         // pixels per SLIP entry (0 for no-slip)
          slipoffset:byte;         // pixel offset for SLIPs
          maxperline:word;         // maximum number of links to visit/scanline (0=all)

          palettebase:word;        // base palette entry
          maxcolors:word;          // maximum number of colors (remove me)
          transpen:byte;           // transparent pen index

          link_entry:entry;           // mask for the link
          code_entry:dual_entry;           // mask for the code index
          color_entry:dual_entry;          // mask for the color/priority
          xpos_entry:entry;           // mask for the X position
          ypos_entry:entry;           // mask for the Y position
          width_entry:entry;          // mask for the width, in tiles*/
          height_entry:entry;         // mask for the height, in tiles
          hflip_entry:entry;          // mask for the horizontal flip
          vflip_entry:entry;          // mask for the vertical flip
          priority_entry:entry;       // mask for the priority
          neighbor_entry:entry;       // mask for the neighbor
          absolute_entry:entry;       // mask for absolute coordinates
          special_entry:entry;        // mask for the special value
          specialvalue:word;         // resulting value to indicate "special"
  end;
  tatari_mo=class
          constructor create(slip_ram:pword;sprite_ram:pword;config:atari_motion_objects_config;screen:byte;xmax,ymax:word);
          destructor free;
          type
              sprite_parameter=class
                  constructor create;
                  destructor free;
                  public
                    shift:word;            // shift amount
                    mask:word;             // final mask
                    function extract(data:pword):word;
                    function set_(input:entry):boolean;
                  private
                    word_:word;             // word index
              end;
              dual_sprite_parameter=class
                  constructor create;
                  destructor free;
                  public
                    function extract(data:pword):word;
                    function set_(input:dual_entry):boolean;
                    function mask:word;
                  private
                    lower:sprite_parameter;            // lower parameter
                    upper:sprite_parameter;            // upper parameter
                    uppershift:word;       // upper shift
              end;
          public
            procedure draw(xscroll,yscroll:word;prio:byte);
            function get_codelookup:pword;
          private
            xmax,ymax:word;
            screen:byte;
            sprite_ram:pword;
            config:atari_motion_objects_config;
            // parameter masks
            linkmask:sprite_parameter;         // mask for the link
            gfxmask:sprite_parameter;          // mask for the graphics bank
            codemask:dual_sprite_parameter;         // mask for the code index
            colormask:dual_sprite_parameter;        // mask for the color
            xposmask:sprite_parameter;         // mask for the X position
            yposmask:sprite_parameter;         // mask for the Y position
            widthmask:sprite_parameter;        // mask for the width, in tiles*/
            heightmask:sprite_parameter;       // mask for the height, in tiles
            hflipmask:sprite_parameter;        // mask for the horizontal flip
            vflipmask:sprite_parameter;        // mask for the vertical flip
            prioritymask:sprite_parameter;     // mask for the priority
            neighbormask:sprite_parameter;     // mask for the neighbor
            absolutemask:sprite_parameter;     // mask for absolute coordinates
            specialmask:sprite_parameter;      // mask for the special value
            // derived tile information
            tilewidth:integer;          // width of non-rotated tile
            tileheight:integer;         // height of non-rotated tile
            tilexshift:integer;         // bits to shift X coordinate when drawing
            tileyshift:integer;         // bits to shift Y coordinate when drawing
	          // derived bitmap information
            bitmapwidth:integer;        // width of the full playfield bitmap
            bitmapheight:integer;       // height of the full playfield bitmap
            bitmapxmask:integer;        // x coordinate mask for the playfield bitmap
            bitmapymask:integer;        // y coordinate mask for the playfield bitmap
	          // derived sprite information
            entrycount:integer;         // number of entries per bank
            entrybits:integer;          // number of bits needed to represent entrycount
            spriterammask:integer;      // combined mask when accessing sprite RAM with raw addresses
            spriteramsize:integer;      // total size of sprite RAM, in entries
            slipshift:integer;          // log2(pixels_per_SLIP)
            sliprammask:integer;        // combined mask when accessing SLIP RAM with raw addresses
            slipramsize:integer;        // total size of SLIP RAM, in entries
	          // live state
	          //emu_timer *             m_force_update_timer;   // timer for forced updating
            bank:dword;               // current bank number
	          // arrays
	          slipram:pword;    // pointer to the SLIP RAM
	          codelookup:pword;       // lookup table for codes
	          colorlookup:pword;       // lookup table for colors
	          gfxlookup:pbyte;         // lookup table for graphics

            activelist:array[0..(MAX_PER_BANK*40)-1] of word; // active list
            activelast:pword;           // last entry in the active list

            last_xpos:dword;          // (during processing) the previous X position
            next_xpos:dword;          // (during processing) the next X position
	          //required_device<gfxdecode_device> m_gfxdecode;
            procedure render_object(entry:pword;xscroll,yscroll:word;prio:byte);
            procedure build_active_list(link:word);
          end;

var
  atari_mo_0:tatari_mo;

implementation

function compute_log(value:integer):integer;
var
  log:integer;
begin
log:=0;
if (value=0) then begin
		compute_log:=-1;
    exit;
end;
while ((value and 1)=0) do begin
  log:=log+1;
  value:=value shr 1;
end;
if (value<>1) then begin
		compute_log:=-1;
    exit;
end;
	compute_log:=log;
end;

function round_to_powerof2(value:integer):integer;
var
  log:integer;
begin
	log:=0;
	if (value=0) then begin
      round_to_powerof2:=1;
      exit;
  end;
  value:=value shr 1;
	while (value<>0) do begin
    log:=log+1;
    value:=value shr 1
  end;
	round_to_powerof2:=1 shl (log+1);
end;

constructor tatari_mo.create(slip_ram:pword;sprite_ram:pword;config:atari_motion_objects_config;screen:byte;xmax,ymax:word);
var
  codesize,colorsize,i,gfxsize:integer;
  temp:pword;
  tempb:pbyte;
begin
  self.screen:=screen;
  self.xmax:=xmax;
  self.ymax:=ymax;
  self.config:=config;
  self.sprite_ram:=sprite_ram;
  self.linkmask:=tatari_mo.sprite_parameter.create;
  self.gfxmask:=tatari_mo.sprite_parameter.create;
  self.codemask:=tatari_mo.dual_sprite_parameter.create;
  self.colormask:=tatari_mo.dual_sprite_parameter.create;
  self.xposmask:=tatari_mo.sprite_parameter.create;
  self.yposmask:=tatari_mo.sprite_parameter.create;
  self.widthmask:=tatari_mo.sprite_parameter.create;
  self.heightmask:=tatari_mo.sprite_parameter.create;
  self.hflipmask:=tatari_mo.sprite_parameter.create;
  self.vflipmask:=tatari_mo.sprite_parameter.create;
  self.prioritymask:=tatari_mo.sprite_parameter.create;
  self.neighbormask:=tatari_mo.sprite_parameter.create;
  self.absolutemask:=tatari_mo.sprite_parameter.create;
  self.specialmask:=tatari_mo.sprite_parameter.create;
  self.slipram:=slip_ram;
  // determine the masks
	self.linkmask.set_(self.config.link_entry);
	self.codemask.set_(self.config.code_entry);
	self.colormask.set_(self.config.color_entry);
	self.xposmask.set_(self.config.xpos_entry);
	self.yposmask.set_(self.config.ypos_entry);
	self.widthmask.set_(self.config.width_entry);
	self.heightmask.set_(self.config.height_entry);
	self.hflipmask.set_(self.config.hflip_entry);
	self.vflipmask.set_(self.config.vflip_entry);
	self.prioritymask.set_(self.config.priority_entry);
	self.neighbormask.set_(self.config.neighbor_entry);
	self.absolutemask.set_(self.config.absolute_entry);
 	// derive tile information
	self.tilewidth:=gfx[self.config.gfxindex].x;
	self.tileheight:=gfx[self.config.gfxindex].y;
	self.tilexshift:=compute_log(self.tilewidth);
	self.tileyshift:=compute_log(self.tileheight);
	// derive bitmap information
	self.bitmapwidth:=round_to_powerof2(self.xposmask.mask);
	self.bitmapheight:=round_to_powerof2(self.yposmask.mask);
	self.bitmapxmask:=self.bitmapwidth-1;
	self.bitmapymask:=self.bitmapheight-1;
	// derive sprite information
	self.entrycount:=round_to_powerof2(self.linkmask.mask);
	self.entrybits:=compute_log(self.entrycount);
	self.spriteramsize:=self.config.bankcount*self.entrycount;
	self.spriterammask:=self.spriteramsize-1;
	if self.config.slipheight<>0 then self.slipshift:=compute_log(self.config.slipheight)
    else self.slipshift:=0;
	self.slipramsize:=self.bitmapheight shr self.slipshift;
	self.sliprammask:=self.slipramsize - 1;
	if (self.config.maxperline=0) then self.config.maxperline:=MAX_PER_BANK;
	// allocate and initialize the code lookup
	codesize:=round_to_powerof2(self.codemask.mask);
	getmem(self.codelookup,codesize*2);
  temp:=self.codelookup;
	for i:=0 to (codesize-1) do begin
    temp^:=i;
    inc(temp);
  end;
	// allocate and initialize the color lookup
	colorsize:=round_to_powerof2(self.colormask.mask);
	getmem(self.colorlookup,colorsize*2);
  temp:=self.colorlookup;
	for i:=0 to (colorsize-1) do begin
    temp^:=i;
    inc(temp);
  end;
	// allocate and the gfx lookup
	gfxsize:=codesize div 256;
	getmem(self.gfxlookup,gfxsize);
  tempb:=self.gfxlookup;
	for i:=0 to (gfxsize-1) do begin
		tempb^:=self.config.gfxindex;
  end;
end;

destructor tatari_mo.free;
begin
  self.linkmask.free;
  self.gfxmask.free;
  self.codemask.free;
  self.colormask.free;
  self.xposmask.free;
  self.yposmask.free;
  self.widthmask.free;
  self.heightmask.free;
  self.hflipmask.free;
  self.vflipmask.free;
  self.prioritymask.free;
  self.neighbormask.free;
  self.absolutemask.free;
  self.specialmask.free;
  freemem(codelookup);
  freemem(colorlookup);
  freemem(gfxlookup);
end;

function tatari_mo.get_codelookup:pword;
begin
  get_codelookup:=self.codelookup;
end;

//sprite parameter
constructor tatari_mo.sprite_parameter.create;
begin
end;

destructor tatari_mo.sprite_parameter.free;
begin
end;

function tatari_mo.sprite_parameter.extract(data:pword):word;
var
  temp:word;
begin
  inc(data,self.word_);
  temp:=data^;
  extract:=(temp shr self.shift) and self.mask
end;

function tatari_mo.sprite_parameter.set_(input:entry):boolean;
var
  f:byte;
  temp:word;
begin
self.word_:=$ffff;
for f:=0 to 3 do
  if (input[f]<>0) then begin
			if (self.word_=$ffff) then self.word_:=f
			  else begin
          set_:=false;
          exit;
        end;
  end;
	// if all-zero, it's valid
	if (self.word_=$ffff) then begin
		self.word_:=0;
    self.shift:=0;
    self.mask:=0;
		set_:=true;
    exit;
	end;
	// determine the shift and final mask
	self.shift:=0;
	temp:=input[self.word_];
	while ((temp and 1)=0) do begin
		self.shift:=self.shift+1;
		temp:=temp shr 1;
	end;
	self.mask:=temp;
	set_:=true;
end;

//dual_sprite_parameter
constructor tatari_mo.dual_sprite_parameter.create;
begin
  self.lower:=tatari_mo.sprite_parameter.create;
  self.upper:=tatari_mo.sprite_parameter.create;
end;

destructor tatari_mo.dual_sprite_parameter.free;
begin
  self.lower.free;
  self.upper.free;
end;

function tatari_mo.dual_sprite_parameter.set_(input:dual_entry):boolean;
var
  temp:word;
begin
	// convert the lower and upper parts
	if (not self.lower.set_(input.data_lower)) then begin
		set_:=false;
    exit;
  end;
	if (not self.upper.set_(input.data_upper)) then begin
		set_:=false;
    exit;
  end;
	// determine the upper shift amount
	temp:=self.lower.mask;
	self.uppershift:=0;
	while (temp <>0) do begin
		self.uppershift:=self.uppershift+1;
		temp:=temp shr 1;
	end;
	set_:=true;
end;

function tatari_mo.dual_sprite_parameter.mask:word;
begin
  mask:=self.lower.mask or (self.upper.mask shl self.uppershift);
end;

function tatari_mo.dual_sprite_parameter.extract(data:pword):word;
begin
  extract:=self.lower.extract(data) or (self.upper.extract(data) shl self.uppershift);
end;

//Draw
procedure tatari_mo.build_active_list(link:word);
var
  f:word;
  visited:array[0..MAX_PER_BANK-1] of boolean;
  bankbase,current,modata,srcdata,temp:pword;
begin
	bankbase:=self.sprite_ram;
  inc(bankbase,self.bank shl (self.entrybits+2));
	current:=@self.activelist[0];
	// visit all the motion objects and copy their data into the display list
	//for f:=0 to (MAX_PER_BANK-1) do visited[f]:=0;
  fillchar(visited[0],MAX_PER_BANK,0);
	for f:=0 to (self.config.maxperline-1) do begin
		// copy the current entry into the list
		modata:=current;
		if (not(self.config.split)) then begin
			srcdata:=bankbase;
      inc(srcdata,link*4);
      inc(current);
			current^:=srcdata^;
      inc(current);
      inc(srcdata);
			current^:=srcdata^;
      inc(current);
      inc(srcdata);
			current^:=srcdata^;
      inc(current);
      inc(srcdata);
			current^:=srcdata^;
		end else begin
			srcdata:=bankbase;
      inc(srcdata,link);
      temp:=srcdata;
      inc(temp,0 shl self.entrybits);
			current^:=temp^;
      inc(current);
      temp:=srcdata;
      inc(temp,1 shl self.entrybits);
      current^:=temp^;
      inc(current);
      temp:=srcdata;
      inc(temp,2 shl self.entrybits);
      current^:=temp^;
      inc(current);
      temp:=srcdata;
      inc(temp,3 shl self.entrybits);
      current^:=temp^;
      inc(current);
		end;
		// link to the next object
		visited[link]:=true;
		if self.config.linked then link:=self.linkmask.extract(modata)
		  else link:=(link+1) and self.linkmask.mask;
    if visited[link] then break;
	end;
	// note the last entry
	self.activelast:=current;
end;

procedure tatari_mo.draw(xscroll,yscroll:word;prio:byte);
var
  step:integer;
  current,first,last,temp:pword;
  band,stopband:byte;
  link:word;
begin
	if (self.slipshift=0) then stopband:=0
    else stopband:=((512 div self.config.slipheight) shr 1)-1;
  //Realmente solo necesito la mitad... La parte visible
  //Funciona por "bandas", cada banda representa una parte de la pantalla, por ejemplo en Gauntlet
  //cada banda tiene 8 pixles de alto, si la pantalla tiene 512 pixels --> 64 bandas
  //Cada banda tiene un indice en la memoria de SLIP, este indice le dice el primer objeto dentro de la
  //memoria de los sprites, despues el resto van encadenados
	for band:=0 to stopband do begin
		  // compute the starting link and clip for the current band
		  link:=0;
		  if (self.slipshift<>0) then begin
			  // extract the link from the SLIP RAM
        temp:=self.slipram;
        inc(temp,band and self.sliprammask);
			  link:=(temp^ shr self.linkmask.shift) and self.linkmask.mask;
      end;
		// if this matches the last link, we don't need to re-process the list
		build_active_list(link);
		// initialize the parameters
		self.next_xpos:=123456;
		// safety check
		if (@self.activelist[0]=self.activelast) then continue;
		// set the start and end points
		if self.config.reverse then begin
			first:=self.activelast;
      dec(first,4);
			last:=@self.activelist;
			step:=-4;
		end else begin
			first:=@self.activelist;
			last:=self.activelast;
      dec(last,4);
			step:=4;
		end;
		// render the mos
    current:=first;
		while (current<>last) do begin
			  render_object(current,xscroll,yscroll,prio);
        inc(current,step);
		end;
	end;
end;

procedure tatari_mo.render_object(entry:pword;xscroll,yscroll:word;prio:byte);
var
  priority,code,color,rawcode:word;
  xpos,ypos,xadv,yadv,sx,sy:integer;
  temp:pword;
  vflip,hflip:boolean;
  x,y,width,height:byte;
begin
  priority:=self.prioritymask.extract(entry);
  if priority<>prio then exit;
	// select the gfx element and save off key information
 	rawcode:=self.codemask.extract(entry);
	// extract data from the various words
  temp:=self.codelookup;
  inc(temp,rawcode);
	code:=temp^;
  temp:=self.colorlookup;
  inc(temp,self.colormask.extract(entry));
	color:=temp^ shl 4; //Aqui aumento el color!!!!!!
	xpos:=self.xposmask.extract(entry);
	ypos:=-self.yposmask.extract(entry);
	hflip:=self.hflipmask.extract(entry)<>0;
	vflip:=self.vflipmask.extract(entry)<>0;
	width:=self.widthmask.extract(entry)+1;
	height:=self.heightmask.extract(entry)+1;
	// compute the effective color, merging in priority
	color:=color+self.config.palettebase;
	// add in the scroll positions if we're not in absolute coordinates
	if (self.absolutemask.extract(entry)=0) then begin
		xpos:=xpos-xscroll;
		ypos:=ypos-yscroll;
	end;
	// adjust for height
	ypos:=ypos-(height shl self.tileyshift);
	// handle previous hold bits
	if (self.next_xpos<>123456) then xpos:=self.next_xpos;
	self.next_xpos:=123456;
	// check for the hold bit
	if (self.neighbormask.extract(entry)<>0) then begin
		if (not self.config.nextneighbor) then xpos:=self.last_xpos+self.tilewidth
		  else self.next_xpos:=xpos+self.tilewidth;
	end;
	self.last_xpos:=xpos;
	// adjust the final coordinates
	xpos:=xpos and self.bitmapxmask;
	ypos:=ypos and self.bitmapymask;
	// is this one special?
	if ((self.specialmask.mask=0) or (self.specialmask.extract(entry)<>self.config.specialvalue)) then begin
		// adjust for h flip
		xadv:=self.tilewidth;
		if hflip then begin
			xpos:=xpos+((width-1) shl self.tilexshift);
			xadv:=-xadv;
		end;
		// adjust for v flip
		yadv:=self.tileheight;
		if vflip then begin
			ypos:=ypos+((height-1) shl self.tileyshift);
			yadv:=-yadv;
		end;
		// standard order is: loop over Y first, then X
		if (not self.config.swapxy) then begin
			// loop over the height
      sy:=ypos;
			for y:=0 to (height-1) do begin
				// loop over the width
        sx:=xpos;
				for x:=0 to (width-1) do begin
          if (((sx<self.xmax) or (sx>503)) and ((sy<self.ymax) or (sy>503))) then begin
            put_gfx_sprite(code,color,hflip,vflip,self.config.gfxindex);
            actualiza_gfx_sprite(sx,sy,self.screen,self.config.gfxindex);
          end;
          sx:=sx+xadv;
          code:=code+1;
				end;
        sy:=sy+yadv;
			end;
		end	// alternative order is swapped
		  else begin
			// loop over the width
      sx:=xpos;
			for x:=0 to (width-1) do begin
				// loop over the height
        sy:=ypos;
				for y:=0 to (height-1) do begin
					// draw the sprite
          if (((sx<self.xmax) or (sx>503)) and ((sy<self.ymax) or (sy>503))) then begin
            put_gfx_sprite(code,color,hflip,vflip,self.config.gfxindex);
            actualiza_gfx_sprite(sx,sy,self.screen,self.config.gfxindex);
          end;
          sy:=sy+yadv;
          code:=code+1;
				end;
        sx:=sx+xadv;
			end;
    end;
  end;
end;

end.
