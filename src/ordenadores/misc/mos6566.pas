unit mos6566;

//{$DEFINE CIA_OLD}

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}dialogs,sysutils,pal_engine,cpu_misc,
      main_engine,gfx_engine;

type
  mos6566_chip=class
      constructor create(clock:dword);
      destructor free;
    public
      linea:word;
      vbase:byte;
      procedure reset;
      function update(linea_:word):byte;
      function read(direccion:byte):byte;
      procedure write(direccion,valor:byte);
      procedure change_calls(irq_call:cpu_outport_call);
      procedure ChangedVA(new_va:word);
    private
      clock:dword;
      irq_raster:word;				// Interrupt raster line
      rc:word;						// Row counter
      vc:word;						// Video counter
      vc_base:word;					// Video counter base
      x_scroll:byte;					// X scroll value
      y_scroll:byte;					// Y scroll value
      cia_vabase:word;				// CIA VA14/15 video base
      mx,mc:array[0..7] of word;						// VIC registers
      mx8:byte;
      my:array[0..7] of byte;
      mc_color_lookup:array[0..3] of byte;
      ctrl1, ctrl2:byte;
      lpx, lpy:byte;
      me,mxe,mye,mdp,mmc:byte;
      sprite_on:byte;
      irq_flag, irq_mask:byte;
      clx_spr,clx_bgr:byte;
      ec,mm0,mm1:byte;
      sc:array[0..7] of byte;
      display_idx:byte;					// Index of current display mode
      display_state:boolean;				// true: Display state, false: Idle state
      border_on:boolean;					// Flag: Upper/lower border on
      border_40_col:boolean;				// Flag: 40 column border
      bad_lines_enabled:boolean;		// Flag: Bad Lines enabled for this frame
      lp_triggered:boolean;				// Flag: Lightpen was triggered in this frame
      matrix_base:pbyte;				// Video matrix base
      char_base:pbyte;				// Character generator base
      bitmap_base:pbyte;				// Bitmap base
      mm0_color, mm1_color:byte;		// Indices for MOB multicolors
      spr_color:array[0..7] of byte;				// Indices for MOB colors
      row25:boolean;
      spr_coll_buf:array[0..$17f] of byte;		// Buffer for sprite-sprite collisions and priorities
      fore_mask_buf:array[0..$2f] of byte;	// Foreground mask for sprite-graphics collisions and priorities
      irq_call:cpu_outport_call;
      procedure raster_irq;
      function get_physical(direccion:word):pbyte;
      procedure vblank;
      procedure draw_sprites;
      function update_mc(linea:word):byte;
  end;

