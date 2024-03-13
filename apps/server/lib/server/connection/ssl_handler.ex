defmodule Server.Connection.SslHandler do
  alias Server.Genserver.Supervisor, as: Acceptor
  alias Client.Error.ErrorHandler, as: Error
  alias :ssl, as: Ssl
  require Logger
  alias Manager.Pubsub

  # @spec connect(state :: map()) :: {:ok, state :: map()} | {:stop, Error.t()}
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
      _response ->
        {:stop, :connection}
    end
  end

  defp accept_loop(clients_number, socket, counter) when counter < clients_number do
    Acceptor.start_acceptor(%{
      connection_handler: Server.Connection.SslHandler,
      socket: socket
    })

    accept_loop(clients_number, socket, counter + 1)
  end

  defp accept_loop(_clients_number, _socket, _counter) do
    :ok
  end

  # @spec handle_connection(message :: any(), state :: map()) ::
  #         {:ok, state :: map()} | {:error, Error.t()}
  def handle_connection(state) do
    :ssl.setopts(state.socket, [{:active, true}])

    case :ssl.transport_accept(state.socket) do
      {:ok, accept_socket} ->
        :ssl.handshake(
          accept_socket,
          [versions: [:"tlsv1.2", :"tlsv1.1", :tlsv1], verify: :verify_none],
          2_000
        )

        {:noreply, %{state | socket: accept_socket}}

      response ->
        IO.inspect(response)

        {:error, response}
    end
  end

  def handle_message({:ssl, _from, _message}, state) do
    # IO.inspect(Map.get(state, :counter))
    {:noreply, Map.put(state, :counter, Map.get(state, :counter, 0) + 1)}
  end

  def handle_message(message, state) do
    case message do
      {:ssl_closed, _other} ->
        Pubsub.broadcast(:server, {:finished, state.timer, state.counter})
        Logger.info("Audio end")
        {:stop, :normal, :test}

      message ->
        IO.inspect(message)
        {:noreply, state}
    end
  end

  def verify(a, b, c) do
    IO.inspect(a)
    IO.inspect(b)
    IO.inspect(c)
  end
end
