unit lenguaje;

interface
uses {$ifndef windows}LCLType,{$endif}sysutils,forms,dialogs,main_engine;

const
      MAX_IDIOMAS=7-1;
      idiomas:array [0..MAX_IDIOMAS] of string=
        ('espanol.lng','english.lng','catala.lng','francais.lng','german.lng',
        'brazil.lng','italian.lng');
type
        tlenguaje=record
          archivo:array[0..4] of string;
          opciones:array[0..4] of string;
          maquina:array[0..4] of string;
          accion:array[0..4] of string;
          cinta:array[0..18] of string;
          errores:array[0..2] of string;
          avisos:array[0..5] of string;
          mensajes:array[0..9] of string;
          varios:array[0..2] of string;
          hints:array[0..19] of string;
        end;

var
  leng:array[0..MAX_IDIOMAS] of tlenguaje;

function leer_idioma:boolean;
procedure cambiar_idioma(idioma:byte);

implementation
uses principal;

procedure cambiar_idioma(idioma:byte);
begin
if not(main_vars.lenguaje_ok) then exit;
principal1.Castellano1.Checked:=false;
principal1.Ingles1.Checked:=false;
principal1.Catalan1.Checked:=false;
principal1.French1.Checked:=false;
principal1.German1.Checked:=false;
principal1.Brazil1.Checked:=false;
principal1.italiano1.checked:=false;
case idioma of
  0:principal1.Castellano1.Checked:=true;
  1:principal1.Ingles1.Checked:=true;
  2:principal1.Catalan1.Checked:=true;
  3:principal1.French1.Checked:=true;
  4:principal1.German1.Checked:=true;
  5:principal1.Brazil1.Checked:=true;
  6:principal1.italiano1.Checked:=true;
end;
//Archivo
principal1.archivo1.caption:=leng[idioma].archivo[0];
principal1.idioma1.caption:=leng[idioma].archivo[1];
principal1.LstRoms.caption:=leng[idioma].archivo[4];
principal1.salir1.caption:=leng[idioma].archivo[2];
principal1.acercade1.caption:=leng[idioma].archivo[3];
//Opciones
principal1.opciones1.caption:=leng[idioma].opciones[0];
principal1.audio1.caption:=leng[idioma].opciones[1];
principal1.video1.caption:=leng[idioma].opciones[2];
principal1.sinsonido1.caption:=leng[idioma].opciones[3];
principal1.configuracion1.caption:=leng[idioma].opciones[4];
//Maquina
principal1.emulacion1.caption:=leng[idioma].maquina[0];
principal1.ordenadores8bits1.caption:=leng[idioma].maquina[1];
principal1.arcade1.caption:=leng[idioma].maquina[2];
principal1.consolas1.caption:=leng[idioma].maquina[3];
//Accion
principal1.uprocesador1.caption:=leng[idioma].accion[0];
principal1.ejecutar1.caption:=leng[idioma].accion[1];
principal1.reset1.caption:=leng[idioma].accion[2];
principal1.pausa1.caption:=leng[idioma].accion[3];
//Hints
principal1.BitBtn2.Hint:=leng[idioma].hints[0];
principal1.BitBtn3.Hint:=leng[idioma].hints[1];
principal1.BitBtn5.Hint:=leng[idioma].hints[3];
principal1.BitBtn6.Hint:=leng[idioma].hints[4];
principal1.btncfg.Hint:=leng[idioma].hints[5];
principal1.bitbtn19.Hint:=leng[idioma].hints[11];
principal1.BitBtn8.Hint:=leng[idioma].hints[18];
principal1.BitBtn13.Hint:=leng[idioma].hints[19];
principal1.BitBtn1.Hint:=leng[idioma].hints[6];
principal1.BitBtn9.Hint:=leng[idioma].hints[7];
principal1.BitBtn10.Hint:=leng[idioma].hints[8];
principal1.BitBtn11.Hint:=leng[idioma].hints[9];
principal1.BitBtn12.Hint:=leng[idioma].hints[10];
principal1.BitBtn14.Hint:=leng[idioma].hints[12];
end;

function leer_fichero_idioma(nombre:string;posicion:byte):boolean;
var
          fichero: textfile;
          cadena: string;
