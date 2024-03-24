defmodule Server.Connection.QuicHandler do
  @moduledoc """
  Module responsible for handling QUIC connections.

  This module implements functions to start a QUIC server, handle incoming connections,
  and process messages from those connections.
  """
  alias Server.Genserver.Supervisor, as: Acceptor
  alias Server.Error.ErrorHandler, as: Error
  alias Server.Struct.ServerManagerStruct
  alias :quicer, as: Quic
  alias Manager.Pubsub
  require Logger

  @spec start(state :: ServerManagerStruct.t()) :: :ok | {:stop, Error.t()}
  @doc """
  Starts the QUIC server.

  It listens on the specified port and accepts incoming connections.

  ## Parameters
    - `state`: The initial server manager state.

  ## Returns
    - `:ok` if the server started successfully, or `{:stop, reason}` if an error occurred.
  """
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
      {:error, reason} ->
        {:error, Error.exception(:connection, reason)}
    end
  end

  @spec accept_loop(clients_number :: integer(), socket :: any(), counter :: integer()) :: :ok
  defp accept_loop(clients_number, socket, counter) when counter < clients_number do
    case Acceptor.start_acceptor(%{
           connection_handler: Server.Connection.QuicHandler,
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
  @doc """
  Handles an incoming QUIC connection.

  ## Parameters
    - `state`: The current state of the connection.

  ## Returns
    - `{:noreply, state}` if the connection is handled successfully, or `{:stop, :normal, {:error, reason}}` if an error occurs.
  """
  def handle_connection(state) do
    Quic.setopt(state.socket, :active, true)

    with {:ok, socket} <- Quic.accept(state.socket, []),
         {:ok, socket} <- Quic.handshake(socket, :infinity),
         {:ok, socket} <- Quic.accept_stream(socket, []) do
      {:noreply, %{state | socket: socket}}
    else
      {:error, reason} ->
        {:stop, :normal, {:error, reason}}
    end
  end

  @spec handle_message({:quic, message :: any(), stm :: any(), props :: any()}, state :: map()) ::
          {:noreply, state :: map()} | {:stop, :normal, {:error, any()}}
  @doc """
  Handles messages received from QUIC connections.

  ## Parameters
    - `{:quic, message, stm, props}`: A tuple containing the message, stream, and properties.
    - `state`: The current state of the connection.

  ## Returns
    - `{:noreply, state}` if the message is handled successfully.
  """
  def handle_message({:quic, message, _stm, _props}, state) do
    cond do
      message |> is_atom && message == :closed ->
        Pubsub.broadcast(:server, {:finished, state.timer, state.counter})
        {:stop, :normal, :finished}

      true ->
        {:noreply, Map.put(state, :counter, Map.get(state, :counter, 0) + 1)}
    end
  end

  @spec handle_message(message :: any(), state :: map()) :: {:noreply, state :: map()}
  def handle_message(_message, state) do
    IO.inspect(:message)
    # IO.inspect(message)

    {:noreply, state}
  end
end
