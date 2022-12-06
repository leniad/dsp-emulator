unit chip8_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     main_engine,controls_engine,sysutils,dialogs,
     sound_engine,file_engine,pal_engine,gfx_engine,misc_functions;

procedure cargar_chip8;

implementation
uses principal;

const
  font:array[0..79] of byte= (
		$F0, $90, $90, $90, $F0,	// 0
		$20, $60, $20, $20, $70,	// 1
		$F0, $10, $F0, $80, $F0,	// 2
		$F0, $10, $F0, $10, $F0,	// 3
		$90, $90, $F0, $10, $10,	// 4
		$F0, $80, $F0, $10, $F0,	// 5
		$F0, $80, $F0, $90, $F0,	// 6
		$F0, $10, $20, $40, $40,	// 7
		$F0, $90, $F0, $90, $F0,	// 8
		$F0, $90, $F0, $10, $F0,	// 9
		$F0, $90, $F0, $90, $90,	// A
		$E0, $90, $E0, $90, $E0,	// B
		$F0, $80, $80, $80, $F0,	// C
		$E0, $90, $90, $90, $E0,	// D
		$F0, $80, $F0, $80, $F0,	// E
		$F0, $80, $F0, $80, $80);	// F
	bigfont:array[0..159] of byte= (
		$FF, $FF, $C3, $C3, $C3, $C3, $C3, $C3, $FF, $FF,	// 0
		$18, $78, $78, $18, $18, $18, $18, $18, $FF, $FF,	// 1
		$FF, $FF, $03, $03, $FF, $FF, $C0, $C0, $FF, $FF,	// 2
		$FF, $FF, $03, $03, $FF, $FF, $03, $03, $FF, $FF,	// 3
		$C3, $C3, $C3, $C3, $FF, $FF, $03, $03, $03, $03, // 4
		$FF, $FF, $C0, $C0, $FF, $FF, $03, $03, $FF, $FF,	// 5
		$FF, $FF, $C0, $C0, $FF, $FF, $C3, $C3, $FF, $FF,	// 6
		$FF, $FF, $03, $03, $06, $0C, $18, $18, $18, $18, // 7
		$FF, $FF, $C3, $C3, $FF, $FF, $C3, $C3, $FF, $FF,	// 8
		$FF, $FF, $C3, $C3, $FF, $FF, $03, $03, $FF, $FF,	// 9
		$7E, $FF, $C3, $C3, $C3, $FF, $FF, $C3, $C3, $C3, // A
		$FC, $FC, $C3, $C3, $FC, $FC, $C3, $C3, $FC, $FC, // B
		$3C, $FF, $C3, $C0, $C0, $C0, $C0, $C3, $FF, $3C, // C
		$FC, $FE, $C3, $C3, $C3, $C3, $C3, $C3, $FE, $FC, // D
		$FF, $FF, $C0, $C0, $FF, $FF, $C0, $C0, $FF, $FF, // E
		$FF, $FF, $C0, $C0, $FF, $FF, $C0, $C0, $C0, $C0);  // F

var
  i,pc:word;
  regs,hp_regs:array[0..$f] of byte;
  delay_timer,sound_timer,sp,screen_mode,sound_channel,mask_x,mask_y:byte;
  key:array[0..$f] of boolean;
  screen_val:array[0..127,0..63] of byte;
  stack:array[0..$f] of word;

procedure change_screen(mode:byte);inline;
begin
screen_mode:=mode;
fillchar(screen_val[0],128*64,0);
copymemory(@memoria[0],@font[0],80);
copymemory(@memoria[80],@bigfont[0],160);
case screen_mode of
  1:begin
     mask_x:=$40;
     mask_y:=$20;
  end;
  2:begin
     mask_x:=$80;
     mask_y:=$40;
  end;
  3:begin
     mask_x:=$40;
     mask_y:=$40;
  end;
end;
end;

procedure reset_chip8;
var
  f:byte;
begin
 reset_audio;
 i:=0;
 sp:=0;
 pc:=$200;
 for f:=0 to $f do regs[f]:=0;
 change_screen(1);
