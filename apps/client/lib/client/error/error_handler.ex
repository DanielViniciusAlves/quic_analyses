defmodule Client.Error.ErrorHandler do
  @moduledoc """
  This module defines custom error handling for the client system.

  ## Types

  - `t()`: Represents an error with a message, type, and reason.

  ## Functions

  - `exception/2`: Constructs an exception with the given value and reason.

  ## Exceptions

  This module defines the following exceptions:

  - `:client_init`: Error encountered while starting the client.
  - `:invalid_run`: Invalid test, stopping all clients.
  - `:connection`: Error encountered while starting connection with the server.
  - `:unknown`: Unknown error.
  """
  defexception [:message, :type, :reason]

  @type t() :: %__MODULE__{
          message: String.t(),
          type: atom(),
          reason: String.t()
        }

  @impl true
  def exception(value, reason \\ "Unknown Error") do
    case value do
      :client_init ->
        %__MODULE__{message: "Error starting Client.", type: value}

      :invalid_run ->
        %__MODULE__{message: "Invalid Test, stopping all clients.", type: value, reason: reason}

      :connection ->
        %__MODULE__{
          message: "Error starting connection with server.",
          type: value,
          reason: reason
        }

      _ ->
        %__MODULE__{message: "Unknown Error", type: :unknown, reason: reason}
    end
  end
end
