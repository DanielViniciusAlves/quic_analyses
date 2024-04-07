defmodule Client.Test do
  use ExUnit.Case
  alias Client.Error.ErrorHandler, as: Error
  alias Client.Genserver.Client, as: Client
  alias Manager.Pubsub

  doctest Client

  defmodule TestConnectionHandler do
    def handle_connection(message, _state) do
      assert message == "test_message"
    end
  end

  setup_all do
    config = %{
      delay: 100,
      loss: 5,
      corruption: 1,
      bandwidth_limit: 10,
      delay_netem_config: true
    }

    {:ok, config: config}
  end

  describe "Client base cases" do
    test "test Client stop", state do
      response = Client.handle_info({:stop, :normal}, %{})
      assert response == {:stop, :normal, :normal}
    end

    test "test handle message", state do
      response = Client.handle_info("test_message", %{connection_handler: TestConnectionHandler})
      assert response == {:noreply, %{connection_handler: TestConnectionHandler}}
    end
  end

  describe "Client terminate options" do
    test "test terminate", state do
      Pubsub.subscribe(:client)

      Task.start_link(fn ->
        assert :ok == Client.terminate(:normal, :normal)
      end)

      assert_receive {:client_stop, :completed}

      Task.start_link(fn ->
        assert :ok == Client.terminate(:normal, {:error, "error"})
      end)

      assert_receive {:client_stop, "error"}

      assert :ok == Client.terminate(:normal, :finished)

      Task.start_link(fn ->
        assert :ok == Client.terminate(:normal, "test")
      end)

      assert_receive {:client_stop, "test"}
    end
  end
end
