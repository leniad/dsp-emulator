unit spectrum_load;

interface
uses {$ifdef windows}windows,{$endif}
     Dialogs,main_engine,spectrum_48k,misc_functions,init_games,file_engine,principal,
     lenguaje,spectrum_misc,tap_tzx,snapshot,tape_window,cargar_spec,sysutils;

type
  tload_rom=record
    datos_rom:pbyte;
    hay_rom:boolean;
    rom_size:word;
    nombre_rom:string;
  end;

var
  spec_rom:tload_rom;
  ultima_posicion:integer=0;
  datos:pbyte;
  nombre,extension:string;
  file_size:integer;

procedure spectrum_load_init;
procedure spectrum_load_click;
procedure spectrum_load_exit;
procedure spectrum_load_close;

implementation

procedure spectrum_load_init;
begin
form2.Button2.Caption:=leng[main_vars.idioma].mensajes[7];
form2.Button1.Caption:=leng[main_vars.idioma].mensajes[8];
form2.FileListBox1.Mask:='*.zip;*.sp;*.zx;*.sna;*.z80;*.tzx;*.tap;*.csw;*.dsp;*.wav;*.szx;*.pzx';
if ((main_vars.tipo_maquina=0) or (main_vars.tipo_maquina=5)) then form2.FileListBox1.Mask:=form2.FileListBox1.Mask+';*.rom';
{$ifdef fpc}
form2.DirectoryEdit1.Directory:=Directory.spectrum_tap;
{$else}
form2.DirectoryListBox1.Directory:=Directory.spectrum_tap;
{$endif}
if (form2.filelistbox1.Count=0) then ultima_posicion:=-1
  else begin
    if ultima_posicion<form2.filelistbox1.Count then begin
      form2.filelistbox1.Selected[ultima_posicion]:=true;
    end else ultima_posicion:=-1;
end;
end;

procedure spectrum_load_click;
var
  g:integer;
  long_bloque,lbloque:dword;
  f,h,i,pagina:byte;
  t1,t2,t3,t4,t5:integer;
  hay_imagen,salida,hay_scr:boolean;
  temp,temp2,temp3,datos_scr:pbyte;
  cadena,nombre_file:string;
begin
form2.label3.Caption:='';
form2.label4.Caption:='';
hay_imagen:=false;
spec_rom.hay_rom:=false;
hay_scr:=false;
datos_scr:=nil;
nombre:=form2.filelistbox1.FileName;
extension:=extension_fichero(nombre);
if extension='ZIP' then begin
  //Comprobar si hay un SCR
  if search_file_from_zip(nombre,'*.scr',nombre_file,t1,t2,false) then begin
    hay_scr:=true;
    if datos<>nil then begin
      freemem(datos);
      datos:=nil;
    end;
    getmem(datos_scr,t1);
    load_file_from_zip(nombre,nombre_file,datos_scr,t1,t2,false);
  end;
  //Comprobar si hay ROM
  spec_rom.hay_rom:=search_file_from_zip(nombre,'*.rom',spec_rom.nombre_rom,t1,t2,false);
  if spec_rom.hay_rom then begin
      spec_rom.rom_size:=t1;
      form2.label3.Caption:='ROM';
      if spec_rom.datos_rom<>nil then begin
        freemem(spec_rom.datos_rom);
        spec_rom.datos_rom:=nil;
      end;
      getmem(spec_rom.datos_rom,spec_rom.rom_size);
      load_file_from_zip(nombre,spec_rom.nombre_rom,spec_rom.datos_rom,t1,t2,false);
  end;
  find_first_file_zip(nombre,'*.*',nombre_file,file_size,t2,false);
  repeat
    if datos<>nil then begin
      freemem(datos);
      datos:=nil;
    end;
    getmem(datos,file_size);
    extension:=extension_fichero(nombre_file);
    if ((extension='TAP') or (extension='TZX') or (extension='PZX') or (extension='CSW') or (extension='WAV') or (extension='DSP') or (extension='SZX') or (extension='ZX') or (extension='Z80') or (extension='SP') or (extension='SNA')) then begin
      load_file_from_zip(nombre,nombre_file,datos,t1,t2,true);
      if ((extension='CSW') or (extension='WAV')) then form2.label3.Caption:=extension+' Spectrum AudioFile';
      nombre:=nombre_file;
      break;
    end;
  until not(find_next_file_zip(nombre_file,file_size,t2));
