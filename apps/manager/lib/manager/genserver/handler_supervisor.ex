defmodule Manager.Genserver.HandlerSupervisor do
  use DynamicSupervisor

  alias Manager.Handler, as: Handler
  alias Manager.ConfigStruct

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @spec start_handler(config :: ConfigStruct.t()) :: :ok | {:error, String.t()}
  def start_handler(config) do
    case DynamicSupervisor.start_child(__MODULE__, {Handler, config}) do
      {:ok, _pid} ->
        :ok

      _error ->
        {:error, "Error starting Handler"}
    end
  end
end
