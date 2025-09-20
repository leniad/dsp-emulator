unit ay_8910;

interface
uses {$IFDEF WINDOWS}windows,{$else}main_engine,{$ENDIF}sound_engine,cpu_misc;

type
  ay8910_chip=class(snd_chip_class)
        constructor create(clock:integer;type_:byte;amp:single=1;internal:boolean=false);
        destructor free;
      public
        procedure Write(v:byte);
        procedure Control(v:byte);
        function Read:byte;
        procedure reset;
        procedure update;
        function update_internal:pinteger;
        function get_control:byte;
        function get_reg(reg:byte):byte;
        procedure set_reg(reg,valor:byte);
        procedure change_io_calls(porta_read,portb_read:cpu_inport_call;porta_write,portb_write:cpu_outport_call);
        function save_snapshot(data:pbyte):word;
        procedure load_snapshot(data:pbyte);
        procedure change_clock(clock:dword);
        procedure change_gain(gain0,gain1,gain2:single);
      private
        Regs:array[0..15] of byte;
        PeriodA,PeriodB,PeriodC,PeriodN,PeriodE:integer;
        CountA,CountB,CountC,CountN,CountE:integer;
        VolA,VolB,VolC,VolE:integer;
        EnvelopeA,EnvelopeB,EnvelopeC:integer;
        OutputA,OutputB,OutputC,OutputN:integer;
        latch,type_:byte;
        CountEnv:shortint;
        Hold,Alternate,Attack,Holding,RNG,UpdateStep:integer;
        lastenable:smallint;
        porta_read,portb_read:cpu_inport_call;
        porta_write,portb_write:cpu_outport_call;
        gain0,gain1,gain2:single;
        procedure AYWriteReg(r,v:byte);
        function AYReadReg(r:byte):byte;
  end;

var
  ay8910_0,ay8910_1,ay8910_2,ay8910_3,ay8910_4:ay8910_chip;

const
  AY8910=0;
  AY8912=1;

implementation

const
  AY_AFINE = 0;
  AY_ACOARSE = 1;
  AY_BFINE = 2;
  AY_BCOARSE = 3;
  AY_CFINE = 4;
  AY_CCOARSE = 5;
  AY_NOISEPER = 6;
  AY_ENABLE = 7;
  AY_AVOL = 8;
  AY_BVOL = 9;
  AY_CVOL = 10;
  AY_EFINE = 11;
  AY_ECOARSE = 12;
  AY_ESHAPE = 13;
  AY_PORTA = 14;
  AY_PORTB = 15;
  STEP=$1000;
  MAX_OUTPUT=$7FFF;

var
  salida_ay:array[0..3] of integer;
  vol_table:array[0..31] of single;

procedure init_table;
var
  i:integer;
  l_out:single;
begin
  l_out:=MAX_OUTPUT/4;
  for i:=31 downto 1 do begin
    Vol_Table[i]:=trunc(l_out+0.5);	// roun to nearest */
    l_out:=l_out/1.188502227;	// = 10 ^ (1.5/20) = 1.5dB */
  end;
  Vol_Table[0]:=0;
end;

procedure ay8910_chip.change_gain(gain0,gain1,gain2:single);
begin
  self.gain0:=gain0;
  self.gain1:=gain1;
  self.gain2:=gain2;
end;

procedure ay8910_chip.change_clock(clock:dword);
begin
  self.clock:=clock;
  self.UpdateStep:=trunc((STEP*FREQ_BASE_AUDIO*8)/self.clock);
end;

constructor ay8910_chip.create(clock:integer;type_:byte;amp:single=1;internal:boolean=false);
begin
  init_table;
  self.clock:=clock;
  self.UpdateStep:=trunc((STEP*FREQ_BASE_AUDIO*8)/self.clock);
  self.porta_read:=nil;
  self.portb_read:=nil;
  self.porta_write:=nil;
  self.portb_write:=nil;
  self.PeriodA:=self.UpdateStep;
  self.PeriodB:=self.UpdateStep;
  self.PeriodC:=self.UpdateStep;
  self.PeriodE:=self.UpdateStep;
  self.PeriodN:=self.UpdateStep;
  if not(internal) then self.tsample_num:=init_channel;
  self.amp:=amp;
  self.reset;
  self.type_:=type_;
  self.gain0:=1;
  self.gain1:=1;
  self.gain2:=1;
