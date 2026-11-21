unit huc6280_audio;
interface

uses sound_engine;

type
  tpce_voice=record
    frequency:word;
    control,balance,noise,dda,index:byte;
    wave:array[0..31]of byte;
    divider,noise_divider:integer;
    seed:cardinal;
  end;
  thuc6280_psg=class(snd_chip_class)
  public
    constructor create(psg_clock:cardinal);
    procedure reset;
    procedure write(reg,value:byte);
    procedure sample(var left,right:integer);
    procedure update;
  private
    voices:array[0..5]of tpce_voice;
    selected,balance,lfo_frequency,lfo_control:byte;
    sample_phase:cardinal;
    attenuation:array[0..31]of integer;
    hp_l,hp_r,last_l,last_r:integer;
    procedure tick;
    function level(side:integer):integer;
  end;

var
  huc6280_psg_0:thuc6280_psg;

implementation
uses Math;

constructor thuc6280_psg.create(psg_clock:cardinal);
var
  i:integer;
begin
 clock:=psg_clock;
 tsample_num:=init_channel;
 for i:=0 to 30 do attenuation[i]:=Round(340.0*Power(10.0,-i*1.5/20));
 attenuation[31]:=0;
 reset;
end;

procedure thuc6280_psg.reset;
var
  i:integer;
begin
 FillChar(voices,SizeOf(voices),0);
 selected:=0;
 balance:=0;
 lfo_frequency:=0;
 lfo_control:=0;
 sample_phase:=0;
 hp_l:=0;
 hp_r:=0;
 last_l:=0;
 last_r:=0;
 for i:=0 to 5 do begin
    voices[i].seed:=1;
    voices[i].divider:=1;
    voices[i].noise_divider:=1;
 end;
end;

procedure thuc6280_psg.write(reg,value:byte);
var
  n:integer;
  old:byte;
begin
 reg:=reg and 15;
 case reg of
   0:selected:=value and 7;
   1:balance:=value;
   8:lfo_frequency:=value;
   9:begin
      lfo_control:=value;
      if (value and $80)<>0 then begin
        voices[1].index:=0;
        voices[1].divider:=1;
      end;
     end;
 end;
 n:=selected;
 if n>5 then exit;
 case reg of
   2:voices[n].frequency:=(voices[n].frequency and $f00) or value;
   3:voices[n].frequency:=(voices[n].frequency and $ff) or (word(value and 15) shl 8);
   4:begin
     old:=voices[n].control;
     if ((old and $40)<>0) and ((value and $40)=0) then voices[n].index:=0;
     if ((old and $80)=0) and ((value and $80)<>0) then begin
       voices[n].divider:=voices[n].frequency;
       if voices[n].divider=0 then voices[n].divider:=4096;
     end;
     voices[n].control:=value;
   end;
   5:voices[n].balance:=value;
   6:if (voices[n].control and $40)<>0 then voices[n].dda:=value and 31
     else begin
       voices[n].wave[voices[n].index]:=value and 31;
       if (voices[n].control and $80)=0 then voices[n].index:=(voices[n].index+1) and 31;
     end;
   7:voices[n].noise:=value;
 end;
end;

procedure thuc6280_psg.tick;
var
  n,period,lf:integer;
  b:cardinal;
begin
 for n:=0 to 5 do begin
   if (voices[n].control and $80)=0 then continue;
   if (n>=4) and ((voices[n].noise and $80)<>0)then begin
     dec(voices[n].noise_divider);
     if voices[n].noise_divider<=0 then begin
       period:=((voices[n].noise and 31) xor 31)*64;
       if period=0 then period:=1;
       inc(voices[n].noise_divider,period);
       b:=voices[n].seed;
       voices[n].seed:=(b shr 1) or (((b xor (b shr 1) xor (b shr 11) xor (b shr 12) xor (b shr 17)) and 1) shl 17);
     end;
   end else if(voices[n].control and $40)=0 then begin
              period:=voices[n].frequency;
              if period=0 then period:=4096;
              if (lfo_control and 3)<>0 then begin
                if n=0 then begin
                    lf:=integer(voices[1].wave[voices[1].index])-16;
                    period:=period+lf*(1 shl (((lfo_control and 3)-1)*2));
                    if period<1 then period:=1;
                end;
                if n=1 then begin
                    if (lfo_control and $80)<>0 then begin
                      voices[n].index:=0;
                      continue;
                    end;
                    lf:=lfo_frequency;
                    if lf=0 then lf:=256;
                    period:=period*lf;
                end;
              end;
              dec(voices[n].divider);
              if voices[n].divider<=0 then begin
                  inc(voices[n].divider,period);
                  voices[n].index:=(voices[n].index+1) and 31;
              end;
            end;
  end;
end;

function thuc6280_psg.level(side:integer):integer;
const
  scale:array[0..15] of byte=(0,3,5,7,9,11,13,15,16,19,21,23,25,27,29,31);
var
  n,atten,v,shift:integer;
begin
 result:=0;
 shift:=0;
 if side=0 then shift:=4;
 for n:=0 to 5 do if (voices[n].control and $80)<>0 then begin
   atten:=31-scale[(balance shr shift) and 15]+31-scale[(voices[n].balance shr shift) and 15]+31-(voices[n].control and 31);
   if atten>31 then atten:=31;
   if (n>=4) and ((voices[n].noise and $80)<>0) then v:=integer(voices[n].seed and 1)*31
     else if (voices[n].control and $40)<>0 then v:=voices[n].dda
            else v:=voices[n].wave[voices[n].index];
   inc(result,(v-16)*attenuation[atten]);
 end;
end;

procedure thuc6280_psg.sample(var left,right:integer);
var
  count,i:integer;
  l,r:int64;
begin
 inc(sample_phase,clock);
 count:=sample_phase div FREQ_BASE_AUDIO;
 sample_phase:=sample_phase mod FREQ_BASE_AUDIO;
 l:=0;
 r:=0;
 for i:=1 to count do begin
  tick;
  inc(l,level(0));
  inc(r,level(1));
 end;
 if count<>0 then begin
    left:=l div count;
    right:=r div count;
 end else begin
            left:=level(0);
            right:=level(1);
          end;
 // Remove the DAC DC component, including DDA channels.
 hp_l:=left-last_l+(hp_l*995) div 1000;
 last_l:=left;
 left:=hp_l;
 hp_r:=right-last_r+(hp_r*995) div 1000;
 last_r:=right;
 right:=hp_r;
 if left>32767 then left:=32767
  else if left< -32768 then left:=-32768;
 if right>32767 then right:=32767
  else if right< -32768 then right:=-32768;
end;

procedure thuc6280_psg.update;
var
  l,r,pos:integer;
begin
 sample(l,r);
 pos:=sound_status.posicion_sonido;
 if pos>=LONG_MAX_AUDIO then exit;
 if sound_status.stereo then begin
   tsample[tsample_num,pos]:=l;
   if pos+1<LONG_MAX_AUDIO then tsample[tsample_num,pos+1]:=r;
 end else tsample[tsample_num,pos]:=(l+r) div 2;
end;

end.
