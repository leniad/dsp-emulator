unit lenguaje;

interface
uses {$ifdef windows}windows{$else}sysutils{$endif};

const
      MAX_IDIOMAS=7-1;
      lng_txt:array[0..MAX_IDIOMAS,0..79] of string=(
      //Español
      ('Archivo','Idioma','Lista de ROMS','Salir','Acerca de...','Opciones','Sonido','Video','Desconectado','Máquina','Ordenadores 8bits','Arcade',
       'Consolas','Acción','Ejecutar','Reiniciar','Pausa','Nombre','Longitud','Cabecera','Bytes','Datos','Bytes Turbo','Tono Puro','Secuencia Pulsos',
       'Datos Puros','Grabación Directa','Para la cinta','Pausa','Grupo','Saltar a posición','Bucle','Fin de Bucle','Para si Spectrum 48K','Texto',
       'Mensaje','Información Archivo','Información Hardware','Velocidad','Bytes Cargados','Cinta Virtual','Nombre de la Cinta','El fichero ya existe. ¿Sobrescribir?',
       'SI','NO','ATENCIÓN','CARGAR','CANCELAR','No se puede encontrar la ROM','dentro del fichero','Reset','Ejecutar emulación','Pausar emulación','Velocidad emulación 25%, 50%, 75% o 100%',
       'Velocidad máxima','Configurar DSP','Configurar ordenador/consola','Cargar Cinta/Snapshot','Cargar Disco','Guardar Snapshot','Poke Memoria','Capturar Imagen',
       'FlashLoad ON/OFF','Play cassette virtual','Stop cassette virtual','Cerrar cassette virtual','Nombre cassette virtual','Contenido del cassette virtual','Configurar dipswitch',
       'Mostrar lista de juegos','Configuración','Fichero no encontrado','Cargar Juego','Ejecutar el último juego al inicio','Mostrar errores de las ROMS','Centrar pantalla principal',
       'CONSOLAS: Mostrar menú de carga de juegos al inicio','Conectado','Abrir','Carpetas'),
       //English
      ('File','Language','ROMS list','Exit','About...','Options','Sound','Video','Disabled','Machine','8bits Computers','Arcade','Consoles','Action','Run',
       'Reset','Pause','Name','Size','Header','Bytes','Data','Turbo Bytes','Pure Tone','Pulse Sequence','Pure Data','Direct Recording','Stop the tape','Pause',
       'Group','Jump To','Loop','Loop end','Stop if Spectrum 48K','Text','Message','File Info','Hardware Info','Speed','Loaded Bytes','Virtual Tape','Tape Name',
       'File already exists. Overwrite?','YES','NO','WARNING','LOAD','CANCEL','Can not find ROM file','inside file','Reset','Run emulation','Pause emulation',
       'Emulation speed: 25%, 50%, 75% or 100%','Fastest speed','Configure DSP','Configure computer/console','Load Tape/Snapshot','Load Disk','Save Snapshot',
       'Poke Memory','Take Snapshot','FlashLoad ON/OFF','Play virtual tape','Stop virtual tape','Close virtual tape','Virtual tape name','Virtual tape content',
       'Configure dipswitch','Show game list','Configuration','File not found','Load Game','Run last game at start-up','Show ROMs errors','Center main screen',
       'CONSOLES: Show game loading menu at startup','Enabled','Open','Folders'),
       //Català
      ('Arxiu','Idioma','Llista de ROMS','Sortida','Acerca de...','Opcions','So','Video','Desconectat','Màquina','Ordinadors 8bits','Arcade','Consolas',
       'Acció','Executar','Reiniciar','Pausa','Nom','Longitud','Capçalera','Bytes','Dades','Bytes Turbo','To Pur','Seqüència Pulsos','Dades Purs','Gravació Directa',
       'Para la cinta','Pausa','Grup','Saltar a posició','Bucle','Fi de Bucle','Para si Spectrum 48K','Text','Missatge','Informació Arxiu','Informació Hardware','Velocitat',
       'Bytes Carregats','Cinta Virtual','Nom de la Cinta','El fitxer ja existeix. Sobreescriure?','SI','NO','ATENCIO','CARREGAR','CANCEL·LAR','No es pot trobar la ROM',
       'dintre del fitxer','Reset','Executar emulació','Pausar emulació','Velocitat de la emulació: 25%, 50%, 75% o 100%','Velocitat máxima','Configurar DSP',
       'Configurar ordinador/consola','Carregar Cinta/Snapshot','Carregar Disc','Guardar Snapshot','Poke Memoria','Guardar imatge','FlashLoad ON/OFF','Play cassette virtual',
       'Stop cassette virtual','Tancar el cassette virtual','Nom del cassette virtual','Contigut del cassette virtual','Configurar dipswitch','Mostrar la llista de jocs',
       'Configuració','No es troba el fitxer','Carregar Joc','Carregar l''ultim joc a l''inici','Mostrar errors en les ROMs','Centrar la pantalla principal',
       'CONSOLES: Mostra menú de càrrega de jocs a l''inici','Conectat','Obrir','Carpetes'),
       //French
      ('Fichier','Langage','Liste de ROMS','Quitter','A propos de ...','Options','Du Son','Vidéo','Désactivé','Machine','Ordinateurs 8 bits','Arcade','Consoles',
       'Action','Exécuter','Reset','Pause','Nom','Taille','Entête','Octets','Données','Turbo Bytes','Tonalité pure','Séquence pulsée','Données pures','Enregistrement direct',
       'Arreter la cassette','Pause','Groupe','Aller à','Boucle','Fin de boucle','Arrêter si Spectrum 48K','Texte','Message','Informations fichier','Information matérielle',
       'Vitesse','Octets chargés','Cassette','Nom del Cassette','Fichier existant. Ecraser?','OUI','NON','ATTENTION','CHARGER','ANNULER','Fichier ROM introuvable',
       'dintre ou fichier','Reset','Démarrer l''émulation','Pause l''émulation','Vitesse d''émulation: 25%, 50%, 75% or 100%','Citesse la plus rapide','Configurer DSP',
       'Configurer l''ordinateur/console','Charge Tape/Snapshot','Charge Disk','Enregistrer Snapshot','Poke Memory','Enregistrer l''image','FlashLoad ON/OFF',
       'Lancer la cassette virtuelle','Arrêter la cassette virtuelle','Fermer la cassette virtuelle','Nom cassette virtuelle','Contenu cassette virtuelle',
       'Configurer dipswitch','Liste de jeux','Configuration','Fichier non trouvé','Chargement du Jeu','Lancer le dernier jeu au démarrage','Afficher les erreurs de ROM',
       'Écran principal central','CONSOLES: Afficher le menu de chargement du jeu au démarrage','Activé','Ouvrir','Dossiers'),
       //German
      ('Datei','Sprache','ROMS Liste','Beenden','Über...','Optionen','Klang','Video','Deaktiviert','Maschine','8-Bit-Computer','Spielhallenmaschinen','Konsolen',
       'Aktion','Laufen','Zurücksetzen','Pause','Name','Größe','Kopf','Bytes','Daten','Turbo-Bytes','Pure Tone','Pulssequenz','Pure Data','Direktaufnahme',
       'Band Stoppen','Pause','Gruppe','Springe zu','Schleife','Schleifenende','Stoppen wenn Spectrum 48K','Text','Nachricht','Datei-Informationen','Hardware-Informationen',
       'Geschwindigkeit','Geladene Bytes','Virtuelles Band','Band-Name','Datei existiert bereits. Überschreiben?','JA','NEIN','WARNUNG','LADE','ABBRUCH','Kann ROM-Datei nicht finden',
       'oder Datei','Zurücksetzen','Emulation laufenlassen','Emulation anhalten','Emulationsgeschwindigkeit: 25%, 50%, 75% or 100%','Schnellste Geschwindigkeit',
       'DSP konfigurieren','Konfigurieren Computer/Konsole','Lade Band/Schnappschuß','Lade Diskette','Speichere Schnappschuß','Speicher-Poke','Bild speichern',
       'TAP nach TZX konvertieren','Virtuelles Band abspielen','Virtuelles Band stoppen','Virtuelles Band schließen','Name des virtuellen Bands','Inhalt des virtuellen Bands',
       'Konfigurieren dipswitch','Spielliste','Konfiguration','Die Datei wurde nicht gefunden','Spiel laden','Letztes Spiel beim Start ausführen','ROM-Fehler anzeigen',
       'Hauptbildschirm zentrieren','KONSOLEN: Spiellademenü beim Start anzeigen','Aktiviert','öffnen','Ordner'),
       //Brazil
      ('Arquivo','Indioma','Lista de ROMS','Salir','Sobre...','Opções','Som','Video','Desativado','Máquina','Ordenadores 8bits','Arcade','Consoles','Ação','Executar',
       'Reiniciar','Pausar','Nome','Longitude','Cabeça','Bytes','Dados','Bytes Turbo','Tone Puro','Sequencía Pulsos','Dados Pulos','Gravação Direta','Para a tela',
       'Pausa','Grupo','Saltar a posição','Bucle','Fim de Bucle','Para o Spectrum 48K','Texto','Mensagem','Informação do Arquivo','Informação Hardware','Velocidade',
       'Bytes Carregados','Tela','Nome de la Cinta','O arquivo já existe, deseja substituir?','SIM','NÃO','ATENCÃO','CARREGAR','CANCELAR','ROM não localizado','com oarquivo',
       'Reset','Executar emulação','Pausar emulação','Velocidade emulação 25%, 50%, 75% o 100%','Velocidade máxima','Configurar DSP','Configurar ordenador/consola',
       'Carregar Cinta/Snapshot','Carregar Disco','Guardar Snapshot','Poke Memoria','Guardar imagen','FlashLoad ON/OFF','Executar cassette virtual','Parar cassette virtual',
       'Encerrar cassette virtual','Nome cassette virtual','Conteudo do cassette virtual','Configurar dipswitch','Lista de jogos','Configuração','Arquivo não encontrado','Carregar Jogo',
       'Executar o último jogo na inicialização','Mostrar erros de ROMs','Tela principal central','CONSOLES: Mostra o menu de carregamento do jogo na inicialização','Ativado','Abrir','Pasta'),
       //Italiano
      ('File','Lingua','Elenco di ROMS','Esci','Informazioni...','Opzioni','Suono','Video','Disabilitato','Piattaforma','Computer a 8bit','Salagiochi','Console','Controllo',
       'Esegui','Riavvia','Sospendi','Nome','Dimensione','Intestazione','Byte','Dati','Turbo Byte','Impulsi semplici','Sequenza a impulsi','Dati semplici','Registrazione diretta',
       'Ferma la cassetta','Pausa','Gruppo','Salta a','Loop','Loop fine','Ferma se Spectrum 48K','Testo','Messaggio','Informazioni sul file','Informazioni sull''Hardware',
       'Velocita','Byte caricati','Cassetta virtuale','Nome de la cassetta','File gia esistente. Vuoi sovrascriverlo?','SI','NO','ATTENZIONE','CARICA','ANNULLA','File della ROM non trovati',
       'dentro il file','Riavvia','Esegui l''emulazione','Sospendi l''emulazione','Velocita dell''emulazione: 25%, 50%, 75% or 100%','Piu veloce possibile','Configura DSP',
       'Configurare computer/console','Carica una cassetta o uno Snapshot','Carica un Disco','Salva uno Snapshot','Poke Memory','Salva immagine','FlashLoad ON/OFF','Avvia la cassetta virtuale',
       'Ferma la cassetta virtuale','Chiudi la cassetta virtuale','Nome di la cassetta virtuale','Contenuto del cassetta virtuale','Configurare dipswitch','Lista dei giochi',
       'Configurazione','File non trovato','Caricare il Gioco','Esegui l''ultimo gioco all''avvio','Mostra errori ROM','Schermata principale centrale','CONSOLE: mostra il menu di caricamento del gioco all''avvio',
       'Abilitato','Aprire','Cartella'));

