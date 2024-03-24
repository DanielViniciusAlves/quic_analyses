defmodule Server.Error.ErrorHandler do
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
