unit device_form;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  Vcl.Grids, Vcl.Imaging.pngimage, device_common,other_common, Vcl.Menus;

type
  Tform_device_data = class(TForm)
    pnl3: TPanel;
    Label3: TLabel;
    GroupBox1: TGroupBox;
    e_name: TEdit;
    Label1: TLabel;
    e_description: TMemo;
    Label2: TLabel;
    Image1: TImage;
    cb_type: TComboBox;
    cb_condition: TComboBox;
    Label4: TLabel;
    Label5: TLabel;
    e_comment: TMemo;
    Label7: TLabel;
    Panel1: TPanel;
    Label6: TLabel;
    GroupBox2: TGroupBox;
    e_param_name: TEdit;
    cb_param_type: TComboBox;
    Label8: TLabel;
    Label9: TLabel;
    Button1: TButton;
    StringGrid1: TStringGrid;
    e_barcode: TEdit;
    Label10: TLabel;
    e_in_price: TEdit;
    e_sell_price: TEdit;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    Label11: TLabel;
    Label12: TLabel;
    GroupBox3: TGroupBox;
    ch_user: TCheckBox;
    Image2: TImage;
    BitBtn1: TBitBtn;
    GroupBox4: TGroupBox;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    cb_status: TComboBox;
    msg_box: TGroupBox;
    msg_text: TLabel;
    MainMenu1: TMainMenu;
    Mveletek1: TMenuItem;
    Eszkztrlse1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure StringGrid1DblClick(Sender: TObject);
    procedure cb_param_typeChange(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure Eszkztrlse1Click(Sender: TObject);
  private
    { Private declarations }
  public
     DEV_ID, USER_ID : string;

    { Public declarations }
  end;

var
  form_device_data: Tform_device_data;

implementation

{$R *.dfm}

procedure Tform_device_data.BitBtn2Click(Sender: TObject);
begin
 if DEV_ID <> '0' then print_device_datasheet(DEV_ID);
end;

procedure Tform_device_data.BitBtn3Click(Sender: TObject);
begin
 ins_device;
end;

procedure Tform_device_data.Button1Click(Sender: TObject);
begin
 if (cb_param_type.ItemIndex > -1) and (e_param_name.Text <> '') then
  begin
   addline(StringGrid1, cb_param_type.Text+'|'+e_param_name.Text);
   cb_param_type.ItemIndex := -1;
   e_param_name.Text := '';
  end;
end;

procedure Tform_device_data.cb_param_typeChange(Sender: TObject);
begin
e_param_name.SetFocus;
end;

procedure Tform_device_data.Eszkztrlse1Click(Sender: TObject);
 var b : integer;
begin

 if (DEV_ID <> '0' ) then
 begin
  b := messagedlg('Biztosan törli ezt az eszközt?',mtConfirmation, mbOKCancel, 0);
  del_device(DEV_ID);
  search_devices;
  close;
 end;
end;

procedure Tform_device_data.FormCreate(Sender: TObject);
begin
fill_device_data_form;
end;

procedure Tform_device_data.StringGrid1DblClick(Sender: TObject);
begin
 delline(StringGrid1,StringGrid1.Row);
end;

end.
