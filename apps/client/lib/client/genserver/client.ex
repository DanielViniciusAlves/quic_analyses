defmodule Client.Genserver.Client do
  use GenServer, restart: :transient

  alias Client.Error.ErrorHandler, as: Error
  alias Client.Connection.ConnectionHandler, as: Connection
  alias Manager.Pubsub
  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  @impl true
  def init(init_config) do
    Logger.info("Client Started")
    Pubsub.subscribe(:client)

    case Connection.start(init_config) do
      {:stop, _reason} ->
        Logger.info("Stoping Client")
        {:stop, :normal, :normal}

      {:ok, state} ->
        {:ok, state}
    end
  end

  @impl true
  def handle_cast(:init, state) do
    case Connection.start(state) do
      {:stop, _reason} ->
        Logger.info("Stoping Client")
        {:noreply, state}

      {:ok, state} ->
        {:noreply, state}
    end
  end

  @impl true
  def handle_info(:start, state) do
    {:ok, data} = :code.priv_dir(:client) |> Path.join("default_audio.opus") |> File.read()
    send_data(data, 80, state)
    {:stop, :normal, :normal}
  end

  defp send_data(data, offset, state) when offset > 0 do
    <<new_data::binary-size(offset), rest::binary>> = data
    state.connection_handler.send(state, "audio" <> new_data)
    :timer.sleep(40)

    if(byte_size(rest) >= 80) do
      send_data(rest, 80, state)
    else
      # Logger.info("End")
      send_data(rest, byte_size(rest), state)
    end
  end

  defp send_data(data, _offset, state) do
    Logger.debug("End")
    state.connection_handler.send(state, "end_message")
  end

  @impl true
  def handle_info(:stop, _state) do
    {:stop, :normal, :normal}
  end

  @impl true
  def handle_info(message, state) do
    state.connection_handler.handle_connection(message, state)
    {:noreply, state}
  end

  @impl true
  def terminate(_reason, reason) do
    case reason do
      :error ->
        Pubsub.broadcast(:client, {:client_stop, Error.exception(:client_error)})

      _reason ->
        Pubsub.broadcast(:client, {:client_stop, :completed})
        :ok
    end
  end
end
