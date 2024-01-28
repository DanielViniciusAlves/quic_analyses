defmodule Manager.Handler do
  use GenServer

  require Logger
  alias Manager.Pubsub
  alias Manager.ConfigStruct
  alias Pubsub

  def start_link(config) do
    GenServer.start_link(__MODULE__, config)
  end

  @impl true
  @spec init(config :: ConfigStruct.t()) :: {:ok, ConfigStruct.t()}
  def init(config) do
    Pubsub.subscribe(:manager)
    Pubsub.broadcast(:client_api, {:init, config})
    Pubsub.broadcast(:server_api, :init)
    {:ok, config}
  end

  @impl true
  def handle_info({:client_terminate, :completed}, state) do
    {:stop, :normal, state}
  end

  @impl true
  def handle_info({:client_terminate, {:client_error, reason}}, state) do
    Logger.info(reason.message)
    {:stop, :normal, state}
  end

  @impl true
  def handle_info({:server_terminate, _reason}, state) do
    {:stop, :normal, state}
  end

  @impl true
  @spec terminate(any(), state :: ConfigStruct.t()) :: any()
  def terminate(_reason, _state) do
    Manager.set_status(:off)
  end
end
