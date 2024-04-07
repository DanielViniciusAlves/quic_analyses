defmodule Manager.Pubsub do
  @moduledoc """
  Public interface for the pub/sub.

  This module provides functions for subscribing to topics, unsubscribing from topics, and broadcasting messages to subscribers.

  ## Functions

  ### `subscribe/1`

  Subscribes to a topic in the pub/sub system.

  #### Parameters
  - `key`: Any value representing the topic to subscribe to.

  ### `unsubscribe/1`

  Unsubscribes from a topic in the pub/sub system.

  #### Parameters
  - `key`: Atom representing the topic to unsubscribe from.

  ### `broadcast/2`

  Broadcasts a message to all subscribers of a topic.

  #### Parameters
  - `topic`: Atom representing the topic to broadcast the message to.
  - `payload`: Any value representing the message payload to be broadcasted.

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
