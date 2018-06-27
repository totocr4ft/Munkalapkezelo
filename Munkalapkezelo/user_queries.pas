unit user_queries;

interface
uses db_common, other_common;

function get_login(email:string):Tresultset;
function get_user_permissions(userid:string):Tresultset;
function insert_user_from_old():boolean;

implementation

function get_login(email:string):Tresultset;
begin
  Result:= run_query(' select * from users where email = :p1',[email]);
end;

function get_user_permissions(userid:string):Tresultset;
begin
  result := run_query(' select * from user_permissions up  '
                     + 'LEFT JOIN permissions p on up.perm_id = p.perm_id where up.user_id = :p1  ',[userid]);
end;

function insert_user_from_old():boolean;
var res : Tresultset;
    i,y   : integer;
    names, addr: T1darray;

begin
  res := run_query(' select * from user ',[]);
  for I := 0 to Length(res) - 1 do
   begin
    names := explode(' ', res[i].Values['fullname'] );
    if Length(names) = 1 then
     begin
      SetLength(names, 2 );
      names[1] := '';
     end;
    exec_query(' insert into users set '
              +' f_name = :p1, '
              +' l_name = :p2, '
              +' email  = :p3, '
              +' password = :p4, '
              +' nick_name = :p5, '
              +' city     = :p6, '
              +' postcode = :p7, '
              +' country  = :p8, '
              +' phone    = :p9, '
              +' address  = :p10, '
              +' registered = :p11  ',
              [
               names[0],
               names[1],
               res[i].Values['email'],
               res[i].Values['pass'],
               res[i].Values['name'],
               '',
               '',
               'Magyarország',
               res[i].Values['tel'],
               res[i].Values['address'],
               ''
              ]);
   end;

end;


end.
