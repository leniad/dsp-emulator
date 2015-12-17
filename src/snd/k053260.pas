unit k053260;

interface
function k053260_main_read(direccion:byte):byte;
procedure k053260_main_write(direccion,valor:byte);
function k053260_read(direccion:byte):byte;
procedure k053260_write(direccion,valor:byte);

implementation
var
  portdata:array[0..3] of byte;

function k053260_main_read(direccion:byte):byte;
begin
  k053260_main_read:=portdata[2+(direccion and 1)];
end;

procedure k053260_main_write(direccion,valor:byte);
begin
  portdata[direccion and 1]:=valor;
end;

function k053260_read(direccion:byte):byte;
var
  ret:byte;
begin
	direccion:=direccion and $3f;
	ret:=0;
	case direccion of
		$00,$01:ret:=portdata[direccion]; // main-to-sub ports
		$29:begin // voice status
			//m_stream->update();
			//for (int i = 0; i < 4; i++) ret |= m_voice[i].playing() << i;
        end;
		$2e:begin // read ROM
			    //if (m_mode & 1) ret = m_voice[0].read_rom();
        end;
  end;
	k053260_read:=ret;
end;


procedure k053260_write(direccion,valor:byte);
begin
	direccion:=direccion and $3f;
	//m_stream->update();
	// per voice registers
	if ((direccion>=$08) and (direccion<=$27)) then begin
		//m_voice[(offset - 8) / 8].set_register(offset, data);
		exit;
	end;
	case direccion of
		// 0x00 and 0x01 are read registers
    $02,$03:portdata[direccion]:=valor; // sub-to-main ports
		// 0x04 through 0x07 seem to be unused
    $28:begin // key on/off
		{
			UINT8 rising_edge = data & ~m_keyon;

			for (int i = 0; i < 4; i++)
			{
				if (rising_edge & (1 << i))
					m_voice[i].key_on();
				else if (!(data & (1 << i)))
					m_voice[i].key_off();
			}
			//m_keyon = data;
			//break;
		  //}
      end;
		// 0x29 is a read register

{		case 0x2a: // loop and pcm/adpcm select
			for (int i = 0; i < 4; i++)
			{
				m_voice[i].set_loop_kadpcm(data);
				data >>= 1;
			}
 //			break;

		// 0x2b seems to be unused

 {		case 0x2c: // pan, voices 0 and 1
			m_voice[0].set_pan(data);
			m_voice[1].set_pan(data >> 3);
			break;

		case 0x2d: // pan, voices 2 and 3
			m_voice[2].set_pan(data);
			m_voice[3].set_pan(data >> 3);
			break;

		// 0x2e is a read register

		case 0x2f: // control
			m_mode = data;
			// bit 0 = enable ROM read from register 0x2e
			// bit 1 = enable sound output
			// bit 2 = enable aux input?
			//   (set by all games except Golfing Greats and Rollergames, both of which
			//    don't have a YM2151. Over Drive only sets it on one of the two chips)
			// bit 3 = aux input or ROM sharing related?
			//   (only set by Over Drive, and only on the same chip that bit 2 is set on)
			break;

		default:
			logerror("%s: Write to unknown K053260 register %02x (data = %02x)\n",
					machine().describe_context(), offset, data);
	}
//}
end;
end;


end.
