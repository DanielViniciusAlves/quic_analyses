defmodule Client.Connection.SslHandler do
  alias Client.Error.ErrorHandler, as: Error
  alias Client.Struct.ClientStruct
  alias :ssl, as: Ssl
  require Logger

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

  @spec handle_connection(message :: any(), state :: ClientStruct.t()) ::
          {:ok, state :: ClientStruct.t()} | {:error, Error.t()}
  def handle_connection(_message, state) do
    # IO.inspect(message)
    {:ok, state}
  end
end
