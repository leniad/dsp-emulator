unit cps1_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,m68000,main_engine,controls_engine,gfx_engine,timer_engine,ym_2151,
     oki6295,kabuki_decript,qsound,rom_engine,misc_functions,pal_engine,
     sound_engine,eeprom;

function iniciar_cps1:boolean;

implementation
type
  cps1_games_def=record
        layerctrl:word;
        palctrl:word;
        testaddr,testval:word;
        mula,mulb,mull,mulh:word;
        mask_sc1,mask_sc2,mask_sc3,mask_sc4:byte;
        pri_mask1,pri_mask2,pri_mask3,pri_mask4:word;
  end;
  cps1_long_bank_def=record
        tipo:byte;
        start_bank,end_bank:dword;
        num_bank:byte;
  end;
  cps1_bank_def=record
        lbank:array[0..3] of dword;
        bank:array[0..6] of cps1_long_bank_def;
  end;
const
        GFXTYPE_SPRITES=1 shl 0;
        GFXTYPE_SCROLL1=1 shl 1;
        GFXTYPE_SCROLL2=1 shl 2;
        GFXTYPE_SCROLL3=1 shl 3;
        GFXTYPE_STARS=1 shl 4;
        //Banks
        cps1_banks:array [0..10] of cps1_bank_def=(
{DM620}  (lbank:($8000,$2000,$2000,0);
          bank:((tipo:GFXTYPE_SCROLL3;start_bank:$8000;end_bank:$bfff;num_bank:1),(tipo:GFXTYPE_SPRITES;start_bank:$2000;end_bank:$3fff;num_bank:2),(tipo:GFXTYPE_STARS or GFXTYPE_SPRITES or GFXTYPE_SCROLL1 or GFXTYPE_SCROLL2 or GFXTYPE_SCROLL3;start_bank:$0;end_bank:$1ffff;num_bank:0),(),(),(),() )),
{S224B}  (lbank:($8000,$0000,$0000,0);
          bank:((tipo:GFXTYPE_SPRITES;start_bank:$0000;end_bank:$43ff;num_bank:0),(tipo:GFXTYPE_SCROLL1;start_bank:$4400;end_bank:$4bff;num_bank:0),(tipo:GFXTYPE_SCROLL3;start_bank:$4c00;end_bank:$5fff;num_bank:0),(tipo:GFXTYPE_SCROLL2;start_bank:$6000;end_bank:$7fff;num_bank:0),(),(),() )),
{KD29B}  (lbank:($8000,$8000,$0000,0);
          bank:((tipo:GFXTYPE_SPRITES;start_bank:$0000;end_bank:$7fff;num_bank:0),(tipo:GFXTYPE_SPRITES;start_bank:$8000;end_bank:$8fff;num_bank:1),(tipo:GFXTYPE_SCROLL2;start_bank:$9000;end_bank:$bfff;num_bank:1),(tipo:GFXTYPE_SCROLL1;start_bank:$c000;end_bank:$d7ff;num_bank:1),(tipo:GFXTYPE_SCROLL3;start_bank:$d800;end_bank:$ffff;num_bank:1),(),() )),
{STF29}  (lbank:($8000,$8000,$8000,0);
          bank:((tipo:GFXTYPE_SPRITES;start_bank:$0000;end_bank:$7fff;num_bank:0),(tipo:GFXTYPE_SPRITES;start_bank:$8000;end_bank:$ffff;num_bank:1),(tipo:GFXTYPE_SPRITES;start_bank:$10000;end_bank:$11fff;num_bank:2),(tipo:GFXTYPE_SCROLL3;start_bank:$2000;end_bank:$3fff;num_bank:2),(tipo:GFXTYPE_SCROLL1;start_bank:$4000;end_bank:$4fff;num_bank:2),(tipo:GFXTYPE_SCROLL2;start_bank:$5000;end_bank:$7fff;num_bank:2),() )),
{ST24M1} (lbank:($8000,$8000,$0000,0);
          bank:((tipo:GFXTYPE_STARS;start_bank:$0000;end_bank:$03ff;num_bank:0),(tipo:GFXTYPE_SPRITES;start_bank:$0000;end_bank:$4fff;num_bank:0),(tipo:GFXTYPE_SCROLL2;start_bank:$4000;end_bank:$7fff;num_bank:0),(tipo:GFXTYPE_SCROLL3;start_bank:$0000;end_bank:$7fff;num_bank:1),(tipo:GFXTYPE_SCROLL1;start_bank:$7000;end_bank:$7fff;num_bank:1),(),() )),
{RT24B}  (lbank:($8000,$8000,$0000,0);
          bank:((tipo:GFXTYPE_SPRITES;start_bank:$0000;end_bank:$53ff;num_bank:0),(tipo:GFXTYPE_SCROLL1;start_bank:$5400;end_bank:$6fff;num_bank:0),(tipo:GFXTYPE_SCROLL3;start_bank:$7000;end_bank:$7fff;num_bank:0),(tipo:GFXTYPE_SCROLL3;start_bank:$0000;end_bank:$3fff;num_bank:1),(tipo:GFXTYPE_SCROLL2;start_bank:$2800;end_bank:$7fff;num_bank:1),(tipo:GFXTYPE_SPRITES;start_bank:$5400;end_bank:$7fff;num_bank:1),() )),
{CC63B}  (lbank:($8000,$8000,$0000,0);
          bank:((tipo:GFXTYPE_SPRITES;start_bank:$0000;end_bank:$7fff;num_bank:0),(tipo:GFXTYPE_SCROLL2;start_bank:$0000;end_bank:$7fff;num_bank:0),(tipo:GFXTYPE_SPRITES;start_bank:$8000;end_bank:$ffff;num_bank:1),(tipo:GFXTYPE_SCROLL1;start_bank:$8000;end_bank:$ffff;num_bank:1),(tipo:GFXTYPE_SCROLL2;start_bank:$8000;end_bank:$ffff;num_bank:1),(tipo:GFXTYPE_SCROLL3;start_bank:$8000;end_bank:$ffff;num_bank:1),() )),
{KR63B}  (lbank:($8000,$8000,$0000,0);
          bank:((tipo:GFXTYPE_SPRITES;start_bank:$0000;end_bank:$7fff;num_bank:0),(tipo:GFXTYPE_SCROLL2;start_bank:$0000;end_bank:$7fff;num_bank:0),(tipo:GFXTYPE_SCROLL1;start_bank:$8000;end_bank:$9fff;num_bank:1),(tipo:GFXTYPE_SPRITES;start_bank:$8000;end_bank:$cfff;num_bank:1),(tipo:GFXTYPE_SCROLL2;start_bank:$8000;end_bank:$cfff;num_bank:1),(tipo:GFXTYPE_SCROLL3;start_bank:$d000;end_bank:$ffff;num_bank:1),() )),
{S9263B} (lbank:($8000,$8000,$8000,0);
          bank:((tipo:GFXTYPE_SPRITES;start_bank:$0000;end_bank:$7fff;num_bank:0),(tipo:GFXTYPE_SPRITES;start_bank:$8000;end_bank:$ffff;num_bank:1),(tipo:GFXTYPE_SPRITES;start_bank:$10000;end_bank:$11fff;num_bank:2),(tipo:GFXTYPE_SCROLL3;start_bank:$2000;end_bank:$3fff;num_bank:2),(tipo:GFXTYPE_SCROLL1;start_bank:$4000;end_bank:$4fff;num_bank:2),(tipo:GFXTYPE_SCROLL2;start_bank:$5000;end_bank:$7fff;num_bank:2),() )),
{CD63B}  (lbank:($8000,$8000,$0000,0);
          bank:((tipo:GFXTYPE_SCROLL1;start_bank:$0000;end_bank:$0fff;num_bank:0),(tipo:GFXTYPE_SPRITES;start_bank:$1000;end_bank:$7fff;num_bank:0),(tipo:GFXTYPE_SPRITES OR GFXTYPE_SCROLL2;start_bank:$8000;end_bank:$dfff;num_bank:1),(tipo:GFXTYPE_SCROLL3;start_bank:$e000;end_bank:$ffff;num_bank:1),(),(),() )),
{PS63B}  (lbank:($8000,$8000,$0000,0);
          bank:((tipo:GFXTYPE_SCROLL1;start_bank:$0000;end_bank:$0fff;num_bank:0),(tipo:GFXTYPE_SPRITES;start_bank:$1000;end_bank:$7fff;num_bank:0),(tipo:GFXTYPE_SPRITES OR GFXTYPE_SCROLL2;start_bank:$8000;end_bank:$dbff;num_bank:1),(tipo:GFXTYPE_SCROLL3;start_bank:$dc00;end_bank:$ffff;num_bank:1),(),(),() )));
        //Games $140
       cps1_cps_b:array[0..9] of cps1_games_def=(
{CPS_B_01}      (layerctrl:$166;palctrl:$170;testaddr:$1FF;testval:$0000;mula:$1fF;mulb:$1FF;mull:$1FF;mulh:$1FF;mask_sc1:$02;mask_sc2:$04;mask_sc3:$08;mask_sc4:$30;pri_mask1:$168;pri_mask2:$16a;pri_mask3:$16c;pri_mask4:$16e),
{CPS_B_04}      (layerctrl:$16e;palctrl:$16a;testaddr:$160;testval:$0004;mula:$1FF;mulb:$1FF;mull:$1FF;mulh:$1FF;mask_sc1:$02;mask_sc2:$04;mask_sc3:$08;mask_sc4:$0;pri_mask1:$166;pri_mask2:$170;pri_mask3:$168;pri_mask4:$172),
{CPS_B_21_BT2}  (layerctrl:$160;palctrl:$170;testaddr:$1FF;testval:$0000;mula:$15e;mulb:$15c;mull:$15a;mulh:$158;mask_sc1:$30;mask_sc2:$08;mask_sc3:$30;mask_sc4:$0;pri_mask1:$16e;pri_mask2:$16c;pri_mask3:$16a;pri_mask4:$168),
{CPS_B_11}      (layerctrl:$166;palctrl:$170;testaddr:$172;testval:$0401;mula:$1ff;mulb:$1ff;mull:$1ff;mulh:$1ff;mask_sc1:$08;mask_sc2:$10;mask_sc3:$20;mask_sc4:$0;pri_mask1:$168;pri_mask2:$16a;pri_mask3:$16c;pri_mask4:$16e),
{CPS_B_21_BT1}  (layerctrl:$168;palctrl:$170;testaddr:$172;testval:$0800;mula:$14e;mulb:$14c;mull:$14a;mulh:$148;mask_sc1:$20;mask_sc2:$04;mask_sc3:$08;mask_sc4:$12;pri_mask1:$166;pri_mask2:$164;pri_mask3:$162;pri_mask4:$160),
{CPS_B_21_BT3}  (layerctrl:$160;palctrl:$170;testaddr:$1ff;testval:$0000;mula:$146;mulb:$144;mull:$142;mulh:$140;mask_sc1:$20;mask_sc2:$12;mask_sc3:$12;mask_sc4:$0;pri_mask1:$16e;pri_mask2:$16c;pri_mask3:$16a;pri_mask4:$168),
{CPS_B_21_BT4}  (layerctrl:$168;palctrl:$170;testaddr:$1ff;testval:$0000;mula:$146;mulb:$144;mull:$142;mulh:$140;mask_sc1:$20;mask_sc2:$10;mask_sc3:$82;mask_sc4:$0;pri_mask1:$166;pri_mask2:$164;pri_mask3:$162;pri_mask4:$160),
{CPS_B_21_DEF}  (layerctrl:$166;palctrl:$170;testaddr:$172;testval:$0000;mula:$140;mulb:$142;mull:$144;mulh:$146;mask_sc1:$02;mask_sc2:$04;mask_sc3:$08;mask_sc4:$30;pri_mask1:$168;pri_mask2:$16a;pri_mask3:$16c;pri_mask4:$16e),
{CPS_B_21_QS2}  (layerctrl:$14a;palctrl:$144;testaddr:$1ff;testval:$0000;mula:$1ff;mulb:$1ff;mull:$1ff;mulh:$1ff;mask_sc1:$16;mask_sc2:$16;mask_sc3:$16;mask_sc4:$0;pri_mask1:$14c;pri_mask2:$14e;pri_mask3:$140;pri_mask4:$142),
{CPS_B_21_QS3}  (layerctrl:$152;palctrl:$14c;testaddr:$14e;testval:$0c00;mula:$1ff;mulb:$1ff;mull:$1ff;mulh:$1ff;mask_sc1:$04;mask_sc2:$02;mask_sc3:$20;mask_sc4:$0;pri_mask1:$154;pri_mask2:$156;pri_mask3:$148;pri_mask4:$14a));

        //Ghouls and ghosts
        ghouls_rom1:array[0..3] of tipo_roms=(
        (n:'dme_29.10h';l:$20000;p:0;crc:$166a58a2),(n:'dme_30.10j';l:$20000;p:$1;crc:$7ac8407a),
        (n:'dme_27.9h';l:$20000;p:$40000;crc:$f734b2be),(n:'dme_28.9j';l:$20000;p:$40001;crc:$03d3e714));
        ghouls_rom2:tipo_roms=(n:'dm-17.7j';l:$80000;p:$80000;crc:$3ea1b0f2);
        ghouls_sound:tipo_roms=(n:'dm_26.10a';l:$10000;p:0;crc:$3692f6e5);
        ghouls_gfx1:array[0..3] of tipo_roms=(
        (n:'dm-05.3a';l:$80000;p:0;crc:$0ba9c0b0),(n:'dm-07.3f';l:$80000;p:2;crc:$5d760ab9),
        (n:'dm-06.3c';l:$80000;p:4;crc:$4ba90b59),(n:'dm-08.3g';l:$80000;p:6;crc:$4bdee9de));
        ghouls_gfx2:array[0..15] of tipo_roms=(
        (n:'09.4a';l:$10000;p:$200000;crc:$ae24bb19),(n:'18.7a';l:$10000;p:$200001;crc:$d34e271a),
        (n:'13.4e';l:$10000;p:$200002;crc:$3f70dd37),(n:'22.7e';l:$10000;p:$200003;crc:$7e69e2e6),
        (n:'11.4c';l:$10000;p:$200004;crc:$37c9b6c6),(n:'20.7c';l:$10000;p:$200005;crc:$2f1345b4),
        (n:'15.4g';l:$10000;p:$200006;crc:$3c2a212a),(n:'24.7g';l:$10000;p:$200007;crc:$889aac05),
        (n:'10.4b';l:$10000;p:$280000;crc:$bcc0f28c),(n:'19.7b';l:$10000;p:$280001;crc:$2a40166a),
        (n:'14.4f';l:$10000;p:$280002;crc:$20f85c03),(n:'23.7f';l:$10000;p:$280003;crc:$8426144b),
        (n:'12.4d';l:$10000;p:$280004;crc:$da088d61),(n:'21.7d';l:$10000;p:$280005;crc:$17e11df0),
        (n:'16.4h';l:$10000;p:$280006;crc:$f187ba1c),(n:'25.7h';l:$10000;p:$280007;crc:$29f79c78));
        //Final Fight
        ffight_rom1:array[0..3] of tipo_roms=(
        (n:'ff_36.11f';l:$20000;p:0;crc:$f9a5ce83),(n:'ff_42.11h';l:$20000;p:$1;crc:$65f11215),
        (n:'ff_37.12f';l:$20000;p:$40000;crc:$e1033784),(n:'ffe_43.12h';l:$20000;p:$40001;crc:$995e968a));
        ffight_rom2:tipo_roms=(n:'ff-32m.8h';l:$80000;p:$80000;crc:$c747696e);
        ffight_sound:tipo_roms=(n:'ff_09.12b';l:$10000;p:0;crc:$b8367eb5);
        ffight_gfx1:array[0..3] of tipo_roms=(
        (n:'ff-5m.7a';l:$80000;p:0;crc:$9c284108),(n:'ff-7m.9a';l:$80000;p:2;crc:$a7584dfb),
        (n:'ff-1m.3a';l:$80000;p:4;crc:$0b605e44),(n:'ff-3m.5a';l:$80000;p:6;crc:$52291cd2));
        ffight_oki:array[0..1] of tipo_roms=(
        (n:'ff_18.11c';l:$20000;p:0;crc:$375c66e7),(n:'ff_19.12c';l:$20000;p:$20000;crc:$1ef137f9));
        //King of Dragons
        kod_rom1:array[0..7] of tipo_roms=(
        (n:'kde_30.11e';l:$20000;p:$00000;crc:$c7414fd4),(n:'kde_37.11f';l:$20000;p:$00001;crc:$a5bf40d2),
        (n:'kde_31.12e';l:$20000;p:$40000;crc:$1fffc7bd),(n:'kde_38.12f';l:$20000;p:$40001;crc:$89e57a82),
        (n:'kde_28.9e'; l:$20000;p:$80000;crc:$9367bcd9),(n:'kde_35.9f'; l:$20000;p:$80001;crc:$4ca6a48a),
        (n:'kde_29.10e';l:$20000;p:$c0000;crc:$6a0ba878),(n:'kde_36.10f';l:$20000;p:$c0001;crc:$b509b39d));
        kod_sound:tipo_roms=(n:'kd_9.12a';l:$10000;p:0;crc:$bac6ec26);
        kod_gfx1:array[0..7] of tipo_roms=(
        (n:'kd-5m.4a';l:$80000;p:$000000;crc:$e45b8701),(n:'kd-7m.6a';l:$80000;p:$000002;crc:$a7750322),
        (n:'kd-1m.3a';l:$80000;p:$000004;crc:$5f74bf78),(n:'kd-3m.5a';l:$80000;p:$000006;crc:$5e5303bf),
        (n:'kd-6m.4c';l:$80000;p:$200000;crc:$113358f3),(n:'kd-8m.6c';l:$80000;p:$200002;crc:$38853c44),
        (n:'kd-2m.3c';l:$80000;p:$200004;crc:$9ef36604),(n:'kd-4m.5c';l:$80000;p:$200006;crc:$402b9b4f));
        kod_oki:array[0..1] of tipo_roms=(
        (n:'kd_18.11c';l:$20000;p:0;crc:$69ecb2c8),(n:'kd_19.12c';l:$20000;p:$20000;crc:$02d851c1));
        //Street Fighter 2
        sf2_rom1:array[0..7] of tipo_roms=(
        (n:'sf2e_30g.11e';l:$20000;p:$00000;crc:$fe39ee33),(n:'sf2e_37g.11f';l:$20000;p:$00001;crc:$fb92cd74),
        (n:'sf2e_31g.12e';l:$20000;p:$40000;crc:$69a0a301),(n:'sf2e_38g.12f';l:$20000;p:$40001;crc:$5e22db70),
        (n:'sf2e_28g.9e' ;l:$20000;p:$80000;crc:$8bf9f1e5),(n:'sf2e_35g.9f'; l:$20000;p:$80001;crc:$626ef934),
        (n:'sf2_29b.10e' ;l:$20000;p:$c0000;crc:$bb4af315),(n:'sf2_36b.10f'; l:$20000;p:$c0001;crc:$c02a13eb));
        sf2_sound:tipo_roms=(n:'sf2_09.12a';l:$10000;p:0;crc:$a4823a1b);
        sf2_gfx1:array[0..11] of tipo_roms=(
        (n:'sf2-5m.4a';l:$80000;p:$000000;crc:$22c9cc8e),(n:'sf2-7m.6a';l:$80000;p:$000002;crc:$57213be8),
        (n:'sf2-1m.3a';l:$80000;p:$000004;crc:$ba529b4f),(n:'sf2-3m.5a';l:$80000;p:$000006;crc:$4b1b33a8),
        (n:'sf2-6m.4c';l:$80000;p:$200000;crc:$2c7e2229),(n:'sf2-8m.6c';l:$80000;p:$200002;crc:$b5548f17),
        (n:'sf2-2m.3c';l:$80000;p:$200004;crc:$14b84312),(n:'sf2-4m.5c';l:$80000;p:$200006;crc:$5e9cd89a),
        (n:'sf2-13m.4d';l:$80000;p:$400000;crc:$994bfa58),(n:'sf2-15m.6d';l:$80000;p:$400002;crc:$3e66ad9d),
        (n:'sf2-9m.3d';l:$80000;p:$400004;crc:$c1befaa8),(n:'sf2-11m.5d';l:$80000;p:$400006;crc:$0627c831));
        sf2_oki:array[0..1] of tipo_roms=(
        (n:'sf2_18.11c';l:$20000;p:0;crc:$7f162009),(n:'sf2_19.12c';l:$20000;p:$20000;crc:$beade53f));
        //Strider
        strider_rom1:array[0..3] of tipo_roms=(
        (n:'30.11f';l:$20000;p:$00000;crc:$da997474),(n:'35.11h';l:$20000;p:$00001;crc:$5463aaa3),
        (n:'31.12f';l:$20000;p:$40000;crc:$d20786db),(n:'36.12h';l:$20000;p:$40001;crc:$21aa2863));
        strider_rom2:tipo_roms=(n:'st-14.8h';l:$80000;p:$80000;crc:$9b3cfc08);
        strider_sound:tipo_roms=(n:'09.12b';l:$10000;p:0;crc:$2ed403bc);
        strider_gfx1:array[0..7] of tipo_roms=(
        (n:'st-2.8a';l:$80000;p:$000000;crc:$4eee9aea),(n:'st-11.10a';l:$80000;p:$000002;crc:$2d7f21e4),
        (n:'st-5.4a';l:$80000;p:$000004;crc:$7705aa46),(n:'st-9.6a';l:$80000;p:$000006;crc:$5b18b722),
        (n:'st-1.7a';l:$80000;p:$200000;crc:$005f000b),(n:'st-10.9a';l:$80000;p:$200002;crc:$b9441519),
        (n:'st-4.3a';l:$80000;p:$200004;crc:$b7d04e8b),(n:'st-8.5a';l:$80000;p:$200006;crc:$6b4713b4));
        strider_oki:array[0..1] of tipo_roms=(
        (n:'18.11c';l:$20000;p:0;crc:$4386bc80),(n:'19.12c';l:$20000;p:$20000;crc:$444536d7));
        //3 Wonder
        wonder3_rom1:array[0..7] of tipo_roms=(
        (n:'rte_30a.11f';l:$20000;p:$00000;crc:$ef5b8b33),(n:'rte_35a.11h';l:$20000;p:$00001;crc:$7d705529),
        (n:'rte_31a.12f';l:$20000;p:$40000;crc:$32835e5e),(n:'rte_36a.12h';l:$20000;p:$40001;crc:$7637975f),
        (n:'rt_28a.9f' ;l:$20000;p:$80000;crc:$054137c8),(n:'rt_33a.9h'; l:$20000;p:$80001;crc:$7264cb1b),
        (n:'rte_29a.10f' ;l:$20000;p:$c0000;crc:$cddaa919),(n:'rte_34a.10h'; l:$20000;p:$c0001;crc:$ed52e7e5));
        wonder3_sound:tipo_roms=(n:'rt_9.12b';l:$10000;p:0;crc:$abfca165);
        wonder3_gfx1:array[0..7] of tipo_roms=(
        (n:'rt-5m.7a';l:$80000;p:$000000;crc:$86aef804),(n:'rt-7m.9a';l:$80000;p:$000002;crc:$4f057110),
        (n:'rt-1m.3a';l:$80000;p:$000004;crc:$902489d0),(n:'rt-3m.5a';l:$80000;p:$000006;crc:$e35ce720),
        (n:'rt-6m.8a';l:$80000;p:$200000;crc:$13cb0e7c),(n:'rt-8m.10a';l:$80000;p:$200002;crc:$1f055014),
        (n:'rt-2m.4a';l:$80000;p:$200004;crc:$e9a034f4),(n:'rt-4m.6a';l:$80000;p:$200006;crc:$df0eea8b));
        wonder3_oki:array[0..1] of tipo_roms=(
        (n:'rt_18.11c';l:$20000;p:0;crc:$26b211ab),(n:'rt_19.12c';l:$20000;p:$20000;crc:$dbe64ad0));
        //Captain Commando
        ccommando_rom1:array[0..1] of tipo_roms=(
        (n:'cce_23d.8f';l:$80000;p:$00000;crc:$42c814c5),(n:'cc_22d.7f';l:$80000;p:$80000;crc:$0fd34195));
        ccommando_rom2:array[0..1] of tipo_roms=(
        (n:'cc_24d.9e';l:$20000;p:$100000;crc:$3a794f25),(n:'cc_28d.9f';l:$20000;p:$100001;crc:$fc3c2906));
        ccommando_sound:tipo_roms=(n:'cc_09.11a';l:$10000;p:0;crc:$698e8b58);
        ccommando_gfx1:array[0..7] of tipo_roms=(
        (n:'cc-5m.3a';l:$80000;p:$000000;crc:$7261d8ba),(n:'cc-7m.5a';l:$80000;p:$000002;crc:$6a60f949),
        (n:'cc-1m.4a';l:$80000;p:$000004;crc:$00637302),(n:'cc-3m.6a';l:$80000;p:$000006;crc:$cc87cf61),
        (n:'cc-6m.7a';l:$80000;p:$200000;crc:$28718bed),(n:'cc-8m.9a';l:$80000;p:$200002;crc:$d4acc53a),
        (n:'cc-2m.8a';l:$80000;p:$200004;crc:$0c69f151),(n:'cc-4m.10a';l:$80000;p:$200006;crc:$1f9ebb97));
        ccommando_oki:array[0..1] of tipo_roms=(
        (n:'cc_18.11c';l:$20000;p:0;crc:$6de2c2db),(n:'cc_19.12c';l:$20000;p:$20000;crc:$b99091ae));
        //Knights of the round
        knights_rom1:array[0..1] of tipo_roms=(
        (n:'kr_23e.8f';l:$80000;p:$00000;crc:$1b3997eb),(n:'kr_22.7f';l:$80000;p:$80000;crc:$d0b671a9));
        knights_sound:tipo_roms=(n:'kr_09.11a';l:$10000;p:0;crc:$5e44d9ee);
        knights_gfx1:array[0..7] of tipo_roms=(
        (n:'kr-5m.3a';l:$80000;p:$000000;crc:$9e36c1a4),(n:'kr-7m.5a';l:$80000;p:$000002;crc:$c5832cae),
        (n:'kr-1m.4a';l:$80000;p:$000004;crc:$f095be2d),(n:'kr-3m.6a';l:$80000;p:$000006;crc:$179dfd96),
        (n:'kr-6m.7a';l:$80000;p:$200000;crc:$1f4298d2),(n:'kr-8m.9a';l:$80000;p:$200002;crc:$37fa8751),
        (n:'kr-2m.8a';l:$80000;p:$200004;crc:$0200bc3d),(n:'kr-4m.10a';l:$80000;p:$200006;crc:$0bb2b4e7));
        knights_oki:array[0..1] of tipo_roms=(
        (n:'kr_18.11c';l:$20000;p:0;crc:$da69d15f),(n:'kr_19.12c';l:$20000;p:$20000;crc:$bfc654e9));
        //Street Fighter II': Champion Edition
        sf2ce_rom1:array[0..2] of tipo_roms=(
        (n:'s92e_23b.8f';l:$80000;p:$00000;crc:$0aaa1a3a),(n:'s92_22b.7f';l:$80000;p:$80000;crc:$2bbe15ed),
        (n:'s92_21a.6f';l:$80000;p:$100000;crc:$925a7877));
        sf2ce_sound:tipo_roms=(n:'s92_09.11a';l:$10000;p:0;crc:$08f6b60e);
        sf2ce_gfx1:array[0..11] of tipo_roms=(
        (n:'s92-1m.3a';l:$80000;p:$000000;crc:$03b0d852),(n:'s92-3m.5a';l:$80000;p:$000002;crc:$840289ec),
        (n:'s92-2m.4a';l:$80000;p:$000004;crc:$cdb5f027),(n:'s92-4m.6a';l:$80000;p:$000006;crc:$e2799472),
        (n:'s92-5m.7a';l:$80000;p:$200000;crc:$ba8a2761),(n:'s92-7m.9a';l:$80000;p:$200002;crc:$e584bfb5),
        (n:'s92-6m.8a';l:$80000;p:$200004;crc:$21e3f87d),(n:'s92-8m.10a';l:$80000;p:$200006;crc:$befc47df),
        (n:'s92-10m.3c';l:$80000;p:$400000;crc:$960687d5),(n:'s92-12m.5c';l:$80000;p:$400002;crc:$978ecd18),
        (n:'s92-11m.4c';l:$80000;p:$400004;crc:$d6ec9a0a),(n:'s92-13m.6c';l:$80000;p:$400006;crc:$ed2c67f6));
        sf2ce_oki:array[0..1] of tipo_roms=(
        (n:'s92_18.11c';l:$20000;p:0;crc:$7f162009),(n:'s92_19.12c';l:$20000;p:$20000;crc:$beade53f));
         //Cadillacs and Dinosaurs
        dino_rom1:array[0..2] of tipo_roms=(
        (n:'cde_23a.8f';l:$80000;p:$00000;crc:$8f4e585e),(n:'cde_22a.7f';l:$80000;p:$80000;crc:$9278aa12),
        (n:'cde_21a.6f';l:$80000;p:$100000;crc:$66d23de2));
        dino_sound:tipo_roms=(n:'cd_q.5k';l:$20000;p:0;crc:$605fdb0b);
        dino_gfx1:array[0..7] of tipo_roms=(
        (n:'cd-1m.3a';l:$80000;p:$000000;crc:$8da4f917),(n:'cd-3m.5a';l:$80000;p:$000002;crc:$6c40f603),
        (n:'cd-2m.4a';l:$80000;p:$000004;crc:$09c8fc2d),(n:'cd-4m.6a';l:$80000;p:$000006;crc:$637ff38f),
        (n:'cd-5m.7a';l:$80000;p:$200000;crc:$470befee),(n:'cd-7m.9a';l:$80000;p:$200002;crc:$22bfb7a3),
        (n:'cd-6m.8a';l:$80000;p:$200004;crc:$e7599ac4),(n:'cd-8m.10a';l:$80000;p:$200006;crc:$211b4b15));
        dino_qsound1:array[0..3] of tipo_roms=(
        (n:'cd-q1.1k';l:$80000;p:$00000;crc:$60927775),(n:'cd-q2.2k';l:$80000;p:$80000;crc:$770f4c47),
        (n:'cd-q3.3k';l:$80000;p:$100000;crc:$2f273ffc),(n:'cd-q4.4k';l:$80000;p:$180000;crc:$2c67821d));
        //The Punisher
        punisher_rom1:array[0..7] of tipo_roms=(
        (n:'pse_26.11e';l:$20000;p:$000000;crc:$389a99d2),(n:'pse_30.11f';l:$20000;p:$000001;crc:$68fb06ac),
        (n:'pse_27.12e';l:$20000;p:$040000;crc:$3eb181c3),(n:'pse_31.12f';l:$20000;p:$040001;crc:$37108e7b),
        (n:'pse_24.9e';l:$20000;p:$080000;crc:$0f434414),(n:'pse_28.9f';l:$20000;p:$080001;crc:$b732345d),
        (n:'pse_25.10e';l:$20000;p:$0c0000;crc:$b77102e2),(n:'pse_29.10f';l:$20000;p:$0c0001;crc:$ec037bce));
        punisher_rom2:tipo_roms=(n:'ps_21.6f';l:$80000;p:$100000;crc:$8affa5a9);
        punisher_sound:tipo_roms=(n:'ps_q.5k';l:$20000;p:0;crc:$49ff4446);
        punisher_gfx1:array[0..7] of tipo_roms=(
        (n:'ps-1m.3a';l:$80000;p:$000000;crc:$77b7ccab),(n:'ps-3m.5a';l:$80000;p:$000002;crc:$0122720b),
        (n:'ps-2m.4a';l:$80000;p:$000004;crc:$64fa58d4),(n:'ps-4m.6a';l:$80000;p:$000006;crc:$60da42c8),
        (n:'ps-5m.7a';l:$80000;p:$200000;crc:$c54ea839),(n:'ps-7m.9a';l:$80000;p:$200002;crc:$04c5acbd),
        (n:'ps-6m.8a';l:$80000;p:$200004;crc:$a544f4cc),(n:'ps-8m.10a';l:$80000;p:$200006;crc:$8f02f436));
        punisher_qsound1:array[0..3] of tipo_roms=(
        (n:'ps-q1.1k';l:$80000;p:$00000;crc:$31fd8726),(n:'ps-q2.2k';l:$80000;p:$80000;crc:$980a9eef),
        (n:'ps-q3.3k';l:$80000;p:$100000;crc:$0dd44491),(n:'ps-q4.4k';l:$80000;p:$180000;crc:$bed42f03));

