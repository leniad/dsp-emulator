unit arcadeconfig_misc;

interface
uses main_engine,arcade_config,controls_engine,stdctrls,principal,dialogs;

procedure configarcade_boton1;
procedure arcadeconfig_close;
procedure arcadeconfig_formshow;

implementation

procedure configarcade_boton1;
var
  dip_tmp:pdef_dip;
  dip_pos:byte;
  f,valor:word;
function leer_valor_dip3(pos1,pos2:byte;dip:def_dip2):word;
begin
case dip.number of
  2:leer_valor_dip3:=dip.val2[combobox_dip[pos1,pos2].ItemIndex];
  4:leer_valor_dip3:=dip.val4[combobox_dip[pos1,pos2].ItemIndex];
  8:leer_valor_dip3:=dip.val8[combobox_dip[pos1,pos2].ItemIndex];
  16:leer_valor_dip3:=dip.val16[combobox_dip[pos1,pos2].ItemIndex];
  32:leer_valor_dip3:=dip.val32[combobox_dip[pos1,pos2].ItemIndex];
end;
end;
begin
  if length(marcade.dipsw_a)<>0 then begin
    for f:=0 to length(marcade.dipsw_a)-1 do begin
      valor:=leer_valor_dip3(0,f+1,marcade.dipsw_a[f]);
      marcade.dswa:=(marcade.dswa and not(marcade.dipsw_a[f].mask)) or valor;
    end;
    if length(marcade.dipsw_b)<>0 then begin
      for f:=0 to length(marcade.dipsw_b)-1 do begin
        valor:=leer_valor_dip3(1,f+1,marcade.dipsw_b[f]);
        marcade.dswb:=(marcade.dswb and not(marcade.dipsw_b[f].mask)) or valor;
      end;
    end;
    if length(marcade.dipsw_c)<>0 then begin
      for f:=0 to length(marcade.dipsw_c)-1 do begin
        valor:=leer_valor_dip3(2,f+1,marcade.dipsw_c[f]);
        marcade.dswc:=(marcade.dswc and not(marcade.dipsw_c[f].mask)) or valor;
      end;
    end;
  end else begin
    dip_tmp:=marcade.dswa_val;
    dip_pos:=1;
    while dip_tmp.name<>'' do begin
      valor:=dip_tmp.dip[combobox_dip[0,dip_pos].ItemIndex].dip_val;
      marcade.dswa:=(marcade.dswa and not(dip_tmp.mask)) or valor;
      dip_pos:=dip_pos+1;
      inc(dip_tmp);
    end;
    if marcade.dswb_val<>nil then begin
      dip_tmp:=marcade.dswb_val;
      dip_pos:=1;
      while dip_tmp.name<>'' do begin
        valor:=dip_tmp.dip[combobox_dip[1,dip_pos].ItemIndex].dip_val;
        marcade.dswb:=(marcade.dswb and not(dip_tmp.mask)) or valor;
        dip_pos:=dip_pos+1;
        inc(dip_tmp);
      end;
    end;
    if marcade.dswc_val<>nil then begin
      dip_tmp:=marcade.dswc_val;
      dip_pos:=1;
      while dip_tmp.name<>'' do begin
        valor:=dip_tmp.dip[combobox_dip[2,dip_pos].ItemIndex].dip_val;
        marcade.dswc:=(marcade.dswc and not(dip_tmp.mask)) or valor;
        dip_pos:=dip_pos+1;
        inc(dip_tmp);
      end;
    end;
   end;
end;

procedure arcadeconfig_close;
var
  f,h:byte;
begin
  for f:=0 to MAX_DIP do begin
    for h:=1 to MAX_COMP do begin
      if Combobox_dip[f,h]<>nil then begin
        Combobox_dip[f,h].Destroy;
        Combobox_dip[f,h]:=nil;
        Label_dip[f,h].Destroy;
        Label_dip[f,h]:=nil;
      end;
    end;
  end;
end;

procedure arcadeconfig_formshow;
procedure montar_paneles(pos,dip_pos:byte);
begin
  Combobox_dip[pos,dip_pos]:=TComboBox.create(config_arcade);
  case pos of
    0:Combobox_dip[pos,dip_pos].Parent:=config_arcade.GroupBox1;
    1:Combobox_dip[pos,dip_pos].Parent:=config_arcade.GroupBox2;
    2:Combobox_dip[pos,dip_pos].Parent:=config_arcade.GroupBox3;
  end;
  Combobox_dip[pos,dip_pos].Left:=100;
  Combobox_dip[pos,dip_pos].Top:=25*dip_pos;
  Combobox_dip[pos,dip_pos].TabStop:=false;
  Combobox_dip[pos,dip_pos].Width:=150;
  Label_dip[pos,dip_pos]:=TLabel.Create(config_arcade);
  case pos of
    0:Label_dip[pos,dip_pos].Parent:=config_arcade.GroupBox1;
    1:Label_dip[pos,dip_pos].Parent:=config_arcade.GroupBox2;
    2:Label_dip[pos,dip_pos].Parent:=config_arcade.GroupBox3;
  end;
  Label_dip[pos,dip_pos].Left:=5;
  Label_dip[pos,dip_pos].Top:=25*dip_pos;
  Label_dip[pos,dip_pos].AutoSize:=true;
