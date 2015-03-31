unit ppi8255;

interface
uses dialogs,sysutils;

type
  read_port_8255=function:byte;
  write_port_8255=procedure (valor:byte);
  tpia8255=record
    control:byte;
		m_group_a_mode:byte;
	  m_group_b_mode:byte;
	  m_port_a_dir:byte;
	  m_port_b_dir:byte;
	  m_port_ch_dir:byte;
	  m_port_cl_dir:byte;
	  m_obf_a:byte;
    m_ibf_a:byte;
	  m_obf_b:byte;
    m_ibf_b:byte;
	  m_inte_a:byte;
    m_inte_b:byte;
    m_inte_1:byte;
    m_inte_2:byte;
    m_control:byte;
	  m_in_mask,m_out_mask,m_read,m_latch,m_output:array[0..2] of byte;
    read_port:array[0..2] of read_port_8255;
    write_port:array[0..2] of write_port_8255;
  end;
  ptpia8255=^tpia8255;

var
  pia_8255:array[0..1] of ptpia8255;

procedure reset_ppi8255(num:byte);
procedure close_ppi8255(num:byte);
procedure init_ppi8255(num:byte;pread_port_a,pread_port_b,pread_port_c:read_port_8255;pwrite_port_a,pwrite_port_b,pwrite_port_c:write_port_8255);
function ppi8255_r(num,port:byte):byte;
procedure ppi8255_w(num,port,data:byte);
function ppi8255_get_port(num,port:byte):byte;
procedure ppi8255_set_port(num,port,data:byte);

implementation

procedure ppi8255_get_handshake_signals(num:byte;val:pbyte);
var
  pia:ptpia8255;
  handshake,mask:byte;
begin
  pia:=pia_8255[num];
	handshake:=$00;
	mask:=$00;
	// group A */
	if (pia.m_group_a_mode=1) then begin
		if (pia.m_port_a_dir<>0) then begin
			if (pia.m_ibf_a)<>0 then handshake:=handshake or $20
        else handshake:=handshake or $0;
      if ((pia.m_ibf_a<>0) and (pia.m_inte_a<>0)) then handshake:=handshake or $08;
			mask:=mask or $28;
		end	else begin
      if (pia.m_obf_a=0) then handshake:=handshake or $80
        else handshake:=handshake or $0;
      if ((pia.m_obf_a<>0) and (pia.m_inte_a<>0)) then handshake:=handshake or $08
        else handshake:=handshake or $0;
			mask:=mask or $88;
		end;
	end else if (pia.m_group_a_mode=2) then begin
    if (pia.m_obf_a<>0) then handshake:=handshake or $0
      else handshake:=handshake or $80;
    if (pia.m_ibf_a<>0) then handshake:=handshake or $20
      else handshake:=handshake or $0;
    if (((pia.m_obf_a<>0) and (pia.m_inte_1<>0)) or ((pia.m_ibf_a<>0) and (pia.m_inte_2<>0))) then handshake:=handshake or $08
      else handshake:=handshake or $0;
		mask:=mask or $a8;
	end;
	// group B */
	if (pia.m_group_b_mode=1) then begin
		if (pia.m_port_b_dir<>0) then begin
      if (pia.m_ibf_b<>0) then handshake:=handshake or $02;
      if ((pia.m_ibf_b<>0) and (pia.m_inte_b<>0)) then handshake:=handshake or $01;
			mask:=mask or $03;
		end else begin
      if (pia.m_obf_b=0) then handshake:=handshake or $02;
      if ((pia.m_obf_b<>0) and (pia.m_inte_b<>0)) then handshake:=handshake or $01;
			mask:=mask or $03;
		end;
	end;
	val^:=val^ and not(mask);
	val^:=val^ or (handshake and mask);
end;

procedure ppi8255_write_port(num,port:byte);
var
  pia:ptpia8255;
  write_data:byte;
begin
  pia:=pia_8255[num];
	write_data:=pia.m_latch[port] and pia.m_out_mask[port];
	write_data:=write_data or ($FF and not(pia.m_out_mask[port]));
	// write out special port 2 signals */
	if (port=2) then ppi8255_get_handshake_signals(num,@write_data);
	pia.m_output[port]:=write_data;
	if @pia.write_port[port]<>nil then pia.write_port[port](write_data);
end;

procedure ppi8255_input(num,port,data:byte);
var
  pia:ptpia8255;
  changed:boolean;
