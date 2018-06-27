unit FTVSPK_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// $Rev: 52393 $
// File generated on 2017.04.20. 13:52:00 from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\Windows\SysWOW64\ftvspkax.dll (1)
// LIBID: {76602DC1-E50C-469A-B4A9-89D8E7C53054}
// LCID: 0
// Helpfile: 
// HelpString: FabulaTech Virtual Serial Port Kit
// DepndLst: 
//   (1) v2.0 stdole, (C:\Windows\SysWOW64\stdole2.tlb)
// SYS_KIND: SYS_WIN32
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
{$ALIGN 4}

interface

uses Winapi.Windows, System.Classes, System.Variants, System.Win.StdVCL, Vcl.Graphics, Vcl.OleCtrls, Vcl.OleServer, Winapi.ActiveX;
  


// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  FTVSPKMajorVersion = 2;
  FTVSPKMinorVersion = 0;

  LIBID_FTVSPK: TGUID = '{76602DC1-E50C-469A-B4A9-89D8E7C53054}';

  IID_IFTVSPKControl: TGUID = '{67CFF731-5BF3-4042-BA0B-69B259C6AFA9}';
  CLASS_FTVSPKControl: TGUID = '{00B203F7-C096-401B-8F84-AE66A72CEC8F}';
  IID_IFTVSPKPair: TGUID = '{332A412F-6978-4B3A-92FA-692DDB4AFFAD}';
  CLASS_FTVSPKPair: TGUID = '{1C021908-9D04-48C8-B593-CCF53B8D74FE}';
  IID_IFTVSPKPairInfo: TGUID = '{5DE1270C-313A-44C6-958E-252B1424D655}';
  CLASS_FTVSPKPairInfo: TGUID = '{7B691290-A53F-4942-B297-5830903AA882}';

// *********************************************************************//
// Declaration of Enumerations defined in Type Library                    
// *********************************************************************//
// Constants for enum _FtVspk_ErrorCode
type
  _FtVspk_ErrorCode = TOleEnum;
const
  ftvspkErrorOk = $00000000;
  ftvspkErrorServiceUnavailable = $00000001;
  ftvspkErrorServiceInternalError = $00000002;
  ftvspkErrorApiInternalError = $00000003;
  ftvspkErrorInvalidParameter = $00000004;
  ftvspkErrorTrialExpired = $00000064;
  ftvspkErrorLicenseQuotaExceeded = $00000065;
  ftvspkErrorPortLimitExceeded = $00000066;
  ftvspkErrorNoMoreItems = $000000C8;
  ftvspkErrorPortAlreadyExists = $000000C9;
  ftvspkErrorNoSuchPort = $000000CA;

// Constants for enum _FtVspk_LicenseType
type
  _FtVspk_LicenseType = TOleEnum;
const
  ftvspkLicenseDemo = $00000000;
  ftvspkLicenseFull = $00000001;
  ftvspkLicenseOem = $00000002;
  ftvspkLicenseSite = $00000003;

// Constants for enum _FtVspk_SerialPinout
type
  _FtVspk_SerialPinout = TOleEnum;
const
  ftvspkPinoutFull = $00000000;
  ftvspkPinoutPartialRts = $00000001;
  ftvspkPinoutPartialDtr = $00000002;
  ftvspkPinoutLoopback = $00000003;

type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IFTVSPKControl = interface;
  IFTVSPKControlDisp = dispinterface;
  IFTVSPKPair = interface;
  IFTVSPKPairDisp = dispinterface;
  IFTVSPKPairInfo = interface;
  IFTVSPKPairInfoDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  FTVSPKControl = IFTVSPKControl;
  FTVSPKPair = IFTVSPKPair;
  FTVSPKPairInfo = IFTVSPKPairInfo;


// *********************************************************************//
// Declaration of structures, unions and aliases.                         
// *********************************************************************//

  FTVSPKErrorCode = _FtVspk_ErrorCode; 
  FTVSPKLicenseType = _FtVspk_LicenseType; 
  FTVSPKSerialPinout = _FtVspk_SerialPinout; 
  LONG_PTR = Integer; 

