unit DataModule.Global;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.FMXUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat,
  DataSet.Serialize, DataSet.Serialize.Config, System.JSON, FIreDAC.DApt;

type
  TDmGlobal = class(TDataModule)
    Conn: TFDConnection;
    FDPhysSQLiteDriverLink: TFDPhysSQLiteDriverLink;
    procedure DataModuleCreate(Sender: TObject);
    procedure ConnBeforeConnect(Sender: TObject);
  private
    procedure CarregarConfigDB(Connection: TFDConnection);
    { Private declarations }
  public
      function ListarMensagens(idUsuario, pagina: integer): TJSONArray;
      function InserirMensagem(idUsuario: integer; mensagem: string): TJSONObject;
      procedure EditarMensagem(idMensagem: integer; mensagem: string);
      procedure ExcluirMensagem(idMensagem: integer);
      function ListarBoletim(idUsuario: integer; periodo: string): TJSONArray;
      function ListarCalendario(idUsuario: integer; dt: string): TJSONArray;
      function ListarUsuarios(idResponsavel: integer): TJSONArray;
      function Login(cpf, senha: string): TJSONObject;
    { Public declarations }
  end;

var
  DmGlobal: TDmGlobal;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TDmGlobal.CarregarConfigDB(Connection: TFDConnection);
begin
  Connection.DriverName:= 'SQLite';

  with Connection.Params do
  begin
    Clear;
    Add('DriverID=SQLite');
    Add('Database=D:\projetos-delphi\99_CODERS\semana_delphi_mobile\Servidor\DB\banco.db');
    Add('User_Name=');
    Add('Password=');
    Add('Port=');
    Add('Server=');
    Add('Protocol=');
    Add('LockingMode=Normal');
  end;

end;

procedure TDmGlobal.DataModuleCreate(Sender: TObject);
begin
  TDataSetSerializeConfig.GetInstance.CaseNameDefinition:= cndLower;
  TDataSetSerializeConfig.GetInstance.Import.DecimalSeparator:= '.';

  Conn.Connected:= True;
end;

procedure TDmGlobal.ConnBeforeConnect(Sender: TObject);
begin
  CarregarConfigDB(conn);
end;

function TDmGlobal.ListarMensagens(idUsuario, pagina: integer): TJSONArray;
var
  qry: TFDQuery;
begin
  try
    qry:= TFDQuery.Create(nil);
    qry.Connection:= Conn;

    qry.SQL.Clear;
    qry.SQL.Add('select s.*, u.nome from tab_social s join tab_usuario u ');
    qry.SQL.Add('on (u.id_usuario = s.id_usuario) ');
    qry.SQL.Add('where s.id_usuario = :id_usuario ');
    qry.SQL.Add('order by s.id_mensagem desc');
    qry.ParamByName('id_usuario').Value:= idUsuario;
    qry.Open;

    Result:= qry.ToJSONArray;

  finally
    FreeAndNil(qry);
  end;

end;

function TDmGlobal.InserirMensagem(idUsuario:integer; mensagem: string): TJSONObject;
var
  qry: TFDQuery;
begin
  try
    if (idUsuario <= 0) or (mensagem = '') then
      raise Exception.Create('Informe o usuário e a mensagem');


    qry:= TFDQuery.Create(nil);
    qry.Connection:= Conn;


    qry.Active:= False;
    qry.SQL.Clear;
    qry.SQL.Add('insert into tab_social(dt_geracao, id_usuario, qtd_like, qtd_comentario, mensagem) ');
    qry.SQL.Add('values(datetime(), :id_usuario, 0, 0, :mensagem); ');
    qry.SQL.Add('select last_insert_rowid() as id_mensagem ');//SQLite
    //qry.SQL.Add('RETURNING ID_MENSAGEM'); //Firebird

    qry.ParamByName('id_usuario').Value:= idUsuario;
    qry.ParamByName('mensagem').Value:= mensagem;
    qry.Active:= True;

    Result:= qry.ToJSONObject;

  finally
    FreeAndNil(qry);
  end;

end;

procedure TDmGlobal.EditarMensagem(idMensagem:integer; mensagem: string);
var
  qry: TFDQuery;
