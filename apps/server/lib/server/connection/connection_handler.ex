defmodule Server.Connection.Handler do
  alias Server.Error.ErrorHandler, as: Error
  alias Server.Struct.ServerManagerStruct
  alias Server.Connection.QuicHandler
  alias Server.Connection.SslHandler
  # alias Server.Connection.UdpHandler

  @spec start(init_config :: ServerManagerStruct.t()) :: :ok | {:error, Error.t()}
  def start(init_config) do
    case init_config.connection_type do
      :quic ->
        QuicHandler.start(init_config)

      :tcp ->
        SslHandler.start(init_config)

      _other ->
        {:error, Error.exception(:invalid_type, "Invalid connection type")}

        # :udp ->
        #   UdpHandler.connect(init_config)
    end
  end
end
