unit View.AlunoSelecao;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView, View.Principal,
  Provider.Loading, Provider.Connection, Provider.Session;

type
  TViewAlunoSelecao = class(TForm)
    rctToolBar: TRectangle;
    lblTituloSelecao: TLabel;
    ltvAluno: TListView;
    procedure ltvAlunoItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure FormShow(Sender: TObject);
  private
    procedure ListarAlunos;
    procedure TerminateAluno(Sender: TObject);
    procedure AddAluno(idAluno: Integer; nome: string);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ViewAlunoSelecao: TViewAlunoSelecao;

implementation

{$R *.fmx}

procedure TViewAlunoSelecao.ltvAlunoItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
  if not Assigned(ViewPrincipal) then
    Application.CreateForm(TViewPrincipal, ViewPrincipal);

  TSession.ID_USUARIO:= AItem.tag;
  TSession.NOME:= AItem.Text;

  ViewPrincipal.Show;

end;

procedure TViewAlunoSelecao.FormShow(Sender: TObject);
begin
  ListarAlunos;
end;

procedure TViewAlunoSelecao.ListarAlunos;
var
  t: TThread;
begin
  TLoading.Show(ViewAlunoSelecao, '');
  ltvAluno.BeginUpdate;
  ltvAluno.Items.Clear;

  t:= TThread.CreateAnonymousThread(procedure
  begin
    //Sincronizar alterações visuais para o usuário na TThread principal;
    ProviderConnection.ListarAlunos(TSession.ID_RESPONSAVEL);

    while not ProviderConnection.fmtAluno.Eof do
    begin
      TThread.Synchronize(TThread.CurrentThread, procedure
      begin
        with ProviderConnection do
        begin
          AddAluno(fmtAluno.FieldByName('id_usuario').AsInteger, fmtAluno.FieldByName('nome').AsString);
        end;
      end);
      ProviderConnection.fmtAluno.Next;
    end;
  end);

  t.OnTerminate:= TerminateAluno;
  t.Start;
end;

procedure TViewAlunoSelecao.TerminateAluno(Sender: TObject);
begin
  TLoading.Hide;
  ltvAluno.EndUpdate;

  if Sender is TThread then
    if Assigned(TThread(Sender).FatalException) then
      ShowMessage(Exception(TThread(Sender).FatalException).Message);
end;

procedure TViewAlunoSelecao.AddAluno(idAluno: Integer; nome: string);
var
  item: TListViewItem;
begin
  item:= ltvAluno.Items.Add;
  item.tag:= idAluno;
  item.Text:= nome;
end;

end.
