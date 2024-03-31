defmodule Server.Error.ErrorHandler do
  @moduledoc """
  This module handles errors for the server system.

  ## Types

  - `t()`: Represents an error with a message, type, and reason.

  ## Functions

  - `exception/2`: Constructs an exception with the given value and reason.

  ## Exceptions

  This module defines the following exceptions:

  - `:connection`: Error encountered while trying to start the listener.
  - `:invalid_type`: Invalid type, stopping test.
  - `:invalid_run`: Invalid test, stopping all acceptors.
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
      :connection ->
        %__MODULE__{message: "Error trying to start the listener", type: value, reason: reason}

      :invalid_type ->
        %__MODULE__{message: "Invalid type, stopping test.", type: value, reason: reason}

      :invalid_run ->
        %__MODULE__{message: "Invalid Test, stopping all acceptors.", type: value, reason: reason}

      _ ->
        %__MODULE__{message: "Unknown Error", type: :unknown, reason: reason}
    end
  end
end
