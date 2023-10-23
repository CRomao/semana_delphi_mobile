unit Provider.Connection;

interface

uses
  System.SysUtils, System.Classes, DataSet.Serialize, DataSet.Serialize.Config,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  RESTRequest4D, DataSet.Serialize.Adapter.RESTRequest4D, System.JSON,
  RESTRequest4D.Response.Contract;

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
    procedure ListarBoletim(idUsuario: integer; periodo: string);
    procedure ListarCalendario(idUsuario: integer; data: TDate);
    procedure ListarAlunos(idUsuario: integer);
    procedure Login(cpf, senha: string);
    procedure EnviarMensagem(idUsuario: Integer; mensagem: string);        
  end;

var
  ProviderConnection: TProviderConnection;

const
  BASE_URL = 'http://localhost:9000';

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TProviderConnection.ListarMensagens(idUsuario: integer);
var
  resp: IResponse;
begin
  resp:= TRequest.New.BaseURL(BASE_URL)
                     .Resource('/social')
                     .Accept('application/json')
                     .AddParam('id_usuario', idUsuario.ToString)
                     .Adapters(TDataSetSerializeAdapter.New(fmtMensagens))
                     .Get;

  if resp.StatusCode <> 200 then
    raise Exception.Create(resp.Content);
end;

procedure TProviderConnection.ListarBoletim(idUsuario: integer; periodo: string);
var
  resp: IResponse;
begin
  resp:= TRequest.New.BaseURL(BASE_URL)
                     .Resource('/boletim')
                     .Accept('application/json')
                     .AddParam('id_usuario', idUsuario.ToString)
                     .AddParam('periodo', periodo)                     
                     .Adapters(TDataSetSerializeAdapter.New(fmtBoletim))
                     .Get;

  if resp.StatusCode <> 200 then
    raise Exception.Create(resp.Content);
end;

procedure TProviderConnection.ListarCalendario(idUsuario: integer; data: TDate);
var
  resp: IResponse;
begin
  resp:= TRequest.New.BaseURL(BASE_URL)
                     .Resource('/calendario')
                     .Accept('application/json')
                     .AddParam('id_usuario', idUsuario.ToString)
                     .AddParam('dt', FormatDateTime('yyyy-mm-dd', data))                     
                     .Adapters(TDataSetSerializeAdapter.New(fmtCalendario))
                     .Get;

  if resp.StatusCode <> 200 then
    raise Exception.Create(resp.Content);
end;

procedure TProviderConnection.DataModuleCreate(Sender: TObject);
begin
  TDataSetSerializeConfig.GetInstance.CaseNameDefinition:= cndLower;
  TDataSetSerializeConfig.GetInstance.Import.DecimalSeparator:= '.';  
end;

procedure TProviderConnection.ListarAlunos(idUsuario: integer);
var
  resp: IResponse;
begin
  resp:= TRequest.New.BaseURL(BASE_URL)
                     .Resource('/usuarios')
                     .Accept('application/json')
                     .AddParam('id_responsavel', idUsuario.ToString)
                     .Adapters(TDataSetSerializeAdapter.New(fmtAluno))
                     .Get;

  if resp.StatusCode <> 200 then
    raise Exception.Create(resp.Content);

end;

procedure TProviderConnection.Login(cpf, senha: string);
var
  resp: IResponse;
  json: TJSONObject;
begin
  try
    json:= TJSONObject.Create;
    json.AddPair('cpf', cpf);
    json.AddPair('senha', senha);

    resp:= TRequest.New.BaseURL(BASE_URL)
                       .Resource('/usuarios/login')
                       .Accept('application/json')
                       .Adapters(TDataSetSerializeAdapter.New(fmtUsuario))
                       .AddBody(json.ToJSON)
                       .Post;

    if resp.StatusCode <> 200 then
      raise Exception.Create(resp.Content);

  finally
    json.DisposeOf;
  end;
end;

procedure TProviderConnection.EnviarMensagem(idUsuario: Integer; mensagem: string);
var
  resp: IResponse;
  json: TJSONObject;
begin
  try
    json:= TJSONObject.Create;
    json.AddPair('id_usuario', idUsuario.ToString);
    json.AddPair('mensagem', mensagem);

    resp:= TRequest.New.BaseURL(BASE_URL)
                       .Resource('/social')
                       .Accept('application/json')
                       .Adapters(TDataSetSerializeAdapter.New(fmtMensagens))
                       .AddBody(json.ToJSON)
                       .Post;

    if resp.StatusCode <> 201 then
      raise Exception.Create(resp.Content);

  finally
    json.DisposeOf;
  end;
end;

end.
