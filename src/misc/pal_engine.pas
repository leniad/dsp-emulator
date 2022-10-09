unit pal_engine;

interface
uses {$IFDEF windows}windows,{$ENDIF}lib_sdl2;

const
    MAX_NETS=3;
    MAX_RES_PER_NET=18;
    SET_TRANS_COLOR=$69; //:-)
    MAX_COLORES=$8000;
type
  tcolor=record
                r,g,b:byte;
                a:byte;
         end;
  tpaleta=array[0..max_colores] of tcolor;
var
  paleta,buffer_paleta:array[0..MAX_COLORES] of word;
  paleta32,paleta_alpha:array[0..MAX_COLORES] of dword;
  buffer_color:array[0..MAX_COLORES] of boolean;

procedure compute_resistor_weights(
	minval,maxval:integer;scaler:single;
	count_1:integer;resistances_1:pinteger;weights_1:psingle;pulldown_1,pullup_1:integer;
	count_2:integer;resistances_2:pinteger;weights_2:psingle;pulldown_2,pullup_2:integer;
	count_3:integer;resistances_3:pinteger;weights_3:psingle;pulldown_3,pullup_3:integer);
function combine_2_weights(tab:psingle;w0,w1:integer):integer;
function combine_3_weights(tab:psingle;w0,w1,w2:integer):integer;
function combine_4_weights(tab:psingle;w0,w1,w2,w3:integer):integer;
function combine_6_weights(tab:psingle;w0,w1,w2,w3,w4,w5:integer):integer;
function pal1bit(bits:byte):byte;
function pal2bit(bits:byte):byte;
function pal3bit(bits:byte):byte;
function pal4bit(bits:byte):byte;
function pal4bit_i(bits,i:byte):byte;
function pal5bit(bits:byte):byte;
function pal6bit(bits:byte):byte;
//Palette functions
procedure set_pal(ppaleta:tpaleta;total_colors:word);
procedure set_pal_color(pcolor:tcolor;pal_pos:word);
procedure set_pal_color_alpha(pcolor:tcolor;pal_pos:word);
function convert_pal_color(pcolor:tcolor):word;

implementation
uses main_engine;

procedure compute_resistor_weights(
	minval,maxval:integer;scaler:single;
	count_1:integer;resistances_1:pinteger;weights_1:psingle;pulldown_1,pullup_1:integer;
	count_2:integer;resistances_2:pinteger;weights_2:psingle;pulldown_2,pullup_2:integer;
	count_3:integer;resistances_3:pinteger;weights_3:psingle;pulldown_3,pullup_3:integer);
var
	networks_no:integer;
	rescount:array[0..(MAX_NETS-1)] of integer;		// number of resistors in each of the nets */
	r:array[0..(MAX_NETS-1),0..(MAX_RES_PER_NET-1)] of single;		// resistances */
	w:array[0..(MAX_NETS-1),0..(MAX_RES_PER_NET-1)] of single;		// calulated weights */
	ws:array[0..(MAX_NETS-1),0..(MAX_RES_PER_NET-1)] of single;	// calulated, scaled weights */
	r_pd:array[0..(MAX_NETS-1)] of integer;			// pulldown resistances */
	r_pu:array[0..(MAX_NETS-1)] of integer;			// pullup resistances */

	max_out:array[0..(MAX_NETS-1)] of single;
	out_:array[0..(MAX_NETS-1)] of psingle;

	i,j,n:integer;
	scale:single;
	max:single;
  count, pd, pu:integer;
	resistances,ptemp:pinteger;
	weights:psingle;
  R0,R1,Vout,dst,sum:single;
  out2_:psingle;
