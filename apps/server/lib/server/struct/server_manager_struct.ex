defmodule Server.Struct.ServerManagerStruct do
  @moduledoc """
  This module defines the structure for the server manager process state.

  ## Structure

  The struct contains the following fields:
  - `clients_number`: Number of clients connected.
  - `connection_type`: Type of connection.
  - `filename`: Filename based on the current system time.

  """
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
