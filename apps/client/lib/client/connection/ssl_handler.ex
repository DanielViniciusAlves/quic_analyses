defmodule Client.Connection.SslHandler do
  alias Client.Error.ErrorHandler, as: Error
  alias :ssl, as: Ssl
  require Logger

  @spec connect(state :: map()) :: {:ok, state :: map()} | {:stop, Error.t()}
  def connect(state) do
    host = Application.get_env(:server, :host)
    port = Application.get_env(:server, :port)
    dir = :code.priv_dir(:server)

    with {:ok, socket} <-
           Ssl.connect(
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
        Logger.info("Error in one of the Clients connections")
        IO.inspect(response)
        {:stop, Error.exception(:connection)}
    end
  end

  @spec send(state :: map(), payload :: binary()) :: {:ok, state :: map()} | {:error, Error.t()}
  def send(state, payload) do
    case(Ssl.send(state.socket, payload)) do
      :ok ->
        {:ok, state}

      {:error, reason} ->
        Logger.error(reason)
        {:error, Error.exception(:send)}
    end
  end

  @spec handle_connection(message :: any(), state :: map()) ::
          {:ok, state :: map()} | {:error, Error.t()}
  def handle_connection(message, state) do
    IO.inspect(message)
    {:ok, state}
  end
end
