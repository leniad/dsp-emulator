unit super_cassette_vision;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     upd7810,lenguaje,main_engine,controls_engine,sysutils,dialogs,
     rom_engine,misc_functions,sound_engine,file_engine;

procedure cargar_scv;

implementation
uses snapshot,principal;

const
  scv_bios:array[0..1] of tipo_roms=(
    (n:'upd7801g.s01';l:$1000;p:0;crc:$7ac06182),(n:'epochtv.chr';l:$400;p:$1000;crc:$db521533));

var
  rom:array[0..$fff] of byte;
  chars:array[0..$3ff] of byte;
  porta_val,portc_val:byte;
  cartucho_load:boolean=false;

procedure eventos_coleco;
begin
{if event.keyboard then begin
   //P1
   if keyboard[KEYBOARD_0] then tcoleco.keypad[0]:=(tcoleco.keypad[0] and $fffe) else tcoleco.keypad[0]:=(tcoleco.keypad[0] or $0001);
   if keyboard[KEYBOARD_1] then tcoleco.keypad[0]:=(tcoleco.keypad[0] and $fffd) else tcoleco.keypad[0]:=(tcoleco.keypad[0] or $0002);
   if keyboard[KEYBOARD_2] then tcoleco.keypad[0]:=(tcoleco.keypad[0] and $fffb) else tcoleco.keypad[0]:=(tcoleco.keypad[0] or $0004);
   if keyboard[KEYBOARD_3] then tcoleco.keypad[0]:=(tcoleco.keypad[0] and $fff7) else tcoleco.keypad[0]:=(tcoleco.keypad[0] or $0008);
   if keyboard[KEYBOARD_4] then tcoleco.keypad[0]:=(tcoleco.keypad[0] and $ffef) else tcoleco.keypad[0]:=(tcoleco.keypad[0] or $0010);
   if keyboard[KEYBOARD_5] then tcoleco.keypad[0]:=(tcoleco.keypad[0] and $ffdf) else tcoleco.keypad[0]:=(tcoleco.keypad[0] or $0020);
   if keyboard[KEYBOARD_6] then tcoleco.keypad[0]:=(tcoleco.keypad[0] and $ffbf) else tcoleco.keypad[0]:=(tcoleco.keypad[0] or $0040);
   if keyboard[KEYBOARD_7] then tcoleco.keypad[0]:=(tcoleco.keypad[0] and $ff7f) else tcoleco.keypad[0]:=(tcoleco.keypad[0] or $0080);
   if keyboard[KEYBOARD_8] then tcoleco.keypad[0]:=(tcoleco.keypad[0] and $feff) else tcoleco.keypad[0]:=(tcoleco.keypad[0] or $0100);
   if keyboard[KEYBOARD_9] then tcoleco.keypad[0]:=(tcoleco.keypad[0] and $fdff) else tcoleco.keypad[0]:=(tcoleco.keypad[0] or $0200);
   if keyboard[KEYBOARD_A] then tcoleco.keypad[0]:=(tcoleco.keypad[0] and $fbff) else tcoleco.keypad[0]:=(tcoleco.keypad[0] or $0400);
   if keyboard[KEYBOARD_S] then tcoleco.keypad[0]:=(tcoleco.keypad[0] and $f7ff) else tcoleco.keypad[0]:=(tcoleco.keypad[0] or $0800);
   //P2
   if keyboard[KEYBOARD_P] then tcoleco.keypad[1]:=(tcoleco.keypad[1] and $fffe) else tcoleco.keypad[1]:=(tcoleco.keypad[1] or $0001);
   if keyboard[KEYBOARD_Q] then tcoleco.keypad[1]:=(tcoleco.keypad[1] and $fffd) else tcoleco.keypad[1]:=(tcoleco.keypad[1] or $0002);
   if keyboard[KEYBOARD_W] then tcoleco.keypad[1]:=(tcoleco.keypad[1] and $fffb) else tcoleco.keypad[1]:=(tcoleco.keypad[1] or $0004);
   if keyboard[KEYBOARD_E] then tcoleco.keypad[1]:=(tcoleco.keypad[1] and $fff7) else tcoleco.keypad[1]:=(tcoleco.keypad[1] or $0008);
   if keyboard[KEYBOARD_R] then tcoleco.keypad[1]:=(tcoleco.keypad[1] and $ffef) else tcoleco.keypad[1]:=(tcoleco.keypad[1] or $0010);
   if keyboard[KEYBOARD_T] then tcoleco.keypad[1]:=(tcoleco.keypad[1] and $ffdf) else tcoleco.keypad[1]:=(tcoleco.keypad[1] or $0020);
   if keyboard[KEYBOARD_Y] then tcoleco.keypad[1]:=(tcoleco.keypad[1] and $ffbf) else tcoleco.keypad[1]:=(tcoleco.keypad[1] or $0040);
   if keyboard[KEYBOARD_U] then tcoleco.keypad[1]:=(tcoleco.keypad[1] and $ff7f) else tcoleco.keypad[1]:=(tcoleco.keypad[1] or $0080);
   if keyboard[KEYBOARD_I] then tcoleco.keypad[1]:=(tcoleco.keypad[1] and $feff) else tcoleco.keypad[1]:=(tcoleco.keypad[1] or $0100);
   if keyboard[KEYBOARD_O] then tcoleco.keypad[1]:=(tcoleco.keypad[1] and $fdff) else tcoleco.keypad[1]:=(tcoleco.keypad[1] or $0200);
   if keyboard[KEYBOARD_Z] then tcoleco.keypad[1]:=(tcoleco.keypad[1] and $fbff) else tcoleco.keypad[1]:=(tcoleco.keypad[1] or $0400);
   if keyboard[KEYBOARD_X] then tcoleco.keypad[1]:=(tcoleco.keypad[1] and $f7ff) else tcoleco.keypad[1]:=(tcoleco.keypad[1] or $0800);
end;
if event.arcade then begin
   //P1
   if arcade_input.up[0] then tcoleco.joystick[0]:=(tcoleco.joystick[0] and $fe) else tcoleco.joystick[0]:=(tcoleco.joystick[0] or 1);
   if arcade_input.right[0] then tcoleco.joystick[0]:=(tcoleco.joystick[0] and $fd) else tcoleco.joystick[0]:=(tcoleco.joystick[0] or 2);
   if arcade_input.down[0] then tcoleco.joystick[0]:=(tcoleco.joystick[0] and $fb) else tcoleco.joystick[0]:=(tcoleco.joystick[0] or 4);
   if arcade_input.left[0] then tcoleco.joystick[0]:=(tcoleco.joystick[0] and $f7) else tcoleco.joystick[0]:=(tcoleco.joystick[0] or 8);
   if arcade_input.but0[0] then tcoleco.joystick[0]:=(tcoleco.joystick[0] and $bf) else tcoleco.joystick[0]:=(tcoleco.joystick[0] or $40);
   if arcade_input.but1[0] then tcoleco.keypad[0]:=(tcoleco.keypad[0] and $bfff) else tcoleco.keypad[0]:=(tcoleco.keypad[0] or $4000);
   //P2
   if arcade_input.up[1] then tcoleco.joystick[1]:=(tcoleco.joystick[1] and $fe) else tcoleco.joystick[1]:=(tcoleco.joystick[1] or 1);
   if arcade_input.right[1] then tcoleco.joystick[1]:=(tcoleco.joystick[1] and $fd) else tcoleco.joystick[1]:=(tcoleco.joystick[1] or 2);
   if arcade_input.down[1] then tcoleco.joystick[1]:=(tcoleco.joystick[1] and $fb) else tcoleco.joystick[1]:=(tcoleco.joystick[1] or 4);
   if arcade_input.left[1] then tcoleco.joystick[1]:=(tcoleco.joystick[1] and $f7) else tcoleco.joystick[1]:=(tcoleco.joystick[1] or 8);
   if arcade_input.but0[1] then tcoleco.joystick[1]:=(tcoleco.joystick[1] and $bf) else tcoleco.joystick[1]:=(tcoleco.joystick[1] or $40);
   if arcade_input.but1[1] then tcoleco.keypad[1]:=(tcoleco.keypad[1] and $bfff) else tcoleco.keypad[1]:=(tcoleco.keypad[1] or $4000);
end; }
end;

