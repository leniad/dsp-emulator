unit spectrum_load;

interface
uses {$ifdef windows}windows,{$endif}
     Dialogs,main_engine,spectrum_48k,misc_functions,file_engine,
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
load_spec.Button2.Caption:=leng[main_vars.idioma].mensajes[7];
load_spec.Button1.Caption:=leng[main_vars.idioma].mensajes[8];
load_spec.FileListBox1.Mask:='*.zip;*.sp;*.zx;*.sna;*.z80;*.tzx;*.tap;*.csw;*.dsp;*.wav;*.szx;*.pzx';
if ((main_vars.tipo_maquina=0) or (main_vars.tipo_maquina=5)) then load_spec.FileListBox1.Mask:=load_spec.FileListBox1.Mask+';*.rom';
{$ifdef fpc}
load_spec.DirectoryEdit1.Directory:=Directory.spectrum_tap;
{$else}
load_spec.DirectoryListBox1.Directory:=Directory.spectrum_tap;
{$endif}
if (load_spec.filelistbox1.Count=0) then ultima_posicion:=-1
  else begin
    if ultima_posicion<load_spec.filelistbox1.Count then begin
      load_spec.filelistbox1.Selected[ultima_posicion]:=true;
    end else ultima_posicion:=-1;
end;
end;

type
  ttape_version=packed record
            major:byte;
            minor:byte;
           end;

procedure spectrum_load_click;
var
  g:integer;
  long_bloque,lbloque:dword;
  f,h,i,pagina:byte;
  t1,t2,t3,t4,t5:integer;
  hay_imagen,salida,hay_scr:boolean;
  temp,temp2,temp3,datos_scr:pbyte;
  nombre_file:string;
  tzx_header:^ttzx_header;
  pzx_header:^tpzx_header;
  pzx_data:^tpzx_data;
  tape_version:^ttape_version;
  szx_header:^tszx_header;
  szx_block:^tszx_block;
  szx_ramp:^tszx_ramp;
  tap_header:^ttap_header;
  csw_header:^tcsw_header;
begin
load_spec.label3.Caption:='';
load_spec.label4.Caption:='';
hay_imagen:=false;
spec_rom.hay_rom:=false;
hay_scr:=false;
datos_scr:=nil;
nombre:=load_spec.filelistbox1.FileName;
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
      load_spec.label3.Caption:='ROM';
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
      nombre:=nombre_file;
      break;
    end;
  until not(find_next_file_zip(nombre_file,file_size,t2));
end else begin  //fichero normal
  if not(read_file_size(nombre,file_size)) then exit;
  if extension='ROM' then begin
    load_spec.label3.Caption:='ROM';
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
  getmem(szx_header,sizeof(tszx_header));
  copymemory(szx_header,temp,8);
  inc(temp,8);g:=8;
  if szx_header.minor_version<10 then load_spec.label3.Caption:='SZX Spectrum Snapshot v'+inttostr(szx_header.major_version)+'.0'+inttostr(szx_header.minor_version)
    else load_spec.label3.Caption:='SZX Spectrum Snapshot v'+inttostr(szx_header.major_version)+'.'+inttostr(szx_header.minor_version);
  case szx_header.tipo_maquina of
    0:load_spec.label4.Caption:='Spectrum 16K';
    1:load_spec.label4.Caption:='Spectrum 48K';
    2:load_spec.label4.Caption:='Spectrum 128K';
    3:load_spec.label4.Caption:='Spectrum +2';
    4:load_spec.label4.Caption:='Spectrum +2A';
    5:load_spec.label4.Caption:='Spectrum +3';
  end;
  freemem(szx_header);
  getmem(szx_block,sizeof(tszx_block));
  while (not(hay_imagen) and (g<file_size)) do begin
    copymemory(szx_block,temp,8);
    inc(temp,8);inc(g,8);
    if szx_block.name='RAMP' then begin
      getmem(szx_ramp,sizeof(tszx_ramp));
      copymemory(szx_ramp,temp,szx_block.longitud);
      if szx_ramp.numero=5 then begin
        if (szx_ramp.flags and 1)<>0 then begin //Pagina RAM comprimida
          getmem(temp2,$4000);
          Decompress_zlib(pointer(@szx_ramp.data[0]),szx_block.longitud-3,pointer(temp2),t2);
          hay_imagen:=true;
          temp:=temp2;
        end else begin //Sin comprimir
          temp:=@szx_ramp.data[0];
          hay_imagen:=true;
        end;
      end else begin
        inc(temp,szx_block.longitud);
        inc(g,szx_block.longitud);
      end;
      freemem(szx_ramp);
    end else begin
      inc(temp,szx_block.longitud);
      inc(g,szx_block.longitud);
    end;
  end;
  freemem(szx_block);
