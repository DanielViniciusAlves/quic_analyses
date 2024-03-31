defmodule Manager.Config do
  @moduledoc """
  This module provides functionality for managing configuration using an Agent.

  The configuration is stored as a struct defined in Manager.ConfigStruct module.
  """

  use Agent

  alias Manager.ConfigStruct, as: Config

  def start_link(_state) do
    Agent.start_link(&init_config/0, name: __MODULE__)
  end

  @spec init_config() :: Config.t()
  def init_config do
    %Config{}
  end
end
