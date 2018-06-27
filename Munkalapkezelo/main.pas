unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, db_common, Vcl.Grids, other_common,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.UI.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Phys, Data.DB, FireDAC.Comp.Client,
  FireDAC.Comp.DataSet, FireDAC.Phys.MySQL, FireDAC.Phys.MySQLDef,
  FireDAC.VCLUI.Wait, FireDAC.Comp.UI, Vcl.ExtCtrls, Vcl.Imaging.pngimage,
  Vcl.ImgList, Vcl.ComCtrls, Mnk_class, globals, main_common, device_common,
  frxClass, frxDBSet, user_queries;

type
  Tform_main = class(TForm)
    pnl1: TPanel;
    pnl2: TPanel;
    img1: TImage;
    lbl1: TLabel;
    main_page_control: TPageControl;
    ts_device: TTabSheet;
    pnl3: TPanel;
    btn3: TButton;
    bt_devices: TButton;
    btn5: TButton;
    btn6: TButton;
    il1: TImageList;
    grp1: TGroupBox;
    bt_login: TButton;
    bt_logout: TButton;
    GroupBox1: TGroupBox;
    StringGrid1: TStringGrid;
    GroupBox2: TGroupBox;
    bt_new_device: TButton;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    e_device_name: TEdit;
    cb_device_type: TComboBox;
    cb_device_condition: TComboBox;
    Label16: TLabel;
    cb_device_status: TComboBox;
    Label3: TLabel;
    e_device_description: TEdit;
    Label6: TLabel;
    e_device_comment: TEdit;
    Image2: TImage;
    Label7: TLabel;
    Button2: TButton;
    ts_main: TTabSheet;
    Image3: TImage;
    Label8: TLabel;
    frx_device_1: TfrxReport;
    frx_ds_device_1: TfrxDBDataset;
    Label9: TLabel;
    e_device_barcode: TEdit;
    TabSheet1: TTabSheet;
    Image4: TImage;
    Label10: TLabel;
    GroupBox3: TGroupBox;
    StringGrid2: TStringGrid;
    GroupBox4: TGroupBox;
    Button3: TButton;
    Label17: TLabel;
    Image5: TImage;
    Label18: TLabel;
    e_client_name: TEdit;
    Button1: TButton;
    procedure bt_loginClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure bt_logoutClick(Sender: TObject);
    procedure bt_new_deviceClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure bt_devicesClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure StringGrid1DblClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    procedure onlogin(Sender : Tobject);
    procedure onlogout(Sender : Tobject);
  end;

var
  form_main: Tform_main;

implementation
uses user_login, device_form;
{$R *.dfm}

procedure Tform_main.bt_logoutClick(Sender: TObject);
begin
MC.LogoutUser;
end;

procedure Tform_main.bt_new_deviceClick(Sender: TObject);
begin
 form_device_data.DEV_ID := '0';
 form_device_data.Show;
end;

procedure Tform_main.Button1Click(Sender: TObject);
begin
  insert_user_from_old;
end;

procedure Tform_main.Button2Click(Sender: TObject);
begin
 search_devices;
end;

procedure Tform_main.Button3Click(Sender: TObject);
begin
 print_device_datasheet('3');
end;

procedure Tform_main.FormCreate(Sender: TObject);
begin
  MC.onUserLogin := onlogin;
  MC.onUserLogout := onlogout;
end;

procedure Tform_main.onlogin(Sender : Tobject);
begin
 loginusr;
end;

procedure Tform_main.onlogout(Sender: TObject);
begin
 logoutusr;
end;


procedure Tform_main.StringGrid1DblClick(Sender: TObject);
begin
 form_device_data.DEV_ID := getobj(StringGrid1);
 form_device_data.Show;
end;

procedure Tform_main.bt_devicesClick(Sender: TObject);
begin
 ts_device.Visible := true;
 main_page_control.ActivePage := ts_device;
 fill_device_form;
end;

procedure Tform_main.bt_loginClick(Sender: TObject);
begin
 form_login.Edit1.Text := '';
 form_login.Edit2.Text := '';
 form_login.ShowModal;
end;

end.
