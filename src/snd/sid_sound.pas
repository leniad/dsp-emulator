unit sid_sound;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}sound_engine,sid_tables,math,dialogs;

const
  TYPE_8580=0;
  TYPE_6581=1;
  maxLogicalVoices=4;
  max_voices=3;
  mix16monoMiddleIndex=256*maxLogicalVoices div 2;
  ENVE_STARTATTACK=0;
	ENVE_STARTRELEASE=2;
	ENVE_ATTACK=4;
	ENVE_DECAY=6;
	ENVE_SUSTAIN=8;
	ENVE_RELEASE=10;
	ENVE_SUSTAINDECAY=12;
	ENVE_MUTE=14;
	ENVE_STARTSHORTATTACK=16;
	ENVE_SHORTATTACK=16;
	ENVE_ALTER=32;
  noiseSeed=$7ffff8;
  masterVolumeLevels:array[0..15] of byte=(
	0,  17,  34,  51,  68,  85, 102, 119,
	136, 153, 170, 187, 204, 221, 238, 255);
  //envelope
  attackTabLen=255;
  attackTimes:array[0..15] of single=( // milliseconds */
	2.2528606,  8.0099577, 15.7696042, 23.7795619, 37.2963655, 55.0684591,
	66.8330845, 78.3473987,
	98.1219818, 244.554021, 489.108042, 782.472742, 977.715461, 2933.64701,
	4889.07793, 7822.72493);
  decayReleaseTimes:array[0..15] of single=( // milliseconds */
	8.91777693,  24.594051, 48.4185907, 73.0116639, 114.512475, 169.078356,
	205.199432, 240.551975,
	301.266125, 750.858245, 1501.71551, 2402.43682, 3001.89298, 9007.21405,
	15010.998, 24018.2111);

type
  type_filter=packed record
		  enabled:boolean;
      Type_,CurType:byte;
      Dy,ResDy:single;
      Value:word;
  end;
  type_sw_storage=packed record
		len:word;
		pnt:dword;
		stp:smallint;
	end;

  psidOperator=^sidOperator;
  sidOperator=class
    constructor create;
    destructor free;
    public
      reg:array[0..6] of byte;
      SIDfreq:dword;
      SIDpulseWidth:word;
      SIDctrl:byte;
      SIDAD,SIDSR:byte;

      carrier:psidOperator;
      modulator:psidOperator;
      sync:boolean;

      pulseIndex,newPulseIndex:word;
      curSIDfreq:word;
      curNoiseFreq:word;

      output:byte;//, outputMask;

      filtVoiceMask:byte;
      filtEnabled:boolean;
      filtLow, filtRef:single;
      filtIO:shortint;
      cycleLenCount:longint;
      cycleAddLenPnt:dword;
      cycleLen, cycleLenPnt:word;

      waveStep, waveStepAdd:word;
      waveStepPnt, waveStepAddPnt:dword;
      waveStepOld:word;
      wavePre:array[0..1] of type_sw_storage;

      noiseReg:dword;
      noiseStep, noiseStepAdd:dword;
      noiseOutput:byte;
      noiseIsLocked:boolean;

      ADSRctrl:byte;
      fenveStep, fenveStepAdd:single;
      enveStep:dword;
      enveStepAdd:word;
      enveStepPnt, enveStepAddPnt:dword;
      enveVol, enveSusVol:byte;
      enveShortAttackCount:word;

      outProc:function(pVoice:psidOperator):shortint;
      ADSRproc:function(pVoice:psidOperator):word;
      waveProc:procedure(pVoice:psidOperator);

      procedure clear;
      procedure set_;
      procedure set2;

    private
      procedure wave_calc_cycle_len;
    end;
  sid_chip=class(snd_chip_class)
    constructor create(clock:dword;type_:byte);
    destructor free;
    public
      type_:integer;
	    clock:dword;
      //PCMfreq:word; // samplerate of the current systems soundcard/DAC
      PCMsid,PCMsidNoise:dword;
      reg:array[0..$1f] of byte;
	    masterVolume:byte;
      masterVolumeAmplIndex:word;
      filter:type_filter;
	    optr:array[0..(max_voices-1)] of sidOperator;
	    optr3_outputmask:integer;
      procedure reset;
      procedure write(dir,valor:byte);
      function read(dir:byte):byte;
      procedure update;
    private
      zero16bit:word;
      filterTable:array[0..$7ff] of single;
      bandPassParam:array[0..$7ff] of single;
      filterResTable:array[0..15] of single;
      mix16mono:array[0..(256*maxLogicalVoices-1)] of word;
      procedure MixerInit(threeVoiceAmplify:integer);
      procedure filterTableInit;
      procedure syncEm;
  end;

  function enveEmuStartAttack(pVoice:psidOperator):word;
  function enveEmuStartRelease(pVoice:psidOperator):word;
  function enveEmuAttack(pVoice:psidOperator):word;
  function enveEmuDecay(pVoice:psidOperator):word;
  function enveEmuSustain(pVoice:psidOperator):word;
  function enveEmuRelease(pVoice:psidOperator):word;
  function enveEmuSustainDecay(pVoice:psidOperator):word;
  function enveEmuMute(pVoice:psidOperator):word;
  function enveEmuStartShortAttack(pVoice:psidOperator):word;
  function enveEmuAlterAttack(pVoice:psidOperator):word;
  function enveEmuAlterDecay(pVoice:psidOperator):word;
  function enveEmuAlterSustain(pVoice:psidOperator):word;
  function enveEmuAlterRelease(pVoice:psidOperator):word;
  function enveEmuAlterSustainDecay(pVoice:psidOperator):word;
  procedure sidMode00(pVoice:psidOperator);
  procedure sidMode10(pVoice:psidOperator);
  procedure sidMode20(pVoice:psidOperator);
  procedure sidMode30(pVoice:psidOperator);
  procedure sidMode40(pVoice:psidOperator);
  procedure sidMode50(pVoice:psidOperator);
  procedure sidMode60(pVoice:psidOperator);
  procedure sidMode70(pVoice:psidOperator);
  procedure sidMode80(pVoice:psidOperator);
  procedure sidModeLock(pVoice:psidOperator);
  procedure sidMode14(pVoice:psidOperator);
  procedure sidMode34(pVoice:psidOperator);
  procedure sidMode54(pVoice:psidOperator);
  procedure sidMode74(pVoice:psidOperator);
  procedure sidMode80hp(pVoice:psidOperator);

