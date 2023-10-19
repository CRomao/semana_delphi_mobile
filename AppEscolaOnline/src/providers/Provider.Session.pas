unit Provider.Session;

interface

type

  TSession = class
    private
    class var FID_USUARIO: Integer;
    class var FNOME: String;
    class var FEMAIL: String;
    public
      class property ID_USUARIO: Integer read FID_USUARIO write FID_USUARIO;
      class property NOME: String read FNOME write FNOME;
      class property EMAIL: String read FEMAIL write FEMAIL;
  end;

implementation

end.
