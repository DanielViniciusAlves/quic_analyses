defmodule Client.Manager.Test do
  use ExUnit.Case
  alias Client.Error.ErrorHandler, as: Error
  alias Client.Manager, as: Client
  alias Manager.Pubsub

  doctest Client

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

  describe "Manager init cases" do
    test "test success init of the Manager", state do
      response = Client.handle_info({:init, state.config}, %{})
      assert response == {:noreply, state.config}
    end

    test "success init of the Manager without delay netem", state do
      config = Map.put(state.config, :delay_netem_config, false)
      response = Client.handle_info({:init, config}, %{})
      assert response == {:noreply, config}
    end

    test "error case when starting the test" do
      Pubsub.subscribe(:manager)
      Pubsub.subscribe(:client)

      Task.start_link(fn ->
        assert {:stop, :normal, %{}} ==
                 Client.handle_info({:init, %{delay_netem_config: true}}, %{})
      end)

      assert_receive {:client_terminate, {:client_error, "Error starting Netem"}}
      assert_receive {:stop, "Error starting Netem"}
    end
  end

  describe "Client stop cases" do
    test "test success stop of the Client" do
      response = Client.handle_info({:client_stop, :completed}, %{clients_number: 10})
      assert response == {:noreply, %{clients_number: 9}}
    end

    test "test success end of Testing" do
      Pubsub.subscribe(:manager)

      Task.start_link(fn ->
        response = Client.handle_info({:client_stop, :completed}, %{clients_number: 1})

        assert response == {:noreply, %{clients_number: 0}}
      end)

      assert_receive {:client_terminate, :completed}
    end

    test "test error in client  termination" do
      Pubsub.subscribe(:manager)
      Pubsub.subscribe(:client)

      Task.start_link(fn ->
        response =
          Client.handle_info({:client_stop, "Error stopping the client"}, %{clients_number: 1})

        assert response == {:stop, :normal, %{clients_number: 1}}
      end)

      base_error = Error.exception(:invalid_run)
      assert_receive {:client_terminate, {:client_error, "Error stopping the client"}}
      assert_receive {:stop, error}
      assert base_error == error
    end

    test "test stop Manager" do
      Pubsub.subscribe(:client)

      Task.start_link(fn ->
        response = Client.handle_info({:stop, "test"}, %{})

        assert response == {:stop, :normal, %{}}
      end)

      assert_receive {:stop, "test"}
    end
  end
end
