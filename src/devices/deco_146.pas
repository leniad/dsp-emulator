unit deco_146;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     misc_functions,controls_engine,hu6280,main_engine,deco_common;

const
  INPUT_PORT_A=-1;
  INPUT_PORT_B=-2;
  INPUT_PORT_C=-3;
type
  ram_type=record
    wo:integer;
	  m:array[0..15] of byte;
	  ux,un:boolean;
  end;

  cpu_deco_146=class
      constructor create;
      destructor free;
    public
      procedure set_interface_scramble(a9,a8,a7,a6,a5,a4,a3,a2,a1,a0:byte);
      procedure set_interface_scramble_reverse;
      procedure set_interface_scramble_interleave;
      procedure set_use_magic_address_xor;
      function read_data(address:word;var csflags:byte):word;
      procedure reset;
      procedure write_data(address,data:word;var csflags:byte);
    protected
      internal_ram:array[0..$3ff] of ram_type;
      bankswitch_swap_read_address,xor_port,mask_port,soundlatch_port,configregion:byte;
      magic_read_address_xor:word;
	    magic_read_address_xor_enabled:boolean;
    private
      external_addrswap:array[0..9] of byte;
      region_selects:array[0..5] of byte;
	    current_rambank,m_latchflag:byte;
	    m_nand,m_xor,m_latchaddr,m_latchdata:word;
      rambank0,rambank1:array[0..$7f] of word;
      procedure write_protport(address,data:word);
      function read_data_getloc(address:word;var location:integer):word;
      function read_protport(address:word):word;
    end;

var
  main_deco146:cpu_deco_146;

