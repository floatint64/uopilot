unit AttriFont;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{ Диалог настройки подсветки синтаксиса -- целиком строится кодом, без
  своей формы в DFM: набор строк в нём зависит от таблицы атрибутов
  подсветчика, а она правится по ходу дела.

  Unit1 подключён в описаниях (нужны TfmSecond, fmSecondfj и TSynUOPilotSyn),
  а он подключает нас в реализации -- по-другому взаимную ссылку не
  развести. }

interface

uses Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, Buttons, Dialogs, Unit1, SynEditHighlighter,
  SynHighlighterUOPilot, ExtCtrls;

type
  { Своих полей нет: класс держит только КЛАССОВЫЕ обработчики, которые
    диалог вешает на созданные им элементы. Обработчику никакого состояния
    и не нужно -- всё лежит на самой форме. }
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

{ Строит диалог целиком: метки видов подсветки, списки слов и кнопки к
  ним. Sender не нужен, но объявлен -- вешается это прямо на пункт меню. }
procedure CreateAttriDialog(Cls: TAttriFontChangeClass; Sender: TObject);

implementation

procedure CreateAttriDialog(Cls: TAttriFontChangeClass; Sender: TObject);
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
begin

  gDlg596724bt := TForm.Create(fmSecondfj);
  gDlg596724bt.BorderStyle := bsDialog;
  if gLangOffsety > 0 then
    gDlg596724bt.Caption := LoadStr(gLangOffsety + $C9)
  else
    gDlg596724bt.Caption := 'Подсветка синтаксиса';
  H := $32;
  Cnt := fmSecondfj.fld_1428.AttrCount - 1;
  W := 0;
  with TColorDialog.Create(fmSecondfj) do
  begin
    Name := 'cdColorFront';
    { В Delphi свойство Options с флагом cdFullOpen раскрывает полный
      диалог с дополнительными цветами. В LCL до версии 4.0 (в т.ч. в
      Lazarus 2.0.12) у TColorDialog нет ни Options, ни cdFullOpen --
      полный диалог открывается всегда. Оставляем строку только для Delphi. }
    {$IFNDEF FPC}
    Options := [cdFullOpen];
    {$ENDIF}
  end;
  with TColorDialog.Create(fmSecondfj) do
  begin
    Name := 'cdColorBack';
    { В Delphi свойство Options с флагом cdFullOpen раскрывает полный
      диалог с дополнительными цветами. В LCL до версии 4.0 (в т.ч. в
      Lazarus 2.0.12) у TColorDialog нет ни Options, ни cdFullOpen --
      полный диалог открывается всегда. Оставляем строку только для Delphi. }
    {$IFNDEF FPC}
    Options := [cdFullOpen];
    {$ENDIF}
  end;
  with TComboBox.Create(fmSecondfj) do
  begin
    Parent := gDlg596724bt;
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
  with TLabel.Create(fmSecondfj) do
  begin
    Parent := gDlg596724bt;
    Left := 10;
    Top := 0;
    Caption := '>';
    Name := 'lAttriP';
    Font.Style := [fsBold];
    Visible := True;
  end;
  N := 0;
  for Pass := 0 to 1 do
    for I := 0 to Cnt do
    begin
        K := TSynUOAttributes(fmSecondfj.fld_1428.Attribute[I]).Kind;
      if (K + Pass = 0) or ((K > 0) and (Pass > 0)) then
      begin
        with TLabel.Create(fmSecondfj) do
        begin
          Parent := gDlg596724bt;
          Left := 20;
          Top := N * 18 + 10;
          Caption := fmSecondfj.fld_1428.Attribute[I].Name;
          ShowHint := True;
          Hint := 'Click to change';
          Tag := N;
          Name := 'lAttri' + IntToStr(N);
          OnClick := Cls.AttriLabelClick;
          H := Top + 18 + 10;
          Font.Style := fmSecondfj.fld_1428.Attribute[I].Style;
          Font.Color := fmSecondfj.fld_1428.Attribute[I].Foreground;
          Color := fmSecondfj.fld_1428.Attribute[I].Background;
          if Width > W then
            W := Width;
        end;
        if K > 0 then
          (fmSecondfj.FindComponent('cbRWList') as TComboBox).Items.Add(
            fmSecondfj.fld_1428.Attribute[I].Name);
        Inc(N);
      end;
    end;
  W := W + 10 + 10 + 10;
  X := 0;
  N := 0;
  for Pass2 := 0 to 1 do
    for I := 0 to Cnt do
    begin
      K2 := TSynUOAttributes(fmSecondfj.fld_1428.Attribute[I]).Kind;
      if (K2 + Pass2 = 0) or ((K2 > 0) and (Pass2 > 0)) then
      begin
        X := W;
        if K2 > 0 then
          with TComboBox.Create(fmSecondfj) do
          begin
            Parent := gDlg596724bt;
            Left := X;
            Top := N * 18 + 10;
            Width := 100;
            Tag := K2;
            Name := 'cbAttri' + IntToStr(K2);
            for Pass := 0 to 255 do
              for K := 0 to Length(
                  TSynUOPilotSyn(fmSecondfj.fld_1428).KeywordTablePtr^[Pass].Names) - 1 do
                if TSynUOPilotSyn(fmSecondfj.fld_1428).KeywordTablePtr^[Pass].Kinds[K] = Tag then
                  Items.Add(LowerCase(
                    TSynUOPilotSyn(fmSecondfj.fld_1428).KeywordTablePtr^[Pass].Names[K]));
            if Items.Count > 0 then
              ItemIndex := 0;
          end;
        X := X + 10 + 100;
        if K2 > 0 then
          with TSpeedButton.Create(fmSecondfj) do
          begin
            Parent := gDlg596724bt;
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
          with TSpeedButton.Create(fmSecondfj) do
          begin
            Parent := gDlg596724bt;
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
          with TSpeedButton.Create(fmSecondfj) do
          begin
            Parent := gDlg596724bt;
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
  with fmSecondfj.Panel30 do
  begin
    Parent := gDlg596724bt;
    Left := W;
    Top := 16;
    Visible := True;
  end;
  W := X + 10;
  gDlg596724bt.ClientHeight := H;
  gDlg596724bt.ClientWidth := W;
  { Ставим диалог слева от главного окна, но не даём ему уехать за край
    рабочего стола. }
  Pass2 := fmSecondfj.Left - gDlg596724bt.Width;
  K := (fmSecondfj.Height - gDlg596724bt.Height) div 2 + fmSecondfj.Top;
  if Pass2 < 0 then
    Pass2 := 0;
  if K < 0 then
    K := 0;
  if gDlg596724bt.Width + Pass2 > Screen.DesktopWidth then
    Pass2 := Screen.DesktopWidth - gDlg596724bt.Width;
  if gDlg596724bt.Height + K > Screen.DesktopHeight then
    K := Screen.DesktopHeight - gDlg596724bt.Height;
  gDlg596724bt.Left := Pass2;
  gDlg596724bt.Top := K;
  Cls.AttriLabelClick(fmSecondfj.FindComponent('lAttri0') as TLabel);
  fmSecondfj.sbAttriChangeApply.OnClick := Cls.AttriApplyClick;
