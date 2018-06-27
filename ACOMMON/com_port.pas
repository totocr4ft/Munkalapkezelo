unit com_port;

interface

uses System.Classes,forms,VaClasses, VaComm, System.DateUtils, System.SysUtils, System.StrUtils;

 type
 Tonrx    = procedure(datastr:string);
 Tonevent = procedure(Sender:TObject) of object;
 Tarray   = array of string;
 Tcomport = Class
  private
   _LOG : Tarray;
   COM  :TVaComm;
   S_OK :Boolean;
   Ondata:Tonrx;
   _on_error,on_open_ok,_on_close: Tonevent;
   BARCODE,_PORT:String;
   _Name  : string;
   state,usepre  : Boolean;
   procedure log(msg:string);
   procedure incoming(Sender:TObject;Count:integer);

  public
   constructor create(port:string);
   destructor  destroy;
   property    OnPortError : Tonevent read _on_error write _on_error;
   property    OnPortClosed : Tonevent read _on_close write _on_close;
   property    OnPortOpened : Tonevent read on_open_ok write on_open_ok;
   property    OnRxData : Tonrx read  Ondata write Ondata;
   property    UniqueName : string read _Name write _name;
   property    ok : boolean read S_OK;
   property    errors: Tarray read _LOG;
   procedure   manual_scan(b:string);
   property    IsOpened : Boolean read state ;
   function    SendData(d:string):boolean;
   procedure   ClosePort;
   procedure   OpenPort(Portname : string);
   property    ActualPortName : string read _PORT;
   property    UsePrefix      : Boolean read usepre write usepre;

  End;

implementation

Destructor Tcomport.destroy;
begin
 COM.Close;
 COM.Free;
 COM := NIL;
end;

procedure Tcomport.ClosePort;
begin
if Assigned(COM) then
 begin
  COM.Close;
  state := false;
  if Assigned(_on_close) then _on_close(self);
 end;
end;

constructor Tcomport.create(port:string);
begin
usepre := true;
state := false;
_PORT := port;
if port <> '' then
 begin
  try
   COM:=TVaComm.Create(nil);
   COM.Baudrate   := br9600;
   COM.DeviceName := port;
   COM.OnRxChar   := incoming;
   COM.Open;
   S_OK           := True;
   state          := True;
   if Assigned(on_open_ok) then on_open_ok(self);
  except
  on e:Exception do
   begin
    log('Comport open error: '+ e.Message);
    if Assigned(_on_error) then _on_error(self);
    S_OK := False;
    state := false;
   end;
  end;
 end
 else
  begin
   try
    COM:=TVaComm.Create(nil);
    COM.Baudrate   := br9600;
    COM.OnRxChar   := incoming;
    S_OK           := True;
   if Assigned(on_open_ok) then on_open_ok(self);
   except
   on e:Exception do
    begin
     log('Comport open error: '+ e.Message);
     if Assigned(_on_error) then _on_error(self);
     S_OK := False;
     state := false;
    end;
   end;
  end;
end;

procedure Tcomport.OpenPort(Portname:string);
begin
_PORT := Portname;
 try
  COM.Close;
  COM.DeviceName := Portname;
  COM.Open;
  S_OK           := True;
  state          := True;
  if Assigned(on_open_ok) then on_open_ok(self);
 except
 on e:Exception do
  begin
   log('Comport open error: '+ e.Message);
   if Assigned(_on_error) then _on_error(self);
   S_OK := False;
   state := false;
  end;
 end;
end;

procedure Tcomport.log(msg:string);
begin
 SetLength(_LOG, Length(_LOG) + 1);
 _LOG[Length(_LOG) - 1] := FormatDateTime('YYYY-MM-dd hh:nn:ss',now) + ' - ' + msg;
end;

function Tcomport.SendData(d:string):boolean;
begin
if S_OK then
 begin
  Result := COM.WriteText(d);
 end;
end;

procedure Tcomport.incoming(Sender:TObject;Count:integer);
var bc : string;
begin
 BARCODE := BARCODE + COM.ReadText;
if usepre then
 begin
 if RightStr( BARCODE, 1 )= #3 then
  begin
   bc := StringReplace(BARCODE,#3,'', [rfReplaceAll,rfIgnoreCase]);
   bc := StringReplace(bc,#2,'', [rfReplaceAll,rfIgnoreCase]);
   BARCODE := '';
   if Assigned(Ondata) then Ondata(bc);
  end;
 end
 else
  begin
   BARCODE := '';
   if Assigned(Ondata) then Ondata(bc);
  end;
end;

procedure Tcomport.manual_scan(b:string);
begin
 if Assigned(Ondata) then Ondata(b);
end;

end.