end;

procedure draw_sprite(x,y,n:byte);
var
  dx,dy,source,bit:byte;
  pos_x,pos_y:byte;
begin
regs[$f]:=0;
if ((screen_mode=2) and (n=0)) then begin  //Schip 8 mode
  for dy:=0 to 15 do begin
    pos_y:=regs[y]+dy;
    for dx:=0 to 15 do begin
      source:=memoria[i+(dy*2)+(dx div 8)];
      bit:=source and ($80 shr (dx and 7));
      pos_x:=regs[x]+dx;
      if ((bit<>0) and (pos_x<mask_x) and (pos_y<mask_y)) then begin
        if screen_val[pos_x,pos_y]=1 then regs[$f]:=1;
        screen_val[pos_x,pos_y]:=screen_val[pos_x,pos_y] xor 1;
      end;
    end;
  end;
end else begin //Chip8 mode
  if n=0 then n:=16;
  for dy:=0 to (n-1) do begin
    source:=memoria[i+dy];
    pos_y:=(regs[y]+dy) and (mask_y-1);
    for dx:=0 to 7 do begin
      bit:=source and ($80 shr dx);
      pos_x:=(regs[x]+dx) and (mask_x-1);
      if bit<>0 then begin
        if screen_val[pos_x,pos_y]=1 then regs[$f]:=1;
        screen_val[pos_x,pos_y]:=screen_val[pos_x,pos_y] xor 1;
      end;
    end;
  end;
end;
end;

procedure chip8_cpu;
var
  nn,n,x,y,tempb:byte;
  opcode,nnn,tempw:word;
