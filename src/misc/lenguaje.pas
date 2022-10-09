unit lenguaje;

interface
{$ifndef windows}uses LCLType;{$endif}

const
      MAX_IDIOMAS=7-1;
      lng_txt:array[0..MAX_IDIOMAS,0..77] of string=(
      //Español
      ('Archivo','Idioma','Lista de ROMS','Salir','Acerca de...','Opciones','Sonido','Video','Desconectado','Máquina','Ordenadores 8bits','Arcade',
       'Consolas','Acción','Ejecutar','Reiniciar','Pausa','Nombre','Longitud','Cabecera','Bytes','Datos','Bytes Turbo','Tono Puro','Secuencia Pulsos',
       'Datos Puros','Grabación Directa','Para la cinta','Pausa','Grupo','Saltar a posición','Bucle','Fin de Bucle','Para si Spectrum 48K','Texto',
       'Mensaje','Información Archivo','Información Hardware','Velocidad','Bytes Cargados','Cinta Virtual','Nombre de la Cinta','El fichero ya existe. ¿Sobrescribir?',
       'SI','NO','ATENCIÓN','CARGAR','CANCELAR','No se puede encontrar la ROM','dentro del fichero','Reset','Ejecutar emulación','Pausar emulación','Velocidad emulación 25%, 50%, 75% o 100%',
       'Velocidad máxima','Configurar DSP','Configurar ordenador/consola','Cargar Cinta/Snapshot','Cargar Disco','Guardar Snapshot','Poke Memoria','Capturar Imagen',
       'FlashLoad ON/OFF','Play cassette virtual','Stop cassette virtual','Cerrar cassette virtual','Nombre cassette virtual','Contenido del cassette virtual','Configurar dipswitch',
       'Mostrar lista de juegos','Configuración','Fichero no encontrado','Cargar Juego','Ejecutar el último juego al inicio','Mostrar errores de las ROMS','Centrar pantalla principal',
       'CONSOLAS: Mostrar menú de carga de juegos al inicio','Conectado'),
       //English
      ('File','Language','ROMS list','Exit','About...','Options','Sound','Video','Disabled','Machine','8bits Computers','Arcade','Consoles','Action','Run',
       'Reset','Pause','Name','Size','Header','Bytes','Data','Turbo Bytes','Pure Tone','Pulse Sequence','Pure Data','Direct Recording','Stop the tape','Pause',
       'Group','Jump To','Loop','Loop end','Stop if Spectrum 48K','Text','Message','File Info','Hardware Info','Speed','Loaded Bytes','Virtual Tape','Tape Name',
       'File already exists. Overwrite?','YES','NO','WARNING','LOAD','CANCEL','Can not find ROM file','inside file','Reset','Run emulation','Pause emulation',
       'Emulation speed: 25%, 50%, 75% or 100%','Fastest speed','Configure DSP','Configure computer/console','Load Tape/Snapshot','Load Disk','Save Snapshot',
       'Poke Memory','Take Snapshot','FlashLoad ON/OFF','Play virtual tape','Stop virtual tape','Close virtual tape','Virtual tape name','Virtual tape content',
       'Configure dipswitch','Show game list','Configuration','File not found','Load Game','Run last game at startup','Show ROMs errors','Center main screen',
       'CONSOLES: Show game loading menu at startup','Enabled'),
       //Català
      ('Arxiu','Idioma','Llista de ROMS','Sortida','Acerca de...','Opcions','So','Video','Desconectat','Màquina','Ordinadors 8bits','Arcade','Consolas',
       'Acció','Executar','Reiniciar','Pausa','Nom','Longitud','Capçalera','Bytes','Dades','Bytes Turbo','To Pur','Seqüència Pulsos','Dades Purs','Gravació Directa',
       'Para la cinta','Pausa','Grup','Saltar a posició','Bucle','Fi de Bucle','Para si Spectrum 48K','Text','Missatge','Informació Arxiu','Informació Hardware','Velocitat',
       'Bytes Carregats','Cinta Virtual','Nom de la Cinta','El fitxer ja existeix. Sobreescriure?','SI','NO','ATENCIO','CARREGAR','CANCEL·LAR','No es pot trobar la ROM',
       'dintre del fitxer','Reset','Executar emulació','Pausar emulació','Velocitat de la emulació: 25%, 50%, 75% o 100%','Velocitat máxima','Configurar DSP',
       'Configurar ordinador/consola','Carregar Cinta/Snapshot','Carregar Disc','Guardar Snapshot','Poke Memoria','Guardar imatge','FlashLoad ON/OFF','Play cassette virtual',
       'Stop cassette virtual','Tancar el cassette virtual','Nom del cassette virtual','Contigut del cassette virtual','Configurar dipswitch','Mostrar la llista de jocs',
       'Configuració','No es troba el fitxer','Carregar Joc','Carregar l''ultim joc a l''inici','Mostrar errors en les ROMs','Centrar la pantalla principal',
       'CONSOLES: Mostra menú de càrrega de jocs a l''inici','Conectat'),
       //French
      ('Fichier','Langage','Liste de ROMS','Quitter','A propos de ...','Options','Du Son','Vidéo','Désactivé','Machine','Ordinateurs 8 bits','Arcade','Consoles',
       'Action','Exécuter','Reset','Pause','Nom','Taille','Entête','Octets','Données','Turbo Bytes','Tonalité pure','Séquence pulsée','Données pures','Enregistrement direct',
       'Arreter la cassette','Pause','Groupe','Aller à','Boucle','Fin de boucle','Arrêter si Spectrum 48K','Texte','Message','Informations fichier','Information matérielle',
       'Vitesse','Octets chargés','Cassette','Nom del Cassette','Fichier existant. Ecraser?','OUI','NON','ATTENTION','CHARGER','ANNULER','Fichier ROM introuvable',
       'dintre ou fichier','Reset','Démarrer l''émulation','Pause l''émulation','Vitesse d''émulation: 25%, 50%, 75% or 100%','Citesse la plus rapide','Configurer DSP',
       'Configurer l''ordinateur/console','Charge Tape/Snapshot','Charge Disk','Enregistrer Snapshot','Poke Memory','Enregistrer l''image','FlashLoad ON/OFF',
       'Lancer la cassette virtuelle','Arrêter la cassette virtuelle','Fermer la cassette virtuelle','Nom cassette virtuelle','Contenu cassette virtuelle',
       'Configurer dipswitch','Liste de jeux','Configuration','Fichier non trouvé','Chargement du Jeu','Lancer le dernier jeu au démarrage','afficher les erreurs de ROM',
       'Écran principal central','CONSOLES: Afficher le menu de chargement du jeu au démarrage','Activé'),
       //German
      ('Datei','Sprache','ROMS Liste','Beenden','Über...','Optionen','Klang','Video','Deaktiviert','Maschine','8-Bit-Computer','Spielhallenmaschinen','Konsolen',
       'Aktion','Laufen','Zurücksetzen','Pause','Name','Größe','Kopf','Bytes','Daten','Turbo-Bytes','Pure Tone','Pulssequenz','Pure Data','Direktaufnahme',
       'Band Stoppen','Pause','Gruppe','Springe zu','Schleife','Schleifenende','Stoppen wenn Spectrum 48K','Text','Nachricht','Datei-Informationen','Hardware-Informationen',
       'Geschwindigkeit','Geladene Bytes','Virtuelles Band','Band-Name','Datei existiert bereits. Überschreiben?','JA','NEIN','WARNUNG','LADE','ABBRUCH','Kann ROM-Datei nicht finden',
       'oder Datei','Zurücksetzen','Emulation laufenlassen','Emulation anhalten','Emulationsgeschwindigkeit: 25%, 50%, 75% or 100%','Schnellste Geschwindigkeit',
       'DSP konfigurieren','Konfigurieren Computer/Konsole','Lade Band/Schnappschuß','Lade Diskette','Speichere Schnappschuß','Speicher-Poke','Bild speichern',
       'TAP nach TZX konvertieren','Virtuelles Band abspielen','Virtuelles Band stoppen','Virtuelles Band schließen','Name des virtuellen Bands','Inhalt des virtuellen Bands',
       'Konfigurieren dipswitch','Spielliste','Konfiguration','Die Datei wurde nicht gefunden','Spiel laden','Letztes Spiel beim Start ausführen','ROM-Fehler anzeigen',
       'Hauptbildschirm zentrieren','KONSOLEN: Spiellademenü beim Start anzeigen','Aktiviert'),
       //Brazil
      ('Arquivo','Indioma','Lista de ROMS','Salir','Sobre...','Opções','Som','Video','Desativado','Máquina','Ordenadores 8bits','Arcade','Consoles','Ação','Executar',
       'Reiniciar','Pausar','Nome','Longitude','Cabeça','Bytes','Dados','Bytes Turbo','Tone Puro','Sequencía Pulsos','Dados Pulos','Gravação Direta','Para a tela',
       'Pausa','Grupo','Saltar a posição','Bucle','Fim de Bucle','Para o Spectrum 48K','Texto','Mensagem','Informação do Arquivo','Informação Hardware','Velocidade',
       'Bytes Carregados','Tela','Nome de la Cinta','O arquivo já existe, deseja substituir?','SIM','NÃO','ATENCÃO','CARREGAR','CANCELAR','ROM não localizado','com oarquivo',
       'Reset','Executar emulação','Pausar emulação','Velocidade emulação 25%, 50%, 75% o 100%','Velocidade máxima','Configurar DSP','Configurar ordenador/consola',
       'Carregar Cinta/Snapshot','Carregar Disco','Guardar Snapshot','Poke Memoria','Guardar imagen','FlashLoad ON/OFF','Executar cassette virtual','Parar cassette virtual',
       'Encerrar cassette virtual','Nome cassette virtual','Conteudo do cassette virtual','Configurar dipswitch','Lista de jogos','Configuração','Arquivo não encontrado','Carregar Jogo',
       'executar o último jogo na inicialização','mostrar erros de ROMs','Tela principal central','CONSOLES: Mostra o menu de carregamento do jogo na inicialização','Ativado'),
       //Italiano
      ('File','Lingua','Elenco di ROMS','Esci','Informazioni...','Opzioni','Suono','Video','Disabilitato','Piattaforma','Computer a 8bit','Salagiochi','Console','Controllo',
       'Esegui','Riavvia','Sospendi','Nome','Dimensione','Intestazione','Byte','Dati','Turbo Byte','Impulsi semplici','Sequenza a impulsi','Dati semplici','Registrazione diretta',
       'Ferma la cassetta','Pausa','Gruppo','Salta a','Loop','Loop fine','Ferma se Spectrum 48K','Testo','Messaggio','Informazioni sul file','Informazioni sull''Hardware',
       'Velocita','Byte caricati','Cassetta virtuale','Nome de la cassetta','File gia esistente. Vuoi sovrascriverlo?','SI','NO','ATTENZIONE','CARICA','ANNULLA','File della ROM non trovati',
       'dentro il file','Riavvia','Esegui l''emulazione','Sospendi l''emulazione','Velocita dell''emulazione: 25%, 50%, 75% or 100%','Piu veloce possibile','Configura DSP',
       'Configurare computer/console','Carica una cassetta o uno Snapshot','Carica un Disco','Salva uno Snapshot','Poke Memory','Salva immagine','FlashLoad ON/OFF','Avvia la cassetta virtuale',
       'Ferma la cassetta virtuale','Chiudi la cassetta virtuale','Nome di la cassetta virtuale','Contenuto del cassetta virtuale','Configurare dipswitch','Lista dei giochi',
       'Configurazione','File non trovato','Caricare il Gioco','Esegui l''ultimo gioco all''avvio','Mostra errori ROM','Schermata principale centrale','CONSOLE: mostra il menu di caricamento del gioco all''avvio',
       'Abilitato'));