var
 nbank,cps_b:byte;
 scroll_x1,scroll_y1,scroll_x2,scroll_y2,scroll_x3,scroll_y3:word;
 rom:array[0..$bffff] of word;
 ram:array[0..$7fff] of word;
 vram:array[0..$17fff] of word;
 snd_rom:array[0..5,0..$3fff] of byte;
 sprite_buffer:array[0..$3ff] of word;
 qram1,qram2:array[0..$fff] of byte;
 qsnd_opcode,qsnd_data:array[0..$7fff] of byte;
 sound_latch,sound_latch2,sound_bank,dswa,dswb,dswc:byte;
 cps1_sprites,cps1_scroll1,cps1_scroll2,cps1_scroll3,cps1_rowscroll,cps1_pal:dword;
 cps1_mula,cps1_mulb,cps1_layer,scroll_pri_x,scroll_pri_y:word;
 cps1_palcltr,pri_mask0,pri_mask1,pri_mask2,pri_mask3:word;
 cps1_rowscrollstart:word;
 pal_change,mask_change,sprites_pri_draw,rowscroll_ena:boolean;

procedure pal_calc;inline;
var
  page,bright:byte;
  color:tcolor;
  offset,palette,pos_buf:word;
  pos:dword;
begin
pos_buf:=0;
for page:=0 to 5 do begin
  if BIT(cps1_palcltr,page) then begin
    for offset:=0 to $1ff do begin
      if buffer_paleta[pos_buf]<>0 then begin
        buffer_paleta[pos_buf]:=0;
        pos:=(pos_buf*2)+cps1_pal;
        palette:=vram[pos shr 1];
        bright:=$f+((palette shr 12) shl 1);
        color.r:=(((palette shr 8) and $f)*$11*bright) div $2d;
        color.g:=(((palette shr 4) and $f)*$11*bright) div $2d;
        color.b:=(((palette shr 0) and $f)*$11*bright) div $2d;
        set_pal_color(color,($200*page)+offset);
        if page<4 then buffer_color[(offset shr 4)+((page-1)*$20)]:=true;
      end;
      pos_buf:=pos_buf+1;
    end;     // skip page in gfxram, but only if we have already copied at least one page
  end else if (pos_buf<>0) then pos_buf:=pos_buf+$200;
