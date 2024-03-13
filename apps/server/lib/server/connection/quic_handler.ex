defmodule Server.Connection.QuicHandler do
  alias Server.Genserver.Supervisor, as: Acceptor
  alias Client.Error.ErrorHandler, as: Error
  alias :quicer, as: Quic
  alias Manager.Pubsub
  require Logger

  # @spec connect(state :: map()) :: {:ok, state :: map()} | {:stop, Error.t()}
  def start(init_config) do
    port = Application.get_env(:server, :port)
    dir = :code.priv_dir(:server)

    options = [
      {:certfile, Path.join([dir, "server-cert.pem"]) |> String.to_charlist()},
      {:keyfile, Path.join([dir, "server-key.pem"]) |> String.to_charlist()},
      {:alpn, [~c"sample"]},
      {:peer_bidi_stream_count, 1}
    ]

    with {:ok, socket} <-
           Quic.listen(port, options) do
      accept_loop(init_config.clients_number, socket, 0)
    else
      _response ->
        {:stop, :connection}
    end
  end

  defp accept_loop(clients_number, socket, counter) when counter < clients_number do
    Acceptor.start_acceptor(%{
      connection_handler: Server.Connection.QuicHandler,
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
    Quic.setopt(state.socket, :active, true)

    case Quic.accept(state.socket, []) do
      {:ok, accept_socket} ->
        {:ok, socket} = Quic.handshake(accept_socket, :infinity)
        {:ok, socket} = Quic.accept_stream(socket, [])

        {:noreply, %{state | socket: socket}}

      response ->
        IO.inspect(response)

        {:error, response}
    end
  end

  def handle_message({:quic, message, stm, _props}, state) do
    cond do
      message |> is_atom ->
        Pubsub.broadcast(:server, {:finished, state.timer, state.counter})
        Logger.info("Audio end")
        {:stop, :normal, :test}

      true ->
        IO.inspect(message)
        {:noreply, Map.put(state, :counter, Map.get(state, :counter, 0) + 1)}
    end
  end

  def handle_message(message, state) do
    IO.inspect(:message)
    # IO.inspect(message)

    {:noreply, state}
  end

  def verify(a, b, c) do
    IO.inspect(a)
    IO.inspect(b)
    IO.inspect(c)
  end
end
