defmodule Manager.ConfigStruct do
  @moduledoc """
  Module defining a configuration struct for network emulation parameters.
  """

  @doc """
  Defines a struct for network emulation configuration.

  The struct contains parameters for configuring network emulation settings.

  ## Fields

  - `delay`: The delay to introduce in the network, in milliseconds.
  - `loss`: The percentage of packet loss to simulate.
  - `corruption`: The percentage of packet corruption to simulate.
  - `bandwidth_limit`: The bandwidth limit to enforce, in megabits per second. 
    Set to `nil` to disable bandwidth limiting.
  - `clients_number`: The number of clients to simulate.
  - `connection_duration`: The duration of each simulated connection, in seconds.
  - `connection_type`: The type of connection to simulate, can be `:tcp`, `:udp`, or `:quic`.
  - `status`: The status of the network emulation, can be `:on` or `:off`.
  - `delay_netem_config`: A boolean indicating whether to configure delay using netem.
  """
  defstruct delay: 0,
            loss: 0,
            corruption: 0,
            bandwidth_limit: 0,
            clients_number: 100,
            connection_duration: 10,
            connection_type: :quic,
            status: :off,
            delay_netem_config: true

  @type t() ::
          %__MODULE__{
            delay: non_neg_integer(),
            loss: non_neg_integer(),
            corruption: non_neg_integer(),
            bandwidth_limit: integer() | nil,
            clients_number: non_neg_integer(),
            connection_duration: non_neg_integer(),
            connection_type: :tcp | :udp | :quic,
            status: :off | :on,
            delay_netem_config: boolean()
          }
end
