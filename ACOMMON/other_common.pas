////////////////////////////////////////////////////////////////////
//   _____ _    _ _   _  _____ _______ _____ ____  _   _  _____   //
// |  ____| |  | | \ | |/ ____|__   __|_   _/ __ \| \ | |/ ____|  //
// | |__  | |  | |  \| | |       | |    | || |  | |  \| | (___    //
// |  __| | |  | | . ` | |       | |    | || |  | | . ` |\___ \   //
// | |    | |__| | |\  | |____   | |   _| || |__| | |\  |____) |  //
// |_|     \____/|_| \_|\_____|  |_|  |_____\____/|_| \_|_____/   //
//                                                                //
////////////////////////////////////////////////////////////////////

unit other_common;

interface

uses  Winapi.Windows, Winapi.Messages, System.SysUtils,
      System.Variants, System.Classes, Vcl.ComCtrls,Vcl.Grids
      ,Winapi.MMSystem,Vcl.Clipbrd,Vcl.StdCtrls,db_common,IdGlobal, IdHash, IdHashMessageDigest,Vcl.Forms,Vcl.Dialogs,Vcl.Controls,
      OleCtnrs, ShellAPI, ComObj;
 type
   Tintarray = array of integer;
   T1darray = array of string;
   T2darray = array of T1darray;
   Tstringobj = class
     private
       val:string;
     public
      constructor Create(value:string);
      property value : string read val write val;
   end;


 function GetAppVersionStr(Exe : string): string;
 function bool_to_string(b:boolean;True:string; False:string):string;
 procedure delline(list:TObject;id:integer);
procedure addline(list:TObject;value:string; obj :string = '');
function getobj(list:TObject):string;
 procedure clear_grid(grid:TStringGrid);
 function summ_grid_col(grid:Tstringgrid;c:integer):integer;
 procedure sound(event: string);
 function explode(separator,text:string):T1darray;
 procedure gidtoclipboard(grid:TStringGrid);
 function get_id_cbox(box:Tcombobox):string;
 procedure fill_cbox_result(box:TComboBox; res:Tresultset;id_col,name_col:string);
 procedure clear_cbox(box:TComboBox);
 procedure array_push(var arr:T1darray;item:string);
 function IsCellSelected(StringGrid: TStringGrid; X, Y: Longint): Boolean;
 procedure append_file(filename:string;txt:string);
 function index_of(arr:T1darray;item:string):integer;
 function MD5(S: String): String;
 function group_resultset(res: Tresultset; cols:T1darray):Tresultset;
 function index_of_result( res: Tresultset; col,Value:string ):Tintarray;
 procedure intarray_push( var arr:Tintarray;item:integer);
 procedure resultset_to_csv(res : Tresultset; filename:string);
 procedure excel_from_resultset(Res : Tresultset;filename:string;Open_after:Boolean);
 procedure order_result_by(var res : Tresultset;col:string);
 function implode(separator:string; intarr:Tintarray):string;
 function ConfirmDialog(title,value,yes_caption,no_caption:string):integer;
 function json_to_resultset(json:string):Tresultset;

implementation

constructor Tstringobj.Create(value: string);
begin
  val := value;
end;

function MD5(S: String): String;
begin
with TIdHashMessageDigest5.Create do
 begin
  Result := UpperCase( HashStringAsHex(S) );
  DisposeOf;
 end;
end;

//--------------CHECK EXE FILEVERSION pl: 1.0.0.12-------//
function GetAppVersionStr(Exe : string): string;
var
  Size, Handle: DWORD;
  Buffer: TBytes;
  FixedPtr: PVSFixedFileInfo;
