unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls;

type
  proverka = record    //Параметор для функций проверки
    bool: boolean;  //Данные о прохождении проверки
    position: byte;  //Позиция остановки.
    event: string;     //Ожидаемый символ.
    received: string;  //Полученый символ.
  end;

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Memo1: TMemo;
    Memo2: TMemo;
    OpenDialog1: TOpenDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
    procedure Memo2Change(Sender: TObject);
  private

  public

  end;

const
  Symbols: set of char = ['A'..'Z', 'a'..'z'];
  numbers: set of byte = [0..9];
//Список допустимых символов для переменной.

var
  Form1: TForm1;
  filename: string;

implementation

{$R *.lfm}

{ TForm1 }

function Data_type(Text: string; i: integer): proverka;
  //Проверка типа данных
var
  a: boolean;
begin
  while Text[i] = ' ' do
    i += 1; //Пропускаем пробелы
  a := False;
  Text := AnsiLowerCase(Text);
  //Конвертируем в нижний регистр.

  if (Text[i] = 'i') and (Text[i + 1] = 'n') and (Text[i + 2] = 't') and
    (Text[i + 3] = 'e') and (Text[i + 4] = 'g') and (Text[i + 5] = 'e') and
    (Text[i + 6] = 'r') //integer
  then
  begin
    a := True;
    i += 6;
  end;

  if (Text[i] = 'b') and (Text[i + 1] = 'o') and (Text[i + 2] = 'o') and
    (Text[i + 3] = 'l') and (Text[i + 4] = 'e') and (Text[i + 5] = 'a') and
    (Text[i + 6] = 'n') //boolean
  then
  begin
    a := True;
    i += 6;
  end;

  if (Text[i] = 'r') and (Text[i + 1] = 'e') and (Text[i + 2] = 'a') and
    (Text[i + 3] = 'l') //real
  then
  begin
    a := True;
    i += 3;
  end;

  if (Text[i] = 'c') and (Text[i + 1] = 'h') and (Text[i + 2] = 'a') and
    (Text[i + 3] = 'r') //char
  then
  begin
    a := True;
    i += 3;
  end;

  if (Text[i + 1] <> ' ') and (Text[i + 1] <> ';') then
  begin
    a := False;
  end;  //Если там какие-то лишние символы.

  if a then
  begin
    Data_type.bool := True;
    Data_type.position := i + 1;
    Data_type.event := '!';
    Data_type.received := '!';
    Exit;
  end
  else
  begin //Неизвестный тип данных
    Data_type.bool := False;
    Data_type.position := i;
    Data_type.event := '!';
    Exit;
  end;

end;

function identifier(Text: string; i: integer): proverka;
  //Проверка индификатора переменной.
var
  a: boolean;
begin
  a := True;  //Первый символ всегда буква.
  while True do
  begin

    case Text[i] of
      'A'..'Z', 'a'..'z': a := False;
      '0'..'9': if a then
        begin
          identifier.bool := False;
          identifier.position := i;
          identifier.event := 'a..z';
          identifier.received := Text[i];
          Exit;
        end;
      ':':
      begin  //Заполнение значений функции.
        identifier.bool := True;
        identifier.position := i + 1;
        identifier.event := '!';
        identifier.received := '!';
        Exit;
      end;
      ' ': if not ((Text[i + 1] = ':') or (Text[i + 1] = ',')) then
        begin
          identifier.bool := False;
          identifier.position := i;
          identifier.event := ':';
          identifier.received := Text[i];
          Exit;
        end;
      ',':
      begin
        a := True;
        if Text[i + 1] = ' ' then
          i += 1; //Перепрыгиваем через пробел.

        if not (Text[i + 1] in ['A'..'Z', 'a'..'z']) then
        begin
          identifier.bool := False;
          identifier.position := i;
          identifier.event := 'a..z';
          identifier.received := Text[i + 1];
          Exit;
        end;
      end;
      else
      begin
        identifier.bool := False;
        identifier.position := i;
        identifier.event := 'a..z';
        identifier.received := Text[i];
        Exit;
      end;
    end;
    i += 1;
  end;
end;

function Start_Var(Text: string; i: integer): proverka;
  //Проверка на ключевое слово
