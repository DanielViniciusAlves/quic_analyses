defmodule Manager.ConfigStruct do
  defstruct delay: 0,
            loss: 0,
            corruption: 0,
            bandwidth_limit: nil,
            clients_number: 100,
            connection_duration: 10,
            connection_type: :quic,
            status: :off

  @type t() ::
          %__MODULE__{
            delay: non_neg_integer(),
            loss: non_neg_integer(),
            corruption: non_neg_integer(),
            bandwidth_limit: integer() | nil,
            clients_number: non_neg_integer(),
            connection_duration: non_neg_integer(),
            connection_type: :tcp | :udp | :quic,
            status: :off | :on
          }
end
