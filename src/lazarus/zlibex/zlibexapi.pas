{*****************************************************************************
*  ZLibExApi.pas                                                             *
*                                                                            *
*  copyright (c) 2010-2011 Nikolay Petrochenko                               *
*  copyright (c) 2000-2010 base2 technologies                                *
*  copyright (c) 1995-2002 Borland Software Corporation                      *
*                                                                            *
*  revision history                                                          *
*    04.06.2011  code cleanup, create Project page on Google Code            *
*    13.12.2010  first version, compiled in Lazarus                          *
*    20.04.2010  updated to zlib version 1.2.5                               *
*                                                                            *
*  License: Mozilla Public License версии 1.1                                *
*           http://www.mozilla.org/MPL/MPL-1.1.html                          *
*                                                                            *
*****************************************************************************}

unit ZLibExApi;

interface
uses dialogs{$ifdef windows},windows{$else},dynlibs{$endif};

const
  {** version ids ***********************************************************}

  ZLIB_VERSION         = '1.2.5';
  ZLIB_VERNUM          = $1250;

  ZLIB_VER_MAJOR       = 1;
  ZLIB_VER_MINOR       = 2;
  ZLIB_VER_REVISION    = 5;
  ZLIB_VER_SUBREVISION = 0;

  {** compression methods ***************************************************}

  Z_DEFLATED = 8;

  {** information flags *****************************************************}

  Z_INFO_FLAG_SIZE  = $1;
  Z_INFO_FLAG_CRC   = $2;
  Z_INFO_FLAG_ADLER = $4;

  Z_INFO_NONE       = 0;
  Z_INFO_DEFAULT    = Z_INFO_FLAG_SIZE or Z_INFO_FLAG_CRC;

  {** flush constants *******************************************************}

  Z_NO_FLUSH      = 0;
  Z_PARTIAL_FLUSH = 1;
  Z_SYNC_FLUSH    = 2;
  Z_FULL_FLUSH    = 3;
  Z_FINISH        = 4;
  Z_BLOCK         = 5;
  Z_TREES         = 6;

  {** return codes **********************************************************}

  Z_OK            = 0;
  Z_STREAM_END    = 1;
  Z_NEED_DICT     = 2;
  Z_ERRNO         = (-1);
  Z_STREAM_ERROR  = (-2);
  Z_DATA_ERROR    = (-3);
  Z_MEM_ERROR     = (-4);
  Z_BUF_ERROR     = (-5);
  Z_VERSION_ERROR = (-6);

  {** compression levels ****************************************************}

  Z_NO_COMPRESSION      =   0;
  Z_BEST_SPEED          =   1;
  Z_BEST_COMPRESSION    =   9;
  Z_DEFAULT_COMPRESSION = (-1);

  {** compression strategies ************************************************}

  Z_FILTERED         = 1;
  Z_HUFFMAN_ONLY     = 2;
  Z_RLE              = 3;
  Z_FIXED            = 4;
  Z_DEFAULT_STRATEGY = 0;

  {** data types ************************************************************}

  Z_BINARY  = 0;
  Z_ASCII   = 1;
  Z_TEXT    = Z_ASCII;
  Z_UNKNOWN = 2;

  {** return code messages **************************************************}

  _z_errmsg: Array [0..9] of String = (
    'Need dictionary',      // Z_NEED_DICT      (2)
    'Stream end',           // Z_STREAM_END     (1)
    'OK',                   // Z_OK             (0)
    'File error',           // Z_ERRNO          (-1)
    'Stream error',         // Z_STREAM_ERROR   (-2)
    'Data error',           // Z_DATA_ERROR     (-3)
    'Insufficient memory',  // Z_MEM_ERROR      (-4)
    'Buffer error',         // Z_BUF_ERROR      (-5)
    'Incompatible version', // Z_VERSION_ERROR  (-6)
    ''
  );

type
  TZAlloc = function (opaque: Pointer; items, size: Integer): Pointer;
  TZFree  = procedure (opaque, block: Pointer);

  {** TZStreamRec ***********************************************************}

  TZStreamRec = packed record
    next_in  : Pointer;   // next input byte
    avail_in : Longint;   // number of bytes available at next_in
    total_in : Longint;   // total nb of input bytes read so far

    next_out : Pointer;   // next output byte should be put here
    avail_out: Longint;   // remaining free space at next_out
    total_out: Longint;   // total nb of bytes output so far

    msg      : Pointer;   // last error message, NULL if no error
    state    : Pointer;   // not visible by applications

    zalloc   : TZAlloc;   // used to allocate the internal state
    zfree    : TZFree;    // used to free the internal state
    opaque   : Pointer;   // private data object passed to zalloc and zfree

    data_type: Integer;   // best guess about the data type: ascii or binary
    adler    : Longint;   // adler32 value of the uncompressed data
    reserved : Longint;   // reserved for future use
  end;
  TdeflateInit_=function(var strm:TZStreamRec;level:Integer;version:PAnsiChar;recsize:Integer):Integer;cdecl;
  TdeflateInit2_=function(var strm: TZStreamRec;level,method,windowBits,memLevel,strategy:Integer;version:PAnsiChar;recsize:Integer):Integer; cdecl;
  Tdeflate=function(var strm:TZStreamRec;flush:Integer):Integer; cdecl;
  TdeflateEnd_Reset=function(var strm:TZStreamRec):Integer; cdecl;
  TinflateInit_=function(var strm:TZStreamRec;version:PAnsiChar;recsize:Integer):Integer; cdecl;
  TinflateInit2_=function(var strm:TZStreamRec;windowBits:Integer;version:PAnsiChar;recsize:Integer):Integer; cdecl;
  Tinflate=function(var strm:TZStreamRec;flush:Integer):Integer; cdecl;
  Tadler32=function(adler:Longint;const buf;len:Integer):Longint; cdecl;
  Tcrc32=function(crc:Longint;const buf;len:Integer):Longint; cdecl;

  var
    deflateInit_:TdeflateInit_;
    deflateInit2_:TdeflateInit2_;
    deflate:Tdeflate;
    deflateEnd:TdeflateEnd_Reset;
    deflateReset:TdeflateEnd_Reset;
    inflateInit_:TinflateInit_;
    inflateInit2_:TinflateInit2_;
    inflate:Tinflate;
    inflateEnd:TdeflateEnd_Reset;
    inflateReset:TdeflateEnd_Reset;
    adler32:Tadler32;
    crc32:Tcrc32;

