defmodule Manager.Pubsub do
  @moduledoc """
  Public interface for the pub/sub.
  """

  @spec subscribe(key :: any()) :: :ok
  def subscribe(key) do
    {:ok, _} = Registry.register(EventBus, key, [])
    :ok
  end

  @spec unsubscribe(key :: atom()) :: :ok
  def unsubscribe(key) do
    Registry.unregister(EventBus, key)
  end

  @spec broadcast(topic :: atom(), payload :: any()) :: :ok
  def broadcast(topic, payload) do
    Registry.dispatch(EventBus, topic, fn entries ->
      for {pid, _} <- entries, pid != Kernel.self(), do: send(pid, payload)
    end)
  end
end
