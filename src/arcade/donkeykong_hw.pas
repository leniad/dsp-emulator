unit donkeykong_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,gfx_engine,samples,rom_engine,
     pal_engine,sound_engine,n2a03_sound,m6502;

procedure Cargar_dkong;
procedure reset_dkong;
procedure cerrar_dkong;
function iniciar_dkong:boolean;
//Donkey Kong & Donkey Kong jr.
procedure dkong_principal;
function dkong_getbyte(direccion:word):byte;
procedure dkong_putbyte(direccion:word;valor:byte);
procedure dkong_sound_update;
//Donkey Kong sound
procedure dkong_tune_sound(valor:byte);
procedure dkong_effects_sound(direccion,valor:byte);
//Donkey Kong Jr. sound
procedure dkongjr_tune_sound(valor:byte);
procedure dkongjr_effects_sound(direccion,valor:byte);
//Donkey Kong 3
procedure dkong3_principal;
function dkong3_getbyte(direccion:word):byte;
procedure dkong3_putbyte(direccion:word;valor:byte);
procedure dkong3_sound_update;
function dkong3_snd1_getbyte(direccion:word):byte;
procedure dkong3_snd1_putbyte(direccion:word;valor:byte);
function dkong3_snd2_getbyte(direccion:word):byte;
procedure dkong3_snd2_putbyte(direccion:word;valor:byte);

