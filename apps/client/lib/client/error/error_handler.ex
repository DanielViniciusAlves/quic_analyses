defmodule Client.Error.ErrorHandler do
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