end;
pal_change:=false;
end;

function gfx_bank(tipo:byte;nchar:word):integer;inline;
var
  shift,pos:byte;
  code,base:dword;
  i:integer;
begin
	case tipo of
		GFXTYPE_SPRITES:shift:=1;
		GFXTYPE_SCROLL1:shift:=0;
		GFXTYPE_SCROLL2:shift:=1;
		GFXTYPE_SCROLL3:shift:=3;
	end;
	code:=nchar shl shift;
  pos:=0;
	while (cps1_banks[nbank].bank[pos].tipo<>0) do begin
		if ((code>=cps1_banks[nbank].bank[pos].start_bank) and (code<=cps1_banks[nbank].bank[pos].end_bank)) then begin
			if (cps1_banks[nbank].bank[pos].tipo and tipo)<>0 then begin
				base:=0;
				for i:=0 to (cps1_banks[nbank].bank[pos].num_bank-1) do
					base:=base+(cps1_banks[nbank].lbank[i]);
        gfx_bank:=(base+(code and (cps1_banks[nbank].lbank[cps1_banks[nbank].bank[pos].num_bank]-1))) shr shift;
        exit;
			end;
		end;
		pos:=pos+1;
  end;
  gfx_bank:=-1;
end;

procedure draw_sprites;inline;
var
  f,color,col,rx,ry,yy,xx:word;
  flipx,flipy:boolean;
  x,y,nchar,dx,dy,dxx:integer;
  last_sprite:byte;