begin
leer_fichero_idioma:=false;
if not(fileexists(nombre)) then exit;
assignfile(fichero,nombre);
reset(fichero);
readln(fichero,cadena); //leer el 1er codigo
//archivo
readln(fichero,cadena);leng[posicion].archivo[0]:=cadena;
readln(fichero,cadena);leng[posicion].archivo[1]:=cadena;
readln(fichero,cadena);leng[posicion].archivo[4]:=cadena;
readln(fichero,cadena);leng[posicion].archivo[2]:=cadena;
readln(fichero,cadena);leng[posicion].archivo[3]:=cadena;
//opciones
readln(fichero,cadena);leng[posicion].opciones[0]:=cadena;
readln(fichero,cadena);leng[posicion].opciones[1]:=cadena;
readln(fichero,cadena);leng[posicion].opciones[2]:=cadena;
readln(fichero,cadena);leng[posicion].opciones[3]:=cadena;
//maquina
readln(fichero,cadena);leng[posicion].maquina[0]:=cadena;
readln(fichero,cadena);leng[posicion].maquina[1]:=cadena;
readln(fichero,cadena);leng[posicion].maquina[2]:=cadena;
readln(fichero,cadena);leng[posicion].maquina[3]:=cadena;
//accion
readln(fichero,cadena);leng[posicion].accion[0]:=cadena;
readln(fichero,cadena);leng[posicion].accion[1]:=cadena;
readln(fichero,cadena);leng[posicion].accion[2]:=cadena;
readln(fichero,cadena);leng[posicion].accion[3]:=cadena;
//varios
readln(fichero,cadena);leng[posicion].varios[0]:=cadena;
readln(fichero,cadena);leng[posicion].varios[1]:=cadena;
//cinta
readln(fichero,cadena);leng[posicion].cinta[0]:=cadena;
readln(fichero,cadena);leng[posicion].cinta[1]:=cadena;
readln(fichero,cadena);leng[posicion].cinta[2]:=cadena;
readln(fichero,cadena);leng[posicion].cinta[3]:=cadena;
readln(fichero,cadena);leng[posicion].cinta[4]:=cadena;
readln(fichero,cadena);leng[posicion].cinta[5]:=cadena;
readln(fichero,cadena);leng[posicion].cinta[6]:=cadena;
readln(fichero,cadena);leng[posicion].cinta[7]:=cadena;
readln(fichero,cadena);leng[posicion].cinta[8]:=cadena;
readln(fichero,cadena);leng[posicion].cinta[9]:=cadena;
readln(fichero,cadena);leng[posicion].cinta[10]:=cadena;
readln(fichero,cadena);leng[posicion].cinta[11]:=cadena;
readln(fichero,cadena);leng[posicion].cinta[12]:=cadena;
readln(fichero,cadena);leng[posicion].cinta[13]:=cadena;
readln(fichero,cadena);leng[posicion].cinta[14]:=cadena;
readln(fichero,cadena);leng[posicion].cinta[15]:=cadena;
readln(fichero,cadena);leng[posicion].cinta[16]:=cadena;
readln(fichero,cadena);leng[posicion].cinta[17]:=cadena;
readln(fichero,cadena);leng[posicion].cinta[18]:=cadena;
//mensajes
readln(fichero,cadena);leng[posicion].mensajes[0]:=cadena;
readln(fichero,cadena);leng[posicion].mensajes[1]:=cadena;
readln(fichero,cadena);leng[posicion].mensajes[2]:=cadena;
readln(fichero,cadena);leng[posicion].mensajes[9]:=cadena; //nombre cinta virtual
readln(fichero,cadena);leng[posicion].mensajes[3]:=cadena; //sobreescribir
readln(fichero,cadena);leng[posicion].mensajes[4]:=cadena; //si
readln(fichero,cadena);leng[posicion].mensajes[5]:=cadena; //no
readln(fichero,cadena);leng[posicion].mensajes[6]:=cadena; //atencion
readln(fichero,cadena);leng[posicion].mensajes[7]:=cadena; //cargar
readln(fichero,cadena);leng[posicion].mensajes[8]:=cadena; //cancelar
//errores
readln(fichero,cadena);leng[posicion].errores[0]:=cadena; //ERROR: No se puede encontrar la ROM
readln(fichero,cadena);leng[posicion].errores[1]:=cadena; //dentro del fichero
//hints
readln(fichero,cadena);leng[posicion].hints[0]:=cadena; //Reset
readln(fichero,cadena);leng[posicion].hints[1]:=cadena; //Ejecutar emulacion
readln(fichero,cadena);leng[posicion].hints[2]:=cadena; //Pausar emulacion
readln(fichero,cadena);leng[posicion].hints[3]:=cadena; //Velocidad emulacion 25%, 50%, 75% o 100%
readln(fichero,cadena);leng[posicion].hints[4]:=cadena; //Velocidad maxima
readln(fichero,cadena);leng[posicion].hints[5]:=cadena; //Configurar DSP
readln(fichero,cadena);leng[posicion].hints[6]:=cadena; //Configurar ordenador/consola
readln(fichero,cadena);leng[posicion].hints[7]:=cadena; //Cargar Cinta/Snapshot
readln(fichero,cadena);leng[posicion].hints[8]:=cadena; //Cargar Disco
readln(fichero,cadena);leng[posicion].hints[9]:=cadena; //Guardar Snapshot
readln(fichero,cadena);leng[posicion].hints[10]:=cadena; //Poke Memoria
readln(fichero,cadena);leng[posicion].hints[11]:=cadena; //Guardar Imagen
readln(fichero,cadena);leng[posicion].hints[12]:=cadena; //FlashLoad ON/OFF
readln(fichero,cadena);leng[posicion].hints[13]:=cadena; //Play cassette virtual
readln(fichero,cadena);leng[posicion].hints[14]:=cadena; //Stop cassette virtual
readln(fichero,cadena);leng[posicion].hints[15]:=cadena; //Cerrar cassette virtual
readln(fichero,cadena);leng[posicion].hints[16]:=cadena; //Nombre cassette virtual
readln(fichero,cadena);leng[posicion].hints[17]:=cadena; //Contenido del cassette virtual
readln(fichero,cadena);leng[posicion].hints[18]:=cadena; //Configurar dipswitch
readln(fichero,cadena);leng[posicion].hints[19]:=cadena; //Cambiar driver
//Nuevos...
readln(fichero,cadena);leng[posicion].opciones[4]:=cadena; //Configuracion
readln(fichero,cadena);leng[posicion].errores[2]:=cadena; //dentro del fichero
close(fichero);
leer_fichero_idioma:=true;
end;

function leer_idioma:boolean;
var
  f:byte;
begin
leer_idioma:=false;
for f:=0 to MAX_IDIOMAS do begin
  if not(leer_fichero_idioma(Directory.lenguaje+idiomas[f],f)) then begin
    MessageDlg('Aviso: Faltan el ficheros de idioma.'+chr(13)+chr(10)+'Warning: Missing lenguaje files.', mtWarning,[mbOk], 0);
    principal1.idioma1.enabled:=false;
    exit;
  end;
end;
leer_idioma:=true;
end;

end.
