unit generic_adpcm;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}msm5205,sound_engine,timer_engine;

type
  generic_adpcm_chip=record
    mem:pbyte;
    step,signal:integer;
    timer,nibble,tsample:byte;
    current,end_:dword;
  end;

var
  gen_adpcm:array[0..1] of generic_adpcm_chip;

procedure gen_adpcm_reset(num:byte);
procedure gen_adpcm_init(num:byte;clock,size:dword);
procedure gen_adpcm_close(num:byte);
procedure gen_adpcm_timer(num:byte;status:boolean);
procedure gen_update_adpcm(index:byte);
procedure gen_adpcm_update(num:byte);

implementation

procedure gen_adpcm_reset(num:byte);
begin
  gen_adpcm[num].step:=-2;
  gen_adpcm[num].signal:=0;
  gen_adpcm[num].nibble:=0;
end;

procedure gen_adpcm_timer(num:byte;status:boolean);
begin
  timers.enabled(gen_adpcm[num].timer,status);
end;

procedure gen_adpcm_init(num:byte;clock,size:dword);
begin
  gen_adpcm[num].tsample:=init_channel;
  getmem(gen_adpcm[num].mem,size);
  gen_adpcm[num].timer:=timers.init(sound_status.cpu_num,sound_status.cpu_clock/clock,nil,gen_update_adpcm,false,num);
  if num=0 then msm5205_ComputeTables;
end;

procedure gen_adpcm_close(num:byte);
begin
  freemem(gen_adpcm[num].mem);
end;

procedure gen_update_adpcm(index:byte);
var
  val:byte;
begin
val:=(gen_adpcm[index].mem[gen_adpcm[index].current] shr gen_adpcm[index].nibble) and $f;
gen_adpcm[index].nibble:=gen_adpcm[index].nibble xor 4;
if (gen_adpcm[index].nibble=4) then begin
			gen_adpcm[index].current:=gen_adpcm[index].current+1;
			if (gen_adpcm[index].current>=gen_adpcm[index].end_) then begin
          timers.enabled(gen_adpcm[index].timer,false);
          gen_adpcm[index].signal:=0;
          exit;
      end;
end;
gen_adpcm[index].signal:=msm5205_clock(val,gen_adpcm[index].step,gen_adpcm[index].signal);
end;


procedure gen_update_adpcm_internal(num:byte);
var
  val:byte;
begin
val:=(gen_adpcm[num].mem[gen_adpcm[num].current] shr gen_adpcm[num].nibble) and $f;
gen_adpcm[num].nibble:=gen_adpcm[num].nibble xor 4;
if (gen_adpcm[num].nibble=4) then begin
			gen_adpcm[num].current:=gen_adpcm[num].current+1;
			if (gen_adpcm[num].current>=gen_adpcm[num].end_) then begin
          timers.enabled(gen_adpcm[num].timer,false);
          gen_adpcm[num].signal:=0;
          exit;
      end;
end;
gen_adpcm[num].signal:=msm5205_clock(val,gen_adpcm[num].step,gen_adpcm[num].signal);
end;

procedure gen_adpcm_update(num:byte);
begin
tsample[gen_adpcm[num].tsample,sound_status.posicion_sonido]:=gen_adpcm[num].signal shl 4;
if sound_status.stereo then tsample[gen_adpcm[num].tsample,sound_status.posicion_sonido+1]:=gen_adpcm[num].signal shl 4;
end;


end.
