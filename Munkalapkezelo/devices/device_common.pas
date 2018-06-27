unit device_common;

interface
uses  db_common,globals, other_common,device_queries, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.UI.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Phys, Data.DB, FireDAC.Comp.Client,
  FireDAC.Comp.DataSet, FireDAC.Phys.MySQL, FireDAC.Phys.MySQLDef,
  FireDAC.VCLUI.Wait, FireDAC.Comp.UI;

procedure fill_device_data_form;
procedure fill_device_form;
procedure ins_device;
procedure search_devices;
procedure print_device_datasheet(dev_id:string);
procedure fill_device_data_edit;
procedure del_device(dev_id:string);

implementation
uses device_form, main ;

procedure fill_device_data_edit;
var res : Tresultset;
    i : integer;
begin
with form_device_data do
 begin
  res := get_device_data(DEV_ID);
  if Length(res) > 0 then
   begin
    cb_status.ItemIndex := cb_status.Items.IndexOf(res[0].Values['dev_status_name']);
    cb_status.Enabled := false;
    cb_condition.ItemIndex := cb_condition.Items.IndexOf(res[0].Values['dev_con_name']);
    cb_condition.Enabled := false;
    cb_type.ItemIndex := cb_type.Items.IndexOf(res[0].Values['device_type_name']);
    cb_type.Enabled := false;
    e_name.Text := res[0].Values['device_name'];
    e_in_price.Text := res[0].Values['device_buy_price'];
    e_sell_price.Text := res[0].Values['device_sell_price'];
    e_comment.Text := res[0].Values['device_comment'];
    e_description.Text := res[0].Values['device_description'];
    e_barcode.Text     := res[0].Values['device_barcode'];
    clear_grid(StringGrid1);
    for I := 0 to Length(res) - 1 do
     begin
       addline(StringGrid1, res[i].Values['dev_param_name']+'|'+res[i].Values['dev_param_description'] );
     end;
    free_result(res);
   end;
 end;
end;


procedure fill_device_data_form;
begin
with form_device_data do
 begin
  cb_status.Enabled := true;
  cb_condition.Enabled := true;
  cb_type.Enabled := true;
  fill_cbox_result(cb_status,get_dev_statuses,'dev_status_id', 'dev_status_name');
  fill_cbox_result(cb_condition,get_dev_conditions,'dev_con_id', 'dev_con_name');
  fill_cbox_result(cb_type,get_dev_types,'dev_type_id', 'device_type_name');
  fill_cbox_result(cb_param_type,get_param_types,'dev_param_id', 'dev_param_name');
  e_name.Text := '';
  e_param_name.Text := '';
  e_barcode.Text := '';
  e_in_price.Text := '0';
  e_sell_price.Text := '';
  e_comment.Lines.Clear;
  e_description.Lines.Clear;
  msg_text.Caption := '';
  if (DEV_ID <> '0')  then
   begin
    fill_device_data_edit;
   end;
 end;
end;

procedure ins_device();
var devdata,params: Tresultset;
    i, par : integer;
