unit sl_label;

interface
uses System.SysUtils,Classes,db_common,mes_label_info;

  type
   Tserial = record
    serial         :string;
    p_order        :string;
    p_date         :string;
    p_line         :string;
    defect_comp    :string;
    defect_comp_id :string;
    defect_type    :string;
    defect_type_id :string;
    parent         :string;
    comment        :string;
    insp_type      :string;
   end;

   TSlLabelitems = array of Tserial;

   TerProc = procedure(t,erStr:string);

   TSllabel = Class
    private
     max_items : integer;
     model_,
     user_,
     plant_,
     location_,
     label_head_ ,
     label_location_,
     label_plant_,
     model_desc,
     status_id_,
     new_locid,
     status_name_,
     label_head_id_:string;
     last_error:string;
     valid_ : boolean;
     sers : TSlLabelitems;
     ErrorProc : TerProc;
     function get_label_data(label_serial:string):Tresultset;
     function count_serials():integer;
     procedure process_label_data(data:Tresultset);
     function create_label_head(loc,pla,usr:string):boolean;
     function insert_serial(s:Tserial):Boolean;
     procedure _error(t,ers:string);
    public
    function set_actual_location(new_plant,new_loc:string):boolean;
    function find_serial(ser:string):integer;
    constructor create(barcode:string);
    function add_serial_rework(serial,parent,def_c_id,def_id,insp_t:string):integer;
    function add_serial(serial:string):integer;
    procedure remove_serial(serial:string);
    function create_label(status_id,user,plant,location:string;out barcode:string):boolean;
    procedure clear;
    function change_label(new_label:string):boolean;
    property barcode : string read label_head_;
    property model : string read model_;
    property model_description : string read model_desc;
    property create_plant : string read plant_;
    property actual_plant : string read label_plant_;
    property actual_location : string read label_location_;
    property create_location : string read location_;
    property status : string read status_name_;
    property status_id : string read status_id_;
    property serials : TSlLabelitems read sers;
    property item_count : integer read count_serials;
    property Onerror    : TerProc write ErrorProc;
    property Valid      : boolean read valid_;
   End;

implementation

constructor TSllabel.create(barcode:string);
begin
if (barcode <> '') then
 begin
  change_label(barcode);
 end;
end;

procedure TSllabel.remove_serial(serial:string);
var ser_id,last_id:Integer;
    temp_c:Tserial;
begin
 if label_head_id_ <> '' then exit;
 if Length(sers) = 0 then exit;
 ser_id := find_serial(serial);
 last_id := Length(sers)-1;
 if ser_id = -1 then exit;
 temp_c := sers[last_id];
 sers[last_id] := sers[ser_id];
 sers[ser_id]  := temp_c;
 SetLength(sers,length(sers)-1);
end;

procedure TSllabel._error(t,ers:string);
begin
 last_error := ers;
 if Assigned(ErrorProc) then ErrorProc(t,ers);
end;

function TSllabel.create_label(status_id,user,plant,location:string;out barcode:string):boolean;
var er : string;
    i  :integer;
begin
Result := false;
if (label_head_ = '') and (item_count > 0) then
begin
if create_label_head(location,plant,user) then
 begin
  barcode    := label_head_;
  plant_     := plant;
  location_  := location;
  status_id_ := status_id;
  user_      := user;
 for i := 0 to Length(sers) - 1 do
  begin
  if not insert_serial(sers[i]) then
   begin
    _error('ER','Címke létrehozás hiba!');
    Result := false;
    exit;
   end;
  end;
  Result := true;
 end;
end
else
begin
 _error( 'ER',' Címke létrehozás hiba! ');
 Result := false;
end;
end;

function TSllabel.find_serial(ser:string):integer;
var i:integer;
begin
 result := -1;
 for I := 0 to Length(sers) - 1 do
 begin
 if sers[0].serial = ser then
  begin
   result := i;
   exit;
  end;
 end;
end;

function TSllabel.add_serial(serial:string):integer;
var labelinfo:TMeslabel;
begin
if find_serial(serial) > -1 then
 begin
  Result := -1;
  _error('ER','Ezt a szériaszámot már tartalmazza!');
  exit;
 end;

if label_head_ = '' then
begin
labelinfo := TMeslabel.Create(serial);
if labelinfo.label_type = 'SERIAL' then
 begin
 if (model_ = '') or (model_ = labelinfo.model) then
  begin
   SetLength(sers,length(sers) + 1);
   sers[length(sers) - 1].serial := labelinfo.serials[0];
   sers[length(sers) - 1].p_order := labelinfo.order;
   sers[length(sers) - 1].p_date := labelinfo.po_date;
   sers[length(sers) - 1].p_line := labelinfo.line;
   sers[length(sers) - 1].defect_comp_id := '0';
   sers[length(sers) - 1].defect_type_id := '0';
   if model_ = '' then model_ := labelinfo.model;
   result := length(sers) - 1;
  end
  else
   begin
    _error('ER','Model nem egyezik!');
    result := -1;
   end;
 end
 else
  begin
   _error('ER','Ismeretlen szériaszám!');
   result := -1;
  end;
end
else
begin
Result := -1;
_error('ER','Meglévõ címkéhez nem lehet hozzáadni!');
end;
end;

