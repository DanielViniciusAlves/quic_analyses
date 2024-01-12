defmodule Client.Genserver.Client do
  use GenServer

  alias Client.Error.ErrorHandler, as: Error
  alias Manager.Pubsub
  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  @impl true
  def init(init_config) do
    # Logger.info("Client Started")
    Pubsub.subscribe(:client)
    {:ok, init_config}
  end

  @impl true
  def handle_info(message, state) do
    IO.inspect(message)
    {:noreply, state}
  end

  @impl true
  def terminate(reason, _state) do
    Logger.error(reason)
    Pubsub.broadcast(:client, {:client_stop, Error.exception(:client_error)})
  end
end
