var
 rtc_shift:uint64;
 rtc_command:byte;
 rtc_last:byte;
 rtc_mode:integer;
 rtc_tp,rtc_data,rtc_test,rtc_held:boolean;
 rtc_elapsed,rtc_origin,rtc_test_origin:int64;
 rtc_tp_div:int64;
 rtc_counter:uint64;
 rtc_datetime:TDateTime;
 rtc_second_origin:int64;

function rtc_now:int64;
begin
  Result:=rtc_elapsed+m68000_0.contador;
end;

function bcd(v:integer):byte;
begin
  Result:=(v div 10)*16+(v mod 10);
end;

function unbcd(v:byte):integer;
begin
  Result:=(v shr 4)*10+(v and 15);
end;

procedure rtc_encode;
var
  yy,mm,dd,hh,mi,ss,ms:word;
begin
 DecodeDate(rtc_datetime,yy,mm,dd);
 DecodeTime(rtc_datetime,hh,mi,ss,ms);
 rtc_counter:=uint64(bcd(ss)) or (uint64(bcd(mi)) shl 8) or (uint64(bcd(hh)) shl 16) or (uint64(bcd(dd)) shl 24) or (uint64(mm*16+DayOfWeek(rtc_datetime)-1) shl 32) or (uint64(bcd(yy mod 100)) shl 40);
end;

procedure rtc_sync;
var
  ticks:int64;
begin
 if rtc_test and not(rtc_held) then begin
  ticks:=(rtc_now-rtc_test_origin)*8192 div 12000000;
  if ticks>0 then begin
      rtc_counter:=(rtc_counter+uint64(ticks)) and $ffffffffffff;
      inc(rtc_test_origin,ticks*12000000 div 8192);
  end;
  rtc_data:=((rtc_counter shr 40) and $ff)=0;
 end else if not(rtc_mode in[1,2]) then rtc_data:=((rtc_now div 6000000) and 1)<>0;
 if not rtc_test and not rtc_held then begin
  ticks:=(rtc_now-rtc_second_origin)div 12000000;
  if ticks>0 then begin
      rtc_datetime:=rtc_datetime+ticks/86400.0;
      inc(rtc_second_origin,ticks*12000000);
      rtc_encode;
  end;
 end;
 rtc_tp:=(((rtc_now-rtc_origin) div rtc_tp_div) and 1)<>0;
end;

procedure rtc_write(v:byte);
var
  rising,strobe:boolean;
  input:byte;
begin
 rtc_sync;
 rising:=((rtc_last and 2)=0) and ((v and 2)<>0);
 strobe:=((rtc_last and 4)=0) and ((v and 4)<>0);
 if rising then begin
  input:=rtc_command and 1;
  rtc_command:=(rtc_command shr 1) or ((v and 1)shl 3);
  if rtc_mode=1 then begin
      rtc_shift:=(rtc_shift shr 1) or (uint64(input) shl 47);
      rtc_data:=(rtc_shift and 1)<>0;
  end;
 end;
 if strobe then begin
  rtc_mode:=rtc_command;
  if (rtc_mode=0) or ((rtc_mode>=4) and (rtc_mode<15)) then rtc_test:=false;
  case rtc_mode of
   0:begin
        rtc_held:=false;
        rtc_tp_div:=93750;
        rtc_origin:=rtc_now;
     end;
   1:begin
        rtc_held:=false;
        rtc_data:=(rtc_shift and 1)<>0;
     end;
   2:begin
        rtc_counter:=rtc_shift;
        rtc_held:=true;
        rtc_data:=(rtc_shift and 1)<>0;
        try rtc_datetime:=EncodeDate(2000+unbcd(rtc_counter shr 40),((rtc_counter shr 32)and $f0)shr 4,unbcd(rtc_counter shr 24))+
          EncodeTime(unbcd(rtc_counter shr 16),unbcd(rtc_counter shr 8),unbcd(rtc_counter),0);
        except
        end;
        rtc_second_origin:=rtc_now;
    end;
   3:begin
        rtc_held:=false;
        rtc_shift:=rtc_counter;
     end;
   4:begin
        rtc_tp_div:=93750;
        rtc_origin:=rtc_now;
     end;
   5:begin
        rtc_tp_div:=23438;
        rtc_origin:=rtc_now;
     end;
   6:begin
        rtc_tp_div:=2930;
        rtc_origin:=rtc_now;
     end;
   7:begin
        rtc_tp_div:=1465;
        rtc_origin:=rtc_now;
     end;
   8..11:begin
            case rtc_mode of
              8:rtc_tp_div:=6000000;
              9:rtc_tp_div:=60000000;
              10:rtc_tp_div:=180000000;
              11:rtc_tp_div:=360000000;
            end;
            rtc_origin:=rtc_now;
         end;
   15:begin
        rtc_test:=true;
        rtc_test_origin:=rtc_now;
      end;
  end;
  if rtc_test and(rtc_mode in[1,3])then begin
      rtc_tp_div:=187500;
      rtc_origin:=rtc_now;
  end;
 end;rtc_last:=v;
end;

procedure reset_rtc;
begin
 rtc_command:=0;
 rtc_last:=0;
 rtc_mode:=0;
 rtc_shift:=0;
 rtc_tp:=false;
 rtc_data:=false;
 rtc_elapsed:=0;
 rtc_origin:=0;
 rtc_test_origin:=0;
 rtc_tp_div:=93750;
 rtc_test:=false;
 rtc_held:=false;
 rtc_second_origin:=0;
 rtc_datetime:=Now;
 rtc_encode;
end;