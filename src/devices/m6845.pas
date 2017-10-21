unit m6845;

interface

const
  CRTC_VS_FLAG=$001;	  // Vsync active
  CRTC_HS_FLAG=$002;	  // Hsync active
  CRTC_HDISP_FLAG=$004;	// Horizontal Display Timing
  CRTC_VDISP_FLAG=$008;	// Vertical Display Timing
  CRTC_HTOT_FLAG=$010;	// HTot reached
  CRTC_VTOT_FLAG=$020;	// VTot reached
  CRTC_MR_FLAG=$040;	  // Max Raster reached
  CRTC_VADJ_FLAG=$080;
  CRTC_R8DT_FLAG=$100;
  CRTC_VSCNT_FLAG=$200;
  CRTC_HSCNT_FLAG=$400;
  CRTC_VSALLOWED_FLAG=$800;
  CRTC_VADJWANTED_FLAG=$01000;
  CRTC_INTERLACE_ACTIVE=$02000;
  CRTC_CURSOR_LINE_ACTIVE=$04000;
  CRTC_CURSOR_ACTIVE=$08000;
  HD6845S_WriteMaskTable:array[0..31] of byte=(
	$0ff,	$0ff,	$0ff,	$0ff,	$07f,	$01f,	$07f,	$07f,	$0f3,	$01f,	$07f,	$01f,	$03f,	$0ff,	$03f,	$0ff,
	$0ff,	$0ff,	$0ff,	$0ff,	$0ff,	$0ff,	$0ff,	$0ff,	$0ff,	$0ff,	$0ff,	$0ff,	$0ff,$0ff,	$0ff,	$0ff);
  HD6845S_ReadMaskTable:array[0..31] of byte=(
	$000,  // Horizontal Total
	$000,  // Horizontal Displayed
	$000,  // Horizontal Sync Position
	$000,  // Sync Widths
	$000,  // Vertical Total
	$000,  // Vertical Adjust
	$000,  // Vertical Displayed
	$000,  // Vertical Sync Position
	$000,  // Interlace and Skew
	$000,  // Maximum Raster Address
	$000,  // Cursor Start
	$000,  // Cursor End
	$0ff,  // Screen Addr (H)
	$0ff,  // Screen Addr (L)
	$0ff,  // Cursor (H)
	$0ff,  // Cursor (L)

	$0ff,  // Light Pen (H)
	$0ff,  // Light Pen (L)
	$000,	$000,	$000,	$000,	$000,	$000,	$000,	$000,	$000,	$000,	$000,	$000,	$000,	$000);


type
  tcrt_internal_state=record
	  CRTC_Flags:word;
	  CRTC_HalfHtotFlags:word;
	  CRTC_FlagsAtLastHsync:word;
	  CRTC_FlagsAtLastHtot:word;
	  // horizontal count */
    HCount:byte;
	  // start and end of line in char positions */
	  HStart, HEnd:byte;
	  // Horizontal sync width */
	  HorizontalSyncWidth:byte;
	  // horizontal sync width counter */
	  HorizontalSyncCount:byte;

	  // raster counter (RA) */
	  RasterCounter:byte;
	  // line counter */
	  LineCounter:byte;
	  // Vertical sync width */
	  VerticalSyncWidth:byte;
	  VerticalSyncWidthCount:byte;
	  // vertical sync width counter */
	  VerticalSyncCount:byte;

	  // INTERLACE STUFF */
	  // interlace and video mode number 0,1,2,3 */
	  //unsigned char InterlaceAndVideoMode;
	  // frame - odd or even - used in interlace */
	  Frame:byte;
	  // Vert Adjust Counter */
	  VertAdjustCount:byte;
	  // delay for start and end of line defined by reg 8
	  HDelayReg8:byte;

	  // type index of CRTC */
	  CRTC_Type:byte;
	  // index of current register selected */
	  CRTC_Reg:byte;

	  // MA (memory address base) */
	  MA:integer;	// current value */
	  // MA of current line we are rendering (character line) */
	  MAStore:integer;		// this is the reload value */

	  CursorBlinkCount:integer; // current flash count */
	  CursorBlinkOutput:integer; // current output from flash */
	  CursorActiveLine:integer; // cursor is active on this line */
	  CursorOutput:integer; // final output */

	  CursorMA:integer;
	  // line function */
	  LinesAfterFrameStart:integer;
	  CharsAfterHsyncStart:integer;
	  LinesAfterVsyncStart:integer;
  end;

