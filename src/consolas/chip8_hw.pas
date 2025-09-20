unit chip8_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     main_engine,controls_engine,sysutils,dialogs,sound_engine,pal_engine,
     gfx_engine,misc_functions;

function iniciar_chip8:boolean;

type
  tchip8=record
          i,pc:word;
          regs,hp_regs:array[0..$f] of byte;
          delay_timer,sound_timer,sp,screen_mode,sound_channel,mask_x,mask_y:byte;
          key:array[0..$f] of boolean;
          screen_val:array[0..127,0..63] of byte;
          stack:array[0..$f] of word;
         end;

var
  chip8_0:tchip8;

implementation
uses principal,snapshot;

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

procedure change_screen(mode:byte);
begin
chip8_0.screen_mode:=mode;
fillchar(chip8_0.screen_val[0],128*64,0);
copymemory(@memoria[0],@font[0],80);
copymemory(@memoria[80],@bigfont[0],160);
case chip8_0.screen_mode of
  1:begin
     chip8_0.mask_x:=$40;
     chip8_0.mask_y:=$20;
  end;
  2:begin
     chip8_0.mask_x:=$80;
     chip8_0.mask_y:=$40;
  end;
  3:begin
     chip8_0.mask_x:=$40;
     chip8_0.mask_y:=$40;
  end;
end;
end;

procedure reset_chip8;
var
  f:byte;
begin
 chip8_0.i:=0;
 chip8_0.sp:=0;
 chip8_0.pc:=$200;
 for f:=0 to $f do chip8_0.regs[f]:=0;
 change_screen(1);
end;

procedure draw_sprite(x,y,n:byte);
var
  dx,dy,source,bit:byte;
  pos_x,pos_y:byte;
begin
chip8_0.regs[$f]:=0;
if ((chip8_0.screen_mode=2) and (n=0)) then begin  //Schip 8 mode
  for dy:=0 to 15 do begin
    pos_y:=chip8_0.regs[y]+dy;
    for dx:=0 to 15 do begin
      source:=memoria[chip8_0.i+(dy*2)+(dx div 8)];
      bit:=source and ($80 shr (dx and 7));
      pos_x:=chip8_0.regs[x]+dx;
      if ((bit<>0) and (pos_x<chip8_0.mask_x) and (pos_y<chip8_0.mask_y)) then begin
        if chip8_0.screen_val[pos_x,pos_y]=1 then chip8_0.regs[$f]:=1;
        chip8_0.screen_val[pos_x,pos_y]:=chip8_0.screen_val[pos_x,pos_y] xor 1;
      end;
    end;
  end;
