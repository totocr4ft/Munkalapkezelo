unit hwinfo;

interface

uses Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  shellapi,WbemScripting_TLB,Registry,Winapi.ActiveX, printers,System.Win.ComObj;


type T2DArray = array of array of string;

type
  TWmi = class

  private
    E : array of string;
    FWMIServices: ISWbemServices;
    function GetBIOSserial:string;
    function GetHDDinfo : T2darray;
    function Getmemory : T2DArray;
    function Getnetwork: T2darray;
    function Getprocessor_info :T2darray;
    function Getosinfo():T2DArray;
    function DecodeProductKey(const HexSrc: array of Byte): string;
    function Get_computerinfo : t2darray;


  public
    constructor Create;
    destructor Destroy;
    property BIOS_serial:string read GetBIOSserial;
    property HDD_info:T2DArray read GetHDDinfo;
    property MEMORY_info: T2DArray read Getmemory;
    property NETWORK_info: T2DArray read Getnetwork;
    property PROCESSOR_info: T2DArray read Getprocessor_info;
    property OS_info: T2DArray read Getosinfo;
    property COMP_info: T2DArray read Get_computerinfo;
    function PROCESS_info(proc_name:string) : T2DArray;
    function SERVICE_info(srv_name:string) : T2DArray;
    function IPbyMAC(mac:string):string;
  end;

implementation

//################################################//

///////////////// OS KEY DECODER //////////////////

function TWmi.DecodeProductKey(const HexSrc: array of Byte): string;
const
  StartOffset: Integer = $34;
  EndOffset: Integer   = $34 + 15;
  Digits: array[0..23] of CHAR = ('B', 'C', 'D', 'F', 'G', 'H', 'J','K', 'M', 'P', 'Q', 'R', 'T', 'V', 'W', 'X', 'Y', '2', '3', '4', '6', '7', '8', '9');
  dLen: Integer = 29;
  sLen: Integer = 15;
var
  HexDigitalPID: array of CARDINAL;
  Des: array of CHAR;
  I, N: INTEGER;
  HN, Value: CARDINAL;
begin
  SetLength(HexDigitalPID, dLen);
  for I := StartOffset to EndOffset do
  begin
    HexDigitalPID[I - StartOffSet] := HexSrc[I];
  end;

  SetLength(Des, dLen + 1);

  for I := dLen - 1 downto 0 do
  begin
    if (((I + 1) mod 6) = 0) then
    begin
      Des[I] := '-';
    end
    else
    begin
      HN := 0;
      for N := sLen - 1 downto 0 do
      begin
        Value := (HN shl 8) or HexDigitalPID[N];
        HexDigitalPID[N] := Value div 24;
        HN    := Value mod 24;
      end;
      Des[I] := Digits[HN];
    end;
  end;
  Des[dLen] := Chr(0);

  for I := 0 to Length(Des) do
  begin
    Result := Result + Des[I];
  end;
end;

/////////////////////////////////////////////////////////////////////////////////////////////////

constructor TWmi.Create;
begin
 CoInitialize(nil);
end;

destructor TWmi.Destroy;
begin
  CoUninitialize;
  inherited Destroy;
end;

function TWmi.PROCESS_info(proc_name:string):t2darray;
const
  WbemUser            ='';
  WbemPassword        ='';
  WbemComputer        ='localhost';
  wbemFlagForwardOnly = $00000020;
var
  FSWbemLocator : OLEVariant;
  FWMIService   : OLEVariant;
  FWbemObjectSet: OLEVariant;
  FWbemObject   : OLEVariant;
  oEnum         : IEnumvariant;
  iValue        : LongWord;
  res           : T2DArray;
  i             : integer;