var
  sid_0:sid_chip;

implementation
var
  ampMod1x8:array[0..((256*256)-1)] of shortint;
  sidModeNormalTable:array[0..15] of procedure(pVoice:psidOperator)=(
	sidMode00, sidMode10, sidMode20, sidMode30, sidMode40, sidMode50, sidMode60, sidMode70,
	sidMode80, sidModeLock, sidModeLock, sidModeLock, sidModeLock, sidModeLock, sidModeLock, sidModeLock);
  sidModeRingTable:array[0..15] of procedure(pVoice:psidOperator)=(
	sidMode00, sidMode14, sidMode00, sidMode34, sidMode00, sidMode54, sidMode00, sidMode74,
	sidModeLock, sidModeLock, sidModeLock, sidModeLock, sidModeLock, sidModeLock, sidModeLock, sidModeLock);
  enveModeTable:array[0..31] of function(pVoice:psidOperator):word = (
  // 0 */
	enveEmuStartAttack, enveEmuStartRelease,
	enveEmuAttack, enveEmuDecay, enveEmuSustain, enveEmuRelease,
	enveEmuSustainDecay, enveEmuMute,
	// 16 */
	enveEmuStartShortAttack,
	enveEmuMute, enveEmuMute, enveEmuMute,
	enveEmuMute, enveEmuMute, enveEmuMute, enveEmuMute,
	// 32        */
	enveEmuStartAttack, enveEmuStartRelease,
	enveEmuAlterAttack, enveEmuAlterDecay, enveEmuAlterSustain, enveEmuAlterRelease,
	enveEmuAlterSustainDecay, enveEmuMute,
	// 48        */
	enveEmuStartShortAttack,
	enveEmuMute, enveEmuMute, enveEmuMute,
	enveEmuMute, enveEmuMute, enveEmuMute, enveEmuMute);
  releaseTabLen:dword;
  releasePos:array[0..255] of dword;
  masterAmplModTable:array[0..(16*256)-1] of word;
  attackRates:array[0..15] of single;
  decayReleaseRates:array[0..15] of single;
  triangleTable:array[0..4095] of byte;
  sawtoothTable:array[0..4095] of byte;
  squareTable:array[0..(2*4096)-1] of byte;
  waveform30:pbyte;
  waveform50:pbyte;
  waveform60:pbyte;
  waveform70:pbyte;
  noiseTableMSB:array[0..(1 shl 8)-1] of byte;
  noiseTableLSB:array[0..(1 shl 16)-1] of byte;

procedure sidInitMixerEngine;
var
  filterAmpl:single;
  si:byte;
  sj:integer;
  uk:word;
begin
	// 8-bit volume modulation tables. */
	filterAmpl:=0.7;
	uk:=0;
	for si:=0 to 255 do begin
		for sj:=-128 to 127 do begin
			ampMod1x8[uk]:=trunc(((si*sj)/255)*filterAmpl);
      uk:=uk+1;
		end;
	end;
end;

function sshr(num:integer;fac:byte):integer;
begin
  if num<0 then sshr:=-(abs(num) shr fac)
    else sshr:=num shr fac;
end;

procedure waveCalcFilter(pVoice:psidOperator);
var
  tmp,tmp2,sample,sample2:single;
  tmpint:integer;
begin
	if pVoice.filtEnabled then begin
		if (sid_0.filter.Type_<>0) then begin
			if (sid_0.filter.Type_=$20) then begin
				pVoice.filtLow:=pVoice.filtLow+(pVoice.filtRef*sid_0.filter.Dy);
				tmp:=pVoice.filtIO-pVoice.filtLow;
				tmp:=tmp-(pVoice.filtRef*sid_0.filter.ResDy);
				pVoice.filtRef:=pVoice.filtRef+(tmp*sid_0.filter.Dy);
				pVoice.filtIO:=shortint(trunc(pVoice.filtRef-pVoice.filtLow/4));
			end else if (sid_0.filter.Type_=$40) then begin
				pVoice.filtLow:=pVoice.filtLow+(pVoice.filtRef*sid_0.filter.Dy*0.1);
				tmp:=pVoice.filtIO-pVoice.filtLow;
				tmp:=tmp-(pVoice.filtRef*sid_0.filter.ResDy);
				pVoice.filtRef:=pVoice.filtRef+(tmp*(sid_0.filter.Dy));
				tmp2:=pVoice.filtRef-pVoice.filtIO/8;
				if (tmp2<-128) then tmp2:=-128;
				if (tmp2>127) then tmp2:=127;
				pVoice.filtIO:=shortint(trunc(tmp2));
			end else begin
				pVoice.filtLow:=pVoice.filtLow+(pVoice.filtRef*sid_0.filter.Dy);
				sample:=pVoice.filtIO;
				sample2:=sample-pVoice.filtLow;
				tmpint:=trunc(sample2);
				sample2:=sample2-(pVoice.filtRef*sid_0.filter.ResDy);
				pVoice.filtRef:=pVoice.filtRef+(sample2*sid_0.filter.Dy);
				if (sid_0.filter.Type_=$10) then pVoice.filtIO:=trunc(pVoice.filtLow)
				  else if (sid_0.filter.Type_=$30) then pVoice.filtIO:=trunc(pVoice.filtLow)
				    else if (sid_0.filter.Type_=$50) then pVoice.filtIO:=trunc(sample-sshr(tmpint,1))
				      else if (sid_0.filter.Type_=$60) then pVoice.filtIO:=tmpint
				        else if (sid_0.filter.Type_=$70) then pVoice.filtIO:=trunc(sample-sshr(tmpint,1));
			end;
		end else // pVoice->sid->filter.Type == 0x00 */
			pVoice.filtIO:=0;
	end;
