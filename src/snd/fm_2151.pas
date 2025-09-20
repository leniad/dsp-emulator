unit fm_2151;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     math,timer_engine,sound_engine;

type
  YM2151Operator=record
	  phase:dword;					// accumulated operator phase */
	  freq:dword;					// operator frequency count */
	  dt1:longint;					// current DT1 (detune 1 phase inc/decrement) value */
	  mul:dword;					// frequency count multiply */
	  dt1_i:dword;					// DT1 index * 32 */
	  dt2:dword;					// current DT2 (detune 2) value */
	  connect:pinteger;				// operator output 'direction' */
	// only M1 (operator 0) is filled with this data: */
	  mem_connect:pinteger;			// where to put the delayed sample (MEM) */
	  mem_value:longint;				// delayed sample (MEM) value */
	// channel specific data; note: each operator number 0 contains channel specific data */
	  fb_shift:dword;				// feedback shift value for operators 0 in each channel */
	  fb_out_curr:longint;			// operator feedback value (used only by operators 0) */
	  fb_out_prev:longint;			// previous feedback value (used only by operators 0) */
	  kc:dword;						// channel KC (copied to all operators) */
	  kc_i:dword;					// just for speedup */
	  pms:dword;					// channel PMS */
	  ams:dword;					// channel AMS */
	// end of channel specific data */
	  AMmask:dword;					// LFO Amplitude Modulation enable mask */
	  state:dword;					// Envelope state: 4-attack(AR) 3-decay(D1R) 2-sustain(D2R) 1-release(RR) 0-off */
	  eg_sh_ar:byte;				//  (attack state) */
	  eg_sel_ar:byte;				//  (attack state) */
	  tl:dword;						// Total attenuation Level */
	  volume:longint;					// current envelope attenuation level */
	  eg_sh_d1r:byte;				//  (decay state) */
	  eg_sel_d1r:byte;				//  (decay state) */
	  d1l:dword;					// envelope switches to sustain state after reaching this level */
	  eg_sh_d2r:byte;				//  (sustain state) */
	  eg_sel_d2r:byte;				//  (sustain state) */
	  eg_sh_rr:byte;				//  (release state) */
	  eg_sel_rr:byte;				//  (release state) */
	  key:dword;					// 0=last key was KEY OFF, 1=last key was KEY ON */
	  ks:dword;						// key scale    */
	  ar:dword;						// attack rate  */
	  d1r:dword;					// decay rate   */
	  d2r:dword;					// sustain rate */
	  rr:dword;						// release rate */
	  reserved0:dword;
	  reserved1:dword;
  end;
  pYM2151Operator=^YM2151Operator;

  YM2151=record
    chanout:array[0..7] of integer;
    m2,c1,c2:integer; // Phase Modulation input for operators 2,3,4 */
    mem:integer;		// one sample delay memory */
	  oper:array[0..31] of pYM2151Operator;			// the 32 operators */
	  pan:array[0..15] of dword;				// channels output masks (0xffffffff = enable) */
	  eg_cnt:dword;					// global envelope generator counter */
	  eg_timer:dword;				// global envelope generator counter works at frequency = chipclock/64/3 */
	  eg_timer_add:dword;			// step of eg_timer */
	  eg_timer_overflow:dword;		// envelope generator timer overlfows every 3 samples (on real chip) */
	  lfo_phase:dword;				// accumulated LFO phase (0 to 255) */
	  lfo_timer:dword;				// LFO timer                        */
	  lfo_timer_add:dword;			// step of lfo_timer                */
	  lfo_overflow:dword;			// LFO generates new output when lfo_timer reaches this value */
	  lfo_counter:dword;			// LFO phase increment counter      */
	  lfo_counter_add:dword;		// step of lfo_counter              */
	  lfo_wsel:byte;				// LFO waveform (0-saw, 1-square, 2-triangle, 3-random noise) */
	  amd:byte;					// LFO Amplitude Modulation Depth   */
	  pmd:smallint;					// LFO Phase Modulation Depth       */
	  lfa:dword;					// LFO current AM output            */
	  lfp:longint;					// LFO current PM output            */
	  test:byte;					// TEST register */
	  ct:byte;						// output control pins (bit1-CT2, bit0-CT1) */
	  noise:dword;					// noise enable/period register (bit 7 - noise enable, bits 4-0 - noise period */
	  noise_rng:dword;				// 17 bit noise shift register */
	  noise_p:dword;				// current noise 'phase'*/
	  noise_f:dword;				// current noise period */
	  csm_req:dword;				// CSM  KEY ON / KEY OFF sequence request */
	  irq_enable:dword;				// IRQ enable for timer B (bit 3) and timer A (bit 2); bit 7 - CSM mode (keyon to all slots, everytime timer A overflows) */
	  status:dword;					// chip status (BUSY, IRQ Flags) */
	  connect:array[0..7] of byte;				// channels connections */
	  timer_A:byte;					// timer A enable (0-disabled) */
	  timer_B:byte;					// timer B enable (0-disabled) */
	  timer_A_time:array[0..1023] of single;		// timer A deltas */
	  timer_B_time:array[0..255] of single;			// timer B deltas */
    irqlinestate:byte;
	  timer_A_index:dword;			// timer A index */
	  timer_B_index:dword;			// timer B index */
	  timer_A_index_old:dword;		// timer A previous index */
	  timer_B_index_old:dword;		// timer B previous index */
	{  Frequency-deltas to get the closest frequency possible.
    *   There are 11 octaves because of DT2 (max 950 cents over base frequency)
    *   and LFO phase modulation (max 800 cents below AND over base frequency)
    *   Summary:   octave  explanation
    *              0       note code - LFO PM
    *              1       note code
    *              2       note code
    *              3       note code
    *              4       note code
    *              5       note code
    *              6       note code
    *              7       note code
    *              8       note code
    *              9       note code + DT2 + LFO PM
    *              10      note code + DT2 + LFO PM}
	  freq:array[0..(11*768)-1] of dword;			// 11 octaves, 768 'cents' per octave */

	{  Frequency deltas for DT1. These deltas alter operator frequency
    *   after it has been taken from frequency-deltas table.}
	  dt1_freq:array[0..(8*32)-1] of longint;			// 8 DT1 levels, 32 KC values */
	  noise_tab:array[0..31] of dword;			// 17bit Noise Generator periods */
	  IRQ_Handler:procedure (irqstate:byte);
	  porthandler:procedure (valor:byte);		// port write function handler */
	  clock:dword;					// chip clock in Hz (passed from 2151intf.c) */
	  sampfreq:dword;				// sampling frequency in Hz (passed from 2151intf.c) */
    lastreg:byte;
    tsample:byte;
    amp:single;
end;
  pYM2151=^YM2151;

var
  FM2151:array[0..3] of pYM2151;

procedure YM_2151Init(num:byte;clock:dword);
function YM_2151ReadStatus(num:byte):byte;
procedure YM_2151ResetChip(num:byte);
procedure YM_2151WriteReg(num,r,v:byte);
function YM_2151UpdateOne(num:byte):pinteger;
procedure YM_2151Close(num:byte);
//timers
procedure timer_a_exec(index:byte);
procedure timer_b_exec(index:byte);

implementation
const
  CLEAR_LINE=0;
  ASSERT_LINE=1;
  M_PI=3.1415926535;
	MAXOUT=32767;
	MINOUT=-32768;
  FREQ_SH=16;  // 16.16 fixed point (frequency calculations) */
  EG_SH=16;  // 16.16 fixed point (envelope generator timing) */
  LFO_SH=10;  // 22.10 fixed point (LFO calculations)       */
  TIMER_SH=16;  // 16.16 fixed point (timers calculations)    */
  FREQ_MASK=$FFFF; //((1 shl FREQ_SH)-1);
  ENV_BITS=10;
  ENV_LEN=$400; //(1 shl ENV_BITS);
  ENV_STEP=0.125;//(128.0/ENV_LEN);
  MAX_ATT_INDEX=$3FF;//(ENV_LEN-1); // 1023 */
  MIN_ATT_INDEX=0;			// 0 */
  EG_ATT=4;
  EG_DEC=3;
  EG_SUS=2;
  EG_REL=1;
  EG_OFF=0;
  SIN_BITS=10;
  SIN_LEN=$400; //(1 shl SIN_BITS);
  SIN_MASK=$3FF; //(SIN_LEN-1);
  TL_RES_LEN=256; // 8 bits addressing (real chip) */
  {  TL_TAB_LEN is calculated as:
*   13 - sinus amplitude bits     (Y axis)
*   2  - sinus sign bit           (Y axis)
*   TL_RES_LEN - sinus resolution (X axis)}
  TL_TAB_LEN=(13*2*TL_RES_LEN);
  ENV_QUIET=832; //(TL_TAB_LEN shr 3);
  RATE_STEPS=8;
  eg_inc:array[0..(19*RATE_STEPS)-1] of byte=(
//cycle:0 1  2 3  4 5  6 7*/
{ 0 } 0,1, 0,1, 0,1, 0,1, // rates 00..11 0 (increment by 0 or 1) */
{ 1 } 0,1, 0,1, 1,1, 0,1, // rates 00..11 1 */
{ 2 } 0,1, 1,1, 0,1, 1,1, // rates 00..11 2 */
{ 3 } 0,1, 1,1, 1,1, 1,1, // rates 00..11 3 */

{ 4 } 1,1, 1,1, 1,1, 1,1, // rate 12 0 (increment by 1) */
{ 5 } 1,1, 1,2, 1,1, 1,2, // rate 12 1 */
{ 6 } 1,2, 1,2, 1,2, 1,2, // rate 12 2 */
{ 7 } 1,2, 2,2, 1,2, 2,2, // rate 12 3 */

{ 8 } 2,2, 2,2, 2,2, 2,2, // rate 13 0 (increment by 2) */
{ 9 } 2,2, 2,4, 2,2, 2,4, // rate 13 1 */
{10 } 2,4, 2,4, 2,4, 2,4, // rate 13 2 */
{11 } 2,4, 4,4, 2,4, 4,4, // rate 13 3 */

{12 } 4,4, 4,4, 4,4, 4,4, // rate 14 0 (increment by 4) */
{13 } 4,4, 4,8, 4,4, 4,8, // rate 14 1 */
{14 } 4,8, 4,8, 4,8, 4,8, // rate 14 2 */
{15 } 4,8, 8,8, 4,8, 8,8, // rate 14 3 */

{16 } 8,8, 8,8, 8,8, 8,8, // rates 15 0, 15 1, 15 2, 15 3 (increment by 8) */
{17 } 16,16,16,16,16,16,16,16, // rates 15 2, 15 3 for attack */
{18 } 0,0, 0,0, 0,0, 0,0); // infinity rates for attack and decay(s) */

