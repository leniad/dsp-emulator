unit pacman_hw;
interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,namco_snd,controls_engine,gfx_engine,rom_engine,
     misc_functions,pal_engine,sound_engine,qsnapshot;

function iniciar_pacman:boolean;

implementation

const
        //Pacman
        pacman_rom:array[0..3] of tipo_roms=(
        (n:'pacman.6e';l:$1000;p:0;crc:$c1e6ab10),(n:'pacman.6f';l:$1000;p:$1000;crc:$1a6fb2d4),
        (n:'pacman.6h';l:$1000;p:$2000;crc:$bcdd1beb),(n:'pacman.6j';l:$1000;p:$3000;crc:$817d94e3));
        pacman_pal:array[0..1] of tipo_roms=(
        (n:'82s123.7f';l:$20;p:0;crc:$2fc650bd),(n:'82s126.4a';l:$100;p:$20;crc:$3eb3a8e4));
        pacman_char:tipo_roms=(n:'pacman.5e';l:$1000;p:0;crc:$0c944964);
        pacman_sound:tipo_roms=(n:'82s126.1m';l:$100;p:0;crc:$a9cc86bf);
        pacman_sprites:tipo_roms=(n:'pacman.5f';l:$1000;p:0;crc:$958fedf9);
        //MS-Pacman
        mspacman_rom:array[0..6] of tipo_roms=(
        (n:'pacman.6e';l:$1000;p:0;crc:$c1e6ab10),(n:'pacman.6f';l:$1000;p:$1000;crc:$1a6fb2d4),
        (n:'pacman.6h';l:$1000;p:$2000;crc:$bcdd1beb),(n:'pacman.6j';l:$1000;p:$3000;crc:$817d94e3),
        (n:'u5';l:$800;p:$8000;crc:$f45fbbcd),(n:'u6';l:$1000;p:$9000;crc:$a90e7000),
        (n:'u7';l:$1000;p:$b000;crc:$c82cd714));
        mspacman_char:tipo_roms=(n:'5e';l:$1000;p:0;crc:$5c281d01);
        mspacman_sprites:tipo_roms=(n:'5f';l:$1000;p:0;crc:$615af909);
        //Crush Roller
        crush_rom:array[0..3] of tipo_roms=(
        (n:'crushkrl.6e';l:$1000;p:0;crc:$a8dd8f54),(n:'crushkrl.6f';l:$1000;p:$1000;crc:$91387299),
        (n:'crushkrl.6h';l:$1000;p:$2000;crc:$d4455f27),(n:'crushkrl.6j';l:$1000;p:$3000;crc:$d59fc251));
        crush_char:tipo_roms=(n:'maketrax.5e';l:$1000;p:0;crc:$91bad2da);
        crush_sprites:tipo_roms=(n:'maketrax.5f';l:$1000;p:0;crc:$aea79f55);
        crush_pal:array[0..1] of tipo_roms=(
        (n:'82s123.7f';l:$20;p:0;crc:$2fc650bd),(n:'2s140.4a';l:$100;p:$20;crc:$63efb927));
        //Ms Pac Man Twin
        mspactwin_rom:tipo_roms=(n:'m27256.bin';l:$8000;p:0;crc:$77a99184);
        mspactwin_char:array[0..1] of tipo_roms=(
        (n:'4__2716.5d';l:$800;p:0;crc:$483c1d1c),(n:'2__2716.5g';l:$800;p:$800;crc:$c08d73a2));
        mspactwin_sprites:array[0..1] of tipo_roms=(
        (n:'3__2516.5f';l:$800;p:0;crc:$22b0188a),(n:'1__2516.5j';l:$800;p:$800;crc:$0a8c46a0));
        mspactwin_pal:array[0..1] of tipo_roms=(
        (n:'mb7051.8h';l:$20;p:0;crc:$ff344446),(n:'82s129.4a';l:$100;p:$20;crc:$a8202d0d));
        //Birdiy
        birdiy_rom:array[0..3] of tipo_roms=(
        (n:'a6.6a';l:$1000;p:0;crc:$3a58f8ad),(n:'c6.6c';l:$1000;p:$1000;crc:$fec61ea2),
        (n:'a4.4a';l:$1000;p:$2000;crc:$3392783b),(n:'c4.4c';l:$1000;p:$3000;crc:$2391d83d));
        birdiy_pal:array[0..1] of tipo_roms=(
        (n:'n82s123n.10n';l:$20;p:0;crc:$ff344446),(n:'n82s129n.9m';l:$100;p:$20;crc:$63efb927));
        birdiy_char:tipo_roms=(n:'c1.1c';l:$1000;p:0;crc:$8f6bf54f);
        birdiy_sprites:tipo_roms=(n:'c3.3c';l:$1000;p:0;crc:$10b55440);
        //Ponpoko
        ponpoko_rom:array[0..7] of tipo_roms=(
        (n:'ppokoj1.bin';l:$1000;p:0;crc:$ffa3c004),(n:'ppokoj2.bin';l:$1000;p:$1000;crc:$4a496866),
        (n:'ppokoj3.bin';l:$1000;p:$2000;crc:$17da6ca3),(n:'ppokoj4.bin';l:$1000;p:$3000;crc:$9d39a565),
        (n:'ppoko5.bin';l:$1000;p:$8000;crc:$54ca3d7d),(n:'ppoko6.bin';l:$1000;p:$9000;crc:$3055c7e0),
        (n:'ppoko7.bin';l:$1000;p:$a000;crc:$3cbe47ca),(n:'ppokoj8.bin';l:$1000;p:$b000;crc:$04b63fc6));
        ponpoko_pal:array[0..1] of tipo_roms=(
        (n:'82s123.7f';l:$20;p:0;crc:$2fc650bd),(n:'82s126.4a';l:$100;p:$20;crc:$3eb3a8e4));
        ponpoko_char:tipo_roms=(n:'ppoko9.bin';l:$1000;p:0;crc:$b73e1a06);
        ponpoko_sprites:tipo_roms=(n:'ppoko10.bin';l:$1000;p:0;crc:$62069b5d);
        //Woodpecker
        woodpeck_rom:array[0..4] of tipo_roms=(
        (n:'f.bin';l:$1000;p:0;crc:$37ea66ca),(n:'i.bin';l:$1000;p:$8000;crc:$cd115dba),
        (n:'e.bin';l:$1000;p:$9000;crc:$d40b2321),(n:'g.bin';l:$1000;p:$a000;crc:$024092f4),
        (n:'h.bin';l:$1000;p:$b000;crc:$18ef0fc8));
        woodpeck_pal:array[0..1] of tipo_roms=(
        (n:'pr.8h';l:$20;p:0;crc:$2fc650bd),(n:'pr.4a';l:$100;p:$20;crc:$d8772167));
        woodpeck_char:array[0..1] of tipo_roms=(
        (n:'a.5e';l:$800;p:0;crc:$15a87f62),(n:'c.5h';l:$800;p:$800;crc:$ab4abd88));
        woodpeck_sprites:array[0..1] of tipo_roms=(
        (n:'b.5f';l:$800;p:0;crc:$5b9ba95b),(n:'d.5j';l:$800;p:$800;crc:$d7b80a45));
        //Eyes
        eyes_rom:array[0..3] of tipo_roms=(
        (n:'d7';l:$1000;p:0;crc:$3b09ac89),(n:'e7';l:$1000;p:$1000;crc:$97096855),
        (n:'f7';l:$1000;p:$2000;crc:$731e294e),(n:'h7';l:$1000;p:$3000;crc:$22f7a719));
        eyes_pal:array[0..1] of tipo_roms=(
        (n:'82s123.7f';l:$20;p:0;crc:$2fc650bd),(n:'82s129.4a';l:$100;p:$20;crc:$d8d78829));
        eyes_char:tipo_roms=(n:'d5';l:$1000;p:0;crc:$d6af0030);
        eyes_sprites:tipo_roms=(n:'e5';l:$1000;p:0;crc:$a42b5201);
        //Alibaba
        alibaba_rom:array[0..5] of tipo_roms=(
        (n:'6e';l:$1000;p:0;crc:$38d701aa),(n:'6f';l:$1000;p:$1000;crc:$3d0e35f3),
        (n:'6h';l:$1000;p:$2000;crc:$823bee89),(n:'6k';l:$1000;p:$3000;crc:$474d032f),
        (n:'6l';l:$1000;p:$8000;crc:$5ab315c1),(n:'6m';l:$800;p:$a000;crc:$438d0357));
        alibaba_pal:array[0..1] of tipo_roms=(
        (n:'82s123.e7';l:$20;p:0;crc:$2fc650bd),(n:'82s129.a4';l:$100;p:$20;crc:$3eb3a8e4));
        alibaba_char:array[0..1] of tipo_roms=(
        (n:'5e';l:$800;p:0;crc:$85bcb8f8),(n:'5h';l:$800;p:$800;crc:$38e50862));
        alibaba_sprites:array[0..1] of tipo_roms=(
        (n:'5f';l:$800;p:0;crc:$b5715c86),(n:'5k';l:$800;p:$800;crc:$713086b3));
        //Piranha
        piranha_rom:array[0..7] of tipo_roms=(
        (n:'pir1.7e';l:$800;p:0;crc:$69a3e6ea),(n:'pir5.6e';l:$800;p:$800;crc:$245e753f),
        (n:'pir2.7f';l:$800;p:$1000;crc:$62cb6954),(n:'pir6.6f';l:$800;p:$1800;crc:$cb0700bc),
        (n:'pir3.7h';l:$800;p:$2000;crc:$843fbfe5),(n:'pir7.6h';l:$800;p:$2800;crc:$73084d5e),
        (n:'pir4.7j';l:$800;p:$3000;crc:$4cdf6704),(n:'pir8.6j';l:$800;p:$3800;crc:$b86fedb3));
        piranha_pal:array[0..1] of tipo_roms=(
        (n:'82s123.7f';l:$20;p:0;crc:$2fc650bd),(n:'piranha.4a';l:$100;p:$20;crc:$08c9447b));
        piranha_char:array[0..1] of tipo_roms=(
        (n:'pir9.5e';l:$800;p:0;crc:$0f19eb28),(n:'pir11.5h';l:$800;p:$800;crc:$5f8bdabe));
        piranha_sprites:array[0..1] of tipo_roms=(
        (n:'pir10.5f';l:$800;p:0;crc:$d19399fb),(n:'pir12.5j';l:$800;p:$800;crc:$cfb4403d));
        //DIP
        pacman_dip_a:array [0..5] of def_dip2=(
        (mask:3;name:'Coinage';number:4;val4:(3,1,2,0);name4:('2C 1C','1C 1C','1C 2C','Free Play')),
        (mask:$c;name:'Lives';number:4;val4:(0,4,8,$c);name4:('1','2','3','5')),
        (mask:$30;name:'Bonus Life';number:4;val4:(0,$10,$20,$30);name4:('10K','15K','20K','None')),
        (mask:$40;name:'Difficulty';number:2;val2:($40,0);name2:('Normal','Hard')),
        (mask:$80;name:'Ghost Names';number:2;val2:($80,0);name2:('Normal','Alternate')),());
        pacman_dip_b:array [0..1] of def_dip2=(
        (mask:$10;name:'Rack Test';number:2;val2:($10,0);name2:('Off','On')),());
        pacman_dip_c:array [0..1] of def_dip2=(
        (mask:$80;name:'Cabinet';number:2;val2:($80,0);name2:('Upright','Cocktail')),());
        mspacman_dip:array [0..4] of def_dip2=(
        (mask:3;name:'Coinage';number:4;val4:(3,1,2,0);name4:('2C 1C','1C 1C','1C 2C','Free Play')),
        (mask:$c;name:'Lives';number:4;val4:(0,4,8,$c);name4:('1','2','3','5')),
        (mask:$30;name:'Bonus Life';number:4;val4:(0,$10,$20,$30);name4:('10K','15K','20K','None')),
        (mask:$40;name:'Difficulty';number:2;val2:($40,0);name2:('Normal','Hard')),());
        crush_dip_a:array [0..4] of def_dip2=(
        (mask:3;name:'Coinage';number:4;val4:(3,1,2,0);name4:('2C 1C','1C 1C','1C 2C','Free Play')),
        (mask:$c;name:'Lives';number:4;val4:(0,4,8,$c);name4:('3','4','5','6')),
        (mask:$10;name:'First Pattern';number:2;val2:($10,0);name2:('Easy','Hard')),
        (mask:$20;name:'Teleport Holes';number:2;val2:($20,0);name2:('Off','On')),());
        crush_dip_b:array [0..1] of def_dip2=(
        (mask:$10;name:'Cabinet';number:2;val2:(0,$10);name2:('Upright','Cocktail')),());
        mspactwin_dip_a:array [0..3] of def_dip2=(
        (mask:3;name:'Coinage';number:4;val4:(3,1,2,0);name4:('2C 1C','1C 1C','1C 2C','Free Play')),
        (mask:$c;name:'Lives';number:4;val4:(0,4,8,$c);name4:('1','2','3','5')),
        (mask:$30;name:'Bonus Life';number:4;val4:(0,$10,$20,$30);name4:('10K','15K','20K','None')),());
        mspactwin_dip_b:array [0..1] of def_dip2=(
        (mask:$10;name:'Jama';number:2;val2:($10,0);name2:('Slow','Fast')),());
        mspactwin_dip_c:array [0..1] of def_dip2=(
        (mask:$80;name:'Skip Screen';number:2;val2:($80,0);name2:('Off','On')),());
        birdiy_dip_a:array [0..4] of def_dip2=(
        (mask:3;name:'Coinage';number:4;val4:(3,1,2,0);name4:('2C 1C','1C 1C','1C 2C','Free Play')),
        (mask:$c;name:'Lives';number:4;val4:(0,4,8,$c);name4:('1','2','3','5')),
        (mask:$10;name:'Cabinet';number:2;val2:(0,$10);name2:('Upright','Cocktail')),
        (mask:$20;name:'Skip Screen';number:2;val2:($20,0);name2:('Off','On')),());
        ponpoko_dip_a:array [0..3] of def_dip2=(
        (mask:3;name:'Bonus Life';number:4;val4:(1,2,3,0);name4:('10K','30K','50K','None')),
        (mask:$30;name:'Lives';number:4;val4:(0,$10,$20,$30);name4:('2','3','4','5')),
        (mask:$40;name:'Cabinet';number:2;val2:($40,0);name2:('Upright','Cocktail')),());
        ponpoko_dip_b:array [0..2] of def_dip2=(
        (mask:$f;name:'Coinage';number:16;val16:(4,$e,$f,2,$d,7,$b,$c,1,6,5,$a,8,9,3,0);name16:('A 3/1 B 3/1','A 3/1 B 1/2','A 3/1 B 1/4','A 2/1 B 2/1','A 2/1 B 1/1','A 2/1 B 1/3','A 2/1 B 1/5','A 2/1 B 1/6','A 1/1 B 1/1','A 1/1 B 4/5','A 1/1 B 2/3','A 1/1 B 1/3','A 1/1 B 1/5','A 1/1 B 1/6','A 1/2 B 1/2','Free Play')),
        (mask:$40;name:'Demo Sounds';number:2;val2:($40,0);name2:('Off','On')),());
        woodpeck_dip_a:array [0..4] of def_dip2=(
        (mask:3;name:'Coinage';number:4;val4:(3,1,2,0);name4:('2C 1C','1C 1C','1C 2C','Free Play')),
        (mask:$c;name:'Lives';number:4;val4:(0,4,8,$c);name4:('1','2','3','5')),
        (mask:$30;name:'Bonus Life';number:4;val4:(0,$10,$20,$30);name4:('5K','10K','15K','None')),
        (mask:$40;name:'Cabinet';number:2;val2:($40,0);name2:('Upright','Cocktail')),());
        eyes_dip_a:array [0..4] of def_dip2=(
        (mask:3;name:'Coinage';number:4;val4:(1,3,2,0);name4:('2C 1C','1C 1C','1C 2C','Free Play')),
        (mask:$c;name:'Lives';number:4;val4:($c,8,4,0);name4:('2','3','4','5')),
        (mask:$30;name:'Bonus Life';number:4;val4:($30,$20,$10,0);name4:('50K','75K','100K','125K')),
        (mask:$40;name:'Cabinet';number:2;val2:($40,0);name2:('Upright','Cocktail')),());
        alibaba_dip_a:array [0..4] of def_dip2=(
        (mask:3;name:'Coinage';number:4;val4:(3,1,2,0);name4:('2C 1C','1C 1C','1C 2C','Free Play')),
        (mask:$c;name:'Lives';number:4;val4:(0,4,8,$c);name4:('1','2','3','5')),
        (mask:$30;name:'Bonus Life';number:4;val4:(0,$10,$20,$30);name4:('10K','15K','20K','None')),
        (mask:$40;name:'Difficulty';number:2;val2:($40,0);name2:('Normal','Hard')),());
        piranha_dip_a:array [0..3] of def_dip2=(
        (mask:3;name:'Coinage';number:4;val4:(0,1,2,3);name4:('2C 1C','1C 1C','1C 2C','Free Play')),
        (mask:$c;name:'Lives';number:4;val4:($c,4,8,0);name4:('1','2','3','5')),
        (mask:$30;name:'Bonus Life';number:4;val4:($30,$10,$20,0);name4:('10K','15K','20K','None')),());

