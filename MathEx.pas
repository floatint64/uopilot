unit MathEx;

{ Разбор и счёт арифметики в хвосте команды ожидания: чистка строки,
  перевод инфикса в постфикс и свёртка постфикса в число. }

interface

function WaitPartOf(var S: string): string;
function WaitTextOf(S: string; var N: Integer): string;
function WaitUnitOf(var S: string; var N: Integer): Integer;
function ParseWaitSuffix(S: string; var A, B: Integer): string;

const
  { Тексты ошибок разбора. Индекс -- сам код ошибки: они отрицательные,
    нуль означает «всё ок». }
  gEvalErrorsl6: array[-6..1] of string = (
    'Пропущено действие', 'Пропущено значение', 'Нет закрывающей скобки',
    'Нет открывающей скобки', 'Символ не распознан', 'Деление на нуль',
    'Все ок.', 'two exp...');

implementation

uses SysUtils, StrUtils, Unit1;

{ ИНФИКС В ПОСТФИКС -- обычная сортировочная станция Дейкстры.
  Границы числа помечаются буквами кириллицы #192 ('А') и #217 ('Щ'):
  в выражении ожидания их быть не может, а метка в один байт дешевле
  любой другой. 'А' ставится перед числом, 'Щ' -- после. }
function WaitPartOf(var S: string): string;
const
  cOps: array[1..7] of Char = '(=)+-*/';
  cPri: array[1..7] of Byte = (0, 1, 1, 2, 2, 3, 3);
var
  { Стек знаков -- прямо в кадре: глубже шестнадцати вложений в выражении
    ожидания всё равно не бывает. }
  nSt: Byte;
  aSt: array[0..16] of Char;
  b: Char;
  i: Byte;
  R: string;
  t: Char;
  c: Char;
  f: Boolean;

  { Старшинство знака, -1 если знак не наш. }
  function ChClass(x: Char): Integer;
  var
    j: Byte;
  begin
    Result := -1;
    for j := 1 to 7 do
      if x = cOps[j] then
      begin
        Result := cPri[j];
        Break;
      end;
  end;

  { Положить знак на стек. }
  procedure PushOp(x: Char);
  begin
    if nSt < 16 then
    begin
      Inc(nSt);
      aSt[nSt] := x;
    end;
  end;

  { Снять знак со стека; освободившееся место затирается '_'. }
  procedure PopOp(var x: Char);
  begin
    if nSt > 0 then
    begin
      x := aSt[nSt];
      aSt[nSt] := '_';
      Dec(nSt);
    end;
  end;

begin
  R := '';
  for i := 0 to 16 do
    aSt[i] := '_';
  nSt := 0;
  for i := 1 to Length(S) do
  begin
    b := S[i];
    b := b;
    t := aSt[nSt];
    if i <= 1 then
      f := False
    else
      f := S[i - 1] in [',', '0'..'9', 'a'..'f', 'x'];
    if ChClass(b) < 0 then
    begin
      if not f then
      begin
        R := R + #192;
        { УНАРНЫЙ МИНУС: он уже лежит на стеке, а число только начинается.
          Признак -- либо самое начало строки (i = 2 после первого знака),
          либо открывающая скобка перед ним. }
        if t = '-' then
          if (i = 2) or (S[i - 2] = '(') then
          begin
            PopOp(c);
            R := R + c;
          end;
      end;
      R := R + b;
      Continue;
    end;
    begin
      if f then
        R := R + #217;
      if b = ')' then
      begin
        repeat
          PopOp(c);
          if c <> '(' then
            R := R + c;
        until c = '(';
      end
      else
        if (ChClass(b) = 0) or (ChClass(b) > ChClass(t)) then
          PushOp(b)
        else
        begin
          repeat
            PopOp(c);
            R := R + c;
            t := aSt[nSt];
          until ChClass(b) > ChClass(t);
          PushOp(b);
        end;
    end;
  end;
  if R[Length(R)] in [',', '0'..'9', 'a'..'f', 'x'] then
    R := R + #217;
  while nSt <> 0 do
  begin
    PopOp(c);
    R := R + c;
  end;
  Result := R;
end;

{ СВЁРТКА ПОСТФИКСА В ЧИСЛО. Раз за разом находим самый левый знак, у
  которого слева стоит готовое число, считаем пару и ставим итог на её
  место; когда знаков не осталось -- переводим остаток в число.
  Строка берётся ПО ЗНАЧЕНИЮ нарочно: тело правит её Delete/Insert, и
  наружу эта правка уходить не должна. }
