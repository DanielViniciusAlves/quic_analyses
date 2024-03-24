defmodule Client.Struct.ClientManagerStruct do
  @moduledoc """
  This struct represents the state of the client manager.

  ## Fields

  - `clients_number`: The number of clients managed by the manager.
  - `connection_duration`: The duration of the connection.
  - `connection_type`: The type of connection.
  """
  defstruct [
    :clients_number,
    :connection_duration,
    :connection_type
  ]

  @type t() ::
          %__MODULE__{
            clients_number: non_neg_integer(),
            connection_duration: non_neg_integer(),
            connection_type: atom()
          }
end