end else begin  //fichero normal
  if not(read_file_size(nombre,file_size)) then exit;
  if extension='ROM' then begin
    form2.label3.Caption:='ROM';
    if spec_rom.datos_rom<>nil then begin
      freemem(spec_rom.datos_rom);
      spec_rom.datos_rom:=nil;
    end;
    getmem(spec_rom.datos_rom,file_size);
    if not(read_file(nombre,spec_rom.datos_rom,file_size)) then exit;
    spec_rom.hay_rom:=true;
    nombre:=extractfilename(nombre);
    exit;
  end else begin
    if datos<>nil then begin
       freemem(datos);
       datos:=nil;
    end;
    getmem(datos,file_size);
    if not(read_file(nombre,datos,file_size)) then exit;
  end;
end;
if datos=nil then exit;
temp:=datos;
temp2:=nil;
nombre:=extractfilename(nombre);
if extension='SZX' then begin
  form2.label3.Caption:='SZX Spectrum Snapshot';
  g:=0;
  inc(temp,6);inc(g,6);
  case temp^ of
    0:form2.label4.Caption:='Spectrum 16K';
    1:form2.label4.Caption:='Spectrum 48K';
    2:form2.label4.Caption:='Spectrum 128K';
    3:form2.label4.Caption:='Spectrum +2';
    4:form2.label4.Caption:='Spectrum +2A';
    5:form2.label4.Caption:='Spectrum +3';
  end;
  inc(temp,2);inc(g,2);
  while (not(hay_imagen) and (g<file_size)) do begin
    cadena:='';
    for f:=0 to 3 do begin
      cadena:=cadena+chr(temp^);
      inc(temp);inc(g);
    end;
    copymemory(@lbloque,temp,4);
    inc(temp,4);inc(g,4);
    if cadena='RAMP' then begin
      long_bloque:=0;
      copymemory(@long_bloque,temp,2);
      inc(temp,2);
      pagina:=temp^;
      inc(temp);
      getmem(temp2,16384);
      if long_bloque=1 then Decompress_zlib(temp,lbloque-3,pointer(temp2),t2);
      if pagina=5 then begin
        hay_imagen:=true;
        temp:=temp2;
      end else begin
        inc(temp,lbloque-3);
        inc(g,lbloque);
        freemem(temp2);
      end;
    end else begin
      inc(temp,lbloque);
      inc(g,lbloque);
    end;
  end;
end;
if extension='TAP' then begin
  form2.label3.Caption:='TAP Spectrum Tape';
  g:=0;
  while (not(hay_imagen) and (g<file_size)) do begin
    long_bloque:=0;
    copymemory(@long_bloque,temp,2);
    inc(g,long_bloque+2);
    if long_bloque>6911 then begin
      hay_imagen:=true;
      inc(temp,3);
      break;
    end;
    inc(temp,long_bloque+2);
  end;
end;
if extension='TZX' then begin
  form2.label3.Caption:='TZX Spectrum Tape';
  inc(temp,10);
  g:=0;
  salida:=false;
  while (not(hay_imagen) and (g<file_size)) do begin
    f:=temp^;
    inc(temp);inc(g);
    long_bloque:=0;
    case f of
      $10:begin
          inc(temp,2);inc(g,2);
          copymemory(@long_bloque,temp,2);
          inc(temp,2);inc(g,2);
          salida:=true;
         end;
      $11:begin
          inc(temp,15);inc(g,15);
          copymemory(@long_bloque,temp,2);
          inc(temp,2);inc(g,2);
          inc(long_bloque,temp^*65536);
          inc(temp);inc(g);
          salida:=true;
         end;
      $12,$2a:long_bloque:=4;
      $13:long_bloque:=temp^*2+1;
      $14:begin
           inc(temp,7);inc(g,7);
           copymemory(@long_bloque,temp,2);
           inc(temp,2);inc(g,2);
           inc(long_bloque,temp^*65536);
           inc(temp);inc(g);
           salida:=true;
          end;
      $19:begin
           inc(temp,6);inc(g,6);
           copymemory(@t5,temp,4);
           inc(temp,4);inc(g,4);
           t1:=temp^;
           inc(temp);inc(g);
           t2:=temp^;
           inc(temp);inc(g);
           copymemory(@long_bloque,temp,4);
           inc(temp,4);inc(g,4);
           long_bloque:=long_bloque div 8;
           t3:=temp^;
           inc(temp);inc(g);
           t4:=temp^;
           inc(temp);inc(g);
           for i:=1 to t2 do begin
            inc(temp);inc(g);
            for h:=1 to t1 do begin
              inc(temp,2);
              inc(g,2);
            end;
           end;
           for i:=1 to t5 do begin
            inc(temp);inc(g);
            inc(temp,2);inc(g,2);
           end;
           for i:=0 to (t4-1) do begin
            inc(temp);inc(g);
            for h:=t3 downto 1 do begin
              inc(temp,2);inc(g,2);
            end;
           end;
           if t4=2 then salida:=true;
      end;
      $20,$23,$24:long_bloque:=2;
      $21,$30:long_bloque:=temp^+1;
      $32:begin
            copymemory(@long_bloque,temp,2);
            long_bloque:=long_bloque+2;
          end;
      $33:long_bloque:=temp^*3+1;
      $34:long_bloque:=8;
        else long_bloque:=0;
    end;
    inc(g,long_bloque);
    if ((long_bloque>6911) and salida) then begin
      hay_imagen:=true;
      if ((f<>$14) or (f<>$19)) then inc(temp);
    end else inc(temp,long_bloque);
  end;