begin
//Find last sprite
last_sprite:=$fe;
for f:=0 to $fe do begin
  color:=sprite_buffer[(f*4)+3];
  if color=$ff00 then begin
      last_sprite:=f;
      break;
  end;
end;
for f:=last_sprite downto 0 do begin
	 nchar:=sprite_buffer[(f shl 2)+2];
   nchar:=gfx_bank(GFXTYPE_SPRITES,nchar);
   if nchar<>-1 then begin
     color:=sprite_buffer[(f shl 2)+3];
     x:=sprite_buffer[(f shl 2)+0];
  	 y:=sprite_buffer[(f shl 2)+1];
     col:=(color and $1f) shl 4;
     rx:=(color shr 8) and $F;
     ry:=(color shr 12) and $F;
     if (color and $20)<>0 then begin  //flip_x
       flipx:=true;
       x:=x+(rx shl 4);
       dx:=-16;
       dxx:=(rx+1) shl 4;
     end else begin
       flipx:=false;
       dx:=16;
       dxx:=-((rx+1) shl 4);
     end;
     if (color and $40)<>0 then begin  //flip_y
       flipy:=true;
       y:=y+(ry shl 4);
       dy:=-16;
     end else begin
       flipy:=false;
       dy:=16;
     end;
     for yy:=0 to ry do begin
        for xx:=0 to rx do begin
          put_gfx_sprite(nchar+xx+(yy shl 4),col,flipx,flipy,2);
          actualiza_gfx_sprite(x,y,5,2);
          x:=x+dx;
        end;
        x:=x+dxx;
        y:=y+dy;
     end;
   end;
end;
//Prioridad de los sprites
if sprites_pri_draw then begin
  scroll_x_y(4,5,scroll_pri_x,scroll_pri_y);
  sprites_pri_draw:=false;
end;
end;

procedure draw_layer(nlayer:byte;sprite_next:boolean);inline;
var
  f,atrib,color,sx,sy,pos,layer2_scroll_x:word;
  x,y,pant:byte;
  address:dword;
  nchar:integer;
  flipx,flipy:boolean;
