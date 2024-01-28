defmodule Client.Connection.UdpHandler do
  alias Client.Error.ErrorHandler, as: Error
  alias :gen_udp, as: Udp
  require Logger

  @spec connect(state :: map()) :: {:ok, state :: map()} | {:stop, Error.t()}
  def connect(state) do
    with {:ok, socket} <- Udp.open(0) do
      {:ok, %{state | connection_handler: Client.Connection.UdpHandler, socket: socket}}
    else
      response ->
        IO.inspect(response)
        {:stop, Error.exception(:connection)}
    end
  end

  @spec send(state :: map(), payload :: binary()) :: {:ok, state :: map()} | {:error, Error.t()}
  def send(state, payload) do
    host = Application.get_env(:server, :host)
    port = Application.get_env(:server, :port)

    case Udp.send(state.socket, host, port, payload) do
      :ok ->
        {:ok, state}

      error ->
        Logger.error(error)
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
