defmodule Manager.Genserver.HandlerSupervisor do
  @moduledoc """
  Supervisor for managing the Handler GenServer.
  """
  use DynamicSupervisor

  require Logger
  alias Manager.Handler, as: Handler
  alias Manager.ConfigStruct

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    DynamicSupervisor.init(max_restarts: 0, strategy: :one_for_one)
  end

  @spec start_handler(config :: ConfigStruct.t()) :: :ok | {:error, String.t()}
  def start_handler(config) do
    with {:ok, _pid} <- DynamicSupervisor.start_child(__MODULE__, {Handler, config}) do
      :ok
    else
      {:error, reason} -> {:error, reason}
      _other -> {:error, "Error in the TC Netem configuration"}
    end
  end
end
