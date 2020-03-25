unit caffeineui;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ButtonPanel,
  Menus, StdCtrls, VersionSupport, windows;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonPanelConfirm: TButtonPanel;
    CheckGroupSettings: TCheckGroup;
    MenuItemSettings: TMenuItem;
    MenuItemExit: TMenuItem;
    PopupMenuTrayIcon: TPopupMenu;
    TrayIconCaffeine: TTrayIcon;
    procedure CancelButtonClick(Sender: TObject);
    procedure CheckGroupSettingsItemClick(Sender: TObject; Index: integer);
    procedure CloseButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormWindowStateChange(Sender: TObject);
    procedure HelpButtonClick(Sender: TObject);
    procedure MenuItemSettingsClick(Sender: TObject);
    procedure MenuItemExitClick(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
    procedure TrayIconCaffeineClick(Sender: TObject);
  private

  public

  end;

(* Source Credits: http://delphidabbler.com/tips/127 *)
type
  EXECUTION_STATE = DWORD;

const
  ES_SYSTEM_REQUIRED = $00000001;
  ES_DISPLAY_REQUIRED = $00000002;
  ES_USER_PRESENT = $00000004;
  ES_AWAYMODE_REQUIRED = $00000040;
  ES_CONTINUOUS = $80000000;

procedure SetThreadExecutionState(ESFlags: EXECUTION_STATE);
  stdcall; external kernel32 name 'SetThreadExecutionState';

var
  Form1: TForm1;
  IsFirstShow: Boolean = True;
  PreventDisplaySleep: Boolean = False;
implementation

{$R *.lfm}

function ConfirmClose : Boolean;
begin
  if QuestionDlg('Caffeine', 'Are you sure you want to quit? ' + sLineBreak +
  sLineBreak + 'This will allow your computer to sleep.',
  mtWarning, [mrYes, '&Yes', mrNo, '&No', 'IsDefault'], 0) = mrYes then
    Result := True
  else
    Result := False;
end;

{ TForm1 }

procedure TForm1.TrayIconCaffeineClick(Sender: TObject);
begin
  if Form1.Visible then
    Form1.Hide
  else
    Form1.Show;
end;

procedure TForm1.FormWindowStateChange(Sender: TObject);
begin
  if Form1.WindowState = wsMinimized then
  begin
    Form1.WindowState := wsNormal;
    Form1.Hide;
  end;
end;

procedure TForm1.CloseButtonClick(Sender: TObject);
begin
  Form1.Hide;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if not ConfirmClose then
    CloseAction := caNone;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  (* Prevent sleeping. *)
  SetThreadExecutionState(ES_CONTINUOUS or ES_SYSTEM_REQUIRED);
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  if IsFirstShow then
  begin
    ButtonPanelConfirm.CancelButton.Enabled := False;
    IsFirstShow := False;
  end
  else
  begin
    ButtonPanelConfirm.OKButton.Enabled := False;
  end;
end;

procedure TForm1.CancelButtonClick(Sender: TObject);
begin
  Form1.Hide;
end;

procedure TForm1.CheckGroupSettingsItemClick(Sender: TObject; Index: integer);
begin
  ButtonPanelConfirm.OKButton.Enabled := True;
end;

procedure TForm1.HelpButtonClick(Sender: TObject);
begin
  MessageDlg('Caffeine', 'Caffeine v' + LeftStr(GetFileVersion, 5) + ' © 2020 Kyle Leong' +
  sLineBreak + 'https://github.com/kyleleong/caffeine' + sLineBreak + sLineBreak +
  'Caffeine prevents your computer from going to sleep while it is active. ' +
  'You can quit the program or access its settings at any time from the tray icon.' +
  sLineBreak + sLineBreak + 'Caffeine uses icons from:' + sLineBreak +
  'https://www.famfamfam.com/lab/icons/silk/' + sLineBreak +
  'https://www.flaticon.com/authors/freepik/'
  , mtInformation, [mbOK], 0);
end;

procedure TForm1.MenuItemSettingsClick(Sender: TObject);
begin
  Form1.Show;
end;

procedure TForm1.MenuItemExitClick(Sender: TObject);
begin
  Form1.Close;
end;

procedure TForm1.OKButtonClick(Sender: TObject);
begin
  (* Need to disable and re-enable with correct settings. *)
  SetThreadExecutionState(ES_CONTINUOUS);
  if CheckGroupSettings.Checked[0] then
    SetThreadExecutionState(ES_CONTINUOUS or ES_SYSTEM_REQUIRED or ES_DISPLAY_REQUIRED)
  else
    SetThreadExecutionState(ES_CONTINUOUS or ES_SYSTEM_REQUIRED);
  Form1.Hide;
  Form1.ButtonPanelConfirm.CancelButton.Enabled := True;
end;

end.
