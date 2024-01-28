defmodule Client.Error.ErrorHandler do
  defexception [:message, :type]

  @type t() :: %__MODULE__{
          message: String.t(),
          type: atom()
        }

  @impl true
  def exception(value) do
    case value do
      :client_init -> %__MODULE__{message: "Error starting Client.", type: value}
      :invalid_run -> %__MODULE__{message: "Invalid Test, stopping all clients.", type: value}
      :connection -> %__MODULE__{message: "Error starting connection with server.", type: value}
      _ -> %__MODULE__{message: "Unknown Error", type: :unknown}
    end
  end
end
