defmodule Client.Manager do
  use GenServer

  alias Client.Struct.ClientManagerStruct
  alias Client.Genserver.Supervisor, as: ClientSupervisor
  alias Client.Error.ErrorHandler, as: Error
  alias Manager.ConfigStruct
  alias Manager.Pubsub

  require Logger

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [])
  end

  @impl true
  def init(_args) do
    Pubsub.subscribe(:client_api)
    Pubsub.subscribe(:client)
    {:ok, %ClientManagerStruct{}}
  end

  @impl true
  @spec handle_info({:init, config :: ConfigStruct.t()}, state :: ClientManagerStruct.t()) ::
          {:noreply, ClientManagerStruct.t()}
  def handle_info({:init, config}, state) do
    with info <- Map.merge(state, config) do
      case info.delay_netem_config do
        true ->
          IO.inspect(:test)
          ClientSupervisor.start_clients(info)
          Logger.info("Client is starting.")
          Pubsub.broadcast(:client, :start)
          config_enviroment(info)

        false ->
          config_enviroment(info)
          ClientSupervisor.start_clients(info)
          Logger.info("Client is starting.")
          Pubsub.broadcast(:client, :start)
      end

      {:noreply, info}
    else
      {:error, reason} ->
        Pubsub.broadcast(:manager, {:client_terminate, {:client_error, reason}})
        {:noreply, state}

      _reason ->
        Pubsub.broadcast(
          :manager,
          {:client_terminate, {:client_error, Error.exception(:client_init)}}
        )

        {:noreply, state}
    end
  end

  @impl true
  @spec handle_info(
          {:client_stop, reason :: Error.t() | :completed},
          state :: ClientManagerStruct.t()
        ) ::
          {:noreply, ClientManagerStruct.t()}
  def handle_info({:client_stop, reason}, state) do
    case reason do
      :completed ->
        case Map.get(state, :clients_number) do
          0 ->
            Pubsub.broadcast(:manager, {:client_terminate, :completed})
            {:noreply, %ConfigStruct{}}

          client_number ->
            if(client_number == 1) do
              Pubsub.broadcast(:manager, {:client_terminate, :completed})
            end

            {:noreply, Map.put(state, :clients_number, client_number - 1)}
        end

      reason ->
        Logger.error(Error.exception(:invalid_run))
        # Logger.error(reason)

        Pubsub.broadcast(:manager, {:client_terminate, {:client_error, reason}})
        Pubsub.broadcast(:client, {:stop, Error.exception(:invalid_run)})

        {:noreply, state}
    end
  end

  def handle_info(:stop, state) do
    Pubsub.broadcast(:client, :stop)
    {:stop, :normal, state}
  end

  defp config_enviroment(config) do
    IO.inspect(:testing)
    cleanup_ambient()

    cmd = "tc"
    base_args = ["qdisc", "add", "dev", "lo", "root", "netem"]
    network_delay = ["delay", (Map.get(config, :delay) |> Integer.to_string()) <> "ms"]
    packet_loss = ["loss", (Map.get(config, :loss) |> Integer.to_string()) <> "%"]
    packet_corruption = ["corrupt", (Map.get(config, :corruption) |> Integer.to_string()) <> "%"]

    bandwidth_limit = [
      "rate",
      (Map.get(config, :bandwidth_limit) |> Integer.to_string()) <> "mbit"
    ]

    args = base_args ++ network_delay ++ packet_loss ++ packet_corruption ++ bandwidth_limit

    System.cmd(cmd, args)
  end

  defp cleanup_ambient() do
    cmd = "tc"
    args = ["qdisc", "del", "dev", "lo", "root"]

    System.cmd(cmd, args)
  end
end
