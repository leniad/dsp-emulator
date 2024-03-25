unit avg_dvg;

interface
uses main_engine,gfx_engine,timer_engine;

const
  MAXVECT=10000;
type
  	tvgvector=record
		  x,y:integer;
		  color:word;
		  intensity:integer;
		  arg1,arg2:integer;
		  status:integer;
    end;
  avgdvg_chip=class
        constructor create(cpu_n,screen:byte;membase:word;x_desp:word);
        destructor free;
      public
        procedure run;
        procedure reset;
        procedure go_w;
        function get_prom_data:pbyte;
        function done_r:byte;
      private
        state_latch,op,halt,sp,scale,intensity,sync_halt:byte;
        membase,data,pc,dvy,dvx,xcenter,ycenter,xmin,ymin,nvect:word;
        prom:array[0..$ff] of byte;
        stack:array[0..3] of word;
        xpos,ypos:integer;
        vectbuf:array[0..(MAXVECT-1)] of tvgvector;
        flip_x,flip_y:boolean;
        x_desp:word;
        screen:byte;
        function dvg_state_addr:byte;
        function dvg_handler_0:byte;
        function dvg_handler_1:byte;
        function dvg_handler_2:byte;
        function dvg_handler_3:byte;
        function dvg_handler_4:byte;
        function dvg_handler_5:byte;
        function dvg_handler_6:byte;
        function dvg_handler_7:byte;
        procedure dvg_update_databus;
        procedure apply_flipping(var x,y:integer);
        procedure dvg_draw_to(x,y,intensity:integer);
        procedure vg_add_point_buf(x,y,color,intensity:integer);
        procedure vg_flush;
  end;

var
  avgdvg_0:avgdvg_chip;
  timer_hs,timer_run:byte;

implementation
const
  VGSLICE=10000;
  VGVECTOR=0;
  VGCLIP=1;

procedure halt_sync_clear;
begin
  avgdvg_0.sync_halt:=0;
  timers.enabled(timer_hs,false);
end;

procedure run_vector;
begin
  timers.enabled(timer_run,false);
  avgdvg_0.run;
end;

constructor avgdvg_chip.create(cpu_n,screen:byte;membase:word;x_desp:word);
begin
  self.membase:=membase;
  self.xcenter:=512;
  self.ycenter:=512;
  self.xmin:=0;
  self.ymin:=0;
  timer_hs:=timers.init(cpu_n,1,halt_sync_clear,nil,false);
  timer_run:=timers.init(cpu_n,1,run_vector,nil,false);
  self.screen:=screen;
  self.x_desp:=x_desp;
end;

destructor avgdvg_chip.free;
begin
end;

procedure avgdvg_chip.reset;
begin
  self.state_latch:=0;
  self.op:=0;
  self.halt:=0;
  self.pc:=0;
  self.data:=0;
  self.sp:=0;
  self.stack[0]:=0;
  self.stack[1]:=0;
  self.stack[2]:=0;
  self.stack[3]:=0;
  self.dvy:=0;
  self.dvx:=0;
  self.scale:=0;
  self.xpos:=0;
  self.ypos:=0;
  self.flip_x:=false;
  self.flip_y:=false;
  self.sync_halt:=0;
end;

function avgdvg_chip.get_prom_data:pbyte;
begin
  get_prom_data:=@self.prom[0];
end;

function avgdvg_chip.dvg_state_addr:byte;
var
  addr:byte;
begin
		addr:=((((self.state_latch shr 4) xor 1) and 1) shl 7) or (self.state_latch and $f);
	  if ((self.op and 8)<>0) then addr:=addr or ((self.op and 7) shl 4);
    dvg_state_addr:=addr;
end;

function avgdvg_chip.dvg_handler_0:byte; //dvg_dmapush
begin
  if ((self.op and 1)=0) then begin
		self.sp:=(self.sp+1) and $f;
		self.stack[self.sp and 3]:=self.pc;
	end;
	dvg_handler_0:=0;
end;

function avgdvg_chip.dvg_handler_1:byte;  //dvg_dmald
begin
  if ((self.op and 1)<>0) then begin
		self.pc:=self.stack[self.sp and 3];
		self.sp:=(self.sp-1) and $f;
	end else begin
		self.pc:=self.dvy;
	end;
	dvg_handler_1:=0;