end;

procedure ay8910_chip.reset;
  var
    i:byte;
begin
    self.latch:=0;
    self.OutputA:= 0;
    self.OutputB:= 0;
    self.OutputC:= 0;
    self.OutputN:= $FF;
    self.RNG:=1;
    self.lastenable:=-1;
  For i := 0 To 13 do self.AYWriteReg(i,0);
end;

destructor ay8910_chip.free;
begin
end;

function ay8910_chip.save_snapshot(data:pbyte):word;
var
  temp:pbyte;
  size:word;
begin
  temp:=data;
  copymemory(temp,@self.regs[0],16);inc(temp,16);size:=16;
  copymemory(temp,@self.PeriodA,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.PeriodB,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.PeriodC,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.PeriodN,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.PeriodE,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.CountA,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.CountB,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.CountC,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.CountN,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.CountE,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.VolA,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.VolB,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.VolC,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.VolE,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.EnvelopeA,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.EnvelopeB,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.EnvelopeC,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.OutputA,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.OutputB,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.OutputC,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.OutputN,4);inc(temp,4);size:=size+4;
  temp^:=self.latch;inc(temp);size:=size+1;
  temp^:=self.type_;inc(temp);size:=size+1;
  copymemory(temp,@self.CountEnv,sizeof(shortint));inc(temp,sizeof(shortint));size:=size+sizeof(shortint);
  copymemory(temp,@self.Hold,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.Alternate,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.Attack,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.Holding,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.RNG,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.UpdateStep,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.lastenable,sizeof(smallint));size:=size+sizeof(smallint);
  save_snapshot:=size;
end;

procedure ay8910_chip.load_snapshot(data:pbyte);
var
  temp:pbyte;
begin
  temp:=data;
  copymemory(@self.regs[0],temp,16);inc(temp,16);
  copymemory(@self.PeriodA,temp,4);inc(temp,4);
  copymemory(@self.PeriodB,temp,4);inc(temp,4);
  copymemory(@self.PeriodC,temp,4);inc(temp,4);
  copymemory(@self.PeriodN,temp,4);inc(temp,4);
  copymemory(@self.PeriodE,temp,4);inc(temp,4);
  copymemory(@self.CountA,temp,4);inc(temp,4);
  copymemory(@self.CountB,temp,4);inc(temp,4);
  copymemory(@self.CountC,temp,4);inc(temp,4);
  copymemory(@self.CountN,temp,4);inc(temp,4);
  copymemory(@self.CountE,temp,4);inc(temp,4);
  copymemory(@self.VolA,temp,4);inc(temp,4);
  copymemory(@self.VolB,temp,4);inc(temp,4);
  copymemory(@self.VolC,temp,4);inc(temp,4);
  copymemory(@self.VolE,temp,4);inc(temp,4);
  copymemory(@self.EnvelopeA,temp,4);inc(temp,4);
  copymemory(@self.EnvelopeB,temp,4);inc(temp,4);
  copymemory(@self.EnvelopeC,temp,4);inc(temp,4);
  copymemory(@self.OutputA,temp,4);inc(temp,4);
  copymemory(@self.OutputB,temp,4);inc(temp,4);
  copymemory(@self.OutputC,temp,4);inc(temp,4);
  copymemory(@self.OutputN,temp,4);inc(temp,4);
  self.latch:=temp^;inc(temp);
  self.type_:=temp^;inc(temp);
  copymemory(@self.CountEnv,temp,sizeof(shortint));inc(temp,sizeof(shortint));
  copymemory(@self.Hold,temp,4);inc(temp,4);
  copymemory(@self.Alternate,temp,4);inc(temp,4);
  copymemory(@self.Attack,temp,4);inc(temp,4);
  copymemory(@self.Holding,temp,4);inc(temp,4);
  copymemory(@self.RNG,temp,4);inc(temp,4);
  copymemory(@self.UpdateStep,temp,4);inc(temp,4);
  copymemory(@self.lastenable,temp,sizeof(smallint));
