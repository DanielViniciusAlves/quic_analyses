defmodule Server.Struct.AcceptorStruct do
  @moduledoc """
  This module defines the structure for the acceptor process state.

  ## Structure

  The struct contains the following fields:
  - `connection_duration`: Duration of the connection.
  - `connection_type`: Type of connection.
  - `connection_handler`: Handler module for the connection.
  - `socket`: Socket object.
  - `id`: Unique identifier.

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