end;

class procedure TAttriFontChange.AttriAddClick(Sender: TObject);
var
  K: Integer;
  CB: TComboBox;
begin
  { Кнопка add: слово из cbAttri<Tag> уходит в таблицу подсветки и в
    список самого комбобокса. Всё под пустым except -- элемента с таким
    именем может и не быть.
    Именно Repaint, а не Invalidate: перекрасить редактор надо сразу,
    а не когда до него дойдёт очередь сообщений. }
  K := (Sender as TSpeedButton).Tag;
  try
    CB := fmSecondfj.FindComponent('cbAttri' + IntToStr(K)) as TComboBox;
    if AddKeyword(fmSecondfj.fld_1428, UpperCase(CB.Text), K) then
      CB.Items.Add(CB.Text);
    fmSecondfj.edScript.Repaint;
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
    выделение сдвигается на существующую строку -- иначе после удаления
    последней ItemIndex останется за краем. }
  K := (Sender as TSpeedButton).Tag;
  CB := fmSecondfj.FindComponent('cbAttri' + IntToStr(K)) as TComboBox;
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
      DeleteKeyword(fmSecondfj.fld_1428, UpperCase(S));
      fmSecondfj.edScript.Repaint;
    end;
end;

class procedure TAttriFontChange.AttriMoveClick(Sender: TObject);
var
  S: string;
  K: Integer;
  CB: TComboBox;
