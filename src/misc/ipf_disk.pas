unit ipf_disk;

interface
uses windows;

function ipf_format(DrvNum:byte;longi_ini:dword;datos:pbyte):boolean;

var
  ipf_last_error:string;

implementation
uses SysUtils,disk_file_format;

type
  TBytesIPF=array of byte;
  TTrackIPF=record
    info,data:boolean;
    cylinder,head,density,signature,indexBits,trackBits,blocks,process:cardinal;
    dataBits,gapBits:cardinal;
    key,offset,size:cardinal;
  end;
  TTracksIPF=array of TTrackIPF;
  TMarkIPF=record pos:integer;kind:byte;end;
  TMarksIPF=array of TMarkIPF;
  TGapSample=record count,patternBits:integer;pattern:TBytesIPF;explicitCount:boolean;end;
  TGapSamples=array of TGapSample;
  EIPF=class(Exception);
  PDskIPF=^DskImg;
const MAX_CELLS=1048560; // <=65535 decoded MFM bytes, limited by DskImg
      MAX_FILE=64*1024*1024;

procedure require(ok:boolean;const reason:string);
begin
  if not ok then raise EIPF.Create(reason);
end;

function be32(const b:TBytesIPF;p:integer):cardinal;
begin
  require((p>=0) and (p<=Length(b)-4),'Truncated integer');
  Result:=(cardinal(b[p]) shl 24) or (cardinal(b[p+1]) shl 16) or
    (cardinal(b[p+2]) shl 8) or b[p+3];
end;

function bounded32(const b:TBytesIPF;p,maximum:integer):integer;
var
  v:cardinal;
begin
  v:=be32(b,p);
  require(v<=cardinal(maximum),'Numeric field exceeds supported limit');
  Result:=integer(v);
end;

function crc32(const b:TBytesIPF;p,n:integer;header:boolean):cardinal;
var
  i,j:integer;
  c,v:cardinal;
begin
  c:=$ffffffff;
  for i:=0 to n-1 do begin
    if header and (i>=8) and (i<12) then v:=0 else v:=b[p+i];
    c:=c xor v;
    for j:=1 to 8 do
      if (c and 1)<>0 then c:=(c shr 1) xor $edb88320 else c:=c shr 1;
  end;
  Result:=not c;
end;

function crc16add(c:word;v:byte):word;
var
  i:integer;
  x:cardinal;
begin
  x:=c xor (cardinal(v) shl 8);
  for i:=1 to 8 do if (x and $8000)<>0 then x:=((x shl 1) xor $1021) and $ffff
    else x:=(x shl 1) and $ffff;
  Result:=x;
end;

function trackIndex(var tracks:TTracksIPF;key:cardinal):integer;
var
  i:integer;
begin
  for i:=0 to High(tracks) do if tracks[i].key=key then begin
    Result:=i;
    exit;
  end;
  require(Length(tracks)<166,'Too many track descriptors');
  Result:=Length(tracks);
  SetLength(tracks,Result+1);
  tracks[Result].key:=key;
end;

procedure descriptor(const b:TBytesIPF;var p:integer;limit:integer;out kind:byte;out n:integer);
var
  v:byte;i,w:integer;x:uint64;
begin
  require(p<limit,'Missing stream terminator');
  v:=b[p];Inc(p);
  kind:=v and 31;
  w:=v shr 5;
  require(w<=limit-p,'Truncated stream parameter');
  x:=0;
  for i:=1 to w do begin
    x:=(x shl 8) or b[p];
    inc(p);
  end;
  require(x<=MAX_CELLS,'Stream parameter too large');
  n:=integer(x);
end;

procedure putRaw(var cells:TBytesIPF;var pos:integer;const b:TBytesIPF;p,bits:integer;var context:byte);
var
  i:integer;
