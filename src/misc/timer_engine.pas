unit timer_engine;

interface
uses dialogs;

const
  MAX_TIMERS=14;

type
  exec_type_param=procedure(param0:byte);
  exec_type_simple=procedure;
  ttimers=record
           execute_param:exec_type_param;  //call function
           execute_simple:exec_type_simple;  //sound call function
           time_final:single;     //Final time to call function
           actual_time:single;    //Actual time
           cpu:byte;        //CPU asociada al timer y dispositivo asociado
           enabled:boolean; // Running?
           param0:byte; //Parametros
        end;
  tautofire_proc=procedure(autofire_index:byte;autofire_status:boolean);
  timer_eng=class
      constructor create;
      destructor free;
   public
      timer:array[0..MAX_TIMERS] of ttimers;
      autofire_timer:byte;
      autofire_on:boolean;
      autofire_status,autofire_enabled:array [0..11] of boolean;
      function init(cpu:byte;time:single;exec_simple:exec_type_simple;exec_param:exec_type_param;ena:boolean;param0:byte=0):byte;
      procedure update(time_add:word;cpu:byte);
      procedure enabled(timer_num:byte;state:boolean);
      procedure reset(timer_num:byte);
      procedure clear;
      procedure autofire_init;
    private
      timer_count:integer;
  end;

var
  timers:timer_eng;

implementation
uses controls_engine,cpu_misc,main_engine;

procedure auto_fire;
begin
  //P1
  if timers.autofire_enabled[0] then begin
    if timers.autofire_status[0] then arcade_input.but0[0]:=not(arcade_input.but0[0])
      else arcade_input.but0[0]:=false;
    event.arcade:=true;
  end;
  if timers.autofire_enabled[1] then begin
    if timers.autofire_status[1] then arcade_input.but1[0]:=not(arcade_input.but1[0])
      else arcade_input.but1[0]:=false;
    event.arcade:=true;
  end;
  if timers.autofire_enabled[2] then begin
    if timers.autofire_status[2] then arcade_input.but2[0]:=not(arcade_input.but2[0])
      else arcade_input.but2[0]:=false;
    event.arcade:=true;
  end;
  if timers.autofire_enabled[3] then begin
    if timers.autofire_status[3] then arcade_input.but3[0]:=not(arcade_input.but3[0])
      else arcade_input.but3[0]:=false;
    event.arcade:=true;
  end;
  if timers.autofire_enabled[4] then begin
    if timers.autofire_status[4] then arcade_input.but4[0]:=not(arcade_input.but4[0])
      else arcade_input.but4[0]:=false;
    event.arcade:=true;
  end;
  if timers.autofire_enabled[5] then begin
    if timers.autofire_status[5] then arcade_input.but5[0]:=not(arcade_input.but5[0])
      else arcade_input.but5[0]:=false;
    event.arcade:=true;
  end;
  //P2
  if timers.autofire_enabled[6] then begin
    if timers.autofire_status[6] then arcade_input.but0[1]:=not(arcade_input.but0[1])
      else arcade_input.but0[1]:=false;
    event.arcade:=true;
  end;
  if timers.autofire_enabled[7] then begin
    if timers.autofire_status[7] then arcade_input.but1[1]:=not(arcade_input.but1[1])
      else arcade_input.but1[1]:=false;
    event.arcade:=true;
  end;
  if timers.autofire_enabled[8] then begin
    if timers.autofire_status[8] then arcade_input.but2[1]:=not(arcade_input.but2[1])
      else arcade_input.but2[1]:=false;
    event.arcade:=true;
  end;
  if timers.autofire_enabled[9] then begin
    if timers.autofire_status[9] then arcade_input.but3[1]:=not(arcade_input.but3[1])
      else arcade_input.but3[1]:=false;
    event.arcade:=true;
  end;
  if timers.autofire_enabled[10] then begin
    if timers.autofire_status[10] then arcade_input.but4[1]:=not(arcade_input.but4[1])
      else arcade_input.but4[1]:=false;
    event.arcade:=true;
  end;
  if timers.autofire_enabled[11] then begin
    if timers.autofire_status[11] then arcade_input.but5[1]:=not(arcade_input.but5[1])
      else arcade_input.but5[1]:=false;
    event.arcade:=true;
  end;
end;

constructor timer_eng.create;
begin
  self.clear;
end;

destructor timer_eng.free;
begin
end;

procedure timer_eng.autofire_init;
begin
  self.autofire_timer:=self.init(cpu_info[0].num_cpu,1,auto_fire,nil,timers.autofire_on);
  self.timer[self.autofire_timer].time_final:=cpu_info[0].clock/1000;
end;

function timer_eng.init(cpu:byte;time:single;exec_simple:exec_type_simple;exec_param:exec_type_param;ena:boolean;param0:byte=0):byte;
begin
self.timer_count:=self.timer_count+1;
if self.timer_count=MAX_TIMERS then MessageDlg('Superados el maximo de timer', mtInformation,[mbOk], 0);
self.timer[self.timer_count].cpu:=cpu;
self.timer[self.timer_count].time_final:=time;
self.timer[self.timer_count].execute_param:=exec_param;
self.timer[self.timer_count].execute_simple:=exec_simple;
self.timer[self.timer_count].enabled:=ena;
self.timer[self.timer_count].param0:=param0;
init:=self.timer_count;
end;

procedure timer_eng.update(time_add:word;cpu:byte);
var
  f:integer;
begin
for f:=self.timer_count downto 0 do begin
  if (self.timer[f].enabled and (cpu=self.timer[f].cpu)) then begin
    self.timer[f].actual_time:=self.timer[f].actual_time+time_add;
    //Atencion!!! si desactivo el timer dentro de la funcion, ya no tiene que hacer nada!
    while ((self.timer[f].actual_time>=self.timer[f].time_final) and self.timer[f].enabled) do begin
        if @self.timer[f].execute_simple<>nil then self.timer[f].execute_simple
          else self.timer[f].execute_param(self.timer[f].param0);
        self.timer[f].actual_time:=self.timer[f].actual_time-self.timer[f].time_final;
    end;
  end;
end;
end;

procedure timer_eng.enabled(timer_num:byte;state:boolean);
begin
  //Esto le sienta mal a Jackal!!!
  //if (state and not(self.timer[timer_num].enabled)) then self.timer[timer_num].actual_time:=0;
  self.timer[timer_num].enabled:=state;
end;

procedure timer_eng.clear;
var
  f:byte;
begin
self.timer_count:=-1;
for f:=0 to MAX_TIMERS do begin
  self.timer[f].time_final:=0;
  self.timer[f].actual_time:=0;
  self.timer[f].execute_param:=nil;
  self.timer[f].execute_simple:=nil;
  self.timer[f].cpu:=0;
  self.timer[f].enabled:=false;
end;
for f:=0 to 11 do autofire_status[f]:=false;
end;

procedure timer_eng.reset(timer_num:byte);
begin
  self.timer[timer_num].actual_time:=0;
end;

end.