const
        //Donkey Kong
        dkong_rom:array[0..4] of tipo_roms=(
        (n:'c_5et_g.bin';l:$1000;p:0;crc:$ba70b88b),(n:'c_5ct_g.bin';l:$1000;p:$1000;crc:$5ec461ec),
        (n:'c_5bt_g.bin';l:$1000;p:$2000;crc:$1c97d324),(n:'c_5at_g.bin';l:$1000;p:$3000;crc:$b9005ac0),());
        dkong_pal:array[0..3] of tipo_roms=(
        (n:'c-2k.bpr';l:$100;p:0;crc:$e273ede5),(n:'c-2j.bpr';l:$100;p:$100;crc:$d6412358),
        (n:'v-5e.bpr';l:$100;p:$200;crc:$b869b8f5),());
        dkong_char:array[0..2] of tipo_roms=(
        (n:'v_5h_b.bin';l:$800;p:0;crc:$12c8c95d),(n:'v_3pt.bin';l:$800;p:$800;crc:$15e9c5e9),());
        dkong_sprites:array[0..4] of tipo_roms=(
        (n:'l_4m_b.bin';l:$800;p:0;crc:$59f8054d),(n:'l_4n_b.bin';l:$800;p:$800;crc:$672e4714),
        (n:'l_4r_b.bin';l:$800;p:$1000;crc:$feaa59ee),(n:'l_4s_b.bin';l:$800;p:$1800;crc:$20f2ef7e),());
        cant_samples=24;
        dk_samples:array[0..cant_samples] of tipo_nombre_samples=(
        (nombre:'death.wav'),(nombre:'tune01.wav'),(nombre:'tune02.wav'),
        (nombre:'tune03.wav';restart:true),(nombre:'tune04.wav';restart:false;loop:true),
        (nombre:'tune05.wav'),(nombre:'tune06.wav'),(nombre:'tune07.wav'),
        (nombre:'tune08_1.wav'),(nombre:'tune08_2.wav';restart:false;loop:true),
        (nombre:'tune09_1.wav'),(nombre:'tune09_2.wav';restart:false;loop:true),
        (nombre:'tune11_1.wav'),(nombre:'tune11_2.wav';restart:false;loop:true),
        (nombre:'tune12.wav'),(nombre:'tune13.wav'),(nombre:'tune14.wav'),(nombre:'tune15.wav'),
        (nombre:'ef01_1.wav'),(nombre:'ef01_2.wav'),(nombre:'ef02.wav'),
        (nombre:'ef03.wav';restart:true),(nombre:'ef04.wav'),(nombre:'ef05.wav'),(nombre:'ef06.wav'));
        dk_dip_a:array [0..4] of def_dip=(
        (mask:$3;name:'Lives';number:4;dip:((dip_val:$0;dip_name:'3'),(dip_val:$1;dip_name:'4'),(dip_val:$2;dip_name:'5'),(dip_val:$3;dip_name:'6'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Bonus Life';number:4;dip:((dip_val:$0;dip_name:'7k'),(dip_val:$4;dip_name:'10k'),(dip_val:$8;dip_name:'15k'),(dip_val:$c;dip_name:'20k'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$70;name:'Coinage';number:8;dip:((dip_val:$70;dip_name:'5C 1C'),(dip_val:$50;dip_name:'4C 1C'),(dip_val:$30;dip_name:'3C 1C'),(dip_val:$10;dip_name:'2C 1C'),(dip_val:$0;dip_name:'1C 1C'),(dip_val:$20;dip_name:'1C 2C'),(dip_val:$40;dip_name:'1C 3C'),(dip_val:$40;dip_name:'1C 4C'),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Cabinet';number:2;dip:((dip_val:$80;dip_name:'Upright'),(dip_val:$0;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        //Donkey Kong Jr.
        dkongjr_rom:array[0..3] of tipo_roms=(
        (n:'dkj.5b';l:$2000;p:0;crc:$dea28158),(n:'dkj.5c';l:$2000;p:$2000;crc:$6fb5faf6),
        (n:'dkj.5e';l:$2000;p:$4000;crc:$d042b6a8),());
        dkongjr_pal:array[0..3] of tipo_roms=(
        (n:'c-2e.bpr';l:$100;p:0;crc:$463dc7ad),(n:'c-2f.bpr';l:$100;p:$100;crc:$47ba0042),
        (n:'v-2n.bpr';l:$100;p:$200;crc:$dbf185bf),());
        dkongjr_char:array[0..2] of tipo_roms=(
        (n:'dkj.3n';l:$1000;p:0;crc:$8d51aca9),(n:'dkj.3p';l:$1000;p:$1000;crc:$4ef64ba5),());
        dkongjr_sprites:array[0..4] of tipo_roms=(
        (n:'v_7c.bin';l:$800;p:0;crc:$dc7f4164),(n:'v_7d.bin';l:$800;p:$800;crc:$0ce7dcf6),
        (n:'v_7e.bin';l:$800;p:$1000;crc:$24d1ff17),(n:'v_7f.bin';l:$800;p:$1800;crc:$0f8c083f),());
        cant_samples_jr=21;
        dkjr_samples:array[0..cant_samples_jr] of tipo_nombre_samples=(
        (nombre:'death.wav'),(nombre:'tune01.wav';restart:false;loop:true),
        (nombre:'tune02.wav'),(nombre:'tune03.wav'),(nombre:'tune04.wav'),
        (nombre:'tune05.wav'),(nombre:'tune06.wav'),(nombre:'tune07.wav'),
        (nombre:'tune08.wav'),(nombre:'tune09.wav'),(nombre:'tune10.wav'),
        (nombre:'tune11.wav'),(nombre:'tune12.wav'),(nombre:'tune13.wav'),
        (nombre:'tune14.wav'),(nombre:'ef01.wav';restart:true),(nombre:'ef02.wav';restart:true),(nombre:'ef03.wav';restart:true),
        (nombre:'ef04.wav'),(nombre:'ef05.wav'),(nombre:'ef06.wav'),(nombre:'ef07.wav'));
        //Donkey Kong 3
        dkong3_rom:array[0..4] of tipo_roms=(
        (n:'dk3c.7b';l:$2000;p:0;crc:$38d5f38e),(n:'dk3c.7c';l:$2000;p:$2000;crc:$c9134379),
        (n:'dk3c.7d';l:$2000;p:$4000;crc:$d22e2921),(n:'dk3c.7e';l:$2000;p:$8000;crc:$615f14b7),());
        dkong3_pal:array[0..3] of tipo_roms=(
        (n:'dkc1-c.1d';l:$200;p:0;crc:$df54befc),(n:'dkc1-c.1c';l:$200;p:$200;crc:$66a77f40),
        (n:'dkc1-v.2n';l:$100;p:$400;crc:$50e33434),());
        dkong3_char:array[0..2] of tipo_roms=(
        (n:'dk3v.3n';l:$1000;p:0;crc:$415a99c7),(n:'dk3v.3p';l:$1000;p:$1000;crc:$25744ea0),());
        dkong3_sprites:array[0..4] of tipo_roms=(
        (n:'dk3v.7c';l:$1000;p:0;crc:$8ffa1737),(n:'dk3v.7d';l:$1000;p:$1000;crc:$9ac84686),
        (n:'dk3v.7e';l:$1000;p:$2000;crc:$0c0af3fb),(n:'dk3v.7f';l:$1000;p:$3000;crc:$55c58662),());
        dkong3_snd1:tipo_roms=(n:'dk3c.5l';l:$2000;p:$e000;crc:$7ff88885);
        dkong3_snd2:tipo_roms=(n:'dk3c.6h';l:$2000;p:$e000;crc:$36d7200c);
        dk3_dip_a:array [0..2] of def_dip=(
        (mask:$7;name:'Coinage';number:8;dip:((dip_val:$2;dip_name:'3C 1C'),(dip_val:$4;dip_name:'2C 1C'),(dip_val:$0;dip_name:'1C 1C'),(dip_val:$6;dip_name:'1C 2C'),(dip_val:$1;dip_name:'1C 3C'),(dip_val:$3;dip_name:'1C 4C'),(dip_val:$5;dip_name:'1C 5C'),(dip_val:$7;dip_name:'1C 6C'),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$80;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        dk3_dip_b:array [0..4] of def_dip=(
        (mask:$3;name:'Lives';number:4;dip:((dip_val:$0;dip_name:'3'),(dip_val:$1;dip_name:'4'),(dip_val:$2;dip_name:'5'),(dip_val:$3;dip_name:'6'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Bonus Life';number:4;dip:((dip_val:$0;dip_name:'30k'),(dip_val:$4;dip_name:'40k'),(dip_val:$8;dip_name:'50k'),(dip_val:$c;dip_name:'None'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Additinoal Bonus';number:4;dip:((dip_val:$0;dip_name:'30k'),(dip_val:$10;dip_name:'40k'),(dip_val:$20;dip_name:'50k'),(dip_val:$30;dip_name:'None'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Difficulty';number:4;dip:((dip_val:$0;dip_name:'Easy'),(dip_val:$40;dip_name:'Medium'),(dip_val:$80;dip_name:'Hard'),(dip_val:$c0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),());
type
    tipo_tunes_def=procedure(valor:byte);
    tipo_effects_def=procedure(direccion,valor:byte);
var
 colores_char:array[0..$ff] of byte;
 haz_nmi,hay_samples:boolean;
 npaleta,latch1,latch2,latch3:byte;
 sprite_bank,char_bank:word;
 audio_tunes:tipo_tunes_def;
 audio_effects:tipo_effects_def;
 //dkong
 tune01,tune08,tune09,tune11:byte;
 effect0,effect1,effect2:byte;

implementation

procedure Cargar_dkong;
begin
llamadas_maquina.iniciar:=iniciar_dkong;
llamadas_maquina.cerrar:=cerrar_dkong;
llamadas_maquina.reset:=reset_dkong;
llamadas_maquina.fps_max:=60.6060606060606060;
case main_vars.tipo_maquina of
  15,168:llamadas_maquina.bucle_general:=dkong_principal;
  169:llamadas_maquina.bucle_general:=dkong3_principal;
end;
end;

function iniciar_dkong:boolean;
var
  memoria_temp:array[0..$5fff] of byte;
const
      pc_x:array[0..7] of dword=(0, 1, 2, 3, 4, 5, 6, 7);
      pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
      ps_dkong_x:array[0..15] of dword=(0, 1, 2, 3, 4, 5, 6, 7,
		  	  64*16*16+0, 64*16*16+1, 64*16*16+2, 64*16*16+3, 64*16*16+4, 64*16*16+5, 64*16*16+6, 64*16*16+7);
      ps_dkong3_x:array[0..15] of dword=(0, 1, 2, 3, 4, 5, 6, 7,
		  	  128*16*16+0, 128*16*16+1, 128*16*16+2, 128*16*16+3, 128*16*16+4, 128*16*16+5, 128*16*16+6, 128*16*16+7);
      ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
    			8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8);

procedure dkong_char_load(num_char:word);
begin
  init_gfx(0,8,8,num_char);
  gfx_set_desc_data(2,0,8*8,num_char*8*8,0);
  convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],true,false);
end;
procedure dkong_sprites_load(num_spr:word);
begin
  init_gfx(1,16,16,num_spr);
  gfx[1].trans[0]:=true;
  gfx_set_desc_data(2,0,16*8,num_spr*16*16,0);
  case main_vars.tipo_maquina of
    15,168:convert_gfx(1,0,@memoria_temp[0],@ps_dkong_x[0],@ps_y[0],true,false);
    169:convert_gfx(1,0,@memoria_temp[0],@ps_dkong3_x[0],@ps_y[0],true,false);
  end;
end;
procedure pal_dkong;
var
  ctemp1,ctemp2:byte;
  colores:tpaleta;
  f:word;
begin
for f:=0 to 255 do begin
  ctemp1:=memoria_temp[f+$100];
  ctemp2:=memoria_temp[f];
  colores[f].r:=not(($21*((ctemp1 shr 1) and 1))+($47*((ctemp1 shr 2) and 1))+($97*((ctemp1 shr 3) and 1)));
  colores[f].g:=not(($21*((ctemp2 shr 2) and 1))+($47*((ctemp2 shr 3) and 1))+($97*(ctemp1 and 1)));
  colores[f].b:=not(($55*(ctemp2 and 1))+($aa*((ctemp2 shr 1) and 1)));
end;
set_pal(colores,256);
copymemory(@colores_char[0],@memoria_temp[$200],$100);
end;
procedure pal_dkong3;
var
  ctemp1,ctemp2:byte;
  colores:tpaleta;
  f:word;
begin
for f:=0 to 255 do begin
  ctemp1:=memoria_temp[f];
  ctemp2:=memoria_temp[f+$200];
  colores[f].r:=not($0e*((ctemp1 shr 4) and 1)+$1f*((ctemp1 shr 5) and 1)+$43*((ctemp1 shr 6) and 1)+$8f*((ctemp1 shr 7) and 1));
  colores[f].g:=not($0e*((ctemp1 shr 0) and 1)+$1f*((ctemp1 shr 1) and 1)+$43*((ctemp1 shr 2) and 1)+$8f*((ctemp1 shr 3) and 1));
  colores[f].b:=not($0e*((ctemp2 shr 0) and 1)+$1f*((ctemp2 shr 1) and 1)+$43*((ctemp2 shr 2) and 1)+$8f*((ctemp2 shr 3) and 1));
end;
set_pal(colores,256);
copymemory(@colores_char[0],@memoria_temp[$400],$100);
end;

begin
iniciar_dkong:=false;
iniciar_audio(false);
//Pantallas:  principal+char y sprites
screen_init(1,256,256);
screen_init(2,256,256,false,true);
iniciar_video(224,256);
case main_vars.tipo_maquina of
  15:begin //Donkey Kong
        //Main CPU
        main_z80:=cpu_z80.create(3072000,264);
        main_z80.change_ram_calls(dkong_getbyte,dkong_putbyte);
        //cargar roms
        if not(cargar_roms(@memoria[0],@dkong_rom[0],'dkong.zip',0)) then exit;
        //samples
        hay_samples:=load_samples('dkong.zip',@dk_samples[0],cant_samples+1);
        if hay_samples then main_z80.init_sound(dkong_sound_update);
        audio_tunes:=dkong_tune_sound;
        audio_effects:=dkong_effects_sound;
        //convertir chars
        if not(cargar_roms(@memoria_temp[0],@dkong_char[0],'dkong.zip',0)) then exit;
        dkong_char_load($100);
        //convertir sprites
        if not(cargar_roms(@memoria_temp[0],@dkong_sprites[0],'dkong.zip',0)) then exit;
        dkong_sprites_load($80);
        //poner la paleta
        if not(cargar_roms(@memoria_temp[0],@dkong_pal[0],'dkong.zip',0)) then exit;
        pal_dkong;
        //DIP
        marcade.dswa:=$80;
        marcade.dswa_val:=@dk_dip_a;
     end;
 168:begin //Donkey Kong Jr.
        //Main CPU
        main_z80:=cpu_z80.create(3072000,264);
        main_z80.change_ram_calls(dkong_getbyte,dkong_putbyte);
        //cargar roms
        if not(cargar_roms(@memoria_temp[0],@dkongjr_rom[0],'dkongjr.zip',0)) then exit;
        copymemory(@memoria[0],@memoria_temp[0],$1000);
        copymemory(@memoria[$3000],@memoria_temp[$1000],$1000);
        copymemory(@memoria[$2000],@memoria_temp[$2000],$800);
        copymemory(@memoria[$4800],@memoria_temp[$2800],$800);
        copymemory(@memoria[$1000],@memoria_temp[$3000],$800);
        copymemory(@memoria[$5800],@memoria_temp[$3800],$800);
        copymemory(@memoria[$4000],@memoria_temp[$4000],$800);
        copymemory(@memoria[$2800],@memoria_temp[$4800],$800);
        copymemory(@memoria[$5000],@memoria_temp[$5000],$800);
        copymemory(@memoria[$1800],@memoria_temp[$5800],$800);
        //samples
        hay_samples:=load_samples('dkongjr.zip',@dkjr_samples[0],cant_samples_jr+1);
        if hay_samples then main_z80.init_sound(dkong_sound_update);
        audio_tunes:=dkongjr_tune_sound;
        audio_effects:=dkongjr_effects_sound;
        //convertir chars
        if not(cargar_roms(@memoria_temp[0],@dkongjr_char[0],'dkongjr.zip',0)) then exit;
        dkong_char_load($200);
        //convertir sprites
        if not(cargar_roms(@memoria_temp[0],@dkongjr_sprites[0],'dkongjr.zip',0)) then exit;
        dkong_sprites_load($80);
        //poner la paleta
        if not(cargar_roms(@memoria_temp[0],@dkongjr_pal[0],'dkongjr.zip',0)) then exit;
        pal_dkong;
        //DIP
        marcade.dswa:=$80;
        marcade.dswa_val:=@dk_dip_a;
     end;
 169:begin //Donkey Kong 3
        //Main CPU
        main_z80:=cpu_z80.create(4000000,264);
        main_z80.change_ram_calls(dkong3_getbyte,dkong3_putbyte);
        //cargar roms
        if not(cargar_roms(@memoria[0],@dkong3_rom[0],'dkong3.zip',0)) then exit;
        //sound 1
        if not(cargar_roms(@mem_snd[0],@dkong3_snd1,'dkong3.zip')) then exit;
        main_m6502:=cpu_m6502.create(1789772,264,TCPU_M6502);
        main_m6502.change_ram_calls(dkong3_snd1_getbyte,dkong3_snd1_putbyte);
        main_m6502.init_sound(dkong3_sound_update);
        init_n2a03_sound(0,nil,nil);
        //sound 2
        if not(cargar_roms(@mem_misc[0],@dkong3_snd2,'dkong3.zip')) then exit;
        snd_m6502:=cpu_m6502.create(1789772,264,TCPU_M6502);
        snd_m6502.change_ram_calls(dkong3_snd2_getbyte,dkong3_snd2_putbyte);
        init_n2a03_sound(1,nil,nil);
        //convertir chars
        if not(cargar_roms(@memoria_temp[0],@dkong3_char[0],'dkong3.zip',0)) then exit;
        dkong_char_load($200);
        //convertir sprites
        if not(cargar_roms(@memoria_temp[0],@dkong3_sprites[0],'dkong3.zip',0)) then exit;
        dkong_sprites_load($100);
        //poner la paleta
        if not(cargar_roms(@memoria_temp[0],@dkong3_pal[0],'dkong3.zip',0)) then exit;
        pal_dkong3;
        //DIP
        marcade.dswa:=$0;
        marcade.dswa_val:=@dk3_dip_a;
        marcade.dswb:=$0;
        marcade.dswb_val:=@dk3_dip_b;
     end;
end;
//final
reset_dkong;
iniciar_dkong:=true;
end;

procedure cerrar_dkong;
begin
main_z80.free;
case main_vars.tipo_maquina of
  15,168:close_samples;
  169:begin
        close_n2a03_sound(0);
        close_n2a03_sound(1);
        main_m6502.free;
        snd_m6502.free;
      end;
end;
close_audio;
close_video;
end;

procedure reset_dkong;
begin
 main_z80.reset;
 case main_vars.tipo_maquina of
    15:begin
        marcade.in2:=0;
        if hay_samples then reset_samples;
        tune08:=0;
        tune09:=0;
        tune11:=0;
        effect0:=0;
       end;
   168:begin
        marcade.in2:=$40;
        if hay_samples then reset_samples;
        effect0:=0;
        effect1:=0;
        effect2:=0;
       end;
   169:begin
        marcade.in2:=0;
        main_m6502.reset;
        snd_m6502.reset;
        reset_n2a03_sound(0);
        reset_n2a03_sound(1);
        latch1:=0;
        latch2:=0;
        latch3:=0;
       end;
 end;
 reset_audio;
 marcade.in0:=0;
 marcade.in1:=0;
 marcade.in2:=0;
 haz_nmi:=false;
 npaleta:=0;
 sprite_bank:=0;
 char_bank:=0;
end;

procedure update_video_dkong;inline;
var
  f,color,nchar:word;
  x,y,atrib,atrib2:byte;
begin
//Poner chars
for f:=$3ff downto 0 do
 if gfx[0].buffer[f] then begin
  y:=f mod 32;
  x:=f div 32;
  color:=((colores_char[y+32*(x shr 2)] and $f) shl 2)+(npaleta shl 6);
  nchar:=memoria[$7400+f]+char_bank;
  put_gfx(248-(x*8),y*8,nchar,color,1,0);
  gfx[0].buffer[f]:=false;
end;;
actualiza_trozo(0,0,256,256,1,0,0,256,256,2);
//Sprites
for f:=0 to $5f do begin
  atrib:=memoria[$7001+(f*4)+sprite_bank];
  atrib2:=memoria[$7002+(f*4)+sprite_bank];
  color:=((atrib2 and $f) shl 2)+(npaleta shl 6);
  nchar:=(atrib and $7f)+((atrib2 and $40) shl 1);
  put_gfx_sprite(nchar,color,(atrib and $80)<>0,(atrib2 and $80)<>0,1);
  x:=memoria[$7000+(f*4)+sprite_bank];
  y:=memoria[$7003+(f*4)+sprite_bank];
  actualiza_gfx_sprite(x-7,y-8,2,1);
end;
actualiza_trozo_final(16,0,224,256,2);
end;

procedure eventos_dkong;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 or $4) else marcade.in0:=(marcade.in0 and $fb);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 or $8) else marcade.in0:=(marcade.in0 and $F7);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 or $2) else marcade.in0:=(marcade.in0 and $fd);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 or $1) else marcade.in0:=(marcade.in0 and $Fe);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 or $10) else marcade.in0:=(marcade.in0 and $ef);
  //P2
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 or $4) else marcade.in1:=(marcade.in1 and $fb);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 or $8) else marcade.in1:=(marcade.in1 and $F7);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 or $2) else marcade.in1:=(marcade.in1 and $fd);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 or $1) else marcade.in1:=(marcade.in1 and $Fe);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 or $10) else marcade.in1:=(marcade.in1 and $ef);
  //SYS
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 or $80) else marcade.in2:=(marcade.in2 and $7f);
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 or $4) else marcade.in2:=(marcade.in2 and $fb);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 or $8) else marcade.in2:=(marcade.in2 and $f7);
end;
end;

