unit View.Login;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Layouts, FMX.Edit, FMX.Controls.Presentation, FMX.StdCtrls, View.AlunoSelecao,
  Provider.Connection, Provider.Loading, Provider.Session;

type
  TViewLogin = class(TForm)
    imgLogoMarca: TImage;
    layLogin: TLayout;
    lblCPF: TLabel;
    edtCPF: TEdit;
    lblSenha: TLabel;
    edtSenha: TEdit;
    rctAcessar: TRectangle;
    btnAcessar: TSpeedButton;
    lblEsqueciSenha: TLabel;
    procedure btnAcessarClick(Sender: TObject);
  private
    procedure TerminateLogin(Sender: TObject);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ViewLogin: TViewLogin;

implementation

{$R *.fmx}

procedure TViewLogin.btnAcessarClick(Sender: TObject);
var
  t: TThread;
begin
  TLoading.Show(ViewLogin, '');

  t:= TThread.CreateAnonymousThread(procedure
  begin
    //Sincronizar alterações visuais para o usuário na TThread principal;
    ProviderConnection.Login(edtCPF.Text, edtSenha.Text);

    TSession.ID_USUARIO:= ProviderConnection.fmtUsuario.FieldByName('id_usuario').AsInteger;
    TSession.NOME:= ProviderConnection.fmtUsuario.FieldByName('nome').AsString;
    TSession.EMAIL:= ProviderConnection.fmtUsuario.FieldByName('email').AsString;
  end);

  t.OnTerminate:= TerminateLogin;
  t.Start;
end;

procedure TViewLogin.TerminateLogin(Sender: TObject);
begin
  TLoading.Hide;

  if Sender is TThread then
    if Assigned(TThread(Sender).FatalException) then
    begin
      ShowMessage(Exception(TThread(Sender).FatalException).Message);
      exit;
    end;

  //se login for valido, cria o form de selecao
  if not Assigned(ViewAlunoSelecao) then
    Application.CreateForm(TViewAlunoSelecao, ViewAlunoSelecao);

  ViewAlunoSelecao.Show;
  TLoading.ToastMessage(ViewAlunoSelecao, 'Bem-vindo '+TSession.NOME, TAlignLayout.Bottom, $FF6A5AE0, $FFFFFFFF, 2);
end;



end.
