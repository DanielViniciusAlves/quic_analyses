defmodule Client.Struct.ClientManagerStruct do
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
