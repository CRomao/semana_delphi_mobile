unit View.Login;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Layouts, FMX.Edit, FMX.Controls.Presentation, FMX.StdCtrls, View.AlunoSelecao,
  Provider.Connection, Provider.Loading, Provider.Session, View.Principal;

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


    TSession.NOME:= ProviderConnection.fmtUsuario.FieldByName('nome').AsString;
    TSession.TIPO_USUARIO:= ProviderConnection.fmtUsuario.FieldByName('tipo_usuario').AsString;

    if TSession.TIPO_USUARIO = 'A' then
    begin
      TSession.ID_USUARIO:= ProviderConnection.fmtUsuario.FieldByName('id_usuario').AsInteger;
      TSession.ID_RESPONSAVEL:= 0;
    end
    else
    begin
      TSession.ID_USUARIO:= 0;
      TSession.ID_RESPONSAVEL:= ProviderConnection.fmtUsuario.FieldByName('id_usuario').AsInteger;
    end

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


  if TSession.TIPO_USUARIO = 'R' then
  begin
    if not Assigned(ViewAlunoSelecao) then
      Application.CreateForm(TViewAlunoSelecao, ViewAlunoSelecao);

    ViewAlunoSelecao.Show;
    TLoading.ToastMessage(ViewAlunoSelecao, 'Bem-vindo '+TSession.NOME, TAlignLayout.Bottom, $FF6A5AE0, $FFFFFFFF, 2);
  end
  else
  begin
    if not Assigned(ViewAlunoSelecao) then
      Application.CreateForm(TViewPrincipal, ViewPrincipal);

    ViewPrincipal.Show;
    TLoading.ToastMessage(ViewPrincipal, 'Bem-vindo '+TSession.NOME, TAlignLayout.Bottom, $FF6A5AE0, $FFFFFFFF, 2);
  end;
end;



end.
