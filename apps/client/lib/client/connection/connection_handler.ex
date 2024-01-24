defmodule Client.Connection.ConnectionHandler do
  def start(connection_type) do
    case connection_type do
      :quic ->
        Quic.start()
        # :tcp -> 
        # :udp -> 
    end
  end
end