begin
 with form_device_data do
  begin
    if cb_type.ItemIndex = -1 then
     begin
      msg(msg_text,'E', 'Adja meg az eszköz típusát!');
      exit;
     end;
    if cb_condition.ItemIndex = -1 then
     begin
      msg(msg_text,'E', 'Adja meg az eszköz állapotát!');
      exit;
     end;
    if cb_status.ItemIndex = -1 then
     begin
      msg(msg_text,'E', 'Adja meg az eszköz státuszát!');
      exit;
     end;
    if e_name.Text = '' then
      begin
      msg(msg_text,'E', 'Adja meg az eszköz Nevét!');
      exit;
     end;
    SetLength(devdata,1);
    devdata[0] := TStringList.Create();
    devdata[0].Values['device_name'] :=  e_name.Text;
    devdata[0].Values['device_description'] := e_description.Text;
    devdata[0].Values['device_type_id'] := (cb_type.Items.Objects[cb_type.ItemIndex] as Tstringobj ).value;
    devdata[0].Values['device_comment'] := e_comment.Text;
    devdata[0].Values['device_buy_price'] := bool_to_string( (e_in_price.Text = ''),'0', e_in_price.Text );
    devdata[0].Values['device_sell_price'] := bool_to_string( (e_sell_price.Text = ''),'0', e_sell_price.Text );
    devdata[0].Values['device_status_id'] := (cb_status.Items.Objects[cb_status.ItemIndex] as Tstringobj ).value;
    devdata[0].Values['device_condition_id'] := (cb_condition.Items.Objects[cb_condition.ItemIndex] as Tstringobj ).value;
    devdata[0].Values['user_id'] := bool_to_string((ch_user.Checked),'0',USER_ID);
    devdata[0].Values['device_barcode'] := e_barcode.Text;
    for i := 0 to StringGrid1.RowCount - 1 do
     begin
       if StringGrid1.Cells[0,i] <> '' then
        begin
         SetLength(params, Length(params) + 1);
         par := Length(params) - 1 ;
         params[par] := TStringList.Create;
         params[par].Values['par_type'] := StringGrid1.Cells[0,i]; 
         params[par].Values['par_name'] := StringGrid1.Cells[1,i];  
        end;
     end;

   if DEV_ID <> '0' then
    begin
     if MC.HavePermission('mod_device') <> True then
      begin
       msg(msg_text,'ER', 'Nincs jogosultsága módosítani!');
       exit;
      end;

     devdata[0].Values['device_id'] := DEV_ID;
     if update_device(devdata,params) then
      begin
       msg(msg_text,'', 'Adatok mentve!');
      end else
       begin
        msg(msg_text,'E', 'Hiba történt!');
       end;
    end else
     begin
      if MC.HavePermission('new_device') <> True then
      begin
       msg(msg_text,'ER', 'Nincs jogosultsága új eszközt regisztrálni!');
       exit;
      end;
      if ins_new_device(devdata,params) then
       begin
       close;
       end else
       begin
        msg(msg_text,'E', 'Hiba történt!');
       end;
     end;
  end;
end;

procedure search_devices;
  var res : Tresultset;
      i   : integer;
      status, cond, d_type: string;
begin
with form_main do
 begin
  if cb_device_status.ItemIndex > -1 then
   begin
    status := (cb_device_status.Items.Objects[cb_device_status.ItemIndex] as Tstringobj).value
   end else status := '-1';
  if cb_device_condition.ItemIndex > -1 then
   begin
    cond := (cb_device_condition.Items.Objects[cb_device_condition.ItemIndex] as Tstringobj).value
   end else cond := '-1';
   if cb_device_type.ItemIndex > -1 then
   begin
    d_type := (cb_device_type.Items.Objects[cb_device_type.ItemIndex] as Tstringobj).value
   end else d_type := '-1';

   clear_grid(StringGrid1);
  res := q_search_devices(e_device_barcode.text,e_device_name.text,e_device_comment.Text,e_device_description.Text,status, cond,d_type);
  for I := 0 to Length(res) - 1 do
   begin
    addline(StringGrid1, res[i].Values['device_name']
                    +'|'+res[i].Values['device_type_name']
                    +'|'+res[i].Values['dev_con_name']
                    +'|'+res[i].Values['dev_status_name']
                    +'|'+res[i].Values['device_sell_price'], res[i].Values['device_id']);
   end;
 end;
 free_result(res);
end;

procedure fill_device_form;
begin
 with form_main do
  begin
   clear_grid(StringGrid1);
   StringGrid1.Cells[0,0] := 'Megnevezés';
   StringGrid1.Cells[1,0] := 'Típus';
   StringGrid1.Cells[2,0] := 'Kondíció';
   StringGrid1.Cells[3,0] := 'Státusz';
   StringGrid1.Cells[4,0] := 'Eladási ár';
   fill_cbox_result(cb_device_status,get_dev_statuses,'dev_status_id', 'dev_status_name');
   fill_cbox_result(cb_device_condition,get_dev_conditions,'dev_con_id', 'dev_con_name');
   fill_cbox_result(cb_device_type,get_dev_types,'dev_type_id', 'device_type_name');
   if MC.HavePermission('new_device') then bt_new_device.Visible := True else bt_new_device.Visible := False;
  end;
end;

procedure print_device_datasheet(dev_id:string);
var db : Tdatabase;
    q  : Tfdquery;
begin
q := q_print_device_datasheet(dev_id, db);
try
with form_main do
 begin
   q.Active := true;
   frx_ds_device_1.DataSet := q;
   frx_device_1.PrepareReport();
   frx_device_1.SelectPrinter;
   frx_device_1.Print;
 end;
finally
  q.Free;
  db.Free;
end;
end;

procedure del_device(dev_id:string);
begin
 delete_device(dev_id);
end;


end.
