defmodule Manager.Config do
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
