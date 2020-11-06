unit tetris_atari_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6502,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     sound_engine,pokey,slapstic,file_engine;

procedure cargar_tetris;

implementation
const
        tetris_rom:tipo_roms=(n:'136066-1100.45f';l:$10000;p:$0;crc:$2acbdb09);
        tetris_gfx:tipo_roms=(n:'136066-1101.35a';l:$10000;p:$0;crc:$84a1939f);
        //Dip
        tetris_dip_a:array [0..3] of def_dip=(
        (mask:$4;name:'Freeze';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$4;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Freeze Step';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$8;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Service';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$80;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
  rom_mem:array[0..1,0..$3fff] of byte;
  nv_ram:array[0..$1ff] of byte;
  rom_bank:byte;
  nvram_write_enable:boolean;

procedure update_video_tetris;
var
  f,nchar,x,y:word;
  color,atrib:byte;
begin
for f:=0 to $7ff do begin
  atrib:=memoria[$1001+(f*2)];
  color:=atrib shr 4;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
    x:=f mod 64;
    y:=f div 64;
    nchar:=memoria[$1000+(f*2)]+((atrib and $7) shl 8);
    put_gfx(x*8,y*8,nchar,color shl 4,1,0);
    gfx[0].buffer[f]:=false;
  end;
end;
actualiza_trozo(0,0,336,240,1,0,0,336,240,2);
actualiza_trozo_final(0,0,336,240,2);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure eventos_tetris;
begin
if event.arcade then begin
  //Coin
  if arcade_input.coin[0] then marcade.in0:=marcade.in0 or $2 else marcade.in0:=marcade.in0 and $fd;
  if arcade_input.coin[1] then marcade.in0:=marcade.in0 or $1 else marcade.in0:=marcade.in0 and $fe;
  //Players
  if arcade_input.but0[0] then marcade.in1:=marcade.in1 or 1 else marcade.in1:=marcade.in1 and $fe;
  if arcade_input.down[0] then marcade.in1:=marcade.in1 or 2 else marcade.in1:=marcade.in1 and $fd;
  if arcade_input.right[0] then marcade.in1:=marcade.in1 or 4 else marcade.in1:=marcade.in1 and $fb;
  if arcade_input.left[0] then marcade.in1:=marcade.in1 or 8 else marcade.in1:=marcade.in1 and $f7;
  if arcade_input.but0[1] then marcade.in1:=marcade.in1 or $10 else marcade.in1:=marcade.in1 and $ef;
  if arcade_input.down[1] then marcade.in1:=marcade.in1 or $20 else marcade.in1:=marcade.in1 and $df;
  if arcade_input.right[1] then marcade.in1:=marcade.in1 or $40 else marcade.in1:=marcade.in1 and $bf;
  if arcade_input.left[1] then marcade.in1:=marcade.in1 or $80 else marcade.in1:=marcade.in1 and $7f;
end;
end;

procedure principal_tetris;
var
  frame:single;
  f:word;
begin
init_controls(false,false,false,true);
frame:=m6502_0.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to 261 do begin
   m6502_0.run(frame);
   frame:=frame+m6502_0.tframes-m6502_0.contador;
   case f of
      0:marcade.in0:=marcade.in0 or $40;
      47,111,175:m6502_0.change_irq(ASSERT_LINE);
      239:begin
            update_video_tetris;
            marcade.in0:=marcade.in0 and $bf;
            m6502_0.change_irq(ASSERT_LINE);
          end;
   end;
 end;
 eventos_tetris;
 video_sync;
end;
end;

function getbyte_tetris(direccion:word):byte;
var
  res,new_bank:byte;
begin
case direccion of
   0..$1fff,$4000..$5fff,$8000..$ffff:getbyte_tetris:=memoria[direccion];
   $2000..$23ff:getbyte_tetris:=buffer_paleta[direccion and $ff];
   $2400..$27ff:getbyte_tetris:=nv_ram[direccion and $1ff];
   $2800..$2bff:case (direccion and $1f) of
                    0..$f:getbyte_tetris:=pokey_0.read(direccion and $f);
                    $10..$1f:getbyte_tetris:=pokey_1.read(direccion and $f);
                end;
   $6000..$7fff:begin //SLAPSTIC
                  res:=memoria[direccion];
	                new_bank:=slapstic_0.slapstic_tweak(direccion and $1fff) and 1;
	                // update for the new bank
	                if (new_bank<>rom_bank) then begin
		                rom_bank:=new_bank;
                    copymemory(@memoria[$4000],@rom_mem[rom_bank,0],$4000);
                  end;
	                getbyte_tetris:=res;
                end;
end;
end;

procedure cambiar_color(dir:byte);inline;
var
  tmp_color:byte;
  color:tcolor;
begin
  tmp_color:=buffer_paleta[dir];
  color.r:=pal3bit(tmp_color shr 5);
  color.g:=pal3bit((tmp_color shr 2) and $7);
  color.b:=pal2bit(tmp_color and $3);
  set_pal_color(color,dir);
  buffer_color[dir shr 4]:=true;
end;

procedure putbyte_tetris(direccion:word;valor:byte);
begin
case direccion of
  0..$fff:memoria[direccion]:=valor;
  $1000..$1fff:if memoria[direccion]<>valor then begin
                gfx[0].buffer[(direccion and $fff) shr 1]:=true;
                memoria[direccion]:=valor;
             end;
  $2000..$23ff:if buffer_paleta[direccion and $ff]<>valor then begin
                  buffer_paleta[direccion and $ff]:=valor;
                  cambiar_color(direccion and $ff);
               end;
   $2400..$27ff:begin
                  if nvram_write_enable then nv_ram[direccion and $1ff]:=valor;
                  nvram_write_enable:=false;
                end;
   $2800..$2bff:case (direccion and $1f) of
                    0..$f:pokey_0.write(direccion and $f,valor);
                    $10..$1f:pokey_1.write(direccion and $f,valor);
                end;
   $3000..$33ff:; //Watchdog
   $3400..$37ff:nvram_write_enable:=true;
   $3800..$3bff:m6502_0.change_irq(CLEAR_LINE);
   $3c00..$3fff:; //coincount
   $4000..$ffff:; //ROM
end;
end;

function tetris_pokey_0(pot:byte):byte;
begin
  tetris_pokey_0:=marcade.in0 or marcade.dswa;
end;

function tetris_pokey_1(pot:byte):byte;
begin
  tetris_pokey_1:=marcade.in1;
end;

procedure tetris_sound_update;
begin
  pokey_0.update;
  pokey_1.update;
end;

//Main
procedure reset_tetris;
begin
m6502_0.reset;
slapstic_0.reset;
pokey_0.reset;
pokey_1.reset;
marcade.in0:=$40;
marcade.in1:=0;
rom_bank:=slapstic_0.current_bank and 1;
copymemory(@memoria[$4000],@rom_mem[1,0],$4000);
nvram_write_enable:=false;
end;

function iniciar_tetris:boolean;
const
    pc_x:array[0..7] of dword=(0*4, 1*4, 2*4, 3*4, 4*4, 5*4, 6*4, 7*4);
    pc_y:array[0..7] of dword=(0*4*8, 1*4*8, 2*4*8, 3*4*8, 4*4*8, 5*4*8, 6*4*8, 7*4*8);
var
  memoria_temp:array[0..$ffff] of byte;
  longitud:integer;
begin
iniciar_tetris:=false;
iniciar_audio(false);
screen_init(1,512,256);
screen_init(2,336,240,false,true);
iniciar_video(336,240);
//Main CPU
m6502_0:=cpu_m6502.create(1789772,262,TCPU_M6502);
m6502_0.change_ram_calls(getbyte_tetris,putbyte_tetris);
m6502_0.init_sound(tetris_sound_update);
//Slapstic
slapstic_0:=slapstic_type.create(101,false);
//Sound Chip
pokey_0:=pokey_chip.create(0,1789772);
pokey_0.change_all_pot(tetris_pokey_0);
pokey_1:=pokey_chip.create(1,1789772);
pokey_1.change_all_pot(tetris_pokey_1);
//nv_ram
if read_file_size(Directory.Arcade_nvram+'tetrisa.nv',longitud) then read_file(Directory.Arcade_nvram+'tetrisa.nv',@nv_ram[0],longitud)
  else for longitud:=0 to $1ff do nv_ram[longitud]:=$ff;
//cargar roms
if not(roms_load(@memoria_temp,tetris_rom)) then exit;
copymemory(@rom_mem[0,0],@memoria_temp[$0],$4000);
copymemory(@rom_mem[1,0],@memoria_temp[$4000],$4000);
copymemory(@memoria[$8000],@memoria_temp[$8000],$8000);
//Cargar chars
if not(roms_load(@memoria_temp,tetris_gfx)) then exit;
init_gfx(0,8,8,$800);
gfx_set_desc_data(4,0,8*8*4,0,1,2,3);
convert_gfx(0,0,@memoria_temp,@pc_x,@pc_y,false,false);
//Dip
marcade.dswa:=$0;
marcade.dswa_val:=@tetris_dip_a;
//final
reset_tetris;
iniciar_tetris:=true;
end;

procedure cerrar_tetris;
begin
write_file(Directory.Arcade_nvram+'tetris.nv',@nv_ram[0],$200);
end;


procedure Cargar_tetris;
begin
llamadas_maquina.iniciar:=iniciar_tetris;
llamadas_maquina.bucle_general:=principal_tetris;
llamadas_maquina.reset:=reset_tetris;
llamadas_maquina.close:=cerrar_tetris;
end;

end.
