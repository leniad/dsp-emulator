unit kaillera;

interface

uses
  {$IFDEF WINDOWS}windows,{$endif}Classes, SysUtils,dialogs;

procedure init_kaillera;

type
    tkailleraInfos=packed record
          appname:pansichar;
          gameList:pansichar;
          gameCallback:function(game:pansichar;player:integer;numplayers:integer):integer;cdecl;
          chatReceivedCallback:procedure (nick:pchar;text:pchar);cdecl;
          moreInfosCallback:procedure (gamename:pchar);cdecl;
    end;
    ptkailleraInfos=^tkailleraInfos;

var
   kaillera_dll_handle:int64;
   kaillera_enabled:boolean;
   kailleraGetVersion:procedure(version:pchar);cdecl;
   kailleraInit:procedure();
   kailleraShutdown:procedure();
   kailleraSetInfos:procedure(infos:ptkailleraInfos);
   {$ifdef windows}
   kailleraSelectServerDialog:procedure(parent:HWND);
   {$endif}
   kailleraModifyPlayValues:procedure(values:pointer;size:Integer);
   kailleraEndGame:procedure();

implementation

procedure init_kaillera;
begin
kaillera_enabled:=false;
{$ifdef darwin}
exit;
{$endif}
{$ifdef linux}
exit;
{$endif}
{$ifdef windows}
kaillera_dll_handle:=LoadLibrary('kailleraclient.dll');
if kaillera_dll_handle=0 then begin
  MessageDlg('Kaillera client library not found.'+chr(10)+chr(13)+'Please read the documentation!', mtError,[mbOk], 0);
  exit;
end;
@kailleraGetVersion:=GetProcAddress(kaillera_dll_handle,'kailleraGetVersion');
@kailleraInit:=GetProcAddress(kaillera_dll_handle,'kailleraInit');
@kailleraShutdown:=GetProcAddress(kaillera_dll_handle,'kailleraShutdown');
@kailleraSetInfos:=GetProcAddress(kaillera_dll_handle,'kailleraSetInfos');
@kailleraModifyPlayValues:=GetProcAddress(kaillera_dll_handle,'kailleraModifyPlayValues');
@kailleraEndGame:=GetProcAddress(kaillera_dll_handle,'kailleraEndGame');
@kailleraSelectServerDialog:=GetProcAddress(kaillera_dll_handle,'kailleraSelectServerDialog');
kaillera_enabled:=true;
{$endif}
end;

end.