const
  c64_paleta:array[0..15] of integer=(
        $000000,$FDFEFC,$BE1A24,$30E6C6,
        $B41AE2,$1FD21E,$211BAE,$DFF60A,
        $B84104,$6A3304,$FE4A57,$424540,
        $70746F,$59FE59,$5F53FE,$A4A7A2);
  FIRST_DISP_LINE=$10; //Linea donde empieza lo visible (incluido borde)
  LAST_DISP_LINE=$11c; //Linea donde termina lo visible (Incluido borde)
  DISPLAY_X=$195; //Pixels de una linea
  FIRST_DMA_LINE=$30;
  LAST_DMA_LINE=$f7;
  COL40_XSTART=$20;  //Pixel donde empieza el borde
  COL40_XSTOP=$160;  //??
  COL38_XSTART=$27;  //Pixel donde empieza el borde si 38 cols
  COL38_XSTOP=$157;
  ExpTable:array[0..255] of word=(
	  $0000, $0003, $000C, $000F, $0030, $0033, $003C, $003F,
	  $00C0, $00C3, $00CC, $00CF, $00F0, $00F3, $00FC, $00FF,
	  $0300, $0303, $030C, $030F, $0330, $0333, $033C, $033F,
	  $03C0, $03C3, $03CC, $03CF, $03F0, $03F3, $03FC, $03FF,
	  $0C00, $0C03, $0C0C, $0C0F, $0C30, $0C33, $0C3C, $0C3F,
	  $0CC0, $0CC3, $0CCC, $0CCF, $0CF0, $0CF3, $0CFC, $0CFF,
	  $0F00, $0F03, $0F0C, $0F0F, $0F30, $0F33, $0F3C, $0F3F,
	  $0FC0, $0FC3, $0FCC, $0FCF, $0FF0, $0FF3, $0FFC, $0FFF,
	  $3000, $3003, $300C, $300F, $3030, $3033, $303C, $303F,
	  $30C0, $30C3, $30CC, $30CF, $30F0, $30F3, $30FC, $30FF,
	  $3300, $3303, $330C, $330F, $3330, $3333, $333C, $333F,
	  $33C0, $33C3, $33CC, $33CF, $33F0, $33F3, $33FC, $33FF,
	  $3C00, $3C03, $3C0C, $3C0F, $3C30, $3C33, $3C3C, $3C3F,
	  $3CC0, $3CC3, $3CCC, $3CCF, $3CF0, $3CF3, $3CFC, $3CFF,
	  $3F00, $3F03, $3F0C, $3F0F, $3F30, $3F33, $3F3C, $3F3F,
	  $3FC0, $3FC3, $3FCC, $3FCF, $3FF0, $3FF3, $3FFC, $3FFF,
	  $C000, $C003, $C00C, $C00F, $C030, $C033, $C03C, $C03F,
	  $C0C0, $C0C3, $C0CC, $C0CF, $C0F0, $C0F3, $C0FC, $C0FF,
	  $C300, $C303, $C30C, $C30F, $C330, $C333, $C33C, $C33F,
	  $C3C0, $C3C3, $C3CC, $C3CF, $C3F0, $C3F3, $C3FC, $C3FF,
	  $CC00, $CC03, $CC0C, $CC0F, $CC30, $CC33, $CC3C, $CC3F,
	  $CCC0, $CCC3, $CCCC, $CCCF, $CCF0, $CCF3, $CCFC, $CCFF,
	  $CF00, $CF03, $CF0C, $CF0F, $CF30, $CF33, $CF3C, $CF3F,
	  $CFC0, $CFC3, $CFCC, $CFCF, $CFF0, $CFF3, $CFFC, $CFFF,
  	$F000, $F003, $F00C, $F00F, $F030, $F033, $F03C, $F03F,
  	$F0C0, $F0C3, $F0CC, $F0CF, $F0F0, $F0F3, $F0FC, $F0FF,
  	$F300, $F303, $F30C, $F30F, $F330, $F333, $F33C, $F33F,
  	$F3C0, $F3C3, $F3CC, $F3CF, $F3F0, $F3F3, $F3FC, $F3FF,
  	$FC00, $FC03, $FC0C, $FC0F, $FC30, $FC33, $FC3C, $FC3F,
  	$FCC0, $FCC3, $FCCC, $FCCF, $FCF0, $FCF3, $FCFC, $FCFF,
  	$FF00, $FF03, $FF0C, $FF0F, $FF30, $FF33, $FF3C, $FF3F,
  	$FFC0, $FFC3, $FFCC, $FFCF, $FFF0, $FFF3, $FFFC, $FFFF);
    MultiExpTable:array[0..255] of word=(
  	$0000, $0005, $000A, $000F, $0050, $0055, $005A, $005F,
  	$00A0, $00A5, $00AA, $00AF, $00F0, $00F5, $00FA, $00FF,
  	$0500, $0505, $050A, $050F, $0550, $0555, $055A, $055F,
  	$05A0, $05A5, $05AA, $05AF, $05F0, $05F5, $05FA, $05FF,
  	$0A00, $0A05, $0A0A, $0A0F, $0A50, $0A55, $0A5A, $0A5F,
  	$0AA0, $0AA5, $0AAA, $0AAF, $0AF0, $0AF5, $0AFA, $0AFF,
  	$0F00, $0F05, $0F0A, $0F0F, $0F50, $0F55, $0F5A, $0F5F,
  	$0FA0, $0FA5, $0FAA, $0FAF, $0FF0, $0FF5, $0FFA, $0FFF,
  	$5000, $5005, $500A, $500F, $5050, $5055, $505A, $505F,
  	$50A0, $50A5, $50AA, $50AF, $50F0, $50F5, $50FA, $50FF,
  	$5500, $5505, $550A, $550F, $5550, $5555, $555A, $555F,
  	$55A0, $55A5, $55AA, $55AF, $55F0, $55F5, $55FA, $55FF,
  	$5A00, $5A05, $5A0A, $5A0F, $5A50, $5A55, $5A5A, $5A5F,
  	$5AA0, $5AA5, $5AAA, $5AAF, $5AF0, $5AF5, $5AFA, $5AFF,
  	$5F00, $5F05, $5F0A, $5F0F, $5F50, $5F55, $5F5A, $5F5F,
  	$5FA0, $5FA5, $5FAA, $5FAF, $5FF0, $5FF5, $5FFA, $5FFF,
  	$A000, $A005, $A00A, $A00F, $A050, $A055, $A05A, $A05F,
  	$A0A0, $A0A5, $A0AA, $A0AF, $A0F0, $A0F5, $A0FA, $A0FF,
  	$A500, $A505, $A50A, $A50F, $A550, $A555, $A55A, $A55F,
  	$A5A0, $A5A5, $A5AA, $A5AF, $A5F0, $A5F5, $A5FA, $A5FF,
  	$AA00, $AA05, $AA0A, $AA0F, $AA50, $AA55, $AA5A, $AA5F,
  	$AAA0, $AAA5, $AAAA, $AAAF, $AAF0, $AAF5, $AAFA, $AAFF,
   	$AF00, $AF05, $AF0A, $AF0F, $AF50, $AF55, $AF5A, $AF5F,
  	$AFA0, $AFA5, $AFAA, $AFAF, $AFF0, $AFF5, $AFFA, $AFFF,
  	$F000, $F005, $F00A, $F00F, $F050, $F055, $F05A, $F05F,
  	$F0A0, $F0A5, $F0AA, $F0AF, $F0F0, $F0F5, $F0FA, $F0FF,
  	$F500, $F505, $F50A, $F50F, $F550, $F555, $F55A, $F55F,
  	$F5A0, $F5A5, $F5AA, $F5AF, $F5F0, $F5F5, $F5FA, $F5FF,
  	$FA00, $FA05, $FA0A, $FA0F, $FA50, $FA55, $FA5A, $FA5F,
  	$FAA0, $FAA5, $FAAA, $FAAF, $FAF0, $FAF5, $FAFA, $FAFF,
  	$FF00, $FF05, $FF0A, $FF0F, $FF50, $FF55, $FF5A, $FF5F,
  	$FFA0, $FFA5, $FFAA, $FFAF, $FFF0, $FFF5, $FFFA, $FFFF);

var
  mos6566_0:mos6566_chip;
  matrix_line,color_line:array[0..39] of byte;

