unit pv1000;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,sysutils,gfx_engine,timer_engine,
     sound_engine,file_engine,pal_engine,misc_functions,dialogs,lenguaje;

function iniciar_pv1000:boolean;

type
    sound_voice=record
        count:dword;
        period:word;
        val:byte;
    end;
    tpv1000_sound=record
        voice:array[0..2] of sound_voice;
        control:byte;
        timer:byte;
        output_:smallint;
        tsample_:byte;
    end;
    tpv1000=record
        io_ram:array[0..7] of byte;
        force_pattern,fd_buffer_flag:boolean;
        pcg_bank,fd_data,border_col:byte;
        sound:tpv1000_sound;
        buffer_video:array[0..$3ff] of boolean;
        keys:array[0..3] of byte;
    end;

var
  pv1000_0:tpv1000;

implementation
uses principal,snapshot;

const
pv1000_paleta:array[0..7] of integer=(
        $000000,$0000FF,$00FF00,$00FFFF,
        $FF0000,$FF00FF,$FFFF00,$FFFFFF);

procedure eventos_pv1000;
begin
if event.arcade then begin
   //System
   if arcade_input.coin[0] then pv1000_0.keys[0]:=(pv1000_0.keys[0] or 1) else pv1000_0.keys[0]:=(pv1000_0.keys[0] and $fe);
   if arcade_input.start[0] then pv1000_0.keys[0]:=(pv1000_0.keys[0] or 2) else pv1000_0.keys[0]:=(pv1000_0.keys[0] and $fd);
   if arcade_input.coin[1] then pv1000_0.keys[0]:=(pv1000_0.keys[0] or 4) else pv1000_0.keys[0]:=(pv1000_0.keys[0] and $fb);
   if arcade_input.start[1] then pv1000_0.keys[0]:=(pv1000_0.keys[0] or 8) else pv1000_0.keys[0]:=(pv1000_0.keys[0] and $f7);
   //Players
   if arcade_input.down[0] then pv1000_0.keys[1]:=(pv1000_0.keys[1] or 1) else pv1000_0.keys[1]:=(pv1000_0.keys[1] and $fe);
   if arcade_input.right[0] then pv1000_0.keys[1]:=(pv1000_0.keys[1] or 2) else pv1000_0.keys[1]:=(pv1000_0.keys[1] and $fd);
   if arcade_input.down[1] then pv1000_0.keys[1]:=(pv1000_0.keys[1] or 4) else pv1000_0.keys[1]:=(pv1000_0.keys[1] and $fb);
   if arcade_input.right[1] then pv1000_0.keys[1]:=(pv1000_0.keys[1] or 8) else pv1000_0.keys[1]:=(pv1000_0.keys[1] and $f7);
   //Players
   if arcade_input.left[0] then pv1000_0.keys[2]:=(pv1000_0.keys[2] or 1) else pv1000_0.keys[2]:=(pv1000_0.keys[2] and $fe);
   if arcade_input.up[0] then pv1000_0.keys[2]:=(pv1000_0.keys[2] or 2) else pv1000_0.keys[2]:=(pv1000_0.keys[2] and $fd);
   if arcade_input.left[1] then pv1000_0.keys[2]:=(pv1000_0.keys[2] or 4) else pv1000_0.keys[2]:=(pv1000_0.keys[2] and $fb);
   if arcade_input.up[1] then pv1000_0.keys[2]:=(pv1000_0.keys[2] or 8) else pv1000_0.keys[2]:=(pv1000_0.keys[2] and $f7);
   //Players
   if arcade_input.but0[0] then pv1000_0.keys[3]:=(pv1000_0.keys[3] or 1) else pv1000_0.keys[3]:=(pv1000_0.keys[3] and $fe);
   if arcade_input.but1[0] then pv1000_0.keys[3]:=(pv1000_0.keys[3] or 2) else pv1000_0.keys[3]:=(pv1000_0.keys[3] and $fd);
   if arcade_input.but0[1] then pv1000_0.keys[3]:=(pv1000_0.keys[3] or 4) else pv1000_0.keys[3]:=(pv1000_0.keys[3] and $fb);
   if arcade_input.but1[1] then pv1000_0.keys[3]:=(pv1000_0.keys[3] or 8) else pv1000_0.keys[3]:=(pv1000_0.keys[3] and $f7);
end;
end;

procedure update_video_pv1000;
var
  sx,sy:byte;
  addr,tile,pos:word;
procedure draw_tile(pos:word);
var
  x,y,valor1,valor2,valor3:byte;
  ptemp:pword;
begin
for y:=0 to 7 do begin
  ptemp:=punbuf;
  valor3:=memoria[pos+y];
  valor2:=memoria[pos+8+y];
  valor1:=memoria[pos+16+y];
  for x:=7 downto 0 do begin
    ptemp^:=paleta[((valor1 shr x) and 1) or (((valor2 shr x) and 1)*2) or (((valor3 shr x) and 1)*4)];
    inc(ptemp);
  end;
  putpixel(sx*8,(sy*8)+y,8,punbuf,1);
