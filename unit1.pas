unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls;

type

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

var
  Form1: TForm1;
  filename: string;

implementation

{$R *.lfm}

{ TForm1 }

function Test(text:string):string; //Тут присходит магия.
begin
     Test:=text+'test';
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
  Memo1.Lines.LoadFromFile(OpenDialog1.FileName);  //Вызав диалогового окна.
end;
end;

procedure TForm1.Button2Click(Sender: TObject);  //Кнопка вызва теста
var result:string;
begin
     result:=Test(Memo1.Text);
     Memo2.Text := result;
end;

end.

