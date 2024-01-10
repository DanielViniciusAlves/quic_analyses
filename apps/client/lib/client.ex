defmodule Client do
  use GenServer

  alias Client.ClientStruct
  alias Client.Manager, as: ClientManager
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
    {:ok, %ClientStruct{}}
  end

  @impl true
  @spec handle_cast({:init, config :: ConfigStruct.t()}, state :: ClientStruct.t()) ::
          {:noreply, ClientStruct.t()}
  def handle_cast({:init, config}, state) do
    Logger.info("Client is starting.")

    with info <- Map.merge(state, config) do
      ClientManager.start_clients(info.clients_number, info.connection_duration)
      {:noreply, info}
    else
      _error ->
        Pubsub.broadcast(:client_api, Error.create(:client_error, "Error initializing Client"))
        {:noreply, state}
    end
  end

  # @impl true
  # def handle_cast({:client_teminate, _reason}, state) do
  #   {:noreply, state}
  # end
end
