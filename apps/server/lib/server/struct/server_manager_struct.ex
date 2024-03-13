defmodule Server.Struct.ServerManagerStruct do
  defstruct [
    :clients_number,
    :connection_type
  ]

  @type t() ::
          %__MODULE__{
            clients_number: non_neg_integer(),
            connection_type: atom()
          }
end