end;

procedure ay8910_chip.change_io_calls(porta_read,portb_read:cpu_inport_call;porta_write,portb_write:cpu_outport_call);
begin
  self.porta_read:=porta_read;
  if self.type_=AY8912 then self.portb_read:=porta_read
    else self.portb_read:=portb_read;
  self.porta_write:=porta_write;
  if self.type_=AY8912 then self.portb_write:=porta_write
    else self.portb_write:=portb_write;
end;

procedure ay8910_chip.AYWriteReg(r,v:byte);
var
    old:integer;
begin
  self.Regs[r]:=v;
  case r of
    AY_AFINE, AY_ACOARSE:begin
        self.Regs[AY_ACOARSE] := self.Regs[AY_ACOARSE] and $F;
        old := self.PeriodA;
        self.PeriodA:=cardinal((self.Regs[AY_AFINE] + (256 * self.Regs[AY_ACOARSE]))*self.UpdateStep);
        if (self.PeriodA = 0) then self.PeriodA:=cardinal(self.UpdateStep);
        self.CountA := self.CountA + (self.PeriodA - old);
        if (self.CountA <= 0) then self.CountA := 1;
      end;
    AY_BFINE, AY_BCOARSE:begin
        self.Regs[AY_BCOARSE] := self.Regs[AY_BCOARSE] and $F;
        old := self.PeriodB;
        self.PeriodB := trunc((self.Regs[AY_BFINE] + (256 * self.Regs[AY_BCOARSE]))* self.UpdateStep);
        if (self.PeriodB = 0) then self.PeriodB := trunc(self.UpdateStep);
        self.CountB := self.CountB + self.PeriodB - old;
        if (self.CountB <= 0) then self.CountB := 1
      end;
    AY_CFINE, AY_CCOARSE:begin
        self.Regs[AY_CCOARSE] := self.Regs[AY_CCOARSE] and $F;
        old := self.PeriodC;
        self.PeriodC := trunc((self.Regs[AY_CFINE] + (256 * self.Regs[AY_CCOARSE]))*self.UpdateStep);
        if (self.PeriodC = 0) then self.PeriodC := trunc(self.UpdateStep);
        self.CountC := self.CountC + (self.PeriodC - old);
        if (self.CountC <= 0) then self.CountC := 1;
      end;
    AY_NOISEPER:begin
        self.Regs[AY_NOISEPER] := self.Regs[AY_NOISEPER] and $1F;
        old := self.PeriodN;
        self.PeriodN := trunc(self.Regs[AY_NOISEPER] * self.UpdateStep);
        if (self.PeriodN = 0) then self.PeriodN := trunc(self.UpdateStep);
        self.CountN := self.CountN + (self.PeriodN - old);
        if (self.CountN <= 0) then self.CountN := 1;
      end;
    AY_ENABLE:begin
        if ((self.lastEnable = -1) or ((self.lastEnable and $40)<>(self.Regs[AY_ENABLE] and $40))) then begin
			      // write out 0xff if port set to input */
			      if (@self.PortA_write<>nil) then begin
              if (self.Regs[AY_ENABLE] and $40)<>0 then self.porta_write(self.Regs[AY_PORTA])
                else self.porta_write($ff);
            end;
        end;
		    if ((self.lastEnable=-1) or ((self.lastEnable and $80)<>(self.Regs[AY_ENABLE] and $80))) then begin
			    // write out 0xff if port set to input */
			    if (@self.portb_write<>nil) then begin
            if (self.Regs[AY_ENABLE] and $80)<>0 then self.portb_write(self.Regs[AY_PORTB])
                else self.portb_write($ff);
          end;
        end;
		    self.lastEnable:= self.Regs[AY_ENABLE];
    end;
    AY_AVOL:begin
        self.Regs[AY_AVOL] := self.Regs[AY_AVOL] and $1F;
        self.EnvelopeA := self.Regs[AY_AVOL] and $10;
        if self.Regs[AY_AVOL]<>0 then old:=self.Regs[AY_AVOL]*2+1 else old:=0;
        if self.EnvelopeA <> 0 then self.VolA := self.VolE else self.VolA:=trunc(Vol_Table[old]);
      end;
    AY_BVOL:begin
        self.Regs[AY_BVOL] := self.Regs[AY_BVOL] and $1F;
        self.EnvelopeB := self.Regs[AY_BVOL] and $10;
        if self.Regs[AY_BVOL]<>0 then old:=self.Regs[AY_BVOL]*2+1 else old:=0;
        if self.EnvelopeB <> 0 then self.VolB := self.VolE else self.VolB :=trunc(Vol_Table[old]);
      end;
    AY_CVOL:begin
        self.Regs[AY_CVOL] := self.Regs[AY_CVOL] and $1F;
        self.EnvelopeC := self.Regs[AY_CVOL] and $10;
        if self.Regs[AY_CVOL]<>0 then old:=self.Regs[AY_CVOL]*2+1 else old:=0;
        if self.EnvelopeC <> 0 then self.VolC := self.VolE else self.VolC :=trunc(Vol_Table[old]);
      end;
    AY_EFINE, AY_ECOARSE:begin
        old := self.PeriodE;
        self.PeriodE := trunc((self.Regs[AY_EFINE] + (256 * self.Regs[AY_ECOARSE]))* self.UpdateStep);
        if (self.PeriodE = 0) then self.PeriodE := trunc(self.UpdateStep/2);
        self.CountE := self.CountE + (self.PeriodE - old);
        if (self.CountE <= 0) then self.CountE := 1
      end;
    AY_ESHAPE:begin
          self.Regs[AY_ESHAPE] := self.Regs[AY_ESHAPE] and $F;
          if ((self.Regs[AY_ESHAPE] and $4)<>0) then self.Attack := $1f
              else self.Attack := $0;
          if ((self.Regs[AY_ESHAPE] and $8) = 0) then begin
			      self.Hold:= 1;
			      self.Alternate:= self.Attack;
		      end else begin
            self.Hold:= self.Regs[AY_ESHAPE] and $1;
			      self.Alternate:= self.Regs[AY_ESHAPE] and $2;
          end;
          self.CountE := self.PeriodE;
          self.CountEnv := $1F;
          self.Holding := 0;
          self.VolE :=trunc(Vol_Table[self.CountEnv xor self.Attack]);
          if (self.EnvelopeA <> 0) then self.VolA := self.VolE;
          if (self.EnvelopeB <> 0) then self.VolB := self.VolE;
          if (self.EnvelopeC <> 0) then self.VolC := self.VolE;
      end;
      AY_PORTA:if @self.porta_write<>nil then self.porta_write(v)
                  else self.Regs[AY_PORTA]:=v;
      AY_PORTB:if @self.portb_write<>nil then self.portb_write(v)
                        else self.Regs[AY_PORTB]:=v;
  end; //case