function TSllabel.add_serial_rework(serial,parent,def_c_id,def_id,insp_t:string):integer;
var labelinfo:TMeslabel;
begin
if label_head_ = '' then
begin
labelinfo := TMeslabel.Create(serial);
if labelinfo.label_type = 'SERIAL' then
 begin
 if (model_ = '') or (model_ = labelinfo.model) then
  begin
   SetLength(sers,length(sers) + 1);
   sers[length(sers) - 1].serial := labelinfo.serials[0];
   sers[length(sers) - 1].defect_comp_id := def_c_id;
   sers[length(sers) - 1].defect_type_id := def_id;
   sers[length(sers) - 1].p_order := labelinfo.order;
   sers[length(sers) - 1].p_date := labelinfo.po_date;
   sers[length(sers) - 1].p_line := labelinfo.line;
   sers[length(sers) - 1].insp_type := insp_t;
   if model_ = '' then model_ := labelinfo.model;
   result := length(sers) - 1;
  end
  else
   begin
    _error('ER','Model nem egyezik!');
    result := -1;
   end;
 end
 else
  begin
   _error('ER','Ismeretlen szériaszám!');
   result := -1;
  end;
end
else
begin
Result := -1;
_error('ER','Meglévõ címkéhez nem lehet hozzáadni!');
end;

end;

function TSllabel.change_label(new_label:string):boolean;
var labeldata:Tresultset;
begin
labeldata := get_label_data(new_label);
if Length(labeldata) > 0 then
 begin
  process_label_data(labeldata);
  result := true;
 end
 else
  begin
   _error('ER',new_label+' Címke nem található vagy érvénytelen!');
   result := false;
  end;
end;

procedure TSllabel.process_label_data(data:Tresultset);
var i : integer;
begin
 clear;
 label_head_id_ := data[0].Values['LABEL_HEAD_ID'];//
 label_head_ := data[0].Values['LABEL_SERIAL'];//
 location_ := data[0].Values['CREATE_LOCATION'];//
 label_location_ := data[0].Values['ACTUAL_LOCATION']; //
 plant_ := data[0].Values['CREATE_PLANT']; //
 label_plant_ := data[0].Values['ACTUAL_PLANT'];//
 user_   := data[0].Values['CREATE_GEN'];//
 model_ := data[0].Values['MODEL'];//
 model_desc := data[0].Values['MODEL_DESCRIPTION'];//
 status_id_ := data[0].Values['STATUS_ID'];//
 status_name_ := data[0].Values['STATUS_NAME'];
 valid_ := (data[0].Values['ACTIVE'] = 'True');
 for I := 0 to Length(data) - 1 do
  begin
   SetLength(sers,length(sers) + 1);
   sers[length(sers) - 1].serial := data[I].Values['SERIAL'];
  end;
 free_result(data);
end;

procedure TSllabel.clear;
begin
 SetLength(sers,0);
 max_items := 0;
 model_:= '';
 user_:= '';
 plant_:= '';
 location_:= '';
 label_head_ := '';
 label_head_id_:= '';;
 last_error:= '';
 status_id_ := '';
 status_name_ := '';
end;

function TSllabel.get_label_data(label_serial:string):Tresultset;
begin
 Result := run_query(' select * from PNX_MASTER.dbo.LABEL_DETAILS where LABEL_SERIAL = :SER ',[label_serial]);
end;

function TSllabel.count_serials():integer;
begin
 result := Length(sers);
end;

function TSllabel.create_label_head(loc,pla,usr:string):boolean;
var i : string;
   res:Tresultset;
begin
result := false;
res := run_query(' declare @o bigint;exec PNX_DEV.dbo.SHIELD_CREATE_SL :pl,:loc,:user, @o OUTPUT select @o as ID ',[pla,loc,usr]);
i := res[0].Values['ID'];
free_result(res);
 if i <> '0' then
 begin
 res := run_query(' select * from PNX_MASTER.dbo.label_head where LABEL_HEAD_ID = :i ',[i]);
  if Length(res) > 0 then
  begin
   label_head_ := res[0].Values['LABEL_SERIAL'];
   label_head_id_ := i;
   new_locid := res[0].Values['CREATE_LOC_ID'];
   result := true;
  end;
 end;
free_result(res);
end;

function TSllabel.insert_serial(s:Tserial):Boolean;
var db : Tdatabase;
begin
 try
  if s.defect_type_id = '' then s.defect_type_id := '0';
  if s.defect_comp_id = '' then s.defect_comp_id := '0';

  db := begin_trans;
  trans_exec_query(db, ' delete from PNX_MASTER.dbo.labels where SERIAL_ID = (select SERIAL_ID from PNX_MASTER.dbo.serials where SERIAL = :s) ',
                        [s.serial]);
  trans_exec_query(db,' exec PNX_MASTER.dbo.INSERT_SERIAL_WITH_LABEL_HEAD :l_h,:ser,:po,:pl,:pd,:mo,:mat ',
                        [label_head_id_,s.serial,s.p_order,s.p_line,s.p_date,model_,'']);
  trans_exec_query(db, 'exec PNX_DEV.dbo.SHIELD_STATUS_CHANGE :ser,:stat,:def,:comp,:loc,:gen,:comm,:reason,:insp_t ',
                        [s.serial,status_id_,s.defect_type_id,s.defect_comp_id,new_locid,user_,s.comment,'0',s.insp_type]);

  commit_trans(db);
  result := true;
 except
  rollback_trans(db);
  _error('ER',' Szériaszám adatbázisba írás hiba! ');
  result := false;
 end;
end;

function TSllabel.set_actual_location(new_plant,new_loc:string):boolean;
var res : Tresultset;
    lid : string;
begin
Result := false;
if barcode = '' then exit;
res := run_query('select pnx_master.dbo.GET_LOC_ID(:pl,:loc) as lid',[new_plant,new_loc]);
if Length(res) > 0  then
 begin
 lid := res[0].Values['lid'];
 result := exec_query(' update pnx_master.dbo.label_head set actual_loc_id = :lid where label_serial = :bc',[lid,barcode]);
 if Result then
  begin
   label_location_ := new_loc;
   label_plant_    := new_plant;
  end;
 end;
 free_result(res);
end;
end.
