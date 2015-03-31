unit timer_engine;

interface
uses dialogs;

const
  MAX_TIMERS=14;
type
  exec_type=procedure;
  ttimers=record
           execute:exec_type;  //call function
           time_final:single;     //Final time to call function
           actual_time:single;    //Actual time
           cpu:byte;        //CPU asociada al timer y dispositivo asociado
           enabled:boolean; // Running?
        end;
var
  //Los timers ahora son dinamicos
  timer:array[0..MAX_TIMERS] of ttimers;
  timer_count:integer;

procedure reset_timer;
procedure update_timer(time_add:word;cpu:byte);
function init_timer(cpu:byte;time:single;exec:exec_type;ena:boolean):byte;

implementation

function init_timer(cpu:byte;time:single;exec:exec_type;ena:boolean):byte;
begin
timer_count:=timer_count+1;
if timer_count=MAX_TIMERS then MessageDlg('Superados el maximos de timers', mtInformation,[mbOk], 0);
timer[timer_count].cpu:=cpu;
timer[timer_count].time_final:=time;
timer[timer_count].execute:=exec;
timer[timer_count].enabled:=ena;
init_timer:=timer_count;
end;

procedure update_timer(time_add:word;cpu:byte);
var
  f:integer;
begin
for f:=0 to timer_count do begin
  if (timer[f].enabled and (cpu=timer[f].cpu)) then begin
    timer[f].actual_time:=timer[f].actual_time+time_add;
    while timer[f].actual_time>=timer[f].time_final do begin
      timer[f].execute;
      timer[f].actual_time:=timer[f].actual_time-timer[f].time_final;
    end;
  end;
end;
end;

procedure reset_timer;
var
  f:byte;
begin
timer_count:=-1;
for f:=0 to MAX_TIMERS do begin
  timer[f].time_final:=0;
  timer[f].actual_time:=0;
  timer[f].execute:=nil;
  timer[f].cpu:=0;
  timer[f].enabled:=false;
end;
end;

end.
