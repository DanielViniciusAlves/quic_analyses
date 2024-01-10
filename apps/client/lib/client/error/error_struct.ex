defmodule Client.Error.ErrorStruct do
  defstruct [
    :type,
    :reason
  ]

  @type t() ::
          %__MODULE__{
            type: atom,
            reason: String.t()
          }
end
