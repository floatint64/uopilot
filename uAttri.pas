unit uAttri;

{ Диалог настройки подсветки синтаксиса -- целиком строится кодом, без
  своей формы в DFM: набор строк в нём зависит от таблицы атрибутов
  подсветчика, а она правится по ходу дела.

  Unit1 подключён в описаниях (нужны TfmSecond, fmSecond, TSynPasSyn),
  а он подключает нас в реализации -- по-другому взаимную ссылку не
  развести. }

interface

{ Unit1 стоит ПОСЛЕДНИМ: всё, что объявлено и там, и в VCL, должно
  разрешаться в пользу Unit1. }
uses Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, Buttons, Dialogs, Unit1;

type
  { Своих полей нет: класс держит только КЛАССОВЫЕ обработчики, которые
    диалог вешает на созданные им элементы. }
  TAttriFontChange = class(TObject)
  public
    class procedure AttriLabelClick(Sender: TObject);
    class procedure AttriMoveClick(Sender: TObject);
    class procedure AttriAddClick(Sender: TObject);
    class procedure AttriDelClick(Sender: TObject);
    class procedure AttriRWListChange(Sender: TObject);
    class procedure AttriRWListExit(Sender: TObject);
    class procedure AttriApplyClick(Sender: TObject);
  end;

  TAttriFontChangeClass = class of TAttriFontChange;

{ Включение SeDebugPrivilege перед OpenProcess к клиенту UO. }
function SetDebugPrivilege(Enable: Boolean): Boolean;

{ Строит диалог целиком: метки видов подсветки, списки слов и кнопки. }
procedure CreateAttriDialog(Cls: TAttriFontChangeClass);

implementation

function SetDebugPrivilege(Enable: Boolean): Boolean;
var
  hTok: THandle;
  Ret: DWORD;
  TP: TTokenPrivileges;
begin
  Result := False;
  if OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES, hTok) then
  begin
    TP.PrivilegeCount := 1;
    LookupPrivilegeValue(nil, 'SeDebugPrivilege', TP.Privileges[0].Luid);
    if Enable then
      TP.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED
    else
      TP.Privileges[0].Attributes := $80000000;
    AdjustTokenPrivileges(hTok, False, TP, SizeOf(TP),
      PTokenPrivileges(nil)^, Ret);
    if GetLastError = ERROR_SUCCESS then
      Result := True;
    CloseHandle(hTok);
  end;
end;

procedure CreateAttriDialog(Cls: TAttriFontChangeClass);
const
  cdOpts: TColorDialogOptions = [cdFullOpen];
  lbBold: TFontStyles = [fsBold];
var
  I: Integer;
  H: Integer;
  W: Integer;
  X: Integer;
  Cnt: Integer;
  K2: Integer;
  N: Integer;
  Pass2: Integer;
  K: Integer;
  Pass: Integer;
  B, J: Integer;
  V: Integer;