var
  CRTC_InternalState:tcrt_internal_state;
  CRTCRegisters,CRTCRegistersBackup:array[0..31] of byte;

implementation

procedure CRTC_SetVsyncOutput(state:boolean);
begin
//LLamada a VSYNC!!!!!!!!!!!
end;

procedure CRTC_SetHsyncOutput(state:boolean);
begin
//LLamada a HSYNC!!!!!!!!
end;

procedure CRTC_ClearFlag(x:word);
begin
	CRTC_InternalState.CRTC_Flags:=CRTC_InternalState.CRTC_Flags and not(x);
end;

procedure CRTC_SetFlag(x:word);
begin
	CRTC_InternalState.CRTC_Flags:=CRTC_InternalState.CRTC_Flags or x;
end;

function CRTC0_ReadData:byte;
var
  CRTC_RegIndex:byte;
begin
	CRTC_RegIndex:=CRTC_InternalState.CRTC_Reg and $01f;
	// unreadable registers return 0 */
	CRTC0_ReadData:=CRTCRegisters[CRTC_RegIndex] and HD6845S_ReadMaskTable[CRTC_RegIndex];
end;


function CRTC0_GetVerticalSyncWidth:integer;
var
  VerticalSyncWidth:integer;
begin
	// confirmed: a programmed vsync width of 0, results in an actual width of 16
	// 16 can happen when counter overflows
	VerticalSyncWidth:=(CRTCRegisters[3] shr 4) and $0f;
	if (VerticalSyncWidth=0) then VerticalSyncWidth:=16;
	CRTC0_GetVerticalSyncWidth:=VerticalSyncWidth;
end;

procedure CRTC_InitVsync;
begin
	CRTC_InternalState.LinesAfterVsyncStart:=0;
	if (CRTC_InternalState.CRTC_Flags and CRTC_VSCNT_FLAG)=0 then begin

		CRTC_InternalState.VerticalSyncCount:=0;
    CRTC_InternalState.VerticalSyncWidth:=CRTC0_GetVerticalSyncWidth;
		CRTC_SetFlag(CRTC_VSCNT_FLAG);
		CRTC_SetVsyncOutput(TRUE);

	end;
end;

procedure	CRTC_DoDispEnable;
begin
  // disp enable is based on the output of HDISP, VDISP and R8 delay */
  // confirmed for type 3 */
  if ((CRTC_InternalState.CRTC_Flags and (CRTC_HDISP_FLAG or CRTC_VDISP_FLAG or CRTC_R8DT_FLAG))=(CRTC_HDISP_FLAG or CRTC_VDISP_FLAG)) then
    //CRTC_SetDispEnable(TRUE)
  else
    //CRTC_SetDispEnable(FALSE);
end;

procedure CRTC0_RefreshHStartAndHEnd;
begin
	// if Reg 8 is used, start and end positions are delayed by amount
	//programmed. HStart can also be additionally delayed by ASIC.

	// set start and end positions of lines */
	CRTC_InternalState.HEnd:=CRTCRegisters[1]+CRTC_InternalState.HDelayReg8;
	CRTC_InternalState.HStart:=CRTC_InternalState.HDelayReg8;

	// set HStart and HEnd to same, because Reg1 is set to 0 */
	if (CRTCRegisters[1]=0) then begin
    CRTC_InternalState.HStart:=0;
    CRTC_InternalState.HEnd:=0;
  end;

	// update rendering function */
	CRTC_DoDispEnable;
