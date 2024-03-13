defmodule Client.Genserver.Supervisor do
  use DynamicSupervisor

  alias Client.Struct.ClientStruct
  alias Client.Error.ErrorHandler, as: Error
  alias Client.Genserver.Client
  alias Client.Struct.ClientManagerStruct
  require Logger

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @spec start_client(ClientStruct.t()) :: :ok | {:error, Error.t()}
  def start_client(config) do
    case DynamicSupervisor.start_child(__MODULE__, {Client, config}) do
      {:ok, _pid} ->
        :ok

      {:error, reason} ->
        IO.inspect(reason)
        {:error, reason}
    end
  end

  # Callback

  @spec start_clients(ClientManagerStruct.t()) :: :ok | {:error, Error.t()}
  def start_clients(config) when config.clients_number > 0 do
    with :ok <-
           %ClientStruct{
             connection_duration: config.connection_duration,
             connection_type: config.connection_type,
             id: config.clients_number
           }
           |> start_client() do
      start_clients(%{config | clients_number: config.clients_number - 1})
    else
      response ->
        response
    end
  end

  def start_clients(_config), do: :ok
end