procedure dkong_principal;
var
  frame:single;
  f:word;
begin
init_controls(false,false,false,true);
frame:=main_z80.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to 263 do begin
    main_z80.run(frame);
    frame:=frame+main_z80.tframes-main_z80.contador;
    if f=239 then begin
      if haz_nmi then main_z80.pedir_nmi:=PULSE_LINE;
      update_video_dkong;
    end;
  end;
  eventos_dkong;
  video_sync;
end;
end;

function dkong_getbyte(direccion:word):byte;
begin
case direccion of
     $0..$6bff,$7000..$77ff:dkong_getbyte:=memoria[direccion];
     $7c00:dkong_getbyte:=marcade.in0;
     $7c80:dkong_getbyte:=marcade.in1;
     $7d00:dkong_getbyte:=marcade.in2;
     $7d80:dkong_getbyte:=marcade.dswa;
end;
end;

procedure dkong_tune_sound(valor:byte);inline;
begin
case valor of
  1:begin
      stop_all_samples;
      start_sample(1);
    end;
  2:begin
      stop_all_samples;
      start_sample(2);
    end;
  3:start_sample(3);
  4:begin
      stop_sample(9);
      stop_sample(11);
      stop_sample(13);
      start_sample(4);
      tune08:=0;
      tune09:=0;
      tune11:=0;
    end;
  5:begin
      stop_all_samples;
      start_sample(5);
    end;
  6:start_sample(6);
  7:begin
      stop_all_samples;
      start_sample(7);
    end;
  8:if tune08=0 then begin
      stop_all_samples;
      start_sample(8);
      tune08:=1;
    end else start_sample(9);
  9:if tune09=0 then begin
      stop_all_samples;
      start_sample(10);
      tune09:=1;
    end else start_sample(11);
  11:if tune11=0 then begin
      stop_all_samples;
      start_sample(12);
      tune11:=1;
     end else start_sample(13);
  12:start_sample(14);
  13:start_sample(15);
  14:begin
      stop_sample(13);
      start_sample(16);
      tune11:=0;
     end;
  15:start_sample(17);