end;
end;
begin
for sy:=0 to 23 do begin
		for sx:=2 to 29 do begin
      addr:=(sy*32)+sx;
      if pv1000_0.buffer_video[addr] then begin
			  tile:=memoria[$b800+addr];
			  if ((tile<$e0) or pv1000_0.force_pattern) then begin
				  tile:=tile or (pv1000_0.pcg_bank shl 8);
          pos:=(tile*32)+8;
          draw_tile(pos);
        end else begin
				  tile:=tile-$e0;
				  pos:=$bc00+(tile*32)+8;
          draw_tile(pos);
			  end;
        pv1000_0.buffer_video[addr]:=false;
      end;
		end;
end;
end;

procedure pv1000_principal;
var
  frame:single;
  f:byte;
begin
init_controls(false,true,false,true);
frame:=z80_0.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to 255 do begin
      z80_0.run(frame);
      frame:=frame+z80_0.tframes-z80_0.contador;
      case f of
        0,196,200,204,208,212,216,220,224,228,232,236,240,244,248,252:z80_0.change_irq(CLEAR_LINE);
        195:begin
              pv1000_0.fd_buffer_flag:=true;
              z80_0.change_irq(ASSERT_LINE);
              update_video_pv1000;
            end;
        199,203,207,211,215,219,223,227,231,235,239,243,247,251,255:z80_0.change_irq(ASSERT_LINE);
      end;
  end;
  actualiza_trozo_simple(0,0,256,192,1);
  eventos_pv1000;
  video_sync;
end;
end;

function pv1000_getbyte(direccion:word):byte;
begin
  case direccion of
    0..$7fff,$b800..$bfff:pv1000_getbyte:=memoria[direccion];
  end;
end;

procedure pv1000_putbyte(direccion:word;valor:byte);
begin
  case direccion of
    0..$7fff:;
    $b800..$bbff:if memoria[direccion]<>valor then begin
                    memoria[direccion]:=valor;
                    pv1000_0.buffer_video[direccion and $3ff]:=true;
                 end;
    $bc00..$bfff:if memoria[direccion]<>valor then begin
                    memoria[direccion]:=valor;
                    fillchar(pv1000_0.buffer_video,$400,1);
                 end;
  end;
end;

function pv1000_in(puerto:word):byte;
var
  tempb,f:byte;
begin
case (puerto and $ff) of
  $f8..$fb,$fe,$ff:pv1000_in:=pv1000_0.io_ram[puerto and 7];
  $fc:begin
        tempb:=byte(pv1000_0.fd_buffer_flag);
        if pv1000_0.fd_data<>0 then tempb:=tempb or 2;
        pv1000_0.fd_buffer_flag:=false;
        pv1000_in:=tempb;
      end;
  $fd:begin
        tempb:=0;
		    for f:=0 to 3 do begin
			    if ((pv1000_0.io_ram[5] and (1 shl f))<>0) then begin
            case f of
              0:tempb:=tempb or pv1000_0.keys[0];
              1:tempb:=tempb or pv1000_0.keys[1];
              2:tempb:=tempb or pv1000_0.keys[2];
              3:tempb:=tempb or pv1000_0.keys[3];
            end;
				    pv1000_0.fd_data:=pv1000_0.fd_data and not(1 shl f);
          end;
        end;
        pv1000_in:=tempb;
      end;
end;
end;

procedure pv1000_out(puerto:word;valor:byte);
var
  per:byte;
begin
case (puerto and $ff) of
  $f8..$fb:begin //Sound
              pv1000_0.io_ram[puerto and 7]:=valor;
              puerto:=puerto and $3;
	            case puerto of
                0..2:begin
			                  per:=not(valor) and $3f;
                        // flip output once and stall there!
			                  if ((per=0) and (pv1000_0.sound.voice[puerto].period<>0)) then pv1000_0.sound.voice[puerto].val:=not(pv1000_0.sound.voice[puerto].val);
			                  pv1000_0.sound.voice[puerto].period:=per;
                      end;
	              3:pv1000_0.sound.control:=valor;
              end;
           end;
  $fc,$fe:pv1000_0.io_ram[puerto and 7]:=valor;
  $fd:begin
        pv1000_0.io_ram[puerto and 7]:=valor;
        pv1000_0.fd_data:=$f;
      end;
  $ff:begin //colores
        pv1000_0.io_ram[puerto and 7]:=valor;
        pv1000_0.pcg_bank:=(valor and $20) shr 5;
		    pv1000_0.force_pattern:=(valor and $10)<>0; // Dig Dug relies on this
		    if (pv1000_0.border_col<>(valor and 7)) then begin
          pv1000_0.border_col:=valor and 7;
          fill_full_screen(1,pv1000_0.border_col);
        end;
      end;
end;
end;

procedure pv1000_sound_update;
begin
  tsample[pv1000_0.sound.tsample_,sound_status.posicion_sonido]:=pv1000_0.sound.output_;
end;

procedure update_sound_internal;
const
  volumes:array[0..2] of byte=($10,$18,$20);
var
  f,xor01,xor12:byte;
  sum:integer;
