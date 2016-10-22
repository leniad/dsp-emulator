unit junofirst_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6809,nz80,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     sound_engine,konami_decrypt,ay_8910,mcs48,dac;

procedure cargar_junofrst;

implementation
const
        junofrst_rom:array[0..3] of tipo_roms=(
        (n:'jfa_b9.bin';l:$2000;p:$a000;crc:$f5a7ab9d),(n:'jfb_b10.bin';l:$2000;p:$c000;crc:$f20626e0),
        (n:'jfc_a10.bin';l:$2000;p:$e000;crc:$1e7744a7),());
        junofrst_bank_rom:array[0..6] of tipo_roms=(
        (n:'jfc1_a4.bin';l:$2000;p:$0;crc:$03ccbf1d),(n:'jfc2_a5.bin';l:$2000;p:$2000;crc:$cb372372),
        (n:'jfc3_a6.bin';l:$2000;p:$4000;crc:$879d194b),(n:'jfc4_a7.bin';l:$2000;p:$6000;crc:$f28af80b),
        (n:'jfc5_a8.bin';l:$2000;p:$8000;crc:$0539f328),(n:'jfc6_a9.bin';l:$2000;p:$a000;crc:$1da2ad6e),());
        junofrst_sound:tipo_roms=(n:'jfs1_j3.bin';l:$1000;p:0;crc:$235a2893);
        junofrst_sound_sub:tipo_roms=(n:'jfs2_p4.bin';l:$1000;p:0;crc:$d0fa5d5f);
        junofrst_blit:array[0..3] of tipo_roms=(
        (n:'jfs3_c7.bin';l:$2000;p:$0;crc:$aeacf6db),(n:'jfs4_d7.bin';l:$2000;p:$2000;crc:$206d954c),
        (n:'jfs5_e7.bin';l:$2000;p:$4000;crc:$1eb87a6e),());
        //Dip
        junofrst_dip_a:array [0..1] of def_dip=(
        (mask:$0f;name:'Coin A';number:16;dip:((dip_val:$2;dip_name:'4C 1C'),(dip_val:$5;dip_name:'3C 1C'),(dip_val:$8;dip_name:'2C 1C'),(dip_val:$4;dip_name:'3C 2C'),(dip_val:$1;dip_name:'4C 3C'),(dip_val:$f;dip_name:'1C 1C'),(dip_val:$3;dip_name:'3C 4C'),(dip_val:$7;dip_name:'2C 3C'),(dip_val:$e;dip_name:'1C 2C'),(dip_val:$6;dip_name:'2C 5C'),(dip_val:$d;dip_name:'1C 3C'),(dip_val:$c;dip_name:'1C 4C'),(dip_val:$b;dip_name:'1C 5C'),(dip_val:$a;dip_name:'1C 6C'),(dip_val:$9;dip_name:'1C 7C'),(dip_val:$0;dip_name:'Free Play'))),());
        junofrst_dip_b:array [0..4] of def_dip=(
        (mask:$3;name:'Lives';number:4;dip:((dip_val:$3;dip_name:'3'),(dip_val:$2;dip_name:'4'),(dip_val:$1;dip_name:'5'),(dip_val:$0;dip_name:'256'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$4;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$70;name:'Difficulty';number:8;dip:((dip_val:$70;dip_name:'1 (Easiest)'),(dip_val:$60;dip_name:'2'),(dip_val:$50;dip_name:'3'),(dip_val:$40;dip_name:'4'),(dip_val:$30;dip_name:'5'),(dip_val:$20;dip_name:'6'),(dip_val:$10;dip_name:'7'),(dip_val:$0;dip_name:'8 (Hardest)'),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Demo Sounds';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 rom_bank,rom_bank_dec:array[0..$f,0..$fff] of byte;
 mem_opcodes,blit_mem:array[0..$5fff] of byte;
 punt:array[0..$ffff] of word;
 irq_enable:boolean;
 i8039_status,frame,xorx,xory,last_snd_val,sound_latch,sound_latch2,rom_nbank,scroll_y:byte;
 blit_data:array[0..3] of byte;
 mem_snd_sub:array[0..$fff] of byte;

procedure update_video_junofrst;inline;
var
  y,x:word;
  effx,yscroll,effy,vrambyte,shifted:byte;
begin
for y:=0 to 255 do begin
		for x:=0 to 255 do begin
			effy:=y xor xory;
      if effy<192 then yscroll:=scroll_y
        else yscroll:=0;
			effx:=(x xor xorx)+yscroll;
			vrambyte:=memoria[effx*128+effy shr 1];
			shifted:=vrambyte shr (4*(effy and 1));
      punt[y*256+x]:=paleta[shifted and $0f];
		end;
end;
putpixel(0,0,$10000,@punt[0],1);
actualiza_trozo(16,0,224,256,1,0,0,224,256,pant_temp);
end;

procedure eventos_junofrst;
begin
if event.arcade then begin
  //marcade.in1
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but2[0] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  //marcade.in2
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.but2[1] then marcade.in2:=(marcade.in2 and $bf) else marcade.in2:=(marcade.in2 or $40);
  //service
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
end;
end;

procedure junofrst_principal;
var
  frame_m,frame_s,frame_s_sub:single;
  irq_req:boolean;
begin
init_controls(false,false,false,true);
frame_m:=m6809_0.tframes;
frame_s:=z80_0.tframes;
frame_s_sub:=mcs48_0.tframes;
irq_req:=false;
while EmuStatus=EsRuning do begin
  for frame:=0 to $ff do begin
    //Main CPU
    m6809_0.run(frame_m);
    frame_m:=frame_m+m6809_0.tframes-m6809_0.contador;
    //Sound CPU
    z80_0.run(frame_s);
    frame_s:=frame_s+z80_0.tframes-z80_0.contador;
    //snd sub
    mcs48_0.run(frame_s_sub);
    frame_s_sub:=frame_s_sub+mcs48_0.tframes-mcs48_0.contador;
    if frame=239 then begin
      if (irq_req and irq_enable) then m6809_0.change_irq(ASSERT_LINE);
      update_video_junofrst;
    end;
  end;
  irq_req:=not(irq_req);
  eventos_junofrst;
  video_sync;
end;
end;

function junofrst_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$800f,$8100..$8fff:junofrst_getbyte:=memoria[direccion];
  $8010:junofrst_getbyte:=marcade.dswb; //dsw2
  $8020:junofrst_getbyte:=marcade.in0;
  $8024:junofrst_getbyte:=marcade.in1;
  $8028:junofrst_getbyte:=marcade.in2;
  $802c:junofrst_getbyte:=marcade.dswa; //dsw1
  $9000..$9fff:if m6809_0.opcode then junofrst_getbyte:=rom_bank_dec[rom_nbank,direccion and $fff]
                  else junofrst_getbyte:=rom_bank[rom_nbank,direccion and $fff];
  $a000..$ffff:if m6809_0.opcode then junofrst_getbyte:=mem_opcodes[direccion-$a000]
                  else junofrst_getbyte:=memoria[direccion];
end;
end;

procedure draw_blitter;inline;
var
  i,j,copy,data:byte;
  src,dest:word;
begin
		src:=((blit_data[2] shl 8) or blit_data[3]) and $fffc;
		dest:=(blit_data[0] shl 8) or blit_data[1];
		copy:=blit_data[3] and $01;
		// 16x16 graphics */
		for i:=0 to 15 do begin
			for j:=0 to 15 do begin
				if (src and 1)<>0 then data:=blit_mem[src shr 1] and $0f
				  else data:=blit_mem[src shr 1] shr 4;
				src:=src+1;
				// if there is a source pixel either copy the pixel or clear the pixel depending on the copy flag */
				if (data<>0) then begin
					if (copy=0) then data:=0;
					if (dest and 1)<>0 then memoria[dest shr 1]:=(memoria[dest shr 1] and $0f) or (data shl 4)
					  else memoria[dest shr 1]:=(memoria[dest shr 1] and $f0) or data;
				end;
				dest:=dest+1;
			end; //del j
			dest:=dest+240;
		end; //del i
end;

procedure junofrst_putbyte(direccion:word;valor:byte);
var
  color:tcolor;
begin
if direccion>$8fff then exit;
case direccion of
  $0..$7fff,$8100..$8fff:memoria[direccion]:=valor;
  $8000..$800f:begin
                color.r:=pal3bit(valor shr 0);
                color.g:=pal3bit(valor shr 3);
                color.b:=pal2bit(valor shr 6);
                set_pal_color(color,direccion and $f);
               end;
  $8030:begin
            irq_enable:=(valor and 1)<>0;
            if not(irq_enable) then m6809_0.change_irq(CLEAR_LINE);
        end;
  $8031:; //Coin counter...
  $8033:scroll_y:=valor;
  $8034:if (valor and 1)<>0 then xorx:=0
          else xorx:=255;
  $8035:if (valor and 1)<>0 then xory:=255
          else xory:=0;
  $8040:begin
          if ((last_snd_val=0) and ((valor and 1)=1))then z80_0.change_irq(HOLD_LINE);
          last_snd_val:=valor and 1;
        end;
  $8050:sound_latch:=valor;
  $8060:rom_nbank:=valor and $f;
  $8070..$8072:blit_data[direccion and $3]:=valor;
  $8073:begin
          blit_data[$3]:=valor;
          draw_blitter;
        end;
end;
end;

function junofrst_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$fff,$2000..$23ff:junofrst_snd_getbyte:=mem_snd[direccion];
  $3000:junofrst_snd_getbyte:=sound_latch;
  $4001:junofrst_snd_getbyte:=ay8910_0.Read;
end;
end;

procedure junofrst_snd_putbyte(direccion:word;valor:byte);
begin
if direccion<$1000 then exit;
case direccion of
  $2000..$23ff:mem_snd[direccion]:=valor;
  $4000:ay8910_0.Control(valor);
  $4002:ay8910_0.Write(valor);
  $5000:sound_latch2:=valor;
  $6000:mcs48_0.change_irq(ASSERT_LINE);
end;
end;

function junofrst_sound2_getbyte(direccion:word):byte;
begin
if direccion<$1000 then junofrst_sound2_getbyte:=mem_snd_sub[direccion];
end;

function junofrst_sound2_inport(puerto:word):byte;
begin
if puerto<$100 then junofrst_sound2_inport:=sound_latch2;
end;

procedure junofrst_sound2_outport(valor:byte;puerto:word);
begin
case puerto of
  MCS48_PORT_P1:dac_0.data8_w(valor);
  MCS48_PORT_P2:begin
                  if (valor and $80)=0 then mcs48_0.change_irq(CLEAR_LINE);
                  i8039_status:=(valor and $70) shr 4;
                end;
end;
end;

function junofrst_portar:byte;
var
  timer:byte;
begin
timer:=((z80_0.contador+trunc(z80_0.tframes*frame)) div (1024 div 2)) and $f;
junofrst_portar:=(timer shl 4) or i8039_status;
end;

procedure junofrst_portbw(valor:byte); //filter RC
begin
end;

procedure junofrst_sound_update;
begin
  ay8910_0.update;
  dac_0.update;
end;

//Main
procedure reset_junofrst;
begin
 m6809_0.reset;
 z80_0.reset;
 mcs48_0.reset;
 ay8910_0.reset;
 dac_0.reset;
 reset_audio;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 irq_enable:=false;
 fillchar(punt,$20000,0);
 fillchar(blit_data[0],4,0);
 xorx:=0;
 xory:=0;
 last_snd_val:=0;
 sound_latch:=0;
 rom_nbank:=0;
 scroll_y:=0;
 i8039_status:=0;
end;

function iniciar_junofrst:boolean;
var
  f:byte;
  memoria_temp,memoria_temp_bank:array[0..$ffff] of byte;
begin
iniciar_junofrst:=false;
iniciar_audio(false);
//Pantallas
screen_init(1,256,256);
iniciar_video(224,256);
//Main CPU
m6809_0:=cpu_m6809.Create(1500000,$100);
m6809_0.change_ram_calls(junofrst_getbyte,junofrst_putbyte);
//Sound CPU
z80_0:=cpu_z80.create(1789750,$100);
z80_0.change_ram_calls(junofrst_snd_getbyte,junofrst_snd_putbyte);
z80_0.init_sound(junofrst_sound_update);
//Sound CPU 2
mcs48_0:=cpu_mcs48.create(8000000,$100,I8039);
mcs48_0.change_ram_calls(junofrst_sound2_getbyte,nil);
mcs48_0.change_io_calls(junofrst_sound2_inport,junofrst_sound2_outport);
//Sound Chip
ay8910_0:=ay8910_chip.create(1789750,AY8910,0.3);
ay8910_0.change_io_calls(junofrst_portar,nil,nil,junofrst_portbw);
dac_0:=dac_chip.Create(0.5);
//cargar roms
if not(cargar_roms(@memoria[0],@junofrst_rom[0],'junofrst.zip',0)) then exit;
konami1_decode(@memoria[$a000],@mem_opcodes[0],$6000);
if not(cargar_roms(@memoria_temp[0],@junofrst_bank_rom[0],'junofrst.zip',0)) then exit;
konami1_decode(@memoria_temp[$0],@memoria_temp_bank[0],$c000);
for f:=0 to $f do begin
  copymemory(@rom_bank[f,0],@memoria_temp[f*$1000],$1000);
  copymemory(@rom_bank_dec[f,0],@memoria_temp_bank[f*$1000],$1000);
end;
if not(cargar_roms(@blit_mem[0],@junofrst_blit[0],'junofrst.zip',0)) then exit;
//Cargar roms sound
if not(cargar_roms(@mem_snd[0],@junofrst_sound,'junofrst.zip')) then exit;
if not(cargar_roms(@mem_snd_sub[0],@junofrst_sound_sub,'junofrst.zip',1)) then exit;
//DIP
marcade.dswa:=$ff;
marcade.dswb:=$7b;
marcade.dswa_val:=@junofrst_dip_a;
marcade.dswb_val:=@junofrst_dip_b;
//final
reset_junofrst;
iniciar_junofrst:=true;
end;

procedure Cargar_junofrst;
begin
llamadas_maquina.iniciar:=iniciar_junofrst;
llamadas_maquina.bucle_general:=junofrst_principal;
llamadas_maquina.reset:=reset_junofrst;
end;

end.
