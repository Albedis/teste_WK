object dmPedido: TdmPedido
  OnCreate = DataModuleCreate
  Height = 311
  Width = 435
  object cdsItensPedido: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 72
    Top = 40
  end
  object dsItensPedido: TDataSource
    DataSet = cdsItensPedido
    Left = 176
    Top = 40
  end
end