end;
//TAP
if extension='TAP' then begin
  load_spec.label3.Caption:='TAP Spectrum Tape';
  getmem(tap_header,sizeof(ttap_header));
  g:=0;
  while (not(hay_imagen) and (g<file_size)) do begin
    copymemory(tap_header,temp,20);
    if tap_header.size>6911 then begin
      hay_imagen:=true;
      inc(temp,3);  //Para llegar a los datos, le sumo el tamaño y el flag
    end else begin
      inc(temp,tap_header.size+2);
      g:=g+tap_header.size+2;
    end;
  end;
  freemem(tap_header);
end;
//TZX
if extension='TZX' then begin
  getmem(tzx_header,sizeof(ttzx_header));
  copymemory(tzx_header,temp,10);
  inc(temp,10);
  if tzx_header.minor<10 then load_spec.label3.Caption:='TZX Spectrum Tape v'+inttostr(tzx_header.major)+'.0'+inttostr(tzx_header.minor)
    else load_spec.label3.Caption:='TZX Spectrum Tape v'+inttostr(tzx_header.major)+'.'+inttostr(tzx_header.minor);
  freemem(tzx_header);
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
  getmem(pzx_header,sizeof(tpzx_header));
  copymemory(pzx_header,temp,8);
  inc(temp,8);
  getmem(tape_version,sizeof(ttape_version));
  copymemory(tape_version,temp,2);
  inc(temp,pzx_header.size);g:=pzx_header.size+8;
  if tape_version.minor<10 then load_spec.label3.Caption:='PZX Spectrum Tape v'+inttostr(tape_version.major)+'.0'+inttostr(tape_version.minor)
    else load_spec.label3.Caption:='PZX Spectrum Tape v'+inttostr(tape_version.major)+'.'+inttostr(tape_version.minor);
  freemem(tape_version);
  while (not(hay_imagen) and (g<file_size)) do begin
    copymemory(pzx_header,temp,8);
    inc(temp,8);inc(g,8);
    temp3:=temp;
    inc(temp,pzx_header.size);inc(g,pzx_header.size);
    if pzx_header.name='DATA' then begin
      getmem(pzx_data,sizeof(tpzx_data));
      copymemory(pzx_data,temp3,8);
      inc(temp3,8);
      pzx_data.bit_count:=(pzx_data.bit_count and $7FFFFFFF) div 8;
      inc(temp3,2*pzx_data.p0);
      inc(temp3,2*pzx_data.p1);
      if pzx_data.bit_count>6911 then begin
            hay_imagen:=true;
            temp:=temp3;
            inc(temp);
      end;
      freemem(pzx_data);
    end;
  end;
  freemem(pzx_header);
