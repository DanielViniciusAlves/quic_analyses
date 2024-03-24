defmodule Client.Connection.QuicHandler do
  alias Client.Error.ErrorHandler, as: Error
  alias Client.Struct.ClientStruct
  alias :quicer, as: Quic
  require Logger

  @spec connect(state :: ClientStruct.t()) ::
          {:ok, state :: ClientStruct.t()} | {:error, Error.t()}
  def connect(state) do
    host = Application.get_env(:server, :host)
    port = Application.get_env(:server, :port)

    with {:ok, conn} <-
           Quic.connect(host, port, [{:alpn, [~c"sample"]}, {:verify, :none}], :infinity),
         {:ok, stm} <- Quic.start_stream(conn, []) do
      {:ok, %{state | connection_handler: Client.Connection.QuicHandler, socket: stm}}
    else
      response ->
        {:error, Error.exception(:connection, response)}
    end
  end

  @spec send(state :: ClientStruct.t(), payload :: binary()) ::
          {:ok, state :: ClientStruct.t()} | {:error, Error.t()}
  def send(state, payload) do
    case Quic.send(state.socket, payload) do
      {:ok, _other} ->
        {:ok, state}

      _error ->
        {:error, Error.exception(:send)}
    end
  end

  @spec handle_connection(message :: any(), state :: ClientStruct.t()) ::
          {:ok, state :: ClientStruct.t()} | {:error, Error.t()}
  def handle_connection(_message, state) do
    # IO.inspect(:client_message)
    # IO.inspect(message)
    {:ok, state}
  end
end
