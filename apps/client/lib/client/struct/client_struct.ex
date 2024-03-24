defmodule Client.Struct.ClientStruct do
  @moduledoc """
  This struct represents the state of a client.

  ## Fields

  - `connection_duration`: The duration of the client's connection.
  - `connection_type`: The type of connection for the client.
  - `connection_handler`: The handler module for the client's connection.
  - `socket`: The socket associated with the client.
  - `id`: The unique identifier of the client.
  """
  defstruct [
    :connection_duration,
    :connection_type,
    {:connection_handler, nil},
    {:socket, nil},
    :id
  ]

  @type t() ::
          %__MODULE__{
            connection_duration: non_neg_integer(),
            connection_type: atom(),
            connection_handler: module(),
            socket: any(),
            id: non_neg_integer()
          }
end