begin;
  try
   FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
   FWMIService   := FSWbemLocator.ConnectServer(WbemComputer, 'root\CIMV2', WbemUser, WbemPassword);
   FWbemObjectSet:= FWMIService.ExecQuery('SELECT * FROM Win32_Process where Name = "'+proc_name+'"','WQL',wbemFlagForwardOnly);
   oEnum         := IUnknown(FWbemObjectSet._NewEnum) as IEnumVariant;
  except
   on e:Exception do
    begin
     SetLength(res,1);
     SetLength(res[0],5);
     res[0,0] := 'ERROR: ' + E.Message;
     res[0,1] := 'ERROR: ' + E.Message;
     res[0,2] := 'ERROR: ' + E.Message;
     res[0,3] := 'ERROR: ' + E.Message;
     res[0,4] := 'ERROR: ' + E.Message;
     result := res;
     exit;
    end;
  end;
  SetLength(res,1);
  i := 0;
  while oEnum.Next(1, FWbemObject, iValue) = 0 do
  begin
    if i > 0 then SetLength(res,i+1);
    SetLength(res[i],5);
    try
    res[i,0] := String(FWbemObject.Caption);
    res[i,1] := String(FWbemObject.CreationDate);
    res[i,2] := String(FWbemObject.CSName);
    res[i,3] := String(FWbemObject.Handle);
    res[i,4] := String(FWbemObject.ThreadCount);
    finally
    FWbemObject:=Unassigned;
    end;
    inc(i)
  end;
    result:=res;
end;

function TWmi.SERVICE_info(srv_name:string):t2darray;
const
  WbemUser            ='';
  WbemPassword        ='';
  WbemComputer        ='localhost';
  wbemFlagForwardOnly = $00000020;
var
  FSWbemLocator : OLEVariant;
  FWMIService   : OLEVariant;
  FWbemObjectSet: OLEVariant;
  FWbemObject   : OLEVariant;
  oEnum         : IEnumvariant;
  iValue        : LongWord;
  res           : T2DArray;
  i             : integer;
begin;
  try
  FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
  FWMIService   := FSWbemLocator.ConnectServer(WbemComputer, 'root\CIMV2', WbemUser, WbemPassword);
  FWbemObjectSet:= FWMIService.ExecQuery('SELECT * FROM Win32_Service where Name = "'+srv_name+'"','WQL',wbemFlagForwardOnly);
  oEnum         := IUnknown(FWbemObjectSet._NewEnum) as IEnumVariant;
  except
   on e:Exception do
    begin
     SetLength(res,1);
     SetLength(res[0],3);
     res[0,0] := 'ERROR: ' + E.Message;
     res[0,1] := 'ERROR: ' + E.Message;
     res[0,2] := 'ERROR: ' + E.Message;
     result := res;
     exit;
    end;
  end;
  SetLength(res,1);
  i := 0;
  while oEnum.Next(1, FWbemObject, iValue) = 0 do
  begin
    if i > 0 then SetLength(res,i+1);
    SetLength(res[i],3);
    try
    res[i,0] := String(FWbemObject.Caption);
    res[i,1] := String(FWbemObject.Started);
    res[i,2] := String(FWbemObject.Name);
    finally
    FWbemObject:=Unassigned;
    end;
    inc(i)
  end;
    result:=res;
end;

function TWmi.GetBIOSserial;
const
  WbemUser            ='';
  WbemPassword        ='';
  WbemComputer        ='localhost';
  wbemFlagForwardOnly = $00000020;
var
  FSWbemLocator : OLEVariant;
  FWMIService   : OLEVariant;
  FWbemObjectSet: OLEVariant;
  FWbemObject   : OLEVariant;
  oEnum         : IEnumvariant;
  iValue        : LongWord;
  res           : string;
  i             : integer;
begin;
  try
  FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
  FWMIService   := FSWbemLocator.ConnectServer(WbemComputer, 'root\CIMV2', WbemUser, WbemPassword);
  FWbemObjectSet:= FWMIService.ExecQuery('SELECT * FROM Win32_BIOS','WQL',wbemFlagForwardOnly);
  oEnum         := IUnknown(FWbemObjectSet._NewEnum) as IEnumVariant;
  except
   on e:Exception do
    begin
     res := 'ERROR: ' + E.Message;
     result := res;
     exit;
    end;
  end;

  while oEnum.Next(1, FWbemObject, iValue) = 0 do
  begin
    res:=  String(FWbemObject.SerialNumber);// Array of String
    FWbemObject:=Unassigned;
  end;
    result:=res;
end;

function TWmi.GetHDDinfo():T2DArray;
const
  WbemUser            ='';
  WbemPassword        ='';
  WbemComputer        ='localhost';
  wbemFlagForwardOnly = $00000020;
var
  FSWbemLocator : OLEVariant;
  FWMIService   : OLEVariant;
  FWbemObjectSet: OLEVariant;
  FWbemObject   : OLEVariant;
  oEnum         : IEnumvariant;
  iValue        : LongWord;
  res           : T2DArray;
  i             : integer;
