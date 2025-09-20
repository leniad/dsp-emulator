unit missilecommand_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}m6502,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     sound_engine,pokey;

function iniciar_missilec:boolean;

implementation
const
        missilec_rom:array[0..5] of tipo_roms=(
        (n:'035820-02.h1';l:$800;p:$5000;crc:$7a62ce6a),(n:'035821-02.jk1';l:$800;p:$5800;crc:$df3bd57f),
        (n:'035822-03e.kl1';l:$800;p:$6000;crc:$1a2f599a),(n:'035823-02.ln1';l:$800;p:$6800;crc:$82e552bb),
        (n:'035824-02.np1';l:$800;p:$7000;crc:$606e42e0),(n:'035825-02.r1';l:$800;p:$7800;crc:$f752eaeb));
        missilec_prom:tipo_roms=(n:'035826-01.l6';l:$20;p:0;crc:$86a22140);
        missilec_dip_a:array [0..4] of def_dip=(
        (mask:$3;name:'Coinage';number:4;dip:((dip_val:$0;dip_name:'1C 1C'),(dip_val:$2;dip_name:'Free Play'),(dip_val:$1;dip_name:'2C 1C'),(dip_val:$3;dip_name:'1C 2C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Right Coin';number:4;dip:((dip_val:$0;dip_name:'1'),(dip_val:$4;dip_name:'4'),(dip_val:$8;dip_name:'5'),(dip_val:$c;dip_name:'6'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Center Coin';number:2;dip:((dip_val:$0;dip_name:'1'),(dip_val:$10;dip_name:'2'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$60;name:'Lenguaje';number:4;dip:((dip_val:$0;dip_name:'English'),(dip_val:$20;dip_name:'French'),(dip_val:$40;dip_name:'German'),(dip_val:$60;dip_name:'Spanish'),(),(),(),(),(),(),(),(),(),(),(),())),());
        missilec_dip_b:array [0..5] of def_dip=(
        (mask:$3;name:'Cities';number:4;dip:((dip_val:$2;dip_name:'4'),(dip_val:$1;dip_name:'5'),(dip_val:$3;dip_name:'6'),(dip_val:$0;dip_name:'7'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Bonus Credit for 4 Coins';number:2;dip:((dip_val:$4;dip_name:'No'),(dip_val:$0;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Trackball Size';number:2;dip:((dip_val:$0;dip_name:'Mini'),(dip_val:$8;dip_name:'Large'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$70;name:'Bonus City';number:8;dip:((dip_val:$10;dip_name:'8000'),(dip_val:$70;dip_name:'10000'),(dip_val:$60;dip_name:'12000'),(dip_val:$50;dip_name:'14000'),(dip_val:$40;dip_name:'15000'),(dip_val:$30;dip_name:'18000'),(dip_val:$20;dip_name:'20000'),(dip_val:$0;dip_name:'None'),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$80;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        suprmatk_rom:array[0..7] of tipo_roms=(
        (n:'035820-02.c1';l:$800;p:$5000;crc:$7a62ce6a),(n:'035821-02.b1';l:$800;p:$5800;crc:$df3bd57f),
        (n:'035822-02.a1';l:$800;p:$6000;crc:$a1cd384a),(n:'035823-02.a5';l:$800;p:$6800;crc:$82e552bb),
        (n:'035824-02.b5';l:$800;p:$7000;crc:$606e42e0),(n:'035825-02.c5';l:$800;p:$7800;crc:$f752eaeb),
        (n:'e0.d5';l:$800;p:$8000;crc:$d0b20179),(n:'e1.e5';l:$800;p:$8800;crc:$c6c818a3));
        suprmatk_dip_a:array [0..4] of def_dip=(
        (mask:$3;name:'Coinage';number:4;dip:((dip_val:$0;dip_name:'1C 1C'),(dip_val:$2;dip_name:'Free Play'),(dip_val:$1;dip_name:'2C 1C'),(dip_val:$3;dip_name:'1C 2C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Right Coin';number:4;dip:((dip_val:$0;dip_name:'1'),(dip_val:$4;dip_name:'4'),(dip_val:$8;dip_name:'5'),(dip_val:$c;dip_name:'6'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Center Coin';number:2;dip:((dip_val:$0;dip_name:'1'),(dip_val:$10;dip_name:'2'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Game';number:4;dip:((dip_val:$0;dip_name:'Missile Command'),(dip_val:$40;dip_name:'Easy Super Missile Attack'),(dip_val:$80;dip_name:'Reg. Super Missile Attack'),(dip_val:$c0;dip_name:'Hard Super Missile Attack'),(),(),(),(),(),(),(),(),(),(),(),())),());

var
  videoram:array[0..$ffff] of byte;
  writeprom:array[0..$1f] of byte;
  madsel_lastcycles:byte;
  irq_state,control:boolean;

function get_bit3_addr(direccion:word):word;
begin
	{ the 3rd bit of video RAM is scattered about various areas
	    we take a 16-bit pixel address here and convert it into
	    a video RAM address based on logic in the schematics }
	get_bit3_addr:=((direccion and $0800) shr 1) or ((not(direccion) and $0800) shr 2) or
			           ((direccion and $07f8) shr 2) or ((direccion and $1000) shr 12);
end;

procedure update_video_missilec;
var
  x,y,pix:byte;
  src,effy:word;
  src3:integer;
  ptemp:pword;
begin
for y:=0 to 230 do begin
    effy:=y+25;
		src:=effy*64;
    ptemp:=punbuf;
		// compute the base of the 3rd pixel row
		if (effy>=224) then src3:=get_bit3_addr(effy shl 8)
      else src3:=-1;
		// loop over X
		for x:=0 to 255 do begin
			pix:=videoram[src+(x div 4)] shr (x and 3);
			pix:=((pix shr 2) and 4) or ((pix shl 1) and 2);
			// if we're in the lower region, get the 3rd bit
			if (src3<>-1) then pix:=pix or ((videoram[src3+((x div 8)*2)] shr (x and 7)) and 1);
      ptemp^:=paleta[pix];
      inc(ptemp);
		end;
    putpixel(0,y,256,punbuf,1);
end;
actualiza_trozo(0,0,256,231,1,0,0,256,231,PANT_TEMP);
end;

procedure eventos_missilec;
begin
if event.arcade then begin
  //in0
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  //in1
  if arcade_input.but2[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
end;
end;

procedure principal_missilec;
var
  frame:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame:=m6502_0.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to 255 do begin
    m6502_0.run(frame);
    frame:=frame+m6502_0.tframes-m6502_0.contador;
    case f of
      0:begin
          marcade.in1:=marcade.in1 or $80;
          m6502_0.change_irq(ASSERT_LINE);
          irq_state:=true;
        end;
      24:marcade.in1:=marcade.in1 and $7f;
      32,96,160,224:begin
          m6502_0.change_irq(CLEAR_LINE);
          irq_state:=false;
         end;
      64,128,192:begin
          m6502_0.change_irq(ASSERT_LINE);
          irq_state:=true;
         end;
      225..255:frame:=frame-(m6502_0.tframes/2);
    end;
 end;
 update_video_missilec;
 eventos_missilec;
 video_sync;
end;
end;

function get_madsel:boolean;
var
  madsel:boolean;
begin
	{ the MADSEL signal disables standard address decoding and routes
	    writes to video RAM; it goes high 5 cycles after an opcode
	    fetch where the low 5 bits are 0x01 and the IRQ signal is clear.}
	madsel:=false;
	if (madsel_lastcycles<>0) then begin
		madsel:=(madsel_lastcycles=5);
		// reset the count until next time
		if madsel then madsel_lastcycles:=0;
	end;
	get_madsel:=madsel;
end;

function getbyte_missilec(direccion:word):byte;
var
  vramaddr:word;
	vramdata,vrammask,res:byte;
begin
if madsel_lastcycles<>0 then madsel_lastcycles:=madsel_lastcycles+1;
res:=$ff;
if not(get_madsel) then begin
  direccion:=direccion and $7fff;
  case direccion of
    0..$3fff:res:=videoram[direccion];
    $4000..$47ff:res:=pokey_0.read(direccion and $f);
    $4800..$48ff:if not(control) then res:=marcade.in0
                    else res:=((analog.c[0].y[0] and $f) shl 4) or (analog.c[0].x[0] and $f);
    $4900..$49ff:res:=marcade.in1;
    $4a00..$4aff:res:=marcade.dswa;
    $5000..$7fff:res:=memoria[direccion];
  end;
  //Si no tiene pendiente una irq, y el opcode termina en $1f=1, tengo que contar 5 accesos y el
  // ultimo (normalmente un write) activa el direccionamiento especial
  if (not(irq_state) and ((res and $1f)=$01) and m6502_0.opcode) then madsel_lastcycles:=1;
end else begin
  // basic 2 bit VRAM reads go to addr >> 2
	// data goes to bits 6 and 7
	// this should only be called if MADSEL == 1
	vramaddr:=direccion shr 2;
	vrammask:=$11 shl (direccion and 3);
	vramdata:=videoram[vramaddr] and vrammask;
	if ((vramdata and $f0)=0) then res:=res and not($80);
	if ((vramdata and $0f)=0) then res:=res and not($40);
	// 3-bit VRAM reads use an extra clock to read the 3rd bit elsewhere
	// on the schematics, this is the MUSHROOM == 1 case
	if ((direccion and $e000)=$e000) then begin
		vramaddr:=get_bit3_addr(direccion);
		vrammask:=1 shl (direccion and 7);
		vramdata:=videoram[vramaddr] and vrammask;
		if (vramdata=0) then res:=res and not($20);
		// account for the extra clock cycle
    m6502_0.contador:=m6502_0.contador+1;
	end;
end;
getbyte_missilec:=res;
end;

procedure putbyte_missilec(direccion:word;valor:byte);
const
	data_lookup:array[0..3] of byte=($00,$0f,$f0,$ff);
var
  color:tcolor;
	vramaddr:word;
	vramdata,vrammask:byte;
begin
if madsel_lastcycles<>0 then madsel_lastcycles:=madsel_lastcycles+1;
if not(get_madsel) then begin
  direccion:=direccion and $7fff;
  case direccion of
    0..$3fff:videoram[direccion]:=valor;
    $4000..$47ff:pokey_0.write(direccion and $f,valor);
    $4800..$48ff:control:=(valor and 1)<>0;
    $4b00..$4bff:begin
                      valor:=not(valor);
                      color.r:=pal1bit(valor shr 3);
                      color.g:=pal1bit(valor shr 2);
                      color.b:=pal1bit(valor shr 1);
                      set_pal_color(color,direccion and $7);
                 end;
    $4c00..$4cff:; //WD
    $4d00..$4dff:if irq_state then begin
                    m6502_0.change_irq(CLEAR_LINE);
			              irq_state:=false;
                 end;
    $5000..$7fff:;
  end;
end else begin
  // basic 2 bit VRAM writes go to addr >> 2
	// data comes from bits 6 and 7
	// this should only be called if MADSEL == 1
	vramaddr:=direccion shr 2;
	vramdata:=data_lookup[valor shr 6];
	vrammask:=writeprom[(direccion and 7) or $10];
	videoram[vramaddr]:=(videoram[vramaddr] and vrammask) or (vramdata and not(vrammask));
	// 3-bit VRAM writes use an extra clock to write the 3rd bit elsewhere
	// on the schematics, this is the MUSHROOM == 1 case
	if ((direccion and $e000)=$e000) then begin
		vramaddr:=get_bit3_addr(direccion);
		vramdata:=-((valor shr 5) and 1);
		vrammask:=writeprom[(direccion and 7) or $18];
		videoram[vramaddr]:=(videoram[vramaddr] and vrammask) or (vramdata and not(vrammask));
		// account for the extra clock cycle
    m6502_0.contador:=m6502_0.contador+1;
	end;
end;
end;

procedure missilec_sound;
begin
  pokey_0.update;
end;

function missilec_pot_r(pot:byte):byte;
begin
  missilec_pot_r:=marcade.dswb;
end;

//Main
procedure reset_missilec;
begin
m6502_0.reset;
pokey_0.reset;
marcade.in0:=$ff;
marcade.in1:=$67;
madsel_lastcycles:=0;
irq_state:=false;
control:=false;
end;

function iniciar_missilec:boolean;
const
  suprmatk_table:array[0..63] of word=(
			$7cc0,$5440,$5b00,$5740,$6000,$6540,$7500,$7100,
			$7800,$5580,$5380,$6900,$6e00,$6cc0,$7dc0,$5b80,
			$5000,$7240,$7040,$62c0,$6840,$7ec0,$7d40,$66c0,
			$72c0,$7080,$7d00,$5f00,$55c0,$5a80,$6080,$7140,
			$7000,$6100,$5400,$5bc0,$7e00,$71c0,$6040,$6e40,
			$5800,$7d80,$7a80,$53c0,$6140,$6700,$7280,$7f00,
			$5480,$70c0,$7f80,$5780,$6680,$7200,$7e40,$7ac0,
			$6300,$7180,$7e80,$6280,$7f40,$6740,$74c0,$7fc0);
var
  f:byte;
begin
llamadas_maquina.bucle_general:=principal_missilec;
llamadas_maquina.reset:=reset_missilec;
llamadas_maquina.fps_max:=61.035156;
iniciar_missilec:=false;
iniciar_audio(false);
screen_init(1,256,231,false,true);
iniciar_video(256,231);
//Main CPU
m6502_0:=cpu_m6502.create(1250000,256,TCPU_M6502);
m6502_0.change_ram_calls(getbyte_missilec,putbyte_missilec);
m6502_0.init_sound(missilec_sound);
init_analog(m6502_0.numero_cpu,m6502_0.clock);
analog_0(10,10,$7,$f,0,false,true,false,true);
pokey_0:=pokey_chip.create(1250000);
pokey_0.change_all_pot(missilec_pot_r);
case main_vars.tipo_maquina of
  344:begin //Missile Command
        //cargar roms
        if not(roms_load(@memoria,missilec_rom)) then exit;
        if not(roms_load(@writeprom,missilec_prom)) then exit;
        //dip
        marcade.dswa:=$81;
        marcade.dswa_val:=@missilec_dip_a;
      end;
  345:begin //Super Missile Attack
        //cargar roms
        if not(roms_load(@memoria,suprmatk_rom)) then exit;
        if not(roms_load(@writeprom,missilec_prom)) then exit;
        //Decrypt
        for f:=0 to $3f do copymemory(@memoria[suprmatk_table[f]],@memoria[$8000+f*$40],$40);
        //dip
        marcade.dswa:=$61;
        marcade.dswa_val:=@suprmatk_dip_a;
      end;
end;
marcade.dswb:=$73;
marcade.dswb_val:=@missilec_dip_b;
//final
reset_missilec;
iniciar_missilec:=true;
end;

end.
