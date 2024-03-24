defmodule Server.Genserver.Acceptor do
  @moduledoc """
  This module implements a GenServer for accepting connections.

  It subscribes to relevant PubSub topics and handles incoming messages and casts.

  """
  use GenServer, restart: :transient

  alias Manager.Pubsub
  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  @impl true
  def init(init_state) do
    Pubsub.subscribe(:acceptor)

    GenServer.cast(Kernel.self(), :accept)

    {:ok, Map.put(init_state, :timer, :os.system_time(:millisecond))}
  end

  @impl true
  def handle_info({:stop, _reason}, _state) do
    {:stop, :normal, :stop}
  end

  @impl true
  def handle_info(message, state) do
    state.connection_handler.handle_message(message, state)
  end

  @impl true
  def handle_cast(:accept, state) do
    case state.connection_handler.handle_connection(state) do
      {:error, _reason} ->
        {:stop, :normal, :accept}

      other ->
        other
    end
  end

  @impl true
  def terminate(_info, reason) do
    case reason do
      :error ->
        Pubsub.broadcast(:server, {:error, reason})

      _reason ->
        :ok
    end
  end
end
