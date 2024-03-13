defmodule Server.Connection.Handler do
  # alias Client.Error.ErrorHandler, as: Error
  alias Server.Connection.QuicHandler
  alias Server.Connection.SslHandler
  alias Server.Connection.UdpHandler

  @spec start(init_config :: map()) :: {:ok, state :: map()} | {:error, Error.t()}
  def start(init_config) do
    case init_config.connection_type do
      :quic ->
        QuicHandler.start(init_config)

      :tcp ->
        SslHandler.start(init_config)

      :udp ->
        UdpHandler.connect(init_config)
    end
  end
end
