defmodule Manager.Test do
  alias Manager.ConfigStruct
  alias Manager

  use ExUnit.Case
  doctest Manager

  describe "Test Manager module" do
    test "Change delay_netem_config" do
      config = Manager.get_config()
      config = Map.put(config, :delay_netem_config, false)
      assert Manager.delay_netem_config(false) == config
    end

    test "Change connection_type" do
      config = Manager.get_config()
      config = Map.put(config, :connection_type, :tcp)
      assert Manager.set_connection_type(:tcp) == config
    end

    test "Change status" do
      config = Manager.get_config()
      config = Map.put(config, :status, :on)
      assert Manager.set_status(:on) == config
    end

    test "Change delay" do
      config = Manager.get_config()
      config = Map.put(config, :delay, 100)
      assert Manager.set_delay(100) == config
    end

    test "Change loss" do
      config = Manager.get_config()
      config = Map.put(config, :loss, 100)
      assert Manager.set_loss(100) == config
    end

    test "Change corruption" do
      config = Manager.get_config()
      config = Map.put(config, :corruption, 100)
      assert Manager.set_corruption(100) == config
    end

    test "Change bandwidth_limit" do
      config = Manager.get_config()
      config = Map.put(config, :bandwidth_limit, 100)
      assert Manager.set_bandwidth_limit(100) == config
    end

    test "Change clients_number" do
      config = Manager.get_config()
      config = Map.put(config, :clients_number, 100)
      assert Manager.set_clients_number(100) == config
    end

    test "Change connection_duration" do
      config = Manager.get_config()
      config = Map.put(config, :connection_duration, 100)
      assert Manager.set_connection_duration(100) == config
    end
  end
end