var
 irq_vblank,dec_enable,croller_disable_protection:boolean;
 rom_decode:array[0..$bfff] of byte;
 read_events:procedure;
 read_io:function(direccion:byte):byte;
 write_io:procedure(direccion,valor:byte);
 croller_counter,croller_offset,unk_latch:byte;
 sprite_ram:array[0..1,0..$f] of byte;
 x_hack,y_hack:integer;
 alibaba_mystery:word;
 irq_vector:byte;

procedure update_video_pacman;
var
  color,offs:word;
  nchar,f,sx,sy,atrib,x,y:byte;
  flip_x,flip_y:boolean;
begin
for y:=0 to 27 do begin
  for x:=0 to 35 do begin
     sx:=x-2;
     sy:=y+2;
     if (sx and $20)<>0 then offs:=sy+((sx and $1f) shl 5)
        else offs:=sx+(sy shl 5);
     if gfx[0].buffer[offs] then begin
        color:=((memoria[$4400+offs]) and $1f) shl 2;
        put_gfx(x*8,y*8,memoria[$4000+offs],color,1,0);
        gfx[0].buffer[offs]:=false;
     end;
  end;
end;
actualiza_trozo(0,0,288,224,1,0,0,288,224,2);
for f:=7 downto 0 do begin
        atrib:=sprite_ram[0,f*2];
        nchar:=atrib shr 2;
        color:=(sprite_ram[0,1+(f*2)] and $1f) shl 2;
        if main_screen.flip_main_screen then begin
          x:=sprite_ram[1,1+(f*2)]-32;
          y:=sprite_ram[1,(f*2)];
          flip_y:=(atrib and 1)=0;
          flip_x:=(atrib and 2)=0;
        end else begin
          x:=(270+x_hack)-sprite_ram[1,1+(f*2)];
          y:=sprite_ram[1,f*2]-31;
          flip_x:=(atrib and 1)<>0;
          flip_y:=(atrib and 2)<>0;
        end;
        put_gfx_sprite_mask(nchar,color,flip_x,flip_y,1,0,$f);
        if (f<2) then actualiza_gfx_sprite(x,y+y_hack,2,1)
           else actualiza_gfx_sprite(x,y,2,1)
