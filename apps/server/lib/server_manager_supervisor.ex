defmodule Server.Manager.Supervisor do
  use Supervisor

  alias Server.Manager, as: Manager

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      {Manager, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