type
      tlenguaje=record
          archivo:array[0..5] of string;
          opciones:array[0..6] of string;
          maquina:array[0..4] of string;
          accion:array[0..4] of string;
          cinta:array[0..18] of string;
          errores:array[0..2] of string;
          avisos:array[0..5] of string;
          mensajes:array[0..9] of string;
          varios:array[0..6] of string;
          hints:array[0..20] of string;
      end;

var
  leng:tlenguaje;

procedure cambiar_idioma(idioma:byte);

implementation
uses principal;

procedure leer_idioma(idioma:byte);
begin
  //archivo
  leng.archivo[0]:=lng_txt[idioma,0];
  leng.archivo[1]:=lng_txt[idioma,1];
  leng.archivo[2]:=lng_txt[idioma,3];
  leng.archivo[3]:=lng_txt[idioma,4];
  leng.archivo[4]:=lng_txt[idioma,2];
  leng.archivo[5]:=lng_txt[idioma,78];
  //opciones
  leng.opciones[0]:=lng_txt[idioma,5];
  leng.opciones[1]:=lng_txt[idioma,6];
  leng.opciones[2]:=lng_txt[idioma,7];
  leng.opciones[3]:=lng_txt[idioma,8];
  leng.opciones[4]:=lng_txt[idioma,70]; //Configuracion
  leng.opciones[5]:=lng_txt[idioma,77];
  leng.opciones[6]:=lng_txt[idioma,79];
  //maquina
  leng.maquina[0]:=lng_txt[idioma,9];
  leng.maquina[1]:=lng_txt[idioma,10];
  leng.maquina[2]:=lng_txt[idioma,11];
  leng.maquina[3]:=lng_txt[idioma,12];
  //accion
  leng.accion[0]:=lng_txt[idioma,13];
  leng.accion[1]:=lng_txt[idioma,14];
  leng.accion[2]:=lng_txt[idioma,15];
  leng.accion[3]:=lng_txt[idioma,16];
  //varios
  leng.varios[0]:=lng_txt[idioma,17];
  leng.varios[1]:=lng_txt[idioma,18];
  leng.varios[2]:=lng_txt[idioma,73];
  leng.varios[3]:=lng_txt[idioma,74];
  leng.varios[4]:=lng_txt[idioma,75];
  leng.varios[5]:=lng_txt[idioma,76];
  //cinta
  leng.cinta[0]:=lng_txt[idioma,19];
  leng.cinta[1]:=lng_txt[idioma,20];
  leng.cinta[2]:=lng_txt[idioma,21];
  leng.cinta[3]:=lng_txt[idioma,22];
  leng.cinta[4]:=lng_txt[idioma,23];
  leng.cinta[5]:=lng_txt[idioma,24];
  leng.cinta[6]:=lng_txt[idioma,25];
  leng.cinta[7]:=lng_txt[idioma,26];
  leng.cinta[8]:=lng_txt[idioma,27];
  leng.cinta[9]:=lng_txt[idioma,28];
  leng.cinta[10]:=lng_txt[idioma,29];
  leng.cinta[11]:=lng_txt[idioma,30];
  leng.cinta[12]:=lng_txt[idioma,31];
  leng.cinta[13]:=lng_txt[idioma,32];
  leng.cinta[14]:=lng_txt[idioma,33];
  leng.cinta[15]:=lng_txt[idioma,34];
  leng.cinta[16]:=lng_txt[idioma,35];
  leng.cinta[17]:=lng_txt[idioma,36];
  leng.cinta[18]:=lng_txt[idioma,37];
  //mensajes
  leng.mensajes[0]:=lng_txt[idioma,38];
  leng.mensajes[1]:=lng_txt[idioma,39];
  leng.mensajes[2]:=lng_txt[idioma,40];
  leng.mensajes[3]:=lng_txt[idioma,42]; //sobreescribir
  leng.mensajes[4]:=lng_txt[idioma,43]; //si
  leng.mensajes[5]:=lng_txt[idioma,44]; //no
  leng.mensajes[6]:=lng_txt[idioma,45]; //atencion
  leng.mensajes[7]:=lng_txt[idioma,46]; //cargar
  leng.mensajes[8]:=lng_txt[idioma,47]; //cancelar
  leng.mensajes[9]:=lng_txt[idioma,41]; //nombre cinta virtual
  //errores
  leng.errores[0]:=lng_txt[idioma,48]; //ERROR: No se puede encontrar la ROM
  leng.errores[1]:=lng_txt[idioma,49]; //dentro del fichero
  leng.errores[2]:=lng_txt[idioma,71]; //Fichero no existe
  //hints
  leng.hints[0]:=lng_txt[idioma,50]; //Reset
  leng.hints[1]:=lng_txt[idioma,51]; //Ejecutar emulacion
  leng.hints[2]:=lng_txt[idioma,52]; //Pausar emulacion
  leng.hints[3]:=lng_txt[idioma,53]; //Velocidad emulacion 25%, 50%, 75% o 100%
  leng.hints[4]:=lng_txt[idioma,54]; //Velocidad maxima
  leng.hints[5]:=lng_txt[idioma,55]; //Configurar DSP
  leng.hints[6]:=lng_txt[idioma,56]; //Configurar ordenador/consola
  leng.hints[7]:=lng_txt[idioma,57]; //Cargar Cinta/Snapshot
  leng.hints[8]:=lng_txt[idioma,58]; //Cargar Disco
  leng.hints[9]:=lng_txt[idioma,59]; //Guardar Snapshot
  leng.hints[10]:=lng_txt[idioma,60]; //Poke Memoria
  leng.hints[11]:=lng_txt[idioma,61]; //Guardar Imagen
  leng.hints[12]:=lng_txt[idioma,62]; //FlashLoad ON/OFF
  leng.hints[13]:=lng_txt[idioma,63]; //Play cassette virtual
  leng.hints[14]:=lng_txt[idioma,64]; //Stop cassette virtual
  leng.hints[15]:=lng_txt[idioma,65]; //Cerrar cassette virtual
  leng.hints[16]:=lng_txt[idioma,66]; //Nombre cassette virtual
  leng.hints[17]:=lng_txt[idioma,67]; //Contenido del cassette virtual
  leng.hints[18]:=lng_txt[idioma,68]; //Configurar dipswitch
  leng.hints[19]:=lng_txt[idioma,69]; //Mostrar lista
  leng.hints[20]:=lng_txt[idioma,72]; //Cargar juego
