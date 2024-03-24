defmodule Manager.Handler do
  use GenServer

  require Logger
  alias Manager.ConfigStruct
  alias Manager.NetemConfig
  alias Manager.Pubsub
  alias Pubsub

  def start_link(config) do
    GenServer.start_link(__MODULE__, config)
  end

  @impl true
  @spec init(config :: ConfigStruct.t()) :: {:ok, ConfigStruct.t()}
  def init(config) do
    Logger.info("Starting test.")
    Pubsub.subscribe(:manager)
    Pubsub.broadcast(:server_api, {:init, config})
    {:ok, config}
  end

  @impl true
  def handle_info(:server_started, state) do
    Pubsub.broadcast(:client_api, {:init, state})
    {:noreply, state}
  end

  @impl true
  def handle_info({:client_terminate, :completed}, state) do
    Logger.info("Client finished sending data.")
    {:noreply, state}
  end

  @impl true
  def handle_info({:client_terminate, {:client_error, reason}}, state) do
    Logger.error(reason)
    {:stop, :normal, state}
  end

  @impl true
  def handle_info({:server_terminate, reason}, state) do
    Logger.info("Server finished all connections.")

    case reason do
      {:error, reason} ->
        Logger.error(reason)

      _other ->
        true
    end

    {:stop, :normal, state}
  end

  @impl true
  @spec terminate(any(), state :: ConfigStruct.t()) :: any()
  def terminate(_reason, _state) do
    Pubsub.broadcast(:server_api, {:stop, :finished})
    Pubsub.broadcast(:client_api, {:stop, :finished})
    Manager.set_status(:off)
    NetemConfig.cleanup_ambient()
    Logger.info("Test finished!")
  end
end
