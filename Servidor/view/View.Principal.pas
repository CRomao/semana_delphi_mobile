unit View.Principal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, Controllers.Global;

type
  TViewPrincipal = class(TForm)
    mmoLogs: TMemo;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ViewPrincipal: TViewPrincipal;

implementation

uses

  Horse,
  Horse.Jhonson,
  Horse.Cors;

{$R *.fmx}

procedure TViewPrincipal.FormShow(Sender: TObject);
begin
  THorse.Use(Jhonson());
  THorse.Use(Cors);

  Controllers.Global.RegistrarRotas;

  THorse.Listen(9000);
  mmoLogs.Lines.Add('Servidor executando na porta ' + THorse.Port.toString);
end;

end.
