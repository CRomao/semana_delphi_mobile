unit Provider.Connection;

interface

uses
  System.SysUtils, System.Classes, DataSet.Serialize, DataSet.Serialize.Config,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TProviderConnection = class(TDataModule)
    fmtMensagens: TFDMemTable;
    fmtBoletim: TFDMemTable;
    fmtCalendario: TFDMemTable;
    fmtUsuario: TFDMemTable;
    fmtAluno: TFDMemTable;
    procedure DataModuleCreate(Sender: TObject);
  private        
    { Private declarations }
  public
    { Public declarations }
    procedure ListarMensagens(idUsuario: integer);
    procedure ListarBoletim(idUsuario: integer);
    procedure ListarCalendario(idUsuario: integer; data: TDate);
    procedure ListarAlunos(idUsuario: integer);
    procedure Login(cpf, senha: string);
  end;

var
  ProviderConnection: TProviderConnection;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TProviderConnection.ListarMensagens(idUsuario: integer);
var
  json: string;
  i: integer;
begin
  //buscar dados via GET do servidor;

  Sleep(1500);
  json:= '[';

  for i := 1 to 10 do
  begin
    json:= json + '{"id": 1, "dt": "15/06 8h", "nome": "Professor Jo�o Marcos", "like": 280, "comentario": 18, "msg": "Torneio de programa��o na escola!"},';
    json:= json + '{"id": 2, "dt": "15/06 10h", "nome": "Cicero Rom�o", "like": 500, "comentario": 188, "msg": "Aprendendo programa��o mobile Delphi!"},';
  end;

  json:= json + '{"id": 3, "dt": "15/06 8h", "nome": "Jos� Rodrigues", "like": 280, "comentario": 18, "msg": "Torneio de programa��o na escola!"}';
  json:= json + ']';

  fmtMensagens.FieldDefs.Clear;
  fmtMensagens.LoadfromJSON(json);

end;

procedure TProviderConnection.ListarBoletim(idUsuario: integer);
var
  json: string;
  i: integer;
begin
  //buscar dados via GET do servidor;

  Sleep(1500);
  json:= '[';
  json:= json + '{"disciplina": "L�ngua Portuguesa", "nota": 8.5, "faltas": 2},';
  json:= json + '{"disciplina": "Matem�tica", "nota": 9.5, "faltas": 2},';
  json:= json + '{"disciplina": "Hist�ria", "nota": 7, "faltas": 6},';
  json:= json + '{"disciplina": "Geografia", "nota": 6.5, "faltas": 5},';
  json:= json + '{"disciplina": "Ingl�s", "nota": 8, "faltas": 2},';
  json:= json + '{"disciplina": "Educa��o Art�stica", "nota": 8.5, "faltas": 0},';
  json:= json + '{"disciplina": "Ci�ncias", "nota": 4, "faltas": 1}';
  json:= json + ']';

  fmtBoletim.FieldDefs.Clear;
  fmtBoletim.LoadFromJSON(json);
end;

procedure TProviderConnection.ListarCalendario(idUsuario: integer; data: TDate);
var
  json: string;
  i: integer;
begin
  //buscar dados via GET do servidor;

  Sleep(1000);
  json:= '[';
  json:= json + '{"descricao": "Reuni�o dos pais e professores", "hora": "10:00h"},';
  json:= json + '{"descricao": "Reuni�o dos pais e professores", "hora": "11:00h"},';
  json:= json + '{"descricao": "Reuni�o dos pais e professores", "hora": "12:00h"}';
  json:= json + ']';

  fmtCalendario.FieldDefs.Clear;
  fmtCalendario.LoadFromJSON(json);
end;

procedure TProviderConnection.DataModuleCreate(Sender: TObject);
begin
  TDataSetSerializeConfig.GetInstance.CaseNameDefinition:= cndLower;
  TDataSetSerializeConfig.GetInstance.Import.DecimalSeparator:= '.';  
end;

procedure TProviderConnection.ListarAlunos(idUsuario: integer);
var
  json: string;
  i: integer;
begin
  //buscar dados via GET do servidor;

  Sleep(1000);
  json:= '[';
  json:= json + '{"id_aluno": 1, "nome": "Fernanda"},';
  json:= json + '{"id_aluno": 2, "nome": "Nat�lia"},';
  json:= json + '{"id_aluno": 3, "nome": "Barb�ra"}';  
  json:= json + ']';

  fmtAluno.FieldDefs.Clear;
  fmtAluno.LoadFromJSON(json);
end;

procedure TProviderConnection.Login(cpf, senha: string);
var
  json: string;
  i: integer;
begin
  //buscar dados via GET do servidor;

  Sleep(1000);

  if senha = '12345' then
    json:= json + '{"id_usuario": 1, "nome": "Cicero Rom�o Fernandes da Cruz", "email": "teste@teste.com.br"}'
  else
    raise Exception.Create('CPF ou senha inv�lida');

  fmtUsuario.FieldDefs.Clear;
  fmtUsuario.LoadFromJSON(json);
end;

end.
