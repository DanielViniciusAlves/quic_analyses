defmodule Manager.Handler do
  use GenServer

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
    turn_off()
    {:noreply, state}
  end

  @impl true
  def handle_info({:client_terminate, {:client_error, _reason}}, state) do
    turn_off()
    {:noreply, state}
  end

  @impl true
  def handle_info({:server_terminate, _reason}, state) do
    {:noreply, state}
  end

  @spec turn_off() :: :ok
  defp turn_off() do
    Manager.set_status(:off)
    :ok
  end
end