begin
  require((bits>=0) and (bits<=Length(cells)-pos),'Raw data exceeds track');
  require((p>=0) and ((bits+7) div 8<=Length(b)-p),'Truncated raw data');
  for i:=0 to bits-1 do begin
    cells[pos]:=(b[p+i div 8] shr (7-i mod 8)) and 1;
    inc(pos);
  end;
  if bits>0 then context:=cells[pos-1];
end;

procedure putMFM(var cells:TBytesIPF;var pos:integer;const pattern:TBytesIPF;patternBits,start,cnt:integer;var context:byte);
var
  i,q:integer;
  v:byte;
begin
  require((cnt>=0) and (cnt<=Length(cells)-pos),'MFM data exceeds track');
  if cnt=0 then exit;
  require((patternBits>0) and ((patternBits+7) div 8<=Length(pattern)),'Empty gap pattern');
  for i:=0 to cnt-1 do begin
    q:=(start+i) mod (patternBits*2);
    if q<0 then inc(q,patternBits*2);
    v:=(pattern[q div 16] shr (7-(q div 2) mod 8)) and 1;
    if (q and 1)<>0 then begin
      cells[pos]:=v;
      context:=v;
    end else cells[pos]:=1-(context or v);
    inc(pos);
  end;
end;

procedure dataStream(const b:TBytesIPF;start,limit,wanted:integer;flags,encoder:cardinal;var cells:TBytesIPF;var pos:integer;var context:byte);
var
  p,n,bits,bytes,i,finish:integer;
  k:byte;
  pattern:TBytesIPF;
begin
  require((start>=0) and (start<limit),'Invalid data stream offset');
  p:=start;
  finish:=pos+wanted;
  require(finish<=Length(cells),'Invalid block size');
  repeat
    descriptor(b,p,limit,k,n);
    if k=0 then begin
      require(pos=finish,'Block stream length mismatch');
      exit;
    end;
    if (flags and 4)<>0 then bits:=n else begin
      require(n<=MAX_CELLS div 8,'Data length overflow');
      bits:=n*8;
    end;
    if k=4 then begin
      require(n<=MAX_CELLS div 8,'Raw length overflow');
      bits:=n*8;
    end;
    bytes:=(bits+7) div 8;
    case k of
      1,4:begin
        require(((k=1) and (encoder=1)) or ((k=4) and (encoder=2)),'Unsupported stream/encoder combination');
        require((bits<=finish-pos) and (bytes<=limit-p),'Truncated raw stream');
        putRaw(cells,pos,b,p,bits,context);
        inc(p,bytes);
      end;
      2,3:begin
        require(encoder=1,'MFM stream in raw block');
        require((bits<=(finish-pos) div 2) and (bytes<=limit-p),'Truncated MFM stream');
        SetLength(pattern,bytes);
        if bytes>0 then Move(b[p],pattern[0],bytes);
        putMFM(cells,pos,pattern,bits,0,bits*2,context);
        inc(p,bytes);
      end;
      5:begin
        require((encoder=1) and (bits<=(finish-pos) div 2),'Invalid weak region');
        for i:=1 to bits*2 do begin
          cells[pos]:=2;
          inc(pos);
        end;
        context:=0;
      end;
      else raise EIPF.Create('Unsupported data stream element');
    end;
  until false;
end;

procedure readGap(const b:TBytesIPF;var p:integer;limit:integer;out samples:TGapSamples);
var
  k:byte;
  n,count,idx:integer;
  haveCount:boolean;
begin
  SetLength(samples,0);
  count:=0;
  haveCount:=false;
  repeat
    descriptor(b,p,limit,k,n);
    if k=0 then begin
      require(not haveCount,'Gap length without pattern');
      exit;
    end;
    case k of
      1:begin
          require(not haveCount,'Duplicate gap length');
          require(n<=MAX_CELLS div 2,'Gap too large');
          count:=n*2;
          haveCount:=true;
        end;
      2:begin
          require((n+7) div 8<=limit-p,'Truncated gap pattern');
          require(Length(samples)<65536,'Too many gap samples');
          idx:=Length(samples);
          SetLength(samples,idx+1);
          samples[idx].patternBits:=n;
          samples[idx].count:=count;
          samples[idx].explicitCount:=haveCount;
          SetLength(samples[idx].pattern,(n+7) div 8);
          if n>0 then Move(b[p],samples[idx].pattern[0],(n+7) div 8);
          inc(p,(n+7) div 8);
          count:=0;
          haveCount:=false;
      end;
      else raise EIPF.Create('Unsupported gap stream element');
    end;
  until false;
