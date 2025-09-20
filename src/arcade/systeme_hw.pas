unit systeme_hw;

interface
uses nz80,{$IFDEF WINDOWS}windows,{$ENDIF}
     main_engine,controls_engine,sega_vdp,sn_76496,rom_engine,sound_engine,
     ppi8255,mc8123;

function iniciar_systeme:boolean;

implementation

const
  hangonjr_rom:array[0..4] of tipo_roms=(
  (n:'epr-7257b.ic7';l:$8000;p:0;crc:$d63925a7),(n:'epr-7258.ic5';l:$8000;p:$8000;crc:$ee3caab3),
  (n:'epr-7259.ic4';l:$8000;p:$10000;crc:$d2ba9bc9),(n:'epr-7260.ic3';l:$8000;p:$18000;crc:$e14da070),
  (n:'epr-7261.ic2';l:$8000;p:$20000;crc:$3810cbf5));
  hangonjr_dip_b:array [0..2] of def_dip=(
  (mask:$6;name:'Enemies';number:4;dip:((dip_val:$6;dip_name:'Easy'),(dip_val:$4;dip_name:'Medium'),(dip_val:$2;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
  (mask:$18;name:'Difficulty';number:4;dip:((dip_val:$18;dip_name:'Easy'),(dip_val:$10;dip_name:'Medium'),(dip_val:$8;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),());
  slapshtr_rom:array[0..4] of tipo_roms=(
  (n:'epr-7351.ic7';l:$8000;p:0;crc:$894adb04),(n:'epr-7352.ic5';l:$8000;p:$8000;crc:$61c938b6),
  (n:'epr-7353.ic4';l:$8000;p:$10000;crc:$8ee2951a),(n:'epr-7354.ic3';l:$8000;p:$18000;crc:$41482aa0),
  (n:'epr-7355.ic2';l:$8000;p:$20000;crc:$c67e1aef));
  fantzn2_rom:array[0..4] of tipo_roms=(
  (n:'epr-11416.ic7';l:$8000;p:0;crc:$76db7b7b),(n:'epr-11415.ic5';l:$10000;p:$8000;crc:$57b45681),
  (n:'epr-11413.ic3';l:$10000;p:$18000;crc:$a231dc85),(n:'epr-11414.ic4';l:$10000;p:$28000;crc:$6f7a9f5f),
  (n:'epr-11412.ic2';l:$10000;p:$38000;crc:$b14db5af));
  fantzn2_key:tipo_roms=(n:'317-0057.key';l:$2000;p:0;crc:$ee43d0f0);
  fantzn2_dip_b:array [0..4] of def_dip=(
  (mask:$2;name:'Demo Sounds';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
  (mask:$c;name:'Lives';number:4;dip:((dip_val:$0;dip_name:'2'),(dip_val:$c;dip_name:'3'),(dip_val:$8;dip_name:'4'),(dip_val:$4;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),
  (mask:$30;name:'Timer';number:4;dip:((dip_val:$20;dip_name:'90'),(dip_val:$30;dip_name:'80'),(dip_val:$10;dip_name:'70'),(dip_val:$0;dip_name:'60'),(),(),(),(),(),(),(),(),(),(),(),())),
  (mask:$c0;name:'Difficulty';number:4;dip:((dip_val:$80;dip_name:'Easy'),(dip_val:$c0;dip_name:'Normal'),(dip_val:$40;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),());
  //ATENCION: La posicion de las ROMS esta adrede para desencriptarlas bien
  opaopa_rom:array[0..4] of tipo_roms=(
  (n:'epr-11054.ic7';l:$8000;p:0;crc:$024b1244),(n:'epr-11053.ic5';l:$8000;p:$10000;crc:$6bc41d6e),
  (n:'epr-11052.ic4';l:$8000;p:$18000;crc:$395c1d0a),(n:'epr-11051.ic3';l:$8000;p:$20000;crc:$4ca132a2),
  (n:'epr-11050.ic2';l:$8000;p:$28000;crc:$a165e2ef));
  opaopa_key:tipo_roms=(n:'317-0042.key';l:$2000;p:0;crc:$d6312538);
  opaopa_dip_b:array [0..4] of def_dip=(
  (mask:$2;name:'Demo Sounds';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
  (mask:$c;name:'Lives';number:4;dip:((dip_val:$0;dip_name:'2'),(dip_val:$c;dip_name:'3'),(dip_val:$8;dip_name:'4'),(dip_val:$4;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),
  (mask:$30;name:'Bonus Life';number:4;dip:((dip_val:$20;dip_name:'25K 45K 70K'),(dip_val:$30;dip_name:'40K 60K 90K'),(dip_val:$10;dip_name:'50K 90K'),(dip_val:$0;dip_name:'None'),(),(),(),(),(),(),(),(),(),(),(),())),
  (mask:$c0;name:'Difficulty';number:4;dip:((dip_val:$80;dip_name:'Easy'),(dip_val:$c0;dip_name:'Normal'),(dip_val:$40;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),());
  tetrisse_rom:array[0..2] of tipo_roms=(
  (n:'epr-12213.7';l:$8000;p:0;crc:$ef3c7a38),(n:'epr-12212.5';l:$8000;p:$8000;crc:$28b550bf),
  (n:'epr-12211.4';l:$8000;p:$10000;crc:$5aa114e9));
  tetris_dip_b:array [0..2] of def_dip=(
  (mask:$2;name:'Demo Sounds';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
  (mask:$30;name:'Difficulty';number:4;dip:((dip_val:$20;dip_name:'Easy'),(dip_val:$30;dip_name:'Normal'),(dip_val:$10;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardets'),(),(),(),(),(),(),(),(),(),(),(),())),());
  transfrm_rom:array[0..4] of tipo_roms=(
  (n:'epr-7605.ic7';l:$8000;p:0;crc:$ccf1d123),(n:'epr-7347.ic5';l:$8000;p:$8000;crc:$df0f639f),
  (n:'epr-7348.ic4';l:$8000;p:$10000;crc:$0f38ea96),(n:'epr-7606.ic3';l:$8000;p:$18000;crc:$9d485df6),
  (n:'epr-7350.ic2';l:$8000;p:$20000;crc:$0052165d));
  transfrm_dip_b:array [0..5] of def_dip=(
  (mask:$1;name:'1 Player Only';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$1;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
  (mask:$2;name:'Demo Sounds';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
  (mask:$c;name:'Lives';number:4;dip:((dip_val:$c;dip_name:'3'),(dip_val:$8;dip_name:'4'),(dip_val:$4;dip_name:'5'),(dip_val:$0;dip_name:'Infinite'),(),(),(),(),(),(),(),(),(),(),(),())),
  (mask:$30;name:'Bonus Life';number:4;dip:((dip_val:$20;dip_name:'10K 30K 50K 70K'),(dip_val:$30;dip_name:'20K 60K 100K 140K'),(dip_val:$10;dip_name:'30K 80K 130K 180K'),(dip_val:$0;dip_name:'50K 150K 250K'),(),(),(),(),(),(),(),(),(),(),(),())),
  (mask:$c0;name:'Difficulty';number:4;dip:((dip_val:$40;dip_name:'Easy'),(dip_val:$c0;dip_name:'Normal'),(dip_val:$80;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),());
  ridleofp_rom:array[0..4] of tipo_roms=(
  (n:'epr-10426.bin';l:$8000;p:0;crc:$4404c7e7),(n:'epr-10425.bin';l:$8000;p:$8000;crc:$35964109),
  (n:'epr-10424.bin';l:$8000;p:$10000;crc:$fcda1dfa),(n:'epr-10423.bin';l:$8000;p:$18000;crc:$0b87244f),
  (n:'epr-10422.bin';l:$8000;p:$20000;crc:$14781e56));
  ridleofp_dip_b:array [0..3] of def_dip=(
  (mask:$3;name:'Lives';number:4;dip:((dip_val:$3;dip_name:'3'),(dip_val:$2;dip_name:'4'),(dip_val:$1;dip_name:'5'),(dip_val:$0;dip_name:'100'),(),(),(),(),(),(),(),(),(),(),(),())),
  (mask:$8;name:'Ball Speed';number:2;dip:((dip_val:$8;dip_name:'Easy'),(dip_val:$0;dip_name:'Difficult'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
  (mask:$60;name:'Bonus Life';number:4;dip:((dip_val:$60;dip_name:'50K 100K 200K 1M 2M 10M 20M 50M'),(dip_val:$40;dip_name:'100K 200K 1M 2M 10M 20M 50M'),(dip_val:$20;dip_name:'200K 1M 2M 10M 20M 50M'),(dip_val:$0;dip_name:'None'),(),(),(),(),(),(),(),(),(),(),(),())),());
  //DIP Generales
  systeme_dip_a:array [0..2] of def_dip=(
  (mask:$0f;name:'Coin A';number:$f;dip:((dip_val:$07;dip_name:'4C 1C'),(dip_val:$08;dip_name:'3C 1C'),(dip_val:$09;dip_name:'2C 1C'),(dip_val:$05;dip_name:'2C1C 5C3C 6C4C'),(dip_val:$04;dip_name:'1C2C 4C3C'),(dip_val:$0f;dip_name:'1C 1C'),(dip_val:$03;dip_name:'1C1C 5C6C'),(dip_val:$02;dip_name:'1C1C 4C5C'),(dip_val:$01;dip_name:'1C1C 2C3C'),(dip_val:$06;dip_name:'2C 3C'),(dip_val:$0e;dip_name:'1C 2C'),(dip_val:$0d;dip_name:'1C 3C'),(dip_val:$0c;dip_name:'1C 4C'),(dip_val:$0b;dip_name:'1C 5C'),(dip_val:$0a;dip_name:'1C 6C'),(dip_val:$0;dip_name:'Invalid'))),
  (mask:$f0;name:'Coin B';number:$f;dip:((dip_val:$70;dip_name:'4C 1C'),(dip_val:$88;dip_name:'3C 1C'),(dip_val:$90;dip_name:'2C 1C'),(dip_val:$50;dip_name:'2C1C 5C3C 6C4C'),(dip_val:$40;dip_name:'1C2C 4C3C'),(dip_val:$f0;dip_name:'1C 1C'),(dip_val:$30;dip_name:'1C1C 5C6C'),(dip_val:$20;dip_name:'1C1C 4C5C'),(dip_val:$10;dip_name:'1C1C 2C3C'),(dip_val:$60;dip_name:'2C 3C'),(dip_val:$e0;dip_name:'1C 2C'),(dip_val:$d0;dip_name:'1C 3C'),(dip_val:$c0;dip_name:'1C 4C'),(dip_val:$b0;dip_name:'1C 5C'),(dip_val:$0a;dip_name:'1C 6C'),(dip_val:$0;dip_name:'Invalid'))),());

var
  memoria_rom,memoria_dec:array [0..$f,0..$3fff] of byte;
  rom_dec:array [0..$7fff] of byte;
  port_select,vdp0_bank,vdp1_bank,vram_write,rom_bank:byte;
  vdp_ram:array [0..1,0..$7fff] of byte;
  //ridleofp
  last,diff:array[0..1] of word;

procedure eventos_systeme;
begin
if event.arcade then begin
  //SYS
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);; //HangOn Jr.
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  //P1
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or 8);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  //P2
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or 1);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or 2);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or 4);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or 8);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
end;
end;

procedure systeme_principal;
var
  f:word;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
  for f:=0 to (vdp_0.VIDEO_Y_TOTAL-1) do begin
      eventos_systeme;
      z80_0.run(frame_main);
      frame_main:=frame_main+z80_0.tframes-z80_0.contador;
      vdp_0.refresh(f);
      vdp_1.refresh(f);
  end;
  actualiza_trozo(0,0,284,vdp_0.VIDEO_VISIBLE_Y_TOTAL,1,0,0,284,vdp_0.VIDEO_VISIBLE_Y_TOTAL,3);
  actualiza_trozo(0,0,284,vdp_0.VIDEO_VISIBLE_Y_TOTAL,2,0,0,284,vdp_0.VIDEO_VISIBLE_Y_TOTAL,3);
  actualiza_trozo(0,0,284,vdp_0.VIDEO_VISIBLE_Y_TOTAL,3,0,0,284,vdp_0.VIDEO_VISIBLE_Y_TOTAL,PANT_TEMP);
  video_sync;
end;
end;

function systeme_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff,$c000..$ffff:systeme_getbyte:=memoria[direccion];
  $8000..$bfff:systeme_getbyte:=memoria_rom[rom_bank,direccion and $3fff]; //ROM bank
end;
end;

procedure systeme_putbyte(direccion:word;valor:byte);
begin
case direccion of
  $0..$7fff:; //ROM
  $8000..$bfff:case vram_write of
                  0,4:vdp_ram[1,$4000+(direccion and $3fff)]:=valor;
                  1,3:vdp_ram[0,$4000+(direccion and $3fff)]:=valor;
                  2,6:vdp_ram[1,direccion and $3fff]:=valor;
                  5,7:vdp_ram[0,direccion and $3fff]:=valor;
               end;
  $c000..$ffff:memoria[direccion]:=valor;
end;
end;

function vdp0_read_mem(direccion:word):byte;
begin
  vdp0_read_mem:=vdp_ram[0,(vdp0_bank*$4000)+(direccion and $3fff)]
end;

function vdp1_read_mem(direccion:word):byte;
begin
  vdp1_read_mem:=vdp_ram[1,(vdp1_bank*$4000)+(direccion and $3fff)]
end;

procedure vdp0_write_mem(direccion:word;valor:byte);
begin
  vdp_ram[0,(vdp0_bank*$4000)+(direccion and $3fff)]:=valor;
end;

procedure vdp1_write_mem(direccion:word;valor:byte);
begin
  vdp_ram[1,(vdp1_bank*$4000)+(direccion and $3fff)]:=valor;
end;

function systeme_inbyte(puerto:word):byte;
begin
  case (puerto and $ff) of
    $7e:systeme_inbyte:=vdp_0.linea_back;
    $ba:systeme_inbyte:=vdp_0.vram_r;
    $bb:systeme_inbyte:=vdp_0.register_r;
    $be:systeme_inbyte:=vdp_1.vram_r;
    $bf:systeme_inbyte:=vdp_1.register_r;
    $e0:systeme_inbyte:=marcade.in0;
    $e1:systeme_inbyte:=marcade.in1;
    $e2:systeme_inbyte:=marcade.in2;
    $f2:systeme_inbyte:=marcade.dswa;
    $f3:systeme_inbyte:=marcade.dswb;
    $f8..$fb:systeme_inbyte:=pia8255_0.read(puerto and $3);
  end;
end;

procedure systeme_outbyte(puerto:word;valor:byte);
begin
  case (puerto and $ff) of
    $7b:sn_76496_0.Write(valor);
    $7e,$7f:sn_76496_1.Write(valor);
    $ba:vdp_0.vram_w(valor);
    $bb:vdp_0.register_w(valor);
    $be:vdp_1.vram_w(valor);
    $bf:vdp_1.register_w(valor);
    $f7:begin
          vdp0_bank:=(valor and $80) shr 7;
          vdp1_bank:=(valor and $40) shr 6;
          vram_write:=valor shr 5;
          rom_bank:=valor and $f;
        end;
    $f8..$fb:pia8255_0.write(puerto and $3,valor);
  end;
end;

procedure systeme_interrupt(int:boolean);
begin
  if int then z80_0.change_irq(ASSERT_LINE)
     else z80_0.change_irq(CLEAR_LINE);
end;

procedure systeme_sound_update;
begin
  sn_76496_0.update;
  sn_76496_1.update;
end;

function ppi8255_systeme_rportc:byte;
begin
  ppi8255_systeme_rportc:=0;
end;

//HangOn Jr.
function ppi8255_hangonjr_rporta:byte;
var
  ret:byte;
begin
  ret:=0;
  if port_select=8 then ret:=analog.c[0].x[0]; //in2 move
  if port_select=9 then ret:=analog.c[1].val[0]; //in3 pedal
  ppi8255_hangonjr_rporta:=ret;
end;

procedure ppi8255_hangonjr_wportc(valor:byte);
begin
  port_select:=valor and $f;
end;

//FantZone II
function fantzone2_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff:if z80_0.opcode then fantzone2_getbyte:=rom_dec[direccion]
              else fantzone2_getbyte:=memoria[direccion];
  $8000..$bfff:fantzone2_getbyte:=memoria_rom[rom_bank,direccion and $3fff]; //ROM bank
  $c000..$ffff:fantzone2_getbyte:=memoria[direccion];
end;
end;

//Opa Opa
function opaopa_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff:if z80_0.opcode then opaopa_getbyte:=rom_dec[direccion]
              else opaopa_getbyte:=memoria[direccion];
  $8000..$bfff:if z80_0.opcode then opaopa_getbyte:=memoria_dec[rom_bank,direccion and $3fff]
                  else opaopa_getbyte:=memoria_rom[rom_bank,direccion and $3fff];
  $c000..$ffff:opaopa_getbyte:=memoria[direccion];
end;
end;

//reidleofp
function ridleofp_inbyte(puerto:word):byte;
begin
  case (puerto and $ff) of
    $7e:ridleofp_inbyte:=vdp_0.linea_back;
    $ba:ridleofp_inbyte:=vdp_0.vram_r;
    $bb:ridleofp_inbyte:=vdp_0.register_r;
    $be:ridleofp_inbyte:=vdp_1.vram_r;
    $bf:ridleofp_inbyte:=vdp_1.register_r;
    $e0:ridleofp_inbyte:=marcade.in0;
    $e1:ridleofp_inbyte:=marcade.in1;
    $e2:ridleofp_inbyte:=marcade.in2;
    $f2:ridleofp_inbyte:=marcade.dswa;
    $f3:ridleofp_inbyte:=marcade.dswb;
    $f8:case port_select of
		      1:ridleofp_inbyte:=diff[0] shr 8;
		      2:ridleofp_inbyte:=diff[1] and $ff;
		      3:ridleofp_inbyte:=diff[1] shr 8;
          else ridleofp_inbyte:=diff[0] and $ff;
    end;
    $f9..$fb:ridleofp_inbyte:=pia8255_0.read(puerto and $3);
  end;
end;

procedure ridleofp_outbyte(puerto:word;valor:byte);
var
  curr:word;
begin
  case (puerto and $ff) of
    $7b:sn_76496_0.Write(valor);
    $7e,$7f:sn_76496_1.Write(valor);
    $ba:vdp_0.vram_w(valor);
    $bb:vdp_0.register_w(valor);
    $be:vdp_1.vram_w(valor);
    $bf:vdp_1.register_w(valor);
    $f7:begin
          vdp0_bank:=(valor and $80) shr 7;
          vdp1_bank:=(valor and $40) shr 6;
          vram_write:=valor shr 5;
          rom_bank:=valor and $f;
        end;
    $f8,$f9,$fb:pia8255_0.write(puerto and $3,valor);
    $fa:begin
          port_select:=(valor and $0c) shr 2;
	        if (valor and 1)<>0 then begin
		        curr:=analog.c[0].x[0] or ((marcade.in1 and $10) shl 10);
		        diff[0]:=((curr-last[0]) and $0fff) or (curr and $f000);
		        last[0]:=curr;
	        end;
	        if (valor and 2)<>0 then begin
		        curr:=analog.c[0].x[1] or ((marcade.in2 and $10) shl 10);
		        diff[1]:=((curr-last[1]) and $0fff) or (curr and $f000);
		        last[1]:=curr;
          end;
        end;
  end;
end;

procedure reset_systeme;
begin
 z80_0.reset;
 sn_76496_0.reset;
 sn_76496_1.reset;
 vdp_0.reset;
 vdp_1.reset;
 pia8255_0.reset;
 frame_main:=z80_0.tframes;
 rom_bank:=0;
 vdp0_bank:=0;
 vdp1_bank:=0;
 vram_write:=0;
 port_select:=0;
 diff[0]:=0;
 diff[1]:=0;
 last[0]:=0;
 last[1]:=0;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
end;

function iniciar_systeme:boolean;
var
  mem_temp:array[0..$47fff] of byte;
  mem_temp_dec:array[0..$2ffff] of byte;
  mem_key:array [0..$1fff] of byte;
  f:byte;
begin
llamadas_maquina.bucle_general:=systeme_principal;
llamadas_maquina.reset:=reset_systeme;
llamadas_maquina.fps_max:=59.922738;
iniciar_systeme:=false;
iniciar_audio(false);
if main_vars.tipo_maquina=257 then main_screen.rot90_screen:=true;
screen_init(1,284,243);
screen_init(2,284,243,true);
screen_init(3,284,243);
iniciar_video(284,243);
//Main CPU
z80_0:=cpu_z80.create(10738635 div 2,LINES_NTSC);
z80_0.change_ram_calls(systeme_getbyte,systeme_putbyte);
z80_0.change_io_calls(systeme_inbyte,systeme_outbyte);
z80_0.init_sound(systeme_sound_update);
//VDP
vdp_0:=vdp_chip.create(1,nil,z80_0.numero_cpu,vdp0_read_mem,vdp0_write_mem);
vdp_0.video_ntsc(0);
sn_76496_0:=sn76496_chip.Create(10738635 div 2);
vdp_1:=vdp_chip.create(2,systeme_interrupt,z80_0.numero_cpu,vdp1_read_mem,vdp1_write_mem,true);
vdp_1.video_ntsc(0);
sn_76496_1:=sn76496_chip.Create(10738635 div 2);
pia8255_0:=pia8255_chip.create;
pia8255_0.change_ports(nil,nil,ppi8255_systeme_rportc,nil,nil,nil);
//DIP
marcade.dswa:=$ff;
case main_vars.tipo_maquina of
  251:begin //HangOn Jr.
        pia8255_0.change_ports(ppi8255_hangonjr_rporta,nil,ppi8255_systeme_rportc,nil,nil,ppi8255_hangonjr_wportc);
        if not(roms_load(@mem_temp,hangonjr_rom)) then exit;
        copymemory(@memoria,@mem_temp,$8000);
        for f:=0 to 7 do copymemory(@memoria_rom[f,0],@mem_temp[$8000+(f*$4000)],$4000);
        //Init Analog
        init_analog(z80_0.numero_cpu,z80_0.clock);
        analog_0(100,4,$80,$e0,$20,true,false,true,true);
        analog_1(100,20,$ff,0,true);
        //DIP
        marcade.dswa_val:=@systeme_dip_a;
        marcade.dswb_val:=@hangonjr_dip_b;
        marcade.dswb:=$ff;
      end;
  252:begin //Slap Shooter
        if not(roms_load(@mem_temp,slapshtr_rom)) then exit;
        copymemory(@memoria,@mem_temp,$8000);
        for f:=0 to 7 do copymemory(@memoria_rom[f,0],@mem_temp[$8000+(f*$4000)],$4000);
        //DIP
        marcade.dswa_val:=@systeme_dip_a;
        marcade.dswb:=$ff;
      end;
  253:begin //Fantasy Zone II
        z80_0.change_ram_calls(fantzone2_getbyte,systeme_putbyte);
        if not(roms_load(@mem_temp,fantzn2_rom)) then exit;
        if not(roms_load(@mem_key,fantzn2_key)) then exit;
        copymemory(@memoria,@mem_temp,$8000);
        mc8123_decrypt_rom(@mem_key,@memoria,@rom_dec,$8000);
        for f:=0 to $f do copymemory(@memoria_rom[f,0],@mem_temp[$8000+(f*$4000)],$4000);
        //DIP
        marcade.dswa_val:=@systeme_dip_a;
        marcade.dswb_val:=@fantzn2_dip_b;
        marcade.dswb:=$fd;
      end;
  254:begin //Opa Opa
        z80_0.change_ram_calls(opaopa_getbyte,systeme_putbyte);
        if not(roms_load(@mem_key,opaopa_key)) then exit;
        if not(roms_load(@mem_temp,opaopa_rom)) then exit;
        mc8123_decrypt_rom(@mem_key,@mem_temp,@mem_temp_dec,$30000);
        //Main ROM
        copymemory(@memoria,@mem_temp,$8000);
        copymemory(@rom_dec,@mem_temp_dec,$8000);
        //ROM Banks
        for f:=0 to 7 do copymemory(@memoria_rom[f,0],@mem_temp[$10000+(f*$4000)],$4000);
        for f:=0 to 7 do copymemory(@memoria_dec[f,0],@mem_temp_dec[$10000+(f*$4000)],$4000);
        //DIP
        marcade.dswa_val:=@systeme_dip_a;
        marcade.dswb_val:=@opaopa_dip_b;
        marcade.dswb:=$fd;
      end;
  255:begin //Tetris
        if not(roms_load(@mem_temp,tetrisse_rom)) then exit;
        copymemory(@memoria,@mem_temp,$8000);
        for f:=0 to 3 do copymemory(@memoria_rom[f,0],@mem_temp[$8000+(f*$4000)],$4000);
        //DIP
        marcade.dswa_val:=@systeme_dip_a;
        marcade.dswb_val:=@tetris_dip_b;
        marcade.dswb:=$fd;
      end;
  256:begin //Transformer
        if not(roms_load(@mem_temp,transfrm_rom)) then exit;
        copymemory(@memoria,@mem_temp,$8000);
        for f:=0 to 7 do copymemory(@memoria_rom[f,0],@mem_temp[$8000+(f*$4000)],$4000);
        //DIP
        marcade.dswa_val:=@systeme_dip_a;
        marcade.dswb_val:=@transfrm_dip_b;
        marcade.dswb:=$fc;
      end;
  257:begin //Riddle of Pythagoras
        z80_0.change_io_calls(ridleofp_inbyte,ridleofp_outbyte);
        if not(roms_load(@mem_temp,ridleofp_rom)) then exit;
        copymemory(@memoria,@mem_temp,$8000);
        for f:=0 to 7 do copymemory(@memoria_rom[f,0],@mem_temp[$8000+(f*$4000)],$4000);
        //Init Analog
        init_analog(z80_0.numero_cpu,z80_0.clock);
        analog_0(60,35,$3ff,$fff,0,false,false,true,true);
        //DIP
        marcade.dswa_val:=@systeme_dip_a;
        marcade.dswb_val:=@ridleofp_dip_b;
        marcade.dswb:=$fe;
      end;
end;
//final
iniciar_systeme:=true;
end;

end.
