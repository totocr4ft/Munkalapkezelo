unit main_common;

interface
uses db_common,globals;

procedure loginusr;
procedure logoutusr;

implementation
uses main;

procedure loginusr;
begin
 with form_main do
  begin
   bt_login.Enabled := false;
   bt_logout.Enabled := true;
   if MC.HavePermission('devices') then bt_devices.Visible := true;
   main_page_control.Visible := true;
   main_page_control.ActivePage := ts_main;
  end;
end;

procedure logoutusr;
begin
 with form_main do
  begin
   bt_login.Enabled := true;
   bt_logout.Enabled := false;
   bt_devices.Visible := false;
   main_page_control.Visible := false;
  end;
end;


end.
