unit mes_label_info;

interface
uses System.Classes,IdHTTP,db_common,Data.DBXJSON,System.SysUtils;

  type
   Tlabelitem = array of string;

   TMeslabel = Class
    private
     l_items:Tlabelitem;
     mo,ln,prod_order,prod_date,bc,barcode_type,er,label_t,p_area:string;
     location_,plant_,user_:string;
     status_,status_id_ :string;
     function valid_():boolean;
     function get_l_count:integer;
     function get_serial_data(sn:string):string;
     function get_raw_result:string;
     procedure parse_json(js:string);
     procedure cleanup;
     procedure get_status();
    const
     SERVER      = 'http://106.114.87.43';
     URL         = '/eoperation_server/details/shield/label_info.php?sn=';
     SERIAL_URL  = '/eoperation_server/details/shield/serial.php?sn=';
    public
     constructor Create(LabelValue : string);
     procedure get_label_data;
     function SerialsCommatext():string;
     property model      : string read mo;
     property line       : string read ln;
     property order      : string read prod_order;
     property po_date    : string read prod_date;
     property barcode    : string read bc write bc;
     property serials    : Tlabelitem read l_items;
     property item_count : integer read get_l_count;
     property label_type : string read label_t;
     property error      : string read er;
     property location   : string read location_ write location_;
     property user       : string read user_ write user_;
     property plant      : string read plant_ write plant_;
     property prod_area  : string read p_area;
     property Valid      : Boolean read valid_;
     property status     : string read status_ ;
     property status_id  : string read status_id_ ;
     function Disable():boolean;
   End;

implementation

constructor TMeslabel.Create(LabelValue : string);
var s : string;
begin
 bc := LabelValue;
 if Copy(LabelValue,1,3) = 'PAL' then
  begin
   label_t := 'PALLETT';
   p_area  := 'MAIN';
  end
  else if Copy(LabelValue,1,3) = 'CAR' then
  begin
   label_t := 'CARTON';
   p_area  := 'LCM';
  end
 else
  begin
   s := get_serial_data(LabelValue);
   if s <> '' then bc := s;
  end;
end;

function TMeslabel.SerialsCommatext:string;
var i : integer;
begin
 Result := '';
 if Length(l_items) = 0 then exit;
 for i := 0 to Length(l_items) - 1 do
  begin
   Result := Result + QuotedStr(l_items[i]);
   if i < Length(l_items) - 1 then Result := Result + ',';
  end;
end;

function TMeslabel.valid_:Boolean;
var res: Tresultset;
begin
res := run_query(' select active from pnx_master.dbo.label_head where label_serial=:l ',[barcode]);
if Length(res) > 0 then
 begin
   result := (res[0].Values['ACTIVE'] = 'True' );
 end;
free_result(res);
end;

function TMeslabel.Disable:Boolean;
var res: Tresultset;
begin
 if (label_t = 'CARTON') and (barcode <> '') then
 Result := exec_query(' update pnx_master.dbo.label_head set active=0 where label_serial = :l ',[barcode])
 else result := false;
end;

function TMeslabel.get_l_count:Integer;
begin
 Result := Length(l_items);
end;

function TMeslabel.get_raw_result:string;
var ht:Tidhttp;
    s,data :string;
begin
if  (location_ <> '') and (user_ <> '') and (plant_ <> '') then
 begin
  data := '&plant='+plant_+'&loc='+location_+'&gen='+user_;
 end
else data := '';
try
 ht := TIdHTTP.Create(nil);
 ht.HandleRedirects := True;
 s  := ht.Get(SERVER+URL+bc+data);
 er := '';
 Result := s;
except
 s  := '';
 er := 'Http_error';
end;
ht.Free;
Result := s;
end;

procedure TMeslabel.parse_json(js:string);
 var
    arr:TJSONArray;
    jv:TJSONValue;
begin
try
cleanup;
arr:=TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(js),0) as TJSONArray;
 for jv in arr do
 begin
  SetLength(l_items,Length(l_items) + 1);
  l_items[Length(l_items) - 1]:=(jv as TJSONObject).Get('serial').JsonValue.Value;
  mo:=(jv as TJSONObject).Get('model').JsonValue.Value;
  ln:=  StringReplace((jv as TJSONObject).Get('line').JsonValue.Value,'DP_','',[rfReplaceAll,rfIgnoreCase]) ;
  prod_order:=(jv as TJSONObject).Get('prod_order').JsonValue.Value;
  prod_date:=(jv as TJSONObject).Get('prod_date').JsonValue.Value;
 end;
 if label_type = 'CARTON' then get_status;
 er := '';
except
 cleanup;
 er := 'Json parse error';
end;
end;

procedure TMeslabel.get_label_data;
var raw : string;
begin
if bc = '#' then exit;
if Copy(bc,1,3) = 'PAL' then
  begin
   label_t := 'PALLETT';
   p_area  := 'MAIN';
  end
  else if Copy(bc,1,3) = 'CAR' then
  begin
   label_t := 'CARTON';
   p_area  := 'LCM';
  end;
 raw := get_raw_result;
 if raw <> '' then
  begin
   parse_json(raw);
  end;
end;

procedure TMeslabel.cleanup;
begin
 SetLength(l_items,0);
 mo := '';
 prod_order := '';
 prod_date  := '';
 ln         := '';
 status_    := '';
 status_id_ := '';
end;

function TMeslabel.get_serial_data(sn:string):string;
var ht:Tidhttp;
    s,data,pal,car :string;
    arr:TJSONArray;
    jv:TJSONValue;
begin
try
 result := '';
 ht := TIdHTTP.Create(nil);
 ht.HandleRedirects := True;
 s  := ht.Get(SERVER+SERIAL_URL+sn);
 er := '';
 cleanup;
 arr:=TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(s),0) as TJSONArray;
 for jv in arr do
 begin
  SetLength(l_items,Length(l_items) + 1);
  l_items[Length(l_items) - 1]:=(jv as TJSONObject).Get('serial').JsonValue.Value;
  pal :=(jv as TJSONObject).Get('pallett').JsonValue.Value;
  car :=(jv as TJSONObject).Get('carton').JsonValue.Value;
  mo:=(jv as TJSONObject).Get('model').JsonValue.Value;
  ln:=  StringReplace((jv as TJSONObject).Get('line').JsonValue.Value,'DP_','',[rfReplaceAll,rfIgnoreCase]) ;
  prod_order:=(jv as TJSONObject).Get('prod_order').JsonValue.Value;
  prod_date:=(jv as TJSONObject).Get('prod_date').JsonValue.Value;
  p_area := (jv as TJSONObject).Get('prod_area').JsonValue.Value;
 end;
 if car <> '' then Result := car else
 if pal <> '' then Result := pal else
  begin
   Result := '#';
  end;
 if model = '' then label_t := 'NO DATA' else label_t := 'SERIAL';
except
 s  := '';
 er := 'Http_error';
end;
ht.Free;
end;

procedure TMeslabel.get_status();
var res : Tresultset;
begin
if (label_type = 'CARTON') and (barcode <> '') then
 begin
  res := run_query(' select * from PNX_MASTER.dbo.LABEL_DETAILS where LABEL_SERIAL = :bc ',[barcode]);
  if Length(res) > 0 then
   begin
    status_    := res[0].Values['STATUS_NAME'];
    status_id_ := res[0].Values['STATUS_ID'];
   end;
 end;
 free_result(res);
end;

end.
