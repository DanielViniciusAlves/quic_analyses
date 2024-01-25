defmodule Client.Struct.ClientStruct do
  defstruct [
    :connection_duration,
    :connection_type,
    :id
  ]

  @type t() ::
          %__MODULE__{
            connection_duration: non_neg_integer(),
            connection_type: atom(),
            id: non_neg_integer()
          }
end