end;

function ay8910_chip.AYReadReg(r:byte):byte;
begin
  case r of
      AY_PORTA:if (@self.porta_read<>nil) then self.Regs[AY_PORTA]:=self.porta_read;
      AY_PORTB:if (@self.portb_read<>nil) then self.Regs[AY_PORTB]:=self.portb_read;
  end;
  AYReadReg:=self.Regs[r];
end;

function ay8910_chip.Read:byte;
begin
  read:=self.AYReadReg(self.latch);
end;

function ay8910_chip.get_reg(reg:byte):byte;
begin
  get_reg:=self.Regs[reg];
end;

procedure ay8910_chip.set_reg(reg,valor:byte);
begin
  self.Regs[reg]:=valor;
end;

procedure ay8910_chip.write(v:byte);
begin
  self.AYWriteReg(self.latch,v);
end;

procedure ay8910_chip.control(v:byte);
begin
  self.latch:=v and $f;
end;

function ay8910_chip.get_control:byte;
begin
  get_control:=self.latch;
end;

function ay8910_chip.update_internal:pinteger;
var
  AY_OutNoise: integer;
  VolA,VolB,VolC: integer;
  lOut1,lOut2,lOut3: integer;
  AY_Left: integer;
  AY_NextEvent: integer;
  temp2:integer;