end;

procedure CRTC0_DoReg1;
begin
	CRTC0_RefreshHStartAndHEnd();
end;

procedure CRTC0_DoReg8;
var
  Delay:byte;
begin
	// on type 3 changing r8 rapidly shows nothing */

	// number of characters delay */
	Delay:=(CRTCRegisters[8] shr 4) and $03;
	CRTC_ClearFlag(CRTC_R8DT_FLAG);

	if (Delay=3) then begin
		// Disable display of graphics */
		CRTC_SetFlag(CRTC_R8DT_FLAG);
		Delay:=0;
	end;
	CRTC_InternalState.HDelayReg8:=delay;
	CRTC0_RefreshHStartAndHEnd;
end;

procedure CRTC0_UpdateState(RegIndex:byte);
begin
	// re-programming vsync position doesn't cut vsync */
	// re-programming length doesn't seem to cut vsync */
	case RegIndex of
  // octoplex title wants this
	4:begin
		  if (CRTC_InternalState.CRTC_Flags and CRTC_MR_FLAG)<>0 then begin
			  if (CRTC_InternalState.LineCounter=CRTCRegisters[4]) then CRTC_SetFlag(CRTC_VTOT_FLAG);
		  end;
		end;
	1:CRTC0_DoReg1;
	3:;
	8:CRTC0_DoReg8();
	7:begin
		  // confirmed: Register can be written at any time and takes immediate effect; not sure if 0 or HCC=R0 */
		  if ((CRTC_InternalState.LineCounter=CRTCRegisters[7]) and (CRTC_InternalState.HCount<>0)) then CRTC_InitVsync;
	  end;
	6:begin
		  // confirmed: immediate on type 0
		  if (CRTC_InternalState.LineCounter=CRTCRegisters[6]) then CRTC_ClearFlag(CRTC_VDISP_FLAG);

		  if ((CRTC_InternalState.LineCounter=0) and (CRTC_InternalState.RasterCounter=0)) then begin
			  if (CRTCRegisters[6]<>0) then CRTC_SetFlag(CRTC_VDISP_FLAG);
      end;
		  CRTC_DoDispEnable;
	  end;

	9:begin
		  if (CRTC_InternalState.CRTC_Flags and CRTC_VADJ_FLAG)<>0 then begin
			  if (CRTC_InternalState.VertAdjustCount=CRTCRegisters[9]) then CRTC_SetFlag(CRTC_MR_FLAG)
          else CRTC_ClearFlag(CRTC_MR_FLAG);
		  end else begin
			  // confirm r8
			  if (CRTC_InternalState.RasterCounter=CRTCRegisters[9]) then CRTC_SetFlag(CRTC_MR_FLAG)
          else CRTC_ClearFlag(CRTC_MR_FLAG);
		  end;
	  end;
		14,15:CRTC_InternalState.CursorMA:=(CRTCRegisters[14] shl 8) or CRTCRegisters[15];
  end;
end;

procedure CRTC_RegisterSelect(RegisterIndex:byte);
begin
	CRTC_InternalState.CRTC_Reg:=RegisterIndex;
end;

procedure CRTC0_WriteData(data:byte);
var
  CRTC_RegIndex:byte;
begin
	CRTC_RegIndex:=CRTC_InternalState.CRTC_Reg and $1f;

	// store registers using current CRTC information - masking out appropiate bits etc for this CRTC*/
	CRTCRegisters[CRTC_RegIndex]:=data and HD6845S_WriteMaskTable[CRTC_RegIndex];

	CRTC0_UpdateState(CRTC_RegIndex);
end;


procedure CRTC_WriteData(data:byte);
var
  CRTC_RegIndex:byte;