end;
end;

procedure dkong_effects_sound(direccion,valor:byte);inline;
begin
case direccion of
  $0:begin
        if ((effect0=0) and ((valor and 1)=1)) then start_sample(18);
        if ((effect0=1) and ((valor and 1)=0)) then start_sample(19);
        effect0:=valor and 1;
     end;
  $1:if (valor<>0) then start_sample(20);
  $2:if (valor<>0) then start_sample(21);
  $3:if (valor<>0) then start_sample(22);
  $4:if (valor<>0) then start_sample(23);
  $5:if (valor<>0) then start_sample(24);
end;
end;

procedure dkongjr_tune_sound(valor:byte);inline;
begin
case valor of
  1:if tune01=0 then begin
        stop_all_samples;
        tune01:=1;
    end else start_sample(1);
  2:start_sample(2);
  3:start_sample(3);
  4:start_sample(4);
  5:start_sample(5);
  6:start_sample(6);
  7:start_sample(7);
  8:start_sample(8);
  9:begin
      stop_sample(1);
      start_sample(9);
      tune01:=0;
    end;
  10:start_sample(10);
  11:begin
      stop_sample(3);
      start_sample(11);
     end;
  12:start_sample(12);
  13:start_sample(13);
  14:begin
      stop_sample(4);
      start_sample(14);
     end;