end;
procedure put_dip(pos:byte;dip:pdef_dip;valor:word);
var
  dip_pos,h:byte;
  dip_tmp:pdef_dip;
begin
dip_tmp:=dip;
dip_pos:=1;
while dip_tmp.name<>'' do begin
  montar_paneles(pos,dip_pos);
  if (dip_tmp.number-1)>MAX_DIP_VALUES then MessageDlg('Warning: More Values in DIP_old than available!',mtError,[mbOk],0);
  for h:=0 to dip_tmp.number-1 do begin
    Combobox_dip[pos,dip_pos].Items.Add(dip_tmp.dip[h].dip_name);
    if dip_tmp.dip[h].dip_val=(valor and dip_tmp.mask) then combobox_dip[pos,dip_pos].ItemIndex:=h;
  end;
  Label_dip[pos,dip_pos].Caption:=dip_tmp.name;
  dip_pos:=dip_pos+1;
  if dip_pos>MAX_COMP then MessageDlg('Warning: More Values in DIP_old than available!',mtError,[mbOk],0);
  inc(dip_tmp);
end;
end;
procedure put_dip3(pos:byte;dip:array of def_dip2;valor:word);
var
  h,f:byte;
begin
for f:=0 to length(dip)-1 do begin
  montar_paneles(pos,f+1);
  for h:=0 to dip[f].number-1 do begin
    case dip[f].number of
        2:begin
            Combobox_dip[pos,f+1].Items.Add(dip[f].name2[h]);
            if dip[f].val2[h]=(valor and dip[f].mask) then combobox_dip[pos,f+1].ItemIndex:=h;
          end;
        4:begin
            Combobox_dip[pos,f+1].Items.Add(dip[f].name4[h]);
            if dip[f].val4[h]=(valor and dip[f].mask) then combobox_dip[pos,f+1].ItemIndex:=h;
          end;
        8:begin
            Combobox_dip[pos,f+1].Items.Add(dip[f].name8[h]);
            if dip[f].val8[h]=(valor and dip[f].mask) then combobox_dip[pos,f+1].ItemIndex:=h;
          end;
        16:begin
            Combobox_dip[pos,f+1].Items.Add(dip[f].name16[h]);
            if dip[f].val16[h]=(valor and dip[f].mask) then combobox_dip[pos,f+1].ItemIndex:=h;
           end;
        32:begin
            Combobox_dip[pos,f+1].Items.Add(dip[f].name32[h]);
            if dip[f].val32[h]=(valor and dip[f].mask) then combobox_dip[pos,f+1].ItemIndex:=h;
          end;

    end;
  end;
  Label_dip[pos,f+1].Caption:=dip[f].name;
  if f>MAX_COMP then MessageDlg('Warning: More Values in DIP than available!',mtError,[mbOk],0);
end;
end;
var
  f:integer;
begin
  f:=(principal1.left+(principal1.width div 2))-(config_arcade.Width div 2);
  if f<0 then config_arcade.Left:=0
    else config_arcade.Left:=f;
  f:=(principal1.top+(principal1.Height div 2))-(config_arcade.Height div 2);
  if f<0 then config_arcade.Top:=0
    else config_arcade.Top:=f;
  config_arcade.GroupBox2.Visible:=false;
  config_arcade.GroupBox3.Visible:=false;
  config_arcade.Width:=289;
  config_arcade.Button1.Left:=9;
  config_arcade.Button2.Left:=141;
  if length(marcade.dipsw_a)<>0 then put_dip3(0,marcade.dipsw_a,marcade.dswa)
    else if marcade.dswa_val<>nil then put_dip(0,marcade.dswa_val,marcade.dswa);
  if ((marcade.dswb_val<>nil) or (length(marcade.dipsw_b)<>0)) then begin
    config_arcade.Width:=560;
    config_arcade.Button1.Left:=64;
    config_arcade.Button2.Left:=340;
    config_arcade.GroupBox2.Visible:=true;
    if length(marcade.dipsw_b)<>0 then put_dip3(1,marcade.dipsw_b,marcade.dswb)
      else put_dip(1,marcade.dswb_val,marcade.dswb);
  end;
  if ((marcade.dswc_val<>nil) or (length(marcade.dipsw_c)<>0)) then begin
    config_arcade.Width:=833;
    config_arcade.Button1.Left:=208;
    config_arcade.Button2.Left:=496;
    config_arcade.GroupBox3.Visible:=true;
    if length(marcade.dipsw_c)<>0 then put_dip3(2,marcade.dipsw_c,marcade.dswc)
      else put_dip(2,marcade.dswc_val,marcade.dswc);
  end;
end;

end.