begin
sum:=0;
// First calculate all vals
for f:=0 to 2 do begin
  pv1000_0.sound.voice[f].count:=pv1000_0.sound.voice[f].count+1;
  if ((pv1000_0.sound.voice[f].period>0) and (pv1000_0.sound.voice[f].count>=pv1000_0.sound.voice[f].period)) then begin
    pv1000_0.sound.voice[f].count:=0;
    pv1000_0.sound.voice[f].val:=not(pv1000_0.sound.voice[f].val);
  end;
end;
// Then mix channels according to m_ctrl
if (pv1000_0.sound.control and 2)<>0 then begin
  // ch0 and ch1
  if ((pv1000_0.sound.control and 1)<>0) then begin
				xor01:=(pv1000_0.sound.voice[0].val xor pv1000_0.sound.voice[1].val) and 1;
				xor12:=(pv1000_0.sound.voice[1].val xor pv1000_0.sound.voice[2].val) and 1;
				sum:=sum+(xor01*volumes[0]);
				sum:=sum+(xor12*volumes[1]);
  end else begin
				sum:=sum+(pv1000_0.sound.voice[0].val*volumes[0]);
				sum:=sum+(pv1000_0.sound.voice[1].val*volumes[1]);
  end;
  // ch3 is unaffected by m_ctrl bit 1
  sum:=sum+(pv1000_0.sound.voice[2].val*volumes[2]);
  if sum>32767 then pv1000_0.sound.output_:=32767
      else if sum<-32767 then pv1000_0.sound.output_:=-32767
        else pv1000_0.sound.output_:=sum;
end;
end;

//Main
procedure reset_pv1000;
var
  f:byte;
begin
 z80_0.reset;
 reset_audio;
 pv1000_0.fd_buffer_flag:=false;
 pv1000_0.force_pattern:=false;
 pv1000_0.fd_data:=0;
 pv1000_0.pcg_bank:=0;
 pv1000_0.border_col:=8;
 fillchar(pv1000_0.io_ram,8,0);
 fillchar(pv1000_0.keys,4,0);
 fillchar(pv1000_0.buffer_video,$400,1);
 for f:=0 to 2 do begin
    pv1000_0.sound.voice[f].count:=0;
    pv1000_0.sound.voice[f].period:=0;
    pv1000_0.sound.voice[f].val:=1;
 end;
 pv1000_0.sound.control:=0;
 pv1000_0.sound.output_:=0;
end;

procedure pv1000_grabar_snapshot;
var
  nombre:string;
begin
nombre:=snapshot_main_write;
Directory.pv1000:=ExtractFilePath(nombre);
end;

procedure abrir_pv1000;
var
  extension,nombre_file,romfile:string;
  longitud:integer;
  datos:pbyte;
begin
  if not(openrom(romfile)) then exit;
  getmem(datos,$400000);
  if not(extract_data(romfile,datos,longitud,nombre_file)) then begin
    freemem(datos);
    exit;
  end;
  extension:=extension_fichero(nombre_file);
  if (extension='DSP') then snapshot_r(datos,longitud)
    else begin
          copymemory(@memoria[$0],datos,longitud);
          reset_pv1000;
         end;
  fillchar(pv1000_0.buffer_video,$400,1);
  change_caption(nombre_file);
  freemem(datos);
  directory.pv1000:=ExtractFilePath(romfile);
end;

function iniciar_pv1000:boolean;
var
  f:byte;
  colores:tpaleta;
begin
principal1.BitBtn10.Glyph:=nil;
principal1.imagelist2.GetBitmap(4,principal1.BitBtn10.Glyph);
principal1.BitBtn10.OnClick:=principal1.fLoadCartucho;
llamadas_maquina.bucle_general:=pv1000_principal;
llamadas_maquina.reset:=reset_pv1000;
llamadas_maquina.cartuchos:=abrir_pv1000;
llamadas_maquina.grabar_snapshot:=pv1000_grabar_snapshot;
llamadas_maquina.fps_max:=59.92274;
iniciar_pv1000:=false;
iniciar_audio(false);
screen_init(1,256,192,false,true);
iniciar_video(256,192);
//Main CPU
z80_0:=cpu_z80.create(17897725 div 5,256);
z80_0.change_ram_calls(pv1000_getbyte,pv1000_putbyte);
z80_0.change_io_calls(pv1000_in,pv1000_out);
z80_0.init_sound(pv1000_sound_update);
//sound
pv1000_0.sound.tsample_:=init_channel;
pv1000_0.sound.timer:=timers.init(z80_0.numero_cpu,(17897725/5)/(17897725/1024),update_sound_internal,nil,true);
//Pal
for f:=0 to 7 do begin
  colores[f].r:=pv1000_paleta[f] shr 16;
  colores[f].g:=(pv1000_paleta[f] shr 8) and $ff;
  colores[f].b:=pv1000_paleta[f] and $ff;
end;
set_pal(colores,8);
//final
reset_pv1000;
if main_vars.console_init then abrir_pv1000;
iniciar_pv1000:=true;
end;

end.