end;

function buscar_idioma:byte;
var
  {$ifdef windows}
  LangID:word;
  {$else}
  {$IFDEF Darwin}
  theLocaleRef:CFLocaleRef;
  locale:CFStringRef;
  buffer:StringPtr;
  bufferSize:CFIndex;
  encoding:CFStringEncoding;
  success:boolean;
  {$endif}
  fbl:string;
  {$ENDIF}
begin
{$ifdef windows}
LangID:=GetUserDefaultLangID;
case Byte(LangID and $03ff) of
  LANG_SPANISH:buscar_idioma:=0;
  LANG_CATALAN:buscar_idioma:=2;
  LANG_FRENCH:buscar_idioma:=3;
  LANG_DUTCH:buscar_idioma:=4;
  LANG_PORTUGUESE:buscar_idioma:=5;
  LANG_ITALIAN:buscar_idioma:=6;
  else {LANG_ENGLISH}buscar_idioma:=1;
end;
{$endif}
{$IFDEF UNIX}
  fbl:='';
  fbl:=Copy(GetEnvironmentVariable('LC_CTYPE'),1,2);
  if fbl='' then fbl:=Copy(GetEnvironmentVariable('LANG'),1,2);
{$endif}
{$IFDEF Darwin}
  theLocaleRef:=CFLocaleCopyCurrent;
  locale:=FLocaleGetIdentifier(theLocaleRef);
  encoding:=0;
  bufferSize:=256;
  buffer:=new(StringPtr);
  success:=CFStringGetPascalString(locale,buffer,bufferSize,encoding);
  if success then l:=string(buffer^)
    else l:='';
  fbl:=Copy(l,1,2);
  dispose(buffer);
{$endif}
{$ifndef windows}
buscar_idioma:=1;
if fbl='es' then buscar_idioma:=0
  else if fbl='fr' then buscar_idioma:=3
    else if fbl='gr' then buscar_idioma:=4
      else if fbl='pt' then buscar_idioma:=5
        else if fbl='it' then buscar_idioma:=6;
{$endif}
end;

