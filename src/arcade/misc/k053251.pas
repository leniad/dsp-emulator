unit k053251;

interface
const
    K053251_CI0=0;
		K053251_CI1=1;
		K053251_CI2=2;
		K053251_CI3=3;
		K053251_CI4=4;

procedure k053251_reset;
procedure k053251_lsb_w(direccion,valor:word);
function k053251_get_priority(ci:byte):byte;
function k053251_get_palette_index(ci:byte):byte;

implementation
var
  tilemaps_set:byte;
  k053251_ram:array[0..$f] of byte;
  dirty_tmap:array[0..4] of boolean;
  palette_index:array[0..4] of byte;

procedure reset_indexes;
begin
	palette_index[0]:=32*((k053251_ram[9] shr 0) and 3);
	palette_index[1]:=32*((k053251_ram[9] shr 2) and 3);
	palette_index[2]:=32*((k053251_ram[9] shr 4) and 3);
	palette_index[3]:=16*((k053251_ram[10] shr 0) and 7);
	palette_index[4]:=16*((k053251_ram[10] shr 3) and 7);
end;

procedure k053251_reset;
var
  f:byte;
begin
	tilemaps_set:=0;
	for f:=0 to $f do k053251_ram[f]:=0;
	for f:=0 to 4 do dirty_tmap[f]:=false;
	reset_indexes();
end;

procedure write(direccion:word;valor:byte);
var
  i,newind:byte;
begin
	valor:=valor and $3f;
	if (k053251_ram[direccion]<>valor) then begin
		k053251_ram[direccion]:=valor;
    case direccion of
      9:begin // palette base index */
          for i:=0 to 2 do begin
				    newind:=32*((valor shr (2*i)) and 3);
				    if (palette_index[i]<>newind) then begin
					    palette_index[i]:=newind;
					    dirty_tmap[i]:=true;
				    end;
			    end;
          //if (!m_tilemaps_set) then space.machine().tilemap().mark_all_dirty();
      end;
      10:begin // palette base index */
          for i:=0 to 1 do begin
				    newind:=16*((valor shr (3*i)) and 7);
				    if (palette_index[3+i]<>newind) then begin
					    palette_index[3+i]:=newind;
					    dirty_tmap[3+i]:=true;
				    end;
			    end;
			    //if (!m_tilemaps_set) then space.machine().tilemap().mark_all_dirty();
         end;
    end;
	end;
end;

procedure k053251_lsb_w(direccion,valor:word);
begin
	write(direccion,valor and $ff);
end;

function k053251_get_priority(ci:byte):byte;
begin
	k053251_get_priority:=k053251_ram[ci];
end;

function k053251_get_palette_index(ci:byte):byte;
begin
	k053251_get_palette_index:=palette_index[ci];
end;

end.
