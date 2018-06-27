unit user_class;

interface
uses db_common, System.SysUtils, other_common, user_queries;

  type
    TUser = class

      private
        usr_name, user_id : string;
        LasterMsg         : string;
        _loggedin         : Boolean;
        _perms            : Tresultset;
      public
       function  Login(email,pass:string):boolean;
       function  Logout:boolean;
       property  UserName: string read usr_name;
       property  UserId  : string read user_id;
       property  isLoggedin   : boolean read _loggedin;
       function have_perm(perm_name:string):boolean;
       constructor create;
    end;


implementation

constructor TUser.create;
begin
_loggedin := false;
end;

function TUser.Login(email,pass:string):boolean;
var res : Tresultset;
    passmd5 : string;
begin
res := get_login(email);
if (Length(res) > 0) and (_loggedin = false) then
 begin
  passmd5 :=  MD5(pass);
  if passmd5 = UpperCase(res[0].Values['password']) then
   begin
     usr_name  := res[0].Values['f_name']+' '+res[0].Values['l_name'];
     user_id   := res[0].Values['user_id'];
     _loggedin := True;
     _perms    := get_user_permissions(res[0].Values['user_id']);
     Result := True;
   end else Result := False;
 end else Result := False;
 free_result(res);
end;

function TUser.have_perm(perm_name: string):boolean;
var i : integer;
begin
 result := false;
  for i := 0 to Length(_perms) -1 do
   begin
    if _perms[i].Values['perm_name'] = perm_name then Result := true;
   end;
end;

function TUser.Logout:boolean;
begin
 if _loggedin = true then
  begin
   usr_name  := '';
   user_id   := '';
   free_result(_perms);
   _loggedin := False;
  end;
end;


end.
