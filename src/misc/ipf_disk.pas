unit ipf_disk;

interface
uses vcl.dialogs{$ifdef windows},windows{$else},dynlibs{$endif};

const
  CAPS_MTRS=5;
  DI_LOCK_DENVAR=1 shl 2;
  DI_LOCK_DENAUTO=1 shl 3;
  DI_LOCK_MEMREF=1 shl 7;
  CAPS_MAXPLATFORM=4;

type
  SDWORD=integer;
  UDWORD=dword;
  // disk sector information block
  CapsSectorInfo=record
	  descdatasize:UDWORD; // data size in bits from IPF descriptor
	  descgapsize:UDWORD;  // gap size in bits from IPF descriptor
	  datasize:UDWORD;     // data size in bits from decoder
	  gapsize:UDWORD;      // gap size in bits from decoder
	  datastart:UDWORD;    // data start position in bits from decoder
	  gapstart:UDWORD;     // gap start position in bits from decoder
	  gapsizews0:UDWORD;   // gap size before write splice
	  gapsizews1:UDWORD;   // gap size after write splice
	  gapws0mode:UDWORD;   // gap size mode before write splice
	  gapws1mode:UDWORD;   // gap size mode after write splice
	  celltype:UDWORD;     // bitcell type
	  enctype:UDWORD;      // encoder type
  end;
  PCAPSSECTORINFO=^CapsSectorInfo;
  // disk track information block
  CapsTrackInfo=record
	  type_:UDWORD;       // track type
	  cylinder:UDWORD;   // cylinder#
	  head:UDWORD;       // head#
	  sectorcnt:UDWORD;  // available sectors
	  sectorsize:UDWORD; // sector size
	  trackcnt:UDWORD;   // track variant count
	  trackbuf:pbyte;   // track buffer memory
	  tracklen:UDWORD;   // track buffer memory length
	  trackdata:array[0..(CAPS_MTRS-1)] of pbyte; // track data pointer if available
	  tracksize:array[0..(CAPS_MTRS-1)] of UDWORD; // track data size
	  timelen:UDWORD;  // timing buffer length
	  timebuf:pword; // timing buffer
  end;
  PCAPSTRACKINFO=^CapsTrackInfo;
  // decoded caps date.time
  CapsDateTimeExt=record
    year,month,day:UDWORD;
	  hour,min,sec:UDWORD;
	  tick:UDWORD;
  end;
  //disk image information block
  CapsImageInfo=record
    type_:UDWORD;        // image type
	  release:UDWORD;     // release ID
	  revision:UDWORD;    // release revision ID
	  mincylinder:UDWORD; // lowest cylinder number
	  maxcylinder:UDWORD; // highest cylinder number
	  minhead:UDWORD;     // lowest head number
	  maxhead:UDWORD;     // highest head number
	  crdt:CapsDateTimeExt; // image creation date.time
	  platform_:array[0..(CAPS_MAXPLATFORM-1)] of UDWORD; // intended platform(s)
  end;
  PCAPSIMAGEINFO=^CapsImageInfo;
  TCAPS_basic=function:SDWORD;cdecl;
  TCAPS_basic2=function(id:SDWORD):SDWORD;cdecl;
  TCAPSLockImage=function(id:SDWORD;name:PCHAR):SDWORD;cdecl;
  TCAPSLockImageMemory=function(id:SDWORD;buffer:pbyte;length,flag:UDWORD):SDWORD;cdecl;
  TCAPSGetImageInfo=function(pi:PCAPSIMAGEINFO;id:SDWORD):SDWORD;cdecl;
  TCAPSLoadImage=function(id,flag:SDWORD):SDWORD;cdecl;
  TCAPSLockTrack=function(ptrackinfo:PCAPSTRACKINFO;id:SDWORD;cylinder,head,flag:UDWORD):SDWORD;cdecl;
  //TCAPSGetInfo=function(pinfo:PCAPSTRACKINFO;id:SDWORD;cylinder,head,inftype,infid:UDWORD):SDWORD;cdecl;

var
  dll_handle:int64;
  //funciones
  CAPSInit:TCAPS_basic;
  CAPSExit:TCAPS_basic;
  CAPSAddImage:TCAPS_basic;
  CAPSRemImage:TCAPS_basic2;
  CAPSLockImage:TCAPSLockImage;
  CAPSLockImageMemory:TCAPSLockImageMemory;
  CAPSUnlockImage:TCAPS_basic2;
  CAPSGetImageInfo:TCAPSGetImageInfo;
  CAPSLoadImage:TCAPSLoadImage;
  CAPSUnlockAllTracks:TCAPS_basic2;
  CAPSLockTrack:TCAPSLockTrack;
  //CAPSGetInfo:TCAPSGetInfo;

function init_ipf_dll:boolean;
procedure close_ipf_dll;

implementation

function init_ipf_dll:boolean;
begin
init_ipf_dll:=false;
{$ifdef darwin}
dll_Handle:=LoadLibrary('CAPSImage.a');
{$endif}
{$ifdef linux}
dll_Handle:=LoadLibrary('libcapsimage.so.4');
{$endif}
{$ifdef windows}
dll_Handle:=LoadLibrary('CAPSImg.dll');
{$endif}
if dll_Handle=0 then begin
  MessageDlg('IPF library not found.'+chr(10)+chr(13)+'Please read the documentation!', mtError,[mbOk], 0);
  exit;
end;
@CAPSInit:=GetProcAddress(dll_Handle,'CAPSInit');
@CAPSExit:=GetProcAddress(dll_Handle,'CAPSExit');
@CAPSAddImage:=GetProcAddress(dll_Handle,'CAPSAddImage');
@CAPSRemImage:=GetProcAddress(dll_Handle,'CAPSRemImage');
@CAPSLockImage:=GetProcAddress(dll_Handle,'CAPSLockImage');
@CAPSLockImageMemory:=GetProcAddress(dll_Handle,'CAPSLockImageMemory');
@CAPSUnlockImage:=GetProcAddress(dll_Handle,'CAPSUnlockImage');
@CAPSGetImageInfo:=GetProcAddress(dll_Handle,'CAPSGetImageInfo');
@CAPSLoadImage:=GetProcAddress(dll_Handle,'CAPSLoadImage');
@CAPSUnlockAllTracks:=GetProcAddress(dll_Handle,'CAPSUnlockAllTracks');
@CAPSLockTrack:=GetProcAddress(dll_Handle,'CAPSLockTrack');
//@CAPSGetInfo:=GetProcAddress(dll_Handle,'CAPSGetInfo');
init_ipf_dll:=true;
end;

procedure close_ipf_dll;
begin
  if dll_handle<>0 then begin
    FreeLibrary(dll_Handle);
    dll_handle:=0;
  end;
end;

end.