begin
  try
    if (idMensagem <= 0) or (mensagem = '') then
      raise Exception.Create('Informe o id e a mensagem');


    qry:= TFDQuery.Create(nil);
    qry.Connection:= Conn;


    qry.Active:= False;
    qry.SQL.Clear;
    qry.SQL.Add('update tab_social set mensagem = :mensagem ');
    qry.SQL.Add('where id_mensagem = :id_mensagem ');
    qry.ParamByName('id_mensagem').Value:= idMensagem;
    qry.ParamByName('mensagem').Value:= mensagem;
    qry.ExecSQL;

  finally
    FreeAndNil(qry);
  end;

end;

procedure TDmGlobal.ExcluirMensagem(idMensagem:integer);
var
  qry: TFDQuery;
begin
  try
    if (idMensagem <= 0) then
      raise Exception.Create('Informe o id da mensagem');


    qry:= TFDQuery.Create(nil);
    qry.Connection:= Conn;

    qry.Active:= False;
    qry.SQL.Clear;
    qry.SQL.Add('delete from tab_social where id_mensagem = :id_mensagem ');
    qry.ParamByName('id_mensagem').Value:= idMensagem;
    qry.ExecSQL;

  finally
    FreeAndNil(qry);
  end;

end;

function TDmGlobal.ListarBoletim(idUsuario: integer; periodo: string): TJSONArray;
var
  qry: TFDQuery;
begin
  try
    qry:= TFDQuery.Create(nil);
    qry.Connection:= Conn;

    qry.SQL.Clear;
    qry.SQL.Add('select disciplina, nota, qtd_falta from tab_boletim where id_usuario = :id_usuario ');
    qry.ParamByName('id_usuario').Value:= idUsuario;

    if (periodo <> '') then
    begin
      qry.SQL.Add('and periodo = :periodo ');
      qry.ParamByName('periodo').Value:= periodo;
    end;

    qry.SQL.Add('order by periodo, disciplina ');
    qry.Open;

    Result:= qry.ToJSONArray;

  finally
    FreeAndNil(qry);
  end;

end;

function TDmGlobal.ListarCalendario(idUsuario: integer; dt: string): TJSONArray;
var
  qry: TFDQuery;
begin
  try
    qry:= TFDQuery.Create(nil);
    qry.Connection:= Conn;

    qry.SQL.Clear;
    qry.SQL.Add('select descricao, hora from tab_calendario where dt_evento = :dt_evento ');
    qry.SQL.Add(' and (id_usuario = :id_usuario or id_usuario = 0) ');
    qry.ParamByName('dt_evento').Value:= dt;
    qry.ParamByName('id_usuario').Value:= idUsuario;
    qry.SQL.Add('order by hora ');
    qry.Open;

    Result:= qry.ToJSONArray;

  finally
    FreeAndNil(qry);
  end;

end;

function TDmGlobal.ListarUsuarios(idResponsavel: integer): TJSONArray;
var
  qry: TFDQuery;
begin
  try
    qry:= TFDQuery.Create(nil);
    qry.Connection:= Conn;

    qry.SQL.Clear;
    qry.SQL.Add('select u.id_usuario, u.nome ');
    qry.SQL.Add('from tab_usuario_responsavel r ');
    qry.SQL.Add('join tab_usuario u on u.id_usuario = r.id_usuario ');
    qry.SQL.Add('where r.id_responsavel = :id_responsavel ');
    qry.ParamByName('id_responsavel').Value:= idResponsavel;
    qry.SQL.Add('order by u.nome');
    qry.Open;

    Result:= qry.ToJSONArray;

  finally
    FreeAndNil(qry);
  end;

end;

function TDmGlobal.Login(cpf, senha: string): TJSONObject;
var
  qry: TFDQuery;
begin
  try
    qry:= TFDQuery.Create(nil);
    qry.Connection:= Conn;

    qry.SQL.Clear;
    qry.SQL.Add('select u.id_usuario, u.nome, u.cpf, u.tipo_usuario, count(r.id_usuario) as qtd_usuarios ');
    qry.SQL.Add('from tab_usuario u ');
    qry.SQL.Add('left join tab_usuario_responsavel r  on (r.id_responsavel = u.id_usuario) ');
    qry.SQL.Add('where u.cpf = :cpf and u.senha = :senha ');
    qry.SQL.Add('group by u.id_usuario, u.nome, u.cpf, u.tipo_usuario ');
    qry.ParamByName('cpf').Value:= cpf;
    qry.ParamByName('senha').Value:= senha;
    qry.Open;

    Result:= qry.ToJSONObject;

  finally
    FreeAndNil(qry);
  end;

end;

end.