end;

function wave_calc_normal(pVoice:psidOperator):shortint;
begin
	if (pVoice.cycleLenCount<=0) then begin
		pVoice.wave_calc_cycle_len;
		if (pVoice.SIDctrl and $40)<>0 then begin
			pVoice.pulseIndex:=pVoice.newPulseIndex;
			if (pVoice.pulseIndex>2048) then pVoice.waveStep:=0;
		end;
	end;
	pVoice.waveProc(pVoice);
	pVoice.filtIO:=ampMod1x8[pVoice.ADSRproc(pVoice) or pVoice.output];
	waveCalcFilter(pVoice);
	wave_calc_normal:=pVoice.filtIO;//&pVoice->outputMask;
end;

procedure enveEmuInit(updateFreq:dword;measuredValues:boolean);
var
	i,j,k:dword;
  tmpVol:word;
  scaledenvelen:dword;
begin
	releaseTabLen:=sizeof(releaseTab);
	for i:=0 to 255 do begin
		j:=0;
		while ((j<releaseTabLen) and (releaseTab[j]>i)) do j:=j+1;
		if (j<releaseTabLen) then releasePos[i]:=j
		  else releasePos[i]:=releaseTabLen-1;
	end;
	k:=0;
	for i:=0 to 15 do begin
		for j:=0 to 255 do begin
			tmpVol:=j;
			if measuredValues then begin
				tmpVol:=trunc((293.0*(1-exp(j/-130.0)))+4.0);
				if (j=0) then tmpVol:=0;
				if (tmpVol>255) then tmpVol:=255;
			end;
			// Want the modulated volume value in the high byte. */
			masterAmplModTable[k]:=round((tmpVol*masterVolumeLevels[i])/255) shl 8;
      k:=k+1;
		end;
	end;
	for i:=0 to 15 do begin
		scaledenvelen:=trunc(floor((attackTimes[i]*updateFreq)/1000));
		if (scaledenvelen=0) then scaledenvelen:=1;
		attackRates[i]:=attackTabLen/scaledenvelen;
		scaledenvelen:=trunc(floor((decayReleaseTimes[i]*updateFreq)/1000));
		if (scaledenvelen=0) then scaledenvelen:=1;
		decayReleaseRates[i]:=releaseTabLen/scaledenvelen;
	end;
end;

procedure sidInitWaveformTables(type_:byte);
var
	i,j:integer;
	k:word;
  ni:dword;
begin
	k:=0;
	for i:=0 to 255 do
		for j:=0 to 7 do begin
      triangleTable[k]:=i;
      k:=k+1;
    end;
	for i:=255 downto 0 do
		for j:=0 to 7 do begin
			triangleTable[k]:=i;
      k:=k+1;
    end;
	k:=0;
	for i:=0 to 255 do
		for j:=0 to 15 do begin
			sawtoothTable[k]:=i;
      k:=k+1;
    end;
	k:=0;
	for i:=0 to 4095 do begin
		squareTable[k]:=255; //0; my estimation; especial for digi sound
    k:=k+1;
  end;
	for i:=0 to 4095 do begin
		squareTable[k]:= 0; //255;
    k:=k+1;
  end;
	if (type_=TYPE_8580) then begin
		waveform30:=@waveform30_8580;
		waveform50:=@waveform50_8580;
		waveform60:=@waveform60_8580;
		waveform70:=@waveform70_8580;
	end else begin
		waveform30:=@waveform30_6581;
		waveform50:=@waveform50_6581;
		waveform60:=@waveform60_6581;
		waveform70:=@waveform70_6581;  // really audible? */
	end;
	if (type_=TYPE_8580) then begin
		sidModeNormalTable[3]:=sidMode30;
		sidModeNormalTable[6]:=sidMode60;
		sidModeNormalTable[7]:=sidMode70;
		sidModeRingTable[7]:=sidMode74;
	end else begin
		sidModeNormalTable[3]:=sidMode30;
		sidModeNormalTable[6]:=sidMode60;
		sidModeNormalTable[7]:=sidMode00;  // really audible? */
		sidModeRingTable[7]:=sidMode00;    // */
	end;
	for ni:=0 to sizeof(noiseTableLSB)-1 do begin
		noiseTableLSB[ni]:=
			(((ni shr (13-4)) and $10) or
				((ni shr (11-3)) and $08) or
				((ni shr (7-2)) and $04) or
				((ni shr (4-1)) and $02) or
				((ni shr (2-0)) and $01));
	end;
	for ni:=0 to sizeof(noiseTableMSB)-1 do begin
		noiseTableMSB[ni]:=
			(((ni shl (7-(22-16))) and $80) or
				((ni shl (6-(20-16))) and $40) or
				((ni shl (5-(16-16))) and $20));
	end;
end;

constructor sid_chip.create(clock:dword;type_:byte);
var
  v,mod_voi:byte;
const
  rev:array[0..2] of byte=(2,1,0);
begin
  if addr(update_sound_proc)=nil then MessageDlg('ERROR: Chip de sonido inicializado sin CPU de sonido!', mtInformation,[mbOk], 0);
  self.tsample_num:=init_channel;
  self.clock:=clock;
  for v:=0 to (max_voices-1) do self.optr[v]:=sidOperator.create;
  for v:=0 to (max_voices-1) do begin
		mod_voi:=rev[v];
		self.optr[v].modulator:=@self.optr[mod_voi];
		self.optr[mod_voi].carrier:=@self.optr[v];
		self.optr[v].filtVoiceMask:=1 shl v;
	end;
	self.PCMsid:=trunc(FREQ_BASE_AUDIO*(16777216/clock));
	self.PCMsidNoise:=trunc((clock*256)/FREQ_BASE_AUDIO);
	self.filter.Enabled:=true;
	sidInitMixerEngine;
	self.filterTableInit;
	sidInitWaveformTables(type_);
	enveEmuInit(FREQ_BASE_AUDIO,true);
  self.zero16bit:=0;
	self.MixerInit(0);
	//self.reset;  Mejor no!! hasta que este creado