type
      tlenguaje=record
          archivo:array[0..4] of string;
          opciones:array[0..5] of string;
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
  leng:array[0..MAX_IDIOMAS] of tlenguaje;

procedure leer_idioma;
procedure cambiar_idioma(idioma:byte);

implementation
uses principal;

procedure cambiar_idioma(idioma:byte);
begin
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
principal1.consonido1.caption:=leng[idioma].opciones[5];
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

procedure leer_idioma;
var
  f:byte;
begin
for f:=0 to MAX_IDIOMAS do begin
  //archivo
  leng[f].archivo[0]:=lng_txt[f,0];
  leng[f].archivo[1]:=lng_txt[f,1];
  leng[f].archivo[4]:=lng_txt[f,2];
  leng[f].archivo[2]:=lng_txt[f,3];
  leng[f].archivo[3]:=lng_txt[f,4];
  //opciones
  leng[f].opciones[0]:=lng_txt[f,5];
  leng[f].opciones[1]:=lng_txt[f,6];
  leng[f].opciones[2]:=lng_txt[f,7];
  leng[f].opciones[3]:=lng_txt[f,8];
  leng[f].opciones[5]:=lng_txt[f,77];
  //maquina
  leng[f].maquina[0]:=lng_txt[f,9];
  leng[f].maquina[1]:=lng_txt[f,10];
  leng[f].maquina[2]:=lng_txt[f,11];
  leng[f].maquina[3]:=lng_txt[f,12];
  //accion
  leng[f].accion[0]:=lng_txt[f,13];
  leng[f].accion[1]:=lng_txt[f,14];
  leng[f].accion[2]:=lng_txt[f,15];
  leng[f].accion[3]:=lng_txt[f,16];
  //varios
  leng[f].varios[0]:=lng_txt[f,17];
  leng[f].varios[1]:=lng_txt[f,18];
  leng[f].varios[2]:=lng_txt[f,73];
  leng[f].varios[3]:=lng_txt[f,74];
  leng[f].varios[4]:=lng_txt[f,75];
  leng[f].varios[5]:=lng_txt[f,76];
  //cinta
  leng[f].cinta[0]:=lng_txt[f,19];
  leng[f].cinta[1]:=lng_txt[f,20];
  leng[f].cinta[2]:=lng_txt[f,21];
  leng[f].cinta[3]:=lng_txt[f,22];
  leng[f].cinta[4]:=lng_txt[f,23];
  leng[f].cinta[5]:=lng_txt[f,24];
  leng[f].cinta[6]:=lng_txt[f,25];
  leng[f].cinta[7]:=lng_txt[f,26];
  leng[f].cinta[8]:=lng_txt[f,27];
  leng[f].cinta[9]:=lng_txt[f,28];
  leng[f].cinta[10]:=lng_txt[f,29];
  leng[f].cinta[11]:=lng_txt[f,30];
  leng[f].cinta[12]:=lng_txt[f,31];
  leng[f].cinta[13]:=lng_txt[f,32];
  leng[f].cinta[14]:=lng_txt[f,33];
  leng[f].cinta[15]:=lng_txt[f,34];
  leng[f].cinta[16]:=lng_txt[f,35];
  leng[f].cinta[17]:=lng_txt[f,36];
  leng[f].cinta[18]:=lng_txt[f,37];
  //mensajes
  leng[f].mensajes[0]:=lng_txt[f,38];
  leng[f].mensajes[1]:=lng_txt[f,39];
  leng[f].mensajes[2]:=lng_txt[f,40];
  leng[f].mensajes[9]:=lng_txt[f,41]; //nombre cinta virtual
  leng[f].mensajes[3]:=lng_txt[f,42]; //sobreescribir
  leng[f].mensajes[4]:=lng_txt[f,43]; //si
  leng[f].mensajes[5]:=lng_txt[f,44]; //no
  leng[f].mensajes[6]:=lng_txt[f,45]; //atencion
  leng[f].mensajes[7]:=lng_txt[f,46]; //cargar
  leng[f].mensajes[8]:=lng_txt[f,47]; //cancelar
  //errores
  leng[f].errores[0]:=lng_txt[f,48]; //ERROR: No se puede encontrar la ROM
  leng[f].errores[1]:=lng_txt[f,49]; //dentro del fichero
  //hints
  leng[f].hints[0]:=lng_txt[f,50]; //Reset
  leng[f].hints[1]:=lng_txt[f,51]; //Ejecutar emulacion
  leng[f].hints[2]:=lng_txt[f,52]; //Pausar emulacion
  leng[f].hints[3]:=lng_txt[f,53]; //Velocidad emulacion 25%, 50%, 75% o 100%
  leng[f].hints[4]:=lng_txt[f,54]; //Velocidad maxima
  leng[f].hints[5]:=lng_txt[f,55]; //Configurar DSP
  leng[f].hints[6]:=lng_txt[f,56]; //Configurar ordenador/consola
  leng[f].hints[7]:=lng_txt[f,57]; //Cargar Cinta/Snapshot
  leng[f].hints[8]:=lng_txt[f,58]; //Cargar Disco
  leng[f].hints[9]:=lng_txt[f,59]; //Guardar Snapshot
  leng[f].hints[10]:=lng_txt[f,60]; //Poke Memoria
  leng[f].hints[11]:=lng_txt[f,61]; //Guardar Imagen
  leng[f].hints[12]:=lng_txt[f,62]; //FlashLoad ON/OFF
  leng[f].hints[13]:=lng_txt[f,63]; //Play cassette virtual
  leng[f].hints[14]:=lng_txt[f,64]; //Stop cassette virtual
  leng[f].hints[15]:=lng_txt[f,65]; //Cerrar cassette virtual
  leng[f].hints[16]:=lng_txt[f,66]; //Nombre cassette virtual
  leng[f].hints[17]:=lng_txt[f,67]; //Contenido del cassette virtual
  leng[f].hints[18]:=lng_txt[f,68]; //Configurar dipswitch
  leng[f].hints[19]:=lng_txt[f,69]; //Mostrar lista
  leng[f].hints[20]:=lng_txt[f,72]; //Cargar juego
  //Nuevos...
  leng[f].opciones[4]:=lng_txt[f,70]; //Configuracion
  leng[f].errores[2]:=lng_txt[f,71]; //Fichero no existe
end;
end;

end.