end;

function fixedGap(const s:TGapSamples):integer;
var
  i:integer;v:int64;
begin
  v:=0;for i:=0 to High(s) do begin
    if s[i].explicitCount then v:=v+s[i].count;
  end;
  require(v<=MAX_CELLS,'Gap description too large');
  Result:=v;
end;

procedure renderGap(const s:TGapSamples;pre:boolean;wanted:integer;var cells:TBytesIPF;var pos:integer;var context:byte);
var
  i,n,remaining,reserved:integer;
begin
  remaining:=wanted;
  reserved:=fixedGap(s);
  for i:=0 to High(s) do begin
    n:=s[i].count;
    if pre then begin
      if i=High(s) then n:=remaining
      else if not s[i].explicitCount then n:=s[i].patternBits;
    end else begin
      if i=0 then begin
        if s[i].explicitCount then n:=wanted-(reserved-n)
          else n:=wanted-reserved;
      end;
    end;
    if n<0 then n:=0;
    if n>remaining then n:=remaining;
    if pre then putMFM(cells,pos,s[i].pattern,s[i].patternBits,0,n,context)
      else putMFM(cells,pos,s[i].pattern,s[i].patternBits,-n,n,context);
    dec(remaining,n);
  end;
  require(remaining=0,'Gap stream cannot fill requested length');
end;

procedure generateGap(const b:TBytesIPF;start,limit,count,mode,patternValue:integer;var cells:TBytesIPF;var pos:integer;var context:byte);
var
  a,z:TGapSamples;
  p,left,right,delta,excess,trim:integer;
  pattern:TBytesIPF;
begin
  if count=0 then exit;
  if mode=0 then begin
    SetLength(pattern,1);
    pattern[0]:=patternValue;
    left:=count div 2;
    delta:=count and 1;
    putMFM(cells,pos,pattern,8,0,left,context);
    if delta<>0 then begin
      cells[pos]:=0;
      inc(pos);
    end;
    putMFM(cells,pos,pattern,8,left+delta-count,count-left-delta,context);
    exit;
  end;
  require((start>=0) and (start<limit),'Invalid gap offset');
  p:=start;
  readGap(b,p,limit,a);
  case mode of
    1:renderGap(a,true,count,cells,pos,context);
    2:renderGap(a,false,count,cells,pos,context);
    3:begin
      readGap(b,p,limit,z);
      delta:=count and 1;
      left:=fixedGap(a);
      right:=fixedGap(z);
      excess:=left+right-(count-delta);
      if excess>0 then begin
        trim:=excess div 2;
        if trim>left then trim:=left;
        dec(left,trim);
        dec(excess,trim);
        trim:=excess;
        if trim>right then trim:=right;Dec(right,trim);
        dec(excess,trim);
        dec(left,excess);
      end;
      left:=left+(count-delta-left-right) div 2;
      renderGap(a,true,left,cells,pos,context);
      if delta<>0 then begin
        cells[pos]:=0;
        inc(pos);
      end;
      renderGap(z,false,count-left-delta,cells,pos,context);
    end;
    else raise EIPF.Create('Invalid gap mode');
  end;
end;

procedure makeCells(const b:TBytesIPF;const t:TTrackIPF;encoderType:cardinal;out cells,dataMask:TBytesIPF);
var
  i,h,p,start,dc,gc,limit:integer;
  flags,enc:cardinal;
  context:byte;
  size:int64;
  rotated:TBytesIPF;
  dataStart,j:integer;