begin
  Size := GetFileVersionInfoSize(PChar(Exe), Handle);
  if Size = 0 then
      RaiseLastOSError;
      SetLength(Buffer, Size);
  if not GetFileVersionInfo(PChar(Exe), Handle, Size, Buffer) then
      RaiseLastOSError;
  if not VerQueryValue(Buffer, '\', Pointer(FixedPtr), Size) then
      RaiseLastOSError;
      Result := Format('%d%d%d%d',
     [LongRec(FixedPtr.dwFileVersionMS).Hi,  //major
      LongRec(FixedPtr.dwFileVersionMS).Lo,  //minor
      LongRec(FixedPtr.dwFileVersionLS).Hi,  //release
      LongRec(FixedPtr.dwFileVersionLS).Lo]) //build
end;

//--------------//  Convert Boolean to custom string  //------------//
function bool_to_string(b:boolean;True:string; False:string):string;
begin
 if b then Result := True else Result := False;
end;

//----------------------------------------------------------------------------//
//                          DELETE LINE FROM STRINGGRID                       //
//----------------------------------------------------------------------------//
procedure delline(list:TObject;id:integer);
var i,y:integer;
    lista:TStringGrid;
begin
try
 with (list as TStringGrid) do
 begin
 if RowCount >= 2 then
  begin
   rows[id].Clear;
  if (RowCount > 2) then
   begin
   for I := id to RowCount - 1 do
    begin
    for y := 0 to ColCount - 1 do
     begin
      Cells[y,i] := Cells[y,i+1];
      Cells[y,i + 1] := '';
     end;
    end;
    RowCount := RowCount - 1;
   end
  end;
 end;
except
end;
end;

//----------------------------------------------------------------------------//
//                          ADD LINE TO STRINGGRID                            //
//----------------------------------------------------------------------------//
procedure addline(list:TObject;value:string; obj :string = '');
var i,y:integer;
    lista:TStringGrid;
    f_row_empty:boolean;
    ob  : Tstringobj;
    values:array of string;
begin
 if obj <> '' then
  begin
   ob := Tstringobj.Create(obj);
  end;
for i := 1 to Length(value) do
 begin
  if value[i] = '|' then
   begin
    if length(values) = 0 then SetLength(values,1);
    SetLength(values,Length(values) + 1);
   end;
 end;
if Length(values) > 0 then
 begin
  y := 0;
 for i := 1 to Length(value) do
  begin
   if value[i] = '|' then
    begin
     Inc(y);
    end;
   if value[i] <> '|' then
    begin
     values[y] := values[y] + value[i]
    end;
  end;
 end;
if Length(values) = 0 then
 begin
  try
   with (list as TStringGrid) do
   begin
    if (RowCount = 2) and (Cells[0,1] = '') then
     begin
      Cells[0,1] := Value;
      if Assigned(ob) then Objects[0,1] := ob;
     end
     else
     begin
      RowCount := RowCount + 1;
      Cells[0,RowCount - 1] := value;
      if Assigned(ob) then Objects[0,RowCount - 1] := ob;
     end;
   end;
  except
  end;
 end
else
 begin
  try
   with (list as TStringGrid) do
   begin
    f_row_empty := true;
    for i := 0 to ColCount - 1 do if Cells[i,1] <> '' then f_row_empty := false;
    if (RowCount = 2) and (f_row_empty) then
     begin
      for i := 0 to Length(values) - 1 do
       begin
        Cells[i,1] := values[i];
        if Assigned(ob) then Objects[i,1] := ob;
       end;
     end
    else
     begin
      RowCount := RowCount + 1;
      for i := 0 to Length(values) - 1 do
      begin
       Cells[i,RowCount - 1] := values[i];
       if Assigned(ob) then Objects[i,RowCount - 1] := ob;
      end;
     end;
   end;
  except
  end;
 end;
end;

//----------------------------------------------------------------------------//
//                          GET LINE OBJECT DATA                              //
//----------------------------------------------------------------------------//
function getobj(list:TObject):string;
begin
with (list as TStringGrid) do
 begin
  if Assigned(Objects[0,Row]) then
   begin
    try
     result := (Objects[0,row] as Tstringobj).val;
    except
     Result := '';
    end;
   end else Result := '';
 end;
end;
//----------------------------------------------------------------------------//
//                     CLEAR STRINGGRID AND SET ROWCOUNT TO 2                 //
//----------------------------------------------------------------------------//
procedure clear_grid(grid:TStringGrid);
var i:integer;
begin
with grid do
 begin
 for I := 1 to RowCount - 1 do
  begin
   Rows[i].Clear;
  end;
  RowCount := 2;
 end;
end;

//----------------------------------------------------------------------------//
//                             CHECK IS CELL SELECTED                         //
//----------------------------------------------------------------------------//

function IsCellSelected(StringGrid: TStringGrid; X, Y: Longint): Boolean;
begin
  Result := False;
  try
    if (X >= StringGrid.Selection.Left) and (X <= StringGrid.Selection.Right) and
       (Y >= StringGrid.Selection.Top)  and (Y <= StringGrid.Selection.Bottom) then
   Result := True;
  except
  end;
end;

//----------------------------------------------------------------------------//
//                      SUMM ALL NUMBERS IN A GIVEN COL                       //
//----------------------------------------------------------------------------//
function summ_grid_col(grid:Tstringgrid;c:integer):integer;
var i,sum,act:integer;
begin
try
with grid do
 begin
 sum := 0;
 for I := 1 to RowCount - 1 do
  begin
   try
    act  := StrToInt(Cells[c,i]);
    sum  := sum + act;
   except
   end;
  end;
  result := sum;
 end;
except
 result := 0;
end;
end;

//----------------------------------------------------------------------------//
//                           PLAY SOUND FROM RESOURCE                         //
//----------------------------------------------------------------------------//
procedure sound(event: string);
var HResource:TResourceHandle;
    HResData:THandle;
    PWav:Pointer;
begin
try
HResource:=FindResource(HInstance,PChar(event),'WAVE');
if HResource<>0 then
 begin
 HResData:=LoadResource(HInstance,HResource);
 if HResData<>0 then
  begin
   PWav:=LockResource(HResData);
   if Assigned(PWav) then
   begin
    sndPlaySound(nil,SND_NODEFAULT);
    sndPlaySound(PWav,SND_ASYNC or SND_MEMORY);
   end;
  end;
  end
except
end;
end;

//----------------------------------------------------------------------------//
//                           Stringgrid to clipbrd                            //
//----------------------------------------------------------------------------//
procedure gidtoclipboard(grid:TStringGrid);
var i,y: integer;
    a:string;
begin
try
a := '';
Clipboard.Clear;
for I := 0 to grid.RowCount - 1 do
 begin
 for y := 0 to grid.ColCount - 1 do
  begin
   a := a + grid.Cells[y,i];
   if y < grid.ColCount - 1 then a := a + #9;
  end;
  a := a + #10;
 end;
 Clipboard.AsText := a;
except
end;
end;
//----------------------------------------------------------------------------//
//                                CBOX UTILS                                  //
//----------------------------------------------------------------------------//
procedure clear_cbox(box:TComboBox);
begin
if box = nil then exit;
 box.Items.Clear;
 box.Text := '';
end;

procedure fill_cbox_result(box:TComboBox; res:Tresultset;id_col,name_col:string);
var i : integer;
begin
if box = nil then exit;
clear_cbox(box);
if id_col <> '' then
 begin
 for i := 0 to Length(res) - 1 do
  begin
   box.Items.AddObject(res[i].Values[name_col],Tstringobj.Create(res[i].Values[id_col]));
  end;
 end
  else
  begin
  for i := 0 to Length(res) do
   begin
    box.Items.Add(res[i].Values[name_col]);
   end;
  end;
 free_result(res);
end;

function get_id_cbox(box:Tcombobox):string;
begin
result := '';
if box = nil then exit;
if box.ItemIndex = -1 then exit;
if box.Items.Objects[box.ItemIndex] = nil then exit;
if box.Items.Objects[box.ItemIndex].ClassType = Tstringobj then
begin
 result :=  (box.Items.Objects[box.ItemIndex] as Tstringobj).value;
end;
end;

procedure append_file(filename:string;txt:string);
var f   : TextFile;
begin
try
if FileExists(filename) then
 begin
  AssignFile(f, filename);
  Append(f);
  Writeln(f,txt);
 end
  else
   begin
    AssignFile(f, filename);
    Rewrite(f);
    Writeln(f,txt);
   end;
 CloseFile(f);
except
 CloseFile(f);
end;
end;

//****************************************************************************//
//                                ARRAY STUFF                                 //
//****************************************************************************//

//----------------------------------------------------------------------------//
//                   CREATE ARRAY FROM STRING (CUSTOM SEPARATOR)              //
//----------------------------------------------------------------------------//
function explode(separator,text:string):T1darray;
var arr : T1darray;
    i,c : integer;
begin
 SetLength(arr,0);
 if (Pos(separator,text) = 0) then
  begin
   SetLength(arr,1);
   arr[0] := text;
   Result := arr;
   exit;
  end;
 if (separator = '') or (text = '')  then begin result:= arr; exit; end;
 try
  c := 0;
  SetLength(arr,1);
 for I := 1 to Length(text)  do
  begin
   if text[i] = separator then
    begin
     SetLength(arr, Length(arr) + 1);
     Inc(c);
    end
    else
    begin
     arr[c] := arr[c] + text[i];
    end;
  end;
  result := arr;
 except;
 end;
end;

//----------------------------------------------------------------------------//
//                   CREATE STRING FROM ARRAY (CUSTOM SEPARATOR)              //
//----------------------------------------------------------------------------//

function implode(separator:string; intarr:Tintarray):string; overload;
var i : integer;
begin
 Result := '';
 if Length(intarr) = 0 then exit;
 for i := 0 to Length(intarr) - 1 do
  begin
   Result := Result + IntToStr(intarr[i]);
   if i < Length(intarr) - 1 then Result := Result + separator;
  end;
end;

function implode(separator:string; arr:T1darray):string; overload;
var i : integer;
begin
 Result := '';
 if Length(arr) = 0 then exit;
 for i := 0 to Length(arr) - 1 do
  begin
   Result := Result + arr[i];
   if i < Length(arr) - 1 then Result := Result + separator;
  end;
end;

//----------------------------------------------------------------------------//
//                      INSERT ITEM TO ARRAY OF STRING                        //
//----------------------------------------------------------------------------//
procedure array_push( var arr:T1darray;item:string);
begin
 SetLength(arr,length(arr) + 1 );
 arr[length(arr) - 1] := item;
end;

procedure intarray_push( var arr:Tintarray;item:integer);
begin
 SetLength(arr,length(arr) + 1 );
 arr[length(arr) - 1] := item;
end;

//----------------------------------------------------------------------------//
//                      Is contains that str?                                 //
//----------------------------------------------------------------------------//
function index_of(arr:T1darray;item:string):integer;
var i:integer;
begin
Result := - 1;
for I := 0 to Length(arr) - 1 do
 begin
 if arr[i] = item then
  begin
   Result := i;
   break;
  end;
 end;
end;

//****************************************************************************//
//****************************************************************************//
//                             RESULTSET STUFF
//****************************************************************************//
//****************************************************************************//

function index_of_result( res: Tresultset; col,Value:string ):Tintarray;
var i,y,z     :integer;
    cols      :T1darray;
    Values    :T1darray;
    hitcount  :integer;
begin
 SetLength(Result,0);
 cols := explode('|',col);
 Values := explode('|',Value);
for i := 0 to Length(res) - 1 do
 begin
  hitcount := 0;
  for y := 0 to Length(cols) - 1 do
   begin
     if res[i].Values[cols[y]] = Values[y] then Inc(hitcount);
   end;
   if hitcount = Length(cols) then
    begin
     intarray_push(Result,i);
    end;
 end;
end;

function group_resultset(res: Tresultset; cols:T1darray):Tresultset;
var i,x,y,z : integer;
    temp_res,orig_result : Tresultset;
    aggreg,hitcount      : integer;
    gr,vals,last_vals    : T1darray;
    c_text: string;
begin
Result := nil;
if Length(res) = 0 then exit;
orig_result := res;
SetLength(vals,Length(cols));
SetLength(last_vals,Length(cols));
for i := 0 to Length(orig_result)- 1 do if index_of(gr,orig_result[i].Values[cols[0]]) = -1 then array_push(gr,orig_result[i].Values[cols[0]]);
for I := 0 to Length(gr) - 1 do
 begin
 for y := 0 to Length(orig_result) - 1 do
  begin
   if orig_result[y].Values[cols[0]] = gr[i] then
    begin
    for x := 0 to Length(cols) - 1 do vals[x] := orig_result[y].Values[cols[x]];
    aggreg := -1;
    for z := 0 to Length(temp_res) - 1 do
     begin
      hitcount := 0;
      for x := 0 to Length(cols) - 1 do if temp_res[z].Values[cols[x]] = vals[x] then Inc( hitcount );
      if hitcount = Length(cols) then aggreg := z;
      end;
      if aggreg > -1 then
       begin
        try
         temp_res[aggreg].Values['AGR_COUNT'] := inttostr(strtoint(temp_res[aggreg].Values['AGR_COUNT']) + 1);
        except
        end;
       end
       else
        begin
         SetLength(temp_res, length(temp_res) + 1);
         x := Length(temp_res) - 1;
         temp_res[x] := TStringList.Create;
         for z := 0 to Length(cols) - 1 do
          begin
           temp_res[x].Values[cols[z]] := vals[z];
          end;
           temp_res[x].Values['AGR_COUNT'] := '1';
        end;
    end;
  end;
 end;
 Result := temp_res;
end;

procedure order_result_by(var res : Tresultset;col:string);
 var i,y,x:integer;
    act,ctrl_act,t,top:string;
    chg:integer;
begin
for I := 0 to Length(res)  - 1  do
 begin
  act := res[i].Values[col];
  chg := 0;
  top := '';
  for y := i to (Length(res)) - 1 do
   begin
    ctrl_act := res[y].Values[col];
    if top = '' then
     begin
      if ctrl_act < act then
      begin
       top := ctrl_act;
       chg := y;
      end;
     end
    else
    begin
    if (ctrl_act < act) and (top >= ctrl_act) then
     begin
      chg := y;
     end;
    end;
   end;
  if chg > 0 then
   begin
    t := res[i].CommaText;
    res[i].CommaText := res[chg].CommaText;
    res[chg].CommaText := t;
   end;
 end;
end;

procedure resultset_to_csv(res : Tresultset; filename:string);
var i,y : integer;
   temp_row:string;
begin
if Length(res) = 0 then exit;
 temp_row := '';
for I := 0 to res[0].Count - 1 do
 begin
  temp_row := temp_row + res[0].Names[i];
  if i < res[0].Count - 1 then  temp_row := temp_row + ';';
 end;
 append_file(filename,temp_row);
 temp_row := '';
for I := 0 to Length(res) - 1 do
 begin
  temp_row := '';
  for y := 0 to res[i].Count - 1 do
   begin
    temp_row := temp_row + res[i].Values[res[i].Names[y]];
    if y < res[i].Count - 1 then  temp_row := temp_row + ';';
   end;
  append_file(filename,temp_row);
 end;
end;

////////////////////////////////////////////////////////////////////////////////
//                                  EXCEL                                     //
////////////////////////////////////////////////////////////////////////////////
function toalpha(n:integer):string;
var a  :string;
  count:integer;
begin
 a := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
 Result := a[n];
end;

procedure excel_from_resultset(Res : Tresultset;filename:string;Open_after:Boolean);
var ExcelApp,WorkBook,WorkSheet:OleVariant;
    i,y:integer;
begin
 try
  ExcelApp:=CreateOleObject('Excel.Application');
  ExcelApp.DisplayAlerts:=false;
  WorkBook:=ExcelApp.WorkBooks.Add;
  WorkSheet:=WorkBook.Worksheets.Item[1];
  WorkSheet.Name:='Teszt';
  WorkSheet.Activate;
  WorkSheet.Select;
  // HEADER
   for I := 0 to Res[0].Count - 1 do
    begin
     WorkSheet.columns[toalpha(i+1)].NumberFormat := '@';
     WorkSheet.Range[toalpha(i+1)+'1',toalpha(i+1)+'1'].Value:=res[0].Names[i];
    end;
  // CONTENT
   for y := 0 to length(res) - 1 do
     begin
     for I := 0 to Res[y].Count - 1 do
      begin
       WorkSheet.Range[toalpha(i+1)+ IntToStr(y+2),toalpha(i+1)+IntToStr(y+2)].Value:=res[y].Values[res[y].Names[i]];
      end;
     end;
  ExcelApp.Range['A1','Z1'].EntireColumn.AutoFit;
  WorkSheet.SaveAs(filename,51);
 except
 WorkSheet.SaveAs(filename,51);
 end;
 WorkBook.Close(SaveChanges:=false);
 WorkSheet:=Unassigned;
 WorkBook:=Unassigned;
 ExcelApp:=Unassigned;
end;

function ConfirmDialog(title,value,yes_caption,no_caption:string):integer;
var msg:TForm;
    i:integer;
    btn:TButton;
    R:TRect;
begin
msg:=CreateMessageDialog(value,mtConfirmation,mbYesNo);
with msg do
try
 Caption:=title;
 TButton(FindComponent('Yes')).Caption:=yes_caption;
 TButton(FindComponent('No')).Caption:=no_caption;
 StyleElements:=[seFont,seClient,seBorder];
  for i:=0 to ComponentCount-1 do
  begin
   if (Components[i] is TButton) then
    begin
     btn:=TButton(Components[i]);
     btn.Default:=btn.ModalResult=mrNo;
     if btn.Default then ActiveControl:=btn;
    end;
  end;
 GetWindowRect(Screen.ActiveForm.Handle,R);
 Left:=R.Left+((R.Right-R.Left) div 2)-(Width div 2);
 Top:=R.Top+((R.Bottom-R.Top) div 2)-(Height div 2);
 Result:=ShowModal;
finally
  Free;
end;
end;

function json_to_resultset(json:string):Tresultset;
var temp1,temp2,temp3:T1darray;
    i,y,x : integer;
begin
 json := Copy(json,2, Length(json) - 3);
 json := StringReplace(json,'"','',[rfReplaceall,Rfignorecase]);
 temp1 := explode('}',json);
 SetLength(Result,length(temp1));
 for I := 0 to Length(temp1) - 1 do
  begin
   Result[i] := TStringList.Create;
   temp2 := explode(',', temp1[i]);
   for y := 0 to Length(temp2) - 1 do
    begin
     if temp2[y] <> '' then
      begin
       temp3 := explode(':',temp2[y]);
       Result[i].Values[StringReplace(temp3[0],'{','',[rfReplaceall,Rfignorecase])] :=  temp3[1];
      end;
    end;
   SetLength(temp3,0);
   SetLength(temp2,0);
  end;
end;

end.