begin
case nlayer of
  0:draw_sprites;
  1:if (cps1_layer and cps1_cps_b[cps_b].mask_sc1)=cps1_cps_b[cps_b].mask_sc1 then begin
      if (sprite_next and mask_change) then begin
        mask_change:=false;
        fillchar(gfx[0].buffer,$1000,1);
      end;
      for f:=0 to $6c7 do begin
       x:=f mod 56;
       y:=f div 56;
       sx:=x+((scroll_x1 and $1f8) div 8);
       sy:=y+((scroll_y1 and $1f8) div 8);
       pos:=(sy and $1f)+((sx and $3f) shl 5)+((sy and $20) shl 6);
       address:=cps1_scroll1+(pos*4);
       atrib:=vram[(address+2) shr 1];
       color:=atrib and $1f;
       if (gfx[0].buffer[pos] or buffer_color[color]) then begin
          nchar:=vram[address shr 1];
          nchar:=gfx_bank(GFXTYPE_SCROLL1,nchar);
          if nchar=-1 then begin
            put_gfx_block_trans(x*8,y*8,1,8,8);
            if sprite_next then put_gfx_block_trans(x*8,y*8,4,8,8);
          end else begin
            flipx:=(atrib and $20)<>0;
            flipy:=(atrib and $40)<>0;
            color:=(color+$20) shl 4;
            put_gfx_trans_flip(x*8,y*8,nchar,color,1,(pos and $20) shr 5,flipx,flipy);
            if sprite_next then begin
              pant:=(atrib and $180) shr 7;
              put_gfx_trans_flip_alt(x*8,y*8,nchar,color,4,(pos and $20) shr 5,flipx,flipy,pant);
            end;
          end;
          gfx[0].buffer[pos]:=false;
       end;
      end;
      if sprite_next then begin
        sprites_pri_draw:=true;
        scroll_pri_x:=scroll_x1 and $7;
        scroll_pri_y:=scroll_y1 and $7;
      end;
      scroll_x_y(1,5,scroll_x1 and $7,scroll_y1 and $7);
    end;
  2:if (cps1_layer and cps1_cps_b[cps_b].mask_sc2)<>0 then begin
      if (sprite_next and mask_change) then begin
        mask_change:=false;
        fillchar(gfx[2].buffer,$1000,1);
      end;
      for f:=0 to $1cf do begin
        x:=f mod 29;
        y:=f div 29;
        if not(rowscroll_ena) then layer2_scroll_x:=scroll_x2
          else begin  //mal!
                  address:=cps1_rowscroll+((y+(scroll_y2 div 16))*4);
                  layer2_scroll_x:=(vram[(address+cps1_rowscrollstart) shr 1]+scroll_x2) and $3ff;
          end;
        sx:=x+((layer2_scroll_x and $3f0) div 16);
        sy:=y+((scroll_y2 and $3f0) div 16);
        pos:=(sy and $0f)+((sx and $3f) shl 4)+((sy and $30) shl 6);
        address:=cps1_scroll2+(pos*4);
        atrib:=vram[(address+2) shr 1];
        color:=atrib and $1f;
        if (gfx[2].buffer[pos] or buffer_color[color+$20]) then begin
          nchar:=vram[address shr 1];
          nchar:=gfx_bank(GFXTYPE_SCROLL2,nchar);
          if nchar=-1 then begin
            put_gfx_block_trans(x*16,y*16,2,16,16);
            if sprite_next then put_gfx_block_trans(x*16,y*16,4,16,16);
          end else begin
            color:=(color+$40) shl 4;
            flipx:=(atrib and $20)<>0;
            flipy:=(atrib and $40)<>0;
            put_gfx_trans_flip(x*16,y*16,nchar,color,2,2,flipx,flipy);
            if sprite_next then begin
              pant:=((atrib and $180) shr 7);
              put_gfx_trans_flip_alt(x*16,y*16,nchar,color,4,2,flipx,flipy,pant);
            end;
          end;
          gfx[2].buffer[pos]:=false;
        end;
      end;
      if sprite_next then begin
        sprites_pri_draw:=true;
        scroll_pri_x:=scroll_x2 and $f;
        scroll_pri_y:=scroll_y2 and $f;
      end;
      scroll_x_y(2,5,layer2_scroll_x and $f,scroll_y2 and $f);
    end;
  3:if (cps1_layer and cps1_cps_b[cps_b].mask_sc3)<>0 then begin
      if (sprite_next and mask_change) then begin
        //Si se ha modificado las mascaras, y es la pantalla de las prioridades borrar todo
        mask_change:=false;
        fillchar(gfx[3].buffer,$1000,1);
      end;
      for f:=0 to $95 do begin
        x:=f mod 15;
        y:=f div 15;
        sx:=x+((scroll_x3 and $7e0) div 32);
        sy:=y+((scroll_y3 and $7e0) div 32);
        pos:=(sy and $07)+((sx and $3f) shl 3)+((sy and $38) shl 6);
        address:=cps1_scroll3+(pos*4);
        atrib:=vram[(address+2) shr 1];
        color:=atrib and $1f;
        if (gfx[3].buffer[pos] or buffer_color[color+$40]) then begin
          nchar:=vram[address shr 1];
          nchar:=gfx_bank(GFXTYPE_SCROLL3,nchar);
          if nchar=-1 then begin
            //Si esta fuera de rango, poner un tile vacio (incluida la pantalla de las prioridades)
            put_gfx_block_trans(x*32,y*32,3,32,32);
            if sprite_next then put_gfx_block_trans(x*32,y*32,4,32,32);
          end else begin
            color:=(color+$60) shl 4;
            flipx:=(atrib and $20)<>0;
            flipy:=(atrib and $40)<>0;
            put_gfx_trans_flip(x*32,y*32,nchar,color,3,3,flipx,flipy);
            if sprite_next then begin
              //¿Es la pantalla de prioridad? Actualizarla
              pant:=((atrib and $180) shr 7);
              put_gfx_trans_flip_alt(x*32,y*32,nchar,color,4,3,flipx,flipy,pant);
            end;
          end;
          gfx[3].buffer[pos]:=false;
        end;
      end;
      if sprite_next then begin
        //Si es la pantalla de prioridades de sprites, poner las variables...
        sprites_pri_draw:=true;
        scroll_pri_x:=scroll_x3 and $1f;
        scroll_pri_y:=scroll_y3 and $1f;
      end;
      scroll_x_y(3,5,scroll_x3 and $1f,scroll_y3 and $1f);
    end;
end;
end;

procedure update_video_cps1;inline;
var
  l0,l1,l2,l3:byte;
begin
  if pal_change then pal_calc;
  fill_full_screen(5,$bff);
  l0:=(cps1_layer shr 6) and 3;
  l1:=(cps1_layer shr 8) and 3;
  l2:=(cps1_layer shr $a) and 3;
  l3:=(cps1_layer shr $c) and 3;
  //draw_starts
  draw_layer(l0,l1=0);
  draw_layer(l1,l2=0);
  draw_layer(l2,l3=0);
  draw_layer(l3,false);
  actualiza_trozo_final(64,16,384,224,5);
  fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure eventos_cps1;
begin
if event.arcade then begin
  //P1
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fffe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fffd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $fffb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $fff7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $ffef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $ffdf) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.but2[0] then marcade.in1:=(marcade.in1 and $ffbf) else marcade.in1:=(marcade.in1 or $40);
  //P2
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $feff) else marcade.in1:=(marcade.in1 or $100);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fdff) else marcade.in1:=(marcade.in1 or $200);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $fbff) else marcade.in1:=(marcade.in1 or $400);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $f7ff) else marcade.in1:=(marcade.in1 or $800);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $efff) else marcade.in1:=(marcade.in1 or $1000);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $dfff) else marcade.in1:=(marcade.in1 or $2000);
  if arcade_input.but2[1] then marcade.in1:=(marcade.in1 and $bfff) else marcade.in1:=(marcade.in1 or $4000);
  //SYS
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $feff) else marcade.in0:=(marcade.in0 or $100);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fdff) else marcade.in0:=(marcade.in0 or $200);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $efff) else marcade.in0:=(marcade.in0 or $1000);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $dfff) else marcade.in0:=(marcade.in0 or $2000);
end;
end;

procedure calc_mask(mask:word;index:byte);inline;
var
  f:byte;
  val:boolean;
begin
for f:=0 to 15 do begin
  val:=((mask shr f) and 1)=0;
  gfx[0].trans_alt[index][f]:=val;
end;
copymemory(@gfx[1].trans_alt[index][0],@gfx[0].trans_alt[index][0],16);
copymemory(@gfx[2].trans_alt[index][0],@gfx[0].trans_alt[index][0],16);
copymemory(@gfx[3].trans_alt[index][0],@gfx[0].trans_alt[index][0],16);
end;

procedure cps1_principal;
var
  frame_m,frame_s:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
frame_s:=z80_0.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to 261 do begin
    //main
    m68000_0.run(frame_m);
    frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
    //sound
    z80_0.run(frame_s);
    frame_s:=frame_s+z80_0.tframes-z80_0.contador;
    if f=239 then begin
       m68000_0.irq[2]:=HOLD_LINE;
       update_video_cps1;
       copymemory(@sprite_buffer,@vram[cps1_sprites shr 1],$400*2);
    end;
 end;
 eventos_cps1;
 video_sync;
end;
end;

function cps1_read_io_w(dir:word):word;inline;
var
  res:word;
begin
res:=$ffff;
case dir of
  $000,$002,$004,$006:res:=marcade.in1; //P1+P2
  $018:res:=marcade.in0; //SYS
  $01a:res:=(dswa shl 8)+$ff; //DSWA
  $01c:res:=(dswb shl 8)+$ff; //DSWB
  $01e:res:=(dswc shl 8)+$ff; //DSWC
end;
if (dir=cps1_cps_b[cps_b].testaddr) then res:=cps1_cps_b[cps_b].testval;
if (dir=cps1_cps_b[cps_b].mull) then res:=(cps1_mula*cps1_mulb) and $ffff;
if (dir=cps1_cps_b[cps_b].mulh) then res:=(cps1_mula*cps1_mulb) shr 16;
cps1_read_io_w:=res;
end;

function cps1_getword(direccion:dword):word;
begin
case direccion of
    $000000..$17ffff:cps1_getword:=rom[direccion shr 1];
    $800000..$8001ff:cps1_getword:=cps1_read_io_w(direccion and $1fe);
    $900000..$92ffff:cps1_getword:=vram[(direccion and $3ffff) shr 1];
    $ff0000..$ffffff:cps1_getword:=ram[(direccion and $ffff) shr 1];
end;
end;