procedure cambiar_idioma(idioma:byte);
begin
principal1.Castellano1.Checked:=false;
principal1.Ingles1.Checked:=false;
principal1.Catalan1.Checked:=false;
principal1.French1.Checked:=false;
principal1.German1.Checked:=false;
principal1.Brazil1.Checked:=false;
principal1.italiano1.checked:=false;
principal1.Auto1.Checked:=false;
case idioma of
  0:principal1.Castellano1.Checked:=true;
  1:principal1.Ingles1.Checked:=true;
  2:principal1.Catalan1.Checked:=true;
  3:principal1.French1.Checked:=true;
  4:principal1.German1.Checked:=true;
  5:principal1.Brazil1.Checked:=true;
  6:principal1.italiano1.Checked:=true;
  200:principal1.Auto1.Checked:=true;
end;
if idioma=200 then idioma:=buscar_idioma;
leer_idioma(idioma);
//Archivo
principal1.archivo1.caption:=leng.archivo[0];
principal1.idioma1.caption:=leng.archivo[1];
principal1.LstRoms.caption:=leng.archivo[4];
principal1.salir1.caption:=leng.archivo[2];
principal1.acercade1.caption:=leng.archivo[3];
//Opciones
principal1.opciones1.caption:=leng.opciones[0];
principal1.audio1.caption:=leng.opciones[1];
principal1.video1.caption:=leng.opciones[2];
principal1.sinsonido1.caption:=leng.opciones[3];
principal1.configuracion1.caption:=leng.opciones[4];
principal1.consonido1.caption:=leng.opciones[5];
//Maquina
principal1.emulacion1.caption:=leng.maquina[0];
principal1.ordenadores8bits1.caption:=leng.maquina[1];
principal1.arcade1.caption:=leng.maquina[2];
principal1.consolas1.caption:=leng.maquina[3];
//Accion
principal1.uprocesador1.caption:=leng.accion[0];
principal1.ejecutar1.caption:=leng.accion[1];
principal1.reset1.caption:=leng.accion[2];
principal1.pausa1.caption:=leng.accion[3];
//Hints
principal1.BitBtn2.Hint:=leng.hints[0];
principal1.BitBtn3.Hint:=leng.hints[2];
principal1.BitBtn5.Hint:=leng.hints[3];
principal1.BitBtn6.Hint:=leng.hints[4];
principal1.btncfg.Hint:=leng.hints[5];
principal1.bitbtn19.Hint:=leng.hints[11];
principal1.BitBtn8.Hint:=leng.hints[18];
principal1.BitBtn13.Hint:=leng.hints[19];
principal1.BitBtn1.Hint:=leng.hints[6];
principal1.BitBtn9.Hint:=leng.hints[7];
principal1.BitBtn10.Hint:=leng.hints[8];
principal1.BitBtn11.Hint:=leng.hints[9];
principal1.BitBtn12.Hint:=leng.hints[10];
principal1.BitBtn14.Hint:=leng.hints[12];
end;

end.