end else begin //Chip8 mode
  if n=0 then n:=16;
  for dy:=0 to (n-1) do begin
    source:=memoria[chip8_0.i+dy];
    pos_y:=(chip8_0.regs[y]+dy) and (chip8_0.mask_y-1);
    for dx:=0 to 7 do begin
      bit:=source and ($80 shr dx);
      pos_x:=(chip8_0.regs[x]+dx) and (chip8_0.mask_x-1);
      if bit<>0 then begin
        if chip8_0.screen_val[pos_x,pos_y]=1 then chip8_0.regs[$f]:=1;
        chip8_0.screen_val[pos_x,pos_y]:=chip8_0.screen_val[pos_x,pos_y] xor 1;
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
  opcode:=(memoria[chip8_0.pc] shl 8)+memoria[chip8_0.pc+1];
  chip8_0.pc:=chip8_0.pc+2;
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
                  for tempw:=0 to 127 do chip8_0.screen_val[tempw,tempb+n]:=chip8_0.screen_val[tempw,tempb];
                for tempb:=0 to (n-1) do for tempw:=0 to 127 do chip8_0.screen_val[tempw,tempb]:=0;
              end;
          $0e0:fillchar(chip8_0.screen_val[0],128*64,0); //CLR
          $0ee:begin  //RET
                chip8_0.sp:=chip8_0.sp-1;
                chip8_0.pc:=chip8_0.stack[chip8_0.sp];
              end;
          $0fb:for tempb:=0 to 63 do begin // SChip 8 scroll display 4 pixels right
                  for tempw:=123 downto 0 do chip8_0.screen_val[tempw+4,tempb]:=chip8_0.screen_val[tempw,tempb];
  						    chip8_0.screen_val[0,tempb]:=0;
                  chip8_0.screen_val[1,tempb]:=0;
                  chip8_0.screen_val[2,tempb]:=0;
                  chip8_0.screen_val[3,tempb]:=0;
					     end;
          $0fc:for tempb:=0 to 63 do begin // SChip 8 scroll display 4 pixels left
                  for tempw:=4 to 127 do chip8_0.screen_val[tempw-4,tempb]:=chip8_0.screen_val[tempw,tempb];
                  chip8_0.screen_val[124,tempb]:=0;
                  chip8_0.screen_val[125,tempb]:=0;
                  chip8_0.screen_val[126,tempb]:=0;
                  chip8_0.screen_val[127,tempb]:=0;
					     end;
          $0fd:reset_chip8;
          $0fe:change_screen(1);
          $0ff:change_screen(2);
          $230:if chip8_0.screen_mode=3 then fillchar(chip8_0.screen_val[0],128*64,0) //CLR 64x64
                  else MessageDlg('Instruccion CHIP8 $0230 - '+inttohex(opcode,4)+' desconocida. PC='+inttohex(chip8_0.pc-2,10), mtInformation,[mbOk], 0);
          $2ac:begin //set 64x64 Mode
                change_screen(3);
                chip8_0.pc:=$200;
               end;
          else MessageDlg('Instruccion CHIP8 0 - '+inttohex(opcode,4)+' desconocida. PC='+inttohex(chip8_0.pc-2,10), mtInformation,[mbOk], 0);
       end;
    $1:chip8_0.pc:=nnn; //JMP NNN
    $2:begin  //CALL NNN
         chip8_0.stack[chip8_0.sp]:=chip8_0.pc;
         chip8_0.sp:=chip8_0.sp+1;
         chip8_0.pc:=nnn;
       end;
    $3:if chip8_0.regs[x]=nn then chip8_0.pc:=(chip8_0.pc+2) and $fff; //skip opcode if VX = NN
    $4:if chip8_0.regs[x]<>nn then chip8_0.pc:=(chip8_0.pc+2) and $fff; //skip opcode if VX != NN
    $5:if chip8_0.regs[x]=chip8_0.regs[y] then chip8_0.pc:=(chip8_0.pc+2) and $fff; //skip opcode if VX = VY
    $6:chip8_0.regs[x]:=nn;  //VX = NN
    $7:chip8_0.regs[x]:=chip8_0.regs[x]+nn; // VX=VX + NN
    $8:case n of
          0:chip8_0.regs[x]:=chip8_0.regs[y]; //VX = VY
          1:chip8_0.regs[x]:=chip8_0.regs[x] or chip8_0.regs[y]; //VX = VX or VY
          2:chip8_0.regs[x]:=chip8_0.regs[x] and chip8_0.regs[y]; //VX = VX and VY
          3:chip8_0.regs[x]:=chip8_0.regs[x] xor chip8_0.regs[y]; //VX = VX xor VY
          4:begin //VX = VX + VY overflow
              tempw:=chip8_0.regs[x]+chip8_0.regs[y];
              chip8_0.regs[$f]:=(tempw shr 8) and 1;
              chip8_0.regs[x]:=tempw and $ff;
            end;
          5:begin //VX = VX - VY overflow
              if chip8_0.regs[x]>=chip8_0.regs[y] then chip8_0.regs[$f]:=1
                else chip8_0.regs[$f]:=0;
              chip8_0.regs[x]:=chip8_0.regs[x]-chip8_0.regs[y];
            end;
          6:begin  //VX = VY shr 1 overflow
              chip8_0.regs[$f]:=chip8_0.regs[y] and 1;
              chip8_0.regs[x]:=chip8_0.regs[y] shr 1;
            end;
          7:begin //VX = VY - VX overflow
              if chip8_0.regs[y]>=chip8_0.regs[x] then chip8_0.regs[$f]:=1
                else chip8_0.regs[$f]:=0;
              chip8_0.regs[x]:=chip8_0.regs[y]-chip8_0.regs[x];
            end;
         $e:begin  //VX = VY shl 1 overflow
              chip8_0.regs[$f]:=(chip8_0.regs[y] shr 7) and 1;
              chip8_0.regs[x]:=chip8_0.regs[y] shl 1;
            end;
          else MessageDlg('Instruccion CHIP8 8 - '+inttohex(opcode,10)+' desconocida. PC='+inttohex(chip8_0.pc-2,10), mtInformation,[mbOk], 0);
       end;
    $9:if chip8_0.regs[x]<>chip8_0.regs[y] then chip8_0.pc:=(chip8_0.pc+2) and $fff; //skip next if VX != VY
    $a:chip8_0.i:=nnn;  //I = NNN
    $b:chip8_0.pc:=nnn+chip8_0.regs[0];  //JMP NNN+V0
    $c:chip8_0.regs[x]:=random(256) and nn;
    $d:draw_sprite(x,y,n);// DRAWSPRITE
    $e:case nn of
          $9e:if chip8_0.key[chip8_0.regs[x] and $f] then chip8_0.pc:=(chip8_0.pc+2) and $fff;  //key VX down
          $a1:if not(chip8_0.key[chip8_0.regs[x] and $f]) then chip8_0.pc:=(chip8_0.pc+2) and $fff;  //key VX up
       end;
    $f:case nn of
            $07:chip8_0.regs[x]:=chip8_0.delay_timer;  //LOAD VX = DELAY TIMER
            $0a:begin  //WAIT FOR KEY PRESS
                  chip8_0.pc:=(chip8_0.pc-2) and $fff;
                  for tempb:=0 to $f do
                    if chip8_0.key[tempb] then begin
                      chip8_0.regs[x]:=tempb;
                      chip8_0.pc:=(chip8_0.pc+2) and $fff;
                    end;
                end;
            $15:chip8_0.delay_timer:=chip8_0.regs[x]; //SET DELAY TIMER = VX
            $18:chip8_0.sound_timer:=chip8_0.regs[x]; //SET SOUND TIMER
            $1e:begin  //SET I = I + VX Overflow -> VF
                  chip8_0.i:=chip8_0.i+chip8_0.regs[x];
                  if chip8_0.i>$fff then chip8_0.regs[$f]:=1
                    else chip8_0.regs[$f]:=0;
                  chip8_0.i:=chip8_0.i and $fff;
                end;
            $29:chip8_0.i:=(chip8_0.regs[x] and $f)*5; //I = VX*5 (sprite)
            $30:chip8_0.i:=(chip8_0.regs[x] and $f)*10+80;
            $33:begin  //Store BCD if VX in I+0+1+2
                  memoria[chip8_0.i]:=chip8_0.regs[x] div 100;
                  memoria[chip8_0.i+1]:=(chip8_0.regs[x] mod 100) div 10;
                  memoria[chip8_0.i+2]:=chip8_0.regs[x] mod 10;
                end;
            $55:for tempb:=0 to x do begin  //MEM[I] = V0 to VX
                    memoria[chip8_0.i]:=chip8_0.regs[tempb];
                    chip8_0.i:=chip8_0.i+1;
                end;
            $65:for tempb:=0 to x do begin //V0 to VX = MEM [I]
                    chip8_0.regs[tempb]:=memoria[chip8_0.i];
                    chip8_0.i:=chip8_0.i+1;
                end;
            $75:for tempb:=0 to x do chip8_0.hp_regs[tempb]:=chip8_0.regs[tempb]; //SAVE HP48 REGS
            $85:for tempb:=0 to x do chip8_0.regs[tempb]:=chip8_0.hp_regs[tempb]; //LOAD HP48 REGS
                  else MessageDlg('Instruccion CHIP8 F - '+inttohex(opcode,10)+' desconocida. PC='+inttohex(chip8_0.pc-2,10), mtInformation,[mbOk], 0);
           end;
      else MessageDlg('Instruccion CHIP8 - '+inttohex(opcode,4)+' desconocida. PC='+inttohex(chip8_0.pc-2,10), mtInformation,[mbOk], 0);
  end;