//note that there is no O(17) in this table - it's directly in the code */
eg_rate_select:array[0..(32+64+32)-1] of byte=( 	// Envelope Generator rates (32 + 64 rates + 32 RKS) */
// 32 dummy (infinite time) rates */
18*RATE_STEPS,18*RATE_STEPS,18*RATE_STEPS,18*RATE_STEPS,18*RATE_STEPS,18*RATE_STEPS,18*RATE_STEPS,18*RATE_STEPS,
18*RATE_STEPS,18*RATE_STEPS,18*RATE_STEPS,18*RATE_STEPS,18*RATE_STEPS,18*RATE_STEPS,18*RATE_STEPS,18*RATE_STEPS,
18*RATE_STEPS,18*RATE_STEPS,18*RATE_STEPS,18*RATE_STEPS,18*RATE_STEPS,18*RATE_STEPS,18*RATE_STEPS,18*RATE_STEPS,
18*RATE_STEPS,18*RATE_STEPS,18*RATE_STEPS,18*RATE_STEPS,18*RATE_STEPS,18*RATE_STEPS,18*RATE_STEPS,18*RATE_STEPS,

// rates 00-11 */
0*RATE_STEPS,1*RATE_STEPS,2*RATE_STEPS,3*RATE_STEPS,
0*RATE_STEPS,1*RATE_STEPS,2*RATE_STEPS,3*RATE_STEPS,
0*RATE_STEPS,1*RATE_STEPS,2*RATE_STEPS,3*RATE_STEPS,
0*RATE_STEPS,1*RATE_STEPS,2*RATE_STEPS,3*RATE_STEPS,
0*RATE_STEPS,1*RATE_STEPS,2*RATE_STEPS,3*RATE_STEPS,
0*RATE_STEPS,1*RATE_STEPS,2*RATE_STEPS,3*RATE_STEPS,
0*RATE_STEPS,1*RATE_STEPS,2*RATE_STEPS,3*RATE_STEPS,
0*RATE_STEPS,1*RATE_STEPS,2*RATE_STEPS,3*RATE_STEPS,
0*RATE_STEPS,1*RATE_STEPS,2*RATE_STEPS,3*RATE_STEPS,
0*RATE_STEPS,1*RATE_STEPS,2*RATE_STEPS,3*RATE_STEPS,
0*RATE_STEPS,1*RATE_STEPS,2*RATE_STEPS,3*RATE_STEPS,
0*RATE_STEPS,1*RATE_STEPS,2*RATE_STEPS,3*RATE_STEPS,
// rate 12 */
4*RATE_STEPS,5*RATE_STEPS,6*RATE_STEPS,7*RATE_STEPS,
// rate 13 */
8*RATE_STEPS,9*RATE_STEPS,10*RATE_STEPS,11*RATE_STEPS,
// rate 14 */
12*RATE_STEPS,13*RATE_STEPS,14*RATE_STEPS,15*RATE_STEPS,
// rate 15 */
16*RATE_STEPS,16*RATE_STEPS,16*RATE_STEPS,16*RATE_STEPS,
// 32 dummy rates (same as 15 3) */
16*RATE_STEPS,16*RATE_STEPS,16*RATE_STEPS,16*RATE_STEPS,16*RATE_STEPS,16*RATE_STEPS,16*RATE_STEPS,16*RATE_STEPS,
16*RATE_STEPS,16*RATE_STEPS,16*RATE_STEPS,16*RATE_STEPS,16*RATE_STEPS,16*RATE_STEPS,16*RATE_STEPS,16*RATE_STEPS,
16*RATE_STEPS,16*RATE_STEPS,16*RATE_STEPS,16*RATE_STEPS,16*RATE_STEPS,16*RATE_STEPS,16*RATE_STEPS,16*RATE_STEPS,
16*RATE_STEPS,16*RATE_STEPS,16*RATE_STEPS,16*RATE_STEPS,16*RATE_STEPS,16*RATE_STEPS,16*RATE_STEPS,16*RATE_STEPS);
//rate  0,    1,    2,   3,   4,   5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15*/
//shift 11,   10,   9,   8,   7,   6,  5,  4,  3,  2, 1,  0,  0,  0,  0,  0 */
//mask  2047, 1023, 511, 255, 127, 63, 31, 15, 7,  3, 1,  0,  0,  0,  0,  0 */

eg_rate_shift:array[0..(32+64+32)-1] of byte=(	// Envelope Generator counter shifts (32 + 64 rates + 32 RKS) */
// 32 infinite time rates */
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,

// rates 00-11 */
11,11,11,11,
10,10,10,10,
9,9,9,9,
8,8,8,8,
7,7,7,7,
6,6,6,6,
5,5,5,5,
4,4,4,4,
3,3,3,3,
2,2,2,2,
1,1,1,1,
0,0,0,0,
// rate 12 */
0,0,0,0,
// rate 13 */
0,0,0,0,
// rate 14 */
0,0,0,0,
// rate 15 */
0,0,0,0,
// 32 dummy rates (same as 15 3) */
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0);
{  DT2 defines offset in cents from base note
*
*   This table defines offset in frequency-deltas table.
*   User's Manual page 22
*
*   Values below were calculated using formula: value =  orig.val / 1.5625
*
*   DT2=0 DT2=1 DT2=2 DT2=3
*   0     600   781   950}
dt2_tab:array[0..3] of dword =( 0, 384, 500, 608 );

