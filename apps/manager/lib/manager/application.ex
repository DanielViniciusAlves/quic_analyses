defmodule Manager.Application do
  @moduledoc false

  use Application

  alias Manager.Config, as: Config
  alias Manager.Genserver.HandlerSupervisor

  @impl true
  def start(_type, _args) do
    children = [
      Config,
      HandlerSupervisor,
      {Registry, keys: :duplicate, name: EventBus}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