begin
	// to allow switching crtcs */
	CRTC_RegIndex:=CRTC_InternalState.CRTC_Reg and $1f;
	CRTCRegistersBackup[CRTC_RegIndex]:=data;

	// now do CRTC specific writes */
  CRTC0_WriteData(Data);
end;

function CRTC0_GetHorizontalSyncWidth:byte;
begin
	// confirmed: a programmed hsync of 0 generates no hsync
	CRTC0_GetHorizontalSyncWidth:=CRTCRegisters[3] and $0f;
end;

function GET_MA:word;
begin
  GET_MA:=(CRTCRegisters[12] shl 8) or CRTCRegisters[13];
end;

procedure CRTC0_DoHDisp;
begin
	// confirmed: if rcc=r9 at HDISP time then store MA for reload. It is possible to change R9 around R1 time only
	// and get the graphics to repeat but doesn't cause problems for RCC */
	// confirmed: gerald's tests seem to indicate that MAStore is not updated when vdisp is not active. i.e. in lower border */
	if (((CRTC_InternalState.CRTC_Flags and CRTC_MR_FLAG)<>0) and ((CRTC_InternalState.CRTC_Flags and CRTC_VDISP_FLAG)<>0)) then begin
			// remember it for next line
			CRTC_InternalState.MAStore:=CRTC_InternalState.MA;
  end;
end;

// setup a VSYNC to start at the beginning of the line */
procedure CRTC_InterlaceControl_SetupStandardVsync;
begin
	// set VSYNC immediatly */
	CRTC_SetFlag(CRTC_VS_FLAG);
	// keep VSYNC set at HTOT/2 */
	CRTC_InternalState.CRTC_HalfHtotFlags:=CRTC_VS_FLAG;
	CRTC_SetVsyncOutput(TRUE);
end;

procedure CRTC_InterlaceControl_FinishStandardVsync;
begin
	// clear vsync
	CRTC_ClearFlag(CRTC_VS_FLAG);
	// no VSYNC on next HTOT/2 */
	CRTC_InternalState.CRTC_HalfHtotFlags:=0;
	CRTC_SetVsyncOutput(FALSE);
end;

// call when VSYNC has begun
procedure CRTC_InterlaceControl_VsyncStart;
begin
		CRTC_InterlaceControl_SetupStandardVsync;
end;

procedure CRTC_InterlaceControl_VsyncEnd;
begin
		CRTC_InterlaceControl_FinishStandardVsync;
end;

procedure CRTC0_DoLineChecks;
begin
	// confirmed: immediate on type 0
	if (CRTC_InternalState.LineCounter=CRTCRegisters[6]) then begin
		CRTC_ClearFlag(CRTC_VDISP_FLAG);
		CRTC_DoDispEnable;
	end;
	// check Vertical sync position */
	if (CRTC_InternalState.LineCounter=CRTCRegisters[7]) then CRTC_InitVsync();
end;

procedure CRTC0_Reset;
var
  i:byte;
