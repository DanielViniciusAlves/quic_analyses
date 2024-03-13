defmodule Server.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias Server.Manager.Supervisor, as: Manager
  alias Server.Genserver.Supervisor, as: Acceptor

  @impl true
  def start(_type, _args) do
    children = [
      Manager,
      Acceptor
    ]

    opts = [strategy: :one_for_one, name: Server.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