end;

procedure update_video_chip8;
var
  x,y,pos_y:byte;
  ptemp:pword;
begin
  pos_y:=0;
  case chip8_0.screen_mode of
    1:begin //Chip8 mode
        for y:=0 to 31 do begin
           ptemp:=punbuf;
           for x:=0 to 63 do begin
              ptemp^:=paleta[chip8_0.screen_val[x,y]];inc(ptemp);
              ptemp^:=paleta[chip8_0.screen_val[x,y]];inc(ptemp);
              ptemp^:=paleta[chip8_0.screen_val[x,y]];inc(ptemp);
              ptemp^:=paleta[chip8_0.screen_val[x,y]];inc(ptemp);
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
              ptemp^:=paleta[chip8_0.screen_val[x,y]];inc(ptemp);
              ptemp^:=paleta[chip8_0.screen_val[x,y]];inc(ptemp);
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
              ptemp^:=paleta[chip8_0.screen_val[x,y]];inc(ptemp);
              ptemp^:=paleta[chip8_0.screen_val[x,y]];inc(ptemp);
              ptemp^:=paleta[chip8_0.screen_val[x,y]];inc(ptemp);
              ptemp^:=paleta[chip8_0.screen_val[x,y]];inc(ptemp);
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
    chip8_0.key[0]:=keyboard[KEYBOARD_X];
    chip8_0.key[1]:=keyboard[KEYBOARD_1];
    chip8_0.key[2]:=keyboard[KEYBOARD_2];
    chip8_0.key[3]:=keyboard[KEYBOARD_3];
    chip8_0.key[4]:=keyboard[KEYBOARD_Q];
    chip8_0.key[5]:=keyboard[KEYBOARD_W];
    chip8_0.key[6]:=keyboard[KEYBOARD_E];
    chip8_0.key[7]:=keyboard[KEYBOARD_A];
    chip8_0.key[8]:=keyboard[KEYBOARD_S];
    chip8_0.key[9]:=keyboard[KEYBOARD_D];
    chip8_0.key[$a]:=keyboard[KEYBOARD_Z];
    chip8_0.key[$b]:=keyboard[KEYBOARD_C];
    chip8_0.key[$c]:=keyboard[KEYBOARD_4];
    chip8_0.key[$d]:=keyboard[KEYBOARD_R];
    chip8_0.key[$e]:=keyboard[KEYBOARD_F];
    chip8_0.key[$f]:=keyboard[KEYBOARD_V];
  end;
