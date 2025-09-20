unit galaxian_stars;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}main_engine,gfx_engine,pal_engine,timer_engine;

const
  GALAXIANS=0;
  SCRAMBLE=1;
  STAR_COUNT=252;

type
  tstars=record
            x,y,color:word;
         end;
  gal_stars=class
        constructor create(num_cpu:byte;clock:dword;tipo:byte);
        destructor free;
    public
          procedure enable_w(ena:boolean);
          procedure reset;
          procedure create_pal(desp:word);
    private
          stars:array[0..(STAR_COUNT-1)] of tstars;
          scrollpos:dword;
          blinking:byte;
          enable:boolean;
  end;

procedure stars_galaxian(screen:byte);
procedure stars_scramble(screen:byte);

var
  galaxian_stars_0:gal_stars;

implementation

procedure stars_advance;
begin
  galaxian_stars_0.blinking:=galaxian_stars_0.blinking+1;
  galaxian_stars_0.scrollpos:=galaxian_stars_0.scrollpos+1;
end;

constructor gal_stars.create(num_cpu:byte;clock:dword;tipo:byte);
begin
case tipo of
  GALAXIANS:timers.init(num_cpu,clock/30,stars_advance,nil,true);
  SCRAMBLE:timers.init(num_cpu,clock*(0.693*(100000+2*10000)*0.00001),stars_advance,nil,true);
end;
end;

destructor gal_stars.free;
begin
end;

procedure stars_galaxian(screen:byte);
var
  f:byte;
  x,y,color:word;
begin
if not(galaxian_stars_0.enable) then exit;
for f:=0 to STAR_COUNT-1 do begin
		x:=(galaxian_stars_0.stars[f].x+galaxian_stars_0.scrollpos) and $1ff;
    //JumpBug no stars in the status area
		if ((x>=240) and (main_vars.tipo_maquina=48)) then continue;
		y:=(galaxian_stars_0.stars[f].y+((galaxian_stars_0.scrollpos+galaxian_stars_0.stars[f].x) shr 9)) and $ff;
		if ((y and 1) xor ((x shr 3) and 1))<>0 then begin
      color:=paleta[galaxian_stars_0.stars[f].color];
      putpixel(y+ADD_SPRITE,x,1,@color,screen);
		end;
 end;
end;

procedure stars_scramble(screen:byte);
var
  f:byte;
  x,y,color:word;
begin
if not(galaxian_stars_0.enable) then exit;
for f:=0 to STAR_COUNT-1 do begin
		x:=galaxian_stars_0.stars[f].x;
		y:=galaxian_stars_0.stars[f].y;
		// determine when to skip plotting
		if ((y and 1) xor ((x shr 3) and 1))<>0 then begin
			case (galaxian_stars_0.blinking and 3) of
  			0:if (galaxian_stars_0.stars[f].color and 1)=0 then continue;
  			1:if (galaxian_stars_0.stars[f].color and 4)=0 then continue;
  			2:if (galaxian_stars_0.stars[f].y and 2)=0 then continue;
			end;
      color:=paleta[galaxian_stars_0.stars[f].color];
      putpixel(y+ADD_SPRITE,x,1,@color,screen);
		end;
end;
end;

procedure gal_stars.enable_w(ena:boolean);
begin
self.enable:=ena;
if not(self.enable) then self.scrollpos:=0;
end;

procedure gal_stars.create_pal(desp:word);
const
  map:array[0..3] of byte =($00,$88,$cc,$ff);
var
  color:tcolor;
  f,tempb,y,total_stars:byte;
  x:word;
  generator,generator2:dword;
begin
for f:=0 to 63 do begin
  tempb:=(f shr 0) and 3;
  color.r:=map[tempb];
  tempb:=(f shr 2) and 3;
  color.g:=map[tempb];
  tempb:=(f shr 4) and 3;
  color.b:=map[tempb];
  set_pal_color(color,f+desp);
end;
total_stars:=0;
generator:=0;
for y:=0 to 255 do begin
		for x:=0 to 511 do begin
			generator2:=((not(generator) shr 16) and 1) xor ((generator shr 4) and 1);
			generator:=(generator shl 1) or generator2;
			if ((((not(generator) shr 16) and 1)<>0) and ((generator and $ff)=$ff)) then begin
				tempb:=(not(generator shr 8)) and $3f;
				if (tempb<>0) then begin
					self.stars[total_stars].x:=x;
					self.stars[total_stars].y:=y;
					self.stars[total_stars].color:=tempb+desp;
					total_stars:=total_stars+1;
				end;
      end;
		end;
end;
end;

procedure gal_stars.reset;
begin
self.blinking:=0;
self.scrollpos:=0;
self.enable:=false;
end;

end.
