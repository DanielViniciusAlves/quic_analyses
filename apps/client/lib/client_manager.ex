defmodule Client.Manager do
  use GenServer

  alias Client.Genserver.Supervisor, as: ClientSupervisor
  alias Client.Error.ErrorHandler, as: Error
  alias Client.Struct.ClientManagerStruct
  alias Manager.ConfigStruct
  alias Manager.NetemConfig
  alias Manager.Pubsub

  require Logger

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [])
  end

  @impl true
  def init(_args) do
    Pubsub.subscribe(:client_api)
    Pubsub.subscribe(:client)
    {:ok, %ClientManagerStruct{}}
  end

  @impl true
  @spec handle_info({:init, config :: ConfigStruct.t()}, state :: ClientManagerStruct.t()) ::
          {:noreply, ClientManagerStruct.t()}
  def handle_info({:init, config}, state) do
    Logger.info("Client is starting.")

    with info <- Map.merge(state, config),
         :ok <- start_test(info) do
      {:noreply, info}
    else
      {:error, reason} ->
        Pubsub.broadcast(:manager, {:client_terminate, {:client_error, reason}})
        Pubsub.broadcast(:client, {:stop, reason})
        {:stop, :normal, state}

      reason ->
        Pubsub.broadcast(
          :manager,
          {:client_terminate, {:client_error, reason}}
        )

        {:stop, :normal, state}
    end
  end

  @impl true
  @spec handle_info(
          {:client_stop, reason :: Error.t() | :completed},
          state :: ClientManagerStruct.t()
        ) :: {:noreply, ClientManagerStruct.t()}
  def handle_info({:client_stop, reason}, state) do
    case reason do
      :completed ->
        client_number = Map.get(state, :clients_number)

        if(client_number == 1) do
          Pubsub.broadcast(:manager, {:client_terminate, :completed})
        end

        {:noreply, Map.put(state, :clients_number, client_number - 1)}

      reason ->
        Pubsub.broadcast(:manager, {:client_terminate, {:client_error, reason}})
        Pubsub.broadcast(:client, {:stop, Error.exception(:invalid_run)})

        {:stop, :normal, state}
    end
  end

  @impl true
  @spec handle_info(:stop, state :: ClientManagerStruct.t()) ::
          {:stop, :normal, ClientManagerStruct.t()}
  def handle_info({:stop, reason}, state) do
    Pubsub.broadcast(:client, {:stop, reason})
    {:stop, :normal, state}
  end

  @spec start_test(info :: ConfigStruct.t()) :: :ok | {:error, String.t()}
  defp start_test(info) do
    case info.delay_netem_config do
      true ->
        case ClientSupervisor.start_clients(info) do
          :ok ->
            Pubsub.broadcast(:client, :start)
            NetemConfig.config_enviroment(info)

          other ->
            other
        end

      false ->
        case NetemConfig.config_enviroment(info) do
          :ok ->
            case ClientSupervisor.start_clients(info) do
              :ok ->
                Pubsub.broadcast(:client, :start)
                :ok

              other ->
                other
            end

          other ->
            other
        end
    end
  end
end