begin;
  try
  FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
  FWMIService   := FSWbemLocator.ConnectServer(WbemComputer, 'root\CIMV2', WbemUser, WbemPassword);
  FWbemObjectSet:= FWMIService.ExecQuery('SELECT * FROM Win32_DiskDrive where MediaType="Fixed hard disk media"','WQL',wbemFlagForwardOnly);
  oEnum         := IUnknown(FWbemObjectSet._NewEnum) as IEnumVariant;
  except
   on e:Exception do
    begin
     SetLength(res,1);
     SetLength(res[0],3);
     res[0,0] := 'ERROR: ' + E.Message;
     res[0,1] := 'ERROR: ' + E.Message;
     res[0,2] := 'ERROR: ' + E.Message;
     result := res;
     exit;
    end;
  end;
  SetLength(res,1);
  i := 0;
  while oEnum.Next(1, FWbemObject, iValue) = 0 do
  begin
    if i > 0 then SetLength(res,i+1);
    SetLength(res[i],3);
    try
    res[i,0] := String(FWbemObject.Model);
    res[i,1] := String(FWbemObject.SerialNumber);
    res[i,2] := String(FWbemObject.Size);
    finally
    FWbemObject:=Unassigned;
    end;
    inc(i)
  end;
    result:=res;
end;

function TWmi.Getmemory():T2DArray;
const
  WbemUser            ='';
  WbemPassword        ='';
  WbemComputer        ='localhost';
  wbemFlagForwardOnly = $00000020;
var
  FSWbemLocator : OLEVariant;
  FWMIService   : OLEVariant;
  FWbemObjectSet: OLEVariant;
  FWbemObject   : OLEVariant;
  oEnum         : IEnumvariant;
  iValue        : LongWord;
  res           : T2DArray;
  i             : integer;
begin;
  try
  FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
  FWMIService   := FSWbemLocator.ConnectServer(WbemComputer, 'root\CIMV2', WbemUser, WbemPassword);
  FWbemObjectSet:= FWMIService.ExecQuery('SELECT * FROM Win32_PhysicalMemory','WQL',wbemFlagForwardOnly);
  oEnum         := IUnknown(FWbemObjectSet._NewEnum) as IEnumVariant;
  except
   on e:Exception do
    begin
     SetLength(res,1);
     SetLength(res[0],3);
     res[0,0] := 'ERROR: ' + E.Message;
     res[0,1] := 'ERROR: ' + E.Message;
     res[0,2] := 'ERROR: ' + E.Message;
     result := res;
     exit;
    end;
  end;
  SetLength(res,1);
  i := 0;
  while oEnum.Next(1, FWbemObject, iValue) = 0 do
  begin
    if i > 0 then SetLength(res,i+1);
    SetLength(res[i],3);
    try
    res[i,0] := String(FWbemObject.Banklabel);
    res[i,1] := String(FWbemObject.SerialNumber);
    res[i,2] := String(FWbemObject.Capacity);
    finally
    FWbemObject:=Unassigned;
    end;
    inc(i)
  end;
    result:=res;
end;

function TWmi.Getnetwork():T2DArray;
const
  WbemUser            ='';
  WbemPassword        ='';
  WbemComputer        ='localhost';
  wbemFlagForwardOnly = $00000020;
var
  FSWbemLocator : OLEVariant;
  FWMIService   : OLEVariant;
  FWbemObjectSet: OLEVariant;
  FWbemObject   : OLEVariant;
  oEnum         : IEnumvariant;
  iValue        : LongWord;
  res           : T2DArray;
  i             : integer;
  temp          : array of string;

begin;
  try
  FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
  FWMIService   := FSWbemLocator.ConnectServer(WbemComputer, 'root\CIMV2', WbemUser, WbemPassword);
  FWbemObjectSet:= FWMIService.ExecQuery('SELECT * FROM Win32_NetworkAdapterConfiguration where Ipenabled = True','WQL',wbemFlagForwardOnly);
  oEnum         := IUnknown(FWbemObjectSet._NewEnum) as IEnumVariant;
  except
   on e:Exception do
    begin
     SetLength(res,1);
     SetLength(res[0],2);
     res[0,0] := 'ERROR: ' + E.Message;
     res[0,1] := 'ERROR: ' + E.Message;
     result := res;
     exit;
    end;
  end;
  SetLength(res,1);
  i := 0;
  while oEnum.Next(1, FWbemObject, iValue) = 0 do
  begin
    if i > 0 then SetLength(res,i+1);
    SetLength(res[i],2);
    try
      temp     := FWbemObject.IPaddress;
      res[i,0] := temp[0];
      res[i,1] := String(FWbemObject.Macaddress);
    finally
     FWbemObject:=Unassigned;
    end;
    inc(i)
  end;
    result:=res;
