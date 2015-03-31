unit poke_spectrum;

interface
uses windows,sysutils,forms,main_engine;

type
  tipo_poke=record
    cantidad:byte;
    direccion:array[0..4] of word;
    valor:array[0..4] of byte;
    nombre_tipo:string;
  end;
  poke_rec=record
    nombre:string;
    crc:array[0..4] of dword;
    poke:array[0..9] of tipo_poke;
  end;
var
  BBDD_pokes:array[0..255] of poke_rec;

procedure iniciar_BBDD_poke;
procedure buscar_BBDD;

implementation
uses tap_tzx;

procedure buscar_BBDD;
var
  indice,posicion:word;
  f:byte;
begin
posicion:=0;
while BBDD_pokes[posicion].nombre<>'' do begin
  indice:=0;
  while cinta_tzx.datos_tzx[indice].tipo_bloque<>$fe do begin
   for f:=0 to 4 do begin
    if cinta_tzx.datos_tzx[indice].crc32=BBDD_pokes[posicion].crc[f] then begin
      //form1.label3.caption:=BBDD_pokes[posicion].nombre;
    end;
   end;
  inc(indice);
  end;
  inc(posicion);
end;
end;

procedure iniciar_BBDD_poke;
var
  fichero:textfile;
  cadena,cadena2:string;
  posicion:word;
  ncrc,cantidad,f:byte;
  poke_num:byte;
begin
{$I-}
assignfile(fichero,extractfiledir(application.ExeName)+main_vars.cadena_dir+'database.pok');
reset(fichero);
posicion:=0;
poke_num:=0;
while not(eof(fichero)) do begin
  readln(fichero,cadena);
  cadena2:=copy(cadena,1,2);
  if cadena2='//' then ;
  if cadena2='GN' then BBDD_pokes[posicion].nombre:=copy(cadena,4,length(cadena)-3);
  if cadena2='GC' then begin
    ncrc:=strtoint(copy(cadena,3,1));
    BBDD_pokes[posicion].crc[ncrc]:=strtoint('$'+copy(cadena,5,length(cadena)-4));
  end;
  if cadena2='PT' then BBDD_pokes[posicion].poke[poke_num].nombre_tipo:=copy(cadena,4,length(cadena)-3);
  if cadena2='PQ' then begin
    cantidad:=strtoint(copy(cadena,4,1));
    BBDD_pokes[posicion].poke[poke_num].cantidad:=cantidad;
    for f:=1 to cantidad do begin
      //Poke datos
      readln(fichero,cadena);
      cadena2:=copy(cadena,1,2);
      if cadena2='PD' then BBDD_pokes[posicion].poke[poke_num].direccion[f-1]:=strtoint(copy(cadena,4,length(cadena)-3));
      //Poke valor
      readln(fichero,cadena);
      cadena2:=copy(cadena,1,2);
      if cadena2='PV' then BBDD_pokes[posicion].poke[poke_num].valor[f-1]:=strtoint(copy(cadena,4,length(cadena)-3));
    end;
    inc(poke_num);
  end;
  if cadena2='EP' then begin
    inc(posicion);
    poke_num:=0;
  end;
end;
{$I+}
end;

end.