procedure update_video;
begin
end;

procedure scv_principal;
var
  frame:single;
  f:word;
begin
init_controls(false,true,true,false);
frame:=upd7810_0.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to 261 do begin
      upd7810_0.run(frame);
      frame:=frame+upd7810_0.tframes-upd7810_0.contador;
      case f of
        0:upd7810_0.set_input_line(UPD7810_INTF2,CLEAR_LINE);
        239:begin
              update_video;
              upd7810_0.set_input_line(UPD7810_INTF2,ASSERT_LINE);
            end;
      end;
  end;
  actualiza_trozo_simple(0,0,192,222,1);
  eventos_coleco;
  video_sync;
end;
end;

function scv_getbyte(direccion:word):byte;
begin
  case direccion of
    0..$fff:scv_getbyte:=rom[direccion];
    $2000..$3403:scv_getbyte:=memoria[direccion];
    $8000..$ff7f:scv_getbyte:=memoria[direccion];
    $ff80..$ffff:scv_getbyte:=upd7810_0.ram[direccion and $7f];
  end;
end;

procedure scv_putbyte(direccion:word;valor:byte);
begin
  case direccion of
    0..$fff:;
    $2000..$3403:memoria[direccion]:=valor;
    $3600:; //sonido!!
    $8000..$ff7f:;//cartucho
    $ff80..$ffff:upd7810_0.ram[direccion and $7f]:=valor;
  end;
