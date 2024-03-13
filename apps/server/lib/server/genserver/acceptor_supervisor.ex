defmodule Server.Genserver.Supervisor do
  use DynamicSupervisor

  alias Server.Struct.ServerStruct
  alias Server.Error.ErrorHandler, as: Error
  alias Server.Genserver.Acceptor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @spec start_acceptor(ServerStruct.t()) :: :ok | {:error, Error.t()}
  def start_acceptor(connection) do
    case DynamicSupervisor.start_child(__MODULE__, {Acceptor, connection}) do
      {:ok, pid} ->
        pid

      {:error, reason} ->
        {:error, reason}
    end
  end
end