begin

  gDlg596724 := TForm.Create(fmSecond);
  gDlg596724.BorderStyle := bsDialog;
  if gLangOffset > 0 then
    gDlg596724.Caption := LoadStr(gLangOffset + $C9)
  else
    gDlg596724.Caption := 'Подсветка синтаксиса';
  H := $32;
  Cnt := fmSecond.fld_1428.AttrCount - 1;
  W := 0;
  with TColorDialog.Create(fmSecond) do
  begin
    Name := 'cdColorFront';
    Options := cdOpts;
  end;
  with TColorDialog.Create(fmSecond) do
  begin
    Name := 'cdColorBack';
    Options := cdOpts;
  end;
  with TComboBox.Create(fmSecond) do
  begin
    Parent := gDlg596724;
    Left := 0;
    Top := 0;
    Width := 100;
    Name := 'cbRWList';
    Text := '';
    Style := csDropDownList;
    OnChange := Cls.AttriRWListChange;
    OnExit := Cls.AttriRWListExit;
    Visible := False;
  end;
  with TLabel.Create(fmSecond) do
  begin
    Parent := gDlg596724;
    Left := 10;
    Top := 0;
    Caption := '>';
    Name := 'lAttriP';
    Font.Style := lbBold;
    Visible := True;
  end;
  N := 0;
  for Pass := 0 to 1 do
    for I := 0 to Cnt do
    begin
      K := fmSecond.fld_1428.Attribute[I].Kind;
      if (K + Pass = 0) or ((K > 0) and (Pass > 0)) then
      begin
        with TLabel.Create(fmSecond) do
        begin
          Parent := gDlg596724;
          Left := 20;
          Top := N * 18 + 10;
          Caption := fmSecond.fld_1428.Attribute[I].Name;
          ShowHint := True;
          Hint := 'Click to change';
          Tag := N;
          Name := 'lAttri' + IntToStr(N);
          OnClick := Cls.AttriLabelClick;
          H := Top + 18 + 10;
          Font.Style := fmSecond.fld_1428.Attribute[I].Style;
          Font.Color := fmSecond.fld_1428.Attribute[I].Foreground;
          Color := fmSecond.fld_1428.Attribute[I].Background;
          if Width > W then
            W := Width;
        end;
        if K > 0 then
          (fmSecond.FindComponent('cbRWList') as TComboBox).Items.Add(
            fmSecond.fld_1428.Attribute[I].Name);
        Inc(N);
      end;
    end;
  W := W + 10 + 10 + 10;
  X := 0;
  N := 0;
  for Pass2 := 0 to 1 do
    for I := 0 to Cnt do
    begin
      K2 := fmSecond.fld_1428.Attribute[I].Kind;
      if (K2 + Pass2 = 0) or ((K2 > 0) and (Pass2 > 0)) then
      begin
        X := W;
        if K2 > 0 then
          with TComboBox.Create(fmSecond) do
          begin
            Parent := gDlg596724;
            Left := X;
            Top := N * 18 + 10;
            Width := 100;
            Tag := K2;
            Name := 'cbAttri' + IntToStr(K2);
            for Pass := 0 to 255 do
              for K := 0 to Length(
                  TSynPasSyn(fmSecond.fld_1428).KeywordTablePtr^[Pass].Names) - 1 do
                if TSynPasSyn(fmSecond.fld_1428).KeywordTablePtr^[Pass].Kinds[K] = Tag then
                  Items.Add(LowerCase(
                    TSynPasSyn(fmSecond.fld_1428).KeywordTablePtr^[Pass].Names[K]));
            if Items.Count > 0 then
              ItemIndex := 0;
          end;
        X := X + 10 + 100;
        if K2 > 0 then
          with TSpeedButton.Create(fmSecond) do
          begin
            Parent := gDlg596724;
            Left := X;
            Top := N * 18 + 10;
            Width := 40;
            Height := 18;
            Caption := 'move';
            OnClick := Cls.AttriMoveClick;
            Tag := K2;
          end;
        X := X + 40;
        if K2 > 0 then
          with TSpeedButton.Create(fmSecond) do
          begin
            Parent := gDlg596724;
            Left := X;
            Top := N * 18 + 10;
            Width := 40;
            Height := 18;
            Caption := 'add';
            OnClick := Cls.AttriAddClick;
            Tag := K2;
          end;
        X := X + 40;
        if K2 > 0 then
          with TSpeedButton.Create(fmSecond) do
          begin
            Parent := gDlg596724;
            Left := X;
            Top := N * 18 + 10;
            Width := 40;
            Height := 18;
            Caption := 'del';
            OnClick := Cls.AttriDelClick;
            Tag := K2;
          end;
        X := X + 40;
        Inc(N);
      end;
    end;
  with fmSecond.Panel30 do
  begin
    Parent := gDlg596724;
    Left := W;
    Top := 16;
    Visible := True;
  end;
  W := X + 10;
  gDlg596724.ClientHeight := H;
  gDlg596724.ClientWidth := W;
  V := gDlg596724.Width;
  Pass2 := fmSecond.Left - V;
  K := (fmSecond.Height - gDlg596724.Height) div 2 + fmSecond.Top;
  if Pass2 < 0 then
    Pass2 := 0;
  if K < 0 then
    K := 0;
  if Screen.DesktopWidth < V + Pass2 then
    Pass2 := Screen.DesktopWidth - gDlg596724.Width;
  if Screen.DesktopHeight < gDlg596724.Height + K then
    K := Screen.DesktopHeight - gDlg596724.Height;
  gDlg596724.Left := Pass2;
  gDlg596724.Top := K;
  Cls.AttriLabelClick(fmSecond.FindComponent('lAttri0') as TLabel);
  fmSecond.sbAttriChangeApply.OnClick := Cls.AttriApplyClick;