begin
	// parse input parameters */
	networks_no:=0;
	for n:=0 to (MAX_NETS-1) do begin
		case n of
		  0:begin
				  count:=count_1;
				  resistances:=resistances_1;
				  weights:=weights_1;
				  pd:=pulldown_1;
				  pu:=pullup_1;
				end;
		  1:begin
				  count:=count_2;
				  resistances:=resistances_2;
				  weights:=weights_2;
				  pd:=pulldown_2;
				  pu:=pullup_2;
				end;
		  else begin
				  count:=count_3;
				  resistances:=resistances_3;
				  weights:=weights_3;
				  pd:=pulldown_3;
				  pu:=pullup_3;
        end;
		end;
		// parameters validity check */
	{	if (count>MAX_RES_PER_NET) then
			fatalerror("compute_resistor_weights(): too many resistors in net #%i. The maximum allowed is %i, the number requested was: %i\n",n, MAX_RES_PER_NET, count);
   }

    rescount[networks_no]:=count;
		if (count > 0) then begin
			for i:=0 to (count-1) do begin
        ptemp:=resistances;
        inc(ptemp,i);
				r[networks_no,i]:=1.0*ptemp^;
			end;
			out_[networks_no]:=weights;
			r_pd[networks_no]:=pd;
			r_pu[networks_no]:=pu;
			inc(networks_no);
		end;
	end;
 {	if (networks_no<1)
		fatalerror("compute_resistor_weights(): no input data\n");
  }
	// calculate outputs for all given networks */
	for i:=0 to (networks_no-1) do begin
		// of n resistors */
		for n:=0 to (rescount[i]-1) do begin
      if (r_pd[i]=0) then R0:=1.0/1e12
        else R0:=1.0/r_pd[i];
      if (r_pu[i]=0) then R1:=1.0/1e12
        else R1:=1.0/r_pu[i];
			for j:=0 to (rescount[i]-1) do begin
				if (j=n) then begin	// only one resistance in the network connected to Vcc */
					if (r[i,j]<>0.0) then R1:=R1+(1.0/r[i,j]);
				end else begin
					if (r[i,j]<>0.0) then R0:=R0+(1.0/r[i,j]);
        end;
			end;

			// now determine the voltage */
			R0:=1.0/R0;
			R1:=1.0/R1;
			Vout:=(maxval-minval)*R0/(R1+R0)+minval;

			// and convert it to a destination value */
      if (Vout<minval) then begin
        dst:=minval
      end else begin
        if (Vout > maxval) then dst:=maxval
          else dst:=Vout;
      end;
			w[i,n]:=dst;
    end;
	 end;

	// calculate maximum outputs for all given networks
	j:=0;
	max:=0.0;
	for i:=0 to (networks_no-1) do begin
		sum:=0.0;
		// of n resistors */
		for n:=0 to (rescount[i]-1) do
			sum:=sum+w[i,n];	// maximum output, ie when each resistance is connected to Vcc */
		max_out[i]:=sum;
		if (max<sum) then begin
			max:=sum;
			j:=i;
		end;
	end;
	if (scaler<0.0)	then // use autoscale ? */
		// calculate the output scaler according to the network with the greatest output */
		scale:=maxval/max_out[j]
	else				// use scaler provided on entry */
		scale:=scaler;

	// calculate scaled output and fill the output table(s)*/
	for i:=0 to (networks_no-1) do begin
		for n:=0 to (rescount[i]-1) do begin
			ws[i,n]:=w[i,n]*scale;	// scale the result */
      out2_:=out_[i];
      inc(out2_,n);
			out2_^:=ws[i,n];		// fill the output table */
		end;
	end;
end;

function combine_2_weights(tab:psingle;w0,w1:integer):integer;inline;
var
  res:single;
  ptemp:psingle;
begin
  ptemp:=tab;
  res:=ptemp^*w0;
  inc(ptemp);
  res:=res+ptemp^*w1+0.5;
  if res>255 then res:=255;
  combine_2_weights:=trunc(res);
end;

function combine_3_weights(tab:psingle;w0,w1,w2:integer):integer;inline;
var
  res:single;
  ptemp:psingle;
begin
  ptemp:=tab;
  res:=ptemp^*w0;
  inc(ptemp);
  res:=res+ptemp^*w1;
  inc(ptemp);
  res:=res+ptemp^*w2+0.5;
  if res>255 then res:=255;
  combine_3_weights:=trunc(res);
