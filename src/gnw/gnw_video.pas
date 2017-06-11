unit gnw_video;

interface

uses
  Windows,Messages,ImageList,ImgList,Controls,Graphics,Classes,ExtCtrls,forms;

type
  Tgnw_video_form = class(TForm)
    dkong_jr_images: TImageList;
    dkong_jr_back: TImage;
    Image2: TImage;
    dkong2_back: TImage;
    dkong2_images: TImageList;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  video_def=record
      id:byte;
      pos_x,pos_y:word;
      size_x,size_y:word;
  end;

var
  gnw_video_form: Tgnw_video_form;

const
  gnw_dkongjr_video:array[0..3,0..15,0..3] of video_def=(
         //0
         (((id:0;pos_x:386;pos_y:138;size_x:26;size_y:29),(),(id:1;pos_x:384;pos_y:169;size_x:31;size_y:27),()), //00X
         ((id:2;pos_x:323;pos_y:138;size_x:30;size_y:25),(),(id:3;pos_x:327;pos_y:185;size_x:33;size_y:31),(id:44;pos_x:340;pos_y:221;size_x:51;size_y:47)), //01X
         ((id:4;pos_x:267;pos_y:145;size_x:30;size_y:22),(),(id:5;pos_x:271;pos_y:191;size_x:32;size_y:27),(id:6;pos_x:270;pos_y:242;size_x:32;size_y:26)), //02X
         ((id:7;pos_x:214;pos_y:167;size_x:23;size_y:33),(id:8;pos_x:210;pos_y:244;size_x:32;size_y:25),(id:9;pos_x:208;pos_y:193;size_x:33;size_y:28),(id:10;pos_x:211;pos_y:214;size_x:26;size_y:31)), //03X
         ((id:11;pos_x:148;pos_y:144;size_x:29;size_y:20),(),(id:12;pos_x:149;pos_y:190;size_x:33;size_y:30),(id:13;pos_x:151;pos_y:248;size_x:33;size_y:21)), //04X
         ((),(),(id:14;pos_x:90;pos_y:186;size_x:31;size_y:27),(id:15;pos_x:87;pos_y:240;size_x:33;size_y:28)), //05X
         ((id:16;pos_x:26;pos_y:127;size_x:69;size_y:62),(id:17;pos_x:36;pos_y:94;size_x:19;size_y:34),(id:18;pos_x:29;pos_y:188;size_x:32;size_y:25),(id:19;pos_x:29;pos_y:245;size_x:34;size_y:24)), //06X
         ((id:20;pos_x:7;pos_y:48;size_x:39;size_y:41),(id:21;pos_x:3;pos_y:119;size_x:17;size_y:30),(id:22;pos_x:7;pos_y:4;size_x:38;size_y:44),(id:23;pos_x:31;pos_y:30;size_x:32;size_y:22)), //07X
         ((),(id:24;pos_x:76;pos_y:76;size_x:60;size_y:64),(id:25;pos_x:96;pos_y:26;size_x:34;size_y:52),(id:26;pos_x:82;pos_y:4;size_x:29;size_y:55)), //08X
         ((id:27;pos_x:219;pos_y:93;size_x:17;size_y:44),(id:28;pos_x:174;pos_y:72;size_x:56;size_y:41),(id:29;pos_x:148;pos_y:15;size_x:21;size_y:52),()), //09X
         ((),(id:30;pos_x:220;pos_y:61;size_x:21;size_y:25),(id:31;pos_x:159;pos_y:16;size_x:29;size_y:44),()), //010X
         ((),(),(id:32;pos_x:164;pos_y:12;size_x:42;size_y:36),()), //011X
         ((id:33;pos_x:284;pos_y:120;size_x:52;size_y:42),(id:34;pos_x:295;pos_y:81;size_x:38;size_y:43),(id:35;pos_x:281;pos_y:27;size_x:27;size_y:16),(id:36;pos_x:281;pos_y:8;size_x:27;size_y:15)), //012X
         ((id:37;pos_x:327;pos_y:25;size_x:7;size_y:12),(id:38;pos_x:326;pos_y:34;size_x:17;size_y:9),(id:39;pos_x:331;pos_y:21;size_x:13;size_y:7),(id:40;pos_x:329;pos_y:10;size_x:7;size_y:15)),  //013X
         ((id:37;pos_x:367;pos_y:25;size_x:7;size_y:12),(id:38;pos_x:366;pos_y:34;size_x:17;size_y:9),(id:39;pos_x:371;pos_y:21;size_x:13;size_y:7),(id:40;pos_x:369;pos_y:10;size_x:7;size_y:15)),  //014X
         ((id:37;pos_x:392;pos_y:25;size_x:7;size_y:12),(id:38;pos_x:391;pos_y:34;size_x:17;size_y:9),(id:39;pos_x:396;pos_y:21;size_x:13;size_y:7),(id:40;pos_x:394;pos_y:10;size_x:7;size_y:15))),  //015X
         //1
         (((id:41;pos_x:345;pos_y:119;size_x:51;size_y:45),(id:42;pos_x:380;pos_y:225;size_x:32;size_y:44),(id:43;pos_x:344;pos_y:174;size_x:52;size_y:50),()), //10X
         ((),(id:45;pos_x:323;pos_y:249;size_x:33;size_y:19),(id:46;pos_x:288;pos_y:176;size_x:50;size_y:48),(id:47;pos_x:283;pos_y:221;size_x:61;size_y:47)), //11X
         ((),(),(id:48;pos_x:235;pos_y:180;size_x:41;size_y:43),(id:49;pos_x:227;pos_y:220;size_x:55;size_y:48)), //12X
         ((id:50;pos_x:209;pos_y:136;size_x:29;size_y:27),(),(id:51;pos_x:172;pos_y:178;size_x:41;size_y:45),(id:52;pos_x:164;pos_y:221;size_x:52;size_y:47)), //13X
         ((id:53;pos_x:98;pos_y:139;size_x:29;size_y:26),(),(id:54;pos_x:107;pos_y:182;size_x:54;size_y:46),(id:55;pos_x:107;pos_y:222;size_x:53;size_y:45)), //14X
         ((),(),(id:56;pos_x:49;pos_y:179;size_x:47;size_y:44),(id:57;pos_x:42;pos_y:218;size_x:51;size_y:49)), //15X
         ((id:58;pos_x:3;pos_y:158;size_x:26;size_y:29),(id:59;pos_x:12;pos_y:96;size_x:36;size_y:51),(id:60;pos_x:351;pos_y:14;size_x:10;size_y:22),(id:61;pos_x:3;pos_y:190;size_x:37;size_y:67)), //16X
         ((),(id:62;pos_x:50;pos_y:90;size_x:27;size_y:32),(id:63;pos_x:46;pos_y:47;size_x:54;size_y:42),(id:64;pos_x:45;pos_y:4;size_x:37;size_y:44)), //17X
         ((id:65;pos_x:171;pos_y:112;size_x:51;size_y:50),(id:66;pos_x:129;pos_y:62;size_x:53;size_y:68),(id:67;pos_x:128;pos_y:17;size_x:23;size_y:49),(id:68;pos_x:112;pos_y:2;size_x:30;size_y:40)), //18X
         ((),(),(),()), //19X
         ((),(),(),()), //110X
         ((id:69;pos_x:230;pos_y:116;size_x:53;size_y:47),(id:70;pos_x:234;pos_y:72;size_x:55;size_y:48),(id:71;pos_x:217;pos_y:28;size_x:60;size_y:15),(id:72;pos_x:216;pos_y:7;size_x:62;size_y:16)), //111X
         ((),(),(id:73;pos_x:312;pos_y:10;size_x:12;size_y:32),()), //112X
         ((id:74;pos_x:338;pos_y:24;size_x:8;size_y:18),(id:75;pos_x:277;pos_y:46;size_x:70;size_y:26),(id:76;pos_x:341;pos_y:10;size_x:7;size_y:15),(id:77;pos_x:331;pos_y:7;size_x:16;size_y:8)), //113X
         ((id:74;pos_x:378;pos_y:24;size_x:8;size_y:18),(id:78;pos_x:349;pos_y:47;size_x:26;size_y:25),(id:76;pos_x:381;pos_y:10;size_x:7;size_y:15),(id:77;pos_x:371;pos_y:7;size_x:16;size_y:8)), //114X
         ((id:74;pos_x:403;pos_y:24;size_x:8;size_y:18),(id:78;pos_x:376;pos_y:47;size_x:26;size_y:25),(id:76;pos_x:406;pos_y:10;size_x:7;size_y:15),(id:77;pos_x:396;pos_y:7;size_x:16;size_y:8))),  //115X
         //2
         (((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),())),
         //3
         (((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),())));

  gnw_dkong2_video:array[0..3,0..15,0..3] of video_def=(
         //0
         (((id:0;pos_x:245;pos_y:377;size_x:55;size_y:44),(id:1;pos_x:237;pos_y:409;size_x:23;size_y:27),(id:2;pos_x:249;pos_y:338;size_x:52;size_y:40),(id:3;pos_x:265;pos_y:314;size_x:27;size_y:25)), //00X
         ((id:4;pos_x:332;pos_y:498;size_x:29;size_y:20),(id:107;pos_x:377;pos_y:524;size_x:16;size_y:9),(id:108;pos_x:387;pos_y:527;size_x:9;size_y:17),(id:109;pos_x:384;pos_y:543;size_x:9;size_y:19)), //01X
         ((),(id:107;pos_x:352;pos_y:524;size_x:16;size_y:9),(id:108;pos_x:362;pos_y:527;size_x:9;size_y:17),(id:109;pos_x:359;pos_y:543;size_x:9;size_y:19)), //02X
         ((),(id:107;pos_x:316;pos_y:524;size_x:16;size_y:9),(id:108;pos_x:325;pos_y:527;size_x:9;size_y:17),(id:109;pos_x:323;pos_y:543;size_x:9;size_y:19)), //03X
         ((id:5;pos_x:290;pos_y:409;size_x:27;size_y:22),(id:6;pos_x:287;pos_y:432;size_x:48;size_y:39),(id:7;pos_x:284;pos_y:468;size_x:54;size_y:46),(id:105;pos_x:296;pos_y:527;size_x:13;size_y:34)), //04X
         ((id:101;pos_x:195;pos_y:545;size_x:60;size_y:18),(id:8;pos_x:226;pos_y:435;size_x:54;size_y:40),(id:9;pos_x:205;pos_y:496;size_x:30;size_y:21),(id:102;pos_x:194;pos_y:526;size_x:61;size_y:16)), //05X
         ((id:100;pos_x:92;pos_y:520;size_x:49;size_y:44),(id:10;pos_x:99;pos_y:432;size_x:54;size_y:39),(id:11;pos_x:101;pos_y:471;size_x:53;size_y:44),(id:12;pos_x:82;pos_y:496;size_x:28;size_y:21)), //06X
         ((id:13;pos_x:31;pos_y:358;size_x:30;size_y:24),(id:14;pos_x:8;pos_y:378;size_x:39;size_y:36),(id:15;pos_x:27;pos_y:420;size_x:25;size_y:30),(id:106;pos_x:335;pos_y:531;size_x:11;size_y:24)), //07X
         ((id:16;pos_x:120;pos_y:379;size_x:54;size_y:42),(id:17;pos_x:118;pos_y:408;size_x:24;size_y:29),(id:18;pos_x:120;pos_y:341;size_x:57;size_y:38),(id:19;pos_x:132;pos_y:314;size_x:33;size_y:29)), //08X
         ((id:20;pos_x:175;pos_y:61;size_x:22;size_y:28),(id:21;pos_x:171;pos_y:6;size_x:95;size_y:63),(id:22;pos_x:46;pos_y:11;size_x:54;size_y:39),(id:23;pos_x:30;pos_y:19;size_x:27;size_y:51)), //09X
         ((id:24;pos_x:38;pos_y:115;size_x:42;size_y:34),(id:25;pos_x:21;pos_y:148;size_x:25;size_y:29),(id:26;pos_x:115;pos_y:62;size_x:23;size_y:28),(id:27;pos_x:10;pos_y:229;size_x:30;size_y:26)), //010X
         ((id:28;pos_x:76;pos_y:102;size_x:32;size_y:27),(id:29;pos_x:79;pos_y:141;size_x:26;size_y:24),(id:30;pos_x:79;pos_y:164;size_x:26;size_y:29),(id:31;pos_x:80;pos_y:232;size_x:29;size_y:22)), //011X
         ((id:32;pos_x:140;pos_y:94;size_x:31;size_y:29),(id:33;pos_x:134;pos_y:146;size_x:30;size_y:26),(id:34;pos_x:137;pos_y:176;size_x:30;size_y:28),(id:35;pos_x:136;pos_y:229;size_x:32;size_y:26)), //012X
         ((id:36;pos_x:199;pos_y:103;size_x:29;size_y:24),(id:37;pos_x:193;pos_y:138;size_x:32;size_y:26),(id:38;pos_x:199;pos_y:180;size_x:31;size_y:27),(id:39;pos_x:197;pos_y:233;size_x:33;size_y:21)),  //013X
         ((id:40;pos_x:260;pos_y:96;size_x:30;size_y:27),(id:41;pos_x:256;pos_y:140;size_x:30;size_y:26),(id:42;pos_x:259;pos_y:177;size_x:30;size_y:26),(id:43;pos_x:260;pos_y:228;size_x:30;size_y:26)),  //014X
         ((id:44;pos_x:320;pos_y:101;size_x:28;size_y:28),(id:45;pos_x:319;pos_y:130;size_x:28;size_y:29),(id:46;pos_x:320;pos_y:186;size_x:30;size_y:24),(id:47;pos_x:317;pos_y:233;size_x:31;size_y:22))),  //015X
         //1
         (((id:48;pos_x:305;pos_y:378;size_x:43;size_y:44),(id:49;pos_x:370;pos_y:491;size_x:28;size_y:25),(id:50;pos_x:342;pos_y:408;size_x:31;size_y:27),(id:51;pos_x:320;pos_y:308;size_x:38;size_y:35)), //10X
         ((id:113;pos_x:370;pos_y:553;size_x:17;size_y:9),(id:110;pos_x:373;pos_y:527;size_x:10;size_y:16),(id:111;pos_x:375;pos_y:539;size_x:15;size_y:8),(id:112;pos_x:370;pos_y:543;size_x:10;size_y:13)), //11X
         ((id:113;pos_x:346;pos_y:553;size_x:17;size_y:9),(id:110;pos_x:348;pos_y:527;size_x:10;size_y:16),(id:111;pos_x:351;pos_y:539;size_x:15;size_y:8),(id:112;pos_x:346;pos_y:543;size_x:10;size_y:13)), //12X
         ((id:113;pos_x:310;pos_y:553;size_x:17;size_y:9),(id:110;pos_x:312;pos_y:527;size_x:10;size_y:16),(id:111;pos_x:315;pos_y:539;size_x:15;size_y:8),(id:112;pos_x:310;pos_y:543;size_x:10;size_y:13)), //13X
         ((id:103;pos_x:264;pos_y:545;size_x:28;size_y:17),(id:52;pos_x:224;pos_y:473;size_x:56;size_y:42),(id:53;pos_x:272;pos_y:494;size_x:25;size_y:23),(id:104;pos_x:264;pos_y:526;size_x:29;size_y:17)), //14X
         ((id:100;pos_x:141;pos_y:520;size_x:49;size_y:44),(id:54;pos_x:163;pos_y:435;size_x:58;size_y:39),(id:55;pos_x:163;pos_y:472;size_x:59;size_y:43),(id:56;pos_x:148;pos_y:492;size_x:28;size_y:25)), //15X
         ((id:100;pos_x:39;pos_y:520;size_x:49;size_y:44),(id:57;pos_x:38;pos_y:432;size_x:53;size_y:43),(id:58;pos_x:40;pos_y:468;size_x:54;size_y:48),(id:59;pos_x:17;pos_y:489;size_x:27;size_y:25)), //16X
         ((id:60;pos_x:56;pos_y:375;size_x:54;size_y:45),(id:61;pos_x:54;pos_y:409;size_x:29;size_y:23),(id:62;pos_x:52;pos_y:335;size_x:50;size_y:44),(id:63;pos_x:59;pos_y:314;size_x:30;size_y:26)), //17X
         ((id:64;pos_x:181;pos_y:377;size_x:54;size_y:45),(id:65;pos_x:177;pos_y:410;size_x:25;size_y:25),(id:66;pos_x:186;pos_y:336;size_x:51;size_y:42),(id:67;pos_x:201;pos_y:313;size_x:25;size_y:26)), //18X
         ((id:68;pos_x:26;pos_y:88;size_x:28;size_y:26),(id:69;pos_x:151;pos_y:41;size_x:43;size_y:28),(id:70;pos_x:91;pos_y:21;size_x:81;size_y:49),(id:71;pos_x:9;pos_y:39;size_x:29;size_y:20)), //19X
         ((id:72;pos_x:29;pos_y:176;size_x:20;size_y:13),(id:73;pos_x:49;pos_y:149;size_x:18;size_y:17),(id:74;pos_x:35;pos_y:166;size_x:49;size_y:43),(id:75;pos_x:33;pos_y:203;size_x:51;size_y:49)), //110X
         ((id:76;pos_x:100;pos_y:88;size_x:40;size_y:42),(id:77;pos_x:103;pos_y:126;size_x:37;size_y:46),(id:78;pos_x:93;pos_y:166;size_x:46;size_y:45),(id:79;pos_x:97;pos_y:207;size_x:51;size_y:45)), //111X
         ((id:80;pos_x:161;pos_y:85;size_x:44;size_y:45),(id:81;pos_x:165;pos_y:127;size_x:35;size_y:44),(id:82;pos_x:161;pos_y:168;size_x:40;size_y:45),(id:83;pos_x:158;pos_y:208;size_x:52;size_y:45)), //112X
         ((id:84;pos_x:221;pos_y:86;size_x:38;size_y:43),(id:85;pos_x:223;pos_y:125;size_x:36;size_y:43),(id:86;pos_x:222;pos_y:164;size_x:37;size_y:45),(id:87;pos_x:218;pos_y:206;size_x:51;size_y:45)),  //113X
         ((id:88;pos_x:286;pos_y:87;size_x:38;size_y:47),(id:89;pos_x:286;pos_y:128;size_x:37;size_y:41),(id:90;pos_x:284;pos_y:165;size_x:39;size_y:47),(id:91;pos_x:279;pos_y:209;size_x:53;size_y:45)),  //114X
         ((id:92;pos_x:300;pos_y:60;size_x:25;size_y:29),(id:93;pos_x:240;pos_y:60;size_x:23;size_y:28),(id:94;pos_x:341;pos_y:104;size_x:65;size_y:111),(id:95;pos_x:361;pos_y:230;size_x:26;size_y:25))), //115X
         //2
         (((id:96;pos_x:242;pos_y:40;size_x:42;size_y:29),(id:97;pos_x:264;pos_y:23;size_x:80;size_y:45),(id:98;pos_x:68;pos_y:1;size_x:27;size_y:42),(id:99;pos_x:291;pos_y:5;size_x:112;size_y:80)),
         ((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),())),
         //3
         (((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),()),((),(),(),())));

implementation

{$R *.dfm}

end.