end;

{ Щелчок по метке вида подсветки: её цвета и стиль показываются
  переключателями на главной форме, а сама метка отмечается указателем. }
class procedure TAttriFontChange.AttriLabelClick(Sender: TObject);
var
  L, P: TLabel;
begin
  L := Sender as TLabel;
  if (fsBold in L.Font.Style) or (fsItalic in L.Font.Style) then
  begin
    if fsItalic in L.Font.Style then
    begin
      if fsBold in L.Font.Style then
        fmSecond.rbAttriBI.Checked := True
      else
        fmSecond.rbAttriI.Checked := True;
    end
    else
      fmSecond.rbAttriB.Checked := True;
  end
  else
    fmSecond.rbAttriN.Checked := True;
  if fsUnderline in L.Font.Style then
    fmSecond.cbAttriIU.Checked := True;
  if fsStrikeOut in L.Font.Style then
    fmSecond.cbAttriIS.Checked := True;
  (fmSecond.FindComponent('cdColorFront') as TColorDialog).Color := L.Font.Color;
  (fmSecond.FindComponent('cdColorBack') as TColorDialog).Color := L.Color;
  fmSecond.sbAttriChangeApply.Tag := (Sender as TLabel).Tag;
  P := fmSecond.FindComponent('lAttriP') as TLabel;
  P.Top := (Sender as TLabel).Top;
end;

class procedure TAttriFontChange.AttriMoveClick(Sender: TObject);
var
  S: string;
  K: Integer;
  CB: TComboBox;
begin
  { Кнопка move: слово переезжает из своего списка в общий cbRWList, а сам
    список показывается прямо на месте нажатой кнопки. }
  K := (Sender as TSpeedButton).Tag;
  Sender := Sender;
  CB := fmSecond.FindComponent('cbAttri' + IntToStr(K)) as TComboBox;
  S := CB.Text;
  if S <> '' then
    if TComboBox(CB).Items.IndexOf(S) >= 0 then
    begin
      CB := fmSecond.FindComponent('cbRWList') as TComboBox;
      CB.Left := (Sender as TSpeedButton).Left;
      CB.Top := (Sender as TSpeedButton).Top;
      CB.Tag := K;
      CB.Hint := S;
      CB.Visible := True;
      CB.SetFocus;
    end;
end;

class procedure TAttriFontChange.AttriAddClick(Sender: TObject);
var
  K: Integer;
  CB: TComboBox;
begin
  { Кнопка add: слово из cbAttri<Tag> уходит в таблицу подсветки и в
    список самого комбобокса. Всё под пустым except -- элемента с таким
    именем может и не быть.
    Именно Repaint, а не Invalidate: перекрасить редактор надо сразу. }
  K := (Sender as TSpeedButton).Tag;
  try
    CB := fmSecond.FindComponent('cbAttri' + IntToStr(K)) as TComboBox;
    if AddKeyword(fmSecond.fld_1428, UpperCase(CB.Text), K) then
      CB.Items.Add(CB.Text);
    fmSecond.edScript.Repaint;
  except
  end;
end;

class procedure TAttriFontChange.AttriDelClick(Sender: TObject);
var
  S: string;
  I: Integer;
  CB: TComboBox;
  K: Integer;
begin
  { Кнопка del: слово убирается и из списка, и из таблицы подсветки, а
    выделение сдвигается на существующую строку. }
  K := (Sender as TSpeedButton).Tag;
  CB := fmSecond.FindComponent('cbAttri' + IntToStr(K)) as TComboBox;
  S := CB.Text;
  if S <> '' then
    if CB.Items.IndexOf(S) >= 0 then
    begin
      I := CB.ItemIndex;
      CB.Items.Delete(CB.Items.IndexOf(S));
      while I >= CB.Items.Count do
        Dec(I);
      if I >= 0 then
        CB.ItemIndex := I
      else
        CB.Text := '';
      DeleteKeyword(fmSecond.fld_1428, UpperCase(S));
      fmSecond.edScript.Repaint;
    end;
