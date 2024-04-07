defmodule Server.Genserver.Acceptor.Test do
  alias Manager.Pubsub
  alias Server.Genserver.Acceptor

  use ExUnit.Case

  defmodule TestConnectionHandler do
    def handle_message(message, _state) do
      assert message == "test_message"
      :ok
    end

    def handle_connection(state) do
      assert state == %{connection_handler: TestConnectionHandler}
      :ok
    end
  end

  defmodule TestConnectionHandlerError do
    def handle_connection(state) do
      assert state == %{connection_handler: TestConnectionHandlerError}
      {:error, "error"}
    end
  end

  describe "Stop cases" do
    test "test acceptor stop" do
      response = Acceptor.handle_info({:stop, :normal}, %{})
      assert response == {:stop, :normal, :stop}
    end
  end

  describe "Handle message cases" do
    test "test handle message" do
      response =
        Acceptor.handle_info("test_message", %{connection_handler: TestConnectionHandler})

      assert response == :ok
    end
  end

  describe "Handle connection cases" do
    test "test handle connection success" do
      response = Acceptor.handle_cast(:accept, %{connection_handler: TestConnectionHandler})

      assert response == :ok
    end

    test "test handle connection error case" do
      response = Acceptor.handle_cast(:accept, %{connection_handler: TestConnectionHandlerError})

      assert response == {:stop, :normal, :accept}
    end
  end

  describe "Terminate cases" do
    test "test success terminate" do
      response = Acceptor.terminate(nil, :ok)

      assert response == :ok
    end

    test "test error terminate" do
      Pubsub.subscribe(:server)

      Task.start_link(fn ->
        response = Acceptor.terminate(nil, :error)

        assert response == {:stop, :normal, %{}}
      end)

      assert_receive {:error, :error}
    end
  end
end