end;
end;

procedure dkongjr_effects_sound(direccion,valor:byte);inline;
begin
case direccion of
  $0:begin
       if ((effect0=1) and ((valor and 1)=0)) then start_sample(15);
       effect0:=valor and 1;
     end;
  $1:begin
       if ((effect1=1) and ((valor and 1)=0)) then start_sample(16);
       effect1:=valor and 1;
     end;
  $2:begin
       if ((effect2=1) and ((valor and 1)=0)) then start_sample(17);
       effect2:=valor and 1;
     end;
  $3:if (valor<>0) then start_sample(18);
  $4:if (valor<>0) then start_sample(19);
  $5:if (valor<>0) then start_sample(20);
  $6:if (valor<>0) then start_sample(21);
end;

end;

procedure dkong_putbyte(direccion:word;valor:byte);
begin
if direccion<$6000 then exit;
memoria[direccion]:=valor;
case direccion of
        $7c00:if hay_samples then audio_tunes(valor);
        $7400..$77ff:gfx[0].buffer[direccion and $3ff]:=true;
        $7c80:if char_bank<>((valor and 1)*$100) then begin
                fillchar(gfx[0].buffer[0],$400,1);
                char_bank:=(valor and 1)*$100;
              end;
        $7d00..$7d07:if hay_samples then audio_effects(direccion and 7,valor);
        $7d80:if ((valor<>0) and hay_samples) then begin  //death
                  stop_all_samples;
                  start_sample(0);
              end;
        $7e82:main_screen.flip_main_screen:=(valor and 1)=0;
        $7d83:sprite_bank:=$200*(valor and 1);
        $7d84:haz_nmi:=(valor=1);
        $7d85:if (valor and 1)<>0 then copymemory(@memoria[$7000],@memoria[$6900],$400);
        $7d86:if npaleta<>((npaleta and 2) or (valor and 1)) then begin
                npaleta:=(npaleta and 2) or (valor and 1);
                fillchar(gfx[0].buffer[0],$400,1);
              end;
        $7d87:if npaleta<>((npaleta and 1) or ((valor and 1) shl 1)) then begin
                npaleta:=(npaleta and 1) or ((valor and 1) shl 1);
                fillchar(gfx[0].buffer[0],$400,1);
              end;
