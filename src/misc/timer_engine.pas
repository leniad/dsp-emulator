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
  tautofire_proc=procedure(autofire_index:byte;autofire_status:boolean);

var
  //Los timers ahora son dinamicos
  timer:array[0..MAX_TIMERS] of ttimers;
  autofire_status,autofire_enabled:array [0..11] of boolean;
  autofire_timer:byte=$ff;
  autofire_general:boolean;

procedure reset_timer;
procedure update_timer(time_add:word;cpu:byte);
function init_timer(cpu:byte;time:single;exec:exec_type;ena:boolean):byte;
//Autofire
procedure init_autofire;
procedure close_autofire;

implementation
uses controls_engine,cpu_misc;

var
  timer_count:integer;

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
for f:=timer_count downto 0 do begin
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

procedure auto_fire;
begin
  //P1
  if autofire_enabled[0] then begin
    if autofire_status[0] then arcade_input.but0[0]:=not(arcade_input.but0[0])
      else arcade_input.but0[0]:=false;
    event.arcade:=true;
  end;
  if autofire_enabled[1] then begin
    if autofire_status[1] then arcade_input.but1[0]:=not(arcade_input.but1[0])
      else arcade_input.but1[0]:=false;
    event.arcade:=true;
  end;
  if autofire_enabled[2] then begin
    if autofire_status[2] then arcade_input.but2[0]:=not(arcade_input.but2[0])
      else arcade_input.but2[0]:=false;
    event.arcade:=true;
  end;
  if autofire_enabled[3] then begin
    if autofire_status[3] then arcade_input.but3[0]:=not(arcade_input.but3[0])
      else arcade_input.but3[0]:=false;
    event.arcade:=true;
  end;
  if autofire_enabled[4] then begin
    if autofire_status[4] then arcade_input.but4[0]:=not(arcade_input.but4[0])
      else arcade_input.but4[0]:=false;
    event.arcade:=true;
  end;
  if autofire_enabled[5] then begin
    if autofire_status[5] then arcade_input.but5[0]:=not(arcade_input.but5[0])
      else arcade_input.but5[0]:=false;
    event.arcade:=true;
  end;
  //P2
  if autofire_enabled[6] then begin
    if autofire_status[6] then arcade_input.but0[1]:=not(arcade_input.but0[1])
      else arcade_input.but0[1]:=false;
    event.arcade:=true;
  end;
  if autofire_enabled[7] then begin
    if autofire_status[7] then arcade_input.but1[1]:=not(arcade_input.but1[1])
      else arcade_input.but1[1]:=false;
    event.arcade:=true;
  end;
  if autofire_enabled[8] then begin
    if autofire_status[8] then arcade_input.but2[1]:=not(arcade_input.but2[1])
      else arcade_input.but2[1]:=false;
    event.arcade:=true;
  end;
  if autofire_enabled[9] then begin
    if autofire_status[9] then arcade_input.but3[1]:=not(arcade_input.but3[1])
      else arcade_input.but3[1]:=false;
    event.arcade:=true;
  end;
  if autofire_enabled[10] then begin
    if autofire_status[10] then arcade_input.but4[1]:=not(arcade_input.but4[1])
      else arcade_input.but4[1]:=false;
    event.arcade:=true;
  end;
  if autofire_enabled[11] then begin
    if autofire_status[11] then arcade_input.but5[1]:=not(arcade_input.but5[1])
      else arcade_input.but5[1]:=false;
    event.arcade:=true;
  end;
end;

procedure init_autofire;
var
  f:byte;
begin
  if autofire_timer=$ff then autofire_timer:=init_timer(cpu_info[0].num_cpu,1,auto_fire,true);
  //Inicializao de nuevo la velocidad y que este encendido
  timer[autofire_timer].enabled:=true;
  timer[autofire_timer].time_final:=cpu_info[0].clock/1000;
  for f:=0 to 11 do autofire_status[f]:=false;
end;

procedure close_autofire;
var
  f:byte;
begin
  if autofire_timer<>$ff then begin
    timer_count:=timer_count-1;
    autofire_timer:=$ff;
  end;
  for f:=0 to 11 do begin
    if not(autofire_general) then autofire_enabled[f]:=false;
    autofire_status[f]:=false;
  end;
end;

end.