begin
  Text := AnsiLowerCase(Text);
  //Конвертируем в нижний регистр.

  if Text[i] <> 'v' then
  begin
    Start_Var.bool := False;
    Start_Var.position := i;
    Start_Var.event := 'v';
    Start_Var.received := Text[i];
    Exit;
  end;
  i += 1;

  if Text[i] <> 'a' then
  begin
    Start_Var.position := i;
    Start_Var.bool := False;
    Start_Var.event := 'a';
    Start_Var.received := Text[i];
    Exit;
  end;
  i += 1;
  if Text[i] <> 'r' then
  begin
    Start_Var.position := i;
    Start_Var.bool := False;
    Start_Var.event := 'r';
    Start_Var.received := Text[i];
    Exit;
  end;
  i += 1;
  if Text[i] <> ' ' then
  begin
    Start_Var.position := i;
    Start_Var.bool := False;
    Start_Var.event := ' ';
    Start_Var.received := Text[i];
    Exit;
  end;
  i += 1;
  with  Start_Var do
  begin  //Заполнение значений функции.
    bool := True;
    position := i;
    event := '!';
    received := '!';
  end;
end;

function neutralization(Text, type_error: string; i: integer): integer;
  //Нетрализхация ошибки на ключевое слово
begin
  case type_error of
    'Start_Var': while Text[i] <> ' ' do i += 1;
    'identifier': begin while Text[i] <> ':' do i += 1; i+=1; end;
    'Data_type': begin while Text[i] <> ';' do i += 1; end;
  end;

  neutralization := i;
end;

function Test(Text: string): string; //Тут присходит магия.
var
  poss, k: byte;
  tmp: proverka;
  tmp_poss: string;
begin
  while pos('  ', Text) > 0 do
    Delete(Text, pos('  ', Text), 1); //Удаляем лишние пробелы.
  while pos(LineEnding, Text) > 0 do
    Delete(Text, pos(LineEnding, Text), 1); //Удаляем перенос строк.
  poss := 1;
  k := 0;

  while Text[poss] = ' ' do //Если есть пробелы в начале.
    poss += 1;

  tmp := Start_Var(Text, poss);
  poss := tmp.position;
  str(poss, tmp_poss);
  if not tmp.bool then
  begin
    k += 1;
    Test := 'Ошибка. Не найдено ключевое слово "var". Позиция ошибки: '
      +
      tmp_poss + ' Ожидалось: "' + tmp.event + '" Полученно: "' + tmp.received + '"';
    poss := neutralization(Text, 'Start_Var', poss + 1);
  end; //Exit;

  while poss <= (length(Text) - 1) do
  begin

    while Text[poss] = ' ' do
      poss += 1;

    tmp := identifier(Text, poss);
    poss := tmp.position;
    str(poss, tmp_poss);
    if not tmp.bool then
    begin
      k += 1;
      Test := Test + LineEnding +
        'Ошибка. Ошибка в имени переменной. Позиция ошибки: '
        +
        tmp_poss + ' Ожидалось: "' + tmp.event + '" Полученно: "' + tmp.received + '"';
        poss := neutralization(Text, 'identifier', poss);
    end;

    tmp := Data_type(Text, poss);
    poss := tmp.position;
    str(poss, tmp_poss);
    if not tmp.bool then
    begin
      k += 1;
      Test := Test + LineEnding +
        'Ошибка. Неизвестный тип данных. Позиция ошибки: ' +
        tmp_poss;
      poss := neutralization(Text, 'Data_type', poss);
    end;

    while Text[poss] = ' ' do poss += 1;  str(poss, tmp_poss);

    if Text[poss] <> ';' then
    begin
      k += 1;
      Test := Test + LineEnding +
        'Ошибка. Отсутсвие терминального символа. Позиция ошибки: '
        +
        tmp_poss + ' Ожидалось: ";" Полученно: "' + Text[poss] + '"';
      //poss := neutralization(Text, 'Data_type', poss);
    end;
    poss += 1;

  end;

  if k = 0 then
    Test := 'Ошибок нет'
  else
  begin
    str(k, tmp_poss);
    Test := Test + LineEnding + 'Анализ закончен. Количество ошибок: '
      +
      tmp_poss;
  end;
end;


procedure TForm1.Memo1Change(Sender: TObject);
begin

end;

procedure TForm1.Memo2Change(Sender: TObject);
begin

end;

procedure TForm1.Button1Click(Sender: TObject);
begin

  if OpenDialog1.Execute then
  begin
    Memo1.Lines.LoadFromFile(OpenDialog1.FileName);
    //Вызав диалогового окна.
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);  //Кнопка вызва теста
var
  Result: string;
begin
  Result := Test(Memo1.Text);
  Memo2.Text := Result;
end;

end.