implementation
uses commodore64,{$IFNDEF CIA_OLD}mos6526{$ELSE}mos6526_old{$ENDIF};

constructor mos6566_chip.create(clock:dword);
var
  f:byte;
  colores:tpaleta;
begin
  self.clock:=clock;
  for f:=0 to 15 do begin
    colores[f].r:=c64_paleta[f] shr 16;
    colores[f].g:=(c64_paleta[f] shr 8) and $ff;
    colores[f].b:=c64_paleta[f] and $ff;
  end;
  set_pal(colores,16);
  self.reset;
end;

destructor mos6566_chip.free;
begin
end;

procedure mos6566_chip.change_calls(irq_call:cpu_outport_call);
begin
  self.irq_call:=irq_call;
end;

procedure mos6566_chip.reset;
var
  f:byte;
begin
  self.linea:=0;
  self.irq_raster:=0;				// Interrupt raster line
  self.rc:=7;						// Row counter
  self.vc:=0;						// Video counter
  self.vc_base:=0;					// Video counter base
  self.x_scroll:=0;					// X scroll value
  self.y_scroll:=0;					// Y scroll value
  self.cia_vabase:=0;				// CIA VA14/15 video base
  for f:=0 to 7 do begin
      mx[f]:=0;
      my[f]:=0;
      sc[f]:=0;
      spr_color[f]:=0;
      mc[f]:=63;
  end;
  for f:=0 to 3 do self.mc_color_lookup[f]:=0;
  for f:=0 to $2f do fore_mask_buf[f]:=0;
  self.ctrl1:=0;
  self.ctrl2:=0;
  self.lpx:=0;
  self.lpy:=0;
  self.sprite_on:=0;
  self.me:=0;
  self.mxe:=0;
  self.mye:=0;
  self.mdp:=0;
  self.mmc:=0;
  self.vbase:=0;
  self.irq_flag:=0;
  self.irq_mask:=0;
  self.clx_spr:=0;
  self.clx_bgr:=0;
  self.ec:=0;
  self.mm0:=0;
  self.mm1:=0;
  self.display_idx:=0;					// Index of current display mode
  self.display_state:=false;				// true: Display state, false: Idle state
  self.border_on:=false;					// Flag: Upper/lower border on
  self.border_40_col:=false;				// Flag: 40 column border
  self.bad_lines_enabled:=false;		// Flag: Bad Lines enabled for this frame
  self.lp_triggered:=false;
  self.matrix_base:=@memoria[0];				// Video matrix base
  self.char_base:=@memoria[0];				// Character generator base
  self.bitmap_base:=@memoria[0];				// Bitmap base
  self.mm0_color:=0;
  self.mm1_color:=0;		// Indices for MOB multicolors
end;

procedure mos6566_chip.ChangedVA(new_va:word);
begin
	self.cia_vabase:=new_va shl 14;
	self.write($18,self.vbase); // Force update of memory pointers
end;

function mos6566_chip.get_physical(direccion:word):pbyte;
var
  va:word;
  ret:pbyte;
begin
	va:=direccion or self.cia_vabase;
	if (((va and $f000)=$9000) or ((va and $f000)=$1000)) then ret:=@char_rom[va and $fff]
	  else ret:=@memoria[va];
  get_physical:=ret;
end;

function mos6566_chip.read(direccion:byte):byte;
var
  ret:byte;
begin
	case direccion  of
		0,2,4,6,8,$a,$c,$e:ret:=self.mx[direccion shr 1];
    1,3,5,7,9,$b,$d,$f:ret:=self.my[direccion shr 1];
		$10:ret:=self.mx8;	// Sprite X position MSB
		$11:ret:=(self.ctrl1 and $7f) or ((self.linea and $100) shr 1);	// Control register 1
    $12:ret:=self.linea;	// Raster counter
		$13:ret:=self.lpx;	// Light pen X
		$14:ret:=self.lpy;	// Light pen Y
    $15:ret:=self.me;	// Sprite enable
    $16:ret:=self.ctrl2 or $c0;	// Control register 2
    $17:ret:=self.mye;	// Sprite Y expansion
    $18:ret:=self.vbase or $01;	// Memory pointers
    $19:ret:=self.irq_flag or $70;	// IRQ flags
		$1a:ret:=self.irq_mask or $f0;	// IRQ mask
		$1b:ret:=self.mdp;	// Sprite data priority
    $1c:ret:=self.mmc;	// Sprite multicolor
    $1d:ret:=self.mxe;	// Sprite X expansion
    $1e:begin	// Sprite-sprite collision
			    ret:=self.clx_spr;
			    self.clx_spr:=0;	// Read and clear
        end;
    $1f:begin	// Sprite-background collision
			    ret:=self.clx_bgr;
			    self.clx_bgr:=0;	// Read and clear
        end;
		$20:ret:=self.ec or $f0;
		$21:ret:=self.mc_color_lookup[0] or $f0;
		$22:ret:=self.mc_color_lookup[1] or $f0;
		$23:ret:=self.mc_color_lookup[2] or $f0;
		$24:ret:=self.mc_color_lookup[3] or $f0;
		$25:ret:=self.mm0 or $f0;
		$26:ret:=self.mm1 or $f0;
		$27,$28,$29,$2a,$2b,$2c,$2d,$2e:ret:=self.sc[direccion-$27] or $f0;
    else ret:=$ff;
  end;
read:=ret;
end;