begin
  if t.density=1 then begin
    SetLength(cells,t.trackBits);
    if Length(cells)>0 then FillChar(cells[0],Length(cells),2);
    exit;
  end;
  require((t.blocks>0) and (t.blocks<=t.size div 32),'Missing block table');
  limit:=t.offset+t.size;
  size:=0;
  for i:=0 to integer(t.blocks)-1 do begin
    h:=t.offset+i*32;
    dc:=bounded32(b,h,MAX_CELLS);
    gc:=bounded32(b,h+4,MAX_CELLS);
    if gc<8 then gc:=0;
    require((dc>=0) and (gc>=0),'Oversized block');
    size:=size+dc+gc;
  end;
  require((size>0) and (size<=MAX_CELLS),'Track exceeds disk-engine capacity');
  SetLength(cells,integer(size));
  SetLength(dataMask,integer(size));
  p:=0;
  context:=0;
  for i:=0 to integer(t.blocks)-1 do begin
    h:=t.offset+i*32;
    dc:=bounded32(b,h,MAX_CELLS);
    gc:=bounded32(b,h+4,MAX_CELLS);
    if gc<8 then gc:=0;
    enc:=be32(b,h+16);
    require((enc=1) or (enc=2),'Unsupported block encoder');
    if encoderType=1 then flags:=0
      else flags:=be32(b,h+20);
    require((flags and not cardinal(7))=0,'Unknown block flags');
    start:=bounded32(b,h+28,t.size);
    require((start>=integer(t.blocks)*32) and (start<=integer(t.size)),'Invalid data offset');
    dataStart:=p;
    if dc>0 then dataStream(b,t.offset+start,limit,dc,flags,enc,cells,p,context);
    for j:=dataStart to p-1 do dataMask[j]:=1;
    start:=bounded32(b,h+8,MAX_FILE);
    if (flags and 3)<>0 then require((start>=integer(t.blocks)*32) and (start<integer(t.size)),'Invalid gap offset');
    generateGap(b,t.offset+start,limit,gc,flags and 3,be32(b,h+24) and 255,cells,p,context);
  end;
  require(p=Length(cells),'Track length mismatch');
  require(t.indexBits<cardinal(Length(cells)),'Invalid index position');
  // IMGE startBitPos locates the generated stream relative to the index.
  if t.indexBits<>0 then begin
    SetLength(rotated,Length(cells));
    for i:=0 to High(cells) do rotated[(i+integer(t.indexBits)) mod Length(cells)]:=cells[i];
    cells:=rotated;
    rotated:=nil;
    SetLength(rotated,Length(dataMask));
    for i:=0 to High(dataMask) do rotated[(i+integer(t.indexBits)) mod Length(dataMask)]:=dataMask[i];
    dataMask:=rotated;
  end;
end;

function rawWord(const cells:TBytesIPF;p:integer):integer;
var
  i,v:integer;
begin
  v:=0;
  for i:=0 to 15 do begin
    v:=v shl 1;
    if cells[(p+i) mod Length(cells)]=1 then v:=v or 1;
  end;
  Result:=v;
end;

function decoded(const cells:TBytesIPF;p:integer;out mask:byte):byte;
var
  i:integer;c:byte;
begin
  Result:=0;
  mask:=0;
  for i:=0 to 7 do begin
    c:=cells[(p+i*2+1) mod Length(cells)];
    Result:=Result shl 1;
    mask:=mask shl 1;
    if c=1 then Result:=Result or 1
      else if c=2 then mask:=mask or 1;
  end;
end;

procedure extractSectors(const cells,dataMask:TBytesIPF;var track:track_type;var disk:DskImg);
var
  marks:TMarksIPF;
  payload,masks,output:TBytesIPF;
  i,j,n,k,h,idx,next,distance,size,variants,v,base,markpos,physicalCells,fieldBytes:integer;
  kind,mask,value:byte;
  crc:word;
  weak:boolean;
  sec:sector_info_type;
  seed:cardinal;
  shortField:boolean;
function getbyte(p:integer):byte;
var
  m:byte;
