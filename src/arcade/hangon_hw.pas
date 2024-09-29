unit hangon_hw;
interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,m68000,main_engine,controls_engine,gfx_engine,rom_engine,
     pal_engine,ppi8255,sound_engine,ym_2203,sega_pcm,fd1089,ym_2151,mcs51;

function iniciar_hangon:boolean;

const
        //Hang-On
        hangon_rom:array[0..3] of tipo_roms=(
        (n:'epr-6918a.ic22';l:$8000;p:0;crc:$20b1c2b0),(n:'epr-6916a.ic8';l:$8000;p:$1;crc:$7d9db1bf),
        (n:'epr-6917a.ic20';l:$8000;p:$10000;crc:$fea12367),(n:'epr-6915a.ic6';l:$8000;p:$10001;crc:$ac883240));
        hangon_sub:array[0..1] of tipo_roms=(
        (n:'epr-6920.ic63';l:$8000;p:0;crc:$1c95013e),(n:'epr-6919.ic51';l:$8000;p:$1;crc:$6ca30d69));
        hangon_sound:tipo_roms=(n:'epr-6833.ic73';l:$4000;p:0;crc:$3b942f5f);
        hangon_tiles:array[0..2] of tipo_roms=(
        (n:'epr-6841.ic38';l:$8000;p:0;crc:$54d295dc),(n:'epr-6842.ic23';l:$8000;p:$8000;crc:$f677b568),
        (n:'epr-6843.ic7';l:$8000;p:$10000;crc:$a257f0da));
        hangon_sprites:array[0..13] of tipo_roms=(
        (n:'epr-6819.ic27';l:$8000;p:0;crc:$469dad07),(n:'epr-6820.ic34';l:$8000;p:1;crc:$87cbc6de),
        (n:'epr-6821.ic28';l:$8000;p:$10000;crc:$15792969),(n:'epr-6822.ic35';l:$8000;p:$10001;crc:$e9718de5),
        (n:'epr-6823.ic29';l:$8000;p:$20000;crc:$49422691),(n:'epr-6824.ic36';l:$8000;p:$20001;crc:$701deaa4),
        (n:'epr-6825.ic30';l:$8000;p:$30000;crc:$6e23c8b4),(n:'epr-6826.ic37';l:$8000;p:$30001;crc:$77d0de2c),
        (n:'epr-6827.ic31';l:$8000;p:$40000;crc:$7fa1bfb6),(n:'epr-6828.ic38';l:$8000;p:$40001;crc:$8e880c93),
        (n:'epr-6829.ic32';l:$8000;p:$50000;crc:$7ca0952d),(n:'epr-6830.ic39';l:$8000;p:$50001;crc:$b1a63aef),
        (n:'epr-6845.ic18';l:$8000;p:$60000;crc:$ba08c9b8),(n:'epr-6846.ic25';l:$8000;p:$60001;crc:$f21e57a3));
        hangon_road:tipo_roms=(n:'epr-6840.ic108';l:$8000;p:0;crc:$581230e3);
        sprite_zoom:tipo_roms=(n:'epr-6844.ic123';l:$2000;p:0;crc:$e3ec7bd6);
        hangon_pcm:array[0..1] of tipo_roms=(
        (n:'epr-6831.ic5';l:$8000;p:$0;crc:$cfef5481),(n:'epr-6832.ic6';l:$8000;p:$8000;crc:$4165aea5));
        hangon_dip_a:array [0..2] of def_dip=(
        (mask:$0f;name:'Coin A';number:16;dip:((dip_val:$7;dip_name:'4C/1C'),(dip_val:$8;dip_name:'3C/1C'),(dip_val:$9;dip_name:'2C/1C'),(dip_val:$5;dip_name:'2C/1C 5C/3C 6C/4C'),(dip_val:$4;dip_name:'2C/1C 4C/3C'),(dip_val:$f;dip_name:'1C/1C'),(dip_val:$3;dip_name:'1C/1C 5C/6C'),(dip_val:$2;dip_name:'1C/1C 4C/5C'),(dip_val:$1;dip_name:'1C/1C 2C/3C'),(dip_val:$6;dip_name:'2C/3C'),(dip_val:$e;dip_name:'1C/2C'),(dip_val:$d;dip_name:'1C/3C'),(dip_val:$c;dip_name:'1C/4C'),(dip_val:$b;dip_name:'1C/5C'),(dip_val:$a;dip_name:'1C/6C'),())),
        (mask:$f0;name:'Coin B';number:16;dip:((dip_val:$70;dip_name:'4C/1C'),(dip_val:$80;dip_name:'3C/1C'),(dip_val:$90;dip_name:'2C/1C'),(dip_val:$50;dip_name:'2C/1C 5C/3C 6C/4C'),(dip_val:$40;dip_name:'2C/1C 4C/3C'),(dip_val:$f0;dip_name:'1C/1C'),(dip_val:$30;dip_name:'1C/1C 5C/6C'),(dip_val:$20;dip_name:'1C/1C 4C/5C'),(dip_val:$10;dip_name:'1C/1C 2C/3C'),(dip_val:$60;dip_name:'2C/3C'),(dip_val:$e0;dip_name:'1C/2C'),(dip_val:$d0;dip_name:'1C/3C'),(dip_val:$c0;dip_name:'1C/4C'),(dip_val:$b0;dip_name:'1C/5C'),(dip_val:$a0;dip_name:'1C/6C'),())),());
        hangon_dip_b:array [0..4] of def_dip=(
        (mask:$1;name:'Demo Sounds';number:2;dip:((dip_val:$1;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$6;name:'Difficulty';number:4;dip:((dip_val:$4;dip_name:'Easy'),(dip_val:$6;dip_name:'Medium'),(dip_val:$2;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$18;name:'Time Adjust';number:4;dip:((dip_val:$18;dip_name:'Normal'),(dip_val:$10;dip_name:'Medium'),(dip_val:$8;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Play Music';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$20;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        //Enduro Racer
        enduror_rom:array[0..5] of tipo_roms=(
        (n:'epr-7640a.ic97';l:$8000;p:0;crc:$1d1dc5d4),(n:'epr-7636a.ic84';l:$8000;p:$1;crc:$84131639),
        (n:'epr-7641.ic98';l:$8000;p:$10000;crc:$2503ae7c),(n:'epr-7637.ic85';l:$8000;p:$10001;crc:$82a27a8c),
        (n:'epr-7642.ic99';l:$8000;p:$20000;crc:$1c453bea),(n:'epr-7638.ic86';l:$8000;p:$20001;crc:$70544779));
        enduror_sub:array[0..1] of tipo_roms=(
        (n:'epr-7634a.ic54';l:$8000;p:0;crc:$aec83731),(n:'epr-7635a.ic67';l:$8000;p:$1;crc:$b2fce96f));
        enduror_sound:tipo_roms=(n:'epr-7682.ic58';l:$8000;p:$0;crc:$c4efbf48);
        enduror_tiles:array[0..2] of tipo_roms=(
        (n:'epr-7644.ic31';l:$8000;p:0;crc:$e7a4ff90),(n:'epr-7645.ic46';l:$8000;p:$8000;crc:$4caa0095),
        (n:'epr-7646.ic60';l:$8000;p:$10000;crc:$7e432683));
        enduror_sprites:array[0..31] of tipo_roms=(
        (n:'epr-7678.ic36';l:$8000;p:0;crc:$9fb5e656),(n:'epr-7670.ic28';l:$8000;p:1;crc:$dbbe2f6e),
        (n:'epr-7662.ic18';l:$8000;p:2;crc:$cb0c13c5),(n:'epr-7654.ic8';l:$8000;p:3;crc:$2db6520d),
        (n:'epr-7677.ic35';l:$8000;p:$20000;crc:$7764765b),(n:'epr-7669.ic27';l:$8000;p:$20001;crc:$f9525faa),
        (n:'epr-7661.ic17';l:$8000;p:$20002;crc:$fe93a79b),(n:'epr-7653.ic7';l:$8000;p:$20003;crc:$46a52114),
        (n:'epr-7676.ic34';l:$8000;p:$40000;crc:$2e42e0d4),(n:'epr-7668.ic26';l:$8000;p:$40001;crc:$e115ce33),
        (n:'epr-7660.ic16';l:$8000;p:$40002;crc:$86dfbb68),(n:'epr-7652.ic6';l:$8000;p:$40003;crc:$2880cfdb),
        (n:'epr-7675.ic33';l:$8000;p:$60000;crc:$05cd2d61),(n:'epr-7667.ic25';l:$8000;p:$60001;crc:$923bde9d),
        (n:'epr-7659.ic15';l:$8000;p:$60002;crc:$629dc8ce),(n:'epr-7651.ic5';l:$8000;p:$60003;crc:$d7902bad),
        (n:'epr-7674.ic32';l:$8000;p:$80000;crc:$1a129acf),(n:'epr-7666.ic24';l:$8000;p:$80001;crc:$23697257),
        (n:'epr-7658.ic14';l:$8000;p:$80002;crc:$1677f24f),(n:'epr-7650.ic4';l:$8000;p:$80003;crc:$642635ec),
        (n:'epr-7673.ic31';l:$8000;p:$a0000;crc:$82602394),(n:'epr-7665.ic23';l:$8000;p:$a0001;crc:$12d77607),
        (n:'epr-7657.ic13';l:$8000;p:$a0002;crc:$8158839c),(n:'epr-7649.ic3';l:$8000;p:$a0003;crc:$4edba14c),
        (n:'epr-7672.ic30';l:$8000;p:$c0000;crc:$d11452f7),(n:'epr-7664.ic22';l:$8000;p:$c0001;crc:$0df2cfad),
        (n:'epr-7656.ic12';l:$8000;p:$c0002;crc:$6c741272),(n:'epr-7648.ic2';l:$8000;p:$c0003;crc:$983ea830),
        (n:'epr-7671.ic29';l:$8000;p:$e0000;crc:$b0c7fdc6),(n:'epr-7663.ic21';l:$8000;p:$e0001;crc:$2b0b8f08),
        (n:'epr-7655.ic11';l:$8000;p:$e0002;crc:$3433fe7b),(n:'epr-7647.ic1';l:$8000;p:$e0003;crc:$2e7fbec0));
        enduror_road:tipo_roms=(n:'epr-7633.ic1';l:$8000;p:0;crc:$6f146210);
        enduror_key:tipo_roms=(n:'317-0013a.key';l:$2000;p:0;crc:$a965b2da);
        enduror_pcm:array[0..1] of tipo_roms=(
        (n:'epr-7681.ic8';l:$8000;p:$0;crc:$bc0c4d12),(n:'epr-7680.ic7';l:$8000;p:$10000;crc:$627b3c8c));
        enduror_dip_b:array [0..5] of def_dip=(
        (mask:$1;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$1;dip_name:'Wheelie'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$6;name:'Difficulty';number:4;dip:((dip_val:$4;dip_name:'Easy'),(dip_val:$6;dip_name:'Medium'),(dip_val:$2;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$18;name:'Time Adjust';number:4;dip:((dip_val:$10;dip_name:'Easy'),(dip_val:$18;dip_name:'Medium'),(dip_val:$8;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$60;name:'Time Control';number:4;dip:((dip_val:$40;dip_name:'Easy'),(dip_val:$60;dip_name:'Medium'),(dip_val:$20;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Demo Sounds';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        //Space Harrier
        sharrier_rom:array[0..7] of tipo_roms=(
        (n:'epr-7188a.ic97';l:$8000;p:0;crc:$45e173c3),(n:'epr-7184a.ic84';l:$8000;p:$1;crc:$e1934a51),
        (n:'epr-7189.ic98';l:$8000;p:$10000;crc:$40b1309f),(n:'epr-7185.ic85';l:$8000;p:$10001;crc:$ce78045c),
        (n:'epr-7190.ic99';l:$8000;p:$20000;crc:$f6391091),(n:'epr-7186.ic86';l:$8000;p:$20001;crc:$79b367d7),
        (n:'epr-7191.ic100';l:$8000;p:$30000;crc:$6171e9d3),(n:'epr-7187.ic87';l:$8000;p:$30001;crc:$70cb72ef));
        sharrier_sub:array[0..1] of tipo_roms=(
        (n:'epr-7182.ic54';l:$8000;p:0;crc:$d7c535b6),(n:'epr-7183.ic67';l:$8000;p:$1;crc:$a6153af8));
        sharrier_sound:array[0..1] of tipo_roms=(
        (n:'epr-7234.ic73';l:$4000;p:0;crc:$d6397933),(n:'epr-7233.ic72';l:$4000;p:$4000;crc:$504e76d9));
        sharrier_tiles:array[0..2] of tipo_roms=(
        (n:'epr-7196.ic31';l:$8000;p:0;crc:$347fa325),(n:'epr-7197.ic46';l:$8000;p:$8000;crc:$39d98bd1),
        (n:'epr-7198.ic60';l:$8000;p:$10000;crc:$3da3ea6b));
        sharrier_sprites:array[0..31] of tipo_roms=(
        (n:'epr-7230.ic36';l:$8000;p:0;crc:$93e2d264),(n:'epr-7222.ic28';l:$8000;p:1;crc:$edbf5fc3),
        (n:'epr-7214.ic18';l:$8000;p:2;crc:$e8c537d8),(n:'epr-7206.ic8';l:$8000;p:3;crc:$22844fa4),
        (n:'epr-7229.ic35';l:$8000;p:$20000;crc:$cd6e7500),(n:'epr-7221.ic27';l:$8000;p:$20001;crc:$41f25a9c),
        (n:'epr-7213.ic17';l:$8000;p:$20002;crc:$5bb09a67),(n:'epr-7205.ic7';l:$8000;p:$20003;crc:$dcaa2ebf),
        (n:'epr-7228.ic34';l:$8000;p:$40000;crc:$d5e15e66),(n:'epr-7220.ic26';l:$8000;p:$40001;crc:$ac62ae2e),
        (n:'epr-7212.ic16';l:$8000;p:$40002;crc:$9c782295),(n:'epr-7204.ic6';l:$8000;p:$40003;crc:$3711105c),
        (n:'epr-7227.ic33';l:$8000;p:$60000;crc:$60d7c1bb),(n:'epr-7219.ic25';l:$8000;p:$60001;crc:$f6330038),
        (n:'epr-7211.ic15';l:$8000;p:$60002;crc:$60737b98),(n:'epr-7203.ic5';l:$8000;p:$60003;crc:$70fb5ebb),
        (n:'epr-7226.ic32';l:$8000;p:$80000;crc:$6d7b5c97),(n:'epr-7218.ic24';l:$8000;p:$80001;crc:$cebf797c),
        (n:'epr-7210.ic14';l:$8000;p:$80002;crc:$24596a8b),(n:'epr-7202.ic4';l:$8000;p:$80003;crc:$b537d082),
        (n:'epr-7225.ic31';l:$8000;p:$a0000;crc:$5e784271),(n:'epr-7217.ic23';l:$8000;p:$a0001;crc:$510e5e10),
        (n:'epr-7209.ic13';l:$8000;p:$a0002;crc:$7a2dad15),(n:'epr-7201.ic3';l:$8000;p:$a0003;crc:$f5ba4e08),
        (n:'epr-7224.ic30';l:$8000;p:$c0000;crc:$ec42c9ef),(n:'epr-7216.ic22';l:$8000;p:$c0001;crc:$6d4a7d7a),
        (n:'epr-7208.ic12';l:$8000;p:$c0002;crc:$0f732717),(n:'epr-7200.ic2';l:$8000;p:$c0003;crc:$fc3bf8f3),
        (n:'epr-7223.ic29';l:$8000;p:$e0000;crc:$ed51fdc4),(n:'epr-7215.ic21';l:$8000;p:$e0001;crc:$dfe75f3d),
        (n:'epr-7207.ic11';l:$8000;p:$e0002;crc:$a2c07741),(n:'epr-7199.ic1';l:$8000;p:$e0003;crc:$b191e22f));
        sharrier_road:tipo_roms=(n:'epr-7181.ic2';l:$8000;p:0;crc:$b4740419);
        sharrier_mcu:tipo_roms=(n:'315-5163a.ic32';l:$1000;p:0;crc:$203dffeb);
        sharrier_pcm:array[0..1] of tipo_roms=(
        (n:'epr-7231.ic5';l:$8000;p:$0;crc:$871c6b14),(n:'epr-7232.ic6';l:$8000;p:$8000;crc:$4b59340c));
        sharrier_dip_b:array [0..6] of def_dip=(
        (mask:$1;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$1;dip_name:'Moving'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2;name:'Demo Sounds';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Lives';number:4;dip:((dip_val:$8;dip_name:'2'),(dip_val:$c;dip_name:'3'),(dip_val:$4;dip_name:'4'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Bonus Life';number:2;dip:((dip_val:$10;dip_name:'5000000'),(dip_val:$0;dip_name:'7000000'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Trial Time';number:2;dip:((dip_val:$20;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Difficulty';number:4;dip:((dip_val:$80;dip_name:'Easy'),(dip_val:$c0;dip_name:'Medium'),(dip_val:$40;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),());
        HANG_ON=1;
        SHARRIER=2;

type
  tsystem16_info=record
    	normal,shadow,hilight:array[0..31] of byte;
      banks:byte;
      screen:array[0..7] of byte;
      screen_enabled:boolean;
      tile_buffer:array[0..7,0..$7ff] of boolean;
   end;
   thangon_road=record
      control:byte;
      colorbase1,colorbase2,colorbase3:word;
      xoff:word;
      type_:byte;
   end;

var
 rom,rom_data:array[0..$1ffff] of word;
 rom2:array[0..$7fff] of word;
 tile_ram:array[0..$3fff] of word;
 ram,ram2:array[0..$1fff] of word;
 road_ram,char_ram,sprite_ram:array[0..$7ff] of word;
 sprite_rom:array[0..$7ffff] of word;
 sprite_rom_32:array[0..$3ffff] of dword;
 s16_info:tsystem16_info;
 road_info:thangon_road;
 sprite_bank:array[0..$f] of byte;
 zoom_sp:array[0..$1fff] of byte;
 control_res,adc_select,sound_latch:byte;
 pcm_rom:array[0..$1ffff] of byte;
 road_gfx:array[0..((256*512)-1)] of byte;
 update_video,sharrier_controls_update:procedure;
 CPU_SYNC:byte;
 //MCU
 i8751_addr:byte;

implementation

procedure draw_road(pri:byte);
var
  y,ctr9m,ctr9n9p,ss8j,md,select:byte;
  color,control,hpos,color0,color1:word;
  src:dword;
  ff9j1,ff9j2,ctr9n9p_ena,plycont:boolean;
  x:integer;
  ptemp:pword;
begin
  for y:=0 to 255 do begin
    control:=road_ram[y];
    // the PLYCONT signal controls the road layering
    plycont:=((control shr 10) and 3)<>0;
    // skip layers we aren't supposed to be drawing
    if (not(plycont) and (pri<>0)) then continue;
    if (plycont and (pri=0)) then continue;
    hpos:=road_ram[$100+(control and $ff)];
    color0:=road_ram[$200+(control and $ff)];
    color1:=road_ram[$300+(control and $ff)];
    // compute the offset of the road graphics for this line
    src:=(control and $ff)*512;
    // initialize the 4-bit counter at 9M, which counts bits within each road byte
    ctr9m:=hpos and 7;
    // initialize the two 4-bit counters at 9P (low) and 9N (high), which count road data bytes
    ctr9n9p:=hpos shr 3;
    // initialize the flip-flop at 9J (lower half), which controls the counting direction
    ff9j1:=((hpos shr 11) and 1)<>0;
    // initialize the flip-flop at 9J (upper half), which controls the background color
    ff9j2:=true;
    // initialize the serial shifter at 8S, which delays several signals after we flip
    ss8j:=0;
    // draw this scanline from the beginning
    ptemp:=punbuf;
    for x:=-24 to 511 do begin
        // ---- the following logic all happens constantly ----
        // the enable is controlled by the value in the counter at 9M
	      ctr9n9p_ena:=(ctr9m=7);
	      // if we carried out of the 9P/9N counters, we will forcibly clear the flip-flop at 9J (lower half)
        if (ctr9n9p=$ff) then ff9j1:=false;
        // if the control word bit 8 is clear, we will forcibly set the flip-flop at 9J (lower half)
        if (control and $100)=0 then ff9j1:=true;
        // for the Hang On/Super Hang On case only: if the control word bit 9 is clear, we will forcibly
        // set the flip-flip at 9J (upper half)
	      if ((road_info.type_=HANG_ON) and ((control and $200)=0)) then ff9j2:=true;
        // ---- now process the pixel ----
	      md:=3;
	      // the Space Harrier/Enduro Racer hardware has a tweak that maps the control word bit 9 to the
        // /CE line on the road ROM; use this to effectively disable the road data
	      if ((road_info.type_<>SHARRIER) or ((control and $200)=0)) then
	        // the /OE line on the road ROM is linked to the AND of bits 2 & 3 of the counter at 9N
	        if ((ctr9n9p and $c0)=$c0) then begin
	          // note that the pixel logic is hidden in a custom at 9S; this is just a guess
	          if (ss8j and 1)<>0 then md:=road_gfx[src+(((ctr9n9p and $3f) shl 3) or ctr9m)]
                 else md:=road_gfx[src+(((ctr9n9p and $3f) shl 3) or (ctr9m xor 7))];
	        end;
	      // "select" is a made-up signal that comes from bit 3 of the serial shifter and is
	      // used in several places for color selection
	      select:=(ss8j shr 3) and 1;
	      // check the flip-flop at 9J (upper half) to determine if we should use the background color;
	      // the output of this is ANDed with M0 and M1 so it only affects pixels with a value of 3;
	      // this is done by the AND gates at 9L and 7K
	      if (ff9j2 and (md=3)) then begin
	        // in this case, the "select" signal is used to select which background color to use
	        // since the color0 control word contains two selections
          if (select<>0) then color:=(color0 and $3f) or road_info.colorbase2
              else color:=((color0 shr 8) and $3f) or road_info.colorbase2;
	      end else begin
	        // if we're not using the background color, we select pixel data from an alternate path
          // the AND gates at 7L, 9K, and 7K clamp the pixel value to 0 if bit 7 of the color 1
          // signal is 1 and if the pixel value is 3 (both M0 and M1 == 1)
	        if (((color1 and $80)<>0) and (md=3)) then md:=0;
	        // the pixel value plus the "select" line combine to form a mux into the low 8 bits of color1
	        color:=(color1 shr ((md shl 1) or select)) and 1;
	        // this value becomes the low bit of the final color; the "select" line itself and the pixel
	        // value form the other bits
	        color:=color or (select shl 3) or (md shl 1) or road_info.colorbase1;
	      end;
	      // write the pixel if we're past the minimum clip
	      if (x>=0) then begin
           ptemp^:=paleta[color];
           inc(ptemp);
        end;
	      // ---- the following logic all happens on the 6M clock ----
	      // clock the counter at 9M
	      ctr9m:=(ctr9m+1) and 7;
	      // if enabled, clock on the two cascaded 4-bit counters at 9P and 9N
	      if (ctr9n9p_ena) then begin
	        if ff9j1 then ctr9n9p:=ctr9n9p+1
	          else ctr9n9p:=ctr9n9p-1;
	      end;
	      // clock the flip-flop at 9J (upper half)
	      ff9j2:=not(not(ff9j1) and ((ss8j and $80)<>0));
	      // clock the serial shift register at 8J
        ss8j:=(ss8j shl 1) or byte(ff9j1);
    end;
    putpixel(ADD_SPRITE,y+ADD_SPRITE,512,punbuf,5);
  end;
end;

procedure draw_tiles(num:byte;px,py:word;scr:byte);
var
  pos,f,nchar,color,data,x,y:word;
begin
  pos:=s16_info.screen[num]*$800;
  for f:=$0 to $7ff do begin
    data:=tile_ram[pos+f];
    color:=(data shr 5) and $7f;
    if (s16_info.tile_buffer[num,f] or buffer_color[color]) then begin
      x:=((f and $3f) shl 3)+px;
      y:=((f shr 6) shl 3)+py;
      nchar:=(data and $fff);
      put_gfx_trans(x,y,nchar,color shl 3,scr,0);
      s16_info.tile_buffer[num,f]:=false;
    end;
  end;
end;

procedure draw_text;
var
  f,nchar,x,y,atrib:word;
  color:byte;
begin
for f:=$0 to $6ff do begin
  atrib:=char_ram[f];
  color:=(atrib shr 8) and $7;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
    x:=(f and $3f) shl 3;
    y:=(f shr 6) shl 3;
    nchar:=atrib and $ff;
    put_gfx_trans(x,y,nchar,color shl 3,1,0);
    if (atrib and $800)<>0 then put_gfx_trans(x,y,nchar,color shl 3,2,0)
      else put_gfx_block_trans(x,y,2,8,8);
    gfx[0].buffer[f]:=false;
  end;
end;
end;

procedure update_video_hangon;
procedure system16ho_draw_pixel(x,y,pix:word);
var
  punt:word;
begin
  //only draw if onscreen, not 0 or 15
	if ((x<320) and ((pix and $f)<>0) and ((pix and $f)<>15)) then begin
      punt:=paleta[(pix and $3ff)+$400];
      putpixel(x+ADD_SPRITE,y+ADD_SPRITE,1,@punt,5);
	end;
end;

procedure draw_sprites(pri:byte);
var
  sprpri,f,g:byte;
  bottom,top:word;
  xacc,zaddr,zmask,vzoom,hzoom,addr,bank,y,pix,data_7,pixels,color:word;
  x,xpos,pitch:integer;
  spritedata:dword;
begin
  for f:=0 to $7f do begin
    sprpri:=sprite_ram[(f*8)+4] and $3;
    if sprpri<>pri then continue;
    addr:=sprite_ram[(f*8)+3];
    sprite_ram[(f*8)+7]:=addr;
    bottom:=(sprite_ram[f*8] shr 8)+1;
    if bottom>$f0 then break;
    top:=(sprite_ram[f*8] and $ff)+1;
    bank:=sprite_bank[(sprite_ram[(f*8)+1] shr 12) and $f];
    // if hidden, or top greater than/equal to bottom, or invalid bank
		if ((top>=bottom) or (bank=255)) then continue;
		xpos:=(sprite_ram[(f*8)+1] and $1ff)-$bd;
		pitch:=smallint(sprite_ram[(f*8)+2]);
		color:=((sprite_ram[(f*8)+4] shr 8) and $3f) shl 4;
    vzoom:=(sprite_ram[(f*8)+4] shr 2) and $3f;
		hzoom:=vzoom shl 1;
		// clamp to within the memory region size
		spritedata:=$8000*(bank mod s16_info.banks);
    // determine the starting zoom address and mask
		zaddr:=(vzoom and $38) shl 5;
		zmask:=1 shl (vzoom and 7);
		// loop from top to bottom
		for y:=top to (bottom-1) do begin
			// advance a row
			addr:=addr+pitch;
      // if the zoom bit says so, add pitch a second time
			if (zoom_sp[zaddr] and zmask)<>0 then addr:=addr+pitch;
      zaddr:=zaddr+1;
			// skip drawing if not within the cliprect
			if (y<256) then begin
        xacc:=0;
				// note that the System 16A sprites have a design flaw that allows the address
				// to carry into the flip flag, which is the topmost bit -- it is very important
				// to emulate this as the games compensate for it
				// non-flipped case
				if (addr and $8000)=0 then begin
          data_7:=addr;
					x:=xpos;
          while (x<512) do begin
						pixels:=sprite_rom[spritedata+(data_7 and $7fff)];
						// draw four pixels
            for g:=3 downto 0 do begin
              xacc:=(xacc and $ff)+hzoom;
              if (xacc<$100) then begin
                pix:=(pixels shr (g*4)) and $f;
                system16ho_draw_pixel(x,y,pix or color);
                x:=x+1;
              end;
            end;
						// stop if the last pixel in the group was 0xf
						if (((pixels shr 0) and $f)=$f) then begin
              sprite_ram[(f*8)+7]:=data_7;
              break;
            end else data_7:=data_7+1;
					end;
				end else begin
				  // flipped case
          data_7:=addr;
					x:=xpos;
          while (x<512) do begin
						pixels:=sprite_rom[spritedata+(data_7 and $7fff)];
						// draw four pixels
            for g:=0 to 3 do begin
              xacc:=(xacc and $ff)+hzoom;
              if (xacc<$100) then begin
                pix:=(pixels shr (g*4)) and $f;
                system16ho_draw_pixel(x,y,pix or color);
                x:=x+1;
              end;
            end;
						// stop if the last pixel in the group was 0xf
						if (((pixels shr 12) and $f)=$f) then begin
              sprite_ram[(f*8)+7]:=data_7;
              break;
            end else data_7:=data_7-1;
					end;
				end;
			end;
		end;
	end;
end;
var
  scroll_x1,scroll_x2,scroll_y1,scroll_y2:word;
begin
if not(s16_info.screen_enabled) then begin
  fill_full_screen(5,$2000);
  actualiza_trozo_final(0,0,320,224,5);
  exit;
end;
//Background
draw_tiles(0,0,256,3);
draw_tiles(1,512,256,3);
draw_tiles(2,0,0,3);
draw_tiles(3,512,0,3);
scroll_x1:=char_ram[$7fd] and $1ff;
scroll_x1:=($c8-scroll_x1) and $3ff;
scroll_y1:=char_ram[$793] and $ff;
//Foreground
draw_tiles(4,0,256,4);
draw_tiles(5,512,256,4);
draw_tiles(6,0,0,4);
draw_tiles(7,512,0,4);
scroll_x2:=char_ram[$7fc] and $1ff;
scroll_x2:=($c8-scroll_x2) and $3ff;
scroll_y2:=char_ram[$792] and $ff;
//text
draw_text;
//Lo pongo todo con prioridades, falta scrollrow y scrollcol!!
draw_road(0); //R0
scroll_x_y(3,5,scroll_x1,scroll_y1); //B0
scroll_x_y(4,5,scroll_x2,scroll_y2);  //F0
draw_road(1); //R1
actualiza_trozo(192,0,320,224,1,0,0,320,224,5); //T0
draw_sprites(3);
draw_sprites(2);
draw_sprites(1);
draw_sprites(0);
actualiza_trozo(192,0,320,224,2,0,0,320,224,5); //T1
//Y lo pinto a la pantalla principal
actualiza_trozo_final(0,0,320,224,5);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
end;

procedure update_video_sharrier;
procedure system16sh_draw_pixel(x:integer;y,pix:word);
var
  punt,punt2,temp1,temp2,temp3:word;
begin
  //only draw if onscreen, not 0 or 15
	if ((x>=0) and (x<320) and ((pix and $f)<>0) and ((pix and $f)<>15)) then begin
      if (pix and $80f)=$a then begin //Shadow
          punt:=getpixel(x+ADD_SPRITE,y+ADD_SPRITE,5);
          punt2:=paleta[$800];
          temp1:=(((punt and $f800)+(punt2 and $f800)) shr 1) and $f800;
          temp2:=(((punt and $7e0)+(punt2 and $7e0)) shr 1) and $7e0;
          temp3:=(((punt and $1f)+(punt2 and $1f)) shr 1) and $1f;
          punt:=temp1 or temp2 or temp3;
      end else punt:=paleta[(pix and $3ff)+$400]; //Normal
      putpixel(x+ADD_SPRITE,y+ADD_SPRITE,1,@punt,5);
	end;
end;

procedure draw_sprites(pri:byte);
var
  sprpri,f,g:byte;
  bottom,top,xacc,zaddr,zmask,vzoom,hzoom,addr,bank,y,pix,data_7,color:word;
  x,xpos,pitch:integer;
  spritedata,pixels:dword;
begin
  for f:=0 to $ff do begin
    sprpri:=(sprite_ram[(f*$8)+2] shr 14) and $1;
    if sprpri<>pri then continue;
    addr:=sprite_ram[(f*8)+3];
    sprite_ram[(f*8)+7]:=addr;
    bottom:=sprite_ram[f*8] shr 8;
    if bottom>$f0 then break;
    top:=sprite_ram[f*8] and $ff;
    bank:=sprite_bank[(sprite_ram[(f*8)+1] shr 12) and $f];
    // if hidden, or top greater than/equal to bottom, or invalid bank
		if ((top>=bottom) or (bank=255)) then continue;
		xpos:=(sprite_ram[(f*8)+1] and $1ff)-$bd;
		pitch:=sprite_ram[(f*8)+2] and $7f;
    if pitch>$3f then pitch:=-(pitch and $3f);
		color:=(sprite_ram[(f*8)+2] shr 8) shl 4;
    vzoom:=(sprite_ram[(f*8)+4] shr 0) and $3f;
		hzoom:=((sprite_ram[(f*8)+4] shr 8) and $3f) shl 1;
		// clamp to within the memory region size
		spritedata:=$8000*(bank mod s16_info.banks);
    // determine the starting zoom address and mask
		zaddr:=(vzoom and $38) shl 5;
		zmask:=1 shl (vzoom and 7);
		// loop from top to bottom
		for y:=top to (bottom-1) do begin
			// advance a row
			addr:=addr+pitch;
      // if the zoom bit says so, add pitch a second time
			if (zoom_sp[zaddr] and zmask)<>0 then addr:=addr+pitch;
      zaddr:=zaddr+1;
			// skip drawing if not within the cliprect
			if (y<256) then begin
        xacc:=0;
				// note that the System 16A sprites have a design flaw that allows the address
				// to carry into the flip flag, which is the topmost bit -- it is very important
				// to emulate this as the games compensate for it
				// non-flipped case
				if (addr and $8000)=0 then begin
          data_7:=addr;
					x:=xpos;
          while (x<512) do begin
						pixels:=sprite_rom_32[spritedata+(data_7 and $7fff)];
						// draw pixels
            for g:=7 downto 0 do begin
              xacc:=(xacc and $ff)+hzoom;
              if (xacc<$100) then begin
                pix:=(pixels shr (g*4)) and $f;
                system16sh_draw_pixel(x,y,pix or color);
                x:=x+1;
              end;
            end;
						// stop if the last pixel in the group was 0xf
						if (pixels and $f)=$f then begin
              sprite_ram[(f*8)+7]:=data_7;
              break;
            end else data_7:=data_7+1;
					end;
        end else begin
				  // flipped case
          data_7:=addr;
					x:=xpos;
          while (x<512) do begin
						pixels:=sprite_rom_32[spritedata+(data_7 and $7fff)];
						// draw pixels
            for g:=0 to 7 do begin
              xacc:=(xacc and $ff)+hzoom;
              if (xacc<$100) then begin
                pix:=(pixels shr (g*4)) and $f;
                system16sh_draw_pixel(x,y,pix or color);
                x:=x+1;
              end;
            end;
						// stop if the last pixel in the group was 0xf
						if ((pixels shr 28) and $f)=$f then begin
              sprite_ram[(f*8)+7]:=data_7;
              break;
            end else data_7:=data_7-1;
          end;
					end;
				end;
			end;
  end;
end;
var
  scroll_x1,scroll_x2,scroll_y1,scroll_y2:word;
begin
if not(s16_info.screen_enabled) then begin
  fill_full_screen(5,$2000);
  actualiza_trozo_final(0,0,320,224,5);
  exit;
end;
//Background
draw_tiles(0,0,256,3);
draw_tiles(1,512,256,3);
draw_tiles(2,0,0,3);
draw_tiles(3,512,0,3);
scroll_x1:=char_ram[$7fd] and $1ff;
scroll_x1:=($c8-scroll_x1) and $3ff;
scroll_y1:=char_ram[$793] and $ff;
//Foreground
draw_tiles(4,0,256,4);
draw_tiles(5,512,256,4);
draw_tiles(6,0,0,4);
draw_tiles(7,512,0,4);
scroll_x2:=char_ram[$7fc] and $1ff;
scroll_x2:=($c8-scroll_x2) and $3ff;
scroll_y2:=char_ram[$792] and $ff;
//text
draw_text;
//Lo pongo todo con prioridades, falta scrollrow y scrollcol!!
draw_road(0); //R0
scroll_x_y(3,5,scroll_x1,scroll_y1); //B0
scroll_x_y(4,5,scroll_x2,scroll_y2);  //F0
draw_road(1); //R1
draw_sprites(0);
draw_sprites(1);
actualiza_trozo(192,0,320,224,1,0,0,320,224,5); //T0
//Y lo pinto a la pantalla principal
actualiza_trozo_final(0,0,320,224,5);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
end;

procedure eventos_hangon;
begin
if event.arcade then begin
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fffe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fffd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $ffef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $ffbf) else marcade.in0:=(marcade.in0 or $40);
end;
end;

procedure eventos_sharrier;
begin
if event.arcade then begin
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fffe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fffd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $ffef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ffdf) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $ffbf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.but2[0] then marcade.in0:=(marcade.in0 and $ff7f) else marcade.in0:=(marcade.in0 or $80);
end;
end;

procedure hangon_principal;
var
  frame_m,frame_sub,frame_s:single;
  f:word;
  h:byte;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
frame_sub:=m68000_1.tframes;
frame_s:=z80_0.tframes;
while EmuStatus=EsRunning do begin
  for f:=0 to 261 do begin
     for h:=1 to CPU_SYNC do begin
        //main
        m68000_0.run(frame_m);
        frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
        //main
        m68000_1.run(frame_sub);
        frame_sub:=frame_sub+m68000_1.tframes-m68000_1.contador;
        //sound
        z80_0.run(frame_s);
        frame_s:=frame_s+z80_0.tframes-z80_0.contador;
     end;
     case f of
        223:begin
              m68000_0.irq[4]:=HOLD_LINE;
              update_video;
            end;
     end;
  end;
  eventos_hangon;
  video_sync;
end;
end;

function hangon_getword(direccion:dword):word;
begin
case direccion of
    0..$3ffff:hangon_getword:=rom[direccion shr 1];
    $20c000..$20ffff:hangon_getword:=ram[(direccion and $3fff) shr 1];
    $400000..$403fff:hangon_getword:=tile_ram[(direccion and $3fff) shr 1];
    $410000..$410fff:hangon_getword:=char_ram[(direccion and $fff) shr 1];
    $600000..$6007ff:hangon_getword:=sprite_ram[(direccion and $7ff) shr 1];
    $a00000..$a00fff:hangon_getword:=buffer_paleta[(direccion and $fff) shr 1];
    $c00000..$c3ffff:hangon_getword:=rom2[(direccion and $3ffff) shr 1];
    $c68000..$c68fff:hangon_getword:=road_ram[(direccion and $fff) shr 1];
    $c7c000..$c7ffff:hangon_getword:=ram2[(direccion and $3fff) shr 1];
    $e00000..$e00fff:hangon_getword:=pia8255_0.read((direccion and 7) shr 1);
    $e01000..$e01fff:case (direccion and 7) shr 1 of
                        0:hangon_getword:=marcade.in0; //service
                        1:hangon_getword:=marcade.dswa; //coinage
                        2:hangon_getword:=marcade.dswb; //dsw
                        3:hangon_getword:=$ffff;
                     end;
    $e03000..$e03fff:case (direccion and $3f) of
                        0..$1f:hangon_getword:=$ff00 or pia8255_1.read((direccion and 7) shr 1);
                        $20..$3f:hangon_getword:=$ff00 or control_res;
                     end;
end;
end;

procedure test_tile_buffer(direccion:word);
var
  num_scr,f:byte;
  pos:word;
begin
  num_scr:=direccion shr 11;
  pos:=direccion and $7ff;
  for f:=0 to 7 do
    if s16_info.screen[f]=num_scr then s16_info.tile_buffer[f,pos]:=true;
end;

procedure change_pal(direccion,val:word);
var
  color:tcolor;
  r,g,b:integer;
begin
	//     byte 0    byte 1
	//  sBGR BBBB GGGG RRRR
	//  x000 4321 4321 4321
	r:=((val shr 12) and $01) or ((val shl 1) and $1e);
	g:=((val shr 13) and $01) or ((val shr 3) and $1e);
	b:=((val shr 14) and $01) or ((val shr 7) and $1e);
  //normal
  color.r:=s16_info.normal[r];
  color.g:=s16_info.normal[g];
  color.b:=s16_info.normal[b];
  set_pal_color(color,direccion);
  //shadow
  color.r:=s16_info.shadow[r];
  color.g:=s16_info.shadow[g];
  color.b:=s16_info.shadow[b];
  set_pal_color(color,direccion+$800);
  //hilight
  color.r:=s16_info.hilight[r];
  color.g:=s16_info.hilight[g];
  color.b:=s16_info.hilight[b];
  set_pal_color(color,direccion+$1000);
  //Buffer
  buffer_color[(direccion shr 3) and $7f]:=true;
end;

procedure test_screen_change(direccion:word);
begin
if direccion=$74e then begin
          //Background abajo 1-2
          if ((char_ram[$74e] shr 12) and $3)<>s16_info.screen[0] then begin
            s16_info.screen[0]:=(char_ram[$74e] shr 12) and $3;
            fillchar(s16_info.tile_buffer[0,0],$800,1);
          end;
          if ((char_ram[$74e] shr 8) and $3)<>s16_info.screen[1] then begin
            s16_info.screen[1]:=(char_ram[$74e] shr 8) and $3;
            fillchar(s16_info.tile_buffer[1,0],$800,1);
          end;
            //Background arriba 1-2
          if ((char_ram[$74e] shr 4) and $3)<>s16_info.screen[2] then begin
            s16_info.screen[2]:=(char_ram[$74e] shr 4) and $3;
            fillchar(s16_info.tile_buffer[2,0],$800,1);
          end;
          if (char_ram[$74e] and $3)<>s16_info.screen[3] then begin
            s16_info.screen[3]:=char_ram[$74e] and $3;
            fillchar(s16_info.tile_buffer[3,0],$800,1);
          end;
end;
if direccion=$74f then begin
            //Foreground abajo
          if ((char_ram[$74f] shr 12) and $3)<>s16_info.screen[4] then begin
            s16_info.screen[4]:=(char_ram[$74f] shr 12) and $3;
            fillchar(s16_info.tile_buffer[4,0],$800,1);
          end;
          if ((char_ram[$74f] shr 8) and $3)<>s16_info.screen[5] then begin
            s16_info.screen[5]:=(char_ram[$74f] shr 8) and $3;
            fillchar(s16_info.tile_buffer[5,0],$800,1);
          end;
            //Foreground arriba
          if ((char_ram[$74f] shr 4) and $3)<>s16_info.screen[6] then begin
            s16_info.screen[6]:=(char_ram[$74f] shr 4) and $3;
            fillchar(s16_info.tile_buffer[6,0],$800,1);
          end;
          if (char_ram[$74f] and $3)<>s16_info.screen[7] then begin
            s16_info.screen[7]:=char_ram[$74f] and $3;
            fillchar(s16_info.tile_buffer[7,0],$800,1);
          end;
end;
end;

procedure hangon_putword(direccion:dword;valor:word);
begin
case direccion of
    0..$3ffff:;
    $20c000..$20ffff:ram[(direccion and $3fff) shr 1]:=valor;
    $400000..$403fff:if tile_ram[(direccion and $3fff) shr 1]<>valor then begin
                        tile_ram[(direccion and $3fff) shr 1]:=valor;
                        test_tile_buffer((direccion and $3fff) shr 1);
                     end;
    $410000..$410fff:if char_ram[(direccion and $fff) shr 1]<>valor then begin
                        char_ram[(direccion and $fff) shr 1]:=valor;
                        gfx[0].buffer[(direccion and $fff) shr 1]:=true;
                        test_screen_change((direccion and $fff) shr 1);
                     end;
    $600000..$6007ff:sprite_ram[(direccion and $7ff) shr 1]:=valor;
    $a00000..$a00fff:if (buffer_paleta[(direccion and $fff) shr 1]<>valor) then begin
                        buffer_paleta[(direccion and $fff) shr 1]:=valor;
                        change_pal((direccion and $fff) shr 1,valor);
                     end;
    $c00000..$c3ffff:;
    $c68000..$c68fff:road_ram[(direccion and $fff) shr 1]:=valor;
    $c7c000..$c7ffff:ram2[(direccion and $3fff) shr 1]:=valor;
    $e00000..$e00fff:pia8255_0.write((direccion and 7) shr 1,valor);
    $e03000..$e03fff:case (direccion and $3f) of
                        0..$1f:pia8255_1.write((direccion and 7) shr 1,valor);
                        $20..$3f:case adc_select of  //controles
                                  0:control_res:=analog.c[0].x[0]; //Volante
                                  1:control_res:=analog.c[1].val[0]; //gas
                                  2:control_res:=analog.c[2].val[0]; //brake
                                  3:control_res:=0;
                                 end;
                     end;
end;
end;

function hangon_sub_getword(direccion:dword):word;
var
  res:word;
begin
direccion:=direccion and $7ffff;
res:=$ffff;
case direccion of
  0..$ffff:res:=rom2[direccion shr 1];
  $68000..$68fff:res:=road_ram[(direccion and $fff) shr 1];
  $7c000..$7ffff:res:=ram2[(direccion and $3fff) shr 1];
end;
hangon_sub_getword:=res;
end;

procedure hangon_sub_putword(direccion:dword;valor:word);
begin
direccion:=direccion and $7ffff;
case direccion of
  0..$3ffff:;
  $68000..$68fff:road_ram[(direccion and $fff) shr 1]:=valor;
  $7c000..$7ffff:ram2[(direccion and $3fff) shr 1]:=valor;
end;
end;

function hangon_snd_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$7fff:hangon_snd_getbyte:=mem_snd[direccion];
  $c000..$cfff:hangon_snd_getbyte:=mem_snd[$c000+(direccion and $7ff)];
  $d000..$dfff:hangon_snd_getbyte:=ym2203_0.status;
  $e000..$efff:hangon_snd_getbyte:=sega_pcm_0.read(direccion and $ff);
end;
end;

procedure hangon_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:;
  $c000..$cfff:mem_snd[$c000+(direccion and $7ff)]:=valor;
  $d000..$dfff:case (direccion and 1) of
                  0:ym2203_0.Control(valor);
                  1:ym2203_0.write(valor);
               end;
  $e000..$efff:sega_pcm_0.write(direccion and $ff,valor);
end;
end;

function hangon_snd_inbyte(puerto:word):byte;
var
  res:byte;
begin
res:=$ff;
case (puerto and $ff) of
  $40..$7f:begin
            pia8255_0.set_port(2,0);
            res:=sound_latch;
           end;
end;
hangon_snd_inbyte:=res;
end;

//Space Harrier
procedure sharrier_principal;
var
  frame_m,frame_sub,frame_s,frame_mcu:single;
  f:word;
  h:byte;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
frame_sub:=m68000_1.tframes;
frame_s:=z80_0.tframes;
frame_mcu:=mcs51_0.tframes;
while EmuStatus=EsRunning do begin
  for f:=0 to 261 do begin
     for h:=1 to CPU_SYNC do begin
        //main
        m68000_0.run(frame_m);
        frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
        //main
        m68000_1.run(frame_sub);
        frame_sub:=frame_sub+m68000_1.tframes-m68000_1.contador;
        //sound
        z80_0.run(frame_s);
        frame_s:=frame_s+z80_0.tframes-z80_0.contador;
        //MCU
        mcs51_0.run(frame_mcu);
        frame_mcu:=frame_mcu+mcs51_0.tframes-mcs51_0.contador;
     end;
     case f of
        223:begin
              mcs51_0.change_irq0(HOLD_LINE);
              update_video_sharrier;
            end;
     end;
  end;
  eventos_sharrier;
  video_sync;
end;
end;

function sharrier_getword(direccion:dword):word;
begin
case direccion of
    0..$3ffff:sharrier_getword:=rom[direccion shr 1];
    $040000..$043fff:sharrier_getword:=ram[(direccion and $3fff) shr 1];
    $100000..$107fff:sharrier_getword:=tile_ram[(direccion and $7fff) shr 1];
    $108000..$108fff:sharrier_getword:=char_ram[(direccion and $fff) shr 1];
    $110000..$110fff:sharrier_getword:=buffer_paleta[(direccion and $fff) shr 1];
    $124000..$127fff:sharrier_getword:=ram2[(direccion and $3fff) shr 1];
    $130000..$130fff:sharrier_getword:=sprite_ram[(direccion and $fff) shr 1];
    $140000..$14ffff:if (not(m68000_0.write_8bits_hi_dir) and not(m68000_0.write_8bits_lo_dir)) then begin
                       case (direccion and $3f) of
                        0..$f:sharrier_getword:=pia8255_0.read((direccion and 7) shr 1);
                        $10..$1f:case ((direccion and 7) shr 1) of
                                  0:sharrier_getword:=marcade.in0;
                                  1:sharrier_getword:=$ffff;
                                  2:sharrier_getword:=marcade.dswa;
                                  3:sharrier_getword:=marcade.dswb;
                                 end;
                        $20..$2f:sharrier_getword:=pia8255_1.read((direccion and 7) shr 1);
                        $30..$3f:sharrier_getword:=$ff00 or control_res;
                        end;
                     end;
    $c68000..$c68fff:sharrier_getword:=road_ram[(direccion and $fff) shr 1];
end;
end;

procedure sharrier_putword(direccion:dword;valor:word);
begin
case direccion of
    0..$3ffff:;
    $040000..$043fff:ram[(direccion and $3fff) shr 1]:=valor;
    $100000..$107fff:if tile_ram[(direccion and $7fff) shr 1]<>valor then begin
                        tile_ram[(direccion and $7fff) shr 1]:=valor;
                        test_tile_buffer((direccion and $7fff) shr 1);
                     end;
    $108000..$108fff:if char_ram[(direccion and $fff) shr 1]<>valor then begin
                        char_ram[(direccion and $fff) shr 1]:=valor;
                        gfx[0].buffer[(direccion and $fff) shr 1]:=true;
                        test_screen_change((direccion and $fff) shr 1);
                     end;
    $110000..$110fff:if (buffer_paleta[(direccion and $fff) shr 1]<>valor) then begin
                        buffer_paleta[(direccion and $fff) shr 1]:=valor;
                        change_pal((direccion and $fff) shr 1,valor);
                     end;
    $124000..$127fff:ram2[(direccion and $3fff) shr 1]:=valor;
    $130000..$130fff:sprite_ram[(direccion and $fff) shr 1]:=valor;
    $140000..$14ffff:if (not(m68000_0.read_8bits_hi_dir) and not(m68000_0.read_8bits_lo_dir)) then begin
                        case (direccion and $3f) of
                          0..$f:pia8255_0.write((direccion and 7) shr 1,valor);
                          $20..$2f:pia8255_1.write((direccion and 7) shr 1,valor);
                          $30..$3f:sharrier_controls_update;
                        end;
                     end;
    $c68000..$c68fff:road_ram[(direccion and $fff) shr 1]:=valor;
end;
end;

procedure sharrier_controls;
begin
case adc_select of
    0:control_res:=analog.c[0].x[0];
    1:control_res:=analog.c[0].y[0];
    2,3:control_res:=0;
end;
end;

procedure sharrier_out_port1(valor:byte);
var
  irq:byte;
begin
  i8751_addr:=((valor and $40) shr 2) or ((valor and $38) shr 3);
	irq:=not(valor) and $7;
	if (irq<>0) then m68000_0.irq[irq]:=HOLD_LINE;
end;

function mcu_ext_ram_read(direccion:word):byte;
var
  addr:dword;
begin
  addr:=(i8751_addr shl 16) or (direccion xor 1);
  mcu_ext_ram_read:=m68000_0.getbyte(addr);
end;

procedure mcu_ext_ram_write(direccion:word;valor:byte);
var
  addr:dword;
begin
  addr:=(i8751_addr shl 16) or (direccion xor 1);
	// hack, either the cpu is too fast or the mcu too slow or there
	// is some kind of synchronization missing. either way, the mcu
	// clears this value after the cpu sets it.
  if addr=$40385 then exit;
  m68000_0.putbyte(addr,valor);
end;

//Enduro Racer
function enduror_getword(direccion:dword):word;
begin
case direccion of
    0..$3ffff:if m68000_0.opcode then enduror_getword:=rom[direccion shr 1]
                  else enduror_getword:=rom_data[direccion shr 1];
    else enduror_getword:=sharrier_getword(direccion);
end;
end;

function enduror_snd_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$7fff,$f800..$ffff:enduror_snd_getbyte:=mem_snd[direccion];
  $f000..$f7ff:enduror_snd_getbyte:=sega_pcm_0.read(direccion and $ff);
end;
end;

procedure enduror_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:;
  $f000..$f7ff:sega_pcm_0.write(direccion and $ff,valor);
  $f800..$ffff:mem_snd[direccion]:=valor;
end;
end;

function enduror_snd_inbyte(puerto:word):byte;
var
  res:byte;
begin
res:=$ff;
case (puerto and $ff) of
  0..$3f:if (puerto and 1)<>0 then res:=ym2151_0.status;
  $40..$7f:begin
            pia8255_0.set_port(2,0);
            res:=sound_latch;
           end;
end;
enduror_snd_inbyte:=res;
end;

procedure enduror_snd_outbyte(puerto:word;valor:byte);
begin
case (puerto and $ff) of
  0..$3f:case (puerto and 1) of
            0:ym2151_0.reg(valor);
            1:ym2151_0.write(valor);
         end;
end;
end;

procedure enduror_controls;
begin
case adc_select of  //controles
    0:control_res:=analog.c[1].val[0]; //gas
    1:control_res:=analog.c[2].val[0]; //brake
    2:control_res:=analog.c[3].val[0]; //Moto arriba
    3:control_res:=analog.c[0].x[0]; //Volante
end;
end;

//Resto
function hangon_read_pcm(dir:dword):byte;
begin
  hangon_read_pcm:=pcm_rom[dir];
end;

procedure ppi8255_0_wporta(valor:byte);
begin
sound_latch:=valor;
end;

procedure ppi8255_0_wportb(valor:byte);
begin
main_screen.flip_main_screen:=(valor and $80)<>0;
if (valor and $20)<>0 then z80_0.change_reset(CLEAR_LINE)
  else z80_0.change_reset(ASSERT_LINE);
s16_info.screen_enabled:=(valor and $10)<>0;
end;

procedure ppi8255_0_wportc(valor:byte);
begin
if (valor and $80)<>0 then z80_0.change_nmi(CLEAR_LINE)
  else z80_0.change_nmi(ASSERT_LINE);
end;

procedure ppi8255_1_wporta(valor:byte);
begin
if (valor and $40)<>0 then m68000_1.irq[4]:=CLEAR_LINE
  else m68000_1.irq[4]:=ASSERT_LINE;
if (valor and $20)<>0 then m68000_1.change_reset(ASSERT_LINE)
  else m68000_1.change_reset(CLEAR_LINE);
adc_select:=(valor shr 2) and 3;
end;

procedure snd_irq(irqstate:byte);
begin
  z80_0.change_irq(irqstate);
end;

procedure hangon_sound_act;
begin
  ym2203_0.update;
  sega_pcm_0.update;
end;

procedure enduror_sound_act;
begin
  ym2151_0.update;
  sega_pcm_0.update;
end;

//Main
procedure reset_hangon;
var
  f:byte;
begin
 m68000_0.reset;
 m68000_1.reset;
 z80_0.reset;
 case main_vars.tipo_maquina of
  334:ym2203_0.reset;
  335:ym2151_0.reset;
  336:begin
        ym2203_0.reset;
        mcs51_0.reset;
        i8751_addr:=0;
      end;
 end;
 reset_analog;
 sega_pcm_0.reset;
 pia8255_0.reset;
 pia8255_1.reset;
 reset_audio;
 marcade.in0:=$ffff;
 s16_info.screen_enabled:=true;
 fillchar(s16_info.tile_buffer,$4000,1);
 adc_select:=0;
 sound_latch:=0;
 control_res:=0;
 for f:=0 to $f do sprite_bank[f]:=f;
end;

function iniciar_hangon:boolean;
var
  f:byte;
  memoria_temp:array[0..$3ffff] of byte;
  fd1089_key:array[0..$1fff] of byte;
  weights:array[0..1,0..5] of single;
  i0,i1,i2,i3,i4:integer;
const
  pt_x:array[0..7] of dword=(0, 1, 2, 3, 4, 5, 6, 7 );
  pt_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
  resistances_normal:array[0..5] of integer=(3900, 2000, 1000, 1000 div 2,1000 div 4, 0);
	resistances_sh:array[0..5] of integer=(3900, 2000, 1000, 1000 div 2, 1000 div 4, 470);
procedure decode_road;
var
  len,src,dst:dword;
  y,x:word;
begin
  len:=$8000;
  for y:=0 to 255 do begin
    src:=(y*$40) mod len;
		dst:=y*512;
		// loop over columns
		for x:=0 to 511 do
			road_gfx[dst+x]:=(((memoria_temp[src+(x shr 3)] shr (not(x) and 7)) and 1) shl 0) or (((memoria_temp[src+(x shr 3)+$4000] shr (not(x) and 7)) and 1) shl 1);
	end;
end;
begin
llamadas_maquina.bucle_general:=hangon_principal;
llamadas_maquina.reset:=reset_hangon;
iniciar_hangon:=false;
iniciar_audio(true);
//Text
screen_init(1,512,256,true);
screen_init(2,512,256,true);
//Background
screen_init(3,1024,512,true);
screen_mod_scroll(3,1024,512,1023,512,256,511);
//Foreground
screen_init(4,1024,512,true);
screen_mod_scroll(4,1024,512,1023,512,256,511);
//Final
screen_init(5,512,256,false,true);
iniciar_video(320,224);
//PPI 825
pia8255_0:=pia8255_chip.create;
pia8255_0.change_ports(nil,nil,nil,ppi8255_0_wporta,ppi8255_0_wportb,ppi8255_0_wportc);
pia8255_1:=pia8255_chip.create;
pia8255_1.change_ports(nil,nil,nil,ppi8255_1_wporta,nil,nil);
case main_vars.tipo_maquina of
  334:begin //Hang-On
        CPU_SYNC:=2;
        //Main CPU
        m68000_0:=cpu_m68000.create(25174800 div 4,262*CPU_SYNC);
        m68000_0.change_ram16_calls(hangon_getword,hangon_putword);
        if not(roms_load16w(@rom,hangon_rom)) then exit;
        //Sub CPU
        m68000_1:=cpu_m68000.create(25174800 div 4,262*CPU_SYNC);
        m68000_1.change_ram16_calls(hangon_sub_getword,hangon_sub_putword);
        if not(roms_load16w(@rom2,hangon_sub)) then exit;
        //Sound CPU
        z80_0:=cpu_z80.create(4000000,262*CPU_SYNC);
        z80_0.change_ram_calls(hangon_snd_getbyte,hangon_snd_putbyte);
        z80_0.change_io_calls(hangon_snd_inbyte,nil);
        z80_0.init_sound(hangon_sound_act);
        if not(roms_load(@mem_snd,hangon_sound)) then exit;
        //Sound
        ym2203_0:=ym2203_chip.create(4000000,0.3,0.3);
        ym2203_0.change_irq_calls(snd_irq);
        sega_pcm_0:=tsega_pcm.create(8000000,hangon_read_pcm,1.3);
        sega_pcm_0.set_bank(BANK_512);
        if not(roms_load(@pcm_rom,hangon_pcm)) then exit;
        //convertir tiles
        if not(roms_load(@memoria_temp,hangon_tiles)) then exit;
        init_gfx(0,8,8,$1000);
        gfx[0].trans[0]:=true;
        gfx_set_desc_data(3,0,8*8,$10000*8,$8000*8,0);
        convert_gfx(0,0,@memoria_temp,@pt_x,@pt_y,false,false);
        //Cargar ROM de los sprites
        if not(roms_load16b(@sprite_rom,hangon_sprites)) then exit;
        if not(roms_load(@zoom_sp,sprite_zoom)) then exit;
        s16_info.banks:=7;
        //Cargar ROM road y decodificarla
        if not(roms_load(@memoria_temp,hangon_road)) then exit;
        decode_road;
        road_info.colorbase1:=$38;
        road_info.colorbase2:=$7c0;
        road_info.colorbase3:=$7c0;
        road_info.xoff:=0;
        road_info.type_:=HANG_ON;
        //dip
        marcade.dswa:=$ffff;
        marcade.dswa_val:=@hangon_dip_a;
        marcade.dswb:=$fffe;
        marcade.dswb_val:=@hangon_dip_b;
        update_video:=update_video_hangon;
  end;
  335:begin //Enduro Racer
        CPU_SYNC:=12; //Impresionante!!!
        sharrier_controls_update:=enduror_controls;
        //Main CPU
        m68000_0:=cpu_m68000.create(10000000,262*CPU_SYNC);
        m68000_0.change_ram16_calls(enduror_getword,sharrier_putword);
        if not(roms_load16w(@memoria_temp,enduror_rom)) then exit;
        //Decode fd1089
        if not(roms_load(@fd1089_key,enduror_key)) then exit;
        fd1089_decrypt($40000,@memoria_temp,@rom,@rom_data,@fd1089_key,fd_typeB);
        //Sub CPU
        m68000_1:=cpu_m68000.create(10000000,262*CPU_SYNC);
        m68000_1.change_ram16_calls(hangon_sub_getword,hangon_sub_putword);
        if not(roms_load16w(@rom2,enduror_sub)) then exit;
        //Sound CPU
        z80_0:=cpu_z80.create(4000000,262*CPU_SYNC);
        z80_0.change_ram_calls(enduror_snd_getbyte,enduror_snd_putbyte);
        z80_0.change_io_calls(enduror_snd_inbyte,enduror_snd_outbyte);
        z80_0.init_sound(enduror_sound_act);
        if not(roms_load(@mem_snd,enduror_sound)) then exit;
        //Sound
        ym2151_0:=ym2151_chip.create(4000000,0.3);
        ym2151_0.change_irq_func(snd_irq);
        sega_pcm_0:=tsega_pcm.create(4000000,hangon_read_pcm,1.3);
        sega_pcm_0.set_bank(BANK_512);
        if not(roms_load(@pcm_rom,enduror_pcm)) then exit;
        //convertir tiles
        if not(roms_load(@memoria_temp,enduror_tiles)) then exit;
        init_gfx(0,8,8,$1000);
        gfx[0].trans[0]:=true;
        gfx_set_desc_data(3,0,8*8,$10000*8,$8000*8,0);
        convert_gfx(0,0,@memoria_temp,@pt_x,@pt_y,false,false);
        //Cargar ROM de los sprites
        if not(roms_load32dw(@sprite_rom_32,enduror_sprites)) then exit;
        if not(roms_load(@zoom_sp,sprite_zoom)) then exit;
        s16_info.banks:=8;
        //Cargar ROM road y decodificarla
        if not(roms_load(@memoria_temp,enduror_road)) then exit;
        decode_road;
        road_info.colorbase1:=$38;
        road_info.colorbase2:=$7c0;
        road_info.colorbase3:=$7c0;
        road_info.xoff:=0;
        road_info.type_:=SHARRIER;
        //dip
        marcade.dswa:=$ffff;
        marcade.dswa_val:=@hangon_dip_a;
        marcade.dswb:=$ff7e;
        marcade.dswb_val:=@enduror_dip_b;
        update_video:=update_video_sharrier;
  end;
  336:begin //Space Harrier
        CPU_SYNC:=2;
        sharrier_controls_update:=sharrier_controls;
        llamadas_maquina.bucle_general:=sharrier_principal;
        //Main CPU
        m68000_0:=cpu_m68000.create(10000000,262*CPU_SYNC);
        m68000_0.change_ram16_calls(sharrier_getword,sharrier_putword);
        if not(roms_load16w(@rom,sharrier_rom)) then exit;
        //Sub CPU
        m68000_1:=cpu_m68000.create(10000000,262*CPU_SYNC);
        m68000_1.change_ram16_calls(hangon_sub_getword,hangon_sub_putword);
        if not(roms_load16w(@rom2,sharrier_sub)) then exit;
        //Sound CPU
        z80_0:=cpu_z80.create(4000000,262*CPU_SYNC);
        z80_0.change_ram_calls(hangon_snd_getbyte,hangon_snd_putbyte);
        z80_0.change_io_calls(hangon_snd_inbyte,nil);
        z80_0.init_sound(hangon_sound_act);
        if not(roms_load(@mem_snd,sharrier_sound)) then exit;
        //MCU
        mcs51_0:=cpu_mcs51.create(I8X51,8000000,262*CPU_SYNC);
        mcs51_0.change_ram_calls(mcu_ext_ram_read,mcu_ext_ram_write);
        mcs51_0.change_io_calls(nil,nil,nil,nil,nil,sharrier_out_port1,nil,nil);
        if not(roms_load(mcs51_0.get_rom_addr,sharrier_mcu)) then exit;
        //Sound
        ym2203_0:=ym2203_chip.create(4000000,0.3,0.3);
        ym2203_0.change_irq_calls(snd_irq);
        sega_pcm_0:=tsega_pcm.create(8000000,hangon_read_pcm,1.3);
        sega_pcm_0.set_bank(BANK_512);
        if not(roms_load(@pcm_rom,sharrier_pcm)) then exit;
        //convertir tiles
        if not(roms_load(@memoria_temp,sharrier_tiles)) then exit;
        init_gfx(0,8,8,$1000);
        gfx[0].trans[0]:=true;
        gfx_set_desc_data(3,0,8*8,$10000*8,$8000*8,0);
        convert_gfx(0,0,@memoria_temp,@pt_x,@pt_y,false,false);
        //Cargar ROM de los sprites
        if not(roms_load32dw(@sprite_rom_32,sharrier_sprites)) then exit;
        if not(roms_load(@zoom_sp,sprite_zoom)) then exit;
        s16_info.banks:=8;
        //Cargar ROM road y decodificarla
        if not(roms_load(@memoria_temp,sharrier_road)) then exit;
        decode_road;
        road_info.colorbase1:=$38;
        road_info.colorbase2:=$7c0;
        road_info.colorbase3:=$7c0;
        road_info.xoff:=0;
        road_info.type_:=SHARRIER;
        //dip
        marcade.dswa:=$ffff;
        marcade.dswa_val:=@hangon_dip_a;
        marcade.dswb:=$fffc;
        marcade.dswb_val:=@sharrier_dip_b;
  end;
end;
//Controls
init_analog(m68000_0.numero_cpu,m68000_0.clock);
analog_0(100,8,$80,$e0,$20,true,false,false,false);
analog_1(100,20,$ff,0,true);
analog_2(100,40,$ff,0,true);
analog_3(100,4,$ff,$20,true);
//poner la paleta
compute_resistor_weights(0,255,-1.0,
  6,addr(resistances_normal[0]),addr(weights[0]),0,0,
  0,nil,nil,0,0,
  0,nil,nil,0,0);
compute_resistor_weights(0,255,-1.0,
  6,addr(resistances_sh[0]),addr(weights[1]),0,0,
  0,nil,nil,0,0,
  0,nil,nil,0,0);
for f:=0 to 31 do begin
  i4:=(f shr 4) and 1;
  i3:=(f shr 3) and 1;
  i2:=(f shr 2) and 1;
  i1:=(f shr 1) and 1;
  i0:=(f shr 0) and 1;
  s16_info.normal[f]:=combine_6_weights(addr(weights[0]),i0,i1,i2,i3,i4,0);
  s16_info.shadow[f]:=combine_6_weights(addr(weights[1]),i0,i1,i2,i3,i4,0);
  s16_info.hilight[f]:=combine_6_weights(addr(weights[1]),i0,i1,i2,i3,i4,1);
end;
//final
reset_hangon;
iniciar_hangon:=true;
end;

end.