end;

function combine_4_weights(tab:psingle;w0,w1,w2,w3:integer):integer;inline;
var
  res:single;
  ptemp:psingle;
begin
  ptemp:=tab;
  res:=ptemp^*w0;
  inc(ptemp);
  res:=res+ptemp^*w1;
  inc(ptemp);
  res:=res+ptemp^*w2;
  inc(ptemp);
  res:=(res+ptemp^*w3)+0.5;
  if res>255 then res:=255;
  combine_4_weights:=trunc(res);
end;

function combine_6_weights(tab:psingle;w0,w1,w2,w3,w4,w5:integer):integer;inline;
var
  res:single;
  ptemp:psingle;
begin
  ptemp:=tab;
  res:=ptemp^*w0;
  inc(ptemp);
  res:=res+ptemp^*w1;
  inc(ptemp);
  res:=res+ptemp^*w2;
  inc(ptemp);
  res:=res+ptemp^*w3;
  inc(ptemp);
  res:=res+ptemp^*w4;
  inc(ptemp);
  res:=(res+ptemp^*w5)+0.5;
  if res>255 then res:=255;
  combine_6_weights:=trunc(res);
end;

function pal1bit(bits:byte):byte;inline;
begin
  if (bits and 1)<>0 then pal1bit:=$ff
    else pal1bit:=0;
end;

function pal2bit(bits:byte):byte;inline;
begin
	bits:=bits and 3;
	pal2bit:=(bits shl 6) or (bits shl 4) or (bits shl 2) or bits;
end;

function pal3bit(bits:byte):byte;inline;
begin
	bits:=bits and 7;
	pal3bit:=(bits shl 5) or (bits shl 2) or (bits shr 1);
end;

function pal4bit(bits:byte):byte;inline;
begin
	bits:=bits and $f;
	pal4bit:=(bits shl 4) or bits;
end;

function pal4bit_i(bits,i:byte):byte;
const
  ztable:array[0..15] of byte=($0,$3,$4,$5,$6,$7,$8,$9,$a,$b,$c,$d,$e,$f,$10,$11);
begin
	pal4bit_i:=(bits and $f)*ztable[i];
end;

function pal5bit(bits:byte):byte;inline;
begin
	bits:=bits and $1f;
	pal5bit:=(bits shl 3) or (bits shr 2);
end;

function pal6bit(bits:byte):byte;
begin
  bits:=bits and $3f;
  pal6bit:=(bits shl 2) or (bits shr 4);
end;

//Palette functions
procedure set_pal(ppaleta:tpaleta;total_colors:word);inline;
var
  colors:word;
begin
for colors:=0 to total_colors-1 do
        paleta[colors]:=SDL_MapRGB(pantalla[PANT_SPRITES].format, ppaleta[colors].r, ppaleta[colors].g, ppaleta[colors].b);
end;

procedure set_pal_color(pcolor:tcolor;pal_pos:word);inline;
begin
paleta[pal_pos]:=SDL_MapRGB(pantalla[PANT_SPRITES].format, pcolor.r, pcolor.g, pcolor.b);
end;

function convert_pal_color(pcolor:tcolor):word;inline;
begin
convert_pal_color:=SDL_MapRGB(pantalla[PANT_SPRITES].format, pcolor.r, pcolor.g, pcolor.b);
end;

procedure set_pal_color_alpha(pcolor:tcolor;pal_pos:word);inline;
begin
paleta[pal_pos]:=SDL_MapRGB(pantalla[PANT_SPRITES].format, pcolor.r, pcolor.g, pcolor.b);
paleta32[pal_pos]:=SDL_MapRGBA(pantalla[PANT_SPRITES_ALPHA].format, pcolor.r, pcolor.g, pcolor.b,$ff);
paleta_alpha[pal_pos]:=SDL_MapRGBA(pantalla[PANT_SPRITES_ALPHA].format, pcolor.r, pcolor.g, pcolor.b,$80);
end;

end.