procedure mos6566_chip.raster_irq;
begin
self.irq_flag:=self.irq_flag or $01;
if (self.irq_mask and $01)<>0 then begin
  self.irq_flag:=irq_flag or $80;
  self.irq_call(ASSERT_LINE);
end;
end;

procedure mos6566_chip.write(direccion,valor:byte);
var
  j,new_irq_raster:word;
  i:byte;
begin
case direccion of
    0,2,4,6,8,$a,$c,$e:self.mx[direccion shr 1]:=(self.mx[direccion shr 1] and $ff00) or valor;
    1,3,5,7,9,$b,$d,$f:self.my[direccion shr 1]:=valor;
		$10:begin
			    self.mx8:=valor;
          j:=1;
          for i:=0 to 7 do begin
				    if (self.mx8 and j)<>0 then self.mx[i]:=self.mx[i] or $100
				      else self.mx[i]:=self.mx[i] and $ff;
            j:=j shl 1;
          end;
        end;
		$11:begin	// Control register 1
			    self.ctrl1:=valor;
			    self.y_scroll:=valor and 7;
			    new_irq_raster:=(self.irq_raster and $ff) or ((valor and $80) shl 1);
			    if ((self.irq_raster<>new_irq_raster) and (self.linea=new_irq_raster)) then self.raster_irq;
			    self.irq_raster:=new_irq_raster;
          self.row25:=(valor and 8)<>0;
			    self.display_idx:=((self.ctrl1 and $60) or (self.ctrl2 and $10)) shr 4;
        end;
		$12:begin 	// Raster counter
			    new_irq_raster:=(self.irq_raster and $ff00) or valor;
			    if ((self.irq_raster<>new_irq_raster) and (self.linea=new_irq_raster)) then self.raster_irq;
			    self.irq_raster:=new_irq_raster;
        end;
		$15:self.me:=valor;	// Sprite enable
		$16:begin	// Control register 2
			    self.ctrl2:=valor;
			    self.x_scroll:=valor and 7;
			    self.border_40_col:=(valor and 8)<>0;
			    self.display_idx:=((self.ctrl1 and $60) or (self.ctrl2 and $10)) shr 4;
        end;
		$17:self.mye:=valor;	// Sprite Y expansion
		$18:begin	// Memory pointers
			    self.vbase:=valor;
			    self.matrix_base:=self.get_physical((valor and $f0) shl 6);
			    self.char_base:=self.get_physical((valor and $0e) shl 10);
			    self.bitmap_base:=self.get_physical((valor and $08) shl 10);
        end;
		$19:begin // IRQ flags
			    self.irq_flag:=self.irq_flag and (not(valor) and $0f);
          self.irq_call(CLEAR_LINE);
			    if (self.irq_flag and self.irq_mask)<>0 then self.irq_flag:=self.irq_flag or $80; // Set master bit if allowed interrupt still pending
        end;
    $1a:begin	// IRQ mask
			    self.irq_mask:=valor and $0f;
			    if (self.irq_flag and self.irq_mask)<>0 then begin  // Trigger interrupt if pending and now allowed
            self.irq_flag:=self.irq_flag or $80;
            self.irq_call(ASSERT_LINE);
			    end else begin
				    self.irq_flag:=self.irq_flag and $7f;
            self.irq_call(CLEAR_LINE);
          end;
        end;
		$1b:self.mdp:=valor;	// Sprite data priority
		$1c:self.mmc:=valor;	// Sprite multicolor
    $1d:self.mxe:=valor;	// Sprite X expansion
    $20:self.ec:=valor and $f;
		$21:self.mc_color_lookup[0]:=valor and $f;
		$22:self.mc_color_lookup[1]:=valor and $f;
		$23:self.mc_color_lookup[2]:=valor and $f;
		$24:self.mc_color_lookup[3]:=valor and $f;
		$25:begin
          self.mm0:=valor;
          self.mm0_color:=valor and $f;
        end;
		$26:begin
          self.mm1:=valor;
          self.mm1_color:=valor and $f;
        end;
    $27,$28,$29,$2a,$2b,$2c,$2d,$2e:begin
          self.sc[direccion-$27]:=valor;
          self.spr_color[direccion-$27]:=valor and $f;
        end;
end;
end;

procedure mos6566_chip.vblank;
begin
  self.vc_base:=0;
	self.lp_triggered:=false;
  {$IFNDEF CIA_OLD}
  mos6526_0.CountTOD1;
  mos6526_0.CountTOD2;
  {$ELSE}
  mos6526_0.clock_tod;
  mos6526_1.clock_tod;
  {$ENDIF}
end;

procedure mos6566_chip.draw_sprites;
var
  snum,sbit:byte;
  spr_coll,gfx_coll:byte;
  ptemp:pword;
  color,coll_pos:byte;
  ptemp1:pbyte;
  col,f,ptempb:byte;
  plane0_r,plane1_r,plane0_l,plane1_l,sdata,fore_mask,sdata_l,sdata_r,fore_mask_r:dword;
  sshift,spr_mask_pos:byte;