end;

class procedure TAttriFontChange.AttriRWListChange(Sender: TObject);
var
  S: string;
  Found: Boolean;
  I: Integer;
  K: Integer;
  CB: TComboBox;
begin
  { Выбрали вид подсветки в плавающем списке -- слово переезжает из
    старого вида в новый: сперва добавляем в новый, потом убираем из
    старого, и каждый шаг под своим except. }
  if (Sender as TComboBox).ItemIndex <> -1 then
  begin
    (Sender as TComboBox).Visible := False;
    S := (Sender as TComboBox).Text;
    Found := False;
    K := 0;
    for I := 0 to fmSecond.fld_1428.AttrCount - 1 do
      if S = fmSecond.fld_1428.Attribute[I].Name then
      begin
        K := fmSecond.fld_1428.Attribute[I].Kind;
        Found := True;
        Break;
      end;
    if Found then
    begin
      S := (Sender as TComboBox).Hint;
      try
        with fmSecond.FindComponent('cbAttri' + IntToStr(K)) as TComboBox do
          Items.Add(S);
        AddKeyword(fmSecond.fld_1428, UpperCase(S), K);
      except
      end;
      K := (Sender as TComboBox).Tag;
      try
        CB := fmSecond.FindComponent('cbAttri' + IntToStr(K)) as TComboBox;
        I := CB.ItemIndex;
        CB.Items.Delete(CB.Items.IndexOf(S));
        while I >= CB.Items.Count do
          Dec(I);
        if I >= 0 then
          CB.ItemIndex := I
        else
          CB.Text := '';
      except
      end;
      fmSecond.edScript.Repaint;
      (Sender as TComboBox).ItemIndex := -1;
    end;
  end;
end;

class procedure TAttriFontChange.AttriRWListExit(Sender: TObject);
begin
  { Уход фокуса прячет плавающий список. }
  (Sender as TComboBox).Visible := False;
end;

class procedure TAttriFontChange.AttriApplyClick(Sender: TObject);
const
  fsNone: TFontStyles = [];
  fsB: TFontStyles = [fsBold];
  fsI: TFontStyles = [fsItalic];
  fsU: TFontStyles = [fsUnderline];
  fsS: TFontStyles = [fsStrikeOut];
var
  S: string;
  I: Integer;
  L: TLabel;
begin
  { Кнопка «применить» стоит на ГЛАВНОЙ форме, а не в диалоге: цвета и
    стиль из её элементов ложатся сперва на метку-образец lAttri<Tag>, а
    оттуда -- на атрибут подсветки с тем же именем. }
  L := fmSecond.FindComponent('lAttri' +
    IntToStr(fmSecond.sbAttriChangeApply.Tag)) as TLabel;
  L.Font.Color := (fmSecond.FindComponent('cdColorFront') as TColorDialog).Color;
  L.Color := (fmSecond.FindComponent('cdColorBack') as TColorDialog).Color;
  L.Font.Style := fsNone;
  if fmSecond.rbAttriB.Checked or fmSecond.rbAttriBI.Checked then
    L.Font.Style := L.Font.Style + fsB;
  if fmSecond.rbAttriI.Checked or fmSecond.rbAttriBI.Checked then
    L.Font.Style := L.Font.Style + fsI;
  if fmSecond.cbAttriIU.Checked then
    L.Font.Style := L.Font.Style + fsU;
  if fmSecond.cbAttriIS.Checked then
    L.Font.Style := L.Font.Style + fsS;
  S := L.Caption;
  for I := 0 to fmSecond.fld_1428.AttrCount - 1 do
    if S = fmSecond.fld_1428.Attribute[I].Name then
    begin
      fmSecond.fld_1428.Attribute[I].Style := L.Font.Style;
      fmSecond.fld_1428.Attribute[I].Foreground := L.Font.Color;
      fmSecond.fld_1428.Attribute[I].Background := L.Color;
      Break;
    end;
end;

end.
