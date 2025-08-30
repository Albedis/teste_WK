object dmConn: TdmConn
  OnCreate = DataModuleCreate
  Height = 351
  Width = 510
  object FDConn: TFDConnection
    Params.Strings = (
      'Database=wkdatabase'
      'Server=localhost'
      'User_Name=root'
      'CharacterSet=utf8'
      'Compress=False'
      'DriverID=MySQL')
    FormatOptions.AssignedValues = [fvADOCompatibility]
    FormatOptions.ADOCompatibility = True
    ResourceOptions.AssignedValues = [rvAutoConnect]
    ResourceOptions.AutoConnect = False
    TxOptions.Params.Strings = (
      'DriverID=MySQL'
      'Server=127.0.0.1'
      'Port=3306'
      'Database=wkdatabase'
      'User_Name=root'
      'Password='
      'CharacterSet=utf8mb4'
      'SSLMode=DISABLED')
    Connected = True
    LoginPrompt = False
    Left = 64
    Top = 8
  end
  object FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink
    VendorLib = 'C:\Teste_WK\Projeto\library\libmysql.dll'
    Left = 64
    Top = 80
  end
end
