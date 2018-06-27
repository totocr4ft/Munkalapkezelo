//  _____  _   ___   __  __  __  ____  _____  _    _ _      ______  //
// |  __ \| \ | \ \ / / |  \/  |/ __ \|  __ \| |  | | |    |  ____| //
// | |__) |  \| |\ V /  | \  / | |  | | |  | | |  | | |    | |__    //
// |  ___/| . ` | > <   | |\/| | |  | | |  | | |  | | |    |  __|   //
// | |    | |\  |/ . \  | |  | | |__| | |__| | |__| | |____| |____  //
// |_|    |_| \_/_/ \_\ |_|  |_|\____/|_____/ \____/|______|______| //
//                                                                  //
//////////////////////////////////////////////////////////////////////

unit module_control;

interface

uses System.Classes,forms,Vcl.Dialogs,System.SysUtils,IdTCPClient;

type

  Tmodule_conrol = Class

  private
  TCP_CLIENT : TIdTCPClient;
  CONFIG:TStringList;
  function log_dir:string;
   procedure append_file(filename:string;txt:string);
  public
  property conf:TStringList read CONFIG;
   constructor Create(mode:integer);
  // destructor Destroy;
   procedure logger(t:string;msg:string);
  End;

const
  mDev = 0;
  mNormal = 1;

implementation

constructor Tmodule_conrol.Create(mode:integer);
var param:string;
    i : integer;
begin
//************************
 if mode = mDev then
//************************
  begin
   param := '';
   param := param + 'AUTH=ad0fb7c58de9aa63d4d83e7c4022d3a1,';
   param := param + 'DATABASE=PNX_DEV,';
   param := param + 'USER_ID=14655182,';
   param := param + 'MAC=FC:AA:14:0F:DF:87,';
   param := param + 'MOD_ID=42,';
   param := param + 'DEV=DEV,';
   param := param + 'COM1=COM1,';
   param := param + 'PLANT=P412,';
   param := param + 'LOCATION=RW03,';
   param := param + 'PRINTER_A4=Samsung CLP-680 Series (106.114.11.245),';
   param := param + 'PRINTER_LABEL=ZDesigner ZM400 200 dpi (ZPL)';
  end
   else if mode = mNormal then
    begin
     i := 1;
     param := '';
     while ParamStr(i) <> '' do
      begin
       param := param + ParamStr(i);
       Inc(i);
      end;
    end;
  param  := StringReplace(param, '$', ' ', [rfReplaceAll, rfIgnoreCase]);
  CONFIG:=TStringList.Create;
  CONFIG.StrictDelimiter := True;
  CONFIG.CommaText := param;
  if (CONFIG.Values['AUTH'] <> 'ad0fb7c58de9aa63d4d83e7c4022d3a1' )
  or (CONFIG.Values['MOD_ID'] = '') then
  begin
   logger('ER','Launch param error : "'+CONFIG.Values['AUTH']+'"');
   Application.Terminate;
   exit;
  end;

if CONFIG.Values['TCP_PORT'] <> '' then
 begin
  try
   TCP_CLIENT := TIdTCPClient.Create(nil);
   TCP_CLIENT.Port := StrToInt(CONFIG.Values['TCP_PORT']);
   TCP_CLIENT.Host := '127.0.0.1';
   TCP_CLIENT.Connect;
  except
   TCP_CLIENT.Destroy;
   Application.Terminate;
  end;
 end;
end;

procedure Tmodule_conrol.logger(t:string;msg:string);
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
 if TCP_CLIENT <> nil then
  begin
   try
    if not TCP_CLIENT.Connected then TCP_CLIENT.Connect;
    TCP_CLIENT.Socket.WriteLn('TYPE=LOG,MODID='+CONFIG.Values['MOD_ID']+',MSG='+tcp_string);
   except
    //----
   end;
  end;
 end;
end;

procedure Tmodule_conrol.append_file(filename:string;txt:string);
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

function Tmodule_conrol.log_dir:string;
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