//Iniciar la DLL
procedure zlib_init_dll;
procedure close_zlib_dll;

{** macros ******************************************************************}

function deflateInit(var strm: TZStreamRec; level: Integer): Integer;
function deflateInit2(var strm: TZStreamRec; level, method, windowBits,memLevel, strategy: Integer): Integer;
function inflateInit(var strm: TZStreamRec): Integer;
function inflateInit2(var strm: TZStreamRec; windowBits: Integer): Integer;

implementation
uses ZLibEx;

procedure zlib_init_dll;
begin
{$ifdef darwin}
zlib_dll_Handle:=LoadLibrary('libz.dylib');
{$endif}
{$ifdef linux}
zlib_dll_Handle:=LoadLibrary('libz.so.1');
{$endif}
{$ifdef windows}
zlib_dll_Handle:=LoadLibrary('zlib1.dll');
{$endif}
if zlib_dll_Handle=0 then begin
  MessageDlg('Zlib library not found.'+chr(10)+chr(13)+'Please read the documentation!', mtError,[mbOk], 0);
  exit;
end;
@deflateInit_:=GetProcAddress(zlib_dll_Handle,'deflateInit_');
@deflateInit2_:=GetProcAddress(zlib_dll_Handle,'deflateInit2_');
@deflate:=GetProcAddress(zlib_dll_Handle,'deflate');
@deflateEnd:=GetProcAddress(zlib_dll_Handle,'deflateEnd');
@deflateReset:=GetProcAddress(zlib_dll_Handle,'deflateReset');
@inflateInit_:=GetProcAddress(zlib_dll_Handle,'inflateInit_');
@inflateInit2_:=GetProcAddress(zlib_dll_Handle,'inflateInit2_');
@inflate:=GetProcAddress(zlib_dll_Handle,'inflate');
@inflateEnd:=GetProcAddress(zlib_dll_Handle,'inflateEnd');
@inflateReset:=GetProcAddress(zlib_dll_Handle,'inflateReset');
@adler32:=GetProcAddress(zlib_dll_Handle,'adler32');
@crc32:=GetProcAddress(zlib_dll_Handle,'crc32');
end;

procedure close_zlib_dll;
begin
  if zlib_dll_handle<>0 then begin
    FreeLibrary(zlib_dll_Handle);
    zlib_dll_handle:=0;
  end;
end;


{*****************************************************************************
*  link zlib code                                                            *
*                                                                            *
*  to make in gcc use:                                                       *
*    make LOC=-DASMV OBJA=match.o -f makefile.gcc                            *
*****************************************************************************}

function _malloc(Size: Integer): Pointer; cdecl; [public, alias: '_malloc'];
begin
  Result:=AllocMem(Size);
end;

procedure _free(Block: Pointer); cdecl; [public, alias: '_free'];
begin
  FreeMem(Block);
end;

{** macros ******************************************************************}

function deflateInit(var strm: TZStreamRec; level: Integer): Integer;
begin
  result := deflateInit_(strm, level, ZLIB_VERSION, SizeOf(TZStreamRec));
end;

function deflateInit2(var strm: TZStreamRec; level, method, windowBits,
  memLevel, strategy: Integer): Integer;
begin
  result := deflateInit2_(strm, level, method, windowBits,
    memLevel, strategy, ZLIB_VERSION, SizeOf(TZStreamRec));
end;

function inflateInit(var strm: TZStreamRec): Integer;
begin
  result := inflateInit_(strm, ZLIB_VERSION, SizeOf(TZStreamRec));
end;

function inflateInit2(var strm: TZStreamRec; windowBits: Integer): Integer;
begin
  result := inflateInit2_(strm, windowBits, ZLIB_VERSION,
    SizeOf(TZStreamRec));
end;


{** zlib function implementations *******************************************}

function zcalloc(opaque: Pointer; items, size: Integer): Pointer;
begin
  GetMem(result,items * size);
end;

procedure zcfree(opaque, block: Pointer);
begin
  FreeMem(block);
end;

{** c function implementations **********************************************}

procedure _memset(p: Pointer; b: Byte; count: Integer); cdecl;
begin
  FillChar(p^,count,b);
end;

procedure _memcpy(dest, source: Pointer; count: Integer); cdecl;
begin
  Move(source^,dest^,count);
end;

end.