begin
  { Кнопка move: слово переезжает из своего списка в общий cbRWList, а сам
    список показывается прямо на месте нажатой кнопки -- так видно, откуда
    слово взято. }
  K := (Sender as TSpeedButton).Tag;
  Sender := Sender;
  CB := fmSecondfj.FindComponent('cbAttri' + IntToStr(K)) as TComboBox;
  S := CB.Text;
  if S <> '' then
    if TComboBox(CB).Items.IndexOf(S) >= 0 then
    begin
      CB := fmSecondfj.FindComponent('cbRWList') as TComboBox;
      CB.Left := (Sender as TSpeedButton).Left;
      CB.Top := (Sender as TSpeedButton).Top;
      CB.Tag := K;
      CB.Hint := S;
      CB.Visible := True;
      CB.SetFocus;
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
    старого. Оба шага под своим except: испортить таблицу подсветки
    из-за одного слова не стоит. }
  if (Sender as TComboBox).ItemIndex <> -1 then
  begin
    (Sender as TComboBox).Visible := False;
    S := (Sender as TComboBox).Text;
    Found := False;
    K := 0;
    for I := 0 to fmSecondfj.fld_1428.AttrCount - 1 do
      if S = fmSecondfj.fld_1428.Attribute[I].Name then
      begin
      K := TSynUOAttributes(fmSecondfj.fld_1428.Attribute[I]).Kind;
        Found := True;
        Break;
      end;
    if Found then
    begin
      S := (Sender as TComboBox).Hint;
      try
        with fmSecondfj.FindComponent('cbAttri' + IntToStr(K)) as TComboBox do
          Items.Add(S);
        AddKeyword(fmSecondfj.fld_1428, UpperCase(S), K);
      except
      end;
      K := (Sender as TComboBox).Tag;
      try
        CB := fmSecondfj.FindComponent('cbAttri' + IntToStr(K)) as TComboBox;
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
      fmSecondfj.edScript.Repaint;
      (Sender as TComboBox).ItemIndex := -1;
    end;
  end;
end;

class procedure TAttriFontChange.AttriRWListExit(Sender: TObject);
begin
  { Уход фокуса прячет плавающий список. }
  (Sender as TComboBox).Visible := False;
end;

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
        fmSecondfj.rbAttriBI.Checked := True
      else
        fmSecondfj.rbAttriI.Checked := True;
    end
    else
      fmSecondfj.rbAttriB.Checked := True;
  end
  else
    fmSecondfj.rbAttriN.Checked := True;
  if fsUnderline in L.Font.Style then
    fmSecondfj.cbAttriIU.Checked := True;
  if fsStrikeOut in L.Font.Style then
    fmSecondfj.cbAttriIS.Checked := True;
  (fmSecondfj.FindComponent('cdColorFront') as TColorDialog).Color := L.Font.Color;
  (fmSecondfj.FindComponent('cdColorBack') as TColorDialog).Color := L.Color;
  fmSecondfj.sbAttriChangeApply.Tag := (Sender as TLabel).Tag;
  P := fmSecondfj.FindComponent('lAttriP') as TLabel;
  P.Top := (Sender as TLabel).Top;
end;

class procedure TAttriFontChange.AttriApplyClick(Sender: TObject);
var
  S: string;
  I: Integer;
  L: TLabel;
begin
  { Кнопка «применить» стоит на ГЛАВНОЙ форме, а не в диалоге: цвета и
    стиль из её элементов ложатся сперва на метку-образец lAttri<Tag>, а
    оттуда -- на атрибут подсветки с тем же именем. }
  L := fmSecondfj.FindComponent('lAttri' +
    IntToStr(fmSecondfj.sbAttriChangeApply.Tag)) as TLabel;
  L.Font.Color := (fmSecondfj.FindComponent('cdColorFront') as TColorDialog).Color;
  L.Color := (fmSecondfj.FindComponent('cdColorBack') as TColorDialog).Color;
  L.Font.Style := [];
  if fmSecondfj.rbAttriB.Checked or fmSecondfj.rbAttriBI.Checked then
    L.Font.Style := L.Font.Style + [fsBold];
  if fmSecondfj.rbAttriI.Checked or fmSecondfj.rbAttriBI.Checked then
    L.Font.Style := L.Font.Style + [fsItalic];
  if fmSecondfj.cbAttriIU.Checked then
    L.Font.Style := L.Font.Style + [fsUnderline];
  if fmSecondfj.cbAttriIS.Checked then
    L.Font.Style := L.Font.Style + [fsStrikeOut];
  S := L.Caption;
  for I := 0 to fmSecondfj.fld_1428.AttrCount - 1 do
    if S = fmSecondfj.fld_1428.Attribute[I].Name then
    begin
      fmSecondfj.fld_1428.Attribute[I].Style := L.Font.Style;
      fmSecondfj.fld_1428.Attribute[I].Foreground := L.Font.Color;
      fmSecondfj.fld_1428.Attribute[I].Background := L.Color;
      Break;
    end;
end;

end.
