defmodule Manager.Pubsub do
  @moduledoc """
  Public interface for the pub/sub.
  """

  def subscribe(key) do
    {:ok, _} = Registry.register(EventBus, key, [])
    :ok
  end

  def unsubscribe(key) do
    Registry.unregister(EventBus, key)
  end

  def broadcast(topic, payload) do
    Registry.dispatch(EventBus, topic, fn entries ->
      for {pid, _} <- entries, pid != Kernel.self(), do: send(pid, payload)
    end)
  end
end
