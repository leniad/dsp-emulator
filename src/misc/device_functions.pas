unit device_functions;
interface
procedure close_all_devices;
implementation
uses nz80,m68000,konami,k052109,k051960,k007232,k053251,k053260,upd7759,sn_76496,
     ay_8910,ym_3812,ym_2203,m6809,vlm_5030,m6502,pokey,m6805,sega_vdp,deco_104,
     deco_146,tms99xx,lr35902,mcs51,m680x,konami_snd,ppi8255,oki6295,dac,msm5205,
     mb88xx,hu6280,tms32010,hd6309,eeprom,nec_v20_v30,z80_sp,mcs48,k051316,
     k053246_k053247_k055673,ym_2151,samples,n2a03,namco_snd,deco_bac06,
     deco_common,deco_16ic,sm510,slapstic,upd7810,upd1771,blitter_williams,
     pia6821,sega_315_5195,sega_pcm,mos6566,mos6526,z80ctc,seibu_sound;
procedure close_all_devices;
begin
//Z80
if z80_0<>nil then begin
  z80_0.free;
  z80_0:=nil;
end;
if z80_1<>nil then begin
  z80_1.free;
  z80_1:=nil;
end;
if z80_2<>nil then begin
  z80_2.free;
  z80_2:=nil;
end;
//M68000
if m68000_0<>nil then begin
   m68000_0.free;
   m68000_0:=nil;
end;
if m68000_1<>nil then begin
  m68000_1.free;
  m68000_1:=nil;
end;
//M6809
if m6809_0<>nil then begin
  m6809_0.free;
  m6809_0:=nil;
end;
if m6809_1<>nil then begin
  m6809_1.free;
  m6809_1:=nil;
end;
if m6809_2<>nil then begin
  m6809_2.free;
  m6809_2:=nil;
end;
//M6502
if m6502_0<>nil then begin
  m6502_0.free;
  m6502_0:=nil;
end;
if m6502_1<>nil then begin
  m6502_1.free;
  m6502_1:=nil;
end;
//Konami
if konami_0<>nil then begin
  konami_0.free;
  konami_0:=nil;
end;
//M6805
if m6805_0<>nil then begin
  m6805_0.free;
  m6805_0:=nil;
end;
if hd6309_0<>nil then begin
  hd6309_0.free;
  hd6309_0:=nil;
end;
//GB
if lr35902_0<>nil then begin
  lr35902_0.free;
  lr35902_0:=nil;
end;
//MCS51
if mcs51_0<>nil then begin
  mcs51_0.free;
  mcs51_0:=nil;
end;
//MCS48
if mcs48_0<>nil then begin
  mcs48_0.free;
  mcs48_0:=nil;
end;
if m6800_0<>nil then begin
  m6800_0.free;
  m6800_0:=nil;
end;
if mb88xx_0<>nil then begin
  mb88xx_0.free;
  mb88xx_0:=nil;
end;
if h6280_0<>nil then begin
  h6280_0.free;
  h6280_0:=nil;
end;
if nec_0<>nil then begin
  nec_0.free;
  nec_0:=nil;
end;
if upd7810_0<>nil then begin
  upd7810_0.free;
  upd7810_0:=nil;
end;
if tms32010_0<>nil then begin
    tms32010_0.free;
    tms32010_0:=nil;
end;
if n2a03_0<>nil then begin
  n2a03_0.free;
  n2a03_0:=nil;
end;
if n2a03_1<>nil then begin
  n2a03_1.free;
  n2a03_1:=nil;
end;
if spec_z80<>nil then begin
  spec_z80.free;
  spec_z80:=nil;
end;
if sm510_0<>nil then begin
  sm510_0.free;
  sm510_0:=nil;
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
if dac_2<>nil then begin
  dac_2.free;
  dac_2:=nil;
end;
if dac_3<>nil then begin
  dac_3.free;
  dac_3:=nil;
end;
if msm5205_0<>nil then begin
  msm5205_0.free;
  msm5205_0:=nil;
end;
if msm5205_1<>nil then begin
  msm5205_1.free;
  msm5205_1:=nil;
end;
if ym2151_0<>nil then begin
  ym2151_0.free;
  ym2151_0:=nil;
end;
if ym2151_1<>nil then begin
  ym2151_1.free;
  ym2151_1:=nil;
end;
if namco_snd_0<>nil then begin
  namco_snd_0.free;
  namco_snd_0:=nil;
end;
if upd1771_0<>nil then begin
  upd1771_0.free;
  upd1771_0:=nil;
end;
if seibu_snd_0<>nil then begin
  //Es importante poner aqui esto! Como tiene chips internos hay que borrarlos antes que el resto o falla
  seibu_snd_0.free;
  seibu_snd_0:=nil;
end;
close_samples;
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
if k007232_1<>nil then begin
  k007232_1.free;
  k007232_1:=nil;
end;
if k053251_0<>nil then begin
  k053251_0.free;
  k053251_0:=nil;
end;
if k053260_0<>nil then begin
  k053260_0.free;
  k053260_0:=nil;
end;
if k053246_0<>nil then begin
  k053246_0.free;
  k053246_0:=nil;
end;
if k051316_0<>nil then begin
  k051316_0.free;
  k051316_0:=nil;
end;
//misc
if slapstic_0<>nil then begin
  slapstic_0.free;
  slapstic_0:=nil;
end;
if vdp_0<>nil then begin
  vdp_0.free;
  vdp_0:=nil;
end;
if vdp_1<>nil then begin
  vdp_1.free;
  vdp_1:=nil;
end;
if main_deco104<>nil then begin
  main_deco104.free;
  main_deco104:=nil;
end;
if main_deco146<>nil then begin
  main_deco146.free;
  main_deco146:=nil;
end;
if bac06_0<>nil then begin
  bac06_0.free;
  bac06_0:=nil;
end;
if deco_sprites_0<>nil then begin
  deco_sprites_0.free;
  deco_sprites_0:=nil;
end;
if deco16ic_0<>nil then begin
  deco16ic_0.free;
  deco16ic_0:=nil;
end;
if deco16ic_1<>nil then begin
  deco16ic_1.free;
  deco16ic_1:=nil;
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
if eeprom_0<>nil then begin
  eeprom_0.free;
  eeprom_0:=nil;
end;
if blitter_0<>nil then begin
  blitter_0.free;
  blitter_0:=nil;
end;
if pia6821_0<>nil then begin
  pia6821_0.free;
  pia6821_0:=nil;
end;
if pia6821_1<>nil then begin
  pia6821_1.free;
  pia6821_1:=nil;
end;
if pia6821_2<>nil then begin
  pia6821_2.free;
  pia6821_2:=nil;
end;
if s315_5195_0<>nil then begin
  s315_5195_0.free;
  s315_5195_0:=nil;
end;
if sega_pcm_0<>nil then begin
  sega_pcm_0.free;
  sega_pcm_0:=nil;
end;
if mos6566_0<>nil then begin
  mos6566_0.free;
  mos6566_0:=nil;
end;
if mos6526_0<>nil then begin
  mos6526_0.free;
  mos6526_0:=nil;
end;
if mos6526_1<>nil then begin
  mos6526_1.free;
  mos6526_1:=nil;
end;
if ctc_0<>nil then begin
  ctc_0.free;
  ctc_0:=nil;
end;
end;
end.