end;

function scv_portb_in(mask:byte):byte;
var
  f,data:byte;
begin
  data:=$ff;
	for f:=0 to 7 do begin
    //teclado!!
		//if (!BIT(m_porta, i)) then data:=data and m_pa[i]->read();
	end;
  scv_portb_in:=data;
end;

function scv_portc_in(mask:byte):byte;
var
  data:byte;
begin
  data:=portc_val;
	data:=(data and $fe) or 1;// or (m_pc0->read() & 0x01); teclado parte 2
  scv_portc_in:=data;
end;

procedure scv_porta_out(valor:byte);
begin
  porta_val:=valor;
end;

procedure scv_portc_out(valor:byte);
begin
  portc_val:=valor;
	//m_cart->write_bank(m_portc);
	//m_upd1771c->pcm_write(m_portc & 0x08);
end;

procedure scv_sound_update;
begin
end;

//Main
procedure reset_scv;
begin
 upd7810_0.reset;
 reset_audio;
 porta_val:=0;
 portc_val:=0;
 if not(cartucho_load) then fillchar(memoria[$8000],$8000,$ff);
end;

function abrir_scv:boolean;
var
  extension,nombre_file,RomFile:string;
  datos:pbyte;
  longitud,crc:integer;
  resultado:boolean;
begin
  if not(OpenRom(StSuperCassette,Romfile)) then begin
    abrir_scv:=true;
    exit;
  end;
  abrir_scv:=false;
  extension:=extension_fichero(RomFile);
  if extension='ZIP' then begin
    if not(search_file_from_zip(RomFile,'*.bin',nombre_file,longitud,crc,false)) then exit;
    getmem(datos,longitud);
    if not(load_file_from_zip(RomFile,nombre_file,datos,longitud,crc,true)) then begin
      freemem(datos);
      exit;
    end;
  end else begin
    if (extension<>'BIN') then exit;
    if not(read_file_size(RomFile,longitud)) then exit;
    getmem(datos,longitud);
    if not(read_file(RomFile,datos,longitud)) then begin
      freemem(datos);
      exit;
    end;
    nombre_file:=extractfilename(RomFile);
  end;
abrir_scv:=true;
extension:=extension_fichero(nombre_file);
if (extension='BIN') then begin
  copymemory(@memoria,datos,longitud);
end;
freemem(datos);
if resultado then begin
  llamadas_maquina.open_file:=nombre_file;
end else begin
  MessageDlg('Error cargando snapshot/ROM.'+chr(10)+chr(13)+'Error loading the snapshot/ROM.', mtInformation,[mbOk], 0);
  llamadas_maquina.open_file:='';
end;
change_caption;
directory.coleco_snap:=ExtractFilePath(romfile);
end;

function iniciar_scv:boolean;
var
  temp:array[0..$13ff] of byte;
begin
iniciar_scv:=false;
iniciar_audio(false);
screen_init(1,192,222);
iniciar_video(192,222);
//Main CPU
upd7810_0:=cpu_upd7810.create(4000000,222,CPU_7801);
upd7810_0.change_ram_calls(scv_getbyte,scv_putbyte);
upd7810_0.change_in(nil,scv_portb_in,scv_portc_in,nil,nil);
upd7810_0.change_out(scv_porta_out,nil,scv_portc_out,nil,nil);
upd7810_0.init_sound(scv_sound_update);
//Chip Sonido
//cargar roms
if not(roms_load(@temp,scv_bios)) then exit;
copymemory(@rom,@temp,$1000);
copymemory(@chars,@temp[$1000],$400);
//final
reset_scv;
iniciar_scv:=true;
end;

procedure cargar_scv;
begin
principal1.BitBtn10.Glyph:=nil;
principal1.imagelist2.GetBitmap(4,principal1.BitBtn10.Glyph);
principal1.BitBtn10.OnClick:=principal1.fLoadCartucho;
llamadas_maquina.iniciar:=iniciar_scv;
llamadas_maquina.bucle_general:=scv_principal;
llamadas_maquina.reset:=reset_scv;
llamadas_maquina.cartuchos:=abrir_scv;
//llamadas_maquina.grabar_snapshot:=scv_grabar_snapshot;
llamadas_maquina.fps_max:=59.922745;
end;


end.
