unit donwloader_thread_common;

interface
uses System.Classes,db_common,Vcl.ComCtrls,IdHTTP,IdComponent,System.SysUtils;

 type
  TDownloaderEvent = procedure(Sender: TObject) of object;
  TDownloader  = class(TThread)
   private
    prbar      : TProgressBar;
    ht         : TIdHTTP;
    dl_state_ch: TDownloaderEvent;
    dstate     : integer;
    buffer     : TMemoryStream;
    main_url   : string;
    f_name     : string;
    l_error    : string;
    i_max      : Int64;
    i_actual   : Int64;
    procedure st_change(st:integer);
    procedure on_ht_work(ASender:TObject;AWork:TWorkMode; Count: Int64);
    procedure on_ht_begin(ASender:TObject;AWork:TWorkMode; Max: Int64);
  public
   constructor create(url:string; filename:string; pr_bar:TProgressBar);
   procedure Execute; override;
   property  OnStateChange: TDownloaderEvent read dl_state_ch write dl_state_ch;
   property  ActualState  : Integer read dstate;
   function  GetResultString():String;
   property  url : string read main_url;
   property  LastError : string read l_error;
  end;

  const
   DsDstarted     = 0;
   DsDdownloading = 1;
   DsDfinished    = 2;
   DsDfilesaved   = 3;
   DSDerror       = 4;


implementation

constructor TDownloader.create(url:string; filename:string; pr_bar:TProgressBar);
begin
  inherited Create(True);
  FreeOnTerminate:= True;
  dstate := -1;
  buffer := TMemoryStream.Create;
  f_name := filename;
  prbar  := pr_bar;
  main_url := url;
end;

procedure TDownloader.st_change(st:integer);
begin
 dstate := st;
 if Assigned(dl_state_ch) then Synchronize( procedure begin dl_state_ch(Self) end );
end;

procedure TDownloader.execute;
begin
 ht := TIdHTTP.Create(nil);
 ht.OnWork := on_ht_work;
 ht.OnWorkBegin := on_ht_begin;
 buffer.Clear;
 try
  st_change(0);
  st_change(1);
  ht.Get(main_url,buffer);
  st_change(2);
  if f_name <> '' then
   begin
    Synchronize( procedure begin buffer.SaveToFile(f_name) end );
    buffer.Clear;
    st_change(3);
   end;
 except
  on E : Exception do
   begin
    l_error := E.Message;
    st_change(4);
   end;
 end;
 ht.Free;
 buffer.Clear;
 buffer.Free;
 prbar.Position := 0;
end;

procedure TDownloader.on_ht_work(ASender:TObject;AWork:TWorkMode; Count: Int64);
begin
 if prbar <> nil then
  begin
   Synchronize( procedure begin prbar.Position := count end );
  end;
end;

procedure TDownloader.on_ht_begin(ASender:TObject;AWork:TWorkMode; Max: Int64);
begin
 if prbar <> nil then
  begin
   prbar.Max := Max;
   prbar.Min := 0;
   prbar.Position := 0;
  end;
end;

function TDownloader.GetResultString():String;
var str : TStringStream;
begin
 try
  str := TStringStream.Create('');
  str.LoadFromStream(buffer);
  result := str.DataString;
 except
  result := '';
 end;
 str.Clear;
 str.Free;
end;


end.
