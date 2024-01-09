defmodule Client do
  @moduledoc """
  Documentation for `Client`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Client.hello()
      :world

  """
  def hello do
    Manager.Pubsub.subscribe(:test)
  end
end
