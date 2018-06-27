unit material_label;

interface
uses db_common,System.SysUtils;

  type
   Mat_label = class
    private
     _barcode:string;
     actual_location,
     user,
     plant,create_location : string;
     active:boolean;
     procedure update_actual_loc;
    public
     maktx    : string;
     material : string;
     qty      : string;
     vendor   : string;
     invoice  : string;
     del_note : string;
     plate_nr : string;
     AWB      : string;
     container: string;
     comment  : string;
     date     : string;
     procedure clear;
     property get_barcode : string read _barcode;
     property get_plant : string read plant;
     property get_create_location : string read create_location;
     property get_actual_location : string read actual_location;
     property get_user : string read user;
     property is_active: Boolean read active;
     procedure change_label(bc:string);
     function save_label_data():boolean;
     constructor create(bc,plnt,act_l,usr:string);
   end;

implementation

constructor Mat_label.create(bc,plnt,act_l,usr:string);
begin
 actual_location := act_l;
 user  := usr;
 plant := plnt;
 if bc <> '' then change_label(bc);
end;

procedure Mat_label.update_actual_loc;
begin
 if (_barcode <> '') and( plant <> '' ) and (actual_location <> '') then
 exec_query(' update pnx_master.dbo.label_head set ACTUAL_LOC_ID = pnx_master.dbo.GET_LOC_ID('+QuotedStr(plant)+','+QuotedStr(actual_location)+') where label_serial = :lh ',[_barcode]);
end;

function Mat_label.save_label_data():Boolean;
var res: Tresultset;
    db : Tdatabase;
    b  : string;
begin
 result := false;
 try
  db := begin_trans;
  res := trans_run_query(db,' exec pnx_master.dbo.CREATE_ML_HEAD :plant ',[plant]);
  if res[0].Values['BARCODE'] <> '' then
   begin
    b := res[0].Values['BARCODE'];
    free_result(res);
    res := trans_run_query (db,' exec pnx_master.dbo.INSERT_ML :BC,:PLANT,:LOC,:MAT,:QTY,:USR,:DNO,:PLNR,:INV,:VEN,:CONT,:COMM,:AWB ',
                           [b,plant,actual_location,material,qty,user,del_note,plate_nr,invoice,vendor,container,comment,AWB]);
    if res[0].Values['L_ID'] = '0' then
     begin
      rollback_trans(db);
      result := False;
      exit;
     end;
    commit_trans(db);
    result := true;
    change_label(b);
   end
    else
     begin
      rollback_trans(db);
     end;
 except
  rollback_trans(db);
 end;
end;

procedure Mat_label.change_label(bc:string);
var res : Tresultset;
begin
 if bc = '' then exit;
 res := run_query(' select h.*, l.LOC_NAME, al.LOC_NAME as ACTUAL_LOC,p.PLANT, m.MAT_DESCRIPTION, m.mat_no from pnx_master.dbo.label_head h left join pnx_master.dbo.locations l on '
                 +' h.CREATE_LOC_ID = l.LOC_ID left join pnx_master.dbo.plants p on p.plant_id = l.plant_id '
                 +' left join pnx_master.dbo.locations al on h.ACTUAL_LOC_ID = al.loc_id '
                 +' left join pnx_master.dbo.materials m on h.mat_id=m.mat_id '
                 +' where h.LABEL_SERIAL = :L  ',[bc]);
 if Length(res) > 0 then
  begin
   clear;
   qty      := res[0].Values['QTY'];
   material := res[0].Values['MAT_NO'];
   maktx    := res[0].Values['MAT_DESCRIPTION'];
   plant    := res[0].Values['PLANT'];
   vendor   := res[0].Values['VENDOR'];
   invoice  := res[0].Values['INVOICE'];
   del_note := res[0].Values['DEL_NOTE'];
   plate_nr := res[0].Values['PLATE_NR'];
   AWB      := res[0].Values['AWB'];
   container:= res[0].Values['CONTAINER'];
   comment  := res[0].Values['COMMENT'];
   date     := res[0].Values['CREATE_DATE'];
   create_location := res[0].Values['LOC_NAME'];
   actual_location := res[0].Values['ACTUAL_LOC'];
   active := (res[0].Values['ACTIVE'] = 'True');
   _barcode := bc;
   update_actual_loc;
  end;
 free_result(res);
end;

procedure Mat_label.clear;
begin
  plant    :='';
  vendor   :='';
  invoice  :='';
  del_note :='';
  plate_nr :='';
  AWB      :='';
  container:='';
  comment  :='';
  date     :='';
  create_location :='';
  actual_location :='';
  user := '';
  material := '';
  qty := '';
end;

end.
