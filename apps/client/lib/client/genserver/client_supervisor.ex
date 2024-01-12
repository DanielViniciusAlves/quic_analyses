defmodule Client.Genserver.Supervisor do
  use DynamicSupervisor

  alias Client.Error.ErrorHandler, as: Error
  alias Client.Genserver.Client
  alias Manager.Pubsub

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @spec start_client(connection_duration :: integer) :: :ok | {:error, Error.t()}
  def start_client(connection_duration) do
    case DynamicSupervisor.start_child(__MODULE__, {Client, connection_duration}) do
      {:ok, _pid} ->
        :ok

      _error ->
        Pubsub.broadcast(:client, {:client_stop, Error.exception(:client_init)})
        {:error, Error.exception(:client_init)}
    end
  end

  # Callback

  @spec start_clients(clients_number :: integer, connection_duration :: integer) ::
          :ok | {:error, Error.t()}
  def start_clients(clients_number, connection_duration) do
    Enum.each(0..clients_number, fn _x ->
      start_client(connection_duration)
    end)
  end
end
