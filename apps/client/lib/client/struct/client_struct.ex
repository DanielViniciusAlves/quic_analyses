defmodule Client.ClientStruct do
  defstruct [
    :clients_number,
    :connection_duration,
    {:status, :off}
  ]

  @type t() ::
          %__MODULE__{
            clients_number: non_neg_integer(),
            connection_duration: non_neg_integer(),
            status: :off | :on
          }
end