end;
end;

procedure dkong_sound_update;
begin
  samples_update;
end;

//Dkong 3
procedure eventos_dkong3;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 or $4) else marcade.in0:=(marcade.in0 and $fb);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 or $8) else marcade.in0:=(marcade.in0 and $F7);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 or $2) else marcade.in0:=(marcade.in0 and $fd);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 or $1) else marcade.in0:=(marcade.in0 and $Fe);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 or $10) else marcade.in0:=(marcade.in0 and $ef);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 or $20) else marcade.in0:=(marcade.in0 and $df);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 or $40) else marcade.in0:=(marcade.in0 and $bf);
  //P2
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 or $4) else marcade.in1:=(marcade.in1 and $fb);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 or $8) else marcade.in1:=(marcade.in1 and $F7);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 or $2) else marcade.in1:=(marcade.in1 and $fd);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 or $1) else marcade.in1:=(marcade.in1 and $Fe);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 or $10) else marcade.in1:=(marcade.in1 and $ef);
  if arcade_input.coin[0] then marcade.in1:=(marcade.in1 or $20) else marcade.in1:=(marcade.in1 and $df);
  if arcade_input.coin[1] then marcade.in1:=(marcade.in1 or $40) else marcade.in1:=(marcade.in1 and $bf);
end;
end;

