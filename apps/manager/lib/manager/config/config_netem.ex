defmodule Manager.NetemConfig do
  @moduledoc """
  Module for configuring network emulation parameters using `tc` command.
  """

  @doc """
  Configures the network environment with specified parameters.

  ## Parameters

  - `config`: A map containing the configuration parameters for network emulation.
    - `:delay`: The delay to introduce in the network, in milliseconds.
    - `:loss`: The percentage of packet loss to simulate.
    - `:corruption`: The percentage of packet corruption to simulate.
    - `:bandwidth_limit`: The bandwidth limit to enforce, in megabits per second.

  ## Returns

  - `:ok`: If the network environment is configured successfully.
  - `{:error, reason}`: If an error occurs during configuration.

  ## Example

      iex> Manager.NetemConfig.config_enviroment(%{delay: 100, loss: 5, corruption: 1, bandwidth_limit: 10})
      :ok
  """
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

  @doc """
  Cleans up the network environment by removing any previously configured netem settings.

  ## Returns

  - `:ok`: If the network environment is cleaned up successfully.
  - `{:error, reason}`: If an error occurs during cleanup.

  ## Example

      iex> Manager.NetemConfig.cleanup_ambient()
      :ok
  """
  def cleanup_ambient() do
    cmd = "tc"
    args = ["qdisc", "del", "dev", "lo", "root"]

    case System.cmd(cmd, args) do
      {"", 2} -> {:error, "Error cleaning Netem"}
      _ -> :ok
    end
  end
end

