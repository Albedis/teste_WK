unit wk.repository.cliente;

interface

uses
  System.SysUtils, System.Generics.Collections,
  FireDAC.Comp.Client,
  wk.model.cliente, wk.sql.cliente, Data.DB;

type
  TClienteRepository = class
  private
    FConn: TFDConnection;
    FCache: TObjectDictionary<Integer, TCliente>;
    function DataSetToModel(ADataSet: TDataSet): TCliente;
  public
    constructor Create(AConn: TFDConnection);
    destructor Destroy; override;

    function BuscarPorId(AId: Integer): TCliente;
    function BuscarPorNome(const ATermo: string): TObjectList<TCliente>;
    function ListarTodos: TObjectDictionary<Integer, TCliente>;
    procedure LimparCache;
  end;

implementation

uses
  StrUtils, wk.factory.model;

{ TClienteRepository }

constructor TClienteRepository.Create(AConn: TFDConnection);
begin
  FConn := AConn;
  FCache := TObjectDictionary<Integer, TCliente>.Create([doOwnsValues]);
end;

destructor TClienteRepository.Destroy;
begin
  FCache.Free;
  inherited;
end;

function TClienteRepository.BuscarPorId(AId: Integer): TCliente;
var
  LQuery: TFDQuery;
begin
  if FCache.TryGetValue(AId, Result) then
    Exit;

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConn;
    LQuery.SQL.Text := TClienteSQL.SelectById;
    LQuery.ParamByName('id').AsInteger := AId;
    LQuery.Open;

    if LQuery.IsEmpty then
    begin
      Result := nil;
      Exit;
    end;

    Result := DataSetToModel(LQuery);
    FCache.Add(Result.id_cliente, Result);

  finally
    LQuery.Free;
  end;
end;

function TClienteRepository.BuscarPorNome(const ATermo: string): TObjectList<TCliente>;
var
  LCliente: TCliente;
  LResultado: TObjectList<TCliente>;
begin
  if FCache.Count = 0 then
    ListarTodos;

  LResultado := TObjectList<TCliente>.Create(False);
  for LCliente in FCache.Values do
    if ContainsText(LCliente.Nome, ATermo) then
      LResultado.Add(LCliente);

  Result := LResultado;
end;

function TClienteRepository.ListarTodos: TObjectDictionary<Integer, TCliente>;
var
  LQuery: TFDQuery;
  LCliente: TCliente;
begin
  if FCache.Count > 0 then
    Exit(FCache);

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConn;
    LQuery.SQL.Text := TClienteSQL.LoadAll;
    LQuery.Open;

    while not LQuery.Eof do
    begin
      LCliente := DataSetToModel(LQuery);
      FCache.AddOrSetValue(LCliente.id_cliente, LCliente);
      LQuery.Next;
    end;
  finally
    LQuery.Free;
  end;

  Result := FCache;
end;

procedure TClienteRepository.LimparCache;
begin
  FCache.Clear;
end;

function TClienteRepository.DataSetToModel(ADataSet: TDataSet): TCliente;
begin
  Result := TModelFactory.ClienteFromDataset(ADataSet);
end;

end.