end;

procedure chip8_principal;
var
  f:byte;
begin
init_controls(false,true,false,false);
while EmuStatus=EsRunning do begin
  for f:=0 to 11 do begin
    chip8_cpu;
    if chip8_0.sound_timer<>0 then tsample[chip8_0.sound_channel,sound_status.posicion_sonido]:=$7fff;
    if sound_status.sonido_activo then begin
        if sound_status.posicion_sonido=sound_status.long_sample then play_sonido
          else sound_status.posicion_sonido:=trunc(sound_status.posicion_sonido+1);
    end;
  end;
  if chip8_0.delay_timer<>0 then chip8_0.delay_timer:=chip8_0.delay_timer-1;
  if chip8_0.sound_timer<>0 then chip8_0.sound_timer:=chip8_0.sound_timer-1;
  eventos_chip8;
  update_video_chip8;
  actualiza_trozo(0,0,64*4,32*4,1,0,0,64*4,32*4,PANT_TEMP);
  video_sync;
end;
end;

//Main
procedure abrir_chip8;
var
  extension,nombre_file,romfile:string;
  longitud:integer;
  datos:pbyte;
begin
  if not(openrom(romfile,SCHIP8)) then exit;
  getmem(datos,$f000);
  if not(extract_data(romfile,datos,longitud,nombre_file,SCHIP8)) then begin
    freemem(datos);
    exit;
  end;
  extension:=extension_fichero(nombre_file);
  reset_chip8;
  if extension='DSP' then snapshot_r(datos,longitud,SCHIP8)
    else copymemory(@memoria[$200],datos,longitud);
  freemem(datos);
  change_caption(nombre_file);
  directory.chip8:=ExtractFilePath(romfile);
end;

procedure chip8_grabar_snapshot;
var
  nombre:string;
begin
nombre:=snapshot_main_write(SCHIP8);
Directory.chip8:=ExtractFilePath(nombre);
end;

function iniciar_chip8:boolean;
var
  colores:tpaleta;
begin
iniciar_audio(false);
principal1.BitBtn10.Glyph:=nil;
principal1.imagelist2.GetBitmap(4,principal1.BitBtn10.Glyph);
principal1.BitBtn10.OnClick:=principal1.fLoadCartucho;
llamadas_maquina.bucle_general:=chip8_principal;
llamadas_maquina.reset:=reset_chip8;
llamadas_maquina.cartuchos:=abrir_chip8;
llamadas_maquina.grabar_snapshot:=chip8_grabar_snapshot;
chip8_0.sound_channel:=init_channel;
screen_init(1,64*4,32*4);
iniciar_video(64*4,32*4);
colores[0].r:=0;colores[0].g:=0;colores[0].b:=0;
colores[1].r:=$ff;colores[1].g:=$ff;colores[1].b:=$ff;
set_pal(colores,2);
reset_chip8;
if main_vars.console_init then abrir_chip8;
iniciar_chip8:=true;
end;

end.
