defmodule Client.Struct.ClientStruct do
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
