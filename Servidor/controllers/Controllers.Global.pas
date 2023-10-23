unit Controllers.Global;

interface

uses
  Horse,
  System.JSON,
  System.SysUtils,
  DataModule.Global;

procedure RegistrarRotas;
procedure ListarMensagens(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure InserirMensagem(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure EditarMensagem(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure ExcluirMensagem(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure ListarBoletim(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure ListarCalendario(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure ListarUsuarios(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure Login(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

procedure RegistrarRotas;
begin
  THorse.Get('/social', ListarMensagens);
  THorse.Post('/social', InserirMensagem);
  THorse.Put('/social/:id_mensagem', EditarMensagem);
  THorse.Delete('/social/:id_mensagem', ExcluirMensagem);

  THorse.Get('/boletim', ListarBoletim);
  THorse.Get('/calendario', ListarCalendario);
  THorse.Get('/usuarios', ListarUsuarios);
  THorse.Post('/usuarios/login', Login); //para que os dados sejam enviados no body e não na URL
end;

procedure ListarMensagens(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Dm: TDmGlobal;
  idUsuario, pagina: integer;
begin
  try
    try
      Dm:= TDmGlobal.Create(nil);

      try
        idUsuario:= Req.Query['id_usuario'].ToInteger;
      except
        idUsuario:= 0;
      end;

      try
        pagina:= Req.Query['pagina'].ToInteger;
      except
        pagina:= 0;
      end;

      Res.Send<TJSONArray>(Dm.ListarMensagens(idUsuario, pagina)).Status(200);

    except on ex:Exception do
      Res.Send('Ocorreu um erro: ' + ex.Message).Status(500);
    end;
  finally
    FreeAndNil(Dm);  //fechar a conexão para seguir o padrão stateless...
  end;
end;

procedure InserirMensagem(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Dm: TDmGlobal;
  body: TJSONObject;
  idUsuario: integer;
  mensagem: string;
begin
  try
    try
      Dm:= TDmGlobal.Create(nil);

      body:= Req.Body<TJSONObject>;
      idUsuario:= body.GetValue<integer>('id_usuario',0);
      mensagem:= body.GetValue<string>('mensagem', '');

      Res.Send<TJSONObject>(Dm.InserirMensagem(idUsuario, mensagem)).Status(201);

    except on ex:Exception do
      Res.Send('Ocorreu um erro: ' + ex.Message).Status(500);
    end;
  finally
    FreeAndNil(Dm);  //fechar a conexão para seguir o padrão stateless...
  end;
end;

procedure EditarMensagem(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Dm: TDmGlobal;
  body: TJSONObject;
  idMensagem: integer;
  mensagem: string;
begin
  try
    try
      Dm:= TDmGlobal.Create(nil);

      //PUT --> http:localhost:9000/social/123 {URI PARAMS}
      //GET --> http:localhost:9000/social?id_mensagem=123 {QUERY PARAMS}

      try
        idMensagem:= Req.Params.Items['id_mensagem'].ToInteger;
      except
        idMensagem:= 0;
      end;

      body:= Req.Body<TJSONObject>;
      mensagem:= body.GetValue<string>('mensagem', '');

      Dm.EditarMensagem(idMensagem, mensagem);

      Res.Send('Registro alterado!').Status(200);

    except on ex:Exception do
      Res.Send('Ocorreu um erro: ' + ex.Message).Status(500);
    end;
  finally
    FreeAndNil(Dm);  //fechar a conexão para seguir o padrão stateless...
  end;
end;

procedure ExcluirMensagem(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Dm: TDmGlobal;
  idMensagem: integer;
begin
  try
    try
      Dm:= TDmGlobal.Create(nil);

      try
        idMensagem:= Req.Params.Items['id_mensagem'].ToInteger;
      except
        idMensagem:= 0;
      end;

      Dm.ExcluirMensagem(idMensagem);

      Res.Send('Registro excluido!').Status(200);

    except on ex:Exception do
      Res.Send('Ocorreu um erro: ' + ex.Message).Status(500);
    end;
  finally
    FreeAndNil(Dm);  //fechar a conexão para seguir o padrão stateless...
  end;
end;

procedure ListarBoletim(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Dm: TDmGlobal;
  idUsuario: integer;
  periodo: string;
begin
  try
    try
      Dm:= TDmGlobal.Create(nil);

      try
        idUsuario:= Req.Query['id_usuario'].ToInteger;
      except
        idUsuario:= 0;
      end;

      try
        periodo:= Req.Query['periodo'];
      except
        periodo:= '';
      end;

      Res.Send<TJSONArray>(Dm.ListarBoletim(idUsuario, periodo)).Status(200);

    except on ex:Exception do
      Res.Send('Ocorreu um erro: ' + ex.Message).Status(500);
    end;
  finally
    FreeAndNil(Dm);  //fechar a conexão para seguir o padrão stateless...
  end;
end;

procedure ListarCalendario(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Dm: TDmGlobal;
  idUsuario: integer;
  data: string;
begin
  try
    try
      Dm:= TDmGlobal.Create(nil);

      try
        idUsuario:= Req.Query['id_usuario'].ToInteger;
      except
        idUsuario:= 0;
      end;

      try
        data:= Req.Query['dt'];
      except
        data:= '';
      end;

      Res.Send<TJSONArray>(Dm.ListarCalendario(idUsuario, data)).Status(200);

    except on ex:Exception do
      Res.Send('Ocorreu um erro: ' + ex.Message).Status(500);
    end;
  finally
    FreeAndNil(Dm);  //fechar a conexão para seguir o padrão stateless...
  end;
end;

procedure ListarUsuarios(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Dm: TDmGlobal;
  idResponsavel: integer;
begin
  try
    try
      Dm:= TDmGlobal.Create(nil);

      try
        idResponsavel:= Req.Query['id_responsavel'].ToInteger;
      except
        idResponsavel:= 0;
      end;

      Res.Send<TJSONArray>(Dm.ListarUsuarios(idResponsavel)).Status(200);

    except on ex:Exception do
      Res.Send('Ocorreu um erro: ' + ex.Message).Status(500);
    end;
  finally
    FreeAndNil(Dm);  //fechar a conexão para seguir o padrão stateless...
  end;
end;

procedure Login(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Dm: TDmGlobal;
  body, json: TJSONObject;
  cpf, senha: string;
begin
  try
    try
      Dm:= TDmGlobal.Create(nil);

      body:= Req.Body<TJSONObject>;
      cpf:= body.GetValue<string>('cpf', '');
      senha:= body.GetValue<string>('senha', '');

      json:= Dm.Login(cpf, senha);

      if (json.Size = 0) then
      begin
        Res.Send('CPF ou Senha inválida').Status(401);
        FreeAndNil(json);
      end
      else
        Res.Send<TJSONObject>(json).Status(200);

    except on ex:Exception do
      Res.Send('Ocorreu um erro: ' + ex.Message).Status(500);
    end;
  finally
    FreeAndNil(Dm);  //fechar a conexão para seguir o padrão stateless...
  end;
end;

end.
