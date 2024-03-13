defmodule Server.Manager do
  use GenServer

  alias Server.Struct.ServerManagerStruct
  alias Server.Genserver.Supervisor, as: ServerSupervisor
  alias Server.Connection.Handler, as: Connection
  alias Server.Error.ErrorHandler, as: Error
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
    with info <- Map.merge(state, config) do
      Connection.start(info)
      Logger.info("Server is starting.")
      Pubsub.broadcast(:manager, :server_started)

      {:noreply, info}
    else
      {:error, reason} ->
        Pubsub.broadcast(:manager, {:server_terminate, {:server_error, reason}})
        {:noreply, state}

      _reason ->
        Pubsub.broadcast(
          :manager,
          {:client_terminate, {:client_error, Error.exception(:client_init)}}
        )

        {:noreply, state}
    end
  end

  def handle_info({:finished, timer, counter}, state) do
    state =
      if !Map.get(state, :filename, false) do
        Map.put(state, :filename, :os.system_time())
      else
        state
      end

    write_data(:os.system_time(:millisecond) - timer, counter, state.filename)

    case Map.get(state, :clients_number) do
      0 ->
        Pubsub.broadcast(:manager, {:server_terminate, :completed})
        {:noreply, %ServerManagerStruct{}}

      client_number ->
        if(client_number == 1) do
          Pubsub.broadcast(:manager, {:server_terminate, :completed})
        end

        {:noreply, Map.put(state, :clients_number, client_number - 1)}
    end
  end

  def handle_info(:stop, state) do
    Pubsub.broadcast(:acceptor, {:stop, "Invalid run"})
    {:stop, :normal, state}
  end

  def write_data(timer, counter, filename) do
    dir = :code.priv_dir(:server)
    file_path = Path.join([dir, to_string(filename)])
    {:ok, file} = File.open(file_path <> ".txt", [:append, :write, :utf8])

    case IO.puts(file, to_string(counter) <> ";" <> to_string(timer)) do
      :ok ->
        File.close(file)
        Logger.debug("Data saved")
    end
  end
end
