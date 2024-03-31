defmodule Client.Connection.ConnectionHandler do
  @moduledoc """
  This module handles different types of connections for the client.

  ## Functions

  - `start/1`: Starts the specified type of connection.

  ## Aliases

  - `ErrorHandler`: Alias for the error handler module.
  - `QuicHandler`: Alias for the QUIC connection handler module.
  - `SslHandler`: Alias for the SSL connection handler module.
  """
  alias Client.Error.ErrorHandler, as: Error
  alias Client.Connection.QuicHandler
  alias Client.Connection.SslHandler
  # alias Client.Connection.UdpHandler

  @spec start(init_config :: map()) :: {:ok, state :: map()} | {:error, Error.t()}
  def start(init_config) do
    case init_config.connection_type do
      :quic ->
        QuicHandler.connect(init_config)

      :tcp ->
        SslHandler.connect(init_config)

      _other ->
        {:error, Error.exception(:invalid_type, "Invalid connection type")}

        # :udp -> UdpHandler.connect(init_config)
    end
  end
end