// *********************************************************************//
// Interface: IFTVSPKControl
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {67CFF731-5BF3-4042-BA0B-69B259C6AFA9}
// *********************************************************************//
  IFTVSPKControl = interface(IDispatch)
    ['{67CFF731-5BF3-4042-BA0B-69B259C6AFA9}']
    function EnumPhysical: Integer; safecall;
    function EnumPairs: Integer; safecall;
    function GetPhysical(unIndex: Integer): Integer; safecall;
    procedure GetPair(unIndex: Integer; out lpunPortNo1: Integer; out lpunPortNo2: Integer); safecall;
    procedure SetPair(unPortNo1: Integer; unPortNo2: Integer); safecall;
    procedure RemovePair(unPortNo1: Integer; unPortNo2: Integer); safecall;
    procedure RemoveAll; safecall;
    procedure SetLoopback(unPortNo: Integer); safecall;
    procedure RemoveLoopback(unPortNo: Integer); safecall;
    procedure Enable(isEnable: WordBool); safecall;
    function IsEnabled: WordBool; safecall;
    function GetLastError: FTVSPKErrorCode; safecall;
    procedure SetPairEx(Pair: OleVariant); safecall;
    procedure GetPairInfo(unPortNo1: Integer; unPortNo2: Integer; var lpPairInfo: OleVariant); safecall;
    function Get_Version: WideString; safecall;
    function Get_LicenseType: FTVSPKLicenseType; safecall;
    function Get_NumberOfLicenses: Integer; safecall;
    function Get_NumberOfPorts: Integer; safecall;
    function Get_LicensedUser: WideString; safecall;
    function Get_LicensedCompany: WideString; safecall;
    function Get_ExpirationDate: WideString; safecall;
    property Version: WideString read Get_Version;
    property LicenseType: FTVSPKLicenseType read Get_LicenseType;
    property NumberOfLicenses: Integer read Get_NumberOfLicenses;
    property NumberOfPorts: Integer read Get_NumberOfPorts;
    property LicensedUser: WideString read Get_LicensedUser;
    property LicensedCompany: WideString read Get_LicensedCompany;
    property ExpirationDate: WideString read Get_ExpirationDate;
  end;

// *********************************************************************//
// DispIntf:  IFTVSPKControlDisp
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {67CFF731-5BF3-4042-BA0B-69B259C6AFA9}
// *********************************************************************//
  IFTVSPKControlDisp = dispinterface
    ['{67CFF731-5BF3-4042-BA0B-69B259C6AFA9}']
    function EnumPhysical: Integer; dispid 1;
    function EnumPairs: Integer; dispid 2;
    function GetPhysical(unIndex: Integer): Integer; dispid 3;
    procedure GetPair(unIndex: Integer; out lpunPortNo1: Integer; out lpunPortNo2: Integer); dispid 4;
    procedure SetPair(unPortNo1: Integer; unPortNo2: Integer); dispid 5;
    procedure RemovePair(unPortNo1: Integer; unPortNo2: Integer); dispid 6;
    procedure RemoveAll; dispid 7;
    procedure SetLoopback(unPortNo: Integer); dispid 8;
    procedure RemoveLoopback(unPortNo: Integer); dispid 9;
    procedure Enable(isEnable: WordBool); dispid 10;
    function IsEnabled: WordBool; dispid 11;
    function GetLastError: FTVSPKErrorCode; dispid 12;
    procedure SetPairEx(Pair: OleVariant); dispid 13;
    procedure GetPairInfo(unPortNo1: Integer; unPortNo2: Integer; var lpPairInfo: OleVariant); dispid 14;
    property Version: WideString readonly dispid 15;
    property LicenseType: FTVSPKLicenseType readonly dispid 16;
    property NumberOfLicenses: Integer readonly dispid 17;
    property NumberOfPorts: Integer readonly dispid 18;
    property LicensedUser: WideString readonly dispid 19;
    property LicensedCompany: WideString readonly dispid 20;
    property ExpirationDate: WideString readonly dispid 21;
  end;

// *********************************************************************//
// Interface: IFTVSPKPair
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {332A412F-6978-4B3A-92FA-692DDB4AFFAD}
// *********************************************************************//
  IFTVSPKPair = interface(IDispatch)
    ['{332A412F-6978-4B3A-92FA-692DDB4AFFAD}']
    function Get_PortNo1: Integer; safecall;
    procedure Set_PortNo1(pVal: Integer); safecall;
    function Get_PortNo2: Integer; safecall;
    procedure Set_PortNo2(pVal: Integer); safecall;
    function Get_BitrateEmulation: WordBool; safecall;
    procedure Set_BitrateEmulation(pVal: WordBool); safecall;
    function Get_Pinout: FTVSPKSerialPinout; safecall;
    procedure Set_Pinout(pVal: FTVSPKSerialPinout); safecall;
    function Get_DtrToDcd: WordBool; safecall;
    procedure Set_DtrToDcd(pVal: WordBool); safecall;
    function Get_DtrToRi: WordBool; safecall;
    procedure Set_DtrToRi(pVal: WordBool); safecall;
    procedure set_data(Data: LONG_PTR; DataSize: Integer); safecall;
    procedure get_data(Data: LONG_PTR; DataSize: Integer); safecall;
    property PortNo1: Integer read Get_PortNo1 write Set_PortNo1;
    property PortNo2: Integer read Get_PortNo2 write Set_PortNo2;
    property BitrateEmulation: WordBool read Get_BitrateEmulation write Set_BitrateEmulation;
    property Pinout: FTVSPKSerialPinout read Get_Pinout write Set_Pinout;
    property DtrToDcd: WordBool read Get_DtrToDcd write Set_DtrToDcd;
    property DtrToRi: WordBool read Get_DtrToRi write Set_DtrToRi;
  end;

