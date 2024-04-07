defmodule Manager do
  @moduledoc """
  ## Manager Module

  This module provides functionality for managing configurations and controlling a handler for a testing environment. It allows for starting and stopping the handler, as well as updating various configuration parameters.

  ## Functions

  ### `start/0`

  Starts the handler and sets the status to `:on` if it's currently `:off`. Logs informational messages for successful start and error messages if there are issues starting the handler or if it's already running.

  ### `stop/0`

  Placeholder function to stop the handler. The actual implementation details for stopping the handler are not provided in the module and are expected to be handled elsewhere.

  ## Callbacks

  ### `get_config/0`

  Retrieves the current configuration stored in the `Config` agent.

  ### `delay_netem_config/1`

  Updates the `delay_netem_config` value in the configuration.

  ### `set_connection_type/1`

  Updates the `connection_type` value in the configuration.

  ### `set_status/1`

  Updates the `status` value in the configuration.

  ### `set_delay/1`

  Updates the `delay` value in the configuration.

  ### `set_loss/1`

  Updates the `loss` value in the configuration.

  ### `set_corruption/1`

  Updates the `corruption` value in the configuration.

  ### `set_bandwidth_limit/1`

  Updates the `bandwidth_limit` value in the configuration.

  ### `set_clients_number/1`

  Updates the `clients_number` value in the configuration.

  ### `set_connection_duration/1`

  Updates the `connection_duration` value in the configuration.

  ### `update_config/2`

  Updates a specific configuration parameter with the given key-value pair.

  ## Types

  - `ConfigStruct.t()`: Represents the structure of the configuration data.
  - `status :: :on | :off`: Represents the status of the handler, either `:on` or `:off`.
  - `atom`: Represents a configuration parameter key.
  - `integer`: Represents an integer value for configuration parameters.
  - `boolean()`: Represents a boolean value for configuration parameters.

  ## Usage

  # Start the handler
  Manager.start()

  # Stop the handler
  Manager.stop()

  # Update configuration parameters
  Manager.set_delay(100)
  Manager.set_status(:on)
  # etc.
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

  @spec set_connection_type(atom) :: ConfigStruct.t()
  def set_connection_type(type) when is_atom(type) do
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
