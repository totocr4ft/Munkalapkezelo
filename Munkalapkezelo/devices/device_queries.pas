unit device_queries;

interface
uses db_common,globals, other_common, System.SysUtils, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.UI.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Phys, Data.DB, FireDAC.Comp.Client,
  FireDAC.Comp.DataSet, FireDAC.Phys.MySQL, FireDAC.Phys.MySQLDef,
  FireDAC.VCLUI.Wait, FireDAC.Comp.UI;

function get_dev_statuses:Tresultset;
function get_dev_conditions:Tresultset;
function get_dev_types:Tresultset;
function get_param_types:Tresultset;
function ins_new_device(devdata,params:Tresultset):boolean;
function q_search_devices(barcode,dev_name,dev_comment,dev_description, status, cond,d_type:string):Tresultset;
function q_print_device_datasheet(dev_id:string; out db : Tdatabase):TFdquery;
function get_device_data(dev_id:string):Tresultset;
function update_device(devdata,params:Tresultset):boolean;
function delete_device(dev_id:string):boolean;


implementation

function get_dev_statuses:Tresultset;
begin
 result := run_query(' select * from device_statuses ',[]);
end;

function get_dev_conditions:Tresultset;
begin
 result := run_query(' select * from device_condition_types ',[]);
end;

function get_dev_types:Tresultset;
begin
 result := run_query(' select * from device_types ',[]);
end;

function get_param_types:Tresultset;
begin
 result := run_query(' select * from device_param_types order by dev_param_name ',[]);
end;

function ins_new_device(devdata,params:Tresultset):boolean;
var  i,y : integer;
begin
  i  := exec_query_ret_id(' insert into devices set ' +
                        ' device_name = :p1, '+
                        ' device_description = :p2,  ' +
                        ' device_type_id = :p3, ' +
                        ' device_comment = :p4, ' +
                        ' device_buy_price = :p5, ' +
                        ' device_sell_price =:p6, ' +
                        ' device_status_id =:p7, '+
                        ' device_condition_id = :p8,  '+
                        ' device_barcode = :p9,  '+
                        ' user_id = :p10 ',
                        [devdata[0].Values['device_name'],
                         devdata[0].Values['device_description'],
                         devdata[0].Values['device_type_id'],
                         devdata[0].Values['device_comment'],
                         devdata[0].Values['device_buy_price'],
                         devdata[0].Values['device_sell_price'],
                         devdata[0].Values['device_status_id'],
                         devdata[0].Values['device_condition_id'],
                         devdata[0].Values['device_barcode'],
                         devdata[0].Values['user_id']
                        ]);

  if i > -1  then
   begin
    exec_query(' delete from device_parameters where device_id = :p1 ', [IntToStr(i)]);
    for y := 0 to Length(params) - 1 do
     begin
      exec_query(' insert into device_parameters set device_id = :p1, dev_param_id = GET_DEV_PARAM_ID("'+params[y].Values['par_type']+'") '+
                 ', dev_param_description = :p2  ', [ IntToStr(i),params[y].Values['par_name']] );
     end;
   end;
  result := True;
end;


function update_device(devdata,params:Tresultset):boolean;
var  i,y : integer;
begin
  result  := exec_query(' update devices set ' +
                        ' device_name = :p1, '+
                        ' device_description = :p2,  ' +
                        ' device_type_id = :p3, ' +
                        ' device_comment = :p4, ' +
                        ' device_buy_price = :p5, ' +
                        ' device_sell_price =:p6, ' +
                        ' device_status_id =:p7, '+
                        ' device_condition_id = :p8,  '+
                        ' device_barcode = :p9,  '+
                        ' user_id = :p10 where device_id = :p11 ',
                        [devdata[0].Values['device_name'],
                         devdata[0].Values['device_description'],
                         devdata[0].Values['device_type_id'],
                         devdata[0].Values['device_comment'],
                         devdata[0].Values['device_buy_price'],
                         devdata[0].Values['device_sell_price'],
                         devdata[0].Values['device_status_id'],
                         devdata[0].Values['device_condition_id'],
                         devdata[0].Values['device_barcode'],
                         devdata[0].Values['user_id'],
                         devdata[0].Values['device_id']
                        ]);

  if devdata[0].Values['device_id'] <> '-1'  then
   begin
    exec_query(' delete from device_parameters where device_id = :p1 ', [ devdata[0].Values['device_id'] ]);
    for y := 0 to Length(params) - 1 do
     begin
      exec_query(' insert into device_parameters set device_id = :p1, dev_param_id = GET_DEV_PARAM_ID("'+params[y].Values['par_type']+'") '+
                 ', dev_param_description = :p2  ', [ devdata[0].Values['device_id'],params[y].Values['par_name']] );
     end;
   end;
  result := True;
end;

function q_search_devices(barcode,dev_name,dev_comment,dev_description, status, cond,d_type:string):Tresultset;
begin
  result:= run_query(' select * from devices d '+
            ' LEFT JOIN device_types t on d.device_type_id = t.dev_type_id  '+
            ' LEFT JOIN device_statuses s on s.dev_status_id = d.device_status_id ' +
            ' LEFT JOIN device_condition_types dc on d.device_condition_id = dc.dev_con_id ' +
            ' where d.device_name LIKE "%'+dev_name+'%" '+
            ' and d.device_description LIKE "%'+dev_description+'%" '+
            ' and d.device_comment LIKE "%'+dev_comment+'%" '+
            ' and d.device_barcode LIKE "%'+barcode+'%" '+
            ' and ( d.device_status_id = :p1 or :p2 = -1 ) '+
            ' and ( d.device_type_id   = :p3 or :p4 = -1 ) '+
            ' and ( d.device_condition_id  = :p5 or :p6 = -1 ) and d.deleted = 0 ORDER BY d.device_added DESC' ,[status,status, d_type,d_type, cond,cond]);
end;

function q_print_device_datasheet(dev_id:string; out db : Tdatabase):TFdquery;
begin
 Result := run_query_not_conv(  ' select * from devices d ' +
                       ' LEFT JOIN device_types t on d.device_type_id = t.dev_type_id ' +
                       ' LEFT JOIN device_statuses s on s.dev_status_id = d.device_status_id ' +
                       ' LEFT JOIN device_condition_types dc on d.device_condition_id = dc.dev_con_id ' +
                       ' LEFT JOIN device_parameters dp on d.device_id = dp.device_id ' +
                       ' LEFT JOIN device_param_types dpt on dpt.dev_param_id = dp.dev_param_id ' +
                       ' where d.device_id = :p1 ', dev_id, db);
end;

function get_device_data(dev_id:string):Tresultset;
begin
  result := run_query ( ' select * from devices d ' +
                       ' LEFT JOIN device_types t on d.device_type_id = t.dev_type_id ' +
                       ' LEFT JOIN device_statuses s on s.dev_status_id = d.device_status_id ' +
                       ' LEFT JOIN device_condition_types dc on d.device_condition_id = dc.dev_con_id ' +
                       ' LEFT JOIN device_parameters dp on d.device_id = dp.device_id ' +
                       ' LEFT JOIN device_param_types dpt on dpt.dev_param_id = dp.dev_param_id ' +
                       ' where d.device_id = :p1 ', dev_id);
end;

function delete_device(dev_id:string):boolean;
begin
  Result := exec_query(' update devices set deleted = 1 where device_id = :p1 ',[dev_id]);
end;


end.
