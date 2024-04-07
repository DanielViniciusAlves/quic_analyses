defmodule Server.Manager.Test do
  alias Server.Error.ErrorHandler, as: Error
  alias Server.Manager, as: Server
  alias Manager.ConfigStruct
  alias Manager.Pubsub
  use ExUnit.Case
  doctest Server

  setup_all do
    config = %ConfigStruct{
      delay: 100,
      loss: 5,
      corruption: 1,
      bandwidth_limit: 10,
      delay_netem_config: true
    }

    {:ok, config: config}
  end

  describe "Server init cases" do
    test "test success init of the Server", state do
      Pubsub.subscribe(:manager)

      Task.start_link(fn ->
        {:noreply, _map} = Server.handle_info({:init, state.config}, %{})
      end)

      assert_receive :server_started
    end

    test "test erro in init of the Server", state do
      Pubsub.subscribe(:manager)
      Pubsub.subscribe(:server)

      Task.start_link(fn ->
        config = Map.put(state.config, :connection_type, :test)
        response = Server.handle_info({:init, config}, %{})

        assert response == {:stop, :normal, %{}}
      end)

      base_error = Error.exception(:invalid_type, "Invalid connection type")
      assert_receive {:server_terminate, {:server_error, error}}
      assert error == base_error
      assert_receive {:stop, error}
      assert error == base_error
    end
  end

  describe "Test finished cases" do
    test "test success case of finished" do
      Task.start_link(fn ->
        response =
          Server.handle_info({:finished, :os.system_time(:millisecond), 10}, %{
            clients_number: 10,
            filename: "test"
          })

        assert response == {:noreply, %{clients_number: 10, filename: "test"}}
      end)
    end

    test "test success case of finished with boradcast" do
      Pubsub.subscribe(:manager)

      Task.start_link(fn ->
        response =
          Server.handle_info({:finished, :os.system_time(:millisecond), 10}, %{
            clients_number: 1,
            filename: "test"
          })

        assert response == {:noreply, %{clients_number: 0, filename: "test"}}
      end)

      assert_receive {:server_terminate, :completed}
    end
  end

  describe "Test stop cases" do
    test "test success stop of the Server" do
      Pubsub.subscribe(:server)

      Task.start_link(fn ->
        response = Server.handle_info({:stop, :test}, %{})

        assert response == {:stop, :normal, %{}}
      end)

      assert_receive {:stop, :test}
    end
  end
end
