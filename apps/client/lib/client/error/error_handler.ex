defmodule Client.Error.ErrorHandler do
  alias Client.Error.ErrorStruct, as: Error

  @spec create(atom(), String.t()) :: Error.t()
  def create(type, reason) when is_atom(type), do: %Error{type: type, reason: reason}
end