end;

function TWmi.IPbyMAC(mac:string):string;
const
  WbemUser            ='';
  WbemPassword        ='';
  WbemComputer        ='localhost';
  wbemFlagForwardOnly = $00000020;
var
  FSWbemLocator : OLEVariant;
  FWMIService   : OLEVariant;
  FWbemObjectSet: OLEVariant;
  FWbemObject   : OLEVariant;
  oEnum         : IEnumvariant;
  iValue        : LongWord;
  res           : T2DArray;
  i             : integer;
  temp          : array of string;

begin;
  if mac = '' then exit;
  try
  FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
  FWMIService   := FSWbemLocator.ConnectServer(WbemComputer, 'root\CIMV2', WbemUser, WbemPassword);
  FWbemObjectSet:= FWMIService.ExecQuery('SELECT * FROM Win32_NetworkAdapterConfiguration where Macaddress="'+mac+'"','WQL',wbemFlagForwardOnly);
  oEnum         := IUnknown(FWbemObjectSet._NewEnum) as IEnumVariant;
  except
   on e:Exception do
    begin
     SetLength(res,1);
     SetLength(res[0],1);
     res[0,0] := 'ERROR: ' + E.Message;
     result := res[0,0];
     exit;
    end;
  end;
  SetLength(res,1);
  SetLength(res[0],1);
  i := 0;
  while oEnum.Next(1, FWbemObject, iValue) = 0 do
  begin
    try
    res[0]:= FWbemObject.Ipaddress;// Array of String
    finally
    FWbemObject:=Unassigned;
    end;
  end;
    result:=res[0,0];
end;

function TWmi.Getprocessor_info():T2DArray;
const
  WbemUser            ='';
  WbemPassword        ='';
  WbemComputer        ='localhost';
  wbemFlagForwardOnly = $00000020;
var
  FSWbemLocator : OLEVariant;
  FWMIService   : OLEVariant;
  FWbemObjectSet: OLEVariant;
  FWbemObject   : OLEVariant;
  oEnum         : IEnumvariant;
  iValue        : LongWord;
  res           : T2DArray;
  i             : integer;
begin;
  try
  FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
  FWMIService   := FSWbemLocator.ConnectServer(WbemComputer, 'root\CIMV2', WbemUser, WbemPassword);
  FWbemObjectSet:= FWMIService.ExecQuery('SELECT * FROM Win32_Processor','WQL',wbemFlagForwardOnly);
  oEnum         := IUnknown(FWbemObjectSet._NewEnum) as IEnumVariant;
  except
   on e:Exception do
    begin
     SetLength(res,1);
     SetLength(res[0],4);
     res[0,0] := 'ERROR: ' + E.Message;
     res[0,1] := 'ERROR: ' + E.Message;
     res[0,2] := 'ERROR: ' + E.Message;
     res[0,3] := 'ERROR: ' + E.Message;
     result := res;
     exit;
    end;
  end;

  SetLength(res,1);
  i := 0;
  while oEnum.Next(1, FWbemObject, iValue) = 0 do
  begin
    if i > 0 then SetLength(res,i+1);
    SetLength(res[i],4);
    try
     res[i,0] := String(FWbemObject.DataWidth);
     res[i,1] := String(FWbemObject.Name);
     res[i,2] := String(FWbemObject.NumberOfCores);
     res[i,3] := String(FWbemObject.ProcessorId);
    finally
    FWbemObject:=Unassigned;
    end;
    inc(i)
  end;
  result:=res;
end;

function TWmi.Get_computerinfo():T2DArray;
const
  WbemUser            ='';
  WbemPassword        ='';
  WbemComputer        ='localhost';
  wbemFlagForwardOnly = $00000020;
