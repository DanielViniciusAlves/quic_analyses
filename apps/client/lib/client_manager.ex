defmodule Client.Manager do
  use GenServer

  alias Client.ClientStruct
  alias Client.Genserver.Supervisor, as: ClientSupervisor
  alias Client.Error.ErrorHandler, as: Error
  alias Manager.ConfigStruct
  alias Manager.Pubsub

  require Logger

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [])
  end

  @impl true
  def init(_args) do
    Pubsub.subscribe(:client_api)
    Pubsub.subscribe(:client)
    {:ok, %ClientStruct{}}
  end

  @impl true
  @spec handle_info({:init, config :: ConfigStruct.t()}, state :: ClientStruct.t()) ::
          {:noreply, ClientStruct.t()}
  def handle_info({:init, config}, state) do
    with info <- Map.merge(state, config),
         :ok <- ClientSupervisor.start_clients(info.clients_number, info.connection_duration) do
      Logger.info("Client is starting.")

      Pubsub.broadcast(
        :manager,
        {:client_terminate, {:client_error, Error.exception(:client_init)}}
      )

      {:noreply, info}
    else
      _reason ->
        Pubsub.broadcast(
          :manager,
          {:client_terminate, {:client_error, Error.exception(:client_init)}}
        )

        {:noreply, state}

      {:error, reason} ->
        Pubsub.broadcast(:manager, {:client_terminate, {:client_error, reason}})
        {:noreply, state}
    end
  end

  @impl true
  @spec handle_info({:client_stop, reason :: Error.t() | :completed}, state :: ClientStruct.t()) ::
          {:noreply, ClientStruct.t()}
  def handle_info({:client_stop, reason}, state) do
    case reason do
      :completed ->
        case Map.get(state, :client_number) do
          0 ->
            Pubsub.broadcast(:manager, {:client_terminate, :completed})
            {:noreply, %ConfigStruct{}}

          client_number ->
            {:noreply, Map.put(state, :client_number, client_number)}
        end

      reason ->
        Logger.error(Error.exception(:invalid_run))
        Logger.error(reason)

        Pubsub.broadcast(:manager, {:client_terminate, {:client_eror, reason}})
        Pubsub.broadcast(:client, {:stop, Error.exception(:invalid_run)})

        {:noreply, state}
    end
  end
end
