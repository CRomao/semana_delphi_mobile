object DmGlobal: TDmGlobal
  OnCreate = DataModuleCreate
  Height = 248
  Width = 386
  object Conn: TFDConnection
    Params.Strings = (
      'LockingMode=Normal'
      'DriverID=sQLite')
    ConnectedStoredUsage = []
    LoginPrompt = False
    BeforeConnect = ConnBeforeConnect
    Left = 56
    Top = 88
  end
  object FDPhysSQLiteDriverLink: TFDPhysSQLiteDriverLink
    Left = 152
    Top = 40
  end
end