begin
  spr_coll:=0;
  gfx_coll:=0;
  sbit:=1;
  for snum:=0 to 7 do begin
    if (((self.sprite_on and sbit)<>0) and (self.mx[snum]<(DISPLAY_X-32))) then begin
      ptemp:=punbuf;
      inc(ptemp,self.mx[snum]+8);
			coll_pos:=self.mx[snum]+8;
      //Datos
			ptemp1:=self.get_physical(self.matrix_base[$3f8+snum] shl 6 or self.mc[snum]);
			sdata:=(ptemp1^ shl 24);inc(ptemp1);
      sdata:=sdata or (ptemp1^ shl 16);inc(ptemp1);
      sdata:=sdata or (ptemp1^ shl 8);
			color:=spr_color[snum] and $f;  //Color
      //Back foreground
			spr_mask_pos:=coll_pos-self.x_scroll;
      ptempb:=spr_mask_pos div 8;
      sshift:=spr_mask_pos and 7;
			fore_mask:=(self.fore_mask_buf[ptempb] shl 24) or (self.fore_mask_buf[ptempb+1] shl 16)
                  or (self.fore_mask_buf[ptempb+2] shl 8) or (self.fore_mask_buf[ptempb+3] shl sshift)
                  or (self.fore_mask_buf[ptempb+4] shr (8-sshift));
      if (self.mxe and sbit)<>0 then begin //X_expanded
        if (self.mx[snum]>=(DISPLAY_X-56)) then continue;
				fore_mask_r:=(self.fore_mask_buf[ptempb+4] shl 24) or (self.fore_mask_buf[ptempb+5] shl 16)
                     or (self.fore_mask_buf[ptempb+6] shl 8) or (self.fore_mask_buf[ptempb+7] shl sshift)
                     or (self.fore_mask_buf[ptempb+8] shr (8-sshift));
        if (self.mmc and sbit)<>0 then begin	// Multicolor mode
					// Expand sprite data
					sdata_l:=MultiExpTable[(sdata shr 24) and $ff] shl 16 or MultiExpTable[(sdata shr 16) and $ff];
					sdata_r:=0 or MultiExpTable[(sdata shr 8) and $ff] shl 16;
          // Convert sprite chunky pixels to bitplanes
					plane0_l:=(sdata_l and $55555555) or (sdata_l and $55555555) shl 1;
					plane1_l:=(sdata_l and $aaaaaaaa) or (sdata_l and $aaaaaaaa) shr 1;
					plane0_r:=(sdata_r and $55555555) or (sdata_r and $55555555) shl 1;
					plane1_r:=(sdata_r and $aaaaaaaa) or (sdata_r and $aaaaaaaa) shr 1;
          // Collision with graphics?
					if (((fore_mask and (plane0_l or plane1_l))<>0) or ((fore_mask_r and (plane0_r or plane1_r))<>0)) then begin
						gfx_coll:=gfx_coll or sbit;
						if (self.mdp and sbit)<>0	then begin
							plane0_l:=plane0_l and not(fore_mask);	// Mask sprite if in background
							plane1_l:=plane1_l and not(fore_mask);
							plane0_r:=plane0_r and not(fore_mask_r);
							plane1_r:=plane1_r and not(fore_mask_r);
						end;
					end;
          // Paint sprite
					for f:=0 to 31 do begin
						if (plane1_l and $80000000)<>0 then begin
							if (plane0_l and $80000000)<>0 then col:=mm1
							  else col:=color;
						end else begin
							if (plane0_l and $80000000)<>0 then col:=mm0
							  else begin
                  inc(ptemp);
                  plane0_l:=plane0_l shl 1;
                  plane1_l:=plane1_l shl 1;
								  continue;
                end;
						end;
						if self.spr_coll_buf[coll_pos+f]<>0 then spr_coll:=spr_coll or self.spr_coll_buf[coll_pos+f] or sbit
						  else begin
							  ptemp^:=paleta[col];
							  self.spr_coll_buf[coll_pos+f]:=sbit;
						  end;
            inc(ptemp);
            plane0_l:=plane0_l shl 1;
            plane1_l:=plane1_l shl 1;
					end;
          for f:=32 to 47 do begin
						if (plane1_r and $80000000)<>0 then begin
							if (plane0_r and $80000000)<>0 then col:=mm1
							  else col:=color;
						end else begin
							if (plane0_r and $80000000)<>0 then col:=mm0
                else begin
                  inc(ptemp);
                  plane0_r:=plane0_r shl 1;
                  plane1_r:=plane1_r shl 1;
								  continue;
                end;
						end;
            // Collision with sprite?
            if self.spr_coll_buf[coll_pos+f]<>0 then begin
              spr_coll:=spr_coll or self.spr_coll_buf[coll_pos+f] or sbit;
            end else begin		// Draw pixel if no collision
              ptemp^:=paleta[col];
              self.spr_coll_buf[coll_pos+f]:=sbit;
            end;
            inc(ptemp);
            plane0_r:=plane0_r shl 1;
            plane1_r:=plane1_r shl 1;
					end;
        end else begin // Standard mode
          // Expand sprite data
					sdata_l:=(ExpTable[(sdata shr 24) and $ff] shl 16) or ExpTable[(sdata shr 16) and $ff];
					sdata_r:=ExpTable[(sdata shr 8) and $ff] shl 16;
					// Collision with graphics?
					if (((fore_mask and sdata_l)<>0) or ((fore_mask_r and sdata_r)<>0)) then begin
						gfx_coll:=gfx_coll or sbit;
						if (self.mdp and sbit)<>0	then begin
							sdata_l:=sdata_l and not(fore_mask);	// Mask sprite if in background
							sdata_r:=sdata_r and not(fore_mask_r);
						end;
					end;
					// Paint sprite
					for f:=0 to 31 do begin
						if (sdata_l and $80000000)<>0 then begin
              // Collision with sprite?
							if self.spr_coll_buf[coll_pos+f]<>0 then begin
                spr_coll:=spr_coll or self.spr_coll_buf[coll_pos+f] or sbit
              end else begin		// Draw pixel if no collision
                  ptemp^:=paleta[color];
								  self.spr_coll_buf[coll_pos+f]:=sbit;
              end;
            end;
            inc(ptemp);
            sdata_l:=sdata_l shl 1;
          end;
					for f:=32 to 47 do begin
						if (sdata_r and $80000000)<>0 then begin
              // Collision with sprite?
							if self.spr_coll_buf[coll_pos+f]<>0 then begin
                spr_coll:=spr_coll or self.spr_coll_buf[coll_pos+f] or sbit;
							end else begin		// Draw pixel if no collision
								ptemp^:=paleta[color];
								self.spr_coll_buf[coll_pos+f]:=sbit;
							end;
						end;
            inc(ptemp);
            sdata_r:=sdata_r shl 1;
          end;
        end;
      end else begin //No expanded
        if (self.mmc and sbit)<>0 then begin 	// Multicolor mode
					// Convert sprite chunky pixels to bitplanes
          plane0_l:=(sdata and $55555555) or ((sdata and $55555555) shl 1);
          plane1_l:=(sdata and $aaaaaaaa) or ((sdata and $aaaaaaaa) shr 1);
					// Collision with graphics?
					if (fore_mask and (plane0_l or plane1_l))<>0 then begin
						gfx_coll:=gfx_coll or sbit;
						if (self.mdp and sbit)<>0 then begin
							plane0_l:=plane0_l and not(fore_mask);	// Mask sprite if in background
							plane1_l:=plane1_l and not(fore_mask);
						end;
					end;
					// Paint sprite
					for f:=0 to 23 do begin
						if (plane1_l and $80000000)<>0 then begin
							if (plane0_l and $80000000)<>0 then col:=self.mm1
							  else col:=color;
						end else begin
							if (plane0_l and $80000000)<>0 then col:=self.mm0
							  else begin
                  inc(ptemp);
                  plane0_l:=plane0_l shl 1;
                  plane1_l:=plane1_l shl 1;
                  continue;
                end;
						end;
						if self.spr_coll_buf[coll_pos+f]<>0 then spr_coll:=self.spr_coll_buf[coll_pos+f] or sbit
						  else begin
							  ptemp^:=paleta[col];
							  self.spr_coll_buf[coll_pos+f]:=sbit;
						end;
            plane0_l:=plane0_l shl 1;
            plane1_l:=plane1_l shl 1;
            inc(ptemp);
          end;
        end else begin // Standard mode
          // Collision with graphics?
					{if (fore_mask and sdata)<>0 then begin
						gfx_coll:=gfx_coll or sbit;
						if (self.mdp and sbit)<>0 then sdata:=sdata and not(fore_mask);	// Mask sprite if in background
					end;}
					// Paint sprite
					for f:=0 to 23 do begin
						if (sdata and $80000000)<>0 then begin
              // Collision with sprite?
							if (self.spr_coll_buf[coll_pos+f]<>0) then begin
								spr_coll:=spr_coll or self.spr_coll_buf[coll_pos+f] or sbit;
							end else begin  // Draw pixel if no collision
								ptemp^:=paleta[color];
								self.spr_coll_buf[coll_pos+f]:=sbit;
							end;
						end;
            inc(ptemp);
            sdata:=sdata shl 1;
          end;
        end;
      end;
    end;
    // Check sprite-sprite collisions
		if (self.clx_spr<>0) then self.clx_spr:=self.clx_spr or spr_coll
		else begin
			self.clx_spr:=self.clx_spr or spr_coll;
			self.irq_flag:=self.irq_flag or $04;
			if (self.irq_mask and $04)<>0 then begin
				self.irq_flag:=self.irq_flag or $80;
				self.irq_call(ASSERT_LINE);
			end;
		end;
		// Check sprite-background collisions
		if (self.clx_bgr<>0) then self.clx_bgr:=self.clx_bgr or gfx_coll
		else begin
			self.clx_bgr:=self.clx_bgr or gfx_coll;
			self.irq_flag:=self.irq_flag or $02;
			if (self.irq_mask and $02)<>0 then begin
				self.irq_flag:=self.irq_flag or $80;
				self.irq_call(ASSERT_LINE);
			end;
    end;
  sbit:=sbit shl 1;
  end; //del for
