defmodule Client.Application do
  use Application

  alias Client.Supervisor, as: Client

  @impl true
  def start(_type, _args) do
    children = [
      Client
    ]

    opts = [strategy: :one_for_one, name: Client.Supervisor.Tree]
    Supervisor.start_link(children, opts)
  end
end
