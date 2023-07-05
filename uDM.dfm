object DM: TDM
  Height = 900
  Width = 614
  PixelsPerInch = 144
  object Conn: TFDConnection
    Params.Strings = (
      
        'Database=C:\Users\62822\Downloads\APM\UASPMFIX\assets\database\d' +
        'bSample.db'
      'DriverID=SQLite')
    LoginPrompt = False
    BeforeConnect = ConnBeforeConnect
    Left = 192
    Top = 115
  end
  object QTemp1: TFDQuery
    Connection = Conn
    Left = 346
    Top = 115
  end
end
