defmodule Client.Genserver.Client do
  use GenServer, restart: :transient

  alias Client.Connection.ConnectionHandler, as: Connection
  alias Client.Struct.ClientStruct
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
      {:error, reason} ->
        Logger.info("Stoping Client")
        {:stop, reason}

      {:ok, state} ->
        {:ok, state}
    end
  end

  @impl true
  @spec handle_info(:start, state :: ClientStruct.t()) :: {:stop, any(), any()}
  def handle_info(:start, state) do
    {:ok, data} = :code.priv_dir(:client) |> Path.join("default_audio.opus") |> File.read()

    case send_data(data, 80, state) do
      {:ok, _response} ->
        {:stop, :normal, :normal}

      other ->
        {:stop, :normal, other}
    end
  end

  @impl true
  @spec handle_info({:stop, reason :: any()}, state :: ClientStruct.t()) ::
          {:stop, :normal, any()}
  def handle_info({:stop, reason}, _state) do
    {:stop, :normal, reason}
  end

  @impl true
  @spec handle_info(any(), state :: ClientStruct.t()) :: {:noreply, ClientStruct.t()}
  def handle_info(message, state) do
    state.connection_handler.handle_connection(message, state)
    {:noreply, state}
  end

  @impl true
  @spec terminate(any(), any()) :: any()
  def terminate(_reason, reason) do
    Logger.info("Stoping Client")

    case reason do
      :normal ->
        Pubsub.broadcast(:client, {:client_stop, :completed})

      {:error, reason} ->
        Pubsub.broadcast(:client, {:client_stop, reason})

      :finished ->
        :ok

      reason ->
        Pubsub.broadcast(:client, {:client_stop, reason})
    end
  end

  @spec send_data(data :: binary(), offset :: integer(), state :: ClientStruct.t()) ::
          {:ok, state :: ClientStruct.t()} | {:error, Error.t()}
  defp send_data(data, offset, state) when offset > 0 do
    <<new_data::binary-size(offset), rest::binary>> = data
    state.connection_handler.send(state, "audio" <> new_data)
    :timer.sleep(40)

    if(byte_size(rest) >= 80) do
      send_data(rest, 80, state)
    else
      send_data(rest, byte_size(rest), state)
    end
  end

  defp send_data(_data, _offset, state) do
    Logger.debug("End")
    state.connection_handler.send(state, "end_message")
  end
end