begin
	// set light pen registers - this is what my CPC
	// type 0 reports!
	CRTCRegisters[16]:=$014;
	CRTCRegisters[17]:=$07c;
	{

	    UM6845:
	    Reset Signal (/RES) is an input signal used to reset the CRTC. When /RES is at "low" level, it forces the CRTC into the following status:

	    * All the counters in the CRTC are cleared and the device stops the display operation
	    * All the outputs go down to "low" level.
	    * Control registers in the CRTC are not affected and remain unchanged.

	This signal is different from other HD6800 family LSIs in the following functions and has restrictions for usage:

	    * /RES has capability of reset function only when LPSTB is at "low" level.
	    * The CRTC starts the display operation immediatly after /RES goes "high" level.

	    }

	// vsync counter not active */
	CRTC_ClearFlag(CRTC_VSCNT_FLAG);
	// not in hsync */
	CRTC_ClearFlag(CRTC_HS_FLAG);
	// not in a vsync */
	CRTC_ClearFlag(CRTC_VS_FLAG);
	// not reached end of line */
	CRTC_ClearFlag(CRTC_HTOT_FLAG);
	// not reached end of frame */
	CRTC_ClearFlag(CRTC_VTOT_FLAG);

	// not reached last raster in char */
	CRTC_ClearFlag(CRTC_MR_FLAG);
	// not in vertical adjust */
	CRTC_ClearFlag(CRTC_VADJ_FLAG);
	// do not display graphics */
	CRTC_ClearFlag(CRTC_VDISP_FLAG);
	CRTC_ClearFlag(CRTC_HDISP_FLAG);
	CRTC_ClearFlag(CRTC_VADJWANTED_FLAG);
	CRTC_ClearFlag(CRTC_R8DT_FLAG);

	// reset all registers */
	for i:=0 to 15 do begin
		// select register */
		CRTC_RegisterSelect(i);
		// write data */
		CRTC_WriteData(0);
	end;

	// reset CRTC internal registers

	// reset horizontal count */
	CRTC_InternalState.HCount:=0;
	// reset line counter (vertical count) */
	CRTC_InternalState.LineCounter:=0;
	// reset raster count */
	CRTC_InternalState.RasterCounter:=0;
	// reset MA */
	CRTC_InternalState.MA:=0;
	CRTC_InternalState.MAStore:=CRTC_InternalState.MA;
	CRTC_InternalState.Frame:=0;

	CRTC_InternalState.CursorOutput:=0;
	CRTC_InternalState.CursorBlinkCount:=0;

	CRTC0_DoLineChecks;
end;

procedure CRTC0_MaxRasterMatch;
begin
	if (CRTC_InternalState.CRTC_Flags and CRTC_INTERLACE_ACTIVE)<>0 then begin
		if (CRTCRegisters[8] and (1 shl 1))<>0 then begin
			if (CRTC_InternalState.RasterCounter=(CRTCRegisters[9] shr 1)) then CRTC_SetFlag(CRTC_MR_FLAG)
			  else CRTC_ClearFlag(CRTC_MR_FLAG);
		end;
	end else begin
		if (CRTC_InternalState.CRTC_Flags and CRTC_VADJ_FLAG)<>0 then begin
			if (CRTC_InternalState.VertAdjustCount=CRTCRegisters[9]) then	CRTC_SetFlag(CRTC_MR_FLAG);
		end else begin
			if (CRTC_InternalState.RasterCounter=CRTCRegisters[9]) then CRTC_SetFlag(CRTC_MR_FLAG);
		end; //CRTC_VADJ_FLAG
	end; //CRTC_INTERLACE_ACTIVE

	if (CRTC_InternalState.CRTC_Flags and CRTC_MR_FLAG)<>0 then begin
		if (CRTC_InternalState.LineCounter=CRTCRegisters[4]) then
			CRTC_SetFlag(CRTC_VTOT_FLAG);
	end;
end;

procedure CRTC0_RestartFrame;
begin

	CRTC_InternalState.LinesAfterFrameStart:=0;

	CRTC_InternalState.MAStore:=GET_MA;
	CRTC_InternalState.MA:=CRTC_InternalState.MAStore;

	CRTC_InternalState.RasterCounter:=0;
	CRTC_InternalState.LineCounter:=0;

  CRTC_InternalState.RasterCounter:=0;

	CRTC_SetFlag(CRTC_VDISP_FLAG);

	CRTC_DoDispEnable;


	// on type 0, the first line is always visible */

