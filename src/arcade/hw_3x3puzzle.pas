unit hw_3x3puzzle;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m68000,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     oki6295,sound_engine;

function iniciar_puzz3x3:boolean;

implementation
const
        puzz3x3_rom:array[0..1] of tipo_roms=(
        (n:'1.bin';l:$20000;p:0;crc:$e9c39ee7),(n:'2.bin';l:$20000;p:$1;crc:$524963be));
        puzz3x3_gfx1:array[0..3] of tipo_roms=(
        (n:'3.bin';l:$80000;p:0;crc:$53c2aa6a),(n:'4.bin';l:$80000;p:1;crc:$fb0b76fd),
        (n:'5.bin';l:$80000;p:2;crc:$b6c1e108),(n:'6.bin';l:$80000;p:3;crc:$47cb0e8e));
        puzz3x3_gfx2:array[0..3] of tipo_roms=(
        (n:'7.bin';l:$20000;p:0;crc:$45b1f58b),(n:'8.bin';l:$20000;p:1;crc:$c0d404a7),
        (n:'9.bin';l:$20000;p:2;crc:$6b303aa9),(n:'10.bin';l:$20000;p:3;crc:$6d0107bc));
        puzz3x3_gfx3:array[0..3] of tipo_roms=(
        (n:'11.bin';l:$20000;p:0;crc:$e124c0b5),(n:'12.bin';l:$20000;p:1;crc:$ae4a8707),
        (n:'13.bin';l:$20000;p:2;crc:$f06925d1),(n:'14.bin';l:$20000;p:3;crc:$07252636));
        puzz3x3_oki:tipo_roms=(n:'15.bin';l:$80000;p:0;crc:$d3aff355);
        puzz3x3_dip_a:array [0..4] of def_dip=(
        (mask:$0300;name:'Coinage';number:4;dip:((dip_val:$300;dip_name:'1C 1C'),(dip_val:$200;dip_name:'1C 2C'),(dip_val:$100;dip_name:'2C 1C'),(dip_val:$0;dip_name:'3C 1C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0400;name:'Demo Sounds';number:2;dip:((dip_val:$400;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$1800;name:'Difficulty';number:4;dip:((dip_val:$1800;dip_name:'Normal'),(dip_val:$1000;dip_name:'Easy'),(dip_val:$800;dip_name:'Easiest'),(dip_val:$0000;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4000;name:'Free Play/Debug mode';number:2;dip:((dip_val:$4000;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        casanova_rom:array[0..1] of tipo_roms=(
        (n:'casanova.u7';l:$40000;p:1;crc:$869c2bf2),(n:'casanova.u8';l:$40000;p:$0;crc:$9df77f4b));
        casanova_gfx1:array[0..7] of tipo_roms=(
        (n:'casanova.u23';l:$80000;p:0;crc:$4bd4e5b1),(n:'casanova.u25';l:$80000;p:1;crc:$5461811b),
        (n:'casanova.u27';l:$80000;p:2;crc:$dd178379),(n:'casanova.u29';l:$80000;p:3;crc:$36469f9e),
        (n:'casanova.u81';l:$80000;p:$200000;crc:$9eafd37d),(n:'casanova.u83';l:$80000;p:$200001;crc:$9d4ce407),
        (n:'casanova.u85';l:$80000;p:$200002;crc:$113c6e3a),(n:'casanova.u87';l:$80000;p:$200003;crc:$61bd80f8));
        casanova_gfx2:array[0..3] of tipo_roms=(
        (n:'casanova.u45';l:$80000;p:0;crc:$530d78bc),(n:'casanova.u43';l:$80000;p:1;crc:$1462d7d6),
        (n:'casanova.u41';l:$80000;p:2;crc:$95f67e82),(n:'casanova.u39';l:$80000;p:3;crc:$97d4095a));
        casanova_gfx3:array[0..3] of tipo_roms=(
        (n:'casanova.u54';l:$80000;p:0;crc:$e60bf0db),(n:'casanova.u52';l:$80000;p:1;crc:$708f779c),
        (n:'casanova.u50';l:$80000;p:2;crc:$c73b5e98),(n:'casanova.u48';l:$80000;p:3;crc:$af9f59c5));
        casanova_oki:array[0..1] of tipo_roms=(
        (n:'casanova.su2';l:$80000;p:0;crc:$84a8320e),(n:'casanova.su3';l:$40000;p:$80000;crc:$334a2d1a));
        casanova_dip_a:array [0..4] of def_dip=(
        (mask:$3;name:'Coinage';number:4;dip:((dip_val:$2;dip_name:'1C 2C'),(dip_val:$3;dip_name:'1C 1C'),(dip_val:$1;dip_name:'2C 1C'),(dip_val:$0;dip_name:'3C 1C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Difficulty';number:4;dip:((dip_val:$8;dip_name:'Easy'),(dip_val:$c;dip_name:'Normal'),(dip_val:$4;dip_name:'Hard'),(dip_val:$0;dip_name:'Very Hard'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Demo Sounds';number:2;dip:((dip_val:$10;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Dip Info';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 rom:array[0..$3ffff] of word;
 ram:array[0..$7fff] of word;
 video1,video1_final:array[0..$3ff] of word;
 video2,video2_final,video3,video3_final:array[0..$7ff] of word;
 oki_rom:array[0..2,0..$3ffff] of byte;
 oki_bank:byte;
 t1scroll_x,t1scroll_y,vblank:word;
 copy_gfx,long_video:boolean;

procedure update_video_puzz3x3;
var
  f,nchar:word;
  x,y:byte;
begin
for f:=0 to $3ff do begin
  if gfx[0].buffer[f] then begin
    x:=f mod 32;
    y:=f div 32;
    nchar:=video1_final[f];
    put_gfx(x*16,y*16,nchar,0,1,0);
    gfx[0].buffer[f]:=false;
  end;
end;
for f:=0 to $7ff do begin
  x:=f mod 64;
  y:=f div 64;
  if gfx[1].buffer[f] then begin
    nchar:=video2_final[f];
    put_gfx_trans(x*8,y*8,nchar,$100,2,1);
    gfx[1].buffer[f]:=false;
  end;
  if gfx[2].buffer[f] then begin
    nchar:=video3_final[f];
    put_gfx_trans(x*8,y*8,nchar,$200,3,2);
    gfx[2].buffer[f]:=false;
  end;
end;
scroll_x_y(1,4,t1scroll_x,t1scroll_y);
actualiza_trozo(0,0,512,256,2,0,0,512,256,4);
actualiza_trozo(0,0,512,256,3,0,0,512,256,4);
if long_video then actualiza_trozo_final(0,0,512,240,4)
  else actualiza_trozo_final(0,0,320,240,4);
if copy_gfx then begin
  copymemory(@video1_final,@video1,$400*2);
  copymemory(@video2_final,@video2,$800*2);
  copymemory(@video3_final,@video3,$800*2);
  fillchar(gfx[0].buffer,$400,1);
  fillchar(gfx[1].buffer,$800,1);
  fillchar(gfx[2].buffer,$800,1);
end;
end;

procedure eventos_puzz3x3;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fffe) else marcade.in0:=(marcade.in0 or $0001);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fffd) else marcade.in0:=(marcade.in0 or $0002);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fffb) else marcade.in0:=(marcade.in0 or $0004);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fff7) else marcade.in0:=(marcade.in0 or $0008);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ffef) else marcade.in0:=(marcade.in0 or $0010);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $ffdf) else marcade.in0:=(marcade.in0 or $0020);
  //P2
  if arcade_input.up[1] then marcade.in0:=(marcade.in0 and $feff) else marcade.in0:=(marcade.in0 or $0100);
  if arcade_input.down[1] then marcade.in0:=(marcade.in0 and $fdff) else marcade.in0:=(marcade.in0 or $0200);
  if arcade_input.left[1] then marcade.in0:=(marcade.in0 and $fbff) else marcade.in0:=(marcade.in0 or $0400);
  if arcade_input.right[1] then marcade.in0:=(marcade.in0 and $f7ff) else marcade.in0:=(marcade.in0 or $0800);
  if arcade_input.but0[1] then marcade.in0:=(marcade.in0 and $efff) else marcade.in0:=(marcade.in0 or $1000);
  if arcade_input.but1[1] then marcade.in0:=(marcade.in0 and $dfff) else marcade.in0:=(marcade.in0 or $2000);
  //SYS
  if arcade_input.coin[0] then marcade.in1:=(marcade.in1 and $fffe) else marcade.in1:=(marcade.in1 or $0001);
  if arcade_input.coin[1] then marcade.in1:=(marcade.in1 and $fffd) else marcade.in1:=(marcade.in1 or $0002);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $fffb) else marcade.in1:=(marcade.in1 or $0004);
end;
end;

procedure puzz3x3_principal;
var
  frame:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame:=m68000_0.tframes;
while EmuStatus=EsRunning do begin
 for f:=0 to $ff do begin
   m68000_0.run(frame);
   frame:=frame+m68000_0.tframes-m68000_0.contador;
   case f of
      21:vblank:=0;
      247:begin
            vblank:=$ffff;
            m68000_0.irq[4]:=HOLD_LINE;
            update_video_puzz3x3;
          end;
   end;
 end;
 eventos_puzz3x3;
 video_sync;
end;
end;

function puzz3x3_getword(direccion:dword):word;
begin
case direccion of
  $0..$7ffff:puzz3x3_getword:=rom[direccion shr 1];
  $100000..$10ffff:puzz3x3_getword:=ram[(direccion and $ffff) shr 1];
  $200000..$2007ff:puzz3x3_getword:=video1[(direccion and $7ff) shr 1];
  $201000..$201fff:puzz3x3_getword:=video2[(direccion and $fff) shr 1];
  $202000..$202fff:puzz3x3_getword:=video3[(direccion and $fff) shr 1];
  $280000:puzz3x3_getword:=vblank;
  $300000..$3005ff:puzz3x3_getword:=buffer_paleta[(direccion and $7ff) shr 1];
  $500000:puzz3x3_getword:=marcade.in0;
  $580000:puzz3x3_getword:=marcade.in1;
  $600000:puzz3x3_getword:=marcade.dswa;
  $700000:puzz3x3_getword:=oki_6295_0.read;
end;
end;

procedure puzz3x3_putword(direccion:dword;valor:word);

procedure cambiar_color(tmp_color,numero:word);
var
  color:tcolor;
begin
  color.b:=pal5bit(tmp_color shr 10);
  color.g:=pal5bit(tmp_color shr 5);
  color.r:=pal5bit(tmp_color);
  set_pal_color(color,numero);
end;

begin
case direccion of
  0..$7ffff:; //ROM
  $100000..$10ffff:ram[(direccion and $ffff) shr 1]:=valor;
  $200000..$2007ff:if video1[(direccion and $7ff) shr 1]<>valor then begin
                    video1[(direccion and $7ff) shr 1]:=valor;
                    gfx[0].buffer[(direccion and $7ff) shr 1]:=true;
                   end;
  $201000..$201fff:if video2[(direccion and $fff) shr 1]<>valor then begin
                    video2[(direccion and $fff) shr 1]:=valor;
                    gfx[1].buffer[(direccion and $fff) shr 1]:=true;
                   end;
  $202000..$202fff:if video3[(direccion and $fff) shr 1]<>valor then begin
                    video3[(direccion and $fff) shr 1]:=valor;
                    gfx[2].buffer[(direccion and $fff) shr 1]:=true;
                   end;
  $300000..$3005ff:if (buffer_paleta[(direccion and $7ff) shr 1]<>valor) then begin
                      buffer_paleta[(direccion and $7ff) shr 1]:=valor;
                      cambiar_color(valor,(direccion and $7ff) shr 1);
                   end;
  $400000:t1scroll_x:=valor;
  $480000:t1scroll_y:=valor;
  $700000:oki_6295_0.write(valor and $ff);
  $800000:begin
            copy_gfx:=(valor and $20)<>0;
            if (valor and $10)<>0 then begin
              if not(long_video) then begin
                change_video_size(512,240);
                long_video:=true;
              end;
            end else begin
              if long_video then begin
                change_video_size(320,240);
                long_video:=false;
              end;
            end;
            if oki_bank<>(valor and 6) then begin
                oki_bank:=valor and 6;
                copymemory(oki_6295_0.get_rom_addr,@oki_rom[oki_bank shr 1,0],$40000);
            end;
          end;
end;
end;

procedure puzz3x3_sound_update;
begin
  oki_6295_0.update;
end;

//Main
procedure reset_puzz3x3;
begin
 m68000_0.reset;
 oki_6295_0.reset;
 reset_audio;
 oki_bank:=0;
 vblank:=$ffff;
 long_video:=true;
 copy_gfx:=false;
 change_video_size(512,240);
 t1scroll_x:=0;
 t1scroll_y:=0;
 marcade.in0:=$ffff;
 marcade.in1:=$ffff;
end;

function iniciar_puzz3x3:boolean;
const
  pc_x:array[0..7] of dword=(3*8,2*8,1*8,0*8,7*8,6*8,5*8,4*8);
  pc_y:array[0..7] of dword=(0*64, 1*64, 2*64, 3*64, 4*64, 5*64, 6*64, 7*64);
  pt_x:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
   8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8);
  pt_y:array[0..15] of dword=(0*128, 1*128, 2*128, 3*128, 4*128, 5*128, 6*128, 7*128,
   8*128, 9*128,10*128,11*128,12*128,13*128,14*128,15*128);
var
  memoria_temp:pbyte;
procedure convert_gfx1(num:word);
begin
  init_gfx(0,16,16,num);
  gfx_set_desc_data(8,0,128*16,0,1,2,3,4,5,6,7);
  convert_gfx(0,0,memoria_temp,@pt_x,@pt_y,false,false);
end;
procedure convert_gfx2(gfx_num:byte;num:word);
begin
  init_gfx(gfx_num,8,8,num);
  gfx[gfx_num].trans[0]:=true;
  gfx_set_desc_data(8,0,64*8,0,1,2,3,4,5,6,7);
  convert_gfx(gfx_num,0,memoria_temp,@pc_x,@pc_y,false,false);
end;
begin
iniciar_puzz3x3:=false;
llamadas_maquina.bucle_general:=puzz3x3_principal;
llamadas_maquina.reset:=reset_puzz3x3;
iniciar_audio(false);
screen_init(1,512,512);
screen_mod_scroll(1,512,512,511,512,512,511);
screen_init(2,512,256,true);
screen_init(3,512,256,true);
screen_init(4,512,512,false,true);
iniciar_video(512,240);
//Main CPU
m68000_0:=cpu_m68000.create(10000000,$100);
m68000_0.change_ram16_calls(puzz3x3_getword,puzz3x3_putword);
m68000_0.init_sound(puzz3x3_sound_update);
//OKI rom
oki_6295_0:=snd_okim6295.Create(1000000,OKIM6295_PIN7_HIGH);
//mem aux
getmem(memoria_temp,$400000);
case main_vars.tipo_maquina of
  281:begin //3x3 puzzle
        if not(roms_load16w(@rom,puzz3x3_rom)) then exit;
        if not(roms_load(memoria_temp,puzz3x3_oki)) then exit;
        copymemory(oki_6295_0.get_rom_addr,memoria_temp,$40000);
        copymemory(@oki_rom[0,0],memoria_temp,$40000);
        copymemory(@oki_rom[1,0],@memoria_temp[$40000],$40000);
        //gfx1
        if not(roms_load32b_b(memoria_temp,puzz3x3_gfx1)) then exit;
        convert_gfx1($2000);
        //gfx2
        fillchar(memoria_temp^,$200000,0);
        if not(roms_load32b_b(memoria_temp,puzz3x3_gfx2)) then exit;
        convert_gfx2(1,$2000);
        //gfx3
        fillchar(memoria_temp^,$200000,0);
        if not(roms_load32b_b(memoria_temp,puzz3x3_gfx3)) then exit;
        convert_gfx2(2,$2000);
        //Dip
        marcade.dswa:=$fbff;
        marcade.dswa_val:=@puzz3x3_dip_a;
      end;
  282:begin //Casanova
        if not(roms_load16w(@rom,casanova_rom)) then exit;
        if not(roms_load(memoria_temp,casanova_oki)) then exit;
        copymemory(oki_6295_0.get_rom_addr,memoria_temp,$40000);
        copymemory(@oki_rom[0,0],memoria_temp,$40000);
        copymemory(@oki_rom[1,0],@memoria_temp[$40000],$40000);
        copymemory(@oki_rom[2,0],@memoria_temp[$80000],$40000);
        //gfx1
        if not(roms_load32b_b(memoria_temp,casanova_gfx1)) then exit;
        convert_gfx1($4000);
        //gfx2
        fillchar(memoria_temp^,$400000,0);
        if not(roms_load32b_b(memoria_temp,casanova_gfx2)) then exit;
        convert_gfx2(1,$8000);
        //gfx3
        fillchar(memoria_temp^,$400000,0);
        if not(roms_load32b_b(memoria_temp,casanova_gfx3)) then exit;
        convert_gfx2(2,$8000);
        //Dip
        marcade.dswa:=$ffef;
        marcade.dswa_val:=@casanova_dip_a;
      end;
end;
//final
freemem(memoria_temp);
reset_puzz3x3;
iniciar_puzz3x3:=true;
end;

end.
