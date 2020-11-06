unit m6845;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}main_engine;

const
  CRTC_VS_FLAG=$001;	  // Vsync active


type
  tcrt_internal_state=record
    requested_addr,
    next_addr,
    addr,
    next_address,
    scr_base,
    char_count,
    line_count,
    raster_count,
    hsw,
    hsw_count,
    vsw,
    vsw_count,
    flag_hadhsync,
    flag_inmonhsync,
    flag_invsync,
    flag_invta,
    flag_newscan,
    flag_reschar,
    flag_resframe,
    flag_resnext,
    flag_resscan,
    flag_resvsync,
    flag_startvta,
    last_hend,
    reg5,
    r7match,
    r9match,
    hstart,
    hend:integer;
    reg_select:byte;
    registers:array[0..17] of byte;
    CharInstMR:procedure;
    CharInstSL:procedure;
{   // 6128+ split screen support
   unsigned int split_addr;
   unsigned char split_sl;
   unsigned int sl_count;
   unsigned char interrupt_sl;}
  end;
  t_flags1 = record
          case byte of
             0: (monVSYNC,inHSYNC,DISPTIMG,HDSPTIMG:byte);
             1: (wl,wh:word);
             2: (combined:dword);
          end;
  t_new_dt = record
          case byte of
             0: (NewDISPTIMG,NewHDSPTIMG:byte);
             1: (combined:word);
          end;

var
  CRTC:tcrt_internal_state;
  LastPreRend:dword;
  MinVSync, MaxVSync:word;
  iMonHSPeakPos, iMonHSStartPos, iMonHSEndPos, iMonHSPeakToStart, iMonHSStartToPeak, iMonHSEndToPeak, iMonHSPeakToEnd:integer;
  HorzPos, MonHSYNC, MonFreeSync:integer;
  HSyncDuration, MinHSync, MaxHSync:integer;
  HadP:integer;
  PosShift, HorzChar, HorzMax:byte;
  flags1:t_flags1;
  new_dt:t_new_dt;
  PreRender:procedure;
  RendWid,RendOut:pbyte;
  RendStart,RendPos:pword;
  HorzPix:array[0..48] of byte;


implementation

