defmodule Client.Connection.SslHandler do
  @moduledoc """
  This module handles SSL connections for the client.

  ## Functions

  - `connect/1`: Establishes an SSL connection with the server.
  - `send/2`: Sends data over the established SSL connection.
  - `handle_connection/2`: Handles incoming messages from the server.

  ## Aliases

  - `ErrorHandler`: Alias for the error handler module.
  - `ClientStruct`: Alias for the client struct module.
  - `:ssl`: Alias for the SSL library.
  """

  alias Client.Error.ErrorHandler, as: Error
  alias Client.Struct.ClientStruct
  alias :ssl, as: Ssl
  require Logger

  @doc """
  Establishes an SSL connection with the server.

  ## Parameters
    - `state`: The client state struct.

  ## Returns
    - `{:ok, state}`: If the connection is successfully established.
    - `{:error, error}`: If an error occurs during connection.

  """
  @spec connect(state :: ClientStruct.t()) ::
          {:ok, state :: ClientStruct.t()} | {:stop, Error.t()}
  def connect(state) do
    host = Application.get_env(:server, :host)
    port = Application.get_env(:server, :port)
    dir = :code.priv_dir(:server)

    with {:ok, socket} <-
           :ssl.connect(
             host,
             port,
             [
               :binary,
               active: true,
               verify: :verify_none,
               cacertfile: Path.join([dir, "cert.pem"])
             ],
             5000
           ) do
      {:ok, %{state | connection_handler: Client.Connection.SslHandler, socket: socket}}
    else
      response ->
        {:error, Error.exception(:connection, response)}
    end
  end

  @doc """
  Sends data over the established SSL connection.

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
    case(Ssl.send(state.socket, payload)) do
      :ok ->
        {:ok, state}

      {:error, _reason} ->
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
    # IO.inspect(message)
    {:ok, state}
  end
end
