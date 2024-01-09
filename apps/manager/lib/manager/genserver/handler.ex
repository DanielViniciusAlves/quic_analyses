defmodule Manager.Handler do
  use GenServer

  alias Manager.ConfigStruct
  alias Manager.Pubsub

  def start_link(config) do
    GenServer.start_link(__MODULE__, config)
  end

  @impl true
  @spec init(config :: ConfigStruct.t()) :: {:ok, ConfigStruct.t()}
  def init(config) do
    Pubsub.subscribe(:manager)
    Pubsub.broadcast(:client_manager, :init)
    Pubsub.broadcast(:server_manager, :init)
    {:ok, config}
  end

  @impl true
  def handle_cast({:client_terminate, _reason}, state) do
    {:noreply, state}
  end

  @impl true
  def handle_cast({:server_terminate, _reason}, state) do
    {:noreply, state}
  end
end