end;
if extension='PZX' then begin
  form2.label3.Caption:='PZX Spectrum Tape';
  g:=0;
  inc(temp,4);inc(g,4);
  copymemory(@long_bloque,temp,4);
  inc(temp,4);inc(g,4);
  inc(temp,long_bloque);inc(g,long_bloque);
  while (not(hay_imagen) and (g<file_size)) do begin
    cadena:='';
    for f:=0 to 3 do begin
      cadena:=cadena+chr(temp^);
      inc(temp);inc(g);
    end;
    copymemory(@long_bloque,temp,4);
    inc(temp,4);inc(g,4);
    temp3:=temp;
    inc(temp,long_bloque);inc(g,long_bloque);
    if cadena='DATA' then begin
      copymemory(@lbloque,temp3,4);
      inc(temp3,4);
      lbloque:=lbloque and $7FFFFFFF;
      inc(temp3,2);
      t1:=temp3^;
      inc(temp3);  //cantidad para formar la longitud del 0
      t2:=temp3^;
      inc(temp3);  //cantidad para formar la longitud del 1
      inc(temp3,t1*2);
      inc(temp3,t2*2);
      if (lbloque div 8)>6911 then begin
            hay_imagen:=true;
            temp:=temp3;
            inc(temp);
      end;
    end;
  end;
end;
if ((extension='Z80') or (extension='DSP')) then begin
  if extension='Z80' then form2.label3.Caption:='Z80 Spectrum Snapshot'
    else form2.label3.Caption:='DSP Spectrum Snapshot';
  inc(temp,6);
  g:=0;
  copymemory(@g,temp,2);
  inc(temp,24);
  if g=0 then begin
    getmem(temp2,16384);
    copymemory(@g,temp,2);
    inc(temp,4);
    case temp^ of
      0,1:form2.label4.Caption:='Spectrum 48K';  //Modo 48k
      3:if g=23 then form2.label4.Caption:='Spectrum 128K'
          else form2.label4.Caption:='Spectrum 48K';
      4,5,6:form2.label4.Caption:='Spectrum 128K';  //Modo 128K
      7,8:form2.label4.Caption:='Spectrum +3';  //Modo +3
      12:form2.label4.Caption:='Spectrum +2A'; //Modo +2A
      13:form2.label4.Caption:='Spectrum +2'; //Modo +2
    end;
    inc(temp,g-2);
    f:=0;
    while f<>8 do begin
      copymemory(@g,temp,2);
      inc(temp,2);
      f:=temp^;
      inc(temp);
      if f=8 then begin
        if g=$FFFF then copymemory(temp2,temp,$4000)
          else begin
            if extension='DSP' then Decompress_zlib(temp,g,pointer(temp2),g)
              else descomprimir_z80(temp2,temp,g);
          end;
      end;
      if g=$FFFF then inc(temp,$4000)
        else inc(temp,g);
    end;
  end else begin
    form2.label4.Caption:='Spectrum 48K';
    getmem(temp2,49192);
    descomprimir_z80(temp2,temp,file_size-34);
  end;
  temp:=temp2;
  hay_imagen:=true;
end;
if extension='SNA' then begin
  form2.label3.Caption:='SNA Spectrum Snapshot';
  if file_size>49179 then form2.label4.caption:='Spectrum 128K'
    else form2.label4.caption:='Spectrum 48K';
  inc(temp,27);
  hay_imagen:=true;
