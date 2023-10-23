unit Provider.Session;

interface

type

  TSession = class
    private
    class var FID_USUARIO: Integer;
    class var FNOME: String;
    class var FTIPO_USUARIO: String;
    class var FID_RESPONSAVEL: Integer;
    public
      class property ID_USUARIO: Integer read FID_USUARIO write FID_USUARIO;
      class property ID_RESPONSAVEL: Integer read FID_RESPONSAVEL write FID_RESPONSAVEL;
      class property NOME: String read FNOME write FNOME;
      class property TIPO_USUARIO: String read FTIPO_USUARIO write FTIPO_USUARIO;
  end;

implementation

end.