begin
  pia:=pia_8255[num];
	changed:=false;
	pia.m_read[port]:=data;
	// port C is special */
	if (port=2) then begin
		if (((pia.m_group_a_mode=1) and (pia.m_port_a_dir=0)) or (pia.m_group_a_mode=2)) then begin
			// is !ACKA asserted? */
			if ((pia.m_obf_a<>0) and ((not(data and $40))<>0)) then begin
				pia.m_obf_a:=0;
				changed:=true;
			end;
		end;
		if (((pia.m_group_a_mode=1) and (pia.m_port_a_dir=1)) or (pia.m_group_a_mode=2)) then begin
			// is !STBA asserted? */
			if ((pia.m_ibf_a=0) and ((not(data and $10))<>0)) then begin
				pia.m_ibf_a:=1;
				changed:=true;
			end;
		end;
		if ((pia.m_group_b_mode=1) and (pia.m_port_b_dir=0)) then begin
			// is !ACKB asserted? */
			if ((pia.m_obf_b<>0) and ((not(data and $04))<>0)) then begin
				pia.m_obf_b:=0;
				changed:=true;
			end;
		end;

		if ((pia.m_group_b_mode=1) and (pia.m_port_b_dir=1)) then begin
			// is !STBB asserted? */
			if ((pia.m_ibf_b=0) and ((not(data and $04))<>0)) then begin
				pia.m_ibf_b:=1;
				changed:=true;
			end;
		end;
		if changed then begin
			ppi8255_write_port(num,2);
		end;
	end;  //del if port2
end;

function ppi8255_read_port(num,port:byte):byte;
var
  pia:ptpia8255;
  res:byte;
begin
  pia:=pia_8255[num];
	res:=$00;
	if (pia.m_in_mask[port]<>0) then begin
    if @pia.read_port[port]<>nil then ppi8255_input(num,port,pia.read_port[port]);
		res:=res or (pia.m_read[port] and pia.m_in_mask[port]);
	end;
	res:=res or (pia.m_latch[port] and pia.m_out_mask[port]);
	case port of
	  0:pia.m_ibf_a:=0; // clear input buffer full flag */
    1:pia.m_ibf_b:=0; // clear input buffer full flag */
	  2:ppi8255_get_handshake_signals(num,@res); // read special port 2 signals
	end;
  ppi8255_read_port:=res;
end;

procedure set_mode(num,data:byte;call_handlers:boolean);
var
  pia:ptpia8255;
  f:byte;
begin
  pia:=pia_8255[num];
	// parse out mode */
	pia.m_group_a_mode:=(data shr 5) and 3;
	pia.m_group_b_mode:=(data shr 2) and 1;
	pia.m_port_a_dir:=(data shr 4) and 1;
	pia.m_port_b_dir:=(data shr 1) and 1;
	pia.m_port_ch_dir:=(data shr 3) and 1;
	pia.m_port_cl_dir:=(data shr 0) and 1;
	// normalize group_a_mode */
	if (pia.m_group_a_mode=3) then pia.m_group_a_mode:=2;
	// Port A direction */
	if (pia.m_group_a_mode=2) then begin
		pia.m_in_mask[0]:=$FF;
		pia.m_out_mask[0]:=$FF;	//bidirectional */
	end else begin
		if (pia.m_port_a_dir<>0) then begin
			pia.m_in_mask[0]:=$FF;
			pia.m_out_mask[0]:=$00;	// input */
		end else begin
			pia.m_in_mask[0]:=$00;
			pia.m_out_mask[0]:=$FF;	// output */
		end;
	end;
	// Port B direction */
	if (pia.m_port_b_dir<>0) then begin
		pia.m_in_mask[1]:=$FF;
		pia.m_out_mask[1]:=$00;	// input */
	end else begin
		pia.m_in_mask[1]:=$00;
		pia.m_out_mask[1]:=$FF;	// output */
	end;
	// Port C upper direction */
	if (pia.m_port_ch_dir<>0) then begin
		pia.m_in_mask[2]:=$F0;
		pia.m_out_mask[2]:=$00;	// input */
	end else begin
		pia.m_in_mask[2]:=$00;
		pia.m_out_mask[2]:=$F0;	// output */
	end;
	// Port C lower direction */
	if (pia.m_port_cl_dir<>0) then pia.m_in_mask[2]:=pia.m_in_mask[2] or $0F	// input */
	  else pia.m_out_mask[2]:=pia.m_out_mask[2] or $0F;	// output */
	// now depending on the group modes, certain Port C lines may be replaced
  //   * with varying control signals
	case pia.m_group_a_mode of
		0:;	// Group A mode 0 no changes */
		1:begin	// Group A mode 1 bits 5-3 are reserved by Group A mode 1
			  pia.m_in_mask[2]:=pia.m_in_mask[2] and $c7;
			  pia.m_out_mask[2]:=pia.m_out_mask[2] and $c7;
			end;
		2:begin // Group A mode 2 bits 7-3 are reserved by Group A mode 2
			  pia.m_in_mask[2]:=pia.m_in_mask[2] and $07;
			  pia.m_out_mask[2]:=pia.m_out_mask[2] and $07;
			end;
	end;
	case pia.m_group_b_mode of
		0:;	// Group B mode 0 no changes */
    1:begin	// Group B mode 1 bits 2-0 are reserved by Group B mode 1 */
			  pia.m_in_mask[2]:=pia.m_in_mask[2] and $F8;
			  pia.m_out_mask[2]:=pia.m_out_mask[2] and $F8;
			end;
	end;
	// KT: 25-Dec-99 - 8255 resets latches when mode set */
	pia.m_latch[0]:=0;
  pia.m_latch[1]:=0;
  pia.m_latch[2]:=0;
	if call_handlers then
		for f:=0 to 2 do ppi8255_write_port(num,f);
	// reset flip-flops */
	pia.m_obf_a:=0;
  pia.m_ibf_a:=0;
	pia.m_obf_b:=0;
  pia.m_ibf_b:=0;
	pia.m_inte_a:=0;
  pia.m_inte_b:=0;
  pia.m_inte_1:=0;
  pia.m_inte_2:=0;
	// store control word */
	pia.m_control:=data;
