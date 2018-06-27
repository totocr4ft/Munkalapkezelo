unit user_login;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  Vcl.StdCtrls, globals;

type
  Tform_login = class(TForm)
    Image1: TImage;
    GroupBox1: TGroupBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    Button2: TButton;
    pnl3: TPanel;
    Label3: TLabel;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  form_login: Tform_login;

implementation
uses main;
{$R *.dfm}

procedure Tform_login.Button1Click(Sender: TObject);
begin
 if MC.LoginUser(Edit1.Text,Edit2.Text) then close
  else
   begin
    Edit2.Text := '';
    ShowMessage('Hibás felhasználó / jelszó');
   end;
end;

end.