end;

destructor sid_chip.free;
var
  v:byte;
begin
  for v:=0 to (max_voices-1) do self.optr[v].free;
end;

procedure enveEmuResetOperator(pVoice:psidOperator);
begin
	// mute, end of R-phase */
	pVoice.ADSRctrl:=ENVE_MUTE;
	pVoice.fenveStep:=0;
  pVoice.fenveStepAdd:=0;
	pVoice.enveStep:=0;
	pVoice.enveSusVol:=0;
	pVoice.enveVol:=0;
	pVoice.enveShortAttackCount:=0;
end;

procedure sid_chip.reset;
var
  v:byte;
begin
  for v:=0 to (max_voices-1) do begin
		self.optr[v].clear;
		enveEmuResetOperator(@self.optr[v]);
	end;
	self.optr3_outputmask:=not(0);  // on */
	self.filter.Type_:=0;
  self.filter.CurType:=0;
	self.filter.Value:=0;
	self.filter.Dy:=0;
  self.filter.ResDy:=0;
	for v:=0 to (max_voices-1) do begin
		optr[v].set_;
		optr[v].set2;
	end;
end;

procedure sid_chip.MixerInit(threeVoiceAmplify:integer);
var
	si:integer;
	ui:word;
	ampDiv:dword;
begin
	ampDiv:=maxLogicalVoices;
	if (threeVoiceAmplify<>0) then ampDiv:=maxLogicalVoices-1;
	// Mixing formulas are optimized by sample input value.
	si:=(-128*maxLogicalVoices)*256;
	for ui:=0 to ((sizeof(mix16mono) div sizeof(word))-1) do begin
		self.mix16mono[ui]:=trunc((si/ampDiv)+self.zero16bit);
		si:=si+256;
	end;
end;

procedure sid_chip.filterTableInit;
var
  yMax,yMin,yAdd,yTmp,resDyMax,resDyMin,resDy:single;
  rk:word;
begin
	// Parameter calculation has not been moved to a separate function */
	// by purpose. */
	yMax:=1.0;
	yMin:=0.01;
	for rk:=0 to $7ff do begin
		self.filterTable[rk]:=(((exp(rk/$800*ln(400.0))/60.0)+0.05)*44100.0)/FREQ_BASE_AUDIO;
		if (self.filterTable[rk]<yMin) then self.filterTable[rk]:=yMin;
		if (self.filterTable[rk]>yMax) then self.filterTable[rk]:=yMax;
	end;
	//extern float bandPassParam[0x800]; */
	yMax:=0.22;
	yMin:=0.05;  // less for some R1/R4 chips */
	yAdd:=(yMax-yMin)/2048.0;
	yTmp:=yMin;
	// Some C++ compilers still have non-local scope! */
	for rk:=0 to $7ff do begin
		self.bandPassParam[rk]:=(yTmp*44100.0)/FREQ_BASE_AUDIO;
		yTmp:=yTmp+yAdd;
	end;
	//extern float filterResTable[16]; */
	resDyMax:=1.0;
	resDyMin:=2.0;
	resDy:=resDyMin;
	for rk:=0 to 15 do begin
		self.filterResTable[rk]:=resDy;
		resDy:=resDy-((resDyMin-resDyMax)/15);
	end;
	self.filterResTable[0]:=resDyMin;
	self.filterResTable[15]:=resDyMax;
end;

procedure sid_chip.syncEm;
var
  sync:array[0..2] of boolean;
  v:byte;
begin
	for v:=0 to (max_voices-1) do begin
		sync[v]:=self.optr[v].modulator.cycleLenCount<=0;
		self.optr[v].cycleLenCount:=self.optr[v].cycleLenCount-1;
	end;
	for v:=0 to (max_voices-1) do begin
		if (self.optr[v].sync and sync[v]) then begin
			self.optr[v].cycleLenCount:=0;
			self.optr[v].outProc:=@wave_calc_normal;
			self.optr[v].waveStep:=0;
      self.optr[v].waveStepPnt:=0;
		end;
	end;
end;

procedure sid_chip.update;
var
  res:word;
begin
  res:=self.mix16mono[abs(mix16monoMiddleIndex
								+self.optr[0].outProc(@optr[0])
								+self.optr[1].outProc(@optr[1])
								+(self.optr[2].outProc(@optr[2]) and self.optr3_outputmask)
{ hack for digi sounds
   does n't seam to come from a tone operator
   ghostbusters and goldrunner everything except volume zeroed }
							+(self.masterVolume shl 2)
//                        +(*sampleEmuRout)()
		)];
		self.syncEm();
tsample[self.tsample_num,sound_status.posicion_sonido]:=smallint(res);
if sound_status.stereo then tsample[self.tsample_num,sound_status.posicion_sonido+1]:=smallint(res);
end;

function sid_chip.read(dir:byte):byte;
var
  res:byte;
begin
	// SIDPLAY reads last written at a sid address value */
	dir:=dir and $1f;
	case dir of
	  $1d..$1f:res:=$ff;
	  $1b:res:=self.optr[2].output;
	  $1c:res:=self.optr[2].enveVol;
    else res:=self.reg[dir];
  end;
  read:=res;
end;

procedure sid_chip.write(dir,valor:byte);
var
  v:byte;