end;

procedure reset_ppi8255(num:byte);
var
  pia:ptpia8255;
  f:byte;
begin
  pia:=pia_8255[num];
  pia.m_group_a_mode:=0;
	pia.m_group_b_mode:=0;
	pia.m_port_a_dir:=0;
	pia.m_port_b_dir:=0;
	pia.m_port_ch_dir:=0;
	pia.m_port_cl_dir:=0;
	pia.m_obf_a:=0;
  pia.m_ibf_a:=0;
	pia.m_obf_b:=0;
  pia.m_ibf_b:=0;
	pia.m_inte_a:=0;
  pia.m_inte_b:=0;
  pia.m_inte_1:=0;
  pia.m_inte_2:=0;
	for f:=0 to 2 do begin
		pia.m_in_mask[f]:=0;
    pia.m_out_mask[f]:=0;
    pia.m_read[f]:=0;
    pia.m_latch[f]:=0;
    pia.m_output[f]:=0;
	end;
	set_mode(num,$9b,false);
end;

procedure close_ppi8255(num:byte);
var
  pia:ptpia8255;
begin
 if pia_8255[num]=nil then exit;
 pia:=pia_8255[num];
 pia.read_port[0]:=nil;
 pia.read_port[1]:=nil;
 pia.read_port[2]:=nil;
 pia.write_port[0]:=nil;
 pia.write_port[1]:=nil;
 pia.write_port[2]:=nil;
 freemem(pia_8255[num]);
 pia_8255[num]:=nil;
end;

procedure init_ppi8255(num:byte;pread_port_a,pread_port_b,pread_port_c:read_port_8255;pwrite_port_a,pwrite_port_b,pwrite_port_c:write_port_8255);
var
  pia:ptpia8255;
begin
  getmem(pia_8255[num],sizeof(tpia8255));
  pia:=pia_8255[num];
  fillchar(pia^,sizeof(tpia8255),0);
  pia.read_port[0]:=pread_port_a;
  pia.read_port[1]:=pread_port_b;
  pia.read_port[2]:=pread_port_c;
  pia.write_port[0]:=pwrite_port_a;
  pia.write_port[1]:=pwrite_port_b;
  pia.write_port[2]:=pwrite_port_c;
end;

function ppi8255_r(num,port:byte):byte;
var
  pia:ptpia8255;
  res:byte;
begin
  pia:=pia_8255[num];
	res:=0;
  port:=port and $3;
	case port of
		0,1,2:res:=ppi8255_read_port(num,port); // Port A,B,C read */
		3:res:=pia.m_control; // Control word */
	end;
  ppi8255_r:=res;
end;

procedure ppi8255_w(num,port,data:byte);
var
  pia:ptpia8255;
  bit:byte;
begin
  pia:=pia_8255[num];
	port:=port mod 4;
	case port of
		0,1,2:begin // Port A,B,C write
			  pia.m_latch[port]:=data;
			  ppi8255_write_port(num,port);
			  case port of
				0:if ((pia.m_port_a_dir=0) and (pia.m_group_a_mode<>0)) then begin
						pia.m_obf_a:=1;
						ppi8255_write_port(num,2);
					end;
				1:if ((pia.m_port_b_dir=0) and (pia.m_group_b_mode<>0)) then begin
						pia.m_obf_b:=1;
						ppi8255_write_port(num,2);
					end;
        end;
      end;
		3:begin // Control word */
      pia.control:=data;
			if (data and $80)<>0 then begin
				set_mode(num,data and $7f,true);
			end else begin
				// bit set/reset */
				bit:=(data shr 1) and $07;
				if (data and 1)<>0 then pia.m_latch[2]:=pia.m_latch[2] or (1 shl bit)	// set bit */
				  else pia.m_latch[2]:=pia.m_latch[2] and (not(1 shl bit));	// reset bit */
				if (pia.m_group_b_mode=1) then
					if (bit=2) then pia.m_inte_b:=data and 1;
				if (pia.m_group_a_mode=1) then begin
					if ((bit=4) and (pia.m_port_a_dir<>0)) then pia.m_inte_a:=data and 1;
					if ((bit=6) and (pia.m_port_a_dir=0)) then pia.m_inte_a:=data and 1;
				end;
				if (pia.m_group_a_mode=2) then begin
					if (bit=4) then pia.m_inte_2:=data and 1;
					if (bit=6) then pia.m_inte_1:=data and 1;
        end;
				ppi8255_write_port(num,2);
			end;
    end;
	end;  //del case
end;

function ppi8255_get_port(num,port:byte):byte;
begin
  ppi8255_get_port:=pia_8255[num].m_output[port];
end;

procedure ppi8255_set_port(num,port,data:byte);
begin
  ppi8255_input(num,port,data);
end;

end.