begin
  opcode:=(memoria[pc] shl 8)+memoria[pc+1];
  pc:=pc+2;
  nnn:=opcode and $fff;
  nn:=opcode and $ff;
  n:=opcode and $f;
  x:=(opcode and $0f00) shr 8;
  y:=(opcode and $00f0) shr 4;
  case (opcode shr 12) of
    $0:case nnn of
          0:; // NOP?????
          $0c0..$0cf:begin //SChip 8 scroll n lines down
                for tempb:=(63-n) downto 0 do
                  for tempw:=0 to 127 do screen_val[tempw,tempb+n]:=screen_val[tempw,tempb];
                for tempb:=0 to (n-1) do for tempw:=0 to 127 do screen_val[tempw,tempb]:=0;
              end;
          $0e0:fillchar(screen_val[0],128*64,0); //CLR
          $0ee:begin  //RET
                sp:=sp-1;
                pc:=stack[sp];
              end;
          $0fb:for tempb:=0 to 63 do begin // SChip 8 scroll display 4 pixels right
                  for tempw:=123 downto 0 do screen_val[tempw+4,tempb]:=screen_val[tempw,tempb];
  						    screen_val[0,tempb]:=0;
                  screen_val[1,tempb]:=0;
                  screen_val[2,tempb]:=0;
                  screen_val[3,tempb]:=0;
					     end;
          $0fc:for tempb:=0 to 63 do begin // SChip 8 scroll display 4 pixels left
                  for tempw:=4 to 127 do screen_val[tempw-4,tempb]:=screen_val[tempw,tempb];
                  screen_val[124,tempb]:=0;
                  screen_val[125,tempb]:=0;
                  screen_val[126,tempb]:=0;
                  screen_val[127,tempb]:=0;
					     end;
          $0fd:reset_chip8;
          $0fe:change_screen(1);
          $0ff:change_screen(2);
          $230:if screen_mode=3 then fillchar(screen_val[0],128*64,0) //CLR 64x64
                  else MessageDlg('Instruccion CHIP8 $0230 - '+inttohex(opcode,4)+' desconocida. PC='+inttohex(pc-2,10), mtInformation,[mbOk], 0);
          $2ac:begin //set 64x64 Mode
                change_screen(3);
                pc:=$200;
               end;
          else MessageDlg('Instruccion CHIP8 0 - '+inttohex(opcode,4)+' desconocida. PC='+inttohex(pc-2,10), mtInformation,[mbOk], 0);
       end;
    $1:pc:=nnn; //JMP NNN
    $2:begin  //CALL NNN
         stack[sp]:=pc;
         sp:=sp+1;
         pc:=nnn;
       end;
    $3:if regs[x]=nn then pc:=(pc+2) and $fff; //skip opcode if VX = NN
    $4:if regs[x]<>nn then pc:=(pc+2) and $fff; //skip opcode if VX != NN
    $5:if regs[x]=regs[y] then pc:=(pc+2) and $fff; //skip opcode if VX = VY
    $6:regs[x]:=nn;  //VX = NN
    $7:regs[x]:=regs[x]+nn; // VX=VX + NN
    $8:case n of
          0:regs[x]:=regs[y]; //VX = VY
          1:regs[x]:=regs[x] or regs[y]; //VX = VX or VY
          2:regs[x]:=regs[x] and regs[y]; //VX = VX and VY
          3:regs[x]:=regs[x] xor regs[y]; //VX = VX xor VY
          4:begin //VX = VX + VY overflow
              tempw:=regs[x]+regs[y];
              regs[$f]:=(tempw shr 8) and 1;
              regs[x]:=tempw and $ff;
            end;
          5:begin //VX = VX - VY overflow
              if regs[x]>=regs[y] then regs[$f]:=1
                else regs[$f]:=0;
              regs[x]:=regs[x]-regs[y];
            end;
          6:begin  //VX = VY shr 1 overflow
              regs[$f]:=regs[y] and 1;
              regs[x]:=regs[y] shr 1;
            end;
          7:begin //VX = VY - VX overflow
              if regs[y]>=regs[x] then regs[$f]:=1
                else regs[$f]:=0;
              regs[x]:=regs[y]-regs[x];
            end;
         $e:begin  //VX = VY shl 1 overflow
              regs[$f]:=(regs[y] shr 7) and 1;
              regs[x]:=regs[y] shl 1;
            end;
          else MessageDlg('Instruccion CHIP8 8 - '+inttohex(opcode,10)+' desconocida. PC='+inttohex(pc-2,10), mtInformation,[mbOk], 0);
       end;
    $9:if regs[x]<>regs[y] then pc:=(pc+2) and $fff; //skip next if VX != VY
    $a:i:=nnn;  //I = NNN
    $b:pc:=nnn+regs[0];  //JMP NNN+V0
    $c:regs[x]:=random(256) and nn;
    $d:draw_sprite(x,y,n);// DRAWSPRITE
    $e:case nn of
          $9e:if key[regs[x] and $f] then pc:=(pc+2) and $fff;  //key VX down
          $a1:if not(key[regs[x] and $f]) then pc:=(pc+2) and $fff;  //key VX up
       end;
    $f:case nn of
            $07:regs[x]:=delay_timer;  //LOAD VX = DELAY TIMER
            $0a:begin  //WAIT FOR KEY PRESS
                  pc:=(pc-2) and $fff;
                  for tempb:=0 to $f do
                    if key[tempb] then begin
                      regs[x]:=tempb;
                      pc:=(pc+2) and $fff;
                    end;
                end;
            $15:delay_timer:=regs[x]; //SET DELAY TIMER = VX
            $18:sound_timer:=regs[x]; //SET SOUND TIMER
            $1e:begin  //SET I = I + VX Overflow -> VF
                  i:=i+regs[x];
                  if i>$fff then regs[$f]:=1
                    else regs[$f]:=0;
                  i:=i and $fff;
                end;
            $29:i:=(regs[x] and $f)*5; //I = VX*5 (sprite)
            $30:i:=(regs[x] and $f)*10+80;
            $33:begin  //Store BCD if VX in I+0+1+2
                  memoria[i]:=regs[x] div 100;
                  memoria[i+1]:=(regs[x] mod 100) div 10;
                  memoria[i+2]:=regs[x] mod 10;
                end;
            $55:for tempb:=0 to x do begin  //MEM[I] = V0 to VX
                    memoria[i]:=regs[tempb];
                    i:=i+1;
                end;
            $65:for tempb:=0 to x do begin //V0 to VX = MEM [I]
                    regs[tempb]:=memoria[i];
                    i:=i+1;
                end;
            $75:for tempb:=0 to x do hp_regs[tempb]:=regs[tempb]; //SAVE HP48 REGS
            $85:for tempb:=0 to x do regs[tempb]:=hp_regs[tempb]; //LOAD HP48 REGS
                  else MessageDlg('Instruccion CHIP8 F - '+inttohex(opcode,10)+' desconocida. PC='+inttohex(pc-2,10), mtInformation,[mbOk], 0);
           end;
      else MessageDlg('Instruccion CHIP8 - '+inttohex(opcode,4)+' desconocida. PC='+inttohex(pc-2,10), mtInformation,[mbOk], 0);
  end;