procedure dkong3_principal;
var
  frame_m,frame_s1,frame_s2:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=main_z80.tframes;
frame_s1:=main_m6502.tframes;
frame_s2:=snd_m6502.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to 263 do begin
    //Main CPU
    main_z80.run(frame_m);
    frame_m:=frame_m+main_z80.tframes-main_z80.contador;
    //SND 1
    main_m6502.run(frame_s1);
    frame_s1:=frame_s1+main_m6502.tframes-main_m6502.contador;
    //SND 2
    snd_m6502.run(frame_s2);
    frame_s2:=frame_s2+snd_m6502.tframes-snd_m6502.contador;
    if f=239 then begin
      if haz_nmi then begin
        main_z80.pedir_nmi:=PULSE_LINE;
        main_m6502.pedir_nmi:=PULSE_LINE;
        snd_m6502.pedir_nmi:=PULSE_LINE;
      end;
      update_video_dkong;
    end;
  end;
  eventos_dkong3;
  video_sync;
end;
end;

function dkong3_getbyte(direccion:word):byte;
begin
case direccion of
     $0..$77ff,$8000..$9fff:dkong3_getbyte:=memoria[direccion];
     $7c00:dkong3_getbyte:=marcade.in0;
     $7c80:dkong3_getbyte:=marcade.in1;
     $7d00:dkong3_getbyte:=marcade.dswa;
     $7d80:dkong3_getbyte:=marcade.dswb;
