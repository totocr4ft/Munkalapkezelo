unit Mnk_class;

interface
uses System.SysUtils, user_class, main_control, Vcl.Dialogs;

  type
    Tmnk_event = procedure(Sender : Tobject) of object;
    Tmnk = class(TMain_ctrl)
     private
       _USER : Tuser;
      _onlogin, _onlogout : Tmnk_event;

     public

      constructor Create();
      function LoginUser(email, pass:string):boolean;
      function HavePermission(perm_name:string):boolean;
      procedure LogoutUser;
      property onUserLogin : Tmnk_event read _onlogin write _onlogin;
      property onUserLogout : Tmnk_event read _onlogout write _onlogout;

    end;


implementation

constructor Tmnk.Create();
begin
 inherited;
 _USER := Tuser.Create;
end;

function Tmnk.LoginUser(email, pass:string):boolean;
begin
Result:= false;
  if _USER.Login(email,pass) then
   begin
     if Assigned(_onlogin) then _onlogin(Self);
     Result := true;
     logger('','USR login: ' + _USER.UserName + ' | '+ email);
   end;
end;

function Tmnk.HavePermission(perm_name:string):boolean;
begin
 Result := _USER.have_perm(perm_name);
end;

procedure Tmnk.LogoutUser;
begin
 logger('','USR logout: ' + _USER.UserName );
 _USER.Logout;
 if Assigned(_onlogout) then _onlogout(Self);
end;




end.