begin
	dir:=dir and $1f;
	case dir of
	$19..$1f:;
  $15..$18:begin
		        self.reg[dir]:=valor;
		        self.masterVolume:=self.reg[$18] and 15;
            self.masterVolumeAmplIndex:=masterVolume shl 8;
		        if (((self.reg[$18] and $80)<>0) and ((self.reg[$17] and self.optr[2].filtVoiceMask)=0)) then
			        self.optr3_outputmask:=0     // off */
		        else self.optr3_outputmask:=not(0);  // on */
		        self.filter.Type_:=self.reg[$18] and $70;
		        if (self.filter.Type_<>self.filter.CurType) then begin
			        self.filter.CurType:=self.filter.Type_;
			        for v:=0 to (max_voices-1) do begin
                self.optr[v].filtLow:=0;
                self.optr[v].filtRef:=0;
              end;
            end;
            if self.filter.Enabled then begin
        			filter.Value:=$7ff and ((self.reg[$15] and 7) or (self.reg[$16]) shl 3);
        			if (self.filter.Type_=$20) then self.filter.Dy:=self.bandPassParam[self.filter.Value]
        			  else self.filter.Dy:=self.filtertable[self.filter.Value];
        			self.filter.ResDy:=self.filterResTable[self.reg[$17] shr 4]-self.filter.Dy;
        			if (self.filter.ResDy<1.0) then self.filter.ResDy:=1.0;
		        end;
		        for v:=0 to (max_voices-1) do begin
        			self.optr[v].set_;
        			// relies on sidEmuSet also for other channels!
        			self.optr[v].set2;
		        end;
          end;
  else begin
		    self.reg[dir]:=valor;
		    if (dir<7) then self.optr[0].reg[dir]:=valor
		      else if (dir<14) then self.optr[1].reg[dir-7]:=valor
		        else if (dir<21) then self.optr[2].reg[dir-14]:=valor;
		    for v:=0 to (max_voices-1) do begin
			    self.optr[v].set_;
			    // relies on sidEmuSet also for other channels!
			    self.optr[v].set2;
		    end;
  end;
end;
end;

//SIDoperator
constructor sidOperator.create;
begin
end;

destructor sidOperator.free;
begin
end;

procedure sidOperator.wave_calc_cycle_len;
var
  diff:word;
begin
	self.cycleAddLenPnt:=self.cycleAddLenPnt+self.cycleLenPnt;
	self.cycleLenCount:=self.cycleLen;
	if (self.cycleAddLenPnt>65535) then self.cycleLenCount:=self.cycleLenCount+1;
	self.cycleAddLenPnt:=self.cycleAddLenPnt and $FFFF;
	// If we keep the value cycleLen between 1 <= x <= 65535, the following check is not required.
		diff:=self.cycleLenCount-self.cycleLen;
		if (self.wavePre[diff].len<>cycleLenCount) then begin
			self.wavePre[diff].len:=self.cycleLenCount;
			self.waveStepAdd:=trunc(4096/self.cycleLenCount);
      self.wavePre[diff].stp:=self.waveStepAdd;
      self.waveStepAddPnt:=trunc(((4096 mod self.cycleLenCount)*65536)/self.cycleLenCount);
			self.wavePre[diff].pnt:=self.waveStepAddPnt;
		end else begin
			self.waveStepAdd:=self.wavePre[diff].stp;
			self.waveStepAddPnt:=self.wavePre[diff].pnt;
		end;
end;

function waveCalcMute(pVoice:psidOperator):shortint;
begin
	pVoice.ADSRproc(pVoice);  // just process envelope */
	waveCalcMute:=pVoice.filtIO;//&pVoice->outputMask;
end;

procedure sidOperator.clear;
begin
	self.SIDfreq:=0;
	self.SIDctrl:=0;
	self.SIDAD:=0;
	self.SIDSR:=0;
	self.sync:=false;
	self.pulseIndex:=0;
  self.newPulseIndex:=0;
  self.SIDpulseWidth:=0;
	self.curSIDfreq:=0;
  self.curNoiseFreq:=0;
	self.output:=0;
  self.noiseOutput:=0;
	self.filtIO:=0;
	self.filtEnabled:=false;
	self.filtLow:=0;
  self.filtRef:=0;
	self.cycleLenCount:=0;
	self.cycleLen:=0;
  self.cycleLenPnt:=0;
	self.cycleAddLenPnt:=0;
	self.outProc:=@waveCalcMute;
	self.waveStepAdd:=0;
  self.waveStepAddPnt:=0;
	self.waveStep:=0;
  self.waveStepPnt:=0;
	self.wavePre[0].len:=0;
	self.wavePre[0].stp:=0;
  self.wavePre[0].pnt:=0;
	self.wavePre[1].len:=0;
	self.wavePre[1].stp:=0;
  self.wavePre[1].pnt:=0;
	self.waveStepOld:=0;
	self.noiseReg:=noiseSeed;
	self.noiseStepAdd:=0;
  self.noiseStep:=0;
	self.noiseIsLocked:=false;
end;

procedure sidOperator.set_;
var
  SRtemp,tmpSusVol,ADtemp,oldWave,newWave,enveTemp:byte;
begin
	self.SIDfreq:=self.reg[0] or (self.reg[1] shl 8);
	self.SIDpulseWidth:=(self.reg[2] or (self.reg[3] shl 8)) and $0FFF;
	self.newPulseIndex:=4096-self.SIDpulseWidth;
	if (((self.waveStep+self.pulseIndex)>=$1000) and ((self.waveStep+self.newPulseIndex)>=$1000)) then
		self.pulseIndex:=self.newPulseIndex
	else if (((self.waveStep+self.pulseIndex)<$1000) and ((self.waveStep+self.newPulseIndex)<$1000)) then
		self.pulseIndex:=self.newPulseIndex;
  oldWave:=self.SIDctrl;
  newWave:=self.reg[4] or (self.reg[5] shl 8); // FIXME: what's actually supposed to happen here?
  enveTemp:=self.ADSRctrl;
	self.SIDctrl:=newWave;

	if (newWave and 1)=0 then begin
		if (oldWave and 1)<>0 then enveTemp:=ENVE_STARTRELEASE
	end else if ((oldWave and 1)=0) then //gateOffCtrl
		enveTemp:=ENVE_STARTATTACK;

	if ((oldWave xor newWave) and $F0)<>0 then self.cycleLenCount:=0;

  ADtemp:=self.reg[5];
  SRtemp:=self.reg[6];
	if (self.SIDAD<>ADtemp) then enveTemp:=enveTemp or ENVE_ALTER
	  else if (self.SIDSR<>SRtemp) then enveTemp:=enveTemp or ENVE_ALTER;

	self.SIDAD:=ADtemp;
	self.SIDSR:=SRtemp;
  tmpSusVol:=masterVolumeLevels[SRtemp shr 4];
	if (self.ADSRctrl<>ENVE_SUSTAIN) then self.enveSusVol:=tmpSusVol
	  else if (self.enveSusVol>self.enveVol) then self.enveSusVol:=0
	    else self.enveSusVol:=tmpSusVol;

	self.ADSRproc:=enveModeTable[(enveTemp shr 1) and $1f];  // shifting out the KEY-bit
	self.ADSRctrl:=enveTemp and (255-ENVE_ALTER-1);
	self.filtEnabled:=sid_0.filter.Enabled and ((sid_0.reg[$17] and self.filtVoiceMask)<>0);