end;
actualiza_trozo_final(0,0,288,224,2);
end;

procedure eventos_pacman;
begin
if event.arcade then begin
  //in 0
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  //in 1
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or 8);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  if arcade_input.but0[0] then begin
    if (memoria[$180b]<>1) then begin
      memoria[$180b]:=1;
      memoria[$1ffd]:=$bd;
    end
  end else begin
    if (memoria[$180b]<>$be) then begin
      memoria[$180b]:=$be;
      memoria[$1ffd]:=0;
    end
  end;
end;
end;

procedure eventos_mspacman;
begin
if event.arcade then begin
  //in 0
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  //in 1
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or 8);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
end;
end;

procedure eventos_ponpoko;
begin
if event.arcade then begin
  //in 0
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 or 1)else marcade.in0:=(marcade.in0 and $fe);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 or 2) else marcade.in0:=(marcade.in0 and $fd);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 or 4) else marcade.in0:=(marcade.in0 and $fb);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 or 8) else marcade.in0:=(marcade.in0 and $f7);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 or $10) else marcade.in0:=(marcade.in0 and $ef);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  //in 1
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 or 1) else marcade.in1:=(marcade.in1 and $fe);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 or 2) else marcade.in1:=(marcade.in1 and $fd);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 or 4) else marcade.in1:=(marcade.in1 and $fb);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 or 8) else marcade.in1:=(marcade.in1 and $f7);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 or $10) else marcade.in1:=(marcade.in1 and $ef);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 or $20) else marcade.in1:=(marcade.in1 and $df);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 or $40) else marcade.in1:=(marcade.in1 and $bf);
end;
end;

procedure pacman_principal;
var
  f:word;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
  for f:=0 to 263 do begin
    read_events;
    //Si no pinto la pantalla aqui, Ms Pac Man Twin no hace el efecto de la pantalla...
    //Los timings del Z80 estan bien, supongo que es correcto (parece que no hay daños colaterales!)
    case f of
      96:update_video_pacman;
      224:if irq_vblank then z80_0.change_irq_vector(ASSERT_LINE,irq_vector);
    end;
    z80_0.run(frame_main);
    frame_main:=frame_main+z80_0.tframes-z80_0.contador;
  end;
  video_sync;
end;
end;

function pacman_gen_getbyte(direccion:word):byte;
begin
case direccion of
        0..$3fff,$8000..$bfff:pacman_gen_getbyte:=memoria[direccion];
        $4000..$47ff,$6000..$67ff,$c000..$c7ff,$e000..$e7ff:pacman_gen_getbyte:=memoria[(direccion and $7ff)+$4000];
        $4800..$4bff,$6800..$6bff,$c800..$cbff,$e800..$ebff:pacman_gen_getbyte:=$bf;
        $4c00..$4fff,$6c00..$6fff,$cc00..$cfff,$ec00..$efff:pacman_gen_getbyte:=memoria[(direccion and $3ff)+$4c00];
        $5000..$5fff,$7000..$7fff,$d000..$dfff,$f000..$ffff:pacman_gen_getbyte:=read_io(direccion and $ff);
