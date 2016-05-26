unit device_functions;

interface

procedure close_all_devices;

implementation
uses nz80,m68000,konami,k052109,k051960,k007232,k053251,k053260,upd7759,sn_76496,
     ay_8910,ym_3812,ym_2203,m6809,vlm_5030,m6502,pokey,m6805,sega_vdp,deco_104,
     deco_146,tms99xx,lr35902,mcs51,m680x,konami_snd,ppi8255,oki6295,dac,msm5205,
     mb88xx,hu6280,tms32010,hd6309,eeprom,nec_v20_v30,z80_sp;

procedure close_all_devices;
begin
//Z80
if main_z80<>nil then begin
  main_z80.free;
  main_z80:=nil;
end;
if sub_z80<>nil then begin
  sub_z80.free;
  sub_z80:=nil;
end;
if snd_z80<>nil then begin
  snd_z80.free;
  snd_z80:=nil;
end;
//M68000
if main_m68000<>nil then begin
   main_m68000.free;
   main_m68000:=nil;
end;
if snd_m68000<>nil then begin
  snd_m68000.free;
  snd_m68000:=nil;
end;
if sub_m68000<>nil then begin
  sub_m68000.free;
  sub_m68000:=nil;
end;
//M6809
if main_m6809<>nil then begin
  main_m6809.free;
  main_m6809:=nil;
end;
if snd_m6809<>nil then begin
  snd_m6809.free;
  snd_m6809:=nil;
end;
if misc_m6809<>nil then begin
  misc_m6809.free;
  misc_m6809:=nil;
end;
//M6502
if main_m6502<>nil then begin
  main_m6502.free;
  main_m6502:=nil;
end;
if snd_m6502<>nil then begin
  snd_m6502.free;
  snd_m6502:=nil;
end;
//Konami
if main_konami<>nil then begin
  main_konami.free;
  main_konami:=nil;
end;
//M6805
if main_m6805<>nil then begin
  main_m6805.free;
  main_m6805:=nil;
end;
if main_hd6309<>nil then begin
  main_hd6309.free;
  main_hd6309:=nil;
end;
//GB
if main_lr<>nil then begin
  main_lr.free;
  main_lr:=nil;
end;
//MCS51
if main_mcs51<>nil then begin
  main_mcs51.free;
  main_mcs51:=nil;
end;
if main_m6800<>nil then begin
  main_m6800.free;
  main_m6800:=nil;
end;
if snd_m6800<>nil then begin
  snd_m6800.free;
  snd_m6800:=nil;
end;
if main_mb88xx<>nil then begin
  main_mb88xx.free;
  main_mb88xx:=nil;
end;
if main_h6280<>nil then begin
  main_h6280.free;
  main_h6280:=nil;
end;
if main_nec<>nil then begin
  main_nec.free;
  main_nec:=nil;
end;
if spec_z80<>nil then begin
  spec_z80.free;
  spec_z80:=nil;
end;
//Sound
if upd7759_0<>nil then begin
  upd7759_0.free;
  upd7759_0:=nil;
end;
if sn_76496_0<>nil then begin
  sn_76496_0.free;
  sn_76496_0:=nil;
end;
if sn_76496_1<>nil then begin
  sn_76496_1.free;
  sn_76496_1:=nil;
end;
if sn_76496_2<>nil then begin
  sn_76496_2.free;
  sn_76496_2:=nil;
end;
if sn_76496_3<>nil then begin
  sn_76496_3.free;
  sn_76496_3:=nil;
end;
if ay8910_0<>nil then begin
  ay8910_0.free;
  ay8910_0:=nil;
end;
if ay8910_1<>nil then begin
  ay8910_1.free;
  ay8910_1:=nil;
end;
if ay8910_2<>nil then begin
  ay8910_2.free;
  ay8910_2:=nil;
end;
if ay8910_3<>nil then begin
  ay8910_3.free;
  ay8910_3:=nil;
end;
if ay8910_4<>nil then begin
  ay8910_4.free;
  ay8910_4:=nil;
end;
if ym3812_0<>nil then begin
  ym3812_0.free;
  ym3812_0:=nil;
end;
if ym3812_1<>nil then begin
  ym3812_1.free;
  ym3812_1:=nil;
end;
if ym2203_0<>nil then begin
  ym2203_0.free;
  ym2203_0:=nil;
end;
if ym2203_1<>nil then begin
  ym2203_1.free;
  ym2203_1:=nil;
end;
if vlm5030_0<>nil then begin
  vlm5030_0.free;
  vlm5030_0:=nil;
end;
if pokey_0<>nil then begin
  pokey_0.free;
  pokey_0:=nil;
end;
if pokey_1<>nil then begin
  pokey_1.free;
  pokey_1:=nil;
end;
if pokey_2<>nil then begin
  pokey_2.free;
  pokey_2:=nil;
end;
if konamisnd_0<>nil then begin
  konamisnd_0.free;
  konamisnd_0:=nil;
end;
if oki_6295_0<>nil then begin
  oki_6295_0.free;
  oki_6295_0:=nil;
end;
if oki_6295_1<>nil then begin
  oki_6295_1.free;
  oki_6295_1:=nil;
end;
if dac_0<>nil then begin
  dac_0.free;
  dac_0:=nil;
end;
if dac_1<>nil then begin
  dac_1.free;
  dac_1:=nil;
end;
if msm_5205_0<>nil then begin
  msm_5205_0.free;
  msm_5205_0:=nil;
end;
if msm_5205_1<>nil then begin
  msm_5205_1.free;
  msm_5205_1:=nil;
end;
//Konami chips
if k052109_0<>nil then begin
  k052109_0.free;
  k052109_0:=nil;
end;
if k051960_0<>nil then begin
  k051960_0.free;
  k051960_0:=nil;
end;
if k007232_0<>nil then begin
  k007232_0.free;
  k007232_0:=nil;
end;
if k053251_0<>nil then begin
  k053251_0.free;
  k053251_0:=nil;
end;
if k053260_0<>nil then begin
  k053260_0.free;
  k053260_0:=nil;
end;
//misc
if vdp_0<>nil then begin
  vdp_0.free;
  vdp_0:=nil;
end;
if main_deco104<>nil then begin
  main_deco104.free;
  main_deco104:=nil;
end;
if main_deco146<>nil then begin
  main_deco146.free;
  main_deco146:=nil;
end;
if tms_0<>nil then begin
  tms_0.free;
  tms_0:=nil;
end;
if pia8255_0<>nil then begin
  pia8255_0.free;
  pia8255_0:=nil;
end;
if pia8255_1<>nil then begin
  pia8255_1.free;
  pia8255_1:=nil;
end;
if main_tms32010<>nil then begin
    main_tms32010.free;
    main_tms32010:=nil;
end;
if eeprom_0<>nil then begin
  eeprom_0.free;
  eeprom_0:=nil;
end;
end;

end.