end;

procedure update_video_chip8;inline;
var
  x,y,pos_y:byte;
  ptemp:pword;
begin
  pos_y:=0;
  case screen_mode of
    1:begin //Chip8 mode
        for y:=0 to 31 do begin
           ptemp:=punbuf;
           for x:=0 to 63 do begin
              ptemp^:=paleta[screen_val[x,y]];inc(ptemp);
              ptemp^:=paleta[screen_val[x,y]];inc(ptemp);
              ptemp^:=paleta[screen_val[x,y]];inc(ptemp);
              ptemp^:=paleta[screen_val[x,y]];inc(ptemp);
           end;
           putpixel(0,pos_y,64*4,punbuf,1);
           putpixel(0,pos_y+1,64*4,punbuf,1);
           putpixel(0,pos_y+2,64*4,punbuf,1);
           putpixel(0,pos_y+3,64*4,punbuf,1);
           pos_y:=pos_y+4;
        end;
      end;
    2:begin //Schip8 mode
        for y:=0 to 63 do begin
           ptemp:=punbuf;
           for x:=0 to 127 do begin
              ptemp^:=paleta[screen_val[x,y]];inc(ptemp);
              ptemp^:=paleta[screen_val[x,y]];inc(ptemp);
           end;
           putpixel(0,pos_y,128*2,punbuf,1);
           putpixel(0,pos_y+1,128*2,punbuf,1);
           pos_y:=pos_y+2;
        end;
      end;
    3:begin //Chip8 mode 64x64
        for y:=0 to 63 do begin
           ptemp:=punbuf;
           for x:=0 to 63 do begin
              ptemp^:=paleta[screen_val[x,y]];inc(ptemp);
              ptemp^:=paleta[screen_val[x,y]];inc(ptemp);
              ptemp^:=paleta[screen_val[x,y]];inc(ptemp);
              ptemp^:=paleta[screen_val[x,y]];inc(ptemp);
           end;
           putpixel(0,pos_y,64*4,punbuf,1);
           putpixel(0,pos_y+1,64*4,punbuf,1);
           pos_y:=pos_y+2;
        end;
      end;
  end;
end;

procedure eventos_chip8;
begin
  if event.keyboard then begin
    key[0]:=keyboard[KEYBOARD_X];
    key[1]:=keyboard[KEYBOARD_1];
    key[2]:=keyboard[KEYBOARD_2];
    key[3]:=keyboard[KEYBOARD_3];
    key[4]:=keyboard[KEYBOARD_Q];
    key[5]:=keyboard[KEYBOARD_W];
    key[6]:=keyboard[KEYBOARD_E];
    key[7]:=keyboard[KEYBOARD_A];
    key[8]:=keyboard[KEYBOARD_S];
    key[9]:=keyboard[KEYBOARD_D];
    key[$a]:=keyboard[KEYBOARD_Z];
    key[$b]:=keyboard[KEYBOARD_C];
    key[$c]:=keyboard[KEYBOARD_4];
    key[$d]:=keyboard[KEYBOARD_R];
    key[$e]:=keyboard[KEYBOARD_F];
    key[$f]:=keyboard[KEYBOARD_V];
  end;