end;
end;

procedure pacman_gen_putbyte(direccion:word;valor:byte);
begin
case direccion of
        0..$3fff,$8000..$bfff:; //ROM
        $4000..$47ff,$6000..$67ff,$c000..$c7ff,$e000..$e7ff:if memoria[(direccion and $7ff)+$4000]<>valor then begin
                        memoria[(direccion and $7ff)+$4000]:=valor;
                        gfx[0].buffer[direccion and $3ff]:=true;
                     end;
        $4c00..$4fff,$6c00..$6fff,$cc00..$cfff,$ec00..$efff:begin
                                                                memoria[(direccion and $3ff)+$4c00]:=valor;
                                                                if (((direccion and $3ff)>$3ef) and ((direccion and $3ff)<=$3ff)) then sprite_ram[0,direccion and $f]:=valor;
                                                            end;
        $5000..$5fff,$7000..$7fff,$d000..$dfff,$f000..$ffff:write_io(direccion and $ff,valor);
end;
end;

function pacman_read_io(direccion:byte):byte;
begin
  case direccion of
    0..$3f:pacman_read_io:=marcade.in0 or marcade.dswb;
    $40..$7f:pacman_read_io:=marcade.in1 or marcade.dswc;
    $80..$bf:pacman_read_io:=marcade.dswa;
    $c0..$ff:pacman_read_io:=0;
  end;
end;

procedure pacman_write_io(direccion,valor:byte);
begin
  case direccion of
    0:begin
        irq_vblank:=valor<>0;
        if not(irq_vblank) then z80_0.change_irq(CLEAR_LINE);
      end;
    1:namco_snd_0.enabled:=valor<>0;
    3:main_screen.flip_main_screen:=(valor and 1)<>0;
    $40..$5f:namco_snd_0.regs[direccion and $1f]:=valor;
    $60..$6f:sprite_ram[1,direccion and $f]:=valor;
  end;
end;

procedure pacman_outbyte(puerto:word;valor:byte);
begin
if (puerto and $ff)=0 then irq_vector:=valor;
end;

procedure pacman_sound_update;
begin
  namco_snd_0.update;
end;

//MS Pacman
function mspacman_getbyte(direccion:word):byte;
begin
case direccion of
        $38..$3f,$3b0..$3b7,$1600..$1607,$2120..$2127,$3ff0..$3ff7,$8000..$8007,$97f0..$97f7:dec_enable:=false;
        $3ff8..$3fff:dec_enable:=true;
end;
case direccion of
        0..$3fff,$8000..$bfff:if dec_enable then mspacman_getbyte:=rom_decode[direccion]
                                  else mspacman_getbyte:=memoria[direccion and $3fff];
        else mspacman_getbyte:=pacman_gen_getbyte(direccion);
end;
end;

procedure mspacman_putbyte(direccion:word;valor:byte);
begin
case direccion of
        $38..$3f,$3b0..$3b7,$1600..$1607,$2120..$2127,$3ff0..$3ff7,$8000..$8007,$97f0..$97f7:dec_enable:=false;
        $3ff8..$3fff:dec_enable:=true;
        else pacman_gen_putbyte(direccion,valor);
end;
end;

//Crush Roller
function crush_read_io(direccion:byte):byte;
const
  protdata_odd:array[0..$1d] of byte=( // table at $ebd (odd entries)
		$00, $c0, $00, $40, $c0, $40, $00, $c0, $00, $40, $00, $c0, $00, $40, $c0, $40,
		$00, $c0, $00, $40, $00, $c0, $00, $40, $c0, $40, $00, $c0, $00, $40);
  protdata_even:array[0..$1d] of byte=( // table at $ebd (even entries)
		$1f, $3f, $2f, $2f, $0f, $0f, $0f, $3f, $0f, $0f, $1c, $3c, $2c, $2c, $0c, $0c,
		$0c, $3c, $0c, $0c, $11, $31, $21, $21, $01, $01, $01, $31, $01, $01);
var
  tempb:byte;
begin
  case direccion of
      0..$3f:crush_read_io:=marcade.in0 or marcade.dswb;
      $40..$7f:crush_read_io:=marcade.in1;
      $80..$bf:begin //proteccion 1
                  tempb:=marcade.dswa and $3f;
                  if not(croller_disable_protection) then begin
                      crush_read_io:=protdata_odd[croller_offset] or tempb;
                      exit;
                  end;
                  case (direccion and $3f) of
                    1,4:crush_read_io:=tempb or $40;
                    5,$e,$10:crush_read_io:=tempb or $c0;
                    else crush_read_io:=tempb;
                  end;
               end;
      $c0..$cf:begin //proteccion 2
                  if not(croller_disable_protection) then begin
                    crush_read_io:=protdata_even[croller_offset];
                    exit;
                  end;
                  case (direccion and $f) of
                    0:crush_read_io:=$1f;
                    9:crush_read_io:=$30;
                    $c:crush_read_io:=0;
                    else crush_read_io:=$20;
                  end;
               end;
      $d0..$ff:crush_read_io:=0;
end;
end;

procedure crush_write_io(direccion,valor:byte);
begin
case direccion of
    0:begin
        irq_vblank:=valor<>0;
        if not(irq_vblank) then z80_0.change_irq(CLEAR_LINE);
      end;
    1:namco_snd_0.enabled:=valor<>0;
    3:main_screen.flip_main_screen:=(valor and 1)<>0;
    4:case valor of //proteccion
        0:begin // disable protection / reset?
            croller_counter:=0;
            croller_offset:=0;
            croller_disable_protection:=true;
          end;
        1:begin
            croller_disable_protection:=false;
            croller_counter:=croller_counter+1;
            if (croller_counter=$3c) then begin
              croller_counter:=0;
              croller_offset:=croller_offset+1;
              if (croller_offset=$1e) then croller_offset:=0;
            end;
          end;
      end;
    $40..$5f:namco_snd_0.regs[direccion and $1f]:=valor;
    $60..$6f:sprite_ram[1,direccion and $f]:=valor;
end;
end;

//Ms Pac Man Twin
function mspactwin_getbyte(direccion:word):byte;
begin
case direccion of
        0..$3fff,$8000..$bfff:if z80_0.opcode then mspactwin_getbyte:=rom_decode[direccion]
                                  else mspactwin_getbyte:=memoria[direccion];
        $6000..$67ff:if z80_0.opcode then mspactwin_getbyte:=rom_decode[(direccion and $1fff)+$2000]
                                  else mspactwin_getbyte:=memoria[(direccion and $1fff)+$2000];
        $4000..$47ff,$c000..$c7ff:mspactwin_getbyte:=memoria[(direccion and $7ff)+$4000];
        $4800..$4bff,$6800..$6bff,$c800..$cbff:mspactwin_getbyte:=0;
        $4c00..$4fff,$6c00..$6fff,$cc00..$cfff,$ec00..$efff:mspactwin_getbyte:=memoria[(direccion and $3ff)+$4c00];
        $5000..$5fff,$7000..$7fff,$d000..$dfff,$f000..$ffff:case (direccion and $ff) of
                                    0..$3f:mspactwin_getbyte:=marcade.in0 or marcade.dswb;
                                    $40..$7f:mspactwin_getbyte:=marcade.in1 or marcade.dswc;
                                    $80..$bf:mspactwin_getbyte:=marcade.dswa;
                                    $c0..$ff:mspactwin_getbyte:=unk_latch;
                                  end;