end;

procedure avgdvg_chip.vg_add_point_buf(x,y,color,intensity:integer);
begin
	if (self.nvect<MAXVECT) then begin
		self.vectbuf[self.nvect].status:=VGVECTOR;
		self.vectbuf[self.nvect].x:=x;
		self.vectbuf[self.nvect].y:=y;
		self.vectbuf[self.nvect].color:=color;
		self.vectbuf[self.nvect].intensity:=intensity;
		self.nvect:=self.nvect+1;
	end;
end;

procedure avgdvg_chip.apply_flipping(var x,y:integer);
begin
	if (self.flip_x) then x:=x+(self.xcenter-x) shl 1;
	if (self.flip_y) then y:=y+(self.ycenter-y) shl 1;
end;

procedure avgdvg_chip.dvg_draw_to(x,y,intensity:integer);
begin
  self.apply_flipping(x,y);
	if (((x or y) and $400)=0) then
		vg_add_point_buf(self.xmin+x,self.ymin+y,7,intensity);
end;

function avgdvg_chip.dvg_handler_2:byte; //dvg_gostrobe
var
  scale,fin,dx,dy:integer;
  cycles,c,mx,my:word;
  bit:byte;
  countx,county:boolean;
begin
	if (self.op=$f) then begin
		scale:=(self.scale+(((self.dvy and $800) shr 11) or (((self.dvx and $800) xor $800) shr 10) or ((self.dvx and $800) shr 9))) and $f;
		self.dvy:=self.dvy and $f00;
		self.dvx:=self.dvx and $f00;
	end else begin
		scale:=(self.scale+self.op) and $f;
	end;
	fin:=$fff-(((2 shl scale) and $7ff) xor $fff);
	// Count up or down
  if (self.dvx and $400)<>0 then dx:=-1
    else dx:=1;
  if (self.dvy and $400)<>0 then dy:=-1
    else dy:=1;
	// Scale factor for rate multipliers
	mx:=(self.dvx shl 2) and $fff;
	my:=(self.dvy shl 2) and $fff;
	cycles:=8*fin;
	c:=0;
	while (fin<>0) do begin
		 {  The 7497 Bit Rate Multiplier is a 6 bit counter with
		 *  clever decoding of output bits to perform the following
		 *  operation:
		 *  fout = m/64 * fin
		 *  where fin is the input frequency, fout is the output
		 *  frequency and m is a factor at the input pins. Output
		 *  pulses are more or less evenly spaced so we get straight
		 *  lines. The DVG has two cascaded 7497s for each coordinate.}
		countx:=false;
		county:=false;
		for bit:=0 to 11 do begin
			if ((c and ((1 shl (bit+1))-1))=((1 shl bit)-1)) then begin
				countx:=(mx and (1 shl (11-bit)))<>0;
				county:=(my and (1 shl (11-bit)))<>0;
			end;
    end;
		c:=(c+1) and $fff;
		 {  Since x- and y-counters always hold the correct count
		 *  wrt. to each other, we can do clipping exactly like the
		 *  hardware does. That is, as soon as any counter's bit 10
		 *  changes to high, we finish the vector. If bit 10 changes
		 *  from high to low, we start a new vector.}
		if countx then begin
			// Is y valid and x entering or leaving the valid range?
			if (((self.ypos and $400)=0) and (((self.xpos xor (self.xpos+dx)) and $400)<>0)) then begin
				if ((self.xpos+dx) and $400)<>0 then // We are leaving the valid range
					dvg_draw_to(self.xpos,self.ypos,self.intensity)
				else                        // We are entering the valid range
					dvg_draw_to((self.xpos+dx) and $fff,self.ypos,0);
			end;
			self.xpos:=(self.xpos+dx) and $fff;
		end;
		if county then begin
			if (((self.xpos and $400)=0) and (((self.ypos xor (self.ypos+dy)) and $400)<>0)) then begin
				if ((self.xpos and $400)=0) then begin
					if ((self.ypos+dy) and $400)<>0 then dvg_draw_to(self.xpos,self.ypos,self.intensity)
					else dvg_draw_to(self.xpos,(self.ypos+dy) and $fff,0);
				end;
			end;
			self.ypos:=(self.ypos+dy) and $fff;
		end;
    fin:=fin-1;
	end;
	dvg_draw_to(self.xpos,self.ypos,self.intensity);
	dvg_handler_2:=cycles;