var
  FSWbemLocator : OLEVariant;
  FWMIService   : OLEVariant;
  FWbemObjectSet: OLEVariant;
  FWbemObject   : OLEVariant;
  oEnum         : IEnumvariant;
  iValue        : LongWord;
  res           : T2DArray;
  i             : integer;
begin;
  try
  FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
  FWMIService   := FSWbemLocator.ConnectServer(WbemComputer, 'root\CIMV2', WbemUser, WbemPassword);
  FWbemObjectSet:= FWMIService.ExecQuery('SELECT * FROM Win32_ComputerSystem','WQL',wbemFlagForwardOnly);
  oEnum         := IUnknown(FWbemObjectSet._NewEnum) as IEnumVariant;
  except
   on e:Exception do
    begin
     SetLength(res,1);
     SetLength(res[0],4);
     res[0,0] := 'ERROR: ' + E.Message;
     res[0,1] := 'ERROR: ' + E.Message;
     result := res;
     exit;
    end;
  end;

  SetLength(res,1);
  i := 0;
  while oEnum.Next(1, FWbemObject, iValue) = 0 do
  begin
    if i > 0 then SetLength(res,i+1);
    SetLength(res[i],2);
    try
     res[i,0] := String(FWbemObject.Caption);
     res[i,1] := String(FWbemObject.UserName);
    finally
     FWbemObject:=Unassigned;
    end;
    inc(i)
  end;
  result:=res;
end;

function TWmi.Getosinfo():T2DArray;
const
  WbemUser            ='';
  WbemPassword        ='';
  WbemComputer        ='localhost';
  wbemFlagForwardOnly = $00000020;
var
  FSWbemLocator : OLEVariant;
  FWMIService   : OLEVariant;
  FWbemObjectSet: OLEVariant;
  FWbemObject   : OLEVariant;
  oEnum         : IEnumvariant;
  iValue        : LongWord;
  res           : T2DArray;
  i             : integer;
  temp          : array of string;
  KeyName, KeyName2, SubKeyName, PN, PID, DN,clear_key,keypart,temp_str,temp_val: string;
  Reg: TRegistry;
  binarySize: INTEGER;
  HexBuf: array of BYTE;
begin;
  try
   FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
   FWMIService   := FSWbemLocator.ConnectServer(WbemComputer, 'root\CIMV2', WbemUser, WbemPassword);
   FWbemObjectSet:= FWMIService.ExecQuery('SELECT * FROM Win32_OperatingSystem','WQL',wbemFlagForwardOnly);
   oEnum         := IUnknown(FWbemObjectSet._NewEnum) as IEnumVariant;
   SetLength(res,1);
   i := 0;
  while oEnum.Next(1, FWbemObject, iValue) = 0 do
  begin
    if i > 0 then SetLength(res,i+1);
    SetLength(res[i],4);
    try
      res[i,0] := String(FWbemObject.Caption);
      temp     := FWbemObject.MUILanguages;
      res[i,1] :=  temp[0];
      res[i,2] := String(FWbemObject.OSArchitecture);
    finally
     FWbemObject:=Unassigned;
    end;
    inc(i)
  end;
  except
   on e:Exception do
    begin
     SetLength(res,1);
     SetLength(res[0],4);
     res[0,0] := 'ERROR: ' + E.Message;
     res[0,1] := 'ERROR: ' + E.Message;
     res[0,2] := 'ERROR: ' + E.Message;
    end;
  end;

 try
  Reg := TRegistry.Create(KEY_WRITE OR KEY_WOW64_64KEY);
  Reg.RootKey := HKEY_LOCAL_MACHINE;

  if Reg.OpenKeyReadOnly('\SOFTWARE\Microsoft\Windows NT\CurrentVersion') then
  begin
    if Reg.GetDataType('DigitalProductId') = rdBinary then
    begin
      PN         := (Reg.ReadString('ProductName'));
      PID        := (Reg.ReadString('ProductID'));
      binarySize := Reg.GetDataSize('DigitalProductId');
      SetLength(HexBuf, binarySize);
      if binarySize > 0 then
      begin
        Reg.ReadBinaryData('DigitalProductId', HexBuf[0], binarySize);
      end;
    end;
  end;
 except

 end;
    res[0,3] := Copy(DecodeProductKey(HexBuf), 1, 29);
    result:=res;
end;


end.