end;
end;

procedure mspactwin_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$3fff,$6000..$67ff,$8000..$bfff:;
  $4000..$47ff,$c000..$c7ff:if memoria[(direccion and $7ff)+$4000]<>valor then begin
                                  memoria[(direccion and $7ff)+$4000]:=valor;
                                  gfx[0].buffer[direccion and $3ff]:=true;
                            end;
  $4c00..$4fff,$6c00..$6fff,$cc00..$cfff,$ec00..$efff:begin
                                                          memoria[(direccion and $3ff)+$4c00]:=valor;
                                                          if (((direccion and $3ff)>$3ef) and ((direccion and $3ff)<=$3ff)) then sprite_ram[0,direccion and $f]:=valor;
                                                      end;
  $5000..$5fff,$7000..$7fff,$d000..$dfff,$f000..$ffff:case (direccion and $ff) of
                              0:begin
                                  irq_vblank:=valor<>0;
                                  if not(irq_vblank) then z80_0.change_irq(CLEAR_LINE);
                                end;
                              1:namco_snd_0.enabled:=valor<>0;
                              3:main_screen.flip_main_screen:=(valor and 1)<>0;
                              $40..$5f:namco_snd_0.regs[direccion and $1f]:=valor;
                              $60..$6f:sprite_ram[1,direccion and $f]:=valor;
                              $80..$bf:unk_latch:=valor;
                              $c0..$ff:; //WD
                            end;
end;
end;

//Birdiy
function birdiy_read_io(direccion:byte):byte;
begin
  case direccion of
    0..$3f:birdiy_read_io:=marcade.in0;
    $40..$7f:birdiy_read_io:=marcade.in1;
    $80..$bf:birdiy_read_io:=marcade.dswa;
    $c0..$ff:birdiy_read_io:=marcade.dswb;
end;
end;

procedure birdiy_write_io(direccion,valor:byte);
begin
case direccion of
  1:begin
      irq_vblank:=valor<>0;
      if not(irq_vblank) then z80_0.change_irq(CLEAR_LINE);
    end;
  $80..$9f:namco_snd_0.regs[direccion and $1f]:=valor;
  $a0..$af:sprite_ram[1,direccion and $f]:=valor;
end;
end;

//Alibaba
function alibaba_getbyte(direccion:word):byte;
begin
case direccion of
        0..$3fff,$8000..$8fff:alibaba_getbyte:=memoria[direccion];
        $4000..$47ff,$6000..$67ff,$c000..$c7ff:alibaba_getbyte:=memoria[(direccion and $7ff)+$4000];
        $4800..$4bff,$6800..$6bff,$c800..$cbff:alibaba_getbyte:=$bf;
        $4c00..$4fff,$6c00..$6fff,$cc00..$cfff,$ec00..$efff:alibaba_getbyte:=memoria[(direccion and $3ff)+$4c00];
        $5000..$5fff,$7000..$7fff,$d000..$dfff,$f000..$ffff:case (direccion and $ff) of
                                    0..$3f:alibaba_getbyte:=marcade.in0 or marcade.dswb;
                                    $40..$7f:alibaba_getbyte:=marcade.in1 or marcade.dswc;
                                    $80..$bf:alibaba_getbyte:=marcade.dswa;
                                    $c0:alibaba_getbyte:=random(16);
                                    $c1:begin
                                          alibaba_mystery:=alibaba_mystery+1;
                                          alibaba_getbyte:=(alibaba_mystery shr 10) and 1;
                                        end;
                                    $c2..$ff:alibaba_getbyte:=$bf;
                                  end;
        $9000..$9fff:alibaba_getbyte:=memoria[(direccion and $3ff)+$9000];
        $a000..$bfff:alibaba_getbyte:=memoria[(direccion and $7ff)+$a000];
end;
end;

procedure alibaba_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$3fff,$8000..$8fff,$a000..$bfff:;
  $4000..$47ff,$6000..$67ff,$c000..$c7ff:if memoria[(direccion and $7ff)+$4000]<>valor then begin
                                  memoria[(direccion and $7ff)+$4000]:=valor;
                                  gfx[0].buffer[direccion and $3ff]:=true;
                            end;
  $4c00..$4fff,$6c00..$6fff,$cc00..$cfff,$ec00..$efff:begin
                                                          memoria[(direccion and $3ff)+$4c00]:=valor;
                                                          if (((direccion and $3ff)>$2ef) and ((direccion and $3ff)<$2ff)) then sprite_ram[0,direccion and $f]:=valor;
                                                      end;
  $5000..$5fff,$7000..$7fff,$d000..$dfff,$f000..$ffff:case (direccion and $ff) of
                              $40..$4f:namco_snd_0.regs[direccion and $f]:=valor;
                              $50..$5f:sprite_ram[1,direccion and $f]:=valor;
                              $60..$6f:namco_snd_0.regs[(direccion and $f) or $10]:=valor;
                              $c0:namco_snd_0.enabled:=valor<>0;
                              $c1:main_screen.flip_main_screen:=(valor and 1)<>0;
                              $c2:begin
                                  irq_vblank:=valor<>0;
                                  if not(irq_vblank) then z80_0.change_irq(CLEAR_LINE);
                                end;

                            end;
  $9000..$9fff:memoria[(direccion and $3ff)+$9000]:=valor;
end;
end;

//Piranha
procedure piranha_outbyte(puerto:word;valor:byte);
begin
if (puerto and $ff)=0 then begin
  if valor=$fa then irq_vector:=$78
    else irq_vector:=valor;
end;
end;

procedure pacman_qsave(nombre:string);
var
  data:pbyte;
  size:word;
  buffer:array[0..5] of byte;
begin
case main_vars.tipo_maquina of
  10:open_qsnapshot_save('pacman'+nombre);
  88:open_qsnapshot_save('mspacman'+nombre);
  234:open_qsnapshot_save('crushroller'+nombre);
  305:open_qsnapshot_save('mspactwin'+nombre);
  353:open_qsnapshot_save('birdiy'+nombre);
  401:open_qsnapshot_save('ponpoko'+nombre);
  402:open_qsnapshot_save('woodpeck'+nombre);
  403:open_qsnapshot_save('eyes'+nombre);
  404:open_qsnapshot_save('alibaba'+nombre);
  405:open_qsnapshot_save('piranha'+nombre);
end;
getmem(data,2000);
//CPU
size:=z80_0.save_snapshot(data);
savedata_qsnapshot(data,size);
//SND
size:=namco_snd_0.save_snapshot(data);
savedata_qsnapshot(data,size);
//MEM
savedata_qsnapshot(@sprite_ram[0],$10);
savedata_qsnapshot(@memoria[$4000],$4000);
if main_vars.tipo_maquina=88 then savedata_qsnapshot(@memoria[$c000],$4000);
//MISC
buffer[0]:=byte(irq_vblank);
buffer[1]:=byte(dec_enable);
buffer[2]:=croller_counter;
buffer[3]:=croller_offset;
buffer[4]:=byte(croller_disable_protection);
buffer[5]:=unk_latch;
savedata_qsnapshot(@buffer,6);
freemem(data);
close_qsnapshot;
end;

procedure pacman_qload(nombre:string);
var
  data:pbyte;
  buffer:array[0..5] of byte;