{#ifdef HD6845S
	// if type 0 is a HD6845S
	CRTC_SetFlag(CRTC_VDISP_FLAG);
#endif}
	// incremented when?
	CRTC_InternalState.CursorBlinkCount:=CRTC_InternalState.CursorBlinkCount+1;
	if (CRTCRegisters[10] and (1 shl 6))<>0 then begin
		// blink */
		if (CRTCRegisters[11] and (1 shl 5))<>0 then begin
			// 32 field period */
			// should we just test bit 5?
			if (CRTC_InternalState.CursorBlinkCount=32) then begin
				CRTC_InternalState.CursorBlinkCount:=0;
				CRTC_InternalState.CursorBlinkOutput:=CRTC_InternalState.CursorBlinkOutput xor 1;
			end;
		end else begin
			// 16 field period
			// should we just test bit 4?
			if (CRTC_InternalState.CursorBlinkCount=16) then begin
				CRTC_InternalState.CursorBlinkCount:=0;
				CRTC_InternalState.CursorBlinkOutput:=CRTC_InternalState.CursorBlinkOutput xor 1;
			end;
		end;
		if (CRTC_InternalState.CursorBlinkOutput)<>0 then CRTC_SetFlag(CRTC_CURSOR_ACTIVE)
		  else CRTC_ClearFlag(CRTC_CURSOR_ACTIVE);
	end else begin
		if (CRTCRegisters[10] and (1 shl 5))<>0 then begin
			// no blink, no output */
			CRTC_ClearFlag(CRTC_CURSOR_ACTIVE);
			CRTC_InternalState.CursorBlinkOutput:=0;
		end else begin
			// no blink
			CRTC_SetFlag(CRTC_CURSOR_ACTIVE);
		end;
	end;
end;

procedure CRTC0_DoVerticalSyncCounter;
begin
	// are we counting vertical syncs?
	if (CRTC_InternalState.CRTC_Flags and CRTC_VSCNT_FLAG)<>0 then begin
		// update vertical sync counter */
		CRTC_InternalState.VerticalSyncCount:=CRTC_InternalState.VerticalSyncCount+1;
		// if vertical sync count = vertical sync width then stop vertical sync
		// if vertical sync width = 0, the counter will wrap after incrementing from 15 causing
		//a vertical sync width of 16
		if (CRTC_InternalState.VerticalSyncCount=CRTC_InternalState.VerticalSyncWidth) then begin
			// count done
			CRTC_InternalState.VerticalSyncCount:=0;
			CRTC_ClearFlag(CRTC_VSCNT_FLAG);
		end;
	end;
end;

// executed for each complete line done by the CRTC
procedure CRTC0_DoLine;
begin
	// to be confirmed; ma works during vadjust
	// increment raster counter
	CRTC_InternalState.RasterCounter:=(CRTC_InternalState.RasterCounter+1) and $1f;

	CRTC0_DoVerticalSyncCounter;
	// are we in vertical adjust ?
	if (CRTC_InternalState.CRTC_Flags and CRTC_VADJ_FLAG)<>0 then begin
		CRTC_InternalState.VertAdjustCount:=(CRTC_InternalState.VertAdjustCount+1) and $1f;
		// vertical adjust matches counter? */
		if (CRTC_InternalState.VertAdjustCount=CRTCRegisters[5]) then begin
			CRTC_ClearFlag(CRTC_VADJ_FLAG);
			CRTC0_RestartFrame;
		end;
	end; //CRTC_VADJ_FLAG

	if (CRTC_InternalState.CRTC_Flags and CRTC_MR_FLAG)<>0 then begin
		CRTC_ClearFlag(CRTC_MR_FLAG);
		CRTC_InternalState.RasterCounter:=0;

		// this will trigger once at vtot */
		if (CRTC_InternalState.CRTC_Flags and CRTC_VTOT_FLAG)<>0 then begin
			CRTC_ClearFlag(CRTC_VTOT_FLAG);

			// toggle frame; here or after vadj? */
			CRTC_InternalState.Frame:=CRTC_InternalState.Frame xor 1;

			// is it active? i.e. VertAdjust!=0 */
			if (CRTCRegisters[5]<>0) then begin
				// yes
				CRTC_InternalState.VertAdjustCount:=0;
				CRTC_SetFlag(CRTC_VADJ_FLAG);

				// confirmed: on type 0, line counter will increment when entering vertical adjust, but not count furthur.
				//i.e. if R5!=0 and R7=VTOT then vertical sync will trigger */
				// increment once going into vertical adjust */
				CRTC_InternalState.LineCounter:=(CRTC_InternalState.LineCounter+1) and $7f;
			end else begin
				// restart frame */
				CRTC0_RestartFrame;
			end;
		end	else begin
			// confirmed: on type 0, line counter will increment when entering vertical adjust, but not count furthur.
			//i.e. if R5!=0 and R7=VTOT then vertical sync will trigger
			// do not increment during vertical adjust
			if (CRTC_InternalState.CRTC_Flags and CRTC_VADJ_FLAG)=0 then
				CRTC_InternalState.LineCounter:=(CRTC_InternalState.LineCounter+1) and $7f;
		end; //CRTC_VTOT_FLAG
	end; //CRTC_MR_FLAG

	// transfer store value */

	CRTC_InternalState.MA:=CRTC_InternalState.MAStore;

	if ((CRTCRegisters[8] and 1)<>0) then CRTC_SetFlag(CRTC_INTERLACE_ACTIVE)
	  else CRTC_ClearFlag(CRTC_INTERLACE_ACTIVE);

	CRTC0_MaxRasterMatch;

	// do last to capture line counter increment in R5 and frame restart */
	CRTC0_DoLineChecks;

end;

procedure CRTC_DoCycles(Cycles:byte);
var
  i:byte;
  PreviousCursorOutput:integer;
  PreviousFlags,Flags:word;
begin

for i:=1 to Cycles do begin
		CRTC_InternalState.CharsAfterHsyncStart:=CRTC_InternalState.CharsAfterHsyncStart+1;
		/// increment horizontal count
		CRTC_InternalState.HCount:=(CRTC_InternalState.HCount+1) and $0ff;
		CRTC_InternalState.MA:=(CRTC_InternalState.MA+1) and $03fff;

		if (CRTC_InternalState.CRTC_Flags and CRTC_HTOT_FLAG)<>0 then begin
			PreviousFlags:=CRTC_InternalState.CRTC_Flags;
			CRTC_ClearFlag(CRTC_HTOT_FLAG);
			// zero count
			CRTC_InternalState.HCount:=0;
			CRTC_InternalState.LinesAfterFrameStart:=CRTC_InternalState.LinesAfterFrameStart+1;
			CRTC_InternalState.LinesAfterVsyncStart:=CRTC_InternalState.LinesAfterVsyncStart+1;

      CRTC0_DoLine;

			if (((PreviousFlags xor CRTC_InternalState.CRTC_Flags) and CRTC_VSCNT_FLAG)<>0) then begin
				// vsync counter bit has changed state */
				if (CRTC_InternalState.CRTC_Flags and CRTC_VSCNT_FLAG)<>0 then
					// change from vsync counter inactive to active */
					CRTC_InterlaceControl_VsyncStart()
				else
					// change from counter active to inactive */
					CRTC_InterlaceControl_VsyncEnd();
			end; //CRTC_VSCNT_FLAG

			CRTC_InternalState.CRTC_FlagsAtLastHtot:=CRTC_InternalState.CRTC_Flags;

		end; //CRTC_HTOT_FLAG


		// does horizontal equal Htot? */
		if (CRTC_InternalState.HCount=CRTCRegisters[0]) then CRTC_SetFlag(CRTC_HTOT_FLAG);

		if (CRTC_InternalState.HCount=(CRTCRegisters[0] shr 1)) then begin
			// get flags
			Flags:=CRTC_InternalState.CRTC_Flags;
			// clear VSYNC flag
			Flags:=Flags and not(CRTC_VS_FLAG);
			// set/clear VSYNC flag
			Flags:=Flags or CRTC_InternalState.CRTC_HalfHtotFlags;
			// store new flags
			CRTC_InternalState.CRTC_Flags:=Flags;
		end;

		// Horizontal Sync Width Counter
		// are we counting horizontal syncs?
		if (CRTC_InternalState.CRTC_Flags and CRTC_HS_FLAG)<>0 then begin
			CRTC_InternalState.HorizontalSyncCount:=CRTC_InternalState.HorizontalSyncCount+1;
			// if horizontal sync count = Horizontal Sync Width then
			// stop horizontal sync
			if (CRTC_InternalState.HorizontalSyncCount=CRTC_InternalState.HorizontalSyncWidth) then begin
				CRTC_InternalState.HorizontalSyncCount:=0;
				// stop horizontal sync counter
				CRTC_ClearFlag(CRTC_HS_FLAG);
				// call functions that would happen on a HSYNC */
				CRTC_SetHsyncOutput(FALSE);
			end;
		end; //CRTC_HS_FLAG

		// does current horizontal count equal position to start horizontal sync?
		if (CRTC_InternalState.HCount=CRTCRegisters[2]) then begin
			CRTC_InternalState.CharsAfterHsyncStart:=0;
      CRTC_InternalState.HorizontalSyncWidth:=CRTC0_GetHorizontalSyncWidth;

			// if horizontal sync = 0, in the HD6845S no horizontal
			//sync is generated. The input to the flip-flop is 1 from
			//both Horizontal Sync Position and HorizontalSyncWidth, and
			//the HSYNC is not even started
			if (CRTC_InternalState.HorizontalSyncWidth<>0) then begin
				// are we already in a HSYNC?
				if (CRTC_InternalState.CRTC_Flags and CRTC_HS_FLAG)=0 then begin
					// no.. */

					// enable horizontal sync counter */
					CRTC_SetFlag(CRTC_HS_FLAG);

					CRTC_SetHsyncOutput(TRUE);
					// initialise counter */
					CRTC_InternalState.HorizontalSyncCount:=0;
				end;
			end;
		end;

		// confirmed: on type 3, border is turned off at HStart */
		if (CRTC_InternalState.HCount=CRTC_InternalState.HStart) then begin
			// enable horizontal display */
			CRTC_SetFlag(CRTC_HDISP_FLAG);
			CRTC_DoDispEnable;
		end;

		// confirmed: on type 3, border is turned on at HEnd. */
		if (CRTC_InternalState.HCount=CRTC_InternalState.HEnd) then begin
			CRTC_ClearFlag(CRTC_HDISP_FLAG);
			CRTC_DoDispEnable;
		end;

		// confirmed: on type 3, hdisp is triggered from R1 because I don't see the screen distort which would happen
		// if it's at HEnd
		if (CRTC_InternalState.HCount=CRTCRegisters[1]) then CRTC0_DoHDisp;

		if (CRTC_InternalState.RasterCounter=(CRTCRegisters[10] and $1f)) then CRTC_SetFlag(CRTC_CURSOR_LINE_ACTIVE);

		if (CRTC_InternalState.RasterCounter=(CRTCRegisters[11] and $1f)) then CRTC_ClearFlag(CRTC_CURSOR_LINE_ACTIVE);

		PreviousCursorOutput:=CRTC_InternalState.CursorOutput;

		CRTC_InternalState.CursorOutput:=0;
		if (
			(CRTC_InternalState.CursorMA=CRTC_InternalState.MA) and
			((CRTC_InternalState.CRTC_Flags and (CRTC_CURSOR_LINE_ACTIVE or CRTC_CURSOR_ACTIVE))=(CRTC_CURSOR_LINE_ACTIVE or CRTC_CURSOR_ACTIVE))
			)
		then CRTC_InternalState.CursorOutput:=1;

		///if (PreviousCursorOutput<>CRTC_InternalState.CursorOutput) then CRTC_DoCursorOutput(CRTC_InternalState.CursorOutput);

		//Graphics_Update();

	end; //for
end;


end.
