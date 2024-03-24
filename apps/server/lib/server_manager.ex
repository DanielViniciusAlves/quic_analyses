defmodule Server.Manager do
  use GenServer

  alias Server.Connection.Handler, as: Connection
  alias Server.Error.ErrorHandler, as: Error
  alias Server.Struct.ServerManagerStruct
  alias Manager.ConfigStruct
  alias Manager.Pubsub

  require Logger

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [])
  end

  @impl true
  def init(_args) do
    Pubsub.subscribe(:server_api)
    Pubsub.subscribe(:server)
    {:ok, %ServerManagerStruct{}}
  end

  @impl true
  @spec handle_info({:init, config :: ConfigStruct.t()}, state :: ServerManagerStruct.t()) ::
          {:noreply, ServerManagerStruct.t()}
  def handle_info({:init, config}, state) do
    with info <- Map.put(state, :connection_type, config.connection_type),
         info <- Map.put(info, :clients_number, config.clients_number),
         :ok <- Connection.start(info) do
      Logger.info("Server is starting.")
      Pubsub.broadcast(:manager, :server_started)

      {:noreply, info}
    else
      {:error, reason} ->
        Pubsub.broadcast(:manager, {:server_terminate, {:server_error, reason}})
        Pubsub.broadcast(:server, {:stop, reason})
        {:stop, :normal, state}

      reason ->
        Pubsub.broadcast(:manager, {:server_terminate, {:server_error, reason}})
        Pubsub.broadcast(:server, {:stop, Error.exception(:invalid_run)})
        {:stop, :normal, state}
    end
  end

  @impl true
  @spec handle_info(
          {:finished, timer :: integer(), counter :: integer()},
          state :: ServerManagerStruct.t()
        ) :: {:noreply, ServerManagerStruct.t()}
  def handle_info({:finished, timer, counter}, state) do
    write_data(:os.system_time(:millisecond) - timer, counter, state.filename)

    client_number = Map.get(state, :clients_number)

    if(client_number == 1) do
      Pubsub.broadcast(:manager, {:server_terminate, :completed})
    end

    {:noreply, Map.put(state, :clients_number, client_number - 1)}
  end

  @impl true
  @spec handle_info(:stop, state :: ServerManagerStruct.t()) ::
          {:stop, :normal, ServerManagerStruct.t()}
  def handle_info({:stop, reason}, state) do
    Pubsub.broadcast(:server, {:stop, reason})
    {:stop, :normal, state}
  end

  @spec write_data(timer :: integer(), counter :: integer(), filename :: String.t()) :: :ok
  defp write_data(timer, counter, filename) do
    dir = :code.priv_dir(:server)
    file_path = Path.join([dir, filename])
    {:ok, file} = File.open(file_path <> ".txt", [:append, :write, :utf8])

    case IO.puts(file, to_string(counter) <> ";" <> to_string(timer)) do
      :ok ->
        File.close(file)
        Logger.debug("Data saved")
    end
  end
end