function WaitTextOf(S: string; var N: Integer): string;
var
  op: Char;
  pe: SmallInt;
  sL: string;                          { кусок слева от знака }
  sR: string;                          { и справа }
  sT: string;
  vL: Int64;
  vR: Int64;
  v: Int64;
  bDone: Boolean;
  p, q, ins: SmallInt;
  bLeft: Boolean;

  { Посчитать пару. Делим только на ненулевое, иначе E := -1 и выход. }
  function CalcOp(C: Char; var E: Integer; A, B: Int64): Int64;
  begin
    Result := 0;
    case C of
      '+': Result := A + B;
      '-': Result := A - B;
      '*': Result := A * B;
      '/':
        if B <> 0 then
          Result := A div B
        else
        begin
          E := -1;
          Exit;
        end;
    end;
    E := 0;
  end;

begin
  Result := '0';
  repeat
    p := 1;
    { Знак ищется СЛЕВА НАПРАВО, но знак, перед которым стоит #192, -- это
      не знак, а начало числа (метка WaitPartOf). }
    repeat
      Inc(p);
    until ((S[p] in ['*', '+', '-', '/']) and (S[p - 1] <> #192))
      or (p > Length(S));
    op := S[p];
    pe := p - 1;
    q := p - 2;
    while q > 0 do
    begin
      if S[q] = #192 then
        Break;
      Dec(q);
    end;
    sR := Copy(S, q + 1, p - q - 2);
    Dec(q);
    p := q - 1;
    while p > 0 do
    begin
      if S[p] = #192 then
        Break;
      Dec(p);
    end;
    if p <= 0 then
      p := 1;
    ins := p;
    sL := Copy(S, p + 1, q - p - 1);
    if not TryStrToInt64(sR, vR) then
      N := 1;
    if not TryStrToInt64(sL, vL) then
      N := 1;
    if sL = '' then
    begin
      { Слева ничего нет: либо всё выражение -- одно число, либо знак висит
        без пары. }
      if op = #0 then
      begin
        v := vR;
        N := 0;
      end
      else
        v := 0;
    end
    else
      v := CalcOp(op, N, vL, vR);
    if N <> 0 then
      Exit;
    sT := IntToStr(v);
    sT := #192 + sT + #217;
    Delete(S, ins, pe - ins + 2);
    Insert(sT, S, ins);
    bDone := True;
    for p := 1 to Length(S) do
    begin
      if p < 2 then
        bLeft := True
      else
        bLeft := S[p - 1] <> #192;
      if (S[p] in ['*', '+', '-', '/']) and bLeft then
      begin
        bDone := False;
        Break;
      end;
    end;
  until bDone;
  Delete(S, Length(S), 1);
  Delete(S, 1, 1);
  try
    v := StrToInt64(S);
  except
    N := 1;
  end;
  if N = 0 then
    Result := IntToStr(v);
end;

{ ПРОВЕРКА И ЧИСТКА ХВОСТА ОЖИДАНИЯ. Идём по строке, выбрасываем всё,
  чего нет в наборе слова, обносим скобками унарный минус и считаем баланс
  скобок. Отрицательный итог -- код ошибки: -2 чужой знак, -3 лишняя '(',
  -4 лишняя ')', -5 два знака подряд, -6 знак не на своём месте.
  Положительный -- длина разобранного куска, позиция отдаётся через N на
  каждом шаге. }
function WaitUnitOf(var S: string; var N: Integer): Integer;
label
  LWc1Z, LWc2Z;
var
  i, j: Integer;
  nOpen, nClose: Integer;
begin
  Assert(@nOpen <> nil);
  Assert(@nClose <> nil);
  Assert(@Result <> nil);
  nOpen := 0;
  nClose := 0;
  Result := 0;
  i := 1;
  while i <= Length(S) do
  begin
    N := i;
    { ВНУТРЕННИЙ ЦИКЛ БЕЗ УСЛОВИЯ: выбрасывает чужие знаки по одному, пока
      под рукой не окажется свой. Выход из него -- либо Break, либо Exit. }
    LWc1Z:
      if i > Length(S) then
        Exit;
      if S[i] in [','] + gWordCharsadq then
        goto LWc2Z;
      { Чужой знак ЗАЖАТ между двумя своими -- дальше резать нельзя, это
        конец разбираемого куска. }
      if (S[i - 1] in [','] + gWordCharsadq - ['*', '+', '-', '/'])
        and (S[i + 1] in [','] + gWordCharsadq - ['*', '+', '-', '/']) then
      begin
        if nOpen > nClose then
          Result := -3
        else
          if nOpen < nClose then
            Result := -4
          else
            if nOpen = nClose then
            begin
              Dec(i);
              Result := i;
            end;
        Exit;
      end;
      Delete(S, i, 1);
      goto LWc1Z;
    LWc2Z:
    { Шестнадцатеричное '0x' пропускается отдельно: сама 'x' в наборе есть,
      а вот 'X' -- нет, отсюда LowerCase от ОДНОГО знака. }
    if not (S[i] in ['(', ')', '*', '+', ',', '-', '/', '0'..'9',
      'a'..'f', 'x']) then
      if (LowerCase(S[i]) <> 'x') or (S[i - 1] <> '0') then
      begin
        Result := -2;
        Exit;
      end;
    { ДВА ЗНАКА ПОДРЯД: допустим только унарный минус, и он обносится
      скобками до конца числа. }
    if i < Length(S) then
      if (S[i] in ['*', '+', '-', '/']) and (S[i + 1] in ['*', '+', '-', '/']) then
        if S[i + 1] = '-' then
        begin
          j := i + 2;
          while (j <= Length(S)) and (S[j] in ['0'..'9', 'a'..'f', 'x']) do
            Inc(j);
          Insert(')', S, j);
          Insert('(', S, i + 1);
        end
        else
        begin
          Result := -5;
          Exit;
        end;
    if S[i] = '(' then
    begin
      Inc(nOpen);
      if i < Length(S) then
        if S[i + 1] in [')', '*', '+', '/'] then
        begin
          Result := -5;
          Exit;
        end;
      if i > 1 then
        if not (S[i - 1] in ['(', '*', '+', '-', '/']) then
        begin
          Result := -6;
          Exit;
        end;
    end;
    if S[i] = ')' then
    begin
      Inc(nClose);
      if i > 1 then
        if S[i - 1] in ['*', '+', '-', '/'] then
        begin
          Result := -5;
          Exit;
        end;
      if i < Length(S) then
        if not (S[i + 1] in [')', '*', '+', '-', '/']) then
        begin
          Result := -6;
          Exit;
        end;
    end;
    Inc(i);
  end;
  if nOpen > nClose then
    Result := -3
  else
    if nOpen < nClose then
      Result := -4
    else
      if nOpen = nClose then
        Result := 0;
end;

{ Разбор хвоста ожидания: шестнадцатеричные числа (1a2bh и $1a2b)
  переводятся в десятичные, потом строка разбирается по словам.
  Отрицательное A -- признак ошибки для вызывающего. }
function ParseWaitSuffix(S: string; var A, B: Integer): string;
var
  sW: string;
  nQ: Int64;
  sOrig, sPrev, sPart: string;
  bF: Boolean;
  nP1, nP2: Integer;
  nI: Integer;
begin
  sOrig := S;
  S := StringReplace(S, ' ', '', [rfReplaceAll]);
  S := StringReplace(S, '+-', '-', [rfReplaceAll]);
  S := StringReplace(S, '--', '+', [rfReplaceAll]);
  S := LowerCase(S);
  nP1 := 1;
  nP2 := 1;
  repeat
    nP1 := PosEx('h', S, nP1);
    if nP1 > 1 then
    begin
      { Отступаем влево, пока идут шестнадцатеричные цифры -- это и есть
        начало числа. }
      nI := nP1 - 1;
      while nI >= 1 do
      begin
        if not (S[nI] in ['0'..'9', 'a'..'f']) then
          Break;
        Dec(nI);
      end;
      sW := Copy(S, nI + 1, nP1 - nI - 1);
      try
        nQ := StrToInt64('$' + sW);
        sW := IntToStr(nQ);
        Delete(S, nI + 1, nP1 - nI);
        Insert(sW, S, nI + 1);
        Dec(nP1, nP1 - nI);
        Inc(nP1, Length(S));
      except
        Inc(nP1);
      end;
    end
    else
      nP1 := 0;
    nP2 := PosEx('$', S, nP2);
    if nP2 > 0 then
    begin
      nI := nP2 + 1;
      if (nI <= Length(S)) and (S[nI] in ['0'..'9']) then
      begin
        while nI <= Length(S) do
        begin
          if not (S[nI] in ['0'..'9', 'a'..'f']) then
            Break;
          Inc(nI);
        end;
        sW := Copy(S, nP2, nI - nP2);
        try
          nQ := StrToInt64(sW);
          sW := IntToStr(nQ);
          Delete(S, nP2, nI - nP2);
          Insert(sW, S, nP2 + 1);
          Inc(nP2, Length(S));
        except
          Inc(nP2);
        end;
      end
      else
        Inc(nP2);
    end;
  until (nP1 = 0) and (nP2 = 0);
  Result := '';
  repeat
    A := WaitUnitOf(S, B);
    if A < 0 then
      Exit;
    if A = 0 then
      sW := S
    else
    begin
      sW := Copy(S, 1, A);
      Delete(S, 1, A + 1);
    end;
    bF := False;
    for nI := 1 to Length(sW) do
      if sW[nI] in ['*', '+', '-', '/'] then
      begin
        bF := True;
        Break;
      end;
    if not bF then
    begin
      Result := Result + sW;
      if A <> 0 then
        Result := Result + ' ';
    end
    else
    begin
      sPart := WaitPartOf(sW);
      sPrev := sPart;
      Result := Result + WaitTextOf(sPart, B);
      if B <> 0 then
      begin
        A := -2;
        Result := sPrev;
        Exit;
      end
      else if A <> 0 then
        Result := Result + ' ';
    end;
  until A = 0;
end;

end.