{

procedure NoChar;
begin
end;

procedure crtc_init;
begin
      ModeMaps[0] = M0hMap;
      ModeMaps[1] = M1hMap;
      ModeMaps[2] = M2hMap;
      ModeMaps[3] = M3hMap;
   ModeMap = ModeMaps[0];
   for (int l = 0; l < 0x7400; l++) {
      int j = l << 1; // actual address
      MAXlate[l] = (j & 0x7FE) | ((j & 0x6000) << 1);
   }

{   int Wid;
   if (dwXScale == 1) {
      Wid = 8;
      PosShift = 5;
   for (int i = 0; i < 48; i++) {
      HorzPix[i] = Wid;
   }
{   HorzPix[48] = 0;
   RendStart = reinterpret_cast<dword *>(&RendBuff[Wid]);
end;


procedure crtc_reset;
begin
   fillchar(CRTC^,0,sizeof(CRTC)); // clear CRTC data structure
   CRTC.registers[0]:=$3f;
   CRTC.registers[2]:=$2e;
   CRTC.registers[3]:=$8e;

   RendPos:=punbuf;
   RendOut:=byte(RendStart);
   RendWid:=addr(HorzPix[0]);

   HorzPos:=$500;
   HorzChar:=$04;
   HorzMax:=48;
   HSyncDuration:=$A00;
   MinHSync:=$4000-HSyncDuration-257;
   MaxHSync:=$4000-HSyncDuration+257;
   MonHSYNC:=$4000-HSyncDuration;
   MonFreeSync:=MonHSYNC;
   flags1.monVSYNC=0;
   flags1.DISPTIMG:=$ff;
   flags1.HDSPTIMG:=$03;
   new_dt.NewDISPTIMG:=$ff;
   new_dt.NewHDSPTIMG:=$03;
   CRTC.CharInstSL:=NoChar;
   CRTC.CharInstMR:=NoChar;
   //CRTC.split_addr:=0;
   //CRTC.split_sl = 0;
   //CRTC.sl_count = 0;
   //CRTC.interrupt_sl = 0;

   MinVSync:=MID_VHOLD;
   MaxVSync:=MinVSync + MIN_VHOLD_RANGE + static_cast<int>(ceil(static_cast<float>((MinVSync - MIN_VHOLD) *
    (MAX_VHOLD_RANGE - MIN_VHOLD_RANGE) / (MAX_VHOLD - MIN_VHOLD))));
end;

procedure set_prerender;
begin
   LastPreRend:=flags1.combined;
   if (LastPreRend=$03ff0000) then begin
      PreRender:=CPC.scr_prerendernorm;
   end else begin
      if (LastPreRend=0) then begin
         PreRender:=CPC.scr_prerenderbord;
      end else begin
         PreRender:=CPC.scr_prerendersync;
      end;
   end;
end;

procedure crtc_cycle(repeat_count:integer);
var
  val:dword;
begin
//   while (repeat_count) {
      if (VDU.flag_drawing) then begin // are we within the rendering area?
         if (HorzChar<HorzMax) then begin // below horizontal cut-off?
            if (flags1.combined<>LastPreRend) then begin
               set_prerender; // change pre-renderer if necessary
            end;
            PreRender(); // translate CPC video memory bytes to entries referencing the palette
            CPC.scr_render(); // render to the video surface at the current bit depth
         end;
      end;
      CRTC.next_address:=MAXlate[(CRTC.addr + CRTC.char_count) and $73ff] or CRTC.scr_base; // next address for PreRender
      flags1.wh:=new_dt.combined; // update the DISPTMG flags

      iMonHSStartPos:=iMonHSStartPos+$100;
      iMonHSEndPos:=iMonHSEndPos+$100;
      iMonHSPeakPos:=iMonHSPeakPos+$100;
      HorzPos:=HorzPos+$100;
      HorzChar:=HorzChar+1;
      if (HorzPos>=MonHSYNC) then begin
         if (VDU.flag_drawing) then begin
            CPC.scr_base:=CPC.scr_base+CPC.scr_line_offs; // advance surface pointer to next row
         end;
         HadP:=1;
         iMonHSPeakPos:=HorzPos-MonHSYNC;
         iMonHSStartToPeak:=iMonHSStartPos-iMonHSPeakPos;
         iMonHSEndToPeak:=iMonHSEndPos-iMonHSPeakPos;
         HorzPos:=iMonHSPeakPos-HSyncDuration;

         HorzChar:=HorzPos shr 8;
         val:=(HorzPos and $f0) shr PosShift;
         if (val=0) then begin
            HorzMax:=48;
            HorzPix[0]:=HorzPix[1];
            RendPos:=RendStart;
            HorzChar:=HorzChar-1;
         end else begin
            RendPos:=reinterpret_cast<dword *>(&RendBuff[val]);
            int tmp = reinterpret_cast<byte *>(RendStart) - reinterpret_cast<byte *>(RendPos);
            HorzPix[48]:= static_cast<byte>(tmp);
            HorzPix[0]:=HorzPix[1]-tmp;
            HorzMax:=49;
         end;
         RendOut = reinterpret_cast<byte *>(RendStart);
         RendWid = &HorzPix[0];
         CPC.scr_pos = CPC.scr_base;
         VDU.scrln++;
         VDU.scanline++;
         if (dword((VDU.scrln)) >= MAX_DRAWN) then begin
            VDU.flag_drawing:=0;
         end else begin
            VDU.flag_drawing:=1;
         end;
      end;

// ----------------------------------------------------------------------------

      if (CRTC.char_count == CRTC.registers[0]) { // matches horizontal total?
         CRTC.last_hend = CRTC.char_count; // preserve current line length in chars
         CRTC.flag_newscan = 1; // request starting a new scan line
         CRTC.char_count = 0; // reset the horizontal character count
      } //else {
    {     CRTC.char_count++; // update counter
         CRTC.char_count &= 255; // limit to 8 bits
      }

 {     if (CRTC.char_count == CRTC.registers[0]) { // matches horizontal total?
         if (CRTC.raster_count == CRTC.registers[9]) { // matches maximum raster address?
            CRTC.flag_reschar = 1; // request a line count update
         } //else {
{            CRTC.flag_reschar = 0; // still within the current character line
         }
 //        if (CRTC.flag_resnext) { // ready to restart frame?
 {           CRTC.flag_resnext = 0;
            CRTC.flag_resframe = 1; // request a frame restart
         }
  //       if (CRTC.flag_startvta) { // ready to start vertical total adjust?
    {        CRTC.flag_startvta = 0;
            CRTC.flag_invta = 1; // entering vertical total adjust
         }
     //    if (CRTC.flag_invta) { // in vertical total adjust?
       {     if ((CRTC.raster_count == CRTC.registers[9]) && (CRTC.line_count == CRTC.registers[4])) {
               CRTC.flag_resscan = 1; // raster counter only resets once at start of vta
            }// else {
               {CRTC.flag_resscan = 0; // raster counter keeps increasing while in vta
            }
//         }
 //     }

   //   if (CRTC.char_count == CRTC.registers[1]) { // matches horizontal displayed?
     {    if (CRTC.raster_count == CRTC.registers[9]) { // matches maximum raster address?
            CRTC.next_addr = CRTC.addr + CRTC.char_count;
         }
   //   }

   {   if (!flags1.inHSYNC) { // not in HSYNC?
         if (CRTC.char_count == CRTC.registers[2]) { // matches horizontal sync position?
            flags1.inHSYNC = 0xff; // turn HSYNC on
            CRTC.flag_hadhsync = 1; // prevent GA from processing more than one HSYNC per scan line
            CRTC.hsw_count = 0; // initialize horizontal sync width counter
            match_hsw();
         }
    //  } //else {
  {       match_hsw();
      }

   {   CRTC.CharInstSL(); // if necessary, process vertical total delay
      CRTC.CharInstMR(); // if necessary, process maximum raster count delay

      if (CRTC.flag_newscan) { // scanline change requested?
         CRTC.flag_newscan = 0;
         if (CRTC.split_sl && CRTC.sl_count == CRTC.split_sl) {
            CRTC.next_addr = CRTC.split_addr;
         }
    {     CRTC.addr = CRTC.next_addr;
         CRTC.sl_count++;

         if (CRTC.flag_invsync) { // VSYNC active?
            CRTC.vsw_count++; // update counter
            CRTC.vsw_count &= 15; // limit to 4 bits
            if (CRTC.vsw_count == CRTC.vsw) { // matches vertical sync width?
               CRTC.vsw_count = 0; // reset counter
               CRTC.flag_resvsync = 1; // request VSYNC reset
            }
  //       }

    {     if (CRTC.flag_resframe) { // frame restart requested?
            restart_frame();
         } //else {
        {    if (CRTC.flag_resscan) { // raster counter reset requested?
               CRTC.flag_resscan = 0;
               CRTC.raster_count = 0; // reset counter
               CRTC.scr_base = 0;
            } //else {
{               CRTC.raster_count++; // update counter
               CRTC.raster_count &= 31; // limit to 5 bits
               if (!CRTC.raster_count) { // did the counter wrap around?
                  match_line_count();
               }
 {              CRTC.scr_base = (CRTC.scr_base + 0x0800) & 0x3800;
            }
  //       }

    {     CRTC.CharInstSL = CharSL1;

         dword temp = 0;
         if (CRTC.raster_count == CRTC.registers[9]) { // matches maximum raster address?
            temp = 1;
            CRTC.flag_resscan = 1; // request a raster counter reset
         }
     {    if (CRTC.r9match != temp) {
            CRTC.r9match = temp;
         }
      {   if (temp) {
            CRTC.CharInstMR = CharMR1;
         }

       {  if (CRTC.flag_invta) { // in vertical total adjust?
            if (CRTC.raster_count == CRTC.reg5) { // matches vertical total adjust?
               restart_frame();
               if (CRTC.registers[9] == 0) { // maximum raster address is zero?
                  CRTC.flag_resscan = 1; // request a raster counter reset
               }
     //       }
      //   }

        { if (CRTC.flag_reschar) { // line count update requested?
            CRTC.line_count++; // update counter
            CRTC.line_count &= 127; // limit to 7 bits
            reload_addr();
         }

      {   if (CRTC.flag_invsync) { // in VSYNC?
            if (CRTC.flag_resvsync) { // end of VSYNC?
               CRTC.flag_invsync = 0; // turn VSYNC off
               CRTC.flag_resvsync = 0;
               if (VDU.scanline == MaxVSync) { // above maximum scanline count?
                  frame_finished();
               }
       //     } else {
          {     if (VDU.scanline > MinVSync) { // above minimum scanline count?
                  frame_finished();
               }
//            }
  //       } else if (VDU.scanline == MaxVSync) { // above maximum scanline count?
    {        frame_finished();
         }
   //   }

     { if (CRTC.char_count == CRTC.hstart) { // leaving border area?
         new_dt.NewHDSPTIMG |= 0x01;
      }
   {   if (CRTC.char_count == CRTC.hend) { // entering border area?
         new_dt.NewHDSPTIMG &= 0xfe;
      }

// ----------------------------------------------------------------------------

   //   repeat_count--;
  //end;
//end;


end.