end;

function mos6566_chip.update_mc(linea:word):byte;
var
	i,j:byte;
	cycles_used:byte;
	spron,spren,sprye:byte;
begin
  spron:=self.sprite_on;
	spren:=self.me;
	sprye:=self.mye;
  cycles_used:=0;
	// Increment sprite data counters
  j:=1;
	for i:=0 to 7 do begin
		// Sprite enabled?
		if (spren and j)<>0 then
			// Yes, activate if Y position matches raster counter
			if (my[i]=(linea and $ff)) then begin
				self.mc[i]:=0;
				spron:=spron or j;  // No, turn sprite off when data counter exceeds 60 and increment counter
			end else if (self.mc[i]<>63) then begin
				          if (sprye and j)<>0 then begin	// Y expansion
					          if (((self.my[i] xor (linea and $ff)) and 1)=0) then begin
						          self.mc[i]:=self.mc[i]+3;
						          cycles_used:=cycles_used+2;
						          if (self.mc[i]=63) then spron:=spron and not(j);
                    end;
				          end else begin
					          self.mc[i]:=self.mc[i]+3;
					          cycles_used:=cycles_used+2;
					          if (self.mc[i]=63) then spron:=spron and not(j);
				          end;
			         end else if (self.mc[i]<>63) then begin
				                  if (sprye and j)<>0 then begin	// Y expansion
					                  if (((self.my[i] xor (linea and $ff)) and 1)=0) then begin
                              self.mc[i]:=self.mc[i]+3;
						                  cycles_used:=cycles_used+2;
						                  if (self.mc[i]=63) then spron:=spron and not(j);
					                  end;
				                  end else begin
					                  self.mc[i]:=self.mc[i]+3;
					                  cycles_used:=cycles_used+2;
					                  if (self.mc[i]=63) then spron:=spron and not(j);
				                  end;
			                  end;
      j:=j shl 1;
	end;
	self.sprite_on:=spron;
	update_mc:=cycles_used;