end;

function avgdvg_chip.dvg_handler_3:byte; //dvg_haltstrobe
begin
  self.halt:=self.op and 1;
	if (self.op and 1)=0 then begin
		self.xpos:=self.dvx and $fff;
		self.ypos:=self.dvy and $fff;
		dvg_draw_to(self.xpos,self.ypos,0);
	end;
	dvg_handler_3:=0;
end;

function avgdvg_chip.dvg_handler_4:byte; //dvg_latch0
begin
  self.dvy:=self.dvy and $f00;
	if (self.op=$f) then self.dvg_handler_7 //dvg_latch3
	  else self.dvy:=(self.dvy and $f00) or self.data;
	self.pc:=self.pc+1;
	dvg_handler_4:=0;
end;

function avgdvg_chip.dvg_handler_5:byte; //dvg_latch1
begin
  self.dvy:=(self.dvy and $ff) or ((self.data and $f) shl 8);
	self.op:=self.data shr 4;
	if (self.op=$f) then begin
		self.dvx:=self.dvx and $f00;
		self.dvy:=self.dvy and $f00;
	end;
	dvg_handler_5:=0;
end;

function avgdvg_chip.dvg_handler_6:byte; //dvg_latch2
begin
  self.dvx:=self.dvx and $f00;
	if (self.op<>$f) then self.dvx:=(self.dvx and $f00) or self.data;
	if (((self.op and 2)<>0) and ((self.op and 8)<>0)) then self.scale:=self.intensity;
	self.pc:=self.pc+1;
	dvg_handler_6:=0;
end;

function avgdvg_chip.dvg_handler_7:byte; //dvg_latch3
begin
  self.dvx:=(self.dvx and $ff) or ((self.data and $f) shl 8);
	self.intensity:=self.data shr 4;
	dvg_handler_7:=0;
end;

procedure avgdvg_chip.dvg_update_databus;
begin
  self.data:=memoria[self.membase+(self.pc shl 1)+(self.state_latch and 1)];
end;

procedure avgdvg_chip.run;
var
  cycles:word;
begin
  cycles:=0;
	while (cycles<VGSLICE) do begin
		// Get next state
		self.state_latch:=(self.state_latch and $10) or (self.prom[self.dvg_state_addr] and $f);
		if ((self.state_latch and 8)<>0) then begin
			// Read vector RAM/ROM
			self.dvg_update_databus;
			// Decode state and call the corresponding handler
			case (self.state_latch and 7) of
			  0:cycles:=cycles+self.dvg_handler_0;
			  1:cycles:=cycles+self.dvg_handler_1;
			  2:cycles:=cycles+self.dvg_handler_2;
			  3:cycles:=cycles+self.dvg_handler_3;
			  4:cycles:=cycles+self.dvg_handler_4;
			  5:cycles:=cycles+self.dvg_handler_5;
			  6:cycles:=cycles+self.dvg_handler_6;
			  7:cycles:=cycles+self.dvg_handler_7;
      end;
		end;
		if ((self.halt<>0) and ((self.state_latch and $10)=0)) then begin
        timers.timer[timer_hs].time_final:=cycles;
        timers.enabled(timer_hs,true);
        self.sync_halt:=1;
    end;
		self.state_latch:=(self.halt shl 4) or (self.state_latch and $f);
		cycles:=cycles+8;
	end;
  //Me espero a que ejecute este set de vectores y sigo...
  timers.timer[timer_run].time_final:=cycles;
  timers.enabled(timer_run,true);
end;

procedure avgdvg_chip.go_w;
begin
  self.dvy:=0;
  self.op:=0;
	if ((self.sync_halt<>0) and (self.nvect>10)) then begin
		 {* This is a good time to start a new frame. Major Havoc
		 * sometimes sets VGGO after a very short vector list. That's
		 * why we ignore frames with less than 10 vectors.}
		  self.nvect:=0;
  end;
	self.vg_flush;
  self.halt:=0;
  self.sync_halt:=0;
  self.run;
