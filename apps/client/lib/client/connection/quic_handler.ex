defmodule Client.Connection.QuicHandler do
  alias Client.Error.ErrorHandler, as: Error
  alias :quicer, as: Quic
  require Logger

  @spec connect(state :: map()) :: {:ok, state :: map()} | {:stop, Error.t()}
  def connect(state) do
    host = Application.get_env(:server, :host)
    port = Application.get_env(:server, :port)

    with {:ok, conn} <-
           Quic.connect(host, port, [{:alpn, [~c"sample"]}, {:verify, :none}], :infinity),
         {:ok, stm} <- Quic.start_stream(conn, []) do
      # :ok <- Quic.handoff_stream(stm, Kernel.self()) do
      {:ok, %{state | connection_handler: Client.Connection.QuicHandler, socket: stm}}
    else
      response ->
        IO.puts("Error")
        IO.inspect(response)
        {:stop, Error.exception(:connection)}
    end
  end

  @spec send(state :: map(), payload :: binary()) :: {:ok, state :: map()} | {:error, Error.t()}
  def send(state, payload) do
    case Quic.send(state.socket, payload) do
      {:ok, res} ->
        {:ok, state}

      {:error, reason} ->
        Logger.error(reason)
        {:error, Error.exception(:send)}
    end
  end

  @spec handle_connection(message :: any(), state :: map()) ::
          {:ok, state :: map()} | {:error, Error.t()}
  def handle_connection(message, state) do
    # IO.inspect(:client_message)
    # IO.inspect(message)
    {:ok, state}
  end
end
