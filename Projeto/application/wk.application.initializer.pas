unit wk.application.initializer;

interface

uses
  System.SysUtils, Vcl.Forms,
  wk.connection.conn, wk.view.PedidoVenda;

type
  TAppInitializer = class
  public
    class procedure Run;
  end;

implementation

{ TAppInitializer }

class procedure TAppInitializer.Run;
var
  LMessage: string;
begin
  // ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.Title := 'Cadastro de Pedidos de Venda';
  try
    dmConn := TdmConn.Create(nil);
  except
    on E:Exception do
    begin
      if dmConn.DataBaseConnected then
        Application.ShowException(E)
      else
      begin
        LMessage:=
          'Esta aplicação será finalizada!' + sLineBreak + E.Message;
        Application.ShowException(Exception.Create(LMessage));
      end;
      Application.Terminate;
      Exit;
    end;
  end;

  try
    Application.MainFormOnTaskbar := True;
    Application.CreateForm(TfrmPedidoVenda, frmPedidoVenda);
    Application.Run;
  except
    on E: Exception do
    begin
      Application.ShowException(E);
      Application.Terminate;
    end;
  end;
end;

end.

