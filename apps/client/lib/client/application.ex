defmodule Client.Application do
  use Application

  alias Client.Manager.Supervisor, as: ClientManagerSupervisor
  alias Client.Genserver.Supervisor, as: ClientSupervisor

  @impl true
  def start(_type, _args) do
    children = [
      ClientManagerSupervisor,
      ClientSupervisor
    ]

    opts = [strategy: :one_for_one, name: Client.Supervisor.Tree]
    Supervisor.start_link(children, opts)
  end
end