end;

function avgdvg_chip.done_r:byte;
begin
  done_r:=self.sync_halt;
end;

procedure avgdvg_chip.vg_flush;
var
  cx0,cy0,cx1,cy1,xs,ys,f,xe,ye,x0,y0,x1,y1:integer;
begin
  fill_full_screen(self.screen,$400);
	cx0:=0;
  cy0:=0;
  cx1:=$500;
  cy1:=$500;
	f:=0;
	while (self.vectbuf[f].status=VGCLIP) do f:=f+1;
	xs:=self.vectbuf[f].x;
	ys:=self.vectbuf[f].y;
  for f:=0 to self.nvect do begin
		if (self.vectbuf[f].status=VGVECTOR) then begin
			xe:=self.vectbuf[f].x;
			ye:=self.vectbuf[f].y;
			x0:=xs;
      y0:=ys;
      x1:=xe;
      y1:=ye;
			xs:=xe;
			ys:=ye;
			if (((x0<cx0) and (x1<cx0)) or ((x0>cx1) and (x1>cx1))) then continue;
			if (x0<cx0) then begin
				y0:=y0+(integer(cx0-x0)*integer(y1-y0) div (x1-x0));
				x0:=cx0;
			end else if (x0>cx1) then begin
				          y0:=y0+(integer(cx1-x0)*integer(y1-y0) div (x1-x0));
				          x0:=cx1;
               end;
			if (x1<cx0) then begin
				y1:=y1+(integer(cx0-x1)*integer(y1-y0) div (x1-x0));
				x1:=cx0;
			end else if (x1>cx1) then begin
				          y1:=y1+(integer(cx1-x1)*integer(y1-y0) div (x1-x0));
				          x1:=cx1;
      end;
			if (((y0<cy0) and (y1<cy0)) or ((y0>cy1) and (y1>cy1))) then continue;
			if (y0<cy0) then begin
				x0:=x0+(integer(cy0-y0)*integer(x1-x0) div (y1-y0));
				y0:=cy0;
			end else if (y0>cy1) then begin
				          x0:=x0+(integer(cy1-y0)*integer(x1-x0) div (y1-y0));
				          y0:=cy1;
              end;
			if (y1<cy0) then begin
				x1:=x1+(integer(cy0-y1)*integer(x1-x0) div (y1-y0));
				y1:=cy0;
			end else if (y1>cy1) then begin
				          x1:=x1+(integer(cy1-y1)*integer(x1-x0) div (y1-y0));
				          y1:=cy1;
			         end;
      if x0>1024 then x0:=400
        else if x0<0 then x0:=0
          else x0:=trunc((x0+0)/2.56);
      if x1>1024 then x1:=400
        else if x1<0 then x1:=0
          else x1:=trunc((x1+0)/2.56);
      if y0>1024 then y0:=400
        else if y0<0 then y0:=0
          else y0:=trunc((1024-y0)/2.56);
      if y1>1024 then y1:=0
        else if y1<0 then y1:=400
          else y1:=trunc((1024-y1)/2.56);
      if self.vectbuf[f].intensity<>0 then draw_line(x0+ADD_SPRITE,y0+ADD_SPRITE,x1+ADD_SPRITE,y1+ADD_SPRITE,self.vectbuf[f].intensity,self.screen);
			//m_vector->add_point(x0, y0, m_vectbuf[i].color, 0);
			//m_vector->add_point(x1, y1, m_vectbuf[i].color, m_vectbuf[i].intensity);
		end;
    if (self.vectbuf[f].status=VGCLIP) then;
		{
			cx0 = m_vectbuf[i].x;
			cy0 = m_vectbuf[i].y;
			cx1 = m_vectbuf[i].arg1;
			cy1 = m_vectbuf[i].arg2;
			using std::swap;
			if (cx0 > cx1)
				swap(cx0, cx1);
			if (cy0 > cy1)
				swap(cy0, cy1);
		}
  end;
  self.nvect:=0;
  actualiza_trozo_final(0,self.x_desp,400,320,self.screen);
end;

end.