end;
if extension='SP' then begin
  form2.label3.Caption:='SP Spectrum Snapshot';
  form2.label4.caption:='Spectrum 48K';
  inc(temp,38);
  hay_imagen:=true;
end;
if extension='ZX' then begin
  form2.label3.Caption:='ZX Spectrum Snapshot';
  form2.label4.caption:='Spectrum 48K';
  inc(temp,132);
  hay_imagen:=true;
end;
if hay_scr then begin
  temp:=datos_scr;
  hay_imagen:=true;
end;
//mostrar imagen si hay...
if hay_imagen then begin
  spec_a_pantalla(temp,form2.image1.picture.Bitmap);
end else begin
  form2.image1.picture:=nil;
end;
if temp2<>nil then freemem(temp2);
if datos_scr<>nil then freemem(datos_scr);
end;

procedure spectrum_load_test_rom;
var
  rom_crc:cardinal;
begin
rom_crc:=calc_crc(spec_rom.datos_rom,spec_rom.rom_size);
case rom_crc of
   $7BCD642C:begin  //Knight Lore, solo puede ser Spectrum 48k
                   spectrum_change_model(0);
                   interface2.hay_if2:=true;
                   interface2.cargado:=false;
                   copymemory(@interface2.rom[0],spec_rom.datos_rom,$8000);
             end;
   else begin
          //Si el modelo no es Sepctrum 16k o 48k, hay que cambiarlo...
          if ((main_vars.tipo_maquina<>0) and (main_vars.tipo_maquina<>5)) then spectrum_change_model(0);
          copymemory(@memoria[0],spec_rom.datos_rom,$4000);
          interface2.hay_if2:=false;
   end;
end;
end;

procedure spectrum_load_exit;
var
  resultado,cinta:boolean;
  cadena:string;
begin
if ((datos=nil) and not(spec_rom.hay_rom)) then exit;
cinta:=false;
resultado:=false;
if spec_rom.hay_rom then begin
  spectrum_load_test_rom;
  llamadas_maquina.reset;
  rom_cambiada_48:=true;
  resultado:=true;
  change_caption(llamadas_maquina.caption+' - ROM: '+spec_rom.nombre_rom);
  cadena:=' - ROM: ';
end else cadena:=' - Snap: ';
if extension='TAP' then begin
  resultado:=abrir_tap(datos,file_size);
  cinta:=true;
end;
if extension='TZX' then begin
  resultado:=abrir_tzx(datos,file_size);
  cinta:=true;
end;
if extension='PZX' then begin
  resultado:=abrir_pzx(datos,file_size);
  cinta:=true;
end;
if extension='CSW' then begin
  resultado:=abrir_csw(datos,file_size);
  cinta:=true;
end;
if extension='WAV' then begin
  resultado:=abrir_wav(datos,file_size);
  cinta:=true;
end;
if extension='Z80' then resultado:=abrir_z80(datos,file_size,false);
if extension='DSP' then resultado:=abrir_z80(datos,file_size,true);
if extension='SNA' then resultado:=abrir_sna(datos,file_size);
if extension='SP' then resultado:=abrir_sp(datos,file_size);
if extension='ZX' then resultado:=abrir_zx(datos,file_size);
if extension='SZX' then resultado:=abrir_szx(datos,file_size);
if not(resultado) then MessageDlg('No es una cinta o un snapshot válido.'+chr(10)+chr(13)+'Not a valid tape or snapshot', mtInformation,[mbOk], 0)
  else begin
    if cinta then begin
      form5.edit1.Text:=nombre;
      form5.show;
      form5.BitBtn1.Enabled:=true;
      form5.BitBtn2.Enabled:=false;
    end else begin  //Snap shot
      change_caption(llamadas_maquina.caption+cadena+nombre);
      main_screen.rapido:=false;
    end;
    Directory.spectrum_tap:=form2.FileListBox1.Directory+main_vars.cadena_dir;
    ultima_posicion:=form2.filelistbox1.ItemIndex;
    form2.close;
   end;
if datos<>nil then freemem(datos);
datos:=nil;
if spec_rom.datos_rom<>nil then freemem(spec_rom.datos_rom);
spec_rom.datos_rom:=nil;
end;

procedure spectrum_load_close;
begin
if datos<>nil then begin
  freemem(datos);
  datos:=nil;
end;
if spec_rom.datos_rom<>nil then begin
  freemem(spec_rom.datos_rom);
  spec_rom.datos_rom:=nil;
end;
Directory.spectrum_tap:=form2.FileListBox1.Directory+main_vars.cadena_dir;
end;

end.