end;
if ((extension='Z80') or (extension='DSP')) then begin
  if extension='Z80' then load_spec.label3.Caption:='Z80 Spectrum Snapshot'
    else load_spec.label3.Caption:='DSP Spectrum Snapshot';
  inc(temp,6);
  g:=0;
  copymemory(@g,temp,2);
  inc(temp,24);
  if g=0 then begin
    getmem(temp2,16384);
    copymemory(@g,temp,2);
    inc(temp,4);
    case temp^ of
      0,1:load_spec.label4.Caption:='Spectrum 48K v3.0';  //Modo 48k
      3:if g=23 then load_spec.label4.Caption:='Spectrum 128K v2.0'
          else load_spec.label4.Caption:='Spectrum 48K v3.0';
      4,5,6:load_spec.label4.Caption:='Spectrum 128K v3.0';  //Modo 128K
      7,8:load_spec.label4.Caption:='Spectrum +3 v3.0';  //Modo +3
      12:load_spec.label4.Caption:='Spectrum +2A v3.0'; //Modo +2A
      13:load_spec.label4.Caption:='Spectrum +2 v3,0'; //Modo +2
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
    load_spec.label4.Caption:='Spectrum 48K v1.0';
    getmem(temp2,49192);
    g:=file_size-34;
    descomprimir_z80(temp2,temp,g);
  end;
  temp:=temp2;
  hay_imagen:=true;
end;
if extension='SNA' then begin
  load_spec.label3.Caption:='SNA Spectrum Snapshot';
  if file_size>49179 then load_spec.label4.caption:='Spectrum 128K'
    else load_spec.label4.caption:='Spectrum 48K';
  inc(temp,27);
  hay_imagen:=true;
end;
if extension='SP' then begin
  load_spec.label3.Caption:='SP Spectrum Snapshot';
  load_spec.label4.caption:='Spectrum 48K';
  inc(temp,38);
  hay_imagen:=true;
end;
if extension='ZX' then begin
  load_spec.label3.Caption:='ZX Spectrum Snapshot';
  load_spec.label4.caption:='Spectrum 48K';
  inc(temp,132);
  hay_imagen:=true;
end;
if extension='CSW' then begin
  getmem(csw_header,sizeof(tcsw_header));
  copymemory(csw_header,temp,25);
  if csw_header.minor<10 then load_spec.label3.Caption:='Compressed Square Wave v'+inttostr(csw_header.major)+'.0'+inttostr(csw_header.minor)
    else load_spec.label3.Caption:='Compressed Square Wave v'+inttostr(csw_header.major)+'.'+inttostr(csw_header.minor);
  load_spec.label4.caption:=' ';
  hay_imagen:=false;
  freemem(csw_header);
end;
if extension='WAV' then begin
  load_spec.label3.Caption:='WAV Spectrum AudioFile';
  load_spec.label4.caption:=' ';
  hay_imagen:=false;
end;
//Hay una imagen SCR, dejo todo lo demas y me quedo con la imagen
if hay_scr then begin
  temp:=datos_scr;
  hay_imagen:=true;
end;
//mostrar imagen si hay...
if hay_imagen then spec_a_pantalla(temp,load_spec.image1.picture.Bitmap)
  else load_spec.image1.picture:=nil;
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
if ((extension='Z80') or (extension='DSP')) then resultado:=abrir_z80(datos,file_size,extension='DSP');
if extension='SNA' then resultado:=abrir_sna(datos,file_size);
if extension='SP' then resultado:=abrir_sp(datos,file_size);
if extension='ZX' then resultado:=abrir_zx(datos,file_size);
if extension='SZX' then resultado:=abrir_szx(datos,file_size);
if not(resultado) then MessageDlg('No es una cinta o un snapshot válido.'+chr(10)+chr(13)+'Not a valid tape or snapshot', mtInformation,[mbOk], 0)
  else begin
    if cinta then begin
      tape_window1.edit1.Text:=nombre;
      tape_window1.show;
      tape_window1.BitBtn1.Enabled:=true;
      tape_window1.BitBtn2.Enabled:=false;
    end else begin  //Snap shot
      change_caption(llamadas_maquina.caption+cadena+nombre);
      main_screen.rapido:=false;
    end;
    Directory.spectrum_tap:=load_spec.FileListBox1.Directory+main_vars.cadena_dir;
    ultima_posicion:=load_spec.filelistbox1.ItemIndex;
    load_spec.close;
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
Directory.spectrum_tap:=load_spec.FileListBox1.Directory+main_vars.cadena_dir;
end;

end.