implementation
const
  deco_146ram:array[0..$3ff] of ram_type=(
(wo:$08a;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:true), //0x000
(wo:$0aa;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$00,$01,$02,$03,$04,$05,$06,$07);ux:false;un:false), //0x002
(wo:$018;m:($0a,$0b,$08,$09,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x004
(wo:$03c;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x006
(wo:$0bc;m:($01,$02,$03,$00,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:true), //0x008
(wo:$00e;m:($06,$07,$04,$05,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:true;un:false), //0x00a
(wo:$09a;m:($0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x00c
(wo:$000;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x00e
(wo:$00c;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x010
(wo:$006;m:($0e,$0f,$0c,$0d,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x012
(wo:$0e6;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07,$00,$01,$02,$03);ux:false;un:false), //0x014
(wo:$09c;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x016
(wo:$05e;m:($00,$01,$02,$03,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b);ux:true;un:true), //0x018
(wo:$0de;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x01a
(wo:$002;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x01c
(wo:$0f4;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:true), //0x01e
(wo:$036;m:($00,$01,$02,$03,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07);ux:true;un:false), //0x020
(wo:$070;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:true;un:true), //0x022
(wo:INPUT_PORT_C;m:($02,$03,$00,$01,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:true), //0x024
(wo:$030;m:($00,$01,$02,$03,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$04,$05,$06,$07);ux:false;un:false), //0x026
(wo:$06a;m:($04,$05,$06,$07,$00,$01,$02,$03,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b);ux:false;un:false), //0x028
(wo:$0c0;m:($07,$04,$05,$06,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:true;un:false), //0x02a
(wo:$01c;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x02c
(wo:$0ec;m:($09,$0a,$0b,$08,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:true;un:false), //0x02e
(wo:$090;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x030
(wo:$0f0;m:($06,$07,$04,$05,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:true), //0x032
(wo:$020;m:($07,$04,$05,$06,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:false;un:false), //0x034
(wo:$082;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:true;un:false), //0x036
(wo:$0a0;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:true;un:false), //0x038
(wo:$078;m:($0f,$0c,$0d,$0e,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:true;un:true), //0x03a
(wo:$0be;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x03c
(wo:$066;m:($04,$05,$06,$07,$00,$01,$02,$03,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x03e
(wo:$0c8;m:($09,$0a,$0b,$08,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:false;un:true), //0x040
(wo:$0ce;m:($00,$01,$02,$03,$0c,$0d,$0e,$0f,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:true;un:false), //0x042
(wo:INPUT_PORT_B;m:($02,$03,$00,$01,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x044
(wo:INPUT_PORT_B;m:($00,$01,$02,$03,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x046
(wo:$0f6;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:false;un:true), //0x048
(wo:$0f8;m:($00,$01,$02,$03,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$04,$05,$06,$07);ux:false;un:true), //0x04a
(wo:$0cc;m:($07,$04,$05,$06,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:false), //0x04c
(wo:$014;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x04e
(wo:INPUT_PORT_A;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x050
(wo:$0de;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:true), //0x052
(wo:$060;m:($00,$01,$02,$03,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07);ux:false;un:true), //0x054
(wo:$012;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$04,$05,$06,$07,$00,$01,$02,$03);ux:true;un:false), //0x056
(wo:$0a2;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x058
(wo:$06c;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:true;un:false), //0x05a
(wo:$076;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x05c
(wo:INPUT_PORT_A;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:true), //0x05e
(wo:$0dc;m:($0c,$0d,$0e,$0f,$00,$01,$02,$03,$08,$09,$0a,$0b,$04,$05,$06,$07);ux:true;un:true), //0x060
(wo:$054;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x062
(wo:$05a;m:($04,$05,$06,$07,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$08,$09,$0a,$0b);ux:true;un:false), //0x064
(wo:INPUT_PORT_A;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x066
(wo:$0e0;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:false;un:true), //0x068
(wo:$0d4;m:($0e,$0f,$0c,$0d,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:false), //0x06a
(wo:$054;m:($04,$05,$06,$07,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$08,$09,$0a,$0b);ux:true;un:true), //0x06c
(wo:$0fc;m:($0d,$0e,$0f,$0c,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x06e
(wo:$07e;m:($06,$07,$04,$05,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:false;un:false), //0x070
(wo:$03e;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:true), //0x072
(wo:$0c6;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$08,$09,$0a,$0b);ux:true;un:true), //0x074
(wo:$078;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$04,$05,$06,$07,$00,$01,$02,$03);ux:true;un:true), //0x076
(wo:$07c;m:($ff,$ff,$ff,$ff,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07);ux:false;un:true), //0x078
(wo:$00e;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x07a
(wo:$09c;m:($0a,$0b,$08,$09,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x07c
(wo:$074;m:($08,$09,$0a,$0b,$00,$01,$02,$03,$04,$05,$06,$07,$0c,$0d,$0e,$0f);ux:false;un:false), //0x07e
(wo:INPUT_PORT_B;m:($00,$01,$02,$03,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x080
(wo:$044;m:($0a,$0b,$08,$09,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:true;un:true), //0x082
(wo:$0c4;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:true;un:true), //0x084
(wo:$0be;m:($0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x086
(wo:$04e;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x088
(wo:$0b2;m:($05,$06,$07,$04,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:true), //0x08a
(wo:$04e;m:($0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:true;un:true), //0x08c
(wo:$052;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$08,$09,$0a,$0b);ux:false;un:false), //0x08e
(wo:$04a;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x090
(wo:INPUT_PORT_B;m:($04,$05,$06,$07,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x092
(wo:$02c;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x094
(wo:$000;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x096
(wo:$076;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x098
(wo:$014;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x09a
(wo:$094;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$00,$01,$02,$03,$0c,$0d,$0e,$0f);ux:false;un:false), //0x09c
(wo:$0ac;m:($0c,$0d,$0e,$0f,$04,$05,$06,$07,$08,$09,$0a,$0b,$00,$01,$02,$03);ux:false;un:true), //0x09e
(wo:$0a4;m:($0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:true;un:false), //0x0a0
(wo:$098;m:($07,$04,$05,$06,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:false;un:true), //0x0a2
(wo:$02c;m:($02,$03,$00,$01,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:true), //0x0a4
(wo:$0d8;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x0a6
(wo:$0d2;m:($06,$07,$04,$05,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:true;un:true), //0x0a8
(wo:$0fe;m:($03,$00,$01,$02,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x0aa
(wo:INPUT_PORT_C;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x0ac
(wo:$062;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07,$00,$01,$02,$03);ux:true;un:false), //0x0ae
(wo:$00c;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$00,$01,$02,$03,$04,$05,$06,$07);ux:true;un:false), //0x0b0
(wo:$078;m:($0e,$0f,$0c,$0d,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:true;un:false), //0x0b2
(wo:$046;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x0b4
(wo:$0c6;m:($0e,$0f,$0c,$0d,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:true;un:false), //0x0b6
(wo:$03a;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x0b8
(wo:$0f2;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:false;un:false), //0x0ba
(wo:$0e2;m:($0e,$0f,$0c,$0d,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x0bc
(wo:INPUT_PORT_B;m:($08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x0be
(wo:$096;m:($0e,$0f,$0c,$0d,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x0c0
(wo:INPUT_PORT_C;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:false), //0x0c2
(wo:$056;m:($0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x0c4
(wo:$09e;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:false;un:false), //0x0c6
(wo:$05c;m:($0a,$0b,$08,$09,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x0c8
(wo:$028;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x0ca
(wo:$0da;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:true;un:false), //0x0cc
(wo:$0b4;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x0ce
(wo:$0a6;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:true;un:true), //0x0d0
(wo:$0a6;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x0d2
(wo:$06c;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x0d4
(wo:$064;m:($00,$01,$02,$03,$0c,$0d,$0e,$0f,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:false), //0x0d6
(wo:INPUT_PORT_C;m:($01,$02,$03,$00,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:true), //0x0d8
(wo:$0e4;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:false;un:true), //0x0da
(wo:$048;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x0dc
(wo:$0ee;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:true;un:true), //0x0de
(wo:$024;m:($01,$02,$03,$00,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x0e0
(wo:$0aa;m:($0d,$0e,$0f,$0c,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:true;un:false), //0x0e2
(wo:$004;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$00,$01,$02,$03,$0c,$0d,$0e,$0f);ux:false;un:false), //0x0e4
(wo:$0c2;m:($0f,$0c,$0d,$0e,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x0e6
(wo:$0ae;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:false;un:false), //0x0e8
(wo:$02a;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x0ea
(wo:$05e;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x0ec
(wo:$078;m:($0b,$08,$09,$0a,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:true;un:false), //0x0ee
(wo:$072;m:($00,$01,$02,$03,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b);ux:false;un:true), //0x0f0
(wo:$016;m:($0d,$0e,$0f,$0c,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x0f2
(wo:$02e;m:($0c,$0d,$0e,$0f,$00,$01,$02,$03,$08,$09,$0a,$0b,$04,$05,$06,$07);ux:true;un:false), //0x0f4
(wo:$042;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x0f6
(wo:$068;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:true;un:false), //0x0f8
(wo:$042;m:($0f,$0c,$0d,$0e,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:false), //0x0fa
(wo:$034;m:($0d,$0e,$0f,$0c,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x0fc
(wo:INPUT_PORT_A;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:false;un:false), //0x0fe
(wo:$008;m:($07,$04,$05,$06,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:true;un:true), //0x100
(wo:$0a2;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x102
(wo:$0c8;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x104
(wo:$07a;m:($05,$06,$07,$04,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:true;un:false), //0x106
(wo:$050;m:($06,$07,$04,$05,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:true;un:false), //0x108
(wo:$01e;m:($08,$09,$0a,$0b,$00,$01,$02,$03,$04,$05,$06,$07,$0c,$0d,$0e,$0f);ux:true;un:false), //0x10a
(wo:$0ca;m:($ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:false;un:false), //0x10c
(wo:$05a;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x10e
(wo:$090;m:($0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x110
(wo:$052;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x112
(wo:$0ba;m:($06,$07,$04,$05,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:false;un:true), //0x114
(wo:$0c0;m:($0a,$0b,$08,$09,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:false;un:false), //0x116
(wo:INPUT_PORT_C;m:($02,$03,$00,$01,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:false), //0x118
(wo:$02a;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x11a
(wo:$032;m:($0b,$08,$09,$0a,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x11c
(wo:$026;m:($05,$06,$07,$04,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:false;un:false), //0x11e
(wo:$0e0;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x120
(wo:$0d6;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07,$00,$01,$02,$03);ux:true;un:true), //0x122
(wo:$0a8;m:($00,$01,$02,$03,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$04,$05,$06,$07);ux:true;un:false), //0x124
(wo:$0d0;m:($0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x126
(wo:$080;m:($09,$0a,$0b,$08,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:false;un:false), //0x128
(wo:$078;m:($0f,$0c,$0d,$0e,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:true), //0x12a
(wo:$06e;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:false), //0x12c
(wo:$092;m:($0e,$0f,$0c,$0d,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x12e
(wo:$040;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x130
(wo:$0ea;m:($0a,$0b,$08,$09,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:true;un:false), //0x132
(wo:$086;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x134
(wo:$01c;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x136
(wo:$010;m:($04,$05,$06,$07,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$08,$09,$0a,$0b);ux:false;un:false), //0x138
(wo:$038;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:false;un:false), //0x13a
(wo:$08e;m:($00,$01,$02,$03,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b);ux:false;un:false), //0x13c
(wo:$04c;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x13e
(wo:$084;m:($0c,$0d,$0e,$0f,$00,$01,$02,$03,$08,$09,$0a,$0b,$04,$05,$06,$07);ux:false;un:false), //0x140
(wo:$028;m:($0d,$0e,$0f,$0c,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:true;un:true), //0x142
(wo:$0b8;m:($06,$07,$04,$05,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:false), //0x144
(wo:$022;m:($0b,$08,$09,$0a,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x146
(wo:$046;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x148
(wo:$08c;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:false), //0x14a
(wo:$0fa;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$00,$01,$02,$03,$0c,$0d,$0e,$0f);ux:true;un:false), //0x14c
(wo:$0b4;m:($08,$09,$0a,$0b,$00,$01,$02,$03,$04,$05,$06,$07,$0c,$0d,$0e,$0f);ux:true;un:true), //0x14e
(wo:$0f0;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x150
(wo:$018;m:($04,$05,$06,$07,$00,$01,$02,$03,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:false), //0x152
(wo:$088;m:($0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x154
(wo:$058;m:($0f,$0c,$0d,$0e,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:true), //0x156
(wo:$032;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x158
(wo:$0a0;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x15a
(wo:$0e8;m:($0c,$0d,$0e,$0f,$04,$05,$06,$07,$08,$09,$0a,$0b,$00,$01,$02,$03);ux:true;un:false), //0x15c
(wo:$04c;m:($0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x15e
(wo:$03a;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:true;un:true), //0x160
(wo:$0b2;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:false;un:true), //0x162
(wo:$086;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:true;un:false), //0x164
(wo:$078;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$00,$01,$02,$03,$0c,$0d,$0e,$0f);ux:false;un:true), //0x166
(wo:$0e6;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07,$00,$01,$02,$03);ux:false;un:true), //0x168
(wo:$028;m:($04,$05,$06,$07,$00,$01,$02,$03,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b);ux:true;un:false), //0x16a
(wo:$026;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$00,$01,$02,$03,$0c,$0d,$0e,$0f);ux:false;un:true), //0x16c
(wo:INPUT_PORT_B;m:($0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x16e
(wo:$02a;m:($08,$09,$0a,$0b,$00,$01,$02,$03,$04,$05,$06,$07,$0c,$0d,$0e,$0f);ux:false;un:true), //0x170
(wo:$086;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x172
(wo:$022;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x174
(wo:$010;m:($02,$03,$00,$01,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x176
(wo:$082;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:false), //0x178
(wo:$02c;m:($0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:false), //0x17a
(wo:$0aa;m:($06,$07,$04,$05,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:true;un:true), //0x17c
(wo:$056;m:($05,$06,$07,$04,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:true;un:true), //0x17e
(wo:$0ec;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x180
(wo:$098;m:($0a,$0b,$08,$09,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x182
(wo:$0e2;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x184
(wo:$09e;m:($00,$01,$02,$03,$0c,$0d,$0e,$0f,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:true;un:true), //0x186
(wo:$0da;m:($02,$03,$00,$01,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:true), //0x188
(wo:$0a2;m:($00,$01,$02,$03,$0c,$0d,$0e,$0f,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:true), //0x18a
(wo:$0c2;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x18c
(wo:$01e;m:($0c,$0d,$0e,$0f,$04,$05,$06,$07,$08,$09,$0a,$0b,$00,$01,$02,$03);ux:false;un:false), //0x18e
(wo:$02e;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$00,$01,$02,$03,$0c,$0d,$0e,$0f);ux:true;un:true), //0x190
(wo:$062;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x192
(wo:$002;m:($0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:true), //0x194
(wo:$072;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$00,$01,$02,$03,$0c,$0d,$0e,$0f);ux:false;un:true), //0x196
(wo:$076;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$00,$01,$02,$03,$0c,$0d,$0e,$0f);ux:true;un:false), //0x198
(wo:$0e0;m:($0d,$0e,$0f,$0c,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:false), //0x19a
(wo:$064;m:($0b,$08,$09,$0a,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:true;un:true), //0x19c
(wo:INPUT_PORT_C;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:true), //0x19e
(wo:INPUT_PORT_A;m:($0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:false), //0x1a0
(wo:$078;m:($0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:false), //0x1a2
(wo:$07e;m:($0f,$0c,$0d,$0e,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:true;un:false), //0x1a4
(wo:$004;m:($01,$02,$03,$00,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:false), //0x1a6
(wo:$0ac;m:($04,$05,$06,$07,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$08,$09,$0a,$0b);ux:false;un:true), //0x1a8
(wo:$0b6;m:($02,$03,$00,$01,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:false), //0x1aa
(wo:$09c;m:($00,$01,$02,$03,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07);ux:false;un:false), //0x1ac
(wo:$006;m:($0b,$08,$09,$0a,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x1ae
(wo:$0c4;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$04,$05,$06,$07,$00,$01,$02,$03);ux:false;un:false), //0x1b0
(wo:INPUT_PORT_A;m:($02,$03,$00,$01,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x1b2
(wo:$0c0;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x1b4
(wo:$036;m:($ff,$ff,$ff,$ff,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07);ux:true;un:true), //0x1b6
(wo:$03c;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x1b8
(wo:$0b2;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x1ba
(wo:$024;m:($0b,$08,$09,$0a,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:false;un:false), //0x1bc
(wo:$008;m:($0f,$0c,$0d,$0e,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x1be
(wo:$030;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$04,$05,$06,$07,$00,$01,$02,$03);ux:false;un:true), //0x1c0
(wo:$09a;m:($0c,$0d,$0e,$0f,$00,$01,$02,$03,$08,$09,$0a,$0b,$04,$05,$06,$07);ux:false;un:true), //0x1c2
(wo:$016;m:($ff,$ff,$ff,$ff,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07);ux:true;un:false), //0x1c4
(wo:$0ba;m:($05,$06,$07,$04,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:false), //0x1c6
(wo:$06a;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x1c8
(wo:$0ce;m:($05,$06,$07,$04,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:true;un:true), //0x1ca
(wo:$0ec;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x1cc
(wo:$014;m:($0d,$0e,$0f,$0c,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x1ce
(wo:INPUT_PORT_B;m:($04,$05,$06,$07,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x1d0
(wo:$050;m:($00,$01,$02,$03,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07);ux:true;un:true), //0x1d2
(wo:$0a0;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:true;un:false), //0x1d4
(wo:$05e;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$04,$05,$06,$07,$00,$01,$02,$03);ux:true;un:true), //0x1d6
(wo:$01a;m:($04,$05,$06,$07,$00,$01,$02,$03,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:true), //0x1d8
(wo:$0fc;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x1da
(wo:$03e;m:($09,$0a,$0b,$08,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x1dc
(wo:$078;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:false;un:false), //0x1de
(wo:$022;m:($03,$00,$01,$02,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:true), //0x1e0
(wo:$0c2;m:($01,$02,$03,$00,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:true), //0x1e2
(wo:$0cc;m:($0e,$0f,$0c,$0d,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:true;un:true), //0x1e4
(wo:$01e;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x1e6
(wo:$002;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x1e8
(wo:$0d2;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x1ea
(wo:$092;m:($09,$0a,$0b,$08,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x1ec
(wo:$0f2;m:($0e,$0f,$0c,$0d,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:true), //0x1ee
(wo:$0c8;m:($0b,$08,$09,$0a,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x1f0
(wo:$058;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x1f2
(wo:$0f4;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$00,$01,$02,$03,$04,$05,$06,$07);ux:true;un:true), //0x1f4
(wo:$0f0;m:($07,$04,$05,$06,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:true;un:false), //0x1f6
(wo:$088;m:($04,$05,$06,$07,$00,$01,$02,$03,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b);ux:false;un:true), //0x1f8
(wo:$020;m:($0c,$0d,$0e,$0f,$04,$05,$06,$07,$08,$09,$0a,$0b,$00,$01,$02,$03);ux:true;un:true), //0x1fa
(wo:$0ca;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x1fc
(wo:$04c;m:($03,$00,$01,$02,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:false), //0x1fe
(wo:INPUT_PORT_C;m:($01,$02,$03,$00,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:false), //0x200
(wo:$04e;m:($ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:true;un:true), //0x202
(wo:$018;m:($04,$05,$06,$07,$00,$01,$02,$03,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b);ux:true;un:true), //0x204
(wo:$064;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x206
(wo:$04a;m:($05,$06,$07,$04,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:true;un:false), //0x208
(wo:$080;m:($0f,$0c,$0d,$0e,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x20a
(wo:$034;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x20c
(wo:$094;m:($07,$04,$05,$06,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:true), //0x20e
(wo:$08a;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:true;un:true), //0x210
(wo:$07a;m:($0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x212
(wo:$0f8;m:($00,$01,$02,$03,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$04,$05,$06,$07);ux:true;un:true), //0x214
(wo:$070;m:($05,$06,$07,$04,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:false;un:true), //0x216
(wo:$0ca;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x218
(wo:$078;m:($0d,$0e,$0f,$0c,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x21a
(wo:$0e4;m:($05,$06,$07,$04,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:true;un:true), //0x21c
(wo:$0fe;m:($00,$01,$02,$03,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b);ux:true;un:false), //0x21e
(wo:$0b0;m:($0d,$0e,$0f,$0c,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:true), //0x220
(wo:$07c;m:($09,$0a,$0b,$08,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x222
(wo:$0b4;m:($09,$0a,$0b,$08,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:true;un:true), //0x224
(wo:$05c;m:($ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:false;un:true), //0x226
(wo:$0e2;m:($0b,$08,$09,$0a,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:true;un:false), //0x228
(wo:INPUT_PORT_C;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:false), //0x22a
(wo:$0ae;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$08,$09,$0a,$0b);ux:false;un:true), //0x22c
(wo:$0de;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x22e
(wo:$090;m:($07,$04,$05,$06,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:true;un:true), //0x230
(wo:$07c;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x232
(wo:$0a6;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$00,$01,$02,$03,$0c,$0d,$0e,$0f);ux:true;un:true), //0x234
(wo:$040;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x236
(wo:$05a;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$00,$01,$02,$03,$04,$05,$06,$07);ux:false;un:true), //0x238
(wo:$0a8;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x23a
(wo:$060;m:($0f,$0c,$0d,$0e,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:true;un:true), //0x23c
(wo:$074;m:($ff,$ff,$ff,$ff,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07);ux:false;un:false), //0x23e
(wo:$06e;m:($0f,$0c,$0d,$0e,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x240
(wo:$0d4;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:false;un:true), //0x242
(wo:$00a;m:($0b,$08,$09,$0a,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:false;un:true), //0x244
(wo:$068;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$08,$09,$0a,$0b);ux:true;un:false), //0x246
(wo:$0d0;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x248
(wo:$052;m:($ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:true;un:false), //0x24a
(wo:INPUT_PORT_B;m:($08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x24c
(wo:$00e;m:($03,$00,$01,$02,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:true), //0x24e
(wo:$012;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x250
(wo:$08c;m:($0a,$0b,$08,$09,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:false;un:true), //0x252
(wo:$0bc;m:($04,$05,$06,$07,$00,$01,$02,$03,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:true), //0x254
(wo:$078;m:($09,$0a,$0b,$08,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x256
(wo:$0fe;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x258
(wo:$0ee;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:false;un:false), //0x25a
(wo:$096;m:($0e,$0f,$0c,$0d,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x25c
(wo:$0dc;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:false;un:false), //0x25e
(wo:$07e;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x260
(wo:$038;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x262
(wo:$046;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x264
(wo:$0b8;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:false;un:true), //0x266
(wo:$0d0;m:($09,$0a,$0b,$08,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x268
(wo:$0c6;m:($0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x26a
(wo:$0ea;m:($07,$04,$05,$06,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:true;un:false), //0x26c
(wo:$066;m:($06,$07,$04,$05,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:false;un:false), //0x26e
(wo:$0f8;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x270
(wo:$068;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x272
(wo:$03a;m:($0d,$0e,$0f,$0c,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x274
(wo:$0e8;m:($03,$00,$01,$02,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x276
(wo:$032;m:($04,$05,$06,$07,$00,$01,$02,$03,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b);ux:true;un:true), //0x278
(wo:$08e;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$00,$01,$02,$03,$0c,$0d,$0e,$0f);ux:false;un:true), //0x27a
(wo:$044;m:($0b,$08,$09,$0a,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x27c
(wo:$0f6;m:($0d,$0e,$0f,$0c,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:true), //0x27e
(wo:INPUT_PORT_B;m:($0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x280
(wo:$0be;m:($0f,$0c,$0d,$0e,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:true;un:false), //0x282
(wo:$040;m:($01,$02,$03,$00,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:true), //0x284
(wo:$06a;m:($05,$06,$07,$04,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:true), //0x286
(wo:$0a4;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:true;un:false), //0x288
(wo:$0f0;m:($0e,$0f,$0c,$0d,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:true;un:true), //0x28a
(wo:$0f8;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x28c
(wo:$0d2;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x28e
(wo:$012;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:true;un:true), //0x290
(wo:$078;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:true;un:true), //0x292
(wo:$000;m:($02,$03,$00,$01,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:true), //0x294
(wo:$01c;m:($00,$01,$02,$03,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$04,$05,$06,$07);ux:false;un:true), //0x296
(wo:$048;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:true;un:false), //0x298
(wo:$06c;m:($0f,$0c,$0d,$0e,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:true), //0x29a
(wo:$0d8;m:($0b,$08,$09,$0a,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x29c
(wo:$062;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$00,$01,$02,$03,$0c,$0d,$0e,$0f);ux:false;un:true), //0x29e
(wo:$0ac;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x2a0
(wo:$0d6;m:($0d,$0e,$0f,$0c,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x2a2
(wo:$00c;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:true;un:true), //0x2a4
(wo:$0e8;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x2a6
(wo:$084;m:($00,$01,$02,$03,$0c,$0d,$0e,$0f,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:false), //0x2a8
(wo:$054;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$00,$01,$02,$03,$04,$05,$06,$07);ux:true;un:true), //0x2aa
(wo:$042;m:($09,$0a,$0b,$08,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:true;un:true), //0x2ac
(wo:$07e;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x2ae
(wo:$002;m:($0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x2b0
(wo:$0d8;m:($0e,$0f,$0c,$0d,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:true;un:false), //0x2b2
(wo:$0c4;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x2b4
(wo:$02e;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x2b6
(wo:$040;m:($09,$0a,$0b,$08,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x2b8
(wo:$064;m:($00,$01,$02,$03,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$04,$05,$06,$07);ux:true;un:true), //0x2ba
(wo:$072;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07,$00,$01,$02,$03);ux:true;un:true), //0x2bc
(wo:$016;m:($02,$03,$00,$01,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:false), //0x2be
(wo:$04e;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$00,$01,$02,$03,$0c,$0d,$0e,$0f);ux:true;un:false), //0x2c0
(wo:$06e;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:true;un:false), //0x2c2
(wo:$0de;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x2c4
(wo:$094;m:($00,$01,$02,$03,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b);ux:false;un:false), //0x2c6
(wo:$074;m:($08,$09,$0a,$0b,$00,$01,$02,$03,$04,$05,$06,$07,$0c,$0d,$0e,$0f);ux:false;un:false), //0x2c8
(wo:$07c;m:($0c,$0d,$0e,$0f,$04,$05,$06,$07,$08,$09,$0a,$0b,$00,$01,$02,$03);ux:true;un:false), //0x2ca
(wo:$006;m:($0c,$0d,$0e,$0f,$00,$01,$02,$03,$08,$09,$0a,$0b,$04,$05,$06,$07);ux:true;un:false), //0x2cc
(wo:$078;m:($02,$03,$00,$01,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:true), //0x2ce
(wo:$09e;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:false;un:false), //0x2d0
(wo:$028;m:($0a,$0b,$08,$09,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x2d2
(wo:$0b2;m:($0f,$0c,$0d,$0e,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x2d4
(wo:$05a;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$04,$05,$06,$07,$00,$01,$02,$03);ux:true;un:false), //0x2d6
(wo:$026;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:true), //0x2d8
(wo:$08a;m:($05,$06,$07,$04,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:false), //0x2da
(wo:$0ac;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:true), //0x2dc
(wo:$096;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$00,$01,$02,$03,$04,$05,$06,$07);ux:true;un:false), //0x2de
(wo:$098;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x2e0
(wo:INPUT_PORT_C;m:($0c,$0d,$0e,$0f,$04,$05,$06,$07,$08,$09,$0a,$0b,$00,$01,$02,$03);ux:false;un:false), //0x2e2
(wo:$02a;m:($09,$0a,$0b,$08,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:true;un:false), //0x2e4
(wo:$0fe;m:($00,$01,$02,$03,$0c,$0d,$0e,$0f,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:true;un:false), //0x2e6
(wo:$0b4;m:($0d,$0e,$0f,$0c,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:true;un:true), //0x2e8
(wo:$032;m:($07,$04,$05,$06,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:false;un:false), //0x2ea
(wo:$0f2;m:($07,$04,$05,$06,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:false;un:true), //0x2ec
(wo:$054;m:($00,$01,$02,$03,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07);ux:false;un:true), //0x2ee
(wo:$0a2;m:($06,$07,$04,$05,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:true), //0x2f0
(wo:$050;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:true;un:false), //0x2f2
(wo:INPUT_PORT_B;m:($01,$02,$03,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x2f4
(wo:$000;m:($02,$03,$00,$01,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:true), //0x2f6
(wo:$01e;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$00,$01,$02,$03,$0c,$0d,$0e,$0f);ux:true;un:false), //0x2f8
(wo:$014;m:($0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:true;un:true), //0x2fa
(wo:$0b8;m:($ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:false;un:false), //0x2fc
(wo:$0ae;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x2fe
(wo:$068;m:($00,$01,$02,$03,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b);ux:true;un:true), //0x300
(wo:$0f8;m:($04,$05,$06,$07,$00,$01,$02,$03,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b);ux:false;un:false), //0x302
(wo:$0d6;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:false;un:false), //0x304
(wo:$044;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:true;un:true), //0x306
(wo:$038;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x308
(wo:$078;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x30a
(wo:$04c;m:($00,$01,$02,$03,$0c,$0d,$0e,$0f,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:true), //0x30c
(wo:$0c6;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:true), //0x30e
(wo:$084;m:($0c,$0d,$0e,$0f,$00,$01,$02,$03,$08,$09,$0a,$0b,$04,$05,$06,$07);ux:true;un:true), //0x310
(wo:$0bc;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x312
(wo:$058;m:($00,$01,$02,$03,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07);ux:true;un:true), //0x314
(wo:INPUT_PORT_B;m:($02,$03,$00,$01,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x316
(wo:$00e;m:($0f,$0c,$0d,$0e,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:false), //0x318
(wo:$092;m:($0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x31a
(wo:$09a;m:($00,$01,$02,$03,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07);ux:false;un:false), //0x31c
(wo:$0a0;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$08,$09,$0a,$0b);ux:true;un:false), //0x31e
(wo:$08c;m:($0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x320
(wo:$08e;m:($04,$05,$06,$07,$00,$01,$02,$03,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x322
(wo:$0d2;m:($ff,$ff,$ff,$ff,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07);ux:true;un:true), //0x324
(wo:$024;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:true), //0x326
(wo:$006;m:($ff,$ff,$ff,$ff,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07);ux:false;un:false), //0x328
(wo:$080;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x32a
(wo:$0e2;m:($06,$07,$04,$05,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:false;un:true), //0x32c
(wo:$008;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x32e
(wo:$00c;m:($00,$01,$02,$03,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07);ux:true;un:false), //0x330
(wo:$048;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x332
(wo:$05c;m:($00,$01,$02,$03,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$04,$05,$06,$07);ux:false;un:false), //0x334
(wo:$042;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x336
(wo:$076;m:($08,$09,$0a,$0b,$00,$01,$02,$03,$04,$05,$06,$07,$0c,$0d,$0e,$0f);ux:true;un:true), //0x338
(wo:$036;m:($00,$01,$02,$03,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$04,$05,$06,$07);ux:true;un:false), //0x33a
(wo:$0b0;m:($07,$04,$05,$06,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:true), //0x33c
(wo:$056;m:($04,$05,$06,$07,$00,$01,$02,$03,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:true), //0x33e
(wo:$01a;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x340
(wo:$0bc;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x342
(wo:$0aa;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x344
(wo:$078;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:true;un:false), //0x346
(wo:$0dc;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$00,$01,$02,$03,$0c,$0d,$0e,$0f);ux:false;un:false), //0x348
(wo:$06a;m:($06,$07,$04,$05,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:true;un:false), //0x34a
(wo:INPUT_PORT_B;m:($03,$00,$01,$02,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x34c
(wo:$03e;m:($04,$05,$06,$07,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$08,$09,$0a,$0b);ux:true;un:true), //0x34e
(wo:$0da;m:($08,$09,$0a,$0b,$00,$01,$02,$03,$04,$05,$06,$07,$0c,$0d,$0e,$0f);ux:false;un:true), //0x350
(wo:$098;m:($0f,$0c,$0d,$0e,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:true;un:true), //0x352
(wo:$01c;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$04,$05,$06,$07,$00,$01,$02,$03);ux:true;un:true), //0x354
(wo:$034;m:($0a,$0b,$08,$09,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:true;un:true), //0x356
(wo:$0ba;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x358
(wo:$08a;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x35a
(wo:$086;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$04,$05,$06,$07,$00,$01,$02,$03);ux:false;un:true), //0x35c
(wo:$09c;m:($03,$00,$01,$02,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:true), //0x35e
(wo:$02c;m:($01,$02,$03,$00,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:false), //0x360
(wo:$080;m:($0c,$0d,$0e,$0f,$00,$01,$02,$03,$08,$09,$0a,$0b,$04,$05,$06,$07);ux:false;un:false), //0x362
(wo:$04a;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x364
(wo:$0c8;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:true;un:false), //0x366
(wo:$05e;m:($0f,$0c,$0d,$0e,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x368
(wo:$0f6;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x36a
(wo:$0fc;m:($04,$05,$06,$07,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$08,$09,$0a,$0b);ux:true;un:false), //0x36c
(wo:$048;m:($05,$06,$07,$04,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:false;un:true), //0x36e
(wo:$0c4;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x370
(wo:$020;m:($00,$01,$02,$03,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b);ux:true;un:false), //0x372
(wo:$030;m:($0d,$0e,$0f,$0c,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:true;un:false), //0x374
(wo:$038;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x376
(wo:INPUT_PORT_A;m:($04,$05,$06,$07,$00,$01,$02,$03,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x378
(wo:$08e;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x37a
(wo:$010;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x37c
(wo:$0d0;m:($05,$06,$07,$04,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:true;un:true), //0x37e
(wo:$084;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x380
(wo:$078;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x382
(wo:$0ee;m:($0f,$0c,$0d,$0e,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x384
(wo:$07a;m:($ff,$ff,$ff,$ff,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07);ux:true;un:false), //0x386
(wo:$0b6;m:($0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:true), //0x388
(wo:$084;m:($04,$05,$06,$07,$00,$01,$02,$03,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b);ux:false;un:true), //0x38a
(wo:$01a;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x38c
(wo:$004;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:true;un:true), //0x38e
(wo:$0fa;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x390
(wo:$0ae;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x392
(wo:$0cc;m:($0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x394
(wo:$0e0;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x396
(wo:$024;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x398
(wo:$0f6;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07,$00,$01,$02,$03);ux:false;un:false), //0x39a
(wo:$0a8;m:($0c,$0d,$0e,$0f,$04,$05,$06,$07,$08,$09,$0a,$0b,$00,$01,$02,$03);ux:false;un:false), //0x39c
(wo:$0ec;m:($06,$07,$04,$05,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:false), //0x39e
(wo:$070;m:($09,$0a,$0b,$08,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x3a0
(wo:$0a6;m:($00,$01,$02,$03,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b);ux:false;un:true), //0x3a2
(wo:$03c;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:true;un:false), //0x3a4
(wo:$09e;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x3a6
(wo:$0c2;m:($0a,$0b,$08,$09,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:true;un:false), //0x3a8
(wo:$03a;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$08,$09,$0a,$0b);ux:false;un:true), //0x3aa
(wo:$0a4;m:($0b,$08,$09,$0a,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:false;un:true), //0x3ac
(wo:$010;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:false;un:false), //0x3ae
(wo:$0d4;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$08,$09,$0a,$0b);ux:true;un:true), //0x3b0
(wo:$03c;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x3b2
(wo:$082;m:($0f,$0c,$0d,$0e,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x3b4
(wo:$00a;m:($0d,$0e,$0f,$0c,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x3b6
(wo:$066;m:($0c,$0d,$0e,$0f,$04,$05,$06,$07,$08,$09,$0a,$0b,$00,$01,$02,$03);ux:false;un:true), //0x3b8
(wo:$022;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:false), //0x3ba
(wo:$0be;m:($07,$04,$05,$06,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:true;un:true), //0x3bc
(wo:$078;m:($09,$0a,$0b,$08,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x3be
(wo:$0ca;m:($08,$09,$0a,$0b,$00,$01,$02,$03,$04,$05,$06,$07,$0c,$0d,$0e,$0f);ux:true;un:false), //0x3c0
(wo:$0ba;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:false;un:true), //0x3c2
(wo:$0e6;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x3c4
(wo:$052;m:($07,$04,$05,$06,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:true;un:true), //0x3c6
(wo:$026;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x3c8
(wo:$0ce;m:($05,$06,$07,$04,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:true;un:false), //0x3ca
(wo:$0f0;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:false;un:false), //0x3cc
(wo:$0f4;m:($01,$02,$03,$00,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:true), //0x3ce
(wo:$060;m:($09,$0a,$0b,$08,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x3d0
(wo:$0e8;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:false), //0x3d2
(wo:$018;m:($00,$01,$02,$03,$0c,$0d,$0e,$0f,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:true;un:true), //0x3d4
(wo:$088;m:($0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:true;un:false), //0x3d6
(wo:$0e4;m:($0b,$08,$09,$0a,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:false;un:false), //0x3d8
(wo:$0ea;m:($05,$06,$07,$04,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:true;un:false), //0x3da
(wo:$0aa;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x3dc
(wo:$06c;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$00,$01,$02,$03,$0c,$0d,$0e,$0f);ux:true;un:true), //0x3de
(wo:$044;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x3e0
(wo:$046;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$00,$01,$02,$03,$04,$05,$06,$07);ux:false;un:false), //0x3e2
(wo:$020;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x3e4
(wo:$012;m:($ff,$ff,$ff,$ff,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07);ux:false;un:true), //0x3e6
(wo:$008;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:false;un:true), //0x3e8
(wo:$062;m:($0b,$08,$09,$0a,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x3ea
(wo:$0c0;m:($0e,$0f,$0c,$0d,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x3ec
(wo:$008;m:($01,$02,$03,$00,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x3ee
(wo:$056;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x3f0
(wo:$0d8;m:($07,$04,$05,$06,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:false), //0x3f2
(wo:$0ee;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x3f4
(wo:$07c;m:($03,$00,$01,$02,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:false), //0x3f6
(wo:$086;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07,$00,$01,$02,$03);ux:false;un:true), //0x3f8
(wo:$078;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x3fa
(wo:$03a;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x3fc
(wo:$006;m:($0c,$0d,$0e,$0f,$00,$01,$02,$03,$08,$09,$0a,$0b,$04,$05,$06,$07);ux:false;un:true), //0x3fe
(wo:$0fc;m:($02,$03,$00,$01,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:false), //0x400
(wo:$01c;m:($0b,$08,$09,$0a,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:true;un:true), //0x402
(wo:$098;m:($0b,$08,$09,$0a,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:true;un:false), //0x404
(wo:$06c;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:true;un:true), //0x406
(wo:$0cc;m:($06,$07,$04,$05,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:true;un:true), //0x408
(wo:$0d6;m:($04,$05,$06,$07,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$08,$09,$0a,$0b);ux:false;un:false), //0x40a
(wo:$0f0;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$00,$01,$02,$03,$0c,$0d,$0e,$0f);ux:false;un:false), //0x40c
(wo:$07a;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x40e
(wo:$09a;m:($0a,$0b,$08,$09,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x410
(wo:$0c4;m:($0a,$0b,$08,$09,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:false;un:true), //0x412
(wo:INPUT_PORT_C;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x414
(wo:$0ea;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:false;un:true), //0x416
(wo:$074;m:($0e,$0f,$0c,$0d,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:true), //0x418
(wo:$096;m:($0a,$0b,$08,$09,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x41a
(wo:$0f2;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x41c
(wo:$08a;m:($0e,$0f,$0c,$0d,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x41e
(wo:$054;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:true;un:true), //0x420
(wo:$05c;m:($0e,$0f,$0c,$0d,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:false), //0x422
(wo:$0c2;m:($0e,$0f,$0c,$0d,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x424
(wo:$026;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x426
(wo:$088;m:($0a,$0b,$08,$09,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x428
(wo:$08c;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x42a
(wo:$09c;m:($0d,$0e,$0f,$0c,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x42c
(wo:$01a;m:($0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x42e
(wo:INPUT_PORT_B;m:($04,$05,$06,$07,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x430
(wo:$000;m:($07,$04,$05,$06,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:true;un:false), //0x432
(wo:$0d4;m:($02,$03,$00,$01,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x434
(wo:$078;m:($04,$05,$06,$07,$00,$01,$02,$03,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:true), //0x436
(wo:$070;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$00,$01,$02,$03,$04,$05,$06,$07);ux:false;un:true), //0x438
(wo:$05e;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:false;un:true), //0x43a
(wo:$0f6;m:($04,$05,$06,$07,$00,$01,$02,$03,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:false), //0x43c
(wo:$082;m:($ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:false;un:true), //0x43e
(wo:$03e;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x440
(wo:$0a6;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$04,$05,$06,$07,$00,$01,$02,$03);ux:false;un:false), //0x442
(wo:$0b0;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x444
(wo:$0de;m:($06,$07,$04,$05,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:true;un:true), //0x446
(wo:$0b6;m:($06,$07,$04,$05,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:true;un:false), //0x448
(wo:$002;m:($0d,$0e,$0f,$0c,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:false), //0x44a
(wo:$090;m:($0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x44c
(wo:$06e;m:($0c,$0d,$0e,$0f,$04,$05,$06,$07,$08,$09,$0a,$0b,$00,$01,$02,$03);ux:true;un:true), //0x44e
(wo:$0a0;m:($ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:true;un:true), //0x450
(wo:$0c8;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x452
(wo:$0f8;m:($0b,$08,$09,$0a,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x454
(wo:$024;m:($0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x456
(wo:$0b6;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x458
(wo:$070;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x45a
(wo:$0ee;m:($ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:true;un:false), //0x45c
(wo:$0b4;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07,$00,$01,$02,$03);ux:true;un:false), //0x45e
(wo:$0ca;m:($09,$0a,$0b,$08,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x460
(wo:$01e;m:($0a,$0b,$08,$09,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:false;un:false), //0x462
(wo:$052;m:($05,$06,$07,$04,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:false), //0x464
(wo:$048;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x466
(wo:$02a;m:($04,$05,$06,$07,$00,$01,$02,$03,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:true), //0x468
(wo:$02c;m:($09,$0a,$0b,$08,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:false;un:false), //0x46a
(wo:$0a8;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$00,$01,$02,$03,$0c,$0d,$0e,$0f);ux:true;un:true), //0x46c
(wo:$010;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$08,$09,$0a,$0b);ux:false;un:false), //0x46e
(wo:$0ce;m:($04,$05,$06,$07,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$08,$09,$0a,$0b);ux:false;un:true), //0x470
(wo:$078;m:($0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x472
(wo:$066;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:true;un:true), //0x474
(wo:$05a;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:true;un:false), //0x476
(wo:INPUT_PORT_C;m:($04,$05,$06,$07,$00,$01,$02,$03,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b);ux:false;un:false), //0x478
(wo:$014;m:($04,$05,$06,$07,$00,$01,$02,$03,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b);ux:true;un:false), //0x47a
(wo:$0e8;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x47c
(wo:$0b8;m:($05,$06,$07,$04,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:true;un:true), //0x47e
(wo:$0e0;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x480
(wo:$012;m:($0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:false), //0x482
(wo:$058;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:false), //0x484
(wo:$036;m:($00,$01,$02,$03,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$04,$05,$06,$07);ux:false;un:true), //0x486
(wo:INPUT_PORT_A;m:($04,$05,$06,$07,$00,$01,$02,$03,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b);ux:false;un:false), //0x488
(wo:$07a;m:($0d,$0e,$0f,$0c,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x48a
(wo:$072;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:false), //0x48c
(wo:$0c6;m:($06,$07,$04,$05,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:true;un:true), //0x48e
(wo:$0bc;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$00,$01,$02,$03,$0c,$0d,$0e,$0f);ux:true;un:false), //0x490
(wo:$0fa;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07,$00,$01,$02,$03);ux:true;un:true), //0x492
(wo:$0f4;m:($0d,$0e,$0f,$0c,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:true;un:false), //0x494
(wo:$046;m:($0b,$08,$09,$0a,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:false;un:true), //0x496
(wo:$0b2;m:($05,$06,$07,$04,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:false), //0x498
(wo:$004;m:($0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:true;un:false), //0x49a
(wo:$07e;m:($05,$06,$07,$04,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:false;un:true), //0x49c
(wo:$04e;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$00,$01,$02,$03,$0c,$0d,$0e,$0f);ux:true;un:true), //0x49e
(wo:$0e2;m:($0b,$08,$09,$0a,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:false;un:false), //0x4a0
(wo:$094;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:true;un:false), //0x4a2
(wo:$0ae;m:($ff,$ff,$ff,$ff,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07);ux:true;un:false), //0x4a4
(wo:$0a8;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x4a6
(wo:$092;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x4a8
(wo:$0da;m:($09,$0a,$0b,$08,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:true;un:true), //0x4aa
(wo:$080;m:($09,$0a,$0b,$08,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:true;un:false), //0x4ac
(wo:$078;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:false;un:false), //0x4ae
(wo:$0be;m:($0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x4b0
(wo:$04c;m:($08,$09,$0a,$0b,$00,$01,$02,$03,$04,$05,$06,$07,$0c,$0d,$0e,$0f);ux:true;un:false), //0x4b2
(wo:$032;m:($0b,$08,$09,$0a,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x4b4
(wo:$0fe;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:true;un:true), //0x4b6
(wo:$030;m:($06,$07,$04,$05,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:false;un:false), //0x4b8
(wo:$0dc;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x4ba
(wo:$030;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x4bc
(wo:$02e;m:($06,$07,$04,$05,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:false), //0x4be
(wo:INPUT_PORT_C;m:($0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x4c0
(wo:$03c;m:($07,$04,$05,$06,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:true;un:false), //0x4c2
(wo:$08c;m:($00,$01,$02,$03,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07);ux:true;un:false), //0x4c4
(wo:$028;m:($0d,$0e,$0f,$0c,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x4c6
(wo:$03e;m:($0d,$0e,$0f,$0c,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:true), //0x4c8
(wo:$0d0;m:($01,$02,$03,$00,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:true), //0x4ca
(wo:$0d4;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x4cc
(wo:$062;m:($03,$00,$01,$02,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:false), //0x4ce
(wo:$076;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:true;un:true), //0x4d0
(wo:$00e;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$08,$09,$0a,$0b);ux:true;un:true), //0x4d2
(wo:$038;m:($0d,$0e,$0f,$0c,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:false), //0x4d4
(wo:$0dc;m:($07,$04,$05,$06,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:false;un:false), //0x4d6
(wo:$0e6;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x4d8
(wo:$00c;m:($0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x4da
(wo:$0a4;m:($01,$02,$03,$00,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:true), //0x4dc
(wo:$0c0;m:($05,$06,$07,$04,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:true), //0x4de
(wo:INPUT_PORT_B;m:($00,$01,$02,$03,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x4e0
(wo:$0ba;m:($0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:true), //0x4e2
(wo:$0ea;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x4e4
(wo:$0ec;m:($0f,$0c,$0d,$0e,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x4e6
(wo:$022;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$00,$01,$02,$03,$04,$05,$06,$07);ux:false;un:false), //0x4e8
(wo:$078;m:($02,$03,$00,$01,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x4ea
(wo:$0a2;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x4ec
(wo:$068;m:($07,$04,$05,$06,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:true;un:true), //0x4ee
(wo:$050;m:($01,$02,$03,$00,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x4f0
(wo:INPUT_PORT_B;m:($04,$05,$06,$07,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x4f2
(wo:$074;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x4f4
(wo:$060;m:($ff,$ff,$ff,$ff,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07);ux:false;un:true), //0x4f6
(wo:$040;m:($09,$0a,$0b,$08,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x4f8
(wo:$0f2;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$00,$01,$02,$03,$04,$05,$06,$07);ux:false;un:true), //0x4fa
(wo:$064;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:false;un:true), //0x4fc
(wo:$084;m:($06,$07,$04,$05,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:true), //0x4fe
(wo:$016;m:($0c,$0d,$0e,$0f,$00,$01,$02,$03,$08,$09,$0a,$0b,$04,$05,$06,$07);ux:false;un:false), //0x500
(wo:$04a;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:false;un:true), //0x502
(wo:$018;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:false;un:false), //0x504
(wo:$084;m:($07,$04,$05,$06,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:true;un:false), //0x506
(wo:$034;m:($00,$01,$02,$03,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$04,$05,$06,$07);ux:true;un:true), //0x508
(wo:INPUT_PORT_B;m:($0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x50a
(wo:$08e;m:($04,$05,$06,$07,$00,$01,$02,$03,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b);ux:false;un:true), //0x50c
(wo:$00a;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x50e
(wo:$0ac;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x510
(wo:$0d2;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:true;un:false), //0x512
(wo:$06a;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:true;un:false), //0x514
(wo:$0b0;m:($03,$00,$01,$02,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:true), //0x516
(wo:$0aa;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x518
(wo:$09e;m:($00,$01,$02,$03,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b);ux:false;un:true), //0x51a
(wo:$044;m:($00,$01,$02,$03,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$04,$05,$06,$07);ux:true;un:false), //0x51c
(wo:$0e4;m:($ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:false;un:false), //0x51e
(wo:$042;m:($04,$05,$06,$07,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$08,$09,$0a,$0b);ux:false;un:false), //0x520
(wo:$020;m:($09,$0a,$0b,$08,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x522
(wo:$056;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$08,$09,$0a,$0b);ux:true;un:false), //0x524
(wo:$078;m:($08,$09,$0a,$0b,$00,$01,$02,$03,$04,$05,$06,$07,$0c,$0d,$0e,$0f);ux:true;un:true), //0x526
(wo:$0ea;m:($06,$07,$04,$05,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:true;un:true), //0x528
(wo:$004;m:($0b,$08,$09,$0a,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x52a
(wo:INPUT_PORT_A;m:($01,$02,$03,$00,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:false), //0x52c
(wo:$060;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x52e
(wo:$0f0;m:($0a,$0b,$08,$09,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x530
(wo:$052;m:($01,$02,$03,$00,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:false), //0x532
(wo:$09c;m:($00,$01,$02,$03,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b);ux:true;un:false), //0x534
(wo:$072;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$00,$01,$02,$03,$0c,$0d,$0e,$0f);ux:false;un:false), //0x536
(wo:$038;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:true;un:false), //0x538
(wo:$036;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x53a
(wo:$0de;m:($08,$09,$0a,$0b,$00,$01,$02,$03,$04,$05,$06,$07,$0c,$0d,$0e,$0f);ux:false;un:true), //0x53c
(wo:$0de;m:($04,$05,$06,$07,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$08,$09,$0a,$0b);ux:true;un:true), //0x53e
(wo:$01e;m:($09,$0a,$0b,$08,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:false;un:true), //0x540
(wo:$092;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x542
(wo:$040;m:($04,$05,$06,$07,$00,$01,$02,$03,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b);ux:true;un:false), //0x544
(wo:$04c;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x546
(wo:$06c;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$08,$09,$0a,$0b);ux:false;un:true), //0x548
(wo:$0fe;m:($0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x54a
(wo:$068;m:($00,$01,$02,$03,$0c,$0d,$0e,$0f,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:true), //0x54c
(wo:$060;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:false;un:false), //0x54e
(wo:$08e;m:($09,$0a,$0b,$08,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x550
(wo:$008;m:($05,$06,$07,$04,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:false;un:false), //0x552
(wo:$006;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x554
(wo:$0d6;m:($00,$01,$02,$03,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07);ux:true;un:true), //0x556
(wo:$06a;m:($0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x558
(wo:$0be;m:($0e,$0f,$0c,$0d,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:false), //0x55a
(wo:INPUT_PORT_A;m:($01,$02,$03,$00,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:true), //0x55c
(wo:$0fc;m:($06,$07,$04,$05,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:true;un:true), //0x55e
(wo:$0fc;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x560
(wo:$078;m:($0b,$08,$09,$0a,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:true;un:true), //0x562
(wo:INPUT_PORT_C;m:($00,$01,$02,$03,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b);ux:false;un:false), //0x564
(wo:$0a4;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x566
(wo:$0c6;m:($0f,$0c,$0d,$0e,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x568
(wo:$0ca;m:($04,$05,$06,$07,$00,$01,$02,$03,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b);ux:false;un:false), //0x56a
(wo:$08c;m:($00,$01,$02,$03,$0c,$0d,$0e,$0f,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:false), //0x56c
(wo:$042;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$00,$01,$02,$03,$04,$05,$06,$07);ux:true;un:false), //0x56e
(wo:$05c;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:true;un:true), //0x570
(wo:$0a0;m:($ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:false;un:true), //0x572
(wo:$04c;m:($0c,$0d,$0e,$0f,$04,$05,$06,$07,$08,$09,$0a,$0b,$00,$01,$02,$03);ux:false;un:false), //0x574
(wo:$04a;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:false;un:true), //0x576
(wo:$0d8;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x578
(wo:$094;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:true;un:true), //0x57a
(wo:$002;m:($05,$06,$07,$04,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:true;un:true), //0x57c
(wo:$020;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:true), //0x57e
(wo:$088;m:($0a,$0b,$08,$09,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:true;un:true), //0x580
(wo:$0b6;m:($09,$0a,$0b,$08,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:false;un:false), //0x582
(wo:$054;m:($0e,$0f,$0c,$0d,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x584
(wo:$0b8;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x586
(wo:$014;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$04,$05,$06,$07,$00,$01,$02,$03);ux:false;un:true), //0x588
(wo:$05a;m:($0c,$0d,$0e,$0f,$04,$05,$06,$07,$08,$09,$0a,$0b,$00,$01,$02,$03);ux:true;un:false), //0x58a
(wo:$0e0;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$08,$09,$0a,$0b);ux:false;un:false), //0x58c
(wo:$0c8;m:($00,$01,$02,$03,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b);ux:false;un:false), //0x58e
(wo:$07a;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$00,$01,$02,$03,$0c,$0d,$0e,$0f);ux:true;un:false), //0x590
(wo:$062;m:($04,$05,$06,$07,$00,$01,$02,$03,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:false), //0x592
(wo:$0f6;m:($07,$04,$05,$06,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:true), //0x594
(wo:$0bc;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x596
(wo:$07c;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$00,$01,$02,$03,$0c,$0d,$0e,$0f);ux:true;un:true), //0x598
(wo:$09a;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x59a
(wo:$0ce;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x59c
(wo:$078;m:($0c,$0d,$0e,$0f,$00,$01,$02,$03,$08,$09,$0a,$0b,$04,$05,$06,$07);ux:true;un:false), //0x59e
(wo:$03c;m:($0a,$0b,$08,$09,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x5a0
(wo:$0f2;m:($02,$03,$00,$01,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:false), //0x5a2
(wo:$006;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x5a4
(wo:$03a;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x5a6
(wo:$0b0;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$04,$05,$06,$07,$00,$01,$02,$03);ux:false;un:false), //0x5a8
(wo:$0cc;m:($0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:true;un:true), //0x5aa
(wo:$02a;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:true;un:true), //0x5ac
(wo:$08a;m:($0e,$0f,$0c,$0d,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:true), //0x5ae
(wo:$0f8;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x5b0
(wo:$024;m:($0a,$0b,$08,$09,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:true;un:false), //0x5b2
(wo:$05e;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:true;un:false), //0x5b4
(wo:$0e4;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x5b6
(wo:$0b4;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:false), //0x5b8
(wo:$016;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x5ba
(wo:$06e;m:($0d,$0e,$0f,$0c,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x5bc
(wo:$096;m:($0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:true;un:false), //0x5be
(wo:$0ee;m:($0f,$0c,$0d,$0e,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x5c0
(wo:$010;m:($05,$06,$07,$04,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:false), //0x5c2
(wo:$0fa;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:false;un:false), //0x5c4
(wo:$0c6;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x5c6
(wo:INPUT_PORT_B;m:($01,$02,$03,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x5c8
(wo:$0c4;m:($0d,$0e,$0f,$0c,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:true;un:false), //0x5ca
(wo:$032;m:($0b,$08,$09,$0a,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:false;un:true), //0x5cc
(wo:$00e;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:true), //0x5ce
(wo:$036;m:($00,$01,$02,$03,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b);ux:true;un:true), //0x5d0
(wo:$0ba;m:($03,$00,$01,$02,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:true), //0x5d2
(wo:$034;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x5d4
(wo:$0e4;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:true;un:false), //0x5d6
(wo:$056;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x5d8
(wo:$078;m:($06,$07,$04,$05,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:true;un:false), //0x5da
(wo:$044;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:true), //0x5dc
(wo:$016;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:true;un:true), //0x5de
(wo:$084;m:($00,$01,$02,$03,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$04,$05,$06,$07);ux:false;un:false), //0x5e0
(wo:$086;m:($00,$01,$02,$03,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07);ux:true;un:false), //0x5e2
(wo:INPUT_PORT_B;m:($02,$03,$00,$01,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x5e4
(wo:$0d8;m:($04,$05,$06,$07,$00,$01,$02,$03,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b);ux:false;un:false), //0x5e6
(wo:$0f6;m:($06,$07,$04,$05,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:true), //0x5e8
(wo:$0b8;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x5ea
(wo:$0dc;m:($07,$04,$05,$06,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:false;un:false), //0x5ec
(wo:$0cc;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x5ee
(wo:$02c;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x5f0
(wo:$012;m:($09,$0a,$0b,$08,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:true;un:false), //0x5f2
(wo:$018;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x5f4
(wo:$07e;m:($00,$01,$02,$03,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07);ux:false;un:true), //0x5f6
(wo:$066;m:($0d,$0e,$0f,$0c,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x5f8
(wo:$0ea;m:($06,$07,$04,$05,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:false;un:true), //0x5fa
(wo:$0d0;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:true), //0x5fc
(wo:$0ac;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$04,$05,$06,$07,$00,$01,$02,$03);ux:true;un:false), //0x5fe
(wo:$0a8;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x600
(wo:$092;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x602
(wo:$034;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:true;un:false), //0x604
(wo:$0e6;m:($00,$01,$02,$03,$0c,$0d,$0e,$0f,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:false), //0x606
(wo:$048;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:true;un:true), //0x608
(wo:$0e2;m:($00,$01,$02,$03,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$04,$05,$06,$07);ux:false;un:true), //0x60a
(wo:$0a6;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:true;un:true), //0x60c
(wo:$0da;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x60e
(wo:$0c0;m:($01,$02,$03,$00,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x610
(wo:$0b2;m:($0d,$0e,$0f,$0c,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:true;un:false), //0x612
(wo:$046;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$00,$01,$02,$03,$0c,$0d,$0e,$0f);ux:false;un:false), //0x614
(wo:$078;m:($04,$05,$06,$07,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$08,$09,$0a,$0b);ux:false;un:true), //0x616
(wo:$070;m:($0f,$0c,$0d,$0e,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x618
(wo:$0d4;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:false;un:false), //0x61a
(wo:$09e;m:($00,$01,$02,$03,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b);ux:false;un:true), //0x61c
(wo:$028;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07,$00,$01,$02,$03);ux:true;un:true), //0x61e
(wo:INPUT_PORT_C;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:false;un:false), //0x620
(wo:$090;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:true;un:false), //0x622
(wo:$0c2;m:($0c,$0d,$0e,$0f,$00,$01,$02,$03,$08,$09,$0a,$0b,$04,$05,$06,$07);ux:true;un:false), //0x624
(wo:$0f4;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x626
(wo:$0a4;m:($0d,$0e,$0f,$0c,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x628
(wo:$03e;m:($04,$05,$06,$07,$00,$01,$02,$03,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x62a
(wo:$058;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:true;un:false), //0x62c
(wo:$064;m:($0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x62e
(wo:$01c;m:($00,$01,$02,$03,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b);ux:true;un:true), //0x630
(wo:$02e;m:($ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:false;un:false), //0x632
(wo:$04e;m:($08,$09,$0a,$0b,$00,$01,$02,$03,$04,$05,$06,$07,$0c,$0d,$0e,$0f);ux:true;un:false), //0x634
(wo:$018;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07,$00,$01,$02,$03);ux:false;un:false), //0x636
(wo:$0a2;m:($0f,$0c,$0d,$0e,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:false), //0x638
(wo:$088;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x63a
(wo:INPUT_PORT_A;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:false), //0x63c
(wo:$0da;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x63e
(wo:$022;m:($06,$07,$04,$05,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:true;un:false), //0x640
(wo:$030;m:($09,$0a,$0b,$08,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x642
(wo:$000;m:($07,$04,$05,$06,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:true;un:true), //0x644
(wo:INPUT_PORT_A;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:false), //0x646
(wo:$00a;m:($07,$04,$05,$06,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:false), //0x648
(wo:$074;m:($05,$06,$07,$04,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:true;un:false), //0x64a
(wo:$0ae;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:false;un:true), //0x64c
(wo:$05c;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x64e
(wo:$01a;m:($09,$0a,$0b,$08,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:false;un:true), //0x650
(wo:$078;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07,$00,$01,$02,$03);ux:false;un:false), //0x652
(wo:INPUT_PORT_C;m:($04,$05,$06,$07,$00,$01,$02,$03,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x654
(wo:$0c0;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x656
(wo:$0aa;m:($00,$01,$02,$03,$0c,$0d,$0e,$0f,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:true;un:false), //0x658
(wo:INPUT_PORT_C;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:false;un:false), //0x65a
(wo:$0e8;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:false;un:true), //0x65c
(wo:$0d2;m:($05,$06,$07,$04,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:false;un:true), //0x65e
(wo:$0f4;m:($09,$0a,$0b,$08,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x660
(wo:$010;m:($0e,$0f,$0c,$0d,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:true;un:false), //0x662
(wo:$080;m:($00,$01,$02,$03,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$04,$05,$06,$07);ux:true;un:true), //0x664
(wo:$00c;m:($0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x666
(wo:$050;m:($0d,$0e,$0f,$0c,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:true), //0x668
(wo:$04a;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x66a
(wo:$09a;m:($07,$04,$05,$06,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:true;un:true), //0x66c
(wo:$06e;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:true;un:true), //0x66e
(wo:INPUT_PORT_A;m:($0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x670
(wo:$072;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x672
(wo:$074;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x674
(wo:$0ba;m:($0f,$0c,$0d,$0e,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x676
(wo:$0c2;m:($05,$06,$07,$04,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:true;un:true), //0x678
(wo:$092;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:true;un:false), //0x67a
(wo:$01e;m:($09,$0a,$0b,$08,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:true;un:true), //0x67c
(wo:$082;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:true;un:false), //0x67e
(wo:$036;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:false;un:false), //0x680
(wo:$084;m:($0b,$08,$09,$0a,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x682
(wo:$016;m:($09,$0a,$0b,$08,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x684
(wo:$0d8;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x686
(wo:$086;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x688
(wo:$028;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$08,$09,$0a,$0b);ux:false;un:false), //0x68a
(wo:$040;m:($0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:true;un:true), //0x68c
(wo:$078;m:($0e,$0f,$0c,$0d,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x68e
(wo:$046;m:($05,$06,$07,$04,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:true), //0x690
(wo:$02e;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x692
(wo:$0ea;m:($04,$05,$06,$07,$00,$01,$02,$03,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:true), //0x694
(wo:$09a;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x696
(wo:$068;m:($0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x698
(wo:$0d4;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:true;un:true), //0x69a
(wo:$070;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$04,$05,$06,$07,$00,$01,$02,$03);ux:true;un:true), //0x69c
(wo:$07c;m:($0a,$0b,$08,$09,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:true;un:true), //0x69e
(wo:$0f6;m:($08,$09,$0a,$0b,$00,$01,$02,$03,$04,$05,$06,$07,$0c,$0d,$0e,$0f);ux:false;un:false), //0x6a0
(wo:$0e8;m:($0a,$0b,$08,$09,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x6a2
(wo:$056;m:($ff,$ff,$ff,$ff,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07);ux:false;un:true), //0x6a4
(wo:$0d2;m:($04,$05,$06,$07,$00,$01,$02,$03,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b);ux:true;un:true), //0x6a6
(wo:$026;m:($ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:true;un:true), //0x6a8
(wo:$0a8;m:($03,$00,$01,$02,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:false), //0x6aa
(wo:$0c6;m:($0c,$0d,$0e,$0f,$04,$05,$06,$07,$08,$09,$0a,$0b,$00,$01,$02,$03);ux:true;un:true), //0x6ac
(wo:$0be;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x6ae
(wo:$062;m:($04,$05,$06,$07,$00,$01,$02,$03,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b);ux:false;un:true), //0x6b0
(wo:$094;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x6b2
(wo:$0ae;m:($07,$04,$05,$06,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:true;un:false), //0x6b4
(wo:$006;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$00,$01,$02,$03,$04,$05,$06,$07);ux:true;un:true), //0x6b6
(wo:$0a4;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$08,$09,$0a,$0b);ux:true;un:true), //0x6b8
(wo:$050;m:($0a,$0b,$08,$09,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:false;un:false), //0x6ba
(wo:$0f2;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x6bc
(wo:$07a;m:($09,$0a,$0b,$08,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x6be
(wo:$06c;m:($0e,$0f,$0c,$0d,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:true;un:true), //0x6c0
(wo:$00e;m:($01,$02,$03,$00,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:true), //0x6c2
(wo:$054;m:($0e,$0f,$0c,$0d,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:true), //0x6c4
(wo:$07e;m:($03,$00,$01,$02,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:true), //0x6c6
(wo:$018;m:($05,$06,$07,$04,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:true;un:true), //0x6c8
(wo:$078;m:($07,$04,$05,$06,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:true;un:true), //0x6ca
(wo:$01a;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$04,$05,$06,$07,$00,$01,$02,$03);ux:false;un:true), //0x6cc
(wo:$0de;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:false;un:false), //0x6ce
(wo:$04a;m:($0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x6d0
(wo:$08c;m:($0f,$0c,$0d,$0e,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:true;un:false), //0x6d2
(wo:$014;m:($01,$02,$03,$00,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:false), //0x6d4
(wo:$0cc;m:($0b,$08,$09,$0a,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x6d6
(wo:$00a;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x6d8
(wo:$002;m:($00,$01,$02,$03,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$04,$05,$06,$07);ux:true;un:false), //0x6da
(wo:$05a;m:($0f,$0c,$0d,$0e,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:true;un:true), //0x6dc
(wo:$0aa;m:($07,$04,$05,$06,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:true;un:false), //0x6de
(wo:$090;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x6e0
(wo:$03c;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x6e2
(wo:$080;m:($02,$03,$00,$01,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:false), //0x6e4
(wo:$044;m:($0d,$0e,$0f,$0c,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x6e6
(wo:$072;m:($ff,$ff,$ff,$ff,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07);ux:true;un:true), //0x6e8
(wo:$098;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x6ea
(wo:$038;m:($0e,$0f,$0c,$0d,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x6ec
(wo:$04c;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:true), //0x6ee
(wo:$022;m:($0b,$08,$09,$0a,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x6f0
(wo:$000;m:($00,$01,$02,$03,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07);ux:false;un:false), //0x6f2
(wo:$0fa;m:($0c,$0d,$0e,$0f,$00,$01,$02,$03,$08,$09,$0a,$0b,$04,$05,$06,$07);ux:false;un:true), //0x6f4
(wo:$00c;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x6f6
(wo:INPUT_PORT_A;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:false;un:false), //0x6f8
(wo:$004;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x6fa
(wo:$066;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x6fc
(wo:$08a;m:($05,$06,$07,$04,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:false), //0x6fe
(wo:$0b0;m:($0a,$0b,$08,$09,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:true;un:false), //0x700
(wo:$012;m:($ff,$ff,$ff,$ff,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07);ux:true;un:false), //0x702
(wo:$066;m:($0f,$0c,$0d,$0e,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x704
(wo:$078;m:($0a,$0b,$08,$09,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x706
(wo:$02c;m:($0b,$08,$09,$0a,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:false;un:false), //0x708
(wo:$09c;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x70a
(wo:$0bc;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07,$00,$01,$02,$03);ux:true;un:false), //0x70c
(wo:$004;m:($0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:false), //0x70e
(wo:$0ca;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$04,$05,$06,$07,$00,$01,$02,$03);ux:false;un:false), //0x710
(wo:INPUT_PORT_B;m:($01,$02,$03,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x712
(wo:$00a;m:($05,$06,$07,$04,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:false;un:false), //0x714
(wo:INPUT_PORT_A;m:($01,$02,$03,$00,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x716
(wo:$0a2;m:($0b,$08,$09,$0a,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:true;un:true), //0x718
(wo:$0ac;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$00,$01,$02,$03,$0c,$0d,$0e,$0f);ux:true;un:true), //0x71a
(wo:$0ce;m:($0c,$0d,$0e,$0f,$04,$05,$06,$07,$08,$09,$0a,$0b,$00,$01,$02,$03);ux:false;un:false), //0x71c
(wo:$08e;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$00,$01,$02,$03,$0c,$0d,$0e,$0f);ux:true;un:true), //0x71e
(wo:$034;m:($01,$02,$03,$00,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:true), //0x720
(wo:INPUT_PORT_C;m:($03,$00,$01,$02,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x722
(wo:$0d6;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x724
(wo:$0fc;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x726
(wo:$0b6;m:($04,$05,$06,$07,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$08,$09,$0a,$0b);ux:true;un:false), //0x728
(wo:$0ec;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x72a
(wo:$094;m:($0c,$0d,$0e,$0f,$04,$05,$06,$07,$08,$09,$0a,$0b,$00,$01,$02,$03);ux:false;un:true), //0x72c
(wo:INPUT_PORT_A;m:($03,$00,$01,$02,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x72e
(wo:$02e;m:($06,$07,$04,$05,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:false;un:false), //0x730
(wo:$09e;m:($0d,$0e,$0f,$0c,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x732
(wo:$05c;m:($04,$05,$06,$07,$00,$01,$02,$03,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:true), //0x734
(wo:$042;m:($0c,$0d,$0e,$0f,$00,$01,$02,$03,$08,$09,$0a,$0b,$04,$05,$06,$07);ux:true;un:true), //0x736
(wo:$0d0;m:($04,$05,$06,$07,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$08,$09,$0a,$0b);ux:true;un:true), //0x738
(wo:$0f0;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x73a
(wo:$0e4;m:($0e,$0f,$0c,$0d,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x73c
(wo:$04e;m:($0e,$0f,$0c,$0d,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:false), //0x73e
(wo:$0cc;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x740
(wo:$078;m:($0e,$0f,$0c,$0d,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x742
(wo:$010;m:($00,$01,$02,$03,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b);ux:true;un:false), //0x744
(wo:$0b8;m:($06,$07,$04,$05,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:true;un:true), //0x746
(wo:$0c4;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:false), //0x748
(wo:$052;m:($09,$0a,$0b,$08,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:false;un:false), //0x74a
(wo:$06a;m:($0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x74c
(wo:$064;m:($03,$00,$01,$02,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x74e
(wo:$0da;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x750
(wo:$076;m:($07,$04,$05,$06,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:true), //0x752
(wo:$03e;m:($0c,$0d,$0e,$0f,$00,$01,$02,$03,$08,$09,$0a,$0b,$04,$05,$06,$07);ux:true;un:true), //0x754
(wo:INPUT_PORT_C;m:($0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:false), //0x756
(wo:$0fe;m:($ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:true;un:false), //0x758
(wo:$058;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$00,$01,$02,$03,$0c,$0d,$0e,$0f);ux:false;un:false), //0x75a
(wo:$02a;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$08,$09,$0a,$0b);ux:true;un:false), //0x75c
(wo:$060;m:($0b,$08,$09,$0a,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:false;un:true), //0x75e
(wo:$0f4;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x760
(wo:$082;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x762
(wo:$008;m:($0a,$0b,$08,$09,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:false;un:true), //0x764
(wo:INPUT_PORT_A;m:($00,$01,$02,$03,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b);ux:false;un:false), //0x766
(wo:$0c8;m:($06,$07,$04,$05,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:true;un:false), //0x768
(wo:INPUT_PORT_B;m:($00,$01,$02,$03,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x76a
(wo:$088;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$00,$01,$02,$03,$04,$05,$06,$07);ux:false;un:true), //0x76c
(wo:$06e;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x76e
(wo:$01c;m:($ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:false;un:true), //0x770
(wo:$0d6;m:($0b,$08,$09,$0a,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:true;un:false), //0x772
(wo:$0e0;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$08,$09,$0a,$0b);ux:false;un:true), //0x774
(wo:$020;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:false;un:false), //0x776
(wo:$0a6;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:false;un:true), //0x778
(wo:$030;m:($0f,$0c,$0d,$0e,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x77a
(wo:$0fa;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x77c
(wo:$078;m:($02,$03,$00,$01,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:true), //0x77e
(wo:$0c0;m:($ff,$ff,$ff,$ff,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07);ux:false;un:false), //0x780
(wo:$0b2;m:($05,$06,$07,$04,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:true;un:false), //0x782
(wo:$0e2;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$00,$01,$02,$03,$04,$05,$06,$07);ux:false;un:false), //0x784
(wo:$024;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x786
(wo:INPUT_PORT_C;m:($02,$03,$00,$01,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x788
(wo:$05e;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:true), //0x78a
(wo:$03a;m:($00,$01,$02,$03,$0c,$0d,$0e,$0f,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:true;un:true), //0x78c
(wo:$032;m:($06,$07,$04,$05,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:true;un:true), //0x78e
(wo:INPUT_PORT_A;m:($0c,$0d,$0e,$0f,$04,$05,$06,$07,$08,$09,$0a,$0b,$00,$01,$02,$03);ux:false;un:false), //0x790
(wo:$0e6;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:false), //0x792
(wo:$096;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x794
(wo:$0ee;m:($02,$03,$00,$01,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x796
(wo:$0f8;m:($0f,$0c,$0d,$0e,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:true), //0x798
(wo:$0b4;m:($02,$03,$00,$01,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:true), //0x79a
(wo:$096;m:($0a,$0b,$08,$09,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:false), //0x79c
(wo:$0a0;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:true;un:true), //0x79e
(wo:$0a0;m:($0a,$0b,$08,$09,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x7a0
(wo:$048;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:false;un:true), //0x7a2
(wo:$0f6;m:($08,$09,$0a,$0b,$00,$01,$02,$03,$04,$05,$06,$07,$0c,$0d,$0e,$0f);ux:false;un:true), //0x7a4
(wo:$006;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$00,$01,$02,$03,$0c,$0d,$0e,$0f);ux:true;un:false), //0x7a6
(wo:$0de;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$00,$01,$02,$03,$0c,$0d,$0e,$0f);ux:false;un:true), //0x7a8
(wo:$0cc;m:($0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:true), //0x7aa
(wo:$0a4;m:($04,$05,$06,$07,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$08,$09,$0a,$0b);ux:false;un:true), //0x7ac
(wo:$07c;m:($02,$03,$00,$01,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:true), //0x7ae
(wo:$0ce;m:($07,$04,$05,$06,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:false;un:true), //0x7b0
(wo:$0ba;m:($0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:true;un:false), //0x7b2
(wo:$01e;m:($00,$01,$02,$03,$0c,$0d,$0e,$0f,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:true), //0x7b4
(wo:$0da;m:($0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x7b6
(wo:$0aa;m:($0d,$0e,$0f,$0c,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:false;un:false), //0x7b8
(wo:$078;m:($07,$04,$05,$06,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:false), //0x7ba
(wo:$076;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$04,$05,$06,$07);ux:false;un:false), //0x7bc
(wo:$0b6;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x7be
(wo:$058;m:($04,$05,$06,$07,$0c,$0d,$0e,$0f,$00,$01,$02,$03,$08,$09,$0a,$0b);ux:false;un:false), //0x7c0
(wo:$050;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x7c2
(wo:$060;m:($03,$00,$01,$02,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:true), //0x7c4
(wo:$05e;m:($00,$01,$02,$03,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07);ux:true;un:true), //0x7c6
(wo:$094;m:($0a,$0b,$08,$09,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x7c8
(wo:$000;m:($0c,$0d,$0e,$0f,$08,$09,$0a,$0b,$00,$01,$02,$03,$04,$05,$06,$07);ux:true;un:false), //0x7ca
(wo:$03e;m:($ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x7cc
(wo:INPUT_PORT_C;m:($01,$02,$03,$00,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x7ce
(wo:$0d0;m:($0c,$0d,$0e,$0f,$00,$01,$02,$03,$08,$09,$0a,$0b,$04,$05,$06,$07);ux:false;un:false), //0x7d0
(wo:$0be;m:($0d,$0e,$0f,$0c,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b);ux:true;un:true), //0x7d2
(wo:$00c;m:($06,$07,$04,$05,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:false), //0x7d4
(wo:INPUT_PORT_A;m:($02,$03,$00,$01,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:false), //0x7d6
(wo:$01a;m:($0b,$08,$09,$0a,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x7d8
(wo:$0e6;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x7da
(wo:$0d6;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:false;un:false), //0x7dc
(wo:$05c;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$00,$01,$02,$03,$0c,$0d,$0e,$0f);ux:true;un:false), //0x7de
(wo:$00a;m:($08,$09,$0a,$0b,$00,$01,$02,$03,$04,$05,$06,$07,$0c,$0d,$0e,$0f);ux:true;un:true), //0x7e0
(wo:$0c4;m:($04,$05,$06,$07,$00,$01,$02,$03,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:true;un:false), //0x7e2
(wo:$0e4;m:($0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:false), //0x7e4
(wo:$0a6;m:($0c,$0d,$0e,$0f,$04,$05,$06,$07,$08,$09,$0a,$0b,$00,$01,$02,$03);ux:true;un:false), //0x7e6
(wo:$058;m:($00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:false), //0x7e8
(wo:$040;m:($00,$01,$02,$03,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b);ux:false;un:false), //0x7ea
(wo:$046;m:($0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x7ec
(wo:$0ea;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:true;un:true), //0x7ee
(wo:$090;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$ff,$ff,$ff,$ff,$0c,$0d,$0e,$0f);ux:true;un:true), //0x7f0
(wo:$08e;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$00,$01,$02,$03);ux:false;un:true), //0x7f2
(wo:INPUT_PORT_A;m:($02,$03,$00,$01,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f);ux:false;un:true), //0x7f4
(wo:$078;m:($0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);ux:false;un:true), //0x7f6
(wo:$004;m:($08,$09,$0a,$0b,$04,$05,$06,$07,$0c,$0d,$0e,$0f,$ff,$ff,$ff,$ff);ux:true;un:false), //0x7f8
(wo:$02e;m:($08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$04,$05,$06,$07,$00,$01,$02,$03);ux:false;un:true), //0x7fa
(wo:$06e;m:($04,$05,$06,$07,$00,$01,$02,$03,$0c,$0d,$0e,$0f,$08,$09,$0a,$0b);ux:true;un:false), //0x7fc
(wo:$04c;m:($04,$05,$06,$07,$08,$09,$0a,$0b,$00,$01,$02,$03,$0c,$0d,$0e,$0f);ux:false;un:true)); //0x7fe

constructor cpu_deco_146.create;
begin
  self.set_interface_scramble(9,8,7,6,5,4,3,2,1,0);
  self.bankswitch_swap_read_address:=$78;
	self.magic_read_address_xor:=$44a;
	self.magic_read_address_xor_enabled:=false;
	self.xor_port:=$2c;
	self.mask_port:=$36;
	self.soundlatch_port:=$64;
	self.configregion:=$8;
  copymemory(@self.internal_ram,@deco_146ram,sizeof(deco_146ram));
end;

destructor cpu_deco_146.Free;
begin
end;


procedure cpu_deco_146.reset;

var
  i:byte;
begin
	self.region_selects[0]:=0;
	self.region_selects[1]:=0;
	self.region_selects[2]:=0;
	self.region_selects[3]:=0;
	self.region_selects[4]:=0;
	self.region_selects[5]:=0;
	self.current_rambank:=0;
	self.m_nand:=$0000;
	self.m_xor:=$0000;
	self.m_latchaddr:=$ffff;
	self.m_latchdata:=$0000;
	self.m_latchflag:=0;
  for i:=0 to $7f do begin
		// the mutant fighter old sim assumes 0x0000
		self.rambank0[i]:=$ffff;
		self.rambank1[i]:=$ffff;
	end;
end;

procedure cpu_deco_146.set_interface_scramble(a9,a8,a7,a6,a5,a4,a3,a2,a1,a0:byte);
begin
  external_addrswap[9]:=a9;
  external_addrswap[8]:=a8;
  external_addrswap[7]:=a7;
  external_addrswap[6]:=a6;
  external_addrswap[5]:=a5;
  external_addrswap[4]:=a4;
  external_addrswap[3]:=a3;
  external_addrswap[2]:=a2;
  external_addrswap[1]:=a1;
  external_addrswap[0]:=a0;
end;

procedure cpu_deco_146.SET_INTERFACE_SCRAMBLE_REVERSE;
begin
  set_interface_scramble(0,1,2,3,4,5,6,7,8,9);
end;

procedure cpu_deco_146.SET_INTERFACE_SCRAMBLE_INTERLEAVE;
begin
  set_interface_scramble(4,5,3,6,2,7,1,8,0,9);
end;

procedure cpu_deco_146.SET_USE_MAGIC_ADDRESS_XOR;
begin
  magic_read_address_xor_enabled:=true;
end;

function reorder(input:word;weights:pbyte):word;
var
  temp:word;
  i:byte;
  tempb:pbyte;
begin
	temp:=0;
	for i:=0 to 15 do begin
		if (input and (1 shl i))<>0 then begin  // if input bit is set
      tempb:=weights;
      inc(tempb,i);
			if (tempb^<>$FF) then begin // and weight exists for output bit
				temp:=temp or (1 shl tempb^); // set that bit
			end;
		end;
	end;
	reorder:=temp;
end;

function cpu_deco_146.read_data_getloc(address:word;var location:integer):word;
var
  retdata,realret:word;
begin
	location:=internal_ram[address shr 1].wo;
	if (location=INPUT_PORT_A) then retdata:=marcade.in0//m_port_a_r(0);
	  else if (location=INPUT_PORT_B) then retdata:=marcade.in1//m_port_b_r(0);
      else if (location=INPUT_PORT_C) then retdata:=marcade.dswa//m_port_c_r(0);
	      else begin
		      if (current_rambank=0) then retdata:=rambank0[location shr 1]
		        else retdata:=rambank1[location shr 1];
	      end;
	realret:=reorder(retdata,@internal_ram[address shr 1].m[0]);
	if (internal_ram[address shr 1].ux) then realret:=realret xor m_xor;
	if (internal_ram[address shr 1].un) then realret:=realret and not(m_nand);
	read_data_getloc:=realret;
end;

function cpu_deco_146.read_protport(address:word):word;
var
  realret:word;
  location:integer;
begin
	// if we read the last written address immediately after then ignore all other logic and just return what was written unmodified
	if ((address=m_latchaddr) and (m_latchflag=1)) then begin
		//logerror("returning latched data %04x\n", m_latchdata);
		m_latchflag:=0;
		read_protport:=m_latchdata;
    exit;
	end;
	m_latchflag:=0;
	if (magic_read_address_xor_enabled) then address:=address xor magic_read_address_xor;
	location:=0;
	realret:=read_data_getloc(address,location);
	if (location=bankswitch_swap_read_address) then begin// this has a special meaning
	//  logerror("(bankswitch) %04x %04x\n", address, mem_mask);
		if (current_rambank=0) then current_rambank:=1
		  else current_rambank:=0;
	end;
	read_protport:=realret;
end;

function cpu_deco_146.read_data(address:word;var csflags:byte):word;
var
  retdata:word;
  upper_addr_bits,real_address:dword;
  i,cs:byte;
begin
	address:=BITSWAP16(address shr 1,15,14,13,12,11,10,external_addrswap[9],external_addrswap[8],external_addrswap[7],external_addrswap[6],external_addrswap[5],external_addrswap[4],external_addrswap[3],external_addrswap[2],external_addrswap[1],external_addrswap[0]) shl 1;
	retdata:=0;
	csflags:=0;
	upper_addr_bits:=(address and $7800) shr 11;
	if (upper_addr_bits=$8) then begin // configuration registers are hardcoded to this area
		//real_address:=address and 0xf;
		//logerror("read config regs? %04x %04x\n", real_address, mem_mask);
		read_data:=$0000;
    exit;
	end;
	// what gets priority?
	for i:=0 to 5 do begin
		cs:=region_selects[i];
		if (cs=upper_addr_bits) then begin
			real_address:=address and $7ff;
			csflags:=csflags or (1 shl i);
			if (i=0) then begin // the first cs is our internal protection area
				//logerror("read matches cs table (protection) %01x %04x %04x\n", i, real_address, mem_mask);
				read_data:=read_protport(real_address);
        exit;
			end else begin
				//logerror("read matches cs table (external connection) %01x %04x %04x\n", i, real_address, mem_mask);
        halt(0);
			end;
		end;
	end;
	if (csflags=0) then begin
		//logerror("read not in cs table\n");
    halt(0);
	end;
	read_data:=retdata;
end;

procedure cpu_deco_146.write_protport(address,data:word);
begin
	m_latchaddr:=address;
	m_latchdata:=data;
	m_latchflag:=1;
	if ((address and $ff)=xor_port) then begin
			//logerror("LOAD XOR REGISTER %04x %04x\n", data, mem_mask);
			m_xor:=data;
	end else begin
    if ((address and $ff)=mask_port) then begin
			//logerror("LOAD NAND REGISTER %04x %04x\n", data, mem_mask);
			m_nand:=data;
	  end	else begin
      if ((address and $ff)=soundlatch_port) then begin
			  //logerror("LOAD SOUND LATCH %04x %04x\n", data, mem_mask);
        deco16_sound_latch:=data and $ff;
        h6280_0.set_irq_line(0,HOLD_LINE);
      end;
    end;
  end;
	// always store
	if (current_rambank=0) then
  rambank0[(address and $ff) shr 1]:=data
	  else rambank1[(address and $ff) shr 1]:=data;
end;

procedure cpu_deco_146.write_data(address,data:word;var csflags:byte);
var
  upper_addr_bits,real_address:word;
  i,cs:byte;
begin
	address:=BITSWAP16(address shr 1, 15,14,13,12,11,10,external_addrswap[9],external_addrswap[8],external_addrswap[7],external_addrswap[6],external_addrswap[5],external_addrswap[4],external_addrswap[3],external_addrswap[2],external_addrswap[1],external_addrswap[0]) shl 1;
	csflags:=0;
	upper_addr_bits:=(address and $7800) shr 11;
	if (upper_addr_bits=8) then begin// configuration registers are hardcoded to this area
		real_address:=address and $f;
		//logerror("write to config regs %04x %04x %04x\n", real_address, data, mem_mask);
		if ((real_address>=$2) and (real_address<=$0c)) then begin
			region_selects[(real_address-2) div 2]:=data and $f;
			exit;
		end else begin
			// unknown
		end;
		exit; // or fall through?
	end;
	for i:=0 to 5 do begin
		cs:=region_selects[i];
		if (cs=upper_addr_bits) then begin
			real_address:=address and $7ff;
			csflags:=csflags or (1 shl i);
			if (i=0) then begin // the first cs is our internal protection area
				//logerror("write matches cs table (protection) %01x %04x %04x %04x\n", i, real_address, data, mem_mask);
				write_protport(real_address, data);
			end else begin
        //halt(0);
      end;
		end;
	end;
	if (csflags=0) then begin
    halt(0);
  end;
end;

end.
