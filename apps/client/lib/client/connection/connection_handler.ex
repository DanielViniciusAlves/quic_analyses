defmodule Client.Connection.ConnectionHandler do
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