begin
case main_vars.tipo_maquina of
  10:if not(open_qsnapshot_load('pacman'+nombre)) then exit;
  88:if not(open_qsnapshot_load('mspacman'+nombre)) then exit;
  234:if not(open_qsnapshot_load('crushroller'+nombre)) then exit;
  305:if not(open_qsnapshot_load('mspactwin'+nombre)) then exit;
  353:if not(open_qsnapshot_load('birdiy'+nombre)) then exit;
  401:if not(open_qsnapshot_load('ponpoko'+nombre)) then exit;
  402:if not(open_qsnapshot_load('woodpeck'+nombre)) then exit;
  403:if not(open_qsnapshot_load('eyes'+nombre)) then exit;
  404:if not(open_qsnapshot_load('alibaba'+nombre)) then exit;
  405:if not(open_qsnapshot_load('piranha'+nombre)) then exit;
end;
getmem(data,2000);
//CPU
loaddata_qsnapshot(data);
z80_0.load_snapshot(data);
//SND
loaddata_qsnapshot(data);
namco_snd_0.load_snapshot(data);
//MEM
loaddata_qsnapshot(@sprite_ram[0]);
loaddata_qsnapshot(@memoria[$4000]);
if main_vars.tipo_maquina=88 then loaddata_qsnapshot(@memoria[$c000]);
//MISC
loaddata_qsnapshot(@buffer);
irq_vblank:=buffer[0]<>0;
dec_enable:=buffer[1]<>0;
croller_counter:=buffer[2];
croller_offset:=buffer[3];
croller_disable_protection:=buffer[4]<>0;
unk_latch:=buffer[5];
freemem(data);
close_qsnapshot;
fillchar(gfx[0].buffer,$400,1);
end;

//Main
procedure reset_pacman;
begin
 z80_0.reset;
 frame_main:=z80_0.tframes;
 namco_snd_0.reset;
 irq_vblank:=false;
 irq_vector:=$ff;
 dec_enable:=false;
 marcade.in0:=$ef;
 marcade.in1:=$7f;
 case main_vars.tipo_maquina of
  234:marcade.in1:=$6f;
  401:begin
        marcade.in0:=$e0;
        marcade.in1:=0;
      end;
  353,402,405:begin
        marcade.in0:=$ff;
        marcade.in1:=$ff;
       end;
 end;
 croller_counter:=0;
 croller_offset:=0;
 croller_disable_protection:=false;
 unk_latch:=0;
 alibaba_mystery:=0;
end;

procedure mspacman_install_patches;
var
  i:byte;
begin
	// copy forty 8-byte patches into Pac-Man code
	for i:=0 to 7 do begin
		rom_decode[$410+i]:=rom_decode[$8008+i];
		rom_decode[$8e0+i]:=rom_decode[$81d8+i];
		rom_decode[$a30+i]:=rom_decode[$8118+i];
		rom_decode[$bd0+i]:=rom_decode[$80d8+i];
		rom_decode[$c20+i]:=rom_decode[$8120+i];
		rom_decode[$e58+i]:=rom_decode[$8168+i];
		rom_decode[$ea8+i]:=rom_decode[$8198+i];
		rom_decode[$1000+i]:=rom_decode[$8020+i];
		rom_decode[$1008+i]:=rom_decode[$8010+i];
		rom_decode[$1288+i]:=rom_decode[$8098+i];
		rom_decode[$1348+i]:=rom_decode[$8048+i];
		rom_decode[$1688+i]:=rom_decode[$8088+i];
		rom_decode[$16b0+i]:=rom_decode[$8188+i];
		rom_decode[$16d8+i]:=rom_decode[$80c8+i];
		rom_decode[$16f8+i]:=rom_decode[$81c8+i];
		rom_decode[$19a8+i]:=rom_decode[$80a8+i];
		rom_decode[$19b8+i]:=rom_decode[$81a8+i];
		rom_decode[$2060+i]:=rom_decode[$8148+i];
		rom_decode[$2108+i]:=rom_decode[$8018+i];
		rom_decode[$21a0+i]:=rom_decode[$81a0+i];
		rom_decode[$2298+i]:=rom_decode[$80a0+i];
		rom_decode[$23e0+i]:=rom_decode[$80e8+i];
		rom_decode[$2418+i]:=rom_decode[$8000+i];
		rom_decode[$2448+i]:=rom_decode[$8058+i];
		rom_decode[$2470+i]:=rom_decode[$8140+i];
		rom_decode[$2488+i]:=rom_decode[$8080+i];
		rom_decode[$24b0+i]:=rom_decode[$8180+i];
		rom_decode[$24d8+i]:=rom_decode[$80c0+i];
		rom_decode[$24f8+i]:=rom_decode[$81c0+i];
		rom_decode[$2748+i]:=rom_decode[$8050+i];
		rom_decode[$2780+i]:=rom_decode[$8090+i];
		rom_decode[$27b8+i]:=rom_decode[$8190+i];
		rom_decode[$2800+i]:=rom_decode[$8028+i];
		rom_decode[$2b20+i]:=rom_decode[$8100+i];
		rom_decode[$2b30+i]:=rom_decode[$8110+i];
		rom_decode[$2bf0+i]:=rom_decode[$81d0+i];
		rom_decode[$2cc0+i]:=rom_decode[$80d0+i];
		rom_decode[$2cd8+i]:=rom_decode[$80e0+i];
		rom_decode[$2cf0+i]:=rom_decode[$81e0+i];
		rom_decode[$2d60+i]:=rom_decode[$8160+i];
	end;
end;

function iniciar_pacman:boolean;
var
  colores:tpaleta;
  f:word;
  j,bit0,bit1,bit2:byte;
  memoria_temp:array[0..$7fff] of byte;
  buffer:array[0..7] of byte;
  rweights,gweights,bweights:array[0..2] of single;
const
  ps_x:array[0..15] of dword=(8*8, 8*8+1, 8*8+2, 8*8+3, 16*8+0, 16*8+1, 16*8+2, 16*8+3,
			24*8+0, 24*8+1, 24*8+2, 24*8+3, 0, 1, 2, 3);
  ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			32*8, 33*8, 34*8, 35*8, 36*8, 37*8, 38*8, 39*8);
  pc_x:array[0..7] of dword=(8*8+0, 8*8+1, 8*8+2, 8*8+3, 0, 1, 2, 3);
  resistances:array[0..2] of integer=(1000,470,220);
procedure conv_chars;
begin
  init_gfx(0,8,8,256);
  gfx_set_desc_data(2,0,16*8,0,4);
  convert_gfx(0,0,@memoria_temp,@pc_x,@ps_y,false,false);
end;
procedure conv_sprites;
begin
  init_gfx(1,16,16,64);
  gfx_set_desc_data(2,0,64*8,0,4);
  convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,false);
end;
procedure decode_eyes;
var
  f:word;
  j:byte;
begin
for f:=0 to $1ff do begin
  for j:=0 to 7 do buffer[j]:=memoria_temp[BITSWAP16((f*8)+j,15,14,13,12,11,10,9,8,7,6,5,4,3,0,1,2)];
  for j:=0 to 7 do memoria_temp[(f*8)+j]:=BITSWAP8(buffer[j],7,4,5,6,3,2,1,0);
