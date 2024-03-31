defmodule Client.Connection.QuicHandler do
  @moduledoc """
  This module handles QUIC connections for the client.

  ## Functions

  - `connect/1`: Establishes a QUIC connection with the server.
  - `send/2`: Sends data over the established QUIC connection.
  - `handle_connection/2`: Handles incoming messages from the server.

  ## Aliases

  - `ErrorHandler`: Alias for the error handler module.
  - `ClientStruct`: Alias for the client struct module.
  - `Quic`: Alias for the QUIC library.
  """

  alias Client.Error.ErrorHandler, as: Error
  alias Client.Struct.ClientStruct
  alias :quicer, as: Quic
  require Logger

  @doc """
  Establishes a QUIC connection with the server.

  ## Parameters
    - `state`: The client state struct.

  ## Returns
    - `{:ok, state}`: If the connection is successfully established.
    - `{:error, error}`: If an error occurs during connection.

  """
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

  @doc """
  Sends data over the established QUIC connection.

  ## Parameters
    - `state`: The client state struct.
    - `payload`: The data to be sent.

  ## Returns
    - `{:ok, state}`: If the data is successfully sent.
    - `{:error, error}`: If an error occurs during sending.

  """
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

  @doc """
  Handles incoming messages from the server.

  ## Parameters
    - `message`: The incoming message.
    - `state`: The client state struct.

  ## Returns
    - `{:ok, state}`: If the message is successfully handled.
    - `{:error, error}`: If an error occurs during handling.

  """
  @spec handle_connection(message :: any(), state :: ClientStruct.t()) ::
          {:ok, state :: ClientStruct.t()} | {:error, Error.t()}
  def handle_connection(_message, state) do
    # IO.inspect(:client_message)
    # IO.inspect(message)
    {:ok, state}
  end
end