// *********************************************************************//
// DispIntf:  IFTVSPKPairDisp
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {332A412F-6978-4B3A-92FA-692DDB4AFFAD}
// *********************************************************************//
  IFTVSPKPairDisp = dispinterface
    ['{332A412F-6978-4B3A-92FA-692DDB4AFFAD}']
    property PortNo1: Integer dispid 1;
    property PortNo2: Integer dispid 2;
    property BitrateEmulation: WordBool dispid 3;
    property Pinout: FTVSPKSerialPinout dispid 4;
    property DtrToDcd: WordBool dispid 5;
    property DtrToRi: WordBool dispid 6;
    procedure set_data(Data: LONG_PTR; DataSize: Integer); dispid 1610743820;
    procedure get_data(Data: LONG_PTR; DataSize: Integer); dispid 1610743821;
  end;

// *********************************************************************//
// Interface: IFTVSPKPairInfo
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {5DE1270C-313A-44C6-958E-252B1424D655}
// *********************************************************************//
  IFTVSPKPairInfo = interface(IDispatch)
    ['{5DE1270C-313A-44C6-958E-252B1424D655}']
    function Get_Pair: OleVariant; safecall;
    function Get_Enabled: WordBool; safecall;
    function Get_PortOpened1: WordBool; safecall;
    function Get_PortOpened2: WordBool; safecall;
    function Get_Pid1: Integer; safecall;
    function Get_Pid2: Integer; safecall;
    function Get_Overlapped1: WordBool; safecall;
    function Get_Overlapped2: WordBool; safecall;
    procedure set_data(Data: LONG_PTR; DataSize: Integer); safecall;
    procedure get_data(Data: LONG_PTR; DataSize: Integer); safecall;
    property Pair: OleVariant read Get_Pair;
    property Enabled: WordBool read Get_Enabled;
    property PortOpened1: WordBool read Get_PortOpened1;
    property PortOpened2: WordBool read Get_PortOpened2;
    property Pid1: Integer read Get_Pid1;
    property Pid2: Integer read Get_Pid2;
    property Overlapped1: WordBool read Get_Overlapped1;
    property Overlapped2: WordBool read Get_Overlapped2;
  end;

// *********************************************************************//
// DispIntf:  IFTVSPKPairInfoDisp
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {5DE1270C-313A-44C6-958E-252B1424D655}
// *********************************************************************//
  IFTVSPKPairInfoDisp = dispinterface
    ['{5DE1270C-313A-44C6-958E-252B1424D655}']
    property Pair: OleVariant readonly dispid 1;
    property Enabled: WordBool readonly dispid 2;
    property PortOpened1: WordBool readonly dispid 3;
    property PortOpened2: WordBool readonly dispid 4;
    property Pid1: Integer readonly dispid 5;
    property Pid2: Integer readonly dispid 6;
    property Overlapped1: WordBool readonly dispid 7;
    property Overlapped2: WordBool readonly dispid 8;
    procedure set_data(Data: LONG_PTR; DataSize: Integer); dispid 1610743816;
    procedure get_data(Data: LONG_PTR; DataSize: Integer); dispid 1610743817;
  end;

// *********************************************************************//
// The Class CoFTVSPKPair provides a Create and CreateRemote method to          
// create instances of the default interface IFTVSPKPair exposed by              
// the CoClass FTVSPKPair. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFTVSPKPair = class
    class function Create: IFTVSPKPair;
    class function CreateRemote(const MachineName: string): IFTVSPKPair;
  end;

// *********************************************************************//
// The Class CoFTVSPKPairInfo provides a Create and CreateRemote method to          
// create instances of the default interface IFTVSPKPairInfo exposed by              
// the CoClass FTVSPKPairInfo. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFTVSPKPairInfo = class
    class function Create: IFTVSPKPairInfo;
    class function CreateRemote(const MachineName: string): IFTVSPKPairInfo;
  end;


implementation

uses System.Win.ComObj;

class function CoFTVSPKPair.Create: IFTVSPKPair;
begin
  Result := CreateComObject(CLASS_FTVSPKPair) as IFTVSPKPair;
end;

class function CoFTVSPKPair.CreateRemote(const MachineName: string): IFTVSPKPair;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FTVSPKPair) as IFTVSPKPair;
end;

class function CoFTVSPKPairInfo.Create: IFTVSPKPairInfo;
begin
  Result := CreateComObject(CLASS_FTVSPKPairInfo) as IFTVSPKPairInfo;
end;

class function CoFTVSPKPairInfo.CreateRemote(const MachineName: string): IFTVSPKPairInfo;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FTVSPKPairInfo) as IFTVSPKPairInfo;
end;

end.
