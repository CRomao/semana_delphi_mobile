program EscolaOnline;

uses
  System.StartUpCopy,
  FMX.Forms,
  View.Login in 'src\view\View.Login.pas' {ViewLogin},
  View.AlunoSelecao in 'src\view\View.AlunoSelecao.pas' {ViewAlunoSelecao},
  View.Principal in 'src\view\View.Principal.pas' {ViewPrincipal},
  Provider.Loading in 'src\providers\Provider.Loading.pas',
  Provider.Connection in 'src\providers\Provider.Connection.pas' {ProviderConnection: TDataModule},
  Provider.Session in 'src\providers\Provider.Session.pas',
  Provider.Functions in 'src\providers\Provider.Functions.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TViewLogin, ViewLogin);
  Application.CreateForm(TViewPrincipal, ViewPrincipal);
  Application.CreateForm(TViewAlunoSelecao, ViewAlunoSelecao);
  Application.CreateForm(TProviderConnection, ProviderConnection);
  Application.Run;
end.
