object dmConsulta: TdmConsulta
  OnCreate = DataModuleCreate
  Height = 480
  Width = 640
  object qryCliente: TFDQuery
    Connection = dmConn.FDConn
    SQL.Strings = (
      'Select * from cliente')
    Left = 64
    Top = 64
  end
  object qryProduto: TFDQuery
    Connection = dmConn.FDConn
    SQL.Strings = (
      ' Select * from produto')
    Left = 64
    Top = 144
  end
  object qryPedido: TFDQuery
    Connection = dmConn.FDConn
    Left = 64
    Top = 216
  end
  object qryPedidoItem: TFDQuery
    Connection = dmConn.FDConn
    SQL.Strings = (
      'select '
      'produto.id_produto,'
      'produto.descricao,'
      'pedido_item.quantidade,'
      'pedido_item.valor_unitario, '
      'pedido_item.valor_total'
      'from pedido_item'
      
        'inner join produto on produto.id_produto = pedido_item.id_produt' +
        'o'
      'where pedido_item.id_pedido = 1'
      'order by pedido_item.id_pedido_item;')
    Left = 64
    Top = 288
  end
  object cdsPedidoItem: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 160
    Top = 288
  end
  object cdsPedido: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 160
    Top = 224
  end
end