end;
end;
begin
llamadas_maquina.bucle_general:=pacman_principal;
llamadas_maquina.reset:=reset_pacman;
llamadas_maquina.fps_max:=60.6060606060;
llamadas_maquina.save_qsnap:=pacman_qsave;
llamadas_maquina.load_qsnap:=pacman_qload;
iniciar_pacman:=false;
iniciar_audio(false);
screen_init(1,288,244);
if (main_vars.tipo_maquina<>401) then main_screen.rot90_screen:=true;
screen_init(2,512,256,false,true);
iniciar_video(288,224);
//Main CPU
z80_0:=cpu_z80.create(3072000,264);
z80_0.change_ram_calls(pacman_gen_getbyte,pacman_gen_putbyte);
z80_0.change_io_calls(nil,pacman_outbyte);
z80_0.init_sound(pacman_sound_update);
namco_snd_0:=namco_snd_chip.create(3);
x_hack:=2;
y_hack:=-1;
case main_vars.tipo_maquina of
  10:begin  //Pacman
        read_io:=pacman_read_io;
        write_io:=pacman_write_io;
        //cargar roms
        if not(roms_load(@memoria,pacman_rom)) then exit;
        //cargar sonido
        if not(roms_load(namco_snd_0.get_wave_dir,pacman_sound)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,pacman_char)) then exit;
        conv_chars;
        //convertir sprites
        if not(roms_load(@memoria_temp,pacman_sprites)) then exit;
        conv_sprites;
        //poner la paleta
        if not(roms_load(@memoria_temp,pacman_pal)) then exit;
        //DIP
        read_events:=eventos_pacman;
        marcade.dswa:=$c9;
        marcade.dswb:=$10;
        marcade.dswc:=$80;
        marcade.dswa_val2:=@pacman_dip_a;
        marcade.dswb_val2:=@pacman_dip_b;
        marcade.dswc_val2:=@pacman_dip_c;
     end;
     88:begin  //MS Pacman
        z80_0.change_ram_calls(mspacman_getbyte,mspacman_putbyte);
        read_io:=pacman_read_io;
        write_io:=pacman_write_io;
        //cargar y desencriptar roms
        if not(roms_load(@memoria,mspacman_rom)) then exit;
        copymemory(@rom_decode,@memoria,$1000);
        copymemory(@rom_decode[$1000],@memoria[$1000],$1000);
        copymemory(@rom_decode[$2000],@memoria[$2000],$1000);
        for f:=0 to $fff do
      	      rom_decode[$3000+f]:=BITSWAP8(memoria[$b000+BITSWAP16(f,15,14,13,12,11,3,7,9,10,8,6,5,4,2,1,0)],0,4,5,7,6,3,2,1);	// decrypt u7
	      for f:=0 to $7ff do begin
		      rom_decode[$8000+f]:=BITSWAP8(memoria[$8000+BITSWAP16(f,15,14,13,12,11,8,7,5,9,10,6,3,4,2,1,0)],0,4,5,7,6,3,2,1);	// decrypt u5
		      rom_decode[$8800+f]:=BITSWAP8(memoria[$9800+BITSWAP16(f,15,14,13,12,11,3,7,9,10,8,6,5,4,2,1,0)],0,4,5,7,6,3,2,1);	// decrypt half of u6
		      rom_decode[$9000+f]:=BITSWAP8(memoria[$9000+BITSWAP16(f,15,14,13,12,11,3,7,9,10,8,6,5,4,2,1,0)],0,4,5,7,6,3,2,1);	// decrypt half of u6
	      end;
        copymemory(@rom_decode[$9800],@memoria[$1800],$800);
        copymemory(@rom_decode[$a000],@memoria[$2000],$1000);
        copymemory(@rom_decode[$b000],@memoria[$3000],$1000);
        mspacman_install_patches;
        //cargar sonido
        if not(roms_load(namco_snd_0.get_wave_dir,pacman_sound)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,mspacman_char)) then exit;
        conv_chars;
        //convertir sprites
        if not(roms_load(@memoria_temp,mspacman_sprites)) then exit;
        conv_sprites;
        //poner la paleta
        if not(roms_load(@memoria_temp,pacman_pal)) then exit;
        //DIP
        read_events:=eventos_mspacman;
        marcade.dswa:=$c9;
        marcade.dswb:=$10;
        marcade.dswc:=$80;
        marcade.dswa_val2:=@mspacman_dip;
        marcade.dswb_val2:=@pacman_dip_b;
        marcade.dswc_val2:=@pacman_dip_c;
     end;
     234:begin  //Crush Roller
        read_io:=crush_read_io;
        write_io:=crush_write_io;
        //cargar roms
        if not(roms_load(@memoria,crush_rom)) then exit;
        //cargar sonido
        if not(roms_load(namco_snd_0.get_wave_dir,pacman_sound)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,crush_char)) then exit;
        conv_chars;
        //convertir sprites
        if not(roms_load(@memoria_temp,crush_sprites)) then exit;
        conv_sprites;
        //poner la paleta
        if not(roms_load(@memoria_temp,crush_pal)) then exit;
        //DIP
        read_events:=eventos_mspacman;
        marcade.dswa:=$31;
        marcade.dswb:=0;
        marcade.dswa_val2:=@crush_dip_a;
        marcade.dswb_val2:=@crush_dip_b;
     end;
     305:begin  //MS Pacman Twin
        z80_0.change_ram_calls(mspactwin_getbyte,mspactwin_putbyte);
        //cargar y desencriptar roms
        if not(roms_load(@memoria_temp,mspactwin_rom)) then exit;
        copymemory(@memoria,@memoria_temp,$4000);
        copymemory(@memoria[$8000],@memoria_temp[$4000],$4000);
	      for f:=0 to $1fff do begin
          // decode opcode
		      rom_decode[f*2]:=BITSWAP8(memoria[f*2],4,5,6,7,0,1,2,3);
		      rom_decode[(f*2)+1]:=BITSWAP8(memoria[(f*2)+1] xor $9a,6,4,5,7,2,0,3,1);
		      rom_decode[$8000+(f*2)]:=BITSWAP8(memoria[$8000+(f*2)],4,5,6,7,0,1,2,3);
		      rom_decode[$8001+(f*2)]:=BITSWAP8(memoria[$8001+(f*2)] xor $9a,6,4,5,7,2,0,3,1);
      		// decode operand
	      	memoria[f*2]:=BITSWAP8(memoria[f*2],0,1,2,3,4,5,6,7);
		      memoria[(f*2)+1]:=BITSWAP8(memoria[(f*2)+1] xor $a3,2,4,6,3,7,0,5,1);
		      memoria[$8000+(f*2)]:=BITSWAP8(memoria[$8000+(f*2)],0,1,2,3,4,5,6,7);
		      memoria[$8001+(f*2)]:=BITSWAP8(memoria[$8001+(f*2)] xor $a3,2,4,6,3,7,0,5,1);
	      end;
        //cargar sonido
        if not(roms_load(namco_snd_0.get_wave_dir,pacman_sound)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,mspactwin_char)) then exit;
        conv_chars;
        //convertir sprites
        if not(roms_load(@memoria_temp,mspactwin_sprites)) then exit;
        conv_sprites;
        //poner la paleta
        if not(roms_load(@memoria_temp,mspactwin_pal)) then exit;
        //DIP
        read_events:=eventos_mspacman;
        marcade.dswa:=$c9;
        marcade.dswa_val2:=@mspactwin_dip_a;
        marcade.dswb:=$10;
        marcade.dswb_val2:=@mspactwin_dip_b;
        marcade.dswc:=$80;
        marcade.dswc_val2:=@mspactwin_dip_c;
     end;
     353:begin  //Birdiy
        read_io:=birdiy_read_io;
        write_io:=birdiy_write_io;
        if not(roms_load(@memoria,birdiy_rom)) then exit;
        if not(roms_load(namco_snd_0.get_wave_dir,pacman_sound)) then exit;
        if not(roms_load(@memoria_temp,birdiy_char)) then exit;
        conv_chars;
        if not(roms_load(@memoria_temp,birdiy_sprites)) then exit;
        conv_sprites;
        if not(roms_load(@memoria_temp,birdiy_pal)) then exit;
        read_events:=eventos_mspacman;
        y_hack:=0;
        marcade.dswa:=$e9;
        marcade.dswa_val2:=@birdiy_dip_a;
        marcade.dswb:=$ff;
     end;
     401:begin  //Ponpoko
        read_io:=birdiy_read_io;
        write_io:=pacman_write_io;
        if not(roms_load(@memoria,ponpoko_rom)) then exit;
        if not(roms_load(namco_snd_0.get_wave_dir,pacman_sound)) then exit;
        if not(roms_load(@memoria_temp,ponpoko_char)) then exit;
        for f:=0 to $ff do begin
		      for j:=0 to 7 do begin
			        bit0:=memoria_temp[(f*$10)+j+8];
			        memoria_temp[(f*$10)+j+8]:=memoria_temp[(f*$10)+j];
			        memoria_temp[(f*$10)+j]:=bit0;
          end;
		    end;
        conv_chars;
        if not(roms_load(@memoria_temp,ponpoko_sprites)) then exit;
        for f:=0 to $7f do begin
		      for j:=0 to 7 do begin
			      bit0:=memoria_temp[(f*$20)+j+$18];
			      memoria_temp[(f*$20)+j+$18]:=memoria_temp[(f*$20)+j+$10];
			      memoria_temp[(f*$20)+j+$10]:=memoria_temp[(f*$20)+j+$8];
			      memoria_temp[(f*$20)+j+$8]:=memoria_temp[(f*$20)+j];
			      memoria_temp[(f*$20)+j]:=bit0;
          end;
        end;
        conv_sprites;
        if not(roms_load(@memoria_temp,ponpoko_pal)) then exit;
        read_events:=eventos_ponpoko;
        x_hack:=0;
        y_hack:=+1;
        marcade.dswa:=$e1;
        marcade.dswa_val2:=@ponpoko_dip_a;
        marcade.dswb:=$b1;
        marcade.dswb_val2:=@ponpoko_dip_b;
     end;
     402:begin  //Woodpecker
        read_io:=birdiy_read_io;
        write_io:=pacman_write_io;
        if not(roms_load(@memoria,woodpeck_rom)) then exit;
        if not(roms_load(namco_snd_0.get_wave_dir,pacman_sound)) then exit;
        if not(roms_load(@memoria_temp,woodpeck_char)) then exit;
        decode_eyes;
        conv_chars;
        if not(roms_load(@memoria_temp,woodpeck_sprites)) then exit;
        decode_eyes;
        conv_sprites;
        if not(roms_load(@memoria_temp,woodpeck_pal)) then exit;
        read_events:=eventos_mspacman;
        marcade.dswa:=$c9;
        marcade.dswa_val2:=@woodpeck_dip_a;
        marcade.dswb:=0;
     end;
     403:begin  //Eyes
        read_io:=pacman_read_io;
        write_io:=pacman_write_io;
        if not(roms_load(@memoria,eyes_rom)) then exit;
        for f:=0 to $bfff do memoria[f]:=BITSWAP8(memoria[f],7,6,3,4,5,2,1,0);
        if not(roms_load(namco_snd_0.get_wave_dir,pacman_sound)) then exit;
        if not(roms_load(@memoria_temp,eyes_char)) then exit;
        decode_eyes;
        conv_chars;
        if not(roms_load(@memoria_temp,eyes_sprites)) then exit;
        decode_eyes;
        conv_sprites;
        if not(roms_load(@memoria_temp,eyes_pal)) then exit;
        read_events:=eventos_mspacman;
        marcade.dswa:=$fb;
        marcade.dswb:=$10;
        marcade.dswc:=$80;
        marcade.dswa_val2:=@eyes_dip_a;
        marcade.dswb_val2:=@pacman_dip_b;
        marcade.dswc_val2:=@pacman_dip_c;
     end;
     404:begin  //Alibaba
        z80_0.change_ram_calls(alibaba_getbyte,alibaba_putbyte);
        if not(roms_load(@memoria,alibaba_rom)) then exit;
        if not(roms_load(namco_snd_0.get_wave_dir,pacman_sound)) then exit;
        if not(roms_load(@memoria_temp,alibaba_char)) then exit;
        conv_chars;
        if not(roms_load(@memoria_temp,alibaba_sprites)) then exit;
        conv_sprites;
        if not(roms_load(@memoria_temp,alibaba_pal)) then exit;
        read_events:=eventos_pacman;
        marcade.dswa:=$c9;
        marcade.dswb:=$10;
        marcade.dswc:=$80;
        marcade.dswa_val2:=@alibaba_dip_a;
        marcade.dswb_val2:=@pacman_dip_b;
        marcade.dswc_val2:=@pacman_dip_c;
     end;
     405:begin  //Piranha
        read_io:=birdiy_read_io;
        write_io:=pacman_write_io;
        z80_0.change_io_calls(nil,piranha_outbyte);
        if not(roms_load(@memoria,piranha_rom)) then exit;
        for f:=0 to $bfff do memoria[f]:=BITSWAP8(memoria[f],7,6,3,4,5,2,1,0);
        if not(roms_load(namco_snd_0.get_wave_dir,pacman_sound)) then exit;
        if not(roms_load(@memoria_temp,piranha_char)) then exit;
        decode_eyes;
        conv_chars;
        if not(roms_load(@memoria_temp,piranha_sprites)) then exit;
        decode_eyes;
        conv_sprites;
        if not(roms_load(@memoria_temp,piranha_pal)) then exit;
        read_events:=eventos_mspacman;
        marcade.dswa:=$c9;
        marcade.dswb:=$10;
        marcade.dswc:=$80;
        marcade.dswa_val2:=@piranha_dip_a;
        marcade.dswb_val2:=@pacman_dip_b;
        marcade.dswc_val2:=@pacman_dip_c;
     end;