end;

procedure chip8_principal;
var
  f:byte;
begin
init_controls(false,true,false,false);
while EmuStatus=EsRuning do begin
  for f:=0 to 11 do begin
    chip8_cpu;
    if sound_timer<>0 then tsample[sound_channel,sound_status.posicion_sonido]:=$7fff;
    if sound_status.hay_sonido then begin
        if sound_status.posicion_sonido=sound_status.long_sample then play_sonido
          else sound_status.posicion_sonido:=trunc(sound_status.posicion_sonido+1);
    end;
  end;
  if delay_timer<>0 then delay_timer:=delay_timer-1;
  if sound_timer<>0 then sound_timer:=sound_timer-1;
  eventos_chip8;
  update_video_chip8;
  actualiza_trozo_simple(0,0,64*4,32*4,1);
  video_sync;
end;
end;

//Main
procedure abrir_chip8;
var
  extension,nombre_file,RomFile:string;
  longitud,crc:integer;
  datos:pbyte;
  resultado:boolean;
begin
  if not(OpenRom(StChip8,RomFile)) then exit;
  extension:=extension_fichero(RomFile);
  resultado:=false;
  if extension='ZIP' then begin
    if not(search_file_from_zip(RomFile,'*.ch8',nombre_file,longitud,crc,false)) then
      if not(search_file_from_zip(RomFile,'*.bin',nombre_file,longitud,crc,false)) then begin
        MessageDlg('Error cargando snapshot/ROM.'+chr(10)+chr(13)+'Error loading the snapshot/ROM.', mtInformation,[mbOk], 0);
        exit;
      end;
    getmem(datos,longitud);
    if not(load_file_from_zip(RomFile,nombre_file,datos,longitud,crc,true)) then freemem(datos)
      else resultado:=true;
  end else begin
    if ((extension<>'CH8') and (extension<>'BIN')) then begin
      MessageDlg('Error cargando snapshot/ROM.'+chr(10)+chr(13)+'Error loading the snapshot/ROM.', mtInformation,[mbOk], 0);
      exit;
    end;
    if read_file_size(RomFile,longitud) then begin
      getmem(datos,longitud);
      if not(read_file(RomFile,datos,longitud)) then freemem(datos)
        else resultado:=true;
      nombre_file:=extractfilename(RomFile);
    end;
  end;
  if not(resultado) then begin
    MessageDlg('Error cargando snapshot/ROM.'+chr(10)+chr(13)+'Error loading the snapshot/ROM.', mtInformation,[mbOk], 0);
    exit;
  end;
  reset_chip8;
  change_caption(nombre_file);
  copymemory(@memoria[$200],datos,longitud);
  freemem(datos);
  directory.Chip8:=ExtractFilePath(romfile);
end;

function iniciar_chip8:boolean;
var
  colores:tpaleta;
begin
iniciar_audio(false);
sound_channel:=init_channel;
//screen
screen_init(1,64*4,32*4);
iniciar_video(64*4,32*4);
colores[0].r:=0;colores[0].g:=0;colores[0].b:=0;
colores[1].r:=$ff;colores[1].g:=$ff;colores[1].b:=$ff;
set_pal(colores,2);
reset_chip8;
if main_vars.console_init then abrir_chip8;
iniciar_chip8:=true;
end;
procedure Cargar_chip8;
begin
principal1.BitBtn10.Glyph:=nil;
principal1.imagelist2.GetBitmap(4,principal1.BitBtn10.Glyph);
principal1.BitBtn10.OnClick:=principal1.fLoadCartucho;
llamadas_maquina.iniciar:=iniciar_chip8;
llamadas_maquina.bucle_general:=chip8_principal;
llamadas_maquina.reset:=reset_chip8;
llamadas_maquina.cartuchos:=abrir_chip8;
//llamadas_maquina.grabar_snapshot:=coleco_grabar_snapshot;
end;

end.