procedure cps1_write_io_w(dir,val:word);inline;
begin
  case dir of
    $100:cps1_sprites:=(val*256)-$900000;
    $102:if cps1_scroll1<>(((val*256) and not($3fff))-$900000) then begin
            cps1_scroll1:=((val*256) and not($3fff))-$900000;
            fillchar(gfx[0].buffer,$1000,1);
         end;
    $104:if cps1_scroll2<>(((val*256) and not($3fff))-$900000) then begin
            cps1_scroll2:=((val*256) and not($3fff))-$900000;
            fillchar(gfx[2].buffer,$1000,1);
         end;
    $106:if cps1_scroll3<>(((val*256) and not($3fff))-$900000) then begin
            cps1_scroll3:=((val*256) and not($3fff))-$900000;
            fillchar(gfx[3].buffer,$1000,1);
         end;
    $108:cps1_rowscroll:=((val*256) and not($3fff))-$900000;
    $10A:if cps1_pal<>(((val*256)-$900000) and $1ffff) then begin
            cps1_pal:=((val*256)-$900000) and $1ffff;
            fillchar(buffer_paleta,$200*6,1);
            pal_change:=true;
         end;
    $10C:if scroll_x1<>(val and $1ff) then begin
            if abs((scroll_x1 and $1f8)-(val and $1f8))>7 then fillchar(gfx[0].buffer,$1000,1);
            scroll_x1:=val and $1ff;
         end;
    $10E:if scroll_y1<>(val and $1ff) then begin
            if abs((scroll_y1 and $1f8)-(val and $1f8))>7 then fillchar(gfx[0].buffer,$1000,1);
            scroll_y1:=val and $1ff;
         end;
    $110:if scroll_x2<>(val and $3ff) then begin
            if abs((scroll_x2 and $3f0)-(val and $3f0))>15 then fillchar(gfx[2].buffer,$1000,1);
            scroll_x2:=val and $3ff;
         end;
    $112:if scroll_y2<>(val and $3ff) then begin
            if abs((scroll_y2 and $3f0)-(val and $3f0))>15 then fillchar(gfx[2].buffer,$1000,1);
            scroll_y2:=val and $3ff;
         end;
    $114:if scroll_x3<>(val and $7ff) then begin
            if abs((scroll_x3 and $7e0)-(val and $7e0))>31 then fillchar(gfx[3].buffer,$1000,1);
            scroll_x3:=val and $7ff;
         end;
    $116:if scroll_y3<>(val and $7ff) then begin
            if abs((scroll_y3 and $7e0)-(val and $7e0))>31 then fillchar(gfx[3].buffer,$1000,1);
            scroll_y3:=(val and $7ff);
         end;
    $120:cps1_rowscrollstart:=val;
    $122:begin  //cps1_vidctrl
            main_screen.flip_main_screen:=(val and $8000)<>0;
            rowscroll_ena:=(val and 1)<>0;
         end;
    $180,$182,$184,$186:sound_latch:=val and $ff;
    $188,$18a,$18c,$18e:sound_latch2:=val and $ff;
  end;
  if (dir=cps1_cps_b[cps_b].palctrl) then begin
      if cps1_palcltr<>val then begin
             cps1_palcltr:=val;
             pal_change:=true;
             fillchar(buffer_paleta,$200*6,1);
         end;
  end;
  if (dir=cps1_cps_b[cps_b].mula) then cps1_mula:=val;
  if (dir=cps1_cps_b[cps_b].mulb) then cps1_mulb:=val;
  if (dir=cps1_cps_b[cps_b].layerctrl) then cps1_layer:=val;
  if (dir=cps1_cps_b[cps_b].pri_mask1) then begin
    if pri_mask0<>val then begin
      calc_mask(val,0);
      pri_mask0:=val;
      mask_change:=true;
    end;
  end;
  if (dir=cps1_cps_b[cps_b].pri_mask2) then begin
    if pri_mask1<>val then begin
      calc_mask(val,1);
      pri_mask1:=val;
      mask_change:=true;
    end;
  end;
  if (dir=cps1_cps_b[cps_b].pri_mask3) then begin
    if pri_mask2<>val then begin
      calc_mask(val,2);
      pri_mask2:=val;
      mask_change:=true;
    end;
  end;
  if (dir=cps1_cps_b[cps_b].pri_mask4) then begin
    if pri_mask3<>val then begin
      calc_mask(val,3);
      pri_mask3:=val;
      mask_change:=true;
    end;
  end;
end;

procedure test_buffers(direccion:dword);inline;
begin
  if ((direccion>=cps1_pal) and (direccion<(cps1_pal+$1800))) then begin
    pal_change:=true;
    buffer_paleta[(direccion-cps1_pal) shr 1]:=1;
    exit;
  end;
  if ((direccion>=cps1_scroll1) and (direccion<(cps1_scroll1+$4000))) then gfx[0].buffer[(direccion-cps1_scroll1) shr 2]:=true;
  if ((direccion>=cps1_scroll2) and (direccion<(cps1_scroll2+$4000))) then gfx[2].buffer[(direccion-cps1_scroll2) shr 2]:=true;
  if ((direccion>=cps1_scroll3) and (direccion<(cps1_scroll3+$4000))) then gfx[3].buffer[(direccion-cps1_scroll3) shr 2]:=true;
end;

procedure cps1_putword(direccion:dword;valor:word);
begin
case direccion of
    $000000..$17ffff:; //ROM
    $800000..$8001ff:cps1_write_io_w(direccion and $1fe,valor);
    $900000..$92ffff:if (vram[(direccion and $3ffff) shr 1]<>valor) then begin
                          vram[(direccion and $3ffff) shr 1]:=valor;
                          test_buffers(direccion and $3ffff);
                     end;
    $ff0000..$ffffff:ram[(direccion and $ffff) shr 1]:=valor;
  end;
end;

//Sonido
function cps1_snd_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$7fff,$d000..$d7ff:cps1_snd_getbyte:=mem_snd[direccion];
  $8000..$bfff:cps1_snd_getbyte:=snd_rom[sound_bank,direccion and $3fff];
  $f001:cps1_snd_getbyte:=ym2151_0.status;
  $f002:cps1_snd_getbyte:=oki_6295_0.read;
  $f008:cps1_snd_getbyte:=sound_latch;
  $f00a:cps1_snd_getbyte:=sound_latch2;
end;
end;

procedure cps1_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$bfff:; //ROM
  $d000..$d7ff:mem_snd[direccion]:=valor;
  $f000:ym2151_0.reg(valor);
  $f001:ym2151_0.write(valor);
  $f002:oki_6295_0.write(valor);
  $f004:sound_bank:=valor and $1;
  $f006:oki_6295_0.change_pin7(valor and 1);
end;
end;

procedure cps1_ym2151_snd_irq(irqstate:byte);
begin
  z80_0.change_irq(irqstate);
end;

procedure cps1_sound_update;
begin
  ym2151_0.update;
  oki_6295_0.update;
end;

//Qsound
function cps1_qsnd_getword(direccion:dword):word;
begin
case direccion of
    $000000..$17ffff:cps1_qsnd_getword:=rom[direccion shr 1];
    $800000..$8001ff:cps1_qsnd_getword:=cps1_read_io_w(direccion and $1fe);
    $900000..$92ffff:cps1_qsnd_getword:=vram[(direccion and $3ffff) shr 1];
    //qsound
    $f18000..$f19fff:cps1_qsnd_getword:=$ff00+qram1[(direccion shr 1) and $fff];
    $f1c000,$f1c002:cps1_qsnd_getword:=$ff;
    $f1c006:cps1_qsnd_getword:=eeprom_0.readbit;
    $f1e000..$f1ffff:cps1_qsnd_getword:=$ff00+qram2[(direccion shr 1) and $fff];
    $ff0000..$ffffff:cps1_qsnd_getword:=ram[(direccion and $ffff) shr 1];
end;
end;

procedure cps1_qsnd_putword(direccion:dword;valor:word);
begin
case direccion of
    $000000..$17ffff:; //ROM
    $800000..$8001ff:cps1_write_io_w(direccion and $1fe,valor);
    $900000..$92ffff:if (vram[(direccion and $3ffff) shr 1]<>valor) then begin
                          vram[(direccion and $3ffff) shr 1]:=valor;
                          test_buffers(direccion and $3ffff);
                     end;
    $f18000..$f19fff:qram1[(direccion shr 1) and $fff]:=valor and $ff;
    $f1c006:begin
              eeprom_0.write_bit(valor and 1);
              eeprom_0.set_clock_line(valor and $40);
              eeprom_0.set_cs_line(not(valor) and $80);
            end;
    $f1e000..$f1ffff:qram2[(direccion shr 1) and $fff]:=valor and $ff;
    $ff0000..$ffffff:ram[(direccion and $ffff) shr 1]:=valor;
  end;
end;

function cps1_qz80_getbyte(direccion:word):byte;
begin
case direccion of
  $0000..$7fff:if z80_0.opcode then cps1_qz80_getbyte:=qsnd_opcode[direccion]
                  else cps1_qz80_getbyte:=qsnd_data[direccion];
  $8000..$bfff:cps1_qz80_getbyte:=snd_rom[sound_bank,direccion and $3fff];
  $c000..$cfff:cps1_qz80_getbyte:=qram1[direccion and $fff];
  $d007:cps1_qz80_getbyte:=qsound_r;
  $f000..$ffff:cps1_qz80_getbyte:=qram2[direccion and $fff];
end;
end;

procedure cps1_qz80_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$bfff:; //ROM
  $c000..$cfff:qram1[direccion and $fff]:=valor;
  $d000..$d002:qsound_w(direccion and $3,valor);
  $d003:sound_bank:=valor and $f;
  $f000..$ffff:qram2[direccion and $fff]:=valor;
end;
end;

procedure cps1_qsnd_int;
begin
  z80_0.change_irq(HOLD_LINE);
end;

//Main
procedure reset_cps1;
begin
 m68000_0.reset;
 z80_0.reset;
 reset_audio;
 case main_vars.tipo_maquina of
  103..111:begin
             ym2151_0.reset;
             oki_6295_0.reset;
           end;
  112,113:begin
             qsound_reset;
             eeprom_0.reset;
          end;
 end;
 marcade.in0:=$ffff;
 marcade.in1:=$ffff;
 sound_latch:=0;
 sound_latch2:=0;
 sound_bank:=0;
 scroll_x1:=0;
 scroll_y1:=0;
 scroll_x2:=0;
 scroll_y2:=0;
 scroll_x3:=0;
 scroll_y3:=0;
 cps1_sprites:=$ffff;
 cps1_scroll1:=$ffff;
 cps1_scroll2:=$ffff;
 cps1_scroll3:=$ffff;
 cps1_rowscroll:=0;
 cps1_pal:=$ffff;
 //cps1_rowscrollstart:=0;
 cps1_mula:=0;
 cps1_mulb:=0;
 cps1_layer:=0;
 cps1_palcltr:=0;
 pal_change:=false;
 scroll_pri_x:=0;
 scroll_pri_y:=0;
 sprites_pri_draw:=false;
 fillchar(buffer_paleta,$200*6,1);
 pri_mask0:=0;
 pri_mask1:=0;
 pri_mask2:=0;
 pri_mask3:=0;
 calc_mask(0,0);
 calc_mask(0,1);
 calc_mask(0,2);
 calc_mask(0,3);
end;

procedure cps1_gfx_decode(memoria_temp:pbyte;gfxsize:dword);inline;
var
  i:dword;
  src,dwval,mask:dword;
  j,n:byte;
  ptemp:pbyte;
