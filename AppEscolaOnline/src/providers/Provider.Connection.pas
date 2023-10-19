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
    json:= json + '{"id": 1, "dt": "15/06 8h", "nome": "Professor João Marcos", "like": 280, "comentario": 18, "msg": "Torneio de programação na escola!"},';
    json:= json + '{"id": 2, "dt": "15/06 10h", "nome": "Cicero Romão", "like": 500, "comentario": 188, "msg": "Aprendendo programação mobile Delphi!"},';
  end;

  json:= json + '{"id": 3, "dt": "15/06 8h", "nome": "José Rodrigues", "like": 280, "comentario": 18, "msg": "Torneio de programação na escola!"}';
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
  json:= json + '{"disciplina": "Língua Portuguesa", "nota": 8.5, "faltas": 2},';
  json:= json + '{"disciplina": "Matemática", "nota": 9.5, "faltas": 2},';
  json:= json + '{"disciplina": "História", "nota": 7, "faltas": 6},';
  json:= json + '{"disciplina": "Geografia", "nota": 6.5, "faltas": 5},';
  json:= json + '{"disciplina": "Inglês", "nota": 8, "faltas": 2},';
  json:= json + '{"disciplina": "Educação Artística", "nota": 8.5, "faltas": 0},';
  json:= json + '{"disciplina": "Ciências", "nota": 4, "faltas": 1}';
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
  json:= json + '{"descricao": "Reunião dos pais e professores", "hora": "10:00h"},';
  json:= json + '{"descricao": "Reunião dos pais e professores", "hora": "11:00h"},';
  json:= json + '{"descricao": "Reunião dos pais e professores", "hora": "12:00h"}';
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
  json:= json + '{"id_aluno": 2, "nome": "Natália"},';
  json:= json + '{"id_aluno": 3, "nome": "Barbára"}';  
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
    json:= json + '{"id_usuario": 1, "nome": "Cicero Romão Fernandes da Cruz", "email": "teste@teste.com.br"}'
  else
    raise Exception.Create('CPF ou senha inválida');

  fmtUsuario.FieldDefs.Clear;
  fmtUsuario.LoadFromJSON(json);
end;

end.
