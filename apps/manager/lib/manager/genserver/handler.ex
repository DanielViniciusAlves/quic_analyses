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
    Logger.info("Starting")
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
    Logger.info("Completed!!!")
    {:noreply, state}
  end

  @impl true
  def handle_info({:client_terminate, {:client_error, reason}}, state) do
    Logger.info(reason.message)
    {:stop, :normal, state}
  end

  @impl true
  def handle_info({:server_terminate, _reason}, state) do
    Logger.info("Server Completed!!!")
    {:stop, :normal, state}
  end

  @impl true
  @spec terminate(any(), state :: ConfigStruct.t()) :: any()
# add timeout to start the config
  def terminate(_reason, _state) do
    Logger.info ("Test Completed")
    Pubsub.broadcast(:server_api, :stop)
    Pubsub.broadcast(:client_api, :stop)
    Manager.set_status(:off)
    cleanup_ambient()
  end

  defp cleanup_ambient() do
    cmd = "tc"
    args = ["qdisc", "del", "dev", "lo", "root"]

    System.cmd(cmd, args)
  end
end