end;

function mos6566_chip.update(linea_:word):byte;
var
  ptemp:pword;
  cycles_left:byte;
  is_bad_line:boolean;
  pbyte1,pbyte2,ptemp1,ptemp2:pbyte;
procedure pinta_linea;
var
  f,h,color,color2,bcolor,bcolor2,data:byte;
  lookup:array[0..3] of byte;
begin
  ptemp:=punbuf;
  inc(ptemp,32);
  if self.display_state then begin
    fillword(ptemp,self.x_scroll,paleta[self.mc_color_lookup[0]]);
    case self.display_idx of
      0:for f:=0 to 39 do begin  //Texto normal
          color:=color_line[f] and $f;
          ptemp1:=char_base;
          inc(ptemp1,(matrix_line[f] shl 3)+self.rc);
          data:=ptemp1^;
          fore_mask_buf[f+4]:=data;
          for h:=0 to 7 do begin
            if (data and $80)=0 then ptemp^:=paleta[self.mc_color_lookup[0]]
              else ptemp^:=paleta[color];
            data:=data shl 1;
            inc(ptemp);
          end;
        end;
      1:for f:=0 to 39 do begin
          ptemp1:=char_base;
          inc(ptemp1,rc);
          inc(ptemp1,(matrix_line[f] shl 3));
          data:=ptemp1^;
          if (color_line[f] and 8)<>0 then begin
            self.mc_color_lookup[3]:=color_line[f] and 7;
            fore_mask_buf[f+4]:=(data and $aa) or (data and $aa) shr 1;
            color:=self.mc_color_lookup[(data shr 6) and 3];
            ptemp^:=paleta[color];inc(ptemp);
            ptemp^:=paleta[color];inc(ptemp);
            color:=self.mc_color_lookup[(data shr 4) and 3];
            ptemp^:=paleta[color];inc(ptemp);
            ptemp^:=paleta[color];inc(ptemp);
            color:=self.mc_color_lookup[(data shr 2) and 3];
            ptemp^:=paleta[color];inc(ptemp);
            ptemp^:=paleta[color];inc(ptemp);
            color:=self.mc_color_lookup[(data shr 0) and 3];
            ptemp^:=paleta[color];inc(ptemp);
            ptemp^:=paleta[color];inc(ptemp);
          end else begin // Standard mode in multicolor mode
            color:=color_line[f] and $f;
            fore_mask_buf[f+4]:=data;
            for h:=0 to 7 do begin
              if (data and $80)=0 then begin
                ptemp^:=paleta[self.mc_color_lookup[0]];
                inc(ptemp);
              end else begin
                ptemp^:=paleta[color];
                inc(ptemp);
              end;
              data:=data shl 1;
            end;
          end;
        end;
      2:begin //standar gfx
          ptemp1:=bitmap_base;
          inc(ptemp1,(vc shl 3)+rc);
          for f:=0 to 39 do begin
            data:=ptemp1^;
            inc(ptemp1,8);
            fore_mask_buf[f+4]:=data;
            color:=matrix_line[f] shr 4;
            bcolor:=matrix_line[f] and $f;
            for h:=0 to 7 do begin
              if (data and $80)=0 then ptemp^:=paleta[bcolor]
                else ptemp^:=paleta[color];
              data:=data shl 1;
              inc(ptemp);
            end;
          end;
        end;
      3:begin //160x200 multi color
          lookup[0]:=self.mc_color_lookup[0];
          ptemp1:=bitmap_base;
          inc(ptemp1,(vc shl 3)+rc);
          for f:=0 to 39 do begin
            lookup[1]:=matrix_line[f] shr 4;
            lookup[2]:=matrix_line[f] and $f;
            lookup[3]:=color_line[f] and $f;
            data:=ptemp1^;
            inc(ptemp1,8);
            fore_mask_buf[f+4]:=(data and $aa) or (data and $aa) shr 1;
            color:=lookup[(data shr 6) and 3];
            ptemp^:=paleta[color];inc(ptemp);
            ptemp^:=paleta[color];inc(ptemp);
            color:=lookup[(data shr 4) and 3];
            ptemp^:=paleta[color];inc(ptemp);
            ptemp^:=paleta[color];inc(ptemp);
            color:=lookup[(data shr 2) and 3];
            ptemp^:=paleta[color];inc(ptemp);
            ptemp^:=paleta[color];inc(ptemp);
            color:=lookup[(data shr 0) and 3];
            ptemp^:=paleta[color];inc(ptemp);
            ptemp^:=paleta[color];inc(ptemp);
          end;
        end;
      4:for f:=0 to 39 do begin
          data:=matrix_line[f];
          fore_mask_buf[f+4]:=data;
          color:=color_line[f];
          bcolor:=self.mc_color_lookup[(data shr 6) and 3];
          ptemp1:=char_base;
          inc(ptemp1,rc);
          inc(ptemp1,(data and $3f) shl 3);
          data:=ptemp1^;
          for h:=0 to 7 do begin
            if (data and $80)=0 then ptemp^:=paleta[bcolor]
              else ptemp^:=paleta[color];
            data:=data shl 1;
            inc(ptemp);
          end;
        end;
      5,6,7:fillword(ptemp,320,paleta[0]); //Invalid!
    end;
    self.vc:=self.vc+40;
  end else begin
    case self.display_idx of
      0,1,4:begin
              if (ctrl1 and $40)<>0 then ptemp1:=get_physical($39ff)
                else ptemp1:=get_physical($3fff);
              data:=ptemp1^;
              for f:=0 to 39 do begin
                fore_mask_buf[f+4]:=data;
                for h:=0 to 7 do begin
                  if (data and $80)=0 then ptemp^:=paleta[self.mc_color_lookup[0]]
                    else ptemp^:=paleta[0];
                  data:=data shl 1;
                  inc(ptemp);
                end;
              end;
            end;
      3:begin
              ptemp1:=get_physical($3fff);
              data:=ptemp1^;
              lookup[0]:=self.mc_color_lookup[0];
              lookup[1]:=0;
              lookup[2]:=0;
              lookup[3]:=0;
              color:=lookup[(data shr 6) and 3];
              color2:=lookup[(data shr 4) and 3];
              bcolor:=lookup[(data shr 2) and 3];
              bcolor2:=lookup[(data shr 0) and 3];
              for f:=0 to 39 do begin
                ptemp^:=paleta[color];inc(ptemp);
                ptemp^:=paleta[color];inc(ptemp);
                ptemp^:=paleta[color2];inc(ptemp);
                ptemp^:=paleta[color2];inc(ptemp);
                ptemp^:=paleta[bcolor];inc(ptemp);
                ptemp^:=paleta[bcolor];inc(ptemp);
                ptemp^:=paleta[bcolor2];inc(ptemp);
                ptemp^:=paleta[bcolor2];inc(ptemp);
                fore_mask_buf[f+4]:=data;
              end;
        end;
      2,5,6,7:fillword(ptemp,320,paleta[0]); //Invalid!
    end;
  end;
  //Draw sprites
  //fillword(punbuf,384,0);
  if (self.sprite_on<>0) then begin
    fillchar(self.spr_coll_buf,$180,0);
    self.draw_sprites;
  end;
  //Bordes izq y der
  ptemp:=punbuf;
  if border_40_col then begin
    fillword(ptemp,32,paleta[self.ec]);
    inc(ptemp,352);
    fillword(ptemp,32,paleta[self.ec]);
  end else begin
    fillword(ptemp,32,paleta[self.ec]);
    inc(ptemp,336);
    fillword(ptemp,32+16,paleta[self.ec]);
  end;