begin
  if (self.Regs[AY_ENABLE] and $1)<>0 then begin
    if self.CountA <=STEP then self.CountA :=self.CountA +STEP;
    self.OutputA := 1;
  end else if (self.Regs[AY_AVOL] = 0) then begin
      if self.CountA <=STEP then self.CountA :=self.CountA +STEP;
  end;
  if (self.Regs[AY_ENABLE] and $2)<>0 then begin
      if self.CountB <=STEP then self.CountB :=self.CountB + STEP;
      self.OutputB := 1;
  end else if self.Regs[AY_BVOL] = 0 then begin
      if self.CountB <=STEP then self.CountB :=self.CountB + STEP;
  end;
  if (self.Regs[AY_ENABLE] and $4)<>0 then begin
      if self.CountC <=STEP then self.CountC :=self.CountC + STEP;
      self.OutputC := 1;
  end else if (self.Regs[AY_CVOL] = 0) then begin
      if self.CountC <=STEP then self.CountC :=self.CountC +STEP;
  end;
    if ((self.Regs[AY_ENABLE] and $38) = $38) then
      if (self.CountN <=STEP) then self.CountN:=self.CountN +STEP;
    AY_OutNoise := (self.OutputN Or self.Regs[AY_ENABLE]);
    VolA := 0; VolB := 0; VolC := 0;
    AY_Left :=STEP;
    repeat
        If (self.CountN < AY_Left) Then AY_NextEvent := self.CountN
                else AY_NextEvent := AY_Left;
        If (AY_OutNoise And $8)<>0 Then begin
            If self.OutputA<>0 Then VolA := VolA + self.CountA;
            self.CountA := self.CountA - AY_NextEvent;
            While (self.CountA <= 0) do begin
                self.CountA := self.CountA + self.PeriodA;
                If (self.CountA > 0) Then begin
                    self.OutputA := self.OutputA Xor 1;
                    If (self.OutputA<>0) Then VolA := VolA + self.PeriodA;
                    break;
                end;
                self.CountA := self.CountA + self.PeriodA;
                VolA := VolA + self.PeriodA;
            end;
            If (self.OutputA<>0) Then VolA := VolA - self.CountA;
        end Else begin
            self.CountA := self.CountA - AY_NextEvent;
            While (self.CountA <= 0) do begin
                self.CountA := self.CountA + self.PeriodA;
                If (self.CountA > 0) Then begin
                    self.OutputA := self.OutputA Xor 1;
                    break;
                end;
                self.CountA := self.CountA + self.PeriodA;
            end;
        end;
        If (AY_OutNoise And $10)<>0 Then begin
            If self.OutputB<>0 Then VolB := VolB + self.CountB;
            self.CountB := self.CountB - AY_NextEvent;
            While (self.CountB <= 0) do begin
                self.CountB := self.CountB + self.PeriodB;
                If (self.CountB > 0) Then begin
                    self.OutputB := self.OutputB Xor 1;
                    If (self.OutputB<>0) Then VolB := VolB + self.PeriodB;
                    break;
                end;
                self.CountB := self.CountB + self.PeriodB;
                VolB := VolB + self.PeriodB;
            end;
            If (self.OutputB<>0) Then VolB := VolB - self.CountB;
        end Else begin
            self.CountB := self.CountB - AY_NextEvent;
            While (self.CountB <= 0) do begin
                self.CountB := self.CountB + self.PeriodB;
                If (self.CountB > 0) Then begin
                    self.OutputB := self.OutputB Xor 1;
                    break;
                end;
                self.CountB := self.CountB + self.PeriodB;
            end;
        end;
        If (AY_OutNoise And $20)<>0 Then begin
            If (self.OutputC<>0) Then VolC := VolC + self.CountC;
            self.CountC := self.CountC - AY_NextEvent;
            While (self.CountC <= 0) do begin
                self.CountC := self.CountC + self.PeriodC;
                If (self.CountC > 0) Then begin
                    self.OutputC := self.OutputC Xor 1;
                    If (self.OutputC<>0) Then VolC := VolC + self.PeriodC;
                    break;
                end;
                self.CountC := self.CountC + self.PeriodC;
                VolC := VolC + self.PeriodC;
            end;
            If (self.OutputC<>0) Then VolC := VolC - self.CountC;
        end Else begin
            self.CountC := self.CountC - AY_NextEvent;
            While (self.CountC <= 0) do begin
                self.CountC := self.CountC + self.PeriodC;
                If (self.CountC > 0) Then begin
                    self.OutputC := self.OutputC Xor 1;
                    break;
                end;
                self.CountC := self.CountC + self.PeriodC;
            end;
        end;
        self.CountN := self.CountN - AY_NextEvent;
        If (self.CountN <= 0) Then begin
          if ((self.RNG + 1) and 2)<>0 then begin	//* (bit0^bit1)? */
					  self.OutputN:=not(self.OutputN);
					  AY_Outnoise:=(self.OutputN or self.Regs[AY_ENABLE]);
          end;
          if (self.RNG and 1)<>0 then self.RNG:=self.RNG xor $28000; //* This version is called the "Galois configuration". */
				  self.RNG:=self.RNG shr 1;
				  self.CountN:=self.CountN+self.PeriodN;
        end;
        AY_Left := AY_Left - AY_NextEvent;
    until (AY_Left <= 0);
    if (self.Holding = 0) then begin
        self.CountE :=self.CountE -STEP;
        If (self.CountE <= 0) then begin
            repeat
                self.CountEnv := self.CountEnv - 1;
                self.CountE := self.CountE + self.PeriodE;
            until (self.CountE > 0);
            if (self.CountEnv < 0) then begin
                if (self.Hold<>0) then begin
                    if (self.Alternate<>0) then self.Attack:=self.Attack xor $1f;
                    self.Holding:=1;
                    self.CountEnv:=0;
                end else begin
                    If (self.Alternate<>0) and ((self.CountEnv and $20)<>0) then self.Attack := self.Attack xor $1f;
                    self.CountEnv:=self.CountEnv and $1f;  //1f
                end;
            end;
            self.VolE :=trunc(Vol_Table[self.CountEnv xor self.Attack]);
            If (self.EnvelopeA<>0) then self.VolA:=self.VolE;
            If (self.EnvelopeB<>0) then self.VolB:=self.VolE;
            If (self.EnvelopeC<>0) then self.VolC:=self.VolE;
        end;
    end;
    lOut1:=trunc(((VolA*self.VolA)/STEP)*self.gain0*self.amp);
    lOut2:=trunc(((VolB*self.VolB)/STEP)*self.gain1*self.amp);
    lOut3:=trunc(((VolC*self.VolC)/STEP)*self.gain2*self.amp);
    temp2:=trunc(((((VolA*self.VolA)/STEP)*self.gain0)+(((VolB*self.VolB)/STEP)*self.gain1)+(((VolC*self.VolC)/STEP))*self.gain2)*self.amp);
    if lout1>32767 then salida_ay[1]:=32767
      else if lout1<-32767 then salida_ay[1]:=-32767
          else salida_ay[1]:=lout1;
    if lout2>32767 then salida_ay[2]:=32767
      else if lout2<-32767 then salida_ay[2]:=-32767
          else salida_ay[2]:=lout2;
    if lout3>32767 then salida_ay[3]:=32767
      else if lout3<-32767 then salida_ay[3]:=-32767
          else salida_ay[3]:=lout3;
    if temp2>32767 then salida_ay[0]:=32767
      else if temp2<-32767 then salida_ay[0]:=-32767
          else salida_ay[0]:=temp2;
    update_internal:=@salida_ay[0];
end;

procedure ay8910_chip.update;
begin
self.update_internal;
tsample[self.tsample_num,sound_status.posicion_sonido]:=salida_ay[0];
if sound_status.stereo then tsample[self.tsample_num,sound_status.posicion_sonido+1]:=salida_ay[0];
end;

end.