{  DT1 defines offset in Hertz from base note
*   This table is converted while initialization...
*   Detune table shown in YM2151 User's Manual is wrong (verified on the real chip)}

dt1_tab:array[0..(4*32)-1] of byte=( // 4*32 DT1 values */
// DT1=0 */
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
// DT1=1 */
  0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2,
  2, 3, 3, 3, 4, 4, 4, 5, 5, 6, 6, 7, 8, 8, 8, 8,
// DT1=2 */
  1, 1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5,
  5, 6, 6, 7, 8, 8, 9,10,11,12,13,14,16,16,16,16,
// DT1=3 */
  2, 2, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 6, 6, 7,
  8, 8, 9,10,11,12,13,14,16,17,19,20,22,22,22,22);

phaseinc_rom:array[0..767] of word=(
1299,1300,1301,1302,1303,1304,1305,1306,1308,1309,1310,1311,1313,1314,1315,1316,
1318,1319,1320,1321,1322,1323,1324,1325,1327,1328,1329,1330,1332,1333,1334,1335,
1337,1338,1339,1340,1341,1342,1343,1344,1346,1347,1348,1349,1351,1352,1353,1354,
1356,1357,1358,1359,1361,1362,1363,1364,1366,1367,1368,1369,1371,1372,1373,1374,
1376,1377,1378,1379,1381,1382,1383,1384,1386,1387,1388,1389,1391,1392,1393,1394,
1396,1397,1398,1399,1401,1402,1403,1404,1406,1407,1408,1409,1411,1412,1413,1414,
1416,1417,1418,1419,1421,1422,1423,1424,1426,1427,1429,1430,1431,1432,1434,1435,
1437,1438,1439,1440,1442,1443,1444,1445,1447,1448,1449,1450,1452,1453,1454,1455,
1458,1459,1460,1461,1463,1464,1465,1466,1468,1469,1471,1472,1473,1474,1476,1477,
1479,1480,1481,1482,1484,1485,1486,1487,1489,1490,1492,1493,1494,1495,1497,1498,
1501,1502,1503,1504,1506,1507,1509,1510,1512,1513,1514,1515,1517,1518,1520,1521,
1523,1524,1525,1526,1528,1529,1531,1532,1534,1535,1536,1537,1539,1540,1542,1543,
1545,1546,1547,1548,1550,1551,1553,1554,1556,1557,1558,1559,1561,1562,1564,1565,
1567,1568,1569,1570,1572,1573,1575,1576,1578,1579,1580,1581,1583,1584,1586,1587,
1590,1591,1592,1593,1595,1596,1598,1599,1601,1602,1604,1605,1607,1608,1609,1610,
1613,1614,1615,1616,1618,1619,1621,1622,1624,1625,1627,1628,1630,1631,1632,1633,
1637,1638,1639,1640,1642,1643,1645,1646,1648,1649,1651,1652,1654,1655,1656,1657,
1660,1661,1663,1664,1666,1667,1669,1670,1672,1673,1675,1676,1678,1679,1681,1682,
1685,1686,1688,1689,1691,1692,1694,1695,1697,1698,1700,1701,1703,1704,1706,1707,
1709,1710,1712,1713,1715,1716,1718,1719,1721,1722,1724,1725,1727,1728,1730,1731,
1734,1735,1737,1738,1740,1741,1743,1744,1746,1748,1749,1751,1752,1754,1755,1757,
1759,1760,1762,1763,1765,1766,1768,1769,1771,1773,1774,1776,1777,1779,1780,1782,
1785,1786,1788,1789,1791,1793,1794,1796,1798,1799,1801,1802,1804,1806,1807,1809,
1811,1812,1814,1815,1817,1819,1820,1822,1824,1825,1827,1828,1830,1832,1833,1835,
1837,1838,1840,1841,1843,1845,1846,1848,1850,1851,1853,1854,1856,1858,1859,1861,
1864,1865,1867,1868,1870,1872,1873,1875,1877,1879,1880,1882,1884,1885,1887,1888,
1891,1892,1894,1895,1897,1899,1900,1902,1904,1906,1907,1909,1911,1912,1914,1915,
1918,1919,1921,1923,1925,1926,1928,1930,1932,1933,1935,1937,1939,1940,1942,1944,
1946,1947,1949,1951,1953,1954,1956,1958,1960,1961,1963,1965,1967,1968,1970,1972,
1975,1976,1978,1980,1982,1983,1985,1987,1989,1990,1992,1994,1996,1997,1999,2001,
2003,2004,2006,2008,2010,2011,2013,2015,2017,2019,2021,2022,2024,2026,2028,2029,
2032,2033,2035,2037,2039,2041,2043,2044,2047,2048,2050,2052,2054,2056,2058,2059,
2062,2063,2065,2067,2069,2071,2073,2074,2077,2078,2080,2082,2084,2086,2088,2089,
2092,2093,2095,2097,2099,2101,2103,2104,2107,2108,2110,2112,2114,2116,2118,2119,
2122,2123,2125,2127,2129,2131,2133,2134,2137,2139,2141,2142,2145,2146,2148,2150,
2153,2154,2156,2158,2160,2162,2164,2165,2168,2170,2172,2173,2176,2177,2179,2181,
2185,2186,2188,2190,2192,2194,2196,2197,2200,2202,2204,2205,2208,2209,2211,2213,
2216,2218,2220,2222,2223,2226,2227,2230,2232,2234,2236,2238,2239,2242,2243,2246,
2249,2251,2253,2255,2256,2259,2260,2263,2265,2267,2269,2271,2272,2275,2276,2279,
2281,2283,2285,2287,2288,2291,2292,2295,2297,2299,2301,2303,2304,2307,2308,2311,
2315,2317,2319,2321,2322,2325,2326,2329,2331,2333,2335,2337,2338,2341,2342,2345,
2348,2350,2352,2354,2355,2358,2359,2362,2364,2366,2368,2370,2371,2374,2375,2378,
2382,2384,2386,2388,2389,2392,2393,2396,2398,2400,2402,2404,2407,2410,2411,2414,
2417,2419,2421,2423,2424,2427,2428,2431,2433,2435,2437,2439,2442,2445,2446,2449,
2452,2454,2456,2458,2459,2462,2463,2466,2468,2470,2472,2474,2477,2480,2481,2484,
2488,2490,2492,2494,2495,2498,2499,2502,2504,2506,2508,2510,2513,2516,2517,2520,
2524,2526,2528,2530,2531,2534,2535,2538,2540,2542,2544,2546,2549,2552,2553,2556,
2561,2563,2565,2567,2568,2571,2572,2575,2577,2579,2581,2583,2586,2589,2590,2593);

{    Noise LFO waveform.

    Here are just 256 samples out of much longer data.

    It does NOT repeat every 256 samples on real chip and I wasnt able to find
    the point where it repeats (even in strings as long as 131072 samples).

    I only put it here because its better than nothing and perhaps
    someone might be able to figure out the real algorithm.


    Note that (due to the way the LFO output is calculated) it is quite
    possible that two values: 0x80 and 0x00 might be wrong in this table.
    To be exact:
        some 0x80 could be 0x81 as well as some 0x00 could be 0x01.}

lfo_noise_waveform:array[0..255] of byte=(
$FF,$EE,$D3,$80,$58,$DA,$7F,$94,$9E,$E3,$FA,$00,$4D,$FA,$FF,$6A,
$7A,$DE,$49,$F6,$00,$33,$BB,$63,$91,$60,$51,$FF,$00,$D8,$7F,$DE,
$DC,$73,$21,$85,$B2,$9C,$5D,$24,$CD,$91,$9E,$76,$7F,$20,$FB,$F3,
$00,$A6,$3E,$42,$27,$69,$AE,$33,$45,$44,$11,$41,$72,$73,$DF,$A2,

$32,$BD,$7E,$A8,$13,$EB,$D3,$15,$DD,$FB,$C9,$9D,$61,$2F,$BE,$9D,
$23,$65,$51,$6A,$84,$F9,$C9,$D7,$23,$BF,$65,$19,$DC,$03,$F3,$24,
$33,$B6,$1E,$57,$5C,$AC,$25,$89,$4D,$C5,$9C,$99,$15,$07,$CF,$BA,
$C5,$9B,$15,$4D,$8D,$2A,$1E,$1F,$EA,$2B,$2F,$64,$A9,$50,$3D,$AB,

$50,$77,$E9,$C0,$AC,$6D,$3F,$CA,$CF,$71,$7D,$80,$A6,$FD,$FF,$B5,
$BD,$6F,$24,$7B,$00,$99,$5D,$B1,$48,$B0,$28,$7F,$80,$EC,$BF,$6F,
$6E,$39,$90,$42,$D9,$4E,$2E,$12,$66,$C8,$CF,$3B,$3F,$10,$7D,$79,
$00,$D3,$1F,$21,$93,$34,$D7,$19,$22,$A2,$08,$20,$B9,$B9,$EF,$51,

$99,$DE,$BF,$D4,$09,$75,$E9,$8A,$EE,$FD,$E4,$4E,$30,$17,$DF,$CE,
$11,$B2,$28,$35,$C2,$7C,$64,$EB,$91,$5F,$32,$0C,$6E,$00,$F9,$92,
$19,$DB,$8F,$AB,$AE,$D6,$12,$C4,$26,$62,$CE,$CC,$0A,$03,$E7,$DD,
$E2,$4D,$8A,$A6,$46,$95,$0F,$8F,$F5,$15,$97,$32,$D4,$28,$1E,$55);

var
  tl_tab:array[0..TL_TAB_LEN-1] of smallint;
  // sin waveform table in 'decibel' scale */
  sin_tab:array[0..SIN_LEN-1] of word;
  // translate from D1L to volume index (16 D1L levels) */
  d1l_tab:array[0..15] of dword;
  salida_fm:array[0..2] of integer;

function sshr(num:int64;fac:byte):int64;inline;
begin
  if num<0 then sshr:=-(abs(num) shr fac)
    else sshr:=num shr fac;
end;

procedure init_tables;
var
	i,x,n:integer;
	o,m:single;
begin
	for x:=0 to TL_RES_LEN-1 do begin
		m:= (1 shl 16) / power(2,(x+1)*(ENV_STEP/4.0) / 8.0);
		m:=floor(m);

		// we never reach (1<<16) here due to the (x+1) */
		// result fits within 16 bits at maximum */

		n:=word(round(m));		// 16 bits here */
		n:=sshr(n,4);		// 12 bits here */
		if (n and 1)<>0 then n:=sshr(n,1)+1 // round to closest */
		  else n:=sshr(n,1);
    // 11 bits here (rounded) */
		n:=n*4;		// 13 bits here (as in real chip) */
		tl_tab[x*2+0]:=n;
		tl_tab[x*2+1]:=-tl_tab[x*2+0];
		for i:=1 to 12 do begin
			tl_tab[ x*2+0 + i*2*TL_RES_LEN ]:=sshr(tl_tab[ x*2+0 ],i);
			tl_tab[ x*2+1 + i*2*TL_RES_LEN ]:= -tl_tab[ x*2+0 + i*2*TL_RES_LEN ];
		end;
	end;

	for i:=0 to SIN_LEN-1 do begin
		// non-standard sinus */
		m:= sin(((i*2)+1)*M_PI/SIN_LEN ); // verified on the real chip */

		// we never reach zero here due to ((i*2)+1) */

		if (m>0.0) then o:= 8*ln(1.0/m)/ln(2)	// convert to 'decibels' */
		  else o:= 8*ln(-1.0/m)/ln(2);	// convert to 'decibels' */
		o:=o/(ENV_STEP/4);

		n:=word(round(2.0*o));
		if (n and 1)<>0 then n:=sshr(n,1)+1 // round to closest */
		  else n:=sshr(n,1);
    if (m>=0)then sin_tab[i]:=n*2+0
      else sin_tab[i]:=n*2+1;
	end;
	// calculate d1l_tab table */
	for i:=0 to 15 do begin
		if i<>15 then m:=i*(4.0/ENV_STEP)
      else m:=(i+16)*(4.0/ENV_STEP);   // every 3 'dB' except for all bits = 1 = 45+48 'dB' */
		d1l_tab[i]:=trunc(m);
	end;
end;

procedure init_chip_tables(chip:pYM2151);
var
	i,j:integer;
	mult,phaseinc,Hz,pom:single;
	scaler:single;
begin
	scaler:=(chip.clock/64.0)/(chip.sampfreq);
	{ this loop calculates Hertz values for notes from c-0 to b-7 */
	/* including 64 'cents' (100/64 that is 1.5625 of real cent) per note */
	/* i*100/64/1200 is equal to i/768

	/* real chip works with 10 bits fixed point values (10.10) }
	mult:= (1 shl (FREQ_SH-10)); // -10 because phaseinc_rom table values are already in 10.10 format */
	for i:=0 to 767 do begin
		// 3.4375 Hz is note A; C# is 4 semitones higher */
		phaseinc:= phaseinc_rom[i];	// real chip phase increment */
		phaseinc:=phaseinc*scaler;			// adjust */
		// octave 2 - reference octave */
		chip.freq[768+2*768+i]:=(trunc(phaseinc*mult)) and $ffffffc0; // adjust to X.10 fixed point */
		// octave 0 and octave 1 */
		for j:=0 to 1 do chip.freq[768+j*768+i]:=(chip.freq[768+2*768+i] shr (2-j)) and $ffffffc0; // adjust to X.10 fixed point */
		// octave 3 to 7 */
		for j:=3 to 7 do chip.freq[768+j*768+i]:=chip.freq[768+2*768+i] shl (j-2);
	end;
	// octave -1 (all equal to: oct 0, _KC_00_, _KF_00_) */
	for i:=0 to 767 do chip.freq[ 0*768 + i ]:= chip.freq[1*768+0];
	// octave 8 and 9 (all equal to: oct 7, _KC_14_, _KF_63_) */
	for j:=8 to 9 do begin
		for i:=0 to 767 do chip.freq[768+j*768+i]:=chip.freq[768+8*768-1];
	end;

	mult:= (1 shl FREQ_SH);
	for j:=0 to 3 do begin
		for i:=0 to 31 do begin
			Hz:=(dt1_tab[j*32+i]*(chip.clock/64.0))/(1 shl 20);
			//calculate phase increment*/
			phaseinc:=(Hz*SIN_LEN)/chip.sampfreq;
			//positive and negative values*/
			chip.dt1_freq[(j+0)*32+i]:=trunc(phaseinc*mult);
			chip.dt1_freq[(j+4)*32+i]:=-chip.dt1_freq[(j+0)*32+i];
		end;
	end;
	// calculate timers' deltas */
	// User's Manual pages 15,16  */
  	//mult:= (1 shl TIMER_SH);
	for i:=0 to 1023 do begin
    pom:=64*(1024-i)*(sound_status.cpu_clock/chip.clock);
    chip.timer_A_time[i]:=pom;  // number of samples that timer period takes (fixed point) */
	end;
	for i:=0 to 255 do begin
		pom:=1024*(256-i)*(sound_status.cpu_clock/chip.clock);
    chip.timer_B_time[i]:=pom;  // number of samples that timer period takes (fixed point) */
	end;

	// calculate noise periods table */
	scaler:= ( chip.clock / 64.0 ) / chip.sampfreq;
	for i:=0 to 31 do begin
    if i<>31 then pom:=i // rate 30 and 31 are the same */
      else pom:=30;
		pom:=32-pom;
		pom:=65536.0 /(pom*32.0);	// number of samples per one shift of the shift register */
		// chip->noise_tab[i] = j * 64;*/	/* number of chip clock cycles per one shift */
		chip.noise_tab[i]:=trunc(pom * 64 * scaler);
  end;
end;

procedure KEY_ON(num:byte;n_op:byte;key_set:byte);
var
	chip:pYM2151;
  tmp:single;
  op:pYM2151Operator;
begin
    chip:=FM2151[num];
    op:=chip.oper[n_op];
		if (op.key=0) then begin
			op.phase:=0;			// clear phase */
			op.state:=EG_ATT;		// KEY ON = attack */
      tmp:=(not(op.volume)*(eg_inc[op.eg_sel_ar+((chip.eg_cnt shr op.eg_sh_ar) and 7)]))/16;
			op.volume:=trunc(op.volume+tmp);
			if (op.volume<=MIN_ATT_INDEX) then begin
				op.volume:= MIN_ATT_INDEX;
				op.state:= EG_DEC;
			end;
		end;
		op.key:=op.key or key_set;
end;

procedure KEY_OFF(op:pYM2151Operator;key_clr:cardinal);
begin
		if (op.key<>0) then begin
			op.key:=op.key and not(key_clr);
			if (op.key=0) then begin
				if (op.state>EG_REL) then op.state:= EG_REL;// KEY OFF =release */
			end;
		end;
end;

procedure envelope_KONKOFF(num:byte;n_op:byte;v:integer);inline;
var
	chip:pYM2151;
begin
  chip:=FM2151[num];
	if (v and $08)<>0 then KEY_ON (num,n_op,1) // M1 */
	  else KEY_OFF(chip.oper[n_op+0],1);

	if (v and $20)<>0 then KEY_ON (num,n_op+1, 1) // M2 */
	  else KEY_OFF(chip.oper[n_op+1],1);

	if (v and $10)<>0 then KEY_ON (num,n_op+2, 1) // C1 */
	  else KEY_OFF(chip.oper[n_op+2],1);

	if (v and $40)<>0 then KEY_ON (num,n_op+3, 1) // C2 */
	  else KEY_OFF(chip.oper[n_op+3],1);
end;

procedure set_connect(num,op:byte;cha,v:integer);inline;
var
	om1,om2:pYM2151Operator;
	oc1:pYM2151Operator;
	chip:pYM2151;
begin
  chip:=FM2151[num];
  om1:=chip.oper[op];
  om2:=chip.oper[op+1];
	oc1:=chip.oper[op+2];

	// set connect algorithm */

	// MEM is simply one sample delay */

	case (v and 7) of
	0:begin
		// M1---C1---MEM---M2---C2---OUT */
		om1.connect:=@chip.c1;
		oc1.connect:=@chip.mem;
		om2.connect:=@chip.c2;
		om1.mem_connect:=@chip.m2;
		end;
	1:begin
		// M1------+-MEM---M2---C2---OUT */
		//      C1-+                     */
		om1.connect:=@chip.mem;
		oc1.connect:=@chip.mem;
		om2.connect:=@chip.c2;
		om1.mem_connect:=@chip.m2;
		end;
	2:begin
		// M1-----------------+-C2---OUT */
		//      C1---MEM---M2-+          */
		om1.connect:=@chip.c2;
		oc1.connect:=@chip.mem;
		om2.connect:=@chip.c2;
		om1.mem_connect:=@chip.m2;
		end;
	3:begin
		// M1---C1---MEM------+-C2---OUT */
		//                 M2-+          */
		om1.connect:=addr(chip.c1);
		oc1.connect:=addr(chip.mem);
		om2.connect:=addr(chip.c2);
		om1.mem_connect:=addr(chip.c2);
		end;
	4:begin
		// M1---C1-+-OUT */
		// M2---C2-+     */
		// MEM: not used */
		om1.connect:=addr(chip.c1);
		oc1.connect:=addr(chip.chanout[cha]);
		om2.connect:=addr(chip.c2);
		om1.mem_connect:=addr(chip.mem);	// store it anywhere where it will not be used */
		end;

	5:begin
		//    +----C1----+     */
		// M1-+-MEM---M2-+-OUT */
		//    +----C2----+     */
		om1.connect:=nil;	// special mark */
		oc1.connect:=addr(chip.chanout[cha]);
		om2.connect:=addr(chip.chanout[cha]);
		om1.mem_connect:=addr(chip.m2);
		end;

	6:begin
		// M1---C1-+     */
		//      M2-+-OUT */
		//      C2-+     */
		// MEM: not used */
		om1.connect:=addr(chip.c1);
		oc1.connect:=addr(chip.chanout[cha]);
		om2.connect:=addr(chip.chanout[cha]);
		om1.mem_connect:=addr(chip.mem);	// store it anywhere where it will not be used */
		end;

	7:begin
		// M1-+     */
		// C1-+-OUT */
		// M2-+     */
		// C2-+     */
		// MEM: not used*/
		om1.connect:=addr(chip.chanout[cha]);
		oc1.connect:=addr(chip.chanout[cha]);
		om2.connect:=addr(chip.chanout[cha]);
		om1.mem_connect:=addr(chip.mem);	// store it anywhere where it will not be used */
		end;
	end;
end;

procedure refresh_EG(num,n_op:byte);inline;
var
	kc:dword;
	v,f:dword;
	chip:pYM2151;
  op:pYM2151Operator;
begin
  chip:=FM2151[num];
  op:=chip.oper[n_op];
  kc:=op.kc;
	// v = 32 + 2*RATE + RKS = max 126 */
for f:=0 to 3 do begin
  op:=chip.oper[n_op+f];
	v:= kc shr op.ks;
	if ((op.ar+v)<(32+62)) then begin
		op.eg_sh_ar:=eg_rate_shift[(op.ar+v) and $7f];
		op.eg_sel_ar:=eg_rate_select[(op.ar+v) and $7f];
	end else begin
		op.eg_sh_ar:= 0;
		op.eg_sel_ar:=17*RATE_STEPS;
	end;
	op.eg_sh_d1r:=eg_rate_shift[(op.d1r+v) and $7f];
	op.eg_sel_d1r:=eg_rate_select[(op.d1r+v) and $7f];
	op.eg_sh_d2r:=eg_rate_shift[(op.d2r+v) and $7f];
	op.eg_sel_d2r:=eg_rate_select[(op.d2r+v) and $7f];
	op.eg_sh_rr:=eg_rate_shift[(op.rr+v) and $7f];
	op.eg_sel_rr:=eg_rate_select[(op.rr+v) and $7f];
end;
end;

// write a register on YM2151 chip number 'n' */
procedure YM_2151WriteReg(num,r,v:byte);
var
	chip:pYM2151;
	op,op2,op3,op4:pYM2151Operator;
  kc,kc_channel,olddt1_i,oldmul,oldks,oldar,olddt2:dword;
  n_op:byte;
  oldstate:integer;
begin
  chip:=FM2151[num];
  n_op:=(r and $07)*4+((r and $18) shr 3);
  r:=r and $ff;
  v:=v and $ff;
  op:=chip.oper[n_op];
	case (r and $e0) of
	$00:begin
		case r of
		  $01:begin	// LFO reset(bit 1), Test Register (other bits) */
			      chip.test:=v;
			      if (v and 2)<>0 then chip.lfo_phase:=0;
          end;
		  $08:envelope_KONKOFF(num,(v and 7)*4,v);
		  $0f:begin	// noise mode enable, noise period */
			      chip.noise:=v;
			      chip.noise_f:=chip.noise_tab[v and $1f];
          end;
		  $10:chip.timer_A_index:=(chip.timer_A_index and $003) or (v shl 2); // timer A hi */
		  $11:chip.timer_A_index:=(chip.timer_A_index and $3fc) or (v and 3); // timer A low */
		  $12:chip.timer_B_index:=v; // timer B */
		  $14:begin	// CSM, irq flag reset, irq enable, timer start/stop */
			      chip.irq_enable:=v;	// bit 3-timer B, bit 2-timer A, bit 7 - CSM */
			      if (v and $10)<>0 then begin	// reset timer A irq flag */
				      chip.status:=chip.status and cardinal(not(1));
				      oldstate:=chip.irqlinestate;
            	chip.irqlinestate:=chip.irqlinestate and not(1);
	            if ((oldstate=1) and (addr(chip.IRQ_Handler)<>nil)) then chip.irq_handler(CLEAR_LINE);
            end;
			      if (v and $20)<>0 then begin	// reset timer B irq flag */
              chip.status:=chip.status and cardinal(not(2));
              oldstate:=chip.irqlinestate;
            	chip.irqlinestate:=chip.irqlinestate and not(2);
	            if ((oldstate=2) and (addr(chip.IRQ_Handler)<>nil)) then chip.irq_handler(CLEAR_LINE);
            end;
			      if (v and $02)<>0 then begin	// load and start timer B */
					    if not(timers.timer[chip.timer_B].enabled) then begin
						    timers.timer[chip.timer_B].time_final:=chip.timer_B_time[chip.timer_B_index];
                timers.enabled(chip.timer_B,true);
    						chip.timer_B_index_old:=chip.timer_B_index;
              end;
			      end else begin		// stop timer B */
					    timers.enabled(chip.timer_B,false);
            end;
			      if (v and $01)<>0 then begin	// load and start timer A */
					    if not(timers.timer[chip.timer_a].enabled) then begin
						    timers.timer[chip.timer_a].time_final:=chip.timer_a_time[chip.timer_a_index];
                timers.enabled(chip.timer_a,true);
    						chip.timer_a_index_old:=chip.timer_a_index;
              end;
			      end else begin 		// stop timer A */
					    timers.enabled(chip.timer_a,false);
            end;
			end;
		$18:begin	// LFO frequency */
				  chip.lfo_overflow:=(1 shl ((15-(byte(v) shr 4))+3))*(1 shl LFO_SH);
				  chip.lfo_counter_add:=$10+(v and $0f);
        end;
		$19:if (v and $80)<>0 then chip.pmd:=v and $7f  // PMD (bit 7==1) or AMD (bit 7==0) */
			      else chip.amd:=v and $7f;
		$1b:begin	// CT2, CT1, LFO waveform */
			    chip.ct:=v shr 6;
			    chip.lfo_wsel:=v and 3;
			    if addr(chip.porthandler)<>nil then chip.porthandler(chip.ct);
        end;
    end; //del 2 case
  end; //del case
	$20:begin
    n_op:=(r and 7)*4;
		op:=chip.oper[n_op];
    op2:=chip.oper[n_op+1];
    op3:=chip.oper[n_op+2];
    op4:=chip.oper[n_op+3];
		case (r and $18) of
		  $00:begin	// RL enable, Feedback, Connection */
            if ((v shr 3) and 7)<>0 then op.fb_shift:=((v shr 3) and 7)+6
              else op.fb_shift:=0;
            if (v and $40)<>0 then chip.pan[(r and 7)*2]:=cardinal(not(0))
              else chip.pan[(r and 7)*2]:=0;
            if (v and $80)<>0 then chip.pan[(r and 7)*2+1]:=cardinal(not(0))
              else chip.pan[(r and 7)*2 +1]:=0;
			      chip.connect[r and 7]:=v and 7;
			      set_connect(num,n_op,r and 7,v and 7);
          end;
		  $08:begin	// Key Code */
			      v:=v and $7f;
			      if (v<>op.kc) then begin
				      kc_channel:=(v-(v shr 2))*64;
				      kc_channel:=kc_channel+768;
				      kc_channel:=kc_channel or (op.kc_i and 63);
				      op.kc:=v;
				      op.kc_i:=kc_channel;
				      op2.kc:=v;
				      op2.kc_i:=kc_channel;
				      op3.kc:=v;
				      op3.kc_i:=kc_channel;
				      op4.kc:=v;
				      op4.kc_i:=kc_channel;
				      kc:=v shr 2;
				      op.dt1:= chip.dt1_freq[(op.dt1_i+kc) and $ff];
				      op.freq:=((chip.freq[kc_channel+op.dt2]+cardinal(op.dt1))*op.mul) shr 1;
				      op2.dt1:=chip.dt1_freq[(op2.dt1_i+kc) and $ff];
				      op2.freq:=((chip.freq[kc_channel+op2.dt2]+cardinal(op2.dt1))*op2.mul) shr 1;
				      op3.dt1:=chip.dt1_freq[(op3.dt1_i+kc) and $ff];
				      op3.freq:=((chip.freq[kc_channel+op3.dt2]+cardinal(op3.dt1))*op3.mul) shr 1;
				      op4.dt1:=chip.dt1_freq[(op4.dt1_i+kc) and $ff];
				      op4.freq:=((chip.freq[kc_channel+op4.dt2]+cardinal(op4.dt1))*op4.mul) shr 1;
				      refresh_EG(num,n_op);
            end;
        end;
		  $10:begin	// Key Fraction */
			      v:=v shr 2;
			      if (v<>(op.kc_i and 63)) then begin
				      kc_channel:=v;
				      kc_channel:=kc_channel or (op.kc_i and cardinal(not(63)));
				      op.kc_i:=kc_channel;
				      op2.kc_i:=kc_channel;
				      op3.kc_i:=kc_channel;
				      op4.kc_i:=kc_channel;
      				op.freq:=((chip.freq[kc_channel+op.dt2]+cardinal(op.dt1))*op.mul) shr 1;
      				op2.freq:=((chip.freq[kc_channel+op2.dt2]+cardinal(op2.dt1))*op2.mul) shr 1;
      				op3.freq:=((chip.freq[kc_channel+op3.dt2]+cardinal(op3.dt1))*op3.mul) shr 1;
              op4.freq:=((chip.freq[kc_channel+op4.dt2]+cardinal(op4.dt1))*op4.mul) shr 1;
      			end;
          end;
		  $18:begin	// PMS, AMS */
      			op.pms:=(v shr 4) and 7;
			      op.ams:=(v and 3);
          end;
		  end;
		end;
	$40:begin		// DT1, MUL */
			  olddt1_i:=op.dt1_i;
			  oldmul:=op.mul;
			  op.dt1_i:=(v and $70) shl 1;
        if (v and $0f)<>0 then op.mul:=(v and $0f) shl 1
          else op.mul:=1;
			  if (olddt1_i<>op.dt1_i) then op.dt1:= chip.dt1_freq[(op.dt1_i+(op.kc shr 2)) and $ff];
			  if ((olddt1_i<>op.dt1_i) or (oldmul<>op.mul)) then op.freq:=((chip.freq[op.kc_i+op.dt2]+cardinal(op.dt1))*op.mul) shr 1;
      end;
	$60:begin		// TL */
        op.tl:=(v and $7f) shl (ENV_BITS-7); // 7bit TL */
      end;
	$80:begin		// KS, AR */
			  oldks:=op.ks;
			  oldar:=op.ar;
			  op.ks:=5-(v shr 6);
        if (v and $1f)<>0 then op.ar:=32+((v and $1f) shl 1)
          else op.ar:=0;
			  if ((op.ar<>oldar) or (op.ks<>oldks)) then begin
				  if ((op.ar+(op.kc shr op.ks))<(32+62)) then begin
					  op.eg_sh_ar:=eg_rate_shift[(op.ar+(op.kc shr op.ks)) and $7f];
					  op.eg_sel_ar:=eg_rate_select[(op.ar+(op.kc shr op.ks)) and $7f];
				  end	else begin
					  op.eg_sh_ar:=0;
					  op.eg_sel_ar:=17*RATE_STEPS;
				  end;
        end;
			  if (op.ks<>oldks) then begin
				  op.eg_sh_d1r:=eg_rate_shift[(op.d1r+(op.kc shr op.ks)) and $7f];
				  op.eg_sel_d1r:=eg_rate_select[(op.d1r+(op.kc shr op.ks)) and $7f];
				  op.eg_sh_d2r:=eg_rate_shift[(op.d2r+(op.kc shr op.ks)) and $7f];
				  op.eg_sel_d2r:=eg_rate_select[(op.d2r+(op.kc shr op.ks)) and $7f];
				  op.eg_sh_rr:=eg_rate_shift[(op.rr+(op.kc shr op.ks)) and $7f];
				  op.eg_sel_rr:=eg_rate_select[(op.rr+(op.kc shr op.ks)) and $7f];
        end;
		end;
	$a0:begin		// LFO AM enable, D1R */
          if (v and $80)<>0 then op.AMmask:=cardinal(not(0))
            else op.AMmask:=0;
          if (v and $1f)<>0 then op.d1r:=32+((v and $1f) shl 1)
            else op.d1r:=0;
		      op.eg_sh_d1r:=eg_rate_shift[(op.d1r+(op.kc shr op.ks)) and $7f];
		      op.eg_sel_d1r:=eg_rate_select[(op.d1r+(op.kc shr op.ks)) and $7f];
      end;
	$c0:begin		// DT2, D2R */
			    olddt2:=op.dt2;
			    op.dt2:=dt2_tab[(v shr 6) and 3];
			    if (op.dt2<>olddt2) then op.freq:=((chip.freq[op.kc_i+op.dt2]+cardinal(op.dt1))*op.mul) shr 1;
          if (v and $1f)<>0 then op.d2r:=32+((v and $1f) shl 1)
            else op.d2r:=0;
		      op.eg_sh_d2r:=eg_rate_shift[(op.d2r+(op.kc shr op.ks)) and $7f];
		      op.eg_sel_d2r:=eg_rate_select[(op.d2r+(op.kc shr op.ks)) and $7f];
      end;
	$e0:begin		// D1L, RR */
		      op.d1l:=d1l_tab[(v shr 4) and $f];
		      op.rr:=34+((v and $0f) shl 2);
		      op.eg_sh_rr:=eg_rate_shift[(op.rr+(op.kc shr op.ks)) and $7f];
		      op.eg_sel_rr:=eg_rate_select[(op.rr+(op.kc shr op.ks)) and $7f];
		  end;
	end;
end;

function YM_2151ReadStatus(num:byte):byte;
var
  chip:pYM2151;
begin
	chip:=FM2151[num];
	YM_2151ReadStatus:=chip.status;
end;

procedure YM_2151Init(num:byte;clock:dword);
var
  f:byte;
begin
	getmem(FM2151[num],sizeof(YM2151));
  fillchar(FM2151[num]^,sizeof(YM2151),0);
  for f:=0 to 31 do begin
    getmem(FM2151[num].oper[f],sizeof(YM2151Operator));
    fillchar(FM2151[num].oper[f]^,sizeof(YM2151Operator),0);
  end;
	FM2151[num].clock:=clock;
	//rate = clock/64;*/
	FM2151[num].sampfreq:=FREQ_BASE_AUDIO;	// avoid division by 0 in init_chip_tables()
	init_chip_tables(FM2151[num]);
	FM2151[num].lfo_timer_add:=trunc((1 shl LFO_SH)*(clock/64.0)/FM2151[num].sampfreq);
	FM2151[num].eg_timer_add:=trunc((1 shl EG_SH)*(clock/64.0)/FM2151[num].sampfreq);
	FM2151[num].eg_timer_overflow:=(3)*(1 shl EG_SH);
  FM2151[num].timer_a:=timers.init(sound_status.cpu_num,1,nil,timer_a_exec,false,num);
  FM2151[num].timer_b:=timers.init(sound_status.cpu_num,1,nil,timer_b_exec,false,num);
	YM_2151ResetChip(num);
  init_tables();
end;

procedure YM_2151Close(num:byte);
var
  i:byte;
begin
if FM2151[num]<>nil then begin
  for i:=0 to 31 do begin
    freemem(FM2151[num].oper[i]);
    FM2151[num].oper[i]:=nil;
  end;
  freemem(FM2151[num]);
  FM2151[num]:=nil;
end;
end;

procedure YM_2151ResetChip(num:byte);
var
  chip:pYM2151;
  i:integer;
begin
	chip:=FM2151[num];
	// initialize hardware registers */
	for i:=0 to 31 do begin
		fillchar(chip.oper[i]^,sizeof(YM2151Operator),0);
		chip.oper[i].volume:=MAX_ATT_INDEX;
    chip.oper[i].kc_i:=768; // min kc_i value */
	end;
	chip.eg_timer:=0;
	chip.eg_cnt:=0;
	chip.lfo_timer:=0;
	chip.lfo_counter:=0;
	chip.lfo_phase:=0;
	chip.lfo_wsel:=0;
	chip.pmd:=0;
	chip.amd:=0;
	chip.lfa:=0;
	chip.lfp:=0;
	chip.test:=0;
	chip.irq_enable:=0;
	chip.timer_A_index:=0;
	chip.timer_B_index:=0;
	chip.timer_A_index_old:=0;
	chip.timer_B_index_old:=0;
	chip.noise:=0;
	chip.noise_rng:=0;
	chip.noise_p:=0;
	chip.noise_f:=chip.noise_tab[0];
	chip.csm_req:=0;
	chip.status:=0;
	YM_2151WriteReg(num,$1b,0);	// only because of CT1, CT2 output pins */
	YM_2151WriteReg(num,$18,0);	// set LFO frequency */
	for i:=$20 to $ff do YM_2151WriteReg(num,i,0);	// set the operators */
  timers.enabled(chip.timer_a,false);
  timers.enabled(chip.timer_b,false);
  chip.irqlinestate:=0;
end;

function op_calc(OP:pYM2151Operator;env:dword;pm:integer):integer;
var
	p:dword;
  tmp:int64;
begin
  tmp:=integer(OP.phase and not(FREQ_MASK))+(pm shl 15);
	p:=(env shl 3)+sin_tab[sshr(tmp,FREQ_SH) and SIN_MASK];
	if (p>=TL_TAB_LEN) then op_calc:=0
	  else op_calc:=tl_tab[p];
end;

function op_calc1(OP:pYM2151Operator;env:dword;pm:integer):integer;
var
	p,i:integer;
begin
	i:=(OP.phase and not(FREQ_MASK))+pm;
	p:=(env shl 3)+sin_tab[sshr(i,FREQ_SH) and SIN_MASK];
	if (p>=TL_TAB_LEN) then op_calc1:=0
	  else op_calc1:=tl_tab[p];
end;

function volume_calc(OP:pYM2151Operator;AM:dword):dword;
begin
 volume_calc:=OP.tl+cardinal(OP.volume)+(AM and OP.AMmask);
end;

procedure chan_calc(num:byte;chan:word);
var
	op,op2,op3,op4:pYM2151Operator;
  env,AM:dword;
  chip:pYM2151;
  _out:longint;
begin
  chip:=FM2151[num];
  AM:=0;
	chip.m2:=0;
  chip.c1:=0;
  chip.c2:=0;
  chip.mem:=0;
	op:=chip.oper[chan*4];	// M1 */
  op2:=chip.oper[(chan*4)+1];
  op3:=chip.oper[(chan*4)+2];
  op4:=chip.oper[(chan*4)+3];

	op.mem_connect^:=op.mem_value;	// restore delayed sample (MEM) value to m2 or c2 */

	if (op.ams<>0) then AM:=chip.lfa shl (op.ams-1);
	env:=volume_calc(op,AM);

  _out:=op.fb_out_prev+op.fb_out_curr;
	op.fb_out_prev:=op.fb_out_curr;

		if (op.connect=nil) then begin // algorithm 5 */
      chip.mem:=op.fb_out_prev;
      chip.c1:=op.fb_out_prev;
      chip.c2:=op.fb_out_prev;
		end else begin // other algorithms */
			op.connect^:=op.fb_out_prev;
    end;
		op.fb_out_curr:=0;
		if (env < ENV_QUIET) then begin
			if (op.fb_shift=0) then _out:=0;
			op.fb_out_curr:=op_calc1(op, env,_out shl op.fb_shift);
		end;

	env:= volume_calc(op2,AM);	// M2 */
	if (env<ENV_QUIET) then op2.connect^:=op2.connect^ + op_calc(op2, env, chip.m2);

	env:= volume_calc(op3,AM);	// C1 */
	if (env<ENV_QUIET) then op3.connect^:=op3.connect^+ op_calc(op3, env, chip.c1);

	env:= volume_calc(op4,AM);	// C2 */
	if (env<ENV_QUIET) then chip.chanout[chan]:=chip.chanout[chan]+op_calc(op4, env, chip.c2);
  // M1 */
	op.mem_value:=chip.mem;

end;

procedure chan7_calc(num:byte);
var
	op,op2,op3,op4:pYM2151Operator;
	env,AM,noiseout:dword;
  chip:pYM2151;
  _out:longint;
begin
  chip:=FM2151[num];
  AM:=0;
	chip.m2:=0;
  chip.c1:=0;
  chip.c2:=0;
  chip.mem:=0;
	op:=chip.oper[7*4];		// M1 */
  op2:=chip.oper[(7*4)+1];
  op3:=chip.oper[(7*4)+2];
  op4:=chip.oper[(7*4)+3];
  // restore delayed sample (MEM) value to m2 or c2 */
	op.mem_connect^:=op.mem_value;
	if (op.ams<>0) then AM:=chip.lfa shl (op.ams-1);
	env:=volume_calc(op,AM);
  _out:=op.fb_out_prev+op.fb_out_curr;
  op.fb_out_prev:=op.fb_out_curr;
  // algorithm 5 */
  if (op.connect=nil) then begin
    chip.mem:=op.fb_out_prev;
    chip.c1:=op.fb_out_prev;
    chip.c2:=op.fb_out_prev;
  end else begin // other algorithms */
    op.connect^:=op.fb_out_prev;
  end;
  op.fb_out_curr:=0;
  if (env<ENV_QUIET) then begin
    if (op.fb_shift=0) then _out:=0;
    op.fb_out_curr:=op_calc1(op,env,_out shl op.fb_shift);
  end;
	env:=volume_calc(op2,AM);	// M2 */
	if (env<ENV_QUIET) then op2.connect^:=op2.connect^+op_calc(op2,env,chip.m2);
	env:=volume_calc(op3,AM);	// C1 */
	if (env<ENV_QUIET) then op3.connect^:=op3.connect^+op_calc(op3,env,chip.c1);
	env:=volume_calc(op4,AM);	// C2 */
	if (chip.noise and $80)<>0 then begin
		noiseout:=0;
		if (env<$3ff) then noiseout:=(env xor $3ff)*2;	// range of the YM2151 noise output is -2044 to 2040 */
    if (chip.noise_rng and $10000)<>0 then chip.chanout[7]:=chip.chanout[7]+integer(noiseout)
      else chip.chanout[7]:=chip.chanout[7]-integer(noiseout); // bit 16 -> output */
	end	else begin
		if (env<ENV_QUIET) then
      chip.chanout[7]:=chip.chanout[7]+op_calc(op4,env,chip.c2);
	end;
  // M1 */
	op.mem_value:=chip.mem;
end;

procedure advance_eg(num:byte);
var
	op:pYM2151Operator;
  chip:pYM2151;
  i,n_op:byte;
  tmp:single;
begin
  chip:=FM2151[num];
	chip.eg_timer:=chip.eg_timer+chip.eg_timer_add;
	while (chip.eg_timer>=chip.eg_timer_overflow) do begin
		chip.eg_timer:=chip.eg_timer-chip.eg_timer_overflow;
		chip.eg_cnt:=chip.eg_cnt+1;
		// envelope generator */
    n_op:=0;
    i:=32;
		while (i<>0) do begin
      op:=chip.oper[n_op];	// CH 0 M1 */
			case (op.state) of
			  EG_ATT:begin	// attack phase */
				        if ((chip.eg_cnt and ((1 shl op.eg_sh_ar)-1))=0) then begin
                  tmp:=(not(op.volume)*(eg_inc[op.eg_sel_ar+((chip.eg_cnt shr op.eg_sh_ar) and 7)]))/16;
					        op.volume:=trunc(op.volume+tmp);
					        if (op.volume<=MIN_ATT_INDEX) then begin
						        op.volume:=MIN_ATT_INDEX;
						        op.state:=EG_DEC;
                  end;
                end;
              end;
			  EG_DEC:begin	// decay phase */
				        if ((chip.eg_cnt and ((1 shl op.eg_sh_d1r)-1))=0) then begin
					        op.volume:=op.volume+eg_inc[op.eg_sel_d1r+((chip.eg_cnt shr op.eg_sh_d1r) and 7)];
					        if (op.volume>=op.d1l) then op.state:=EG_SUS;
                end;
               end;
			  EG_SUS:begin	// sustain phase */
				        if ((chip.eg_cnt and ((1 shl op.eg_sh_d2r)-1))=0) then begin
					        op.volume:=op.volume+eg_inc[op.eg_sel_d2r+((chip.eg_cnt shr op.eg_sh_d2r) and 7)];
					        if (op.volume>=MAX_ATT_INDEX) then begin
						        op.volume:=MAX_ATT_INDEX;
						        op.state:=EG_OFF;
					        end;
                end;
              end;

			  EG_REL:begin	// release phase */
				        if ((chip.eg_cnt and ((1 shl op.eg_sh_rr)-1))=0) then begin
					        op.volume:=op.volume + eg_inc[op.eg_sel_rr+((chip.eg_cnt shr op.eg_sh_rr) and 7)];
					        if (op.volume>=MAX_ATT_INDEX) then begin
						        op.volume:=MAX_ATT_INDEX;
						        op.state:=EG_OFF;
                  end;
				        end;
              end;
			end;
			n_op:=n_op+1;
      i:=i-1;
		end;
	end;
end;

procedure advance(num:byte);
var
	op,op2,op3,op4:pYM2151Operator;
	i:dword;
	a,p:integer;
  chip:pYM2151;
  j:dword;
  mod_ind:longint;
  kc_channel:dword;
  n_op:byte;
begin
  chip:=FM2151[num];
	// LFO */
	if (chip.test and 2)<>0 then begin
		chip.lfo_phase:=0;
	end else begin
		chip.lfo_timer:=chip.lfo_timer+chip.lfo_timer_add;
		if (chip.lfo_timer>=chip.lfo_overflow) then begin
			chip.lfo_timer:=chip.lfo_timer-chip.lfo_overflow;
			chip.lfo_counter:=chip.lfo_counter+chip.lfo_counter_add;
			chip.lfo_phase:=chip.lfo_phase+(chip.lfo_counter shr 4);
			chip.lfo_phase:=chip.lfo_phase and 255;
			chip.lfo_counter:=chip.lfo_counter and 15;
		end;
	end;
	i:=chip.lfo_phase;
	// calculate LFO AM and PM waveform value (all verified on real chip, except for noise algorithm which is impossible to analyse)*/
	case chip.lfo_wsel of
	 0:begin
		// saw */
		// AM: 255 down to 0 */
		// PM: 0 to 127, -127 to 0 (at PMD=127: LFP = 0 to 126, -126 to 0) */
		a:=255-i;
		if (i<128) then p:=i
		  else p:=i-255;
		end;
	 1:begin
  		// square */
  		// AM: 255, 0 */
  		// PM: 128,-128 (LFP = exactly +PMD, -PMD) */
  		if (i<128) then begin
  			a:= 255;
  			p:= 128;
  		end else begin
  			a:= 0;
  			p:=-128;
  		end;
     end;
	2:begin
		// triangle */
		// AM: 255 down to 1 step -2; 0 up to 254 step +2 */
		// PM: 0 to 126 step +2, 127 to 1 step -2, 0 to -126 step -2, -127 to -1 step +2*/
		if (i<128) then a:=255-(i*2)
		  else a:=(i*2)-256;
    if (i<64)	then 					// i = 0..63 */
          p:= i*2					// 0 to 126 step +2 */
		    else if (i<128)	then 				// i = 64..127 */
            p:=255-i*2			// 127 to 1 step -2 */
			  else if (i<192)	then 		// i = 128..191 */
              p:=256-i*2		// 0 to -126 step -2*/
				else					// i = 192..255 */
                p:=i*2-511;		//-127 to -1 step +2*/
		end;
	else begin
		// random */
		// the real algorithm is unknown !!!
    // We just use a snapshot of data from real chip */
		// AM: range 0 to 255    */
		// PM: range -128 to 127 */
		a:= lfo_noise_waveform[i];
		p:= a-128;
		end;
	end;
	chip.lfa:=trunc(a*chip.amd/128);
	chip.lfp:=trunc(p*chip.pmd/128);
	{  The Noise Generator of the YM2151 is 17-bit shift register.
    *   Input to the bit16 is negated (bit0 XOR bit3) (EXNOR).
    *   Output of the register is negated (bit0 XOR bit3).
    *   Simply use bit16 as the noise output.}
	chip.noise_p:=chip.noise_p+chip.noise_f;
	i:=(chip.noise_p shr 16);		// number of events (shifts of the shift register) */
	chip.noise_p:=chip.noise_p and $ffff;
	while (i<>0) do begin
		j:=((chip.noise_rng xor (chip.noise_rng shr 3)) and 1) xor 1;
		chip.noise_rng:=(j shl 16) or (chip.noise_rng shr 1);
		i:=i-1;
	end;
	// phase generator */
  n_op:=0;
  i:=8;
	while (i<>0) do begin
    op:=chip.oper[n_op];	// CH 0 M1 */
    op2:=chip.oper[n_op+1];
    op3:=chip.oper[n_op+2];
    op4:=chip.oper[n_op+3];
		if (op.pms<>0)	then begin // only when phase modulation from LFO is enabled for this channel */
			mod_ind:=chip.lfp;		// -128..+127 (8bits signed) */
			if (op.pms<6) then mod_ind:=sshr(mod_ind,(6-op.pms))
        else mod_ind:=mod_ind shl (op.pms-5);
			if (mod_ind<>0) then begin
				kc_channel:=op.kc_i+cardinal(mod_ind);
				op.phase:=op.phase+sshr(((chip.freq[kc_channel+op.dt2]+op.dt1)*op.mul),1);
        op2.phase:=op2.phase+sshr(((chip.freq[kc_channel+op2.dt2]+op2.dt1)*op2.mul),1);
        op3.phase:=op3.phase+sshr(((chip.freq[kc_channel+op3.dt2]+op3.dt1)*op3.mul),1);
        op4.phase:=op4.phase+sshr(((chip.freq[kc_channel+op4.dt2]+op4.dt1)*op4.mul),1);
			end	else begin		// phase modulation from LFO is equal to zero */
				op.phase:=op.phase+op.freq;
				op2.phase:=op2.phase+op2.freq;
				op3.phase:=op3.phase+op3.freq;
				op4.phase:=op4.phase+op4.freq;
			end;
		end	else begin			// phase modulation from LFO is disabled */
				op.phase:=op.phase+op.freq;
				op2.phase:=op2.phase+op2.freq;
				op3.phase:=op3.phase+op3.freq;
				op4.phase:=op4.phase+op4.freq;
		end;
		n_op:=n_op+4;
    i:=i-1;
	end;
	{ CSM is calculated *after* the phase generator calculations (verified on real chip)
    * CSM keyon line seems to be ORed with the KO line inside of the chip.
    * The result is that it only works when KO (register 0x08) is off, ie. 0
    *
    * Interesting effect is that when timer A is set to 1023, the KEY ON happens
    * on every sample, so there is no KEY OFF at all - the result is that
    * the sound played is the same as after normal KEY ON.}
	if (chip.csm_req<>0) then begin			// CSM KEYON/KEYOFF seqeunce request */
		if (chip.csm_req=2)	then begin // KEY ON */
      n_op:=0;
      i:=32;
			while (i<>0) do begin
				KEY_ON(num,n_op,2);
        n_op:=n_op+1;
        i:=i-1;
      end;
			chip.csm_req:=1;
		end	else begin					// KEY OFF */
      n_op:=0;
      i:=32;
			while (i<>0) do begin
        op:=chip.oper[n_op];	// CH 0 M1 */
				KEY_OFF(op,2);
				n_op:=n_op+1;
        i:=i-1;
			end;
			chip.csm_req:=0;
		end;
	end;
end;

function YM_2151UpdateOne(num:byte):pinteger;
var
	outl,outr:integer;
  chip:pYM2151;
begin
    chip:=FM2151[num];
	  advance_eg(num);
		chip.chanout[0]:=0;
		chip.chanout[1]:=0;
		chip.chanout[2]:=0;
		chip.chanout[3]:=0;
		chip.chanout[4]:=0;
		chip.chanout[5]:=0;
		chip.chanout[6]:=0;
		chip.chanout[7]:=0;

		chan_calc(num,0);
		chan_calc(num,1);
		chan_calc(num,2);
		chan_calc(num,3);
		chan_calc(num,4);
		chan_calc(num,5);
		chan_calc(num,6);
		chan7_calc(num);

		outl:=chip.chanout[0] and chip.pan[0];
		outr:=chip.chanout[0] and chip.pan[1];
		outl:=outl+(chip.chanout[1] and chip.pan[2]);
		outr:=outr+(chip.chanout[1] and chip.pan[3]);
		outl:=outl+(chip.chanout[2] and chip.pan[4]);
		outr:=outr+(chip.chanout[2] and chip.pan[5]);
		outl:=outl+(chip.chanout[3] and chip.pan[6]);
		outr:=outr+(chip.chanout[3] and chip.pan[7]);
		outl:=outl+(chip.chanout[4] and chip.pan[8]);
		outr:=outr+(chip.chanout[4] and chip.pan[9]);
		outl:=outl+(chip.chanout[5] and chip.pan[10]);
		outr:=outr+(chip.chanout[5] and chip.pan[11]);
		outl:=outl+(chip.chanout[6] and chip.pan[12]);
		outr:=outr+(chip.chanout[6] and chip.pan[13]);
		outl:=outl+(chip.chanout[7] and chip.pan[14]);
		outr:=outr+(chip.chanout[7] and chip.pan[15]);
		if (outl>MAXOUT) then outl:=MAXOUT
			else if (outl<MINOUT) then outl:=MINOUT;
		if (outr>MAXOUT) then outr:=MAXOUT
			else if (outr<MINOUT) then outr:=MINOUT;
    salida_fm[0]:=(outl+outr) div 2;
    salida_fm[1]:=outl;
    salida_fm[2]:=outr;
    advance(num);
    YM_2151UpdateOne:=@salida_fm[0];
end;

//Timers
procedure timer_a_exec(index:byte);
var
  chip:pYM2151;
  oldstate:integer;
begin
chip:=FM2151[index];
timers.timer[chip.timer_a].time_final:=chip.timer_A_time[chip.timer_A_index ];
chip.timer_A_index_old:=chip.timer_A_index;
if (chip.irq_enable and $04)<>0 then begin
		chip.status:=chip.status or 1;
		oldstate:=chip.irqlinestate;
  	chip.irqlinestate:=chip.irqlinestate or 1;
  	if ((oldstate=0) and (addr(chip.irq_handler)<>nil)) then chip.irq_handler(ASSERT_LINE);
end;
if (chip.irq_enable and $80)<>0 then
		chip.csm_req:=2;		// request KEY ON / KEY OFF sequence */
end;

procedure timer_b_exec(index:byte);
var
  chip:pYM2151;
  oldstate:integer;
begin
chip:=FM2151[index];
timers.timer[chip.timer_b].time_final:=chip.timer_b_time[chip.timer_b_index];
chip.timer_b_index_old:=chip.timer_b_index;
if (chip.irq_enable and $08)<>0 then begin
		chip.status:=chip.status or 2;
		oldstate:=chip.irqlinestate;
  	chip.irqlinestate:=chip.irqlinestate or 2;
  	if ((oldstate=0) and (addr(chip.irq_handler)<>nil)) then chip.irq_handler(ASSERT_LINE);
end;
end;

end.