end;

function waveCalcRangeCheck(pVoice:psidOperator):shortint;
begin
	pVoice.waveStepOld:=pVoice.waveStep;
	pVoice.waveProc(pVoice);
	if (pVoice.waveStep<pVoice.waveStepOld) then begin
		// Next step switch back to normal calculation. */
		pVoice.cycleLenCount:=0;
		pVoice.outProc:=@wave_calc_normal;
    pVoice.waveStep:=4095;
	end;
	pVoice.filtIO:=ampMod1x8[pVoice.ADSRproc(pVoice) or pVoice.output];
	waveCalcFilter(pVoice);
	waveCalcRangeCheck:=pVoice.filtIO;//&pVoice->outputMask;
end;

procedure sidOperator.set2;
begin
	self.outProc:=@wave_calc_normal;
	self.sync:=false;
	if ((self.SIDfreq<16) or ((self.SIDctrl and 8)<>0)) then begin
		self.outProc:=@waveCalcMute;
		if (self.SIDfreq=0) then begin
			self.cycleLen:=0;
      self.cycleLenPnt:=0;
			self.cycleAddLenPnt:=0;
			self.waveStep:=0;
			self.waveStepPnt:=0;
			self.curSIDfreq:=0;
      self.curNoiseFreq:=0;
			self.noiseStepAdd:=0;
			self.cycleLenCount:=0;
		end;
		if (self.SIDctrl and 8)<>0 then begin
			if self.noiseIsLocked then begin
				self.noiseIsLocked:=false;
				self.noiseReg:=noiseSeed;
			end;
		end;
	end else begin
		if (self.curSIDfreq<>self.SIDfreq) then begin
			self.curSIDfreq:=self.SIDfreq;
			// We keep the value cycleLen between 1 <= x <= 65535.
			// This makes a range-check in wave_calc_cycle_len() unrequired.
			self.cycleLen:=sid_0.PCMsid div self.SIDfreq;
			self.cycleLenPnt:=((sid_0.PCMsid mod self.SIDfreq)*65536) div self.SIDfreq;
			if (self.cycleLenCount>0) then begin
				self.wave_calc_cycle_len;
				self.outProc:=@waveCalcRangeCheck;
			end;
		end;
		if (((self.SIDctrl and $80)<>0) and (self.curNoiseFreq<>self.SIDfreq)) then begin
			self.curNoiseFreq:=self.SIDfreq;
			self.noiseStepAdd:=(sid_0.PCMsidNoise*self.SIDfreq) shr 8;
			if (self.noiseStepAdd>=(1 shl 21)) then sidModeNormalTable[8]:=sidMode80hp
			  else sidModeNormalTable[8]:=sidMode80;
		end;
		if (self.SIDctrl and 2)<>0 then begin
			if ((self.modulator.SIDfreq=0) or ((self.modulator.SIDctrl and 8)<>0)) then begin
			end else if (((self.carrier.SIDctrl and 2)<>0) and (self.modulator.SIDfreq>=(self.SIDfreq shl 1))) then begin
			          end else begin
				          self.sync:=true;
                end;
		end;
	  if (((self.SIDctrl and $14)=$14) and (self.modulator.SIDfreq<>0)) then self.waveProc:=sidModeRingTable[self.SIDctrl shr 4]
	    else self.waveProc:=sidModeNormalTable[self.SIDctrl shr 4];
  end;
end;

function enveEmuStartAttack(pVoice:psidOperator):word;
begin
	pVoice.ADSRctrl:=ENVE_ATTACK;
	pVoice.fenveStep:=pVoice.enveVol;
	enveEmuStartAttack:=enveEmuAlterAttack(pVoice);
end;

function enveEmuStartRelease(pVoice:psidOperator):word;
begin
	pVoice.ADSRctrl:=ENVE_RELEASE;
	pVoice.fenveStep:=releasePos[pVoice.enveVol];
	enveEmuStartRelease:=enveEmuAlterRelease(pVoice);
end;

function enveEmuStartDecay(pVoice:psidOperator):word;
begin
	pVoice.ADSRctrl:=ENVE_DECAY;
	pVoice.fenveStep:=0;
	enveEmuStartDecay:=enveEmuAlterDecay(pVoice);
end;

procedure enveEmuEnveAdvance(pVoice:psidOperator);
begin
	pVoice.fenveStep:=pVoice.fenveStep+pVoice.fenveStepAdd;
end;

function enveEmuAttack(pVoice:psidOperator):word;
begin
	pVoice.enveStep:=trunc(pVoice.fenveStep) and $ffff;
	if (pVoice.enveStep>=attackTabLen) then begin
		enveEmuAttack:=enveEmuStartDecay(pVoice);
	end else begin
		pVoice.enveVol:=pVoice.enveStep;
		enveEmuEnveAdvance(pVoice);
		enveEmuAttack:=masterAmplModTable[(sid_0.masterVolumeAmplIndex+pVoice.enveVol) and $fff];
	end;
end;

function enveEmuDecay(pVoice:psidOperator):word;
begin
	pVoice.enveStep:=trunc(pVoice.fenveStep) and $ffff;
	if (pVoice.enveStep>=releaseTabLen) then begin
		pVoice.enveVol:=pVoice.enveSusVol;
		enveEmuDecay:=enveEmuAlterSustain(pVoice);  // start sustain */
	end else begin
		pVoice.enveVol:=releaseTab[pVoice.enveStep];
		// Will be controlled from sidEmuSet2(). */
		if (pVoice.enveVol<=pVoice.enveSusVol) then begin
			pVoice.enveVol:=pVoice.enveSusVol;
			enveEmuDecay:=enveEmuAlterSustain(pVoice);  // start sustain */
		end else begin
			enveEmuEnveAdvance(pVoice);
			enveEmuDecay:=masterAmplModTable[(sid_0.masterVolumeAmplIndex+pVoice.enveVol) and $fff];
		end;
	end;
