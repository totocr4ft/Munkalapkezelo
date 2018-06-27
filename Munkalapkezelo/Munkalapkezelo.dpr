program Munkalapkezelo;

uses
  Vcl.Forms,
  main in 'main.pas' {form_main},
  Vcl.Themes,
  Vcl.Styles,
  globals in '..\ACOMMON\globals.pas',
  db_common in '..\ACOMMON\db_common.pas',
  main_control in 'main_control.pas',
  other_common in '..\ACOMMON\other_common.pas',
  hwinfo in '..\ACOMMON\hwinfo.pas',
  user_class in 'user\user_class.pas',
  user_queries in 'user_queries.pas',
  Mnk_class in 'appctrl\Mnk_class.pas',
  user_login in 'user\user_login.pas' {form_login},
  main_common in 'main_common.pas',
  device_form in 'devices\device_form.pas' {form_device_data},
  device_common in 'devices\device_common.pas',
  device_queries in 'devices\device_queries.pas';

{$R *.res}

begin
  MC := Tmnk.Create;
  //DEV MODE
  MC.logDB := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Smokey Quartz Kamri');
  Application.CreateForm(Tform_main, form_main);
  Application.CreateForm(Tform_login, form_login);
  Application.CreateForm(Tform_device_data, form_device_data);
  Application.Run;
end.