end;
end;

procedure dkong3_putbyte(direccion:word;valor:byte);
begin
if ((direccion<$6000) or ((direccion>$7fff) and (direccion<$a000))) then exit;
memoria[direccion]:=valor;
case direccion of
        $7400..$77ff:gfx[0].buffer[direccion and $3ff]:=true;
        $7c00:latch1:=valor;
        $7c80:latch2:=valor;
        $7d00:latch3:=valor;
        $7d80:if ((valor and $1)<>0) then begin
                main_m6502.pedir_reset:=CLEAR_LINE;
                snd_m6502.pedir_reset:=CLEAR_LINE;
              end else begin
                  main_m6502.pedir_reset:=ASSERT_LINE;
                  reset_n2a03_sound(0);
                  snd_m6502.pedir_reset:=ASSERT_LINE;
                  reset_n2a03_sound(1);
              end;
        $7e81:if char_bank<>((not(valor) and 1)*$100) then begin
                fillchar(gfx[0].buffer[0],$400,1);
                char_bank:=(not(valor) and 1)*$100;
              end;
        $7e82:main_screen.flip_main_screen:=(valor and 1)=0;
        $7e83:sprite_bank:=$200*(valor and 1);
        $7e84:haz_nmi:=(valor=1);
        $7e85:if (valor and 1)<>0 then copymemory(@memoria[$7000],@memoria[$6900],$400);
        $7e86:if npaleta<>((npaleta and 2) or (valor and 1)) then begin
                npaleta:=(npaleta and 2) or (valor and 1);
                fillchar(gfx[0].buffer[0],$400,1);
              end;
        $7e87:if npaleta<>((npaleta and 1) or ((valor and 1) shl 1)) then begin
                npaleta:=(npaleta and 1) or ((valor and 1) shl 1);
                fillchar(gfx[0].buffer[0],$400,1);
              end;
end;
end;

function dkong3_snd1_getbyte(direccion:word):byte;
begin
  case direccion of
    $0..$1ff,$e000..$ffff:dkong3_snd1_getbyte:=mem_snd[direccion];
    $4000..$4015:dkong3_snd1_getbyte:=n2a03_read(0,direccion);
    $4016:dkong3_snd1_getbyte:=latch1;
    $4017:dkong3_snd1_getbyte:=latch2;
  end;
end;

procedure dkong3_snd1_putbyte(direccion:word;valor:byte);
begin
if direccion>$dfff then exit;
case direccion of
    0..$1ff:mem_snd[direccion]:=valor;
    $4000..$4017:n2a03_write(0,direccion,valor);
  end;
end;

function dkong3_snd2_getbyte(direccion:word):byte;
begin
  case direccion of
    $0..$1ff,$e000..$ffff:dkong3_snd2_getbyte:=mem_misc[direccion];
    $4000..$4015,$4017:dkong3_snd2_getbyte:=n2a03_read(1,direccion);
    $4016:dkong3_snd2_getbyte:=latch3;
  end;
end;

procedure dkong3_snd2_putbyte(direccion:word;valor:byte);
begin
if direccion>$dfff then exit;
case direccion of
    0..$1ff:mem_misc[direccion]:=valor;
    $4000..$4017:n2a03_write(1,direccion,valor);
  end;
end;

procedure dkong3_sound_update;
begin
  n2a03_sound_update(0);
  n2a03_sound_update(1);
end;

end.
