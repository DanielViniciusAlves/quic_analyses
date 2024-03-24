defmodule Manager.NetemConfig do
  def config_enviroment(config) do
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

    case System.cmd(cmd, args) do
      {"", 2} -> {:error, "Error starting Netem"}
      _ -> :ok
    end
  end

  def cleanup_ambient() do
    cmd = "tc"
    args = ["qdisc", "del", "dev", "lo", "root"]

    case System.cmd(cmd, args) do
      {"", 2} -> {:error, "Error cleaning Netem"}
      _ -> :ok
    end
  end
end
