unit globals;

interface
uses main_control, Mnk_class, Vcl.Consts, Vcl.StdCtrls, Vcl.Graphics;
  var MC : Tmnk;

procedure msg(msgtext:TLabel; t, msg:string);

implementation

procedure msg(msgtext:TLabel; t, msg:string);
begin
if t = 'E' then
 begin
  msgtext.Font.Color := clred;
  msgtext.caption := msg;
  MC.logger('ER', 'MSG FOR USR: ' + msg);
 end else
  begin
    msgtext.Font.Color := clGreen;
    msgtext.caption := msg;
    MC.logger('', 'MSG FOR USR: ' + msg);
  end;
end;

end.