end;
compute_resistor_weights(0,	255, -1.0,
			3,@resistances,@rweights,0,0,
			3,@resistances,@gweights,0,0,
			2,@resistances[1],@bweights,0,0);
for f:=0 to $1f do begin
		// red component
		bit0:=(memoria_temp[f] shr 0) and 1;
		bit1:=(memoria_temp[f] shr 1) and 1;
		bit2:=(memoria_temp[f] shr 2) and 1;
		colores[f].r:=combine_3_weights(@rweights,bit0,bit1,bit2);
		// green component
		bit0:=(memoria_temp[f] shr 3) and 1;
		bit1:=(memoria_temp[f] shr 4) and 1;
		bit2:=(memoria_temp[f] shr 5) and 1;
		colores[f].g:=combine_3_weights(@gweights,bit0,bit1,bit2);
		// blue component
		bit0:=(memoria_temp[f] shr 6) and 1;
		bit1:=(memoria_temp[f] shr 7) and 1;
		colores[f].b:=combine_2_weights(@bweights,bit0,bit1);
end;
set_pal(colores,$20);
for f:=0 to 255 do begin
  gfx[0].colores[f]:=memoria_temp[$20+f] and $f;
  gfx[1].colores[f]:=memoria_temp[$20+f] and $f;
end;
//final
iniciar_pacman:=true;
end;

end.