begin
  Result:=decoded(cells,p,m);
end;
function fieldCRC(p,count:integer):word;
var
  x:integer;
begin
  Result:=$ffff;
  for x:=1 to 3 do Result:=crc16add(Result,$a1);
  for x:=0 to count-1 do Result:=crc16add(Result,getbyte(p+x*16));
end;
begin
  if Length(cells)<160 then exit;
  i:=0;
  while i<Length(cells) do begin
    if (rawWord(cells,i)=$4489) and (rawWord(cells,i+16)=$4489) and (rawWord(cells,i+32)=$4489) then begin
      kind:=decoded(cells,i+48,mask);
      if (mask=0) and ((kind=$fe) or (kind=$fb) or (kind=$f8) or (kind=$f9) or (kind=$fa)) then begin
        n:=Length(marks);require(n<512,'Too many address marks');SetLength(marks,n+1);
        marks[n].pos:=i+48;marks[n].kind:=kind;Inc(i,48);
      end;
    end;
    Inc(i);
  end;
  for idx:=0 to High(marks) do if marks[idx].kind=$fe then begin
    require(track.number_sector<64,'More than 64 sectors on a track');
    FillChar(sec,SizeOf(sec),0);
    h:=marks[idx].pos;
    sec.track:=getbyte(h+16);
    sec.head:=getbyte(h+32);
    sec.sector:=getbyte(h+48);
    sec.sector_size:=getbyte(h+64);
    crc:=fieldCRC(h,5);
    if (getbyte(h+80)<>Hi(crc)) or (getbyte(h+96)<>Lo(crc)) then sec.status1:=$20;
    n:=Length(marks);next:=(idx+1) mod n;
    if (next=idx) or (marks[next].kind=$fe) then begin
      sec.status1:=sec.status1 or $01;
      sec.status2:=$01;
    end else begin
      require(sec.sector_size<=8,'Sector size not representable');
      size:=128 shl sec.sector_size;
      markpos:=marks[next].pos;
      k:=(next+1) mod n;
      distance:=(marks[k].pos-markpos+Length(cells)) mod Length(cells);
      // A field cannot consume the next sync/address mark or a whole revolution.
      if distance=0 then distance:=Length(cells);
      distance:=distance-48;
      // A protected disk may declare N=6 while writing only 6144 data
      // bytes and no CRC. Keep N, expose physical data and report DE/DD.
      physicalCells:=0;
      while (physicalCells<distance) and (dataMask[(markpos+physicalCells) mod Length(cells)]<>0) do inc(physicalCells);
      fieldBytes:=physicalCells div 16;
      require(fieldBytes>=1,'Data address mark outside data area');
      shortField:=(size+3)>fieldBytes;
      if shortField then begin
        size:=fieldBytes-1; // DAM is not sector payload.
        if size>=2 then begin
          crc:=fieldCRC(markpos,fieldBytes-2);
          if (getbyte(markpos+(fieldBytes-2)*16)=Hi(crc)) and (getbyte(markpos+(fieldBytes-1)*16)=Lo(crc)) then dec(size,2);
        end;
        require(size>0,'Empty protected sector');
      end;
      SetLength(payload,size);
      SetLength(masks,size);
      weak:=false;
      for j:=0 to size-1 do begin
        payload[j]:=decoded(cells,markpos+16+j*16,mask);
        masks[j]:=mask;
        weak:=weak or (mask<>0);
      end;
      crc:=fieldCRC(markpos,size+1);
      if shortField or weak or (getbyte(markpos+(size+1)*16)<>Hi(crc)) or (getbyte(markpos+(size+2)*16)<>Lo(crc)) then begin
        sec.status1:=sec.status1 or $20;
        sec.status2:=sec.status2 or $20;
      end;
      if (marks[next].kind and 2)=0 then sec.status2:=sec.status2 or $40;
      variants:=1;
      if weak then variants:=3;
      base:=Length(output);
      require(base+size*variants<=65535,'Sector variants exceed track capacity');
      sec.posicion_data:=base;
      sec.data_length:=size*variants;
      sec.multi:=weak;
      SetLength(output,base+size*variants);
      // Three complete copies; stable bits are preserved in every copy.
      seed:=$13579bdf xor cardinal(sec.sector);
      for v:=0 to variants-1 do for j:=0 to size-1 do begin
        seed:=seed xor (seed shl 13);
        seed:=seed xor (seed shr 17);
        seed:=seed xor (seed shl 5);
        value:=byte(seed and $ff);
        if v=0 then value:=0 else if v=1 then value:=$ff;
        output[base+v*size+j]:=payload[j] or (value and masks[j]);
      end;
      if weak then begin
        disk.cont_multi:=3;
        disk.max_multi:=3;
      end;
    end;
    track.sector[track.number_sector]:=sec;
    inc(track.number_sector);
  end;
  track.track_lenght:=Length(output);
  if Length(output)>0 then begin
    GetMem(track.data,Length(output));
    Move(output[0],track.data^,Length(output));
  end;