begin
	gfxsize:=gfxsize div 4;
	for i:=0 to (gfxsize-1) do begin
    ptemp:=memoria_temp;inc(ptemp,4*i);
		src:=ptemp^;
    ptemp:=memoria_temp;inc(ptemp,(4*i)+1);
    src:=src or (ptemp^ shl 8);
    ptemp:=memoria_temp;inc(ptemp,(4*i)+2);
    src:=src or (ptemp^ shl 16);
    ptemp:=memoria_temp;inc(ptemp,(4*i)+3);
    src:=src or (ptemp^ shl 24);
		dwval:=0;
		for j:=0 to 7 do begin
			n:=0;
			mask:=($80808080 shr j) and src;
			if (mask and $000000ff)<>0 then n:=n or 1;
			if (mask and $0000ff00)<>0 then n:=n or 2;
			if (mask and $00ff0000)<>0 then n:=n or 4;
			if (mask and $ff000000)<>0 then n:=n or 8;
			dwval:=dwval or (n shl (j * 4));
		end;
    ptemp:=memoria_temp;inc(ptemp,4*i);
		ptemp^:=(dwval shr 0) and $ff;
    ptemp:=memoria_temp;inc(ptemp,(4*i)+1);
    ptemp^:=(dwval shr 8) and $ff;
    ptemp:=memoria_temp;inc(ptemp,(4*i)+2);
    ptemp^:=(dwval shr 16) and $ff ;
    ptemp:=memoria_temp;inc(ptemp,(4*i)+3);
    ptemp^:=(dwval shr 24) and $ff;
	end;
end;

procedure cerrar_cps1;
begin
case main_vars.tipo_maquina of
  112..113:qsound_close;
end;
end;

function iniciar_cps1:boolean;
var
  memoria_temp,ptemp:pbyte;
  f:byte;
const
  pt_y:array[0..15] of dword=(0*64, 1*64, 2*64, 3*64, 4*64, 5*64, 6*64, 7*64,
                              8*64, 9*64,10*64,11*64,12*64,13*64,14*64,15*64);
  pt2_x:array[0..31] of dword=(1*4, 0*4, 3*4, 2*4, 5*4, 4*4, 7*4, 6*4,
                               9*4, 8*4,11*4,10*4,13*4,12*4,15*4,14*4,
                              17*4,16*4,19*4,18*4,21*4,20*4,23*4,22*4,
                              25*4,24*4,27*4,26*4,29*4,28*4,31*4,30*4);
  pt2_y:array[0..31] of dword=(0*128, 1*128, 2*128, 3*128, 4*128, 5*128, 6*128, 7*128,
                               8*128, 9*128,10*128,11*128,12*128,13*128,14*128,15*128,
                              16*128,17*128,18*128,19*128,20*128,21*128,22*128,23*128,
                              24*128,25*128,26*128,27*128,28*128,29*128,30*128,31*128);

procedure poner_roms_word;
var
  rom_size:dword;
  tempw:word;
begin
//es una mierda... Lo cargo todo como bytes y luego lo convierto a word...
ptemp:=memoria_temp;
for rom_size:=0 to $bffff do begin
  tempw:=ptemp^ shl 8;
  inc(ptemp);
  tempw:=tempw or ptemp^;
  inc(ptemp);
  rom[rom_size]:=tempw;
end;
end;

procedure convert_chars(n:dword);
begin
  init_gfx(0,8,8,n);
  init_gfx(1,8,8,n);
  gfx[0].trans[15]:=true;
  gfx[1].trans[15]:=true;
  gfx_set_desc_data(4,0,64*8,0,1,2,3);
  convert_gfx(0,0,memoria_temp,@pt2_x,@pt_y,false,false);
  convert_gfx(1,0,memoria_temp,@pt2_x[8],@pt_y,false,false);
end;

procedure convert_tiles16(n:dword);
begin
  init_gfx(2,16,16,n);
  gfx[2].trans[15]:=true;
  gfx_set_desc_data(4,0,128*8,0,1,2,3);
  convert_gfx(2,0,memoria_temp,@pt2_x,@pt_y,false,false);
end;

procedure convert_tiles32(n:dword);
begin
  init_gfx(3,32,32,n);
  gfx[3].trans[15]:=true;
  gfx_set_desc_data(4,0,512*8,0,1,2,3);
  convert_gfx(3,0,memoria_temp,@pt2_x,@pt2_y,false,false);
end;

begin
llamadas_maquina.bucle_general:=cps1_principal;
llamadas_maquina.close:=cerrar_cps1;
llamadas_maquina.reset:=reset_cps1;
llamadas_maquina.fps_max:=59.61;
iniciar_cps1:=false;
//8x8
screen_init(1,448,248,true,false);
screen_mod_scroll(1,448,448,511,248,248,255);
//16x16
screen_init(2,464,256,true,false);
screen_mod_scroll(2,464,464,511,256,256,255);
for f:=3 to 4 do begin
  screen_init(f,480,320,true,false);
  screen_mod_scroll(f,480,448,511,320,288,511);
end;
screen_init(5,512,512,false,true);
iniciar_video(384,224);
getmem(memoria_temp,$600000);
case main_vars.tipo_maquina of
  103..111:begin
             iniciar_audio(false);
             if (main_vars.tipo_maquina=111) then m68000_0:=cpu_m68000.create(12000000,262)
                else m68000_0:=cpu_m68000.create(10000000,262);
             m68000_0.change_ram16_calls(cps1_getword,cps1_putword);
             //Sound CPU
             z80_0:=cpu_z80.create(3579545,262);
             z80_0.change_ram_calls(cps1_snd_getbyte,cps1_snd_putbyte);
             z80_0.init_sound(cps1_sound_update);
             //Sound chips
             ym2151_0:=ym2151_chip.create(3579545);
             ym2151_0.change_irq_func(cps1_ym2151_snd_irq);
             oki_6295_0:=snd_okim6295.Create(1000000,OKIM6295_PIN7_HIGH,0.50);
           end;
  112,113:begin  //Qsound
           iniciar_audio(true);
           m68000_0:=cpu_m68000.create(12000000,262);
           m68000_0.change_ram16_calls(cps1_qsnd_getword,cps1_qsnd_putword);
           //Sound CPU
           z80_0:=cpu_z80.create(8000000,262);
           z80_0.change_ram_calls(cps1_qz80_getbyte,cps1_qz80_putbyte);
           z80_0.init_sound(qsound_sound_update);
           //Sound Chip
           qsound_init($200000);
           timers.init(z80_0.numero_cpu,8000000/250,cps1_qsnd_int,nil,true);
      end;
