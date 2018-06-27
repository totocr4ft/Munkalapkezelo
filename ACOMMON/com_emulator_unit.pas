unit com_emulator_unit;

interface
uses System.Classes,System.SysUtils,FTVSPK_TLB,System.Win.ComObj;

  type
   TComemuEvent = procedure(Sender: TObject) of object;
   TComEmu = class
     private
      MAIN_EMU_CTRL      : IFTVSPKControl;
      _ONL,_ONACTIVE,_ONERROR,_ON_DEACT : TComemuEvent;
      _LAST_ER,_LAST_LOG : string;
      _N1,_N2            : integer;
      _OK                  : boolean;
      procedure log(t,msg:string);
     public
      function CreatePair(n1,n2:integer):boolean;
      function PairCount:integer;
      constructor create;
      destructor destroy;
      property OnLog       : TComemuEvent read _ONL write _ONL;
      property LastLog     : string read _LAST_LOG;
      property LastError   : string read _LAST_ER;
      property OnActivate  : TComemuEvent read _ONACTIVE write _ONACTIVE;
      property OnDeactivate: TComemuEvent read _ON_DEACT write _ON_DEACT;
      property OnError     : TComemuEvent read _ONERROR write _ONERROR;
      procedure StopEmulation;
   end;

implementation

destructor TComEmu.Destroy;
begin
 if _OK then
  begin
    MAIN_EMU_CTRL.Enable(False);
    MAIN_EMU_CTRL.RemoveAll;
    MAIN_EMU_CTRL._Release;
  end;
end;

procedure TComEmu.StopEmulation;
begin
if _OK then
  begin
   try
    MAIN_EMU_CTRL.Enable(False);
    MAIN_EMU_CTRL.RemoveAll;
    if Assigned(_ON_DEACT) then _ON_DEACT(self);
    log('','Emulation stopped');
   except
    on e:Exception do
     begin
      if Assigned(_ONERROR) then _ONERROR(self);
      log('ER','Deactivation error ' + e.Message);
     end;
   end;
  end;
end;

constructor TComEmu.create;
begin
 // CREATOR
 try
  MAIN_EMU_CTRL := CreateComObject(CLASS_FTVSPKControl) as IFTVSPKControl;
  MAIN_EMU_CTRL.Enable(False);
  MAIN_EMU_CTRL.RemoveAll;
  _OK := True
 except
 on e:Exception do
  begin
   log('ER','Create error ' + e.Message);
   _OK := False;
  end;
 end;
end;

procedure TComEmu.log(t: string; msg: string);
begin
 if t = 'ER' then _LAST_ER := msg;
 _LAST_LOG := msg;
 if Assigned(_ONL) then _ONL(Self);
end;

function TComEmu.CreatePair(n1: Integer; n2: Integer):Boolean;
begin
if _OK then
 begin
  try
   MAIN_EMU_CTRL.SetPair(n1,n2);
   MAIN_EMU_CTRL.Enable(True);
   log('','Pair Created: COM'+ IntToStr(n1)+' ==> COM'+ IntToStr(n2) );
   if Assigned(_ONACTIVE) then _ONACTIVE(self);
   _N1 := n1;
   _N2 := n2;
  except
  on e:Exception do
   begin
    if Assigned(_ONERROR) then _ONERROR(self);
    log('ER','PAIR create error ' + e.Message);
   end;
  end;
 end;
end;

function TComEmu.PairCount:integer;
begin
Result := 0;
if _OK then
 begin
  Result := MAIN_EMU_CTRL.EnumPairs;
 end;
end;




end.