end;

procedure freeCandidate(disk:PDskIPF);
var
  s,t:integer;
begin
  if disk=nil then exit;
  for s:=0 to 1 do for t:=0 to 82 do if disk^.Tracks[s,t].data<>nil then begin
    FreeMem(disk^.Tracks[s,t].data);
    disk^.Tracks[s,t].data:=nil;
  end;
  Dispose(disk);
end;

function ipf_format(DrvNum:byte;longi_ini:dword;datos:pbyte):boolean;
var
  b,cells,dataMask:TBytesIPF;
  tracks:TTracksIPF;
  candidate:PDskIPF;
  p,size,idx,start,i,s,t,minTrack,maxTrack,minHead,maxHead:integer;
  key,encoder,revision:cardinal;
  name:ansistring;
  hasInfo,hasCAPS:boolean;
  used:array[0..1,0..82]of boolean;
begin
  Result:=false;
  ipf_last_error:='';
  candidate:=nil;
  try
    try
      require(DrvNum<=High(dsk),'Invalid drive');
      require(datos<>nil,'Nil input');
      require((longi_ini>=12) and (longi_ini<=MAX_FILE),'Invalid IPF file size');
      SetLength(b,longi_ini);
      Move(datos^,b[0],longi_ini);
      require((b[0]=Ord('C')) and (b[1]=Ord('A')) and (b[2]=Ord('P')) and (b[3]=Ord('S')),'Missing CAPS signature');
      p:=0;
      hasInfo:=false;
      hasCAPS:=false;
      encoder:=0;
      minTrack:=0;
      maxTrack:=0;
      minHead:=0;
      maxHead:=0;
      while p<Length(b) do begin
        start:=p;
        require(Length(b)-p>=12,'Truncated tag header');
        key:=be32(b,p+4);
        require((key>=12) and (key<=cardinal(Length(b)-p)),'Invalid tag size');
        size:=key;
        require(crc32(b,p,size,true)=be32(b,p+8),'IPF tag CRC mismatch');
        SetLength(name,4);
        for i:=0 to 3 do name[i+1]:=AnsiChar(b[p+i]);
        inc(p,size);
        if name='CAPS' then begin
          require((start=0) and (size=12) and not hasCAPS,'Invalid CAPS tag');
          hasCAPS:=true;
        end else if name='INFO' then begin
          require((size=96) and not hasInfo,'Invalid INFO tag');
          require(be32(b,start+12)=1,'Unsupported media type');
          encoder:=be32(b,start+16);
          revision:=be32(b,start+20);
          require(((encoder=1) or (encoder=2)) and (revision=1),'Unsupported IPF encoder');
          minTrack:=bounded32(b,start+36,82);
          maxTrack:=bounded32(b,start+40,82);
          minHead:=bounded32(b,start+44,1);
          maxHead:=bounded32(b,start+48,1);
          require((minTrack>=0) and (minTrack<=maxTrack) and (maxTrack<=82) and (minHead>=0) and (minHead<=maxHead) and (maxHead<=1),'Unsupported disk geometry');
          hasInfo:=true;
        end else if name='IMGE' then begin
          require(size=80,'Invalid IMGE tag');
          key:=be32(b,start+64);
          idx:=trackIndex(tracks,key);
          require(not tracks[idx].info,'Duplicate IMGE key');
          with tracks[idx] do begin
            cylinder:=be32(b,start+12);
            head:=be32(b,start+16);
            density:=be32(b,start+20);
            signature:=be32(b,start+24);
            indexBits:=be32(b,start+36);
            dataBits:=be32(b,start+40);
            gapBits:=be32(b,start+44);
            trackBits:=be32(b,start+48);
            blocks:=be32(b,start+52);
            process:=be32(b,start+56);
            info:=true;
          end;
        end else if name='DATA' then begin
          require(size=28,'Invalid DATA tag');
          key:=be32(b,start+24);
          idx:=trackIndex(tracks,key);
          require(not tracks[idx].data,'Duplicate DATA key');
          key:=be32(b,start+12);
          require(key<=cardinal(Length(b)-p),'Truncated DATA payload');
          require(be32(b,start+16)<=uint64(key)*8,'Invalid DATA bit length');
          require(crc32(b,p,key,false)=be32(b,start+20),'DATA CRC mismatch');
          tracks[idx].offset:=p;
          tracks[idx].size:=key;
          tracks[idx].data:=true;
          inc(p,key);
        end;
        // Other metadata tags are skipped using their already validated size.
      end;
      require(hasCAPS and hasInfo and (Length(tracks)>0),'Incomplete IPF image');
      New(candidate);
      FillChar(candidate^,SizeOf(DskImg),0);
      FillChar(used,SizeOf(used),0);
      candidate^.DiskHeader.nbof_tracks:=maxTrack+1;
      candidate^.DiskHeader.nbof_heads:=maxHead+1;
      candidate^.ImageName:=dsk[DrvNum].ImageName;
      candidate^.protegido:=true; // Sector writes cannot be saved losslessly as IPF.
      for idx:=0 to High(tracks) do begin
        require(tracks[idx].info,'DATA without IMGE');
        with tracks[idx] do begin
          require((cylinder>=cardinal(minTrack)) and (cylinder<=cardinal(maxTrack)) and (head>=cardinal(minHead)) and (head<=cardinal(maxHead)),'Track outside declared geometry');
          require((signature=1) and (process=0),'Unsupported track encoding');
          require((trackBits<=MAX_CELLS) and (density>=1) and (density<=9),'Unsupported track type');
        end;
        s:=tracks[idx].head;
        t:=tracks[idx].cylinder;
        require(not used[s,t],'Duplicate physical track');
        used[s,t]:=true;
        candidate^.Tracks[s,t].track_number:=t;
        candidate^.Tracks[s,t].side_number:=s;
        candidate^.Tracks[s,t].recording_mode:=2;
        candidate^.Tracks[s,t].data_rate:=1;
        if tracks[idx].trackBits=0 then continue;
        require(tracks[idx].data or (tracks[idx].density=1),'IMGE without DATA');
        makeCells(b,tracks[idx],encoder,cells,dataMask);
        if tracks[idx].density<>1 then begin
          extractSectors(cells,dataMask,candidate^.Tracks[s,t],candidate^);
          require(candidate^.Tracks[s,t].number_sector>0,'Track has no supported IBM MFM sectors');
        end;
      end;
      // Commit only after complete validation; failure preserves the old disk.
      clear_disk(DrvNum);
      candidate^.abierto:=true;
      dsk[DrvNum]:=candidate^;
      for s:=0 to 1 do for t:=0 to 82 do candidate^.Tracks[s,t].data:=nil;
      Result:=true;
    except
      on e:EIPF do ipf_last_error:=e.Message;
    end;
  finally
    freeCandidate(candidate);
  end;
end;

end.
