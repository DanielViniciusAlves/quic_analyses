defmodule Manager.Handler.Test do
  alias Manager.Handler
  alias Manager.Pubsub
  alias Manager

  use ExUnit.Case
  doctest Handler

  describe "Client test cases" do
    test "test handle_info server_started" do
      Pubsub.subscribe(:client_api)

      Task.start_link(fn ->
        response = Handler.handle_info(:server_started, %{})
      end)

      assert_receive {:init, %{}}
    end

    test "test handle_info client_terminate completed" do
      response = Handler.handle_info({:client_terminate, :completed}, %{})

      assert response == {:noreply, %{}}
    end

    test "test handle_info client_error" do
      response = Handler.handle_info({:client_terminate, {:client_error, "error"}}, %{})

      assert response == {:stop, :normal, %{}}
    end

    test "test server_terminate error" do
      response = Handler.handle_info({:server_terminate, {:error, "error"}}, %{})

      assert response == {:stop, :normal, %{}}
    end

    test "test server_terminate" do
      response = Handler.handle_info({:server_terminate, :normal}, %{})

      assert response == {:stop, :normal, %{}}
    end

    test "test terminate" do
      Pubsub.subscribe(:server_api)
      Pubsub.subscribe(:client_api)

      Task.start_link(fn ->
        response = Handler.terminate(:normal, %{})
      end)

      config = Manager.get_config()
      assert config.status == :off
      assert_receive {:stop, :finished}
      assert_receive {:stop, :finished}
    end
  end
end
