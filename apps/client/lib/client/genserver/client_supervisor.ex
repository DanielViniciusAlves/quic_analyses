defmodule Client.Genserver.Supervisor do
  use DynamicSupervisor

  alias Client.Struct.ClientStruct
  alias Client.Error.ErrorHandler, as: Error
  alias Client.Genserver.Client
  alias Client.Struct.ClientManagerStruct
  alias Manager.Pubsub

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

      _error ->
        Pubsub.broadcast(:client, {:client_stop, Error.exception(:client_init)})
        {:error, Error.exception(:client_init)}
    end
  end

  # Callback

  @spec start_clients(ClientManagerStruct.t()) :: :ok | {:error, Error.t()}
  def start_clients(config) do
    Enum.each(0..config.clients_number, fn id ->
      config = %ClientStruct{
        connection_duration: config.connection_duration,
        connection_type: config.connection_duration,
        id: id
      }

      start_client(config)
    end)
  end
end
