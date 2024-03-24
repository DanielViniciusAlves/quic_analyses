defmodule Server.Struct.ServerManagerStruct do
  defstruct [
    :clients_number,
    :connection_type,
    {:filename, :os.system_time() |> to_string()}
  ]

  @type t() ::
          %__MODULE__{
            clients_number: non_neg_integer(),
            connection_type: atom(),
            filename: String.t()
          }
end
