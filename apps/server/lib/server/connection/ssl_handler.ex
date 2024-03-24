defmodule Server.Connection.SslHandler do
  alias Server.Genserver.Supervisor, as: Acceptor
  alias Server.Error.ErrorHandler, as: Error
  alias Server.Struct.ServerManagerStruct
  alias Manager.Pubsub
  require Logger

  @spec start(state :: ServerManagerStruct.t()) :: :ok | {:stop, Error.t()}
  def start(init_config) do
    port = Application.get_env(:server, :port)
    dir = :code.priv_dir(:server)

    options = [
      {:certfile, Path.join([dir, "server-cert.pem"]) |> String.to_charlist()},
      {:keyfile, Path.join([dir, "server-key.pem"]) |> String.to_charlist()},
      {:reuseaddr, true},
      :binary
    ]

    with {:ok, socket} <- :ssl.listen(port, options) do
      accept_loop(init_config.clients_number, socket, 0)
    else
      {:error, reason} ->
        {:error, Error.exception(:connection, reason)}
    end
  end

  @spec accept_loop(clients_number :: integer(), socket :: any(), counter :: integer()) :: :ok
  defp accept_loop(clients_number, socket, counter) when counter < clients_number do
    case Acceptor.start_acceptor(%{
           connection_handler: Server.Connection.SslHandler,
           socket: socket
         }) do
      {:error, reason} ->
        {:error, reason}

      :ok ->
        accept_loop(clients_number, socket, counter + 1)
    end
  end

  defp accept_loop(_clients_number, _socket, _counter) do
    :ok
  end

  @spec handle_connection(state :: map()) ::
          {:noreply, state :: map()} | {:stop, :normal, {:error, any()}}
  def handle_connection(state) do
    with :ok <- :ssl.setopts(state.socket, [{:active, true}]),
         {:ok, accept_socket} <- :ssl.transport_accept(state.socket),
         {:ok, _socket} <-
           :ssl.handshake(
             accept_socket,
             [versions: [:"tlsv1.2", :"tlsv1.1", :tlsv1], verify: :verify_none],
             2_000
           ) do
      {:noreply, %{state | socket: accept_socket}}
    else
      {:error, reason} ->
        {:stop, :normal, {:error, reason}}
    end
  end

  @spec handle_message({:quic, from :: any(), message :: any()}, state :: map()) ::
          {:noreply, state :: map()}
  def handle_message({:ssl, _from, message}, state) do
    IO.inspect(message)
    {:noreply, Map.put(state, :counter, Map.get(state, :counter, 0) + 1)}
  end

  @spec handle_message(message :: any(), state :: map()) :: {:noreply, state :: map()}
  def handle_message(message, state) do
    case message do
      {:ssl_closed, _other} ->
        Pubsub.broadcast(:server, {:finished, state.timer, state.counter})
        {:stop, :normal, :finished}

      _message ->
        {:noreply, state}
    end
  end
end