end;
case main_vars.tipo_maquina of
  103:begin
        nbank:=0;
        cps_b:=0;
        //cargar roms
        if not(roms_load16b(memoria_temp,ghouls_rom1)) then exit;
        if not(roms_load(memoria_temp,ghouls_rom2)) then exit;
        poner_roms_word;
        //roms sonido y poner en su banco
        if not(roms_load(memoria_temp,ghouls_sound)) then exit;
        ptemp:=memoria_temp;
        copymemory(@mem_snd,ptemp,$8000);inc(ptemp,$8000);
        copymemory(@snd_rom[0,0],ptemp,$4000);inc(ptemp,$4000);
        copymemory(@snd_rom[1,0],ptemp,$4000);
        //convertir gfx (salen todos de los mismos datos)
        if not(roms_load64b(memoria_temp,ghouls_gfx1)) then exit;
        if not(roms_load64b_b(memoria_temp,ghouls_gfx2)) then exit;
        cps1_gfx_decode(memoria_temp,$300000);
        //Chars
        convert_chars($c000);
        //Tiles 16x16
        convert_tiles16($6000);
        //Tiles 32x32
        convert_tiles32($1800);
        dswa:=$ff;
        dswb:=$ff;
        dswc:=$ff;
  end;
  104:begin
        nbank:=1;
        cps_b:=1;
        //cargar roms
        if not(roms_load16b(memoria_temp,ffight_rom1)) then exit;
        if not(roms_load_swap_word(memoria_temp,ffight_rom2)) then exit;
        poner_roms_word;
        //roms sonido y poner en su banco
        if not(roms_load(memoria_temp,ffight_sound)) then exit;
        ptemp:=memoria_temp;
        copymemory(@mem_snd,ptemp,$8000);inc(ptemp,$8000);
        copymemory(@snd_rom[0,0],ptemp,$4000);inc(ptemp,$4000);
        copymemory(@snd_rom[1,0],ptemp,$4000);
        //Cargar ADPCM ROMS
        if not(roms_load(oki_6295_0.get_rom_addr,ffight_oki)) then exit;
        //convertir gfx (salen todos de los mismos datos)
        if not(roms_load64b(memoria_temp,ffight_gfx1)) then exit;
        cps1_gfx_decode(memoria_temp,$200000);
        //Chars
        convert_chars($8000);
        //Tiles 16x16
        convert_tiles16($4000);
        //Tiles 32x32
        convert_tiles32($1000);
        dswa:=$ff;
        dswb:=$f4;
        dswc:=$9f;
  end;
  105:begin
        nbank:=2;
        cps_b:=2;
        //cargar roms
        if not(roms_load16b(memoria_temp,kod_rom1)) then exit;
        poner_roms_word;
        //roms sonido y poner en su banco
        if not(roms_load(memoria_temp,kod_sound)) then exit;
        ptemp:=memoria_temp;
        copymemory(@mem_snd,ptemp,$8000);inc(ptemp,$8000);
        copymemory(@snd_rom[0,0],ptemp,$4000);inc(ptemp,$4000);
        copymemory(@snd_rom[1,0],ptemp,$4000);
        //Cargar ADPCM ROMS
        if not(roms_load(oki_6295_0.get_rom_addr,kod_oki)) then exit;
        //convertir gfx (salen todos de los mismos datos)
        if not(roms_load64b(memoria_temp,kod_gfx1)) then exit;
        cps1_gfx_decode(memoria_temp,$400000);
        //Chars
        convert_chars($10000);
        //Tiles 16x16
        convert_tiles16($8000);
        //Tiles 32x32
        convert_tiles32($2000);
        dswa:=$ff;
        dswb:=$fc;
        dswc:=$9f;
  end;
  106:begin
        nbank:=3;
        cps_b:=3;
        //cargar roms
        if not(roms_load16b(memoria_temp,sf2_rom1)) then exit;
        poner_roms_word;
        //roms sonido y poner en su banco
        if not(roms_load(memoria_temp,sf2_sound)) then exit;
        ptemp:=memoria_temp;
        copymemory(@mem_snd,ptemp,$8000);inc(ptemp,$8000);
        copymemory(@snd_rom[0,0],ptemp,$4000);inc(ptemp,$4000);
        copymemory(@snd_rom[1,0],ptemp,$4000);
        //Cargar ADPCM ROMS
        if not(roms_load(oki_6295_0.get_rom_addr,sf2_oki)) then exit;
        //convertir gfx (salen todos de los mismos datos)
        if not(roms_load64b(memoria_temp,sf2_gfx1)) then exit;
        cps1_gfx_decode(memoria_temp,$600000);
        //Chars
        convert_chars($18000);
        //Tiles 16x16
        convert_tiles16($c000);
        //Tiles 32x32
        convert_tiles32($3000);
        dswa:=$ff;
        dswb:=$fc;
        dswc:=$9f;
  end;
  107:begin  //Strider
        nbank:=4;
        cps_b:=0;
        //cargar roms
        if not(roms_load16b(memoria_temp,strider_rom1)) then exit;
        if not(roms_load_swap_word(memoria_temp,strider_rom2)) then exit;
        poner_roms_word;
        //roms sonido y poner en su banco
        if not(roms_load(memoria_temp,strider_sound)) then exit;
        ptemp:=memoria_temp;
        copymemory(@mem_snd,ptemp,$8000);inc(ptemp,$8000);
        copymemory(@snd_rom[0,0],ptemp,$4000);inc(ptemp,$4000);
        copymemory(@snd_rom[1,0],ptemp,$4000);
        //Cargar ADPCM ROMS
        if not(roms_load(oki_6295_0.get_rom_addr,strider_oki)) then exit;
        //convertir gfx (salen todos de los mismos datos)
        if not(roms_load64b(memoria_temp,strider_gfx1)) then exit;
        cps1_gfx_decode(memoria_temp,$400000);
        //Chars
        convert_chars($10000);
        //Tiles 16x16
        convert_tiles16($8000);
        //Tiles 32x32
        convert_tiles32($2000);
        dswa:=$ff;
        dswb:=$bf;
        dswc:=$ff;
  end;
  108:begin  //3 Wonders
        nbank:=5;
        cps_b:=4;
        //cargar roms
        if not(roms_load16b(memoria_temp,wonder3_rom1)) then exit;
        poner_roms_word;
        //roms sonido y poner en su banco
        if not(roms_load(memoria_temp,wonder3_sound)) then exit;
        ptemp:=memoria_temp;
        copymemory(@mem_snd,ptemp,$8000);inc(ptemp,$8000);
        copymemory(@snd_rom[0,0],ptemp,$4000);inc(ptemp,$4000);
        copymemory(@snd_rom[1,0],ptemp,$4000);
        //Cargar ADPCM ROMS
        if not(roms_load(oki_6295_0.get_rom_addr,wonder3_oki)) then exit;
        //convertir gfx (salen todos de los mismos datos)
        if not(roms_load64b(memoria_temp,wonder3_gfx1)) then exit;
        cps1_gfx_decode(memoria_temp,$400000);
        //Chars
        convert_chars($10000);
        //Tiles 16x16
        convert_tiles16($8000);
        //Tiles 32x32
        convert_tiles32($2000);
        dswa:=$ff;
        dswb:=$9a;
        dswc:=$99;
  end;
  109:begin  //Captain Commando
        nbank:=6;
        cps_b:=5;
        //cargar roms
        if not(roms_load_swap_word(memoria_temp,ccommando_rom1)) then exit;
        if not(roms_load16b(memoria_temp,ccommando_rom2)) then exit;
        poner_roms_word;
        //roms sonido y poner en su banco
        if not(roms_load(memoria_temp,ccommando_sound)) then exit;
        ptemp:=memoria_temp;
        copymemory(@mem_snd,ptemp,$8000);inc(ptemp,$8000);
        copymemory(@snd_rom[0,0],ptemp,$4000);inc(ptemp,$4000);
        copymemory(@snd_rom[1,0],ptemp,$4000);
        //Cargar ADPCM ROMS
        if not(roms_load(oki_6295_0.get_rom_addr,ccommando_oki)) then exit;
        //convertir gfx (salen todos de los mismos datos)
        if not(roms_load64b(memoria_temp,ccommando_gfx1)) then exit;
        cps1_gfx_decode(memoria_temp,$400000);
        //Chars
        convert_chars($10000);
        //Tiles 16x16
        convert_tiles16($8000);
        //Tiles 32x32
        convert_tiles32($2000);
        dswa:=$ff;
        dswb:=$f4;
        dswc:=$9f;
  end;
  110:begin  //Knights of the Round
        nbank:=7;
        cps_b:=6;
        //cargar roms
        if not(roms_load_swap_word(memoria_temp,knights_rom1)) then exit;
        poner_roms_word;
        //roms sonido y poner en su banco
        if not(roms_load(memoria_temp,knights_sound)) then exit;
        ptemp:=memoria_temp;
        copymemory(@mem_snd,ptemp,$8000);inc(ptemp,$8000);
        copymemory(@snd_rom[0,0],ptemp,$4000);inc(ptemp,$4000);
        copymemory(@snd_rom[1,0],ptemp,$4000);
        //Cargar ADPCM ROMS
        if not(roms_load(oki_6295_0.get_rom_addr,knights_oki)) then exit;
        //convertir gfx (salen todos de los mismos datos)
        if not(roms_load64b(memoria_temp,knights_gfx1)) then exit;
        cps1_gfx_decode(memoria_temp,$400000);
        //Chars
        convert_chars($10000);
        //Tiles 16x16
        convert_tiles16($8000);
        //Tiles 32x32
        convert_tiles32($2000);
        dswa:=$ff;
        dswb:=$fc;
        dswc:=$9f;
  end;
  111:begin  //SF II' CE
        nbank:=8;
        cps_b:=7;
        //cargar roms
        if not(roms_load_swap_word(memoria_temp,sf2ce_rom1)) then exit;
        poner_roms_word;
        //roms sonido y poner en su banco
        if not(roms_load(memoria_temp,sf2ce_sound)) then exit;
        ptemp:=memoria_temp;
        copymemory(@mem_snd,ptemp,$8000);inc(ptemp,$8000);
        copymemory(@snd_rom[0,0],ptemp,$4000);inc(ptemp,$4000);
        copymemory(@snd_rom[1,0],ptemp,$4000);
        //Cargar ADPCM ROMS
        if not(roms_load(oki_6295_0.get_rom_addr,sf2ce_oki)) then exit;
        //convertir gfx (salen todos de los mismos datos)
        if not(roms_load64b(memoria_temp,sf2ce_gfx1)) then exit;
        cps1_gfx_decode(memoria_temp,$600000);
        //Chars
        convert_chars($18000);
        //Tiles 16x16
        convert_tiles16($c000);
        //Tiles 32x32
        convert_tiles32($3000);
        dswa:=$ff;
        dswb:=$fc;
        dswc:=$9f;
  end;
  112:begin  //Cadillacs and Dinosaurs
        nbank:=9;
        cps_b:=8;
        //eeprom
        eeprom_0:=eeprom_class.create(7,8,'0110','0101','0111');
        //cargar roms
        if not(roms_load_swap_word(memoria_temp,dino_rom1)) then exit;
        poner_roms_word;
        //roms sonido y poner en su banco
        if not(roms_load(memoria_temp,dino_sound)) then exit;
        ptemp:=memoria_temp;
        copymemory(@mem_snd,ptemp,$8000);inc(ptemp,$8000);
        for f:=0 to 5 do begin
          copymemory(@snd_rom[f,0],ptemp,$4000);
          inc(ptemp,$4000);
        end;
        kabuki_cps1_decode(@mem_snd,@qsnd_opcode,@qsnd_data,$76543210,$24601357,$4343,$43);
        //Cargar ROMS Qsound
        if not(roms_load(qsound_state.sample_rom,dino_qsound1)) then exit;
        //convertir gfx (salen todos de los mismos datos)
        if not(roms_load64b(memoria_temp,dino_gfx1)) then exit;
        cps1_gfx_decode(memoria_temp,$400000);
        //Chars
        convert_chars($10000);
        //Tiles 16x16
        convert_tiles16($8000);
        //Tiles 32x32
        convert_tiles32($2000);
        dswa:=$ff;
        dswb:=$ff;
        dswc:=$ff;
  end;
  113:begin  //The Punisher
        nbank:=10;
        cps_b:=9;
        //eeprom
        eeprom_0:=eeprom_class.create(7,8,'0110','0101','0111');
        //cargar roms
        if not(roms_load16b(memoria_temp,punisher_rom1)) then exit;
        if not(roms_load_swap_word(memoria_temp,punisher_rom2)) then exit;
        poner_roms_word;
        //roms sonido y poner en su banco
        if not(roms_load(memoria_temp,punisher_sound)) then exit;
        ptemp:=memoria_temp;
        copymemory(@mem_snd,ptemp,$8000);inc(ptemp,$8000);
        for f:=0 to 5 do begin
          copymemory(@snd_rom[f,0],ptemp,$4000);
          inc(ptemp,$4000);
        end;
        kabuki_cps1_decode(@mem_snd,@qsnd_opcode,@qsnd_data,$67452103,$75316024,$2222,$22);
        //Cargar ROMS Qsound
        if not(roms_load(qsound_state.sample_rom,punisher_qsound1)) then exit;
        //convertir gfx (salen todos de los mismos datos)
        if not(roms_load64b(memoria_temp,punisher_gfx1)) then exit;
        cps1_gfx_decode(memoria_temp,$400000);
        //Chars
        convert_chars($10000);
        //Tiles 16x16
        convert_tiles16($8000);
        //Tiles 32x32
        convert_tiles32($2000);
        dswa:=$ff;
        dswb:=$ff;
        dswc:=$ff;
  end;
end;
//final
freemem(memoria_temp);
reset_cps1;
iniciar_cps1:=true;
end;

end.
