program UoPilot;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{ Минимальный стек 32 КБ -- значение уходит прямо в заголовок PE. }
{$MINSTACKSIZE 32768}

{ FastMM4 -- первым юнитом: он подменяет менеджер памяти и при любом
  другом месте в uses ругается «Память уже была выделена». }
uses
{$IFnDEF FPC}
{$ELSE}
  Interfaces,
{$ENDIF}
  Windows,
  SysUtils,
  Forms,
  { Патчер VCL из SynWrite: весь файл под IFDEF VER150, то есть работает
    только в Delphi 7. Стоит сразу за Forms -- патчит именно его. }
  VCLFixes in 'VCLFixes.pas',
  Unit1 in 'Unit1.pas' {fmSecondfj},
  FixedTabControl in 'FixedTabControl.pas',
  fmFirst_u in 'fmFirst_u.pas' {fmFirstfj},
  Unit2 in 'Unit2.pas';

{ Ресурсы: значки, курсор WEB_HAND, шесть языковых таблиц, справка,
  звук и lua51.dll. }
{$R res/uopres.rc}

var
  S: string;
  V: Integer;

begin
  IsMultiThread := True;
  Application.Title := '';
  Application.Initialize;
  Application.ProcessMessages;
  Application.CreateForm(TfmFirst, fmFirstfj);
  Application.CreateForm(TfmSecond, fmSecondfj);
  fmSecondfj.ShowInTaskBar := stAlways;
  ShowWindow(Application.Handle, SW_HIDE);
  SetWindowLong(Application.Handle, GWL_EXSTYLE,
    GetWindowLong(Application.Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW);
  if fmSecondfj.miMinToTray.Checked and fmSecondfj.FFlag14E6 then
    ShowWindow(fmSecondfj.Handle, SW_HIDE);
  if (fmSecondfj.edScript <> nil) and fmSecondfj.Visible and
     fmSecondfj.edScript.Visible and fmSecondfj.edScript.Enabled and
     (fmSecondfj.pcAll.ActivePage = fmSecondfj.tsScript) then
    fmSecondfj.edScript.SetFocus;
  if fmSecondfj.tScript.OwnerDraw then
    fmSecondfj.RedrawAllTabs;
  S := StringReplace('2.42', '.', '', [rfReplaceAll]);
  V := StrToInt(S) * 100;
  if V > fmSecondfj.fld_1460 then
  begin
    fmSecondfj.miAboutClick(nil);
    fmSecondfj.fld_1460 := V;
  end;
  try
    Application.Run;
  except
    Application.MessageBox('Неотловленная ошибка', '', 1);
  end;
end.