end;

function enveEmuSustain(pVoice:psidOperator):word;
begin
  enveEmuSustain:=masterAmplModTable[(sid_0.masterVolumeAmplIndex+pVoice.enveVol) and $fff];
end;

function enveEmuRelease(pVoice:psidOperator):word;
begin
	pVoice.enveStep:=trunc(pVoice.fenveStep) and $ffff;
	if (pVoice.enveStep>=releaseTabLen) then begin
		pVoice.enveVol:=releaseTab[releaseTabLen-1];
		enveEmuRelease:=masterAmplModTable[(sid_0.masterVolumeAmplIndex+pVoice.enveVol) and $fff];
	end else begin
		pVoice.enveVol:=releaseTab[pVoice.enveStep];
		enveEmuEnveAdvance(pVoice);
		enveEmuRelease:=masterAmplModTable[(sid_0.masterVolumeAmplIndex+pVoice.enveVol) and $fff];
	end;
end;

function enveEmuSustainDecay(pVoice:psidOperator):word;
begin
	pVoice.enveStep:=trunc(pVoice.fenveStep) and $ffff;
	if (pVoice.enveStep>=releaseTabLen) then begin
		pVoice.enveVol:=releaseTab[releaseTabLen-1];
		enveEmuSustainDecay:=enveEmuAlterSustain(pVoice);
	end else begin
		pVoice.enveVol:=releaseTab[pVoice.enveStep];
		// Will be controlled from sidEmuSet2(). */
		if (pVoice.enveVol<=pVoice.enveSusVol) then begin
			pVoice.enveVol:=pVoice.enveSusVol;
			enveEmuSustainDecay:=enveEmuAlterSustain(pVoice);
		end else begin
			enveEmuEnveAdvance(pVoice);
			enveEmuSustainDecay:=masterAmplModTable[(sid_0.masterVolumeAmplIndex+pVoice.enveVol) and $fff];
		end;
	end;
end;

function enveEmuMute(pVoice:psidOperator):word;
begin
  enveEmuMute:=0;
end;

function enveEmuShortAttack(pVoice:psidOperator):word;
begin
	pVoice.enveStep:=trunc(pVoice.fenveStep) and $ffff;
	if ((pVoice.enveStep>=attackTabLen) or (pVoice.enveShortAttackCount=0)) then begin
		enveEmuShortAttack:=enveEmuStartDecay(pVoice);
    exit;
  end;
	pVoice.enveVol:=pVoice.enveStep;
	pVoice.enveShortAttackCount:=pVoice.enveShortAttackCount-1;
	enveEmuEnveAdvance(pVoice);
	enveEmuShortAttack:=masterAmplModTable[(sid_0.masterVolumeAmplIndex+pVoice.enveVol) and $fff];
end;

function enveEmuAlterShortAttack(pVoice:psidOperator):word;
var
  attack:byte;
begin
	attack:=pVoice.SIDAD shr 4;
	pVoice.fenveStepAdd:=attackRates[attack];
	pVoice.ADSRproc:=@enveEmuShortAttack;
	enveEmuAlterShortAttack:=enveEmuShortAttack(pVoice);
end;

function enveEmuStartShortAttack(pVoice:psidOperator):word;
begin
	pVoice.ADSRctrl:=ENVE_SHORTATTACK;
	pVoice.fenveStep:=pVoice.enveVol;
	pVoice.enveShortAttackCount:=65535;  // unused */
	enveEmuStartShortAttack:=enveEmuAlterShortAttack(pVoice);
end;

function enveEmuAlterAttack(pVoice:psidOperator):word;
var
  attack:byte;
begin
	attack:=pVoice.SIDAD shr 4;
	pVoice.fenveStepAdd:=attackRates[attack];
	pVoice.ADSRproc:=@enveEmuAttack;
	enveEmuAlterAttack:=enveEmuAttack(pVoice);
end;

function enveEmuAlterDecay(pVoice:psidOperator):word;
var
  decay:byte;
begin
	decay:=pVoice.SIDAD and $F;
	pVoice.fenveStepAdd:=decayReleaseRates[decay];
	pVoice.ADSRproc:=@enveEmuDecay;
	enveEmuAlterDecay:=enveEmuDecay(pVoice);
end;

function enveEmuAlterSustain(pVoice:psidOperator):word;
begin
	if (pVoice.enveVol>pVoice.enveSusVol) then begin
		pVoice.ADSRctrl:=ENVE_SUSTAINDECAY;
		pVoice.ADSRproc:=@enveEmuSustainDecay;
		enveEmuAlterSustain:=enveEmuAlterSustainDecay(pVoice);
	end else begin
		pVoice.ADSRctrl:=ENVE_SUSTAIN;
		pVoice.ADSRproc:=@enveEmuSustain;
		enveEmuAlterSustain:=enveEmuSustain(pVoice);
	end;
end;

function enveEmuAlterRelease(pVoice:psidOperator):word;
var
  release:byte;
begin
	release:=pVoice.SIDSR and $F;
	pVoice.fenveStepAdd:=decayReleaseRates[release];
	pVoice.ADSRproc:=@enveEmuRelease;
	enveEmuAlterRelease:=enveEmuRelease(pVoice);
end;

function enveEmuAlterSustainDecay(pVoice:psidOperator):word;
var
  decay:byte;
begin
	decay:=pVoice.SIDAD and $F ;
	pVoice.fenveStepAdd:=decayReleaseRates[decay];
	pVoice.ADSRproc:=@enveEmuSustainDecay;
	enveEmuAlterSustainDecay:=enveEmuSustainDecay(pVoice);
end;

