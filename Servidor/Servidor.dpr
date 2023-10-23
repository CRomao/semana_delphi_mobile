program Servidor;

uses
  System.StartUpCopy,
  FMX.Forms,
  View.Principal in 'view\View.Principal.pas' {ViewPrincipal},
  Controllers.Global in 'controllers\Controllers.Global.pas',
  DataModule.Global in 'DataModules\DataModule.Global.pas' {DmGlobal: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TViewPrincipal, ViewPrincipal);
  Application.Run;
end.