end;
begin
  self.linea:=linea_;
  // Trigger raster IRQ if IRQ line reached
	if (linea_=self.irq_raster) then self.raster_irq;
	// Vblank?
  case linea_ of
    0..15,301..311:begin //estoy en Vblank
      update:=63;
      exit;
    end;
    300:begin //empiezo vblank
         self.vblank;
         update:=63;
		     exit;
        end;
  end;
  cycles_left:=63;	// Cycles left for CPU
	is_bad_line:=false;
	// In line $30, the DEN bit controls if Bad Lines can occur
	if (linea_=$30) then self.bad_lines_enabled:=(self.ctrl1 and $10)<>0;
  // Estoy dentro de lo visible? Si no, estoy en vblank
	if ((linea_>=FIRST_DISP_LINE) and (linea_<=LAST_DISP_LINE)) then begin
      // Set video counter
  		self.vc:=self.vc_base;
	  	// Bad Line condition? Si es asi, cojo los datos para las siguientes 8 lineas!!
		  if ((linea_>=FIRST_DMA_LINE) and (linea_<=LAST_DMA_LINE) and (((linea_ and 7)=self.y_scroll)) and bad_lines_enabled) then begin
			    // Turn on display
			    self.display_state:=true;
          is_bad_line:=true;
			    cycles_left:=23;
			    self.rc:=0;
          // Cojo 40 bytes de los datos para pintar la pantalla
			    pbyte1:=@matrix_line[0];
			    pbyte2:=@color_line[0];
			    ptemp1:=matrix_base;
          inc(ptemp1,self.vc);
			    ptemp2:=@color_ram[0];
          inc(ptemp2,self.vc);
          copymemory(pbyte1,ptemp1,40);
          copymemory(pbyte2,ptemp2,40);
      end;
      ptemp:=punbuf;
      case linea_ of
        16..50,251..299:fillword(ptemp,384,paleta[self.ec]); //borde
        51..54,247..250:if self.row25 then pinta_linea
                else fillword(ptemp,384,paleta[self.ec]); //borde
        55..246:pinta_linea;
      end;
      // Increment row counter, go to idle state on overflow
		  if (self.rc=7) then begin
			    self.display_state:=false;
			    self.vc_base:=self.vc;
      end else self.rc:=self.rc+1;
		  if ((linea_>=FIRST_DMA_LINE-1) and (linea_<=LAST_DMA_LINE-1) and ((((linea_+1) and 7)=self.y_scroll)) and self.bad_lines_enabled) then
			    self.rc:=0;
  end;
  if (self.me or self.sprite_on)<>0 then cycles_left:=cycles_left-self.update_mc(linea_);
  update:=cycles_left;
end;

end.