procedure waveAdvance(pVoice:psidOperator);
begin
	pVoice.waveStepPnt:=pVoice.waveStepPnt+pVoice.waveStepAddPnt;
	pVoice.waveStep:=pVoice.waveStep+pVoice.waveStepAdd;
	if (pVoice.waveStepPnt>65535) then pVoice.waveStep:=pVoice.waveStep+1;
	pVoice.waveStepPnt:=pVoice.waveStepPnt and $FFFF;
	pVoice.waveStep:=pVoice.waveStep and $fff;
end;

procedure noiseAdvance(pVoice:psidOperator);
begin
	pVoice.noiseStep:=pVoice.noiseStep+pVoice.noiseStepAdd;
	if (pVoice.noiseStep>=(1 shl 20)) then begin
		pVoice.noiseStep:=pVoice.noiseStep-(1 shl 20);
		pVoice.noiseReg:=(pVoice.noiseReg shl 1) or
			(((pVoice.noiseReg shr 22) xor (pVoice.noiseReg shr 17)) and 1);
		pVoice.noiseOutput:=noiseTableLSB[pVoice.noiseReg and $ffff]
								or noiseTableMSB[(pVoice.noiseReg shr 16) and $ff];
	end;
end;

procedure sidMode00(pVoice:psidOperator);
begin
	pVoice.output:=pVoice.filtIO-$80;
	waveAdvance(pVoice);
end;

procedure sidMode10(pVoice:psidOperator);
begin
  pVoice.output:=triangleTable[pVoice.waveStep];
	waveAdvance(pVoice);
end;

procedure sidMode20(pVoice:psidOperator);
begin
  pVoice.output:=sawtoothTable[pVoice.waveStep];
	waveAdvance(pVoice);
end;

procedure sidMode30(pVoice:psidOperator);
begin
  pVoice.output:=waveform30[pVoice.waveStep];
	waveAdvance(pVoice);
end;

procedure sidMode40(pVoice:psidOperator);
begin
  pVoice.output:=squareTable[(pVoice.waveStep+pVoice.pulseIndex) and $1fff];
	waveAdvance(pVoice);
end;

procedure sidMode50(pVoice:psidOperator);
var
  tword:word;
begin
  tword:=pVoice.waveStep+pVoice.SIDpulseWidth;
  if tword>4095 then pVoice.output:=0
    else pVoice.output:=waveform50[tword];
	waveAdvance(pVoice);
end;

procedure sidMode60(pVoice:psidOperator);
var
  tword:word;
begin
  tword:=pVoice.waveStep+pVoice.SIDpulseWidth;
  if tword>4095 then pVoice.output:=0
    else pVoice.output:=waveform60[tword];
	waveAdvance(pVoice);
end;

procedure sidMode70(pVoice:psidOperator);
var
  tword:word;
begin
  tword:=pVoice.waveStep+pVoice.SIDpulseWidth;
  if tword>4095 then pVoice.output:=0
    else pVoice.output:=waveform70[tword];
	waveAdvance(pVoice);
end;

procedure sidMode80(pVoice:psidOperator);
begin
  pVoice.output:=pVoice.noiseOutput;
	waveAdvance(pVoice);
	noiseAdvance(pVoice);
end;

procedure sidModeLock(pVoice:psidOperator);
begin
  pVoice.noiseIsLocked:=true;
	pVoice.output:=pVoice.filtIO-$80;
	waveAdvance(pVoice);
end;

procedure sidMode14(pVoice:psidOperator);
begin
	if (pVoice.modulator.waveStep<2048) then pVoice.output:=triangleTable[pVoice.waveStep and $fff]
	else pVoice.output:=$FF xor triangleTable[pVoice.waveStep and $fff];
	waveAdvance(pVoice);
end;

procedure sidMode34(pVoice:psidOperator);
begin
	if (pVoice.modulator.waveStep<2048) then pVoice.output:=waveform30[pVoice.waveStep and $fff]
	  else pVoice.output:=$FF xor waveform30[pVoice.waveStep and $fff];
	waveAdvance(pVoice);
end;

procedure sidMode54(pVoice:psidOperator);
var
  tword:word;
begin
  tword:=pVoice.waveStep+pVoice.SIDpulseWidth;
  if tword>4095 then tword:=0
    else tword:=waveform50[tword];
	if (pVoice.modulator.waveStep<2048) then pVoice.output:=tword
	  else pVoice.output:=$FF xor tword;
	waveAdvance(pVoice);
end;

procedure sidMode74(pVoice:psidOperator);
var
  tword:word;
begin
  tword:=pVoice.waveStep+pVoice.SIDpulseWidth;
  if tword>4095 then tword:=0
    else tword:=waveform70[tword];
	if (pVoice.modulator.waveStep<2048) then pVoice.output:=tword
  	else pVoice.output:=$FF xor tword;
	waveAdvance(pVoice);
end;

procedure noiseAdvanceHp(pVoice:psidOperator);
var
  tmp:dword;
begin
	tmp:=pVoice.noiseStepAdd;
	while (tmp>=(1 shl 20)) do begin
		tmp:=tmp-(1 shl 20);
		pVoice.noiseReg:=(pVoice.noiseReg shl 1) or
			(((pVoice.noiseReg shr 22) xor (pVoice.noiseReg shr 17)) and 1);
	end;
	pVoice.noiseStep:=pVoice.noiseStep+tmp;
	if (pVoice.noiseStep>=(1 shl 20)) then begin
		pVoice.noiseStep:=pVoice.noiseStep-(1 shl 20);
		pVoice.noiseReg:=(pVoice.noiseReg shl 1) or
			(((pVoice.noiseReg shr 22) xor (pVoice.noiseReg shr 17)) and 1);
	end;
	pVoice.noiseOutput:=noiseTableLSB[pVoice.noiseReg and $ffff]
							or noiseTableMSB[(pVoice.noiseReg shr 16) and $ff];
end;

procedure sidMode80hp(pVoice:psidOperator);
begin
  pVoice.output:=pVoice.noiseOutput;
	waveAdvance(pVoice);
	noiseAdvanceHp(pVoice);
end;

end.
