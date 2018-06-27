unit main_control;

interface
uses System.Classes,forms,Vcl.Dialogs,System.SysUtils, db_common;

   type
    TMain_ctrl = Class
     private

     public
      CONFIG : TStringList;
      function log_dir:string;
      procedure logger(t:string;msg:string);
      procedure append_file(filename:string;txt:string);
      constructor Create();
      property conf:TStringList read CONFIG;
    End;

implementation

constructor TMain_ctrl.Create();
var param:string;
    i : integer;
begin
  param  := '';
  param  := param + 'DATABASE=Munkalap';
  param  := StringReplace(param, '$', ' ', [rfReplaceAll, rfIgnoreCase]);
 // CONFIG := TStringList.Create;
 // CONFIG.StrictDelimiter := True;
 // CONFIG.CommaText := param;
end;

procedure TMain_ctrl.logger(t:string;msg:string);
var    actualdir,tcp_string, prefix: string;
begin
if msg = '' then  exit;
tcp_string := StringReplace(msg, ' ', '$', [rfReplaceAll, rfIgnoreCase]);
actualdir := log_dir;
if t = ''   then prefix := FormatDateTime('YYY.MM.dd HH:m:ss', now)+ ' - ';
if t = 'EX' then prefix := FormatDateTime('YYY.MM.dd HH:m:ss', now)+ ' - EXCEPTION: ';
if t = 'ER' then prefix := FormatDateTime('YYY.MM.dd HH:m:ss', now)+ ' - ERROR: ';
if actualdir <> '' then
 begin
  append_file(actualdir+'LOG.txt', prefix + msg);
 end;
end;

procedure TMain_ctrl.append_file(filename:string;txt:string);
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

function TMain_ctrl.log_dir:string;
var f   : TextFile;
    path, new,year,month,day,tcp_string: string;
begin
path  := ExtractFilePath(Application.ExeName);
year  := FormatDateTime('YYYY', now);
month := FormatDateTime('MM', now);
day   := FormatDateTime('DD', now);
try
if not DirectoryExists(path + 'LOG') then MkDir(path + 'LOG');
if not DirectoryExists(path + 'LOG\' + year) then MkDir(path + 'LOG\'+year);
if not DirectoryExists(path + 'LOG\'+  year + '\' + month ) then MkDir(path + 'LOG\'+ year + '\' + month);
if not DirectoryExists(path + 'LOG\' + year + '\' + month + '\' + day ) then MkDir(path + 'LOG\'+ year + '\' + month + '\' + day);
Result := path + 'LOG\'+ year + '\' + month + '\' + day + '\';
except
 on e:Exception do
  begin
   Result := '';
  end;
end;
end;


end.
