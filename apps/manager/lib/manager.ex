defmodule Manager do
  @moduledoc """
    This module manages the configuration and lifecycle of the Manager system.

    ## Usage

    - To start the Manager system, use `Manager.start/0`.
    - To stop the Manager system, use `Manager.stop/0`.

    ## Configuration

    The configuration is stored in an Agent, allowing dynamic updates during runtime.

    ## Callbacks

    - `get_config/0`: Retrieve the current configuration.
    - `set_delay/1`: Set the delay in the configuration.
    - `set_loss/1`: Set the loss in the configuration.
    - `set_corruption/1`: Set the corruption in the configuration.
    - `set_bandwidth_limit/1`: Set the bandwidth limit in the configuration.
    - `set_clients_number/1`: Set the number of clients in the configuration.
    - `set_connection_duration/1`: Set the connection duration in the configuration.

    ## Starting the System

    To start the system, use Manager.start/0. It retrieves the configuration, starts the HandlerSupervisor, and sets the status to :on.
    Stopping the System

    To stop the system, use Manager.stop/0. It performs the necessary actions to stop the system.

  """

  alias Manager.ConfigStruct
  alias Manager.Config
  alias Manager.Genserver.HandlerSupervisor

  require Logger

  def start() do
    config = get_config()

    with :off <- config.status,
         :ok <- HandlerSupervisor.start_handler(config) do
      set_status(:on)
      Logger.info("Test Started !")
    else
      {:error, reason} ->
        Logger.critical("Error: starting handler.")
        {:error, reason}

      :on ->
        Logger.error("Error: Handler already running.")
        {:error, "Already running"}
    end
  end

  def stop() do
    :call_module_to_stop_docker
  end

  ## Callbacks

  @spec get_config() :: ConfigStruct.t()
  def get_config() do
    Agent.get(Config, fn state ->
      state
    end)
  end

  @spec delay_netem_config(boolean) :: ConfigStruct.t()
  def delay_netem_config(type) when is_boolean(type) do
    update_config(:delay_netem_config, type)
  end

  @spec set_connection_type(integer) :: ConfigStruct.t()
  def set_connection_type(type) when is_integer(type) do
    update_config(:connection_type, type)
  end

  @spec set_status(status :: :on | :off) :: ConfigStruct.t()
  def set_status(status) do
    update_config(:status, status)
  end

  @spec set_delay(integer) :: ConfigStruct.t()
  def set_delay(delay) when is_integer(delay) do
    update_config(:delay, delay)
  end

  @spec set_loss(integer) :: ConfigStruct.t()
  def set_loss(loss) when is_integer(loss) do
    update_config(:loss, loss)
  end

  @spec set_corruption(integer) :: ConfigStruct.t()
  def set_corruption(corruption) when is_integer(corruption) do
    update_config(:corruption, corruption)
  end

  @spec set_bandwidth_limit(integer) :: ConfigStruct.t()
  def set_bandwidth_limit(bandwidth_limit) when is_integer(bandwidth_limit) do
    update_config(:bandwidth_limit, bandwidth_limit)
  end

  @spec set_clients_number(integer) :: ConfigStruct.t()
  def set_clients_number(clients_number) when is_integer(clients_number) do
    update_config(:clients_number, clients_number)
  end

  @spec set_connection_duration(integer) :: ConfigStruct.t()
  def set_connection_duration(connection_duration) when is_integer(connection_duration) do
    update_config(:connection_duration, connection_duration)
  end

  @spec update_config(atom, integer | :on | :off | boolean()) :: ConfigStruct.t()
  defp update_config(key, value) when is_integer(value) or is_atom(value) or is_boolean(value) do
    Agent.update(Config, fn state ->
      Map.put(state, key, value)
    end)

    get_config()
  end

  defp update_config(_key, _value), do: {:error, "Invalid type"}
end
